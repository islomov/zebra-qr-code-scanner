//
//  BarcodeFormView.swift
//  ZebraCodeScanner
//
//  Created by Sardor Islomov on 25/01/26.
//

import SwiftUI

struct BarcodeFormView: View {
    let type: BarcodeType
    @ObservedObject var viewModel: GenerateViewModel
    @State private var showPreview = false
    @FocusState private var isFieldFocused: Bool

    var body: some View {
        Form {
            Section {
                TextField(type.placeholder, text: $viewModel.barcodeContent)
                    .focused($isFieldFocused)
                    .keyboardType(type.allowsLetters ? .default : .numberPad)
                    .autocorrectionDisabled()
                    .padding(.vertical, 4)

                if let requiredLength = type.requiredLength {
                    HStack {
                        Text("Characters")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(viewModel.barcodeContent.filter { $0.isNumber }.count)/\(requiredLength)")
                            .foregroundStyle(isValidLength ? .green : .secondary)
                    }
                    .font(.caption)
                }
            } header: {
                Text("Content")
            } footer: {
                Text(footerText)
            }

            Section {
                Button {
                    viewModel.generateBarcode(for: type)
                    showPreview = true
                } label: {
                    HStack {
                        Spacer()
                        Label("Generate Barcode", systemImage: "barcode")
                            .font(.headline)
                        Spacer()
                    }
                }
                .disabled(!viewModel.isValidBarcode(for: type))
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle(type.title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showPreview) {
            BarcodePreviewView(type: type, viewModel: viewModel)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isFieldFocused = true
            }
        }
        .onDisappear {
            isFieldFocused = false
        }
    }

    private var isValidLength: Bool {
        guard let requiredLength = type.requiredLength else { return true }
        let digitCount = viewModel.barcodeContent.filter { $0.isNumber }.count
        return digitCount == requiredLength || digitCount == requiredLength - 1
    }

    private var footerText: String {
        switch type {
        case .code128:
            return "Code 128 supports letters, numbers, and special characters."
        case .ean13:
            return "Enter 12 or 13 digits. Check digit will be calculated automatically."
        case .ean8:
            return "Enter 7 or 8 digits. Check digit will be calculated automatically."
        case .upca:
            return "Enter 11 or 12 digits. Check digit will be calculated automatically."
        case .aztec:
            return "Aztec codes support text, numbers, and special characters."
        case .pdf417:
            return "PDF417 codes support text, numbers, and special characters."
        }
    }
}

#Preview {
    NavigationStack {
        BarcodeFormView(type: .code128, viewModel: GenerateViewModel())
    }
}
