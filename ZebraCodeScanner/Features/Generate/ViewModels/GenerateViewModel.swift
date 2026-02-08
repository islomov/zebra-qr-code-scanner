//
//  GenerateViewModel.swift
//  ZebraCodeScanner
//
//  Created by Sardor Islomov on 25/01/26.
//

import SwiftUI
import UIKit
import Combine

@MainActor
final class GenerateViewModel: ObservableObject {
    // MARK: - Form Fields

    // Text
    @Published var text: String = ""

    // URL
    @Published var url: String = ""

    // Phone
    @Published var phone: String = ""

    // Email
    @Published var emailTo: String = ""
    @Published var emailSubject: String = ""
    @Published var emailBody: String = ""

    // WiFi
    @Published var wifiSSID: String = ""
    @Published var wifiPassword: String = ""
    @Published var wifiSecurity: WiFiSecurityType = .wpa

    // vCard
    @Published var vcardName: String = ""
    @Published var vcardPhone: String = ""
    @Published var vcardEmail: String = ""
    @Published var vcardCompany: String = ""

    // SMS
    @Published var smsPhone: String = ""
    @Published var smsMessage: String = ""

    // Social Media
    @Published var socialMediaUsername: String = ""

    // Barcode
    @Published var barcodeContent: String = ""

    // MARK: - Generated Output

    @Published var generatedImage: UIImage?
    @Published var generatedContent: String = ""

    // MARK: - QR Styling

    @Published var qrBackgroundColor: Color = .white
    @Published var qrForegroundColor: Color = .black
    @Published var qrCenterLogo: UIImage? = nil
    @Published var qrModuleStyle: QRModuleStyle = .square
    @Published var isStyleDirty: Bool = false
    var savedEntity: GeneratedCodeEntity? = nil

    // MARK: - Services

    private let qrService = QRCodeGeneratorService.shared
    private let dataManager = CoreDataManager.shared

    // MARK: - Generation

    func generateQRCode(for type: QRCodeContentType) {
        let content = encodeContent(for: type)
        generatedContent = content
        qrBackgroundColor = .white
        qrForegroundColor = .black
        qrCenterLogo = nil
        qrModuleStyle = .square
        generatedImage = qrService.generateStyledQRCode(
            from: content,
            size: 300,
            backgroundColor: UIColor(qrBackgroundColor),
            foregroundColor: UIColor(qrForegroundColor),
            centerLogo: qrCenterLogo,
            moduleStyle: qrModuleStyle
        )
    }

    private func encodeContent(for type: QRCodeContentType) -> String {
        switch type {
        case .text:
            return qrService.encodeText(text)
        case .url:
            return qrService.encodeURL(url)
        case .phone:
            return qrService.encodePhone(phone)
        case .email:
            return qrService.encodeEmail(to: emailTo, subject: emailSubject, body: emailBody)
        case .wifi:
            return qrService.encodeWiFi(ssid: wifiSSID, password: wifiPassword, security: wifiSecurity)
        case .vcard:
            return qrService.encodeVCard(name: vcardName, phone: vcardPhone, email: vcardEmail, company: vcardCompany)
        case .sms:
            return qrService.encodeSMS(phone: smsPhone, message: smsMessage)
        }
    }

    // MARK: - Social Media Generation

    func generateSocialMediaQRCode(for type: SocialMediaType) {
        let profileURL = type.baseURL + socialMediaUsername.trimmingCharacters(in: .whitespacesAndNewlines)
        generatedContent = profileURL
        qrBackgroundColor = .white
        qrForegroundColor = .black
        qrCenterLogo = nil
        qrModuleStyle = .square
        generatedImage = qrService.generateStyledQRCode(
            from: profileURL,
            size: 300,
            backgroundColor: UIColor(qrBackgroundColor),
            foregroundColor: UIColor(qrForegroundColor),
            centerLogo: qrCenterLogo,
            moduleStyle: qrModuleStyle
        )
    }

    func isSocialMediaValid() -> Bool {
        !socialMediaUsername.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    @discardableResult
    func saveSocialMediaToHistory(type: SocialMediaType) -> GeneratedCodeEntity {
        let entity = dataManager.saveGeneratedCode(
            type: "qr",
            content: generatedContent,
            contentType: type.rawValue,
            image: generatedImage
        )
        savedEntity = entity
        return entity
    }

    // MARK: - Barcode Generation

    func generateBarcode(for type: BarcodeType) {
        generatedContent = barcodeContent
        generatedImage = qrService.generateBarcode(from: barcodeContent, type: type)
    }

    // MARK: - Validation

    func isValid(for type: QRCodeContentType) -> Bool {
        switch type {
        case .text:
            return !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .url:
            return !url.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .phone:
            return !phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .email:
            return !emailTo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .wifi:
            return !wifiSSID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .vcard:
            return !vcardName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .sms:
            return !smsPhone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    func isValidBarcode(for type: BarcodeType) -> Bool {
        let content = barcodeContent.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else { return false }

        switch type {
        case .code128, .aztec, .pdf417:
            return true // These formats accept any content
        case .ean13:
            let digits = content.filter { $0.isNumber }
            return digits.count == 12 || digits.count == 13
        case .ean8:
            let digits = content.filter { $0.isNumber }
            return digits.count == 7 || digits.count == 8
        case .upca:
            let digits = content.filter { $0.isNumber }
            return digits.count == 11 || digits.count == 12
        }
    }

    // MARK: - Styled Regeneration

    func regenerateStyledQRCode() {
        guard !generatedContent.isEmpty else { return }
        generatedImage = qrService.generateStyledQRCode(
            from: generatedContent,
            size: 300,
            backgroundColor: UIColor(qrBackgroundColor),
            foregroundColor: UIColor(qrForegroundColor),
            centerLogo: qrCenterLogo,
            moduleStyle: qrModuleStyle
        )
        isStyleDirty = true
    }

    func updateSavedImage() {
        guard let entity = savedEntity, let image = generatedImage else { return }
        entity.imageData = image.pngData()
        dataManager.saveContext()
    }

    // MARK: - Delete

    func deleteCurrentCode() {
        if let entity = savedEntity {
            dataManager.deleteGeneratedCode(entity)
            savedEntity = nil
        }
    }

    // MARK: - Save to History

    @discardableResult
    func saveToHistory(type: QRCodeContentType) -> GeneratedCodeEntity {
        let entity = dataManager.saveGeneratedCode(
            type: "qr",
            content: generatedContent,
            contentType: type.rawValue,
            image: generatedImage
        )
        savedEntity = entity
        return entity
    }

    @discardableResult
    func saveBarcodeToHistory(type: BarcodeType) -> GeneratedCodeEntity {
        let entity = dataManager.saveGeneratedCode(
            type: "barcode",
            content: generatedContent,
            contentType: type.rawValue,
            image: generatedImage
        )
        savedEntity = entity
        return entity
    }

    // MARK: - Reset

    func reset() {
        text = ""
        url = ""
        phone = ""
        emailTo = ""
        emailSubject = ""
        emailBody = ""
        wifiSSID = ""
        wifiPassword = ""
        wifiSecurity = .wpa
        vcardName = ""
        vcardPhone = ""
        vcardEmail = ""
        vcardCompany = ""
        smsPhone = ""
        smsMessage = ""
        socialMediaUsername = ""
        barcodeContent = ""
        generatedImage = nil
        generatedContent = ""
        qrBackgroundColor = .white
        qrForegroundColor = .black
        qrCenterLogo = nil
        qrModuleStyle = .square
        isStyleDirty = false
        savedEntity = nil
    }
}
