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
    @FocusState private var isFieldFocused: Bool

    var body: some View {
        Form {
            formContent

            Section {
                Button {
                    viewModel.generateQRCode(for: type)
                    showPreview = true
                } label: {
                    HStack {
                        Spacer()
                        Label("Generate QR Code", systemImage: "qrcode")
                            .font(.headline)
                        Spacer()
                    }
                }
                .disabled(!viewModel.isValid(for: type))
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle(type.title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showPreview) {
            QRCodePreviewView(type: type, viewModel: viewModel)
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

    @ViewBuilder
    private var formContent: some View {
        switch type {
        case .text:
            textForm
        case .url:
            urlForm
        case .phone:
            phoneForm
        case .email:
            emailForm
        case .wifi:
            wifiForm
        case .vcard:
            vcardForm
        case .sms:
            smsForm
        }
    }

    // MARK: - Text Form

    private var textForm: some View {
        Section("Content") {
            TextField("Enter text", text: $viewModel.text, axis: .vertical)
                .focused($isFieldFocused)
                .lineLimit(5...10)
                .padding(.vertical, 4)
        }
    }

    // MARK: - URL Form

    private var urlForm: some View {
        Section("Website URL") {
            TextField("example.com", text: $viewModel.url)
                .focused($isFieldFocused)
                .keyboardType(.URL)
                .textContentType(.URL)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .padding(.vertical, 4)
        }
    }

    // MARK: - Phone Form

    private var phoneForm: some View {
        Section("Phone Number") {
            TextField("+1 234 567 8900", text: $viewModel.phone)
                .focused($isFieldFocused)
                .keyboardType(.phonePad)
                .textContentType(.telephoneNumber)
                .padding(.vertical, 4)
        }
    }

    // MARK: - Email Form

    private var emailForm: some View {
        Group {
            Section("Recipient") {
                TextField("email@example.com", text: $viewModel.emailTo)
                    .focused($isFieldFocused)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .padding(.vertical, 4)
            }

            Section("Subject (Optional)") {
                TextField("Subject", text: $viewModel.emailSubject)
                    .padding(.vertical, 4)
            }

            Section("Message (Optional)") {
                TextField("Message", text: $viewModel.emailBody, axis: .vertical)
                    .lineLimit(3...6)
                    .padding(.vertical, 4)
            }
        }
    }

    // MARK: - WiFi Form

    private var wifiForm: some View {
        Group {
            Section("Network Name") {
                TextField("WiFi Name (SSID)", text: $viewModel.wifiSSID)
                    .focused($isFieldFocused)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .padding(.vertical, 4)
            }

            Section("Security") {
                Picker("Security Type", selection: $viewModel.wifiSecurity) {
                    ForEach(WiFiSecurityType.allCases) { security in
                        Text(security.title).tag(security)
                    }
                }
                .pickerStyle(.segmented)
            }

            if viewModel.wifiSecurity != .none {
                Section("Password") {
                    SecureField("WiFi Password", text: $viewModel.wifiPassword)
                        .padding(.vertical, 4)
                }
            }
        }
    }

    // MARK: - vCard Form

    private var vcardForm: some View {
        Group {
            Section {
                Button {
                    showContactPicker = true
                } label: {
                    Label("Import from Contacts", systemImage: "person.crop.circle.badge.plus")
                }
            }
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

            Section("Name") {
                TextField("Full Name", text: $viewModel.vcardName)
                    .focused($isFieldFocused)
                    .textContentType(.name)
                    .padding(.vertical, 4)
            }

            Section("Contact Info (Optional)") {
                TextField("Phone", text: $viewModel.vcardPhone)
                    .keyboardType(.phonePad)
                    .textContentType(.telephoneNumber)
                    .padding(.vertical, 4)

                TextField("Email", text: $viewModel.vcardEmail)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .padding(.vertical, 4)
            }

            Section("Company (Optional)") {
                TextField("Company Name", text: $viewModel.vcardCompany)
                    .textContentType(.organizationName)
                    .padding(.vertical, 4)
            }
        }
    }

    // MARK: - SMS Form

    private var smsForm: some View {
        Group {
            Section("Phone Number") {
                TextField("+1 234 567 8900", text: $viewModel.smsPhone)
                    .focused($isFieldFocused)
                    .keyboardType(.phonePad)
                    .textContentType(.telephoneNumber)
                    .padding(.vertical, 4)
            }

            Section("Message (Optional)") {
                TextField("Message", text: $viewModel.smsMessage, axis: .vertical)
                    .lineLimit(3...6)
                    .padding(.vertical, 4)
            }
        }
    }
}

#Preview {
    NavigationStack {
        QRCodeFormView(type: .wifi, viewModel: GenerateViewModel())
    }
}
