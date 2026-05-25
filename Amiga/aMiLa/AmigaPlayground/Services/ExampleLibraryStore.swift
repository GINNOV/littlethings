import Foundation

enum ExampleLanguage: String, CaseIterable, Codable, Identifiable {
    case assembly = "ASM"
    case c = "C"
    case mixed = "ASM + C"

    var id: String { rawValue }
}

struct ExampleLibraryItem: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var language: ExampleLanguage
    var code: String
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        language: ExampleLanguage,
        code: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.language = language
        self.code = code
        self.createdAt = createdAt
        self.updatedAt = updatedAt
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

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.examples = Self.loadExamples(from: userDefaults, storageKey: storageKey)
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

    func updateExample(id: ExampleLibraryItem.ID, name: String, language: ExampleLanguage, code: String) {
        guard let index = examples.firstIndex(where: { $0.id == id }) else { return }
        examples[index].name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        examples[index].language = language
        examples[index].code = code
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

    nonisolated static let defaultExamples: [ExampleLibraryItem] = [
        ExampleLibraryItem(
            id: UUID(uuidString: "43C658C5-5D35-4B17-A93F-5E7FCF29D401")!,
            name: "Copper Rainbow",
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
            name: "Blitter Clear Screen",
            language: .assembly,
            code: """
; Clear 320x256 one-bitplane CHIP buffer with the blitter.
            SECTION    Code,CODE,CHIP
            XDEF       _Start
_Start:
            lea        $dff000,a6
            lea        Bitplane,a0

.waitBlit:
            btst       #6,$02(a6)           ; DMACONR blitter busy
            bne.s      .waitBlit

            move.w     #$0100,$40(a6)       ; BLTCON0: use D only
            move.w     #$0000,$42(a6)       ; BLTCON1
            move.w     #$0000,$66(a6)       ; BLTDMOD
            move.l     a0,$54(a6)           ; BLTDPTH
            move.w     #(256*64)+20,$58(a6) ; BLTSIZE: 256 lines, 40 bytes
            rts

            SECTION    ChipData,DATA,CHIP
Bitplane:   ds.b       40*256
"""
        ),
        ExampleLibraryItem(
            id: UUID(uuidString: "68D3E570-DF6C-4119-A6E2-A5C4FA70C001")!,
            name: "Bouncing Copper Bars",
            language: .assembly,
            code: """
; Animate a copper color register by changing the wait line each frame.
            SECTION    Code,CODE,CHIP
            XDEF       _Start
_Start:
            lea        $dff000,a6
            lea        CopperList(pc),a0
            move.l     a0,$80(a6)
            move.w     #$0000,$88(a6)
            move.w     #$8280,$96(a6)

            moveq      #80,d0
            moveq      #1,d1

.main:
            btst       #6,$bfe001
            beq.s      .done
            bsr.s      WaitVBlank
            move.b     d0,BarWait
            add.b      d1,d0
            cmp.b      #150,d0
            beq.s      .flip
            cmp.b      #70,d0
            bne.s      .main
.flip:
            neg.b      d1
            bra.s      .main

.done:
            rts

WaitVBlank:
            cmp.b      #$ff,$06(a6)
            bne.s      WaitVBlank
.leave:
            cmp.b      #$ff,$06(a6)
            beq.s      .leave
            rts

CopperList:
            dc.w       $0100,$0200
BarWait:    dc.b       80,$07
            dc.w       $fffe,$0180,$0f0
            dc.w       $a007,$fffe,$0180,$00f
            dc.w       $ffff,$fffe
"""
        ),
        ExampleLibraryItem(
            id: UUID(uuidString: "E1124EBA-A754-4F2A-9E33-401B7D30992D")!,
            name: "Audio Pulse Channel",
            language: .assembly,
            code: """
; Start Paula audio channel 0 with a tiny pulse waveform.
            SECTION    Code,CODE,CHIP
            XDEF       _Start
_Start:
            lea        $dff000,a6
            lea        Pulse(pc),a0
            move.l     a0,$a0(a6)           ; AUD0LC
            move.w     #8,$a4(a6)           ; AUD0LEN in words
            move.w     #64,$a8(a6)          ; AUD0VOL
            move.w     #214,$a6(a6)         ; AUD0PER
            move.w     #$8201,$96(a6)       ; DMAEN + AUD0EN
            rts

            ALIGN      4
Pulse:
            dc.b       127,127,127,127,0,0,0,0
            dc.b       -127,-127,-127,-127,0,0,0,0
"""
        ),
        ExampleLibraryItem(
            id: UUID(uuidString: "8C90777D-F55E-49D4-91AB-047D4F4D6881")!,
            name: "Joystick Direction Reader",
            language: .assembly,
            code: """
; Read joystick 1 direction bits from JOY1DAT into d0.
            SECTION    Code,CODE
            XDEF       _ReadJoy
_ReadJoy:
            move.w     $dff00c,d0           ; JOY1DAT
            move.w     d0,d1
            lsr.w      #1,d1
            eor.w      d1,d0                ; Convert gray-like bits
            and.w      #$0303,d0            ; Keep direction state
            rts
"""
        ),
        ExampleLibraryItem(
            id: UUID(uuidString: "E70AFEB6-BDE3-44D2-9B78-56331532C7C2")!,
            name: "Intuition Window Hello",
            language: .c,
            code: """
typedef unsigned long ULONG;
typedef void *APTR;

struct Library;
struct Window {
    APTR UserPort;
};

extern struct Library *OpenLibrary(const char *name, ULONG version);
extern void CloseLibrary(struct Library *library);
extern struct Window *OpenWindowTags(struct Window *window, ...);
extern void CloseWindow(struct Window *window);
extern void WaitPort(APTR port);

#define TAG_DONE        0UL
#define WA_Title        0x80000002UL
#define WA_Width        0x80000008UL
#define WA_Height       0x80000009UL
#define WA_CloseGadget  0x80000012UL
#define WA_DragBar      0x80000013UL
#define WA_DepthGadget  0x80000014UL
#define WA_IDCMP        0x8000001CUL
#define IDCMP_CLOSEWINDOW 0x00000200UL
#define TRUE            1UL

int main(void)
{
    struct Library *IntuitionBase;
    struct Window *win;

    IntuitionBase = OpenLibrary("intuition.library", 37);
    if (!IntuitionBase) {
        return 20;
    }

    win = OpenWindowTags(0,
        WA_Title, (ULONG)"Amiga Playground",
        WA_Width, 320UL,
        WA_Height, 80UL,
        WA_CloseGadget, TRUE,
        WA_DragBar, TRUE,
        WA_DepthGadget, TRUE,
        WA_IDCMP, IDCMP_CLOSEWINDOW,
        TAG_DONE);

    if (win) {
        WaitPort(win->UserPort);
        CloseWindow(win);
    }

    CloseLibrary(IntuitionBase);
    return 0;
}
"""
        ),
        ExampleLibraryItem(
            id: UUID(uuidString: "F8C03D74-B36F-41F2-840B-A4C6C67EC28B")!,
            name: "Exec AllocMem Pattern",
            language: .c,
            code: """
typedef unsigned char UBYTE;
typedef unsigned long ULONG;
typedef void *APTR;

extern APTR AllocMem(ULONG byteSize, ULONG requirements);
extern void FreeMem(APTR memoryBlock, ULONG byteSize);

#define MEMF_CHIP   0x00000002UL
#define MEMF_CLEAR  0x00010000UL

int main(void)
{
    UBYTE *buffer;
    ULONG i;

    buffer = (UBYTE *)AllocMem(4096UL, MEMF_CHIP | MEMF_CLEAR);
    if (!buffer) {
        return 20;
    }

    for (i = 0; i < 4096; i++) {
        buffer[i] = (UBYTE)(i & 0xff);
    }

    FreeMem(buffer, 4096UL);
    return 0;
}
"""
        ),
        ExampleLibraryItem(
            id: UUID(uuidString: "35236B07-09D4-45F5-8875-F5826940F0EB")!,
            name: "C Copper List Builder",
            language: .c,
            code: """
typedef unsigned short UWORD;

static UWORD copper[16];

int main(void)
{
    UWORD *p = copper;

    *p++ = 0x0100; *p++ = 0x0200;
    *p++ = 0x4007; *p++ = 0xfffe; *p++ = 0x0180; *p++ = 0x00f;
    *p++ = 0x6007; *p++ = 0xfffe; *p++ = 0x0180; *p++ = 0x0f0;
    *p++ = 0x8007; *p++ = 0xfffe; *p++ = 0x0180; *p++ = 0xf00;
    *p++ = 0xffff; *p++ = 0xfffe;

    return copper[0] == 0x0100 ? 0 : 5;
}
"""
        ),
        ExampleLibraryItem(
            id: UUID(uuidString: "9CE82ED8-4A6E-4CF1-836E-227860872A17")!,
            name: "C Main Calling ASM WaitTOF",
            language: .mixed,
            code: """
; Mixed project note:
;   main.c would declare: extern void WaitTwoFrames(void);
;   main.c would call:    WaitTwoFrames();
;
; This editor buffer is the VASM-compiled assembly side.
            SECTION    Code,CODE
            XDEF       _WaitTwoFrames
_WaitTwoFrames:
            lea        $dff000,a6
            bsr.s      .wait
            bsr.s      .wait
            rts
.wait:
            cmp.b      #$ff,$06(a6)
            bne.s      .wait
.leave:
            cmp.b      #$ff,$06(a6)
            beq.s      .leave
            rts
"""
        ),
        ExampleLibraryItem(
            id: UUID(uuidString: "9F7E6BD4-3F09-4419-8845-F920674E4A46")!,
            name: "ASM Copper Called From C",
            language: .mixed,
            code: """
; Mixed project note:
;   main.c would declare: extern void InstallCopper(void);
;   main.c would call:    InstallCopper();
;
; This editor buffer is the VASM-compiled assembly side.
            SECTION    Code,CODE,CHIP
            XDEF       _InstallCopper
_InstallCopper:
            lea        $dff000,a6
            lea        CopperList(pc),a0
            move.l     a0,$80(a6)
            move.w     #$0000,$88(a6)
            move.w     #$8280,$96(a6)
            rts

CopperList:
            dc.w       $0100,$0200
            dc.w       $5007,$fffe,$0180,$0af
            dc.w       $7007,$fffe,$0180,$fa0
            dc.w       $9007,$fffe,$0180,$f0a
            dc.w       $ffff,$fffe
"""
        )
    ]
}
