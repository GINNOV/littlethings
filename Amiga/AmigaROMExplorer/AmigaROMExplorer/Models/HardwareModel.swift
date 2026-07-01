import Foundation

struct HardwareModel: Identifiable, Hashable, Codable, Sendable {
    let id: String
    let name: String
    let codename: String?
    let releaseYear: Int?
    let cpu: String
    let chipset: String
    let summary: String
    let symbolName: String

    static let catalog: [HardwareModel] = [
        HardwareModel(
            id: "a1000",
            name: "Amiga 1000",
            codename: "Lorraine",
            releaseYear: 1985,
            cpu: "Motorola 68000 @ 7.16 MHz",
            chipset: "OCS (Original Chip Set)",
            summary: "Commodore's first Amiga. Kickstart loads from floppy; a separate WCS bootstrap ROM brings the machine up.",
            symbolName: "desktopcomputer"
        ),
        HardwareModel(
            id: "a500",
            name: "Amiga 500",
            codename: nil,
            releaseYear: 1987,
            cpu: "Motorola 68000 @ 7.16 MHz",
            chipset: "OCS",
            summary: "The iconic home Amiga. Kickstart 1.2/1.3 in ROM made it instantly ready to run games and Workbench.",
            symbolName: "keyboard"
        ),
        HardwareModel(
            id: "a500plus",
            name: "Amiga 500 Plus",
            codename: nil,
            releaseYear: 1992,
            cpu: "Motorola 68000 @ 7.16 MHz",
            chipset: "ECS",
            summary: "ECS refresh of the A500 with 1 MB Chip RAM and Kickstart 2.04.",
            symbolName: "keyboard"
        ),
        HardwareModel(
            id: "a600",
            name: "Amiga 600",
            codename: nil,
            releaseYear: 1992,
            cpu: "Motorola 68000 @ 7.16 MHz",
            chipset: "ECS",
            summary: "Compact ECS machine with PCMCIA and optional internal IDE.",
            symbolName: "rectangle.compress.vertical"
        ),
        HardwareModel(
            id: "a600hd",
            name: "Amiga 600 HD",
            codename: nil,
            releaseYear: 1992,
            cpu: "Motorola 68000 @ 7.16 MHz",
            chipset: "ECS",
            summary: "A600 bundle with internal hard drive and Kickstart 2.05 tuned for HD setups.",
            symbolName: "internaldrive"
        ),
        HardwareModel(
            id: "a1200",
            name: "Amiga 1200",
            codename: nil,
            releaseYear: 1992,
            cpu: "Motorola 68EC020 @ 14.32 MHz",
            chipset: "AGA",
            summary: "Advanced Graphics Architecture in an all-in-one wedge. Kickstart 3.0/3.1 era flagship home machine.",
            symbolName: "sparkles.rectangle.stack"
        ),
        HardwareModel(
            id: "a2000",
            name: "Amiga 2000",
            codename: nil,
            releaseYear: 1987,
            cpu: "Motorola 68000 @ 7.16 MHz",
            chipset: "OCS / ECS",
            summary: "Expandable desktop tower with Zorro slots. Popular in video and productivity.",
            symbolName: "pc"
        ),
        HardwareModel(
            id: "a3000",
            name: "Amiga 3000",
            codename: nil,
            releaseYear: 1990,
            cpu: "Motorola 68030 @ 16–25 MHz",
            chipset: "ECS",
            summary: "Professional workstation with separate boot ROMs and SuperKickstart support.",
            symbolName: "server.rack"
        ),
        HardwareModel(
            id: "a4000",
            name: "Amiga 4000",
            codename: nil,
            releaseYear: 1992,
            cpu: "Motorola 68030/68040",
            chipset: "AGA",
            summary: "High-end tower/desktop with AGA and Kickstart 3.1.",
            symbolName: "externaldrive"
        ),
        HardwareModel(
            id: "a4000t",
            name: "Amiga 4000T",
            codename: nil,
            releaseYear: 1994,
            cpu: "Motorola 68040",
            chipset: "AGA",
            summary: "Big-box tower variant of the A4000 line with room for serious expansion.",
            symbolName: "shippingbox"
        ),
        HardwareModel(
            id: "cdtv",
            name: "Commodore CDTV",
            codename: nil,
            releaseYear: 1991,
            cpu: "Motorola 68000 @ 7.16 MHz",
            chipset: "OCS + CD-ROM",
            summary: "Living-room CD multimedia console based on Amiga architecture with extended ROM.",
            symbolName: "tv"
        ),
        HardwareModel(
            id: "cd32",
            name: "Amiga CD32",
            codename: nil,
            releaseYear: 1993,
            cpu: "Motorola 68EC020 @ 14.32 MHz",
            chipset: "AGA + CD-ROM",
            summary: "World's first 32-bit CD games console. Uses Kickstart 3.1 plus CD32 extended ROM.",
            symbolName: "gamecontroller"
        ),
        HardwareModel(
            id: "a570",
            name: "A570 CD-ROM",
            codename: nil,
            releaseYear: 1992,
            cpu: "Motorola 68000 (host A500)",
            chipset: "OCS + CD-ROM",
            summary: "External CD-ROM for A500-class machines with CDTV extended ROM support.",
            symbolName: "opticaldiscdrive"
        )
    ]

    static func resolve(from tokens: [String]) -> [HardwareModel] {
        var seen = Set<String>()
        var models: [HardwareModel] = []

        for token in tokens {
            let key = token.lowercased()
            if let model = catalog.first(where: { $0.id == key }), seen.insert(model.id).inserted {
                models.append(model)
            }
        }

        if models.isEmpty, let inferred = inferFromCompound(tokens.joined(separator: "-")) {
            models = inferred
        }

        return models
    }

    private static func inferFromCompound(_ compound: String) -> [HardwareModel]? {
        let matches = catalog.filter { compound.contains($0.id) }
        return matches.isEmpty ? nil : matches
    }
}