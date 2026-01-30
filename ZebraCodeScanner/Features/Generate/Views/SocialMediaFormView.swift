//
//  SocialMediaFormView.swift
//  ZebraCodeScanner
//
//  Created by Sardor Islomov on 30/01/26.
//

import SwiftUI

struct SocialMediaFormView: View {
    let type: SocialMediaType
    @ObservedObject var viewModel: GenerateViewModel
    @State private var showPreview = false

    var body: some View {
        Form {
            Section {
                HStack(spacing: 12) {
                    Image(systemName: type.icon)
                        .font(.system(size: 28))
                        .foregroundStyle(.purple)
                    VStack(alignment: .leading) {
                        Text(type.title)
                            .font(.headline)
                        Text(type.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }

            Section("Username") {
                TextField(type.placeholder, text: $viewModel.socialMediaUsername)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
            }

            if !viewModel.socialMediaUsername.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Section("Profile URL") {
                    Text(type.baseURL + viewModel.socialMediaUsername.trimmingCharacters(in: .whitespacesAndNewlines))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                Button {
                    viewModel.generateSocialMediaQRCode(for: type)
                    showPreview = true
                } label: {
                    HStack {
                        Spacer()
                        Label("Generate QR Code", systemImage: "qrcode")
                            .font(.headline)
                        Spacer()
                    }
                }
                .disabled(!viewModel.isSocialMediaValid())
            }
        }
        .navigationTitle(type.title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showPreview) {
            SocialMediaPreviewView(type: type, viewModel: viewModel)
        }
    }
}

struct SocialMediaPreviewView: View {
    let type: SocialMediaType
    @ObservedObject var viewModel: GenerateViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showSaveSuccess = false
    @State private var showSaveError = false
    @State private var hasSavedToHistory = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

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

            VStack(spacing: 12) {
                if let image = viewModel.generatedImage {
                    ShareLink(
                        item: Image(uiImage: image),
                        preview: SharePreview("\(type.title) QR Code", image: Image(uiImage: image))
                    ) {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }

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
        .onAppear {
            saveToHistory()
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
    }

    private func saveToHistory() {
        guard !hasSavedToHistory else { return }
        hasSavedToHistory = true
        viewModel.saveSocialMediaToHistory(type: type)
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
        SocialMediaFormView(type: .instagram, viewModel: GenerateViewModel())
    }
}
