import SwiftUI

struct SettingsView: View {
    private enum Tab: String, CaseIterable, Identifiable {
        case general = "General"
        case playback = "Playback"
        case ai = "AI"

        var id: Self { self }

        var systemImage: String {
            switch self {
            case .general: "gearshape"
            case .playback: "play.circle"
            case .ai: "sparkles"
            }
        }
    }

    @State private var selectedTab = Tab.general

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                ForEach(Tab.allCases) { tab in
                    Button {
                        selectedTab = tab
                    } label: {
                        VStack(spacing: 2) {
                            Image(systemName: tab.systemImage)
                                .font(.title2)
                            Text(tab.rawValue)
                                .font(.caption)
                        }
                        .frame(minWidth: 56)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background {
                            if selectedTab == tab {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.accentColor.opacity(0.18))
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityValue(selectedTab == tab ? "Selected" : "")
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 6)

            Group {
                switch selectedTab {
                case .general:
                    GeneralSettingsView()
                case .playback:
                    PlaybackSettingsView()
                case .ai:
                    AISettingsView()
                }
            }
        }
        .frame(width: 720, height: 700)
    }
}
