; Data file for the Amiga Parallax Demo
; Contains all data and memory allocations.

; Constants
BPL_WIDTH = 40
SCREEN_HEIGHT = 256
BPL_SIZE = BPL_WIDTH*SCREEN_HEIGHT
BPLCON2_PF2P2 = $40

;===============================================================
; FAST RAM DATA (for things the CPU uses but not custom chips)
;===============================================================
    SECTION FastData,DATA

    XDEF    gfxname, TextLeft, TextRight, SoundLength, SfxStruct, BPLCON2_PF2P2
gfxname:
    dc.b    "graphics.library",0
    EVEN
TextLeft:
    dc.b    "LEFT TEXT",0
    EVEN
TextRight:
    dc.b    "RIGHT TEXT",0
    EVEN
SoundLength:
    dc.w    1000
SfxStruct:
    dc.l    SoundSample
    dc.w    500
    dc.w    700
    dc.w    64
    dc.b    -1
    dc.b    1

;===============================================================
; CHIP RAM DATA (for things the custom chips need to access)
;===============================================================
    SECTION ChipData,DATA_C

    XDEF    FontData, SoundSample
    XDEF    CopperNormal, CopperGlitch
    XDEF    bitplane1, bitplane2
    XDEF    AmegasMod

FontData:
    ; Simple 8x8 font data. Chars must be in ASCII order from SPACE.
    ; Char: SPACE
    dc.b $00,$00,$00,$00,$00,$00,$00,$00
    ; Chars: ! " # $ % & ' ( ) * + , - . / 0 1 2 3 4 5 6 7 8 9 : ; < = > ? @
    blk.b 31*8, 0
    ; Char: A
    dc.b $00,$00,$00,$00,$00,$00,$00,$00
    ; Char: B
    dc.b $00,$00,$00,$00,$00,$00,$00,$00
    ; Char: C
    dc.b $00,$00,$00,$00,$00,$00,$00,$00
    ; Char: D
    dc.b $00,$00,$00,$00,$00,$00,$00,$00
    ; Char: E
    dc.b $7E,$40,$40,$7C,$40,$40,$7E,$00
    ; Char: F
    dc.b $7E,$40,$40,$7C,$40,$40,$40,$00
    ; Char: G
    dc.b $3E,$40,$40,$4E,$42,$42,$3E,$00
    ; Char: H
    dc.b $42,$42,$42,$7E,$42,$42,$42,$00
    ; Char: I
    dc.b $3E,$18,$18,$18,$18,$18,$3E,$00
    ; Char: J
    dc.b $00,$00,$00,$00,$00,$00,$00,$00
    ; Char: K
    dc.b $00,$00,$00,$00,$00,$00,$00,$00
    ; Char: L
    dc.b $40,$40,$40,$40,$40,$40,$7E,$00
    ; Char: M
    dc.b $00,$00,$00,$00,$00,$00,$00,$00
    ; Char: N
    dc.b $00,$00,$00,$00,$00,$00,$00,$00
    ; Char: O
    dc.b $00,$00,$00,$00,$00,$00,$00,$00
    ; Char: P
    dc.b $00,$00,$00,$00,$00,$00,$00,$00
    ; Char: Q
    dc.b $00,$00,$00,$00,$00,$00,$00,$00
    ; Char: R
    dc.b $7C,$42,$42,$7C,$50,$48,$44,$00
    ; Char: S
    dc.b $00,$00,$00,$00,$00,$00,$00,$00
    ; Char: T
    dc.b $7E,$18,$18,$18,$18,$18,$18,$00
    ; Char: U
    dc.b $42,$42,$42,$42,$42,$42,$3E,$00
    ; Char: V
    dc.b $00,$00,$00,$00,$00,$00,$00,$00
    ; Char: W
    dc.b $00,$00,$00,$00,$00,$00,$00,$00
    ; Char: X
    dc.b $42,$42,$24,$18,$24,$42,$42,$00

SoundSample:
    blk.b 1000,0

CopperNormal:
    blk.l   64,0
CopperGlitch:
    blk.l   128,0
bitplane1:
    blk.b   BPL_SIZE,0
bitplane2:
    blk.b   BPL_SIZE,0
AmegasMod:
    incbin  "amegas.mod"

    END