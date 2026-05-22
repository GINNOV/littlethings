;-------------------------------------------------
;  Amiga Parallax + Glitch Demo
;-------------------------------------------------

    SECTION CODE,CODE_C

    INCLUDE "exec/types.i"
    INCLUDE "graphics/gfx.i"
    INCLUDE "graphics/gfxbase.i"
    INCLUDE "hardware/custom.i"
    INCLUDE "hardware/dmabits.i"
    INCLUDE "hardware/intbits.i"

; Exec library vector offsets (LVOs) for functions used
_LVOForbid      EQU -132
_LVOOpenLibrary EQU -552
_LVOPermit      EQU -138

; external ptplayer ------------------------------------------------------------
    XREF  _mt_install, _mt_init, _mt_music, _mt_end, _mt_remove, _mt_playfx
; external data ----------------------------------------------------------------
    XREF  gfxname, TextLeft, TextRight, SfxStruct
    XREF  FontData, CopperNormal, CopperGlitch, bitplane1, bitplane2, AmegasMod
    XREF  BPLCON2_PF2P2  ; Added for playfield priority
;-------------------------------------------------------------------------------

custom      EQU $dff000

SCREEN_W    EQU 320
SCREEN_H    EQU 256
BPL_W       EQU 40
BPL_SIZE    EQU BPL_W*SCREEN_H
FONT_H      EQU 8

;------------------------------------------------------------------------------
;  BSS / variables
;------------------------------------------------------------------------------
    SECTION BSS,DATA

ExecBasePtr:   dc.l 0
GfxBasePtr:    dc.l 0
OldCopper:  dc.l 0
OldVBL:     dc.l 0
OldInt:     dc.l 0
OldDMA:     dc.l 0
Pos1:       dc.w 15
Pos2:       dc.w 0
MeetFlag:   dc.w 0
GlitchFlag: dc.w 0
GlitchTime: dc.w 50

;------------------------------------------------------------------------------
;  CODE
;------------------------------------------------------------------------------
    SECTION CODE,CODE_C

start:
    move.l  4.w,a6
    jsr     _LVOForbid(a6)
    move.l  a6,ExecBasePtr

    lea     gfxname,a1
    jsr     _LVOOpenLibrary(a6)
    move.l  d0,GfxBasePtr
    move.l  d0,a6
    move.l  gb_copinit(a6),OldCopper

    ; Install VBL interrupt handler
    move.l  $6c.w,OldVBL
    lea     VBL(pc),a0
    move.l  a0,$6c.w

    ; kill DMA / interrupts
    move.w  $dff002,OldDMA
    move.w  $dff01c,OldInt
    move.w  #$7fff,$dff09a
    move.w  #$7fff,$dff096

    ; clear bitplanes
    lea     bitplane1,a0
    bsr     ClearBpl
    lea     bitplane2,a0
    bsr     ClearBpl

    ; draw text
    lea     TextLeft,a0
    lea     bitplane1+BPL_W*100+10,a1
    bsr     DrawText
    lea     TextRight,a0
    lea     bitplane2+BPL_W*100+(SCREEN_W/8-20),a1
    bsr     DrawText

    ; build copper lists
    lea     CopperNormal,a0
    bsr     BuildCopper
    lea     CopperGlitch,a0
    bsr     BuildGlitchCopper

    ; start copper
    move.l  #CopperNormal,$dff080
    move.w  #INTF_SETCLR!INTF_VERTB,$dff09a
    move.w  #DMAF_SETCLR!DMAF_MASTER!DMAF_COPPER!DMAF_RASTER,$dff096

    ; start ptplayer
    lea     custom,a6
    moveq   #1,d0
    jsr     _mt_install
    lea     AmegasMod,a0
    move.l  #0,a1
    clr.l   d0
    jsr     _mt_init

MainLoop:
    btst    #6,$bfe001
    bne     MainLoop
    bra     Exit

Exit:
    lea     custom,a6
    jsr     _mt_end
    jsr     _mt_remove

    ; Restore VBL interrupt handler
    move.l  OldVBL,$6c.w

    move.w  #$7fff,$dff09a
    move.w  OldInt,d0
    or.w    #$8000,d0
    move.w  d0,$dff09a
    move.w  #$7fff,$dff096
    move.w  OldDMA,d0
    or.w    #$8000,d0
    move.w  d0,$dff096
    move.l  OldCopper,$dff080

    move.l  ExecBasePtr,a6
    jsr     _LVOPermit(a6)
    clr.l   d0
    rts

;------------------------------------------------------------------------------
;  VBL
;------------------------------------------------------------------------------
VBL:
    movem.l d0-a6,-(sp)
    lea     custom,a6
    jsr     _mt_music

    tst.w   MeetFlag
    bne     .chkGlitch

    subq.w  #1,Pos1
    addq.w  #1,Pos2

    ; coarse scroll
    move.w  Pos1,d0
    and.w   #15,d0
    cmp.w   #15,d0
    bne     .nc1
    add.w   #16,Pos1
    ; Adjust plane1 pointer -2 bytes and update Copper lists
    lea     bitplane1-2,a1
    move.l  a1,d0
    swap    d0
    move.w  d0,CopperNormal+2
    move.w  d0,CopperGlitch+2
    move.w  a1,d0  ; Low word
    move.w  d0,CopperNormal+6
    move.w  d0,CopperGlitch+6
.nc1:
    move.w  Pos2,d0
    and.w   #15,d0
    cmp.w   #0,d0
    bne     .nc2
    sub.w   #16,Pos2
    ; Adjust plane2 pointer +2 bytes and update Copper lists
    lea     bitplane2+2,a1
    move.l  a1,d0
    swap    d0
    move.w  d0,CopperNormal+10
    move.w  d0,CopperGlitch+10
    move.w  a1,d0  ; Low word
    move.w  d0,CopperNormal+14
    move.w  d0,CopperGlitch+14
.nc2:

    ; fine scroll
    move.w  Pos1,d0
    and.w   #15,d0
    move.w  Pos2,d1
    and.w   #15,d1
    lsl.w   #4,d1
    or.w    d0,d1
    move.w  d1,$dff102

    ; collision?
    move.w  Pos1,d0
    cmp.w   Pos2,d0
    ble     .noMeet
    move.w  #1,MeetFlag
    bsr     PlaySnd
    move.w  #1,GlitchFlag
    move.l  #CopperGlitch,$dff080
.noMeet:

.chkGlitch:
    tst.w   GlitchFlag
    beq     .vblEnd
    subq.w  #1,GlitchTime
    bne     .vblEnd
    clr.w   GlitchFlag
    move.l  #CopperNormal,$dff080
.vblEnd:
    move.w  #INTF_VERTB,$dff09c
    movem.l (sp)+,d0-a6
    rte

;------------------------------------------------------------------------------
;  Sub-routines
;------------------------------------------------------------------------------
PlaySnd:
    lea     custom,a6
    lea     SfxStruct,a0
    jsr     _mt_playfx
    rts

ClearBpl:
    move.l  #BPL_SIZE/4-1,d0
.clr:   clr.l   (a0)+
    dbra    d0,.clr
    rts

DrawText:
    moveq   #0,d1
.loop:  move.b  (a0)+,d1
    beq     .done
    sub.b   #' ',d1
    lsl.w   #3,d1
    lea     FontData,a2
    add.w   d1,a2
    moveq   #FONT_H-1,d2
.ln:    move.b  (a2)+,(a1)
    add.l   #BPL_W,a1
    dbra    d2,.ln
    sub.l   #BPL_W*FONT_H,a1
    addq.l  #1,a1
    bra     .loop
.done:  rts

BuildCopper:
    lea     CopperNormal,a0

    ; bitplane pointers
    lea     bitplane1,a1
    move.l  a1,d0
    move.w  #$0e0,(a0)+  ; bpl1pth
    swap    d0
    move.w  d0,(a0)+
    move.l  a1,d0
    move.w  #$0e2,(a0)+  ; bpl1ptl
    move.w  d0,(a0)+

    lea     bitplane2,a1
    move.l  a1,d0
    move.w  #$0e4,(a0)+  ; bpl2pth
    swap    d0
    move.w  d0,(a0)+
    move.l  a1,d0
    move.w  #$0e6,(a0)+  ; bpl2ptl
    move.w  d0,(a0)+

    move.w  #$100,(a0)+  ; bplcon0
    move.w  #$4200,(a0)+  ; 2 planes, dual-PF, lores
    move.w  #$102,(a0)+  ; bplcon1
    move.w  #0,(a0)+
    move.w  #$104,(a0)+  ; bplcon2
    move.w  BPLCON2_PF2P2,(a0)+  ; PF2 priority
    move.w  #$092,(a0)+  ; ddfstrt
    move.w  #$0038,(a0)+
    move.w  #$094,(a0)+  ; ddfstop
    move.w  #$00d0,(a0)+
    move.w  #$08e,(a0)+  ; diwstrt
    move.w  #$2c81,(a0)+
    move.w  #$090,(a0)+  ; diwstop
    move.w  #$f4c1,(a0)+
    move.w  #$180,(a0)+  ; color00
    move.w  #0,(a0)+
    move.w  #$182,(a0)+  ; color01
    move.w  #$FFF,(a0)+
    move.w  #$188,(a0)+  ; color04
    move.w  #$F00,(a0)+
    move.w  #$18a,(a0)+  ; color05
    move.w  #$0F0,(a0)+
    move.l  #$FFFFFFFE,(a0)+
    rts

BuildGlitchCopper:
    lea     CopperGlitch,a0
    lea     CopperNormal,a1
    move.w  #25,d0
.copy:  move.w  (a1)+,(a0)+
    dbra    d0,.copy

    moveq   #SCREEN_H/4-1,d1
    move.w  #$4001,d2
.loop:  move.w  d2,(a0)+
    move.w  #$FFFE,(a0)+
    move.w  #$102,(a0)+  ; bplcon1
    move.w  d2,d3
    add.w   #$0020,d3
    and.w   #$00F0,d3
    move.w  d3,(a0)+
    add.w   #$0400,d2
    dbra    d1,.loop
    move.l  #$FFFFFFFE,(a0)+
    rts

;------------------------------------------------------------------------------
    END