//
//  ProductInfo.swift
//  ZebraCodeScanner
//
//  Created by Sardor Islomov on 25/01/26.
//

import Foundation

struct ProductInfo {
    let name: String
    let brand: String?
    let imageURL: String?
    let category: String?
    let ingredients: String?
}

// MARK: - Open Food Facts API Response

struct OpenFoodFactsResponse: Decodable {
    let status: Int
    let product: OpenFoodFactsProduct?
}

struct OpenFoodFactsProduct: Decodable {
    let productName: String?
    let brands: String?
    let imageUrl: String?
    let categories: String?
    let ingredientsText: String?

    enum CodingKeys: String, CodingKey {
        case productName = "product_name"
        case brands
        case imageUrl = "image_url"
        case categories
        case ingredientsText = "ingredients_text"
    }

    var toProductInfo: ProductInfo? {
        guard let name = productName, !name.isEmpty else { return nil }
        return ProductInfo(
            name: name,
            brand: brands,
            imageURL: imageUrl,
            category: categories,
            ingredients: ingredientsText
        )
    }
}

// MARK: - UPCitemdb API Response

struct UPCItemDBResponse: Decodable {
    let code: String?
    let total: Int?
    let items: [UPCItemDBItem]?
}

struct UPCItemDBItem: Decodable {
    let title: String?
    let brand: String?
    let category: String?
    let description: String?
    let images: [String]?

    var toProductInfo: ProductInfo? {
        guard let name = title, !name.isEmpty else { return nil }
        return ProductInfo(
            name: name,
            brand: brand,
            imageURL: images?.first,
            category: category,
            ingredients: description
        )
    }
}
