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
        TabView(selection: $selectedTab) {
            GenerateView(showSettings: $showSettings)
                .tabItem {
                    Label("Generate", systemImage: "qrcode")
                }
                .tag(0)

            ScanView(showSettings: $showSettings, viewModel: scanViewModel, isActiveTab: selectedTab == 1)
                .tabItem {
                    Label("Scan", systemImage: "camera.viewfinder")
                }
                .tag(1)

            HistoryView(showSettings: $showSettings)
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
                .tag(2)
        }
        .onChange(of: selectedTab) { [selectedTab] newTab in
            print("[ContentView] Tab switched: \(selectedTab) → \(newTab)")
            if newTab == 1 {
                // Start scanning immediately - camera is kept alive
                scanViewModel.startScanning()
            } else if selectedTab == 1 {
                scanViewModel.stopScanning()
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .preferredColorScheme(colorScheme)
        }
        .preferredColorScheme(colorScheme)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
