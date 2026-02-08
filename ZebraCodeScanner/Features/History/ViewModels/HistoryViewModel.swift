//
//  HistoryViewModel.swift
//  ZebraCodeScanner
//
//  Created by Sardor Islomov on 25/01/26.
//

import SwiftUI
import Combine

enum HistoryFilterTab: String, CaseIterable {
    case all = "all"
    case generated = "generated"
    case scanned = "scanned"

    var title: String {
        switch self {
        case .all: return String(localized: "history.filter.all", defaultValue: "All")
        case .generated: return String(localized: "history.filter.generated", defaultValue: "Generated")
        case .scanned: return String(localized: "history.filter.scanned", defaultValue: "Scanned")
        }
    }
}

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published var generatedCodes: [GeneratedCodeEntity] = []
    @Published var scannedCodes: [ScannedCodeEntity] = []
    @Published var searchText: String = ""
    @Published var selectedTab: HistoryFilterTab = .all

    private let dataManager = CoreDataManager.shared

    var filteredGeneratedCodes: [GeneratedCodeEntity] {
        let codes = generatedCodes
        if searchText.isEmpty { return codes }
        let search = searchText.lowercased()
        return codes.filter { entity in
            let content = entity.content?.lowercased() ?? ""
            let contentType = entity.contentType?.lowercased() ?? ""
            return content.contains(search) || contentType.contains(search)
        }
    }

    var filteredScannedCodes: [ScannedCodeEntity] {
        let codes = scannedCodes
        if searchText.isEmpty { return codes }
        let search = searchText.lowercased()
        return codes.filter { entity in
            let content = entity.content?.lowercased() ?? ""
            let type = entity.type?.lowercased() ?? ""
            let productName = entity.productName?.lowercased() ?? ""
            return content.contains(search) || type.contains(search) || productName.contains(search)
        }
    }

    var qrCodes: [GeneratedCodeEntity] {
        filteredGeneratedCodes.filter { $0.type == "qr" }
    }

    var barcodes: [GeneratedCodeEntity] {
        filteredGeneratedCodes.filter { $0.type == "barcode" }
    }

    var isEmpty: Bool {
        switch selectedTab {
        case .all:
            return generatedCodes.isEmpty && scannedCodes.isEmpty
        case .generated:
            return generatedCodes.isEmpty
        case .scanned:
            return scannedCodes.isEmpty
        }
    }

    func fetchHistory() {
        generatedCodes = dataManager.fetchGeneratedCodes()
        scannedCodes = dataManager.fetchScannedCodes()
    }

    func deleteGenerated(_ entity: GeneratedCodeEntity) {
        dataManager.deleteGeneratedCode(entity)
        fetchHistory()
    }

    func deleteScanned(_ entity: ScannedCodeEntity) {
        dataManager.deleteScannedCode(entity)
        fetchHistory()
    }

    func deleteAll() {
        dataManager.deleteAllGeneratedCodes()
        dataManager.deleteAllScannedCodes()
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
        return entity.contentType ?? String(localized: "common.unknown", defaultValue: "Unknown")
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

    func getScannedTypeTitle(for entity: ScannedCodeEntity) -> String {
        entity.type?.capitalized ?? String(localized: "common.unknown", defaultValue: "Unknown")
    }

    func getScannedTypeIcon(for entity: ScannedCodeEntity) -> String {
        let type = entity.type?.lowercased() ?? ""
        if type.contains("qr") {
            return "qrcode"
        }
        return "barcode"
    }
}
