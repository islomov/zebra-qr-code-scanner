//
//  TrackingService.swift
//  ZebraCodeScanner
//
//  Created by Sardor Islomov on 11/02/26.
//

import AdSupport
import AppTrackingTransparency
import Combine

@MainActor
final class TrackingService: ObservableObject {

    static let shared = TrackingService()

    @Published var isAuthorized: Bool = false

    private init() {
        updateStatus()
    }

    func requestTrackingPermission() {
        guard ATTrackingManager.trackingAuthorizationStatus == .notDetermined else {
            updateStatus()
            return
        }

        ATTrackingManager.requestTrackingAuthorization { status in
            DispatchQueue.main.async {
                self.updateStatus()

                switch status {
                case .authorized:
                    let idfa = ASIdentifierManager.shared().advertisingIdentifier
                    print("[Tracking] Authorized. IDFA: \(idfa.uuidString)")
                case .denied:
                    print("[Tracking] Denied by user")
                case .restricted:
                    print("[Tracking] Restricted")
                case .notDetermined:
                    print("[Tracking] Not determined")
                @unknown default:
                    print("[Tracking] Unknown status: \(status.rawValue)")
                }
            }
        }
    }

    func updateStatus() {
        isAuthorized = ATTrackingManager.trackingAuthorizationStatus == .authorized
    }
}
