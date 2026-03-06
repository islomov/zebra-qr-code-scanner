//
//  ImageSearchEngine.swift
//  ZebraCodeScanner
//
//  Created by Sardor Islomov on 04/03/26.
//

import Foundation

enum ImageSearchEngine: String, CaseIterable, Identifiable {
    case googleLens
    case yandex

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .googleLens: return String(localized: "image_search.engine.google", defaultValue: "Google")
        case .yandex: return String(localized: "image_search.engine.yandex", defaultValue: "Yandex")
        }
    }

    var uploadURL: URL {
        switch self {
        case .googleLens:
            return URL(string: "https://lens.google.com/v3/upload")!
        case .yandex:
            return URL(string: "https://yandex.com/images/search?rpt=imageview&format=json&request=%7B%22blocks%22%3A%5B%7B%22block%22%3A%22b-page_type_search-by-image__link%22%7D%5D%7D")!
        }
    }

    var formFieldName: String {
        switch self {
        case .googleLens: return "encoded_image"
        case .yandex: return "upfile"
        }
    }

    var uploadFilename: String {
        switch self {
        case .googleLens: return "image.jpg"
        case .yandex: return "blob"
        }
    }

    var extraFormFields: [(String, String)] {
        []
    }

    var referer: String {
        switch self {
        case .googleLens: return "https://lens.google.com/"
        case .yandex: return "https://yandex.com/images/"
        }
    }
}
