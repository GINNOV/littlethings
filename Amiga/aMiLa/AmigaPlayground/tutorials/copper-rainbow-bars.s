; ==========================================================
;   Amiga 68000 Copper List Example
;   Generates a classic vertical raster rainbow bar
;   (System-friendly graphics.library takeover)
; ==========================================================
            SECTION    Code,CODE,CHIP       ; Must be in CHIP RAM!
            XDEF       _Start
_Start:
            movem.l    d2-d7/a2-a6,-(sp)    ; Save registers

            ; 1. Open Graphics Library
            move.l     $4.w,a6              ; ExecBase
            lea        gfxName(pc),a1
            moveq      #0,d0
            jsr        -408(a6)             ; OpenLibrary
            move.l     d0,GfxBase
            beq.s      .exit

            ; 2. Shut down OS View/Display (System-friendly loadview)
            move.l     GfxBase(pc),a6
            move.l     34(a6),oldView       ; Save GfxBase->ActiView

            sub.l      a1,a1                ; Load NULL view (turns off OS screen)
            jsr        -222(a6)             ; LoadView(NULL)
            jsr        -270(a6)             ; WaitTOF()
            jsr        -270(a6)             ; Double WaitTOF

            ; 3. Setup Custom Copper List
            lea        $dff000,a5
            lea        CopperList(pc),a0
            move.l     a0,$80(a5)           ; Write COP1LC ($DFF080)
            move.w     #$0000,$88(a5)       ; Strobe COPJMP1 ($DFF088) to activate

            ; Enable copper DMA
            move.w     #$8280,$96(a5)       ; DMACON: set COPEN and DMAEN

.waitButton:
            ; Wait for left mouse button (Port $bfe001, bit 6)
            btst       #6,$bfe001
            bne.s      .waitButton

            ; 4. Restore OS View and Copper
            move.l     GfxBase(pc),a6
            move.l     oldView(pc),a1       ; Load old view pointer
            jsr        -222(a6)             ; LoadView(oldView)
            jsr        -270(a6)             ; WaitTOF()
            jsr        -270(a6)             ; WaitTOF()

            ; Close Graphics Library
            move.l     $4.w,a6
            move.l     GfxBase(pc),a1
            jsr        -414(a6)             ; CloseLibrary

.exit:
            movem.l    (sp)+,d2-d7/a2-a6    ; Restore registers
            moveq      #0,d0                ; Return 0
            rts

gfxName:    dc.b       "graphics.library",0
            EVEN
GfxBase:    dc.l       0
oldView:    dc.l       0

            ALIGN      4
CopperList:
            dc.w       $0100,$0200          ; No planes
            dc.w       $5007,$fffe          ; Wait for line 80
            dc.w       $0180,$0f00          ; Red
            dc.w       $5807,$fffe          ; Wait for line 88
            dc.w       $0180,$0f70          ; Orange
            dc.w       $6007,$fffe          ; Wait for line 96
            dc.w       $0180,$0ff0          ; Yellow
            dc.w       $6807,$fffe          ; Wait for line 104
            dc.w       $0180,$00f0          ; Green
            dc.w       $7007,$fffe          ; Wait for line 112
            dc.w       $0180,$00ff          ; Cyan
            dc.w       $7807,$fffe          ; Wait for line 120
            dc.w       $0180,$000f          ; Blue
            dc.w       $8007,$fffe          ; Wait for line 128
            dc.w       $0180,$0f0f          ; Purple
            dc.w       $8807,$fffe          ; Wait for line 136
            dc.w       $0180,$0000          ; Black
            dc.w       $ffff,$fffe          ; End of copper list
