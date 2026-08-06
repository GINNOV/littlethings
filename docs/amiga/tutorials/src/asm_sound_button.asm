;-----------------------------------------------------
; asm_sound_button.asm
; Interactive Sound Button in 68k Assembly
; - Opens an OS-friendly window on Workbench
; - Draws an interactive UI button
; - Plays 8-bit sound sample via Paula audio hardware
;-----------------------------------------------------
CUSTOM          equ     $DFF000
INTENA          equ     $09A
DMACON          equ     $096
AUD0PTH         equ     $0A0
AUD0LEN         equ     $0A4
AUD0PER         equ     $0A8
AUD0VOL         equ     $0A6

_LVOOpenLibrary  equ    -552
_LVOCloseLibrary equ    -414
_LVOOpenWindow   equ    -222
_LVOCloseWindow  equ    -72
_LVOWait         equ    -468
_LVOGetMsg       equ    -372
_LVOReplyMsg     equ    -378
_LVOSetAPen      equ    -330
_LVOMove         equ    -294
_LVOText         equ    -342
_LVORectFill     equ    -318

    SECTION code,CODE

start:
;--- Open Libraries ---
    move.l  $4.w,a6
    lea     IntuitionName,a1
    moveq   #0,d0
    jsr     _LVOOpenLibrary(a6)
    move.l  d0,IntuitionBase
    beq     cleanup_all

    move.l  $4.w,a6
    lea     GfxName,a1
    moveq   #0,d0
    jsr     _LVOOpenLibrary(a6)
    move.l  d0,GfxBase
    beq     fail_intuition

;--- Open Window ---
    lea     NewWindow,a0
    move.l  IntuitionBase,a6
    jsr     _LVOOpenWindow(a6)
    move.l  d0,Window
    beq     fail_gfx

    move.l  Window,a0
    move.l  116(a0),a1          ; RastPort pointer
    move.l  a1,RastPort

;--- Draw Button ---
    bsr     draw_button_up

;--- Event Loop ---
event_loop:
    move.l  Window,a0
    move.l  108(a0),d0          ; Signal mask
    move.l  $4.w,a6
    jsr     _LVOWait(a6)

    move.l  Window,a0
    move.l  104(a0),a1          ; UserPort
    move.l  $4.w,a6
    jsr     _LVOGetMsg(a6)
    move.l  d0,Message
    beq     event_loop

    move.l  Message,a0
    move.w  20(a0),d0           ; Message Class
    cmp.w   #$0200,d0           ; IDCMP_CLOSEWINDOW ($0200)
    beq     quit

    cmp.w   #$0008,d0           ; IDCMP_MOUSEBUTTONS ($0008)
    bne     reply_msg

    move.l  Message,a0
    move.w  22(a0),d0           ; Code
    cmp.w   #$68,d0             ; SELECTDOWN
    beq     mouse_down
    cmp.w   #$69,d0             ; SELECTUP
    beq     mouse_up

reply_msg:
    move.l  Message,a1
    move.l  $4.w,a6
    jsr     _LVOReplyMsg(a6)
    bra     event_loop

mouse_down:
    bsr     draw_button_down
    bsr     play_sound
    bra     reply_msg

mouse_up:
    bsr     draw_button_up
    bra     reply_msg

quit:
    move.l  Message,a1
    move.l  $4.w,a6
    jsr     _LVOReplyMsg(a6)

;--- Cleanup ---
fail_window:
    move.l  Window,a0
    move.l  IntuitionBase,a6
    jsr     _LVOCloseWindow(a6)
fail_gfx:
    move.l  GfxBase,a1
    move.l  $4.w,a6
    jsr     _LVOCloseLibrary(a6)
fail_intuition:
    move.l  IntuitionBase,a1
    move.l  $4.w,a6
    jsr     _LVOCloseLibrary(a6)
cleanup_all:
    moveq   #0,d0
    rts

;--- Subroutine: Draw Button Up ---
draw_button_up:
    movem.l d1-d3/a1,-(sp)
    move.l  RastPort,a1
    move.l  GfxBase,a6
    move.w  #1,d0               ; Color pen 1
    jsr     _LVOSetAPen(a6)
    move.w  #50,d0
    move.w  #30,d1
    move.w  #270,d2
    move.w  #70,d3
    jsr     _LVORectFill(a6)
    move.w  #2,d0               ; Color pen 2
    jsr     _LVOSetAPen(a6)
    move.w  #110,d0
    move.w  #52,d1
    jsr     _LVOMove(a6)
    lea     button_text,a0
    move.w  #10,d0
    jsr     _LVOText(a6)
    movem.l (sp)+,d1-d3/a1
    rts

;--- Subroutine: Draw Button Down ---
draw_button_down:
    movem.l d1-d3/a1,-(sp)
    move.l  RastPort,a1
    move.l  GfxBase,a6
    move.w  #2,d0               ; Color pen 2
    jsr     _LVOSetAPen(a6)
    move.w  #50,d0
    move.w  #30,d1
    move.w  #270,d2
    move.w  #70,d3
    jsr     _LVORectFill(a6)
    move.w  #1,d0               ; Color pen 1
    jsr     _LVOSetAPen(a6)
    move.w  #110,d0
    move.w  #52,d1
    jsr     _LVOMove(a6)
    lea     button_text,a0
    move.w  #10,d0
    jsr     _LVOText(a6)
    movem.l (sp)+,d1-d3/a1
    rts

;--- Subroutine: Play Sound ---
play_sound:
    lea     CUSTOM,a5
    lea     sound_data,a0
    move.l  a0,AUD0PTH(a5)      ; Set channel 0 sample pointer
    move.w  #sound_len,AUD0LEN(a5) ; Set sample length in words
    move.w  #424,AUD0PER(a5)    ; Period for ~8363 Hz playback
    move.w  #64,AUD0VOL(a5)     ; Volume (0..64)
    move.w  #$8201,DMACON(a5)   ; Enable Audio Channel 0 DMA (Bit 15 SET, Bit 9 DMAEN, Bit 0 AUD0EN)
    rts

;--- Data Section ---
    SECTION data,DATA

IntuitionName: dc.b 'intuition.library',0
GfxName:       dc.b 'graphics.library',0
button_text:   dc.b 'Play Sound',0
    EVEN

IntuitionBase: dc.l 0
GfxBase:       dc.l 0
Window:        dc.l 0
RastPort:      dc.l 0
Message:       dc.l 0

NewWindow:
    dc.w 0,0,320,100            ; Left, Top, Width, Height
    dc.w 1,2                    ; DetailPen, BlockPen
    dc.l $0208                  ; IDCMP Flags (IDCMP_CLOSEWINDOW | IDCMP_MOUSEBUTTONS)
    dc.l $000F                  ; Flags (WFLG_DRAGBAR | WFLG_DEPTHGADGET | WFLG_CLOSEGADGET | WFLG_ACTIVATE)
    dc.l 0,0                    ; FirstGadget, CheckMark
    dc.l window_title,0,0,0,0   ; Title, Screen, BitMap, Min/Max size
    dc.w 1                      ; Type (WBENCHSCREEN)
window_title: dc.b 'Amiga Audio Player',0
    EVEN

;--- Audio Sample Data in Chip RAM ---
    SECTION sound_chip,DATA_C

sound_data:
    ; 8-bit PCM audio sample (square/sine tone burst)
    dc.b 127,127,127,127,127,127,127,127,-128,-128,-128,-128,-128,-128,-128,-128
    dc.b 127,127,127,127,127,127,127,127,-128,-128,-128,-128,-128,-128,-128,-128
    dc.b 100,100,100,100,100,100,100,100,-100,-100,-100,-100,-100,-100,-100,-100
    dc.b  80, 80, 80, 80, 80, 80, 80, 80, -80, -80, -80, -80, -80, -80, -80, -80
    dc.b  60, 60, 60, 60, 60, 60, 60, 60, -60, -60, -60, -60, -60, -60, -60, -60
    dc.b  40, 40, 40, 40, 40, 40, 40, 40, -40, -40, -40, -40, -40, -40, -40, -40
    dc.b  20, 20, 20, 20, 20, 20, 20, 20, -20, -20, -20, -20, -20, -20, -20, -20
    dc.b   0,  0,  0,  0,  0,  0,  0,  0,   0,   0,   0,   0,   0,   0,   0,   0
sound_end:
sound_len equ (sound_end-sound_data)/2
