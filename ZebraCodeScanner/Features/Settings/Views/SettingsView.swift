//
//  SettingsView.swift
//  ZebraCodeScanner
//
//  Created by Sardor Islomov on 25/01/26.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Scanning") {
                    Toggle("Vibrate on Scan", isOn: .constant(true))
                    Toggle("Sound on Scan", isOn: .constant(true))
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
                        // TODO: Implement clear history
                    }
                }

                Section("About") {
                    Button("Rate App") {
                        // TODO: Implement rate app
                    }

                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
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
        }
    }
}

#Preview {
    SettingsView()
}
