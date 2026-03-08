//
//  NetworkManager.swift
//  ZebraCodeScanner
//
//  Created by Sardor Islomov on 25/01/26.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingFailed(Error)
}

final class NetworkManager {
    static let shared = NetworkManager()

    private let session: URLSession

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        self.session = URLSession(configuration: config)
    }

    func fetch<T: Decodable>(_ type: T.Type, from urlString: String) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }

    func fetch<T: Decodable>(_ type: T.Type, request: URLRequest) async throws -> T {
        print("[Network] \(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "nil")")
        if let body = request.httpBody, let bodyStr = String(data: body, encoding: .utf8) {
            print("[Network] Body: \(bodyStr)")
        }
        print("[Network] Headers: \(request.allHTTPHeaderFields ?? [:])")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            print("[Network] No HTTP response")
            throw NetworkError.invalidResponse
        }

        print("[Network] Status: \(httpResponse.statusCode)")
        if let responseStr = String(data: data, encoding: .utf8) {
            print("[Network] Response: \(String(responseStr.prefix(500)))")
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("[Network] Decoding error: \(error)")
            throw NetworkError.decodingFailed(error)
        }
    }
}
