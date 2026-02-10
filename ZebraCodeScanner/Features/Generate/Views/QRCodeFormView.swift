//
//  QRCodeFormView.swift
//  ZebraCodeScanner
//
//  Created by Sardor Islomov on 25/01/26.
//

import SwiftUI
import ContactsUI

struct QRCodeFormView: View {
    let type: QRCodeContentType
    @ObservedObject var viewModel: GenerateViewModel
    @State private var showPreview = false
    @State private var showContactPicker = false
    @State private var showValidationError = false
    @FocusState private var focusedField: String?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Custom Navigation Header
                navigationHeader

                // Section header + fields
                VStack(alignment: .leading, spacing: 8) {
                    sectionHeader
                    formFields
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
            QRCodePreviewView(type: type, viewModel: viewModel)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                focusedField = firstFieldKey
            }
        }
        .onDisappear {
            focusedField = nil
        }
    }

    // MARK: - Navigation Header

    private var navigationHeader: some View {
        ZStack {
            Text(String(localized: "generate.section.qr_codes", defaultValue: "QR Codes"))
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
            Image(iconName)
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

    // MARK: - Icon Name

    private var iconName: String {
        switch type {
        case .text: return "icon-text"
        case .url: return "icon-link"
        case .phone: return "icon-phone"
        case .email: return "icon-email"
        case .wifi: return "icon-wifi"
        case .vcard: return "icon-contact"
        case .sms: return "icon-sms"
        case .geo: return "icon-location"
        case .crypto: return "icon-crypto"
        case .event: return "icon-event"
        }
    }

    // MARK: - First Field Key

    private var firstFieldKey: String {
        switch type {
        case .text: return "text"
        case .url: return "url"
        case .phone: return "phone"
        case .email: return "emailTo"
        case .wifi: return "wifiSSID"
        case .vcard: return "vcardName"
        case .sms: return "smsPhone"
        case .geo: return "geoLatitude"
        case .crypto: return "cryptoAddress"
        case .event: return "eventTitle"
        }
    }

    // MARK: - Form Fields

    @ViewBuilder
    private var formFields: some View {
        switch type {
        case .text:
            textFields
        case .url:
            urlFields
        case .phone:
            phoneFields
        case .email:
            emailFields
        case .wifi:
            wifiFields
        case .vcard:
            vcardFields
        case .sms:
            smsFields
        case .geo:
            geoFields
        case .crypto:
            cryptoFields
        case .event:
            eventFields
        }
    }

    // MARK: - Text Form

    private var textFields: some View {
        customTextEditor(
            text: $viewModel.text,
            placeholder: String(localized: "qr_form.placeholder.enter_text", defaultValue: "Enter text"),
            fieldKey: "text",
            isRequired: true
        )
        .padding(.horizontal, 16)
    }

    // MARK: - URL Form

    private var urlFields: some View {
        customTextField(
            text: $viewModel.url,
            placeholder: String(localized: "qr_form.placeholder.example_url", defaultValue: "Example.com"),
            fieldKey: "url",
            isRequired: true,
            keyboardType: .URL,
            contentType: .URL,
            autocapitalization: false
        )
        .padding(.horizontal, 16)
    }

    // MARK: - Phone Form

    private var phoneFields: some View {
        customTextField(
            text: $viewModel.phone,
            placeholder: String(localized: "qr_form.placeholder.phone", defaultValue: "+123 456 789"),
            fieldKey: "phone",
            isRequired: true,
            keyboardType: .phonePad,
            contentType: .telephoneNumber
        )
        .padding(.horizontal, 16)
    }

    // MARK: - Email Form

    private var emailFields: some View {
        VStack(spacing: 8) {
            customTextField(
                text: $viewModel.emailTo,
                placeholder: String(localized: "qr_form.placeholder.email", defaultValue: "Forexample@gmail.com"),
                fieldKey: "emailTo",
                isRequired: true,
                keyboardType: .emailAddress,
                contentType: .emailAddress,
                autocapitalization: false
            )

            customTextField(
                text: $viewModel.emailSubject,
                placeholder: String(localized: "qr_form.placeholder.subject_optional", defaultValue: "Subject (Optional)"),
                fieldKey: "emailSubject",
                isRequired: false
            )

            customTextEditor(
                text: $viewModel.emailBody,
                placeholder: String(localized: "qr_form.placeholder.message", defaultValue: "Message"),
                fieldKey: "emailBody",
                isRequired: false
            )
        }
        .padding(.horizontal, 16)
    }

    // MARK: - WiFi Form

    private var wifiFields: some View {
        VStack(spacing: 12) {
            customTextField(
                text: $viewModel.wifiSSID,
                placeholder: String(localized: "qr_form.placeholder.wifi_name", defaultValue: "Wi-Fi Name (SSD)"),
                fieldKey: "wifiSSID",
                isRequired: true,
                autocapitalization: false
            )

            wifiSecurityToggle

            if viewModel.wifiSecurity != .none {
                customTextField(
                    text: $viewModel.wifiPassword,
                    placeholder: String(localized: "qr_form.placeholder.wifi_password", defaultValue: "Wi-Fi Password"),
                    fieldKey: "wifiPassword",
                    isRequired: false,
                    isSecure: true
                )
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - WiFi Security Toggle

    private var wifiSecurityToggle: some View {
        HStack(spacing: 0) {
            ForEach(WiFiSecurityType.allCases) { security in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.wifiSecurity = security
                    }
                } label: {
                    Text(security.title)
                        .font(.custom("Inter-Regular", size: 14))
                        .tracking(-0.408)
                        .foregroundStyle(DesignColors.primaryText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background(
                            viewModel.wifiSecurity == security
                            ? DesignColors.cardBackground
                            : Color.clear
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(
                            color: viewModel.wifiSecurity == security
                            ? Color.black.opacity(0.08) : Color.clear,
                            radius: 4, y: 2
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(DesignColors.lightText)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - vCard Form

    private var vcardFields: some View {
        VStack(spacing: 8) {
            // Import from Contacts button
            Button {
                showContactPicker = true
            } label: {
                HStack(spacing: 10) {
                    Image("icon-contact")
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color(red: 0x27/255, green: 0x61/255, blue: 0xF4/255))

                    Text(String(localized: "qr_form.button.import_contacts", defaultValue: "Import from Contacts"))
                        .font(.custom("Inter-Regular", size: 14))
                        .tracking(-0.408)
                        .foregroundStyle(Color(red: 0x27/255, green: 0x61/255, blue: 0xF4/255))

                    Spacer()
                }
                .padding(20)
                .frame(height: 58)
                .background(DesignColors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(DesignColors.stroke, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)
            .sheet(isPresented: $showContactPicker) {
                ContactPickerView { contact in
                    viewModel.vcardName = [contact.givenName, contact.familyName]
                        .filter { !$0.isEmpty }
                        .joined(separator: " ")
                    if let phone = contact.phoneNumbers.first?.value.stringValue {
                        viewModel.vcardPhone = phone
                    }
                    if let email = contact.emailAddresses.first?.value as String? {
                        viewModel.vcardEmail = email
                    }
                    viewModel.vcardCompany = contact.organizationName
                }
            }

            customTextField(
                text: $viewModel.vcardName,
                placeholder: String(localized: "qr_form.placeholder.full_name", defaultValue: "Full name"),
                fieldKey: "vcardName",
                isRequired: true,
                contentType: .name
            )

            customTextField(
                text: $viewModel.vcardPhone,
                placeholder: String(localized: "qr_form.placeholder.phone_optional", defaultValue: "Phone (Optional)"),
                fieldKey: "vcardPhone",
                isRequired: false,
                keyboardType: .phonePad,
                contentType: .telephoneNumber
            )

            customTextField(
                text: $viewModel.vcardEmail,
                placeholder: String(localized: "qr_form.placeholder.email_optional", defaultValue: "Email (Optional)"),
                fieldKey: "vcardEmail",
                isRequired: false,
                keyboardType: .emailAddress,
                contentType: .emailAddress,
                autocapitalization: false
            )

            customTextField(
                text: $viewModel.vcardCompany,
                placeholder: String(localized: "qr_form.placeholder.company_optional", defaultValue: "Company name (Optional)"),
                fieldKey: "vcardCompany",
                isRequired: false,
                contentType: .organizationName
            )
        }
        .padding(.horizontal, 16)
    }

    // MARK: - SMS Form

    private var smsFields: some View {
        VStack(spacing: 8) {
            customTextField(
                text: $viewModel.smsPhone,
                placeholder: String(localized: "qr_form.placeholder.sms_phone", defaultValue: "+123 456 789"),
                fieldKey: "smsPhone",
                isRequired: true,
                keyboardType: .phonePad,
                contentType: .telephoneNumber
            )

            customTextEditor(
                text: $viewModel.smsMessage,
                placeholder: String(localized: "qr_form.placeholder.message_optional", defaultValue: "Message (Optional)"),
                fieldKey: "smsMessage",
                isRequired: false
            )
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Geo Form

    private var geoFields: some View {
        VStack(spacing: 8) {
            customTextField(
                text: $viewModel.geoLatitude,
                placeholder: String(localized: "qr_form.placeholder.latitude", defaultValue: "Latitude (e.g. 40.7128)"),
                fieldKey: "geoLatitude",
                isRequired: true,
                keyboardType: .decimalPad
            )

            customTextField(
                text: $viewModel.geoLongitude,
                placeholder: String(localized: "qr_form.placeholder.longitude", defaultValue: "Longitude (e.g. -74.0060)"),
                fieldKey: "geoLongitude",
                isRequired: true,
                keyboardType: .decimalPad
            )

            customTextField(
                text: $viewModel.geoLabel,
                placeholder: String(localized: "qr_form.placeholder.location_label", defaultValue: "Label (Optional)"),
                fieldKey: "geoLabel",
                isRequired: false
            )
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Crypto Form

    private var cryptoFields: some View {
        VStack(spacing: 12) {
            cryptoCurrencyToggle

            customTextField(
                text: $viewModel.cryptoAddress,
                placeholder: String(localized: "qr_form.placeholder.crypto_address", defaultValue: "Wallet address"),
                fieldKey: "cryptoAddress",
                isRequired: true,
                autocapitalization: false
            )
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Crypto Currency Toggle

    private var cryptoCurrencyToggle: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(CryptoCurrencyType.allCases) { currency in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.cryptoCurrency = currency
                        }
                    } label: {
                        Text(currency.title)
                            .font(.custom("Inter-Regular", size: 13))
                            .tracking(-0.408)
                            .foregroundStyle(DesignColors.primaryText)
                            .padding(.horizontal, 12)
                            .frame(height: 36)
                            .background(
                                viewModel.cryptoCurrency == currency
                                ? DesignColors.cardBackground
                                : Color.clear
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .shadow(
                                color: viewModel.cryptoCurrency == currency
                                ? Color.black.opacity(0.08) : Color.clear,
                                radius: 4, y: 2
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(4)
        }
        .fixedSize(horizontal: false, vertical: true)
        .background(DesignColors.lightText)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Event Form

    private var eventFields: some View {
        VStack(spacing: 8) {
            customTextField(
                text: $viewModel.eventTitle,
                placeholder: String(localized: "qr_form.placeholder.event_title", defaultValue: "Event title"),
                fieldKey: "eventTitle",
                isRequired: true
            )

            eventDatePicker(
                label: String(localized: "qr_form.label.start_date", defaultValue: "Start"),
                date: $viewModel.eventStartDate
            )

            eventDatePicker(
                label: String(localized: "qr_form.label.end_date", defaultValue: "End"),
                date: $viewModel.eventEndDate
            )

            customTextField(
                text: $viewModel.eventLocation,
                placeholder: String(localized: "qr_form.placeholder.event_location", defaultValue: "Location (Optional)"),
                fieldKey: "eventLocation",
                isRequired: false
            )

            customTextEditor(
                text: $viewModel.eventDescription,
                placeholder: String(localized: "qr_form.placeholder.event_description", defaultValue: "Description (Optional)"),
                fieldKey: "eventDescription",
                isRequired: false
            )
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Event Date Picker

    private func eventDatePicker(label: String, date: Binding<Date>) -> some View {
        HStack {
            Text(label)
                .font(.custom("Inter-Regular", size: 14))
                .tracking(-0.408)
                .foregroundStyle(DesignColors.secondaryText)

            Spacer()

            DatePicker("", selection: date)
                .labelsHidden()
                .tint(DesignColors.primaryText)
        }
        .padding(.horizontal, 20)
        .frame(height: 58)
        .background(DesignColors.cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(DesignColors.stroke, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Generate Button

    private var generateButton: some View {
        Button {
            if viewModel.isValid(for: type) {
                showValidationError = false
                viewModel.generateQRCode(for: type)
                showPreview = true
            } else {
                showValidationError = true
            }
        } label: {
            HStack(spacing: 8) {
                Image("icon-qr")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundStyle(DesignColors.primaryButtonText)

                Text(String(localized: "qr_form.button.generate", defaultValue: "Generate QR Code"))
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

    // MARK: - Custom Input Components

    private func customTextField(
        text: Binding<String>,
        placeholder: String,
        fieldKey: String,
        isRequired: Bool,
        keyboardType: UIKeyboardType = .default,
        contentType: UITextContentType? = nil,
        autocapitalization: Bool = true,
        isSecure: Bool = false
    ) -> some View {
        let hasError = showValidationError && isRequired && text.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let isFocused = focusedField == fieldKey

        let borderColor: Color = hasError
            ? Color(red: 0xFF/255, green: 0x3B/255, blue: 0x30/255)
            : (isFocused ? DesignColors.primaryText : DesignColors.stroke)

        return ZStack {
            if isSecure {
                SecureField("", text: text, prompt: Text(placeholder)
                    .foregroundColor(DesignColors.secondaryText))
                    .font(.custom("Inter-Regular", size: 14))
                    .tracking(-0.408)
                    .foregroundStyle(DesignColors.primaryText)
                    .focused($focusedField, equals: fieldKey)
            } else {
                TextField("", text: text, prompt: Text(placeholder)
                    .foregroundColor(DesignColors.secondaryText))
                    .font(.custom("Inter-Regular", size: 14))
                    .tracking(-0.408)
                    .foregroundStyle(DesignColors.primaryText)
                    .focused($focusedField, equals: fieldKey)
                    .keyboardType(keyboardType)
                    .textContentType(contentType)
                    .autocapitalization(autocapitalization ? .sentences : .none)
                    .autocorrectionDisabled(!autocapitalization)
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

    private func customTextEditor(
        text: Binding<String>,
        placeholder: String,
        fieldKey: String,
        isRequired: Bool
    ) -> some View {
        let hasError = showValidationError && isRequired && text.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let isFocused = focusedField == fieldKey

        let borderColor: Color = hasError
            ? Color(red: 0xFF/255, green: 0x3B/255, blue: 0x30/255)
            : (isFocused ? DesignColors.primaryText : DesignColors.stroke)

        return ZStack(alignment: .topLeading) {
            if text.wrappedValue.isEmpty {
                Text(placeholder)
                    .font(.custom("Inter-Regular", size: 14))
                    .tracking(-0.408)
                    .foregroundStyle(DesignColors.secondaryText)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
            }

            TextEditor(text: text)
                .font(.custom("Inter-Regular", size: 14))
                .tracking(-0.408)
                .foregroundStyle(DesignColors.primaryText)
                .focused($focusedField, equals: fieldKey)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
        }
        .frame(height: 120)
        .background(DesignColors.cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(borderColor, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct QRCodeFormView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            QRCodeFormView(type: .wifi, viewModel: GenerateViewModel())
        }
    }
}
