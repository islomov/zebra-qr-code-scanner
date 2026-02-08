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
    @State private var showDeleteConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Custom Navigation Header
                navigationHeader

                // Section header
                sectionHeader

                // Barcode image
                barcodeImageSection
                    .padding(.top, 16)

                // Content preview
                Text(viewModel.generatedContent)
                    .font(.custom("Inter-Medium", size: 16))
                    .tracking(-0.408)
                    .foregroundStyle(DesignColors.primaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 16)
                    .padding(.horizontal, 16)

                // Action buttons
                actionButtons
                    .padding(.top, 24)
                    .padding(.bottom, 24)
            }
        }
        .background(DesignColors.background)
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            saveToHistory()
        }
        .alert(String(localized: "common.alert.saved", defaultValue: "Saved!"), isPresented: $showSaveSuccess) {
            Button(String(localized: "common.ok", defaultValue: "OK"), role: .cancel) {}
        } message: {
            Text(String(localized: "preview.barcode_saved_message", defaultValue: "Barcode saved to your photo library."))
        }
        .alert(String(localized: "common.error", defaultValue: "Error"), isPresented: $showSaveError) {
            Button(String(localized: "common.ok", defaultValue: "OK"), role: .cancel) {}
        } message: {
            Text(String(localized: "preview.barcode_save_error", defaultValue: "Failed to save barcode. Please check photo library permissions."))
        }
        .alert(String(localized: "preview.delete_barcode_title", defaultValue: "Delete Barcode?"), isPresented: $showDeleteConfirmation) {
            Button(String(localized: "common.delete", defaultValue: "Delete"), role: .destructive) {
                viewModel.deleteCurrentCode()
                viewModel.reset()
                dismiss()
            }
            Button(String(localized: "common.cancel", defaultValue: "Cancel"), role: .cancel) {}
        } message: {
            Text(String(localized: "preview.delete_barcode_message", defaultValue: "This will remove the barcode from your history."))
        }
    }

    // MARK: - Navigation Header

    private var navigationHeader: some View {
        ZStack {
            Text(String(localized: "common.barcode", defaultValue: "Barcode"))
                .font(.custom("Inter-SemiBold", size: 20))
                .tracking(-0.408)
                .foregroundStyle(DesignColors.primaryText)

            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(DesignColors.primaryText)
                        .frame(width: 44, height: 44)
                        .background(DesignColors.cardBackground)
                        .clipShape(Circle())
                }

                Spacer()

                Button {
                    viewModel.reset()
                    dismiss()
                } label: {
                    Text(String(localized: "common.done", defaultValue: "Done"))
                        .font(.custom("Inter-Medium", size: 14))
                        .tracking(-0.408)
                        .foregroundStyle(DesignColors.primaryText)
                        .frame(width: 66, height: 44)
                        .background(DesignColors.cardBackground)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 16)
    }

    // MARK: - Section Header

    private var sectionHeader: some View {
        HStack(spacing: 8) {
            Image(sectionIconName)
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundStyle(DesignColors.primaryText)

            Text(type.title)
                .font(.custom("Inter-SemiBold", size: 20))
                .tracking(-0.408)
                .foregroundStyle(DesignColors.primaryText)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    private var sectionIconName: String {
        switch type {
        case .aztec: return "icon-aztec"
        case .pdf417: return "icon-pdf417"
        default: return "icon-barcode1d"
        }
    }

    // MARK: - Barcode Image

    private var barcodeImageSection: some View {
        Group {
            if let image = viewModel.generatedImage {
                Image(uiImage: image)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 120)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 30)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // Share
                if let image = viewModel.generatedImage {
                    ShareLink(
                        item: Image(uiImage: image),
                        preview: SharePreview(String(localized: "common.barcode", defaultValue: "Barcode"), image: Image(uiImage: image))
                    ) {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 16, weight: .medium))
                            Text(String(localized: "common.share", defaultValue: "Share"))
                                .font(.custom("Inter-Medium", size: 16))
                                .tracking(-0.408)
                        }
                        .foregroundStyle(DesignColors.primaryButtonText)
                        .padding(16)
                        .frame(height: 51)
                        .background(DesignColors.primaryText)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }

                // Save to Photos
                Button { saveToPhotos() } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.down.to.line")
                            .font(.system(size: 16, weight: .medium))
                        Text(String(localized: "common.save_to_photos", defaultValue: "Save to Photos"))
                            .font(.custom("Inter-Medium", size: 16))
                            .tracking(-0.408)
                    }
                    .foregroundStyle(DesignColors.primaryText)
                    .padding(16)
                    .frame(height: 51)
                    .background(DesignColors.lightText)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)

                // Copy Image
                Button { copyToClipboard() } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 16, weight: .medium))
                        Text(String(localized: "common.copy_image", defaultValue: "Copy Image"))
                            .font(.custom("Inter-Medium", size: 16))
                            .tracking(-0.408)
                    }
                    .foregroundStyle(DesignColors.primaryText)
                    .padding(16)
                    .frame(height: 51)
                    .background(DesignColors.lightText)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)

                // Delete
                Button { showDeleteConfirmation = true } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "trash")
                            .font(.system(size: 16, weight: .medium))
                        Text(String(localized: "common.delete", defaultValue: "Delete"))
                            .font(.custom("Inter-Medium", size: 16))
                            .tracking(-0.408)
                    }
                    .foregroundStyle(Color(red: 0xE8/255, green: 0x10/255, blue: 0x10/255))
                    .padding(16)
                    .frame(height: 51)
                    .background(Color(red: 0xE8/255, green: 0x10/255, blue: 0x10/255).opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Actions

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

struct BarcodePreviewView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            BarcodePreviewView(type: .code128, viewModel: {
                let vm = GenerateViewModel()
                vm.barcodeContent = "ABC123"
                vm.generateBarcode(for: .code128)
                return vm
            }())
        }
    }
}
