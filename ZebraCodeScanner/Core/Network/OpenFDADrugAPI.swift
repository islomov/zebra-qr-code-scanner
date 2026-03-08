//
//  OpenFDADrugAPI.swift
//  ZebraCodeScanner
//
//  Created by Sardor Islomov on 06/03/26.
//

import Foundation

final class OpenFDADrugAPI {
    static let shared = OpenFDADrugAPI()

    private let baseURL = "https://api.fda.gov/drug/ndc.json"
    private let networkManager = NetworkManager.shared

    private init() {}

    func fetchProduct(barcode: String) async -> ProductInfo? {
        // Drug UPC-A barcodes start with "3", the middle 10 digits are the NDC
        guard barcode.count == 12, barcode.hasPrefix("3") else { return nil }

        let ndcDigits = String(barcode.dropFirst().dropLast())

        // NDC can be formatted as 4-4-2, 5-3-2, or 5-4-1
        let formats = [
            "\(ndcDigits.prefix(4))-\(ndcDigits.dropFirst(4).prefix(4))-\(ndcDigits.suffix(2))",
            "\(ndcDigits.prefix(5))-\(ndcDigits.dropFirst(5).prefix(3))-\(ndcDigits.suffix(2))",
            "\(ndcDigits.prefix(5))-\(ndcDigits.dropFirst(5).prefix(4))-\(ndcDigits.suffix(1))"
        ]

        for ndc in formats {
            if let product = await lookupByNDC(ndc) {
                return product
            }
        }

        return nil
    }

    private func lookupByNDC(_ ndc: String) async -> ProductInfo? {
        let encoded = ndc.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ndc
        let urlString = "\(baseURL)?search=packaging.package_ndc:\"\(encoded)\"&limit=1"

        do {
            let response = try await networkManager.fetch(OpenFDAResponse.self, from: urlString)
            return response.results?.first?.toProductInfo
        } catch {
            return nil
        }
    }
}
