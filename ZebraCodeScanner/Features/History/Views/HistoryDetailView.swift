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

    @State private var showSaveSuccess = false
    @State private var showSaveError = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Code Image
                if let image = entity.image {
                    Image(uiImage: image)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: entity.type == "barcode" ? .infinity : 250)
                        .frame(height: entity.type == "barcode" ? 120 : 250)
                        .padding(20)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
                }

                // Type Badge
                HStack {
                    Image(systemName: typeIcon)
                    Text(typeTitle)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .clipShape(Capsule())

                // Details Section
                VStack(alignment: .leading, spacing: 16) {
                    DetailRow(title: "Type", value: entity.type == "qr" ? "QR Code" : "Barcode")
                    DetailRow(title: "Content Type", value: typeTitle)
                    DetailRow(title: "Content", value: entity.content ?? "")
                    DetailRow(title: "Created", value: formatDate(entity.createdAt))
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)

                // Action Buttons
                VStack(spacing: 12) {
                    // Share Button
                    if let image = entity.image {
                        ShareLink(
                            item: Image(uiImage: image),
                            preview: SharePreview(typeTitle, image: Image(uiImage: image))
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

                    // Copy Content Button
                    Button {
                        UIPasteboard.general.string = entity.content
                    } label: {
                        Label("Copy Content", systemImage: "doc.on.doc")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray5))
                            .foregroundStyle(.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // Copy Image Button
                    Button {
                        if let image = entity.image {
                            UIPasteboard.general.image = image
                        }
                    } label: {
                        Label("Copy Image", systemImage: "photo.on.rectangle")
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
            .padding(.top)
        }
        .navigationTitle(typeTitle)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Saved!", isPresented: $showSaveSuccess) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Image saved to your photo library.")
        }
        .alert("Error", isPresented: $showSaveError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Failed to save. Please check photo library permissions.")
        }
    }

    private var typeIcon: String {
        if entity.type == "qr" {
            if let contentType = entity.contentType,
               let qrType = QRCodeContentType(rawValue: contentType) {
                return qrType.icon
            }
            return "qrcode"
        } else {
            return "barcode"
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

struct DetailRow: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.body)
        }
    }
}

struct ScannedDetailView: View {
    let entity: ScannedCodeEntity

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Icon
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
                    .frame(width: 120, height: 120)
                    .overlay {
                        Image(systemName: typeIcon)
                            .font(.system(size: 50))
                            .foregroundStyle(.secondary)
                    }
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)

                // Type Badge
                HStack {
                    Image(systemName: typeIcon)
                    Text(entity.type?.capitalized ?? "Unknown")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .clipShape(Capsule())

                // Details Section
                VStack(alignment: .leading, spacing: 16) {
                    DetailRow(title: "Type", value: entity.type?.capitalized ?? "Unknown")
                    DetailRow(title: "Content", value: entity.content ?? "")
                    if let productName = entity.productName, !productName.isEmpty {
                        DetailRow(title: "Product", value: productName)
                    }
                    if let productBrand = entity.productBrand, !productBrand.isEmpty {
                        DetailRow(title: "Brand", value: productBrand)
                    }
                    DetailRow(title: "Scanned", value: formatDate(entity.scannedAt))
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)

                // Copy Content Button
                Button {
                    UIPasteboard.general.string = entity.content
                } label: {
                    Label("Copy Content", systemImage: "doc.on.doc")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5))
                        .foregroundStyle(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .padding(.top)
        }
        .navigationTitle(entity.type?.capitalized ?? "Scanned Code")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var typeIcon: String {
        let type = entity.type?.lowercased() ?? ""
        if type.contains("qr") {
            return "qrcode"
        }
        return "barcode"
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
