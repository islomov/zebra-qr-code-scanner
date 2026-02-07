import SwiftUI

struct ForceUpdateView: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 20) {
                Image(systemName: "arrow.down.app.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(DesignColors.primaryText)

                Text("Update Required")
                    .font(.custom("Inter-SemiBold", size: 20))
                    .tracking(-0.408)
                    .foregroundStyle(DesignColors.primaryText)

                Text("A new version of the app is available.\nPlease update to continue using the app.")
                    .font(.custom("Inter-Regular", size: 14))
                    .tracking(-0.408)
                    .foregroundStyle(DesignColors.secondaryText)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            Button {
                if let url = URL(string: "https://apps.apple.com/app/id6758623522") {
                    UIApplication.shared.open(url)
                }
            } label: {
                Text("Update Now")
                    .font(.custom("Inter-Medium", size: 16))
                    .tracking(-0.408)
                    .frame(maxWidth: .infinity)
                    .frame(height: 51)
                    .background(DesignColors.primaryActionBackground)
                    .foregroundStyle(DesignColors.primaryButtonText)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(DesignColors.background)
        .interactiveDismissDisabled()
    }
}
