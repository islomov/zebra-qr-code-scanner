import StoreKit
import UIKit

final class AppRatingService {
    static let shared = AppRatingService()

    private let scanCountKey = "successfulScanCount"
    private let generateCountKey = "successfulGenerateCount"
    private let lastPromptDateKey = "lastRatingPromptDate"

    private let scanThreshold = 3
    private let generateThreshold = 2
    private let cooldownDays = 60

    private init() {}

    func recordSuccessfulScan() {
        let count = UserDefaults.standard.integer(forKey: scanCountKey) + 1
        UserDefaults.standard.set(count, forKey: scanCountKey)
        if count >= scanThreshold {
            requestReviewIfNeeded()
        }
    }

    func recordSuccessfulGeneration() {
        let count = UserDefaults.standard.integer(forKey: generateCountKey) + 1
        UserDefaults.standard.set(count, forKey: generateCountKey)
        if count >= generateThreshold {
            requestReviewIfNeeded()
        }
    }

    private func requestReviewIfNeeded() {
        if let lastDate = UserDefaults.standard.object(forKey: lastPromptDateKey) as? Date {
            let daysSince = Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day ?? 0
            guard daysSince >= cooldownDays else { return }
        }

        guard let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else { return }

        SKStoreReviewController.requestReview(in: scene)

        UserDefaults.standard.set(Date(), forKey: lastPromptDateKey)
        UserDefaults.standard.set(0, forKey: scanCountKey)
        UserDefaults.standard.set(0, forKey: generateCountKey)
    }
}
