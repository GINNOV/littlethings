                ; This is music and player routine for Level 1 - Axis Chemicals
                ; $00048000  Initialise Music Player    - Set up Player Samples & Instruments
                ; $00048004  Silence All Audio          - Stop Playing and Silence Audio
                ; $00048008  Stop Audio 
                ; $0004800c  Stop Audio
                ; $00048010  Init Song                  - Initialise Song to Play (D0 = song number)
                ; $00048014  Play SFX                   - Initialise & PLay SFX on 4th audio channel (if not already playing or is higher priority of one that is playing) - L0004822c
                ; $00048018  Play Song                  - Called every VBL to play music

                ;--------------------- includes and constants ---------------------------
                INCDIR      "include"
                INCLUDE     "hw.i"

TEST_MUSIC_BUILD SET 1                 ; run a test build with imported GFX
TEST_BUILD_LEVEL SET 1                 ; if enabling TEST_MUSIC_BUILD then also enable this

                section church_iff,code_c

                IFND TEST_BUILD_LEVEL
; Music Player Constants
AUDIO_PLAYER_INIT               EQU $00048000                       ; initialise music/sfx player
AUDIO_PLAYER_SILENCE            EQU $00048004                       ; Silence all audio
AUDIO_PLAYER_INIT_SFX_1         EQU $00048008                       ; Initialise SFX Audio Channnel
AUDIO_PLAYER_INIT_SFX_2         EQU $0004800c                       ; same as init_sfx_1 above
AUDIO_PLAYER_INIT_SONG          EQU $00048010                       ; initialise song to play - D0.l = song/sound 1 to 13
AUDIO_PLAYER_INIT_SFX           EQU $00048014                       ; initialise sfx to play - d0.l = sfx 5 to 13
AUDIO_PLAYER_UPDATE             EQU $00048018                       ; regular update (vblank to keep sounds/music playing)
                ENDC
                IFD TEST_BUILD_LEVEL
; Music Player Constants
AUDIO_PLAYER_INIT               EQU Init_Player                     ; initialise music/sfx player
AUDIO_PLAYER_SILENCE            EQU Stop_Playing                    ; Silence all audio
AUDIO_PLAYER_INIT_SFX_1         EQU Init_SFX_1                      ; Initialise SFX Audio Channnel
AUDIO_PLAYER_INIT_SFX_2         EQU Init_SFX_2                      ; same as init_sfx_1 above
AUDIO_PLAYER_INIT_SONG          EQU Init_Song                       ; initialise song to play - D0.l = song/sound 1 to 13
AUDIO_PLAYER_INIT_SFX           EQU Init_SFX                        ; initialise sfx to play - d0.l = sfx 5 to 13
AUDIO_PLAYER_UPDATE             EQU Play_Sounds                     ; regular update (vblank to keep sounds/music playing)
                ENDC    


;Church.iff - Level Music - Constants
;----------------------------------
SFX_LEVEL_MUSIC     EQU         $01
SFX_LEVEL_COMPLETE  EQU         $02
SFX_LIFE_LOST       EQU         $03
SFX_TIMER_EXPIRED   EQU         $04
SFX_DRIP            EQU         $05             ; Empty Sounds (Level 5)
SFX_GASLEAK         EQU         $06             ; Empty Sounds (Level 5)
SFX_BATROPE         EQU         $07             
SFX_BATARANG        EQU         $08
SFX_GRENADE         EQU         $09
SFX_GUYHIT          EQU         $0a
SFX_SPLASH          EQU         $0b
SFX_Ricochet        EQU         $0c
SFX_EXPLOSION       EQU         $0d



        IFND TEST_MUSIC_BUILD
                IFND TEST_BUILD_LEVEL
                        org     $47fe4                                         ; original load address
                ENDC
        ELSE


kill_system
                lea     $dff000,a6
                move.w  #$7fff,INTENA(a6)
                move.w  #$7fff,DMACON(a6)
                move.w  #$7fff,INTREQ(a6)   
                lea     kill_system,a7                              ; initialise stack 
                bsr     init_system

                ;--------------------------------------------------------------
                ; TEST PROGRAM
                ; set song number below 'SOUND_TO_PLAY' for different songs/sfx
                ;   #$01 = Level 1 Music
                ;   #$02 = Level 1 Completed
                ;   #$03 = Player Live Lost
                ;   #$04 = Unknown/Unused Music - Level Timer Run out?
                ;   #$05 = Drip SFX
                ;   #$06 = Gas Leak
                ;   #$07 = Batrope
                ;   #$08 = Batarang
                ;   #$09 = Grenade
                ;   #$0a = Bad Guy Hit
                ;   #$0b = Splash (jack in the vat)
                ;   #$0c = Ricochet
                ;   #$0d = Explosion (grenade)
                ;--------------------------------------------------

SOUND_TO_PLAY   EQU     $01                                   ; valid range #$01 to #$0d

init_test_prg
                jsr     Init_Player                           ; init music routine/instruments

                lea     $dff000,a6
                lea     level_3_interrupt,a0
                move.l  a0,$6c.w
                move.W  #$c020,INTENA(a6)                       ; enable level 3 interrupt
                move.W  #$c020,INTENA(a6)                       ; enable level 3 interrupt

                moveq   #SOUND_TO_PLAY,d0                       ; song number to play
                jsr     Init_Song                               ; init song 1

loop
                jmp     loop     



                ;---------------- level 3 interrupt ----------------
                ; vertical blank interrupt handler.
                ; play the song at 25 frames per second.
                ;
level_3_interrupt
                movem.l d0-d7/a0-a6,-(a7)
                
                lea     $dff000,a6
                move.w  INTREQR(a6),d0
                and.w   #$0020,d0
                beq     .exit_isr

                jsr     check_change_sound

.play_music     ; play music @ 25 frames per second.
                eor.w   #$0001,frameskipper
                beq.s   .exit_isr
                jsr     Play_Sounds

.exit_isr
                ; clear level 3 interrut bits
                move.w  d0,INTREQ(a6)

                movem.l (a7)+,d0-d7/a0-a6
                rte


frameskipper:   dc.w    $0000                   ; used to only update music at 25 frames per second.
                                                ; otherwise it's too fast.


                ;--------------- check change sound ------------------
                ; check for mouse press and release, if so then
                ; increment the current sound.
                ; 
check_change_sound
                btst    #$6,$bfe001
                bne.s   .button_up
.button_down
                st.b    button_down
                bra.s   .end_button_check
.button_up
                cmp.b   #$ff,button_down
                bne.s   .end_button_check
.change_music
                sf.b    button_down
                addq.b  #$01,current_song
                cmp.b   #$0d,current_song
                ble.s   .change_song
.loop_id        
                move.b  #$01,current_song
.change_song       
                jsr     do_silence_all_audio
                moveq.l #$0,d0
                move.b  current_song,d0
                jsr     do_init_song
.end_button_check
                rts

                even
button_down     dc.b    $00
current_song    dc.b    SOUND_TO_PLAY
                even



                ; ------------------- kill system -----------------
                include "./lib/kill_system.s"

        ENDC    

L00047fe4               bra.b L00048000                         ; initialise music player.

L00047fe6               dc.w  $0001, $091a                      ; Length of file?
L00047fea               dc.w  $0000, $0000                      ; 
L00047fee               dc.w  $0000, $0000                      ; 
L00047ff2               dc.w  $0000, $0000                      ; 
L00047ff6               dc.w  $0000, $0000                      ; 
L00047ffa               dc.w  $0000, $0000                      ; 
L00047ffe               dc.w  $0000

Init_Player                                                     ; original address $00048000
L00048000               bra.w do_initialise_music_player        ; jmp $00048180
Stop_Playing                                                    ; original address $00048004
L00048004               bra.w do_silence_all_audio              ; jmp $00048194
Init_SFX_1                                                      ; original address $00048008
L00048008               bra.w do_init_sfx_channels              ; jmp $000481e8 - could also be reinit_active audio channel
Init_SFX_2                                                      ; original address $0004800c
L0004800c               bra.w do_init_sfx_channels              ; jmp $000481e8
Init_Song                                                       ; original address $00048010
L00048010               bra.w do_init_song                      ; jmp $0004824e
Init_SFX                                                        ; original address $00048014
L00048014               bra.w do_play_sfx                       ; jmp $0004822c
Play_Sounds                                                     ; original address $00048018
L00048018               bra.w do_play_sounds                      ; jmp $0004830e


master_audio_volume_mask_1                                      ; original address $0004801c
L0004801c               dc.w  $ffff
master_audio_volume_mask_2 
L0004801e               dc.w  $ffff                             ; original address $0004801e

song_ctrl_bits                                                  ; original address $00048020
L00048020               dc.w  $0000                             ; bit 15 = playing song,
                                                                ; bit 14 = playing sfx (4th channel)




 
song_no_1                                                       ; original address $00048022
L00048022               dc.b  $01
song_no_2                                                       ; original address $00048023
sfx_no
L00048023               dc.b  $01   

channel_00_status                                       ; original address $00048024
L00048024               dc.w  $0000                     ; $0000 - Channel Control Bits (active command bits)
                        dc.l  $00000000                 ; $0002 - Loop Back to previous Pattern Ptr
                        dc.l  $00000000                 ; $0006 - Next Pattern Ptr
                        dc.l  $00000000                 ; $000a - Loop Back Position Inside Current Pattern
                        dc.l  $00000000                 ; $000e - Next Pattern Data Ptr
                        dc.b  $00                       ; $0012 - Pattern Loop Count (1 = play once - default)
                        dc.b  $00                       ; $0013 - 
                        dc.l  $00000000                 ; $0014 - 
                        dc.l  $00000000                 ; $0018 - 
                        dc.w  $0000                     ; $001c - 
                        dc.w  $0000                     ; $001e - 
                        dc.b  $00                       ; $0020 - 
                        dc.b  $00                       ; $0021 - Pattern Command 10 - Parameter (byte) - ctrl clear bits (0,1,2,4,5,6,7)
                        dc.b  $00                       ; $0022 - Pattern Command 10 - Parameter (byte) - ctrl clear bits (0,1,2,4,5,6,7)
                        dc.b  $00                       ; $0023 - 
                        dc.b  $00                       ; $0024 - Pattern Command 09 - Parameter (byte) - ctrl bit 3
                        dc.b  $00                       ; $0025 - Pattern Command 09 - Parameter (byte) - ctrl bit 3
                        dc.b  $00                       ; $0026 -
                        dc.b  $00                       ; $0027 - 
                        dc.l  $00000000                 ; $0028 - ptr CMD 14
                        dc.l  $00000000                 ; $002c - ptr CMD 14 - working copy
                        dc.b  $00                       ; $0030 - 
                        dc.b  $00                       ; $0031 - 
                        dc.b  $00                       ; $0032 -
                        dc.b  $00                       ; $0033 - 
                        dc.b  $00                       ; $0034 - 
                        dc.b  $00                       ; $0035 -
                        dc.b  $00                       ; $0036 -
                        dc.b  $00                       ; $0037 -
                        dc.b  $00                       ; $0038 -
                        dc.b  $00                       ; $0039 - 
                        dc.w  $0000                     ; $003a -
                        dc.w  $0000                     ; $003c -
                        dc.l  $00000000                 ; $003e -
                        dc.w  $0000                     ; $0042 -
                        dc.l  $00000000                 ; $0044 - 
                        dc.w  $0000                     ; $0048 - 
                        dc.w  $0000                     ; $004a -
                        dc.w  $0000                     ; $004c -
                        dc.b  $00                       ; $004e -
                        dc.b  $00                       ; $004f -
                        dc.b  $00                       ; $0050 -
                        dc.b  $00                       ; $0051 - Pattern Command 05 Parameter - ctrl bit 5
                        dc.w  $0000                     ; $0052 - Pattern Command 08 Parameter - ctrl bit 7
                        dc.w  $0001                     ; $0054 - channel dma bit - channel bit? 8 (2^0)  

channel_01_status                                       ; original address $0004807a
L0004807a               dc.w  $0000                             
                        dc.l  $00000000                      
                        dc.l  $00000000                      
                        dc.l  $00000000                      
                        dc.l  $00000000                      
                        dc.b  $00
                        dc.b  $00
                        dc.l  $00000000
                        dc.l  $00000000
                        dc.w  $0000                      
                        dc.w  $0000
                        dc.b  $00
                        dc.b  $00                      
                        dc.b  $00
                        dc.b  $00
                        dc.b  $00
                        dc.b  $00                      
                        dc.b  $00
                        dc.b  $00
                        dc.l  $00000000
                        dc.l  $00000000
                        dc.b  $00
                        dc.b  $00                      
                        dc.b  $00
                        dc.b  $00
                        dc.b  $00
                        dc.b  $00                      
                        dc.b  $00
                        dc.b  $00
                        dc.b  $00
                        dc.b  $00                      
                        dc.w  $0000
                        dc.w  $0000                      
                        dc.l  $00000000                      
                        dc.w  $0000
                        dc.l  $00000000
                        dc.w  $0000                      
                        dc.w  $0000
                        dc.w  $0000                      
                        dc.b  $00
                        dc.b  $00
                        dc.b  $00
                        dc.b  $00                      
                        dc.w  $0000
                        dc.w  $0002                     ; $54 - channel dma bit - channel bit? 8 (2^1)                        

channel_02_status                                       ; original address $000480d0
L000480d0               dc.w  $0000
                        dc.l  $00000000
                        dc.l  $00000000
                        dc.l  $00000000
                        dc.l  $00000000
                        dc.b  $00
                        dc.b  $00                      
                        dc.l  $00000000                      
                        dc.l  $00000000  
                        dc.w  $0000
                        dc.w  $0000                     
                        dc.b  $00
                        dc.b  $00
                        dc.b  $00
                        dc.b  $00                      
                        dc.b  $00
                        dc.b  $00
                        dc.b  $00
                        dc.b  $00                      
                        dc.l  $00000000                      
                        dc.l  $00000000                      
                        dc.b  $00
                        dc.b  $00
                        dc.b  $00
                        dc.b  $00                      
                        dc.b  $00
                        dc.b  $00
                        dc.b  $00
                        dc.b  $00                      
                        dc.b  $00
                        dc.b  $00
                        dc.w  $0000                      
                        dc.w  $0000
                        dc.l  $00000000
                        dc.w  $0000                      
                        dc.l  $00000000                                      
                        dc.w  $0000
                        dc.w  $0000                      
                        dc.w  $0000
                        dc.b  $00
                        dc.b  $00                      
                        dc.b  $00
                        dc.b  $00
                        dc.w  $0000                      
                        dc.w  $0004                     ; $54 - channel dma bit - channel bit? 8 (2^2)  

channel_03_status                                       ; original address $00048126
L00048126               dc.w  $0000                             
                        dc.l  $00000000                      
                        dc.l  $00000000                      
                        dc.l  $00000000                      
                        dc.l  $00000000                      
                        dc.b  $00
                        dc.b  $00
                        dc.l  $00000000
                        dc.l  $00000000
                        dc.w  $0000                      
                        dc.w  $0000
                        dc.b  $00
                        dc.b  $00                      
                        dc.b  $00
                        dc.b  $00
                        dc.b  $00
                        dc.b  $00                      
                        dc.b  $00
                        dc.b  $00
                        dc.l  $00000000
                        dc.l  $00000000
                        dc.b  $00
                        dc.b  $00                      
                        dc.b  $00
                        dc.b  $00
                        dc.b  $00
                        dc.b  $00                      
                        dc.b  $00
                        dc.b  $00
                        dc.b  $00
                        dc.b  $00                      
                        dc.w  $0000
                        dc.w  $0000                      
                        dc.l  $00000000                      
                        dc.w  $0000
                        dc.l  $00000000
                        dc.w  $0000                      
                        dc.w  $0000
                        dc.w  $0000                      
                        dc.b  $00
                        dc.b  $00
                        dc.b  $00
                        dc.b  $00                      
                        dc.w  $0000
                        dc.w  $0008                     ; $54 - channel dma bit - channel bit? 8 (2^3)                     

audio_dma                                               ; original address $0004817c
L0004817c               dc.w  $0000                     ; Changes to DMACON (Active DMA Channels)
                                                        ; flag cleared on start of frame play routine
                                                        ; also it's or'ed with #$54 of channel status

play_counter                                            ; original address $0004817e
L0004817e               dc.w  $0000                     ; incremented when 'do_play_sounds' called with active sound
                                                        ; referenced as a word
                                                        ; cleared when playing new song/sound
                                                        ; incremented duting frame play routine every time 4020 is cleared
                


                        ; --------------- Initialise Music Player ----------------
                        ; No Parameters Required
do_initialise_music_player                                      ; original address $00048180
L00048180               lea.l   L00048d98,a0
                        lea.l   instrument_data,a1              ; L00048c40,a1
                        bsr.w   init_instruments                ; L00048a08
                        bra.w   do_silence_all_audio            ; L00048194



                        ;---------------------------- do silence all audio ----------------------------------
                        ; initialises all audio channels and sets song/sfx numbers to $00
                        ;
do_silence_all_audio                                            ; original address $00048194
L00048194               movem.l d0/a0-a1,-(a7)
                        move.b  #$00,song_no_1                  ; L00048022
                        move.b  #$00,sfx_no                     ; song_no_2 ; L00048023
                        lea.l   channel_00_status,a0            ; L00048024,a0 
                        lea.l   $00dff0a8,a1                    ; a1 = AUD0VOL
                        bsr.b   init_audio_channel              ; L000481ca
                        bsr.b   init_audio_channel              ; L000481ca
                        bsr.b   init_audio_channel              ; L000481ca
                        bsr.b   init_audio_channel              ; L000481ca
                        move.w  #$0000,song_ctrl_bits           ; L00048020 ; sound type bits & channel dma enable bits (all channels)
                        movem.l (a7)+,d0/a0-a1
                        rts



                        ;------------ silence channel volume -------------
                        ; Set Audio Channel Volume to Zero, also init other channel structure values
                        ; IN: A0 - channel/voice status data
                        ; IN: A1 - AUDxVOL custom register
                        ;
init_audio_channel                                              ; original address $000481ca
L000481ca               move.w  #$0000,(a0)
                        move.w  #$0001,$004a(a0)
                        move.w  #$0000,$004c(a0)
                        move.w  #$0000,(a1)                     ; AUDxVOL
                        adda.w  #$0056,a0                       ; a0 = next audio channel structure
                        adda.w  #$0010,a1                       ; a1 = next audo channel AUDxVOL h/w/ register
                        rts




                        ;----------------------------- do_init_sfx_channels -----------------------------
                        ; Reset active channels for specified sound. 
                        ; Maybe used to silence channels before playing sfx over existing sound.
                        ;
                        ; If song number (d0) is not in range 0-13 then silence audio and exit.
                        ; If song number (d0) is in range 0-13 then re-initialise the active channels only.
                        ;
                        ; IN: D0.w      - Song Number/SFX Number?
                        ;
do_init_sfx_channels                                            ; original address $000481e8
L000481e8               movem.l d0/d7/a0-a2,-(a7)
                        subq.w  #$01,d0
                        bmi.b   .unknown_song_number            ; d0 <= 0  ; jmp $000481f6
                        cmp.w   #$000d,d0                       ; 13
                        bcs.b   .reset_active_channels          ; d0 < 13  ; jmp $000481fa
.unknown_song_number
                        bsr.b   do_silence_all_audio            ; d0 >= 13 ; jmp $00048194                       
                        bra.b   .exit                           ; L00048226

                        ; reset any active audio channels in specified sound
                        ; maybe used to silence a channel when wanting to play a sfx over current sound.
                        ; d0.w index into table - L0005847e (active song channels?)
.reset_active_channels
                        lea.l   sounds_table,a2                 ; L0005847e,a2
                        asl.w   #$03,d0                         ; d0 = d0 * 8
                        adda.w  d0,a2                           ; add offset to a2
                        lea.l   channel_00_status,a0            ; L00048024,a0
                        lea.l   $00dff0a8,a1                    ; AUD0VOL
                        moveq   #$03,d7
.audio_channel_loop
                        tst.w   (a2)+
                        bne.b   .init_audio_channel             ; if channel active then - re-init active audio channel - L00048220
                        adda.w  #$0056,a0                       ; else - get next audio channel status
                        adda.w  #$0010,a1                       ;        get next audio channel volume register.
                        bra.b   .skip_init_audio_channel        ;        skip init audio channel - L00048222
.init_audio_channel
                        bsr.b   init_audio_channel              ; L000481ca ; init_audio_channel
.skip_init_audio_channel
                        dbf.w   d7,.audio_channel_loop          ; loop - L00048212 ; loop for next channel
.exit                                                           ; original address $00048226
                        movem.l (a7)+,d0/d7/a0-a2
                        rts 



                        ;--------------------------- do play sfx ------------------------
                        ; I think this is used to play a SFX sound on the 4th channel. 
                        ; Test is channel is active, 
                        ; IN:  D0.w - song number?
                        ;
do_play_sfx                                                     ; original address $0004822c
                        tst.w   channel_03_status               ; 00048126 - is channel 4 in use?
                        beq.b   .init_sfx                        ; 0004823c     - no, then initialise sfx
                        cmp.b   sfx_no,d0                       ; 00048023 - is requested sfx higher priority or already playing?
                        bcs.b   .exit                           ;              - yes, then exit L0004824c

.init_sfx                                                        ; original address $0004823c
                        movem.l d0/d7/a0-a2,-(a7)
                        move.w  #$4000,d1                       ; set sfx playing bit.
                        move.b  d0,sfx_no                       ; song_no_2 ; L00048023
                        bra.b   init_sound                      ; jmp $0004825c
.exit                                                           ; original address $0004824c
                        rts  




                        ;----------------------- do init song ------------------------
                        ; set the current song number, and initialise for playing.
                        ; if sound number is out of range then stop the audio.
                        ;
                        ; initialises each audio channel's data ptrs
                        ; sets cmd param 82/83
                        ; sets $00004020 
                        ;
                        ; IN: D0.l - sound/song to play?
                        ;               - 0 = play nothing/stop
                        ;               - >13 = play nothing/stop
                        ;
                        ; Init Commands:
                        ; $80 - Deactivate Audio Channel if unused (i.e. no data).
                        ; $81 - Set Channel Data ptr $0002(channelstatus)
                        ; $82 - Store next byte in $0013(channelstatus)
                        ; $83 - store next byte in $0012(channelstatus) 
                        ; $0x - +ve command, init channel data and skip to next channel
                        ;       - Set Channel Data ptr $0006(channelstatus)
                        ;       - value is index into song_channel_database
                        ;       - added to current ptr address as offset to pattern data?
                        ;       - address stored in $000e(channelstatus)
do_init_song                                                    ; original address $0004824e
L0004824e               movem.l d0/d7/a0-a2,-(a7)
                        move.w  #$8000,d1                       ; set song playing bit.
                        move.b  d0,song_no_1                    ; L00048022


                        ; if sfx, then enters here (d0 = sound number)
init_sound                                                      ; original address $0004825c
                        clr.w   play_counter                    ; L0004817e ; timer/counter
.validate_sound_no                                              ; original address $00048262
                        subq.w  #$01,d0                         ; is d0 < 0
                        bmi.b   .validation_failed              ;       yes - validation failed - L0004826c
                        cmp.w   #$000d,d0                       ; is d0 > 13
                        bcs.b   .validation_ok                  ;       no - validation is ok - L00048274
.validation_failed                                              ; original address $0004826c
                        bsr.w   do_silence_all_audio            ; bsr $00048194
                        bra.w   .exit                           ; exit after failure - L00048308

.validation_ok          ; init song/sound                       ; original address $00048274
                        lea.l   sounds_table,a0                 ; L0005847e,a0
                        asl.w   #$03,d0
                        adda.w  d0,a0                           ; a0 = sounds table entry to initialise
                        lea.l   channel_00_status,a1            ; L00048024,a1
                        moveq   #$03,d7                         ; loop counter 3 + 1 (number of channels to init)
.audio_channel_loop
                        move.w  (a0)+,d0                        ; get channel init data byte offset
                        beq.b   .init_next_channel              ; if = $0000 then init next channel - L000482fa
                        lea.l   -2(a0,d0.W),a2                  ; a2 = address of channel init data stream - $fe(a0,d0.W),a2
                        moveq   #$00,d0
                        move.w  d0,$004c(a1)                    ; Volume?
                        move.l  d0,$0002(a1)                    ; Music Data/Pattern ptr
                        move.l  d0,$000a(a1)                    ; Music Data/Pattern ptr
                        move.b  d0,$0013(a1)                    ; Unknown
                        move.b  #$01,$0012(a1)                  ; Unknown
                        move.w  d1,(a1)                         ; Channel ctrl bits

.command_loop           ; get and process init commands         ; original address $000482a8
                        move.b  (a2)+,d0
                        bpl.b   .init_channel_data_and_exit     ; L000482de

.chk_cmd_80             ; is it command 80?                     ; original address $000482ac
                        sub.b   #$80,d0
                        bne.b   .chk_cmd_81                     ; L000482c0

.do_cmd_80              ; is 80 - disable channel if no channel data    ; original address $000482b2
                        movea.l $0002(a1),a2
                        cmpa.w  #$0000,a2
                        bne.b   .command_loop                   ; L000482a8 - loop - next command
                        clr.w   (a1)                            ; disable channel, clear control bits
                        bra.b   .init_next_channel              ; L000482fa - do next channel

.chk_cmd_81             ; is it command 81?                     ; original address $000482c0
                        subq.b  #$01,d0
                        bne.b   .chk_cmd_82                     ; L000482ca

.do_cmd_81              ; is 81 - loop sequence pattern address ptr      ; original address $000482c4
                        move.l  a2,$0002(a1) 
                        bra.b   .command_loop                   ; L000482a8

.chk_cmd_82             ; is it command 82?                     ; original address $000482ca
                        subq.b  #$01,d0
                        bne.b   .chk_cmd_83                     ; L000482d4

.is_cmd_82              ; is 82 - store next byte in $0013(channelstatus)      ; original address $000482ce
                        move.b  (a2)+,$0013(a1)
                        bra.b   .command_loop                   ; L000482a8

.chk_cmd_83             ; is it command 83?                     ; original address $000482d4
                        subq.b  #$01,d0
                        bne.b   .command_loop                   ; L000482a8

.is_cmd_83              ; is 83 - pattern loop count byte in $0012(channelstatus) ; original address $000482d8
                        move.b  (a2)+,$0012(a1)
                        bra.b   .command_loop                   ; L000482a8

                        ; is MSB=0 - store ptr & set pattern data
.init_channel_data_and_exit                                     ; original address $000482de
                        move.l  a2,$0006(a1)                    ; next pattern ptr
                        lea.l   sound_pattern_data_base,a2      ; L000584e6,a2
                        ext.w   d0
                        add.w   d0,d0
                        adda.w  d0,a2
                        adda.w  (a2),a2
                        move.l  a2,$000e(a1)                    ; pattern data ptr
                        move.w  #$0001,$0052(a1)

.init_next_channel                                              ; original address $000482fa
                        lea.l   $0056(a1),a1                    ; next channel struct (86 bytes)
                        dbf.w   d7,.audio_channel_loop          ; init next audio channel - L00048286
                        or.w    d1,song_ctrl_bits               ; L00048020 ; update sound type bits & channel enable bits (all channels)

.exit                                                           ; original address $00048308
                        movem.l (a7)+,d0/d7/a0-a2
                        rts 




                ;--------------------------- do play sounds -----------------------
                ; Call this routine at regular intervals to play the current
                ; song/sfx combination. (e.g. during vbl)
                ; The game calls this at 25 frames per second to play current 
                ; songs/sfx
                ;
                ; IN:- no parameters
                ;
do_play_sounds                                                ; original address $0004830e
L0004830e               lea.l   $00dff000,a6                    ; customer chip base register.
                        lea.l   note_period_table+48,a5         ; L00048c00 ; mid point of the note period table
                        clr.w   audio_dma                       ; L0004817c
                        tst.w   song_ctrl_bits                  ; L00048020 ; sound type bits & channel enable bits (all channels)
                        beq.b   .set_hw_registers               ; L00048384 ; no active sound channels then branch

                        addq.w  #$01,play_counter               ; L0004817e ; increment play ticker counter
                        clr.w   song_ctrl_bits                  ; L00048020 ; sound type bits & channel enable bits (all channels)

.do_channel_0_cmds                                              ; original address $00048334
                        lea.l   channel_00_status,a4            ; L00048024,a4
                        move.w  (a4),d7                         ; d7 = channel ctrl bits
                        beq.b   .do_channel_1_cmds              ; L00048348
                        bsr.b   channel_command_loop            ; L00048392
                        move.w  d7,(a4)                         ; update channel ctrl bits
                        or.w    d7,song_ctrl_bits               ; L00048020 ; update sound type bits & channel enable bits (all channels)

.do_channel_1_cmds                                              ; original address $00048348
                        lea.l   channel_01_status,a4            ; L0004807a,a4
                        move.w  (a4),d7                         ; d7 = channel ctrl bits
                        beq.b   .do_channel_2_cmds              ; L0004835c
                        bsr.b   channel_command_loop            ; L00048392
                        move.w  d7,(a4)                         ; update channel ctrl bits
                        or.w    d7,song_ctrl_bits               ; L00048020 ; update sound type bits & channel enable bits (all channels)

.do_channel_2_cmds                                              ; original address $0004835c
                        lea.l   channel_02_status,a4            ; L000480d0,a4
                        move.w  (a4),d7                         ; d7 = channel ctrl bits
                        beq.b   .do_channel_3_cmds              ; L00048370
                        bsr.b   channel_command_loop            ; L00048392
                        move.w  d7,(a4)                         ; update ctrl bits
                        or.w    d7,song_ctrl_bits               ; L00048020 ; update sound type bits & channel enable bits (all channels)

.do_channel_3_cmds                                              ; original address $00048370
                        lea.l   channel_03_status,a4            ; L00048126,a4
                        move.w  (a4),d7                         ; d7 = channel ctrl bits
                        beq.b   .set_hw_registers               ; L00048384
                        bsr.b   channel_command_loop            ; L00048392
                        move.w  d7,(a4)                         ; update ctrl bits
                        or.w    d7,song_ctrl_bits               ; L00048020 ; update sound type bits & channel enable bits (all channels)

.set_hw_registers                                               ; original address $00048384
                        and.w   #$c000,song_ctrl_bits           ; L00048020 ; clear chanel enable bits, preserve sound/sfx type
                        bsr.w   update_audio_custom_registers   ; L0004887e ; set audio h/w registers.
                        rts 




                ; ------------------ channel command loop --------------------------
                ; Process channel audio commands for the current channel/sound/sfx
                ;
                ; IN:  a4 = channel status base address
                ; IN:  d7 = channel status CTRL word
                ; OUT: d7 = channel status CTRL word
                ;
channel_command_loop                                            ; original address $00048392
L00048392               subq.w  #$01,$0052(a4)
                        bne.w   L000486de

.get_pattern_data
                        movea.l $000e(a4),a3                    ; a3 = current pattern data ptr
                        bclr.l  #$0007,d7

channel_cmd_loop        ; Music Command Loop                    ; original address $000483a2
                        move.b  (a3)+,d0                        ; d0 = next pattern command
                        bpl.w   process_sound_commands          ; L0004858a - exit & process sound commands
                        bclr.l  #$0003,d7
.validate_cmd                                                   ; original address $000483ac
                        cmp.b   #$a0,d0                         ; max $20 (32) commands
                        bcc.b   channel_cmd_loop                ; is cmd < $a0 then do next command - jmp $000483a2
.valitation_ok                                                  ; original address L000483b2
                        lea.l   cmd_jump_table(pc),a0          
                        sub.b   #$80,d0                         ; d0 = jmp table index - subtract base value from command value
                        ext.w   d0                              ; d0 = word index into jump table
                        add.w   d0,d0                           ; d0 = address offset index into jump table
                        adda.w  d0,a0                           ; d0 = jump table entry address
                        move.w  (a0),d0                         ; d0 = offset to start of command routine
                        beq.b   channel_cmd_loop                ; if d0 = $0000 then NOP, do next command - jmp $000483a2
                        jmp     $00(a0,d0.W)                    ; jmp to command initialise routine.
                        ; some commands exit (rts)
                        ; others, jmp back to 'cmd_loop'


; jump table offsets from L000483c8 (32 music commands)
cmd_jump_table                                                          ; original address $000483c8
L000483c8               dc.w    music_command_01-(cmd_jump_table+0)     ; $000483c8 + $0040 = $00048408 - CMD 01
L000483ca               dc.w    music_command_02-(cmd_jump_table+2)     ; $000483ca + $00ba = $00048484 - CMD 02      
L000483cc               dc.w    music_command_03-(cmd_jump_table+4)     ; $000483cc + $00c0 = $0004848c - CMD 03              
L000483ce               dc.w    music_command_04-(cmd_jump_table+6)     ; $000483ce + $00c2 = $00048490 - CMD 04      
L000483d0               dc.w    music_command_05-(cmd_jump_table+8)     ; $000483d0 + $00c4 = $00048494 - CMD 05
L000483d2               dc.w    music_command_06-(cmd_jump_table+10)    ; $000483d2 + $00ce = $000484a0 - CMD 06     
L000483d4               dc.w    music_command_07-(cmd_jump_table+12)    ; $000483d4 + $00d4 = $000484a8 - CMD 07                      
L000483d6               dc.w    music_command_08-(cmd_jump_table+14)    ; $000483d6 + $00dc = $000484b2 - CMD 08
L000483d8               dc.w    music_command_09-(cmd_jump_table+16)    ; $000483d8 + $00ea = $000484c2 - CMD 09            
L000483da               dc.w    music_command_10-(cmd_jump_table+18)    ; $000483da + $00f8 = $000484d2 - CMD 10
L000483dc               dc.w    music_command_11-(cmd_jump_table+20)    ; $000483dc + $010a = $000484e6 - CMD 11
L000483de               dc.w    music_command_12-(cmd_jump_table+22)    ; $000483de + $0140 = $0004851e - CMD 12
L000483e0               dc.w    music_command_13-(cmd_jump_table+24)    ; $000483e0 + $0156 = $00048536 - CMD 13
L000483e2               dc.w    music_command_14-(cmd_jump_table+26)    ; $000483e2 + $010c = $000484ee - CMD 14
L000483e4               dc.w    music_command_15-(cmd_jump_table+28)    ; $000483e4 + $0132 = $00048516 - CMD 15
L000483e6               dc.w    music_command_16-(cmd_jump_table+30)    ; $000483e6 + $0158 = $0004853e - CMD 16
L000483e8               dc.w    music_command_17-(cmd_jump_table+32)    ; $000483e8 + $016e = $00048556 - CMD 17
L000483ea               dc.w    $0000                   
L000483ec               dc.w    $0000
L000483ee               dc.w    $0000                   
L000483f0               dc.w    $0000
L000483f2               dc.w    $0000                   
L000483f4               dc.w    $0000
L000483f6               dc.w    $0000                   
L000483f8               dc.w    $0000
L000483fa               dc.w    $0000                   
L000483fc               dc.w    $0000
L000483fe               dc.w    $0000                   
L00048400               dc.w    $0000
L00048402               dc.w    $0000                   
L00048404               dc.w    $0000
L00048406               dc.w    $0000                   


;
; L00048408 - CMD 01 - ($80) 
;       - Next Pattern/Loop current pattern/Loop back to start pattern or finish playing
;       - no loop if $0002(a4) not set.
music_command_01                                                ; original address $00048408
L00048408               movea.l $000a(a4),a3                    ; a3 = CMD2 saved pattern table ptr
                        cmpa.w  #$0000,a3                       ; check a3 is set
                        bne.b   channel_cmd_loop                ; if CMD2 pattern ptr != $0000 then exit, do next command - L00483a2
.do_cmd_01                                                      ; original address $00048412
                        movea.l $0006(a4),a3                    ; a3 = next pattern ptr
                        move.b  -$0001(a3),d0                   ; current pattern offset

                        subq.b  #$01,$0012(a4)                  ; decrement pattern loop counter - $0012(a4)
                        bne.b   .set_next_pattern_ptr           ; reset start of current pattern - $0004846e

                        move.b  #$01,$0012(a4)                  ; reset pattern loop counter (play once = 1) $0012(14) counter
                        move.b  #$00,$0013(a4)                  ; 

.cmd_loop               ; another command loop                  ; original address $0004842c
                        move.b  (a3)+,d0                        ; d0 = next pattern command/pattern offset
                        bpl.b   .set_next_pattern_ptr           ; L0004846e
.chk_80                                                         ; original address $00048430
                        sub.b   #$80,d0
                        bne.b   .chk_81                         ; L00048450
.is_80                  ; cmd 80                                ; original address $00048436
                        movea.l $0002(a4),a3                    ; a3 = back to start of pattern data ptr
                        cmpa.w  #$0000,a3                       ; is loop ptr set?
                        bne.b   .cmd_loop                       ;       yes, process next command - $0004842c 
                        ; disable channel & exit
                        move.w  #$0001,$004a(a4)                ;       no, disable audio channel
                        move.w  #$0000,$004c(a4)                ; volume = 0
                        moveq   #$00,d7                         ; channel ctrl bits = disabled
                        rts 
.chk_81                                                         ; original address
                        subq.b  #$01,d0
                        bne.b   .chk_82                         ; L0004845a
.is_81                  move.l  a3,$0002(a4)                    ; store pattern loop ptr
                        bra.b   .cmd_loop                       ; loop, process next command - L0004842c
.chk_82                                                         ; original address $0004845a
                        subq.b  #$01,d0
                        bne.b   .chk_83                         ; L00048464
.is_83                                                          ; original address $0004845e
                        move.b  (a3)+,$0013(a4)                 ; set $0013(a4) next pattern byte
                        bra.b   .cmd_loop                       ; loop, process next command - $0004842c
.chk_83
                        subq.b  #$01,d0
                        bne.b   .cmd_loop                       ; loop, process next command - $0004842c
                        move.b  (a3)+,$0012(a4)                 ; store pattern loop counter
                        bra.b   .cmd_loop                       ; loop, process next command - $0004842c

.set_next_pattern_ptr                                           ; original address $0004846e
                        move.l  a3,$0006(a4)
                        lea.l   sound_pattern_data_base,a3      ; pattern indirection table address
                        ext.w   d0                              ; d0 = byte extended to word  
                        add.w   d0,d0                           ; d0 = table address index
                        adda.w  d0,a3                           ; a3 = table entry ptr
                        adda.w  (a3),a3                         ; a3 = next pattern data address ptr
                        bra.w   channel_cmd_loop                        ; do next command - jmp $000483a2





;
; L00048484 - CMD 02 - ($81)
;       - store current pattern position ptr (loop back within current pattern)
music_command_02                                        ; original address $00048484
L00048484               move.l  a3,$000a(a4)
                        bra.w   channel_cmd_loop                ; do next command - jmp $000483a2






;
; L0004848c - CMD 03 - ($82)
;       - no operation
music_command_03                                        ; original address $0004848c
L0004848c               bra.w   channel_cmd_loop                ; do next command - jmp $000483a2


;
; L00048490 - CMD 04 - ($83)
;       - no operation
music_command_04                                        ; original address $00048490
L00048490               bra.w   channel_cmd_loop                ; do next command - jmp $000483a2






;
; L00048494 - CMD 05 - ($84)
;               - Set CRTL bit 5 
;               - Set Param byte $0051(s)
music_command_05                                        ; original address $00048494
L00048494               bset.l  #$0005,d7
                        move.b  (a3)+,$0051(a4)
                        bra.w   channel_cmd_loop                ; do next command - jmp $000483a2


;
; L000484a0 - CMD 06 - ($85)
;               - End/Cancel Command 05
music_command_06                                        ; original address $000484a0
L000484a0               bclr.l  #$0005,d7
                        bra.w   channel_cmd_loop                ; do next command - jmp $000483a2





;
; L000484a8 - CMD 07 - ($86)
;               - increase $0052(s) by $0100 (256)
music_command_07                                        ; original address $000484a8
L000484a8               add.w   #$0100,$0052(a4)
L000484ae               bra.w   channel_cmd_loop                ; do next command - jmp $000483a2




;
; L000484b2 - CMD 08 - $(87)
;               - clear bit 4 - channel ctrl
;               - set bit 7 - channel ctrl
;               - clear $004c(s)
;               - add $0052(s) with CMD 05 value (if active $0051(s)) or add next pattern byte 
;
music_command_08                                        ; original address $000484b2
L000484b2               bclr.l  #$0004,d7               ; clear bit 4 - channel ctrl
                        bset.l  #$0007,d7               ; set bit 7 - channel ctrl
                        clr.w   $004c(a4)       
                        bra.w   L000486c8




;
; L000484c2 - CMD 09 - ($88)
;               - set bit 3 - channel ctrl
;               - set command parameters from pattern data bytes
;
music_command_09                                        ; original address $000484c2
L000484c2               bset.l  #$0003,d7               ; set bit 3 - channel ctrl
                        move.b  (a3)+,$0024(a4)
                        move.b  (a3)+,$0025(a4)
                        bra.w   channel_cmd_loop                ; do next command - jmp $000483a2



;
; L000484d2 - CMD 10 - ($89)
;               - clear bits 0 - 2 (cmd 14)
;               - clear bits 4 -7 (cmd 5,8)
;               - preserve other bits (cmd 9)
;               - set parameter bytes
music_command_10                                        ; original address $000484d2
L000484d2               and.w   #$fff8,d7
                        bset.l  #$0000,d7
                        move.b  (a3)+,$0021(a4)
                        move.b  (a3)+,$0022(a4)
                        bra.w   channel_cmd_loop                ; do next command - jmp $000483a2



;
; L000484e6 - CMD 11 - ($8a)
;               - clear ctrl bit 0
music_command_11                                        ; original address $000484e6
L000484e6               bclr.l  #$0000,d7
                        bra.w   channel_cmd_loop                ; do next command - jmp $000483a2




; L000484ee - CMD 14 - ($8d)
;               - set bit 1
;               - clear bits 1 - 2
;               - clear bits 4 - 7
;               - preserve bit 3 (CMD 9)
music_command_14                                        ; original address $000484ee
L000484ee               and.w   #$fff8,d7
L000484f2               bset.l  #$0001,d7
L000484f6               lea.l   command_14_data,a0      ; $00058378,a0
L000484fc               moveq   #$00,d0
L000484fe               move.b  (a3)+,d0                ; d0 = next pattern byte
L00048500               add.w   d0,d0                   ; d0 = index into table
L00048502               adda.w  d0,a0                   ; a0 = table entry address
L00048504               adda.w  (a0),a0                 ; a0 = indirection address ptr
L00048506               move.b  (a0)+,$0032(a4)
L0004850a               move.b  (a0)+,$0030(a4)
L0004850e               move.l  a0,$0028(a4)
L00048512               bra.w   channel_cmd_loop                ; do next command - jmp $000483a2

; L00048516 - CMD 15
music_command_15                                        ; original address $00048516
L00048516               bclr.l  #$0001,d7
L0004851a               bra.w   channel_cmd_loop                ; do next command - jmp $000483a2





; L0004851e - CMD 12
music_command_12                                        ; original address $0004851e
L0004851e               and.w   #$fff8,d7
L00048522               bset.l  #$0002,d7
L00048526               move.b  (a3)+,$0036(a4)
L0004852a               move.b  (a3)+,$0034(a4)
L0004852e               move.b  (a3)+,$0035(a4)
L00048532               bra.w   channel_cmd_loop                ; do next command - jmp $000483a2

; L00048536 - CMD 13
music_command_13
L00048536               bclr.l  #$0002,d7
L0004853a               bra.w   channel_cmd_loop                ; do next command - jmp $000483a2

; L0004853e - CMD 16
music_command_16                                        ; original address $0004853e
L0004853e               lea.l   command_16_data,a0      ; L0005842a,a0
L00048544               moveq   #$00,d0
L00048546               move.b  (a3)+,d0
L00048548               add.w   d0,d0
L0004854a               adda.w  d0,a0
L0004854c               adda.w  (a0),a0
L0004854e               move.l  a0,$0014(a4)
L00048552               bra.w   channel_cmd_loop                ; do next command - jmp $000483a2

; L00048556 - CMD 17
music_command_17                                        ; original address $00048556
L00048556               lea.l   command_17_data,a0      ; L00048c30,a0
L0004855c               moveq   #$00,d0
L0004855e               move.b  (a3)+,d0
L00048560               asl.w   #$04,d0
L00048562               adda.w  d0,a0
L00048564               move.w  (a0)+,$003c(a4)
L00048568               move.l  (a0)+,$003e(a4)
L0004856c               move.w  (a0)+,$0042(a4)
L00048570               move.l  (a0)+,$0044(a4)
L00048574               move.w  (a0)+,$0048(a4)
L00048578               bclr.l  #$0006,d7
L0004857c               tst.w   (a0)
L0004857e               beq.w   channel_cmd_loop                ; do next command - jmp $000483a2
L00048582               bset.l  #$0006,d7
L00048586               bra.w   channel_cmd_loop                ; do next command - jmp $000483a2


                ; +ve pattern command data (end of pattern command loop)
                ; IN: A4 = Sound Channel Structure
                ; IN: A3 = Next Pattern Command Ptr
                ; IN: D0 = command data
                ; IN: D7 = Channel Ctrl Bits
process_sound_commands                                  ; original address $0004858a         
L0004858a       btst.l  #$0006,d7
L0004858e       bne.b   L00048594
L00048590       add.b   $0013(a4),d0
L00048594       move.b  d0,$004f(a4)
L00048598       btst.l  #$0000,d7
L0004859c       beq.b   L000485a8
L0004859e       add.b   $0021(a4),d0
L000485a2       move.b  $0022(a4),$0023(a4)
L000485a8       move.b  d0,$0050(a4)
L000485ac       ext.w   d0
L000485ae       sub.w   $003c(a4),d0
L000485b2       add.w   d0,d0
L000485b4       cmp.w   #$ffd0,d0
L000485b8       blt.b   L000485c0
L000485ba       cmp.w   #$002c,d0
L000485be       ble.b   L000485d6

L000485c0       move.b  $004f(a4),d1
L000485c4       move.b  $0050(a4),d2
L000485c8       move.w  $003c(a4),d3
L000485cc       move.w  $0054(a4),d4
L000485d0       movea.l $0006(a4),a2
L000485d4       illegal

L000485d6       move.w  $00(a5,d0.W),$004a(a4)
L000485dc       btst.l  #$0002,d7
L000485e0       beq.b   L0004863c
L000485e2       move.b  $0050(a4),d0
L000485e6       add.b   $0034(a4),d0
L000485ea       ext.w   d0
L000485ec       sub.w   $003c(a4),d0
L000485f0       add.w   d0,d0
L000485f2       cmp.w   #$ffd0,d0
L000485f6       blt.b   L000485fe
L000485f8       cmp.w   #$002c,d0
L000485fc       ble.b   L00048614

L000485fe       move.b  $004f(a4),d1
L00048602       move.b  $0050(a4),d2
L00048606       move.w  $003c(a4),d3
L0004860a       move.w  $0054(a4),d4
L0004860e       movea.l $0006(a4),a2
L00048612       illegal

L00048614       move.w  $00(a5,d0.W),d0
L00048618       sub.w   $004a(a4),d0
L0004861c       asr.w   #$01,d0
L0004861e       ext.l   d0
L00048620       move.b  $0035(a4),d1
L00048624       ext.w   d1
L00048626       divs.w  d1,d0
L00048628       move.w  d0,$003a(a4)
L0004862c       move.b  d1,$0039(a4)

L00048630       add.b   d1,d1
L00048632       move.b  d1,$0038(a4)
L00048636       move.b  $0036(a4),$0037(a4)
L0004863c       btst.l  #$0003,d7
L00048640       beq.b   L00048692
L00048642       move.b  $0050(a4),d0
L00048646       add.b   $0024(a4),d0
L0004864a       ext.w   d0
L0004864c       sub.w   $003c(a4),d0
L00048650       add.w   d0,d0
L00048652       cmp.w   #$ffd0,d0
L00048656       blt.b   L0004865e
L00048658       cmp.w   #$002c,d0
L0004865c       ble.b   L00048674

L0004865e       move.b  $004f(a4),d1
L00048662       move.b  $0050(a4),d2
L00048666       move.w  $003c(a4),d3
L0004866a       move.w  $0054(a4),d4
L0004866e       movea.l $0006(a4),a2
L00048672       illegal

L00048674       move.w  $00(a5,d0.W),d0
L00048678       sub.w   $004a(a4),d0
L0004867c       ext.l   d0
L0004867e       moveq   #$00,d1
L00048680       move.b  $0025(a4),d1
L00048684       divs.w  d1,d0
L00048686       move.w  d0,$0026(a4)
L0004868a       neg.w   d0
L0004868c       muls.w  d1,d0
L0004868e       sub.w   d0,$004a(a4)
L00048692       btst.l  #$0001,d7
L00048696       beq.b   L000486aa
L00048698       move.b  #$01,$0033(a4)
L0004869e       move.l  $0028(a4),$002c(a4)
L000486a4       move.b  $0030(a4),$0031(a4)
L000486aa       bset.l  #$0004,d7
L000486ae       move.l  $0014(a4),$0018(a4)
L000486b4       move.w  #$0001,$001e(a4)
L000486ba       clr.w   $004c(a4)
L000486be       move.w  $0054(a4),d0
L000486c2       or.w    d0,audio_dma                    ; L0004817c

; jmp destination from 'pattern command 08 ($87)'
L000486c8       moveq   #$00,d0
L000486ca       move.b  $0051(a4),d0                    ; Cmd 05 byte parameter
L000486ce       btst.l  #$0005,d7                       ; is CMD 05 is active?
L000486d2       bne.b   L000486d6                       ;       yes, use CMD 05 param value
L000486d4       move.b  (a3)+,d0                        ;       no, use next pattern param value
L000486d6       add.w   d0,$0052(a4)                    ; update $0052(s)
L000486da       move.l  a3,$000e(a4)                    ; store pattern position ptr. 


; jmp destination from 'process_command_loop' when $0052(s) is not $0000
L000486de       btst.l  #$0007,d7                       ; Is Command 8 Active?
L000486e2       bne.w   exit_process_sound_commands     ; L0004887c - yes, don't do the following and exit


L000486e6       move.w  $004a(a4),d0
L000486ea       btst.l  #$0003,d7
L000486ee       beq.b   L00048702
L000486f0       subq.b  #$01,$0025(a4)
L000486f4       bne.b   L000486fa
L000486f6       bclr.l  #$0003,d7
L000486fa       sub.w   $0026(a4),d0
L000486fe       bra.w   L000487d4
L00048702       btst.l  #$0000,d7
L00048706       beq.b   L0004874e
L00048708       subq.b  #$01,$0023(a4)
L0004870c       bcc.w   L000487d4
L00048710       move.b  $004f(a4),d0
L00048714       move.b  $0050(a4),d1
L00048718       move.b  d0,$0050(a4)
L0004871c       ext.w   d0
L0004871e       sub.w   $003c(a4),d0
L00048722       add.w   d0,d0
L00048724       cmp.w   #$ffd0,d0
L00048728       blt.b   L00048730
L0004872a       cmp.w   #$002c,d0
L0004872e       ble.b   L00048746

L00048730       move.b  $004f(a4),d1
L00048734       move.b  $0050(a4),d2
L00048738       move.w  $003c(a4),d3
L0004873c       move.w  $0054(a4),d4
L00048740       movea.l $0006(a4),a2
L00048744       illegal

L00048746       move.w  $00(a5,d0.W),d0
L0004874a       bra.w   L000487d4
L0004874e       btst.l  #$0001,d7
L00048752       beq.b   L000487b0
L00048754       subq.b  #$01,$0033(a4)
L00048758       bne.b   L000487d4
L0004875a       movea.l $002c(a4),a0
L0004875e       move.b  (a0)+,d0
L00048760       subq.b  #$01,$0031(a4)
L00048764       bne.b   L00048770
L00048766       movea.l $0028(a4),a0
L0004876a       move.b  $0030(a4),$0031(a4)
L00048770       move.l  a0,$002c(a4)
L00048774       move.b  $0032(a4),$0033(a4)
L0004877a       add.b   $0050(a4),d0
L0004877e       ext.w   d0
L00048780       sub.w   $003c(a4),d0
L00048784       add.w   d0,d0
L00048786       cmp.w   #$ffd0,d0
L0004878a       blt.b   L00048792
L0004878c       cmp.w   #$002c,d0
L00048790       ble.b   L000487a8

L00048792       move.b  $004f(a4),d1
L00048796       move.b  $0050(a4),d2
L0004879a       move.w  $003c(a4),d3
L0004879e       move.w  $0054(a4),d4
L000487a2       movea.l $0006(a4),a2
L000487a6       illegal

L000487a8       move.w  $00(a5,d0.W),d0
L000487ac       bra.w   L000487d4
L000487b0       btst.l  #$0002,d7
L000487b4       beq.b   L000487d4
L000487b6       subq.b  #$01,$0037(a4)
L000487ba       bcc.b   L000487d4
L000487bc       addq.b  #$01,$0037(a4)
L000487c0       subq.b  #$01,$0039(a4)
L000487c4       bne.b   L000487d0
L000487c6       neg.w   $003a(a4)
L000487ca       move.b  $0038(a4),$0039(a4)
L000487d0       add.w   $003a(a4),d0
L000487d4       move.w  d0,$004a(a4)
L000487d8       btst.l  #$0004,d7
L000487dc       beq.w   exit_process_sound_commands     ; L0004887c
L000487e0       subq.w  #$01,$001e(a4)
L000487e4       bne.w   L00048866
L000487e8       movea.l $0018(a4),a0
L000487ec       moveq   #$00,d0
L000487ee       move.b  (a0)+,d0
L000487f0       beq.b   L00048834
L000487f2       bmi.b   L0004880e
L000487f4       move.w  d0,$001e(a4)
L000487f8       move.b  #$01,$001c(a4)
L000487fe       move.b  #$01,$001d(a4)
L00048804       move.b  (a0)+,$0020(a4)
L00048808       move.l  a0,$0018(a4)
L0004880c       bra.b   L00048866
L0004880e       neg.b   d0
L00048810       move.w  d0,$001e(a4)
L00048814       move.b  #$01,$0020(a4)
L0004881a       move.b  (a0)+,d0
L0004881c       bpl.b   L00048824
L0004881e       neg.b   d0
L00048820       neg.b   $0020(a4)
L00048824       move.b  d0,$001c(a4)
L00048828       move.b  #$01,$001d(a4)
L0004882e       move.l  a0,$0018(a4)
L00048832       bra.b   L00048866
L00048834       move.b  (a0),d0
L00048836       beq.b   L00048842
L00048838       bpl.b   L0004883c
L0004883a       neg.b   d0
L0004883c       sub.w   $0052(a4),d0
L00048840       bmi.b   L00048848
L00048842       bclr.l  #$0004,d7
L00048846       bra.b   exit_process_sound_commands     ; L0004887c

L00048848       neg.w   d0
L0004884a       move.w  d0,$001e(a4)
L0004884e       move.b  #$00,$001c(a4)
L00048854       move.b  #$00,$001d(a4)
L0004885a       move.b  #$00,$0020(a4)
L00048860       move.l  a0,$0018(a4)
L00048864       bra.b   exit_process_sound_commands     ; L0004887c

L00048866       subq.b  #$01,$001d(a4)
L0004886a       bne.b   exit_process_sound_commands     ; L0004887c

L0004886c       move.b  $001c(a4),$001d(a4)
L00048872       move.b  $0020(a4),d0
L00048876       ext.w   d0
L00048878       add.w   d0,$004c(a4)

exit_process_sound_commands                             ; original address $0004887c
L0004887c       rts 




update_audio_custom_registers
L0004887e       move.w  audio_dma,d0                    ;L0004817c,d0
L00048884       beq.b   L000488f4
L00048886       move.w  d0,$0096(a6)
L0004888a       move.w  d0,d1
L0004888c       lsl.w   #$07,d1
L0004888e       move.w  d1,$009c(a6)
L00048892       moveq   #$00,d2
L00048894       moveq   #$01,d3
L00048896       btst.l  #$0000,d0
L0004889a       beq.b   L000488a4
L0004889c       move.w  d3,$00a6(a6)
L000488a0       move.w  d2,$00aa(a6)
L000488a4       btst.l  #$0001,d0
L000488a8       beq.b   L000488b2
L000488aa       move.w  d3,$00b6(a6)
L000488ae       move.w  d2,$00ba(a6)
L000488b2       btst.l  #$0002,d0
L000488b6       beq.b   L000488c0
L000488b8       move.w  d3,$00c6(a6)
L000488bc       move.w  d2,$00ca(a6)
L000488c0       btst.l  #$0003,d0
L000488c4       beq.b   L000488ce
L000488c6       move.w  d3,$00d6(a6)
L000488ca       move.w  d2,$00da(a6)
L000488ce       move.w  $001e(a6),d2
L000488d2       and.w   d1,d2
L000488d4       cmp.w   d1,d2
L000488d6       bne.b   L000488ce
L000488d8       moveq   #$02,d2
L000488da       move.w  $0006(a6),d3
L000488de       and.w   #$ff00,d3
L000488e2       move.w  $0006(a6),d4
L000488e6       and.w   #$ff00,d4
L000488ea       cmp.w   d4,d3
L000488ec       beq.b   L000488e2
L000488ee       move.w  d4,d3
L000488f0       dbf.w   d2,L000488e2

L000488f4       move.w  master_audio_volume_mask_1,d1           ; L0004801c,d1
L000488fa       move.w  master_audio_volume_mask_2,d2           ; L0004801e,d2
L00048900       lea.l   channel_00_status,a0                    ; L00048024,a0
L00048906       move.w  d1,d3
L00048908       btst.b  #$0006,(a0)
L0004890c       beq.b   L00048910
L0004890e       move.w  d2,d3
L00048910       and.w   $004c(a0),d3
L00048914       move.w  d3,$00a8(a6)
L00048918       move.w  $004a(a0),$00a6(a6)
L0004891e       btst.l  #$0000,d0
L00048922       beq.b   L00048932
L00048924       move.w  $0042(a0),$00a4(a6)
L0004892a       move.l  $003e(a0),$00a0(a6)
L00048930       bra.b   L0004893e
L00048932       move.w  $0048(a0),$00a4(a6)
L00048938       move.l  $0044(a0),$00a0(a6)
L0004893e       lea.l   channel_01_status,a0                    ; L0004807a,a0
L00048944       move.w  d1,d3
L00048946       btst.b  #$0006,(a0)
L0004894a       beq.b   L0004894e
L0004894c       move.w  d2,d3
L0004894e       and.w   $004c(a0),d3
L00048952       move.w  d3,$00b8(a6)
L00048956       move.w  $004a(a0),$00b6(a6)
L0004895c       btst.l  #$0001,d0
L00048960       beq.b   L00048970
L00048962       move.w  $0042(a0),$00b4(a6)
L00048968       move.l  $003e(a0),$00b0(a6)
L0004896e       bra.b   L0004897c
L00048970       move.w  $0048(a0),$00b4(a6)
L00048976       move.l  $0044(a0),$00b0(a6)
L0004897c       lea.l   channel_02_status,a0                    ; L000480d0,a0
L00048982       move.w  d1,d3
L00048984       btst.b  #$0006,(a0)
L00048988       beq.b   L0004898c
L0004898a       move.w  d2,d3
L0004898c       and.w   $004c(a0),d3
L00048990       move.w  d3,$00c8(a6)
L00048994       move.w  $004a(a0),$00c6(a6)
L0004899a       btst.l  #$0002,d0
L0004899e       beq.b   L000489ae
L000489a0       move.w  $0042(a0),$00c4(a6)
L000489a6       move.l  $003e(a0),$00c0(a6)
L000489ac       bra.b   L000489ba
L000489ae       move.w  $0048(a0),$00c4(a6)
L000489b4       move.l  $0044(a0),$00c0(a6)
L000489ba       lea.l   channel_03_status,a0                    ; L00048126,a0
L000489c0       move.w  d1,d3
L000489c2       btst.b  #$0006,(a0)
L000489c6       beq.b   L000489ca
L000489c8       move.w  d2,d3
L000489ca       and.w   $004c(a0),d3
L000489ce       move.w  d3,$00d8(a6)
L000489d2       move.w  $004a(a0),$00d6(a6)
L000489d8       btst.l  #$0003,d0
L000489dc       beq.b   L000489ec
L000489de       move.w  $0042(a0),$00d4(a6)
L000489e4       move.l  $003e(a0),$00d0(a6)
L000489ea       bra.b   L000489f8
L000489ec       move.w  $0048(a0),$00d4(a6)
L000489f2       move.l  $0044(a0),$00d0(a6)
L000489f8       or.w    #$8000,d0
L000489fc       move.w  d0,$0096(a6)
L00048a00       clr.w   audio_dma                               ; L0004817c
L00048a06       rts


                ;------------------- initialise music samples --------------------
                ; extract sample data ptrs and lengths from the IFF sample
                ; data.
                ;
                ; IN: a0    - music sample table address $4D52 - default_sample_data
                ; IN: a1    - music/song instrument data $4BFA - instrument_data
                ;
init_instruments                                                ; original address $00048a08
                move.l  (a0)+,d0
                beq.b   .exit
                move.w  (a0)+,(a1)
                move.w  (a0)+,$000e(a1)
                move.l  a0,-(a7)
                lea.l   -8(a0,d0.L),a0                          ; $f8(a0,d0.L),a0
                move.l  $0004(a0),d0
                addq.l  #$08,d0
                bsr.w   process_instrument                      ; L00048a28
                movea.l (a7)+,a0
                bra.b   init_instruments                        ; jmp L00048a08
.exit           rts 


                ; ------------------ process instrument  ----------------
                ; IN: A0 = ptr to start of 'FORM' block of sample data.
                ; IN: A1 = ptr to Instrument Entry in Music Data.
                ; IN: D0 = length of sample including headers.
                ;
process_instrument
                move.l  a1,-(a7)
                bsr.w   process_sample_data     ; L00048a6c - External Include 'process_sample_data.s'
                movea.l (a7)+,a1
                addq.l  #$02,a1                 ; addaq
                movea.l sample_vhdr_ptr,a0      ; L00048b80,a0
                move.l  (a0)+,d0                ; d0 = sample length length
                bclr.l  #$0000,d0               ; d0 = make length even
                move.l  (a0)+,d1                ; d1 = sample repeat length 
                bclr.l  #$0000,d1               ; d1 = make repeat length even
                movea.l sample_body_ptr,a0      ; L00048ba8,a0
                move.l  a0,(a1)+                ; store sample start address in instrument table offset 2-5
                adda.l  d0,a0                   ; a0 = start of repeat section of sample
                add.l   d1,d0                   ; d0 = total length of sample + repeat
                lsr.l   #$01,d0                 ; d0 = count of word length
                move.w  d0,(a1)+                ; store sample length (words) in table offset 6-7
                tst.l   d1                      ; test repeat length
                bne.b   .set_repeat             ; L00048a60
.no_repeat
                lea.l   silient_repeat,a0       ; L00048d80,a0 - silent repeat sample data
                moveq   #$02,d1                 ; set single word length for silent repeat length
.set_repeat
                move.l  a0,(a1)+                ; set repeat start address in table offset 8 - 11
                lsr.l   #$01,d1                 ; d1 = repeat length (words)
                move.w  d1,(a1)+                ; set repeat length (words) in table offset 12-13
                addq.l  #$02,a1                 ; update instrument table ptr (skip param 2 - unknown 0 or -1 value) - 14-15 ; addaq
                rts 









; FUNCTION:
; process_sample_data
;
; IN:
; A0 = ptr to start of 'FORM' or 'CAT ' block of sample data.
; A1 = ptr to Instrument Entry in Music Data.
; D0 = remaining length of sample file including headers.
;
; OUT:
; sample_status         ; 0 = success, 1 = missing FORM/CAT chunk, 2 = missing 8SVX chunk
; sample_vhdr_ptr       ; address ptr to sample vhdr data
; sample_body_ptr       ; address ptr to raw sample data
;
                include './lib/process_sample_data.s'





                ; --------------------- Note Period Table ------------------------
                ;       - audio channel period values - note frequenies
                ;       - indexes to $00004bba clamped to -48 bytes or +44 bytes to remain in table range
                ;       - I've got the table running B to B (may be I'm a semi-tone out C to C - most likely) 
note_period_table                                               ; original address $00048BD0
L00048BD0       dc.w    $06FE, $0699, $063B, $05E1, $058D, $053D, $04F2, $04AB          
L00048BE0       dc.w    $0467, $0428, $03EC, $03B4, $037F, $034D, $031D, $02F1          
L00048BF0       dc.w    $02C6, $029E, $0279, $0255, $0234, $0214, $01F6, $01DA  

L00048c00       dc.w    $01BF, $01A6, $018F, $0178, $0163, $014F, $013C, $012B          
L00048C10       dc.w    $011A, $010A, $00FB, $00ED, $00E0, $00D3, $00C7, $00BC          
L00048C20       dc.w    $00B2, $00A8, $009E, $0095, $008D, $0085, $007E, $0077          




command_17_data
L00048C30       dc.w    $0021, $0004, $8D82, $000B, $0004, $8D82, $000B, $0000          ;.!..............

instrument_data                                                 ; original address $00048C40
L00048C40       dc.w    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000          ;................
L00048C50       dc.w    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000          ;................
L00048C60       dc.w    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000          ;................
L00048C70       dc.w    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000          ;................
L00048C80       dc.w    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000          ;................
L00048C90       dc.w    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000          ;................
L00048CA0       dc.w    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000          ;................
L00048CB0       dc.w    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000          ;................
L00048CC0       dc.w    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000          ;................
L00048CD0       dc.w    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000          ;................
L00048CE0       dc.w    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000          ;................
L00048CF0       dc.w    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000          ;................
L00048D00       dc.w    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000          ;................
L00048D10       dc.w    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000          ;................
L00048D20       dc.w    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000          ;................
L00048D30       dc.w    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000          ;................
L00048D40       dc.w    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000          ;................
L00048D50       dc.w    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000          ;................
L00048D60       dc.w    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000          ;................
L00048D70       dc.w    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000   

silient_repeat                                  ; original address $00048D80
L00048D80       dc.w    $0000                   ; 2 bytes of silent sample repeat data (for samples that don't have a repeat section)


L00048D82       dc.w    $0074, $60DC, $82BB, $457E, $24A0, $8C00, $7460          ;...t`...E~$...t`
L00048D90       dc.w    $DC82, $BB45, $7E24, $A08C


                ; ------ music sample data table (12 sample offsets & 2 word params) ------
                ; 12 sound samples in IFF 8SVX format.
                ; Table of address offsets below, not sure what the additional two 16 bit 
                ; parameters that follow the offset represent yet. maybe volume and something else.
                ;
raw_sample_data_table                                   ; original address $00048d98
L00048d98       
.data_01        dc.l    sample_file_01-.data_01         ; $00048E0C - $00048d98 = $00000074
                dc.w    $0030, $0000                          
.data_02        dc.l    sample_file_02-.data_02         ; $0004AA74 - $00048dA0 = $00001CD4
                dc.w    $0018, $0000
.data_03        dc.l    sample_file_03-.data_03         ; $0004c5c8 - $00048dA0 = $00003820
                dc.w    $0030, $0000
.data_04        dc.l    sample_file_04-.data_04         ; $0004d090 - $00048DB0 = $000042E0
                dc.w    $0018, $FFFF
.data_05        dc.l    sample_file_05-.data_05         ; $0004e492 - $00048DB8 = $000056DA
                dc.w    $0039, $0000
.data_06        dc.l    sample_file_06-.data_06         ; $0004fcf0 - $00048DC0 = $00006F30
                dc.w    $0018, $0000
.data_07        dc.l    sample_file_07-.data_07         ; $00050c50 - $00048DC8 = $00007E88
                dc.w    $0018, $0000
.data_08        dc.l    sample_file_08-.data_08         ; $00051344 - $00048DD0 = $00008574
                dc.w    $0018, $0000
.data_09        dc.l    sample_file_09-.data_09         ; $000519de - $00048DD8 = $00008C06
                dc.w    $0018, $0000
.data_10        dc.l    sample_file_10-.data_10         ; $00052690 - $00048DE0 = $000098B0
                dc.w    $0018, $0000
.data_11        dc.l    sample_file_11-.data_11         ; $00052fa0 - $00048DE8 = $0000A1B8
                dc.w    $0018, $0000         
.data_12        dc.l    sample_file_12-.data_12         ; $00053676 - $00048DF0 = $0000A886 
                dc.w    $0018, $0000
L00048DF8       dc.w    $0000, $0000                    ; 0 marks the end of sample table data                    


 ; Sample 01
sample_file_01
                ; --------------------- Sound Sample 1 -------------------
                ; Start Address: $00048DFC
                ; Name:          PIPEORGAN-C4
                include "./music/sample_file_01.s"


; Sample 02
sample_file_02
                ; --------------------- Sound Sample 2 -------------------
                ; Start Address: $0004A7A8
                ; Name:          MOOGBASS-C2
                include "./music/sample_file_02.s"



; Sample 03
sample_file_03
                ; --------------------- Sound Sample 3 -------------------
                ; Start Address: $0004C8E8
                ; Name:          STRINGS-C4
                include "./music/sample_file_03.s"


; Sample 04
sample_file_04
                ; --------------------- Sound Sample 4 -------------------
                ; Start Address: $0004E43C
                ; Name:          HITSNARE-C2
                include "./music/sample_file_04.s"


; Sample 05
sample_file_05
                ; --------------------- Sound Sample 5 -------------------
                ; Start Address: $0004F8F4
                ; Name:          TIMELESS-A4        
                include "./music/sample_file_05.s"


; Sample 06
sample_file_06
                ; --------------------- Sound Sample 6 -------------------
                ; Start Address: $00050CC2
                ; Name:          GUNFIRE2
                include "./music/sample_file_06.s"



; Sample 07
sample_file_07
                ; --------------------- Sound Sample 7 -------------------
                ; Start Address: $00051C22
                ; Name:          HELICOPTER
                include "./music/sample_file_07.s"



; Sample 08
sample_file_08
                ; --------------------- Sound Sample 8 -------------------
                ; Start Address: $00052C74
                ; Name:          THROWGRENADE
                include "./music/sample_file_08.s"



; Sample 09
sample_file_09
                ; --------------------- Sound Sample 9 -------------------
                ; Start Address: $00053926
                ; Name:          BATARANG
                include "./music/sample_file_09.s"




; Sample 10
sample_file_10
                ; --------------------- Sound Sample 10 -------------------
                ; Start Address: $00054236
                ; Name:          BATROPE
                include "./music/sample_file_10.s"



; Sample 11
sample_file_11
                ; --------------------- Sound Sample 11 -------------------
                ; Start Address: $0005490C
                ; Name:          YOU-GETTIN-HIT
                include "./music/sample_file_11.s"



; Sample 12
sample_file_12
                ; --------------------- Sound Sample 12 -------------------
                ; Start Address: $00055010
                ; Name:          EXPLOSION
                include "./music/sample_file_12.s"


                          

command_14_data
L00055C62       dc.w    L00055C90-(command_14_data+00)          ;$002E   ; $00055C62 + $002E = $00055C90
L00055C64       dc.w    L00055C93-(command_14_data+02)          ;$002F   ; $00055C64 + $002F = $00055C93
L00055C66       dc.w    L00055C97-(command_14_data+04)          ;$0031   ; $00055C66 + $0031 = $00055C97
L00055C68       dc.w    L00055C9C-(command_14_data+06)          ;$0034   ; $00055C68 + $0034 = $00055C9C
L00055C6a       dc.w    L00055CB1-(command_14_data+08)          ;$0047   ; $00055C6a + $0047 = $00055CB1
L00055C6c       dc.w    L00055CB6-(command_14_data+10)          ;$004A   ; $00055C6c + $004A = $00055CB6
L00055C6e       dc.w    L00055CBC-(command_14_data+12)          ;$004E   ; $00055C6e + $004E = $00055CBC
L00055C70       dc.w    L00055CBF-(command_14_data+14)          ;$004F   ; $00055C70 + $004F = $00055CBF
L00055C72       dc.w    L00055CC2-(command_14_data+16)          ;$0050   ; $00055C72 + $0050 = $00055CC2
L00055C74       dc.w    L00055CC5-(command_14_data+18)          ;$0051   ; $00055C74 + $0051 = $00055CC5
L00055C76       dc.w    L00055CCA-(command_14_data+20)          ;$0054   ; $00055C76 + $0054 = $00055CCA
L00055C78       dc.w    L00055CCF-(command_14_data+22)          ;$0057   ; $00055C78 + $0057 = $00055CCF
L00055C7a       dc.w    L00055CD4-(command_14_data+24)          ;$005A   ; $00055C7a + $005A = $00055CD4
L00055C7c       dc.w    L00055CD9-(command_14_data+26)          ;$005D   ; $00055C7c + $005D = $00055CD9
L00055C7e       dc.w    L00055CDE-(command_14_data+28)          ;$0060   ; $00055C7e + $0060 = $00055CDE
L00055C80       dc.w    L00055CF3-(command_14_data+30)          ;$0073   ; $00055C80 + $0073 = $00055CF3
L00055C82       dc.w    L00055CF8-(command_14_data+32)          ;$0076   ; $00055C82 + $0076 = $00055CF8
L00055C84       dc.w    L00055CFD-(command_14_data+34)          ;$0079   ; $00055C84 + $0079 = $00055CFD
L00055C86       dc.w    L00055D02-(command_14_data+36)          ;$007C   ; $00055C86 + $007C = $00055D02
L00055C88       dc.w    L00055D07-(command_14_data+38)          ;$007F   ; $00055C88 + $007F = $00055D07
L00055C8a       dc.w    L00055D0C-(command_14_data+40)          ;$0082   ; $00055C8a + $0082 = $00055D0C
L00055C8c       dc.w    L00055D10-(command_14_data+42)          ;$0084   ; $00055C8c + $0084 = $00055D10
L00055C8e       dc.w    L00055D15-(command_14_data+44)          ;$0087   ; $00055C8e + $0087 = $00055D15

L00055C90       dc.b    $01,$01,$00
L00055C93       dc.b    $01,$02,$00,$0C
L00055C97       dc.b    $01,$03,$00,$03,$07
L00055C9C       dc.b    $01,$13,$00,$0C,$01,$0B,$02,$0A,$03,$09,$04,$08,$05,$07,$06,$05,$04,$03,$02,$01,$00
L00055CB1       dc.b    $01,$03,$00,$03,$07
L00055CB6       dc.b    $01,$04,$00,$0C,$03,$07
L00055CBC       dc.b    $01,$01,$00
L00055CBF       dc.b    $01,$01,$00 
L00055CC2       dc.b    $01,$01,$00
L00055CC5       dc.b    $01,$03,$00,$05,$09
L00055CCA       dc.b    $01,$03,$00,$04,$07
L00055CCF       dc.b    $01,$03,$00,$05,$08
L00055CD4       dc.b    $01,$03,$00,$03,$08
L00055CD9       dc.b    $01,$03,$00,$04,$09
L00055CDE       dc.b    $01,$13,$00,$18,$02
L00055CF3       dc.b    $0B,$02,$0A,$03,$09
L00055CF8       dc.b    $04,$08,$05,$07,$06
L00055CFD       dc.b    $05,$04,$03,$02,$01,$00,$01,$03,$00,$05,$07,$01,$03,$00,$03,$07,$01,$03,$00,$01,$07 
L00055D02       dc.b    $01,$03,$00,$05,$09
L00055D07       dc.b    $01,$03,$00,$18,$0C
L00055D0C       dc.b    $01,$02,$00,$0C
L00055D10       dc.b    $01,$03,$00,$03,$07
L00055D15       dc.b    $01,$03,$00,$03,$08


command_16_data ; also end of cmd 14 data ptr
L00055d1a       dc.w    $0014,$0019,$001E,$0020
L00055D22       dc.w    $0024,$0028,$002C,$0032,$0038,$003E,$010F,$05FE         ;.$.(.,.2.8.>....
L00055D32       dc.w    $0005,$FF01,$0F0A,$FF00,$05FF,$010F,$0000,$0111         ;................
L00055D42       dc.w    $05FE,$0000,$010F,$07FF,$0000,$010E,$05FE,$0000         ;................
L00055D52       dc.w    $010A,$08FF,$01FE,$0000,$010F,$07FE,$01FF,$0000
L00055d62       dc.w    $010F,$05FE,$05FF,$0000,$013E,$0000


modified_pattern_01
;p19
L000562DBm          dc.b      $90,$01
                    dc.b      $8F,$01
                    dc.b      $84,$30
                    dc.b      $3a,$3a
                    dc.b      $3a,$30
                    dc.b      $3a,$30
                    dc.b      $85
                    dc.b      $80

modified_patternList
L00055ED6m     dc.b    $81,$01,$80          ; Loop Pattern $01
               even
                ;------------------------ song table ----------------------
                ; A table of song/sfx entries
                ;  - 13 entries (4 songs & 9 SFX?)
                ;  - one 16 bit word per audio channel (4 per table entry)
                ;       - $0000 = channel unused
                ;       - Value is an offset to the channel data for the sound
                ;               - each value is a byte offset from the current word's address in the table.
                ;
                ; 3 channel music, 1 channel sfx?
                ;
sounds_table
sound_01
L00055d6e       dc.w    sound_01_chan_00-sound_01       ; $0168   ; $00055d6e + $0168 = $00055ED6 
L00055d70       dc.w    sound_01_chan_01-(sound_01+2)   ; $011D   ; $00055d70 + $011D = $00055E8D 
L00055d72       dc.w    sound_01_chan_02-(sound_01+4)   ; $00F0   ; $00055d72 + $00F0 = $00055E62 
L00055d74       dc.w    $0000   ; unused, reserved for sfx

;; Modified SOund 01
;L00055d6e       dc.w    modified_patternList-sound_01       ; $0168   ; $00055d6e + $0168 = $00055ED6 
;L00055d70       dc.w    $0000 
;L00055d72       dc.w    $0000 
;L00055d74       dc.w    $0000   ; unused, reserved for sfx

sound_02
L00055d76       dc.w    sound_02_chan_00-sound_02       ; $05A2   ; $00055d76 + $05A2 = $00056318
L00055d78       dc.w    sound_02_chan_01-(sound_02+2)   ; $05A2   ; $00055d78 + $05A2 = $0005631A
L00055d7a       dc.w    sound_02_chan_02-(sound_02+4)   ; $05A2   ; $00055d7a + $05A2 = $0005631C
L00055d7c       dc.w    $0000   ; unused, reserved for sfx

sound_03
L00055d7e       dc.w    sound_03_chan_00-sound_03       ; $0631   ; $00055d7e + $0631 = $000563AF 
L00055d80       dc.w    sound_03_chan_01-(sound_03+2)   ; $0631   ; $00055d80 + $0631 = $000563B1 
L00055d82       dc.w    sound_03_chan_02-(sound_03+4)   ; $0631   ; $00055d82 + $0631 = $000563B3 
L00055d84       dc.w    $0000   ; unused, reserved for sfx

sound_04
L00055d86       dc.w    sound_04_chan_00-sound_04       ; $0658   ; $00055d86 + $0658 = $000563DE 
L00055d88       dc.w    sound_04_chan_01-(sound_04+2)   ; $0654   ; $00055d88 + $0654 = $000563DC 
L00055d8a       dc.w    sound_04_chan_02-(sound_04+4)   ; $0656   ; $00055d8a + $0656 = $000563E0 
L00055d8c       dc.w    $0000   ; unused, reserved for sfx

sound_05        ; unused - (drip in level 1)
L00055d8e       dc.w    $0000   ; unused, reserved for music
L00055d90       dc.w    $0000   ; unused, reserved for music
L00055d92       dc.w    $0000   ; unused, reserved for music
L00055d94       dc.w    $0000   ; unused, reserved for music

sound_06        ; unused - (gas leak in level 1)
L00055d96       dc.w    $0000   ; unused, reserved for music
L00055d98       dc.w    $0000   ; unused, reserved for music
L00055d9a       dc.w    $0000   ; unused, reserved for music
L00055d9c       dc.w    $0000   ; unused, reserved for music

sound_07
L00055d9e       dc.w    $0000   ; unused, reserved for music
L00055da0       dc.w    $0000   ; unused, reserved for music
L00055da2       dc.w    $0000   ; unused, reserved for music
L00055da4       dc.w    sound_07_chan_03-(sound_07+6)   ; $003A   ; $00055da4 + $003A = $00055DDE

sound_08
L00055da6       dc.w    $0000   ; unused, reserved for music
L00055da8       dc.w    $0000   ; unused, reserved for music
L00055daa       dc.w    $0000   ; unused, reserved for music
L00055dac       dc.w    sound_08_chan_03-(sound_08+6)   ; $0030   ; $00055dac + $0030 = $00055DDC

sound_09
L00055dae       dc.w    $0000   ; unused, reserved for music
L00055db0       dc.w    $0000   ; unused, reserved for music
L00055db2       dc.w    $0000   ; unused, reserved for music
L00055db4       dc.w    sound_09_chan_03-(sound_09+6)   ; $0026   ; $00055db4 + $0026 = $00055DDA

sound_10
L00055db6       dc.w    $0000   ; unused, reserved for music
L00055db8       dc.w    $0000   ; unused, reserved for music
L00055dba       dc.w    $0000   ; unused, reserved for music
L00055dbc       dc.w    sound_10_chan_03-(sound_10+6)   ; $0024   ; $00055dbc + $0024 = $00055DE0

sound_11
L00055dbe       dc.w    $0000   ; unused, reserved for music
L00055dc0       dc.w    $0000   ; unused, reserved for music
L00055dc2       dc.w    $0000   ; unused, reserved for music
L00055dc4       dc.w    sound_11_chan_03-(sound_11+6)   ; $0014   ; $00055dc4 + $0014 = $00055DD8

sound_12
L00055dc6       dc.w    $0000   ; unused, reserved for music
L00055dc8       dc.w    $0000   ; unused, reserved for music
L00055dca       dc.w    $0000   ; unused, reserved for music
L00055dcc       dc.w    sound_12_chan_03-(sound_12+6)   ; $000A   ; $00055dcc + $000A = $00055DD6

sound_13
L00055dce       dc.w    $0000   ; unused, reserved for music
L00055dd0       dc.w    $0000   ; unused, reserved for music
L00055dd2       dc.w    $0000   ; unused, reserved for music
L00055dd4       dc.w    sound_13_chan_03-(sound_13+6)   ; $000E   ; $00055dd4 + $000E = $00055DE2



sound_12_chan_03
L00055dd6       dc.b    $1F,$80

sound_11_chan_03
L00055dd8       dc.b    $20,$80

sound_09_chan_03
L00055dda       dc.b    $21,$80

sound_08_chan_03
L00055ddc       dc.b    $22,$80

sound_07_chan_03
L00055dde       dc.b    $23,$80

sound_10_chan_03
L00055de0       dc.b    $24,$80 

sound_13_chan_03
L00055DE2       dc.b    $25,$80


sfx_pattern_31
L00055DE4       dc.b    $8F,$09,$90,$06,$0C,$32,$80

sfx_pattern_32
L00055DEB       dc.b    $8F,$09,$90,$07,$81,$16,$FF         
L00055DF2       dc.b    $80

sfx_pattern_33
L00055DF3       dc.b    $8F,$09,$90,$08,$16,$32,$80

sfx_pattern_34
L00055DFA       dc.b    $8F,$09,$90,$09,$1C,$1E,$80

sfx_pattern_35
L00055E01       dc.b    $8F
L00055E02       dc.b    $09,$90,$0A,$18,$1E,$80

sfx_pattern_36
L00055E08       dc.b    $8F,$09,$90,$0B,$16,$1E,$80

sfx_pattern_37
L00055E0F       dc.b    $8F,$09,$90
L00055E12       dc.b    $0C,$07,$32,$80



;----------------------------- Sound Pattern Database --------------------------
; database of Sound Pattern data offsets.
; The Sound Pattern Sequences (e.g. sound_01_chan_00) contain indexes into this 
; table that identify the pattern/track to be played.
;
; The byte offests in this table are added to the table entry address to find
; the address of the pattern/track data.
;
; e.g. the first pattern $00
;       Address = $000584e6 + $0087 = $0005856d (labelled by 'pattern_00')
;
sound_pattern_data_base
L00055e16       dc.w    pattern_00-(sound_pattern_data_base+00)         ; $00FC ; $00055e16 + $00FC = $55F12 
;L00055e18       dc.w    modified_pattern_01-(sound_pattern_data_base+02)         ; $011B ; $00055e18 + $011B = $55F33 
L00055e18       dc.w    pattern_01-(sound_pattern_data_base+02)         ; $011B ; $00055e18 + $011B = $55F33 
L00055e1a       dc.w    pattern_02-(sound_pattern_data_base+04)         ; $0176 ; $00055e1a + $0176 = $55F90 
L00055e1c       dc.w    pattern_03-(sound_pattern_data_base+06)         ; $01D8 ; $00055e1c + $01D8 = $55FF4 
L00055e1e       dc.w    pattern_04-(sound_pattern_data_base+08)         ; $0209 ; $00055e1e + $0209 = $56027 
L00055E20       dc.w    pattern_05-(sound_pattern_data_base+10)         ; $0231 ; $00055E20 + $0231 = $56051     
L00055E22       dc.w    pattern_06-(sound_pattern_data_base+12)         ; $024E ; $00055E22 + $024E = $56070 
L00055E24       dc.w    pattern_07-(sound_pattern_data_base+14)         ; $025E ; $00055E24 + $025E = $56082 
L00055E26       dc.w    pattern_08-(sound_pattern_data_base+16)         ; $02BC ; $00055E26 + $02BC = $560E2 
L00055E28       dc.w    pattern_09-(sound_pattern_data_base+18)         ; $02F3 ; $00055E28 + $02F3 = $5611B 
L00055E2a       dc.w    pattern_10-(sound_pattern_data_base+20)         ; $032C ; $00055E2a + $032C = $56156 
L00055E2c       dc.w    pattern_11-(sound_pattern_data_base+22)         ; $0374 ; $00055E2c + $0374 = $561A0 
L00055E2e       dc.w    pattern_12-(sound_pattern_data_base+24)         ; $03BA ; $00055E2e + $03BA = $561E8 
L00055E30       dc.w    pattern_13-(sound_pattern_data_base+26)         ; $03C3 ; $00055E30 + $03C3 = $561F3 
L00055E32       dc.w    pattern_14-(sound_pattern_data_base+28)         ; $03E9 ; $00055E32 + $03E9 = $5621B 
L00055E34       dc.w    pattern_15-(sound_pattern_data_base+30)         ; $0406 ; $00055E34 + $0406 = $5623A 
L00055E36       dc.w    pattern_16-(sound_pattern_data_base+32)         ; $042B ; $00055E36 + $042B = $56261 
L00055E38       dc.w    pattern_17-(sound_pattern_data_base+34)         ; $0452 ; $00055E38 + $0452 = $5628A 
L00055E3a       dc.w    pattern_18-(sound_pattern_data_base+36)         ; $049E ; $00055E3a + $049E = $562D8 
L00055E3c       dc.w    pattern_19-(sound_pattern_data_base+38)         ; $049F ; $00055E3c + $049F = $562DB 
L00055E3e       dc.w    pattern_20-(sound_pattern_data_base+40)         ; $04B1 ; $00055E3e + $04B1 = $562EF 
L00055E40       dc.w    pattern_21-(sound_pattern_data_base+42)         ; $04DE ; $00055E40 + $04DE = $5631E 
L00055E42       dc.w    pattern_22-(sound_pattern_data_base+44)         ; $050B ; $00055E42 + $050B = $5634D
L00055E44       dc.w    pattern_23-(sound_pattern_data_base+46)         ; $052E ; $00055E44 + $052E = $56372 
L00055E46       dc.w    pattern_24-(sound_pattern_data_base+48)         ; $056F ; $00055E46 + $056F = $563B5 
L00055E48       dc.w    pattern_25-(sound_pattern_data_base+50)         ; $057B ; $00055E48 + $057B = $563C3 
L00055E4a       dc.w    pattern_26-(sound_pattern_data_base+52)         ; $0587 ; $00055E4a + $0587 = $563D1 
L00055E4c       dc.w    pattern_27-(sound_pattern_data_base+54)         ; $059D ; $00055E4c + $059D = $563E9 
L00055E4e       dc.w    pattern_28-(sound_pattern_data_base+56)         ; $05C9 ; $00055E4e + $05C9 = $56417 
L00055E50       dc.w    pattern_29-(sound_pattern_data_base+58)         ; $05F8 ; $00055E50 + $05F8 = $56448 
L00055E52       dc.w    pattern_30-(sound_pattern_data_base+60)         ; $060D ; $00055E52 + $060D = $5645F 
L00055E54       dc.w    sfx_pattern_31-(sound_pattern_data_base+62)         ; $FF90 ; $00055E54 + $FF90 (-70) = $55DE4
L00055E56       dc.w    sfx_pattern_32-(sound_pattern_data_base+64)         ; $FF95 ; $00055E56 + $FF95 (-6B) = $55DEB
L00055E58       dc.w    sfx_pattern_33-(sound_pattern_data_base+66)         ; $FF9B ; $00055E58 + $FF9B (-65) = $55DF3
L00055E5a       dc.w    sfx_pattern_34-(sound_pattern_data_base+68)         ; $FFA0 ; $00055E5a + $FFA0 (-60) = $55DFA
L00055E5c       dc.w    sfx_pattern_35-(sound_pattern_data_base+70)         ; $FFA5 ; $00055E5c + $FFA5 (-5B) = $55E01
L00055E5e       dc.w    sfx_pattern_36-(sound_pattern_data_base+72)         ; $FFAA ; $00055E5e + $FFAA (-56) = $55E08
L00055E60       dc.w    sfx_pattern_37-(sound_pattern_data_base+74)         ; $FFAF ; $00055E60 + $FFAF (-51 )= $55E0F


sound_01_chan_02
L00055E62       dc.b    $81,$03,$03,$03,$83,$08,$06,$07,$0C,$83,$03,$12,$07,$83,$02,$0F 
L00055E72       dc.b    $82,$F9,$0F,$82,$F9,$0F,$82,$00,$0F,$82,$F9,$0F,$82,$FE,$0F,$82 
L00055E82       dc.b    $02,$0F,$82,$FD,$0F,$82,$04,$0F,$10,$14,$80

sound_01_chan_01
L00055E8D       dc.b    $81,$00,$00,$00,$83 
L00055E92       dc.b    $04,$04,$82,$03,$04,$82,$03,$04,$04,$04,$04,$04,$0A,$04,$04,$0B 
L00055EA2       dc.b    $83,$04,$04,$04,$04,$0A,$04,$04,$0B,$83,$02,$04,$82,$03,$04,$04 
L00055EB2       dc.b    $83,$04,$0D,$04,$04,$0D,$0D,$82,$FE,$04,$82,$FE,$04,$82,$02,$04 
L00055EC2       dc.b    $82,$02,$04,$82,$FD,$04,$82,$FD,$04,$82,$04,$04,$82,$04,$04,$83 
L00055ED2       dc.b    $02,$04,$13,$80


sound_01_chan_00
L00055ED6       dc.b    $81,$01,$02,$11,$83,$08,$05,$05,$05,$08,$05,$05      
L00055EE2       dc.b    $09,$83,$04,$05,$05,$05,$08,$05,$05,$09,$83,$04,$05,$83,$04,$0E         ;................
L00055EF2       dc.b    $05,$05,$0E,$0E,$82,$FE,$05,$82,$FE,$05,$82,$02,$05,$82,$02,$05         ;................
L00055F02       dc.b    $82,$FD,$05,$82,$FD,$05,$82,$04,$05,$82,$04,$05,$83,$04,$05,$80

pattern_00
L00055F12       dc.b    $8F,$01,$90,$02,$8B,$18,$01,$03,$18,$60,$1D,$60,$1F,$60,$20,$30   
L00055F22       dc.b    $1F,$30,$1B,$60,$1A,$60,$23,$60,$1F,$54,$90,$04,$18,$06,$18,$06   
L00055F32       dc.b    $80

pattern_01
L00055F33       dc.b    $90,$01,$8F,$03,$8B,$10,$01,$03,$30,$0C,$30,$18,$30,$18,$30   
L00055F42       dc.b    $18,$30,$0C,$30,$0C,$30,$18,$30,$18,$30,$18,$30,$0C,$30,$0C,$2F   
L00055F52       dc.b    $18,$2F,$18,$2F,$18,$2F,$0C,$32,$0C,$33,$18,$33,$0C,$33,$0C,$32   
L00055F62       dc.b    $18,$32,$0C,$30,$0C,$30,$18,$30,$18,$30,$18,$30,$0C,$32,$0C,$32   
L00055F72       dc.b    $18,$32,$18,$32,$18,$32,$0C,$2F,$0C,$2F,$18,$2F,$18,$2F,$18,$2F   
L00055F82       dc.b    $0C,$2F,$0C,$2F,$18,$2F,$18,$2F,$18,$2F,$06,$2F,$06,$80

pattern_02
L00055F90       dc.b    $90,$01   
L00055F92       dc.b    $8F,$03,$30,$0C,$30,$18,$3C,$18,$30,$18,$30,$06,$30,$06,$30,$0C   
L00055FA2       dc.b    $30,$18,$3C,$18,$30,$18,$30,$06,$30,$06,$31,$0C,$32,$18,$3E,$18   
L00055FB2       dc.b    $32,$18,$32,$0C,$32,$0C,$33,$18,$33,$18,$33,$0C,$33,$0C,$32,$0C   
L00055FC2       dc.b    $30,$0C,$30,$18,$3C,$18,$30,$18,$30,$06,$30,$06,$32,$0C,$32,$18   
L00055FD2       dc.b    $3E,$18,$32,$18,$32,$06,$32,$06,$2F,$0C,$2F,$18,$3B,$18,$2F,$18   
L00055FE2       dc.b    $2F,$06,$2F,$06,$2B,$0C,$2B,$18,$2B,$18,$8E,$8B,$0C,$02,$02,$24   
L00055FF2       dc.b    $24,$80

pattern_03
L00055FF4       dc.b    $90,$03,$8F,$04,$8D,$04,$30,$48,$30,$18,$8D,$0B,$30,$48   
L00056002       dc.b    $30,$18,$8D,$09,$32,$48,$32,$18,$33,$48,$33,$18,$8D,$0D,$33,$48   
L00056012       dc.b    $33,$18,$8D,$0A,$32,$48,$32,$18,$8D,$09,$32,$30,$8D,$0C,$33,$30   
L00056022       dc.b    $8D,$09,$32,$60,$80

pattern_04
L00056027       dc.b    $90,$02,$8F,$02,$8E,$8B,$06,$01,$03,$18,$06   
L00056032       dc.b    $18,$06,$24,$06,$18,$06,$90,$04,$18,$0C,$90,$02,$16,$0C,$18,$0C   
L00056042       dc.b    $24,$06,$18,$06,$90,$04,$18,$0C,$90,$02,$18,$06,$24,$06,$80

pattern_05
L00056051       dc.b    $90   
L00056052       dc.b    $03,$8F,$05,$8D,$04,$84,$06,$30,$30,$30,$30,$85,$30,$0C,$84,$06   
L00056062       dc.b    $30,$30,$30,$30,$30,$30,$85,$30,$0C,$30,$06,$30,$06,$80

pattern_06
L00056070       dc.b    $90,$05   
L00056072       dc.b    $8F,$00,$8E,$8C,$87,$0C,$84,$12,$3C,$3E,$41,$3E,$85,$3C,$0C,$80   

pattern_07
L00056082       dc.b    $90,$01,$8F,$01,$8B,$14,$01,$02,$84,$0C,$30,$2B,$30,$33,$30,$33   
L00056092       dc.b    $37,$33,$3A,$37,$3A,$85,$3A,$18,$3C,$24,$90,$05,$84,$0C,$2B,$30   
L000560A2       dc.b    $32,$33,$85,$35,$12,$37,$12,$38,$0C,$37,$60,$8E,$90,$01,$84,$0C   
L000560B2       dc.b    $24,$1F,$24,$27,$24,$27,$2B,$27,$2E,$2B,$2E,$85,$2E,$18,$30,$0C   
L000560C2       dc.b    $32,$0C,$33,$24,$32,$0C,$30,$30,$90,$05,$26,$0C,$84,$06,$29,$2C   
L000560D2       dc.b    $30,$35,$35,$38,$3C,$41,$2B,$2F,$32,$37,$37,$3B,$3E,$43,$85,$80

pattern_08
L000560E2       dc.b    $90,$03,$8F,$05,$8D,$04,$84,$06,$30,$30,$30,$30,$85,$30,$0C,$84   
L000560F2       dc.b    $06,$30,$30,$35,$35,$35,$35,$85,$35,$0C,$35,$06,$35,$06,$8D,$0A   
L00056102       dc.b    $84,$06,$37,$37,$37,$37,$85,$37,$0C,$84,$06,$37,$37,$37,$37,$37   
L00056112       dc.b    $37,$85,$37,$0C,$37,$06,$37,$06,$80

pattern_09
L0005611B       dc.b    $90,$03,$8F,$05,$8D,$0C,$84   
L00056122       dc.b    $06,$30,$30,$30,$30,$85,$30,$0C,$84,$06,$30,$30,$30,$30,$30,$30   
L00056132       dc.b    $85,$30,$0C,$30,$06,$30,$06,$8D,$04,$84,$06,$35,$35,$35,$35,$85   
L00056142       dc.b    $35,$0C,$84,$06,$35,$35,$8D,$0A,$37,$37,$37,$37,$85,$37,$0C,$37   
L00056152       dc.b    $06,$37,$06,$80

pattern_10
L00056156       dc.b    $8E,$8B,$06,$01,$03,$90,$02,$8F,$02,$18,$06,$18   
L00056162       dc.b    $06,$18,$06,$18,$06,$90,$04,$18,$0C,$90,$02,$16,$0C,$18,$0C,$1D   
L00056172       dc.b    $0C,$90,$04,$18,$0C,$90,$02,$1D,$06,$1D,$06,$1F,$06,$1F,$06,$1F   
L00056182       dc.b    $06,$1F,$06,$90,$04,$18,$0C,$90,$02,$1F,$0C,$1F,$0C,$1F,$0C,$90   
L00056192       dc.b    $04,$18,$06,$90,$02,$13,$06,$1D,$06,$90,$04,$18,$06,$80

pattern_11
L000561A0       dc.b    $8E,$8B   
L000561A2       dc.b    $06,$01,$03,$90,$02,$8F,$02,$20,$06,$20,$06,$20,$06,$20,$06,$90   
L000561B2       dc.b    $04,$18,$0C,$90,$02,$1E,$0C,$20,$0C,$20,$06,$20,$06,$90,$04,$18   
L000561C2       dc.b    $06,$18,$0C,$18,$06,$90,$02,$1D,$06,$1D,$06,$1D,$06,$1D,$06,$90   
L000561D2       dc.b    $04,$18,$0C,$90,$02,$1B,$0C,$1D,$0C,$1F,$06,$1F,$06,$90,$04,$18   
L000561E2       dc.b    $0C,$18,$06,$18,$06,$80

pattern_12
L000561E8       dc.b    $90,$05,$8F,$01,$8B,$30,$01,$04,$30,$60   
L000561F2       dc.b    $80

pattern_13
L000561F3       dc.b    $8E,$8B,$0C,$01,$03,$90,$02,$8F,$02,$1D,$06,$1D,$06,$1D,$06   
L00056202       dc.b    $1D,$06,$90,$04,$18,$0C,$90,$02,$16,$0C,$1D,$0C,$1D,$06,$1D,$06   
L00056212       dc.b    $90,$04,$18,$0C,$90,$02,$1D,$0C,$80

pattern_14
L0005621B       dc.b    $90,$03,$8F,$05,$8D,$04,$84   
L00056222       dc.b    $06,$35,$35,$35,$35,$85,$35,$0C,$84,$06,$35,$35,$35,$35,$35,$35   
L00056232       dc.b    $85,$35,$0C,$35,$06,$35,$06,$80

pattern_15
L0005623A       dc.b    $8E,$90,$05,$8F,$00,$8C,$84,$0C   
L00056242       dc.b    $33,$30,$33,$37,$33,$85,$37,$06,$33,$0C,$33,$06,$30,$0C,$84,$0C   
L00056252       dc.b    $3F,$3C,$3F,$43,$3F,$85,$43,$06,$3F,$0C,$3F,$06,$3C,$0C,$80

pattern_16
L00056261       dc.b    $8E   
L00056262       dc.b    $90,$05,$8F,$00,$84,$06,$33,$3C,$3C,$27,$48,$27,$33,$3C,$30,$33   
L00056272       dc.b    $3C,$33,$48,$3F,$30,$3C,$33,$30,$3C,$33,$48,$27,$33,$3C,$30,$33   
L00056282       dc.b    $3C,$33,$48,$3F,$30,$3C,$85,$80

pattern_17
L0005628A       dc.b    $8E,$90,$01,$8F,$01,$8B,$14,$02   
L00056292       dc.b    $02,$84,$0C,$24,$2B,$30,$2B,$33,$30,$33,$37,$85,$88,$FF,$0C,$3C   
L000562A2       dc.b    $48,$3E,$0C,$3F,$0C,$3F,$18,$3E,$0C,$3E,$30,$3C,$06,$3E,$06,$3C   
L000562B2       dc.b    $0C,$38,$0C,$88,$FF,$0C,$35,$0C,$33,$48,$84,$0C,$32,$33,$32,$33   
L000562C2       dc.b    $32,$33,$30,$2D,$32,$36,$85,$39,$24,$37,$0C,$36,$0C,$3B,$30,$36   
L000562D2       dc.b    $0C,$33,$18,$37,$6C,$80

pattern_18
L000562D8       dc.b    $87,$60,$80

pattern_19
L000562DB       dc.b    $90,$02,$8F,$01,$8B,$18,$01   
L000562E2       dc.b    $03,$1B,$30,$1A,$30,$18,$3C,$88,$FE,$1E,$18,$24,$80

pattern_20
L000562EF       dc.b    $8E,$90,$05   
L000562F2       dc.b    $8F,$03,$84,$06,$33,$3C,$3C,$48,$48,$27,$33,$3C,$48,$33,$3C,$33   
L00056302       dc.b    $37,$3F,$30,$3C,$33,$30,$3C,$48,$48,$27,$33,$3C,$48,$3C,$43,$48   
L00056312       dc.b    $30,$37,$3C,$48,$85,$80

sound_02_chan_00
L00056318       dc.b    $16,$80

sound_02_chan_01
L0005631A       dc.b    $15,$80

sound_02_chan_02
L0005631C       dc.b    $17,$80

pattern_21
L0005631E       dc.b    $90,$02,$8F,$01 
L00056322       dc.b    $18,$06,$24,$06,$18,$06,$18,$0C,$18,$06,$16,$06,$18,$06,$29,$06 
L00056332       dc.b    $29,$06,$1D,$06,$29,$12,$1D,$0C,$18,$06,$24,$06,$18,$06,$1D,$0C 
L00056342       dc.b    $1D,$0C,$1D,$06,$24,$0C,$1F,$0C,$18,$0C,$80

pattern_22
L0005634D       dc.b    $90,$01,$8B,$14,$01 
L00056352       dc.b    $03,$8F,$01,$87,$0C,$30,$0C,$33,$0C,$37,$0C,$38,$12,$37,$12,$35 
L00056362       dc.b    $12,$87,$06,$30,$0C,$35,$06,$38,$06,$3A,$0C,$3B,$03,$3C,$24,$80 

pattern_23
L00056372       dc.b    $90,$03,$8F,$00,$8D,$04,$30,$0C,$30,$06,$30,$0C,$30,$06,$30,$06 
L00056382       dc.b    $30,$06,$8D,$0B,$30,$0C,$30,$06,$30,$0C,$30,$06,$30,$06,$30,$06 
L00056392       dc.b    $8D,$04,$30,$0C,$30,$06,$8D,$0B,$30,$0C,$30,$06,$30,$06,$30,$06 

L000563A2       dc.b    $8D,$0A,$30,$0C,$8D,$0C,$2F,$0C,$8D,$0A,$30,$0C,$80

sound_03_chan_00
L000563AF       dc.b    $18,$80

sound_03_chan_01
L000563B1       dc.b    $1A,$80

sound_03_chan_02
L000563B3       dc.b    $19,$80

pattern_24
L000563B5       dc.b    $90,$02,$8F,$01,$84,$06,$1F,$1F,$1D,$1F,$85,$87,$18
L000563C2       dc.b    $80

pattern_25
L000563C3       dc.b    $90,$05,$8F,$01,$84,$06,$46,$45,$44,$43,$85,$87,$18,$80

pattern_26
L000563D1       dc.b    $90
L000563D2       dc.b    $04,$8F,$02,$84,$06,$18,$18,$18,$18,$80

sound_04_chan_01
L000563DC       dc.b    $1B,$80

sound_04_chan_00
L000563DE       dc.b    $1C,$80

sound_04_chan_02
L000563E0       dc.b    $1D,$82
L000563E2       dc.b    $FE,$1D,$82,$01,$1D,$1E,$80


pattern_27
L000563E9       dc.b    $90,$05,$8F,$01,$84,$06,$46,$45,$3E  
L000563F2       dc.b    $3F,$46,$45,$46,$45,$3E,$3F,$46,$45,$44,$43,$3C,$3D,$44,$43,$44  
L00056402       dc.b    $43,$3C,$3D,$44,$43,$40,$3F,$37,$38,$40,$3F,$40,$3F,$37,$38,$40  
L00056412       dc.b    $3F,$85,$3C,$18,$80

pattern_28
L00056417       dc.b    $90,$03,$8F,$00,$8D,$0B,$32,$0C,$32,$0C,$32  
L00056422       dc.b    $0C,$32,$06,$32,$0C,$32,$12,$30,$0C,$30,$0C,$30,$0C,$30,$06,$30  
L00056432       dc.b    $0C,$30,$12,$8D,$0C,$30,$0C,$30,$0C,$30,$0C,$30,$06,$30,$0C,$30  
L00056442       dc.b    $12,$8D,$14,$30,$18,$80

pattern_29
L00056448       dc.b    $90,$02,$8F,$01,$1F,$06,$1F,$06,$1F,$06  
L00056452       dc.b    $1F,$06,$1F,$0C,$1F,$0C,$1F,$06,$1F,$06,$1F,$0C,$80

pattern_30
L0005645F       dc.b    $90,$02,$8F  
L00056462       dc.b    $01,$18,$18,$80



;; END OF FILE
L00056466       dc.b    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  
L00056472       dc.w    $0000,$0000,$0000,$0031,$1C80,$0000,$000A,$8028         ;.......1.......(
L00056482       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000         ;................
L00056492       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0022         ;..............."
L000564A2       dc.w    $2080,$0000,$000B,$8028,$0000,$0000,$0000,$0000         ; ......(........
L000564B2       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000         ;................
L000564C2       dc.w    $0000,$0000,$0000,$0062,$5E80,$0000,$0015,$4014         ;.......b^.....@.
L000564D2       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000         ;................
L000564E2       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0069         ;...............i
L000564F2       dc.w    $8140,$3FFF,$F850,$4014,$0000,$0000,$0000,$0000         ;.@?..P@.........
L00056502       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000         ;................
L00056512       dc.w    $0000,$0000,$0000,$004C,$3CC7,$EFFE,$AFB1,$8014         ;.......L<.......
L00056522       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000         ;................
L00056532       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$004E         ;...............N
L00056542       dc.w    $7F1D,$15FF,$6AE0,$8014,$0000,$0000,$0000,$0000         ;....j...........
L00056552       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000         ;................
L00056562       dc.w    $0000,$0000,$0000,$0048,$7F8A,$83FF,$8552,$800A         ;.......H.....R..
L00056572       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000         ;................
L00056582       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$00CC         ;................
L00056592       dc.w    $363F,$45FF,$42B5,$000A,$0000,$0000,$0000,$0000         ;6?E.B...........
L000565A2       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000         ;................
L000565B2       dc.w    $0000,$0000,$0000,$00E7,$44FF,$A2FF,$A174,$000A         ;........D....t..
L000565C2       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000         ;................
L000565D2       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$00D0         ;................
L000565E2       dc.w    $4DFF,$C17F,$42B4,$000A,$0000,$0000,$0000,$0000         ;M...B...........
L000565F2       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000         ;................
L00056602       dc.w    $0000,$0000,$0000,$00EA,$8BE1,$A0BE,$A17A,$0005         ;.............z..
L00056612       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000         ;................
L00056622       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$00D2         ;................
L00056632       dc.w    $8B80,$5055,$42BA,$0005,$0000,$0000,$0000,$0000         ;..PUB...........
L00056642       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000         ;................
L00056652       dc.w    $0000,$0000,$0000,$00E4,$0A15,$2A0A,$07FA,$0005         ;..........*.....
L00056662       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000         ;................
L00056672       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$00F3         ;................
L00056682       dc.w    $CAAE,$9F00,$0E1A,$0005,$0000,$0000,$0000,$0000         ;................
L00056692       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000         ;................
L000566A2       dc.w    $0000,$0000,$0000,$00E4,$697F,$4681,$580E,$0002         ;........i.F.X...
L000566B2       dc.w    $8000,$0000,$0000,$0000,$0000,$0000,$0000,$0000         ;................
L000566C2       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$00FA         ;................
L000566D2       dc.w    $90D5,$E1EB,$F01E,$0002,$8000,$0000,$0000,$0000         ;................
L000566E2       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000         ;................
L000566F2       dc.w    $0000,$0000,$0000,$00ED,$55AA,$D03F,$000E,$0002         ;........U..?....
L00056702       dc.w    $8000,$0000,$0000,$0000,$0000,$0000,$0000,$0000         ;................
L00056712       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$01E7         ;................
L00056722       dc.w    $82C1,$7000,$0012,$0001,$0000,$0000,$0000,$0000         ;..p.............
L00056732       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000         ;................
L00056742       dc.w    $0000,$0000,$0000,$01ED,$41AA,$AA02,$A80A,$0001         ;........A.......
L00056752       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000         ;................
L00056762       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$01EB         ;................
L00056772       dc.w    $835D,$F557,$F416,$0001,$8000,$0000,$0000,$0000         ;.].W............
L00056782       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000         ;................
L00056792       dc.w    $0000,$0000,$0000,$01DD,$87FF,$FFBF,$FA0B,$0000         ;................






