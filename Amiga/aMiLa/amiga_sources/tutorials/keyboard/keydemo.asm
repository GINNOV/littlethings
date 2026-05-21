;===============================================================================
; Amiga Key Press Demo with Copper Effects (Corrected)
; Target: Amiga 500 (OCS), 512KB Chip RAM, PAL 50Hz
; Assemble with: vasm -m68000 -Fhunkexe -o keydemo.exe keydemo.asm
;===============================================================================
; Hardware register constants
CUSTOM      equ $DFF000
COP1LCH     equ $DFF080     ; Copper list pointer
BPLCON0     equ $DFF100     ; Bitplane control
BPL1PTH     equ $DFF0E0     ; Bitplane 1 pointer (high)
BPL1PTL     equ $DFF0E2     ; Bitplane 1 pointer (low)
BPL2PTH     equ $DFF0E4     ; Bitplane 2 pointer (high)
BPL2PTL     equ $DFF0E6     ; Bitplane 2 pointer (low)
DIWSTRT     equ $DFF08E     ; Display window start
DIWSTOP     equ $DFF090     ; Display window stop
DDFSTRT     equ $DFF092     ; Display fetch start
DDFSTOP     equ $DFF094     ; Display fetch stop
COLOR00     equ $DFF180     ; Background color
VPOSR       equ $DFF004     ; Beam position read
INTENA      equ $DFF09A     ; Interrupt enable
INTREQ      equ $DFF09C     ; Interrupt request
DMACON      equ $DFF096     ; DMA control
; CIA-A Registers (Keyboard)
CIAICR      equ $BFED01     ; CIA-A Interrupt Control Register
CIAASDR     equ $BFEC01     ; CIA-A Serial Data Register (read)
CIA_SP_FLAG equ 3           ; Serial Port flag bit in CIAICR
;===============================================================================
; Data section (Chip RAM required for screen and copper)
;===============================================================================
    section CHIP,data,chip
; Screen buffer (320x200, 2 bitplanes = 4 colors)
screen:         ds.b 8000
screen_bpl2:    ds.b 8000
screen_size     equ screen_bpl2-screen
; Copper list for a static screen
copper_static:
    dc.w BPL1PTH,(screen>>16)&$FFFF    ; Set Bitplane 1 Pointer (High Word)
    dc.w BPL1PTL,screen&$FFFF          ; Set Bitplane 1 Pointer (Low Word)
    dc.w BPL2PTH,(screen_bpl2>>16)&$FFFF ; Set Bitplane 2 Pointer (High Word)
    dc.w BPL2PTL,screen_bpl2&$FFFF     ; Set Bitplane 2 Pointer (Low Word)
    dc.w DIWSTRT,$2C81                 ; Display window start (PAL)
    dc.w DIWSTOP,$2CC1                 ; Display window stop
    dc.w DDFSTRT,$0038                 ; Data fetch start
    dc.w DDFSTOP,$00D0                 ; Data fetch stop
    dc.w BPLCON0,$2200                 ; 2 bitplanes, low-res, color enabled
    dc.w COLOR00,$0114                 ; Dark blue background
    dc.w $FFFF,$FFFE                   ; Wait for end of frame, then end list
; Copper list for simple color cycle effect
copper_simple:
    dc.w $2C01,$FFFE                   ; Wait for line $2C (start of display)
simple_color_move:
    dc.w COLOR00,$0000                 ; Dynamic color (updated in main loop)
    dc.w $FFFF,$FFFE                   ; Wait for end of frame, then end list
; Copper list for creative "raster bar" effect
copper_creative:
    dc.w $4001,$FFFE,COLOR00,$0000     ; Line 64, Black
    dc.w $5001,$FFFE,COLOR00,$0F00     ; Line 80, Red
    dc.w $6001,$FFFE,COLOR00,$00F0     ; Line 96, Green
    dc.w $7001,$FFFE,COLOR00,$000F     ; Line 112, Blue
    dc.w $8001,$FFFE,COLOR00,$0FF0     ; Line 128, Yellow
    dc.w $9001,$FFFE,COLOR00,$0F0F     ; Line 144, Magenta
    dc.w $A001,$FFFE,COLOR00,$00FF     ; Line 160, Cyan
    dc.w $B001,$FFFE,COLOR00,$0FFF     ; Line 176, White
    dc.w $C001,$FFFE,COLOR00,$0000     ; Line 192, Black
    dc.w $FFFF,$FFFE                   ; Wait end of frame
;===============================================================================
; Data section (Fast RAM is fine for this)
;===============================================================================
    section DATA,data,fast
; Keyboard raw code to ASCII map (incomplete, just for demo)
keymap:
    dc.b " '1234567890-=\`"
    dc.b "qwertyuiop[]"
    dc.b "asdfghjkl;'/"
    dc.b "zxcvbnm,."
    ; This is a simplified map. Raw codes are used as index.
keymap_size equ *-keymap
; Variables
effect_state:   dc.b 0      ; 0=static, 1=simple, 2=creative
color_phase:    dc.w 0      ; For simple effect animation
last_key:       dc.b 0      ; Last pressed ASCII key
key_pressed:    dc.b 0      ; Key press flag
;===============================================================================
; Code section
;===============================================================================
    section CODE,code
start:
    ; We are in supervisor mode, base address of custom chips is in a6
    lea     CUSTOM,a6
    ; --- System Shutdown ---
    move.w  #$7FFF,INTENA(a6)   ; Disable all interrupts
    move.w  #$7FFF,INTREQ(a6)   ; Clear any pending requests
    move.w  #$7FFF,DMACON(a6)   ; Disable all DMA
    move.b  #$7F,CIAICR         ; Disable all CIA-A interrupts
    ; --- Clear Screen ---
    lea     screen,a1
    moveq   #0,d0
    move.w  #(screen_size/4)-1,d1
clear_loop:
    move.l  d0,(a1)+
    dbra    d1,clear_loop
    ; --- Set up Copper and DMA ---
    lea     copper_static,a0
    move.l  a0,COP1LCH(a6)      ; Set Copper list pointer
    move.w  #$8280,DMACON(a6)   ; Enable DMA: Master, Copper, Bitplanes
    ; --- Main loop ---
main_loop:
    bsr     wait_vblank         ; Synchronize with the display frame
    bsr     read_keyboard
    ; Handle key press
    move.b  key_pressed,d0
    beq.s   no_key_action       ; If no key was pressed, skip to effects
    move.b  last_key,d0
    cmpi.b  #'s',d0
    beq.s   activate_simple
    cmpi.b  #'c',d0
    beq.s   activate_creative
    cmpi.b  #'d',d0             ; 'd' for default/static
    beq.s   activate_static
no_key_action:
    ; Update copper effect based on state
    move.b  effect_state,d0
    cmpi.b  #1,d0
    beq.s   run_simple
    cmpi.b  #2,d0
    beq.s   run_creative
    ; --- State 0: Static ---
run_static:
    lea     copper_static,a0
    move.l  a0,COP1LCH(a6)
    bra.s   loop_end
    ; --- State 1: Simple ---
run_simple:
    lea     copper_simple,a0
    move.l  a0,COP1LCH(a6)
    ; Animate color
    move.w  color_phase,d0
    add.w   #$008,d0            ; Animate blue component
    cmpi.w  #$0F0,d0
    blt.s   .no_wrap
    moveq   #0,d0
.no_wrap:
    move.w  d0,color_phase
    move.w  d0,simple_color_move+2 ; Update copper list value
    bra.s   loop_end
    ; --- State 2: Creative ---
run_creative:
    lea     copper_creative,a0
    move.l  a0,COP1LCH(a6)
    bra.s   loop_end
    ; --- Key press activation labels ---
activate_simple:
    move.b  #1,effect_state
    bra.s   loop_end
activate_creative:
    move.b  #2,effect_state
    bra.s   loop_end
activate_static:
    move.b  #0,effect_state
    ; fall through
loop_end:
    bra     main_loop
;===============================================================================
; Subroutines
;===============================================================================
; --- Waits for the vertical blanking interval ---
wait_vblank:
.wait:
    move.b  $DFF006,d0          ; VHPOSR high byte (vertical position bits 7-0)
    cmp.b   #$FA,d0             ; Wait for line 250 (in vblank)
    bne.s   .wait
    rts
; --- Keyboard reading subroutine ---
read_keyboard:
    move.b  #0,key_pressed      ; Assume no key pressed
    ; Check CIA-A if a keycode byte has been received
    btst    #CIA_SP_FLAG,CIAICR ; Test Serial Port flag in Interrupt Control Reg
    beq.s   .no_data            ; No data available
    ; Read raw keycode
    move.b  CIAASDR,d0          ; Get raw keycode from Serial Data Register
    not.b   d0                  ; Invert bits (Amiga keyboard specific)
    ; We only care about key presses (bit 7 clear), not releases
    btst    #7,d0
    bne.s   .no_data            ; It's a key release, ignore it
    ; Convert raw code to ASCII
    lea     keymap,a0
    cmp.b   #keymap_size,d0
    bhs.s   .no_data            ; Key out of our map's range
    move.b  (a0,d0),d0          ; Get ASCII from table
    move.b  d0,last_key
    move.b  #1,key_pressed
.no_data:
    rts