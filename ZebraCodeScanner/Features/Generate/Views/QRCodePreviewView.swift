//
//  QRCodePreviewView.swift
//  ZebraCodeScanner
//
//  Created by Sardor Islomov on 25/01/26.
//

import SwiftUI
import PhotosUI

struct ColorPickerRow: View {
    let title: String
    @Binding var selectedColor: Color
    let borderColor: Color
    let onSelect: () -> Void

    private let presetColors: [Color] = [
        .white, .black, Color(.systemGray5),
        .red, .orange, .yellow, .green, .blue, .purple, .pink
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(presetColors, id: \.self) { color in
                        Circle()
                            .fill(color)
                            .frame(width: 36, height: 36)
                            .overlay(
                                Circle()
                                    .strokeBorder(color == borderColor ? Color.gray.opacity(0.3) : Color.clear, lineWidth: 1)
                            )
                            .overlay(
                                Circle()
                                    .strokeBorder(Color.accentColor, lineWidth: selectedColor == color ? 3 : 0)
                                    .frame(width: 42, height: 42)
                            )
                            .onTapGesture {
                                selectedColor = color
                                onSelect()
                            }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(.horizontal)
    }
}

struct QRCodePreviewView: View {
    let type: QRCodeContentType
    @ObservedObject var viewModel: GenerateViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showSaveSuccess = false
    @State private var showSaveError = false
    @State private var hasSavedToHistory = false
    @State private var showDeleteConfirmation = false
    @State private var selectedPhotoItem: PhotosPickerItem?

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                qrImageSection
                typeBadge
                ColorPickerRow(title: "Background Color", selectedColor: $viewModel.qrBackgroundColor, borderColor: .white) {
                    viewModel.regenerateStyledQRCode()
                }
                ColorPickerRow(title: "QR Code Color", selectedColor: $viewModel.qrForegroundColor, borderColor: .black) {
                    viewModel.regenerateStyledQRCode()
                }
                logoSection
                actionButtons
            }
            .padding(.top)
        }
        .navigationTitle("QR Code")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    viewModel.reset()
                    dismiss()
                }
            }
        }
        .onAppear { saveToHistory() }
        .onChange(of: selectedPhotoItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    viewModel.qrCenterLogo = image
                    viewModel.regenerateStyledQRCode()
                }
            }
        }
        .alert("Saved!", isPresented: $showSaveSuccess) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("QR code saved to your photo library.")
        }
        .alert("Error", isPresented: $showSaveError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Failed to save QR code. Please check photo library permissions.")
        }
        .alert("Delete QR Code?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                viewModel.deleteCurrentCode()
                viewModel.reset()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will remove the QR code from your history.")
        }
    }

    private var qrImageSection: some View {
        Group {
            if let image = viewModel.generatedImage {
                Image(uiImage: image)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .padding(20)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
            }
        }
    }

    private var typeBadge: some View {
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
    }

    private var logoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Center Logo")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                if let logo = viewModel.qrCenterLogo {
                    Image(uiImage: logo)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    Button("Remove") {
                        viewModel.qrCenterLogo = nil
                        viewModel.regenerateStyledQRCode()
                    }
                    .font(.subheadline)
                    .foregroundStyle(.red)
                }

                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    Label(viewModel.qrCenterLogo == nil ? "Add Logo" : "Change", systemImage: "photo")
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray5))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding(.horizontal)
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            if let image = viewModel.generatedImage {
                ShareLink(
                    item: Image(uiImage: image),
                    preview: SharePreview("QR Code", image: Image(uiImage: image))
                ) {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }

            Button { saveToPhotos() } label: {
                Label("Save to Photos", systemImage: "photo.badge.arrow.down")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray5))
                    .foregroundStyle(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Button { copyToClipboard() } label: {
                Label("Copy Image", systemImage: "doc.on.doc")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray5))
                    .foregroundStyle(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Button(role: .destructive) { showDeleteConfirmation = true } label: {
                Label("Delete", systemImage: "trash")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .foregroundStyle(.red)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
    }

    private func saveToHistory() {
        guard !hasSavedToHistory else { return }
        hasSavedToHistory = true
        viewModel.saveToHistory(type: type)
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
        QRCodePreviewView(type: .text, viewModel: {
            let vm = GenerateViewModel()
            vm.text = "Hello World"
            vm.generateQRCode(for: .text)
            return vm
        }())
    }
}
