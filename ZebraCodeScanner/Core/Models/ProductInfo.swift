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

// MARK: - OpenFDA Drug NDC API Response

struct OpenFDAResponse: Decodable {
    let results: [OpenFDADrugResult]?
}

struct OpenFDADrugResult: Decodable {
    let brandName: String?
    let genericName: String?
    let labelerName: String?
    let dosageForm: String?
    let route: [String]?
    let activeIngredients: [OpenFDAActiveIngredient]?
    let packaging: [OpenFDAPackaging]?

    enum CodingKeys: String, CodingKey {
        case brandName = "brand_name"
        case genericName = "generic_name"
        case labelerName = "labeler_name"
        case dosageForm = "dosage_form"
        case route
        case activeIngredients = "active_ingredients"
        case packaging
    }

    var toProductInfo: ProductInfo? {
        let name = brandName ?? genericName
        guard let name, !name.isEmpty else { return nil }

        let ingredientsList = activeIngredients?.compactMap { ingredient in
            if let name = ingredient.name, let strength = ingredient.strength {
                return "\(name) \(strength)"
            }
            return ingredient.name
        }.joined(separator: ", ")

        let categoryParts = [dosageForm, route?.joined(separator: ", ")].compactMap { $0 }
        let category = categoryParts.isEmpty ? nil : categoryParts.joined(separator: " - ")

        return ProductInfo(
            name: name,
            brand: labelerName,
            imageURL: nil,
            category: category,
            ingredients: ingredientsList
        )
    }
}

struct OpenFDAActiveIngredient: Decodable {
    let name: String?
    let strength: String?
}

struct OpenFDAPackaging: Decodable {
    let packageNdc: String?

    enum CodingKeys: String, CodingKey {
        case packageNdc = "package_ndc"
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
