//
//  AboutView.swift
//  ADFinder
//
//  Created by Mario Esposito on 5/23/25.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) var dismiss

    // These will get the values from your app's Info.plist
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
                    .frame(width: 128, height: 128)
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

            Text("A Finder tool for Amiga Disk Files (ADF). Created by Mario Esposito")
                .font(.caption)

            Divider()

            Text("CONTRIBUTIONS & DEV TIPS")
                .font(.caption.weight(.semibold))
            HStack(alignment: .top, spacing: 32) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("🔌 Powered by [ADFLib](https://github.com/adflib/ADFlib).")
                    Text("🎨 Some icons by [thiings.co](https://thiings.co)")
                    Text("🐛 [Report bugs or suggest features](https://github.com/GINNOV/littlethings/issues)")
                    Text("❣️ Lots of love from the community.")
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("👷🏼‍♂️ Build [ADFLib](https://github.com/GINNOV/littlethings/tree/master/Amiga/Tools/ADFinder/distribution/docs/build_adflib.md) for macOS.")
                    Text("👷🏼‍♀️ Overall tool's [architecture](https://github.com/GINNOV/littlethings/tree/master/Amiga/Tools/ADFinder/distribution/docs).")
                }
            }
            .font(.caption)
            .padding(.bottom)

            Button("Close") {
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
