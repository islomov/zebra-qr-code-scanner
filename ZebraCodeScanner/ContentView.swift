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
        .onChange(of: selectedTab) { oldTab, newTab in
            print("[ContentView] Tab switched: \(oldTab) → \(newTab)")
            if newTab == 1 {
                scanViewModel.startScanning()
            } else if oldTab == 1 {
                scanViewModel.stopScanning()
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
}

#Preview {
    ContentView()
}
