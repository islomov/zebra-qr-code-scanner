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

    func generateStyledQRCode(from content: String, size: CGFloat = 300, backgroundColor: UIColor = .white, foregroundColor: UIColor = .black, centerLogo: UIImage? = nil, moduleStyle: QRModuleStyle = .square) -> UIImage? {
        guard let data = content.data(using: .utf8) else { return nil }

        let correctionLevel = centerLogo != nil ? "H" : "M"

        // For non-square styles, use custom drawing path
        if moduleStyle != .square {
            return generateCustomStyledQRCode(
                data: data,
                size: size,
                backgroundColor: backgroundColor,
                foregroundColor: foregroundColor,
                centerLogo: centerLogo,
                moduleStyle: moduleStyle,
                correctionLevel: correctionLevel
            )
        }

        let filter = CIFilter.qrCodeGenerator()
        filter.message = data
        filter.correctionLevel = correctionLevel

        guard let outputImage = filter.outputImage else { return nil }

        // Apply foreground/background colors via CIFalseColor
        let coloredImage: CIImage
        if let colorFilter = CIFilter(name: "CIFalseColor",
                                       parameters: ["inputImage": outputImage,
                                                     "inputColor0": CIColor(color: foregroundColor),
                                                     "inputColor1": CIColor(color: backgroundColor)]),
           let colored = colorFilter.outputImage {
            coloredImage = colored
        } else {
            coloredImage = outputImage
        }

        let scaleX = size / coloredImage.extent.size.width
        let scaleY = size / coloredImage.extent.size.height
        let scaledImage = coloredImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return nil }

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        return renderer.image { ctx in
            let qrImage = UIImage(cgImage: cgImage)
            qrImage.draw(in: CGRect(origin: .zero, size: CGSize(width: size, height: size)))

            if let logo = centerLogo {
                let logoSize = size * 0.22
                let logoPadding: CGFloat = 6
                let backgroundSize = logoSize + logoPadding * 2
                let backgroundOrigin = CGPoint(x: (size - backgroundSize) / 2, y: (size - backgroundSize) / 2)
                let backgroundRect = CGRect(origin: backgroundOrigin, size: CGSize(width: backgroundSize, height: backgroundSize))

                UIColor.white.setFill()
                UIBezierPath(roundedRect: backgroundRect, cornerRadius: 8).fill()

                let logoOrigin = CGPoint(x: (size - logoSize) / 2, y: (size - logoSize) / 2)
                let logoRect = CGRect(origin: logoOrigin, size: CGSize(width: logoSize, height: logoSize))
                logo.draw(in: logoRect)
            }
        }
    }

    // MARK: - Custom Styled QR Code Drawing

    private func generateCustomStyledQRCode(data: Data, size: CGFloat, backgroundColor: UIColor, foregroundColor: UIColor, centerLogo: UIImage?, moduleStyle: QRModuleStyle, correctionLevel: String) -> UIImage? {
        guard let matrix = extractModuleMatrix(data: data, correctionLevel: correctionLevel) else { return nil }
        guard let bounds = findQRCodeBounds(in: matrix) else { return nil }

        let qrSize = bounds.size
        let moduleSize = size / CGFloat(qrSize)

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        return renderer.image { ctx in
            let cgCtx = ctx.cgContext

            // Fill background
            cgCtx.setFillColor(backgroundColor.cgColor)
            cgCtx.fill(CGRect(origin: .zero, size: CGSize(width: size, height: size)))

            // Draw data modules (skip finder pattern regions)
            cgCtx.setFillColor(foregroundColor.cgColor)
            for row in 0..<qrSize {
                for col in 0..<qrSize {
                    let matrixRow = row + bounds.originRow
                    let matrixCol = col + bounds.originCol

                    guard matrix[matrixRow][matrixCol] else { continue }
                    guard !isFinderPattern(row: row, col: col, qrSize: qrSize) else { continue }

                    let rect = CGRect(
                        x: CGFloat(col) * moduleSize,
                        y: CGFloat(row) * moduleSize,
                        width: moduleSize,
                        height: moduleSize
                    )
                    drawModule(in: cgCtx, rect: rect, style: moduleStyle)
                }
            }

            // Draw finder patterns as composite shapes
            let finderPositions = [
                CGPoint(x: 0, y: 0),
                CGPoint(x: CGFloat(qrSize - 7) * moduleSize, y: 0),
                CGPoint(x: 0, y: CGFloat(qrSize - 7) * moduleSize)
            ]
            for origin in finderPositions {
                drawFinderPattern(
                    in: cgCtx,
                    origin: origin,
                    moduleSize: moduleSize,
                    style: moduleStyle,
                    foregroundColor: foregroundColor,
                    backgroundColor: backgroundColor
                )
            }

            // Overlay center logo
            if let logo = centerLogo {
                let logoSize = size * 0.22
                let logoPadding: CGFloat = 6
                let backgroundSize = logoSize + logoPadding * 2
                let backgroundOrigin = CGPoint(x: (size - backgroundSize) / 2, y: (size - backgroundSize) / 2)
                let backgroundRect = CGRect(origin: backgroundOrigin, size: CGSize(width: backgroundSize, height: backgroundSize))

                cgCtx.setFillColor(UIColor.white.cgColor)
                cgCtx.addPath(UIBezierPath(roundedRect: backgroundRect, cornerRadius: 8).cgPath)
                cgCtx.fillPath()

                let logoOrigin = CGPoint(x: (size - logoSize) / 2, y: (size - logoSize) / 2)
                let logoRect = CGRect(origin: logoOrigin, size: CGSize(width: logoSize, height: logoSize))
                logo.draw(in: logoRect)
            }
        }
    }

    private func extractModuleMatrix(data: Data, correctionLevel: String) -> [[Bool]]? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = data
        filter.correctionLevel = correctionLevel

        guard let outputImage = filter.outputImage else { return nil }

        let extent = outputImage.extent
        let width = Int(extent.width)
        let height = Int(extent.height)

        guard let cgImage = context.createCGImage(outputImage, from: extent) else { return nil }

        let bytesPerPixel = cgImage.bitsPerPixel / 8
        let bytesPerRow = cgImage.bytesPerRow

        guard let dataProvider = cgImage.dataProvider,
              let pixelData = dataProvider.data,
              let pointer = CFDataGetBytePtr(pixelData) else { return nil }

        var matrix: [[Bool]] = Array(repeating: Array(repeating: false, count: width), count: height)

        for y in 0..<height {
            for x in 0..<width {
                let offset = y * bytesPerRow + x * bytesPerPixel
                let pixelValue = pointer[offset]
                matrix[y][x] = (pixelValue == 0)
            }
        }

        return matrix
    }

    private func findQRCodeBounds(in matrix: [[Bool]]) -> (originRow: Int, originCol: Int, size: Int)? {
        let height = matrix.count
        let width = matrix[0].count

        var minRow = height, minCol = width
        var maxRow = 0, maxCol = 0

        for row in 0..<height {
            for col in 0..<width {
                if matrix[row][col] {
                    minRow = min(minRow, row)
                    minCol = min(minCol, col)
                    maxRow = max(maxRow, row)
                    maxCol = max(maxCol, col)
                }
            }
        }

        guard minRow <= maxRow && minCol <= maxCol else { return nil }

        let size = max(maxRow - minRow + 1, maxCol - minCol + 1)
        return (minRow, minCol, size)
    }

    private func isFinderPattern(row: Int, col: Int, qrSize: Int) -> Bool {
        // Top-left finder: 0..6, 0..6
        if row <= 6 && col <= 6 { return true }
        // Top-right finder: 0..6, (qrSize-7)..(qrSize-1)
        if row <= 6 && col >= qrSize - 7 { return true }
        // Bottom-left finder: (qrSize-7)..(qrSize-1), 0..6
        if row >= qrSize - 7 && col <= 6 { return true }
        return false
    }

    private func drawModule(in context: CGContext, rect: CGRect, style: QRModuleStyle) {
        let inset: CGFloat = rect.width * 0.05
        let insetRect = rect.insetBy(dx: inset, dy: inset)

        switch style {
        case .square:
            context.fill(insetRect)

        case .roundedSquare:
            let radius = insetRect.width * 0.3
            let path = UIBezierPath(roundedRect: insetRect, cornerRadius: radius)
            context.addPath(path.cgPath)
            context.fillPath()

        case .circle:
            let path = UIBezierPath(ovalIn: insetRect)
            context.addPath(path.cgPath)
            context.fillPath()
        }
    }

    private func drawFinderPattern(in context: CGContext, origin: CGPoint, moduleSize: CGFloat, style: QRModuleStyle, foregroundColor: UIColor, backgroundColor: UIColor) {
        let outerSize = moduleSize * 7
        let middleSize = moduleSize * 5
        let innerSize = moduleSize * 3

        let outerRect = CGRect(origin: origin, size: CGSize(width: outerSize, height: outerSize))
        let middleRect = CGRect(
            x: origin.x + moduleSize,
            y: origin.y + moduleSize,
            width: middleSize,
            height: middleSize
        )
        let innerRect = CGRect(
            x: origin.x + moduleSize * 2,
            y: origin.y + moduleSize * 2,
            width: innerSize,
            height: innerSize
        )

        switch style {
        case .square:
            context.setFillColor(foregroundColor.cgColor)
            context.fill(outerRect)
            context.setFillColor(backgroundColor.cgColor)
            context.fill(middleRect)
            context.setFillColor(foregroundColor.cgColor)
            context.fill(innerRect)

        case .roundedSquare:
            let outerRadius = moduleSize * 1.0
            let middleRadius = moduleSize * 0.8
            let innerRadius = moduleSize * 0.6

            context.setFillColor(foregroundColor.cgColor)
            context.addPath(UIBezierPath(roundedRect: outerRect, cornerRadius: outerRadius).cgPath)
            context.fillPath()

            context.setFillColor(backgroundColor.cgColor)
            context.addPath(UIBezierPath(roundedRect: middleRect, cornerRadius: middleRadius).cgPath)
            context.fillPath()

            context.setFillColor(foregroundColor.cgColor)
            context.addPath(UIBezierPath(roundedRect: innerRect, cornerRadius: innerRadius).cgPath)
            context.fillPath()

        case .circle:
            context.setFillColor(foregroundColor.cgColor)
            context.addPath(UIBezierPath(ovalIn: outerRect).cgPath)
            context.fillPath()

            context.setFillColor(backgroundColor.cgColor)
            context.addPath(UIBezierPath(ovalIn: middleRect).cgPath)
            context.fillPath()

            context.setFillColor(foregroundColor.cgColor)
            context.addPath(UIBezierPath(ovalIn: innerRect).cgPath)
            context.fillPath()
        }
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
        case .aztec:
            return generateAztec(from: content, size: width)
        case .pdf417:
            return generatePDF417(from: content, width: width, height: height)
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

    private func generateAztec(from content: String, size: CGFloat) -> UIImage? {
        guard let data = content.data(using: .utf8) else { return nil }

        let filter = CIFilter.aztecCodeGenerator()
        filter.message = data
        filter.correctionLevel = 23 // ~23% error correction

        guard let outputImage = filter.outputImage else { return nil }

        let scaleX = size / outputImage.extent.size.width
        let scaleY = size / outputImage.extent.size.height
        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return nil }

        return UIImage(cgImage: cgImage)
    }

    private func generatePDF417(from content: String, width: CGFloat, height: CGFloat) -> UIImage? {
        guard let data = content.data(using: .utf8) else { return nil }

        let filter = CIFilter.pdf417BarcodeGenerator()
        filter.message = data
        filter.correctionLevel = 2

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
