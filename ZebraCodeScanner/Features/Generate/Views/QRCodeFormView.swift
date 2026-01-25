//
//  QRCodeFormView.swift
//  ZebraCodeScanner
//
//  Created by Sardor Islomov on 25/01/26.
//

import SwiftUI

struct QRCodeFormView: View {
    let type: QRCodeContentType
    @ObservedObject var viewModel: GenerateViewModel
    @State private var showPreview = false

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
        .navigationTitle(type.title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showPreview) {
            QRCodePreviewView(type: type, viewModel: viewModel)
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
                .lineLimit(5...10)
        }
    }

    // MARK: - URL Form

    private var urlForm: some View {
        Section("Website URL") {
            TextField("example.com", text: $viewModel.url)
                .keyboardType(.URL)
                .textContentType(.URL)
                .autocapitalization(.none)
                .autocorrectionDisabled()
        }
    }

    // MARK: - Phone Form

    private var phoneForm: some View {
        Section("Phone Number") {
            TextField("+1 234 567 8900", text: $viewModel.phone)
                .keyboardType(.phonePad)
                .textContentType(.telephoneNumber)
        }
    }

    // MARK: - Email Form

    private var emailForm: some View {
        Group {
            Section("Recipient") {
                TextField("email@example.com", text: $viewModel.emailTo)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
            }

            Section("Subject (Optional)") {
                TextField("Subject", text: $viewModel.emailSubject)
            }

            Section("Message (Optional)") {
                TextField("Message", text: $viewModel.emailBody, axis: .vertical)
                    .lineLimit(3...6)
            }
        }
    }

    // MARK: - WiFi Form

    private var wifiForm: some View {
        Group {
            Section("Network Name") {
                TextField("WiFi Name (SSID)", text: $viewModel.wifiSSID)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
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
                }
            }
        }
    }

    // MARK: - vCard Form

    private var vcardForm: some View {
        Group {
            Section("Name") {
                TextField("Full Name", text: $viewModel.vcardName)
                    .textContentType(.name)
            }

            Section("Contact Info (Optional)") {
                TextField("Phone", text: $viewModel.vcardPhone)
                    .keyboardType(.phonePad)
                    .textContentType(.telephoneNumber)

                TextField("Email", text: $viewModel.vcardEmail)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
            }

            Section("Company (Optional)") {
                TextField("Company Name", text: $viewModel.vcardCompany)
                    .textContentType(.organizationName)
            }
        }
    }

    // MARK: - SMS Form

    private var smsForm: some View {
        Group {
            Section("Phone Number") {
                TextField("+1 234 567 8900", text: $viewModel.smsPhone)
                    .keyboardType(.phonePad)
                    .textContentType(.telephoneNumber)
            }

            Section("Message (Optional)") {
                TextField("Message", text: $viewModel.smsMessage, axis: .vertical)
                    .lineLimit(3...6)
            }
        }
    }
}

#Preview {
    NavigationStack {
        QRCodeFormView(type: .wifi, viewModel: GenerateViewModel())
    }
}
