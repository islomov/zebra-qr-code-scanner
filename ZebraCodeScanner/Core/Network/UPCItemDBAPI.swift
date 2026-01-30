//
//  UPCItemDBAPI.swift
//  ZebraCodeScanner
//
//  Created by Sardor Islomov on 25/01/26.
//

import Foundation

final class UPCItemDBAPI {
    static let shared = UPCItemDBAPI()

    private let baseURL = "https://api.upcitemdb.com/prod/trial/lookup"
    private let networkManager = NetworkManager.shared

    private init() {}

    func fetchProduct(barcode: String) async -> ProductInfo? {
        let urlString = "\(baseURL)?upc=\(barcode)"

        do {
            let response = try await networkManager.fetch(UPCItemDBResponse.self, from: urlString)

            guard let items = response.items, !items.isEmpty else { return nil }

            return items.first?.toProductInfo
        } catch {
            print("UPCitemdb API error: \(error)")
            return nil
        }
    }
}
