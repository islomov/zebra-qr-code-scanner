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
    @State private var showValidationError = false
    @FocusState private var isFieldFocused: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Custom Navigation Header
                navigationHeader

                // Section header + fields
                VStack(alignment: .leading, spacing: 8) {
                    sectionHeader
                    inputSection
                }

                // Generate button
                generateButton
                    .padding(.top, 24)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .background(DesignColors.background)
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showPreview) {
            BarcodePreviewView(type: type, viewModel: viewModel)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isFieldFocused = true
            }
        }
        .onDisappear {
            isFieldFocused = false
        }
    }

    // MARK: - Navigation Header

    private var navigationHeader: some View {
        ZStack {
            Text(type.is2D ? "2D Barcodes" : "1D Barcodes")
                .font(.custom("Inter-SemiBold", size: 20))
                .tracking(-0.408)
                .foregroundStyle(DesignColors.primaryText)

            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(DesignColors.primaryText)
                        .frame(width: 44, height: 44)
                        .background(DesignColors.cardBackground)
                        .clipShape(Circle())
                }

                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 16)
    }

    // MARK: - Section Header

    private var sectionHeader: some View {
        HStack(spacing: 8) {
            Image(sectionIconName)
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundStyle(DesignColors.primaryText)

            Text(type.title)
                .font(.custom("Inter-SemiBold", size: 20))
                .tracking(-0.408)
                .foregroundStyle(DesignColors.primaryText)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    private var sectionIconName: String {
        switch type {
        case .aztec: return "icon-aztec"
        case .pdf417: return "icon-pdf417"
        default: return "icon-barcode1d"
        }
    }

    // MARK: - Input Section

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            inputField

            Text(footerText)
                .font(.custom("Inter-Regular", size: 14))
                .tracking(-0.408)
                .foregroundStyle(DesignColors.secondaryText)
                .padding(.horizontal, 20)
                .padding(.top, 8)
        }
        .padding(.horizontal, 16)
    }

    private var inputField: some View {
        let hasError = showValidationError && viewModel.barcodeContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let borderColor: Color = hasError
            ? Color(red: 0xFF/255, green: 0x3B/255, blue: 0x30/255)
            : (isFieldFocused ? DesignColors.primaryText : DesignColors.stroke)

        return HStack {
            TextField("", text: $viewModel.barcodeContent, prompt: Text(placeholderText)
                .foregroundColor(DesignColors.secondaryText))
                .font(.custom("Inter-Regular", size: 14))
                .tracking(-0.408)
                .foregroundStyle(DesignColors.primaryText)
                .focused($isFieldFocused)
                .keyboardType(type.allowsLetters ? .default : .numberPad)
                .autocorrectionDisabled()

            if let requiredLength = type.requiredLength {
                Text("\(digitCount)/\(requiredLength)")
                    .font(.custom("Inter-Regular", size: 14))
                    .tracking(-0.408)
                    .foregroundStyle(DesignColors.secondaryText)
            }
        }
        .padding(20)
        .frame(height: 58)
        .background(DesignColors.cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(borderColor, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var digitCount: Int {
        viewModel.barcodeContent.filter { $0.isNumber }.count
    }

    private var placeholderText: String {
        switch type {
        case .code128:
            return "Enter text or numbers"
        case .ean13:
            return "Enter 13 digits"
        case .ean8:
            return "Enter 8 digits"
        case .upca:
            return "Enter 12 digits"
        case .aztec:
            return "Enter text or numbers"
        case .pdf417:
            return "Enter text or numbers"
        }
    }

    private var footerText: String {
        switch type {
        case .code128:
            return "Code 128 supports letters, numbers, and special characters"
        case .ean13:
            return "Enter 12 or 13 digits. Check digit will be calculated automatically"
        case .ean8:
            return "Enter 7 or 8 digits. Check digit will be calculated automatically"
        case .upca:
            return "Enter 11 or 12 digits. Check digit will be calculated automatically"
        case .aztec:
            return "Aztec codes support text, numbers, and special characters"
        case .pdf417:
            return "PDF417 codes support text, numbers, and special characters"
        }
    }

    // MARK: - Generate Button

    private var generateButton: some View {
        Button {
            if viewModel.isValidBarcode(for: type) {
                showValidationError = false
                viewModel.generateBarcode(for: type)
                showPreview = true
            } else {
                showValidationError = true
            }
        } label: {
            HStack(spacing: 8) {
                Image("icon-barcode1d")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundStyle(DesignColors.primaryButtonText)

                Text("Generate Barcode")
                    .font(.custom("Inter-Medium", size: 16))
                    .tracking(-0.408)
                    .foregroundStyle(DesignColors.primaryButtonText)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 51)
            .background(DesignColors.primaryText)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
    }
}

struct BarcodeFormView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            BarcodeFormView(type: .ean13, viewModel: GenerateViewModel())
        }
    }
}
