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
    var subtitle: String = "Choose a preferred color"
    @Binding var selectedColor: Color
    let borderColor: Color
    var disabledColor: Color? = nil
    let onSelect: () -> Void

    private let presetColors: [Color] = [
        .white, .black, Color(.systemGray3),
        .red, .orange, .yellow, .green, .blue, .purple, .pink
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.custom("Inter-Medium", size: 16))
                    .tracking(-0.408)
                    .foregroundStyle(DesignColors.primaryText)

                Text(subtitle)
                    .font(.custom("Inter-Regular", size: 12))
                    .tracking(-0.408)
                    .foregroundStyle(DesignColors.secondaryText)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(presetColors, id: \.self) { color in
                        let isDisabled = disabledColor == color
                        Button {
                            selectedColor = color
                            onSelect()
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(color)
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                color == borderColor ? DesignColors.stroke : Color.clear,
                                                lineWidth: 1
                                            )
                                    )
                                    .opacity(isDisabled ? 0.3 : 1.0)

                                if selectedColor == color {
                                    Circle()
                                        .stroke(DesignColors.primaryText, lineWidth: 2)
                                        .frame(width: 28, height: 28)
                                }

                                if isDisabled {
                                    Image(systemName: "line.diagonal")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(DesignColors.secondaryText)
                                }
                            }
                            .frame(width: 48, height: 32)
                        }
                        .buttonStyle(.plain)
                        .disabled(isDisabled)
                    }
                }
                .padding(3)
            }
            .background(DesignColors.lightText)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(16)
        .background(DesignColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct StylePickerRow: View {
    let title: String
    var subtitle: String = ""
    @Binding var selectedStyle: QRModuleStyle
    let onSelect: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.custom("Inter-Medium", size: 16))
                    .tracking(-0.408)
                    .foregroundStyle(DesignColors.primaryText)

                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.custom("Inter-Regular", size: 12))
                        .tracking(-0.408)
                        .foregroundStyle(DesignColors.secondaryText)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(QRModuleStyle.allCases) { style in
                        Button {
                            selectedStyle = style
                            onSelect()
                        } label: {
                            VStack(spacing: 4) {
                                ZStack {
                                    Image(systemName: style.icon)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(DesignColors.primaryText)
                                        .frame(width: 32, height: 32)

                                    if selectedStyle == style {
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(DesignColors.primaryText, lineWidth: 2)
                                            .frame(width: 36, height: 36)
                                    }
                                }

                                Text(style.title)
                                    .font(.custom("Inter-Regular", size: 11))
                                    .tracking(-0.408)
                                    .foregroundStyle(DesignColors.secondaryText)
                            }
                            .frame(width: 56, height: 56)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(3)
            }
            .background(DesignColors.lightText)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(16)
        .background(DesignColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct CenterIconPickerRow: View {
    let title: String
    var subtitle: String = ""
    @Binding var selectedIcon: QRCenterIcon?
    let onSelect: (QRCenterIcon?) -> Void

    private let columns = 5

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.custom("Inter-Medium", size: 16))
                    .tracking(-0.408)
                    .foregroundStyle(DesignColors.primaryText)

                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.custom("Inter-Regular", size: 12))
                        .tracking(-0.408)
                        .foregroundStyle(DesignColors.secondaryText)
                }
            }

            let allItems: [QRCenterIcon?] = [nil] + QRCenterIcon.allCases.map { $0 as QRCenterIcon? }
            let indices = Array(stride(from: 0, to: allItems.count, by: columns))

            VStack(spacing: 6) {
                ForEach(indices, id: \.self) { index in
                    HStack(spacing: 6) {
                        ForEach(0..<columns, id: \.self) { col in
                            let itemIndex = index + col
                            if itemIndex < allItems.count {
                                let item = allItems[itemIndex]
                                iconChip(for: item)
                            } else {
                                Color.clear.frame(maxWidth: .infinity, minHeight: 36)
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(DesignColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    @ViewBuilder
    private func iconChip(for icon: QRCenterIcon?) -> some View {
        let isSelected = selectedIcon == icon
        Button {
            selectedIcon = icon
            onSelect(icon)
        } label: {
            ZStack {
                if let icon = icon {
                    Image(icon.assetName)
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundStyle(DesignColors.primaryText)
                } else {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(DesignColors.secondaryText)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 36)
            .background(DesignColors.lightText)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? DesignColors.primaryText : Color.clear, lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
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
        case .text: return "icon-text"
        case .url: return "icon-link"
        case .phone: return "icon-phone"
        case .email: return "icon-email"
        case .wifi: return "icon-wifi"
        case .vcard: return "icon-contact"
        case .sms: return "icon-sms"
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

struct QRCodePreviewView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            QRCodePreviewView(type: .text, viewModel: {
                let vm = GenerateViewModel()
                vm.text = "Hello World"
                vm.generateQRCode(for: .text)
                return vm
            }())
        }
    }
}
