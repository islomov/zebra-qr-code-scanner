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
    @AppStorage("appearanceMode") private var appearanceMode = "system"
    @State private var showClearHistoryAlert = false

    private let dataManager = CoreDataManager.shared

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            settingsHeader

            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    scanningSection
                    storageSection
                    appearanceSection
                    dataSection
                    aboutSection
                }
                .padding(.top, 0)
            }
        }
        .background(DesignColors.background)
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

    // MARK: - Header

    private var settingsHeader: some View {
        ZStack {
            Text("Settings")
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
    }

    // MARK: - Scanning Section

    private var scanningSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("Scanning")

            VStack(spacing: 8) {
                settingsToggleRow(title: "Vibrate on Scan", isOn: $vibrateOnScan)
                settingsToggleRow(title: "Sound on Scan", isOn: $soundOnScan)
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Storage Section

    private var storageSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("Storage")

            HStack {
                Text("Default Save Location")
                    .font(.custom("Inter-Medium", size: 16))
                    .tracking(-0.408)
                    .foregroundStyle(DesignColors.primaryText)

                Spacer()

                Text("Photos")
                    .font(.custom("Inter-Regular", size: 14))
                    .tracking(-0.408)
                    .foregroundStyle(DesignColors.secondaryText)
            }
            .padding(20)
            .frame(height: 58)
            .background(DesignColors.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(DesignColors.stroke, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Appearance Section

    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("Appearance")

            HStack(spacing: 16) {
                appearanceCard(
                    title: "System",
                    icon: "circle.lefthalf.filled",
                    iconBgColor: Color(red: 0x35/255, green: 0x35/255, blue: 0x35/255),
                    isSelected: appearanceMode == "system"
                ) {
                    appearanceMode = "system"
                }

                appearanceCard(
                    title: "Light",
                    icon: "sun.max.fill",
                    iconBgColor: Color.white,
                    isSelected: appearanceMode == "light"
                ) {
                    appearanceMode = "light"
                }

                appearanceCard(
                    title: "Dark",
                    icon: "moon.fill",
                    iconBgColor: Color.white,
                    isSelected: appearanceMode == "dark"
                ) {
                    appearanceMode = "dark"
                }
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Data Section

    private var dataSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("Data")

            Button {
                showClearHistoryAlert = true
            } label: {
                HStack {
                    Text("Clear History")
                        .font(.custom("Inter-Medium", size: 16))
                        .tracking(-0.408)
                        .foregroundStyle(Color(red: 0xE8/255, green: 0x10/255, blue: 0x10/255))

                    Spacer()
                }
                .padding(20)
                .frame(height: 58)
                .background(DesignColors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(DesignColors.stroke, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
    }

    // MARK: - About Section

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("About")

            VStack(spacing: 0) {
                // Rate app row (top rounded)
                Button {
                    requestReview()
                } label: {
                    HStack {
                        Text("Rate app")
                            .font(.custom("Inter-Medium", size: 16))
                            .tracking(-0.408)
                            .foregroundStyle(DesignColors.primaryText)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(DesignColors.secondaryText)
                    }
                    .padding(20)
                    .frame(height: 58)
                    .background(DesignColors.cardBackground)
                }
                .buttonStyle(.plain)

                Divider()
                    .background(DesignColors.stroke)

                // Privacy Policy row
                Button {
                    if let url = URL(string: "https://viralapps.studio/privacy-policy") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    HStack {
                        Text("Privacy Policy")
                            .font(.custom("Inter-Medium", size: 16))
                            .tracking(-0.408)
                            .foregroundStyle(DesignColors.primaryText)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(DesignColors.secondaryText)
                    }
                    .padding(20)
                    .frame(height: 58)
                    .background(DesignColors.cardBackground)
                }
                .buttonStyle(.plain)

                Divider()
                    .background(DesignColors.stroke)

                // Terms of Use row
                Button {
                    if let url = URL(string: "https://viralapps.studio/terms-of-use") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    HStack {
                        Text("Terms of Use")
                            .font(.custom("Inter-Medium", size: 16))
                            .tracking(-0.408)
                            .foregroundStyle(DesignColors.primaryText)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(DesignColors.secondaryText)
                    }
                    .padding(20)
                    .frame(height: 58)
                    .background(DesignColors.cardBackground)
                }
                .buttonStyle(.plain)

                Divider()
                    .background(DesignColors.stroke)

                // Version row (bottom rounded)
                HStack {
                    Text("Version")
                        .font(.custom("Inter-Medium", size: 16))
                        .tracking(-0.408)
                        .foregroundStyle(DesignColors.secondaryText)

                    Spacer()

                    Text("\(appVersion) (\(buildNumber))")
                        .font(.custom("Inter-Regular", size: 14))
                        .tracking(-0.408)
                        .foregroundStyle(DesignColors.secondaryText)
                }
                .padding(20)
                .frame(height: 58)
                .background(DesignColors.cardBackground)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(DesignColors.stroke, lineWidth: 1)
            )
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 24)
    }

    // MARK: - Components

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.custom("Inter-Medium", size: 16))
            .tracking(-0.408)
            .foregroundStyle(DesignColors.secondaryText)
            .padding(.leading, 20)
    }

    private func settingsToggleRow(title: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Text(title)
                .font(.custom("Inter-Medium", size: 16))
                .tracking(-0.408)
                .foregroundStyle(DesignColors.primaryText)

            Spacer()

            // Custom toggle
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isOn.wrappedValue.toggle()
                }
            } label: {
                ZStack(alignment: isOn.wrappedValue ? .trailing : .leading) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isOn.wrappedValue ? DesignColors.primaryText : Color(red: 0xE0/255, green: 0xE0/255, blue: 0xE0/255))
                        .frame(width: 40, height: 24)

                    Circle()
                        .fill(DesignColors.primaryButtonText)
                        .frame(width: 20, height: 20)
                        .padding(2)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .frame(height: 58)
        .background(DesignColors.cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(DesignColors.stroke, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func appearanceCard(title: String, icon: String, iconBgColor: Color, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                action()
            }
        } label: {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(iconBgColor)
                        .frame(width: 36, height: 36)

                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(iconBgColor == .white ? Color(red: 0x1E/255, green: 0x1E/255, blue: 0x1E/255) : .white)
                }

                Text(title)
                    .font(.custom("Inter-Medium", size: 16))
                    .tracking(-0.408)
                    .foregroundStyle(DesignColors.primaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(DesignColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? DesignColors.primaryText : Color.clear, lineWidth: 1)
            )
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 17))
                        .foregroundStyle(DesignColors.primaryText)
                        .offset(x: -7, y: 7)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
