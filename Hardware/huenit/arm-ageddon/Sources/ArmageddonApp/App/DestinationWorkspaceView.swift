import SwiftUI

struct DestinationWorkspaceView: View {
    let destination: AppDestination
    let recoveryAction: @MainActor () -> Void

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
            DiagnosticsWorkspaceView(recoveryAction: recoveryAction)
        }
    }
}
