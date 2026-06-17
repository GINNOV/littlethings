import AppKit
import SwiftUI

struct AboutView: View {
    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }

    private var buildNumber: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    }

    private var appName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
            ?? "Amiga ROM Explorer"
    }

    var body: some View {
        VStack(spacing: 15) {
            if let icon = NSApp.applicationIconImage {
                Image(nsImage: icon)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .shadow(color: .gray.opacity(0.5), radius: 10, x: 0, y: 5)
                    .frame(width: 128, height: 128)
            } else {
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 96, height: 96)
            }

            Text(appName)
                .font(.title2.weight(.semibold))

            Text("Version \(appVersion) (Build \(buildNumber))")
                .font(.callout)
                .foregroundStyle(.secondary)

            Text("The ultimate Amiga firmware atlas. Browse a shipped reference catalog of Kickstart, extended ROM, boot, and cartridge images — with or without local ROM files.")
                .font(.caption)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundStyle(.secondary)

            Divider()

            Text("FEATURES")
                .font(.caption.weight(.semibold))

            VStack(alignment: .leading, spacing: 4) {
                Text("📚 Shipped reference catalog and research cache")
                Text("🖥️ Hardware mapping for every firmware entry")
                Text("📁 Optional local ROM folder scanning")
                Text("🤖 Optional Ollama sub-agent deep research")
            }
            .font(.caption)
            .frame(maxWidth: .infinity, alignment: .leading)

            Divider()

            Text("CONTRIBUTIONS & LINKS")
                .font(.caption.weight(.semibold))

            HStack(alignment: .top, spacing: 32) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("👤 Created by [Mario Esposito](https://github.com/GINNOV)")
                    Text("🐛 [Report bugs or suggest features](https://github.com/GINNOV/littlethings/issues)")
                    Text("🌎 More Amiga tools [here](https://ginnov.github.io/littlethings)")
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("🧠 Optional [Ollama](https://ollama.com) enrichment")
                    Text("📦 Part of [littlethings](https://github.com/GINNOV/littlethings)")
                    Text("❣️ Built for Amiga preservationists.")
                }
            }
            .font(.caption)
        }
        .padding(30)
        .frame(width: 520)
    }
}