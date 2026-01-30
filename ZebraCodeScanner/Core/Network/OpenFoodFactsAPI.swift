//
//  OpenFoodFactsAPI.swift
//  ZebraCodeScanner
//
//  Created by Sardor Islomov on 25/01/26.
//

import Foundation

final class OpenFoodFactsAPI {
    static let shared = OpenFoodFactsAPI()

    private let baseURL = "https://world.openfoodfacts.org/api/v0/product"
    private let networkManager = NetworkManager.shared

    private init() {}

    func fetchProduct(barcode: String) async -> ProductInfo? {
        let urlString = "\(baseURL)/\(barcode).json"

        do {
            let response = try await networkManager.fetch(OpenFoodFactsResponse.self, from: urlString)

            guard response.status == 1 else { return nil }

            return response.product?.toProductInfo
        } catch {
            print("Open Food Facts API error: \(error)")
            return nil
        }
    }
}
