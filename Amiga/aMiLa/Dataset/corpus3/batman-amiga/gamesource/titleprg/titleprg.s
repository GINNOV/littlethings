             
                ; Title Screen
                ; ------------
                ; Title_Screen_Start            - $0001c000   - First Game Title Screen Start
                ;                               - $0001c004   - End Game Title Screen Start (Game Over/Game Completion)
                ;
                ;
                ; Music Player
                ; ------------
                ; Initialise_Music_Player       - $00004000
                ; Silence_All_Audio             - $00004004
                ; Init_Song                     - $00004010 - D0.l = Song Number to play (0-3, 0 = stop playing)
                ; Play_Song                     - $00004018 - Call every frame/cycle to play song
                ;
                ;
                ; VSCode Plugins
                ;----------------
                ; Requires the 'amiga assembly' plugin in order to build and run.
                ;
                ;
                ; VSCode Test Build
                ;-------------------
                ; - 1) Ensure that the 'TEST_TITLEPRG' defintion below is defined.
                ;
                ; - 2) Select the 'Run/Start Debugging' or 'Run/Start without debugging' option from the menu.
                ;
                ;
                ; Absolute Build
                ;----------------
                ; - 1) Comment out the 'TEST_TITLEPRG' definition below.
                ;
                ; - 2) Run the Task 'amigaassembly: build-absolute'
                ;       - This will create an absolte file org $3FFC called 'titleprg.o' in the /build folder
                ;
                ; - 3) This binary file can then be crunched with shrinkler or zxo and copied to the rellevent .adf fr testing.
                ; 


                section titleprg_iff,code_c
                ;opt     o-


                ;--------------------- includes and constants ---------------------------
                INCDIR  "include"
                INCLUDE "hw.i"

TEST_TITLEPRG SET 1             ; run a test build with imported GFX
DEBUG_TYPER   SET 1             ; when set - updated text type on the title screen.
VBLANK_FIX    SET 1             ; Implement VBLANK FIX (remove processor wait from raster wait routine) 
TEST_JOKER    SET 1             ; start with joker screen, comment out to start with batman screen


        IFND TEST_TITLEPRG
                org     $3ffc                                           ; original load address $3FFC
        ENDC


        IFND TEST_TITLEPRG
DISPLAY_BITPLANE_ADDRESS        EQU     $63190                          ; address of display bitplanes in memory
ASSET_CHARSET_BASE              EQU     $3f1ea                          ; address of charset in memory
JOKER_GFX                       EQU     $49C40
BATMAN_GFX                      EQU     $56460
        ELSE
DISPLAY_BITPLANE_ADDRESS        EQU     test_display
ASSET_CHARSET_BASE              EQU     test_bitplanes-$4c                 ; address of charset in memory
JOKER_GFX                       EQU     test_bitplanes+$AA06
BATMAN_GFX                      EQU     test_bitplanes+$1722A
        ENDC

                                         ; Comment this to remove 'test'

        IFD TEST_TITLEPRG  

kill_system
                lea     $dff000,a6
                move.w  #$7fff,INTENA(a6)
                move.w  #$7fff,DMACON(a6)
                move.w  #$7fff,INTREQ(a6)   
                lea     kill_system,a7                              ; initialise stack 
                lea     .mouse_loop,a1
                bsr     init_system

.mouse_loop
                ;subq    #1,d0
                ;move.w  d0,$dff180
                ;btst    #$6,$bfe001
                ;bne.s   .mouse_loop

.start_title_screen
                ;jmp     title_screen_start                      ; Entry point $0001c000
                jmp     end_game_start


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



        ENDC


                ;-------------------------- title prg start -----------------------------
                ; The original binaries of the game start with a long word that provide
                ; the load/address of the file.
titleprg_start
        dc.l    $00004000                                       ; original start address $00003FFC





                ;****************************************************************************************************************
                ;****************************************************************************************************************
                ;****************************************************************************************************************
                ;
                ;
                ;               NEW ENTRY POINT TO TITLE SCREEN 
                ;               Added to have known entry points into the title screen (updated new loader to compensate)
                ;
                ;
                ;****************************************************************************************************************
                ;****************************************************************************************************************
                ;****************************************************************************************************************
                ;------------------------ TITLE SCREEN ENTRY POINT ---------------------------
                ;jmp   title_screen_start                        ; original address jmp $0001c000
                ;-------------------- GAME OVER/COMPLETION ENTRY POINT -----------------------
                ;jmp   end_game_start                            ; original address jmp $0001c006




                ;****************************************************************************************************************
                ;****************************************************************************************************************
                ;****************************************************************************************************************
                ;
                ;
                ;
                ;               MUSIC/SOUND Player Routines
                ;
                ;
                ;
                ;****************************************************************************************************************
                ;****************************************************************************************************************
                ;****************************************************************************************************************




                ;----------------------------- Music Player Jump Table ------------------------------
Initialise_Music_Player                                         ; original routine address $00004000
                bra.w   do_initialise_music_player              ; jmp $00004180
Silence_All_Audio                                               ; original routine address $00004004
                bra.w   do_silence_all_audio                    ; calls $00004194
Stop_Audio                                                      ; original address $00004008
                bra.w   do_stop_audio                           ; $000041e0
Stop_Audio_2                                                    ; original address $0000400c
                bra.w   do_stop_audio                           ; $000041e0
Init_Song                                                       ; original routine address $00004010
                bra.w   do_init_song                            ; calls $0000423e, ; IN: D0.l (song/sound to play)
L00004014       
                bra.w   L00004222
Play_Song                                                       ; original routine address $00004018
                bra.w   do_play_song                            ; $000042f6


                even
master_audio_volume_mask_1                                      ; original address L0000401c
                dc.w    $ffff                                   ; master channel volume mask 1
master_audio_volume_mask_2                                      ; original address L0000401e
                dc.w    $ffff                                   ; master channel volume mask 2


L00004020       dc.w    $8000                                   ; cleared when audio is silenced


song_number                                                     ; original address $00004022
                dc.b    $01                                     ; sound/song to play - initialised to $00
L00004023       dc.b    $00                                     ; initialised to $00




                ; ------ channel/voice data structs --------
                ; offset | desc
                ; 0x0000 | bit 15 - init new song ( 1 = init new song)
                ;        | bit 14 - init same song ( 1 = init same song)
                ;        | bit 06 - choose master_volume_mask 1 or 2 (0 = use mask 1, 1 = use mask 2)
                ; 0x003e | 32bit Audio Sample Data Ptr        - AUDxLC
                ; 0x0042 | 16bit Audio Sample Len             - AUDxLEN (sample?/repeat?)
                ; 0x0044 | 32bit Audio Sample Data Ptr        - AUDxLC
                ; 0x0048 | 16bit Audio Sample Len             - AUDxLEN (sample?/repeat?) 
                ; 0x004a | 16bit Audio Frequency Period       - AUDxPER
                ; 0x004c | 16bit channel volume               - AUDxVOL
                ;
                ;

CHANNEL_CTRL_WORD       EQU     $0
CHANNEL_INIT_DATA_PTR   EQU     $2                      ; 32bit address of channel init data (e.g. song_00_chanel_00_init_data)
CHANNEL_CURRENT_DATA_PTR EQU    $6
CHANNEL_MUSIC_DATA_PTR  EQU     $e
CHANNEL_SAMPLE_PTR_A    EQU     $3e
CHANNEL_SAMPLE_LEN_A    EQU     $42
CHANNEL_SAMPLE_PTR_B    EQU     $44
CHANNEL_SAMPLE_LEN_B    EQU     $48
CHANNEL_SAMPLE_PERIOD   EQU     $4a
CHANNEL_VOLUME          EQU     $4c
CHANNEL_CMD_POS         EQU     $52                     ; 16bit value initialised to #$0001

CHANNEL_STATUS_SIZE     EQU     $56                     ; size of structure in bytes

                even
 
channel_1_status                        ; original address L00004024
                dc.w    $8080                           ; 00 - $00 - Control Bits (executing CMD bits etc)
                dc.l    song_00_channel_00_init_data+1  ; 02 - $02 - PTR - Channel Initialisation/CTRL Data ($0001ba1b)
                dc.l    L0001BA1E                       ; 06 - $06 - Current Data PTR32 - Pattern Data - ($0001ba1e)
                dc.l    $00000000                       ; 10 - $0a - 
                dc.l    L0001BA41                       ; 14 - $0e - End of Channel 0 Data - ($0001ba41)
                dc.b    $05                             ; 18 - $12
                dc.b    $00                             ; 19 - $13
                dc.l    L0001B9A6                       ; 20 - $14
                dc.l    L0001B9AA                       ; 24 - $18
                dc.w    $0101                           ; 28 - $1c
                dc.w    $0004                           ; 30 - $1e
                dc.b    $fd                             ; 32 - $20
                dc.b    $00                             ; 33 - $21 - CMD 10 - Param8
                dc.b    $00                             ; 34 - $22 - CMD 10 - Param8
                dc.b    $00                             ; 35 - $23 - CMD 10 - Param8
                dc.b    $00                             ; 36 - $24 - CMD 09 - Param8
                dc.b    $00                             ; 37 - $25 - CMD 09 - Param8
                dc.b    $00                             ; 38 - $26 - CMD 09 - Copy Param8 - $25
                dc.b    $00                             ; 39 - $27 - 
                dc.l    $00000000                       ; 40 - $28 - CMD 14 - PTR32
                dc.l    $00000000                       ; 44 - $2c - CMD 14 - Copy PTR32 
                dc.b    $00                             ; 48 - $30 - CMD 14 - Param8
                dc.b    $00                             ; 49 - $31 - CMD 14 - Copy Param8 $30
                dc.b    $00                             ; 50 - $32 - CMD 14 - Param8
                dc.b    $00                             ; 51 - $33 - CMD 14 - Copy Param8 $32
                dc.b    $00                             ; 52 - $34 - CMD 12 - Param8
                dc.b    $00                             ; 53 - $35 - CMD 12 - Param8
                dc.b    $00                             ; 54 - $36 - CMD 12 - Param8
                dc.b    $00                             ; 55 - $37 - CMD 12 - Copy Param8 $36
                dc.b    $00                             ; 56 - $38 - CMD 12 - Copy Param8 $35
                dc.b    $00                             ; 57 - $39 - CMD 12 - Copy Param8 $35
                dc.w    $0000                           ; 58 - $3a - CMD 12 - Division Result (16 bits)
                dc.w    $0038                           ; 60 - $3c - CMD 17 - Param16   (Volume?)
                dc.l    sample_08+104                   ; 62 - $3e - CMD 17 - PTR32     (sample start - $0000fb6c)
                dc.w    $0666                           ; 66 - $42 - CMD 17 - Param16   (sample len)
                dc.l    silient_repeat                  ; 68 - $44 - CMD 17 - PTR32     (repeat data - $00004d3a)
                dc.w    $0001                           ; 72 - $48 - CMD 17 - Param     (repeat len)
                dc.w    $018f                           ; 74 - $4a -
                dc.w    $0000                           ; 76 - $4c - 
                dc.b    $00                             ; 78 - $4e -
                dc.b    $3a                             ; 79 - $4f - CMD 17 - Working Copy
                dc.b    $3a                             ; 80 - $50 - CMD 10/17 - Working Copy
                dc.b    $06                             ; 81 - $51 - CMD 05 - Param
                dc.w    $0018                           ; 82 - $52 - 16 bits tempo?
                dc.w    $0001                           ; 84 - $54 - Audio DMA?


channel_2_status                                        ; original address L0000407a
                dc.w    $8050
                dc.l    L0001BA27
                dc.l    L0001BA28
                dc.l    $00000000
                dc.l    L0001BB55
                dc.b    $01
                dc.b    $00
                dc.l    L0001B9AC
                dc.l    L0001B9AE
                dc.w    $0101
                dc.w    $0001
                dc.b    $1e
                dc.b    $00
                dc.b    $00
                dc.b    $00
                dc.b    $00
                dc.b    $00
                dc.b    $00
                dc.b    $00
                dc.l    $00000000
                dc.l    $00000000
                dc.b    $00
                dc.b    $00
                dc.b    $00
                dc.b    $00
                dc.b    $00
                dc.b    $00
                dc.b    $00
                dc.b    $00
                dc.b    $00
                dc.b    $00
                dc.w    $0000
                dc.w    $0018
                dc.l    sample_04+104                   ; ($0000ca18)
                dc.w    $0a28
                dc.l    silient_repeat                  ; ($00004d3a)
                dc.w    $0001
                dc.w    $01bf
                dc.w    $001e
                dc.b    $00
                dc.b    $18
                dc.b    $18
                dc.b    $00
                dc.w    $0006
                dc.w    $0002



channel_3_status                                        ; original address L000040d0
                dc.w    $8010
                dc.l    L0001BA2A                       ; ($0001ba2a)
                dc.l    L0001BA2B                       ; ($0001ba2b)
                dc.l    $00000000
                dc.l    L0001BBAE                       ; ($0001bbae)
                dc.b    $01
                dc.b    $00
                dc.l    L0001B9AC                       ; ($0001B9AC)
                dc.l    L0001B9AE                       ; ($0001B9AE)
                dc.w    $0101
                dc.w    $0001
                dc.b    $1e
                dc.b    $00
                dc.b    $00
                dc.B    $00
                dc.b    $00
                dc.b    $00
                dc.b    $00
                dc.b    $00
                dc.l    $00000000
                dc.l    $00000000
                dc.b    $00
                dc.b    $00
                dc.b    $00
                dc.b    $00
                dc.b    $00
                dc.b    $00
                dc.b    $00
                dc.b    $00
                dc.b    $00
                dc.b    $00
                dc.w    $0000
                dc.w    $0011
                dc.l    sample_07+104                   ; ($0000ed94)
                dc.w    $06b8
                dc.l    silient_repeat                  ; ($00004d3a)
                dc.w    $0001
                dc.w    $00d3
                dc.w    $001e
                dc.b    $00
                dc.b    $1e
                dc.b    $1e
                dc.b    $00
                dc.w    $000c
                dc.w    $0004



channel_4_status                                        ; original address L00004126
                dc.w    $8084
                dc.l    L0001BA34                       ; ($0001ba34)
                dc.l    L0001BA37                       ; ($0001ba37)
                dc.l    $00000000
                dc.l    L0001BA41                       ; ($0001ba41)
                dc.b    $05
                dc.b    $00
                dc.l    L0001B9B4                       ; ($0001b9b4)
                dc.l    L0001B9BA+1                     ; ($0001b9bb)
                dc.w    $0101
                dc.w    $0001
                dc.b    $ff
                dc.b    $00
                dc.b    $00
                dc.b    $00
                dc.b    $00
                dc.b    $00
                dc.b    $00
                dc.b    $00
                dc.l    $00000000
                dc.l    $00000000
                dc.b    $00
                dc.b    $00
                dc.b    $00
                dc.b    $00
                dc.b    $01
                dc.b    $03
                dc.b    $14
                dc.b    $00
                dc.b    $06
                dc.b    $05
                dc.w    $0006
                dc.w    $003e
                dc.l    sample_10+104                   ; ($000114ca)
                dc.w    $11d6
                dc.l    sample_10+6422                  ; ($00012de0)
                dc.w    $054b
                dc.w    $0279
                dc.w    $0000
                dc.b    $00
                dc.b    $38
                dc.b    $38
                dc.b    $00
                dc.w    $0018
                dc.w    $0008


.other_data
audio_dma                                               ; original address $0000417c
                dc.w    $0000                           ; Changes to DMACON (Active DMA Channels)
                                                        ; flag cleared on start of frame play routine
                                                        ; also it's or'ed with #$54 of channel status 

L0000417e       dc.w    $0d69                           ; referenced as a word
                                                        ; cleared when playing new song/sound
                                                        ; incremented duting frame play routine every time 4020 is cleared


                even
                ;----------------------------- intitialise music player ------------------------------
do_initialise_music_player                                      ; original routine address $00004180                                                        
                lea.l   default_sample_data,a0                  ; L00004d52,a0
                lea.l   instrument_data,a1                      ; L00004bfa,a1
                bsr.w   init_instruments                        ; calls L000049cc
                bra.w   do_silence_all_audio                    ; jmp $00004194



                ;---------------------------- do silence all audio ----------------------------------
                ; sets all audio channels to 0 volume, probably also stops any playing tracks
                ; by setting values in channel structure and/or values in 4022, 4023
                ;
do_silence_all_audio                                            ; original routine address $00004194
                movem.l d0/a0-a1,-(a7)

                move.b  #$00,song_number                        ; $00004022 - initialising unknown
                move.b  #$00,L00004023                          ; initialising unknown

                lea.l   channel_1_status,a0                     ; $4024,a0
                lea.l   $00dff0a8,a1                            ; a1 = audio volume
                bsr.b   silence_channel_volume                  ; calls $000041c2
                bsr.b   silence_channel_volume                  ; calls $000041c2
                bsr.b   silence_channel_volume                  ; calls $000041c2
                bsr.b   silence_channel_volume                  ; calls $000041c2
                move.w  #$0000,L00004020                        ; enabled DMA channels?
                movem.l (a7)+,d0/a0-a1
                rts                                             ; Where does this go? whats on the stack?



                ;------------ silence channel volume -------------
                ; IN: A0 - channel/voice status data
                ; IN: A1 - AUDxVOL custom register
                ;
silence_channel_volume
                move.w  #$0000,(a0)                             ; set volume in struct
                move.w  #$0001,$004a(a0)                        ; set unknown in struct
                move.w  #$0000,$004c(a0)                        ; set unknown in struct
                move.w  #$0000,(a1)                             ; Volume custom reg = 0
                adda.w  #$0056,a0                               ; update ptr to next channel struct (86 bytes)
                adda.w  #$0010,a1                               ; update to next channel volume register
                rts




                ;----------------------------- do stop audio -----------------------------
                ; Stop Playing Audio, this appears to be another routine that
                ; silences the audio. 
                ;
                ; If song number (d0) is not in range 1-3 then silence audio and exit.
                ;
                ; Called from:
                ;        - do_title_screen_start
                ;
                ; IN: D0.w      - Song Number
                ;
do_stop_audio                                                   ; original routine address $000041e0
                movem.l d0/d7/a0-a2,-(a7)
                subq.w  #$01,d0
                bmi.b   .silence_audio                          ; jmp $000041ee
                cmp.w   #$0003,d0
                bcs.b   .silence_channels                       ; jmp $000041f2 - Never Called as Song number is always in range.
.silence_audio
                bsr.b   do_silence_all_audio                    ; calls $00004194
                bra.b   .exit                                   ; jmp $0000421c

.silence_channels
                lea.l   song_table,a2                           ; L0001b9dc,a2
                asl.w   #$03,d0
                adda.w  d0,a2
                lea.l   channel_1_status,a0                     ; L00004024,a0
                lea.l   $00dff0a8,a1                            ; a1 = AUD0VOL
                moveq   #$03,d7                                 ; d7 = 3 + 1 ; 4 sound channels
.audio_channel_loop
                tst.w   (a2)+                                   ; Test Song Structure Volume - $00004208
                bne.b   .silence_audio_channel                  ; if volume !=0 then silence the channel
                adda.w  #$0056,a0                               ; offset into channel status
                adda.w  #$0010,a1                               ; increment to next AUDxVOL register
                bra.b   .continue                               ; continue loop processing - $00004218
.silence_audio_channel
                bsr.b   silence_channel_volume                  ; calls $000041c2       - L00004216
.continue
                dbf.w   d7,.audio_channel_loop                  ; jmp $00004208         - L00004218
.exit                                                           ; original address $0000421c
                movem.l (a7)+,d0/d7/a0-a2
                rts






                ;------------------------ restart song? ---------------------
                ; restart song/old init song.
                ; **** APPEARS UNUSED ****
                ;
                ; IN:  D0.w - song number?
                ;
                                                        ; original routine address $00004222
L00004222       tst.w   channel_4_status                ; L00004126 ; test a flag - unknown
                beq.b   .continue_execution             ; if flag == 0 then continue execution, jmp $0000422e

                cmp.b   L00004023,d0                    ; compare $4023 with song number? (4023 > d0?)
                bcs.b   .exit                           ; if $4023 > d0

.continue_execution                                     ; original address $0000422e
                movem.l d0/d7/a0-a2,-(a7)
                move.w  #$4000,d1                       ; d1 = unknown (flags?)
                move.b  d0,L00004023                    ; store song number? in $4023?
                bra.b  do_init_current_song             ; calls $0000424a
.exit                                                   ; original address $0000423c
                rts





                ;----------------------- do init song ------------------------
                ; set the current song number, and initialise for playing.
                ; if song number is out of range then stop the audio.
                ;
                ; initialises each audio channel's data ptrs
                ; sets cmd param 82/83
                ; sets $00004020 
                ;
                ; IN: D0.l - sound/song to play?
                ;               - 0 = play nothing/stop
                ;               - >3 = play nothing/stop
                ;
do_init_song                                                    ; original routine address $0000423e
                movem.l d0/d7/a0-a2,-(a7)
                move.w  #$8000,d1                               ; d1 = unknown(flags?)
                move.b  d0,song_number                          ; $00004022
do_init_current_song
                clr.w   L0000417e                               ; clear timer/counter?
.validate_song_number
                subq.w  #$01,d0
                bmi.b   .stop_playing                           ; L00004258
                cmp.w   #$0003,d0                               ; check song number in range 1-3
                bcs.b   .init_song

.stop_playing                                                   ; addr $4258
                bsr.w   do_silence_all_audio                    ; calls $00004194
                bra.w   .exit

.init_song                                                      ; original address $00004260
                lea.l   song_table,a0                           ; $0001b9dc - a0 = base ptr
                asl.w   #$03,d0                                 ; d0 = song no x 8
                adda.w  d0,a0                                   ; a0 = updated base ptr to song table entry

                ;------- init each audio channel -----
.init_channels
                lea.l   channel_1_status,a1                     ; L00004024,a1
                moveq   #$03,d7                                 ; d7 = channel count + 1

                ;------- loop each audio channel ------
.channel_loop                                                   ; original address $00004270
                move.w  (a0)+,d0                                ; d0 = channel offset value (from value address) 
                beq.b   .skip_to_next_channel                   ; if value = 0, jmp $000042e4

                ;------- init audio channel ------
                lea.l   -2(a0,d0.w),a2                          ; a2 = song channel init data
                moveq   #$00,d0
                move.w  d0,CHANNEL_VOLUME(a1)                   ; initialise channel volume
                move.l  d0,CHANNEL_INIT_DATA_PTR(a1)            ; $0002(a1) ; initialise unknown channel status values
                move.l  d0,$000a(a1)                            ; initialise unknown channel status values
                move.b  d0,$0013(a1)                            ; initialise unknown channel status values
                move.b  #$01,$0012(a1)                          ; initialise unknown channel status values
                move.w  d1,CHANNEL_CTRL_WORD(a1)                ; (d1 = 8000/d1 = 4000) initialise unknown channel status values


                ; ------ init channel CMD Process Loop ------
.get_next_byte                                                  ; original address $00004292
                move.b  (a2)+,d0                                ; d0 = song channel init data byte  

                ;------- Check 0x CMD --------
.chk_code_0x                                                    ; addr $000042c8
                bpl.b   .is_code_0x                             ; code is '0x', bit 7 = 0, Play Sample?


                ;------ Check for Loop -----
.chk_code_80                                                    ; addr $00004296
                sub.b   #$80,d0
                bne.b   .chk_code_81


                ;--------- Clear channel CTRL Word ------- 
.is_code_80                                                     ; addr $0000429c
                movea.l CHANNEL_INIT_DATA_PTR(a1),a2
                cmpa.w  #$0000,a2
                bne.b   .get_next_byte
.is_null_ptr
                clr.w   CHANNEL_CTRL_WORD(a1)                   ; reset channel control bits
                bra.b   .skip_to_next_channel                   ; jmp $000042e4


                ;------ Check for Save Ptr ------
.chk_code_81                                                    ; addr $000042aa
                subq.b  #$01,d0
                bne.b   .chk_code_82

                ;--------- CMD Save Ptr --------
                ; used to save address for loop
.is_code_81                                                     ; original address 000042AE
                move.l  a2,CHANNEL_INIT_DATA_PTR(a1)            ; store current channel data ptr
                bra.b   .get_next_byte



                ;------ Check for CMD 82 -------
.chk_code_82                                                    ; addr $000042b4
                subq.b  #$01,d0
                bne.b   .chk_code_83

                ;------- CMD 82 save param -----
.is_code_82                                                     ; original address 000042B8
                move.b  (a2)+,$0013(a1)                         ; initialise unknown channel status values
                bra.b   .get_next_byte                          ; jmp $00004292



                ;------ Check for CMD 83 -------
.chk_code_83                                                    ; addr $000042be
                subq.b  #$01,d0                                 ; original address 000042BE
                bne.b   .get_next_byte

                ;------ CMD 83 save param ------
.is_code_83                                                     ; original address 000042C2
                move.b  (a2)+,$0012(a1)                         ; initialise unknown channel status values
                bra.b   .get_next_byte



                ;----------- CMD 0x --------
                ; d0 = Command (index to channel music data table)
                ; ends the channel initialisation, skips to next channel
                ;
.is_code_0x                                                     ; original address 000042C8
                move.l  a2,CHANNEL_CURRENT_DATA_PTR(a1)         ; $0006(a1) ; store song channel data ptr
                lea.l   song_channel_data_base,a2               ; L0001BA06,a2
                ext.w   d0
                add.w   d0,d0                                   ; d0 = d0 * 2 (another table index)
                adda.w  d0,a2                                   ; add index offset to L0001BA06
                adda.w  (a2),a2
                move.l  a2,CHANNEL_MUSIC_DATA_PTR(a1)           ; $000e(a1) ; ($90,$0B - $90,$0C) - initialise unknown channel status values
                move.w  #$0001,CHANNEL_CMD_POS(a1)              ; $0052(a1) ; initialise command counter/tempo?

.skip_to_next_channel                                           ; addr $000042e4
                lea.l   CHANNEL_STATUS_SIZE(a1),a1              ; $0056(a1),a1
                dbf.w   d7,.channel_loop                        ; loop, jmp $00004270
                or.w    d1,L00004020                            ; (d1 = 8000/d1 = 4000)
.exit                                                           ; addr $000042f0
                movem.l (a7)+,d0/d7/a0-a2
                rts





                ;--------------------------- do play song -----------------------
                ;
do_play_song                                                    ; original routine address $000042f6
                lea.l   $00dff000,a6                            ; a6 = custom base
                lea.l   note_period_table+48,a5                 ; L00004bba ; a5 = mid note frequency table (-48 to + 44)
                clr.w   audio_dma                               ; L0000417c ; clear flag (audio dma)

                tst.w   L00004020                               ; test $4020 (status flags?)
                beq.b   .L00004354                               ; if $4020 == 0 then jmp $00004354

                addq.w  #$01,L0000417e
                clr.w   L00004020                               ; clear $4020 (status flags)

                ; -------- channel 1 ---------
.L00004314                                                      ; original address L00004314            
                lea.l   channel_1_status,a4                     ; a4 = channel 1 status - L00004024,a4
                move.w  CHANNEL_CTRL_WORD(a4),d7                ; d7 = channel current active command bits
                beq.b   .L00004324
.do_commands                                                    ; original address L0000431c
                bsr.b   do_channel_command_loop                 ; L00004360 ; command loop
                move.w  d7,CHANNEL_CTRL_WORD(a4)
                or.w    d7,L00004020

                ; ------- channel 2 ---------
.no_active_commands                                             ; original address L00004324
.L00004324      lea.l   channel_2_status,a4                     ;L0000407a,a4
                move.w  CHANNEL_CTRL_WORD(a4),d7
                beq.b   .L00004334
                bsr.b   do_channel_command_loop                 ; L00004360
                move.w  d7,CHANNEL_CTRL_WORD(a4)
                or.w    d7,L00004020

                ; ------ channel 3 ----------
.L00004334                                                      ; original address .L00004334                
                lea.l   channel_3_status,a4                     ; L000040d0,a4
                move.w  CHANNEL_CTRL_WORD(a4),d7
                beq.b   .L00004344
                bsr.b   do_channel_command_loop                 ; L00004360
                move.w  d7,CHANNEL_CTRL_WORD(a4)
                or.w    d7,L00004020

                ; ------ channel 4 ---------
.L00004344                                                      ; original address .L00004344
                lea.l   channel_4_status,a4                     ;L00004126,a4
                move.w  CHANNEL_CTRL_WORD(a4),d7
                beq.b   .L00004354
                bsr.b   do_channel_command_loop                 ; L00004360
                move.w  d7,CHANNEL_CTRL_WORD(a4)
                or.w    d7,L00004020

.L00004354                                                      ; original address .L00004354 
                and.w   #$c000,L00004020                        ; %1100 = $c (12) mask all apart from top 2 MSBs
                bsr.w   update_audio_custom_registers           ; L00004852
                rts




                ;  IN: a4 = channel status base address
                ;  IN: d7 = channel status CTRL word
                ; OUT: d7 = channel status CTRL word
                ;
do_channel_command_loop                                 ; original address L00004360
                tst.w   $0052(a4)                       ; test 82(a4) - command 8 in progress?
                beq.w   check_command_08                ; if 82(82) == 0 then jmp L000046b2

                subq.w  #$01,$0052(a4)                  ; decrement 82(a4)
                bne.w   check_command_08                ; if > 0 then  jmp L000046b2

                                                        ; 82(a4) reached 0 
                movea.l $000e(a4),a3                    ; a3 = 14(a4) is an address                   
                bclr.l  #$0007,d7                       ; d7 = clear bit 7

play_song_command_loop                                  ; original address L00004378
                move.b  (a3)+,d0                        ; d0 = next music command
                bpl.w   do_command_processing           ; $00004560 ; MSB = 0, jmp $00004560

                bclr.l  #$0003,d7                       ; clear bit 3 on start commands
                cmp.b   #$a0,d0                         ; sub #$a0 from d0
                bcc.b   play_song_command_loop          ; if d0 > #$a0 (160) then loop (ignore command) ,jmp $00004378

                lea.l   jump_table(pc),a0               ; $0014(pc),a0
                sub.b   #$80,d0                         ; d0 = d0 - 128 (max 32 commands)
                ext.w   d0
                add.w   d0,d0                           ; d0 = jump table index
                adda.w  d0,a0                           ; a0 = address of jump table command offset entry
                move.w  (a0),d0                         ; d0 = offset to music command routine.
                beq.b   play_song_command_loop          ; if d0 == 0 then ignore command, jmp $00004378
                jmp     $00(a0,d0.w)                    ; execute music command


                ;---------------- music command jump table (max 32 commands) ------------------
jump_table                                             ; original address $0000439e
                dc.w music_command_01-(jump_table+0)        ; offset - $0040 ; 439E + 40 = 43DE
                dc.w music_command_02-(jump_table+2)      ; offset - $00ba ; 43A0 + BA = 445A 
                dc.w music_command_03-(jump_table+4)      ; offset - $00c0 ; 43A2 + C0 = 4462      
                dc.w music_command_04-(jump_table+6)      ; offset - $00c2 ; 43A4 + C2 = 4466
                dc.w music_command_05-(jump_table+8)      ; offset - $00c4 ; 43A6 + C4 = 446A     
                dc.w music_command_06-(jump_table+10)     ; offset - $00ce ; 43a8 + CE = 4476       
                dc.w music_command_07-(jump_table+12)     ; offset - $00d4 ; 43aa + D4 = 447E
                dc.w music_command_08-(jump_table+14)     ; offset - $00dc ; 43ac + DC = 4488        
                dc.w music_command_09-(jump_table+16)     ; offset - $00ea ; 43ae + ea = 4498
                dc.w music_command_10-(jump_table+18)     ; offset - $00f8 ; 43b0 + f8 = 44A8
                dc.w music_command_11-(jump_table+20)     ; offset - $010a ; 43b2 + 10a = 44BC
                dc.w music_command_12-(jump_table+22)     ; offset - $0140 ; 43b4 + 140 = 44F4
                dc.w music_command_13-(jump_table+24)     ; offset - $0156 ; 43b6 + 156 = 450C
                dc.w music_command_14-(jump_table+26)     ; offset - $010c ; 43b8 + 10c = 44C4
                dc.w music_command_15-(jump_table+28)     ; offset - $0132 ; 43ba + 132 = 44EC
                dc.w music_command_16-(jump_table+30)     ; offset - $0158 ; 43bc + 158 = 4514
                dc.w music_command_17-(jump_table+32)     ; offset - $016e ; 43be + 16e = 452c
                dc.w $0000
                dc.w $0000
                dc.w $0000
                dc.w $0000
                dc.w $0000
                dc.w $0000
                dc.w $0000
                dc.w $0000
                dc.w $0000
                dc.w $0000
                dc.w $0000
                dc.w $0000
                dc.w $0000
                dc.w $0000
                dc.w $0000



music_command_01                                        ; original addrss L000043de
                movea.l $000a(a4),a3
                cmpa.w  #$0000,a3                       ; if a3 != 0 then next command
                bne.b   play_song_command_loop          ; $00004378
                movea.l $0006(a4),a3
                move.b  -$0001(a3),d0
                subq.b  #$01,$0012(a4)
                bne.b   .L00004444
                move.b  #$01,$0012(a4)
                move.b  #$00,$0013(a4)
                
.L00004402                                              ; original address L00004402                
                move.b  (a3)+,d0
                bpl.b   .L00004444
                sub.b   #$80,d0
                bne.b   .L00004426
                movea.l $0002(a4),a3
                cmpa.w  #$0000,a3
                bne.b   .L00004402
                move.w  #$0001,$004a(a4)
                move.w  #$0000,$004c(a4)
                moveq   #$00,d7
                rts  

.L00004426      subq.b  #$01,d0                        ; original address L00004428
                bne.b   .L00004430
                move.l  a3,$0002(a4)
                bra.b   .L00004402

.L00004430      subq.b  #$01,d0                        ; original address L00004430
                bne.b   .L0000443a
                move.b  (a3)+,$0013(a4)
                bra.b   .L00004402

.L0000443a      subq.b  #$01,d0
                bne.b   .L00004402
                move.b  (a3)+,$0012(a4)
                bra.b   .L00004402

.L00004444      move.l  a3,$0006(a4)
                lea.l   song_channel_data_base,a3        ; $0001ba06,a3
                ext.w   d0
                add.w   d0,d0
                adda.w  d0,a3
                adda.w  (a3),a3
                bra.w   play_song_command_loop          ; $00004378


music_command_02                                        ; original address $0000445a
                move.l  a3,$000a(a4)                    ; store current command/song ptr in 10(a4)
                bra.w   play_song_command_loop          ; $00004378


music_command_03                                        ; no operation - original address $00004462
                bra.w   play_song_command_loop          ; $00004378


music_command_04                                        ; no operation - original address $00004466
                bra.w   play_song_command_loop          ; $00004378


music_command_05                                        ; original address $0000446a
                bset.l  #$0005,d7                       ; set status bit 5
                move.b  (a3)+,$0051(a4)                 ; #$51 (81) - store command param in 81(a4)
                bra.w   play_song_command_loop          ; $00004378


music_command_06                                        ; original address $00004476
                bclr.l  #$0005,d7                       ; clear status bit 5
                bra.w   play_song_command_loop          ; $00004378


music_command_07                                        ; original address $0000447e
                add.w   #$0100,$0052(a4)                ; increase offset 84(a4) by 256
                bra.w   play_song_command_loop          ; $00004378


music_command_08                                        ; original address $00004488
                bclr.l  #$0004,d7                       ; clear status bit 4
                bset.l  #$0007,d7                       ; set status bit 7
                clr.w   $004c(a4)                       ; clear word at #$4c (76) 
                bra.w   skip_cmds_09_to_17              ; L0000469c


music_command_09                                        ; original address $00004498
                bset.l  #$0003,d7
                move.b  (a3)+,$0024(a4)                 ; store - command 09 parameter
                move.b  (a3)+,$0025(a4)                 ; store - command 09 parameter
                bra.w   play_song_command_loop          ; $00004378


music_command_10                                        ; original address $000044a8
                and.w   #$fff8,d7                       ; clear bits 0-6 of d7
                bset.l  #$0000,d7
                move.b  (a3)+,$0021(a4)                 ; store - command 10 parameter
                move.b  (a3)+,$0022(a4)                 ; store - command 10 parameter
                bra.w   play_song_command_loop          ; $00004378


music_command_11                                        ; original address $000044bc
                bclr.l  #$0000,d7
                bra.w   play_song_command_loop          ; $00004378


music_command_14                                        ; original address $000044c4
                and.w   #$fff8,d7
                bset.l  #$0001,d7
                lea.l   L0001B986,a0
                moveq   #$00,d0
                move.b  (a3)+,d0
                add.w   d0,d0
                adda.w  d0,a0
                adda.w  (a0),a0
                move.b  (a0)+,$0032(a4)                 ; store parameter
                move.b  (a0)+,$0030(a4)                 ; store parameter
                move.l  a0,$0028(a4)
                bra.w   play_song_command_loop          ; $00004378


music_command_15                                        ; original address $000044ec
                bclr.l  #$0001,d7
                bra.w   play_song_command_loop          ; $00004378

music_command_12                                        ; addr $000044f4
                and.w   #$fff8,d7       
                bset.l  #$0002,d7
                move.b  (a3)+,$0036(a4)
                move.b  (a3)+,$0034(a4)
                move.b  (a3)+,$0035(a4)
                bra.w   play_song_command_loop          ; $00004378


music_command_13                                        ; addr $0000450c
                bclr.l  #$0002,d7
                bra.w   play_song_command_loop          ; $00004378


music_command_16                                        ; addr $00004514
                lea.l   L0001B98C,a0
                moveq   #$00,d0
                move.b  (a3)+,d0
                add.w   d0,d0
                adda.w  d0,a0
                adda.w  (a0),a0
                move.l  a0,$0014(a4) 
                bra.w   play_song_command_loop          ; $00004378


music_command_17                                        ; addr $0000452c
                lea.l   L00004BEA,a0
                moveq   #$00,d0
                move.b  (a3)+,d0
                asl.w   #$04,d0
                adda.w  d0,a0
                move.w  (a0)+,$003c(a4)                 ; volume 
                move.l  (a0)+,$003e(a4)                 ; sample start address
                move.w  (a0)+,$0042(a4)                 ; sample length
                move.l  (a0)+,$0044(a4)                 ; sample repeat address
                move.w  (a0)+,$0048(a4)                 ; sample repeat length   
                bclr.l  #$0006,d7
                tst.w   (a0)
                beq.w   play_song_command_loop          ; $00004378
                bset.l  #$0006,d7
                bra.w   play_song_command_loop          ; $00004378




                ; IN: D0.b = data from command list
                ; IN: D7.l = command status bits
                ;
do_command_processing                                   ; original routine address $00004560
                ; ------ CMD 17 --------
                btst.l  #$0006,d7                       ; test for CMD 17
                bne.b   .not_cmd_17                     ; $0000456a ; no... skip next instruction
.is_cmd_17
                add.b   $0013(a4),d0                    ; #$13 (19) - added to command value
.not_cmd_17                                             ; original address $0000456a
                move.b  d0,$004f(a4)                    ; store copy of current command byte value


                ;------- CMD 10 --------
.chk_cmd_10                                             ; addr $0000456e
                btst.l  #$0000,d7                       ; chk CMD 10
                beq.b   .not_cmd_10
.is_cmd_10
                add.b   $0021(a4),d0                    ; d0 = CMD 10 param 1     - #$21 (33)
                move.b  $0022(a4),$0023(a4)             ; duplcate CMD 10 param 2 - #$22 (34)

.not_cmd_10                                             ; original routine address $0000457e
                move.b  d0,$0050(a4)                    ; update working copy of current command value
                ext.w   d0
                sub.w   $003c(a4),d0                    ; d0 = d0 - CMD 17 param 1  - #$3c (60)
                add.w   d0,d0                           ; d0 = d0 * 2 - relative index to middle of note frequency table $00004bba

.validate_command
                cmp.w   #$ffd0,d0                       ; compare -48
                blt.b   .debug_assert_fail              ; $00004596 ; ******* BRANCH IS NEVER TAKEN *******
                cmp.w   #$002c,d0                       ; compare +44
                ble.b   continue_command_processing_01  ; L000045ac ; this branch is always taken -------->>>>>>>

.debug_assert_fail                                      ; original routine address $00004596
                move.b  $004f(a4),d1                    ; ******* BRANCH IS NEVER TAKEN *******
                move.b  $0050(a4),d2
                move.w  $003c(a4),d3
                move.w  $0054(a4),d4
                movea.l $0006(a4),a2
                illegal                                 ; ******* DEBUG/ASSERT BAD COMMAND




                ; IN: D0.w is index to middle of note frequency table $00004bba (offset range -48 to + 44)
continue_command_processing_01                          ; original address $000045ac
                move.w  $00(a5,d0.w),$004a(a4)          ; lookup note fequency value from $00004bba (range -48 to +44) - frequency/playback speed?

.chk_cmd_12
                btst.l  #$0002,d7                       ; chk CMD 12
                beq.b   continue_command_processing_02  ; $00004612 ; no... skip cmd 12

                ;--------- CMD 12 ---------
.is_cmd_12                                              ; original routine address $000045b8
                move.b  $0050(a4),d0                    ; d0 = copy of command byte
                add.b   $0034(a4),d0                    ; d0 = command byte + cmd 12 parameter
                ext.w   d0
                sub.w   $003c(a4),d0                    ; d0 = d0 - 60
                add.w   d0,d0                           ; d0 = d0 * 2
.validate_command
                cmp.w   #$ffd0,d0                       ; compare -48
                blt.b   .debug_assert_fail              ; L000045D4 ; ******* BRANCH IS NEVER TAKEN *******
                cmp.w   #$002c,d0                       ; compare +44
                ble.b   .continue_cmd12                 ; L000045EA ; this branch is always taken ------>>>>>>>>>

.debug_assert_fail
                move.b  $004f(a4),d1                    ; ******* BRANCH IS NEVER TAKEN *******
                move.b  $0050(a4),d2
                move.w  $003c(a4),d3
                move.w  $0054(a4),d4
                movea.l $0006(a4),a2
                illegal                                 ; ******* DEBUG/ASSERT BAD COMMAND

.continue_cmd12                                         ; original address $45ea
                move.w  $00(a5,d0.w),d0                 ; d0 = note period value from $00004bba
                sub.w   $004a(a4),d0                    ; subtract previous lookup value $4bba
                asr.w   #$01,d0                         ; d0 = d0/2
                ext.l   d0
                move.b  $0035(a4),d1                    ; d1 = CMD 12 param                  
                ext.w   d1                              ; d1 = sign extend
                divs.w  d1,d0                           ; d0 = d0/d1                         
                move.w  d0,$003a(a4)                    ; #$3a (58) - results of divs
                move.b  d1,$0039(a4)                    ; #$39 (57) - working copy of CMD 12 param
                add.b   d1,d1                           ; d1 = d1 * 2
                move.b  d1,$0038(a4)                    ; #$38 (56) - working copy of CMD 12 param * 2
                move.b  $0036(a4),$0037(a4)             ; #$37 (55) - working copy of CMD 12 param 
.end_cmd_12



continue_command_processing_02                          ; original address $00004612
                btst.l  #$0003,d7                       ; chk CMD 09
                beq.b   continue_command_processing_03  ; no... jmp $00004668


                ;---------- CMD 09 ------------
.is_cmd_09                                              ; original address $00004618
                move.b  $0050(a4),d0                    ; d0 = current command byte
                add.b   $0024(a4),d0                    ; d0 = d0 + CMD 09 Param #$24 (36)
                ext.w   d0                              ; 
                sub.w   $003c(a4),d0                    ; d0 = d0 - CMD 17 Param #$3c (60)
                add.w   d0,d0                           ; d0 = d0 * 2

.validate_command                                       ; original address $00004628
                cmp.w   #$ffd0,d0                       ; validate -48
                blt.b   .debug_assert_fail              ; $00004634 ; ******* BRANCH IS NEVER TAKEN *******
                cmp.w   #$002c,d0                       ; validate +44
                ble.b   .continue_cmd_09                ; this branch is always taken ------>>>>>>>>>

.debug_assert_fail                                      ; original address $00004634
                move.b  $004f(a4),d1                    ; ******* BRANCH IS NEVER TAKEN *******
                move.b  $0050(a4),d2
                move.w  $003c(a4),d3
                move.w  $0054(a4),d4
                movea.l $0006(a4),a2
                illegal                                 ; ******* DEBUG/ASSERT BAD COMMAND


.continue_cmd_09                                        ; original address $0000464a
                move.w  $00(a5,d0.w),d0                 ; d0 = note period value from $00004bba

                sub.w   $004a(a4),d0                    ; d0 = d0 - current note period value $00004bba
                ext.l   d0
                moveq   #$00,d1
                move.b  $0025(a4),d1                    ; d1 = CMD 09 param #$25 (31)
                divs.w  d1,d0                           ; d0 = d0/d1
                move.w  d0,$0026(a4)                    ; store remainder value #$26 ()
                neg.w   d0                              ; d0 = remainder * -1
                muls.w  d1,d0                           ; d0 = d0 * d1
                sub.w   d0,$004a(a4)                    ; sub d0 from #$4a (74) - previous $00004bba current note period value $00004bba
.end_cmd_09




continue_command_processing_03                          ; original address $00004668
                btst.l  #$0001,d7                       ; chk CMD 14
                beq.b   continue_command_processing_04  ; no.... jmp $00004680

                ; --------- CMD 14 ---------
.is_cmd_14                                              ; original address $0000466e
                move.b  #$01,$0033(a4)                  ; set CMD 14 working value - #$33 (51)
                move.l  $0028(a4),$002c(a4)             ; working copy CMD 14 param - #$2c (44)
                move.b  $0030(a4),$0031(a4)             ; working copy CMD 14 param - #$31 (49)
.end_cmd_14


continue_command_processing_04                          ; original address $00004680
                bset.l  #$0004,d7                       ; cleared by CMD 08
                move.l  $0014(a4),$0018(a4)             ; working copy of pointer?
                move.w  #$0001,$001e(a4)                ; initialise value
                clr.w   $004c(a4)       
                move.w  $0054(a4),d0            
                or.w    d0,audio_dma                    ; L0000417c ; audio dma

skip_cmds_09_to_17                                        ; original address $0000469c
                moveq   #$00,d0                         ; d0 = #$0.l
                move.b  $0051(a4),d0                    ; d0 = byte CMD 05


.chk_cmd_05                                             ; original address $000046a2
                btst.l  #$0005,d7
                bne.b   .not_cmd_05                     ; jmp $000046aa
                ;-------- CMD 05 -----------
.is_cmd_05                                              ; original address $000046a8
                move.b  (a3)+,d0                        ; d0 = next CMD Byte



                ;-------- CMD 08 -----------
.not_cmd_05                                             ; original address $000046aa
                add.w   d0,$0052(a4)                    ; store d0 in #$52 (82)
                move.l  a3,$000e(a4)                    ; store ptr to current CMD

check_command_08                                        ; $46b2
.chk_cmd_08                                             ; original address $000046b2
                btst.l  #$0007,d7
                bne.w   exit_command_processing         ; jmp $00004850

.do_cmd_08                                              ; original address $000046ba
                move.w  $004a(a4),d0                    ; d0 = current note period value from table $00004bba



                ;--------- Check for CMD 09 ----------
.chk_cmd_09                                             ; original address $000046be
                btst.l  #$0003,d7
                beq.b   chk_cmd_10                      ; L000046d6

                ;--------- CMD 09 ---------
.is_cmd_09                                              ; original address $000046c4
                subq.b  #$01,$0025(a4)                  ; CMD 09 counter
                bne.b   .cont_cmd_09                    ; L000046ce
.end_cmd_09
                bclr.l  #$0003,d7                       ; clear CMD 09 bit (switch cmd off)
.cont_cmd_09
                sub.w   $0026(a4),d0
                bra.w   store_sample_period               ; L000047a8 ; skip next couple of commands 




                ;--------- Check for CMD 10 -----------
chk_cmd_10                                              ; original address$000046d6
                btst.l  #$0000,d7
                beq.b   continue_command_processing_05  ; L00004722

                ;---------- CMD 10 ---------
.is_cmd_10                                              ; original address $000046dc
                subq.b  #$01,$0023(a4)
                bcc.w   store_sample_period               ; L000047a8
                move.b  $004f(a4),d0
                move.b  $0050(a4),d1
                move.b  d0,$0050(a4)
                ext.w   d0
                sub.w   $003c(a4),d0
                add.w   d0,d0

.validate_command                                       ; original address $000046f8
                cmp.w   #$ffd0,d0                       ; validate -48
                blt.b   .debug_assert_fail              ; L00004704 - this branch is never taken                       
                cmp.w   #$002c,d0                       ; valdate +44
                ble.b   .continue_cmd_10                ; $0000471a  this branch is always taken ------>>>>>>>>>

.debug_assert_fail                                      ; original address $00004704
                move.b  $004f(a4),d1                    ; ******* BRANCH IS NEVER TAKEN *******
                move.b  $0050(a4),d2
                move.w  $003c(a4),d3
                move.w  $0054(a4),d4
                movea.l $0006(a4),a2
                illegal                                 ; ******* DEBUG/ASSERT BAD COMMAND

.continue_cmd_10                                        ; original address $0000471a           
                move.w  $00(a5,d0.w),d0
                bra.w   store_sample_period             ; L000047a8


continue_command_processing_05                          ; original address L00004722

                ; ---------- check CMD 14 ----------
.chk_cmd_14                                             ; original address L00004722
                btst.l  #$0001,d7
                beq.b   continue_command_processing_06  ; L00004784


                ;------------- CMD 14 ----------
.is_cmd_14                                              ; original address L00004728
                subq.b  #$01,$0033(a4)                  ; original address L00004728
                bne.b   store_sample_period             ; L000047a8
                movea.l $002c(a4),a0
                move.b  (a0)+,d0
                subq.b  #$01,$0031(a4)
                bne.b   .L00004744
                movea.l $0028(a4),a0
                move.b  $0030(a4),$0031(a4)
.L00004744      move.l  a0,$002c(a4)
                move.b  $0032(a4),$0033(a4)
                add.b   $0050(a4),d0
                ext.w   d0
                sub.w   $003c(a4),d0
                add.w   d0,d0

.validate_command                                       ; original address $000046f8
                cmp.w   #$ffd0,d0                       ; validate -48
                blt.b   .debug_assert_fail              ; L00004766 - this branch is never taken
                cmp.w   #$002c,d0                       ; valdate +44
                ble.b   .end_cmd_14                     ; $0000471a  this branch is always taken ------>>>>>>>>>

.debug_assert_fail                                      ; original address L00004766
                move.b  $004f(a4),d1
                move.b  $0050(a4),d2
                move.w  $003c(a4),d3
                move.w  $0054(a4),d4
                movea.l $0006(a4),a2
                illegal                                 ; ******* DEBUG/ASSERT BAD COMMAND

.end_cmd_14                                             ; original address L0000477c
                move.w  $00(a5,d0.w),d0
                bra.w   store_sample_period             ; L000047a8



continue_command_processing_06                          ; original address L00004784

                ;---------- Check CMD 12 ---------
.chk_cmd_12                                             ; original address L00004784
                btst.l  #$0002,d7
                beq.b   store_sample_period             ; L000047a8

                ;------------ CMD 12 -------------
.is_cmd_12                                              ; original address L0000478a
                subq.b  #$01,$0037(a4)
                bcc.b   store_sample_period             ; L000047a8
                addq.b  #$01,$0037(a4)
                subq.b  #$01,$0039(a4)
                bne.b   .L000047a4
                neg.w   $003a(a4)
                move.b  $0038(a4),$0039(a4)
.L000047a4      add.w   $003a(a4),d0


store_sample_period                                     ; original address L000047a8
                move.w  d0,CHANNEL_SAMPLE_PERIOD(a4)    ; $004a(a4)


                ; -------- Check CMD 08,12,10,14 --------
.chk_08_10_12_14                                        ; original address L000047ac
                btst.l  #$0004,d7
                beq.w   exit_command_processing         ; Not CMD 08,12,10,14 - jmp $00004850

                ; -------- Is xxxx CMD ----------
.is_cmd_08_10_12_14                                     ; original address L000047b4
                subq.w  #$01,$001e(a4)
                bne.w   .L0000483a
                movea.l $0018(a4),a0
                moveq   #$00,d0
                move.b  (a0)+,d0
                beq.b   .L00004808
                bmi.b   .L000047e2
                move.w  d0,$001e(a4)
                move.b  #$01,$001c(a4)
                move.b  #$01,$001d(a4)
                move.b  (a0)+,$0020(a4)
                move.l  a0,$0018(a4)
                bra.b   .L0000483a


.L000047e2      neg.b   d0
                move.w  d0,$001e(a4)
                move.b  #$01,$0020(a4)
                move.b  (a0)+,d0
                bpl.b   .L000047f8
                neg.b   d0
                neg.b   $0020(a4)
.L000047f8      move.b  d0,$001c(a4)
                move.b  #$01,$001d(a4)
                move.l  a0,$0018(a4)
                bra.b   .L0000483a


.L00004808      move.b  (a0),d0
                beq.b   .L00004816
                bpl.b   .L00004810
                neg.b   d0
.L00004810      sub.w   $0052(a4),d0
                bmi.b   .L0000481c
.L00004816      bclr.l  #$0004,d7
                bra.b   exit_command_processing                 ;L00004850


.L0000481c      neg.w   d0
                move.w  d0,$001e(a4)
                move.b  #$00,$001c(a4)
                move.b  #$00,$001d(a4)
                move.b  #$00,$0020(a4)
                move.l  a0,$0018(a4)
                bra.b   exit_command_processing         ; L00004850


.L0000483a      subq.b  #$01,$001d(a4)
                bne.b   exit_command_processing         ; L00004850
                move.b  $001c(a4),$001d(a4)
                move.b  $0020(a4),d0
                ext.w   d0
                add.w   d0,CHANNEL_VOLUME(a4)           ; $004c(a4)

exit_command_processing                                 ; original address L00004850
                rts  





                ; ----------------------- set custom register values -------------------
                ; IN: a6 - Custom Base
                ; IN: 
update_audio_custom_registers                                   ; original routine address $00004852
                move.w  audio_dma,d0                            ; L0000417c ; Audio DMA?  #$0054 of channel_data
                beq.b   set_channel_volume                      ; L000048c6

                ; init channel dma and interrupts if $417c != 0
set_channel_dma                                                 ; original asddress $00004858
                move.w  d0,DMACON(a6)                           ; enable audio channel(s) DMA - $0096(a6)
                move.w  d0,d1
                lsl.w   #$07,d1
                move.w  d1,INTREQ(a6)                           ; clear audio interrupt flags - $009c(a6)
                moveq   #$00,d2
                moveq   #$01,d3

.chk_aud0_dma                                                   ; original address L00004868
                btst.l  #$0000,d0
                beq.b   .chk_aud1_dma                           ; aud 0 dma is off - $00004876

.is_aud0_dma                                                    ; original address L0000486e
                move.w  d3,AUD0PER(a6)                          ; AUD0PER - set to #$0001 - audio 0 frequency period value - ; $00a6(a6)
                move.w  d2,AUD0DAT(a6)                          ; AUD0DAT - set to #$0000 - audio 0 data value - ; $00aa(a6)

.chk_aud1_dma                                                   ; original address L00004876
                btst.l  #$0001,d0
                beq.b   .chk_aud2_dma                           ; L00004884

.is_aud1_dma                                                    ; original address L0000487c
                move.w  d3,AUD1PER(a6)                          ; $00b6(a6)
                move.w  d2,AUD1DAT(a6)                          ; $00ba(a6)

.chk_aud2_dma                                                   ; original address L00004884
                btst.l  #$0002,d0
                beq.b   .chk_aud3_dma                           ; L00004892

.is_aud2_dma                                                    ; original address L0000488a
                move.w  d3,AUD2PER(a6)                          ; $00c6(a6)
                move.w  d2,AUD2DAT(a6)                          ; $00ca(a6)

.chk_aud3_dma                                                   ; original address L00004892
                btst.l  #$0003,d0
                beq.b   .audio_interrupt_wait                   ; L000048a0
.is_aud3_dma                                                    ; original address L00004898
                move.w  d3,AUD3PER(a6)                          ; $00d6(a6)
                move.w  d2,AUD3DAT(a6)                          ; $00da(a6)

.audio_interrupt_wait                                           ; original address L000048a0
                move.w  INTREQR(a6),d2                          ; INTREQR - Interrupt flag bits
                and.w   d1,d2                                   ; mask disabled audio interrupts
                cmp.w   d1,d2                                   ; wait for interrupts to occur on all enabled audio channels
                bne.b   .audio_interrupt_wait                   ; L000048a0

.raster_wait                                                    ; original address L000048aa
                moveq   #$02,d2                                 ; loop counter 2 + 1
                move.w  VHPOSR(a6),d3                           ; $0006(a6),d3
                and.w   #$ff00,d3                               ; mask horizontal position
.loop                                                           ; original address L000048b4
                move.w  VHPOSR(a6),d4                           ; $0006(a6),d4
                and.w   #$ff00,d4                               ; mask horizontal position
                cmp.w   d4,d3
                beq.b   .loop                                   ; wait for next raster line, L000048b4
                move.w  d4,d3
                dbf.w   d2,.loop                                ; L000048b4 ; wait for approx 3.5 raster lines


set_channel_volume                                              ; original address L000048c6
                move.w  master_audio_volume_mask_1,d1           ; L0000401c - master audio volume mask 1 (#$ffff = on)
                move.w  master_audio_volume_mask_2,d2           ; L0000401e - master audio volume mask 2 (#$ffff = on)
 


                ; IN: D0 = DMA/interrupt bits (channel enabled)
                ; IN: D1 = master volume mask 1
do_channel_1
                lea.l   channel_1_status,a0                     ; $4024,a0
                move.w  d1,d3
.chk_volume_mask
                btst.b  #$0006,(a0)                             ; test which volume mask to use (allows volume off/reduced volume by setting a channel bit) 
                beq.b   .use_volume_mask_1                      ; $000048dc
.use_volume_mask_2                                              ; original address L000048da
                move.w  d2,d3                                   ; d2,d3 = master volume mask
.use_volume_mask_1                                              ; original address L000048dc
                and.w   CHANNEL_VOLUME(a0),d3                   ; d3 = channnel volume
.set_volume                                                     ; original address L000048e0
                move.w  d3,AUD0VOL(a6)                          ; $00a8(a6) - set audio volume
.set_pitch                                                      ; original address L000048e4
                move.w  CHANNEL_SAMPLE_PERIOD(a0),AUD0PER(a6)   ; $00a6(a6) - set sample pitch
.chk_new_sample                                                 ; original address L000048ea
                btst.l  #$0000,d0                               ; d0 = still contains channel interrupt/DMA status bits
                beq.b   .set_sample_2                           ; L000048fe
                ; set sample start/repeat
.set_sample_1                                                   ; original address L000048f0
                move.w  CHANNEL_SAMPLE_LEN_A(a0),AUD0LEN(a6)    ; set DMA Sample Audio Length $00a4(a6)
                move.l  CHANNEL_SAMPLE_PTR_A(a0),AUD0LC(a6)     ; set DMA Sample Data Ptr $00a0(a6)
                bra.b   do_channel_2                            ; jmp $0000490a
                ; set sample start/repeat
.set_sample_2                                                   ; original address L000048fe
                move.w  CHANNEL_SAMPLE_LEN_B(a0),AUD0LEN(a6)    ; $00a4(a6)
                move.l  CHANNEL_SAMPLE_PTR_B(a0),AUD0LC(a6)     ; $00a0(a6)



                ; IN: D0 = DMA/interrupt bits (channel enabled)
                ; IN: D1 = master volume mask 1
do_channel_2                                                    ; original address L0000490a
                lea.l   channel_2_status,a0                     ; L0000407a,a0
                move.w  d1,d3
.chk_volume_mask
                btst.b  #$0006,(a0)                             ; original address L00004910
                beq.b   .use_volume_mask_1                      ; L00004918
.use_volume_mask_2                                              ; original address L00004916
                move.w  d2,d3
.use_volume_mask_1                                              ; original address L00004918
                and.w   CHANNEL_VOLUME(a0),d3
.set_volume                                                     ; original address L0000491c 
                move.w  d3,AUD1VOL(a6)                          ; $00b8(a6)
.set_pitch                                                      ; original address L00004920
                move.w  CHANNEL_SAMPLE_PERIOD(a0),AUD1PER(a6)   ; $00b6(a6)
.chk_new_sample                                                 ; original address L00004926
                btst.l  #$0001,d0
                beq.b   .set_sample_2                           ; L0000493a
.set_sample_1                                                   ; original address L0000492c
                move.w  CHANNEL_SAMPLE_LEN_A(a0),AUD1LEN(a6)    ; $00b4(a6)
                move.l  CHANNEL_SAMPLE_PTR_A(a0),AUD1LC(a6)     ; $00b0(a6)
                bra.b   do_channel_3                            ; L00004946
.set_sample_2                                                   ; original address L0000493a
                move.w  CHANNEL_SAMPLE_LEN_B(a0),AUD1LEN(a6)    ; $00b4(a6)
                move.l  CHANNEL_SAMPLE_PTR_B(a0),AUD1LC(a6)     ; $00b0(a6)



                ; IN: D0 = DMA/interrupt bits (channel enabled)
                ; IN: D1 = master volume mask 1
do_channel_3                                                    ; original address  L00004946
                lea.l   channel_3_status,a0                     ;$40d0,a0
                move.w  d1,d3
.chk_volume_mask                                                ; original address  L0000494c
                btst.b  #$0006,(a0)
                beq.b   .set_volume                             ; L00004954
.use_volume_mask_2                                              ; original address  L00004952
                move.w  d2,d3
.use_volume_mask_1                                              ; original address  L00004954
                and.w   CHANNEL_VOLUME(a0),d3
.set_volume                                                     ; original address  L00004958
                move.w  d3,AUD2VOL(a6)                          ; $00c8(a6)
.set_pitch                                                      ; original address  L0000495c
                move.w  CHANNEL_SAMPLE_PERIOD(a0),AUD2PER(a6)   ; $00c6(a6)
.chk_new_sample                                                 ; original address  L00004962
                btst.l  #$0002,d0
                beq.b   .set_sample_2                           ; L00004976
.set_sample_1                                                   ; original address  L00004968
                move.w  CHANNEL_SAMPLE_LEN_A(a0),AUD2LEN(a6)    ; $00c4(a6)
                move.l  CHANNEL_SAMPLE_PTR_A(a0),AUD2LC(a6)    ; $00c0(a6)
                bra.b   do_channel_4                            ; jmp L00004982
.set_sample_2                                                   ; original address  L00004976
                move.w  CHANNEL_SAMPLE_LEN_B(a0),AUD2LEN(a6)    ; $00c4(a6)
                move.l  CHANNEL_SAMPLE_PTR_B(a0),AUD2LC(a6)     ; $00c0(a6)



                ; IN: D0 = DMA/interrupt bits (channel enabled)
                ; IN: D1 = master volume mask 1
do_channel_4
                lea.l   channel_4_status,a0                     ;$4126,a0
                move.w  d1,d3
.chk_volume_mask 
                btst.b  #$0006,(a0)
                beq.b   .use_volume_mask_1                      ; L00004990
.use_volume_mask_2 
                move.w  d2,d3
.use_volume_mask_1
                and.w   CHANNEL_VOLUME(a0),d3
.set_volume
                move.w  d3,AUD3VOL(a6)                          ; $00d8(a6)
.set_pitch
                move.w  CHANNEL_SAMPLE_PERIOD(a0),AUD3PER(a6)   ; $00d6(a6)
.chk_new_sample 
                btst.l  #$0003,d0
                beq.b   .set_sample_2                           ; L000049b2
.set_sample_1 
                move.w  CHANNEL_SAMPLE_LEN_A(a0),AUD3LEN(a6)    ; $00d4(a6)
                move.l  CHANNEL_SAMPLE_PTR_A(a0),AUD3LC(a6)     ; $00d0(a6)
                bra.b   do_enable_dma                           ; L000049be
.set_sample_2 
                move.w  CHANNEL_SAMPLE_LEN_B(a0),AUD3LEN(a6)    ; $00d4(a6)
                move.l  CHANNEL_SAMPLE_PTR_B(a0),AUD3LC(a6)     ; $00d0(a6)


                ; Enable channel DMA
do_enable_dma
                or.w    #$8000,d0                               ; d0 = add SET flag to Audio DMA
                move.w  d0,DMACON(a6)                           ; $0096(a6) ; enable Audio DMA

                clr.w   audio_dma                               ; L0000417c ; Clear Audio DMA Changes - for next processing loop
                rts




                ;------------------- initislise music samples --------------------
                ; extract sample data ptrs and lengths from the IFF sample
                ; data.
                ;
                ; IN: a0    - music sample table address $4D52 - default_sample_data
                ; IN: a1    - music/song instrument data $4BFA - instrument_data
                ;
init_instruments                                        ; original routine address L000049cc
                move.l  (a0)+,d0                        ; d0 = sound sample byte offset
                beq.b   .exit                           ; if d0 == 0 then exit
                move.w  (a0)+,INSTR_VOLUME(a1)          ; copy sample volume
                move.w  (a0)+,INSTR_SAMPLE_UNKNOWN(a1)  ; copy param value2 (unknown, 0 or -1)
                move.l  a0,-(a7)                        ; save a0 - incremented ptr to stack
                                                        ; d0 is offset to data within the structure
                lea.l   -8(a0,d0.l),a0                  ; a0 = ptr to start of iff sample 'FORM' structure. #$f8 = -8
                move.l  $0004(a0),d0                    ; d0 = Length of 'FORM' data structure (sample data)
                addq.l  #$08,d0                         ; d0 = alter length to include 'FORM' and length header value, d0 = total file len from A0.
                bsr.w   process_instrument              ; calls L000049ec
                movea.l (a7)+,a0                        ; a0 = next sample table entry
                bra.b   init_instruments                ; jmp L000049cc ; loop for next sample data.
.exit
                rts     



                ; ------------------ process instrument  ----------------
                ; IN: A0 = ptr to start of 'FORM' block of sample data.
                ; IN: A1 = ptr to Instrument Entry in Music Data.
                ; IN: D0 = length of sample including headers.
                ;
process_instrument                                      ; original routine address L000049ec
                move.l  a1,-(a7)                        ; Save ptr to Instrument Details
                bsr.w   process_sample_data             ; calls L00004a30
                movea.l (a7)+,a1                        ; Restore ptr to Instrument Details
                addq.l  #$02,a1                         ; a1 = skip first param value (volume) offset 0-1
                movea.l sample_vhdl_ptr,a0              ; L00004b3e,a0
                move.l  (a0)+,d0                        ; d0 = sample length length
                bclr.l  #$0000,d0                       ; d0 = make length even
                move.l  (a0)+,d1                        ; d1 = sample repeat length 
                bclr.l  #$0000,d1                       ; d1 = make repeat length even
                movea.l sample_body_ptr,a0              ; a0 = start of sample data, $00004b64,a0
                move.l  a0,(a1)+                        ; store sample start address in instrument table offset 2-5
                adda.l  d0,a0                           ; a0 = start of repeat section of sample
                add.l   d1,d0                           ; d0 = total length of sample + repeat
                lsr.l   #$01,d0                         ; d0 = count of word length
                move.w  d0,(a1)+                        ; store sample length (words) in table offset 6-7
                tst.l   d1                              ; test repeat length
                bne.b   .set_repeat
.no_repeat
                lea.l   silient_repeat,a0               ; $00004d3a,a0 ; set default 0 value for silent repeat
                moveq   #$02,d1                         ; set single word length for silent repeat.
.set_repeat
                move.l  a0,(a1)+                        ; set repeat start address in table offset 8 - 11
                lsr.l   #$01,d1                         ; d1 = repeat length (words)
                move.w  d1,(a1)+                        ; set repeat length (words) in table offset 12-13
                addq.l  #$02,a1                         ; update instrument table ptr (skip param 2 - unknown 0 or -1 value) - 14-15
                rts  



                ;------------------ process sample data --------------------------
                ; Walks through the IFF 8SVX file format, storing the pointers to
                ; the BODY and VHDL chunks in the variables.
                ;
                ; Also, sets the error/status 'sample_status' - 0 = success
                ;
                ; IN: A0 = ptr to start of 'FORM' or 'CAT ' block of sample data.
                ; IN: A1 = ptr to Instrument Entry in Music Data.
                ; IN: D0 = length of sample including headers.
                ;
sample_status                                   ; original variable address L00004a2e
                dc.w    $0000                   ; error/status flag
                                                ; 1 = missing FORM/CAT chunk
                                                ; 2 = missing 8SVX chunk

process_sample_data                             ; original routine address L00004a30
                clr.w   sample_status           ; L00004a2e 
                movem.l d0/a0,-(a7)
                bra.w   process_inner_chunk
process_inner_chunk
                tst.l   d0                      ; test sample length
                beq.b   .exit
                move.l  (a0)+,d1                ; d1 = Chunk Name
                subq.l  #$04,d0                 ; d0 = remaining bytes
                bsr.w   process_sample_chunk    ; calls L00004a50 ; process iff chunks
                bra.b   process_inner_chunk     ; jmp L00004a3c ; loop while data remaining
.exit                                           ; original address $00004a4a
                movem.l (a7)+,d0/a0
                rts



                ;------------------ process sample chunk ------------------
                ; process IFF sample data, top level of file structure.
                ;
                ; IN: A0 = ptr to length of data.
                ; IN: A1 = ptr to Instrument Entry in Music Data.
                ; IN: D0 = length of sample including headers.
                ; IN: D1.l = chunk identifier, e.g. FORM, CAT etc
                ;
process_sample_chunk                            ; original routine address L00004a50
                cmp.l   #'FORM',d1               ; #$464f524d,d1
                beq.w   process_form_chunk      ; jmp L00004aac ; process FORM chunk
                cmp.l   #'CAT ',d1               ; #$43415420,d1
                beq.w   process_cat_chunk       ; jmp L00004a6e ; process CAT chunk
                move.w  #$0001,sample_status    ; L00004a2e ; error status flag?
                clr.l   d0                      ; clear remaining byte length
                rts



                ;--------------------- process CAT chunk --------------------------
                ; skips header and continues processing inner chunk data.
                ;
                ; IN: A0 = ptr to length of chunk data.
                ; IN: A1 = ptr to Instrument Entry in Music Data.
                ; IN: D0 = length of outer chunk.
                ; IN: D1.l = chunk identifier, e.g. FORM, CAT etc
                ;
process_cat_chunk                               ; original routine address L00004a6e
                movem.l d0/a0,-(a7)
                move.l  (a0)+,d0                ; d0 = chunk length
                move.l  d0,d1                   ; d1 = chunk length
                btst.l  #$0000,d1               ; test odd/even length
                beq.b   .no_pad_byte            ; is even, no pad byte
.add_pad_byte                                   ; addr $4a7c
                addq.l  #$01,d1                 ; is odd, add pad byte
.no_pad_byte                                    ; addr $4a7e
                addq.l  #$04,d1                 ; add length field to chunk len
                add.l   d1,$0004(a7)            ; update address ptr on stack (end of chunk)
                sub.l   d1,(a7)                 ; subtract chunk length from remaining bytes on stack
                addq.l  #$04,(a0)
                subq.l  #$04,d0                 ; subtract remaining bytes
                bra.b   process_inner_chunk     ; jmp L00004a3c



                ;------------------- process LIST chunk -----------------
                ; skip the list chunk, and continue processing
                ;
                ; IN: A0 = ptr to length of data.
                ; IN: A1 = ptr to Instrument Entry in Music Data.
                ; IN: D0 = length of remaining data.
                ; IN: D1.l = chunk identifier, e.g. FORM, CAT etc
                ;
process_list_chunk                              ; original addr $00004a8c
                movem.l d0/a0,-(a7)
                move.l  (a0)+,d0
                move.l  d0,d1
                btst.l  #$0000,d1
                beq.b   .no_pad_byte
.add_pad_byte                                   ; addr $4a9a
                addq.l  #$01,d1
.no_pad_byte                                    ; addr $4a9c
                addq.l  #$04,d1
                add.l   d1,$0004(a7)
                sub.l   d1,(a7)
                nop
                movem.l (a7)+,d0/a0
                rts



                ;---------------- process FORM chunk ------------------
                ; Expects to find an '8SVX' inner chunk of data.
                ; If not, then sets error/status flag = $0002
                ;
                ; IN: A0 = ptr to length of data.
                ; IN: A1 = ptr to Instrument Entry in Music Data.
                ; IN: D0 = length of sample including headers.
                ; IN: D1.l = chunk identifier, e.g. FORM, CAT etc
                ;

process_form_chunk                           ; original routine address L00004aac
                movem.l d0/a0,-(a7)
                move.l  (a0)+,d0                ; d0 = length of FORM data
                move.l  d0,d1                   ; d1 = length of FORM data
                btst.l  #$0000,d1               ; check of length is odd
                beq.b   .no_pad_byte            ; even length (no pad byte required)
.add_pad_byte                                   ; addr $4aba
                addq.l  #$01,d1                 ; odd length (add pad byte)
.no_pad_byte                                    ; addr $4abc
                addq.l  #$04,d1                 ; add length field to chunk len
                add.l   d1,$0004(a7)            ; update address ptr on stack (end of chunk)
                sub.l   d1,(a7)                 ; subtract chunk length from remaining bytes on stack
                move.l  (a0)+,d1                ; d1 = inner chunk identifer
                subq.l  #$04,d0                 ; d0 = updated remaining bytes
                cmp.l   #'8SVX',d1               ; #$38535658,d1
                beq.w   process_8svx_chunk      ; jmp L00004ade ; process 8SVX chunk
                move.w  #$0002,sample_status    ; L00004a2e ; error/status flag
                movem.l (a7)+,d0/a0
                rts



                ;------------------ process 8SVX chunk ---------------------
                ; loops through sample data until no bytes remaining.
                ; processes inner chunks of 8SVX chunk, including:-
                ;  - VHDL, BODY, NAME, ANNO
                ;
                ; IN: A0 = ptr to length of data.
                ; IN: A1 = ptr to Instrument Entry in Music Data.
                ; IN: D0 = length of remaining data.
                ; IN: D1.l = chunk identifier, e.g. FORM, CAT etc
                ;
process_8svx_chunk                                      ; original address $00004ade
                tst.l   d0                              ; test end of sample data
                beq.b   .exit                           ; if so, then exit
                move.l  (a0)+,d1                        ; d1 = inner chunk identifier
                subq.l  #$04,d0                         ; d0 = updated remaining bytes
                bsr.w   process_inner_8svx_chunk        ; calls $00004af2
                bra.b   process_8svx_chunk              ; jmp L00004ade ; loop until no bytes remaining.
.exit                                                   ; addr $4aec
                movem.l (a7)+,d0/a0                     ; exit
                rts



                ;---------------- process inner 8SVX chunk --------------
                ; process data held inside the 8SVX chunk, this is only
                ; concerned with the VHDL and BODY chunks. it skips
                ; other chunks such as the NAME, ANNO meta data chunks.
                ;
                ; IN: A0 = ptr to length of data.
                ; IN: A1 = ptr to Instrument Entry in Music Data.
                ; IN: D0 = length of remaining data.
                ; IN: D1.l = chunk identifier, e.g. FORM, CAT etc
                ;
process_inner_8svx_chunk                                ; original routine address L00004af2
                cmp.l   #'FORM',d1                       ;#$464f524d,d1
                beq     process_form_chunk              ; jmp L00004aac
                cmp.l   #'LIST',d1                       ;#$4c495354,d1
                beq.b   process_list_chunk              ; jmp L00004a8c
                cmp.l   #'CAT ',d1                       ;#$43415420,d1
                beq.w   process_cat_chunk               ; jmp L00004a6e
                cmp.l   #'VHDR',d1                       ;#$56484452,d1
                beq.w   process_vhdl_chunk              ; jmp L00004b42
                cmp.l   #'BODY',d1                       ;#$424f4459,d1
                beq.w   process_body_chunk              ; L00004b68
.skip_unused_chunks                                     ; addr $4b20
                movem.l d0/a0,-(a7)
                move.l  (a0)+,d0
                move.l  d0,d1
                btst.l  #$0000,d1
                beq.b   .no_pad_byte
.add_pad_byte                                           ; addr $4b2e
                addq.l  #$01,d1
.no_pad_byte                                            ; addr $4b30
                addq.l  #$04,d1
                add.l   d1,$0004(a7)
                sub.l   d1,(a7)
                movem.l (a7)+,d0/a0
                rts



                ;-------------------- process VHDL chunk ----------------------
                ; stores address of VHDL chunk in variable 'sample_vhdl_ptr'
                ;
                ; IN: A0 = ptr to length of data.
                ; IN: A1 = ptr to Instrument Entry in Music Data.
                ; IN: D0 = length of remaining data.
                ; IN: D1.l = chunk identifier, e.g. FORM, CAT etc
                ;
sample_vhdl_ptr                                 ; original var address L00004b3e
                dc.l    $00017F66               ; original address L00004b3e

process_vhdl_chunk                              ; original address L00004b42
                movem.l d0/a0,-(a7)
                move.l  (a0)+,d0                ; d0 = length of chunk
                move.l  d0,d1                   ; d1 = length of chunk
                btst.l  #$0000,d1               ; is pad byte required (odd length)
                beq.b   .no_pad_byte            ; no pad byte (length is even)
.add_pad_byte                                   ; addr $4b50
                addq.l  #$01,d1                 ; add pad byte (make length even)
.no_pad_byte                                    ; addr $4b52
                addq.l  #$04,d1                 ; update chunk length (include length field)
                add.l   d1,$0004(a7)            ; update A0 data ptr on stack (end of chunk)
                sub.l   d1,(a7)                 ; update d0 remaining data on stack
                move.l  a0,sample_vhdl_ptr      ; L00004b3e ; store address of VHDL chunk
                movem.l (a7)+,d0/a0
                rts



                ;------------------------- process body chunk ------------------------
                ; store address of the raw sample data in variable 'sample_body_ptr'
                ;
                ; IN: A0 = ptr to length of data.
                ; IN: A1 = ptr to Instrument Entry in Music Data.
                ; IN: D0 = length of remaining data.
                ; IN: D1.l = chunk identifier, e.g. FORM, CAT etc
                ;
sample_body_ptr                                 ; original var address L0004b64
                dc.l    $00017FBA               ; body data ptr (raw sample data)

process_body_chunk                              ; original routine address L0004b68
                movem.l d0/a0,-(a7)
                move.l  (a0)+,d0                ; d0 = body length
                move.l  d0,d1                   ; d1 = body length
                btst.l  #$0000,d1               ; check for odd length
                beq.b   .no_pad_byte            ; even length (no pad byte)
.add_pad_byte                                   ; addr $4b76
                addq.l  #$01,d1
.no_pad_byte                                    ; addr $4b78
                addq.l  #$04,d1                 ; update chunk length (include length field)
                add.l   d1,$0004(a7)            ; update A0 data ptr on stack (end of chunk)
                sub.l   d1,(a7)                 ; update d0 remaining data on stack
                move.l  a0,sample_body_ptr      ; L0004b64 ; store address of raw sample data
                movem.l (a7)+,d0/a0
                rts


                even
                ; COMMAND TABLE - 
                ;       - audio channel period values - note frequenies
                ;       - indexes to $00004bba clamped to -48 bytes or +44 bytes to remain in table range
                ;       - I've got the table running B to B (may be I'm a semi-tone out C to C - most likely)
note_period_table                                               ; original address L00004B8A
                dc.w    $06FE           ; B     (1790)
                dc.w    $0699           ; C     (1689)
                dc.w    $063B           ; C#    (1595)
                dc.w    $05E1           ; D     (1505)
                dc.w    $058D           ; D#    (1421)
                dc.w    $053D           ; E     (1341)          ; note_period_table+10
                dc.w    $04F2           ; F     (1266)
                dc.W    $04AB           ; F#    (1195)
                dc.w    $0467           ; G     (1127)
                dc.W    $0428           ; G#    (1064)
                dc.W    $03EC           ; A     (1004)          ; note_period_table+20
                dc.W    $03B4           ; A#    (948)
                dc.W    $037F           ; B     (895)
                dc.w    $034D           ; C     (845)
                dc.W    $031D           ; C#    (797)
                dc.w    $02F1           ; D     (753)           ; note_period_table+30
                dc.w    $02C6           ; D#    (710)
                dc.w    $029E           ; E     (670)
                dc.w    $0279           ; F     (633)
                dc.w    $0255           ; F#    (633)
                dc.w    $0234           ; G     (564)           ; note_period_table+40
                dc.w    $0214           ; G#    (532)
                dc.w    $01F6           ; A     (502)
                dc.w    $01DA           ; A#    (474)
; used in frame play routine - Centre point of Table
L00004BBA       dc.w    $01BF           ; B     (447)           ; note_period_table+48
                dc.w    $01A6           ; C     (422)
                dc.w    $018F           ; C#    (399)
                dc.w    $0178           ; D     (376)
                dc.w    $0163           ; D#    (355)
                dc.W    $014F           ; E     (335)
                dc.w    $013C           ; F     (316)
                dc.w    $012B           ; F#    (299)
                dc.w    $011A           ; G     (282)
                dc.w    $010A           ; G#    (266)
                dc.W    $00FB           ; A     (251)
                dc.w    $00ED           ; A#    (237)
                dc.w    $00E0           ; B     (224)
                dc.w    $00D3           ; C     (211)
                dc.w    $00C7           ; C#    (199)
                dc.w    $00BC           ; D     (188)
                dc.w    $00B2           ; D#    (178)
                dc.w    $00A8           ; E     (168)
                dc.W    $009E           ; F     (158)
                dc.W    $0095           ; F#    (149)
                dc.W    $008D           ; G     (141)
                dc.w    $0085           ; G#    (133)
                dc.W    $007E           ; A     (126)
                dc.w    $0077           ; A#    (119)


                ; music command 17 data
L00004BEA       dc.w $0021
                dc.l L00004D3C  ; $0000, $4D3C
                dc.w $000b
                dc.l L00004D3C  ; $0000, $4D3C
                dc.w $000B, $0000




                ;---------------- music data, maybe instrument data ------------------
                ; I think each 16 bytes represents data describing a sound/instrument.
                ; There are 12 samples in the Sample Data and 12 entries below.
                ; THe table below could have room for 20 or 21 entries (only 12 in use)
                ; the parameters from the SampleTable below @ $00004D52 'default_sample_data' 
                ; are copied into this table.
                ;
                ;       - The 16bit value offset 4 of each sample is copied to offset 0 of this table.
                ;       - The 16bit value offset 6 of each sample is copied to offset $e (14) of this table.
                ;
                ; I guess that this may be reseting values for the insrument volume (param 1)
                ; and a second param (unsure, values either 0, or -1). could be a repeat value 
                ; or something similar.
                ;
                ; I think the following table is used during the playing of the song(s),
                ; and keeps track of the instrument settings for each sample 
                ; (which may change during the playing of the song?)
                ;
                ; I think the following format.
                ;
                ; Offset        | Size          | Description
                ;---------------+---------------+-----------------------------------------
                ; 0             | 2             | I think default sample volume
                ; 2             | 4             | Sample Data Start Address
                ; 6             | 2             | Sample Length in Words
                ; 8             | 4             | Sample Repeat Start Address
                ; 12            | 2             | Sample Repeat Length in Words
                ; 14            | 2             | Unknown Parameter, values either 0 or -1
                ;

INSTR_VOLUME            EQU     $0
INSTR_SAMPLE_PTR        EQU     $2
INSTR_SAMPLE_LEN        EQU     $6
INSTR_SAMPLE_REPEAT_PTR EQU     $8
INSTR_SAMPLE_REPEAT_LEN EQU     $C
INSTR_SAMPLE_UNKNOWN    EQU     $E

instrument_data                         ; original address L00004BFA
instrument_01                           ; original address L00004BFA
.volume         dc.w  $0018
.samplestart    dc.l  $00004E1E
.samplelen      dc.w  $1C5C
.repeatstart    dc.l  silient_repeat
.repeatlen      dc.w  $0001
.unknown        dc.w  $0000    
instrument_02                           ; original address L00004C0A
.volume         dc.w  $0018
.samplestart    dc.l  $0000873E
.samplelen      dc.w  $1703
.repeatstart    dc.l  silient_repeat    ;$00004D3A
.repeatlen      dc.w  $0001
.unknown        dc.w  $0000    
instrument_03                           ; original address L00004C1A
.volume         dc.w  $000C
.samplestart    dc.l  $0000B5AC
.samplelen      dc.w  $0A02
.repeatstart    dc.l  silient_repeat    ; $00004D3A
.repeatlen      dc.w  $0001
.unknown        dc.w  $FFFF    
instrument_04                           ; original address L00004C2A
.volume         dc.w  $0018
.samplestart    dc.l  $0000CA18
.samplelen      dc.w  $0A28
.repeatstart    dc.l  silient_repeat    ;$00004D3A
.repeatlen      dc.w  $0001
.unknown        dc.w  $FFFF    
instrument_05                           ; original address L00004C3A
.volume         dc.w  $0030
.samplestart    dc.l  $0000DED0
.samplelen      dc.w  $012B
.repeatstart    dc.l  silient_repeat    ;$00004D3A
.repeatlen      dc.w  $0001
.unknown        dc.w  $FFFF    
instrument_06                           ; original address L00004C4A
.volume         dc.w  $0032
.samplestart    dc.l  $0000E18E
.samplelen      dc.w  $05CF
.repeatstart    dc.l  silient_repeat    ;$00004D3A
.repeatlen      dc.w  $0001
.unknown        dc.w  $FFFF  
instrument_07                           ; original address L00004C5A
.volume         dc.w  $0011
.samplestart    dc.l  $0000ED94
.samplelen      dc.w  $06B8
.repeatstart    dc.l  silient_repeat    ;$00004D3A
.repeatlen      dc.w  $0001
.unknown        dc.w  $0000    
instrument_08                           ; original address L00004C6A
.volume         dc.w  $0038
.samplestart    dc.l  $0000FB6C
.samplelen      dc.w  $0666
.repeatstart    dc.l  silient_repeat    ;$00004D3A
.repeatlen      dc.w  $0001
.unknown        dc.w  $0000    
instrument_09                           ; original address L00004C7A
.volume         dc.w  $0014
.samplestart    dc.l  $000108A0
.samplelen      dc.w  $05E1
.repeatstart    dc.l  silient_repeat    ;$00004D3A
.repeatlen      dc.w  $0001
.unknown        dc.w  $0000    
instrument_10                           ; original address L00004C8A
.volume         dc.w  $003E
.samplestart    dc.l  $000114CA
.samplelen      dc.w  $11D6
.repeatstart    dc.l  $00012DE0
.repeatlen      dc.w  $054B
.unknown        dc.w  $0000    
instrument_11                           ; original address L00004C9A
.volume         dc.w  $0018
.samplestart    dc.l  $000138DE
.samplelen      dc.w  $233A
.repeatstart    dc.l  silient_repeat    ;$00004D3A
.repeatlen      dc.w  $0001
.unknown        dc.w  $0000    
instrument_12                           ; original address L00004CAA
.volume         dc.w  $0018
.samplestart    dc.l  $00017FBA
.samplelen      dc.w  $1CE6
.repeatstart    dc.l  silient_repeat    ;$00004D3A
.repeatlen      dc.w  $0001
.unknown        dc.w  $0000    
instrument_13                           ; original address L00004CBA
.volume         dc.w  $0000
.samplestart    dc.l  $00000000
.samplelen      dc.w  $0000
.repeatstart    dc.l  $00000000
.repeatlen      dc.w  $0000
.unknown        dc.w  $0000    
instrument_14                           ; original address L00004CCA
.volume         dc.w  $0000
.samplestart    dc.l  $00000000
.samplelen      dc.w  $0000
.repeatstart    dc.l  $00000000
.repeatlen      dc.w  $0000
.unknown        dc.w  $0000    
instrument_15                           ; original address L00004CDA
.volume         dc.w  $0000
.samplestart    dc.l  $00000000
.samplelen      dc.w  $0000
.repeatstart    dc.l  $00000000
.repeatlen      dc.w  $0000
.unknown        dc.w  $0000    
instrument_16                           ; original address L00004CEA
.volume         dc.w  $0000
.samplestart    dc.l  $00000000
.samplelen      dc.w  $0000
.repeatstart    dc.l  $00000000
.repeatlen      dc.w  $0000
.unknown        dc.w  $0000    
instrument_17                           ; original address L00004CFA
.volume         dc.w  $0000
.samplestart    dc.l  $00000000
.samplelen      dc.w  $0000
.repeatstart    dc.l  $00000000
.repeatlen      dc.w  $0000
.unknown        dc.w  $0000    
instrument_18                           ; original address L00004D0A
.volume         dc.w  $0000
.samplestart    dc.l  $00000000
.samplelen      dc.w  $0000
.repeatstart    dc.l  $00000000
.repeatlen      dc.w  $0000
.unknown        dc.w  $0000    
instrument_19                           ; original address L00004D1A
.volume         dc.w  $0000
.samplestart    dc.l  $00000000
.samplelen      dc.w  $0000
.repeatstart    dc.l  $00000000
.repeatlen      dc.w  $0000
.unknown        dc.w  $0000    
instrument_20                           ; original address L00004D2A
.volume         dc.w  $0000
.samplestart    dc.l  $00000000
.samplelen      dc.w  $0000
.repeatstart    dc.l  $00000000
.repeatlen      dc.w  $0000
.unknown        dc.w  $0000    

;instrument_data                                                                 ; original address L00004BFA
;.instrument_01  dc.w  $0018, $0000, $4E1E, $1C5C, $0000, $4D3A, $0001, $0000    ; original address L00004BFA
;.instrument_02  dc.w  $0018, $0000, $873E, $1703, $0000, $4D3A, $0001, $0000    ; original address L00004C0A
;.instrument_03  dc.w  $000C, $0000, $B5AC, $0A02, $0000, $4D3A, $0001, $FFFF    ; original address L00004C1A
;.instrument_04  dc.w  $0018, $0000, $CA18, $0A28, $0000, $4D3A, $0001, $FFFF    ; original address L00004C2A
;.instrument_05  dc.w  $0030, $0000, $DED0, $012B, $0000, $4D3A, $0001, $FFFF    ; original address L00004C3A
;.instrument_06  dc.w  $0032, $0000, $E18E, $05CF, $0000, $4D3A, $0001, $FFFF  ; original address L00004C4A
;.instrument_07  dc.w  $0011, $0000, $ED94, $06B8, $0000, $4D3A, $0001, $0000    ; original address L00004C5A
;.instrument_08  dc.w  $0038, $0000, $FB6C, $0666, $0000, $4D3A, $0001, $0000    ; original address L00004C6A
;.instrument_09  dc.w  $0014, $0001, $08A0, $05E1, $0000, $4D3A, $0001, $0000    ; original address L00004C7A
;.instrument_10  dc.w  $003E, $0001, $14CA, $11D6, $0001, $2DE0, $054B, $0000    ; original address L00004C8A
;.instrument_11  dc.w  $0018, $0001, $38DE, $233A, $0000, $4D3A, $0001, $0000    ; original address L00004C9A
;.instrument_12  dc.w  $0018, $0001, $7FBA, $1CE6, $0000, $4D3A, $0001, $0000    ; original address L00004CAA
;.instrument_13  dc.w  $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000    ; original address L00004CBA
;.instrument_14  dc.w  $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000    ; original address L00004CCA
;.instrument_15  dc.w  $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000    ; original address L00004CDA
;.instrument_16  dc.w  $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000    ; original address L00004CEA
;.instrument_17  dc.w  $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000    ; original address L00004CFA
;.instrument_18  dc.w  $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000    ; original address L00004D0A
;.instrument_19  dc.w  $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000    ; original address L00004D1A
;.instrument_20  dc.w  $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000    ; original address L00004D2A


silient_repeat                                                                  ; original address L00004D3A
                dc.w  $0000                                                     ; repeat data for end of non-repeating samples (2 bytes)



                ; -- unknown data values (11 words/22 bytes)
L00004D3C       dc.w  $0074, $60DC, $82BB, $457E, $24A0, $8C00, $7460
L00004D4A       dc.w  $DC82, $BB45, $7E24, $A08C




                ; ------ music sample data table (12 sample offsets & 2 word params) ------
                ; 12 sound samples in IFF 8SVX format.
                ; Table of address offsets below, not sure what the additional two 16 bit 
                ; parameters that follow the offset represent yet. maybe volume and something else.
                ;
                ; addr $00004D52                                  ; Offset Calc   | Start       | Name           | End
default_sample_data                                               ;---------------+-------------+----------------+----------
.data_01        dc.l  sample_01-.data_01 
                dc.w  $0018, $0000                                ; $4D52 + $0064 = $00004DB6   - WHATRU         - $000086D6
.data_02        dc.l  sample_02-.data_02
                dc.w  $0018, $0000                                ; $4D5A + $3972 = $000086D6   - IMBATMAN       - $0000B544 
.data_03        dc.l  sample_03-.data_03
                dc.w  $000C, $FFFF                                ; $4D62 + $67E2 = $0000B544   - HITBASS-C1     - $0000C9B0
.data_04        dc.l  sample_04-.data_04 
                dc.w  $0018, $FFFF                                ; $4D6A + $7C46 = $0000C9B0   - HITSNARE-C2    - $0000DE68 
.data_05        dc.l  sample_05-.data_05
                dc.w  $0030, $FFFF                                ; $4D72 + $90F6 = $0000DE68   - KIT-HIHAT-C4   - $0000E126
.data_06        dc.l  sample_06-.data_06
                dc.w  $0032, $FFFF                                ; $4D7A + $93AC = $0000E126   - KIT-OPENHAT-D4 - $0000ED2C
.data_07        dc.l  sample_07-.data_07
                dc.w  $0011, $0000                                ; $4D82 + $9FAA = $0000ED2C   - BASS2-F        - $0000FB04
.data_08        dc.l  sample_08-.data_08 
                dc.w  $0038, $0000                                ; $4D8A + $AD7A = $0000FB04   - TIMELESS-GS    - $00010838
.data_09        dc.l  sample_09-.data_09
                dc.w  $0014, $0000                                ; $4D92 + $BAA6 = $00010838   - TIMEBASS-GS    - $00011462
.data_10        dc.l  sample_10-.data_10 
                dc.w  $003E, $0000                                ; $4D9A + $C6C8 = $00011462   - CRUNCHGUITAR-C4- $00013876
.data_11        dc.l  sample_11-.data_11
                dc.w  $0018, $0000                                ; $4DA2 + $EAD4 = $00013876   - LAUGH          - $00017F52
.data_12        dc.l  sample_12-.data_12
                dc.w  $0018, $0000                                ; $4DAA + $131A8 = $00017F52  - IWANNA         - $0001B986
.data_end       dc.w  $0000, $0000                                              ; 0 marks the end of sample table data



                ; --------------------- Sound Sample 1 -------------------
                ; Start Address: $00004DB6
                ; End Address:   $000086D5
                ; Name:          WHATRU 
                ; sample_01:     original address $00004DB6
                include "./music/sample_01.s"


                ; --------------------- Sound Sample 2 -------------------
                ; Start Address: $000086D6
                ; End Address:   $0000B543
                ; Name:          IMBATMAN 
                ; sample_02:     ; original address $000086D6
                include "./music/sample_02.s"


                ; --------------------- Sound Sample 3 -------------------
                ; Start Address: $0000B544
                ; End Address:   $0000C9AF
                ; Name:          HITBASS-C1
                ; sample_03      ; original address $0000B544
                include "./music/sample_03.s"


                ; --------------------- Sound Sample 4 -------------------
                ; Start Address: $0000C9B0
                ; End Address:   $0000DE67
                ; Name:          HITSNARE-C2
                ; sample_04     ; original address $0000C9B0
                include "./music/sample_04.s"


                ; --------------------- Sound Sample 5 -------------------
                ; Start Address: $0000DE68
                ; End Address:   $0000E125
                ; Name:          KIT-HIHAT-C4 
                ; sample_05      ; original address $0000DE68
                include "./music/sample_05.s"
                
                
                ; --------------------- Sound Sample 6 -------------------
                ; Start Address: $0000E126
                ; End Address:   $0000ED2B
                ; Name:          KIT-OPENHAT-D4
                ; sample_06      ; original address $0000E126
                include "./music/sample_06.s"

                
                ; --------------------- Sound Sample 7 -------------------
                ; Start Address: $0000ED2C
                ; End Address:   $0000FB04
                ; Name:          BASS2-F
                ; sample_07      ; original address $0000ED2C
                include "./music/sample_07.s"

                
                ; --------------------- Sound Sample 8 -------------------
                ; Start Address: $0000FB04
                ; End Address:   $00010837
                ; Name:          TIMELESS-GS
                ; sample_08      ; original address $0000FB04
                include "./music/sample_08.s"


                ; --------------------- Sound Sample 9 -------------------
                ; Start Address: $00010838
                ; End Address:   $00011461
                ; Name:          TIMEBASS-GS
                ; sample_09      ; original address $00010838
                include "./music/sample_09.s"
                
                
                ; --------------------- Sound Sample 10 -------------------
                ; Start Address: $00011462
                ; End Address:   $00013875
                ; Name:          CRUNCHGUITAR-C4
                ; sample_10      ; original address $00011462
                include "./music/sample_10.s"


                ; --------------------- Sound Sample 11 -------------------
                ; Start Address: $00013876
                ; End Address:   $00017F51
                ; Name:          LAUGH
                ; sample_11      ; original address $00013876
                include "./music/sample_11.s"


                ; --------------------- Sound Sample 12 -------------------
                ; Start Address: $00017F52
                ; End Address:   $0001B985
                ; Name:          IWANNA
                ; sample_12      ; original address $00017F52
                include "./music/sample_12.s"

                ; ------------- end of sample data ---------------



                ; ----------------------- unknown data -------------------------------
                ; music command 14 data
L0001B986 dc.w $0002, $0202                                                     
L0001B98A dc.w $000C

                ; music command 16 data
L0001B98C       dc.w $0014, $0018, $001C, $001E, $0020, $0025, $002B       
L0001B99A       dc.w $0031, $0037, $0039, $013C, $1EFE, $0000 
L0001B9A6       dc.w $0119, $08FD
L0001B9AA       dc.w $0000
L0001B9AC       dc.w $011E
L0001B9AE       dc.w $0000, $013E, $0000
L0001B9B4       dc.w $020F, $07FF, $000A
L0001B9BA       dc.w $FF01, $1902, $F605, $FF00, $0001, $190B, $FE01, $FE00
L0001B9CA       dc.w $0001, $2A14, $FE01, $FE00, $0001, $3E00, $0001, $3200

L0001B9DA dc.w $0000 
                ; ----------------------- unknown data -------------------------------





                ; ---------------------- song table ----------------------
                ; 4 values per song entry (channel settings)
                ; each 2byte value is an offset to the channel data for the song
                ; song1:
                ;       channel1: 3e + 1b9dc = 1ba1a
                ;       channel2: 48 + 1b9de = 1ba26
                ;       channel3: 49 + 1b9e0 = 1ba29
                ;       channel4: 51 + 1b9e2 = 1ba33
                ; song2:
                ;       channel1: off
                ;       channel2: off
                ;       channel3: off
                ;       channel4: 0a + 1b9ea = 1b9f4
                ;
                ; song3:
                ;       channel1: off
                ;       channel2: off
                ;       channel3: off
                ;       channel4: 04 + 1b9f2 = 
song_table                                              ; original address $0001b9dc

                ;--------------------- Song 00 - Title Screen - Music --------------
                ; offsets to channel initialisation data
song_00                                                 ; original address $0001b9dc
.channel_init_data_offset_00 dc.w song_00_channel_00_init_data-song_00     ; arpeggios             ; original address $0001b9dc + $3e = $1ba1a
.channel_init_data_offset_01 dc.w song_00_channel_01_init_data-(song_00+2) ; drums            ; original address $0001b9de + $48 = $1ba26
.channel_init_data_offset_02 dc.w song_00_channel_02_init_data-(song_00+4) ; bass           ; original address $0001b9e0 + $49 = $1ba29
.channel_init_data_offset_03 dc.w song_00_channel_03_init_data-(song_00+6) ; voice and guitar          ; original address $0001b9e2 + $51 = $1ba33
;.channel_init_data_offset_00 dc.w $003E                 ; original address $0001b9dc + $3e = $1ba1a
;.channel_init_data_offset_01 dc.w $0048                 ; original address $0001b9de + $48 = $1ba26
;.channel_init_data_offset_02 dc.w $0049                 ; original address $0001b9e0 + $49 = $1ba29
;.channel_init_data_offset_03 dc.w $0051                 ; original address $0001b9e2 + $51 = $1ba33




                ;-------------------- Song 01 - Game Over - Joker Laugh ----------------------
                ; offsets to channel initialisation data
song_01                                                 ; original address $0001b9e4
.channel_init_data_offset_00 dc.w $0000                                                 ; original address $0001b9e4 - n/a - channel not used
.channel_init_data_offset_01 dc.w $0000                                                 ; original address $0001b9e6 - n/a - channel not used
.channel_init_data_offset_02 dc.w $0000                                                 ; original address $0001b9e8 - n/a - channel not used
.channel_init_data_offset_03 dc.w song_01_channel_03_init_data-(song_01+6)              ; original address $0001b9ea + $0A = $1b9f4 - song_01_channel_03_init_data
;.channel_init_data_offset_00 dc.w $0000                 ; original address $0001b9e4 - n/a - channel not used
;.channel_init_data_offset_01 dc.w $0000                 ; original address $0001b9e6 - n/a - channel not used
;.channel_init_data_offset_02 dc.w $0000                 ; original address $0001b9e8 - n/a - channel not used
;.channel_init_data_offset_03 dc.w $000A                 ; original address $0001b9ea + $0A = $1b9f4 - song_01_channel_03_init_data





                ;-------------------- Song 02 - Game Complete - Batman IWanna ----------------------
                ; offsets to channel initialisation data
song_02                                                 ; original address $0001b9ec
.channel_init_data_offset_00 dc.w $0000                                                 ; original address $0001b9ec - n/a - channel not used            
.channel_init_data_offset_01 dc.W $0000                                                 ; original address $0001b9ee - n/a - channel not used 
.channel_init_data_offset_02 dc.w $0000                                                 ; original address $0001b9f0 - n/a - channel not used 
.channel_init_data_offset_03 dc.w song_02_channel_03_init_data-(song_02+6)              ; original address $0001b9f2 + $04 = $0001B9F6 - song_02_channel_03_init_data
;.channel_init_data_offset_00 dc.w $0000                 ; original address $0001b9ec - n/a - channel not used            
;.channel_init_data_offset_01 dc.W $0000                 ; original address $0001b9ee - n/a - channel not used 
;.channel_init_data_offset_02 dc.w $0000                 ; original address $0001b9f0 - n/a - channel not used 
;.channel_init_data_offset_03 dc.w $0004                 ; original address $0001b9f2 + $04 = $0001B9F6 - song_01_channel_03_init_data







                ;----------- Song 01 - Game Over - Joker Laugh - Channel 3 Init Data  ------------
song_01_channel_03_init_data                            ; original address $0001B9F4
                dc.b $07                                ; offset #$0e (14) - music data song_01_channel_3_data
                dc.b $80                                


 
                ;----------- Song 02 - Game Complete - Batman IWanna - Channel 3 Init Data  ------------
song_02_channel_03_init_data                            ; original address $0001B9F6
                dc.b $08
                dc.b $80 




song_01_channel_3_data                                  ; original address $0001B9F8 - Joker Laugh Channel Data
L0001B9F8       dc.b $90,$0B,$8F,$03,$18,$96,$80        ; Pattern/Command Data? 


song_02_channel_3_data                                  ; original address $0001B9FF - Batman Iwanna Channel Data
L0001B9FF       dc.b $90,$0C,$8F,$03,$18,$96,$80        ; Pattern/Command Data? 





                ;------------ songs channel data base address -------------
                ; base address in init_song 
song_channel_data_base                  ; original address $0001BA06
L0001BA06       dc.w (song_00_channel_0_data-L0001BA06)         ; offset value - #$1ba3e = song 00 channel 0 & 3 data
L0001BA08       dc.w (L0001BA42-L0001BA08)                      ; $1ba42
L0001BA0A       dc.w (song_00_channel_1_data-L0001BA0A)         ; offset value - #$1ba8b = song 00 channel 1 data
L0001BA0C       dc.w (song_00_channel_2_data-L0001BA0C)         ; offset value - #$1bb62 = song 00 channel 2 data
L0001BA0E       dc.w (song_00_channel_3_data-L0001BA0E)         ; offset value - #$1bbb1 = song 00 channel 3 data
L0001BA10       dc.w (L0001BBCC-L0001BA10)                      ; $1bbcc
L0001BA12       dc.w (L0001BBE1-L0001BA12)                      ; $1bbe1
L0001BA14       dc.w (song_01_channel_3_data-L0001BA14)         ; offset value -#$1c (-28) = song 01 channel 3 data
L0001BA16       dc.w (song_02_channel_3_data-L0001BA16)         ; offset value -#$17 (-23) = song 02 channel 3 data
L0001BA18       dc.w (L0001BC3A-L0001BA18)                      ; $1bc3a
;L0001BA06       dc.w $0038              ; offset value - #$1ba3e = song 00 channel 0 & 3 data
;L0001BA08       dc.w $003A              ; unknown offset
;L0001BA0A       dc.w $0081              ; offset value - #$1ba8b = song 00 channel 1 data
;L0001BA0C       dc.w $0156              ; offset value - #$1bb62 = song 00 channel 2 data
;L0001BA0E       dc.w $01A3              ; offset value - #$1bbb1 = song 00 channel 3 data
;L0001BA10       dc.w $01BC              ; unknown offset
;L0001BA12       dc.w $01CF              ; unknown offset
;L0001BA14       dc.w $FFE4              ; offset value -#$1c (-28) = song 01 channel 3 data
;L0001BA16       dc.w $FFE9              ; offset value -#$17 (-23) = song 02 channel 3 data
;L0001BA18       dc.w $0222




                ;-------- Song 00 Channel 0 Init Data - Title Music -------
song_00_channel_00_init_data                            ; original address $0001BA1A (offset song_table + #$00 + #$0000)
L0001BA1A       dc.b $81                                ; store ptr in channel data #$0002
L0001BA1B       dc.b $83, $08                           ; store next byte in channel data #$0012
                dc.b $00                                ; offset 0 - music data song_00_channel_0_data
L0001BA1E       dc.b $01,$01,$01,$01,$83,$08,$00,$80    ; Pattern/Command Data? 



                ;-------- Song 00 Channel 1 Init Data - Title Music -------
song_00_channel_01_init_data                            ; original address $0001ba26 (offset song_table + #$02 + #$0048)
L0001BA26       dc.b $81                                ; store ptr in channel data #$0002
L0001BA27       dc.b $02                                ; offset 4 - music data - song_00_channel_1_data
L0001BA28       dc.b $80                                ; Pattern/Command Data? 



                ;-------- Song 00 Channel 2 Init Data - Title Music -------
song_00_channel_02_init_data                            ; original address $0001BA29 (offset song_table + #$04 + #$0049)
L0001BA29       dc.b $81                                ; store ptr in channel data #$0002
L0001BA2A       dc.b $03                                ; offset 6 - music data - song_00_channel_2_data
L0001BA2B       dc.b $03,$03,$03,$03,$03,$06,$06,$80    ; Pattern/Command Data? 



                ;-------- Song 00 Channel 3 Init Data - Title Music -------
song_00_channel_03_init_data
L0001BA33       dc.b $81                                ; store ptr in channel data #$0002
L0001BA34       dc.b $83, $08                           ; store next byte in channel data #$0012
                dc.b $00                                ; offset 8 - music data - song_00_channel_3_data
L0001BA37       dc.b $04,$05,$05,$83,$08,$00,$80        ; Pattern/Command Data? 




                ;------------- data used by channel 0 (arpeggios) -------------------
song_00_channel_0_data                                  ; original address $0001BA3E - song_data_base + (#$0000)
L0001BA3E       dc.b $85,$87,$60
L0001BA41       dc.b $80


                ;------------- unknown channel data  -------------------
L0001BA42       dc.b $8F,$01,$90,$08,$8E,$8C,$84,$06
L0001BA4A       dc.b $38,$3A,$3F,$38,$3A,$3F,$38,$3A,$3F,$38,$3A,$3F,$38,$3A,$3F,$38
L0001BA5A       dc.b $3A,$3F,$38,$3A,$3F,$38,$3A,$3F,$38,$3A,$3F,$38,$3A,$3F,$38,$3A
L0001BA6A       dc.b $3F,$38,$3A,$3F,$38,$3A,$3F,$38,$3A,$3F,$38,$3A,$3F,$38,$3A,$3F
L0001BA7A       dc.b $38,$3A,$3F,$38,$3A,$3F,$38,$3A,$3F,$38,$3A,$3F,$38,$3A,$3F,$3A
L0001BA8A       dc.b $80


                ;------------- data used by channel 1 (Drums) --------------------
song_00_channel_1_data                                     ; original address $0001BA8B - song_data_base + (#$0004) 
L0001BA8B       dc.b $8F,$02,$90,$03,$0C,$06,$90,$05,$40,$06,$90,$06,$41,$06,$90,$05 
L0001BA9B       dc.b $40,$06,$90,$04,$18,$0C,$90,$06,$41,$0C,$90,$03,$0C,$06,$90,$05
L0001BAAB       dc.b $40,$06,$90,$06,$41,$06,$90,$05,$40,$06,$90,$04,$18,$0C,$90,$06
L0001BABB       dc.b $41,$06,$90,$05,$40,$06,$90,$03,$0C,$06,$90,$05,$40,$06,$90,$06
L0001BACB       dc.b $41,$06,$90,$05,$40,$06,$90,$04,$18,$0C,$90,$06,$41,$0C,$90,$03
L0001BADB       dc.b $0C,$06,$90,$05,$40,$06,$90,$06,$41,$06,$90,$05,$40,$06,$90,$04
L0001BAEB       dc.b $18,$0C,$90,$06,$41,$06,$90,$04,$18,$06,$90,$03,$0C,$06,$90,$05
L0001BAFB       dc.b $40,$06,$90,$06,$41,$06,$90,$05,$40,$06,$90,$04,$18,$0C,$90,$06
L0001BB0B       dc.b $41,$0C,$90,$03,$0C,$06,$90,$05,$40,$06,$90,$06,$41,$06,$90,$05
L0001BB1B       dc.b $40,$06,$90,$04,$18,$0C,$90,$06,$41,$06,$90,$05,$40,$06,$90,$03
L0001BB2B       dc.b $0C,$06,$90,$05,$40,$06,$90,$06,$41,$06,$90,$05,$40,$06,$90,$04
L0001BB3B       dc.b $18,$0C,$90,$06,$41,$0C,$90,$03,$0C,$06,$90,$05,$40,$06,$90,$06
L0001BB4B       dc.b $41,$06,$90,$05,$40
L0001BB50       dc.b $06,$90,$04,$18,$06
L0001BB55       dc.b $90,$04,$18,$06,$90,$04
L0001BB5B       dc.b $18,$06,$90,$04,$18,$06,$80

                ;-------------- data used by channel 2 (bass) -----------------------
song_00_channel_2_data                                  ; original address $0001BB62 - song_data_base + (#0006)
L0001BB62       dc.b $90,$07,$8F,$02,$8E,$8C,$14,$0C
L0001BB6A       dc.b $20,$0C,$20,$0C,$14,$06,$1E,$0C,$14,$06,$20,$0C,$1E,$0C,$20,$0C
L0001BB7A       dc.b $0F,$0C,$1B,$0C,$1B,$0C,$0F,$06,$19,$0C,$0F,$06,$1B,$0C,$19,$0C
L0001BB8A       dc.b $1B,$0C,$12,$0C,$1E,$0C,$1E,$0C,$12,$06,$1E,$0C,$12,$06,$1E,$0C
L0001BB9A       dc.b $20,$0C,$22,$0C,$0D,$0C,$19,$0C,$19,$0C,$0D,$06,$19,$0C,$0D,$06
L0001BBAA       dc.b $19,$0C,$1E,$0C
L0001BBAE       dc.b $20,$0C,$80





                ;-----------------------Channel  3 ( Voice & Guitar ) -------------------------
song_00_channel_3_data
L0001BBB1       dc.b $8F,$03,$90,$01,$87,$54,$23,$90,$90
L0001BBBA       dc.b $02,$23,$06,$23,$96,$90,$01,$87,$54,$23,$06,$23,$8A,$90,$02,$23
L0001BBCA       dc.b $9C,$80

L0001BBCC       dc.b $90,$0A,$8F,$04,$8B,$14,$01,$03,$3D,$48,$3F,$18,$3A,$60
L0001BBDA       dc.b $3A,$48,$3D,$18,$38,$60,$80

L0001BBE1       dc.b $90,$09,$8F,$02,$14,$0C,$20,$0C,$20
L0001BBEA       dc.b $0C,$14,$06,$1E,$0C,$14,$06,$20,$0C,$1E,$0C,$20,$0C,$14,$0C,$20
L0001BBFA       dc.b $0C,$20,$0C,$14,$06,$1E,$0C,$14,$06,$20,$06,$14,$06,$1E,$06,$14
L0001BC0A       dc.b $06,$20,$06,$14,$06,$0F,$0C,$1B,$0C,$1B,$0C,$0F,$06,$19,$0C,$0F
L0001BC1A       dc.b $06,$1B,$0C,$19,$0C,$1B,$0C,$0F,$0C,$1B,$0C,$1B,$0C,$0F,$06,$19
L0001BC2A       dc.b $0C,$0F,$06,$1B,$06,$0F,$06,$19,$06,$0F,$06,$1B,$06,$0F,$06,$80



L0001BC3A       dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00



                ; ----------------------- unused memory -----------------------------
                even
L0001BC4A dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BC5A dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BC6A dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BC7A dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BC8A dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BC9A dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BCAA dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BCBA dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BCCA dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BCDA dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BCEA dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BCFA dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BD0A dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BD1A dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BD2A dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BD3A dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BD4A dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BD5A dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BD6A dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BD7A dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BD8A dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BD9A dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BDAA dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BDBA dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BDCA dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BDDA dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BDEA dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BDFA dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BE0A dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BE1A dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BE2A dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BE3A dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BE4A dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BE5A dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BE6A dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BE7A dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BE8A dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BE9A dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BEAA dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BEBA dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BECA dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BEDA dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BEEA dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BEFA dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BF0A dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BF1A dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BF2A dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BF3A dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BF4A dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BF5A dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BF6A dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BF7A dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BF8A dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BF9A dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BFAA dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BFBA dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BFCA dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BFDA dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BFEA dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
L0001BFFA dc.w $0000, $0000, $0000
                ; --------------------------- unused memory -----------------------------








                ;----------------------------------------------------------------------------------------------------------------
                ; Pad bytes force the 'title_screen_start' to the address $1c000 or offset $18004 in the absolute assembled file
                ;--------------------------- Pad Bytes --------------------------------------------------------------------------
                dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000                        ; pad bytes to make code start @ $1c000
                ;--------------------------- Pad Bytes ----------------------------------
;

                ;------------------------ TITLE SCREEN ENTRY POINT ---------------------------
                ; original address hardcoded to $1c000, 
                ; I may change this so that the jump table is placed at $4000-$0c
                ; to create a jump table that starts at $3FF4 but this will require an update
                ; to the new game loader to change the start jmp addresses of the title screen
                ; and return to title screen loader methods.
                ; I want to keep this file as 'original' as possible and anyy changes wil be
                ; made in separate project.
                ;
title_screen_start                                              ; original routine address $0001c000
                bra.w   do_title_screen_start                   ; jmp $0001c008 



                ;-------------------- GAME OVER/COMPLETION ENTRY POINT -----------------------
end_game_start                                                  ; original routine address $0001c004
                bra.w   do_return_to_title_screen               ; jmp $0001d450




PANEL_INITIALISE_PLAYER_SCORE   EQU     $0007c81c               ; address of Panel.Initialise_Player_Score
PANEL_INITIALISE_PLAYER_LIVES   EQU     $0007c838               ; address of Panel.Initialise_Player_Lives
PANEL_STATUS_1                  EQU     $0007c874               ; address of Panel.Panel_Status_1  
PANEL_STATUS_2                  EQU     $0007c875               ; address of Panel.Panel_Status_2 
PANEL_HIGHSCORE                 EQU     $0007c878               ; address of Panel.High_Score 
PANEL_PLAYERSCORE               EQU     $0007c87c               ; address of Panel.Player_Score
LOADER_LOAD_LEVEL_1             EQU     $824                    ; address of Loader.Load_Level_1()

PANEL_STATUS_2_INFINITE_LIVES   EQU     $7                      ; panel status 2: bit 7 = 1 (infinite lives on)
PANEL_STATUS_2_GAME_COMPLETED   EQU     $6                      ; game completed = 1
PANEL_STATUS_2_GAME_OVER        EQU     $5                      ; game over/completion  - return from game
PANEL_STATUS_2_MUSIC_SFX        EQU     $0                      ; Music/SFX (0 = music, 1 = sfx)



                ;---------------------------- do title screenn start ----------------------------
                ; Routine to set up & run the title screen the first time the game is started.
                ; the routine 'return_to_title_screen' is called after game over/completion. 
                ;
                ; Sets Window start to bottom of screen (probably for scroll up routine)
                ; H/w Ref, standard DIWSRT & DIWSTOP
                ; PAL - $2c81, $2cc1
                ; NTSC- $2c81, $f4c1
                ;
do_title_screen_start                                           ; original routine address $0001c008
                clr.l   PANEL_HIGHSCORE                         ; clear Panel.HighScore
                move.l  highscore_table,PANEL_HIGHSCORE         ; set Panel.HighScore to top high-score
                ; continue as 'return_to_title_screen' below




                ;------------------------- return to title screen ----------------------------
                ; called after game over/compltion to return to the title screen.
                ;
return_to_title_screen                                          ; original address $0001c018
                lea.l   temp_stack_top,a7                       ; set temp stack space - $0001d6de,a7

.init_display_window                                            ; Initialise Window Scroll (start window = bottom of NTSC display)
                move.b  #$f4,copper_diwstrt                     ; reset window start line (usually $2c) - $0001d6e8
                move.b  #$f4,copper_diwstop                     ; reset widndow stop line (usually $2c or $f4 PAL/NTSC ) - $0001d6ec
.wait_frame
                moveq   #$01,d0                                 ; d0 = frames to wait + 1
                bsr.w   raster_wait_161                         ; wait for raster 161 - $0001c2f8
.init_system
                bsr.w   initialise_title_screen                 ; calls $0001c0d8
.init_display
                move.w  #$5000,$00dff100                        ; set 5 bitplane screen - BPLCON0
                lea.l   title_screen_colors,a0                  ; $0001d79a - screen colours
                bsr.w   copper_copy                             ; calls $0001d3a0
.init_game_status
                and.w   #$f89f,PANEL_STATUS_1                   ; clear panel status bits (panel status 1 & 2)
                                                                ; low 3 bits of status 1 (game over, life lost, timer expired)
                                                                ; bits 6 & 5 of status 2 (don't know what these do yet) - Think it's end game flags (success/fail etc)
.init_music
                bsr.w   init_title_music                        ; calls $0001c1a0 ; Play Song 01 (Title Tune)
.init_background
                bsr.w   copy_title_screen_bitplanes             ; calls $0001ca34 - copy title screen bitplanes to display memory (copper list display)


                ;************ TITLE SCREEN WAIT LOOP *****************
                ; Manage hi-score entry and text typer display.
                ; The text typer controls the main title-screen wait
                ; loop, waits for joystick button press to jump
                ; to 'start_game' below.
.title_screen_loop
                bsr.w   hi_score_and_text_typer                 ; calls $0001c586


                ;************* START GAME - LOAD LEVEL 1 *************
                ;text typer jumps out to here when start button pressed
start_game                                                      ; original address $0001c05e
                not.w   start_game_flag                         ; invert bits, value not used anywhere else in the title screen. $0001c09c
.wait_diwstrt
                cmp.b   #$f4,copper_diwstrt                     ; L0001d6e8
                bne.b    .wait_diwstrt                          ; if starting before title screen has openned, then wait 
.wait_frame
                moveq   #$01,d0                                 ; d0 = frames to wait + 1
                bsr.w   raster_wait_161                         ; wait for raster 161 - $0001c2f8
.init_game
                move.l  highscore_table,PANEL_PLAYERSCORE       ; set player score in panel to high score (reset next)
                jsr     PANEL_INITIALISE_PLAYER_SCORE           ; calls Panel.Initialise_Player_Score
                jsr     PANEL_INITIALISE_PLAYER_LIVES           ; calls Panel.Initialise_Player_Lives
                jsr     Stop_Audio                              ; calls $00004008
.load_level_1
                jmp     LOADER_LOAD_LEVEL_1                     ; jmp $00000824 - Loader.Load_Level_1




                ;---------------------- fatal error --------------------
                ; loop forever increment backgounr colour in tight loop
                ; UNUSED CODE
fatal_error
                jmp     do_fatal_error                          ; jmp $0001d542 



start_game_flag                                                 ; original address $0001c09c
                dc.w $0000                                      ; bits are inverted (not.w) on game_start 





                ;------------------------- do window scroll -------------------------
                ; called from level 3 interrupt handler, manages the title screen
                ; window scroll up (on title screen start) and the scroll down
                ; (on game start).
                ;
                ; The window scrolls in at 1 raster per call.
                ; The window scrolls out at 4 rasters per call.
                ;
do_window_scroll
                tst.w   start_game_flag                         ; test if game has started, $0001c09c
                bne.b  do_scroll_down                           ; jmp L0001c0ba
.do_scroll_up                                                   ; original address $0001c0a6
                cmp.b   #$2c,copper_diwstrt                     ; test window start position byte, $0001d6e8 
                beq.b   .exit                                   ; if window is fully 'open' (scrolled to top), jmp $0001c0b8
                sub.w   #$0100,copper_diwstrt                   ; else, scrol window top up by 1 raster line, $0001d6e8
.exit
                rts  

do_scroll_down                                                 ; original address $0001c0ba
                cmp.b   #$f4,copper_diwstrt                     ; test if window top is at bottom of display, $0001d6e8
                beq.b   .exit                                   ; if yes, then exit
                bcs.b   .scroll_down                            ; if no, then scroll down
.already_down
                move.b  #$f0,copper_diwstrt                     ; if somewhere near, set at the bottom
.scroll_down
                add.w   #$0400,copper_diwstrt                   ; scroll window top down by 4 raster lines, $0001d6e8
.exit
                rts 




                ;--------------------------- initialise title screen ----------------------------
                ; set up the system, interrupts annd display.
                ; NB: Level 6 interrupt enabled, but no handler (set previously in disk loader)
                ;
initialise_title_screen                                         ; original routine address $0001c0d8
                move.l  #$f481f4c1,$00dff08e                    ; DIWSTRT/DIWSTOP - Initialise
                move.w  #$7fff,d0       
                move.w  d0,$00dff096                            ; DMACON - DMA off
                move.w  d0,$00dff09a                            ; INTENA - Interrupts off
                move.w  d0,$00dff09c                            ; INTREQ - Clear Interrupt Requests
                move.l  #level_1_interrupt_handler,$00000064    ; Level 1 Interrupt Vector
                move.l  #level_2_interrupt_handler,$00000068    ; Level 2 Interrupt Vector           
                move.l  #level_3_interrupt_handler,$0000006c    ; Level 3 Interrupt Vector   
                move.l  #level_4_interrupt_handler,$00000070    ; Level 4 Interrupt Vector        
                move.l  #level_5_interrupt_handler,$00000074    ; Level 5 Interrupt Vector
                move.w  #$e028,$00dff09a                        ; PORTS/TIMERS(2),VERTB(3),EXTER(6),INTEN,SET/CLR (no level 1,4,5) !No Level 6 handler
                move.w  #$83c0,$00dff096
                move.l  #copper_list,$dff080                     ;#$0001d6e2,$00dff080
                move.w  d0,$00dff088
                move.b  #$7f,$00bfed01
                move.b  #$7f,$00bfed01
                jsr     Initialise_Music_Player                 ; calls $00004000
                move.l  #$00001f40,d0                           ; d0 = bitplane size in bytes (8000)
                bra.w   reset_title_screen_display              ; calls $0001d2de

clear_keycode_and_exit                                          ; original address $0001c16a
                clr.w   raw_key_code_store                      ;$L0001c2f0 - clear raw keycode store
global_rts                                                      ; original address $0001c170
                rts                                             ; called from elsewhere.




                ;------------------- Do Title Screen Menu Options --------------------
                ; check for key presses and do menu screen menu options.
                ; called from typer main loop when waiting for start game.
                ;
                ;       F2 = Music/SFX toggle 
                ;       
do_title_screen_menu_options                                            ; original routine address $0001c172
                btst.b  #$0000,raw_keyboard_serial_data_byte            ; is last key code - key up? $0001c2ed
                bne.w   clear_menu_flag_and_exit                        ; no, clear menu flag and exit, $0001c1b8
                tst.w   menu_keypress_flag                              ; $0001c2f2
                bne.w   global_rts                                      ; jmp $0001c170
.check_f2                                                               ; original address $0001c188
                cmp.w   #$005c,raw_keyboard_serial_data_word            ; compare 'F2' key press, $0001c2ec 
                bne.b   clear_menu_flag_and_exit                        ; no, clear menu flag and exit, $0001c1b8
.is_f2               
                not.w   menu_keypress_flag                              ; toggle flag. $0001c2f2
                bchg.b  #PANEL_STATUS_2_MUSIC_SFX,PANEL_STATUS_2        ; $0007c875

                ; fall through to init_title_music (toggle on/off)




                ;------------------- Init Title Music -----------------
init_title_music                                                        ; original routine address $0001c1a0
                btst.b  #PANEL_STATUS_2_MUSIC_SFX,PANEL_STATUS_2        ; music or sfx bit of panel_status_2 
                beq.b   .init_song_01 
                jmp     Silence_All_Audio                               ; calls $00004004 - end music
.init_song_01
                moveq   #$01,d0                                         ; set tune to play? 
                jmp     Init_Song                                       ; jmp $00004010
                ; uses rts in Init_Song to return to caller.




                ;------------------ clear menu flag and exit ----------------
                ; used by the do_title_screen_menu_options routine above.
                ; clears keypress flag and exit, used to detect single
                ; keypress.
clear_menu_flag_and_exit
                clr.w menu_keypress_flag                        ; L0001c2f2
                rts




                ;----------------------- do infinite lives cheat code ----------------------
                ; This routine handles the cheat code entry, matching and toggling.
                ; It's a bit heavy for an ISR.      
                ;
                ; Called from:
                ;       level_2_interrupt_handler
                ;
do_infinite_live_cheat_code                                             ; original routine address $0001c1c0
                btst.b  #$0000,raw_keyboard_serial_data_byte            ; test lsb of raw keyboard data - $0001c2ed
                bne.w   clear_keycode_and_exit                          ; if lsb = 1 then clear $0001c2f0.w and exit (key up) - jmp $0001c16a

                tst.w   raw_key_code_store                              ; test raw keycode store - $0001c2f0
                bne.b   .exit                                           ; if keycode store is not empty, exit - jmp $0001c24a

                ; check if keycode is an expected code
                ; if so enqueue it
                ; if not then exit
.process_raw_key_code
                move.w  raw_keyboard_serial_data_word,d0                ; d0 = raw keyboard key code - $0001c2ec
                and.b   #$fe,d0                                         ; d0 = mask lsb and high byte
                move.w  d0,raw_key_code_store                           ; $0001c2f0 ; store raw key code
                lea.l   raw_key_code_table,a0                           ; $0001c258 ; raw keycode table (ends with $FFxx)

.match_keycodes_loop                                                    ; original address $0001c1ea
                cmp.b   (a0),d0
                beq.w   .enqueue_key_code                               ; $0001c1fe ; key code is in the list, pop it in the queue

.unmatched_keycode                                                      ; original address $0001c1f0
                cmp.b   #$ff,(a0)                                       ; continue checking until the end of list ($ff value is part of code - dodgy/bug)
                beq.w   .exit                                           ; then exit - jmp $0001c24a

                addq.l  #$02,a0                                         ; match next value with keycode
                bra.w   .match_keycodes_loop                            ; jmp $0001c1ea ; loop


                ; this is a queue of entered valid keycodes
                ; valid key codes are added to the end of the queue
.enqueue_key_code                                                       ; original address $0001c1fe
                move.b  $0001(a0),d1                                    ; d1 = key code table second byte match
                lea.l   keyboard_buffer_start+1,a0                        ; $0001c24d
                moveq   #$05,d0                                         ; d0 = loop counter (6 times)

.shift_chars_loop                                                       ; original address $0001c20a
                move.b  (a0),-$0001(a0)                                 ; shift bytes down in memory by 1 character
                addq.l  #$01,a0                                         
                dbf.w   d0,.shift_chars_loop                            ; $0001c20a ; Loop for all characters
                move.b  d1,keyboard_buffer_start+5                      ; $0001c251 ; d1 = key code table second byte match. add to end of queue


                ; check if cheat code has been entered 
                ; in the queue, compares against
                ; stored values.
.check_cheat_code
                lea.l   keyboard_buffer_start,a0                        ; $0001c24c
                lea.l   cheat_code,a1                                   ; $0001c252
                moveq   #$05,d0                                         ; d0 = 5 + 1 (loop counter)
.compare_loop
                cmpm.b  (a0)+,(a1)+
                bne.b   .exit                                           ; jmp $0001c24a
                dbf.w   d0,.compare_loop                                ; loop 6 times, jmp $0001c228
                ; if we get here then the secret cheat code has been entered.
                ; 'IXLLLL' - 'jammmm' - 6 char code
.toggle_infinite_lives
                bchg.b  #PANEL_STATUS_2_INFINITE_LIVES,PANEL_STATUS_2           ; #$0007,$0007c875 ; Enable CHEAT?
                move.b  #$f4,copper_diwstrt                                     ; reset title screen window (closed) $0001d6e8
                move.l  #$00001f40,d0                                           ; bitplane size in bytes (8000)
                bsr.w   reset_title_screen_display                              ; calls $0001d2de ; reset title screen display
.exit
                rts 




                ;------------------------ keyboard buffer --------------------------
                ; contains values looked up from 'raw_key_code_table' when
                ; matched with raw keycodes.
                ; it is a queue, so new data enters at the end and old data is
                ; shifted towards the front.
                ; FIFO Queue structure.
                ;
keyboard_buffer_start                                   ; original address $0001c24c
                dc.b $20,$20,$20,$20,$20,$20


                ; ------------------------ cheat code----------------------------------
                ; This is an obfuscated cheat code string. 'IXLLLL' which is compared
                ; against the keyboard buffer above when a new acceptable key is
                ; entered into the buffer. 
cheat_code                                              ; original address $0001c252
                dc.b $49,$58,$4c,$4c,$4c,$4c            ; IXLLLL 'JAMMMM'


                ;-------------------- cheat - raw key codes ----------------------
                ; key code table - used to match keys pressed with expected
                ; cheat code values.
                ; - the second byte is 
                ;
                ; - the cheat keycodes are mapped to other characters (i presume to obsuscate)
                ; - J - maps to 'I'
                ; - A - maps to 'X'
                ; - M - maps to 'L'
                ;
                ; - the cheat code matched against is then 'IXLLL'
                ;
                ; - why bother doing this is anyones guess, does anyone really care that much 
                ; - about hiding cheat codes?
                ;
raw_key_code_table
                dc.b $be,$58        ; X
                dc.b $ae,$31        ; 1            
                dc.b $92,$51        ; Q
                dc.b $90,$4C        ; L
                dc.b $D0,$20        ; ' '
                dc.b $B0,$30        ; 0
                dc.b $DA,$4A        ; J
                dc.b $B2,$49        ; I
                dc.b $CE,$46        ; F
                dc.b $94,$56        ; V
                dc.b $ff,$fe            ; inserted my own end of table loop code

;L0001c26c       dc.b $4E,$73                   ; back to code (below)
;L0001c26e       dc.b $48,$E7                   ; back to code (below)
;L0001c270       dc.b $FF,$FE                   ; back to code (below) (ends with $FFxx)













                even
                ;*********************************************************************************************************************
                ;*********************************************************************************************************************
                ;*********************************************************************************************************************
                ;
                ;
                ;       Interrupt Service Routines (ISRs)
                ;
                ;
                ;*********************************************************************************************************************
                ;*********************************************************************************************************************
                ;*********************************************************************************************************************




                ;---------------------- level 1 interrupt handler -------------------
                ; Do nothing. This should probably clear the INTREQ bits for
                ; Level 1 interrupts
                ;
                ; *** This interrupt is not enabled in the title screen ***f
                ;
level_1_interrupt_handler                                       ; original address $0001c26c
                rte




                ;---------------------- level 2 interrupt handler -------------------
                ; PORTS/TIMERS - Level 2 Interrupt Handler
                ; CIA-A Timers & Ports
                ;
                ; The ICR Register is cleared by reading the register, but this
                ; code immediately sets it back to the value it just read.
                ; The implications of this are that if this interrupt was not
                ; raised by the CIAA then bit 7 will = 0, this means that when
                ; that value is written back to the register then it will
                ; mask the interrupts that just occurred, and prevent them
                ; from occurring again.
                ;
                ; Conversly if the interrupt was raised by the CIAA then Bit 7 
                ; will be 1, this will enable the interrupt enable bit for the 
                ; interrupts that were raised. This code looks dodgy/hacky
                ;
                ; later the ICR is then set to #$08 which masks the SP bit
                ; this sets the SP bit to 0, which is the keyboard interrupt
                ; serial register bit. So this interrupt is being disabled here
                ; as far as I can make out.
                ;
                ; Obviously this works for reading the keyboard etc, but...
                ; it doesn't appear correct as per the h/w refs that I've read.
                ;
                ; This interrupt is enabled in 'initialise_title_screen' (PORTS - LVL2)
                ;
level_2_interrupt_handler                                                       ; original routine address $0001c26e
                movem.l d0-d7/a0-a6,-(a7)
                move.b  $00bfec01,raw_keyboard_serial_data_byte                 ; SDR - $0001c2ed ; keyboard serial data
                move.b  $00bfed01,$00bfed01                                     ; ICR - WTF-1!, clear the interrupt control if not a CIAA/Set Interrupts if is CIAA
                move.w  #$0808,$00dff09c                                        ; INTREQ - Clear PORTS(2), 
                                                                                ; WTF-2! - Clear RBF(5) (keyboard serial) - Level 5 Interrupt!
                move.b  #$08,$00bfed01                                          ; ICR - Mask SP bit = 0 (keyboard serial)
                move.b  #$60,$00bfee01                                          ; CRA - Timer A Control - INMODE=1, SPMODE=1
                bsr.w   do_infinite_live_cheat_code                             ; calls $0001c1c0
                movem.l (a7)+,d0-d7/a0-a6
                rte




                ;---------------------- level 3 interrupt handler -------------------
                ; Vertical blank interrupt handler.
                ;   - plays current song
                ;   - scrolls window up/down
                ;   - does hacky stuff with CIAA and keyboard port 
                ;      - reset for serial register input (end of keyboard ACK)
                ;
                ; This interrupt is enabled in 'initialise_title_screen' (VERTB)
                ;
level_3_interrupt_handler
                movem.l d0-d7/a0-a6,-(a7)
                jsr     Play_Song                               ; $00004018 ; play song
                bsr.w   do_window_scroll                        ; calls $0001c09e
                move.b  $00bfed01,$00bfed01                     ; ICR -> ICR (why?) CIAA nothing to do with level 3 interrupts, also just looks like nonsence
                move.b  #$08,$00bfee01                          ; CIAA - CRA - one shot timer A, stop timer A, SPMODE = input (keyboard)
                move.b  #$88,$00bfed01                          ; CIAA - ICR - enable SP interrupt LVL 2 (keyboard())
                move.w  #$0020,$00dff09c                        ; Clear VERTB interrupt
                not.w   vertical_blank_toggle                   ; toggle vertical blank flag, $0001c2e8
                movem.l (a7)+,d0-d7/a0-a6
                rte  




                ;---------------------- level 4 interrupt handler -------------------
                ; Do nothing. This should probably clear the INTREQ bits for
                ; Level 4 interrupts
                ;
                ; *** This interrupt is not enabled in the title screen ***f
                ; 
level_4_interrupt_handler                                       ; original address $0001c2e4
                rte




                ;---------------------- level 5 interrupt handler -------------------
                ; Do nothing. This should probably clear the INTREQ bits for
                ; Level 5 interrupts
                ;
                ; *** This interrupt is not enabled in the title screen ***f
                ;
level_5_interrupt_handler                                       ; original address $0001c2e6
                rte




                ;---------------------- level 6 interrupt handler --------------------
                ; ***** MISSING ALTOGETHER, BUT INTERRUPTS ARE ENABLED FOR THIS *****
                ; TODO: Add a handler once i've got this assembling as is.



                even
vertical_blank_toggle                                   ; original address $0001C2E8
                dc.w $0000                              ; value appears unused by the title screen (toggled every frame)

unused_002                                              ; original address $0001C2EA
                dc.w $0000



raw_keyboard_serial_data_word                                           ; original address $0001C2EC
                dc.b $00                                                ; keyboard raw key code word (high byte always 0)
raw_keyboard_serial_data_byte                                           ; original address $0001c2ed
                dc.b $00                                                ; keyboard raw key code byte

                even
                dc.w $0000 

raw_key_code_store                                                      ; original address $0001c2f0
                dc.w $0000                                              ; keyboard reading data/flags

menu_keypress_flag                                                      ; original address $0001c2f2
                dc.w $0000                                              ; 0 = music, $ffff = sfx

                dc.w $0000, $0000




                ;------------------------- wait raster 161 -------------------------
                ; Waits for raster 161 (#$a1) in a busy loop, it will also
                ; wait for multiple frames for the value set in d0.l
                ;
                ; It has a dodgy processor wait loop which prevents false +ve's
                ; with the vertical check on the same raster line (it's a bit shit) 
                ;
                ; reading and comparing a byte value might not be the best approach
                ; on a custom register.
                ;
                ; IN: D0.l = number of frames to wait + 1
                ;
raster_wait_161                                                 ; original routine address $0001c2f8

        IFND VBLANK_FIX
.vwait 
                cmp.b   #$a1,$00dff006                          ; compare VHPOSR with #$a1 (161)
                bne.b   .vwait
                move.w  #$001e,d1
.processor_wait
                dbf.w  d1,.processor_wait
                dbf.w  d0,raster_wait_161
        ELSE
.vwait1 
                cmp.b   #$a1,$00dff006                          ; compare VHPOSR with #$a1 (161)
                bne.b   .vwait1
.vwait2 
                cmp.b   #$a2,$00dff006                          ; compare VHPOSR with #$a2 (162)
                bne.b   .vwait2
                dbf.w  d0,.vwait1
        ENDC

return_rts      rts





                even
xy_coords
x_coord                                                 ; original address L0001c310
                dc.w    $0000                           ; x co-ord (byte value)
y_coord                                                 ; original address L0001c312
                dc.w    $0000                           ; y co-ord (line value)
current_text_ptr                                        ; original address L0001c314
                dc.l    $00000000                       ; $0001c784 - address of start of text being displayed (used for looping back to start)




unused_background_flash                                 ; original routine address $0001c318
                add.w #$0001,d7
                move.w d7,$00dff180
                rts 




                ;----------------------- text typer ------------------------
                ; type out screen of text, also process control codes for
                ; special chars and inserting hi score table etc.
                ;
                ; IN: a6 - text structure for display
                ;          1 word - display co-ords (x,y bytes)
                ;          x bytes - text & display codes
                ;          1 byte  - #$ff - end text display
                ;
text_typer                                                      ; original routine address $0001c324
                move.l  a6,current_text_ptr                     ; $0001c314 ; store a6 address (used for looping when CODE #$00)
                move.b  (a6)+,x_coord+1                         ; store x coord - $0001c311
                move.b  (a6)+,y_coord+1                         ; store y coord - $0001c313

resume_text_start_line
                moveq   #$00,d0
                move.w  y_coord,d0                              ; $0001c312 ; d0 = y co-ord
                mulu.w  #$0028,d0                               ; d0 = d0 * 40 (bytes per scan line)
                add.w   x_coord,d0                              ; $0001c310 ; d0 = d0 + x co-ord
                add.l   #DISPLAY_BITPLANE_ADDRESS,d0            ; #$00063190,d0 ; add bitplane base address
                exg.l   d0,a2                                   ; a2 = display destination address
                movea.l a2,a3                                   ; a3 = display destination address

resume_text_current_position
                tst.w   typer_extended_command_1                ; $0001c782 - exension command/params (for commands #$02)
                bne.w   continue_wait_or_start_game             ; jmp $0001c50e
                move.b  (a6)+,d0                                ; get display param
                cmp.b   #$ff,d0
                beq.w   return_rts                              ; $0001c30e
                cmp.b   #$0d,d0
                beq.w   crlf                                    ; jmp $0001c4d0 - crlf - carriage return plus line feed
                cmp.b   #$0e,d0
                beq.w   lf                                      ; jmp $0001c4dc - lf, line feed
                cmp.b   #$01,d0
                beq.w   cls                                     ; jmp $0001c4e8 - clear screen
                cmp.b   #$06,d0
                beq.w   _nop                                    ; jmp $0001c580 - no operation
                cmp.b   #$02,d0
                beq.w   wait_or_start_game                      ; jmp $0001c4fe - check fire button/start game?
                cmp.b   #$03,d0
                beq.w   hi_scores                               ; jmp $0001c53e - start displaying hi score table
                cmp.b   #$04,d0
                beq.w   end_hi_scores                           ; jmp $0001c54e - resume typer after hi score table
                cmp.b   #$05,d0
                beq.w   hi_score_and_text_typer                 ; jmp $0001c586 - name up/enter initials
                cmp.b   #$40,d0
                beq.w   .copyright_symbol                       ; jmp $0001c3f6 '@' convert to 2nd character after 'Z' - (c) symbol 
                cmp.b   #$26,d0
                beq.w   .ampersand_symbol                       ; JMP $0001c3e6 '&' convert to 3rd character after 'Z' - '&' symbol
                cmp.b   #$23,d0
                beq.w   maybe_backspace                         ; jmp $0001c558 '#' symbol - unsure, decrements x offset
                cmp.b   #$2e,d0
                beq.w   .fullstop_symbol                        ; jmp $0001c3ee '.' convert to 1st character after 'Z'
                and.w   #$003f,d0
                beq.w   loop_text_typer                      ; jmp $0001c534 - #$00 = ***** Loop Text Typer ***** 
                cmp.b   #$20,d0
                beq.w   .space_symbol                           ; jmp $0001c3fe ' ' - increment x position.       
                cmp.b   #$30,d0
                blt.w   .plot_character                         ; jmp $0001c404 - plot raw char code from offset
                sub.w   #$0014,d0
                bra.w   .plot_character                         ; jmp $0001c404 - subtract ' ' char and plot raw char code

.ampersand_symbol
                move.w  #$002c,d0
                bra.w   .plot_character                         ; jmp $0001c404

.fullstop_symbol
                move.w  #$002a,d0
                bra.w   .plot_character                         ; jmp $0001c404

.copyright_symbol
                move.b  #$002b,d0                               ; d0 = 43 - character offset (plus #$30)
                bra.w   .plot_character                         ; jmp $0001c404 - 

.space_symbol
                addq.l  #$01,a3
                bra.w   resume_text_current_position            ; jmp $0001c352

.plot_character
                mulu.w  #$0050,d0
                add.l   #ASSET_CHARSET_BASE,d0                  ; #$0003f1ea,d0
                exg.l   d0,a1
                moveq   #$04,d7                                 ; d7 = 4 + 1 = 5 bitplanes
                moveq   #$00,d1
                movea.l a3,a2
.copy_loop
                move.b  (a1),(a2)                               ; copy char data - line 1
                move.b  $0002(a1),$0028(a2)                     ; copy char data - line 2
                move.b  $0004(a1),$0050(a2)                     ; copy char data - line 3
                move.b  $0006(a1),$0078(a2)                     ; copy char data - line 4
                move.b  $0008(a1),$00a0(a2)                     ; copy char data - line 5
                move.b  $000a(a1),$00c8(a2)                     ; copy char data - line 6
                move.b  $000c(a1),$00f0(a2)                     ; copy char data - line 7
                move.b  $000e(a1),$0118(a2)                     ; copy char data - line 8

                adda.l  #$00000010,a1                           ; add 16 bytes to source (next bitplane of character)
                adda.l  bitplane_size,a2                        ; increment dest to next bitplane.
                dbf.w   d7,.copy_loop                           ; bitplane loop, jmp $0001c416
                
                addq.l  #$01,a3                                 ; increment x position
                bra.w   resume_text_current_position            ; loop next char, $0001c352
                rts  




                ;--------------------- plot character x & y ----------------------
                ; plot character at x and y co-ords
                ; IN: d0 = character offset to plot starts at character '0'
                ;
char_plot_x_coord                               ; original address $0001c45a
                dc.w $0000                      ; x co-ord (byte value)
char_plot_y_coord                               ; original address $0001c45c
                dc.w $0000                      ; y co-ord (line value)

plot_character
                moveq   #$00,d3
                moveq   #$00,d2
                move.w  char_plot_y_coord,d2            ; L0001c45c,d3 ; y co-ordinate
                move.w  char_plot_x_coord,d2            ; L0001c45a,d2 ; x co-ordinate
                mulu.w  #$0028,d3                       ; d3 = d3 * 40 (raster line)
                add.w   d3,d2                           ; d2 = x & y co-ords byte offset
                add.l   #DISPLAY_BITPLANE_ADDRESS,d2    ; #$00063190 ; add bitplane 1 base address
                exg.l   d2,a2                           ; a2 = dest address, d1 = prev value of a2
                and.l   #$0000003f,d0                   ; clamp d0 to 0-63
                mulu.w  #$0050,d0                       ; 80 bytes per char (16 bytes per bitplane) 8*8
                add.l   #ASSET_CHARSET_BASE,d0           ; #$0003f1ea ; character set gfx base address
                exg.l   d0,a1                           ; a1 = character source address
                moveq   #$04,d7                         ; d7 = 4 + 1 - bitplane loop count
                moveq   #$00,d1                         ; d1 = 0
.copy_loop
                move.b  (a1),(a2)                       ; copy character data line 1
                move.b  $0002(a1),$0028(a2)             ; copy character data line 2
                move.b  $0004(a1),$0050(a2)             ; copy character data line 3
                move.b  $0006(a1),$0078(a2)             ; copy character data line 4
                move.b  $0008(a1),$00a0(a2)             ; copy character data line 5
                move.b  $000a(a1),$00c8(a2)             ; copy character data line 6
                move.b  $000c(a1),$00f0(a2)             ; copy character data line 7
                move.b  $000e(a1),$0118(a2)             ; copy character data line 8
                adda.l  #$00000010,a1                   ; a1 = start next bitplane of char
                adda.l  bitplane_size,a2                ; L0001ca3e,a2
                dbf.w   d7,.copy_loop
                rts



                ;----------------- crlf ---------------------
                ; carriage return plus line feed.
                ; continue typing at the start of the next
                ; line on the screen.
crlf                                                    ; original address $0001c4d0
                add.w   #$0008,y_coord                  ; $0001c312, add 8 scan lines to y coord
                bra.w   resume_text_start_line          ; jmp $0001c336



                ;---------------- line feed -----------------
                ; continue typing one line down without
                ; returning to the start of the line.
lf                                                      ; original address $0001c4dc
                adda.l  #$00000140,a3                   ; add 320 to raster line (next page)
                movea.l a3,a2                           ; update dest display ptrs
                bra.w   resume_text_current_position    ; jmp $0001c352



                ;--------------- clear screen --------------
                ; clear screen bitplanes and reset x,y
                ; coords.
cls
                bsr.w   copy_title_screen_bitplanes     ; calls $0001ca34
                move.w  #$0007,x_coord                  ; $0001c310
                clr.w   y_coord                         ; $0001c312 
                bra.w   resume_text_start_line          ; $0001c336 



                ;-------------- code #$02 -----------------
                ; code: #$02 - 
                ; initialise 'wait_or_start_game'
                ; get the number of frames to wait for
                ; displaying the current page of text.
wait_or_start_game                                      ; original routine address $0001c4fe
                move.b  (a6)+,d0
                move.b  d0,typer_extended_command_1     ; $0001c782
                move.b  (a6)+,d0
                move.b  d0,typer_extended_command_2     ; $0001c783
                ; falls through to 'wait_or_start_game'


                ;------------------ wait or start game ---------------
                ; continuation of the the wait_or_start_game command/
                ; decrements the counter, waits for the required number
                ; of frames.
                ;
                ; if joystick button is pressed (port 2)
                ; then jumps to start game code.
                ;
continue_wait_or_start_game
                moveq   #$00,d0
                bsr.w   raster_wait_161                 ; calls $0001c2f8
                bsr.w   do_title_screen_menu_options    ; calls $0001c172
                btst.b  #$0007,$00bfe001                ; Port 2 Fire Button (Joystick)
                beq.b   .firebutton_pressed             ; $0001c52e ; if button pressed, start game?
                sub.w   #$0001,typer_extended_command_1 ; $0001c782 - decrement fame wait time
                bra.w   resume_text_current_position    ; jmp $0001c352

.firebutton_pressed
                jmp     start_game                      ; jmp $0001c05e



                ;--------------- loop text typer -----------------
                ; CODE #$00 - restart text typer from initial
                ;             saved text prt
loop_text_typer                                                 ; original address $0001c534
                movea.l current_text_ptr,a6                     ; $0001c314 [00000000],a6
                bra.w   text_typer                              ; calls $0001c324 - display text
                ; use text_typer rts to return



                ;--------------------- hi scores -------------------
                ; CODE: #$03 - start displaying Hi Score Table
                ;
hi_scores                                                       ; original routine address $0001c53e
                move.l  a6,temp_typer_text_ptr                  ; $0001c77e ; store current text typer ptr position
                movea.l #high_score_display_text,a6             ; #$0001c974 ; resume text from this location (HI SCORE TABLE)
                bra.w   resume_text_current_position            ; jmp $0001c352



                ;-------------------end hi scores ------------------
                ; CODE: #$04 - resume typing text after hi scores
                ;
end_hi_scores                                                   ; original routine address $0001c54e
                movea.l temp_typer_text_ptr,a6                  ; $0001c77e ; restore text typer source ptr from saved location
                bra.w   resume_text_current_position            ; jmp $0001c352



maybe_backspace                                                 ; original routine address $0001c558
                move.w  x_coord,char_plot_x_coord               ; $0001c45a
                move.w  y_coord,char_plot_y_coord               ; $0001c45c
                move.b  #$20,d0
                bsr.w   plot_character                          ; calls $0001c45e
                sub.w   #$0001,x_coord                          ; $0001c310
                bra.w   resume_text_current_position            ; jmp $0001c352



                ;-------------------- nop -----------------------
                ; do nothing, just resume text typing
_nop                                                            ; original address $0001c580
                bra.w   resume_text_current_position            ; jmp $0001c352



                ;-------- dangling rts instruction --------------
                rts







                ;------------------------ hi score and text typer -------------------------
                ; If Player score is a high score then insert is into the 
                ; highscore table.
                ; enter intials.
                ; start title screen text typer loop.
                ;
hi_score_and_text_typer                                                 ; original routine address $0001c586
                lea.l   highscore_table+16,a5                           ; L0001ca28,a5 ; Lowest Hi Score (5th)
                lea.l   end_highscore_display_text,a4                   ; L0001c9fc,a4 ; end of score table display text
                moveq   #$00,d0
.score_check_loop
                move.l  (a5),d6                                         ; d6 = next lowest high score
                cmp.l   PANEL_HIGHSCORE,d6                              ; High Score/Player Score
                bgt.w   .not_high_score                                 ; jmp $0001c5ec
.is_higher_score
                ; copy score display text down the list one entry
                move.l  (a5),$0004(a5)                                  ; shift lowest high score down the table
                subq.l  #$04,a5                                         ; update pointer to next highest score
                suba.l  #$00000017,a4                                   ; #$17 (23) update pointer to next highest score (display text)
                move.b  $000a(a4),$0021(a4)                             ; copy display test down the table.
                move.b  $000b(a4),$0022(a4)
                move.b  $000c(a4),$0023(a4)
                move.b  $000f(a4),$0026(a4)
                move.b  $0010(a4),$0027(a4)
                move.b  $0011(a4),$0028(a4)
                move.b  $0012(a4),$0029(a4)
                move.b  $0013(a4),$002a(a4)
                move.b  $0014(a4),$002b(a4)
                addq.w  #$01,d0                                         ; increase index counter
                cmp.w   #$0005,d0                                       ; 5 high scores to check against
                bne.w   .score_check_loop

                ; d0 = high score entry counting from bottom of the table 1-5
.not_high_score
                tst.w   d0
                beq.w   display_title_screen_text                       ; if d0 = 0 then not an high score, jmp $0001c760

                ; a4 = text display
                ; a5 = score table
                ; d0 = score index
.is_an_high_score                                                       ; original address $0001c5f2
                move.l  (a5),$0004(a5)
                move.l  PANEL_HIGHSCORE,(a5)                            ; set high score in score table
                move.b  #$20,$000a(a4)                                  ; insert space at text display index 10 - initial 1
                move.b  #$20,$000b(a4)                                  ; insert space at text display index 11 - initial 2
                move.b  #$20,$000c(a4)                                  ; insert space at text display index 12 - initial 3

.add_score_to_table_bcd
.digits_1_and_2                                                         ; original address $0001c60e
                movem.l d0,-(a7)                                        ; save d0 (score entry index)
                move.b  $0003(a5),d0                                    ; d0 = score byte (BCD)
                move.b  d0,d1                                           ; d1 = copy score byte (BCD)
                and.b   #$0f,d0                                         ; d0 = low digit
                add.w   #$0030,d0                                       ; d0 = add Ascii base for '0'
                lsr.b   #$04,d1                                         ; d1 = second score digit
                add.w   #$0030,d1                                       ; d1 = add Ascii base for '0'
                move.b  d0,$0014(a4)                                    ; store score digit 1 - least significant
                move.b  d1,$0013(a4)                                    ; store score digit 2 - second digit

.digits_3_and_4                                                         ; original address $0001c62e
                move.b  $0002(a5),d0                                    ; d0 = score byte (BCD)
                move.b  d0,d1                                           ; d1 = copy score byte (BCD)
                and.b   #$0f,d0                                         ; d0 = low digit
                add.w   #$0030,d0                                       ; d0 = add Ascii base for '0'
                lsr.b   #$04,d1                                         ; d1 = second score digit
                add.w   #$0030,d1                                       ; d1 = add Ascii base for '0'
                move.b  d0,$0012(a4)                                    ; store score digit 1 - least significant
                move.b  d1,$0011(a4)                                    ; store score digit 2 - second digit

.digits_5_and_6                                                         ; original address $0001c64a
                move.b  $0001(a5),d0                                    ; d0 = score byte (BCD)
                move.b  d0,d1                                           ; d1 = copy score byte (BCD)
                and.b   #$0f,d0                                         ; d0 = low digit
                add.w   #$0030,d0                                       ; d0 = add Ascii base for '0'
                lsr.b   #$04,d1                                         ; d1 = second score digit
                add.w   #$0030,d1                                       ; d1 = add Ascii base for '0'
                move.b  d0,$0010(a4)                                    ; store score digit 1 - least significant
                move.b  d1,$000f(a4)                                    ; store score digit 2 - second digit

.init_enter_initials
                adda.l  #$0000000a,a4                                   ; increase text display ptr by 10 chars
                lea.l   score_y_coord_table,a0                          ; L0001c76a,a0
                movem.l (a7)+,d0                                        ; d0 = restored table entry index
                asl.w   #$01,d0                                         ; d0 = d0 * 2 (index to a0 table)
                move.w  $00(a0,d0.w),char_plot_y_coord                  ; L0001c45c - set y co-ord 
                move.w  #$0011,char_plot_x_coord                        ; L0001c45a - set x co-ord first char
                move.w  #$0003,name_initials_count                      ; L0001c776 - number of letters to enter
                move.b  #$04,high_score_6th_entry                       ; $0001C9FC - insert text typer code to not display last entry
                                                                        ; CODE #$04 makes typer End HighScore table
.display_hiscore_table
                lea.l   display_hiscores,a6                             ; L0001c96e ; (a6) = $0c30 - x,y display co-ords
                bsr.w   text_typer                                      ; $0001c324 ; type text

                moveq   #$01,d6                                         ; d6 = initialise the current displayed character(initials entry)
                bsr.w   .draw_current_character                         ; calls $0001c710 
                *** This never returns (looks like it should be a bra?) ***
                *** Enters the .initials_entry_loop ***
                *** Eventually jumps out at .end_intial_entry

.initials_entry_loop                                                    ; original address $0001c6a8
                moveq   #$04,d0
                bsr.w   raster_wait_161                                 ; calls $0001c2f8 - wait 4 frames
                clr.l   joystick_left                                   ; clear both joystick left & right flags - $0001c778
                clr.w   unused_var_flag                                 ; clear the 16 bit word - appears unused else where - $0001c77c
                move.w  $00dff00c,d0                                    ; d0 = JOT1DAT
                btst.l  #$0001,d0                                       ; joystick right (active high)
                sne.b   joystick_right                                  ; $0001c77a
                btst.l  #$0008,d0                                       ; joystick left (active high)
                sne.b   joystick_left                                   ; $0001c778

.test_joystick_button
                btst.b  #$0007,$00bfe001
                beq.w   .wait_joystick_button_released                  ; L0001c71a

                move.w  joystick_left,d0                                ; $0001c778,d0
                or.w    joystick_right,d0                               ; $0001c77a,d0
                beq.b   .initials_entry_loop                            ; no joystick input - loop, L0001c6a8

                tst.w   joystick_left                                   ; $0001c778
                bne.w   .stick_left                                     ; L0001c706

.stick_right
                cmp.w   #$001b,d6                                       ; check last character index
                beq.w   .initials_entry_loop                            ; if at last character then loop
                addq.w  #$01,d6                                         ; increment current character
                bra.w   .draw_current_character                         ; calls $0001c710

.stick_left
                cmp.w   #$0001,d6                                       ; check is at 1st character
                beq.w   .initials_entry_loop                            ; if is first character then don't update, just loop
                subq.w  #$01,d6                                         ; decrement current character

.draw_current_character                                                 ; original address $0001c710
                move.b  d6,d0
                bsr.w   plot_character                                  ; calls $0001c45e
                bra.w   .initials_entry_loop                            ; L0001c6a8

.wait_joystick_button_released
                btst.b  #$0007,$00bfe001
                beq.w   .wait_joystick_button_released                  ; L0001c71a

.increment_next_char
                add.w   #$0001,char_plot_x_coord                        ; L0001c45a - advance to next character entry
                move.b  d6,d0                                           ; d0,d6 = current character
                cmp.b   #$1c,d0                                         ; test current char = #$1c (28)
                bne.w   .not_end
                move.w  #$ffe0,d0                                       ; insert -32 (equals a space char when #$40 is added back to it below)
.not_end
                add.b   #$40,d0
                move.b  d0,(a4)+                                        ; update display text
                sub.w   #$0001,name_initials_count                      ; update next name initial index, L0001c776
                beq.w   .end_intial_entry                               ; L0001c758
                move.b  d6,d0
                bsr.w   plot_character                                  ; calls $0001c45e
                bra.w   .initials_entry_loop                            ; L0001c6a8 

.end_intial_entry                                                       ; original address $0001c758
                move.w  #$0060,typer_extended_command_1                 ; $0001c782
                ; fall through to 'display_title_screen_text' below




                ;--------------------- display title screen text -----------------------------
                ; start the text typer routine that cycles through the text displayyed over
                ; the title screen as a set of text pages. Includes the display of the 
                ; high score table etc. 
                ; strangely the typer routine also waits for the joystick button to be
                ; pressed for the start game.
                ;
display_title_screen_text                                               ; original address $0001c760
                lea.l   title_screen_text,a6                            ; $0001c784 - a6 = title screen text for display
                bra.w   text_typer                                      ; jmp $0001c324 - display text
                ; uses text_typer rts to return?




score_y_coord_table                                             ; original address $0001C76A
                dc.w $0058, $0060, $0050, $0040, $0030, $0020   ; table of y co-ord values for each line of the hi-score table on the screen, bottom to top (not sure if 1st entry is used)

name_initials_count                                             ; original address $0001C776
                dc.w $0000                                      ; count of hi-score initials entered during the entry loop. initialised to 3, exits loop when 0

; used during enter high score initial loop
joystick_left                                                   ; original address $0001C778
                dc.w $0000                                      ; joystick left (SET TRUE)
joystick_right
                dc.w $0000                                      ; joystick right (SET TRUE)

unused_var_flag                                                 ; original address $0001C77C
                dc.w $0000                                      ; cleared when joystick values are read during hi-score initials entry loop - appears unused apart from being cleared in the loop.

temp_typer_text_ptr                                             ; original address $0001c77e
                dc.l $00000000                                  ; store ptr to typer text while command types hi-score table

typer_extended_command_1                                        ; original address $0001C782
                dc.b $00
typer_extended_command_2                                        ; original address $0001C783
                dc.b $00 


title_screen_text       

                IFND DEBUG_TYPER
                                                                ; original address $0001c784
                        dc.b $01,$01                                    ; display co-ords (x,y)
                        dc.b $01                                        ; clear screen command
                        dc.b $0D,$0D,$0D,$0D,$0D,$0D                    ; #$0D = carriage return
                        dc.b '      OCEAN SOFTWARE',$0D,$0D                   
                        dc.b '         PRESENTS   ',$0D                       
                        dc.b $02,$00,$80                                ; #$02 = wait for 2.5 seconds (128 frames)

                ELSE

                        dc.b $01,$01                                    ; display co-ords (x,y)
                        dc.b $01                                        ; clear screen command
                        dc.b $0D,$0D,$0D,$0D,$0D,$0D                    ; #$0D = carriage return
                        dc.b '      OCEAN SOFTWARE',$0D,$0D                   
                        dc.b '    REBUILT FROM SOURCE   ',$0D                       
                        dc.b $02,$00,$80                                ; #$02 = wait for 2.5 seconds (128 frames)

                ENDC

                dc.b $01                                        ; #$01 = clear the screen
                dc.b $06                                        ; #$06 = No Operation (nop)
                dc.b $0D,$0D,$0D,$0D,$0D,$0D
                dc.b '          BATMAN',$0D,$0D
                dc.b '        THE MOVIE'
                dc.b $02,$00,$80                                ; #$02 = wait for 2.5 seconds (128 frames)

                dc.b $01                                        ; #$01 = clear the screen
                dc.b $0D,$0D
                dc.b '   TM & @ DC COMICS INC',$2E,$0D          ; #$2E = full stop symbol
                dc.b '           1989 ',$0D,$0D,$0D
                dc.b '   @ OCEAN SOFTWARE 1989',$0D,$0D
                dc.b '     ESC',$2E,$2E,'ABORT GAME',$0D,$0D    ; #$2E = full stop symbol
                dc.b '      F1',$2E,$2E,'PAUSE GAME',$0D,$0D
                dc.b '      F2',$2E,$2E,'TOGGLE MUSIC',$0D
                dc.b $02,$01,$00                                ; #$02 = wait for 5 (256) seconds

                dc.b $01                                        ; #$01 = clear screen
                dc.b $0D
                dc.b '   CODING BY',$0D
                dc.b '            MIKE LAMB',$0D 
                dc.b '            JOBBEEEE',$0D
                dc.b '            SHORTY',$0D,$0D
                dc.b '   GRAPHICS BY',$0D
                dc.b '            DAWN DRAKE',$0D
                dc.b '            BILL HARBISON',$0D
                dc.b '            JOHN PALMER',$0D,$0D
                dc.b '   MUSIC AND FX BY',$0D
                dc.b '            JON DUNN',$0D
                dc.b '            MATTHEW CANNON' 
                dc.b $02,$01,$00                        ; #$02 = wait for 5 (256) seconds
                
                dc.b $01                                ; #$01 = clear screen
                dc.b $03                                ; #$03 = display hi score table
                dc.b $02,$00,$f0                        ; #$02 = wait for 2.5 seconds

                dc.w $01                                ; #$01 - clear screen
                dc.b $00                                ; #$00 - loop text to start
                dc.b $FF                                ; #$ff - end typer (never reaches here)                                                     




display_hiscores                                        ; original address $0001C96E
                dc.b $0C,$30                            ; x, y               
                dc.b $01                                ; $01 - clear screen
                dc.b $0D                                ; $0D - carriage return
                dc.b $03                                ; $03 - display hi scores
                dc.b $FF                                ; $ff - end typer




                ;------------------------- HIGH SCORE DISPLAY TABLE ----------------------------
                ; The text typer displays this text when encountering CODE #$03, it ends
                ; and resumes where it left off when encountering CODE #$04.
                ; - title     = 21 chars (incl control codes)
                ; - lines 1-6 = 23 chars (incl control codes)
                ; - The 6th line entry is only used to roll the last entry into when inserting
                ;   a new high score into the table.
                ;   The insertion routine stuffs the code #$04 into the start of the 6th 
                ;   entry, preventing the text typer routine from displaying it on screen.
                ;
high_score_display_text                                                                                            ; original address $0001C974
                dc.b $20,$20,$20,$20,$20,$20,$20,$20,$20,$48,$49,$20,$53,$43,$4F,$52,$45,$53,$0D,$0D,$0D           ;         HI SCORES
                dc.b $20,$20,$20,$20,$20,$31,$53,$54,$20,$20,$41,$4A,$53,$20,$20,$31,$32,$35,$30,$30,$30,$0D,$0D   ;     1ST  AJS  125000
                dc.b $20,$20,$20,$20,$20,$32,$4E,$44,$20,$20,$4D,$49,$4B,$20,$20,$31,$30,$30,$30,$30,$30,$0D,$0D   ;     2ND  MIK  100000
                dc.b $20,$20,$20,$20,$20,$33,$52,$44,$20,$20,$4A,$4F,$42,$20,$20,$30,$37,$35,$30,$30,$30,$0D,$0D   ;     3RD  JOB  075000
                dc.b $20,$20,$20,$20,$20,$34,$54,$48,$20,$20,$42,$49,$4C,$20,$20,$30,$35,$30,$30,$30,$30,$0D,$0D   ;     4TH  BIL  050000
                dc.b $20,$20,$20,$20,$20,$35,$54,$48,$20,$20,$4A,$4F,$4E,$20,$20,$30,$32,$35,$30,$30,$30,$0D,$0D   ;     5TH  JON  025000
end_highscore_display_text                                                                                         ; original address $0001C9FC
high_score_6th_entry                                                                                               ; original address $0001C9FC - not displayed, buffer to roll last entry into
                dc.b $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$0D,$0D
                dc.b $04                        ; #$04 - typer code - resume typer after high score table




L0001CA14       dc.b $00, $00, $00, $00 
                even



                ;--------------- High Score Table -------------
                ; High score table where the top 5 scores are
                ; stored in BCD format.
                ; The 6th entry is only used to roll the
                ; last score into when inserting a new
                ; hi-score into the table.
                ;
highscore_table                                         ; original address $0001CA18
                dc.l $00125000
                dc.l $00100000
                dc.l $00075000
                dc.l $00050000
                dc.l $00025000                          ; highscore_table+16 ; original address $0001CA28                              
                dc.l $00000000                          ; highscore_table+20 ; original address $0001CA2c - not displayed, used to roll last entry into




                ; -------------- other data 1 ----------------------
                ; currently unknown/unused data
.other_data1                                            ; original address $0001CA2E
L0001CA2E       dc.w $0000, $0000                       ; **** UNUSED??? ****



                even
                ; --------------- Copy Title Screen Bitplanes ----------------
                ; A0 = Source Address
copy_title_screen_bitplanes
        IFND     TEST_TITLEPRG
                lea.l   $00040000,a0
        ELSE
                lea.l   test_bitplanes+(40*88)+10,a0
        ENDC
                bra.w   copy_bitplanes_to_display                 ; calls $0001d3da
                ; uses routine rts to return to caller




bitplane_size                                   ; original address $0001ca3e
                dc.l $00000000                  ; The size of the current display bitplane in bytes          




                ; -------------- other data 2 ----------------------
                ; currently unknown/unused data
.other_data2
L0001CA42       dc.w $0000, $0000                ;or.b #$00,d0







                ;-------------------------------- UNUSED CODE -----------------------------
                ;-------------------------------- UNUSED CODE -----------------------------
                ;-------------------------------- UNUSED CODE -----------------------------
                ;-------------------------------- UNUSED CODE -----------------------------
                ;-------------------------------- UNUSED CODE -----------------------------
                ;-------------------------------- UNUSED CODE -----------------------------  


                ; l0001cd0e = $7e (126) - reset_title_screen_display
                ; l0001cd12 = $3c (60)  - reset title screen display (L0001cd0e+4)          
L0001ca46       lea.l   L0001CD0E,a0
L0001ca4c       lea.l   L0001CD2E,a2
L0001ca52       lea.l   L0001CD16,a3
L0001ca58       lea.l   L0001CD34,a4
L0001ca5e       lea.l   L0001CD3A,a5
L0001ca64       lea.l   L0001CD40,a6

L0001ca6a       moveq   #$00,d7
L0001ca6c       bsr.w   L0001cb94

L0001ca70       move.w  #$0fca,d1
L0001ca74       or.w    L0001CD8C,d1
L0001ca7a       move.w  d1,$00dff040
L0001ca80       move.w  L0001CD8C,$00dff042
L0001ca8a       move.l  L0001CD86,d0
L0001ca90       beq.w   L0001cb92
L0001ca94       move.l  L0001CD6E,$00dff04c
L0001ca9e       move.l  L0001CD82,$00dff050
L0001caa8       move.l  d0,$00dff048
L0001caae       move.l  d0,$00dff054
L0001cab4       clr.w   $00dff064
L0001caba       clr.w   $00dff062
L0001cac0       move.w  (a4),$00dff060
L0001cac6       move.w  (a4),$00dff066
L0001cacc       move.w  (a2),$00dff058
L0001cad2       add.l   bitplane_size,d0                        ;$0001ca3e,d0
L0001cad8       bsr.w   wait_blitter                            ; calls $0001d442
L0001cadc       move.l  L0001CD72,$00dff04c
L0001cae6       move.l  L0001CD82,$00dff050
L0001caf0       move.l  d0,$00dff048
L0001caf6       move.l  d0,$00dff054
L0001cafc       move.w  (a2),$00dff058
L0001cb02       add.l   bitplane_size,d0                        ;$0001ca3e,d0
L0001cb08       bsr.w   wait_blitter                            ; calls $0001d442
L0001cb0c       move.l  L0001CD76,$00dff04c
L0001cb16       move.l  L0001CD82,$00dff050
L0001cb20       move.l  d0,$00dff048
L0001cb26       move.l  d0,$00dff054
L0001cb2c       move.w  (a2),$00dff058
L0001cb32       add.l   bitplane_size,d0                        ; $0001ca3e,d0
L0001cb38       bsr.w   wait_blitter                            ; calls $0001d442
L0001cb3c       move.l  L0001CD7A,$00dff04c
L0001cb46       move.l  L0001CD82,$00dff050
L0001cb50       move.l  d0,$00dff048
L0001cb56       move.l  d0,$00dff054
L0001cb5c       move.w  (a2),$00dff058
L0001cb62       add.l   bitplane_size,d0                        ; $0001ca3e,d0
L0001cb68       bsr.w   wait_blitter                            ; calls $0001d442
L0001cb6c       move.l  L0001CD7E,$00dff04c
L0001cb76       move.l  L0001CD82,$00dff050
L0001cb80       move.l  d0,$00dff048
L0001cb86       move.l  d0,$00dff054
L0001cb8c       move.w  (a2),$00dff058
L0001cb92       rts


                ; L0001cd0e,a0
                ; L0001cd2e,a2
                ; L0001cd16,a3
                ; L0001cd34,a4
                ; L0001cd3a,a5
                ; L0001cd40,a6                  ; index for source copy
                ; d7 = 0
L0001cb94       moveq   #$00,d0
L0001cb96       move.w  #$0028,(a4)

L0001cb9a       movem.l a0,-(a7)
L0001cb9e       move.w  (a6),d0
L0001cba0       mulu.w  #$001c,d0
L0001cba4       lea.l   L0001CD44,a0
L0001cbaa       move.l  $00(a0,d0.l),L0001CD66
L0001cbb2       move.l  $04(a0,d0.l),L0001CD66+8                ; L0001cd6e
L0001cbba       move.l  $08(a0,d0.l),L0001CD66+12               ; L0001cd72
L0001cbc2       move.l  $0c(a0,d0.l),L0001CD66+16               ; L0001cd76
L0001cbca       move.l  $10(a0,d0.l),L0001CD66+20               ; L0001cd7a
L0001cbd2       move.l  $14(a0,d0.l),L0001CD66+24               ; L0001cd7e
L0001cbda       move.l  $18(a0,d0.l),L0001CD66+28               ; L0001cd82
L0001cbe2       movem.l (a7)+,a0

L0001cbe6       move.w  (a0),d0                 ; d0 = 1st word
L0001cbe8       move.w  d0,d2                   ; d2 = 1st word
L0001cbea       and.w   #$000f,d2               ; mask to 8 bits
L0001cbee       lsr.w   #$03,d0                 ; d0 = d0 * 8
L0001cbf0       move.w  $0004(a0),d1            ; d1 = 2nd word
L0001cbf4       add.w   #$0100,d1               ; d1 = d1 + 256
L0001cbf8       ext.w   d0                      ; sign extend byte to word
L0001cbfa       add.w   #$0100,d0               ; d0 = d0 + 256
L0001cbfe       move.w  L0001CD66+2,d4          ; L0001cd68,d4
L0001cc04       move.w  d1,d3                   ; d3 = d1
L0001cc06       cmp.w   #$01c7,d3       
L0001cc0a       bgt.w   clear_and_exit          ; L0001cc22
L0001cc0e       add.w   d4,d3
L0001cc10       cmp.w   #$01c7,d3
L0001cc14       blt.w   L0001cc2a
L0001cc18       sub.w   #$01c7,d3
L0001cc1c       sub.w   d3,d4
L0001cc1e       beq.b   clear_and_exit          ; L0001cc22
L0001cc20       bpl.b   L0001cc2a
clear_and_exit
L0001cc22       clr.l   L0001CD86
L0001cc28       rts  


L0001cc2a       cmp.w   #$0100,d1
L0001cc2e       bgt.w   L0001cc7a
L0001cc32       move.w  d1,d3
L0001cc34       add.w   d4,d3
L0001cc36       sub.w   #$0100,d3
L0001cc3a       bmi.w   L0001cc22
L0001cc3e       move.w  d3,d4
L0001cc40       beq.w   L0001cc22
L0001cc44       sub.w   L0001CD68,d3
L0001cc4a       neg.w   d3
L0001cc4c       mulu.w  L0001CD66,d3
L0001cc52       add.l   d3,$0001CD6E
L0001cc58       add.l   d3,$0001CD72
L0001cc5e       add.l   d3,$0001CD76
L0001cc64       add.l   d3,$0001CD7A
L0001cc6a       add.l   d3,$0001CD7E
L0001cc70       add.l   d3,$0001CD82
L0001cc76       move.w  #$0100,d1
L0001cc7a       clr.w   (a5)
L0001cc7c       cmp.w   #$0128,d0
L0001cc80       bgt.w   L0001cc22
L0001cc84       cmp.w   #$0100,d0
L0001cc88       bgt.w   L0001cc9c
L0001cc8c       move.w  d0,d3
L0001cc8e       sub.w   #$0100,d3
L0001cc92       bmi.w   L0001cc22
L0001cc96       nop
L0001cc98       move.w  #$0100,d0
L0001cc9c       move.w  d0,d3
L0001cc9e       add.w   L0001CD66,d3
L0001cca4       cmp.w   #$0128,d3
L0001cca8       blt.w   L0001ccb0
L0001ccac       bra.w   L0001cc22
L0001ccb0       move.w  L0001CD66,d6
L0001ccb6       sub.w   d6,(a4)
L0001ccb8       sub.w   #$0100,d0
L0001ccbc       sub.w   #$0100,d1
L0001ccc0       mulu.w  #$0028,d1
L0001ccc4       add.l   d1,d0
L0001ccc6       move.l  L0001CA42,d1
L0001cccc       add.l   d0,d1
L0001ccce       move.l  d1,L0001CD86
L0001ccd4       asl.w   #$08,d2
L0001ccd6       asl.w   #$04,d2
L0001ccd8       move.w  d2,L0001CD8C
L0001ccde       move.w  L0001CD66,d5
L0001cce4       mulu.w  d4,d5
L0001cce6       move.l  d5,L0001CD6A
L0001ccec       move.w  L0001CD66,d5
L0001ccf2       lsr.w   #$01,d5
L0001ccf4       asl.w   #$06,d4
L0001ccf6       or.w    d4,d5
L0001ccf8       move.w  d5,(a2)
L0001ccfa       rts

L0001ccfc       lea.l   L0001CD2E,a0
L0001cd02       move.w  #$0002,d7
L0001cd06       clr.w   (a0)+
L0001cd08       dbf.w   d7,L0001cd06
L0001cd0c       rts



                ;-------------------------------- UNUSED CODE -----------------------------
                ;-------------------------------- UNUSED CODE -----------------------------
                ;-------------------------------- UNUSED CODE -----------------------------
                ;-------------------------------- UNUSED CODE -----------------------------
                ;-------------------------------- UNUSED CODE -----------------------------




                ; l0001cd0e = $7e (126) - reset_title_screen_display
                ; l0001cd12 = $3c (60)  - reset title screen display (L0001cd0e+4)
L0001CD0E       dc.w $0000, $0018, $0000, $0012 
L0001CD16       dc.w $0000, $0000, $0000, $0000
                dc.w $0000, $0000, $0000, $0000
                dc.w $0000, $0000
                
L0001CD2A       dc.w $0000, $0000       ;unused? 

L0001CD2E       dc.w $0000, $0000, $0000
L0001CD34       dc.w $0000, $0000, $0000
L0001CD3A       dc.w $0000, $0000, $0000
L0001CD40       dc.w $0000              ; index for copy above L0001CD0E -> L0001CD66
                dc.w $0000
L0001CD44       dc.w $000C

L0001CD46 dc.w $001C, $0005, $0000, $0005
L0001CD4E dc.w $0150, $0005, $02A0, $0005, $03F0, $0005, $0540, $0001           ;.P...........@..
L0001CD5E dc.w $CD8E, $0000, $0000, $0000

                ; Values from L0001CD0E - is copied to these values here.
L0001CD66       dc.w $0000
L0001CD68       dc.w $0000
L0001CD6A       dc.l $00000000          ; skipped by data copy
L0001CD6E       dc.l $00000000
L0001CD72       dc.l $00000000
L0001CD76       dc.l $00000000
L0001CD7A       dc.l $00000000 
L0001CD7E       dc.l $00000000             
L0001CD82       dc.l $00000000

L0001CD86 dc.w $0000, $0000, $0000
L0001CD8C dc.w $0000           
L0001CD8E dc.w $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF           ;................
L0001CD9E dc.w $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF           ;................
L0001CDAE dc.w $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF           ;................
L0001CDBE dc.w $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF           ;................
L0001CDCE dc.w $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF           ;................
L0001CDDE dc.w $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF           ;................
L0001CDEE dc.w $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF           ;................
L0001CDFE dc.w $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF           ;................
L0001CE0E dc.w $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF           ;................
L0001CE1E dc.w $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF           ;................
L0001CE2E dc.w $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF           ;................
L0001CE3E dc.w $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF           ;................
L0001CE4E dc.w $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF           ;................
L0001CE5E dc.w $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF           ;................
L0001CE6E dc.w $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF           ;................
L0001CE7E dc.w $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF           ;................
L0001CE8E dc.w $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF           ;................
L0001CE9E dc.w $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF           ;................
L0001CEAE dc.w $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF           ;................
L0001CEBE dc.w $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF           ;................
L0001CECE dc.w $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF           ;................
L0001CEDE dc.w $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF           ;................
L0001CEEE dc.w $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF           ;................
L0001CEFE dc.w $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF           ;................
L0001CF0E dc.w $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF           ;................
L0001CF1E dc.w $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF           ;................
L0001CF2E dc.w $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF           ;................
L0001CF3E dc.w $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF           ;................
L0001CF4E dc.w $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF           ;................
L0001CF5E dc.w $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF           ;................
L0001CF6E dc.w $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF           ;................
L0001CF7E dc.w $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF           ;................
L0001CF8E dc.w $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF           ;................
L0001CF9E dc.w $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF           ;................
L0001CFAE dc.w $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF           ;................
L0001CFBE dc.w $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF           ;................
L0001CFCE dc.w $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF           ;................
L0001CFDE dc.w $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF           ;................
L0001CFEE dc.w $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF           ;................
L0001CFFE dc.w $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF           ;................
L0001D00E dc.w $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF           ;................
L0001D01E dc.w $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF           ;................
L0001D02E dc.w $FFFF, $FFFF, $FFFF, $FFFF, $0000, $0000, $0000, $0000           ;................
L0001D03E dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000           ;................
L0001D04E dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000           ;................
L0001D05E dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000           ;................
L0001D06E dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000           ;................
L0001D07E dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000           ;................
L0001D08E dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000           ;................
L0001D09E dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000           ;................
L0001D0AE dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000           ;................
L0001D0BE dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000           ;................
L0001D0CE dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000           ;................
L0001D0DE dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000           ;................
L0001D0EE dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000           ;................
L0001D0FE dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000           ;................
L0001D10E dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000           ;................
L0001D11E dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000           ;................
L0001D12E dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000           ;................
L0001D13E dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000           ;................
L0001D14E dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000           ;................
L0001D15E dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000           ;................
L0001D16E dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000           ;................
L0001D17E dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000           ;................
L0001D18E dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000           ;................
L0001D19E dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000           ;................
L0001D1AE dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000           ;................
L0001D1BE dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000           ;................
L0001D1CE dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000           ;................
L0001D1DE dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000           ;................
L0001D1EE dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000           ;................
L0001D1FE dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000           ;................
L0001D20E dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000           ;................
L0001D21E dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000           ;................
L0001D22E dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000           ;................
L0001D23E dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000           ;................
L0001D24E dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000           ;................
L0001D25E dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000           ;................
L0001D26E dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000           ;................
L0001D27E dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000           ;................
L0001D28E dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000           ;................
L0001D29E dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000           ;................
L0001D2AE dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000           ;................
L0001D2BE dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000           ;................
L0001D2CE dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000           ;................




                ;---------------------- reset title screen display ------------------------
                ; 
                ;
                ; 1) resets the display window to closed, set general display parameters
                ; in custom registers.
                ; Checks if cheat is enabled, and if so flips the display.
                ;
                ; Called from:
                ;
                ; IN: D0.l = bitplane size (bytes)
                ;
reset_title_screen_display                                              ; original address $0001d2de
                move.l  d0,bitplane_size                                ; $0001ca3e
                move.b  #$f4,$00dff08e                                  ; DIWSTRT - reset window to closed
                moveq   #$01,d0
                bsr.w   raster_wait_161                                 ; wait for 2 frames ; calls $0001c2f8
                ;move.w  #$1000,$00dff100                                ; BPLCON0 - 5 bitplane screen
                move.w  #$5000,$00dff100                                ; BPLCON0 - 5 bitplane screen
                move.w  #$0040,$00dff104                                ; BPLCON2 - Playfield 2 - priority (dual playfield?)
                move.w  #$0000,$00dff102                                ; BPLCON1 - Clear scroll delay
                move.l  #DISPLAY_BITPLANE_ADDRESS,L0001CA42             ; #$00063190,$0001ca42 [00000000]
                move.w  #$007e,L0001CD0E                                ; #$7e (126)
                move.w  #$003c,L0001CD0E+4                              ; #$3c (60)
                move.l  #$003800d0,$00dff092                            ; DDFSTRT/DDFSTOP - DMA bitplane fetch
                clr.w   $00dff108                                       ; BPL1MOD - CLR not the best on custom regs
                clr.w   $00dff10a                                       ; BPL2MOD
                move.l  #$ffffffff,$00dff044                            ; BLTAFWM/BLTALWM - blitter word masks
                move.l  #DISPLAY_BITPLANE_ADDRESS,d0                    ; #$00063190,d0
                btst.b  #PANEL_STATUS_2_INFINITE_LIVES,PANEL_STATUS_2   ; $0007c875
                beq.b   .set_bitplane_ptrs                              ; $0001d372
.cheat_enabled
                move.w  #$ffb0,$00dff108                                ; BPL1MOD = -80 (flip screen)
                move.w  #$ffb0,$00dff10a                                ; BPL2MOD = -80 (flip screen)
                move.l  bitplane_size,d1                                ; $0001ca3e,d1
                sub.l   #$00000028,d1
                add.l   d1,d0                                           ; d0 last line of title screen bitplane

.set_bitplane_ptrs
                moveq   #$04,d7                                         ; d7 = 4 + 1 (5 bitplanes) set bitplane pointers for title screen
                lea.l   copper_bplh_ptrs,a0                             ; L0001d6ee,a0 - bitplane high 16bit ptrs
                lea.l   copper_bpll_ptrs,a1                             ; L0001d702,a1 - bitplane low  16bit ptrs
.bitplane_loop
                move.w  d0,$0002(a1)
                swap.w  d0
                move.w  d0,$0002(a0)
                swap.w  d0
                addq.l  #$04,a0                                         ; increment to next bitplane ptr in copper list
                addq.l  #$04,a1                                         ; increment to next bitplane ptr in copper list
                add.l   bitplane_size,d0                                ; $0001ca3e,d0 - calc next bitplane start address
                dbf.w   d7,.bitplane_loop                               ; loop 5 times, jmp $0001d380
                rts



                ;------------------- do copy bitplane memory -----------------
                ; copies memory to the display bitplanes from $20000
                ; appears to be unused code.
                ;
do_copy_bitplane_memory
                bra.w   copy_bitplane_memory                            ; jmp $0001d3b4




                ;--------------------- copper copy -------------------
                ; copies colours into the copper for the current
                ; screen display
                ; IN: A0 = ptr to screen colours
                ;
copper_copy                                                     ; original address $0001d3a0
                lea.l   copper_colors,a1                        ; 0001d718,a1
                move.w  #$001f,d0                               ; d0 = 31 + 1 - counter
.copy_loop
                move.w  (a0)+,(a1)
                addq.l  #$04,a1                                 ; update dest ptr to next colour value
                dbf.w   d0,.copy_loop
                rts




                ;------------------- copy bitplane memory -----------------
                ; copies memory to the display bitplanes from $20000
                ; appears to be unused code.
                ;
copy_bitplane_memory                                            ; original routine address
                clr.l   DISPLAY_BITPLANE_ADDRESS                ; $00063190 - clear first 32 bits?
                lea.l   $00020000,a0                            ; a0 = $20000 - source address
                lea.l   DISPLAY_BITPLANE_ADDRESS+4,a1           ; a1 = $63194 - destination address
                movea.l a0,a2                                   ; a2 = copy dest address
                moveq   #$04,d1                                 ; d1 = counter 4 + 1 (5 bitplanes)
.bitplane_copy_loop
                move.w  #$1f40,d0                               ; d0 = bitplane size (8000)
.byte_copy_loop
                move.b  (a0)+,(a1)+                             ; copy byte by byte from source to dest
                dbf.w   d0,.byte_copy_loop
                dbf.w   d1,.bitplane_copy_loop
                rts




                ; ----------------------------- Copy Bitplanes to Display  --------------------------------
                ; copy source gfx to display bitplanes.
                ;
                ; - address $63190 = Bitplane address for display - see copper list
                ;
                ; - 28 x 3 = 84 bytes per loop iteration
                ; - 84 x 477 = 40,068 bytes
                ;  - 320 x 200 screen = 8000 bytes per bitplane 
                ;  - 8000 x5 = 40,0000
                ; - over copies 68 bytes?
                ;
                ; IN: A0 = ptr to src gfx
                ;
copy_bitplanes_to_display                               ; original routine address $0001d3da
                movem.l d0/a0-a1,-(a7)
                lea.l   DISPLAY_BITPLANE_ADDRESS,a1     ; $00063190,a1
                move.w  #$01dc,d0                       ; d0 = $1cd (476) + 1
.copy_loop
                movem.l (a0)+,d1-d7                     ; copy 28 bytes src -> registers
                movem.l d1-d7,(a1)                      ; copy 28 bytes reg -> dest (a1)
                adda.l  #$0000001c,a1                   ; #$1c = 28 (28 bytes to dest ptr)
                movem.l (a0)+,d1-d7                     ; copy 28 bytes src -> registers
                movem.l d1-d7,(a1)                      ; copy 28 bytes reg -> dest
                adda.l  #$0000001c,a1                   ; #$1c = 28 (28 bytes to dest ptr) 
                movem.l (a0)+,d1-d7                     ; copy 28 bytes src > registers
                movem.l d1-d7,(a1)                      ; copy 28 bytes reg -> dest
                adda.l  #$0000001c,a1                   ; #$1c = 28 (28 bytes to dest ptr) 
                dbf.w   d0,.copy_loop                   ; copy loop (477 times x 28 bytes = 40,068)

                movem.l (a7)+,d0/a0-a1
                rts



                ; --------------------- copy gfx to display ---------------------
                ; copies 51,212 bytes from source to dest.
                ; IN: a0 = source gfx ptr
copy_gfx_to_display                                     ; original address $0001d41c
                movem.l d0/a1,-(a7)
                lea.l   DISPLAY_BITPLANE_ADDRESS,a1     ; $00063190,a1
                move.w  #$0724,d0                       ; #$724 + 1 (1829) ; 1829 * 28 = 51,212
.copy_loop
                movem.l (a0)+,d1-d7                     ; get 28 source bytes (d1-d7)
                movem.l d1-d7,(a1)                      ; set 28 dest bytes (d1-d7)
                adda.l  #$0000001c,a1                   ; increment dest ptr by #$1c (28)
                dbf.w   d0,.copy_loop                   ; loop 1829 times
                movem.l (a7)+,d0/a1
                rts 




                ;--------------------- wait blitter ---------------------------
                ; wait for blitter to finish it's current operation.
                ; busy wait loop.
wait_blitter
                btst.b  #$0006,$00dff002                 ; test BBUSY bit of DMACONR
                bne.w   wait_blitter
                rts  



                ;--------------------- do return to title screen ----------------
                ; perform game over/game completion checks, display correct
                ; screens on return from the game back to the title screen.
                ;
do_return_to_title_screen                                                       ; original routine address $0001d450
                lea.l   temp_stack_top,a7                                       ; set temp stack, $0001d6de,a7
                bsr.w   initialise_title_screen                                 ; calls $0001c0d8
                btst.b  #PANEL_STATUS_2_GAME_OVER,PANEL_STATUS_2                ; #$0005,$0007c875 
                beq.b   do_gameover_completion                                  ; calls $0001d46e
                clr.l   PANEL_HIGHSCORE                                         ; $0007c87c
                bra.w   return_to_title_screen                                  ; $0001c018



                ;------------------- do game over/completion -------------------
                ; check panel_status_2 bit to see if the game was completed
                ; or whether it's a game over.
do_gameover_completion                                                          ; original routine address $0001d46e
                btst.b  #PANEL_STATUS_2_GAME_COMPLETED,PANEL_STATUS_2           ; #$0006,$0007c875 
                IFD TEST_JOKER
                beq.w   display_endgame_joker                                   ; jmp $0001d4ec
                ENDC



                ;---------------------- display completion screen -----------------------
                ; displays the game completion screen, plays the batman voice (song 3)
                ; waits for ~15 seconds, returns to title screen.
display_completion_screen                                                       ; original routine address $0001d47a
                move.l  #$00001f40,d0                                           ; d0 = bitplane size (bytes) (8000)
                bsr.w   reset_title_screen_display                              ; calls $0001d2de
                move.w  #$4000,$00dff100                                        ; set 4 bitplane screen
                lea.l   palette_16_colours,a0                                   ; L0001d4cc ; 16 colour palette address
                bsr.w   copper_copy                                             ; calls $0001d3a0
                lea.l   BATMAN_GFX,a0                                            ; a0 = source gfx
                ;lea.l   $00056460,a0                                            ; a0 = source gfx
                bsr.w   copy_bitplanes_to_display                               ; calls $0001d3da
                move.b  #$2c,copper_diwstrt                                     ; $0001d6e8 - set window open
                move.b  #$f4,copper_diwstop                                     ; $0001d6ec 
                move.w  #$0064,d0                                               ; d0 = 100
                bsr.w   raster_wait_161                                         ; wait for 100 frames (2 seconds) - calls $0001c2f8
                moveq   #$03,d0                                                 ; d0 = song 3
                jsr     Init_Song                                               ; init play song 4 - calls $00004010
                move.w  #$0600,d0                                               ; d0 = 1536 
                bsr.w   raster_wait_161                                         ; wait for 1536 frames (15 seconds) - calls $0001c2f8
                bra.w   return_to_title_screen                                  ; jmp $0001c018




                ;------------------- 16 colour palette -----------------------
                ; 16 colour palatte for the above.
palette_16_colours                                                              ; original address $0001d4cc
                dc.w $0000, $0ec2, $0e80, $0a40, $0820, $0e60, $0ea8, $0eca 
                dc.w $0ea0, $0eee, $0222, $0444, $0666, $0888, $0AAA, $0CCC




                ;---------------------- display end game joker -----------------------
                ; displays the game over screen, plays the joker laugh (song 2)
                ; waits for ~10 seconds, returns to title screen.
display_endgame_joker                                                   ; original address $0001d4f0
                move.l  #$2800,d0                                       ; d0,d4 = bitplane size (bytes)
                bsr.w   reset_title_screen_display                      ; calls $0001d2de
        IFND     TEST_TITLEPRG
                lea.l   $00040000,a0
                lea.l   JOKER_GFX,a0                                    ; a0 = display palette colour table
                bsr.w   copper_copy                                     ; calls $0001d3a0
                lea.l   JOKER_GFX+$40,a0                                ; a0 = display palette colour table
        ELSE
                lea.l   test_bitplanes,a0                               ; a0 = display palette colour table
                lea.l   JOKER_GFX+4,a0                                  ; a0 = display palette colour table
                bsr.w   copper_copy                                     ; calls $0001d3a0
                lea.l   JOKER_GFX+$44,a0                                ; a0 = display palette colour table
        ENDC
                bsr.w   copy_gfx_to_display                             ; calls $0001d41c
                move.b  #$2c,copper_diwstrt                             ; $0001d6e8
                move.b  #$2b,copper_diwstop                             ; $0001d6ec
                move.w  #$0014,d0
                bsr.w   raster_wait_161                                 ; calls $0001c2f8
                moveq   #$02,d0
                jsr     Init_Song                                       ; calls $00004010
                move.w  #$0200,d0                                       ; d0 = wait 512 frames (10 seconds)
                bsr.w   raster_wait_161                                 ; calls $0001c2f8
                bra.w   return_to_title_screen                          ; jmp $0001c018




                ;--------------------- wait 10 seconds ---------------------
                ; waits for 512 frames to pass.
                ; *** unused code ***
wait_10_seconds
                move.w  #$0200,d0                                       ; d0 = wait 512 frames (10 seconds)
                bsr.w   raster_wait_161                                 ; calls $0001c2f8
                bra.w   return_to_title_screen                          ; jmp $0001c018




                ;-----------------------do  fatal error ------------------
                ; Takes back ground colour and sets it, then increments the value
                ; loops forever.
                ;
do_fatal_error                                                          ; original routine address $0001d542
                move.w  d0,$00dff180
                addq.w  #$01,d0
                bra.w   do_fatal_error



                ;----------------------- title screen stack ------------------
                ; memory area used for the title screen stack memory.
                ; sp/a7 is set to the address 'temp_stack_top' at the end of 
                ; this block of data.
                ;
temp_stack_bottom                                                       ; original address $0001D54E
                dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000   
                dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000   
                dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000   
                dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000   
                dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000   
                dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000   
                dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000   
                dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000   
                dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000   
                dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000   
                dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000   
                dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000   
                dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000   
                dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000   
                dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000   
                dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000   
                dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000   
                dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000   
                dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000   
                dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000   
                dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000   
                dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000   
                dc.w $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000   
                dc.w $0000, $0000, $00C7, $8978, $00C7, $8978, $00C7, $848C   
                dc.w $00C7, $871E, $00C7, $8104, $0000, $0000, $0000, $0000   
temp_stack_top                                                          ; original address $0001D6DE




L0001D6DE dc.w $0000                            ; ***** UNUSED? *****
L0001D6E0 dc.w $0000                            ; ***** UNUSED? *****




                ; ------------------- copper list -------------------
copper_list
                dc.w $00FF
                dc.w $FF00
                dc.w DIWSTRT            ; $008E 
copper_diwstrt                                                  ; original address $0001D6E8
                dc.w $F381
                dc.w DIWSTOP            ; $0090
copper_diwstop                                                  ; original address $0001D6EC
                dc.w $F4C1
copper_bplh_ptrs
                dc.w BPL1PTH            ; $00E0
                dc.W $0006
                dc.w BPL2PTH            ; $00E4
                dc.w $0006
                dc.w BPL3PTH            ; $00E8
                dc.w $0006
                dc.w BPL4PTH            ; $00EC
                dc.w $0006
                dc.w BPL5PTH            ; $00F0
                dc.w $0006
copper_bpll_ptrs
                dc.w BPL1PTL            ; $00E2
                dc.w $3190
                dc.w BPL2PTL            ; $00E6
                dc.w $50D0
                dc.w BPL3PTL            ; $00EA
                dc.w $7010
                dc.w BPL4PTL            ; $00EE
                dc.w $8F50
                dc.w BPL5PTL            ; $00F2
                dc.w $AE90
                dc.w COLOR00
copper_colors                                                   ; original address $0001d718
                dc.w $0000
                dc.w COLOR01, $0000
                dc.w COLOR02, $0000
                dc.w COLOR03, $0000
                dc.w COLOR04, $0000
                dc.w COLOR05, $0000
                dc.w COLOR06, $0B51
                dc.w COLOR07, $0D61
                dc.w COLOR08, $0E70
                dc.w COLOR09, $0F80 
                dc.w COLOR10, $0F90
                dc.w COLOR11, $0FA0
                dc.w COLOR12, $0FB0
                dc.w COLOR13, $0FC0
                dc.w COLOR14, $0FE0
                dc.w COLOR15, $0FF0
                dc.w COLOR16, $0045
                dc.w COLOR17, $0900
                dc.w COLOR18, $0FFF
                dc.w COLOR19, $0033
                dc.w COLOR20, $0067
                dc.w COLOR21, $0222
                dc.w COLOR22, $0333
                dc.w COLOR23, $0444
                dc.w COLOR24, $0F99
                dc.w COLOR25, $0666
                dc.w COLOR26, $0706
                dc.w COLOR27, $0504
                dc.w COLOR28, $099A
                dc.w COLOR29, $0403
                dc.w COLOR30, $0302
                dc.w COLOR31, $0DDE
                dc.w $FFFF, $FFFE




                ;------------------------ title screen colours ---------------------
                ; table of colours copied into the copper list colour registers.
                ; the palette used for the title screen display.
                ;
title_screen_colors                                                     ; original address $0001D79A       
                dc.w $0000, $0521, $0310, $0731, $0831, $0A41, $0B51, $0D61
                dc.w $0E70, $0F80, $0F90, $0FA0, $0FB0, $0FC0, $0FE0, $0FF0
                dc.w $0045, $0900, $0FFF, $0033, $0067, $0222, $0333, $0444
                dc.w $0F99, $0666, $0706, $0504, $099A, $0403, $0302, $0DDE






        IFD TEST_TITLEPRG
                even
test_bitplanes  
                INCDIR './gfx/'
                INCBIN 'titlepic.iff'
                ;dcb.w   40068,$ff00

                even
test_display    
                dcb.w   40000,$f0f0
        ENDC

; 0003f1ea - text font
