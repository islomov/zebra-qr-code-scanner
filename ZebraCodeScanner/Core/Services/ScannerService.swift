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

// MARK: - DataScanner UIViewControllerRepresentable
struct DataScannerRepresentable: UIViewControllerRepresentable {
    let recognizedDataTypes: Set<DataScannerViewController.RecognizedDataType>
    let onScanned: (String, String) -> Void
    let onError: (Error) -> Void

    @Binding var isScanning: Bool
    @Binding var isTorchOn: Bool

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: recognizedDataTypes,
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
                try? uiViewController.startScanning()
            }
        } else {
            if uiViewController.isScanning {
                uiViewController.stopScanning()
            }
        }

        setTorch(on: isTorchOn)
    }

    static func dismantleUIViewController(_ uiViewController: DataScannerViewController, coordinator: Coordinator) {
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
