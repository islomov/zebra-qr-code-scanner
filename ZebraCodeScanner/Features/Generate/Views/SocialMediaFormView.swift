//
//  SocialMediaFormView.swift
//  ZebraCodeScanner
//
//  Created by Sardor Islomov on 30/01/26.
//

import SwiftUI
import PhotosUI

struct SocialMediaFormView: View {
    let type: SocialMediaType
    @ObservedObject var viewModel: GenerateViewModel
    @State private var showPreview = false
    @State private var showValidationError = false
    @FocusState private var isFieldFocused: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Custom Navigation Header
                navigationHeader

                // Section header + input
                VStack(alignment: .leading, spacing: 8) {
                    sectionHeader
                    usernameField
                }

                // Generate button
                generateButton
                    .padding(.top, 24)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .background(DesignColors.background)
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showPreview) {
            SocialMediaPreviewView(type: type, viewModel: viewModel)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isFieldFocused = true
            }
        }
        .onDisappear {
            isFieldFocused = false
        }
    }

    // MARK: - Navigation Header

    private var navigationHeader: some View {
        ZStack {
            Text(String(localized: "social_media_form.title", defaultValue: "Social media"))
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
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 16)
    }

    // MARK: - Section Header

    private var sectionHeader: some View {
        HStack(spacing: 8) {
            Image(iconName)
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

    private var iconName: String {
        switch type {
        case .facebook: return "icon-facebook"
        case .instagram: return "icon-instagram"
        case .x: return "icon-twitter-x"
        case .reddit: return "icon-reddit"
        case .tiktok: return "icon-tiktok"
        case .snapchat: return "icon-snapchat"
        case .threads: return "icon-threads"
        case .youtube: return "icon-youtube"
        }
    }

    // MARK: - Username Field

    private var usernameField: some View {
        let hasError = showValidationError && viewModel.socialMediaUsername.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let borderColor: Color = hasError
            ? Color(red: 0xFF/255, green: 0x3B/255, blue: 0x30/255)
            : (isFieldFocused ? DesignColors.primaryText : DesignColors.stroke)

        return TextField("", text: $viewModel.socialMediaUsername, prompt: Text(placeholderText)
            .foregroundColor(DesignColors.secondaryText))
            .font(.custom("Inter-Regular", size: 14))
            .tracking(-0.408)
            .foregroundStyle(DesignColors.primaryText)
            .focused($isFieldFocused)
            .autocapitalization(.none)
            .autocorrectionDisabled()
            .padding(20)
            .frame(height: 58)
            .background(DesignColors.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(borderColor, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 16)
    }

    private var placeholderText: String {
        switch type {
        case .facebook: return String(localized: "social_media_form.placeholder.username_or_page", defaultValue: "Username or page name")
        default: return String(localized: "social_media_form.placeholder.username", defaultValue: "Username")
        }
    }

    // MARK: - Generate Button

    private var generateButton: some View {
        Button {
            if viewModel.isSocialMediaValid() {
                showValidationError = false
                viewModel.generateSocialMediaQRCode(for: type)
                showPreview = true
            } else {
                showValidationError = true
            }
        } label: {
            HStack(spacing: 8) {
                Image("icon-qr")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundStyle(DesignColors.primaryButtonText)

                Text(String(localized: "qr_form.button.generate", defaultValue: "Generate QR Code"))
                    .font(.custom("Inter-Medium", size: 16))
                    .tracking(-0.408)
                    .foregroundStyle(DesignColors.primaryButtonText)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 51)
            .background(DesignColors.primaryText)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
    }
}

// MARK: - Social Media Preview View

struct SocialMediaPreviewView: View {
    let type: SocialMediaType
    @ObservedObject var viewModel: GenerateViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showSaveSuccess = false
    @State private var showSaveError = false
    @State private var hasSavedToHistory = false
    @State private var showDeleteConfirmation = false
    @State private var selectedPhotoItem: PhotosPickerItem?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Custom Navigation Header
                navigationHeader

                // Section header
                sectionHeader

                // QR image + Add Logo
                qrImageSection
                    .padding(.top, 16)

                // Color pickers
                VStack(spacing: 12) {
                    ColorPickerRow(
                        title: String(localized: "preview.background_color.title", defaultValue: "Background color"),
                        subtitle: String(localized: "preview.background_color.subtitle", defaultValue: "Choose a preferred background color"),
                        selectedColor: $viewModel.qrBackgroundColor,
                        borderColor: .white,
                        disabledColor: viewModel.qrForegroundColor
                    ) {
                        viewModel.regenerateStyledQRCode()
                    }

                    ColorPickerRow(
                        title: String(localized: "preview.qr_code_color.title", defaultValue: "QR Code Color"),
                        subtitle: String(localized: "preview.qr_code_color.subtitle", defaultValue: "Choose a preferred QR code color"),
                        selectedColor: $viewModel.qrForegroundColor,
                        borderColor: .black,
                        disabledColor: viewModel.qrBackgroundColor
                    ) {
                        viewModel.regenerateStyledQRCode()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)

                // Shape pickers
                VStack(spacing: 12) {
                    StylePickerRow(
                        title: String(localized: "preview.finder_shape.title", defaultValue: "Finder Shape"),
                        subtitle: String(localized: "preview.finder_shape.subtitle", defaultValue: "Shape of the 3 corner squares"),
                        selectedStyle: $viewModel.qrFinderStyle
                    ) {
                        viewModel.regenerateStyledQRCode()
                    }

                    StylePickerRow(
                        title: String(localized: "preview.dot_shape.title", defaultValue: "Dot Shape"),
                        subtitle: String(localized: "preview.dot_shape.subtitle", defaultValue: "Shape of the inner data pattern"),
                        selectedStyle: $viewModel.qrModuleStyle
                    ) {
                        viewModel.regenerateStyledQRCode()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)

                // Center icon picker
                CenterIconPickerRow(
                    title: String(localized: "preview.center_icon.title", defaultValue: "Center Icon"),
                    subtitle: String(localized: "preview.center_icon.subtitle", defaultValue: "Add an icon to the center of QR code"),
                    selectedIcon: $viewModel.qrCenterIcon
                ) { icon in
                    viewModel.selectCenterIcon(icon)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)

                // Icon color pickers (only when a center icon is selected)
                if viewModel.qrCenterIcon != nil {
                    VStack(spacing: 12) {
                        ColorPickerRow(
                            title: String(localized: "preview.icon_background_color.title", defaultValue: "Icon Background"),
                            subtitle: String(localized: "preview.icon_background_color.subtitle", defaultValue: "Choose icon background color"),
                            selectedColor: $viewModel.iconBackgroundColor,
                            borderColor: .white
                        ) {
                            viewModel.regenerateStyledQRCode()
                        }

                        ColorPickerRow(
                            title: String(localized: "preview.icon_color.title", defaultValue: "Icon Color"),
                            subtitle: String(localized: "preview.icon_color.subtitle", defaultValue: "Choose icon color"),
                            selectedColor: $viewModel.iconTintColor,
                            borderColor: .black
                        ) {
                            viewModel.regenerateStyledQRCode()
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                }

                // Action buttons
                actionButtons
                    .padding(.top, 24)
                    .padding(.bottom, 24)
            }
        }
        .background(DesignColors.background)
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .onAppear { saveToHistory() }
        .onChange(of: selectedPhotoItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    viewModel.qrCenterIcon = nil
                    viewModel.qrCenterLogo = image
                    viewModel.regenerateStyledQRCode()
                }
            }
        }
        .alert(String(localized: "common.alert.saved", defaultValue: "Saved!"), isPresented: $showSaveSuccess) {
            Button(String(localized: "common.ok", defaultValue: "OK"), role: .cancel) {}
        } message: {
            Text(String(localized: "preview.qr_saved_message", defaultValue: "QR code saved to your photo library."))
        }
        .alert(String(localized: "common.error", defaultValue: "Error"), isPresented: $showSaveError) {
            Button(String(localized: "common.ok", defaultValue: "OK"), role: .cancel) {}
        } message: {
            Text(String(localized: "preview.qr_save_error", defaultValue: "Failed to save QR code. Please check photo library permissions."))
        }
        .alert(String(localized: "preview.delete_qr_title", defaultValue: "Delete QR Code?"), isPresented: $showDeleteConfirmation) {
            Button(String(localized: "common.delete", defaultValue: "Delete"), role: .destructive) {
                viewModel.deleteCurrentCode()
                viewModel.reset()
                dismiss()
            }
            Button(String(localized: "common.cancel", defaultValue: "Cancel"), role: .cancel) {}
        } message: {
            Text(String(localized: "preview.delete_qr_message", defaultValue: "This will remove the QR code from your history."))
        }
    }

    // MARK: - Navigation Header

    private var navigationHeader: some View {
        ZStack {
            Text(String(localized: "common.qr_code", defaultValue: "QR Code"))
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
                    if viewModel.isStyleDirty {
                        viewModel.updateSavedImage()
                    }
                    viewModel.reset()
                    dismiss()
                } label: {
                    Text(viewModel.isStyleDirty
                         ? String(localized: "common.save", defaultValue: "Save")
                         : String(localized: "common.done", defaultValue: "Done"))
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
            Image(iconName)
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

    private var iconName: String {
        switch type {
        case .facebook: return "icon-facebook"
        case .instagram: return "icon-instagram"
        case .x: return "icon-twitter-x"
        case .reddit: return "icon-reddit"
        case .tiktok: return "icon-tiktok"
        case .snapchat: return "icon-snapchat"
        case .threads: return "icon-threads"
        case .youtube: return "icon-youtube"
        }
    }

    // MARK: - QR Image + Add Logo

    private var qrImageSection: some View {
        HStack(alignment: .center, spacing: 16) {
            if let image = viewModel.generatedImage {
                Image(uiImage: image)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)
                    .padding(20)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
            }

            addLogoSection
        }
        .padding(.horizontal, 16)
    }

    private var addLogoSection: some View {
        VStack(spacing: 8) {
            if let logo = viewModel.qrCenterLogo {
                Image(uiImage: logo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    Text(String(localized: "preview.logo.change", defaultValue: "Change"))
                        .font(.custom("Inter-Medium", size: 14))
                        .tracking(-0.408)
                        .foregroundStyle(Color(red: 0x01/255, green: 0x87/255, blue: 0xFF/255))
                }

                Button {
                    viewModel.qrCenterIcon = nil
                    viewModel.qrCenterLogo = nil
                    viewModel.regenerateStyledQRCode()
                } label: {
                    Text(String(localized: "preview.logo.remove", defaultValue: "Remove"))
                        .font(.custom("Inter-Medium", size: 14))
                        .tracking(-0.408)
                        .foregroundStyle(Color(red: 0xE8/255, green: 0x10/255, blue: 0x10/255))
                }
            } else {
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    VStack(spacing: 8) {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 24))
                            .foregroundStyle(Color(red: 0x01/255, green: 0x87/255, blue: 0xFF/255))

                        Text(String(localized: "preview.logo.add", defaultValue: "Add Logo"))
                            .font(.custom("Inter-Medium", size: 14))
                            .tracking(-0.408)
                            .foregroundStyle(Color(red: 0x01/255, green: 0x87/255, blue: 0xFF/255))
                    }
                }
            }
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // Share
                if let image = viewModel.generatedImage {
                    ShareLink(
                        item: Image(uiImage: image),
                        preview: SharePreview(String(localized: "common.qr_code", defaultValue: "QR Code"), image: Image(uiImage: image))
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

struct SocialMediaFormView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SocialMediaFormView(type: .instagram, viewModel: GenerateViewModel())
        }
    }
}
