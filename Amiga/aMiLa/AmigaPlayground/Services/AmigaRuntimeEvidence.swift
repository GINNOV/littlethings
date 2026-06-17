import Foundation

struct AmigaRuntimeEvidenceManifest: Codable, Equatable {
    struct EmulatorCapture: Codable, Equatable {
        var backend: String
        var expectation: String
        var artifacts: [String]
        var minimumFrames: Int
    }

    var schemaVersion: Int
    var familyID: String
    var templateID: String
    var observationKind: String
    var expectedSignals: [String]
    var sourceProofs: [String]
    var emulatorCapture: EmulatorCapture
}

struct AmigaRuntimeEvidenceValidationResult: Equatable {
    var manifest: AmigaRuntimeEvidenceManifest
    var failures: [String]

    var passed: Bool {
        failures.isEmpty
    }
}

enum AmigaRuntimeEvidenceContract {
    static func validateModPlayerControls(source: String, prompt: String) -> AmigaRuntimeEvidenceValidationResult {
        let templateID = AmigaProgramFamilyRegistry.modPlayerControls.id
        let manifest = AmigaRuntimeEvidenceManifest(
            schemaVersion: 1,
            familyID: "mod_player_controls_complex",
            templateID: templateID,
            observationKind: "model-backed-paula-control-panel-with-boot-preview",
            expectedSignals: [
                "Embedded model declares Play and Stop controls with stable ids and actions.",
                "Startup calls PlayMOD before entering the persistent UI loop, making Paula state observable without synthetic mouse input.",
                "PlayMOD programs AUD0LC, AUD0LEN, AUD0PER, and AUD0VOL.",
                "PlayMOD enables AUD0 DMA through DMACON.",
                "StopMOD clears AUD0 DMA through DMACON.",
                "PlaybackState is set by PlayMOD and cleared by StopMOD.",
                "InputDispatch routes activated Play and Stop controls to PlayMOD and StopMOD.",
                "Mouse input uses click-edge activation so follow-up controls do not retrigger continuously.",
                "Follow-up edits preserve Play, Stop, AudioVolume, PlaybackState, and existing action routines."
            ],
            sourceProofs: [],
            emulatorCapture: .init(
                backend: "vAmiga",
                expectation: "paula-register-trace",
                artifacts: [
                    "bootable_adf",
                    "adf_inspection_json",
                    "boot_state_register_trace",
                    "raw_frame",
                    "retroshell_transcript",
                    "template_runtime_evidence_json",
                    "manifest_json"
                ],
                minimumFrames: 1
            )
        )

        var result = AmigaRuntimeEvidenceValidationResult(manifest: manifest, failures: [])
        let sourceFailures = AmigaProgramSourceVerifier.failures(in: source)
        if !sourceFailures.isEmpty {
            result.failures.append("source verifier failed: \(sourceFailures.joined(separator: "; "))")
        }

        let semantic = AssemblySemanticValidator.validate(source: source, prompt: prompt)
        if !semantic.passed {
            result.failures.append("semantic verifier failed: \(semantic.summary)")
        }

        let index = AmigaSourceIndexer.index(source)
        if index.model?.id != templateID {
            result.failures.append("missing MOD controls runtime model identity")
        } else {
            result.manifest.sourceProofs.append("embedded_model:\(templateID)")
        }

        appendProof("startup_playmod_preview", pattern: #"(?ims)^_Start\s*:.*bsr(?:\.\w+)?\s+PlayMOD.*bsr(?:\.\w+)?\s+DrawControls.*\.mainLoop\s*:"#, source: source, result: &result)
        appendProof("play_dispatch", pattern: #"(?is)@amiga:dispatch\s+play\s+->\s+PlayMOD.*bsr(?:\.\w+)?\s+PlayMOD"#, source: source, result: &result)
        appendProof("stop_dispatch", pattern: #"(?is)@amiga:dispatch\s+stop\s+->\s+StopMOD.*bsr(?:\.\w+)?\s+StopMOD"#, source: source, result: &result)
        appendProof("aud0lc_pointer_write", pattern: #"(?i)move\.l\s+a0\s*,\s*\$a0\s*\(\s*a6\s*\)"#, source: source, result: &result)
        appendProof("aud0len_write", pattern: #"(?i)move\.w\s+#8\s*,\s*\$a4\s*\(\s*a6\s*\)"#, source: source, result: &result)
        appendProof("aud0per_write", pattern: #"(?i)move\.w\s+#[0-9$xa-fA-F]+\s*,\s*\$a6\s*\(\s*a6\s*\)"#, source: source, result: &result)
        appendProof("aud0vol_write", pattern: #"(?i)move\.w\s+AudioVolume\s*\(\s*pc\s*\)\s*,\s*\$a8\s*\(\s*a6\s*\)"#, source: source, result: &result)
        appendProof("audio_dma_enable", pattern: #"(?i)move\.w\s+#\$8201\s*,\s*\$96\s*\(\s*a6\s*\)"#, source: source, result: &result)
        appendProof("audio_dma_stop", pattern: #"(?i)move\.w\s+#\$0001\s*,\s*\$96\s*\(\s*a6\s*\)"#, source: source, result: &result)
        appendProof("playback_state_set", pattern: #"(?i)move\.w\s+#1\s*,\s*PlaybackState"#, source: source, result: &result)
        appendProof("playback_state_clear", pattern: #"(?i)clr\.w\s+PlaybackState"#, source: source, result: &result)
        appendProof("click_edge_activation", pattern: #"(?is)ReadMouseControls\s*:.*move\.w\s+d1\s*,\s*MouseClicked.*move\.w\s+d0\s*,\s*MouseWasButtons"#, source: source, result: &result)

        return result
    }

    static func validateDoubleBufferedBitplane(source: String, prompt: String) -> AmigaRuntimeEvidenceValidationResult {
        let templateID = AmigaProgramFamilyRegistry.doubleBufferedBitplane.id
        let manifest = AmigaRuntimeEvidenceManifest(
            schemaVersion: 1,
            familyID: "double_buffered_bitplane_sprite_copper",
            templateID: templateID,
            observationKind: "vblank-paced-double-buffered-bitplane-with-copper-sprite-overlay",
            expectedSignals: [
                "Booted frame is not Workbench/AmigaDOS placeholder.",
                "Generated code disables inherited interrupts and DMA before taking over the display.",
                "BPLCON0 configures one low-resolution bitplane.",
                "Front and back buffers are distinct chip-memory labels.",
                "Both BufferA and BufferB are written to BPL1PT as visible front/back frames.",
                "An owned copper list is installed through COP1LC and refreshed through COPJMP1.",
                "The copper list contains BPLCON0, BPL1PT, SPR0PT, COLOR00, and COLOR01 entries.",
                "Sprite DMA overlays the bitplane buffer through a nonzero SPR0PT pointer.",
                "DMACON enables bitplane, copper, and sprite DMA together.",
                "WaitVBlank paces each pointer swap.",
                "Left mouse button exits through the cleanup path."
            ],
            sourceProofs: [],
            emulatorCapture: .init(
                backend: "vAmiga",
                expectation: "motion-plus-register-trace",
                artifacts: [
                    "bootable_adf",
                    "adf_inspection_json",
                    "boot_state_register_trace",
                    "raw_frame",
                    "frame_analysis_json",
                    "retroshell_transcript",
                    "template_runtime_evidence_json",
                    "manifest_json"
                ],
                minimumFrames: 2
            )
        )

        var result = AmigaRuntimeEvidenceValidationResult(manifest: manifest, failures: [])
        let sourceFailures = AmigaProgramSourceVerifier.failures(in: source)
        if !sourceFailures.isEmpty {
            result.failures.append("source verifier failed: \(sourceFailures.joined(separator: "; "))")
        }

        let semantic = AssemblySemanticValidator.validate(source: source, prompt: prompt)
        if !semantic.passed {
            result.failures.append("semantic verifier failed: \(semantic.summary)")
        }

        let index = AmigaSourceIndexer.index(source)
        if index.model?.id != templateID {
            result.failures.append("missing double-buffered bitplane runtime model identity")
        } else {
            result.manifest.sourceProofs.append("embedded_model:\(templateID)")
        }

        appendProof("front_color_output", pattern: #"(?i)move\.w\s+FrontColor\s*\(\s*pc\s*\)\s*,\s*\$182\s*\(\s*a6\s*\)"#, source: source, result: &result)
        appendProof("back_color_output", pattern: #"(?i)move\.w\s+BackColor\s*\(\s*pc\s*\)\s*,\s*\$182\s*\(\s*a6\s*\)"#, source: source, result: &result)
        appendProof("front_buffer_pointer_swap", pattern: #"(?i)move\.l\s+a2\s*,\s*\$e0\s*\(\s*a6\s*\)"#, source: source, result: &result)
        appendProof("back_buffer_pointer_swap", pattern: #"(?i)move\.l\s+a3\s*,\s*\$e0\s*\(\s*a6\s*\)"#, source: source, result: &result)
        appendProof("low_res_bitplane_mode", pattern: #"(?i)move\.w\s+#\$1200\s*,\s*\$100\s*\(\s*a6\s*\)"#, source: source, result: &result)
        appendProof("hardware_takeover_dmacon_clear", pattern: #"(?i)move\.w\s+#\$7fff\s*,\s*\$96\s*\(\s*a6\s*\)"#, source: source, result: &result)
        appendProof("interrupts_disabled_for_hardware_frame", pattern: #"(?i)move\.w\s+#\$7fff\s*,\s*\$9a\s*\(\s*a6\s*\)"#, source: source, result: &result)
        appendProof("owned_copper_list_installed", pattern: #"(?is)lea\s+CopperList\s*,\s*a0.*move\.l\s+a0\s*,\s*\$80\s*\(\s*a6\s*\).*move\.w\s+#\$0000\s*,\s*\$88\s*\(\s*a6\s*\)"#, source: source, result: &result)
        appendProof("owned_copper_bitplane_sprite_palette", pattern: #"(?is)CopperList\s*:.*\$0100\s*,\s*\$1200.*CopperBplHi\s*:.*CopperBplLo\s*:.*CopperSpr0Hi\s*:.*CopperSpr0Lo\s*:.*\$0182"#, source: source, result: &result)
        appendProof("sprite_pointer_setup", pattern: #"(?i)move\.l\s+a4\s*,\s*\$120\s*\(\s*a6\s*\)"#, source: source, result: &result)
        appendProof("bitplane_copper_sprite_dma_enable", pattern: #"(?i)move\.w\s+#\$83a0\s*,\s*\$96\s*\(\s*a6\s*\)"#, source: source, result: &result)
        appendProof("vblank_wait_routine", pattern: #"(?im)^WaitVBlank\s*:"#, source: source, result: &result)
        appendProof("vblank_before_swap", pattern: #"(?is)bsr(?:\.\w+)?\s+WaitVBlank.*move\.l\s+a2\s*,\s*\$e0\s*\(\s*a6\s*\).*bsr(?:\.\w+)?\s+DrawBufferB"#, source: source, result: &result)
        appendProof("distinct_visible_frame_data", pattern: #"(?is)BufferA\s*:.*BufferB\s*:.*PatternA\s*:.*PatternB\s*:"#, source: source, result: &result)
        appendProof("left_mouse_exit", pattern: #"(?i)btst\s+#6\s*,\s*\$bfe001"#, source: source, result: &result)

        return result
    }

    static func validateBlitterBOBCollisionBounds(source: String, prompt: String) -> AmigaRuntimeEvidenceValidationResult {
        let manifest = AmigaRuntimeEvidenceManifest(
            schemaVersion: 1,
            familyID: "blitter_bob_collision_bounds",
            templateID: AmigaProgramTemplate.blitterBOBCollisionBoundsID,
            observationKind: "vblank-paced-visible-blitter-object-with-collision-state",
            expectedSignals: [
                "Booted frame is not Workbench/AmigaDOS placeholder.",
                "BPL1PT points at Bitplane before DMA is enabled.",
                "BPLCON0 configures one low-resolution bitplane.",
                "An owned copper list refreshes BPLCON0, BPL1PT, and palette registers.",
                "DMACON disables OS DMA/copper before direct display setup, then enables bitplane, copper, and blitter DMA.",
                "Main loop waits for vblank before object update.",
                "BOBX/BOBY are clamped before destination pointer calculation.",
                "Masked cookie-cut blitter draw waits before programming registers.",
                "BLTSIZE is followed by a DMACONR blitter wait.",
                "CollisionState is set when the BOB overlaps the target rectangle.",
                "CollisionColor drives COLOR01 during collision and green drives COLOR01 otherwise.",
                "Left mouse button exits through the cleanup path."
            ],
            sourceProofs: [],
            emulatorCapture: .init(
                backend: "vAmiga",
                expectation: "motion-plus-register-trace",
                artifacts: [
                    "bootable_adf",
                    "adf_inspection_json",
                    "boot_state_register_trace",
                    "raw_frame",
                    "frame_analysis_json",
                    "retroshell_transcript",
                    "template_runtime_evidence_json",
                    "manifest_json"
                ],
                minimumFrames: 2
            )
        )

        var result = AmigaRuntimeEvidenceValidationResult(manifest: manifest, failures: [])
        let sourceFailures = AmigaProgramSourceVerifier.failures(in: source)
        if !sourceFailures.isEmpty {
            result.failures.append("source verifier failed: \(sourceFailures.joined(separator: "; "))")
        }

        let semantic = AssemblySemanticValidator.validate(source: source, prompt: prompt)
        if !semantic.passed {
            result.failures.append("semantic verifier failed: \(semantic.summary)")
        }

        let index = AmigaSourceIndexer.index(source)
        if index.model?.id != AmigaProgramTemplate.blitterBOBCollisionBoundsID {
            result.failures.append("missing blitter BOB runtime model identity")
        } else {
            result.manifest.sourceProofs.append("embedded_model:\(AmigaProgramTemplate.blitterBOBCollisionBoundsID)")
        }

        appendProof("bitplane_pointer_setup", pattern: #"(?i)move\.l\s+a0\s*,\s*\$e0\s*\(\s*a6\s*\)"#, source: source, result: &result)
        appendProof("low_res_bitplane_mode", pattern: #"(?i)move\.w\s+#\$1200\s*,\s*\$100\s*\(\s*a6\s*\)"#, source: source, result: &result)
        appendProof("hardware_takeover_dmacon_clear", pattern: #"(?i)move\.w\s+#\$7fff\s*,\s*\$96\s*\(\s*a6\s*\)"#, source: source, result: &result)
        appendProof("interrupts_disabled_for_hardware_frame", pattern: #"(?i)move\.w\s+#\$7fff\s*,\s*\$9a\s*\(\s*a6\s*\)"#, source: source, result: &result)
        appendProof("copper_list_installed", pattern: #"(?is)lea\s+CopperList\s*,\s*a0.*move\.l\s+a0\s*,\s*\$80\s*\(\s*a6\s*\).*move\.w\s+#\$0000\s*,\s*\$88\s*\(\s*a6\s*\)"#, source: source, result: &result)
        appendProof("owned_copper_palette_and_bitplane", pattern: #"(?is)CopperList\s*:.*\$0100\s*,\s*\$1200.*CopperBplHi\s*:.*CopperBplLo\s*:.*\$0182\s*,\s*\$00f0"#, source: source, result: &result)
        appendProof("bitplane_copper_and_blitter_dma_enable", pattern: #"(?i)move\.w\s+#\$83c0\s*,\s*\$96\s*\(\s*a6\s*\)"#, source: source, result: &result)
        appendProof("left_mouse_exit", pattern: #"(?i)btst\s+#6\s*,\s*\$bfe001"#, source: source, result: &result)
        appendProof("vblank_wait_routine", pattern: #"(?im)^WaitVBlank\s*:"#, source: source, result: &result)
        appendProof("vblank_before_update", pattern: #"(?is)bsr\s+WaitVBlank.*bsr\s+UpdateBOBPosition.*bsr\s+CheckCollision.*bsr\s+DrawBOB"#, source: source, result: &result)
        appendProof("horizontal_bounds_clamp", pattern: #"(?is)cmp\.w\s+#16\s*,\s*d0.*cmp\.w\s+#288\s*,\s*d0.*neg\.w\s+BOBDX"#, source: source, result: &result)
        appendProof("vertical_bounds_clamp", pattern: #"(?is)cmp\.w\s+#32\s*,\s*d1.*cmp\.w\s+#176\s*,\s*d1.*neg\.w\s+BOBDY"#, source: source, result: &result)
        appendProof("masked_cookie_cut_blit", pattern: #"(?is)lea\s+BOBMask\s*,\s*a0.*lea\s+BOBImage\s*,\s*a1.*move\.w\s+#\$0fca\s*,\s*\$40\s*\(\s*a6\s*\)"#, source: source, result: &result)
        appendProof("pre_blit_wait_call", pattern: #"(?ims)^DrawBOB\s*:.*bsr\s+WaitBlitter.*move\.w\s+#\$0fca\s*,\s*\$40\s*\(\s*a6\s*\)"#, source: source, result: &result)
        appendProof("post_bltsize_wait", pattern: #"(?is)move\.w\s+#\(16\*64\)\+1\s*,\s*\$58\s*\(\s*a6\s*\).*\.waitAfter\s*:.*btst\s+#6\s*,\s*\$02\s*\(\s*a6\s*\)"#, source: source, result: &result)
        appendProof("collision_state_set", pattern: #"(?i)move\.w\s+#1\s*,\s*CollisionState"#, source: source, result: &result)
        appendProof("collision_color_output", pattern: #"(?i)move\.w\s+CollisionColor\s*\(\s*pc\s*\)\s*,\s*\$182\s*\(\s*a6\s*\)"#, source: source, result: &result)
        appendProof("non_collision_color_output", pattern: #"(?i)move\.w\s+#\$0f0\s*,\s*\$182\s*\(\s*a6\s*\)"#, source: source, result: &result)

        return result
    }

    static func validateCopperRuntimeRaster(source: String, prompt: String) -> AmigaRuntimeEvidenceValidationResult {
        let templateID = "bouncing-copper-bars"
        let manifest = AmigaRuntimeEvidenceManifest(
            schemaVersion: 1,
            familyID: "copper_runtime_raster_validation",
            templateID: templateID,
            observationKind: "vblank-paced-animated-copper-raster-bars",
            expectedSignals: [
                "Booted frame is not Workbench/AmigaDOS placeholder.",
                "An owned copper list is installed through COP1LC and activated through COPJMP1.",
                "Copper DMA is enabled through DMACON.",
                "Copper WAIT words create at least six visible raster color bands.",
                "The main loop waits for vblank before patching copper WAIT y positions.",
                "Animated state rewrites Bar1Wait through Bar6Wait.",
                "Distinct COLOR00 words make frame/raster evidence visible.",
                "Left mouse button exits through the cleanup path."
            ],
            sourceProofs: [],
            emulatorCapture: .init(
                backend: "vAmiga",
                expectation: "motion-plus-register-trace",
                artifacts: [
                    "bootable_adf",
                    "adf_inspection_json",
                    "boot_state_register_trace",
                    "raw_frame",
                    "frame_analysis_json",
                    "retroshell_transcript",
                    "template_runtime_evidence_json",
                    "manifest_json"
                ],
                minimumFrames: 2
            )
        )

        var result = AmigaRuntimeEvidenceValidationResult(manifest: manifest, failures: [])
        let sourceFailures = AmigaProgramSourceVerifier.failures(in: source)
        if !sourceFailures.isEmpty {
            result.failures.append("source verifier failed: \(sourceFailures.joined(separator: "; "))")
        }

        let semantic = AssemblySemanticValidator.validate(source: source, prompt: prompt)
        if !semantic.passed {
            result.failures.append("semantic verifier failed: \(semantic.summary)")
        }

        let indexedModel = AmigaSourceIndexer.index(source).model
        if let match = AssistantPromptTemplate.match(for: prompt), match.id == templateID, match.source == source {
            result.manifest.sourceProofs.append("template_match:\(templateID)")
        } else if indexedModel?.id == templateID {
            result.manifest.sourceProofs.append("model_identity:\(templateID)")
        } else {
            result.failures.append("missing bouncing copper bars template identity")
        }

        appendProof("owned_copper_list_installed", pattern: #"(?is)lea\s+CopperList\s*\(\s*pc\s*\)\s*,\s*a0.*move\.l\s+a0\s*,\s*\$80\s*\(\s*a6\s*\).*move\.w\s+#\$0000\s*,\s*\$88\s*\(\s*a6\s*\)"#, source: source, result: &result)
        appendProof("copper_dma_enable", pattern: #"(?i)move\.w\s+#\$8280\s*,\s*\$96\s*\(\s*a6\s*\)"#, source: source, result: &result)
        appendProof("vblank_paced_copper_patch", pattern: #"(?is)bsr(?:\.\w+)?\s+WaitVBlank.*move\.b\s+d2\s*,\s*Bar1Wait.*move\.b\s+d2\s*,\s*Bar6Wait"#, source: source, result: &result)
        appendProof("six_copper_wait_bands", pattern: #"(?is)Bar1Wait\s*:.*Bar2Wait\s*:.*Bar3Wait\s*:.*Bar4Wait\s*:.*Bar5Wait\s*:.*Bar6Wait\s*:"#, source: source, result: &result)
        appendProof("distinct_raster_colors", pattern: #"(?is)\$0180\s*,\s*\$0f00.*\$0180\s*,\s*\$0ff0.*\$0180\s*,\s*\$00f0.*\$0180\s*,\s*\$00ff.*\$0180\s*,\s*\$000f.*\$0180\s*,\s*\$0f0f"#, source: source, result: &result)
        appendCopperModelPaletteProof(indexedModel, result: &result)
        appendProof("wait_table_end_marker", pattern: #"(?i)dc\.w\s+\$ffff\s*,\s*\$fffe"#, source: source, result: &result)
        appendProof("left_mouse_exit", pattern: #"(?i)btst\s+#6\s*,\s*\$bfe001"#, source: source, result: &result)

        return result
    }

    static func validateMouseSpriteMultiplex(source: String, prompt: String) -> AmigaRuntimeEvidenceValidationResult {
        let templateID = "mouse-sprite-multiplex"
        let manifest = AmigaRuntimeEvidenceManifest(
            schemaVersion: 1,
            familyID: "mouse_sprite_multiplex",
            templateID: templateID,
            observationKind: "vblank-paced-mouse-controlled-dual-sprite-copy",
            expectedSignals: [
                "Booted frame is not Workbench/AmigaDOS placeholder.",
                "Embedded model declares sprite, CIA, copper, and bitplane/display hardware ownership.",
                "SPR0PT points at the primary mouse-controlled sprite.",
                "SPR1PT points at a second offset sprite copy.",
                "JOY0DAT deltas update bounded MouseX and MouseY state.",
                "WaitVBlank paces sprite control-byte rewrites.",
                "BPL1PT points at a visible backdrop bitplane.",
                "Sprite DMA, bitplane DMA, and copper DMA are enabled together.",
                "Both sprite data records terminate with zero control words.",
                "Left mouse button exits after the startup grace period."
            ],
            sourceProofs: [],
            emulatorCapture: .init(
                backend: "vAmiga",
                expectation: "motion-plus-register-trace",
                artifacts: [
                    "bootable_adf",
                    "adf_inspection_json",
                    "boot_state_register_trace",
                    "raw_frame",
                    "frame_analysis_json",
                    "retroshell_transcript",
                    "template_runtime_evidence_json",
                    "manifest_json"
                ],
                minimumFrames: 2
            )
        )

        var result = AmigaRuntimeEvidenceValidationResult(manifest: manifest, failures: [])
        let sourceFailures = AmigaProgramSourceVerifier.failures(in: source)
        if !sourceFailures.isEmpty {
            result.failures.append("source verifier failed: \(sourceFailures.joined(separator: "; "))")
        }

        let semantic = AssemblySemanticValidator.validate(source: source, prompt: prompt)
        if !semantic.passed {
            result.failures.append("semantic verifier failed: \(semantic.summary)")
        }

        let index = AmigaSourceIndexer.index(source)
        if index.model?.id != templateID {
            result.failures.append("missing mouse sprite multiplex runtime model identity")
        } else {
            result.manifest.sourceProofs.append("embedded_model:\(templateID)")
        }

        appendProof("spr0_pointer_write", pattern: #"(?i)move\.l\s+a0\s*,\s*\$120\s*\(\s*a6\s*\)"#, source: source, result: &result)
        appendProof("spr1_pointer_write", pattern: #"(?i)move\.l\s+a0\s*,\s*\$124\s*\(\s*a6\s*\)"#, source: source, result: &result)
        appendProof("bitplane_pointer_setup", pattern: #"(?i)move\.l\s+a0\s*,\s*\$e0\s*\(\s*a6\s*\)"#, source: source, result: &result)
        appendProof("visible_backdrop_bitplane_data", pattern: #"(?is)BackdropBitplane\s*:.*dcb\.l\s+2560\s*,\s*\$55555555"#, source: source, result: &result)
        appendProof("sprite_bitplane_copper_dma_enable", pattern: #"(?i)move\.w\s+#\$83a0\s*,\s*\$96\s*\(\s*a6\s*\)"#, source: source, result: &result)
        appendProof("joy0dat_mouse_sampling", pattern: #"(?i)move\.w\s+\$0a\s*\(\s*a6\s*\)\s*,\s*d0"#, source: source, result: &result)
        appendProof("mouse_state_updates", pattern: #"(?is)ReadMouseSprite\s*:.*move\.w\s+d2\s*,\s*MouseX.*move\.w\s+d2\s*,\s*MouseY"#, source: source, result: &result)
        appendProof("vblank_before_sprite_update", pattern: #"(?is)bsr(?:\.\w+)?\s+WaitVBlank.*bsr(?:\.\w+)?\s+ReadMouseSprite.*bsr(?:\.\w+)?\s+UpdateSprites"#, source: source, result: &result)
        appendProof("primary_sprite_control_update", pattern: #"(?is)UpdateSprites\s*:.*move\.b\s+d0\s*,\s*Sprite0VStart.*move\.b\s+d0\s*,\s*Sprite0VStop.*move\.b\s+d1\s*,\s*Sprite0HStart"#, source: source, result: &result)
        appendProof("multiplexed_sprite_control_update", pattern: #"(?is)UpdateSprites\s*:.*move\.b\s+d0\s*,\s*Sprite1VStart.*move\.b\s+d0\s*,\s*Sprite1VStop.*move\.b\s+d1\s*,\s*Sprite1HStart"#, source: source, result: &result)
        appendProof("sprite_data_terminators", pattern: #"(?is)SpriteData0\s*:.*\$0000\s*,\s*\$0000.*SpriteData1\s*:.*\$0000\s*,\s*\$0000"#, source: source, result: &result)
        appendProof("left_mouse_exit", pattern: #"(?i)btst\s+#6\s*,\s*\$bfe001"#, source: source, result: &result)

        return result
    }

    static func validateCleanTakeoverRestore(source: String, prompt: String) -> AmigaRuntimeEvidenceValidationResult {
        let templateID = AmigaProgramTemplate.cleanTakeoverRestoreID
        let manifest = AmigaRuntimeEvidenceManifest(
            schemaVersion: 1,
            familyID: "clean_takeover_restore",
            templateID: templateID,
            observationKind: "vblank-paced-clean-takeover-with-full-system-restore",
            expectedSignals: [
                "Booted frame is not Workbench/AmigaDOS placeholder.",
                "Embedded model declares saved view, DMA, interrupt, copper, palette, and restore-control state.",
                "graphics.library is opened before LoadView(NULL) and closed after LoadView(oldView).",
                "OldView, OldDMACON, OldINTENA, OldCOP1LC, and OldColor00 are saved before hardware takeover.",
                "Inherited INTREQ, INTENA, and DMACON state are cleared before the owned copper list is installed.",
                "An owned copper list is installed through COP1LC and activated through COPJMP1.",
                "Copper DMA is enabled through DMACON for visible runtime color evidence.",
                "The main loop checks restore input before the vblank-paced effect update.",
                "CycleColor updates COLOR00 through ColorTable.",
                "All user exits route through RestoreSystem before returning.",
                "RestoreSystem restores COLOR00, COP1LC, DMACON, INTENA, INTREQ, LoadView(oldView), and CloseLibrary."
            ],
            sourceProofs: [],
            emulatorCapture: .init(
                backend: "vAmiga",
                expectation: "motion-plus-register-trace",
                artifacts: [
                    "bootable_adf",
                    "adf_inspection_json",
                    "boot_state_register_trace",
                    "raw_frame",
                    "frame_analysis_json",
                    "retroshell_transcript",
                    "template_runtime_evidence_json",
                    "manifest_json"
                ],
                minimumFrames: 2
            )
        )

        var result = AmigaRuntimeEvidenceValidationResult(manifest: manifest, failures: [])
        let sourceFailures = AmigaProgramSourceVerifier.failures(in: source)
        if !sourceFailures.isEmpty {
            result.failures.append("source verifier failed: \(sourceFailures.joined(separator: "; "))")
        }

        let semantic = AssemblySemanticValidator.validate(source: source, prompt: prompt)
        if !semantic.passed {
            result.failures.append("semantic verifier failed: \(semantic.summary)")
        }

        let index = AmigaSourceIndexer.index(source)
        if index.model?.id != templateID {
            result.failures.append("missing clean takeover runtime model identity")
        } else {
            result.manifest.sourceProofs.append("embedded_model:\(templateID)")
        }

        appendProof("graphics_library_open", pattern: #"(?i)jsr\s+-408\s*\(\s*a6\s*\)\s*;\s*OpenLibrary\("graphics\.library"\)"#, source: source, result: &result)
        appendProof("loadview_null_takeover", pattern: #"(?i)jsr\s+-222\s*\(\s*a6\s*\)\s*;\s*LoadView\(NULL\)"#, source: source, result: &result)
        appendProof("waittof_settle_after_takeover", pattern: #"(?is)LoadView\(NULL\).*jsr\s+-270\s*\(\s*a6\s*\).*jsr\s+-270\s*\(\s*a6\s*\)"#, source: source, result: &result)
        appendProof("saved_old_view", pattern: #"(?i)move\.l\s+34\s*\(\s*a6\s*\)\s*,\s*OldView"#, source: source, result: &result)
        appendProof("saved_old_dmacon", pattern: #"(?i)move\.w\s+\$02\s*\(\s*a6\s*\)\s*,\s*OldDMACON"#, source: source, result: &result)
        appendProof("saved_old_intena", pattern: #"(?i)move\.w\s+\$1c\s*\(\s*a6\s*\)\s*,\s*OldINTENA"#, source: source, result: &result)
        appendProof("saved_old_cop1lc", pattern: #"(?is)move\.l\s+\$80\s*\(\s*a6\s*\)\s*,\s*d0.*move\.l\s+d0\s*,\s*OldCOP1LC"#, source: source, result: &result)
        appendProof("saved_old_color00", pattern: #"(?i)move\.w\s+\$180\s*\(\s*a6\s*\)\s*,\s*OldColor00"#, source: source, result: &result)
        appendProof("interrupt_and_dma_takeover_clear", pattern: #"(?is)move\.w\s+#\$7fff\s*,\s*\$9c\s*\(\s*a6\s*\).*move\.w\s+#\$7fff\s*,\s*\$9a\s*\(\s*a6\s*\).*move\.w\s+#\$7fff\s*,\s*\$96\s*\(\s*a6\s*\)"#, source: source, result: &result)
        appendProof("owned_copper_list_installed", pattern: #"(?is)lea\s+CopperList\s*\(\s*pc\s*\)\s*,\s*a0.*move\.l\s+a0\s*,\s*\$80\s*\(\s*a6\s*\).*move\.w\s+#0\s*,\s*\$88\s*\(\s*a6\s*\)"#, source: source, result: &result)
        appendProof("copper_dma_enable", pattern: #"(?i)move\.w\s+#\$8280\s*,\s*\$96\s*\(\s*a6\s*\)"#, source: source, result: &result)
        appendProof("restore_input_before_effect", pattern: #"(?ims)^\.main\s*:.*bsr\s+CheckRestoreInput.*bne\.s\s+\.restore.*bsr\s+WaitVBlank.*bsr\s+CycleColor"#, source: source, result: &result)
        appendProof("left_mouse_restore_request", pattern: #"(?is)CheckRestoreInput\s*:.*btst\s+#6\s*,\s*\$bfe001.*beq\.s\s+\.restoreRequested"#, source: source, result: &result)
        appendProof("all_exits_call_restore_system", pattern: #"(?ims)^\.restore\s*:.*bsr\s+RestoreSystem.*^\.exit\s*:"#, source: source, result: &result)
        appendProof("vblank_wait_routine", pattern: #"(?is)WaitVBlank\s*:.*\$06\s*\(\s*a6\s*\).*\.leaveVBlank"#, source: source, result: &result)
        appendProof("color_cycle_output", pattern: #"(?is)CycleColor\s*:.*lea\s+ColorTable\s*\(\s*pc\s*\)\s*,\s*a0.*move\.w\s+\(a0,d0\.w\)\s*,\s*\$180\s*\(\s*a6\s*\)"#, source: source, result: &result)
        appendProof("color_table_visible_values", pattern: #"(?i)ColorTable\s*:\s*dc\.w\s+\$[0-9a-f]{4}\s*,\s*\$[0-9a-f]{4}\s*,\s*\$[0-9a-f]{4}\s*,\s*\$[0-9a-f]{4}"#, source: source, result: &result)
        appendProof("restore_color00", pattern: #"(?i)move\.w\s+OldColor00\s*\(\s*pc\s*\)\s*,\s*\$180\s*\(\s*a6\s*\)"#, source: source, result: &result)
        appendProof("restore_cop1lc", pattern: #"(?is)move\.l\s+OldCOP1LC\s*\(\s*pc\s*\)\s*,\s*d0.*move\.l\s+d0\s*,\s*\$80\s*\(\s*a6\s*\)"#, source: source, result: &result)
        appendProof("restore_dmacon", pattern: #"(?is)move\.w\s+OldDMACON\s*\(\s*pc\s*\)\s*,\s*d0.*or\.w\s+#\$8000\s*,\s*d0.*move\.w\s+d0\s*,\s*\$96\s*\(\s*a6\s*\)"#, source: source, result: &result)
        appendProof("restore_intena", pattern: #"(?is)move\.w\s+OldINTENA\s*\(\s*pc\s*\)\s*,\s*d0.*or\.w\s+#\$8000\s*,\s*d0.*move\.w\s+d0\s*,\s*\$9a\s*\(\s*a6\s*\)"#, source: source, result: &result)
        appendProof("restore_intreq_ack", pattern: #"(?i)move\.w\s+#\$7fff\s*,\s*\$9c\s*\(\s*a6\s*\)"#, source: source, result: &result)
        appendProof("loadview_oldview_restore", pattern: #"(?is)move\.l\s+OldView\s*\(\s*pc\s*\)\s*,\s*a1.*jsr\s+-222\s*\(\s*a6\s*\)\s*;\s*LoadView\(oldView\)"#, source: source, result: &result)
        appendProof("close_graphics_library", pattern: #"(?i)jsr\s+-414\s*\(\s*a6\s*\)"#, source: source, result: &result)

        return result
    }

    static func validateIntuitionWindowTool(source: String, prompt: String) -> AmigaRuntimeEvidenceValidationResult {
        let templateID = AmigaProgramTemplate.intuitionWindowToolID
        let manifest = AmigaRuntimeEvidenceManifest(
            schemaVersion: 1,
            familyID: "intuition_window_tool",
            templateID: templateID,
            observationKind: "system-friendly-intuition-window-with-balanced-cleanup",
            expectedSignals: [
                "Boot reaches an AmigaOS-friendly executable path without custom-chip takeover.",
                "Embedded model declares Intuition and Exec dependencies plus WindowPtr and IntuitionBase state.",
                "OpenLibrary(\"intuition.library\") and CloseLibrary(IntuitionBase) are balanced.",
                "OpenWindow(&NewWindow) and CloseWindow(WindowPtr) are balanced.",
                "OpenLibrary failure exits without attempting window cleanup.",
                "OpenWindow failure routes to CloseLibraryOnly.",
                "WaitPort/GetMsg/ReplyMsg drive the Intuition event loop.",
                "IDCMP_CLOSEWINDOW branches to CleanupAndExit.",
                "IDCMP_GADGETUP branches to InputDispatch.",
                "Modeled gadgets have Gadget records, IntuiText labels, and dispatch branches.",
                "Cleanup closes the window before closing intuition.library."
            ],
            sourceProofs: [],
            emulatorCapture: .init(
                backend: "vAmiga",
                expectation: "system-resource-trace",
                artifacts: [
                    "bootable_adf",
                    "adf_inspection_json",
                    "boot_state_register_trace",
                    "raw_frame",
                    "retroshell_transcript",
                    "template_runtime_evidence_json",
                    "manifest_json"
                ],
                minimumFrames: 1
            )
        )

        var result = AmigaRuntimeEvidenceValidationResult(manifest: manifest, failures: [])
        let sourceFailures = AmigaProgramSourceVerifier.failures(in: source)
        if !sourceFailures.isEmpty {
            result.failures.append("source verifier failed: \(sourceFailures.joined(separator: "; "))")
        }

        let semantic = AssemblySemanticValidator.validate(source: source, prompt: prompt)
        if !semantic.passed {
            result.failures.append("semantic verifier failed: \(semantic.summary)")
        }

        let index = AmigaSourceIndexer.index(source)
        if index.model?.id != templateID {
            result.failures.append("missing Intuition runtime model identity")
        } else {
            result.manifest.sourceProofs.append("embedded_model:\(templateID)")
        }

        appendProof("intuition_library_name", pattern: #"(?i)"intuition\.library""#, source: source, result: &result)
        appendProof("intuition_openlibrary", pattern: #"(?i)jsr\s+-552\s*\(\s*a6\s*\)\s*;\s*OpenLibrary\("intuition\.library"\)"#, source: source, result: &result)
        appendProof("intuition_base_saved", pattern: #"(?i)move\.l\s+d0\s*,\s*IntuitionBase"#, source: source, result: &result)
        appendProof("openlibrary_failure_exits", pattern: #"(?is)jsr\s+-552\s*\(\s*a6\s*\).*move\.l\s+d0\s*,\s*IntuitionBase.*beq\s+ProgramExit"#, source: source, result: &result)
        appendProof("openwindow_call", pattern: #"(?i)jsr\s+-204\s*\(\s*a6\s*\)\s*;\s*OpenWindow\(&NewWindow\)"#, source: source, result: &result)
        appendProof("window_pointer_saved", pattern: #"(?i)move\.l\s+d0\s*,\s*WindowPtr"#, source: source, result: &result)
        appendProof("openwindow_failure_closes_library", pattern: #"(?is)jsr\s+-204\s*\(\s*a6\s*\).*move\.l\s+d0\s*,\s*WindowPtr.*beq\s+CloseLibraryOnly"#, source: source, result: &result)
        appendProof("waitport_event_wait", pattern: #"(?i)jsr\s+-384\s*\(\s*a6\s*\)\s*;\s*WaitPort\(UserPort\)"#, source: source, result: &result)
        appendProof("getmsg_event_read", pattern: #"(?i)jsr\s+-372\s*\(\s*a6\s*\)\s*;\s*GetMsg\(UserPort\)"#, source: source, result: &result)
        appendProof("replymsg_event_release", pattern: #"(?i)jsr\s+-378\s*\(\s*a6\s*\)\s*;\s*ReplyMsg\(message\)"#, source: source, result: &result)
        appendProof("closewindow_event_cleanup_branch", pattern: #"(?is)cmp\.l\s+#IDCMP_CLOSEWINDOW\s*,\s*d2.*beq\s+CleanupAndExit"#, source: source, result: &result)
        appendProof("gadgetup_dispatch_branch", pattern: #"(?is)cmp\.l\s+#IDCMP_GADGETUP\s*,\s*d2.*beq\s+InputDispatch"#, source: source, result: &result)
        appendProof("closewindow_before_closelibrary", pattern: #"(?is)CleanupAndExit\s*:.*jsr\s+-72\s*\(\s*a6\s*\)\s*;\s*CloseWindow\(WindowPtr\).*CloseLibraryOnly\s*:.*jsr\s+-414\s*\(\s*a6\s*\)\s*;\s*CloseLibrary\(IntuitionBase\)"#, source: source, result: &result)
        appendProof("window_pointer_cleared_after_close", pattern: #"(?is)jsr\s+-72\s*\(\s*a6\s*\)\s*;\s*CloseWindow\(WindowPtr\).*clr\.l\s+WindowPtr"#, source: source, result: &result)
        appendProof("intuition_base_cleared_after_close", pattern: #"(?is)jsr\s+-414\s*\(\s*a6\s*\)\s*;\s*CloseLibrary\(IntuitionBase\).*clr\.l\s+IntuitionBase"#, source: source, result: &result)
        appendProof("newwindow_declares_close_and_gadget_idcmp", pattern: #"(?is)NewWindow\s*:.*dc\.l\s+IDCMP_CLOSEWINDOW\+IDCMP_GADGETUP"#, source: source, result: &result)
        appendProof("modeled_play_gadget_data", pattern: #"(?is)Gadget_play\s*:.*Text_play\s*:.*Label_play\s*:.*dc\.b\s+"[^"]+""#, source: source, result: &result)
        appendProof("modeled_stop_gadget_data", pattern: #"(?is)Gadget_stop\s*:.*Text_stop\s*:.*Label_stop\s*:.*dc\.b\s+"[^"]+""#, source: source, result: &result)
        appendProof("play_gadget_dispatch", pattern: #"(?is)@amiga:dispatch\s+play\s+->\s+PlayAction.*cmp\.l\s+#Gadget_play\s*,\s*a2.*bsr\s+PlayAction"#, source: source, result: &result)
        appendProof("stop_gadget_dispatch", pattern: #"(?is)@amiga:dispatch\s+stop\s+->\s+StopAction.*cmp\.l\s+#Gadget_stop\s*,\s*a2.*bsr\s+StopAction"#, source: source, result: &result)

        return result
    }

    static func manifestJSON(_ manifest: AmigaRuntimeEvidenceManifest) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(manifest)
        return String(data: data, encoding: .utf8) ?? "{}"
    }

    private static func appendProof(
        _ proof: String,
        pattern: String,
        source: String,
        result: inout AmigaRuntimeEvidenceValidationResult
    ) {
        if contains(pattern: pattern, in: source) {
            result.manifest.sourceProofs.append(proof)
        } else {
            result.failures.append("missing runtime source proof: \(proof)")
        }
    }

    private static func appendCopperModelPaletteProof(
        _ model: AmigaProgramModel?,
        result: inout AmigaRuntimeEvidenceValidationResult
    ) {
        guard let model else {
            result.failures.append("missing runtime source proof: distinct_model_palette")
            return
        }

        let visibleColors = model.stateVariables
            .filter { $0.id.hasPrefix("band_color_") }
            .compactMap(\.initialValue)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .filter { $0 != "$0000" && $0 != "0" }
        guard Set(visibleColors).count >= 2 else {
            result.failures.append("runtime frame lacks expected colored raster bands: model palette has fewer than two visible colors")
            return
        }
        result.manifest.sourceProofs.append("distinct_model_palette")
    }

    private static func contains(pattern: String, in source: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return false
        }
        let range = NSRange(source.startIndex..<source.endIndex, in: source)
        return regex.firstMatch(in: source, range: range) != nil
    }
}
