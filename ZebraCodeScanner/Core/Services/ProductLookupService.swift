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
    private let openFDADrug = OpenFDADrugAPI.shared
    private let upcItemDB = UPCItemDBAPI.shared

    private init() {}

    func lookupProduct(barcode: String) async -> ProductInfo? {
        print("[Lookup] Looking up barcode: \(barcode) (length: \(barcode.count))")

        // Try Open Food Facts first (food products, good international coverage)
        print("[Lookup] Trying Open Food Facts...")
        if let product = await openFoodFacts.fetchProduct(barcode: barcode) {
            print("[Lookup] Found via Open Food Facts: \(product.name)")
            return product
        }
        print("[Lookup] Open Food Facts: not found")

        // Try OpenFDA for drug/medicine barcodes (UPC starting with "3")
        print("[Lookup] Trying OpenFDA...")
        if let product = await openFDADrug.fetchProduct(barcode: barcode) {
            print("[Lookup] Found via OpenFDA: \(product.name)")
            return product
        }
        print("[Lookup] OpenFDA: not found")

        // Fallback to UPCitemdb paid (comprehensive product database)
        print("[Lookup] Trying UPCitemdb...")
        if let product = await upcItemDB.fetchProduct(barcode: barcode) {
            print("[Lookup] Found via UPCitemdb: \(product.name)")
            return product
        }
        print("[Lookup] UPCitemdb: not found")

        print("[Lookup] No product found for barcode: \(barcode)")
        return nil
    }
}
