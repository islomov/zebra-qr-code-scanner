//
//  AnalyticsService.swift
//  ZebraCodeScanner
//
//  Created by Sardor Islomov on 26/04/03.
//

import FirebaseAnalytics

enum AnalyticsService {

    // MARK: - Generate

    static func logQRCodeGenerated(contentType: String) {
        Analytics.logEvent("qr_code_generated", parameters: [
            "content_type": contentType
        ])
    }

    static func logBarcodeGenerated(barcodeType: String) {
        Analytics.logEvent("barcode_generated", parameters: [
            "barcode_type": barcodeType
        ])
    }

    static func logSocialMediaQRGenerated(platform: String) {
        Analytics.logEvent("social_media_qr_generated", parameters: [
            "platform": platform
        ])
    }

    static func logQRCodeCustomized() {
        Analytics.logEvent("qr_code_customized", parameters: nil)
    }

    // MARK: - Scan

    static func logCodeScanned(codeType: String) {
        Analytics.logEvent("code_scanned", parameters: [
            "code_type": codeType
        ])
    }

    static func logPhotoScanned() {
        Analytics.logEvent("photo_scanned", parameters: nil)
    }

    static func logManualBarcodeEntered() {
        Analytics.logEvent("manual_barcode_entered", parameters: nil)
    }

    static func logProductLookup(found: Bool) {
        Analytics.logEvent("product_lookup", parameters: [
            "found": found ? "true" : "false"
        ])
    }

    // MARK: - History

    static func logHistoryCleared() {
        Analytics.logEvent("history_cleared", parameters: nil)
    }

    // MARK: - Settings

    static func logSettingChanged(setting: String, value: String) {
        Analytics.logEvent("setting_changed", parameters: [
            "setting": setting,
            "value": value
        ])
    }
}
