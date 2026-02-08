//
//  HistoryDetailView.swift
//  ZebraCodeScanner
//
//  Created by Sardor Islomov on 25/01/26.
//

import SwiftUI
import CoreData

struct HistoryDetailView: View {
    let entity: GeneratedCodeEntity
    @Environment(\.dismiss) private var dismiss

    @State private var showSaveSuccess = false
    @State private var showSaveError = false
    @State private var showDeleteConfirmation = false

    var body: some View {
        VStack(spacing: 0) {
            // Custom header
            detailHeader

            ScrollView {
                VStack(spacing: 16) {
                    // Code Image
                    codeImageSection

                    // Type Badge
                    typeBadge

                    // Details Section
                    detailsSection
                }
                .padding(.top, 8)
            }

            Spacer()

            // Action Buttons
            actionButtons
                .padding(.bottom, 8)
        }
        .background(DesignColors.background)
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .alert(String(localized: "common.alert.saved", defaultValue: "Saved!"), isPresented: $showSaveSuccess) {
            Button(String(localized: "common.ok", defaultValue: "OK"), role: .cancel) {}
        } message: {
            Text(String(localized: "history_detail.saved_message", defaultValue: "Image saved to your photo library."))
        }
        .alert(String(localized: "common.error", defaultValue: "Error"), isPresented: $showSaveError) {
            Button(String(localized: "common.ok", defaultValue: "OK"), role: .cancel) {}
        } message: {
            Text(String(localized: "history_detail.save_error", defaultValue: "Failed to save. Please check photo library permissions."))
        }
        .alert(String(localized: "history_detail.delete_title", defaultValue: "Delete Code"), isPresented: $showDeleteConfirmation) {
            Button(String(localized: "common.delete", defaultValue: "Delete"), role: .destructive) {
                CoreDataManager.shared.deleteGeneratedCode(entity)
                dismiss()
            }
            Button(String(localized: "common.cancel", defaultValue: "Cancel"), role: .cancel) {}
        } message: {
            Text(String(localized: "history_detail.delete_message", defaultValue: "Are you sure you want to delete this code?"))
        }
    }

    // MARK: - Header

    private var detailHeader: some View {
        ZStack {
            Text(entity.type == "qr" ? String(localized: "common.qr_code", defaultValue: "QR Code") : String(localized: "common.barcode", defaultValue: "Barcode"))
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
                    dismiss()
                } label: {
                    Text(String(localized: "common.done", defaultValue: "Done"))
                        .font(.custom("Inter-Medium", size: 14))
                        .tracking(-0.408)
                        .foregroundStyle(DesignColors.primaryText)
                        .padding(.horizontal, 16)
                        .frame(height: 44)
                        .background(DesignColors.cardBackground)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    // MARK: - Code Image

    private var codeImageSection: some View {
        VStack(spacing: 16) {
            if let image = entity.image {
                if entity.type == "barcode" {
                    Image(uiImage: image)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: 120)
                        .padding(20)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: DesignColors.primaryText.opacity(0.1), radius: 10, x: 0, y: 0)
                } else {
                    Image(uiImage: image)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160, height: 160)
                        .padding(20)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: DesignColors.primaryText.opacity(0.1), radius: 10, x: 0, y: 0)
                }
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Type Badge

    private var typeBadge: some View {
        HStack(spacing: 4) {
            Image(iconName)
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 16, height: 16)
                .foregroundStyle(DesignColors.primaryText)

            Text(typeTitle)
                .font(.custom("Inter-Regular", size: 14))
                .tracking(-0.408)
                .foregroundStyle(DesignColors.primaryText)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(DesignColors.cardBackground)
        .clipShape(Capsule())
    }

    // MARK: - Details Section

    private var detailsSection: some View {
        VStack(spacing: 0) {
            detailRow(label: String(localized: "history_detail.label.type", defaultValue: "Type"), value: entity.type == "qr" ? String(localized: "common.qr_code", defaultValue: "QR Code") : String(localized: "common.barcode", defaultValue: "Barcode"))
            detailRow(label: String(localized: "history_detail.label.content_type", defaultValue: "Content type"), value: typeTitle)
            detailRow(label: String(localized: "history_detail.label.content", defaultValue: "Content"), value: entity.content ?? "")
            detailRow(label: String(localized: "history_detail.label.created", defaultValue: "Created"), value: formatDate(entity.createdAt))
        }
        .padding(8)
        .background(DesignColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 16)
    }

    private func detailRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.custom("Inter-Regular", size: 14))
                .tracking(-0.408)
                .foregroundStyle(DesignColors.secondaryText)

            Text(value)
                .font(.custom("Inter-Medium", size: 16))
                .tracking(-0.408)
                .foregroundStyle(DesignColors.primaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // Share
                if let image = entity.image {
                    ShareLink(
                        item: Image(uiImage: image),
                        preview: SharePreview(typeTitle, image: Image(uiImage: image))
                    ) {
                        actionButton(icon: "square.and.arrow.up", title: String(localized: "common.share", defaultValue: "Share"), isPrimary: true)
                    }
                }

                // Save to Photos
                Button {
                    saveToPhotos()
                } label: {
                    actionButton(icon: "arrow.down.to.line", title: String(localized: "common.save_to_photos", defaultValue: "Save to Photos"))
                }

                // Copy Content
                Button {
                    UIPasteboard.general.string = entity.content
                } label: {
                    actionButton(icon: "doc.on.doc", title: String(localized: "history_detail.copy_content", defaultValue: "Copy content"))
                }

                // Copy Image
                Button {
                    if let image = entity.image {
                        UIPasteboard.general.image = image
                    }
                } label: {
                    actionButton(icon: "photo.on.rectangle", title: String(localized: "common.copy_image", defaultValue: "Copy Image"))
                }

                // Delete
                Button {
                    showDeleteConfirmation = true
                } label: {
                    actionButton(icon: "trash", title: String(localized: "common.delete", defaultValue: "Delete"), isDestructive: true)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func actionButton(icon: String, title: String, isPrimary: Bool = false, isDestructive: Bool = false) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16))
            Text(title)
                .font(.custom("Inter-Medium", size: 16))
                .tracking(-0.408)
        }
        .foregroundStyle(isDestructive ? Color.white : isPrimary ? DesignColors.primaryButtonText : DesignColors.primaryText)
        .padding(.horizontal, 16)
        .frame(height: 51)
        .background(isPrimary ? DesignColors.primaryText : isDestructive ? Color(red: 0xE8/255, green: 0x10/255, blue: 0x10/255) : DesignColors.lightText)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Helpers

    private var iconName: String {
        if entity.type == "qr" {
            if let contentType = entity.contentType {
                switch contentType {
                case "text": return "icon-text"
                case "url": return "icon-link"
                case "phone": return "icon-phone"
                case "email": return "icon-email"
                case "wifi": return "icon-wifi"
                case "vcard": return "icon-contact"
                case "sms": return "icon-sms"
                default: return "icon-qr"
                }
            }
            return "icon-qr"
        } else {
            return "icon-barcode1d"
        }
    }

    private var typeTitle: String {
        if entity.type == "qr" {
            if let contentType = entity.contentType,
               let qrType = QRCodeContentType(rawValue: contentType) {
                return qrType.title
            }
        } else if entity.type == "barcode" {
            if let contentType = entity.contentType,
               let barcodeType = BarcodeType(rawValue: contentType) {
                return barcodeType.title
            }
        }
        return entity.contentType ?? "Unknown"
    }

    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }

    private func saveToPhotos() {
        guard let image = entity.image else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        showSaveSuccess = true
    }
}

// MARK: - Scanned Detail View

struct ScannedDetailView: View {
    let entity: ScannedCodeEntity
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Custom header
            detailHeader

            ScrollView {
                VStack(spacing: 16) {
                    // Icon
                    iconSection

                    // Type Badge
                    typeBadge

                    // Details Section
                    detailsSection
                }
                .padding(.top, 8)
            }

            Spacer()

            // Action Buttons
            actionButtons
                .padding(.bottom, 8)
        }
        .background(DesignColors.background)
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }

    // MARK: - Header

    private var detailHeader: some View {
        ZStack {
            Text(isQR ? String(localized: "common.qr_code", defaultValue: "QR Code") : String(localized: "common.barcode", defaultValue: "Barcode"))
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
                    dismiss()
                } label: {
                    Text(String(localized: "common.done", defaultValue: "Done"))
                        .font(.custom("Inter-Medium", size: 14))
                        .tracking(-0.408)
                        .foregroundStyle(DesignColors.primaryText)
                        .padding(.horizontal, 16)
                        .frame(height: 44)
                        .background(DesignColors.cardBackground)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    // MARK: - Icon Section

    private var iconSection: some View {
        Image(systemName: isQR ? "qrcode" : "barcode")
            .font(.system(size: 60))
            .foregroundStyle(DesignColors.secondaryText)
            .frame(width: 160, height: 160)
            .padding(20)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: DesignColors.primaryText.opacity(0.1), radius: 10, x: 0, y: 0)
            .padding(.horizontal, 16)
    }

    // MARK: - Type Badge

    private var typeBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: isQR ? "qrcode" : "barcode")
                .font(.system(size: 14))
                .foregroundStyle(DesignColors.primaryText)

            Text(entity.type?.capitalized ?? String(localized: "common.unknown", defaultValue: "Unknown"))
                .font(.custom("Inter-Regular", size: 14))
                .tracking(-0.408)
                .foregroundStyle(DesignColors.primaryText)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(DesignColors.cardBackground)
        .clipShape(Capsule())
    }

    // MARK: - Details Section

    private var detailsSection: some View {
        VStack(spacing: 0) {
            detailRow(label: String(localized: "history_detail.label.type", defaultValue: "Type"), value: isQR ? String(localized: "common.qr_code", defaultValue: "QR Code") : String(localized: "common.barcode", defaultValue: "Barcode"))
            detailRow(label: String(localized: "history_detail.label.content", defaultValue: "Content"), value: entity.content ?? "")
            if let productName = entity.productName, !productName.isEmpty {
                detailRow(label: String(localized: "history_detail.label.product", defaultValue: "Product"), value: productName)
            }
            if let productBrand = entity.productBrand, !productBrand.isEmpty {
                detailRow(label: String(localized: "history_detail.label.brand", defaultValue: "Brand"), value: productBrand)
            }
            detailRow(label: String(localized: "history_detail.label.scanned", defaultValue: "Scanned"), value: formatDate(entity.scannedAt))
        }
        .padding(8)
        .background(DesignColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 16)
    }

    private func detailRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.custom("Inter-Regular", size: 14))
                .tracking(-0.408)
                .foregroundStyle(DesignColors.secondaryText)

            Text(value)
                .font(.custom("Inter-Medium", size: 16))
                .tracking(-0.408)
                .foregroundStyle(DesignColors.primaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // Copy Content
                Button {
                    UIPasteboard.general.string = entity.content
                } label: {
                    actionButton(icon: "doc.on.doc", title: String(localized: "history_detail.copy_content", defaultValue: "Copy content"), isPrimary: true)
                }

                // Open Link (if URL)
                if let content = entity.content,
                   let url = URL(string: content),
                   UIApplication.shared.canOpenURL(url) {
                    Button {
                        UIApplication.shared.open(url)
                    } label: {
                        actionButton(icon: "safari", title: String(localized: "history_detail.open_link", defaultValue: "Open Link"))
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func actionButton(icon: String, title: String, isPrimary: Bool = false) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16))
            Text(title)
                .font(.custom("Inter-Medium", size: 16))
                .tracking(-0.408)
        }
        .foregroundStyle(isPrimary ? DesignColors.primaryButtonText : DesignColors.primaryText)
        .padding(.horizontal, 16)
        .frame(height: 51)
        .background(isPrimary ? DesignColors.primaryText : DesignColors.lightText)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Helpers

    private var isQR: Bool {
        let type = entity.type?.lowercased() ?? ""
        return type.contains("qr")
    }

    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
}

struct HistoryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HistoryDetailView(entity: GeneratedCodeEntity(context: CoreDataManager.shared.viewContext))
        }
    }
}
