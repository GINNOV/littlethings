SYSTEM_PROMPT = (
    "You are AntigravityAmiga, an elite Amiga 68000 Motorola assembly programmer. "
    "Return complete VASM Motorola syntax source that compiles with vasmm68k_mot "
    "-kick1hunks -Fhunkexe and can run as an AmigaDOS executable. Use SECTION Code,CODE, "
    "XDEF _Start, whitespace before instructions/directives, $-style hexadecimal constants, "
    "and custom-chip addressing via lea $dff000,a6 plus register offsets."
)


def record(user_prompt, assistant_source):
    return {
        "messages": [
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": user_prompt.strip()},
            {"role": "assistant", "content": assistant_source.strip() + "\n"},
        ]
    }


CURATED_ASM_REGRESSIONS = [
    record(
        "Generate a minimal Amiga 68000 assembly program that exits cleanly.",
        """
            SECTION Code,CODE
            XDEF    _Start
_Start:
            moveq   #0,d0
            rts
""",
    ),
    record(
        "Generate a complete VASM-compatible AmigaDOS executable with SECTION Code,CODE, XDEF _Start, an _Start label, and a clean return.",
        """
            SECTION Code,CODE
            XDEF    _Start
_Start:
            moveq   #0,d0
            rts
""",
    ),
    record(
        "Generate a minimal Amiga VASM 68000 executable that clears d0 and returns.",
        """
            SECTION Code,CODE
            XDEF    _Start
_Start:
            moveq   #0,d0
            rts
""",
    ),
    record(
        """
Repair this semantically incomplete answer. It compiles, but it is not a complete AmigaDOS executable because it uses SECTION CODE, omits XDEF _Start, and omits the _Start label.

SECTION CODE
    move.l  4.w,a6
    lea     dosname,a1
    jsr     -408(a6)
    move.l  d0,dosbase
    move.l  d0,a6
    moveq   #0,d0
    rts

dosbase dc.l 0
dosname dc.b 'dos.library',0
""",
        """
            SECTION Code,CODE
            XDEF    _Start
_Start:
            moveq   #0,d0
            rts
""",
    ),
    record(
        """
The previous Amiga 68000 assembly failed the reliability gate.

Semantic failures:
- missing SECTION Code,CODE
- missing XDEF _Start
- missing _Start label

Return ONLY one complete corrected source file in a fenced assembly code block. Preserve the requested behavior.

Previous source:
SECTION CODE
    move.l  4.w,a6
    lea     dosname,a1
    jsr     -408(a6)
    move.l  d0,dosbase
    move.l  d0,a6
    moveq   #0,d0
    rts

dosbase dc.l 0
dosname dc.b 'dos.library',0
""",
        """
            SECTION Code,CODE
            XDEF    _Start
_Start:
            moveq   #0,d0
            rts
""",
    ),
    record(
        "Generate an Amiga VASM 68000 executable that sets COLOR00 to red via the custom chip register at $dff180, waits briefly in a finite delay loop, then returns.",
        """
            SECTION Code,CODE
            XDEF    _Start
_Start:
            lea     $dff000,a6
            move.w  #$0f00,$180(a6)
            move.w  #300,d0
.delay:
            dbf     d0,.delay
            rts
""",
    ),
    record(
        "Generate an Amiga VASM 68000 executable that waits for one vertical blank using VPOSR at $dff004, sets COLOR00 to blue, then returns.",
        """
            SECTION Code,CODE
            XDEF    _Start
_Start:
            lea     $dff000,a6
.waitHigh:
            cmp.b   #$ff,$06(a6)
            bne.s   .waitHigh
.waitLow:
            cmp.b   #$ff,$06(a6)
            beq.s   .waitLow
            move.w  #$000f,$180(a6)
            rts
""",
    ),
    record(
        "Generate an Amiga VASM 68000 executable that installs a tiny copper list changing COLOR00 through several colors, waits for a finite delay, clears copper DMA for this demo, then returns.",
        """
            SECTION Code,CODE,CHIP
            XDEF    _Start
_Start:
            lea     $dff000,a6
            lea     CopperList(pc),a0
            move.l  a0,$80(a6)
            move.w  #$0000,$88(a6)
            move.w  #$8280,$96(a6)

            move.w  #120,d0
.delay:
            bsr.s   WaitVBlank
            dbf     d0,.delay

            move.w  #$0080,$96(a6)
            rts

WaitVBlank:
            cmp.b   #$ff,$06(a6)
            bne.s   WaitVBlank
.leave:
            cmp.b   #$ff,$06(a6)
            beq.s   .leave
            rts

            ALIGN   2
CopperList:
            dc.w    $0100,$0200
            dc.w    $3007,$fffe,$0180,$0f00
            dc.w    $4007,$fffe,$0180,$0ff0
            dc.w    $5007,$fffe,$0180,$00f0
            dc.w    $6007,$fffe,$0180,$00ff
            dc.w    $7007,$fffe,$0180,$000f
            dc.w    $ffff,$fffe
""",
    ),
    record(
        "Generate a static Amiga copper list that changes the background color across several raster lines.",
        """
            SECTION Code,CODE,CHIP
            XDEF    _Start
_Start:
            lea     $dff000,a6
            lea     CopperList(pc),a0
            move.l  a0,$80(a6)
            move.w  #$0000,$88(a6)
            move.w  #$8280,$96(a6)

            move.w  #180,d0
.delay:
            bsr.s   WaitVBlank
            dbf     d0,.delay

            move.w  #$0080,$96(a6)
            rts

WaitVBlank:
            cmp.b   #$ff,$06(a6)
            bne.s   WaitVBlank
.leave:
            cmp.b   #$ff,$06(a6)
            beq.s   .leave
            rts

            ALIGN   2
CopperList:
            dc.w    $0100,$0200
            dc.w    $2807,$fffe,$0180,$0000
            dc.w    $3807,$fffe,$0180,$0f00
            dc.w    $4807,$fffe,$0180,$0ff0
            dc.w    $5807,$fffe,$0180,$00f0
            dc.w    $6807,$fffe,$0180,$00ff
            dc.w    $7807,$fffe,$0180,$000f
            dc.w    $8807,$fffe,$0180,$0f0f
            dc.w    $ffff,$fffe
""",
    ),
    record(
        """
Repair this failed static copper answer. It repeats SECTION/_Start blocks and never emits CopperList, COP1LC, COPJMP1, DMACON, or dc.w $ffff,$fffe.

SECTION Code,CODE,CHIP
XDEF _Start
_Start:
    lea $dff000,a6
    move.w #$0000,$180(a6)
    move.w #$8280,$184(a6)
    move.w #120,d0
.delay:
    bsr.s WaitVBlank
    dbf d0,.delay
    rts
""",
        """
            SECTION Code,CODE,CHIP
            XDEF    _Start
_Start:
            lea     $dff000,a6
            lea     CopperList(pc),a0
            move.l  a0,$80(a6)
            move.w  #$0000,$88(a6)
            move.w  #$8280,$96(a6)
            move.w  #180,d0
.delay:
            bsr.s   WaitVBlank
            dbf     d0,.delay
            move.w  #$0080,$96(a6)
            rts

WaitVBlank:
            cmp.b   #$ff,$06(a6)
            bne.s   WaitVBlank
.leave:
            cmp.b   #$ff,$06(a6)
            beq.s   .leave
            rts

            ALIGN   2
CopperList:
            dc.w    $0100,$0200
            dc.w    $3007,$fffe,$0180,$0f00
            dc.w    $4007,$fffe,$0180,$0ff0
            dc.w    $5007,$fffe,$0180,$00f0
            dc.w    $6007,$fffe,$0180,$00ff
            dc.w    $7007,$fffe,$0180,$000f
            dc.w    $ffff,$fffe
""",
    ),
    record(
        "Generate an Amiga VASM 68000 executable that waits for the blitter using the canonical DMACONR byte test bit 6, clears a small CHIP data buffer with the CPU, then returns.",
        """
            SECTION Code,CODE,CHIP
            XDEF    _Start
_Start:
            lea     $dff000,a6
.waitBlitter:
            btst    #6,$02(a6)
            bne.s   .waitBlitter

            lea     ChipBuffer(pc),a0
            moveq   #0,d0
            move.w  #127,d1
.clear:
            move.l  d0,(a0)+
            dbf     d1,.clear
            rts

            ALIGN   2
ChipBuffer:
            ds.b    512
""",
    ),
    record(
        "Generate a bouncing multi color copper list with animated bars that exits on left mouse.",
        """
            SECTION Code,CODE,CHIP
            XDEF    _Start
_Start:
            lea     $dff000,a6
            lea     CopperList(pc),a0
            move.l  a0,$80(a6)
            move.w  #$0000,$88(a6)
            move.w  #$8280,$96(a6)
            moveq   #64,d0
            moveq   #1,d1

.main:
            btst    #6,$bfe001
            beq.s   .done
            bsr.s   WaitVBlank
            move.b  d0,d2
            move.b  d2,Bar1Wait
            addq.b  #8,d2
            move.b  d2,Bar2Wait
            addq.b  #8,d2
            move.b  d2,Bar3Wait
            addq.b  #8,d2
            move.b  d2,Bar4Wait
            add.b   d1,d0
            cmp.b   #150,d0
            beq.s   .flip
            cmp.b   #48,d0
            bne.s   .main
.flip:
            neg.b   d1
            bra.s   .main
.done:
            move.w  #$0080,$96(a6)
            rts

WaitVBlank:
            cmp.b   #$ff,$06(a6)
            bne.s   WaitVBlank
.leave:
            cmp.b   #$ff,$06(a6)
            beq.s   .leave
            rts

            ALIGN   2
CopperList:
            dc.w    $0100,$0200
Bar1Wait:  dc.b    64,$07
            dc.w    $fffe,$0180,$0f00
Bar2Wait:  dc.b    72,$07
            dc.w    $fffe,$0180,$0ff0
Bar3Wait:  dc.b    80,$07
            dc.w    $fffe,$0180,$00f0
Bar4Wait:  dc.b    88,$07
            dc.w    $fffe,$0180,$00ff
            dc.w    $ffff,$fffe
""",
    ),
    record(
        """
Repair this semantically wrong bouncing copper answer. It installs a static CopperList, but it lacks a left mouse exit and does not update Bar wait words every frame.

SECTION Code,CODE,CHIP
XDEF _Start
_Start:
    lea $dff000,a6
    lea CopperList(pc),a0
    move.l a0,$80(a6)
    move.w #$0000,$88(a6)
    move.w #$8280,$96(a6)
    move.w #120,d0
.delay:
    bsr.s WaitVBlank
    dbf d0,.delay
    rts
CopperList:
    dc.w $0100,$0200
    dc.w $3007,$fffe,$0180,$0f00
    dc.w $ffff,$fffe
""",
        """
            SECTION Code,CODE,CHIP
            XDEF    _Start
_Start:
            lea     $dff000,a6
            lea     CopperList(pc),a0
            move.l  a0,$80(a6)
            move.w  #$0000,$88(a6)
            move.w  #$8280,$96(a6)
            moveq   #64,d0
            moveq   #1,d1
.main:
            btst    #6,$bfe001
            beq.s   .done
            bsr.s   WaitVBlank
            move.b  d0,d2
            move.b  d2,Bar1Wait
            addq.b  #8,d2
            move.b  d2,Bar2Wait
            add.b   d1,d0
            cmp.b   #150,d0
            beq.s   .flip
            cmp.b   #48,d0
            bne.s   .main
.flip:
            neg.b   d1
            bra.s   .main
.done:
            move.w  #$0080,$96(a6)
            rts

WaitVBlank:
            cmp.b   #$ff,$06(a6)
            bne.s   WaitVBlank
.leave:
            cmp.b   #$ff,$06(a6)
            beq.s   .leave
            rts

            ALIGN   2
CopperList:
            dc.w    $0100,$0200
Bar1Wait:  dc.b    64,$07
            dc.w    $fffe,$0180,$0f00
Bar2Wait:  dc.b    72,$07
            dc.w    $fffe,$0180,$00ff
            dc.w    $ffff,$fffe
""",
    ),
    record(
        """
Repair this semantically wrong bouncing copper answer. It uses btst #6,$02(a6), which is a blitter busy wait, not a left mouse exit. Replace that with btst #6,$bfe001 and keep the animated Bar wait updates.

SECTION Code,CODE,CHIP
XDEF _Start
_Start:
    lea $dff000,a6
    lea CopperList(pc),a0
    move.l a0,$80(a6)
    move.w #$0000,$88(a6)
    move.w #$8280,$96(a6)
    moveq #64,d0
    moveq #1,d1
.main:
    btst #6,$02(a6)
    beq.s .done
    bsr.s WaitVBlank
    move.b d0,d2
    move.b d2,Bar1Wait
    addq.b #8,d2
    move.b d2,Bar2Wait
    add.b d1,d0
    cmp.b #150,d0
    beq.s .flip
    cmp.b #48,d0
    bne.s .main
.flip:
    neg.b d1
    bra.s .main
.done:
    move.w #$0080,$96(a6)
    rts
CopperList:
Bar1Wait: dc.b 64,$07
    dc.w $fffe,$0180,$0f00
Bar2Wait: dc.b 72,$07
    dc.w $fffe,$0180,$0ff0
    dc.w $ffff,$fffe
""",
        """
            SECTION Code,CODE,CHIP
            XDEF    _Start
_Start:
            lea     $dff000,a6
            lea     CopperList(pc),a0
            move.l  a0,$80(a6)
            move.w  #$0000,$88(a6)
            move.w  #$8280,$96(a6)
            moveq   #64,d0
            moveq   #1,d1
.main:
            btst    #6,$bfe001
            beq.s   .done
            bsr.s   WaitVBlank
            move.b  d0,d2
            move.b  d2,Bar1Wait
            addq.b  #8,d2
            move.b  d2,Bar2Wait
            add.b   d1,d0
            cmp.b   #150,d0
            beq.s   .flip
            cmp.b   #48,d0
            bne.s   .main
.flip:
            neg.b   d1
            bra.s   .main
.done:
            move.w  #$0080,$96(a6)
            rts

WaitVBlank:
            cmp.b   #$ff,$06(a6)
            bne.s   WaitVBlank
.leave:
            cmp.b   #$ff,$06(a6)
            beq.s   .leave
            rts

            ALIGN   2
CopperList:
            dc.w    $0100,$0200
Bar1Wait:  dc.b    64,$07
            dc.w    $fffe,$0180,$0f00
Bar2Wait:  dc.b    72,$07
            dc.w    $fffe,$0180,$0ff0
            dc.w    $ffff,$fffe
""",
    ),
    record(
        "Generate an Amiga 68000 assembly program that sets up a simple blitter operation and waits for blitter completion.",
        """
            SECTION Code,CODE,CHIP
            XDEF    _Start
_Start:
            lea     $dff000,a6
.waitBefore:
            btst    #6,$02(a6)
            bne.s   .waitBefore
            move.w  #$09f0,$40(a6)
            move.w  #$0000,$42(a6)
            move.l  #$ffffffff,$44(a6)
            lea     SourceData(pc),a0
            lea     DestData(pc),a1
            move.l  a0,$50(a6)
            move.l  a1,$54(a6)
            move.w  #$0000,$64(a6)
            move.w  #$0000,$66(a6)
            move.w  #$0401,$58(a6)
.waitAfter:
            btst    #6,$02(a6)
            bne.s   .waitAfter
            rts

            ALIGN   2
SourceData:
            dc.w    $ffff,$0000,$ffff,$0000
DestData:
            ds.w    4
""",
    ),
    record(
        """
Repair this semantically wrong blitter answer. It emits copper setup but the task requires BLTCON0 at $40(a6), BLTSIZE at $58(a6), and a blitter busy wait.

SECTION Code,CODE,CHIP
XDEF _Start
_Start:
    lea $dff000,a6
    lea CopperList(pc),a0
    move.l a0,$80(a6)
    move.w #$00ff,$88(a6)
.waitBlitter:
    btst #6,$02(a6)
    bne.s .waitBlitter
    rts
CopperList:
    dc.w $ffff,$fffe
""",
        """
            SECTION Code,CODE,CHIP
            XDEF    _Start
_Start:
            lea     $dff000,a6
.waitBefore:
            btst    #6,$02(a6)
            bne.s   .waitBefore
            move.w  #$09f0,$40(a6)
            move.w  #$0000,$42(a6)
            move.l  #$ffffffff,$44(a6)
            lea     SourceData(pc),a0
            lea     DestData(pc),a1
            move.l  a0,$50(a6)
            move.l  a1,$54(a6)
            move.w  #$0000,$64(a6)
            move.w  #$0000,$66(a6)
            move.w  #$0401,$58(a6)
.waitAfter:
            btst    #6,$02(a6)
            bne.s   .waitAfter
            rts

            ALIGN   2
SourceData:
            dc.w    $ffff,$0000,$ffff,$0000
DestData:
            ds.w    4
""",
    ),
    record(
        """
Repair this semantically wrong blitter answer. It only waits for the blitter and returns. The task requires setting up a simple blitter operation, including BLTCON0 at $40(a6), BLTSIZE at $58(a6), and waits before and after the blit.

SECTION Code,CODE,CHIP
XDEF _Start
_Start:
    lea $dff000,a6
.waitBefore:
    btst #6,$02(a6)
    bne.s .waitBefore
    rts
""",
        """
            SECTION Code,CODE,CHIP
            XDEF    _Start
_Start:
            lea     $dff000,a6
.waitBefore:
            btst    #6,$02(a6)
            bne.s   .waitBefore
            move.w  #$09f0,$40(a6)
            move.w  #$0000,$42(a6)
            move.l  #$ffffffff,$44(a6)
            lea     SourceData(pc),a0
            lea     DestData(pc),a1
            move.l  a0,$50(a6)
            move.l  a1,$54(a6)
            move.w  #$0000,$64(a6)
            move.w  #$0000,$66(a6)
            move.w  #$0401,$58(a6)
.waitAfter:
            btst    #6,$02(a6)
            bne.s   .waitAfter
            rts

            ALIGN   2
SourceData:
            dc.w    $ffff,$0000,$ffff,$0000
DestData:
            ds.w    4
""",
    ),
    record(
        """
Repair this failed VASM source. The compiler reported an undefined symbol <DFF180>.

SECTION Code
CODE
XDEF _Start
_Start:
    MOVE #$0f00,DFF180
    RTS
""",
        """
            SECTION Code,CODE
            XDEF    _Start
_Start:
            lea     $dff000,a6
            move.w  #$0f00,$180(a6)
            rts
""",
    ),
    record(
        """
Repair this failed VASM source. It uses C-style hex and an undefined symbol BLUE.

SECTION Code,CODE
XDEF _Start
_Start:
    MOVE #0xFFFE,D0
    MOVE #BLUE,D1
    RTS
""",
        """
            SECTION Code,CODE
            XDEF    _Start
_Start:
            move.w  #$fffe,d0
            move.w  #$000f,d1
            rts
""",
    ),
    record(
        """
Repair this failed VASM source. It uses the nonexistent DEC mnemonic, invalid dff000(a6) addressing, and bne.l in a short loop.

SECTION Code
CODE
XDEF _Start
_Start:
    lea $dff000,a6
    move.l #0xf0000000,dff000(a6)
    move.l #0FFFFFFF,d0
DelayLoop:
    dec.l d0
    bne.l DelayLoop
    rts
""",
        """
            SECTION Code,CODE
            XDEF    _Start
_Start:
            lea     $dff000,a6
            move.w  #$0f00,$180(a6)
            move.w  #600,d0
DelayLoop:
            subq.w  #1,d0
            bne.s   DelayLoop
            rts
""",
    ),
    record(
        """
Repair this failed VASM source. It uses wait.l, BPUSH, OUT, and $fp/v0 pseudo-registers.

SECTION Code,CODE
XDEF _Start
_Start:
    BPUSH #12,SP
    OUT A0,D0
    wait.l #$ffff,dff008
    move.l $ffff0000($fp),v0
    rts
""",
        """
            SECTION Code,CODE
            XDEF    _Start
_Start:
            lea     $dff000,a6
.waitHigh:
            cmp.b   #$ff,$06(a6)
            bne.s   .waitHigh
.waitLow:
            cmp.b   #$ff,$06(a6)
            beq.s   .waitLow
            moveq   #0,d0
            rts
""",
    ),
    record(
        """
Repair this failed VASM source. It tries to clear nonexistent 68000 data registers d8, d9, d10 and does not implement the requested COLOR00 write.

SECTION Code,CODE
    move.l 4.w,a6
    move.l #$00000000,d1
    move.l #$00000000,d2
    move.l #$00000000,d3
    move.l #$00000000,d4
    move.l #$00000000,d5
    move.l #$00000000,d6
    move.l #$00000000,d7
    move.l #$00000000,d8
    move.l #$00000000,d9
    move.l #$00000000,d10
    rts
""",
        """
            SECTION Code,CODE
            XDEF    _Start
_Start:
            lea     $dff000,a6
            move.w  #$0f00,$180(a6)
            move.w  #300,d0
.delay:
            dbf     d0,.delay
            rts
""",
    ),
    record(
        "Generate a complete VASM Amiga 68000 COLOR00 demo. Do not clear all registers; only set COLOR00 to red, wait briefly, and return.",
        """
            SECTION Code,CODE
            XDEF    _Start
_Start:
            lea     $dff000,a6
            move.w  #$0f00,$180(a6)
            move.w  #300,d0
.delay:
            dbf     d0,.delay
            rts
""",
    ),
    record(
        "Generate an Amiga VASM 68000 executable that installs a tiny copper list changing COLOR00 through several colors, waits for a finite delay, clears copper DMA for this demo, then returns. Do not answer with the simple COLOR00 delay demo.",
        """
            SECTION Code,CODE,CHIP
            XDEF    _Start
_Start:
            lea     $dff000,a6
            lea     CopperList(pc),a0
            move.l  a0,$80(a6)
            move.w  #$0000,$88(a6)
            move.w  #$8280,$96(a6)
            move.w  #120,d0
.delay:
            bsr.s   WaitVBlank
            dbf     d0,.delay
            move.w  #$0080,$96(a6)
            rts

WaitVBlank:
            cmp.b   #$ff,$06(a6)
            bne.s   WaitVBlank
.leave:
            cmp.b   #$ff,$06(a6)
            beq.s   .leave
            rts

            ALIGN   2
CopperList:
            dc.w    $0100,$0200
            dc.w    $3007,$fffe,$0180,$0f00
            dc.w    $4007,$fffe,$0180,$0ff0
            dc.w    $5007,$fffe,$0180,$00f0
            dc.w    $6007,$fffe,$0180,$00ff
            dc.w    $ffff,$fffe
""",
    ),
    record(
        """
Repair this semantically wrong answer. The task asked for a tiny copper list, but the answer only writes COLOR00 directly.

SECTION Code,CODE
XDEF _Start
_Start:
    lea $dff000,a6
    move.w #$0f00,$180(a6)
    move.w #300,d0
.delay:
    dbf d0,.delay
    rts
""",
        """
            SECTION Code,CODE,CHIP
            XDEF    _Start
_Start:
            lea     $dff000,a6
            lea     CopperList(pc),a0
            move.l  a0,$80(a6)
            move.w  #$0000,$88(a6)
            move.w  #$8280,$96(a6)
            move.w  #120,d0
.delay:
            bsr.s   WaitVBlank
            dbf     d0,.delay
            move.w  #$0080,$96(a6)
            rts

WaitVBlank:
            cmp.b   #$ff,$06(a6)
            bne.s   WaitVBlank
.leave:
            cmp.b   #$ff,$06(a6)
            beq.s   .leave
            rts

            ALIGN   2
CopperList:
            dc.w    $0100,$0200
            dc.w    $3007,$fffe,$0180,$0f00
            dc.w    $4007,$fffe,$0180,$0ff0
            dc.w    $5007,$fffe,$0180,$00f0
            dc.w    $6007,$fffe,$0180,$00ff
            dc.w    $ffff,$fffe
""",
    ),
    record(
        "Generate an Amiga VASM 68000 executable that waits for the blitter using the canonical DMACONR byte test bit 6, clears a small CHIP data buffer with the CPU, then returns. Use only d0-d7 and a0-a6.",
        """
            SECTION Code,CODE,CHIP
            XDEF    _Start
_Start:
            lea     $dff000,a6
.waitBlitter:
            btst    #6,$02(a6)
            bne.s   .waitBlitter
            lea     ChipBuffer(pc),a0
            moveq   #0,d0
            move.w  #127,d1
.clear:
            move.l  d0,(a0)+
            dbf     d1,.clear
            rts

            ALIGN   2
ChipBuffer:
            ds.b    512
""",
    ),
    record(
        """
Repair this failed blitter clear source. It uses bare dff000 as a symbol and nonexistent registers d8/d9/d10.

SECTION Code,CODE
XDEF _Start
_Start:
    lea $dff000,a6
.waitBlitter:
    btst #6,$02(a6)
    bne.s .waitBlitter
    lea ChipBuffer(pc),a0
.clear:
    move.w dff000,d1
    move.w d0,d8
    move.w d0,d9
    move.w d0,d10
    rts
ChipBuffer:
    ds.b 512
""",
        """
            SECTION Code,CODE,CHIP
            XDEF    _Start
_Start:
            lea     $dff000,a6
.waitBlitter:
            btst    #6,$02(a6)
            bne.s   .waitBlitter
            lea     ChipBuffer(pc),a0
            moveq   #0,d0
            move.w  #127,d1
.clear:
            move.l  d0,(a0)+
            dbf     d1,.clear
            rts

            ALIGN   2
ChipBuffer:
            ds.b    512
""",
    ),
]


def capability_records(family, prompts, source, repairs):
    records = [record(prompt, source) for prompt in prompts]
    records.extend(record(prompt, source) for prompt in repairs)
    return records


BLITTER_CLEAR_SOURCE = """
            SECTION Code,CODE,CHIP
            XDEF    _Start
_Start:
            lea     $dff000,a6
            lea     Bitplane,a0
.waitBefore:
            btst    #6,$02(a6)
            bne.s   .waitBefore
            move.w  #$0100,$40(a6)
            move.w  #$0000,$42(a6)
            move.w  #$ffff,$44(a6)
            move.w  #$ffff,$46(a6)
            move.l  a0,$54(a6)
            move.w  #$0000,$64(a6)
            move.w  #$0000,$66(a6)
            move.w  #(16*64)+2,$58(a6)
.waitAfter:
            btst    #6,$02(a6)
            bne.s   .waitAfter
            rts

            SECTION ChipData,DATA,CHIP
Bitplane:   ds.b    4*16
"""

BLITTER_COPY_SOURCE = """
            SECTION Code,CODE,CHIP
            XDEF    _Start
_Start:
            lea     $dff000,a6
            lea     BlitBuffers,a0
            lea     4*16(a0),a1
.waitBefore:
            btst    #6,$02(a6)
            bne.s   .waitBefore
            move.w  #$09f0,$40(a6)
            move.w  #$0000,$42(a6)
            move.l  a0,$50(a6)
            move.l  a1,$54(a6)
            move.w  #$0000,$64(a6)
            move.w  #$0000,$66(a6)
            move.w  #(16*64)+2,$58(a6)
.waitAfter:
            btst    #6,$02(a6)
            bne.s   .waitAfter
            rts

            SECTION ChipData,DATA,CHIP
BlitBuffers: ds.b   4*16*2
"""

BLITTER_FILL_SOURCE = """
            SECTION Code,CODE,CHIP
            XDEF    _Start
_Start:
            lea     $dff000,a6
            lea     FillBuffer,a0
.waitBefore:
            btst    #6,$02(a6)
            bne.s   .waitBefore
            move.w  #$0100,$40(a6)
            move.w  #$0000,$42(a6)
            move.w  #$ffff,$44(a6)
            move.w  #$ffff,$46(a6)
            move.l  a0,$54(a6)
            move.w  #$0000,$64(a6)
            move.w  #$0000,$66(a6)
            move.w  #(16*64)+2,$58(a6)
.waitAfter:
            btst    #6,$02(a6)
            bne.s   .waitAfter
            rts

            SECTION ChipData,DATA,CHIP
FillBuffer: ds.b    4*16
"""

BLITTER_MASKED_BOB_SOURCE = """
            SECTION Code,CODE,CHIP
            XDEF    _Start
_Start:
            lea     $dff000,a6
            lea     BobBlock,a0
            lea     16*16(a0),a1
            lea     16*16*2(a0),a2
.waitBefore:
            btst    #6,$02(a6)
            bne.s   .waitBefore
            move.w  #$0fca,$40(a6)
            move.w  #$0000,$42(a6)
            move.l  a0,$50(a6)
            move.l  a1,$52(a6)
            move.l  a2,$54(a6)
            move.w  #$0000,$64(a6)
            move.w  #$0000,$66(a6)
            move.w  #(16*16)+2,$58(a6)
.waitAfter:
            btst    #6,$02(a6)
            bne.s   .waitAfter
            rts

            SECTION ChipData,DATA,CHIP
BobBlock:
BobSource:  dc.b    $ff,$00,$ff,$00
            dc.b    $00,$ff,$00,$ff
            ds.b    16*16-8
BobMask:    dc.b    $ff,$ff,$ff,$ff
            dc.b    $ff,$ff,$ff,$ff
            ds.b    16*16-8
BobDest:    ds.b    16*16
"""

BITPLANE_SOURCE = """
            SECTION Code,CODE,CHIP
            XDEF    _Start
_Start:
            lea     $dff000,a6
            lea     Bitplane,a0
            move.l  a0,$e0(a6)
            move.w  #$1200,$100(a6)
            move.w  #$0000,$102(a6)
            move.w  #$0200,$96(a6)
            rts

            SECTION ChipData,DATA,CHIP
Bitplane:   ds.b    40*32
"""

SPRITE_SOURCE = """
            SECTION Code,CODE,CHIP
            XDEF    _Start
_Start:
            lea     $dff000,a6
            lea     Sprite0(pc),a0
            move.l  a0,$120(a6)
            move.w  #$8020,$96(a6)
.loop:
            btst    #6,$bfe001
            bne.s   .loop
            rts

Sprite0:
            dc.w    $3050,$3060
            dc.w    $ffff,$0000
            dc.w    $0000,$0000
"""

AUDIO_SOURCE = """
            SECTION Code,CODE,CHIP
            XDEF    _Start
_Start:
            lea     $dff000,a6
            lea     Sample(pc),a0
            move.l  a0,$a0(a6)
            move.w  #4,$a4(a6)
            move.w  #$00c0,$a6(a6)
            move.w  #$0040,$a8(a6)
            move.w  #$8201,$96(a6)
.loop:
            btst    #6,$bfe001
            bne.s   .loop
            move.w  #$0001,$96(a6)
            rts

Sample:
            dc.b    $00,$20,$40,$20,$00,$e0,$c0,$e0
            even
"""

INPUT_SOURCE = """
            SECTION Code,CODE
            XDEF    _Start
_Start:
.loop:
            btst    #6,$bfe001
            bne.s   .loop
            moveq   #0,d0
            rts
"""

INTERRUPT_SOURCE = """
            SECTION Code,CODE
            XDEF    _Start
_Start:
            lea     $dff000,a6
            move.w  #$7fff,$9a(a6)
            move.w  #$0020,$9c(a6)
            move.w  #$c020,$9a(a6)
            move.w  #$0020,$9c(a6)
            move.w  #$7fff,$9a(a6)
            rts
"""

EXEC_SOURCE = """
            SECTION Code,CODE
            XDEF    _Start
_Start:
            move.l  4.w,a6
            lea     GraphicsName(pc),a1
            moveq   #0,d0
            jsr     -408(a6)
            move.l  d0,a1
            beq.s   .done
            move.l  a1,a6
            sub.l   a1,a1
            jsr     -222(a6)
            move.l  4.w,a6
            jsr     -414(a6)
.done:
            moveq   #0,d0
            rts
GraphicsName:
            dc.b    "graphics.library",0
            even
"""

SUBROUTINE_SOURCE = """
            SECTION Code,CODE
            XDEF    ClearWords
ClearWords:
            tst.w   d0
            beq.s   .done
            subq.w  #1,d0
.loop:
            clr.w   (a0)+
            dbf     d0,.loop
.done:
            rts
"""

BOOTBLOCK_SOURCE = """
            SECTION Code,CODE
Boot:
            dc.b    "DOS",0
            dc.l    0
            dc.l    880
Start:
            moveq   #0,d0
            rts
"""

CURATED_ASM_REGRESSIONS.extend(
    capability_records(
        "blitter",
        [
            "Generate a blitter clear that clears a small CHIP bitplane and waits before and after BLTSIZE.",
            "Write a VASM Amiga blitter destination clear using BLTCON0, BLTDPTH, BLTDMOD, and BLTSIZE.",
            "Create a complete AmigaDOS executable that uses the blitter to clear CHIP memory.",
            "Generate a canonical btst #6,$02(a6) blitter clear routine with BLTSIZE start.",
            "Write Amiga 68000 code that clears a bitplane with the blitter, then returns.",
            "Generate an Amiga 68000 assembly program that clears a CHIP memory bitplane with the blitter and waits for completion.",
            "Generate an Amiga 68000 assembly program that copies a small CHIP memory block with the blitter and waits for completion.",
            "Generate an Amiga 68000 assembly program that starts a simple blitter fill operation and waits for completion.",
            "Generate an Amiga 68000 assembly routine that sets up a masked bob blit using source and mask data and waits for completion.",
        ],
        BLITTER_CLEAR_SOURCE,
        [
            "Repair this blitter wait-only answer: it waits on btst #6,$02(a6) and returns without BLTCON0, BLTDPTH, BLTDMOD, or BLTSIZE.",
            "Repair this non-canonical blitter answer: replace btst #14,$02(a6) with btst #6,$02(a6), configure BLTCON0, and start through BLTSIZE.",
            "Repair this blitter copy answer: it compiles but omits BLTSPT, BLTDPT, BLTAMOD, BLTDMOD, and the post-BLTSIZE wait.",
            "Repair this blitter fill answer: it starts BLTSIZE without a pre-blitter btst #6,$02(a6) busy wait.",
            "Repair this masked bob answer: it uses invalid registers d8-d10 and never writes BLTAPT, BLTSPT, and BLTDPT.",
        ],
    )
)

CURATED_ASM_REGRESSIONS.extend(
    capability_records(
        "blitter",
        [
            "Generate an Amiga 68000 assembly program that copies a small CHIP memory block with the blitter and waits for completion.",
            "Write VASM code that copies CHIP source to CHIP destination through BLTSPT, BLTDPT, and BLTSIZE.",
            "Create a complete Amiga blitter copy with waits before and after BLTSIZE.",
        ],
        BLITTER_COPY_SOURCE,
        [
            "Repair this blitter copy answer: it has BLTSIZE but no BLTSPT or BLTDPT pointer setup.",
            "Repair this blitter copy answer: replace btst #14,$02(a6) with btst #6,$02(a6) and add the missing post-BLTSIZE wait.",
        ],
    )
)

CURATED_ASM_REGRESSIONS.extend(
    capability_records(
        "blitter",
        [
            "Generate an Amiga 68000 assembly program that starts a simple blitter fill operation and waits for completion.",
            "Write a VASM blitter fill using BLTCON0, BLTDPT, BLTDMOD, and BLTSIZE.",
            "Create a complete Amiga blitter fill routine with canonical busy waits.",
        ],
        BLITTER_FILL_SOURCE,
        [
            "Repair this blitter fill answer: it omits BLTCON0 at $40(a6) and BLTSIZE at $58(a6).",
            "Repair this blitter fill answer: it uses a single blitter wait instead of waits before and after BLTSIZE.",
        ],
    )
)

CURATED_ASM_REGRESSIONS.extend(
    capability_records(
        "blitter",
        [
            "Generate an Amiga 68000 assembly routine that sets up a masked bob blit using source and mask data and waits for completion.",
            "Write a masked bob blit with BLTSPT, BLTAPT, BLTDPT, and canonical btst #6,$02(a6) waits.",
            "Create a subroutine-style masked bob setup that waits for blitter completion.",
        ],
        BLITTER_MASKED_BOB_SOURCE,
        [
            "Repair this masked bob answer: it compiles but uses non-canonical blitter waits and omits BLTAPT.",
            "Repair this masked bob answer: it emits d8-d10 and never starts the blit through BLTSIZE.",
        ],
    )
)

CURATED_ASM_REGRESSIONS.extend(
    capability_records(
        "bitplane",
        [
            "Generate a one-bitplane Amiga display setup using BPLCON0 and a CHIP bitplane.",
            "Write a complete VASM program that points BPL1 to CHIP memory.",
            "Create an Amiga bitplane display skeleton with BPLCON0 and BPL1 pointer setup.",
            "Generate code that enables one bitplane and stores its data in CHIP memory.",
            "Write Amiga 68000 code for a one-bitplane screen buffer.",
        ],
        BITPLANE_SOURCE,
        [
            "Repair this bitplane answer: it has CHIP data but no BPLCON0 $100(a6) setup.",
            "Repair this bitplane answer: it sets COLOR00 but never writes the BPL1 pointer at $e0(a6).",
        ],
    )
)

CURATED_ASM_REGRESSIONS.extend(
    capability_records(
        "sprite",
        [
            "Generate a sprite 0 display program with sprite data terminated by zero words.",
            "Write VASM code that points SPR0 to CHIP sprite data and exits on left mouse.",
            "Create an Amiga sprite setup example using SPR0 pointer registers.",
            "Generate a complete program that displays sprite 0 from CHIP memory.",
            "Write Amiga 68000 code for a simple hardware sprite.",
        ],
        SPRITE_SOURCE,
        [
            "Repair this sprite answer: it has sprite data but never writes SPR0 pointer registers.",
            "Repair this sprite answer: it omits the dc.w $0000,$0000 sprite terminator.",
        ],
    )
)

CURATED_ASM_REGRESSIONS.extend(
    capability_records(
        "audio",
        [
            "Generate an audio DMA program that plays a short sample on channel 0.",
            "Write Amiga VASM code that configures AUD0LCH, AUD0LEN, AUD0PER, and AUD0VOL.",
            "Create a complete program that enables audio channel 0 DMA for a tiny sample.",
            "Generate an Amiga audio DMA example that exits on left mouse.",
            "Write 68000 code to play a short CHIP sample through AUD0.",
        ],
        AUDIO_SOURCE,
        [
            "Repair this audio answer: it has sample bytes but no AUD0LCH/AUD0LEN/AUD0PER/AUD0VOL setup.",
            "Repair this audio answer: it configures AUD0 registers but never enables audio DMA through DMACON.",
        ],
    )
)

CURATED_ASM_REGRESSIONS.extend(
    capability_records(
        "input",
        [
            "Generate a program that polls the left mouse button through CIAA and exits when pressed.",
            "Write an Amiga input polling loop using $bfe001.",
            "Create a complete VASM executable that waits for left mouse using CIAA.",
            "Generate 68000 code that reads mouse input and returns cleanly.",
            "Write a small Amiga program with a hardware input polling loop.",
        ],
        INPUT_SOURCE,
        [
            "Repair this input answer: it loops forever but never reads CIAA or joystick hardware.",
            "Repair this mouse answer: it describes left mouse in comments but never uses $bfe001.",
        ],
    )
)

CURATED_ASM_REGRESSIONS.extend(
    capability_records(
        "interrupt",
        [
            "Generate a simple interrupt setup skeleton that writes INTENA and acknowledges INTREQ.",
            "Write Amiga 68000 code that enables and acknowledges a vertical blank interrupt bit.",
            "Create a complete VASM interrupt gate example using $9a(a6) and $9c(a6).",
            "Generate code that demonstrates INTENA setup and INTREQ acknowledgement.",
            "Write an interrupt-safe Amiga skeleton that disables interrupts before returning.",
        ],
        INTERRUPT_SOURCE,
        [
            "Repair this interrupt answer: it writes INTENA but never acknowledges INTREQ.",
            "Repair this interrupt answer: it mentions interrupts but never touches $9a(a6) or $9c(a6).",
        ],
    )
)

CURATED_ASM_REGRESSIONS.extend(
    capability_records(
        "exec",
        [
            "Generate a program that opens graphics.library through Exec and calls LoadView with null.",
            "Write Amiga 68000 code using Exec OldOpenLibrary and CloseLibrary.",
            "Create a complete AmigaDOS executable that calls graphics.library through LVOs.",
            "Generate code that uses 4.w as ExecBase and restores before returning.",
            "Write a system-friendly graphics.library call example in VASM.",
        ],
        EXEC_SOURCE,
        [
            "Repair this Exec answer: it calls an LVO without loading ExecBase from 4.w into a6.",
            "Repair this graphics.library answer: it opens the library but never closes it through Exec.",
        ],
    )
)

CURATED_ASM_REGRESSIONS.extend(
    capability_records(
        "bootblock",
        [
            "Generate an Amiga bootblock skeleton with a DOS signature and root block longword.",
            "Write a bootblock-shaped VASM source containing DOS, checksum placeholder, and root block 880.",
            "Create a minimal Amiga bootblock layout with a clean boot entry.",
            "Generate a DOS bootblock header and stub 68000 code.",
            "Write an Amiga bootblock skeleton suitable for later checksum filling.",
        ],
        BOOTBLOCK_SOURCE,
        [
            "Repair this bootblock answer: it lacks the DOS signature.",
            "Repair this bootblock answer: it lacks the root block longword 880.",
        ],
    )
)

CURATED_ASM_REGRESSIONS.extend(
    capability_records(
        "subroutine",
        [
            "Generate a reusable Amiga 68000 subroutine that clears d0 words starting at a0.",
            "Write a callable VASM routine named ClearWords that returns with rts.",
            "Create a word clear subroutine using a0 as pointer and d0 as count.",
            "Generate a reusable memory clear routine with a callable label.",
            "Write a compact 68000 subroutine that clears a word-aligned range.",
        ],
        SUBROUTINE_SOURCE,
        [
            "Repair this subroutine answer: it has no callable label.",
            "Repair this subroutine answer: it falls through without rts.",
        ],
    )
)

CURATED_ASM_REGRESSIONS.extend(
    [
        record(
            """
Repair this malformed static copper list. Data directives must not use immediate markers, and the list must terminate with dc.w $ffff,$fffe.

SECTION Code,CODE,CHIP
XDEF _Start
_Start:
    lea $dff000,a6
    lea CopperList(pc),a0
    move.l a0,$80(a6)
    move.w #$0000,$88(a6)
    move.w #$8280,$96(a6)
    rts
CopperList:
    dc.w #$3007,#$fffe,#$0180,#$0f00
""",
            """
            SECTION Code,CODE,CHIP
            XDEF    _Start
_Start:
            lea     $dff000,a6
            lea     CopperList(pc),a0
            move.l  a0,$80(a6)
            move.w  #$0000,$88(a6)
            move.w  #$8280,$96(a6)
            rts

CopperList:
            dc.w    $0100,$0200
            dc.w    $3007,$fffe,$0180,$0f00
            dc.w    $5007,$fffe,$0180,$00f0
            dc.w    $7007,$fffe,$0180,$000f
            dc.w    $ffff,$fffe
""",
        ),
        record(
            """
Repair this bouncing copper answer. It repeats setup writes, never waits for vblank, never checks left mouse, and has no animated copper wait labels.
""",
            """
            SECTION Code,CODE,CHIP
            XDEF    _Start
_Start:
            lea     $dff000,a6
            lea     CopperList(pc),a0
            move.l  a0,$80(a6)
            move.w  #$0000,$88(a6)
            move.w  #$8280,$96(a6)
            moveq   #64,d0
            moveq   #1,d1
.loop:
            bsr.s   WaitVBlank
            move.b  d0,Bar1Wait
            add.w   d1,d0
            cmp.w   #120,d0
            beq.s   .flip
            cmp.w   #40,d0
            bne.s   .mouse
.flip:
            neg.w   d1
.mouse:
            btst    #6,$bfe001
            bne.s   .loop
            rts

WaitVBlank:
            cmp.b   #$ff,$06(a6)
            bne.s   WaitVBlank
.leave:
            cmp.b   #$ff,$06(a6)
            beq.s   .leave
            rts

            ALIGN   2
CopperList:
            dc.w    $0100,$0200
Bar1Wait:  dc.b    64,$07
            dc.w    $fffe,$0180,$0f00
Bar2Wait:  dc.b    80,$07
            dc.w    $fffe,$0180,$00f0
            dc.w    $ffff,$fffe
""",
        ),
        record(
            """
Repair this sprite setup. It writes malformed immediates like #$#$0000 to DMACON, never reads left mouse, and omits the sprite terminator.
""",
            SPRITE_SOURCE,
        ),
    ]
)
