//
//  ScanView.swift
//  ZebraCodeScanner
//
//  Created by Sardor Islomov on 25/01/26.
//

import SwiftUI
import VisionKit
import PhotosUI

struct ScanView: View {
    @Binding var showSettings: Bool
    @ObservedObject var viewModel: ScanViewModel
    var isActiveTab: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                if isActiveTab {
                    if viewModel.isSupported {
                        scannerView
                    } else {
                        unsupportedView
                    }
                } else {
                    Color(.systemBackground)
                }
            }
            .navigationTitle("Scan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    PhotosPicker(selection: $viewModel.selectedPhoto, matching: .images) {
                        Image(systemName: "photo.on.rectangle")
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .onChange(of: viewModel.selectedPhoto) { _ in
                viewModel.processSelectedPhoto()
            }
            .sheet(isPresented: $viewModel.showResult) {
                if viewModel.isBarcode {
                    ProductResultView(
                        content: viewModel.scannedContent,
                        type: viewModel.scannedType,
                        productInfo: viewModel.productInfo,
                        isLoading: viewModel.isLoadingProduct,
                        onScanAgain: {
                            viewModel.showResult = false
                            viewModel.resetScan()
                        },
                        onDismiss: {
                            viewModel.showResult = false
                            viewModel.resetScan()
                        }
                    )
                } else {
                    ScanResultView(
                        content: viewModel.scannedContent,
                        type: viewModel.scannedType,
                        onScanAgain: {
                            viewModel.showResult = false
                            viewModel.resetScan()
                        },
                        onDismiss: {
                            viewModel.showResult = false
                            viewModel.resetScan()
                        }
                    )
                }
            }
            .sheet(isPresented: $viewModel.showManualEntry) {
                ManualBarcodeEntryView(viewModel: viewModel)
            }
            .alert("Camera Access Required", isPresented: $viewModel.showPermissionAlert) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Please allow camera access in Settings to scan QR codes and barcodes.")
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred")
            }
        }
    }

    private var scannerView: some View {
        ZStack {
            // Keep DataScannerRepresentable always mounted to avoid recreation
            DataScannerRepresentable(
                scanMode: viewModel.scanMode,
                onScanned: { content, type in
                    viewModel.handleScannedCode(content: content, type: type)
                },
                onError: { error in
                    viewModel.handleScanError(error)
                },
                isScanning: $viewModel.isScanning,
                isTorchOn: $viewModel.isTorchOn
            )
            .ignoresSafeArea()

            if viewModel.isScanning {
                // QR frame overlay
                if viewModel.scanMode == .qrCode {
                    QRFrameOverlay()
                }

                // Overlay controls
                VStack {
                    Spacer()

                    HStack(spacing: 40) {
                        Button {
                            viewModel.toggleTorch()
                        } label: {
                            Image(systemName: viewModel.isTorchOn ? "flashlight.on.fill" : "flashlight.off.fill")
                                .font(.title2)
                                .foregroundStyle(.white)
                                .padding()
                                .background(Circle().fill(.ultraThinMaterial))
                        }

                        if viewModel.scanMode == .barcode {
                            Button {
                                viewModel.showManualEntry = true
                            } label: {
                                Image(systemName: "keyboard")
                                    .font(.title2)
                                    .foregroundStyle(.white)
                                    .padding()
                                    .background(Circle().fill(.ultraThinMaterial))
                            }
                        }
                    }
                    .padding(.bottom, 16)

                    // Mode picker at bottom
                    ScanModePicker(selectedMode: $viewModel.scanMode)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 30)
                }
            } else {
                // Camera not active - show placeholder over scanner
                Color(.systemBackground)

                VStack(spacing: 24) {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 80))
                        .foregroundStyle(.tint)

                    Text("Scan QR & Barcodes")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Use your camera to scan QR codes and barcodes.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Button {
                        viewModel.startScanning()
                    } label: {
                        Label("Start Scanning", systemImage: "camera")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: 200)
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding()
            }
        }
    }

    private var unsupportedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.fill.badge.ellipsis")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("Scanner Not Available")
                .font(.title2)
                .fontWeight(.semibold)

            Text("This device doesn't support barcode scanning. You can still import images from your photo library.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            PhotosPicker(selection: $viewModel.selectedPhoto, matching: .images) {
                Label("Import from Photos", systemImage: "photo.on.rectangle")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: 200)
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

// MARK: - QR Frame Overlay

struct QRFrameOverlay: View {
    @State private var isAnimating = false
    private let frameSize: CGFloat = 250
    private let cornerLength: CGFloat = 30
    private let lineWidth: CGFloat = 4

    var body: some View {
        ZStack {
            // Dimmed background with cutout
            Color.black.opacity(0.4)
                .reverseMask {
                    RoundedRectangle(cornerRadius: 16)
                        .frame(width: frameSize, height: frameSize)
                }

            // Corner brackets
            ZStack {
                // Top-left
                CornerShape(corner: .topLeft, length: cornerLength)
                // Top-right
                CornerShape(corner: .topRight, length: cornerLength)
                // Bottom-left
                CornerShape(corner: .bottomLeft, length: cornerLength)
                // Bottom-right
                CornerShape(corner: .bottomRight, length: cornerLength)
            }
            .frame(width: frameSize, height: frameSize)
            .foregroundStyle(.white)
            .opacity(isAnimating ? 1.0 : 0.6)
            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
            .onAppear { isAnimating = true }
        }
        .ignoresSafeArea()
    }
}

struct CornerShape: View {
    enum Corner {
        case topLeft, topRight, bottomLeft, bottomRight
    }

    let corner: Corner
    let length: CGFloat
    let lineWidth: CGFloat = 4

    var body: some View {
        GeometryReader { geo in
            Path { path in
                let w = geo.size.width
                let h = geo.size.height

                switch corner {
                case .topLeft:
                    path.move(to: CGPoint(x: 0, y: length))
                    path.addLine(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: length, y: 0))
                case .topRight:
                    path.move(to: CGPoint(x: w - length, y: 0))
                    path.addLine(to: CGPoint(x: w, y: 0))
                    path.addLine(to: CGPoint(x: w, y: length))
                case .bottomLeft:
                    path.move(to: CGPoint(x: 0, y: h - length))
                    path.addLine(to: CGPoint(x: 0, y: h))
                    path.addLine(to: CGPoint(x: length, y: h))
                case .bottomRight:
                    path.move(to: CGPoint(x: w - length, y: h))
                    path.addLine(to: CGPoint(x: w, y: h))
                    path.addLine(to: CGPoint(x: w, y: h - length))
                }
            }
            .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
        }
    }
}

extension View {
    @ViewBuilder
    func reverseMask<Mask: View>(@ViewBuilder _ mask: () -> Mask) -> some View {
        self.mask(
            ZStack {
                Rectangle()
                mask()
                    .blendMode(.destinationOut)
            }
            .compositingGroup()
        )
    }
}

// MARK: - Scan Mode Picker

struct ScanModePicker: View {
    @Binding var selectedMode: ScanMode
    @Namespace private var animation

    var body: some View {
        HStack(spacing: 0) {
            ForEach(ScanMode.allCases, id: \.self) { mode in
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        selectedMode = mode
                    }
                } label: {
                    Text(mode.rawValue)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(selectedMode == mode ? .white : .white.opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background {
                            if selectedMode == mode {
                                Capsule()
                                    .fill(.white.opacity(0.25))
                                    .matchedGeometryEffect(id: "tab", in: animation)
                            }
                        }
                }
            }
        }
        .padding(4)
        .background(Capsule().fill(.black.opacity(0.5)))
    }
}

// MARK: - Manual Barcode Entry

struct ManualBarcodeEntryView: View {
    @ObservedObject var viewModel: ScanViewModel
    @Environment(\.dismiss) private var dismiss

    private let barcodeTypes = [
        ("ean13", "EAN-13"),
        ("ean8", "EAN-8"),
        ("upce", "UPC-E"),
        ("code128", "Code 128"),
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Barcode Type") {
                    Picker("Type", selection: $viewModel.manualBarcodeType) {
                        ForEach(barcodeTypes, id: \.0) { value, label in
                            Text(label).tag(value)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Barcode Number") {
                    TextField("Enter barcode number", text: $viewModel.manualBarcodeText)
                        .keyboardType(.numberPad)
                        .textContentType(.none)
                        .autocorrectionDisabled()
                }

                Section {
                    Button {
                        viewModel.submitManualBarcode()
                    } label: {
                        HStack {
                            Spacer()
                            Label("Search", systemImage: "magnifyingglass")
                                .font(.headline)
                            Spacer()
                        }
                    }
                    .disabled(viewModel.manualBarcodeText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .navigationTitle("Enter Barcode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ScanView_Previews: PreviewProvider {
    static var previews: some View {
        ScanView(showSettings: .constant(false), viewModel: ScanViewModel(), isActiveTab: true)
    }
}
