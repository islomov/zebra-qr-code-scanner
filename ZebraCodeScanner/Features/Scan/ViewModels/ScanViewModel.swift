//
//  ScanViewModel.swift
//  ZebraCodeScanner
//
//  Created by Sardor Islomov on 25/01/26.
//

import SwiftUI
import Combine
import PhotosUI
import Vision
import AudioToolbox
import AVFoundation

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

    @Published var scanMode: ScanMode = .qrCode
    @Published var showManualEntry: Bool = false
    @Published var manualBarcodeText: String = ""
    @Published var manualBarcodeType: String = "ean13"

    private lazy var scannerService = ScannerService.shared
    private lazy var dataManager = CoreDataManager.shared
    private lazy var productLookupService = ProductLookupService.shared
    private var hasAuthorizedCamera = false

    init() {
        // Only record permission state — don't start the camera here.
        // Camera init is heavyweight and blocks the main thread for ~1-2s.
        // The actual scanning starts when the user navigates to the Scan tab.
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            hasAuthorizedCamera = true
        }
    }

    var isBarcode: Bool {
        scannedType != "qr" && scannedType != "datamatrix" && scannedType != "aztec" && scannedType != "text" && !scannedType.isEmpty
    }

    var isSupported: Bool {
        AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) != nil
    }

    func checkAndRequestPermission() async {
        print("[ScanVM] checkAndRequestPermission called")
        scannerService.checkPermission()

        switch scannerService.permissionStatus {
        case .authorized:
            print("[ScanVM] permission authorized, setting isScanning=true")
            hasAuthorizedCamera = true
            isScanning = true
        case .notDetermined:
            print("[ScanVM] permission notDetermined, requesting...")
            let granted = await scannerService.requestPermission()
            if granted {
                print("[ScanVM] permission granted, setting isScanning=true")
                hasAuthorizedCamera = true
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
        if hasAuthorizedCamera {
            isScanning = true
            return
        }
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
        guard !content.isEmpty, !showResult else { return }

        isScanning = false
        scannedContent = content
        scannedType = type
        productInfo = nil
        showResult = true

        // Auto-save to history
        _ = dataManager.saveScannedCode(type: type, content: content)

        // Haptic feedback
        if UserDefaults.standard.object(forKey: "vibrateOnScan") == nil || UserDefaults.standard.bool(forKey: "vibrateOnScan") {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }

        // Sound feedback
        if UserDefaults.standard.object(forKey: "soundOnScan") == nil || UserDefaults.standard.bool(forKey: "soundOnScan") {
            AudioServicesPlaySystemSound(1057)
        }

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

    func submitManualBarcode() {
        let trimmed = manualBarcodeText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        showManualEntry = false
        handleScannedCode(content: trimmed, type: manualBarcodeType)
        manualBarcodeText = ""
    }

    func handleScanError(_ error: Error) {
        errorMessage = error.localizedDescription
    }

    func processSelectedPhoto() {
        guard let selectedPhoto else { return }

        Task {
            guard let data = try? await selectedPhoto.loadTransferable(type: Data.self),
                  let uiImage = UIImage(data: data) else {
                errorMessage = String(localized: "scan.error.failed_to_load_image", defaultValue: "Failed to load image")
                return
            }

            await scanImageForCodes(uiImage)
        }
    }

    private func scanImageForCodes(_ image: UIImage) async {
        guard let cgImage = image.cgImage else {
            errorMessage = String(localized: "scan.error.invalid_image", defaultValue: "Invalid image format")
            return
        }

        let request = VNDetectBarcodesRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        do {
            try handler.perform([request])

            guard let observations = request.results, !observations.isEmpty else {
                errorMessage = String(localized: "scan.error.no_code_found", defaultValue: "No QR code or barcode found in this image")
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
            errorMessage = "\(String(localized: "scan.error.scan_failed", defaultValue: "Failed to scan image:")) \(error.localizedDescription)"
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
        if !isScanning {
            startScanning()
        }
        print("[ScanVM] resetScan() done")
    }

    deinit {
        print("[ScanVM] DEINIT - ScanViewModel destroyed")
    }

    func getTypeDisplayName(_ type: String) -> String {
        switch type {
        case "qr":
            return String(localized: "code_type.qr_code", defaultValue: "QR Code")
        case "code128":
            return String(localized: "code_type.code128", defaultValue: "Code 128")
        case "ean13":
            return String(localized: "code_type.ean13", defaultValue: "EAN-13")
        case "ean8":
            return String(localized: "code_type.ean8", defaultValue: "EAN-8")
        case "upce":
            return String(localized: "code_type.upce", defaultValue: "UPC-E")
        case "code39":
            return String(localized: "code_type.code39", defaultValue: "Code 39")
        case "code93":
            return String(localized: "code_type.code93", defaultValue: "Code 93")
        case "itf14":
            return String(localized: "code_type.itf14", defaultValue: "ITF-14")
        case "datamatrix":
            return String(localized: "code_type.data_matrix", defaultValue: "Data Matrix")
        case "pdf417":
            return String(localized: "code_type.pdf417", defaultValue: "PDF417")
        case "aztec":
            return String(localized: "code_type.aztec", defaultValue: "Aztec")
        default:
            return String(localized: "common.barcode", defaultValue: "Barcode")
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
