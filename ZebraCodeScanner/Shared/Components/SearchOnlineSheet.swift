//
//  SearchOnlineSheet.swift
//  ZebraCodeScanner
//

import SwiftUI

struct SearchOnlineSheet: View {
    let query: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Drag indicator
            Capsule()
                .fill(Color.gray.opacity(0.4))
                .frame(width: 36, height: 5)
                .padding(.top, 8)

            Text(String(localized: "search_online.title", defaultValue: "Search Online"))
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(DesignColors.primaryText)
                .padding(.top, 20)
                .padding(.bottom, 4)

            Text(String(localized: "search_online.subtitle", defaultValue: "Choose a marketplace to search"))
                .font(.system(size: 14))
                .foregroundStyle(DesignColors.secondaryText)
                .padding(.bottom, 20)

            VStack(spacing: 8) {
                marketplaceButton(
                    title: String(localized: "search_online.amazon", defaultValue: "Amazon"),
                    icon: "cart",
                    marketplace: "amazon"
                )

                marketplaceButton(
                    title: String(localized: "search_online.ebay", defaultValue: "eBay"),
                    icon: "tag",
                    marketplace: "ebay"
                )

                marketplaceButton(
                    title: String(localized: "search_online.google_shopping", defaultValue: "Google Shopping"),
                    icon: "magnifyingglass",
                    marketplace: "google"
                )
            }
            .padding(.horizontal, 16)

            Spacer()
        }
        .presentationDetents([.height(300)])
        .presentationDragIndicator(.hidden)
        .background(DesignColors.background)
    }

    private func marketplaceButton(title: String, icon: String, marketplace: String) -> some View {
        Button {
            openSearch(on: marketplace)
            dismiss()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .frame(width: 24)

                Text(title)
                    .font(.system(size: 16, weight: .medium))

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 14))
                    .foregroundStyle(DesignColors.secondaryText)
            }
            .foregroundStyle(DesignColors.primaryText)
            .padding(16)
            .background(DesignColors.detailCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(DesignColors.detailCardStroke, lineWidth: 1)
            )
        }
    }

    private func openSearch(on marketplace: String) {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString: String
        switch marketplace {
        case "amazon":
            urlString = "https://www.amazon.com/s?k=\(encoded)"
        case "ebay":
            urlString = "https://www.ebay.com/sch/i.html?_nkw=\(encoded)"
        default:
            urlString = "https://www.google.com/search?tbm=shop&q=\(encoded)"
        }
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}
