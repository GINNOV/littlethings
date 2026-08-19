import ArmageddonCore
import SwiftUI

struct FixtureLaunchView: View {
    let profile: LaunchProfile?

    var body: some View {
        VStack(spacing: 12) {
            Text(ArmageddonCore.productName)
                .font(.title)
            if let profile {
                Text(profile.title)
                    .accessibilityIdentifier("launch.profile.\(profile.rawValue)")
                Text("Fixture state ready")
                    .accessibilityIdentifier("launch.ready")
            } else {
                Text("Fixture configuration failed")
                    .accessibilityIdentifier("launch.failed")
            }
        }
        .padding(32)
    }
}
