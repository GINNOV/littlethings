import SwiftUI

struct DestinationWorkspaceView: View {
    let destination: AppDestination

    var body: some View {
        switch destination {
        case .live:
            LiveWorkspaceView()
        case .capture:
            CaptureWorkspaceView()
        case .models:
            ModelsWorkspaceView()
        case .runs:
            RunsWorkspaceView()
        case .diagnostics:
            DiagnosticsWorkspaceView()
        }
    }
}
