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
