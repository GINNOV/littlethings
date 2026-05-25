;==============================================================================
; Title:       Amiga CIA-A Timer Setup & Interrupt Handler
; Assembler:   vasmm68k_mot
; Description: Demonstrates how to configure CIA-A Timer A as an interval timer,
;              set the latch value, enable the interrupt, and hook up a standard
;              AmigaOS interrupt handler.
;==============================================================================

    SECTION Code,CODE

; Setup CIA-A Timer A interrupt
; D0 = Interval value (latch)
SetupCIATimer:
    movem.l d2/a5-a6,-(sp)
    move.l  4.w,a6              ; ExecBase

    ; Prepare Interrupt struct
    lea     TimerInt,a1
    move.b  #9,8(a1)            ; LN_TYPE = NT_INTERRUPT (9)
    move.b  #0,9(a1)            ; LN_PRI  = 0
    lea     TimerName(pc),a0
    move.l  a0,10(a1)           ; LN_NAME
    lea     TimerServer(pc),a0
    move.l  a0,18(a1)           ; IS_CODE = pointer to our handler
    sub.l   a0,a0
    move.l  a0,14(a1)           ; IS_DATA = NULL

    ; Add our handler to the PORTS interrupt chain (INTB_PORTS = 13)
    moveq   #13,d0
    jsr     -168(a6)            ; _LVOAddIntServer

    ; Disable OS CIA-A Timer A interrupts during configuration
    lea     $bfe001,a0          ; CIA-A base
    move.b  #$7f,$d00(a0)       ; Disable all CIA-A interrupts (ICR)

    ; Configure Timer A Latch
    move.b  d0,$400(a0)         ; Timer A low byte latch
    lsr.w   #8,d0
    move.b  d0,$500(a0)         ; Timer A high byte latch

    ; Start Timer A in continuous mode
    ; Control Register A (CRA) at $e00:
    ; Bit 0: Start timer (1 = start)
    ; Bit 3: Continuous/one-shot (0 = continuous)
    ; Bit 4: Force load latch (1 = force load once)
    move.b  #$11,$e00(a0)       ; Start Timer, Continuous, Force load

    ; Enable CIA-A Timer A interrupt in the ICR
    move.b  #$81,$d00(a0)       ; Set bit 7 (SET flag) and bit 0 (Timer A)

    movem.l (sp)+,d2/a5-a6
    rts

; Clean up CIA-A Timer A interrupt on exit
CleanupCIATimer:
    movem.l a5-a6,-(sp)
    move.l  4.w,a6              ; ExecBase

    ; Disable CIA-A Timer A interrupt
    lea     $bfe001,a0
    move.b  #$01,$d00(a0)       ; Clear bit 7 (CLEAR flag), clear Timer A interrupt

    ; Remove our interrupt server from PORTS chain
    moveq   #13,d0
    lea     TimerInt,a1
    jsr     -174(a6)            ; _LVORemoveIntServer

    movem.l (sp)+,a5-a6
    rts

; Actual Interrupt Handler routine called by Exec
TimerServer:
    lea     $bfe001,a0
    move.b  $d00(a0),d0         ; Read ICR to check interrupt cause and clear it
    btst    #0,d0               ; Check if Timer A caused it
    beq.s   .not_ours
    
    ; Place your custom tick code here (e.g. increase frame count)
    addq.l  #1,TimerTicks

.not_ours:
    moveq   #0,d0               ; Clear Z-flag to continue interrupt chain
    rts

TimerName:
    dc.b    "CIA-A Timer A Interval Handler",0
    even

    SECTION Data,DATA

TimerTicks:
    dc.l    0

    SECTION BSS,BSS

TimerInt:
    ds.b    22                  ; Size of standard Amiga Struct Interrupt
    even
