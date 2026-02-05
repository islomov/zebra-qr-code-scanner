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
    @Namespace private var tabAnimation

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                historyHeader
                    .padding(.bottom, 8)

                // Search bar
                searchBar
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)

                // Filter tabs
                filterPicker
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)

                if viewModel.isEmpty {
                    emptyStateView
                } else {
                    historyListView
                }
            }
            .background(DesignColors.background)
            .navigationBarHidden(true)
            .onAppear {
                viewModel.fetchHistory()
            }
        }
    }

    // MARK: - Header

    private var historyHeader: some View {
        HStack {
            Text("History")
                .font(.custom("Inter-SemiBold", size: 28))
                .tracking(-0.408)
                .foregroundStyle(DesignColors.primaryText)

            Spacer()

            Button {
                showSettings = true
            } label: {
                Image("icon-setting")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundStyle(DesignColors.primaryText)
                    .frame(width: 44, height: 44)
                    .background(DesignColors.cardBackground)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18))
                .foregroundStyle(DesignColors.secondaryText)

            TextField("Search codes", text: $viewModel.searchText)
                .font(.custom("Inter-Regular", size: 14))
                .tracking(-0.408)
                .foregroundStyle(DesignColors.primaryText)
                .frame(maxWidth: .infinity)

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(DesignColors.secondaryText)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(DesignColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Filter Picker

    private var filterPicker: some View {
        HStack(spacing: 0) {
            ForEach(HistoryFilterTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        viewModel.selectedTab = tab
                    }
                } label: {
                    Text(tab.rawValue)
                        .font(.custom("Inter-Regular", size: 14))
                        .tracking(-0.408)
                        .foregroundStyle(DesignColors.primaryText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background {
                            if viewModel.selectedTab == tab {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(DesignColors.primaryButtonText)
                                    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 0)
                                    .matchedGeometryEffect(id: "historyTab", in: tabAnimation)
                            }
                        }
                }
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(DesignColors.lightText)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(DesignColors.stroke, lineWidth: 1)
                )
        )
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 20))
                .foregroundStyle(DesignColors.inactive)
                .frame(width: 44, height: 44)
                .background(DesignColors.lightText)
                .clipShape(Circle())

            VStack(spacing: 8) {
                Text("No history yet")
                    .font(.custom("Inter-SemiBold", size: 18))
                    .tracking(-0.408)
                    .foregroundStyle(DesignColors.primaryText)

                Text(emptyStateMessage)
                    .font(.custom("Inter-Regular", size: 14))
                    .tracking(-0.408)
                    .foregroundStyle(DesignColors.secondaryText)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
    }

    private var emptyStateMessage: String {
        switch viewModel.selectedTab {
        case .all:
            return "Generated and scanned codes will appear here"
        case .generated:
            return "Generated QR codes and barcodes will appear here"
        case .scanned:
            return "Scanned QR codes and barcodes will appear here"
        }
    }

    // MARK: - History List

    private var historyListView: some View {
        ScrollView {
            VStack(spacing: 0) {
                if viewModel.selectedTab != .scanned {
                    generatedSections
                }
                if viewModel.selectedTab != .generated {
                    scannedSection
                }
            }
            .padding(.bottom, 20)
        }
    }

    @ViewBuilder
    private var generatedSections: some View {
        if !viewModel.qrCodes.isEmpty {
            sectionHeader(icon: "icon-qr", title: "QR Codes")

            VStack(spacing: 0) {
                ForEach(Array(viewModel.qrCodes.enumerated()), id: \.element.id) { index, entity in
                    NavigationLink {
                        HistoryDetailView(entity: entity)
                    } label: {
                        HistoryRowView(entity: entity, viewModel: viewModel)
                    }
                    .buttonStyle(.plain)

                    if index < viewModel.qrCodes.count - 1 {
                        Divider()
                            .background(DesignColors.stroke)
                            .padding(.horizontal, 16)
                    }
                }
            }
            .background(DesignColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }

        if !viewModel.barcodes.isEmpty {
            sectionHeader(icon: "icon-barcode1d", title: "Barcodes")

            VStack(spacing: 0) {
                ForEach(Array(viewModel.barcodes.enumerated()), id: \.element.id) { index, entity in
                    NavigationLink {
                        HistoryDetailView(entity: entity)
                    } label: {
                        HistoryRowView(entity: entity, viewModel: viewModel)
                    }
                    .buttonStyle(.plain)

                    if index < viewModel.barcodes.count - 1 {
                        Divider()
                            .background(DesignColors.stroke)
                            .padding(.horizontal, 16)
                    }
                }
            }
            .background(DesignColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
    }

    @ViewBuilder
    private var scannedSection: some View {
        if !viewModel.filteredScannedCodes.isEmpty {
            scannedSectionHeader

            VStack(spacing: 0) {
                ForEach(Array(viewModel.filteredScannedCodes.enumerated()), id: \.element.id) { index, entity in
                    NavigationLink {
                        ScannedDetailView(entity: entity)
                    } label: {
                        ScannedRowView(entity: entity, viewModel: viewModel)
                    }
                    .buttonStyle(.plain)

                    if index < viewModel.filteredScannedCodes.count - 1 {
                        Divider()
                            .background(DesignColors.stroke)
                            .padding(.horizontal, 16)
                    }
                }
            }
            .background(DesignColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
    }

    // MARK: - Section Headers

    private var scannedSectionHeader: some View {
        HStack(spacing: 8) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 18))
                .foregroundStyle(DesignColors.primaryText)
                .frame(width: 24, height: 24)

            Text("Scanned")
                .font(.custom("Inter-Medium", size: 16))
                .tracking(-0.408)
                .foregroundStyle(DesignColors.primaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    private func sectionHeader(icon: String, title: String) -> some View {
        HStack(spacing: 8) {
            Image(icon)
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundStyle(DesignColors.primaryText)

            Text(title)
                .font(.custom("Inter-Medium", size: 16))
                .tracking(-0.408)
                .foregroundStyle(DesignColors.primaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }
}

// MARK: - History Row View (Generated Codes)

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
                    .frame(width: 58, height: 58)
                    .background(DesignColors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(DesignColors.lightText)
                    .frame(width: 58, height: 58)
                    .overlay {
                        Image(systemName: viewModel.getTypeIcon(for: entity))
                            .foregroundStyle(DesignColors.secondaryText)
                    }
            }

            // Details
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Image(iconName(for: entity))
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16, height: 16)
                        .foregroundStyle(DesignColors.primaryText)

                    Text(viewModel.getTypeTitle(for: entity))
                        .font(.custom("Inter-Regular", size: 14))
                        .tracking(-0.408)
                        .foregroundStyle(DesignColors.primaryText)
                }

                VStack(alignment: .leading, spacing: 0) {
                    Text(entity.content ?? "")
                        .font(.custom("Inter-Regular", size: 12))
                        .tracking(-0.408)
                        .foregroundStyle(DesignColors.secondaryText)
                        .lineLimit(1)

                    Text(viewModel.formatDate(entity.createdAt))
                        .font(.custom("Inter-Regular", size: 12))
                        .tracking(-0.408)
                        .foregroundStyle(DesignColors.secondaryText)
                }
            }

            Spacer()

            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(DesignColors.secondaryText)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }

    private func iconName(for entity: GeneratedCodeEntity) -> String {
        if entity.type == "qr" {
            if let contentType = entity.contentType {
                switch contentType {
                case "text": return "icon-text"
                case "url": return "icon-link"
                case "phone": return "icon-phone"
                case "email": return "icon-email"
                case "wifi": return "icon-wifi"
                case "vcard": return "icon-contact"
                case "sms": return "icon-sms"
                default: return "icon-qr"
                }
            }
            return "icon-qr"
        } else {
            return "icon-barcode1d"
        }
    }
}

// MARK: - Scanned Row View

struct ScannedRowView: View {
    let entity: ScannedCodeEntity
    let viewModel: HistoryViewModel

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(DesignColors.lightText)
                .frame(width: 58, height: 58)
                .overlay {
                    Image(systemName: viewModel.getScannedTypeIcon(for: entity))
                        .font(.system(size: 20))
                        .foregroundStyle(DesignColors.secondaryText)
                }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Image(systemName: viewModel.getScannedTypeIcon(for: entity))
                        .font(.system(size: 14))
                        .foregroundStyle(DesignColors.primaryText)

                    Text(viewModel.getScannedTypeTitle(for: entity))
                        .font(.custom("Inter-Regular", size: 14))
                        .tracking(-0.408)
                        .foregroundStyle(DesignColors.primaryText)
                }

                VStack(alignment: .leading, spacing: 0) {
                    if let productName = entity.productName, !productName.isEmpty {
                        Text(productName)
                            .font(.custom("Inter-Regular", size: 12))
                            .tracking(-0.408)
                            .foregroundStyle(DesignColors.secondaryText)
                            .lineLimit(1)
                    } else {
                        Text(entity.content ?? "")
                            .font(.custom("Inter-Regular", size: 12))
                            .tracking(-0.408)
                            .foregroundStyle(DesignColors.secondaryText)
                            .lineLimit(1)
                    }

                    Text(viewModel.formatDate(entity.scannedAt))
                        .font(.custom("Inter-Regular", size: 12))
                        .tracking(-0.408)
                        .foregroundStyle(DesignColors.secondaryText)
                }
            }

            Spacer()

            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(DesignColors.secondaryText)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView(showSettings: .constant(false))
    }
}
