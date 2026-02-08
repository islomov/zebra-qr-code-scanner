//
//  GenerateView.swift
//  ZebraCodeScanner
//
//  Created by Sardor Islomov on 25/01/26.
//

import SwiftUI

struct GenerateView: View {
    @Binding var showSettings: Bool
    @StateObject private var viewModel = GenerateViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    // Custom Header
                    HStack {
                        Text(String(localized: "generate.title", defaultValue: "Generate"))
                            .font(.custom("Inter-SemiBold", size: 28))
                            .tracking(-0.408)
                            .foregroundStyle(DesignColors.primaryText)

                        Spacer()

                        Button {
                            showSettings = true
                        } label: {
                            Image("icon-setting")
                                .renderingMode(.template)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .foregroundStyle(DesignColors.primaryText)
                                .frame(width: 44, height: 44)
                                .background(DesignColors.cardBackground)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 8)

                    // QR Codes Section
                    sectionHeader(icon: "icon-qr", title: String(localized: "generate.section.qr_codes", defaultValue: "QR Codes"), iconColor: Color(red: 0x01/255, green: 0x87/255, blue: 0xFF/255))

                    gridLayout(items: Array(QRCodeContentType.allCases)) { type in
                        NavigationLink {
                            QRCodeFormView(type: type, viewModel: viewModel)
                        } label: {
                            GenerateCard(
                                iconName: qrIconName(for: type),
                                title: type.title
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 16)

                    // 1D Barcodes Section
                    sectionHeader(icon: "icon-1d-section", title: String(localized: "generate.section.1d_barcodes", defaultValue: "1D Barcodes"), iconColor: Color(red: 0xF2/255, green: 0x99/255, blue: 0x0A/255))

                    gridLayout(items: BarcodeType.barcodes1D) { type in
                        NavigationLink {
                            BarcodeFormView(type: type, viewModel: viewModel)
                        } label: {
                            GenerateCard(
                                iconName: "icon-barcode1d",
                                title: type.title
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 16)

                    // 2D Barcodes Section
                    sectionHeader(icon: "icon-2d-section", title: String(localized: "generate.section.2d_barcodes", defaultValue: "2D Barcodes"), iconColor: Color(red: 0x2D/255, green: 0xD9/255, blue: 0x16/255))

                    gridLayout(items: BarcodeType.barcodes2D) { type in
                        NavigationLink {
                            BarcodeFormView(type: type, viewModel: viewModel)
                        } label: {
                            GenerateCard(
                                iconName: barcodeIconName(for: type),
                                title: type.title
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 16)

                    // Social Media Section
                    sectionHeader(icon: "icon-social-section", title: String(localized: "generate.section.social_media", defaultValue: "Social Media"), iconColor: Color(red: 0xC2/255, green: 0x0E/255, blue: 0xEF/255))

                    gridLayout(items: Array(SocialMediaType.allCases)) { type in
                        NavigationLink {
                            SocialMediaFormView(type: type, viewModel: viewModel)
                        } label: {
                            GenerateCard(
                                iconName: socialIconName(for: type),
                                title: type.title
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 16)

                    // Feature Request Section
                    VStack(spacing: 16) {
                        Image("icon-lightbulb")
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                            .foregroundStyle(DesignColors.primaryText)

                        VStack(spacing: 8) {
                            Text(String(localized: "generate.request.title", defaultValue: "Need a different code type?"))
                                .font(.custom("Inter-SemiBold", size: 20))
                                .tracking(-0.408)
                                .foregroundStyle(DesignColors.primaryText)

                            Text(String(localized: "generate.request.message", defaultValue: "If you need additional QR codes or barcodes, let us know!"))
                                .font(.custom("Inter-Regular", size: 14))
                                .tracking(-0.408)
                                .foregroundStyle(DesignColors.secondaryText)
                        }
                        .multilineTextAlignment(.center)

                        Link(destination: URL(string: "mailto:sardor.islomov.96@gmail.com?subject=Code%20Scanner%20-%20Feature%20Request")!) {
                            Text(String(localized: "generate.request.button", defaultValue: "Send a Request"))
                                .font(.custom("Inter-Medium", size: 16))
                                .tracking(-0.408)
                                .foregroundStyle(DesignColors.lightText)
                                .frame(maxWidth: .infinity)
                                .padding(16)
                                .background(DesignColors.primaryText)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                    .padding(16)
                    .background(DesignColors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(DesignColors.stroke, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 24)
                }
            }
            .background(DesignColors.background)
            .navigationBarHidden(true)
        }
    }

    // MARK: - Non-Lazy Grid Layout

    @ViewBuilder
    private func gridLayout<Item: Identifiable, Content: View>(
        items: [Item],
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View {
        let indices = Array(stride(from: 0, to: items.count, by: 2))
        VStack(spacing: 8) {
            ForEach(indices, id: \.self) { index in
                HStack(spacing: 8) {
                    content(items[index])
                    if index + 1 < items.count {
                        content(items[index + 1])
                    } else {
                        Color.clear
                    }
                }
            }
        }
    }

    // MARK: - Section Header

    private func sectionHeader(icon: String, title: String, iconColor: Color = DesignColors.primaryText) -> some View {
        HStack(spacing: 8) {
            Image(icon)
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundStyle(iconColor)

            Text(title)
                .font(.custom("Inter-SemiBold", size: 20))
                .tracking(-0.408)
                .foregroundStyle(DesignColors.primaryText)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    // MARK: - Icon Name Helpers

    private func qrIconName(for type: QRCodeContentType) -> String {
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

    private func barcodeIconName(for type: BarcodeType) -> String {
        switch type {
        case .aztec: return "icon-aztec"
        case .pdf417: return "icon-pdf417"
        default: return "icon-barcode1d"
        }
    }

    private func socialIconName(for type: SocialMediaType) -> String {
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
}

// MARK: - Generate Card

struct GenerateCard: View {
    let iconName: String
    let title: String

    var body: some View {
        HStack(spacing: 8) {
            Image(iconName)
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundStyle(DesignColors.primaryText)

            Text(title)
                .font(.custom("Inter-Medium", size: 16))
                .tracking(-0.408)
                .foregroundStyle(DesignColors.primaryText)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(16)
        .background(DesignColors.cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(DesignColors.stroke, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct GenerateView_Previews: PreviewProvider {
    static var previews: some View {
        GenerateView(showSettings: .constant(false))
    }
}
