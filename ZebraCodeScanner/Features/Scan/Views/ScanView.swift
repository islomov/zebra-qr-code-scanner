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
    @StateObject private var viewModel = ScanViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isSupported {
                    scannerView
                } else {
                    unsupportedView
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
            .onChange(of: viewModel.selectedPhoto) { _, _ in
                viewModel.processSelectedPhoto()
            }
            .sheet(isPresented: $viewModel.showResult) {
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
            if viewModel.isScanning {
                DataScannerRepresentable(
                    recognizedDataTypes: viewModel.recognizedDataTypes,
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

                // Overlay controls
                VStack {
                    Spacer()

                    HStack(spacing: 40) {
                        // Torch toggle
                        Button {
                            viewModel.toggleTorch()
                        } label: {
                            Image(systemName: viewModel.isTorchOn ? "flashlight.on.fill" : "flashlight.off.fill")
                                .font(.title2)
                                .foregroundStyle(.white)
                                .padding()
                                .background(Circle().fill(.ultraThinMaterial))
                        }
                    }
                    .padding(.bottom, 50)
                }
            } else {
                // Start scanning view
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
        .onAppear {
            viewModel.startScanning()
        }
        .onDisappear {
            viewModel.stopScanning()
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

#Preview {
    ScanView(showSettings: .constant(false))
}
