//
//  LegalDocumentView.swift
//  ZebraCodeScanner
//
//  Created by Sardor Islomov on 05/02/26.
//

import SwiftUI
import WebKit

struct LegalDocumentView: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    let fileName: String

    @State private var isLoading = true

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text(title)
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
                LegalWebView(fileName: fileName, isLoading: $isLoading)

                if isLoading {
                    ProgressView()
                        .controlSize(.large)
                }
            }
        }
        .background(DesignColors.background)
    }
}

private struct LegalWebView: UIViewRepresentable {
    let fileName: String
    @Binding var isLoading: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(isLoading: $isLoading)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.navigationDelegate = context.coordinator

        if let url = Bundle.main.url(forResource: fileName, withExtension: "html") {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

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
    }
}
