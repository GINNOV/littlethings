import Foundation

fileprivate func assemblyCommentStartIndex(in line: String) -> String.Index? {
    var index = line.startIndex
    var inDoubleQuotedString = false
    var inSingleQuotedString = false

    while index < line.endIndex {
        let character = line[index]

        if character == "\"", !inSingleQuotedString {
            let nextIndex = line.index(after: index)
            if inDoubleQuotedString,
               nextIndex < line.endIndex,
               line[nextIndex] == "\"" {
                index = line.index(after: nextIndex)
                continue
            }
            inDoubleQuotedString.toggle()
        } else if character == "'", !inDoubleQuotedString {
            let nextIndex = line.index(after: index)
            if inSingleQuotedString,
               nextIndex < line.endIndex,
               line[nextIndex] == "'" {
                index = line.index(after: nextIndex)
                continue
            }
            inSingleQuotedString.toggle()
        } else if character == ";", !inDoubleQuotedString, !inSingleQuotedString {
            return index
        }

        index = line.index(after: index)
    }

    return nil
}

fileprivate func assemblyCodePrefix(beforeCommentIn line: String) -> String {
    guard let commentStart = assemblyCommentStartIndex(in: line) else {
        return line
    }
    return String(line[..<commentStart])
}

fileprivate func assemblyCommentText(in line: String) -> String? {
    guard let commentStart = assemblyCommentStartIndex(in: line) else {
        return nil
    }
    let textStart = line.index(after: commentStart)
    return String(line[textStart...]).trimmingCharacters(in: .whitespaces)
}

fileprivate func amigaMarkerAttributeText(for value: String) -> String {
    value
        .replacingOccurrences(of: "\\", with: "\\\\")
        .replacingOccurrences(of: "\"", with: "\\\"")
}

struct AmigaProgramModel: Codable, Equatable {
    enum Kind: String, Codable, Equatable {
        case demo
        case utility
        case menu
        case audioPlayer
        case effect
        case hybrid
    }

    struct Control: Codable, Equatable, Identifiable {
        var id: String
        var label: String
        var action: String
        var bounds: Bounds?

        init(id: String, label: String, action: String, bounds: Bounds? = nil) {
            self.id = id
            self.label = label
            self.action = action
            self.bounds = bounds
        }
    }

    struct Bounds: Codable, Equatable {
        var x: Int
        var y: Int
        var width: Int
        var height: Int
    }

    struct Routine: Codable, Equatable, Identifiable {
        var id: String
        var label: String
        var purpose: String
        var clobbers: [String]
        var calls: [String]

        init(id: String, label: String, purpose: String, clobbers: [String] = [], calls: [String] = []) {
            self.id = id
            self.label = label
            self.purpose = purpose
            self.clobbers = clobbers
            self.calls = calls
        }
    }

    struct StateVariable: Codable, Equatable, Identifiable {
        var id: String
        var symbol: String
        var purpose: String
        var initialValue: String?
    }

    enum HardwareSubsystem: String, Codable, Equatable, CaseIterable {
        case copper = "Copper"
        case bitplanes = "Bitplanes"
        case sprites = "Sprites"
        case blitter = "Blitter"
        case paula = "Paula"
        case cia = "CIA"
        case exec = "Exec"
        case graphics = "Graphics"
        case intuition = "Intuition"
    }

    var id: String
    var kind: Kind
    var controls: [Control]
    var routines: [Routine]
    var stateVariables: [StateVariable]
    var hardware: [HardwareSubsystem]
    var verificationExpectations: [String]

    init(
        id: String,
        kind: Kind,
        controls: [Control] = [],
        routines: [Routine] = [],
        stateVariables: [StateVariable] = [],
        hardware: [HardwareSubsystem] = [],
        verificationExpectations: [String] = []
    ) {
        self.id = id
        self.kind = kind
        self.controls = controls
        self.routines = routines
        self.stateVariables = stateVariables
        self.hardware = hardware
        self.verificationExpectations = verificationExpectations
    }
}

struct AmigaProgramFamilyManifest: Equatable, Identifiable {
    var id: String
    var name: String
    var kind: AmigaProgramModel.Kind
    var firstShotPromptExamples: [String]
    var rejectedFirstShotPromptExamples: [String]
    var representativeRoutedFirstShotPromptExamples: [String]
    var supportedFollowUps: [String]
    var requiredFollowUpSmokePrompts: [String]
    var requiredFollowUpSmokeChains: [[String]]
    var representativeRoutedFollowUpSmokeChains: [[String]]
    var requiredRejectedFollowUpSmokePrompts: [String]
    var requiredRejectedFollowUpSmokeChains: [[String]]
    var requiredRecoveryFollowUpSmokeChains: [[String]]
    var representativeRoutedRecoveryFollowUpSmokeChains: [[String]]
    var requiredIgnoredFollowUpSmokePrompts: [String]
    var requiredRegions: [AmigaSourceRegionName]
    var requiredHardware: [AmigaProgramModel.HardwareSubsystem]
    var requiredVerificationGates: [String]

    init(
        id: String,
        name: String,
        kind: AmigaProgramModel.Kind,
        firstShotPromptExamples: [String],
        rejectedFirstShotPromptExamples: [String] = [],
        representativeRoutedFirstShotPromptExamples: [String] = [],
        supportedFollowUps: [String],
        requiredFollowUpSmokePrompts: [String],
        requiredFollowUpSmokeChains: [[String]],
        representativeRoutedFollowUpSmokeChains: [[String]] = [],
        requiredRejectedFollowUpSmokePrompts: [String],
        requiredRejectedFollowUpSmokeChains: [[String]] = [],
        requiredRecoveryFollowUpSmokeChains: [[String]] = [],
        representativeRoutedRecoveryFollowUpSmokeChains: [[String]] = [],
        requiredIgnoredFollowUpSmokePrompts: [String] = [],
        requiredRegions: [AmigaSourceRegionName],
        requiredHardware: [AmigaProgramModel.HardwareSubsystem],
        requiredVerificationGates: [String]
    ) {
        self.id = id
        self.name = name
        self.kind = kind
        self.firstShotPromptExamples = firstShotPromptExamples
        self.rejectedFirstShotPromptExamples = rejectedFirstShotPromptExamples
        self.representativeRoutedFirstShotPromptExamples = representativeRoutedFirstShotPromptExamples
        self.supportedFollowUps = supportedFollowUps
        self.requiredFollowUpSmokePrompts = requiredFollowUpSmokePrompts
        self.requiredFollowUpSmokeChains = requiredFollowUpSmokeChains
        self.representativeRoutedFollowUpSmokeChains = representativeRoutedFollowUpSmokeChains
        self.requiredRejectedFollowUpSmokePrompts = requiredRejectedFollowUpSmokePrompts
        self.requiredRejectedFollowUpSmokeChains = requiredRejectedFollowUpSmokeChains
        self.requiredRecoveryFollowUpSmokeChains = requiredRecoveryFollowUpSmokeChains
        self.representativeRoutedRecoveryFollowUpSmokeChains = representativeRoutedRecoveryFollowUpSmokeChains
        self.requiredIgnoredFollowUpSmokePrompts = requiredIgnoredFollowUpSmokePrompts
        self.requiredRegions = requiredRegions
        self.requiredHardware = requiredHardware
        self.requiredVerificationGates = requiredVerificationGates
    }
}

enum AmigaSourceRegionName: String, Codable, Equatable, CaseIterable {
    case model
    case controls
    case drawControls = "draw_controls"
    case hitTest = "hit_test"
    case inputDispatch = "input_dispatch"
    case routines
    case state
    case chipData = "chip_data"
    case cleanup
}

enum AmigaProgramFamilyRegistry {
    static let doubleBufferedBitplane = AmigaProgramFamilyManifest(
        id: "double-buffer-bitplane",
        name: "Model-backed double-buffered bitplane",
        kind: .effect,
        firstShotPromptExamples: [
            "Generate double-buffered bitplane animation that swaps front red and back green bitplane pointers on vblank, overlays a small sprite, updates a copper color register, and exits on left mouse click.",
            "Generate double-buffered bitplane animation that swaps front (red) and back (green) bitplane pointers on vblank and exits on left mouse click.",
            "Generate double-buffered bitplane animation that swaps front and back bitplane pointers on vblank and exits on left mouse click."
        ],
        rejectedFirstShotPromptExamples: [
            "Generate a double buffered audio sample player with clean start and stop controls."
        ],
        representativeRoutedFirstShotPromptExamples: [
            "Generate double-buffered bitplane animation that swaps front and back bitplane pointers on vblank and exits on left mouse click."
        ],
        supportedFollowUps: [
            "set front color",
            "set back color"
        ],
        requiredFollowUpSmokePrompts: [
            "set front color to purple",
            "set back color to orange",
            "set front and back color to red",
            "set front color to red and back color to blue"
        ],
        requiredFollowUpSmokeChains: [
            [
                "set front color to purple",
                "set back color to orange"
            ],
            [
                "set back color to blue",
                "set front color to orange",
                "set back color to purple"
            ],
            [
                "set front color to red and back color to blue",
                "set front color to orange",
                "set back color to purple"
            ]
        ],
        representativeRoutedFollowUpSmokeChains: [
            [
                "set front color to purple",
                "set back color to orange"
            ]
        ],
        requiredRejectedFollowUpSmokePrompts: [
            "set front color to teal",
            "set front color to",
            "set front color to greenhouse",
            "set back color to",
            "set back to color",
            "set front color to red and back color"
        ],
        requiredRejectedFollowUpSmokeChains: [
            [
                "set front color to purple",
                "set front color to teal"
            ],
            [
                "set front color to purple",
                "set back color to"
            ],
            [
                "set front and back color to red",
                "set back color to teal"
            ],
            [
                "set back color to blue",
                "set back to color"
            ]
        ],
        requiredIgnoredFollowUpSmokePrompts: [
            "upset front color to red"
        ],
        requiredRegions: [
            .model,
            .controls,
            .drawControls,
            .hitTest,
            .inputDispatch,
            .routines,
            .state,
            .chipData
        ],
        requiredHardware: [.bitplanes, .sprites, .copper, .cia],
        requiredVerificationGates: [
            "verified first-shot template",
            "structured follow-up patcher",
            "representative routed conversation audit",
            "AmigaProgramSourceVerifier",
            "AssemblySemanticValidator",
            "VASM compile",
            "bootable ADF generation",
            "runtime observation contract",
            "optional vAmiga runtime smoke",
            "negative verifier tests"
        ]
    )

    static let modPlayerControls = AmigaProgramFamilyManifest(
        id: "mod-player-controls",
        name: "Model-backed MOD controls",
        kind: .audioPlayer,
        firstShotPromptExamples: [
            "Generate two buttons, play and stop of a mod file",
            "Generate two buttons, play and stop for a module file.",
            "Generate play and stop buttons for a music module.",
            "Generate play and stop controls for a tracker module."
        ],
        rejectedFirstShotPromptExamples: [
            "Generate a display with stopwatch buttons for a modulator.",
            "Generate a UI module with play and stop buttons."
        ],
        representativeRoutedFirstShotPromptExamples: [
            "Generate play and stop controls for a tracker module."
        ],
        supportedFollowUps: [
            "add volume up",
            "add volume down",
            "add volume controls",
            "add pause",
            "add mute",
            "rename a visible control label",
            "remove an added control",
            "reorder controls",
            "change an added control behavior",
            "change control bounds",
            "change playback note",
            "change playback period",
            "change volume step",
            "set initial volume"
        ],
        requiredFollowUpSmokePrompts: [
            "add a third button called Volume Up",
            "make the third button say Louder",
            "change Stop button caption Halt",
            "set Halt button title Stop",
            "change volume step to 8",
            "change volume step to -8",
            "set playback note to C-3",
            "set playback period to 428",
            "set initial volume to -1",
            "set initial volume to $20",
            "set initial volume to max",
            "set initial volume to 63",
            "remove volume up"
        ],
        requiredFollowUpSmokeChains: [
            [
                "add volume up",
                "make the third button say Louder",
                "change volume step to 8",
                "set initial volume to 63"
            ],
            [
                "add volume up",
                "set volume increment to 8"
            ],
            [
                "add volume up and set volume increment to 8",
                "set initial volume to 32"
            ],
            [
                "add volume controls centered below Stop and set volume increment to 8",
                "set initial volume to 32"
            ],
            [
                "add a button called Down centered below Stop to lower volume and set volume increment to 8",
                "set initial volume to 32"
            ],
            [
                "add volume up",
                "add a button called Down to lower volume and move Down before Volume Up",
                "set volume increment to 8"
            ],
            [
                "add volume up",
                "add a button called Down centered below Stop to lower volume and move Down before Volume Up",
                "set volume increment to 8"
            ],
            [
                "add volume up",
                "add a button called Down to lower volume and move Down before Volume Up and set volume increment to 8",
                "set initial volume to 32"
            ],
            [
                "add volume up",
                "add a button called Down centered below Stop to lower volume and move Down before Volume Up and set volume increment to 8",
                "set initial volume to 32"
            ],
            [
                "add a button called Down to lower volume",
                "rename Down to Quieter and center Down below Stop and set initial volume to 32",
                "set volume increment to 8"
            ],
            [
                "add volume up",
                "center Volume Up below Stop and set volume increment to 8",
                "set initial volume to 32"
            ],
            [
                "add volume up",
                #"rename "Volume Up" to "Louder" and set volume increment to 8"#,
                "set initial volume to 32"
            ],
            [
                "add volume up",
                #"rename "Volume Up" to "Louder" and center Volume Up below Stop"#,
                "set volume increment to 8"
            ],
            [
                "add volume up",
                #"rename "Volume Up" to "Louder" and center Volume Up below Stop and set initial volume to 32"#,
                "set playback period to 428"
            ],
            [
                "add volume up",
                "change volume step to -8",
                "set volume increment to 8"
            ],
            [
                "add volume up",
                "make Volume Up lower volume instead and set volume increment to 8",
                "set initial volume to 32"
            ],
            [
                "add volume up",
                "make Volume Up say Down and lower volume and set volume increment to 8",
                "set initial volume to 32"
            ],
            [
                "add volume up",
                "make Volume Up say Down and lower volume and center Volume Up below Stop",
                "change volume step to 8"
            ],
            [
                "add volume up",
                "make Volume Up say Down and lower volume and center Volume Up below Stop and set volume increment to 8",
                "set initial volume to 32"
            ],
            [
                "add volume up",
                "change volume step from 4 to 8"
            ],
            [
                "add volume up",
                "change volume step to 0x08"
            ],
            [
                "add volume up",
                "change volume step to $08"
            ],
            [
                "add volume up",
                "set playback note to C-3 and change volume step to 8",
                "set initial volume to 32"
            ],
            [
                "change Stop button caption Halt",
                "set Halt button title Stop"
            ],
            [
                #"rename 'Stop' to 'Bass "Boost"'"#,
                "set initial volume to 32"
            ],
            [
                #"rename 'Stop' to 'Bass \ Boost'"#,
                "set initial volume to 32"
            ],
            [
                "set initial volume to 31",
                "set initial volume to max",
                "set initial volume to 32 for channel 0"
            ],
            [
                "set initial volume to 31",
                "set initial volume to 0x21"
            ],
            [
                "set volume to 200",
                "set volume to 0"
            ],
            [
                "add volume up",
                "rename \"Volume Up\" to \"Louder\"",
                "add volume down",
                "change volume step to 8",
                "set initial volume to 32"
            ],
            [
                "add volume up",
                "add volume down",
                "add pause",
                "add mute"
            ],
            [
                "add volume up",
                "rename \"Volume Up\" to \"Louder\"",
                "make the volume up button say Boost",
                "change volume step to 8",
                "set initial volume to 32"
            ],
            [
                "add volume up",
                "rename \"Volume Up\" to \"Louder\"",
                "rename volume_up control to Boost",
                "change volume step to 8"
            ],
            [
                "add another button named Hold to pause the mod",
                "make the pause button say Freeze",
                "add mute"
            ],
            [
                "add another button called Louder",
                "add volume down"
            ],
            [
                #"add a third button called "Louder" to raise volume after I stop and play the mod"#,
                "make the volume up button say Boost",
                "change volume step to 8"
            ],
            [
                #"add a third button called 'Louder' to "raise volume""#,
                #"rename 'Louder' to "Boost""#,
                "change volume step to 8"
            ],
            [
                "add a third button with label Louder to raise volume",
                "change volume step to 8"
            ],
            [
                "add another button to pause the mod with text Hold",
                "add mute"
            ],
            [
                "add another button with title Hold to pause the mod",
                "add another button to mute the mod with caption Silence"
            ],
            [
                "add volume controls",
                "change volume step to 8"
            ],
            [
                "add a volume up button and a volume down button",
                "change volume step to 8"
            ],
            [
                #"add a third button called "Volume Up" to raise volume"#,
                #"add a fourth button called "Volume Down" to lower volume"#,
                "add pause",
                "rename Volume Down to Quieter and move Quieter after Pause and set volume increment to 8",
                "set initial volume to 32"
            ],
            [
                "add buttons for volume up and volume down",
                "change volume step to 8"
            ],
            [
                "add volume down and volume up",
                "change volume step to 8"
            ],
            [
                "add a pause button and a mute button",
                "make the pause button say Freeze"
            ],
            [
                "add pause and mute controls",
                "make the pause button say Freeze"
            ],
            [
                "add volume up",
                "add volume down",
                "remove volume up",
                "change volume step to 8"
            ],
            [
                "add volume up",
                "add volume down",
                "remove Volume Up and set volume increment to 8",
                "set initial volume to 32"
            ],
            [
                "add volume controls",
                "remove Volume Up and rename Volume Down to Quieter",
                "set volume increment to 8"
            ],
            [
                "add volume controls",
                "remove Volume Up and rename Volume Down to Quieter and set initial volume to 32",
                "set volume increment to 8"
            ],
            [
                "add volume controls",
                "add pause",
                "remove Volume Up and rename Volume Down to Quieter and move Quieter after Pause",
                "set volume increment to 8"
            ],
            [
                "add volume controls",
                "add pause",
                "remove Volume Up and rename Volume Down to Quieter and move Quieter after Pause and set initial volume to 32",
                "set volume increment to 8"
            ],
            [
                "add volume controls",
                "add pause",
                "remove Volume Up and rename Volume Down to Quieter and move Quieter after Pause and set initial volume to 32",
                #"add another button called "Louder" to raise volume"#,
                "set playback period to 428"
            ],
            [
                "add volume controls",
                "remove Volume Up and rename Volume Down to Quieter and center Volume Down below Stop",
                "set volume increment to 8"
            ],
            [
                "add volume controls",
                "remove Volume Up and rename Volume Down to Quieter and center Volume Down below Stop and set initial volume to 32",
                "set volume increment to 8"
            ],
            [
                "add volume controls",
                "add pause",
                "remove Volume Up and rename Volume Down to Quieter and center Volume Down below Stop and move Quieter after Pause",
                "set volume increment to 8"
            ],
            [
                "add volume controls",
                "add pause",
                "remove Volume Up and rename Volume Down to Quieter and center Volume Down below Stop and move Quieter after Pause and set initial volume to 32",
                "set volume increment to 8"
            ],
            [
                "add volume controls",
                "remove Volume Up and make Volume Down mute instead",
                "set initial volume to 32"
            ],
            [
                "add volume controls",
                "remove Volume Up and make Volume Down mute instead and set initial volume to 32",
                "set playback period to 428"
            ],
            [
                "add volume controls",
                "add pause",
                "remove Volume Up and make Volume Down mute instead and move Volume Down after Pause",
                "set initial volume to 32"
            ],
            [
                "add volume controls",
                "add pause",
                "remove Volume Up and make Volume Down mute instead and move Volume Down after Pause and set initial volume to 32",
                "set playback period to 428"
            ],
            [
                "add volume controls",
                "remove Volume Up and make Volume Down mute instead and center Volume Down below Stop",
                "set initial volume to 32"
            ],
            [
                "add volume controls",
                "remove Volume Up and make Volume Down mute instead and center Volume Down below Stop and set initial volume to 32",
                "set playback period to 428"
            ],
            [
                "add volume controls",
                "add pause",
                "remove Volume Up and make Volume Down mute instead and center Volume Down below Stop and move Volume Down after Pause",
                "set initial volume to 32"
            ],
            [
                "add volume controls",
                "add pause",
                "remove Volume Up and make Volume Down mute instead and center Volume Down below Stop and move Volume Down after Pause and set initial volume to 32",
                "set playback period to 428"
            ],
            [
                "add volume controls",
                "remove Volume Up and make Volume Down say Silence and mute instead",
                "set initial volume to 32"
            ],
            [
                "add volume controls",
                "remove Volume Up and make Volume Down say Silence and mute instead and set initial volume to 32",
                "set playback period to 428"
            ],
            [
                "add volume controls",
                "add pause",
                "remove Volume Up and make Volume Down say Silence and mute instead and move Silence after Pause",
                "set initial volume to 32"
            ],
            [
                "add volume controls",
                "add pause",
                "remove Volume Up and make Volume Down say Silence and mute instead and move Silence after Pause and set initial volume to 32",
                "set playback period to 428"
            ],
            [
                "add volume controls",
                "remove Volume Up and make Volume Down say Silence and mute instead and center Volume Down below Stop",
                "set initial volume to 32"
            ],
            [
                "add volume controls",
                "remove Volume Up and make Volume Down say Silence and mute instead and center Volume Down below Stop and set initial volume to 32",
                "set playback period to 428"
            ],
            [
                "add volume controls",
                "add pause",
                "remove Volume Up and make Volume Down say Silence and mute instead and center Volume Down below Stop and move Silence after Pause",
                "set initial volume to 32"
            ],
            [
                "add volume controls",
                "add pause",
                "remove Volume Up and make Volume Down say Silence and mute instead and center Volume Down below Stop and move Silence after Pause and set initial volume to 32",
                "set playback period to 428"
            ],
            [
                "add volume controls",
                "remove Volume Up and center Volume Down below Stop and set initial volume to 32",
                "set volume increment to 8"
            ],
            [
                "add volume controls",
                "remove Volume Up and center Volume Down below Stop",
                "set volume increment to 8"
            ],
            [
                "add volume controls",
                "add pause",
                "remove Volume Up and move Volume Down after Pause",
                "set volume increment to 8"
            ],
            [
                "add volume controls",
                "add pause",
                "remove Volume Up and center Volume Down below Stop and move Volume Down after Pause",
                "set volume increment to 8"
            ],
            [
                "add volume controls",
                "add pause",
                "remove Volume Up and move Volume Down after Pause and set volume increment to 8",
                "set initial volume to 32"
            ],
            [
                "add volume controls",
                "add pause",
                "remove Volume Up and center Volume Down below Stop and move Volume Down after Pause and set volume increment to 8",
                "set initial volume to 32"
            ],
            [
                "add volume up",
                #"rename "Volume Up" to "Louder""#,
                "remove Louder",
                "add a third button called Volume Up"
            ],
            [
                "add volume up",
                "remove the third button",
                "add a third button called Volume Up"
            ],
            [
                "add volume up",
                "add volume down",
                "move Volume Down before Volume Up",
                "change volume step to 8"
            ],
            [
                "add volume up",
                "add volume down",
                "move Volume Down before Volume Up and set volume increment to 8",
                "set initial volume to 32"
            ],
            [
                "add volume up",
                "add pause",
                "center Volume Up below Stop and move Volume Up after Pause",
                "change volume step to 8"
            ],
            [
                "add volume up",
                "add pause",
                "center Volume Up below Stop and move Volume Up after Pause and set volume increment to 8",
                "set initial volume to 32"
            ],
            [
                "add volume controls",
                "add pause and move Volume Down after Pause",
                "set volume increment to 8"
            ],
            [
                "add volume controls",
                "add pause and move Volume Down after Pause and set volume increment to 8",
                "set initial volume to 32"
            ],
            [
                "add volume up",
                "add volume down",
                "move the fourth button before the third button",
                "change volume step to 8"
            ],
            [
                "add volume up",
                #"rename "Volume Up" to "Louder""#,
                "add volume down",
                "move Volume Down before Louder"
            ],
            [
                "add volume controls",
                #"rename "Volume Up" to "Louder" and move Louder after Volume Down"#,
                "set volume increment to 8"
            ],
            [
                "add volume controls",
                #"rename "Volume Up" to "Louder" and move Louder after Volume Down and set volume increment to 8"#,
                "set initial volume to 32"
            ],
            [
                "add volume up",
                "add pause",
                #"rename "Volume Up" to "Louder" and center Volume Up below Stop and move Louder after Pause"#,
                "set volume increment to 8"
            ],
            [
                "add volume up",
                "add pause",
                #"rename "Volume Up" to "Louder" and center Volume Up below Stop and move Louder after Pause and set volume increment to 8"#,
                "set initial volume to 32"
            ],
            [
                "add pause",
                "make the Pause button mute instead",
                "set initial volume to 32"
            ],
            [
                "add volume up",
                "add pause",
                "make Volume Up mute instead and move Volume Up after Pause",
                "set initial volume to 32"
            ],
            [
                "add volume up",
                "make Volume Up mute instead and center Volume Up below Stop",
                "set initial volume to 32"
            ],
            [
                "add volume up",
                "make Volume Up mute instead and center Volume Up below Stop and set initial volume to 32",
                "set playback period to 428"
            ],
            [
                "add volume up",
                "add pause",
                "make Volume Up mute instead and center Volume Up below Stop and move Volume Up after Pause",
                "set initial volume to 32"
            ],
            [
                "add volume up",
                "add pause",
                "make Volume Up mute instead and move Volume Up after Pause and set initial volume to 32",
                "set playback period to 428"
            ],
            [
                "add volume up",
                "add pause",
                "make Volume Up mute instead and center Volume Up below Stop and move Volume Up after Pause and set initial volume to 32",
                "set playback period to 428"
            ],
            [
                "add volume up",
                #"rename "Volume Up" to "Louder""#,
                "make Louder lower volume instead",
                "add another button called Volume Up",
                "change volume step to 8"
            ],
            [
                "add volume up",
                #"rename "Volume Up" to "Louder""#,
                "make Louder say Down and lower volume",
                "change volume step to 8"
            ],
            [
                "add volume up",
                "add pause",
                "make Volume Up say Down and lower volume and move Down after Pause",
                "change volume step to 8"
            ],
            [
                "add volume up",
                "add pause",
                "make Volume Up say Down and lower volume and center Volume Up below Stop and move Down after Pause",
                "change volume step to 8"
            ],
            [
                "add volume up",
                "add pause",
                "make Volume Up say Down and lower volume and move Down after Pause and set volume increment to 8",
                "set initial volume to 32"
            ],
            [
                "add volume up",
                "add pause",
                "make Volume Up say Down and lower volume and center Volume Up below Stop and move Down after Pause and set volume increment to 8",
                "set initial volume to 32"
            ],
            [
                "add volume up",
                #"rename "Volume Up" to "Louder""#,
                "set Louder bounds to 208,72,88,20",
                "make Louder wider by 16",
                "move Louder left by 8",
                "center Louder below Stop",
                "center Louder below Stop and move it down by 4",
                "set playback note to C-3",
                "set playback period to 428",
                "change volume step to 8"
            ],
            [
                "add a volume up button centered below Stop",
                "change volume step to 8"
            ],
            [
                "add a volume up button centered below Stop and move it down by 4",
                "change volume step to 8"
            ],
            [
                "add a volume up button centered below Stop and make it wider by 16",
                "change volume step to 8"
            ],
            [
                "add volume up",
                "make the third button 80x20 centered below Stop",
                "change volume step to 8"
            ],
            [
                "add a button called Louder centered below Stop to raise volume and make it wider by 16",
                "change volume step to 8"
            ],
            [
                "add volume controls centered below Stop",
                "change volume step to 8"
            ],
            [
                "add volume controls centered below Stop and move them down by 4",
                "change volume step to 8"
            ],
            [
                "add volume controls",
                "center volume controls below Stop",
                "change volume step to 8"
            ],
            [
                "add volume controls",
                "center volume controls below Stop and move them down by 4",
                "change volume step to 8"
            ],
            [
                "add volume controls",
                "move volume controls down by 8",
                "change volume step to 8"
            ],
            [
                "add volume controls",
                "move volume controls down by 4 and make them wider by 8",
                "change volume step to 8"
            ],
            [
                "add volume controls",
                "move volume controls down by 4 and make them 80x20",
                "change volume step to 8"
            ],
            [
                "add volume controls",
                "make volume controls wider by 8",
                "change volume step to 8"
            ],
            [
                "add volume controls",
                "make volume controls wider by 8 centered below Stop",
                "change volume step to 8"
            ],
            [
                "add volume controls",
                "make volume controls 80x20",
                "change volume step to 8"
            ],
            [
                "add volume controls",
                "make volume controls 80x20 centered below Stop",
                "change volume step to 8"
            ]
        ],
        representativeRoutedFollowUpSmokeChains: [
            [
                #"add a third button called "Volume Up" to raise volume"#,
                #"add a fourth button called "Volume Down" to lower volume"#,
                "add pause",
                "rename Volume Down to Quieter and move Quieter after Pause and set volume increment to 8",
                "set initial volume to 32"
            ],
            [
                "add volume up",
                "make Volume Up mute instead and center Volume Up below Stop and set initial volume to 32",
                "set playback period to 428"
            ]
        ],
        requiredRejectedFollowUpSmokePrompts: [
            #"add a third button called "Bass Boost +""#,
            "add another button called Louderness",
            "change Stopper button text to Halt",
            "change volume step to 8",
            "set initial volume",
            #"add a third button called "Mute" to pause the mod"#,
            "add volume up and volume up",
            "add a mute button and a mute button",
            "rename the fourth button to Louder",
            "add a fourth button called Louder to raise volume",
            "add a volume up button centered left of Play",
            "add a volume up button centered below Stop and move it down by 220",
            "add a volume up button centered below Stop and make it wider by 260",
            "add a button called Louder centered below Stop to raise volume and make it wider by 260",
            "add volume controls centered left of Play",
            "add volume controls centered below Stop and move them down by 220",
            "add volume controls centered left of Play and set volume increment to 8",
            "remove Play",
            "move Play after Stop",
            "add volume up and change volume step"
        ],
        requiredRejectedFollowUpSmokeChains: [
            [
                "add volume up",
                "add volume up"
            ],
            [
                "add volume up",
                "change volume step"
            ],
            [
                "add volume up",
                "add a button called Down centered below Stop to lower volume and change volume step"
            ],
            [
                "add volume up",
                "add a button called Down to lower volume and move Down before Volume Up and change volume step"
            ],
            [
                "add volume up",
                "add a button called Down centered below Stop to lower volume and move Down before Volume Up and change volume step"
            ],
            [
                "add a button called Down to lower volume",
                "rename Down to Quieter and center Down below Stop and set initial volume"
            ],
            [
                "add volume up",
                #"rename "Volume Up" to "Louder" and change volume step"#
            ],
            [
                "add volume up",
                #"rename "Volume Up" to "Louder" and center Volume Up left of Play"#
            ],
            [
                "add volume up",
                "make Volume Up lower volume instead and change volume step"
            ],
            [
                "add volume up",
                "make Volume Up mute instead and center Volume Up below Stop and set initial volume"
            ],
            [
                "add volume up",
                "add pause",
                "make Volume Up mute instead and move Volume Up after Pause and set initial volume"
            ],
            [
                "add volume up",
                "add pause",
                "make Volume Up mute instead and center Volume Up below Stop and move Volume Up after Pause and set initial volume"
            ],
            [
                "add volume up",
                "make Volume Up say Down and lower volume and change volume step"
            ],
            [
                "add volume up",
                "add pause",
                "make Volume Up say Down and lower volume and move Down after Pause and change volume step"
            ],
            [
                "add volume up",
                "add pause",
                "make Volume Up say Down and lower volume and center Volume Up below Stop and move Down after Pause and change volume step"
            ],
            [
                "add volume up",
                "make Volume Up say Down and lower volume and center Volume Up left of Play"
            ],
            [
                "add volume up",
                "make Volume Up say Down and lower volume and center Volume Up below Stop and change volume step"
            ],
            [
                "add volume up",
                "center Volume Up below Stop and change volume step"
            ],
            [
                "add volume up",
                "add pause",
                "center Volume Up below Stop and move Volume Up after Pause and change volume step"
            ],
            [
                "add volume up",
                "remove Volume Up and change volume step"
            ],
            [
                "add volume controls",
                "remove Volume Up and center Volume Down below Stop and change volume step"
            ],
            [
                "add volume controls",
                "remove Volume Up and center Volume Up below Stop"
            ],
            [
                "add volume controls",
                "remove Volume Up and rename Volume Down to Quieter and center Volume Up below Stop"
            ],
            [
                "add volume controls",
                "add pause",
                "remove Volume Up and rename Volume Down to Quieter and move Volume Up after Pause"
            ],
            [
                "add volume controls",
                "add pause",
                "remove Volume Up and rename Volume Down to Quieter and center Volume Down below Stop and move Volume Up after Pause"
            ],
            [
                "add volume controls",
                "remove Volume Up and rename Volume Up to Louder"
            ],
            [
                "add volume controls",
                "remove Volume Up and make Volume Up mute instead"
            ],
            [
                "add volume controls",
                "remove Volume Up and make Volume Down mute instead and center Volume Up below Stop"
            ],
            [
                "add volume controls",
                "add pause",
                "remove Volume Up and make Volume Down mute instead and move Volume Up after Pause"
            ],
            [
                "add volume controls",
                "add pause",
                "remove Volume Up and make Volume Down mute instead and center Volume Down below Stop and move Volume Up after Pause"
            ],
            [
                "add volume controls",
                "remove Volume Up and make Volume Up say Silence and mute instead"
            ],
            [
                "add volume controls",
                "remove Volume Up and make Volume Down say Silence and mute instead and center Volume Up below Stop"
            ],
            [
                "add volume controls",
                "add pause",
                "remove Volume Up and make Volume Down say Silence and mute instead and move Volume Up after Pause"
            ],
            [
                "add volume controls",
                "add pause",
                "remove Volume Up and make Volume Down say Silence and mute instead and center Volume Down below Stop and move Volume Up after Pause"
            ],
            [
                "add volume controls",
                "add pause",
                "remove Volume Up and move Volume Up after Pause"
            ],
            [
                "add volume controls",
                "add pause",
                "remove Volume Up and move Volume Down after Pause and change volume step"
            ],
            [
                "add volume controls",
                "add pause",
                "remove Volume Up and center Volume Down below Stop and move Volume Down after Pause and change volume step"
            ],
            [
                "add volume controls",
                "add pause and move Volume Down after Pause and change volume step"
            ],
            [
                "add volume controls",
                #"rename "Volume Up" to "Louder" and move Louder after Volume Down and change volume step"#
            ],
            [
                "add volume up",
                "add pause",
                #"rename "Volume Up" to "Louder" and center Volume Up below Stop and move Louder after Pause and change volume step"#
            ],
            [
                "add volume up",
                "set playback note to C-3 and change volume step"
            ],
            [
                "set playback period to 214",
                "set playback period"
            ],
            [
                "set playback note to C-3",
                "set playback note"
            ],
            [
                "add volume up",
                "add a button to pause and mute"
            ],
            [
                "add volume up",
                "rename the fourth button to Louder"
            ],
            [
                "add volume up",
                "make the fourth button say Louder"
            ],
            [
                "add volume up",
                #"rename "Pause" to "Hold""#
            ],
            [
                "add volume up",
                "set initial volume"
            ],
            [
                "rename Play button to Start",
                #"add another button called "Play" to start playback"#
            ],
            [
                "rename Stop button to Halt",
                #"add another button called "Stop" to stop playback"#
            ],
            [
                "rename Play button to Start",
                #"rename "Stop" to "Play""#
            ],
            [
                #"add a third button called "Louder" to raise volume"#,
                "add volume up"
            ],
            [
                "add volume controls",
                "add pause",
                "remove Volume Up and rename Volume Down to Quieter and move Quieter after Pause and set initial volume to 32",
                #"add another button called "Louder" to raise volume"#,
                "set playback period to 428",
                "add volume up"
            ],
            [
                "rename Play button to Start",
                #"add another button called "Start" to raise volume"#
            ],
            [
                "add volume up",
                "remove Play"
            ],
            [
                "add volume up",
                "remove the fourth button"
            ],
            [
                "add volume up",
                "move Volume Down before Volume Up"
            ],
            [
                "add volume up",
                "add volume down",
                "move Volume Down before Volume Up and change volume step"
            ],
            [
                "add volume up",
                "move Volume Up before Pause"
            ],
            [
                "add volume up",
                "move Play after Stop"
            ],
            [
                "add volume up",
                "move the fifth button before the third button"
            ],
            [
                "add volume up",
                "move the third button before the fifth button"
            ],
            [
                "add pause",
                "add mute",
                "make Pause mute instead"
            ],
            [
                "add volume up",
                "add volume down",
                #"rename "Volume Up" to "Louder""#,
                "make Louder say Down and lower volume"
            ],
            [
                "add volume up",
                "make Play mute instead"
            ],
            [
                "add volume up",
                "make the third button wider by 200"
            ],
            [
                "add volume up",
                "move the third button right by 200"
            ],
            [
                "add volume up",
                "center the third button left of Play"
            ],
            [
                "add volume up",
                "center the third button below Stop and move it down by 220"
            ],
            [
                "add volume up",
                "make the third button 400x20 centered below Stop"
            ],
            [
                "add volume controls",
                "center volume controls left of Play"
            ],
            [
                "add volume controls",
                "center volume controls below Stop and move them down by 220"
            ],
            [
                "add volume controls",
                "move volume controls left by 260"
            ],
            [
                "add volume controls",
                "move volume controls down by 4 and make them wider by 260"
            ],
            [
                "add volume controls",
                "move volume controls down by 4 and make them 400x20"
            ],
            [
                "add volume controls",
                "make volume controls wider by 260"
            ],
            [
                "add volume controls",
                "make volume controls wider by 260 centered below Stop"
            ],
            [
                "add volume controls",
                "make volume controls 400x20"
            ],
            [
                "add volume controls",
                "make volume controls 400x20 centered below Stop"
            ]
        ],
        requiredRecoveryFollowUpSmokeChains: [
            [
                "add volume up",
                "change volume step",
                "set volume increment to 8"
            ],
            [
                "add volume controls",
                "add pause",
                "remove Volume Up and rename Volume Down to Quieter and move Quieter after Pause and set initial volume to 32",
                #"add another button called "Louder" to raise volume"#,
                "set playback period to 428",
                "add volume up",
                "add mute"
            ],
            [
                #"add a third button called "Volume Up" to raise volume"#,
                #"add a fourth button called "Volume Down" to lower volume"#,
                "add pause",
                "rename Volume Down to Quieter and move Quieter after Pause and set volume increment to 8",
                "set initial volume to 32",
                "set playback period",
                "set playback note to C-3"
            ]
        ],
        representativeRoutedRecoveryFollowUpSmokeChains: [
            [
                #"add a third button called "Volume Up" to raise volume"#,
                #"add a fourth button called "Volume Down" to lower volume"#,
                "add pause",
                "rename Volume Down to Quieter and move Quieter after Pause and set volume increment to 8",
                "set initial volume to 32",
                "set playback period",
                "set playback note to C-3"
            ],
            [
                "add volume controls",
                "add pause",
                "remove Volume Up and rename Volume Down to Quieter and move Quieter after Pause and set initial volume to 32",
                #"add another button called "Louder" to raise volume"#,
                "set playback period to 428",
                "add volume up",
                "add mute"
            ]
        ],
        requiredIgnoredFollowUpSmokePrompts: [
            "set volume amounting to 8",
            "make volume currentness 32",
            "change Stop button texture to Halt",
            "addendum raise volume"
        ],
        requiredRegions: [
            .model,
            .controls,
            .drawControls,
            .hitTest,
            .inputDispatch,
            .routines,
            .state,
            .chipData
        ],
        requiredHardware: [.paula, .cia, .bitplanes],
        requiredVerificationGates: [
            "verified first-shot template",
            "structured follow-up patcher",
            "representative routed conversation audit",
            "AmigaProgramSourceVerifier",
            "AssemblySemanticValidator",
            "VASM compile",
            "bootable ADF generation",
            "runtime observation contract",
            "optional vAmiga runtime smoke",
            "negative verifier tests"
        ]
    )

    static let all: [AmigaProgramFamilyManifest] = [
        doubleBufferedBitplane,
        modPlayerControls
    ]

    static func manifest(for id: String) -> AmigaProgramFamilyManifest? {
        all.first { $0.id == id }
    }
}

enum AmigaProgramFamilyPromotionAudit {
    private struct SemanticValidationCache {
        var results: [String: AssemblySemanticValidationResult] = [:]

        mutating func validate(source: String, prompt: String) -> AssemblySemanticValidationResult {
            let key = source + "\u{1f}" + prompt
            if let cached = results[key] {
                return cached
            }
            let result = AssemblySemanticValidator.validate(source: source, prompt: prompt)
            results[key] = result
            return result
        }
    }

    private struct FollowUpPatchOutcomeCache {
        var outcomes: [String: AmigaProgramFollowUpPatchOutcome] = [:]

        mutating func outcome(prompt: String, source: String) -> AmigaProgramFollowUpPatchOutcome {
            let key = source + "\u{1f}" + prompt
            if let cached = outcomes[key] {
                return cached
            }
            let outcome = AmigaProgramFollowUpPlanner.patchOutcome(prompt: prompt, source: source)
            outcomes[key] = outcome
            return outcome
        }
    }

    struct RoutedFirstShotFollowUpArtifact {
        let firstShotPrompt: String
        let followUpPrompt: String
        let source: String
        let model: AmigaProgramModel
    }

    struct RoutedFirstShotFollowUpEvent {
        enum Outcome: Equatable {
            case patched
            case rejected([String])
        }

        let firstShotPrompt: String
        let followUpPrompt: String
        let sourceBefore: String
        let sourceAfter: String
        let modelBefore: AmigaProgramModel
        let modelAfter: AmigaProgramModel
        let outcome: Outcome
    }

    static let baselineRequiredVerificationGates = [
        "verified first-shot template",
        "structured follow-up patcher",
        "representative routed conversation audit",
        "AmigaProgramSourceVerifier",
        "AssemblySemanticValidator",
        "VASM compile",
        "bootable ADF generation",
        "runtime observation contract",
        "optional vAmiga runtime smoke",
        "negative verifier tests"
    ]
    static let supportedVerificationGates = Set(baselineRequiredVerificationGates)
    static let supportedFollowUpDeclarationsByFamily: [String: Set<String>] = [
        AmigaProgramFamilyRegistry.doubleBufferedBitplane.id: [
            "set front color",
            "set back color"
        ],
        AmigaProgramFamilyRegistry.modPlayerControls.id: [
            "add volume up",
            "add volume down",
            "add volume controls",
            "add pause",
            "add mute",
            "rename a visible control label",
            "remove an added control",
            "reorder controls",
            "change an added control behavior",
            "change control bounds",
            "change playback note",
            "change playback period",
            "change volume step",
            "set initial volume"
        ]
    ]

    static func failuresForAllFamilies() -> [String] {
        failures(for: AmigaProgramFamilyRegistry.all)
    }

    static func failures(for manifests: [AmigaProgramFamilyManifest]) -> [String] {
        let registryFailures = registryFailures(for: manifests)
        guard registryFailures.isEmpty else {
            return registryFailures
        }
        return manifests.flatMap { failures(for: $0) }
    }

    static func failures(for manifest: AmigaProgramFamilyManifest) -> [String] {
        var failures: [String] = []

        if normalizedPromptKey(manifest.id).isEmpty {
            failures.append("<blank>: blank family id.")
        } else if manifest.id != manifest.id.trimmingCharacters(in: .whitespacesAndNewlines) {
            failures.append("\(manifest.id): family id has leading or trailing whitespace.")
        }
        if normalizedPromptKey(manifest.name).isEmpty {
            failures.append("\(manifest.id): blank family name.")
        } else if manifest.name != manifest.name.trimmingCharacters(in: .whitespacesAndNewlines) {
            failures.append("\(manifest.id): family name has leading or trailing whitespace.")
        }
        if manifest.firstShotPromptExamples.isEmpty {
            failures.append("\(manifest.id): missing first-shot prompt examples.")
        }
        failures.append(contentsOf: blankPromptFailures(
            in: manifest.firstShotPromptExamples,
            manifestID: manifest.id,
            fieldName: "first-shot prompt examples"
        ))
        failures.append(contentsOf: trimmedPromptFailures(
            in: manifest.firstShotPromptExamples,
            manifestID: manifest.id,
            fieldName: "first-shot prompt examples"
        ))
        failures.append(contentsOf: duplicatePromptFailures(
            in: manifest.firstShotPromptExamples,
            manifestID: manifest.id,
            fieldName: "first-shot prompt examples"
        ))
        if manifest.rejectedFirstShotPromptExamples.isEmpty {
            failures.append("\(manifest.id): missing rejected first-shot prompt examples.")
        }
        failures.append(contentsOf: blankPromptFailures(
            in: manifest.rejectedFirstShotPromptExamples,
            manifestID: manifest.id,
            fieldName: "rejected first-shot prompt examples"
        ))
        failures.append(contentsOf: trimmedPromptFailures(
            in: manifest.rejectedFirstShotPromptExamples,
            manifestID: manifest.id,
            fieldName: "rejected first-shot prompt examples"
        ))
        failures.append(contentsOf: duplicatePromptFailures(
            in: manifest.rejectedFirstShotPromptExamples,
            manifestID: manifest.id,
            fieldName: "rejected first-shot prompt examples"
        ))
        for prompt in overlappingPrompts(
            manifest.firstShotPromptExamples,
            manifest.rejectedFirstShotPromptExamples
        ) {
            failures.append("\(manifest.id): first-shot prompt cannot be both accepted and rejected: \(prompt)")
        }
        if manifest.representativeRoutedFirstShotPromptExamples.isEmpty {
            failures.append("\(manifest.id): missing representative routed first-shot prompt examples.")
        }
        failures.append(contentsOf: blankPromptFailures(
            in: manifest.representativeRoutedFirstShotPromptExamples,
            manifestID: manifest.id,
            fieldName: "representative routed first-shot prompt examples"
        ))
        failures.append(contentsOf: trimmedPromptFailures(
            in: manifest.representativeRoutedFirstShotPromptExamples,
            manifestID: manifest.id,
            fieldName: "representative routed first-shot prompt examples"
        ))
        failures.append(contentsOf: duplicatePromptFailures(
            in: manifest.representativeRoutedFirstShotPromptExamples,
            manifestID: manifest.id,
            fieldName: "representative routed first-shot prompt examples"
        ))
        let firstShotPromptKeys = Set(manifest.firstShotPromptExamples.map(Self.normalizedPromptKey))
        for prompt in manifest.representativeRoutedFirstShotPromptExamples
            where !firstShotPromptKeys.contains(Self.normalizedPromptKey(prompt)) {
            failures.append("\(manifest.id): representative routed first-shot prompt is not declared by first-shot prompt examples: \(prompt)")
        }
        if manifest.supportedFollowUps.isEmpty {
            failures.append("\(manifest.id): missing supported follow-up declarations.")
        }
        failures.append(contentsOf: blankPromptFailures(
            in: manifest.supportedFollowUps,
            manifestID: manifest.id,
            fieldName: "supported follow-up declarations"
        ))
        failures.append(contentsOf: trimmedPromptFailures(
            in: manifest.supportedFollowUps,
            manifestID: manifest.id,
            fieldName: "supported follow-up declarations"
        ))
        failures.append(contentsOf: duplicatePromptFailures(
            in: manifest.supportedFollowUps,
            manifestID: manifest.id,
            fieldName: "supported follow-up declarations"
        ))
        let supportedFollowUpDeclarations = supportedFollowUpDeclarationsByFamily[manifest.id] ?? []
        for supportedFollowUp in manifest.supportedFollowUps
            where !supportedFollowUpDeclarations.contains(supportedFollowUp) {
            failures.append("\(manifest.id): unsupported follow-up declaration for family: \(supportedFollowUp).")
        }
        if manifest.requiredFollowUpSmokePrompts.isEmpty {
            failures.append("\(manifest.id): missing required follow-up smoke prompts.")
        }
        failures.append(contentsOf: blankPromptFailures(
            in: manifest.requiredFollowUpSmokePrompts,
            manifestID: manifest.id,
            fieldName: "required follow-up smoke prompts"
        ))
        failures.append(contentsOf: trimmedPromptFailures(
            in: manifest.requiredFollowUpSmokePrompts,
            manifestID: manifest.id,
            fieldName: "required follow-up smoke prompts"
        ))
        failures.append(contentsOf: duplicatePromptFailures(
            in: manifest.requiredFollowUpSmokePrompts,
            manifestID: manifest.id,
            fieldName: "required follow-up smoke prompts"
        ))
        if manifest.requiredFollowUpSmokeChains.isEmpty {
            failures.append("\(manifest.id): missing required follow-up smoke chains.")
        }
        failures.append(contentsOf: duplicateChainFailures(
            in: manifest.requiredFollowUpSmokeChains,
            manifestID: manifest.id,
            fieldName: "required follow-up smoke chains"
        ))
        for (index, chain) in manifest.requiredFollowUpSmokeChains.enumerated() where chain.isEmpty {
            failures.append("\(manifest.id): required follow-up smoke chain \(index + 1) is empty.")
        }
        for (index, chain) in manifest.requiredFollowUpSmokeChains.enumerated() where chain.count == 1 {
            failures.append("\(manifest.id): required follow-up smoke chain \(index + 1) must contain at least two follow-ups.")
        }
        for (index, chain) in manifest.requiredFollowUpSmokeChains.enumerated() {
            failures.append(contentsOf: blankChainPromptFailures(
                in: chain,
                manifestID: manifest.id,
                chainName: "required follow-up smoke chain \(index + 1)"
            ))
            failures.append(contentsOf: trimmedChainPromptFailures(
                in: chain,
                manifestID: manifest.id,
                chainName: "required follow-up smoke chain \(index + 1)"
            ))
            for prompt in duplicatePrompts(in: chain) {
                failures.append("\(manifest.id): required follow-up smoke chain \(index + 1) repeats prompt: \(prompt)")
            }
        }
        if manifest.representativeRoutedFollowUpSmokeChains.isEmpty {
            failures.append("\(manifest.id): missing representative routed follow-up smoke chains.")
        }
        failures.append(contentsOf: duplicateChainFailures(
            in: manifest.representativeRoutedFollowUpSmokeChains,
            manifestID: manifest.id,
            fieldName: "representative routed follow-up smoke chains"
        ))
        let requiredFollowUpChainKeys = Set(manifest.requiredFollowUpSmokeChains.map(Self.normalizedChainKey))
        for chain in manifest.representativeRoutedFollowUpSmokeChains
            where !requiredFollowUpChainKeys.contains(Self.normalizedChainKey(chain)) {
            failures.append("\(manifest.id): representative routed follow-up smoke chain is not declared by required follow-up smoke chains: \(chain.joined(separator: " -> "))")
        }
        if manifest.requiredRejectedFollowUpSmokeChains.isEmpty {
            failures.append("\(manifest.id): missing required rejected follow-up smoke chains.")
        }
        failures.append(contentsOf: duplicateChainFailures(
            in: manifest.requiredRejectedFollowUpSmokeChains,
            manifestID: manifest.id,
            fieldName: "required rejected follow-up smoke chains"
        ))
        for (index, chain) in manifest.requiredRejectedFollowUpSmokeChains.enumerated() where chain.isEmpty {
            failures.append("\(manifest.id): required rejected follow-up smoke chain \(index + 1) is empty.")
        }
        for (index, chain) in manifest.requiredRejectedFollowUpSmokeChains.enumerated() where chain.count == 1 {
            failures.append("\(manifest.id): required rejected follow-up smoke chain \(index + 1) must contain at least one accepted setup and one rejected follow-up.")
        }
        for (index, chain) in manifest.requiredRejectedFollowUpSmokeChains.enumerated() {
            failures.append(contentsOf: blankChainPromptFailures(
                in: chain,
                manifestID: manifest.id,
                chainName: "required rejected follow-up smoke chain \(index + 1)"
            ))
            failures.append(contentsOf: trimmedChainPromptFailures(
                in: chain,
                manifestID: manifest.id,
                chainName: "required rejected follow-up smoke chain \(index + 1)"
            ))
            for prompt in duplicatePrompts(in: Array(chain.dropLast())) {
                failures.append("\(manifest.id): required rejected follow-up smoke chain \(index + 1) repeats setup prompt: \(prompt)")
            }
        }
        failures.append(contentsOf: duplicateChainFailures(
            in: manifest.requiredRecoveryFollowUpSmokeChains,
            manifestID: manifest.id,
            fieldName: "required recovery follow-up smoke chains"
        ))
        for (index, chain) in manifest.requiredRecoveryFollowUpSmokeChains.enumerated() where chain.isEmpty {
            failures.append("\(manifest.id): required recovery follow-up smoke chain \(index + 1) is empty.")
        }
        for (index, chain) in manifest.requiredRecoveryFollowUpSmokeChains.enumerated() where chain.count < 3 {
            failures.append("\(manifest.id): required recovery follow-up smoke chain \(index + 1) must contain accepted setup, rejected follow-up, and recovery follow-up.")
        }
        for (index, chain) in manifest.requiredRecoveryFollowUpSmokeChains.enumerated() {
            failures.append(contentsOf: blankChainPromptFailures(
                in: chain,
                manifestID: manifest.id,
                chainName: "required recovery follow-up smoke chain \(index + 1)"
            ))
            failures.append(contentsOf: trimmedChainPromptFailures(
                in: chain,
                manifestID: manifest.id,
                chainName: "required recovery follow-up smoke chain \(index + 1)"
            ))
            for prompt in duplicatePrompts(in: Array(chain.dropLast(2))) {
                failures.append("\(manifest.id): required recovery follow-up smoke chain \(index + 1) repeats setup prompt: \(prompt)")
            }
        }
        if !manifest.requiredRecoveryFollowUpSmokeChains.isEmpty,
           manifest.representativeRoutedRecoveryFollowUpSmokeChains.isEmpty {
            failures.append("\(manifest.id): missing representative routed recovery follow-up smoke chains.")
        }
        failures.append(contentsOf: duplicateChainFailures(
            in: manifest.representativeRoutedRecoveryFollowUpSmokeChains,
            manifestID: manifest.id,
            fieldName: "representative routed recovery follow-up smoke chains"
        ))
        let requiredRecoveryChainKeys = Set(manifest.requiredRecoveryFollowUpSmokeChains.map(Self.normalizedChainKey))
        for chain in manifest.representativeRoutedRecoveryFollowUpSmokeChains
            where !requiredRecoveryChainKeys.contains(Self.normalizedChainKey(chain)) {
            failures.append("\(manifest.id): representative routed recovery follow-up smoke chain is not declared by required recovery follow-up smoke chains: \(chain.joined(separator: " -> "))")
        }
        for supportedFollowUp in manifest.supportedFollowUps
            where !acceptedSmokePrompts(in: manifest).contains(where: { smokePromptCovers($0, supportedFollowUp: supportedFollowUp) }) {
            failures.append("\(manifest.id): supported follow-up lacks accepted smoke coverage: \(supportedFollowUp).")
        }
        let representativePrompts = representativeAcceptedSmokePrompts(in: manifest)
        for supportedFollowUp in manifest.supportedFollowUps
            where !representativePrompts.contains(where: { smokePromptCovers($0, supportedFollowUp: supportedFollowUp) }) {
            failures.append("\(manifest.id): supported follow-up lacks representative routed accepted smoke coverage: \(supportedFollowUp).")
        }
        let acceptedPrompts = acceptedSmokePrompts(in: manifest)
        for prompt in acceptedPrompts
            where !manifest.supportedFollowUps.contains(where: { smokePromptCovers(prompt, supportedFollowUp: $0) }) {
            failures.append("\(manifest.id): accepted smoke prompt exercises undeclared follow-up capability: \(prompt).")
        }
        if manifest.requiredRejectedFollowUpSmokePrompts.isEmpty {
            failures.append("\(manifest.id): missing required rejected follow-up smoke prompts.")
        }
        failures.append(contentsOf: blankPromptFailures(
            in: manifest.requiredRejectedFollowUpSmokePrompts,
            manifestID: manifest.id,
            fieldName: "required rejected follow-up smoke prompts"
        ))
        failures.append(contentsOf: trimmedPromptFailures(
            in: manifest.requiredRejectedFollowUpSmokePrompts,
            manifestID: manifest.id,
            fieldName: "required rejected follow-up smoke prompts"
        ))
        failures.append(contentsOf: duplicatePromptFailures(
            in: manifest.requiredRejectedFollowUpSmokePrompts,
            manifestID: manifest.id,
            fieldName: "required rejected follow-up smoke prompts"
        ))
        for prompt in rejectedSmokePrompts(in: manifest)
            where !manifest.supportedFollowUps.contains(where: { rejectedSmokePromptCovers(prompt, supportedFollowUp: $0) }) {
            failures.append("\(manifest.id): rejected smoke prompt exercises undeclared follow-up capability: \(prompt).")
        }
        if manifest.requiredIgnoredFollowUpSmokePrompts.isEmpty {
            failures.append("\(manifest.id): missing required ignored follow-up smoke prompts.")
        }
        failures.append(contentsOf: blankPromptFailures(
            in: manifest.requiredIgnoredFollowUpSmokePrompts,
            manifestID: manifest.id,
            fieldName: "required ignored follow-up smoke prompts"
        ))
        failures.append(contentsOf: trimmedPromptFailures(
            in: manifest.requiredIgnoredFollowUpSmokePrompts,
            manifestID: manifest.id,
            fieldName: "required ignored follow-up smoke prompts"
        ))
        failures.append(contentsOf: duplicatePromptFailures(
            in: manifest.requiredIgnoredFollowUpSmokePrompts,
            manifestID: manifest.id,
            fieldName: "required ignored follow-up smoke prompts"
        ))
        if manifest.requiredRegions.isEmpty {
            failures.append("\(manifest.id): missing required source regions.")
        }
        failures.append(contentsOf: duplicateRawValueFailures(
            in: manifest.requiredRegions,
            manifestID: manifest.id,
            fieldName: "required source regions"
        ))
        if manifest.requiredHardware.isEmpty {
            failures.append("\(manifest.id): missing required hardware declarations.")
        }
        failures.append(contentsOf: duplicateRawValueFailures(
            in: manifest.requiredHardware,
            manifestID: manifest.id,
            fieldName: "required hardware declarations"
        ))
        if manifest.requiredVerificationGates.isEmpty {
            failures.append("\(manifest.id): missing required verification gates.")
        }
        failures.append(contentsOf: blankPromptFailures(
            in: manifest.requiredVerificationGates,
            manifestID: manifest.id,
            fieldName: "required verification gates"
        ))
        failures.append(contentsOf: trimmedPromptFailures(
            in: manifest.requiredVerificationGates,
            manifestID: manifest.id,
            fieldName: "required verification gates"
        ))
        failures.append(contentsOf: duplicatePromptFailures(
            in: manifest.requiredVerificationGates,
            manifestID: manifest.id,
            fieldName: "required verification gates"
        ))
        for gate in manifest.requiredVerificationGates where !supportedVerificationGates.contains(gate) {
            failures.append("\(manifest.id): unsupported verification gate declaration: \(gate).")
        }
        for gate in baselineRequiredVerificationGates where !manifest.requiredVerificationGates.contains(gate) {
            failures.append("\(manifest.id): missing baseline verification gate: \(gate).")
        }

        var semanticCache = SemanticValidationCache()
        var patchCache = FollowUpPatchOutcomeCache()
        failures.append(contentsOf: firstShotPromptGateFailures(for: manifest, semanticCache: &semanticCache))
        failures.append(contentsOf: rejectedFirstShotPromptRoutingFailures(for: manifest))

        if shouldSkipArtifactAudit(for: manifest, after: failures) {
            return failures
        }

        let source: String
        do {
            source = try verifiedSource(for: manifest)
        } catch {
            failures.append("\(manifest.id): verified source failed: \(error.localizedDescription)")
            return failures
        }

        let index = AmigaSourceIndexer.index(source)
        guard let model = index.model else {
            failures.append("\(manifest.id): verified source does not embed an AmigaProgramModel.")
            return failures
        }

        if model.id != manifest.id {
            failures.append("\(manifest.id): embedded model id \(model.id) does not match manifest id.")
        }
        if model.kind != manifest.kind {
            failures.append("\(manifest.id): embedded model kind \(model.kind.rawValue) does not match manifest kind \(manifest.kind.rawValue).")
        }

        let modelHardware = Set(model.hardware)
        for subsystem in manifest.requiredHardware where !modelHardware.contains(subsystem) {
            failures.append("\(manifest.id): model is missing manifest-required hardware \(subsystem.rawValue).")
        }

        for region in manifest.requiredRegions {
            guard let sourceRegion = index.regions[region.rawValue] else {
                failures.append("\(manifest.id): missing manifest-required region \(region.rawValue).")
                continue
            }
            if sourceRegion.endLine == nil {
                failures.append("\(manifest.id): manifest-required region \(region.rawValue) is not closed.")
            }
        }

        let verifierFailures = AmigaProgramSourceVerifier.failures(in: source)
        failures.append(contentsOf: verifierFailures.map { "\(manifest.id): verifier failure: \($0)" })
        failures.append(contentsOf: runtimeObservationFailures(for: manifest, source: source))

        for prompt in manifest.firstShotPromptExamples {
            guard let match = AssistantPromptTemplate.match(for: prompt) else {
                continue
            }
            failures.append(contentsOf: firstShotFollowUpSmokeFailures(
                for: manifest,
                prompt: prompt,
                source: match.source,
                semanticCache: &semanticCache,
                patchCache: &patchCache
            ))
        }

        failures.append(contentsOf: followUpSmokeFailures(for: manifest, source: source, semanticCache: &semanticCache, patchCache: &patchCache))
        failures.append(contentsOf: rejectedFollowUpSmokeFailures(for: manifest, source: source, patchCache: &patchCache))
        failures.append(contentsOf: recoveryFollowUpSmokeFailures(for: manifest, source: source, patchCache: &patchCache))
        failures.append(contentsOf: representativeRoutedFirstShotConversationFailures(for: manifest))
        failures.append(contentsOf: ignoredFollowUpSmokeFailures(for: manifest, source: source))

        return failures
    }

    static func runtimeObservationFailures(for manifest: AmigaProgramFamilyManifest, source: String) -> [String] {
        let index = AmigaSourceIndexer.index(source)
        guard let model = index.model else {
            return ["\(manifest.id): runtime observation contract failure: missing embedded AmigaProgramModel."]
        }

        let normalizedLines = source
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { normalizedRuntimeObservationLine(String($0)) }
        let containsLine: (String) -> Bool = { needle in
            normalizedLines.contains { $0.contains(needle) }
        }

        switch manifest.id {
        case AmigaProgramFamilyRegistry.doubleBufferedBitplane.id:
            var failures: [String] = []
            if !model.hardware.contains(.bitplanes) {
                failures.append("\(manifest.id): runtime observation contract failure: model does not declare bitplane hardware.")
            }
            if !model.hardware.contains(.copper) {
                failures.append("\(manifest.id): runtime observation contract failure: model does not declare copper hardware.")
            }
            if !model.hardware.contains(.sprites) {
                failures.append("\(manifest.id): runtime observation contract failure: model does not declare sprite hardware.")
            }
            if !containsLine("move.wfrontcolor(pc),$182(a6)") ||
                !containsLine("move.wbackcolor(pc),$182(a6)") {
                failures.append("\(manifest.id): runtime observation contract failure: missing COLOR01 writes for front/back frame evidence.")
            }
            if !containsLine("move.la2,$e0(a6)") ||
                !containsLine("move.la3,$e0(a6)") {
                failures.append("\(manifest.id): runtime observation contract failure: missing BPL1PT writes for both front/back buffers.")
            }
            if !containsLine("bsr.swaitvblank") && !containsLine("bsrwaitvblank") {
                failures.append("\(manifest.id): runtime observation contract failure: frame swap is not paced through WaitVBlank.")
            }
            if !containsLine("move.wa0,$80(a6)") && !containsLine("move.la0,$80(a6)") {
                failures.append("\(manifest.id): runtime observation contract failure: missing owned copper-list install.")
            }
            if !containsLine("move.la4,$120(a6)") {
                failures.append("\(manifest.id): runtime observation contract failure: missing sprite overlay pointer write.")
            }
            if !containsLine("move.w#$83a0,$96(a6)") {
                failures.append("\(manifest.id): runtime observation contract failure: missing bitplane/copper/sprite DMA enable.")
            }
            for label in ["buffera:", "bufferb:", "patterna:", "patternb:", "copperlist:", "spritedata:"] where !containsLine(label) {
                failures.append("\(manifest.id): runtime observation contract failure: missing visible frame data label \(label.dropLast()).")
            }
            return failures

        case AmigaProgramFamilyRegistry.modPlayerControls.id:
            var failures: [String] = []
            if !model.hardware.contains(.paula) {
                failures.append("\(manifest.id): runtime observation contract failure: model does not declare Paula hardware.")
            }
            let requiredSignals = [
                ("AUD0LC sample pointer write", "move.la0,$a0(a6)"),
                ("AUD0LEN sample length write", "move.w#8,$a4(a6)"),
                ("AUD0PER playback period write", "$a6(a6)"),
                ("AUD0VOL volume write", "$a8(a6)"),
                ("audio DMA enable", "move.w#$8201,$96(a6)"),
                ("audio DMA stop", "move.w#$0001,$96(a6)"),
                ("playback-state set", "move.w#1,playbackstate"),
                ("playback-state clear", "clr.wplaybackstate")
            ]
            for (name, needle) in requiredSignals where !containsLine(needle) {
                failures.append("\(manifest.id): runtime observation contract failure: missing \(name).")
            }
            if !containsLine("bsrplaymod") {
                failures.append("\(manifest.id): runtime observation contract failure: startup does not preview PlayMOD for emulator-visible Paula evidence.")
            }
            return failures

        default:
            return ["\(manifest.id): runtime observation contract failure: no runtime contract is defined for this promoted family."]
        }
    }

    private static func normalizedRuntimeObservationLine(_ line: String) -> String {
        let code = line.split(separator: ";", maxSplits: 1, omittingEmptySubsequences: false).first.map(String.init) ?? ""
        return code
            .lowercased()
            .replacingOccurrences(of: #"\s+"#, with: "", options: .regularExpression)
    }

    private static func firstShotPromptGateFailures(for manifest: AmigaProgramFamilyManifest) -> [String] {
        var semanticCache = SemanticValidationCache()
        return firstShotPromptGateFailures(for: manifest, semanticCache: &semanticCache)
    }

    private static func firstShotPromptGateFailures(
        for manifest: AmigaProgramFamilyManifest,
        semanticCache: inout SemanticValidationCache
    ) -> [String] {
        var failures: [String] = []
        for prompt in manifest.firstShotPromptExamples {
            guard let match = AssistantPromptTemplate.match(for: prompt) else {
                failures.append("\(manifest.id): first-shot prompt did not route: \(prompt)")
                continue
            }
            if match.id != manifest.id {
                failures.append("\(manifest.id): first-shot prompt routed to \(match.id) instead of manifest id for prompt: \(prompt)")
            }
            let matchIndex = AmigaSourceIndexer.index(match.source)
            if let matchModel = matchIndex.model {
                if matchModel.id != manifest.id {
                    failures.append("\(manifest.id): first-shot prompt embedded model id \(matchModel.id) instead of manifest id for prompt: \(prompt)")
                }
                if matchModel.kind != manifest.kind {
                    failures.append("\(manifest.id): first-shot prompt embedded model kind \(matchModel.kind.rawValue) instead of \(manifest.kind.rawValue) for prompt: \(prompt)")
                }
                let matchHardware = Set(matchModel.hardware)
                for subsystem in manifest.requiredHardware where !matchHardware.contains(subsystem) {
                    failures.append("\(manifest.id): first-shot prompt model is missing manifest-required hardware \(subsystem.rawValue) for prompt: \(prompt)")
                }
            } else {
                failures.append("\(manifest.id): first-shot prompt did not embed an AmigaProgramModel for prompt: \(prompt)")
            }
            for region in manifest.requiredRegions {
                guard let sourceRegion = matchIndex.regions[region.rawValue] else {
                    failures.append("\(manifest.id): first-shot prompt is missing manifest-required region \(region.rawValue) for prompt: \(prompt)")
                    continue
                }
                if sourceRegion.endLine == nil {
                    failures.append("\(manifest.id): first-shot prompt manifest-required region \(region.rawValue) is not closed for prompt: \(prompt)")
                }
            }
            let matchVerifierFailures = AmigaProgramSourceVerifier.failures(in: match.source)
            failures.append(contentsOf: matchVerifierFailures.map { "\(manifest.id): first-shot prompt verifier failure for prompt \(prompt): \($0)" })
            let semantic = semanticCache.validate(source: match.source, prompt: prompt)
            if !semantic.passed {
                failures.append("\(manifest.id): semantic gate failed for first-shot prompt \(prompt): \(semantic.summary)")
            }
        }
        return failures
    }

    private static func rejectedFirstShotPromptRoutingFailures(for manifest: AmigaProgramFamilyManifest) -> [String] {
        manifest.rejectedFirstShotPromptExamples.compactMap { prompt in
            guard let match = AssistantPromptTemplate.match(for: prompt), match.id == manifest.id else {
                return nil
            }
            return "\(manifest.id): rejected first-shot prompt routed to manifest id: \(prompt)"
        }
    }

    private static func shouldSkipArtifactAudit(
        for manifest: AmigaProgramFamilyManifest,
        after failures: [String]
    ) -> Bool {
        guard AmigaProgramFamilyRegistry.manifest(for: manifest.id) != nil else {
            return false
        }
        return failures.contains { failure in
            fatalManifestFailureFragments.contains { failure.contains($0) }
        }
    }

    private static let fatalManifestFailureFragments = [
        ": blank family id.",
        ": blank family name.",
        ": family id has leading or trailing whitespace.",
        ": family name has leading or trailing whitespace.",
        ": missing first-shot prompt examples.",
        ": blank first-shot prompt examples",
        ": first-shot prompt examples at index",
        ": duplicate first-shot prompt examples:",
        ": first-shot prompt cannot be both accepted and rejected:",
        ": first-shot prompt did not route:",
        ": first-shot prompt routed to ",
        ": first-shot prompt embedded model id ",
        ": first-shot prompt embedded model kind ",
        ": first-shot prompt did not embed an AmigaProgramModel",
        ": first-shot prompt is missing manifest-required region",
        ": first-shot prompt manifest-required region",
        ": first-shot prompt verifier failure",
        ": semantic gate failed for first-shot prompt",
        ": missing rejected first-shot prompt examples.",
        ": blank rejected first-shot prompt examples",
        ": rejected first-shot prompt examples at index",
        ": duplicate rejected first-shot prompt examples:",
        ": rejected first-shot prompt routed to manifest id:",
        ": missing representative routed first-shot prompt examples.",
        ": blank representative routed first-shot prompt examples",
        ": representative routed first-shot prompt examples at index",
        ": duplicate representative routed first-shot prompt examples:",
        ": representative routed first-shot prompt is not declared by first-shot prompt examples:",
        ": missing supported follow-up declarations.",
        ": blank supported follow-up declarations",
        ": supported follow-up declarations at index",
        ": duplicate supported follow-up declarations:",
        ": unsupported follow-up declaration for family:",
        ": missing required follow-up smoke prompts.",
        ": blank required follow-up smoke prompts",
        ": required follow-up smoke prompts at index",
        ": duplicate required follow-up smoke prompts:",
        ": missing required follow-up smoke chains.",
        ": duplicate required follow-up smoke chains:",
        ": required follow-up smoke chain ",
        ": missing representative routed follow-up smoke chains.",
        ": duplicate representative routed follow-up smoke chains:",
        ": representative routed follow-up smoke chain is not declared by required follow-up smoke chains:",
        ": missing required rejected follow-up smoke chains.",
        ": duplicate required rejected follow-up smoke chains:",
        ": required rejected follow-up smoke chain ",
        ": duplicate required recovery follow-up smoke chains:",
        ": required recovery follow-up smoke chain ",
        ": missing representative routed recovery follow-up smoke chains.",
        ": duplicate representative routed recovery follow-up smoke chains:",
        ": representative routed recovery follow-up smoke chain is not declared by required recovery follow-up smoke chains:",
        ": supported follow-up lacks representative routed accepted smoke coverage:",
        ": missing required rejected follow-up smoke prompts.",
        ": blank required rejected follow-up smoke prompts",
        ": required rejected follow-up smoke prompts at index",
        ": duplicate required rejected follow-up smoke prompts:",
        ": missing required ignored follow-up smoke prompts.",
        ": blank required ignored follow-up smoke prompts",
        ": required ignored follow-up smoke prompts at index",
        ": duplicate required ignored follow-up smoke prompts:",
        ": missing required source regions.",
        ": duplicate required source regions:",
        ": missing required hardware declarations.",
        ": duplicate required hardware declarations:",
        ": missing required verification gates.",
        ": blank required verification gates",
        ": required verification gates at index",
        ": duplicate required verification gates:",
        ": unsupported verification gate declaration:",
        ": missing baseline verification gate:"
    ]

    private static func firstShotFollowUpSmokeFailures(
        for manifest: AmigaProgramFamilyManifest,
        prompt: String,
        source: String
    ) -> [String] {
        var semanticCache = SemanticValidationCache()
        return firstShotFollowUpSmokeFailures(
            for: manifest,
            prompt: prompt,
            source: source,
            semanticCache: &semanticCache
        )
    }

    private static func firstShotFollowUpSmokeFailures(
        for manifest: AmigaProgramFamilyManifest,
        prompt: String,
        source: String,
        semanticCache: inout SemanticValidationCache
    ) -> [String] {
        var patchCache = FollowUpPatchOutcomeCache()
        return firstShotFollowUpSmokeFailures(
            for: manifest,
            prompt: prompt,
            source: source,
            semanticCache: &semanticCache,
            patchCache: &patchCache
        )
    }

    private static func firstShotFollowUpSmokeFailures(
        for manifest: AmigaProgramFamilyManifest,
        prompt: String,
        source: String,
        semanticCache: inout SemanticValidationCache,
        patchCache: inout FollowUpPatchOutcomeCache
    ) -> [String] {
        let failures = followUpSmokeFailures(for: manifest, source: source, semanticCache: &semanticCache, patchCache: &patchCache) +
            rejectedFollowUpSmokeFailures(for: manifest, source: source, patchCache: &patchCache) +
            recoveryFollowUpSmokeFailures(for: manifest, source: source, patchCache: &patchCache) +
            ignoredFollowUpSmokeFailures(for: manifest, source: source, patchCache: &patchCache)
        return failures.map {
            "\(manifest.id): first-shot prompt follow-up smoke failure for prompt \(prompt): \($0)"
        }
    }

    static func representativeRoutedFirstShotConversationFailures(
        for manifest: AmigaProgramFamilyManifest
    ) -> [String] {
        do {
            let eventFailures = try representativeRoutedConversationEventFailures(for: manifest)
            if !eventFailures.isEmpty {
                return contextualRepresentativeRoutedFirstShotConversationFailures(
                    manifestID: manifest.id,
                    failures: eventFailures
                )
            }
            return []
        } catch AmigaProgramPatchError.verificationFailed(let failures) {
            return contextualRepresentativeRoutedFirstShotConversationFailures(
                manifestID: manifest.id,
                failures: failures
            )
        } catch {
            return [
                "\(manifest.id): representative routed first-shot conversation failed: \(error.localizedDescription)"
            ]
        }
    }

    static func representativeRoutedConversationEventFailures(
        for manifest: AmigaProgramFamilyManifest
    ) throws -> [String] {
        try representativeRoutedFollowUpConversationEventFailures(for: manifest) +
            representativeRoutedRecoveryConversationEventFailures(for: manifest)
    }

    static func representativeRoutedFollowUpConversationEventFailures(
        for manifest: AmigaProgramFamilyManifest
    ) throws -> [String] {
        let declarationFailures = representativeRoutedDeclarationFailures(for: manifest)
        if !declarationFailures.isEmpty {
            throw AmigaProgramPatchError.verificationFailed(declarationFailures)
        }

        return try manifest.representativeRoutedFirstShotPromptExamples.flatMap { firstShotPrompt in
            try manifest.representativeRoutedFollowUpSmokeChains.flatMap { followUpChain in
                let match = try routedFirstShotMatch(for: manifest, prompt: firstShotPrompt)
                guard let initialModel = AmigaSourceIndexer.index(match.source).model else {
                    throw AmigaProgramPatchError.verificationFailed([
                        "\(manifest.id): first-shot prompt did not embed an AmigaProgramModel for prompt: \(firstShotPrompt)"
                    ])
                }
                let events = try routedFirstShotFollowUpSmokeChainEvents(
                    for: manifest,
                    firstShotPrompts: [firstShotPrompt],
                    followUpChains: [followUpChain]
                )
                return followUpConversationEventInvariantFailures(
                    events: events,
                    manifestID: manifest.id,
                    firstShotPrompt: firstShotPrompt,
                    followUpChain: followUpChain,
                    initialSource: match.source,
                    initialModel: initialModel
                )
            }
        }
    }

    static func followUpConversationEventInvariantFailures(
        events: [RoutedFirstShotFollowUpEvent],
        manifestID: String,
        firstShotPrompt: String,
        followUpChain: [String],
        initialSource: String? = nil,
        initialModel: AmigaProgramModel? = nil
    ) -> [String] {
        var failures: [String] = []
        guard events.count == followUpChain.count else {
            return [
                "\(manifestID): representative follow-up event chain produced \(events.count) events for \(followUpChain.count) prompts: \(followUpChain.joined(separator: " -> "))"
            ]
        }

        if let firstEvent = events.first {
            if let initialSource,
               firstEvent.sourceBefore != initialSource {
                failures.append("\(manifestID): representative follow-up did not start from routed first-shot source: \(firstEvent.followUpPrompt)")
            }
            if let initialModel,
               firstEvent.modelBefore != initialModel {
                failures.append("\(manifestID): representative follow-up did not start from routed first-shot model: \(firstEvent.followUpPrompt)")
            }
        }

        for (index, event) in events.enumerated() {
            let expectedPrompt = followUpChain[index]
            failures.append(contentsOf: eventEmbeddedModelFailures(
                event,
                manifestID: manifestID,
                context: "representative follow-up event \(index + 1)",
                prompt: expectedPrompt
            ))
            if event.firstShotPrompt != firstShotPrompt {
                failures.append("\(manifestID): representative follow-up event \(index + 1) has first-shot prompt \(event.firstShotPrompt) instead of \(firstShotPrompt).")
            }
            if event.followUpPrompt != expectedPrompt {
                failures.append("\(manifestID): representative follow-up event \(index + 1) has follow-up prompt \(event.followUpPrompt) instead of \(expectedPrompt).")
            }
            guard case .patched = event.outcome else {
                failures.append("\(manifestID): representative follow-up event \(index + 1) rejected instead of patching: \(expectedPrompt)")
                continue
            }
            if event.sourceBefore == event.sourceAfter {
                failures.append("\(manifestID): representative follow-up patched event did not change source: \(expectedPrompt)")
            }
            if index > 0 {
                let previous = events[index - 1]
                if event.sourceBefore != previous.sourceAfter {
                    failures.append("\(manifestID): representative follow-up resumed from a different source after \(previous.followUpPrompt): \(expectedPrompt)")
                }
                if event.modelBefore != previous.modelAfter {
                    failures.append("\(manifestID): representative follow-up resumed from a different model after \(previous.followUpPrompt): \(expectedPrompt)")
                }
            }
        }

        return failures
    }

    static func representativeRoutedRecoveryConversationEventFailures(
        for manifest: AmigaProgramFamilyManifest
    ) throws -> [String] {
        let declarationFailures = representativeRoutedDeclarationFailures(for: manifest)
        if !declarationFailures.isEmpty {
            throw AmigaProgramPatchError.verificationFailed(declarationFailures)
        }

        return try manifest.representativeRoutedFirstShotPromptExamples.flatMap { firstShotPrompt in
            try manifest.representativeRoutedRecoveryFollowUpSmokeChains.flatMap { recoveryChain in
                let match = try routedFirstShotMatch(for: manifest, prompt: firstShotPrompt)
                guard let initialModel = AmigaSourceIndexer.index(match.source).model else {
                    throw AmigaProgramPatchError.verificationFailed([
                        "\(manifest.id): first-shot prompt did not embed an AmigaProgramModel for prompt: \(firstShotPrompt)"
                    ])
                }
                let events = try routedFirstShotRecoveryFollowUpSmokeChainEvents(
                    for: manifest,
                    firstShotPrompts: [firstShotPrompt],
                    recoveryChains: [recoveryChain]
                )
                return recoveryConversationEventInvariantFailures(
                    events: events,
                    manifestID: manifest.id,
                    firstShotPrompt: firstShotPrompt,
                    recoveryChain: recoveryChain,
                    initialSource: match.source,
                    initialModel: initialModel
                )
            }
        }
    }

    static func recoveryConversationEventInvariantFailures(
        events: [RoutedFirstShotFollowUpEvent],
        manifestID: String,
        firstShotPrompt: String,
        recoveryChain: [String],
        initialSource: String? = nil,
        initialModel: AmigaProgramModel? = nil
    ) -> [String] {
        var failures: [String] = []
        guard recoveryChain.count >= 3 else {
            return [
                "\(manifestID): representative recovery event chain must contain accepted setup, rejected follow-up, and recovery follow-up."
            ]
        }
        guard events.count == recoveryChain.count else {
            return [
                "\(manifestID): representative recovery event chain produced \(events.count) events for \(recoveryChain.count) prompts: \(recoveryChain.joined(separator: " -> "))"
            ]
        }

        if let firstEvent = events.first {
            if let initialSource,
               firstEvent.sourceBefore != initialSource {
                failures.append("\(manifestID): representative recovery did not start from routed first-shot source: \(firstEvent.followUpPrompt)")
            }
            if let initialModel,
               firstEvent.modelBefore != initialModel {
                failures.append("\(manifestID): representative recovery did not start from routed first-shot model: \(firstEvent.followUpPrompt)")
            }
        }

        let rejectedIndex = recoveryChain.count - 2
        let recoveryIndex = recoveryChain.count - 1
        for (index, event) in events.enumerated() {
            let expectedPrompt = recoveryChain[index]
            failures.append(contentsOf: eventEmbeddedModelFailures(
                event,
                manifestID: manifestID,
                context: "representative recovery event \(index + 1)",
                prompt: expectedPrompt
            ))
            if event.firstShotPrompt != firstShotPrompt {
                failures.append("\(manifestID): representative recovery event \(index + 1) has first-shot prompt \(event.firstShotPrompt) instead of \(firstShotPrompt).")
            }
            if event.followUpPrompt != expectedPrompt {
                failures.append("\(manifestID): representative recovery event \(index + 1) has follow-up prompt \(event.followUpPrompt) instead of \(expectedPrompt).")
            }
            if index == rejectedIndex {
                guard case .rejected(let reasons) = event.outcome else {
                    failures.append("\(manifestID): representative recovery event \(index + 1) patched instead of rejecting: \(expectedPrompt)")
                    continue
                }
                let concreteReasons = reasons
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
                if concreteReasons.isEmpty {
                    failures.append("\(manifestID): representative recovery rejected event has no concrete rejection reason: \(expectedPrompt)")
                }
                if event.sourceBefore != event.sourceAfter {
                    failures.append("\(manifestID): representative recovery rejected event mutated source: \(expectedPrompt)")
                }
                if event.modelBefore != event.modelAfter {
                    failures.append("\(manifestID): representative recovery rejected event mutated model: \(expectedPrompt)")
                }
            } else {
                guard case .patched = event.outcome else {
                    failures.append("\(manifestID): representative recovery event \(index + 1) rejected instead of patching: \(expectedPrompt)")
                    continue
                }
                if event.sourceBefore == event.sourceAfter {
                    failures.append("\(manifestID): representative recovery patched event did not change source: \(expectedPrompt)")
                }
            }
        }

        if events.indices.contains(rejectedIndex),
           events.indices.contains(recoveryIndex),
           events[recoveryIndex].sourceBefore != events[rejectedIndex].sourceAfter {
            failures.append("\(manifestID): representative recovery resumed from a different source after rejection: \(recoveryChain[recoveryIndex])")
        }
        if events.indices.contains(rejectedIndex),
           events.indices.contains(recoveryIndex),
           events[recoveryIndex].modelBefore != events[rejectedIndex].modelAfter {
            failures.append("\(manifestID): representative recovery resumed from a different model after rejection: \(recoveryChain[recoveryIndex])")
        }

        return failures
    }

    private static func eventEmbeddedModelFailures(
        _ event: RoutedFirstShotFollowUpEvent,
        manifestID: String,
        context: String,
        prompt: String
    ) -> [String] {
        var failures: [String] = []
        if let sourceBeforeModel = AmigaSourceIndexer.index(event.sourceBefore).model {
            if sourceBeforeModel != event.modelBefore {
                failures.append("\(manifestID): \(context) source-before embedded model does not match modelBefore: \(prompt)")
            }
        } else {
            failures.append("\(manifestID): \(context) source-before does not embed an AmigaProgramModel: \(prompt)")
        }
        if let sourceAfterModel = AmigaSourceIndexer.index(event.sourceAfter).model {
            if sourceAfterModel != event.modelAfter {
                failures.append("\(manifestID): \(context) source-after embedded model does not match modelAfter: \(prompt)")
            }
        } else {
            failures.append("\(manifestID): \(context) source-after does not embed an AmigaProgramModel: \(prompt)")
        }
        return failures
    }

    static func contextualRepresentativeRoutedFirstShotConversationFailures(
        manifestID: String,
        failures: [String]
    ) -> [String] {
        failures.map { failure in
            let detailPrefix = "\(manifestID): "
            let detail = failure.hasPrefix(detailPrefix)
                ? String(failure.dropFirst(detailPrefix.count))
                : failure
            return "\(manifestID): representative routed first-shot conversation failure: \(detail)"
        }
    }

    private static func blankPromptFailures(
        in prompts: [String],
        manifestID: String,
        fieldName: String
    ) -> [String] {
        prompts.enumerated().compactMap { index, prompt in
            guard normalizedPromptKey(prompt).isEmpty else {
                return nil
            }
            return "\(manifestID): blank \(fieldName) at index \(index + 1)."
        }
    }

    private static func blankChainPromptFailures(
        in prompts: [String],
        manifestID: String,
        chainName: String
    ) -> [String] {
        prompts.enumerated().compactMap { index, prompt in
            guard normalizedPromptKey(prompt).isEmpty else {
                return nil
            }
            return "\(manifestID): \(chainName) has blank prompt at step \(index + 1)."
        }
    }

    private static func trimmedPromptFailures(
        in prompts: [String],
        manifestID: String,
        fieldName: String
    ) -> [String] {
        prompts.enumerated().compactMap { index, prompt in
            guard !normalizedPromptKey(prompt).isEmpty,
                  prompt != prompt.trimmingCharacters(in: .whitespacesAndNewlines) else {
                return nil
            }
            return "\(manifestID): \(fieldName) at index \(index + 1) has leading or trailing whitespace."
        }
    }

    private static func trimmedChainPromptFailures(
        in prompts: [String],
        manifestID: String,
        chainName: String
    ) -> [String] {
        prompts.enumerated().compactMap { index, prompt in
            guard !normalizedPromptKey(prompt).isEmpty,
                  prompt != prompt.trimmingCharacters(in: .whitespacesAndNewlines) else {
                return nil
            }
            return "\(manifestID): \(chainName) prompt at step \(index + 1) has leading or trailing whitespace."
        }
    }

    private static func registryFailures(for manifests: [AmigaProgramFamilyManifest]) -> [String] {
        var failures: [String] = []
        if manifests.isEmpty {
            failures.append("registry: missing registered program families.")
        }
        failures.append(contentsOf: duplicateManifestFieldFailures(
            in: manifests.map { ($0.id, $0.id) },
            fieldName: "family ids"
        ))
        failures.append(contentsOf: duplicateManifestFieldFailures(
            in: manifests.map { ($0.name, $0.name) },
            fieldName: "family names"
        ))
        failures.append(contentsOf: overlappingAcceptedFirstShotFailures(for: manifests))
        return failures
    }

    private static func duplicateManifestFieldFailures(
        in values: [(displayValue: String, identity: String)],
        fieldName: String
    ) -> [String] {
        var firstByKey: [String: String] = [:]
        var reportedKeys: Set<String> = []
        var failures: [String] = []
        for value in values {
            let key = normalizedPromptKey(value.identity)
            guard !key.isEmpty else {
                continue
            }
            if let first = firstByKey[key] {
                guard reportedKeys.insert(key).inserted else {
                    continue
                }
                failures.append("registry: duplicate \(fieldName): \(first)")
            } else {
                firstByKey[key] = value.displayValue
            }
        }
        return failures
    }

    private static func overlappingAcceptedFirstShotFailures(for manifests: [AmigaProgramFamilyManifest]) -> [String] {
        var firstByKey: [String: (prompt: String, manifestID: String)] = [:]
        var reportedKeys: Set<String> = []
        var failures: [String] = []
        for manifest in manifests {
            for prompt in manifest.firstShotPromptExamples {
                let key = normalizedPromptKey(prompt)
                guard !key.isEmpty else {
                    continue
                }
                if let first = firstByKey[key] {
                    guard reportedKeys.insert(key).inserted else {
                        continue
                    }
                    failures.append("registry: first-shot prompt example declared by multiple families: \(first.prompt) (\(first.manifestID), \(manifest.id))")
                } else {
                    firstByKey[key] = (prompt, manifest.id)
                }
            }
        }
        return failures
    }

    static func verifiedSource(for manifest: AmigaProgramFamilyManifest) throws -> String {
        switch manifest.id {
        case AmigaProgramFamilyRegistry.doubleBufferedBitplane.id:
            return try AmigaProgramTemplate.verifiedDoubleBufferedBitplaneSource(frontColor: "red", backColor: "green")
        case AmigaProgramFamilyRegistry.modPlayerControls.id:
            return try AmigaProgramTemplate.verifiedModPlayerControlsSource()
        default:
            throw AmigaProgramPatchError.verificationFailed(["No verified source provider registered for \(manifest.id)."])
        }
    }

    private static func duplicateRawValueFailures<Value: RawRepresentable>(
        in values: [Value],
        manifestID: String,
        fieldName: String
    ) -> [String] where Value.RawValue == String {
        duplicateValues(in: values.map(\.rawValue)).map {
            "\(manifestID): duplicate \(fieldName): \($0)"
        }
    }

    private static func duplicateValues(in values: [String]) -> [String] {
        var firstByKey: [String: String] = [:]
        var reportedKeys: Set<String> = []
        var duplicates: [String] = []
        for value in values {
            let key = Self.normalizedPromptKey(value)
            guard !key.isEmpty else {
                continue
            }
            if let first = firstByKey[key] {
                guard reportedKeys.insert(key).inserted else {
                    continue
                }
                duplicates.append(first)
            } else {
                firstByKey[key] = value
            }
        }
        return duplicates
    }

    private static func duplicateChainFailures(
        in chains: [[String]],
        manifestID: String,
        fieldName: String
    ) -> [String] {
        duplicateChains(in: chains).map {
            "\(manifestID): duplicate \(fieldName): \($0.joined(separator: " -> "))"
        }
    }

    private static func duplicateChains(in chains: [[String]]) -> [[String]] {
        var firstByKey: [String: [String]] = [:]
        var reportedKeys: Set<String> = []
        var duplicates: [[String]] = []
        for chain in chains {
            let key = normalizedChainKey(chain)
            guard !key.isEmpty else {
                continue
            }
            if let first = firstByKey[key] {
                guard reportedKeys.insert(key).inserted else {
                    continue
                }
                duplicates.append(first)
            } else {
                firstByKey[key] = chain
            }
        }
        return duplicates
    }

    private static func duplicatePromptFailures(
        in prompts: [String],
        manifestID: String,
        fieldName: String
    ) -> [String] {
        duplicatePrompts(in: prompts).map {
            "\(manifestID): duplicate \(fieldName): \($0)"
        }
    }

    private static func duplicatePrompts(in prompts: [String]) -> [String] {
        duplicateValues(in: prompts)
    }

    private static func overlappingPrompts(_ left: [String], _ right: [String]) -> [String] {
        let rejected = Set(right.map(Self.normalizedPromptKey))
        var seen: Set<String> = []
        var overlaps: [String] = []
        for prompt in left {
            let key = Self.normalizedPromptKey(prompt)
            guard rejected.contains(key), seen.insert(key).inserted else {
                continue
            }
            overlaps.append(prompt)
        }
        return overlaps
    }

    private static func normalizedPromptKey(_ prompt: String) -> String {
        prompt
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }

    private static func normalizedChainKey(_ chain: [String]) -> String {
        chain
            .map(Self.normalizedPromptKey)
            .filter { !$0.isEmpty }
            .joined(separator: "\u{1f}")
    }

    static func followUpSmokeSources(
        for manifest: AmigaProgramFamilyManifest,
        source startingSource: String? = nil
    ) throws -> [(prompt: String, source: String, model: AmigaProgramModel)] {
        try followUpSmokeSources(
            for: manifest,
            prompts: manifest.requiredFollowUpSmokePrompts,
            source: startingSource
        )
    }

    static func followUpSmokeChainSources(
        for manifest: AmigaProgramFamilyManifest,
        source startingSource: String? = nil
    ) throws -> [[(prompt: String, source: String, model: AmigaProgramModel)]] {
        try manifest.requiredFollowUpSmokeChains.map { prompts in
            try followUpSmokeSources(for: manifest, prompts: prompts, source: startingSource)
        }
    }

    static func acceptedFollowUpSmokeSources(
        for manifest: AmigaProgramFamilyManifest,
        source startingSource: String? = nil
    ) throws -> [(prompt: String, source: String, model: AmigaProgramModel)] {
        let requiredPromptArtifacts = try followUpSmokeSources(for: manifest, source: startingSource)
        let chainArtifacts = try followUpSmokeChainSources(for: manifest, source: startingSource).flatMap { $0 }
        let rejectedChainSetupArtifacts = try manifest.requiredRejectedFollowUpSmokeChains.flatMap { prompts in
            try followUpSmokeSources(
                for: manifest,
                prompts: Array(prompts.dropLast()),
                source: startingSource
            )
        }
        let recoveryChainArtifacts = try manifest.requiredRecoveryFollowUpSmokeChains.flatMap { prompts in
            try recoveryFollowUpSmokeSources(
                for: manifest,
                prompts: prompts,
                source: startingSource
            )
        }
        return requiredPromptArtifacts + chainArtifacts + rejectedChainSetupArtifacts + recoveryChainArtifacts
    }

    static func routedFirstShotAcceptedFollowUpSmokeSources(
        for manifest: AmigaProgramFamilyManifest
    ) throws -> [RoutedFirstShotFollowUpArtifact] {
        try manifest.firstShotPromptExamples.flatMap { firstShotPrompt in
            let match = try routedFirstShotMatch(for: manifest, prompt: firstShotPrompt)
            return try acceptedFollowUpSmokeSources(
                for: manifest,
                source: match.source
            ).map { artifact in
                RoutedFirstShotFollowUpArtifact(
                    firstShotPrompt: firstShotPrompt,
                    followUpPrompt: artifact.prompt,
                    source: artifact.source,
                    model: artifact.model
                )
            }
        }
    }

    static func routedFirstShotFollowUpSmokeChainSources(
        for manifest: AmigaProgramFamilyManifest,
        firstShotPrompts selectedFirstShotPrompts: [String],
        followUpChains selectedFollowUpChains: [[String]]
    ) throws -> [RoutedFirstShotFollowUpArtifact] {
        try assertDeclaredFirstShotPrompts(
            selectedFirstShotPrompts,
            manifest: manifest,
            context: "representative routed first-shot prompt"
        )
        try assertDeclaredChains(
            selectedFollowUpChains,
            declaredChains: manifest.requiredFollowUpSmokeChains,
            manifest: manifest,
            context: "representative routed first-shot follow-up chain"
        )

        return try selectedFirstShotPrompts.flatMap { firstShotPrompt in
            let match = try routedFirstShotMatch(for: manifest, prompt: firstShotPrompt)
            return try selectedFollowUpChains.flatMap { followUpChain in
                try followUpSmokeSources(
                    for: manifest,
                    prompts: followUpChain,
                    source: match.source
                ).map { artifact in
                    RoutedFirstShotFollowUpArtifact(
                        firstShotPrompt: firstShotPrompt,
                        followUpPrompt: artifact.prompt,
                        source: artifact.source,
                        model: artifact.model
                    )
                }
            }
        }
    }

    static func routedFirstShotFollowUpSmokeChainEvents(
        for manifest: AmigaProgramFamilyManifest,
        firstShotPrompts selectedFirstShotPrompts: [String],
        followUpChains selectedFollowUpChains: [[String]]
    ) throws -> [RoutedFirstShotFollowUpEvent] {
        try assertDeclaredFirstShotPrompts(
            selectedFirstShotPrompts,
            manifest: manifest,
            context: "representative routed first-shot prompt"
        )
        try assertDeclaredChains(
            selectedFollowUpChains,
            declaredChains: manifest.requiredFollowUpSmokeChains,
            manifest: manifest,
            context: "representative routed first-shot follow-up chain"
        )

        return try selectedFirstShotPrompts.flatMap { firstShotPrompt in
            let match = try routedFirstShotMatch(for: manifest, prompt: firstShotPrompt)
            return try selectedFollowUpChains.flatMap { followUpChain in
                try followUpSmokeEvents(
                    for: manifest,
                    firstShotPrompt: firstShotPrompt,
                    prompts: followUpChain,
                    source: match.source
                )
            }
        }
    }

    static func routedFirstShotRecoveryFollowUpSmokeChainSources(
        for manifest: AmigaProgramFamilyManifest,
        firstShotPrompts selectedFirstShotPrompts: [String],
        recoveryChains selectedRecoveryChains: [[String]]
    ) throws -> [RoutedFirstShotFollowUpArtifact] {
        try assertDeclaredFirstShotPrompts(
            selectedFirstShotPrompts,
            manifest: manifest,
            context: "representative routed first-shot prompt"
        )
        try assertDeclaredChains(
            selectedRecoveryChains,
            declaredChains: manifest.requiredRecoveryFollowUpSmokeChains,
            manifest: manifest,
            context: "representative routed first-shot recovery chain"
        )

        return try selectedFirstShotPrompts.flatMap { firstShotPrompt in
            let match = try routedFirstShotMatch(for: manifest, prompt: firstShotPrompt)
            return try selectedRecoveryChains.flatMap { recoveryChain in
                try recoveryFollowUpSmokeSources(
                    for: manifest,
                    prompts: recoveryChain,
                    source: match.source
                ).map { artifact in
                    RoutedFirstShotFollowUpArtifact(
                        firstShotPrompt: firstShotPrompt,
                        followUpPrompt: artifact.prompt,
                        source: artifact.source,
                        model: artifact.model
                    )
                }
            }
        }
    }

    static func routedFirstShotRecoveryFollowUpSmokeChainEvents(
        for manifest: AmigaProgramFamilyManifest,
        firstShotPrompts selectedFirstShotPrompts: [String],
        recoveryChains selectedRecoveryChains: [[String]]
    ) throws -> [RoutedFirstShotFollowUpEvent] {
        try assertDeclaredFirstShotPrompts(
            selectedFirstShotPrompts,
            manifest: manifest,
            context: "representative routed first-shot prompt"
        )
        try assertDeclaredChains(
            selectedRecoveryChains,
            declaredChains: manifest.requiredRecoveryFollowUpSmokeChains,
            manifest: manifest,
            context: "representative routed first-shot recovery chain"
        )

        return try selectedFirstShotPrompts.flatMap { firstShotPrompt in
            let match = try routedFirstShotMatch(for: manifest, prompt: firstShotPrompt)
            return try selectedRecoveryChains.flatMap { recoveryChain in
                try recoveryFollowUpSmokeEvents(
                    for: manifest,
                    firstShotPrompt: firstShotPrompt,
                    prompts: recoveryChain,
                    source: match.source
                )
            }
        }
    }

    static func representativeRoutedFirstShotFollowUpArtifacts(
        for manifest: AmigaProgramFamilyManifest
    ) throws -> [RoutedFirstShotFollowUpArtifact] {
        try representativeRoutedFirstShotConversationArtifactChains(for: manifest).map { chain in
            try finalRepresentativeArtifact(
                from: chain,
                manifest: manifest,
                context: "representative routed conversation chain"
            )
        }
    }

    static func representativeRoutedFirstShotConversationArtifacts(
        for manifest: AmigaProgramFamilyManifest
    ) throws -> [RoutedFirstShotFollowUpArtifact] {
        try representativeRoutedFirstShotConversationArtifactChains(for: manifest).flatMap { $0 }
    }

    private static func representativeRoutedFirstShotConversationArtifactChains(
        for manifest: AmigaProgramFamilyManifest
    ) throws -> [[RoutedFirstShotFollowUpArtifact]] {
        let firstShotPrompts = manifest.representativeRoutedFirstShotPromptExamples
        let declarationFailures = representativeRoutedDeclarationFailures(for: manifest)
        if !declarationFailures.isEmpty {
            throw AmigaProgramPatchError.verificationFailed(declarationFailures)
        }

        let followUpArtifacts = try manifest.representativeRoutedFollowUpSmokeChains.map { chain in
            try routedFirstShotFollowUpSmokeChainSources(
                for: manifest,
                firstShotPrompts: firstShotPrompts,
                followUpChains: [chain]
            )
        }
        let recoveryArtifacts = try manifest.representativeRoutedRecoveryFollowUpSmokeChains.map { chain in
            try routedFirstShotRecoveryFollowUpSmokeChainSources(
                for: manifest,
                firstShotPrompts: firstShotPrompts,
                recoveryChains: [chain]
            )
        }
        return followUpArtifacts + recoveryArtifacts
    }

    private static func representativeRoutedDeclarationFailures(
        for manifest: AmigaProgramFamilyManifest
    ) -> [String] {
        var declarationFailures: [String] = []
        if manifest.representativeRoutedFirstShotPromptExamples.isEmpty {
            declarationFailures.append("\(manifest.id): missing representative routed first-shot prompt examples.")
        }
        if manifest.representativeRoutedFollowUpSmokeChains.isEmpty {
            declarationFailures.append("\(manifest.id): missing representative routed follow-up smoke chains.")
        }
        if !manifest.requiredRecoveryFollowUpSmokeChains.isEmpty,
           manifest.representativeRoutedRecoveryFollowUpSmokeChains.isEmpty {
            declarationFailures.append("\(manifest.id): missing representative routed recovery follow-up smoke chains.")
        }
        return declarationFailures
    }

    private static func finalRepresentativeArtifact(
        from artifacts: [RoutedFirstShotFollowUpArtifact],
        manifest: AmigaProgramFamilyManifest,
        context: String
    ) throws -> RoutedFirstShotFollowUpArtifact {
        guard let finalArtifact = artifacts.last else {
            throw AmigaProgramPatchError.verificationFailed([
                "\(manifest.id): \(context) produced no artifacts."
            ])
        }
        return finalArtifact
    }

    private static func assertDeclaredFirstShotPrompts(
        _ selectedFirstShotPrompts: [String],
        manifest: AmigaProgramFamilyManifest,
        context: String
    ) throws {
        let declaredFirstShotPromptKeys = Set(manifest.firstShotPromptExamples.map(Self.normalizedPromptKey))
        let undeclaredFirstShotPrompts = selectedFirstShotPrompts.filter {
            !declaredFirstShotPromptKeys.contains(Self.normalizedPromptKey($0))
        }
        guard undeclaredFirstShotPrompts.isEmpty else {
            throw AmigaProgramPatchError.verificationFailed(
                undeclaredFirstShotPrompts.map {
                    "\(manifest.id): \(context) is not declared by the manifest: \($0)"
                }
            )
        }
    }

    private static func assertDeclaredChains(
        _ selectedChains: [[String]],
        declaredChains: [[String]],
        manifest: AmigaProgramFamilyManifest,
        context: String
    ) throws {
        let declaredChainKeys = Set(declaredChains.map(Self.normalizedChainKey))
        let undeclaredChains = selectedChains.filter {
            !declaredChainKeys.contains(Self.normalizedChainKey($0))
        }
        guard undeclaredChains.isEmpty else {
            throw AmigaProgramPatchError.verificationFailed(
                undeclaredChains.map {
                    "\(manifest.id): \(context) is not declared by the manifest: \($0.joined(separator: " -> "))"
                }
            )
        }
    }

    private static func routedFirstShotMatch(
        for manifest: AmigaProgramFamilyManifest,
        prompt firstShotPrompt: String
    ) throws -> AssistantPromptTemplateMatch {
        guard let match = AssistantPromptTemplate.match(for: firstShotPrompt) else {
            throw AmigaProgramPatchError.verificationFailed([
                "\(manifest.id): first-shot prompt did not route: \(firstShotPrompt)"
            ])
        }
        guard match.id == manifest.id else {
            throw AmigaProgramPatchError.verificationFailed([
                "\(manifest.id): first-shot prompt routed to \(match.id) instead of manifest id for prompt: \(firstShotPrompt)"
            ])
        }
        guard let matchModel = AmigaSourceIndexer.index(match.source).model else {
            throw AmigaProgramPatchError.verificationFailed([
                "\(manifest.id): first-shot prompt did not embed an AmigaProgramModel for prompt: \(firstShotPrompt)"
            ])
        }
        guard matchModel.id == manifest.id else {
            throw AmigaProgramPatchError.verificationFailed([
                "\(manifest.id): first-shot prompt embedded model id \(matchModel.id) instead of manifest id for prompt: \(firstShotPrompt)"
            ])
        }
        guard matchModel.kind == manifest.kind else {
            throw AmigaProgramPatchError.verificationFailed([
                "\(manifest.id): first-shot prompt embedded model kind \(matchModel.kind.rawValue) instead of \(manifest.kind.rawValue) for prompt: \(firstShotPrompt)"
            ])
        }
        return match
    }

    private static func followUpSmokeSources(
        for manifest: AmigaProgramFamilyManifest,
        prompts: [String],
        source startingSource: String? = nil
    ) throws -> [(prompt: String, source: String, model: AmigaProgramModel)] {
        let source: String
        if let startingSource {
            source = startingSource
        } else {
            source = try verifiedSource(for: manifest)
        }

        var artifacts: [(prompt: String, source: String, model: AmigaProgramModel)] = []
        var currentSource = source

        for prompt in prompts {
            switch AmigaProgramFollowUpPlanner.patchOutcome(prompt: prompt, source: currentSource) {
            case .notRecognized:
                throw AmigaProgramPatchError.verificationFailed([
                    "\(manifest.id): required follow-up smoke prompt was not recognized: \(prompt)"
                ])
            case .rejected(let reasons):
                throw AmigaProgramPatchError.verificationFailed(
                    unexpectedRejectionFailures(
                        reasons,
                        manifest: manifest,
                        context: "required follow-up smoke prompt",
                        prompt: prompt
                    )
                )
            case .patched(let result):
                let failures = acceptedFollowUpArtifactFailures(
                    manifest: manifest,
                    prompt: prompt,
                    previousSource: currentSource,
                    result: result
                )
                if !failures.isEmpty {
                    throw AmigaProgramPatchError.verificationFailed(failures)
                }
                artifacts.append((prompt: prompt, source: result.source, model: result.model))
                currentSource = result.source
            }
        }

        return artifacts
    }

    private static func followUpSmokeSources(
        for manifest: AmigaProgramFamilyManifest,
        prompts: [String],
        source startingSource: String? = nil,
        patchCache: inout FollowUpPatchOutcomeCache
    ) throws -> [(prompt: String, source: String, model: AmigaProgramModel)] {
        let source: String
        if let startingSource {
            source = startingSource
        } else {
            source = try verifiedSource(for: manifest)
        }

        var artifacts: [(prompt: String, source: String, model: AmigaProgramModel)] = []
        var currentSource = source

        for prompt in prompts {
            switch patchCache.outcome(prompt: prompt, source: currentSource) {
            case .notRecognized:
                throw AmigaProgramPatchError.verificationFailed([
                    "\(manifest.id): required follow-up smoke prompt was not recognized: \(prompt)"
                ])
            case .rejected(let reasons):
                throw AmigaProgramPatchError.verificationFailed(
                    unexpectedRejectionFailures(
                        reasons,
                        manifest: manifest,
                        context: "required follow-up smoke prompt",
                        prompt: prompt
                    )
                )
            case .patched(let result):
                let failures = acceptedFollowUpArtifactFailures(
                    manifest: manifest,
                    prompt: prompt,
                    previousSource: currentSource,
                    result: result
                )
                if !failures.isEmpty {
                    throw AmigaProgramPatchError.verificationFailed(failures)
                }
                artifacts.append((prompt: prompt, source: result.source, model: result.model))
                currentSource = result.source
            }
        }

        return artifacts
    }

    private static func modelInSource(
        _ source: String,
        manifest: AmigaProgramFamilyManifest,
        context: String,
        prompt: String
    ) throws -> AmigaProgramModel {
        guard let model = AmigaSourceIndexer.index(source).model else {
            throw AmigaProgramPatchError.verificationFailed([
                "\(manifest.id): \(context) source does not embed an AmigaProgramModel for prompt: \(prompt)"
            ])
        }
        guard model.id == manifest.id else {
            throw AmigaProgramPatchError.verificationFailed([
                "\(manifest.id): \(context) source embedded model id \(model.id) instead of manifest id for prompt: \(prompt)"
            ])
        }
        return model
    }

    private static func followUpSmokeEvents(
        for manifest: AmigaProgramFamilyManifest,
        firstShotPrompt: String,
        prompts: [String],
        source startingSource: String? = nil
    ) throws -> [RoutedFirstShotFollowUpEvent] {
        var currentSource = try startingSource ?? verifiedSource(for: manifest)
        var events: [RoutedFirstShotFollowUpEvent] = []

        for prompt in prompts {
            let modelBefore = try modelInSource(
                currentSource,
                manifest: manifest,
                context: "required follow-up smoke prompt",
                prompt: prompt
            )
            switch AmigaProgramFollowUpPlanner.patchOutcome(prompt: prompt, source: currentSource) {
            case .notRecognized:
                throw AmigaProgramPatchError.verificationFailed([
                    "\(manifest.id): required follow-up smoke prompt was not recognized: \(prompt)"
                ])
            case .rejected(let reasons):
                throw AmigaProgramPatchError.verificationFailed(
                    unexpectedRejectionFailures(
                        reasons,
                        manifest: manifest,
                        context: "required follow-up smoke prompt",
                        prompt: prompt
                    )
                )
            case .patched(let result):
                let failures = acceptedFollowUpArtifactFailures(
                    manifest: manifest,
                    prompt: prompt,
                    previousSource: currentSource,
                    result: result
                )
                if !failures.isEmpty {
                    throw AmigaProgramPatchError.verificationFailed(failures)
                }
                events.append(RoutedFirstShotFollowUpEvent(
                    firstShotPrompt: firstShotPrompt,
                    followUpPrompt: prompt,
                    sourceBefore: currentSource,
                    sourceAfter: result.source,
                    modelBefore: modelBefore,
                    modelAfter: result.model,
                    outcome: .patched
                ))
                currentSource = result.source
            }
        }

        return events
    }

    private static func recoveryFollowUpSmokeEvents(
        for manifest: AmigaProgramFamilyManifest,
        firstShotPrompt: String,
        prompts: [String],
        source startingSource: String? = nil
    ) throws -> [RoutedFirstShotFollowUpEvent] {
        guard prompts.count >= 3 else {
            throw AmigaProgramPatchError.verificationFailed([
                "\(manifest.id): required recovery follow-up smoke chain must contain accepted setup, rejected follow-up, and recovery follow-up."
            ])
        }

        let setupPrompts = Array(prompts.dropLast(2))
        let rejectedPrompt = prompts[prompts.count - 2]
        let recoveryPrompt = prompts[prompts.count - 1]
        var currentSource = try startingSource ?? verifiedSource(for: manifest)
        var events: [RoutedFirstShotFollowUpEvent] = []

        for prompt in setupPrompts {
            let modelBefore = try modelInSource(currentSource, manifest: manifest, context: "required recovery follow-up smoke chain setup prompt", prompt: prompt)
            switch AmigaProgramFollowUpPlanner.patchOutcome(prompt: prompt, source: currentSource) {
            case .notRecognized:
                throw AmigaProgramPatchError.verificationFailed([
                    "\(manifest.id): required follow-up smoke prompt was not recognized: \(prompt)"
                ])
            case .rejected(let reasons):
                throw AmigaProgramPatchError.verificationFailed(
                    unexpectedRejectionFailures(
                        reasons,
                        manifest: manifest,
                        context: "required follow-up smoke prompt",
                        prompt: prompt
                    )
                )
            case .patched(let result):
                let failures = acceptedFollowUpArtifactFailures(
                    manifest: manifest,
                    prompt: prompt,
                    previousSource: currentSource,
                    result: result
                )
                if !failures.isEmpty {
                    throw AmigaProgramPatchError.verificationFailed(failures)
                }
                events.append(RoutedFirstShotFollowUpEvent(
                    firstShotPrompt: firstShotPrompt,
                    followUpPrompt: prompt,
                    sourceBefore: currentSource,
                    sourceAfter: result.source,
                    modelBefore: modelBefore,
                    modelAfter: result.model,
                    outcome: .patched
                ))
                currentSource = result.source
            }
        }

        let modelBeforeRejection = try modelInSource(
            currentSource,
            manifest: manifest,
            context: "required recovery follow-up smoke chain rejected prompt",
            prompt: rejectedPrompt
        )
        switch AmigaProgramFollowUpPlanner.patchOutcome(prompt: rejectedPrompt, source: currentSource) {
        case .rejected(let reasons):
            let failures = concreteRejectionReasonFailures(
                reasons,
                manifest: manifest,
                context: "required recovery follow-up smoke chain rejected prompt",
                prompt: rejectedPrompt
            )
            if !failures.isEmpty {
                throw AmigaProgramPatchError.verificationFailed(failures)
            }
            events.append(RoutedFirstShotFollowUpEvent(
                firstShotPrompt: firstShotPrompt,
                followUpPrompt: rejectedPrompt,
                sourceBefore: currentSource,
                sourceAfter: currentSource,
                modelBefore: modelBeforeRejection,
                modelAfter: modelBeforeRejection,
                outcome: .rejected(reasons)
            ))
        case .notRecognized:
            throw AmigaProgramPatchError.verificationFailed([
                "\(manifest.id): required recovery follow-up smoke chain rejected prompt was not recognized after setup: \(rejectedPrompt)"
            ])
        case .patched:
            throw AmigaProgramPatchError.verificationFailed([
                "\(manifest.id): required recovery follow-up smoke chain rejected prompt patched instead of rejecting after setup: \(rejectedPrompt)"
            ])
        }

        switch AmigaProgramFollowUpPlanner.patchOutcome(prompt: recoveryPrompt, source: currentSource) {
        case .notRecognized:
            throw AmigaProgramPatchError.verificationFailed([
                "\(manifest.id): required recovery follow-up smoke chain recovery prompt was not recognized after rejection: \(recoveryPrompt)"
            ])
        case .rejected(let reasons):
            throw AmigaProgramPatchError.verificationFailed(
                unexpectedRejectionFailures(
                    reasons,
                    manifest: manifest,
                    context: "required recovery follow-up smoke chain recovery prompt",
                    prompt: recoveryPrompt
                )
            )
        case .patched(let result):
            let failures = acceptedFollowUpArtifactFailures(
                manifest: manifest,
                prompt: recoveryPrompt,
                previousSource: currentSource,
                result: result
            )
            if !failures.isEmpty {
                throw AmigaProgramPatchError.verificationFailed(failures)
            }
            events.append(RoutedFirstShotFollowUpEvent(
                firstShotPrompt: firstShotPrompt,
                followUpPrompt: recoveryPrompt,
                sourceBefore: currentSource,
                sourceAfter: result.source,
                modelBefore: modelBeforeRejection,
                modelAfter: result.model,
                outcome: .patched
            ))
        }

        return events
    }

    private static func recoveryFollowUpSmokeSources(
        for manifest: AmigaProgramFamilyManifest,
        prompts: [String],
        source startingSource: String? = nil
    ) throws -> [(prompt: String, source: String, model: AmigaProgramModel)] {
        var patchCache = FollowUpPatchOutcomeCache()
        return try recoveryFollowUpSmokeSources(
            for: manifest,
            prompts: prompts,
            source: startingSource,
            patchCache: &patchCache
        )
    }

    private static func recoveryFollowUpSmokeSources(
        for manifest: AmigaProgramFamilyManifest,
        prompts: [String],
        source startingSource: String? = nil,
        patchCache: inout FollowUpPatchOutcomeCache
    ) throws -> [(prompt: String, source: String, model: AmigaProgramModel)] {
        guard prompts.count >= 3 else {
            throw AmigaProgramPatchError.verificationFailed([
                "\(manifest.id): required recovery follow-up smoke chain must contain accepted setup, rejected follow-up, and recovery follow-up."
            ])
        }

        let setupPrompts = Array(prompts.dropLast(2))
        let rejectedPrompt = prompts[prompts.count - 2]
        let recoveryPrompt = prompts[prompts.count - 1]
        var artifacts = try followUpSmokeSources(
            for: manifest,
            prompts: setupPrompts,
            source: startingSource,
            patchCache: &patchCache
        )
        let sourceBeforeRejection: String
        if let lastArtifact = artifacts.last {
            sourceBeforeRejection = lastArtifact.source
        } else if let startingSource {
            sourceBeforeRejection = startingSource
        } else {
            sourceBeforeRejection = try verifiedSource(for: manifest)
        }

        switch patchCache.outcome(prompt: rejectedPrompt, source: sourceBeforeRejection) {
        case .rejected(let reasons):
            let failures = concreteRejectionReasonFailures(
                reasons,
                manifest: manifest,
                context: "required recovery follow-up smoke chain rejected prompt",
                prompt: rejectedPrompt
            )
            if !failures.isEmpty {
                throw AmigaProgramPatchError.verificationFailed(failures)
            }
        case .notRecognized:
            throw AmigaProgramPatchError.verificationFailed([
                "\(manifest.id): required recovery follow-up smoke chain rejected prompt was not recognized after setup: \(rejectedPrompt)"
            ])
        case .patched:
            throw AmigaProgramPatchError.verificationFailed([
                "\(manifest.id): required recovery follow-up smoke chain rejected prompt patched instead of rejecting after setup: \(rejectedPrompt)"
            ])
        }

        switch patchCache.outcome(prompt: recoveryPrompt, source: sourceBeforeRejection) {
        case .notRecognized:
            throw AmigaProgramPatchError.verificationFailed([
                "\(manifest.id): required recovery follow-up smoke chain recovery prompt was not recognized after rejection: \(recoveryPrompt)"
            ])
        case .rejected(let reasons):
            throw AmigaProgramPatchError.verificationFailed(
                unexpectedRejectionFailures(
                    reasons,
                    manifest: manifest,
                    context: "required recovery follow-up smoke chain recovery prompt",
                    prompt: recoveryPrompt
                )
            )
        case .patched(let result):
            let failures = acceptedFollowUpArtifactFailures(
                manifest: manifest,
                prompt: recoveryPrompt,
                previousSource: sourceBeforeRejection,
                result: result
            )
            if !failures.isEmpty {
                throw AmigaProgramPatchError.verificationFailed(failures)
            }
            artifacts.append((prompt: recoveryPrompt, source: result.source, model: result.model))
        }

        return artifacts
    }

    static func acceptedFollowUpArtifactFailures(
        manifest: AmigaProgramFamilyManifest,
        prompt: String,
        previousSource: String? = nil,
        result: AmigaProgramPatchResult
    ) -> [String] {
        var failures: [String] = []
        if let previousSource {
            failures.append(contentsOf: patchResultEffectFailures(
                manifest: manifest,
                prompt: prompt,
                previousSource: previousSource,
                result: result
            ))
            failures.append(contentsOf: patchResultChangedRegionFailures(
                manifest: manifest,
                prompt: prompt,
                previousSource: previousSource,
                result: result
            ))
        }
        failures.append(contentsOf: patchResultModelIdentityFailures(
            manifest: manifest,
            prompt: prompt,
            result: result
        ))
        failures.append(contentsOf: AmigaProgramSourceVerifier.failures(in: result.source).map {
            "\(manifest.id): accepted follow-up artifact verifier failure after \(prompt): \($0)"
        })
        let semantic = AssemblySemanticValidator.validate(
            source: result.source,
            prompt: semanticPrompt(for: manifest, followUpPrompt: prompt)
        )
        if !semantic.passed {
            failures.append("\(manifest.id): accepted follow-up artifact semantic failure after \(prompt): \(semantic.summary)")
        }
        if let previousSource,
           let previousModel = AmigaSourceIndexer.index(previousSource).model {
            failures.append(contentsOf: modelPreservationFailures(
                manifest: manifest,
                prompt: prompt,
                previousModel: previousModel,
                resultModel: result.model
            ))
            failures.append(contentsOf: sourceRoutineBodyPreservationFailures(
                manifest: manifest,
                prompt: prompt,
                previousSource: previousSource,
                result: result,
                previousModel: previousModel
            ))
            failures.append(contentsOf: sourceDataBlockPreservationFailures(
                manifest: manifest,
                prompt: prompt,
                previousSource: previousSource,
                result: result,
                previousModel: previousModel
            ))
        }
        return failures
    }

    static func followUpSmokeFailures(for manifest: AmigaProgramFamilyManifest, source: String) -> [String] {
        var semanticCache = SemanticValidationCache()
        var patchCache = FollowUpPatchOutcomeCache()
        return followUpSmokeFailures(for: manifest, source: source, semanticCache: &semanticCache, patchCache: &patchCache)
    }

    private static func followUpSmokeFailures(
        for manifest: AmigaProgramFamilyManifest,
        source: String,
        semanticCache: inout SemanticValidationCache
    ) -> [String] {
        var patchCache = FollowUpPatchOutcomeCache()
        return followUpSmokeFailures(for: manifest, source: source, semanticCache: &semanticCache, patchCache: &patchCache)
    }

    private static func followUpSmokeFailures(
        for manifest: AmigaProgramFamilyManifest,
        source: String,
        semanticCache: inout SemanticValidationCache,
        patchCache: inout FollowUpPatchOutcomeCache
    ) -> [String] {
        var failures = followUpSmokeFailures(
            for: manifest,
            source: source,
            prompts: manifest.requiredFollowUpSmokePrompts,
            chainName: "required prompt chain",
            semanticCache: &semanticCache,
            patchCache: &patchCache
        )

        for (index, prompts) in manifest.requiredFollowUpSmokeChains.enumerated() {
            failures.append(contentsOf: followUpSmokeFailures(
                for: manifest,
                source: source,
                prompts: prompts,
                chainName: "conversation chain \(index + 1)",
                semanticCache: &semanticCache,
                patchCache: &patchCache
            ))
        }

        return failures
    }

    static func rejectedFollowUpSmokeFailures(for manifest: AmigaProgramFamilyManifest, source: String) -> [String] {
        var patchCache = FollowUpPatchOutcomeCache()
        return rejectedFollowUpSmokeFailures(for: manifest, source: source, patchCache: &patchCache)
    }

    private static func rejectedFollowUpSmokeFailures(
        for manifest: AmigaProgramFamilyManifest,
        source: String,
        patchCache: inout FollowUpPatchOutcomeCache
    ) -> [String] {
        var failures: [String] = []

        for prompt in manifest.requiredRejectedFollowUpSmokePrompts {
            switch patchCache.outcome(prompt: prompt, source: source) {
            case .rejected(let reasons):
                failures.append(contentsOf: concreteRejectionReasonFailures(
                    reasons,
                    manifest: manifest,
                    context: "required rejected follow-up smoke prompt",
                    prompt: prompt
                ))
            case .notRecognized:
                failures.append("\(manifest.id): required rejected follow-up smoke prompt was not recognized: \(prompt)")
            case .patched:
                failures.append("\(manifest.id): required rejected follow-up smoke prompt patched instead of rejecting: \(prompt)")
            }
        }
        for (index, chain) in manifest.requiredRejectedFollowUpSmokeChains.enumerated() {
            failures.append(contentsOf: rejectedFollowUpSmokeChainFailures(
                for: manifest,
                source: source,
                prompts: chain,
                chainName: "required rejected follow-up smoke chain \(index + 1)",
                patchCache: &patchCache
            ))
        }

        return failures
    }

    static func recoveryFollowUpSmokeFailures(for manifest: AmigaProgramFamilyManifest, source: String) -> [String] {
        var patchCache = FollowUpPatchOutcomeCache()
        return recoveryFollowUpSmokeFailures(for: manifest, source: source, patchCache: &patchCache)
    }

    private static func recoveryFollowUpSmokeFailures(
        for manifest: AmigaProgramFamilyManifest,
        source: String,
        patchCache: inout FollowUpPatchOutcomeCache
    ) -> [String] {
        manifest.requiredRecoveryFollowUpSmokeChains.enumerated().flatMap { index, chain -> [String] in
            do {
                _ = try recoveryFollowUpSmokeSources(
                    for: manifest,
                    prompts: chain,
                    source: source,
                    patchCache: &patchCache
                )
                return []
            } catch AmigaProgramPatchError.verificationFailed(let failures) {
                return failures
            } catch {
                return ["\(manifest.id): required recovery follow-up smoke chain \(index + 1) failed: \(error.localizedDescription)"]
            }
        }
    }

    static func ignoredFollowUpSmokeFailures(for manifest: AmigaProgramFamilyManifest, source: String) -> [String] {
        var patchCache = FollowUpPatchOutcomeCache()
        return ignoredFollowUpSmokeFailures(for: manifest, source: source, patchCache: &patchCache)
    }

    private static func ignoredFollowUpSmokeFailures(
        for manifest: AmigaProgramFamilyManifest,
        source: String,
        patchCache: inout FollowUpPatchOutcomeCache
    ) -> [String] {
        var failures: [String] = []

        for prompt in manifest.requiredIgnoredFollowUpSmokePrompts {
            switch patchCache.outcome(prompt: prompt, source: source) {
            case .notRecognized:
                break
            case .rejected(let reasons):
                let reasonSummary = concreteRejectionReasonSummary(reasons)
                failures.append("\(manifest.id): required ignored follow-up smoke prompt rejected instead of staying unrecognized: \(prompt): \(reasonSummary)")
            case .patched:
                failures.append("\(manifest.id): required ignored follow-up smoke prompt patched instead of staying unrecognized: \(prompt)")
            }
        }

        return failures
    }

    private static func concreteRejectionReasonFailures(
        _ reasons: [String],
        manifest: AmigaProgramFamilyManifest,
        context: String,
        prompt: String
    ) -> [String] {
        let concreteReasons = reasons.map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
        }.filter { !$0.isEmpty }
        guard concreteReasons.isEmpty else {
            return []
        }
        return ["\(manifest.id): \(context) rejected without concrete diagnostics: \(prompt)"]
    }

    private static func unexpectedRejectionFailures(
        _ reasons: [String],
        manifest: AmigaProgramFamilyManifest,
        context: String,
        prompt: String
    ) -> [String] {
        let reasonSummary = concreteRejectionReasonSummary(reasons)
        var failures = ["\(manifest.id): \(context) was rejected: \(prompt): \(reasonSummary)"]
        failures.append(contentsOf: concreteRejectionReasonFailures(
            reasons,
            manifest: manifest,
            context: context,
            prompt: prompt
        ))
        return failures
    }

    private static func concreteRejectionReasonSummary(_ reasons: [String]) -> String {
        let concreteReasons = reasons.map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
        }.filter { !$0.isEmpty }
        return concreteReasons.isEmpty ? "<missing>" : concreteReasons.joined(separator: "; ")
    }

    private static func acceptedSmokePrompts(in manifest: AmigaProgramFamilyManifest) -> [String] {
        let rejectedChainSetupPrompts = manifest.requiredRejectedFollowUpSmokeChains.flatMap { $0.dropLast() }
        let recoveryChainAcceptedPrompts = manifest.requiredRecoveryFollowUpSmokeChains.flatMap { chain -> [String] in
            guard chain.count >= 3 else { return chain }
            return Array(chain.dropLast(2)) + [chain[chain.count - 1]]
        }
        return manifest.requiredFollowUpSmokePrompts +
            manifest.requiredFollowUpSmokeChains.flatMap { $0 } +
            rejectedChainSetupPrompts +
            recoveryChainAcceptedPrompts
    }

    private static func representativeAcceptedSmokePrompts(in manifest: AmigaProgramFamilyManifest) -> [String] {
        let recoveryAcceptedPrompts = manifest.representativeRoutedRecoveryFollowUpSmokeChains.flatMap { chain -> [String] in
            guard chain.count >= 3 else { return chain }
            return Array(chain.dropLast(2)) + [chain[chain.count - 1]]
        }
        return manifest.representativeRoutedFollowUpSmokeChains.flatMap { $0 } +
            recoveryAcceptedPrompts
    }

    private static func rejectedSmokePrompts(in manifest: AmigaProgramFamilyManifest) -> [String] {
        let recoveryChainRejectedPrompts = manifest.requiredRecoveryFollowUpSmokeChains.compactMap { chain in
            chain.count >= 2 ? chain[chain.count - 2] : nil
        }
        return manifest.requiredRejectedFollowUpSmokePrompts +
            manifest.requiredRejectedFollowUpSmokeChains.compactMap(\.last) +
            recoveryChainRejectedPrompts
    }

    private static func rejectedSmokePromptCovers(_ prompt: String, supportedFollowUp: String) -> Bool {
        if smokePromptCovers(prompt, supportedFollowUp: supportedFollowUp) {
            return true
        }

        let normalizedPrompt = prompt.lowercased()
        switch supportedFollowUp.lowercased() {
        case "add volume up", "add volume down", "add volume controls", "add pause", "add mute":
            return containsWord("add", in: normalizedPrompt) &&
                (containsWord("button", in: normalizedPrompt) ||
                    containsWord("buttons", in: normalizedPrompt) ||
                    containsWord("control", in: normalizedPrompt) ||
                    containsWord("controls", in: normalizedPrompt) ||
                    containsWord("called", in: normalizedPrompt) ||
                    containsWord("named", in: normalizedPrompt))
        default:
            return false
        }
    }

    private static func smokePromptCovers(_ prompt: String, supportedFollowUp: String) -> Bool {
        let normalizedPrompt = prompt.lowercased()
        switch supportedFollowUp.lowercased() {
        case "set front color":
            return containsWord("front", in: normalizedPrompt) && containsWord("color", in: normalizedPrompt)
        case "set back color":
            return containsWord("back", in: normalizedPrompt) && containsWord("color", in: normalizedPrompt)
        case "add volume up":
            return containsPhrase("volume up", in: normalizedPrompt) ||
                containsPhrase("raise volume", in: normalizedPrompt) ||
                containsPhrase("increase volume", in: normalizedPrompt) ||
                containsPhrase("turn volume up", in: normalizedPrompt) ||
                (containsWord("add", in: normalizedPrompt) && containsWord("louder", in: normalizedPrompt))
        case "add volume down":
            return containsPhrase("volume down", in: normalizedPrompt) ||
                containsPhrase("lower volume", in: normalizedPrompt) ||
                containsPhrase("decrease volume", in: normalizedPrompt) ||
                containsPhrase("turn volume down", in: normalizedPrompt) ||
                (containsWord("add", in: normalizedPrompt) && containsWord("quieter", in: normalizedPrompt))
        case "add volume controls":
            return (containsWord("volume", in: normalizedPrompt) &&
                (containsWord("controls", in: normalizedPrompt) || containsWord("buttons", in: normalizedPrompt))) ||
                ((containsPhrase("volume up", in: normalizedPrompt) || containsPhrase("raise volume", in: normalizedPrompt)) &&
                    (containsPhrase("volume down", in: normalizedPrompt) || containsPhrase("lower volume", in: normalizedPrompt)))
        case "add pause":
            return containsWord("add", in: normalizedPrompt) && containsWord("pause", in: normalizedPrompt)
        case "add mute":
            return containsWord("add", in: normalizedPrompt) && containsWord("mute", in: normalizedPrompt)
        case "rename a visible control label":
            return !containsWord("add", in: normalizedPrompt) &&
                (containsWord("rename", in: normalizedPrompt) ||
                    containsWord("label", in: normalizedPrompt) ||
                    containsWord("labeled", in: normalizedPrompt) ||
                    containsWord("labelled", in: normalizedPrompt) ||
                    containsWord("text", in: normalizedPrompt) ||
                    containsWord("caption", in: normalizedPrompt) ||
                    containsWord("title", in: normalizedPrompt) ||
                    containsWord("say", in: normalizedPrompt))
        case "remove an added control":
            return containsWord("remove", in: normalizedPrompt) ||
                containsWord("delete", in: normalizedPrompt) ||
                containsWord("drop", in: normalizedPrompt)
        case "reorder controls":
            return (containsWord("move", in: normalizedPrompt) ||
                containsWord("put", in: normalizedPrompt) ||
                containsWord("place", in: normalizedPrompt) ||
                containsWord("shift", in: normalizedPrompt) ||
                containsWord("bring", in: normalizedPrompt) ||
                containsWord("reorder", in: normalizedPrompt)) &&
                (containsWord("before", in: normalizedPrompt) || containsWord("after", in: normalizedPrompt))
        case "change an added control behavior":
            return (containsWord("make", in: normalizedPrompt) ||
                containsWord("change", in: normalizedPrompt) ||
                containsWord("switch", in: normalizedPrompt) ||
                containsWord("convert", in: normalizedPrompt) ||
                containsWord("turn", in: normalizedPrompt) ||
                containsWord("set", in: normalizedPrompt)) &&
                (containsWord("instead", in: normalizedPrompt) ||
                    containsWord("to", in: normalizedPrompt) ||
                    containsWord("into", in: normalizedPrompt) ||
                    containsWord("as", in: normalizedPrompt))
        case "change control bounds":
            return (containsWord("bounds", in: normalizedPrompt) ||
                containsWord("position", in: normalizedPrompt) ||
                containsWord("resize", in: normalizedPrompt) ||
                containsWord("size", in: normalizedPrompt) ||
                containsWord("wide", in: normalizedPrompt) ||
                containsWord("width", in: normalizedPrompt) ||
                containsWord("height", in: normalizedPrompt) ||
                containsWord("tall", in: normalizedPrompt) ||
                containsWord("center", in: normalizedPrompt) ||
                containsWord("centered", in: normalizedPrompt) ||
                containsWord("wider", in: normalizedPrompt) ||
                containsWord("narrower", in: normalizedPrompt) ||
                containsWord("taller", in: normalizedPrompt) ||
                containsWord("shorter", in: normalizedPrompt) ||
                containsWord("bigger", in: normalizedPrompt) ||
                containsWord("larger", in: normalizedPrompt) ||
                containsWord("smaller", in: normalizedPrompt) ||
                hasExplicitSizeSmokeSignal(in: normalizedPrompt) ||
                hasRelativePositionSmokeSignal(in: normalizedPrompt) ||
                hasRelativePlacementSmokeSignal(in: normalizedPrompt)) &&
                (containsWord("set", in: normalizedPrompt) ||
                    containsWord("change", in: normalizedPrompt) ||
                    containsWord("move", in: normalizedPrompt) ||
                    containsWord("place", in: normalizedPrompt) ||
                    containsWord("put", in: normalizedPrompt) ||
                    containsWord("make", in: normalizedPrompt) ||
                    containsWord("center", in: normalizedPrompt) ||
                    containsWord("centered", in: normalizedPrompt))
        case "change playback period":
            return containsWord("period", in: normalizedPrompt) &&
                (containsWord("playback", in: normalizedPrompt) ||
                    containsWord("audio", in: normalizedPrompt) ||
                    containsWord("paula", in: normalizedPrompt) ||
                    containsWord("aud0per", in: normalizedPrompt)) &&
                (containsWord("set", in: normalizedPrompt) ||
                    containsWord("change", in: normalizedPrompt) ||
                    containsWord("update", in: normalizedPrompt) ||
                    containsWord("adjust", in: normalizedPrompt) ||
                    containsWord("make", in: normalizedPrompt))
        case "change playback note":
            return (containsWord("note", in: normalizedPrompt) ||
                containsWord("pitch", in: normalizedPrompt)) &&
                (containsWord("playback", in: normalizedPrompt) ||
                    containsWord("audio", in: normalizedPrompt) ||
                    containsWord("paula", in: normalizedPrompt) ||
                    containsWord("mod", in: normalizedPrompt) ||
                    containsWord("module", in: normalizedPrompt)) &&
                (containsWord("set", in: normalizedPrompt) ||
                    containsWord("change", in: normalizedPrompt) ||
                    containsWord("update", in: normalizedPrompt) ||
                    containsWord("adjust", in: normalizedPrompt) ||
                    containsWord("make", in: normalizedPrompt))
        case "change volume step":
            return containsWord("volume", in: normalizedPrompt) &&
                (containsWord("step", in: normalizedPrompt) ||
                    containsWord("increment", in: normalizedPrompt) ||
                    containsWord("amount", in: normalizedPrompt))
        case "set initial volume":
            return containsWord("volume", in: normalizedPrompt) &&
                !containsWord("step", in: normalizedPrompt) &&
                !containsWord("increment", in: normalizedPrompt) &&
                !containsWord("amount", in: normalizedPrompt) &&
                (containsWord("initial", in: normalizedPrompt) ||
                    containsWord("default", in: normalizedPrompt) ||
                    containsWord("starting", in: normalizedPrompt) ||
                    containsPhrase("start volume", in: normalizedPrompt) ||
                    containsPhrase("set volume", in: normalizedPrompt) ||
                    containsPhrase("volume to", in: normalizedPrompt))
        default:
            return containsPhrase(supportedFollowUp, in: normalizedPrompt)
        }
    }

    private static func hasRelativePositionSmokeSignal(in normalizedPrompt: String) -> Bool {
        guard containsWord("by", in: normalizedPrompt) else { return false }
        return containsWord("left", in: normalizedPrompt) ||
            containsWord("right", in: normalizedPrompt) ||
            containsWord("up", in: normalizedPrompt) ||
            containsWord("down", in: normalizedPrompt)
    }

    private static func hasExplicitSizeSmokeSignal(in normalizedPrompt: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: #"\b\d+\s*x\s*\d+\b"#) else {
            return false
        }
        let range = NSRange(normalizedPrompt.startIndex..<normalizedPrompt.endIndex, in: normalizedPrompt)
        return regex.firstMatch(in: normalizedPrompt, range: range) != nil
    }

    private static func hasRelativePlacementSmokeSignal(in normalizedPrompt: String) -> Bool {
        containsWord("below", in: normalizedPrompt) ||
            containsWord("under", in: normalizedPrompt) ||
            containsWord("beneath", in: normalizedPrompt) ||
            containsWord("above", in: normalizedPrompt) ||
            containsPhrase("left of", in: normalizedPrompt) ||
            containsPhrase("right of", in: normalizedPrompt)
    }

    private static func containsWord(_ word: String, in normalizedPrompt: String) -> Bool {
        normalizedPrompt.split { !$0.isLetter && !$0.isNumber }.contains { $0 == word.lowercased() }
    }

    private static func containsPhrase(_ phrase: String, in normalizedPrompt: String) -> Bool {
        let promptTokens = normalizedPrompt.split { !$0.isLetter && !$0.isNumber }
        let phraseTokens = phrase.lowercased().split { !$0.isLetter && !$0.isNumber }
        guard !phraseTokens.isEmpty,
              phraseTokens.count <= promptTokens.count else {
            return false
        }
        for start in 0...(promptTokens.count - phraseTokens.count) {
            let window = promptTokens[start..<(start + phraseTokens.count)]
            if zip(window, phraseTokens).allSatisfy({ $0 == $1 }) {
                return true
            }
        }
        return false
    }

    private static func rejectedFollowUpSmokeChainFailures(
        for manifest: AmigaProgramFamilyManifest,
        source: String,
        prompts: [String],
        chainName: String
    ) -> [String] {
        var patchCache = FollowUpPatchOutcomeCache()
        return rejectedFollowUpSmokeChainFailures(
            for: manifest,
            source: source,
            prompts: prompts,
            chainName: chainName,
            patchCache: &patchCache
        )
    }

    private static func rejectedFollowUpSmokeChainFailures(
        for manifest: AmigaProgramFamilyManifest,
        source: String,
        prompts: [String],
        chainName: String,
        patchCache: inout FollowUpPatchOutcomeCache
    ) -> [String] {
        guard prompts.count >= 2 else { return [] }

        var failures: [String] = []
        var currentSource = source
        var previousModel = AmigaSourceIndexer.index(source).model
        let acceptedSetupPrompts = prompts.dropLast()
        let rejectedPrompt = prompts[prompts.count - 1]

        for prompt in acceptedSetupPrompts {
            switch patchCache.outcome(prompt: prompt, source: currentSource) {
            case .notRecognized:
                failures.append("\(manifest.id): \(chainName) setup prompt was not recognized: \(prompt)")
                return failures
            case .rejected(let reasons):
                failures.append(contentsOf: unexpectedRejectionFailures(
                    reasons,
                    manifest: manifest,
                    context: "\(chainName) setup prompt",
                    prompt: prompt
                ))
                return failures
            case .patched(let result):
                failures.append(contentsOf: patchResultEffectFailures(
                    manifest: manifest,
                    prompt: "\(chainName) / \(prompt)",
                    previousSource: currentSource,
                    result: result
                ))
                failures.append(contentsOf: patchResultModelIdentityFailures(
                    manifest: manifest,
                    prompt: "\(chainName) / \(prompt)",
                    result: result
                ))
                failures.append(contentsOf: patchResultChangedRegionFailures(
                    manifest: manifest,
                    prompt: "\(chainName) / \(prompt)",
                    previousSource: currentSource,
                    result: result
                ))
                let verifierFailures = AmigaProgramSourceVerifier.failures(in: result.source)
                failures.append(contentsOf: verifierFailures.map { "\(manifest.id): \(chainName) verifier failure after \(prompt): \($0)" })
                let semantic = AssemblySemanticValidator.validate(
                    source: result.source,
                    prompt: semanticPrompt(for: manifest, followUpPrompt: prompt)
                )
                if !semantic.passed {
                    failures.append("\(manifest.id): \(chainName) semantic failure after \(prompt): \(semantic.summary)")
                }
                if let previousModel {
                    failures.append(contentsOf: modelPreservationFailures(
                        manifest: manifest,
                        prompt: "\(chainName) / \(prompt)",
                        previousModel: previousModel,
                        resultModel: result.model
                    ))
                    failures.append(contentsOf: sourceRoutineBodyPreservationFailures(
                        manifest: manifest,
                        prompt: "\(chainName) / \(prompt)",
                        previousSource: currentSource,
                        result: result,
                        previousModel: previousModel
                    ))
                    failures.append(contentsOf: sourceDataBlockPreservationFailures(
                        manifest: manifest,
                        prompt: "\(chainName) / \(prompt)",
                        previousSource: currentSource,
                        result: result,
                        previousModel: previousModel
                    ))
                }
                currentSource = result.source
                previousModel = result.model
            }
        }

        switch patchCache.outcome(prompt: rejectedPrompt, source: currentSource) {
        case .rejected(let reasons):
            failures.append(contentsOf: concreteRejectionReasonFailures(
                reasons,
                manifest: manifest,
                context: "\(chainName) rejected prompt",
                prompt: rejectedPrompt
            ))
        case .notRecognized:
            failures.append("\(manifest.id): \(chainName) rejected prompt was not recognized after setup: \(rejectedPrompt)")
        case .patched:
            failures.append("\(manifest.id): \(chainName) rejected prompt patched instead of rejecting after setup: \(rejectedPrompt)")
        }

        return failures
    }

    private static func followUpSmokeFailures(
        for manifest: AmigaProgramFamilyManifest,
        source: String,
        prompts: [String],
        chainName: String
    ) -> [String] {
        var semanticCache = SemanticValidationCache()
        return followUpSmokeFailures(
            for: manifest,
            source: source,
            prompts: prompts,
            chainName: chainName,
            semanticCache: &semanticCache
        )
    }

    private static func followUpSmokeFailures(
        for manifest: AmigaProgramFamilyManifest,
        source: String,
        prompts: [String],
        chainName: String,
        semanticCache: inout SemanticValidationCache
    ) -> [String] {
        var patchCache = FollowUpPatchOutcomeCache()
        return followUpSmokeFailures(
            for: manifest,
            source: source,
            prompts: prompts,
            chainName: chainName,
            semanticCache: &semanticCache,
            patchCache: &patchCache
        )
    }

    private static func followUpSmokeFailures(
        for manifest: AmigaProgramFamilyManifest,
        source: String,
        prompts: [String],
        chainName: String,
        semanticCache: inout SemanticValidationCache,
        patchCache: inout FollowUpPatchOutcomeCache
    ) -> [String] {
        var failures: [String] = []
        var currentSource = source
        var previousModel = AmigaSourceIndexer.index(source).model

        for prompt in prompts {
            switch patchCache.outcome(prompt: prompt, source: currentSource) {
            case .notRecognized:
                failures.append("\(manifest.id): \(chainName) prompt was not recognized: \(prompt)")
            case .rejected(let reasons):
                failures.append(contentsOf: unexpectedRejectionFailures(
                    reasons,
                    manifest: manifest,
                    context: "\(chainName) prompt",
                    prompt: prompt
                ))
            case .patched(let result):
                failures.append(contentsOf: patchResultEffectFailures(
                    manifest: manifest,
                    prompt: "\(chainName) / \(prompt)",
                    previousSource: currentSource,
                    result: result
                ))
                failures.append(contentsOf: patchResultModelIdentityFailures(
                    manifest: manifest,
                    prompt: "\(chainName) / \(prompt)",
                    result: result
                ))
                failures.append(contentsOf: patchResultChangedRegionFailures(
                    manifest: manifest,
                    prompt: "\(chainName) / \(prompt)",
                    previousSource: currentSource,
                    result: result
                ))
                let verifierFailures = AmigaProgramSourceVerifier.failures(in: result.source)
                failures.append(contentsOf: verifierFailures.map { "\(manifest.id): \(chainName) verifier failure after \(prompt): \($0)" })
                let semantic = semanticCache.validate(
                    source: result.source,
                    prompt: semanticPrompt(for: manifest, followUpPrompt: prompt)
                )
                if !semantic.passed {
                    failures.append("\(manifest.id): \(chainName) semantic failure after \(prompt): \(semantic.summary)")
                }

                if let previousModel {
                    failures.append(contentsOf: modelPreservationFailures(
                        manifest: manifest,
                        prompt: "\(chainName) / \(prompt)",
                        previousModel: previousModel,
                        resultModel: result.model
                    ))
                    failures.append(contentsOf: sourceRoutineBodyPreservationFailures(
                        manifest: manifest,
                        prompt: "\(chainName) / \(prompt)",
                        previousSource: currentSource,
                        result: result,
                        previousModel: previousModel
                    ))
                    failures.append(contentsOf: sourceDataBlockPreservationFailures(
                        manifest: manifest,
                        prompt: "\(chainName) / \(prompt)",
                        previousSource: currentSource,
                        result: result,
                        previousModel: previousModel
                    ))
                }

                currentSource = result.source
                previousModel = result.model
            }
        }

        return failures
    }

    static func patchResultEffectFailures(
        manifest: AmigaProgramFamilyManifest,
        prompt: String,
        previousSource: String,
        result: AmigaProgramPatchResult
    ) -> [String] {
        var failures: [String] = []
        if result.source == previousSource {
            failures.append("\(manifest.id): follow-up \(prompt) returned patched output without changing source.")
        }
        if result.changedRegions.isEmpty {
            failures.append("\(manifest.id): follow-up \(prompt) did not declare any changed regions.")
        }
        return failures
    }

    static func patchResultModelIdentityFailures(
        manifest: AmigaProgramFamilyManifest,
        prompt: String,
        result: AmigaProgramPatchResult
    ) -> [String] {
        let embeddedModel = AmigaSourceIndexer.index(result.source).model
        guard embeddedModel == result.model else {
            return ["\(manifest.id): follow-up \(prompt) returned a model that does not match the model embedded in its source."]
        }
        return []
    }

    static func patchResultChangedRegionFailures(
        manifest: AmigaProgramFamilyManifest,
        prompt: String,
        previousSource: String,
        result: AmigaProgramPatchResult
    ) -> [String] {
        let declaredRegions = result.changedRegions
        let duplicateDeclaredRegions = Dictionary(grouping: declaredRegions, by: { $0 })
            .filter { $0.value.count > 1 }
            .map(\.key)
            .sorted()
        var failures = duplicateDeclaredRegions.map {
            "\(manifest.id): follow-up \(prompt) declares changed region \($0) more than once."
        }
        let canonicalRegionNames = Set(AmigaSourceRegionName.allCases.map(\.rawValue))
        for region in declaredRegions.sorted() where !canonicalRegionNames.contains(region) {
            failures.append("\(manifest.id): follow-up \(prompt) declares non-canonical changed region \(region).")
        }

        let previousIndex = AmigaSourceIndexer.index(previousSource)
        let resultIndex = AmigaSourceIndexer.index(result.source)
        let knownRegions = Set(previousIndex.regions.keys).union(resultIndex.regions.keys)
        let actualChangedRegions = knownRegions
            .filter { regionName in
                regionText(regionName, in: previousSource, index: previousIndex) !=
                    regionText(regionName, in: result.source, index: resultIndex)
            }
            .sorted()

        let declaredSet = Set(declaredRegions)
        let actualSet = Set(actualChangedRegions)
        for region in actualChangedRegions where !declaredSet.contains(region) {
            failures.append("\(manifest.id): follow-up \(prompt) changed region \(region) but did not declare it.")
        }
        for region in declaredRegions.sorted() where !actualSet.contains(region) {
            failures.append("\(manifest.id): follow-up \(prompt) declares region \(region) as changed, but that region did not change.")
        }
        for region in declaredRegions.sorted() where !knownRegions.contains(region) {
            failures.append("\(manifest.id): follow-up \(prompt) declares unknown changed region \(region).")
        }
        if sourceOutsideClosedRegions(previousSource, index: previousIndex) !=
            sourceOutsideClosedRegions(result.source, index: resultIndex) {
            failures.append("\(manifest.id): follow-up \(prompt) changed source outside model-backed regions.")
        }

        return failures
    }

    static func sourceActionRoutinePreservationFailures(
        manifest: AmigaProgramFamilyManifest,
        prompt: String,
        previousSource: String,
        resultSource: String,
        previousModel: AmigaProgramModel,
        resultModel: AmigaProgramModel
    ) -> [String] {
        let previousLines = previousSource.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        let resultLines = resultSource.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        var failures: [String] = []

        for previousControl in previousModel.controls
            where resultModel.controls.contains(where: { $0.id == previousControl.id && $0.action == previousControl.action }) {
            guard !isActionRoutineBodySuperseded(previousControl.action, by: resultModel.verificationExpectations, prompt: prompt) else {
                continue
            }
            guard let previousBody = routineBody(previousControl.action, inRegion: AmigaSourceRegionName.routines.rawValue, source: previousSource, sourceLines: previousLines),
                  let resultBody = routineBody(previousControl.action, inRegion: AmigaSourceRegionName.routines.rawValue, source: resultSource, sourceLines: resultLines) else {
                continue
            }
            if previousBody != resultBody {
                failures.append("\(manifest.id): follow-up \(prompt) changed existing action routine \(previousControl.action) for \(previousControl.label).")
            }
        }

        return failures
    }

    static func sourceRoutineBodyPreservationFailures(
        manifest: AmigaProgramFamilyManifest,
        prompt: String,
        previousSource: String,
        result: AmigaProgramPatchResult,
        previousModel: AmigaProgramModel
    ) -> [String] {
        let previousLines = previousSource.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        let resultLines = result.source.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        let previousIndex = AmigaSourceIndexer.index(previousSource)
        let resultIndex = AmigaSourceIndexer.index(result.source)
        var failures: [String] = []

        for previousRoutine in previousModel.routines {
            guard result.model.routines.contains(where: { $0.id == previousRoutine.id && $0.label == previousRoutine.label }),
                  let expectedRegion = expectedRegionName(for: previousRoutine, model: previousModel) else {
                continue
            }
            guard !isRoutineBodySuperseded(
                previousRoutine,
                inRegion: expectedRegion,
                previousModel: previousModel,
                result: result,
                prompt: prompt
            ) else {
                continue
            }
            guard let previousBody = routineBody(previousRoutine.label, inRegion: expectedRegion.rawValue, index: previousIndex, sourceLines: previousLines),
                  let resultBody = routineBody(previousRoutine.label, inRegion: expectedRegion.rawValue, index: resultIndex, sourceLines: resultLines) else {
                continue
            }
            if previousBody != resultBody {
                failures.append("\(manifest.id): follow-up \(prompt) changed existing routine source body \(previousRoutine.label).")
            }
        }

        return failures
    }

    static func sourceDataBlockPreservationFailures(
        manifest: AmigaProgramFamilyManifest,
        prompt: String,
        previousSource: String,
        result: AmigaProgramPatchResult,
        previousModel: AmigaProgramModel
    ) -> [String] {
        let previousLines = previousSource.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        let resultLines = result.source.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        let previousIndex = AmigaSourceIndexer.index(previousSource)
        let resultIndex = AmigaSourceIndexer.index(result.source)
        let previousLabels = labelNames(inRegion: AmigaSourceRegionName.chipData.rawValue, index: previousIndex, sourceLines: previousLines)
        let resultLabels = Set(labelNames(inRegion: AmigaSourceRegionName.chipData.rawValue, index: resultIndex, sourceLines: resultLines))
        var failures: [String] = []

        for label in previousLabels where resultLabels.contains(label) {
            guard !isDataBlockSuperseded(label, previousModel: previousModel, resultModel: result.model, prompt: prompt) else {
                continue
            }
            guard let previousBlock = dataBlock(label, inRegion: AmigaSourceRegionName.chipData.rawValue, index: previousIndex, sourceLines: previousLines),
                  let resultBlock = dataBlock(label, inRegion: AmigaSourceRegionName.chipData.rawValue, index: resultIndex, sourceLines: resultLines) else {
                continue
            }
            if previousBlock != resultBlock {
                failures.append("\(manifest.id): follow-up \(prompt) changed existing chip data block \(label).")
            }
        }

        return failures
    }

    private static func isDataBlockSuperseded(
        _ label: String,
        previousModel: AmigaProgramModel,
        resultModel: AmigaProgramModel,
        prompt: String
    ) -> Bool {
        guard label.hasPrefix("ControlLabel_") || label.hasPrefix("ControlRect_") else {
            return false
        }
        if isControlRemovalPrompt(prompt) {
            return true
        }
        if isControlReorderPrompt(prompt), label.hasPrefix("ControlRect_") {
            return true
        }
        let controlID = label.hasPrefix("ControlLabel_")
            ? String(label.dropFirst("ControlLabel_".count))
            : String(label.dropFirst("ControlRect_".count))
        guard let previousControl = previousModel.controls.first(where: { $0.id == controlID }) else {
            return false
        }
        if isControlBoundsPrompt(prompt),
           label.hasPrefix("ControlRect_"),
           let resultControl = resultModel.controls.first(where: { $0.id == controlID }),
           resultControl.bounds != previousControl.bounds {
            return true
        }
        return isControlLabelSuperseded(previousControl, by: resultModel.verificationExpectations, prompt: prompt)
    }

    private static func isActionRoutineBodySuperseded(_ action: String, by resultExpectations: [String], prompt: String) -> Bool {
        if action == "PlayMOD" {
            guard promptAllowsPlaybackPeriodSupersession(prompt) else {
                return false
            }
            return resultExpectations.contains { $0.hasPrefix("Playback period is ") }
        }
        guard action == "VolumeUp" || action == "VolumeDown" else {
            return false
        }
        guard promptAllowsVolumeStepSupersession(prompt) else {
            return false
        }
        return resultExpectations.contains { $0.hasPrefix("Volume step is ") }
    }

    private static func isRoutineBodySuperseded(
        _ routine: AmigaProgramModel.Routine,
        inRegion region: AmigaSourceRegionName,
        previousModel: AmigaProgramModel,
        result: AmigaProgramPatchResult,
        prompt: String
    ) -> Bool {
        if isActionRoutineBodySuperseded(routine.label, by: result.model.verificationExpectations, prompt: prompt) {
            return true
        }
        let addedControls = result.model.controls.count > previousModel.controls.count
        if addedControls && regionSupportsAddedControls(region, routineLabel: routine.label) {
            return true
        }
        if isControlRemovalPrompt(prompt) && regionSupportsAddedControls(region, routineLabel: routine.label) {
            return true
        }
        if isControlReorderPrompt(prompt) && regionSupportsAddedControls(region, routineLabel: routine.label) {
            return true
        }
        if isControlBehaviorChangePrompt(prompt) && regionSupportsAddedControls(region, routineLabel: routine.label) {
            return true
        }
        if isControlBoundsPrompt(prompt) && regionSupportsControlGeometry(region, routineLabel: routine.label) {
            return true
        }
        return false
    }

    private static func regionSupportsControlGeometry(_ region: AmigaSourceRegionName, routineLabel: String) -> Bool {
        switch (region, routineLabel) {
        case (.drawControls, "DrawControls"),
             (.hitTest, "HitTestControls"):
            return true
        default:
            return false
        }
    }

    private static func regionSupportsAddedControls(_ region: AmigaSourceRegionName, routineLabel: String) -> Bool {
        switch (region, routineLabel) {
        case (.drawControls, "DrawControls"),
             (.hitTest, "HitTestControls"),
             (.inputDispatch, "InputDispatch"):
            return true
        default:
            return false
        }
    }

    private static func expectedRegionName(for routine: AmigaProgramModel.Routine, model: AmigaProgramModel) -> AmigaSourceRegionName? {
        if model.controls.contains(where: { $0.action == routine.label }) {
            return .routines
        }

        switch routine.label {
        case "DrawControls", "DrawControlRect", "DrawControlLabel":
            return .drawControls
        case "WaitVBlank", "ReadMouseControls", "HitTestControls":
            return .hitTest
        case "InputDispatch":
            return .inputDispatch
        default:
            return .routines
        }
    }

    private static func dataBlock(_ label: String, inRegion name: String, source: String, sourceLines: [String]) -> [String]? {
        let index = AmigaSourceIndexer.index(source)
        return dataBlock(label, inRegion: name, index: index, sourceLines: sourceLines)
    }

    private static func dataBlock(_ label: String, inRegion name: String, index: AmigaSourceIndex, sourceLines: [String]) -> [String]? {
        guard let region = index.regions[name],
              let endLine = region.endLine,
              let labelIndex = labelLineIndex(label, inRegion: name, index: index, sourceLines: sourceLines) else {
            return nil
        }
        let regionEndIndex = min(endLine - 1, sourceLines.count)
        let nextLineIndex = labelIndex + 1
        guard nextLineIndex < regionEndIndex else {
            return [sourceLines[labelIndex]]
        }
        let bodyEnd = sourceLines[nextLineIndex..<regionEndIndex].firstIndex { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("; @amiga:region") {
                return true
            }
            return AmigaSourceIndexer.labelName(from: line) != nil
        } ?? regionEndIndex
        return trimmedRoutineBody(Array(sourceLines[labelIndex..<bodyEnd]))
    }

    private static func labelNames(inRegion name: String, source: String, sourceLines: [String]) -> [String] {
        let index = AmigaSourceIndexer.index(source)
        return labelNames(inRegion: name, index: index, sourceLines: sourceLines)
    }

    private static func labelNames(inRegion name: String, index: AmigaSourceIndex, sourceLines: [String]) -> [String] {
        guard let region = index.regions[name], let endLine = region.endLine else {
            return []
        }
        let lowerBound = max(region.startLine - 1, 0)
        let upperBound = min(endLine - 1, sourceLines.count)
        guard lowerBound < upperBound else {
            return []
        }
        return sourceLines[lowerBound..<upperBound].compactMap { line in
            guard let label = AmigaSourceIndexer.labelName(from: line), !label.hasPrefix(".") else {
                return nil
            }
            return label
        }
    }

    private static func routineBody(_ label: String, inRegion name: String, source: String, sourceLines: [String]) -> [String]? {
        let index = AmigaSourceIndexer.index(source)
        return routineBody(label, inRegion: name, index: index, sourceLines: sourceLines)
    }

    private static func routineBody(_ label: String, inRegion name: String, index: AmigaSourceIndex, sourceLines: [String]) -> [String]? {
        guard let region = index.regions[name],
              let endLine = region.endLine,
              let labelIndex = labelLineIndex(label, inRegion: name, index: index, sourceLines: sourceLines) else {
            return nil
        }
        let regionEndIndex = min(endLine - 1, sourceLines.count)
        guard labelIndex + 1 < regionEndIndex else {
            return []
        }
        let bodyStart = labelIndex + 1
        let bodyEnd = sourceLines[bodyStart..<regionEndIndex].firstIndex { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("; @amiga:region") {
                return true
            }
            guard let label = AmigaSourceIndexer.labelName(from: line) else {
                return false
            }
            return !label.hasPrefix(".")
        } ?? regionEndIndex
        return trimmedRoutineBody(Array(sourceLines[bodyStart..<bodyEnd]))
    }

    private static func trimmedRoutineBody(_ lines: [String]) -> [String] {
        var result = lines
        while let last = result.last {
            let trimmed = last.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty || trimmed.hasPrefix(";") {
                result.removeLast()
            } else {
                break
            }
        }
        return result
    }

    private static func labelLineIndex(_ label: String, inRegion name: String, index: AmigaSourceIndex, sourceLines: [String]) -> Int? {
        guard let region = index.regions[name], let endLine = region.endLine else {
            return nil
        }
        let lowerBound = max(region.startLine - 1, 0)
        let upperBound = min(endLine - 1, sourceLines.count)
        guard lowerBound < upperBound else {
            return nil
        }
        return sourceLines[lowerBound..<upperBound].firstIndex {
            AmigaSourceIndexer.labelName(from: $0) == label
        }
    }

    private static func regionText(_ name: String, in source: String, index: AmigaSourceIndex) -> String? {
        guard let region = index.regions[name], let endLine = region.endLine else { return nil }
        let lines = source.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        let lowerBound = max(region.startLine - 1, 0)
        let upperBound = min(endLine, lines.count)
        guard lowerBound < upperBound else { return "" }
        return lines[lowerBound..<upperBound].joined(separator: "\n")
    }

    private static func sourceOutsideClosedRegions(_ source: String, index: AmigaSourceIndex) -> String {
        let lines = source.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        let closedRanges = index.regions.values.compactMap { region -> Range<Int>? in
            guard let endLine = region.endLine else { return nil }
            let lowerBound = max(region.startLine - 1, 0)
            let upperBound = min(endLine, lines.count)
            guard lowerBound < upperBound else { return nil }
            return lowerBound..<upperBound
        }
        var regionLineIndexes = Set<Int>()
        for range in closedRanges {
            regionLineIndexes.formUnion(range)
        }
        return lines.enumerated()
            .filter { offset, _ in !regionLineIndexes.contains(offset) }
            .map(\.element)
            .joined(separator: "\n")
    }

    private static func semanticPrompt(for manifest: AmigaProgramFamilyManifest, followUpPrompt: String) -> String {
        let familyHints: String
        let hardwareHints: String
        switch manifest.kind {
        case .audioPlayer:
            familyHints = "audio sound mouse input"
            hardwareHints = manifest.requiredHardware
                .filter { $0 != .bitplanes }
                .map(\.rawValue)
                .joined(separator: " ")
        case .effect:
            familyHints = "bitplane screen mouse input"
            hardwareHints = manifest.requiredHardware.map(\.rawValue).joined(separator: " ")
        default:
            familyHints = ""
            hardwareHints = manifest.requiredHardware.map(\.rawValue).joined(separator: " ")
        }
        return (
            manifest.firstShotPromptExamples + [followUpPrompt, hardwareHints, familyHints]
        )
        .joined(separator: " ")
    }

    static func modelPreservationFailures(
        manifest: AmigaProgramFamilyManifest,
        prompt: String,
        previousModel: AmigaProgramModel,
        resultModel: AmigaProgramModel
    ) -> [String] {
        var failures: [String] = []
        if resultModel.id != previousModel.id {
            failures.append("\(manifest.id): follow-up \(prompt) changed model id from \(previousModel.id) to \(resultModel.id).")
        }
        if resultModel.kind != previousModel.kind {
            failures.append("\(manifest.id): follow-up \(prompt) changed model kind from \(previousModel.kind.rawValue) to \(resultModel.kind.rawValue).")
        }
        for previousHardware in previousModel.hardware
            where !resultModel.hardware.contains(previousHardware) {
            failures.append("\(manifest.id): follow-up \(prompt) did not preserve hardware dependency \(previousHardware.rawValue).")
        }
        for resultHardware in resultModel.hardware
            where !previousModel.hardware.contains(resultHardware) &&
            !manifest.requiredHardware.contains(resultHardware) {
            failures.append("\(manifest.id): follow-up \(prompt) added undeclared hardware dependency \(resultHardware.rawValue).")
        }
        for previousExpectation in previousModel.verificationExpectations
            where !resultModel.verificationExpectations.contains(previousExpectation) &&
            !isVerificationExpectationSuperseded(previousExpectation, by: resultModel.verificationExpectations, prompt: prompt) &&
            !isRemovedControlExpectation(previousExpectation, previousModel: previousModel, resultModel: resultModel, prompt: prompt) &&
            !isRetargetedControlExpectation(previousExpectation, previousModel: previousModel, resultModel: resultModel, prompt: prompt) {
            failures.append("\(manifest.id): follow-up \(prompt) did not preserve verification expectation: \(previousExpectation)")
        }
        for previousState in previousModel.stateVariables
            where !resultModel.stateVariables.contains(where: { $0.id == previousState.id && $0.symbol == previousState.symbol }) {
            failures.append("\(manifest.id): follow-up \(prompt) did not preserve state variable \(previousState.id) -> \(previousState.symbol).")
        }
        for resultState in resultModel.stateVariables
            where !previousModel.stateVariables.contains(where: { $0.id == resultState.id && $0.symbol == resultState.symbol }) {
            if isControlBehaviorChangePrompt(prompt),
               ["audio_volume", "playback_state"].contains(resultState.id) {
                continue
            }
            failures.append("\(manifest.id): follow-up \(prompt) added undeclared state variable \(resultState.id) -> \(resultState.symbol).")
        }
        for previousState in previousModel.stateVariables {
            guard let resultState = resultModel.stateVariables.first(where: { $0.id == previousState.id && $0.symbol == previousState.symbol }) else {
                continue
            }
            if resultState.purpose != previousState.purpose {
                failures.append("\(manifest.id): follow-up \(prompt) changed state variable \(previousState.id) purpose.")
            }
            if resultState.initialValue != previousState.initialValue &&
                !isStateInitialValueSuperseded(previousState, by: resultModel.verificationExpectations, prompt: prompt) {
                failures.append("\(manifest.id): follow-up \(prompt) changed state variable \(previousState.id) initial value from \(formattedStateInitialValue(previousState.initialValue)) to \(formattedStateInitialValue(resultState.initialValue)).")
            }
        }
        for previousControl in previousModel.controls
            where !resultModel.controls.contains(where: { $0.id == previousControl.id && $0.action == previousControl.action }) &&
            !isControlRemovalPrompt(prompt) &&
            !isControlBehaviorChangePrompt(prompt) {
            failures.append("\(manifest.id): follow-up \(prompt) did not preserve control \(previousControl.id) -> \(previousControl.action).")
        }
        let addedControls = resultModel.controls.filter { resultControl in
            !previousModel.controls.contains(where: { $0.id == resultControl.id })
        }
        for resultControl in addedControls
            where !isAddedControlSupported(resultControl, by: prompt, manifest: manifest) {
            failures.append("\(manifest.id): follow-up \(prompt) added undeclared control \(resultControl.id) -> \(resultControl.action).")
        }
        for (previousIndex, previousControl) in previousModel.controls.enumerated() {
            guard let resultIndex = resultModel.controls.firstIndex(where: { $0.id == previousControl.id }) else { continue }
            let resultControl = resultModel.controls[resultIndex]
            if resultIndex != previousIndex && !isControlRemovalPrompt(prompt) && !isControlReorderPrompt(prompt) {
                failures.append("\(manifest.id): follow-up \(prompt) changed control \(previousControl.id) slot from \(previousIndex + 1) to \(resultIndex + 1).")
            }
            if resultControl.label != previousControl.label &&
                !isControlLabelSuperseded(previousControl, by: resultModel.verificationExpectations, prompt: prompt) {
                failures.append("\(manifest.id): follow-up \(prompt) changed control \(previousControl.id) label from \(previousControl.label) to \(resultControl.label).")
            }
            if resultControl.bounds != previousControl.bounds &&
                !isControlRemovalPrompt(prompt) &&
                !isControlReorderPrompt(prompt) &&
                !isControlBoundsPrompt(prompt) {
                failures.append("\(manifest.id): follow-up \(prompt) changed control \(previousControl.id) bounds.")
            }
        }
        for previousRoutine in previousModel.routines
            where !resultModel.routines.contains(where: { $0.id == previousRoutine.id && $0.label == previousRoutine.label }) &&
            !isRemovedControlRoutine(previousRoutine, previousModel: previousModel, resultModel: resultModel, prompt: prompt) &&
            !isRetargetedControlRoutine(previousRoutine, previousModel: previousModel, resultModel: resultModel, prompt: prompt) {
            failures.append("\(manifest.id): follow-up \(prompt) did not preserve routine \(previousRoutine.id) -> \(previousRoutine.label).")
        }
        let addedControlActions = Set(addedControls.map(\.action))
        for resultRoutine in resultModel.routines
            where !previousModel.routines.contains(where: { $0.id == resultRoutine.id && $0.label == resultRoutine.label }) &&
            !addedControlActions.contains(resultRoutine.label) &&
            !isRetargetedControlRoutine(resultRoutine, previousModel: resultModel, resultModel: previousModel, prompt: prompt) {
            failures.append("\(manifest.id): follow-up \(prompt) added undeclared routine \(resultRoutine.id) -> \(resultRoutine.label).")
        }
        for previousRoutine in previousModel.routines {
            guard let resultRoutine = resultModel.routines.first(where: { $0.id == previousRoutine.id && $0.label == previousRoutine.label }) else {
                continue
            }
            if resultRoutine.purpose != previousRoutine.purpose {
                failures.append("\(manifest.id): follow-up \(prompt) changed routine \(previousRoutine.id) purpose.")
            }
            if resultRoutine.clobbers != previousRoutine.clobbers {
                failures.append("\(manifest.id): follow-up \(prompt) changed routine \(previousRoutine.id) clobbers.")
            }
            if resultRoutine.calls != previousRoutine.calls &&
                !isRoutineCallMetadataSuperseded(previousRoutine, resultRoutine: resultRoutine, addedControls: addedControls) &&
                !isControlRemovalPrompt(prompt) &&
                !isControlReorderPrompt(prompt) &&
                !isControlBehaviorChangePrompt(prompt) {
                failures.append("\(manifest.id): follow-up \(prompt) changed routine \(previousRoutine.id) calls.")
            }
        }
        return failures
    }

    private static func isRoutineCallMetadataSuperseded(
        _ previousRoutine: AmigaProgramModel.Routine,
        resultRoutine: AmigaProgramModel.Routine,
        addedControls: [AmigaProgramModel.Control]
    ) -> Bool {
        guard previousRoutine.label == "InputDispatch", !addedControls.isEmpty else {
            return false
        }
        let expectedCalls = previousRoutine.calls + addedControls.map(\.action)
        return resultRoutine.calls == expectedCalls
    }

    private static func isAddedControlSupported(_ control: AmigaProgramModel.Control, by prompt: String, manifest: AmigaProgramFamilyManifest) -> Bool {
        let normalizedAction = control.action.lowercased()
        let supportedActionsByFollowUp = [
            "add volume up": ["volumeup"],
            "add volume down": ["volumedown"],
            "add volume controls": ["volumeup", "volumedown"],
            "add pause": ["pause", "pausemod"],
            "add mute": ["mute", "mutemod"]
        ]
        return supportedActionsByFollowUp.contains { supportedFollowUp, action in
            manifest.supportedFollowUps.contains(supportedFollowUp) &&
                smokePromptCovers(prompt, supportedFollowUp: supportedFollowUp) &&
                action.contains(normalizedAction)
        }
    }

    private static func isVerificationExpectationSuperseded(_ previousExpectation: String, by resultExpectations: [String], prompt: String) -> Bool {
        let supersededPrefixes = [
            "Playback period is ",
            "Volume step is ",
            "Initial volume is ",
            "Front buffer color is ",
            "Back buffer color is ",
            "Copper bar count is ",
            "Copper bar spacing is ",
            "Copper bar bounce step is ",
            "Copper palette is ",
            "Top status band is "
        ]
        guard let prefix = supersededPrefixes.first(where: { previousExpectation.hasPrefix($0) }) else {
            return false
        }
        guard promptAllowsExpectationSupersession(prefix, prompt: prompt) else {
            return false
        }
        return resultExpectations.contains { $0.hasPrefix(prefix) }
    }

    private static func isRemovedControlExpectation(
        _ previousExpectation: String,
        previousModel: AmigaProgramModel,
        resultModel: AmigaProgramModel,
        prompt: String
    ) -> Bool {
        guard isControlRemovalPrompt(prompt) else { return false }
        if previousExpectation.hasPrefix("Volume step is "),
           !resultModel.controls.contains(where: { $0.action == "VolumeUp" || $0.action == "VolumeDown" }) {
            return true
        }
        return previousModel.controls
            .filter { previousControl in
                !resultModel.controls.contains { $0.id == previousControl.id && $0.action == previousControl.action }
            }
            .contains { removedControl in
                previousExpectation.contains(removedControl.label) ||
                    previousExpectation.contains(removedControl.action)
            }
    }

    private static func isRemovedControlRoutine(
        _ previousRoutine: AmigaProgramModel.Routine,
        previousModel: AmigaProgramModel,
        resultModel: AmigaProgramModel,
        prompt: String
    ) -> Bool {
        guard isControlRemovalPrompt(prompt) else { return false }
        return previousModel.controls.contains { previousControl in
            previousControl.id == previousRoutine.id &&
                previousControl.action == previousRoutine.label &&
                !resultModel.controls.contains { $0.id == previousControl.id && $0.action == previousControl.action }
        }
    }

    private static func isRetargetedControlExpectation(
        _ previousExpectation: String,
        previousModel: AmigaProgramModel,
        resultModel: AmigaProgramModel,
        prompt: String
    ) -> Bool {
        guard isControlBehaviorChangePrompt(prompt) else { return false }
        if previousExpectation.hasPrefix("Volume step is "),
           !resultModel.controls.contains(where: { $0.action == "VolumeUp" || $0.action == "VolumeDown" }) {
            return true
        }
        return retargetedControls(previousModel: previousModel, resultModel: resultModel).contains { pair in
            previousExpectation.hasSuffix(" dispatches to \(pair.previous.action).") &&
                (
                    resultModel.verificationExpectations.contains("Control \(pair.result.label) dispatches to \(pair.result.action).") ||
                    resultModel.verificationExpectations.contains("Control \(pair.previous.label) dispatches to \(pair.result.action).")
                )
        }
    }

    private static func isRetargetedControlRoutine(
        _ routine: AmigaProgramModel.Routine,
        previousModel: AmigaProgramModel,
        resultModel: AmigaProgramModel,
        prompt: String
    ) -> Bool {
        guard isControlBehaviorChangePrompt(prompt) else { return false }
        return retargetedControls(previousModel: previousModel, resultModel: resultModel).contains { pair in
            routine.id == pair.previous.id &&
                (routine.label == pair.previous.action || routine.label == pair.result.action)
        }
    }

    private static func retargetedControls(
        previousModel: AmigaProgramModel,
        resultModel: AmigaProgramModel
    ) -> [(previous: AmigaProgramModel.Control, result: AmigaProgramModel.Control)] {
        previousModel.controls.compactMap { previousControl in
            guard let resultControl = resultModel.controls.first(where: { $0.id == previousControl.id }),
                  resultControl.action != previousControl.action else {
                return nil
            }
            return (previousControl, resultControl)
        }
    }

    private static func isControlLabelSuperseded(_ previousControl: AmigaProgramModel.Control, by resultExpectations: [String], prompt: String) -> Bool {
        guard smokePromptCovers(prompt, supportedFollowUp: "rename a visible control label") else {
            return false
        }
        return resultExpectations.contains {
            $0.hasPrefix("Control \(previousControl.label) is labeled ") &&
                ($0.hasSuffix(" without changing \(previousControl.action).") || isControlBehaviorChangePrompt(prompt))
        }
    }

    private static func isStateInitialValueSuperseded(_ previousState: AmigaProgramModel.StateVariable, by resultExpectations: [String], prompt: String) -> Bool {
        let expectationPrefix: String?
        switch (previousState.id, previousState.symbol) {
        case ("audio_volume", _), (_, "AudioVolume"):
            expectationPrefix = "Initial volume is "
        case ("front_color", _), (_, "FrontColor"):
            expectationPrefix = "Front buffer color is "
        case ("back_color", _), (_, "BackColor"):
            expectationPrefix = "Back buffer color is "
        case ("bar_count", _), (_, "BarCount"):
            expectationPrefix = "Copper bar count is "
        case ("bar_spacing", _), (_, "BarSpacing"):
            expectationPrefix = "Copper bar spacing is "
        case ("bar_step", _), (_, "BarStep"):
            expectationPrefix = "Copper bar bounce step is "
        case ("status_band_color", _), (_, "StatusBandColor"):
            expectationPrefix = "Top status band is "
        case ("band_color_1", _), (_, "BandColor1"),
             ("band_color_2", _), (_, "BandColor2"),
             ("band_color_3", _), (_, "BandColor3"),
             ("band_color_4", _), (_, "BandColor4"),
             ("band_color_5", _), (_, "BandColor5"),
             ("band_color_6", _), (_, "BandColor6"),
             ("band_color_7", _), (_, "BandColor7"),
             ("band_color_8", _), (_, "BandColor8"):
            expectationPrefix = "Copper palette is "
        default:
            expectationPrefix = nil
        }
        guard let expectationPrefix else {
            return false
        }
        guard promptAllowsExpectationSupersession(expectationPrefix, prompt: prompt) else {
            return false
        }
        return resultExpectations.contains { $0.hasPrefix(expectationPrefix) }
    }

    private static func promptAllowsExpectationSupersession(_ prefix: String, prompt: String) -> Bool {
        switch prefix {
        case "Playback period is ":
            return promptAllowsPlaybackPeriodSupersession(prompt)
        case "Volume step is ":
            return promptAllowsVolumeStepSupersession(prompt)
        case "Initial volume is ":
            return smokePromptCovers(prompt, supportedFollowUp: "set initial volume")
        case "Front buffer color is ":
            return smokePromptCovers(prompt, supportedFollowUp: "set front color")
        case "Back buffer color is ":
            return smokePromptCovers(prompt, supportedFollowUp: "set back color")
        case "Copper bar count is ":
            return smokePromptCovers(prompt, supportedFollowUp: "increase the number of bars to eight")
        case "Copper bar spacing is ":
            return smokePromptCovers(prompt, supportedFollowUp: "change copper bar spacing")
        case "Copper bar bounce step is ":
            return smokePromptCovers(prompt, supportedFollowUp: "make the bars bounce slower")
        case "Copper palette is ":
            return smokePromptCovers(prompt, supportedFollowUp: "change the palette to blue and white") ||
                smokePromptCovers(prompt, supportedFollowUp: "increase the number of bars to eight")
        case "Top status band is ":
            return smokePromptCovers(prompt, supportedFollowUp: "add a top status band without losing the animation")
        default:
            return false
        }
    }

    private static func isControlRemovalPrompt(_ prompt: String) -> Bool {
        smokePromptCovers(prompt, supportedFollowUp: "remove an added control")
    }

    private static func isControlReorderPrompt(_ prompt: String) -> Bool {
        smokePromptCovers(prompt, supportedFollowUp: "reorder controls")
    }

    private static func isControlBehaviorChangePrompt(_ prompt: String) -> Bool {
        let normalized = prompt.lowercased()
        return smokePromptCovers(prompt, supportedFollowUp: "change an added control behavior") ||
            (
                (
                    containsWord("rename", in: normalized) ||
                    containsWord("label", in: normalized) ||
                    containsWord("text", in: normalized) ||
                    containsWord("caption", in: normalized) ||
                    containsWord("title", in: normalized) ||
                    containsWord("say", in: normalized)
                ) &&
                (
                    containsWord("make", in: normalized) ||
                    containsWord("change", in: normalized) ||
                    containsWord("switch", in: normalized) ||
                    containsWord("convert", in: normalized) ||
                    containsWord("turn", in: normalized) ||
                    containsWord("set", in: normalized)
                ) &&
                !containsWord("add", in: normalized) &&
                !(containsWord("remove", in: normalized) || containsWord("delete", in: normalized)) &&
                (
                    containsPhrase("raise volume", in: normalized) ||
                    containsPhrase("increase volume", in: normalized) ||
                    containsPhrase("turn volume up", in: normalized) ||
                    containsPhrase("lower volume", in: normalized) ||
                    containsPhrase("decrease volume", in: normalized) ||
                    containsPhrase("turn volume down", in: normalized)
                )
            )
    }

    private static func isControlBoundsPrompt(_ prompt: String) -> Bool {
        smokePromptCovers(prompt, supportedFollowUp: "change control bounds")
    }

    private static func promptAllowsVolumeStepSupersession(_ prompt: String) -> Bool {
        smokePromptCovers(prompt, supportedFollowUp: "change volume step")
    }

    private static func promptAllowsPlaybackPeriodSupersession(_ prompt: String) -> Bool {
        smokePromptCovers(prompt, supportedFollowUp: "change playback period") ||
            smokePromptCovers(prompt, supportedFollowUp: "change playback note")
    }

    private static func formattedStateInitialValue(_ value: String?) -> String {
        value ?? "nil"
    }
}

struct AmigaSourceRegion: Equatable {
    var name: String
    var startLine: Int
    var endLine: Int?
}

struct AmigaSourceIndex: Equatable {
    var labels: [String]
    var duplicateLabels: [String]
    var regions: [String: AmigaSourceRegion]
    var model: AmigaProgramModel?
}

enum AmigaSourceIndexer {
    static func index(_ source: String) -> AmigaSourceIndex {
        let lines = source.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        var labels: [String] = []
        var labelCounts: [String: Int] = [:]
        var regions: [String: AmigaSourceRegion] = [:]
        var openRegions: [String: Int] = [:]
        var encodedModelLines: [String] = []
        var isReadingModel = false

        for (offset, line) in lines.enumerated() {
            let lineNumber = offset + 1
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if let label = labelName(from: line) {
                labels.append(label)
                labelCounts[label, default: 0] += 1
            }

            if let marker = regionMarker(from: trimmed) {
                switch marker.action {
                case "begin":
                    openRegions[marker.name] = lineNumber
                    if marker.name == AmigaSourceRegionName.model.rawValue {
                        encodedModelLines.removeAll()
                        isReadingModel = true
                    }
                case "end":
                    if let startLine = openRegions.removeValue(forKey: marker.name) {
                        regions[marker.name] = AmigaSourceRegion(name: marker.name, startLine: startLine, endLine: lineNumber)
                    }
                    if marker.name == AmigaSourceRegionName.model.rawValue {
                        isReadingModel = false
                    }
                default:
                    break
                }
                continue
            }

            if isReadingModel, trimmed.hasPrefix(";") {
                encodedModelLines.append(String(trimmed.dropFirst()).trimmingCharacters(in: .whitespaces))
            }
        }

        for (name, startLine) in openRegions {
            regions[name] = AmigaSourceRegion(name: name, startLine: startLine, endLine: nil)
        }

        let duplicateLabels = labelCounts
            .filter { $0.value > 1 }
            .map(\.key)
            .sorted()

        return AmigaSourceIndex(
            labels: labels,
            duplicateLabels: duplicateLabels,
            regions: regions,
            model: decodeModel(from: encodedModelLines)
        )
    }

    static func modelRegion(for model: AmigaProgramModel) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(model)
        let json = String(data: data, encoding: .utf8) ?? "{}"
        let commentedJSON = json
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { "; \($0)" }
            .joined(separator: "\n")

        return """
; @amiga:region model begin
\(commentedJSON)
; @amiga:region model end
"""
    }

    static func labelName(from line: String) -> String? {
        let code = assemblyCodePrefix(beforeCommentIn: line)
        let trimmed = code.trimmingCharacters(in: .whitespaces)
        guard let colonIndex = trimmed.firstIndex(of: ":") else { return nil }
        let label = String(trimmed[..<colonIndex]).trimmingCharacters(in: .whitespaces)
        guard !label.isEmpty, label.range(of: #"^[A-Za-z_.$][A-Za-z0-9_.$]*$"#, options: .regularExpression) != nil else {
            return nil
        }
        return label
    }

    private static func regionMarker(from trimmedLine: String) -> (name: String, action: String)? {
        let prefix = "; @amiga:region "
        guard trimmedLine.hasPrefix(prefix) else { return nil }
        let parts = trimmedLine.dropFirst(prefix.count).split(separator: " ").map(String.init)
        guard parts.count == 2 else { return nil }
        return (parts[0], parts[1])
    }

    private static func decodeModel(from commentedLines: [String]) -> AmigaProgramModel? {
        guard !commentedLines.isEmpty else { return nil }
        let json = commentedLines.joined(separator: "\n")
        guard let data = json.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(AmigaProgramModel.self, from: data)
    }
}

enum AmigaProgramPatchError: LocalizedError, Equatable {
    case missingModel
    case missingRegion(String)
    case missingControl(String)
    case ambiguousControlReference([String])
    case conflictingControlBehaviors([String])
    case duplicateRequestedControl(String)
    case invalidControlLabel(String)
    case unsupportedControl(String)
    case protectedControl(String)
    case protectedControlMove(String)
    case protectedControlBehavior(String)
    case duplicateControl(String)
    case duplicateAction(String, String)
    case duplicateLabel(String)
    case verificationFailed([String])

    var errorDescription: String? {
        switch self {
        case .missingModel:
            return "Source does not contain an Amiga program model region."
        case let .missingRegion(region):
            return "Source does not contain required region: \(region)."
        case let .missingControl(label):
            return "Source does not contain a control named \(label)."
        case let .ambiguousControlReference(labels):
            return "Ambiguous control reference. Specify one of: \(labels.joined(separator: ", "))."
        case let .conflictingControlBehaviors(behaviors):
            return "Conflicting control behaviors in one request. Specify exactly one of: \(behaviors.joined(separator: ", "))."
        case let .duplicateRequestedControl(name):
            return "Duplicate control requested: \(name). Specify each control only once."
        case .invalidControlLabel:
            return "Control labels must be non-blank and cannot contain line breaks or control characters."
        case let .unsupportedControl(label):
            return "Unsupported model-backed control \"\(label)\". Supported controls: Volume Up, Volume Down, Pause, Mute."
        case let .protectedControl(label):
            return "Cannot remove required control \(label). Required controls: Play, Stop."
        case let .protectedControlMove(label):
            return "Cannot move required control \(label). Move added controls relative to Play or Stop instead."
        case let .protectedControlBehavior(label):
            return "Cannot change required control \(label) behavior. Change added controls instead."
        case let .duplicateControl(id):
            return "A control with id \(id) already exists."
        case let .duplicateAction(action, label):
            return "A control that dispatches to \(action) already exists: \(label)."
        case let .duplicateLabel(label):
            return "A label named \(label) already exists."
        case let .verificationFailed(failures):
            return "Patched Amiga program failed verification: \(failures.joined(separator: "; "))"
        }
    }
}

struct AmigaProgramPatchResult: Equatable {
    var source: String
    var model: AmigaProgramModel
    var changedRegions: [String]
}

enum AmigaProgramControlPlacement: Equatable {
    case before
    case after
}

enum AmigaProgramFollowUpPatchOutcome: Equatable {
    case notRecognized
    case patched(AmigaProgramPatchResult)
    case rejected([String])
}

enum AmigaProgramPatcher {
    static func addControl(label: String, action: String, to source: String) throws -> AmigaProgramPatchResult {
        let index = AmigaSourceIndexer.index(source)
        guard var model = index.model else { throw AmigaProgramPatchError.missingModel }
        try requireMODControlsModel(model)
        try requireVerifiedCurrentSource(source)
        let trimmedLabel = label.trimmingCharacters(in: .whitespacesAndNewlines)
        try requireValidControlLabel(trimmedLabel)

        let baseControlID = stableID(from: trimmedLabel)
        let actionLabel = stableLabel(from: action)

        if let existingControl = model.controls.first(where: { $0.id == baseControlID }),
           existingControl.label.caseInsensitiveCompare(trimmedLabel) == .orderedSame {
            throw AmigaProgramPatchError.duplicateControl(baseControlID)
        }
        if let existingControl = model.controls.first(where: { $0.action == actionLabel }) {
            throw AmigaProgramPatchError.duplicateAction(actionLabel, existingControl.label)
        }
        if let existingControl = model.controls.first(where: { $0.label.caseInsensitiveCompare(trimmedLabel) == .orderedSame }) {
            throw AmigaProgramPatchError.duplicateLabel(existingControl.label)
        }
        let controlID = uniqueControlID(basedOn: baseControlID, existingControls: model.controls)
        guard !index.labels.contains(actionLabel) else {
            throw AmigaProgramPatchError.duplicateLabel(actionLabel)
        }
        let patchSpec = try controlPatchSpec(label: trimmedLabel, controlID: controlID, actionLabel: actionLabel)

        try requireClosedRegion(AmigaSourceRegionName.model.rawValue, in: index)
        try requireClosedRegion(AmigaSourceRegionName.controls.rawValue, in: index)
        try requireClosedRegion(AmigaSourceRegionName.drawControls.rawValue, in: index)
        try requireClosedRegion(AmigaSourceRegionName.hitTest.rawValue, in: index)
        try requireClosedRegion(AmigaSourceRegionName.inputDispatch.rawValue, in: index)
        try requireClosedRegion(AmigaSourceRegionName.routines.rawValue, in: index)
        try requireClosedRegion(AmigaSourceRegionName.state.rawValue, in: index)
        try requireClosedRegion(AmigaSourceRegionName.chipData.rawValue, in: index)

        let controlSlot = model.controls.count + 1
        let controlBounds = defaultBounds(forControlAt: controlSlot)
        model.controls.append(AmigaProgramModel.Control(id: controlID, label: trimmedLabel, action: actionLabel, bounds: controlBounds))
        model.routines.append(AmigaProgramModel.Routine(id: controlID, label: actionLabel, purpose: patchSpec.purpose))
        if let dispatchRoutineIndex = model.routines.firstIndex(where: { $0.id == "dispatch" && $0.label == "InputDispatch" }),
           !model.routines[dispatchRoutineIndex].calls.contains(actionLabel) {
            model.routines[dispatchRoutineIndex].calls.append(actionLabel)
        }
        for stateVariable in controlSelectionStateVariables() where !model.stateVariables.contains(where: { $0.id == stateVariable.id }) {
            model.stateVariables.append(stateVariable)
        }
        for stateVariable in patchSpec.stateVariables where !model.stateVariables.contains(where: { $0.id == stateVariable.id }) {
            model.stateVariables.append(stateVariable)
        }
        model.verificationExpectations.append("Control \(trimmedLabel) dispatches to \(actionLabel).")

        var patched = source
        patched = try replaceRegion(AmigaSourceRegionName.model.rawValue, in: patched, with: AmigaSourceIndexer.modelRegion(for: model))
        patched = try insertBeforeRegionEnd(AmigaSourceRegionName.controls.rawValue, in: patched, lines: [
            controlMarkerLine(id: controlID, label: trimmedLabel, action: actionLabel, bounds: controlBounds)
        ])
        patched = try insertBeforeReturn(afterLabel: "DrawControls", inRegion: AmigaSourceRegionName.drawControls.rawValue, source: patched, lines: drawControlLines(
            id: controlID,
            slot: controlSlot,
            bounds: controlBounds
        ))
        patched = try insertBeforeLabel(".doneHitTest", inRegion: AmigaSourceRegionName.hitTest.rawValue, source: patched, lines: hitTestLines(
            id: controlID,
            slot: controlSlot,
            bounds: controlBounds
        ))
        patched = try insertBeforeLabelOrRegionReturn(".doneDispatch", inRegion: AmigaSourceRegionName.inputDispatch.rawValue, source: patched, lines: [
            #"            ; @amiga:dispatch \#(controlID) -> \#(actionLabel)"#,
            "            cmp.w      #\(controlSlot),d0",
            "            bne.s      .skip_\(controlID)",
            "            bsr        \(actionLabel)",
            ".skip_\(controlID):"
        ])
        let stateLinesToEnsure = controlSelectionStateLines() + patchSpec.stateLines
        var didChangeStateRegion = false
        if !stateLinesToEnsure.isEmpty {
            let existingSource = patched
            let stateLines = stateLinesToEnsure.filter { stateLine in
                let symbol = stateLine.split(separator: ":").first.map(String.init) ?? stateLine
                return !hasLabelDefinition(symbol, in: existingSource)
            }
            if !stateLines.isEmpty {
                patched = try insertBeforeRegionEnd(AmigaSourceRegionName.state.rawValue, in: patched, lines: stateLines)
                didChangeStateRegion = true
            }
        }
        patched = try insertBeforeRegionEnd(AmigaSourceRegionName.routines.rawValue, in: patched, lines: [""] + patchSpec.routineLines)
        patched = try insertBeforeRegionEnd(AmigaSourceRegionName.chipData.rawValue, in: patched, lines: controlRectDataLines(
            id: controlID,
            label: trimmedLabel,
            slot: controlSlot,
            bounds: controlBounds
        ))

        return try verifiedPatchResult(AmigaProgramPatchResult(
            source: patched,
            model: model,
            changedRegions: [
                AmigaSourceRegionName.model.rawValue,
                AmigaSourceRegionName.controls.rawValue,
                AmigaSourceRegionName.drawControls.rawValue,
                AmigaSourceRegionName.hitTest.rawValue,
                AmigaSourceRegionName.inputDispatch.rawValue,
                AmigaSourceRegionName.routines.rawValue,
                AmigaSourceRegionName.chipData.rawValue
            ] + (didChangeStateRegion ? [AmigaSourceRegionName.state.rawValue] : [])
        ))
    }

    static func updateVolumeStep(_ step: Int, in source: String) throws -> AmigaProgramPatchResult {
        let index = AmigaSourceIndexer.index(source)
        guard var model = index.model else { throw AmigaProgramPatchError.missingModel }
        try requireMODControlsModel(model)
        try requireVerifiedCurrentSource(source)
        try requireClosedRegion(AmigaSourceRegionName.model.rawValue, in: index)
        try requireClosedRegion(AmigaSourceRegionName.routines.rawValue, in: index)
        let hasVolumeUp = model.controls.contains { $0.action == "VolumeUp" }
        let hasVolumeDown = model.controls.contains { $0.action == "VolumeDown" }
        guard hasVolumeUp || hasVolumeDown else {
            throw AmigaProgramPatchError.missingRegion("volume controls")
        }

        let clampedStep = max(1, min(step, 64))
        var patched = source
        if hasVolumeUp {
            patched = try replaceInstructionImmediate(
                pattern: #"(?im)^(\s*)(?:addq|add)\.w\s+#(?:\d+|\$[0-9a-f]+|0x[0-9a-f]+)\s*,\s*d0\b"#,
                replacement: "add.w      #\(clampedStep),d0",
                inRoutine: "VolumeUp",
                source: patched
            )
        }
        if hasVolumeDown {
            patched = try replaceInstructionImmediate(
                pattern: #"(?im)^(\s*)(?:subq|sub)\.w\s+#(?:\d+|\$[0-9a-f]+|0x[0-9a-f]+)\s*,\s*d0\b"#,
                replacement: "sub.w      #\(clampedStep),d0",
                inRoutine: "VolumeDown",
                source: patched
            )
        }
        let changedRoutine = patched != source

        model.verificationExpectations.removeAll { $0.hasPrefix("Volume step is ") }
        model.verificationExpectations.append("Volume step is \(clampedStep).")
        patched = try replaceRegion(AmigaSourceRegionName.model.rawValue, in: patched, with: AmigaSourceIndexer.modelRegion(for: model))

        guard patched != source else {
            return try verifiedPatchResult(AmigaProgramPatchResult(source: source, model: model, changedRegions: []))
        }

        var changedRegions = [AmigaSourceRegionName.model.rawValue]
        if changedRoutine {
            changedRegions.append(AmigaSourceRegionName.routines.rawValue)
        }
        return try verifiedPatchResult(AmigaProgramPatchResult(
            source: patched,
            model: model,
            changedRegions: changedRegions
        ))
    }

    static func addIntuitionGadget(label: String, to source: String) throws -> AmigaProgramPatchResult {
        let index = AmigaSourceIndexer.index(source)
        guard var model = index.model else { throw AmigaProgramPatchError.missingModel }
        try requireIntuitionWindowToolModel(model)
        try requireVerifiedCurrentSource(source)

        let trimmedLabel = label.trimmingCharacters(in: .whitespacesAndNewlines)
        try requireValidControlLabel(trimmedLabel)
        let baseID = stableID(from: trimmedLabel)
        if let existing = model.controls.first(where: { $0.id == baseID || $0.label.caseInsensitiveCompare(trimmedLabel) == .orderedSame }) {
            throw AmigaProgramPatchError.duplicateControl(existing.id)
        }
        let controlID = uniqueControlID(basedOn: baseID, existingControls: model.controls)
        let actionLabel = "\(stableLabel(from: trimmedLabel))Action"
        if model.controls.contains(where: { $0.action == actionLabel }) {
            throw AmigaProgramPatchError.duplicateAction(actionLabel, trimmedLabel)
        }
        let slot = model.controls.count
        let y = model.controls.map { $0.bounds?.y ?? 18 }.max() ?? 18
        let bounds = AmigaProgramModel.Bounds(x: 14 + slot * 90, y: y, width: 78, height: 18)
        model.controls.append(AmigaProgramModel.Control(id: controlID, label: trimmedLabel, action: actionLabel, bounds: bounds))
        model.routines.append(AmigaProgramModel.Routine(id: controlID, label: actionLabel, purpose: "Records that the \(trimmedLabel) gadget was activated."))
        if let dispatchIndex = model.routines.firstIndex(where: { $0.id == "dispatch" }),
           !model.routines[dispatchIndex].calls.contains(actionLabel) {
            model.routines[dispatchIndex].calls.append(actionLabel)
        }
        model.verificationExpectations.append("Control \(trimmedLabel) dispatches to \(actionLabel).")

        return try verifiedIntuitionPatchResult(model: model, changedRegions: [
            AmigaSourceRegionName.model.rawValue,
            AmigaSourceRegionName.controls.rawValue,
            AmigaSourceRegionName.inputDispatch.rawValue,
            AmigaSourceRegionName.routines.rawValue,
            AmigaSourceRegionName.chipData.rawValue
        ])
    }

    static func renameIntuitionGadget(currentLabel: String, newLabel: String, in source: String) throws -> AmigaProgramPatchResult {
        let index = AmigaSourceIndexer.index(source)
        guard var model = index.model else { throw AmigaProgramPatchError.missingModel }
        try requireIntuitionWindowToolModel(model)
        try requireVerifiedCurrentSource(source)

        let trimmedNewLabel = newLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        try requireValidControlLabel(trimmedNewLabel)
        guard let controlIndex = controlIndex(matching: currentLabel, in: model.controls) else {
            throw AmigaProgramPatchError.missingControl(currentLabel)
        }
        if model.controls.enumerated().contains(where: { offset, control in
            offset != controlIndex && control.label.caseInsensitiveCompare(trimmedNewLabel) == .orderedSame
        }) {
            throw AmigaProgramPatchError.duplicateLabel(trimmedNewLabel)
        }
        let previousLabel = model.controls[controlIndex].label
        model.controls[controlIndex].label = trimmedNewLabel
        model.verificationExpectations.removeAll { $0.contains("Control \(previousLabel) dispatches") }
        model.verificationExpectations.append("Control \(trimmedNewLabel) dispatches to \(model.controls[controlIndex].action).")

        return try verifiedIntuitionPatchResult(model: model, changedRegions: [
            AmigaSourceRegionName.model.rawValue,
            AmigaSourceRegionName.controls.rawValue,
            AmigaSourceRegionName.chipData.rawValue
        ])
    }

    static func moveIntuitionButtonsToBottom(in source: String) throws -> AmigaProgramPatchResult {
        let index = AmigaSourceIndexer.index(source)
        guard var model = index.model else { throw AmigaProgramPatchError.missingModel }
        try requireIntuitionWindowToolModel(model)
        try requireVerifiedCurrentSource(source)

        for offset in model.controls.indices {
            model.controls[offset].bounds = AmigaProgramModel.Bounds(x: 14 + offset * 90, y: 62, width: 78, height: 18)
        }
        model.verificationExpectations.removeAll { $0 == "Modeled gadgets are placed on the bottom row." }
        model.verificationExpectations.append("Modeled gadgets are placed on the bottom row.")

        return try verifiedIntuitionPatchResult(model: model, changedRegions: [
            AmigaSourceRegionName.model.rawValue,
            AmigaSourceRegionName.controls.rawValue,
            AmigaSourceRegionName.chipData.rawValue
        ])
    }

    static func addIntuitionStatusText(in source: String) throws -> AmigaProgramPatchResult {
        let index = AmigaSourceIndexer.index(source)
        guard var model = index.model else { throw AmigaProgramPatchError.missingModel }
        try requireIntuitionWindowToolModel(model)
        try requireVerifiedCurrentSource(source)

        if !model.stateVariables.contains(where: { $0.id == "status_text" }) {
            model.stateVariables.append(AmigaProgramModel.StateVariable(
                id: "status_text",
                symbol: "StatusTextEnabled",
                purpose: "One when the generated Intuition text field is present.",
                initialValue: "1"
            ))
        }
        model.verificationExpectations.removeAll { $0 == "Status text field is present without changing cleanup." }
        model.verificationExpectations.append("Status text field is present without changing cleanup.")

        return try verifiedIntuitionPatchResult(model: model, changedRegions: [
            AmigaSourceRegionName.model.rawValue,
            AmigaSourceRegionName.state.rawValue,
            AmigaSourceRegionName.chipData.rawValue
        ])
    }

    static func updateCleanTakeoverPaletteToGreen(in source: String) throws -> AmigaProgramPatchResult {
        let index = AmigaSourceIndexer.index(source)
        guard var model = index.model else { throw AmigaProgramPatchError.missingModel }
        try requireCleanTakeoverRestoreModel(model)
        try requireVerifiedCurrentSource(source)

        try updateStateInitialValue(symbol: "PaletteMode", id: "palette_mode", value: "1", model: &model)
        model.verificationExpectations.removeAll { $0 == "Cycling palette uses green tones." }
        model.verificationExpectations.append("Cycling palette uses green tones.")

        return try verifiedCleanTakeoverPatchResult(model: model, changedRegions: [
            AmigaSourceRegionName.model.rawValue,
            AmigaSourceRegionName.state.rawValue,
            AmigaSourceRegionName.chipData.rawValue
        ])
    }

    static func enableCleanTakeoverCopperSplit(in source: String) throws -> AmigaProgramPatchResult {
        let index = AmigaSourceIndexer.index(source)
        guard var model = index.model else { throw AmigaProgramPatchError.missingModel }
        try requireCleanTakeoverRestoreModel(model)
        try requireVerifiedCurrentSource(source)

        try updateStateInitialValue(symbol: "CopperSplitEnabled", id: "copper_split_enabled", value: "1", model: &model)
        model.verificationExpectations.removeAll { $0 == "Copper split is enabled while preserving restore." }
        model.verificationExpectations.append("Copper split is enabled while preserving restore.")

        return try verifiedCleanTakeoverPatchResult(model: model, changedRegions: [
            AmigaSourceRegionName.model.rawValue,
            AmigaSourceRegionName.state.rawValue,
            AmigaSourceRegionName.chipData.rawValue
        ])
    }

    static func slowCleanTakeoverEveryOtherVBlank(in source: String) throws -> AmigaProgramPatchResult {
        let index = AmigaSourceIndexer.index(source)
        guard var model = index.model else { throw AmigaProgramPatchError.missingModel }
        try requireCleanTakeoverRestoreModel(model)
        try requireVerifiedCurrentSource(source)

        try updateStateInitialValue(symbol: "VBlankDivider", id: "vblank_divider", value: "2", model: &model)
        model.verificationExpectations.removeAll { $0 == "Color cycling updates every other vblank." }
        model.verificationExpectations.append("Color cycling updates every other vblank.")

        return try verifiedCleanTakeoverPatchResult(model: model, changedRegions: [
            AmigaSourceRegionName.model.rawValue,
            AmigaSourceRegionName.state.rawValue
        ])
    }

    static func enableCleanTakeoverRightMouseRestore(in source: String) throws -> AmigaProgramPatchResult {
        let index = AmigaSourceIndexer.index(source)
        guard var model = index.model else { throw AmigaProgramPatchError.missingModel }
        try requireCleanTakeoverRestoreModel(model)
        try requireVerifiedCurrentSource(source)

        try updateStateInitialValue(symbol: "RightMouseRestoreEnabled", id: "right_mouse_restore_enabled", value: "1", model: &model)
        model.verificationExpectations.removeAll { $0 == "Right mouse also routes through RestoreSystem." }
        model.verificationExpectations.append("Right mouse also routes through RestoreSystem.")

        return try verifiedCleanTakeoverPatchResult(model: model, changedRegions: [
            AmigaSourceRegionName.model.rawValue,
            AmigaSourceRegionName.hitTest.rawValue,
            AmigaSourceRegionName.state.rawValue
        ])
    }

    static func updatePlaybackPeriod(_ period: Int, in source: String) throws -> AmigaProgramPatchResult {
        let index = AmigaSourceIndexer.index(source)
        guard var model = index.model else { throw AmigaProgramPatchError.missingModel }
        try requireMODControlsModel(model)
        try requireVerifiedCurrentSource(source)
        try requireClosedRegion(AmigaSourceRegionName.model.rawValue, in: index)
        try requireClosedRegion(AmigaSourceRegionName.routines.rawValue, in: index)
        guard model.controls.contains(where: { $0.action == "PlayMOD" }) else {
            throw AmigaProgramPatchError.missingRegion("playback control")
        }

        let clampedPeriod = max(113, min(period, 856))
        var patched = source
        patched = try replaceInstructionImmediate(
            pattern: #"(?im)^(\s*)move\.w\s+#(?:\d+|\$[0-9a-f]+|0x[0-9a-f]+)\s*,\s*\$a6\(a6\)(?:\s*;[^\n]*)?$"#,
            replacement: "move.w     #\(clampedPeriod),$a6(a6)         ; AUD0PER",
            inRoutine: "PlayMOD",
            source: patched
        )
        let changedRoutine = patched != source

        model.verificationExpectations.removeAll { $0.hasPrefix("Playback period is ") }
        model.verificationExpectations.append("Playback period is \(clampedPeriod).")
        patched = try replaceRegion(AmigaSourceRegionName.model.rawValue, in: patched, with: AmigaSourceIndexer.modelRegion(for: model))

        guard patched != source else {
            return try verifiedPatchResult(AmigaProgramPatchResult(source: source, model: model, changedRegions: []))
        }

        var changedRegions = [AmigaSourceRegionName.model.rawValue]
        if changedRoutine {
            changedRegions.append(AmigaSourceRegionName.routines.rawValue)
        }
        return try verifiedPatchResult(AmigaProgramPatchResult(
            source: patched,
            model: model,
            changedRegions: changedRegions
        ))
    }

    static func updateInitialVolume(_ volume: Int, in source: String) throws -> AmigaProgramPatchResult {
        let index = AmigaSourceIndexer.index(source)
        guard var model = index.model else { throw AmigaProgramPatchError.missingModel }
        try requireMODControlsModel(model)
        try requireVerifiedCurrentSource(source)
        try requireClosedRegion(AmigaSourceRegionName.model.rawValue, in: index)
        try requireClosedRegion(AmigaSourceRegionName.state.rawValue, in: index)
        guard let stateIndex = model.stateVariables.firstIndex(where: { $0.id == "audio_volume" || $0.symbol == "AudioVolume" }) else {
            throw AmigaProgramPatchError.missingRegion("audio volume state")
        }

        let clampedVolume = max(0, min(volume, 64))
        model.stateVariables[stateIndex].initialValue = "\(clampedVolume)"
        model.verificationExpectations.removeAll { $0.hasPrefix("Initial volume is ") }
        model.verificationExpectations.append("Initial volume is \(clampedVolume).")

        var patched = source
        patched = try replaceRegion(AmigaSourceRegionName.model.rawValue, in: patched, with: AmigaSourceIndexer.modelRegion(for: model))
        let modelOnlyPatched = patched
        patched = try replaceStateWordLine(label: "AudioVolume", inRegion: AmigaSourceRegionName.state.rawValue, source: patched, value: clampedVolume)
        let changedState = patched != modelOnlyPatched

        guard patched != source else {
            return try verifiedPatchResult(AmigaProgramPatchResult(source: source, model: model, changedRegions: []))
        }

        var changedRegions = [AmigaSourceRegionName.model.rawValue]
        if changedState {
            changedRegions.append(AmigaSourceRegionName.state.rawValue)
        }
        return try verifiedPatchResult(AmigaProgramPatchResult(
            source: patched,
            model: model,
            changedRegions: changedRegions
        ))
    }

    static func updateBitplaneColor(role: String, color: String, in source: String) throws -> AmigaProgramPatchResult {
        let index = AmigaSourceIndexer.index(source)
        guard var model = index.model else { throw AmigaProgramPatchError.missingModel }
        guard model.id == AmigaProgramFamilyRegistry.doubleBufferedBitplane.id,
              model.kind == AmigaProgramFamilyRegistry.doubleBufferedBitplane.kind else {
            throw AmigaProgramPatchError.missingRegion("double-buffered bitplane model")
        }
        try requireVerifiedCurrentSource(source)
        try requireClosedRegion(AmigaSourceRegionName.model.rawValue, in: index)
        try requireClosedRegion(AmigaSourceRegionName.state.rawValue, in: index)

        let normalizedRole = role.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let stateID: String
        let symbol: String
        let bufferName: String
        if normalizedRole == "front" {
            stateID = "front_color"
            symbol = "FrontColor"
            bufferName = "BufferA"
        } else if normalizedRole == "back" {
            stateID = "back_color"
            symbol = "BackColor"
            bufferName = "BufferB"
        } else {
            throw AmigaProgramPatchError.missingRegion("bitplane color role")
        }

        let normalizedColor = color.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard let value = AmigaProgramTemplate.colorValue(named: normalizedColor) else {
            throw AmigaProgramPatchError.missingRegion("supported color")
        }
        guard let stateIndex = model.stateVariables.firstIndex(where: { $0.id == stateID || $0.symbol == symbol }) else {
            throw AmigaProgramPatchError.missingRegion("\(symbol) state")
        }

        model.stateVariables[stateIndex].initialValue = value
        model.verificationExpectations.removeAll { $0.hasPrefix("\(normalizedRole.capitalized) buffer color is ") }
        model.verificationExpectations.append("\(normalizedRole.capitalized) buffer color is \(normalizedColor).")

        var patched = source
        patched = try replaceRegion(AmigaSourceRegionName.model.rawValue, in: patched, with: AmigaSourceIndexer.modelRegion(for: model))
        patched = try replaceStateWordLine(
            label: symbol,
            inRegion: AmigaSourceRegionName.state.rawValue,
            source: patched,
            value: value,
            suffix: "; \(normalizedColor) foreground for \(bufferName)"
        )
        let modelOnlyPatched = try replaceRegion(AmigaSourceRegionName.model.rawValue, in: source, with: AmigaSourceIndexer.modelRegion(for: model))
        let changedState = patched != modelOnlyPatched

        guard patched != source else {
            return try verifiedPatchResult(AmigaProgramPatchResult(source: source, model: model, changedRegions: []))
        }

        var changedRegions = [AmigaSourceRegionName.model.rawValue]
        if changedState {
            changedRegions.append(AmigaSourceRegionName.state.rawValue)
        }
        return try verifiedPatchResult(AmigaProgramPatchResult(
            source: patched,
            model: model,
            changedRegions: changedRegions
        ))
    }

    static func moveDoubleBufferedSpriteDownward(in source: String) throws -> AmigaProgramPatchResult {
        let index = AmigaSourceIndexer.index(source)
        guard var model = index.model else { throw AmigaProgramPatchError.missingModel }
        try requireDoubleBufferedBitplaneModel(model)
        try requireVerifiedCurrentSource(source)
        try requireClosedRegion(AmigaSourceRegionName.model.rawValue, in: index)
        try requireClosedRegion(AmigaSourceRegionName.chipData.rawValue, in: index)

        model.verificationExpectations.removeAll { $0.hasPrefix("Sprite overlay vertical offset is ") }
        model.verificationExpectations.append("Sprite overlay vertical offset is 16 pixels downward.")

        var patched = source
        patched = try replaceRegion(AmigaSourceRegionName.model.rawValue, in: patched, with: AmigaSourceIndexer.modelRegion(for: model))
        let beforeSprite = patched
        patched = patched.replacingOccurrences(
            of: "            dc.w       $4060,$4800",
            with: "            dc.w       $5060,$5800          ; sprite moved 16 pixels downward"
        )
        guard patched != beforeSprite else {
            throw AmigaProgramPatchError.missingRegion("sprite vertical control words")
        }
        return try doubleBufferedBitplaneVerifiedPatchResult(
            source: source,
            patched: patched,
            model: model,
            changedRegions: [AmigaSourceRegionName.model.rawValue, AmigaSourceRegionName.chipData.rawValue]
        )
    }

    static func updateDoubleBufferedVBlankWaits(_ count: Int, in source: String) throws -> AmigaProgramPatchResult {
        let index = AmigaSourceIndexer.index(source)
        guard var model = index.model else { throw AmigaProgramPatchError.missingModel }
        try requireDoubleBufferedBitplaneModel(model)
        try requireVerifiedCurrentSource(source)
        try requireClosedRegion(AmigaSourceRegionName.model.rawValue, in: index)

        guard count == 2 else {
            throw AmigaProgramPatchError.missingRegion("supported double-buffered vblank wait count")
        }
        model.verificationExpectations.removeAll { $0.hasPrefix("Animation waits ") }
        model.verificationExpectations.append("Animation waits 2 vblanks per buffer swap.")

        var patched = source
        patched = try replaceRegion(AmigaSourceRegionName.model.rawValue, in: patched, with: AmigaSourceIndexer.modelRegion(for: model))
        let beforeLoopPatch = patched
        patched = patched.replacingOccurrences(
            of: "            bsr.s      WaitVBlank\n            tst.b      d2",
            with: "            bsr.s      WaitVBlank\n            bsr.s      WaitVBlank          ; second vblank wait for slower animation\n            tst.b      d2"
        )
        guard patched != beforeLoopPatch else {
            throw AmigaProgramPatchError.missingRegion("double-buffered vblank pacing call")
        }
        return try doubleBufferedBitplaneVerifiedPatchResult(
            source: source,
            patched: patched,
            model: model,
            changedRegions: [AmigaSourceRegionName.model.rawValue, AmigaSourceRegionName.hitTest.rawValue]
        )
    }

    static func updateDoubleBufferedCopperAccentColor(_ color: String, in source: String) throws -> AmigaProgramPatchResult {
        let index = AmigaSourceIndexer.index(source)
        guard var model = index.model else { throw AmigaProgramPatchError.missingModel }
        try requireDoubleBufferedBitplaneModel(model)
        try requireVerifiedCurrentSource(source)
        try requireClosedRegion(AmigaSourceRegionName.model.rawValue, in: index)
        try requireClosedRegion(AmigaSourceRegionName.chipData.rawValue, in: index)

        let normalizedColor = color.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard let value = AmigaProgramTemplate.colorValue(named: normalizedColor) else {
            throw AmigaProgramPatchError.missingRegion("supported copper accent color")
        }
        model.verificationExpectations.removeAll { $0.hasPrefix("Copper accent color is ") }
        model.verificationExpectations.append("Copper accent color is \(normalizedColor).")

        var patched = source
        patched = try replaceRegion(AmigaSourceRegionName.model.rawValue, in: patched, with: AmigaSourceIndexer.modelRegion(for: model))
        let beforeStartup = patched
        patched = patched.replacingOccurrences(
            of: "            move.w     #$0000,$180(a6)",
            with: "            move.w     #\(value),$180(a6)       ; \(normalizedColor) copper accent"
        )
        guard patched != beforeStartup else {
            throw AmigaProgramPatchError.missingRegion("startup copper accent color")
        }
        let beforeCopperList = patched
        patched = patched.replacingOccurrences(
            of: "            dc.w       $0180,$0000",
            with: "            dc.w       $0180,\(value)          ; \(normalizedColor) copper accent"
        )
        guard patched != beforeCopperList else {
            throw AmigaProgramPatchError.missingRegion("copper list accent color")
        }
        return try doubleBufferedBitplaneVerifiedPatchResult(
            source: source,
            patched: patched,
            model: model,
            changedRegions: [AmigaSourceRegionName.model.rawValue, AmigaSourceRegionName.chipData.rawValue]
        )
    }

    static func updateMouseSpriteFollowerOffset(_ offset: Int, in source: String) throws -> AmigaProgramPatchResult {
        let index = AmigaSourceIndexer.index(source)
        guard var model = index.model else { throw AmigaProgramPatchError.missingModel }
        try requireMouseSpriteMultiplexModel(model)
        try requireVerifiedCurrentSource(source)
        try requireClosedRegion(AmigaSourceRegionName.model.rawValue, in: index)
        try requireClosedRegion(AmigaSourceRegionName.state.rawValue, in: index)

        let boundedOffset = min(max(offset, 0), 96)
        try updateStateInitialValue(symbol: "FollowerXOffset", id: "follower_x_offset", value: "\(boundedOffset)", model: &model)
        model.verificationExpectations.removeAll { $0.hasPrefix("Follower sprite horizontal offset is ") }
        model.verificationExpectations.append("Follower sprite horizontal offset is \(boundedOffset) pixels.")

        var patched = source
        patched = try replaceRegion(AmigaSourceRegionName.model.rawValue, in: patched, with: AmigaSourceIndexer.modelRegion(for: model))
        patched = try replaceStateWordLine(
            label: "FollowerXOffset",
            inRegion: AmigaSourceRegionName.state.rawValue,
            source: patched,
            value: boundedOffset
        )
        return try mouseSpriteVerifiedPatchResult(source: source, patched: patched, model: model)
    }

    static func updateMouseSpriteHorizontalWrapping(enabled: Bool, in source: String) throws -> AmigaProgramPatchResult {
        let index = AmigaSourceIndexer.index(source)
        guard var model = index.model else { throw AmigaProgramPatchError.missingModel }
        try requireMouseSpriteMultiplexModel(model)
        try requireVerifiedCurrentSource(source)
        try requireClosedRegion(AmigaSourceRegionName.model.rawValue, in: index)
        try requireClosedRegion(AmigaSourceRegionName.state.rawValue, in: index)

        let value = enabled ? 1 : 0
        try updateStateInitialValue(symbol: "FollowerWrapEnabled", id: "follower_wrap_enabled", value: "\(value)", model: &model)
        model.verificationExpectations.removeAll { $0.hasPrefix("Follower horizontal wrapping is ") }
        model.verificationExpectations.append("Follower horizontal wrapping is \(enabled ? "enabled" : "disabled").")

        var patched = source
        patched = try replaceRegion(AmigaSourceRegionName.model.rawValue, in: patched, with: AmigaSourceIndexer.modelRegion(for: model))
        patched = try replaceStateWordLine(
            label: "FollowerWrapEnabled",
            inRegion: AmigaSourceRegionName.state.rawValue,
            source: patched,
            value: value
        )
        return try mouseSpriteVerifiedPatchResult(source: source, patched: patched, model: model)
    }

    static func updateMouseSpriteFollowerLag(enabled: Bool, in source: String) throws -> AmigaProgramPatchResult {
        let index = AmigaSourceIndexer.index(source)
        guard var model = index.model else { throw AmigaProgramPatchError.missingModel }
        try requireMouseSpriteMultiplexModel(model)
        try requireVerifiedCurrentSource(source)
        try requireClosedRegion(AmigaSourceRegionName.model.rawValue, in: index)
        try requireClosedRegion(AmigaSourceRegionName.state.rawValue, in: index)

        let value = enabled ? 1 : 0
        try updateStateInitialValue(symbol: "FollowerLagEnabled", id: "follower_lag_enabled", value: "\(value)", model: &model)
        model.verificationExpectations.removeAll { $0.hasPrefix("Follower one-frame lag is ") }
        model.verificationExpectations.append("Follower one-frame lag is \(enabled ? "enabled" : "disabled").")

        var patched = source
        patched = try replaceRegion(AmigaSourceRegionName.model.rawValue, in: patched, with: AmigaSourceIndexer.modelRegion(for: model))
        patched = try replaceStateWordLine(
            label: "FollowerLagEnabled",
            inRegion: AmigaSourceRegionName.state.rawValue,
            source: patched,
            value: value
        )
        return try mouseSpriteVerifiedPatchResult(source: source, patched: patched, model: model)
    }

    static func updateMouseSpriteColor(_ color: String, in source: String) throws -> AmigaProgramPatchResult {
        let index = AmigaSourceIndexer.index(source)
        guard var model = index.model else { throw AmigaProgramPatchError.missingModel }
        try requireMouseSpriteMultiplexModel(model)
        try requireVerifiedCurrentSource(source)
        try requireClosedRegion(AmigaSourceRegionName.model.rawValue, in: index)
        try requireClosedRegion(AmigaSourceRegionName.state.rawValue, in: index)

        let normalizedColor = color.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard let value = AmigaProgramTemplate.colorValue(named: normalizedColor) else {
            throw AmigaProgramPatchError.missingRegion("supported sprite color")
        }
        try updateStateInitialValue(symbol: "SpriteColor1", id: "sprite_color", value: value, model: &model)
        try updateStateInitialValue(symbol: "SpriteColor2", id: "sprite_color_2", value: value, model: &model)
        try updateStateInitialValue(symbol: "SpriteColor3", id: "sprite_color_3", value: value, model: &model)
        model.verificationExpectations.removeAll { $0.hasPrefix("Sprite color is ") }
        model.verificationExpectations.append("Sprite color is \(normalizedColor).")

        var patched = source
        patched = try replaceRegion(AmigaSourceRegionName.model.rawValue, in: patched, with: AmigaSourceIndexer.modelRegion(for: model))
        patched = try replaceStateWordLine(
            label: "SpriteColor1",
            inRegion: AmigaSourceRegionName.state.rawValue,
            source: patched,
            value: value,
            suffix: "; \(normalizedColor) sprite COLOR17"
        )
        patched = try replaceStateWordLine(
            label: "SpriteColor2",
            inRegion: AmigaSourceRegionName.state.rawValue,
            source: patched,
            value: value,
            suffix: "; \(normalizedColor) sprite COLOR18"
        )
        patched = try replaceStateWordLine(
            label: "SpriteColor3",
            inRegion: AmigaSourceRegionName.state.rawValue,
            source: patched,
            value: value,
            suffix: "; \(normalizedColor) sprite COLOR19"
        )
        return try mouseSpriteVerifiedPatchResult(source: source, patched: patched, model: model)
    }

    static func updateCopperRasterBarCount(_ count: Int, in source: String) throws -> AmigaProgramPatchResult {
        let index = AmigaSourceIndexer.index(source)
        guard var model = index.model else { throw AmigaProgramPatchError.missingModel }
        try requireCopperRasterModel(model)
        try requireVerifiedCurrentSource(source)
        try requireClosedRegion(AmigaSourceRegionName.model.rawValue, in: index)
        try requireClosedRegion(AmigaSourceRegionName.state.rawValue, in: index)

        guard count == 8 else {
            throw AmigaProgramPatchError.missingRegion("supported copper bar count")
        }

        try updateStateInitialValue(symbol: "BarCount", id: "bar_count", value: "8", model: &model)
        try updateStateInitialValue(symbol: "BandColor7", id: "band_color_7", value: "$000f", model: &model)
        try updateStateInitialValue(symbol: "BandColor8", id: "band_color_8", value: "$0fff", model: &model)
        model.verificationExpectations.removeAll { $0.hasPrefix("Copper bar count is ") }
        model.verificationExpectations.append("Copper bar count is 8.")

        var patched = source
        patched = try replaceRegion(AmigaSourceRegionName.model.rawValue, in: patched, with: AmigaSourceIndexer.modelRegion(for: model))
        patched = try replaceStateWordLine(label: "BarCount", inRegion: AmigaSourceRegionName.state.rawValue, source: patched, value: 8)
        patched = try replaceStateWordLine(label: "BandColor7", inRegion: AmigaSourceRegionName.state.rawValue, source: patched, value: "$000f", suffix: "; blue seventh bar")
        patched = try replaceStateWordLine(label: "BandColor8", inRegion: AmigaSourceRegionName.state.rawValue, source: patched, value: "$0fff", suffix: "; white eighth bar")
        return try copperRasterVerifiedPatchResult(source: source, patched: patched, model: model)
    }

    static func updateCopperRasterBounceStep(_ step: Int, in source: String) throws -> AmigaProgramPatchResult {
        let index = AmigaSourceIndexer.index(source)
        guard var model = index.model else { throw AmigaProgramPatchError.missingModel }
        try requireCopperRasterModel(model)
        try requireVerifiedCurrentSource(source)
        try requireClosedRegion(AmigaSourceRegionName.model.rawValue, in: index)
        try requireClosedRegion(AmigaSourceRegionName.state.rawValue, in: index)

        let boundedStep = min(max(step, 1), 4)
        try updateStateInitialValue(symbol: "BarStep", id: "bar_step", value: "\(boundedStep)", model: &model)
        model.verificationExpectations.removeAll { $0.hasPrefix("Copper bar bounce step is ") }
        model.verificationExpectations.append("Copper bar bounce step is \(boundedStep) pixel\(boundedStep == 1 ? "" : "s") per frame.")

        var patched = source
        patched = try replaceRegion(AmigaSourceRegionName.model.rawValue, in: patched, with: AmigaSourceIndexer.modelRegion(for: model))
        patched = try replaceStateWordLine(label: "BarStep", inRegion: AmigaSourceRegionName.state.rawValue, source: patched, value: boundedStep)
        return try copperRasterVerifiedPatchResult(source: source, patched: patched, model: model)
    }

    static func updateCopperRasterBlueWhitePalette(in source: String) throws -> AmigaProgramPatchResult {
        let index = AmigaSourceIndexer.index(source)
        guard var model = index.model else { throw AmigaProgramPatchError.missingModel }
        try requireCopperRasterModel(model)
        try requireVerifiedCurrentSource(source)
        try requireClosedRegion(AmigaSourceRegionName.model.rawValue, in: index)
        try requireClosedRegion(AmigaSourceRegionName.state.rawValue, in: index)

        let values = [
            ("BandColor1", "band_color_1", "$000f"),
            ("BandColor2", "band_color_2", "$0fff"),
            ("BandColor3", "band_color_3", "$000f"),
            ("BandColor4", "band_color_4", "$0fff"),
            ("BandColor5", "band_color_5", "$000f"),
            ("BandColor6", "band_color_6", "$0fff"),
            ("BandColor7", "band_color_7", "$000f"),
            ("BandColor8", "band_color_8", "$0fff")
        ]
        for (symbol, id, value) in values {
            try updateStateInitialValue(symbol: symbol, id: id, value: value, model: &model)
        }
        model.verificationExpectations.removeAll { $0.hasPrefix("Copper palette is ") }
        model.verificationExpectations.append("Copper palette is blue and white.")

        var patched = source
        patched = try replaceRegion(AmigaSourceRegionName.model.rawValue, in: patched, with: AmigaSourceIndexer.modelRegion(for: model))
        for (symbol, _, value) in values {
            patched = try replaceStateWordLine(label: symbol, inRegion: AmigaSourceRegionName.state.rawValue, source: patched, value: value, suffix: "; blue/white palette")
        }
        return try copperRasterVerifiedPatchResult(source: source, patched: patched, model: model)
    }

    static func updateCopperRasterTopStatusBand(in source: String) throws -> AmigaProgramPatchResult {
        let index = AmigaSourceIndexer.index(source)
        guard var model = index.model else { throw AmigaProgramPatchError.missingModel }
        try requireCopperRasterModel(model)
        try requireVerifiedCurrentSource(source)
        try requireClosedRegion(AmigaSourceRegionName.model.rawValue, in: index)
        try requireClosedRegion(AmigaSourceRegionName.state.rawValue, in: index)

        try updateStateInitialValue(symbol: "StatusBandColor", id: "status_band_color", value: "$00f0", model: &model)
        model.verificationExpectations.removeAll { $0.hasPrefix("Top status band is ") }
        model.verificationExpectations.append("Top status band is enabled.")

        var patched = source
        patched = try replaceRegion(AmigaSourceRegionName.model.rawValue, in: patched, with: AmigaSourceIndexer.modelRegion(for: model))
        patched = try replaceStateWordLine(label: "StatusBandColor", inRegion: AmigaSourceRegionName.state.rawValue, source: patched, value: "$00f0", suffix: "; green top status band")
        return try copperRasterVerifiedPatchResult(source: source, patched: patched, model: model)
    }

    static func updateBlitterBOBHorizontalSpeed(_ speed: Int, in source: String) throws -> AmigaProgramPatchResult {
        let index = AmigaSourceIndexer.index(source)
        guard var model = index.model else { throw AmigaProgramPatchError.missingModel }
        try requireBlitterBOBCollisionModel(model)
        try requireVerifiedCurrentSource(source)
        try requireClosedRegion(AmigaSourceRegionName.model.rawValue, in: index)
        try requireClosedRegion(AmigaSourceRegionName.state.rawValue, in: index)

        let boundedSpeed = min(max(speed, 1), 16)
        guard let stateIndex = model.stateVariables.firstIndex(where: { $0.id == "bob_dx" || $0.symbol == "BOBDX" }) else {
            throw AmigaProgramPatchError.missingRegion("BOBDX state")
        }
        model.stateVariables[stateIndex].initialValue = "\(boundedSpeed)"

        var patched = source
        patched = try replaceRegion(AmigaSourceRegionName.model.rawValue, in: patched, with: AmigaSourceIndexer.modelRegion(for: model))
        patched = try replaceStateWordLine(
            label: "BOBDX",
            inRegion: AmigaSourceRegionName.state.rawValue,
            source: patched,
            value: boundedSpeed
        )
        return try blitterBOBVerifiedPatchResult(source: source, patched: patched, model: model)
    }

    static func updateBlitterBOBTargetRectangle(left: Int, right: Int, in source: String) throws -> AmigaProgramPatchResult {
        let index = AmigaSourceIndexer.index(source)
        guard var model = index.model else { throw AmigaProgramPatchError.missingModel }
        try requireBlitterBOBCollisionModel(model)
        try requireVerifiedCurrentSource(source)
        try requireClosedRegion(AmigaSourceRegionName.model.rawValue, in: index)
        try requireClosedRegion(AmigaSourceRegionName.state.rawValue, in: index)

        let clampedLeft = min(max(left, 16), 272)
        let clampedRight = min(max(right, clampedLeft + 16), 288)
        try updateBlitterBOBStateInitialValue(symbol: "TargetLeft", id: "target_left", value: "\(clampedLeft)", model: &model)
        try updateBlitterBOBStateInitialValue(symbol: "TargetRight", id: "target_right", value: "\(clampedRight)", model: &model)

        var patched = source
        patched = try replaceRegion(AmigaSourceRegionName.model.rawValue, in: patched, with: AmigaSourceIndexer.modelRegion(for: model))
        patched = try replaceStateWordLine(
            label: "TargetLeft",
            inRegion: AmigaSourceRegionName.state.rawValue,
            source: patched,
            value: clampedLeft
        )
        patched = try replaceStateWordLine(
            label: "TargetRight",
            inRegion: AmigaSourceRegionName.state.rawValue,
            source: patched,
            value: clampedRight
        )
        return try blitterBOBVerifiedPatchResult(source: source, patched: patched, model: model)
    }

    static func updateBlitterBOBCollisionColor(_ color: String, in source: String) throws -> AmigaProgramPatchResult {
        let index = AmigaSourceIndexer.index(source)
        guard var model = index.model else { throw AmigaProgramPatchError.missingModel }
        try requireBlitterBOBCollisionModel(model)
        try requireVerifiedCurrentSource(source)
        try requireClosedRegion(AmigaSourceRegionName.model.rawValue, in: index)
        try requireClosedRegion(AmigaSourceRegionName.state.rawValue, in: index)

        let normalizedColor = color.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard let value = AmigaProgramTemplate.colorValue(named: normalizedColor) else {
            throw AmigaProgramPatchError.missingRegion("supported collision color")
        }
        try updateBlitterBOBStateInitialValue(symbol: "CollisionColor", id: "collision_color", value: value, model: &model)

        var patched = source
        patched = try replaceRegion(AmigaSourceRegionName.model.rawValue, in: patched, with: AmigaSourceIndexer.modelRegion(for: model))
        patched = try replaceStateWordLine(
            label: "CollisionColor",
            inRegion: AmigaSourceRegionName.state.rawValue,
            source: patched,
            value: value,
            suffix: "; \(normalizedColor) collision COLOR01"
        )
        return try blitterBOBVerifiedPatchResult(source: source, patched: patched, model: model)
    }

    static func addBlitterBOBDirectionControl(in source: String) throws -> AmigaProgramPatchResult {
        let index = AmigaSourceIndexer.index(source)
        guard var model = index.model else { throw AmigaProgramPatchError.missingModel }
        try requireBlitterBOBCollisionModel(model)
        try requireVerifiedCurrentSource(source)
        try requireClosedRegion(AmigaSourceRegionName.model.rawValue, in: index)
        try requireClosedRegion(AmigaSourceRegionName.routines.rawValue, in: index)
        try requireClosedRegion(AmigaSourceRegionName.state.rawValue, in: index)

        if !model.routines.contains(where: { $0.id == "read_direction_input" || $0.label == "ReadDirectionInput" }) {
            let readDirectionRoutine = AmigaProgramModel.Routine(
                id: "read_direction_input",
                label: "ReadDirectionInput",
                purpose: "Reads joystick direction state while preserving the left-mouse exit path."
            )
            if let updateRoutineIndex = model.routines.firstIndex(where: { $0.id == "update_bob_position" || $0.label == "UpdateBOBPosition" }) {
                model.routines.insert(readDirectionRoutine, at: model.routines.index(after: updateRoutineIndex))
            } else {
                model.routines.append(readDirectionRoutine)
            }
        }
        if let updateIndex = model.routines.firstIndex(where: { $0.id == "update_bob_position" || $0.label == "UpdateBOBPosition" }),
           !model.routines[updateIndex].calls.contains("ReadDirectionInput") {
            model.routines[updateIndex].calls.append("ReadDirectionInput")
        }
        if !model.stateVariables.contains(where: { $0.id == "direction_control_enabled" || $0.symbol == "DirectionControlEnabled" }) {
            model.stateVariables.append(AmigaProgramModel.StateVariable(
                id: "direction_control_enabled",
                symbol: "DirectionControlEnabled",
                purpose: "Set when joystick direction reads are part of the BOB movement path.",
                initialValue: "1"
            ))
        }
        if !model.stateVariables.contains(where: { $0.id == "direction_sample" || $0.symbol == "DirectionSample" }) {
            model.stateVariables.append(AmigaProgramModel.StateVariable(
                id: "direction_sample",
                symbol: "DirectionSample",
                purpose: "Last sampled joystick direction bits.",
                initialValue: "0"
            ))
        }
        model.verificationExpectations.removeAll { $0 == "Joystick direction input participates in BOB movement while mouse exit remains armed." }
        model.verificationExpectations.append("Joystick direction input participates in BOB movement while mouse exit remains armed.")

        var patched = source
        patched = try replaceRegion(AmigaSourceRegionName.model.rawValue, in: patched, with: AmigaSourceIndexer.modelRegion(for: model))

        let beforeUpdateCall = patched
        patched = patched.replacingOccurrences(
            of: "UpdateBOBPosition:\n            move.w     BOBX(pc),d0",
            with: "UpdateBOBPosition:\n            bsr        ReadDirectionInput\n            move.w     BOBX(pc),d0"
        )
        guard patched != beforeUpdateCall else {
            throw AmigaProgramPatchError.missingRegion("UpdateBOBPosition entry")
        }

        let beforeRoutine = patched
        patched = patched.replacingOccurrences(
            of: "\nCheckCollision:\n",
            with: """

ReadDirectionInput:
            move.w     DirectionControlEnabled(pc),d5
            beq.s      .directionDone
            move.w     $00c(a6),d3          ; JOY1DAT direction evidence
            move.w     d3,d4
            andi.w     #$0303,d4
            beq.s      .directionDone
            move.w     d4,DirectionSample
.directionDone:
            rts

CheckCollision:
"""
        )
        guard patched != beforeRoutine else {
            throw AmigaProgramPatchError.missingRegion("CheckCollision routine anchor")
        }

        let beforeState = patched
        patched = patched.replacingOccurrences(
            of: "ExitDelay:      dc.w       90\n            ; @amiga:region state end",
            with: """
ExitDelay:      dc.w       90
DirectionControlEnabled: dc.w 1
DirectionSample: dc.w       0
            ; @amiga:region state end
"""
        )
        guard patched != beforeState else {
            throw AmigaProgramPatchError.missingRegion("DirectionControlEnabled state")
        }

        return try blitterBOBVerifiedPatchResult(
            source: source,
            patched: patched,
            model: model,
            changedRegions: [
                AmigaSourceRegionName.model.rawValue,
                AmigaSourceRegionName.routines.rawValue,
                AmigaSourceRegionName.state.rawValue
            ]
        )
    }

    static func renameControl(currentLabel: String, newLabel: String, in source: String) throws -> AmigaProgramPatchResult {
        let index = AmigaSourceIndexer.index(source)
        guard var model = index.model else { throw AmigaProgramPatchError.missingModel }
        try requireMODControlsModel(model)
        try requireVerifiedCurrentSource(source)
        try requireClosedRegion(AmigaSourceRegionName.model.rawValue, in: index)
        try requireClosedRegion(AmigaSourceRegionName.controls.rawValue, in: index)
        try requireClosedRegion(AmigaSourceRegionName.chipData.rawValue, in: index)

        let trimmedCurrentLabel = currentLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNewLabel = newLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        try requireValidControlLabel(trimmedNewLabel)
        let currentID = stableID(from: trimmedCurrentLabel)
        guard let controlIndex = model.controls.firstIndex(where: { control in
            control.id == currentID || control.label.caseInsensitiveCompare(trimmedCurrentLabel) == .orderedSame
        }) else {
            throw AmigaProgramPatchError.missingControl(trimmedCurrentLabel)
        }
        guard !model.controls.enumerated().contains(where: { offset, control in
            offset != controlIndex && control.label.caseInsensitiveCompare(trimmedNewLabel) == .orderedSame
        }) else {
            throw AmigaProgramPatchError.duplicateControl(stableID(from: trimmedNewLabel))
        }
        let targetID = stableID(from: trimmedNewLabel)
        guard !model.controls.enumerated().contains(where: { offset, control in
            offset != controlIndex && control.id == targetID
        }) else {
            throw AmigaProgramPatchError.duplicateControl(targetID)
        }

        let originalControl = model.controls[controlIndex]
        model.controls[controlIndex].label = trimmedNewLabel
        model.verificationExpectations.append("Control \(originalControl.label) is labeled \(trimmedNewLabel) without changing \(originalControl.action).")

        var patched = source
        patched = try replaceRegion(AmigaSourceRegionName.model.rawValue, in: patched, with: AmigaSourceIndexer.modelRegion(for: model))
        patched = try replaceFirstLine(inRegion: AmigaSourceRegionName.controls.rawValue, source: patched, with: controlMarkerLine(
            id: originalControl.id,
            label: trimmedNewLabel,
            action: originalControl.action,
            bounds: originalControl.bounds
        )) { line in
            patchMarkerCommentText(in: line)?.contains("@amiga:model control id=\(originalControl.id) ") == true
        }
        patched = try replaceDataLine(afterLabel: "ControlLabel_\(originalControl.id)", inRegion: AmigaSourceRegionName.chipData.rawValue, source: patched, with: #"            dc.b       "\#(assemblyStringLiteralText(for: trimmedNewLabel))",0"#)

        return try verifiedPatchResult(AmigaProgramPatchResult(
            source: patched,
            model: model,
            changedRegions: [
                AmigaSourceRegionName.model.rawValue,
                AmigaSourceRegionName.controls.rawValue,
                AmigaSourceRegionName.chipData.rawValue
            ]
        ))
    }

    static func removeControl(label: String, from source: String) throws -> AmigaProgramPatchResult {
        let index = AmigaSourceIndexer.index(source)
        guard var model = index.model else { throw AmigaProgramPatchError.missingModel }
        try requireMODControlsModel(model)
        try requireVerifiedCurrentSource(source)
        try requireClosedRegion(AmigaSourceRegionName.model.rawValue, in: index)
        try requireClosedRegion(AmigaSourceRegionName.controls.rawValue, in: index)
        try requireClosedRegion(AmigaSourceRegionName.drawControls.rawValue, in: index)
        try requireClosedRegion(AmigaSourceRegionName.hitTest.rawValue, in: index)
        try requireClosedRegion(AmigaSourceRegionName.inputDispatch.rawValue, in: index)
        try requireClosedRegion(AmigaSourceRegionName.routines.rawValue, in: index)
        try requireClosedRegion(AmigaSourceRegionName.chipData.rawValue, in: index)

        let trimmedLabel = label.trimmingCharacters(in: .whitespacesAndNewlines)
        let stableID = stableID(from: trimmedLabel)
        guard let controlIndex = model.controls.firstIndex(where: { control in
            control.id == stableID ||
                control.label.caseInsensitiveCompare(trimmedLabel) == .orderedSame
        }) else {
            throw AmigaProgramPatchError.missingControl(trimmedLabel)
        }

        let removedControl = model.controls[controlIndex]
        guard !["play", "stop"].contains(removedControl.id) else {
            throw AmigaProgramPatchError.protectedControl(removedControl.label)
        }

        model.controls.remove(at: controlIndex)
        for offset in model.controls.indices {
            model.controls[offset].bounds = defaultBounds(forControlAt: offset + 1)
        }
        model.routines.removeAll { $0.id == removedControl.id && $0.label == removedControl.action }
        if let dispatchRoutineIndex = model.routines.firstIndex(where: { $0.id == "dispatch" && $0.label == "InputDispatch" }) {
            model.routines[dispatchRoutineIndex].calls.removeAll { $0 == removedControl.action }
        }
        model.verificationExpectations.removeAll { expectation in
            expectation.contains(removedControl.label) ||
                expectation.contains(removedControl.action) ||
                expectation.contains("Control \(removedControl.label) ")
        }
        if !model.controls.contains(where: { $0.action == "VolumeUp" || $0.action == "VolumeDown" }) {
            model.verificationExpectations.removeAll { $0.hasPrefix("Volume step is ") }
        }

        var patched = source
        patched = try replaceRegion(AmigaSourceRegionName.model.rawValue, in: patched, with: AmigaSourceIndexer.modelRegion(for: model))
        patched = try replaceRegionBody(AmigaSourceRegionName.controls.rawValue, in: patched, with: controlMarkerLines(for: model.controls))
        patched = try replaceDrawControlsBody(in: patched, controls: model.controls)
        patched = try replaceHitTestBody(in: patched, controls: model.controls)
        patched = try replaceInputDispatchBody(in: patched, controls: model.controls)
        patched = try removeRoutine(label: removedControl.action, inRegion: AmigaSourceRegionName.routines.rawValue, source: patched)
        patched = try replaceControlDataBody(in: patched, controls: model.controls)

        return try verifiedPatchResult(AmigaProgramPatchResult(
            source: patched,
            model: model,
            changedRegions: [
                AmigaSourceRegionName.model.rawValue,
                AmigaSourceRegionName.controls.rawValue,
                AmigaSourceRegionName.drawControls.rawValue,
                AmigaSourceRegionName.hitTest.rawValue,
                AmigaSourceRegionName.inputDispatch.rawValue,
                AmigaSourceRegionName.routines.rawValue,
                AmigaSourceRegionName.chipData.rawValue
            ]
        ))
    }

    static func moveControl(label: String, placement: AmigaProgramControlPlacement, targetLabel: String, in source: String) throws -> AmigaProgramPatchResult {
        let index = AmigaSourceIndexer.index(source)
        guard var model = index.model else { throw AmigaProgramPatchError.missingModel }
        try requireMODControlsModel(model)
        try requireVerifiedCurrentSource(source)
        try requireClosedRegion(AmigaSourceRegionName.model.rawValue, in: index)
        try requireClosedRegion(AmigaSourceRegionName.controls.rawValue, in: index)
        try requireClosedRegion(AmigaSourceRegionName.drawControls.rawValue, in: index)
        try requireClosedRegion(AmigaSourceRegionName.hitTest.rawValue, in: index)
        try requireClosedRegion(AmigaSourceRegionName.inputDispatch.rawValue, in: index)
        try requireClosedRegion(AmigaSourceRegionName.chipData.rawValue, in: index)

        let trimmedLabel = label.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedTargetLabel = targetLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let sourceIndex = controlIndex(matching: trimmedLabel, in: model.controls) else {
            throw AmigaProgramPatchError.missingControl(trimmedLabel)
        }
        guard let targetIndex = controlIndex(matching: trimmedTargetLabel, in: model.controls) else {
            throw AmigaProgramPatchError.missingControl(trimmedTargetLabel)
        }

        let movedControl = model.controls[sourceIndex]
        guard !["play", "stop"].contains(movedControl.id) else {
            throw AmigaProgramPatchError.protectedControlMove(movedControl.label)
        }
        guard sourceIndex != targetIndex else {
            return try verifiedPatchResult(AmigaProgramPatchResult(source: source, model: model, changedRegions: []))
        }

        let originalControlIDs = model.controls.map(\.id)
        var controls = model.controls
        let controlsWithCustomBounds: Set<String> = Set(controls.enumerated().compactMap { offset, control in
            guard let bounds = control.bounds,
                  bounds != defaultBounds(forControlAt: offset + 1) else {
                return nil
            }
            return control.id
        })
        let control = controls.remove(at: sourceIndex)
        let adjustedTargetIndex = sourceIndex < targetIndex ? targetIndex - 1 : targetIndex
        let insertionIndex: Int
        switch placement {
        case .before:
            insertionIndex = adjustedTargetIndex
        case .after:
            insertionIndex = adjustedTargetIndex + 1
        }
        controls.insert(control, at: min(max(0, insertionIndex), controls.count))
        guard controls.map(\.id) != originalControlIDs else {
            return try verifiedPatchResult(AmigaProgramPatchResult(source: source, model: model, changedRegions: []))
        }
        for offset in controls.indices {
            if !controlsWithCustomBounds.contains(controls[offset].id) {
                controls[offset].bounds = defaultBounds(forControlAt: offset + 1)
            }
        }
        model.controls = controls
        if let dispatchRoutineIndex = model.routines.firstIndex(where: { $0.id == "dispatch" && $0.label == "InputDispatch" }) {
            model.routines[dispatchRoutineIndex].calls = controls.map(\.action)
        }

        var patched = source
        patched = try replaceRegion(AmigaSourceRegionName.model.rawValue, in: patched, with: AmigaSourceIndexer.modelRegion(for: model))
        patched = try replaceRegionBody(AmigaSourceRegionName.controls.rawValue, in: patched, with: controlMarkerLines(for: controls))
        patched = try replaceDrawControlsBody(in: patched, controls: controls)
        patched = try replaceHitTestBody(in: patched, controls: controls)
        patched = try replaceInputDispatchBody(in: patched, controls: controls)
        patched = try replaceControlDataBody(in: patched, controls: controls)

        return try verifiedPatchResult(AmigaProgramPatchResult(
            source: patched,
            model: model,
            changedRegions: [
                AmigaSourceRegionName.model.rawValue,
                AmigaSourceRegionName.controls.rawValue,
                AmigaSourceRegionName.drawControls.rawValue,
                AmigaSourceRegionName.hitTest.rawValue,
                AmigaSourceRegionName.inputDispatch.rawValue,
                AmigaSourceRegionName.chipData.rawValue
            ]
        ))
    }

    static func changeControlBehavior(label: String, action: String, in source: String) throws -> AmigaProgramPatchResult {
        let index = AmigaSourceIndexer.index(source)
        guard var model = index.model else { throw AmigaProgramPatchError.missingModel }
        try requireMODControlsModel(model)
        try requireVerifiedCurrentSource(source)
        try requireClosedRegion(AmigaSourceRegionName.model.rawValue, in: index)
        try requireClosedRegion(AmigaSourceRegionName.controls.rawValue, in: index)
        try requireClosedRegion(AmigaSourceRegionName.inputDispatch.rawValue, in: index)
        try requireClosedRegion(AmigaSourceRegionName.routines.rawValue, in: index)
        try requireClosedRegion(AmigaSourceRegionName.state.rawValue, in: index)

        let trimmedLabel = label.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let controlIndex = controlIndex(matching: trimmedLabel, in: model.controls) else {
            throw AmigaProgramPatchError.missingControl(trimmedLabel)
        }

        let actionLabel = stableLabel(from: action)
        let previousControl = model.controls[controlIndex]
        guard !["play", "stop"].contains(previousControl.id) else {
            throw AmigaProgramPatchError.protectedControlBehavior(previousControl.label)
        }
        guard previousControl.action != actionLabel else {
            throw AmigaProgramPatchError.duplicateAction(actionLabel, previousControl.label)
        }
        if let existingControl = model.controls.enumerated().first(where: { offset, control in
            offset != controlIndex && control.action == actionLabel
        })?.element {
            throw AmigaProgramPatchError.duplicateAction(actionLabel, existingControl.label)
        }

        let patchSpec = try controlPatchSpec(label: previousControl.label, controlID: previousControl.id, actionLabel: actionLabel)
        model.controls[controlIndex].action = actionLabel
        if !model.controls.contains(where: { $0.action == previousControl.action }) {
            model.routines.removeAll { $0.id == previousControl.id && $0.label == previousControl.action }
        }
        if !model.routines.contains(where: { $0.label == actionLabel }) {
            model.routines.append(AmigaProgramModel.Routine(id: previousControl.id, label: actionLabel, purpose: patchSpec.purpose))
        }
        if let dispatchRoutineIndex = model.routines.firstIndex(where: { $0.id == "dispatch" && $0.label == "InputDispatch" }) {
            model.routines[dispatchRoutineIndex].calls = model.controls.map(\.action)
        }
        for stateVariable in patchSpec.stateVariables where !model.stateVariables.contains(where: { $0.id == stateVariable.id }) {
            model.stateVariables.append(stateVariable)
        }
        model.verificationExpectations.removeAll { expectation in
            expectation == "Control \(previousControl.label) dispatches to \(previousControl.action)." ||
                expectation.hasSuffix(" dispatches to \(previousControl.action).")
        }
        if !model.controls.contains(where: { $0.action == "VolumeUp" || $0.action == "VolumeDown" }) {
            model.verificationExpectations.removeAll { $0.hasPrefix("Volume step is ") }
        }
        model.verificationExpectations.append("Control \(previousControl.label) dispatches to \(actionLabel).")

        var patched = source
        patched = try replaceRegion(AmigaSourceRegionName.model.rawValue, in: patched, with: AmigaSourceIndexer.modelRegion(for: model))
        patched = try replaceRegionBody(AmigaSourceRegionName.controls.rawValue, in: patched, with: controlMarkerLines(for: model.controls))
        patched = try replaceInputDispatchBody(in: patched, controls: model.controls)
        if !model.controls.contains(where: { $0.action == previousControl.action }) {
            patched = try removeRoutine(label: previousControl.action, inRegion: AmigaSourceRegionName.routines.rawValue, source: patched)
        }
        var changedRegions = [
            AmigaSourceRegionName.model.rawValue,
            AmigaSourceRegionName.controls.rawValue,
            AmigaSourceRegionName.inputDispatch.rawValue,
            AmigaSourceRegionName.routines.rawValue
        ]
        if !hasLabelDefinition(actionLabel, in: patched) {
            patched = try insertBeforeRegionEnd(AmigaSourceRegionName.routines.rawValue, in: patched, lines: [""] + patchSpec.routineLines)
        }
        let stateLines = patchSpec.stateLines.filter { stateLine in
            let symbol = stateLine.split(separator: ":").first.map(String.init) ?? stateLine
            return !hasLabelDefinition(symbol, in: patched)
        }
        if !stateLines.isEmpty {
            patched = try insertBeforeRegionEnd(AmigaSourceRegionName.state.rawValue, in: patched, lines: stateLines)
            changedRegions.append(AmigaSourceRegionName.state.rawValue)
        }

        return try verifiedPatchResult(AmigaProgramPatchResult(
            source: patched,
            model: model,
            changedRegions: changedRegions
        ))
    }

    static func updateControlBounds(label: String, bounds: AmigaProgramModel.Bounds, in source: String) throws -> AmigaProgramPatchResult {
        try updateControlBounds([(label: label, bounds: bounds)], in: source)
    }

    static func updateControlBounds(
        _ placements: [(label: String, bounds: AmigaProgramModel.Bounds)],
        in source: String
    ) throws -> AmigaProgramPatchResult {
        let index = AmigaSourceIndexer.index(source)
        guard var model = index.model else { throw AmigaProgramPatchError.missingModel }
        try requireMODControlsModel(model)
        try requireVerifiedCurrentSource(source)
        try requireClosedRegion(AmigaSourceRegionName.model.rawValue, in: index)
        try requireClosedRegion(AmigaSourceRegionName.controls.rawValue, in: index)
        try requireClosedRegion(AmigaSourceRegionName.drawControls.rawValue, in: index)
        try requireClosedRegion(AmigaSourceRegionName.hitTest.rawValue, in: index)
        try requireClosedRegion(AmigaSourceRegionName.chipData.rawValue, in: index)

        var resolvedPlacements: [(index: Int, bounds: AmigaProgramModel.Bounds)] = []
        var hasBoundsChanges = false
        for placement in placements {
            let trimmedLabel = placement.label.trimmingCharacters(in: .whitespacesAndNewlines)
            guard let controlIndex = controlIndex(matching: trimmedLabel, in: model.controls) else {
                throw AmigaProgramPatchError.missingControl(trimmedLabel)
            }
            if model.controls[controlIndex].bounds != placement.bounds {
                hasBoundsChanges = true
            }
            resolvedPlacements.append((index: controlIndex, bounds: placement.bounds))
        }
        guard hasBoundsChanges else {
            return try verifiedPatchResult(AmigaProgramPatchResult(source: source, model: model, changedRegions: []))
        }

        for placement in resolvedPlacements {
            model.controls[placement.index].bounds = placement.bounds
        }

        var patched = source
        patched = try replaceRegion(AmigaSourceRegionName.model.rawValue, in: patched, with: AmigaSourceIndexer.modelRegion(for: model))
        patched = try replaceRegionBody(AmigaSourceRegionName.controls.rawValue, in: patched, with: controlMarkerLines(for: model.controls))
        patched = try replaceDrawControlsBody(in: patched, controls: model.controls)
        patched = try replaceHitTestBody(in: patched, controls: model.controls)
        patched = try replaceControlDataBody(in: patched, controls: model.controls)

        return try verifiedPatchResult(AmigaProgramPatchResult(
            source: patched,
            model: model,
            changedRegions: [
                AmigaSourceRegionName.model.rawValue,
                AmigaSourceRegionName.controls.rawValue,
                AmigaSourceRegionName.drawControls.rawValue,
                AmigaSourceRegionName.hitTest.rawValue,
                AmigaSourceRegionName.chipData.rawValue
            ]
        ))
    }

    private static func requireMODControlsModel(_ model: AmigaProgramModel) throws {
        guard model.id == AmigaProgramFamilyRegistry.modPlayerControls.id,
              model.kind == AmigaProgramFamilyRegistry.modPlayerControls.kind else {
            throw AmigaProgramPatchError.missingRegion("MOD controls model")
        }
    }

    private static func requireDoubleBufferedBitplaneModel(_ model: AmigaProgramModel) throws {
        guard model.id == AmigaProgramFamilyRegistry.doubleBufferedBitplane.id,
              model.kind == AmigaProgramFamilyRegistry.doubleBufferedBitplane.kind else {
            throw AmigaProgramPatchError.missingRegion("double-buffered bitplane model")
        }
    }

    private static func requireIntuitionWindowToolModel(_ model: AmigaProgramModel) throws {
        guard model.id == AmigaProgramTemplate.intuitionWindowToolID,
              model.kind == .utility else {
            throw AmigaProgramPatchError.missingRegion("Intuition window tool model")
        }
    }

    private static func requireCleanTakeoverRestoreModel(_ model: AmigaProgramModel) throws {
        guard model.id == AmigaProgramTemplate.cleanTakeoverRestoreID,
              model.kind == .effect else {
            throw AmigaProgramPatchError.missingRegion("clean takeover restore model")
        }
    }

    private static func verifiedIntuitionPatchResult(model: AmigaProgramModel, changedRegions: [String]) throws -> AmigaProgramPatchResult {
        let source = try AmigaProgramTemplate.verifiedIntuitionWindowToolSource(model: model)
        return try verifiedPatchResult(AmigaProgramPatchResult(
            source: source,
            model: model,
            changedRegions: changedRegions
        ))
    }

    private static func verifiedCleanTakeoverPatchResult(model: AmigaProgramModel, changedRegions: [String]) throws -> AmigaProgramPatchResult {
        let source = try AmigaProgramTemplate.verifiedCleanTakeoverRestoreSource(model: model)
        return try verifiedPatchResult(AmigaProgramPatchResult(
            source: source,
            model: model,
            changedRegions: changedRegions
        ))
    }

    private static func requireBlitterBOBCollisionModel(_ model: AmigaProgramModel) throws {
        guard model.id == AmigaProgramTemplate.blitterBOBCollisionBoundsID,
              model.kind == .effect else {
            throw AmigaProgramPatchError.missingRegion("blitter BOB collision model")
        }
    }

    private static func requireMouseSpriteMultiplexModel(_ model: AmigaProgramModel) throws {
        guard model.id == "mouse-sprite-multiplex",
              model.kind == .effect else {
            throw AmigaProgramPatchError.missingRegion("mouse sprite multiplex model")
        }
    }

    private static func requireCopperRasterModel(_ model: AmigaProgramModel) throws {
        guard model.id == "bouncing-copper-bars",
              model.kind == .effect else {
            throw AmigaProgramPatchError.missingRegion("bouncing copper raster model")
        }
    }

    private static func updateBlitterBOBStateInitialValue(
        symbol: String,
        id: String,
        value: String,
        model: inout AmigaProgramModel
    ) throws {
        try updateStateInitialValue(symbol: symbol, id: id, value: value, model: &model)
    }

    private static func updateStateInitialValue(
        symbol: String,
        id: String,
        value: String,
        model: inout AmigaProgramModel
    ) throws {
        guard let stateIndex = model.stateVariables.firstIndex(where: { $0.id == id || $0.symbol == symbol }) else {
            throw AmigaProgramPatchError.missingRegion("\(symbol) state")
        }
        model.stateVariables[stateIndex].initialValue = value
    }

    private static func blitterBOBVerifiedPatchResult(
        source: String,
        patched: String,
        model: AmigaProgramModel,
        changedRegions: [String] = [
            AmigaSourceRegionName.model.rawValue,
            AmigaSourceRegionName.state.rawValue
        ]
    ) throws -> AmigaProgramPatchResult {
        guard patched != source else {
            return try verifiedPatchResult(AmigaProgramPatchResult(source: source, model: model, changedRegions: []))
        }
        return try verifiedPatchResult(AmigaProgramPatchResult(
            source: patched,
            model: model,
            changedRegions: changedRegions
        ))
    }

    private static func doubleBufferedBitplaneVerifiedPatchResult(
        source: String,
        patched: String,
        model: AmigaProgramModel,
        changedRegions: [String]
    ) throws -> AmigaProgramPatchResult {
        guard patched != source else {
            return try verifiedPatchResult(AmigaProgramPatchResult(source: source, model: model, changedRegions: []))
        }
        return try verifiedPatchResult(AmigaProgramPatchResult(
            source: patched,
            model: model,
            changedRegions: changedRegions
        ))
    }

    private static func mouseSpriteVerifiedPatchResult(
        source: String,
        patched: String,
        model: AmigaProgramModel
    ) throws -> AmigaProgramPatchResult {
        guard patched != source else {
            return try verifiedPatchResult(AmigaProgramPatchResult(source: source, model: model, changedRegions: []))
        }
        return try verifiedPatchResult(AmigaProgramPatchResult(
            source: patched,
            model: model,
            changedRegions: [
                AmigaSourceRegionName.model.rawValue,
                AmigaSourceRegionName.state.rawValue
            ]
        ))
    }

    private static func copperRasterVerifiedPatchResult(
        source: String,
        patched: String,
        model: AmigaProgramModel
    ) throws -> AmigaProgramPatchResult {
        guard patched != source else {
            return try verifiedPatchResult(AmigaProgramPatchResult(source: source, model: model, changedRegions: []))
        }
        return try verifiedPatchResult(AmigaProgramPatchResult(
            source: patched,
            model: model,
            changedRegions: [
                AmigaSourceRegionName.model.rawValue,
                AmigaSourceRegionName.state.rawValue
            ]
        ))
    }

    private static func requireVerifiedCurrentSource(_ source: String) throws {
        let failures = AmigaProgramSourceVerifier.failures(in: source)
        guard failures.isEmpty else {
            throw AmigaProgramPatchError.verificationFailed(failures)
        }
    }

    private static func verifiedPatchResult(_ result: AmigaProgramPatchResult) throws -> AmigaProgramPatchResult {
        let failures = AmigaProgramSourceVerifier.failures(in: result.source)
        guard failures.isEmpty else {
            throw AmigaProgramPatchError.verificationFailed(failures)
        }
        return result
    }

    private static func requireValidControlLabel(_ label: String) throws {
        guard !label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AmigaProgramPatchError.invalidControlLabel(label)
        }
        guard !label.unicodeScalars.contains(where: { CharacterSet.controlCharacters.contains($0) }) else {
            throw AmigaProgramPatchError.invalidControlLabel(label)
        }
    }

    static func stableID(from label: String) -> String {
        let words = label
            .lowercased()
            .split { !$0.isLetter && !$0.isNumber }
            .map(String.init)
        return words.isEmpty ? "control" : words.joined(separator: "_")
    }

    private static func uniqueControlID(basedOn baseID: String, existingControls: [AmigaProgramModel.Control]) -> String {
        let existingIDs = Set(existingControls.map(\.id))
        guard existingIDs.contains(baseID) else { return baseID }
        var suffix = 2
        while existingIDs.contains("\(baseID)_\(suffix)") {
            suffix += 1
        }
        return "\(baseID)_\(suffix)"
    }

    static func stableLabel(from action: String) -> String {
        let words = action
            .split { !$0.isLetter && !$0.isNumber }
            .map(String.init)
        let raw = words.isEmpty ? "ControlAction" : words.joined()
        guard let first = raw.first else { return "ControlAction" }
        return String(first).uppercased() + raw.dropFirst()
    }

    private static func controlIndex(matching label: String, in controls: [AmigaProgramModel.Control]) -> Int? {
        let stableID = stableID(from: label)
        return controls.firstIndex { control in
            control.id == stableID ||
                control.label.caseInsensitiveCompare(label) == .orderedSame ||
                control.action.caseInsensitiveCompare(label) == .orderedSame
        }
    }

    private static func requireClosedRegion(_ name: String, in index: AmigaSourceIndex) throws {
        guard let region = index.regions[name], region.endLine != nil else {
            throw AmigaProgramPatchError.missingRegion(name)
        }
    }

    private static func replaceRegion(_ name: String, in source: String, with replacement: String) throws -> String {
        let index = AmigaSourceIndexer.index(source)
        guard let region = index.regions[name], let endLine = region.endLine else {
            throw AmigaProgramPatchError.missingRegion(name)
        }

        var lines = source.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        let replacementLines = replacement.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        lines.replaceSubrange((region.startLine - 1)..<endLine, with: replacementLines)
        return lines.joined(separator: "\n")
    }

    private static func replaceRegionBody(_ name: String, in source: String, with replacementLines: [String]) throws -> String {
        let index = AmigaSourceIndexer.index(source)
        guard let region = index.regions[name], let endLine = region.endLine else {
            throw AmigaProgramPatchError.missingRegion(name)
        }

        var lines = source.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        lines.replaceSubrange(region.startLine..<(endLine - 1), with: replacementLines)
        return lines.joined(separator: "\n")
    }

    private static func replaceDrawControlsBody(in source: String, controls: [AmigaProgramModel.Control]) throws -> String {
        try replaceLines(
            afterLabel: "DrawControls",
            beforeReturnInRegion: AmigaSourceRegionName.drawControls.rawValue,
            source: source,
            with: controlDrawLines(for: controls)
        )
    }

    private static func replaceHitTestBody(in source: String, controls: [AmigaProgramModel.Control]) throws -> String {
        try replaceLines(
            afterLineMatching: { $0.trimmingCharacters(in: .whitespaces).lowercased() == "beq        .donehittest" },
            beforeLabel: ".doneHitTest",
            inRegion: AmigaSourceRegionName.hitTest.rawValue,
            source: source,
            with: controlHitTestLines(for: controls)
        )
    }

    private static func replaceInputDispatchBody(in source: String, controls: [AmigaProgramModel.Control]) throws -> String {
        try replaceLines(
            afterLineMatching: { $0.trimmingCharacters(in: .whitespaces).lowercased() == "beq.s      .donedispatch" },
            beforeLabel: ".doneDispatch",
            inRegion: AmigaSourceRegionName.inputDispatch.rawValue,
            source: source,
            with: controlDispatchLines(for: controls)
        )
    }

    private static func replaceControlDataBody(in source: String, controls: [AmigaProgramModel.Control]) throws -> String {
        let index = AmigaSourceIndexer.index(source)
        guard let region = index.regions[AmigaSourceRegionName.chipData.rawValue], let endLine = region.endLine else {
            throw AmigaProgramPatchError.missingRegion(AmigaSourceRegionName.chipData.rawValue)
        }

        var lines = source.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        let regionBodyRange = region.startLine..<(endLine - 1)
        var removalRanges: [Range<Int>] = []
        var cursor = regionBodyRange.lowerBound
        while cursor < regionBodyRange.upperBound {
            let line = lines[cursor]
            guard lineDefinesControlRectLabel(line) else {
                cursor += 1
                continue
            }
            let blockEnd = (cursor + 1)..<regionBodyRange.upperBound
            let evenLine = blockEnd.first { lines[$0].trimmingCharacters(in: .whitespaces).lowercased() == "even" }
            let removalEnd = evenLine.map { $0 + 1 } ?? blockEnd.lowerBound
            removalRanges.append(cursor..<removalEnd)
            cursor = removalEnd
        }
        for range in removalRanges.reversed() {
            lines.removeSubrange(range)
        }

        guard let bitplaneBufferIndex = lines.indices.first(where: { lineDefinesExactLabel(lines[$0], label: "BitplaneBuffer") }) else {
            throw AmigaProgramPatchError.missingRegion("BitplaneBuffer")
        }
        lines.insert(contentsOf: controlDataLines(for: controls), at: bitplaneBufferIndex)
        return lines.joined(separator: "\n")
    }

    private static func removeRoutine(label: String, inRegion name: String, source: String) throws -> String {
        let index = AmigaSourceIndexer.index(source)
        guard let region = index.regions[name], let endLine = region.endLine else {
            throw AmigaProgramPatchError.missingRegion(name)
        }

        var lines = source.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        let searchRange = max(region.startLine, 1)..<max(endLine, region.startLine)
        guard let labelLine = searchRange.first(where: { lineDefinesLabel(lines[$0 - 1], label: label) }) else {
            throw AmigaProgramPatchError.missingRegion(label)
        }
        let routineEnd = ((labelLine + 1)..<max(endLine, labelLine + 1)).first { lineIndex in
            let line = lines[lineIndex - 1]
            if line.trimmingCharacters(in: .whitespaces).hasPrefix("; @amiga:region") {
                return true
            }
            guard let label = AmigaSourceIndexer.labelName(from: line) else {
                return false
            }
            return !label.hasPrefix(".")
        } ?? endLine
        let startIndex = max(labelLine - 2, region.startLine - 1)
        let removeStart = lines[startIndex].trimmingCharacters(in: .whitespaces).isEmpty ? startIndex : labelLine - 1
        lines.removeSubrange(removeStart..<(routineEnd - 1))
        return lines.joined(separator: "\n")
    }

    private static func replaceLines(
        afterLabel label: String,
        beforeReturnInRegion name: String,
        source: String,
        with replacementLines: [String]
    ) throws -> String {
        let index = AmigaSourceIndexer.index(source)
        guard let region = index.regions[name], let endLine = region.endLine else {
            throw AmigaProgramPatchError.missingRegion(name)
        }

        var lines = source.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        let searchRange = max(region.startLine, 1)..<max(endLine, region.startLine)
        guard let labelLine = searchRange.first(where: { lineDefinesLabel(lines[$0 - 1], label: label) }) else {
            throw AmigaProgramPatchError.missingRegion(label)
        }
        guard let returnLine = ((labelLine + 1)..<max(endLine, labelLine + 1)).first(where: { isReturnInstructionLine(lines[$0 - 1]) }) else {
            throw AmigaProgramPatchError.missingRegion(label)
        }
        lines.replaceSubrange(labelLine..<returnLine - 1, with: replacementLines)
        return lines.joined(separator: "\n")
    }

    private static func replaceLines(
        afterLineMatching startPredicate: (String) -> Bool,
        beforeLabel label: String,
        inRegion name: String,
        source: String,
        with replacementLines: [String]
    ) throws -> String {
        let index = AmigaSourceIndexer.index(source)
        guard let region = index.regions[name], let endLine = region.endLine else {
            throw AmigaProgramPatchError.missingRegion(name)
        }

        var lines = source.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        let searchRange = max(region.startLine, 1)..<max(endLine, region.startLine)
        guard let startLine = searchRange.first(where: { startPredicate(lines[$0 - 1]) }),
              let labelLine = searchRange.first(where: { lineDefinesLabel(lines[$0 - 1], label: label) }),
              startLine < labelLine else {
            throw AmigaProgramPatchError.missingRegion(label)
        }
        lines.replaceSubrange(startLine..<(labelLine - 1), with: replacementLines)
        return lines.joined(separator: "\n")
    }

    private static func replaceLines(
        afterRegionStart name: String,
        beforeLabel label: String,
        source: String,
        with replacementLines: [String]
    ) throws -> String {
        let index = AmigaSourceIndexer.index(source)
        guard let region = index.regions[name], let endLine = region.endLine else {
            throw AmigaProgramPatchError.missingRegion(name)
        }

        var lines = source.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        let searchRange = max(region.startLine, 1)..<max(endLine, region.startLine)
        guard let labelLine = searchRange.first(where: { lineDefinesExactLabel(lines[$0 - 1], label: label) }) else {
            throw AmigaProgramPatchError.missingRegion(label)
        }
        lines.replaceSubrange(region.startLine..<(labelLine - 1), with: replacementLines)
        return lines.joined(separator: "\n")
    }

    private static func insertBeforeRegionEnd(_ name: String, in source: String, lines insertedLines: [String]) throws -> String {
        let index = AmigaSourceIndexer.index(source)
        guard let region = index.regions[name], let endLine = region.endLine else {
            throw AmigaProgramPatchError.missingRegion(name)
        }

        var lines = source.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        lines.insert(contentsOf: insertedLines, at: endLine - 1)
        return lines.joined(separator: "\n")
    }

    private static func replaceFirstLine(inRegion name: String, source: String, with replacement: String, matching predicate: (String) -> Bool) throws -> String {
        let index = AmigaSourceIndexer.index(source)
        guard let region = index.regions[name], let endLine = region.endLine else {
            throw AmigaProgramPatchError.missingRegion(name)
        }

        var lines = source.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        let searchRange = max(region.startLine, 1)..<max(endLine, region.startLine)
        guard let lineIndex = searchRange.first(where: { predicate(lines[$0 - 1]) }) else {
            throw AmigaProgramPatchError.missingRegion(name)
        }
        lines[lineIndex - 1] = replacement
        return lines.joined(separator: "\n")
    }

    private static func replaceStateWordLine(label: String, inRegion name: String, source: String, value: Int) throws -> String {
        try replaceStateWordLine(
            label: label,
            inRegion: name,
            source: source,
            sameLineReplacement: "\(label):  dc.w     \(value)",
            splitLineReplacement: "            dc.w       \(value)"
        )
    }

    private static func replaceStateWordLine(label: String, inRegion name: String, source: String, value: String, suffix: String?) throws -> String {
        let commentSuffix = suffix.map { " \($0)" } ?? ""
        return try replaceStateWordLine(
            label: label,
            inRegion: name,
            source: source,
            sameLineReplacement: "\(label): dc.w       \(value)                \(commentSuffix)",
            splitLineReplacement: "            dc.w       \(value)                \(commentSuffix)"
        )
    }

    private static func replaceStateWordLine(
        label: String,
        inRegion name: String,
        source: String,
        sameLineReplacement: String,
        splitLineReplacement: String
    ) throws -> String {
        let index = AmigaSourceIndexer.index(source)
        guard let region = index.regions[name], let endLine = region.endLine else {
            throw AmigaProgramPatchError.missingRegion(name)
        }

        var lines = source.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        let searchRange = max(region.startLine, 1)..<max(endLine, region.startLine)
        guard let lineIndex = searchRange.first(where: { lineIndex in
            lineDefinesLabel(lines[lineIndex - 1], label: label)
        }) else {
            throw AmigaProgramPatchError.missingRegion(label)
        }

        if stateWordDirectiveLine(lines[lineIndex - 1], label: label) {
            lines[lineIndex - 1] = sameLineReplacement
            return lines.joined(separator: "\n")
        }

        let dataRange = (lineIndex + 1)..<max(endLine, lineIndex + 1)
        for dataLineIndex in dataRange.prefix(3) {
            let line = lines[dataLineIndex - 1]
            if AmigaSourceIndexer.labelName(from: line) != nil {
                break
            }
            if stateWordDirectiveLine(line, label: nil) {
                lines[dataLineIndex - 1] = splitLineReplacement
                return lines.joined(separator: "\n")
            }
        }

        throw AmigaProgramPatchError.missingRegion(label)
    }

    private static func stateWordDirectiveLine(_ line: String, label: String?) -> Bool {
        let code = assemblyCodePrefix(beforeCommentIn: line)
        var trimmed = code.trimmingCharacters(in: .whitespaces)
        if let label {
            guard lineDefinesLabel(line, label: label),
                  let colonIndex = trimmed.firstIndex(of: ":") else {
                return false
            }
            trimmed = String(trimmed[trimmed.index(after: colonIndex)...])
                .trimmingCharacters(in: .whitespaces)
        }
        guard let mnemonicEnd = trimmed.firstIndex(where: { $0 == " " || $0 == "\t" }) else {
            return false
        }
        let mnemonic = String(trimmed[..<mnemonicEnd]).lowercased()
        guard mnemonic == "dc.w" else {
            return false
        }
        let operands = trimmed[mnemonicEnd...].trimmingCharacters(in: .whitespaces)
        return operands.isEmpty == false
    }

    private static func replaceDataLine(afterLabel label: String, inRegion name: String, source: String, with replacement: String) throws -> String {
        let index = AmigaSourceIndexer.index(source)
        guard let region = index.regions[name], let endLine = region.endLine else {
            throw AmigaProgramPatchError.missingRegion(name)
        }

        var lines = source.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        let searchRange = max(region.startLine, 1)..<max(endLine, region.startLine)
        guard let labelLine = searchRange.first(where: { lineIndex in
            lineDefinesLabel(lines[lineIndex - 1], label: label)
        }) else {
            throw AmigaProgramPatchError.missingRegion(label)
        }
        let dataRange = (labelLine + 1)..<max(endLine, labelLine + 1)
        guard let dataLine = dataRange.prefix(3).first(where: { lineIndex in
            lines[lineIndex - 1].trimmingCharacters(in: .whitespaces).lowercased().hasPrefix("dc.b")
        }) else {
            throw AmigaProgramPatchError.missingRegion(label)
        }
        lines[dataLine - 1] = replacement
        return lines.joined(separator: "\n")
    }

    private static func insertBeforeRegionReturn(_ name: String, in source: String, lines insertedLines: [String]) throws -> String {
        let index = AmigaSourceIndexer.index(source)
        guard let region = index.regions[name], let endLine = region.endLine else {
            throw AmigaProgramPatchError.missingRegion(name)
        }

        var lines = source.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        let searchRange = max(region.startLine, 1)..<max(endLine, region.startLine)
        let insertionIndex = searchRange.reversed().first { lineIndex in
            isReturnInstructionLine(lines[lineIndex - 1])
        }.map { $0 - 1 } ?? (endLine - 1)
        lines.insert(contentsOf: insertedLines, at: insertionIndex)
        return lines.joined(separator: "\n")
    }

    private static func insertBeforeLabelOrRegionReturn(_ label: String, inRegion name: String, source: String, lines insertedLines: [String]) throws -> String {
        let index = AmigaSourceIndexer.index(source)
        guard let region = index.regions[name], let endLine = region.endLine else {
            throw AmigaProgramPatchError.missingRegion(name)
        }

        var lines = source.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        let searchRange = max(region.startLine, 1)..<max(endLine, region.startLine)
        if let labelLine = searchRange.first(where: { lineIndex in
            lineDefinesLabel(lines[lineIndex - 1], label: label)
        }) {
            lines.insert(contentsOf: insertedLines, at: labelLine - 1)
            return lines.joined(separator: "\n")
        }

        return try insertBeforeRegionReturn(name, in: source, lines: insertedLines)
    }

    private static func insertBeforeReturn(afterLabel label: String, inRegion name: String, source: String, lines insertedLines: [String]) throws -> String {
        let index = AmigaSourceIndexer.index(source)
        guard let region = index.regions[name], let endLine = region.endLine else {
            throw AmigaProgramPatchError.missingRegion(name)
        }

        var lines = source.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        let searchRange = max(region.startLine, 1)..<max(endLine, region.startLine)
        guard let labelLine = searchRange.first(where: { lineIndex in
            lineDefinesLabel(lines[lineIndex - 1], label: label)
        }) else {
            throw AmigaProgramPatchError.missingRegion(label)
        }
        let insertionIndex = (labelLine + 1)..<max(endLine, labelLine + 1)
        let returnIndex = insertionIndex.first { lineIndex in
            isReturnInstructionLine(lines[lineIndex - 1])
        }.map { $0 - 1 } ?? (endLine - 1)
        lines.insert(contentsOf: insertedLines, at: returnIndex)
        return lines.joined(separator: "\n")
    }

    private static func isReturnInstructionLine(_ line: String) -> Bool {
        let code = assemblyCodePrefix(beforeCommentIn: line)
        return code
            .trimmingCharacters(in: .whitespaces)
            .split { $0 == " " || $0 == "\t" }
            .joined(separator: " ")
            .lowercased() == "rts"
    }

    private static func patchMarkerCommentText(in line: String) -> String? {
        guard let comment = assemblyCommentText(in: line) else { return nil }
        return comment.hasPrefix("@amiga:") ? comment : nil
    }

    private static func insertBeforeLabel(_ label: String, inRegion name: String, source: String, lines insertedLines: [String]) throws -> String {
        let index = AmigaSourceIndexer.index(source)
        guard let region = index.regions[name], let endLine = region.endLine else {
            throw AmigaProgramPatchError.missingRegion(name)
        }

        var lines = source.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        let searchRange = max(region.startLine, 1)..<max(endLine, region.startLine)
        let insertionIndex = searchRange.first { lineIndex in
            lineDefinesLabel(lines[lineIndex - 1], label: label)
        }.map { $0 - 1 } ?? (endLine - 1)
        lines.insert(contentsOf: insertedLines, at: insertionIndex)
        return lines.joined(separator: "\n")
    }

    private static func hasLabelDefinition(_ label: String, in source: String) -> Bool {
        source
            .split(separator: "\n", omittingEmptySubsequences: false)
            .contains { line in
                lineDefinesLabel(String(line), label: label)
            }
    }

    private static func controlMarkerLine(id: String, label: String, action: String, bounds: AmigaProgramModel.Bounds?) -> String {
        let markerLabel = amigaMarkerAttributeText(for: label)
        guard let bounds else {
            return #"            ; @amiga:model control id=\#(id) label="\#(markerLabel)" action=\#(action)"#
        }
        return #"            ; @amiga:model control id=\#(id) label="\#(markerLabel)" action=\#(action) bounds=\#(bounds.x),\#(bounds.y),\#(bounds.width),\#(bounds.height)"#
    }

    private static func controlMarkerLines(for controls: [AmigaProgramModel.Control]) -> [String] {
        controls.map { control in
            controlMarkerLine(id: control.id, label: control.label, action: control.action, bounds: control.bounds)
        }
    }

    private static func defaultBounds(forControlAt slot: Int) -> AmigaProgramModel.Bounds {
        let zeroBasedSlot = max(0, slot - 1)
        let column = zeroBasedSlot % 3
        let row = zeroBasedSlot / 3
        return AmigaProgramModel.Bounds(
            x: 32 + column * 88,
            y: 40 + row * 28,
            width: 72,
            height: 20
        )
    }

    private static func hitTestLines(id: String, slot: Int, bounds: AmigaProgramModel.Bounds) -> [String] {
        let right = bounds.x + bounds.width
        let bottom = bounds.y + bounds.height
        return [
            "            ; @amiga:hittest \(id) slot=\(slot) bounds=\(bounds.x),\(bounds.y),\(bounds.width),\(bounds.height)",
            "            move.w     MouseX(pc),d0",
            "            cmp.w      #\(bounds.x),d0",
            "            blt.s      .miss_\(id)",
            "            cmp.w      #\(right),d0",
            "            bge.s      .miss_\(id)",
            "            move.w     MouseY(pc),d0",
            "            cmp.w      #\(bounds.y),d0",
            "            blt.s      .miss_\(id)",
            "            cmp.w      #\(bottom),d0",
            "            bge.s      .miss_\(id)",
            "            move.w     #\(slot),SelectedControl",
            "            move.w     #\(slot),ActivatedControl",
            "            bra        .doneHitTest",
            ".miss_\(id):"
        ]
    }

    private static func controlHitTestLines(for controls: [AmigaProgramModel.Control]) -> [String] {
        controls.enumerated().flatMap { offset, control in
            hitTestLines(
                id: control.id,
                slot: offset + 1,
                bounds: control.bounds ?? defaultBounds(forControlAt: offset + 1)
            )
        }
    }

    private static func drawControlLines(id: String, slot: Int, bounds: AmigaProgramModel.Bounds) -> [String] {
        [
            "            ; @amiga:draw_control \(id) slot=\(slot) bounds=\(bounds.x),\(bounds.y),\(bounds.width),\(bounds.height)",
            "            lea        ControlRect_\(id)(pc),a0",
            "            bsr        DrawControlRect"
        ]
    }

    private static func controlDrawLines(for controls: [AmigaProgramModel.Control]) -> [String] {
        controls.enumerated().flatMap { offset, control in
            drawControlLines(
                id: control.id,
                slot: offset + 1,
                bounds: control.bounds ?? defaultBounds(forControlAt: offset + 1)
            )
        }
    }

    private static func controlDispatchLines(for controls: [AmigaProgramModel.Control]) -> [String] {
        controls.enumerated().flatMap { offset, control in
            let slot = offset + 1
            return [
                #"            ; @amiga:dispatch \#(control.id) -> \#(control.action)"#,
                "            cmp.w      #\(slot),d0",
                "            bne.s      .skip_\(control.id)",
                "            bsr        \(control.action)",
                ".skip_\(control.id):"
            ]
        }
    }

    private static func controlRectDataLines(id: String, label: String, slot: Int, bounds: AmigaProgramModel.Bounds) -> [String] {
        [
            "ControlRect_\(id):",
            "            dc.w       \(bounds.x),\(bounds.y),\(bounds.width),\(bounds.height),\(slot)",
            "            dc.l       ControlLabel_\(id)",
            "ControlLabel_\(id):",
            #"            dc.b       "\#(assemblyStringLiteralText(for: label))",0"#,
            "            even"
        ]
    }

    private static func controlDataLines(for controls: [AmigaProgramModel.Control]) -> [String] {
        controls.enumerated().flatMap { offset, control in
            controlRectDataLines(
                id: control.id,
                label: control.label,
                slot: offset + 1,
                bounds: control.bounds ?? defaultBounds(forControlAt: offset + 1)
            )
        }
    }

    private static func assemblyStringLiteralText(for label: String) -> String {
        label.replacingOccurrences(of: #"""#, with: #""""#)
    }

    private static func controlSelectionStateVariables() -> [AmigaProgramModel.StateVariable] {
        [
            AmigaProgramModel.StateVariable(id: "selected_control", symbol: "SelectedControl", purpose: "One-based selected control slot for UI focus.", initialValue: "1"),
            AmigaProgramModel.StateVariable(id: "activated_control", symbol: "ActivatedControl", purpose: "One-frame control slot consumed by InputDispatch.", initialValue: "0"),
            AmigaProgramModel.StateVariable(id: "mouse_x", symbol: "MouseX", purpose: "Current mouse X coordinate for control hit testing.", initialValue: "40"),
            AmigaProgramModel.StateVariable(id: "mouse_y", symbol: "MouseY", purpose: "Current mouse Y coordinate for control hit testing.", initialValue: "48"),
            AmigaProgramModel.StateVariable(id: "mouse_raw_x", symbol: "MouseRawX", purpose: "Previous raw JOY0DAT X counter used to derive signed mouse deltas.", initialValue: "40"),
            AmigaProgramModel.StateVariable(id: "mouse_raw_y", symbol: "MouseRawY", purpose: "Previous raw JOY0DAT Y counter used to derive signed mouse deltas.", initialValue: "48"),
            AmigaProgramModel.StateVariable(id: "mouse_buttons", symbol: "MouseButtons", purpose: "Bit zero is one while the left mouse button is pressed.", initialValue: "0"),
            AmigaProgramModel.StateVariable(id: "mouse_was_buttons", symbol: "MouseWasButtons", purpose: "Previous frame mouse button state for click-edge detection.", initialValue: "0"),
            AmigaProgramModel.StateVariable(id: "mouse_clicked", symbol: "MouseClicked", purpose: "One for a single frame when the left mouse button transitions to pressed.", initialValue: "0")
        ]
    }

    private static func controlSelectionStateLines() -> [String] {
        [
            "SelectedControl: dc.w  1",
            "ActivatedControl: dc.w 0",
            "MouseX:     dc.w       40",
            "MouseY:     dc.w       48",
            "MouseRawX:  dc.w       40",
            "MouseRawY:  dc.w       48",
            "MouseButtons: dc.w     0",
            "MouseWasButtons: dc.w 0",
            "MouseClicked: dc.w     0"
        ]
    }

    private static func replaceInstructionImmediate(pattern: String, replacement: String, inRoutine label: String, source: String) throws -> String {
        guard let routineRange = routineBodyRange(label: label, in: source) else {
            throw AmigaProgramPatchError.missingRegion(label)
        }
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return source }
        let range = NSRange(routineRange, in: source)
        var result = source
        for match in regex.matches(in: source, range: range).reversed() {
            guard match.numberOfRanges > 1,
                  let matchRange = Range(match.range(at: 0), in: result),
                  let indentRange = Range(match.range(at: 1), in: result) else {
                continue
            }
            result.replaceSubrange(matchRange, with: "\(result[indentRange])\(replacement)")
        }
        return result
    }

    private static func routineBodyRange(label: String, in source: String) -> Range<String.Index>? {
        let lines = source.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        var lineStarts: [String.Index] = []
        var cursor = source.startIndex
        for line in lines {
            lineStarts.append(cursor)
            cursor = source.index(cursor, offsetBy: line.count)
            if cursor < source.endIndex, source[cursor] == "\n" {
                cursor = source.index(after: cursor)
            }
        }

        guard let startLineIndex = lines.firstIndex(where: { lineDefinesLabel($0, label: label) }) else {
            return nil
        }

        let bodyStartLine = startLineIndex + 1
        guard bodyStartLine < lineStarts.count else { return nil }
        let endLineIndex = lines[bodyStartLine...].firstIndex { line in
            if line.trimmingCharacters(in: .whitespaces).hasPrefix("; @amiga:region") {
                return true
            }
            return AmigaSourceIndexer.labelName(from: line) != nil
        } ?? lines.count

        let start = lineStarts[bodyStartLine]
        let end = endLineIndex < lineStarts.count ? lineStarts[endLineIndex] : source.endIndex
        return start..<end
    }

    private static func lineDefinesLabel(_ line: String, label: String) -> Bool {
        AmigaSourceIndexer.labelName(from: line) == label
    }

    private static func lineDefinesExactLabel(_ line: String, label: String) -> Bool {
        assemblyCodePrefix(beforeCommentIn: line)
            .trimmingCharacters(in: .whitespaces)
            .lowercased()
            .hasPrefix("\(label.lowercased()):")
    }

    private static func lineDefinesControlRectLabel(_ line: String) -> Bool {
        assemblyCodePrefix(beforeCommentIn: line)
            .trimmingCharacters(in: .whitespaces)
            .range(of: #"^ControlRect_[A-Za-z0-9_]+:"#, options: .regularExpression) != nil
    }

    private struct ControlPatchSpec {
        var purpose: String
        var stateVariables: [AmigaProgramModel.StateVariable]
        var stateLines: [String]
        var routineLines: [String]
    }

    private static func controlPatchSpec(label: String, controlID: String, actionLabel: String) throws -> ControlPatchSpec {
        let canonicalAction = actionLabel.lowercased()
        if canonicalAction == "volumeup" {
            return ControlPatchSpec(
                purpose: "Raises Paula channel 0 playback volume.",
                stateVariables: [
                    AmigaProgramModel.StateVariable(id: "audio_volume", symbol: "AudioVolume", purpose: "Current Paula channel 0 volume.", initialValue: "48")
                ],
                stateLines: [
                    "AudioVolume: dc.w      48"
                ],
                routineLines: [
                    "\(actionLabel):",
                    "            move.w     AudioVolume(pc),d0",
                    "            add.w      #4,d0",
                    "            cmp.w      #64,d0",
                    "            ble.s      .storeVolumeUp",
                    "            moveq      #64,d0",
                    ".storeVolumeUp:",
                    "            move.w     d0,AudioVolume",
                    "            lea        $dff000,a6",
                    "            move.w     d0,$a8(a6)        ; AUD0VOL",
                    "            rts"
                ]
            )
        }

        if canonicalAction == "volumedown" {
            return ControlPatchSpec(
                purpose: "Lowers Paula channel 0 playback volume.",
                stateVariables: [
                    AmigaProgramModel.StateVariable(id: "audio_volume", symbol: "AudioVolume", purpose: "Current Paula channel 0 volume.", initialValue: "48")
                ],
                stateLines: [
                    "AudioVolume: dc.w      48"
                ],
                routineLines: [
                    "\(actionLabel):",
                    "            move.w     AudioVolume(pc),d0",
                    "            sub.w      #4,d0",
                    "            bpl.s      .storeVolumeDown",
                    "            moveq      #0,d0",
                    ".storeVolumeDown:",
                    "            move.w     d0,AudioVolume",
                    "            lea        $dff000,a6",
                    "            move.w     d0,$a8(a6)        ; AUD0VOL",
                    "            rts"
                ]
            )
        }

        if canonicalAction == "mute" || canonicalAction == "mutemod" {
            return ControlPatchSpec(
                purpose: "Mutes Paula channel 0 without changing playback state.",
                stateVariables: [
                    AmigaProgramModel.StateVariable(id: "audio_volume", symbol: "AudioVolume", purpose: "Current Paula channel 0 volume.", initialValue: "48")
                ],
                stateLines: [
                    "AudioVolume: dc.w      48"
                ],
                routineLines: [
                    "\(actionLabel):",
                    "            clr.w      AudioVolume",
                    "            lea        $dff000,a6",
                    "            clr.w      $a8(a6)           ; AUD0VOL",
                    "            rts"
                ]
            )
        }

        if canonicalAction == "pause" || canonicalAction == "pausemod" {
            return ControlPatchSpec(
                purpose: "Pauses Paula channel 0 playback while preserving the play controls.",
                stateVariables: [
                    AmigaProgramModel.StateVariable(id: "playback_state", symbol: "PlaybackState", purpose: "Zero when stopped, one when playing.", initialValue: "0")
                ],
                stateLines: [
                    "PlaybackState: dc.w    0"
                ],
                routineLines: [
                    "\(actionLabel):",
                    "            lea        $dff000,a6",
                    "            move.w     #$0001,$96(a6)       ; clear AUD0 DMA bit",
                    "            clr.w      PlaybackState",
                    "            rts"
                ]
            )
        }

        if controlID == "volume_up" {
            return try controlPatchSpec(label: label, controlID: "", actionLabel: "VolumeUp")
        }

        if controlID == "volume_down" {
            return try controlPatchSpec(label: label, controlID: "", actionLabel: "VolumeDown")
        }

        if controlID == "mute" {
            return try controlPatchSpec(label: label, controlID: "", actionLabel: "Mute")
        }

        if controlID == "pause" {
            return try controlPatchSpec(label: label, controlID: "", actionLabel: "PauseMOD")
        }

        throw AmigaProgramPatchError.unsupportedControl(label)
    }
}

enum AmigaProgramTemplate {
    static let blitterBOBCollisionBoundsID = "blitter-bob-collision-bounds"
    static let cleanTakeoverRestoreID = "clean-takeover"
    static let intuitionWindowToolID = "intuition-window-tool"

    static func blitterBOBCollisionBoundsSource(
        horizontalSpeed: Int = 2,
        targetLeft: Int = 128,
        targetRight: Int = 176,
        collisionColor: String = "red"
    ) throws -> String {
        let normalizedCollisionColor = normalizedColorName(collisionColor, fallback: "red")
        let collisionColorValue = colorValue(named: normalizedCollisionColor) ?? "$0f00"
        let model = AmigaProgramModel(
            id: blitterBOBCollisionBoundsID,
            kind: .effect,
            routines: [
                AmigaProgramModel.Routine(id: "wait_vblank", label: "WaitVBlank", purpose: "Paces object updates to vertical blank."),
                AmigaProgramModel.Routine(id: "update_bob_position", label: "UpdateBOBPosition", purpose: "Moves the BOB and bounces it inside visible screen bounds."),
                AmigaProgramModel.Routine(id: "check_collision", label: "CheckCollision", purpose: "Tests the BOB against the target rectangle and records collision state."),
                AmigaProgramModel.Routine(id: "draw_bob", label: "DrawBOB", purpose: "Programs a masked cookie-cut blitter draw for the BOB.", calls: ["WaitBlitter"]),
                AmigaProgramModel.Routine(id: "wait_blitter", label: "WaitBlitter", purpose: "Waits until the blitter is idle before programming or after starting a blit.")
            ],
            stateVariables: [
                AmigaProgramModel.StateVariable(id: "bob_x", symbol: "BOBX", purpose: "Current bounded BOB X position.", initialValue: "24"),
                AmigaProgramModel.StateVariable(id: "bob_y", symbol: "BOBY", purpose: "Current bounded BOB Y position.", initialValue: "48"),
                AmigaProgramModel.StateVariable(id: "bob_dx", symbol: "BOBDX", purpose: "Signed horizontal BOB velocity.", initialValue: "\(horizontalSpeed)"),
                AmigaProgramModel.StateVariable(id: "bob_dy", symbol: "BOBDY", purpose: "Signed vertical BOB velocity.", initialValue: "1"),
                AmigaProgramModel.StateVariable(id: "target_left", symbol: "TargetLeft", purpose: "Collision target left edge.", initialValue: "\(targetLeft)"),
                AmigaProgramModel.StateVariable(id: "target_top", symbol: "TargetTop", purpose: "Collision target top edge.", initialValue: "72"),
                AmigaProgramModel.StateVariable(id: "target_right", symbol: "TargetRight", purpose: "Collision target right edge.", initialValue: "\(targetRight)"),
                AmigaProgramModel.StateVariable(id: "target_bottom", symbol: "TargetBottom", purpose: "Collision target bottom edge.", initialValue: "120"),
                AmigaProgramModel.StateVariable(id: "collision_state", symbol: "CollisionState", purpose: "Set to one while the BOB overlaps the target rectangle.", initialValue: "0"),
                AmigaProgramModel.StateVariable(id: "collision_color", symbol: "CollisionColor", purpose: "COLOR01 value written when collision is detected.", initialValue: collisionColorValue),
                AmigaProgramModel.StateVariable(id: "exit_delay", symbol: "ExitDelay", purpose: "Initial vblank countdown before honoring left mouse exit.", initialValue: "90")
            ],
            hardware: [.bitplanes, .blitter, .cia, .copper],
            verificationExpectations: [
                "BOB motion stays bounded before blitter pointer setup.",
                "Masked blitter draw waits before programming and after BLTSIZE.",
                "Collision state drives a visible COLOR01 change.",
                "Left mouse click exits cleanly."
            ]
        )

        return """
\(try AmigaSourceIndexer.modelRegion(for: model))
; Blitter BOB collision bounds template.
; Effect: bounded masked BOB with rectangle collision color
            SECTION    Code,CODE,CHIP
            XDEF       _Start
_Start:
            movem.l    d2-d7/a2-a6,-(sp)
            lea        $dff000,a6
            move.w     #$7fff,$9a(a6)       ; INTENA: disable OS interrupts for hardware-owned frame
            move.w     #$7fff,$9c(a6)       ; INTREQ: clear pending interrupts
            move.w     #$7fff,$96(a6)       ; DMACON: clear OS DMA/copper before direct display setup
            lea        Bitplane,a0
            move.l     a0,$e0(a6)           ; BPL1PT
            move.w     #$1200,$100(a6)      ; BPLCON0: one low-res bitplane
            move.w     #$0000,$102(a6)
            move.w     #$0000,$104(a6)
            move.w     #$000,$180(a6)       ; COLOR00 background
            move.w     #$0f0,$182(a6)       ; COLOR01 non-collision object
            lea        Bitplane,a0
            move.l     a0,d0
            lea        CopperBplHi,a1
            swap       d0
            move.w     d0,(a1)
            swap       d0
            move.w     d0,4(a1)
            moveq      #0,d0
            move.w     #(40*256/4)-1,d1
.clearBitplane:
            move.l     d0,(a0)+
            dbra       d1,.clearBitplane
            move.w     #90,ExitDelay
            lea        CopperList,a0
            move.l     a0,$80(a6)           ; COP1LC
            move.w     #$0000,$88(a6)       ; COPJMP1
            move.w     #$83c0,$96(a6)       ; DMAEN + bitplane DMA + copper DMA + blitter DMA
            bsr        DrawBOB

.main:
            bsr        WaitVBlank
            tst.w      ExitDelay
            beq.s      .mouseExitArmed
            subq.w     #1,ExitDelay
            bra.s      .updateFrame
.mouseExitArmed:
            btst       #6,$bfe001
            beq        .done
.updateFrame:
            bsr        UpdateBOBPosition
            bsr        CheckCollision
            bsr        DrawBOB
            bra        .main

.done:
            move.w     #$0100,$96(a6)
            movem.l    (sp)+,d2-d7/a2-a6
            moveq      #0,d0
            rts

            ; @amiga:region controls begin
            ; @amiga:region controls end

            ; @amiga:region draw_controls begin
            ; @amiga:region draw_controls end

            ; @amiga:region hit_test begin
WaitVBlank:
            cmp.b      #$ff,$06(a6)
            bne.s      WaitVBlank
.leave:
            cmp.b      #$ff,$06(a6)
            beq.s      .leave
            rts
            ; @amiga:region hit_test end

            ; @amiga:region input_dispatch begin
            ; @amiga:region input_dispatch end

            ; @amiga:region routines begin
UpdateBOBPosition:
            move.w     BOBX(pc),d0
            add.w      BOBDX(pc),d0
            cmp.w      #16,d0
            bge.s      .rightBound
            move.w     #16,d0
            neg.w      BOBDX
.rightBound:
            cmp.w      #288,d0
            ble.s      .storeX
            move.w     #288,d0
            neg.w      BOBDX
.storeX:
            move.w     d0,BOBX
            move.w     BOBY(pc),d1
            add.w      BOBDY(pc),d1
            cmp.w      #32,d1
            bge.s      .bottomBound
            move.w     #32,d1
            neg.w      BOBDY
.bottomBound:
            cmp.w      #176,d1
            ble.s      .storeY
            move.w     #176,d1
            neg.w      BOBDY
.storeY:
            move.w     d1,BOBY
            rts

CheckCollision:
            clr.w      CollisionState
            move.w     BOBX(pc),d0
            cmp.w      TargetRight(pc),d0
            bgt.s      .noCollision
            add.w      #16,d0
            cmp.w      TargetLeft(pc),d0
            blt.s      .noCollision
            move.w     BOBY(pc),d1
            cmp.w      TargetBottom(pc),d1
            bgt.s      .noCollision
            add.w      #16,d1
            cmp.w      TargetTop(pc),d1
            blt.s      .noCollision
            move.w     #1,CollisionState
            move.w     CollisionColor(pc),$182(a6) ; COLOR01 collision evidence
            rts
.noCollision:
            move.w     #$0f0,$182(a6)
            rts

DrawBOB:
            bsr        WaitBlitter
            move.w     BOBY(pc),d0
            mulu       #40,d0
            move.w     BOBX(pc),d1
            lsr.w      #3,d1
            add.w      d1,d0
            lea        Bitplane,a2
            adda.w     d0,a2
            lea        BOBMask,a0
            lea        BOBImage,a1
            move.w     #$ffff,$44(a6)       ; BLTAFWM
            move.w     #$ffff,$46(a6)       ; BLTALWM
            move.w     #$0fca,$40(a6)       ; cookie-cut A/B/C to D
            move.w     #$0000,$42(a6)
            move.w     #0,$64(a6)           ; BLTAMOD
            move.w     #0,$62(a6)           ; BLTBMOD
            move.w     #38,$60(a6)          ; BLTCMOD
            move.w     #38,$66(a6)          ; BLTDMOD
            move.l     a0,$50(a6)           ; A = mask
            move.l     a1,$4c(a6)           ; B = image
            move.l     a2,$48(a6)           ; C = destination
            move.l     a2,$54(a6)           ; D = destination
            move.w     #(16*64)+1,$58(a6)   ; BLTSIZE: 16 rows, one word
.waitAfter:
            btst       #6,$02(a6)
            bne.s      .waitAfter
            rts

WaitBlitter:
            btst       #6,$02(a6)
            bne.s      WaitBlitter
            rts
            ; @amiga:region routines end

            ; @amiga:region state begin
BOBX:           dc.w       24
BOBY:           dc.w       48
BOBDX:          dc.w       \(horizontalSpeed)
BOBDY:          dc.w       1
TargetLeft:     dc.w       \(targetLeft)
TargetTop:      dc.w       72
TargetRight:    dc.w       \(targetRight)
TargetBottom:   dc.w       120
CollisionState: dc.w       0
CollisionColor: dc.w       \(collisionColorValue)       ; \(normalizedCollisionColor) collision COLOR01
ExitDelay:      dc.w       90
            ; @amiga:region state end

            SECTION    ChipData,DATA,CHIP
            ; @amiga:region chip_data begin
            ALIGN      2
CopperList:
            dc.w       $0100,$1200          ; BPLCON0: one low-res bitplane
            dc.w       $00e0
CopperBplHi:
            dc.w       0
            dc.w       $00e2
CopperBplLo:
            dc.w       0
            dc.w       $0180,$0000          ; COLOR00
            dc.w       $0182,$00f0          ; COLOR01
            dc.w       $ffff,$fffe
BOBMask:
            dc.w       $07e0,$1ff8,$3ffc,$7ffe
            dc.w       $7ffe,$ffff,$ffff,$ffff
            dc.w       $ffff,$ffff,$7ffe,$7ffe
            dc.w       $3ffc,$1ff8,$07e0,$0000
BOBImage:
            dc.w       $0180,$0660,$0ff0,$1998
            dc.w       $3ffc,$2664,$5ffa,$599a
            dc.w       $599a,$5ffa,$2664,$3ffc
            dc.w       $1998,$0ff0,$0660,$0180

Bitplane:   ds.b       40*256
            ; @amiga:region chip_data end
"""
    }

    static func verifiedBlitterBOBCollisionBoundsSource(
        horizontalSpeed: Int = 2,
        targetLeft: Int = 128,
        targetRight: Int = 176,
        collisionColor: String = "red"
    ) throws -> String {
        let source = try blitterBOBCollisionBoundsSource(
            horizontalSpeed: horizontalSpeed,
            targetLeft: targetLeft,
            targetRight: targetRight,
            collisionColor: collisionColor
        )
        return try verifiedModelBackedSource(source)
    }

    static func cleanTakeoverRestoreModel(
        paletteMode: String = "amber",
        copperSplitEnabled: Bool = false,
        vblankDivider: Int = 1,
        rightMouseRestoreEnabled: Bool = false
    ) -> AmigaProgramModel {
        let boundedDivider = max(1, min(vblankDivider, 4))
        var expectations = [
            "Graphics view, DMA, interrupt, copper pointer, and COLOR00 state are saved before takeover.",
            "Every user exit path calls RestoreSystem before returning.",
            "RestoreSystem restores COLOR00, COP1LC, DMACON, INTENA, INTREQ, LoadView(oldView), and CloseLibrary.",
            "Color cycling is paced by vertical blank."
        ]
        if paletteMode == "green" {
            expectations.append("Cycling palette uses green tones.")
        }
        if copperSplitEnabled {
            expectations.append("Copper split is enabled while preserving restore.")
        }
        if boundedDivider == 2 {
            expectations.append("Color cycling updates every other vblank.")
        }
        if rightMouseRestoreEnabled {
            expectations.append("Right mouse also routes through RestoreSystem.")
        }

        return AmigaProgramModel(
            id: cleanTakeoverRestoreID,
            kind: .effect,
            routines: [
                AmigaProgramModel.Routine(id: "wait_vblank", label: "WaitVBlank", purpose: "Paces the takeover effect to vertical blank."),
                AmigaProgramModel.Routine(id: "check_restore_input", label: "CheckRestoreInput", purpose: "Checks mouse restore exits without bypassing RestoreSystem."),
                AmigaProgramModel.Routine(id: "cycle_color", label: "CycleColor", purpose: "Advances COLOR00 through the modeled palette."),
                AmigaProgramModel.Routine(id: "restore_system", label: "RestoreSystem", purpose: "Restores every saved OS display, DMA, interrupt, copper, and palette state.")
            ],
            stateVariables: [
                AmigaProgramModel.StateVariable(id: "gfx_base", symbol: "GfxBase", purpose: "Opened graphics.library base pointer.", initialValue: nil),
                AmigaProgramModel.StateVariable(id: "old_view", symbol: "OldView", purpose: "Saved graphics View pointer.", initialValue: nil),
                AmigaProgramModel.StateVariable(id: "old_dmacon", symbol: "OldDMACON", purpose: "Saved readable DMACONR value.", initialValue: "0"),
                AmigaProgramModel.StateVariable(id: "old_intena", symbol: "OldINTENA", purpose: "Saved readable INTENAR value.", initialValue: "0"),
                AmigaProgramModel.StateVariable(id: "old_cop1lc", symbol: "OldCOP1LC", purpose: "Saved original copper list pointer.", initialValue: nil),
                AmigaProgramModel.StateVariable(id: "old_color00", symbol: "OldColor00", purpose: "Saved COLOR00 value.", initialValue: "0"),
                AmigaProgramModel.StateVariable(id: "color_phase", symbol: "ColorPhase", purpose: "Current index into ColorTable.", initialValue: "0"),
                AmigaProgramModel.StateVariable(id: "frame_skip_counter", symbol: "FrameSkipCounter", purpose: "Counts vblanks between color updates.", initialValue: "0"),
                AmigaProgramModel.StateVariable(id: "vblank_divider", symbol: "VBlankDivider", purpose: "Number of vblanks between color updates.", initialValue: "\(boundedDivider)"),
                AmigaProgramModel.StateVariable(id: "palette_mode", symbol: "PaletteMode", purpose: "One selects green cycling palette, zero selects amber palette.", initialValue: paletteMode == "green" ? "1" : "0"),
                AmigaProgramModel.StateVariable(id: "copper_split_enabled", symbol: "CopperSplitEnabled", purpose: "One when the owned copper list includes a mid-screen split.", initialValue: copperSplitEnabled ? "1" : "0"),
                AmigaProgramModel.StateVariable(id: "right_mouse_restore_enabled", symbol: "RightMouseRestoreEnabled", purpose: "One when right mouse can trigger RestoreSystem.", initialValue: rightMouseRestoreEnabled ? "1" : "0")
            ],
            hardware: [.exec, .graphics, .cia, .copper],
            verificationExpectations: expectations
        )
    }

    static func cleanTakeoverRestoreSource(model suppliedModel: AmigaProgramModel? = nil) throws -> String {
        let model = suppliedModel ?? cleanTakeoverRestoreModel()
        let paletteMode = cleanTakeoverStateValue("palette_mode", in: model, fallback: "0") == "1" ? "green" : "amber"
        let copperSplitEnabled = cleanTakeoverStateValue("copper_split_enabled", in: model, fallback: "0") == "1"
        let rightMouseRestoreEnabled = cleanTakeoverStateValue("right_mouse_restore_enabled", in: model, fallback: "0") == "1"
        let vblankDivider = Int(cleanTakeoverStateValue("vblank_divider", in: model, fallback: "1")) ?? 1
        let boundedDivider = max(1, min(vblankDivider, 4))
        let colors = paletteMode == "green"
            ? ["$0020", "$0040", "$0060", "$0080"]
            : ["$0040", "$0060", "$0080", "$00a0"]
        let colorComment = paletteMode == "green" ? "green tone" : "amber tone"
        let rightMouseLines = rightMouseRestoreEnabled ? """
            move.w     RightMouseRestoreEnabled(pc),d1
            beq.s      .noRestoreInput
            btst       #2,$dff016
            beq.s      .restoreRequested
.noRestoreInput:
""" : """
.noRestoreInput:
"""
        let copperSplitLines = copperSplitEnabled ? """
            dc.w       $7f07,$fffe
            dc.w       $0180,$0020          ; optional copper split color
""" + "\n" : ""

        return """
\(try AmigaSourceIndexer.modelRegion(for: model))
; Clean takeover skeleton template.
; Saves view, DMA, interrupts, copper pointer, and COLOR00, runs a
; vblank-paced color cycle, then restores every saved state on exit.
            SECTION    Code,CODE,CHIP
            XDEF       _Start
_Start:
            movem.l    d2-d7/a2-a6,-(sp)
            move.l     $4.w,a6
            lea        GfxName(pc),a1
            moveq      #0,d0
            jsr        -408(a6)             ; OpenLibrary("graphics.library")
            move.l     d0,GfxBase
            beq        .exit

            move.l     d0,a6
            move.l     34(a6),OldView       ; save OS view
            sub.l      a1,a1
            jsr        -222(a6)             ; LoadView(NULL)
            jsr        -270(a6)             ; WaitTOF
            jsr        -270(a6)

            lea        $dff000,a6
            move.w     $02(a6),OldDMACON    ; save DMACONR
            move.w     $1c(a6),OldINTENA    ; save INTENAR
            move.l     $80(a6),d0           ; save COP1LC
            move.l     d0,OldCOP1LC
            move.w     $180(a6),OldColor00  ; save palette color 0
            move.w     #$7fff,$9c(a6)       ; acknowledge pending INTREQ bits
            move.w     #$7fff,$9a(a6)       ; disable interrupts during takeover
            move.w     #$7fff,$96(a6)       ; clear old DMA before installing copper
            lea        CopperList(pc),a0
            move.l     a0,$80(a6)           ; COP1LC
            move.w     #0,$88(a6)           ; COPJMP1
            move.w     #$8280,$96(a6)       ; DMAEN + COPEN

.main:
            bsr        CheckRestoreInput
            tst.w      d0
            bne.s      .restore
            bsr        WaitVBlank
            addq.w     #1,FrameSkipCounter
            move.w     FrameSkipCounter(pc),d0
            cmp.w      VBlankDivider(pc),d0
            blt.s      .main
            clr.w      FrameSkipCounter
            bsr        CycleColor
            bra.s      .main

.restore:
            bsr        RestoreSystem

.exit:
            movem.l    (sp)+,d2-d7/a2-a6
            moveq      #0,d0
            rts

            ; @amiga:region controls begin
            ; @amiga:region controls end

            ; @amiga:region draw_controls begin
            ; @amiga:region draw_controls end

            ; @amiga:region hit_test begin
WaitVBlank:
            lea        $dff000,a6
            cmp.b      #$ff,$06(a6)
            bne.s      WaitVBlank
.leaveVBlank:
            cmp.b      #$ff,$06(a6)
            beq.s      .leaveVBlank
            rts

CheckRestoreInput:
            moveq      #0,d0
            btst       #6,$bfe001
            beq.s      .restoreRequested
\(rightMouseLines)            rts
.restoreRequested:
            moveq      #1,d0
            rts
            ; @amiga:region hit_test end

            ; @amiga:region input_dispatch begin
            ; @amiga:region input_dispatch end

            ; @amiga:region routines begin
CycleColor:
            lea        $dff000,a6
            move.w     ColorPhase(pc),d0
            addq.w     #1,d0
            and.w      #$0003,d0
            move.w     d0,ColorPhase
            lea        ColorTable(pc),a0
            add.w      d0,d0
            move.w     (a0,d0.w),$180(a6)
            rts

RestoreSystem:
            lea        $dff000,a6
            move.w     OldColor00(pc),$180(a6)
            move.l     OldCOP1LC(pc),d0
            move.l     d0,$80(a6)
            move.w     #0,$88(a6)
            move.w     #$7fff,$96(a6)
            move.w     OldDMACON(pc),d0
            or.w       #$8000,d0
            move.w     d0,$96(a6)
            move.w     #$7fff,$9a(a6)
            move.w     OldINTENA(pc),d0
            or.w       #$8000,d0
            move.w     d0,$9a(a6)
            move.w     #$7fff,$9c(a6)
            move.l     GfxBase(pc),a6
            move.l     OldView(pc),a1
            jsr        -222(a6)             ; LoadView(oldView)
            jsr        -270(a6)
            jsr        -270(a6)
            move.l     $4.w,a6
            move.l     GfxBase(pc),a1
            jsr        -414(a6)
            clr.l      GfxBase
            rts
            ; @amiga:region routines end

            ; @amiga:region state begin
GfxBase:    dc.l       0
OldView:    dc.l       0
OldDMACON:  dc.w       0
OldINTENA:  dc.w       0
OldCOP1LC:  dc.l       0
OldColor00: dc.w       0
ColorPhase: dc.w       0
FrameSkipCounter: dc.w 0
VBlankDivider: dc.w    \(boundedDivider)
PaletteMode: dc.w      \(paletteMode == "green" ? 1 : 0)
CopperSplitEnabled: dc.w \(copperSplitEnabled ? 1 : 0)
RightMouseRestoreEnabled: dc.w \(rightMouseRestoreEnabled ? 1 : 0)
            ; @amiga:region state end

            ; @amiga:region chip_data begin
GfxName:    dc.b       "graphics.library",0
            EVEN
ColorTable: dc.w       \(colors[0]),\(colors[1]),\(colors[2]),\(colors[3]) ; \(colorComment) cycle

CopperList:
            dc.w       $0100,$0200
            dc.w       $0180,$004
\(copperSplitLines)            dc.w $ffff,$fffe
            ; @amiga:region chip_data end
"""
    }

    static func verifiedCleanTakeoverRestoreSource(model: AmigaProgramModel? = nil) throws -> String {
        let source = try cleanTakeoverRestoreSource(model: model)
        return try verifiedModelBackedSource(source)
    }

    static func doubleBufferedBitplaneSource(frontColor: String = "yellow", backColor: String = "cyan") throws -> String {
        let normalizedFrontColor = normalizedColorName(frontColor, fallback: "yellow")
        let normalizedBackColor = normalizedColorName(backColor, fallback: "cyan")
        let frontValue = colorValue(named: normalizedFrontColor) ?? "$0ff0"
        let backValue = colorValue(named: normalizedBackColor) ?? "$00ff"
        let model = AmigaProgramModel(
            id: "double-buffer-bitplane",
            kind: .effect,
            routines: [
                AmigaProgramModel.Routine(id: "draw_buffer_a", label: "DrawBufferA", purpose: "Draws the next frame into front buffer A.", calls: ["CopyPattern"]),
                AmigaProgramModel.Routine(id: "draw_buffer_b", label: "DrawBufferB", purpose: "Draws the next frame into back buffer B.", calls: ["CopyPattern"]),
                AmigaProgramModel.Routine(id: "copy_pattern", label: "CopyPattern", purpose: "Copies the selected bitplane pattern into the hidden buffer."),
                AmigaProgramModel.Routine(id: "patch_copper_bitplane", label: "PatchCopperBitplane", purpose: "Patches the owned copper list with the currently visible bitplane pointer."),
                AmigaProgramModel.Routine(id: "patch_copper_sprite", label: "PatchCopperSprite", purpose: "Patches the owned copper list with the sprite pointer used as overlay evidence."),
                AmigaProgramModel.Routine(id: "wait_vblank", label: "WaitVBlank", purpose: "Paces bitplane pointer swaps to vertical blank.")
            ],
            stateVariables: [
                AmigaProgramModel.StateVariable(id: "front_color", symbol: "FrontColor", purpose: "COLOR01 value used while BufferA is visible.", initialValue: frontValue),
                AmigaProgramModel.StateVariable(id: "back_color", symbol: "BackColor", purpose: "COLOR01 value used while BufferB is visible.", initialValue: backValue)
            ],
            hardware: [.bitplanes, .sprites, .copper, .cia],
            verificationExpectations: [
                "Front buffer color is \(normalizedFrontColor).",
                "Back buffer color is \(normalizedBackColor).",
                "An owned copper list refreshes the display, palette, and sprite pointers.",
                "Sprite DMA overlays the bitplane buffer as runtime interaction evidence.",
                "Bitplane pointer swaps are paced by vblank.",
                "Left mouse click exits cleanly."
            ]
        )

        return """
\(try AmigaSourceIndexer.modelRegion(for: model))
; Double-buffered bitplane animation template.
            SECTION    Code,CODE,CHIP
            XDEF       _Start
_Start:
            movem.l    d2/a2-a4/a6,-(sp)
            lea        $dff000,a6
            move.w     #$7fff,$9a(a6)      ; disable OS interrupts for owned hardware frame
            move.w     #$7fff,$9c(a6)      ; clear pending interrupt requests
            move.w     #$7fff,$96(a6)      ; stop inherited DMA before display setup
            lea        BufferA,a2
            lea        BufferB,a3
            lea        SpriteData,a4
            move.w     #$1200,$100(a6)      ; BPLCON0: one low-res bitplane
            move.w     #$0000,$102(a6)      ; BPLCON1
            move.w     #$0000,$104(a6)      ; BPLCON2
            move.w     #$0000,$108(a6)      ; BPL1MOD
            move.w     #$0000,$10a(a6)      ; BPL2MOD
            move.w     #$0000,$180(a6)
            move.w     FrontColor(pc),$182(a6)
            move.l     a2,$e0(a6)           ; BPL1PT
            move.l     a4,$120(a6)          ; SPR0PT
            move.l     a2,d0
            bsr.w      PatchCopperBitplane
            move.l     a4,d0
            bsr.w      PatchCopperSprite
            lea        CopperList,a0
            move.l     a0,$80(a6)           ; COP1LC
            move.w     #$0000,$88(a6)       ; COPJMP1
            move.w     #$83a0,$96(a6)       ; master + bitplane + copper + sprite DMA

            moveq      #0,d2
.main:
            btst       #6,$bfe001
            beq.s      .done
            bsr.s      WaitVBlank
            tst.b      d2
            bne.s      .showB
.showA:
            move.w     FrontColor(pc),$182(a6) ; COLOR01 for BufferA/front frame
            move.l     a2,$e0(a6)           ; BPL1PT
            move.l     a2,d0
            bsr.w      PatchCopperBitplane
            bsr.s      DrawBufferB
            moveq      #1,d2
            bra.s      .main
.showB:
            move.w     BackColor(pc),$182(a6) ; COLOR01 for BufferB/back frame
            move.l     a3,$e0(a6)           ; BPL1PT
            move.l     a3,d0
            bsr.w      PatchCopperBitplane
            bsr.s      DrawBufferA
            moveq      #0,d2
            bra.s      .main

.done:
            move.w     #$03a0,$96(a6)
            movem.l    (sp)+,d2/a2-a4/a6
            moveq      #0,d0
            rts

            ; @amiga:region controls begin
            ; @amiga:region controls end

            ; @amiga:region draw_controls begin
            ; @amiga:region draw_controls end

            ; @amiga:region hit_test begin
WaitVBlank:
            cmp.b      #$ff,$06(a6)
            bne.s      WaitVBlank
.leave:
            cmp.b      #$ff,$06(a6)
            beq.s      .leave
            rts

PatchCopperBitplane:
            lea        CopperBplHi,a0
            swap       d0
            move.w     d0,(a0)
            swap       d0
            move.w     d0,4(a0)
            move.w     #$0000,$88(a6)
            rts

PatchCopperSprite:
            lea        CopperSpr0Hi,a0
            swap       d0
            move.w     d0,(a0)
            swap       d0
            move.w     d0,4(a0)
            rts
            ; @amiga:region hit_test end

            ; @amiga:region input_dispatch begin
            ; @amiga:region input_dispatch end

            ; @amiga:region routines begin
DrawBufferA:
            lea        BufferA,a0
            lea        PatternA,a1
            bra.s      CopyPattern

DrawBufferB:
            lea        BufferB,a0
            lea        PatternB,a1
            bra.s      CopyPattern

CopyPattern:
            moveq      #31,d0
.copy:
            move.l     (a1)+,(a0)+
            dbf        d0,.copy
            rts
            ; @amiga:region routines end

            ; @amiga:region state begin
FrontColor: dc.w       \(frontValue)                ; \(normalizedFrontColor) foreground for BufferA
BackColor:  dc.w       \(backValue)                ; \(normalizedBackColor) foreground for BufferB
            ; @amiga:region state end

            SECTION    ChipData,DATA,CHIP
            ; @amiga:region chip_data begin
BufferA:    ds.b       40*256
BufferB:    ds.b       40*256
PatternA:
            dcb.l      32,$aaaaaaaa
PatternB:
            dcb.l      32,$55555555
CopperList:
            dc.w       $0100,$1200          ; BPLCON0: one low-res bitplane
            dc.w       $00e0
CopperBplHi:
            dc.w       0
            dc.w       $00e2
CopperBplLo:
            dc.w       0
            dc.w       $0120
CopperSpr0Hi:
            dc.w       0
            dc.w       $0122
CopperSpr0Lo:
            dc.w       0
            dc.w       $0180,$0000
            dc.w       $0182,\(frontValue)
            dc.w       $ffff,$fffe
SpriteData:
            dc.w       $4060,$4800
            dc.w       $03c0,$03c0
            dc.w       $07e0,$07e0
            dc.w       $0ff0,$0ff0
            dc.w       $1ff8,$1ff8
            dc.w       $0ff0,$0ff0
            dc.w       $07e0,$07e0
            dc.w       $03c0,$03c0
            dc.w       $0000,$0000
            ; @amiga:region chip_data end
"""
    }

    static func verifiedDoubleBufferedBitplaneSource(frontColor: String = "yellow", backColor: String = "cyan") throws -> String {
        let source = try doubleBufferedBitplaneSource(frontColor: frontColor, backColor: backColor)
        return try verifiedModelBackedSource(source)
    }

    static func modPlayerControlsSource() throws -> String {
        let model = AmigaProgramModel(
            id: "mod-player-controls",
            kind: .audioPlayer,
            controls: [
                AmigaProgramModel.Control(id: "play", label: "Play", action: "PlayMOD", bounds: .init(x: 32, y: 40, width: 72, height: 20)),
                AmigaProgramModel.Control(id: "stop", label: "Stop", action: "StopMOD", bounds: .init(x: 120, y: 40, width: 72, height: 20))
            ],
            routines: [
                AmigaProgramModel.Routine(id: "play", label: "PlayMOD", purpose: "Starts Paula channel 0 sample playback."),
                AmigaProgramModel.Routine(id: "stop", label: "StopMOD", purpose: "Stops Paula channel 0 playback."),
                AmigaProgramModel.Routine(id: "draw_controls", label: "DrawControls", purpose: "Emits the model-backed UI control geometry for rendering.", calls: ["DrawControlRect"]),
                AmigaProgramModel.Routine(id: "draw_control_rect", label: "DrawControlRect", purpose: "Draws one control rectangle into the UI bitplane buffer.", calls: ["DrawControlLabel"]),
                AmigaProgramModel.Routine(id: "draw_control_label", label: "DrawControlLabel", purpose: "Draws one control label into the UI bitplane buffer."),
                AmigaProgramModel.Routine(id: "wait_vblank", label: "WaitVBlank", purpose: "Paces the UI loop to vertical blank."),
                AmigaProgramModel.Routine(id: "read_mouse", label: "ReadMouseControls", purpose: "Samples JOY0DAT and CIAA left mouse button into UI input state."),
                AmigaProgramModel.Routine(id: "hit_test", label: "HitTestControls", purpose: "Maps mouse coordinates to the selected UI control slot."),
                AmigaProgramModel.Routine(id: "dispatch", label: "InputDispatch", purpose: "Dispatches the selected UI control to its action routine.", calls: ["PlayMOD", "StopMOD"])
            ],
            stateVariables: [
                AmigaProgramModel.StateVariable(id: "selected_control", symbol: "SelectedControl", purpose: "One-based selected control slot for UI focus.", initialValue: "1"),
                AmigaProgramModel.StateVariable(id: "activated_control", symbol: "ActivatedControl", purpose: "One-frame control slot consumed by InputDispatch.", initialValue: "0"),
                AmigaProgramModel.StateVariable(id: "mouse_x", symbol: "MouseX", purpose: "Current mouse X coordinate for control hit testing.", initialValue: "40"),
                AmigaProgramModel.StateVariable(id: "mouse_y", symbol: "MouseY", purpose: "Current mouse Y coordinate for control hit testing.", initialValue: "48"),
                AmigaProgramModel.StateVariable(id: "mouse_raw_x", symbol: "MouseRawX", purpose: "Previous raw JOY0DAT X counter used to derive signed mouse deltas.", initialValue: "40"),
                AmigaProgramModel.StateVariable(id: "mouse_raw_y", symbol: "MouseRawY", purpose: "Previous raw JOY0DAT Y counter used to derive signed mouse deltas.", initialValue: "48"),
                AmigaProgramModel.StateVariable(id: "mouse_buttons", symbol: "MouseButtons", purpose: "Bit zero is one while the left mouse button is pressed.", initialValue: "0"),
                AmigaProgramModel.StateVariable(id: "mouse_was_buttons", symbol: "MouseWasButtons", purpose: "Previous frame mouse button state for click-edge detection.", initialValue: "0"),
                AmigaProgramModel.StateVariable(id: "mouse_clicked", symbol: "MouseClicked", purpose: "One for a single frame when the left mouse button transitions to pressed.", initialValue: "0"),
                AmigaProgramModel.StateVariable(id: "playback_state", symbol: "PlaybackState", purpose: "Zero when stopped, one when playing.", initialValue: "0"),
                AmigaProgramModel.StateVariable(id: "audio_volume", symbol: "AudioVolume", purpose: "Current Paula channel 0 volume.", initialValue: "48")
            ],
            hardware: [.paula, .cia, .bitplanes],
            verificationExpectations: [
                "Play dispatches to PlayMOD.",
                "Stop dispatches to StopMOD.",
                "Startup previews PlayMOD for emulator-visible Paula register evidence.",
                "Playback state is preserved as data for follow-up edits."
            ]
        )

        return """
\(try AmigaSourceIndexer.modelRegion(for: model))
; Model-backed MOD player control scaffold.
            SECTION    Code,CODE
            XDEF       _Start
_Start:
            bsr        PlayMOD              ; boot-time preview for runtime Paula register evidence
            bsr        DrawControls
.mainLoop:
            bsr        WaitVBlank
            bsr        ReadMouseControls
            bsr        HitTestControls
            bsr        InputDispatch
            bra.s      .mainLoop

            ; @amiga:region controls begin
            ; @amiga:model control id=play label="Play" action=PlayMOD bounds=32,40,72,20
            ; @amiga:model control id=stop label="Stop" action=StopMOD bounds=120,40,72,20
            ; @amiga:region controls end

            ; @amiga:region draw_controls begin
DrawControls:
            ; @amiga:draw_control play slot=1 bounds=32,40,72,20
            lea        ControlRect_play(pc),a0
            bsr        DrawControlRect
            ; @amiga:draw_control stop slot=2 bounds=120,40,72,20
            lea        ControlRect_stop(pc),a0
            bsr        DrawControlRect
            rts

DrawControlRect:
            ; Rectangle record format: x, y, width, height, slot, label pointer.
            movem.l    d0-d7/a1-a3,-(sp)
            move.w     (a0)+,d0
            move.w     (a0)+,d1
            move.w     (a0)+,d2
            move.w     (a0)+,d3
            move.w     (a0)+,d4
            movea.l    (a0)+,a3
            lea        BitplaneBuffer(pc),a1
            move.w     d1,d5
            move.w     #40,d6              ; 320 pixel low-res row stride in bytes
            mulu.w     d6,d5
            adda.w     d5,a1
            move.w     d0,d5
            lsr.w      #3,d5
            adda.w     d5,a1
            movea.l    a1,a2
            move.w     d0,d5
            add.w      d2,d5
            subq.w     #1,d5
            lsr.w      #3,d5
            move.w     d0,d6
            lsr.w      #3,d6
            sub.w      d6,d5
            move.w     d3,d6
            subq.w     #1,d6
            bmi.s      .doneDrawControlRect
.drawControlEdges:
            move.b     #$ff,(a1)
            move.b     #$ff,0(a1,d5.w)
            adda.w     #40,a1
            dbra       d6,.drawControlEdges
            move.w     d3,d6
            subq.w     #1,d6
            move.w     #40,d7
            mulu.w     d7,d6
            movea.l    a2,a1
            adda.w     d6,a1
            move.b     #$ff,(a1)
            move.b     #$ff,0(a1,d5.w)
            movea.l    a2,a1
            adda.w     #41,a1
            bsr        DrawControlLabel
            lea        $dff000,a6
            move.w     #$0222,$180(a6)      ; COLOR00 dark background for control area
            move.w     #$0ccc,$182(a6)      ; COLOR01 bright control outline color
.doneDrawControlRect:
            movem.l    (sp)+,d0-d7/a1-a3
            rts

DrawControlLabel:
            movem.l    d0-d2/a1/a3,-(sp)
            moveq      #11,d2              ; up to 12 visible label bytes
.drawControlLabelChar:
            move.b     (a3)+,d0
            beq.s      .doneDrawControlLabel
            ori.b      #$80,d0
            move.b     d0,(a1)+
            dbra       d2,.drawControlLabelChar
.doneDrawControlLabel:
            movem.l    (sp)+,d0-d2/a1/a3
            rts
            ; @amiga:region draw_controls end

            ; @amiga:region hit_test begin
WaitVBlank:
            lea        $dff000,a6
.waitVBlank:
            cmp.b      #$ff,$06(a6)        ; VPOSR high byte reaches PAL vblank region
            bne.s      .waitVBlank
.leaveVBlank:
            cmp.b      #$ff,$06(a6)
            beq.s      .leaveVBlank
            rts

ReadMouseControls:
            lea        $dff000,a6
            move.w     $0a(a6),d0           ; JOY0DAT mouse counters
            move.w     d0,d1
            and.w      #$00ff,d1            ; raw X counter
            move.w     d1,d2
            sub.w      MouseRawX(pc),d2
            cmp.w      #127,d2
            ble.s      .mouseXNoPositiveWrap
            sub.w      #256,d2
.mouseXNoPositiveWrap:
            cmp.w      #-128,d2
            bge.s      .mouseXDeltaReady
            add.w      #256,d2
.mouseXDeltaReady:
            move.w     d1,MouseRawX
            add.w      MouseX(pc),d2
            bge.s      .mouseXNotNegative
            moveq      #0,d2
.mouseXNotNegative:
            cmp.w      #319,d2
            ble.s      .storeMouseX
            move.w     #319,d2
.storeMouseX:
            move.w     d2,MouseX
            lsr.w      #8,d0
            and.w      #$00ff,d0            ; raw Y counter
            move.w     d0,d2
            sub.w      MouseRawY(pc),d2
            cmp.w      #127,d2
            ble.s      .mouseYNoPositiveWrap
            sub.w      #256,d2
.mouseYNoPositiveWrap:
            cmp.w      #-128,d2
            bge.s      .mouseYDeltaReady
            add.w      #256,d2
.mouseYDeltaReady:
            move.w     d0,MouseRawY
            add.w      MouseY(pc),d2
            bge.s      .mouseYNotNegative
            moveq      #0,d2
.mouseYNotNegative:
            cmp.w      #255,d2
            ble.s      .storeMouseY
            move.w     #255,d2
.storeMouseY:
            move.w     d2,MouseY
            moveq      #0,d0
            btst       #6,$bfe001           ; CIAA PRA left mouse, zero when pressed
            bne.s      .storeMouseButtons
            moveq      #1,d0
.storeMouseButtons:
            move.w     d0,MouseButtons
            moveq      #0,d1
            tst.w      d0
            beq.s      .storeMouseClicked
            tst.w      MouseWasButtons
            bne.s      .storeMouseClicked
            moveq      #1,d1
.storeMouseClicked:
            move.w     d1,MouseClicked
            move.w     d0,MouseWasButtons
            rts

HitTestControls:
            move.w     MouseClicked(pc),d0
            beq        .doneHitTest
            ; @amiga:hittest play slot=1 bounds=32,40,72,20
            move.w     MouseX(pc),d0
            cmp.w      #32,d0
            blt.s      .miss_play
            cmp.w      #104,d0
            bge.s      .miss_play
            move.w     MouseY(pc),d0
            cmp.w      #40,d0
            blt.s      .miss_play
            cmp.w      #60,d0
            bge.s      .miss_play
            move.w     #1,SelectedControl
            move.w     #1,ActivatedControl
            bra        .doneHitTest
.miss_play:
            ; @amiga:hittest stop slot=2 bounds=120,40,72,20
            move.w     MouseX(pc),d0
            cmp.w      #120,d0
            blt.s      .miss_stop
            cmp.w      #192,d0
            bge.s      .miss_stop
            move.w     MouseY(pc),d0
            cmp.w      #40,d0
            blt.s      .miss_stop
            cmp.w      #60,d0
            bge.s      .miss_stop
            move.w     #2,SelectedControl
            move.w     #2,ActivatedControl
            bra        .doneHitTest
.miss_stop:
.doneHitTest:
            rts
            ; @amiga:region hit_test end

            ; @amiga:region input_dispatch begin
InputDispatch:
            move.w     ActivatedControl(pc),d0
            beq.s      .doneDispatch
            ; @amiga:dispatch play -> PlayMOD
            cmp.w      #1,d0
            bne.s      .skip_play
            bsr        PlayMOD
.skip_play:
            ; @amiga:dispatch stop -> StopMOD
            cmp.w      #2,d0
            bne.s      .skip_stop
            bsr        StopMOD
.skip_stop:
.doneDispatch:
            clr.w      ActivatedControl
            rts
            ; @amiga:region input_dispatch end

            ; @amiga:region routines begin
PlayMOD:
            lea        $dff000,a6
            lea        Sample(pc),a0
            move.l     a0,$a0(a6)           ; AUD0LC
            move.w     #8,$a4(a6)           ; AUD0LEN
            move.w     #428,$a6(a6)         ; AUD0PER
            move.w     AudioVolume(pc),$a8(a6) ; AUD0VOL
            move.w     #$8201,$96(a6)       ; DMAEN + AUD0
            move.w     #1,PlaybackState
            rts

StopMOD:
            lea        $dff000,a6
            move.w     #$0001,$96(a6)       ; clear AUD0 DMA bit
            clr.w      PlaybackState
            rts
            ; @amiga:region routines end

            ; @amiga:region state begin
SelectedControl: dc.w  1
ActivatedControl: dc.w 0
MouseX:     dc.w       40
MouseY:     dc.w       48
MouseRawX:  dc.w       40
MouseRawY:  dc.w       48
MouseButtons: dc.w     0
MouseWasButtons: dc.w 0
MouseClicked: dc.w     0
PlaybackState: dc.w    0
AudioVolume:  dc.w     48
            ; @amiga:region state end

            ; @amiga:region chip_data begin
ControlRect_play:
            dc.w       32,40,72,20,1
            dc.l       ControlLabel_play
ControlLabel_play:
            dc.b       "Play",0
            even
ControlRect_stop:
            dc.w       120,40,72,20,2
            dc.l       ControlLabel_stop
ControlLabel_stop:
            dc.b       "Stop",0
            even
BitplaneBuffer:
            ds.b       8000
Sample:     dc.b       0,64,127,64,0,-64,-127,-64
            dc.b       0,64,127,64,0,-64,-127,-64
            ; @amiga:region chip_data end
"""
    }

    static func verifiedModPlayerControlsSource() throws -> String {
        let source = try modPlayerControlsSource()
        return try verifiedModelBackedSource(source)
    }

    static func intuitionWindowToolModel() -> AmigaProgramModel {
        AmigaProgramModel(
            id: intuitionWindowToolID,
            kind: .utility,
            controls: [
                AmigaProgramModel.Control(id: "play", label: "Play", action: "PlayAction", bounds: .init(x: 14, y: 18, width: 78, height: 18)),
                AmigaProgramModel.Control(id: "stop", label: "Stop", action: "StopAction", bounds: .init(x: 104, y: 18, width: 78, height: 18))
            ],
            routines: [
                AmigaProgramModel.Routine(id: "event_loop", label: "EventLoop", purpose: "Waits for Intuition IDCMP messages and exits on close-window."),
                AmigaProgramModel.Routine(id: "dispatch", label: "InputDispatch", purpose: "Dispatches IDCMP_GADGETUP messages to modeled gadget action routines.", calls: ["PlayAction", "StopAction"]),
                AmigaProgramModel.Routine(id: "cleanup", label: "CleanupAndExit", purpose: "Closes the window before closing intuition.library."),
                AmigaProgramModel.Routine(id: "play", label: "PlayAction", purpose: "Records that the Play gadget was activated."),
                AmigaProgramModel.Routine(id: "stop", label: "StopAction", purpose: "Records that the Stop gadget was activated.")
            ],
            stateVariables: [
                AmigaProgramModel.StateVariable(id: "intuition_base", symbol: "IntuitionBase", purpose: "Opened intuition.library base pointer.", initialValue: "0"),
                AmigaProgramModel.StateVariable(id: "window_ptr", symbol: "WindowPtr", purpose: "OpenWindow result pointer that must be closed before library shutdown.", initialValue: "0"),
                AmigaProgramModel.StateVariable(id: "status_state", symbol: "StatusState", purpose: "Small state word changed by gadget actions.", initialValue: "0")
            ],
            hardware: [.exec, .intuition],
            verificationExpectations: [
                "OpenLibrary and CloseLibrary for intuition.library are balanced.",
                "OpenWindow and CloseWindow are balanced.",
                "IDCMP_CLOSEWINDOW exits through cleanup.",
                "Every modeled gadget has an Intuition Gadget record and dispatch branch."
            ]
        )
    }

    static func intuitionWindowToolSource(model: AmigaProgramModel? = nil) throws -> String {
        let model = model ?? intuitionWindowToolModel()
        let controls = model.controls
        let gadgetData = intuitionGadgetDataLines(for: controls)
        let textData = intuitionTextDataLines(for: controls, includeStatusText: model.stateVariables.contains { $0.id == "status_text" })
        let dispatchLines = intuitionDispatchLines(for: controls)
        let actionLines = intuitionActionRoutineLines(for: controls)
        let controlMarkers = controls.map { control in
            let markerLabel = amigaMarkerAttributeText(for: control.label)
            if let bounds = control.bounds {
                return #"            ; @amiga:model control id=\#(control.id) label="\#(markerLabel)" action=\#(control.action) bounds=\#(bounds.x),\#(bounds.y),\#(bounds.width),\#(bounds.height)"#
            }
            return #"            ; @amiga:model control id=\#(control.id) label="\#(markerLabel)" action=\#(control.action)"#
        }.joined(separator: "\n")

        return """
\(try AmigaSourceIndexer.modelRegion(for: model))
; Intuition windowed tool template.
; Opens intuition.library, creates modeled gadgets, waits for IDCMP close-window
; or gadget-up messages, then closes the window before the library.
IDCMP_GADGETUP      equ        $00000040
IDCMP_CLOSEWINDOW   equ        $00000200
WFLG_DRAGBAR        equ        $00000002
WFLG_DEPTHGADGET    equ        $00000004
WFLG_CLOSEGADGET    equ        $00000008
WFLG_ACTIVATE       equ        $00001000
WFLG_GIMMEZEROZERO  equ        $00000400
GFLG_GADGHCOMP      equ        $0000
GACT_RELVERIFY      equ        $0001
GTYP_BOOLGADGET     equ        $0001
JAM1                equ        $0001
WBENCHSCREEN        equ        $0001

            SECTION    Code,CODE
            XDEF       _Start
_Start:
            movem.l    d2-d7/a2-a6,-(sp)
            move.l     $4.w,a6
            lea        IntuitionName(pc),a1
            moveq      #0,d0
            jsr        -552(a6)             ; OpenLibrary("intuition.library")
            move.l     d0,IntuitionBase
            beq        ProgramExit

            move.l     d0,a6
            lea        NewWindow(pc),a0
            jsr        -204(a6)             ; OpenWindow(&NewWindow)
            move.l     d0,WindowPtr
            beq        CloseLibraryOnly
            bra        EventLoop

            ; @amiga:region controls begin
\(controlMarkers)
            ; @amiga:region controls end

            ; @amiga:region draw_controls begin
            ; Intuition renders the modeled Gadget and IntuiText records.
            ; @amiga:region draw_controls end

            ; @amiga:region hit_test begin
EventLoop:
            move.l     WindowPtr(pc),a0
            move.l     86(a0),a0            ; Window.UserPort
            move.l     $4.w,a6
            jsr        -384(a6)             ; WaitPort(UserPort)

.nextMessage:
            move.l     WindowPtr(pc),a0
            move.l     86(a0),a0            ; Window.UserPort
            move.l     $4.w,a6
            jsr        -372(a6)             ; GetMsg(UserPort)
            move.l     d0,d1
            beq.s      EventLoop
            move.l     d0,a1
            move.l     20(a1),d2            ; IntuiMessage.Class
            move.l     28(a1),a2            ; IntuiMessage.IAddress, used for gadget dispatch
            move.l     d0,a1
            move.l     $4.w,a6
            jsr        -378(a6)             ; ReplyMsg(message)
            cmp.l      #IDCMP_CLOSEWINDOW,d2
            beq        CleanupAndExit
            cmp.l      #IDCMP_GADGETUP,d2
            beq        InputDispatch
            bra.s      .nextMessage
            ; @amiga:region hit_test end

            ; @amiga:region input_dispatch begin
InputDispatch:
\(dispatchLines)
            bra        EventLoop
            ; @amiga:region input_dispatch end

            ; @amiga:region routines begin
\(actionLines)

CleanupAndExit:
            move.l     WindowPtr(pc),d0
            beq.s      CloseLibraryOnly
            move.l     d0,a0
            move.l     IntuitionBase(pc),a6
            jsr        -72(a6)              ; CloseWindow(WindowPtr)
            clr.l      WindowPtr

CloseLibraryOnly:
            move.l     IntuitionBase(pc),d0
            beq.s      ProgramExit
            move.l     d0,a1
            move.l     $4.w,a6
            jsr        -414(a6)             ; CloseLibrary(IntuitionBase)
            clr.l      IntuitionBase

ProgramExit:
            movem.l    (sp)+,d2-d7/a2-a6
            moveq      #0,d0
            rts
            ; @amiga:region routines end

            ; @amiga:region state begin
IntuitionBase: dc.l    0
WindowPtr:     dc.l    0
StatusState:   dc.w    0
\(model.stateVariables.contains { $0.id == "status_text" } ? "StatusTextEnabled: dc.w 1" : "")
            ; @amiga:region state end

            ; @amiga:region chip_data begin
            ALIGN      2
IntuitionName:
            dc.b       "intuition.library",0
WindowTitle:
            dc.b       "Amiga Tool",0
            EVEN

NewWindow:
            dc.w       20,20,320,112
            dc.b       0,1
            dc.l       IDCMP_CLOSEWINDOW+IDCMP_GADGETUP
            dc.l       WFLG_CLOSEGADGET+WFLG_DEPTHGADGET+WFLG_DRAGBAR+WFLG_ACTIVATE+WFLG_GIMMEZEROZERO
            dc.l       \(controls.first.map { "Gadget_\($0.id)" } ?? "0")
            dc.l       0
            dc.l       WindowTitle
            dc.l       0
            dc.l       0
            dc.w       120,50,340,170
            dc.w       WBENCHSCREEN

\(gadgetData)
\(textData)
            ; @amiga:region chip_data end
"""
    }

    static func verifiedIntuitionWindowToolSource(model: AmigaProgramModel? = nil) throws -> String {
        let source = try intuitionWindowToolSource(model: model)
        return try verifiedModelBackedSource(source)
    }

    private static func intuitionGadgetDataLines(for controls: [AmigaProgramModel.Control]) -> String {
        controls.enumerated().map { offset, control in
            let next = offset + 1 < controls.count ? "Gadget_\(controls[offset + 1].id)" : "0"
            let bounds = control.bounds ?? .init(x: 14 + offset * 90, y: 18, width: 78, height: 18)
            return """
Gadget_\(control.id):
            dc.l       \(next)
            dc.w       \(bounds.x),\(bounds.y),\(bounds.width),\(bounds.height)
            dc.w       GFLG_GADGHCOMP
            dc.w       GACT_RELVERIFY
            dc.w       GTYP_BOOLGADGET
            dc.l       0
            dc.l       0
            dc.l       Text_\(control.id)
            dc.l       0
            dc.l       0
            dc.w       \(offset + 1)
            dc.l       0
"""
        }.joined(separator: "\n")
    }

    private static func intuitionTextDataLines(for controls: [AmigaProgramModel.Control], includeStatusText: Bool) -> String {
        var lines = controls.map { control in
            """
Text_\(control.id):
            dc.b       1,0,JAM1,0
            dc.w       12,5
            dc.l       0
            dc.l       Label_\(control.id)
            dc.l       0
Label_\(control.id):
            dc.b       "\(control.label)",0
            EVEN
"""
        }
        if includeStatusText {
            lines.append("""
StatusText:
            dc.b       1,0,JAM1,0
            dc.w       14,82
            dc.l       0
            dc.l       StatusLabel
            dc.l       0
StatusLabel:
            dc.b       "Ready",0
            EVEN
""")
        }
        return lines.joined(separator: "\n")
    }

    private static func intuitionDispatchLines(for controls: [AmigaProgramModel.Control]) -> String {
        controls.map { control in
            """
            ; @amiga:dispatch \(control.id) -> \(control.action)
            cmp.l      #Gadget_\(control.id),a2
            bne.s      .skip_\(control.id)
            bsr        \(control.action)
            bra        EventLoop
.skip_\(control.id):
"""
        }.joined(separator: "\n")
    }

    private static func intuitionActionRoutineLines(for controls: [AmigaProgramModel.Control]) -> String {
        controls.enumerated().map { offset, control in
            """
\(control.action):
            move.w     #\(offset + 1),StatusState
            rts
"""
        }.joined(separator: "\n")
    }

    private static func cleanTakeoverStateValue(_ id: String, in model: AmigaProgramModel, fallback: String) -> String {
        model.stateVariables.first(where: { $0.id == id })?.initialValue ?? fallback
    }

    static func verifiedModelBackedSource(_ source: String) throws -> String {
        let failures = AmigaProgramSourceVerifier.failures(in: source)
        guard failures.isEmpty else {
            throw AmigaProgramPatchError.verificationFailed(failures)
        }
        return source
    }

    static func normalizedColorName(_ color: String, fallback: String) -> String {
        let normalized = color.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return colorValue(named: normalized) == nil ? fallback : normalized
    }

    static func colorValue(named color: String?) -> String? {
        switch color?.lowercased() {
        case "white":
            return "$0fff"
        case "yellow":
            return "$0ff0"
        case "green":
            return "$00f0"
        case "cyan":
            return "$00ff"
        case "blue":
            return "$000f"
        case "purple", "magenta":
            return "$0f0f"
        case "red":
            return "$0f00"
        case "orange":
            return "$0f80"
        default:
            return nil
        }
    }
}

enum AmigaProgramSourceVerifier {
    private static let failuresCacheLimit = 128
    private static let failuresCacheLock = NSLock()
    private static var failuresCache: [String: [String]] = [:]
    private static var failuresCacheOrder: [String] = []

    static func failures(in source: String) -> [String] {
        failuresCacheLock.lock()
        if let cached = failuresCache[source] {
            failuresCacheLock.unlock()
            return cached
        }
        failuresCacheLock.unlock()

        let failures = uncachedFailures(in: source)

        failuresCacheLock.lock()
        if failuresCache[source] == nil {
            failuresCache[source] = failures
            failuresCacheOrder.append(source)
            if failuresCacheOrder.count > failuresCacheLimit {
                let evicted = failuresCacheOrder.removeFirst()
                failuresCache.removeValue(forKey: evicted)
            }
        }
        failuresCacheLock.unlock()
        return failures
    }

    private static func uncachedFailures(in source: String) -> [String] {
        let index = AmigaSourceIndexer.index(source)
        let sourceLines = source.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        let modelRegionFailures = modelRegionEncodingFailures(index: index, sourceLines: sourceLines)
        var failures: [String] = []

        guard let model = index.model else {
            return ["Missing embedded Amiga program model."] + modelRegionFailures
        }
        let isIntuitionWindowTool = model.id == AmigaProgramTemplate.intuitionWindowToolID

        failures.append(contentsOf: modelRegionCanonicalFailures(index: index, model: model, sourceLines: sourceLines))

        if !index.duplicateLabels.isEmpty {
            failures.append("Duplicate labels: \(index.duplicateLabels.joined(separator: ", ")).")
        }
        if model.id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            failures.append("Blank model id.")
        } else if model.id != model.id.trimmingCharacters(in: .whitespacesAndNewlines) {
            failures.append("Model id has leading or trailing whitespace.")
        } else if !isKebabIdentifier(model.id) {
            failures.append("Model id is not a canonical kebab-case identifier.")
        }
        failures.append(contentsOf: registeredFamilyKindFailures(model))
        failures.append(contentsOf: blankFieldFailures(
            values: model.controls.map(\.id),
            fieldName: "model control ids"
        ))
        failures.append(contentsOf: untrimmedFieldFailures(
            values: model.controls.map(\.id),
            fieldName: "model control ids"
        ))
        failures.append(contentsOf: identifierFormatFailures(
            values: model.controls.map(\.id),
            fieldName: "model control ids",
            styleName: "snake-case",
            isValid: isSnakeIdentifier
        ))
        failures.append(contentsOf: blankFieldFailures(
            values: model.controls.map(\.label),
            fieldName: "model control labels"
        ))
        failures.append(contentsOf: untrimmedFieldFailures(
            values: model.controls.map(\.label),
            fieldName: "model control labels"
        ))
        failures.append(contentsOf: controlCharacterFieldFailures(
            values: model.controls.map(\.label),
            fieldName: "model control labels"
        ))
        failures.append(contentsOf: blankFieldFailures(
            values: model.controls.map(\.action),
            fieldName: "model control actions"
        ))
        failures.append(contentsOf: untrimmedFieldFailures(
            values: model.controls.map(\.action),
            fieldName: "model control actions"
        ))
        failures.append(contentsOf: identifierFormatFailures(
            values: model.controls.map(\.action),
            fieldName: "model control actions",
            styleName: "assembly-label",
            isValid: isAssemblyLabelIdentifier
        ))
        failures.append(contentsOf: blankFieldFailures(
            values: model.routines.map(\.id),
            fieldName: "model routine ids"
        ))
        failures.append(contentsOf: untrimmedFieldFailures(
            values: model.routines.map(\.id),
            fieldName: "model routine ids"
        ))
        failures.append(contentsOf: identifierFormatFailures(
            values: model.routines.map(\.id),
            fieldName: "model routine ids",
            styleName: "snake-case",
            isValid: isSnakeIdentifier
        ))
        failures.append(contentsOf: blankFieldFailures(
            values: model.routines.map(\.label),
            fieldName: "model routine labels"
        ))
        failures.append(contentsOf: untrimmedFieldFailures(
            values: model.routines.map(\.label),
            fieldName: "model routine labels"
        ))
        failures.append(contentsOf: identifierFormatFailures(
            values: model.routines.map(\.label),
            fieldName: "model routine labels",
            styleName: "assembly-label",
            isValid: isAssemblyLabelIdentifier
        ))
        failures.append(contentsOf: blankFieldFailures(
            values: model.routines.map(\.purpose),
            fieldName: "model routine purposes"
        ))
        failures.append(contentsOf: untrimmedFieldFailures(
            values: model.routines.map(\.purpose),
            fieldName: "model routine purposes"
        ))
        failures.append(contentsOf: controlCharacterFieldFailures(
            values: model.routines.map(\.purpose),
            fieldName: "model routine purposes"
        ))
        failures.append(contentsOf: routineListFieldFailures(
            routines: model.routines,
            values: { $0.clobbers },
            fieldName: "model routine clobbers"
        ))
        failures.append(contentsOf: routineListFieldFailures(
            routines: model.routines,
            values: { $0.calls },
            fieldName: "model routine calls"
        ))
        failures.append(contentsOf: blankFieldFailures(
            values: model.stateVariables.map(\.id),
            fieldName: "model state ids"
        ))
        failures.append(contentsOf: untrimmedFieldFailures(
            values: model.stateVariables.map(\.id),
            fieldName: "model state ids"
        ))
        failures.append(contentsOf: identifierFormatFailures(
            values: model.stateVariables.map(\.id),
            fieldName: "model state ids",
            styleName: "snake-case",
            isValid: isSnakeIdentifier
        ))
        failures.append(contentsOf: blankFieldFailures(
            values: model.stateVariables.map(\.symbol),
            fieldName: "model state symbols"
        ))
        failures.append(contentsOf: untrimmedFieldFailures(
            values: model.stateVariables.map(\.symbol),
            fieldName: "model state symbols"
        ))
        failures.append(contentsOf: identifierFormatFailures(
            values: model.stateVariables.map(\.symbol),
            fieldName: "model state symbols",
            styleName: "assembly-label",
            isValid: isAssemblyLabelIdentifier
        ))
        failures.append(contentsOf: blankFieldFailures(
            values: model.stateVariables.map(\.purpose),
            fieldName: "model state purposes"
        ))
        failures.append(contentsOf: untrimmedFieldFailures(
            values: model.stateVariables.map(\.purpose),
            fieldName: "model state purposes"
        ))
        failures.append(contentsOf: controlCharacterFieldFailures(
            values: model.stateVariables.map(\.purpose),
            fieldName: "model state purposes"
        ))
        failures.append(contentsOf: blankOptionalFieldFailures(
            values: model.stateVariables.map(\.initialValue),
            fieldName: "model state initial values"
        ))
        failures.append(contentsOf: untrimmedOptionalFieldFailures(
            values: model.stateVariables.map(\.initialValue),
            fieldName: "model state initial values"
        ))
        failures.append(contentsOf: controlCharacterOptionalFieldFailures(
            values: model.stateVariables.map(\.initialValue),
            fieldName: "model state initial values"
        ))
        let duplicateControlIDs = duplicateValues(model.controls.map(\.id))
        if !duplicateControlIDs.isEmpty {
            failures.append("Duplicate model control ids: \(duplicateControlIDs.joined(separator: ", ")).")
        }
        let duplicateControlLabels = duplicateValues(model.controls.map(\.label), normalizedBy: { $0.lowercased() })
        if !duplicateControlLabels.isEmpty {
            failures.append("Duplicate model control labels: \(duplicateControlLabels.joined(separator: ", ")).")
        }
        let duplicateControlActions = duplicateValues(model.controls.map(\.action))
        if !duplicateControlActions.isEmpty {
            failures.append("Duplicate model control actions: \(duplicateControlActions.joined(separator: ", ")).")
        }
        failures.append(contentsOf: controlActionRoutineFailures(model: model))
        if !isIntuitionWindowTool {
            failures.append(contentsOf: boundedControlSupportRoutineFailures(model: model))
            failures.append(contentsOf: boundedControlSupportRoutineCallFailures(model: model))
            failures.append(contentsOf: boundedControlStateVariableFailures(model: model))
        }
        failures.append(contentsOf: controlBoundsFailures(model.controls))
        let duplicateRoutineIDs = duplicateValues(model.routines.map(\.id))
        if !duplicateRoutineIDs.isEmpty {
            failures.append("Duplicate model routine ids: \(duplicateRoutineIDs.joined(separator: ", ")).")
        }
        let duplicateRoutineLabels = duplicateValues(model.routines.map(\.label))
        if !duplicateRoutineLabels.isEmpty {
            failures.append("Duplicate model routine labels: \(duplicateRoutineLabels.joined(separator: ", ")).")
        }
        let duplicateStateIDs = duplicateValues(model.stateVariables.map(\.id))
        if !duplicateStateIDs.isEmpty {
            failures.append("Duplicate model state ids: \(duplicateStateIDs.joined(separator: ", ")).")
        }
        let duplicateStateSymbols = duplicateValues(model.stateVariables.map(\.symbol))
        if !duplicateStateSymbols.isEmpty {
            failures.append("Duplicate model state symbols: \(duplicateStateSymbols.joined(separator: ", ")).")
        }
        let duplicateHardware = duplicateValues(model.hardware.map(\.rawValue))
        if !duplicateHardware.isEmpty {
            failures.append("Duplicate model hardware dependencies: \(duplicateHardware.joined(separator: ", ")).")
        }
        let blankVerificationExpectationIndexes = model.verificationExpectations.enumerated().compactMap { offset, expectation in
            expectation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "\(offset)" : nil
        }
        if !blankVerificationExpectationIndexes.isEmpty {
            failures.append("Blank model verification expectations at index: \(blankVerificationExpectationIndexes.joined(separator: ", ")).")
        }
        failures.append(contentsOf: untrimmedFieldFailures(
            values: model.verificationExpectations,
            fieldName: "model verification expectations"
        ))
        failures.append(contentsOf: controlCharacterFieldFailures(
            values: model.verificationExpectations,
            fieldName: "model verification expectations"
        ))
        let duplicateVerificationExpectations = duplicateValues(
            model.verificationExpectations
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty },
            normalizedBy: { $0.lowercased() }
        )
        if !duplicateVerificationExpectations.isEmpty {
            failures.append("Duplicate model verification expectations: \(duplicateVerificationExpectations.joined(separator: ", "))")
        }

        failures.append(contentsOf: modelRegionFailures)
        failures.append(contentsOf: regionBoundaryFailures(sourceLines: sourceLines))
        failures.append(contentsOf: hardwareDependencyFactFailures(model: model, index: index, sourceLines: sourceLines))
        for region in [AmigaSourceRegionName.controls, .drawControls, .hitTest, .inputDispatch, .routines, .state, .chipData] {
            guard index.regions[region.rawValue]?.endLine != nil else {
                failures.append("Missing closed region: \(region.rawValue).")
                continue
            }
        }
        let drawControlsReturnLine = firstReturnLine(afterLabel: "DrawControls", inRegion: AmigaSourceRegionName.drawControls.rawValue, index: index, sourceLines: sourceLines)
        let hitTestReturnLine = firstReturnLine(afterLabel: "HitTestControls", inRegion: AmigaSourceRegionName.hitTest.rawValue, index: index, sourceLines: sourceLines)
        let dispatchReturnLine = firstReturnLine(inRegion: AmigaSourceRegionName.inputDispatch.rawValue, index: index, sourceLines: sourceLines)
        let inputDispatchLines = linesBeforeReturn(inRegion: AmigaSourceRegionName.inputDispatch.rawValue, index: index, sourceLines: sourceLines)
        if isIntuitionWindowTool {
            failures.append(contentsOf: intuitionWindowToolSourceFailures(model: model, index: index, sourceLines: sourceLines))
            return failures
        }
        let startupLines = entryStartupLines(sourceLines: sourceLines)
        let mainLoopLines = entryLoopLines(index: index, sourceLines: sourceLines)
        let waitVBlankLines = linesInRoutine("WaitVBlank", inRegion: AmigaSourceRegionName.hitTest.rawValue, index: index, sourceLines: sourceLines)
        let stateLines = lines(inRegion: AmigaSourceRegionName.state.rawValue, index: index, sourceLines: sourceLines)
        let drawControlRectLines = linesInRoutine("DrawControlRect", inRegion: AmigaSourceRegionName.drawControls.rawValue, index: index, sourceLines: sourceLines)
        let readMouseLines = linesInRoutine("ReadMouseControls", inRegion: AmigaSourceRegionName.hitTest.rawValue, index: index, sourceLines: sourceLines)
        let hitTestLines = linesInRoutine("HitTestControls", inRegion: AmigaSourceRegionName.hitTest.rawValue, index: index, sourceLines: sourceLines)
        failures.append(contentsOf: verificationExpectationFactFailures(model: model, index: index, sourceLines: sourceLines))
        let hasBoundedControls = model.controls.contains { $0.bounds != nil }
        if hasBoundedControls {
            if !index.labels.contains("DrawControls") {
                failures.append("Missing routine label DrawControls.")
            }
            if !index.labels.contains("DrawControlRect") {
                failures.append("Missing routine label DrawControlRect.")
            }
            if !index.labels.contains("DrawControlLabel") {
                failures.append("Missing routine label DrawControlLabel.")
            }
            if !index.labels.contains("WaitVBlank") {
                failures.append("Missing routine label WaitVBlank.")
            }
            if !index.labels.contains(".mainLoop") {
                failures.append("Missing persistent UI main loop.")
            }
            if !startupLines.contains(where: { isDirectSubroutineCallLine($0, target: "DrawControls") }) {
                failures.append("UI entry does not draw controls before polling.")
            }
            if !mainLoopLines.contains(where: { isDirectSubroutineCallLine($0, target: "WaitVBlank") }) ||
                !waitVBlankLines.contains(where: { containsExecutableAddressOperand($0, displacement: 0x06, register: "a6") }) {
                failures.append("UI main loop is not paced by vertical blank.")
            }
            if !containsOrderedDirectSubroutineCalls(["ReadMouseControls", "HitTestControls", "InputDispatch"], in: mainLoopLines) {
                failures.append("UI main loop does not poll and dispatch controls.")
            }
            if !mainLoopLines.contains(where: { isDirectBranchLine($0, mnemonic: "bra", target: ".mainLoop") }) {
                failures.append("UI main loop does not continue polling controls.")
            }
            if !index.labels.contains("BitplaneBuffer") {
                failures.append("Missing UI bitplane buffer.")
            }
            if !drawControlRectLines.contains(where: { isPCRelativeLEALine($0, symbol: "BitplaneBuffer", register: "a1") }) {
                failures.append("Control drawing does not target the UI bitplane buffer.")
            }
            if !drawControlRectLines.contains(where: { moveWordImmediateLine($0, value: 40, destination: "d6") }) &&
                !drawControlRectLines.contains(where: { moveWordImmediateLine($0, value: 40, destination: "d7") }) {
                failures.append("Control drawing does not use the 320px bitplane row stride.")
            }
            if !drawControlRectLines.contains(where: { moveByteImmediateLine($0, value: 0xff, destination: "(a1)") }) {
                failures.append("Control drawing does not write visible edge pixels.")
            }
            if !drawControlRectLines.contains(where: { isDirectSubroutineCallLine($0, target: "DrawControlLabel") }) {
                failures.append("Control drawing does not render control labels.")
            }
            if !index.labels.contains("ReadMouseControls") {
                failures.append("Missing routine label ReadMouseControls.")
            }
            if !readMouseLines.contains(where: { containsExecutableAddressOperand($0, displacement: 0x0a, register: "a6") }) {
                failures.append("Missing JOY0DAT mouse coordinate read.")
            }
            if !readMouseLines.contains(where: { btstImmediateLine($0, bit: 6, destinationValue: 0xbfe001) }) {
                failures.append("Missing CIAA left mouse button read.")
            }
            if !containsLabel("MouseButtons", in: stateLines) {
                failures.append("Missing state symbol MouseButtons.")
            }
            if !containsLabel("ActivatedControl", in: stateLines) {
                failures.append("Missing one-frame activated control state.")
            }
            if !containsLabel("MouseWasButtons", in: stateLines) || !containsLabel("MouseClicked", in: stateLines) {
                failures.append("Missing mouse click-edge state.")
            }
            if !readMouseLines.contains(where: { moveWordRegisterLine($0, source: "d1", destination: "MouseClicked") }) ||
                !readMouseLines.contains(where: { moveWordRegisterLine($0, source: "d0", destination: "MouseWasButtons") }) {
                failures.append("Mouse input does not update click-edge state.")
            }
            if !containsLabel("MouseRawX", in: stateLines) || !containsLabel("MouseRawY", in: stateLines) {
                failures.append("Missing raw mouse counter state.")
            }
            if !readMouseLines.contains(where: { subWordSymbolLine($0, source: "MouseRawX(pc)", destination: "d2") }) ||
                !readMouseLines.contains(where: { subWordSymbolLine($0, source: "MouseRawY(pc)", destination: "d2") }) {
                failures.append("Mouse input does not derive signed deltas from previous JOY0DAT counters.")
            }
            if !readMouseLines.contains(where: { moveWordRegisterLine($0, source: "d1", destination: "MouseRawX") }) ||
                !readMouseLines.contains(where: { moveWordRegisterLine($0, source: "d0", destination: "MouseRawY") }) {
                failures.append("Mouse input does not update previous raw JOY0DAT counters.")
            }
            if !readMouseLines.contains(where: { cmpWordRegisterLine($0, value: 319, register: "d2") }) ||
                !readMouseLines.contains(where: { cmpWordRegisterLine($0, value: 255, register: "d2") }) {
                failures.append("Mouse input does not clamp pointer coordinates to screen bounds.")
            }
            if !hitTestLines.contains(where: { moveWordSymbolLine($0, source: "MouseClicked(pc)", destination: "d0") }) {
                failures.append("Hit testing does not use click-edge activation.")
            }
            if !inputDispatchLines.contains(where: { moveWordSymbolLine($0, source: "ActivatedControl(pc)", destination: "d0") }) {
                failures.append("Input dispatch does not consume activated control state.")
            }
            if inputDispatchLines.contains(where: { moveWordSymbolLine($0, source: "SelectedControl(pc)", destination: "d0") }) {
                failures.append("Input dispatch uses persistent selection instead of one-frame activation.")
            }
            if !inputDispatchLines.contains(where: { clearWordLine($0, destination: "ActivatedControl") }) {
                failures.append("Input dispatch does not clear activated control state.")
            }
        }
        failures.append(contentsOf: unmodeledControlMarkerFailures(
            model: model,
            index: index,
            sourceLines: sourceLines
        ))

        for (offset, control) in model.controls.enumerated() {
            let modelMarker = controlMarkerText(for: control)
            if firstLineIndex(containing: modelMarker, inRegion: AmigaSourceRegionName.controls.rawValue, index: index, sourceLines: sourceLines) == nil {
                let looseControlMarker = "@amiga:model control id=\(control.id) "
                if firstLineIndex(containing: looseControlMarker, inRegion: AmigaSourceRegionName.controls.rawValue, index: index, sourceLines: sourceLines) != nil {
                    failures.append("Control marker for \(control.label) does not match the embedded model.")
                } else {
                    failures.append("Missing control marker for \(control.label).")
                }
            }
            if control.bounds == nil {
                failures.append("Missing bounds for \(control.label).")
            }

            let slot = offset + 1
            let drawMarker = drawMarkerText(for: control, slot: slot)
            if let drawMarkerIndex = firstLineIndex(containing: drawMarker, inRegion: AmigaSourceRegionName.drawControls.rawValue, index: index, sourceLines: sourceLines) {
                if let drawControlsReturnLine, drawMarkerIndex + 1 > drawControlsReturnLine {
                    failures.append("Draw marker for \(control.label) is after the DrawControls return.")
                }
                let drawsControl = sourceLines[(drawMarkerIndex + 1)...]
                    .prefix(3)
                    .contains { line in
                        isPCRelativeLEALine(line, symbol: "ControlRect_\(control.id)", register: "a0")
                    }
                if !drawsControl {
                    failures.append("Draw path for \(control.label) does not reference its rectangle data.")
                }
            } else {
                let looseDrawMarker = "@amiga:draw_control \(control.id) "
                if firstLineIndex(containing: looseDrawMarker, inRegion: AmigaSourceRegionName.drawControls.rawValue, index: index, sourceLines: sourceLines) != nil {
                    failures.append("Draw marker for \(control.label) does not match the model bounds and slot.")
                } else {
                    failures.append("Missing draw marker for \(control.label).")
                }
            }
            if let rectDataIndex = labelLineIndex("ControlRect_\(control.id)", inRegion: AmigaSourceRegionName.chipData.rawValue, index: index, sourceLines: sourceLines) {
                if let bounds = control.bounds,
                   !controlRectDataMatches(bounds: bounds, slot: slot, after: rectDataIndex, sourceLines: sourceLines) {
                    failures.append("Control rectangle data for \(control.label) does not match the model bounds and slot.")
                }
            } else {
                failures.append("Missing control rectangle data for \(control.label).")
            }
            if let labelDataIndex = labelLineIndex("ControlLabel_\(control.id)", inRegion: AmigaSourceRegionName.chipData.rawValue, index: index, sourceLines: sourceLines) {
                if !labelDataMatches(control.label, after: labelDataIndex, sourceLines: sourceLines) {
                    failures.append("Control label data for \(control.label) does not match the model label.")
                }
            } else {
                failures.append("Missing control label data for \(control.label).")
            }

            let hitTestMarker = hitTestMarkerText(for: control, slot: slot)
            guard let hitTestMarkerIndex = firstLineIndex(containing: hitTestMarker, inRegion: AmigaSourceRegionName.hitTest.rawValue, index: index, sourceLines: sourceLines) else {
                let looseHitTestMarker = "@amiga:hittest \(control.id) "
                if firstLineIndex(containing: looseHitTestMarker, inRegion: AmigaSourceRegionName.hitTest.rawValue, index: index, sourceLines: sourceLines) != nil {
                    failures.append("Hit-test marker for \(control.label) does not match the model bounds and slot.")
                } else {
                    failures.append("Missing hit-test marker for \(control.label).")
                }
                continue
            }
            if let hitTestReturnLine, hitTestMarkerIndex + 1 > hitTestReturnLine {
                failures.append("Hit-test marker for \(control.label) is after the HitTestControls return.")
            }
            if let bounds = control.bounds,
               !hitTestBoundsMatch(bounds: bounds, after: hitTestMarkerIndex, sourceLines: sourceLines) {
                failures.append("Hit-test for \(control.label) does not match the model bounds.")
            }
            let selectsControl = sourceLines[(hitTestMarkerIndex + 1)...]
                .prefix(12)
                .contains { moveWordImmediateLine($0, value: slot, destination: "SelectedControl") }
            if !selectsControl {
                failures.append("Hit-test for \(control.label) does not select slot \(slot).")
            }
            let activatesControl = sourceLines[(hitTestMarkerIndex + 1)...]
                .prefix(13)
                .contains { moveWordImmediateLine($0, value: slot, destination: "ActivatedControl") }
            if !activatesControl {
                failures.append("Hit-test for \(control.label) does not activate slot \(slot).")
            }
            if let bounds = control.bounds,
               selectsControl,
               activatesControl,
               !hitTestBlockHasGuardedActivation(control: control, slot: slot, bounds: bounds, after: hitTestMarkerIndex, sourceLines: sourceLines) {
                failures.append("Hit-test for \(control.label) is not guarded by its bounds.")
            }

            let dispatchMarker = "@amiga:dispatch \(control.id) -> \(control.action)"
            guard let markerIndex = firstLineIndex(containing: dispatchMarker, inRegion: AmigaSourceRegionName.inputDispatch.rawValue, index: index, sourceLines: sourceLines) else {
                failures.append("Missing dispatch marker for \(control.label).")
                continue
            }
            if let dispatchReturnLine, markerIndex + 1 > dispatchReturnLine {
                failures.append("Dispatch marker for \(control.label) is after the InputDispatch return.")
            }

            let dispatchWindow = sourceLines[(markerIndex + 1)...].prefix(5)
            let comparesSlot = dispatchWindow.contains { line in
                cmpWordD0Line(line, value: slot)
            }
            if !comparesSlot {
                failures.append("Dispatch for \(control.label) does not compare activated slot \(slot).")
            }

            let executableDispatch = sourceLines[(markerIndex + 1)...]
                .prefix(5)
                .contains { isDirectRoutineCallLine($0, target: control.action) }
            if !executableDispatch {
                failures.append("Control \(control.label) does not execute \(control.action) after its dispatch marker.")
            }
            if comparesSlot && executableDispatch &&
                !dispatchBlockHasGuardedAction(control: control, slot: slot, after: markerIndex, sourceLines: sourceLines) {
                failures.append("Dispatch for \(control.label) is not guarded by its activated slot.")
            }

            if labelLineIndex(control.action, inRegion: AmigaSourceRegionName.routines.rawValue, index: index, sourceLines: sourceLines) == nil {
                failures.append("Action routine \(control.action) for \(control.label) is not inside the routines region.")
            } else if !routineHasExecutableBody(control.action, inRegion: AmigaSourceRegionName.routines.rawValue, index: index, sourceLines: sourceLines) {
                failures.append("Action routine \(control.action) for \(control.label) has no executable body.")
            }
        }
        failures.append(contentsOf: unmodeledRoutineLabelFailures(
            model: model,
            index: index,
            sourceLines: sourceLines
        ))

        for routine in model.routines {
            if !index.labels.contains(routine.label) {
                failures.append("Missing routine label \(routine.label).")
            } else if let expectedRegion = expectedRegionName(for: routine, model: model),
                      labelLineIndex(routine.label, inRegion: expectedRegion.rawValue, index: index, sourceLines: sourceLines) == nil {
                failures.append("Routine \(routine.label) is not inside the expected \(expectedRegion.rawValue) region.")
            }
            if let routineRegion = regionName(containingLabel: routine.label, index: index, sourceLines: sourceLines) {
                failures.append(contentsOf: routineCallMetadataFailures(
                    routine: routine,
                    model: model,
                    inRegion: routineRegion,
                    index: index,
                    sourceLines: sourceLines
                ))
                failures.append(contentsOf: routineClobberMetadataFailures(
                    routine: routine,
                    inRegion: routineRegion,
                    index: index,
                    sourceLines: sourceLines
                ))
            }
        }

        for stateVariable in model.stateVariables {
            guard containsLabel(stateVariable.symbol, in: stateLines) else {
                failures.append("Missing state symbol \(stateVariable.symbol).")
                continue
            }
            if let initialValue = stateVariable.initialValue {
                guard let sourceValue = stateWordValue(for: stateVariable.symbol, in: stateLines) else {
                    failures.append("State symbol \(stateVariable.symbol) does not declare a dc.w initial value.")
                    continue
                }
                if !stateWordValuesMatch(sourceValue, initialValue) {
                    failures.append("State symbol \(stateVariable.symbol) initial value \(sourceValue) does not match model value \(initialValue).")
                }
            }
        }
        failures.append(contentsOf: unmodeledStateSymbolFailures(
            model: model,
            index: index,
            sourceLines: sourceLines
        ))
        failures.append(contentsOf: unmodeledKnownFamilyChipDataFailures(
            model: model,
            index: index,
            sourceLines: sourceLines
        ))

        if model.id == AmigaProgramFamilyRegistry.doubleBufferedBitplane.id {
            failures.append(contentsOf: doubleBufferedBitplaneFailures(
                model: model,
                index: index,
                sourceLines: sourceLines,
                stateLines: stateLines
            ))
        }

        return failures
    }

    private static func modelRegionEncodingFailures(index: AmigaSourceIndex, sourceLines: [String]) -> [String] {
        guard let region = index.regions[AmigaSourceRegionName.model.rawValue],
              let endLine = region.endLine else {
            return []
        }
        let lowerBound = max(region.startLine, 0)
        let upperBound = min(endLine - 1, sourceLines.count)
        guard lowerBound < upperBound else {
            return []
        }
        let nonCommentPayloadLines = sourceLines[lowerBound..<upperBound].enumerated().compactMap { offset, line in
            let lineNumber = lowerBound + offset + 1
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            return trimmed.hasPrefix(";") ? nil : "\(lineNumber)"
        }
        guard !nonCommentPayloadLines.isEmpty else {
            return []
        }
        return ["Model region contains non-comment payload at line(s): \(nonCommentPayloadLines.joined(separator: ", "))."]
    }

    private static func modelRegionCanonicalFailures(index: AmigaSourceIndex, model: AmigaProgramModel, sourceLines: [String]) -> [String] {
        guard let region = index.regions[AmigaSourceRegionName.model.rawValue],
              let endLine = region.endLine,
              let expectedRegion = try? AmigaSourceIndexer.modelRegion(for: model) else {
            return []
        }
        let lowerBound = max(region.startLine - 1, 0)
        let upperBound = min(endLine, sourceLines.count)
        guard lowerBound < upperBound else {
            return []
        }
        let actualLines = Array(sourceLines[lowerBound..<upperBound])
        let expectedLines = expectedRegion.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        guard actualLines != expectedLines else {
            return []
        }
        return ["Model region is not canonical encoded AmigaProgramModel JSON."]
    }

    private static func regionBoundaryFailures(sourceLines: [String]) -> [String] {
        let requiredRegions: [AmigaSourceRegionName] = [
            .model,
            .controls,
            .drawControls,
            .hitTest,
            .inputDispatch,
            .routines,
            .state,
            .chipData
        ]
        var beginCounts: [String: Int] = [:]
        var endCounts: [String: Int] = [:]
        var beginLines: [String: Int] = [:]
        var endLines: [String: Int] = [:]
        var unknownRegionNames: Set<String> = []
        var invalidRegionActions: Set<String> = []
        let canonicalRegionNames = Set(AmigaSourceRegionName.allCases.map(\.rawValue))
        for (offset, line) in sourceLines.enumerated() {
            let lineNumber = offset + 1
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            let prefix = "; @amiga:region "
            guard trimmed.hasPrefix(prefix) else { continue }
            let parts = trimmed.dropFirst(prefix.count).split(separator: " ").map(String.init)
            guard parts.count == 2 else { continue }
            if !canonicalRegionNames.contains(parts[0]) {
                unknownRegionNames.insert(parts[0])
            }
            switch parts[1] {
            case "begin":
                beginCounts[parts[0], default: 0] += 1
                beginLines[parts[0]] = lineNumber
            case "end":
                endCounts[parts[0], default: 0] += 1
                endLines[parts[0]] = lineNumber
            default:
                invalidRegionActions.insert("\(parts[0]) \(parts[1])")
                continue
            }
        }

        var failures: [String] = []
        for name in unknownRegionNames.sorted() {
            failures.append("Unknown source region marker: \(name).")
        }
        for marker in invalidRegionActions.sorted() {
            failures.append("Invalid source region marker action: \(marker).")
        }
        var previousRegion: AmigaSourceRegionName?
        var previousEndLine: Int?
        for region in requiredRegions {
            let name = region.rawValue
            let beginCount = beginCounts[name, default: 0]
            let endCount = endCounts[name, default: 0]
            if beginCount != 1 {
                failures.append("Region \(name) must have exactly one begin marker (found \(beginCount)).")
            }
            if endCount != 1 {
                failures.append("Region \(name) must have exactly one end marker (found \(endCount)).")
            }
            guard beginCount == 1,
                  endCount == 1,
                  let beginLine = beginLines[name],
                  let endLine = endLines[name] else {
                continue
            }
            if beginLine >= endLine {
                failures.append("Region \(name) end marker appears before its begin marker.")
            }
            if let previousRegion, let previousEndLine, beginLine <= previousEndLine {
                failures.append("Region \(name) begins before previous required region \(previousRegion.rawValue) is closed.")
            }
            previousRegion = region
            previousEndLine = endLine
        }
        return failures
    }

    private static func unmodeledRoutineLabelFailures(
        model: AmigaProgramModel,
        index: AmigaSourceIndex,
        sourceLines: [String]
    ) -> [String] {
        let modeledRoutineLabels = Set(model.routines.map(\.label))
        let routineRegions: [AmigaSourceRegionName] = [
            .drawControls,
            .hitTest,
            .inputDispatch,
            .routines
        ]
        var failures: [String] = []
        for region in routineRegions {
            let labels = sourceLabels(inRegion: region.rawValue, index: index, sourceLines: sourceLines)
            let unmodeledLabels = labels.filter { !modeledRoutineLabels.contains($0) }
            if !unmodeledLabels.isEmpty {
                failures.append("Region \(region.rawValue) declares unmodeled routine labels: \(unmodeledLabels.joined(separator: ", ")).")
            }
        }
        return failures
    }

    private static func unmodeledStateSymbolFailures(
        model: AmigaProgramModel,
        index: AmigaSourceIndex,
        sourceLines: [String]
    ) -> [String] {
        let modeledSymbols = Set(model.stateVariables.map(\.symbol))
        let sourceSymbols = sourceLabels(inRegion: AmigaSourceRegionName.state.rawValue, index: index, sourceLines: sourceLines)
        let unmodeledSymbols = sourceSymbols.filter { !modeledSymbols.contains($0) }
        guard !unmodeledSymbols.isEmpty else { return [] }
        return ["State region declares unmodeled symbols: \(unmodeledSymbols.joined(separator: ", "))."]
    }

    private static func unmodeledKnownFamilyChipDataFailures(
        model: AmigaProgramModel,
        index: AmigaSourceIndex,
        sourceLines: [String]
    ) -> [String] {
        let allowedLabels: Set<String>
        if model.id == AmigaProgramFamilyRegistry.modPlayerControls.id {
            var labels = Set(["BitplaneBuffer", "Sample"])
            for control in model.controls {
                labels.insert("ControlRect_\(control.id)")
                labels.insert("ControlLabel_\(control.id)")
            }
            allowedLabels = labels
        } else if model.id == AmigaProgramFamilyRegistry.doubleBufferedBitplane.id {
            allowedLabels = Set([
                "BufferA",
                "BufferB",
                "PatternA",
                "PatternB",
                "CopperList",
                "CopperBplHi",
                "CopperBplLo",
                "CopperSpr0Hi",
                "CopperSpr0Lo",
                "SpriteData"
            ])
        } else {
            return []
        }

        let sourceLabels = sourceLabels(inRegion: AmigaSourceRegionName.chipData.rawValue, index: index, sourceLines: sourceLines)
        let unmodeledLabels = sourceLabels.filter { !allowedLabels.contains($0) }
        guard !unmodeledLabels.isEmpty else { return [] }
        return ["Chip data region declares unmodeled labels: \(unmodeledLabels.joined(separator: ", "))."]
    }

    private static func unmodeledControlMarkerFailures(
        model: AmigaProgramModel,
        index: AmigaSourceIndex,
        sourceLines: [String]
    ) -> [String] {
        guard !model.controls.isEmpty else { return [] }
        let modeledControlIDs = Set(model.controls.map(\.id))
        let markerRequirements: [(region: AmigaSourceRegionName, pattern: String, description: String)] = [
            (.controls, #"@amiga:model control id=([A-Za-z0-9_]+)\b"#, "control markers"),
            (.drawControls, #"@amiga:draw_control ([A-Za-z0-9_]+)\b"#, "draw markers"),
            (.hitTest, #"@amiga:hittest ([A-Za-z0-9_]+)\b"#, "hit-test markers"),
            (.inputDispatch, #"@amiga:dispatch ([A-Za-z0-9_]+)\s*->"#, "dispatch markers")
        ]
        var failures: [String] = []
        for requirement in markerRequirements {
            let markerIDs = markerIDsMatching(
                requirement.pattern,
                inRegion: requirement.region.rawValue,
                index: index,
                sourceLines: sourceLines
            )
            let unmodeledIDs = markerIDs.filter { !modeledControlIDs.contains($0) }
            if !unmodeledIDs.isEmpty {
                failures.append("Region \(requirement.region.rawValue) declares unmodeled \(requirement.description): \(unmodeledIDs.joined(separator: ", ")).")
            }
            let duplicateIDs = duplicateValues(markerIDs)
            if !duplicateIDs.isEmpty {
                failures.append("Region \(requirement.region.rawValue) declares duplicate \(requirement.description): \(duplicateIDs.joined(separator: ", ")).")
            }
        }
        return failures
    }

    private static func doubleBufferedBitplaneFailures(
        model: AmigaProgramModel,
        index: AmigaSourceIndex,
        sourceLines: [String],
        stateLines: [String]
    ) -> [String] {
        var failures: [String] = []
        let startupLines = linesAfterLabel("_Start", untilFirstRegionUsing: index, sourceLines: sourceLines)
        let mainLoopLines = linesAfterLabel(".main", untilFirstRegionUsing: index, sourceLines: sourceLines)
        let showALines = linesAfterLabel(".showA", untilFirstRegionUsing: index, sourceLines: sourceLines)
        let showBLines = linesAfterLabel(".showB", untilFirstRegionUsing: index, sourceLines: sourceLines)
        let waitVBlankLines = linesInRoutine("WaitVBlank", inRegion: AmigaSourceRegionName.hitTest.rawValue, index: index, sourceLines: sourceLines)
        let drawBufferALines = linesInRoutine("DrawBufferA", inRegion: AmigaSourceRegionName.routines.rawValue, index: index, sourceLines: sourceLines)
        let drawBufferBLines = linesInRoutine("DrawBufferB", inRegion: AmigaSourceRegionName.routines.rawValue, index: index, sourceLines: sourceLines)
        let copyPatternLines = linesInRoutine("CopyPattern", inRegion: AmigaSourceRegionName.routines.rawValue, index: index, sourceLines: sourceLines)

        if model.kind != .effect {
            failures.append("Double-buffered bitplane model must be an effect.")
        }
        if !model.controls.isEmpty {
            failures.append("Double-buffered bitplane model must not declare UI controls.")
        }
        if !model.hardware.contains(.bitplanes) {
            failures.append("Double-buffered bitplane model is missing bitplane hardware dependency.")
        }
        if !model.hardware.contains(.cia) {
            failures.append("Double-buffered bitplane model is missing CIA hardware dependency.")
        }
        if !model.hardware.contains(.copper) {
            failures.append("Double-buffered bitplane model is missing copper hardware dependency.")
        }
        if !model.hardware.contains(.sprites) {
            failures.append("Double-buffered bitplane model is missing sprite hardware dependency.")
        }
        failures.append(contentsOf: doubleBufferedBitplaneRoutineCallFailures(model: model))
        if !containsLabel("BufferA", inRegion: AmigaSourceRegionName.chipData.rawValue, index: index, sourceLines: sourceLines) {
            failures.append("Double-buffered bitplane source is missing BufferA chip data.")
        }
        if !containsLabel("BufferB", inRegion: AmigaSourceRegionName.chipData.rawValue, index: index, sourceLines: sourceLines) {
            failures.append("Double-buffered bitplane source is missing BufferB chip data.")
        }
        if !containsLabel("PatternA", inRegion: AmigaSourceRegionName.chipData.rawValue, index: index, sourceLines: sourceLines) {
            failures.append("Double-buffered bitplane source is missing PatternA chip data.")
        }
        if !containsLabel("PatternB", inRegion: AmigaSourceRegionName.chipData.rawValue, index: index, sourceLines: sourceLines) {
            failures.append("Double-buffered bitplane source is missing PatternB chip data.")
        }
        if !containsLabel("CopperList", inRegion: AmigaSourceRegionName.chipData.rawValue, index: index, sourceLines: sourceLines) {
            failures.append("Double-buffered bitplane source is missing owned copper list data.")
        }
        if !containsLabel("SpriteData", inRegion: AmigaSourceRegionName.chipData.rawValue, index: index, sourceLines: sourceLines) {
            failures.append("Double-buffered bitplane source is missing sprite overlay data.")
        }
        if !containsLabel("FrontColor", in: stateLines) || !containsLabel("BackColor", in: stateLines) {
            failures.append("Double-buffered bitplane source is missing front/back color state.")
        }
        if !startupLines.contains(where: { doubleBufferedLeaLine($0, source: "BufferA", destination: "a2") }) ||
            !startupLines.contains(where: { doubleBufferedLeaLine($0, source: "BufferB", destination: "a3") }) {
            failures.append("Double-buffered bitplane startup does not bind both front and back buffers.")
        }
        if !startupLines.contains(where: { doubleBufferedMoveWordImmediateLine($0, value: 0x1200, destinationDisplacement: 0x100, register: "a6") }) {
            failures.append("Double-buffered bitplane startup does not configure one low-res bitplane.")
        }
        if !startupLines.contains(where: { doubleBufferedMoveWordImmediateLine($0, value: 0x83a0, destinationDisplacement: 0x96, register: "a6") }) {
            failures.append("Double-buffered bitplane startup does not enable bitplane, copper, and sprite DMA.")
        }
        if !startupLines.contains(where: { doubleBufferedMoveLongRegisterLine($0, source: "a4", destinationDisplacement: 0x120, register: "a6") }) {
            failures.append("Double-buffered bitplane startup does not program the sprite overlay pointer.")
        }
        if !startupLines.contains(where: { doubleBufferedMoveLongRegisterLine($0, source: "a0", destinationDisplacement: 0x80, register: "a6") }) {
            failures.append("Double-buffered bitplane startup does not install an owned copper list.")
        }
        if !mainLoopLines.contains(where: { doubleBufferedBtstLine($0, bit: 6, destination: "$bfe001") }) ||
            !containsOrderedLineEvidence([
                { doubleBufferedBtstLine($0, bit: 6, destination: "$bfe001") },
                { isDirectBranchLine($0, mnemonic: "beq", target: ".done") }
            ], in: mainLoopLines) {
            failures.append("Double-buffered bitplane main loop does not exit on left mouse click.")
        }
        if !mainLoopLines.contains(where: { isDirectSubroutineCallLine($0, target: "WaitVBlank") }) ||
            !waitVBlankLines.contains(where: { containsExecutableAddressOperand($0, displacement: 0x06, register: "a6") }) {
            failures.append("Double-buffered bitplane swaps are not paced by vertical blank.")
        }
        if !containsOrderedLineEvidence(
            [
                { doubleBufferedMoveWordSymbolLine($0, source: "FrontColor(pc)", destinationDisplacement: 0x182, register: "a6") },
                { doubleBufferedMoveLongRegisterLine($0, source: "a2", destinationDisplacement: 0xe0, register: "a6") },
                { isDirectSubroutineCallLine($0, target: "DrawBufferB") },
                { doubleBufferedMoveQuickLine($0, value: 1, destination: "d2") },
                { isDirectBranchLine($0, mnemonic: "bra", target: ".main") }
            ],
            in: showALines
        ) {
            failures.append("Double-buffered bitplane front-buffer path does not show BufferA and draw BufferB.")
        }
        if !containsOrderedLineEvidence(
            [
                { doubleBufferedMoveWordSymbolLine($0, source: "BackColor(pc)", destinationDisplacement: 0x182, register: "a6") },
                { doubleBufferedMoveLongRegisterLine($0, source: "a3", destinationDisplacement: 0xe0, register: "a6") },
                { isDirectSubroutineCallLine($0, target: "DrawBufferA") },
                { doubleBufferedMoveQuickLine($0, value: 0, destination: "d2") },
                { isDirectBranchLine($0, mnemonic: "bra", target: ".main") }
            ],
            in: showBLines
        ) {
            failures.append("Double-buffered bitplane back-buffer path does not show BufferB and draw BufferA.")
        }
        if !containsOrderedLineEvidence([
            { doubleBufferedLeaLine($0, source: "BufferA", destination: "a0") },
            { doubleBufferedLeaLine($0, source: "PatternA", destination: "a1") },
            { isDirectBranchLine($0, mnemonic: "bra", target: "CopyPattern") }
        ], in: drawBufferALines) {
            failures.append("DrawBufferA does not copy PatternA into BufferA.")
        }
        if !containsOrderedLineEvidence([
            { doubleBufferedLeaLine($0, source: "BufferB", destination: "a0") },
            { doubleBufferedLeaLine($0, source: "PatternB", destination: "a1") }
        ], in: drawBufferBLines) {
            failures.append("DrawBufferB does not copy PatternB into BufferB.")
        }
        if !containsOrderedLineEvidence([
            { doubleBufferedCopyPatternMoveLine($0) },
            { doubleBufferedCopyPatternLoopLine($0) },
            { isReturnInstructionLine($0) }
        ], in: copyPatternLines) {
            failures.append("CopyPattern does not copy bitplane data into the hidden buffer.")
        }
        return failures
    }

    private static func doubleBufferedLeaLine(_ line: String, source: String, destination: String) -> Bool {
        let operands = normalizedInstructionOperands(line, mnemonic: "lea")
        return operands.count == 2 &&
            operands[0] == source.lowercased() &&
            operands[1] == destination.lowercased()
    }

    private static func doubleBufferedMoveWordImmediateLine(_ line: String, value: Int, destinationDisplacement: Int, register: String) -> Bool {
        let operands = normalizedInstructionOperands(line, mnemonic: "move.w")
        return operands.count == 2 &&
            immediateWordValue(operands[0]) == value &&
            addressRegisterOperand(operands[1], displacement: destinationDisplacement, register: register)
    }

    private static func doubleBufferedMoveWordSymbolLine(_ line: String, source: String, destinationDisplacement: Int, register: String) -> Bool {
        let operands = normalizedInstructionOperands(line, mnemonic: "move.w")
        return operands.count == 2 &&
            operands[0] == source.lowercased() &&
            addressRegisterOperand(operands[1], displacement: destinationDisplacement, register: register)
    }

    private static func doubleBufferedMoveLongRegisterLine(_ line: String, source: String, destinationDisplacement: Int, register: String) -> Bool {
        let operands = normalizedInstructionOperands(line, mnemonic: "move.l")
        return operands.count == 2 &&
            operands[0] == source.lowercased() &&
            addressRegisterOperand(operands[1], displacement: destinationDisplacement, register: register)
    }

    private static func doubleBufferedMoveQuickLine(_ line: String, value: Int, destination: String) -> Bool {
        let operands = normalizedInstructionOperands(line, mnemonic: "moveq")
        return operands.count == 2 &&
            immediateWordValue(operands[0]) == value &&
            operands[1] == destination.lowercased()
    }

    private static func doubleBufferedBtstLine(_ line: String, bit: Int, destination: String) -> Bool {
        let operands = normalizedInstructionOperands(line, mnemonic: "btst")
        return operands.count == 2 &&
            immediateWordValue(operands[0]) == bit &&
            operands[1] == destination.lowercased()
    }

    private static func doubleBufferedCopyPatternMoveLine(_ line: String) -> Bool {
        let operands = normalizedInstructionOperands(line, mnemonic: "move.l")
        return operands == ["(a1)+", "(a0)+"]
    }

    private static func doubleBufferedCopyPatternLoopLine(_ line: String) -> Bool {
        let normalizedLine = normalizedAssemblyLine(line)
        guard let instruction = normalizedExecutableInstruction(normalizedLine),
              instruction.operands == ["d0", ".copy"] else {
            return false
        }
        let mnemonicParts = instruction.mnemonic.split(separator: ".", maxSplits: 1).map(String.init)
        guard mnemonicParts.first == "dbf" else {
            return false
        }
        return mnemonicParts.count == 1 || mnemonicParts.last == "w"
    }

    private static func containsExecutableAddressOperand(_ line: String, displacement: Int, register: String) -> Bool {
        let normalizedLine = normalizedAssemblyLine(line)
        guard let instruction = normalizedExecutableInstruction(normalizedLine) else {
            return false
        }
        return instruction.operands.contains {
            addressRegisterOperand($0, displacement: displacement, register: register)
        }
    }

    private static func addressRegisterOperand(_ operand: String, displacement: Int, register: String) -> Bool {
        let suffix = "(\(register.lowercased()))"
        guard operand.hasSuffix(suffix) else {
            return false
        }
        let valueText = String(operand.dropLast(suffix.count))
        return controlRectWordValue(valueText) == displacement
    }

    private static func doubleBufferedBitplaneRoutineCallFailures(model: AmigaProgramModel) -> [String] {
        let requiredCallsByRoutineID: [(id: String, label: String, calls: [String])] = [
            ("draw_buffer_a", "DrawBufferA", ["CopyPattern"]),
            ("draw_buffer_b", "DrawBufferB", ["CopyPattern"])
        ]
        var failures: [String] = []
        for requirement in requiredCallsByRoutineID {
            guard let routine = model.routines.first(where: { $0.id == requirement.id && $0.label == requirement.label }) else {
                continue
            }
            let missingCalls = requirement.calls.filter { !routine.calls.contains($0) }
            if !missingCalls.isEmpty {
                failures.append("Double-buffered bitplane routine \(requirement.label) is missing model calls: \(missingCalls.joined(separator: ", ")).")
            }
        }
        return failures
    }

    private static func sourceLabels(inRegion name: String, index: AmigaSourceIndex, sourceLines: [String]) -> [String] {
        guard let region = index.regions[name], let endLine = region.endLine else {
            return []
        }
        let lowerBound = max(region.startLine - 1, 0)
        let upperBound = min(endLine - 1, sourceLines.count)
        guard lowerBound < upperBound else {
            return []
        }
        return sourceLines[lowerBound..<upperBound].compactMap { line in
            guard let label = AmigaSourceIndexer.labelName(from: line), !label.hasPrefix(".") else {
                return nil
            }
            return label
        }
    }

    private static func markerIDsMatching(
        _ pattern: String,
        inRegion name: String,
        index: AmigaSourceIndex,
        sourceLines: [String]
    ) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let region = index.regions[name],
              let endLine = region.endLine else {
            return []
        }
        let lowerBound = max(region.startLine - 1, 0)
        let upperBound = min(endLine - 1, sourceLines.count)
        guard lowerBound < upperBound else {
            return []
        }
        var ids: [String] = []
        for line in sourceLines[lowerBound..<upperBound] {
            guard let marker = markerCommentText(in: line) else { continue }
            let range = NSRange(marker.startIndex..<marker.endIndex, in: marker)
            guard let match = regex.firstMatch(in: marker, range: range),
                  match.numberOfRanges > 1,
                  let idRange = Range(match.range(at: 1), in: marker) else {
                continue
            }
            ids.append(String(marker[idRange]))
        }
        return ids
    }

    private static func registeredFamilyKindFailures(_ model: AmigaProgramModel) -> [String] {
        guard let manifest = AmigaProgramFamilyRegistry.manifest(for: model.id),
              model.kind != manifest.kind else {
            return []
        }
        return ["Registered family \(model.id) must use model kind \(manifest.kind.rawValue), not \(model.kind.rawValue)."]
    }

    private static func blankFieldFailures(values: [String], fieldName: String) -> [String] {
        let indexes = values.enumerated().compactMap { offset, value in
            value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "\(offset)" : nil
        }
        guard !indexes.isEmpty else { return [] }
        return ["Blank \(fieldName) at index: \(indexes.joined(separator: ", "))."]
    }

    private static func untrimmedFieldFailures(values: [String], fieldName: String) -> [String] {
        let indexes = values.enumerated().compactMap { offset, value in
            let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
            return !trimmed.isEmpty && value != trimmed ? "\(offset)" : nil
        }
        guard !indexes.isEmpty else { return [] }
        return ["\(fieldName.capitalized) have leading or trailing whitespace at index: \(indexes.joined(separator: ", "))."]
    }

    private static func controlCharacterFieldFailures(values: [String], fieldName: String) -> [String] {
        let indexes = values.enumerated().compactMap { offset, value in
            value.unicodeScalars.contains(where: { CharacterSet.controlCharacters.contains($0) }) ? "\(offset)" : nil
        }
        guard !indexes.isEmpty else { return [] }
        return ["\(fieldName.capitalized) contain line breaks or control characters at index: \(indexes.joined(separator: ", "))."]
    }

    private static func blankOptionalFieldFailures(values: [String?], fieldName: String) -> [String] {
        let indexes = values.enumerated().compactMap { offset, value in
            guard let value = value else { return nil as String? }
            return value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "\(offset)" : nil
        }
        guard !indexes.isEmpty else { return [] }
        return ["Blank \(fieldName) at index: \(indexes.joined(separator: ", "))."]
    }

    private static func untrimmedOptionalFieldFailures(values: [String?], fieldName: String) -> [String] {
        let indexes = values.enumerated().compactMap { offset, value in
            guard let value = value else { return nil as String? }
            let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
            return !trimmed.isEmpty && value != trimmed ? "\(offset)" : nil
        }
        guard !indexes.isEmpty else { return [] }
        return ["\(fieldName.capitalized) have leading or trailing whitespace at index: \(indexes.joined(separator: ", "))."]
    }

    private static func controlCharacterOptionalFieldFailures(values: [String?], fieldName: String) -> [String] {
        let indexes = values.enumerated().compactMap { offset, value in
            guard let value = value else { return nil as String? }
            return value.unicodeScalars.contains(where: { CharacterSet.controlCharacters.contains($0) }) ? "\(offset)" : nil
        }
        guard !indexes.isEmpty else { return [] }
        return ["\(fieldName.capitalized) contain line breaks or control characters at index: \(indexes.joined(separator: ", "))."]
    }

    private static func identifierFormatFailures(
        values: [String],
        fieldName: String,
        styleName: String,
        isValid: (String) -> Bool
    ) -> [String] {
        let indexes = values.enumerated().compactMap { offset, value in
            let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
            return !trimmed.isEmpty && value == trimmed && !isValid(value) ? "\(offset)" : nil
        }
        guard !indexes.isEmpty else { return [] }
        return ["\(fieldName.capitalized) are not canonical \(styleName) identifiers at index: \(indexes.joined(separator: ", "))."]
    }

    private static func isKebabIdentifier(_ value: String) -> Bool {
        value.range(of: #"^[a-z][a-z0-9]*(?:-[a-z0-9]+)*$"#, options: .regularExpression) != nil
    }

    private static func isSnakeIdentifier(_ value: String) -> Bool {
        value.range(of: #"^[a-z][a-z0-9]*(?:_[a-z0-9]+)*$"#, options: .regularExpression) != nil
    }

    private static func isAssemblyLabelIdentifier(_ value: String) -> Bool {
        value.range(of: #"^[A-Za-z_.$][A-Za-z0-9_.$]*$"#, options: .regularExpression) != nil
    }

    private static func controlActionRoutineFailures(model: AmigaProgramModel) -> [String] {
        var failures: [String] = []
        for control in model.controls {
            guard model.routines.contains(where: { $0.id == control.id && $0.label == control.action }) else {
                failures.append("Control \(control.label) action \(control.action) is not declared as model routine id \(control.id).")
                continue
            }
        }
        return failures
    }

    private static func intuitionWindowToolSourceFailures(
        model: AmigaProgramModel,
        index: AmigaSourceIndex,
        sourceLines: [String]
    ) -> [String] {
        var failures: [String] = []
        let source = sourceLines.joined(separator: "\n")
        let stateLines = lines(inRegion: AmigaSourceRegionName.state.rawValue, index: index, sourceLines: sourceLines)
        let chipDataLines = lines(inRegion: AmigaSourceRegionName.chipData.rawValue, index: index, sourceLines: sourceLines)

        let requiredSnippets: [(String, String)] = [
            ("Intuition source is missing intuition.library name.", "\"intuition.library\""),
            ("Intuition source is missing OpenLibrary call.", "jsr        -552(a6)             ; OpenLibrary(\"intuition.library\")"),
            ("Intuition source is missing OpenWindow call.", "jsr        -204(a6)             ; OpenWindow(&NewWindow)"),
            ("Intuition source is missing WaitPort event wait.", "jsr        -384(a6)             ; WaitPort(UserPort)"),
            ("Intuition source is missing GetMsg event read.", "jsr        -372(a6)             ; GetMsg(UserPort)"),
            ("Intuition source is missing ReplyMsg call.", "jsr        -378(a6)             ; ReplyMsg(message)"),
            ("Intuition source is missing close-window IDCMP test.", "cmp.l      #IDCMP_CLOSEWINDOW,d2"),
            ("Intuition source is missing gadget-up IDCMP test.", "cmp.l      #IDCMP_GADGETUP,d2"),
            ("Intuition close-window path does not branch to cleanup.", "beq        CleanupAndExit"),
            ("OpenWindow failure does not route to library cleanup.", "beq        CloseLibraryOnly"),
            ("Intuition source is missing CloseWindow cleanup.", "jsr        -72(a6)              ; CloseWindow(WindowPtr)"),
            ("Intuition source is missing CloseLibrary cleanup.", "jsr        -414(a6)             ; CloseLibrary(IntuitionBase)")
        ]
        for (failure, snippet) in requiredSnippets where !source.contains(snippet) {
            failures.append(failure)
        }

        if let closeWindow = source.range(of: "jsr        -72(a6)              ; CloseWindow(WindowPtr)"),
           let closeLibrary = source.range(of: "jsr        -414(a6)             ; CloseLibrary(IntuitionBase)"),
           closeWindow.lowerBound > closeLibrary.lowerBound {
            failures.append("Intuition cleanup closes the library before the window.")
        }

        for stateVariable in model.stateVariables {
            if !containsLabel(stateVariable.symbol, in: stateLines) {
                failures.append("Intuition state symbol \(stateVariable.symbol) is not declared in the state region.")
            }
        }

        guard containsLabel("NewWindow", in: chipDataLines) else {
            failures.append("Intuition source is missing NewWindow data.")
            return failures
        }

        for (offset, control) in model.controls.enumerated() {
            let slot = offset + 1
            let gadgetLabel = "Gadget_\(control.id)"
            let textLabel = "Text_\(control.id)"
            let labelSymbol = "Label_\(control.id)"

            guard let gadgetIndex = labelLineIndex(gadgetLabel, inRegion: AmigaSourceRegionName.chipData.rawValue, index: index, sourceLines: sourceLines) else {
                failures.append("Intuition control \(control.label) is missing Gadget_\(control.id) data.")
                continue
            }
            if let bounds = control.bounds {
                let expectedBounds = [bounds.x, bounds.y, bounds.width, bounds.height]
                let gadgetWindow = sourceLines[(gadgetIndex + 1)...].prefix(14)
                let boundsValues = gadgetWindow
                    .compactMap { line -> [Int]? in
                        let normalized = normalizedAssemblyLine(line)
                        guard normalized.hasPrefix("dc.w ") else { return nil }
                        let values = normalized
                            .dropFirst("dc.w ".count)
                            .split(separator: ",", omittingEmptySubsequences: false)
                            .compactMap { controlRectWordValue(String($0)) }
                        return values.count == 4 ? values : nil
                    }
                    .first
                if boundsValues != expectedBounds ||
                    !gadgetWindow.map(normalizedAssemblyLine).contains("dc.w \(slot)") {
                    failures.append("Intuition Gadget_\(control.id) data does not match model bounds and slot.")
                }
            }
            if !sourceLines[(gadgetIndex + 1)...].prefix(12).contains(where: { normalizedAssemblyLine($0) == "dc.l \(textLabel.lowercased())" }) {
                failures.append("Intuition Gadget_\(control.id) does not point to \(textLabel).")
            }
            if labelLineIndex(textLabel, inRegion: AmigaSourceRegionName.chipData.rawValue, index: index, sourceLines: sourceLines) == nil {
                failures.append("Intuition control \(control.label) is missing \(textLabel) data.")
            }
            if let labelIndex = labelLineIndex(labelSymbol, inRegion: AmigaSourceRegionName.chipData.rawValue, index: index, sourceLines: sourceLines) {
                if !labelDataMatches(control.label, after: labelIndex, sourceLines: sourceLines) {
                    failures.append("Intuition label data for \(control.label) does not match the model label.")
                }
            } else {
                failures.append("Intuition control \(control.label) is missing \(labelSymbol) label data.")
            }

            let dispatchMarker = "@amiga:dispatch \(control.id) -> \(control.action)"
            guard let markerIndex = firstLineIndex(containing: dispatchMarker, inRegion: AmigaSourceRegionName.inputDispatch.rawValue, index: index, sourceLines: sourceLines) else {
                failures.append("Intuition control \(control.label) is missing dispatch marker.")
                continue
            }
            let dispatchWindow = sourceLines[(markerIndex + 1)...].prefix(5).map(normalizedAssemblyLine)
            if !dispatchWindow.contains("cmp.l #\(gadgetLabel.lowercased()),a2") {
                failures.append("Intuition dispatch for \(control.label) does not compare IAddress with \(gadgetLabel).")
            }
            if !dispatchWindow.contains(where: { $0 == "bsr \(control.action.lowercased())" }) {
                failures.append("Intuition dispatch for \(control.label) does not call \(control.action).")
            }
            if labelLineIndex(control.action, inRegion: AmigaSourceRegionName.routines.rawValue, index: index, sourceLines: sourceLines) == nil {
                failures.append("Intuition action routine \(control.action) is not inside the routines region.")
            }
        }

        if model.stateVariables.contains(where: { $0.id == "status_text" }) &&
            labelLineIndex("StatusText", inRegion: AmigaSourceRegionName.chipData.rawValue, index: index, sourceLines: sourceLines) == nil {
            failures.append("Intuition model declares status_text without StatusText data.")
        }

        return failures
    }

    private static func boundedControlSupportRoutineFailures(model: AmigaProgramModel) -> [String] {
        guard model.controls.contains(where: { $0.bounds != nil }) else { return [] }
        let requiredSupportRoutines = [
            ("draw_controls", "DrawControls"),
            ("draw_control_rect", "DrawControlRect"),
            ("draw_control_label", "DrawControlLabel"),
            ("wait_vblank", "WaitVBlank"),
            ("read_mouse", "ReadMouseControls"),
            ("hit_test", "HitTestControls"),
            ("dispatch", "InputDispatch")
        ]
        return requiredSupportRoutines.compactMap { id, label in
            guard model.routines.contains(where: { $0.id == id && $0.label == label }) else {
                return "Bounded control model is missing support routine id \(id) label \(label)."
            }
            return nil
        }
    }

    private static func boundedControlSupportRoutineCallFailures(model: AmigaProgramModel) -> [String] {
        guard model.controls.contains(where: { $0.bounds != nil }) else { return [] }
        var failures: [String] = []
        let requiredCallsByRoutineID: [(id: String, label: String, calls: [String])] = [
            ("draw_controls", "DrawControls", ["DrawControlRect"]),
            ("draw_control_rect", "DrawControlRect", ["DrawControlLabel"]),
            ("dispatch", "InputDispatch", model.controls.map(\.action))
        ]
        for requirement in requiredCallsByRoutineID {
            guard let routine = model.routines.first(where: { $0.id == requirement.id && $0.label == requirement.label }) else {
                continue
            }
            let missingCalls = requirement.calls.filter { !routine.calls.contains($0) }
            if !missingCalls.isEmpty {
                failures.append("Bounded control support routine \(requirement.label) is missing model calls: \(missingCalls.joined(separator: ", ")).")
            }
        }
        return failures
    }

    private static func boundedControlStateVariableFailures(model: AmigaProgramModel) -> [String] {
        guard model.controls.contains(where: { $0.bounds != nil }) else { return [] }
        let requiredStateVariables = [
            ("selected_control", "SelectedControl", "1"),
            ("activated_control", "ActivatedControl", "0"),
            ("mouse_x", "MouseX", "40"),
            ("mouse_y", "MouseY", "48"),
            ("mouse_raw_x", "MouseRawX", "40"),
            ("mouse_raw_y", "MouseRawY", "48"),
            ("mouse_buttons", "MouseButtons", "0"),
            ("mouse_was_buttons", "MouseWasButtons", "0"),
            ("mouse_clicked", "MouseClicked", "0")
        ]

        var failures: [String] = []
        for (id, symbol, initialValue) in requiredStateVariables {
            guard let stateVariable = model.stateVariables.first(where: { $0.id == id && $0.symbol == symbol }) else {
                failures.append("Bounded control model is missing UI state id \(id) symbol \(symbol).")
                continue
            }
            if stateVariable.initialValue != initialValue {
                failures.append("Bounded control model UI state \(symbol) initial value \(stateVariable.initialValue ?? "unset") does not match \(initialValue).")
            }
        }
        return failures
    }

    private static func controlBoundsFailures(_ controls: [AmigaProgramModel.Control]) -> [String] {
        var failures: [String] = []
        for control in controls {
            guard let bounds = control.bounds else { continue }
            if bounds.width <= 0 || bounds.height <= 0 {
                failures.append("Control \(control.label) has non-positive model bounds.")
            }
            if bounds.x < 0 || bounds.y < 0 || bounds.x + bounds.width > 320 || bounds.y + bounds.height > 256 {
                failures.append("Control \(control.label) model bounds are outside the 320x256 UI surface.")
            }
        }
        for leftIndex in controls.indices {
            guard let leftBounds = controls[leftIndex].bounds else { continue }
            for rightIndex in controls.indices where rightIndex > leftIndex {
                guard let rightBounds = controls[rightIndex].bounds else { continue }
                if boundsOverlap(leftBounds, rightBounds) {
                    failures.append("Control \(controls[leftIndex].label) model bounds overlap \(controls[rightIndex].label).")
                }
            }
        }
        return failures
    }

    private static func boundsOverlap(_ left: AmigaProgramModel.Bounds, _ right: AmigaProgramModel.Bounds) -> Bool {
        left.x < right.x + right.width &&
            left.x + left.width > right.x &&
            left.y < right.y + right.height &&
            left.y + left.height > right.y
    }

    private static func hardwareDependencyFactFailures(
        model: AmigaProgramModel,
        index: AmigaSourceIndex,
        sourceLines: [String]
    ) -> [String] {
        let sourceProofs = hardwareSourceProofs(index: index, sourceLines: sourceLines)
        let modeledHardware = Set(model.hardware)
        var failures: [String] = []
        for hardware in model.hardware {
            if !sourceProofs.contains(hardware) {
                failures.append("Model declares \(hardware.rawValue) hardware dependency without source proof.")
            }
        }
        let undeclaredHardware = AmigaProgramModel.HardwareSubsystem.allCases
            .filter { sourceProofs.contains($0) && !modeledHardware.contains($0) }
        for hardware in undeclaredHardware {
            failures.append("Source uses \(hardware.rawValue) hardware without model dependency.")
        }
        return failures
    }

    private static func hardwareSourceProofs(index: AmigaSourceIndex, sourceLines: [String]) -> Set<AmigaProgramModel.HardwareSubsystem> {
        let normalizedLines = sourceLines.map(normalizedAssemblyLine)
        let executableInstructions = normalizedLines.compactMap(normalizedExecutableInstruction)
        var proofs: Set<AmigaProgramModel.HardwareSubsystem> = []
        if executableInstructions.contains(where: { instruction in
            instruction.operands.contains("$a0(a6)") ||
                instruction.operands.contains("$a4(a6)") ||
                instruction.operands.contains("$a6(a6)") ||
                instruction.operands.contains("$a8(a6)")
        }) {
            proofs.insert(.paula)
        }
        if executableInstructions.contains(where: { $0.operands.contains("$bfe001") }) {
            proofs.insert(.cia)
        }
        if executableInstructions.contains(where: { instruction in
            instruction.operands.contains("$100(a6)") ||
                instruction.operands.contains("$e0(a6)") ||
                (instruction.mnemonic == "lea" && instruction.operands.first?.hasPrefix("bitplanebuffer") == true)
        }) ||
            containsLabel("BitplaneBuffer", inRegion: AmigaSourceRegionName.chipData.rawValue, index: index, sourceLines: sourceLines) ||
            containsLabel("BufferA", inRegion: AmigaSourceRegionName.chipData.rawValue, index: index, sourceLines: sourceLines) {
            proofs.insert(.bitplanes)
        }
        if executableInstructions.contains(where: { $0.operands.contains("$80(a6)") || $0.operands.contains("$84(a6)") }) {
            proofs.insert(.copper)
        }
        if executableInstructions.contains(where: { $0.operands.contains("$120(a6)") || $0.operands.contains("$124(a6)") }) {
            proofs.insert(.sprites)
        }
        if executableInstructions.contains(where: { instruction in
            instruction.operands.contains("$40(a6)") ||
                instruction.operands.contains("$58(a6)") ||
                instruction.operands.contains("$66(a6)")
        }) {
            proofs.insert(.blitter)
        }
        if executableInstructions.contains(where: { instruction in
            instruction.operands.contains("$4.w") ||
                (sizedCallMnemonic(instruction.mnemonic) == "jsr" &&
                    instruction.operands.contains(where: { operand in
                        operand == "(a6)" || (operand.hasPrefix("-") && operand.hasSuffix("(a6)"))
                    })
                )
        }) {
            proofs.insert(.exec)
        }
        if sourceLines.contains(where: { $0.lowercased().contains("\"intuition.library\"") }) ||
            containsLabel("NewWindow", inRegion: AmigaSourceRegionName.chipData.rawValue, index: index, sourceLines: sourceLines) ||
            executableInstructions.contains(where: { instruction in
                sizedCallMnemonic(instruction.mnemonic) == "jsr" &&
                    instruction.operands.contains("-204(a6)")
            }) {
            proofs.insert(.intuition)
        }
        if sourceLines.contains(where: { $0.lowercased().contains("\"graphics.library\"") }) ||
            executableInstructions.contains(where: { instruction in
                sizedCallMnemonic(instruction.mnemonic) == "jsr" &&
                    (instruction.operands.contains("-222(a6)") || instruction.operands.contains("-270(a6)"))
            }) {
            proofs.insert(.graphics)
        }
        return proofs
    }

    private static func verificationExpectationFactFailures(
        model: AmigaProgramModel,
        index: AmigaSourceIndex,
        sourceLines: [String]
    ) -> [String] {
        var failures: [String] = []
        for expectation in model.verificationExpectations {
            let trimmed = expectation.trimmingCharacters(in: .whitespacesAndNewlines)
            if let match = regexMatch(#"^Control (.+) dispatches to ([A-Za-z_.$][A-Za-z0-9_.$]*)\.$"#, in: trimmed) {
                let label = match[1]
                let action = match[2]
                guard let control = model.controls.first(where: { $0.label == label }) else {
                    if model.controls.contains(where: { $0.action == action }) {
                        continue
                    }
                    failures.append("Verification expectation references unknown control \(label).")
                    continue
                }
                if control.action != action {
                    failures.append("Verification expectation for control \(label) claims action \(action) but model action is \(control.action).")
                }
                continue
            }

            if let match = regexMatch(#"^Initial volume is ([0-9]+)\.$"#, in: trimmed) {
                let expectedVolume = match[1]
                guard let audioVolume = model.stateVariables.first(where: { $0.id == "audio_volume" || $0.symbol == "AudioVolume" }) else {
                    failures.append("Verification expectation requires AudioVolume state.")
                    continue
                }
                if audioVolume.initialValue != expectedVolume {
                    failures.append("Verification expectation claims initial volume \(expectedVolume) but model AudioVolume is \(audioVolume.initialValue ?? "unset").")
                }
                continue
            }

            if let match = regexMatch(#"^Volume step is ([0-9]+)\.$"#, in: trimmed) {
                let expectedStep = match[1]
                if !volumeStepExpectationMatches(expectedStep, model: model, index: index, sourceLines: sourceLines) {
                    failures.append("Verification expectation claims volume step \(expectedStep) but no model volume routine uses that step.")
                }
                continue
            }

            if let match = regexMatch(#"^Playback period is ([0-9]+)\.$"#, in: trimmed) {
                let expectedPeriod = match[1]
                if !playbackPeriodExpectationMatches(expectedPeriod, model: model, index: index, sourceLines: sourceLines) {
                    failures.append("Verification expectation claims playback period \(expectedPeriod) but PlayMOD does not write AUD0PER with that period.")
                }
                continue
            }

            if let match = regexMatch(#"^(Front|Back) buffer color is ([a-z]+)\.$"#, in: trimmed) {
                let role = match[1].lowercased()
                let color = match[2]
                let stateID = "\(role)_color"
                let symbol = role == "front" ? "FrontColor" : "BackColor"
                guard let expectedColorValue = AmigaProgramTemplate.colorValue(named: color) else {
                    failures.append("Verification expectation uses unsupported \(role) buffer color \(color).")
                    continue
                }
                guard let stateVariable = model.stateVariables.first(where: { $0.id == stateID || $0.symbol == symbol }) else {
                    failures.append("Verification expectation requires \(symbol) state.")
                    continue
                }
                if stateVariable.initialValue?.lowercased() != expectedColorValue.lowercased() {
                    failures.append("Verification expectation claims \(role) buffer color \(color) but model \(symbol) is \(stateVariable.initialValue ?? "unset").")
                }
                continue
            }

            if trimmed == "Playback state is preserved as data for follow-up edits." {
                if !model.stateVariables.contains(where: { $0.id == "playback_state" || $0.symbol == "PlaybackState" }) {
                    failures.append("Verification expectation requires PlaybackState state.")
                }
                if !playbackStateExpectationMatches(model: model, index: index, sourceLines: sourceLines) {
                    failures.append("Verification expectation requires PlayMOD to set and StopMOD to clear PlaybackState.")
                }
                continue
            }

            if trimmed == "Startup previews PlayMOD for emulator-visible Paula register evidence." {
                let startupLines = entryStartupLines(sourceLines: sourceLines)
                if !startupLines.contains(where: { isDirectSubroutineCallLine($0, target: "PlayMOD") }) {
                    failures.append("Verification expectation requires startup to call PlayMOD.")
                }
            }
        }
        return failures
    }

    private static func playbackStateExpectationMatches(
        model: AmigaProgramModel,
        index: AmigaSourceIndex,
        sourceLines: [String]
    ) -> Bool {
        let hasPlayControl = model.controls.contains { $0.action == "PlayMOD" }
        let hasStopControl = model.controls.contains { $0.action == "StopMOD" }
        guard hasPlayControl, hasStopControl else { return false }

        let playLines = linesInRoutine("PlayMOD", inRegion: AmigaSourceRegionName.routines.rawValue, index: index, sourceLines: sourceLines)
        let stopLines = linesInRoutine("StopMOD", inRegion: AmigaSourceRegionName.routines.rawValue, index: index, sourceLines: sourceLines)

        return playLines.contains(where: { moveWordImmediateLine($0, value: 1, destination: "PlaybackState") }) &&
            stopLines.contains(where: { clearWordLine($0, destination: "PlaybackState") })
    }

    private static func volumeStepExpectationMatches(
        _ expectedStep: String,
        model: AmigaProgramModel,
        index: AmigaSourceIndex,
        sourceLines: [String]
    ) -> Bool {
        let volumeRoutines = model.controls
            .map(\.action)
            .filter { $0 == "VolumeUp" || $0 == "VolumeDown" }
        guard !volumeRoutines.isEmpty else { return false }
        guard let expectedValue = Int(expectedStep) else { return false }

        for routine in volumeRoutines {
            let mnemonic = routine == "VolumeUp" ? "add.w" : "sub.w"
            let lines = linesInRoutine(routine, inRegion: AmigaSourceRegionName.routines.rawValue, index: index, sourceLines: sourceLines)
            if lines.contains(where: { wordArithmeticImmediateLine($0, mnemonic: mnemonic, value: expectedValue, destination: "d0") }) {
                return true
            }
        }
        return false
    }

    private static func playbackPeriodExpectationMatches(
        _ expectedPeriod: String,
        model: AmigaProgramModel,
        index: AmigaSourceIndex,
        sourceLines: [String]
    ) -> Bool {
        guard model.controls.contains(where: { $0.action == "PlayMOD" }),
              let expectedValue = Int(expectedPeriod) else {
            return false
        }

        let lines = linesInRoutine("PlayMOD", inRegion: AmigaSourceRegionName.routines.rawValue, index: index, sourceLines: sourceLines)
        return lines.contains(where: { moveWordImmediateLine($0, value: expectedValue, destination: "$a6(a6)") })
    }

    private static func regexMatch(_ pattern: String, in value: String) -> [String]? {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(value.startIndex..<value.endIndex, in: value)
        guard let match = regex.firstMatch(in: value, range: range) else { return nil }
        return (0..<match.numberOfRanges).compactMap { index in
            guard let captureRange = Range(match.range(at: index), in: value) else { return nil }
            return String(value[captureRange])
        }
    }

    private static func routineListFieldFailures(
        routines: [AmigaProgramModel.Routine],
        values: (AmigaProgramModel.Routine) -> [String],
        fieldName: String
    ) -> [String] {
        var failures: [String] = []
        for (routineIndex, routine) in routines.enumerated() {
            let entries = values(routine)
            let blankIndexes = entries.enumerated().compactMap { entryIndex, value in
                value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "\(routineIndex).\(entryIndex)" : nil
            }
            if !blankIndexes.isEmpty {
                failures.append("Blank \(fieldName) at index: \(blankIndexes.joined(separator: ", ")).")
            }

            let untrimmedIndexes = entries.enumerated().compactMap { entryIndex, value in
                let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
                return !trimmed.isEmpty && value != trimmed ? "\(routineIndex).\(entryIndex)" : nil
            }
            if !untrimmedIndexes.isEmpty {
                failures.append("\(fieldName.capitalized) have leading or trailing whitespace at index: \(untrimmedIndexes.joined(separator: ", ")).")
            }

            let controlCharacterIndexes = entries.enumerated().compactMap { entryIndex, value in
                value.unicodeScalars.contains(where: { CharacterSet.controlCharacters.contains($0) }) ? "\(routineIndex).\(entryIndex)" : nil
            }
            if !controlCharacterIndexes.isEmpty {
                failures.append("\(fieldName.capitalized) contain line breaks or control characters at index: \(controlCharacterIndexes.joined(separator: ", ")).")
            }

            let duplicates = duplicateValues(entries, normalizedBy: { $0.lowercased() })
            if !duplicates.isEmpty {
                let routineLabel = routine.label.trimmingCharacters(in: .whitespacesAndNewlines)
                failures.append("Duplicate \(fieldName) in routine \(routineLabel.isEmpty ? "\(routineIndex)" : routineLabel): \(duplicates.joined(separator: ", ")).")
            }
        }
        return failures
    }

    private static func routineCallMetadataFailures(
        routine: AmigaProgramModel.Routine,
        model: AmigaProgramModel,
        inRegion regionName: String,
        index: AmigaSourceIndex,
        sourceLines: [String]
    ) -> [String] {
        var failures: [String] = []
        let knownLabels = Set(index.labels.map { $0.lowercased() })
        let modelRoutineLabels = Set(model.routines.map { $0.label.lowercased() })
        let declaredCalls = Set(routine.calls.map { $0.lowercased() })
        let actualCalls = routineCalls(
            in: linesInRoutine(routine.label, inRegion: regionName, index: index, sourceLines: sourceLines)
        )
        for declaredCall in routine.calls {
            let normalizedCall = declaredCall.lowercased()
            if !knownLabels.contains(normalizedCall) {
                failures.append("Routine \(routine.label) declares unknown call \(declaredCall).")
            } else if !actualCalls.contains(normalizedCall) {
                failures.append("Routine \(routine.label) declares call \(declaredCall) but does not call it.")
            }
        }
        let undeclaredModelCalls = actualCalls
            .filter { modelRoutineLabels.contains($0) && !declaredCalls.contains($0) }
            .sorted()
        if !undeclaredModelCalls.isEmpty {
            failures.append("Routine \(routine.label) calls model routines without declaring them: \(undeclaredModelCalls.joined(separator: ", ")).")
        }
        return failures
    }

    private static func routineClobberMetadataFailures(
        routine: AmigaProgramModel.Routine,
        inRegion regionName: String,
        index: AmigaSourceIndex,
        sourceLines: [String]
    ) -> [String] {
        guard !routine.clobbers.isEmpty else { return [] }
        let writtenRegisters = routineRegisterWrites(
            in: linesInRoutine(routine.label, inRegion: regionName, index: index, sourceLines: sourceLines)
        )
        var failures: [String] = []
        for declaredClobber in routine.clobbers {
            let registers = expandedRegisterList(declaredClobber)
            guard !registers.isEmpty else {
                failures.append("Routine \(routine.label) declares unsupported clobber \(declaredClobber).")
                continue
            }
            let missingWrites = registers.filter { !writtenRegisters.contains($0) }
            if !missingWrites.isEmpty {
                failures.append("Routine \(routine.label) declares clobber \(declaredClobber) but does not write \(missingWrites.joined(separator: ", ")).")
            }
        }
        return failures
    }

    private static func routineCalls(in lines: [String]) -> Set<String> {
        var calls: Set<String> = []
        for line in lines {
            let normalizedLine = normalizedAssemblyLine(line)
            let parts = normalizedLine
                .split { $0 == " " || $0 == "\t" }
                .map(String.init)
            guard parts.count >= 2,
                  let baseMnemonic = sizedCallMnemonic(parts[0]),
                  ["bra", "bsr", "jsr"].contains(baseMnemonic),
                  isDirectRoutineCallTarget(parts[1]) else {
                continue
            }
            calls.insert(parts[1])
        }
        return calls
    }

    private static func isDirectRoutineCallLine(_ line: String, target: String) -> Bool {
        let normalizedLine = normalizedAssemblyLine(line)
        let parts = normalizedLine
            .split { $0 == " " || $0 == "\t" }
            .map(String.init)
        guard parts.count >= 2,
              let baseMnemonic = sizedCallMnemonic(parts[0]),
              ["bra", "bsr", "jsr"].contains(baseMnemonic),
              isDirectRoutineCallTarget(parts[1]) else {
            return false
        }
        return parts[1] == target.lowercased()
    }

    private static func isDirectSubroutineCallLine(_ line: String, target: String) -> Bool {
        let normalizedLine = normalizedAssemblyLine(line)
        let parts = normalizedLine
            .split { $0 == " " || $0 == "\t" }
            .map(String.init)
        guard parts.count >= 2,
              let baseMnemonic = sizedCallMnemonic(parts[0]),
              ["bsr", "jsr"].contains(baseMnemonic),
              isDirectRoutineCallTarget(parts[1]) else {
            return false
        }
        return parts[1] == target.lowercased()
    }

    private static func isDirectBranchLine(_ line: String, mnemonic: String, target: String) -> Bool {
        let normalizedLine = normalizedAssemblyLine(line)
        let parts = normalizedLine
            .split { $0 == " " || $0 == "\t" }
            .map(String.init)
        guard parts.count >= 2,
              let baseMnemonic = sizedBranchMnemonic(parts[0]),
              baseMnemonic == mnemonic.lowercased(),
              isDirectRoutineCallTarget(parts[1]) else {
            return false
        }
        return parts[1] == target.lowercased()
    }

    private static func isPCRelativeLEALine(_ line: String, symbol: String, register: String) -> Bool {
        let normalizedLine = normalizedAssemblyLine(line)
        let parts = normalizedLine
            .split(separator: " ", maxSplits: 1)
            .map(String.init)
        guard parts.count == 2,
              parts[0] == "lea" else {
            return false
        }
        return parts[1] == "\(symbol.lowercased())(pc),\(register.lowercased())"
    }

    private static func containsOrderedDirectSubroutineCalls(_ targets: [String], in lines: [String]) -> Bool {
        var nextTargetIndex = targets.startIndex
        for line in lines {
            guard nextTargetIndex < targets.endIndex else { break }
            if isDirectSubroutineCallLine(line, target: targets[nextTargetIndex]) {
                nextTargetIndex = targets.index(after: nextTargetIndex)
            }
        }
        return nextTargetIndex == targets.endIndex
    }

    private static func sizedCallMnemonic(_ mnemonic: String) -> String? {
        let parts = mnemonic.split(separator: ".", maxSplits: 1).map(String.init)
        guard let base = parts.first, ["bra", "bsr", "jsr"].contains(base) else {
            return nil
        }
        if parts.count == 1 {
            return base
        }
        guard let size = parts.last, ["s", "w", "l"].contains(size) else {
            return nil
        }
        return base
    }

    private static func sizedBranchMnemonic(_ mnemonic: String) -> String? {
        let branchMnemonics = Set(["bra", "beq", "bne", "blt", "bge"])
        let parts = mnemonic.split(separator: ".", maxSplits: 1).map(String.init)
        guard let base = parts.first, branchMnemonics.contains(base) else {
            return nil
        }
        if parts.count == 1 {
            return base
        }
        guard let size = parts.last, ["s", "w"].contains(size) else {
            return nil
        }
        return base
    }

    private static func isDirectRoutineCallTarget(_ target: String) -> Bool {
        regexMatch(#"^[a-z_.$][a-z0-9_.$]*$"#, in: target) != nil
    }

    private static func routineRegisterWrites(in lines: [String]) -> Set<String> {
        var writes: Set<String> = []
        for line in lines {
            let normalizedLine = normalizedAssemblyLine(line)
            let parts = normalizedLine
                .split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
                .map(String.init)
            guard parts.count == 2 else { continue }
            let mnemonic = parts[0]
            let operands = parts[1]
                .split(separator: ",", omittingEmptySubsequences: true)
                .map { $0.trimmingCharacters(in: .whitespaces) }
            switch mnemonic {
            case "lea", "move", "move.b", "move.w", "move.l", "movea", "movea.w", "movea.l", "moveq", "moveq.l",
                "add", "add.b", "add.w", "add.l", "adda", "adda.w", "adda.l",
                "addi", "addi.b", "addi.w", "addi.l", "addq", "addq.b", "addq.w", "addq.l",
                "sub", "sub.b", "sub.w", "sub.l", "suba", "suba.w", "suba.l",
                "subi", "subi.b", "subi.w", "subi.l", "subq", "subq.b", "subq.w", "subq.l",
                "and", "and.b", "and.w", "and.l", "or", "or.b", "or.w", "or.l",
                "eor", "eor.b", "eor.w", "eor.l", "ori", "ori.b", "ori.w", "ori.l",
                "lsl", "lsl.b", "lsl.w", "lsl.l", "lsr", "lsr.b", "lsr.w", "lsr.l",
                "mulu", "mulu.w", "muls", "muls.w":
                if let destination = operands.last, let register = singleRegister(destination) {
                    writes.insert(register)
                }
            case "movem", "movem.w", "movem.l":
                guard let destination = operands.last else { continue }
                for register in expandedRegisterList(destination) {
                    writes.insert(register)
                }
            case "clr", "clr.b", "clr.w", "clr.l", "neg", "neg.b", "neg.w", "neg.l",
                "not", "not.b", "not.w", "not.l":
                if let destination = operands.last, let register = singleRegister(destination) {
                    writes.insert(register)
                }
            default:
                continue
            }
        }
        return writes
    }

    private static func expandedRegisterList(_ declaration: String) -> [String] {
        declaration
            .lowercased()
            .split(separator: "/")
            .flatMap { component -> [String] in
                let part = String(component)
                if part.contains("-") {
                    return expandedRegisterRange(part)
                }
                return singleRegister(part).map { [$0] } ?? []
            }
    }

    private static func expandedRegisterRange(_ declaration: String) -> [String] {
        let bounds = declaration.split(separator: "-").map(String.init)
        guard bounds.count == 2,
              let first = singleRegister(bounds[0]),
              let last = singleRegister(bounds[1]),
              first.first == last.first,
              let firstIndex = Int(first.dropFirst()),
              let lastIndex = Int(last.dropFirst()),
              (0...7).contains(firstIndex),
              (0...7).contains(lastIndex),
              firstIndex <= lastIndex else {
            return []
        }
        let prefix = String(first.prefix(1))
        return (firstIndex...lastIndex).map { "\(prefix)\($0)" }
    }

    private static func singleRegister(_ operand: String) -> String? {
        let trimmed = operand.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard trimmed.count == 2,
              let prefix = trimmed.first,
              prefix == "d" || prefix == "a",
              let value = Int(trimmed.dropFirst()),
              (0...7).contains(value) else {
            return nil
        }
        return trimmed
    }

    private static func duplicateValues(_ values: [String], normalizedBy normalize: (String) -> String = { $0 }) -> [String] {
        var counts: [String: Int] = [:]
        var firstValueByKey: [String: String] = [:]
        for value in values {
            let key = normalize(value)
            counts[key, default: 0] += 1
            firstValueByKey[key] = firstValueByKey[key] ?? value
        }
        return counts
            .filter { $0.value > 1 }
            .map(\.key)
            .sorted()
            .compactMap { firstValueByKey[$0] }
    }

    private static func firstReturnLine(inRegion name: String, index: AmigaSourceIndex, sourceLines: [String]) -> Int? {
        guard let region = index.regions[name], let endLine = region.endLine else { return nil }
        let startIndex = max(region.startLine - 1, 0)
        let endIndex = min(endLine - 1, sourceLines.count)
        guard startIndex < endIndex else { return nil }
        return sourceLines[startIndex..<endIndex].firstIndex { line in
            isReturnInstructionLine(line)
        }.map { $0 + 1 }
    }

    private static func firstReturnLine(afterLabel label: String, inRegion name: String, index: AmigaSourceIndex, sourceLines: [String]) -> Int? {
        guard let region = index.regions[name],
              let endLine = region.endLine,
              let labelIndex = labelLineIndex(label, inRegion: name, index: index, sourceLines: sourceLines) else { return nil }
        let regionEndIndex = min(endLine - 1, sourceLines.count)
        guard labelIndex + 1 < regionEndIndex else { return nil }
        return sourceLines[(labelIndex + 1)..<regionEndIndex].firstIndex { line in
            isReturnInstructionLine(line)
        }.map { $0 + 1 }
    }

    private static func linesBeforeReturn(inRegion name: String, index: AmigaSourceIndex, sourceLines: [String]) -> [String] {
        guard let region = index.regions[name], let endLine = region.endLine else { return [] }
        let startIndex = max(region.startLine - 1, 0)
        let regionEndIndex = min(endLine - 1, sourceLines.count)
        guard startIndex < regionEndIndex else { return [] }
        let returnIndex = sourceLines[startIndex..<regionEndIndex].firstIndex {
            isReturnInstructionLine($0)
        } ?? regionEndIndex
        guard startIndex < returnIndex else { return [] }
        return Array(sourceLines[startIndex..<returnIndex])
    }

    private static func linesInRoutine(_ label: String, inRegion name: String, index: AmigaSourceIndex, sourceLines: [String]) -> [String] {
        guard let region = index.regions[name],
              let endLine = region.endLine,
              let labelIndex = labelLineIndex(label, inRegion: name, index: index, sourceLines: sourceLines) else {
            return []
        }
        let regionEndIndex = min(endLine - 1, sourceLines.count)
        guard labelIndex + 1 < regionEndIndex else { return [] }

        let bodyStart = labelIndex + 1
        let bodyEnd = sourceLines[bodyStart..<regionEndIndex].firstIndex { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            return trimmed.hasSuffix(":") && !trimmed.hasPrefix(".")
        } ?? regionEndIndex
        return Array(sourceLines[bodyStart..<bodyEnd])
    }

    private static func entryStartupLines(sourceLines: [String]) -> [String] {
        guard let startIndex = sourceLines.firstIndex(where: {
            AmigaSourceIndexer.labelName(from: $0) == "_Start"
        }),
              let mainLoopIndex = sourceLines[(startIndex + 1)...].firstIndex(where: {
                  AmigaSourceIndexer.labelName(from: $0) == ".mainLoop"
              }),
              startIndex + 1 < mainLoopIndex else {
            return []
        }
        return Array(sourceLines[(startIndex + 1)..<mainLoopIndex])
    }

    private static func entryLoopLines(index: AmigaSourceIndex, sourceLines: [String]) -> [String] {
        guard let mainLoopIndex = sourceLines.firstIndex(where: {
            AmigaSourceIndexer.labelName(from: $0) == ".mainLoop"
        }) else {
            return []
        }
        let firstRegionStartIndex = index.regions.values
            .map { max($0.startLine - 1, 0) }
            .filter { $0 > mainLoopIndex }
            .min() ?? sourceLines.count
        let endIndex = min(firstRegionStartIndex, sourceLines.count)
        guard mainLoopIndex + 1 < endIndex else { return [] }
        return Array(sourceLines[(mainLoopIndex + 1)..<endIndex])
    }

    private static func linesAfterLabel(_ label: String, untilFirstRegionUsing index: AmigaSourceIndex, sourceLines: [String]) -> [String] {
        guard let labelIndex = sourceLines.firstIndex(where: {
            AmigaSourceIndexer.labelName(from: $0) == label
        }) else {
            return []
        }
        let firstRegionStartIndex = index.regions.values
            .map { max($0.startLine - 1, 0) }
            .filter { $0 > labelIndex }
            .min() ?? sourceLines.count
        let nextTopLevelLabelIndex = sourceLines[(labelIndex + 1)..<firstRegionStartIndex].firstIndex { line in
            guard let label = AmigaSourceIndexer.labelName(from: line) else {
                return false
            }
            return !label.hasPrefix(".")
        } ?? firstRegionStartIndex
        let endIndex = min(nextTopLevelLabelIndex, sourceLines.count)
        guard labelIndex + 1 < endIndex else { return [] }
        return Array(sourceLines[(labelIndex + 1)..<endIndex])
    }

    private static func containsOrderedLineEvidence(_ expected: [(String) -> Bool], in lines: [String]) -> Bool {
        guard !expected.isEmpty else { return true }
        var nextExpectedIndex = expected.startIndex
        for line in lines {
            if expected[nextExpectedIndex](line) {
                nextExpectedIndex = expected.index(after: nextExpectedIndex)
                if nextExpectedIndex == expected.endIndex {
                    return true
                }
            }
        }
        return false
    }

    private static func executableInstructionMnemonic(in normalizedLine: String) -> String? {
        let parts = normalizedLine
            .split(separator: " ")
            .map(String.init)
        guard !parts.isEmpty else { return nil }
        let mnemonicIndex = parts[0].hasSuffix(":") ? 1 : 0
        guard parts.indices.contains(mnemonicIndex) else { return nil }
        let mnemonic = parts[mnemonicIndex]
        let directiveBases: Set<String> = [
            "section", "dc", "ds", "dcb", "blk", "even", "cnop", "align",
            "include", "incbin", "xdef", "xref", "end", "org", "equ", "set"
        ]
        let base = mnemonic.split(separator: ".", maxSplits: 1).first.map(String.init) ?? mnemonic
        return directiveBases.contains(base) ? nil : mnemonic
    }

    private static func normalizedExecutableInstruction(_ normalizedLine: String) -> (mnemonic: String, operands: [String])? {
        let parts = normalizedLine
            .split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
            .map(String.init)
        guard let mnemonic = executableInstructionMnemonic(in: normalizedLine) else {
            return nil
        }
        let operands = parts.dropFirst().first?
            .split(separator: ",", omittingEmptySubsequences: true)
            .map { $0.trimmingCharacters(in: .whitespaces) } ?? []
        return (mnemonic, operands)
    }

    private static func dispatchBlockHasGuardedAction(control: AmigaProgramModel.Control, slot: Int, after markerIndex: Int, sourceLines: [String]) -> Bool {
        var foundCompare = false
        var foundGuard = false
        var foundAction = false
        for line in sourceLines[(markerIndex + 1)...].prefix(6) {
            let normalizedLine = normalizedAssemblyLine(line)
            if !foundCompare {
                foundCompare = cmpWordD0Line(line, value: slot)
                continue
            }
            if !foundGuard {
                foundGuard = isDirectBranchLine(line, mnemonic: "bne", target: ".skip_\(control.id)")
                continue
            }
            if !foundAction {
                foundAction = isDirectRoutineCallLine(line, target: control.action)
                continue
            }
            if normalizedLine == ".skip_\(control.id):" {
                return true
            }
        }
        return false
    }

    private static func lines(inRegion name: String, index: AmigaSourceIndex, sourceLines: [String]) -> [String] {
        guard let region = index.regions[name], let endLine = region.endLine else { return [] }
        let startIndex = max(region.startLine - 1, 0)
        let regionEndIndex = min(endLine - 1, sourceLines.count)
        guard startIndex < regionEndIndex else { return [] }
        return Array(sourceLines[startIndex..<regionEndIndex])
    }

    private static func containsLabel(_ label: String, in lines: [String]) -> Bool {
        lines.contains { line in
            AmigaSourceIndexer.labelName(from: line) == label
        }
    }

    private static func containsLabel(_ label: String, inRegion name: String, index: AmigaSourceIndex, sourceLines: [String]) -> Bool {
        labelLineIndex(label, inRegion: name, index: index, sourceLines: sourceLines) != nil
    }

    private static func expectedRegionName(for routine: AmigaProgramModel.Routine, model: AmigaProgramModel) -> AmigaSourceRegionName? {
        if model.controls.contains(where: { $0.action == routine.label }) {
            return .routines
        }

        switch routine.label {
        case "DrawControls", "DrawControlRect", "DrawControlLabel":
            return .drawControls
        case "WaitVBlank", "ReadMouseControls", "HitTestControls":
            return .hitTest
        case "InputDispatch":
            return .inputDispatch
        default:
            return nil
        }
    }

    private static func regionName(containingLabel label: String, index: AmigaSourceIndex, sourceLines: [String]) -> String? {
        for region in AmigaSourceRegionName.allCases {
            if labelLineIndex(label, inRegion: region.rawValue, index: index, sourceLines: sourceLines) != nil {
                return region.rawValue
            }
        }
        return nil
    }

    private static func normalizedAssemblyLine(_ line: String) -> String {
        let code = assemblyCodePrefix(beforeCommentIn: line)
        return code
            .trimmingCharacters(in: .whitespaces)
            .split { $0 == " " || $0 == "\t" }
            .joined(separator: " ")
            .replacingOccurrences(of: " ,", with: ",")
            .replacingOccurrences(of: ", ", with: ",")
            .lowercased()
    }

    private static func controlMarkerText(for control: AmigaProgramModel.Control) -> String {
        let markerLabel = amigaMarkerAttributeText(for: control.label)
        var marker = #"@amiga:model control id=\#(control.id) label="\#(markerLabel)" action=\#(control.action)"#
        if let bounds = control.bounds {
            marker += " bounds=\(bounds.x),\(bounds.y),\(bounds.width),\(bounds.height)"
        }
        return marker
    }

    private static func drawMarkerText(for control: AmigaProgramModel.Control, slot: Int) -> String {
        guard let bounds = control.bounds else {
            return "@amiga:draw_control \(control.id) slot=\(slot)"
        }
        return "@amiga:draw_control \(control.id) slot=\(slot) bounds=\(bounds.x),\(bounds.y),\(bounds.width),\(bounds.height)"
    }

    private static func hitTestMarkerText(for control: AmigaProgramModel.Control, slot: Int) -> String {
        guard let bounds = control.bounds else {
            return "@amiga:hittest \(control.id) slot=\(slot)"
        }
        return "@amiga:hittest \(control.id) slot=\(slot) bounds=\(bounds.x),\(bounds.y),\(bounds.width),\(bounds.height)"
    }

    private static func hitTestBoundsMatch(bounds: AmigaProgramModel.Bounds, after markerIndex: Int, sourceLines: [String]) -> Bool {
        let expected = [
            bounds.x,
            bounds.x + bounds.width,
            bounds.y,
            bounds.y + bounds.height
        ]
        let compares = sourceLines[(markerIndex + 1)...]
            .prefix(12)
            .compactMap(cmpWordD0ImmediateValue)
        guard compares.count >= expected.count else { return false }
        return Array(compares.prefix(expected.count)) == expected
    }

    private static func hitTestBlockHasGuardedActivation(control: AmigaProgramModel.Control, slot: Int, bounds: AmigaProgramModel.Bounds, after markerIndex: Int, sourceLines: [String]) -> Bool {
        let expected: [(String) -> Bool] = [
            { moveWordSymbolLine($0, source: "MouseX(pc)", destination: "d0") },
            { cmpWordD0Line($0, value: bounds.x) },
            { isDirectBranchLine($0, mnemonic: "blt", target: ".miss_\(control.id)") },
            { cmpWordD0Line($0, value: bounds.x + bounds.width) },
            { isDirectBranchLine($0, mnemonic: "bge", target: ".miss_\(control.id)") },
            { moveWordSymbolLine($0, source: "MouseY(pc)", destination: "d0") },
            { cmpWordD0Line($0, value: bounds.y) },
            { isDirectBranchLine($0, mnemonic: "blt", target: ".miss_\(control.id)") },
            { cmpWordD0Line($0, value: bounds.y + bounds.height) },
            { isDirectBranchLine($0, mnemonic: "bge", target: ".miss_\(control.id)") },
            { moveWordImmediateLine($0, value: slot, destination: "SelectedControl") },
            { moveWordImmediateLine($0, value: slot, destination: "ActivatedControl") },
            { isDirectBranchLine($0, mnemonic: "bra", target: ".doneHitTest") },
            { normalizedAssemblyLine($0) == ".miss_\(control.id):" }
        ]
        let blockLines = Array(sourceLines[(markerIndex + 1)...].prefix(16))
        return containsOrderedLineEvidence(expected, in: blockLines)
    }

    private static func cmpWordD0Line(_ line: String, value: Int) -> Bool {
        cmpWordD0ImmediateValue(line) == value
    }

    private static func cmpWordRegisterLine(_ line: String, value: Int, register: String) -> Bool {
        let operands = normalizedInstructionOperands(line, mnemonic: "cmp.w")
        guard operands.count == 2,
              operands[1] == register.lowercased() else {
            return false
        }
        return immediateWordValue(operands[0]) == value
    }

    private static func cmpWordD0ImmediateValue(_ line: String) -> Int? {
        let operands = normalizedInstructionOperands(line, mnemonic: "cmp.w")
        guard operands.count == 2,
              operands[1] == "d0" else {
            return nil
        }
        return immediateWordValue(operands[0])
    }

    private static func moveWordImmediateLine(_ line: String, value: Int, destination: String) -> Bool {
        let operands = normalizedInstructionOperands(line, mnemonic: "move.w")
        guard operands.count == 2,
              operands[1] == destination.lowercased() else {
            return false
        }
        return immediateWordValue(operands[0]) == value
    }

    private static func moveWordRegisterLine(_ line: String, source: String, destination: String) -> Bool {
        let operands = normalizedInstructionOperands(line, mnemonic: "move.w")
        return operands.count == 2 &&
            operands[0] == source.lowercased() &&
            operands[1] == destination.lowercased()
    }

    private static func moveWordSymbolLine(_ line: String, source: String, destination: String) -> Bool {
        let operands = normalizedInstructionOperands(line, mnemonic: "move.w")
        return operands.count == 2 &&
            operands[0] == source.lowercased() &&
            operands[1] == destination.lowercased()
    }

    private static func subWordSymbolLine(_ line: String, source: String, destination: String) -> Bool {
        let operands = normalizedInstructionOperands(line, mnemonic: "sub.w")
        return operands.count == 2 &&
            operands[0] == source.lowercased() &&
            operands[1] == destination.lowercased()
    }

    private static func wordArithmeticImmediateLine(_ line: String, mnemonic: String, value: Int, destination: String) -> Bool {
        let operands = normalizedInstructionOperands(line, mnemonic: mnemonic)
        guard operands.count == 2,
              operands[1] == destination.lowercased() else {
            return false
        }
        return immediateWordValue(operands[0]) == value
    }

    private static func moveByteImmediateLine(_ line: String, value: Int, destination: String) -> Bool {
        let operands = normalizedInstructionOperands(line, mnemonic: "move.b")
        guard operands.count == 2,
              operands[1] == destination.lowercased() else {
            return false
        }
        return immediateWordValue(operands[0]) == value
    }

    private static func clearWordLine(_ line: String, destination: String) -> Bool {
        let operands = normalizedInstructionOperands(line, mnemonic: "clr.w")
        return operands.count == 1 && operands[0] == destination.lowercased()
    }

    private static func btstImmediateLine(_ line: String, bit: Int, destinationValue: Int) -> Bool {
        let operands = normalizedInstructionOperands(line, mnemonic: "btst")
        guard operands.count == 2,
              immediateWordValue(operands[0]) == bit else {
            return false
        }
        return absoluteAddressOperand(operands[1], value: destinationValue)
    }

    private static func normalizedInstructionOperands(_ line: String, mnemonic: String) -> [String] {
        let normalizedLine = normalizedAssemblyLine(line)
        let parts = normalizedLine
            .split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
            .map(String.init)
        guard parts.count == 2,
              parts[0] == mnemonic else {
            return []
        }
        return parts[1]
            .split(separator: ",", omittingEmptySubsequences: true)
            .map { $0.trimmingCharacters(in: .whitespaces) }
    }

    private static func immediateWordValue(_ operand: String) -> Int? {
        guard operand.hasPrefix("#") else {
            return nil
        }
        return controlRectWordValue(String(operand.dropFirst()))
    }

    private static func absoluteAddressOperand(_ operand: String, value: Int) -> Bool {
        controlRectWordValue(operand) == value
    }

    private static func routineHasExecutableBody(_ label: String, inRegion name: String, index: AmigaSourceIndex, sourceLines: [String]) -> Bool {
        guard let region = index.regions[name],
              let endLine = region.endLine,
              let labelIndex = labelLineIndex(label, inRegion: name, index: index, sourceLines: sourceLines) else {
            return false
        }
        let regionEndIndex = min(endLine - 1, sourceLines.count)
        guard labelIndex + 1 < regionEndIndex else { return false }

        for line in sourceLines[(labelIndex + 1)..<regionEndIndex] {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty || trimmed.hasPrefix(";") {
                continue
            }
            if AmigaSourceIndexer.labelName(from: line) != nil {
                return false
            }
            if isReturnInstructionLine(line) {
                continue
            }
            if executableInstructionMnemonic(in: normalizedAssemblyLine(line)) != nil {
                return true
            }
        }
        return false
    }

    private static func isReturnInstructionLine(_ line: String) -> Bool {
        normalizedAssemblyLine(line) == "rts"
    }

    private static func stateWordValue(for label: String, in lines: [String]) -> String? {
        guard let labelIndex = lines.firstIndex(where: { AmigaSourceIndexer.labelName(from: $0) == label }) else {
            return nil
        }
        if let value = stateWordValue(label: label, line: lines[labelIndex]) {
            return value
        }
        return lines[(labelIndex + 1)...]
            .prefix(3)
            .compactMap { stateWordValue(label: nil, line: $0) }
            .first
    }

    private static func stateWordValue(label: String?, line: String) -> String? {
        let code = assemblyCodePrefix(beforeCommentIn: line)
        var trimmed = code.trimmingCharacters(in: .whitespaces)
        if let label {
            guard AmigaSourceIndexer.labelName(from: line) == label,
                  let colonIndex = trimmed.firstIndex(of: ":") else {
                return nil
            }
            trimmed = String(trimmed[trimmed.index(after: colonIndex)...])
                .trimmingCharacters(in: .whitespaces)
        }
        guard let mnemonicEnd = trimmed.firstIndex(where: { $0 == " " || $0 == "\t" }) else {
            return nil
        }
        let mnemonic = String(trimmed[..<mnemonicEnd]).lowercased()
        guard mnemonic == "dc.w" else { return nil }
        let operands = trimmed[mnemonicEnd...]
            .trimmingCharacters(in: .whitespaces)
            .split(separator: ",", omittingEmptySubsequences: false)
        guard operands.count == 1, let value = operands.first else {
            return nil
        }
        let operand = String(value.trimmingCharacters(in: .whitespaces))
        return operand.isEmpty ? nil : operand
    }

    private static func stateWordValuesMatch(_ sourceValue: String, _ modelValue: String) -> Bool {
        if let sourceWord = controlRectWordValue(sourceValue),
           let modelWord = controlRectWordValue(modelValue) {
            return sourceWord == modelWord
        }
        return sourceValue == modelValue
    }

    private static func labelLineIndex(_ label: String, inRegion name: String, index: AmigaSourceIndex, sourceLines: [String]) -> Int? {
        guard let region = index.regions[name], let endLine = region.endLine else { return nil }
        let startIndex = max(region.startLine - 1, 0)
        let regionEndIndex = min(endLine - 1, sourceLines.count)
        guard startIndex < regionEndIndex else { return nil }
        return sourceLines[startIndex..<regionEndIndex].firstIndex { line in
            AmigaSourceIndexer.labelName(from: line) == label
        }
    }

    private static func labelDataMatches(_ label: String, after labelLineIndex: Int, sourceLines: [String]) -> Bool {
        return sourceLines[(labelLineIndex + 1)...]
            .prefix(3)
            .contains { labelDataLineMatches(label, line: $0) }
    }

    private static func labelDataLineMatches(_ label: String, line: String) -> Bool {
        let code = assemblyCodePrefix(beforeCommentIn: line)
        let trimmed = code.trimmingCharacters(in: .whitespaces)
        guard let mnemonicEnd = trimmed.firstIndex(where: { $0 == " " || $0 == "\t" }) else {
            return false
        }
        let mnemonic = String(trimmed[..<mnemonicEnd]).lowercased()
        guard mnemonic == "dc.b" else { return false }

        let operands = trimmed[mnemonicEnd...].trimmingCharacters(in: .whitespaces)
        let expectedDoubleQuotedLabel = NSRegularExpression.escapedPattern(for: assemblyStringLiteralText(for: label))
        var quotedLabelPatterns = [#""\#(expectedDoubleQuotedLabel)""#]
        if !label.contains("'") {
            quotedLabelPatterns.append(#"'\#(NSRegularExpression.escapedPattern(for: label))'"#)
        }
        guard let regex = try? NSRegularExpression(pattern: #"^(?:\#(quotedLabelPatterns.joined(separator: "|")))\s*,\s*0\s*$"#) else {
            return false
        }
        let range = NSRange(operands.startIndex..<operands.endIndex, in: operands)
        return regex.firstMatch(in: operands, range: range) != nil
    }

    private static func controlRectDataMatches(bounds: AmigaProgramModel.Bounds, slot: Int, after labelLineIndex: Int, sourceLines: [String]) -> Bool {
        let expected = [bounds.x, bounds.y, bounds.width, bounds.height, slot]
        guard let wordLine = sourceLines[(labelLineIndex + 1)...]
            .prefix(3)
            .first(where: { assemblyCodePrefix(beforeCommentIn: $0).trimmingCharacters(in: .whitespaces).lowercased().hasPrefix("dc.w") }) else {
            return false
        }
        let trimmed = assemblyCodePrefix(beforeCommentIn: wordLine).trimmingCharacters(in: .whitespaces)
        let operands = trimmed
            .dropFirst("dc.w".count)
            .split(separator: ",", omittingEmptySubsequences: false)
            .map { $0.trimmingCharacters(in: .whitespaces) }
        let values = operands.compactMap(controlRectWordValue)
        guard values.count == operands.count else {
            return false
        }
        return values == expected
    }

    private static func controlRectWordValue(_ operand: String) -> Int? {
        let normalized = operand.trimmingCharacters(in: .whitespaces).lowercased()
        if normalized.hasPrefix("$") {
            return Int(normalized.dropFirst(), radix: 16)
        }
        if normalized.hasPrefix("0x") {
            return Int(normalized.dropFirst(2), radix: 16)
        }
        return Int(normalized)
    }

    private static func assemblyStringLiteralText(for label: String) -> String {
        label.replacingOccurrences(of: #"""#, with: #""""#)
    }

    private static func firstLineIndex(containing pattern: String, inRegion name: String, index: AmigaSourceIndex, sourceLines: [String]) -> Int? {
        guard let region = index.regions[name], let endLine = region.endLine else { return nil }
        let startIndex = max(region.startLine - 1, 0)
        let regionEndIndex = min(endLine - 1, sourceLines.count)
        guard startIndex < regionEndIndex else { return nil }
        return sourceLines[startIndex..<regionEndIndex].firstIndex { line in
            markerCommentText(in: line)?.contains(pattern) == true
        }
    }

    private static func markerCommentText(in line: String) -> String? {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard trimmed.hasPrefix("; @amiga:") else { return nil }
        return trimmed
    }
}

enum AmigaProgramFollowUpPlanner {
    struct BitplaneColorRequest: Equatable {
        let role: String
        let color: String
    }

    enum BitplaneColorIntent: Equatable {
        case request(role: String, color: String)
        case requests([BitplaneColorRequest])
        case missingColor(role: String)
        case conflictingRoles([String])
        case unsupported(role: String, supportedColors: [String])
        case notRecognized
    }

    enum DoubleBufferedBitplaneFollowUpIntent: Equatable {
        case spriteDownward
        case vblankWaits(Int)
        case copperAccentColor(String)
        case rejected([String])
        case notRecognized
    }

    enum BlitterBOBFollowUpIntent: Equatable {
        case horizontalSpeed(Int)
        case targetRectangle(left: Int, right: Int)
        case collisionColor(String)
        case directionControl
        case rejected([String])
        case notRecognized
    }

    enum MouseSpriteMultiplexFollowUpIntent: Equatable {
        case followerOffset(Int)
        case horizontalWrapping(Bool)
        case followerLag(Bool)
        case spriteColor(String)
        case rejected([String])
        case notRecognized
    }

    enum CopperRasterFollowUpIntent: Equatable {
        case barCount(Int)
        case bounceStep(Int)
        case blueWhitePalette
        case topStatusBand
        case rejected([String])
        case notRecognized
    }

    static func modPlayerControlsMatch(for prompt: String) -> AssistantPromptTemplateMatch? {
        let normalized = prompt.lowercased()
        guard hasMODModuleSignal(in: normalized),
              containsWord("play", in: normalized) || containsPhrase("start playback", in: normalized),
              containsWord("stop", in: normalized) || containsPhrase("stop playback", in: normalized),
              containsWord("button", in: normalized) || containsWord("buttons", in: normalized) || containsWord("control", in: normalized) || containsWord("controls", in: normalized) else {
            return nil
        }

        guard let source = try? AmigaProgramTemplate.verifiedModPlayerControlsSource() else { return nil }
        return AssistantPromptTemplateMatch(
            id: "mod-player-controls",
            name: "Model-backed MOD controls",
            source: source,
            parameters: [
                "mode": "source-aware program",
                "controls": "Play, Stop"
            ]
        )
    }

    private static func hasMODModuleSignal(in normalized: String) -> Bool {
        containsWord("mod", in: normalized) ||
            containsPhrase("module file", in: normalized) ||
            containsPhrase("music module", in: normalized) ||
            containsPhrase("tracker module", in: normalized)
    }

    static func patch(prompt: String, source: String) -> AmigaProgramPatchResult? {
        guard case .patched(let result) = patchOutcome(prompt: prompt, source: source) else {
            return nil
        }
        return result
    }

    static func patchOutcome(prompt: String, source: String) -> AmigaProgramFollowUpPatchOutcome {
        let index = AmigaSourceIndexer.index(source)
        guard let model = index.model else { return .notRecognized }
        do {
            if model.id == AmigaProgramTemplate.blitterBOBCollisionBoundsID {
                switch blitterBOBFollowUpIntent(from: prompt) {
                case .horizontalSpeed(let speed):
                    try verifyCurrentSourceBeforePatching(source)
                    return .patched(try verified(AmigaProgramPatcher.updateBlitterBOBHorizontalSpeed(speed, in: source)))
                case .targetRectangle(let left, let right):
                    try verifyCurrentSourceBeforePatching(source)
                    return .patched(try verified(AmigaProgramPatcher.updateBlitterBOBTargetRectangle(left: left, right: right, in: source)))
                case .collisionColor(let color):
                    try verifyCurrentSourceBeforePatching(source)
                    return .patched(try verified(AmigaProgramPatcher.updateBlitterBOBCollisionColor(color, in: source)))
                case .directionControl:
                    try verifyCurrentSourceBeforePatching(source)
                    return .patched(try verified(AmigaProgramPatcher.addBlitterBOBDirectionControl(in: source)))
                case .rejected(let reasons):
                    try verifyCurrentSourceBeforePatching(source)
                    return .rejected(reasons)
                case .notRecognized:
                    return .notRecognized
                }
            }
            if model.id == "mouse-sprite-multiplex" {
                switch mouseSpriteMultiplexFollowUpIntent(from: prompt) {
                case .followerOffset(let offset):
                    try verifyCurrentSourceBeforePatching(source)
                    return .patched(try verified(AmigaProgramPatcher.updateMouseSpriteFollowerOffset(offset, in: source)))
                case .horizontalWrapping(let enabled):
                    try verifyCurrentSourceBeforePatching(source)
                    return .patched(try verified(AmigaProgramPatcher.updateMouseSpriteHorizontalWrapping(enabled: enabled, in: source)))
                case .followerLag(let enabled):
                    try verifyCurrentSourceBeforePatching(source)
                    return .patched(try verified(AmigaProgramPatcher.updateMouseSpriteFollowerLag(enabled: enabled, in: source)))
                case .spriteColor(let color):
                    try verifyCurrentSourceBeforePatching(source)
                    return .patched(try verified(AmigaProgramPatcher.updateMouseSpriteColor(color, in: source)))
                case .rejected(let reasons):
                    try verifyCurrentSourceBeforePatching(source)
                    return .rejected(reasons)
                case .notRecognized:
                    return .notRecognized
                }
            }
            if model.id == "bouncing-copper-bars" {
                switch copperRasterFollowUpIntent(from: prompt) {
                case .barCount(let count):
                    try verifyCurrentSourceBeforePatching(source)
                    return .patched(try verified(AmigaProgramPatcher.updateCopperRasterBarCount(count, in: source)))
                case .bounceStep(let step):
                    try verifyCurrentSourceBeforePatching(source)
                    return .patched(try verified(AmigaProgramPatcher.updateCopperRasterBounceStep(step, in: source)))
                case .blueWhitePalette:
                    try verifyCurrentSourceBeforePatching(source)
                    return .patched(try verified(AmigaProgramPatcher.updateCopperRasterBlueWhitePalette(in: source)))
                case .topStatusBand:
                    try verifyCurrentSourceBeforePatching(source)
                    return .patched(try verified(AmigaProgramPatcher.updateCopperRasterTopStatusBand(in: source)))
                case .rejected(let reasons):
                    try verifyCurrentSourceBeforePatching(source)
                    return .rejected(reasons)
                case .notRecognized:
                    return .notRecognized
                }
            }
            if model.id == AmigaProgramFamilyRegistry.doubleBufferedBitplane.id {
                switch bitplaneColorIntent(from: prompt) {
                case .request(let role, let color):
                    try verifyCurrentSourceBeforePatching(source)
                    return .patched(try verified(AmigaProgramPatcher.updateBitplaneColor(role: role, color: color, in: source)))
                case .requests(let requests):
                    try verifyCurrentSourceBeforePatching(source)
                    var patchedSource = source
                    var changedRegions: [String] = []
                    var finalResult: AmigaProgramPatchResult?
                    for request in requests {
                        let result = try verified(AmigaProgramPatcher.updateBitplaneColor(role: request.role, color: request.color, in: patchedSource))
                        patchedSource = result.source
                        changedRegions = mergedChangedRegions(changedRegions, result.changedRegions)
                        finalResult = result
                    }
                    guard let finalResult else { return .notRecognized }
                    if patchedSource == source {
                        return .patched(AmigaProgramPatchResult(
                            source: source,
                            model: finalResult.model,
                            changedRegions: []
                        ))
                    }
                    return .patched(AmigaProgramPatchResult(
                        source: patchedSource,
                        model: finalResult.model,
                        changedRegions: changedRegions
                    ))
                case .missingColor(let role):
                    try verifyCurrentSourceBeforePatching(source)
                    return .rejected(["Specify a supported \(role) buffer color."])
                case .conflictingRoles(let roles):
                    try verifyCurrentSourceBeforePatching(source)
                    return .rejected([
                        "Conflicting bitplane color roles in one request: \(roles.joined(separator: ", ")). Specify exactly one of: front, back."
                    ])
                case .unsupported(let role, let supportedColors):
                    try verifyCurrentSourceBeforePatching(source)
                    return .rejected([
                        "Unsupported \(role) buffer color. Supported colors: \(supportedColors.joined(separator: ", "))."
                    ])
                case .notRecognized:
                    switch doubleBufferedBitplaneFollowUpIntent(from: prompt) {
                    case .spriteDownward:
                        try verifyCurrentSourceBeforePatching(source)
                        return .patched(try verified(AmigaProgramPatcher.moveDoubleBufferedSpriteDownward(in: source)))
                    case .vblankWaits(let count):
                        try verifyCurrentSourceBeforePatching(source)
                        return .patched(try verified(AmigaProgramPatcher.updateDoubleBufferedVBlankWaits(count, in: source)))
                    case .copperAccentColor(let color):
                        try verifyCurrentSourceBeforePatching(source)
                        return .patched(try verified(AmigaProgramPatcher.updateDoubleBufferedCopperAccentColor(color, in: source)))
                    case .rejected(let reasons):
                        try verifyCurrentSourceBeforePatching(source)
                        return .rejected(reasons)
                    case .notRecognized:
                        return .notRecognized
                    }
                }
            }
            if model.id == AmigaProgramTemplate.cleanTakeoverRestoreID {
                let normalized = prompt.lowercased()
                if normalized.contains("disable interrupts") && normalized.contains("without restoring") {
                    try verifyCurrentSourceBeforePatching(source)
                    return .rejected(["Cannot disable interrupts without restoring INTENA from the saved state."])
                }
                if normalized.contains("skip") && normalized.contains("saving") && (normalized.contains("copper pointer") || normalized.contains("cop1lc")) {
                    try verifyCurrentSourceBeforePatching(source)
                    return .rejected(["Cannot skip saving COP1LC; the original copper pointer is required for RestoreSystem."])
                }
                if normalized.contains("exit directly") && normalized.contains("rts") {
                    try verifyCurrentSourceBeforePatching(source)
                    return .rejected(["Cannot exit the takeover loop with raw RTS; every exit must call RestoreSystem first."])
                }
                if normalized.contains("overwrite") && normalized.contains("dma") && normalized.contains("zero") {
                    try verifyCurrentSourceBeforePatching(source)
                    return .rejected(["Cannot overwrite saved DMA state; RestoreSystem must re-enable the saved OldDMACON mask."])
                }
                if normalized.contains("green") && (normalized.contains("palette") || normalized.contains("color") || normalized.contains("colour")) {
                    try verifyCurrentSourceBeforePatching(source)
                    return .patched(try verified(AmigaProgramPatcher.updateCleanTakeoverPaletteToGreen(in: source)))
                }
                if normalized.contains("copper split") {
                    try verifyCurrentSourceBeforePatching(source)
                    return .patched(try verified(AmigaProgramPatcher.enableCleanTakeoverCopperSplit(in: source)))
                }
                if normalized.contains("every other vblank") || normalized.contains("every other vertical blank") ||
                    (normalized.contains("slow") && normalized.contains("vblank")) {
                    try verifyCurrentSourceBeforePatching(source)
                    return .patched(try verified(AmigaProgramPatcher.slowCleanTakeoverEveryOtherVBlank(in: source)))
                }
                if normalized.contains("right mouse") && (normalized.contains("restore") || normalized.contains("emergency")) {
                    try verifyCurrentSourceBeforePatching(source)
                    return .patched(try verified(AmigaProgramPatcher.enableCleanTakeoverRightMouseRestore(in: source)))
                }
                return .notRecognized
            }
            if model.id == AmigaProgramTemplate.intuitionWindowToolID {
                let normalized = prompt.lowercased()
                if normalized.contains("skip") && normalized.contains("closing") && normalized.contains("window") {
                    try verifyCurrentSourceBeforePatching(source)
                    return .rejected(["Cannot skip CloseWindow; Intuition windows must be closed before intuition.library is closed."])
                }
                if normalized.contains("open intuition twice") || (normalized.contains("intuition") && normalized.contains("twice") && normalized.contains("close it once")) {
                    try verifyCurrentSourceBeforePatching(source)
                    return .rejected(["Cannot unbalance intuition.library OpenLibrary and CloseLibrary calls."])
                }
                if normalized.contains("no bounds") {
                    try verifyCurrentSourceBeforePatching(source)
                    return .rejected(["Intuition gadgets require explicit bounds in the model and Gadget data."])
                }
                if normalized.contains("jumping into data") || normalized.contains("jump into data") {
                    try verifyCurrentSourceBeforePatching(source)
                    return .rejected(["Close-window handling must branch to CleanupAndExit, not into data regions."])
                }
                if normalized.contains("status text") || normalized.contains("status field") {
                    try verifyCurrentSourceBeforePatching(source)
                    return .patched(try verified(AmigaProgramPatcher.addIntuitionStatusText(in: source)))
                }
                if (normalized.contains("move") || normalized.contains("place")) &&
                    normalized.contains("button") &&
                    normalized.contains("bottom") {
                    try verifyCurrentSourceBeforePatching(source)
                    return .patched(try verified(AmigaProgramPatcher.moveIntuitionButtonsToBottom(in: source)))
                }
                if normalized.contains("rename") && normalized.contains("stop") && normalized.contains("halt") {
                    try verifyCurrentSourceBeforePatching(source)
                    return .patched(try verified(AmigaProgramPatcher.renameIntuitionGadget(currentLabel: "Stop", newLabel: "Halt", in: source)))
                }
                if normalized.contains("volume up") &&
                    (normalized.contains("add") || normalized.contains("third") || normalized.contains("gadget") || normalized.contains("button")) {
                    try verifyCurrentSourceBeforePatching(source)
                    return .patched(try verified(AmigaProgramPatcher.addIntuitionGadget(label: "Volume Up", to: source)))
                }
                return .notRecognized
            }
            guard model.id == AmigaProgramFamilyRegistry.modPlayerControls.id else {
                return .notRecognized
            }
            switch modControlMoveAndParameterUpdateIntent(from: prompt, model: model) {
            case .request(let controls, let moveClause, let updates):
                try verifyCurrentSourceBeforePatching(source)
                var patchedSource = source
                var changedRegions: [String] = []
                var finalResult: AmigaProgramPatchResult?
                for control in controls {
                    let result = try verified(AmigaProgramPatcher.addControl(label: control.label, action: control.action, to: patchedSource))
                    patchedSource = result.source
                    changedRegions = mergedChangedRegions(changedRegions, result.changedRegions)
                    finalResult = result
                }
                guard let added = finalResult else { return .notRecognized }
                var addedResult = added
                if controls.count > 1,
                   let placements = addedControlGroupPlacementBounds(
                    in: prompt,
                    addedLabels: controls.map(\.label),
                    model: addedResult.model
                   ) {
                    let placed = try verified(AmigaProgramPatcher.updateControlBounds(placements, in: addedResult.source))
                    patchedSource = placed.source
                    changedRegions = mergedChangedRegions(changedRegions, placed.changedRegions)
                    addedResult = placed
                    finalResult = placed
                } else if controls.count == 1,
                          let placement = addedControlPlacementBounds(
                            in: prompt,
                            addedLabel: controls[0].label,
                            model: addedResult.model
                          ) {
                    let placed = try verified(AmigaProgramPatcher.updateControlBounds(
                        label: controls[0].label,
                        bounds: placement.bounds,
                        in: addedResult.source
                    ))
                    patchedSource = placed.source
                    changedRegions = mergedChangedRegions(changedRegions, placed.changedRegions)
                    addedResult = placed
                    finalResult = placed
                }
                if let rejection = ordinalControlMoveRejection(from: moveClause, model: addedResult.model) ??
                    ambiguousControlMoveRejection(from: moveClause, model: addedResult.model) {
                    return .rejected([rejection])
                }
                guard let move = moveControlRequest(from: moveClause, model: addedResult.model) else {
                    return .rejected(["Specify one control move after adding controls."])
                }
                let moved = try verified(AmigaProgramPatcher.moveControl(
                    label: move.label,
                    placement: move.placement,
                    targetLabel: move.targetLabel,
                    in: addedResult.source
                ))
                patchedSource = moved.source
                changedRegions = mergedChangedRegions(changedRegions, moved.changedRegions)
                finalResult = moved
                for update in updates {
                    let result = try verified(modParameterPatchResult(for: update, in: patchedSource))
                    patchedSource = result.source
                    changedRegions = mergedChangedRegions(changedRegions, result.changedRegions)
                    finalResult = result
                }
                guard let finalResult else { return .notRecognized }
                return .patched(AmigaProgramPatchResult(
                    source: finalResult.source,
                    model: finalResult.model,
                    changedRegions: changedRegions
                ))
            case .rejected(let reasons):
                try verifyCurrentSourceBeforePatching(source)
                return .rejected(reasons)
            case .notRecognized:
                break
            }
            switch modControlAndParameterUpdateIntent(from: prompt, model: model) {
            case .request(let controls, let updates):
                try verifyCurrentSourceBeforePatching(source)
                var patchedSource = source
                var changedRegions: [String] = []
                var finalResult: AmigaProgramPatchResult?
                for control in controls {
                    let result = try verified(AmigaProgramPatcher.addControl(label: control.label, action: control.action, to: patchedSource))
                    patchedSource = result.source
                    changedRegions = mergedChangedRegions(changedRegions, result.changedRegions)
                    finalResult = result
                }
                if var result = finalResult {
                    if controls.count > 1,
                       let placements = addedControlGroupPlacementBounds(
                        in: prompt,
                        addedLabels: controls.map(\.label),
                        model: result.model
                       ) {
                        let placed = try verified(AmigaProgramPatcher.updateControlBounds(placements, in: result.source))
                        patchedSource = placed.source
                        changedRegions = mergedChangedRegions(changedRegions, placed.changedRegions)
                        result = placed
                        finalResult = result
                    } else if controls.count == 1,
                              let placement = addedControlPlacementBounds(
                                in: prompt,
                                addedLabel: controls[0].label,
                                model: result.model
                              ) {
                        let placed = try verified(AmigaProgramPatcher.updateControlBounds(
                            label: controls[0].label,
                            bounds: placement.bounds,
                            in: result.source
                        ))
                        patchedSource = placed.source
                        changedRegions = mergedChangedRegions(changedRegions, placed.changedRegions)
                        result = placed
                        finalResult = result
                    }
                }
                for update in updates {
                    let result = try verified(modParameterPatchResult(for: update, in: patchedSource))
                    patchedSource = result.source
                    changedRegions = mergedChangedRegions(changedRegions, result.changedRegions)
                    finalResult = result
                }
                guard let finalResult else { return .notRecognized }
                return .patched(AmigaProgramPatchResult(
                    source: finalResult.source,
                    model: finalResult.model,
                    changedRegions: changedRegions
                ))
            case .rejected(let reasons):
                try verifyCurrentSourceBeforePatching(source)
                return .rejected(reasons)
            case .notRecognized:
                break
            }
            switch modLabelBehaviorBoundsMoveAndParameterUpdateIntent(from: prompt, model: model) {
            case .request(let change, let placement, let moveClause, let updates):
                try verifyCurrentSourceBeforePatching(source)
                let behaviorChanged = try verified(AmigaProgramPatcher.changeControlBehavior(
                    label: change.currentLabel,
                    action: change.action,
                    in: source
                ))
                let renamed = try verified(AmigaProgramPatcher.renameControl(
                    currentLabel: change.currentLabel,
                    newLabel: change.newLabel,
                    in: behaviorChanged.source
                ))
                let boundsLabel = placement.label == change.currentLabel ? change.newLabel : placement.label
                let boundsChanged = try verified(AmigaProgramPatcher.updateControlBounds(
                    label: boundsLabel,
                    bounds: placement.bounds,
                    in: renamed.source
                ))
                if let rejection = ordinalControlMoveRejection(from: moveClause, model: boundsChanged.model) ??
                    ambiguousControlMoveRejection(from: moveClause, model: boundsChanged.model) {
                    return .rejected([rejection])
                }
                guard let move = moveControlRequest(from: moveClause, model: boundsChanged.model) else {
                    return .rejected(["Specify one control move after changing label, behavior, and bounds."])
                }
                let moved = try verified(AmigaProgramPatcher.moveControl(
                    label: move.label,
                    placement: move.placement,
                    targetLabel: move.targetLabel,
                    in: boundsChanged.source
                ))
                var patchedSource = moved.source
                var changedRegions = mergedChangedRegions(
                    behaviorChanged.changedRegions,
                    renamed.changedRegions,
                    boundsChanged.changedRegions,
                    moved.changedRegions
                )
                var finalResult: AmigaProgramPatchResult = moved
                for update in updates {
                    let result = try verified(modParameterPatchResult(for: update, in: patchedSource))
                    patchedSource = result.source
                    changedRegions = mergedChangedRegions(changedRegions, result.changedRegions)
                    finalResult = result
                }
                return .patched(AmigaProgramPatchResult(
                    source: finalResult.source,
                    model: finalResult.model,
                    changedRegions: changedRegions
                ))
            case .rejected(let reasons):
                try verifyCurrentSourceBeforePatching(source)
                return .rejected(reasons)
            case .notRecognized:
                break
            }
            switch modLabelBehaviorBoundsAndParameterUpdateIntent(from: prompt, model: model) {
            case .request(let change, let placement, let updates):
                try verifyCurrentSourceBeforePatching(source)
                let behaviorChanged = try verified(AmigaProgramPatcher.changeControlBehavior(
                    label: change.currentLabel,
                    action: change.action,
                    in: source
                ))
                let renamed = try verified(AmigaProgramPatcher.renameControl(
                    currentLabel: change.currentLabel,
                    newLabel: change.newLabel,
                    in: behaviorChanged.source
                ))
                let boundsLabel = placement.label == change.currentLabel ? change.newLabel : placement.label
                let boundsChanged = try verified(AmigaProgramPatcher.updateControlBounds(
                    label: boundsLabel,
                    bounds: placement.bounds,
                    in: renamed.source
                ))
                var patchedSource = boundsChanged.source
                var changedRegions = mergedChangedRegions(
                    behaviorChanged.changedRegions,
                    renamed.changedRegions,
                    boundsChanged.changedRegions
                )
                var finalResult: AmigaProgramPatchResult = boundsChanged
                for update in updates {
                    let result = try verified(modParameterPatchResult(for: update, in: patchedSource))
                    patchedSource = result.source
                    changedRegions = mergedChangedRegions(changedRegions, result.changedRegions)
                    finalResult = result
                }
                return .patched(AmigaProgramPatchResult(
                    source: finalResult.source,
                    model: finalResult.model,
                    changedRegions: changedRegions
                ))
            case .rejected(let reasons):
                try verifyCurrentSourceBeforePatching(source)
                return .rejected(reasons)
            case .notRecognized:
                break
            }
            switch modLabelBehaviorAndParameterUpdateIntent(from: prompt, model: model) {
            case .request(let change, let updates):
                try verifyCurrentSourceBeforePatching(source)
                let behaviorChanged = try verified(AmigaProgramPatcher.changeControlBehavior(
                    label: change.currentLabel,
                    action: change.action,
                    in: source
                ))
                let renamed = try verified(AmigaProgramPatcher.renameControl(
                    currentLabel: change.currentLabel,
                    newLabel: change.newLabel,
                    in: behaviorChanged.source
                ))
                var patchedSource = renamed.source
                var changedRegions = mergedChangedRegions(behaviorChanged.changedRegions, renamed.changedRegions)
                var finalResult: AmigaProgramPatchResult = renamed
                for update in updates {
                    let result = try verified(modParameterPatchResult(for: update, in: patchedSource))
                    patchedSource = result.source
                    changedRegions = mergedChangedRegions(changedRegions, result.changedRegions)
                    finalResult = result
                }
                return .patched(AmigaProgramPatchResult(
                    source: finalResult.source,
                    model: finalResult.model,
                    changedRegions: changedRegions
                ))
            case .rejected(let reasons):
                try verifyCurrentSourceBeforePatching(source)
                return .rejected(reasons)
            case .notRecognized:
                break
            }
            switch modLabelBehaviorAndBoundsUpdateIntent(from: prompt, model: model) {
            case .request(let change, let placement):
                try verifyCurrentSourceBeforePatching(source)
                let behaviorChanged = try verified(AmigaProgramPatcher.changeControlBehavior(
                    label: change.currentLabel,
                    action: change.action,
                    in: source
                ))
                let renamed = try verified(AmigaProgramPatcher.renameControl(
                    currentLabel: change.currentLabel,
                    newLabel: change.newLabel,
                    in: behaviorChanged.source
                ))
                let boundsLabel = placement.label == change.currentLabel ? change.newLabel : placement.label
                let boundsChanged = try verified(AmigaProgramPatcher.updateControlBounds(
                    label: boundsLabel,
                    bounds: placement.bounds,
                    in: renamed.source
                ))
                return .patched(AmigaProgramPatchResult(
                    source: boundsChanged.source,
                    model: boundsChanged.model,
                    changedRegions: mergedChangedRegions(
                        behaviorChanged.changedRegions,
                        renamed.changedRegions,
                        boundsChanged.changedRegions
                    )
                ))
            case .rejected(let reasons):
                try verifyCurrentSourceBeforePatching(source)
                return .rejected(reasons)
            case .notRecognized:
                break
            }
            switch modLabelBehaviorMoveAndParameterUpdateIntent(from: prompt, model: model) {
            case .request(let change, let moveClause, let updates):
                try verifyCurrentSourceBeforePatching(source)
                let behaviorChanged = try verified(AmigaProgramPatcher.changeControlBehavior(
                    label: change.currentLabel,
                    action: change.action,
                    in: source
                ))
                let renamed = try verified(AmigaProgramPatcher.renameControl(
                    currentLabel: change.currentLabel,
                    newLabel: change.newLabel,
                    in: behaviorChanged.source
                ))
                if let rejection = ordinalControlMoveRejection(from: moveClause, model: renamed.model) ??
                    ambiguousControlMoveRejection(from: moveClause, model: renamed.model) {
                    return .rejected([rejection])
                }
                guard let move = moveControlRequest(from: moveClause, model: renamed.model) else {
                    return .rejected(["Specify one control move after changing label and behavior."])
                }
                let moved = try verified(AmigaProgramPatcher.moveControl(
                    label: move.label,
                    placement: move.placement,
                    targetLabel: move.targetLabel,
                    in: renamed.source
                ))
                var patchedSource = moved.source
                var changedRegions = mergedChangedRegions(
                    behaviorChanged.changedRegions,
                    renamed.changedRegions,
                    moved.changedRegions
                )
                var finalResult: AmigaProgramPatchResult = moved
                for update in updates {
                    let result = try verified(modParameterPatchResult(for: update, in: patchedSource))
                    patchedSource = result.source
                    changedRegions = mergedChangedRegions(changedRegions, result.changedRegions)
                    finalResult = result
                }
                return .patched(AmigaProgramPatchResult(
                    source: finalResult.source,
                    model: finalResult.model,
                    changedRegions: changedRegions
                ))
            case .rejected(let reasons):
                try verifyCurrentSourceBeforePatching(source)
                return .rejected(reasons)
            case .notRecognized:
                break
            }
            switch modRenameBoundsMoveAndParameterUpdateIntent(from: prompt, model: model) {
            case .request(let rename, let placement, let moveClause, let updates):
                try verifyCurrentSourceBeforePatching(source)
                let renamed = try verified(AmigaProgramPatcher.renameControl(
                    currentLabel: rename.currentLabel,
                    newLabel: rename.newLabel,
                    in: source
                ))
                let boundsLabel = placement.label == rename.currentLabel ? rename.newLabel : placement.label
                let boundsChanged = try verified(AmigaProgramPatcher.updateControlBounds(
                    label: boundsLabel,
                    bounds: placement.bounds,
                    in: renamed.source
                ))
                if let rejection = ordinalControlMoveRejection(from: moveClause, model: boundsChanged.model) ??
                    ambiguousControlMoveRejection(from: moveClause, model: boundsChanged.model) {
                    return .rejected([rejection])
                }
                guard let move = moveControlRequest(from: moveClause, model: boundsChanged.model) else {
                    return .rejected(["Specify one control move after renaming and changing bounds."])
                }
                let moved = try verified(AmigaProgramPatcher.moveControl(
                    label: move.label,
                    placement: move.placement,
                    targetLabel: move.targetLabel,
                    in: boundsChanged.source
                ))
                var patchedSource = moved.source
                var changedRegions = mergedChangedRegions(renamed.changedRegions, boundsChanged.changedRegions, moved.changedRegions)
                var finalResult: AmigaProgramPatchResult = moved
                for update in updates {
                    let result = try verified(modParameterPatchResult(for: update, in: patchedSource))
                    patchedSource = result.source
                    changedRegions = mergedChangedRegions(changedRegions, result.changedRegions)
                    finalResult = result
                }
                return .patched(AmigaProgramPatchResult(
                    source: finalResult.source,
                    model: finalResult.model,
                    changedRegions: changedRegions
                ))
            case .rejected(let reasons):
                try verifyCurrentSourceBeforePatching(source)
                return .rejected(reasons)
            case .notRecognized:
                break
            }
            switch modRenameBoundsAndParameterUpdateIntent(from: prompt, model: model) {
            case .request(let rename, let placement, let updates):
                try verifyCurrentSourceBeforePatching(source)
                let renamed = try verified(AmigaProgramPatcher.renameControl(
                    currentLabel: rename.currentLabel,
                    newLabel: rename.newLabel,
                    in: source
                ))
                let boundsLabel = placement.label == rename.currentLabel ? rename.newLabel : placement.label
                let boundsChanged = try verified(AmigaProgramPatcher.updateControlBounds(
                    label: boundsLabel,
                    bounds: placement.bounds,
                    in: renamed.source
                ))
                var patchedSource = boundsChanged.source
                var changedRegions = mergedChangedRegions(renamed.changedRegions, boundsChanged.changedRegions)
                var finalResult: AmigaProgramPatchResult = boundsChanged
                for update in updates {
                    let result = try verified(modParameterPatchResult(for: update, in: patchedSource))
                    patchedSource = result.source
                    changedRegions = mergedChangedRegions(changedRegions, result.changedRegions)
                    finalResult = result
                }
                return .patched(AmigaProgramPatchResult(
                    source: finalResult.source,
                    model: finalResult.model,
                    changedRegions: changedRegions
                ))
            case .rejected(let reasons):
                try verifyCurrentSourceBeforePatching(source)
                return .rejected(reasons)
            case .notRecognized:
                break
            }
            switch modRenameBoundsUpdateIntent(from: prompt, model: model) {
            case .request(let rename, let placement):
                try verifyCurrentSourceBeforePatching(source)
                let renamed = try verified(AmigaProgramPatcher.renameControl(
                    currentLabel: rename.currentLabel,
                    newLabel: rename.newLabel,
                    in: source
                ))
                let boundsLabel = placement.label == rename.currentLabel ? rename.newLabel : placement.label
                let boundsChanged = try verified(AmigaProgramPatcher.updateControlBounds(
                    label: boundsLabel,
                    bounds: placement.bounds,
                    in: renamed.source
                ))
                return .patched(AmigaProgramPatchResult(
                    source: boundsChanged.source,
                    model: boundsChanged.model,
                    changedRegions: mergedChangedRegions(renamed.changedRegions, boundsChanged.changedRegions)
                ))
            case .rejected(let reasons):
                try verifyCurrentSourceBeforePatching(source)
                return .rejected(reasons)
            case .notRecognized:
                break
            }
            switch modRenameMoveAndParameterUpdateIntent(from: prompt, model: model) {
            case .request(let rename, let moveClause, let updates):
                try verifyCurrentSourceBeforePatching(source)
                let renamed = try verified(AmigaProgramPatcher.renameControl(
                    currentLabel: rename.currentLabel,
                    newLabel: rename.newLabel,
                    in: source
                ))
                if let rejection = ordinalControlMoveRejection(from: moveClause, model: renamed.model) ??
                    ambiguousControlMoveRejection(from: moveClause, model: renamed.model) {
                    return .rejected([rejection])
                }
                guard let move = moveControlRequest(from: moveClause, model: renamed.model) else {
                    return .rejected(["Specify one control move after renaming a control."])
                }
                let moved = try verified(AmigaProgramPatcher.moveControl(
                    label: move.label,
                    placement: move.placement,
                    targetLabel: move.targetLabel,
                    in: renamed.source
                ))
                var patchedSource = moved.source
                var changedRegions = mergedChangedRegions(renamed.changedRegions, moved.changedRegions)
                var finalResult: AmigaProgramPatchResult = moved
                for update in updates {
                    let result = try verified(modParameterPatchResult(for: update, in: patchedSource))
                    patchedSource = result.source
                    changedRegions = mergedChangedRegions(changedRegions, result.changedRegions)
                    finalResult = result
                }
                return .patched(AmigaProgramPatchResult(
                    source: finalResult.source,
                    model: finalResult.model,
                    changedRegions: changedRegions
                ))
            case .rejected(let reasons):
                try verifyCurrentSourceBeforePatching(source)
                return .rejected(reasons)
            case .notRecognized:
                break
            }
            switch modRenameAndParameterUpdateIntent(from: prompt, model: model) {
            case .request(let rename, let updates):
                try verifyCurrentSourceBeforePatching(source)
                let renamed = try verified(AmigaProgramPatcher.renameControl(
                    currentLabel: rename.currentLabel,
                    newLabel: rename.newLabel,
                    in: source
                ))
                var patchedSource = renamed.source
                var changedRegions = renamed.changedRegions
                var finalResult: AmigaProgramPatchResult = renamed
                for update in updates {
                    let result = try verified(modParameterPatchResult(for: update, in: patchedSource))
                    patchedSource = result.source
                    changedRegions = mergedChangedRegions(changedRegions, result.changedRegions)
                    finalResult = result
                }
                return .patched(AmigaProgramPatchResult(
                    source: finalResult.source,
                    model: finalResult.model,
                    changedRegions: changedRegions
                ))
            case .rejected(let reasons):
                try verifyCurrentSourceBeforePatching(source)
                return .rejected(reasons)
            case .notRecognized:
                break
            }
            switch modBehaviorBoundsMoveAndParameterUpdateIntent(from: prompt, model: model) {
            case .request(let behavior, let placement, let moveClause, let updates):
                try verifyCurrentSourceBeforePatching(source)
                let behaviorChanged = try verified(AmigaProgramPatcher.changeControlBehavior(
                    label: behavior.label,
                    action: behavior.action,
                    in: source
                ))
                let boundsChanged = try verified(AmigaProgramPatcher.updateControlBounds(
                    label: placement.label,
                    bounds: placement.bounds,
                    in: behaviorChanged.source
                ))
                if let rejection = ordinalControlMoveRejection(from: moveClause, model: boundsChanged.model) ??
                    ambiguousControlMoveRejection(from: moveClause, model: boundsChanged.model) {
                    return .rejected([rejection])
                }
                guard let move = moveControlRequest(from: moveClause, model: boundsChanged.model) else {
                    return .rejected(["Specify one control move after changing behavior and bounds."])
                }
                let moved = try verified(AmigaProgramPatcher.moveControl(
                    label: move.label,
                    placement: move.placement,
                    targetLabel: move.targetLabel,
                    in: boundsChanged.source
                ))
                var patchedSource = moved.source
                var changedRegions = mergedChangedRegions(behaviorChanged.changedRegions, boundsChanged.changedRegions, moved.changedRegions)
                var finalResult: AmigaProgramPatchResult = moved
                for update in updates {
                    let result = try verified(modParameterPatchResult(for: update, in: patchedSource))
                    patchedSource = result.source
                    changedRegions = mergedChangedRegions(changedRegions, result.changedRegions)
                    finalResult = result
                }
                return .patched(AmigaProgramPatchResult(
                    source: finalResult.source,
                    model: finalResult.model,
                    changedRegions: changedRegions
                ))
            case .rejected(let reasons):
                try verifyCurrentSourceBeforePatching(source)
                return .rejected(reasons)
            case .notRecognized:
                break
            }
            switch modBehaviorBoundsAndParameterUpdateIntent(from: prompt, model: model) {
            case .request(let behavior, let placement, let updates):
                try verifyCurrentSourceBeforePatching(source)
                let behaviorChanged = try verified(AmigaProgramPatcher.changeControlBehavior(
                    label: behavior.label,
                    action: behavior.action,
                    in: source
                ))
                let boundsChanged = try verified(AmigaProgramPatcher.updateControlBounds(
                    label: placement.label,
                    bounds: placement.bounds,
                    in: behaviorChanged.source
                ))
                var patchedSource = boundsChanged.source
                var changedRegions = mergedChangedRegions(behaviorChanged.changedRegions, boundsChanged.changedRegions)
                var finalResult: AmigaProgramPatchResult = boundsChanged
                for update in updates {
                    let result = try verified(modParameterPatchResult(for: update, in: patchedSource))
                    patchedSource = result.source
                    changedRegions = mergedChangedRegions(changedRegions, result.changedRegions)
                    finalResult = result
                }
                return .patched(AmigaProgramPatchResult(
                    source: finalResult.source,
                    model: finalResult.model,
                    changedRegions: changedRegions
                ))
            case .rejected(let reasons):
                try verifyCurrentSourceBeforePatching(source)
                return .rejected(reasons)
            case .notRecognized:
                break
            }
            switch modBehaviorMoveAndParameterUpdateIntent(from: prompt, model: model) {
            case .request(let behavior, let moveClause, let updates):
                try verifyCurrentSourceBeforePatching(source)
                let behaviorChanged = try verified(AmigaProgramPatcher.changeControlBehavior(
                    label: behavior.label,
                    action: behavior.action,
                    in: source
                ))
                if let rejection = ordinalControlMoveRejection(from: moveClause, model: behaviorChanged.model) ??
                    ambiguousControlMoveRejection(from: moveClause, model: behaviorChanged.model) {
                    return .rejected([rejection])
                }
                guard let move = moveControlRequest(from: moveClause, model: behaviorChanged.model) else {
                    return .rejected(["Specify one control move after changing behavior."])
                }
                let moved = try verified(AmigaProgramPatcher.moveControl(
                    label: move.label,
                    placement: move.placement,
                    targetLabel: move.targetLabel,
                    in: behaviorChanged.source
                ))
                var patchedSource = moved.source
                var changedRegions = mergedChangedRegions(behaviorChanged.changedRegions, moved.changedRegions)
                var finalResult: AmigaProgramPatchResult = moved
                for update in updates {
                    let result = try verified(modParameterPatchResult(for: update, in: patchedSource))
                    patchedSource = result.source
                    changedRegions = mergedChangedRegions(changedRegions, result.changedRegions)
                    finalResult = result
                }
                return .patched(AmigaProgramPatchResult(
                    source: finalResult.source,
                    model: finalResult.model,
                    changedRegions: changedRegions
                ))
            case .rejected(let reasons):
                try verifyCurrentSourceBeforePatching(source)
                return .rejected(reasons)
            case .notRecognized:
                break
            }
            switch modBehaviorAndParameterUpdateIntent(from: prompt, model: model) {
            case .request(let behavior, let updates):
                try verifyCurrentSourceBeforePatching(source)
                let behaviorChanged = try verified(AmigaProgramPatcher.changeControlBehavior(
                    label: behavior.label,
                    action: behavior.action,
                    in: source
                ))
                var patchedSource = behaviorChanged.source
                var changedRegions = behaviorChanged.changedRegions
                var finalResult: AmigaProgramPatchResult = behaviorChanged
                for update in updates {
                    let result = try verified(modParameterPatchResult(for: update, in: patchedSource))
                    patchedSource = result.source
                    changedRegions = mergedChangedRegions(changedRegions, result.changedRegions)
                    finalResult = result
                }
                return .patched(AmigaProgramPatchResult(
                    source: finalResult.source,
                    model: finalResult.model,
                    changedRegions: changedRegions
                ))
            case .rejected(let reasons):
                try verifyCurrentSourceBeforePatching(source)
                return .rejected(reasons)
            case .notRecognized:
                break
            }
            switch modBoundsMoveAndParameterUpdateIntent(from: prompt, model: model) {
            case .request(let placements, let move, let updates):
                try verifyCurrentSourceBeforePatching(source)
                let boundsChanged = try verified(AmigaProgramPatcher.updateControlBounds(placements, in: source))
                let moved = try verified(AmigaProgramPatcher.moveControl(
                    label: move.label,
                    placement: move.placement,
                    targetLabel: move.targetLabel,
                    in: boundsChanged.source
                ))
                var patchedSource = moved.source
                var changedRegions = mergedChangedRegions(boundsChanged.changedRegions, moved.changedRegions)
                var finalResult: AmigaProgramPatchResult = moved
                for update in updates {
                    let result = try verified(modParameterPatchResult(for: update, in: patchedSource))
                    patchedSource = result.source
                    changedRegions = mergedChangedRegions(changedRegions, result.changedRegions)
                    finalResult = result
                }
                return .patched(AmigaProgramPatchResult(
                    source: finalResult.source,
                    model: finalResult.model,
                    changedRegions: changedRegions
                ))
            case .rejected(let reasons):
                try verifyCurrentSourceBeforePatching(source)
                return .rejected(reasons)
            case .notRecognized:
                break
            }
            switch modBoundsAndParameterUpdateIntent(from: prompt, model: model) {
            case .request(let placements, let updates):
                try verifyCurrentSourceBeforePatching(source)
                let boundsChanged = try verified(AmigaProgramPatcher.updateControlBounds(placements, in: source))
                var patchedSource = boundsChanged.source
                var changedRegions = boundsChanged.changedRegions
                var finalResult: AmigaProgramPatchResult = boundsChanged
                for update in updates {
                    let result = try verified(modParameterPatchResult(for: update, in: patchedSource))
                    patchedSource = result.source
                    changedRegions = mergedChangedRegions(changedRegions, result.changedRegions)
                    finalResult = result
                }
                return .patched(AmigaProgramPatchResult(
                    source: finalResult.source,
                    model: finalResult.model,
                    changedRegions: changedRegions
                ))
            case .rejected(let reasons):
                try verifyCurrentSourceBeforePatching(source)
                return .rejected(reasons)
            case .notRecognized:
                break
            }
            switch modRemovalLabelBehaviorBoundsMoveAndParameterUpdateIntent(from: prompt, model: model) {
            case .request(let label, let change, let placement, let moveClause, let updates):
                try verifyCurrentSourceBeforePatching(source)
                let removed = try verified(AmigaProgramPatcher.removeControl(label: label, from: source))
                let behaviorChanged = try verified(AmigaProgramPatcher.changeControlBehavior(
                    label: change.currentLabel,
                    action: change.action,
                    in: removed.source
                ))
                let renamed = try verified(AmigaProgramPatcher.renameControl(
                    currentLabel: change.currentLabel,
                    newLabel: change.newLabel,
                    in: behaviorChanged.source
                ))
                let placementLabel = placement.label.caseInsensitiveCompare(change.currentLabel) == .orderedSame
                    ? change.newLabel
                    : placement.label
                let boundsChanged = try verified(AmigaProgramPatcher.updateControlBounds(
                    label: placementLabel,
                    bounds: placement.bounds,
                    in: renamed.source
                ))
                if let rejection = ordinalControlMoveRejection(from: moveClause, model: boundsChanged.model) ??
                    ambiguousControlMoveRejection(from: moveClause, model: boundsChanged.model) {
                    return .rejected([rejection])
                }
                guard let move = moveControlRequest(from: moveClause, model: boundsChanged.model) else {
                    return .rejected(["Specify one control move after removing, changing label, behavior, and bounds."])
                }
                let moved = try verified(AmigaProgramPatcher.moveControl(
                    label: move.label,
                    placement: move.placement,
                    targetLabel: move.targetLabel,
                    in: boundsChanged.source
                ))
                var patchedSource = moved.source
                var changedRegions = mergedChangedRegions(
                    removed.changedRegions,
                    behaviorChanged.changedRegions,
                    renamed.changedRegions,
                    boundsChanged.changedRegions,
                    moved.changedRegions
                )
                var finalResult: AmigaProgramPatchResult = moved
                for update in updates {
                    let result = try verified(modParameterPatchResult(for: update, in: patchedSource))
                    patchedSource = result.source
                    changedRegions = mergedChangedRegions(changedRegions, result.changedRegions)
                    finalResult = result
                }
                return .patched(AmigaProgramPatchResult(
                    source: finalResult.source,
                    model: finalResult.model,
                    changedRegions: changedRegions
                ))
            case .rejected(let reasons):
                try verifyCurrentSourceBeforePatching(source)
                return .rejected(reasons)
            case .notRecognized:
                break
            }
            switch modRemovalRenameBoundsMoveAndParameterUpdateIntent(from: prompt, model: model) {
            case .request(let label, let rename, let placement, let moveClause, let updates):
                try verifyCurrentSourceBeforePatching(source)
                let removed = try verified(AmigaProgramPatcher.removeControl(label: label, from: source))
                let renamed = try verified(AmigaProgramPatcher.renameControl(
                    currentLabel: rename.currentLabel,
                    newLabel: rename.newLabel,
                    in: removed.source
                ))
                let placementLabel = placement.label.caseInsensitiveCompare(rename.currentLabel) == .orderedSame
                    ? rename.newLabel
                    : placement.label
                let boundsChanged = try verified(AmigaProgramPatcher.updateControlBounds(
                    label: placementLabel,
                    bounds: placement.bounds,
                    in: renamed.source
                ))
                if let rejection = ordinalControlMoveRejection(from: moveClause, model: boundsChanged.model) ??
                    ambiguousControlMoveRejection(from: moveClause, model: boundsChanged.model) {
                    return .rejected([rejection])
                }
                guard let move = moveControlRequest(from: moveClause, model: boundsChanged.model) else {
                    return .rejected(["Specify one control move after removing, renaming, and changing bounds."])
                }
                let moved = try verified(AmigaProgramPatcher.moveControl(
                    label: move.label,
                    placement: move.placement,
                    targetLabel: move.targetLabel,
                    in: boundsChanged.source
                ))
                var patchedSource = moved.source
                var changedRegions = mergedChangedRegions(removed.changedRegions, renamed.changedRegions, boundsChanged.changedRegions, moved.changedRegions)
                var finalResult: AmigaProgramPatchResult = moved
                for update in updates {
                    let result = try verified(modParameterPatchResult(for: update, in: patchedSource))
                    patchedSource = result.source
                    changedRegions = mergedChangedRegions(changedRegions, result.changedRegions)
                    finalResult = result
                }
                return .patched(AmigaProgramPatchResult(
                    source: finalResult.source,
                    model: finalResult.model,
                    changedRegions: changedRegions
                ))
            case .rejected(let reasons):
                try verifyCurrentSourceBeforePatching(source)
                return .rejected(reasons)
            case .notRecognized:
                break
            }
            switch modRemovalBoundsMoveAndParameterUpdateIntent(from: prompt, model: model) {
            case .request(let label, let placements, let move, let updates):
                try verifyCurrentSourceBeforePatching(source)
                let removed = try verified(AmigaProgramPatcher.removeControl(label: label, from: source))
                let boundsChanged = try verified(AmigaProgramPatcher.updateControlBounds(placements, in: removed.source))
                let moved = try verified(AmigaProgramPatcher.moveControl(
                    label: move.label,
                    placement: move.placement,
                    targetLabel: move.targetLabel,
                    in: boundsChanged.source
                ))
                var patchedSource = moved.source
                var changedRegions = mergedChangedRegions(removed.changedRegions, boundsChanged.changedRegions, moved.changedRegions)
                var finalResult: AmigaProgramPatchResult = moved
                for update in updates {
                    let result = try verified(modParameterPatchResult(for: update, in: patchedSource))
                    patchedSource = result.source
                    changedRegions = mergedChangedRegions(changedRegions, result.changedRegions)
                    finalResult = result
                }
                return .patched(AmigaProgramPatchResult(
                    source: finalResult.source,
                    model: finalResult.model,
                    changedRegions: changedRegions
                ))
            case .rejected(let reasons):
                try verifyCurrentSourceBeforePatching(source)
                return .rejected(reasons)
            case .notRecognized:
                break
            }
            switch modRemovalLabelBehaviorMoveAndParameterUpdateIntent(from: prompt, model: model) {
            case .request(let label, let change, let moveClause, let updates):
                try verifyCurrentSourceBeforePatching(source)
                let removed = try verified(AmigaProgramPatcher.removeControl(label: label, from: source))
                let behaviorChanged = try verified(AmigaProgramPatcher.changeControlBehavior(
                    label: change.currentLabel,
                    action: change.action,
                    in: removed.source
                ))
                let renamed = try verified(AmigaProgramPatcher.renameControl(
                    currentLabel: change.currentLabel,
                    newLabel: change.newLabel,
                    in: behaviorChanged.source
                ))
                if let rejection = ordinalControlMoveRejection(from: moveClause, model: renamed.model) ??
                    ambiguousControlMoveRejection(from: moveClause, model: renamed.model) {
                    return .rejected([rejection])
                }
                guard let move = moveControlRequest(from: moveClause, model: renamed.model) else {
                    return .rejected(["Specify one control move after removing, changing label, and behavior."])
                }
                let moved = try verified(AmigaProgramPatcher.moveControl(
                    label: move.label,
                    placement: move.placement,
                    targetLabel: move.targetLabel,
                    in: renamed.source
                ))
                var patchedSource = moved.source
                var changedRegions = mergedChangedRegions(
                    removed.changedRegions,
                    behaviorChanged.changedRegions,
                    renamed.changedRegions,
                    moved.changedRegions
                )
                var finalResult: AmigaProgramPatchResult = moved
                for update in updates {
                    let result = try verified(modParameterPatchResult(for: update, in: patchedSource))
                    patchedSource = result.source
                    changedRegions = mergedChangedRegions(changedRegions, result.changedRegions)
                    finalResult = result
                }
                return .patched(AmigaProgramPatchResult(
                    source: finalResult.source,
                    model: finalResult.model,
                    changedRegions: changedRegions
                ))
            case .rejected(let reasons):
                try verifyCurrentSourceBeforePatching(source)
                return .rejected(reasons)
            case .notRecognized:
                break
            }
            switch modRemovalLabelBehaviorBoundsAndParameterUpdateIntent(from: prompt, model: model) {
            case .request(let label, let change, let placement, let updates):
                try verifyCurrentSourceBeforePatching(source)
                let removed = try verified(AmigaProgramPatcher.removeControl(label: label, from: source))
                let behaviorChanged = try verified(AmigaProgramPatcher.changeControlBehavior(
                    label: change.currentLabel,
                    action: change.action,
                    in: removed.source
                ))
                let renamed = try verified(AmigaProgramPatcher.renameControl(
                    currentLabel: change.currentLabel,
                    newLabel: change.newLabel,
                    in: behaviorChanged.source
                ))
                let placementLabel = placement.label.caseInsensitiveCompare(change.currentLabel) == .orderedSame
                    ? change.newLabel
                    : placement.label
                let boundsChanged = try verified(AmigaProgramPatcher.updateControlBounds(
                    label: placementLabel,
                    bounds: placement.bounds,
                    in: renamed.source
                ))
                var patchedSource = boundsChanged.source
                var changedRegions = mergedChangedRegions(
                    removed.changedRegions,
                    behaviorChanged.changedRegions,
                    renamed.changedRegions,
                    boundsChanged.changedRegions
                )
                var finalResult: AmigaProgramPatchResult = boundsChanged
                for update in updates {
                    let result = try verified(modParameterPatchResult(for: update, in: patchedSource))
                    patchedSource = result.source
                    changedRegions = mergedChangedRegions(changedRegions, result.changedRegions)
                    finalResult = result
                }
                return .patched(AmigaProgramPatchResult(
                    source: finalResult.source,
                    model: finalResult.model,
                    changedRegions: changedRegions
                ))
            case .rejected(let reasons):
                try verifyCurrentSourceBeforePatching(source)
                return .rejected(reasons)
            case .notRecognized:
                break
            }
            switch modRemovalLabelBehaviorAndParameterUpdateIntent(from: prompt, model: model) {
            case .request(let label, let change, let updates):
                try verifyCurrentSourceBeforePatching(source)
                let removed = try verified(AmigaProgramPatcher.removeControl(label: label, from: source))
                let behaviorChanged = try verified(AmigaProgramPatcher.changeControlBehavior(
                    label: change.currentLabel,
                    action: change.action,
                    in: removed.source
                ))
                let renamed = try verified(AmigaProgramPatcher.renameControl(
                    currentLabel: change.currentLabel,
                    newLabel: change.newLabel,
                    in: behaviorChanged.source
                ))
                var patchedSource = renamed.source
                var changedRegions = mergedChangedRegions(removed.changedRegions, behaviorChanged.changedRegions, renamed.changedRegions)
                var finalResult: AmigaProgramPatchResult = renamed
                for update in updates {
                    let result = try verified(modParameterPatchResult(for: update, in: patchedSource))
                    patchedSource = result.source
                    changedRegions = mergedChangedRegions(changedRegions, result.changedRegions)
                    finalResult = result
                }
                return .patched(AmigaProgramPatchResult(
                    source: finalResult.source,
                    model: finalResult.model,
                    changedRegions: changedRegions
                ))
            case .rejected(let reasons):
                try verifyCurrentSourceBeforePatching(source)
                return .rejected(reasons)
            case .notRecognized:
                break
            }
            switch modRemovalRenameBoundsAndParameterUpdateIntent(from: prompt, model: model) {
            case .request(let label, let rename, let placement, let updates):
                try verifyCurrentSourceBeforePatching(source)
                let removed = try verified(AmigaProgramPatcher.removeControl(label: label, from: source))
                let renamed = try verified(AmigaProgramPatcher.renameControl(
                    currentLabel: rename.currentLabel,
                    newLabel: rename.newLabel,
                    in: removed.source
                ))
                let placementLabel = placement.label.caseInsensitiveCompare(rename.currentLabel) == .orderedSame
                    ? rename.newLabel
                    : placement.label
                let boundsChanged = try verified(AmigaProgramPatcher.updateControlBounds(
                    label: placementLabel,
                    bounds: placement.bounds,
                    in: renamed.source
                ))
                var patchedSource = boundsChanged.source
                var changedRegions = mergedChangedRegions(removed.changedRegions, renamed.changedRegions, boundsChanged.changedRegions)
                var finalResult: AmigaProgramPatchResult = boundsChanged
                for update in updates {
                    let result = try verified(modParameterPatchResult(for: update, in: patchedSource))
                    patchedSource = result.source
                    changedRegions = mergedChangedRegions(changedRegions, result.changedRegions)
                    finalResult = result
                }
                return .patched(AmigaProgramPatchResult(
                    source: finalResult.source,
                    model: finalResult.model,
                    changedRegions: changedRegions
                ))
            case .rejected(let reasons):
                try verifyCurrentSourceBeforePatching(source)
                return .rejected(reasons)
            case .notRecognized:
                break
            }
            switch modRemovalRenameMoveAndParameterUpdateIntent(from: prompt, model: model) {
            case .request(let label, let rename, let moveClause, let updates):
                try verifyCurrentSourceBeforePatching(source)
                let removed = try verified(AmigaProgramPatcher.removeControl(label: label, from: source))
                let renamed = try verified(AmigaProgramPatcher.renameControl(
                    currentLabel: rename.currentLabel,
                    newLabel: rename.newLabel,
                    in: removed.source
                ))
                if let rejection = ordinalControlMoveRejection(from: moveClause, model: renamed.model) ??
                    ambiguousControlMoveRejection(from: moveClause, model: renamed.model) {
                    return .rejected([rejection])
                }
                guard let move = moveControlRequest(from: moveClause, model: renamed.model) else {
                    return .rejected(["Specify one control move after removing and renaming."])
                }
                let moved = try verified(AmigaProgramPatcher.moveControl(
                    label: move.label,
                    placement: move.placement,
                    targetLabel: move.targetLabel,
                    in: renamed.source
                ))
                var patchedSource = moved.source
                var changedRegions = mergedChangedRegions(removed.changedRegions, renamed.changedRegions, moved.changedRegions)
                var finalResult: AmigaProgramPatchResult = moved
                for update in updates {
                    let result = try verified(modParameterPatchResult(for: update, in: patchedSource))
                    patchedSource = result.source
                    changedRegions = mergedChangedRegions(changedRegions, result.changedRegions)
                    finalResult = result
                }
                return .patched(AmigaProgramPatchResult(
                    source: finalResult.source,
                    model: finalResult.model,
                    changedRegions: changedRegions
                ))
            case .rejected(let reasons):
                try verifyCurrentSourceBeforePatching(source)
                return .rejected(reasons)
            case .notRecognized:
                break
            }
            switch modRemovalRenameAndParameterUpdateIntent(from: prompt, model: model) {
            case .request(let label, let rename, let updates):
                try verifyCurrentSourceBeforePatching(source)
                let removed = try verified(AmigaProgramPatcher.removeControl(label: label, from: source))
                let renamed = try verified(AmigaProgramPatcher.renameControl(
                    currentLabel: rename.currentLabel,
                    newLabel: rename.newLabel,
                    in: removed.source
                ))
                var patchedSource = renamed.source
                var changedRegions = mergedChangedRegions(removed.changedRegions, renamed.changedRegions)
                var finalResult: AmigaProgramPatchResult = renamed
                for update in updates {
                    let result = try verified(modParameterPatchResult(for: update, in: patchedSource))
                    patchedSource = result.source
                    changedRegions = mergedChangedRegions(changedRegions, result.changedRegions)
                    finalResult = result
                }
                return .patched(AmigaProgramPatchResult(
                    source: finalResult.source,
                    model: finalResult.model,
                    changedRegions: changedRegions
                ))
            case .rejected(let reasons):
                try verifyCurrentSourceBeforePatching(source)
                return .rejected(reasons)
            case .notRecognized:
                break
            }
            switch modRemovalBehaviorBoundsMoveAndParameterUpdateIntent(from: prompt, model: model) {
            case .request(let label, let behavior, let placement, let moveClause, let updates):
                try verifyCurrentSourceBeforePatching(source)
                let removed = try verified(AmigaProgramPatcher.removeControl(label: label, from: source))
                let behaviorChanged = try verified(AmigaProgramPatcher.changeControlBehavior(
                    label: behavior.label,
                    action: behavior.action,
                    in: removed.source
                ))
                let boundsChanged = try verified(AmigaProgramPatcher.updateControlBounds(
                    label: placement.label,
                    bounds: placement.bounds,
                    in: behaviorChanged.source
                ))
                if let rejection = ordinalControlMoveRejection(from: moveClause, model: boundsChanged.model) ??
                    ambiguousControlMoveRejection(from: moveClause, model: boundsChanged.model) {
                    return .rejected([rejection])
                }
                guard let move = moveControlRequest(from: moveClause, model: boundsChanged.model) else {
                    return .rejected(["Specify one control move after removing, changing behavior, and changing bounds."])
                }
                let moved = try verified(AmigaProgramPatcher.moveControl(
                    label: move.label,
                    placement: move.placement,
                    targetLabel: move.targetLabel,
                    in: boundsChanged.source
                ))
                var patchedSource = moved.source
                var changedRegions = mergedChangedRegions(
                    removed.changedRegions,
                    behaviorChanged.changedRegions,
                    boundsChanged.changedRegions,
                    moved.changedRegions
                )
                var finalResult: AmigaProgramPatchResult = moved
                for update in updates {
                    let result = try verified(modParameterPatchResult(for: update, in: patchedSource))
                    patchedSource = result.source
                    changedRegions = mergedChangedRegions(changedRegions, result.changedRegions)
                    finalResult = result
                }
                return .patched(AmigaProgramPatchResult(
                    source: finalResult.source,
                    model: finalResult.model,
                    changedRegions: changedRegions
                ))
            case .rejected(let reasons):
                try verifyCurrentSourceBeforePatching(source)
                return .rejected(reasons)
            case .notRecognized:
                break
            }
            switch modRemovalBehaviorBoundsAndParameterUpdateIntent(from: prompt, model: model) {
            case .request(let label, let behavior, let placement, let updates):
                try verifyCurrentSourceBeforePatching(source)
                let removed = try verified(AmigaProgramPatcher.removeControl(label: label, from: source))
                let behaviorChanged = try verified(AmigaProgramPatcher.changeControlBehavior(
                    label: behavior.label,
                    action: behavior.action,
                    in: removed.source
                ))
                let boundsChanged = try verified(AmigaProgramPatcher.updateControlBounds(
                    label: placement.label,
                    bounds: placement.bounds,
                    in: behaviorChanged.source
                ))
                var patchedSource = boundsChanged.source
                var changedRegions = mergedChangedRegions(removed.changedRegions, behaviorChanged.changedRegions, boundsChanged.changedRegions)
                var finalResult: AmigaProgramPatchResult = boundsChanged
                for update in updates {
                    let result = try verified(modParameterPatchResult(for: update, in: patchedSource))
                    patchedSource = result.source
                    changedRegions = mergedChangedRegions(changedRegions, result.changedRegions)
                    finalResult = result
                }
                return .patched(AmigaProgramPatchResult(
                    source: finalResult.source,
                    model: finalResult.model,
                    changedRegions: changedRegions
                ))
            case .rejected(let reasons):
                try verifyCurrentSourceBeforePatching(source)
                return .rejected(reasons)
            case .notRecognized:
                break
            }
            switch modRemovalBehaviorMoveAndParameterUpdateIntent(from: prompt, model: model) {
            case .request(let label, let behavior, let moveClause, let updates):
                try verifyCurrentSourceBeforePatching(source)
                let removed = try verified(AmigaProgramPatcher.removeControl(label: label, from: source))
                let behaviorChanged = try verified(AmigaProgramPatcher.changeControlBehavior(
                    label: behavior.label,
                    action: behavior.action,
                    in: removed.source
                ))
                if let rejection = ordinalControlMoveRejection(from: moveClause, model: behaviorChanged.model) ??
                    ambiguousControlMoveRejection(from: moveClause, model: behaviorChanged.model) {
                    return .rejected([rejection])
                }
                guard let move = moveControlRequest(from: moveClause, model: behaviorChanged.model) else {
                    return .rejected(["Specify one control move after removing and changing behavior."])
                }
                let moved = try verified(AmigaProgramPatcher.moveControl(
                    label: move.label,
                    placement: move.placement,
                    targetLabel: move.targetLabel,
                    in: behaviorChanged.source
                ))
                var patchedSource = moved.source
                var changedRegions = mergedChangedRegions(removed.changedRegions, behaviorChanged.changedRegions, moved.changedRegions)
                var finalResult: AmigaProgramPatchResult = moved
                for update in updates {
                    let result = try verified(modParameterPatchResult(for: update, in: patchedSource))
                    patchedSource = result.source
                    changedRegions = mergedChangedRegions(changedRegions, result.changedRegions)
                    finalResult = result
                }
                return .patched(AmigaProgramPatchResult(
                    source: finalResult.source,
                    model: finalResult.model,
                    changedRegions: changedRegions
                ))
            case .rejected(let reasons):
                try verifyCurrentSourceBeforePatching(source)
                return .rejected(reasons)
            case .notRecognized:
                break
            }
            switch modRemovalBehaviorAndParameterUpdateIntent(from: prompt, model: model) {
            case .request(let label, let behavior, let updates):
                try verifyCurrentSourceBeforePatching(source)
                let removed = try verified(AmigaProgramPatcher.removeControl(label: label, from: source))
                let behaviorChanged = try verified(AmigaProgramPatcher.changeControlBehavior(
                    label: behavior.label,
                    action: behavior.action,
                    in: removed.source
                ))
                var patchedSource = behaviorChanged.source
                var changedRegions = mergedChangedRegions(removed.changedRegions, behaviorChanged.changedRegions)
                var finalResult: AmigaProgramPatchResult = behaviorChanged
                for update in updates {
                    let result = try verified(modParameterPatchResult(for: update, in: patchedSource))
                    patchedSource = result.source
                    changedRegions = mergedChangedRegions(changedRegions, result.changedRegions)
                    finalResult = result
                }
                return .patched(AmigaProgramPatchResult(
                    source: finalResult.source,
                    model: finalResult.model,
                    changedRegions: changedRegions
                ))
            case .rejected(let reasons):
                try verifyCurrentSourceBeforePatching(source)
                return .rejected(reasons)
            case .notRecognized:
                break
            }
            switch modRemovalBoundsAndParameterUpdateIntent(from: prompt, model: model) {
            case .request(let label, let placements, let updates):
                try verifyCurrentSourceBeforePatching(source)
                let removed = try verified(AmigaProgramPatcher.removeControl(label: label, from: source))
                let boundsChanged = try verified(AmigaProgramPatcher.updateControlBounds(placements, in: removed.source))
                var patchedSource = boundsChanged.source
                var changedRegions = mergedChangedRegions(removed.changedRegions, boundsChanged.changedRegions)
                var finalResult: AmigaProgramPatchResult = boundsChanged
                for update in updates {
                    let result = try verified(modParameterPatchResult(for: update, in: patchedSource))
                    patchedSource = result.source
                    changedRegions = mergedChangedRegions(changedRegions, result.changedRegions)
                    finalResult = result
                }
                return .patched(AmigaProgramPatchResult(
                    source: finalResult.source,
                    model: finalResult.model,
                    changedRegions: changedRegions
                ))
            case .rejected(let reasons):
                try verifyCurrentSourceBeforePatching(source)
                return .rejected(reasons)
            case .notRecognized:
                break
            }
            switch modRemovalMoveAndParameterUpdateIntent(from: prompt, model: model) {
            case .request(let label, let move, let updates):
                try verifyCurrentSourceBeforePatching(source)
                let removed = try verified(AmigaProgramPatcher.removeControl(label: label, from: source))
                let moved = try verified(AmigaProgramPatcher.moveControl(
                    label: move.label,
                    placement: move.placement,
                    targetLabel: move.targetLabel,
                    in: removed.source
                ))
                var patchedSource = moved.source
                var changedRegions = mergedChangedRegions(removed.changedRegions, moved.changedRegions)
                var finalResult: AmigaProgramPatchResult = moved
                for update in updates {
                    let result = try verified(modParameterPatchResult(for: update, in: patchedSource))
                    patchedSource = result.source
                    changedRegions = mergedChangedRegions(changedRegions, result.changedRegions)
                    finalResult = result
                }
                return .patched(AmigaProgramPatchResult(
                    source: finalResult.source,
                    model: finalResult.model,
                    changedRegions: changedRegions
                ))
            case .rejected(let reasons):
                try verifyCurrentSourceBeforePatching(source)
                return .rejected(reasons)
            case .notRecognized:
                break
            }
            switch modRemovalBoundsUpdateIntent(from: prompt, model: model) {
            case .request(let label, let placements):
                try verifyCurrentSourceBeforePatching(source)
                let removed = try verified(AmigaProgramPatcher.removeControl(label: label, from: source))
                let boundsChanged = try verified(AmigaProgramPatcher.updateControlBounds(placements, in: removed.source))
                return .patched(AmigaProgramPatchResult(
                    source: boundsChanged.source,
                    model: boundsChanged.model,
                    changedRegions: mergedChangedRegions(removed.changedRegions, boundsChanged.changedRegions)
                ))
            case .rejected(let reasons):
                try verifyCurrentSourceBeforePatching(source)
                return .rejected(reasons)
            case .notRecognized:
                break
            }
            switch modRemovalMoveUpdateIntent(from: prompt, model: model) {
            case .request(let label, let move):
                try verifyCurrentSourceBeforePatching(source)
                let removed = try verified(AmigaProgramPatcher.removeControl(label: label, from: source))
                let moved = try verified(AmigaProgramPatcher.moveControl(
                    label: move.label,
                    placement: move.placement,
                    targetLabel: move.targetLabel,
                    in: removed.source
                ))
                return .patched(AmigaProgramPatchResult(
                    source: moved.source,
                    model: moved.model,
                    changedRegions: mergedChangedRegions(removed.changedRegions, moved.changedRegions)
                ))
            case .rejected(let reasons):
                try verifyCurrentSourceBeforePatching(source)
                return .rejected(reasons)
            case .notRecognized:
                break
            }
            switch modRemovalAndParameterUpdateIntent(from: prompt, model: model) {
            case .request(let label, let updates):
                try verifyCurrentSourceBeforePatching(source)
                let removed = try verified(AmigaProgramPatcher.removeControl(label: label, from: source))
                var patchedSource = removed.source
                var changedRegions = removed.changedRegions
                var finalResult: AmigaProgramPatchResult = removed
                for update in updates {
                    let result = try verified(modParameterPatchResult(for: update, in: patchedSource))
                    patchedSource = result.source
                    changedRegions = mergedChangedRegions(changedRegions, result.changedRegions)
                    finalResult = result
                }
                return .patched(AmigaProgramPatchResult(
                    source: finalResult.source,
                    model: finalResult.model,
                    changedRegions: changedRegions
                ))
            case .rejected(let reasons):
                try verifyCurrentSourceBeforePatching(source)
                return .rejected(reasons)
            case .notRecognized:
                break
            }
            switch modMoveAndParameterUpdateIntent(from: prompt, model: model) {
            case .request(let move, let updates):
                try verifyCurrentSourceBeforePatching(source)
                let moved = try verified(AmigaProgramPatcher.moveControl(
                    label: move.label,
                    placement: move.placement,
                    targetLabel: move.targetLabel,
                    in: source
                ))
                var patchedSource = moved.source
                var changedRegions = moved.changedRegions
                var finalResult: AmigaProgramPatchResult = moved
                for update in updates {
                    let result = try verified(modParameterPatchResult(for: update, in: patchedSource))
                    patchedSource = result.source
                    changedRegions = mergedChangedRegions(changedRegions, result.changedRegions)
                    finalResult = result
                }
                return .patched(AmigaProgramPatchResult(
                    source: finalResult.source,
                    model: finalResult.model,
                    changedRegions: changedRegions
                ))
            case .rejected(let reasons):
                try verifyCurrentSourceBeforePatching(source)
                return .rejected(reasons)
            case .notRecognized:
                break
            }
            switch modParameterUpdateIntent(from: prompt) {
            case .request(let updates):
                try verifyCurrentSourceBeforePatching(source)
                var patchedSource = source
                var changedRegions: [String] = []
                var finalResult: AmigaProgramPatchResult?
                for update in updates {
                    let result = try verified(modParameterPatchResult(for: update, in: patchedSource))
                    patchedSource = result.source
                    changedRegions = mergedChangedRegions(changedRegions, result.changedRegions)
                    finalResult = result
                }
                guard let finalResult else { return .notRecognized }
                return .patched(AmigaProgramPatchResult(
                    source: finalResult.source,
                    model: finalResult.model,
                    changedRegions: changedRegions
                ))
            case .rejected(let reasons):
                try verifyCurrentSourceBeforePatching(source)
                return .rejected(reasons)
            case .notRecognized:
                break
            }
            if playbackNoteIntent(from: prompt) {
                try verifyCurrentSourceBeforePatching(source)
                guard let period = playbackNotePeriod(from: prompt) else {
                    return .rejected(["Specify a supported playback note such as C-3."])
                }
                return .patched(try verified(AmigaProgramPatcher.updatePlaybackPeriod(period, in: source)))
            }
            if playbackPeriodIntent(from: prompt) {
                try verifyCurrentSourceBeforePatching(source)
                guard let period = firstInteger(in: prompt) else {
                    return .rejected(["Specify a numeric playback period."])
                }
                return .patched(try verified(AmigaProgramPatcher.updatePlaybackPeriod(period, in: source)))
            }
            if volumeStepIntent(from: prompt) {
                try verifyCurrentSourceBeforePatching(source)
                guard let step = firstInteger(in: prompt) else {
                    return .rejected(["Specify a numeric volume step."])
                }
                return .patched(try verified(AmigaProgramPatcher.updateVolumeStep(step, in: source)))
            }
            if initialVolumeIntent(from: prompt) {
                try verifyCurrentSourceBeforePatching(source)
                guard let volume = initialVolumeValue(from: prompt) else {
                    return .rejected(["Specify a numeric initial volume."])
                }
                return .patched(try verified(AmigaProgramPatcher.updateInitialVolume(volume, in: source)))
            }
            if let rejection = conflictingControlBehaviorChangeRejection(from: prompt, model: model) {
                try verifyCurrentSourceBeforePatching(source)
                return .rejected([rejection])
            }
            if let rejection = duplicateControlLabelAndBehaviorChangeRejection(from: prompt, model: model) {
                try verifyCurrentSourceBeforePatching(source)
                return .rejected([rejection])
            }
            if let request = controlLabelAndBehaviorChangeRequest(from: prompt, model: model) {
                try verifyCurrentSourceBeforePatching(source)
                let behaviorChanged = try verified(AmigaProgramPatcher.changeControlBehavior(
                    label: request.currentLabel,
                    action: request.action,
                    in: source
                ))
                let renamed = try verified(AmigaProgramPatcher.renameControl(
                    currentLabel: request.currentLabel,
                    newLabel: request.newLabel,
                    in: behaviorChanged.source
                ))
                return .patched(AmigaProgramPatchResult(
                    source: renamed.source,
                    model: renamed.model,
                    changedRegions: mergedChangedRegions(behaviorChanged.changedRegions, renamed.changedRegions)
                ))
            }
            if let request = controlBehaviorChangeRequest(from: prompt, model: model) {
                try verifyCurrentSourceBeforePatching(source)
                return .patched(try verified(AmigaProgramPatcher.changeControlBehavior(
                    label: request.label,
                    action: request.action,
                    in: source
                )))
            }
            if let placements = controlGroupBoundsRequest(from: prompt, model: model) {
                try verifyCurrentSourceBeforePatching(source)
                return .patched(try verified(AmigaProgramPatcher.updateControlBounds(placements, in: source)))
            }
            if let request = controlBoundsRequest(from: prompt, model: model) {
                try verifyCurrentSourceBeforePatching(source)
                return .patched(try verified(AmigaProgramPatcher.updateControlBounds(
                    label: request.label,
                    bounds: request.bounds,
                    in: source
                )))
            }
            if let rejection = ambiguousControlBoundsRejection(from: prompt, model: model) {
                try verifyCurrentSourceBeforePatching(source)
                return .rejected([rejection])
            }
            if let rejection = ordinalControlMoveRejection(from: prompt, model: model) {
                try verifyCurrentSourceBeforePatching(source)
                return .rejected([rejection])
            }
            if let request = moveControlRequest(from: prompt, model: model) {
                try verifyCurrentSourceBeforePatching(source)
                return .patched(try verified(AmigaProgramPatcher.moveControl(
                    label: request.label,
                    placement: request.placement,
                    targetLabel: request.targetLabel,
                    in: source
                )))
            }
            if let rejection = ambiguousControlMoveRejection(from: prompt, model: model) {
                try verifyCurrentSourceBeforePatching(source)
                return .rejected([rejection])
            }
            if let rejection = ordinalControlRemovalRejection(from: prompt, model: model) {
                try verifyCurrentSourceBeforePatching(source)
                return .rejected([rejection])
            }
            if let label = removeControlRequest(from: prompt, model: model) {
                try verifyCurrentSourceBeforePatching(source)
                return .patched(try verified(AmigaProgramPatcher.removeControl(label: label, from: source)))
            }
            if let rejection = ambiguousControlRemovalRejection(from: prompt, model: model) {
                try verifyCurrentSourceBeforePatching(source)
                return .rejected([rejection])
            }
            if let rejection = ordinalLabelRenameRejection(from: prompt, model: model) {
                try verifyCurrentSourceBeforePatching(source)
                return .rejected([rejection])
            }
            if let request = labelRenameRequest(from: prompt, model: model) {
                try verifyCurrentSourceBeforePatching(source)
                return .patched(try verified(AmigaProgramPatcher.renameControl(currentLabel: request.currentLabel, newLabel: request.newLabel, in: source)))
            }
            if let rejection = ambiguousLabelRenameRejection(from: prompt, model: model) {
                try verifyCurrentSourceBeforePatching(source)
                return .rejected([rejection])
            }
            if let rejection = duplicateAddControlRequestRejection(from: prompt) {
                try verifyCurrentSourceBeforePatching(source)
                return .rejected([rejection])
            }
            if let rejection = conflictingAddControlRejection(from: prompt) {
                try verifyCurrentSourceBeforePatching(source)
                return .rejected([rejection])
            }
            if let rejection = addControlOrdinalRejection(from: prompt, model: model) {
                try verifyCurrentSourceBeforePatching(source)
                return .rejected([rejection])
            }
            if let requests = addControlRequests(from: prompt) {
                try verifyCurrentSourceBeforePatching(source)
                var patchedSource = source
                var finalResult: AmigaProgramPatchResult?
                var changedRegions: [String] = []
                for request in requests {
                    let result = try verified(AmigaProgramPatcher.addControl(label: request.label, action: request.action, to: patchedSource))
                    patchedSource = result.source
                    finalResult = result
                    changedRegions = mergedChangedRegions(changedRegions, result.changedRegions)
                }
                if var result = finalResult,
                   let placements = addedControlGroupPlacementBounds(
                    in: prompt,
                    addedLabels: requests.map(\.label),
                    model: result.model
                   ) {
                    let placed = try verified(AmigaProgramPatcher.updateControlBounds(placements, in: result.source))
                    result = placed
                    changedRegions = mergedChangedRegions(changedRegions, placed.changedRegions)
                    return .patched(AmigaProgramPatchResult(
                        source: result.source,
                        model: result.model,
                        changedRegions: changedRegions
                    ))
                }
                guard let finalResult else { return .notRecognized }
                return .patched(AmigaProgramPatchResult(
                    source: finalResult.source,
                    model: finalResult.model,
                    changedRegions: changedRegions
                ))
            }
            guard let request = addControlRequest(from: prompt) else {
                if let unsupportedLabel = unsupportedAddControlLabel(from: prompt) {
                    try verifyCurrentSourceBeforePatching(source)
                    let controlID = AmigaProgramPatcher.stableID(from: unsupportedLabel)
                    if model.controls.contains(where: { control in
                        control.id == controlID || control.label.caseInsensitiveCompare(unsupportedLabel) == .orderedSame
                    }) {
                        return .rejected(["A control with id \(controlID) already exists."])
                    }
                    return .rejected([
                        "Unsupported model-backed control \"\(unsupportedLabel)\". Supported controls: Volume Up, Volume Down, Pause, Mute."
                    ])
                }
                return .notRecognized
            }
            try verifyCurrentSourceBeforePatching(source)
            let added = try verified(AmigaProgramPatcher.addControl(label: request.label, action: request.action, to: source))
            if let placement = addedControlPlacementBounds(in: prompt, addedLabel: request.label, model: added.model) {
                let placed = try verified(AmigaProgramPatcher.updateControlBounds(
                    label: placement.label,
                    bounds: placement.bounds,
                    in: added.source
                ))
                return .patched(AmigaProgramPatchResult(
                    source: placed.source,
                    model: placed.model,
                    changedRegions: mergedChangedRegions(added.changedRegions, placed.changedRegions)
                ))
            }
            return .patched(added)
        } catch AmigaProgramPatchError.verificationFailed(let failures) {
            return .rejected(failures)
        } catch {
            return .rejected([patchErrorDescription(error)])
        }
    }

    static func bitplaneColorRequest(from prompt: String) -> (role: String, color: String)? {
        guard case .request(let role, let color) = bitplaneColorIntent(from: prompt) else {
            return nil
        }
        return (role, color)
    }

    static func doubleBufferedBitplaneFollowUpIntent(from prompt: String) -> DoubleBufferedBitplaneFollowUpIntent {
        let normalized = prompt.lowercased()
        let supportedColors = ["white", "yellow", "green", "cyan", "blue", "purple", "magenta", "red", "orange"]
        let hasEditSignal = containsWord("set", in: normalized) ||
            containsWord("change", in: normalized) ||
            containsWord("update", in: normalized) ||
            containsWord("make", in: normalized) ||
            containsWord("slow", in: normalized)
        guard hasEditSignal else { return .notRecognized }

        if containsWord("sprite", in: normalized),
           containsWord("downward", in: normalized) || containsWord("down", in: normalized) {
            return .spriteDownward
        }

        if (containsWord("slow", in: normalized) || containsWord("wait", in: normalized) || containsWord("waiting", in: normalized)),
           containsWord("vblank", in: normalized) || containsWord("vblanks", in: normalized) || containsPhrase("vertical blank", in: normalized) {
            if containsWord("two", in: normalized) || firstInteger(in: normalized) == 2 {
                return .vblankWaits(2)
            }
            return .rejected(["Specify a supported double-buffered vblank wait count: 2."])
        }

        if containsWord("copper", in: normalized),
           containsWord("accent", in: normalized) || containsWord("background", in: normalized) || containsWord("color", in: normalized) || containsWord("colour", in: normalized) {
            for color in supportedColors where containsWord(color, in: normalized) {
                return .copperAccentColor(color)
            }
            return .rejected(["Specify a supported copper accent color: \(supportedColors.joined(separator: ", "))."])
        }

        return .notRecognized
    }

    static func blitterBOBFollowUpIntent(from prompt: String) -> BlitterBOBFollowUpIntent {
        let normalized = prompt.lowercased()
        let supportedColors = ["white", "yellow", "green", "cyan", "blue", "purple", "magenta", "red", "orange"]

        if containsWord("blitter", in: normalized),
           containsWord("start", in: normalized),
           containsWord("without", in: normalized),
           (containsWord("wait", in: normalized) || containsWord("waiting", in: normalized)) {
            return .rejected(["Cannot start the blitter without a DMACONR wait before programming and after BLTSIZE."])
        }
        if containsWord("outside", in: normalized),
           containsWord("bounds", in: normalized) || containsPhrase("screen bounds", in: normalized) {
            return .rejected(["Cannot move the BOB outside the verified screen bounds contract."])
        }
        if containsWord("negative", in: normalized),
           containsPhrase("blit size", in: normalized) || containsWord("bltsize", in: normalized) {
            return .rejected(["Cannot use a negative BLTSIZE; the blitter size field must remain positive and hardware-valid."])
        }
        if containsWord("remove", in: normalized),
           containsWord("mask", in: normalized),
           containsWord("masked", in: normalized) || containsWord("collision", in: normalized) {
            return .rejected(["Cannot remove the BOB mask while preserving the masked collision contract."])
        }

        let hasEditSignal = containsWord("make", in: normalized) ||
            containsWord("move", in: normalized) ||
            containsWord("change", in: normalized) ||
            containsWord("set", in: normalized) ||
            containsWord("update", in: normalized) ||
            containsWord("add", in: normalized)
        guard hasEditSignal else { return .notRecognized }

        if (containsWord("keyboard", in: normalized) || containsWord("joystick", in: normalized)),
           (containsWord("direction", in: normalized) || containsWord("movement", in: normalized) || containsWord("control", in: normalized)) {
            return .directionControl
        }

        if containsWord("faster", in: normalized),
           containsWord("horizontally", in: normalized) || containsWord("horizontal", in: normalized),
           containsWord("object", in: normalized) || containsWord("bob", in: normalized) {
            return .horizontalSpeed(4)
        }
        if containsWord("target", in: normalized) || containsWord("rectangle", in: normalized),
           containsPhrase("right side", in: normalized) || containsWord("right", in: normalized) {
            return .targetRectangle(left: 208, right: 256)
        }
        if containsWord("collision", in: normalized),
           containsWord("color", in: normalized) || containsWord("colour", in: normalized) {
            for color in supportedColors where containsWord(color, in: normalized) {
                return .collisionColor(color)
            }
            return .rejected(["Specify a supported collision color: \(supportedColors.joined(separator: ", "))."])
        }

        return .notRecognized
    }

    static func mouseSpriteMultiplexFollowUpIntent(from prompt: String) -> MouseSpriteMultiplexFollowUpIntent {
        let normalized = prompt.lowercased()
        let supportedColors = ["white", "yellow", "green", "cyan", "blue", "purple", "magenta", "red", "orange"]

        if (containsWord("sprite", in: normalized) || containsWord("sprites", in: normalized)) &&
            (containsPhrase("outside chip memory", in: normalized) || containsPhrase("outside chip", in: normalized)) {
            return .rejected(["Cannot write sprite pointers outside chip memory."])
        }
        if (containsWord("remove", in: normalized) || containsWord("delete", in: normalized)) &&
            (containsWord("second", in: normalized) || containsWord("follower", in: normalized) || containsWord("multiplex", in: normalized)) &&
            (containsWord("sprite", in: normalized) || containsWord("copy", in: normalized)) {
            return .rejected(["Cannot remove the second sprite while preserving the multiplex contract."])
        }
        if (containsWord("outside", in: normalized) || containsWord("without", in: normalized)) &&
            (containsWord("vblank", in: normalized) || containsPhrase("vertical blank", in: normalized)) &&
            (containsWord("sprite", in: normalized) || containsWord("sprites", in: normalized)) {
            return .rejected(["Cannot update multiplexed sprite control words outside the vblank-paced path."])
        }

        let hasEditSignal = containsWord("set", in: normalized) ||
            containsWord("change", in: normalized) ||
            containsWord("update", in: normalized) ||
            containsWord("make", in: normalized) ||
            containsWord("adjust", in: normalized) ||
            containsWord("add", in: normalized) ||
            containsWord("enable", in: normalized)
        guard hasEditSignal else { return .notRecognized }

        if (containsWord("follower", in: normalized) || containsWord("second", in: normalized) || containsWord("copy", in: normalized)) &&
            containsWord("offset", in: normalized) {
            guard let offset = firstInteger(in: normalized) else {
                return .rejected(["Specify a numeric follower offset."])
            }
            return .followerOffset(offset)
        }

        if (containsWord("wrap", in: normalized) || containsWord("wrapping", in: normalized)) &&
            (containsWord("horizontal", in: normalized) || containsWord("horizontally", in: normalized) || containsWord("follower", in: normalized) || containsWord("sprite", in: normalized)) {
            let disabling = containsWord("disable", in: normalized) ||
                containsPhrase("turn off", in: normalized) ||
                containsWord("remove", in: normalized) ||
                containsPhrase("without wrapping", in: normalized)
            return .horizontalWrapping(!disabling)
        }

        if (containsWord("lag", in: normalized) || containsPhrase("one frame", in: normalized) || containsPhrase("one-frame", in: normalized)) &&
            (containsWord("follower", in: normalized) || containsWord("second", in: normalized) || containsWord("copy", in: normalized)) {
            let disabling = containsWord("disable", in: normalized) ||
                containsPhrase("turn off", in: normalized) ||
                containsWord("remove", in: normalized) ||
                containsPhrase("without lag", in: normalized)
            return .followerLag(!disabling)
        }

        if containsWord("sprite", in: normalized) || containsWord("sprites", in: normalized) {
            for color in supportedColors where containsWord(color, in: normalized) {
                return .spriteColor(color)
            }
            if containsWord("color", in: normalized) || containsWord("colour", in: normalized) {
                return .rejected(["Specify a supported sprite color: \(supportedColors.joined(separator: ", "))."])
            }
        }

        return .notRecognized
    }

    static func copperRasterFollowUpIntent(from prompt: String) -> CopperRasterFollowUpIntent {
        let normalized = prompt.lowercased()

        if (containsWord("wait", in: normalized) || containsPhrase("copper wait", in: normalized)) &&
            (containsPhrase("past the end", in: normalized) || containsPhrase("end of display", in: normalized) || containsWord("outside", in: normalized)) {
            return .rejected(["Cannot create copper WAIT positions past the verified display range."])
        }
        if containsWord("odd", in: normalized),
           (containsPhrase("copper instruction", in: normalized) || containsWord("address", in: normalized)) {
            return .rejected(["Cannot use an odd copper instruction address; copper list words must remain word-aligned."])
        }
        if (containsWord("remove", in: normalized) || containsWord("delete", in: normalized)) &&
            (containsWord("copjmp1", in: normalized) || containsPhrase("copper jump", in: normalized)) {
            return .rejected(["Cannot remove COPJMP1 while preserving the owned copper-list activation contract."])
        }
        if (containsWord("zero", in: normalized) || containsPhrase("no bars", in: normalized)) &&
            (containsWord("bar", in: normalized) || containsWord("bars", in: normalized)) {
            return .rejected(["Cannot set zero bars; at least six visible copper bands are required for runtime evidence."])
        }

        let hasEditSignal = containsWord("set", in: normalized) ||
            containsWord("change", in: normalized) ||
            containsWord("update", in: normalized) ||
            containsWord("make", in: normalized) ||
            containsWord("add", in: normalized) ||
            containsWord("increase", in: normalized)
        guard hasEditSignal else { return .notRecognized }

        if containsWord("bar", in: normalized) || containsWord("bars", in: normalized) {
            if containsWord("eight", in: normalized) || firstInteger(in: normalized) == 8 {
                return .barCount(8)
            }
            if let count = firstInteger(in: normalized), count <= 0 {
                return .rejected(["Cannot set zero bars; at least six visible copper bands are required for runtime evidence."])
            }
        }

        if (containsWord("slower", in: normalized) || containsPhrase("bounce slower", in: normalized)) &&
            (containsWord("bounce", in: normalized) || containsWord("bars", in: normalized)) {
            return .bounceStep(1)
        }

        if (containsWord("palette", in: normalized) || containsWord("color", in: normalized) || containsWord("colour", in: normalized)) &&
            containsWord("blue", in: normalized) &&
            containsWord("white", in: normalized) {
            return .blueWhitePalette
        }

        if containsPhrase("top status band", in: normalized) ||
            (containsWord("status", in: normalized) && containsWord("band", in: normalized)) {
            return .topStatusBand
        }

        return .notRecognized
    }

    static func bitplaneColorIntent(from prompt: String) -> BitplaneColorIntent {
        let normalized = prompt.lowercased()
        let hasEditSignal = containsWord("set", in: normalized) ||
            containsWord("change", in: normalized) ||
            containsWord("update", in: normalized) ||
            containsWord("make", in: normalized)
        guard hasEditSignal else { return .notRecognized }

        let supportedColors = ["white", "yellow", "green", "cyan", "blue", "purple", "magenta", "red", "orange"]
        let mentionsFront = containsWord("front", in: normalized)
        let mentionsBack = containsWord("back", in: normalized)
        guard mentionsFront || mentionsBack else {
            return .notRecognized
        }
        if mentionsFront && mentionsBack {
            if let requests = multiRoleBitplaneColorRequests(in: normalized, supportedColors: supportedColors) {
                return .requests(requests)
            }
            return .conflictingRoles(["front", "back"])
        }

        let role: String
        if mentionsFront {
            role = "front"
        } else {
            role = "back"
        }

        for color in supportedColors
            where containsWord(color, in: normalized) {
            return .request(role: role, color: color)
        }
        let trimmed = normalized.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.hasSuffix(" color") ||
            trimmed.hasSuffix(" to color") ||
            trimmed.hasSuffix(" color to") ||
            trimmed.hasSuffix(" buffer color") ||
            trimmed.hasSuffix(" buffer color to") ||
            trimmed.hasSuffix(" to") {
            return .missingColor(role: role)
        }
        return .unsupported(role: role, supportedColors: supportedColors)
    }

    private struct PromptToken {
        let text: String
        let location: Int
    }

    private static func multiRoleBitplaneColorRequests(in normalizedPrompt: String, supportedColors: [String]) -> [BitplaneColorRequest]? {
        let tokens = promptTokens(in: normalizedPrompt)
        guard let frontLocation = tokens.first(where: { $0.text == "front" })?.location,
              let backLocation = tokens.first(where: { $0.text == "back" })?.location else {
            return nil
        }

        let colorTokens = tokens.filter { supportedColors.contains($0.text) }
        guard !colorTokens.isEmpty else { return nil }
        if colorTokens.count == 1,
           let sharedColor = colorTokens.first,
           sharedColor.location > max(frontLocation, backLocation) {
            return [
                BitplaneColorRequest(role: "front", color: sharedColor.text),
                BitplaneColorRequest(role: "back", color: sharedColor.text)
            ]
        }

        guard let frontColor = colorAfterRole(
            "front",
            beforeOtherRole: "back",
            tokens: tokens,
            supportedColors: supportedColors
        ),
              let backColor = colorAfterRole(
                "back",
                beforeOtherRole: "front",
                tokens: tokens,
                supportedColors: supportedColors
              ) else {
            return nil
        }
        return [
            BitplaneColorRequest(role: "front", color: frontColor),
            BitplaneColorRequest(role: "back", color: backColor)
        ]
    }

    private static func colorAfterRole(_ role: String, beforeOtherRole otherRole: String, tokens: [PromptToken], supportedColors: [String]) -> String? {
        guard let roleIndex = tokens.firstIndex(where: { $0.text == role }) else { return nil }
        let otherIndex = tokens[(roleIndex + 1)...].firstIndex { $0.text == otherRole } ?? tokens.endIndex
        guard roleIndex + 1 < otherIndex else { return nil }
        return tokens[(roleIndex + 1)..<otherIndex]
            .first { supportedColors.contains($0.text) }?
            .text
    }

    private static func promptTokens(in normalizedPrompt: String) -> [PromptToken] {
        guard let regex = try? NSRegularExpression(pattern: #"[a-z0-9]+"#) else { return [] }
        let range = NSRange(normalizedPrompt.startIndex..<normalizedPrompt.endIndex, in: normalizedPrompt)
        return regex.matches(in: normalizedPrompt, range: range).compactMap { match in
            guard let matchRange = Range(match.range, in: normalizedPrompt) else { return nil }
            return PromptToken(text: String(normalizedPrompt[matchRange]), location: match.range.location)
        }
    }

    private static func containsWord(_ word: String, in normalizedPrompt: String) -> Bool {
        normalizedPrompt
            .split { !$0.isLetter && !$0.isNumber }
            .contains { $0 == word }
    }

    static func recognizesPatchRequest(prompt: String, source: String) -> Bool {
        switch patchOutcome(prompt: prompt, source: source) {
        case .patched, .rejected:
            return true
        case .notRecognized:
            return false
        }
    }

    private static func verifyCurrentSourceBeforePatching(_ source: String) throws {
        let failures = AmigaProgramSourceVerifier.failures(in: source)
        guard failures.isEmpty else {
            throw AmigaProgramPatchError.verificationFailed(failures)
        }
    }

    private static func verified(_ result: AmigaProgramPatchResult) throws -> AmigaProgramPatchResult {
        let failures = AmigaProgramSourceVerifier.failures(in: result.source)
        guard failures.isEmpty else {
            throw AmigaProgramPatchError.verificationFailed(failures)
        }
        return result
    }

    private static func mergedChangedRegions(_ regions: [String]...) -> [String] {
        var merged: [String] = []
        for region in regions.flatMap({ $0 }) where !merged.contains(region) {
            merged.append(region)
        }
        return merged
    }

    private static func patchErrorDescription(_ error: Error) -> String {
        if let localizedError = error as? LocalizedError,
           let description = localizedError.errorDescription {
            return description
        }
        return error.localizedDescription
    }

    private enum ModParameterUpdate: Equatable {
        case playbackPeriod(Int)
        case volumeStep(Int)
        case initialVolume(Int)

        var target: String {
            switch self {
            case .playbackPeriod:
                return "playback period"
            case .volumeStep:
                return "volume step"
            case .initialVolume:
                return "initial volume"
            }
        }
    }

    private enum ModParameterUpdateIntent: Equatable {
        case request([ModParameterUpdate])
        case rejected([String])
        case notRecognized
    }

    private enum ModParameterClauseIntent: Equatable {
        case update(ModParameterUpdate)
        case rejected(String)
        case notRecognized
    }

    private enum ModControlAndParameterUpdateIntent: Equatable {
        case request(controls: [(label: String, action: String)], updates: [ModParameterUpdate])
        case rejected([String])
        case notRecognized

        static func == (lhs: ModControlAndParameterUpdateIntent, rhs: ModControlAndParameterUpdateIntent) -> Bool {
            switch (lhs, rhs) {
            case (.notRecognized, .notRecognized):
                return true
            case (.rejected(let lhsReasons), .rejected(let rhsReasons)):
                return lhsReasons == rhsReasons
            case (.request(let lhsControls, let lhsUpdates), .request(let rhsControls, let rhsUpdates)):
                return lhsControls.map(\.label) == rhsControls.map(\.label) &&
                    lhsControls.map(\.action) == rhsControls.map(\.action) &&
                    lhsUpdates == rhsUpdates
            default:
                return false
            }
        }
    }

    private enum ModControlMoveAndParameterUpdateIntent: Equatable {
        case request(controls: [(label: String, action: String)], moveClause: String, updates: [ModParameterUpdate])
        case rejected([String])
        case notRecognized

        static func == (lhs: ModControlMoveAndParameterUpdateIntent, rhs: ModControlMoveAndParameterUpdateIntent) -> Bool {
            switch (lhs, rhs) {
            case (.notRecognized, .notRecognized):
                return true
            case (.rejected(let lhsReasons), .rejected(let rhsReasons)):
                return lhsReasons == rhsReasons
            case (.request(let lhsControls, let lhsMoveClause, let lhsUpdates),
                  .request(let rhsControls, let rhsMoveClause, let rhsUpdates)):
                return lhsControls.map(\.label) == rhsControls.map(\.label) &&
                    lhsControls.map(\.action) == rhsControls.map(\.action) &&
                    lhsMoveClause == rhsMoveClause &&
                    lhsUpdates == rhsUpdates
            default:
                return false
            }
        }
    }

    private enum ModRenameAndParameterUpdateIntent: Equatable {
        case request(rename: (currentLabel: String, newLabel: String), updates: [ModParameterUpdate])
        case rejected([String])
        case notRecognized

        static func == (lhs: ModRenameAndParameterUpdateIntent, rhs: ModRenameAndParameterUpdateIntent) -> Bool {
            switch (lhs, rhs) {
            case (.notRecognized, .notRecognized):
                return true
            case (.rejected(let lhsReasons), .rejected(let rhsReasons)):
                return lhsReasons == rhsReasons
            case (.request(let lhsRename, let lhsUpdates), .request(let rhsRename, let rhsUpdates)):
                return lhsRename.currentLabel == rhsRename.currentLabel &&
                    lhsRename.newLabel == rhsRename.newLabel &&
                    lhsUpdates == rhsUpdates
            default:
                return false
            }
        }
    }

    private enum ModRenameBoundsAndParameterUpdateIntent: Equatable {
        case request(
            rename: (currentLabel: String, newLabel: String),
            placement: (label: String, bounds: AmigaProgramModel.Bounds),
            updates: [ModParameterUpdate]
        )
        case rejected([String])
        case notRecognized

        static func == (lhs: ModRenameBoundsAndParameterUpdateIntent, rhs: ModRenameBoundsAndParameterUpdateIntent) -> Bool {
            switch (lhs, rhs) {
            case (.notRecognized, .notRecognized):
                return true
            case (.rejected(let lhsReasons), .rejected(let rhsReasons)):
                return lhsReasons == rhsReasons
            case (.request(let lhsRename, let lhsPlacement, let lhsUpdates),
                  .request(let rhsRename, let rhsPlacement, let rhsUpdates)):
                return lhsRename.currentLabel == rhsRename.currentLabel &&
                    lhsRename.newLabel == rhsRename.newLabel &&
                    lhsPlacement.label == rhsPlacement.label &&
                    lhsPlacement.bounds == rhsPlacement.bounds &&
                    lhsUpdates == rhsUpdates
            default:
                return false
            }
        }
    }

    private enum ModRenameBoundsUpdateIntent: Equatable {
        case request(
            rename: (currentLabel: String, newLabel: String),
            placement: (label: String, bounds: AmigaProgramModel.Bounds)
        )
        case rejected([String])
        case notRecognized

        static func == (lhs: ModRenameBoundsUpdateIntent, rhs: ModRenameBoundsUpdateIntent) -> Bool {
            switch (lhs, rhs) {
            case (.notRecognized, .notRecognized):
                return true
            case (.rejected(let lhsReasons), .rejected(let rhsReasons)):
                return lhsReasons == rhsReasons
            case (.request(let lhsRename, let lhsPlacement), .request(let rhsRename, let rhsPlacement)):
                return lhsRename.currentLabel == rhsRename.currentLabel &&
                    lhsRename.newLabel == rhsRename.newLabel &&
                    lhsPlacement.label == rhsPlacement.label &&
                    lhsPlacement.bounds == rhsPlacement.bounds
            default:
                return false
            }
        }
    }

    private enum ModRenameBoundsMoveAndParameterUpdateIntent: Equatable {
        case request(
            rename: (currentLabel: String, newLabel: String),
            placement: (label: String, bounds: AmigaProgramModel.Bounds),
            moveClause: String,
            updates: [ModParameterUpdate]
        )
        case rejected([String])
        case notRecognized

        static func == (lhs: ModRenameBoundsMoveAndParameterUpdateIntent, rhs: ModRenameBoundsMoveAndParameterUpdateIntent) -> Bool {
            switch (lhs, rhs) {
            case (.notRecognized, .notRecognized):
                return true
            case (.rejected(let lhsReasons), .rejected(let rhsReasons)):
                return lhsReasons == rhsReasons
            case (.request(let lhsRename, let lhsPlacement, let lhsMoveClause, let lhsUpdates),
                  .request(let rhsRename, let rhsPlacement, let rhsMoveClause, let rhsUpdates)):
                return lhsRename.currentLabel == rhsRename.currentLabel &&
                    lhsRename.newLabel == rhsRename.newLabel &&
                    lhsPlacement.label == rhsPlacement.label &&
                    lhsPlacement.bounds == rhsPlacement.bounds &&
                    lhsMoveClause == rhsMoveClause &&
                    lhsUpdates == rhsUpdates
            default:
                return false
            }
        }
    }

    private enum ModRenameMoveAndParameterUpdateIntent: Equatable {
        case request(
            rename: (currentLabel: String, newLabel: String),
            moveClause: String,
            updates: [ModParameterUpdate]
        )
        case rejected([String])
        case notRecognized

        static func == (lhs: ModRenameMoveAndParameterUpdateIntent, rhs: ModRenameMoveAndParameterUpdateIntent) -> Bool {
            switch (lhs, rhs) {
            case (.notRecognized, .notRecognized):
                return true
            case (.rejected(let lhsReasons), .rejected(let rhsReasons)):
                return lhsReasons == rhsReasons
            case (.request(let lhsRename, let lhsMoveClause, let lhsUpdates),
                  .request(let rhsRename, let rhsMoveClause, let rhsUpdates)):
                return lhsRename.currentLabel == rhsRename.currentLabel &&
                    lhsRename.newLabel == rhsRename.newLabel &&
                    lhsMoveClause == rhsMoveClause &&
                    lhsUpdates == rhsUpdates
            default:
                return false
            }
        }
    }

    private enum ModBehaviorAndParameterUpdateIntent: Equatable {
        case request(behavior: (label: String, action: String), updates: [ModParameterUpdate])
        case rejected([String])
        case notRecognized

        static func == (lhs: ModBehaviorAndParameterUpdateIntent, rhs: ModBehaviorAndParameterUpdateIntent) -> Bool {
            switch (lhs, rhs) {
            case (.notRecognized, .notRecognized):
                return true
            case (.rejected(let lhsReasons), .rejected(let rhsReasons)):
                return lhsReasons == rhsReasons
            case (.request(let lhsBehavior, let lhsUpdates), .request(let rhsBehavior, let rhsUpdates)):
                return lhsBehavior.label == rhsBehavior.label &&
                    lhsBehavior.action == rhsBehavior.action &&
                    lhsUpdates == rhsUpdates
            default:
                return false
            }
        }
    }

    private enum ModBehaviorMoveAndParameterUpdateIntent: Equatable {
        case request(
            behavior: (label: String, action: String),
            moveClause: String,
            updates: [ModParameterUpdate]
        )
        case rejected([String])
        case notRecognized

        static func == (lhs: ModBehaviorMoveAndParameterUpdateIntent, rhs: ModBehaviorMoveAndParameterUpdateIntent) -> Bool {
            switch (lhs, rhs) {
            case (.notRecognized, .notRecognized):
                return true
            case (.rejected(let lhsReasons), .rejected(let rhsReasons)):
                return lhsReasons == rhsReasons
            case (.request(let lhsBehavior, let lhsMoveClause, let lhsUpdates),
                  .request(let rhsBehavior, let rhsMoveClause, let rhsUpdates)):
                return lhsBehavior.label == rhsBehavior.label &&
                    lhsBehavior.action == rhsBehavior.action &&
                    lhsMoveClause == rhsMoveClause &&
                    lhsUpdates == rhsUpdates
            default:
                return false
            }
        }
    }

    private enum ModBehaviorBoundsAndParameterUpdateIntent: Equatable {
        case request(
            behavior: (label: String, action: String),
            placement: (label: String, bounds: AmigaProgramModel.Bounds),
            updates: [ModParameterUpdate]
        )
        case rejected([String])
        case notRecognized

        static func == (lhs: ModBehaviorBoundsAndParameterUpdateIntent, rhs: ModBehaviorBoundsAndParameterUpdateIntent) -> Bool {
            switch (lhs, rhs) {
            case (.notRecognized, .notRecognized):
                return true
            case (.rejected(let lhsReasons), .rejected(let rhsReasons)):
                return lhsReasons == rhsReasons
            case (.request(let lhsBehavior, let lhsPlacement, let lhsUpdates),
                  .request(let rhsBehavior, let rhsPlacement, let rhsUpdates)):
                return lhsBehavior.label == rhsBehavior.label &&
                    lhsBehavior.action == rhsBehavior.action &&
                    lhsPlacement.label == rhsPlacement.label &&
                    lhsPlacement.bounds == rhsPlacement.bounds &&
                    lhsUpdates == rhsUpdates
            default:
                return false
            }
        }
    }

    private enum ModLabelBehaviorAndParameterUpdateIntent: Equatable {
        case request(change: (currentLabel: String, newLabel: String, action: String), updates: [ModParameterUpdate])
        case rejected([String])
        case notRecognized

        static func == (lhs: ModLabelBehaviorAndParameterUpdateIntent, rhs: ModLabelBehaviorAndParameterUpdateIntent) -> Bool {
            switch (lhs, rhs) {
            case (.notRecognized, .notRecognized):
                return true
            case (.rejected(let lhsReasons), .rejected(let rhsReasons)):
                return lhsReasons == rhsReasons
            case (.request(let lhsChange, let lhsUpdates), .request(let rhsChange, let rhsUpdates)):
                return lhsChange.currentLabel == rhsChange.currentLabel &&
                    lhsChange.newLabel == rhsChange.newLabel &&
                    lhsChange.action == rhsChange.action &&
                    lhsUpdates == rhsUpdates
            default:
                return false
            }
        }
    }

    private enum ModBehaviorBoundsMoveAndParameterUpdateIntent: Equatable {
        case request(
            behavior: (label: String, action: String),
            placement: (label: String, bounds: AmigaProgramModel.Bounds),
            moveClause: String,
            updates: [ModParameterUpdate]
        )
        case rejected([String])
        case notRecognized

        static func == (lhs: ModBehaviorBoundsMoveAndParameterUpdateIntent, rhs: ModBehaviorBoundsMoveAndParameterUpdateIntent) -> Bool {
            switch (lhs, rhs) {
            case (.notRecognized, .notRecognized):
                return true
            case (.rejected(let lhsReasons), .rejected(let rhsReasons)):
                return lhsReasons == rhsReasons
            case (.request(let lhsBehavior, let lhsPlacement, let lhsMoveClause, let lhsUpdates),
                  .request(let rhsBehavior, let rhsPlacement, let rhsMoveClause, let rhsUpdates)):
                return lhsBehavior.label == rhsBehavior.label &&
                    lhsBehavior.action == rhsBehavior.action &&
                    lhsPlacement.label == rhsPlacement.label &&
                    lhsPlacement.bounds == rhsPlacement.bounds &&
                    lhsMoveClause == rhsMoveClause &&
                    lhsUpdates == rhsUpdates
            default:
                return false
            }
        }
    }

    private enum ModLabelBehaviorMoveAndParameterUpdateIntent: Equatable {
        case request(
            change: (currentLabel: String, newLabel: String, action: String),
            moveClause: String,
            updates: [ModParameterUpdate]
        )
        case rejected([String])
        case notRecognized

        static func == (
            lhs: ModLabelBehaviorMoveAndParameterUpdateIntent,
            rhs: ModLabelBehaviorMoveAndParameterUpdateIntent
        ) -> Bool {
            switch (lhs, rhs) {
            case (.notRecognized, .notRecognized):
                return true
            case (.rejected(let lhsReasons), .rejected(let rhsReasons)):
                return lhsReasons == rhsReasons
            case (.request(let lhsChange, let lhsMoveClause, let lhsUpdates),
                  .request(let rhsChange, let rhsMoveClause, let rhsUpdates)):
                return lhsChange.currentLabel == rhsChange.currentLabel &&
                    lhsChange.newLabel == rhsChange.newLabel &&
                    lhsChange.action == rhsChange.action &&
                    lhsMoveClause == rhsMoveClause &&
                    lhsUpdates == rhsUpdates
            default:
                return false
            }
        }
    }

    private enum ModLabelBehaviorBoundsAndParameterUpdateIntent: Equatable {
        case request(
            change: (currentLabel: String, newLabel: String, action: String),
            placement: (label: String, bounds: AmigaProgramModel.Bounds),
            updates: [ModParameterUpdate]
        )
        case rejected([String])
        case notRecognized

        static func == (
            lhs: ModLabelBehaviorBoundsAndParameterUpdateIntent,
            rhs: ModLabelBehaviorBoundsAndParameterUpdateIntent
        ) -> Bool {
            switch (lhs, rhs) {
            case (.notRecognized, .notRecognized):
                return true
            case (.rejected(let lhsReasons), .rejected(let rhsReasons)):
                return lhsReasons == rhsReasons
            case (.request(let lhsChange, let lhsPlacement, let lhsUpdates),
                  .request(let rhsChange, let rhsPlacement, let rhsUpdates)):
                return lhsChange.currentLabel == rhsChange.currentLabel &&
                    lhsChange.newLabel == rhsChange.newLabel &&
                    lhsChange.action == rhsChange.action &&
                    lhsPlacement.label == rhsPlacement.label &&
                    lhsPlacement.bounds == rhsPlacement.bounds &&
                    lhsUpdates == rhsUpdates
            default:
                return false
            }
        }
    }

    private enum ModLabelBehaviorBoundsMoveAndParameterUpdateIntent: Equatable {
        case request(
            change: (currentLabel: String, newLabel: String, action: String),
            placement: (label: String, bounds: AmigaProgramModel.Bounds),
            moveClause: String,
            updates: [ModParameterUpdate]
        )
        case rejected([String])
        case notRecognized

        static func == (
            lhs: ModLabelBehaviorBoundsMoveAndParameterUpdateIntent,
            rhs: ModLabelBehaviorBoundsMoveAndParameterUpdateIntent
        ) -> Bool {
            switch (lhs, rhs) {
            case (.notRecognized, .notRecognized):
                return true
            case (.rejected(let lhsReasons), .rejected(let rhsReasons)):
                return lhsReasons == rhsReasons
            case (.request(let lhsChange, let lhsPlacement, let lhsMoveClause, let lhsUpdates),
                  .request(let rhsChange, let rhsPlacement, let rhsMoveClause, let rhsUpdates)):
                return lhsChange.currentLabel == rhsChange.currentLabel &&
                    lhsChange.newLabel == rhsChange.newLabel &&
                    lhsChange.action == rhsChange.action &&
                    lhsPlacement.label == rhsPlacement.label &&
                    lhsPlacement.bounds == rhsPlacement.bounds &&
                    lhsMoveClause == rhsMoveClause &&
                    lhsUpdates == rhsUpdates
            default:
                return false
            }
        }
    }

    private enum ModLabelBehaviorAndBoundsUpdateIntent: Equatable {
        case request(
            change: (currentLabel: String, newLabel: String, action: String),
            placement: (label: String, bounds: AmigaProgramModel.Bounds)
        )
        case rejected([String])
        case notRecognized

        static func == (lhs: ModLabelBehaviorAndBoundsUpdateIntent, rhs: ModLabelBehaviorAndBoundsUpdateIntent) -> Bool {
            switch (lhs, rhs) {
            case (.notRecognized, .notRecognized):
                return true
            case (.rejected(let lhsReasons), .rejected(let rhsReasons)):
                return lhsReasons == rhsReasons
            case (.request(let lhsChange, let lhsPlacement), .request(let rhsChange, let rhsPlacement)):
                return lhsChange.currentLabel == rhsChange.currentLabel &&
                    lhsChange.newLabel == rhsChange.newLabel &&
                    lhsChange.action == rhsChange.action &&
                    lhsPlacement.label == rhsPlacement.label &&
                    lhsPlacement.bounds == rhsPlacement.bounds
            default:
                return false
            }
        }
    }

    private enum ModBoundsAndParameterUpdateIntent: Equatable {
        case request(placements: [(label: String, bounds: AmigaProgramModel.Bounds)], updates: [ModParameterUpdate])
        case rejected([String])
        case notRecognized

        static func == (lhs: ModBoundsAndParameterUpdateIntent, rhs: ModBoundsAndParameterUpdateIntent) -> Bool {
            switch (lhs, rhs) {
            case (.notRecognized, .notRecognized):
                return true
            case (.rejected(let lhsReasons), .rejected(let rhsReasons)):
                return lhsReasons == rhsReasons
            case (.request(let lhsPlacements, let lhsUpdates), .request(let rhsPlacements, let rhsUpdates)):
                return lhsPlacements.map(\.label) == rhsPlacements.map(\.label) &&
                    lhsPlacements.map(\.bounds) == rhsPlacements.map(\.bounds) &&
                    lhsUpdates == rhsUpdates
            default:
                return false
            }
        }
    }

    private enum ModBoundsMoveAndParameterUpdateIntent: Equatable {
        case request(
            placements: [(label: String, bounds: AmigaProgramModel.Bounds)],
            move: (label: String, placement: AmigaProgramControlPlacement, targetLabel: String),
            updates: [ModParameterUpdate]
        )
        case rejected([String])
        case notRecognized

        static func == (lhs: ModBoundsMoveAndParameterUpdateIntent, rhs: ModBoundsMoveAndParameterUpdateIntent) -> Bool {
            switch (lhs, rhs) {
            case (.notRecognized, .notRecognized):
                return true
            case (.rejected(let lhsReasons), .rejected(let rhsReasons)):
                return lhsReasons == rhsReasons
            case (.request(let lhsPlacements, let lhsMove, let lhsUpdates),
                  .request(let rhsPlacements, let rhsMove, let rhsUpdates)):
                return lhsPlacements.map(\.label) == rhsPlacements.map(\.label) &&
                    lhsPlacements.map(\.bounds) == rhsPlacements.map(\.bounds) &&
                    lhsMove.label == rhsMove.label &&
                    lhsMove.placement == rhsMove.placement &&
                    lhsMove.targetLabel == rhsMove.targetLabel &&
                    lhsUpdates == rhsUpdates
            default:
                return false
            }
        }
    }

    private enum ModRemovalBoundsAndParameterUpdateIntent: Equatable {
        case request(label: String, placements: [(label: String, bounds: AmigaProgramModel.Bounds)], updates: [ModParameterUpdate])
        case rejected([String])
        case notRecognized

        static func == (lhs: ModRemovalBoundsAndParameterUpdateIntent, rhs: ModRemovalBoundsAndParameterUpdateIntent) -> Bool {
            switch (lhs, rhs) {
            case (.notRecognized, .notRecognized):
                return true
            case (.rejected(let lhsReasons), .rejected(let rhsReasons)):
                return lhsReasons == rhsReasons
            case (.request(let lhsLabel, let lhsPlacements, let lhsUpdates),
                  .request(let rhsLabel, let rhsPlacements, let rhsUpdates)):
                return lhsLabel == rhsLabel &&
                    lhsPlacements.map(\.label) == rhsPlacements.map(\.label) &&
                    lhsPlacements.map(\.bounds) == rhsPlacements.map(\.bounds) &&
                    lhsUpdates == rhsUpdates
            default:
                return false
            }
        }
    }

    private enum ModRemovalBoundsUpdateIntent: Equatable {
        case request(label: String, placements: [(label: String, bounds: AmigaProgramModel.Bounds)])
        case rejected([String])
        case notRecognized

        static func == (lhs: ModRemovalBoundsUpdateIntent, rhs: ModRemovalBoundsUpdateIntent) -> Bool {
            switch (lhs, rhs) {
            case (.notRecognized, .notRecognized):
                return true
            case (.rejected(let lhsReasons), .rejected(let rhsReasons)):
                return lhsReasons == rhsReasons
            case (.request(let lhsLabel, let lhsPlacements), .request(let rhsLabel, let rhsPlacements)):
                return lhsLabel == rhsLabel &&
                    lhsPlacements.map(\.label) == rhsPlacements.map(\.label) &&
                    lhsPlacements.map(\.bounds) == rhsPlacements.map(\.bounds)
            default:
                return false
            }
        }
    }

    private enum ModRemovalBoundsMoveAndParameterUpdateIntent: Equatable {
        case request(
            label: String,
            placements: [(label: String, bounds: AmigaProgramModel.Bounds)],
            move: (label: String, placement: AmigaProgramControlPlacement, targetLabel: String),
            updates: [ModParameterUpdate]
        )
        case rejected([String])
        case notRecognized

        static func == (lhs: ModRemovalBoundsMoveAndParameterUpdateIntent, rhs: ModRemovalBoundsMoveAndParameterUpdateIntent) -> Bool {
            switch (lhs, rhs) {
            case (.notRecognized, .notRecognized):
                return true
            case (.rejected(let lhsReasons), .rejected(let rhsReasons)):
                return lhsReasons == rhsReasons
            case (.request(let lhsLabel, let lhsPlacements, let lhsMove, let lhsUpdates),
                  .request(let rhsLabel, let rhsPlacements, let rhsMove, let rhsUpdates)):
                return lhsLabel == rhsLabel &&
                    lhsPlacements.map(\.label) == rhsPlacements.map(\.label) &&
                    lhsPlacements.map(\.bounds) == rhsPlacements.map(\.bounds) &&
                    lhsMove.label == rhsMove.label &&
                    lhsMove.placement == rhsMove.placement &&
                    lhsMove.targetLabel == rhsMove.targetLabel &&
                    lhsUpdates == rhsUpdates
            default:
                return false
            }
        }
    }

    private enum ModRemovalRenameBoundsMoveAndParameterUpdateIntent: Equatable {
        case request(
            label: String,
            rename: (currentLabel: String, newLabel: String),
            placement: (label: String, bounds: AmigaProgramModel.Bounds),
            moveClause: String,
            updates: [ModParameterUpdate]
        )
        case rejected([String])
        case notRecognized

        static func == (
            lhs: ModRemovalRenameBoundsMoveAndParameterUpdateIntent,
            rhs: ModRemovalRenameBoundsMoveAndParameterUpdateIntent
        ) -> Bool {
            switch (lhs, rhs) {
            case (.notRecognized, .notRecognized):
                return true
            case (.rejected(let lhsReasons), .rejected(let rhsReasons)):
                return lhsReasons == rhsReasons
            case (.request(let lhsLabel, let lhsRename, let lhsPlacement, let lhsMoveClause, let lhsUpdates),
                  .request(let rhsLabel, let rhsRename, let rhsPlacement, let rhsMoveClause, let rhsUpdates)):
                return lhsLabel == rhsLabel &&
                    lhsRename.currentLabel == rhsRename.currentLabel &&
                    lhsRename.newLabel == rhsRename.newLabel &&
                    lhsPlacement.label == rhsPlacement.label &&
                    lhsPlacement.bounds == rhsPlacement.bounds &&
                    lhsMoveClause == rhsMoveClause &&
                    lhsUpdates == rhsUpdates
            default:
                return false
            }
        }
    }

    private enum ModRemovalRenameAndParameterUpdateIntent: Equatable {
        case request(label: String, rename: (currentLabel: String, newLabel: String), updates: [ModParameterUpdate])
        case rejected([String])
        case notRecognized

        static func == (lhs: ModRemovalRenameAndParameterUpdateIntent, rhs: ModRemovalRenameAndParameterUpdateIntent) -> Bool {
            switch (lhs, rhs) {
            case (.notRecognized, .notRecognized):
                return true
            case (.rejected(let lhsReasons), .rejected(let rhsReasons)):
                return lhsReasons == rhsReasons
            case (.request(let lhsLabel, let lhsRename, let lhsUpdates), .request(let rhsLabel, let rhsRename, let rhsUpdates)):
                return lhsLabel == rhsLabel &&
                    lhsRename.currentLabel == rhsRename.currentLabel &&
                    lhsRename.newLabel == rhsRename.newLabel &&
                    lhsUpdates == rhsUpdates
            default:
                return false
            }
        }
    }

    private enum ModRemovalRenameMoveAndParameterUpdateIntent: Equatable {
        case request(
            label: String,
            rename: (currentLabel: String, newLabel: String),
            moveClause: String,
            updates: [ModParameterUpdate]
        )
        case rejected([String])
        case notRecognized

        static func == (
            lhs: ModRemovalRenameMoveAndParameterUpdateIntent,
            rhs: ModRemovalRenameMoveAndParameterUpdateIntent
        ) -> Bool {
            switch (lhs, rhs) {
            case (.notRecognized, .notRecognized):
                return true
            case (.rejected(let lhsReasons), .rejected(let rhsReasons)):
                return lhsReasons == rhsReasons
            case (.request(let lhsLabel, let lhsRename, let lhsMoveClause, let lhsUpdates),
                  .request(let rhsLabel, let rhsRename, let rhsMoveClause, let rhsUpdates)):
                return lhsLabel == rhsLabel &&
                    lhsRename.currentLabel == rhsRename.currentLabel &&
                    lhsRename.newLabel == rhsRename.newLabel &&
                    lhsMoveClause == rhsMoveClause &&
                    lhsUpdates == rhsUpdates
            default:
                return false
            }
        }
    }

    private enum ModRemovalRenameBoundsAndParameterUpdateIntent: Equatable {
        case request(
            label: String,
            rename: (currentLabel: String, newLabel: String),
            placement: (label: String, bounds: AmigaProgramModel.Bounds),
            updates: [ModParameterUpdate]
        )
        case rejected([String])
        case notRecognized

        static func == (
            lhs: ModRemovalRenameBoundsAndParameterUpdateIntent,
            rhs: ModRemovalRenameBoundsAndParameterUpdateIntent
        ) -> Bool {
            switch (lhs, rhs) {
            case (.notRecognized, .notRecognized):
                return true
            case (.rejected(let lhsReasons), .rejected(let rhsReasons)):
                return lhsReasons == rhsReasons
            case (.request(let lhsLabel, let lhsRename, let lhsPlacement, let lhsUpdates),
                  .request(let rhsLabel, let rhsRename, let rhsPlacement, let rhsUpdates)):
                return lhsLabel == rhsLabel &&
                    lhsRename.currentLabel == rhsRename.currentLabel &&
                    lhsRename.newLabel == rhsRename.newLabel &&
                    lhsPlacement.label == rhsPlacement.label &&
                    lhsPlacement.bounds == rhsPlacement.bounds &&
                    lhsUpdates == rhsUpdates
            default:
                return false
            }
        }
    }

    private enum ModRemovalLabelBehaviorAndParameterUpdateIntent: Equatable {
        case request(
            label: String,
            change: (currentLabel: String, newLabel: String, action: String),
            updates: [ModParameterUpdate]
        )
        case rejected([String])
        case notRecognized

        static func == (
            lhs: ModRemovalLabelBehaviorAndParameterUpdateIntent,
            rhs: ModRemovalLabelBehaviorAndParameterUpdateIntent
        ) -> Bool {
            switch (lhs, rhs) {
            case (.notRecognized, .notRecognized):
                return true
            case (.rejected(let lhsReasons), .rejected(let rhsReasons)):
                return lhsReasons == rhsReasons
            case (.request(let lhsLabel, let lhsChange, let lhsUpdates),
                  .request(let rhsLabel, let rhsChange, let rhsUpdates)):
                return lhsLabel == rhsLabel &&
                    lhsChange.currentLabel == rhsChange.currentLabel &&
                    lhsChange.newLabel == rhsChange.newLabel &&
                    lhsChange.action == rhsChange.action &&
                    lhsUpdates == rhsUpdates
            default:
                return false
            }
        }
    }

    private enum ModRemovalLabelBehaviorMoveAndParameterUpdateIntent: Equatable {
        case request(
            label: String,
            change: (currentLabel: String, newLabel: String, action: String),
            moveClause: String,
            updates: [ModParameterUpdate]
        )
        case rejected([String])
        case notRecognized

        static func == (
            lhs: ModRemovalLabelBehaviorMoveAndParameterUpdateIntent,
            rhs: ModRemovalLabelBehaviorMoveAndParameterUpdateIntent
        ) -> Bool {
            switch (lhs, rhs) {
            case (.notRecognized, .notRecognized):
                return true
            case (.rejected(let lhsReasons), .rejected(let rhsReasons)):
                return lhsReasons == rhsReasons
            case (.request(let lhsLabel, let lhsChange, let lhsMoveClause, let lhsUpdates),
                  .request(let rhsLabel, let rhsChange, let rhsMoveClause, let rhsUpdates)):
                return lhsLabel == rhsLabel &&
                    lhsChange.currentLabel == rhsChange.currentLabel &&
                    lhsChange.newLabel == rhsChange.newLabel &&
                    lhsChange.action == rhsChange.action &&
                    lhsMoveClause == rhsMoveClause &&
                    lhsUpdates == rhsUpdates
            default:
                return false
            }
        }
    }

    private enum ModRemovalLabelBehaviorBoundsAndParameterUpdateIntent: Equatable {
        case request(
            label: String,
            change: (currentLabel: String, newLabel: String, action: String),
            placement: (label: String, bounds: AmigaProgramModel.Bounds),
            updates: [ModParameterUpdate]
        )
        case rejected([String])
        case notRecognized

        static func == (
            lhs: ModRemovalLabelBehaviorBoundsAndParameterUpdateIntent,
            rhs: ModRemovalLabelBehaviorBoundsAndParameterUpdateIntent
        ) -> Bool {
            switch (lhs, rhs) {
            case (.notRecognized, .notRecognized):
                return true
            case (.rejected(let lhsReasons), .rejected(let rhsReasons)):
                return lhsReasons == rhsReasons
            case (.request(let lhsLabel, let lhsChange, let lhsPlacement, let lhsUpdates),
                  .request(let rhsLabel, let rhsChange, let rhsPlacement, let rhsUpdates)):
                return lhsLabel == rhsLabel &&
                    lhsChange.currentLabel == rhsChange.currentLabel &&
                    lhsChange.newLabel == rhsChange.newLabel &&
                    lhsChange.action == rhsChange.action &&
                    lhsPlacement.label == rhsPlacement.label &&
                    lhsPlacement.bounds == rhsPlacement.bounds &&
                    lhsUpdates == rhsUpdates
            default:
                return false
            }
        }
    }

    private enum ModRemovalLabelBehaviorBoundsMoveAndParameterUpdateIntent: Equatable {
        case request(
            label: String,
            change: (currentLabel: String, newLabel: String, action: String),
            placement: (label: String, bounds: AmigaProgramModel.Bounds),
            moveClause: String,
            updates: [ModParameterUpdate]
        )
        case rejected([String])
        case notRecognized

        static func == (
            lhs: ModRemovalLabelBehaviorBoundsMoveAndParameterUpdateIntent,
            rhs: ModRemovalLabelBehaviorBoundsMoveAndParameterUpdateIntent
        ) -> Bool {
            switch (lhs, rhs) {
            case (.notRecognized, .notRecognized):
                return true
            case (.rejected(let lhsReasons), .rejected(let rhsReasons)):
                return lhsReasons == rhsReasons
            case (.request(let lhsLabel, let lhsChange, let lhsPlacement, let lhsMoveClause, let lhsUpdates),
                  .request(let rhsLabel, let rhsChange, let rhsPlacement, let rhsMoveClause, let rhsUpdates)):
                return lhsLabel == rhsLabel &&
                    lhsChange.currentLabel == rhsChange.currentLabel &&
                    lhsChange.newLabel == rhsChange.newLabel &&
                    lhsChange.action == rhsChange.action &&
                    lhsPlacement.label == rhsPlacement.label &&
                    lhsPlacement.bounds == rhsPlacement.bounds &&
                    lhsMoveClause == rhsMoveClause &&
                    lhsUpdates == rhsUpdates
            default:
                return false
            }
        }
    }

    private enum ModRemovalBehaviorAndParameterUpdateIntent: Equatable {
        case request(label: String, behavior: (label: String, action: String), updates: [ModParameterUpdate])
        case rejected([String])
        case notRecognized

        static func == (lhs: ModRemovalBehaviorAndParameterUpdateIntent, rhs: ModRemovalBehaviorAndParameterUpdateIntent) -> Bool {
            switch (lhs, rhs) {
            case (.notRecognized, .notRecognized):
                return true
            case (.rejected(let lhsReasons), .rejected(let rhsReasons)):
                return lhsReasons == rhsReasons
            case (.request(let lhsLabel, let lhsBehavior, let lhsUpdates), .request(let rhsLabel, let rhsBehavior, let rhsUpdates)):
                return lhsLabel == rhsLabel &&
                    lhsBehavior.label == rhsBehavior.label &&
                    lhsBehavior.action == rhsBehavior.action &&
                    lhsUpdates == rhsUpdates
            default:
                return false
            }
        }
    }

    private enum ModRemovalBehaviorMoveAndParameterUpdateIntent: Equatable {
        case request(
            label: String,
            behavior: (label: String, action: String),
            moveClause: String,
            updates: [ModParameterUpdate]
        )
        case rejected([String])
        case notRecognized

        static func == (
            lhs: ModRemovalBehaviorMoveAndParameterUpdateIntent,
            rhs: ModRemovalBehaviorMoveAndParameterUpdateIntent
        ) -> Bool {
            switch (lhs, rhs) {
            case (.notRecognized, .notRecognized):
                return true
            case (.rejected(let lhsReasons), .rejected(let rhsReasons)):
                return lhsReasons == rhsReasons
            case (.request(let lhsLabel, let lhsBehavior, let lhsMoveClause, let lhsUpdates),
                  .request(let rhsLabel, let rhsBehavior, let rhsMoveClause, let rhsUpdates)):
                return lhsLabel == rhsLabel &&
                    lhsBehavior.label == rhsBehavior.label &&
                    lhsBehavior.action == rhsBehavior.action &&
                    lhsMoveClause == rhsMoveClause &&
                    lhsUpdates == rhsUpdates
            default:
                return false
            }
        }
    }

    private enum ModRemovalBehaviorBoundsAndParameterUpdateIntent: Equatable {
        case request(
            label: String,
            behavior: (label: String, action: String),
            placement: (label: String, bounds: AmigaProgramModel.Bounds),
            updates: [ModParameterUpdate]
        )
        case rejected([String])
        case notRecognized

        static func == (
            lhs: ModRemovalBehaviorBoundsAndParameterUpdateIntent,
            rhs: ModRemovalBehaviorBoundsAndParameterUpdateIntent
        ) -> Bool {
            switch (lhs, rhs) {
            case (.notRecognized, .notRecognized):
                return true
            case (.rejected(let lhsReasons), .rejected(let rhsReasons)):
                return lhsReasons == rhsReasons
            case (.request(let lhsLabel, let lhsBehavior, let lhsPlacement, let lhsUpdates),
                  .request(let rhsLabel, let rhsBehavior, let rhsPlacement, let rhsUpdates)):
                return lhsLabel == rhsLabel &&
                    lhsBehavior.label == rhsBehavior.label &&
                    lhsBehavior.action == rhsBehavior.action &&
                    lhsPlacement.label == rhsPlacement.label &&
                    lhsPlacement.bounds == rhsPlacement.bounds &&
                    lhsUpdates == rhsUpdates
            default:
                return false
            }
        }
    }

    private enum ModRemovalBehaviorBoundsMoveAndParameterUpdateIntent: Equatable {
        case request(
            label: String,
            behavior: (label: String, action: String),
            placement: (label: String, bounds: AmigaProgramModel.Bounds),
            moveClause: String,
            updates: [ModParameterUpdate]
        )
        case rejected([String])
        case notRecognized

        static func == (
            lhs: ModRemovalBehaviorBoundsMoveAndParameterUpdateIntent,
            rhs: ModRemovalBehaviorBoundsMoveAndParameterUpdateIntent
        ) -> Bool {
            switch (lhs, rhs) {
            case (.notRecognized, .notRecognized):
                return true
            case (.rejected(let lhsReasons), .rejected(let rhsReasons)):
                return lhsReasons == rhsReasons
            case (.request(let lhsLabel, let lhsBehavior, let lhsPlacement, let lhsMoveClause, let lhsUpdates),
                  .request(let rhsLabel, let rhsBehavior, let rhsPlacement, let rhsMoveClause, let rhsUpdates)):
                return lhsLabel == rhsLabel &&
                    lhsBehavior.label == rhsBehavior.label &&
                    lhsBehavior.action == rhsBehavior.action &&
                    lhsPlacement.label == rhsPlacement.label &&
                    lhsPlacement.bounds == rhsPlacement.bounds &&
                    lhsMoveClause == rhsMoveClause &&
                    lhsUpdates == rhsUpdates
            default:
                return false
            }
        }
    }

    private enum ModRemovalMoveAndParameterUpdateIntent: Equatable {
        case request(
            label: String,
            move: (label: String, placement: AmigaProgramControlPlacement, targetLabel: String),
            updates: [ModParameterUpdate]
        )
        case rejected([String])
        case notRecognized

        static func == (lhs: ModRemovalMoveAndParameterUpdateIntent, rhs: ModRemovalMoveAndParameterUpdateIntent) -> Bool {
            switch (lhs, rhs) {
            case (.notRecognized, .notRecognized):
                return true
            case (.rejected(let lhsReasons), .rejected(let rhsReasons)):
                return lhsReasons == rhsReasons
            case (.request(let lhsLabel, let lhsMove, let lhsUpdates),
                  .request(let rhsLabel, let rhsMove, let rhsUpdates)):
                return lhsLabel == rhsLabel &&
                    lhsMove.label == rhsMove.label &&
                    lhsMove.placement == rhsMove.placement &&
                    lhsMove.targetLabel == rhsMove.targetLabel &&
                    lhsUpdates == rhsUpdates
            default:
                return false
            }
        }
    }

    private enum ModRemovalMoveUpdateIntent: Equatable {
        case request(
            label: String,
            move: (label: String, placement: AmigaProgramControlPlacement, targetLabel: String)
        )
        case rejected([String])
        case notRecognized

        static func == (lhs: ModRemovalMoveUpdateIntent, rhs: ModRemovalMoveUpdateIntent) -> Bool {
            switch (lhs, rhs) {
            case (.notRecognized, .notRecognized):
                return true
            case (.rejected(let lhsReasons), .rejected(let rhsReasons)):
                return lhsReasons == rhsReasons
            case (.request(let lhsLabel, let lhsMove), .request(let rhsLabel, let rhsMove)):
                return lhsLabel == rhsLabel &&
                    lhsMove.label == rhsMove.label &&
                    lhsMove.placement == rhsMove.placement &&
                    lhsMove.targetLabel == rhsMove.targetLabel
            default:
                return false
            }
        }
    }

    private enum ModRemovalAndParameterUpdateIntent: Equatable {
        case request(label: String, updates: [ModParameterUpdate])
        case rejected([String])
        case notRecognized
    }

    private enum ModMoveAndParameterUpdateIntent: Equatable {
        case request(
            move: (label: String, placement: AmigaProgramControlPlacement, targetLabel: String),
            updates: [ModParameterUpdate]
        )
        case rejected([String])
        case notRecognized

        static func == (lhs: ModMoveAndParameterUpdateIntent, rhs: ModMoveAndParameterUpdateIntent) -> Bool {
            switch (lhs, rhs) {
            case (.notRecognized, .notRecognized):
                return true
            case (.rejected(let lhsReasons), .rejected(let rhsReasons)):
                return lhsReasons == rhsReasons
            case (.request(let lhsMove, let lhsUpdates), .request(let rhsMove, let rhsUpdates)):
                return lhsMove.label == rhsMove.label &&
                    lhsMove.placement == rhsMove.placement &&
                    lhsMove.targetLabel == rhsMove.targetLabel &&
                    lhsUpdates == rhsUpdates
            default:
                return false
            }
        }
    }

    private static func modControlMoveAndParameterUpdateIntent(
        from prompt: String,
        model: AmigaProgramModel
    ) -> ModControlMoveAndParameterUpdateIntent {
        let clauses = modParameterUpdateClauses(in: prompt)
        let normalizedPrompt = prompt.lowercased()
        guard clauses.count > 1,
              hasAddControlSignal(in: normalizedPrompt),
              movePlacementSeparator(in: prompt) != nil,
              !hasRemoveControlSignal(in: normalizedPrompt),
              !hasControlRenameSignalOutsideAddLabel(in: normalizedPrompt) else {
            return .notRecognized
        }

        var controls: [(label: String, action: String)] = []
        var moveClause: String?
        var updates: [ModParameterUpdate] = []
        var rejectedReasons: [String] = []
        for clause in clauses {
            if let rejection = duplicateAddControlRequestRejection(from: clause) ??
                conflictingAddControlRejection(from: clause) ??
                addControlOrdinalRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let requests = addControlRequests(from: clause) {
                controls.append(contentsOf: requests)
                continue
            }
            if let request = addControlRequest(from: clause) {
                controls.append(request)
                continue
            }
            if movePlacementSeparator(in: clause) != nil {
                if moveClause != nil {
                    rejectedReasons.append("Specify only one control move.")
                } else {
                    moveClause = clause
                }
                continue
            }
            switch modParameterClauseIntent(from: clause) {
            case .update(let update):
                updates.append(update)
            case .rejected(let reason):
                rejectedReasons.append(reason)
            case .notRecognized:
                break
            }
        }

        guard !controls.isEmpty,
              let moveClause else {
            return .notRecognized
        }
        if let duplicateLabel = duplicateAddControlLabel(in: controls) {
            return .rejected(["Duplicate control requested: \(duplicateLabel). Specify each control only once."])
        }
        if !rejectedReasons.isEmpty {
            return .rejected(Array(Set(rejectedReasons)).sorted())
        }
        let duplicateTargets = duplicateModParameterUpdateTargets(in: updates)
        if !duplicateTargets.isEmpty {
            return .rejected(duplicateTargets.map { "Specify only one \($0) update." })
        }
        return .request(controls: controls, moveClause: moveClause, updates: updates)
    }

    private static func modControlAndParameterUpdateIntent(
        from prompt: String,
        model: AmigaProgramModel
    ) -> ModControlAndParameterUpdateIntent {
        let clauses = modParameterUpdateClauses(in: prompt)
        guard clauses.count > 1,
              hasAddControlSignal(in: prompt.lowercased()) else {
            return .notRecognized
        }

        var controls: [(label: String, action: String)] = []
        var updates: [ModParameterUpdate] = []
        var rejectedReasons: [String] = []
        for clause in clauses {
            if let rejection = duplicateAddControlRequestRejection(from: clause) ??
                conflictingAddControlRejection(from: clause) ??
                addControlOrdinalRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let requests = addControlRequests(from: clause) {
                controls.append(contentsOf: requests)
                continue
            }
            if let request = addControlRequest(from: clause) {
                controls.append(request)
                continue
            }
            switch modParameterClauseIntent(from: clause) {
            case .update(let update):
                updates.append(update)
            case .rejected(let reason):
                rejectedReasons.append(reason)
            case .notRecognized:
                break
            }
        }

        guard !controls.isEmpty,
              updates.count + rejectedReasons.count > 0 else {
            return .notRecognized
        }
        if let duplicateLabel = duplicateAddControlLabel(in: controls) {
            return .rejected(["Duplicate control requested: \(duplicateLabel). Specify each control only once."])
        }
        if !rejectedReasons.isEmpty {
            return .rejected(Array(Set(rejectedReasons)).sorted())
        }
        let duplicateTargets = duplicateModParameterUpdateTargets(in: updates)
        if !duplicateTargets.isEmpty {
            return .rejected(duplicateTargets.map { "Specify only one \($0) update." })
        }
        return .request(controls: controls, updates: updates)
    }

    private static func modRenameAndParameterUpdateIntent(
        from prompt: String,
        model: AmigaProgramModel
    ) -> ModRenameAndParameterUpdateIntent {
        let clauses = modParameterUpdateClauses(in: prompt)
        let normalizedPrompt = prompt.lowercased()
        guard clauses.count > 1,
              hasRenameSignal(in: normalizedPrompt),
              !containsWord("add", in: normalizedPrompt),
              !hasRemoveControlSignal(in: normalizedPrompt) else {
            return .notRecognized
        }

        var rename: (currentLabel: String, newLabel: String)?
        var updates: [ModParameterUpdate] = []
        var rejectedReasons: [String] = []
        for clause in clauses {
            if let rejection = ordinalLabelRenameRejection(from: clause, model: model) ??
                ambiguousLabelRenameRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let request = labelRenameRequest(from: clause, model: model) {
                if rename != nil {
                    rejectedReasons.append("Specify only one control rename.")
                } else {
                    rename = request
                }
                continue
            }
            switch modParameterClauseIntent(from: clause) {
            case .update(let update):
                updates.append(update)
            case .rejected(let reason):
                rejectedReasons.append(reason)
            case .notRecognized:
                break
            }
        }

        guard let rename,
              updates.count + rejectedReasons.count > 0 else {
            return .notRecognized
        }
        if !rejectedReasons.isEmpty {
            return .rejected(Array(Set(rejectedReasons)).sorted())
        }
        let duplicateTargets = duplicateModParameterUpdateTargets(in: updates)
        if !duplicateTargets.isEmpty {
            return .rejected(duplicateTargets.map { "Specify only one \($0) update." })
        }
        return .request(rename: rename, updates: updates)
    }

    private static func modRenameBoundsAndParameterUpdateIntent(
        from prompt: String,
        model: AmigaProgramModel
    ) -> ModRenameBoundsAndParameterUpdateIntent {
        let clauses = modParameterUpdateClauses(in: prompt)
        let normalizedPrompt = prompt.lowercased()
        guard clauses.count > 2,
              hasRenameSignal(in: normalizedPrompt),
              hasControlBoundsSignal(in: normalizedPrompt),
              !containsWord("add", in: normalizedPrompt),
              !hasRemoveControlSignal(in: normalizedPrompt) else {
            return .notRecognized
        }

        var rename: (currentLabel: String, newLabel: String)?
        var placement: (label: String, bounds: AmigaProgramModel.Bounds)?
        var updates: [ModParameterUpdate] = []
        var rejectedReasons: [String] = []
        for clause in clauses {
            if let rejection = ordinalLabelRenameRejection(from: clause, model: model) ??
                ambiguousLabelRenameRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let request = labelRenameRequest(from: clause, model: model) {
                if rename != nil {
                    rejectedReasons.append("Specify only one control rename.")
                } else {
                    rename = request
                }
                continue
            }
            if let rejection = ambiguousControlBoundsRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let boundsRequest = controlBoundsRequest(from: clause, model: model) {
                if placement != nil {
                    rejectedReasons.append("Specify only one control bounds change.")
                } else {
                    placement = boundsRequest
                }
                continue
            }
            switch modParameterClauseIntent(from: clause) {
            case .update(let update):
                updates.append(update)
            case .rejected(let reason):
                rejectedReasons.append(reason)
            case .notRecognized:
                break
            }
        }

        guard let rename,
              let placement,
              updates.count + rejectedReasons.count > 0 else {
            return .notRecognized
        }
        if !rejectedReasons.isEmpty {
            return .rejected(Array(Set(rejectedReasons)).sorted())
        }
        let duplicateTargets = duplicateModParameterUpdateTargets(in: updates)
        if !duplicateTargets.isEmpty {
            return .rejected(duplicateTargets.map { "Specify only one \($0) update." })
        }
        return .request(rename: rename, placement: placement, updates: updates)
    }

    private static func modRenameBoundsUpdateIntent(
        from prompt: String,
        model: AmigaProgramModel
    ) -> ModRenameBoundsUpdateIntent {
        let clauses = modParameterUpdateClauses(in: prompt)
        let normalizedPrompt = prompt.lowercased()
        guard clauses.count > 1,
              hasRenameSignal(in: normalizedPrompt),
              hasControlBoundsSignal(in: normalizedPrompt),
              !containsWord("add", in: normalizedPrompt),
              !hasRemoveControlSignal(in: normalizedPrompt),
              movePlacementSeparator(in: prompt) == nil else {
            return .notRecognized
        }

        var rename: (currentLabel: String, newLabel: String)?
        var placement: (label: String, bounds: AmigaProgramModel.Bounds)?
        var rejectedReasons: [String] = []
        for clause in clauses {
            if let rejection = ordinalLabelRenameRejection(from: clause, model: model) ??
                ambiguousLabelRenameRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let request = labelRenameRequest(from: clause, model: model) {
                if rename != nil {
                    rejectedReasons.append("Specify only one control rename.")
                } else {
                    rename = request
                }
                continue
            }
            if let rejection = ambiguousControlBoundsRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let boundsRequest = controlBoundsRequest(from: clause, model: model) {
                if placement != nil {
                    rejectedReasons.append("Specify only one control bounds change.")
                } else {
                    placement = boundsRequest
                }
                continue
            }
            switch modParameterClauseIntent(from: clause) {
            case .update:
                return .notRecognized
            case .rejected(let reason):
                rejectedReasons.append(reason)
            case .notRecognized:
                break
            }
        }

        guard let rename,
              let placement else {
            return .notRecognized
        }
        if !rejectedReasons.isEmpty {
            return .rejected(Array(Set(rejectedReasons)).sorted())
        }
        return .request(rename: rename, placement: placement)
    }

    private static func modRenameBoundsMoveAndParameterUpdateIntent(
        from prompt: String,
        model: AmigaProgramModel
    ) -> ModRenameBoundsMoveAndParameterUpdateIntent {
        let clauses = modParameterUpdateClauses(in: prompt)
        let normalizedPrompt = prompt.lowercased()
        guard clauses.count > 2,
              hasRenameSignal(in: normalizedPrompt),
              hasControlBoundsSignal(in: normalizedPrompt),
              movePlacementSeparator(in: prompt) != nil,
              !containsWord("add", in: normalizedPrompt),
              !hasRemoveControlSignal(in: normalizedPrompt) else {
            return .notRecognized
        }

        var rename: (currentLabel: String, newLabel: String)?
        var placement: (label: String, bounds: AmigaProgramModel.Bounds)?
        var moveClause: String?
        var updates: [ModParameterUpdate] = []
        var rejectedReasons: [String] = []
        for clause in clauses {
            if let rejection = ordinalLabelRenameRejection(from: clause, model: model) ??
                ambiguousLabelRenameRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let request = labelRenameRequest(from: clause, model: model) {
                if rename != nil {
                    rejectedReasons.append("Specify only one control rename.")
                } else {
                    rename = request
                }
                continue
            }
            if let rejection = ambiguousControlBoundsRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let boundsRequest = controlBoundsRequest(from: clause, model: model) {
                if placement != nil {
                    rejectedReasons.append("Specify only one control bounds change.")
                } else {
                    placement = boundsRequest
                }
                continue
            }
            if movePlacementSeparator(in: clause) != nil {
                if moveClause != nil {
                    rejectedReasons.append("Specify only one control move.")
                } else {
                    moveClause = clause
                }
                continue
            }
            switch modParameterClauseIntent(from: clause) {
            case .update(let update):
                updates.append(update)
            case .rejected(let reason):
                rejectedReasons.append(reason)
            case .notRecognized:
                break
            }
        }

        guard let rename,
              let placement,
              let moveClause else {
            return .notRecognized
        }
        if placement.label != rename.currentLabel {
            rejectedReasons.append("Specify the same control for rename and bounds changes.")
        }
        if !rejectedReasons.isEmpty {
            return .rejected(Array(Set(rejectedReasons)).sorted())
        }
        let duplicateTargets = duplicateModParameterUpdateTargets(in: updates)
        if !duplicateTargets.isEmpty {
            return .rejected(duplicateTargets.map { "Specify only one \($0) update." })
        }
        return .request(rename: rename, placement: placement, moveClause: moveClause, updates: updates)
    }

    private static func modRenameMoveAndParameterUpdateIntent(
        from prompt: String,
        model: AmigaProgramModel
    ) -> ModRenameMoveAndParameterUpdateIntent {
        let clauses = modParameterUpdateClauses(in: prompt)
        let normalizedPrompt = prompt.lowercased()
        guard clauses.count > 1,
              hasRenameSignal(in: normalizedPrompt),
              movePlacementSeparator(in: prompt) != nil,
              !containsWord("add", in: normalizedPrompt),
              !hasRemoveControlSignal(in: normalizedPrompt) else {
            return .notRecognized
        }

        var rename: (currentLabel: String, newLabel: String)?
        var moveClause: String?
        var updates: [ModParameterUpdate] = []
        var rejectedReasons: [String] = []
        for clause in clauses {
            if let rejection = ordinalLabelRenameRejection(from: clause, model: model) ??
                ambiguousLabelRenameRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let request = labelRenameRequest(from: clause, model: model) {
                if rename != nil {
                    rejectedReasons.append("Specify only one control rename.")
                } else {
                    rename = request
                }
                continue
            }
            if movePlacementSeparator(in: clause) != nil {
                if moveClause != nil {
                    rejectedReasons.append("Specify only one control move.")
                } else {
                    moveClause = clause
                }
                continue
            }
            switch modParameterClauseIntent(from: clause) {
            case .update(let update):
                updates.append(update)
            case .rejected(let reason):
                rejectedReasons.append(reason)
            case .notRecognized:
                break
            }
        }

        guard let rename,
              let moveClause else {
            return .notRecognized
        }
        if !rejectedReasons.isEmpty {
            return .rejected(Array(Set(rejectedReasons)).sorted())
        }
        let duplicateTargets = duplicateModParameterUpdateTargets(in: updates)
        if !duplicateTargets.isEmpty {
            return .rejected(duplicateTargets.map { "Specify only one \($0) update." })
        }
        return .request(rename: rename, moveClause: moveClause, updates: updates)
    }

    private static func modBehaviorAndParameterUpdateIntent(
        from prompt: String,
        model: AmigaProgramModel
    ) -> ModBehaviorAndParameterUpdateIntent {
        let clauses = modParameterUpdateClauses(in: prompt)
        let normalizedPrompt = prompt.lowercased()
        guard clauses.count > 1,
              hasBehaviorChangeSignal(in: normalizedPrompt),
              !hasRenameSignal(in: normalizedPrompt),
              !containsWord("add", in: normalizedPrompt),
              !hasRemoveControlSignal(in: normalizedPrompt),
              !hasMoveControlSignal(in: normalizedPrompt) else {
            return .notRecognized
        }

        var behavior: (label: String, action: String)?
        var updates: [ModParameterUpdate] = []
        var rejectedReasons: [String] = []
        for clause in clauses {
            if let rejection = conflictingControlBehaviorChangeRejection(from: clause, model: model) ??
                duplicateControlLabelAndBehaviorChangeRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let request = controlBehaviorChangeRequest(from: clause, model: model) {
                if behavior != nil {
                    rejectedReasons.append("Specify only one control behavior change.")
                } else {
                    behavior = request
                }
                continue
            }
            switch modParameterClauseIntent(from: clause) {
            case .update(let update):
                updates.append(update)
            case .rejected(let reason):
                rejectedReasons.append(reason)
            case .notRecognized:
                break
            }
        }

        guard let behavior,
              updates.count + rejectedReasons.count > 0 else {
            return .notRecognized
        }
        if !rejectedReasons.isEmpty {
            return .rejected(Array(Set(rejectedReasons)).sorted())
        }
        let duplicateTargets = duplicateModParameterUpdateTargets(in: updates)
        if !duplicateTargets.isEmpty {
            return .rejected(duplicateTargets.map { "Specify only one \($0) update." })
        }
        return .request(behavior: behavior, updates: updates)
    }

    private static func modBehaviorMoveAndParameterUpdateIntent(
        from prompt: String,
        model: AmigaProgramModel
    ) -> ModBehaviorMoveAndParameterUpdateIntent {
        let clauses = modParameterUpdateClauses(in: prompt)
        let normalizedPrompt = prompt.lowercased()
        guard clauses.count > 1,
              hasBehaviorChangeSignal(in: normalizedPrompt),
              movePlacementSeparator(in: prompt) != nil,
              !hasRenameSignal(in: normalizedPrompt),
              !containsWord("add", in: normalizedPrompt),
              !hasRemoveControlSignal(in: normalizedPrompt) else {
            return .notRecognized
        }

        var behavior: (label: String, action: String)?
        var moveClause: String?
        var updates: [ModParameterUpdate] = []
        var rejectedReasons: [String] = []
        for clause in clauses {
            if let rejection = conflictingControlBehaviorChangeRejection(from: clause, model: model) ??
                duplicateControlLabelAndBehaviorChangeRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let request = controlBehaviorChangeRequest(from: clause, model: model) {
                if behavior != nil {
                    rejectedReasons.append("Specify only one control behavior change.")
                } else {
                    behavior = request
                }
                continue
            }
            if movePlacementSeparator(in: clause) != nil {
                if moveClause != nil {
                    rejectedReasons.append("Specify only one control move.")
                } else {
                    moveClause = clause
                }
                continue
            }
            switch modParameterClauseIntent(from: clause) {
            case .update(let update):
                updates.append(update)
            case .rejected(let reason):
                rejectedReasons.append(reason)
            case .notRecognized:
                break
            }
        }

        guard let behavior,
              let moveClause else {
            return .notRecognized
        }
        if !rejectedReasons.isEmpty {
            return .rejected(Array(Set(rejectedReasons)).sorted())
        }
        let duplicateTargets = duplicateModParameterUpdateTargets(in: updates)
        if !duplicateTargets.isEmpty {
            return .rejected(duplicateTargets.map { "Specify only one \($0) update." })
        }
        return .request(behavior: behavior, moveClause: moveClause, updates: updates)
    }

    private static func modBehaviorBoundsAndParameterUpdateIntent(
        from prompt: String,
        model: AmigaProgramModel
    ) -> ModBehaviorBoundsAndParameterUpdateIntent {
        let clauses = modParameterUpdateClauses(in: prompt)
        let normalizedPrompt = prompt.lowercased()
        guard clauses.count > 1,
              hasBehaviorChangeSignal(in: normalizedPrompt),
              hasControlBoundsSignal(in: normalizedPrompt),
              !hasRenameSignal(in: normalizedPrompt),
              !containsWord("add", in: normalizedPrompt),
              !hasRemoveControlSignal(in: normalizedPrompt),
              !hasMoveControlSignal(in: normalizedPrompt) else {
            return .notRecognized
        }

        var behavior: (label: String, action: String)?
        var placement: (label: String, bounds: AmigaProgramModel.Bounds)?
        var updates: [ModParameterUpdate] = []
        var rejectedReasons: [String] = []
        for clause in clauses {
            if let rejection = conflictingControlBehaviorChangeRejection(from: clause, model: model) ??
                duplicateControlLabelAndBehaviorChangeRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let request = controlBehaviorChangeRequest(from: clause, model: model) {
                if behavior != nil {
                    rejectedReasons.append("Specify only one control behavior change.")
                } else {
                    behavior = request
                }
                continue
            }
            if let rejection = ambiguousControlBoundsRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let boundsRequest = controlBoundsRequest(from: clause, model: model) {
                if placement != nil {
                    rejectedReasons.append("Specify only one control bounds change.")
                } else {
                    placement = boundsRequest
                }
                continue
            }
            switch modParameterClauseIntent(from: clause) {
            case .update(let update):
                updates.append(update)
            case .rejected(let reason):
                rejectedReasons.append(reason)
            case .notRecognized:
                break
            }
        }

        guard let behavior,
              let placement else {
            return .notRecognized
        }
        if placement.label != behavior.label {
            rejectedReasons.append("Specify the same control for behavior and bounds changes.")
        }
        if !rejectedReasons.isEmpty {
            return .rejected(Array(Set(rejectedReasons)).sorted())
        }
        let duplicateTargets = duplicateModParameterUpdateTargets(in: updates)
        if !duplicateTargets.isEmpty {
            return .rejected(duplicateTargets.map { "Specify only one \($0) update." })
        }
        return .request(behavior: behavior, placement: placement, updates: updates)
    }

    private static func modBehaviorBoundsMoveAndParameterUpdateIntent(
        from prompt: String,
        model: AmigaProgramModel
    ) -> ModBehaviorBoundsMoveAndParameterUpdateIntent {
        let clauses = modParameterUpdateClauses(in: prompt)
        let normalizedPrompt = prompt.lowercased()
        guard clauses.count > 2,
              hasBehaviorChangeSignal(in: normalizedPrompt),
              hasControlBoundsSignal(in: normalizedPrompt),
              movePlacementSeparator(in: prompt) != nil,
              !hasRenameSignal(in: normalizedPrompt),
              !containsWord("add", in: normalizedPrompt),
              !hasRemoveControlSignal(in: normalizedPrompt) else {
            return .notRecognized
        }

        var behavior: (label: String, action: String)?
        var placement: (label: String, bounds: AmigaProgramModel.Bounds)?
        var moveClause: String?
        var updates: [ModParameterUpdate] = []
        var rejectedReasons: [String] = []
        for clause in clauses {
            if let rejection = conflictingControlBehaviorChangeRejection(from: clause, model: model) ??
                duplicateControlLabelAndBehaviorChangeRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let request = controlBehaviorChangeRequest(from: clause, model: model) {
                if behavior != nil {
                    rejectedReasons.append("Specify only one control behavior change.")
                } else {
                    behavior = request
                }
                continue
            }
            if let rejection = ambiguousControlBoundsRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let boundsRequest = controlBoundsRequest(from: clause, model: model) {
                if placement != nil {
                    rejectedReasons.append("Specify only one control bounds change.")
                } else {
                    placement = boundsRequest
                }
                continue
            }
            if movePlacementSeparator(in: clause) != nil {
                if moveClause != nil {
                    rejectedReasons.append("Specify only one control move.")
                } else {
                    moveClause = clause
                }
                continue
            }
            switch modParameterClauseIntent(from: clause) {
            case .update(let update):
                updates.append(update)
            case .rejected(let reason):
                rejectedReasons.append(reason)
            case .notRecognized:
                break
            }
        }

        guard let behavior,
              let placement,
              let moveClause else {
            return .notRecognized
        }
        if placement.label != behavior.label {
            rejectedReasons.append("Specify the same control for behavior and bounds changes.")
        }
        if !rejectedReasons.isEmpty {
            return .rejected(Array(Set(rejectedReasons)).sorted())
        }
        let duplicateTargets = duplicateModParameterUpdateTargets(in: updates)
        if !duplicateTargets.isEmpty {
            return .rejected(duplicateTargets.map { "Specify only one \($0) update." })
        }
        return .request(behavior: behavior, placement: placement, moveClause: moveClause, updates: updates)
    }

    private static func modLabelBehaviorAndParameterUpdateIntent(
        from prompt: String,
        model: AmigaProgramModel
    ) -> ModLabelBehaviorAndParameterUpdateIntent {
        let clauses = modParameterUpdateClauses(in: prompt)
        let normalizedPrompt = prompt.lowercased()
        guard clauses.count > 1,
              hasRenameSignal(in: normalizedPrompt),
              hasBehaviorChangeSignal(in: normalizedPrompt),
              !containsWord("add", in: normalizedPrompt),
              !hasRemoveControlSignal(in: normalizedPrompt),
              !hasMoveControlSignal(in: normalizedPrompt) else {
            return .notRecognized
        }

        var structuralClauses: [String] = []
        var updates: [ModParameterUpdate] = []
        var rejectedReasons: [String] = []
        for clause in clauses {
            switch modParameterClauseIntent(from: clause) {
            case .update(let update):
                updates.append(update)
            case .rejected(let reason):
                rejectedReasons.append(reason)
            case .notRecognized:
                structuralClauses.append(clause)
            }
        }

        let structuralPrompt = structuralClauses.joined(separator: " and ")
        if let rejection = conflictingControlBehaviorChangeRejection(from: structuralPrompt, model: model) ??
            duplicateControlLabelAndBehaviorChangeRejection(from: structuralPrompt, model: model) {
            rejectedReasons.append(rejection)
        }

        guard let change = controlLabelAndBehaviorChangeRequest(from: structuralPrompt, model: model),
              updates.count + rejectedReasons.count > 0 else {
            return .notRecognized
        }
        if !rejectedReasons.isEmpty {
            return .rejected(Array(Set(rejectedReasons)).sorted())
        }
        let duplicateTargets = duplicateModParameterUpdateTargets(in: updates)
        if !duplicateTargets.isEmpty {
            return .rejected(duplicateTargets.map { "Specify only one \($0) update." })
        }
        return .request(change: change, updates: updates)
    }

    private static func modLabelBehaviorMoveAndParameterUpdateIntent(
        from prompt: String,
        model: AmigaProgramModel
    ) -> ModLabelBehaviorMoveAndParameterUpdateIntent {
        let clauses = modParameterUpdateClauses(in: prompt)
        let normalizedPrompt = prompt.lowercased()
        guard clauses.count > 1,
              hasRenameSignal(in: normalizedPrompt),
              hasBehaviorChangeSignal(in: normalizedPrompt),
              movePlacementSeparator(in: prompt) != nil,
              !containsWord("add", in: normalizedPrompt),
              !hasRemoveControlSignal(in: normalizedPrompt) else {
            return .notRecognized
        }

        var structuralClauses: [String] = []
        var moveClause: String?
        var updates: [ModParameterUpdate] = []
        var rejectedReasons: [String] = []
        for clause in clauses {
            switch modParameterClauseIntent(from: clause) {
            case .update(let update):
                updates.append(update)
                continue
            case .rejected(let reason):
                rejectedReasons.append(reason)
                continue
            case .notRecognized:
                break
            }

            if movePlacementSeparator(in: clause) != nil {
                if moveClause != nil {
                    rejectedReasons.append("Specify only one control move.")
                } else {
                    moveClause = clause
                }
                continue
            }
            structuralClauses.append(clause)
        }

        let structuralPrompt = structuralClauses.joined(separator: " and ")
        if let rejection = conflictingControlBehaviorChangeRejection(from: structuralPrompt, model: model) ??
            duplicateControlLabelAndBehaviorChangeRejection(from: structuralPrompt, model: model) {
            rejectedReasons.append(rejection)
        }

        guard let change = controlLabelAndBehaviorChangeRequest(from: structuralPrompt, model: model),
              let moveClause else {
            return .notRecognized
        }
        if !rejectedReasons.isEmpty {
            return .rejected(Array(Set(rejectedReasons)).sorted())
        }
        let duplicateTargets = duplicateModParameterUpdateTargets(in: updates)
        if !duplicateTargets.isEmpty {
            return .rejected(duplicateTargets.map { "Specify only one \($0) update." })
        }
        return .request(change: change, moveClause: moveClause, updates: updates)
    }

    private static func modLabelBehaviorBoundsAndParameterUpdateIntent(
        from prompt: String,
        model: AmigaProgramModel
    ) -> ModLabelBehaviorBoundsAndParameterUpdateIntent {
        let clauses = modParameterUpdateClauses(in: prompt)
        let normalizedPrompt = prompt.lowercased()
        guard clauses.count > 2,
              hasRenameSignal(in: normalizedPrompt),
              hasBehaviorChangeSignal(in: normalizedPrompt),
              hasControlBoundsSignal(in: normalizedPrompt),
              !containsWord("add", in: normalizedPrompt),
              !hasRemoveControlSignal(in: normalizedPrompt),
              !hasMoveControlSignal(in: normalizedPrompt) else {
            return .notRecognized
        }

        var structuralClauses: [String] = []
        var placement: (label: String, bounds: AmigaProgramModel.Bounds)?
        var updates: [ModParameterUpdate] = []
        var rejectedReasons: [String] = []
        for clause in clauses {
            switch modParameterClauseIntent(from: clause) {
            case .update(let update):
                updates.append(update)
                continue
            case .rejected(let reason):
                rejectedReasons.append(reason)
                continue
            case .notRecognized:
                break
            }

            if let rejection = ambiguousControlBoundsRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let boundsRequest = controlBoundsRequest(from: clause, model: model) {
                if placement != nil {
                    rejectedReasons.append("Specify only one control bounds change.")
                } else {
                    placement = boundsRequest
                }
                continue
            }
            structuralClauses.append(clause)
        }

        let structuralPrompt = structuralClauses.joined(separator: " and ")
        if let rejection = conflictingControlBehaviorChangeRejection(from: structuralPrompt, model: model) ??
            duplicateControlLabelAndBehaviorChangeRejection(from: structuralPrompt, model: model) {
            rejectedReasons.append(rejection)
        }

        guard let change = controlLabelAndBehaviorChangeRequest(from: structuralPrompt, model: model),
              let placement,
              updates.count + rejectedReasons.count > 0 else {
            return .notRecognized
        }
        if placement.label != change.currentLabel {
            rejectedReasons.append("Specify the same control for label, behavior, and bounds changes.")
        }
        if !rejectedReasons.isEmpty {
            return .rejected(Array(Set(rejectedReasons)).sorted())
        }
        let duplicateTargets = duplicateModParameterUpdateTargets(in: updates)
        if !duplicateTargets.isEmpty {
            return .rejected(duplicateTargets.map { "Specify only one \($0) update." })
        }
        return .request(change: change, placement: placement, updates: updates)
    }

    private static func modLabelBehaviorBoundsMoveAndParameterUpdateIntent(
        from prompt: String,
        model: AmigaProgramModel
    ) -> ModLabelBehaviorBoundsMoveAndParameterUpdateIntent {
        let clauses = modParameterUpdateClauses(in: prompt)
        let normalizedPrompt = prompt.lowercased()
        guard clauses.count > 2,
              hasRenameSignal(in: normalizedPrompt),
              hasBehaviorChangeSignal(in: normalizedPrompt),
              hasControlBoundsSignal(in: normalizedPrompt),
              movePlacementSeparator(in: prompt) != nil,
              !containsWord("add", in: normalizedPrompt),
              !hasRemoveControlSignal(in: normalizedPrompt) else {
            return .notRecognized
        }

        var structuralClauses: [String] = []
        var placement: (label: String, bounds: AmigaProgramModel.Bounds)?
        var moveClause: String?
        var updates: [ModParameterUpdate] = []
        var rejectedReasons: [String] = []
        for clause in clauses {
            switch modParameterClauseIntent(from: clause) {
            case .update(let update):
                updates.append(update)
                continue
            case .rejected(let reason):
                rejectedReasons.append(reason)
                continue
            case .notRecognized:
                break
            }

            if movePlacementSeparator(in: clause) != nil {
                if moveClause != nil {
                    rejectedReasons.append("Specify only one control move.")
                } else {
                    moveClause = clause
                }
                continue
            }
            if let rejection = ambiguousControlBoundsRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let boundsRequest = controlBoundsRequest(from: clause, model: model) {
                if placement != nil {
                    rejectedReasons.append("Specify only one control bounds change.")
                } else {
                    placement = boundsRequest
                }
                continue
            }
            structuralClauses.append(clause)
        }

        let structuralPrompt = structuralClauses.joined(separator: " and ")
        if let rejection = conflictingControlBehaviorChangeRejection(from: structuralPrompt, model: model) ??
            duplicateControlLabelAndBehaviorChangeRejection(from: structuralPrompt, model: model) {
            rejectedReasons.append(rejection)
        }

        guard let change = controlLabelAndBehaviorChangeRequest(from: structuralPrompt, model: model),
              let placement,
              let moveClause else {
            return .notRecognized
        }
        if placement.label != change.currentLabel {
            rejectedReasons.append("Specify the same control for label, behavior, bounds, and move changes.")
        }
        if !rejectedReasons.isEmpty {
            return .rejected(Array(Set(rejectedReasons)).sorted())
        }
        let duplicateTargets = duplicateModParameterUpdateTargets(in: updates)
        if !duplicateTargets.isEmpty {
            return .rejected(duplicateTargets.map { "Specify only one \($0) update." })
        }
        return .request(change: change, placement: placement, moveClause: moveClause, updates: updates)
    }

    private static func modLabelBehaviorAndBoundsUpdateIntent(
        from prompt: String,
        model: AmigaProgramModel
    ) -> ModLabelBehaviorAndBoundsUpdateIntent {
        let clauses = modParameterUpdateClauses(in: prompt)
        let normalizedPrompt = prompt.lowercased()
        guard clauses.count > 1,
              hasRenameSignal(in: normalizedPrompt),
              hasBehaviorChangeSignal(in: normalizedPrompt),
              hasControlBoundsSignal(in: normalizedPrompt),
              !containsWord("add", in: normalizedPrompt),
              !hasRemoveControlSignal(in: normalizedPrompt),
              !hasMoveControlSignal(in: normalizedPrompt) else {
            return .notRecognized
        }

        var structuralClauses: [String] = []
        var placement: (label: String, bounds: AmigaProgramModel.Bounds)?
        var rejectedReasons: [String] = []
        for clause in clauses {
            if let rejection = ambiguousControlBoundsRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let boundsRequest = controlBoundsRequest(from: clause, model: model) {
                if placement != nil {
                    rejectedReasons.append("Specify only one control bounds change.")
                } else {
                    placement = boundsRequest
                }
                continue
            }
            structuralClauses.append(clause)
        }

        let structuralPrompt = structuralClauses.joined(separator: " and ")
        if let rejection = conflictingControlBehaviorChangeRejection(from: structuralPrompt, model: model) ??
            duplicateControlLabelAndBehaviorChangeRejection(from: structuralPrompt, model: model) {
            rejectedReasons.append(rejection)
        }

        guard let change = controlLabelAndBehaviorChangeRequest(from: structuralPrompt, model: model),
              let placement else {
            return .notRecognized
        }
        if placement.label != change.currentLabel {
            rejectedReasons.append("Specify the same control for label, behavior, and bounds changes.")
        }
        if !rejectedReasons.isEmpty {
            return .rejected(Array(Set(rejectedReasons)).sorted())
        }
        return .request(change: change, placement: placement)
    }

    private static func modBoundsAndParameterUpdateIntent(
        from prompt: String,
        model: AmigaProgramModel
    ) -> ModBoundsAndParameterUpdateIntent {
        let clauses = modParameterUpdateClauses(in: prompt)
        let normalizedPrompt = prompt.lowercased()
        guard clauses.count > 1,
              hasControlBoundsSignal(in: normalizedPrompt),
              !containsWord("add", in: normalizedPrompt),
              !hasRenameSignal(in: normalizedPrompt),
              !hasRemoveControlSignal(in: normalizedPrompt) else {
            return .notRecognized
        }

        var placements: [(label: String, bounds: AmigaProgramModel.Bounds)]?
        var updates: [ModParameterUpdate] = []
        var rejectedReasons: [String] = []
        for clause in clauses {
            if let rejection = ambiguousControlBoundsRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let groupPlacement = controlGroupBoundsRequest(from: clause, model: model) {
                if placements != nil {
                    rejectedReasons.append("Specify only one control bounds change.")
                } else {
                    placements = groupPlacement
                }
                continue
            }
            if let placement = controlBoundsRequest(from: clause, model: model) {
                if placements != nil {
                    rejectedReasons.append("Specify only one control bounds change.")
                } else {
                    placements = [placement]
                }
                continue
            }
            switch modParameterClauseIntent(from: clause) {
            case .update(let update):
                updates.append(update)
            case .rejected(let reason):
                rejectedReasons.append(reason)
            case .notRecognized:
                break
            }
        }

        guard let placements,
              updates.count + rejectedReasons.count > 0 else {
            return .notRecognized
        }
        if !rejectedReasons.isEmpty {
            return .rejected(Array(Set(rejectedReasons)).sorted())
        }
        let duplicateTargets = duplicateModParameterUpdateTargets(in: updates)
        if !duplicateTargets.isEmpty {
            return .rejected(duplicateTargets.map { "Specify only one \($0) update." })
        }
        return .request(placements: placements, updates: updates)
    }

    private static func modBoundsMoveAndParameterUpdateIntent(
        from prompt: String,
        model: AmigaProgramModel
    ) -> ModBoundsMoveAndParameterUpdateIntent {
        let clauses = modParameterUpdateClauses(in: prompt)
        let normalizedPrompt = prompt.lowercased()
        guard clauses.count > 1,
              hasControlBoundsSignal(in: normalizedPrompt),
              hasMoveControlSignal(in: normalizedPrompt),
              !containsWord("add", in: normalizedPrompt),
              !hasRenameSignal(in: normalizedPrompt),
              !hasRemoveControlSignal(in: normalizedPrompt) else {
            return .notRecognized
        }

        var placements: [(label: String, bounds: AmigaProgramModel.Bounds)]?
        var move: (label: String, placement: AmigaProgramControlPlacement, targetLabel: String)?
        var updates: [ModParameterUpdate] = []
        var rejectedReasons: [String] = []
        for clause in clauses {
            if let rejection = ambiguousControlBoundsRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let groupPlacement = controlGroupBoundsRequest(from: clause, model: model) {
                if placements != nil {
                    rejectedReasons.append("Specify only one control bounds change.")
                } else {
                    placements = groupPlacement
                }
                continue
            }
            if let placement = controlBoundsRequest(from: clause, model: model) {
                if placements != nil {
                    rejectedReasons.append("Specify only one control bounds change.")
                } else {
                    placements = [placement]
                }
                continue
            }
            if let rejection = ordinalControlMoveRejection(from: clause, model: model) ??
                ambiguousControlMoveRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let request = moveControlRequest(from: clause, model: model) {
                if move != nil {
                    rejectedReasons.append("Specify only one control move.")
                } else {
                    move = request
                }
                continue
            }
            switch modParameterClauseIntent(from: clause) {
            case .update(let update):
                updates.append(update)
            case .rejected(let reason):
                rejectedReasons.append(reason)
            case .notRecognized:
                break
            }
        }

        guard let placements,
              let move else {
            return .notRecognized
        }
        if !rejectedReasons.isEmpty {
            return .rejected(Array(Set(rejectedReasons)).sorted())
        }
        let duplicateTargets = duplicateModParameterUpdateTargets(in: updates)
        if !duplicateTargets.isEmpty {
            return .rejected(duplicateTargets.map { "Specify only one \($0) update." })
        }
        return .request(placements: placements, move: move, updates: updates)
    }

    private static func modRemovalBoundsAndParameterUpdateIntent(
        from prompt: String,
        model: AmigaProgramModel
    ) -> ModRemovalBoundsAndParameterUpdateIntent {
        let clauses = modParameterUpdateClauses(in: prompt)
        let normalizedPrompt = prompt.lowercased()
        guard clauses.count > 2,
              hasRemoveControlSignal(in: normalizedPrompt),
              hasControlBoundsSignal(in: normalizedPrompt),
              !containsWord("add", in: normalizedPrompt),
              !hasRenameSignal(in: normalizedPrompt) else {
            return .notRecognized
        }

        var label: String?
        var placements: [(label: String, bounds: AmigaProgramModel.Bounds)]?
        var updates: [ModParameterUpdate] = []
        var rejectedReasons: [String] = []
        for clause in clauses {
            if let rejection = ambiguousControlRemovalRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let request = removeControlRequest(from: clause, model: model) {
                if label != nil {
                    rejectedReasons.append("Specify only one control removal.")
                } else {
                    label = request
                }
                continue
            }
            if let rejection = ambiguousControlBoundsRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let groupPlacement = controlGroupBoundsRequest(from: clause, model: model) {
                if placements != nil {
                    rejectedReasons.append("Specify only one control bounds change.")
                } else {
                    placements = groupPlacement
                }
                continue
            }
            if let placement = controlBoundsRequest(from: clause, model: model) {
                if placements != nil {
                    rejectedReasons.append("Specify only one control bounds change.")
                } else {
                    placements = [placement]
                }
                continue
            }
            switch modParameterClauseIntent(from: clause) {
            case .update(let update):
                updates.append(update)
            case .rejected(let reason):
                rejectedReasons.append(reason)
            case .notRecognized:
                break
            }
        }

        guard let label,
              let placements,
              updates.count + rejectedReasons.count > 0 else {
            return .notRecognized
        }
        if placements.contains(where: { $0.label.caseInsensitiveCompare(label) == .orderedSame }) {
            rejectedReasons.append("Cannot change bounds for a removed control.")
        }
        if !rejectedReasons.isEmpty {
            return .rejected(Array(Set(rejectedReasons)).sorted())
        }
        let duplicateTargets = duplicateModParameterUpdateTargets(in: updates)
        if !duplicateTargets.isEmpty {
            return .rejected(duplicateTargets.map { "Specify only one \($0) update." })
        }
        return .request(label: label, placements: placements, updates: updates)
    }

    private static func modRemovalBoundsUpdateIntent(
        from prompt: String,
        model: AmigaProgramModel
    ) -> ModRemovalBoundsUpdateIntent {
        let clauses = modParameterUpdateClauses(in: prompt)
        let normalizedPrompt = prompt.lowercased()
        guard clauses.count > 1,
              hasRemoveControlSignal(in: normalizedPrompt),
              hasControlBoundsSignal(in: normalizedPrompt),
              !containsWord("add", in: normalizedPrompt),
              !hasRenameSignal(in: normalizedPrompt) else {
            return .notRecognized
        }

        var label: String?
        var placements: [(label: String, bounds: AmigaProgramModel.Bounds)]?
        var rejectedReasons: [String] = []
        for clause in clauses {
            if let rejection = ambiguousControlRemovalRejection(from: clause, model: model) ??
                ordinalControlRemovalRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let request = removeControlRequest(from: clause, model: model) {
                if label != nil {
                    rejectedReasons.append("Specify only one control removal.")
                } else {
                    label = request
                }
                continue
            }
            if let rejection = ambiguousControlBoundsRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let groupPlacement = controlGroupBoundsRequest(from: clause, model: model) {
                if placements != nil {
                    rejectedReasons.append("Specify only one control bounds change.")
                } else {
                    placements = groupPlacement
                }
                continue
            }
            if let placement = controlBoundsRequest(from: clause, model: model) {
                if placements != nil {
                    rejectedReasons.append("Specify only one control bounds change.")
                } else {
                    placements = [placement]
                }
                continue
            }
        }

        guard let label,
              let placements else {
            return .notRecognized
        }
        if placements.contains(where: { $0.label.caseInsensitiveCompare(label) == .orderedSame }) {
            rejectedReasons.append("Cannot change bounds for a removed control.")
        }
        if !rejectedReasons.isEmpty {
            return .rejected(Array(Set(rejectedReasons)).sorted())
        }
        return .request(label: label, placements: placements)
    }

    private static func modRemovalBoundsMoveAndParameterUpdateIntent(
        from prompt: String,
        model: AmigaProgramModel
    ) -> ModRemovalBoundsMoveAndParameterUpdateIntent {
        let clauses = modParameterUpdateClauses(in: prompt)
        let normalizedPrompt = prompt.lowercased()
        guard clauses.count > 2,
              hasRemoveControlSignal(in: normalizedPrompt),
              hasControlBoundsSignal(in: normalizedPrompt),
              hasMoveControlSignal(in: normalizedPrompt),
              !containsWord("add", in: normalizedPrompt),
              !hasRenameSignal(in: normalizedPrompt),
              !containsWord("make", in: normalizedPrompt),
              !containsPhrase("lower volume", in: normalizedPrompt),
              !containsPhrase("raise volume", in: normalizedPrompt) else {
            return .notRecognized
        }

        var label: String?
        var placements: [(label: String, bounds: AmigaProgramModel.Bounds)]?
        var move: (label: String, placement: AmigaProgramControlPlacement, targetLabel: String)?
        var updates: [ModParameterUpdate] = []
        var rejectedReasons: [String] = []
        for clause in clauses {
            if let rejection = ambiguousControlRemovalRejection(from: clause, model: model) ??
                ordinalControlRemovalRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let request = removeControlRequest(from: clause, model: model) {
                if label != nil {
                    rejectedReasons.append("Specify only one control removal.")
                } else {
                    label = request
                }
                continue
            }
            if let rejection = ambiguousControlBoundsRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let groupPlacement = controlGroupBoundsRequest(from: clause, model: model) {
                if placements != nil {
                    rejectedReasons.append("Specify only one control bounds change.")
                } else {
                    placements = groupPlacement
                }
                continue
            }
            if let placement = controlBoundsRequest(from: clause, model: model) {
                if placements != nil {
                    rejectedReasons.append("Specify only one control bounds change.")
                } else {
                    placements = [placement]
                }
                continue
            }
            if let rejection = ordinalControlMoveRejection(from: clause, model: model) ??
                ambiguousControlMoveRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let request = moveControlRequest(from: clause, model: model) {
                if move != nil {
                    rejectedReasons.append("Specify only one control move.")
                } else {
                    move = request
                }
                continue
            }
            switch modParameterClauseIntent(from: clause) {
            case .update(let update):
                updates.append(update)
            case .rejected(let reason):
                rejectedReasons.append(reason)
            case .notRecognized:
                break
            }
        }

        guard let label,
              let placements,
              let move else {
            return .notRecognized
        }
        if placements.contains(where: { $0.label.caseInsensitiveCompare(label) == .orderedSame }) {
            rejectedReasons.append("Cannot change bounds for a removed control.")
        }
        if move.label.caseInsensitiveCompare(label) == .orderedSame ||
            move.targetLabel.caseInsensitiveCompare(label) == .orderedSame {
            rejectedReasons.append("Cannot move a removed control or move another control relative to it.")
        }
        if !rejectedReasons.isEmpty {
            return .rejected(Array(Set(rejectedReasons)).sorted())
        }
        let duplicateTargets = duplicateModParameterUpdateTargets(in: updates)
        if !duplicateTargets.isEmpty {
            return .rejected(duplicateTargets.map { "Specify only one \($0) update." })
        }
        return .request(label: label, placements: placements, move: move, updates: updates)
    }

    private static func modRemovalRenameBoundsMoveAndParameterUpdateIntent(
        from prompt: String,
        model: AmigaProgramModel
    ) -> ModRemovalRenameBoundsMoveAndParameterUpdateIntent {
        let clauses = modParameterUpdateClauses(in: prompt)
        let normalizedPrompt = prompt.lowercased()
        guard clauses.count > 3,
              hasRemoveControlSignal(in: normalizedPrompt),
              hasRenameSignal(in: normalizedPrompt),
              hasControlBoundsSignal(in: normalizedPrompt),
              hasMoveControlSignal(in: normalizedPrompt),
              !containsWord("add", in: normalizedPrompt) else {
            return .notRecognized
        }

        var label: String?
        var rename: (currentLabel: String, newLabel: String)?
        var placement: (label: String, bounds: AmigaProgramModel.Bounds)?
        var moveClause: String?
        var updates: [ModParameterUpdate] = []
        var rejectedReasons: [String] = []
        for clause in clauses {
            if let rejection = ambiguousControlRemovalRejection(from: clause, model: model) ??
                ordinalControlRemovalRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let request = removeControlRequest(from: clause, model: model) {
                if label != nil {
                    rejectedReasons.append("Specify only one control removal.")
                } else {
                    label = request
                }
                continue
            }
            if let rejection = ordinalLabelRenameRejection(from: clause, model: model) ??
                ambiguousLabelRenameRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let request = labelRenameRequest(from: clause, model: model) {
                if rename != nil {
                    rejectedReasons.append("Specify only one control rename.")
                } else {
                    rename = request
                }
                continue
            }
            if let rejection = ambiguousControlBoundsRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let request = controlBoundsRequest(from: clause, model: model) {
                if placement != nil {
                    rejectedReasons.append("Specify only one control bounds change.")
                } else {
                    placement = request
                }
                continue
            }
            if movePlacementSeparator(in: clause) != nil {
                if moveClause != nil {
                    rejectedReasons.append("Specify only one control move.")
                } else {
                    moveClause = clause
                }
                continue
            }
            switch modParameterClauseIntent(from: clause) {
            case .update(let update):
                updates.append(update)
            case .rejected(let reason):
                rejectedReasons.append(reason)
            case .notRecognized:
                break
            }
        }

        guard let label,
              let rename,
              let placement,
              let moveClause else {
            return .notRecognized
        }
        if rename.currentLabel.caseInsensitiveCompare(label) == .orderedSame {
            rejectedReasons.append("Cannot rename a removed control.")
        }
        if placement.label.caseInsensitiveCompare(label) == .orderedSame {
            rejectedReasons.append("Cannot change bounds for a removed control.")
        }
        if placement.label.caseInsensitiveCompare(rename.currentLabel) != .orderedSame {
            rejectedReasons.append("Specify the same control for rename, bounds, and move changes.")
        }
        if let move = moveControlRequest(from: moveClause, model: model),
           move.label.caseInsensitiveCompare(label) == .orderedSame ||
            move.targetLabel.caseInsensitiveCompare(label) == .orderedSame {
            rejectedReasons.append("Cannot move a removed control or move another control relative to it.")
        }
        if !rejectedReasons.isEmpty {
            return .rejected(Array(Set(rejectedReasons)).sorted())
        }
        let duplicateTargets = duplicateModParameterUpdateTargets(in: updates)
        if !duplicateTargets.isEmpty {
            return .rejected(duplicateTargets.map { "Specify only one \($0) update." })
        }
        return .request(label: label, rename: rename, placement: placement, moveClause: moveClause, updates: updates)
    }

    private static func modRemovalRenameAndParameterUpdateIntent(
        from prompt: String,
        model: AmigaProgramModel
    ) -> ModRemovalRenameAndParameterUpdateIntent {
        let clauses = modParameterUpdateClauses(in: prompt)
        let normalizedPrompt = prompt.lowercased()
        guard clauses.count > 1,
              hasRemoveControlSignal(in: normalizedPrompt),
              hasRenameSignal(in: normalizedPrompt),
              !hasControlBoundsSignal(in: normalizedPrompt),
              !hasMoveControlSignal(in: normalizedPrompt),
              !containsWord("add", in: normalizedPrompt) else {
            return .notRecognized
        }

        var label: String?
        var rename: (currentLabel: String, newLabel: String)?
        var updates: [ModParameterUpdate] = []
        var rejectedReasons: [String] = []
        for clause in clauses {
            if let rejection = ambiguousControlRemovalRejection(from: clause, model: model) ??
                ordinalControlRemovalRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let request = removeControlRequest(from: clause, model: model) {
                if label != nil {
                    rejectedReasons.append("Specify only one control removal.")
                } else {
                    label = request
                }
                continue
            }
            if let rejection = ordinalLabelRenameRejection(from: clause, model: model) ??
                ambiguousLabelRenameRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let request = labelRenameRequest(from: clause, model: model) {
                if rename != nil {
                    rejectedReasons.append("Specify only one control rename.")
                } else {
                    rename = request
                }
                continue
            }
            switch modParameterClauseIntent(from: clause) {
            case .update(let update):
                updates.append(update)
            case .rejected(let reason):
                rejectedReasons.append(reason)
            case .notRecognized:
                break
            }
        }

        guard let label,
              let rename else {
            return .notRecognized
        }
        if rename.currentLabel.caseInsensitiveCompare(label) == .orderedSame {
            rejectedReasons.append("Cannot rename a removed control.")
        }
        if !rejectedReasons.isEmpty {
            return .rejected(Array(Set(rejectedReasons)).sorted())
        }
        let duplicateTargets = duplicateModParameterUpdateTargets(in: updates)
        if !duplicateTargets.isEmpty {
            return .rejected(duplicateTargets.map { "Specify only one \($0) update." })
        }
        return .request(label: label, rename: rename, updates: updates)
    }

    private static func modRemovalRenameMoveAndParameterUpdateIntent(
        from prompt: String,
        model: AmigaProgramModel
    ) -> ModRemovalRenameMoveAndParameterUpdateIntent {
        let clauses = modParameterUpdateClauses(in: prompt)
        let normalizedPrompt = prompt.lowercased()
        guard clauses.count > 2,
              hasRemoveControlSignal(in: normalizedPrompt),
              hasRenameSignal(in: normalizedPrompt),
              hasMoveControlSignal(in: normalizedPrompt),
              !hasControlBoundsSignal(in: normalizedPrompt),
              !containsWord("add", in: normalizedPrompt) else {
            return .notRecognized
        }

        var label: String?
        var rename: (currentLabel: String, newLabel: String)?
        var moveClause: String?
        var updates: [ModParameterUpdate] = []
        var rejectedReasons: [String] = []
        for clause in clauses {
            if let rejection = ambiguousControlRemovalRejection(from: clause, model: model) ??
                ordinalControlRemovalRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let request = removeControlRequest(from: clause, model: model) {
                if label != nil {
                    rejectedReasons.append("Specify only one control removal.")
                } else {
                    label = request
                }
                continue
            }
            if let rejection = ordinalLabelRenameRejection(from: clause, model: model) ??
                ambiguousLabelRenameRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let request = labelRenameRequest(from: clause, model: model) {
                if rename != nil {
                    rejectedReasons.append("Specify only one control rename.")
                } else {
                    rename = request
                }
                continue
            }
            if movePlacementSeparator(in: clause) != nil {
                if moveClause != nil {
                    rejectedReasons.append("Specify only one control move.")
                } else {
                    moveClause = clause
                }
                continue
            }
            switch modParameterClauseIntent(from: clause) {
            case .update(let update):
                updates.append(update)
            case .rejected(let reason):
                rejectedReasons.append(reason)
            case .notRecognized:
                break
            }
        }

        guard let label,
              let rename,
              let moveClause else {
            return .notRecognized
        }
        if rename.currentLabel.caseInsensitiveCompare(label) == .orderedSame {
            rejectedReasons.append("Cannot rename a removed control.")
        }
        if let move = moveControlRequest(from: moveClause, model: model),
           move.label.caseInsensitiveCompare(label) == .orderedSame ||
            move.targetLabel.caseInsensitiveCompare(label) == .orderedSame {
            rejectedReasons.append("Cannot move a removed control or move another control relative to it.")
        }
        if !rejectedReasons.isEmpty {
            return .rejected(Array(Set(rejectedReasons)).sorted())
        }
        let duplicateTargets = duplicateModParameterUpdateTargets(in: updates)
        if !duplicateTargets.isEmpty {
            return .rejected(duplicateTargets.map { "Specify only one \($0) update." })
        }
        return .request(label: label, rename: rename, moveClause: moveClause, updates: updates)
    }

    private static func modRemovalRenameBoundsAndParameterUpdateIntent(
        from prompt: String,
        model: AmigaProgramModel
    ) -> ModRemovalRenameBoundsAndParameterUpdateIntent {
        let clauses = modParameterUpdateClauses(in: prompt)
        let normalizedPrompt = prompt.lowercased()
        guard clauses.count > 2,
              hasRemoveControlSignal(in: normalizedPrompt),
              hasRenameSignal(in: normalizedPrompt),
              hasControlBoundsSignal(in: normalizedPrompt),
              !hasMoveControlSignal(in: normalizedPrompt),
              !containsWord("add", in: normalizedPrompt) else {
            return .notRecognized
        }

        var label: String?
        var rename: (currentLabel: String, newLabel: String)?
        var placement: (label: String, bounds: AmigaProgramModel.Bounds)?
        var updates: [ModParameterUpdate] = []
        var rejectedReasons: [String] = []
        for clause in clauses {
            if let rejection = ambiguousControlRemovalRejection(from: clause, model: model) ??
                ordinalControlRemovalRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let request = removeControlRequest(from: clause, model: model) {
                if label != nil {
                    rejectedReasons.append("Specify only one control removal.")
                } else {
                    label = request
                }
                continue
            }
            if let rejection = ordinalLabelRenameRejection(from: clause, model: model) ??
                ambiguousLabelRenameRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let request = labelRenameRequest(from: clause, model: model) {
                if rename != nil {
                    rejectedReasons.append("Specify only one control rename.")
                } else {
                    rename = request
                }
                continue
            }
            if let rejection = ambiguousControlBoundsRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let request = controlBoundsRequest(from: clause, model: model) {
                if placement != nil {
                    rejectedReasons.append("Specify only one control bounds change.")
                } else {
                    placement = request
                }
                continue
            }
            switch modParameterClauseIntent(from: clause) {
            case .update(let update):
                updates.append(update)
            case .rejected(let reason):
                rejectedReasons.append(reason)
            case .notRecognized:
                break
            }
        }

        guard let label,
              let rename,
              let placement else {
            return .notRecognized
        }
        if rename.currentLabel.caseInsensitiveCompare(label) == .orderedSame {
            rejectedReasons.append("Cannot rename a removed control.")
        }
        if placement.label.caseInsensitiveCompare(label) == .orderedSame {
            rejectedReasons.append("Cannot change bounds for a removed control.")
        }
        if placement.label.caseInsensitiveCompare(rename.currentLabel) != .orderedSame {
            rejectedReasons.append("Specify the same control for rename and bounds changes.")
        }
        if !rejectedReasons.isEmpty {
            return .rejected(Array(Set(rejectedReasons)).sorted())
        }
        let duplicateTargets = duplicateModParameterUpdateTargets(in: updates)
        if !duplicateTargets.isEmpty {
            return .rejected(duplicateTargets.map { "Specify only one \($0) update." })
        }
        return .request(label: label, rename: rename, placement: placement, updates: updates)
    }

    private static func modRemovalLabelBehaviorAndParameterUpdateIntent(
        from prompt: String,
        model: AmigaProgramModel
    ) -> ModRemovalLabelBehaviorAndParameterUpdateIntent {
        let clauses = modParameterUpdateClauses(in: prompt)
        let normalizedPrompt = prompt.lowercased()
        guard clauses.count > 1,
              hasRemoveControlSignal(in: normalizedPrompt),
              hasRenameSignal(in: normalizedPrompt),
              hasBehaviorChangeSignal(in: normalizedPrompt),
              !hasControlBoundsSignal(in: normalizedPrompt),
              !hasMoveControlSignal(in: normalizedPrompt),
              !containsWord("add", in: normalizedPrompt) else {
            return .notRecognized
        }

        var label: String?
        var structuralClauses: [String] = []
        var updates: [ModParameterUpdate] = []
        var rejectedReasons: [String] = []
        for clause in clauses {
            if let rejection = ambiguousControlRemovalRejection(from: clause, model: model) ??
                ordinalControlRemovalRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let request = removeControlRequest(from: clause, model: model) {
                if label != nil {
                    rejectedReasons.append("Specify only one control removal.")
                } else {
                    label = request
                }
                continue
            }
            switch modParameterClauseIntent(from: clause) {
            case .update(let update):
                updates.append(update)
                continue
            case .rejected(let reason):
                rejectedReasons.append(reason)
                continue
            case .notRecognized:
                break
            }
            structuralClauses.append(clause)
        }

        let structuralPrompt = structuralClauses.joined(separator: " and ")
        if let rejection = conflictingControlBehaviorChangeRejection(from: structuralPrompt, model: model) ??
            duplicateControlLabelAndBehaviorChangeRejection(from: structuralPrompt, model: model) {
            rejectedReasons.append(rejection)
        }

        guard let label,
              let change = controlLabelAndBehaviorChangeRequest(from: structuralPrompt, model: model) else {
            return .notRecognized
        }
        if change.currentLabel.caseInsensitiveCompare(label) == .orderedSame {
            rejectedReasons.append("Cannot change label or behavior for a removed control.")
        }
        if !rejectedReasons.isEmpty {
            return .rejected(Array(Set(rejectedReasons)).sorted())
        }
        let duplicateTargets = duplicateModParameterUpdateTargets(in: updates)
        if !duplicateTargets.isEmpty {
            return .rejected(duplicateTargets.map { "Specify only one \($0) update." })
        }
        return .request(label: label, change: change, updates: updates)
    }

    private static func modRemovalLabelBehaviorBoundsAndParameterUpdateIntent(
        from prompt: String,
        model: AmigaProgramModel
    ) -> ModRemovalLabelBehaviorBoundsAndParameterUpdateIntent {
        let clauses = modParameterUpdateClauses(in: prompt)
        let normalizedPrompt = prompt.lowercased()
        guard clauses.count > 2,
              hasRemoveControlSignal(in: normalizedPrompt),
              hasRenameSignal(in: normalizedPrompt),
              hasBehaviorChangeSignal(in: normalizedPrompt),
              hasControlBoundsSignal(in: normalizedPrompt),
              !hasMoveControlSignal(in: normalizedPrompt),
              !containsWord("add", in: normalizedPrompt) else {
            return .notRecognized
        }

        var label: String?
        var structuralClauses: [String] = []
        var placement: (label: String, bounds: AmigaProgramModel.Bounds)?
        var updates: [ModParameterUpdate] = []
        var rejectedReasons: [String] = []
        for clause in clauses {
            if let rejection = ambiguousControlRemovalRejection(from: clause, model: model) ??
                ordinalControlRemovalRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let request = removeControlRequest(from: clause, model: model) {
                if label != nil {
                    rejectedReasons.append("Specify only one control removal.")
                } else {
                    label = request
                }
                continue
            }
            switch modParameterClauseIntent(from: clause) {
            case .update(let update):
                updates.append(update)
                continue
            case .rejected(let reason):
                rejectedReasons.append(reason)
                continue
            case .notRecognized:
                break
            }
            if let rejection = ambiguousControlBoundsRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let request = controlBoundsRequest(from: clause, model: model) {
                if placement != nil {
                    rejectedReasons.append("Specify only one control bounds change.")
                } else {
                    placement = request
                }
                continue
            }
            structuralClauses.append(clause)
        }

        let structuralPrompt = structuralClauses.joined(separator: " and ")
        if let rejection = conflictingControlBehaviorChangeRejection(from: structuralPrompt, model: model) ??
            duplicateControlLabelAndBehaviorChangeRejection(from: structuralPrompt, model: model) {
            rejectedReasons.append(rejection)
        }

        guard let label,
              let change = controlLabelAndBehaviorChangeRequest(from: structuralPrompt, model: model),
              let placement else {
            return .notRecognized
        }
        if change.currentLabel.caseInsensitiveCompare(label) == .orderedSame {
            rejectedReasons.append("Cannot change label or behavior for a removed control.")
        }
        if placement.label.caseInsensitiveCompare(label) == .orderedSame {
            rejectedReasons.append("Cannot change bounds for a removed control.")
        }
        if placement.label.caseInsensitiveCompare(change.currentLabel) != .orderedSame {
            rejectedReasons.append("Specify the same control for label, behavior, and bounds changes.")
        }
        if !rejectedReasons.isEmpty {
            return .rejected(Array(Set(rejectedReasons)).sorted())
        }
        let duplicateTargets = duplicateModParameterUpdateTargets(in: updates)
        if !duplicateTargets.isEmpty {
            return .rejected(duplicateTargets.map { "Specify only one \($0) update." })
        }
        return .request(label: label, change: change, placement: placement, updates: updates)
    }

    private static func modRemovalLabelBehaviorMoveAndParameterUpdateIntent(
        from prompt: String,
        model: AmigaProgramModel
    ) -> ModRemovalLabelBehaviorMoveAndParameterUpdateIntent {
        let clauses = modParameterUpdateClauses(in: prompt)
        let normalizedPrompt = prompt.lowercased()
        guard clauses.count > 2,
              hasRemoveControlSignal(in: normalizedPrompt),
              hasRenameSignal(in: normalizedPrompt),
              hasBehaviorChangeSignal(in: normalizedPrompt),
              hasMoveControlSignal(in: normalizedPrompt),
              !hasControlBoundsSignal(in: normalizedPrompt),
              !containsWord("add", in: normalizedPrompt) else {
            return .notRecognized
        }

        var label: String?
        var structuralClauses: [String] = []
        var moveClause: String?
        var updates: [ModParameterUpdate] = []
        var rejectedReasons: [String] = []
        for clause in clauses {
            if let rejection = ambiguousControlRemovalRejection(from: clause, model: model) ??
                ordinalControlRemovalRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let request = removeControlRequest(from: clause, model: model) {
                if label != nil {
                    rejectedReasons.append("Specify only one control removal.")
                } else {
                    label = request
                }
                continue
            }
            switch modParameterClauseIntent(from: clause) {
            case .update(let update):
                updates.append(update)
                continue
            case .rejected(let reason):
                rejectedReasons.append(reason)
                continue
            case .notRecognized:
                break
            }
            if movePlacementSeparator(in: clause) != nil {
                if moveClause != nil {
                    rejectedReasons.append("Specify only one control move.")
                } else {
                    moveClause = clause
                }
                continue
            }
            structuralClauses.append(clause)
        }

        let structuralPrompt = structuralClauses.joined(separator: " and ")
        if let rejection = conflictingControlBehaviorChangeRejection(from: structuralPrompt, model: model) ??
            duplicateControlLabelAndBehaviorChangeRejection(from: structuralPrompt, model: model) {
            rejectedReasons.append(rejection)
        }

        guard let label,
              let change = controlLabelAndBehaviorChangeRequest(from: structuralPrompt, model: model),
              let moveClause else {
            return .notRecognized
        }
        if change.currentLabel.caseInsensitiveCompare(label) == .orderedSame {
            rejectedReasons.append("Cannot change label or behavior for a removed control.")
        }
        if let move = moveControlRequest(from: moveClause, model: model),
           move.label.caseInsensitiveCompare(label) == .orderedSame ||
            move.targetLabel.caseInsensitiveCompare(label) == .orderedSame {
            rejectedReasons.append("Cannot move a removed control or move another control relative to it.")
        }
        if !rejectedReasons.isEmpty {
            return .rejected(Array(Set(rejectedReasons)).sorted())
        }
        let duplicateTargets = duplicateModParameterUpdateTargets(in: updates)
        if !duplicateTargets.isEmpty {
            return .rejected(duplicateTargets.map { "Specify only one \($0) update." })
        }
        return .request(label: label, change: change, moveClause: moveClause, updates: updates)
    }

    private static func modRemovalLabelBehaviorBoundsMoveAndParameterUpdateIntent(
        from prompt: String,
        model: AmigaProgramModel
    ) -> ModRemovalLabelBehaviorBoundsMoveAndParameterUpdateIntent {
        let clauses = modParameterUpdateClauses(in: prompt)
        let normalizedPrompt = prompt.lowercased()
        guard clauses.count > 3,
              hasRemoveControlSignal(in: normalizedPrompt),
              hasRenameSignal(in: normalizedPrompt),
              hasBehaviorChangeSignal(in: normalizedPrompt),
              hasControlBoundsSignal(in: normalizedPrompt),
              hasMoveControlSignal(in: normalizedPrompt),
              !containsWord("add", in: normalizedPrompt) else {
            return .notRecognized
        }

        var label: String?
        var structuralClauses: [String] = []
        var placement: (label: String, bounds: AmigaProgramModel.Bounds)?
        var moveClause: String?
        var updates: [ModParameterUpdate] = []
        var rejectedReasons: [String] = []
        for clause in clauses {
            if let rejection = ambiguousControlRemovalRejection(from: clause, model: model) ??
                ordinalControlRemovalRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let request = removeControlRequest(from: clause, model: model) {
                if label != nil {
                    rejectedReasons.append("Specify only one control removal.")
                } else {
                    label = request
                }
                continue
            }
            switch modParameterClauseIntent(from: clause) {
            case .update(let update):
                updates.append(update)
                continue
            case .rejected(let reason):
                rejectedReasons.append(reason)
                continue
            case .notRecognized:
                break
            }
            if movePlacementSeparator(in: clause) != nil {
                if moveClause != nil {
                    rejectedReasons.append("Specify only one control move.")
                } else {
                    moveClause = clause
                }
                continue
            }
            if let rejection = ambiguousControlBoundsRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let request = controlBoundsRequest(from: clause, model: model) {
                if placement != nil {
                    rejectedReasons.append("Specify only one control bounds change.")
                } else {
                    placement = request
                }
                continue
            }
            structuralClauses.append(clause)
        }

        let structuralPrompt = structuralClauses.joined(separator: " and ")
        if let rejection = conflictingControlBehaviorChangeRejection(from: structuralPrompt, model: model) ??
            duplicateControlLabelAndBehaviorChangeRejection(from: structuralPrompt, model: model) {
            rejectedReasons.append(rejection)
        }

        guard let label,
              let change = controlLabelAndBehaviorChangeRequest(from: structuralPrompt, model: model),
              let placement,
              let moveClause else {
            return .notRecognized
        }
        if change.currentLabel.caseInsensitiveCompare(label) == .orderedSame {
            rejectedReasons.append("Cannot change label or behavior for a removed control.")
        }
        if placement.label.caseInsensitiveCompare(label) == .orderedSame {
            rejectedReasons.append("Cannot change bounds for a removed control.")
        }
        if placement.label.caseInsensitiveCompare(change.currentLabel) != .orderedSame {
            rejectedReasons.append("Specify the same control for label, behavior, bounds, and move changes.")
        }
        if let move = moveControlRequest(from: moveClause, model: model),
           move.label.caseInsensitiveCompare(label) == .orderedSame ||
            move.targetLabel.caseInsensitiveCompare(label) == .orderedSame {
            rejectedReasons.append("Cannot move a removed control or move another control relative to it.")
        }
        if !rejectedReasons.isEmpty {
            return .rejected(Array(Set(rejectedReasons)).sorted())
        }
        let duplicateTargets = duplicateModParameterUpdateTargets(in: updates)
        if !duplicateTargets.isEmpty {
            return .rejected(duplicateTargets.map { "Specify only one \($0) update." })
        }
        return .request(label: label, change: change, placement: placement, moveClause: moveClause, updates: updates)
    }

    private static func modRemovalBehaviorAndParameterUpdateIntent(
        from prompt: String,
        model: AmigaProgramModel
    ) -> ModRemovalBehaviorAndParameterUpdateIntent {
        let clauses = modParameterUpdateClauses(in: prompt)
        let normalizedPrompt = prompt.lowercased()
        guard clauses.count > 1,
              hasRemoveControlSignal(in: normalizedPrompt),
              hasBehaviorChangeSignal(in: normalizedPrompt),
              !hasRenameSignal(in: normalizedPrompt),
              !hasControlBoundsSignal(in: normalizedPrompt),
              !hasMoveControlSignal(in: normalizedPrompt),
              !containsWord("add", in: normalizedPrompt) else {
            return .notRecognized
        }

        var label: String?
        var behavior: (label: String, action: String)?
        var updates: [ModParameterUpdate] = []
        var rejectedReasons: [String] = []
        for clause in clauses {
            if let rejection = ambiguousControlRemovalRejection(from: clause, model: model) ??
                ordinalControlRemovalRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let request = removeControlRequest(from: clause, model: model) {
                if label != nil {
                    rejectedReasons.append("Specify only one control removal.")
                } else {
                    label = request
                }
                continue
            }
            if let rejection = conflictingControlBehaviorChangeRejection(from: clause, model: model) ??
                duplicateControlLabelAndBehaviorChangeRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let request = controlBehaviorChangeRequest(from: clause, model: model) {
                if behavior != nil {
                    rejectedReasons.append("Specify only one control behavior change.")
                } else {
                    behavior = request
                }
                continue
            }
            switch modParameterClauseIntent(from: clause) {
            case .update(let update):
                updates.append(update)
            case .rejected(let reason):
                rejectedReasons.append(reason)
            case .notRecognized:
                break
            }
        }

        guard let label,
              let behavior else {
            return .notRecognized
        }
        if behavior.label.caseInsensitiveCompare(label) == .orderedSame {
            rejectedReasons.append("Cannot change behavior for a removed control.")
        }
        if !rejectedReasons.isEmpty {
            return .rejected(Array(Set(rejectedReasons)).sorted())
        }
        let duplicateTargets = duplicateModParameterUpdateTargets(in: updates)
        if !duplicateTargets.isEmpty {
            return .rejected(duplicateTargets.map { "Specify only one \($0) update." })
        }
        return .request(label: label, behavior: behavior, updates: updates)
    }

    private static func modRemovalBehaviorMoveAndParameterUpdateIntent(
        from prompt: String,
        model: AmigaProgramModel
    ) -> ModRemovalBehaviorMoveAndParameterUpdateIntent {
        let clauses = modParameterUpdateClauses(in: prompt)
        let normalizedPrompt = prompt.lowercased()
        guard clauses.count > 2,
              hasRemoveControlSignal(in: normalizedPrompt),
              hasBehaviorChangeSignal(in: normalizedPrompt),
              hasMoveControlSignal(in: normalizedPrompt),
              !hasRenameSignal(in: normalizedPrompt),
              !hasControlBoundsSignal(in: normalizedPrompt),
              !containsWord("add", in: normalizedPrompt) else {
            return .notRecognized
        }

        var label: String?
        var behavior: (label: String, action: String)?
        var moveClause: String?
        var updates: [ModParameterUpdate] = []
        var rejectedReasons: [String] = []
        for clause in clauses {
            if let rejection = ambiguousControlRemovalRejection(from: clause, model: model) ??
                ordinalControlRemovalRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let request = removeControlRequest(from: clause, model: model) {
                if label != nil {
                    rejectedReasons.append("Specify only one control removal.")
                } else {
                    label = request
                }
                continue
            }
            if let rejection = conflictingControlBehaviorChangeRejection(from: clause, model: model) ??
                duplicateControlLabelAndBehaviorChangeRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let request = controlBehaviorChangeRequest(from: clause, model: model) {
                if behavior != nil {
                    rejectedReasons.append("Specify only one control behavior change.")
                } else {
                    behavior = request
                }
                continue
            }
            if movePlacementSeparator(in: clause) != nil {
                if moveClause != nil {
                    rejectedReasons.append("Specify only one control move.")
                } else {
                    moveClause = clause
                }
                continue
            }
            switch modParameterClauseIntent(from: clause) {
            case .update(let update):
                updates.append(update)
            case .rejected(let reason):
                rejectedReasons.append(reason)
            case .notRecognized:
                break
            }
        }

        guard let label,
              let behavior,
              let moveClause else {
            return .notRecognized
        }
        if behavior.label.caseInsensitiveCompare(label) == .orderedSame {
            rejectedReasons.append("Cannot change behavior for a removed control.")
        }
        if let move = moveControlRequest(from: moveClause, model: model),
           move.label.caseInsensitiveCompare(label) == .orderedSame ||
            move.targetLabel.caseInsensitiveCompare(label) == .orderedSame {
            rejectedReasons.append("Cannot move a removed control or move another control relative to it.")
        }
        if !rejectedReasons.isEmpty {
            return .rejected(Array(Set(rejectedReasons)).sorted())
        }
        let duplicateTargets = duplicateModParameterUpdateTargets(in: updates)
        if !duplicateTargets.isEmpty {
            return .rejected(duplicateTargets.map { "Specify only one \($0) update." })
        }
        return .request(label: label, behavior: behavior, moveClause: moveClause, updates: updates)
    }

    private static func modRemovalBehaviorBoundsAndParameterUpdateIntent(
        from prompt: String,
        model: AmigaProgramModel
    ) -> ModRemovalBehaviorBoundsAndParameterUpdateIntent {
        let clauses = modParameterUpdateClauses(in: prompt)
        let normalizedPrompt = prompt.lowercased()
        guard clauses.count > 2,
              hasRemoveControlSignal(in: normalizedPrompt),
              hasBehaviorChangeSignal(in: normalizedPrompt),
              hasControlBoundsSignal(in: normalizedPrompt),
              !hasRenameSignal(in: normalizedPrompt),
              !hasMoveControlSignal(in: normalizedPrompt),
              !containsWord("add", in: normalizedPrompt) else {
            return .notRecognized
        }

        var label: String?
        var behavior: (label: String, action: String)?
        var placement: (label: String, bounds: AmigaProgramModel.Bounds)?
        var updates: [ModParameterUpdate] = []
        var rejectedReasons: [String] = []
        for clause in clauses {
            if let rejection = ambiguousControlRemovalRejection(from: clause, model: model) ??
                ordinalControlRemovalRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let request = removeControlRequest(from: clause, model: model) {
                if label != nil {
                    rejectedReasons.append("Specify only one control removal.")
                } else {
                    label = request
                }
                continue
            }
            if let rejection = conflictingControlBehaviorChangeRejection(from: clause, model: model) ??
                duplicateControlLabelAndBehaviorChangeRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let request = controlBehaviorChangeRequest(from: clause, model: model) {
                if behavior != nil {
                    rejectedReasons.append("Specify only one control behavior change.")
                } else {
                    behavior = request
                }
                continue
            }
            if let rejection = ambiguousControlBoundsRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let request = controlBoundsRequest(from: clause, model: model) {
                if placement != nil {
                    rejectedReasons.append("Specify only one control bounds change.")
                } else {
                    placement = request
                }
                continue
            }
            switch modParameterClauseIntent(from: clause) {
            case .update(let update):
                updates.append(update)
            case .rejected(let reason):
                rejectedReasons.append(reason)
            case .notRecognized:
                break
            }
        }

        guard let label,
              let behavior,
              let placement else {
            return .notRecognized
        }
        if behavior.label.caseInsensitiveCompare(label) == .orderedSame {
            rejectedReasons.append("Cannot change behavior for a removed control.")
        }
        if placement.label.caseInsensitiveCompare(label) == .orderedSame {
            rejectedReasons.append("Cannot change bounds for a removed control.")
        }
        if placement.label.caseInsensitiveCompare(behavior.label) != .orderedSame {
            rejectedReasons.append("Specify the same control for behavior and bounds changes.")
        }
        if !rejectedReasons.isEmpty {
            return .rejected(Array(Set(rejectedReasons)).sorted())
        }
        let duplicateTargets = duplicateModParameterUpdateTargets(in: updates)
        if !duplicateTargets.isEmpty {
            return .rejected(duplicateTargets.map { "Specify only one \($0) update." })
        }
        return .request(label: label, behavior: behavior, placement: placement, updates: updates)
    }

    private static func modRemovalBehaviorBoundsMoveAndParameterUpdateIntent(
        from prompt: String,
        model: AmigaProgramModel
    ) -> ModRemovalBehaviorBoundsMoveAndParameterUpdateIntent {
        let clauses = modParameterUpdateClauses(in: prompt)
        let normalizedPrompt = prompt.lowercased()
        guard clauses.count > 3,
              hasRemoveControlSignal(in: normalizedPrompt),
              hasBehaviorChangeSignal(in: normalizedPrompt),
              hasControlBoundsSignal(in: normalizedPrompt),
              hasMoveControlSignal(in: normalizedPrompt),
              !hasRenameSignal(in: normalizedPrompt),
              !containsWord("add", in: normalizedPrompt) else {
            return .notRecognized
        }

        var label: String?
        var behavior: (label: String, action: String)?
        var placement: (label: String, bounds: AmigaProgramModel.Bounds)?
        var moveClause: String?
        var updates: [ModParameterUpdate] = []
        var rejectedReasons: [String] = []
        for clause in clauses {
            if let rejection = ambiguousControlRemovalRejection(from: clause, model: model) ??
                ordinalControlRemovalRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let request = removeControlRequest(from: clause, model: model) {
                if label != nil {
                    rejectedReasons.append("Specify only one control removal.")
                } else {
                    label = request
                }
                continue
            }
            if let rejection = conflictingControlBehaviorChangeRejection(from: clause, model: model) ??
                duplicateControlLabelAndBehaviorChangeRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let request = controlBehaviorChangeRequest(from: clause, model: model) {
                if behavior != nil {
                    rejectedReasons.append("Specify only one control behavior change.")
                } else {
                    behavior = request
                }
                continue
            }
            if let rejection = ambiguousControlBoundsRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let request = controlBoundsRequest(from: clause, model: model) {
                if placement != nil {
                    rejectedReasons.append("Specify only one control bounds change.")
                } else {
                    placement = request
                }
                continue
            }
            if movePlacementSeparator(in: clause) != nil {
                if moveClause != nil {
                    rejectedReasons.append("Specify only one control move.")
                } else {
                    moveClause = clause
                }
                continue
            }
            switch modParameterClauseIntent(from: clause) {
            case .update(let update):
                updates.append(update)
            case .rejected(let reason):
                rejectedReasons.append(reason)
            case .notRecognized:
                break
            }
        }

        guard let label,
              let behavior,
              let placement,
              let moveClause else {
            return .notRecognized
        }
        if behavior.label.caseInsensitiveCompare(label) == .orderedSame {
            rejectedReasons.append("Cannot change behavior for a removed control.")
        }
        if placement.label.caseInsensitiveCompare(label) == .orderedSame {
            rejectedReasons.append("Cannot change bounds for a removed control.")
        }
        if placement.label.caseInsensitiveCompare(behavior.label) != .orderedSame {
            rejectedReasons.append("Specify the same control for behavior, bounds, and move changes.")
        }
        if let move = moveControlRequest(from: moveClause, model: model),
           move.label.caseInsensitiveCompare(label) == .orderedSame ||
            move.targetLabel.caseInsensitiveCompare(label) == .orderedSame {
            rejectedReasons.append("Cannot move a removed control or move another control relative to it.")
        }
        if !rejectedReasons.isEmpty {
            return .rejected(Array(Set(rejectedReasons)).sorted())
        }
        let duplicateTargets = duplicateModParameterUpdateTargets(in: updates)
        if !duplicateTargets.isEmpty {
            return .rejected(duplicateTargets.map { "Specify only one \($0) update." })
        }
        return .request(label: label, behavior: behavior, placement: placement, moveClause: moveClause, updates: updates)
    }

    private static func modRemovalMoveAndParameterUpdateIntent(
        from prompt: String,
        model: AmigaProgramModel
    ) -> ModRemovalMoveAndParameterUpdateIntent {
        let clauses = modParameterUpdateClauses(in: prompt)
        let normalizedPrompt = prompt.lowercased()
        guard clauses.count > 2,
              hasRemoveControlSignal(in: normalizedPrompt),
              hasMoveControlSignal(in: normalizedPrompt),
              !containsWord("add", in: normalizedPrompt),
              !hasRenameSignal(in: normalizedPrompt) else {
            return .notRecognized
        }

        var label: String?
        var move: (label: String, placement: AmigaProgramControlPlacement, targetLabel: String)?
        var updates: [ModParameterUpdate] = []
        var rejectedReasons: [String] = []
        for clause in clauses {
            if let rejection = ambiguousControlRemovalRejection(from: clause, model: model) ??
                ordinalControlRemovalRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let request = removeControlRequest(from: clause, model: model) {
                if label != nil {
                    rejectedReasons.append("Specify only one control removal.")
                } else {
                    label = request
                }
                continue
            }
            if let rejection = ordinalControlMoveRejection(from: clause, model: model) ??
                ambiguousControlMoveRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let request = moveControlRequest(from: clause, model: model) {
                if move != nil {
                    rejectedReasons.append("Specify only one control move.")
                } else {
                    move = request
                }
                continue
            }
            switch modParameterClauseIntent(from: clause) {
            case .update(let update):
                updates.append(update)
            case .rejected(let reason):
                rejectedReasons.append(reason)
            case .notRecognized:
                break
            }
        }

        guard let label,
              let move,
              updates.count + rejectedReasons.count > 0 else {
            return .notRecognized
        }
        if move.label.caseInsensitiveCompare(label) == .orderedSame ||
            move.targetLabel.caseInsensitiveCompare(label) == .orderedSame {
            rejectedReasons.append("Cannot move a removed control or move another control relative to it.")
        }
        if !rejectedReasons.isEmpty {
            return .rejected(Array(Set(rejectedReasons)).sorted())
        }
        let duplicateTargets = duplicateModParameterUpdateTargets(in: updates)
        if !duplicateTargets.isEmpty {
            return .rejected(duplicateTargets.map { "Specify only one \($0) update." })
        }
        return .request(label: label, move: move, updates: updates)
    }

    private static func modRemovalMoveUpdateIntent(
        from prompt: String,
        model: AmigaProgramModel
    ) -> ModRemovalMoveUpdateIntent {
        let clauses = modParameterUpdateClauses(in: prompt)
        let normalizedPrompt = prompt.lowercased()
        guard clauses.count > 1,
              hasRemoveControlSignal(in: normalizedPrompt),
              hasMoveControlSignal(in: normalizedPrompt),
              !containsWord("add", in: normalizedPrompt),
              !hasRenameSignal(in: normalizedPrompt) else {
            return .notRecognized
        }

        var label: String?
        var move: (label: String, placement: AmigaProgramControlPlacement, targetLabel: String)?
        var rejectedReasons: [String] = []
        for clause in clauses {
            if let rejection = ambiguousControlRemovalRejection(from: clause, model: model) ??
                ordinalControlRemovalRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let request = removeControlRequest(from: clause, model: model) {
                if label != nil {
                    rejectedReasons.append("Specify only one control removal.")
                } else {
                    label = request
                }
                continue
            }
            if let rejection = ordinalControlMoveRejection(from: clause, model: model) ??
                ambiguousControlMoveRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let request = moveControlRequest(from: clause, model: model) {
                if move != nil {
                    rejectedReasons.append("Specify only one control move.")
                } else {
                    move = request
                }
                continue
            }
        }

        guard let label,
              let move else {
            return .notRecognized
        }
        if move.label.caseInsensitiveCompare(label) == .orderedSame ||
            move.targetLabel.caseInsensitiveCompare(label) == .orderedSame {
            rejectedReasons.append("Cannot move a removed control or move another control relative to it.")
        }
        if !rejectedReasons.isEmpty {
            return .rejected(Array(Set(rejectedReasons)).sorted())
        }
        return .request(label: label, move: move)
    }

    private static func modRemovalAndParameterUpdateIntent(
        from prompt: String,
        model: AmigaProgramModel
    ) -> ModRemovalAndParameterUpdateIntent {
        let clauses = modParameterUpdateClauses(in: prompt)
        let normalizedPrompt = prompt.lowercased()
        guard clauses.count > 1,
              hasRemoveControlSignal(in: normalizedPrompt),
              !hasRenameSignal(in: normalizedPrompt),
              !containsWord("add", in: normalizedPrompt) else {
            return .notRecognized
        }

        var label: String?
        var updates: [ModParameterUpdate] = []
        var rejectedReasons: [String] = []
        for clause in clauses {
            if let rejection = ambiguousControlRemovalRejection(from: clause, model: model) ??
                ordinalControlRemovalRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let request = removeControlRequest(from: clause, model: model) {
                if label != nil {
                    rejectedReasons.append("Specify only one control removal.")
                } else {
                    label = request
                }
                continue
            }
            switch modParameterClauseIntent(from: clause) {
            case .update(let update):
                updates.append(update)
            case .rejected(let reason):
                rejectedReasons.append(reason)
            case .notRecognized:
                break
            }
        }

        guard let label,
              updates.count + rejectedReasons.count > 0 else {
            return .notRecognized
        }
        if !rejectedReasons.isEmpty {
            return .rejected(Array(Set(rejectedReasons)).sorted())
        }
        let duplicateTargets = duplicateModParameterUpdateTargets(in: updates)
        if !duplicateTargets.isEmpty {
            return .rejected(duplicateTargets.map { "Specify only one \($0) update." })
        }
        return .request(label: label, updates: updates)
    }

    private static func modMoveAndParameterUpdateIntent(
        from prompt: String,
        model: AmigaProgramModel
    ) -> ModMoveAndParameterUpdateIntent {
        let clauses = modParameterUpdateClauses(in: prompt)
        let normalizedPrompt = prompt.lowercased()
        guard clauses.count > 1,
              hasMoveControlSignal(in: normalizedPrompt),
              !hasRenameSignal(in: normalizedPrompt),
              !containsWord("add", in: normalizedPrompt),
              !hasRemoveControlSignal(in: normalizedPrompt) else {
            return .notRecognized
        }

        var move: (label: String, placement: AmigaProgramControlPlacement, targetLabel: String)?
        var updates: [ModParameterUpdate] = []
        var rejectedReasons: [String] = []
        for clause in clauses {
            if let rejection = ordinalControlMoveRejection(from: clause, model: model) ??
                ambiguousControlMoveRejection(from: clause, model: model) {
                rejectedReasons.append(rejection)
                continue
            }
            if let request = moveControlRequest(from: clause, model: model) {
                if move != nil {
                    rejectedReasons.append("Specify only one control move.")
                } else {
                    move = request
                }
                continue
            }
            switch modParameterClauseIntent(from: clause) {
            case .update(let update):
                updates.append(update)
            case .rejected(let reason):
                rejectedReasons.append(reason)
            case .notRecognized:
                break
            }
        }

        guard let move,
              updates.count + rejectedReasons.count > 0 else {
            return .notRecognized
        }
        if !rejectedReasons.isEmpty {
            return .rejected(Array(Set(rejectedReasons)).sorted())
        }
        let duplicateTargets = duplicateModParameterUpdateTargets(in: updates)
        if !duplicateTargets.isEmpty {
            return .rejected(duplicateTargets.map { "Specify only one \($0) update." })
        }
        return .request(move: move, updates: updates)
    }

    private static func modParameterUpdateIntent(from prompt: String) -> ModParameterUpdateIntent {
        let clauses = modParameterUpdateClauses(in: prompt)
        guard clauses.count > 1 else { return .notRecognized }

        var updates: [ModParameterUpdate] = []
        var rejectedReasons: [String] = []
        for clause in clauses {
            switch modParameterClauseIntent(from: clause) {
            case .update(let update):
                updates.append(update)
            case .rejected(let reason):
                rejectedReasons.append(reason)
            case .notRecognized:
                break
            }
        }

        guard updates.count + rejectedReasons.count > 1 else { return .notRecognized }
        if !rejectedReasons.isEmpty {
            return .rejected(Array(Set(rejectedReasons)).sorted())
        }
        let duplicateTargets = duplicateModParameterUpdateTargets(in: updates)
        if !duplicateTargets.isEmpty {
            return .rejected(duplicateTargets.map { "Specify only one \($0) update." })
        }
        guard updates.count > 1 else { return .notRecognized }
        return .request(updates)
    }

    private static func modParameterPatchResult(
        for update: ModParameterUpdate,
        in source: String
    ) throws -> AmigaProgramPatchResult {
        switch update {
        case .playbackPeriod(let period):
            return try AmigaProgramPatcher.updatePlaybackPeriod(period, in: source)
        case .volumeStep(let step):
            return try AmigaProgramPatcher.updateVolumeStep(step, in: source)
        case .initialVolume(let volume):
            return try AmigaProgramPatcher.updateInitialVolume(volume, in: source)
        }
    }

    private static func modParameterClauseIntent(from clause: String) -> ModParameterClauseIntent {
        if playbackNoteIntent(from: clause) {
            guard let period = playbackNotePeriod(from: clause) else {
                return .rejected("Specify a supported playback note such as C-3.")
            }
            return .update(.playbackPeriod(period))
        }
        if playbackPeriodIntent(from: clause) {
            guard let period = firstInteger(in: clause) else {
                return .rejected("Specify a numeric playback period.")
            }
            return .update(.playbackPeriod(period))
        }
        if volumeStepIntent(from: clause) {
            guard let step = firstInteger(in: clause) else {
                return .rejected("Specify a numeric volume step.")
            }
            return .update(.volumeStep(step))
        }
        if initialVolumeIntent(from: clause) {
            guard let volume = initialVolumeValue(from: clause) else {
                return .rejected("Specify a numeric initial volume.")
            }
            return .update(.initialVolume(volume))
        }
        return .notRecognized
    }

    private static func modParameterUpdateClauses(in prompt: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: #"(?i)\band\b"#) else { return [prompt] }
        let range = NSRange(prompt.startIndex..<prompt.endIndex, in: prompt)
        var clauses: [String] = []
        var clauseStart = prompt.startIndex
        for match in regex.matches(in: prompt, range: range) {
            guard let matchRange = Range(match.range, in: prompt) else { continue }
            let clause = prompt[clauseStart..<matchRange.lowerBound]
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if !clause.isEmpty {
                clauses.append(String(clause))
            }
            clauseStart = matchRange.upperBound
        }
        let finalClause = prompt[clauseStart...].trimmingCharacters(in: .whitespacesAndNewlines)
        if !finalClause.isEmpty {
            clauses.append(finalClause)
        }
        return clauses
    }

    private static func duplicateModParameterUpdateTargets(in updates: [ModParameterUpdate]) -> [String] {
        var seen: Set<String> = []
        var duplicates: [String] = []
        for update in updates where !seen.insert(update.target).inserted && !duplicates.contains(update.target) {
            duplicates.append(update.target)
        }
        return duplicates
    }

    private static func duplicateAddControlLabel(in controls: [(label: String, action: String)]) -> String? {
        var seen: Set<String> = []
        for control in controls where !seen.insert(control.action).inserted {
            return control.label
        }
        return nil
    }

    static func volumeStepRequest(from prompt: String) -> Int? {
        guard volumeStepIntent(from: prompt) else { return nil }
        return firstInteger(in: prompt)
    }

    static func playbackPeriodRequest(from prompt: String) -> Int? {
        guard playbackPeriodIntent(from: prompt) else { return nil }
        return firstInteger(in: prompt)
    }

    static func playbackNotePeriodRequest(from prompt: String) -> Int? {
        guard playbackNoteIntent(from: prompt) else { return nil }
        return playbackNotePeriod(from: prompt)
    }

    private static func playbackPeriodIntent(from prompt: String) -> Bool {
        let normalized = prompt.lowercased()
        let hasEditSignal = containsWord("set", in: normalized) ||
            containsWord("change", in: normalized) ||
            containsWord("update", in: normalized) ||
            containsWord("adjust", in: normalized) ||
            containsWord("make", in: normalized)
        return hasEditSignal &&
            containsWord("period", in: normalized) &&
            (containsWord("playback", in: normalized) ||
                containsWord("audio", in: normalized) ||
                containsWord("paula", in: normalized) ||
                containsWord("aud0per", in: normalized))
    }

    private static func playbackNoteIntent(from prompt: String) -> Bool {
        let normalized = prompt.lowercased()
        let hasEditSignal = containsWord("set", in: normalized) ||
            containsWord("change", in: normalized) ||
            containsWord("update", in: normalized) ||
            containsWord("adjust", in: normalized) ||
            containsWord("make", in: normalized)
        return hasEditSignal &&
            (containsWord("note", in: normalized) || containsWord("pitch", in: normalized)) &&
            (containsWord("playback", in: normalized) ||
                containsWord("audio", in: normalized) ||
                containsWord("paula", in: normalized) ||
                containsWord("mod", in: normalized) ||
                containsWord("module", in: normalized))
    }

    private static func playbackNotePeriod(from prompt: String) -> Int? {
        let normalized = prompt.lowercased()
        guard let regex = try? NSRegularExpression(pattern: #"(?i)\b([a-g])\s*(#|sharp|b|flat|-)?\s*([1-3])\b"#) else {
            return nil
        }
        let range = NSRange(normalized.startIndex..<normalized.endIndex, in: normalized)
        guard let match = regex.firstMatch(in: normalized, range: range),
              let noteRange = Range(match.range(at: 1), in: normalized),
              let octaveRange = Range(match.range(at: 3), in: normalized),
              let octave = Int(normalized[octaveRange]) else {
            return nil
        }
        let accidental = Range(match.range(at: 2), in: normalized).map { String(normalized[$0]) }
        let note = String(normalized[noteRange])
        return protrackerPeriod(note: note, accidental: accidental, octave: octave)
    }

    private static func protrackerPeriod(note: String, accidental: String?, octave: Int) -> Int? {
        let semitone: Int
        switch note {
        case "c": semitone = 0
        case "d": semitone = 2
        case "e": semitone = 4
        case "f": semitone = 5
        case "g": semitone = 7
        case "a": semitone = 9
        case "b": semitone = 11
        default: return nil
        }

        let adjustedSemitone: Int
        switch accidental {
        case "#", "sharp":
            adjustedSemitone = semitone + 1
        case "b", "flat":
            adjustedSemitone = semitone - 1
        default:
            adjustedSemitone = semitone
        }

        let normalizedSemitone = (adjustedSemitone + 12) % 12
        let octaveOffset = adjustedSemitone < 0 ? -1 : (adjustedSemitone > 11 ? 1 : 0)
        let normalizedOctave = octave + octaveOffset
        guard (1...3).contains(normalizedOctave) else {
            return nil
        }

        let periods = [
            [856, 808, 762, 720, 678, 640, 604, 570, 538, 508, 480, 453],
            [428, 404, 381, 360, 339, 320, 302, 285, 269, 254, 240, 226],
            [214, 202, 190, 180, 170, 160, 151, 143, 135, 127, 120, 113]
        ]
        return periods[normalizedOctave - 1][normalizedSemitone]
    }

    private static func volumeStepIntent(from prompt: String) -> Bool {
        let normalized = prompt.lowercased()
        let hasEditSignal = containsWord("set", in: normalized) ||
            containsWord("change", in: normalized) ||
            containsWord("update", in: normalized) ||
            containsWord("adjust", in: normalized) ||
            containsWord("make", in: normalized)
        let hasImplicitSetSignal = containsPhrase("volume step to", in: normalized) ||
            containsPhrase("volume increment to", in: normalized) ||
            containsPhrase("volume amount to", in: normalized)
        return (hasEditSignal || hasImplicitSetSignal) &&
            containsWord("volume", in: normalized) &&
            (containsWord("step", in: normalized) || containsWord("increment", in: normalized) || containsWord("amount", in: normalized))
    }

    static func initialVolumeRequest(from prompt: String) -> Int? {
        guard initialVolumeIntent(from: prompt) else { return nil }
        return initialVolumeValue(from: prompt)
    }

    private static func initialVolumeIntent(from prompt: String) -> Bool {
        let normalized = prompt.lowercased()
        let hasEditSignal = containsWord("set", in: normalized) ||
            containsWord("change", in: normalized) ||
            containsWord("update", in: normalized) ||
            containsWord("adjust", in: normalized) ||
            containsWord("make", in: normalized)
        let hasImplicitSetSignal = containsPhrase("initial volume to", in: normalized) ||
            containsPhrase("default volume to", in: normalized) ||
            containsPhrase("starting volume to", in: normalized) ||
            containsPhrase("start volume to", in: normalized)
        guard hasEditSignal || hasImplicitSetSignal,
              containsWord("volume", in: normalized),
              !containsWord("step", in: normalized),
              !containsWord("increment", in: normalized),
              !containsWord("amount", in: normalized),
              !containsWord("button", in: normalized),
              !containsWord("control", in: normalized),
              !containsWord("label", in: normalized),
              !containsWord("text", in: normalized),
              !containsWord("caption", in: normalized),
              !containsWord("title", in: normalized),
              !normalized.contains("say ") else {
            return false
        }

        let hasVolumeLevelSignal = containsWord("initial", in: normalized) ||
            containsWord("default", in: normalized) ||
            containsWord("starting", in: normalized) ||
            containsPhrase("start volume", in: normalized) ||
            containsWord("current", in: normalized) ||
            containsPhrase("volume to", in: normalized)
        return hasVolumeLevelSignal
    }

    private static func initialVolumeValue(from prompt: String) -> Int? {
        if let numericValue = firstInteger(in: prompt) {
            return numericValue
        }

        let normalized = prompt.lowercased()
        if containsWord("max", in: normalized) ||
            containsWord("maximum", in: normalized) ||
            containsWord("full", in: normalized) ||
            containsWord("loudest", in: normalized) {
            return 64
        }
        if containsWord("half", in: normalized) ||
            containsPhrase("half volume", in: normalized) {
            return 32
        }
        if containsWord("mute", in: normalized) ||
            containsWord("muted", in: normalized) ||
            containsWord("silent", in: normalized) ||
            containsWord("silence", in: normalized) ||
            containsWord("off", in: normalized) ||
            containsWord("min", in: normalized) ||
            containsWord("minimum", in: normalized) {
            return 0
        }
        if containsWord("normal", in: normalized) ||
            containsWord("default", in: normalized) {
            return 48
        }
        return nil
    }

    static func labelRenameRequest(from prompt: String, model: AmigaProgramModel) -> (currentLabel: String, newLabel: String)? {
        let normalized = prompt.lowercased()
        guard hasRenameSignal(in: normalized),
              !containsWord("add", in: normalized) else {
            return nil
        }

        let quoted = quotedTexts(in: prompt)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        if quoted.count >= 2 {
            return (quoted[0], quoted[1])
        }

        if let ordinalIndex = controlOrdinalRequest(in: normalized),
           model.controls.indices.contains(ordinalIndex),
           let newLabel = labelAfterRenameSeparator(in: prompt) {
            return (model.controls[ordinalIndex].label, newLabel)
        }
        if controlOrdinalRequest(in: normalized) != nil {
            return nil
        }

        guard let control = model.controls
            .sorted(by: { $0.label.count > $1.label.count })
            .first(where: { control in
                containsPhrase(control.label, in: normalized) ||
                    containsPhrase(control.id.replacingOccurrences(of: "_", with: " "), in: normalized) ||
                    controlActionReferenceMatches(control.action, in: normalized)
            }),
            let newLabel = labelAfterRenameSeparator(in: prompt) else {
            return nil
        }

        return (control.label, newLabel)
    }

    static func removeControlRequest(from prompt: String, model: AmigaProgramModel) -> String? {
        let normalized = prompt.lowercased()
        guard hasRemoveControlSignal(in: normalized),
              !hasRenameSignal(in: normalized),
              !containsWord("add", in: normalized) else {
            return nil
        }

        let quoted = quotedTexts(in: prompt)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        if let firstQuoted = quoted.first {
            return firstQuoted
        }

        if let ordinalIndex = controlOrdinalRequest(in: normalized),
           model.controls.indices.contains(ordinalIndex) {
            return model.controls[ordinalIndex].label
        }
        if controlOrdinalRequest(in: normalized) != nil {
            return nil
        }

        return model.controls
            .sorted(by: { $0.label.count > $1.label.count })
            .first { control in
                containsPhrase(control.label, in: normalized) ||
                    containsPhrase(control.id.replacingOccurrences(of: "_", with: " "), in: normalized) ||
                    controlActionReferenceMatches(control.action, in: normalized)
            }?
            .label
    }

    private static func ambiguousControlRemovalRejection(from prompt: String, model: AmigaProgramModel) -> String? {
        let normalized = prompt.lowercased()
        guard hasRemoveControlSignal(in: normalized),
              hasControlNoun(in: normalized),
              !hasRenameSignal(in: normalized),
              quotedTexts(in: prompt).isEmpty,
              controlOrdinalRequest(in: normalized) == nil,
              model.controls.count > 1 else {
            return nil
        }

        return AmigaProgramPatchError.ambiguousControlReference(model.controls.map(\.label)).errorDescription
    }

    static func controlBehaviorChangeRequest(from prompt: String, model: AmigaProgramModel) -> (label: String, action: String)? {
        let normalized = prompt.lowercased()
        guard hasBehaviorChangeSignal(in: normalized),
              !containsWord("add", in: normalized),
              !hasRemoveControlSignal(in: normalized),
              !hasMoveControlSignal(in: normalized),
              behaviorChangeTargetSeparator(in: normalized) else {
            return nil
        }
        let targetRequests = behaviorChangeTargetRequests(in: prompt, model: model)
        guard targetRequests.count == 1,
              let request = targetRequests.first else {
            return nil
        }
        return (request.control.label, request.action)
    }

    static func controlLabelAndBehaviorChangeRequest(from prompt: String, model: AmigaProgramModel) -> (currentLabel: String, newLabel: String, action: String)? {
        let normalized = prompt.lowercased()
        guard hasRenameSignal(in: normalized),
              hasBehaviorChangeSignal(in: normalized),
              !containsWord("add", in: normalized),
              !hasRemoveControlSignal(in: normalized),
              !hasMoveControlSignal(in: normalized),
              behaviorChangeTargetSeparator(in: normalized) || hasExplicitControlBehaviorPhrase(in: normalized),
              let rename = labelRenameRequest(from: prompt, model: model) else {
            return nil
        }
        let targetRequests = behaviorChangeTargetRequests(in: prompt, model: model)
        guard targetRequests.count == 1,
              let request = targetRequests.first,
              request.control.label == rename.currentLabel else {
            return nil
        }
        return (rename.currentLabel, rename.newLabel, request.action)
    }

    private static func duplicateControlLabelAndBehaviorChangeRejection(from prompt: String, model: AmigaProgramModel) -> String? {
        let normalized = prompt.lowercased()
        guard hasRenameSignal(in: normalized),
              hasBehaviorChangeSignal(in: normalized),
              !containsWord("add", in: normalized),
              !hasRemoveControlSignal(in: normalized),
              !hasMoveControlSignal(in: normalized),
              behaviorChangeTargetSeparator(in: normalized) || hasExplicitControlBehaviorPhrase(in: normalized) else {
            return nil
        }
        let targetRequests = behaviorChangeTargetRequests(in: prompt, model: model)
        guard targetRequests.count == 1,
              let request = targetRequests.first,
              let existingControl = model.controls.first(where: { control in
                control.label != request.control.label && control.action == request.action
              }) else {
            return nil
        }
        return AmigaProgramPatchError.duplicateAction(request.action, existingControl.label).errorDescription
    }

    private static func conflictingControlBehaviorChangeRejection(from prompt: String, model: AmigaProgramModel) -> String? {
        let normalized = prompt.lowercased()
        guard hasBehaviorChangeSignal(in: normalized),
              !containsWord("add", in: normalized),
              !hasRemoveControlSignal(in: normalized),
              !hasMoveControlSignal(in: normalized),
              behaviorChangeTargetSeparator(in: normalized) else {
            return nil
        }
        let targetRequests = behaviorChangeTargetRequests(in: prompt, model: model)
        guard targetRequests.count > 1 else {
            return nil
        }
        let names = targetRequests.map { _, action in
            addControlBehaviorCandidates().first(where: { $0.action == action })?.name ?? action
        }
        return AmigaProgramPatchError.conflictingControlBehaviors(names).errorDescription
    }

    private static func behaviorChangeTargetRequests(in prompt: String, model: AmigaProgramModel) -> [(control: AmigaProgramModel.Control, action: String)] {
        let normalized = prompt.lowercased()
        var results: [(control: AmigaProgramModel.Control, action: String)] = []
        let promptTokens = normalized.split { !$0.isLetter && !$0.isNumber }
        for target in addControlBehaviorIntentLocations(in: normalized) where target.action != "PlayMOD" && target.action != "StopMOD" {
            let prefix = prefix(upToTokenLocation: target.location, tokens: promptTokens)
            guard let sourceControl = controlReference(in: prefix, model: model),
                  sourceControl.action != target.action,
                  !results.contains(where: { $0.control.label == sourceControl.label && $0.action == target.action }) else {
                continue
            }
            results.append((sourceControl, target.action))
        }
        return results
    }

    private static func hasExplicitControlBehaviorPhrase(in normalizedPrompt: String) -> Bool {
        addControlBehaviorCandidates().contains { candidate in
            candidate.matches.contains { containsPhrase($0, in: normalizedPrompt) }
        }
    }

    private static func prefix(upToTokenLocation location: Int, tokens: [Substring]) -> String {
        let boundedLocation = max(0, min(location, tokens.count))
        return tokens[..<boundedLocation].joined(separator: " ")
    }

    static func controlBoundsRequest(from prompt: String, model: AmigaProgramModel) -> (label: String, bounds: AmigaProgramModel.Bounds)? {
        let normalized = prompt.lowercased()
        guard hasControlBoundsSignal(in: normalized),
              !containsWord("add", in: normalized),
              !hasRemoveControlSignal(in: normalized),
              !hasRenameSignal(in: normalized) else {
            return nil
        }

        if let separator = relativeControlPlacementSeparator(in: prompt) {
            let currentSide = String(prompt[..<separator.range.lowerBound])
            if let sourceLabel = controlReferenceLabel(in: currentSide, model: model) ??
                ordinalControlReferenceLabel(in: currentSide, model: model),
               let sourceControl = model.controls.first(where: { $0.label == sourceLabel }),
               let currentBounds = sourceControl.bounds,
               let placement = relativeControlPlacementBounds(
                in: prompt,
                model: model,
                sourceBoundsOverride: boundsByApplyingSizeRequest(in: prompt, to: currentBounds)
               ) {
                return boundByApplyingPositionRequest(in: prompt, placement: placement)
            }
        }

        guard let sourceControl = controlReference(in: prompt, model: model),
              let currentBounds = sourceControl.bounds else {
            return nil
        }

        if let explicitBounds = explicitControlBounds(in: prompt) {
            return (sourceControl.label, explicitBounds)
        }

        var bounds = currentBounds
        var didChange = false
        if let x = keyedInteger(named: ["x"], in: prompt) {
            bounds.x = x
            didChange = true
        }
        if let y = keyedInteger(named: ["y"], in: prompt) {
            bounds.y = y
            didChange = true
        }
        if let width = keyedInteger(named: ["w", "width", "wide"], in: prompt) {
            bounds.width = width
            didChange = true
        }
        if let height = keyedInteger(named: ["h", "height", "tall"], in: prompt) {
            bounds.height = height
            didChange = true
        }
        if !didChange,
           let size = explicitControlSize(in: prompt) {
            bounds.width = size.width
            bounds.height = size.height
            didChange = true
        }
        if !didChange,
           let delta = relativeControlSizeDelta(in: prompt) {
            bounds.width += delta.width
            bounds.height += delta.height
            didChange = true
        }
        if !didChange,
           let delta = relativeControlPositionDelta(in: prompt) {
            bounds.x += delta.x
            bounds.y += delta.y
            didChange = true
        } else if didChange,
                  let delta = relativeControlPositionDelta(in: prompt) {
            bounds.x += delta.x
            bounds.y += delta.y
        }
        return didChange ? (sourceControl.label, bounds) : nil
    }

    private static func controlGroupBoundsRequest(
        from prompt: String,
        model: AmigaProgramModel
    ) -> [(label: String, bounds: AmigaProgramModel.Bounds)]? {
        let normalized = prompt.lowercased()
        guard hasControlBoundsSignal(in: normalized),
              !containsWord("add", in: normalized),
              !hasRemoveControlSignal(in: normalized),
              !hasRenameSignal(in: normalized) else {
            return nil
        }

        if let separator = relativeControlPlacementSeparator(in: prompt) {
            let currentSide = String(prompt[..<separator.range.lowerBound])
            let targetSide = String(prompt[separator.range.upperBound...])
            guard let sourceControls = controlGroupReference(in: currentSide, model: model),
                  let targetLabel = visibleControlReferenceLabel(in: targetSide, model: model) ??
                    ordinalControlReferenceLabel(in: targetSide, model: model) ??
                    controlReferenceLabel(in: targetSide, model: model),
                  let targetControl = model.controls.first(where: { $0.label == targetLabel }) else {
                return nil
            }

            let sizedControls = controlsByApplyingSizeRequest(in: prompt, to: sourceControls)
            return boundsByApplyingPositionRequest(
                in: prompt,
                placement: controlGroupPlacementBounds(
                    for: sizedControls,
                    relativeTo: targetControl,
                    placement: separator.placement,
                    centered: containsWord("center", in: normalized) || containsWord("centered", in: normalized)
                )
            )
        }

        guard let sourceControls = controlGroupReference(in: prompt, model: model) else {
            return nil
        }
        if let delta = relativeControlPositionDelta(in: prompt) {
            return controlsByApplyingSizeRequest(in: prompt, to: sourceControls).compactMap { control in
                guard var bounds = control.bounds else { return nil }
                bounds.x += delta.x
                bounds.y += delta.y
                return (control.label, bounds)
            }
        }
        if let delta = relativeControlSizeDelta(in: prompt) {
            return sourceControls.compactMap { control in
                guard var bounds = control.bounds else { return nil }
                bounds.width += delta.width
                bounds.height += delta.height
                return (control.label, bounds)
            }
        }
        if let size = explicitControlSize(in: prompt) {
            return sourceControls.compactMap { control in
                guard var bounds = control.bounds else { return nil }
                bounds.width = size.width
                bounds.height = size.height
                return (control.label, bounds)
            }
        }
        return nil
    }

    private static func ambiguousControlBoundsRejection(from prompt: String, model: AmigaProgramModel) -> String? {
        let normalized = prompt.lowercased()
        guard hasControlBoundsSignal(in: normalized),
              hasControlNoun(in: normalized),
              !containsWord("add", in: normalized),
              !hasRemoveControlSignal(in: normalized),
              !hasRenameSignal(in: normalized),
              controlReference(in: prompt, model: model) == nil,
              model.controls.count > 1 else {
            return nil
        }
        return AmigaProgramPatchError.ambiguousControlReference(model.controls.map(\.label)).errorDescription
    }

    private static func boundsByApplyingPositionRequest(
        in prompt: String,
        placement: [(label: String, bounds: AmigaProgramModel.Bounds)]?
    ) -> [(label: String, bounds: AmigaProgramModel.Bounds)]? {
        guard let placement,
              let delta = relativeControlPositionDelta(in: prompt) else {
            return placement
        }
        return placement.map { placed in
            var bounds = placed.bounds
            bounds.x += delta.x
            bounds.y += delta.y
            return (placed.label, bounds)
        }
    }

    private static func boundByApplyingPositionRequest(
        in prompt: String,
        placement: (label: String, bounds: AmigaProgramModel.Bounds)
    ) -> (label: String, bounds: AmigaProgramModel.Bounds) {
        guard let delta = relativeControlPositionDelta(in: prompt) else {
            return placement
        }
        var bounds = placement.bounds
        bounds.x += delta.x
        bounds.y += delta.y
        return (placement.label, bounds)
    }

    private static func hasControlBoundsSignal(in normalizedPrompt: String) -> Bool {
        let hasGeometryWord = containsWord("bounds", in: normalizedPrompt) ||
            containsWord("position", in: normalizedPrompt) ||
            containsWord("resize", in: normalizedPrompt) ||
            containsWord("size", in: normalizedPrompt) ||
            containsWord("wide", in: normalizedPrompt) ||
            containsWord("width", in: normalizedPrompt) ||
            containsWord("height", in: normalizedPrompt) ||
            containsWord("tall", in: normalizedPrompt) ||
            containsWord("wider", in: normalizedPrompt) ||
            containsWord("narrower", in: normalizedPrompt) ||
            containsWord("taller", in: normalizedPrompt) ||
            containsWord("shorter", in: normalizedPrompt) ||
            containsWord("bigger", in: normalizedPrompt) ||
            containsWord("larger", in: normalizedPrompt) ||
            containsWord("smaller", in: normalizedPrompt) ||
            explicitControlSize(in: normalizedPrompt) != nil ||
            hasRelativePositionSignal(in: normalizedPrompt) ||
            hasRelativePlacementSignal(in: normalizedPrompt)
        let hasPositionKeys = containsWord("x", in: normalizedPrompt) && containsWord("y", in: normalizedPrompt)
        let hasEditSignal = containsWord("set", in: normalizedPrompt) ||
            containsWord("change", in: normalizedPrompt) ||
            containsWord("move", in: normalizedPrompt) ||
            containsWord("place", in: normalizedPrompt) ||
            containsWord("put", in: normalizedPrompt) ||
            containsWord("make", in: normalizedPrompt) ||
            containsWord("center", in: normalizedPrompt) ||
            containsWord("centered", in: normalizedPrompt)
        return hasEditSignal && (hasGeometryWord || hasPositionKeys)
    }

    private static func explicitControlBounds(in prompt: String) -> AmigaProgramModel.Bounds? {
        let normalized = prompt.lowercased()
        guard containsWord("bounds", in: normalized) else { return nil }
        let values = integers(in: prompt)
        guard values.count >= 4 else { return nil }
        return AmigaProgramModel.Bounds(x: values[0], y: values[1], width: values[2], height: values[3])
    }

    private static func explicitControlSize(in prompt: String) -> (width: Int, height: Int)? {
        guard let regex = try? NSRegularExpression(pattern: #"(?i)\b(\$[0-9a-f]+|0x[0-9a-f]+|-?\d+)\s*x\s*(\$[0-9a-f]+|0x[0-9a-f]+|-?\d+)\b"#) else {
            return nil
        }
        let range = NSRange(prompt.startIndex..<prompt.endIndex, in: prompt)
        guard let match = regex.firstMatch(in: prompt, range: range),
              match.numberOfRanges > 2,
              let widthRange = Range(match.range(at: 1), in: prompt),
              let heightRange = Range(match.range(at: 2), in: prompt),
              let width = integerValue(from: String(prompt[widthRange])),
              let height = integerValue(from: String(prompt[heightRange])) else {
            return nil
        }
        return (width, height)
    }

    private static func relativeControlSizeDelta(in prompt: String) -> (width: Int, height: Int)? {
        let fallbackAmount = integers(in: prompt).first ?? 16
        var widthDelta = 0
        var heightDelta = 0
        if let amount = relativeControlSizeAmount(for: ["wider"], in: prompt, defaultAmount: fallbackAmount) {
            widthDelta += amount
        }
        if let amount = relativeControlSizeAmount(for: ["narrower"], in: prompt, defaultAmount: fallbackAmount) {
            widthDelta -= amount
        }
        if let amount = relativeControlSizeAmount(for: ["taller"], in: prompt, defaultAmount: fallbackAmount) {
            heightDelta += amount
        }
        if let amount = relativeControlSizeAmount(for: ["shorter"], in: prompt, defaultAmount: fallbackAmount) {
            heightDelta -= amount
        }
        if let amount = relativeControlSizeAmount(for: ["bigger", "larger"], in: prompt, defaultAmount: fallbackAmount) {
            widthDelta += amount
            heightDelta += amount
        }
        if let amount = relativeControlSizeAmount(for: ["smaller"], in: prompt, defaultAmount: fallbackAmount) {
            widthDelta -= amount
            heightDelta -= amount
        }
        guard widthDelta != 0 || heightDelta != 0 else { return nil }
        return (widthDelta, heightDelta)
    }

    private static func relativeControlSizeAmount(
        for keywords: [String],
        in prompt: String,
        defaultAmount: Int
    ) -> Int? {
        let normalized = prompt.lowercased()
        let integer = #"\$[0-9a-fA-F]+|0x[0-9a-fA-F]+|-?\d+"#
        for keyword in keywords {
            if let amount = relativeControlSizeAmount(
                pattern: #"(?i)\b\#(keyword)\s+by\s+(\#(integer))\b"#,
                prompt: prompt,
                amountGroup: 1
            ) {
                return amount
            }
            if let amount = relativeControlSizeAmount(
                pattern: #"(?i)\bby\s+(\#(integer))\s+\#(keyword)\b"#,
                prompt: prompt,
                amountGroup: 1
            ) {
                return amount
            }
            if containsWord(keyword, in: normalized) {
                return defaultAmount
            }
        }
        return nil
    }

    private static func relativeControlSizeAmount(
        pattern: String,
        prompt: String,
        amountGroup: Int
    ) -> Int? {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(prompt.startIndex..<prompt.endIndex, in: prompt)
        guard let match = regex.firstMatch(in: prompt, range: range),
              match.numberOfRanges > amountGroup,
              let amountRange = Range(match.range(at: amountGroup), in: prompt) else {
            return nil
        }
        return integerValue(from: String(prompt[amountRange]))
    }

    private static func relativeControlPositionDelta(in prompt: String) -> (x: Int, y: Int)? {
        guard let request = relativeControlPositionRequest(in: prompt) else { return nil }
        switch request.direction {
        case "left":
            return (-request.amount, 0)
        case "right":
            return (request.amount, 0)
        case "up":
            return (0, -request.amount)
        case "down":
            return (0, request.amount)
        default:
            return nil
        }
    }

    private static func hasRelativePositionSignal(in normalizedPrompt: String) -> Bool {
        relativeControlPositionRequest(in: normalizedPrompt) != nil
    }

    private static func relativeControlPositionRequest(in prompt: String) -> (direction: String, amount: Int)? {
        let integer = #"\$[0-9a-fA-F]+|0x[0-9a-fA-F]+|-?\d+"#
        if let request = relativeControlPositionRequest(
            pattern: #"(?i)\b(left|right|up|down)\s+by\s+(\#(integer))\b"#,
            prompt: prompt,
            directionGroup: 1,
            amountGroup: 2
        ) {
            return request
        }
        if let request = relativeControlPositionRequest(
            pattern: #"(?i)\bby\s+(\#(integer))\s+(left|right|up|down)\b"#,
            prompt: prompt,
            directionGroup: 2,
            amountGroup: 1
        ) {
            return request
        }
        return nil
    }

    private static func relativeControlPositionRequest(
        pattern: String,
        prompt: String,
        directionGroup: Int,
        amountGroup: Int
    ) -> (direction: String, amount: Int)? {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(prompt.startIndex..<prompt.endIndex, in: prompt)
        guard let match = regex.firstMatch(in: prompt, range: range),
              match.numberOfRanges > max(directionGroup, amountGroup),
              let directionRange = Range(match.range(at: directionGroup), in: prompt),
              let amountRange = Range(match.range(at: amountGroup), in: prompt),
              let amount = integerValue(from: String(prompt[amountRange])) else {
            return nil
        }
        return (String(prompt[directionRange]).lowercased(), amount)
    }

    private enum RelativeControlPlacement: Equatable {
        case above
        case below
        case leftOf
        case rightOf
    }

    private static func relativeControlPlacementBounds(
        in prompt: String,
        model: AmigaProgramModel,
        sourceBoundsOverride: AmigaProgramModel.Bounds? = nil
    ) -> (label: String, bounds: AmigaProgramModel.Bounds)? {
        guard let separator = relativeControlPlacementSeparator(in: prompt) else { return nil }
        let currentSide = String(prompt[..<separator.range.lowerBound])
        let targetSide = String(prompt[separator.range.upperBound...])
        guard let sourceLabel = controlReferenceLabel(in: currentSide, model: model) ??
            ordinalControlReferenceLabel(in: currentSide, model: model),
            let targetLabel = visibleControlReferenceLabel(in: targetSide, model: model) ??
            ordinalControlReferenceLabel(in: targetSide, model: model) ??
            controlReferenceLabel(in: targetSide, model: model),
            let sourceControl = model.controls.first(where: { $0.label == sourceLabel }),
            let targetControl = model.controls.first(where: { $0.label == targetLabel }),
            sourceControl.id != targetControl.id,
            let currentBounds = sourceControl.bounds,
            let targetBounds = targetControl.bounds else {
            return nil
        }
        let sourceBounds = sourceBoundsOverride ?? currentBounds
        let gap = 8
        let normalized = prompt.lowercased()
        let center = containsWord("center", in: normalized) || containsWord("centered", in: normalized)
        var bounds = sourceBounds
        switch separator.placement {
        case .above:
            bounds.x = center ? centeredCoordinate(sourceSize: sourceBounds.width, targetOrigin: targetBounds.x, targetSize: targetBounds.width) : targetBounds.x
            bounds.y = targetBounds.y - sourceBounds.height - gap
        case .below:
            bounds.x = center ? centeredCoordinate(sourceSize: sourceBounds.width, targetOrigin: targetBounds.x, targetSize: targetBounds.width) : targetBounds.x
            bounds.y = targetBounds.y + targetBounds.height + gap
        case .leftOf:
            bounds.x = targetBounds.x - sourceBounds.width - gap
            bounds.y = center ? centeredCoordinate(sourceSize: sourceBounds.height, targetOrigin: targetBounds.y, targetSize: targetBounds.height) : targetBounds.y
        case .rightOf:
            bounds.x = targetBounds.x + targetBounds.width + gap
            bounds.y = center ? centeredCoordinate(sourceSize: sourceBounds.height, targetOrigin: targetBounds.y, targetSize: targetBounds.height) : targetBounds.y
        }
        bounds = boundsByAvoidingControlOverlap(
            bounds,
            movingControlID: sourceControl.id,
            placement: separator.placement,
            controls: model.controls,
            gap: gap
        )
        return (sourceControl.label, bounds)
    }

    private static func boundsByAvoidingControlOverlap(
        _ initialBounds: AmigaProgramModel.Bounds,
        movingControlID: String,
        placement: RelativeControlPlacement,
        controls: [AmigaProgramModel.Control],
        gap: Int
    ) -> AmigaProgramModel.Bounds {
        let occupiedBounds = controls.compactMap { control -> AmigaProgramModel.Bounds? in
            guard control.id != movingControlID else { return nil }
            return control.bounds
        }
        var bounds = initialBounds
        for _ in 0..<(occupiedBounds.count + 1) {
            guard occupiedBounds.contains(where: { controlBoundsOverlap(bounds, $0) }) else {
                return bounds
            }
            switch placement {
            case .above:
                bounds.y -= bounds.height + gap
            case .below:
                bounds.y += bounds.height + gap
            case .leftOf:
                bounds.x -= bounds.width + gap
            case .rightOf:
                bounds.x += bounds.width + gap
            }
        }
        return bounds
    }

    private static func controlBoundsOverlap(_ left: AmigaProgramModel.Bounds, _ right: AmigaProgramModel.Bounds) -> Bool {
        left.x < right.x + right.width &&
            left.x + left.width > right.x &&
            left.y < right.y + right.height &&
            left.y + left.height > right.y
    }

    private static func addedControlPlacementBounds(
        in prompt: String,
        addedLabel: String,
        model: AmigaProgramModel
    ) -> (label: String, bounds: AmigaProgramModel.Bounds)? {
        guard let addedControl = model.controls.first(where: { $0.label.caseInsensitiveCompare(addedLabel) == .orderedSame }),
              let currentBounds = addedControl.bounds else {
            return nil
        }

        var sourceBounds = currentBounds
        if let size = explicitControlSize(in: prompt) {
            sourceBounds.width = size.width
            sourceBounds.height = size.height
        }
        if let delta = relativeControlSizeDelta(in: prompt) {
            sourceBounds.width += delta.width
            sourceBounds.height += delta.height
        }

        guard let placement = relativeControlPlacementBounds(in: prompt, model: model, sourceBoundsOverride: sourceBounds),
              placement.label == addedControl.label else {
            return nil
        }
        return boundByApplyingPositionRequest(in: prompt, placement: placement)
    }

    private static func boundsByApplyingSizeRequest(
        in prompt: String,
        to bounds: AmigaProgramModel.Bounds
    ) -> AmigaProgramModel.Bounds {
        var bounds = bounds
        if let size = explicitControlSize(in: prompt) {
            bounds.width = size.width
            bounds.height = size.height
        }
        if let delta = relativeControlSizeDelta(in: prompt) {
            bounds.width += delta.width
            bounds.height += delta.height
        }
        return bounds
    }

    private static func addedControlGroupPlacementBounds(
        in prompt: String,
        addedLabels: [String],
        model: AmigaProgramModel
    ) -> [(label: String, bounds: AmigaProgramModel.Bounds)]? {
        guard addedLabels.count > 1,
              let separator = relativeControlPlacementSeparator(in: prompt) else {
            return nil
        }
        let targetSide = String(prompt[separator.range.upperBound...])
        guard let targetLabel = visibleControlReferenceLabel(in: targetSide, model: model) ??
            ordinalControlReferenceLabel(in: targetSide, model: model) ??
            controlReferenceLabel(in: targetSide, model: model),
            let targetControl = model.controls.first(where: { $0.label == targetLabel }) else {
            return nil
        }

        let addedControls = addedLabels.compactMap { label in
            model.controls.first { $0.label.caseInsensitiveCompare(label) == .orderedSame }
        }
        guard addedControls.count == addedLabels.count else {
            return nil
        }

        let normalized = prompt.lowercased()
        let sizedControls = controlsByApplyingSizeRequest(in: prompt, to: addedControls)
        return boundsByApplyingPositionRequest(
            in: prompt,
            placement: controlGroupPlacementBounds(
                for: sizedControls,
                relativeTo: targetControl,
                placement: separator.placement,
                centered: containsWord("center", in: normalized) || containsWord("centered", in: normalized)
            )
        )
    }

    private static func controlsByApplyingSizeRequest(
        in prompt: String,
        to controls: [AmigaProgramModel.Control]
    ) -> [AmigaProgramModel.Control] {
        controls.map { control in
            guard var bounds = control.bounds else {
                return control
            }
            if let size = explicitControlSize(in: prompt) {
                bounds.width = size.width
                bounds.height = size.height
            }
            if let delta = relativeControlSizeDelta(in: prompt) {
                bounds.width += delta.width
                bounds.height += delta.height
            }
            var sized = control
            sized.bounds = bounds
            return sized
        }
    }

    private static func controlGroupPlacementBounds(
        for sourceControls: [AmigaProgramModel.Control],
        relativeTo targetControl: AmigaProgramModel.Control,
        placement: RelativeControlPlacement,
        centered: Bool
    ) -> [(label: String, bounds: AmigaProgramModel.Bounds)]? {
        guard sourceControls.count > 1,
              let targetBounds = targetControl.bounds,
              sourceControls.allSatisfy({ $0.id != targetControl.id && $0.bounds != nil }) else {
            return nil
        }

        let gap = 8
        switch placement {
        case .above, .below:
            let sizes = sourceControls.compactMap(\.bounds)
            let totalWidth = sizes.map(\.width).reduce(0, +) + gap * max(0, sizes.count - 1)
            let rowHeight = sizes.map(\.height).max() ?? 0
            var x = centered ? centeredCoordinate(sourceSize: totalWidth, targetOrigin: targetBounds.x, targetSize: targetBounds.width) : targetBounds.x
            let y = placement == .below ? targetBounds.y + targetBounds.height + gap : targetBounds.y - rowHeight - gap
            return zip(sourceControls, sizes).map { control, size in
                defer { x += size.width + gap }
                return (control.label, AmigaProgramModel.Bounds(x: x, y: y, width: size.width, height: size.height))
            }
        case .leftOf, .rightOf:
            let sizes = sourceControls.compactMap(\.bounds)
            let columnWidth = sizes.map(\.width).max() ?? 0
            let totalHeight = sizes.map(\.height).reduce(0, +) + gap * max(0, sizes.count - 1)
            let x = placement == .rightOf ? targetBounds.x + targetBounds.width + gap : targetBounds.x - columnWidth - gap
            var y = centered ? centeredCoordinate(sourceSize: totalHeight, targetOrigin: targetBounds.y, targetSize: targetBounds.height) : targetBounds.y
            return zip(sourceControls, sizes).map { control, size in
                defer { y += size.height + gap }
                return (control.label, AmigaProgramModel.Bounds(x: x, y: y, width: size.width, height: size.height))
            }
        }
    }

    private static func centeredCoordinate(sourceSize: Int, targetOrigin: Int, targetSize: Int) -> Int {
        targetOrigin + (targetSize - sourceSize) / 2
    }

    private static func hasRelativePlacementSignal(in normalizedPrompt: String) -> Bool {
        relativeControlPlacementSeparator(in: normalizedPrompt) != nil
    }

    private static func relativeControlPlacementSeparator(in prompt: String) -> (placement: RelativeControlPlacement, range: Range<String.Index>)? {
        let patterns: [(String, RelativeControlPlacement)] = [
            (#"(?i)\b(?:to\s+the\s+)?right\s+of\b"#, .rightOf),
            (#"(?i)\b(?:to\s+the\s+)?left\s+of\b"#, .leftOf),
            (#"(?i)\b(?:below|under|beneath)\b"#, .below),
            (#"(?i)\babove\b"#, .above)
        ]
        for (pattern, placement) in patterns {
            guard let regex = try? NSRegularExpression(pattern: pattern) else { continue }
            let range = NSRange(prompt.startIndex..<prompt.endIndex, in: prompt)
            guard let match = regex.firstMatch(in: prompt, range: range),
                  let swiftRange = Range(match.range, in: prompt) else {
                continue
            }
            return (placement, swiftRange)
        }
        return nil
    }

    private static func keyedInteger(named names: [String], in prompt: String) -> Int? {
        let escapedNames = names.map { NSRegularExpression.escapedPattern(for: $0) }.joined(separator: "|")
        let pattern = #"(?i)\b(?:\#(escapedNames))\b\s*(?:=|to|:)?\s*(\$[0-9a-f]+|0x[0-9a-f]+|-?\d+)"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(prompt.startIndex..<prompt.endIndex, in: prompt)
        guard let match = regex.firstMatch(in: prompt, range: range),
              match.numberOfRanges > 1,
              let valueRange = Range(match.range(at: 1), in: prompt) else {
            return nil
        }
        return integerValue(from: String(prompt[valueRange]))
    }

    private static func integers(in prompt: String) -> [Int] {
        let pattern = #"\$[0-9a-fA-F]+|0x[0-9a-fA-F]+|-?\d+"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let range = NSRange(prompt.startIndex..<prompt.endIndex, in: prompt)
        return regex.matches(in: prompt, range: range).compactMap { match in
            guard let valueRange = Range(match.range, in: prompt) else { return nil }
            return integerValue(from: String(prompt[valueRange]))
        }
    }

    private static func integerValue(from text: String) -> Int? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.hasPrefix("$") {
            return Int(trimmed.dropFirst(), radix: 16)
        }
        if trimmed.lowercased().hasPrefix("0x") {
            return Int(trimmed.dropFirst(2), radix: 16)
        }
        return Int(trimmed)
    }

    private static func controlReference(in prompt: String, model: AmigaProgramModel) -> AmigaProgramModel.Control? {
        let normalized = prompt.lowercased()
        if let ordinal = controlOrdinalRequest(in: normalized),
           model.controls.indices.contains(ordinal) {
            return model.controls[ordinal]
        }
        if let label = controlReferenceLabel(in: prompt, model: model) {
            return model.controls.first { $0.label == label }
        }
        return nil
    }

    private static func controlGroupReference(in text: String, model: AmigaProgramModel) -> [AmigaProgramModel.Control]? {
        let normalized = text.lowercased()
        guard containsWord("volume", in: normalized),
              containsWord("controls", in: normalized) || containsWord("buttons", in: normalized) else {
            return nil
        }
        let controls = model.controls.filter { control in
            control.action == "VolumeUp" || control.action == "VolumeDown"
        }
        guard controls.count == 2 else {
            return nil
        }
        return controls
    }

    private static func behaviorChangeTargetSeparator(in normalizedPrompt: String) -> Bool {
        containsWord("to", in: normalizedPrompt) ||
            containsWord("into", in: normalizedPrompt) ||
            containsWord("as", in: normalizedPrompt) ||
            containsWord("instead", in: normalizedPrompt)
    }

    private static func hasBehaviorChangeSignal(in normalizedPrompt: String) -> Bool {
        containsWord("make", in: normalizedPrompt) ||
            containsWord("change", in: normalizedPrompt) ||
            containsWord("switch", in: normalizedPrompt) ||
            containsWord("convert", in: normalizedPrompt) ||
            containsWord("turn", in: normalizedPrompt) ||
            containsWord("set", in: normalizedPrompt)
    }

    static func moveControlRequest(from prompt: String, model: AmigaProgramModel) -> (label: String, placement: AmigaProgramControlPlacement, targetLabel: String)? {
        let normalized = prompt.lowercased()
        guard hasMoveControlSignal(in: normalized),
              !hasRenameSignal(in: normalized),
              !containsWord("add", in: normalized),
              !hasRemoveControlSignal(in: normalized),
              let separator = movePlacementSeparator(in: prompt) else {
            return nil
        }

        let quoted = quotedTexts(in: prompt)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        if quoted.count >= 2 {
            return (quoted[0], separator.placement, quoted[1])
        }

        let currentSide = String(prompt[..<separator.range.lowerBound])
        let targetSide = String(prompt[separator.range.upperBound...])
        guard let currentLabel = controlReferenceLabel(in: currentSide, model: model) ??
            ordinalControlReferenceLabel(in: currentSide, model: model) ??
            cleanedMoveReference(from: currentSide),
            let targetLabel = controlReferenceLabel(in: targetSide, model: model) ??
            ordinalControlReferenceLabel(in: targetSide, model: model) ??
            cleanedMoveReference(from: targetSide) else {
            return nil
        }
        return (currentLabel, separator.placement, targetLabel)
    }

    private static func ordinalControlMoveRejection(from prompt: String, model: AmigaProgramModel) -> String? {
        let normalized = prompt.lowercased()
        guard hasMoveControlSignal(in: normalized),
              !hasRenameSignal(in: normalized),
              !containsWord("add", in: normalized),
              !hasRemoveControlSignal(in: normalized),
              let separator = movePlacementSeparator(in: prompt) else {
            return nil
        }

        let currentSide = String(prompt[..<separator.range.lowerBound])
        if let ordinal = controlOrdinalRequest(in: currentSide.lowercased()),
           !model.controls.indices.contains(ordinal) {
            return "Cannot move the \(ordinalDescription(ordinal)); this program has \(model.controls.count) controls."
        }

        let targetSide = String(prompt[separator.range.upperBound...])
        if let ordinal = controlOrdinalRequest(in: targetSide.lowercased()),
           !model.controls.indices.contains(ordinal) {
            return "Cannot move relative to the \(ordinalDescription(ordinal)); this program has \(model.controls.count) controls."
        }

        return nil
    }

    private static func ambiguousControlMoveRejection(from prompt: String, model: AmigaProgramModel) -> String? {
        let normalized = prompt.lowercased()
        guard hasMoveControlSignal(in: normalized),
              movePlacementSeparator(in: prompt) != nil,
              hasControlNoun(in: normalized),
              !hasRenameSignal(in: normalized),
              !containsWord("add", in: normalized),
              !hasRemoveControlSignal(in: normalized),
              model.controls.count > 1 else {
            return nil
        }

        return AmigaProgramPatchError.ambiguousControlReference(model.controls.map(\.label)).errorDescription
    }

    private static func movePlacementSeparator(in prompt: String) -> (placement: AmigaProgramControlPlacement, range: Range<String.Index>)? {
        let patterns: [(String, AmigaProgramControlPlacement)] = [
            (#"(?i)\bbefore\b"#, .before),
            (#"(?i)\bafter\b"#, .after)
        ]
        for (pattern, placement) in patterns {
            guard let regex = try? NSRegularExpression(pattern: pattern) else { continue }
            let range = NSRange(prompt.startIndex..<prompt.endIndex, in: prompt)
            guard let match = regex.firstMatch(in: prompt, range: range),
                  let swiftRange = Range(match.range, in: prompt) else {
                continue
            }
            return (placement, swiftRange)
        }
        return nil
    }

    private static func controlReferenceLabel(in text: String, model: AmigaProgramModel) -> String? {
        let normalized = text.lowercased()
        return model.controls
            .sorted(by: { $0.label.count > $1.label.count })
            .first { control in
                containsPhrase(control.label, in: normalized) ||
                    containsPhrase(control.id.replacingOccurrences(of: "_", with: " "), in: normalized) ||
                    controlActionReferenceMatches(control.action, in: normalized)
            }?
            .label
    }

    private static func visibleControlReferenceLabel(in text: String, model: AmigaProgramModel) -> String? {
        let normalized = text.lowercased()
        return model.controls
            .compactMap { control -> (label: String, location: Int, length: Int)? in
                let promptTokens = normalized.split { !$0.isLetter && !$0.isNumber }
                let labelLocation = firstPhraseTokenIndex(control.label, in: promptTokens)
                let idLocation = firstPhraseTokenIndex(control.id.replacingOccurrences(of: "_", with: " "), in: promptTokens)
                guard let location = [labelLocation, idLocation].compactMap({ $0 }).min() else {
                    return nil
                }
                return (control.label, location, control.label.count)
            }
            .sorted { lhs, rhs in
                lhs.location == rhs.location ? lhs.length > rhs.length : lhs.location < rhs.location
            }
            .first?
            .label
    }

    private static func ordinalControlReferenceLabel(in text: String, model: AmigaProgramModel) -> String? {
        guard let ordinal = controlOrdinalRequest(in: text.lowercased()),
              model.controls.indices.contains(ordinal) else {
            return nil
        }
        return model.controls[ordinal].label
    }

    private static func cleanedMoveReference(from text: String) -> String? {
        let removableWords = Set([
            "move", "put", "place", "shift", "bring", "reorder",
            "the", "a", "an", "button", "buttons", "control", "controls", "to"
        ])
        let words = text
            .split { !$0.isLetter && !$0.isNumber }
            .map(String.init)
            .filter { !removableWords.contains($0.lowercased()) }
        guard !words.isEmpty else { return nil }
        return words.map { word in
            guard let first = word.first else { return word }
            return String(first).uppercased() + word.dropFirst().lowercased()
        }.joined(separator: " ")
    }

    private static func ordinalControlRemovalRejection(from prompt: String, model: AmigaProgramModel) -> String? {
        let normalized = prompt.lowercased()
        guard hasRemoveControlSignal(in: normalized),
              let ordinal = controlOrdinalRequest(in: normalized),
              !model.controls.indices.contains(ordinal) else {
            return nil
        }

        return "Cannot remove the \(ordinalDescription(ordinal)); this program has \(model.controls.count) controls."
    }

    private static func ambiguousLabelRenameRejection(from prompt: String, model: AmigaProgramModel) -> String? {
        let normalized = prompt.lowercased()
        guard hasRenameSignal(in: normalized),
              !containsWord("add", in: normalized),
              labelAfterRenameSeparator(in: prompt) != nil,
              hasControlNoun(in: normalized),
              model.controls.count > 1 else {
            return nil
        }

        return AmigaProgramPatchError.ambiguousControlReference(model.controls.map(\.label)).errorDescription
    }

    private static func ordinalLabelRenameRejection(from prompt: String, model: AmigaProgramModel) -> String? {
        let normalized = prompt.lowercased()
        guard hasRenameSignal(in: normalized),
              !containsWord("add", in: normalized),
              labelAfterRenameSeparator(in: prompt) != nil,
              let ordinal = controlOrdinalRequest(in: normalized),
              !model.controls.indices.contains(ordinal) else {
            return nil
        }

        return "Cannot rename the \(ordinalDescription(ordinal)); this program has \(model.controls.count) controls."
    }

    private static func ordinalDescription(_ zeroBasedIndex: Int) -> String {
        switch zeroBasedIndex {
        case 0: return "first control"
        case 1: return "second control"
        case 2: return "third control"
        case 3: return "fourth control"
        case 4: return "fifth control"
        case 5: return "sixth control"
        default: return "control \(zeroBasedIndex + 1)"
        }
    }

    private static func addControlOrdinalRejection(from prompt: String, model: AmigaProgramModel) -> String? {
        let normalized = prompt.lowercased()
        guard containsWord("add", in: normalized),
              let requestedOrdinal = controlOrdinalRequest(in: normalized),
              requestedOrdinal != model.controls.count else {
            return nil
        }

        return "Cannot add the \(ordinalDescription(requestedOrdinal)); next control slot is \(ordinalDescription(model.controls.count))."
    }

    private static func controlActionReferenceMatches(_ action: String, in normalizedPrompt: String) -> Bool {
        switch action.lowercased() {
        case "volumeup":
            return containsPhrase("volume up", in: normalizedPrompt) ||
                containsPhrase("raise volume", in: normalizedPrompt) ||
                containsPhrase("increase volume", in: normalizedPrompt) ||
                containsPhrase("turn volume up", in: normalizedPrompt) ||
                containsWord("louder", in: normalizedPrompt)
        case "volumedown":
            return containsPhrase("volume down", in: normalizedPrompt) ||
                containsPhrase("lower volume", in: normalizedPrompt) ||
                containsPhrase("decrease volume", in: normalizedPrompt) ||
                containsPhrase("turn volume down", in: normalizedPrompt) ||
                containsWord("quieter", in: normalizedPrompt)
        case "pausemod":
            return containsWord("pause", in: normalizedPrompt)
        case "mute":
            return containsWord("mute", in: normalizedPrompt)
        case "playmod":
            return containsWord("play", in: normalizedPrompt)
        case "stopmod":
            return containsWord("stop", in: normalizedPrompt)
        default:
            return false
        }
    }

    private static func controlOrdinalRequest(in normalizedPrompt: String) -> Int? {
        let ordinals: [(String, Int)] = [
            ("first", 0),
            ("1st", 0),
            ("second", 1),
            ("2nd", 1),
            ("third", 2),
            ("3rd", 2),
            ("fourth", 3),
            ("4th", 3),
            ("fifth", 4),
            ("5th", 4),
            ("sixth", 5),
            ("6th", 5)
        ]
        guard hasControlNoun(in: normalizedPrompt) else {
            return nil
        }
        return ordinals.first { ordinal, _ in
            containsPhrase("\(ordinal) button", in: normalizedPrompt) || containsPhrase("\(ordinal) control", in: normalizedPrompt)
        }?.1
    }

    static func addControlRequest(from prompt: String) -> (label: String, action: String)? {
        let normalized = prompt.lowercased()
        guard hasAddControlSignal(in: normalized) else {
            return nil
        }
        let explicitLabel = explicitAddControlLabel(from: prompt)
        return addControlBehaviorIntents(in: normalized)
            .first
            .map { behavior in (explicitLabel ?? behavior.name, behavior.action) }
    }

    private static func addControlRequests(from prompt: String) -> [(label: String, action: String)]? {
        let normalized = prompt.lowercased()
        guard hasAddControlSignal(in: normalized),
              explicitAddControlLabel(from: prompt) == nil,
              controlOrdinalRequest(in: normalized) == nil,
              allowsMultiControlAddNouns(in: normalized) else {
            return nil
        }

        let behaviors = addControlBehaviorIntents(in: normalized)
        if behaviors.isEmpty,
           requestsVolumeControlPair(in: normalized) {
            return [
                (label: "Volume Up", action: "VolumeUp"),
                (label: "Volume Down", action: "VolumeDown")
            ]
        }
        guard behaviors.count > 1 else { return nil }
        return behaviors.map { behavior in
            (label: behavior.name, action: behavior.action)
        }
    }

    private static func conflictingAddControlRejection(from prompt: String) -> String? {
        let normalized = prompt.lowercased()
        guard hasAddControlSignal(in: normalized),
              hasControlNoun(in: normalized) else {
            return nil
        }

        let behaviors = addControlBehaviorIntents(in: normalized)
        guard behaviors.count > 1 else { return nil }
        if explicitAddControlLabel(from: prompt) == nil,
           controlOrdinalRequest(in: normalized) == nil,
           allowsMultiControlAddNouns(in: normalized) {
            return nil
        }
        return AmigaProgramPatchError.conflictingControlBehaviors(behaviors.map(\.name)).errorDescription
    }

    private static func duplicateAddControlRequestRejection(from prompt: String) -> String? {
        let normalized = prompt.lowercased()
        guard hasAddControlSignal(in: normalized) else { return nil }
        let promptTokens = normalized.split { !$0.isLetter && !$0.isNumber }
        for candidate in addControlBehaviorCandidates() {
            for phrase in candidate.matches where phraseTokenIndexes(phrase, in: promptTokens).count > 1 {
                return AmigaProgramPatchError.duplicateRequestedControl(candidate.name).errorDescription
            }
            for word in candidate.wordMatches where wordTokenIndexes(word, in: promptTokens).count > 1 {
                return AmigaProgramPatchError.duplicateRequestedControl(candidate.name).errorDescription
            }
        }
        return nil
    }

    private static func addControlBehaviorIntents(in normalized: String) -> [(action: String, name: String)] {
        addControlBehaviorIntentLocations(in: normalized)
            .map { ($0.action, $0.name) }
    }

    private static func addControlBehaviorIntentLocations(in normalized: String) -> [(action: String, name: String, location: Int)] {
        let candidates = addControlBehaviorCandidates()

        let promptTokens = normalized.split { !$0.isLetter && !$0.isNumber }
        var results: [(action: String, name: String, location: Int)] = []
        for candidate in candidates {
            let locations =
                candidate.matches.compactMap { firstPhraseTokenIndex($0, in: promptTokens) } +
                candidate.wordMatches.compactMap { firstWordTokenIndex($0, in: promptTokens) }
            guard let location = locations.min() else { continue }
            if let existing = results.firstIndex(where: { $0.action == candidate.action }) {
                results[existing].location = min(results[existing].location, location)
            } else {
                results.append((candidate.action, candidate.name, location))
            }
        }
        return results
            .sorted { lhs, rhs in
                lhs.location == rhs.location ? lhs.name < rhs.name : lhs.location < rhs.location
            }
    }

    private static func addControlBehaviorCandidates() -> [(action: String, name: String, matches: [String], wordMatches: [String])] {
        [
            ("VolumeUp", "Volume Up", ["volume up", "volume-up", "raise volume", "increase volume", "turn volume up"], ["louder"]),
            ("VolumeDown", "Volume Down", ["volume down", "volume-down", "lower volume", "decrease volume", "turn volume down"], ["quieter"]),
            ("Mute", "Mute", [], ["mute"]),
            ("PauseMOD", "Pause", [], ["pause"]),
            ("StopMOD", "Stop", ["stop mod", "stop playback", "stop button", "stop control"], []),
            ("PlayMOD", "Play", ["play mod", "start playback", "play button", "play control"], [])
        ]
    }

    private static func requestsVolumeControlPair(in normalized: String) -> Bool {
        containsWord("volume", in: normalized) &&
            (containsWord("controls", in: normalized) || containsWord("buttons", in: normalized))
    }

    private static func containsPhrase(_ phrase: String, in normalizedPrompt: String) -> Bool {
        let promptTokens = normalizedPrompt.split { !$0.isLetter && !$0.isNumber }
        return firstPhraseTokenIndex(phrase, in: promptTokens) != nil
    }

    private static func firstPhraseTokenIndex(_ phrase: String, in promptTokens: [Substring]) -> Int? {
        phraseTokenIndexes(phrase, in: promptTokens).first
    }

    private static func phraseTokenIndexes(_ phrase: String, in promptTokens: [Substring]) -> [Int] {
        let phraseTokens = phrase.lowercased().split { !$0.isLetter && !$0.isNumber }
        guard !phraseTokens.isEmpty,
              phraseTokens.count <= promptTokens.count else {
            return []
        }
        var indexes: [Int] = []
        for start in 0...(promptTokens.count - phraseTokens.count) {
            let window = promptTokens[start..<(start + phraseTokens.count)]
            if zip(window, phraseTokens).allSatisfy({ $0 == $1 }) {
                indexes.append(start)
            }
        }
        return indexes
    }

    private static func firstWordTokenIndex(_ word: String, in promptTokens: [Substring]) -> Int? {
        wordTokenIndexes(word, in: promptTokens).first
    }

    private static func wordTokenIndexes(_ word: String, in promptTokens: [Substring]) -> [Int] {
        let normalizedWord = word.lowercased()
        return promptTokens.indices.filter { promptTokens[$0] == normalizedWord }
    }

    private static func explicitAddControlLabel(from prompt: String) -> String? {
        if let quoted = firstQuotedText(in: prompt)?.trimmingCharacters(in: .whitespacesAndNewlines),
           !quoted.isEmpty {
            return quoted
        }

        let labelTerminator = #"\s+(?:to|that|which|center|centered|below|under|beneath|above|left|right|before|after|and)\b|$"#
        let patterns = [
            #"(?i)\bcalled\s+([^"”'\n.,]+?)(?:\#(labelTerminator))"#,
            #"(?i)\bnamed\s+([^"”'\n.,]+?)(?:\#(labelTerminator))"#,
            #"(?i)\bwith\s+(?:label|text|caption|title)\b\s+([^"”'\n.,]+?)(?:\#(labelTerminator))"#,
            #"(?i)\blabel(?:ed|led)\s+([^"”'\n.,]+?)(?:\#(labelTerminator))"#,
            #"(?i)\b(?:label|text|caption|title)\b\s+([^"”'\n.,]+?)(?:\#(labelTerminator))"#
        ]
        for pattern in patterns {
            guard let regex = try? NSRegularExpression(pattern: pattern) else { continue }
            let range = NSRange(prompt.startIndex..<prompt.endIndex, in: prompt)
            guard let match = regex.firstMatch(in: prompt, range: range),
                  match.numberOfRanges > 1,
                  let matchRange = Range(match.range(at: 1), in: prompt) else {
                continue
            }
            let label = prompt[matchRange]
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .trimmingCharacters(in: CharacterSet(charactersIn: "\"'“”"))
            return label.isEmpty ? nil : label
        }

        return nil
    }

    private static func unsupportedAddControlLabel(from prompt: String) -> String? {
        let normalized = prompt.lowercased()
        guard hasAddControlSignal(in: normalized),
              hasControlNoun(in: normalized) else {
            return nil
        }

        if let quoted = firstQuotedText(in: prompt)?.trimmingCharacters(in: .whitespacesAndNewlines),
           !quoted.isEmpty {
            return quoted
        }
        if let label = labelAfterRenameSeparator(in: prompt) {
            return label
        }
        return "requested control"
    }

    private static func hasRenameSignal(in normalizedPrompt: String) -> Bool {
        containsWord("rename", in: normalizedPrompt) ||
            containsWord("label", in: normalizedPrompt) ||
            containsWord("labeled", in: normalizedPrompt) ||
            containsWord("labelled", in: normalizedPrompt) ||
            containsWord("called", in: normalizedPrompt) ||
            containsWord("named", in: normalizedPrompt) ||
            containsWord("text", in: normalizedPrompt) ||
            containsWord("caption", in: normalizedPrompt) ||
            containsWord("title", in: normalizedPrompt) ||
            containsWord("say", in: normalizedPrompt)
    }

    private static func hasControlRenameSignalOutsideAddLabel(in normalizedPrompt: String) -> Bool {
        containsWord("rename", in: normalizedPrompt) ||
            containsWord("label", in: normalizedPrompt) ||
            containsWord("labeled", in: normalizedPrompt) ||
            containsWord("labelled", in: normalizedPrompt) ||
            containsWord("text", in: normalizedPrompt) ||
            containsWord("caption", in: normalizedPrompt) ||
            containsWord("title", in: normalizedPrompt) ||
            containsWord("say", in: normalizedPrompt)
    }

    private static func hasAddControlSignal(in normalizedPrompt: String) -> Bool {
        containsWord("add", in: normalizedPrompt) ||
            containsWord("third", in: normalizedPrompt) ||
            containsWord("another", in: normalizedPrompt)
    }

    private static func hasRemoveControlSignal(in normalizedPrompt: String) -> Bool {
        containsWord("remove", in: normalizedPrompt) ||
            containsWord("delete", in: normalizedPrompt) ||
            containsWord("drop", in: normalizedPrompt)
    }

    private static func hasMoveControlSignal(in normalizedPrompt: String) -> Bool {
        containsWord("move", in: normalizedPrompt) ||
            containsWord("put", in: normalizedPrompt) ||
            containsWord("place", in: normalizedPrompt) ||
            containsWord("shift", in: normalizedPrompt) ||
            containsWord("bring", in: normalizedPrompt) ||
            containsWord("reorder", in: normalizedPrompt)
    }

    private static func hasControlNoun(in normalizedPrompt: String) -> Bool {
        containsWord("button", in: normalizedPrompt) ||
            containsWord("buttons", in: normalizedPrompt) ||
            containsWord("control", in: normalizedPrompt) ||
            containsWord("controls", in: normalizedPrompt)
    }

    private static func hasSingularControlNoun(in normalizedPrompt: String) -> Bool {
        containsWord("button", in: normalizedPrompt) ||
            containsWord("control", in: normalizedPrompt)
    }

    private static func allowsMultiControlAddNouns(in normalizedPrompt: String) -> Bool {
        !hasSingularControlNoun(in: normalizedPrompt) ||
            controlNounOccurrenceCount(in: normalizedPrompt) > 1
    }

    private static func controlNounOccurrenceCount(in normalizedPrompt: String) -> Int {
        normalizedPrompt
            .split { !$0.isLetter && !$0.isNumber }
            .filter { token in
                token == "button" ||
                    token == "buttons" ||
                    token == "control" ||
                    token == "controls"
            }
            .count
    }

    private static func canonicalAction(for label: String) -> String {
        switch AmigaProgramPatcher.stableID(from: label) {
        case "volume_up":
            return "VolumeUp"
        case "volume_down":
            return "VolumeDown"
        case "pause":
            return "PauseMOD"
        case "mute":
            return "Mute"
        default:
            return AmigaProgramPatcher.stableLabel(from: label)
        }
    }

    private static func firstQuotedText(in prompt: String) -> String? {
        quotedTexts(in: prompt).first
    }

    private static func quotedTexts(in prompt: String) -> [String] {
        let patterns = [#""([^"]+)""#, #"“([^”]+)”"#, #"'([^']+)'"#]
        var matches: [(location: Int, text: String)] = []
        for pattern in patterns {
            guard let regex = try? NSRegularExpression(pattern: pattern) else { continue }
            let range = NSRange(prompt.startIndex..<prompt.endIndex, in: prompt)
            for match in regex.matches(in: prompt, range: range) {
                guard match.numberOfRanges > 1,
                      let matchRange = Range(match.range(at: 1), in: prompt) else {
                    continue
                }
                matches.append((match.range.location, String(prompt[matchRange])))
            }
        }
        return matches
            .sorted { $0.location < $1.location }
            .map(\.text)
    }

    private static func labelAfterRenameSeparator(in prompt: String) -> String? {
        let labelTerminator = #"\s+(?:and|that|which|center|centered|below|under|beneath|above|left|right|before|after)\b|$"#
        let patterns = [
            #"(?i)\bto\s+["“']?([^"”'\n.,]+?)["”']?(?:\#(labelTerminator))"#,
            #"(?i)\bcalled\s+["“']?([^"”'\n.,]+?)["”']?(?:\#(labelTerminator))"#,
            #"(?i)\bnamed\s+["“']?([^"”'\n.,]+?)["”']?(?:\#(labelTerminator))"#,
            #"(?i)\bsay\s+["“']?([^"”'\n.,]+?)["”']?(?:\#(labelTerminator))"#,
            #"(?i)\blabel(?:ed|led)\s+["“']?([^"”'\n.,]+?)["”']?(?:\#(labelTerminator))"#,
            #"(?i)\b(?:label|text|caption|title)\b\s+["“']?([^"”'\n.,]+?)["”']?(?:\#(labelTerminator))"#
        ]
        for pattern in patterns {
            guard let regex = try? NSRegularExpression(pattern: pattern) else { continue }
            let range = NSRange(prompt.startIndex..<prompt.endIndex, in: prompt)
            guard let match = regex.firstMatch(in: prompt, range: range),
                  match.numberOfRanges > 1,
                  let matchRange = Range(match.range(at: 1), in: prompt) else {
                continue
            }
            let label = prompt[matchRange]
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .trimmingCharacters(in: CharacterSet(charactersIn: "\"'“”"))
            return label.isEmpty ? nil : label
        }
        return nil
    }

    private static func firstInteger(in prompt: String) -> Int? {
        if let targetValue = targetSeparatorInteger(in: prompt) {
            return targetValue
        }
        guard let regex = try? NSRegularExpression(pattern: integerPattern) else { return nil }
        let range = NSRange(prompt.startIndex..<prompt.endIndex, in: prompt)
        guard let match = regex.firstMatch(in: prompt, range: range) else {
            return nil
        }
        return integerValue(from: match, in: prompt, groupOffset: 0)
    }

    private static let integerPattern = #"(?<![A-Za-z0-9_])(-?)(?:\$([0-9A-Fa-f]{1,4})|0[xX]([0-9A-Fa-f]{1,4})|([0-9]{1,4}))(?![A-Za-z0-9_])"#

    private static func targetSeparatorInteger(in prompt: String) -> Int? {
        guard let regex = try? NSRegularExpression(pattern: #"(?i)(?:\bto\b|=)\s+\#(integerPattern)"#) else {
            return nil
        }
        let range = NSRange(prompt.startIndex..<prompt.endIndex, in: prompt)
        guard let match = regex.firstMatch(in: prompt, range: range) else {
            return nil
        }
        return integerValue(from: match, in: prompt, groupOffset: 0)
    }

    private static func integerValue(from match: NSTextCheckingResult, in prompt: String, groupOffset: Int) -> Int? {
        let sign = Range(match.range(at: groupOffset + 1), in: prompt).map { String(prompt[$0]) } ?? ""
        let parsed: Int?
        if let hexRange = Range(match.range(at: groupOffset + 2), in: prompt) {
            parsed = Int(prompt[hexRange], radix: 16)
        } else if let cHexRange = Range(match.range(at: groupOffset + 3), in: prompt) {
            parsed = Int(prompt[cHexRange], radix: 16)
        } else if let decimalRange = Range(match.range(at: groupOffset + 4), in: prompt) {
            parsed = Int(prompt[decimalRange])
        } else {
            parsed = nil
        }
        guard let value = parsed else { return nil }
        return sign == "-" ? -value : value
    }
}
