import Combine
import Foundation
import FirebaseRemoteConfig

@MainActor
final class ForceUpdateService: ObservableObject {
    @Published var requiresUpdate = false

    private let remoteConfig = RemoteConfig.remoteConfig()

    func checkForUpdate() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings

        Task {
            do {
                let status = try await remoteConfig.fetchAndActivate()
                print("[ForceUpdate] Remote Config status: \(status)")

                let rawValue = remoteConfig.configValue(forKey: "minimum_app_version").stringValue
                    .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines.union(CharacterSet(charactersIn: "\"")))
                let minimumVersion = rawValue.isEmpty ? "1.0.0" : rawValue

                let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"

                print("[ForceUpdate] current=\(currentVersion) minimum=\(minimumVersion)")
                requiresUpdate = isVersion(currentVersion, lessThan: minimumVersion)
                print("[ForceUpdate] requiresUpdate=\(requiresUpdate)")
            } catch {
                print("[ForceUpdate] Remote Config fetch error: \(error.localizedDescription)")
            }
        }
    }

    private func isVersion(_ current: String, lessThan minimum: String) -> Bool {
        let currentParts = current.split(separator: ".").compactMap { Int($0) }
        let minimumParts = minimum.split(separator: ".").compactMap { Int($0) }

        for i in 0..<max(currentParts.count, minimumParts.count) {
            let c = i < currentParts.count ? currentParts[i] : 0
            let m = i < minimumParts.count ? minimumParts[i] : 0
            if c < m { return true }
            if c > m { return false }
        }
        return false
    }
}
