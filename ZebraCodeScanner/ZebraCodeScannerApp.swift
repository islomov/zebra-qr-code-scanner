//
//  ZebraCodeScannerApp.swift
//  ZebraCodeScanner
//
//  Created by Sardor Islomov on 25/01/26.
//

import SwiftUI
import FirebaseCore
import FirebaseCrashlytics

@main
struct ZebraCodeScannerApp: App {
    @StateObject private var forceUpdateService = ForceUpdateService()

    init() {
        FirebaseApp.configure()
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
    }
}
