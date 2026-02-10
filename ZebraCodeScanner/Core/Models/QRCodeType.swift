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
        case .text: return String(localized: "qr_content_type.text.title", defaultValue: "Text")
        case .url: return String(localized: "qr_content_type.url.title", defaultValue: "URL")
        case .phone: return String(localized: "qr_content_type.phone.title", defaultValue: "Phone")
        case .email: return String(localized: "qr_content_type.email.title", defaultValue: "Email")
        case .wifi: return String(localized: "qr_content_type.wifi.title", defaultValue: "WiFi")
        case .vcard: return String(localized: "qr_content_type.vcard.title", defaultValue: "Contact")
        case .sms: return String(localized: "qr_content_type.sms.title", defaultValue: "SMS")
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
        case .text: return String(localized: "qr_content_type.text.description", defaultValue: "Plain text content")
        case .url: return String(localized: "qr_content_type.url.description", defaultValue: "Website link")
        case .phone: return String(localized: "qr_content_type.phone.description", defaultValue: "Phone number")
        case .email: return String(localized: "qr_content_type.email.description", defaultValue: "Email address")
        case .wifi: return String(localized: "qr_content_type.wifi.description", defaultValue: "WiFi credentials")
        case .vcard: return String(localized: "qr_content_type.vcard.description", defaultValue: "Contact card")
        case .sms: return String(localized: "qr_content_type.sms.description", defaultValue: "SMS message")
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
        case .none: return String(localized: "wifi_security.none.title", defaultValue: "None")
        case .wpa: return String(localized: "wifi_security.wpa.title", defaultValue: "WPA/WPA2")
        case .wep: return String(localized: "wifi_security.wep.title", defaultValue: "WEP")
        }
    }
}

enum SocialMediaType: String, CaseIterable, Identifiable {
    case facebook = "facebook"
    case instagram = "instagram"
    case x = "x"
    case reddit = "reddit"
    case tiktok = "tiktok"
    case snapchat = "snapchat"
    case threads = "threads"
    case youtube = "youtube"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .facebook: return String(localized: "social_media.facebook.title", defaultValue: "Facebook")
        case .instagram: return String(localized: "social_media.instagram.title", defaultValue: "Instagram")
        case .x: return String(localized: "social_media.x.title", defaultValue: "X")
        case .reddit: return String(localized: "social_media.reddit.title", defaultValue: "Reddit")
        case .tiktok: return String(localized: "social_media.tiktok.title", defaultValue: "TikTok")
        case .snapchat: return String(localized: "social_media.snapchat.title", defaultValue: "Snapchat")
        case .threads: return String(localized: "social_media.threads.title", defaultValue: "Threads")
        case .youtube: return String(localized: "social_media.youtube.title", defaultValue: "YouTube")
        }
    }

    var icon: String {
        switch self {
        case .facebook: return "person.crop.square"
        case .instagram: return "camera.circle"
        case .x: return "bubble.left"
        case .reddit: return "globe"
        case .tiktok: return "play.rectangle"
        case .snapchat: return "message.circle"
        case .threads: return "at.circle"
        case .youtube: return "play.rectangle.fill"
        }
    }

    var description: String {
        switch self {
        case .facebook: return String(localized: "social_media.facebook.description", defaultValue: "Facebook profile")
        case .instagram: return String(localized: "social_media.instagram.description", defaultValue: "Instagram profile")
        case .x: return String(localized: "social_media.x.description", defaultValue: "X (Twitter) profile")
        case .reddit: return String(localized: "social_media.reddit.description", defaultValue: "Reddit profile")
        case .tiktok: return String(localized: "social_media.tiktok.description", defaultValue: "TikTok profile")
        case .snapchat: return String(localized: "social_media.snapchat.description", defaultValue: "Snapchat profile")
        case .threads: return String(localized: "social_media.threads.description", defaultValue: "Threads profile")
        case .youtube: return String(localized: "social_media.youtube.description", defaultValue: "YouTube channel")
        }
    }

    var baseURL: String {
        switch self {
        case .facebook: return "https://facebook.com/"
        case .instagram: return "https://instagram.com/"
        case .x: return "https://x.com/"
        case .reddit: return "https://reddit.com/u/"
        case .tiktok: return "https://tiktok.com/@"
        case .snapchat: return "https://snapchat.com/add/"
        case .threads: return "https://threads.net/@"
        case .youtube: return "https://youtube.com/@"
        }
    }

    var placeholder: String {
        switch self {
        case .facebook: return String(localized: "social_media.facebook.placeholder", defaultValue: "username or page name")
        case .instagram: return String(localized: "social_media.instagram.placeholder", defaultValue: "username")
        case .x: return String(localized: "social_media.x.placeholder", defaultValue: "username")
        case .reddit: return String(localized: "social_media.reddit.placeholder", defaultValue: "username")
        case .tiktok: return String(localized: "social_media.tiktok.placeholder", defaultValue: "username")
        case .snapchat: return String(localized: "social_media.snapchat.placeholder", defaultValue: "username")
        case .threads: return String(localized: "social_media.threads.placeholder", defaultValue: "username")
        case .youtube: return String(localized: "social_media.youtube.placeholder", defaultValue: "channel name")
        }
    }
}

enum BarcodeType: String, CaseIterable, Identifiable {
    case code128 = "code128"
    case ean13 = "ean13"
    case ean8 = "ean8"
    case upca = "upca"
    case aztec = "aztec"
    case pdf417 = "pdf417"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .code128: return String(localized: "barcode_type.code128.title", defaultValue: "Code 128")
        case .ean13: return String(localized: "barcode_type.ean13.title", defaultValue: "EAN-13")
        case .ean8: return String(localized: "barcode_type.ean8.title", defaultValue: "EAN-8")
        case .upca: return String(localized: "barcode_type.upca.title", defaultValue: "UPC-A")
        case .aztec: return String(localized: "barcode_type.aztec.title", defaultValue: "Aztec")
        case .pdf417: return String(localized: "barcode_type.pdf417.title", defaultValue: "PDF417")
        }
    }

    var icon: String {
        switch self {
        case .aztec: return "square.dashed"
        case .pdf417: return "rectangle.split.3x3"
        default: return "barcode"
        }
    }

    var description: String {
        switch self {
        case .code128: return String(localized: "barcode_type.code128.description", defaultValue: "Alphanumeric barcode")
        case .ean13: return String(localized: "barcode_type.ean13.description", defaultValue: "13-digit product code")
        case .ean8: return String(localized: "barcode_type.ean8.description", defaultValue: "8-digit product code")
        case .upca: return String(localized: "barcode_type.upca.description", defaultValue: "12-digit US product code")
        case .aztec: return String(localized: "barcode_type.aztec.description", defaultValue: "2D matrix barcode")
        case .pdf417: return String(localized: "barcode_type.pdf417.description", defaultValue: "2D stacked barcode")
        }
    }

    var requiredLength: Int? {
        switch self {
        case .code128: return nil // Variable length
        case .ean13: return 13
        case .ean8: return 8
        case .upca: return 12
        case .aztec: return nil // Variable length
        case .pdf417: return nil // Variable length
        }
    }

    var allowsLetters: Bool {
        switch self {
        case .code128, .aztec, .pdf417: return true
        case .ean13, .ean8, .upca: return false
        }
    }

    var placeholder: String {
        switch self {
        case .code128: return String(localized: "barcode_type.code128.placeholder", defaultValue: "Enter text or numbers")
        case .ean13: return String(localized: "barcode_type.ean13.placeholder", defaultValue: "Enter 13 digits")
        case .ean8: return String(localized: "barcode_type.ean8.placeholder", defaultValue: "Enter 8 digits")
        case .upca: return String(localized: "barcode_type.upca.placeholder", defaultValue: "Enter 12 digits")
        case .aztec: return String(localized: "barcode_type.aztec.placeholder", defaultValue: "Enter text or numbers")
        case .pdf417: return String(localized: "barcode_type.pdf417.placeholder", defaultValue: "Enter text or numbers")
        }
    }

    var is2D: Bool {
        switch self {
        case .aztec, .pdf417: return true
        case .code128, .ean13, .ean8, .upca: return false
        }
    }

    static var barcodes1D: [BarcodeType] {
        allCases.filter { !$0.is2D }
    }

    static var barcodes2D: [BarcodeType] {
        allCases.filter { $0.is2D }
    }
}

enum QRCenterIcon: String, CaseIterable, Identifiable {
    case text = "text"
    case link = "link"
    case phone = "phone"
    case email = "email"
    case wifi = "wifi"
    case contact = "contact"
    case sms = "sms"
    case facebook = "facebook"
    case instagram = "instagram"
    case x = "x"
    case reddit = "reddit"
    case tiktok = "tiktok"
    case snapchat = "snapchat"
    case threads = "threads"
    case youtube = "youtube"

    var id: String { rawValue }

    var assetName: String {
        switch self {
        case .text: return "icon-text"
        case .link: return "icon-link"
        case .phone: return "icon-phone"
        case .email: return "icon-email"
        case .wifi: return "icon-wifi"
        case .contact: return "icon-contact"
        case .sms: return "icon-sms"
        case .facebook: return "icon-facebook"
        case .instagram: return "icon-instagram"
        case .x: return "icon-twitter-x"
        case .reddit: return "icon-reddit"
        case .tiktok: return "icon-tiktok"
        case .snapchat: return "icon-snapchat"
        case .threads: return "icon-threads"
        case .youtube: return "icon-youtube"
        }
    }

    var title: String {
        switch self {
        case .text: return String(localized: "center_icon.text.title", defaultValue: "Text")
        case .link: return String(localized: "center_icon.link.title", defaultValue: "Link")
        case .phone: return String(localized: "center_icon.phone.title", defaultValue: "Phone")
        case .email: return String(localized: "center_icon.email.title", defaultValue: "Email")
        case .wifi: return String(localized: "center_icon.wifi.title", defaultValue: "WiFi")
        case .contact: return String(localized: "center_icon.contact.title", defaultValue: "Contact")
        case .sms: return String(localized: "center_icon.sms.title", defaultValue: "SMS")
        case .facebook: return String(localized: "center_icon.facebook.title", defaultValue: "Facebook")
        case .instagram: return String(localized: "center_icon.instagram.title", defaultValue: "Instagram")
        case .x: return String(localized: "center_icon.x.title", defaultValue: "X")
        case .reddit: return String(localized: "center_icon.reddit.title", defaultValue: "Reddit")
        case .tiktok: return String(localized: "center_icon.tiktok.title", defaultValue: "TikTok")
        case .snapchat: return String(localized: "center_icon.snapchat.title", defaultValue: "Snapchat")
        case .threads: return String(localized: "center_icon.threads.title", defaultValue: "Threads")
        case .youtube: return String(localized: "center_icon.youtube.title", defaultValue: "YouTube")
        }
    }
}

enum QRModuleStyle: String, CaseIterable, Identifiable {
    case square = "square"
    case roundedSquare = "roundedSquare"
    case circle = "circle"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .square: return String(localized: "qr_module_style.square.title", defaultValue: "Square")
        case .roundedSquare: return String(localized: "qr_module_style.rounded_square.title", defaultValue: "Rounded")
        case .circle: return String(localized: "qr_module_style.circle.title", defaultValue: "Circle")
        }
    }

    var icon: String {
        switch self {
        case .square: return "square.fill"
        case .roundedSquare: return "app.fill"
        case .circle: return "circle.fill"
        }
    }
}
