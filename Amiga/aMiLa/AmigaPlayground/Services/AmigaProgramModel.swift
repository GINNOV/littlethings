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
    var supportedFollowUps: [String]
    var requiredFollowUpSmokePrompts: [String]
    var requiredFollowUpSmokeChains: [[String]]
    var requiredRejectedFollowUpSmokePrompts: [String]
    var requiredRejectedFollowUpSmokeChains: [[String]]
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
        supportedFollowUps: [String],
        requiredFollowUpSmokePrompts: [String],
        requiredFollowUpSmokeChains: [[String]],
        requiredRejectedFollowUpSmokePrompts: [String],
        requiredRejectedFollowUpSmokeChains: [[String]] = [],
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
        self.supportedFollowUps = supportedFollowUps
        self.requiredFollowUpSmokePrompts = requiredFollowUpSmokePrompts
        self.requiredFollowUpSmokeChains = requiredFollowUpSmokeChains
        self.requiredRejectedFollowUpSmokePrompts = requiredRejectedFollowUpSmokePrompts
        self.requiredRejectedFollowUpSmokeChains = requiredRejectedFollowUpSmokeChains
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
            "Generate double-buffered bitplane animation that swaps front (red) and back (green) bitplane pointers on vblank and exits on left mouse click.",
            "Generate double-buffered bitplane animation that swaps front and back bitplane pointers on vblank and exits on left mouse click."
        ],
        rejectedFirstShotPromptExamples: [
            "Generate a double buffered audio sample player with clean start and stop controls."
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
        requiredHardware: [.bitplanes, .cia],
        requiredVerificationGates: [
            "verified first-shot template",
            "structured follow-up patcher",
            "AmigaProgramSourceVerifier",
            "AssemblySemanticValidator",
            "VASM compile",
            "bootable ADF generation",
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
        supportedFollowUps: [
            "add volume up",
            "add volume down",
            "add volume controls",
            "add pause",
            "add mute",
            "rename a visible control label",
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
            "set initial volume to -1",
            "set initial volume to $20",
            "set initial volume to 63"
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
                "change Stop button caption Halt",
                "set Halt button title Stop"
            ],
            [
                "set initial volume to 31",
                "set initial volume to 32 for channel 0"
            ],
            [
                "set initial volume to 31",
                "set initial volume to 0x21"
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
            "add a fourth button called Louder to raise volume"
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
                "rename Play button to Start",
                #"add another button called "Play" to start playback"#
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
                "rename Play button to Start",
                #"add another button called "Start" to raise volume"#
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
            "AmigaProgramSourceVerifier",
            "AssemblySemanticValidator",
            "VASM compile",
            "bootable ADF generation",
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
    struct RoutedFirstShotFollowUpArtifact {
        let firstShotPrompt: String
        let followUpPrompt: String
        let source: String
        let model: AmigaProgramModel
    }

    static let baselineRequiredVerificationGates = [
        "verified first-shot template",
        "structured follow-up patcher",
        "AmigaProgramSourceVerifier",
        "AssemblySemanticValidator",
        "VASM compile",
        "bootable ADF generation",
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
        for supportedFollowUp in manifest.supportedFollowUps
            where !acceptedSmokePrompts(in: manifest).contains(where: { smokePromptCovers($0, supportedFollowUp: supportedFollowUp) }) {
            failures.append("\(manifest.id): supported follow-up lacks accepted smoke coverage: \(supportedFollowUp).")
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

        failures.append(contentsOf: firstShotPromptGateFailures(for: manifest))
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

        for prompt in manifest.firstShotPromptExamples {
            guard let match = AssistantPromptTemplate.match(for: prompt) else {
                continue
            }
            failures.append(contentsOf: firstShotFollowUpSmokeFailures(
                for: manifest,
                prompt: prompt,
                source: match.source
            ))
        }

        failures.append(contentsOf: followUpSmokeFailures(for: manifest, source: source))
        failures.append(contentsOf: rejectedFollowUpSmokeFailures(for: manifest, source: source))
        failures.append(contentsOf: ignoredFollowUpSmokeFailures(for: manifest, source: source))

        return failures
    }

    private static func firstShotPromptGateFailures(for manifest: AmigaProgramFamilyManifest) -> [String] {
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
            let semantic = AssemblySemanticValidator.validate(source: match.source, prompt: prompt)
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
        ": missing required rejected follow-up smoke chains.",
        ": duplicate required rejected follow-up smoke chains:",
        ": required rejected follow-up smoke chain ",
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
        let failures = followUpSmokeFailures(for: manifest, source: source) +
            rejectedFollowUpSmokeFailures(for: manifest, source: source) +
            ignoredFollowUpSmokeFailures(for: manifest, source: source)
        return failures.map {
            "\(manifest.id): first-shot prompt follow-up smoke failure for prompt \(prompt): \($0)"
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
        return requiredPromptArtifacts + chainArtifacts + rejectedChainSetupArtifacts
    }

    static func routedFirstShotAcceptedFollowUpSmokeSources(
        for manifest: AmigaProgramFamilyManifest
    ) throws -> [RoutedFirstShotFollowUpArtifact] {
        try manifest.firstShotPromptExamples.flatMap { firstShotPrompt in
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
        var failures = followUpSmokeFailures(
            for: manifest,
            source: source,
            prompts: manifest.requiredFollowUpSmokePrompts,
            chainName: "required prompt chain"
        )

        for (index, prompts) in manifest.requiredFollowUpSmokeChains.enumerated() {
            failures.append(contentsOf: followUpSmokeFailures(
                for: manifest,
                source: source,
                prompts: prompts,
                chainName: "conversation chain \(index + 1)"
            ))
        }

        return failures
    }

    static func rejectedFollowUpSmokeFailures(for manifest: AmigaProgramFamilyManifest, source: String) -> [String] {
        var failures: [String] = []

        for prompt in manifest.requiredRejectedFollowUpSmokePrompts {
            switch AmigaProgramFollowUpPlanner.patchOutcome(prompt: prompt, source: source) {
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
                chainName: "required rejected follow-up smoke chain \(index + 1)"
            ))
        }

        return failures
    }

    static func ignoredFollowUpSmokeFailures(for manifest: AmigaProgramFamilyManifest, source: String) -> [String] {
        var failures: [String] = []

        for prompt in manifest.requiredIgnoredFollowUpSmokePrompts {
            switch AmigaProgramFollowUpPlanner.patchOutcome(prompt: prompt, source: source) {
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
        return manifest.requiredFollowUpSmokePrompts +
            manifest.requiredFollowUpSmokeChains.flatMap { $0 } +
            rejectedChainSetupPrompts
    }

    private static func rejectedSmokePrompts(in manifest: AmigaProgramFamilyManifest) -> [String] {
        manifest.requiredRejectedFollowUpSmokePrompts +
            manifest.requiredRejectedFollowUpSmokeChains.compactMap(\.last)
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
        guard prompts.count >= 2 else { return [] }

        var failures: [String] = []
        var currentSource = source
        var previousModel = AmigaSourceIndexer.index(source).model
        let acceptedSetupPrompts = prompts.dropLast()
        let rejectedPrompt = prompts[prompts.count - 1]

        for prompt in acceptedSetupPrompts {
            switch AmigaProgramFollowUpPlanner.patchOutcome(prompt: prompt, source: currentSource) {
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

        switch AmigaProgramFollowUpPlanner.patchOutcome(prompt: rejectedPrompt, source: currentSource) {
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
        var failures: [String] = []
        var currentSource = source
        var previousModel = AmigaSourceIndexer.index(source).model

        for prompt in prompts {
            switch AmigaProgramFollowUpPlanner.patchOutcome(prompt: prompt, source: currentSource) {
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
            guard let previousBody = routineBody(previousRoutine.label, inRegion: expectedRegion.rawValue, source: previousSource, sourceLines: previousLines),
                  let resultBody = routineBody(previousRoutine.label, inRegion: expectedRegion.rawValue, source: result.source, sourceLines: resultLines) else {
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
        let previousLabels = labelNames(inRegion: AmigaSourceRegionName.chipData.rawValue, source: previousSource, sourceLines: previousLines)
        let resultLabels = Set(labelNames(inRegion: AmigaSourceRegionName.chipData.rawValue, source: result.source, sourceLines: resultLines))
        var failures: [String] = []

        for label in previousLabels where resultLabels.contains(label) {
            guard !isDataBlockSuperseded(label, previousModel: previousModel, resultModel: result.model, prompt: prompt) else {
                continue
            }
            guard let previousBlock = dataBlock(label, inRegion: AmigaSourceRegionName.chipData.rawValue, source: previousSource, sourceLines: previousLines),
                  let resultBlock = dataBlock(label, inRegion: AmigaSourceRegionName.chipData.rawValue, source: result.source, sourceLines: resultLines) else {
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
        guard label.hasPrefix("ControlLabel_") else {
            return false
        }
        let controlID = String(label.dropFirst("ControlLabel_".count))
        guard let previousControl = previousModel.controls.first(where: { $0.id == controlID }) else {
            return false
        }
        return isControlLabelSuperseded(previousControl, by: resultModel.verificationExpectations, prompt: prompt)
    }

    private static func isActionRoutineBodySuperseded(_ action: String, by resultExpectations: [String], prompt: String) -> Bool {
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
        return false
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
            return AmigaSourceIndexer.index(line).labels.isEmpty == false
        } ?? regionEndIndex
        return trimmedRoutineBody(Array(sourceLines[labelIndex..<bodyEnd]))
    }

    private static func labelNames(inRegion name: String, source: String, sourceLines: [String]) -> [String] {
        let index = AmigaSourceIndexer.index(source)
        guard let region = index.regions[name], let endLine = region.endLine else {
            return []
        }
        let lowerBound = max(region.startLine - 1, 0)
        let upperBound = min(endLine - 1, sourceLines.count)
        guard lowerBound < upperBound else {
            return []
        }
        return sourceLines[lowerBound..<upperBound].flatMap { line in
            AmigaSourceIndexer.index(line).labels.filter { !$0.hasPrefix(".") }
        }
    }

    private static func routineBody(_ label: String, inRegion name: String, source: String, sourceLines: [String]) -> [String]? {
        let index = AmigaSourceIndexer.index(source)
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
            guard let label = AmigaSourceIndexer.index(line).labels.first else {
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
            AmigaSourceIndexer.index($0).labels.contains(label)
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
            !isVerificationExpectationSuperseded(previousExpectation, by: resultModel.verificationExpectations, prompt: prompt) {
            failures.append("\(manifest.id): follow-up \(prompt) did not preserve verification expectation: \(previousExpectation)")
        }
        for previousState in previousModel.stateVariables
            where !resultModel.stateVariables.contains(where: { $0.id == previousState.id && $0.symbol == previousState.symbol }) {
            failures.append("\(manifest.id): follow-up \(prompt) did not preserve state variable \(previousState.id) -> \(previousState.symbol).")
        }
        for resultState in resultModel.stateVariables
            where !previousModel.stateVariables.contains(where: { $0.id == resultState.id && $0.symbol == resultState.symbol }) {
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
            where !resultModel.controls.contains(where: { $0.id == previousControl.id && $0.action == previousControl.action }) {
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
            if resultIndex != previousIndex {
                failures.append("\(manifest.id): follow-up \(prompt) changed control \(previousControl.id) slot from \(previousIndex + 1) to \(resultIndex + 1).")
            }
            if resultControl.label != previousControl.label &&
                !isControlLabelSuperseded(previousControl, by: resultModel.verificationExpectations, prompt: prompt) {
                failures.append("\(manifest.id): follow-up \(prompt) changed control \(previousControl.id) label from \(previousControl.label) to \(resultControl.label).")
            }
            if resultControl.bounds != previousControl.bounds {
                failures.append("\(manifest.id): follow-up \(prompt) changed control \(previousControl.id) bounds.")
            }
        }
        for previousRoutine in previousModel.routines
            where !resultModel.routines.contains(where: { $0.id == previousRoutine.id && $0.label == previousRoutine.label }) {
            failures.append("\(manifest.id): follow-up \(prompt) did not preserve routine \(previousRoutine.id) -> \(previousRoutine.label).")
        }
        let addedControlActions = Set(addedControls.map(\.action))
        for resultRoutine in resultModel.routines
            where !previousModel.routines.contains(where: { $0.id == resultRoutine.id && $0.label == resultRoutine.label }) &&
            !addedControlActions.contains(resultRoutine.label) {
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
                !isRoutineCallMetadataSuperseded(previousRoutine, resultRoutine: resultRoutine, addedControls: addedControls) {
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
            "Volume step is ",
            "Initial volume is ",
            "Front buffer color is ",
            "Back buffer color is "
        ]
        guard let prefix = supersededPrefixes.first(where: { previousExpectation.hasPrefix($0) }) else {
            return false
        }
        guard promptAllowsExpectationSupersession(prefix, prompt: prompt) else {
            return false
        }
        return resultExpectations.contains { $0.hasPrefix(prefix) }
    }

    private static func isControlLabelSuperseded(_ previousControl: AmigaProgramModel.Control, by resultExpectations: [String], prompt: String) -> Bool {
        guard smokePromptCovers(prompt, supportedFollowUp: "rename a visible control label") else {
            return false
        }
        return resultExpectations.contains {
            $0.hasPrefix("Control \(previousControl.label) is labeled ") &&
                $0.hasSuffix(" without changing \(previousControl.action).")
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
        case "Volume step is ":
            return promptAllowsVolumeStepSupersession(prompt)
        case "Initial volume is ":
            return smokePromptCovers(prompt, supportedFollowUp: "set initial volume")
        case "Front buffer color is ":
            return smokePromptCovers(prompt, supportedFollowUp: "set front color")
        case "Back buffer color is ":
            return smokePromptCovers(prompt, supportedFollowUp: "set back color")
        default:
            return false
        }
    }

    private static func promptAllowsVolumeStepSupersession(_ prompt: String) -> Bool {
        smokePromptCovers(prompt, supportedFollowUp: "change volume step")
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

    private static func labelName(from line: String) -> String? {
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

        let controlID = stableID(from: trimmedLabel)
        let actionLabel = stableLabel(from: action)

        if let existingControl = model.controls.first(where: { $0.id == controlID }),
           existingControl.label.caseInsensitiveCompare(trimmedLabel) == .orderedSame {
            throw AmigaProgramPatchError.duplicateControl(controlID)
        }
        if let existingControl = model.controls.first(where: { $0.action == actionLabel }) {
            throw AmigaProgramPatchError.duplicateAction(actionLabel, existingControl.label)
        }
        if let existingControl = model.controls.first(where: { $0.label.caseInsensitiveCompare(trimmedLabel) == .orderedSame }) {
            throw AmigaProgramPatchError.duplicateLabel(existingControl.label)
        }
        guard !model.controls.contains(where: { $0.id == controlID }) else {
            throw AmigaProgramPatchError.duplicateControl(controlID)
        }
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

        model.verificationExpectations.removeAll { $0.hasPrefix("Volume step is ") }
        model.verificationExpectations.append("Volume step is \(clampedStep).")
        patched = try replaceRegion(AmigaSourceRegionName.model.rawValue, in: patched, with: AmigaSourceIndexer.modelRegion(for: model))

        return try verifiedPatchResult(AmigaProgramPatchResult(
            source: patched,
            model: model,
            changedRegions: [
                AmigaSourceRegionName.model.rawValue,
                AmigaSourceRegionName.routines.rawValue
            ]
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
        patched = try replaceStateWordLine(label: "AudioVolume", inRegion: AmigaSourceRegionName.state.rawValue, source: patched, value: clampedVolume)

        return try verifiedPatchResult(AmigaProgramPatchResult(
            source: patched,
            model: model,
            changedRegions: [
                AmigaSourceRegionName.model.rawValue,
                AmigaSourceRegionName.state.rawValue
            ]
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

        return try verifiedPatchResult(AmigaProgramPatchResult(
            source: patched,
            model: model,
            changedRegions: [
                AmigaSourceRegionName.model.rawValue,
                AmigaSourceRegionName.state.rawValue
            ]
        ))
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

    private static func requireMODControlsModel(_ model: AmigaProgramModel) throws {
        guard model.id == AmigaProgramFamilyRegistry.modPlayerControls.id,
              model.kind == AmigaProgramFamilyRegistry.modPlayerControls.kind else {
            throw AmigaProgramPatchError.missingRegion("MOD controls model")
        }
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

    static func stableLabel(from action: String) -> String {
        let words = action
            .split { !$0.isLetter && !$0.isNumber }
            .map(String.init)
        let raw = words.isEmpty ? "ControlAction" : words.joined()
        guard let first = raw.first else { return "ControlAction" }
        return String(first).uppercased() + raw.dropFirst()
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
            if AmigaSourceIndexer.index(line).labels.isEmpty == false {
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

    private static func drawControlLines(id: String, slot: Int, bounds: AmigaProgramModel.Bounds) -> [String] {
        [
            "            ; @amiga:draw_control \(id) slot=\(slot) bounds=\(bounds.x),\(bounds.y),\(bounds.width),\(bounds.height)",
            "            lea        ControlRect_\(id)(pc),a0",
            "            bsr        DrawControlRect"
        ]
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
            return AmigaSourceIndexer.index(line).labels.isEmpty == false
        } ?? lines.count

        let start = lineStarts[bodyStartLine]
        let end = endLineIndex < lineStarts.count ? lineStarts[endLineIndex] : source.endIndex
        return start..<end
    }

    private static func lineDefinesLabel(_ line: String, label: String) -> Bool {
        AmigaSourceIndexer.index(line).labels.contains(label)
    }

    private struct ControlPatchSpec {
        var purpose: String
        var stateVariables: [AmigaProgramModel.StateVariable]
        var stateLines: [String]
        var routineLines: [String]
    }

    private static func controlPatchSpec(label: String, controlID: String, actionLabel: String) throws -> ControlPatchSpec {
        let canonicalAction = actionLabel.lowercased()
        if controlID == "volume_up" || canonicalAction == "volumeup" {
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

        if controlID == "volume_down" || canonicalAction == "volumedown" {
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

        if controlID == "mute" || canonicalAction == "mute" || canonicalAction == "mutemod" {
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

        if controlID == "pause" || canonicalAction == "pause" || canonicalAction == "pausemod" {
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

        throw AmigaProgramPatchError.unsupportedControl(label)
    }
}

enum AmigaProgramTemplate {
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
                AmigaProgramModel.Routine(id: "wait_vblank", label: "WaitVBlank", purpose: "Paces bitplane pointer swaps to vertical blank.")
            ],
            stateVariables: [
                AmigaProgramModel.StateVariable(id: "front_color", symbol: "FrontColor", purpose: "COLOR01 value used while BufferA is visible.", initialValue: frontValue),
                AmigaProgramModel.StateVariable(id: "back_color", symbol: "BackColor", purpose: "COLOR01 value used while BufferB is visible.", initialValue: backValue)
            ],
            hardware: [.bitplanes, .cia],
            verificationExpectations: [
                "Front buffer color is \(normalizedFrontColor).",
                "Back buffer color is \(normalizedBackColor).",
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
            movem.l    d2/a2-a3/a6,-(sp)
            lea        $dff000,a6
            lea        BufferA,a2
            lea        BufferB,a3
            move.w     #$1200,$100(a6)      ; BPLCON0: one low-res bitplane
            move.w     #$0000,$102(a6)      ; BPLCON1
            move.w     #$0000,$104(a6)      ; BPLCON2
            move.w     #$0000,$108(a6)      ; BPL1MOD
            move.w     #$0000,$10a(a6)      ; BPL2MOD
            move.w     #$0000,$180(a6)
            move.w     FrontColor(pc),$182(a6)
            move.w     #$8300,$96(a6)       ; master DMA + bitplane DMA

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
            bsr.s      DrawBufferB
            moveq      #1,d2
            bra.s      .main
.showB:
            move.w     BackColor(pc),$182(a6) ; COLOR01 for BufferB/back frame
            move.l     a3,$e0(a6)           ; BPL1PT
            bsr.s      DrawBufferA
            moveq      #0,d2
            bra.s      .main

.done:
            move.w     #$0100,$96(a6)
            movem.l    (sp)+,d2/a2-a3/a6
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
                "Playback state is preserved as data for follow-up edits."
            ]
        )

        return """
\(try AmigaSourceIndexer.modelRegion(for: model))
; Model-backed MOD player control scaffold.
            SECTION    Code,CODE
            XDEF       _Start
_Start:
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
    static func failures(in source: String) -> [String] {
        let index = AmigaSourceIndexer.index(source)
        let sourceLines = source.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        let modelRegionFailures = modelRegionEncodingFailures(index: index, sourceLines: sourceLines)
        var failures: [String] = []

        guard let model = index.model else {
            return ["Missing embedded Amiga program model."] + modelRegionFailures
        }

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
        failures.append(contentsOf: boundedControlSupportRoutineFailures(model: model))
        failures.append(contentsOf: boundedControlSupportRoutineCallFailures(model: model))
        failures.append(contentsOf: boundedControlStateVariableFailures(model: model))
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
            allowedLabels = Set(["BufferA", "BufferB", "PatternA", "PatternB"])
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
        if !startupLines.contains(where: { doubleBufferedMoveWordImmediateLine($0, value: 0x8300, destinationDisplacement: 0x96, register: "a6") }) {
            failures.append("Double-buffered bitplane startup does not enable bitplane DMA.")
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
        return sourceLines[lowerBound..<upperBound].flatMap { line in
            AmigaSourceIndexer.index(line).labels.filter { !$0.hasPrefix(".") }
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
            AmigaSourceIndexer.index($0).labels.contains("_Start")
        }),
              let mainLoopIndex = sourceLines[(startIndex + 1)...].firstIndex(where: {
                  AmigaSourceIndexer.index($0).labels.contains(".mainLoop")
              }),
              startIndex + 1 < mainLoopIndex else {
            return []
        }
        return Array(sourceLines[(startIndex + 1)..<mainLoopIndex])
    }

    private static func entryLoopLines(index: AmigaSourceIndex, sourceLines: [String]) -> [String] {
        guard let mainLoopIndex = sourceLines.firstIndex(where: {
            AmigaSourceIndexer.index($0).labels.contains(".mainLoop")
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
            AmigaSourceIndexer.index($0).labels.contains(label)
        }) else {
            return []
        }
        let firstRegionStartIndex = index.regions.values
            .map { max($0.startLine - 1, 0) }
            .filter { $0 > labelIndex }
            .min() ?? sourceLines.count
        let nextTopLevelLabelIndex = sourceLines[(labelIndex + 1)..<firstRegionStartIndex].firstIndex { line in
            AmigaSourceIndexer.index(line).labels.contains { !$0.hasPrefix(".") }
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
            AmigaSourceIndexer.index(line).labels.contains(label)
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
            if AmigaSourceIndexer.index(line).labels.isEmpty == false {
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
        guard let labelIndex = lines.firstIndex(where: { AmigaSourceIndexer.index($0).labels.contains(label) }) else {
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
            guard AmigaSourceIndexer.index(line).labels.contains(label),
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
            AmigaSourceIndexer.index(line).labels.contains(label)
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
            if model.id == AmigaProgramFamilyRegistry.doubleBufferedBitplane.id {
                switch bitplaneColorIntent(from: prompt) {
                case .request(let role, let color):
                    try verifyCurrentSourceBeforePatching(source)
                    return .patched(try verified(AmigaProgramPatcher.updateBitplaneColor(role: role, color: color, in: source)))
                case .requests(let requests):
                    try verifyCurrentSourceBeforePatching(source)
                    var patchedSource = source
                    var finalResult: AmigaProgramPatchResult?
                    for request in requests {
                        let result = try verified(AmigaProgramPatcher.updateBitplaneColor(role: request.role, color: request.color, in: patchedSource))
                        patchedSource = result.source
                        finalResult = result
                    }
                    guard let finalResult else { return .notRecognized }
                    return .patched(finalResult)
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
                    return .notRecognized
                }
            }
            guard model.id == AmigaProgramFamilyRegistry.modPlayerControls.id else {
                return .notRecognized
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
                guard let volume = firstInteger(in: prompt) else {
                    return .rejected(["Specify a numeric initial volume."])
                }
                return .patched(try verified(AmigaProgramPatcher.updateInitialVolume(volume, in: source)))
            }
            if let request = labelRenameRequest(from: prompt, model: model) {
                try verifyCurrentSourceBeforePatching(source)
                return .patched(try verified(AmigaProgramPatcher.renameControl(currentLabel: request.currentLabel, newLabel: request.newLabel, in: source)))
            }
            if let rejection = ordinalLabelRenameRejection(from: prompt, model: model) {
                try verifyCurrentSourceBeforePatching(source)
                return .rejected([rejection])
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
                for request in requests {
                    let result = try verified(AmigaProgramPatcher.addControl(label: request.label, action: request.action, to: patchedSource))
                    patchedSource = result.source
                    finalResult = result
                }
                guard let finalResult else { return .notRecognized }
                return .patched(finalResult)
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
            return .patched(try verified(AmigaProgramPatcher.addControl(label: request.label, action: request.action, to: source)))
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

    private static func patchErrorDescription(_ error: Error) -> String {
        if let localizedError = error as? LocalizedError,
           let description = localizedError.errorDescription {
            return description
        }
        return error.localizedDescription
    }

    static func volumeStepRequest(from prompt: String) -> Int? {
        guard volumeStepIntent(from: prompt) else { return nil }
        return firstInteger(in: prompt)
    }

    private static func volumeStepIntent(from prompt: String) -> Bool {
        let normalized = prompt.lowercased()
        let hasEditSignal = containsWord("set", in: normalized) ||
            containsWord("change", in: normalized) ||
            containsWord("update", in: normalized) ||
            containsWord("adjust", in: normalized) ||
            containsWord("make", in: normalized)
        return hasEditSignal &&
            containsWord("volume", in: normalized) &&
            (containsWord("step", in: normalized) || containsWord("increment", in: normalized) || containsWord("amount", in: normalized))
    }

    static func initialVolumeRequest(from prompt: String) -> Int? {
        guard initialVolumeIntent(from: prompt) else { return nil }
        return firstInteger(in: prompt)
    }

    private static func initialVolumeIntent(from prompt: String) -> Bool {
        let normalized = prompt.lowercased()
        let hasEditSignal = containsWord("set", in: normalized) ||
            containsWord("change", in: normalized) ||
            containsWord("update", in: normalized) ||
            containsWord("adjust", in: normalized) ||
            containsWord("make", in: normalized)
        guard hasEditSignal,
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
            .map { ($0.action, $0.name) }
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

        let patterns = [
            #"(?i)\bcalled\s+([^"”'\n.,]+?)(?:\s+to\b|\s+that\b|\s+which\b|$)"#,
            #"(?i)\bnamed\s+([^"”'\n.,]+?)(?:\s+to\b|\s+that\b|\s+which\b|$)"#,
            #"(?i)\bwith\s+(?:label|text|caption|title)\b\s+([^"”'\n.,]+?)(?:\s+to\b|\s+that\b|\s+which\b|$)"#,
            #"(?i)\blabel(?:ed|led)\s+([^"”'\n.,]+?)(?:\s+to\b|\s+that\b|\s+which\b|$)"#,
            #"(?i)\b(?:label|text|caption|title)\b\s+([^"”'\n.,]+?)(?:\s+to\b|\s+that\b|\s+which\b|$)"#
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

    private static func hasAddControlSignal(in normalizedPrompt: String) -> Bool {
        containsWord("add", in: normalizedPrompt) ||
            containsWord("third", in: normalizedPrompt) ||
            containsWord("another", in: normalizedPrompt)
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
        let patterns = [
            #"(?i)\bto\s+["“']?([^"”'\n.,]+)["”']?"#,
            #"(?i)\bcalled\s+["“']?([^"”'\n.,]+)["”']?"#,
            #"(?i)\bnamed\s+["“']?([^"”'\n.,]+)["”']?"#,
            #"(?i)\bsay\s+["“']?([^"”'\n.,]+)["”']?"#,
            #"(?i)\blabel(?:ed|led)\s+["“']?([^"”'\n.,]+)["”']?"#,
            #"(?i)\b(?:label|text|caption|title)\b\s+["“']?([^"”'\n.,]+)["”']?"#
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
