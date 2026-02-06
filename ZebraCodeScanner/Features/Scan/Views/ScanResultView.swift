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
                                Text("Scanned Content")
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
            .navigationTitle("Scan result")
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
            .alert("Copied!", isPresented: $showCopiedAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Content copied to clipboard.")
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
                        Text("Share")
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
                        Text("Copy")
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
                            Text("Open URL")
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
                        Text("Scan again")
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
