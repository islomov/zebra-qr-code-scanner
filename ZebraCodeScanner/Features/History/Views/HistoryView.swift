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
            Group {
                if viewModel.generatedCodes.isEmpty {
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
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 80))
                .foregroundStyle(.tertiary)

            Text("No History Yet")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Generated QR codes and barcodes will appear here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }

    private var historyListView: some View {
        List {
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
                            viewModel.delete(viewModel.qrCodes[index])
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
                            viewModel.delete(viewModel.barcodes[index])
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
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

#Preview {
    HistoryView(showSettings: .constant(false))
}
