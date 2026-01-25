//
//  HistoryViewModel.swift
//  ZebraCodeScanner
//
//  Created by Sardor Islomov on 25/01/26.
//

import SwiftUI
import Combine

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published var generatedCodes: [GeneratedCodeEntity] = []
    @Published var searchText: String = ""

    private let dataManager = CoreDataManager.shared

    var filteredCodes: [GeneratedCodeEntity] {
        if searchText.isEmpty {
            return generatedCodes
        }
        return generatedCodes.filter { entity in
            let content = entity.content?.lowercased() ?? ""
            let contentType = entity.contentType?.lowercased() ?? ""
            let search = searchText.lowercased()
            return content.contains(search) || contentType.contains(search)
        }
    }

    var qrCodes: [GeneratedCodeEntity] {
        filteredCodes.filter { $0.type == "qr" }
    }

    var barcodes: [GeneratedCodeEntity] {
        filteredCodes.filter { $0.type == "barcode" }
    }

    func fetchHistory() {
        generatedCodes = dataManager.fetchGeneratedCodes()
    }

    func delete(_ entity: GeneratedCodeEntity) {
        dataManager.deleteGeneratedCode(entity)
        fetchHistory()
    }

    func deleteAll() {
        dataManager.deleteAllGeneratedCodes()
        fetchHistory()
    }

    func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    func getTypeTitle(for entity: GeneratedCodeEntity) -> String {
        if entity.type == "qr" {
            if let contentType = entity.contentType,
               let qrType = QRCodeContentType(rawValue: contentType) {
                return qrType.title
            }
        } else if entity.type == "barcode" {
            if let contentType = entity.contentType,
               let barcodeType = BarcodeType(rawValue: contentType) {
                return barcodeType.title
            }
        }
        return entity.contentType ?? "Unknown"
    }

    func getTypeIcon(for entity: GeneratedCodeEntity) -> String {
        if entity.type == "qr" {
            if let contentType = entity.contentType,
               let qrType = QRCodeContentType(rawValue: contentType) {
                return qrType.icon
            }
            return "qrcode"
        } else {
            return "barcode"
        }
    }
}
