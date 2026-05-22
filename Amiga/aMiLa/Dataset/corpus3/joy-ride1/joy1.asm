; Amiga Joystick Demo with Copper Effects (standalone vasm version, no NDK includes)
; Assemble:
; vasm -m68000 -Fhunkexe -o joystickdemo.exe joy1.asm
; Target: Amiga OCS/ECS/AGA, PAL 50Hz, 512KB Chip

CUSTOM   equ $dff000
CIAA     equ $bfe001
CIAB     equ $bfd000

; Minimal Custom chip register offsets (relative to CUSTOM)
dmaconr   EQU $002
intenar   EQU $01C
intreqr   EQU $01E
joy1dat   EQU $00C
adkconr   EQU $010
potinp    EQU $016
potgo     EQU $034

cop1lc    EQU $080
diwstrt   EQU $08E
diwstop   EQU $090
ddfstrt   EQU $092
ddfstop   EQU $094
dmacon    EQU $096
intena    EQU $09A
intreq    EQU $09C
adkcon    EQU $09E

bplpt     EQU $0E0      ; plane N: high = bplpt+4*N, low = bplpt+4*N+2
bplcon0   EQU $100
bplcon1   EQU $102
bplcon2   EQU $104
bpl1mod   EQU $108
bpl2mod   EQU $10A

color     EQU $180      ; color K = color + 2*K

; CIA register offsets (relative to base CIAA/CIAB)
ciapra    EQU $000
ciaprb    EQU $100
ciaddra   EQU $200
ciaddrb   EQU $300

SCREEN_WIDTH     = 320
SCREEN_HEIGHT    = 200
SCREEN_DEPTH     = 4
BITPLANE_SIZE    = (SCREEN_WIDTH/8)*SCREEN_HEIGHT
COPPER_SIZE      = 2048

; Exec jump table vectors (absolute, A6 = ExecBase)
LVOSupervisor    = -30
LVOAllocMem      = -198
LVOFreeMem       = -210

; Alloc record offsets
screen_bitplanes = 0
screen_copper    = 4
screen_size      = 8

    section "code",code

start:
    movem.l d2-d7/a2-a6,-(sp)
    move.l  4.w,a6

    jsr     InitHardware
    jsr     SetupDisplay
    tst.l   d0
    beq     Cleanup

MainLoop:
    jsr     ReadJoystick
    jsr     ProcessInput
    jsr     WaitVBlank

    move.b  CIAA+ciapra,d0
    btst    #6,d0              ; Left mouse button to quit
    bne.s   MainLoop

Cleanup:
    jsr     RestoreHardware
    jsr     FreeResources
    movem.l (sp)+,d2-d7/a2-a6
    moveq   #0,d0
    rts

InitHardware:
    lea     CUSTOM,a5
    move.w  dmaconr(a5),old_dmacon
    move.w  intenar(a5),old_intena
    move.w  adkconr(a5),old_adkcon
    move.w  #$7fff,dmacon(a5)
    move.w  #$7fff,intena(a5)
    move.b  #$00,CIAA+ciaddra
    move.b  #$00,CIAA+ciaddrb
    move.b  #$00,CIAB+ciaddra
    move.b  #$00,CIAB+ciaddrb
    rts

RestoreHardware:
    lea     CUSTOM,a5
    move.w  old_dmacon,d0
    or.w    #$8000,d0
    move.w  d0,dmacon(a5)
    move.w  old_intena,d0
    or.w    #$8000,d0
    move.w  d0,intena(a5)
    move.w  old_adkcon,d0
    or.w    #$8000,d0
    move.w  d0,adkcon(a5)
    rts

FreeResources:
    move.l  screen_data+screen_bitplanes,d0
    beq.s   .no_bpl
    move.l  d0,a1
    move.l  #BITPLANE_SIZE*SCREEN_DEPTH,d0
    jsr     LVOFreeMem(a6)
.no_bpl:
    move.l  screen_data+screen_copper,d0
    beq.s   .no_cop
    move.l  d0,a1
    move.l  #COPPER_SIZE,d0
    jsr     LVOFreeMem(a6)
.no_cop:
    rts

SetupDisplay:
    move.l  #BITPLANE_SIZE*SCREEN_DEPTH,d0
    move.l  #$10000000|$00010000,d1   ; MEMF_CHIP|MEMF_CLEAR
    jsr     LVOAllocMem(a6)
    tst.l   d0
    beq.s   .fail
    move.l  d0,screen_data+screen_bitplanes

    move.l  #COPPER_SIZE,d0
    move.l  #$10000000,d1            ; MEMF_CHIP
    jsr     LVOAllocMem(a6)
    tst.l   d0
    beq.s   .free_bpl
    move.l  d0,screen_data+screen_copper

    jsr     BuildBaseCopper

    ; Load copper: write low then high to `cop1lc`
    move.l  screen_data+screen_copper,d0
    move.w  d0,cop1lc(a5)
    swap    d0
    move.w  d0,cop1lc(a5)

    move.w  #$8380,dmacon(a5)        ; SET + MASTER + BPL + COP
    moveq   #1,d0
    rts

.free_bpl:
    move.l  screen_data+screen_bitplanes,d0
    beq.s   .fail
    move.l  d0,a1
    move.l  #BITPLANE_SIZE*SCREEN_DEPTH,d0
    jsr     LVOFreeMem(a6)
.fail:
    moveq   #0,d0
    rts

BuildBaseCopper:
    move.l  screen_data+screen_copper,a0
    move.l  a0,a1

    ; Bitplane pointers using `bplpt` base with offsets
    move.l  screen_data+screen_bitplanes,d0

    ; Plane 0
    move.w  #bplpt,(a1)+                 ; high word register
    move.l  d0,d2
    swap    d2
    move.w  d2,(a1)+
    move.w  #bplpt+2,(a1)+               ; low word register
    move.w  d0,(a1)+
    add.l   #BITPLANE_SIZE,d0

    ; Plane 1
    move.w  #bplpt+4,(a1)+
    move.l  d0,d2
    swap    d2
    move.w  d2,(a1)+
    move.w  #bplpt+6,(a1)+
    move.w  d0,(a1)+
    add.l   #BITPLANE_SIZE,d0

    ; Plane 2
    move.w  #bplpt+8,(a1)+
    move.l  d0,d2
    swap    d2
    move.w  d2,(a1)+
    move.w  #bplpt+10,(a1)+
    move.w  d0,(a1)+
    add.l   #BITPLANE_SIZE,d0

    ; Plane 3
    move.w  #bplpt+12,(a1)+
    move.l  d0,d2
    swap    d2
    move.w  d2,(a1)+
    move.w  #bplpt+14,(a1)+
    move.w  d0,(a1)+

    ; Display controls
    move.w  #bplcon0,(a1)+
    move.w  #$4200,(a1)+                ; 4 planes, color, 320 wide
    move.w  #bplcon1,(a1)+
    move.w  #$0000,(a1)+
    move.w  #bplcon2,(a1)+
    move.w  #$0000,(a1)+
    move.w  #bpl1mod,(a1)+
    move.w  #$0000,(a1)+
    move.w  #bpl2mod,(a1)+
    move.w  #$0000,(a1)+

    ; Display window (PAL)
    move.w  #diwstrt,(a1)+
    move.w  #$2c81,(a1)+
    move.w  #diwstop,(a1)+
    move.w  #$f4c1,(a1)+
    move.w  #ddfstrt,(a1)+
    move.w  #$0038,(a1)+
    move.w  #ddfstop,(a1)+
    move.w  #$00d0,(a1)+

    ; Base colors (use `color + 2*n`)
    move.w  #color+0,(a1)+
    move.w  #$000,(a1)+
    move.w  #color+2,(a1)+
    move.w  #$fff,(a1)+
    move.w  #color+4,(a1)+
    move.w  #$f00,(a1)+
    move.w  #color+6,(a1)+
    move.w  #$0f0,(a1)+
    move.w  #color+8,(a1)+
    move.w  #$00f,(a1)+
    move.w  #color+10,(a1)+
    move.w  #$ff0,(a1)+
    move.w  #color+12,(a1)+
    move.w  #$f0f,(a1)+
    move.w  #color+14,(a1)+
    move.w  #$0ff,(a1)+

    ; Reserve space for dynamic effects
    add.l   #200,a1

    ; End copper
    move.w  #$ffff,(a1)+
    move.w  #$fffe,(a1)+
    rts

ReadJoystick:
    lea     CUSTOM,a5
    move.w  joy1dat(a5),d0
    and.w   #$0303,d0
    bclr    #8,d0
    beq.s   .z1
    bset    #2,d0
.z1:
    bclr    #9,d0
    beq.s   .z2
    bset    #3,d0
.z2:
    add.w   d0,d0
    move.w  .joy_tableX(pc,d0.w),d1
    move.w  .joy_tableY(pc,d0.w),d2

    clr.b   d3
    cmp.w   #1,d1
    bne.s   .no_right
    bset    #3,d3
.no_right:
    cmp.w   #-1,d1
    bne.s   .no_left
    bset    #2,d3
.no_left:
    cmp.w   #1,d2
    bne.s   .no_down
    bset    #1,d3
.no_down:
    cmp.w   #-1,d2
    bne.s   .no_up
    bset    #0,d3
.no_up:

    move.b  CIAA+ciapra,d0
    btst    #6,d0
    bne.s   .no_fire1
    bset    #7,d3
.no_fire1:

    move.w  #$c000,potgo(a5)
    move.w  potinp(a5),d0
    btst    #14,d0
    bne.s   .no_fire2
    bset    #6,d3
.no_fire2:
    move.w  #0,potgo(a5)

    move.b  d3,joy1_data
    rts

.joy_tableX:
    dc.w    0,0,1,1,0,0,0,1,-1,0,0,0,-1,-1
.joy_tableY:
    dc.w    0,1,1,0,-1,0,0,-1,-1,0,0,0,0,1

ProcessInput:
    move.b  joy1_data,d0
    btst    #7,d0
    bne.s   .button1
    btst    #6,d0
    bne.s   .button2
    move.l  #msg_none,a0
    bra.s   .display
.button1:
    move.l  #msg_button1,a0
    bra.s   .display
.button2:
    move.l  #msg_button2,a0
.display:
    jsr     DisplayMessage

    move.b  joy1_data,d0
    andi.b  #$0f,d0
    btst    #0,d0
    bne     CopperEffectUp
    btst    #1,d0
    bne     CopperEffectDown
    btst    #2,d0
    bne     CopperEffectLeft
    btst    #3,d0
    bne     CopperEffectRight
    rts

DisplayMessage:
    move.l  screen_data+screen_bitplanes,a0
    add.l   #BITPLANE_SIZE*2,a0
    add.l   #(SCREEN_WIDTH/8)*100,a0

    moveq   #7,d1
.clear:
    moveq   #9,d2
.clear_line:
    clr.l   (a0)+
    dbra    d2,.clear_line
    dbra    d1,.clear

    sub.l   #(SCREEN_WIDTH/8)*8,a0
    moveq   #7,d1
.draw:
    move.l  #$ffffffff,(a0)
    move.l  #$ffffffff,4(a0)
    move.l  #$ffffffff,8(a0)
    move.l  #$ffffffff,12(a0)
    move.l  #$ffffffff,16(a0)
    move.l  #$ffffffff,20(a0)
    move.l  #$ffffffff,24(a0)
    move.l  #$ffffffff,28(a0)
    move.l  #$ffffffff,32(a0)
    move.l  #$ffffffff,36(a0)
    add.l   #SCREEN_WIDTH/8,a0
    dbra    d1,.draw
    rts

CopperEffectUp:
    move.l  screen_data+screen_copper,a0
    add.l   #200,a0
    moveq   #99,d7
.cclrU:
    clr.w   (a0)+
    dbra    d7,.cclrU
    sub.l   #200,a0

    moveq   #19,d0
    move.w  #$2c01,(a0)+
    move.w  #$fffe,(a0)+
    move.w  #$000,d1
.u_loop:
    move.w  #color+0,(a0)+
    move.w  d1,(a0)+
    add.w   #$0111,d1
    move.w  #(1<<8)|$01,(a0)+
    move.w  #$fffe,(a0)+
    dbra    d0,.u_loop
    rts

CopperEffectDown:
    move.l  screen_data+screen_copper,a0
    add.l   #200,a0
    moveq   #99,d7
.cclrD:
    clr.w   (a0)+
    dbra    d7,.cclrD
    sub.l   #200,a0

    moveq   #19,d0
    move.w  #$c001,(a0)+
    move.w  #$fffe,(a0)+
    move.w  #$000,d1
.d_loop:
    move.w  #color+0,(a0)+
    move.w  d1,(a0)+
    add.w   #$0111,d1
    move.w  #(1<<8)|$01,(a0)+
    move.w  #$fffe,(a0)+
    dbra    d0,.d_loop
    rts

CopperEffectLeft:
    move.l  screen_data+screen_copper,a0
    add.l   #200,a0
    moveq   #99,d7
.cclrL:
    clr.w   (a0)+
    dbra    d7,.cclrL
    sub.l   #200,a0

    moveq   #19,d0
    move.w  #$2c01,(a0)+
    move.w  #$fffe,(a0)+
    move.w  #$004,d1
.l_loop:
    move.w  #color+0,(a0)+
    move.w  d1,(a0)+
    add.w   #$0001,d1
    move.w  #(1<<8)|$01,(a0)+
    move.w  #$fffe,(a0)+
    dbra    d0,.l_loop
    rts

CopperEffectRight:
    move.l  screen_data+screen_copper,a0
    add.l   #200,a0
    moveq   #99,d7
.cclrR:
    clr.w   (a0)+
    dbra    d7,.cclrR
    sub.l   #200,a0

    moveq   #19,d0
    move.w  #$8001,(a0)+
    move.w  #$fffe,(a0)+
    move.w  #$0a0,d1
.r_loop:
    move.w  #color+0,(a0)+
    move.w  d1,(a0)+
    add.w   #$0001,d1
    move.w  #(1<<8)|$01,(a0)+
    move.w  #$fffe,(a0)+
    dbra    d0,.r_loop
    rts

WaitVBlank:
    lea     CUSTOM,a5
.waitvb1:
    move.w  intreqr(a5),d0
    btst    #5,d0
    beq.s   .waitvb1
    move.w  #$8020,intreq(a5)
    rts

    section "data",data
msg_none:     dc.b " ",0
msg_button1:  dc.b "FIRE1",0
msg_button2:  dc.b "FIRE2",0
    even

    section "bss",bss
old_dmacon:   ds.w 1
old_intena:   ds.w 1
old_adkcon:   ds.w 1

screen_data:
    ds.l 2

joy1_data:    ds.b 1
    even