//
//  NotificationService.swift
//  ZebraCodeScanner
//
//  Created by Sardor Islomov on 08/02/26.
//

import Combine
import Foundation
import UserNotifications

@MainActor
final class NotificationService: ObservableObject {

    static let shared = NotificationService()

    @Published var isAuthorized: Bool = false

    private static let notificationIdentifierPrefix = "zebra_daily_"

    // MARK: - Message Pool

    private var messages: [(title: String, body: String)] {
        [
            // Product Lookup
            (title: String(localized: "notification.title.product_lookup", defaultValue: "Discover Products"),
             body: String(localized: "notification.body.product_lookup_1", defaultValue: "Scan any barcode to discover product details instantly!")),
            (title: String(localized: "notification.title.product_lookup", defaultValue: "Discover Products"),
             body: String(localized: "notification.body.product_lookup_2", defaultValue: "Curious about a product? Scan its barcode for instant info!")),
            (title: String(localized: "notification.title.product_lookup", defaultValue: "Discover Products"),
             body: String(localized: "notification.body.product_lookup_3", defaultValue: "Wondering what's in that product? Scan and find out!")),

            // QR Code Scanning
            (title: String(localized: "notification.title.qr_scan", defaultValue: "QR Code Ready"),
             body: String(localized: "notification.body.qr_scan_1", defaultValue: "Found a QR code? Scan it in seconds!")),
            (title: String(localized: "notification.title.qr_scan", defaultValue: "QR Code Ready"),
             body: String(localized: "notification.body.qr_scan_2", defaultValue: "QR codes are everywhere! Open Zebra to scan one now.")),
            (title: String(localized: "notification.title.qr_scan", defaultValue: "QR Code Ready"),
             body: String(localized: "notification.body.qr_scan_3", defaultValue: "See a QR code on a poster or package? Scan it instantly!")),

            // Barcode Scanning
            (title: String(localized: "notification.title.barcode_scan", defaultValue: "Barcode Scanner"),
             body: String(localized: "notification.body.barcode_scan_1", defaultValue: "Need to check a product? Scan its barcode now!")),
            (title: String(localized: "notification.title.barcode_scan", defaultValue: "Barcode Scanner"),
             body: String(localized: "notification.body.barcode_scan_2", defaultValue: "Shopping? Scan barcodes to compare products easily!")),
            (title: String(localized: "notification.title.barcode_scan", defaultValue: "Barcode Scanner"),
             body: String(localized: "notification.body.barcode_scan_3", defaultValue: "Your barcode scanner is ready. Check any product in a tap!")),
        ]
    }

    private init() {
        Task {
            await checkAuthorizationStatus()
        }
    }

    // MARK: - Permission

    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            isAuthorized = granted
            return granted
        } catch {
            print("[Notifications] Permission request error: \(error.localizedDescription)")
            isAuthorized = false
            return false
        }
    }

    func checkAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }

    // MARK: - Scheduling

    /// Reschedules only if 2 or fewer notifications remain pending.
    /// Called on every foreground entry to keep the 7-day window fresh
    /// without disrupting already-scheduled notifications.
    func rescheduleIfNeeded() async {
        let center = UNUserNotificationCenter.current()
        let pending = await center.pendingNotificationRequests()
        let ours = pending.filter { $0.identifier.hasPrefix(Self.notificationIdentifierPrefix) }

        if ours.count <= 2 {
            scheduleDailyNotifications()
        } else {
            print("[Notifications] \(ours.count) notifications still pending, skipping reschedule")
        }
    }

    func scheduleDailyNotifications() {
        let center = UNUserNotificationCenter.current()

        // Remove existing scheduled notifications from this feature
        let identifiers = (0..<7).map { "\(Self.notificationIdentifierPrefix)\($0)" }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)

        // Schedule 7 daily notifications at 6:00 PM
        // Start from today if 6 PM hasn't passed yet, otherwise start from tomorrow
        let now = Date()
        let calendar = Calendar.current
        let todayAt6PM = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: now)!
        let startOffset = now < todayAt6PM ? 0 : 1

        for i in 0..<7 {
            let dayOffset = startOffset + i
            guard let message = messages.randomElement(),
                  let futureDate = calendar.date(byAdding: .day, value: dayOffset, to: now) else {
                continue
            }

            let content = UNMutableNotificationContent()
            content.title = message.title
            content.body = message.body
            content.sound = .default

            var dateComponents = calendar.dateComponents(
                [.year, .month, .day],
                from: futureDate
            )
            dateComponents.hour = 18
            dateComponents.minute = 0

            let trigger = UNCalendarNotificationTrigger(
                dateMatching: dateComponents, repeats: false
            )

            let request = UNNotificationRequest(
                identifier: "\(Self.notificationIdentifierPrefix)\(i)",
                content: content,
                trigger: trigger
            )

            center.add(request) { error in
                if let error {
                    print("[Notifications] Schedule error: \(error.localizedDescription)")
                }
            }
        }

        print("[Notifications] Scheduled 7 daily notifications at 6:00 PM")
    }

    func cancelAllNotifications() {
        let center = UNUserNotificationCenter.current()
        let identifiers = (0..<7).map { "\(Self.notificationIdentifierPrefix)\($0)" }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        print("[Notifications] Cancelled all daily notifications")
    }
}
