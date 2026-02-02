//
//  ScanViewModel.swift
//  ZebraCodeScanner
//
//  Created by Sardor Islomov on 25/01/26.
//

import SwiftUI
import Combine
import VisionKit
import PhotosUI
import Vision

@MainActor
final class ScanViewModel: ObservableObject {
    @Published var isScanning: Bool = false
    @Published var isTorchOn: Bool = false
    @Published var scannedContent: String = ""
    @Published var scannedType: String = ""
    @Published var showResult: Bool = false
    @Published var showPermissionAlert: Bool = false
    @Published var errorMessage: String?

    @Published var selectedPhoto: PhotosPickerItem?

    @Published var productInfo: ProductInfo?
    @Published var isLoadingProduct: Bool = false

    private let scannerService = ScannerService.shared
    private let dataManager = CoreDataManager.shared
    private let productLookupService = ProductLookupService.shared

    var isBarcode: Bool {
        scannedType != "qr" && scannedType != "datamatrix" && scannedType != "aztec" && scannedType != "text" && !scannedType.isEmpty
    }

    var recognizedDataTypes: Set<DataScannerViewController.RecognizedDataType> {
        [
            .barcode(symbologies: [
                .qr,
                .code128,
                .ean13,
                .ean8,
                .upce,
                .code39,
                .code93,
                .itf14,
                .dataMatrix,
                .pdf417,
                .aztec
            ])
        ]
    }

    var isSupported: Bool {
        DataScannerViewController.isSupported
    }

    var isAvailable: Bool {
        DataScannerViewController.isAvailable
    }

    func checkAndRequestPermission() async {
        print("[ScanVM] checkAndRequestPermission called")
        scannerService.checkPermission()

        switch scannerService.permissionStatus {
        case .authorized:
            print("[ScanVM] permission authorized, setting isScanning=true")
            isScanning = true
        case .notDetermined:
            print("[ScanVM] permission notDetermined, requesting...")
            let granted = await scannerService.requestPermission()
            if granted {
                print("[ScanVM] permission granted, setting isScanning=true")
                isScanning = true
            } else {
                print("[ScanVM] permission denied by user")
                showPermissionAlert = true
            }
        case .denied, .restricted:
            print("[ScanVM] permission denied/restricted")
            showPermissionAlert = true
        @unknown default:
            showPermissionAlert = true
        }
    }

    func startScanning() {
        print("[ScanVM] startScanning() called, current isScanning=\(isScanning)")
        Task {
            await checkAndRequestPermission()
        }
    }

    func stopScanning() {
        print("[ScanVM] stopScanning() called, setting isScanning=false")
        isScanning = false
        isTorchOn = false
    }

    func toggleTorch() {
        isTorchOn.toggle()
    }

    func handleScannedCode(content: String, type: String) {
        print("[ScanVM] handleScannedCode: content=\(content), type=\(type)")
        guard !content.isEmpty else { return }

        stopScanning()

        scannedContent = content
        scannedType = type
        productInfo = nil
        showResult = true

        // Auto-save to history
        _ = dataManager.saveScannedCode(type: type, content: content)

        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        // Lookup product info for barcodes
        if isBarcode {
            lookupProduct(barcode: content)
        }
    }

    private func lookupProduct(barcode: String) {
        isLoadingProduct = true
        Task {
            let info = await productLookupService.lookupProduct(barcode: barcode)
            self.productInfo = info
            self.isLoadingProduct = false
        }
    }

    func handleScanError(_ error: Error) {
        errorMessage = error.localizedDescription
    }

    func processSelectedPhoto() {
        guard let selectedPhoto else { return }

        Task {
            guard let data = try? await selectedPhoto.loadTransferable(type: Data.self),
                  let uiImage = UIImage(data: data) else {
                errorMessage = "Failed to load image"
                return
            }

            await scanImageForCodes(uiImage)
        }
    }

    private func scanImageForCodes(_ image: UIImage) async {
        guard let cgImage = image.cgImage else {
            errorMessage = "Invalid image format"
            return
        }

        let request = VNDetectBarcodesRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        do {
            try handler.perform([request])

            guard let observations = request.results, !observations.isEmpty else {
                errorMessage = "No QR code or barcode found in this image"
                return
            }

            if let firstBarcode = observations.first {
                let content = firstBarcode.payloadStringValue ?? ""
                let type = mapSymbologyToType(firstBarcode.symbology)

                await MainActor.run {
                    handleScannedCode(content: content, type: type)
                }
            }
        } catch {
            errorMessage = "Failed to scan image: \(error.localizedDescription)"
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

    func saveToHistory() -> ScannedCodeEntity? {
        return dataManager.saveScannedCode(
            type: scannedType,
            content: scannedContent,
            productName: productInfo?.name,
            productBrand: productInfo?.brand,
            productImage: productInfo?.imageURL
        )
    }

    func resetScan() {
        print("[ScanVM] resetScan() called")
        scannedContent = ""
        scannedType = ""
        showResult = false
        errorMessage = nil
        productInfo = nil
        isLoadingProduct = false
        startScanning()
        print("[ScanVM] resetScan() done")
    }

    deinit {
        print("[ScanVM] DEINIT - ScanViewModel destroyed")
    }

    func getTypeDisplayName(_ type: String) -> String {
        switch type {
        case "qr":
            return "QR Code"
        case "code128":
            return "Code 128"
        case "ean13":
            return "EAN-13"
        case "ean8":
            return "EAN-8"
        case "upce":
            return "UPC-E"
        case "code39":
            return "Code 39"
        case "code93":
            return "Code 93"
        case "itf14":
            return "ITF-14"
        case "datamatrix":
            return "Data Matrix"
        case "pdf417":
            return "PDF417"
        case "aztec":
            return "Aztec"
        default:
            return "Barcode"
        }
    }

    func getTypeIcon(_ type: String) -> String {
        switch type {
        case "qr", "datamatrix", "aztec":
            return "qrcode"
        default:
            return "barcode"
        }
    }
}
