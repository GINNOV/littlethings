
                ;------------------ init system -------------------------
                ; kill system taken from the original loader with a
                ; few modifications (i.e. no CIA timers set up and a
                ; generic interrupt handler installed)
init_system                                                         ; original routine address $00001F26
                lea     $00dff000,A6                                ; A6 = custom chip base address
                lea     $00bfd100,A5                                ; A5 = CIAB PRB - used as base address to CIAB
                lea     $00bfe101,A4                                ; A4 = CIAA PRB - used as base address to CIAA

                moveq.l #$00,D0

                move.w  #$7fff,INTENA(A6)                           ; disable interrupts
                move.w  #$1fff,DMACON(A6)                           ; disable DMA
                move.w  #$7fff,INTENA(A6)                           ; disable interrupts again?


                ; enter supervisor mode
                lea.l   .supervisor_trap(PC),A0                     ; A0 = address of supervisor trap $00001F58
                move.l  A0,$00000080                                ; Set TRAP 0 vector
                movea.l A7,A0                                       ; store stack pointer
                trap    #$00                                        ; do the trap (jmp to next instruction in supervisor mode)
                                                                    ; this trap never returns.

                ; enter supervisor mode
                ; D0.l = $00000000
.supervisor_trap                                                    ; original address $00001F58
                movea.l A0,A7                                       ; restore the stack (i.e. rts return address etc)
                move.w  #$0200,BPLCON0(A6)                          ; 0 bitplanes, COLOR_ON=1, low res
                move.w  D0,BPLCON1(A6)                              ; clear delay/scroll registers
                move.w  D0,BPLCON2(A6)                              ; reset sprite/bitplane priorities, genlock etc.
                move.w  D0,COLOR00(A6)                              ; background colour = black
                move.w  #$4000,DSKLEN(A6)                           ; disable disk DMA (as per h/w ref)
                move.l  D0,BLTCON0(A6)                              ; clear BLTCON0 & BLTCON1
                move.w  #$0041,BLTSIZE(A6)                          ; Perform 1 x 1 word blit (DMA off) bit odd.

                move.w  #$8340,DMACON(A6)                           ; enable MASTER,BITPLANE,BLITTER DMA
                move.w  #$7fff,ADKCON(A6)                           ; clear disk controller bits

                ; reset sprites positions
.reset_sprites
                moveq.l #$07,D1                                     ; D1 = counter 7 + 1 (8 sprites)
                lea.l   SPR0POS(A6),A0                              ; A0 = first sprite position
.reset_sprite_loop
                move.w  D0,(A0)
                addq.l #$08,A0                                      ; next sprite pointer
                dbf.w  D1,.reset_sprite_loop                       ; reset next sprite position, $00001F8E

                ; silence audio
.reset_audio
                moveq.l  #$03,D1                                    ; D1 = counter 3 + 1 (4 audio channels)
                lea.l    AUD0VOL(A6),A0                              ; A0 = channel 1 audio volume register.
.reset_audio_loop
                move.w  D0,(A0)                                     ; set audio channel volume to 0
                lea.l   $0010(A0),A0                                ; A0 = next channel audio volume address
                dbf.w   D1,.reset_audio_loop                        ; reset next audio channel volume, $00001F9C

                ; reset CIAA
                ; A4 = CIAA PRB - used as base address to CIAA
.reset_ciaa
                move.b  #$7f,$0c00(A4)                              ; ICR = clear interrupts
                move.b  D0,$0d00(A4)                                ; CRA = clear timer A control bits
                move.b  D0,$0e00(A4)                                ; CRB = clear timer B control bits
                move.b  D0,-$0100(A4)                               ; PRA = clear /LED /OVL (/OVL shouldn't be played with - ROM overlay in memory flag)
                move.b  #$03,$0100(A4)                              ; DDRA = set /LED /OVL as output, set disk status as inputs (as the system intends)
                move.b  D0,(A4)                                     ; PRB = set parallel data lines to 0
                move.b  #$ff,$0200(A4)                              ; DDRB = set direction line to output

                ; reset CIAB
                ; A5 = CIAB PRB - used as base address to CIAB
.reset_ciab
                move.b  #$7f,$0c00(A5)                              ; ICR = clear interrupts
                move.b  D0,$0d00(A5)                                ; CRA = clear Timer A control bits
                move.b  D0,$0e00(A5)                                ; CRB = clear Timer B control bits
                move.b  #$c0,-$0100(A5)                             ; PRA = set keyboard serial /DTR /RTS lines
                move.b  #$c0,$0100(A5)                              ; DDRA = set /DTR /RTS lines to output
                move.b  #$ff,(A5)                                   ; PRB = deselect all drives & motor, /SIDE = Bottom, /DIR = outwards, 
                move.b  #$ff,$0200(A5)                              ; DDRB = set drive control bits to output
.set_exceptions
                lea     interrupt_handler(pc),a0
                move.l  a0,$64
                move.l  a0,$68
                move.l  a0,$6C
                move.l  a0,$70
                move.l  a0,$74
                move.l  a0,$78
 
.joy_test
                move.w  #$ff00,POTGO(A6)                            ; Enable output for Paula Pins on Port 2 (9,5), Port 1 (9,5), set pins high
                move.w  D0,JOYTEST(A6)                             ; D0.W = $DF90 (maybe a bug? D0.l is set above) write to all 4 joystick-mouse counters at once. (JOY0DAT, JOY1DAT)

.reset_drive_motors                
                ; switch drives off
                ; A5 = CIAB PRB - used as base address to CIAB
                or.b    #$ff,(A5)                                   ; deselect disk drives 
                and.b   #$87,(A5)                                   ; latch motors off on drives 0-3
                and.b   #$87,(A5)                                   ; latch motors off on drivee 0-3
                or.b    #$ff,(A5)                                   ; deselect disk drived

.reset_ciaa_timer_b
                ; A4 = CIAA PRB - used as base address to CIAA
                MOVE.B  #$f0,$0500(A4)                              ; Timer B Low Byte
                MOVE.B  #$37,$0600(A4)                              ; Timer B High Byte - 14320 clock ticks = approx 20ms 
                MOVE.B  #$11,$0e00(A4)                              ; Load, Start Timer B continuous mode.

.reset_ciab_timer_b
                ; A5 = CIAB PRB - used as base address to CIAB
                MOVE.B  #$91,$0500(A5)                              ; Timer B Low Byte
                MOVE.B  #$00,$0600(A5)                              ; Timer B High Byte - 145 clock ticks = approx 200us
                MOVE.B  #$00,$0e00(A5)                              ; CRB - clear control reg (Timer B) - not started. (think it's used to trigger a keyboard ack)

.enable_interrupts
                move.w  #$7fff,INTREQ(A6)                           ; Clear Interrupt Request bits
.enable_ciaa_interrupts
                tst.b   $0c00(A4)                                   ; CIAA ICR - clear interrupt flags
                ;MOVE.B  #$8a,$0c00(A4)                              ; CIAA ICR - Enable SP (Keyboard), ALRM (TOD)

.enable_ciab_interrupts
                tst.b   $0c00(A5)                                   ; CIAB ICR - clear interrupt flags
                ;MOVE.B  #$93,$0c00(A5)                              ; CIAB ICR - Enable FLG (DSKINDEX), TB (TimerA), TA (TimerB)
              
.exit_init_system
                ;move.w  #$e078,INTENA(a6)
                move.w  #$2000,sr
                rts


                ;------------- interrupt handler ------------------
                ; just clear any raised interrupt flags and exit
interrupt_handler
                movem.l d0-d7/a0-a6,-(a7)
                lea     $dff000,a6
                move.w  #$7fff,INTREQ(a6)
                movem.l (a7)+,d0-d7/a0-a6
                rte

