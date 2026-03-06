//
//  ImageSearchView.swift
//  ZebraCodeScanner
//
//  Created by Sardor Islomov on 01/03/26.
//

import SwiftUI
import WebKit

struct ImageSearchView: View {
    @Environment(\.dismiss) private var dismiss

    let image: UIImage?

    @State private var selectedEngine: ImageSearchEngine = .googleLens
    @State private var loadedEngines: Set<ImageSearchEngine> = [.googleLens]
    @State private var loadingStates: [ImageSearchEngine: Bool] = [.googleLens: true]
    @Namespace private var tabAnimation

    var body: some View {
        VStack(spacing: 0) {
            // Header
            ZStack {
                Text(String(localized: "image_search.title", defaultValue: "Photo Search"))
                    .font(.custom("Inter-SemiBold", size: 20))
                    .tracking(-0.408)
                    .foregroundStyle(DesignColors.primaryText)

                HStack {
                    Spacer()

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(DesignColors.primaryText)
                            .frame(width: 44, height: 44)
                            .background(DesignColors.cardBackground)
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)

            // Engine tab bar
            engineTabBar
                .padding(.horizontal, 16)
                .padding(.bottom, 12)

            // WebView content
            ZStack {
                if let image {
                    ForEach(ImageSearchEngine.allCases) { engine in
                        if loadedEngines.contains(engine) {
                            ImageSearchWebView(
                                image: image,
                                engine: engine,
                                isLoading: Binding(
                                    get: { loadingStates[engine] ?? true },
                                    set: { loadingStates[engine] = $0 }
                                )
                            )
                            .opacity(selectedEngine == engine ? 1 : 0)
                            .allowsHitTesting(selectedEngine == engine)
                        }
                    }
                }

                if loadingStates[selectedEngine] ?? true {
                    VStack(spacing: 16) {
                        ProgressView()
                            .controlSize(.large)
                        Text(String(localized: "image_search.searching", defaultValue: "Searching..."))
                            .font(.custom("Inter-Regular", size: 14))
                            .tracking(-0.408)
                            .foregroundStyle(DesignColors.secondaryText)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .background(DesignColors.background)
    }

    // MARK: - Engine Tab Bar

    private var engineTabBar: some View {
        HStack(spacing: 0) {
            ForEach(ImageSearchEngine.allCases) { engine in
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        selectedEngine = engine
                    }
                    // Lazy load: mark engine as loaded on first tap
                    if !loadedEngines.contains(engine) {
                        loadingStates[engine] = true
                        loadedEngines.insert(engine)
                    }
                } label: {
                    Text(engine.displayName)
                        .font(.custom("Inter-Regular", size: 14))
                        .tracking(-0.408)
                        .foregroundStyle(DesignColors.primaryText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background {
                            if selectedEngine == engine {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(DesignColors.primaryButtonText)
                                    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 0)
                                    .matchedGeometryEffect(id: "engineTab", in: tabAnimation)
                            }
                        }
                }
            }
        }
        .padding(4)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(DesignColors.lightText)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(DesignColors.stroke, lineWidth: 1)
                )
        )
    }
}

// MARK: - Image Search WebView

private struct ImageSearchWebView: UIViewRepresentable {
    let image: UIImage
    let engine: ImageSearchEngine
    @Binding var isLoading: Bool

    private static let userAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"

    func makeCoordinator() -> Coordinator {
        Coordinator(isLoading: $isLoading)
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .systemBackground
        webView.scrollView.backgroundColor = .systemBackground
        webView.navigationDelegate = context.coordinator
        webView.customUserAgent = Self.userAgent

        if engine == .googleLens {
            // Google Lens returns results directly from POST — load in WebView
            directPostUpload(image: image, engine: engine, webView: webView)
        } else {
            // Other engines redirect after upload — use URLSession first,
            // then load the results URL in the WebView
            twoStepUpload(image: image, engine: engine, webView: webView)
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    // MARK: - Google Lens (direct POST in WebView)

    private func directPostUpload(image: UIImage, engine: ImageSearchEngine, webView: WKWebView) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let imageData = image.jpegData(compressionQuality: 0.6) else { return }
            let request = Self.buildMultipartRequest(engine: engine, imageData: imageData)

            DispatchQueue.main.async {
                webView.load(request)
            }
        }
    }

    // MARK: - Yandex / Bing / TinEye (upload via URLSession, then load results URL)

    private func twoStepUpload(image: UIImage, engine: ImageSearchEngine, webView: WKWebView) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let imageData = image.jpegData(compressionQuality: 0.6) else { return }
            let request = Self.buildMultipartRequest(engine: engine, imageData: imageData)

            // Use a delegate that captures the redirect URL instead of following it
            let delegate = RedirectCaptureDelegate()
            let session = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)

            let task = session.dataTask(with: request) { data, response, error in
                let resultsURL: URL?

                if let redirectURL = delegate.redirectURL {
                    // Engine responded with a redirect — use that URL
                    resultsURL = redirectURL
                } else if let httpResponse = response as? HTTPURLResponse,
                          let location = httpResponse.value(forHTTPHeaderField: "Location"),
                          let url = URL(string: location) {
                    resultsURL = url
                } else if let data {
                    // Try parsing as JSON first (Yandex returns JSON with format=json)
                    if let jsonURL = Self.extractYandexJSONURL(from: data) {
                        resultsURL = jsonURL
                    } else if let html = String(data: data, encoding: .utf8) {
                        // Parse HTML for meta-refresh redirect
                        resultsURL = Self.extractMetaRefreshURL(from: html, baseURL: engine.uploadURL)
                    } else {
                        resultsURL = nil
                    }
                } else {
                    resultsURL = nil
                }

                DispatchQueue.main.async {
                    if let resultsURL {
                        webView.load(URLRequest(url: resultsURL))
                    } else if let data {
                        // Fallback: load raw response content
                        webView.load(data, mimeType: "text/html", characterEncodingName: "utf-8", baseURL: engine.uploadURL)
                    }
                }
            }
            task.resume()
        }
    }

    // MARK: - Build Multipart Request

    private static func buildMultipartRequest(engine: ImageSearchEngine, imageData: Data) -> URLRequest {
        let boundary = UUID().uuidString
        var body = Data()

        // Add extra form fields for engines that need them
        for (name, value) in engine.extraFormFields {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }

        // Add image file field
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(engine.formFieldName)\"; filename=\"\(engine.uploadFilename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        var request = URLRequest(url: engine.uploadURL)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue(engine.referer, forHTTPHeaderField: "Referer")
        request.httpBody = body
        return request
    }

    // MARK: - Parse Yandex JSON response

    private static func extractYandexJSONURL(from data: Data) -> URL? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let blocks = json["blocks"] as? [[String: Any]],
              let firstBlock = blocks.first,
              let params = firstBlock["params"] as? [String: Any],
              let queryString = params["url"] as? String else {
            return nil
        }
        // Yandex returns a query string (e.g. "cbir_id=...&rpt=imageview")
        // Construct full URL: base + "?" + queryString
        return URL(string: "https://yandex.com/images/search?\(queryString)")
    }

    // MARK: - Parse meta-refresh redirect from HTML

    private static func extractMetaRefreshURL(from html: String, baseURL: URL) -> URL? {
        // Look for <meta http-equiv="refresh" content="0;URL='...'" />
        guard let range = html.range(of: "URL=", options: .caseInsensitive) else { return nil }
        let afterURL = html[range.upperBound...]
        let cleaned = afterURL.drop { $0 == "'" || $0 == "\"" }
        let urlString = String(cleaned.prefix(while: { $0 != "'" && $0 != "\"" && $0 != ">" }))
        if urlString.hasPrefix("http") {
            return URL(string: urlString)
        }
        // Relative URL
        return URL(string: urlString, relativeTo: baseURL)
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject, WKNavigationDelegate {
        @Binding var isLoading: Bool

        init(isLoading: Binding<Bool>) {
            _isLoading = isLoading
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            isLoading = false
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            isLoading = false
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            decisionHandler(.allow)
        }
    }
}

// MARK: - URLSession Delegate to Capture Redirect URL

private final class RedirectCaptureDelegate: NSObject, URLSessionTaskDelegate {
    var redirectURL: URL?

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void
    ) {
        // Capture the redirect URL and stop following
        redirectURL = request.url
        completionHandler(nil)
    }
}
