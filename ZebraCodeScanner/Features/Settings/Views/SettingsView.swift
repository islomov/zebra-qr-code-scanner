//
//  SettingsView.swift
//  ZebraCodeScanner
//
//  Created by Sardor Islomov on 25/01/26.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("vibrateOnScan") private var vibrateOnScan = true
    @AppStorage("soundOnScan") private var soundOnScan = true
    @AppStorage("appearanceMode") private var appearanceMode = "system"
    @State private var showClearHistoryAlert = false
    @State private var showPrivacyPolicy = false
    @State private var showTermsOfUse = false

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
        .alert(String(localized: "settings.data.clear_history_title", defaultValue: "Clear History"), isPresented: $showClearHistoryAlert) {
            Button(String(localized: "common.cancel", defaultValue: "Cancel"), role: .cancel) { }
            Button(String(localized: "settings.data.clear_all", defaultValue: "Clear All"), role: .destructive) {
                dataManager.deleteAllGeneratedCodes()
                dataManager.deleteAllScannedCodes()
            }
        } message: {
            Text(String(localized: "settings.data.clear_history_message", defaultValue: "This will permanently delete all generated and scanned code history."))
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            LegalDocumentView(title: String(localized: "settings.about.privacy_policy", defaultValue: "Privacy Policy"), fileName: "privacy-policy")
        }
        .sheet(isPresented: $showTermsOfUse) {
            LegalDocumentView(title: String(localized: "settings.about.terms_of_use", defaultValue: "Terms of Use"), fileName: "terms-of-use")
        }
    }

    // MARK: - Header

    private var settingsHeader: some View {
        ZStack {
            Text(String(localized: "settings.title", defaultValue: "Settings"))
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
            sectionTitle(String(localized: "settings.scanning.section_title", defaultValue: "Scanning"))

            VStack(spacing: 8) {
                settingsToggleRow(title: String(localized: "settings.scanning.vibrate_on_scan", defaultValue: "Vibrate on Scan"), isOn: $vibrateOnScan)
                settingsToggleRow(title: String(localized: "settings.scanning.sound_on_scan", defaultValue: "Sound on Scan"), isOn: $soundOnScan)
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Storage Section

    private var storageSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle(String(localized: "settings.storage.section_title", defaultValue: "Storage"))

            HStack {
                Text(String(localized: "settings.storage.default_save_location", defaultValue: "Default Save Location"))
                    .font(.custom("Inter-Medium", size: 16))
                    .tracking(-0.408)
                    .foregroundStyle(DesignColors.primaryText)

                Spacer()

                Text(String(localized: "settings.storage.photos", defaultValue: "Photos"))
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
            sectionTitle(String(localized: "settings.appearance.section_title", defaultValue: "Appearance"))

            HStack(spacing: 16) {
                appearanceCard(
                    title: String(localized: "settings.appearance.system", defaultValue: "System"),
                    icon: "circle.lefthalf.filled",
                    iconBgColor: Color(red: 0x35/255, green: 0x35/255, blue: 0x35/255),
                    isSelected: appearanceMode == "system"
                ) {
                    appearanceMode = "system"
                }

                appearanceCard(
                    title: String(localized: "settings.appearance.light", defaultValue: "Light"),
                    icon: "sun.max.fill",
                    iconBgColor: Color.white,
                    isSelected: appearanceMode == "light"
                ) {
                    appearanceMode = "light"
                }

                appearanceCard(
                    title: String(localized: "settings.appearance.dark", defaultValue: "Dark"),
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
            sectionTitle(String(localized: "settings.data.section_title", defaultValue: "Data"))

            Button {
                showClearHistoryAlert = true
            } label: {
                HStack {
                    Text(String(localized: "settings.data.clear_history", defaultValue: "Clear History"))
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
            sectionTitle(String(localized: "settings.about.section_title", defaultValue: "About"))

            VStack(spacing: 0) {
                // Rate app row (top rounded)
                Button {
                    if let url = URL(string: "https://apps.apple.com/app/id6758623522?action=write-review") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    HStack {
                        Text(String(localized: "settings.about.rate_app", defaultValue: "Rate app"))
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
                    showPrivacyPolicy = true
                } label: {
                    HStack {
                        Text(String(localized: "settings.about.privacy_policy", defaultValue: "Privacy Policy"))
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
                    showTermsOfUse = true
                } label: {
                    HStack {
                        Text(String(localized: "settings.about.terms_of_use", defaultValue: "Terms of Use"))
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
                    Text(String(localized: "settings.about.version", defaultValue: "Version"))
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
