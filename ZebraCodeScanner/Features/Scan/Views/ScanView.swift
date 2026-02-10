//
//  ScanView.swift
//  ZebraCodeScanner
//
//  Created by Sardor Islomov on 25/01/26.
//

import SwiftUI
import PhotosUI

struct ScanView: View {
    @Binding var showSettings: Bool
    @ObservedObject var viewModel: ScanViewModel
    var isActiveTab: Bool

    var body: some View {
        ZStack {
            if viewModel.isSupported {
                scannerView
            }

            if !isActiveTab {
                Color(.systemBackground)
                    .ignoresSafeArea()
            } else if !viewModel.isSupported {
                unsupportedView
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
        .alert(String(localized: "scan.permission.title", defaultValue: "Camera Access Required"), isPresented: $viewModel.showPermissionAlert) {
            Button(String(localized: "scan.permission.open_settings", defaultValue: "Open Settings")) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button(String(localized: "common.cancel", defaultValue: "Cancel"), role: .cancel) {}
        } message: {
            Text(String(localized: "scan.permission.message", defaultValue: "Please allow camera access in Settings to scan QR codes and barcodes."))
        }
        .alert(String(localized: "scan.unavailable.title", defaultValue: "Scanning Unavailable"), isPresented: .constant(viewModel.errorMessage != nil)) {
            Button(String(localized: "common.ok", defaultValue: "OK")) {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? String(localized: "scan.unavailable.default_error", defaultValue: "An error occurred"))
        }
    }

    // MARK: - Scanner View

    private var scannerView: some View {
        ZStack {
            CameraScannerRepresentable(
                onScanned: { content, type in
                    viewModel.handleScannedCode(content: content, type: type)
                },
                onError: { error in
                    viewModel.handleScanError(error)
                },
                onZoomChanged: { zoom in
                    viewModel.currentZoom = zoom
                },
                onFocusTap: { point in
                    viewModel.focusPoint = point
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        viewModel.focusPoint = nil
                    }
                },
                isScanning: $viewModel.isScanning,
                isTorchOn: $viewModel.isTorchOn
            )
            .ignoresSafeArea()

            if viewModel.isScanning {
                // Frame overlay (pass-through touches)
                if viewModel.scanMode == .qrCode {
                    QRFrameOverlay()
                        .allowsHitTesting(false)
                } else {
                    BarcodeFrameOverlay()
                        .allowsHitTesting(false)
                }

                // Focus indicator
                if let focusPoint = viewModel.focusPoint {
                    FocusIndicatorView(point: focusPoint)
                        .allowsHitTesting(false)
                }

                // Zoom level indicator
                if viewModel.currentZoom > 1.05 {
                    VStack {
                        Spacer()
                        Text(String(format: "%.1fx", viewModel.currentZoom))
                            .font(.custom("Inter-Medium", size: 14))
                            .tracking(-0.408)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Capsule())
                            .padding(.bottom, viewModel.scanMode == .barcode ? 170 : 80)
                    }
                    .allowsHitTesting(false)
                }

                // Header
                VStack {
                    scanHeader
                    Spacer()
                }

                // Bottom controls
                VStack {
                    Spacer()

                    if viewModel.scanMode == .barcode {
                        actionButtons
                            .padding(.bottom, 16)
                    }

                    ScanModePicker(selectedMode: $viewModel.scanMode)
                        .padding(.horizontal, 44)
                        .padding(.bottom, 20)
                }
            } else {
                DesignColors.background
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    Image("icon-scan")
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 72, height: 72)
                        .foregroundStyle(DesignColors.primaryText)

                    Text(String(localized: "scan.welcome.title", defaultValue: "Scan QR & Barcodes"))
                        .font(.custom("Inter-SemiBold", size: 20))
                        .tracking(-0.408)
                        .foregroundStyle(DesignColors.primaryText)

                    Text(String(localized: "scan.welcome.message", defaultValue: "Use your camera to scan QR codes and barcodes."))
                        .font(.custom("Inter-Regular", size: 14))
                        .tracking(-0.408)
                        .foregroundStyle(DesignColors.secondaryText)
                        .multilineTextAlignment(.center)

                    Button {
                        viewModel.startScanning()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "camera")
                                .font(.system(size: 16, weight: .medium))
                            Text(String(localized: "scan.welcome.start_scanning", defaultValue: "Start Scanning"))
                                .font(.custom("Inter-Medium", size: 16))
                                .tracking(-0.408)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: 200)
                        .frame(height: 51)
                        .background(DesignColors.primaryActionBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Scan Header

    private var scanHeader: some View {
        ZStack {
            Text(String(localized: "scan.header.title", defaultValue: "Scan"))
                .font(.custom("Inter-SemiBold", size: 20))
                .tracking(-0.408)
                .foregroundStyle(.white)

            HStack {
                PhotosPicker(selection: $viewModel.selectedPhoto, matching: .images) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(DesignColors.primaryText)
                        .frame(width: 44, height: 44)
                        .background(DesignColors.cardBackground)
                        .clipShape(Circle())
                }

                Spacer()

                Button {
                    showSettings = true
                } label: {
                    Image("icon-setting")
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundStyle(DesignColors.primaryText)
                        .frame(width: 44, height: 44)
                        .background(DesignColors.cardBackground)
                        .clipShape(Circle())
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 16)
    }

    // MARK: - Action Buttons (Flashlight & Keyboard)

    private var actionButtons: some View {
        HStack(spacing: 16) {
            Button {
                viewModel.toggleTorch()
            } label: {
                Image(systemName: viewModel.isTorchOn ? "flashlight.on.fill" : "flashlight.off.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(DesignColors.primaryText)
                    .frame(width: 44, height: 44)
                    .background(DesignColors.lightText)
                    .clipShape(Circle())
            }

            Button {
                viewModel.showManualEntry = true
            } label: {
                Image(systemName: "keyboard")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(DesignColors.primaryText)
                    .frame(width: 44, height: 44)
                    .background(DesignColors.lightText)
                    .clipShape(Circle())
            }
        }
    }

    // MARK: - Unsupported View

    private var unsupportedView: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 20) {
                Image(systemName: "camera.fill.badge.ellipsis")
                    .font(.system(size: 72))
                    .foregroundStyle(DesignColors.primaryText)

                Text(String(localized: "scan.unsupported.title", defaultValue: "Scanner Not Available"))
                    .font(.custom("Inter-SemiBold", size: 20))
                    .tracking(-0.408)
                    .foregroundStyle(DesignColors.primaryText)

                Text(String(localized: "scan.unsupported.message", defaultValue: "This device doesn't support barcode scanning. You can still import images from your photo library."))
                    .font(.custom("Inter-Regular", size: 14))
                    .tracking(-0.408)
                    .foregroundStyle(DesignColors.secondaryText)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            PhotosPicker(selection: $viewModel.selectedPhoto, matching: .images) {
                HStack(spacing: 8) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 16, weight: .medium))
                    Text(String(localized: "scan.unsupported.import_from_photos", defaultValue: "Import from Photos"))
                        .font(.custom("Inter-Medium", size: 16))
                        .tracking(-0.408)
                }
                .foregroundStyle(DesignColors.primaryButtonText)
                .frame(maxWidth: .infinity)
                .frame(height: 51)
                .background(DesignColors.primaryActionBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(DesignColors.background)
    }
}

// MARK: - QR Frame Overlay

struct QRFrameOverlay: View {
    @State private var isAnimating = false
    private let frameSize: CGFloat = 230
    private let cornerLength: CGFloat = 32
    private let lineWidth: CGFloat = 3

    var body: some View {
        ZStack {
            Color(red: 0x1E/255, green: 0x1E/255, blue: 0x1E/255)
                .opacity(0.72)
                .reverseMask {
                    RoundedRectangle(cornerRadius: 4)
                        .frame(width: frameSize, height: frameSize)
                }

            // Semi-transparent fill inside the frame
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.white.opacity(0.2))
                .frame(width: frameSize, height: frameSize)

            // Corner brackets
            ZStack {
                CornerShape(corner: .topLeft, length: cornerLength, lineWidth: lineWidth)
                CornerShape(corner: .topRight, length: cornerLength, lineWidth: lineWidth)
                CornerShape(corner: .bottomLeft, length: cornerLength, lineWidth: lineWidth)
                CornerShape(corner: .bottomRight, length: cornerLength, lineWidth: lineWidth)
            }
            .frame(width: frameSize + 8, height: frameSize + 8)
            .foregroundStyle(.white)
            .opacity(isAnimating ? 1.0 : 0.7)
            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
            .onAppear { isAnimating = true }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Barcode Frame Overlay

struct BarcodeFrameOverlay: View {
    @State private var isAnimating = false
    private let frameWidth: CGFloat = 342
    private let frameHeight: CGFloat = 150
    private let cornerLength: CGFloat = 32
    private let lineWidth: CGFloat = 3

    var body: some View {
        ZStack {
            Color(red: 0x1E/255, green: 0x1E/255, blue: 0x1E/255)
                .opacity(0.72)
                .reverseMask {
                    RoundedRectangle(cornerRadius: 4)
                        .frame(width: frameWidth, height: frameHeight)
                }

            RoundedRectangle(cornerRadius: 4)
                .fill(Color.white.opacity(0.2))
                .frame(width: frameWidth, height: frameHeight)

            ZStack {
                CornerShape(corner: .topLeft, length: cornerLength, lineWidth: lineWidth)
                CornerShape(corner: .topRight, length: cornerLength, lineWidth: lineWidth)
                CornerShape(corner: .bottomLeft, length: cornerLength, lineWidth: lineWidth)
                CornerShape(corner: .bottomRight, length: cornerLength, lineWidth: lineWidth)
            }
            .frame(width: frameWidth + 8, height: frameHeight + 8)
            .foregroundStyle(.white)
            .opacity(isAnimating ? 1.0 : 0.7)
            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
            .onAppear { isAnimating = true }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Corner Shape

struct CornerShape: View {
    enum Corner {
        case topLeft, topRight, bottomLeft, bottomRight
    }

    let corner: Corner
    let length: CGFloat
    var lineWidth: CGFloat = 3

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

// MARK: - Focus Indicator

struct FocusIndicatorView: View {
    let point: CGPoint
    @State private var scale: CGFloat = 1.3
    @State private var opacity: Double = 1.0

    var body: some View {
        GeometryReader { _ in
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.yellow, lineWidth: 2)
                .frame(width: 70, height: 70)
                .scaleEffect(scale)
                .opacity(opacity)
                .position(x: point.x, y: point.y)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        scale = 1.0
                    }
                    withAnimation(.easeOut(duration: 0.3).delay(0.8)) {
                        opacity = 0
                    }
                }
        }
        .ignoresSafeArea()
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
                    Text(mode.title)
                        .font(.custom("Inter-Regular", size: 14))
                        .tracking(-0.408)
                        .foregroundStyle(DesignColors.primaryText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background {
                            if selectedMode == mode {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(DesignColors.primaryButtonText)
                                    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 0)
                                    .matchedGeometryEffect(id: "tab", in: animation)
                            }
                        }
                }
            }
        }
        .padding(4)
        .frame(width: 302)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(DesignColors.lightText)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(DesignColors.stroke, lineWidth: 1)
                )
        )
    }
}

// MARK: - Manual Barcode Entry

struct ManualBarcodeEntryView: View {
    @ObservedObject var viewModel: ScanViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isInputFocused: Bool

    private let barcodeTypes = [
        ("ean13", "EAN-13"),
        ("ean8", "EAN-8"),
        ("upce", "UPC-E"),
        ("code128", "Code 128"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            ZStack {
                Text(String(localized: "scan.manual_entry.title", defaultValue: "Enter Barcode"))
                    .font(.custom("Inter-SemiBold", size: 20))
                    .tracking(-0.408)
                    .foregroundStyle(DesignColors.primaryText)

                HStack {
                    Spacer()

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(DesignColors.primaryText)
                            .frame(width: 44, height: 44)
                            .background(DesignColors.cardBackground)
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 8)

            // Barcode type segmented control
            HStack(spacing: 0) {
                ForEach(barcodeTypes, id: \.0) { value, label in
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            viewModel.manualBarcodeType = value
                        }
                    } label: {
                        Text(label)
                            .font(.custom("Inter-Regular", size: 14))
                            .tracking(-0.408)
                            .foregroundStyle(DesignColors.primaryText)
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                            .background(
                                viewModel.manualBarcodeType == value
                                    ? RoundedRectangle(cornerRadius: 10)
                                        .fill(DesignColors.primaryButtonText)
                                        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 0)
                                    : nil
                            )
                    }
                }
            }
            .padding(4)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(DesignColors.lightText)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(DesignColors.stroke, lineWidth: 1)
                    )
            )
            .padding(.horizontal, 16)
            .padding(.top, 16)

            // Input field
            TextField(String(localized: "scan.manual_entry.placeholder", defaultValue: "Enter barcode number"), text: $viewModel.manualBarcodeText)
                .font(.custom("Inter-Regular", size: 16))
                .tracking(-0.408)
                .keyboardType(.numberPad)
                .textContentType(.none)
                .autocorrectionDisabled()
                .focused($isInputFocused)
                .padding(20)
                .frame(height: 58)
                .background(DesignColors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isInputFocused ? DesignColors.primaryText : DesignColors.stroke, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 16)
                .padding(.top, 24)

            // Search button
            Button {
                viewModel.submitManualBarcode()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16, weight: .medium))
                    Text(String(localized: "scan.manual_entry.search", defaultValue: "Search"))
                        .font(.custom("Inter-Medium", size: 16))
                        .tracking(-0.408)
                }
                .foregroundStyle(DesignColors.primaryButtonText)
                .frame(maxWidth: .infinity)
                .frame(height: 51)
                .background(DesignColors.primaryText)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(viewModel.manualBarcodeText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(viewModel.manualBarcodeText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
            .padding(.horizontal, 16)
            .padding(.top, 24)

            Spacer()
        }
        .background(DesignColors.background)
    }
}

struct ScanView_Previews: PreviewProvider {
    static var previews: some View {
        ScanView(showSettings: .constant(false), viewModel: ScanViewModel(), isActiveTab: true)
    }
}
