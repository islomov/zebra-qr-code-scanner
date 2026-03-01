//
//  ContentView.swift
//  ZebraCodeScanner
//
//  Created by Sardor Islomov on 25/01/26.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showSettings = false
    @StateObject private var scanViewModel = ScanViewModel()
    @AppStorage("appearanceMode") private var appearanceMode = "system"

    private var colorScheme: ColorScheme? {
        switch appearanceMode {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case 1:
                    ScanView(showSettings: $showSettings, viewModel: scanViewModel)
                case 2:
                    HistoryView(showSettings: $showSettings)
                default:
                    GenerateView(showSettings: $showSettings)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            FloatingTabBar(selectedTab: $selectedTab)
                .padding(.bottom, 12)
        }
        .ignoresSafeArea(.keyboard)
        .onChange(of: selectedTab) { newTab in
            if newTab == 1 {
                scanViewModel.startScanning()
            } else {
                scanViewModel.stopScanning()
            }
        }
        .onChange(of: showSettings) { isShowing in
            if isShowing {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .preferredColorScheme(colorScheme)
        }
        .preferredColorScheme(colorScheme)
    }
}

private struct FloatingTabBar: View {
    @Binding var selectedTab: Int

    private let tabs: [(icon: String, tag: Int)] = [
        ("icon-qr", 0),
        ("icon-scan", 1),
        ("icon-history", 2)
    ]

    var body: some View {
        HStack(spacing: 20) {
            ForEach(tabs, id: \.tag) { tab in
                TabBarButton(
                    icon: tab.icon,
                    isSelected: selectedTab == tab.tag
                ) {
                    selectedTab = tab.tag
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color(UIColor { tc in
                    tc.userInterfaceStyle == .dark ? .white : UIColor(red: 0x1E/255, green: 0x1E/255, blue: 0x1E/255, alpha: 1)
                }))
                .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 4)
                .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 1)
        )
    }
}

private struct TabBarButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                action()
            }
        } label: {
            Image(icon)
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
                .foregroundColor(isSelected ? DesignColors.primaryButtonText : DesignColors.inactive)
                .padding(10)
                .background(
                    Circle()
                        .fill(isSelected ? DesignColors.primaryButtonText.opacity(0.12) : .clear)
                )
        }
        .buttonStyle(.plain)
        .animation(nil, value: isSelected)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
