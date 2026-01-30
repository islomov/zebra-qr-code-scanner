//
//  ProductLookupService.swift
//  ZebraCodeScanner
//
//  Created by Sardor Islomov on 25/01/26.
//

import Foundation

final class ProductLookupService {
    static let shared = ProductLookupService()

    private let openFoodFacts = OpenFoodFactsAPI.shared
    private let upcItemDB = UPCItemDBAPI.shared

    private init() {}

    func lookupProduct(barcode: String) async -> ProductInfo? {
        // Try Open Food Facts first (food products)
        if let product = await openFoodFacts.fetchProduct(barcode: barcode) {
            return product
        }

        // Fallback to UPCitemdb (general products)
        if let product = await upcItemDB.fetchProduct(barcode: barcode) {
            return product
        }

        return nil
    }
}
