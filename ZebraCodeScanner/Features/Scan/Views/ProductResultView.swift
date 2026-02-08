//
//  ProductResultView.swift
//  ZebraCodeScanner
//
//  Created by Sardor Islomov on 25/01/26.
//

import SwiftUI

struct ProductResultView: View {
    let content: String
    let type: String
    let productInfo: ProductInfo?
    let isLoading: Bool
    let onScanAgain: () -> Void
    let onDismiss: () -> Void

    @State private var showCopiedAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                if isLoading {
                    loadingView
                } else if let product = productInfo {
                    productView(product)
                } else {
                    notFoundView
                }
            }
            .background(DesignColors.background)
            .navigationTitle(String(localized: "product_result.nav_title", defaultValue: "Product result"))
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
                Text(String(localized: "product_result.copied_message", defaultValue: "Barcode copied to clipboard."))
            }
        }
    }

    // MARK: - Product Found View

    private func productView(_ product: ProductInfo) -> some View {
        VStack(spacing: 0) {
            // Product Image + Name + Brand
            VStack(spacing: 20) {
                if let imageURL = product.imageURL, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 200, height: 200)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        case .failure:
                            productPlaceholder
                        case .empty:
                            ProgressView()
                                .frame(width: 200, height: 200)
                        @unknown default:
                            productPlaceholder
                        }
                    }
                } else {
                    productPlaceholder
                }

                VStack(spacing: 8) {
                    Text(product.name)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(DesignColors.primaryText)
                        .multilineTextAlignment(.center)

                    if let brand = product.brand, !brand.isEmpty {
                        Text(brand)
                            .font(.system(size: 14))
                            .foregroundStyle(DesignColors.secondaryText)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)

            // Details Cards + Barcode Card + Action Buttons
            VStack(spacing: 8) {
                // Category & Ingredients Card
                if product.category != nil || product.ingredients != nil {
                    VStack(alignment: .leading, spacing: 12) {
                        if let category = product.category, !category.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(String(localized: "product_result.category", defaultValue: "Category"))
                                    .font(.system(size: 14))
                                    .foregroundStyle(DesignColors.labelText)
                                Text(category)
                                    .font(.system(size: 16))
                                    .foregroundStyle(DesignColors.primaryText)
                            }
                        }

                        if let ingredients = product.ingredients, !ingredients.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(String(localized: "product_result.ingredients", defaultValue: "Ingredients"))
                                    .font(.system(size: 14))
                                    .foregroundStyle(DesignColors.labelText)
                                Text(ingredients)
                                    .font(.system(size: 16))
                                    .foregroundStyle(DesignColors.primaryText)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(DesignColors.detailCardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(DesignColors.detailCardStroke, lineWidth: 1)
                    )
                }

                // Barcode Info Card
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image("icon-barcode1d")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 16, height: 16)
                            .foregroundStyle(DesignColors.labelText)
                        Text(typeDisplayName)
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

    // MARK: - Not Found View

    private var notFoundView: some View {
        VStack(spacing: 0) {
            VStack(spacing: 20) {
                Image("icon-product-not-found")
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 72, height: 72)
                    .foregroundStyle(DesignColors.primaryText)

                VStack(spacing: 8) {
                    Text(String(localized: "product_result.not_found.title", defaultValue: "Product Not Found"))
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(DesignColors.primaryText)
                        .multilineTextAlignment(.center)

                    Text(String(localized: "product_result.not_found.message", defaultValue: "No product information available for this barcode"))
                        .font(.system(size: 14))
                        .foregroundStyle(DesignColors.labelText)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)

            actionButtons
                .padding(16)
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)

            Text(String(localized: "product_result.loading", defaultValue: "Looking up product..."))
                .font(.system(size: 14))
                .foregroundStyle(DesignColors.secondaryText)
        }
        .frame(height: 200)
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
                        Text(String(localized: "product_result.copy_barcode", defaultValue: "Copy barcode"))
                            .font(.system(size: 16, weight: .medium))
                    }
                    .padding(16)
                    .background(DesignColors.actionButtonBackground)
                    .foregroundStyle(DesignColors.primaryText)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
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

    // MARK: - Product Placeholder

    private var productPlaceholder: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(DesignColors.detailCardBackground)
            .frame(width: 200, height: 200)
            .overlay {
                Image(systemName: "shippingbox")
                    .font(.system(size: 40))
                    .foregroundStyle(DesignColors.secondaryText)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(DesignColors.detailCardStroke, lineWidth: 1)
            )
    }

    // MARK: - Helpers

    private var typeDisplayName: String {
        switch type {
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
        default:
            return String(localized: "common.barcode", defaultValue: "Barcode")
        }
    }

}

struct ProductResultView_Previews: PreviewProvider {
    static var previews: some View {
        ProductResultView(
            content: "737628064502",
            type: "ean13",
            productInfo: ProductInfo(
                name: "Chocolate Bar",
                brand: "Example Brand",
                imageURL: nil,
                category: "Snacks",
                ingredients: "Sugar, cocoa butter, milk"
            ),
            isLoading: false,
            onScanAgain: {},
            onDismiss: {}
        )
    }
}
