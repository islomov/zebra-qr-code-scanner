import SwiftUI

struct ForceUpdateView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "arrow.down.app.fill")
                .font(.system(size: 64))
                .foregroundStyle(.blue)

            Text("Update Required")
                .font(.title.bold())

            Text("A new version of the app is available. Please update to continue using the app.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button {
                // TODO: Replace with your App Store URL
                if let url = URL(string: "https://apps.apple.com/app/idYOUR_APP_ID") {
                    UIApplication.shared.open(url)
                }
            } label: {
                Text("Update Now")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 32)

            Spacer()
        }
        .interactiveDismissDisabled()
    }
}
