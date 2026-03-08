//
//  UPCItemDBAPI.swift
//  ZebraCodeScanner
//
//  Created by Sardor Islomov on 25/01/26.
//

import Foundation

final class UPCItemDBAPI {
    static let shared = UPCItemDBAPI()

    private let baseURL = "https://api.upcitemdb.com/prod/v1/lookup"
    private let apiKey = "7ea92fe42a0bde3bb277f6638988d87b"
    private let networkManager = NetworkManager.shared

    private init() {}

    func fetchProduct(barcode: String) async -> ProductInfo? {
        guard let url = URL(string: baseURL) else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "user_key")
        request.setValue("3scale", forHTTPHeaderField: "key_type")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["upc": barcode])

        do {
            let response = try await networkManager.fetch(UPCItemDBResponse.self, request: request)

            guard let items = response.items, !items.isEmpty else { return nil }

            return items.first?.toProductInfo
        } catch {
            print("UPCitemdb API error: \(error)")
            return nil
        }
    }
}
