//
//  QRCodeType.swift
//  ZebraCodeScanner
//
//  Created by Sardor Islomov on 25/01/26.
//

import Foundation

enum QRCodeContentType: String, CaseIterable, Identifiable {
    case text = "text"
    case url = "url"
    case phone = "phone"
    case email = "email"
    case wifi = "wifi"
    case vcard = "vcard"
    case sms = "sms"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .text: return "Text"
        case .url: return "URL"
        case .phone: return "Phone"
        case .email: return "Email"
        case .wifi: return "WiFi"
        case .vcard: return "Contact"
        case .sms: return "SMS"
        }
    }

    var icon: String {
        switch self {
        case .text: return "text.alignleft"
        case .url: return "link"
        case .phone: return "phone.fill"
        case .email: return "envelope.fill"
        case .wifi: return "wifi"
        case .vcard: return "person.crop.rectangle.fill"
        case .sms: return "message.fill"
        }
    }

    var description: String {
        switch self {
        case .text: return "Plain text content"
        case .url: return "Website link"
        case .phone: return "Phone number"
        case .email: return "Email address"
        case .wifi: return "WiFi credentials"
        case .vcard: return "Contact card"
        case .sms: return "SMS message"
        }
    }
}

enum WiFiSecurityType: String, CaseIterable, Identifiable {
    case none = "nopass"
    case wpa = "WPA"
    case wep = "WEP"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .none: return "None"
        case .wpa: return "WPA/WPA2"
        case .wep: return "WEP"
        }
    }
}

enum BarcodeType: String, CaseIterable, Identifiable {
    case code128 = "code128"
    case ean13 = "ean13"
    case ean8 = "ean8"
    case upca = "upca"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .code128: return "Code 128"
        case .ean13: return "EAN-13"
        case .ean8: return "EAN-8"
        case .upca: return "UPC-A"
        }
    }

    var icon: String {
        return "barcode"
    }

    var description: String {
        switch self {
        case .code128: return "Alphanumeric barcode"
        case .ean13: return "13-digit product code"
        case .ean8: return "8-digit product code"
        case .upca: return "12-digit US product code"
        }
    }

    var requiredLength: Int? {
        switch self {
        case .code128: return nil // Variable length
        case .ean13: return 13
        case .ean8: return 8
        case .upca: return 12
        }
    }

    var allowsLetters: Bool {
        switch self {
        case .code128: return true
        case .ean13, .ean8, .upca: return false
        }
    }

    var placeholder: String {
        switch self {
        case .code128: return "Enter text or numbers"
        case .ean13: return "Enter 13 digits"
        case .ean8: return "Enter 8 digits"
        case .upca: return "Enter 12 digits"
        }
    }
}
