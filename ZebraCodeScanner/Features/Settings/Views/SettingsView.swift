//
//  SettingsView.swift
//  ZebraCodeScanner
//
//  Created by Sardor Islomov on 25/01/26.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.requestReview) private var requestReview
    @AppStorage("vibrateOnScan") private var vibrateOnScan = true
    @AppStorage("soundOnScan") private var soundOnScan = true
    @State private var showClearHistoryAlert = false

    private let dataManager = CoreDataManager.shared

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Scanning") {
                    Toggle("Vibrate on Scan", isOn: $vibrateOnScan)
                    Toggle("Sound on Scan", isOn: $soundOnScan)
                }

                Section("Storage") {
                    HStack {
                        Text("Default Save Location")
                        Spacer()
                        Text("Photos")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Data") {
                    Button("Clear History", role: .destructive) {
                        showClearHistoryAlert = true
                    }
                }

                Section("About") {
                    Button("Rate App") {
                        requestReview()
                    }

                    HStack {
                        Text("Version")
                        Spacer()
                        Text("\(appVersion) (\(buildNumber))")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Clear History", isPresented: $showClearHistoryAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear All", role: .destructive) {
                    dataManager.deleteAllGeneratedCodes()
                    dataManager.deleteAllScannedCodes()
                }
            } message: {
                Text("This will permanently delete all generated and scanned code history.")
            }
        }
    }
}

#Preview {
    SettingsView()
}
