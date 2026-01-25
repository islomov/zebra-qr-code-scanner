//
//  BarcodePreviewView.swift
//  ZebraCodeScanner
//
//  Created by Sardor Islomov on 25/01/26.
//

import SwiftUI

struct BarcodePreviewView: View {
    let type: BarcodeType
    @ObservedObject var viewModel: GenerateViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showSaveSuccess = false
    @State private var showSaveError = false
    @State private var hasSavedToHistory = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Barcode Image
            if let image = viewModel.generatedImage {
                Image(uiImage: image)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 120)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 30)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
            }

            // Content Preview
            Text(viewModel.generatedContent)
                .font(.title3.monospaced())
                .foregroundStyle(.primary)

            // Type Badge
            HStack {
                Image(systemName: type.icon)
                Text(type.title)
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .clipShape(Capsule())

            Spacer()

            // Action Buttons
            VStack(spacing: 12) {
                // Share Button
                if let image = viewModel.generatedImage {
                    ShareLink(
                        item: Image(uiImage: image),
                        preview: SharePreview("Barcode", image: Image(uiImage: image))
                    ) {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }

                // Save to Photos Button
                Button {
                    saveToPhotos()
                } label: {
                    Label("Save to Photos", systemImage: "photo.badge.arrow.down")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5))
                        .foregroundStyle(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                // Copy to Clipboard Button
                Button {
                    copyToClipboard()
                } label: {
                    Label("Copy Image", systemImage: "doc.on.doc")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5))
                        .foregroundStyle(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .navigationTitle("Barcode")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    viewModel.reset()
                    dismiss()
                }
            }
        }
        .onAppear {
            saveToHistory()
        }
        .alert("Saved!", isPresented: $showSaveSuccess) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Barcode saved to your photo library.")
        }
        .alert("Error", isPresented: $showSaveError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Failed to save barcode. Please check photo library permissions.")
        }
    }

    private func saveToHistory() {
        guard !hasSavedToHistory else { return }
        hasSavedToHistory = true
        viewModel.saveBarcodeToHistory(type: type)
    }

    private func saveToPhotos() {
        guard let image = viewModel.generatedImage else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        showSaveSuccess = true
    }

    private func copyToClipboard() {
        guard let image = viewModel.generatedImage else { return }
        UIPasteboard.general.image = image
    }
}

#Preview {
    NavigationStack {
        BarcodePreviewView(type: .code128, viewModel: {
            let vm = GenerateViewModel()
            vm.barcodeContent = "ABC123"
            vm.generateBarcode(for: .code128)
            return vm
        }())
    }
}
