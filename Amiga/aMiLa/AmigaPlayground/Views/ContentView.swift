import SwiftUI
import Combine
import UniformTypeIdentifiers
import AppKit

struct AmigaPlaygroundActions {
    let assemble: () -> Void
    let fixCompileErrors: () -> Void
    let openPromptLibrary: () -> Void
    let openExampleLibrary: () -> Void
    let saveCode: () -> Void
    let indentCode: () -> Void
    let runDefaultEmulator: () -> Void
    let validateVAmiga: () -> Void
    let runWebEmulator: () -> Void
    let exportADF: () -> Void
    let newChat: () -> Void
    let clearEditor: () -> Void
    let canRun: Bool
    let canChat: Bool
    let canFixCompileErrors: Bool
}

private struct AmigaPlaygroundActionsKey: FocusedValueKey {
    typealias Value = AmigaPlaygroundActions
}

extension FocusedValues {
    var amigaPlaygroundActions: AmigaPlaygroundActions? {
        get { self[AmigaPlaygroundActionsKey.self] }
        set { self[AmigaPlaygroundActionsKey.self] = newValue }
    }
}

enum AppPreferenceDefaults {
    static let showChatBoingBallKey = "showChatBoingBall"
    static let showChatBoingBall = true
    static let autoInjectGeneratedCodeKey = "autoInjectGeneratedCode"
    static let autoInjectGeneratedCode = true
}

struct AmigaPlaygroundCommands: Commands {
    @FocusedValue(\.amigaPlaygroundActions) private var actions

    var body: some Commands {
        CommandMenu("Playground") {
            if let actions {
                Button("Assemble") {
                    actions.assemble()
                }
                .disabled(!actions.canRun)
                .keyboardShortcut("r", modifiers: .command)

                Button("Fix Compile Errors with Assistant") {
                    actions.fixCompileErrors()
                }
                .disabled(!actions.canFixCompileErrors)
                .keyboardShortcut("f", modifiers: [.command, .option])

                Button("Prompt Library") {
                    actions.openPromptLibrary()
                }
                .keyboardShortcut("l", modifiers: [.command, .option])

                Button("Example Library") {
                    actions.openExampleLibrary()
                }
                .keyboardShortcut("e", modifiers: [.command, .option])

                Button("Save Code...") {
                    actions.saveCode()
                }
                .keyboardShortcut("s", modifiers: .command)

                Button("Indent Code") {
                    actions.indentCode()
                }
                .keyboardShortcut("i", modifiers: [.command, .option])

                Button("Export Bootable ADF...") {
                    actions.exportADF()
                }
                .disabled(!actions.canRun)

                Button("New Chat") {
                    actions.newChat()
                }
                .disabled(!actions.canChat)
                .keyboardShortcut("n", modifiers: [.command, .shift])

                Button("Clear Editor") {
                    actions.clearEditor()
                }
            }
        }

        CommandMenu("Emulator") {
            if let actions {
                Button("Run Default Emulator") {
                    actions.runDefaultEmulator()
                }
                .disabled(!actions.canRun)
                .keyboardShortcut("r", modifiers: [.command, .shift])

                Divider()

                Button("Validate with vAmiga") {
                    actions.validateVAmiga()
                }
                .disabled(!actions.canRun)

                Button("Run Web Emulator") {
                    actions.runWebEmulator()
                }
                .disabled(!actions.canRun)
            }
        }

    }
}

enum OutputTab: String, CaseIterable, Identifiable {
    case console = "Console"
    case thinking = "Thinking Process"
    case emulator = "Web Emulator"
    
    var id: String { self.rawValue }
}

struct ContentView: View {
    @StateObject private var llm = OllamaService.shared
    @StateObject private var mlxServer = MLXServerController.shared
    @Environment(\.openWindow) private var openWindow

    enum BuildStatus {
        case idle
        case running
        case success
        case failure

        var label: String {
            switch self {
            case .idle:
                return "IDLE"
            case .running:
                return "RUNNING"
            case .success:
                return "VALID"
            case .failure:
                return "ERROR"
            }
        }

        var detailLabel: String {
            switch self {
            case .idle:
                return "IDLE"
            case .running:
                return "RUNNING"
            case .success:
                return "VALID"
            case .failure:
                return "COMPILER ERROR"
            }
        }

        var color: Color {
            switch self {
            case .idle:
                return Color(red: 0.45, green: 0.82, blue: 1.0)
            case .running:
                return .orange
            case .success:
                return .green
            case .failure:
                return .red
            }
        }

        var accessibilityColorName: String {
            switch self {
            case .idle:
                return "light blue"
            case .running:
                return "orange"
            case .success:
                return "green"
            case .failure:
                return "red"
            }
        }
    }

    // Editor State
    @State private var codeText: String = """
; ==========================================================
;   Amiga 68000 Copper List Example
;   Generates a classic vertical raster rainbow bar
;   (System-friendly graphics.library takeover)
; ==========================================================

            SECTION    Code,CODE,CHIP       ; Must be in CHIP RAM!

            XDEF       _StartCopper
_StartCopper:
            movem.l    d2-d7/a2-a6,-(sp)    ; Save registers

            ; 1. Open Graphics Library
            move.l     $4.w,a6              ; ExecBase
            lea        gfxName(pc),a1
            moveq      #0,d0
            jsr        -408(a6)             ; OpenLibrary
            move.l     d0,GfxBase
            beq.s      .exit

            ; 2. Shut down OS View/Display (System-friendly loadview)
            move.l     GfxBase(pc),a6
            move.l     34(a6),oldView       ; Save GfxBase->ActiView (offset 34)

            sub.l      a1,a1                ; Load NULL view (turns off OS screen)
            jsr        -222(a6)             ; LoadView(NULL)
            jsr        -270(a6)             ; WaitTOF()
            jsr        -270(a6)             ; Double WaitTOF for interlaced setup

            ; 3. Setup Custom Copper List
            lea        $dff000,a5
            lea        CopperList(pc),a0
            move.l     a0,$80(a5)           ; Write COP1LC ($DFF080)
            move.w     #$0000,$88(a5)       ; Strobe COPJMP1 ($DFF088) to activate

            ; Enable copper DMA
            move.w     #$8280,$96(a5)       ; DMACON: set COPEN and DMAEN

.waitButton:
            ; Wait for left mouse button (Port $bfe001, bit 6)
            btst       #6,$bfe001
            bne.s      .waitButton

            ; 4. Restore OS View and Copper
            move.l     GfxBase(pc),a6
            move.l     oldView(pc),a1       ; Load old view pointer
            jsr        -222(a6)             ; LoadView(oldView)
            jsr        -270(a6)             ; WaitTOF()
            jsr        -270(a6)             ; WaitTOF()

            ; Close Graphics Library
            move.l     $4.w,a6
            move.l     GfxBase(pc),a1
            jsr        -414(a6)             ; CloseLibrary

.exit:
            movem.l    (sp)+,d2-d7/a2-a6    ; Restore registers
            moveq      #0,d0                ; Return 0
            rts

gfxName:    dc.b       "graphics.library",0
            EVEN
GfxBase:    dc.l       0
oldView:    dc.l       0

            ALIGN      4
CopperList:
            ; Custom screen copper instructions
            dc.w       $0100,$0200          ; BPLCON0: disable all bitplanes (black screen)

            ; Vertical color raster splits
            dc.w       $5007,$fffe          ; Wait for line 80
            dc.w       $0180,$0f00          ; Color 0 = Red
            dc.w       $5807,$fffe          ; Wait for line 88
            dc.w       $0180,$0f70          ; Color 0 = Orange
            dc.w       $6007,$fffe          ; Wait for line 96
            dc.w       $0180,$0ff0          ; Color 0 = Yellow
            dc.w       $6807,$fffe          ; Wait for line 104
            dc.w       $0180,$00f0          ; Color 0 = Green
            dc.w       $7007,$fffe          ; Wait for line 112
            dc.w       $0180,$00ff          ; Color 0 = Cyan
            dc.w       $7807,$fffe          ; Wait for line 120
            dc.w       $0180,$000f          ; Color 0 = Blue
            dc.w       $8007,$fffe          ; Wait for line 128
            dc.w       $0180,$0f0f          ; Color 0 = Purple
            dc.w       $8807,$fffe          ; Wait for line 136
            dc.w       $0180,$0000          ; Color 0 = Black

            dc.w       $ffff,$fffe          ; End of copper list
"""


    // Persisted Amiga Hardware Settings
    @AppStorage("emulatorModel") private var emulatorModel: String = "A500"
    @AppStorage("emulatorCpu") private var emulatorCpu: String = "68000"
    @AppStorage("emulatorChipRam") private var emulatorChipRam: String = "512 KB"
    @AppStorage("emulatorFastRam") private var emulatorFastRam: String = "0 MB"
    @AppStorage("emulatorJit") private var emulatorJit: Bool = false
    @AppStorage("selectedRomFilename") private var selectedRomFilename: String = ""
    @AppStorage("emulatorCustomArgs") private var emulatorCustomArgs: String = ""
    @AppStorage("emulatorBackend") private var emulatorBackend: String = EmulatorBackend.fsUAE.rawValue
    @AppStorage("vAmigaExecutablePath") private var vAmigaExecutablePath: String = "/Applications/vAmiga.app/Contents/MacOS/vAmiga"
    @AppStorage("vAmigaCustomArgs") private var vAmigaCustomArgs: String = ""
    @AppStorage("vAmigaAutoConfigureServers") private var vAmigaAutoConfigureServers: Bool = true
    @AppStorage("vAmigaRemoteShellPort") private var vAmigaRemoteShellPort: Int = 8080
    @AppStorage("vAmigaRPCPort") private var vAmigaRPCPort: Int = 8081
    @AppStorage("vAmigaPrometheusPort") private var vAmigaPrometheusPort: Int = 8083
    @AppStorage("vAmigaSerialPort") private var vAmigaSerialPort: Int = 8085
    @AppStorage("autoRunEmulator") private var autoRunEmulator: Bool = false
    @AppStorage(AppPreferenceDefaults.showChatBoingBallKey) private var showChatBoingBall: Bool = AppPreferenceDefaults.showChatBoingBall
    @AppStorage(AppPreferenceDefaults.autoInjectGeneratedCodeKey) private var autoInjectGeneratedCode: Bool = AppPreferenceDefaults.autoInjectGeneratedCode

    // Compilation & Output State
    @State private var outputConsole: String = "VASM compiler idle.\nPress Assemble to build the program."
    @State private var isCompiling: Bool = false
    @State private var isExportingADF: Bool = false
    @State private var buildStatus: BuildStatus = .idle
    @State private var adfTrigger: Int = 0
    @State private var activeOutputTab: OutputTab = .console
    @State private var didCopyConsole: Bool = false
    @State private var lastSavedCodeURL: URL?

    private var looksLikeC: Bool {
        if let url = lastSavedCodeURL {
            let ext = url.pathExtension.lowercased()
            return ext == "c" || ext == "h"
        }
        return AssemblySourceFormatter.looksLikeC(codeText)
    }

    private var selectedBackend: EmulatorBackend {
        EmulatorBackend(rawValue: emulatorBackend) ?? .fsUAE
    }

    private var selectedBackendName: String {
        selectedBackend.displayName
    }

    private var vAmigaServerConfig: VAmigaServerConfig {
        VAmigaServerConfig(
            remoteShellPort: vAmigaRemoteShellPort,
            rpcPort: vAmigaRPCPort,
            prometheusPort: vAmigaPrometheusPort,
            serialPort: vAmigaSerialPort,
            autoConfigure: vAmigaAutoConfigureServers
        )
    }

    private var llmConnectionTint: Color {
        switch mlxServer.status {
        case .running:
            return .green
        case .runningExternally, .starting, .stopping, .downloading:
            return .accentColor
        case .failed:
            return .red
        case .stopped:
            break
        }

        switch llm.connectionStatus {
        case .connected:
            return .green
        case .disconnected:
            return .red
        case .checking:
            return .accentColor
        case .unchecked:
            return .gray
        }
    }

    private var assistantConnectionStatusLabel: String {
        switch mlxServer.status {
        case .running:
            return "MLX Server Running"
        case .runningExternally:
            return "MLX Running Outside App"
        case .starting, .stopping, .downloading:
            return mlxServer.status.label
        case .failed:
            return "MLX Setup Needed"
        case .stopped:
            return llm.connectionStatusLabel
        }
    }

    private var mlxServerToggleIcon: String {
        if mlxServer.canStop {
            return "stop.fill"
        }

        return mlxServer.canDownload ? "arrow.down.circle.fill" : "play.fill"
    }

    private var mlxServerToggleHelp: String {
        if mlxServer.canStop {
            return "Stop local MLX model server"
        }

        return mlxServer.canDownload ? "Download local MLX model" : "Start local MLX model server"
    }

    private var canToggleMLXServer: Bool {
        mlxServer.canDownload || mlxServer.canStart || mlxServer.canStop
    }

    // Chat Panel State
    @StateObject private var assistantChat = AssistantChatSession()
    @State private var currentMessage: String = ""
    @State private var copiedPromptMessageID: UUID?
    @State private var currentChatTask: URLSessionDataTask?
    @State private var selfCorrectionAttempts: Int = 0
    @State private var originalUserPrompt: String = ""

    private var canFixCompileErrors: Bool {
        buildStatus == .failure &&
            !isCompiling &&
            !isExportingADF &&
            !assistantChat.isGenerating &&
            !codeText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !outputConsole.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // Examples Database
    static let examples: [String: String] = [
        "Copper Rainbow": """
; ==========================================================
;   Amiga 68000 Copper List Example
;   Generates a classic vertical raster rainbow bar
;   (System-friendly graphics.library takeover)
; ==========================================================
            SECTION    Code,CODE,CHIP       ; Must be in CHIP RAM!
            XDEF       _Start
_Start:
            movem.l    d2-d7/a2-a6,-(sp)    ; Save registers

            ; 1. Open Graphics Library
            move.l     $4.w,a6              ; ExecBase
            lea        gfxName(pc),a1
            moveq      #0,d0
            jsr        -408(a6)             ; OpenLibrary
            move.l     d0,GfxBase
            beq.s      .exit

            ; 2. Shut down OS View/Display (System-friendly loadview)
            move.l     GfxBase(pc),a6
            move.l     34(a6),oldView       ; Save GfxBase->ActiView

            sub.l      a1,a1                ; Load NULL view (turns off OS screen)
            jsr        -222(a6)             ; LoadView(NULL)
            jsr        -270(a6)             ; WaitTOF()
            jsr        -270(a6)             ; Double WaitTOF

            ; 3. Setup Custom Copper List
            lea        $dff000,a5
            lea        CopperList(pc),a0
            move.l     a0,$80(a5)           ; Write COP1LC ($DFF080)
            move.w     #$0000,$88(a5)       ; Strobe COPJMP1 ($DFF088) to activate

            ; Enable copper DMA
            move.w     #$8280,$96(a5)       ; DMACON: set COPEN and DMAEN

.waitButton:
            ; Wait for left mouse button (Port $bfe001, bit 6)
            btst       #6,$bfe001
            bne.s      .waitButton

            ; 4. Restore OS View and Copper
            move.l     GfxBase(pc),a6
            move.l     oldView(pc),a1       ; Load old view pointer
            jsr        -222(a6)             ; LoadView(oldView)
            jsr        -270(a6)             ; WaitTOF()
            jsr        -270(a6)             ; WaitTOF()

            ; Close Graphics Library
            move.l     $4.w,a6
            move.l     GfxBase(pc),a1
            jsr        -414(a6)             ; CloseLibrary

.exit:
            movem.l    (sp)+,d2-d7/a2-a6    ; Restore registers
            moveq      #0,d0                ; Return 0
            rts

gfxName:    dc.b       "graphics.library",0
            EVEN
GfxBase:    dc.l       0
oldView:    dc.l       0

            ALIGN      4
CopperList:
            dc.w       $0100,$0200          ; No planes
            dc.w       $5007,$fffe          ; Wait for line 80
            dc.w       $0180,$0f00          ; Red
            dc.w       $5807,$fffe          ; Wait for line 88
            dc.w       $0180,$0f70          ; Orange
            dc.w       $6007,$fffe          ; Wait for line 96
            dc.w       $0180,$0ff0          ; Yellow
            dc.w       $6807,$fffe          ; Wait for line 104
            dc.w       $0180,$00f0          ; Green
            dc.w       $7007,$fffe          ; Wait for line 112
            dc.w       $0180,$00ff          ; Cyan
            dc.w       $7807,$fffe          ; Wait for line 120
            dc.w       $0180,$000f          ; Blue
            dc.w       $8007,$fffe          ; Wait for line 128
            dc.w       $0180,$0f0f          ; Purple
            dc.w       $8807,$fffe          ; Wait for line 136
            dc.w       $0180,$0000          ; Black
            dc.w       $ffff,$fffe          ; End of copper list
""",
        "Joystick Reader": """
; ==========================================================
;   Amiga 68000 Joystick Detection Example
; ==========================================================
            SECTION    Code,CODE
            XDEF       _ReadJoy
_ReadJoy:
            move.w     $dff00c,d0           ; Read JOY1DAT (Joystick 1 Port)

            ; Decode directions
            move.w     d0,d1
            and.w      #$0001,d1            ; Bit 0: Y-axis XOR (Forward)

            move.w     d0,d2
            and.w      #$0002,d2            ; Bit 1: X-axis XOR (Right)

            ; Test for Fire button (Port $bfe001 bit 7 for Joy 0 / CIA bit for Joy 1)
            ; Typically check Game Port 1 custom pin registers
            moveq      #0,d0
            rts
""",
        "Audio Sine Player": """
; ==========================================================
;   Amiga 68000 Audio Sine Channel 0 Example
; ==========================================================
            SECTION    Code,CODE
            XDEF       _PlayAudio
_PlayAudio:
            lea        $dff000,a6

            ; 1. Set channel 0 pointer to sample data
            lea        SineWave(pc),a0
            move.l     a0,$a0(a6)           ; AUD0LCH/AUD0LCL

            ; 2. Set sample length (in words)
            move.w     #4,$a4(a6)           ; AUD0LEN (8 bytes = 4 words)

            ; 3. Set volume (0 to 64)
            move.w     #64,$a8(a6)          ; AUD0VOL (Max)

            ; 4. Set period (lower = higher pitch)
            move.w     #428,$a6(a6)         ; AUD0PER (~440Hz Sine)

            ; 5. Enable audio DMA channel 0
            move.w     #$8201,$96(a6)       ; DMACON: AUD0EN and DMAEN
            rts

            ALIGN      4
SineWave:
            ; 8-bit signed audio sample wave data (8 bytes)
            dc.b       0, 90, 127, 90, 0, -90, -127, -90
"""
    ]

    var examples: [String: String] {
        ExampleLibraryStore.defaultExamplesByName
    }

    private var playgroundActions: AmigaPlaygroundActions {
        AmigaPlaygroundActions(
            assemble: runCompilation,
            fixCompileErrors: fixCompileErrorsWithAssistant,
            openPromptLibrary: openPromptLibrary,
            openExampleLibrary: openExampleLibrary,
            saveCode: saveCode,
            indentCode: indentCode,
            runDefaultEmulator: runInEmulator,
            validateVAmiga: validateInVAmiga,
            runWebEmulator: runInWebEmulator,
            exportADF: exportToADF,
            newChat: startNewChat,
            clearEditor: clearEditor,
            canRun: !isCompiling && !isExportingADF,
            canChat: !assistantChat.isGenerating,
            canFixCompileErrors: canFixCompileErrors
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        Button(action: runCompilation) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Assemble")
                            }
                        }
                        .disabled(isCompiling || isExportingADF)
                        .keyboardShortcut(.init("r"), modifiers: .command)
                        .controlSize(.large)
                        .buttonStyle(.borderedProminent)
                        .accessibilityIdentifier("assembleButton")
                        .help("Assemble the current source")

                        Button(action: fixCompileErrorsWithAssistant) {
                            HStack {
                                Image(systemName: "wand.and.stars")
                                Text("Fix")
                            }
                        }
                        .disabled(!canFixCompileErrors)
                        .buttonStyle(.bordered)
                        .accessibilityIdentifier("fixCompileErrorsButton")
                        .help("Ask the assistant to fix the current VASM errors")

                        Button(action: openPromptLibrary) {
                            HStack {
                                Image(systemName: "text.quote")
                                Text("Prompts")
                            }
                        }
                        .buttonStyle(.bordered)
                        .accessibilityIdentifier("promptLibraryButton")
                        .help("Open the prompt library")

                        Button(action: saveCode) {
                            HStack {
                                Image(systemName: "square.and.arrow.down")
                                Text("Save")
                            }
                        }
                        .buttonStyle(.bordered)
                        .accessibilityIdentifier("saveCodeButton")
                        .help("Save the current source code")

                        Button(action: runInEmulator) {
                            HStack {
                                Image(systemName: "play.tv")
                                Text("Run")
                            }
                        }
                        .disabled(isCompiling || isExportingADF)
                        .buttonStyle(.bordered)
                        .accessibilityIdentifier("runDefaultEmulatorButton")
                        .help("Assemble and run in the selected emulator")

                        Button(action: exportToADF) {
                            HStack {
                                Image(systemName: "opticaldisc")
                                Text("Export ADF")
                            }
                        }
                        .disabled(isCompiling || isExportingADF)
                        .buttonStyle(.bordered)
                        .accessibilityIdentifier("exportADFButton")
                        .help("Export a bootable ADF")

                        Button(action: openExampleLibrary) {
                            HStack(spacing: 8) {
                                Image(systemName: "books.vertical")
                                Text("Examples")
                            }
                        }
                        .buttonStyle(.bordered)
                        .accessibilityIdentifier("goldExamplesMenu")
                        .help("Open the example library")

                        Button(role: .destructive) {
                            clearEditor()
                        } label: {
                            Image(systemName: "trash")
                        }
                        .buttonStyle(.bordered)
                        .help("Clear editor")
                        .accessibilityLabel("Clear editor")
                        .accessibilityIdentifier("clearEditorButton")

                        Button(action: startNewChat) {
                            Image(systemName: "plus.message")
                        }
                        .disabled(assistantChat.isGenerating)
                        .buttonStyle(.bordered)
                        .help("Start a new chat")
                        .accessibilityLabel("Start a new chat")
                        .accessibilityIdentifier("newChatButton")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(nsColor: .windowBackgroundColor))

            HSplitView {
                // LEFT: Assistant sidebar
                VStack(spacing: 0) {
                    HStack(alignment: .firstTextBaseline) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Assistant")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            HStack(spacing: 5) {
                                Circle()
                                    .fill(llmConnectionTint)
                                    .frame(width: 8, height: 8)
                                    .accessibilityHidden(true)

                                Text(assistantConnectionStatusLabel)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .accessibilityIdentifier("assistantConnectionStatusLabel")
                            }
                        }

                        Spacer()

                        Button {
                            toggleMLXServerFromAssistantHeader()
                        } label: {
                            Image(systemName: mlxServerToggleIcon)
                        }
                        .disabled(!canToggleMLXServer)
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        .tint(.accentColor)
                        .help(mlxServerToggleHelp)
                        .accessibilityLabel(mlxServerToggleHelp)
                        .accessibilityIdentifier("assistantToggleMLXServerButton")

                        Image(systemName: "sparkles")
                            .foregroundStyle(.tint)
                            .accessibilityHidden(true)
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 52)
                    .background(Color(nsColor: .controlBackgroundColor))

                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(alignment: .leading, spacing: 10) {
                                if assistantChat.messages.isEmpty {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Antigravity 68k")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundColor(.orange)
                                        Text("Ask for copper lists, blitter copies, joystick readers, or audio routines. Generated code is optimized and validated for vasm.")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.72))
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    .padding(12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                } else {
                                    ForEach(assistantChat.messages) { msg in
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack(spacing: 6) {
                                                Text(msg.role == "user" ? "You" : "Assistant")
                                                    .font(.caption)
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(msg.role == "user" ? .cyan : .orange)

                                                if let prompt = assistantChat.reusablePrompt(from: msg) {
                                                    Button {
                                                        copyPromptToClipboard(prompt, messageID: msg.id)
                                                    } label: {
                                                        Image(systemName: copiedPromptMessageID == msg.id ? "checkmark" : "doc.on.doc")
                                                            .font(.caption)
                                                            .frame(width: 18, height: 18)
                                                    }
                                                    .buttonStyle(.plain)
                                                    .foregroundColor(copiedPromptMessageID == msg.id ? .green : .cyan.opacity(0.9))
                                                    .help("Copy prompt")
                                                    .accessibilityLabel("Copy prompt to clipboard")
                                                    .accessibilityIdentifier("copyPromptButton")
                                                }
                                            }

                                            Text(msg.content)
                                                .font(.system(.body, design: .monospaced))
                                                .foregroundColor(.white)
                                                .padding(8)
                                                .background(msg.role == "user" ? Color.blue.opacity(0.2) : Color.orange.opacity(0.12))
                                                .cornerRadius(6)
                                                .textSelection(.enabled)

                                            // Quick Code Inject Button
                                            if msg.role == "assistant" && assistantChat.isLikelyInjectableCode(msg.content) {
                                                Button(action: {
                                                    injectCodeBlock(from: msg.content)
                                                }) {
                                                    HStack(spacing: 8) {
                                                        Image(systemName: "arrow.right.doc.on.clipboard")
                                                        Text("Inject Code into Editor")
                                                    }
                                                    .font(.caption)
                                                }
                                                .buttonStyle(ChatInjectButtonStyle())
                                                .accessibilityIdentifier("injectCodeButton")
                                                .help("Confirm and inject this assistant code into the editor")
                                            }
                                        }
                                        .padding(.horizontal, 10)
                                        .id(msg.id)
                                    }
                                }

                                if assistantChat.isGenerating {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Assistant")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.orange)
                                        Text(assistantChat.currentGeneration)
                                            .font(.system(.body, design: .monospaced))
                                            .foregroundColor(.white)
                                            .padding(8)
                                            .background(Color.orange.opacity(0.12))
                                            .cornerRadius(6)
                                    }
                                    .padding(.horizontal, 10)
                                    .id("generation")
                                }
                            }
                            .padding(.vertical, 10)
                        }
                        .onChange(of: assistantChat.messages.count) {
                            if let last = assistantChat.messages.last {
                                withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                            }
                        }
                        .onChange(of: assistantChat.currentGeneration) {
                            proxy.scrollTo("generation", anchor: .bottom)
                        }
                    }

                    Spacer()

                    if showChatBoingBall {
                        BoingBallView()
                            .padding(.vertical, 8)
                            .accessibilityIdentifier("chatBoingBall")
                    }

                    Divider()

                    HStack(spacing: 8) {
                        ChatTextInput(
                            placeholder: "Ask the assistant...",
                            text: $currentMessage,
                            onCommit: sendMessage,
                            accessibilityIdentifier: "assistantPromptField"
                        )
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(Color(red: 0.18, green: 0.18, blue: 0.22))
                            .cornerRadius(4)
                            .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.orange.opacity(0.35), lineWidth: 1))
                            .disabled(assistantChat.isGenerating)

                        Button(action: assistantChat.isGenerating ? stopMessageGeneration : sendMessage) {
                            Text(assistantChat.isGenerating ? "Stop" : "Send")
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.regular)
                        .tint(assistantChat.isGenerating ? .red : .accentColor)
                        .accessibilityIdentifier("sendMessageButton")
                    }
                    .padding(10)
                    .background(Color(nsColor: .controlBackgroundColor))
                }
                .frame(minWidth: 260, idealWidth: 340, maxWidth: 420)
                .background(Color(red: 0.08, green: 0.08, blue: 0.1))

                // RIGHT: Split Code Editor + VASM Console output
                VSplitView {
                    // UPPER: Retro Custom Assembly Code Editor
                    VStack(spacing: 0) {
                        HStack(spacing: 12) {
                            Label(selectedBackendName, systemImage: "display")
                            Divider()
                                .frame(height: 12)
                            Text("Chip \(emulatorChipRam)")
                            Text("Fast \(emulatorFastRam)")
                            Text(emulatorCpu)
                            Spacer()
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .padding(.horizontal, 10)
                        .frame(height: 52)
                        .background(Color(nsColor: .controlBackgroundColor))
                        .accessibilityIdentifier("hardwareStatusLabel")

                        HStack(alignment: .top, spacing: 0) {
                            // Custom Synchronized Line Numbers column
                            VStack(alignment: .trailing, spacing: 4) {
                                ForEach(1...max(codeText.components(separatedBy: "\n").count, 1), id: \.self) { line in
                                    Text("\(line)")
                                        .font(.system(.body, design: .monospaced))
                                        .foregroundColor(.gray)
                                        .frame(height: 18)
                                }
                            }
                            .padding(.leading, 6)
                            .padding(.trailing, 10)
                            .padding(.vertical, 8)
                            .background(Color(red: 0.05, green: 0.12, blue: 0.25))
                            .frame(maxHeight: .infinity, alignment: .top)
                            .clipped()

                            // Text Editor with Deep Amiga Blue theme
                            TextEditor(text: $codeText)
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.white)
                                .padding(.vertical, 4)
                                .scrollContentBackground(.hidden)
                                .background(Color(red: 0.0, green: 0.18, blue: 0.35)) // Deep Classic Blue
                                .cornerRadius(4)
                                .accessibilityIdentifier("assemblyEditor")
                        }
                        .clipped()
                    }
                    .frame(minHeight: 250, maxHeight: .infinity, alignment: .top)
                    .clipped()

                    // LOWER: Multi-mode VASM Console, Thinking Process, or WebEmulatorView
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 12) {
                            Picker("Output", selection: $activeOutputTab) {
                                Label("Console", systemImage: "terminal.fill").tag(OutputTab.console)
                                Label("Thinking Process", systemImage: "brain").tag(OutputTab.thinking)
                                Label("Web Emulator", systemImage: "safari.fill").tag(OutputTab.emulator)
                            }
                            .pickerStyle(.segmented)
                            .labelsHidden()
                            .frame(width: 380)
                            .accessibilityIdentifier("outputPanePicker")

                            Spacer()

                            if activeOutputTab == .console {
                                Button {
                                    fixCompileErrorsWithAssistant()
                                } label: {
                                    Image(systemName: "wand.and.stars")
                                }
                                .buttonStyle(.borderless)
                                .help("Fix compile errors with assistant")
                                .disabled(!canFixCompileErrors)
                                .accessibilityIdentifier("fixConsoleErrorsButton")
                                .accessibilityLabel("Fix compile errors with assistant")

                                Button {
                                    copyConsoleToClipboard()
                                } label: {
                                    Image(systemName: didCopyConsole ? "checkmark" : "doc.on.doc")
                                }
                                .buttonStyle(.borderless)
                                .help("Copy console output")
                                .disabled(outputConsole.isEmpty)
                                .accessibilityIdentifier("copyConsoleButton")
                                .accessibilityLabel("Copy console output to clipboard")

                                Button {
                                    clearConsole()
                                } label: {
                                    Image(systemName: "trash")
                                }
                                .buttonStyle(.borderless)
                                .help("Clear console")
                                .accessibilityIdentifier("clearConsoleButton")
                                .accessibilityLabel("Clear console")
                            }

                            HStack(spacing: 6) {
                                Circle()
                                    .fill(buildStatus.color)
                                    .frame(width: 8, height: 8)
                                    .accessibilityHidden(true)
                                Text(buildStatus.detailLabel)
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(buildStatus.color)
                            }
                            .accessibilityIdentifier("consoleBuildStatusIndicator")
                            .accessibilityLabel("Build status")
                            .accessibilityValue(buildStatus.accessibilityColorName)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color(nsColor: .controlBackgroundColor))

                        switch activeOutputTab {
                        case .console:
                            ScrollView {
                                Text(outputConsole)
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .background(Color.black)
                        case .thinking:
                            ScrollViewReader { scrollViewProxy in
                                ScrollView {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(assistantChat.currentThinking.isEmpty ? "No active thinking process recorded." : assistantChat.currentThinking)
                                            .font(.system(.body, design: .monospaced))
                                            .foregroundColor(.orange)
                                            .padding(10)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .id("thinkingText")
                                    }
                                }
                                .background(Color(red: 0.0, green: 0.1, blue: 0.2))
                                .onChange(of: assistantChat.currentThinking) {
                                    scrollViewProxy.scrollTo("thinkingText", anchor: .bottom)
                                }
                            }
                        case .emulator:
                            WebEmulatorView(adfTrigger: $adfTrigger, adfPath: "/tmp/amiga_playground_temp.adf")
                                .background(Color.black)
                        }
                    }
                    .frame(minHeight: 180, maxHeight: 400)
                }
                .frame(minWidth: 420)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        }
        .frame(minWidth: 760, minHeight: 650)
        .background(Color.black)
        .accessibilityIdentifier("mainWindowContent")
        .focusedSceneValue(\.amigaPlaygroundActions, playgroundActions)
        .onAppear {
            llm.refreshConnectionStatus()
            mlxServer.refreshStatus()
        }
        .onChange(of: mlxServer.status) {
            llm.refreshConnectionStatus()
        }
        .onChange(of: llm.provider) {
            llm.refreshConnectionStatus()
        }
        .onChange(of: llm.customUrl) {
            llm.refreshConnectionStatus()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification)) { _ in
            MLXServerController.shared.stop()
        }
        .onReceive(NotificationCenter.default.publisher(for: .pastePromptIntoAssistant)) { notification in
            guard let prompt = notification.userInfo?["prompt"] as? String else { return }
            currentMessage = prompt
        }
        .onReceive(NotificationCenter.default.publisher(for: .loadExampleIntoEditor)) { notification in
            guard let code = notification.userInfo?["code"] as? String else { return }
            let name = notification.userInfo?["name"] as? String ?? "Example"
            codeText = code
            outputConsole = "Loaded '\(name)' example source code."
        }
    }

    // Assemble the code using VASM Process helper
    private func runCompilation() {
        if autoRunEmulator {
            runInEmulator()
            return
        }

        isCompiling = true
        buildStatus = .running
        activeOutputTab = .console
        outputConsole = "Assembling code using vasmm68k_mot...\n"

        CompilerService.shared.compile(assemblyCode: codeText) { success, output in
            self.isCompiling = false
            self.buildStatus = success ? .success : .failure
            self.outputConsole = output
        }
    }

    private func clearEditor() {
        codeText = ""
        outputConsole = "Editor Cleared."
    }

    private func loadExample(named key: String) {
        codeText = examples[key] ?? ""
        outputConsole = "Loaded '\(key)' example assembly source code."
    }

    private func startNewChat() {
        if assistantChat.isGenerating {
            stopMessageGeneration()
        }
        assistantChat.reset()
        currentMessage = ""
        selfCorrectionAttempts = 0
        originalUserPrompt = ""
        outputConsole = "Started a new assistant chat."
    }

    private func indentCode() {
        codeText = AssemblySourceFormatter.indentedSource(from: codeText)
        outputConsole = "Indented editor source."
    }

    private func openPromptLibrary() {
        openWindow(id: "prompt-library")
    }

    private func openExampleLibrary() {
        openWindow(id: "example-library")
    }

    private func fixCompileErrorsWithAssistant() {
        guard canFixCompileErrors else { return }

        activeOutputTab = .thinking
        let repairPrompt = compileRepairPrompt(source: codeText, compilerOutput: outputConsole)
        submitAssistantPrompt(repairPrompt, clearComposer: false)
    }

    private func runInEmulator() {
        runNativeEmulator(
            backend: selectedBackend,
            label: selectedBackendName,
            openingMessage: "Assembling code and packaging bootable ADF for \(selectedBackendName)...\n"
        )
    }

    // Validate compiled code through vAmiga Desktop automation servers.
    private func validateInVAmiga() {
        isCompiling = true
        buildStatus = .running
        activeOutputTab = .console
        outputConsole = "Validating code by building a bootable ADF and collecting vAmiga debug evidence...\n"

        let tempADFPath = "/tmp/amiga_playground_temp.adf"

        CompilerService.shared.generateBootableADF(assemblyCode: codeText, targetADFPath: tempADFPath) { success, resultMessage in
            if !success {
                self.isCompiling = false
                self.buildStatus = .failure
                self.outputConsole = resultMessage
                self.writeCompileFailureValidationArtifact(message: resultMessage)
                return
            }

            self.outputConsole = resultMessage + "\n\nLaunching vAmiga and connecting to RPC/Prometheus servers..."

            let launchConfig = EmulatorLaunchConfig(
                backend: .vAmiga,
                adfPath: tempADFPath,
                romRelativePath: self.selectedRomFilename,
                model: self.emulatorModel,
                chipRamMb: self.emulatorChipRam,
                fastRamMb: self.emulatorFastRam,
                cpu: self.emulatorCpu,
                jit: self.emulatorJit,
                customArgs: self.emulatorCustomArgs,
                vAmigaExecutablePath: self.vAmigaExecutablePath,
                vAmigaCustomArgs: self.vAmigaCustomArgs,
                vAmigaServerConfig: self.vAmigaServerConfig
            )

            VAmigaValidationService.shared.validate(config: launchConfig) { result in
                self.isCompiling = false
                self.buildStatus = result.success ? .success : .failure
                self.outputConsole += "\n\n\(result.summary)"
                if !result.failures.isEmpty {
                    self.outputConsole += "\n\nFailures:\n" + result.failures.map { "- \($0)" }.joined(separator: "\n")
                }
                self.outputConsole += "\n\nValidation artifacts:\n\(result.artifactDirectory)\nTrace:\n\(result.tracePath)\nMetrics:\n\(result.metricsPath)"
            }
        }
    }

    // Build a bootable ADF and run it in a native emulator backend.
    private func runNativeEmulator(backend: EmulatorBackend, label: String, openingMessage: String) {
        isCompiling = true
        buildStatus = .running
        activeOutputTab = .console
        outputConsole = openingMessage

        let tempADFPath = "/tmp/amiga_playground_temp.adf"

        CompilerService.shared.generateBootableADF(assemblyCode: codeText, targetADFPath: tempADFPath) { success, resultMessage in
            if !success {
                self.isCompiling = false
                self.buildStatus = .failure
                self.outputConsole = resultMessage
                return
            }

            self.outputConsole = resultMessage + "\n\nLaunching \(label) with selected ROM and configuration..."

            let launchConfig = EmulatorLaunchConfig(
                backend: backend,
                adfPath: tempADFPath,
                romRelativePath: self.selectedRomFilename,
                model: self.emulatorModel,
                chipRamMb: self.emulatorChipRam,
                fastRamMb: self.emulatorFastRam,
                cpu: self.emulatorCpu,
                jit: self.emulatorJit,
                customArgs: self.emulatorCustomArgs,
                vAmigaExecutablePath: self.vAmigaExecutablePath,
                vAmigaCustomArgs: self.vAmigaCustomArgs,
                vAmigaServerConfig: self.vAmigaServerConfig
            )

            EmulatorService.shared.launchEmulator(config: launchConfig) { result in
                self.isCompiling = false
                self.buildStatus = result.success ? .success : .failure
                self.outputConsole = self.outputConsole + "\n\n" + result.message
                if let tracePath = result.tracePath {
                    self.outputConsole += "\n\nValidation Trace Output:\n\(tracePath)"
                }
            }
        }
    }

    private func writeCompileFailureValidationArtifact(message: String) {
        DispatchQueue.global(qos: .utility).async {
            let runId = "vamiga-compile-failure-\(UUID().uuidString.prefix(8))"
            do {
                let result = try VAmigaValidationArtifactWriter().write(
                    runId: runId,
                    config: self.vAmigaServerConfig,
                    commands: [],
                    metrics: "# Validation stopped before vAmiga launch because compilation failed.\n",
                    stdoutStderr: message,
                    failures: [message],
                    summary: "Validation failed during compile/ADF generation."
                )
                DispatchQueue.main.async {
                    self.outputConsole += "\n\nValidation artifacts:\n\(result.artifactDirectory)"
                }
            } catch {
                DispatchQueue.main.async {
                    self.outputConsole += "\n\nCould not write validation failure artifacts: \(error.localizedDescription)"
                }
            }
        }
    }

    // Run compiled code in Embedded Web Emulator (vAmigaWeb Option B)
    private func runInWebEmulator() {
        isCompiling = true
        buildStatus = .running
        activeOutputTab = .console
        outputConsole = "Assembling code and packaging bootable ADF for Web Emulator...\n"

        let tempADFPath = "/tmp/amiga_playground_temp.adf"

        CompilerService.shared.generateBootableADF(assemblyCode: codeText, targetADFPath: tempADFPath) { success, resultMessage in
            self.isCompiling = false
            self.buildStatus = success ? .success : .failure
            self.outputConsole = resultMessage

            if success {
                // Increment trigger to notify WKWebView updateNSView to inject ADF file
                self.adfTrigger += 1
            }
        }
    }

    // Interfacing with local LLM APIs
    private func sendMessage() {
        submitAssistantPrompt(currentMessage, clearComposer: true)
    }

    private func submitAssistantPrompt(_ rawPrompt: String, clearComposer: Bool) {
        guard let request = assistantChat.submit(rawPrompt) else { return }
        let submittedPrompt = rawPrompt.trimmingCharacters(in: .whitespacesAndNewlines)

        if clearComposer {
            currentMessage = ""
        }

        if selfCorrectionAttempts == 0 {
            originalUserPrompt = submittedPrompt
        }

        if selfCorrectionAttempts == 0,
           let localSource = AssistantPromptTemplate.source(for: submittedPrompt) {
            let response = """
            ```assembly
            \(localSource)
            ```
            """
            let completion = assistantChat.complete(fullResponse: response, streamedResponse: "")
            guard let injectedCode = completion.injectedCode else { return }

            runAssemblyReliabilityGate(injectedCode, submittedPrompt: submittedPrompt)
            return
        }

        let adapterPath = looksLikeC ? "adapters_c" : "adapters_asm"
        outputConsole = "Generating"
        currentChatTask = OllamaService.shared.streamChat(
            messages: request.messages,
            adapterPath: adapterPath,
            onContentChunk: { chunk in
                llm.markConnected()
                assistantChat.appendContentChunk(chunk)
            },
            onReasoningChunk: { chunk in
                llm.markConnected()
                if activeOutputTab != .thinking {
                    activeOutputTab = .thinking
                }
                assistantChat.appendReasoningChunk(chunk)
            },
            onCompletion: { contentResponse, reasoningResponse in
                currentChatTask = nil
                llm.markConnected()
                let completion = assistantChat.complete(
                    fullResponse: contentResponse,
                    streamedResponse: assistantChat.currentGeneration,
                    reasoningResponse: reasoningResponse
                )
                
                guard let injectedCode = completion.injectedCode else {
                    self.selfCorrectionAttempts = 0
                    if let consoleMessage = completion.consoleMessage {
                        outputConsole = consoleMessage
                    }
                    return
                }
                
                // If it is C code, we inject it directly (since this editor compiles assembly only)
                if AssemblySourceFormatter.looksLikeC(injectedCode) {
                    self.selfCorrectionAttempts = 0
                    handleGeneratedCodeReady(
                        injectedCode,
                        prompt: self.originalUserPrompt.isEmpty ? submittedPrompt : self.originalUserPrompt,
                        autoInjectConsoleMessage: completion.consoleMessage ?? "Injected code from Amiga Assistant.",
                        readyConsoleMessage: "Assistant generated C code. Review it in chat, then click Inject Code into Editor to replace the editor contents."
                    )
                    return
                }
                
                runAssemblyReliabilityGate(injectedCode, submittedPrompt: submittedPrompt)
            },
            onError: { error in
                currentChatTask = nil
                let nsError = error as NSError
                if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled {
                    return
                }

                llm.markDisconnected(error)
                assistantChat.fail(error)
            }
        )
    }

    private func runAssemblyReliabilityGate(_ source: String, submittedPrompt: String) {
        let requestedPrompt = originalUserPrompt.isEmpty ? submittedPrompt : originalUserPrompt
        activeOutputTab = .console
        outputConsole = "Compiling"

        CompilerService.shared.compile(assemblyCode: source) { success, compilerOutput in
            let semanticResult = AssemblySemanticValidator.validate(source: source, prompt: requestedPrompt)

            if success && semanticResult.passed {
                self.selfCorrectionAttempts = 0
                self.outputConsole = "Passed"
                handleGeneratedCodeReady(
                    source,
                    prompt: requestedPrompt,
                    autoInjectConsoleMessage: "Passed",
                    readyConsoleMessage: "Passed"
                )
                return
            }

            let gateFailures = self.reliabilityGateFailures(
                compilerSucceeded: success,
                compilerOutput: compilerOutput,
                semanticFailures: semanticResult.failures
            )

            if self.selfCorrectionAttempts < 2 {
                self.selfCorrectionAttempts += 1
                outputConsole = "Repairing"
                let repairPrompt = AssemblyRepairPromptBuilder.prompt(
                    originalRequest: requestedPrompt,
                    source: source,
                    compilerOutput: compilerOutput,
                    semanticFailures: semanticResult.failures,
                    attempt: self.selfCorrectionAttempts
                )
                submitAssistantPrompt(repairPrompt, clearComposer: false)
                return
            }

            self.selfCorrectionAttempts = 0
            outputConsole = "Failed: \(gateFailures.first ?? "reliability gate failed")"
        }
    }

    private func reliabilityGateFailures(compilerSucceeded: Bool, compilerOutput: String, semanticFailures: [String]) -> [String] {
        var failures: [String] = []

        if !compilerSucceeded {
            let trimmedCompilerOutput = compilerOutput.trimmingCharacters(in: .whitespacesAndNewlines)
            failures.append(trimmedCompilerOutput.isEmpty ? "compiler failed" : trimmedCompilerOutput)
        }

        failures.append(contentsOf: semanticFailures)
        return failures
    }

    private func compileRepairPrompt(source: String, compilerOutput: String) -> String {
        """
        Fix the current Amiga Motorola 68000 source so it compiles with vasmm68k_mot using Motorola syntax.

        Requirements:
        - Return one complete corrected source file in a single fenced code block.
        - Fix only the compiler errors and the minimum directly related syntax needed for VASM.
        - Preserve the program behavior and labels unless a change is required to compile.
        - Add an inline comment on every amended code line so it is obvious what changed. Use this format for assembly: `; amended: <short reason>`. Use this format for C: `/* amended: <short reason> */`.
        - Do not include prose outside the code block.

        VASM output:
        ```text
        \(compilerOutput)
        ```

        Current editor source:
        ```asm
        \(source)
        ```
        """
    }

    private func stopMessageGeneration() {
        currentChatTask?.cancel()
        currentChatTask = nil
        assistantChat.cancel()
    }

    private func toggleMLXServerFromAssistantHeader() {
        if mlxServer.canStop {
            mlxServer.stop()
            llm.refreshConnectionStatus()
        } else if mlxServer.canDownload {
            llm.provider = .lmStudio
            llm.customUrl = ""
            llm.modelName = OllamaService.publishedModelID
            mlxServer.downloadModel(startAfterDownload: true)
        } else if mlxServer.canStart {
            llm.provider = .lmStudio
            llm.customUrl = ""
            llm.modelName = OllamaService.publishedModelID
            mlxServer.start()
        }
    }

    private func copyPromptToClipboard(_ prompt: String, messageID: UUID) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(prompt, forType: .string)
        copiedPromptMessageID = messageID

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            if copiedPromptMessageID == messageID {
                copiedPromptMessageID = nil
            }
        }
    }

    private func copyConsoleToClipboard() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(outputConsole, forType: .string)
        didCopyConsole = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            didCopyConsole = false
        }
    }

    private func clearConsole() {
        outputConsole = ""
        didCopyConsole = false
    }

    // Simple helper to isolate block between markdown fences and overwrite the editor
    private func injectCodeBlock(from responseText: String) {
        let prompt = assistantChat.promptPrecedingAssistantMessage(responseText) ?? "Manual assistant code injection"
        if let range = responseText.range(of: "```[a-zA-Z0-9]*\n", options: .regularExpression) {
            let codeStart = responseText.index(range.upperBound, offsetBy: 0)
            if let endRange = responseText[codeStart...].range(of: "```") {
                let codeContent = responseText[codeStart..<endRange.lowerBound]
                injectGeneratedCode(
                    AssemblySourceFormatter.vasmReadySource(
                        from: String(codeContent).trimmingCharacters(in: .whitespacesAndNewlines)
                    ),
                    prompt: prompt,
                    consoleMessage: "Injected code block from Amiga Assistant."
                )
                return
            }
        }

        // Fallback if no code fences are found
        injectGeneratedCode(
            AssemblySourceFormatter.vasmReadySource(from: responseText),
            prompt: prompt,
            consoleMessage: "Injected full assistant text block."
        )
    }

    private func injectGeneratedCode(_ source: String, prompt: String, consoleMessage: String) {
        guard confirmReplacingEditorIfNeeded() else {
            outputConsole = "Code injection cancelled. Existing editor content was kept."
            return
        }

        let proposedFileName = proposedSourceFileName(for: source)
        codeText = sourceWithInjectionHeader(source, proposedFileName: proposedFileName, prompt: prompt)
        playCodeInjectedSound()
        outputConsole = "\(consoleMessage)\nProposed file name: \(proposedFileName)"
    }

    private func handleGeneratedCodeReady(_ source: String, prompt: String, autoInjectConsoleMessage: String, readyConsoleMessage: String) {
        guard autoInjectGeneratedCode else {
            outputConsole = readyConsoleMessage
            return
        }

        injectGeneratedCode(source, prompt: prompt, consoleMessage: autoInjectConsoleMessage)
    }

    private func confirmReplacingEditorIfNeeded() -> Bool {
        guard !codeText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return true }

        let alert = NSAlert()
        alert.messageText = "Replace editor contents?"
        alert.informativeText = "The editor already contains code. Injecting new code will replace it."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Replace")
        alert.addButton(withTitle: "Cancel")
        return alert.runModal() == .alertFirstButtonReturn
    }

    private func sourceWithInjectionHeader(_ source: String, proposedFileName: String, prompt: String) -> String {
        let user = NSFullUserName().isEmpty ? NSUserName() : NSFullUserName()
        let timestamp = Self.injectionDateFormatter.string(from: Date())

        if proposedFileName.hasSuffix(".c") {
            return """
            /*
             User: \(user)
             Date: \(timestamp)
             Proposed file name: \(proposedFileName)
             Prompt:
            \(prompt.split(separator: "\n", omittingEmptySubsequences: false).map { " \(String($0))" }.joined(separator: "\n"))
             */

            \(source)
            """
        }

        let promptLines = prompt
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { ";   \(String($0))" }
            .joined(separator: "\n")

        return """
        ; ==========================================================
        ; User: \(user)
        ; Date: \(timestamp)
        ; Proposed file name: \(proposedFileName)
        ; Prompt:
        \(promptLines)
        ; ==========================================================

        \(source)
        """
    }

    private func proposedSourceFileName(for source: String) -> String {
        AssemblySourceFormatter.looksLikeC(source) ? "assistant_generated.c" : "assistant_generated.s"
    }

    private func playCodeInjectedSound() {
        if let saddle = NSSound(named: NSSound.Name("Saddle")) {
            saddle.play()
        } else {
            NSSound(named: NSSound.Name("Tink"))?.play()
        }
    }

    private static let injectionDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }()

    private func saveCode() {
        if let lastSavedCodeURL {
            writeCode(to: lastSavedCodeURL)
            return
        }

        saveCodeAs()
    }

    private func saveCodeAs() {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = ["s", "asm", "c"]
            .compactMap { UTType(filenameExtension: $0) } + [.plainText]
        savePanel.nameFieldStringValue = proposedSourceFileName(for: codeText)
        savePanel.title = "Save Source Code"
        savePanel.message = "Choose where to save the current editor source."

        savePanel.begin { response in
            if response == .OK, let targetURL = savePanel.url {
                self.lastSavedCodeURL = targetURL
                self.writeCode(to: targetURL)
            }
        }
    }

    private func writeCode(to url: URL) {
        do {
            try codeText.write(to: url, atomically: true, encoding: .utf8)
            outputConsole = "Saved source code to:\n\(url.path)"
        } catch {
            outputConsole = "Failed to save source code:\n\(error.localizedDescription)"
        }
    }

    // ADF Generation Helpers
    private func exportToADF() {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [UTType(filenameExtension: "adf")].compactMap { $0 }
        savePanel.nameFieldStringValue = "amiga_playground.adf"
        savePanel.title = "Export Bootable ADF"
        savePanel.message = "Choose where to save your bootable Amiga Disk File (ADF)."

        savePanel.begin { response in
            if response == .OK, let targetURL = savePanel.url {
                self.generateADF(at: targetURL)
            }
        }
    }

    private func generateADF(at url: URL) {
        self.isExportingADF = true
        self.buildStatus = .running
        self.activeOutputTab = .console
        self.outputConsole = "Generating bootable ADF disk image at:\n\(url.path)...\n"

        CompilerService.shared.generateBootableADF(assemblyCode: codeText, targetADFPath: url.path) { success, resultMessage in
            self.isExportingADF = false
            self.buildStatus = success ? .success : .failure
            self.outputConsole = resultMessage
        }
    }
}

private struct ChatInjectButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .foregroundColor(.orange.opacity(configuration.isPressed ? 0.72 : 0.95))
            .background(Color(red: 0.18, green: 0.18, blue: 0.22).opacity(configuration.isPressed ? 0.85 : 1.0))
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.orange.opacity(configuration.isPressed ? 0.95 : 0.55), lineWidth: 1)
            )
    }
}

struct SettingsView: View {
    @StateObject private var llm = OllamaService.shared
    @StateObject private var mlxServer = MLXServerController.shared

    @AppStorage("emulatorModel") private var emulatorModel: String = "A500"
    @AppStorage("emulatorCpu") private var emulatorCpu: String = "68000"
    @AppStorage("emulatorChipRam") private var emulatorChipRam: String = "512 KB"
    @AppStorage("emulatorFastRam") private var emulatorFastRam: String = "0 MB"
    @AppStorage("emulatorJit") private var emulatorJit: Bool = false
    @AppStorage("selectedRomFilename") private var selectedRomFilename: String = ""
    @AppStorage("emulatorCustomArgs") private var emulatorCustomArgs: String = ""
    @AppStorage("emulatorBackend") private var emulatorBackend: String = EmulatorBackend.fsUAE.rawValue
    @AppStorage("vAmigaExecutablePath") private var vAmigaExecutablePath: String = "/Applications/vAmiga.app/Contents/MacOS/vAmiga"
    @AppStorage("vAmigaCustomArgs") private var vAmigaCustomArgs: String = ""
    @AppStorage("vAmigaAutoConfigureServers") private var vAmigaAutoConfigureServers: Bool = true
    @AppStorage("vAmigaRemoteShellPort") private var vAmigaRemoteShellPort: Int = 8080
    @AppStorage("vAmigaRPCPort") private var vAmigaRPCPort: Int = 8081
    @AppStorage("vAmigaPrometheusPort") private var vAmigaPrometheusPort: Int = 8083
    @AppStorage("vAmigaSerialPort") private var vAmigaSerialPort: Int = 8085
    @AppStorage("autoRunEmulator") private var autoRunEmulator: Bool = false
    @AppStorage(AppPreferenceDefaults.showChatBoingBallKey) private var showChatBoingBall: Bool = AppPreferenceDefaults.showChatBoingBall
    @AppStorage(AppPreferenceDefaults.autoInjectGeneratedCodeKey) private var autoInjectGeneratedCode: Bool = AppPreferenceDefaults.autoInjectGeneratedCode
    @AppStorage("romsDirectoryPath") private var romsDirectoryPath: String = "/Users/megov/code/GitHub/littlethings/Amiga/commodore-amiga-firmware"

    @State private var availableRoms: [RomEntry] = []

    let models = ["A500", "A500+", "A600", "A1000", "A1200", "A2000", "A3000", "A4000"]
    let cpus = ["68000", "68010", "68020", "68030", "68040", "68060"]
    let chipRams = ["512 KB", "1 MB", "2 MB", "4 MB", "8 MB"]
    let fastRams = ["0 MB", "1 MB", "2 MB", "4 MB", "8 MB", "16 MB", "32 MB", "64 MB"]

    private var portFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.minimum = 1
        formatter.maximum = 65535
        formatter.allowsFloats = false
        return formatter
    }

    private var contextWindowFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.minimum = 1
        formatter.allowsFloats = false
        return formatter
    }

    private var contextWindowSliderValue: Binding<Double> {
        Binding(
            get: { Double(llm.contextWindow) },
            set: { llm.contextWindow = Int($0.rounded()) }
        )
    }

    private var mlxServerToggleLabel: String {
        if mlxServer.canStop {
            return "Stop MLX Server"
        }

        return mlxServer.canDownload ? "Download Model" : "Start MLX Server"
    }

    private var mlxServerToggleIcon: String {
        if mlxServer.canStop {
            return "stop.fill"
        }

        return mlxServer.canDownload ? "arrow.down.circle.fill" : "play.fill"
    }

    private var canToggleMLXServer: Bool {
        mlxServer.canDownload || mlxServer.canStart || mlxServer.canStop
    }

    private var mlxServerStatusColor: Color {
        switch mlxServer.status {
        case .running:
            return .green
        case .runningExternally:
            return .accentColor
        case .starting, .stopping, .downloading:
            return .accentColor
        case .failed:
            return .red
        case .stopped:
            return .secondary
        }
    }

    private func toggleMLXServerFromSettings() {
        if mlxServer.canStop {
            mlxServer.stop()
            llm.refreshConnectionStatus()
        } else if mlxServer.canDownload {
            llm.provider = .lmStudio
            llm.customUrl = ""
            llm.modelName = OllamaService.publishedModelID
            mlxServer.downloadModel(startAfterDownload: true)
        } else if mlxServer.canStart {
            llm.provider = .lmStudio
            llm.customUrl = ""
            llm.modelName = OllamaService.publishedModelID
            mlxServer.start()
        }
    }

    private func revealMLXServerLog() {
        let logURL = URL(fileURLWithPath: mlxServer.logFilePath)
        if FileManager.default.fileExists(atPath: logURL.path) {
            NSWorkspace.shared.activateFileViewerSelecting([logURL])
        } else {
            NSWorkspace.shared.open(logURL.deletingLastPathComponent())
        }
    }

    private var selectedRomDisplayName: String {
        if selectedRomFilename.isEmpty {
            return "Default / vAmiga configured ROM"
        }

        return availableRoms.first(where: { $0.relativePath == selectedRomFilename })?.displayName ?? selectedRomFilename
    }

    private var selectedBackendDescription: String {
        switch EmulatorBackend(rawValue: emulatorBackend) ?? .fsUAE {
        case .fsUAE:
            return "FS-UAE launches the generated ADF with the selected ROM and hardware configuration."
        case .vAmiga:
            return "vAmiga validation uses Desktop automation servers to collect RPC trace, CPU, and runtime evidence."
        }
    }

    private func chooseRomsDirectory() {
        let panel = NSOpenPanel()
        panel.title = "Select Kickstart ROM Directory"
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        if !romsDirectoryPath.isEmpty && FileManager.default.fileExists(atPath: romsDirectoryPath) {
            panel.directoryURL = URL(fileURLWithPath: romsDirectoryPath)
        }

        if panel.runModal() == .OK {
            if let path = panel.url?.path {
                self.romsDirectoryPath = path
                self.availableRoms = EmulatorService.shared.getAvailableRoms()
                if !selectedRomFilename.isEmpty && !availableRoms.contains(where: { $0.relativePath == selectedRomFilename }) {
                    selectedRomFilename = ""
                }
            }
        }
    }

    var body: some View {
        TabView {
            generalSettings
                .tabItem { Label("General", systemImage: "gearshape") }
                .accessibilityIdentifier("settingsGeneralTab")

            aiSettings
                .tabItem { Label("AI", systemImage: "sparkles") }
                .accessibilityIdentifier("settingsAITab")

            hardwareSettings
                .tabItem { Label("Hardware", systemImage: "cpu") }
                .accessibilityIdentifier("settingsHardwareTab")

            fsUaeSettings
                .tabItem { Label("FS-UAE", systemImage: "display") }
                .accessibilityIdentifier("settingsFSUAETab")

            vAmigaSettings
                .tabItem { Label("vAmiga", systemImage: "waveform.path.ecg") }
                .accessibilityIdentifier("settingsVAmigaTab")
        }
        .padding(20)
        .frame(width: 680, height: 620)
        .onAppear {
            self.availableRoms = EmulatorService.shared.getAvailableRoms()
            if !selectedRomFilename.isEmpty && !availableRoms.contains(where: { $0.relativePath == selectedRomFilename }) {
                selectedRomFilename = ""
            }
        }
    }

    private var generalSettings: some View {
        Form {
            Picker("Default emulator", selection: $emulatorBackend) {
                ForEach(EmulatorBackend.allCases) { backend in
                    Text(backend.displayName).tag(backend.rawValue)
                }
            }
            Text(selectedBackendDescription)
                .font(.caption)
                .foregroundStyle(.secondary)

            Toggle("Automatically run default emulator after assembly", isOn: $autoRunEmulator)

            Toggle("Show Boing Ball animation in chat", isOn: $showChatBoingBall)
                .accessibilityIdentifier("showChatBoingBallToggle")

            Toggle("Automatically inject generated code", isOn: $autoInjectGeneratedCode)
                .accessibilityIdentifier("autoInjectGeneratedCodeToggle")

            Text("When enabled, assistant code is inserted after generation and compiler checks finish. If the editor already contains code, the replacement confirmation still appears.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .formStyle(.grouped)
        .padding()
    }

    private var aiSettings: some View {
        Form {
            Section("Connection") {
                Picker("Provider", selection: $llm.provider) {
                    ForEach(OllamaService.Provider.allCases) { provider in
                        Text(provider.rawValue).tag(provider)
                    }
                }

                TextField("Model name", text: $llm.modelName)
                    .textFieldStyle(.roundedBorder)

                Link("Open Hugging Face model card", destination: OllamaService.modelCardURL)
                    .font(.caption)
                    .accessibilityIdentifier("huggingFaceModelCardLink")

                TextField("Custom API URL", text: $llm.customUrl)
                    .textFieldStyle(.roundedBorder)

                Text("Active endpoint: \(llm.apiUrl)")
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("activeEndpointLabel")

                Text("Request model: \(llm.requestModelName)")
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
            }

            Section("Local MLX Server") {
                HStack(spacing: 8) {
                    Circle()
                        .fill(mlxServerStatusColor)
                        .frame(width: 8, height: 8)
                        .accessibilityHidden(true)

                    Text(mlxServer.status.label)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .accessibilityIdentifier("mlxServerStatusLabel")
                }

                Text("Managed by bundled helper")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let detail = mlxServer.status.detail {
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .textSelection(.enabled)

                    Button {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(detail, forType: .string)
                    } label: {
                        Label("Copy Setup Instructions", systemImage: "doc.on.doc")
                    }
                    .accessibilityIdentifier("copyMLXSetupInstructionsButton")
                }

                HStack {
                    Button {
                        toggleMLXServerFromSettings()
                    } label: {
                        Label(mlxServerToggleLabel, systemImage: mlxServerToggleIcon)
                    }
                    .disabled(!canToggleMLXServer)
                    .tint(.accentColor)
                    .accessibilityIdentifier("toggleMLXServerButton")

                    Button {
                        mlxServer.refreshStatus()
                        llm.refreshConnectionStatus()
                    } label: {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                    .accessibilityIdentifier("refreshMLXServerButton")

                    Button {
                        NSWorkspace.shared.open(mlxServer.configuration.workingDirectory)
                    } label: {
                        Label("Folder", systemImage: "folder")
                    }
                    .accessibilityIdentifier("openMLXServerFolderButton")

                    Link(destination: OllamaService.modelCardURL) {
                        Label("Model Card", systemImage: "link")
                    }
                    .accessibilityIdentifier("mlxServerModelCardLink")
                }

                Text("Endpoint: \(mlxServer.endpointDescription)")
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)

                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("Log: \(mlxServer.logFilePath)")
                        .font(.caption.monospaced())
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .truncationMode(.middle)

                    Button {
                        revealMLXServerLog()
                    } label: {
                        Image(systemName: "folder")
                    }
                    .buttonStyle(.borderless)
                    .help("Open log location in Finder")
                    .accessibilityLabel("Open MLX server log location")
                    .accessibilityIdentifier("openMLXServerLogLocationButton")
                }
            }

            Section("Instruction") {
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Context window", value: $llm.contextWindow, formatter: contextWindowFormatter)
                        .textFieldStyle(.roundedBorder)
                        .accessibilityIdentifier("assistantContextWindowField")

                    HStack(spacing: 10) {
                        Slider(value: contextWindowSliderValue, in: 1024...32768, step: 512)
                            .accessibilityIdentifier("assistantContextWindowSlider")

                        Text("\(llm.contextWindow)")
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.secondary)
                            .frame(width: 52, alignment: .trailing)
                    }
                }

                TextEditor(text: $llm.systemPrompt)
                    .font(.body.monospaced())
                    .frame(minHeight: 120)
                    .accessibilityIdentifier("assistantSystemPromptEditor")

                Text("System prompt is sent as a system message before the chat history.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .padding()
        .accessibilityIdentifier("aiSettingsPane")
        .onAppear {
            mlxServer.refreshStatus()
        }
    }

    private var hardwareSettings: some View {
        Form {
            Section("Kickstart ROM") {
                Text("Directory: \(romsDirectoryPath)")
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .truncationMode(.middle)

                HStack {
                    Button("Choose Folder...") {
                        chooseRomsDirectory()
                    }

                    Button("Reset to Default") {
                        romsDirectoryPath = "/Users/megov/code/GitHub/littlethings/Amiga/commodore-amiga-firmware"
                        availableRoms = EmulatorService.shared.getAvailableRoms()
                        if !selectedRomFilename.isEmpty && !availableRoms.contains(where: { $0.relativePath == selectedRomFilename }) {
                            selectedRomFilename = ""
                        }
                    }
                }

                if availableRoms.isEmpty {
                    Text("No ROM files found in the selected directory.")
                        .foregroundStyle(.red)
                } else {
                    Picker("Kickstart ROM", selection: $selectedRomFilename) {
                        Text("Default / vAmiga configured ROM").tag("")
                        ForEach(availableRoms) { rom in
                            Text(rom.displayName).tag(rom.relativePath)
                        }
                    }
                }
            }

            Section("Model and CPU") {
                Picker("Amiga model", selection: $emulatorModel) {
                    ForEach(models, id: \.self) { model in Text(model).tag(model) }
                }

                Picker("CPU", selection: $emulatorCpu) {
                    ForEach(cpus, id: \.self) { cpu in Text(cpu).tag(cpu) }
                }
            }

            Section("Memory") {
                Picker("Chip RAM", selection: $emulatorChipRam) {
                    ForEach(chipRams, id: \.self) { ram in Text(ram).tag(ram) }
                }

                Picker("Fast RAM", selection: $emulatorFastRam) {
                    ForEach(fastRams, id: \.self) { ram in Text(ram).tag(ram) }
                }

                Toggle("Enable JIT", isOn: $emulatorJit)
            }
        }
        .formStyle(.grouped)
        .padding()
    }

    private var fsUaeSettings: some View {
        Form {
            TextField("Custom FS-UAE launch arguments", text: $emulatorCustomArgs)
                .textFieldStyle(.roundedBorder)
            Text("These arguments are appended when the default emulator is FS-UAE.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .formStyle(.grouped)
        .padding()
    }

    private var vAmigaSettings: some View {
        Form {
            Section("Application") {
                TextField("vAmiga executable", text: $vAmigaExecutablePath)
                    .textFieldStyle(.roundedBorder)

                TextField("vAmiga launch arguments", text: $vAmigaCustomArgs)
                    .textFieldStyle(.roundedBorder)
            }

            Section("Server Validation") {
                Toggle("Auto-configure vAmiga automation servers", isOn: $vAmigaAutoConfigureServers)

                TextField("Remote Shell port", value: $vAmigaRemoteShellPort, formatter: portFormatter)
                    .textFieldStyle(.roundedBorder)

                TextField("RPC port", value: $vAmigaRPCPort, formatter: portFormatter)
                    .textFieldStyle(.roundedBorder)

                TextField("Prometheus port", value: $vAmigaPrometheusPort, formatter: portFormatter)
                    .textFieldStyle(.roundedBorder)

                TextField("Serial port", value: $vAmigaSerialPort, formatter: portFormatter)
                    .textFieldStyle(.roundedBorder)
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

struct SettingsPickerField<SelectionValue: Hashable, Content: View>: View {
    let title: String
    let displayValue: String
    @Binding var selection: SelectionValue
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)

            Menu {
                Picker(title, selection: $selection) {
                    content()
                }
            } label: {
                HStack(spacing: 8) {
                    Text(displayValue)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .truncationMode(.middle)

                    Spacer(minLength: 8)

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption)
                        .foregroundColor(.orange.opacity(0.9))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(Color(red: 0.18, green: 0.18, blue: 0.22))
                .cornerRadius(4)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.orange.opacity(0.45), lineWidth: 1))
            }
            .buttonStyle(PlainButtonStyle())
            .frame(minWidth: 160, maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
    }
}

struct SettingsBackendPicker: View {
    @Binding var selection: String

    var body: some View {
        HStack(spacing: 8) {
            Text("Backend:")
                .font(.system(.body, design: .monospaced))
                .fontWeight(.bold)
                .foregroundColor(.white)

            ForEach(EmulatorBackend.allCases) { backend in
                Button(action: {
                    selection = backend.rawValue
                }) {
                    Text(backend.displayName)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(selection == backend.rawValue ? .black : .white)
                        .lineLimit(1)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .frame(minWidth: 130)
                        .background(selection == backend.rawValue ? Color.orange : Color(red: 0.18, green: 0.18, blue: 0.22))
                        .cornerRadius(4)
                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.orange.opacity(selection == backend.rawValue ? 1.0 : 0.45), lineWidth: 1))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

struct SettingsAssistantProviderPicker: View {
    @Binding var selection: OllamaService.Provider

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Provider")
                .font(.caption)
                .foregroundColor(.gray)

            HStack(spacing: 0) {
                ForEach(OllamaService.Provider.allCases) { provider in
                    Button(action: {
                        selection = provider
                    }) {
                        Text(provider.rawValue)
                            .font(.system(.body, design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundColor(selection == provider ? .black : .white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(selection == provider ? Color.orange : Color(red: 0.18, green: 0.18, blue: 0.22))
                    }
                    .buttonStyle(PlainButtonStyle())

                    if provider != OllamaService.Provider.allCases.last {
                        Spacer().frame(width: 1)
                    }
                }
            }
            .cornerRadius(4)
            .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.orange.opacity(0.75), lineWidth: 1))
        }
    }
}

struct SettingsPortField: View {
    let title: String
    @Binding var value: Int
    let formatter: NumberFormatter

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)

            SettingsNumberInput(placeholder: "8080", value: $value, formatter: formatter)
                .settingsTextInputStyle()
                .frame(minWidth: 120)
        }
    }
}

private extension View {
    func settingsTextInputStyle() -> some View {
        self
            .frame(height: 20)
            .padding(8)
            .background(Color(red: 0.18, green: 0.18, blue: 0.22))
            .cornerRadius(4)
            .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.orange.opacity(0.5), lineWidth: 1))
    }
}

struct ChatTextInput: View {
    let placeholder: String
    @Binding var text: String
    let onCommit: () -> Void
    let accessibilityIdentifier: String?

    init(
        placeholder: String,
        text: Binding<String>,
        onCommit: @escaping () -> Void,
        accessibilityIdentifier: String? = nil
    ) {
        self.placeholder = placeholder
        _text = text
        self.onCommit = onCommit
        self.accessibilityIdentifier = accessibilityIdentifier
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundStyle(.white.opacity(0.68))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 7)
                    .allowsHitTesting(false)
            }

            CommandSubmittingTextView(
                text: $text,
                onCommandReturn: onCommit,
                accessibilityIdentifier: accessibilityIdentifier
            )
            .accessibilityLabel(placeholder)
        }
        .frame(height: 72)
    }
}

struct CommandSubmittingTextView: NSViewRepresentable {
    @Binding var text: String
    let onCommandReturn: () -> Void
    let accessibilityIdentifier: String?

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.drawsBackground = false
        scrollView.borderType = .noBorder
        scrollView.hasVerticalScroller = true
        scrollView.autohidesScrollers = true

        let textView = SubmitOnCommandReturnTextView()

        textView.delegate = context.coordinator
        textView.onCommandReturn = onCommandReturn
        textView.string = text
        textView.drawsBackground = false
        textView.textColor = .white
        textView.insertionPointColor = .white
        textView.font = .systemFont(ofSize: NSFont.systemFontSize)
        textView.isRichText = false
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.textContainerInset = NSSize(width: 4, height: 4)
        textView.minSize = NSSize(width: 0, height: 0)
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.textContainer?.containerSize = NSSize(width: scrollView.contentSize.width, height: CGFloat.greatestFiniteMagnitude)
        textView.textContainer?.widthTracksTextView = true
        textView.setAccessibilityIdentifier(accessibilityIdentifier)
        scrollView.documentView = textView

        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? SubmitOnCommandReturnTextView else { return }
        textView.onCommandReturn = onCommandReturn
        textView.setAccessibilityIdentifier(accessibilityIdentifier)
        if textView.string != text {
            textView.string = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    final class Coordinator: NSObject, NSTextViewDelegate {
        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            text = textView.string
        }
    }
}

final class SubmitOnCommandReturnTextView: NSTextView {
    var onCommandReturn: (() -> Void)?

    override func keyDown(with event: NSEvent) {
        if event.modifierFlags.contains(.command),
           event.charactersIgnoringModifiers == "\r" {
            onCommandReturn?()
            return
        }

        super.keyDown(with: event)
    }
}

struct SettingsTextInput: NSViewRepresentable {
    let placeholder: String
    @Binding var text: String

    func makeNSView(context: Context) -> NSTextField {
        let field = NSTextField()
        field.delegate = context.coordinator
        field.isBordered = false
        field.isBezeled = false
        field.drawsBackground = false
        field.textColor = .white
        field.placeholderString = placeholder
        field.font = NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
        field.focusRingType = .none
        field.lineBreakMode = .byTruncatingMiddle
        field.cell?.sendsActionOnEndEditing = true
        return field
    }

    func updateNSView(_ field: NSTextField, context: Context) {
        if field.stringValue != text {
            field.stringValue = text
        }
        field.textColor = .white
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    final class Coordinator: NSObject, NSTextFieldDelegate {
        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
        }

        func controlTextDidChange(_ notification: Notification) {
            guard let field = notification.object as? NSTextField else { return }
            text = field.stringValue
        }
    }
}

struct SettingsNumberInput: NSViewRepresentable {
    let placeholder: String
    @Binding var value: Int
    let formatter: NumberFormatter

    func makeNSView(context: Context) -> NSTextField {
        let field = NSTextField()
        field.delegate = context.coordinator
        field.formatter = formatter
        field.isBordered = false
        field.isBezeled = false
        field.drawsBackground = false
        field.textColor = .white
        field.placeholderString = placeholder
        field.font = NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
        field.focusRingType = .none
        field.alignment = .left
        return field
    }

    func updateNSView(_ field: NSTextField, context: Context) {
        let current = "\(value)"
        if field.stringValue != current {
            field.stringValue = current
        }
        field.textColor = .white
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(value: $value)
    }

    final class Coordinator: NSObject, NSTextFieldDelegate {
        @Binding var value: Int

        init(value: Binding<Int>) {
            _value = value
        }

        func controlTextDidChange(_ notification: Notification) {
            guard let field = notification.object as? NSTextField else { return }
            if let intValue = Int(field.stringValue), (1...65535).contains(intValue) {
                value = intValue
            }
        }

        func controlTextDidEndEditing(_ notification: Notification) {
            guard let field = notification.object as? NSTextField else { return }
            field.stringValue = "\(value)"
        }
    }
}

#Preview {
    ContentView()
}
