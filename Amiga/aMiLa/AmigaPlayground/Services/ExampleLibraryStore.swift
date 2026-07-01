import Foundation

enum ExampleLanguage: String, CaseIterable, Codable, Identifiable {
    case assembly = "ASM"
    case c = "C"
    case mixed = "C + ASM"

    var id: String { rawValue }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        switch rawValue {
        case Self.assembly.rawValue:
            self = .assembly
        case Self.c.rawValue:
            self = .c
        case Self.mixed.rawValue, "ASM + C":
            self = .mixed
        default:
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported example language: \(rawValue)")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

struct ExampleLibraryItem: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var language: ExampleLanguage
    var code: String
    var metadata: DemoSchoolMetadata
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        language: ExampleLanguage,
        code: String,
        metadata: DemoSchoolMetadata = DemoSchoolMetadata(),
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.language = language
        self.code = code
        self.metadata = metadata
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, language, code, metadata, createdAt, updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        language = try container.decode(ExampleLanguage.self, forKey: .language)
        code = try container.decode(String.self, forKey: .code)
        metadata = try container.decodeIfPresent(DemoSchoolMetadata.self, forKey: .metadata) ?? DemoSchoolMetadata(language: language.rawValue)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }
}

extension Notification.Name {
    static let loadExampleIntoEditor = Notification.Name("loadExampleIntoEditor")
}

@MainActor
final class ExampleLibraryStore: ObservableObject {
    static let shared = ExampleLibraryStore()

    @Published private(set) var examples: [ExampleLibraryItem] = []

    private let userDefaults: UserDefaults
    private let storageKey = "exampleLibraryItems"
    private let defaultSeedVersionKey = "exampleLibraryDefaultSeedVersion"
    private let currentDefaultSeedVersion = 6

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        let storedExamples = Self.loadExamples(from: userDefaults, storageKey: storageKey)
        let seedVersion = userDefaults.integer(forKey: defaultSeedVersionKey)

        if seedVersion < currentDefaultSeedVersion {
            self.examples = Self.mergedDefaultExamples(with: storedExamples)
            save()
            userDefaults.set(currentDefaultSeedVersion, forKey: defaultSeedVersionKey)
        } else {
            self.examples = storedExamples
        }
    }

    func createExample() -> ExampleLibraryItem {
        let item = ExampleLibraryItem(
            name: uniqueExampleName(),
            language: .assembly,
            code: ""
        )
        examples.insert(item, at: 0)
        save()
        return item
    }

    func updateExample(id: ExampleLibraryItem.ID, name: String, language: ExampleLanguage, code: String, metadata: DemoSchoolMetadata? = nil) {
        guard let index = examples.firstIndex(where: { $0.id == id }) else { return }
        examples[index].name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        examples[index].language = language
        examples[index].code = code
        if var metadata {
            metadata.language = language.rawValue
            examples[index].metadata = metadata
        }
        examples[index].updatedAt = Date()
        save()
    }

    func deleteExample(id: ExampleLibraryItem.ID) {
        examples.removeAll { $0.id == id }
        save()
    }

    func example(withID id: ExampleLibraryItem.ID?) -> ExampleLibraryItem? {
        guard let id else { return nil }
        return examples.first { $0.id == id }
    }

    nonisolated static var defaultExamplesByName: [String: String] {
        Dictionary(uniqueKeysWithValues: defaultExamples.map { ($0.name, $0.code) })
    }

    private func uniqueExampleName() -> String {
        let baseName = "Untitled Example"
        guard examples.contains(where: { $0.name == baseName }) else { return baseName }

        var suffix = 2
        while examples.contains(where: { $0.name == "\(baseName) \(suffix)" }) {
            suffix += 1
        }
        return "\(baseName) \(suffix)"
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(examples) else { return }
        userDefaults.set(data, forKey: storageKey)
    }

    private static func loadExamples(from userDefaults: UserDefaults, storageKey: String) -> [ExampleLibraryItem] {
        guard let data = userDefaults.data(forKey: storageKey),
              let examples = try? JSONDecoder().decode([ExampleLibraryItem].self, from: data) else {
            return defaultExamples
        }

        return examples.sorted { $0.updatedAt > $1.updatedAt }
    }

    private static func mergedDefaultExamples(with storedExamples: [ExampleLibraryItem]) -> [ExampleLibraryItem] {
        let currentDefaultNames = Set(defaultExamples.map(\.name))
        let legacyNames = Set([
            "Copper Rainbow", "Blitter Clear Screen", "Bouncing Copper Bars", "Audio Pulse Channel",
            "Joystick Direction Reader", "Intuition Window Hello", "Exec AllocMem Pattern",
            "C Copper List Builder", "C Main Calling ASM WaitTOF", "ASM Copper Called From C"
        ])
        let customExamples = storedExamples.filter { !legacyNames.contains($0.name) && !currentDefaultNames.contains($0.name) }
        return (defaultExamples + customExamples).sorted { $0.updatedAt > $1.updatedAt }
    }

    nonisolated private static func withDemoSchoolMetadata(_ example: ExampleLibraryItem) -> ExampleLibraryItem {
        var example = example
        switch example.name {
        case "01 ASM Clean Takeover Skeleton":
            example.metadata = DemoSchoolMetadata(difficulty: "Intermediate", stage: "System", language: example.language.rawValue, effectType: "System", hardware: ["Exec", "Copper", "Bitplanes"], concepts: ["OS restore", "VBlank", "DMACON"], value: ["Learn", "Reuse"], status: "Verified")
        case "02 ASM Copper Rainbow Lab":
            example.metadata = DemoSchoolMetadata(difficulty: "Beginner", stage: "Copper", language: example.language.rawValue, effectType: "Raster Bars", hardware: ["Copper"], concepts: ["WAIT", "MOVE", "raster bars"], value: ["Learn", "Showcase"], status: "Verified", dependencies: ["01 ASM Clean Takeover Skeleton"])
        case "03 ASM Double-Buffered Bitplane Playground":
            example.metadata = DemoSchoolMetadata(difficulty: "Intermediate", stage: "Display", language: example.language.rawValue, effectType: "Bitplane", hardware: ["Bitplanes", "Copper"], concepts: ["double buffering", "BPL pointers", "VBlank"], value: ["Learn", "Reuse"], status: "Verified", dependencies: ["02 ASM Copper Rainbow Lab"])
        case "04 ASM Blitter Toolkit Demo":
            example.metadata = DemoSchoolMetadata(difficulty: "Intermediate", stage: "Blitter", language: example.language.rawValue, effectType: "Blitter", hardware: ["Blitter", "Bitplanes"], concepts: ["BBUSY", "clear", "masked copy", "line mode"], value: ["Learn", "Reuse"], status: "Verified", dependencies: ["03 ASM Double-Buffered Bitplane Playground"])
        case "05 ASM Hardware Sprite Logo":
            example.metadata = DemoSchoolMetadata(difficulty: "Intermediate", stage: "Sprites", language: example.language.rawValue, effectType: "Sprite Logo", hardware: ["Sprites", "Copper"], concepts: ["SPRxPOS", "SPRxCTL", "DMA pointer animation"], value: ["Learn", "Showcase"], status: "Verified", dependencies: ["03 ASM Double-Buffered Bitplane Playground"])
        case "06 ASM Sine Text Scroller":
            example.metadata = DemoSchoolMetadata(difficulty: "Advanced", stage: "Math", language: example.language.rawValue, effectType: "Scroller", hardware: ["Bitplanes"], concepts: ["sine table", "custom font", "scrolltext"], value: ["Learn", "Showcase"], status: "Verified", dependencies: ["03 ASM Double-Buffered Bitplane Playground"])
        case "07 C Starfield + Parallax":
            example.metadata = DemoSchoolMetadata(difficulty: "Advanced", stage: "Effects", language: example.language.rawValue, effectType: "Starfield", hardware: ["Bitplanes", "Math"], concepts: ["fixed point", "parallax", "wraparound"], value: ["Learn", "Showcase"], status: "Verified", dependencies: ["06 ASM Sine Text Scroller"])
        case "08 C Menu + Input Shell":
            example.metadata = DemoSchoolMetadata(difficulty: "Intermediate", stage: "C Integration", language: example.language.rawValue, effectType: "Menu", hardware: ["Exec", "CIA"], concepts: ["menus", "input", "scene launch"], value: ["Learn", "Reuse"], status: "Verified")
        case "09 C + ASM Scene Orchestrator":
            example.metadata = DemoSchoolMetadata(difficulty: "Advanced", stage: "C Integration", language: example.language.rawValue, effectType: "Megamix", hardware: ["Copper", "CIA"], concepts: ["C orchestration", "ASM effects", "VBlank"], value: ["Learn", "Reuse"], status: "Verified", dependencies: ["08 C Menu + Input Shell"])
        case "10 C + ASM Mini Demo Megamix":
            example.metadata = DemoSchoolMetadata(difficulty: "Showcase", stage: "Showcase", language: example.language.rawValue, effectType: "Megamix", hardware: ["Copper", "Blitter", "Sprites", "Paula", "CIA", "Bitplanes"], concepts: ["composition", "scene sequencing", "MOD replay", "CIA timer sync"], value: ["Showcase", "Reuse"], status: "Verified", dependencies: ["09 C + ASM Scene Orchestrator"])
        default:
            example.metadata = DemoSchoolMetadata(language: example.language.rawValue)
        }
        return example
    }

    nonisolated static let defaultExamples: [ExampleLibraryItem] = [
        ExampleLibraryItem(
            id: UUID(uuidString: "43C658C5-5D35-4B17-A93F-5E7FCF29D401")!,
            name: "02 ASM Copper Rainbow Lab",
            language: .assembly,
            code: """
; ==========================================================
;   Amiga 68000 Copper List Example
;   Generates a classic vertical raster rainbow bar
;   (System-friendly graphics.library takeover)
; ==========================================================
            SECTION    Code,CODE,CHIP       ; Must be in CHIP RAM!
            XDEF       _Start
_Start:
            movem.l    d2-d7/a2-a6,-(sp)    ; Save registers

            move.l     $4.w,a6              ; ExecBase
            lea        gfxName(pc),a1
            moveq      #0,d0
            jsr        -408(a6)             ; OpenLibrary
            move.l     d0,GfxBase
            beq.s      .exit

            move.l     GfxBase(pc),a6
            move.l     34(a6),oldView       ; Save GfxBase->ActiView
            sub.l      a1,a1
            jsr        -222(a6)             ; LoadView(NULL)
            jsr        -270(a6)             ; WaitTOF()
            jsr        -270(a6)             ; WaitTOF()

            lea        $dff000,a5
            lea        CopperList(pc),a0
            move.l     a0,$80(a5)           ; COP1LC
            move.w     #$0000,$88(a5)       ; COPJMP1
            move.w     #$8280,$96(a5)       ; DMAEN + COPEN

.waitButton:
            btst       #6,$bfe001
            bne.s      .waitButton

            move.l     GfxBase(pc),a6
            move.l     oldView(pc),a1
            jsr        -222(a6)             ; LoadView(oldView)
            jsr        -270(a6)
            jsr        -270(a6)

            move.l     $4.w,a6
            move.l     GfxBase(pc),a1
            jsr        -414(a6)             ; CloseLibrary

.exit:
            movem.l    (sp)+,d2-d7/a2-a6
            moveq      #0,d0
            rts

gfxName:    dc.b       "graphics.library",0
            EVEN
GfxBase:    dc.l       0
oldView:    dc.l       0

            ALIGN      4
CopperList:
            dc.w       $0100,$0200
            dc.w       $5007,$fffe,$0180,$0f00
            dc.w       $5807,$fffe,$0180,$0f70
            dc.w       $6007,$fffe,$0180,$0ff0
            dc.w       $6807,$fffe,$0180,$00f0
            dc.w       $7007,$fffe,$0180,$00ff
            dc.w       $7807,$fffe,$0180,$000f
            dc.w       $8007,$fffe,$0180,$0f0f
            dc.w       $8807,$fffe,$0180,$0000
            dc.w       $ffff,$fffe
"""
        ),
        ExampleLibraryItem(
            id: UUID(uuidString: "27167A62-567A-4F64-942E-EFB62F37F3C1")!,
            name: "04 ASM Blitter Toolkit Demo",
            language: .assembly,
            code: """
; Blitter toolkit: clear, cookie-cut masked copy, and line mode.
; The reusable rule is simple: always wait for BBUSY before touching BLT regs.
            SECTION    Code,CODE,CHIP
            XDEF       _Start
_Start:
            lea        $dff000,a6
            lea        Bitplane,a0
            bsr.s      BlitClear
            lea        Bitplane+(40*80)+14,a0
            bsr.s      BlitMaskedCopy
            lea        Bitplane+(40*120)+10,a0
            bsr.s      BlitLine
            rts

WaitBlitter:
            btst       #6,$02(a6)           ; DMACONR blitter busy
            bne.s      WaitBlitter
            rts

BlitClear:
            bsr        WaitBlitter
            move.w     #$0100,$40(a6)       ; BLTCON0: use D only
            move.w     #$0000,$42(a6)       ; BLTCON1
            move.w     #$0000,$66(a6)       ; BLTDMOD
            move.l     a0,$54(a6)           ; BLTDPTH
            move.w     #(256*64)+20,$58(a6) ; BLTSIZE: 256 lines, 40 bytes
            bsr        WaitBlitter
            rts

BlitMaskedCopy:
            bsr        WaitBlitter
            move.w     #$0fca,$40(a6)       ; minterm: (A AND B) OR (NOT A AND C)
            move.w     #$0000,$42(a6)
            move.w     #0,$64(a6)           ; BLTAMOD
            move.w     #0,$62(a6)           ; BLTBMOD
            move.w     #38,$60(a6)          ; BLTCMOD: existing screen stride
            move.w     #38,$66(a6)          ; BLTDMOD: destination stride
            lea        ShapeMask(pc),a1
            lea        ShapePixels(pc),a2
            move.l     a1,$50(a6)           ; BLTAPTH
            move.l     a2,$4c(a6)           ; BLTBPTH
            move.l     a0,$48(a6)           ; BLTCPTH
            move.l     a0,$54(a6)           ; BLTDPTH
            move.w     #(16*64)+1,$58(a6)   ; 16 rows, 1 word wide
            bsr        WaitBlitter
            rts

BlitLine:
            bsr        WaitBlitter
            move.w     #$ffff,$44(a6)       ; BLTAFWM
            move.w     #$ffff,$46(a6)       ; BLTALWM
            move.w     #$8000,$74(a6)       ; BLTADAT: first pixel
            move.w     #40,$66(a6)          ; BLTDMOD: screen stride
            move.w     #$0bca,$40(a6)       ; line mode with inclusive OR minterm
            move.w     #$0001,$42(a6)       ; BLTCON1: octant/sign bits live here
            move.l     a0,$54(a6)           ; BLTDPTH
            move.w     #(64*64)+1,$58(a6)   ; BLTSIZE: 64 line steps, 1 word
            bsr        WaitBlitter
            rts

ShapeMask:
            dc.w       $ffff,$ffff,$ffff,$ffff
            dc.w       $7ffe,$3ffc,$1ff8,$0ff0
            dc.w       $0ff0,$1ff8,$3ffc,$7ffe
            dc.w       $ffff,$7ffe,$3ffc,$1ff8
            dc.w       $0ff0,$1ff8,$3ffc,$7ffe
ShapePixels:
            dc.w       $8001,$c003,$e007,$f00f
            dc.w       $f81f,$fc3f,$fe7f,$ffff
            dc.w       $ffff,$fe7f,$fc3f,$f81f
            dc.w       $f00f,$e007,$c003,$8001
Bitplane:   ds.b       40*256
"""
        ),
        ExampleLibraryItem(
            id: UUID(uuidString: "68D3E570-DF6C-4119-A6E2-A5C4FA70C001")!,
            name: "01 ASM Clean Takeover Skeleton",
            language: .assembly,
            code: """
; Clean system takeover skeleton.
; Saves the active View, installs a tiny copper list, waits for mouse,
; then restores the OS display. Use this as the base for every demo.
            SECTION    Code,CODE,CHIP
            XDEF       _Start
_Start:
            movem.l    d2-d7/a2-a6,-(sp)
            move.l     $4.w,a6
            lea        GfxName(pc),a1
            moveq      #0,d0
            jsr        -408(a6)             ; OpenLibrary
            move.l     d0,GfxBase
            beq.s      .exit

            move.l     d0,a6
            move.l     34(a6),OldView       ; graphics.library ActiView
            sub.l      a1,a1
            jsr        -222(a6)             ; LoadView(NULL)
            jsr        -270(a6)             ; WaitTOF
            jsr        -270(a6)

            lea        $dff000,a6
            lea        CopperList(pc),a0
            move.l     a0,$80(a6)
            move.w     #0,$88(a6)
            move.w     #$8380,$96(a6)       ; DMAEN + COPEN + BPLEN

.main:
            btst       #6,$bfe001
            beq.s      .restore
            bsr        WaitVBlank
            bra.s      .main

.restore:
            move.l     GfxBase(pc),a6
            move.l     OldView(pc),a1
            jsr        -222(a6)             ; LoadView(oldView)
            jsr        -270(a6)
            jsr        -270(a6)
            move.l     $4.w,a6
            move.l     GfxBase(pc),a1
            jsr        -414(a6)             ; CloseLibrary

.exit:
            movem.l    (sp)+,d2-d7/a2-a6
            moveq      #0,d0
            rts

WaitVBlank:
            cmp.b      #$ff,$06(a6)
            bne.s      WaitVBlank
.leave:
            cmp.b      #$ff,$06(a6)
            beq.s      .leave
            rts

GfxName:    dc.b       "graphics.library",0
            EVEN
GfxBase:    dc.l       0
OldView:    dc.l       0

CopperList:
            dc.w       $0100,$0200          ; BPLCON0 off, copper visible
            dc.w       $0180,$0040          ; COLOR00 dark blue
            dc.w       $ffff,$fffe
"""
        ),
        ExampleLibraryItem(
            id: UUID(uuidString: "E1124EBA-A754-4F2A-9E33-401B7D30992D")!,
            name: "05 ASM Hardware Sprite Logo",
            language: .assembly,
            code: """
; Hardware sprite logo: installs sprite 0 and moves it with a small sine path.
; The sprite data ends with a zero control pair, which is mandatory.
            SECTION    Code,CODE,CHIP
            XDEF       _Start
_Start:
            lea        $dff000,a6
            lea        Sprite0(pc),a0
            move.l     a0,$120(a6)          ; SPR0PTH/L
            move.w     #$8220,$96(a6)       ; DMAEN + SPRITE DMA
            lea        YPath(pc),a1
            moveq      #31,d7
.frame:
            bsr        WaitVBlank
            move.b     (a1)+,Sprite0        ; VSTART
            move.b     Sprite0(pc),d0
            add.b      #32,d0
            move.b     d0,Sprite0+2         ; VSTOP
            dbra       d7,.frame
            rts

WaitVBlank:
            cmp.b      #$ff,$06(a6)
            bne.s      WaitVBlank
.leave:
            cmp.b      #$ff,$06(a6)
            beq.s      .leave
            rts

YPath:
            dc.b       $40,$44,$48,$4c,$50,$54,$58,$5b
            dc.b       $5e,$60,$62,$63,$64,$63,$62,$60
            dc.b       $5e,$5b,$58,$54,$50,$4c,$48,$44
            dc.b       $40,$3c,$38,$36,$34,$33,$34,$36

Sprite0:
            dc.b       $40,$80,$60,$00       ; VSTART/HSTART, VSTOP/control
            dc.w       %0001100000011000,%0011110000111100
            dc.w       %0111111001111110,%1111111111111111
            dc.w       %1110011111100111,%1100001111000011
            dc.w       %1101101111011011,%1111111111111111
            dc.w       0,0
"""
        ),
        ExampleLibraryItem(
            id: UUID(uuidString: "8C90777D-F55E-49D4-91AB-047D4F4D6881")!,
            name: "07 C Starfield + Parallax",
            language: .c,
            code: """
/* C starfield + parallax core.
   Teaches: byte-column bitplane plotting, fixed-speed wraparound, two
   depth layers, and palette cycling. Plug FarPlane/NearPlane into the
   double-buffered display example and call RenderStarfield() each VBlank. */
typedef unsigned char UBYTE;
typedef unsigned short UWORD;
typedef unsigned long ULONG;

#define ScreenBytesPerRow 40
#define ScreenRows 128
#define StarCount 12

struct Star {
    UBYTE xByte;
    UBYTE y;
    UBYTE speed;
    UBYTE layer;
};

static UBYTE FarPlane[ScreenBytesPerRow * ScreenRows];
static UBYTE NearPlane[ScreenBytesPerRow * ScreenRows];
static UWORD FrameCounter;
static UWORD CurrentStarColor;

static const UWORD ParallaxPalette[8] = {
    0x0444, 0x0666, 0x0888, 0x0aaa,
    0x0fff, 0x0aaa, 0x0888, 0x0666
};

static struct Star Stars[StarCount] = {
    { 37, 12, 1, 0 }, { 30, 18, 2, 1 }, { 35, 26, 1, 0 },
    { 22, 34, 3, 1 }, { 33, 42, 2, 1 }, { 15, 52, 1, 0 },
    { 38, 64, 3, 1 }, { 20, 76, 2, 1 }, { 36, 88, 1, 0 },
    { 27, 96, 3, 1 }, { 34, 108, 2, 1 }, { 18, 120, 1, 0 }
};

static void ClearLayers(void)
{
    ULONG i;

    for (i = 0; i < (ULONG)(ScreenBytesPerRow * ScreenRows); i++) {
        FarPlane[i] = 0;
        NearPlane[i] = 0;
    }
}

static void PlotStar(const struct Star *star)
{
    const UWORD offset = (UWORD)(star->y * ScreenBytesPerRow + star->xByte);

    if (star->layer) {
        NearPlane[offset] |= 0xf0;
    } else {
        FarPlane[offset] |= 0x80;
    }
}

static void ColorCycle(void)
{
    CurrentStarColor = ParallaxPalette[FrameCounter & 7];
}

void RenderStarfield(void)
{
    UWORD i;

    ClearLayers();
    for (i = 0; i < StarCount; i++) {
        if (Stars[i].xByte < Stars[i].speed) {
            Stars[i].xByte = ScreenBytesPerRow - 1;
        } else {
            Stars[i].xByte = (UBYTE)(Stars[i].xByte - Stars[i].speed);
        }
        PlotStar(&Stars[i]);
    }
    ColorCycle();
    FrameCounter++;
}

int main(void)
{
    UWORD frame;

    for (frame = 0; frame < 90; frame++) {
        RenderStarfield();
    }
    return (int)CurrentStarColor;
}
"""
        ),
        ExampleLibraryItem(
            id: UUID(uuidString: "E70AFEB6-BDE3-44D2-9B78-56331532C7C2")!,
            name: "08 C Menu + Input Shell",
            language: .c,
            code: """
/* C menu + input shell.
   Teaches: scene tables, debounced joystick navigation, menu cursor state,
   and clean calls into ASM-owned effects. Replace read_input() with CIA
   joystick/mouse polling and draw_menu() with your bitplane/font renderer. */
typedef unsigned char UBYTE;
typedef unsigned short UWORD;
typedef unsigned long ULONG;

#define INPUT_UP    0x01
#define INPUT_DOWN  0x02
#define INPUT_FIRE  0x04

extern void CopperBars(void);
extern void Starfield(void);
extern void SpriteLogo(void);

struct DemoScene {
    const char *title;
    void (*run)(void);
    UBYTE difficulty;
};

struct MenuState {
    UWORD selected;
    UWORD previousSelected;
    UBYTE previousInput;
    UBYTE launchRequested;
};

static UBYTE read_input(void)
{
    return 0;
}

static void wait_vblank(void)
{
}

static void draw_menu(const struct DemoScene *scenes, UWORD count, const struct MenuState *menu)
{
    UWORD i;

    for (i = 0; i < count; i++) {
        const char cursor = (i == menu->selected) ? '>' : ' ';
        (void)cursor;
        (void)scenes[i].title;
        (void)scenes[i].difficulty;
    }
}

static void update_menu(struct MenuState *menu, UBYTE input, UWORD sceneCount)
{
    const UBYTE pressed = (UBYTE)(input & (UBYTE)~menu->previousInput);

    menu->previousSelected = menu->selected;
    if (pressed & INPUT_UP) {
        menu->selected = (menu->selected == 0) ? (UWORD)(sceneCount - 1) : (UWORD)(menu->selected - 1);
    }
    if (pressed & INPUT_DOWN) {
        menu->selected = (UWORD)((menu->selected + 1) % sceneCount);
    }
    if (pressed & INPUT_FIRE) {
        menu->launchRequested = 1;
    }

    menu->previousInput = input;
}

static void launch_scene(const struct DemoScene *scene)
{
    if (scene && scene->run) {
        scene->run();
    }
}

int main(void)
{
    static const struct DemoScene scenes[] = {
        { "Copper bars", CopperBars, 1 },
        { "Starfield", Starfield, 2 },
        { "Sprite logo", SpriteLogo, 2 }
    };
    struct MenuState menu = {
        0,
        0xffff,
        0,
        0
    };
    ULONG frame;

    for (frame = 0; frame < 600 && !menu.launchRequested; frame++) {
        wait_vblank();
        update_menu(&menu, read_input(), (UWORD)(sizeof(scenes) / sizeof(scenes[0])));
        if (menu.selected != menu.previousSelected) {
            draw_menu(scenes, (UWORD)(sizeof(scenes) / sizeof(scenes[0])), &menu);
        }
    }

    launch_scene(&scenes[menu.selected]);
    return (int)menu.selected;
}
"""
        ),
        ExampleLibraryItem(
            id: UUID(uuidString: "F8C03D74-B36F-41F2-840B-A4C6C67EC28B")!,
            name: "06 ASM Sine Text Scroller",
            language: .assembly,
            code: """
; Sine text scroller core.
; Teaches: scroll cursor, sine Y lookup, byte-aligned custom font plotting,
; and the frame state you can plug into the double-buffered bitplane example.
            SECTION    Code,CODE,CHIP
            XDEF       _Start
_Start:
            moveq      #119,d7
.frames:
            bsr        RenderFrame
            addq.w     #1,ScrollX
            addq.w     #1,FrameCounter
            dbra       d7,.frames
            rts

RenderFrame:
            bsr        ClearBitplane
            move.l     ScrollTextPtr(pc),a3
            move.w     ScrollX(pc),d6
            lsr.w      #3,d6
            neg.w      d6
            add.w      #38,d6                 ; right edge in byte columns
            move.w     FrameCounter(pc),d5
            and.w      #31,d5
            moveq      #23,d7                 ; 24 visible cells
.charLoop:
            moveq      #0,d0
            move.b     (a3)+,d0
            bne.s      .hasChar
            lea        ScrollText(pc),a3
            move.b     (a3)+,d0
.hasChar:
            cmp.b      #' ',d0
            beq.s      .nextChar
            sub.b      #'A',d0
            bmi.s      .nextChar
            cmp.b      #25,d0
            bhi.s      .nextChar
            move.w     d0,d1
            lsl.w      #3,d1
            lea        CustomFont(pc),a2
            adda.w     d1,a2
            move.w     d5,d1
            add.w      d7,d1
            and.w      #31,d1
            lea        SineTable(pc),a0
            moveq      #0,d2
            move.b     (a0,d1.w),d2
            add.w      #44,d2                 ; base Y
            move.w     d6,d3
            bsr        DrawGlyph
.nextChar:
            subq.w     #1,d6
            dbra       d7,.charLoop
            move.l     a3,ScrollTextPtr
            rts

DrawGlyph:
            cmp.w      #0,d3
            blt.s      .done
            cmp.w      #39,d3
            bgt.s      .done
            lea        Bitplane(pc),a1
            moveq      #7,d4
.row:
            move.w     d2,d0
            mulu       #40,d0
            add.w      d3,d0
            move.b     (a2)+,d1
            or.b       d1,(a1,d0.w)
            addq.w     #1,d2
            dbra       d4,.row
.done:
            rts

ClearBitplane:
            lea        Bitplane(pc),a0
            moveq      #0,d0
            move.w     #(40*128/4)-1,d7
.clear:
            move.l     d0,(a0)+
            dbra       d7,.clear
            rts

ScrollX:        dc.w       0
FrameCounter:  dc.w       0
ScrollTextPtr: dc.l       ScrollText
ScrollText:    dc.b       "AMIGA DEMO SCHOOL  SINE SCROLLER  CUSTOM FONT  ",0
               EVEN

SineTable:
            dc.b       0,3,6,9,12,14,16,18
            dc.b       20,21,22,23,24,23,22,21
            dc.b       20,18,16,14,12,9,6,3
            dc.b       0,-3,-6,-9,-12,-14,-16,-18
            EVEN

CustomFont:
; A-Z 8x8 byte-aligned teaching font, compact enough to edit by hand.
            dc.b       $18,$24,$42,$7e,$42,$42,$42,$00 ; A
            dc.b       $7c,$42,$42,$7c,$42,$42,$7c,$00 ; B
            dc.b       $3c,$42,$40,$40,$40,$42,$3c,$00 ; C
            dc.b       $78,$44,$42,$42,$42,$44,$78,$00 ; D
            dc.b       $7e,$40,$40,$7c,$40,$40,$7e,$00 ; E
            dc.b       $7e,$40,$40,$7c,$40,$40,$40,$00 ; F
            dc.b       $3c,$42,$40,$4e,$42,$42,$3c,$00 ; G
            dc.b       $42,$42,$42,$7e,$42,$42,$42,$00 ; H
            dc.b       $7e,$18,$18,$18,$18,$18,$7e,$00 ; I
            dc.b       $0e,$04,$04,$04,$44,$44,$38,$00 ; J
            dc.b       $42,$44,$48,$70,$48,$44,$42,$00 ; K
            dc.b       $40,$40,$40,$40,$40,$40,$7e,$00 ; L
            dc.b       $42,$66,$5a,$5a,$42,$42,$42,$00 ; M
            dc.b       $42,$62,$52,$4a,$46,$42,$42,$00 ; N
            dc.b       $3c,$42,$42,$42,$42,$42,$3c,$00 ; O
            dc.b       $7c,$42,$42,$7c,$40,$40,$40,$00 ; P
            dc.b       $3c,$42,$42,$42,$4a,$44,$3a,$00 ; Q
            dc.b       $7c,$42,$42,$7c,$48,$44,$42,$00 ; R
            dc.b       $3c,$42,$40,$3c,$02,$42,$3c,$00 ; S
            dc.b       $7e,$18,$18,$18,$18,$18,$18,$00 ; T
            dc.b       $42,$42,$42,$42,$42,$42,$3c,$00 ; U
            dc.b       $42,$42,$42,$42,$24,$24,$18,$00 ; V
            dc.b       $42,$42,$42,$5a,$5a,$66,$42,$00 ; W
            dc.b       $42,$24,$18,$18,$18,$24,$42,$00 ; X
            dc.b       $42,$24,$18,$18,$18,$18,$18,$00 ; Y
            dc.b       $7e,$04,$08,$10,$20,$40,$7e,$00 ; Z
            EVEN

Bitplane:   ds.b       40*128
"""
        ),
        ExampleLibraryItem(
            id: UUID(uuidString: "35236B07-09D4-45F5-8875-F5826940F0EB")!,
            name: "03 ASM Double-Buffered Bitplane Playground",
            language: .assembly,
            code: """
; Double-buffered one-bitplane pointer swap skeleton.
            SECTION    Code,CODE,CHIP
            XDEF       _Start
_Start:
            lea        $dff000,a6
            lea        CopperList(pc),a0
            move.l     a0,$80(a6)
            move.w     #$0000,$88(a6)
            move.w     #$8380,$96(a6)       ; DMAEN + COPEN + BPLEN
            lea        BufferA(pc),a0
            lea        BufferB(pc),a1
            moveq      #20,d7
.loop:
            bsr        WaitVBlank
            exg        a0,a1
            move.l     a0,BitplanePtr
            dbra       d7,.loop
            rts

WaitVBlank:
            cmp.b      #$ff,$06(a6)
            bne.s      WaitVBlank
.leave:
            cmp.b      #$ff,$06(a6)
            beq.s      .leave
            rts

CopperList:
            dc.w       $0100,$1200
BitplanePtr:
            dc.w       $00e0,$0000,$00e2,$0000
            dc.w       $ffff,$fffe

BufferA:    ds.b       40*256
BufferB:    ds.b       40*256
"""
        ),
        ExampleLibraryItem(
            id: UUID(uuidString: "9CE82ED8-4A6E-4CF1-836E-227860872A17")!,
            name: "09 C + ASM Scene Orchestrator",
            language: .mixed,
            code: """
; Mixed project note:
;   main.c owns menus/state and calls:
;       extern void RunScene(unsigned short id);
;       extern void SceneTick(void);
;   id 0 = copper bars, 1 = starfield, 2 = sprite logo.
;
; This editor buffer is the VASM-compiled assembly side.
            SECTION    Code,CODE,CHIP
            XDEF       _RunScene
            XDEF       _SceneTick
_RunScene:
            and.w      #3,d0
            move.w     d0,ActiveScene
            clr.w      FrameCounter
            bsr        SceneInit
            rts

_SceneTick:
            addq.w     #1,FrameCounter
            move.w     ActiveScene(pc),d0
            add.w      d0,d0
            move.w     SceneTickJump(pc,d0.w),d1
            jmp        SceneTickJump(pc,d1.w)

SceneInit:
            add.w      d0,d0
            move.w     SceneInitJump(pc,d0.w),d1
            jmp        SceneInitJump(pc,d1.w)

SceneInitJump:
            dc.w       InitCopper-SceneInitJump
            dc.w       InitStars-SceneInitJump
            dc.w       InitSprite-SceneInitJump
            dc.w       SceneDone-SceneInitJump

SceneTickJump:
            dc.w       TickCopper-SceneTickJump
            dc.w       TickStars-SceneTickJump
            dc.w       TickSprite-SceneTickJump
            dc.w       SceneDone-SceneTickJump

InitCopper:
            lea        $dff000,a6
            lea        CopperList(pc),a0
            move.l     a0,$80(a6)
            move.w     #0,$88(a6)
            move.w     #$8280,$96(a6)
            bra        SceneDone

InitStars:
            lea        $dff000,a6
            move.w     #$0000,$180(a6)
            move.w     #$000f,$182(a6)
            bra        SceneDone

InitSprite:
            lea        $dff000,a6
            lea        Sprite0(pc),a0
            move.l     a0,$120(a6)
            move.w     #$8220,$96(a6)

TickCopper:
            lea        $dff000,a6
            move.w     FrameCounter(pc),d0
            and.w      #$000f,d0
            lsl.w      #8,d0
            or.w       #$000f,d0
            move.w     d0,$180(a6)
            rts

TickStars:
            lea        StarX(pc),a0
            subq.b     #1,(a0)
            bcc.s      .plot
            move.b     #39,(a0)
.plot:
            lea        $dff000,a6
            move.w     FrameCounter(pc),d0
            and.w      #$000f,d0
            move.w     d0,$182(a6)
            rts

TickSprite:
            move.w     FrameCounter(pc),d0
            and.w      #31,d0
            lea        SpriteYPath(pc),a0
            move.b     (a0,d0.w),Sprite0
            move.b     Sprite0(pc),d1
            add.b      #32,d1
            move.b     d1,Sprite0+2
            rts

SceneDone:
            rts

ActiveScene:    dc.w       0
FrameCounter:   dc.w       0
StarX:          dc.b       39
                EVEN

CopperList:
            dc.w       $0100,$0200
            dc.w       $5007,$fffe,$0180,$0f0
            dc.w       $7007,$fffe,$0180,$00f
            dc.w       $ffff,$fffe

SpriteYPath:
            dc.b       $50,$54,$58,$5b,$5e,$60,$62,$63
            dc.b       $64,$63,$62,$60,$5e,$5b,$58,$54
            dc.b       $50,$4c,$48,$45,$42,$40,$3e,$3d
            dc.b       $3c,$3d,$3e,$40,$42,$45,$48,$4c

Sprite0:
            dc.b       $50,$80,$70,$00
            dc.w       $3c3c,$7e7e,$ffff,$7e7e
            dc.w       0,0
"""
        ),
        ExampleLibraryItem(
            id: UUID(uuidString: "9F7E6BD4-3F09-4419-8845-F920674E4A46")!,
            name: "10 C + ASM Mini Demo Megamix",
            language: .mixed,
            code: """
; Mixed project note:
;   main.c would call DemoInit(), then DemoTick() once per frame.
;   This assembly side composes copper color, sprite DMA, Paula audio,
;   and a tiny MOD-style pattern tick driven from a CIA timer scaffold.
;
; This editor buffer is the VASM-compiled assembly side.
            SECTION    Code,CODE,CHIP
            XDEF       _DemoInit
            XDEF       _DemoTick
            XDEF       _ModTick
_DemoInit:
            lea        $dff000,a6
            lea        CopperList(pc),a0
            move.l     a0,$80(a6)
            lea        Sprite0(pc),a0
            move.l     a0,$120(a6)
            lea        Pulse(pc),a0
            move.l     a0,$a0(a6)
            move.w     #8,$a4(a6)
            move.w     #64,$a8(a6)
            move.w     #214,$a6(a6)
            move.w     #0,$88(a6)
            move.w     #$83a1,$96(a6)       ; DMAEN+COPEN+BPLEN+SPRITE+AUD0
            clr.w      Frame
            clr.w      ModRow
            move.w     #6,TickDivider
            bsr        _CIAInstallBeat
            rts

_DemoTick:
            lea        $dff000,a6
            bsr        WaitVBlank
            bsr        _ModTick
            addq.w     #1,Frame
            bsr        UpdateCopperPalette
            bsr        UpdateSpriteLogo
            bsr        UpdateScroller
            bsr        UpdateStarfield
            rts

UpdateCopperPalette:
            move.w     Frame(pc),d0
            and.w      #$000f,d0
            add.w      d0,d0
            lea        Palette(pc),a0
            move.w     (a0,d0.w),ColorPatch
            rts

UpdateSpriteLogo:
            move.w     Frame(pc),d0
            and.w      #31,d0
            lea        SpritePath(pc),a0
            move.b     (a0,d0.w),Sprite0
            move.b     Sprite0(pc),d1
            add.b      #32,d1
            move.b     d1,Sprite0+2
            rts

UpdateScroller:
            addq.w     #1,ScrollX
            move.w     ScrollX(pc),d0
            and.w      #31,d0
            lea        SineTable(pc),a0
            moveq      #0,d1
            move.b     (a0,d0.w),d1
            move.w     d1,ScrollerY
            rts

UpdateStarfield:
            lea        Stars(pc),a0
            moveq      #StarCount-1,d7
.star:
            move.b     2(a0),d0
            sub.b      d0,(a0)
            bcc.s      .next
            move.b     #39,(a0)
.next:
            addq.l     #4,a0
            dbra       d7,.star
            addq.w     #3,StarPhase
            rts

_CIAInstallBeat:
            move.b     #$7f,$bfdd00         ; CIA-B: mask timer interrupts while configuring
            move.b     #$21,$bfdf00         ; Timer B one-shot/force-load placeholder
            move.b     #$81,$bfdd00         ; enable Timer B interrupt source
            rts

_ModTick:
            subq.w     #1,TickDivider
            bne.s      .done
            move.w     #6,TickDivider       ; classic MOD speed: 6 ticks per row
            move.w     ModRow(pc),d0
            add.w      d0,d0
            lea        ModPattern(pc),a0
            move.w     (a0,d0.w),d1
            lea        PeriodTable(pc),a1
            move.w     (a1,d1.w),$a6(a6)    ; AUD0PER
            lea        Pulse(pc),a2
            move.l     a2,$a0(a6)           ; AUD0LC
            move.w     #8,$a4(a6)           ; AUD0LEN
            move.w     #48,$a8(a6)          ; AUD0VOL
            addq.w     #1,ModRow
            and.w      #$0007,ModRow
.done:
            rts

WaitVBlank:
            cmp.b      #$ff,$06(a6)
            bne.s      WaitVBlank
.leave:
            cmp.b      #$ff,$06(a6)
            beq.s      .leave
            rts

Frame:      dc.w       0
ScrollX:    dc.w       0
ScrollerY:  dc.w       0
StarPhase:  dc.w       0
TickDivider: dc.w      6
ModRow:     dc.w       0
StarCount   equ        8
Palette:    dc.w       $00f,$02f,$04f,$06f,$08f,$0af,$0cf,$0ff
            dc.w       $0fc,$0f8,$0f4,$0f0,$8f0,$cf0,$f80,$f40
SineTable:
            dc.b       0,3,6,9,12,14,16,18
            dc.b       20,21,22,23,24,23,22,21
            dc.b       20,18,16,14,12,9,6,3
            dc.b       0,-3,-6,-9,-12,-14,-16,-18
            EVEN
PeriodTable:
            dc.w       428,381,340,320
ModPattern:
            dc.w       0,2,4,6,4,2,0,6

CopperList:
            dc.w       $0100,$0200
            dc.w       $4007,$fffe,$0180,$008
            dc.w       $6007,$fffe,$0180
ColorPatch: dc.w       $00f
            dc.w       $9007,$fffe,$0180,$f40
            dc.w       $ffff,$fffe

Sprite0:
            dc.b       $48,$90,$68,$00
            dc.w       $1818,$3c3c,$7e7e,$ffff
            dc.w       $ffff,$7e7e,$3c3c,$1818
            dc.w       0,0

SpritePath:
            dc.b       $48,$4c,$50,$54,$58,$5b,$5e,$60
            dc.b       $62,$63,$64,$63,$62,$60,$5e,$5b
            dc.b       $58,$54,$50,$4c,$48,$44,$40,$3e
            dc.b       $3c,$3e,$40,$44,$48,$4c,$50,$54

; x byte, y, speed, layer. C can inspect this table for debug overlays.
Stars:
            dc.b       39,16,1,0
            dc.b       30,28,2,1
            dc.b       35,44,1,0
            dc.b       24,60,3,1
            dc.b       37,76,2,1
            dc.b       18,92,1,0
            dc.b       32,108,3,1
            dc.b       22,120,2,1
            EVEN

Pulse:
            dc.b       127,127,64,0,-64,-127,-64,0
            dc.b       127,64,0,-64,-127,-64,0,64
"""
        )
    ].map(withDemoSchoolMetadata).sorted { $0.name < $1.name }
}
