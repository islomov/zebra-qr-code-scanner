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
    @State private var showSplash = true

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
            ZStack {
                ContentView()
                    .fullScreenCover(isPresented: $forceUpdateService.requiresUpdate) {
                        ForceUpdateView()
                            .interactiveDismissDisabled()
                    }
                    .onAppear {
                        forceUpdateService.checkForUpdate()
                    }
                    .opacity(showSplash ? 0 : 1)

                if showSplash {
                    SplashScreenView {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showSplash = false
                        }
                    }
                    .transition(.opacity)
                }
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
