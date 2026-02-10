//
//  ScannerService.swift
//  ZebraCodeScanner
//
//  Created by Sardor Islomov on 25/01/26.
//

import SwiftUI
import Combine
import AVFoundation

@MainActor
final class ScannerService: ObservableObject {

    static let shared = ScannerService()

    @Published var isAvailable: Bool = false
    @Published var permissionStatus: AVAuthorizationStatus = .notDetermined

    private init() {
        checkAvailability()
        checkPermission()
    }

    func checkAvailability() {
        isAvailable = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) != nil
    }

    func checkPermission() {
        permissionStatus = AVCaptureDevice.authorizationStatus(for: .video)
    }

    func requestPermission() async -> Bool {
        let granted = await AVCaptureDevice.requestAccess(for: .video)
        checkPermission()
        return granted
    }
}

// MARK: - Scan Mode Enum (shared with ScanViewModel)
enum ScanMode: String, CaseIterable {
    case qrCode = "qrCode"
    case barcode = "barcode"

    var title: String {
        switch self {
        case .qrCode: return String(localized: "scan_mode.qr_code", defaultValue: "QR Code")
        case .barcode: return String(localized: "scan_mode.barcode", defaultValue: "Barcode")
        }
    }
}

// MARK: - Camera Scanner UIViewControllerRepresentable

struct CameraScannerRepresentable: UIViewControllerRepresentable {
    let onScanned: (String, String) -> Void
    let onError: (Error) -> Void
    let onZoomChanged: (CGFloat) -> Void
    let onFocusTap: (CGPoint) -> Void

    @Binding var isScanning: Bool
    @Binding var isTorchOn: Bool

    func makeUIViewController(context: Context) -> CameraScannerViewController {
        let controller = CameraScannerViewController()
        controller.onScanned = onScanned
        controller.onError = onError
        controller.onZoomChanged = onZoomChanged
        controller.onFocusTap = onFocusTap
        return controller
    }

    func updateUIViewController(_ controller: CameraScannerViewController, context: Context) {
        if isScanning {
            controller.startScanning()
        } else {
            controller.stopScanning()
        }

        let coordinator = context.coordinator
        if coordinator.previousTorchState != isTorchOn {
            coordinator.previousTorchState = isTorchOn
            controller.setTorch(on: isTorchOn)
        }
    }

    static func dismantleUIViewController(_ controller: CameraScannerViewController, coordinator: Coordinator) {
        controller.stopScanning()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var previousTorchState: Bool = false
    }
}

// MARK: - Camera Scanner View Controller

class CameraScannerViewController: UIViewController {

    private let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "com.zebra.scanner.session")
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var isConfigured = false
    private var pendingStart = false

    var onScanned: ((String, String) -> Void)?
    var onError: ((Error) -> Void)?
    var onZoomChanged: ((CGFloat) -> Void)?
    var onFocusTap: ((CGPoint) -> Void)?

    // Debounce: avoid firing for the same code repeatedly
    private var lastScannedValue: String?
    private var lastScanTime: Date?

    // Zoom
    private var initialZoomFactor: CGFloat = 1.0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        // Pinch-to-zoom gesture
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        view.addGestureRecognizer(pinchGesture)

        // Tap-to-focus gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tapGesture)

        // Configure the capture session on a background queue — no main thread blocking.
        sessionQueue.async { [weak self] in
            self?.configureSession()
        }
    }

    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        handlePinchZoom(scale: gesture.scale, state: gesture.state)
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let tapPoint = gesture.location(in: view)
        focusAt(pointInView: tapPoint)
    }

    // MARK: - Pinch to Zoom

    func handlePinchZoom(scale: CGFloat, state: UIGestureRecognizer.State) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }

        switch state {
        case .began:
            initialZoomFactor = device.videoZoomFactor
        case .changed:
            let maxZoom = min(device.activeFormat.videoMaxZoomFactor, 10.0)
            let newZoom = min(max(initialZoomFactor * scale, 1.0), maxZoom)
            do {
                try device.lockForConfiguration()
                device.videoZoomFactor = newZoom
                device.unlockForConfiguration()
                onZoomChanged?(newZoom)
            } catch {
                print("[CameraScanner] Failed to set zoom: \(error)")
            }
        default:
            break
        }
    }

    // MARK: - Tap to Focus

    func focusAt(pointInView: CGPoint) {
        guard let previewLayer = previewLayer else { return }

        let devicePoint = previewLayer.captureDevicePointConverted(fromLayerPoint: pointInView)

        guard let device = AVCaptureDevice.default(for: .video) else { return }

        do {
            try device.lockForConfiguration()

            if device.isFocusPointOfInterestSupported {
                device.focusPointOfInterest = devicePoint
                device.focusMode = .autoFocus
            }

            if device.isExposurePointOfInterestSupported {
                device.exposurePointOfInterest = devicePoint
                device.exposureMode = .autoExpose
            }

            device.unlockForConfiguration()
        } catch {
            print("[CameraScanner] Failed to set focus: \(error)")
        }

        onFocusTap?(pointInView)
    }

    private func configureSession() {
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            return
        }

        do {
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)

            captureSession.beginConfiguration()

            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            }

            let metadataOutput = AVCaptureMetadataOutput()
            if captureSession.canAddOutput(metadataOutput) {
                captureSession.addOutput(metadataOutput)
                metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
                metadataOutput.metadataObjectTypes = [
                    .qr, .dataMatrix, .aztec,
                    .ean13, .ean8, .upce,
                    .code128, .code39, .code93,
                    .interleaved2of5, .pdf417
                ]
            }

            captureSession.commitConfiguration()
            isConfigured = true

            // Setup preview layer on main queue
            DispatchQueue.main.async { [weak self] in
                self?.setupPreviewLayer()
            }

            // If startScanning() was called before configuration finished, start now.
            if pendingStart {
                pendingStart = false
                captureSession.startRunning()
            }
        } catch {
            DispatchQueue.main.async { [weak self] in
                self?.onError?(error)
            }
        }
    }

    private func setupPreviewLayer() {
        let layer = AVCaptureVideoPreviewLayer(session: captureSession)
        layer.videoGravity = .resizeAspectFill
        layer.frame = view.bounds
        view.layer.insertSublayer(layer, at: 0)
        previewLayer = layer
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    func startScanning() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            if self.isConfigured {
                if !self.captureSession.isRunning {
                    self.captureSession.startRunning()
                }
            } else {
                self.pendingStart = true
            }
        }
    }

    func stopScanning() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            self.pendingStart = false
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }
        }
        lastScannedValue = nil
        lastScanTime = nil
    }

    func setTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video),
              device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            device.torchMode = on ? .on : .off
            device.unlockForConfiguration()
        } catch {
            print("[CameraScanner] Failed to set torch: \(error)")
        }
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate

extension CameraScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let stringValue = metadataObject.stringValue,
              !stringValue.isEmpty else { return }

        // Debounce: ignore the same value within 3 seconds
        let now = Date()
        if stringValue == lastScannedValue,
           let lastTime = lastScanTime,
           now.timeIntervalSince(lastTime) < 3.0 {
            return
        }

        lastScannedValue = stringValue
        lastScanTime = now

        let type = mapType(metadataObject.type)
        onScanned?(stringValue, type)
    }

    private func mapType(_ type: AVMetadataObject.ObjectType) -> String {
        switch type {
        case .qr: return "qr"
        case .ean13: return "ean13"
        case .ean8: return "ean8"
        case .code128: return "code128"
        case .code39: return "code39"
        case .code93: return "code93"
        case .upce: return "upce"
        case .pdf417: return "pdf417"
        case .aztec: return "aztec"
        case .dataMatrix: return "datamatrix"
        case .interleaved2of5: return "itf14"
        default: return "barcode"
        }
    }
}
