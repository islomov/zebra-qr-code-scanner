//
//  ZebraCodeScannerApp.swift
//  ZebraCodeScanner
//
//  Created by Sardor Islomov on 25/01/26.
//

import SwiftUI
import CoreText
import FirebaseCore
import FirebaseAnalytics
import FirebaseCrashlytics

@main
struct ZebraCodeScannerApp: App {
    @StateObject private var forceUpdateService = ForceUpdateService()
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false

    init() {
        FirebaseApp.configure()
        Self.registerCustomFonts()
    }

    private static func registerCustomFonts() {
        let fontFileNames = ["Inter-Regular", "Inter-Medium", "Inter-SemiBold"]
        for fontFileName in fontFileNames {
            guard let fontURL = Bundle.main.url(forResource: fontFileName, withExtension: "ttf") else {
                continue
            }
            CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .fullScreenCover(isPresented: $forceUpdateService.requiresUpdate) {
                    ForceUpdateView()
                        .interactiveDismissDisabled()
                }
                .onAppear {
                    forceUpdateService.checkForUpdate()
                }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active && notificationsEnabled {
                Task {
                    await NotificationService.shared.checkAuthorizationStatus()
                    if NotificationService.shared.isAuthorized {
                        await NotificationService.shared.rescheduleIfNeeded()
                    }
                }
            }
        }
    }
}
