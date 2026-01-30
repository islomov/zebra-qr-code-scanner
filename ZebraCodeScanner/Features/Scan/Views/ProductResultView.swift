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

    @State private var showSavedAlert = false
    @State private var showCopiedAlert = false

    private let dataManager = CoreDataManager.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Product Section
                    if isLoading {
                        loadingView
                    } else if let product = productInfo {
                        productView(product)
                    } else {
                        notFoundView
                    }

                    // Barcode Info Card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "barcode")
                            Text(typeDisplayName)
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                        Text(content)
                            .font(.body.monospaced())
                            .textSelection(.enabled)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)

                    // Action Buttons
                    VStack(spacing: 12) {
                        Button {
                            UIPasteboard.general.string = content
                            showCopiedAlert = true
                        } label: {
                            Label("Copy Barcode", systemImage: "doc.on.doc")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        ShareLink(item: content) {
                            Label("Share", systemImage: "square.and.arrow.up")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemGray5))
                                .foregroundStyle(.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        Button {
                            saveToHistory()
                        } label: {
                            Label("Save to History", systemImage: "clock.arrow.circlepath")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemGray5))
                                .foregroundStyle(.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

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
                .padding(.top)
            }
            .navigationTitle("Product Result")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        onDismiss()
                    }
                }
            }
            .alert("Saved!", isPresented: $showSavedAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Scan result saved to history.")
            }
            .alert("Copied!", isPresented: $showCopiedAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Barcode copied to clipboard.")
            }
        }
    }

    // MARK: - Product Views

    private func productView(_ product: ProductInfo) -> some View {
        VStack(spacing: 16) {
            // Product Image
            if let imageURL = product.imageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 200, maxHeight: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
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

            // Product Name & Brand
            VStack(spacing: 4) {
                Text(product.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                if let brand = product.brand, !brand.isEmpty {
                    Text(brand)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)

            // Details Card
            if product.category != nil || product.ingredients != nil {
                VStack(alignment: .leading, spacing: 12) {
                    if let category = product.category, !category.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Category")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(category)
                                .font(.body)
                        }
                    }

                    if let ingredients = product.ingredients, !ingredients.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Ingredients")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(ingredients)
                                .font(.body)
                                .lineLimit(5)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)

            Text("Looking up product...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(height: 200)
    }

    private var notFoundView: some View {
        VStack(spacing: 12) {
            Image(systemName: "shippingbox")
                .font(.system(size: 50))
                .foregroundStyle(.tertiary)

            Text("Product Not Found")
                .font(.title3)
                .fontWeight(.semibold)

            Text("No product information available for this barcode.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.vertical)
    }

    private var productPlaceholder: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(.systemGray5))
            .frame(width: 200, height: 200)
            .overlay {
                Image(systemName: "shippingbox")
                    .font(.system(size: 40))
                    .foregroundStyle(.secondary)
            }
    }

    // MARK: - Helpers

    private var typeDisplayName: String {
        switch type {
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
        default:
            return "Barcode"
        }
    }

    private func saveToHistory() {
        _ = dataManager.saveScannedCode(
            type: type,
            content: content,
            productName: productInfo?.name,
            productBrand: productInfo?.brand,
            productImage: productInfo?.imageURL
        )
        showSavedAlert = true
    }
}

#Preview {
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
