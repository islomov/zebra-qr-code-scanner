//
//  GenerateView.swift
//  ZebraCodeScanner
//
//  Created by Sardor Islomov on 25/01/26.
//

import SwiftUI

struct GenerateView: View {
    @Binding var showSettings: Bool
    @StateObject private var viewModel = GenerateViewModel()

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // QR Codes Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "qrcode")
                                .foregroundStyle(.tint)
                            Text("QR Codes")
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        .padding(.horizontal)

                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(QRCodeContentType.allCases) { type in
                                NavigationLink {
                                    QRCodeFormView(type: type, viewModel: viewModel)
                                } label: {
                                    QRTypeCard(type: type)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    // 1D Barcodes Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "barcode")
                                .foregroundStyle(.orange)
                            Text("1D Barcodes")
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        .padding(.horizontal)

                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(BarcodeType.barcodes1D) { type in
                                NavigationLink {
                                    BarcodeFormView(type: type, viewModel: viewModel)
                                } label: {
                                    BarcodeTypeCard(type: type)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    // 2D Barcodes Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "square.dashed")
                                .foregroundStyle(.green)
                            Text("2D Barcodes")
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        .padding(.horizontal)

                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(BarcodeType.barcodes2D) { type in
                                NavigationLink {
                                    BarcodeFormView(type: type, viewModel: viewModel)
                                } label: {
                                    BarcodeTypeCard(type: type)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    // Social Media Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "at")
                                .foregroundStyle(.purple)
                            Text("Social Media")
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        .padding(.horizontal)

                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(SocialMediaType.allCases) { type in
                                NavigationLink {
                                    SocialMediaFormView(type: type, viewModel: viewModel)
                                } label: {
                                    SocialMediaTypeCard(type: type)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    // Request Section
                    VStack(spacing: 12) {
                        Image(systemName: "lightbulb")
                            .font(.system(size: 28))
                            .foregroundStyle(.yellow)

                        Text("Need a different code type?")
                            .font(.headline)

                        Text("If you need additional QR codes or barcodes, let us know!")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        Link(destination: URL(string: "mailto:sardor.islomov.96@gmail.com?subject=Code%20Scanner%20-%20Feature%20Request")!) {
                            Label("Send a Request", systemImage: "envelope")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.accentColor)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
                }
                .padding()
            }
            .navigationTitle("Generate")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
    }
}

struct QRTypeCard: View {
    let type: QRCodeContentType

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: type.icon)
                .font(.system(size: 32))
                .foregroundStyle(.tint)

            Text(type.title)
                .font(.headline)
                .foregroundStyle(.primary)

            Text(type.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
}

struct BarcodeTypeCard: View {
    let type: BarcodeType

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: type.icon)
                .font(.system(size: 32))
                .foregroundStyle(.orange)

            Text(type.title)
                .font(.headline)
                .foregroundStyle(.primary)

            Text(type.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
}

struct SocialMediaTypeCard: View {
    let type: SocialMediaType

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: type.icon)
                .font(.system(size: 32))
                .foregroundStyle(.purple)

            Text(type.title)
                .font(.headline)
                .foregroundStyle(.primary)

            Text(type.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    GenerateView(showSettings: .constant(false))
}
