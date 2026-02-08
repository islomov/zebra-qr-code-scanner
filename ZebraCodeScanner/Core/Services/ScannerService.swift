//
//  ScannerService.swift
//  ZebraCodeScanner
//
//  Created by Sardor Islomov on 25/01/26.
//

import SwiftUI
import Combine
import VisionKit
import AVFoundation
import Vision

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
        isAvailable = DataScannerViewController.isSupported && DataScannerViewController.isAvailable
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

    var recognizedDataTypes: Set<DataScannerViewController.RecognizedDataType> {
        switch self {
        case .qrCode:
            return [
                .barcode(symbologies: [
                    .qr,
                    .dataMatrix,
                    .aztec
                ])
            ]
        case .barcode:
            return [
                .barcode(symbologies: [
                    .code128,
                    .ean13,
                    .ean8,
                    .upce,
                    .code39,
                    .code93,
                    .itf14,
                    .pdf417
                ])
            ]
        }
    }
}

// MARK: - DataScanner UIViewControllerRepresentable
struct DataScannerRepresentable: UIViewControllerRepresentable {
    let onScanned: (String, String) -> Void
    let onError: (Error) -> Void

    @Binding var isScanning: Bool
    @Binding var isTorchOn: Bool

    /// All symbologies recognized at once — no need to recreate the scanner when switching modes.
    private static let allRecognizedDataTypes: Set<DataScannerViewController.RecognizedDataType> = [
        .barcode(symbologies: [
            .qr, .dataMatrix, .aztec,
            .code128, .ean13, .ean8, .upce,
            .code39, .code93, .itf14, .pdf417
        ])
    ]

    func makeUIViewController(context: Context) -> DataScannerViewController {
        print("[Scanner] makeUIViewController - creating scanner")
        let scanner = DataScannerViewController(
            recognizedDataTypes: Self.allRecognizedDataTypes,
            qualityLevel: .balanced,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: true,
            isPinchToZoomEnabled: true,
            isGuidanceEnabled: false,
            isHighlightingEnabled: false
        )
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        if isScanning {
            if !uiViewController.isScanning {
                print("[Scanner] Starting scanning")
                try? uiViewController.startScanning()
            }
        } else {
            if uiViewController.isScanning {
                print("[Scanner] Stopping scanning")
                uiViewController.stopScanning()
            }
        }

        let coordinator = context.coordinator
        if coordinator.previousTorchState != isTorchOn {
            coordinator.previousTorchState = isTorchOn
            setTorch(on: isTorchOn)
        }
    }

    static func dismantleUIViewController(_ uiViewController: DataScannerViewController, coordinator: Coordinator) {
        print("[Scanner] dismantleUIViewController - stopping scanner")
        uiViewController.stopScanning()
    }

    private func setTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video),
              device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            device.torchMode = on ? .on : .off
            device.unlockForConfiguration()
        } catch {
            print("Failed to set torch: \(error)")
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onScanned: onScanned, onError: onError)
    }

    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let onScanned: (String, String) -> Void
        let onError: (Error) -> Void
        var previousTorchState: Bool = false

        init(onScanned: @escaping (String, String) -> Void, onError: @escaping (Error) -> Void) {
            self.onScanned = onScanned
            self.onError = onError
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            print("[Scanner] didTapOn item")
            processItem(item)
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            print("[Scanner] didAdd \(addedItems.count) items, total: \(allItems.count)")
            guard let item = addedItems.first else { return }
            processItem(item)
        }

        private func processItem(_ item: RecognizedItem) {
            switch item {
            case .barcode(let barcode):
                let content = barcode.payloadStringValue ?? ""
                let type = mapSymbologyToType(barcode.observation.symbology)
                onScanned(content, type)
            case .text(let text):
                onScanned(text.transcript, "text")
            @unknown default:
                break
            }
        }

        private func mapSymbologyToType(_ symbology: VNBarcodeSymbology) -> String {
            switch symbology {
            case .qr:
                return "qr"
            case .code128:
                return "code128"
            case .ean13:
                return "ean13"
            case .ean8:
                return "ean8"
            case .upce:
                return "upce"
            case .code39:
                return "code39"
            case .code93:
                return "code93"
            case .itf14:
                return "itf14"
            case .dataMatrix:
                return "datamatrix"
            case .pdf417:
                return "pdf417"
            case .aztec:
                return "aztec"
            default:
                return "barcode"
            }
        }

        func dataScanner(_ dataScanner: DataScannerViewController, becameUnavailableWithError error: DataScannerViewController.ScanningUnavailable) {
            print("[Scanner] becameUnavailableWithError: \(error)")
            onError(error)
        }

        deinit {
            print("[Scanner] Coordinator deinit")
        }
    }
}
