//
//  HistoryView.swift
//  ZebraCodeScanner
//
//  Created by Sardor Islomov on 25/01/26.
//

import SwiftUI

struct HistoryView: View {
    @Binding var showSettings: Bool
    @StateObject private var viewModel = HistoryViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter tabs
                Picker("Filter", selection: $viewModel.selectedTab) {
                    ForEach(HistoryFilterTab.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 8)

                if viewModel.isEmpty {
                    emptyStateView
                } else {
                    historyListView
                }
            }
            .navigationTitle("History")
            .searchable(text: $viewModel.searchText, prompt: "Search codes")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .onAppear {
                viewModel.fetchHistory()
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 80))
                .foregroundStyle(.tertiary)

            Text("No History Yet")
                .font(.title2)
                .fontWeight(.semibold)

            Text(emptyStateMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
        }
    }

    private var emptyStateMessage: String {
        switch viewModel.selectedTab {
        case .all:
            return "Generated and scanned codes will appear here."
        case .generated:
            return "Generated QR codes and barcodes will appear here."
        case .scanned:
            return "Scanned QR codes and barcodes will appear here."
        }
    }

    private var historyListView: some View {
        List {
            if viewModel.selectedTab != .scanned {
                generatedSections
            }
            if viewModel.selectedTab != .generated {
                scannedSection
            }
        }
        .listStyle(.insetGrouped)
    }

    @ViewBuilder
    private var generatedSections: some View {
        if !viewModel.qrCodes.isEmpty {
            Section("QR Codes") {
                ForEach(viewModel.qrCodes) { entity in
                    NavigationLink {
                        HistoryDetailView(entity: entity)
                    } label: {
                        HistoryRowView(entity: entity, viewModel: viewModel)
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        viewModel.deleteGenerated(viewModel.qrCodes[index])
                    }
                }
            }
        }

        if !viewModel.barcodes.isEmpty {
            Section("Barcodes") {
                ForEach(viewModel.barcodes) { entity in
                    NavigationLink {
                        HistoryDetailView(entity: entity)
                    } label: {
                        HistoryRowView(entity: entity, viewModel: viewModel)
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        viewModel.deleteGenerated(viewModel.barcodes[index])
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var scannedSection: some View {
        if !viewModel.filteredScannedCodes.isEmpty {
            Section("Scanned") {
                ForEach(viewModel.filteredScannedCodes) { entity in
                    NavigationLink {
                        ScannedDetailView(entity: entity)
                    } label: {
                        ScannedRowView(entity: entity, viewModel: viewModel)
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        viewModel.deleteScanned(viewModel.filteredScannedCodes[index])
                    }
                }
            }
        }
    }
}

struct HistoryRowView: View {
    let entity: GeneratedCodeEntity
    let viewModel: HistoryViewModel

    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail
            if let image = entity.image {
                Image(uiImage: image)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray5))
                    .frame(width: 50, height: 50)
                    .overlay {
                        Image(systemName: viewModel.getTypeIcon(for: entity))
                            .foregroundStyle(.secondary)
                    }
            }

            // Details
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: viewModel.getTypeIcon(for: entity))
                        .font(.caption)
                        .foregroundStyle(.tint)
                    Text(viewModel.getTypeTitle(for: entity))
                        .font(.subheadline)
                        .fontWeight(.medium)
                }

                Text(entity.content ?? "")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Text(viewModel.formatDate(entity.createdAt))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct ScannedRowView: View {
    let entity: ScannedCodeEntity
    let viewModel: HistoryViewModel

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray5))
                .frame(width: 50, height: 50)
                .overlay {
                    Image(systemName: viewModel.getScannedTypeIcon(for: entity))
                        .foregroundStyle(.secondary)
                }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: viewModel.getScannedTypeIcon(for: entity))
                        .font(.caption)
                        .foregroundStyle(.tint)
                    Text(viewModel.getScannedTypeTitle(for: entity))
                        .font(.subheadline)
                        .fontWeight(.medium)
                }

                if let productName = entity.productName, !productName.isEmpty {
                    Text(productName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                } else {
                    Text(entity.content ?? "")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Text(viewModel.formatDate(entity.scannedAt))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView(showSettings: .constant(false))
    }
}
