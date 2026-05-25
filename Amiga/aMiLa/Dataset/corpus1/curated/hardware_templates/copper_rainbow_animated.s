;==============================================================================
; Title:       Amiga Animated Multicolored Copper List
; Assembler:   vasmm68k_mot
; Description: Takes over graphics, starts a multicolored copper bar that swings
;              up and down the screen, waits for a left mouse click, restores
;              the original OS display state, and exits cleanly.
;==============================================================================

    SECTION Code,CODE

Start:
    move.l  4.w,a6              ; ExecBase pointer
    lea     GfxName(pc),a1      ; Name of library
    moveq   #0,d0               ; Any version
    jsr     -408(a6)            ; _LVOOpenLibrary
    tst.l   d0
    beq     .error
    move.l  d0,GfxBase          ; Save library base pointer
    
    move.l  d0,a6               ; GfxBase to A6
    move.l  $22(a6),OldView     ; Save GfxBase->ActiView for clean restore
    
    sub.l   a1,a1               ; Load NULL view pointer
    jsr     -222(a6)            ; _LVOLoadView(NULL)
    jsr     -270(a6)            ; _LVOWaitTOF
    jsr     -270(a6)            ; _LVOWaitTOF
    
    lea     CopperList,a0       ; Load absolute address of our Copper list
    move.l  a0,$dff080          ; Load into COP1LCH
    
.main_loop:
    move.l  GfxBase,a6          ; GfxBase to A6
    jsr     -270(a6)            ; _LVOWaitTOF
    
    btst    #6,$bfe001          ; Left click is bit 6 of CIAPRA
    beq.s   .exit               ; If pressed, exit cleanly
    
    move.b  y_pos,d0            ; Load current Y position
    move.b  y_speed,d1          ; Load current direction
    add.b   d1,d0               ; Apply movement
    
    cmp.b   #$30,d0
    blt.s   .bounce
    cmp.b   #$e0,d0
    bgt.s   .bounce
    bra.s   .save_y
    
.bounce:
    neg.b   d1                  ; Reverse speed direction
    move.b  d1,y_speed          ; Save reversed speed
    add.b   d1,d0               ; Re-apply correct movement
    
.save_y:
    move.b  d0,y_pos            ; Save updated Y position
    
    lea     CopperList,a0       ; Load absolute address
    
    move.b  d0,(a0)             ; Modify line 1 wait
    addq.b  #1,d0
    move.b  d0,8(a0)            ; Modify line 2 wait
    addq.b  #1,d0
    move.b  d0,16(a0)           ; Modify line 3 wait
    addq.b  #1,d0
    move.b  d0,24(a0)           ; Modify line 4 wait
    addq.b  #1,d0
    move.b  d0,32(a0)           ; Modify line 5 wait
    addq.b  #1,d0
    move.b  d0,40(a0)           ; Modify line 6 wait
    addq.b  #1,d0
    move.b  d0,48(a0)           ; Modify line 7 wait
    addq.b  #1,d0
    move.b  d0,56(a0)           ; Modify line 8 wait
    
    bra.s   .main_loop
    
.exit:
    move.l  GfxBase,a6          ; GfxBase to A6
    move.l  OldView,a1          ; Restore original ActiView
    jsr     -222(a6)            ; _LVOLoadView
    jsr     -270(a6)            ; _LVOWaitTOF
    
    move.l  $26(a6),$dff080     ; GfxBase->copinit points to system copper
    
    move.l  4.w,a6              ; ExecBase
    move.l  GfxBase,a1          ; Library base
    jsr     -414(a6)            ; _LVOCloseLibrary
    
.error:
    moveq   #0,d0               ; Return success/zero
    rts

GfxName:
    dc.b    "graphics.library",0
    even

    SECTION Data,DATA

GfxBase:
    dc.l    0
OldView:
    dc.l    0
y_pos:
    dc.b    $80                 ; Initial scanline coordinate
y_speed:
    dc.b    2                   ; Vertical velocity
    even

    SECTION Copper,DATA_C

CopperList:
    dc.w    $0001,$fffe         ; Wait for line (offset 0)
    dc.w    $0180,$0f00         ; Color00 = Red
    dc.w    $0001,$fffe         ; Wait for line (offset 8)
    dc.w    $0180,$0f80         ; Color00 = Orange
    dc.w    $0001,$fffe         ; Wait for line (offset 16)
    dc.w    $0180,$0ff0         ; Color00 = Yellow
    dc.w    $0001,$fffe         ; Wait for line (offset 24)
    dc.w    $0180,$00f0         ; Color00 = Green
    dc.w    $0001,$fffe         ; Wait for line (offset 32)
    dc.w    $0180,$00ff         ; Color00 = Cyan
    dc.w    $0001,$fffe         ; Wait for line (offset 40)
    dc.w    $0180,$000f         ; Color00 = Blue
    dc.w    $0001,$fffe         ; Wait for line (offset 48)
    dc.w    $0180,$0f0f         ; Color00 = Purple
    dc.w    $0001,$fffe         ; Wait for line (offset 56)
    dc.w    $0180,$0000         ; Color00 = Black
    dc.w    $ffff,$fffe         ; Wait for unreachable line
