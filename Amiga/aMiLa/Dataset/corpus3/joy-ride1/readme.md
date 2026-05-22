

# Amiga Joystick Demo with Copper Effects

Excellent choice! Starting with joystick input and copper effects is a perfect way to dive into Amiga assembly programming. I'll create a complete example that demonstrates both concepts while being educational and visually rewarding.

```assembly
; Amiga Joystick Demo with Copper Effects
; Assemble with: vasm -m68000 -Fhunkexe -o joystickdemo.exe joystickdemo.asm
; Run on: Amiga 500 (OCS) or higher

    include "hardware/custom.i"    ; Custom chip register definitions
    include "hardware/cia.i"       ; CIA chip register definitions

    ; Constants
    SCREEN_WIDTH     = 320
    SCREEN_HEIGHT    = 200
    SCREEN_DEPTH     = 4          ; 4 bitplanes = 16 colors
    BITPLANE_SIZE    = SCREEN_WIDTH*SCREEN_HEIGHT/8

    ; Structure for our copper list
    structure copperlist,0
    aptr    c_next                  ; Pointer to next copper list
    word    c_jump                  ; Jump instruction
    label   c_instructions          ; Start of copper instructions
    send

    ; Structure for our screen
    structure screen,0
    aptr    s_bitplanes            ; Pointer to bitplanes
    aptr    s_copper                ; Pointer to copper list
    word    s_width,s_height        ; Dimensions
    send

    ; Program code
    section "code",code
    lea     (a6),a5                ; Save base address

    ; Initialize hardware
    jsr     InitHardware

    ; Set up display
    jsr     SetupDisplay

    ; Main program loop
MainLoop:
    ; Read joystick input
    jsr     ReadJoystick

    ; Process input and update display
    jsr     ProcessInput

    ; Wait for vertical blank
    jsr     WaitVBlank

    ; Check if mouse button is pressed to exit
    btst    #6,ciapra+$100(a6)     ; Check left mouse button
    beq.s   MainLoop               ; If not pressed, continue loop

    ; Clean up and exit
    jsr     Cleanup
    move.l  #0,d0                  ; Return code 0
    rts                           ; Return to DOS

; Initialize hardware
InitHardware:
    ; Save old custom registers
    move.l  custom,a0
    move.l  dmaconr(a0),old_dmacon
    move.l  intena(a0),old_intena
    move.l  adkcon(a0),old_adkcon

    ; Disable interrupts and DMA
    move.w  #$7FFF,d0
    move.w  d0,intena(a0)          ; Disable all interrupts
    move.w  d0,dmacon(a0)          ; Disable all DMA

    ; Set up CIA for joystick reading
    move.b  #$00,ciapra+$100(a6)   ; Set CIA port A as input
    move.b  #$00,ciaprb+$100(a6)   ; Set CIA port B as input
    move.b  #$FF,ciaddra+$100(a6)  ; Set all CIA port A lines as input
    move.b  #$FF,ciaddrb+$100(a6)  ; Set all CIA port B lines as input

    rts

; Set up display
SetupDisplay:
    ; Allocate memory for bitplanes
    move.l  #BITPLANE_SIZE*4,d0    ; 4 bitplanes
    move.l  #MEMF_CHIP,d1          ; Allocate in Chip RAM
    jsr     AllocMem
    move.l  d0,screen+s_bitplanes  ; Store bitplane pointer
    beq     Cleanup                ; If allocation failed, exit

    ; Clear bitplanes
    move.l  d0,a1
    move.l  #BITPLANE_SIZE*4/4-1,d1
ClearBitplanes:
    move.l  #0,(a1)+
    dbra    d1,ClearBitplanes

    ; Allocate memory for copper list
    move.l  #1000,d0               ; 1000 bytes for copper list
    move.l  #MEMF_CHIP,d1          ; Allocate in Chip RAM
    jsr     AllocMem
    move.l  d0,screen+s_copper     ; Store copper pointer
    beq     Cleanup                ; If allocation failed, exit

    ; Initialize copper list with basic display setup
    jsr     InitCopperList

    ; Set up colors
    jsr     SetupColors

    ; Enable display DMA
    move.l  custom,a0
    move.w  #$00C0,dmacon(a0)      ; Enable bitplane DMA
    move.w  #$0080,dmacon(a0)      ; Enable copper DMA

    rts

; Initialize copper list
InitCopperList:
    move.l  screen+s_copper,a0
    move.l  a0,a1                  ; a1 = current copper position

    ; Set up display
    move.w  #$00E0,(a1)+           ; BPL1PT high
    move.l  screen+s_bitplanes,d0
    move.w  d0,(a1)+               ; BPL1PT low
    swap    d0
    move.w  d0,(a1)+               ; BPL1PT high

    move.w  #$00E2,(a1)+           ; BPL2PT high
    move.l  screen+s_bitplanes,d0
    add.l   #BITPLANE_SIZE,d0      ; Second bitplane
    move.w  d0,(a1)+               ; BPL2PT low
    swap    d0
    move.w  d0,(a1)+               ; BPL2PT high

    move.w  #$00E4,(a1)+           ; BPL3PT high
    move.l  screen+s_bitplanes,d0
    add.l   #BITPLANE_SIZE*2,d0    ; Third bitplane
    move.w  d0,(a1)+               ; BPL3PT low
    swap    d0
    move.w  d0,(a1)+               ; BPL3PT high

    move.w  #$00E6,(a1)+           ; BPL4PT high
    move.l  screen+s_bitplanes,d0
    add.l   #BITPLANE_SIZE*3,d0    ; Fourth bitplane
    move.w  d0,(a1)+               ; BPL4PT low
    swap    d0
    move.w  d0,(a1)+               ; BPL4PT high

    ; Display mode and control
    move.w  #$0100,$0092(a1)       ; BPLCON0: Bitplanes enabled, HIRES
    move.w  #$0020,$0094(a1)       ; BPLCON1: Scroll = 0
    move.w  #$0000,$0096(a1)       ; BPLCON2: No playfield priority
    move.w  #$0024,$008E(a1)       ; DIWSTART: Display window start
    move.w  #$00C4,$0090(a1)       ; DIWSTOP: Display window stop
    move.w  #$0038,$0092(a1)       ; DDFSTART: Data fetch start
    move.w  #$00D0,$0094(a1)       ; DDFSTOP: Data fetch stop

    ; Set up color registers
    move.w  #$0180,$0180(a1)       ; COLOR00: Background (black)
    move.w  #$0FFF,$0182(a1)       ; COLOR01: White
    move.w  #$0F00,$0184(a1)       ; COLOR02: Red
    move.w  #$00F0,$0186(a1)       ; COLOR03: Green
    move.w  #$000F,$0188(a1)       ; COLOR04: Blue
    move.w  #$0FF0,$018A(a1)       ; COLOR05: Yellow
    move.w  #$0F0F,$018C(a1)       ; COLOR06: Magenta
    move.w  #$00FF,$018E(a1)       ; COLOR07: Cyan

    ; Set up copper jump (to itself for now)
    move.w  #$FFFF,$00FE(a1)       ; COPJMP1
    move.l  a0,$00FC(a1)           ; Jump to start of copper list

    ; Load copper list
    move.l  custom,a0
    move.l  a0,cop1lc(a0)          ; Load copper list pointer

    rts

; Set up colors
SetupColors:
    ; This is a placeholder for more advanced color setup
    ; For now, we're using the colors set in the copper list
    rts

; Read joystick input
ReadJoystick:
    move.l  ciaa,a0                ; CIA-A base address
    move.b  ciapra(a0),d0          ; Read port A (joystick 1)
    move.b  d0,joy1_data           ; Store joystick 1 data

    move.l  ciab,a0                ; CIA-B base address
    move.b  ciapra(a0),d0          ; Read port A (joystick 2/mouse)
    move.b  d0,joy2_data           ; Store joystick 2 data

    rts

; Process input and update display
ProcessInput:
    ; Check joystick 1 buttons
    move.b  joy1_data,d0
    andi.b  #$C0,d0                ; Mask button bits
    beq.s   .NoButton              ; No button pressed

    ; Check which button is pressed
    btst    #6,d0                  ; Check button 1
    beq.s   .CheckButton2
    move.l  #msg_button1,a0        ; Message for button 1
    bra.s   .DisplayMessage

.CheckButton2:
    btst    #7,d0                  ; Check button 2
    beq.s   .NoButton
    move.l  #msg_button2,a0        ; Message for button 2
    bra.s   .DisplayMessage

.NoButton:
    move.l  #msg_none,a0           ; No button message

.DisplayMessage:
    ; Display the message on screen
    jsr     DisplayMessage

    ; Check joystick direction
    move.b  joy1_data,d0
    andi.b  #$0F,d0                ; Mask direction bits
    cmpi.b  #$0F,d0                ; Check if any direction is pressed
    beq.s   .NoDirection           ; No direction pressed

    ; Update copper effect based on direction
    jsr     UpdateCopperEffect

.NoDirection:
    rts

; Display message on screen
DisplayMessage:
    ; This is a simplified text display routine
    ; In a real demo, you would use a proper text rendering system
    
    ; For now, we'll just clear a portion of the screen and draw some pixels
    move.l  screen+s_bitplanes,a0
    add.l   #BITPLANE_SIZE*2,a0    ; Use bitplane 3 for text
    
    ; Clear text area (lines 10-20)
    move.l  #10*40,d0              ; Start at line 10
    add.l   a0,a0
    move.l  a0,a1                  ; a1 = current position
    
    move.l  #10*40/4-1,d1          ; 10 lines * 40 bytes/line / 4 (longwords)
.ClearText:
    move.l  #0,(a1)+
    dbra    d1,.ClearText
    
    ; Draw a simple pattern based on the message
    move.l  a0,a1                  ; a1 = current position
    move.l  #10*40,d0              ; Start at line 10
    add.l   d0,a1
    
    ; Draw a simple indicator
    move.l  #8,d0                  ; 8 lines of text
.DrawLoop:
    move.l  #$FFFFFFFF,(a1)        ; Draw a line
    add.l   #40,a1                 ; Next line
    dbra    d0,.DrawLoop
    
    rts

; Update copper effect based on joystick direction
UpdateCopperEffect:
    move.b  joy1_data,d0
    andi.b  #$0F,d0                ; Mask direction bits
    
    ; Check up
    btst    #0,d0
    beq.s   .CheckDown
    jsr     CopperEffectUp
    bra.s   .DoneDirection
    
.CheckDown:
    btst    #1,d0
    beq.s   .CheckLeft
    jsr     CopperEffectDown
    bra.s   .DoneDirection
    
.CheckLeft:
    btst    #2,d0
    beq.s   .CheckRight
    jsr     CopperEffectLeft
    bra.s   .DoneDirection
    
.CheckRight:
    btst    #3,d0
    beq.s   .DoneDirection
    jsr     CopperEffectRight
    
.DoneDirection:
    rts

; Copper effect for up direction
CopperEffectUp:
    move.l  screen+s_copper,a0
    add.l   #80,a0                 ; Skip to where we can insert our effect
    
    ; Create a gradient effect at the top of the screen
    move.l  #20,d0                 ; 20 lines of effect
    move.w  #$0000,d1              ; Start with black
    move.l  #0,d2                  ; Color increment
    
.EffectLoop:
    move.w  #$0180,(a0)+           ; COLOR00 register
    move.w  d1,(a0)+               ; Color value
    
    ; Increment color
    add.w   d2,d1
    add.w   #$0010,d2              ; Increase increment
    
    ; Wait for next line
    move.w  #$0001,(a0)+           ; WAIT
    move.w  #$00FF,(a0)+           ; Horizontal position
    move.w  #$FFFE,(a0)+           ; Vertical position (next line)
    
    dbra    d0,.EffectLoop
    
    rts

; Copper effect for down direction
CopperEffectDown:
    move.l  screen+s_copper,a0
    add.l   #80,a0                 ; Skip to where we can insert our effect
    
    ; Create a gradient effect at the bottom of the screen
    move.l  #20,d0                 ; 20 lines of effect
    move.w  #$0000,d1              ; Start with black
    move.l  #0,d2                  ; Color increment
    
    ; Wait until we're near the bottom
    move.w  #$0001,(a0)+           ; WAIT
    move.w  #$00FF,(a0)+           ; Horizontal position
    move.w  #$00C0,(a0)+           ; Vertical position (near bottom)
    
.EffectLoop:
    move.w  #$0180,(a0)+           ; COLOR00 register
    move.w  d1,(a0)+               ; Color value
    
    ; Increment color
    add.w   d2,d1
    add.w   #$0010,d2              ; Increase increment
    
    ; Wait for next line
    move.w  #$0001,(a0)+           ; WAIT
    move.w  #$00FF,(a0)+           ; Horizontal position
    move.w  #$FFFE,(a0)+           ; Vertical position (next line)
    
    dbra    d0,.EffectLoop
    
    rts

; Copper effect for left direction
CopperEffectLeft:
    move.l  screen+s_copper,a0
    add.l   #80,a0                 ; Skip to where we can insert our effect
    
    ; Create a vertical gradient effect on the left side
    move.l  #20,d0                 ; 20 lines of effect
    move.w  #$0000,d1              ; Start with black
    move.l  #0,d2                  ; Color increment
    
.EffectLoop:
    move.w  #$0180,(a0)+           ; COLOR00 register
    move.w  d1,(a0)+               ; Color value
    
    ; Increment color
    add.w   d2,d1
    add.w   #$0010,d2              ; Increase increment
    
    ; Wait for next line
    move.w  #$0001,(a0)+           ; WAIT
    move.w  #$00FF,(a0)+           ; Horizontal position
    move.w  #$FFFE,(a0)+           ; Vertical position (next line)
    
    dbra    d0,.EffectLoop
    
    rts

; Copper effect for right direction
CopperEffectRight:
    move.l  screen+s_copper,a0
    add.l   #80,a0                 ; Skip to where we can insert our effect
    
    ; Create a vertical gradient effect on the right side
    move.l  #20,d0                 ; 20 lines of effect
    move.w  #$0000,d1              ; Start with black
    move.l  #0,d2                  ; Color increment
    
    ; Wait until we're at the right side
    move.w  #$0001,(a0)+           ; WAIT
    move.w  #$00C0,(a0)+           ; Horizontal position (right side)
    move.w  #$FFDF,(a0)+           ; Vertical position (any)
    
.EffectLoop:
    move.w  #$0180,(a0)+           ; COLOR00 register
    move.w  d1,(a0)+               ; Color value
    
    ; Increment color
    add.w   d2,d1
    add.w   #$0010,d2              ; Increase increment
    
    ; Wait for next line
    move.w  #$0001,(a0)+           ; WAIT
    move.w  #$00C0,(a0)+           ; Horizontal position (right side)
    move.w  #$FFFE,(a0)+           ; Vertical position (next line)
    
    dbra    d0,.EffectLoop
    
    rts

; Wait for vertical blank
WaitVBlank:
    move.l  custom,a0
    move.w  #$20,$004(a0)          ; Set VB flag in INTREQ
.wait:
    move.w  intreqr(a0),d0
    btst    #5,d0                  ; Check VB flag
    beq.s   .wait                  ; If not set, keep waiting
    
    move.w  #$20,$010(a0)          ; Clear VB flag
    rts

; Clean up and exit
Cleanup:
    ; Restore old custom registers
    move.l  custom,a0
    move.l  old_dmacon,d0
    move.w  d0,dmacon(a0)
    move.l  old_intena,d0
    move.w  d0,intena(a0)
    move.l  old_adkcon,d0
    move.w  d0,adkcon(a0)

    ; Free allocated memory
    move.l  screen+s_bitplanes,a0
    move.l  a0,d0
    beq.s   .NoBitplanes
    move.l  #BITPLANE_SIZE*4,d1    ; Size of bitplanes
    jsr     FreeMem
.NoBitplanes:

    move.l  screen+s_copper,a0
    move.l  a0,d0
    beq.s   .NoCopper
    move.l  #1000,d1               ; Size of copper list
    jsr     FreeMem
.NoCopper:

    rts

; Data section
section "data",data
    ; Screen structure
    ds.b    screen_size
    ; Joystick data
joy1_data:
    dc.b    0
joy2_data:
    dc.b    0
    ; Old custom register values
old_dmacon:
    dc.l    0
old_intena:
    dc.l    0
old_adkcon:
    dc.l    0
    ; Messages
msg_button1:
    dc.b    "Button 1 pressed",0
msg_button2:
    dc.b    "Button 2 pressed",0
msg_none:
    dc.b    "No button pressed",0
```

## Build Instructions

To assemble and run this demo:

1. Save the code as `joystickdemo.asm`
2. Assemble with vasm:
   ```
   vasm -m68000 -Fhunkexe -o joystickdemo.exe joystickdemo.asm
   ```
3. Run in your emulator (vAmiga or FS-UAE)

## How It Works

This program demonstrates several fundamental Amiga programming concepts:

### Hardware Initialization
- Saves and restores custom chip registers
- Sets up the CIA (Complex Interface Adapter) for joystick input
- Disables interrupts and DMA during initialization

### Display Setup
- Allocates memory for 4 bitplanes (16 colors)
- Initializes a copper list to set up the display
- Sets up basic color registers

### Joystick Input
- Reads joystick data from the CIA registers
- Detects button presses and joystick directions
- Joystick 1 is mapped to CIA port A

### Visual Feedback
- Displays a simple pattern when buttons are pressed
- Creates copper effects in different screen regions based on joystick direction:
  - Up: Gradient effect at the top of the screen
  - Down: Gradient effect at the bottom
  - Left: Vertical gradient on the left side
  - Right: Vertical gradient on the right side

### Copper Effects
The copper is a co-processor that can modify hardware registers in sync with the beam position. In this demo, we use it to create color gradients that respond to joystick input. Each direction triggers a different copper effect that modifies the background color in a specific region of the screen.

## Learning Points

This example introduces you to:
1. Amiga hardware registers and their usage
2. Memory allocation and management
3. Copper list programming for visual effects
4. Joystick input handling
5. Basic display setup
6. Vertical blank synchronization
