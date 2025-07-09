//
//  AboutView.swift
//  IFFViewer
//
//  Created by Mario Esposito on 7/9/25.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) var dismiss

    var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "N/A"
    }
    var buildNumber: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "N/A"
    }
    var appName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "ADFinder"
    }

    var body: some View {
        VStack(spacing: 15) {
            if let nsImage = NSApp.applicationIconImage {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .shadow(color: .gray.opacity(0.6), radius: 10, x: 0, y: 5)
                    .frame(width: 256, height: 256)
            } else {
                Image(systemName: "magnifyingglass.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.accentColor)
            }

            Text(appName)
                .font(.title2.weight(.semibold))

            Text("Version \(appVersion) (Build \(buildNumber))")
                .font(.callout)
                .foregroundColor(.secondary)

            Text("A modern take to quickly preview Amiga IFF files.\r  Created by Mario Esposito")
                .font(.caption)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Divider()

            Text("CONTRIBUTIONS & DEV TIPS")
                .font(.caption.weight(.semibold))
            HStack(alignment: .top, spacing: 32) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("🔌 Powered by [IFFLib](https://github.com/svanderburg/libiff/tree/master).")
                    Text("🎨 Some icons by [thiings.co](https://thiings.co)")
                    Text("🐛 [Report bugs or suggest features](https://github.com/GINNOV/littlethings/issues)")
                    Text("❣️ Lots of love from the community.")
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("👷🏼‍♂️ Build [IFFLib](https://github.com/GINNOV/littlethings/tree/swiftlibIFF) for macOS.")
                    Text("👷🏼‍♀️ Overall tool's [architecture](https://github.com/GINNOV/littlethings/tree/master/Amiga/Tools/PixDeluxe/distribution/docs).")
                    Text("🌎 More tools available [here](https://ginnov.github.io/littlethings).")
                }
            }
            .font(.caption)
            .padding(.bottom)

            Button("CLOSE") {
                dismiss()
            }
            .keyboardShortcut(.cancelAction)
        }
        .padding(30)
        .frame(minWidth: 320, idealWidth: 350)
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
