import Foundation

enum ROMKnowledgeBase {
    static func baselineResearch(for item: ROMCatalogItem) -> ROMResearch {
        let profile = profile(for: item)
        return ROMResearch(
            romID: item.id,
            title: item.displayTitle,
            summary: profile.summary,
            contentsDescription: profile.contents,
            purpose: profile.purpose,
            hardwareIDs: item.parsed.hardwareTokens,
            history: profile.history,
            technicalInsights: profile.insights,
            notableLibraries: profile.libraries,
            compatibilityNotes: profile.compatibility,
            researchSource: .knowledgeBase,
            researchedAt: Date()
        )
    }

    private struct Profile {
        let summary: String
        let contents: String
        let purpose: String
        let history: String
        let insights: [String]
        let libraries: [String]
        let compatibility: String
    }

    private static func profile(for item: ROMCatalogItem) -> Profile {
        switch item.category {
        case .kickstart:
            return kickstartProfile(for: item)
        case .extendedROM:
            return extendedROMProfile(for: item)
        case .bootROM:
            return bootROMProfile(for: item)
        case .bootstrap:
            return bootstrapProfile(for: item)
        case .cartridges:
            return cartridgeProfile(for: item)
        case .other:
            return genericProfile(for: item)
        }
    }

    private static func kickstartProfile(for item: ROMCatalogItem) -> Profile {
        let version = item.versionLabel.lowercased()
        let machines = item.machines.map(\.name).joined(separator: ", ")
        let era = kickstartEra(version: version)

        return Profile(
            summary: "Kickstart is the Amiga's resident operating system firmware. This \(item.parsed.dumpQuality.label.lowercased()) image targets \(machines.isEmpty ? "Amiga hardware" : machines) and provides the Exec kernel, device drivers, Intuition GUI, and DOS library needed to boot Workbench or games.",
            contents: era.contents,
            purpose: "Stored in ROM (or loaded from disk on early A1000 setups), Kickstart initializes custom chips, brings up Chip RAM, installs core libraries, and hands control to boot media or the Workbench desktop.",
            history: era.history,
            insights: era.insights + dumpInsights(for: item),
            libraries: era.libraries,
            compatibility: "Emulators and real hardware require a legally obtained ROM matching the target machine. \(item.parsed.dumpQuality == .good ? "This verified-good dump is suitable for archival emulation." : "Non-good variants may be useful for preservation study but can behave differently in emulators.")"
        )
    }

    private static func extendedROMProfile(for item: ROMCatalogItem) -> Profile {
        let isCD32 = item.manifest.destination.contains("cd32")
        let isCDTV = item.manifest.destination.contains("cdtv")
        let isA570 = item.manifest.destination.contains("a570")

        let target: String
        if isCD32 { target = "Amiga CD32" }
        else if isCDTV { target = "Commodore CDTV" }
        else if isA570 { target = "A570 CD-ROM expansion" }
        else { target = "CD-capable Amiga systems" }

        return Profile(
            summary: "Extended ROM firmware for \(target). Adds CD filesystem support, audio/CD streaming helpers, and boot logic beyond standard Kickstart.",
            contents: "Contains CD32/CDTV-specific boot code, ISO9660 filesystem support, audio drivers, and often additional icon/tool resources. Works in tandem with a compatible Kickstart ROM.",
            purpose: "Enables CD-based boot, audio CD playback, and console-style startup on CDTV/CD32, or CD-ROM expansion on A500-class machines.",
            history: "Commodore shipped CDTV in 1991 as a living-room Amiga, followed by the A570 expansion and the CD32 console in 1993. Each platform needed extra firmware beyond Kickstart to manage the CD subsystem.",
            insights: [
                "Extended ROM is mapped separately from Kickstart; emulators need both ROM sets configured.",
                "Revision numbers often track paired Kickstart releases (e.g. r40.60 for late CD32).",
                "Some dumps are socket-specific (U34/U35) reflecting physical ROM placement on the board."
            ],
            libraries: ["cdfilesystem.library", "lowlevel.library", "icon.library"],
            compatibility: "Pair with the Kickstart version used by the original hardware. Mismatched Kickstart/extended ROM pairs may fail CD boot."
        )
    }

    private static func bootROMProfile(for item: ROMCatalogItem) -> Profile {
        Profile(
            summary: "A3000 boot ROM providing early startup code before Kickstart takes over. The A3000 uses a two-stage boot process with separate ROM0 and ROM1 images.",
            contents: "Low-level diagnostics, memory sizing, SCSI/CPU setup, and handoff logic. Smaller than Kickstart and executed before the main OS ROM.",
            purpose: "Brings the A3000 hardware to a state where SuperKickstart or standard Kickstart can be loaded from ROM or disk.",
            history: "The Amiga 3000 (1990) introduced a more workstation-like boot path. Boot ROM v1.4 r36.16 is the canonical pair split across ROM0 and ROM1 sockets.",
            insights: [
                "ROM0 and ROM1 are not interchangeable; emulators must load both in correct order.",
                "Boot ROM works with A3000 SuperKickstart images for full OS features.",
                "Useful for studying how Commodore separated diagnostics from the main Kickstart payload."
            ],
            libraries: [],
            compatibility: "A3000 and A3000T only. Required in addition to the appropriate Kickstart/SuperKickstart image."
        )
    }

    private static func bootstrapProfile(for item: ROMCatalogItem) -> Profile {
        Profile(
            summary: "Amiga 1000 Write-Control Store (WCS) bootstrap. The A1000 does not have full Kickstart in ROM; instead this tiny loader pulls Kickstart from disk.",
            contents: "Minimal 68000 code that tests hardware, loads the Kickstart image from floppy into WCS/RAM, and transfers execution.",
            purpose: "Allows the A1000 to boot despite shipping before mask-programmed Kickstart ROMs were ready.",
            history: "When the Amiga 1000 launched in 1985, Kickstart was still evolving weekly. The bootstrap + floppy Kickstart workflow let Commodore update OS versions without replacing ROM chips.",
            insights: [
                "Only 256 bytes of battery-backed WCS are available for the bootstrap path.",
                "A1000 emulation requires both bootstrap ROM and a Kickstart disk image.",
                "Preservationists treat bootstrap dumps as essential for accurate A1000 recreation."
            ],
            libraries: [],
            compatibility: "Amiga 1000 only. Must be paired with a Kickstart 1.x disk image."
        )
    }

    private static func cartridgeProfile(for item: ROMCatalogItem) -> Profile {
        let name = item.manifest.destination.split(separator: "/").dropFirst().first.map(String.init) ?? "cartridge"
        let cartridge = cartridgeDetails(name: name, item: item)

        return Profile(
            summary: cartridge.summary,
            contents: cartridge.contents,
            purpose: cartridge.purpose,
            history: cartridge.history,
            insights: cartridge.insights + dumpInsights(for: item),
            libraries: cartridge.libraries,
            compatibility: cartridge.compatibility
        )
    }

    private static func genericProfile(for item: ROMCatalogItem) -> Profile {
        Profile(
            summary: "Amiga-related firmware image catalogued in your local manifest.",
            contents: "Binary ROM data. Inspect size and checksum to compare against known good dumps.",
            purpose: "Used by emulators or hardware that expect this specific ROM mapping.",
            history: "Listed in manifest as: \(item.manifest.source)",
            insights: dumpInsights(for: item),
            libraries: [],
            compatibility: "Verify against hardware documentation before use."
        )
    }

    private static func dumpInsights(for item: ROMCatalogItem) -> [String] {
        var insights: [String] = []
        if let info = item.fileInfo {
            insights.append("File size: \(ByteCountFormatter.string(fromByteCount: Int64(info.byteCount), countStyle: .file))")
            if let md5 = info.md5 {
                insights.append("MD5: \(md5)")
            }
        }
        insights.append("Manifest status: \(item.manifest.status.label)")
        if item.parsed.dumpQuality != .good {
            insights.append("Dump class: \(item.parsed.dumpQuality.label) — verify behavior before relying on it for production emulation.")
        }
        return insights
    }

    private static func kickstartEra(version: String) -> (contents: String, history: String, insights: [String], libraries: [String]) {
        if version.contains("0.7") || version.contains("1.0") || version.contains("1.1") {
            return (
                "Early Exec, minimal Intuition, floppy-based tooling. NTSC/PAL variants and frequent beta builds.",
                "1985–1986: Kickstart co-evolved with the Amiga 1000 and early developer machines. Versions were delivered on disk before ROM chips stabilized.",
                ["Very early builds may lack libraries present in Kickstart 1.2 and later, affecting game compatibility.", "NTSC vs PAL splits matter for video timing."],
                ["exec.library", "graphics.library", "dos.library"]
            )
        }
        if version.contains("1.2") || version.contains("1.3") {
            return (
                "Mature OCS Kickstart with stable Workbench 1.2/1.3, improved graphics/audio support, and broad game library compatibility.",
                "1986–1987: Kickstart 1.2/1.3 powered the Amiga 500 and became the gold standard for OCS gaming.",
                ["1.3 is the most requested ROM for WHDLoad and classic gaming.", "512 KB ROM size is standard for this generation."],
                ["exec.library", "graphics.library", "intuition.library", "dos.library", "icon.library"]
            )
        }
        if version.contains("2.0") || version.contains("2.02") || version.contains("2.03") || version.contains("2.04") || version.contains("2.05") {
            return (
                "ECS-era Kickstart with 2.x Workbench, improved color modes, and better hard drive support.",
                "1990–1992: ECS machines (A500+, A600, A3000) shipped with Kickstart 2.x. SuperKickstart images exist for A3000.",
                ["A500+ and A600 images are not always interchangeable.", "Developer and KickIt builds expose extra debug tooling."],
                ["exec.library", "graphics.library", "intuition.library", "dos.library", "workbench.library"]
            )
        }
        if version.contains("3.0") || version.contains("3.1") {
            return (
                "AGA-aware Kickstart with 3.x Workbench, CD32 support hooks, and improved system services.",
                "1992–1994: A1200, A4000, and CD32 era. Kickstart 3.1 (r40.x) is the final classic generation.",
                ["512 KB ROM for most 3.x images; some machines need exact revision (r40.068 for A1200).", "Beta and hack images document late Commodore engineering."],
                ["exec.library", "graphics.library", "intuition.library", "dos.library", "asl.library", "commodities.library"]
            )
        }
        return (
            "Standard Amiga Kickstart firmware containing Exec, drivers, and Intuition.",
            "Kickstart evolved from floppy-loaded prototypes to mask ROMs across the Amiga's commercial lifetime.",
            ["Match ROM revision to target hardware for accurate emulation."],
            ["exec.library", "graphics.library", "dos.library"]
        )
    }

    private static func cartridgeDetails(name: String, item: ROMCatalogItem) -> Profile {
        switch name {
        case "action-replay":
            return Profile(
                summary: "Datel Action Replay freezer/cartridge ROM. Provides memory monitor, disk copier, trainer tools, and early cheat features.",
                contents: "Menu-driven 68k code mapped into cartridge address space with hooks into Exec and DOS.",
                purpose: "Development, game backup, and memory inspection on connected Amiga models.",
                history: "Action Replay Mk I–III defined the commercial freezer market from 1989 through the early 1990s.",
                insights: ["Modified [m] dumps may include community patches.", "A1200-specific editions map to different physical connectors."],
                libraries: ["exec.library"],
                compatibility: "Must match host machine cartridge slot (A500/A600/A1200 variants differ)."
            )
        case "nordic-power":
            return Profile(
                summary: "Nordic Power expansion cartridge firmware by Data & Electronics.",
                contents: "Utility ROM with power-user tools and system enhancements.",
                purpose: "Adds convenience utilities and enhancements when the cartridge is inserted at boot.",
                history: "Popular in European Amiga scenes during 1989–1990.",
                insights: ["Less common than Action Replay but follows similar cartridge mapping rules."],
                libraries: [],
                compatibility: "Typically A500-class machines with side expansion slot."
            )
        case "x-power-professional-500":
            return Profile(
                summary: "X-Power Professional 500 cartridge ROM from Design & Engineering.",
                contents: "Professional utility firmware with system tools and enhancements.",
                purpose: "Productivity and power-user tooling for A500-series machines.",
                history: "Early 1990s third-party expansion competing in the utility cartridge space.",
                insights: ["Version bumps (v1.2 vs v1.3) reflect feature additions and bug fixes."],
                libraries: [],
                compatibility: "Designed for Amiga 500-class hardware."
            )
        case "action-cartridge-super-iv-pro":
            return Profile(
                summary: "GameWorks Action Cartridge Super IV Pro utility ROM.",
                contents: "Cartridge-resident tools and boot-time utilities.",
                purpose: "System enhancement and game-related tooling.",
                history: "Early 1990s third-party cartridge from GameWorks.",
                insights: ["Catalogued as a preservation reference in TOSEC naming."],
                libraries: [],
                compatibility: "Verify slot compatibility with target hardware."
            )
        default:
            return genericProfile(for: item)
        }
    }
}