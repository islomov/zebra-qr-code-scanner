//
//  QRCodeGeneratorService.swift
//  ZebraCodeScanner
//
//  Created by Sardor Islomov on 25/01/26.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

final class QRCodeGeneratorService {
    static let shared = QRCodeGeneratorService()

    private let context = CIContext()

    private init() {}

    func generateQRCode(from content: String, size: CGFloat = 200) -> UIImage? {
        guard let data = content.data(using: .utf8) else { return nil }

        let filter = CIFilter.qrCodeGenerator()
        filter.message = data
        filter.correctionLevel = "M"

        guard let outputImage = filter.outputImage else { return nil }

        let scaleX = size / outputImage.extent.size.width
        let scaleY = size / outputImage.extent.size.height
        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return nil }

        return UIImage(cgImage: cgImage)
    }

    // MARK: - Content Encoders

    func encodeText(_ text: String) -> String {
        return text
    }

    func encodeURL(_ url: String) -> String {
        var urlString = url.trimmingCharacters(in: .whitespacesAndNewlines)
        if !urlString.lowercased().hasPrefix("http://") && !urlString.lowercased().hasPrefix("https://") {
            urlString = "https://" + urlString
        }
        return urlString
    }

    func encodePhone(_ phone: String) -> String {
        let cleaned = phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return "tel:\(cleaned)"
    }

    func encodeEmail(to: String, subject: String = "", body: String = "") -> String {
        var result = "mailto:\(to)"
        var params: [String] = []

        if !subject.isEmpty {
            params.append("subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? subject)")
        }
        if !body.isEmpty {
            params.append("body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? body)")
        }

        if !params.isEmpty {
            result += "?" + params.joined(separator: "&")
        }

        return result
    }

    func encodeWiFi(ssid: String, password: String, security: WiFiSecurityType, hidden: Bool = false) -> String {
        let hiddenStr = hidden ? "H:true;" : ""
        if security == .none {
            return "WIFI:T:nopass;S:\(ssid);\(hiddenStr);"
        }
        return "WIFI:T:\(security.rawValue);S:\(ssid);P:\(password);\(hiddenStr);"
    }

    func encodeVCard(name: String, phone: String = "", email: String = "", company: String = "") -> String {
        var vcard = "BEGIN:VCARD\nVERSION:3.0\n"
        vcard += "FN:\(name)\n"
        vcard += "N:\(name);;;\n"

        if !phone.isEmpty {
            vcard += "TEL:\(phone)\n"
        }
        if !email.isEmpty {
            vcard += "EMAIL:\(email)\n"
        }
        if !company.isEmpty {
            vcard += "ORG:\(company)\n"
        }

        vcard += "END:VCARD"
        return vcard
    }

    func encodeSMS(phone: String, message: String = "") -> String {
        let cleaned = phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        if message.isEmpty {
            return "sms:\(cleaned)"
        }
        let encodedMessage = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? message
        return "sms:\(cleaned)?body=\(encodedMessage)"
    }

    // MARK: - Barcode Generation

    func generateBarcode(from content: String, type: BarcodeType, width: CGFloat = 300, height: CGFloat = 100) -> UIImage? {
        switch type {
        case .code128:
            return generateCode128(from: content, width: width, height: height)
        case .ean13:
            return generateEAN13(from: content, width: width, height: height)
        case .ean8:
            return generateEAN8(from: content, width: width, height: height)
        case .upca:
            return generateUPCA(from: content, width: width, height: height)
        }
    }

    private func generateCode128(from content: String, width: CGFloat, height: CGFloat) -> UIImage? {
        guard let data = content.data(using: .ascii) else { return nil }

        let filter = CIFilter.code128BarcodeGenerator()
        filter.message = data
        filter.quietSpace = 10

        guard let outputImage = filter.outputImage else { return nil }

        let scaleX = width / outputImage.extent.size.width
        let scaleY = height / outputImage.extent.size.height
        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return nil }

        return UIImage(cgImage: cgImage)
    }

    // MARK: - EAN/UPC Barcode Generation

    private func generateEAN13(from content: String, width: CGFloat, height: CGFloat) -> UIImage? {
        let digits = content.filter { $0.isNumber }
        guard digits.count == 12 || digits.count == 13 else { return nil }

        let code = digits.count == 12 ? digits + calculateEAN13CheckDigit(digits) : digits
        return drawEANBarcode(code: code, isEAN8: false, width: width, height: height)
    }

    private func generateEAN8(from content: String, width: CGFloat, height: CGFloat) -> UIImage? {
        let digits = content.filter { $0.isNumber }
        guard digits.count == 7 || digits.count == 8 else { return nil }

        let code = digits.count == 7 ? digits + calculateEAN8CheckDigit(digits) : digits
        return drawEANBarcode(code: code, isEAN8: true, width: width, height: height)
    }

    private func generateUPCA(from content: String, width: CGFloat, height: CGFloat) -> UIImage? {
        let digits = content.filter { $0.isNumber }
        guard digits.count == 11 || digits.count == 12 else { return nil }

        let code = digits.count == 11 ? digits + calculateUPCACheckDigit(digits) : digits
        // UPC-A is essentially EAN-13 with a leading 0
        let ean13Code = "0" + code
        return drawEANBarcode(code: ean13Code, isEAN8: false, width: width, height: height)
    }

    private func drawEANBarcode(code: String, isEAN8: Bool, width: CGFloat, height: CGFloat) -> UIImage? {
        let digits = Array(code).compactMap { Int(String($0)) }

        // EAN encoding patterns
        let lCodes = [
            "0001101", "0011001", "0010011", "0111101", "0100011",
            "0110001", "0101111", "0111011", "0110111", "0001011"
        ]
        let gCodes = [
            "0100111", "0110011", "0011011", "0100001", "0011101",
            "0111001", "0000101", "0010001", "0001001", "0010111"
        ]
        let rCodes = [
            "1110010", "1100110", "1101100", "1000010", "1011100",
            "1001110", "1010000", "1000100", "1001000", "1110100"
        ]

        // First digit encoding pattern for EAN-13
        let firstDigitPatterns = [
            "LLLLLL", "LLGLGG", "LLGGLG", "LLGGGL", "LGLLGG",
            "LGGLLG", "LGGGLL", "LGLGLG", "LGLGGL", "LGGLGL"
        ]

        var barcodeString = "101" // Start guard

        if isEAN8 {
            // EAN-8: 4 digits left, 4 digits right
            for i in 0..<4 {
                barcodeString += lCodes[digits[i]]
            }
            barcodeString += "01010" // Center guard
            for i in 4..<8 {
                barcodeString += rCodes[digits[i]]
            }
        } else {
            // EAN-13: First digit determines pattern, then 6 left, 6 right
            let pattern = Array(firstDigitPatterns[digits[0]])
            for i in 1..<7 {
                if pattern[i - 1] == "L" {
                    barcodeString += lCodes[digits[i]]
                } else {
                    barcodeString += gCodes[digits[i]]
                }
            }
            barcodeString += "01010" // Center guard
            for i in 7..<13 {
                barcodeString += rCodes[digits[i]]
            }
        }

        barcodeString += "101" // End guard

        // Draw barcode
        let barWidth = width / CGFloat(barcodeString.count + 20) // Add quiet zones
        let quietZone = barWidth * 10

        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), true, 0)
        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }

        // White background
        ctx.setFillColor(UIColor.white.cgColor)
        ctx.fill(CGRect(x: 0, y: 0, width: width, height: height))

        // Draw bars
        ctx.setFillColor(UIColor.black.cgColor)
        var x = quietZone

        for char in barcodeString {
            if char == "1" {
                ctx.fill(CGRect(x: x, y: 10, width: barWidth, height: height - 20))
            }
            x += barWidth
        }

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }

    private func calculateEAN13CheckDigit(_ digits: String) -> String {
        let nums = Array(digits).compactMap { Int(String($0)) }
        var sum = 0
        for (index, num) in nums.enumerated() {
            sum += num * (index % 2 == 0 ? 1 : 3)
        }
        let checkDigit = (10 - (sum % 10)) % 10
        return String(checkDigit)
    }

    private func calculateEAN8CheckDigit(_ digits: String) -> String {
        let nums = Array(digits).compactMap { Int(String($0)) }
        var sum = 0
        for (index, num) in nums.enumerated() {
            sum += num * (index % 2 == 0 ? 3 : 1)
        }
        let checkDigit = (10 - (sum % 10)) % 10
        return String(checkDigit)
    }

    private func calculateUPCACheckDigit(_ digits: String) -> String {
        let nums = Array(digits).compactMap { Int(String($0)) }
        var sum = 0
        for (index, num) in nums.enumerated() {
            sum += num * (index % 2 == 0 ? 3 : 1)
        }
        let checkDigit = (10 - (sum % 10)) % 10
        return String(checkDigit)
    }
}
