//
//  ScanResultView.swift
//  ZebraCodeScanner
//
//  Created by Sardor Islomov on 25/01/26.
//

import SwiftUI

struct ScanResultView: View {
    let content: String
    let type: String
    let onScanAgain: () -> Void
    let onDismiss: () -> Void

    @State private var showCopiedAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Icon
                    Image(systemName: typeIcon)
                        .font(.system(size: 80))
                        .foregroundStyle(.tint)
                        .padding(.top, 20)

                    // Type Badge
                    HStack {
                        Image(systemName: typeIcon)
                        Text(typeDisplayName)
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .clipShape(Capsule())

                    // Content Card
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Scanned Content")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text(content)
                            .font(.body)
                            .textSelection(.enabled)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)

                    // Action Buttons
                    VStack(spacing: 12) {
                        // Copy Button
                        Button {
                            UIPasteboard.general.string = content
                            showCopiedAlert = true
                        } label: {
                            Label("Copy to Clipboard", systemImage: "doc.on.doc")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        // Open URL (if applicable)
                        if isURL {
                            Button {
                                openURL()
                            } label: {
                                Label("Open in Browser", systemImage: "safari")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(.systemGray5))
                                    .foregroundStyle(.primary)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }

                        // Share Button
                        ShareLink(item: content) {
                            Label("Share", systemImage: "square.and.arrow.up")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemGray5))
                                .foregroundStyle(.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        // Scan Again Button
                        Button {
                            onScanAgain()
                        } label: {
                            Label("Scan Again", systemImage: "camera.viewfinder")
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
            }
            .navigationTitle("Scan Result")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        onDismiss()
                    }
                }
            }
            .alert("Copied!", isPresented: $showCopiedAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Content copied to clipboard.")
            }
        }
    }

    private var typeIcon: String {
        switch type {
        case "qr", "datamatrix", "aztec":
            return "qrcode"
        default:
            return "barcode"
        }
    }

    private var typeDisplayName: String {
        switch type {
        case "qr":
            return "QR Code"
        case "code128":
            return "Code 128"
        case "ean13":
            return "EAN-13"
        case "ean8":
            return "EAN-8"
        case "upce":
            return "UPC-E"
        case "code39":
            return "Code 39"
        case "code93":
            return "Code 93"
        case "itf14":
            return "ITF-14"
        case "datamatrix":
            return "Data Matrix"
        case "pdf417":
            return "PDF417"
        case "aztec":
            return "Aztec"
        default:
            return "Barcode"
        }
    }

    private var isURL: Bool {
        guard let url = URL(string: content) else { return false }
        return url.scheme == "http" || url.scheme == "https"
    }

    private func openURL() {
        guard let url = URL(string: content) else { return }
        UIApplication.shared.open(url)
    }

}

struct ScanResultView_Previews: PreviewProvider {
    static var previews: some View {
        ScanResultView(
            content: "https://example.com",
            type: "qr",
            onScanAgain: {},
            onDismiss: {}
        )
    }
}
