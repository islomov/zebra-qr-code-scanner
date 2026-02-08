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
                VStack(spacing: 0) {
                    // Type Icon + Name
                    VStack(spacing: 20) {
                        Image(typeIconAsset)
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 72, height: 72)
                            .foregroundStyle(DesignColors.primaryText)

                        Text(typeDisplayName)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(DesignColors.primaryText)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                    // Content Card + Action Buttons
                    VStack(spacing: 8) {
                        // Scanned Content Card
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 4) {
                                Image(typeIconAsset)
                                    .resizable()
                                    .renderingMode(.template)
                                    .frame(width: 16, height: 16)
                                    .foregroundStyle(DesignColors.labelText)
                                Text(String(localized: "scan_result.scanned_content", defaultValue: "Scanned Content"))
                                    .font(.system(size: 14))
                                    .foregroundStyle(DesignColors.labelText)
                            }

                            Text(content)
                                .font(.system(size: 16))
                                .foregroundStyle(DesignColors.primaryText)
                                .textSelection(.enabled)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(DesignColors.detailCardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(DesignColors.detailCardStroke, lineWidth: 1)
                        )

                        // Action Buttons
                        actionButtons
                    }
                    .padding(16)
                }
            }
            .background(DesignColors.background)
            .navigationTitle(String(localized: "scan_result.nav_title", defaultValue: "Scan result"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(DesignColors.primaryText)
                    }
                }
            }
            .alert(String(localized: "common.alert.copied", defaultValue: "Copied!"), isPresented: $showCopiedAlert) {
                Button(String(localized: "common.ok", defaultValue: "OK"), role: .cancel) {}
            } message: {
                Text(String(localized: "scan_result.copied_message", defaultValue: "Content copied to clipboard."))
            }
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ShareLink(item: content) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16))
                        Text(String(localized: "common.share", defaultValue: "Share"))
                            .font(.system(size: 16, weight: .medium))
                    }
                    .padding(16)
                    .background(DesignColors.primaryActionBackground)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                Button {
                    UIPasteboard.general.string = content
                    showCopiedAlert = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 16))
                        Text(String(localized: "common.copy", defaultValue: "Copy"))
                            .font(.system(size: 16, weight: .medium))
                    }
                    .padding(16)
                    .background(DesignColors.actionButtonBackground)
                    .foregroundStyle(DesignColors.primaryText)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                if isURL {
                    Button {
                        openURL()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "safari")
                                .font(.system(size: 16))
                            Text(String(localized: "scan_result.open_url", defaultValue: "Open URL"))
                                .font(.system(size: 16, weight: .medium))
                        }
                        .padding(16)
                        .background(DesignColors.actionButtonBackground)
                        .foregroundStyle(DesignColors.primaryText)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }

                Button {
                    onScanAgain()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "barcode.viewfinder")
                            .font(.system(size: 16))
                        Text(String(localized: "scan_result.scan_again", defaultValue: "Scan again"))
                            .font(.system(size: 16, weight: .medium))
                    }
                    .padding(16)
                    .background(DesignColors.actionButtonBackground)
                    .foregroundStyle(DesignColors.primaryText)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
        }
    }

    // MARK: - Helpers

    private var typeIconAsset: String {
        switch type {
        case "qr":
            return "icon-qr"
        case "aztec":
            return "icon-aztec"
        case "pdf417":
            return "icon-pdf417"
        case "datamatrix":
            return "icon-2d-section"
        default:
            return "icon-barcode1d"
        }
    }

    private var typeDisplayName: String {
        switch type {
        case "qr":
            return String(localized: "code_type.qr_code", defaultValue: "QR Code")
        case "code128":
            return String(localized: "code_type.code128", defaultValue: "Code 128")
        case "ean13":
            return String(localized: "code_type.ean13", defaultValue: "EAN-13")
        case "ean8":
            return String(localized: "code_type.ean8", defaultValue: "EAN-8")
        case "upce":
            return String(localized: "code_type.upce", defaultValue: "UPC-E")
        case "code39":
            return String(localized: "code_type.code39", defaultValue: "Code 39")
        case "code93":
            return String(localized: "code_type.code93", defaultValue: "Code 93")
        case "itf14":
            return String(localized: "code_type.itf14", defaultValue: "ITF-14")
        case "datamatrix":
            return String(localized: "code_type.data_matrix", defaultValue: "Data Matrix")
        case "pdf417":
            return String(localized: "code_type.pdf417", defaultValue: "PDF417")
        case "aztec":
            return String(localized: "code_type.aztec", defaultValue: "Aztec")
        default:
            return String(localized: "common.barcode", defaultValue: "Barcode")
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
