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
            Text(type.is2D ? String(localized: "generate.section.2d_barcodes", defaultValue: "2D Barcodes") : String(localized: "generate.section.1d_barcodes", defaultValue: "1D Barcodes"))
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
            return String(localized: "barcode_form.placeholder.text_or_numbers", defaultValue: "Enter text or numbers")
        case .ean13:
            return String(localized: "barcode_form.placeholder.enter_13_digits", defaultValue: "Enter 13 digits")
        case .ean8:
            return String(localized: "barcode_form.placeholder.enter_8_digits", defaultValue: "Enter 8 digits")
        case .upca:
            return String(localized: "barcode_form.placeholder.enter_12_digits", defaultValue: "Enter 12 digits")
        case .aztec:
            return String(localized: "barcode_form.placeholder.text_or_numbers", defaultValue: "Enter text or numbers")
        case .pdf417:
            return String(localized: "barcode_form.placeholder.text_or_numbers", defaultValue: "Enter text or numbers")
        }
    }

    private var footerText: String {
        switch type {
        case .code128:
            return String(localized: "barcode_form.footer.code128", defaultValue: "Code 128 supports letters, numbers, and special characters")
        case .ean13:
            return String(localized: "barcode_form.footer.ean13", defaultValue: "Enter 12 or 13 digits. Check digit will be calculated automatically")
        case .ean8:
            return String(localized: "barcode_form.footer.ean8", defaultValue: "Enter 7 or 8 digits. Check digit will be calculated automatically")
        case .upca:
            return String(localized: "barcode_form.footer.upca", defaultValue: "Enter 11 or 12 digits. Check digit will be calculated automatically")
        case .aztec:
            return String(localized: "barcode_form.footer.aztec", defaultValue: "Aztec codes support text, numbers, and special characters")
        case .pdf417:
            return String(localized: "barcode_form.footer.pdf417", defaultValue: "PDF417 codes support text, numbers, and special characters")
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

                Text(String(localized: "barcode_form.button.generate", defaultValue: "Generate Barcode"))
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
