//
//  GoogleLensView.swift
//  ZebraCodeScanner
//
//  Created by Sardor Islomov on 01/03/26.
//

import SwiftUI
import WebKit

struct GoogleLensView: View {
    @Environment(\.dismiss) private var dismiss

    let image: UIImage?

    @State private var isLoading = true

    var body: some View {
        VStack(spacing: 0) {
            // Header
            ZStack {
                Text(String(localized: "google_lens.title", defaultValue: "Photo Search"))
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
            .padding(.bottom, 16)

            ZStack {
                if let image {
                    // Only create WKWebView once image is ready
                    GoogleLensWebView(image: image, isLoading: $isLoading)
                }

                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .controlSize(.large)
                        Text(String(localized: "google_lens.searching", defaultValue: "Searching..."))
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
}

// MARK: - Google Lens WebView

private struct GoogleLensWebView: UIViewRepresentable {
    let image: UIImage
    @Binding var isLoading: Bool

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
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"

        uploadImageToGoogleLens(image: image, webView: webView)

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    private func uploadImageToGoogleLens(image: UIImage, webView: WKWebView) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let imageData = image.jpegData(compressionQuality: 0.6) else { return }

            let boundary = UUID().uuidString
            var body = Data()
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"encoded_image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

            var request = URLRequest(url: URL(string: "https://lens.google.com/v3/upload")!)
            request.httpMethod = "POST"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
            request.httpBody = body

            DispatchQueue.main.async {
                webView.load(request)
            }
        }
    }

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
