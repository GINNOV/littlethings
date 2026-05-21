                ; Load Address: $3ffc
                ; Length bytes: $18005 (98309)
                ; End Address:  $1c001
                ; Code Entry:   $d000
                ;
                section panel,code_c


                ;--------------------- includes and constants ---------------------------
                INCDIR      "include"
                INCLUDE     "hw.i"


TEST_BUILD_LEVEL        EQU     1




; Batcave - Constants
;----------------------
            IFD TEST_BUILD_LEVEL
BATCAVE_DISPLAY_BUFFER1     EQU display_buffer1
BATCAVE_DISPLAY_BUFFER2     EQU display_buffer2
BATCAVE_TIMER               EQU $1000                                   ; 10 minutes test timer
            ELSE
BATCAVE_DISPLAY_BUFFER1     EQU $0005ED00
BATCAVE_DISPLAY_BUFFER2     EQU $00067680
BATCAVE_TIMER               EQU $0059                                   ; 59 seconds timer
            ENDC
BATCAVE_DISPLAY_BUFFER_SIZE EQU $8980                                   ; 35200 bytes
BATCAVE_BPLWIDTH            EQU $2c                                     ; (44 bytes)
BATCAVE_BPLHEIGHT           EQU $98                                     ; (152 rasters high)
BATCAVE_BPL_SIZE            EQU BATCAVE_BPLWIDTH*BATCAVE_BPLHEIGHT      ; $1a20 (6688 bytes)





            IFD TEST_BUILD_LEVEL 
start
                jmp code_entry_point                ; original address $0000d000 

            ELSE
                org $3ffc

                dc.l    $00004000
            ENDC    


; music do-nothing stubs
;L00004000           rts
;L00004004           rts          
;L00004008           rts
;L00004010           rts          
;L00004014           rts
;L00004018           rts

L00004000           bra.w   do_initialise_music_player          ; L00004180
L00004004           bra.w   do_silence_all_audio                ; L00004194
L00004008           bra.w   do_init_sfx_channels                ; L000041e0
L0000400c           bra.w   do_init_sfx_channels                ; L000041e0
L00004010           bra.w   do_init_song                        ; L0000423e
L00004014           bra.w   do_play_sfx                         ; L00004222
L00004018           bra.w   do_play_sounds                      ; L000042f6

master_audio_volume_mask_1  ;original address L0000401C
L0000401c           dc.w    $FFFF
master_audio_volume_mask_2  ;original address L0000401E
L0000401e           dc.w    $FFFF
song_ctrl_bits      ;original address L00004020
L00004020           dc.w    $0000

song_no_1           ;original addfress L00004022
L00004022           dc.b    $00
song_no_2
sfx_no              ; original address L00004023          
L00004023           dc.b    $00

channel_00_status   ;original address L00004024
L00004024           dc.w    $0000
                    dc.l    $00000000
                    dc.l    $0000CAF6
                    dc.l    $00000000
                    dc.l    $0000CB4A
                    dc.b    $01
                    dc.b    $00
                    dc.l    $0000C6A4
L0000403C           dc.l    $0000C6A8
                    dc.w    $0101
                    dc.w    $0013
                    dc.b    $FF
                    dc.b    $00
                    dc.b    $00
                    dc.b    $00
                    dc.b    $00
                    dc.b    $00
                    dc.b    $00
                    dc.b    $00
L0000404C           dc.l    $00000000
                    dc.l    $00000000
                    dc.b    $00
                    dc.b    $00
                    dc.b    $00
                    dc.b    $00
                    dc.b    $01
                    dc.b    $03
                    dc.b    $0C
                    dc.b    $0A
L0000405C           dc.b    $06
                    dc.b    $03
                    dc.w    $FFFC
                    dc.w    $0030
                    dc.l    $00004DEE
                    dc.w    $0ED0
                    dc.l    $00004D32
L0000406C           dc.w    $0001
                    dc.w    $0001
                    dc.w    $0000
                    dc.b    $00
                    dc.b    $3C
                    dc.b    $3C
                    dc.b    $00
                    dc.w    $0000
                    dc.w    $0001

channel_01_status   ;original address L0000407A                 
L0000407a           dc.w    $0000
L0000407C           dc.l    $00000000
                    dc.l    $0000CAF8
                    dc.l    $00000000
                    dc.l    $0000CB2A
L0000408C           dc.b    $01
                    dc.b    $00
                    dc.l    $0000C6A4
                    dc.l    $0000C6A8
                    dc.w    $0101
                    dc.w    $001F
                    dc.b    $FF
                    dc.b    $00
L0000409C           dc.b    $00
                    dc.b    $00
                    dc.b    $00
                    dc.b    $00
                    dc.b    $00
                    dc.b    $00
                    dc.l    $0000C623
                    dc.l    $0000C625
                    dc.b    $03
                    dc.b    $01
L000040AC           dc.b    $01
                    dc.b    $01
                    dc.b    $00
                    dc.b    $00
                    dc.b    $00
                    dc.b    $00
                    dc.b    $00
                    dc.b    $00
                    dc.w    $0000
                    dc.w    $001F
                    dc.l    $0000951A
L000040BC           dc.w    $08E4
                    dc.l    $0000A0C2
                    dc.w    $0310
                    dc.w    $0001
                    dc.w    $0000
                    dc.b    $00
                    dc.b    $24
                    dc.b    $24
                    dc.b    $00
L000040CC           dc.w    $0000
                    dc.w    $0002

channel_02_status   ;original address L000040D0                    
L000040d0           dc.w    $0000
                    dc.l    $00000000
                    dc.l    $0000CAFA
                    dc.l    $00000000
                    dc.l    $0000CB88
                    dc.b    $01
                    dc.b    $00
                    dc.l    $0000C6A4
                    dc.l    $0000C6A8
L000040EC           dc.w    $0101
                    dc.w    $001F
                    dc.b    $FF
                    dc.b    $00
                    dc.b    $00
                    dc.b    $00
                    dc.b    $00
                    dc.b    $00
                    dc.b    $00
                    dc.b    $00
                    dc.l    $0000C63C
L000040FC           dc.l    $0000C63C
                    dc.b    $03
                    dc.b    $03
                    dc.b    $01
                    dc.b    $01
                    dc.b    $00
                    dc.b    $00
                    dc.b    $00
                    dc.b    $00
                    dc.b    $00
                    dc.b    $00
                    dc.w    $0000
L0000410C           dc.w    $002D
                    dc.l    $0000A74A
                    dc.w    $09B3
                    dc.l    $0000B4F2
                    dc.w    $02DF
                    dc.w    $0001
L0000411C           dc.w    $0000
                    dc.b    $00
                    dc.b    $30
                    dc.b    $30
                    dc.b    $06
                    dc.w    $0000
                    dc.w    $0004

channel_03_status   ; original address L00004126              
L00004126           dc.w    $0000
                    dc.l    $00000000
L0000412C           dc.l    $0000C70F
                    dc.l    $00000000
                    dc.l    $0000C718
                    dc.b    $01
                    dc.b    $00
                    dc.l    $0000C6D9
                    dc.l    $0000C6DB
                    dc.w    $0101
                    dc.w    $0000
                    dc.b    $3E
                    dc.b    $00
                    dc.b    $00
                    dc.b    $00
                    dc.b    $00
                    dc.b    $00
L0000414C           dc.b    $00
                    dc.b    $00
                    dc.l    $00000000
                    dc.l    $00000000
                    dc.b    $00
                    dc.b    $00
                    dc.b    $00
                    dc.b    $00
                    dc.b    $00
                    dc.b    $00
L0000415C           dc.b    $00
                    dc.b    $00
                    dc.b    $00
                    dc.b    $00
                    dc.w    $0000
                    dc.w    $0018
                    dc.l    $0000BB18
                    dc.w    $02DB
                    dc.l    $00004D32
                    dc.w    $0001
                    dc.w    $0001
                    dc.w    $0000
                    dc.b    $00
                    dc.b    $18
                    dc.b    $18
                    dc.b    $00
                    dc.w    $0000
                    dc.w    $0008

audio_dma       ; original address L0000417C                
L0000417c           dc.w    $0000

play_counter    ; original address L0000417E
L0000417e           dc.w    $00B5 



                        ; --------------- Initialise Music Player ----------------
                        ; No Parameters Required
do_initialise_music_player  ; original address L00004180
L00004180           lea.l   raw_sample_data_table,a0    ; L00004d4a,a0
L00004186           lea.l   instrument_data,a1          ; L00004bf2,a1
L0000418c           bsr.w   init_instruments            ; L000049c4
L00004190           bra.w   do_silence_all_audio        ; L00004194 



                        ;---------------------------- do silence all audio ----------------------------------
                        ; initialises all audio channels and sets song/sfx numbers to $00
                        ;
do_silence_all_audio    ; original address L00004194
L00004194           movem.l d0/a0-a1,-(a7)
L00004198           move.b  #$00,song_no_1                  ; L00004022
L0000419e           move.b  #$00,sfx_no                     ; L00004023
L000041a4           lea.l   channel_00_status,a0            ; L00004024,a0
L000041a8           lea.l   $00dff0a8,a1
L000041ae           bsr.b   init_audio_channel              ; L000041c2
L000041b0           bsr.b   init_audio_channel              ; L000041c2
L000041b2           bsr.b   init_audio_channel              ; L000041c2
L000041b4           bsr.b   init_audio_channel              ; L000041c2
L000041b6           move.w  #$0000,song_ctrl_bits           ; L00004020
L000041bc           movem.l (a7)+,d0/a0-a1
L000041c0           rts  



                        ;------------ silence channel volume -------------
                        ; Set Audio Channel Volume to Zero, also init other channel structure values
                        ; IN: A0 - channel/voice status data
                        ; IN: A1 - AUDxVOL custom register
                        ;
init_audio_channel  ; original address L000041c2
L000041c2           move.w  #$0000,(a0)
L000041c6           move.w  #$0001,$004a(a0)
L000041cc           move.w  #$0000,$004c(a0)
L000041d2           move.w  #$0000,(a1)
L000041d6           adda.w  #$0056,a0
L000041da           adda.w  #$0010,a1
L000041de           rts



                        ;----------------------------- do_init_sfx_channels -----------------------------
                        ; Reset active channels for specified sound. 
                        ; Maybe used to silence channels before playing sfx over existing sound.
                        ;
                        ; If song number (d0) is not in range 0-13 then silence audio and exit.
                        ; If song number (d0) is in range 0-13 then re-initialise the active channels only.
                        ;
                        ; IN: D0.w      - Song Number/SFX Number?
                        ;
do_init_sfx_channels    ; original address L000041e0
L000041e0           movem.l d0/d7/a0-a2,-(a7)
L000041e4           subq.w  #$01,d0
L000041e6           bmi.b   L000041ee
L000041e8           cmp.w   #$0006,d0
L000041ec           bcs.b   L000041f2
L000041ee           bsr.b   do_silence_all_audio        ; L00004194
L000041f0           bra.b   L0000421c

L000041f2           lea.l   sounds_table,a2             ; L0000c6de,a2
L000041f8           asl.w   #$03,d0
L000041fa           adda.w  d0,a2
L000041fc           lea.l   channel_00_status,a0        ; L00004024,a0
L00004200           lea.l   $00dff0a8,a1

L00004206           moveq   #$03,d7
L00004208           tst.w   (a2)+
L0000420a           bne.b   L00004216 
L0000420c           adda.w  #$0056,a0
L00004210           adda.w  #$0010,a1
L00004214           bra.b   L00004218

L00004216           bsr.b   init_audio_channel          ; L000041c2
L00004218           dbf.w   d7,L00004208

L0000421c           movem.l (a7)+,d0/d7/a0-a2
L00004220           rts



                        ;--------------------------- do play sfx ------------------------
                        ; I think this is used to play a SFX sound on the 4th channel. 
                        ; Test is channel is active, 
                        ; IN:  D0.w - song number?
                        ;
do_play_sfx   
L00004222           tst.w   channel_03_status       ;L00004126 
L00004226           beq.b   L0000422e
L00004228           cmp.b   sfx_no,d0               ; L00004023,d0
L0000422c           bcs.b   L0000423c

L0000422e           movem.l d0/d7/a0-a2,-(a7)
L00004232           move.w  #$4000,d1
L00004236           move.b  d0,sfx_no               ; L0004023 
L0000423a           bra.b   init_sound              ; L0000424a
L0000423c           rts  



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
do_init_song    ; original address L0000423e
L0000423e           movem.l d0/d7/a0-a2,-(a7)
L00004242           move.w  #$8000,d1
L00004246           move.b  d0,song_no_1            ;L00004022

init_sound      ; original address L0000424a
L0000424a           clr.w   play_counter            ;L0000417e

L0000424e           subq.w  #$01,d0
L00004250           bmi.b   L00004258
L00004252           cmp.w   #$0006,d0
L00004256           bcs.b   L00004260

L00004258           bsr.w   do_silence_all_audio    ;L00004194
L0000425c           bra.w   L000042f0

L00004260           lea.l   sounds_table,a0         ; $0000c6de,a0
L00004266           asl.w   #$03,d0
L00004268           adda.w  d0,a0
L0000426a           lea.l   channel_00_status,a1    ; L00004024,a1
L0000426e           moveq   #$03,d7

L00004270           move.w  (a0)+,d0
L00004272           beq.b   L000042e4 

L00004274           lea.l   -2(a0,d0.w),a2
L00004278           moveq   #$00,d0
L0000427a           move.w  d0,$004c(a1)
L0000427e           move.l  d0,$0002(a1)
L00004282           move.l  d0,$000a(a1)
L00004286           move.b  d0,$0013(a1)
L0000428a           move.b  #$01,$0012(a1)
L00004290           move.w  d1,(a1)

L00004292           move.b  (a2)+,d0
L00004294           bpl.b   L000042c8

L00004296           sub.b   #$80,d0
L0000429a           bne.b   L000042aa

L0000429c           movea.l $0002(a1),a2
L000042a0           cmpa.w  #$0000,a2
L000042a4           bne.b   L00004292
L000042a6           clr.w   (a1)
L000042a8           bra.b   L000042e4 

L000042aa           subq.b  #$01,d0
L000042ac           bne.b   L000042b4

L000042ae           move.l  a2,$0002(a1)
L000042b2           bra.b   L00004292

L000042b4           subq.b  #$01,d0
L000042b6           bne.b   L000042be

L000042b8           move.b  (a2)+,$0013(a1)
L000042bc           bra.b   L00004292

L000042be           subq.b  #$01,d0
L000042c0           bne.b   L00004292

L000042c2           move.b  (a2)+,$0012(a1)
L000042c6           bra.b   L00004292

L000042c8           move.l  a2,$0006(a1)
L000042cc           lea.l   sound_pattern_data_base,a2      ; L0000c720,a2
L000042d2           ext.w   d0
L000042d4           add.w   d0,d0
L000042d6           adda.w  d0,a2
L000042d8           adda.w  (a2),a2
L000042da           move.l  a2,$000e(a1)
L000042de           move.w  #$0001,$0052(a1)

L000042e4           lea.l   $0056(a1),a1
L000042e8           dbf.w   d7,L00004270
L000042ec           or.w    d1,song_ctrl_bits           ; L00004020

L000042f0           movem.l (a7)+,d0/d7/a0-a2
L000042f4           rts 



                ;--------------------------- do play sounds -----------------------
                ; Call this routine at regular intervals to play the current
                ; song/sfx combination. (e.g. during vbl)
                ; The game calls this at 25 frames per second to play current 
                ; songs/sfx
                ;
                ; IN:- no parameters
                ;
do_play_sounds   
L000042f6               lea.l   $00dff000,a6
L000042fc               lea.l   note_period_table+48,a5     ; L00004bb2,a5
L00004302               clr.w   audio_dma                   ; L0000417c
L00004306               tst.w   song_ctrl_bits              ; L00004020
L0000430a               beq.b   L00004354

L0000430c               addq.w  #$01,play_counter           ; L0000417e
L00004310               clr.w   song_ctrl_bits              ; L00004020

L00004314               lea.l   channel_00_status,a4        ; L00004024,a4
L00004318               move.w  (a4),d7
L0000431a               beq.b   L00004324
L0000431c               bsr.b   channel_command_loop        ; L00004360
L0000431e               move.w  d7,(a4)
L00004320               or.w    d7,song_ctrl_bits           ; L00004020

L00004324               lea.l   channel_01_status,a4        ; L0000407a,a4
L00004328               move.w  (a4),d7
L0000432a               beq.b   L00004334
L0000432c               bsr.b   channel_command_loop        ; L00004360
L0000432e               move.w  d7,(a4)
L00004330               or.w    d7,song_ctrl_bits           ; L00004020

L00004334               lea.l   channel_02_status,a4        ; L000040d0,a4
L00004338               move.w  (a4),d7
L0000433a               beq.b   L00004344
L0000433c               bsr.b   channel_command_loop        ; L00004360
L0000433e               move.w  d7,(a4)
L00004340               or.w    d7,song_ctrl_bits           ; L00004020

L00004344               lea.l   channel_03_status,a4        ; L00004126,a4
L00004348               move.w  (a4),d7
L0000434a               beq.b   L00004354
L0000434c               bsr.b   channel_command_loop        ; L00004360
L0000434e               move.w  d7,(a4)
L00004350               or.w    d7,song_ctrl_bits           ; L00004020

L00004354               and.w   #$c000,song_ctrl_bits       ; L00004020
L0000435a               bsr.w   update_audio_custom_registers ; L0000484a
L0000435e               rts  




                ; ------------------ channel command loop --------------------------
                ; Process channel audio commands for the current channel/sound/sfx
                ;
                ; IN:  a4 = channel status base address
                ; IN:  d7 = channel status CTRL word
                ; OUT: d7 = channel status CTRL word
                ;
channel_command_loop   
L00004360               subq.w  #$01,$0052(a4)
L00004364               bne.w   L000046aa

L00004368               movea.l $000e(a4),a3
L0000436c               bclr.l  #$0007,d7

channel_cmd_loop    ; original address L00004370
L00004370               move.b  (a3)+,d0
L00004372               bpl.w   L00004558
L00004376               bclr.l  #$0003,d7

L0000437a               cmp.b   #$a0,d0
L0000437e               bcc.b   L00004370

L00004380               lea.l   cmd_jump_table(pc),a0       ; L00004396(pc),a0
L00004384               sub.b   #$80,d0
L00004388               ext.w   d0
L0000438a               add.w   d0,d0
L0000438c               adda.w  d0,a0
L0000438e               move.w  (a0),d0
L00004390               beq.b   L00004370
L00004392               jmp     $00(a0,d0.w)
                        ; some commands exit (rts)
                        ; others, jmp back to 'cmd_loop'


cmd_jump_table  ; original address L00004396
L00004396   dc.w    music_command_01-(cmd_jump_table+00)    ; L00004396 + $0040 = $000043d6 - CMD 01 - music_command_01
            dc.w    music_command_02-(cmd_jump_table+02)    ; L00004398 + $00BA = $00004452 - CMD 02 - music_command_02
            dc.w    music_command_03-(cmd_jump_table+04)    ; L0000439a + $00C0 = $0000445a - CMD 03 = music_command_03
            dc.w    music_command_04-(cmd_jump_table+06)    ; L0000439c + $00C2 = $0000445e - CMD 04 - music_command_04
            dc.w    music_command_05-(cmd_jump_table+08)    ; L0000439e + $00C4 = $00004462 - CMD 05 - music_command_05
            dc.w    music_command_06-(cmd_jump_table+10)    ; L000043a0 + $00CE = $0000446e - CMD 06 - music_command_06
            dc.w    music_command_07-(cmd_jump_table+12)    ; L000043a2 + $00D4 = $00004476 - CMD 07 - music_command_07
            dc.w    music_command_08-(cmd_jump_table+14)    ; L000043a4 + $00DC = $00004480 - CMD 08 - music_command_08
            dc.w    music_command_09-(cmd_jump_table+16)    ; L000043a6 + $00EA = $00004490 - CMD 09 - music_command_09
            dc.w    music_command_10-(cmd_jump_table+18)    ; L000043a8 + $00F8 = $000044a0 - CMD 10 - music_command_10
            dc.w    music_command_11-(cmd_jump_table+20)    ; L000043aa + $010A = $000044b4 - CMD 11 - music_command_11
            dc.w    music_command_12-(cmd_jump_table+22)    ; L000043ac + $0140 = $000044ec - CMD 12 - music_command_12
            dc.w    music_command_13-(cmd_jump_table+24)    ; L000043ae + $0156 = $00004504 - CMD 13 - music_command_13
            dc.w    music_command_14-(cmd_jump_table+26)    ; L000043b0 + $010C = $000044bc - CMD 14 - music_command_14
            dc.w    music_command_15-(cmd_jump_table+28)    ; L000043b2 + $0132 = $000044e4 - CMD 15 - music_command_15
            dc.w    music_command_16-(cmd_jump_table+30)    ; L000043b4 + $0158 = $0000450c - CMD 16 - music_command_16
            dc.w    music_command_17-(cmd_jump_table+32)    ; L000043b6 + $016E = $00004524 - CMD 17 - music_command_17
            dc.w    $0000
            dc.w    $0000
            dc.w    $0000
            dc.w    $0000
            dc.w    $0000
            dc.w    $0000
            dc.w    $0000 
            dc.w    $0000 
            dc.w    $0000
            dc.w    $0000
            dc.w    $0000
            dc.w    $0000
            dc.w    $0000
            dc.w    $0000
            dc.w    $0000 


;
; 000043d6 - CMD 01 - ($80) 
;       - Next Pattern/Loop current pattern/Loop back to start pattern or finish playing
;       - no loop if $0002(a4) not set.
music_command_01
L000043d6           movea.l $000a(a4),a3
L000043da           cmpa.w  #$0000,a3
L000043de           bne.b   channel_cmd_loop            ;L00004370

L000043e0           movea.l $0006(a4),a3
L000043e4           move.b  -$0001(a3),d0

L000043e8           subq.b  #$01,$0012(a4)
L000043ec           bne.b   L0000443c

L000043ee           move.b  #$01,$0012(a4)
L000043f4           move.b  #$00,$0013(a4)

                    ; command loop
L000043fa           move.b  (a3)+,d0
L000043fc           bpl.b   L0000443c

L000043fe           sub.b   #$80,d0
L00004402           bne.b   L0000441e
                    ; cmd 80
L00004404           movea.l $0002(a4),a3
L00004408           cmpa.w  #$0000,a3
L0000440c           bne.b   L000043fa
                    ; disable channel and exit
L0000440e           move.w  #$0001,$004a(a4)
L00004414           move.w  #$0000,$004c(a4)
L0000441a           moveq   #$00,d7
L0000441c           rts  

L0000441e           subq.b  #$01,d0
L00004420           bne.b   L00004428
L00004422           move.l  a3,$0002(a4)
L00004426           bra.b   L000043fa

L00004428           subq.b  #$01,d0
L0000442a           bne.b   L00004432

L0000442c           move.b  (a3)+,$0013(a4)
L00004430           bra.b   L000043fa

L00004432           subq.b  #$01,d0
L00004434           bne.b   L000043fa
L00004436           move.b  (a3)+,$0012(a4)
L0000443a           bra.b   L000043fa

L0000443c           move.l  a3,$0006(a4)
L00004440           lea.l   sound_pattern_data_base,a3      ; L0000c720,a3
L00004446           ext.w   d0
L00004448           add.w   d0,d0
L0000444a           adda.w  d0,a3
L0000444c           adda.w  (a3),a3
L0000444e           bra.w   L00004370



;
; 00004452 - CMD 02 - ($81)
;       - store current pattern position ptr (loop back within current pattern)
music_command_02
L00004452           move.l  a3,$000a(a4)
L00004456           bra.w   channel_cmd_loop    ; L00004370


;
; 0000445a - CMD 03 - ($82)
;       - no operation
music_command_03
L0000445a           bra.w   channel_cmd_loop    ; L00004370


;
; 0000445e - CMD 03 - ($82)
;       - no operation
music_command_04
L0000445e           bra.w   channel_cmd_loop    ; L00004370



;
; 00004462 - CMD 05 - ($84)
;               - Set CRTL bit 5 
;               - Set Param byte $0051(s)
music_command_05
L00004462           bset.l  #$0005,d7
L00004466           move.b  (a3)+,$0051(a4)
L0000446a           bra.w   channel_cmd_loop    ; L00004370


;
; L000484a0 - CMD 06 - ($85)
;               - End/Cancel Command 05
music_command_06
L0000446e           bclr.l  #$0005,d7
L00004472           bra.w   channel_cmd_loop    ; L00004370


;
; 00004476 - CMD 07 - ($86)
;               - increase $0052(s) by $0100 (256)
music_command_07
L00004476           add.w   #$0100,$0052(a4)
L0000447c           bra.w   channel_cmd_loop    ; L00004370


;
; L000484b2 - CMD 08 - $(87)
;               - clear bit 4 - channel ctrl
;               - set bit 7 - channel ctrl
;               - clear $004c(s)
;               - add $0052(s) with CMD 05 value (if active $0051(s)) or add next pattern byte 
;
music_command_08
L00004480           bclr.l  #$0004,d7
L00004484           bset.l  #$0007,d7
L00004488           clr.w   $004c(a4)
L0000448c           bra.w   L00004694


; 00004490 - CMD 09 - ($88)
;               - set bit 3 - channel ctrl
;               - set command parameters from pattern data bytes
;
music_command_09
L00004490           bset.l  #$0003,d7
L00004494           move.b  (a3)+,$0024(a4)
L00004498           move.b  (a3)+,$0025(a4)
L0000449c           bra.w   channel_cmd_loop        ; L00004370


;
; L000484d2 - CMD 10 - ($89)
;               - clear bits 0 - 2 (cmd 14)
;               - clear bits 4 -7 (cmd 5,8)
;               - preserve other bits (cmd 9)
;               - set parameter bytes
music_command_10
L000044a0           and.w   #$fff8,d7
L000044a4           bset.l  #$0000,d7
L000044a8           move.b  (a3)+,$0021(a4)
L000044ac           move.b  (a3)+,$0022(a4)
L000044b0           bra.w   channel_cmd_loop        ; L00004370 


;
; 000044b4 - CMD 11 - ($8a)
;               - clear ctrl bit 0
music_command_11
L000044b4           bclr.l  #$0000,d7
L000044b8           bra.w   channel_cmd_loop        ; L00004370



; L000044bc - CMD 14 - ($8d)
;               - set bit 1
;               - clear bits 1 - 2
;               - clear bits 4 - 7
;               - preserve bit 3 (CMD 9)
music_command_14
L000044bc           and.w   #$fff8,d7
L000044c0           bset.l  #$0001,d7
L000044c4           lea.l   command_14_data,a0      ; L0000c5d2,a0
L000044ca           moveq   #$00,d0
L000044cc           move.b  (a3)+,d0
L000044ce           add.w   d0,d0
L000044d0           adda.w  d0,a0
L000044d2           adda.w  (a0),a0
L000044d4           move.b  (a0)+,$0032(a4)
L000044d8           move.b  (a0)+,$0030(a4)
L000044dc           move.l  a0,$0028(a4)
L000044e0           bra.w   channel_cmd_loop        ; L00004370


; 000044e4 - CMD 15
music_command_15
L000044e4           bclr.l  #$0001,d7
L000044e8           bra.w   channel_cmd_loop        ; L00004370



; 000044ec - CMD 12
music_command_12
L000044ec           and.w   #$fff8,d7
L000044f0           bset.l  #$0002,d7
L000044f4           move.b  (a3)+,$0036(a4)
L000044f8           move.b  (a3)+,$0034(a4)
L000044fc           move.b  (a3)+,$0035(a4)
L00004500           bra.w   channel_cmd_loop        ; L00004370


; 00004504 - CMD 13
music_command_13
L00004504           bclr.l  #$0002,d7
L00004508           bra.w   channel_cmd_loop        ; L00004370


; 0000450c - CMD 16
music_command_16
L0000450c           lea.l   command_16_data,a0      ; $0000c68a,a0
L00004512           moveq   #$00,d0
L00004514           move.b  (a3)+,d0
L00004516           add.w   d0,d0
L00004518           adda.w  d0,a0
L0000451a           adda.w  (a0),a0
L0000451c           move.l  a0,$0014(a4)
L00004520           bra.w   channel_cmd_loop        ; L00004370


; 00004524 - CMD 17
music_command_17
L00004524           lea.l   command_17_data,a0      ; $00004be2,a0
L0000452a           moveq   #$00,d0
L0000452c           move.b  (a3)+,d0
L0000452e           asl.w   #$04,d0
L00004530           adda.w  d0,a0
L00004532           move.w  (a0)+,$003c(a4)
L00004536           move.l  (a0)+,$003e(a4)
L0000453a           move.w  (a0)+,$0042(a4)
L0000453e           move.l  (a0)+,$0044(a4)
L00004542           move.w  (a0)+,$0048(a4)
L00004546           bclr.l  #$0006,d7
L0000454a           tst.w   (a0) [0012]
L0000454c           beq.w   channel_cmd_loop        ; L00004370
L00004550           bset.l  #$0006,d7
L00004554           bra.w   channel_cmd_loop        ; L00004370



                ; +ve pattern command data (end of pattern command loop)
                ; IN: A4 = Sound Channel Structure
                ; IN: A3 = Next Pattern Command Ptr
                ; IN: D0 = command data
                ; IN: D7 = Channel Ctrl Bits
process_sound_commands  ; original address 00004558
L00004558           btst.l  #$0006,d7
L0000455c           bne.b   L00004562
L0000455e           add.b   $0013(a4),d0
L00004562           move.b  d0,$004f(a4)
L00004566           btst.l  #$0000,d7
L0000456a           beq.b   L00004576
L0000456c           add.b   $0021(a4),d0
L00004570           move.b  $0022(a4),$0023(a4)
L00004576           move.b  d0,$0050(a4)
L0000457a           ext.w   d0
L0000457c           sub.w   $003c(a4),d0
L00004580           add.w   d0,d0
L00004582           cmp.w   #$ffd0,d0
L00004586           blt.b   L0000458e
L00004588           cmp.w   #$002c,d0
L0000458c           ble.b   L000045a4

L0000458e           move.b  $004f(a4),d1
L00004592           move.b  $0050(a4),d2
L00004596           move.w  $003c(a4),d3
L0000459a           move.w  $0054(a4),d4
L0000459e           movea.l $0006(a4),a2
L000045a2           illegal

L000045a4           move.w  $00(a5,d0.w),$004a(a4)
L000045aa           btst.l  #$0002,d7
L000045ae           beq.b   L0000460a
L000045b0           move.b  $0050(a4),d0
L000045b4           add.b   $0034(a4),d0
L000045b8           ext.w   d0
L000045ba           sub.w   $003c(a4),d0
L000045be           add.w   d0,d0
L000045c0           cmp.w   #$ffd0,d0
L000045c4           blt.b   L000045cc
L000045c6           cmp.w   #$002c,d0
L000045ca           ble.b   L000045e2

L000045cc           move.b  $004f(a4),d1
L000045d0           move.b  $0050(a4),d2
L000045d4           move.w  $003c(a4),d3
L000045d8           move.w  $0054(a4),d4
L000045dc           movea.l $0006(a4),a2
L000045e0           illegal

L000045e2           move.w  $00(a5,d0.w),d0
L000045e6           sub.w   $004a(a4),d0
L000045ea           asr.w   #$01,d0
L000045ec           ext.l   d0
L000045ee           move.b  $0035(a4),d1
L000045f2           ext.w   d1
L000045f4           divs.w  d1,d0
L000045f6           move.w  d0,$003a(a4)
L000045fa           move.b  d1,$0039(a4)

L000045fe           add.b   d1,d1
L00004600           move.b  d1,$0038(a4)
L00004604           move.b  $0036(a4),$0037(a4)
L0000460a           btst.l  #$0003,d7
L0000460e           beq.b   L00004660
L00004610           move.b  $0050(a4),d0
L00004614           add.b   $0024(a4),d0
L00004618           ext.w   d0
L0000461a           sub.w   $003c(a4),d0
L0000461e           add.w   d0,d0
L00004620           cmp.w   #$ffd0,d0
L00004624           blt.b   L0000462c
L00004626           cmp.w   #$002c,d0
L0000462a           ble.b   L00004642

L0000462c           move.b  $004f(a4),d1
L00004630           move.b  $0050(a4),d2
L00004634           move.w  $003c(a4),d3
L00004638           move.w  $0054(a4),d4
L0000463c           movea.l $0006(a4),a2
L00004640           illegal

L00004642           move.w  $00(a5,d0.w),d0
L00004646           sub.w   $004a(a4),d0
L0000464a           ext.l   d0
L0000464c           moveq   #$00,d1
L0000464e           move.b  $0025(a4),d1
L00004652           divs.w  d1,d0
L00004654           move.w  d0,$0026(a4)
L00004658           neg.w   d0
L0000465a           muls.w  d1,d0
L0000465c           sub.w   d0,$004a(a4)
L00004660           btst.l  #$0001,d7
L00004664           beq.b   L00004678
L00004666           move.b  #$01,$0033(a4)
L0000466c           move.l  $0028(a4),$002c(a4)
L00004672           move.b  $0030(a4),$0031(a4)
L00004678           bset.l  #$0004,d7
L0000467c           move.l  $0014(a4),$0018(a4)
L00004682           move.w  #$0001,$001e(a4)
L00004688           clr.w   $004c(a4)
L0000468c           move.w  $0054(a4),d0
L00004690           or.w    d0,audio_dma            ; L0000417c

; jmp destination from 'pattern command 08 ($87)'
L00004694           moveq   #$00,d0
L00004696           move.b  $0051(a4),d0
L0000469a           btst.l  #$0005,d7
L0000469e           bne.b   L000046a2
L000046a0           move.b  (a3)+,d0
L000046a2           add.w   d0,$0052(a4)
L000046a6           move.l  a3,$000e(a4)


; jmp destination from 'process_command_loop' when $0052(s) is not $0000
L000046aa           btst.l  #$0007,d7
L000046ae           bne.w   exit_process_sound_commands     ; L00004848


L000046b2           move.w  $004a(a4),d0
L000046b6           btst.l  #$0003,d7
L000046ba           beq.b   L000046ce
L000046bc           subq.b  #$01,$0025(a4)
L000046c0           bne.b   L000046c6
L000046c2           bclr.l  #$0003,d7
L000046c6           sub.w   $0026(a4),d0
L000046ca           bra.w   L000047a0
L000046ce           btst.l  #$0000,d7
L000046d2           beq.b   L0000471a
L000046d4           subq.b  #$01,$0023(a4)
L000046d8           bcc.w   L000047a0
L000046dc           move.b  $004f(a4),d0
L000046e0           move.b  $0050(a4),d1
L000046e4           move.b  d0,$0050(a4)
L000046e8           ext.w   d0
L000046ea           sub.w   $003c(a4),d0
L000046ee           add.w   d0,d0
L000046f0           cmp.w   #$ffd0,d0
L000046f4           blt.b   L000046fc
L000046f6           cmp.w   #$002c,d0
L000046fa           ble.b   L00004712

L000046fc           move.b  $004f(a4),d1
L00004700           move.b  $0050(a4),d2
L00004704           move.w  $003c(a4),d3
L00004708           move.w  $0054(a4),d4
L0000470c           movea.l $0006(a4),a2
L00004710           illegal

L00004712           move.w  $00(a5,d0.w),d0
L00004716           bra.w   L000047a0
L0000471a           btst.l  #$0001,d7
L0000471e           beq.b   L0000477c
L00004720           subq.b  #$01,$0033(a4)
L00004724           bne.b   L000047a0
L00004726           movea.l $002c(a4),a0
L0000472a           move.b  (a0)+,d0
L0000472c           subq.b  #$01,$0031(a4)
L00004730           bne.b   L0000473c
L00004732           movea.l $0028(a4),a0
L00004736           move.b  $0030(a4),$0031(a4)
L0000473c           move.l  a0,$002c(a4)
L00004740           move.b  $0032(a4),$0033(a4)
L00004746           add.b   $0050(a4),d0
L0000474a           ext.w   d0
L0000474c           sub.w   $003c(a4),d0
L00004750           add.w   d0,d0
L00004752           cmp.w   #$ffd0,d0
L00004756           blt.b   L0000475e
L00004758           cmp.w   #$002c,d0
L0000475c           ble.b   L00004774

L0000475e           move.b  $004f(a4),d1
L00004762           move.b  $0050(a4),d2
L00004766           move.w  $003c(a4),d3
L0000476a           move.w  $0054(a4),d4
L0000476e           movea.l $0006(a4),a2
L00004772           illegal

L00004774           move.w  $00(a5,d0.w),d0
L00004778           bra.w   L000047a0
L0000477c           btst.l  #$0002,d7
L00004780           beq.b   L000047a0
L00004782           subq.b  #$01,$0037(a4)
L00004786           bcc.b   L000047a0
L00004788           addq.b  #$01,$0037(a4)
L0000478c           subq.b  #$01,$0039(a4)
L00004790           bne.b   L0000479c
L00004792           neg.w   $003a(a4)
L00004796           move.b  $0038(a4),$0039(a4)
L0000479c           add.w   $003a(a4),d0
L000047a0           move.w  d0,$004a(a4)
L000047a4           btst.l  #$0004,d7
L000047a8           beq.w   exit_process_sound_commands     ; L00004848
L000047ac           subq.w  #$01,$001e(a4)
L000047b0           bne.w   L00004832
L000047b4           movea.l $0018(a4),a0
L000047b8           moveq   #$00,d0
L000047ba           move.b  (a0)+,d0
L000047bc           beq.b   L00004800
L000047be           bmi.b   L000047da
L000047c0           move.w  d0,$001e(a4)
L000047c4           move.b  #$01,$001c(a4)
L000047ca           move.b  #$01,$001d(a4)
L000047d0           move.b  (a0)+,$0020(a4)
L000047d4           move.l  a0,$0018(a4)
L000047d8           bra.b   L00004832
L000047da           neg.b   d0
L000047dc           move.w  d0,$001e(a4)
L000047e0           move.b  #$01,$0020(a4)
L000047e6           move.b  (a0)+,d0
L000047e8           bpl.b   L000047f0
L000047ea           neg.b   d0
L000047ec           neg.b   $0020(a4)
L000047f0           move.b  d0,$001c(a4)
L000047f4           move.b  #$01,$001d(a4)
L000047fa           move.l  a0,$0018(a4)
L000047fe           bra.b   L00004832
L00004800           move.b  (a0),d0
L00004802           beq.b   L0000480e
L00004804           bpl.b   L00004808
L00004806           neg.b   d0
L00004808           sub.w   $0052(a4),d0
L0000480c           bmi.b   L00004814
L0000480e           bclr.l  #$0004,d7
L00004812           bra.b   exit_process_sound_commands     ; L00004848

L00004814           neg.w   d0
L00004816           move.w  d0,$001e(a4)
L0000481a           move.b  #$00,$001c(a4)
L00004820           move.b  #$00,$001d(a4)
L00004826           move.b  #$00,$0020(a4)
L0000482c           move.l  a0,$0018(a4)
L00004830           bra.b   exit_process_sound_commands     ; L00004848

L00004832           subq.b  #$01,$001d(a4)
L00004836           bne.b   exit_process_sound_commands     ; L00004848

L00004838           move.b  $001c(a4),$001d(a4)
L0000483e           move.b  $0020(a4),d0
L00004842           ext.w   d0
L00004844           add.w   d0,$004c(a4)

exit_process_sound_commands     ; original address L00004848
L00004848           rts  


update_audio_custom_registers   ; original address L0000484a
L0000484a           move.w  audio_dma,d0        ; L0000417c,d0
L0000484e           beq.b   L000048be
L00004850           move.w  d0,$0096(a6)
L00004854           move.w  d0,d1
L00004856           lsl.w   #$07,d1
L00004858           move.w  d1,$009c(a6)
L0000485c           moveq   #$00,d2
L0000485e           moveq   #$01,d3
L00004860           btst.l  #$0000,d0
L00004864           beq.b   L0000486e
L00004866           move.w  d3,$00a6(a6)
L0000486a           move.w  d2,$00aa(a6)
L0000486e           btst.l  #$0001,d0
L00004872           beq.b   L0000487c
L00004874           move.w  d3,$00b6(a6)
L00004878           move.w  d2,$00ba(a6)
L0000487c           btst.l  #$0002,d0
L00004880           beq.b   L0000488a
L00004882           move.w  d3,$00c6(a6)
L00004886           move.w  d2,$00ca(a6)
L0000488a           btst.l  #$0003,d0
L0000488e           beq.b   L00004898
L00004890           move.w  d3,$00d6(a6)
L00004894           move.w  d2,$00da(a6)
L00004898           move.w  $001e(a6),d2
L0000489c           and.w   d1,d2
L0000489e           cmp.w   d1,d2
L000048a0           bne.b   L00004898
L000048a2           moveq   #$02,d2
L000048a4           move.w  $0006(a6),d3
L000048a8           and.w   #$ff00,d3
L000048ac           move.w  $0006(a6),d4
L000048b0           and.w   #$ff00,d4
L000048b4           cmp.w   d4,d3
L000048b6           beq.b   L000048ac
L000048b8           move.w  d4,d3
L000048ba           dbf.w   d2,L000048ac

L000048be           move.w  master_audio_volume_mask_1,d1       ; L0000401c,d1
L000048c2           move.w  master_audio_volume_mask_2,d2       ; L0000401e,d2
L000048c6           lea.l   channel_00_status,a0                ; L00004024,a0
L000048ca           move.w  d1,d3
L000048cc           btst.b  #$0006,(a0)
L000048d0           beq.b   L000048d4
L000048d2           move.w  d2,d3
L000048d4           and.w   $004c(a0),d3
L000048d8           move.w  d3,$00a8(a6)
L000048dc           move.w  $004a(a0),$00a6(a6)
L000048e2           btst.l  #$0000,d0
L000048e6           beq.b   L000048f6
L000048e8           move.w  $0042(a0),$00a4(a6)
L000048ee           move.l  $003e(a0),$00a0(a6)
L000048f4           bra.b   L00004902
L000048f6           move.w  $0048(a0),$00a4(a6)
L000048fc           move.l  $0044(a0),$00a0(a6)
L00004902           lea.l   channel_01_status,a0                ; L0000407a,a0
L00004906           move.w  d1,d3
L00004908           btst.b  #$0006,(a0)
L0000490c           beq.b   L00004910
L0000490e           move.w  d2,d3
L00004910           and.w   $004c(a0),d3
L00004914           move.w  d3,$00b8(a6)
L00004918           move.w  $004a(a0),$00b6(a6)
L0000491e           btst.l  #$0001,d0
L00004922           beq.b   L00004932
L00004924           move.w  $0042(a0),$00b4(a6)
L0000492a           move.l  $003e(a0),$00b0(a6)
L00004930           bra.b   L0000493e
L00004932           move.w  $0048(a0),$00b4(a6)
L00004938           move.l  $0044(a0),$00b0(a6)
L0000493e           lea.l   channel_02_status,a0                ; L000040d0,a0
L00004942           move.w  d1,d3
L00004944           btst.b  #$0006,(a0)
L00004948           beq.b   L0000494c
L0000494a           move.w  d2,d3
L0000494c           and.w   $004c(a0),d3
L00004950           move.w  d3,$00c8(a6)
L00004954           move.w  $004a(a0),$00c6(a6)
L0000495a           btst.l  #$0002,d0
L0000495e           beq.b   L0000496e
L00004960           move.w  $0042(a0),$00c4(a6)
L00004966           move.l  $003e(a0),$00c0(a6)
L0000496c           bra.b   L0000497a
L0000496e           move.w  $0048(a0),$00c4(a6)
L00004974           move.l  $0044(a0),$00c0(a6)
L0000497a           lea.l   channel_03_status,a0                ; L00004126,a0
L0000497e           move.w  d1,d3
L00004980           btst.b  #$0006,(a0)
L00004984           beq.b   L00004988
L00004986           move.w  d2,d3
L00004988           and.w   $004c(a0),d3
L0000498c           move.w  d3,$00d8(a6)
L00004990           move.w  $004a(a0),$00d6(a6)
L00004996           btst.l  #$0003,d0
L0000499a           beq.b   L000049aa
L0000499c           move.w  $0042(a0),$00d4(a6)
L000049a2           move.l  $003e(a0),$00d0(a6)
L000049a8           bra.b   L000049b6
L000049aa           move.w  $0048(a0),$00d4(a6)
L000049b0           move.l  $0044(a0),$00d0(a6)
L000049b6           or.w    #$8000,d0
L000049ba           move.w  d0,$0096(a6)
L000049be           clr.w   audio_dma                           ; L0000417c
L000049c2           rts 



                ;------------------- initialise music samples --------------------
                ; extract sample data ptrs and lengths from the IFF sample
                ; data.
                ;
                ; IN: a0    - music sample table address $4D52 - default_sample_data
                ; IN: a1    - music/song instrument data $4BFA - instrument_data
                ;
init_instruments    ; original address L000049c4
L000049c4           move.l  (a0)+,d0
L000049c6           beq.b   L000049e2
L000049c8           move.w  (a0)+,(a1)
L000049ca           move.w  (a0)+,$000e(a1)
L000049ce           move.l  a0,-(a7)
L000049d0           lea.l   -$8(a0,d0.l),a0
L000049d4           move.l  $0004(a0),d0
L000049d8           addq.l  #$08,d0
L000049da           bsr.w   process_instrument      ; L000049e4
L000049de           movea.l (a7)+,a0
L000049e0           bra.b   init_instruments        ; L000049c4
L000049e2           rts  



                ; ------------------ process instrument  ----------------
                ; IN: A0 = ptr to start of 'FORM' block of sample data.
                ; IN: A1 = ptr to Instrument Entry in Music Data.
                ; IN: D0 = length of sample including headers.
                ;
process_instrument  ; original address L000049e4
L000049e4           move.l  a1,-(a7)
L000049e6           bsr.w   process_sample_data         ; L00004a28
L000049ea           movea.l (a7)+,a1
L000049ec           addq.l  #$02,a1
L000049ee           movea.l sample_vhdr_ptr,a0          ; L00004b36,a0
L000049f4           move.l  (a0)+,d0
L000049f6           bclr.l  #$0000,d0
L000049fa           move.l  (a0)+,d1
L000049fc           bclr.l  #$0000,d1
L00004a00           movea.l sample_body_ptr,a0          ; L00004b5c,a0
L00004a06           move.l  a0,(a1)+
L00004a08           adda.l  d0,a0
L00004a0a           add.l   d1,d0
L00004a0c           lsr.l   #$01,d0
L00004a0e           move.w  d0,(a1)+
L00004a10           tst.l   d1
L00004a12           bne.b   L00004a1c
L00004a14           lea.l   silient_repeat,a0           ; L00004d32,a0
L00004a1a           moveq   #$02,d1
L00004a1c           move.l  a0,(a1)+
L00004a1e           lsr.l   #$01,d1
L00004a20           move.w  d1,(a1)+
L00004a22           addq.l  #$02,a1
L00004a24           rts



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
sample_status   ; original address L00004a26
L00004a26               dc.w    $0000


process_sample_data ; original address L00004a28
L00004a28               clr.w   sample_status           ; L00004a26
L00004a2c               movem.l d0/a0,-(a7)
L00004a30               bra.w   process_inner_chunk     ; L00004a34

process_inner_chunk ; original address L00004a34
L00004a34               tst.l   d0
L00004a36               beq.b   L00004a42
L00004a38               move.l  (a0)+,d1
L00004a3a               subq.l  #$04,d0
L00004a3c               bsr.w   process_sample_chunk    ; L00004a48
L00004a40               bra.b   process_inner_chunk     ; L00004a34
L00004a42               movem.l (a7)+,d0/a0
L00004a46               rts 


                ;------------------ process sample chunk ------------------
                ; process IFF sample data, top level of file structure.
                ;
                ; IN: A0 = ptr to length of data.
                ; IN: A1 = ptr to Instrument Entry in Music Data.
                ; IN: D0.l = length of remaining data including length data.
                ; IN: D1.l = chunk identifier, e.g. FORM, CAT etc
                ;
process_sample_chunk    ; original address L00004a48
L00004a48               cmp.l   #'FORM',d1              ; #$464f524d,d1
L00004a4e               beq.w   process_form_chunk      ; L00004aa4
L00004a52               cmp.l   #'CAT ',d1              ; #$43415420,d1
L00004a58               beq.w   process_cat_chunk       ; L00004a66
L00004a5c               move.w  #$0001,sample_status    ; L00004a26
L00004a62               clr.l   d0
L00004a64               rts 


                ;--------------------- process CAT chunk --------------------------
                ; skips header and continues processing any further chunks 
                ; that are nested inside the CAT Chunk, data.
                ;
                ; IN: A0 = ptr to length of chunk data.
                ; IN: A1 = ptr to Instrument Entry in Music Data.
                ; IN: D0.l = length of remaining data including length data.
                ; IN: D1.l = chunk identifier, e.g. FORM, CAT etc
                ;
process_cat_chunk   ; original address L00004a66  
L00004a66               movem.l d0/a0,-(a7)
L00004a6a               move.l  (a0)+,d0
L00004a6c               move.l  d0,d1
L00004a6e               btst.l  #$0000,d1
L00004a72               beq.b   L00004a76
L00004a74               addq.l  #$01,d1
L00004a76               addq.l  #$04,d1
L00004a78               add.l   d1,$0004(a7)
L00004a7c               sub.l   d1,(a7)
L00004a7e               addq.l  #$04,(a0)
L00004a80               subq.l  #$04,d0
L00004a82               bra.b   process_inner_chunk         ; L00004a34



                ;------------------- process LIST chunk -----------------
                ; skip the list chunk, and continue processing
                ;
                ; IN: A0 = ptr to length of data.
                ; IN: A1 = ptr to Instrument Entry in Music Data.
                ; IN: D0.l = length of remaining data.
                ; IN: D1.l = chunk identifier, e.g. FORM, CAT etc
                ;
process_list_chunk      ; original address L00004a84
L00004a84               movem.l d0/a0,-(a7)
L00004a88               move.l  (a0)+,d0
L00004a8a               move.l  d0,d1
L00004a8c               btst.l  #$0000,d1
L00004a90               beq.b   L00004a94
L00004a92               addq.l  #$01,d1
L00004a94               addq.l  #$04,d1
L00004a96               add.l   d1,$0004(a7)
L00004a9a               sub.l   d1,(a7)
L00004a9c               nop
L00004a9e               movem.l (a7)+,d0/a0
L00004aa2               rts



                ;---------------- process FORM chunk ------------------
                ; Expects to find an '8SVX' inner chunk of data.
                ; If not, then sets error/status flag = $0002
                ;
                ; IN: A0 = ptr to length of data.
                ; IN: A1 = ptr to Instrument Entry in Music Data.
                ; IN: D0.l = length of remaining data including length field.
                ; IN: D1.l = chunk identifier, e.g. FORM, CAT etc
                ;
process_form_chunk  ; original address L00004aa4
L00004aa4               movem.l d0/a0,-(a7)
L00004aa8               move.l  (a0)+,d0
L00004aaa               move.l  d0,d1
L00004aac               btst.l  #$0000,d1
L00004ab0               beq.b   L00004ab4
L00004ab2               addq.l  #$01,d1
L00004ab4               addq.l  #$04,d1
L00004ab6               add.l   d1,$0004(a7)
L00004aba               sub.l   d1,(a7)
L00004abc               move.l  (a0)+,d1
L00004abe               subq.l  #$04,d0
L00004ac0               cmp.l   #'8SVX',d1              ; #$38535658,d1
L00004ac6               beq.w   process_8svx_chunk      ; L00004ad6
L00004aca               move.w  #$0002,sample_status    ; L00004a26
L00004ad0               movem.l (a7)+,d0/a0
L00004ad4               rts 


                ;------------------ process 8SVX chunk ---------------------
                ; loops through sample data until no bytes remaining.
                ; processes inner chunks of 8SVX chunk, including:-
                ;  - VHDL, BODY, NAME, ANNO
                ;
                ; IN: A0 = ptr to length of data.
                ; IN: A1 = ptr to Instrument Entry in Music Data.
                ; IN: D0.l = length of remaining data.
                ; IN: D1.l = chunk identifier, i.e '8SVX'
                ;
process_8svx_chunk  ; original address L00004ad6
L00004ad6               tst.l   d0
L00004ad8               beq.b   L00004ae4
L00004ada               move.l  (a0)+,d1
L00004adc               subq.l  #$04,d0
L00004ade               bsr.w   process_inner_8svx_chunk    ; L00004aea
L00004ae2               bra.b   process_8svx_chunk          ; L00004ad6
L00004ae4               movem.l (a7)+,d0/a0
L00004ae8               rts




                ;---------------- process inner 8SVX chunk --------------
                ; process data held inside the 8SVX chunk, this is only
                ; concerned with the VHDR and BODY chunks. it skips
                ; other chunks such as the NAME, ANNO meta data chunks.
                ;
                ; IN: A0 = ptr to length of data.
                ; IN: A1 = ptr to Instrument Entry in Music Data.
                ; IN: D0 = length of remaining data.
                ; IN: D1.l = chunk identifier, e.g. FORM, CAT etc
                ;
process_inner_8svx_chunk    ; original address L00004aea
L00004aea               cmp.l   #'FORM',d1          ; #$464f524d,d1
L00004af0               beq.b   process_form_chunk  ; L00004aa4
L00004af2               cmp.l   #'LIST',d1          ; #$4c495354,d1
L00004af8               beq.b   process_list_chunk  ; L00004a84
L00004afa               cmp.l   #'CAT ',d1          ; #$43415420,d1
L00004b00               beq.w   process_cat_chunk   ; L00004a66
L00004b04               cmp.l   #'VHDR',d1          ; #$56484452,d1
L00004b0a               beq.w   process_vhdr_chunk  ; L00004b3a
L00004b0e               cmp.l   #'BODY',d1          ; #$424f4459,d1
L00004b14               beq.w   process_body_chunk  ; L00004b60
L00004b18               movem.l d0/a0,-(a7)
L00004b1c               move.l  (a0)+,d0
L00004b1e               move.l  d0,d1
L00004b20               btst.l  #$0000,d1
L00004b24               beq.b   L00004b28
L00004b26               addq.l  #$01,d1
L00004b28               addq.l  #$04,d1
L00004b2a               add.l   d1,$0004(a7)
L00004b2e               sub.l   d1,(a7)
L00004b30               movem.l (a7)+,d0/a0
L00004b34               rts



                ;-------------------- process VHDR chunk ----------------------
                ; stores address of VHDR chunk in variable 'sample_vhdr_ptr'
                ;
                ; IN: A0 = ptr to length of data.
                ; IN: A1 = ptr to Instrument Entry in Music Data.
                ; IN: D0 = length of remaining data.
                ; IN: D1.l = chunk identifier, e.g. FORM, CAT etc
                ;
sample_vhdr_ptr     ; original address L00004b36
L00004b36               dc.l    $0000c0e2


process_vhdr_chunk  ; original address L00004b3a
L00004b3a               movem.l d0/a0,-(a7)
L00004b3e               move.l  (a0)+,d0
L00004b40               move.l  d0,d1
L00004b42               btst.l  #$0000,d1
L00004b46               beq.b   L00004b4a
L00004b48               addq.l  #$01,d1
L00004b4a               addq.l  #$04,d1
L00004b4c               add.l   d1,$0004(a7)
L00004b50               sub.l   d1,(a7)
L00004b52               move.l  a0,sample_vhdr_ptr          ; L00004b36
L00004b56               movem.l (a7)+,d0/a0
L00004b5a               rts



                ;------------------------- process body chunk ------------------------
                ; store address of the raw sample data in variable 'sample_body_ptr'
                ;
                ; IN: A0 = ptr to length of data.
                ; IN: A1 = ptr to Instrument Entry in Music Data.
                ; IN: D0 = length of remaining data.
                ; IN: D1.l = chunk identifier, e.g. FORM, CAT etc
                ;
sample_body_ptr     ; original address L00004b5c
L00004b5c               dc.l    $0000c136


process_body_chunk  ; original address L00004b60
L00004b60               movem.l d0/a0,-(a7)
L00004b64               move.l  (a0)+,d0
L00004b66               move.l  d0,d1
L00004b68               btst.l  #$0000,d1
L00004b6c               beq.b   L00004b70
L00004b6e               addq.l  #$01,d1
L00004b70               addq.l  #$04,d1
L00004b72               add.l   d1,$0004(a7)
L00004b76               sub.l   d1,(a7)
L00004b78               move.l  a0,sample_body_ptr          ; L00004b5c
L00004b7c               movem.l (a7)+,d0/a0
L00004b80               rts

                ; --------------------- Note Period Table ------------------------
                ;       - audio channel period values - note frequenies
                ;       - indexes to $00004bba clamped to -48 bytes or +44 bytes to remain in table range
                ;       - I've got the table running B to B (may be I'm a semi-tone out C to C - most likely) 
note_period_table    ; original address 00004B82
L00004B82       dc.w    $06FE,$0699,$063B,$05E1,$058D,$053D,$04F2,$04AB
L00004B92       dc.w    $0467,$0428,$03EC,$03B4,$037F,$034D,$031D,$02F1
L00004BA2       dc.w    $02C6,$029E,$0279,$0255,$0234,$0214,$01F6,$01DA
                ; + 48 bytes - midpoint
L00004BB2       dc.w    $01BF,$01A6,$018F,$0178,$0163,$014F,$013C,$012B
L00004BC2       dc.w    $011A,$010A,$00FB,$00ED,$00E0,$00D3,$00C7,$00BC
L00004BD2       dc.w    $00B2,$00A8,$009E,$0095,$008D,$0085,$007E,$0077

command_17_data ; original address L00004BE2
L00004BE2       dc.w    $0021,$0000,$4D34,$000B,$0000,$4D34,$000B,$0000  

instrument_data ; original address L00004BF2
L00004BF2       dc.w    $0030,$0000,$4DEE,$0ED0,$0000,$4D32,$0001,$0000
L00004C02       dc.w    $0024,$0000,$6BF6,$0A02,$0000,$4D32,$0001,$FFFF
L00004C12       dc.w    $0018,$0000,$8062,$0A28,$0000,$4D32,$0001,$FFFF
L00004C22       dc.w    $001F,$0000,$951A,$08E4,$0000,$A0C2,$0310,$0000
L00004C32       dc.w    $002D,$0000,$A74A,$09B3,$0000,$B4F2,$02DF,$0000
L00004C42       dc.w    $0018,$0000,$BB18,$02DB,$0000,$4D32,$0001,$0000
L00004C52       dc.w    $0018,$0000,$C136,$024E,$0000,$4D32,$0001,$0000
L00004C62       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00004C72       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00004C82       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00004C92       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00004CA2       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00004CB2       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00004CC2       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00004CD2       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00004CE2       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00004CF2       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00004D02       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00004D12       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00004D22       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

silient_repeat ; original address L00004D32
L00004D32   dc.w    $0000 

L00004d34   dc.w    $0074,$60DC,$82BB,$457E,$24A0,$8C00,$7460
L00004d42   dc.w    $DC82,$BB45,$7E24,$A08C 


                ; ------ music sample data table (12 sample offsets & 2 word params) ------
                ; 12 sound samples in IFF 8SVX format.
                ; Table of address offsets below, not sure what the additional two 16 bit 
                ; parameters that follow the offset represent yet. maybe volume and something else.
                ;
raw_sample_data_table   ; original address L00004d4a
raw_sample_01
L00004d4a   dc.l    sample_file_01-raw_sample_01    ; $0000003C ; $4d86-$4d4a=$0000003C
            dc.W    $0030,$0000
raw_sample_02
L00004D52   dc.l    sample_file_02-raw_sample_02    ; $00001E3C ; $6b8e-$4d52=$6b8e
            dc.w    $0024,$FFFF
raw_sample_03
L00004d5a   dc.l    sample_file_03-raw_sample_03    ; $000032A0 ; $7ffa-$4d5a=$32a0
            dc.w    $0018,$FFFF
raw_sample_04
L00004D62   dc.l    sample_file_04-raw_sample_04    ; $00004750 ; $94b2-$4d62=$4750
            dc.w    $001F,$0000
raw_sample_05
L00004d6a   dc.l    sample_file_05-raw_sample_05    ; $00005978 ; $a6e2-$4d6a=$5978
            dc.w    $002D,$0000
raw_sample_06
L00004D72   dc.l    sample_file_06-raw_sample_06    ; $00006D3E ; $bab0-$4d72=$6d3e
            dc.w    $0018,$0000
raw_sample_07
L00004d7a   dc.l    sample_file_07-raw_sample_07    ; $00007354 ; $c0ce-$4d7a=$7354
            dc.w    $0018,$0000                     

            dc.w    $0000,$0000

; Sample 01
sample_file_01
                ; --------------------- Sound Sample 1 -------------------
                ; Start Address: $00004D86
                ; Name:          MAGIC-C4
                include "./music/sample_file_01.s"

; Sample 02
sample_file_02
                ; --------------------- Sound Sample 2 -------------------
                ; Start Address: $00006b8e
                ; Name:          STRINGS-C4
                include "./music/sample_file_02.s"


; Sample 03
sample_file_03
                ; --------------------- Sound Sample 3 -------------------
                ; Start Address: $00007FFA
                ; Name:          HITSNARE-C2
                include "./music/sample_file_03.s"


; Sample 04
sample_file_04
                ; --------------------- Sound Sample 4 -------------------
                ; Start Address: $000094B2
                ; Name:          SQ80BASS2-G2
                include "./music/sample_file_04.s"


; Sample 05
sample_file_05
                ; --------------------- Sound Sample 5 -------------------
                ; Start Address: $0000A6E2
                ; Name:          TIMELESS-A4
                include "./music/sample_file_05.s"


; Sample 06
sample_file_06
                ; --------------------- Sound Sample 6 -------------------
                ; Start Address: $0000A6E2
                ; Name:          BLIP2
                include "./music/sample_file_06.s"


; Sample 07
sample_file_07
                ; --------------------- Sound Sample 7 -------------------
                ; Start Address: $0000C0ce
                ; Name:          BLIP
                include "./music/sample_file_07.s"



; Music/Pattern Data etc
command_14_data ; original address L0000C5D2
L0000C5D2   dc.w  $002E,$002F,$0031,$0034,$0047,$004A,$004E,$004F  
L0000C5E2   dc.w  $0050,$0051,$0054,$0057,$005A,$005D,$0060,$0073  
L0000C5F2   dc.w  $0076,$0079,$007C,$007F,$0082,$0084,$0087,$0101  
L0000C602   dc.w  $0001,$0200,$0C02,$0300,$0307,$0113,$000C,$010B  
L0000C612   dc.w  $020A,$0309,$0408,$0507,$0605,$0403,$0201,$0001  
L0000C622   dc.w  $0300,$0307,$0204,$000C,$0307,$0101,$0001,$0100  
L0000C632   dc.w  $0101,$0001,$0300,$0509,$0103,$0004,$0701,$0300  
L0000C642   dc.w  $0508,$0103,$0003,$0801,$0300,$0409,$0113,$0018  
L0000C652   dc.w  $020B,$020A,$0309,$0408,$0507,$0605,$0403,$0201  
L0000C662   dc.w  $0001,$0300,$0507,$0103,$0003,$0701,$0300,$0107  
L0000C672   dc.w  $0103,$0005,$0901,$0300,$180C,$0202,$000C,$0103  
L0000C682   dc.w  $0003,$0701,$0300,$0308

command_16_data
L0000c68a   dc.w  $0014,$0018,$001D,$001F  
L0000C692   dc.w  $0024,$0027,$002B,$0031,$0037,$003D,$0128,$0AFC  
L0000C6A2   dc.w  $0000,$0214,$28FF,$0001,$FE01,$2800,$000A,$040A  
L0000C6B2   dc.w  $FF00,$0FFF,$011E,$0003,$F601,$280D,$FD00,$0001  
L0000C6C2   dc.w  $230B,$FD01,$FE00,$0001,$3E14,$FD01,$FE00,$0001  
L0000C6D2   dc.w  $3E1E,$FE01,$FE00,$0001,$3E00,$0000

sounds_table
L0000c6de   dc.w  $00FE,$00D7  
L0000C6E2   dc.w  $00B0,$0000,$040F,$040F,$040F,$0000,$049B,$049B  
L0000C6F2   dc.w  $049B,$0000,$04C4,$04C0,$04C2,$0000,$0000,$0000  
L0000C702   dc.w  $0000,$000A,$0000,$0000,$0000,$0004,$3780,$3880  
L0000C712   dc.w  $8F09,$9006,$1828,$808F,$0990,$070C,$2880

sound_pattern_data_base
L0000c720   dc.w    $0000  
L0000C722   dc.w  $FFFE,$FFFC,$FFFA,$FFF8,$FFF6,$FFF4,$FFF2,$FFF0  
L0000C732   dc.w  $FFEE,$FFEC,$FFEA,$FFE8,$FFE6,$FFE4,$FFE2,$FFE0  
L0000C742   dc.w  $FFDE,$FFDC,$FFDA,$FFD8,$FFD6,$FFD4,$FFD2,$00B9  
L0000C752   dc.w  $00D4,$00EB,$0120,$012B,$0133,$013C,$014B,$0177  
L0000C762   dc.w  $01B3,$0225,$023C,$027C,$0293,$02AF,$02D2,$02EF  
L0000C772   dc.w  $0310,$031D,$032A,$035D,$0381,$03AF,$03CD,$040F  
L0000C782   dc.w  $041C,$0429,$043F,$046E,$049E,$04B4,$FF84,$FF89  
L0000C792   dc.w  $1C83,$0819,$1F83,$0419,$1F22,$2222,$8201,$2282  
L0000C7A2   dc.w  $0122,$8202,$2282,$0222,$2324,$8201,$2482,$0224  
L0000C7B2   dc.w  $8203,$2425,$801D,$8308,$1820,$8304,$1820,$1818  
L0000C7C2   dc.w  $1882,$0118,$8201,$1882,$0218,$8202,$1826,$2782  
L0000C7D2   dc.w  $0127,$8202,$2782,$0327,$2880,$1B83,$041E,$8304  
L0000C7E2   dc.w  $1A21,$8304,$1A21,$1A1A,$1A82,$011A,$8201,$1A82  
L0000C7F2   dc.w  $021A,$8202,$1A83,$0429,$8304,$2A2B,$8201,$2B82  
L0000C802   dc.w  $022B,$8203,$2B2C,$808D,$0490,$058F,$0137,$0637  
L0000C812   dc.w  $0637,$0637,$1237,$0637,$0637,$0637,$128D,$0A35  
L0000C822   dc.w  $0635,$1280,$8E90,$018F,$0184,$0632,$3A3E,$4337  
L0000C832   dc.w  $3A3E,$4337,$3A3E,$4335,$393C,$4185,$808E,$8590  
L0000C842   dc.w  $028F,$0224,$0C90,$048F,$011F,$061F,$0690,$038F  
L0000C852   dc.w  $0218,$0C90,$048F,$011F,$061F,$0690,$028F,$0224  
L0000C862   dc.w  $0C90,$048F,$011F,$061F,$0690,$038F,$0218,$0618  
L0000C872   dc.w  $0C18,$0680,$9004,$8F01,$8B30,$0103,$1B30,$1D30  
L0000C882   dc.w  $8090,$048F,$018E,$2730,$2930,$8090,$058F,$018D  
L0000C892   dc.w  $0A33,$3035,$3080,$9004,$8F01,$8B0C,$0103,$1F48  
L0000C8A2   dc.w  $1D0C,$1D06,$1D06,$8090,$018F,$028E,$8406,$3337  
L0000C8B2   dc.w  $3A3F,$3337,$3A3F,$3033,$373C,$3033,$373C,$3539  
L0000C8C2   dc.w  $3C41,$3539,$3C41,$3639,$3E42,$8E36,$3984,$033E  
L0000C8D2   dc.w  $3F3E,$3F85,$8090,$058F,$018D,$0C84,$062B,$2B37  
L0000C8E2   dc.w  $8412,$3784,$062B,$2B8D,$0B84,$062B,$2B37,$8412  
L0000C8F2   dc.w  $3784,$062B,$2B8D,$1284,$0624,$2430,$8412,$3084  
L0000C902   dc.w  $0624,$248D,$0A84,$0626,$2632,$8412,$3284,$0626  
L0000C912   dc.w  $2685,$808E,$9002,$8F02,$240C,$9004,$8F01,$1B06  
L0000C922   dc.w  $1B06,$9003,$8F02,$1806,$9004,$8F01,$1B06,$1B06  
L0000C932   dc.w  $1B06,$9002,$8F02,$240C,$9004,$8F01,$1806,$1806  
L0000C942   dc.w  $9003,$8F02,$180C,$9004,$8F01,$1806,$1806,$9002  
L0000C952   dc.w  $8F02,$240C,$9004,$8F01,$1D06,$1D06,$9003,$8F02  
L0000C962   dc.w  $1806,$9004,$8F01,$1D06,$1D06,$1D06,$9002,$8F02  
L0000C972   dc.w  $240C,$9004,$8F01,$1A06,$1A06,$9003,$8F02,$1806  
L0000C982   dc.w  $1806,$1806,$1806,$8090,$018F,$008E,$8406,$3736  
L0000C992   dc.w  $3637,$3736,$3637,$3736,$3637,$3736,$3637,$8580  
L0000C9A2   dc.w  $9001,$8F00,$8E84,$0624,$282B,$3034,$3735,$348E  
L0000C9B2   dc.w  $8403,$3C3D,$3C3D,$3C3D,$3C3D,$3C3D,$3C3D,$3C3D  
L0000C9C2   dc.w  $3C3D,$8E84,$0620,$2328,$2C2F,$3439,$388E,$8403  
L0000C9D2   dc.w  $4041,$4041,$4041,$4041,$4041,$4041,$4041,$4041  
L0000C9E2   dc.w  $8580,$9005,$8F01,$8E84,$0632,$312D,$3231,$2D39  
L0000C9F2   dc.w  $3432,$312D,$3231,$3939,$3485,$808E,$8F00,$840C  
L0000CA02   dc.w  $3939,$3985,$3906,$3906,$390C,$3906,$390C,$390C  
L0000CA12   dc.w  $390C,$390C,$390C,$390C,$808D,$0990,$058F,$012B  
L0000CA22   dc.w  $182B,$242B,$062B,$062B,$062B,$062B,$0C8D,$0C2C  
L0000CA32   dc.w  $182C,$242C,$062C,$062C,$062C,$062C,$0C80,$8D0A  
L0000CA42   dc.w  $9005,$8F01,$390C,$3906,$3906,$390C,$3906,$3906  
L0000CA52   dc.w  $390C,$3906,$3906,$390C,$3906,$3906,$808D,$0F90  
L0000CA62   dc.w  $058F,$002D,$0C2D,$0C2D,$0C2D,$068D,$0A2D,$062D  
L0000CA72   dc.w  $0C2D,$062D,$0C2D,$0C2D,$0C2D,$0C2D,$0C2D,$0C80  
L0000CA82   dc.w  $8F02,$9002,$240C,$8F01,$9004,$1806,$1806,$808F  
L0000CA92   dc.w  $0290,$0224,$0C8F,$0190,$041C,$061C,$0680,$8F02  
L0000CAA2   dc.w  $9002,$240C,$8F01,$9004,$2106,$2106,$8F02,$9003  
L0000CAB2   dc.w  $180C,$8F01,$9004,$2106,$2106,$8F02,$9002,$240C  
L0000CAC2   dc.w  $8F01,$9004,$2106,$2106,$8F02,$9003,$1806,$180C  
L0000CAD2   dc.w  $1806,$808E,$8F00,$9004,$210C,$210C,$210C,$2106  
L0000CAE2   dc.w  $2106,$210C,$2106,$210C,$210C,$210C,$210C,$210C  
L0000CAF2   dc.w  $210C,$802E,$802D,$802F,$8085,$9004,$8F01,$2406  
L0000CB02   dc.w  $2406,$2406,$240C,$2406,$2206,$2406,$2906,$2906  
L0000CB12   dc.w  $2906,$2912,$290C,$2406,$2406,$2406,$290C,$290C  
L0000CB22   dc.w  $2906,$240C,$2B0C,$240C,$8085,$8F01,$9001,$870C  
L0000CB32   dc.w  $300C,$330C,$370C,$3812,$3712,$3518,$300C,$3506  
L0000CB42   dc.w  $3806,$3A0C,$3B03,$3C18,$8085,$8F01,$9005,$8D05  
L0000CB52   dc.w  $300C,$3006,$300C,$3006,$3006,$3006,$8D0B,$300C  
L0000CB62   dc.w  $3006,$300C,$3006,$3006,$3006,$8D05,$300C,$3006  
L0000CB72   dc.w  $8D0B,$300C,$3006,$3006,$3006,$8D0A,$300C,$8D0C  
L0000CB82   dc.w  $2F0C,$8D0A,$300C,$8030,$8032,$8031,$808F,$0290  
L0000CB92   dc.w  $028E,$8406,$1F1F,$1D1F,$8587,$1880,$8F01,$9005  
L0000CBA2   dc.w  $8E84,$063A,$3938,$3785,$8718,$8084,$0690,$038F  
L0000CBB2   dc.w  $0218,$1818,$1880,$3380,$3480,$3582,$FE35,$8201  
L0000CBC2   dc.w  $3536,$8085,$9001,$8F04,$8C8E,$8406,$4645,$3E3F  
L0000CBD2   dc.w  $4645,$4645,$3E3F,$4645,$4443,$3C3D,$4443,$4443  
L0000CBE2   dc.w  $3C3D,$4443,$403F,$3738,$403F,$403F,$3738,$403F  
L0000CBF2   dc.w  $853C,$1880,$8590,$058F,$008D,$0B32,$0C32,$0C32  
L0000CC02   dc.w  $0C32,$0632,$0C32,$1230,$0C30,$0C30,$0C30,$0630  
L0000CC12   dc.w  $0C30,$128D,$0C30,$0C30,$0C30,$0C30,$0630,$0C30  
L0000CC22   dc.w  $128D,$1430,$1880,$8590,$048F,$022B,$062B,$062B  
L0000CC32   dc.w  $062B,$062B,$0C2B,$0C2B,$062B,$062B,$0C80,$2418  
L0000CC42   dc.w  $8000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CC52   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CC62   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CC72   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CC82   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CC92   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CCA2   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CCB2   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CCC2   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CCD2   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CCE2   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CCF2   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CD02   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CD12   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CD22   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CD32   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CD42   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CD52   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CD62   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CD72   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CD82   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CD92   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CDA2   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CDB2   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CDC2   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CDD2   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CDE2   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CDF2   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CE02   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CE12   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CE22   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CE32   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CE42   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CE52   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CE62   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CE72   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CE82   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CE92   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CEA2   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CEB2   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CEC2   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CED2   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CEE2   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CEF2   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CF02   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CF12   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CF22   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CF32   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CF42   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CF52   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CF62   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CF72   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CF82   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CF92   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CFA2   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CFB2   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CFC2   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CFD2   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CFE2   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000CFF2   dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$4FF9  




                    ;------------------------- code entry point on load ---------------------------
                    ;
code_entry_point        ;JSR     _DEBUG_COLOURS
                        move.w  #$7fff,CUSTOM+DMACON
                        move.w  #$7fff,CUSTOM+INTENA
                        move.w  #$7fff,CUSTOM+INTREQ
                        move.w  #$7fff,CUSTOM+INTREQ

L0000D000               LEA.L   stack_memory,a7             ; L0000EF96,A7                ; stack
L0000D006               JSR     L00004000                   ; init music

                    ; init font - 320 lines of 5 byte struct (4bpl + mask)
                        ;JSR     _DEBUG_COLOURS
L0000D00C               MOVE.W  #$013f,D7                   ; d7 = 320
L0000D010               LEA.L   font8x8x5,a0                ; L0000E7BC,A0
L0000D016_loop          MOVE.B  $0004(A0),D0
L0000D01A               AND.B   $0001(A0),D0
L0000D01E               NOT.B   D0
L0000D020               AND.B   $0002(A0),D0
L0000D024               AND.B   $0003(A0),D0
L0000D028               EOR.B   D0,$0004(A0)
L0000D02C               MOVE.B  $0004(A0),D0
L0000D030               AND.B   $0003(A0),D0
L0000D034               NOT.B   D0
L0000D036               AND.B   $0001(A0),D0
L0000D03A               AND.B   $0002(A0),D0
L0000D03E               EOR.B   D0,$0001(A0)
L0000D042               EOR.B   D0,$0003(A0)
L0000D046               ADDA.L  #$00000005,A0           ; next raster (interleaved font) struct (5 bytes = 4 bpl + mask)
L0000D048               DBF.W   D7,L0000D016_loop 

L0000D04C               MOVE.W  #$7fff,D0
L0000D050               MOVE.W  D0,CUSTOM+DMACONR                   ; $00dff002; writing to RO register = BAD NEWS
L0000D056               MOVE.W  D0,CUSTOM+INTENA                    ; $00dff09a - disable interrupts
L0000D05C               MOVE.W  D0,CUSTOM+INTREQ                    ; $00dff09c - clear current interrupt flags
L0000D062               MOVE.W  #$e028,CUSTOM+INTENA                ; $00dff09a - SET|INTEN|EXTER|COPER|VERTB|PORTS
L0000D06A               MOVE.W  #$83c0,CUSTOM+DMACON                ; $00dff096 - SET|DMAEN|BPLEN|COPEN|BLTEN
L0000D072               MOVE.L  #copper_list,CUSTOM+COP1LC          ; $00dff080 - copper list
L0000D07C               MOVE.W  CUSTOM+COPJMP1,D0                   ; $00dff088,D0 - reading from WO register - BAD NEWS

L0000D082               MOVE.L  #level1_interrupt_handler,$00000064             ; exception vector - Level 1
L0000D08C               MOVE.L  #level2_interrupt_handler,$00000068             ; exception vector - Level 2
L0000D096               MOVE.L  #level3_interrupt_handler,$0000006c             ; exception vector - Level 3
L0000D0A0               MOVE.L  #level4_interrupt_handler,$00000070             ; exception vector - Level 4
L0000D0AA               MOVE.L  #level5_interrupt_handler,$00000074             ; exception vector - Level 5

L0000D0B4               MOVE.B  #$7f,$00bfed01
L0000D0BC               MOVE.B  #$7f,$00bfed01
L0000D0C4               BRA.W   game_initialisation                             ; L0000D10C 
                            ;-------------------------------------

level_status        ; original address L0000D0C8 ( > 0 = level completed )
L0000D0C8               dc.w    $0000 


                    ;----------------- return to title screen --------------
return_to_title_screen  ; original address L0000D0CA
L0000D0CA               MOVE.W  #$0064,D0                       ; frames to wait/skip
L0000D0CE               BSR.W   wait_frame                      ; L0000D1EE
L0000D0D2               BSR.W   fade_panel_out                  ; L0000E630
L0000D0D6               JMP     $00000820                       ; loader - load title screen
                    ; ---------------------------------------------
                    ; NEVER RETURNS
                    ;----------------------------------------------



                    ;-------------------- level completed ------------------
level_completed     ; original address L0000D0DC
L0000D0DC               MOVE.W  #$9999,PANEL_TIMER_UPDATE_VALUE     ; $0007c882 ; panel
L0000D0E4               MOVE.L  #BATCAVE_DISPLAY_BUFFER1,display_buffer_ptr1      ; L0000E55A ; external address (display?)
L0000D0EE               MOVE.L  #BATCAVE_DISPLAY_BUFFER2,display_buffer_ptr2      ; L0000E55E ; external address (display?)
L0000D0F8               BSR.W   screen_wipe_to_black                ; L0000E562
L0000D0FC               BSR.W   fade_panel_out                      ; L0000E630
L0000D100               JSR     L00004008                           ; music
L0000D106               JMP     $00000830                           ; loader - load batwing level 4
                    ; ---------------------------------------------
                    ; NEVER RETURNS
                    ;----------------------------------------------




                    ;-------------------- continue game start --------------------
game_initialisation ; original address L0000D10C
L0000D10C               JSR     L00004008                                   ; music
                        ; check game over
L0000D112               BTST.B  #PANEL_ST1_NO_LIVES_LEFT,PANEL_STATUS_1     ; #$0001,$0007c874 ; panel 
L0000D11A               BNE.W   return_to_title_screen                      ; L0000D0CA
                        ; check level completed
L0000D11E               TST.W   level_status                                ; L0000D0C8
L0000D124               BNE.W   level_completed                             ; L0000D0DC
                        ; music init?
L0000D128               JSR     L00004008                                   ; music
                        ; set stack ptr
L0000D12E               LEA.L   stack_memory,a7                             ; L0000EF96,A7

L0000D134               BSR.W   init_display_and_game                       ; L0000D38C
L0000D138               BSR.W   panel_fade_in                               ; L0000E5EA
L0000D13C               BSR.W   display_level_intro_text                    ; L0000E4F2
L0000D140               CLR.W   PANEL_TIMER_UPDATE_VALUE                    ; panel - $0007c882
L0000D146               MOVE.L  #$00000001,D0
L0000D148               BSR.W   init_music_sfx                              ; L0000D26E
L0000D14C               CLR.W   raw_keycode_word                            ; L0000D1E6
                        ; game loop?
                        ; wait for end of frame
L0000D152_loop          MOVE.L  #$00000000,D0                               ; wait end of frame
L0000D154               BSR.W   wait_frame                                  ; L0000D1EE

L0000D158               BSR.W   L0000DC1C
L0000D15C               BSR.W   L0000D56A
L0000D160               JSR     do_keyboard_actions                         ; L0000D222
L0000D166               BTST.B  #PANEL_ST1_TIMER_EXPIRED,PANEL_STATUS_1     ; #$0000,$0007c874               ; panel
L0000D16E               BEQ.B   L0000D152_loop 

L0000D170               BRA.W   L0000D9E6 



                ; ------------ level 1 interrupt handler ------------------
                ; do nothing, unused
                ;
level1_interrupt_handler    ; original address L0000D174
L0000D174               RTE 


                ; ------------ level 2 interrupt handler ------------------
                ; PORTS interrupt
                ;  - reading raw keycodes and twiddling bits on CIAA
                ;  - not the recommended way of reading the keyboard and ack'ing the code, as far as I can see.
                ;
level2_interrupt_handler    ; original address L0000D176
L0000D176               MOVE.B  $00bfec01,L0000D1E7             ; raw key code from keyboard
L0000D180               MOVE.B  $00bfed01,$00bfed01             ; ICR - unless a CIAA interrupt will clear CIA interrupts?
L0000D18A               MOVE.W  #$0808,CUSTOM+INTREQ            ; Clear PORTS | RBF? - $00dff09c
L0000D192               MOVE.B  #$08,$00bfed01                  ; ICR - Clear SP FLAG
L0000D19A               MOVE.B  #$60,$00bfee01                  ; CRA - INMODE=1, SPMODE=1
L0000D1A2               RTE 


                ;-------------- level 3 interrupt handler -----------------
                ; COPER & VERTB interrupts
                ;   - Update Music
                ;   - Update Score Panel
                ;   - CIAA Bit twiddling, maybe a keyboard ack, not the recommended way of reading the keyboard and ack'ing the code, as far as I can see.
                ;
level3_interrupt_handler    ; original address L0000D1A4
L0000D1A4               MOVEM.L D0-D7/A0-A6,-(A7)
L0000D1A8               MOVE.W  #$0020,CUSTOM+INTREQ            ; Clear VERTB interrupt - $00dff09c
L0000D1B0               MOVE.B  $00bfed01,$00bfed01             ; ICR - interrupt control register (reading clears it, msb is set/clear so unless cia interrupt has occurred then it will disable ciaa interrupts)
L0000D1BA               MOVE.B  #$08,$00bfee01                  ; CRA, Set timer A one-shot mode
L0000D1C2               MOVE.B  #$88,$00bfed01                  ; ICR, Set, SP FLAG (Enable SP Interrupt)
L0000D1CA               NOT.W   frame_toggle                    ; Frame Toggle (odd/even frame toggle) - unreferenced by game code
L0000D1D0               JSR     L00004018                       ; music - update
L0000D1D6               JSR     PANEL_UPDATE                    ; panel - update $0007c800
L0000D1DC               MOVEM.L (A7)+,D0-D7/A0-A6
L0000D1E0               RTE 


                ; --------------- level 4 interrupt handler ---------------
                ; unused
                ;
level4_interrupt_handler    ; original address L0000D1E2
L0000D1E2               RTE 


                ; --------------- level 5  interrupt handler ---------------
                ; unused
                ;
level5_interrupt_handler    ; original address L0000D1E4
L0000D1E4               RTE 


                        even
raw_keycode_word
L0000D1E6               dc.b    $00
raw_keycode
L0000D1E7               dc.b    $00                 ; raw keycode.
L0000D1E8               dc.w    $0000 
L0000D1EA               dc.w    $0000

key_down_flag       ; original address L0000D1EC
L0000D1EC               dc.w    $0000


                    ; ------------- wait frame count -------------
                    ; Wait for number of specified frames.
                    ; Contains a dodgy processor loop to wait for beam to end the current raster.
                    ; IN:
                    ;   D0.w = frame count
                    ;
wait_frame          ; original address $0000D1EE
L0000D1EE_loop          CMP.B   #$c1,CUSTOM+VHPOSR       ; $00dff006
L0000D1F6               BNE.B   L0000D1EE_loop 
L0000D1F8               MOVE.W  #$0064,D1
L0000D1FC_loop          DBF.W   D1,L0000D1FC_loop
L0000D200               DBF.W   D0,L0000D1EE_loop
L0000D204               RTS 


                    ; copy word value from (a0)+
                    ; place that word into last word of 2 word struct (a1)+
                    ; e.g
                    ;   - A0 = $1111,$2222,$3333
                    ;   - a1 = xxxx,$1111,xxxx,$2222,xxxx,$3333
                    ;   where xxxx is untouched b this routine
                    ;
                    ; IN:
                    ;   A0 = source data words
                    ;   A1 = dest data structure
                    ;
                    ; OUT:
                    ;   D0.l = $00000001
                    ;
copy_palette_to_copper
L0000D206               MOVE.W  #$000f,D0
L0000D20A               ADDA.L  #$00000002,A1
L0000D20C_loop          MOVE.W  (A0)+,(A1)+
L0000D20E               ADDA.L  #$00000002,A1
L0000D210               DBF.W   D0,L0000D20C_loop 
L0000D214               MOVE.L  #$00000001,D0           ; frames to wait/skip
L0000D216               BRA.W   wait_frame              ; L0000D1EE_loop 

clear_key_down_flag
L0000D21A               CLR.W   key_down_flag          ; L0000D1EC
exit_keyboard_test
L0000D220               RTS 



                ; ------------- do keyboard actions --------------
                ; check key presses and do stuff.
                ; code looks a bit strange, may have to debug this
                ; to see whats going on.
                ;
do_keyboard_actions
L0000D222               BTST.B  #$0000,raw_keycode      ; test key up/down flag - L0000D1E7
L0000D22A               BNE.W   clear_key_down_flag     ; L0000D21A 

L0000D22E               TST.W   key_down_flag           ; L0000D1EC
L0000D234               BNE.W   exit_keyboard_test      ; L0000D220 

L0000D238               CMP.W   #$004c,raw_keycode_word ; L0000D1E6 ; $4c / 2 = $26 ='J' keyboard?
L0000D240               BEQ.W   skip_level              ; L0000D2D8 ; skip level
L0000D244               CMP.W   #$005c,raw_keycode_word ; L0000D1E6 ; $5c / 2 = $2E = '5' keypad? 
L0000D24C               BEQ.W   toggle_music_sfx        ; L0000D260 
L0000D250               CMP.W   #$0074,raw_keycode_word ; L0000D1E6 ; $74 / 2 = $3a = '/' keyboard?
L0000D258               BEQ.W   exit_game               ; L0000D2C2 ; end the game ()
L0000D25C               BRA.W   clear_key_down_flag     ;L0000D21A 
                        ; use rts to return to caller
                        ;---------------------------


                    ; ------------- toggle music/sfx ---------------
toggle_music_sfx    ; original address L0000D260
L0000D260               NOT.W   key_down_flag                               ; L0000D1EC
L0000D266               BCHG.B  #PANEL_ST2_MUSIC_SFX,PANEL_STATUS_2         ; #$0000,$0007c875            ; panel
                        ; fall through to init_music_sfx

                    ;------------ initialise music/sfx -------------
                    ; IN:-
                    ;   D0.l - $00000001
init_music_sfx      ; original address L0000D26E
L0000D26E               BTST.B  #PANEL_ST2_MUSIC_SFX,PANEL_STATUS_2       ; #$0000,$0007c875            ; panel
L0000D276               BEQ.B   L0000D27E 
L0000D278               JMP     L00004004                   ; music - init sfx
                        ; use rts to exit
                        ;------------------------
L0000D27E               MOVE.L  #$00000001,D0               ; Set Song Number to Play
L0000D280               JMP     L00004010                   ; init song -music
                        ; use rts to exit
                        ;-------------------------

L0000D286               CLR.W   key_down_flag              ; L0000D1EC
L0000D28C               RTS 




L0000D28E               MOVE.W  #$9999,PANEL_TIMER_UPDATE_VALUE     ; $0007c882           ; panel
L0000D296               NOT.W   L0000D2C0

L0000D29C               CLR.W   raw_keycode_word                    ; L0000D1E6
L0000D2A2_loop          CMP.W   #$005e,raw_keycode_word             ; L0000D1E6
L0000D2AA               BNE.B   L0000D2A2_loop 

L0000D2AC               CLR.W   raw_keycode_word                    ; L0000D1E6
L0000D2B2               CLR.W   PANEL_TIMER_UPDATE_VALUE            ; $0007c882           ; panel
L0000D2B8               CLR.W   L0000D2C0
L0000D2BE               RTS 



L0000D2C0                dc.w    $0000 


                    ; -------------- no lives left/end level -------------
exit_game
L0000D2C2               MOVE.W  #$9999,PANEL_TIMER_UPDATE_VALUE             ; $0007c882            ; panel
L0000D2CA               BSET.B  #PANEL_ST1_NO_LIVES_LEFT,PANEL_STATUS_1     ; #$0001,$0007c874     ; panel
L0000D2D2               JMP     L0000DA10 

                    ; ------------- skip level -------------
skip_level
L0000D2D8               BTST.B  #PANEL_ST2_CHEAT_ACTIVE,PANEL_STATUS_2      ; #$0007,$0007c875     ;panel
L0000D2E0               BEQ.B   L0000D2EE 
L0000D2E2               NOT.W   level_status                                ; L0000D0C8
L0000D2E8               JMP     L0000DA10
L0000D2EE               RTS 


L0000D2F0               LEA.L   L0000D36C,A0
L0000D2F6               LEA.L   L0000D37C,A1
L0000D2FC               MOVE.W  #$0001,D0
L0000D300               MOVE.L  #$00000000,D1
L0000D302_loop          BSR.W   L0000D344
L0000D306               ADD.W   #$00000001,D1
L0000D308               ADD.W   #$00000001,D0
L0000D30A               CMP.W   #$0009,D0
L0000D30E               BNE.B   L0000D302_loop 
L0000D310               CLR.W   L0000DC0E
L0000D316               RTS 


L0000D318               LEA.L   L0000D36C,A0
L0000D31E               LEA.L   L0000D37C,A1
L0000D324               MOVE.W  L0000D84A,D0
L0000D32A               BSR.W   L0000D33E
L0000D32E               MOVE.W  L0000D848,D0
L0000D334               BSR.W   L0000D33E
L0000D338               MOVE.W  L0000D846,D0
L0000D33E               MOVE.W  D0,D1
L0000D340               SUB.W   #$0001,D1


;L0000D2F0               LEA.L   L0000D36C,A0
;L0000D2F6               LEA.L   L0000D37C,A1
;L0000D2FC               MOVE.W  #$0001,D0
;L0000D300               MOVE.L  #$00000000,D1

L0000D344               ASL.W   #$00000001,D1               ; d1*2 = index
L0000D346               MOVE.W  $00(A0,D1.w),L0000E122
L0000D34E               MOVE.W  $00(A1,D1.w),L0000E126
L0000D356               MOVE.W  D0,L0000E154
L0000D35C               MOVEM.L D0-D1/A0-A1,-(A7)
L0000D360               BSR.W   L0000DE94
L0000D364               MOVEM.L (A7)+,D0-D1/A0-A1
L0000D368               LSR.W   #$00000001,D1
L0000D36A               RTS 


                        ; table of 8 indexes
L0000D36C               dc.w    $001C,$001C,$001C,$001C,$0126,$0126,$0126,$0127
                        ; table of 8 indexes
L0000D37C               dc.w    $0005,$002A,$004E,$0074,$0005,$002A,$004F,$0073  



set_copper_bitplanes    movem.l d0/d1/d7/a0,-(a7)
                        moveq.l #3,d7
.panel_loop             move.w  d0,6(a0)
                        swap    d0
                        move.w  d0,2(a0)
                        swap    d0
                        lea.l   8(a0),a0
                        add.l   d1,d0
                        dbf     d7,.panel_loop
                        movem.l (a7)+,d0/d1/d7/a0
                        rts

                ; -------------- init display and game settings ---------------
                ; Initialise the display, size, palettes etc
                ; Initialise initial game value, timers, energy etc.
                ;
init_display_and_game   ; original address L0000D38C
L0000D38C               MOVE.W  #$4180,CUSTOM+BPLCON0                           ; 4 bitplanes|Genlock?|UHRES? - $00dff100
L0000D394               MOVE.W  #$0040,CUSTOM+BPLCON2                           ; Sprite priority - $00dff104
L0000D39C               MOVE.L  #$003800d0,CUSTOM+DDFSTRT                       ; NTSC Window Settings - $00dff092
L0000D3A6               MOVE.L  #$2c81f4c1,CUSTOM+DIWSTRT                       ; NTSC Window Settings - $00dff08e
L0000D3B0               MOVE.L  #$ffffffff,CUSTOM+BLTAFWM                       ; Blitter 1st & last word mask - $00dff044
L0000D3BA               CLR.L   L0000DBFC
L0000D3C0               CLR.W   L0000DC00
L0000D3C6               CLR.L   L0000DC02
L0000D3CC               CLR.W   L0000EE04
L0000D3D2               MOVE.W  #$0003,L0000DBFA
L0000D3DA               MOVE.W  #$0001,L0000DC06
L0000D3E2               MOVE.W  #$0073,L0000D8D8
L0000D3EA               MOVE.W  #$0006,L0000DC00
L0000D3F2               MOVE.W  #$0018,L0000E124
L0000D3FA               MOVE.W  #$0012,L0000E128

                        ; ------------ additional code - set panel gfx ------------
                        move.l  #PANEL_GFX,D0
                        move.l  #PANEL_DISPLAY_BITPLANEBYTES,d1
                        lea.l   copper_panel_bpl_ptrs,a0
                        bsr     set_copper_bitplanes
                        ; ------------additional code - game display gfx----------
                        move.l  #BATCAVE_DISPLAY_BUFFER1+2,d0
                        move.l  #BATCAVE_BPL_SIZE,d1
                        lea.l   copper_game_bpl_ptrs,a0
                        bsr     set_copper_bitplanes
                        ; --------------------------------------------------------

L0000D402               LEA.L   game_screen_palette,a0                          ; L0000F6CE,A0
L0000D408               LEA.L   copper_screen_palette,A1                        ; L0000FBE6,A1
L0000D40E               BSR.W   copy_palette_to_copper                          ; L0000D206
L0000D412               MOVE.L  #BATCAVE_BPL_SIZE,L0000DC14                     ; Display buffer bitplane size 44*152
L0000D41C               MOVE.L  #BATCAVE_DISPLAY_BUFFER1,display_bitplane_ptr   ; L0000DC18 ; external address (display?)
L0000D426               MOVE.W  #BATCAVE_BPLWIDTH,display_bitplane_width_bytes  ; #$002c,L0000EE00
L0000D42E               BSR.W   init_background_gfx                             ; L0000D4F4
L0000D432               BSR.W   L0000D2F0
L0000D436               BSR.W   L0000D462
                        ; set level timer
L0000D43A               MOVE.W  #BATCAVE_TIMER,D0                               ; BCD Timer Value
L0000D43E               JSR     PANEL_INIT_TIMER                                ; $0007c80e ; panel
L0000D444               MOVE.W  #$9999,PANEL_TIMER_UPDATE_VALUE                 ; $0007c882 ; panel
                        ; set player energy
L0000D44C               JSR     PANEL_INIT_ENERGY                               ; $0007c854 ; panel
L0000D452               CLR.L   L0000D846
L0000D458               CLR.W   L0000D84A
                        ; clear 3 words (match values?)
L0000D45E               BRA.W   L0000E110 
                        ; use rts to return to caller
                        ;------------------------------------


L0000D462               CLR.L   L0000D840
L0000D468               CLR.W   L0000D844
L0000D46E               BSR.W   L0000D48E
L0000D472               MOVE.W  D0,L0000D840
L0000D478               BSR.W   L0000D48E
L0000D47C               MOVE.W  D0,L0000D842
L0000D482               BSR.W   L0000D48E
L0000D486               MOVE.W  D0,L0000D844
L0000D48C               RTS 


L0000D48E               BSR.W   L0000D516
L0000D492               MOVE.W  L0000D54A,D0
L0000D498               AND.W   #$0007,D0
L0000D49C               MOVE.L  #$00000000,D7
L0000D49E               BSR.W   L0000D8F4
L0000D4A2               TST.W   D7
L0000D4A4               BNE.B   L0000D48E 
L0000D4A6               RTS 



                ; ------------ unreferenced code? --------------
                ; some unknown address ranges accessed in here
L0000D4A8               LEA.L   $0001fffa,A0                ; gfx?
L0000D4AE               LEA.L   BATCAVE_DISPLAY_BUFFER1,A1                ; display buffer?
L0000D4B4               LEA.L   $000231d2,A2
L0000D4BA               LEA.L   $00060720,A3
L0000D4C0               LEA.L   $000263aa,A4
L0000D4C6               LEA.L   $00062140,A5
L0000D4CC               MOVE.W  #BATCAVE_BPL_SIZE,D0
L0000D4D0_loop          MOVE.B  (A0)+,(A1)+
L0000D4D2               MOVE.B  (A2)+,(A3)+
L0000D4D4               MOVE.B  (A4)+,(A5)+
L0000D4D6               DBF.W   D0,L0000D4D0_loop 
L0000D4DA               RTS 



                ; ------------ unreferenced code? --------------
                ; some unknown address ranges accessed in here
L0000D4DC               LEA.L   $00019588,A0                ; external address
L0000D4E2               LEA.L   $00063b66,A1                ; external address
L0000D4E8               MOVE.W  #$1a20,D0
L0000D4EC_loop          MOVE.B  (A0)+,(A1)+
L0000D4EE               DBF.W   D0,L0000D4EC_loop 
L0000D4F2               RTS 




                ; ------------ init background gfx -------------
                ; copy main background gfx to display buffer 1
                ; copies 3 bitplanes of gfx to the background buffer (bpl0,1,2)
                ; clears the final bitplane (6692 bytes)
                ; Both the copy loops and clear loop counters are 'off by 1'
                ; copying and clearing 1 too many longwords each.
                ; I've rectified this by subtacting 1 from the loop counters.
                ; Each bitplane = 152 rasters * 44 bytes wide = 6688 ($1a20) bytes
                ; 6688 bytes * 3 bitplanes = 20064 bytes ($4e60)
                ; 6688 bytes * 1 bitplane  = 6688  bytes ($1a20)
                ; loop counter 1 = 20064 / 4 = 5016 ($1398) (minus 1 for dbf = $1397)
                ; loop counter 2 =  6688 / 4 = 1672 ($0688) (minus 1 for dbf = $0687)
init_background_gfx
                        ; copy data $buffer to $buffer+4e64
L0000D4F4               LEA.L   background_gfx,A0                   ; L00010000,A0 ; copy $10000-$14E64 to Display Buffer 1
L0000D4FA               LEA.L   BATCAVE_DISPLAY_BUFFER1,A1          ; external address
L0000D500               MOVE.W  #$1398-1,D0                         ; (5015+1)*4 = 20068 bytes (4e64)
L0000D504_loop          MOVE.L  (A0)+,(A1)+
L0000D506               DBF.W   D0,L0000D504_loop 
                        ; clear mem $buffer+4e64 to $buffer+$6888 
L0000D50A               MOVE.W  #$0688-1,D0                         ; (1671+1)*4 = 6688 bytes (1a20)
L0000D50E_loop          CLR.L   (A1)+                               ; clear 4 bytes
L0000D510               DBF.W   D0,L0000D50E_loop 
L0000D514               RTS 



L0000D516               MOVEM.L D0-D1/A0,-(A7)
L0000D51A               LEA.L   L0000D54C,A0
L0000D520               MOVE.B  $00bfe801,D0
L0000D526               MOVE.B  $00bfe901,D1
L0000D52C               EOR.W   D1,D0
L0000D52E               MOVE.W  D0,D1
L0000D530               AND.W   #$0007,D0
L0000D534               ASL.W   #$00000001,D0
L0000D536               EOR.W   D1,$00(A0,D0.w)
L0000D53A               MOVE.W  $00(A0,D0.w),D0
L0000D53E               MOVE.W  D0,L0000D54A
L0000D544               MOVEM.L (A7)+,D0-D1/A0
L0000D548               RTS 


L0000D54A               dc.w    $1164
L0000D54C               dc.w    $F051,$FFE0,$CF01,$337F,$FEEF,$0506,$0838
L0000D55A               dc.w    $0012



L0000D55C               BTST.B  #$0006,$00dff002
L0000D564               BNE.W   L0000D55C
L0000D568               RTS 



L0000D56A               TST.W   L0000DC02
L0000D570               BEQ.W   L0000D588 
L0000D574               MOVE.W  L0000DC0A,D0
L0000D57A               ADD.W   D0,L0000E128
L0000D580               SUB.W   #$0001,L0000DC02
L0000D588               TST.W   L0000DC04
L0000D58E               BEQ.W   L0000D5A6 
L0000D592               MOVE.W  L0000DC08,D0
L0000D598               ADD.W   D0,L0000E124
L0000D59E               SUB.W   #$0001,L0000DC04
L0000D5A6               RTS 



L0000D5A8               CLR.L   L0000DC10
L0000D5AE               CLR.W   L0000DC0C
L0000D5B4               MOVE.W  $00dff00c,D0
L0000D5BA               BTST.L  #$0001,D0
L0000D5BE               SNE.B   L0000DC10 
L0000D5C4               BTST.L  #$0009,D0
L0000D5C8               SNE.B   L0000DC11 
L0000D5CE               BTST.L  #$0000,D0
L0000D5D2               SNE.B   L0000DC12 
L0000D5D8               BTST.L  #$0008,D0
L0000D5DC               SNE.B   L0000DC13 
L0000D5E2               MOVE.B  L0000DC10,D1
L0000D5E8               EOR.B   D1,L0000DC12
L0000D5EE               MOVE.B  L0000DC11,D1
L0000D5F4               EOR.B   D1,L0000DC13
L0000D5FA               BTST.B  #$0007,$00bfe001
L0000D602               SEQ.B   L0000DC0C 
L0000D608               TST.W   L0000DC04
L0000D60E               BNE.B   L0000D636 
L0000D610               CLR.W   L0000DC08
L0000D616               TST.B   L0000DC10
L0000D61C               BEQ.B   L0000D626 
L0000D61E               MOVE.W  #$000a,L0000DC08
L0000D626               TST.B   L0000DC11
L0000D62C               BEQ.B   L0000D636 
L0000D62E               MOVE.W  #$fff6,L0000DC08
L0000D636               TST.W   L0000DC02
L0000D63C               BNE.B   L0000D664 
L0000D63E               CLR.W   L0000DC0A
L0000D644               TST.B   L0000DC12
L0000D64A               BEQ.B   L0000D654 
L0000D64C               MOVE.W  #$0004,L0000DC0A
L0000D654               TST.B   L0000DC13
L0000D65A               BEQ.B   L0000D664 
L0000D65C               MOVE.W  #$fffc,L0000DC0A
L0000D664               TST.W   L0000DC04
L0000D66A               BNE.B   L0000D6A4 
L0000D66C               TST.W   L0000DC08
L0000D672               BEQ.B   L0000D6A4 
L0000D674               BPL.W   L0000D690 
L0000D678               CMP.W   #$0080,L0000E124
L0000D680               BLT.W   L0000D6A4 
L0000D684               MOVE.W  #$001b,L0000DC04
L0000D68C               BRA.W   L0000D6A4 

L0000D690               CMP.W   #$0080,L0000E124
L0000D698               BGT.W   L0000D6A4 
L0000D69C               MOVE.W  #$001b,L0000DC04
L0000D6A4               TST.W   L0000DC02
L0000D6AA               BNE.B   L0000D6EE 
L0000D6AC               TST.W   L0000DC0A
L0000D6B2               BEQ.B   L0000D6EE 
L0000D6B4               BPL.W   L0000D6D0 
L0000D6B8               CMP.W   #$0020,L0000E128
L0000D6C0               BLT.W   L0000D6EE 
L0000D6C4               SUB.W   #$0001,L0000DC06
L0000D6CC               BRA.W   L0000D6E4 

L0000D6D0               CMP.W   #$0071,L0000E128
L0000D6D8               BGT.W   L0000D6EE 
L0000D6DC               ADD.W   #$0001,L0000DC06
L0000D6E4               MOVE.W  #$0009,L0000DC02
L0000D6EC               RTS 




L0000D6EE               MOVE.W  L0000DC08,D0
L0000D6F4               OR.W    L0000DC0A,D0
L0000D6FA               OR.W    L0000DC04,D0
L0000D700               OR.W    L0000DC02,D0
L0000D706               BNE.W   L0000DBA4 
L0000D70A               TST.W   L0000DC0C
L0000D710               BEQ.W   L0000DBEA 
L0000D714               TST.W   L0000DC0E
L0000D71A               BNE.W   L0000DBA4 
L0000D71E               LEA.L   L0000D846,A2
L0000D724               LEA.L   L0000D7EC,A0
L0000D72A               LEA.L   L0000D816,A1
L0000D730               MOVE.W  L0000DBFC,D2
L0000D736               MOVE.W  L0000DBFE,D1
L0000D73C               BSR.W   L0000D84C
L0000D740               MOVE.L  #$00000000,D7
L0000D742               MOVE.W  L0000E154,D0
L0000D748               BSR.W   L0000D912
L0000D74C               TST.W   D7
L0000D74E               BNE.W   L0000D7EA 
L0000D752               MOVE.W  L0000E154,$00(A2,D1.w)
L0000D75A               MOVE.W  $00(A0,D2.w),L0000E122
L0000D762               MOVE.W  $00(A1,D2.w),L0000E126
L0000D76A               BSR.W   L0000DE94
L0000D76E               MOVE.L  #$00000005,D0
L0000D770               JSR     L00004014
L0000D776               BSR.W   L0000DBA6
L0000D77A               SUB.W   #$0001,L0000DBFA
L0000D782               BNE.W   L0000D7D4 
L0000D786               BSR.W   L0000D86A
L0000D78A               CMP.B   #$33,L0000D8D6          ; display char
L0000D792               BNE.B   L0000D798 
L0000D794               BRA.W   L0000D930 


L0000D798               MOVE.L  #$00000006,D0
L0000D79A               JSR     L00004014
L0000D7A0               SUB.W   #$0001,L0000DC00
L0000D7A8               BPL.W   L0000D7B0 
L0000D7AC               BRA.W   L0000D9E6 


L0000D7B0               MOVE.L  #$00000006,D0
L0000D7B2               JSR     PANEL_LOSE_ENERGY       ; $0007c870 ; Panel
L0000D7B8               MOVE.W  #$0003,L0000DBFA
L0000D7C0               MOVE.W  #$fffe,L0000DBFE
L0000D7C8               CLR.L   L0000D846
L0000D7CE               CLR.W   L0000D84A
L0000D7D4               NOT.W   L0000DC0E
L0000D7DA               ADD.W   #$0002,L0000DBFC
L0000D7E2               ADD.W   #$0002,L0000DBFE
L0000D7EA               RTS 



L0000D7EC               dc.w    $0068,$0068,$0068,$007B,$007B,$007B,$008E,$008E
L0000D7FC               dc.w    $008E,$00A1,$00A1,$00A1,$00B4,$00B4,$00B4,$00C7
L0000D80C               dc.w    $00C7,$00C7,$00DA,$00DA,$00DA

L0000D816               dc.w    $0013,$0031,$004F
L0000D81C               dc.w    $0013,$0031,$004F,$0013,$0031,$004F,$0013,$0031
L0000D82C               dc.w    $004F,$0013,$0031,$004F,$0013,$0031,$004F,$0013
L0000D83C               dc.w    $0031,$004F
L0000D840               dc.w    $0001
L0000D842               dc.w    $0002
L0000D844               dc.w    $0003
L0000D846               dc.w    $0000
L0000D848               dc.w    $0000
L0000D84A               dc.w    $0000




L0000D84C               MOVE.W  L0000DC06,L0000E154
L0000D856               CMP.W   #$0080,L0000E124
L0000D85E               BLT.B   L0000D868 
L0000D860               ADD.W   #$0004,L0000E154
L0000D868               RTS 



L0000D86A               BSR.W   L0000D318
L0000D86E               CLR.W   L0000DC0E
L0000D874               MOVE.B  #$30,D7
L0000D878               BSR.W   L0000D8DA
L0000D87C               MOVE.B  D7,L0000D8D6            ; display char
L0000D882               MOVE.L  #$00000000,D0
L0000D884               MOVE.B  D7,D0
L0000D886               SUB.B   #$30,D0
L0000D88A               ASL.L   #$00000008,D0
L0000D88C               JSR     PANEL_ADD_SCORE         ; $0007c82a ; Panel
L0000D892               NOT.W   L0000EE04
L0000D898               MOVE.L  #debug_typer_buffer,debug_display_buffer_ptr     ; #L0000F68E,L0000EDFC
L0000D8A2               LEA.L   L0000D8D4,A6
L0000D8A8               BSR.W   debug_text_typer        ; L0000E382 
L0000D8AC               MOVE.W  #$0009,L0000E154
L0000D8B4               MOVE.W  L0000D8D8,L0000E122
L0000D8BE               MOVE.W  #$006e,L0000E126
L0000D8C6               BSR.W   L0000DE94
L0000D8CA               ADD.W   #$0013,L0000D8D8
L0000D8D2               RTS 

                        ; display characters (x,y,char,$ff)
L0000D8D4               dc.w    $0000
L0000D8D6               dc.w    $30ff
L0000D8D8               dc.w    $0073 


L0000D8DA               MOVE.W  L0000D846,D0
L0000D8E0               BSR.W   L0000D8F4
L0000D8E4               MOVE.W  L0000D848,D0
L0000D8EA               BSR.W   L0000D8F4
L0000D8EE               MOVE.W  L0000D84A,D0
L0000D8F4               CMP.W   L0000D840,D0
L0000D8FA               BEQ.B   L0000D90E 
L0000D8FC               CMP.W   L0000D842,D0
L0000D902               BEQ.B   L0000D90E 
L0000D904               CMP.W   L0000D844,D0
L0000D90A               BEQ.B   L0000D90E 
L0000D90C               RTS 


L0000D90E               ADD.W   #$00000001,D7
L0000D910               RTS 


L0000D912               CMP.W   L0000D846,D0
L0000D918               BEQ.B   L0000D92C 
L0000D91A               CMP.W   L0000D848,D0
L0000D920               BEQ.B   L0000D92C 
L0000D922               CMP.W   L0000D84A,D0
L0000D928               BEQ.B   L0000D92C 
L0000D92A               RTS 
L0000D92C               ADD.W   #$00000001,D7
L0000D92E               RTS 


L0000D930               MOVE.W  #$000d,D3
L0000D934               BSR.W   L0000DAAA
L0000D938               MOVE.L  #$00000002,D0
L0000D93A               JSR     L00004010
L0000D940               MOVE.L  #$00000000,D0
L0000D942               MOVE.W  PANEL_TIMER_VALUE,D0                ; $0007c884,D0 ; Panel
L0000D948               ASL.L   #$00000008,D0
L0000D94A               ASL.L   #$00000004,D0
L0000D94C               JSR     PANEL_ADD_SCORE                     ; $0007c82a ; Panel
L0000D952               MOVE.W  #$ffff,level_status                 ; L0000D0C8 - level completed

L0000D95A               MOVE.W  #$9999,PANEL_TIMER_UPDATE_VALUE     ; $0007c882 ; Panel
L0000D962               MOVE.W  #$00c8,D0                           ; frames to wait/skip
L0000D966               BSR.W   wait_frame                          ; L0000D1EE_loop
L0000D96A               MOVE.W  #$2260,D0
L0000D96E               LEA.L   BATCAVE_DISPLAY_BUFFER2,A0                        ; external address
L0000D974               CLR.L   (A0)+
L0000D976               DBF.W   D0,L0000D974 
L0000D97A               MOVE.L  #BATCAVE_DISPLAY_BUFFER2,display_buffer_ptr2      ; L0000E55E ; external address
L0000D984               LEA.L   text_simlex_success,a0              ; L0000E680,A0
L0000D98A               BSR.W   game_text_typer                     ; L0000E6E4
L0000D98E               MOVE.L  #BATCAVE_DISPLAY_BUFFER1,display_buffer_ptr1      ; L0000E55A ; external address
L0000D998               MOVE.L  #BATCAVE_DISPLAY_BUFFER2,display_buffer_ptr2      ; L0000E55E ; external address
L0000D9A2               BSR.W   screen_wipe_to_backbuffer           ; L0000E572
L0000D9A6               MOVE.W  #$00c8,D0                           ; frames to wait/skip
L0000D9AA               BSR.W   wait_frame                  
L0000D9AE               MOVE.L  #BATCAVE_DISPLAY_BUFFER1,display_buffer_ptr1      ; L0000E55A ; external address
L0000D9B8               MOVE.L  #BATCAVE_DISPLAY_BUFFER2,display_buffer_ptr2      ; L0000E55E ; external address
L0000D9C2               BSR.W   screen_wipe_to_black                ; L0000E562
L0000D9C6               LEA.L   game_screen_palette,A0              ; L0000F6CE,A0
L0000D9CC               LEA.L   copper_screen_palette,a1            ; L0000FBE6,A1
L0000D9D2               BSR.W   copy_palette_to_copper              ; L0000D206
L0000D9D6               BRA.W   L0000D112 


L0000D9DA               MOVE.W  #$0001,level_status     ; L0000D0C8 - level completed
L0000D9E2               BRA.W   L0000DA00 


L0000D9E6               MOVE.W  #$0080,D0
L0000D9EA               JSR     PANEL_LOSE_ENERGY       ; $0007c870 ; Panel
L0000D9F0               MOVE.W  #$000b,D3
L0000D9F4               BSR.W   L0000DAAA
L0000D9F8               MOVE.L  #$00000003,D0
L0000D9FA               JSR     L00004010
L0000DA00               MOVE.W  #$9999,PANEL_TIMER_UPDATE_VALUE     ; $0007c882 ; Panel
L0000DA08               MOVE.W  #$00c8,D0               ; frames to wait/skip
L0000DA0C               BSR.W   wait_frame              ; L0000D1EE_loop

L0000DA10               MOVE.W  #$2260,D0
L0000DA14               LEA.L   BATCAVE_DISPLAY_BUFFER2,A0            ; External Address
L0000DA1A               CLR.L   (A0)+
L0000DA1C               DBF.W   D0,L0000DA1A 
L0000DA20               MOVE.L  #BATCAVE_DISPLAY_BUFFER2,display_buffer_ptr2              ; L0000E55E    ; external address
L0000DA2A               BTST.B  #PANEL_ST1_TIMER_EXPIRED,PANEL_STATUS_1     ; #$0000,$0007c874        ; Panel
L0000DA32               BNE.B   L0000DA54 
L0000DA34               BTST.B  #PANEL_ST1_NO_LIVES_LEFT,PANEL_STATUS_1     ; #$0001,$0007c874        ; Panel
L0000DA3C               BNE.B   L0000DA42 
L0000DA3E               BRA.W   L0000DA7E 

L0000DA42               MOVE.L  #$00000004,D0
L0000DA44               JSR     L00004010                   ; Panel
L0000DA4A               LEA.L   text_game_over,a0           ; L0000E6D6,A0
L0000DA50               BRA.W   L0000DA5A 


L0000DA54               LEA.L   text_time_out,a0                ; L0000E6CA,A0
L0000DA5A               BSR.W   game_text_typer                 ; L0000E6E4
L0000DA5E               MOVE.L  #BATCAVE_DISPLAY_BUFFER1,display_buffer_ptr1  ; L0000E55A ; external address
L0000DA68               MOVE.L  #BATCAVE_DISPLAY_BUFFER2,display_buffer_ptr2  ; L0000E55E ; external address
L0000DA72               BSR.W   screen_wipe_to_backbuffer       ; L0000E572
L0000DA76               MOVE.W  #$00c8,D0                       ; frames to wait/skip
L0000DA7A               BSR.W   wait_frame                      ; L0000D1EE_loop
L0000DA7E               MOVE.L  #BATCAVE_DISPLAY_BUFFER1,display_buffer_ptr1  ; L0000E55A        ; external address
L0000DA88               MOVE.L  #BATCAVE_DISPLAY_BUFFER2,display_buffer_ptr2  ; L0000E55E        ; external address
L0000DA92               BSR.W   screen_wipe_to_black            ; L0000E562
L0000DA96               LEA.L   game_screen_palette,A0          ; L0000F6CE,A0
L0000DA9C               LEA.L   copper_screen_palette,A1        ; L0000FBE6,A1
L0000DAA2               BSR.W   copy_palette_to_copper          ; L0000D206
L0000DAA6               BRA.W   L0000D112 


L0000DAAA               MOVE.W  #$9999,PANEL_TIMER_UPDATE_VALUE     ; $0007c882 ; Panel
L0000DAB2               BSR.W   L0000E110
L0000DAB6               MOVE.W  #$0025,D0               ; frames to wait/skip
L0000DABA               BSR.W   wait_frame              ; L0000D1EE_loop
L0000DABE               BSR.W   init_background_gfx     ; L0000D4F4
L0000DAC2               LEA.L   L0000D36C,A0
L0000DAC8               LEA.L   L0000DB52,A1
L0000DACE               MOVE.L  #$00000000,D2
L0000DAD0               MOVE.W  #$0005,D0               ; frames to wait/skip
L0000DAD4               BSR.W   wait_frame              ; L0000D1EE_loop
L0000DAD8               BSR.W   L0000DB2E
L0000DADC               ADD.W   #$00000002,D2
L0000DADE               CMP.W   #$0012,D2
L0000DAE2               BNE.B   L0000DAD0 
L0000DAE4               MOVE.W  #$0004,D0               ; frames to wait/skip
L0000DAE8               BSR.W   wait_frame              ; L0000D1EE_loop
L0000DAEC               ADD.W   #$0001,D3
L0000DAF0               CMP.W   #$000c,D3
L0000DAF4               BNE.B   L0000DB0A 
L0000DAF6               MOVE.W  #$008e,L0000E122
L0000DAFE               MOVE.W  #$0010,L0000E126
L0000DB06               BRA.W   L0000DB1A 


L0000DB0A               MOVE.W  #$007d,L0000E122
L0000DB12               MOVE.W  #$002d,L0000E126
L0000DB1A               MOVE.W  D3,L0000E154
L0000DB20               BSR.W   L0000DE94
L0000DB24               RTS 


L0000DB26               MOVE.W  #$0060,D0               ; frames to wait/skip
L0000DB2A               BRA.W   wait_frame              ; L0000D1EE_loop 
L0000DB2E               MOVE.W  $00(A0,D2.w),L0000E122
L0000DB36               MOVE.W  $00(A1,D2.w),L0000E126
L0000DB3E               MOVE.W  D3,L0000E154
L0000DB44               MOVEM.L D2-D3/A0-A1,-(A7)
L0000DB48               BSR.W   L0000DE94
L0000DB4C               MOVEM.L (A7)+,D2-D3/A0-A1
L0000DB50               RTS


L0000DB52               dc.w    $0005,$002A,$004E,$0074,$0073,$004F,$002A,$0005
L0000DB62               dc.w    $3039,$0000,$DC06


L0000DB68               MOVE.W  D0,D1
L0000DB6A               LEA.L   L0000DBF2,A0
L0000DB70               ADD.W   D0,D0
L0000DB72               MOVE.W  -2(A0,D0.W),L0000E126
L0000DB7A               MOVE.W  L0000E124,L0000E122
L0000DB84               ADD.W   #$0003,L0000E122
L0000DB8C               CMP.W   #$0080,L0000E124
L0000DB94               BLT.W   L0000DB9A 
L0000DB98               ADD.W   #$00000004,D1
L0000DB9A               MOVE.W  D1,L0000E154
L0000DBA0               BSR.W   L0000DE94
L0000DBA4               RTS 


L0000DBA6               MOVE.W  L0000DC06,D0
L0000DBAC               MOVE.W  D0,D1
L0000DBAE               LEA.L   L0000DBF2,A0
L0000DBB4               ADD.W   D0,D0
L0000DBB6               MOVE.W  -2(A0,D0.w),L0000E126
L0000DBBE               MOVE.W  L0000E124,L0000E122
L0000DBC8               ADD.W   #$0001,L0000E122
L0000DBD0               CMP.W   #$0080,L0000E124
L0000DBD8               BLT.W   L0000DBDE 
L0000DBDC               ADD.W   #$00000004,D1
L0000DBDE               MOVE.W  #$000a,L0000E154
L0000DBE6               BRA.W   L0000DE94 
L0000DBEA               CLR.W   L0000DC0E
L0000DBF0               RTS 


L0000DBF2               dc.w    $0005,$002A,$004F,$0074
L0000DBFA               dc.w    $0003
L0000DBFC               dc.w    $0000
L0000DBFE               dc.w    $0000
L0000DC00               dc.w    $0000
L0000DC02               dc.w    $0000
L0000DC04               dc.w    $0000
L0000DC06               dc.w    $0001
L0000DC08               dc.w    $0000
L0000DC0A               dc.w    $0000
L0000DC0C               dc.w    $0000
L0000DC0E               dc.w    $0000
L0000DC10               dc.b    $00
L0000DC11               dc.b    $00
L0000DC12               dc.b    $00
L0000DC13               dc.b    $00
display_bitplane_size   ; original address L0000DC14
L0000DC14               dc.l    $00000000
display_bitplane_ptr    ; original address L0000DC18
L0000DC18               dc.l    $00000000


L0000DC1C               MOVE.L  #BATCAVE_BPL_SIZE,display_bitplane_size   
L0000DC26               MOVE.L  #BATCAVE_DISPLAY_BUFFER1,display_bitplane_ptr       ; L0000DC18       
L0000DC30               MOVE.W  #BATCAVE_BPLWIDTH,display_bitplane_width_bytes      ; #$002c,L0000EE00
L0000DC38               BSR.W   L0000DC46
L0000DC3C               BSR.W   L0000D5A8
L0000DC40               BSR.W   L0000DCDE
L0000DC44               RTS 




L0000DC46               LEA.L   L0000E13E,A1
L0000DC4C               LEA.L   L0000E146,A2
L0000DC52               LEA.L   L0000E132,A3
L0000DC58               LEA.L   L0000E14C,A4
L0000DC5E               LEA.L   L0000E152,A5
L0000DC64               CLR.W   L0000E142
L0000DC6A               CLR.L   L0000E136
L0000DC70               BSR.W   L0000D55C
L0000DC74               CLR.W   $00dff042
L0000DC7A               MOVE.W  #$09f0,$00dff040
L0000DC82               MOVE.W  #$0002,D7
L0000DC86_loop          MOVE.L  (A1),D2
L0000DC88               BEQ.W   L0000DCCE 
L0000DC8C               MOVE.W  (A2),D0
L0000DC8E               BEQ.B   L0000DCCE 
L0000DC90               MOVE.W  D0,D1
L0000DC92               AND.W   #$003f,D0
L0000DC96               ASL.W   #$00000001,D0
L0000DC98               LSR.W   #$00000006,D1
L0000DC9A               MULU.W  D1,D0
L0000DC9C               MOVE.L  (A3),D3
L0000DC9E               MOVE.L  #$00000003,D6
L0000DCA0_loop          BSR.W   L0000D55C
L0000DCA4               MOVE.L  D2,$00dff054
L0000DCAA               MOVE.L  D3,$00dff050
L0000DCB0               MOVE.W  (A4),$00dff066
L0000DCB6               MOVE.W  (A5),$00dff064
L0000DCBC               MOVE.W  (A2),$00dff058
L0000DCC2               ADD.L   D0,D3
L0000DCC4               ADD.L   L0000DC14,D2
L0000DCCA               DBF.W   D6,L0000DCA0_loop 
L0000DCCE               SUBA.L  #$00000004,A1
L0000DCD0               SUBA.L  #$00000002,A2
L0000DCD2               SUBA.L  #$00000004,A3
L0000DCD4               SUBA.L  #$00000002,A4
L0000DCD6               SUBA.L  #$00000002,A5
L0000DCD8               DBF.W   D7,L0000DC86_loop 
L0000DCDC               RTS 


L0000DCDE               BSR.W   L0000E110
L0000DCE2               MOVE.L  #$00073000,L0000E2C0        ; external address?
L0000DCEC               LEA.L   L0000E122,A0
L0000DCF2               LEA.L   L0000E136,A1
L0000DCF8               LEA.L   L0000E142,A2
L0000DCFE               LEA.L   L0000E12A,A3
L0000DD04               LEA.L   L0000E148,A4
L0000DD0A               LEA.L   L0000E14E,A5
L0000DD10               LEA.L   L0000E154,A6
L0000DD16               MOVE.W  #$0001,D7
L0000DD1A_loop          CLR.L   L0000E2E2
L0000DD20               CMP.W   #$0001,D7
L0000DD24               BEQ.W   L0000DE80 
L0000DD28               BSR.W   L0000DFB2
L0000DD2C               TST.W   (A2)
L0000DD2E               BEQ.W   L0000DE80 
L0000DD32               BSR.W   L0000D55C
L0000DD36               MOVE.W  #$09f0,$00dff040
L0000DD3E               CLR.W   $00dff066
L0000DD44               MOVE.W  (A4),$00dff064
L0000DD4A               MOVE.L  L0000E2C0,(A3)
L0000DD50               MOVE.L  L0000E2E2,D0
L0000DD56               BEQ.W   L0000DE80 
L0000DD5A               MOVE.L  D0,(A1)
L0000DD5C               MOVE.L  L0000E2CA,D2
L0000DD62               MOVE.L  #$00000003,D6
L0000DD64               BSR.W   L0000D55C
L0000DD68               MOVE.L  L0000E2C0,$00dff054
L0000DD72               MOVE.L  D0,$00dff050
L0000DD78               MOVE.W  (A2),$00dff058
L0000DD7E               ADD.L   D2,L0000E2C0
L0000DD84               ADD.L   L0000DC14,D0
L0000DD8A               DBF.W   D6,L0000DD64 
L0000DD8E               MOVE.W  #$0fca,D1
L0000DD92               OR.W    L0000E2E8,D1
L0000DD98               BSR.W   L0000D55C
L0000DD9C               MOVE.W  D1,$00dff040
L0000DDA2               MOVE.W  L0000E2E8,$00dff042
L0000DDAC               MOVE.L  L0000E2E2,D0
L0000DDB2               MOVE.L  L0000E2CE,$00dff04c
L0000DDBC               MOVE.L  L0000E2DE,$00dff050
L0000DDC6               MOVE.L  D0,$00dff048
L0000DDCC               MOVE.L  D0,$00dff054
L0000DDD2               CLR.W   $00dff064
L0000DDD8               CLR.W   $00dff062
L0000DDDE               MOVE.W  (A4),$00dff060
L0000DDE4               MOVE.W  (A4),$00dff066
L0000DDEA               MOVE.W  (A2),$00dff058
L0000DDF0               ADD.L   L0000DC14,D0
L0000DDF6               BSR.W   L0000D55C
L0000DDFA               MOVE.L  L0000E2D2,$00dff04c
L0000DE04               MOVE.L  L0000E2DE,$00dff050
L0000DE0E               MOVE.L  D0,$00dff048
L0000DE14               MOVE.L  D0,$00dff054
L0000DE1A_loop          MOVE.W  (A2),$00dff058
L0000DE20               ADD.L   L0000DC14,D0
L0000DE26               BSR.W   L0000D55C
L0000DE2A               MOVE.L  L0000E2D6,$00dff04c
L0000DE34               MOVE.L  L0000E2DE,$00dff050
L0000DE3E               MOVE.L  D0,$00dff048
L0000DE44               MOVE.L  D0,$00dff054
L0000DE4A               MOVE.W  (A2),$00dff058
L0000DE50               ADD.L   L0000DC14,D0
L0000DE56               BSR.W   L0000D55C
L0000DE5A               MOVE.L  L0000E2DA,$00dff04c
L0000DE64               MOVE.L  L0000E2DE,$00dff050
L0000DE6E               MOVE.L  D0,$00dff048
L0000DE74               MOVE.L  D0,$00dff054
L0000DE7A               MOVE.W  (A2),$00dff058
L0000DE80               ADDA.L  #$00000002,A0
L0000DE82               ADDA.L  #$00000004,A1
L0000DE84               ADDA.L  #$00000002,A2
L0000DE86               ADDA.L  #$00000004,A3
L0000DE88               ADDA.L  #$00000002,A4
L0000DE8A               ADDA.L  #$00000002,A5
L0000DE8C               ADDA.L  #$00000002,A6
L0000DE8E               DBF.W   D7,L0000DD1A_loop 
L0000DE92               RTS 


            ; ----------- blitting some shit ------------

L0000DE94               LEA.L   L0000E122,A0
L0000DE9A               LEA.L   L0000E142,A2
L0000DEA0               LEA.L   L0000E12A,A3
L0000DEA6               LEA.L   L0000E148,A4
L0000DEAC               LEA.L   L0000E14E,A5            ; ptr to word - bitplane width in bytes
L0000DEB2               LEA.L   L0000E154,A6            ; ptr to word - index to object to blit?
L0000DEB8               MOVE.L  #$00000000,D7
L0000DEBA               BSR.W   L0000DFB2

L0000DEBE               MOVE.W  #$0fca,D1               ; minterms $ca = cookie cutter
                                    ; Channel A = Mask
                                    ; Channel B = GFX
                                    ; Channel C = Dest
                                    ; Channel D = Dest

L0000DEC2               OR.W    L0000E2E8,D1
L0000DEC8               MOVE.W  D1,$00dff040
L0000DECE               MOVE.W  L0000E2E8,$00dff042
L0000DED8               MOVE.L  L0000E2E2,D0
L0000DEDE               BEQ.W   L0000DE92 
L0000DEE2               MOVE.L  L0000E2CE,$00dff04c
L0000DEEC               MOVE.L  L0000E2DE,$00dff050
L0000DEF6               MOVE.L  D0,$00dff048
L0000DEFC               MOVE.L  D0,$00dff054
L0000DF02               CLR.W   $00dff064
L0000DF08               CLR.W   $00dff062
L0000DF0E               MOVE.W  (A4),$00dff060
L0000DF14               MOVE.W  (A4),$00dff066
L0000DF1A               MOVE.W  (A2),$00dff058
L0000DF20               ADD.L   L0000DC14,D0
L0000DF26               BSR.W   L0000D55C
L0000DF2A               MOVE.L  L0000E2D2,$00dff04c
L0000DF34               MOVE.L  L0000E2DE,$00dff050
L0000DF3E               MOVE.L  D0,$00dff048
L0000DF44               MOVE.L  D0,$00dff054
L0000DF4A               MOVE.W  (A2),$00dff058
L0000DF50               ADD.L   L0000DC14,D0
L0000DF56               BSR.W   L0000D55C
L0000DF5A               MOVE.L  L0000E2D6,$00dff04c
L0000DF64               MOVE.L  L0000E2DE,$00dff050
L0000DF6E               MOVE.L  D0,$00dff048
L0000DF74               MOVE.L  D0,$00dff054
L0000DF7A               MOVE.W  (A2),$00dff058
L0000DF80               ADD.L   L0000DC14,D0
L0000DF86               BSR.W   L0000D55C
L0000DF8A               MOVE.L  L0000E2DA,$00dff04c
L0000DF94               MOVE.L  L0000E2DE,$00dff050
L0000DF9E               MOVE.L  D0,$00dff048
L0000DFA4               MOVE.L  D0,$00dff054
L0000DFAA               MOVE.W  (A2),$00dff058
L0000DFB0               RTS 


                        ; A6 = ptr to object index
L0000DFB2               MOVE.L  #$00000000,D0
L0000DFB4               MOVE.W  display_bitplane_width_bytes,(A4)           ; L0000EE00,(A4)
L0000DFBA               MOVEM.L A0,-(A7)
L0000DFBE               MOVE.W (A6),D0
L0000DFC0               MULU.W  #$0018,D0               ; d0 = index * 24 - structure size
L0000DFC4               LEA.L   L0000E158,A0            ; 24 bytes struct (6 longs)
L0000DFCA               MOVE.L  $00(A0,D0.l),L0000E2C6
L0000DFD2               MOVE.L  $04(A0,D0.l),L0000E2CE
L0000DFDA               MOVE.L  $08(A0,D0.l),L0000E2D2
L0000DFE2               MOVE.L  $0c(A0,D0.l),L0000E2D6
L0000DFEA               MOVE.L  $10(A0,D0.l),L0000E2DA
L0000DFF2               MOVE.L  $14(A0,D0.l),L0000E2DE
L0000DFFA               MOVEM.L (A7)+,A0
L0000DFFE               MOVE.W  (A0),D0
L0000E000               MOVE.W  D0,D2
L0000E002               AND.W   #$000f,D2
L0000E006               LSR.W   #$00000003,D0
L0000E008               MOVE.W  $0004(A0),D1
L0000E00C               ADD.W   #$0100,D1
L0000E010               EXT.W   D0
L0000E012               ADD.W   #$0100,D0
L0000E016               MOVE.W  L0000E2C8,D4
L0000E01C               MOVE.W  D1,D3
L0000E01E               CMP.W   #$0197,D3
L0000E022               BGT.W   L0000E03A 
L0000E026               ADD.W   D4,D3
L0000E028               CMP.W   #$0197,D3
L0000E02C               BLT.W   L0000E042 
L0000E030               SUB.W   #$0197,D3
L0000E034               SUB.W   D3,D4
L0000E036               BEQ.B   L0000E03A 
L0000E038               BPL.B   L0000E042 
L0000E03A               CLR.L   L0000E2E2
L0000E040               RTS 



L0000E042               CMP.W   #$0100,D1
L0000E046               BGT.W   L0000E08C 
L0000E04A               MOVE.W  D1,D3
L0000E04C               ADD.W   D4,D3
L0000E04E               SUB.W   #$0100,D3
L0000E052               BMI.W   L0000E03A 
L0000E056               MOVE.W  D3,D4
L0000E058               BEQ.W   L0000E03A 
L0000E05C               SUB.W   L0000E2C8,D3
L0000E062               NEG.W   D3
L0000E064               MULU.W  L0000E2C6,D3
L0000E06A               ADD.L   D3,L0000E2CE
L0000E070               ADD.L   D3,L0000E2D2
L0000E076               ADD.L   D3,L0000E2D6
L0000E07C               ADD.L   D3,L0000E2DA
L0000E082               ADD.L   D3,L0000E2DE
L0000E088               MOVE.W  #$0100,D1
L0000E08C               CLR.W   (A5)
L0000E08E               CMP.W   #$0130,D0
L0000E092               BGT.W   L0000E03A 
L0000E096               CMP.W   #$0100,D0
L0000E09A               BGT.W   L0000E0AE 
L0000E09E               MOVE.W  D0,D3
L0000E0A0               SUB.W   #$0100,D3
L0000E0A4               BMI.W   L0000E03A 
L0000E0A8               NOP 
L0000E0AA               MOVE.W  #$0100,D0
L0000E0AE               MOVE.W  D0,D3
L0000E0B0               ADD.W   L0000E2C6,D3
L0000E0B6               CMP.W   #$0130,D3
L0000E0BA               BLT.W   L0000E0C2 
L0000E0BE               BRA.W   L0000E03A 


L0000E0C2               MOVE.W  L0000E2C6,D6
L0000E0C8               SUB.W   D6,(A4)
L0000E0CA               SUB.W   #$0100,D0
L0000E0CE               SUB.W   #$0100,D1
L0000E0D2               MULU.W  display_bitplane_width_bytes,D1     ; L0000EE00,D1
L0000E0D8               ADD.L   D1,D0
L0000E0DA               MOVE.L  display_bitplane_ptr,D1             ; L0000DC18,D1
L0000E0E0               ADD.L   D0,D1
L0000E0E2               MOVE.L  D1,L0000E2E2
L0000E0E8               ASL.W   #$00000008,D2
L0000E0EA               ASL.W   #$00000004,D2
L0000E0EC               MOVE.W  D2,L0000E2E8
L0000E0F2               MOVE.W  L0000E2C6,D5
L0000E0F8               MULU.W  D4,D5
L0000E0FA               MOVE.L  D5,L0000E2CA
L0000E100               MOVE.W  L0000E2C6,D5
L0000E106               LSR.W   #$00000001,D5
L0000E108               ASL.W   #$00000006,D4
L0000E10A               OR.W    D4,D5
L0000E10C               MOVE.W  D5,(A2)
L0000E10E               RTS 


                    ; ------ clear 3 words @ $E142 -----
L0000E110               LEA.L   L0000E142,A0
L0000E116               MOVE.W  #$0002,D7
L0000E11A_loop          CLR.W   (A0)+
L0000E11C               DBF.W   D7,L0000E11A_loop 
L0000E120               RTS 



L0000E122               dc.w    $0000
L0000E124               dc.w    $0018
L0000E126               dc.w    $0000
L0000E128               dc.w    $0012

L0000E12A               dc.w    $0000,$0000
L0000E12E               dc.w    $0000,$0000
L0000E132               dc.w    $0000,$0000
L0000E136               dc.w    $0000,$0000,$0000,$0000
L0000E13E               dc.w    $0000,$0000

L0000E142               dc.w    $0000,$0000
L0000E146               dc.w    $0000

L0000E148               dc.w    $0000,$0000
L0000E14C               dc.w    $0000
L0000E14E               dc.w    $0000,$0000
L0000E152               dc.w    $0000
L0000E154               dc.w    $0000,$0000

                        ; ; 24 bytes struct (6 longs)
                        ; maybe something
                        ; width (bytes) x height lines
                        ; bpl0
                        ; bpl1
                        ; bpl2
                        ; bpl3
                        ; bpl4
                        ; mask 
L0000E158               dc.l    $00080055               ; object 1 (maybe widthxheight 4 bytes x 85 lines)
                        dc.l    L000164C0               ; address ptr?
                        dc.l    L00016770               ; address ptr?
                        dc.l    L00016A20               ; address ptr?
                        dc.l    L00016CD0               ; address ptr?
                        dc.l    L00016F80               ; address ptr?          

L0000E170               dc.l    $0006001E               ; object 2
                        dc.l    L00014E40
                        dc.l    L00014EF4
                        dc.l    L00014FA8
                        dc.l    L0001505C
                        dc.l    L0000F5DA
                        
                        dc.l    $0006001E               ; object 3
                        dc.l    L00015110
                        dc.l    L000151C4
                        dc.l    L00015278
                        dc.l    L0001532C
                        dc.l    L0000F5DA
                        
                        dc.l    $0006001E               ; object 4
                        dc.l    L000153E0
                        dc.l    L00015494
                        dc.l    L00015548
                        dc.l    L000155FC
                        dc.l    L0000F5DA
                        
                        dc.l    $0006001E               ; object 5
                        dc.l    L000156B0
                        dc.l    L00015764
                        dc.l    L00015818
                        dc.l    L000158CC
                        dc.l    L0000F5DA
                        
                        dc.l    $0006001E               ; object 6
                        dc.l    L00015980
                        dc.l    L00015A34
                        dc.l    L00015AE8
                        dc.l    L00015B9C
                        dc.l    L0000F5DA
                        
                        dc.l    $0006001E             ; object 7
                        dc.l    L00015C50
                        dc.l    L00015D04
                        dc.l    L00015DB8
                        dc.l    L00015E6C
                        dc.l    L0000F5DA
                        
                        dc.l    $0006001E             ; object 8
                        dc.l    L00015F20
                        dc.l    L00015FD4
                        dc.l    L00016088
                        dc.l    L0001613C
                        dc.l    L0000F5DA
                        
                        dc.l    $0006001E             ; object 9
                        dc.l    L000161F0
                        dc.l    L000162A4
                        dc.l    L00016358
                        dc.l    L0001640C
                        dc.l    L0000F5DA
                        
                        dc.l    $00040008             ; object 10
                        dc.l    L0000F6CE
                        dc.l    L0000F68E
                        dc.l    L0000F68E
                        dc.l    L0000F6CE
                        dc.l    L0000F6AE
                        
                        dc.l    $0006001E             ; object 11
                        dc.l    L0000F6CE
                        dc.l    L0000F6CE
                        dc.l    L0000F6CE
                        dc.l    L0000F6CE
                        dc.l    L0000F5DA
                        
                        dc.l    $0006001E             ; object 12
                        dc.l    L00017230
                        dc.l    L000172E4
                        dc.l    L00017398
                        dc.l    L0001744C
                        dc.l    L0000F5DA
                        
                        dc.l    $000C0068             ; object 13
                        dc.l    L00017500
                        dc.l    L000179EC
                        dc.l    L00017ED8
                        dc.l    L000183C4
                        dc.l    L0000EF9A
                        
                        dc.l    $0006001E             ; object 14
                        dc.l    L000188B0
                        dc.l    L00018964
                        dc.l    L00018A18
                        dc.l    L00018ACC
                        dc.l    L0000F5DA
                        
                        dc.l    $000C0027             ; object 15
                        dc.l    L00018B80
                        dc.l    L00018D60
                        dc.l    L00018F40
                        dc.l    L00019120
                        dc.l    L0000EF9A

L0000E2C0               dc.w    $0000
L0000E2C2               dc.w    $0000,$0000
L0000E2C6               dc.w    $0000
L0000E2C8               dc.w    $0000
L0000E2CA               dc.w    $0000,$0000
L0000E2CE               dc.w    $0000,$0000
L0000E2D2               dc.w    $0000,$0000
L0000E2D6               dc.w    $0000,$0000
L0000E2DA               dc.w    $0000,$0000
L0000E2DE               dc.w    $0000,$0000

L0000E2E2               dc.w    $0000,$0000,$0000
L0000E2E8               dc.w    $0000  

L0000E2EA               RTS     ; 4e75


L0000E2EC               MOVEM.L D0-D7/A0-A6,-(A7)
L0000E2F0               BSR.W   L0000E312
L0000E2F4               MOVEM.L (A7)+,D0-D7/A0-A6
L0000E2F8               RTS 


L0000E2FA               ADD.W   #$0001,D0
L0000E2FE               BRA.W   L0000E2FA 

                        ; text to type
L0000E302               dc.w    $0000                       ; x,y co-ords
L0000E304               dc.w    $3030,$3030,$FF00           ; debug value to print '0000' - last $00 maybe pad byte
L0000E30A               dc.w    $0000 


                ; ----------- debug text display ------------
                ; write a debug value into the panel area
                ;
L0000E30C               CLR.W   L0000E30A
L0000E312               MOVE.L  #PANEL_GFX,L0000EDFC        ; $0007c89a panel
L0000E31C               LEA.L   L0000E304,A6
L0000E322               LEA.L   L0000E36E,A5                ; array of characters 0-9A-F
L0000E328               MOVE.W  D1,L0000E302
L0000E32E               MOVE.W  D0,D1
L0000E330               LSR.W   #$00000008,D0
L0000E332               LSR.W   #$00000004,D0
L0000E334               MOVE.B  $00(A5,D0.w),D2
L0000E338               MOVE.B  D2,(A6)+
L0000E33A               MOVE.W  D1,D0
L0000E33C               LSR.W   #$00000008,D0
L0000E33E               AND.W   #$000f,D0
L0000E342               MOVE.B  $00(A5,D0.w),D2
L0000E346               MOVE.B  D2,(A6)+
L0000E348               MOVE.W  D1,D0
L0000E34A               LSR.W   #$00000004,D0
L0000E34C               AND.W   #$000f,D0
L0000E350               MOVE.B  $00(A5,D0.w),D2
L0000E354               MOVE.B  D2,(A6)+
L0000E356               MOVE.W  D1,D0
L0000E358               AND.W   #$000f,D0
L0000E35C               MOVE.B  $00(A5,D0.w),D2
L0000E360               MOVE.B  D2,(A6)+
L0000E362               LEA.L   L0000E302,A6
L0000E368               BRA.W   debug_text_typer            ; L0000E382
L0000E36C               RTS 

                        ; convert hex to ascii routine above
L0000E36E               dc.w    $3031,$3233,$3435,$3637,$3839,$4142,$4344,$4546     ;0123456789ABCDEF
                        even
                        ; text typer co-ords
L0000E37E               dc.b    $00     ; x co-ord word (combined with below byte)
L0000E37F               dc.b    $00     ; x co-ord byte (char 8 pixel resolution)
L0000E380               dc.b    $00     ; y co-ord byte (line 1 pixel resolution) 
                        dc.b    $00     ; unused/pad byte



                    ; IN:-
                    ;   A6.l = ptr to x,y co-ords as bytes
                    ;
debug_text_typer
L0000E382               MOVE.B  (A6)+,L0000E37F     ; byte x co-ord (byte resolution) - 8 pixels
L0000E388               MOVE.B  (A6)+,L0000E380     ; byte y co-ord (line resolution) - 1 pixel
L0000E38E               MOVE.L  #$00000000,D0
L0000E390               MOVE.L  #$00000000,D1
L0000E392               MOVE.B  L0000E380,D1
L0000E398               MULU.W  #$002c,D1           ; y co-ord? mult by 40
L0000E39C               ADD.W   L0000E37E,D1
L0000E3A2_loop          MOVE.B  (A6)+,D0
L0000E3A4               AND.W   #$00ff,D0
L0000E3A8               CMP.B   #$ff,D0
L0000E3AC               BEQ.W   L0000E4E0 
L0000E3B0               AND.W   #$00ff,D0
L0000E3B4               CMP.B   #$20,D0             ; space
L0000E3B8               BEQ.W   L0000E3F4 
L0000E3BC               CMP.B   #$2f,D0             ; /
L0000E3C0               BLE.W   L0000E408 
L0000E3C4               CMP.B   #$39,D0             ; 9
L0000E3C8               BLE.W   L0000E3F4 
L0000E3CC               CMP.B   #$40,D0             ; @
L0000E3D0               BLE.W   L0000E3F4 
L0000E3D4               CMP.B   #$5c,D0             ; \
L0000E3D8               BLE.W   L0000E3FC 
L0000E3DC               CMP.B   #$60,D0             ; ` (61 = a)
L0000E3E0               BLE.W   L0000E408 
L0000E3E4               CMP.B   #$7a,D0             ; z
L0000E3E8               BGT.W   L0000E408 
L0000E3EC               SUB.B   #$60,D0             ; ` (61 = a)
L0000E3F0               BRA.W   L0000E40C 

L0000E3F4               AND.W   #$003f,D0           
L0000E3F8               BRA.W   L0000E40C 

L0000E3FC               AND.W   #$003f,D0
L0000E400               ADD.W   #$0040,D0
L0000E404               BRA.W   L0000E40C 

L0000E408               MOVE.B  #$00,D0             ; '/' = first character

L0000E40C               ASL.W   #$00000003,D0       ; divide by 8
L0000E40E               LEA.L   L00019300,A0        ; font gfx address?
L0000E414               ADDA.W  D0,A0
L0000E416               MOVEA.L L0000EDFC,A1        ; destination display buffer 
L0000E41C               TST.W   L0000EE04           ; 1 = 4 byte per line buffer, 0 = 40 byte per line buffer
L0000E422               BNE.B   L0000E482 
                        ; do 40 bytes per line destination buffer
L0000E424               MOVE.B  (A0),$00(A1,D1.w)
L0000E428               ADDA.L  #$0000002c,A1
L0000E42E               MOVE.B  $01(A0),$00(A1,D1.w)
L0000E434               ADDA.L  #$0000002c,A1
L0000E43A               MOVE.B  $02(A0),$00(A1,D1.w)
L0000E440               ADDA.L  #$0000002c,A1
L0000E446               MOVE.B  $03(A0),$00(A1,D1.w)
L0000E44C               ADDA.L  #$0000002c,A1
L0000E452               MOVE.B  $04(A0),$00(A1,D1.w)
L0000E458               ADDA.L  #$0000002c,A1
L0000E45E               MOVE.B  $05(A0),$00(A1,D1.w)
L0000E464               ADDA.L  #$0000002c,A1
L0000E46A               MOVE.B  $06(A0),$00(A1,D1.w)
L0000E470               ADDA.L  #$0000002c,A1
L0000E476               MOVE.B  $07(A0),$00(A1,D1.w)
L0000E47C               ADD.L   #$00000001,D1
L0000E47E               BRA.W   L0000E3A2_loop              ; next char

                        ; do 4 bytes per line destination buffer
L0000E482               MOVE.B  (A0),$00(A1,D1.w)
L0000E486               ADDA.L  #$00000004,A1
L0000E48C               MOVE.B  $01(A0),$00(A1,D1.w)
L0000E492               ADDA.L  #$00000004,A1
L0000E498               MOVE.B  $02(A0),$00(A1,D1.w)
L0000E49E               ADDA.L  #$00000004,A1
L0000E4A4               MOVE.B  $03(A0),$00(A1,D1.w)
L0000E4AA               ADDA.L  #$00000004,A1
L0000E4B0               MOVE.B  $04(A0),$00(A1,D1.w)
L0000E4B6               ADDA.L  #$00000004,A1
L0000E4BC               MOVE.B  $05(A0),$00(A1,D1.w)
L0000E4C2               ADDA.L  #$00000004,A1
L0000E4C8               MOVE.B  $06(A0),$00(A1,D1.w)
L0000E4CE               ADDA.L  #$00000004,A1
L0000E4D4               MOVE.B  $07(A0),$00(A1,D1.w)
L0000E4DA               ADD.L   #$00000001,D1
L0000E4DC               BRA.W   L0000E3A2_loop              ; next_char



L0000E4E0               MOVE.L  #PANEL_GFX,L0000EDFC        ; $0007c89a panel
L0000E4EA               CLR.W   L0000EE04
L0000E4F0               RTS 



                    ; ---------------- display level intro text -----------------
                    ; - copy buffer1 to buffer2 $5ed00-$65580 to $67680-$6df00
                    ;   also clear buffer1 $5ed00-$65580
                    ; - clear additional buffer ram
                    ; - display intro text
                    ; - set copper palette
                    ; - pause 3.5 seconds
                    ; - wipe back buffer to front buffer
display_level_intro_text    ; original address L0000E4F2
                    ; set game palette
L0000E52A               LEA.L   game_screen_palette_2,a0        ; L0000FCBE,A0
L0000E530               LEA.L   copper_screen_palette,A1        ; L0000FBE6,A1
L0000E536               BSR.W   copy_palette_to_copper          ; L0000D206

L0000E4F2               LEA.L   BATCAVE_DISPLAY_BUFFER1,A0                ; external address
L0000E4F8               LEA.L   BATCAVE_DISPLAY_BUFFER2,A1                ; external address
L0000E4FE               MOVE.W  #$1a20,D0                   ; $1a20 = 6688 (buffer size?) *4 = 26752 (total bytes cleared)
L0000E502_loop          MOVE.L  (A0),(A1)+
L0000E504               CLR.L   (A0)+
L0000E506               DBF.W   D0,L0000E502_loop
                    ; clear additional space $65580-$66fa0
L0000E50A               MOVE.W  #$0688,D0                   ; clear additional $1a20 bytes
L0000E50E               CLR.L   (A0)+
L0000E510               DBF.W   D0,L0000E50E 
                    ; display 'bat cave text'
L0000E514               MOVE.L  #$00000000,D0
L0000E516               MOVE.L  #BATCAVE_DISPLAY_BUFFER1,display_buffer_ptr2  ; L0000E55E        ; gfx buffer - external address
L0000E520               LEA.L   text_bat_cave,A0                ; L0000E670,A0
L0000E526               BSR.W   game_text_typer                 ; L0000E6E4
                    ; set game palette
;L0000E52A               LEA.L   game_screen_palette_2,a0        ; L0000FCBE,A0
;L0000E530               LEA.L   copper_screen_palette,A1        ; L0000FBE6,A1
;L0000E536               BSR.W   copy_palette_to_copper          ; L0000D206
                    ; pause 3.5 seconds
L0000E53A               MOVE.W  #$00b4,D0                       ; wait 180 frame (3.5 ish seconds)
L0000E53E               BSR.W   wait_frame                      ; $0000d1ee
                    ; wipe back buffer to display
L0000E542               MOVE.L  #BATCAVE_DISPLAY_BUFFER1,display_buffer_ptr1  ; L0000E55A        ; external address
L0000E54C               MOVE.L  #BATCAVE_DISPLAY_BUFFER2,display_buffer_ptr2  ; L0000E55E            ; external address
L0000E556               BRA.W   screen_wipe_to_backbuffer       ; L0000E572 
                    ; uses rts above to return
                    ;---------------------------------

display_buffer_ptrs
display_buffer_ptr1
L0000E55A               dc.l    $00000000                   ; address ptr
display_buffer_ptr2
L0000E55E               dc.l    $00000000                   ; address ptr


                    ; clear buffer (35200 bytes)
screen_wipe_to_black
L0000E562               MOVE.W  #$225f,D7               ; $225f+1 = 8800 (*4 = 35200 bytes - $8980)
L0000E566               MOVEA.L display_buffer_ptr2,A1  ; L0000E55E,A1 ; a1 = display buffer?
L0000E56C_loop          CLR.L   (A1)+
L0000E56E               DBF.W   D7,L0000E56C_loop 

screen_wipe_to_backbuffer
L0000E572               MOVE.W  #$002c,D0               ; d0 = screen width (40 bytes)
L0000E576               MOVE.W  #$0098,D1               ; d1 = screen height (152 rasters)

L0000E57A               MOVEM.L display_buffer_ptrs,A0-A1   ; L0000E55A,A0-A1 ; a0,a1 = buffer 1 & buffer 2 ptrs
L0000E582               CLR.W   D2
L0000E584_loop          MULU.W  #$0555,D2
L0000E588               ADD.W   #$00000001,D2
L0000E58A               AND.W   #$1fff,D2
L0000E58E               BEQ.B   L0000E5E8 
L0000E590               MOVE.L  #$0000007f,D3
L0000E592               AND.W   D2,D3
L0000E594               MOVE.L  #$0000000f,D5
L0000E596               LSR.W   #$00000001,D3
L0000E598               BCC.B   L0000E59C 
L0000E59A               MOVE.L  #$fffffff0,D5
L0000E59C               CMP.W   D0,D3
L0000E59E               BCC.B   L0000E584_loop 
L0000E5A0               MOVE.W  D2,D4
L0000E5A2               LSR.W   #$00000005,D4
L0000E5A4               AND.W   #$00fc,D4
L0000E5A8               CMP.W   D1,D4
L0000E5AA               BCC.B   L0000E584_loop 
L0000E5AC               MULU.W  D0,D4
L0000E5AE               ADD.W   D3,D4
L0000E5B0               MOVE.W  D2,-(A7)
L0000E5B2               MOVE.W  D0,D3
L0000E5B4               MULU.W  D1,D3
L0000E5B6               MOVE.L  #$00000003,D7
L0000E5B8               MOVE.W  D4,-(A7)
L0000E5BA               MOVE.L  #$00000003,D2
L0000E5BC               MOVE.B  D5,D6
L0000E5BE               NOT.W   D6
L0000E5C0               AND.B   $00(A0,D4.w),D6
L0000E5C4               MOVE.B  D6,$00(A0,D4.w)
L0000E5C8               MOVE.B  D5,D6
L0000E5CA               AND.B   $00(A1,D4.w),D6
L0000E5CE               OR.B    $00(A0,D4.w),D6
L0000E5D2               MOVE.B  D6,$00(A0,D4.w)
L0000E5D6               ADD.W   D0,D4
L0000E5D8               DBF.W   D2,L0000E5BC 
L0000E5DC               MOVE.W  (A7)+,D4
L0000E5DE               ADD.W   D3,D4
L0000E5E0               DBF.W   D7,L0000E5B8 
L0000E5E4               MOVE.W  (A7)+,D2
L0000E5E6               BRA.B   L0000E584_loop 
L0000E5E8               RTS 



                ; ---------------- fade panel in (to palette) --------------
panel_fade_in
L0000E5EA               MOVE.L  #$0000000f,D7
L0000E5EC_loop          LEA.L   copper_panel_palette+2,a0       ;L0000FC54,A0
L0000E5F2               LEA.L   panel_colour_palette,a1         ;L0000FC9E,A1
L0000E5F8               MOVE.L  #$0000000f,D6
L0000E5FA_loop          MOVE.W  (A0),D0
L0000E5FC               MOVE.W  (A1)+,D1
L0000E5FE               EOR.W   D0,D1
L0000E600               MOVE.L  #$0000000f,D2
L0000E602               AND.W   D1,D2
L0000E604               BEQ.B   L0000E608 
L0000E606               ADD.W   #$00000001,D0
L0000E608               MOVE.L  #$fffffff0,D2
L0000E60A               AND.B   D1,D2
L0000E60C               BEQ.B   L0000E612 
L0000E60E               ADD.W   #$0010,D0
L0000E612               AND.W   #$0f00,D1
L0000E616               BEQ.B   L0000E61C 
L0000E618               ADD.W   #$0100,D0
L0000E61C               MOVE.W  D0,(A0)
L0000E61E               ADDA.W  #$00000004,A0
L0000E620               DBF.W   D6,L0000E5FA_loop 
L0000E624               MOVE.L  #$00000003,D0               ; frames to wait/skip
L0000E626               BSR.W   wait_frame                  ;L0000D1EE_loop
L0000E62A               DBF.W   D7,L0000E5EC_loop
L0000E62E               RTS 



                ; ---------------- fade panel out (to black) --------------
fade_panel_out
L0000E630               MOVE.L  #$0000000f,D7
L0000E632_loop          LEA.L   copper_panel_palette+2,a0   ;L0000FC54,A0
L0000E638               MOVE.L  #$0000000f,D6
L0000E63A_loop          MOVE.W  (A0),D0                 ; get colour value from copper 
L0000E63C               MOVE.L  #$0000000f,D1           ; fade blue component
L0000E63E               AND.W   D0,D1
L0000E640               BEQ.B   L0000E644 
L0000E642               SUB.W   #$00000001,D0           ; fade blue towards black
L0000E644               MOVE.W  #$00f0,D1               ; fade green component
L0000E648               AND.W   D0,D1
L0000E64A               BEQ.B   L0000E650 
L0000E64C               SUB.W   #$0010,D0               ; fade green towards black
L0000E650               MOVE.W  #$0f00,D1               ; fade red component
L0000E654               AND.W   D0,D1
L0000E656               BEQ.B   L0000E65C 
L0000E658               SUB.W   #$0100,D0               ; fade red to black
L0000E65C               MOVE.W  D0,(A0)                 ; store faded colour back into copper
L0000E65E               ADDA.W  #$00000004,A0           ; next colour 
L0000E660               DBF.W   D6,L0000E63A_loop       ; next colour loop
L0000E664               MOVE.L  #$00000003,D0           ; frames to wait/skip
L0000E666               BSR.W   wait_frame              ; L0000D1EE_loop
L0000E66A               DBF.W   D7,L0000E632_loop       ; fade all again.
L0000E66E               RTS 



text_bat_cave
L0000E670               dc.b    $46,$10
L0000E672               dc.b    'THE BATCAVE',$00,$ff
L0000E67F               dc.b    $41

text_simlex_success
L0000E680               dc.b    $14,$08
L0000E682               dc.b    'SMILEX SUCCESSFULLY ANALYSED',$00
L0000E69F               dc.b    $3C,$0C     
L0000E6A1               dc.b    'NOW THWART THE JOKERS',$00
L0000E6B7               dc.b    $50,$10
L0000E6B9               dc.b    'CARNIVAL PLOT.',$00,$ff
L0000E6C9               dc.b    $20 ; pad byte 

text_time_out
L0000E6CA               dc.b    $46,$13
L0000E6CC               dc.b    'TIME OUT',$00,$ff

text_game_over
L0000E6D6               dc.b    $46,$12
L0000E6D8               dc.b    'GAME OVER',$00,$ff
L0000E6E3               dc.b    $45 ; pad byte 



                    ; ------------------- game text typer -------------------
                    ; routine displays text (see above)
                    ; Each line of text starts with 2 bytes (y co-ord, x co-ord)
                    ; followed by null terminated text ($00)
                    ; a final terminator ($ff) or another line of text starting with x,y co-ords
                    ; can follow the previous line.
                    ;
                    ; IN:-
                    ;   L0000E55E = dest gfx buffer - display_buffer_ptr2
                    ;
game_text_typer     ; original address L0000E6E4
L0000E6E4               MOVE.B  (A0)+,D0
L0000E6E6               BMI.W   L0000E7BA               ; $ff = exit
L0000E6EA               AND.W   #$00ff,D0               ; d0 = y co-ord
L0000E6EE               MULU.W  #$002c,D0
L0000E6F2               MOVE.B  (A0)+,D1                ; d1 = x co-ord
L0000E6F4               EXT.W   D1
L0000E6F6               ADD.W   D1,D0                   ; d0 = x & y byte offset for display
L0000E6F8               MOVEA.L display_buffer_ptr2,A1  ; L0000E55E,A1        ; destination display ptr
L0000E6FE               LEA.L   $00(A1,D0.w),A1         ; a1 = dest gfx buffer

                    ; do next character
L0000E702_loop          MOVE.L  #$00000000,D0
L0000E704               MOVE.B  (A0)+,D0
L0000E706               BEQ.B   L0000E6E4           ; $00 = end of line

L0000E708               CMP.B   #$20,D0
L0000E70C               BEQ.W   L0000E7B2 
L0000E710               MOVE.L  #$ffffffcd,D1
L0000E712               CMP.B   #$41,D0
L0000E716               BCC.B   L0000E73E 
L0000E718               MOVE.L  #$ffffffd4,D1
L0000E71A               CMP.B   #$30,D0
L0000E71E               BCC.B   L0000E73E 
L0000E720               MOVE.L  #$00000000,D1
L0000E722               CMP.B   #$21,D0
L0000E726               BEQ.B   L0000E744 
L0000E728               MOVE.L  #$00000001,D1
L0000E72A               CMP.B   #$28,D0
L0000E72E               BEQ.B   L0000E744 
L0000E730               MOVE.L  #$00000002,D1
L0000E732               CMP.B   #$29,D0
L0000E736               BEQ.B   L0000E744 
L0000E738               MOVE.L  #$00000003,D1
L0000E73A               BRA.W   L0000E744 

L0000E73E               ADD.B   D0,D1
L0000E740               AND.W   #$00ff,D1
L0000E744               MULU.W  #$0028,D1
L0000E748               LEA.L   font8x8x5,a2            ; L0000E7BC,A2            ; font gfx address
L0000E74E               LEA.L   $00(A2,D1.w),A2
L0000E752               MOVE.L  #$00000007,D7           ; 8 pixel font
L0000E754               MOVEA.L A1,A3
L0000E756_loop          MOVE.B  (A2)+,D1
L0000E758               AND.B   D1,(A3)
L0000E75A               MOVE.B  (A2)+,D2
L0000E75C               OR.B    D2,(A3)

L0000E75E               AND.B   D1,$1a20(A3)
L0000E762               MOVE.B  (A2)+,D2
L0000E764               OR.B    D2,$1a20(A3)

L0000E768               AND.B   D1,$3440(A3)
L0000E76C               MOVE.B  (A2)+,D2
L0000E76E               OR.B    D2,$3440(A3)

L0000E772               AND.B   D1,$4e60(A3)
L0000E776               MOVE.B  (A2)+,D2
L0000E778               OR.B    D2,$4e60(A3)

L0000E77C               LEA.L   $002c(A3),A3
L0000E780               LEA.L   -$0005(A2),A2
L0000E784               MOVE.B  (A2)+,D1
L0000E786               AND.B   D1,(A3)
L0000E788               MOVE.B  (A2)+,D2
L0000E78A               OR.B    D2,(A3)
L0000E78C               AND.B   D1,$1a20(A3)
L0000E790               MOVE.B  (A2)+,D2
L0000E792               OR.B    D2,$1a20(A3)
L0000E796               AND.B   D1,$3440(A3)
L0000E79A               MOVE.B  (A2)+,D2
L0000E79C               OR.B    D2,$3440(A3)
L0000E7A0               AND.B   D1,$4e60(A3)
L0000E7A4               MOVE.B  (A2)+,D2
L0000E7A6               OR.B    D2,$4e60(A3)
L0000E7AA               LEA.L   $002c(A3),A3
L0000E7AE               DBF.W   D7,L0000E756_loop 

L0000E7B2               LEA.L   $0001(A1),A1
L0000E7B6               BRA.W   L0000E702_loop 
L0000E7BA               RTS 


                ; multi-colour 4 bpl 8x8 pixel font - used by game text typer
                ; 320 rasters (4bpl + mask)

                ; char '!'
                ; ..11....      ; bpl0
                ; ..11....
                ; ..11....
                ; ..11....
                ; ..11....
                ; ........
                ; ..11....
                ; ........
font8x8x5
L0000E7BC       dc.b    $CF     ; 11..1111      ; mask
                dc.b    $30     ; ..11....      ; bpl0
                dc.b    $30     ; ..11....      ; bpl1
                dc.b    $00     ; ........      ; bpl2
                dc.b    $00     ; ........      ; bpl3

                dc.b    $C7     ; 11...111
                dc.b    $30     ; ..11....
                dc.b    $38     ; ..111...
                dc.b    $08     ; ....1...
                dc.b    $00     ; ........

                dc.b    $C7     ; 11...111
                dc.b    $30     ; ..11....
                dc.b    $38     ; ..111...
                dc.b    $08     ; ....1...
                dc.b    $00     ; ........

                dc.b    $C7     ; 11...111
L0000E7CC       dc.b    $30     ; ..11....
                dc.b    $38     ; ..111...
                dc.b    $08     ; ....1...
                dc.b    $00     ; ........

                dc.b    $C7     ; 11...111
                dc.b    $30     ; ..11....
                dc.b    $38     ; ..111...
                dc.b    $08     ; ....1...
                dc.b    $00     ; ........

                dc.b    $E7     ; 111..111
                dc.b    $00     ; ........
                dc.b    $18     ; ...11...
                dc.b    $18     ; ...11...
                dc.b    $00     ; ........

                dc.b    $CF     ; 11..1111
                dc.b    $30     ; ..11....
L0000E7DC       dc.b    $30     ; ..11....
                dc.b    $00     ; ........
                dc.b    $00     ; ........

                dc.b    $E7     ; 111..111
                dc.b    $00     ; ........
                dc.b    $18     ; ...11...
                dc.b    $18     ; ...11...
                dc.b    $00     ; ........



                dc.b    $F3
                dc.b    $0C
                dc.b    $0C
                dc.b    $00
                dc.b    $00
                dc.b    $E1
                dc.b    $18
                dc.b    $1E
L0000E7EC       dc.w    $0600,$E318,$1C04,$00E3,$181C,$0400,$E318,$1C04
L0000E7FC       dc.w    $00E3,$181C,$0400,$F30C,$0C00,$00F9,$0006,$0600
L0000E80C       dc.w    $9F60,$6000,$00CF,$3030,$0000,$C730,$3808,$00C7
L0000E81C       dc.w    $3038,$0800,$C730,$3808,$00C7,$3038,$0800,$8760
L0000E82C       dc.w    $7818,$00CF,$0030,$3000,$FF00,$0000,$00FF,$0000
L0000E83C       dc.w    $0000,$FF00,$0000,$00FF,$0000,$0000,$FF00,$0000
L0000E84C       dc.w    $009F,$6060,$0000,$8F60,$7010,$00CF,$0030,$3000
L0000E85C       dc.w    $837C,$7C00,$0001,$C6FE,$3800,$10CE,$EF21,$0000
L0000E86C       dc.w    $D6FF,$2900,$08E6,$F711,$0018,$C6E7,$2100,$807C
L0000E87C       dc.w    $7F03,$00C1,$003E,$3E00,$C738,$3800,$00C3,$383C
L0000E88C       dc.w    $0400,$E318,$1C04,$00E3,$181C,$0400,$E318,$1C04
L0000E89C       dc.w    $00E3,$181C,$0400,$E318,$1C04,$00F3,$000C,$0C00
L0000E8AC       dc.w    $837C,$7C00,$0001,$C6FE,$3800,$900C,$6F63,$00E1
L0000E8BC       dc.w    $181E,$0600,$C330,$3C0C,$0087,$6078,$1800,$00FE
L0000E8CC       dc.w    $FF01,$0080,$007F,$7F00,$837C,$7C00,$0001,$C6FE
L0000E8DC       dc.w    $3800,$9806,$6761,$00C0,$3C3F,$0300,$E106,$1E18
L0000E8EC       dc.w    $0038,$C6C7,$0100,$807C,$7F03,$00C1,$003E,$3E00
L0000E8FC       dc.w    $E31C,$1C00,$00C1,$3C3E,$0200,$816C,$7E12,$0001
L0000E90C       dc.w    $CCFE,$3200,$01FE,$FE00,$0080,$0C7F,$7300,$F10C
L0000E91C       dc.w    $0E02,$00F9,$0006,$0600,$00FE,$FF00,$0000,$C0FF
L0000E92C       dc.w    $3F00,$1FC0,$E020,$0003,$FCFC,$0000,$8006,$7F79
L0000E93C       dc.w    $0038,$C6C7,$0100,$807C,$7F03,$00C1,$003E,$3E00
L0000E94C       dc.w    $837C,$7C00,$0001,$C6FE,$3800,$1CC0,$E323,$0003
L0000E95C       dc.w    $FCFC,$0000,$01C6,$FE38,$0018,$C6E7,$2100,$807C
L0000E96C       dc.w    $7F03,$00C1,$003E,$3E00,$01FE,$FE00,$0080,$067F
L0000E97C       dc.w    $7900,$F00C,$0F03,$00E1,$181E,$0600,$E318,$1C04
L0000E98C       dc.w    $00C7,$3038,$0800,$C730,$3808,$00E7,$0018,$1800
L0000E99C       dc.w    $837C,$7C00,$0001,$C6FE,$3800,$18C6,$E721,$0080
L0000E9AC       dc.w    $7C7F,$0300,$01C6,$FE38,$0018,$C6E7,$2100,$807C
L0000E9BC       dc.w    $7F03,$00C1,$003E,$3E00,$837C,$7C00,$0001,$C6FE
L0000E9CC       dc.w    $3800,$18C6,$E721,$0080,$7E7F,$0100,$C006,$3F39
L0000E9DC       dc.w    $0038,$C6C7,$0100,$807C,$7F03,$00C1,$003E,$3E00
L0000E9EC       dc.w    $EF10,$1000,$00C7,$3838,$0000,$C338,$3C04,$0083
L0000E9FC       dc.w    $6C7C,$1000,$817C,$7E02,$0001,$C6FE,$3800,$18C6
L0000EA0C       dc.w    $E721,$009C,$0063,$6300,$03FC,$FC00,$0001,$C6FE
L0000EA1C       dc.w    $3800,$18C6,$E721,$0000,$FCFF,$0300,$01C6,$FE38
L0000EA2C       dc.w    $0018,$C6E7,$2100,$00FC,$FF03,$0081,$007E,$7E00
L0000EA3C       dc.w    $837C,$7C00,$0001,$C6FE,$3800,$1CC0,$E323,$001F
L0000EA4C       dc.w    $C0E0,$2000,$1FC0,$E020,$0019,$C6E6,$2000,$807C
L0000EA5C       dc.w    $7F03,$00C1,$003E,$3E00,$07F8,$F800,$0003,$CCFC
L0000EA6C       dc.w    $3000,$19C6,$E620,$0018,$C6E7,$2100,$18C6,$E721
L0000EA7C       dc.w    $0010,$CCEF,$2300,$01F8,$FE06,$0083,$007C,$7C00
L0000EA8C       dc.w    $01FE,$FE00,$0000,$C0FF,$3F00,$1FC0,$E020,$0007
L0000EA9C       dc.w    $F8F8,$0000,$03C0,$FC3C,$001F,$C0E0,$2000,$01FE
L0000EAAC       dc.w    $FE00,$0080,$007F,$7F00,$01FE,$FE00,$0000,$C0FF
L0000EABC       dc.w    $3F00,$1FC0,$E020,$0007,$F8F8,$0000,$03C0,$FC3C
L0000EACC       dc.w    $001F,$C0E0,$2000,$1FC0,$E020,$009F,$0060,$6000
L0000EADC       dc.w    $837C,$7C00,$0001,$C6FE,$3800,$1CC0,$E323,$0001
L0000EAEC       dc.w    $DEFE,$2000,$10C6,$EF29,$0018,$C6E7,$2100,$807E
L0000EAFC       dc.w    $7F01,$00C0,$003F,$3F00,$39C6,$C600,$0018,$C6E7
L0000EB0C       dc.w    $2100,$18C6,$E721,$0000,$FEFF,$0100,$00C6,$FF39
L0000EB1C       dc.w    $0018,$C6E7,$2100,$18C6,$E721,$009C,$0063,$6300
L0000EB2C       dc.w    $8778,$7800,$00C3,$303C,$0C00,$C730,$3808,$00C7
L0000EB3C       dc.w    $3038,$0800,$C730,$3808,$00C7,$3038,$0800,$8778
L0000EB4C       dc.w    $7800,$00C3,$003C,$3C00,$F906,$0600,$00F8,$0607
L0000EB5C       dc.w    $0100,$F806,$0701,$00F8,$0607,$0100,$38C6,$C701
L0000EB6C       dc.w    $0018,$C6E7,$2100,$807C,$7F03,$00C1,$003E,$3E00
L0000EB7C       dc.w    $39C6,$C600,$0010,$CCEF,$2300,$01D8,$FE26,$0003
L0000EB8C       dc.w    $F0FC,$0C00,$07D8,$F820,$0013,$CCEC,$2000,$19C6
L0000EB9C       dc.w    $E620,$009C,$0063,$6300,$3FC0,$C000,$001F,$C0E0
L0000EBAC       dc.w    $2000,$1FC0,$E020,$001F,$C0E0,$2000,$1FC0,$E020
L0000EBBC       dc.w    $0019,$C6E6,$2000,$00FE,$FF01,$0080,$007F,$7F00
L0000EBCC       dc.w    $39C6,$C600,$0010,$EEEF,$0100,$00FE,$FF01,$0000
L0000EBDC       dc.w    $D6FF,$2900,$10C6,$EF29,$0018,$C6E7,$2100,$18C6
L0000EBEC       dc.w    $E721,$009C,$0063,$6300,$39C6,$C600,$0018,$E6E7
L0000EBFC       dc.w    $0100,$08F6,$F701,$0000,$DEFF,$2100,$10CE,$EF21
L0000EC0C       dc.w    $0018,$C6E7,$2100,$18C6,$E721,$009C,$0063,$6300
L0000EC1C       dc.w    $837C,$7C00,$0001,$C6FE,$3800,$18C6,$E721,$0018
L0000EC2C       dc.w    $C6E7,$2100,$18C6,$E721,$0018,$C6E7,$2100,$807C
L0000EC3C       dc.w    $7F03,$00C1,$003E,$3E00,$03FC,$FC00,$0001,$C6FE
L0000EC4C       dc.w    $3800,$18C6,$E721,$0000,$FCFF,$0300,$01C0,$FE3E
L0000EC5C       dc.w    $001F,$C0E0,$2000,$1FC0,$E020,$009F,$0060,$6000
L0000EC6C       dc.w    $837C,$7C00,$0001,$C6FE,$3800,$18C6,$E721,$0018
L0000EC7C       dc.w    $C6E7,$2100,$00DA,$FF25,$0000,$CCFF,$3300,$8176
L0000EC8C       dc.w    $7E08,$00C4,$003B,$3B00,$03FC,$FC00,$0001,$C6FE
L0000EC9C       dc.w    $3800,$18C6,$E721,$0000,$FCFF,$0300,$01CC,$FE32
L0000ECAC       dc.w    $0018,$C6E7,$2100,$18C6,$E721,$009C,$0063,$6300
L0000ECBC       dc.w    $837C,$7C00,$0001,$C6FE,$3800,$1CC0,$E323,$0083
L0000ECCC       dc.w    $7C7C,$0000,$C106,$3E38,$0038,$C6C7,$0100,$807C
L0000ECDC       dc.w    $7F03,$00C1,$003E,$3E00,$03FC,$FC00,$0081,$307E
L0000ECEC       dc.w    $4E00,$C730,$3808,$00C7,$3038,$0800,$C730,$3808
L0000ECFC       dc.w    $00C7,$3038,$0800,$C730,$3808,$00E7,$0018,$1800
L0000ED0C       dc.w    $39C6,$C600,$0018,$C6E7,$2100,$18C6,$E721,$0018
L0000ED1C       dc.w    $C6E7,$2100,$18C6,$E721,$0018,$C6E7,$2100,$807C
L0000ED2C       dc.w    $7F03,$00C1,$003E,$3E00,$39C6,$C600,$0018,$C6E7
L0000ED3C       dc.w    $2100,$18C6,$E721,$0080,$6C7F,$1300,$817C,$7E02
L0000ED4C       dc.w    $00C1,$383E,$0600,$E310,$1C0C,$00F7,$0008,$0800
L0000ED5C       dc.w    $39C6,$C600,$0018,$C6E7,$2100,$08D6,$F721,$0000
L0000ED6C       dc.w    $D6FF,$2900,$00FE,$FF01,$0080,$7C7F,$0300,$816C
L0000ED7C       dc.w    $7E12,$00C9,$0036,$3600,$39C6,$C600,$0018,$C6E7
L0000ED8C       dc.w    $2100,$10EE,$EF01,$0080,$7C7F,$0300,$01EE,$FE10
L0000ED9C       dc.w    $0018,$C6E7,$2100,$18C6,$E721,$009C,$0063,$6300
L0000EDAC       dc.w    $33CC,$CC00,$0011,$CCEE,$2200,$11CC,$EE22,$0081
L0000EDBC       dc.w    $787E,$0600,$C330,$3C0C,$00C7,$3038,$0800,$C730
L0000EDCC       dc.w    $3808,$00E7,$0018,$1800,$03FC,$FC00,$0001,$CCFE
L0000EDDC       dc.w    $3200,$8118,$7E66,$00C3,$303C,$0C00,$8760,$7818
L0000EDEC       dc.w    $0003,$CCFC,$3000,$01FC,$FE02,$0081,$007E,$7E00
                ; ----------- end of font data -------


debug_display_buffer_ptr    ; original address L0000EDFC
L0000EDFC       dc.l    $0007C89A               ; address of panel gfx

display_bitplane_width_bytes    ; original address L0000EE00
L0000EE00       dc.w    $0000

frame_toggle    ; original address L0000EE02
L0000EE02       dc.w    $0000                   ; frame toggle (NOT.W every VERTB) - unreferenced by code

L0000EE04       dc.w    $0000

L0000EE06       dc.w    $C89A,$002C,$FFFF
L0000EE0C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000EE1C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000EE2C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000EE3C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000EE4C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000EE5C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000EE6C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000EE7C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000EE8C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000EE9C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000EEAC       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000EEBC       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000EECC       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000EEDC       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000EEEC       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000EEFC       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000EF0C       dc.w    $0000,$0000,$0000,$0000,$0007,$FC92,$0007,$C808
L0000EF1C       dc.w    $0007,$FC92,$0007,$C808,$0000,$8000,$0000,$FFFF
L0000EF2C       dc.w    $0055,$FFFF,$0000,$0000,$0000,$7E81,$FFFF,$FFF0
L0000EF3C       dc.w    $0000,$FFFF,$0000,$FFFF,$0000,$4126

                dc.w    $0006,$7680     ; Display Buffer Ptr?

L0000EF4C       dc.w    $0000,$E864,$0000,$D1E4,$0000,$FFFF,$0000,$FFFF
L0000EF5C       dc.w    $0055,$0000,$0000,$1A20,$0000,$7E81,$FFFF,$FFF0
L0000EF6C       dc.w    $0000,$FFFF,$0000,$FFFF,$0000,$FC9C

                dc.w    $0006,$7680     ; Display Buffer Ptr?

L0000EF7C       dc.w    $0000,$E864,$0006,$871D,$0000,$E150,$0000,$00C7
L0000EF8C       dc.w    $848C,$00C7,$871E,$00C7

stack_memory
L0000ef96       dc.w    $8104,$0000,$0000

L0000EF9A       dc.w    $FFFF
L0000EF9C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000EFAC       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000EFBC       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000EFCC       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000EFDC       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000EFEC       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000EFFC       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F00C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F01C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F02C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F03C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F04C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F05C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F06C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F07C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F08C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F09C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F0AC       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F0BC       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F0CC       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F0DC       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F0EC       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F0FC       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F10C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F11C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F12C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F13C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F14C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F15C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F16C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F17C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F18C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F19C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F1AC       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F1BC       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F1CC       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F1DC       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F1EC       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F1FC       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F20C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F21C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F22C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F23C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F24C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F25C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F26C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F27C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F28C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F29C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F2AC       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F2BC       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F2CC       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F2DC       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F2EC       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F2FC       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F30C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F31C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F32C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F33C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F34C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F35C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F36C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F37C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F38C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F39C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F3AC       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F3BC       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F3CC       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F3DC       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F3EC       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F3FC       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F40C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F41C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F42C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F43C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F44C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F45C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F46C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F47C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F48C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F49C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F4AC       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F4BC       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F4CC       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F4DC       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F4EC       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F4FC       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F50C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F51C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F52C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F53C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F54C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F55C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F56C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F57C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F58C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F59C       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F5AC       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F5BC       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
L0000F5CC       dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF

L0000F5DA       dc.w    $07FF
L0000F5DC       dc.w    $FFE0,$0000,$07FF,$FFE0,$0000,$07FF,$FFE0,$0000
L0000F5EC       dc.w    $07FF,$FFE0,$0000,$07FF,$FFE0,$0000,$07FF,$FFE0
L0000F5FC       dc.w    $0000,$07FF,$FFE0,$0000,$07FF,$FFE0,$0000,$07FF
L0000F60C       dc.w    $FFE0,$0000,$07FF,$FFE0,$0000,$07FF,$FFE0,$0000
L0000F61C       dc.w    $07FF,$FFE0,$0000,$07FF,$FFE0,$0000,$07FF,$FFE0
L0000F62C       dc.w    $0000,$07FF,$FFE0,$0000,$07FF,$FFE0,$0000,$07FF
L0000F63C       dc.w    $FFE0,$0000,$07FF,$FFE0,$0000,$07FF,$FFE0,$0000
L0000F64C       dc.w    $07FF,$FFE0,$0000,$07FF,$FFE0,$0000,$07FF,$FFE0
L0000F65C       dc.w    $0000,$07FF,$FFE0,$0000,$07FF,$FFE0,$0000,$07FF
L0000F66C       dc.w    $FFE0,$0000,$07FF,$FFE0,$0000,$07FF,$FFE0,$0000
L0000F67C       dc.w    $07FF,$FFE0,$0000,$0000,$0000,$0000,$0000,$0000
L0000F68C       dc.w    $0000

            ; debug typer buffer (64 bytes)
debug_typer_buffer  ; original address L0000F68E
L0000F68E       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F69C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F6AC       dc.w    $0000

L0000F6AE       dc.w    $FF00,$0000,$FF00,$0000,$FF00,$0000,$FF00
L0000F6BC       dc.w    $0000,$FF00,$0000,$FF00,$0000,$FF00,$0000,$FF00
L0000F6CC       dc.w    $0000

game_screen_palette
L0000F6CE       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F6DC       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F6EC       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F6FC       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F70C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F71C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F72C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F73C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F74C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F75C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F76C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F77C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F78C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F79C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F7AC       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F7BC       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F7CC       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F7DC       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F7EC       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F7FC       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F80C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F81C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F82C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F83C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F84C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F85C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F86C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F87C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F88C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F89C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F8AC       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F8BC       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F8CC       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F8DC       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F8EC       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F8FC       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F90C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F91C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F92C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F93C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F94C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F95C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F96C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F97C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F98C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F99C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F9AC       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F9BC       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F9CC       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F9DC       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F9EC       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000F9FC       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000FA0C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000FA1C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000FA2C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000FA3C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000FA4C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000FA5C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000FA6C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000FA7C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000FA8C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000FA9C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000FAAC       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000FABC       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000FACC       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000FADC       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000FAEC       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000FAFC       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000FB0C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000FB1C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000FB2C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000FB3C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000FB4C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000FB5C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000FB6C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000FB7C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000FB8C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000FB9C       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0000FBAC       dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000 



            ; ----------------- copper list -----------------
copper_list ; original address $000fbba
L0000FBBA       ; game screen display
                dc.w    $00FF,$FF00     ; This wait looks dodgy will have to decipher it. (masking out horizonal wait)
                ; set display modulos
                dc.w    $0108,$0004     ; BPL1MOD (44 byte width?)
                dc.w    $010A,$0004     ; BPL2MOD (44 byte width?)
                ; set bitplane ptrs
copper_game_bpl_ptrs 
                ; $0005ED02 - bpl0 $1a20 bytes (6688 bytes) (/44 = 152 raster lines high)
                dc.w    $00E0,$0005
                dc.w    $00E2,$ED02
                ; $00060722 - bpl1 $1a20 bytes (6688 bytes) (/44 = 152 raster lines high)
                dc.w    $00E4,$0006
                dc.w    $00E6,$0722
                ; $00062142 - bpl2 $1a20 bytes (6688 bytes) (/44 = 152 raster lines high)
                dc.w    $00E8,$0006
                dc.w    $00EA,$2142
                ; $00063B62 - bpl3 $1a20 bytes (6688 bytes) (/44 = 152 raster lines high)
                dc.w    $00EC,$0006
                dc.w    $00EE,$3B62     
                ; $65582 - end of display buffer 1
                ; game screen palette (4 bitplanes/16 colours)
copper_screen_palette
L0000FBE6       dc.w    $0180,$0000
                dc.w    $0182,$0000
                dc.w    $0184,$0000
                dc.w    $0186,$0000
                dc.w    $0188,$0000
                dc.w    $018A,$0000
                dc.w    $018C,$0000
                dc.w    $018E,$0000
                dc.w    $0190,$0000
                dc.w    $0192,$0000
                dc.w    $0194,$0000
                dc.w    $0196,$0000
                dc.w    $0198,$0000
                dc.w    $019A,$0000
                dc.w    $019C,$0000
                dc.w    $019E,$0000
                ; panel display start
L0000FC26       dc.w    $C401,$FF00
copper_panel_bpl_ptrs
                ; $7C89A - bpl0
                dc.w    $00E0,$0007
                dc.w    $00E2,$C89A
                ; $7D01A - bpl1
                dc.w    $00E4,$0007
                dc.w    $00E6,$D01A 
                ; $7D79A - bpl2
                dc.w    $00E8,$0007
                dc.w    $00EA,$D79A
                ; $7DF1A - bpl3     
                dc.w    $00EC,$0007
                dc.w    $00EE,$DF1A
                ; display modulos     
                dc.w    $0108,$0000     ; BPL1MOD (40 bytes wide)
                dc.w    $010A,$0000     ; BPL2MOD (40 bytes wide)
                ; panel palette (4 bitplanes/16 colours)
copper_panel_palette
L0000FC52       dc.w    $0180,$0000
                dc.w    $0182,$0000
                dc.w    $0184,$0000
                dc.w    $0186,$0000
                dc.w    $0188,$0000
                dc.w    $018A,$0000
                dc.w    $018C,$0000
                dc.w    $018E,$0000
                dc.w    $0190,$0000
                dc.w    $0192,$0000
                dc.w    $0194,$0000
                dc.w    $0196,$0000
                dc.w    $0198,$0000
                dc.w    $019A,$0000
                dc.w    $019C,$0000
                dc.w    $019E,$0000
                ; end of the display
                dc.w    $F301,$FFFE
                dc.w    $0180,$0000
                dc.w    $FFFF,$FFFE 


; colour table (panel?)
panel_colour_palette
L0000FC9E       dc.w    $0000,$0060,$0FFF,$0008,$0A22,$0444,$0862
L0000FCAC       dc.w    $0666,$0888,$0AAA,$0A40,$0C60,$0E80,$0EA0,$0EC0
L0000FCBC       dc.w    $0EEE

game_screen_palette_2
L0000FCBE       dc.w    $0000,$0130,$0111,$0333,$0555,$0777,$0BBB
L0000FCCC       dc.w    $0008,$0A04,$0703,$0000,$0B50,$0F70,$0250,$0F00
L0000FCDC       dc.w    $0005,$0F70,$0250,$0F00,$0005,$0000,$0000,$0000


L0000FCEC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000FCFC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000FD0C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000FD1C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000FD2C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000FD3C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000FD4C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000FD5C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000FD6C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000FD7C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000FD8C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000FD9C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000FDAC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000FDBC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000FDCC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000FDDC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000FDEC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000FDFC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000FE0C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000FE1C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000FE2C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000FE3C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000FE4C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000FE5C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000FE6C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000FE7C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000FE8C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000FE9C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000FEAC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000FEBC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000FECC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000FEDC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000FEEC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000FEFC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000FF0C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000FF1C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000FF2C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000FF3C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000FF4C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000FF5C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000FF6C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000FF7C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000FF8C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000FF9C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000FFAC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000FFBC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000FFCC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000FFDC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000FFEC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000  
L0000FFFC   dc.w    $0000,$0000


            ; background batcave graphics
            ; 3 bitplane image (44 bytes wide by 152 rasters high)
            ; 6688 ($1a20) bytes per bitplane, so....
            ; bpl0 = $10000 - $11a1f
            ; bpl1 = $11a20 - $1343f
            ; bpl3 = $13440 - $14E5f
background_gfx  ; original address L00010000
            include "./gfx/backgroundgfx.s"


L00014E40   dc.w    $0000,$0000,$0000,$0000,$0000,$0000
L00014E4C   dc.w    $0000,$0000,$0000,$000A,$0000,$0000,$000A,$0000
L00014E5C   dc.w    $0000,$000E
L00014E60   dc.w    $0000,$0000,$000A
L00014E66   dc.w    $0000,$0000,$0000
L00014E6C   dc.w    $0000,$0000,$0000,$0000,$0000,$000D,$8000,$0000
L00014E7C   dc.w    $0021,$8000,$0000,$00A4,$8000,$0000,$00A9,$0800
L00014E8C   dc.w    $0000,$00A2,$0800,$0000,$0024,$0800,$0000,$0028
L00014E9C   dc.w    $0800,$0000,$0030,$0800,$0000,$00FF,$F800,$0000
L00014EAC   dc.w    $00FF,$F800,$0000,$00FF,$F800,$0000,$00FF,$F800
L00014EBC   dc.w    $0000,$00FF,$F800,$0000,$00FF,$F800,$0000,$00FF
L00014ECC   dc.w    $F800,$0000,$00FF,$F800,$0000,$007F,$F000,$0000
L00014EDC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00014EEC   dc.w    $0000,$0000,$0000,$0000

L00014EF4   dc.w    $0000,$0000,$0000,$0000
L00014EFC   dc.w    $0000,$0000,$001F,$C000,$0000,$001F,$4000,$0000
L00014F0C   dc.w    $001F,$4000,$0000,$001B,$4000,$0000,$001B,$4000
L00014F1C   dc.w    $0000,$000F,$8000,$0000,$0000,$0000,$0000,$0009
L00014F2C   dc.w    $8000,$0000,$005E,$0000,$0000,$0068,$F000,$0000
L00014F3C   dc.w    $0061,$F800,$0000,$0063,$F800,$0000,$0067,$F800
L00014F4C   dc.w    $0000,$006F,$F800,$0000,$007F,$F800,$0000,$00FF
L00014F5C   dc.w    $F800,$0000,$00FF,$F800,$0000,$00FF,$F800,$0000
L00014F6C   dc.w    $00FF,$F800,$0000,$00FF,$F800,$0000,$00FF,$F800
L00014F7C   dc.w    $0000,$00FF,$F800,$0000,$00FF,$F800,$0000,$007F
L00014F8C   dc.w    $F000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00014F9C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000

L00014FA8   dc.w    $0000,$0000
L00014FAC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0006
L00014FBC   dc.w    $0000,$0000,$0006,$0000,$0000,$0006,$0000,$0000
L00014FCC   dc.w    $0006,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00014FDC   dc.w    $0000,$0006,$0000,$0000,$007F,$F000,$0000,$009F
L00014FEC   dc.w    $0800,$0000,$009E,$0000,$0000,$009C,$0000,$0000
L00014FFC   dc.w    $0098,$0000,$0000,$0090,$0000,$0000,$0080,$0000
L0001500C   dc.w    $0000,$005F,$F000,$0000,$007F,$F000,$0000,$007F
L0001501C   dc.w    $F000,$0000,$007F,$F000,$0000,$007F,$F000,$0000
L0001502C   dc.w    $007F,$F000,$0000,$007F,$F000,$0000,$007F,$F000
L0001503C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001504C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001505C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001506C   dc.w    $0000,$0002,$0000,$0000,$0002,$0000,$0000,$0002
L0001507C   dc.w    $0000,$0000,$0002,$0000,$0000,$0000,$0000,$0000
L0001508C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001509C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L000150AC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L000150BC   dc.w    $0000,$0000,$0000,$005F,$F000,$0000,$0000,$0000
L000150CC   dc.w    $0000,$007F,$F000,$0000,$007F,$F000,$0000,$007F
L000150DC   dc.w    $F000,$0000,$007F,$F000,$0000,$007F,$F000,$0000
L000150EC   dc.w    $007F,$F000,$0000,$0000,$0000,$0000,$0000,$0000
L000150FC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001510C   dc.w    $0130,$0000

L00015110   dc.w    $000D,$8000,$0000,$0000,$0000,$0000
L0001511C   dc.w    $000D,$8000,$0000,$0009,$8000,$0000,$0009,$8000
L0001512C   dc.w    $0000,$0009,$8000,$0000,$0009,$8000,$0000,$0009
L0001513C   dc.w    $8000,$0000,$0009,$8000,$0000,$0009,$8000,$0000
L0001514C   dc.w    $000C,$8000,$0000,$000E,$8000,$0000,$0015,$8000
L0001515C   dc.w    $0000,$0023,$4000,$0000,$0046,$2000,$0000,$0048
L0001516C   dc.w    $1000,$0000,$009F,$D000,$0000,$00B0,$7800,$0000
L0001517C   dc.w    $00B3,$3800,$0000,$00B7,$3800,$0000,$00B7,$3800
L0001518C   dc.w    $0000,$0097,$3800,$0000,$0091,$B800,$0000,$0093
L0001519C   dc.w    $F800,$0000,$0093,$F800,$0000,$0097,$F800,$0000
L000151AC   dc.w    $009F,$F800,$0000,$0080,$3800,$0000,$007F,$F000
L000151BC   dc.w    $0000,$000A,$C000,$0000

L000151C4   dc.w    $000A,$C000,$0000,$000F
L000151CC   dc.w    $C000,$0000,$000A,$C000,$0000,$000E,$C000,$0000
L000151DC   dc.w    $000E,$C000,$0000,$000E,$C000,$0000,$000E,$C000
L000151EC   dc.w    $0000,$000E,$C000,$0000,$000E,$C000,$0000,$000E
L000151FC   dc.w    $C000,$0000,$000A,$C000,$0000,$0008,$C000,$0000
L0001520C   dc.w    $0019,$C000,$0000,$003C,$6000,$0000,$0078,$3000
L0001521C   dc.w    $0000,$0070,$1800,$0000,$00EF,$D800,$0000,$00D0
L0001522C   dc.w    $5C00,$0000,$00D3,$1C00,$0000,$00D7,$1C00,$0000
L0001523C   dc.w    $00D7,$1C00,$0000,$00D7,$1C00,$0000,$00D1,$9C00
L0001524C   dc.w    $0000,$00D3,$DC00,$0000,$00D3,$DC00,$0000,$00D7
L0001525C   dc.w    $DC00,$0000,$00C0,$1C00,$0000,$00C0,$3C00,$0000
L0001526C   dc.w    $007F,$F800,$0000,$0007,$0000,$0000

L00015278   dc.w    $0007,$0000
L0001527C   dc.w    $0000,$0000,$0000,$0000,$0007,$0000,$0000,$0007
L0001528C   dc.w    $0000,$0000,$0007,$0000,$0000,$0007,$0000,$0000
L0001529C   dc.w    $0007,$0000,$0000,$0007,$0000,$0000,$0007,$0000
L000152AC   dc.w    $0000,$0007,$0000,$0000,$0007,$0000,$0000,$0007
L000152BC   dc.w    $0000,$0000,$000E,$0000,$0000,$001F,$8000,$0000
L000152CC   dc.w    $003F,$C000,$0000,$003F,$E000,$0000,$0070,$2000
L000152DC   dc.w    $0000,$006F,$8000,$0000,$006C,$C000,$0000,$0068
L000152EC   dc.w    $C000,$0000,$0068,$C000,$0000,$0068,$C000,$0000
L000152FC   dc.w    $006E,$4000,$0000,$006C,$0000,$0000,$006C,$0000
L0001530C   dc.w    $0000,$0068,$0000,$0000,$0060,$0000,$0000,$007F
L0001531C   dc.w    $C000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001532C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001533C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001534C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001535C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001536C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001537C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001538C   dc.w    $000F,$C000,$0000,$001F,$C000,$0000,$001F,$C000
L0001539C   dc.w    $0000,$001F,$C000,$0000,$001F,$C000,$0000,$001F
L000153AC   dc.w    $C000,$0000,$001F,$C000,$0000,$001F,$C000,$0000
L000153BC   dc.w    $001F,$C000,$0000,$001F,$C000,$0000,$0000,$0000
L000153CC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L000153DC   dc.w    $0130,$0000

L000153E0   dc.w    $0000,$0000,$0000,$0000,$0000,$0000
L000153EC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L000153FC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001540C   dc.w    $0000,$0000,$0000,$0000,$0000,$002A,$D800,$0000
L0001541C   dc.w    $002A,$D800,$0000,$0000,$0000,$0000,$003F,$F800
L0001542C   dc.w    $0000,$003B,$F800,$0000,$003B,$F800,$0000,$003B
L0001543C   dc.w    $F800,$0000,$003F,$F800,$0000,$003B,$F800,$0000
L0001544C   dc.w    $003F,$F800,$0000,$003F,$F800,$0000,$003F,$F800
L0001545C   dc.w    $0000,$001F,$F000,$0000,$0000,$0000,$0000,$0000
L0001546C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001547C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001548C   dc.w    $0000,$0000,$0000,$0000

L00015494   dc.w    $0000,$0000,$0000,$0000
L0001549C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L000154AC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L000154BC   dc.w    $0000,$0000,$0000,$0000,$003F,$F800,$0000,$0064
L000154CC   dc.w    $A400,$0000,$0064,$A400,$0000,$003F,$F800,$0000
L000154DC   dc.w    $007F,$FC00,$0000,$0044,$0400,$0000,$0044,$0400
L000154EC   dc.w    $0000,$0044,$0400,$0000,$0040,$0400,$0000,$0040
L000154FC   dc.w    $0400,$0000,$0040,$0400,$0000,$0040,$0400,$0000
L0001550C   dc.w    $0040,$0400,$0000,$0060,$0C00,$0000,$003F,$F800
L0001551C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001552C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001553C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000

L00015548   dc.w    $0000,$0000
L0001554C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001555C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001556C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001557C   dc.w    $0000,$001F,$0000,$0000,$001F,$0000,$0000,$0000
L0001558C   dc.w    $0000,$0000,$0000,$0000,$0000,$001F,$8000,$0000
L0001559C   dc.w    $001F,$8000,$0000,$001F,$8000,$0000,$001F,$8000
L000155AC   dc.w    $0000,$001F,$8000,$0000,$001F,$8000,$0000,$001F
L000155BC   dc.w    $8000,$0000,$000F,$0000,$0000,$0000,$0000,$0000
L000155CC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L000155DC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L000155EC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L000155FC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001560C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001561C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001562C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001563C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$001B
L0001564C   dc.w    $8000,$0000,$001B,$8000,$0000,$001B,$8000,$0000
L0001565C   dc.w    $001B,$8000,$0000,$001B,$8000,$0000,$001F,$8000
L0001566C   dc.w    $0000,$001F,$8000,$0000,$000F,$0000,$0000,$0000
L0001567C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001568C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001569C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L000156AC   dc.w    $0130,$0000

L000156B0   dc.w    $0003,$0000,$0000,$0003,$0000,$0000
L000156BC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$000A,$8000
L000156CC   dc.w    $0000,$0011,$4000,$0000,$000E,$0000,$0000,$0007
L000156DC   dc.w    $8000,$0000,$000C,$8000,$0000,$0008,$8000,$0000
L000156EC   dc.w    $0000,$8000,$0000,$0002,$8000,$0000,$0002,$8000
L000156FC   dc.w    $0000,$0003,$8000,$0000,$0013,$8000,$0000,$0013
L0001570C   dc.w    $8000,$0000,$001B,$8000,$0000,$001B,$8000,$0000
L0001571C   dc.w    $001A,$8000,$0000,$0018,$8000,$0000,$0018,$8000
L0001572C   dc.w    $0000,$0019,$8000,$0000,$0012,$8000,$0000,$000E
L0001573C   dc.w    $8000,$0000,$000D,$0000,$0000,$0009,$0000,$0000
L0001574C   dc.w    $0006,$0000,$0000,$003F,$C000,$0000,$0024,$C000
L0001575C   dc.w    $0000,$0005,$0000,$0000

L00015764   dc.w    $0005,$0000,$0000,$0005
L0001576C   dc.w    $0000,$0000,$0007,$0000,$0000,$0007,$0000,$0000
L0001577C   dc.w    $0004,$8000,$0000,$000E,$4000,$0000,$0007,$C000
L0001578C   dc.w    $0000,$0000,$C000,$0000,$0003,$C000,$0000,$0007
L0001579C   dc.w    $4000,$0000,$000F,$4000,$0000,$000D,$4000,$0000
L000157AC   dc.w    $000D,$4000,$0000,$000C,$4000,$0000,$000C,$4000
L000157BC   dc.w    $0000,$000C,$C000,$0000,$0005,$C000,$0000,$0005
L000157CC   dc.w    $C000,$0000,$0005,$C000,$0000,$000F,$C000,$0000
L000157DC   dc.w    $001F,$C000,$0000,$001E,$C000,$0000,$001C,$C000
L000157EC   dc.w    $0000,$0000,$C000,$0000,$0001,$C000,$0000,$0001
L000157FC   dc.w    $C000,$0000,$0007,$C000,$0000,$003F,$C000,$0000
L0001580C   dc.w    $0018,$0000,$0000,$0006,$0000,$0000

L00015818   dc.w    $0006,$0000
L0001581C   dc.w    $0000,$0006,$0000,$0000,$0000,$0000,$0000,$0000
L0001582C   dc.w    $0000,$0000,$000F,$0000,$0000,$001F,$8000,$0000
L0001583C   dc.w    $0018,$0000,$0000,$001F,$0000,$0000,$001F,$0000
L0001584C   dc.w    $0000,$001F,$0000,$0000,$001F,$0000,$0000,$001F
L0001585C   dc.w    $0000,$0000,$001F,$0000,$0000,$001F,$0000,$0000
L0001586C   dc.w    $000F,$0000,$0000,$000F,$8000,$0000,$000F,$8000
L0001587C   dc.w    $0000,$000F,$0000,$0000,$000F,$0000,$0000,$000F
L0001588C   dc.w    $0000,$0000,$001F,$0000,$0000,$001F,$0000,$0000
L0001589C   dc.w    $001F,$0000,$0000,$001F,$0000,$0000,$001E,$0000
L000158AC   dc.w    $0000,$001E,$0000,$0000,$0018,$0000,$0000,$0000
L000158BC   dc.w    $0000,$0000,$003F,$C000,$0000,$0000,$0000,$0000
L000158CC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L000158DC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L000158EC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L000158FC   dc.w    $0000,$0000,$0000,$0000,$8000,$0000,$0001,$8000
L0001590C   dc.w    $0000,$0001,$8000,$0000,$0001,$8000,$0000,$0009
L0001591C   dc.w    $0000,$0000,$0019,$0000,$0000,$0019,$8000,$0000
L0001592C   dc.w    $0018,$8000,$0000,$0008,$0000,$0000,$0008,$0000
L0001593C   dc.w    $0000,$0000,$0000,$0000,$0010,$0000,$0000,$0010
L0001594C   dc.w    $0000,$0000,$0010,$0000,$0000,$0000,$0000,$0000
L0001595C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001596C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001597C   dc.w    $0130,$0000

L00015980   dc.w    $0000,$0000,$0000,$0000,$0000,$0000
L0001598C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$8000
L0001599C   dc.w    $0000,$0000,$8000,$0000,$0000,$8000,$0000,$0004
L000159AC   dc.w    $8000,$0000,$0004,$8000,$0000,$0004,$8000,$0000
L000159BC   dc.w    $0004,$8000,$0000,$0004,$8000,$0000,$0004,$8000
L000159CC   dc.w    $0000,$0004,$8000,$0000,$0004,$8000,$0000,$0004
L000159DC   dc.w    $8000,$0000,$0000,$0000,$0000,$0004,$8000,$0000
L000159EC   dc.w    $0004,$8000,$0000,$0004,$8000,$0000,$0004,$8000
L000159FC   dc.w    $0000,$0004,$8000,$0000,$0004,$8000,$0000,$0004
L00015A0C   dc.w    $8000,$0000,$0004,$8000,$0000,$0004,$8000,$0000
L00015A1C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00015A2C   dc.w    $0000,$0000,$0000,$0000

L00015A34   dc.w    $0000,$0000,$0000,$0000
L00015A3C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00015A4C   dc.w    $0000,$0000,$0000,$0001,$0000,$0000,$0001,$0000
L00015A5C   dc.w    $0000,$0001,$0000,$0000,$0001,$0000,$0000,$0001
L00015A6C   dc.w    $0000,$0000,$0001,$0000,$0000,$0001,$0000,$0000
L00015A7C   dc.w    $0001,$0000,$0000,$0006,$8000,$0000,$0006,$8000
L00015A8C   dc.w    $0000,$0006,$8000,$0000,$0000,$0000,$0000,$0006
L00015A9C   dc.w    $8000,$0000,$0006,$8000,$0000,$0006,$8000,$0000
L00015AAC   dc.w    $0006,$8000,$0000,$0006,$8000,$0000,$0006,$8000
L00015ABC   dc.w    $0000,$0006,$8000,$0000,$0006,$8000,$0000,$0006
L00015ACC   dc.w    $8000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00015ADC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000

L00015AE8   dc.w    $0000,$0000
L00015AEC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00015AFC   dc.w    $0000,$0000,$0000,$0000,$0000,$0001,$0000,$0000
L00015B0C   dc.w    $0001,$0000,$0000,$0001,$0000,$0000,$0001,$0000
L00015B1C   dc.w    $0000,$0001,$0000,$0000,$0001,$0000,$0000,$0001
L00015B2C   dc.w    $0000,$0000,$0001,$0000,$0000,$0003,$0000,$0000
L00015B3C   dc.w    $0003,$0000,$0000,$0003,$0000,$0000,$0000,$0000
L00015B4C   dc.w    $0000,$0003,$0000,$0000,$0003,$0000,$0000,$0003
L00015B5C   dc.w    $0000,$0000,$0003,$0000,$0000,$0003,$0000,$0000
L00015B6C   dc.w    $0003,$0000,$0000,$0003,$0000,$0000,$0003,$0000
L00015B7C   dc.w    $0000,$0003,$0000,$0000,$0000,$0000,$0000,$0000
L00015B8C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00015B9C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00015BAC   dc.w    $0000,$0000,$0000,$0000,$0000,$8000,$0000,$0001
L00015BBC   dc.w    $8000,$0000,$0003,$8000,$0000,$0007,$8000,$0000
L00015BCC   dc.w    $0007,$8000,$0000,$0007,$8000,$0000,$0007,$8000
L00015BDC   dc.w    $0000,$0007,$8000,$0000,$0007,$8000,$0000,$0000
L00015BEC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00015BFC   dc.w    $0000,$0000,$0000,$0005,$8000,$0000,$0005,$8000
L00015C0C   dc.w    $0000,$0005,$8000,$0000,$0005,$8000,$0000,$0005
L00015C1C   dc.w    $8000,$0000,$0005,$8000,$0000,$0005,$8000,$0000
L00015C2C   dc.w    $0005,$8000,$0000,$0005,$8000,$0000,$0000,$0000
L00015C3C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00015C4C   dc.w    $0130,$0000

L00015C50   dc.w    $0000,$8000,$0000,$0001,$8000,$0000
L00015C5C   dc.w    $0000,$0000,$0000,$0000,$C000,$0000,$0001,$A000
L00015C6C   dc.w    $0000,$0000,$D000,$0000,$001F,$1000,$0000,$0015
L00015C7C   dc.w    $9000,$0000,$0015,$9000,$0000,$0015,$9000,$0000
L00015C8C   dc.w    $0015,$9000,$0000,$001F,$F000,$0000,$001F,$F000
L00015C9C   dc.w    $0000,$001F,$F000,$0000,$001F,$F000,$0000,$001F
L00015CAC   dc.w    $F000,$0000,$001F,$F000,$0000,$001F,$F000,$0000
L00015CBC   dc.w    $001F,$F000,$0000,$001F,$F000,$0000,$001F,$F000
L00015CCC   dc.w    $0000,$001F,$F000,$0000,$001F,$F000,$0000,$0015
L00015CDC   dc.w    $9000,$0000,$0015,$9000,$0000,$0015,$9000,$0000
L00015CEC   dc.w    $0015,$9000,$0000,$0005,$8000,$0000,$0000,$0000
L00015CFC   dc.w    $0000,$0001,$0000,$0000

L00015D04   dc.w    $0001,$0000,$0000,$0001
L00015D0C   dc.w    $8000,$0000,$0001,$8000,$0000,$0000,$E000,$0000
L00015D1C   dc.w    $0006,$3000,$0000,$000F,$1800,$0000,$001F,$F800
L00015D2C   dc.w    $0000,$0012,$1800,$0000,$0012,$1800,$0000,$0012
L00015D3C   dc.w    $1800,$0000,$0012,$1800,$0000,$0010,$0800,$0000
L00015D4C   dc.w    $001F,$F800,$0000,$0000,$0800,$0000,$0000,$0800
L00015D5C   dc.w    $0000,$0000,$0800,$0000,$0000,$0800,$0000,$0000
L00015D6C   dc.w    $0800,$0000,$0000,$0800,$0000,$0000,$0800,$0000
L00015D7C   dc.w    $0010,$0800,$0000,$001F,$F800,$0000,$0010,$0800
L00015D8C   dc.w    $0000,$0012,$1800,$0000,$0012,$1800,$0000,$0012
L00015D9C   dc.w    $1800,$0000,$0012,$1800,$0000,$0012,$1800,$0000
L00015DAC   dc.w    $000F,$F000,$0000,$0001,$8000,$0000

L00015DB8   dc.w    $0001,$8000
L00015DBC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0007
L00015DCC   dc.w    $0000,$0000,$000F,$C000,$0000,$001F,$E000,$0000
L00015DDC   dc.w    $0000,$0000,$0000,$000F,$E000,$0000,$000F,$E000
L00015DEC   dc.w    $0000,$000F,$E000,$0000,$000F,$E000,$0000,$0007
L00015DFC   dc.w    $4000,$0000,$0000,$0000,$0000,$0007,$4000,$0000
L00015E0C   dc.w    $0007,$4000,$0000,$0007,$4000,$0000,$0007,$4000
L00015E1C   dc.w    $0000,$0007,$4000,$0000,$0007,$4000,$0000,$0007
L00015E2C   dc.w    $4000,$0000,$0007,$4000,$0000,$0000,$0000,$0000
L00015E3C   dc.w    $0007,$4000,$0000,$000F,$E000,$0000,$000F,$E000
L00015E4C   dc.w    $0000,$000F,$E000,$0000,$000F,$E000,$0000,$000F
L00015E5C   dc.w    $E000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00015E6C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00015E7C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00015E8C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00015E9C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00015EAC   dc.w    $0000,$0007,$4000,$0000,$0000,$0000,$0000,$0007
L00015EBC   dc.w    $4000,$0000,$0007,$4000,$0000,$0007,$4000,$0000
L00015ECC   dc.w    $0007,$4000,$0000,$0007,$4000,$0000,$0007,$4000
L00015EDC   dc.w    $0000,$0007,$4000,$0000,$0007,$4000,$0000,$0000
L00015EEC   dc.w    $0000,$0000,$0007,$4000,$0000,$0000,$0000,$0000
L00015EFC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00015F0C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00015F1C   dc.w    $0130,$0000

L00015F20   dc.w    $001B,$4000,$0000,$0018,$4000,$0000
L00015F2C   dc.w    $0019,$4000,$0000,$0019,$4000,$0000,$0000,$0000
L00015F3C   dc.w    $0000,$0019,$4000,$0000,$0019,$4000,$0000,$0019
L00015F4C   dc.w    $4000,$0000,$0019,$4000,$0000,$0019,$4000,$0000
L00015F5C   dc.w    $0008,$A000,$0000,$0008,$A000,$0000,$0008,$A000
L00015F6C   dc.w    $0000,$0008,$A000,$0000,$0008,$A000,$0000,$0008
L00015F7C   dc.w    $A000,$0000,$0008,$A000,$0000,$0008,$A000,$0000
L00015F8C   dc.w    $0008,$A000,$0000,$0008,$A000,$0000,$0008,$A000
L00015F9C   dc.w    $0000,$0008,$A000,$0000,$0019,$4000,$0000,$0019
L00015FAC   dc.w    $4000,$0000,$0019,$4000,$0000,$0019,$4000,$0000
L00015FBC   dc.w    $0019,$4000,$0000,$001F,$C000,$0000,$0000,$0000
L00015FCC   dc.w    $0000,$0000,$2000,$0000

L00015FD4   dc.w    $0000,$2000,$0000,$0000
L00015FDC   dc.w    $2000,$0000,$0002,$2000,$0000,$0002,$2000,$0000
L00015FEC   dc.w    $001F,$E000,$0000,$0002,$2000,$0000,$0002,$2000
L00015FFC   dc.w    $0000,$0002,$2000,$0000,$0002,$2000,$0000,$0002
L0001600C   dc.w    $2000,$0000,$0007,$2000,$0000,$0007,$2000,$0000
L0001601C   dc.w    $0007,$2000,$0000,$0007,$2000,$0000,$0007,$2000
L0001602C   dc.w    $0000,$0007,$2000,$0000,$0007,$2000,$0000,$0007
L0001603C   dc.w    $2000,$0000,$0007,$2000,$0000,$0007,$2000,$0000
L0001604C   dc.w    $0007,$2000,$0000,$0007,$2000,$0000,$0002,$2000
L0001605C   dc.w    $0000,$0002,$2000,$0000,$0002,$2000,$0000,$0002
L0001606C   dc.w    $2000,$0000,$0000,$2000,$0000,$001F,$E000,$0000
L0001607C   dc.w    $001F,$E000,$0000,$0000,$0000,$0000

L00016088   dc.w    $0000,$0000
L0001608C   dc.w    $0000,$0000,$0000,$0000,$0003,$0000,$0000,$0003
L0001609C   dc.w    $0000,$0000,$0000,$0000,$0000,$0003,$0000,$0000
L000160AC   dc.w    $0003,$0000,$0000,$0003,$0000,$0000,$0003,$0000
L000160BC   dc.w    $0000,$0003,$0000,$0000,$001F,$C000,$0000,$001F
L000160CC   dc.w    $C000,$0000,$001F,$C000,$0000,$001F,$C000,$0000
L000160DC   dc.w    $001F,$C000,$0000,$001F,$C000,$0000,$001F,$C000
L000160EC   dc.w    $0000,$001F,$C000,$0000,$001F,$C000,$0000,$001F
L000160FC   dc.w    $C000,$0000,$001F,$C000,$0000,$001F,$C000,$0000
L0001610C   dc.w    $0003,$0000,$0000,$0003,$0000,$0000,$0003,$0000
L0001611C   dc.w    $0000,$0003,$0000,$0000,$0003,$8000,$0000,$0000
L0001612C   dc.w    $0000,$0000,$0000,$0000,$0000,$001F,$C000,$0000
L0001613C   dc.w    $001F,$C000,$0000,$001F,$C000,$0000,$001C,$C000
L0001614C   dc.w    $0000,$001C,$C000,$0000,$0000,$0000,$0000,$001C
L0001615C   dc.w    $C000,$0000,$001C,$C000,$0000,$001C,$C000,$0000
L0001616C   dc.w    $001C,$C000,$0000,$001C,$C000,$0000,$0000,$0000
L0001617C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001618C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001619C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L000161AC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L000161BC   dc.w    $0000,$0000,$001C,$C000,$0000,$001C,$C000,$0000
L000161CC   dc.w    $001C,$C000,$0000,$001C,$C000,$0000,$001C,$4000
L000161DC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L000161EC   dc.w    $0130,$0000

L000161F0   dc.w    $0000,$0000,$0000,$0000,$0000,$0000
L000161FC   dc.w    $0000,$0180,$0000,$0000,$0340,$0000,$0000,$0420
L0001620C   dc.w    $0000,$0000,$0620,$0000,$00C7,$0420,$0000,$012B
L0001621C   dc.w    $C240,$0000,$01FC,$7180,$0000,$0300,$0C00,$0000
L0001622C   dc.w    $0400,$0300,$0000,$01D5,$D880,$0000,$07FD,$FD80
L0001623C   dc.w    $0000,$0115,$5500,$0000,$0515,$5500,$0000,$01D7
L0001624C   dc.w    $DD00,$0000,$0455,$5100,$0000,$0455,$5100,$0000
L0001625C   dc.w    $05DD,$5100,$0000,$0400,$0100,$0000,$0200,$0200
L0001626C   dc.w    $0000,$03FF,$FE00,$0000,$01FF,$FC00,$0000,$0000
L0001627C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001628C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001629C   dc.w    $0000,$0000,$0000,$0000

L000162A4   dc.w    $0000,$0000,$0000,$0000
L000162AC   dc.w    $0000,$0000,$0000,$0180,$0000,$0000,$0240,$0000
L000162BC   dc.w    $0000,$0620,$0000,$0000,$0420,$0000,$00C0,$0420
L000162CC   dc.w    $0000,$01A4,$0240,$0000,$0003,$8180,$0000,$00FF
L000162DC   dc.w    $F000,$0000,$03FF,$FC00,$0000,$062A,$2700,$0000
L000162EC   dc.w    $05DF,$DF00,$0000,$0717,$7700,$0000,$05D7,$DF00
L000162FC   dc.w    $0000,$05D5,$DF00,$0000,$0455,$5300,$0000,$05DD
L0001630C   dc.w    $5100,$0000,$05DD,$5300,$0000,$0400,$0100,$0000
L0001631C   dc.w    $03DF,$D200,$0000,$01FF,$FC00,$0000,$0000,$0000
L0001632C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001633C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001634C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000

L00016358   dc.w    $0000,$0000
L0001635C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001636C   dc.w    $0100,$0000,$0000,$0200,$0000,$0000,$0200,$0000
L0001637C   dc.w    $0007,$0040,$0000,$008F,$C080,$0000,$01FF,$F000
L0001638C   dc.w    $0000,$03FF,$FC00,$0000,$07FF,$FF00,$0000,$07FF
L0001639C   dc.w    $FF80,$0000,$0222,$2280,$0000,$06EA,$AA00,$0000
L000163AC   dc.w    $02EA,$AA00,$0000,$062A,$2200,$0000,$03AA,$AE00
L000163BC   dc.w    $0000,$03AA,$AE00,$0000,$0222,$AE00,$0000,$03FF
L000163CC   dc.w    $FE00,$0000,$01FF,$FC00,$0000,$0000,$0000,$0000
L000163DC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L000163EC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L000163FC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001640C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001641C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001642C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001643C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001644C   dc.w    $0000,$0000,$0000,$0000,$05DD,$DD00,$0000,$01FD
L0001645C   dc.w    $DD00,$0000,$073D,$5500,$0000,$03FD,$FD00,$0000
L0001646C   dc.w    $07FF,$FD00,$0000,$0677,$FF00,$0000,$07FF,$FD00
L0001647C   dc.w    $0000,$07FF,$FF00,$0000,$0220,$2E00,$0000,$03FF
L0001648C   dc.w    $FE00,$0000,$01FF,$FC00,$0000,$0000,$0000,$0000
L0001649C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L000164AC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L000164BC   dc.w    $0000,$0000

L000164C0   dc.w    $0000,$8000,$0000,$0000,$0001,$4000
L000164CC   dc.w    $0000,$0000,$0001,$4000,$0000,$0000,$0002,$0000
L000164DC   dc.w    $0000,$0000,$0003,$8000,$0000,$0000,$0004,$8000
L000164EC   dc.w    $0000,$0000,$0007,$0000,$0000,$0000,$000C,$0000
L000164FC   dc.w    $0000,$0000,$0007,$0000,$0000,$0000,$000C,$0000
L0001650C   dc.w    $0000,$0000,$000A,$0000,$0000,$0000,$0010,$0000
L0001651C   dc.w    $0000,$0000,$0004,$0000,$0000,$0000,$0030,$4000
L0001652C   dc.w    $0000,$0000,$0000,$9000,$0000,$0000,$0040,$6200
L0001653C   dc.w    $0000,$0000,$0009,$1480,$0000,$0000,$0002,$4600
L0001654C   dc.w    $0000,$0000,$0231,$A910,$0000,$0000,$0468,$0028
L0001655C   dc.w    $0000,$0000,$0034,$1110,$0000,$0000,$0406,$0248
L0001656C   dc.w    $0000,$0000,$04E1,$E080,$0000,$0000,$0438,$6028
L0001657C   dc.w    $0000,$0000,$00CA,$1610,$0000,$0000,$0033,$81C0
L0001658C   dc.w    $0000,$0000,$004C,$4820,$0000,$0000,$0011,$1B00
L0001659C   dc.w    $0000,$0000,$000C,$2380,$0000,$0000,$0007,$0CC0
L000165AC   dc.w    $0000,$0000,$000B,$6120,$0000,$0000,$0012,$FCC0
L000165BC   dc.w    $0000,$0000,$0004,$A800,$0000,$0000,$0001,$ABC0
L000165CC   dc.w    $0000,$0000,$0002,$5780,$0000,$0000,$0000,$1400
L000165DC   dc.w    $0000,$0000,$0000,$0A00,$0000,$0000,$0000,$0000
L000165EC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L000165FC   dc.w    $0000,$0000,$0005,$A000,$0000,$0000,$0000,$0400
L0001660C   dc.w    $0000,$0000,$000B,$2200,$0000,$0000,$0020,$6A00
L0001661C   dc.w    $0000,$0000,$0000,$1100,$0000,$0000,$000B,$4200
L0001662C   dc.w    $0000,$0000,$0020,$0900,$0000,$0000,$0000,$0200
L0001663C   dc.w    $0000,$0000,$0000,$0600,$0000,$0000,$001F,$E000
L0001664C   dc.w    $0000,$0000,$0030,$1200,$0000,$0000,$0025,$8B00
L0001665C   dc.w    $0000,$0000,$0070,$EB00,$0000,$0000,$0071,$6A00
L0001666C   dc.w    $0000,$0000,$0076,$6840,$0000,$0000,$00E6,$7830
L0001667C   dc.w    $0000,$0000,$00E6,$740C,$0000,$0000,$00E4,$B413
L0001668C   dc.w    $0000,$0000,$00A4,$B274,$C000,$0000,$00A4,$B30F
L0001669C   dc.w    $1000,$0000,$01A4,$B700,$7000,$0000,$01CC,$B600
L000166AC   dc.w    $0C00,$0000,$014C,$B000,$0000,$0000,$014C,$B040
L000166BC   dc.w    $0000,$0000,$0148,$B0B0,$0000,$0000,$0149,$706E
L000166CC   dc.w    $0000,$0000,$0081,$70C5,$8000,$0000,$0289,$4C3C
L000166DC   dc.w    $E000,$0000,$0281,$4E01,$D000,$0000,$0291,$4E00
L000166EC   dc.w    $1800,$0000,$0299,$6A00,$0000,$0000,$0299,$6A00
L000166FC   dc.w    $0000,$0000,$0639,$6C00,$0000,$0000,$0632,$E800
L0001670C   dc.w    $0000,$0000,$0372,$A9E0,$0000,$0000,$03F2,$E89C
L0001671C   dc.w    $0000,$0000,$0132,$69EB,$0000,$0000,$0008,$C81C
L0001672C   dc.w    $C000,$0000,$2000,$1800,$A000,$0000,$1600,$2800
L0001673C   dc.w    $1000,$0000,$01CF,$DD00,$0000,$0000,$0033,$8200
L0001674C   dc.w    $0000,$0000,$00C0,$0C00,$0000,$0000,$004D,$B000
L0001675C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0001,$8000
L0001676C   dc.w    $0000,$0000

L00016770   dc.w    $0003,$C000,$0000,$0000,$0007,$6000
L0001677C   dc.w    $0000,$0000,$0007,$6000,$0000,$0000,$0006,$6000
L0001678C   dc.w    $0000,$0000,$000F,$C000,$0000,$0000,$000C,$C000
L0001679C   dc.w    $0000,$0000,$000F,$8000,$0000,$0000,$001D,$8000
L000167AC   dc.w    $0000,$0000,$001F,$8000,$0000,$0000,$001F,$0000
L000167BC   dc.w    $0000,$0000,$003F,$0000,$0000,$0000,$003F,$0000
L000167CC   dc.w    $0000,$0000,$007F,$7000,$0000,$0000,$006F,$D800
L000167DC   dc.w    $0000,$0000,$00F7,$8B80,$0000,$0000,$01DF,$EEC0
L000167EC   dc.w    $0000,$0000,$03EF,$7C40,$0000,$0000,$07FF,$BE78
L000167FC   dc.w    $0000,$0000,$07FF,$7FF4,$0000,$0000,$0BEF,$B9E2
L0001680C   dc.w    $0000,$0000,$0BE7,$F7F2,$0000,$0000,$0FFE,$FBDE
L0001681C   dc.w    $0000,$0000,$0F1E,$7FEC,$0000,$0000,$0FE7,$CF9C
L0001682C   dc.w    $0000,$0000,$0FF9,$E7FC,$0000,$0000,$07EF,$7E7C
L0001683C   dc.w    $0000,$0000,$07F3,$F7F8,$0000,$0000,$07CC,$5CF8
L0001684C   dc.w    $0000,$0000,$07E3,$9F38,$0000,$0000,$03E0,$E3D8
L0001685C   dc.w    $0000,$0000,$03E8,$9CF8,$0000,$0000,$03F8,$0330
L0001686C   dc.w    $0000,$0000,$01FC,$00F0,$0000,$0000,$01FD,$03F0
L0001687C   dc.w    $0000,$0000,$00FF,$57F0,$0000,$0000,$00FF,$D7F0
L0001688C   dc.w    $0000,$0000,$00FF,$FFF0,$0000,$0000,$007F,$FFE0
L0001689C   dc.w    $0000,$0000,$007F,$FFE0,$0000,$0000,$007F,$FFC0
L000168AC   dc.w    $0000,$0000,$00FF,$9FC0,$0000,$0000,$00FF,$F780
L000168BC   dc.w    $0000,$0000,$00FF,$1B00,$0000,$0000,$00FF,$FF80
L000168CC   dc.w    $0000,$0000,$00FF,$FBC0,$0000,$0000,$00FF,$3BC0
L000168DC   dc.w    $0000,$0000,$00FF,$FFC0,$0000,$0000,$00FF,$F3C0
L000168EC   dc.w    $0000,$0000,$00FF,$FFC0,$0000,$0000,$01FF,$FF80
L000168FC   dc.w    $0000,$0000,$01F3,$9F00,$0000,$0000,$01E2,$6F80
L0001690C   dc.w    $0000,$0000,$01EA,$9F80,$0000,$0000,$03EA,$DFC0
L0001691C   dc.w    $0000,$0000,$03E8,$DFF0,$0000,$0000,$03D0,$CFBC
L0001692C   dc.w    $0000,$0000,$07D0,$DFCF,$0000,$0000,$07D1,$9F83
L0001693C   dc.w    $C000,$0000,$0791,$9BF0,$F000,$0000,$0791,$9BFF
L0001694C   dc.w    $1800,$0000,$0791,$9B8F,$F400,$0000,$0FA1,$9B80
L0001695C   dc.w    $7E00,$0000,$0F21,$9FC0,$0C00,$0000,$0F21,$9FF0
L0001696C   dc.w    $0000,$0000,$0F21,$9FBE,$0000,$0000,$0F23,$1F0F
L0001697C   dc.w    $8000,$0000,$0E43,$1FC1,$E000,$0000,$0E43,$1BFC
L0001698C   dc.w    $7000,$0000,$1E43,$1BBF,$D800,$0000,$1E53,$1B81
L0001699C   dc.w    $FC00,$0000,$1E5B,$3B80,$1800,$0000,$1E5B,$3B80
L000169AC   dc.w    $0000,$0000,$3EBB,$3F00,$0000,$0000,$3EB6,$3FE0
L000169BC   dc.w    $0000,$0000,$3BF6,$3FFC,$0000,$0000,$3DF6,$7E1F
L000169CC   dc.w    $0000,$0000,$3E36,$7FE3,$C000,$0000,$7F88,$DFFC
L000169DC   dc.w    $E000,$0000,$7FF0,$3F1F,$B000,$0000,$3FFF,$EF00
L000169EC   dc.w    $F800,$0000,$17FF,$CF00,$1000,$0000,$09F0,$6F00
L000169FC   dc.w    $0000,$0000,$063F,$F600,$0000,$0000,$01B1,$4C00
L00016A0C   dc.w    $0000,$0000,$003F,$F000,$0000,$0000,$0000,$0000
L00016A1C   dc.w    $0000,$0000

L00016A20   dc.w    $0000,$0000,$0000,$0000,$0000,$8000
L00016A2C   dc.w    $0000,$0000,$0000,$8000,$0000,$0000,$0001,$8000
L00016A3C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0003,$0000
L00016A4C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0002,$0000
L00016A5C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00016A6C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00016A7C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0010,$2000
L00016A8C   dc.w    $0000,$0000,$0008,$7000,$0000,$0000,$0020,$1100
L00016A9C   dc.w    $0000,$0000,$0010,$8380,$0000,$0000,$0000,$4180
L00016AAC   dc.w    $0000,$0000,$0000,$8008,$0000,$0000,$0410,$461C
L00016ABC   dc.w    $0000,$0000,$0418,$080C,$0000,$0000,$0001,$0420
L00016ACC   dc.w    $0000,$0000,$00E1,$8010,$0000,$0000,$0018,$3060
L00016ADC   dc.w    $0000,$0000,$0007,$1800,$0000,$0000,$0010,$C180
L00016AEC   dc.w    $0000,$0000,$000C,$3800,$0000,$0000,$0033,$A700
L00016AFC   dc.w    $0000,$0000,$001C,$60C0,$0000,$0000,$001F,$9C20
L00016B0C   dc.w    $0000,$0000,$0017,$E300,$0000,$0000,$0007,$FCC0
L00016B1C   dc.w    $0000,$0000,$0003,$FF00,$0000,$0000,$0002,$FC00
L00016B2C   dc.w    $0000,$0000,$0000,$A800,$0000,$0000,$0000,$2800
L00016B3C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00016B4C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00016B5C   dc.w    $0000,$0000,$0000,$6000,$0000,$0000,$0000,$1800
L00016B6C   dc.w    $0000,$0000,$0000,$E400,$0000,$0000,$0000,$1000
L00016B7C   dc.w    $0000,$0000,$0000,$0C00,$0000,$0000,$0000,$C400
L00016B8C   dc.w    $0000,$0000,$0000,$3000,$0000,$0000,$0000,$0C00
L00016B9C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00016BAC   dc.w    $0000,$0000,$000F,$E000,$0000,$0000,$001F,$F000
L00016BBC   dc.w    $0000,$0000,$0017,$7000,$0000,$0000,$0017,$3000
L00016BCC   dc.w    $0000,$0000,$0017,$3000,$0000,$0000,$002F,$3040
L00016BDC   dc.w    $0000,$0000,$002F,$2070,$0000,$0000,$002E,$607C
L00016BEC   dc.w    $0000,$0000,$006E,$640F,$0000,$0000,$006E,$6400
L00016BFC   dc.w    $E000,$0000,$006E,$6400,$0800,$0000,$005E,$6400
L00016C0C   dc.w    $0000,$0000,$00DE,$6400,$0000,$0000,$00DE,$6400
L00016C1C   dc.w    $0000,$0000,$00DE,$6440,$0000,$0000,$00DC,$E4F0
L00016C2C   dc.w    $0000,$0000,$01BC,$E43E,$0000,$0000,$01BC,$E403
L00016C3C   dc.w    $8000,$0000,$01BC,$E400,$2000,$0000,$01AC,$E400
L00016C4C   dc.w    $0000,$0000,$01A4,$C400,$0000,$0000,$01A4,$C400
L00016C5C   dc.w    $0000,$0000,$0144,$C000,$0000,$0000,$0149,$C000
L00016C6C   dc.w    $0000,$0000,$0409,$C000,$0000,$0000,$0209,$81E0
L00016C7C   dc.w    $0000,$0000,$01C9,$801C,$0000,$0000,$0077,$2003
L00016C8C   dc.w    $0000,$0000,$000F,$C000,$4000,$0000,$0000,$1000
L00016C9C   dc.w    $0000,$0000,$0800,$3000,$0000,$0000,$060F,$F000
L00016CAC   dc.w    $0000,$0000,$01C0,$0800,$0000,$0000,$007E,$F000
L00016CBC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00016CCC   dc.w    $0000,$0000

L00016CD0   dc.w    $0000,$0000,$0000,$0000,$0000,$0000
L00016CDC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00016CEC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00016CFC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00016D0C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00016D1C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00016D2C   dc.w    $0000,$0000,$0001,$0000,$0000,$0000,$0001,$0000
L00016D3C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0080,$0000
L00016D4C   dc.w    $0000,$0000,$0180,$0000,$0000,$0000,$0100,$0000
L00016D5C   dc.w    $0000,$0000,$0102,$0000,$0000,$0000,$0201,$8800
L00016D6C   dc.w    $0000,$0000,$0200,$4600,$0000,$0000,$0200,$1800
L00016D7C   dc.w    $0000,$0000,$0200,$0600,$0000,$0000,$0040,$0080
L00016D8C   dc.w    $0000,$0000,$0430,$00E0,$0000,$0000,$0108,$0004
L00016D9C   dc.w    $0000,$0000,$0100,$0000,$0000,$0000,$0100,$0000
L00016DAC   dc.w    $0000,$0000,$0180,$0000,$0000,$0000,$0180,$0000
L00016DBC   dc.w    $0000,$0000,$0180,$0008,$0000,$0000,$01C0,$0000
L00016DCC   dc.w    $0000,$0000,$00C0,$0000,$0000,$0000,$00E0,$0000
L00016DDC   dc.w    $0000,$0000,$0070,$0000,$0000,$0000,$0078,$0000
L00016DEC   dc.w    $0000,$0000,$0078,$0010,$0000,$0000,$003E,$0040
L00016DFC   dc.w    $0000,$0000,$003F,$FF80,$0000,$0000,$0021,$FF00
L00016E0C   dc.w    $0000,$0000,$0070,$1E00,$0000,$0000,$007F,$8000
L00016E1C   dc.w    $0000,$0000,$0040,$1900,$0000,$0000,$0010,$0400
L00016E2C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0014,$0000
L00016E3C   dc.w    $0000,$0000,$0007,$C000,$0000,$0000,$0078,$0000
L00016E4C   dc.w    $0000,$0000,$0047,$E000,$0000,$0000,$0080,$1800
L00016E5C   dc.w    $0000,$0000,$0080,$0800,$0000,$0000,$0080,$0400
L00016E6C   dc.w    $0000,$0000,$0080,$0400,$0000,$0000,$0100,$0480
L00016E7C   dc.w    $0000,$0000,$0100,$0500,$0000,$0000,$0100,$0500
L00016E8C   dc.w    $0000,$0000,$0200,$0900,$0000,$0000,$0200,$0900
L00016E9C   dc.w    $0000,$0000,$0200,$0880,$0000,$0000,$0200,$0800
L00016EAC   dc.w    $0000,$0000,$0200,$0800,$0000,$0000,$0200,$0880
L00016EBC   dc.w    $0000,$0000,$0400,$0900,$0000,$0000,$0400,$0900
L00016ECC   dc.w    $0000,$0000,$0400,$0900,$0000,$0000,$0400,$0900
L00016EDC   dc.w    $0000,$0000,$0400,$0900,$0000,$0000,$0400,$0000
L00016EEC   dc.w    $0000,$0000,$0800,$0080,$0000,$0000,$0800,$0080
L00016EFC   dc.w    $0000,$0000,$0800,$0080,$0000,$0000,$0800,$1080
L00016F0C   dc.w    $0000,$0000,$1000,$1100,$0000,$0000,$1000,$1200
L00016F1C   dc.w    $0000,$0000,$1000,$1200,$0000,$0000,$1000,$1200
L00016F2C   dc.w    $0000,$0000,$0800,$1200,$0000,$0000,$2600,$1000
L00016F3C   dc.w    $0000,$0000,$11C0,$2100,$0000,$0000,$083F,$C100
L00016F4C   dc.w    $0000,$0000,$0600,$0200,$0000,$0000,$01C0,$0C00
L00016F5C   dc.w    $0000,$0000,$003F,$F000,$0000,$0000,$0000,$0000
L00016F6C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0130
L00016F7C   dc.w    $0000,$0000

L00016F80   dc.w    $0003,$C000,$0000,$0000,$0007,$E000
L00016F8C   dc.w    $0000,$0000,$0007,$E000,$0000,$0000,$0007,$E000
L00016F9C   dc.w    $0000,$0000,$000F,$C000,$0000,$0000,$000F,$C000
L00016FAC   dc.w    $0000,$0000,$000F,$8000,$0000,$0000,$001F,$8000
L00016FBC   dc.w    $0000,$0000,$001F,$8000,$0000,$0000,$001F,$0000
L00016FCC   dc.w    $0000,$0000,$003F,$0000,$0000,$0000,$003F,$0000
L00016FDC   dc.w    $0000,$0000,$007F,$7000,$0000,$0000,$007F,$F800
L00016FEC   dc.w    $0000,$0000,$00FF,$FB80,$0000,$0000,$01FF,$FFC0
L00016FFC   dc.w    $0000,$0000,$03FF,$FFC0,$0000,$0000,$07FF,$FFF8
L0001700C   dc.w    $0000,$0000,$07FF,$FFFC,$0000,$0000,$0FFF,$FFFE
L0001701C   dc.w    $0000,$0000,$0FFF,$FFFE,$0000,$0000,$0FFF,$FFFE
L0001702C   dc.w    $0000,$0000,$0FFF,$FFFC,$0000,$0000,$0FFF,$FFFC
L0001703C   dc.w    $0000,$0000,$0FFF,$FFFC,$0000,$0000,$07FF,$FFFC
L0001704C   dc.w    $0000,$0000,$07FF,$FFF8,$0000,$0000,$07FF,$FFF8
L0001705C   dc.w    $0000,$0000,$07FF,$FFF8,$0000,$0000,$03FF,$FFF8
L0001706C   dc.w    $0000,$0000,$03FF,$FFF8,$0000,$0000,$03FF,$FFF0
L0001707C   dc.w    $0000,$0000,$01FF,$FFF0,$0000,$0000,$01FF,$FFF0
L0001708C   dc.w    $0000,$0000,$00FF,$FFF0,$0000,$0000,$00FF,$FFF0
L0001709C   dc.w    $0000,$0000,$00FF,$FFF0,$0000,$0000,$007F,$FFE0
L000170AC   dc.w    $0000,$0000,$007F,$FFE0,$0000,$0000,$007F,$FFC0
L000170BC   dc.w    $0000,$0000,$00FF,$FFC0,$0000,$0000,$00FF,$FF80
L000170CC   dc.w    $0000,$0000,$00FF,$FF00,$0000,$0000,$00FF,$FF80
L000170DC   dc.w    $0000,$0000,$00FF,$FFC0,$0000,$0000,$00FF,$FFC0
L000170EC   dc.w    $0000,$0000,$00FF,$FFC0,$0000,$0000,$00FF,$FFC0
L000170FC   dc.w    $0000,$0000,$00FF,$FFC0,$0000,$0000,$01FF,$FF80
L0001710C   dc.w    $0000,$0000,$01FF,$FF00,$0000,$0000,$01FF,$FF80
L0001711C   dc.w    $0000,$0000,$01FF,$FF80,$0000,$0000,$03FF,$FFC0
L0001712C   dc.w    $0000,$0000,$03FF,$FFF0,$0000,$0000,$03FF,$FFFC
L0001713C   dc.w    $0000,$0000,$07FF,$FFFF,$0000,$0000,$07FF,$FFFF
L0001714C   dc.w    $C000,$0000,$07FF,$FFFF,$F000,$0000,$07FF,$FFFF
L0001715C   dc.w    $F800,$0000,$07FF,$FF8F,$FC00,$0000,$0FFF,$FF80
L0001716C   dc.w    $7E00,$0000,$0FFF,$FFC0,$0C00,$0000,$0FFF,$FFF0
L0001717C   dc.w    $0000,$0000,$0FFF,$FFFE,$0000,$0000,$0FFF,$FFFF
L0001718C   dc.w    $8000,$0000,$0FFF,$FFFF,$E000,$0000,$0FFF,$FFFF
L0001719C   dc.w    $F000,$0000,$1FFF,$FFBF,$F800,$0000,$1FFF,$FF81
L000171AC   dc.w    $FC00,$0000,$1FFF,$FF80,$1800,$0000,$1FFF,$FF80
L000171BC   dc.w    $0000,$0000,$3FFF,$FF00,$0000,$0000,$3FFF,$FFE0
L000171CC   dc.w    $0000,$0000,$3FFF,$FFFC,$0000,$0000,$3FFF,$FFFF
L000171DC   dc.w    $0000,$0000,$3FFF,$FFFF,$C000,$0000,$7FFF,$FFFF
L000171EC   dc.w    $E000,$0000,$7FFF,$FF1F,$F000,$0000,$3FFF,$FF00
L000171FC   dc.w    $F800,$0000,$1FFF,$FF00,$1000,$0000,$0FFF,$FF00
L0001720C   dc.w    $0000,$0000,$07FF,$FE00,$0000,$0000,$01FF,$FC00
L0001721C   dc.w    $0000,$0000,$003F,$F000,$0000,$0000,$0000,$0000
L0001722C   dc.w    $0000,$0000

L00017230   dc.w    $0003,$0000,$0000,$0000,$8000,$0000
L0001723C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$3000
L0001724C   dc.w    $0000,$0000,$0400,$0000,$0000,$0100,$0000,$0000
L0001725C   dc.w    $0000,$0000,$0019,$C000,$0000,$007F,$F000,$0000
L0001726C   dc.w    $0040,$7000,$0000,$0041,$6000,$0000,$0020,$0000
L0001727C   dc.w    $0000,$00B9,$F800,$0000,$00C4,$3800,$0000,$0002
L0001728C   dc.w    $9C00,$0000,$00D8,$5800,$0000,$0024,$0C00,$0000
L0001729C   dc.w    $0097,$5000,$0000,$005C,$D000,$0000,$006F,$9000
L000172AC   dc.w    $0000,$0007,$2000,$0000,$0010,$6000,$0000,$0038
L000172BC   dc.w    $A000,$0000,$0036,$A000,$0000,$0007,$C000,$0000
L000172CC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L000172DC   dc.w    $0000,$0000,$0000,$0000

L000172E4   dc.w    $0000,$0000,$0000,$0000
L000172EC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L000172FC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001730C   dc.w    $0000,$0000,$0000,$0000,$0019,$C000,$0000,$0060
L0001731C   dc.w    $3000,$0000,$007F,$9000,$0000,$002E,$0000,$0000
L0001732C   dc.w    $0053,$4000,$0000,$00C6,$0800,$0000,$00BA,$C800
L0001733C   dc.w    $0000,$00F8,$6000,$0000,$0027,$A400,$0000,$00D8
L0001734C   dc.w    $D000,$0000,$0060,$A800,$0000,$0020,$2000,$0000
L0001735C   dc.w    $0050,$6000,$0000,$0038,$C000,$0000,$000F,$A000
L0001736C   dc.w    $0000,$0007,$0000,$0000,$002A,$2000,$0000,$0000
L0001737C   dc.w    $4000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001738C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000

L00017398   dc.w    $0000,$0000
L0001739C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L000173AC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L000173BC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0006,$0000
L000173CC   dc.w    $0000,$001F,$C000,$0000,$003F,$E000,$0000,$0077
L000173DC   dc.w    $F000,$0000,$006E,$B000,$0000,$007F,$F000,$0000
L000173EC   dc.w    $007F,$F000,$0000,$007A,$FC00,$0000,$00FF,$FC00
L000173FC   dc.w    $0000,$00D8,$FC00,$0000,$00E7,$3800,$0000,$00F1
L0001740C   dc.w    $7000,$0000,$0038,$F000,$0000,$003F,$F000,$0000
L0001741C   dc.w    $003F,$D000,$0000,$003F,$E000,$0000,$001D,$C000
L0001742C   dc.w    $0000,$000F,$8000,$0000,$0000,$0000,$0000,$0000
L0001743C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001744C   dc.w    $0003,$0000,$0000,$0000,$C000,$0000,$0000,$6000
L0001745C   dc.w    $0000,$0000,$2000,$0000,$0000,$3000,$0000,$0000
L0001746C   dc.w    $0600,$0000,$0000,$0100,$0000,$0000,$0000,$0000
L0001747C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001748C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001749C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L000174AC   dc.w    $0000,$0000,$0000,$0027,$0000,$0000,$0010,$4000
L000174BC   dc.w    $0000,$000E,$8000,$0000,$0007,$0000,$0000,$0000
L000174CC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L000174DC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L000174EC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L000174FC   dc.w    $0000,$0000

L00017500   dc.w    $0000,$0000,$0000,$0000,$0000,$0000
L0001750C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001751C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001752C   dc.w    $0000,$0000,$0000,$0000,$00C0,$0000,$0000,$0000
L0001753C   dc.w    $0000,$0000,$0060,$0000,$0000,$0000,$0000,$0000
L0001754C   dc.w    $0030,$0000,$0000,$0000,$0000,$0000,$0018,$0000
L0001755C   dc.w    $0000,$0000,$0000,$0000,$000C,$0000,$0000,$0000
L0001756C   dc.w    $0000,$0000,$0006,$0000,$0000,$0000,$0000,$0000
L0001757C   dc.w    $0003,$0000,$0000,$0000,$0000,$0000,$0003,$8000
L0001758C   dc.w    $0000,$0000,$0000,$0000,$0001,$C000,$0000,$0000
L0001759C   dc.w    $0000,$0000,$0001,$C000,$0000,$0000,$0000,$0000
L000175AC   dc.w    $0000,$E000,$0000,$0000,$0000,$0000,$0000,$F000
L000175BC   dc.w    $0000,$0000,$0000,$0000,$0000,$7000,$0000,$0000
L000175CC   dc.w    $0000,$0000,$0000,$7800,$0000,$0000,$0000,$0000
L000175DC   dc.w    $0000,$3800,$0000,$0000,$0000,$0000,$0000,$0C00
L000175EC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L000175FC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001760C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001761C   dc.w    $7000,$0000,$0000,$0000,$0000,$0000,$0800,$0000
L0001762C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001763C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001764C   dc.w    $0020,$0000,$0000,$0007,$F800,$0000,$0010,$0000
L0001765C   dc.w    $0000,$01F8,$07C0,$0000,$0008,$0000,$0000,$1E07
L0001766C   dc.w    $F838,$0000,$0004,$0000,$0000,$63FF,$FFC6,$0000
L0001767C   dc.w    $0000,$0000,$0000,$9F00,$1E39,$8000,$0000,$0000
L0001768C   dc.w    $0000,$3800,$01CE,$4000,$0000,$0000,$0002,$6700
L0001769C   dc.w    $0023,$2000,$0000,$0000,$0004,$7000,$0019,$1000
L000176AC   dc.w    $0000,$0000,$0008,$C000,$0000,$9800,$0000,$0000
L000176BC   dc.w    $0011,$8000,$0004,$8C00,$0000,$0000,$0053,$1C00
L000176CC   dc.w    $0002,$C800,$0000,$0000,$0052,$C000,$0402,$4A00
L000176DC   dc.w    $0000,$0000,$00A5,$0000,$0000,$4D00,$0000,$0000
L000176EC   dc.w    $00A5,$F000,$039E,$6500,$0000,$0000,$002B,$FF20
L000176FC   dc.w    $027F,$2640,$0000,$0000,$002B,$2850,$029F,$9280
L0001770C   dc.w    $0000,$0000,$002A,$E411,$C490,$CA80,$0000,$0000
L0001771C   dc.w    $0053,$82FE,$2800,$C140,$0000,$0000,$0051,$00CC
L0001772C   dc.w    $1879,$D100,$0000,$0000,$0053,$9C82,$15A5,$2900
L0001773C   dc.w    $0000,$0000,$0057,$8072,$3300,$9D00,$0000,$0000
L0001774C   dc.w    $0063,$4C58,$0A42,$7200,$0000,$0000,$0065,$C52C
L0001775C   dc.w    $1E16,$7880,$0000,$0000,$00E0,$10D0,$0D8C,$CD00
L0001776C   dc.w    $0000,$0000,$00C1,$4600,$0A35,$76C0,$0000,$0000
L0001777C   dc.w    $00C4,$6070,$1501,$1A00,$0000,$0000,$00E8,$18E6
L0001778C   dc.w    $3BC4,$44C0,$0000,$0000,$00C9,$00C4,$11A0,$0A40
L0001779C   dc.w    $0000,$0000,$00A8,$0108,$1C5C,$2540,$0000,$0000
L000177AC   dc.w    $0082,$0018,$160A,$9200,$0000,$0000,$0062,$000C
L000177BC   dc.w    $110B,$3B08,$0000,$0000,$0054,$8046,$3080,$FB1C
L000177CC   dc.w    $0000,$0000,$006D,$0081,$E083,$6784,$0000,$0000
L000177DC   dc.w    $001A,$0181,$1D41,$B19A,$0000,$0000,$02CA,$0151
L000177EC   dc.w    $4ED0,$5B4A,$0000,$0000,$0074,$0360,$2388,$3CEA
L000177FC   dc.w    $0000,$0000,$0934,$0E00,$2000,$1572,$0000,$0000
L0001780C   dc.w    $0994,$6805,$6003,$07D0,$0000,$0000,$09D4,$C00D
L0001781C   dc.w    $F402,$CAB8,$0000,$0000,$09CC,$201B,$FB01,$21F6
L0001782C   dc.w    $0000,$0000,$0ACC,$381C,$0781,$A346,$0000,$0000
L0001783C   dc.w    $0AF2,$1EFB,$BBE3,$4104,$0000,$0000,$0232,$1F76
L0001784C   dc.w    $4D1F,$0508,$0000,$0000,$0266,$0800,$0002,$0AB0
L0001785C   dc.w    $0000,$0000,$0506,$143F,$FF86,$9EF8,$0000,$0000
L0001786C   dc.w    $0521,$0C5C,$6344,$3EC0,$0000,$0000,$02D9,$123F
L0001787C   dc.w    $0F8A,$29C4,$0000,$0000,$019B,$0C10,$5114,$73C0
L0001788C   dc.w    $0000,$0000,$0019,$0ABD,$57EC,$2298,$0000,$0000
L0001789C   dc.w    $0019,$057F,$FFD8,$C290,$0000,$0000,$0049,$059F
L000178AC   dc.w    $FF38,$C6A0,$0000,$0000,$0005,$C4E3,$F8F0,$8C80
L000178BC   dc.w    $0000,$0000,$002D,$C2B0,$07B1,$8880,$0000,$0000
L000178CC   dc.w    $000C,$E2C0,$0159,$5180,$0000,$0000,$0002,$D120
L000178DC   dc.w    $0030,$3580,$0000,$0000,$0006,$50A1,$0052,$A980
L000178EC   dc.w    $0000,$0000,$0001,$5060,$00A6,$7900,$0000,$0000
L000178FC   dc.w    $0001,$2830,$0065,$7900,$0000,$0000,$0003,$9808
L0001790C   dc.w    $0044,$BB00,$0000,$0000,$0003,$C000,$00CB,$7200
L0001791C   dc.w    $0000,$0000,$0002,$6400,$019E,$7200,$0000,$0000
L0001792C   dc.w    $0002,$3600,$0331,$E600,$0000,$0000,$0000,$9900
L0001793C   dc.w    $0023,$4400,$0000,$0000,$0001,$C780,$004F,$1C00
L0001794C   dc.w    $0000,$0000,$0001,$F6E0,$00DE,$6800,$0000,$0000
L0001795C   dc.w    $0001,$F538,$071E,$9000,$0000,$0000,$0001,$68CF
L0001796C   dc.w    $FFD5,$1000,$0000,$0000,$0001,$3430,$06A8,$2000
L0001797C   dc.w    $0000,$0000,$0000,$985F,$F550,$4000,$0000,$0000
L0001798C   dc.w    $0000,$461F,$8AE0,$8000,$0000,$0000,$0000,$2181
L0001799C   dc.w    $FFC1,$0000,$0000,$0000,$0000,$1878,$5796,$0000
L000179AC   dc.w    $0000,$0000,$0000,$0706,$AFCC,$0000,$0000,$0000
L000179BC   dc.w    $0000,$00C7,$FE30,$0000,$0000,$0000,$0000,$0038
L000179CC   dc.w    $01C0,$0000,$0000,$0000,$0000,$0007,$FE00,$0000
L000179DC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L000179EC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L000179FC   dc.w    $0000,$0000,$0000,$0000,$0000,$0100,$7000,$0000
L00017A0C   dc.w    $0000,$0000,$0000,$0800,$0E00,$0000,$0000,$0000
L00017A1C   dc.w    $0000,$4000,$0300,$0000,$0000,$0000,$0000,$0000
L00017A2C   dc.w    $0080,$0000,$0000,$0000,$0002,$0000,$0040,$0000
L00017A3C   dc.w    $0000,$0000,$0000,$0000,$0020,$0000,$0000,$0000
L00017A4C   dc.w    $0000,$0000,$0010,$0000,$0000,$0000,$0000,$0000
L00017A5C   dc.w    $0008,$0000,$0000,$0000,$0020,$0000,$0004,$0000
L00017A6C   dc.w    $0000,$0000,$0000,$0000,$0004,$0000,$0000,$0000
L00017A7C   dc.w    $0000,$0000,$0002,$0000,$0000,$0000,$0000,$0000
L00017A8C   dc.w    $0002,$0000,$0000,$0000,$0080,$0000,$0003,$0000
L00017A9C   dc.w    $0000,$0000,$0000,$0000,$0003,$0000,$0000,$0000
L00017AAC   dc.w    $0000,$0000,$0001,$8000,$0000,$0000,$0000,$0000
L00017ABC   dc.w    $0001,$8000,$0000,$0000,$0000,$0000,$0001,$C000
L00017ACC   dc.w    $0000,$0000,$0000,$0000,$0007,$F000,$0000,$0000
L00017ADC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00017AEC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0007
L00017AFC   dc.w    $8000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00017B0C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00017B1C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00017B2C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00017B3C   dc.w    $0000,$0007,$F800,$0000,$0000,$0000,$0000,$01F8
L00017B4C   dc.w    $07C0,$0000,$0000,$0000,$0000,$1E00,$003E,$0000
L00017B5C   dc.w    $0000,$0000,$0000,$6000,$0007,$0000,$0002,$0000
L00017B6C   dc.w    $0000,$80FF,$E001,$C000,$0002,$0000,$0000,$07FF
L00017B7C   dc.w    $FE00,$7000,$0001,$0000,$0002,$18FF,$FFC0,$3800
L00017B8C   dc.w    $0001,$0000,$0004,$0FFF,$FFE0,$1E00,$0000,$0000
L00017B9C   dc.w    $0008,$3FFF,$FFF8,$1F00,$0000,$0000,$0010,$7FFF
L00017BAC   dc.w    $FFF8,$0E80,$0000,$0000,$0050,$E3FF,$FFFE,$0F00
L00017BBC   dc.w    $0000,$0000,$0011,$3FFF,$FBFE,$0F00,$0000,$0000
L00017BCC   dc.w    $00A2,$FFFF,$FBF8,$0F80,$0000,$0000,$00A2,$0FFF
L00017BDC   dc.w    $F806,$0740,$0000,$0000,$0024,$F91F,$FC7F,$0760
L00017BEC   dc.w    $0000,$0000,$0025,$2FCF,$FC98,$03C0,$0000,$0000
L00017BFC   dc.w    $0024,$078E,$380F,$03E0,$0000,$0000,$004C,$7C01
L00017C0C   dc.w    $D1FF,$01F0,$0000,$0000,$004E,$FF03,$EB86,$11B0
L00017C1C   dc.w    $0000,$0000,$004C,$7001,$EE3C,$2198,$0000,$0000
L00017C2C   dc.w    $0048,$50B1,$CCFE,$8188,$0000,$0000,$005C,$EDAB
L00017C3C   dc.w    $EDDD,$00C0,$0000,$0000,$005A,$7DDB,$EB99,$00C0
L00017C4C   dc.w    $0000,$0000,$009F,$4C27,$F642,$31C0,$0000,$0000
L00017C5C   dc.w    $00BE,$A2EF,$F1C4,$88C0,$0000,$0000,$00BB,$9F8F
L00017C6C   dc.w    $E8FE,$E460,$0000,$0000,$0097,$E719,$C43B,$B8D0
L00017C7C   dc.w    $0000,$0000,$00B6,$FF3B,$EE1F,$F440,$0000,$0000
L00017C8C   dc.w    $0097,$FEF7,$E383,$DA40,$0000,$0000,$00BD,$FFE7
L00017C9C   dc.w    $E1E5,$6C60,$0000,$0000,$005D,$FFE3,$E2F4,$C440
L00017CAC   dc.w    $0000,$0000,$004B,$7F91,$DF7E,$0440,$0000,$0000
L00017CBC   dc.w    $00D0,$FF30,$037C,$0018,$0000,$0000,$00C1,$FE32
L00017CCC   dc.w    $023E,$0004,$0000,$0000,$0151,$FE0E,$B02F,$80C4
L00017CDC   dc.w    $0000,$0000,$03E3,$FC9F,$DC77,$C164,$0000,$0000
L00017CEC   dc.w    $0A83,$F1FF,$DFFF,$E0EC,$0000,$0000,$0A03,$87FA
L00017CFC   dc.w    $9FFC,$F24C,$0000,$0000,$0A03,$3FF0,$03FC,$3204
L00017D0C   dc.w    $0000,$0000,$0A13,$9FE0,$00FE,$180A,$0000,$0000
L00017D1C   dc.w    $0913,$87C0,$007E,$183A,$0000,$0000,$0909,$C108
L00017D2C   dc.w    $021C,$B87C,$0000,$0000,$01C9,$C011,$B1C0,$7070
L00017D3C   dc.w    $0000,$0000,$0189,$D0FF,$FFE1,$7100,$0000,$0000
L00017D4C   dc.w    $04E9,$E800,$6061,$6978,$0000,$0000,$04CC,$E020
L00017D5C   dc.w    $0082,$D1E4,$0000,$0000,$0214,$E400,$0004,$C4CC
L00017D6C   dc.w    $0000,$0000,$01B4,$F211,$0109,$A8CC,$0000,$0000
L00017D7C   dc.w    $00F6,$7100,$0011,$98DC,$0000,$0000,$00B6,$7880
L00017D8C   dc.w    $0023,$78DC,$0000,$0000,$00F6,$7860,$00C3,$30F8
L00017D9C   dc.w    $0000,$0000,$00F2,$381C,$0703,$F0F8,$0000,$0000
L00017DAC   dc.w    $007A,$3C4F,$F846,$60B0,$0000,$0000,$003B,$1C3F
L00017DBC   dc.w    $FEA6,$A180,$0000,$0000,$0019,$0E5F,$FFCF,$C180
L00017DCC   dc.w    $0000,$0000,$000D,$8F1E,$FFAD,$4180,$0000,$0000
L00017DDC   dc.w    $0000,$8F9F,$FF59,$9100,$0000,$0000,$0000,$C7CF
L00017DEC   dc.w    $FF9A,$A100,$0000,$0000,$0002,$67F7,$FFBB,$2300
L00017DFC   dc.w    $0000,$0000,$0003,$37FF,$FF34,$4200,$0000,$0000
L00017E0C   dc.w    $0002,$13FF,$FE60,$4200,$0000,$0000,$0002,$09FF
L00017E1C   dc.w    $FCC1,$8600,$0000,$0000,$0000,$04FF,$FFC3,$0400
L00017E2C   dc.w    $0000,$0000,$0001,$007F,$FF8E,$2C00,$0000,$0000
L00017E3C   dc.w    $0001,$001F,$FF1C,$0800,$0000,$0000,$0001,$0A07
L00017E4C   dc.w    $F810,$5000,$0000,$0000,$0001,$1700,$00C0,$9000
L00017E5C   dc.w    $0000,$0000,$0001,$4BC0,$0601,$A000,$0000,$0000
L00017E6C   dc.w    $0000,$A7A3,$F003,$4000,$0000,$0000,$0000,$59E0
L00017E7C   dc.w    $0006,$8000,$0000,$0000,$0000,$267E,$0009,$0000
L00017E8C   dc.w    $0000,$0000,$0000,$1887,$A806,$0000,$0000,$0000
L00017E9C   dc.w    $0000,$0739,$500C,$0000,$0000,$0000,$0000,$00C0
L00017EAC   dc.w    $0030,$0000,$0000,$0000,$0000,$0038,$01C0,$0000
L00017EBC   dc.w    $0000,$0000,$0000,$0007,$FE00,$0000,$0000,$0000
L00017ECC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000

L00017ED8   dc.w    $0000,$0000
L00017EDC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00017EEC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00017EFC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00017F0C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00017F1C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00017F2C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00017F3C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00017F4C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00017F5C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00017F6C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00017F7C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00017F8C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00017F9C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00017FAC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00017FBC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00017FCC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00017FDC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00017FEC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L00017FFC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001800C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001801C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001802C   dc.w    $0000,$0000,$0000,$0000,$0000,$0007,$F800,$0000
L0001803C   dc.w    $0000,$0000,$0000,$01FF,$FFC0,$0000,$0000,$0000
L0001804C   dc.w    $0000,$1FFF,$FFF8,$0000,$0000,$0000,$0000,$7FFF
L0001805C   dc.w    $FFFE,$0000,$0000,$0000,$0001,$FFFF,$FFFF,$8000
L0001806C   dc.w    $0000,$0000,$0001,$FFFF,$FFFF,$C000,$0000,$0000
L0001807C   dc.w    $0003,$FFFF,$FFFF,$E000,$0000,$0000,$0007,$FFFF
L0001808C   dc.w    $FFFF,$E000,$0000,$0000,$002F,$FFFF,$FFFF,$F000
L0001809C   dc.w    $0000,$0000,$002F,$FFFF,$FFFD,$F000,$0000,$0000
L000180AC   dc.w    $004F,$FFFF,$FFFD,$F000,$0000,$0000,$001F,$FFFF
L000180BC   dc.w    $FFFF,$F000,$0000,$0000,$001F,$FFFF,$FFF9,$F880
L000180CC   dc.w    $0000,$0000,$001F,$06FF,$FF80,$F880,$0000,$0000
L000180DC   dc.w    $001E,$D03F,$FF67,$FC00,$0000,$0000,$001F,$F87F
L000180EC   dc.w    $FFFF,$FC00,$0000,$0000,$003F,$FFFF,$FFFF,$FE00
L000180FC   dc.w    $0000,$0000,$003F,$FFFF,$F7FF,$EE00,$0000,$0000
L0001810C   dc.w    $003F,$E1FF,$F3C3,$DE00,$0000,$0000,$003F,$904F
L0001811C   dc.w    $F68D,$7E00,$0000,$0000,$003F,$22B7,$F126,$FF00
L0001812C   dc.w    $0000,$0000,$003F,$A0F7,$F106,$FF00,$0000,$0000
L0001813C   dc.w    $007F,$B03F,$FA0D,$FE00,$0000,$0000,$007F,$FCFF     
L0001814C   dc.w    $FFCB,$FF00,$0000,$0000,$007F,$FFFF,$FFFF,$FF80     
L0001815C   dc.w    $0000,$0000,$007F,$FFFF,$FFFF,$FF00,$0000,$0000     
L0001816C   dc.w    $007F,$FFFF,$FFFF,$FF80,$0000,$0000,$007F,$FFFF     
L0001817C   dc.w    $FFFF,$FF80,$0000,$0000,$007F,$FFFF,$FFFF,$FF80     
L0001818C   dc.w    $0000,$0000,$003F,$FFFF,$FFFF,$FF98,$0000,$0000     
L0001819C   dc.w    $003F,$FFFF,$E3FF,$FF9C,$0000,$0000,$033F,$FFF1     
L000181AC   dc.w    $E1FF,$FFDC,$0000,$0000,$073F,$FFF3,$FFFF,$FFFE     
L000181BC   dc.w    $0000,$0000,$07BF,$FFFF,$FFFF,$FFBE,$0000,$0000     
L000181CC   dc.w    $079F,$FFFF,$FFFF,$FF9E,$0000,$0000,$07FF,$FFFF     
L000181DC   dc.w    $FFFF,$FF9E,$0000,$0000,$07FF,$FFFF,$FFFF,$FDBE     
L000181EC   dc.w    $0000,$0000,$07FF,$FFF8,$E3FF,$FDFE,$0000,$0000     
L000181FC   dc.w    $07FF,$FFE0,$00FF,$FFFC,$0000,$0000,$07FF,$DFC0     
L0001820C   dc.w    $007F,$7FFC,$0000,$0000,$07FF,$E703,$B81C,$FFF8     
L0001821C   dc.w    $0000,$0000,$07FF,$E00F,$FE00,$FFFC,$0000,$0000     
L0001822C   dc.w    $07FF,$F000,$0001,$FFF8,$0000,$0000,$03FF,$F800     
L0001823C   dc.w    $0001,$F780,$0000,$0000,$03FF,$F800,$0003,$EF00     
L0001824C   dc.w    $0000,$0000,$01EF,$FC00,$0007,$FF00,$0000,$0000     
L0001825C   dc.w    $004F,$FE0F,$FE0F,$DF00,$0000,$0000,$000F,$FF01     
L0001826C   dc.w    $581F,$FF00,$0000,$0000,$004F,$FF80,$003F,$BF00     
L0001827C   dc.w    $0000,$0000,$000F,$FFE0,$00FF,$FF00,$0000,$0000     
L0001828C   dc.w    $000F,$FFFC,$07FF,$7F00,$0000,$0000,$0007,$FFFF     
L0001829C   dc.w    $FFFF,$FF00,$0000,$0000,$0007,$FFFF,$FFFF,$FE00     
L000182AC   dc.w    $0000,$0000,$0007,$FFFF,$FFFF,$FE00,$0000,$0000     
L000182BC   dc.w    $0003,$FFFF,$FFFF,$FE00,$0000,$0000,$0003,$FFFF     
L000182CC   dc.w    $FFFF,$EE00,$0000,$0000,$0003,$FFFF,$FFFF,$DE00     
L000182DC   dc.w    $0000,$0000,$0001,$FFFF,$FFFF,$DC00,$0000,$0000     
L000182EC   dc.w    $0000,$FFFF,$FFFF,$BC00,$0000,$0000,$0001,$FFFF     
L000182FC   dc.w    $FFFF,$BC00,$0000,$0000,$0001,$FFFF,$FFFE,$7800     
L0001830C   dc.w    $0000,$0000,$0001,$FFFF,$FFFC,$F800,$0000,$0000     
L0001831C   dc.w    $0000,$FFFF,$FFF1,$F000,$0000,$0000,$0000,$FFFF     
L0001832C   dc.w    $FFE3,$F000,$0000,$0000,$0000,$FFFF,$FFEF,$E000     
L0001833C   dc.w    $0000,$0000,$0000,$FFFF,$FF3F,$E000,$0000,$0000     
L0001834C   dc.w    $0000,$FFFF,$F9FF,$C000,$0000,$0000,$0000,$7FFC     
L0001835C   dc.w    $0FFF,$8000,$0000,$0000,$0000,$3FFF,$FFFF,$0000     
L0001836C   dc.w    $0000,$0000,$0000,$1FFF,$FFFE,$0000,$0000,$0000     
L0001837C   dc.w    $0000,$07FF,$FFF8,$0000,$0000,$0000,$0000,$00FF     
L0001838C   dc.w    $FFF0,$0000,$0000,$0000,$0000,$003F,$FFC0,$0000     
L0001839C   dc.w    $0000,$0000,$0000,$0007,$FE00,$0000,$0000,$0000     
L000183AC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L000183BC   dc.w    $0000,$0000,$0000,$0000

L000183C4   dc.w    $0000,$0000,$0000,$0000     
L000183CC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L000183DC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L000183EC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$00C0,$0000     
L000183FC   dc.w    $0000,$0000,$0000,$0000,$0070,$0000,$0000,$0000     
L0001840C   dc.w    $0000,$0000,$003C,$0000,$0000,$0000,$0000,$0000     
L0001841C   dc.w    $001F,$0000,$0000,$0000,$0000,$0000,$000F,$8000     
L0001842C   dc.w    $0000,$0000,$0000,$0000,$0007,$C000,$0000,$0000     
L0001843C   dc.w    $0000,$0000,$0003,$E000,$0000,$0000,$0000,$0000     
L0001844C   dc.w    $0003,$F000,$0000,$0000,$0000,$0000,$0001,$F800     
L0001845C   dc.w    $0000,$0000,$0000,$0000,$0001,$FC00,$0000,$0000     
L0001846C   dc.w    $0000,$0000,$0000,$FC00,$0000,$0000,$0000,$0000     
L0001847C   dc.w    $0000,$FE00,$0000,$0000,$0000,$0000,$0000,$7E00     
L0001848C   dc.w    $0000,$0000,$0000,$0000,$0000,$7F00,$0000,$0000     
L0001849C   dc.w    $0000,$0000,$0000,$3F00,$0000,$0000,$0000,$0000     
L000184AC   dc.w    $0000,$0F00,$0000,$0000,$0000,$0000,$0000,$0000     
L000184BC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L000184CC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L000184DC   dc.w    $0000,$0000,$7000,$0000,$0000,$0000,$0000,$0000     
L000184EC   dc.w    $0C00,$0000,$0000,$0000,$0000,$0000,$0300,$0000     
L000184FC   dc.w    $0000,$0000,$0000,$0000,$00C0,$0000,$0000,$0000     
L0001850C   dc.w    $0000,$0000,$0020,$0000,$0000,$0000,$0000,$0000     
L0001851C   dc.w    $0010,$0000,$0000,$0000,$0000,$0000,$0008,$0000     
L0001852C   dc.w    $0000,$0000,$0000,$0000,$0004,$0000,$0000,$0000     
L0001853C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L0001854C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L0001855C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L0001856C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L0001857C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L0001858C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L0001859C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L000185AC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L000185BC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L000185CC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L000185DC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L000185EC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$1C00     
L000185FC   dc.w    $0000,$0000,$0000,$0000,$0000,$2000,$0100,$0000     
L0001860C   dc.w    $0000,$0000,$0000,$0040,$0200,$0000,$0000,$0000     
L0001861C   dc.w    $0000,$0000,$0600,$0000,$0000,$0000,$0000,$00C0     
L0001862C   dc.w    $0180,$0000,$0000,$0000,$0000,$0300,$0030,$0000     
L0001863C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L0001864C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L0001865C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L0001866C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L0001867C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L0001868C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L0001869C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L000186AC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L000186BC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L000186CC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L000186DC   dc.w    $0000,$0007,$1C00,$0000,$0000,$0000,$0000,$001F     
L000186EC   dc.w    $FF00,$0000,$0000,$0000,$0000,$203F,$FF80,$8000     
L000186FC   dc.w    $0000,$0000,$0000,$18F4,$45E3,$0000,$0000,$0000     
L0001870C   dc.w    $0000,$1FE0,$003F,$0000,$0000,$0000,$0000,$0800     
L0001871C   dc.w    $0002,$0000,$0000,$0000,$0000,$043F,$9F86,$0000     
L0001872C   dc.w    $0000,$0000,$0000,$065F,$FF4C,$0000,$0000,$0000     
L0001873C   dc.w    $0000,$033F,$FF98,$0000,$0000,$0000,$0000,$0180     
L0001874C   dc.w    $0030,$0000,$0000,$0000,$0000,$00FE,$A7E0,$0000     
L0001875C   dc.w    $0000,$0000,$0000,$007F,$FFC0,$0000,$0000,$0000     
L0001876C   dc.w    $0000,$001F,$FF00,$0000,$0000,$0000,$0000,$0003     
L0001877C   dc.w    $F800,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L0001878C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L0001879C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L000187AC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L000187BC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L000187CC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L000187DC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L000187EC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L000187FC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L0001880C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L0001881C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L0001882C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L0001883C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L0001884C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L0001885C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L0001886C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L0001887C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L0001888C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L0001889C   dc.w    $0000,$0000,$0000,$0000,$0000,$0130,$0111,$0333     
L000188AC   dc.w    $0555,$0000

L000188B0   dc.w    $0000,$0000,$0000,$0000,$0000,$0000     
L000188BC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L000188CC   dc.w    $0000,$0000,$0000,$0000,$001E,$F800,$0000,$00F9     
L000188DC   dc.w    $7E00,$0000,$005A,$4F00,$0000,$0110,$4380,$0000     
L000188EC   dc.w    $0618,$00C0,$0000,$0800,$6080,$0000,$0400,$0080     
L000188FC   dc.w    $0000,$0000,$0080,$0000,$0E00,$00C0,$0000,$0B70     
L0001890C   dc.w    $11C0,$0000,$0631,$4180,$0000,$028D,$3E00,$0000     
L0001891C   dc.w    $01ED,$E800,$0000,$003F,$E000,$0000,$0002,$0000     
L0001892C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L0001893C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L0001894C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L0001895C   dc.w    $0000,$0000,$0000,$0000

L00018964   dc.w    $0000,$0000,$0000,$0000 
L0001896C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L0001897C   dc.w    $0018,$6000,$0000,$00C0,$3800,$0000,$001C,$9E00     
L0001898C   dc.w    $0000,$02E5,$0700,$0000,$0405,$2380,$0000,$0F0C     
L0001899C   dc.w    $11C0,$0000,$1E04,$D140,$0000,$1A08,$6000,$0000     
L000189AC   dc.w    $1200,$0000,$0000,$1200,$0080,$0000,$1600,$01C0     
L000189BC   dc.w    $0000,$1350,$01C0,$0000,$1840,$A180,$0000,$05EC     
L000189CC   dc.w    $2800,$0000,$03ED,$F500,$0000,$00DF,$F200,$0000     
L000189DC   dc.w    $00F9,$8800,$0000,$0018,$6000,$0000,$0000,$0000     
L000189EC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L000189FC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L00018A0C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000

L00018A18   dc.w    $0000,$0000 
L00018A1C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L00018A2C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L00018A3C   dc.w    $0003,$6000,$0000,$001A,$7800,$0000,$00DB,$4C00     
L00018A4C   dc.w    $0000,$0018,$6200,$0000,$0018,$6180,$0000,$0408     
L00018A5C   dc.w    $00C0,$0000,$0E00,$00C0,$0000,$0C00,$0040,$0000     
L00018A6C   dc.w    $0800,$0000,$0000,$0C20,$1000,$0000,$0775,$F000     
L00018A7C   dc.w    $0000,$0331,$D600,$0000,$0010,$0C00,$0000,$0020     
L00018A8C   dc.w    $1000,$0000,$0007,$8000,$0000,$0000,$0000,$0000     
L00018A9C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L00018AAC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L00018ABC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L00018ACC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L00018ADC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L00018AEC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L00018AFC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L00018B0C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L00018B1C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L00018B2C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L00018B3C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L00018B4C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L00018B5C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L00018B6C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L00018B7C   dc.w    $0000,$0000

L00018B80   dc.w    $0000,$0000,$0000,$0000,$0000,$0000     
L00018B8C   dc.w    $0000,$0000,$0000,$0057,$0000,$0000,$0000,$0000     
L00018B9C   dc.w    $0000,$000B,$E000,$0000,$0000,$0000,$0006,$7606     
L00018BAC   dc.w    $1800,$0000,$0000,$0000,$01FF,$EFFF,$3E00,$0000     
L00018BBC   dc.w    $0000,$0000,$0FD9,$D9FF,$7D80,$0000,$0000,$0000     
L00018BCC   dc.w    $7FE8,$B9FC,$E2E0,$0000,$0000,$0001,$FF59,$73CE     
L00018BDC   dc.w    $FA30,$0000,$0000,$0007,$B970,$43C1,$FE58,$0000     
L00018BEC   dc.w    $0000,$001F,$41E8,$01E0,$2FAC,$0000,$0000,$003F     
L00018BFC   dc.w    $0398,$01D0,$0FD2,$0000,$0000,$0078,$027C,$03B0     
L00018C0C   dc.w    $03E0,$0000,$0000,$00F0,$03FC,$03F0,$0070,$0000     
L00018C1C   dc.w    $0000,$01E0,$03FC,$03F0,$0018,$0000,$0000,$03C0     
L00018C2C   dc.w    $03F0,$00E0,$009C,$0000,$0000,$03C0,$00F0,$0260     
L00018C3C   dc.w    $014C,$0000,$0000,$0480,$0000,$0110,$0038,$0000     
L00018C4C   dc.w    $0000,$0540,$0000,$0080,$003B,$0000,$0000,$0320     
L00018C5C   dc.w    $0000,$0000,$0013,$0000,$0000,$0B40,$0000,$0000     
L00018C6C   dc.w    $0033,$0000,$0000,$0880,$0000,$0000,$003B,$0000     
L00018C7C   dc.w    $0000,$0380,$0000,$0000,$000F,$0000,$0000,$07C0     
L00018C8C   dc.w    $0000,$0000,$001E,$0000,$0000,$05C0,$0E00,$0807     
L00018C9C   dc.w    $003E,$0000,$0000,$04F0,$1F00,$0A0F,$80FE,$0000     
L00018CAC   dc.w    $0000,$0210,$0F8C,$2813,$80F8,$0000,$0000,$01E0     
L00018CBC   dc.w    $0FB8,$1381,$80F0,$0000,$0000,$00FC,$1FF1,$03D1     
L00018CCC   dc.w    $83D0,$0000,$0000,$033B,$0FDF,$0C01,$0F80,$0000     
L00018CDC   dc.w    $0000,$019E,$073F,$8822,$3F00,$0000,$0000,$00E4     
L00018CEC   dc.w    $C27F,$9074,$7E00,$0000,$0000,$0061,$F2FF,$23F8     
L00018CFC   dc.w    $FE00,$0000,$0000,$0019,$FCFF,$9FFB,$E800,$0000     
L00018D0C   dc.w    $0000,$000E,$7FFF,$FFFE,$E000,$0000,$0000,$0001     
L00018D1C   dc.w    $0FFF,$FFF3,$0000,$0000,$0000,$0000,$0007,$E770     
L00018D2C   dc.w    $0000,$0000,$0000,$0000,$0000,$C200,$0000,$0000     
L00018D3C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L00018D4C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0007,$FE00     
L00018D5C   dc.w    $0000,$0000

L00018D60   dc.w    $0000,$0000,$01F8,$01F8,$0000,$0000     
L00018D6C   dc.w    $0000,$0000,$0E00,$007F,$0000,$0000,$0000,$0000     
L00018D7C   dc.w    $7000,$007F,$E000,$0000,$0000,$0001,$8001,$86FE     
L00018D8C   dc.w    $1800,$0000,$0000,$0006,$01FC,$0E07,$0600,$0000     
L00018D9C   dc.w    $0000,$0018,$0FDC,$1801,$0180,$0000,$0000,$0060     
L00018DAC   dc.w    $7EA5,$3803,$1CE0,$0000,$0000,$0081,$FFC4,$783F     
L00018DBC   dc.w    $0430,$0000,$0000,$0107,$888C,$3031,$0678,$0000     
L00018DCC   dc.w    $0000,$02DF,$8114,$0218,$13BC,$0000,$0000,$07FC     
L00018DDC   dc.w    $0264,$022C,$03FE,$0000,$0000,$0FF8,$0384,$0044     
L00018DEC   dc.w    $03FF,$0000,$0000,$1FF8,$0004,$000C,$01EF,$8000     
L00018DFC   dc.w    $0000,$1FF0,$000C,$0204,$00FF,$8000,$0000,$3FE0     
L00018E0C   dc.w    $0006,$070C,$006F,$C000,$0000,$3FE0,$010C,$0388     
L00018E1C   dc.w    $001F,$C000,$0000,$7CC0,$00F8,$01D0,$0003,$E000     
L00018E2C   dc.w    $0000,$7C20,$0010,$0080,$0003,$6000,$0000,$7840     
L00018E3C   dc.w    $0000,$0000,$0003,$2000,$0000,$7820,$0000,$0000     
L00018E4C   dc.w    $0033,$2000,$0000,$78C0,$0000,$0000,$003B,$2000     
L00018E5C   dc.w    $0000,$73C0,$0000,$0000,$002F,$2000,$0000,$63E0     
L00018E6C   dc.w    $0000,$0000,$005E,$2000,$0000,$29E0,$0E00,$0807     
L00018E7C   dc.w    $007E,$4000,$0000,$30F0,$1100,$0A01,$80FE,$4000     
L00018E8C   dc.w    $0000,$1C10,$108C,$2780,$80F8,$8000,$0000,$1A00     
L00018E9C   dc.w    $1080,$0C50,$80F0,$8000,$0000,$0908,$0041,$0C30     
L00018EAC   dc.w    $81C1,$0000,$0000,$06C0,$001F,$0800,$0082,$0000     
L00018EBC   dc.w    $0000,$0360,$003F,$8020,$2104,$0000,$0000,$0198     
L00018ECC   dc.w    $D47F,$8072,$C008,$0000,$0000,$00E7,$FCFF,$03FF     
L00018EDC   dc.w    $0010,$0000,$0000,$0078,$7EFF,$BFFF,$1060,$0000     
L00018EEC   dc.w    $0000,$001F,$8FFF,$FFFE,$0180,$0000,$0000,$0007     
L00018EFC   dc.w    $F1FF,$FFF4,$0600,$0000,$0000,$0001,$FE07,$E700     
L00018F0C   dc.w    $1800,$0000,$0000,$0000,$7FC0,$3C00,$E000,$0000     
L00018F1C   dc.w    $0000,$0000,$0F80,$0007,$0000,$0000,$0000,$0000     
L00018F2C   dc.w    $01F8,$01F8,$0000,$0000,$0000,$0000,$0000,$0000     
L00018F3C   dc.w    $0000,$0000

L00018F40   dc.w    $0000,$0000,$0000,$0000,$0000,$0000     
L00018F4C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L00018F5C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0007,$F801     
L00018F6C   dc.w    $E000,$0000,$0000,$0000,$0003,$F1F8,$F800,$0000     
L00018F7C   dc.w    $0000,$0000,$0023,$E3FE,$FE00,$0000,$0000,$0000     
L00018F8C   dc.w    $0159,$C3FF,$FF00,$0000,$0000,$0000,$00B9,$83E1     
L00018F9C   dc.w    $FFC0,$0000,$0000,$0000,$7178,$F3E0,$F980,$0000     
L00018FAC   dc.w    $0000,$0000,$C0F8,$03F0,$3C40,$0000,$0000,$0003     
L00018FBC   dc.w    $01F8,$03F8,$0C00,$0000,$0000,$0004,$01F8,$03F8     
L00018FCC   dc.w    $0000,$0000,$0000,$0000,$03F8,$03F8,$0090,$0000     
L00018FDC   dc.w    $0000,$0000,$03F0,$01F8,$0060,$0000,$0000,$0000     
L00018FEC   dc.w    $03F8,$01F0,$00F0,$0000,$0000,$0000,$01F0,$01F0     
L00018FFC   dc.w    $0170,$0000,$0000,$0300,$00E0,$00E0,$003C,$0000     
L0001900C   dc.w    $0000,$03C0,$0000,$0000,$003C,$0000,$0000,$07E0     
L0001901C   dc.w    $0000,$0000,$003C,$0000,$0000,$07C0,$0000,$0000     
L0001902C   dc.w    $000C,$0000,$0000,$0700,$0000,$0000,$0004,$0000     
L0001903C   dc.w    $0000,$0C00,$0000,$0000,$0010,$0000,$0000,$1C00     
L0001904C   dc.w    $0000,$0000,$0020,$0000,$0000,$1600,$0000,$0000     
L0001905C   dc.w    $0000,$0000,$0000,$0F00,$0E00,$000E,$0000,$0000     
L0001906C   dc.w    $0000,$07E0,$1F10,$0C1F,$0004,$0000,$0000,$07F8     
L0001907C   dc.w    $1F3E,$1F9F,$0108,$0000,$0000,$07F4,$1FBE,$0FCF     
L0001908C   dc.w    $0230,$0000,$0000,$01FF,$0FE0,$07FF,$0F60,$0000     
L0001909C   dc.w    $0000,$00FF,$C7C0,$1FDE,$1EC0,$0000,$0000,$007F     
L000190AC   dc.w    $2780,$1F8E,$3F80,$0000,$0000,$001E,$0300,$BC04     
L000190BC   dc.w    $FE00,$0000,$0000,$0007,$8100,$2000,$F800,$0000     
L000190CC   dc.w    $0000,$0000,$7000,$0001,$E000,$0000,$0000,$0000     
L000190DC   dc.w    $0E00,$000F,$0000,$0000,$0000,$0000,$01F8,$18F8     
L000190EC   dc.w    $0000,$0000,$0000,$0000,$0007,$FE00,$0000,$0000     
L000190FC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L0001910C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L0001911C   dc.w    $0000,$0000

L00019120   dc.w    $0000,$0000,$0000,$0000,$0000,$0000     
L0001912C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L0001913C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L0001914C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L0001915C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L0001916C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L0001917C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L0001918C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L0001919C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L000191AC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L000191BC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L000191CC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L000191DC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L000191EC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L000191FC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L0001920C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L0001921C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L0001922C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L0001923C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L0001924C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L0001925C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L0001926C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L0001927C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L0001928C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L0001929C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L000192AC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L000192BC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L000192CC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L000192DC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L000192EC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0130,$0111     
L000192FC   dc.w    $0333,$0555



            ; font 8x8
L00019300   dc.b    $3C,$66,$6E,$6E,$60,$62,$3C,$00
            dc.b    $00,$00,$3C,$06     
L0001930C   dc.w    $3E66,$3E00,$0060,$607C,$6666,$7C00,$0000,$3C60     
L0001931C   dc.w    $6060,$3C00,$0006,$063E,$6666,$3E00,$0000,$3C66     
L0001932C   dc.w    $7E60,$3C00,$000E,$183E,$1818,$1800,$0000,$3E66     
L0001933C   dc.w    $663E,$067C,$0060,$607C,$6666,$6600,$0018,$0038     
L0001934C   dc.w    $1818,$3C00,$0006,$0006,$0606,$063C,$0060,$606C     
L0001935C   dc.w    $786C,$6600,$0038,$1818,$1818,$3C00,$0000,$667F     
L0001936C   dc.w    $7F6B,$6300,$0000,$7C66,$6666,$6600,$0000,$3C66     
L0001937C   dc.w    $6666,$3C00,$0000,$7C66,$667C,$6060,$0000,$3E66     
L0001938C   dc.w    $663E,$0606,$0000,$7C66,$6060,$6000,$0000,$3E60     
L0001939C   dc.w    $3C06,$7C00,$0018,$7E18,$1818,$0E00,$0000,$6666     
L000193AC   dc.w    $6666,$3E00,$0000,$6666,$663C,$1800,$0000,$636B     
L000193BC   dc.w    $7F3E,$3600,$0000,$663C,$183C,$6600,$0000,$6666     
L000193CC   dc.w    $663E,$0C78,$0000,$7E0C,$1830,$7E00,$3C30,$3030     
L000193DC   dc.w    $3030,$3C00,$0C12,$307C,$3062,$FC00,$3C0C,$0C0C     
L000193EC   dc.w    $0C0C,$3C00,$0018,$3C7E,$1818,$1818,$0010,$307F     
L000193FC   dc.w    $7F30,$1000,$0000,$0000,$0000,$0000,$1818,$1818     
L0001940C   dc.w    $0000,$1800,$6666,$6600,$0000,$0000,$6666,$FF66     
L0001941C   dc.w    $FF66,$6600,$183E,$603C,$067C,$1800,$6266,$0C18     
L0001942C   dc.w    $3066,$4600,$3C66,$3C38,$6766,$3F00,$060C,$1800     
L0001943C   dc.w    $0000,$0000,$0C18,$3030,$3018,$0C00,$3018,$0C0C     
L0001944C   dc.w    $0C18,$3000,$0066,$3CFF,$3C66,$0000,$0018,$187E     
L0001945C   dc.w    $1818,$0000,$0000,$0000,$0018,$1830,$0000,$007E     
L0001946C   dc.w    $0000,$0000,$0000,$0000,$0018,$1800,$0003,$060C     
L0001947C   dc.w    $1830,$6000,$3C66,$6E76,$6666,$3C00,$1818,$3818     
L0001948C   dc.w    $1818,$7E00,$3C66,$060C,$3060,$7E00,$3C66,$061C     
L0001949C   dc.w    $0666,$3C00,$060E,$1E66,$7F06,$0600,$7E60,$7C06     
L000194AC   dc.w    $0666,$3C00,$3C66,$607C,$6666,$3C00,$7E66,$0C18     
L000194BC   dc.w    $1818,$1800,$3C66,$663C,$6666,$3C00,$3C66,$663E     
L000194CC   dc.w    $0666,$3C00,$0000,$1800,$0018,$0000,$0000,$1800     
L000194DC   dc.w    $0018,$1830,$0E18,$3060,$3018,$0E00,$0000,$7E00     
L000194EC   dc.w    $7E00,$0000,$7018,$0C06,$0C18,$7000,$3C66,$060C     
L000194FC   dc.w    $1800,$1800,$0000,$00FF,$FF00,$0000,$183C,$667E     
L0001950C   dc.w    $6666,$6600,$7C66,$667C,$6666,$7C00,$3C66,$6060     
L0001951C   dc.w    $6066,$3C00,$786C,$6666,$666C,$7800,$7E60,$6078     
L0001952C   dc.w    $6060,$7E00,$7E60,$6078,$6060,$6000,$3C66,$606E     
L0001953C   dc.w    $6666,$3C00,$6666,$667E,$6666,$6600,$3C18,$1818     
L0001954C   dc.w    $1818,$3C00,$1E0C,$0C0C,$0C6C,$3800,$666C,$7870     
L0001955C   dc.w    $786C,$6600,$6060,$6060,$6060,$7E00,$6377,$7F6B     
L0001956C   dc.w    $6363,$6300,$6676,$7E7E,$6E66,$6600,$3C66,$6666     
L0001957C   dc.w    $6666,$3C00,$7C66,$667C,$6060,$6000,$3C66,$6666     
L0001958C   dc.w    $663C,$0E00,$7C66,$667C,$786C,$6600,$3C66,$603C     
L0001959C   dc.w    $0666,$3C00,$7E18,$1818,$1818,$1800,$6666,$6666     
L000195AC   dc.w    $6666,$3C00,$6666,$6666,$663C,$1800,$6363,$636B     
L000195BC   dc.w    $7F77,$6300,$6666,$3C18,$3C66,$6600,$6666,$663C     
L000195CC   dc.w    $1818,$1800,$7E06,$0C18,$3060,$7E00,$1818,$18FF     
L000195DC   dc.w    $FF18,$1818,$C0C0,$3030,$C0C0,$3030,$1818,$1818     
L000195EC   dc.w    $1818,$1818,$3333,$CCCC,$3333,$CCCC,$3399,$CC66     
L000195FC   dc.w    $3399,$CC66,$0000,$0000,$0000,$0000,$F0F0,$F0F0     
L0001960C   dc.w    $F0F0,$F0F0,$0000,$0000,$FFFF,$FFFF,$FF00,$0000     
L0001961C   dc.w    $0000,$0000,$0000,$0000,$0000,$00FF,$C0C0,$C0C0     
L0001962C   dc.w    $C0C0,$C0C0,$CCCC,$3333,$CCCC,$3333,$0303,$0303     
L0001963C   dc.w    $0303,$0303,$0000,$0000,$CCCC,$3333,$CC99,$3366     
L0001964C   dc.w    $CC99,$3366,$0303,$0303,$0303,$0303,$1818,$181F     
L0001965C   dc.w    $1F18,$1818,$0000,$0000,$0F0F,$0F0F,$1818,$181F     
L0001966C   dc.w    $1F00,$0000,$0000,$00F8,$F818,$1818,$0000,$0000     
L0001967C   dc.w    $0000,$FFFF,$0000,$001F,$1F18,$1818,$1818,$18FF     
L0001968C   dc.w    $FF00,$0000,$0000,$00FF,$FF18,$1818,$1818,$18F8     
L0001969C   dc.w    $F818,$1818,$C0C0,$C0C0,$C0C0,$C0C0,$E0E0,$E0E0     
L000196AC   dc.w    $E0E0,$E0E0,$0707,$0707,$0707,$0707,$FFFF,$0000     
L000196BC   dc.w    $0000,$0000,$FFFF,$FF00,$0000,$0000,$0000,$0000     
L000196CC   dc.w    $00FF,$FFFF,$0103,$066C,$7870,$6000,$0000,$0000     
L000196DC   dc.w    $F0F0,$F0F0,$0F0F,$0F0F,$0000,$0000,$1818,$18F8     
L000196EC   dc.w    $F800,$0000,$F0F0,$F0F0,$0000,$0000,$F0F0,$F0F0     
L000196FC   dc.w    $0F0F,$0F0F,$C399,$9191,$9F99,$C3FF,$FFFF,$C3F9     
L0001970C   dc.w    $C199,$C1FF,$FF9F,$9F83,$9999,$83FF,$FFFF,$C39F     
L0001971C   dc.w    $9F9F,$C3FF,$FFF9,$F9C1,$9999,$C1FF,$FFFF,$C399     
L0001972C   dc.w    $819F,$C3FF,$FFF1,$E7C1,$E7E7,$E7FF,$FFFF,$C199     
L0001973C   dc.w    $99C1,$F983,$FF9F,$9F83,$9999,$99FF,$FFE7,$FFC7     
L0001974C   dc.w    $E7E7,$C3FF,$FFF9,$FFF9,$F9F9,$F9C3,$FF9F,$9F93     
L0001975C   dc.w    $8793,$99FF,$FFC7,$E7E7,$E7E7,$C3FF,$FFFF,$9980     
L0001976C   dc.w    $8094,$9CFF,$FFFF,$8399,$9999,$99FF,$FFFF,$C399     
L0001977C   dc.w    $9999,$C3FF,$FFFF,$8399,$9983,$9F9F,$FFFF,$C199     
L0001978C   dc.w    $99C1,$F9F9,$FFFF,$8399,$9F9F,$9FFF,$FFFF,$C19F     
L0001979C   dc.w    $C3F9,$83FF,$FFE7,$81E7,$E7E7,$F1FF,$FFFF,$9999     
L000197AC   dc.w    $9999,$C1FF,$FFFF,$9999,$99C3,$E7FF,$FFFF,$9C94     
L000197BC   dc.w    $80C1,$C9FF,$FFFF,$99C3,$E7C3,$99FF,$FFFF,$9999     
L000197CC   dc.w    $99C1,$F387,$FFFF,$81F3,$E7CF,$81FF,$C3CF,$CFCF     
L000197DC   dc.w    $CFCF,$C3FF,$F3ED,$CF83,$CF9D,$03FF,$C3F3,$F3F3     
L000197EC   dc.w    $F3F3,$C3FF,$FFE7,$C381,$E7E7,$E7E7,$FFEF,$CF80     
L000197FC   dc.w    $80CF,$EFFF,$FFFF,$FFFF,$FFFF,$FFFF,$E7E7,$E7E7     
L0001980C   dc.w    $FFFF,$E7FF,$9999,$99FF,$FFFF,$FFFF,$9999,$0099     
L0001981C   dc.w    $0099,$99FF,$E7C1,$9FC3,$F983,$E7FF,$9D99,$F3E7     
L0001982C   dc.w    $CF99,$B9FF,$C399,$C3C7,$9899,$C0FF,$F9F3,$E7FF     
L0001983C   dc.w    $FFFF,$FFFF,$F3E7,$CFCF,$CFE7,$F3FF,$CFE7,$F3F3     
L0001984C   dc.w    $F3E7,$CFFF,$FF99,$C300,$C399,$FFFF,$FFE7,$E781     
L0001985C   dc.w    $E7E7,$FFFF,$FFFF,$FFFF,$FFE7,$E7CF,$FFFF,$FF81     
L0001986C   dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFE7,$E7FF,$FFFC,$F9F3     
L0001987C   dc.w    $E7CF,$9FFF,$C399,$9189,$9999,$C3FF,$E7E7,$C7E7     
L0001988C   dc.w    $E7E7,$81FF,$C399,$F9F3,$CF9F,$81FF,$C399,$F9E3     
L0001989C   dc.w    $F999,$C3FF,$F9F1,$E199,$80F9,$F9FF,$819F,$83F9     
L000198AC   dc.w    $F999,$C3FF,$C399,$9F83,$9999,$C3FF,$8199,$F3E7     
L000198BC   dc.w    $E7E7,$E7FF,$C399,$99C3,$9999,$C3FF,$C399,$99C1     
L000198CC   dc.w    $F999,$C3FF,$FFFF,$E7FF,$FFE7,$FFFF,$FFFF,$E7FF     
L000198DC   dc.w    $FFE7,$E7CF,$F1E7,$CF9F,$CFE7,$F1FF,$FFFF,$81FF     
L000198EC   dc.w    $81FF,$FFFF,$8FE7,$F3F9,$F3E7,$8FFF,$C399,$F9F3     
L000198FC   dc.w    $E7FF,$E7FF,$FFFF,$FF00,$00FF,$FFFF,$E7C3,$9981     
L0001990C   dc.w    $9999,$99FF,$8399,$9983,$9999,$83FF,$C399,$9F9F     
L0001991C   dc.w    $9F99,$C3FF,$8793,$9999,$9993,$87FF,$819F,$9F87     
L0001992C   dc.w    $9F9F,$81FF,$819F,$9F87,$9F9F,$9FFF,$C399,$9F91     
L0001993C   dc.w    $9999,$C3FF,$9999,$9981,$9999,$99FF,$C3E7,$E7E7     
L0001994C   dc.w    $E7E7,$C3FF,$E1F3,$F3F3,$F393,$C7FF,$9993,$878F     
L0001995C   dc.w    $8793,$99FF,$9F9F,$9F9F,$9F9F,$81FF,$9C88,$8094     
L0001996C   dc.w    $9C9C,$9CFF,$9989,$8181,$9199,$99FF,$C399,$9999     
L0001997C   dc.w    $9999,$C3FF,$8399,$9983,$9F9F,$9FFF,$C399,$9999     
L0001998C   dc.w    $99C3,$F1FF,$8399,$9983,$8793,$99FF,$C399,$9FC3     
L0001999C   dc.w    $F999,$C3FF,$81E7,$E7E7,$E7E7,$E7FF,$9999,$9999     
L000199AC   dc.w    $9999,$C3FF,$9999,$9999,$99C3,$E7FF,$9C9C,$9C94     
L000199BC   dc.w    $8088,$9CFF,$9999,$C3E7,$C399,$99FF,$9999,$99C3     
L000199CC   dc.w    $E7E7,$E7FF,$81F9,$F3E7,$CF9F,$81FF,$E7E7,$E700     
L000199DC   dc.w    $00E7,$E7E7,$3F3F,$CFCF,$3F3F,$CFCF,$E7E7,$E7E7     
L000199EC   dc.w    $E7E7,$E7E7,$CCCC,$3333,$CCCC,$3333,$CC66,$3399     
L000199FC   dc.w    $CC66,$3399,$FFFF,$FFFF,$FFFF,$FFFF,$0F0F,$0F0F     
L00019A0C   dc.w    $0F0F,$0F0F,$FFFF,$FFFF,$0000,$0000,$00FF,$FFFF     
L00019A1C   dc.w    $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FF00,$3F3F,$3F3F     
L00019A2C   dc.w    $3F3F,$3F3F,$3333,$CCCC,$3333,$CCCC,$FCFC,$FCFC     
L00019A3C   dc.w    $FCFC,$FCFC,$FFFF,$FFFF,$3333,$CCCC,$3366,$CC99     
L00019A4C   dc.w    $3366,$CC99,$FCFC,$FCFC,$FCFC,$FCFC,$E7E7,$E7E0     
L00019A5C   dc.w    $E0E7,$E7E7,$FFFF,$FFFF,$F0F0,$F0F0,$E7E7,$E7E0     
L00019A6C   dc.w    $E0FF,$FFFF,$FFFF,$FF07,$07E7,$E7E7,$FFFF,$FFFF     
L00019A7C   dc.w    $FFFF,$0000,$FFFF,$FFE0,$E0E7,$E7E7,$E7E7,$E700     
L00019A8C   dc.w    $00FF,$FFFF,$FFFF,$FF00,$00E7,$E7E7,$E7E7,$E707     
L00019A9C   dc.w    $07E7,$E7E7,$3F3F,$3F3F,$3F3F,$3F3F,$1F1F,$1F1F     
L00019AAC   dc.w    $1F1F,$1F1F,$F8F8,$F8F8,$F8F8,$F8F8,$0000,$FFFF     
L00019ABC   dc.w    $FFFF,$FFFF,$0000,$00FF,$FFFF,$FFFF,$FFFF,$FFFF     
L00019ACC   dc.w    $FF00,$0000,$FEFC,$F993,$878F,$9FFF,$FFFF,$FFFF     
L00019ADC   dc.w    $0F0F,$0F0F,$F0F0,$F0F0,$FFFF,$FFFF,$E7E7,$E707     
L00019AEC   dc.w    $07FF,$FFFF,$0F0F,$0F0F,$FFFF,$FFFF,$0F00,$006C     
L00019AFC   dc.w    $0000,$0069,$0000,$0000,$0000,$0041,$C000,$0FD7     
L00019B0C   dc.w    $8000,$0000,$0000,$0000,$0000,$0B90,$0000,$0DE0     
L00019B1C   dc.w    $0000,$09EC,$0000,$0D74,$0000,$1F74,$0000,$1A78     
L00019B2C   dc.w    $4000,$3820,$E000,$3203,$A000,$1EC6,$0000,$0FC0     
L00019B3C   dc.w    $0000,$0000,$0000,$0000,$0000,$7FE0,$0000,$7FF0     
L00019B4C   dc.w    $0000,$FFF8,$0000,$FFF8,$0000,$FFF8,$4000,$FFF9     
L00019B5C   dc.w    $E000,$7FFB,$F000,$7FFF,$F000,$7FFF,$E000,$3FFF     
L00019B6C   dc.w    $C000,$3FFF,$8000,$5FC0,$0000,$2740,$0000,$73F0     
L00019B7C   dc.w    $0000,$7170,$0000,$71F0,$0000,$69B0,$0000,$31F0     
L00019B8C   dc.w    $0000,$3403,$A000,$3816,$4000,$1FD0,$8000,$0000     
L00019B9C   dc.w    $0000,$2000,$0000,$1800,$0000,$0C00,$0000,$0880     
L00019BAC   dc.w    $0000,$0C00,$0000,$1440,$0000,$0800,$4000,$0803     
L00019BBC   dc.w    $8000,$0357,$C000,$0007,$8000,$0000,$0000,$2C40     
L00019BCC   dc.w    $0000,$1700,$0000,$3BB0,$0000,$31D0,$0000,$38C0     
L00019BDC   dc.w    $0000,$3CE0,$0000,$1860,$0000,$1400,$2000,$1A41     
L00019BEC   dc.w    $C000,$0FD7,$8000,$0000,$0000,$2C40,$0000,$1700     
L00019BFC   dc.w    $0000,$3BB0,$0000,$35D0,$0000,$38C0,$0000,$3CE0     
L00019C0C   dc.w    $4000,$1860,$E000,$1403,$A000,$1AC6,$0000,$0FC0     
L00019C1C   dc.w    $0000,$0000,$0000,$03FF,$0000,$07FF,$0000,$07FF     
L00019C2C   dc.w    $0000,$07FF,$8000,$0FFF,$8000,$0FFF,$C000,$1FFF     
L00019C3C   dc.w    $C000,$1FFF,$E000,$3FFF,$E000,$3FFF,$E000,$3FFF     
L00019C4C   dc.w    $E000,$1FFF,$E000,$1FC7,$E000,$3F87,$E000,$3F87     
L00019C5C   dc.w    $E000,$3F07,$E000,$3F07,$E000,$7E07,$E000,$7E03     
L00019C6C   dc.w    $C000,$7F07,$F000,$7FC7,$FC00,$7FC7,$FC00,$0180     
L00019C7C   dc.w    $0000,$03FC,$0000,$03FC,$0000,$03F6,$0000,$07FE     
L00019C8C   dc.w    $0000,$07F6,$8000,$0FFE,$8000,$0EEE,$8000,$1FEE     
L00019C9C   dc.w    $8000,$1FFE,$8000,$1F2A,$C000,$0000,$8000,$0F83     
L00019CAC   dc.w    $C000,$1F03,$C000,$1D03,$C000,$1A00,$0000,$0003     
L00019CBC   dc.w    $8000,$3800,$0000,$0000,$0000,$0400,$4000,$1801     
L00019CCC   dc.w    $8000,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L00019CDC   dc.w    $0000,$0008,$0000,$0000,$0000,$0008,$0000,$0000     
L00019CEC   dc.w    $0000,$0110,$4000,$0010,$4000,$0000,$4000,$0014     
L00019CFC   dc.w    $0000,$0000,$4000,$0000,$0000,$0000,$0000,$0200     
L00019D0C   dc.w    $0000,$0400,$0000,$0000,$4000,$0400,$0000,$0000     
L00019D1C   dc.w    $0000,$2C02,$C000,$1981,$9800,$0000,$0000,$0000     
L00019D2C   dc.w    $0000,$0300,$0000,$03FC,$0000,$03FC,$0000,$03FC     
L00019D3C   dc.w    $0000,$03FC,$0000,$03BC,$0000,$07FC,$4000,$07B8     
L00019D4C   dc.w    $4000,$073A,$4000,$001E,$0000,$0000,$4000,$0000     
L00019D5C   dc.w    $0000,$0000,$0000,$0200,$0000,$0400,$0000,$0000     
L00019D6C   dc.w    $4000,$0400,$0000,$0000,$0000,$0000,$0000,$0100     
L00019D7C   dc.w    $1000,$0000,$0000,$0000,$0000,$0300,$0000,$03FC     
L00019D8C   dc.w    $0000,$03FC,$0000,$03FC,$0000,$03FC,$0000,$03BC     
L00019D9C   dc.w    $0000,$07FC,$4000,$07B8,$4000,$073A,$4000,$001E     
L00019DAC   dc.w    $0000,$0000,$4000,$0000,$0000,$0000,$0000,$0200     
L00019DBC   dc.w    $0000,$0400,$0000,$0000,$4000,$0400,$0000,$0000     
L00019DCC   dc.w    $0000,$0000,$0000,$0100,$1000,$0000,$0000,$00FF     
L00019DDC   dc.w    $C000,$00FF,$C000,$01FF,$C000,$01FF,$C000,$01FF     
L00019DEC   dc.w    $E000,$03FF,$E000,$03FF,$F000,$07FF,$F800,$07FF     
L00019DFC   dc.w    $FC00,$0FFF,$FC00,$0FFF,$FC00,$0FFF,$FC00,$1FC0     
L00019E0C   dc.w    $FC00,$1F80,$FC00,$3F80,$7E00,$3F00,$7E00,$3F00     
L00019E1C   dc.w    $7F00,$3F00,$3F80,$7E00,$3F80,$7F00,$1FC0,$1F80     
L00019E2C   dc.w    $1FF0,$0780,$1FF0,$0060,$0000,$007F,$0000,$00FF     
L00019E3C   dc.w    $0000,$00FE,$8000,$00FF,$C000,$01FE,$C000,$01FE     
L00019E4C   dc.w    $C000,$03BD,$C000,$03FD,$C000,$07FB,$8000,$07CF     
L00019E5C   dc.w    $9000,$0000,$1000,$0F80,$7000,$0E00,$7000,$0600     
L00019E6C   dc.w    $3800,$1200,$1800,$0C00,$0000,$1000,$1800,$1000     
L00019E7C   dc.w    $0000,$0C00,$0100,$0000,$0600,$0000,$0000,$0000     
L00019E8C   dc.w    $0000,$0000,$0000,$0000,$0000,$0001,$0000,$0000     
L00019E9C   dc.w    $0000,$0001,$0000,$0001,$0000,$0042,$1000,$0002     
L00019EAC   dc.w    $1800,$0004,$5800,$0000,$4800,$0000,$0800,$0000     
L00019EBC   dc.w    $0800,$0100,$0800,$0100,$0400,$0000,$0400,$0200     
L00019ECC   dc.w    $0000,$0000,$0700,$1400,$0000,$0E00,$0B00,$0300     
L00019EDC   dc.w    $0660,$0000,$0000,$0000,$0000,$0040,$0000,$00FF     
L00019EEC   dc.w    $0000,$007F,$0000,$007F,$8000,$00FF,$8000,$00EF     
L00019EFC   dc.w    $8000,$00FF,$8000,$01EF,$1000,$01CF,$5800,$0007     
L00019F0C   dc.w    $C800,$0000,$0800,$0000,$0800,$0100,$0800,$0100     
L00019F1C   dc.w    $0400,$0000,$0400,$0200,$0000,$0000,$0600,$0000     
L00019F2C   dc.w    $0000,$0000,$0000,$0200,$0040,$0000,$0000,$0000     
L00019F3C   dc.w    $0000,$0040,$0000,$00FF,$0000,$007F,$0000,$007F     
L00019F4C   dc.w    $8000,$00FF,$8000,$00EF,$8000,$00FF,$8000,$01EF     
L00019F5C   dc.w    $1000,$01CF,$5800,$0007,$C800,$0000,$0800,$0000     
L00019F6C   dc.w    $0800,$0100,$0800,$0100,$0400,$0000,$0400,$0200     
L00019F7C   dc.w    $0000,$0000,$0600,$0000,$0000,$0000,$0000,$0200     
L00019F8C   dc.w    $0040,$0000,$0000,$003F,$F000,$003F,$F000,$003F     
L00019F9C   dc.w    $F000,$007F,$F000,$007F,$F800,$00FF,$F800,$00FF     
L00019FAC   dc.w    $FC00,$01FF,$FC00,$01FF,$FE00,$01FF,$FE00,$03FF     
L00019FBC   dc.w    $FE00,$07FF,$FE00,$0FF0,$FC00,$0FE0,$FC00,$3FC0     
L00019FCC   dc.w    $FC00,$7F80,$FC00,$7F00,$FC00,$3E00,$FC00,$1E00     
L00019FDC   dc.w    $FC00,$0F00,$7F00,$0700,$7FC0,$0000,$7FC0,$0018     
L00019FEC   dc.w    $0000,$001F,$E000,$001F,$E000,$003F,$E000,$003F     
L00019FFC   dc.w    $B000,$007F,$F000,$007F,$B000,$00FF,$B000,$007E     
L0001A00C   dc.w    $B000,$001F,$6000,$01E7,$4800,$03B0,$0800,$03C0     
L0001A01C   dc.w    $7000,$0500,$7000,$0640,$7000,$0200,$7000,$0000     
L0001A02C   dc.w    $0000,$0800,$7000,$0000,$0000,$0000,$0400,$0000     
L0001A03C   dc.w    $1800,$0000,$0000,$0000,$0000,$0000,$0000,$0000     
L0001A04C   dc.w    $0000,$0000,$0000,$0000,$4000,$0000,$0000,$0000     
L0001A05C   dc.w    $4000,$0000,$4000,$0001,$4400,$0000,$8C00,$0000     
L0001A06C   dc.w    $A400,$0040,$0400,$0020,$0800,$00C0,$0800,$0080     
L0001A07C   dc.w    $0800,$1100,$0800,$0800,$0000,$1C00,$0800,$0200     
L0001A08C   dc.w    $0000,$0200,$2C00,$0000,$1980,$0000,$0000,$0000     
L0001A09C   dc.w    $0000,$0018,$0000,$001F,$C000,$001F,$C000,$001F     
L0001A0AC   dc.w    $E000,$0037,$E000,$003F,$E000,$006B,$E000,$004F     
L0001A0BC   dc.w    $C000,$000B,$A800,$0001,$E400,$0040,$0400,$0020     
L0001A0CC   dc.w    $0800,$00C0,$0800,$0000,$0800,$0100,$0800,$0000     
L0001A0DC   dc.w    $0000,$0000,$0800,$0200,$0000,$0000,$0000,$0000     
L0001A0EC   dc.w    $0100,$0000,$0000,$0000,$0000,$0018,$0000,$001F     
L0001A0FC   dc.w    $C000,$001F,$C000,$001F,$E000,$0037,$E000,$003F     
L0001A10C   dc.w    $E000,$006B,$E000,$004F,$C000,$000B,$A800,$0001     
L0001A11C   dc.w    $E400,$0040,$0400,$0020,$0800,$00C0,$0800,$0000     
L0001A12C   dc.w    $0800,$0100,$0800,$0000,$0000,$0000,$0800,$0200     
L0001A13C   dc.w    $0000,$0000,$0000,$0000,$0100,$0000,$0000,$3FF0     
L0001A14C   dc.w    $3FF0,$3FF0,$3FF0,$3FF8,$3FF8,$7FF8,$7FFC,$7FFE     
L0001A15C   dc.w    $7FFE,$7FFE,$3FFC,$0FF8,$0FF0,$0FE0,$3FC0,$7FC0     
L0001A16C   dc.w    $3FC0,$1FC0,$0FF0,$07FC,$07FC,$1800,$1FE0,$1FE0     
L0001A17C   dc.w    $1FA0,$1FF0,$1FB0,$3FB0,$3EB0,$3EF0,$3FF0,$3370     
L0001A18C   dc.w    $0008,$0720,$0720,$0700,$0700,$0000,$0700,$0000     
L0001A19C   dc.w    $0040,$0180,$0000,$0000,$0000,$0000,$0040,$0000     
L0001A1AC   dc.w    $0040,$0040,$0140,$0104,$0004,$0084,$0000,$0090     
L0001A1BC   dc.w    $0080,$0080,$0080,$1000,$0080,$0000,$02C0,$0198     
L0001A1CC   dc.w    $0000,$0000,$1800,$1FC0,$1FC0,$1FC0,$17E0,$1FE0     
L0001A1DC   dc.w    $0FE0,$0BC4,$1BC4,$01E4,$0000,$0090,$0080,$0080     
L0001A1EC   dc.w    $0080,$1000,$0080,$0000,$0000,$0010,$0000,$0000     
L0001A1FC   dc.w    $1800,$1FC0,$1FC0,$1FC0,$17E0,$1FE0,$0FE0,$0BC4     
L0001A20C   dc.w    $1BC4,$01E4,$0000,$0090,$0080,$0080,$0080,$1000     
L0001A21C   dc.w    $0080,$0000,$0000,$0010,$0000,$3FF0,$0000,$3FF0     
L0001A22C   dc.w    $0000,$3FF0,$0000,$3FF8,$0000,$7FF8,$0000,$7FFC     
L0001A23C   dc.w    $0000,$7FFE,$0000,$7FFF,$0000,$FFFF,$8000,$FFFF     
L0001A24C   dc.w    $8000,$FFFF,$8000,$FFFF,$8000,$FE3F,$8000,$FE1F     
L0001A25C   dc.w    $8000,$FC1F,$8000,$FC1F,$8000,$FC1F,$8000,$FC0F     
L0001A26C   dc.w    $0000,$FC1F,$C000,$7F1F,$F000,$7FDF,$F000,$1FC0     
L0001A27C   dc.w    $0000,$1800,$0000,$1FE0,$0000,$1FE0,$0000,$1FD0     
L0001A28C   dc.w    $0000,$3FF0,$0000,$3FD0,$0000,$3FD8,$0000,$3FF8     
L0001A29C   dc.w    $0000,$7F68,$0000,$7F6A,$0000,$67A2,$0000,$001E     
L0001A2AC   dc.w    $0000,$7C1E,$0000,$7C0E,$0000,$7000,$0000,$700E     
L0001A2BC   dc.w    $0000,$0000,$0000,$7000,$0000,$0001,$0000,$0406     
L0001A2CC   dc.w    $0000,$0800,$0000,$0000,$0000,$0000,$0000,$0000     
L0001A2DC   dc.w    $0000,$0000,$0000,$0020,$0000,$0000,$0000,$0020     
L0001A2EC   dc.w    $0000,$0020,$0000,$0002,$0000,$0093,$0000,$0091     
L0001A2FC   dc.w    $0000,$0041,$0000,$0001,$0000,$0001,$0000,$0001     
L0001A30C   dc.w    $0000,$0800,$0000,$0801,$0000,$0000,$0000,$0800     
L0001A31C   dc.w    $0000,$000B,$0000,$2C06,$6000,$1980,$0000,$0000     
L0001A32C   dc.w    $0000,$0000,$0000,$1800,$0000,$1FE0,$0000,$1FF0     
L0001A33C   dc.w    $0000,$1FF0,$0000,$0FF0,$0000,$1FF0,$0000,$1FF2     
L0001A34C   dc.w    $0000,$17F3,$0000,$37F9,$0000,$01E1,$0000,$0001     
L0001A35C   dc.w    $0000,$0001,$0000,$0001,$0000,$0800,$0000,$0801     
L0001A36C   dc.w    $0000,$0000,$0000,$0800,$0000,$0000,$0000,$0000     
L0001A37C   dc.w    $4000,$0100,$0000,$0000,$0000,$0000,$0000,$1800     
L0001A38C   dc.w    $0000,$1FE0,$0000,$1FF0,$0000,$1FF0,$0000,$0FF0     
L0001A39C   dc.w    $0000,$1FF0,$0000,$1FF2,$0000,$17F3,$0000,$37F9     
L0001A3AC   dc.w    $0000,$01E1,$0000,$0001,$0000,$0001,$0000,$0001     
L0001A3BC   dc.w    $0000,$0800,$0000,$0801,$0000,$0000,$0000,$0800     
L0001A3CC   dc.w    $0000,$0000,$0000,$0000,$4000,$0100,$0000,$0000     
L0001A3DC   dc.w    $0000,$03FF,$0000,$03FF,$0000,$07FF,$8000,$07FF     
L0001A3EC   dc.w    $8000,$0FFF,$C000,$0FFF,$C000,$1FFF,$E000,$1FFF     
L0001A3FC   dc.w    $F000,$3FFF,$F800,$3FFF,$F800,$1FFF,$F800,$0FFF     
L0001A40C   dc.w    $F800,$1FC1,$F800,$1F80,$FC00,$3F00,$FC00,$3F00     
L0001A41C   dc.w    $FE00,$3E00,$7F00,$3E00,$7F00,$7E00,$3F80,$7F00     
L0001A42C   dc.w    $3FE0,$1FC0,$3FE0,$0FC0,$0000,$0180,$0000,$01FE     
L0001A43C   dc.w    $0000,$03FE,$0000,$03FA,$0000,$07FE,$0000,$07FA     
L0001A44C   dc.w    $0000,$0FFB,$0000,$0EFF,$0000,$1FDD,$4000,$1FDD     
L0001A45C   dc.w    $4000,$07BC,$6000,$0000,$E000,$0F80,$E000,$0E00     
L0001A46C   dc.w    $7000,$1C00,$3000,$0400,$0000,$1000,$3000,$0000     
L0001A47C   dc.w    $0000,$0400,$0200,$0600,$0C00,$0000,$0000,$0000     
L0001A48C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0004     
L0001A49C   dc.w    $0000,$0000,$0000,$0004,$0000,$0004,$4000,$0100     
L0001A4AC   dc.w    $6000,$0022,$3000,$0022,$3000,$0000,$1000,$0000     
L0001A4BC   dc.w    $1000,$0000,$1000,$0100,$0800,$0200,$0800,$0200     
L0001A4CC   dc.w    $0000,$0800,$0E00,$0400,$0000,$2C00,$1600,$1E00     
L0001A4DC   dc.w    $0CC0,$0180,$0000,$0000,$0000,$0000,$0000,$0180     
L0001A4EC   dc.w    $0000,$01FC,$0000,$01FE,$0000,$03FE,$0000,$03FE     
L0001A4FC   dc.w    $0000,$07BE,$4000,$07FE,$4000,$0BBE,$2000,$033F     
L0001A50C   dc.w    $2000,$001C,$1000,$0000,$1000,$0000,$1000,$0100     
L0001A51C   dc.w    $0800,$0200,$0800,$0200,$0000,$0800,$0C00,$0400     
L0001A52C   dc.w    $0000,$0000,$0000,$0000,$0080,$0100,$0000,$0000     
L0001A53C   dc.w    $0000,$0000,$0000,$0180,$0000,$01FC,$0000,$01FE     
L0001A54C   dc.w    $0000,$03FE,$0000,$03FE,$0000,$07BE,$4000,$07FE     
L0001A55C   dc.w    $4000,$0BBE,$2000,$033F,$2000,$001C,$1000,$0000     
L0001A56C   dc.w    $1000,$0000,$1000,$0100,$0800,$0200,$0800,$0200     
L0001A57C   dc.w    $0000,$0800,$0C00,$0400,$0000,$0000,$0000,$0000     
L0001A58C   dc.w    $0080,$0100,$0000,$0000,$0000,$00FF,$C000,$00FF     
L0001A59C   dc.w    $C000,$00FF,$E000,$00FF,$E000,$01FF,$E000,$01FF     
L0001A5AC   dc.w    $F000,$01FF,$F000,$03FF,$F800,$03FF,$F800,$03FF     
L0001A5BC   dc.w    $FC00,$03FF,$FC00,$07FF,$FC00,$0FF1,$F800,$0FE1     
L0001A5CC   dc.w    $F800,$3FC1,$F800,$7F81,$F800,$7F01,$F800,$3E01     
L0001A5DC   dc.w    $F800,$1E01,$F800,$0F00,$FE00,$0700,$FF80,$0000     
L0001A5EC   dc.w    $FF80,$0060,$0000,$007F,$8000,$007F,$8000,$00FD     
L0001A5FC   dc.w    $8000,$00FF,$8000,$00FD,$8000,$00FD,$A000,$01FD     
L0001A60C   dc.w    $A000,$01FF,$A000,$007B,$B000,$010F,$3000,$0270     
L0001A61C   dc.w    $3000,$00E0,$E000,$01C0,$E000,$0400,$E000,$0300     
L0001A62C   dc.w    $E000,$0000,$0000,$0800,$E000,$0000,$0000,$0000     
L0001A63C   dc.w    $0800,$0000,$3000,$0000,$0000,$0000,$0000,$0000     
L0001A64C   dc.w    $0000,$0000,$0000,$0002,$0000,$0000,$0000,$0002     
L0001A65C   dc.w    $0000,$0002,$0000,$0002,$1000,$0000,$1000,$0004     
L0001A66C   dc.w    $0800,$0080,$8800,$0180,$0800,$0300,$1000,$0400     
L0001A67C   dc.w    $1000,$0200,$1000,$1000,$1000,$0800,$0000,$1C00     
L0001A68C   dc.w    $1000,$0200,$0000,$0200,$5800,$0000,$3300,$0000     
L0001A69C   dc.w    $0000,$0000,$0000,$0060,$0000,$007F,$0000,$007F     
L0001A6AC   dc.w    $0000,$007F,$0000,$00FF,$0000,$006F,$0000,$005F     
L0001A6BC   dc.w    $1000,$001E,$1000,$0016,$8800,$0083,$8800,$0080     
L0001A6CC   dc.w    $0800,$0300,$1000,$0400,$1000,$0200,$1000,$0000     
L0001A6DC   dc.w    $1000,$0000,$0000,$0000,$1000,$0200,$0000,$0000     
L0001A6EC   dc.w    $0000,$0000,$0200,$0000,$0000,$0000,$0000,$0060     
L0001A6FC   dc.w    $0000,$007F,$0000,$007F,$0000,$007F,$0000,$00FF     
L0001A70C   dc.w    $0000,$006F,$0000,$005F,$1000,$001E,$1000,$0016     
L0001A71C   dc.w    $8800,$0083,$8800,$0080,$0800,$0300,$1000,$0400     
L0001A72C   dc.w    $1000,$0200,$1000,$0000,$1000,$0000,$0000,$0000     
L0001A73C   dc.w    $1000,$0200,$0000,$0000,$0000,$0000,$0200,$0000     
L0001A74C   dc.w    $0000,$3FF0,$0000,$3FF8,$0000,$3FF8,$0000,$3FF8     
L0001A75C   dc.w    $0000,$3FFC,$0000,$3FFE,$0000,$7FFF,$0000,$7FFF     
L0001A76C   dc.w    $8000,$7FFF,$8000,$7FFF,$8000,$7FFF,$0000,$3FFE     
L0001A77C   dc.w    $0000,$07FC,$0000,$07F8,$0000,$07F0,$0000,$07E0     
L0001A78C   dc.w    $0000,$0FE0,$0000,$1FE0,$0000,$0FE0,$0000,$07F8     
L0001A79C   dc.w    $0000,$03FE,$0000,$03FE,$0000,$1800,$0000,$1FE0     
L0001A7AC   dc.w    $0000,$1FE0,$0000,$1F60,$0000,$1FE0,$0000,$1F60     
L0001A7BC   dc.w    $0000,$3F68,$0000,$3F6C,$0000,$3E6C,$0000,$3E69     
L0001A7CC   dc.w    $0000,$334C,$0000,$0008,$0000,$02F8,$0000,$01E0     
L0001A7DC   dc.w    $0000,$0260,$0000,$0180,$0000,$0000,$0000,$0140     
L0001A7EC   dc.w    $0000,$0300,$0000,$0020,$0000,$0000,$0000,$0000     
L0001A7FC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0080     
L0001A80C   dc.w    $0000,$0008,$0000,$008C,$0000,$0086,$0000,$0083     
L0001A81C   dc.w    $0000,$0183,$0000,$0186,$0000,$00A2,$0000,$0004     
L0001A82C   dc.w    $0000,$0000,$0000,$0010,$0000,$0000,$0000,$0040     
L0001A83C   dc.w    $0000,$0400,$0000,$0B00,$0000,$0700,$0000,$01A0     
L0001A84C   dc.w    $0000,$0018,$0000,$0000,$0000,$0000,$0000,$1800     
L0001A85C   dc.w    $0000,$1FC0,$0000,$1FC0,$0000,$1FC8,$0000,$1FCC     
L0001A86C   dc.w    $0000,$1BC6,$0000,$0FC3,$0000,$0B83,$0000,$13A6     
L0001A87C   dc.w    $0000,$01E2,$0000,$0004,$0000,$0000,$0000,$0010     
L0001A88C   dc.w    $0000,$0000,$0000,$0040,$0000,$0000,$0000,$0000     
L0001A89C   dc.w    $0000,$0000,$0000,$0100,$0000,$0010,$0000,$0000     
L0001A8AC   dc.w    $0000,$0000,$0000,$1800,$0000,$1FC0,$0000,$1FC0     
L0001A8BC   dc.w    $0000,$1FC8,$0000,$1FCC,$0000,$1BC6,$0000,$0FC3     
L0001A8CC   dc.w    $0000,$0B83,$0000,$13A6,$0000,$01E2,$0000,$0004     
L0001A8DC   dc.w    $0000,$0000,$0000,$0010,$0000,$0000,$0000,$0040     
L0001A8EC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0100     
L0001A8FC   dc.w    $0000,$0010,$0000,$0000,$0000,$00FF,$0000,$00FF     
L0001A90C   dc.w    $0000,$00FF,$0000,$03FF,$C000,$01FF,$0000,$01FF     
L0001A91C   dc.w    $0000,$01FF,$0000,$03FF,$0000,$07FF,$0000,$1FFF     
L0001A92C   dc.w    $0000,$7FFF,$8000,$FFFF,$C000,$FFFF,$C000,$FFFF     
L0001A93C   dc.w    $C000,$7FFF,$C000,$1FFF,$E000,$03FF,$F000,$03FF     
L0001A94C   dc.w    $F000,$03FF,$E000,$03FF,$C000,$07FF,$8000,$07FF     
L0001A95C   dc.w    $8000,$0000,$0000,$007E,$0000,$0000,$0000,$0000     
L0001A96C   dc.w    $0000,$0124,$0000,$0174,$0000,$01BC,$0000,$021C     
L0001A97C   dc.w    $0000,$001A,$0000,$00E8,$0000,$15F1,$0000,$62E2     
L0001A98C   dc.w    $8000,$7040,$8000,$7D1A,$8000,$1D64,$8000,$004A     
L0001A99C   dc.w    $8000,$0186,$A000,$01FE,$4000,$01FE,$4000,$01FE     
L0001A9AC   dc.w    $0000,$03FE,$0000,$03FE,$0000,$0000,$0000,$0000     
L0001A9BC   dc.w    $0000,$007E,$0000,$0000,$0000,$00A0,$0000,$00FE     
L0001A9CC   dc.w    $0000,$00FE,$0000,$019D,$0000,$0049,$0000,$0700     
L0001A9DC   dc.w    $0000,$0A00,$0000,$1000,$0000,$0C0C,$0000,$0134     
L0001A9EC   dc.w    $0000,$007C,$0000,$0078,$0000,$0000,$2000,$0000     
L0001A9FC   dc.w    $6000,$0000,$4000,$0000,$0000,$0000,$0000,$0000     
L0001AA0C   dc.w    $0000,$0000,$0000,$0000,$0000,$0066,$0000,$0000     
L0001AA1C   dc.w    $0000,$008A,$0000,$00CA,$0000,$006E,$0000,$0113     
L0001AA2C   dc.w    $0000,$0018,$0000,$05C8,$0000,$1F60,$0000,$3062     
L0001AA3C   dc.w    $0000,$3448,$0000,$1C24,$0000,$011C,$0000,$0078 
L0001AA4C   dc.w    $0000,$0000,$0000,$0000,$6000,$0028,$4000,$00B0
L0001AA5C   dc.w    $0000,$01B8,$0000,$0138,$0000,$0000,$0000,$0000
L0001AA6C   dc.w    $0000,$0066,$0000,$0000,$0000,$00A0,$0000,$0034
L0001AA7C   dc.w    $0000,$0090,$0000,$008E,$0000,$0051,$0000,$05C8
L0001AA8C   dc.w    $0000,$1F60,$0000,$306E,$0000,$344E,$0000,$1C14
L0001AA9C   dc.w    $0000,$0060,$0000,$0000,$0000,$0000,$2000,$0000
L0001AAAC   dc.w    $0000,$0028,$0000,$00B0,$0000,$01B8,$0000,$0138
L0001AABC   dc.w    $0000,$07FF,$8000,$07FF,$8000,$0FFF,$8000,$0FFF
L0001AACC   dc.w    $C000,$1FFF,$C000,$1FFF,$E000,$3FFF,$E000,$3FFF
L0001AADC   dc.w    $E000,$3FFF,$E000,$1FFF,$E000,$1FC7,$E000,$3F87
L0001AAEC   dc.w    $E000,$3F87,$E000,$3F07,$E000,$3F07,$E000,$7E07
L0001AAFC   dc.w    $E000,$7E03,$C000,$7F07,$F000,$7FC7,$FC00,$7FC7
L0001AB0C   dc.w    $FC00,$03FE,$0000,$03F6,$0000,$07FE,$0000,$07F6
L0001AB1C   dc.w    $8000,$0FFE,$8000,$0EEE,$8000,$1FEE,$8000,$1FFE
L0001AB2C   dc.w    $8000,$1F2A,$C000,$0000,$8000,$0F83,$C000,$1F03
L0001AB3C   dc.w    $C000,$1D03,$C000,$1A00,$0000,$0003,$8000,$3800
L0001AB4C   dc.w    $0000,$0000,$0000,$0400,$4000,$1801,$8000,$0000
L0001AB5C   dc.w    $0000,$0000,$0000,$0008,$0000,$0000,$0000,$0008
L0001AB6C   dc.w    $0000,$0000,$0000,$0110,$4000,$0010,$4000,$0000
L0001AB7C   dc.w    $4000,$0014,$0000,$0000,$4000,$0000,$0000,$0000
L0001AB8C   dc.w    $0000,$0200,$0000,$0400,$0000,$0000,$4000,$0400
L0001AB9C   dc.w    $0000,$0000,$0000,$2C02,$C000,$1981,$9800,$0000
L0001ABAC   dc.w    $0000,$017C,$0000,$03FC,$0000,$03FC,$0000,$03FC
L0001ABBC   dc.w    $0000,$03BC,$0000,$07FC,$4000,$07B8,$4000,$073A
L0001ABCC   dc.w    $4000,$001E,$0000,$0000,$4000,$0000,$0000,$0000
L0001ABDC   dc.w    $0000,$0200,$0000,$0400,$0000,$0000,$4000,$0400
L0001ABEC   dc.w    $0000,$0000,$0000,$0000,$0000,$0100,$1000,$0000
L0001ABFC   dc.w    $0000,$017C,$0000,$03FC,$0000,$03FC,$0000,$03FC
L0001AC0C   dc.w    $0000,$03BC,$0000,$07FC,$4000,$07B8,$4000,$073A
L0001AC1C   dc.w    $4000,$001E,$0000,$0000,$4000,$0000,$0000,$0000
L0001AC2C   dc.w    $0000,$0200,$0000,$0400,$0000,$0000,$4000,$0400
L0001AC3C   dc.w    $0000,$0000,$0000,$0000,$0000,$0100,$1000,$0000
L0001AC4C   dc.w    $0000,$1000,$0000,$383F,$C000,$7C3F,$C000,$FC3F
L0001AC5C   dc.w    $C000,$FCFF,$F000,$7C7F,$E000,$3E7F,$C000,$3F7F
L0001AC6C   dc.w    $C000,$3FFF,$C000,$3FFF,$8000,$1FFF,$8000,$1FFF
L0001AC7C   dc.w    $C000,$0FFF,$E000,$07FF,$E000,$01FF,$E000,$01FF
L0001AC8C   dc.w    $E000,$01FF,$F000,$00FF,$F800,$00FF,$FE00,$00FF
L0001AC9C   dc.w    $FF00,$00FF,$FF00,$01FF,$FE00,$01FF,$EC00,$0000
L0001ACAC   dc.w    $0000,$0000,$0000,$301F,$8000,$5000,$0000,$1800
L0001ACBC   dc.w    $0000,$1064,$0000,$0046,$8000,$126B,$8000,$1903
L0001ACCC   dc.w    $8000,$1D82,$8000,$0EDB,$0000,$0FF5,$0000,$07F2
L0001ACDC   dc.w    $C000,$01F9,$C000,$007B,$4000,$007E,$4000,$0077
L0001ACEC   dc.w    $8000,$007D,$8000,$0079,$9000,$007B,$8A00,$007D
L0001ACFC   dc.w    $8000,$00FF,$8C00,$00FF,$8000,$0000,$0000,$0000
L0001AD0C   dc.w    $0000,$0000,$0000,$701F,$8000,$4800,$0000,$0014
L0001AD1C   dc.w    $0000,$0C3F,$8000,$0C2F,$8000,$0673,$8000,$0214
L0001AD2C   dc.w    $0000,$0120,$0000,$0008,$0000,$000C,$0000,$0006
L0001AD3C   dc.w    $0000,$0004,$0000,$0001,$0000,$0008,$0000,$0002
L0001AD4C   dc.w    $0000,$0006,$0000,$0004,$0A00,$0002,$0600,$0000
L0001AD5C   dc.w    $0C00,$0000,$0000,$0000,$0000,$0000,$0000,$3000
L0001AD6C   dc.w    $0000,$201D,$8000,$4000,$0000,$1001,$8000,$0C29
L0001AD7C   dc.w    $0000,$1A1D,$8000,$1F50,$0000,$0F16,$0000,$0F71
L0001AD8C   dc.w    $0000,$07F8,$0000,$00BE,$C000,$001B,$4000,$003F
L0001AD9C   dc.w    $0000,$001F,$0000,$000F,$0000,$0017,$0000,$0007
L0001ADAC   dc.w    $1000,$000E,$0000,$0027,$0600,$006E,$0C00,$004E
L0001ADBC   dc.w    $0000,$0000,$0000,$3000,$0000,$3800,$0000,$501D
L0001ADCC   dc.w    $8000,$0000,$0000,$0004,$0000,$0C06,$8000,$1A32
L0001ADDC   dc.w    $0000,$1F23,$8000,$0F02,$0000,$0F71,$0000,$07F8
L0001ADEC   dc.w    $0000,$00BE,$C000,$001B,$4000,$003F,$0000,$001F
L0001ADFC   dc.w    $0000,$000F,$0000,$0017,$0000,$0007,$1000,$000E
L0001AE0C   dc.w    $0A00,$0027,$0000,$006E,$0000,$004E,$0000,$03FF
L0001AE1C   dc.w    $03FF,$03FF,$0FFF,$07FF,$07FF,$07FE,$0FFC,$1FF8
L0001AE2C   dc.w    $1FF8,$1FFC,$1FFC,$1FFC,$1FFC,$3FFC,$3FFF,$3FFF
L0001AE3C   dc.w    $3FFF,$3FFE,$3FFC,$7FF8,$7FF8,$0000,$01F2,$0004
L0001AE4C   dc.w    $000B,$0617,$051E,$067C,$0838,$0930,$07E0,$0CE0
L0001AE5C   dc.w    $0CC8,$0F28,$0FE8,$1FE0,$1FD0,$1ECA,$1F64,$1FC4
L0001AE6C   dc.w    $1FE0,$3FE0,$3FE0,$0000,$0001,$01F2,$0004,$0188
L0001AE7C   dc.w    $0380,$0300,$06C0,$0CC0,$0000,$0300,$0300,$0000
L0001AE8C   dc.w    $0000,$0000,$0000,$0002,$0086,$0004,$0000,$0000
L0001AE9C   dc.w    $0000,$0000,$0002,$01E6,$0009,$011B,$0206,$007C
L0001AEAC   dc.w    $04B8,$04F0,$00E0,$03C0,$0B00,$0D08,$0F80,$0600
L0001AEBC   dc.w    $0D00,$0C40,$0686,$0F84,$0D00,$1B80,$1380,$0000
L0001AECC   dc.w    $0002,$01E6,$0009,$001B,$0106,$037C,$02B8,$08F0
L0001AEDC   dc.w    $00E0,$03C0,$0B00,$0D08,$0F80,$0600,$0D00,$0C42
L0001AEEC   dc.w    $0680,$0F80,$0D00,$1B80,$1380,$1800,$3C00,$7E00
L0001AEFC   dc.w    $FE00,$FC00,$F800,$F000,$C000,$8000,$8000,$0000
L0001AF0C   dc.w    $0800,$0400,$7000,$C800,$9000,$0000,$0000,$0000
L0001AF1C   dc.w    $0000,$0000,$0000,$1000,$7800,$F800,$F000,$0000
L0001AF2C   dc.w    $8000,$0000,$0000,$0000,$0800,$1000,$0800,$3800
L0001AF3C   dc.w    $7000,$0000,$8000,$0000,$0000,$0000,$1800,$1800
L0001AF4C   dc.w    $7800,$C000,$8000,$0000,$8000,$0000,$0000,$01FE
L0001AF5C   dc.w    $0000,$01FE,$0000,$01FE,$0000,$07FF,$8000,$03FF
L0001AF6C   dc.w    $0000,$03FF,$0000,$03FE,$0000,$07FE,$C000,$0FFF
L0001AF7C   dc.w    $C000,$0FFF,$C000,$0FFF,$C000,$1FFF,$C000,$1FFF
L0001AF8C   dc.w    $0000,$1FFE,$0000,$1FFE,$0000,$1FFC,$0000,$1FFC
L0001AF9C   dc.w    $0000,$3FF8,$0000,$3FF8,$0000,$3FF8,$0000,$7FF8
L0001AFAC   dc.w    $0000,$7FF8,$0000,$0000,$0000,$00FC,$0000,$0000
L0001AFBC   dc.w    $0000,$0000,$0000,$0310,$0000,$029A,$0000,$032C
L0001AFCC   dc.w    $0000,$040C,$0000,$0470,$0000,$0611,$8000,$04A1
L0001AFDC   dc.w    $C000,$0E0F,$0000,$0FFC,$0000,$0FE0,$0000,$0FF0
L0001AFEC   dc.w    $0000,$0FD0,$0000,$0F60,$0000,$1F60,$0000,$1EC0
L0001AFFC   dc.w    $0000,$1FE0,$0000,$3FE0,$0000,$3FE0,$0000,$0000
L0001B00C   dc.w    $0000,$0000,$0000,$00FC,$0000,$0000,$0000,$00D0
L0001B01C   dc.w    $0000,$01FE,$0000,$01BC,$0000,$03CC,$0000,$0600
L0001B02C   dc.w    $C000,$01AE,$4000,$035E,$0000,$01F0,$0000,$0000
L0001B03C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001B04C   dc.w    $0000,$0080,$0000,$0100,$0000,$0000,$0000,$0000
L0001B05C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$00F4
L0001B06C   dc.w    $0000,$0000,$0000,$0084,$0000,$0124,$0000,$0074
L0001B07C   dc.w    $0000,$0240,$0000,$0030,$8000,$0304,$C000,$02FF
L0001B08C   dc.w    $C000,$07FC,$0000,$07F0,$0000,$07C0,$0000,$0700
L0001B09C   dc.w    $0000,$0500,$0000,$0420,$0000,$0080,$0000,$0580
L0001B0AC   dc.w    $0000,$0D00,$0000,$1B80,$0000,$1380,$0000,$0000
L0001B0BC   dc.w    $0000,$0000,$0000,$00F4,$0000,$0000,$0000,$0010
L0001B0CC   dc.w    $0000,$009A,$0000,$01C8,$0000,$018C,$0000,$0630
L0001B0DC   dc.w    $8000,$0344,$C000,$02FF,$C000,$07FC,$0000,$07F0
L0001B0EC   dc.w    $0000,$07C0,$0000,$0700,$0000,$0500,$0000,$0420
L0001B0FC   dc.w    $0000,$0080,$0000,$0580,$0000,$0D00,$0000,$1B80
L0001B10C   dc.w    $0000,$1380,$0000,$0070,$01E0,$1FF0,$FFC0,$FFE0
L0001B11C   dc.w    $FC00,$F000,$8000,$0000,$0000,$0100,$1280,$3000
L0001B12C   dc.w    $E000,$8000,$0000,$0000,$0040,$0180,$1380,$C000
L0001B13C   dc.w    $0000,$0000,$0000,$0000,$0040,$0080,$0180,$9000
L0001B14C   dc.w    $E000,$0000,$0000,$0000,$0000,$0100,$0200,$8000
L0001B15C   dc.w    $E000,$0000,$0000,$1001,$0000,$0000,$0000,$0801
L0001B16C   dc.w    $0000,$0000,$0000,$5401,$0000,$6901,$0020,$3703
L0001B17C   dc.w    $0040,$1F83,$8080,$0F92,$C094,$77EA,$C1A8,$3BFB
L0001B18C   dc.w    $C5F0,$1001,$0000,$0000,$0000,$0801,$0000,$0000
L0001B19C   dc.w    $0000,$4401,$0000,$6001,$0020,$0202,$0040,$0182
L0001B1AC   dc.w    $8080,$0492,$4000,$21CA,$C080,$184A,$4440,$0000
L0001B1BC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001B1CC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001B1DC   dc.w    $0010,$0000,$8000,$0000,$0040,$1001,$0000,$0000
L0001B1EC   dc.w    $0000,$0801,$0000,$0000,$0000,$4401,$0000,$6001
L0001B1FC   dc.w    $0020,$0202,$0040,$0182,$8080,$0492,$4000,$21CA
L0001B20C   dc.w    $4080,$184A,$4400,$0001,$0000,$0000,$0000,$0001
L0001B21C   dc.w    $0000,$0000,$0000,$5001,$0000,$6801,$0000,$0403
L0001B22C   dc.w    $0000,$0703,$8000,$0712,$C090,$332A,$41A0,$123B
L0001B23C   dc.w    $C1A0,$0008,$0000,$0000,$0008,$0000,$0000,$0000
L0001B24C   dc.w    $0000,$0000,$0008,$0000,$0000,$0000,$0000,$0000
L0001B25C   dc.w    $0008,$0800,$0000,$0008,$0800,$0000,$0008,$0000
L0001B26C   dc.w    $0000,$0018,$0800,$0000,$001C,$8800,$0000,$001C
L0001B27C   dc.w    $8800,$0000,$001C,$9000,$0000,$001C,$DC80,$0000
L0001B28C   dc.w    $001C,$DC80,$8000,$001C,$C481,$8000,$001D,$C583
L0001B29C   dc.w    $0000,$001D,$C587,$0000,$043D,$EB0E,$0000,$043F
L0001B2AC   dc.w    $EB0E,$0000,$073D,$EB9E,$0000,$07BF,$EBBC,$0000
L0001B2BC   dc.w    $03BF,$EBFC,$0000,$03FF,$EBF8,$0000,$07FF,$EBF8
L0001B2CC   dc.w    $0000,$03FF,$EFF8,$4000,$03FF,$FFF1,$8000,$0FFF
L0001B2DC   dc.w    $FFF7,$8000,$03FF,$FFFF,$0000,$1BFF,$FFFE,$5200
L0001B2EC   dc.w    $0DFF,$FFFF,$0C00,$23FF,$FFFE,$1000,$0B7F,$FFFC
L0001B2FC   dc.w    $4000,$E3FF,$FFFD,$FE00,$0008,$0000,$0000,$0008
L0001B30C   dc.w    $0000,$0000,$0000,$0000,$0000,$0008,$0000,$0000
L0001B31C   dc.w    $0000,$0000,$0000,$0008,$0800,$0000,$0008,$0800
L0001B32C   dc.w    $0000,$0008,$0000,$0000,$0008,$0800,$0000,$000C
L0001B33C   dc.w    $8800,$0000,$000C,$8000,$0000,$000C,$9000,$0000
L0001B34C   dc.w    $0004,$D400,$0000,$000C,$5480,$8000,$0004,$C481
L0001B35C   dc.w    $8000,$000D,$4583,$0000,$0005,$4505,$0000,$0415
L0001B36C   dc.w    $230A,$0000,$0415,$210A,$0000,$0315,$2294,$0000
L0001B37C   dc.w    $0315,$21B4,$0000,$0195,$61C8,$0000,$018D,$20A8
L0001B38C   dc.w    $0000,$07CD,$6110,$0000,$0245,$6D50,$4000,$0061
L0001B39C   dc.w    $1591,$8000,$0767,$65A7,$0000,$0261,$152A,$0000
L0001B3AC   dc.w    $1B67,$6574,$5000,$0D37,$6CCB,$0000,$23B0,$689C
L0001B3BC   dc.w    $0000,$0B12,$69E0,$0000,$219F,$E354,$0E00,$0000
L0001B3CC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001B3DC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001B3EC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001B3FC   dc.w    $0000,$0000,$0000,$0000,$0000,$0008,$0000,$0000
L0001B40C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001B41C   dc.w    $0000,$0000,$0080,$0000,$0000,$0000,$0000,$0000
L0001B42C   dc.w    $0080,$0000,$0008,$0000,$0000,$0000,$0000,$0000
L0001B43C   dc.w    $0008,$0000,$0000,$0000,$0010,$0000,$0000,$4000
L0001B44C   dc.w    $0000,$0008,$0020,$0000,$0008,$4000,$0000,$0000
L0001B45C   dc.w    $4040,$0000,$0000,$0180,$0000,$0000,$4180,$0000
L0001B46C   dc.w    $0000,$0100,$0000,$0000,$4100,$0000,$0000,$4000
L0001B47C   dc.w    $0000,$0000,$4000,$0000,$0000,$4000,$0000,$0000
L0001B48C   dc.w    $4020,$7000,$0008,$0000,$0000,$0008,$0000,$0000
L0001B49C   dc.w    $0000,$0000,$0000,$0008,$0000,$0000,$0000,$0000
L0001B4AC   dc.w    $0000,$0008,$0800,$0000,$0008,$0800,$0000,$0008
L0001B4BC   dc.w    $0000,$0000,$0008,$0800,$0000,$000C,$8800,$0000
L0001B4CC   dc.w    $0004,$8000,$0000,$000C,$9000,$0000,$0004,$D400
L0001B4DC   dc.w    $0000,$000C,$5480,$8000,$0004,$C401,$8000,$000D
L0001B4EC   dc.w    $4583,$0000,$0005,$4505,$0000,$0415,$230A,$0000
L0001B4FC   dc.w    $0415,$210A,$0000,$0315,$2294,$0000,$0315,$21A4
L0001B50C   dc.w    $0000,$0195,$21C8,$0000,$0185,$2088,$0000,$07C5
L0001B51C   dc.w    $2110,$0000,$0245,$2D10,$4000,$0061,$1411,$8000
L0001B52C   dc.w    $0767,$2427,$0000,$0261,$142A,$0000,$1B67,$2474
L0001B53C   dc.w    $5000,$0D37,$2CCB,$0000,$23B0,$289C,$0000,$0B12
L0001B54C   dc.w    $29E0,$0000,$219F,$A354,$1E00,$0008,$0000,$0000
L0001B55C   dc.w    $0008,$0000,$0000,$0000,$0000,$0000,$0008,$0000
L0001B56C   dc.w    $0000,$0000,$0000,$0000,$0008,$0800,$0000,$0008
L0001B57C   dc.w    $0800,$0000,$0008,$0000,$0000,$0008,$0800,$0000
L0001B58C   dc.w    $000C,$8800,$0000,$0004,$8800,$0000,$000C,$9000
L0001B59C   dc.w    $0000,$000C,$DC80,$0000,$000C,$DC80,$8000,$000C
L0001B5AC   dc.w    $C401,$8000,$000D,$C583,$0000,$000D,$C587,$0000
L0001B5BC   dc.w    $041D,$EB0E,$0000,$041D,$EB0E,$0000,$031D,$EB9C
L0001B5CC   dc.w    $0000,$031D,$EBAC,$0000,$009D,$ABF8,$0000,$0285
L0001B5DC   dc.w    $EBD8,$0000,$07C5,$ABF0,$0000,$03CD,$ABB0,$4000
L0001B5EC   dc.w    $03AD,$FA71,$8000,$07AB,$9A67,$0000,$03AD,$FACE
L0001B5FC   dc.w    $0000,$1BAB,$9ABC,$5000,$0DDB,$973B,$0000,$23EF
L0001B60C   dc.w    $977E,$0000,$017D,$967C,$0000,$E2F4,$9EFC,$1E00
L0001B61C   dc.w    $0000,$1000,$0000,$0000,$1000,$0000,$0000,$0000
L0001B62C   dc.w    $0000,$0000,$1000,$0000,$0000,$3000,$0000,$0000
L0001B63C   dc.w    $3001,$0000,$0000,$1001,$0000,$0000,$2000,$0000
L0001B64C   dc.w    $0000,$3001,$0000,$0308,$3001,$0000,$0182,$3801
L0001B65C   dc.w    $0000,$00C8,$3901,$0000,$0048,$2900,$0000,$0162
L0001B66C   dc.w    $2901,$8000,$0061,$3101,$8000,$0315,$3901,$8040
L0001B67C   dc.w    $0077,$3903,$9008,$0139,$BB03,$A4A0,$00CB,$BB83
L0001B68C   dc.w    $C020,$000A,$BAC7,$1A60,$107D,$FAC6,$9A40,$187F
L0001B69C   dc.w    $7BD6,$BCC0,$4C3F,$FAD7,$3548,$271F,$FFD7,$AF80
L0001B6AC   dc.w    $01BF,$FFDE,$B300,$60CF,$FEFE,$7690,$002F,$FEE6
L0001B6BC   dc.w    $F784,$007F,$FFFF,$EF0C,$0037,$FEFF,$FF5C,$000F
L0001B6CC   dc.w    $FEFF,$FEFC,$000F,$FFFF,$FEFC,$0007,$FFFF,$FFD8
L0001B6DC   dc.w    $00DF,$FFFF,$FFE0,$006F,$FFFF,$FFC0,$0017,$FFFF
L0001B6EC   dc.w    $FF00,$000B,$FFFF,$FF00,$0009,$FFFF,$E610,$0007
L0001B6FC   dc.w    $FFFF,$CA00,$0003,$FFFF,$FC80,$0001,$FFFF,$ED80
L0001B70C   dc.w    $0001,$FFFF,$FB00,$0007,$FFFF,$FE00,$0003,$FFFF
L0001B71C   dc.w    $FE00,$0001,$FFFF,$ED80,$0001,$FFFF,$FB00,$0007
L0001B72C   dc.w    $FFFF,$FE00,$0003,$FFFF,$FE00,$0007,$FFFF,$FE00
L0001B73C   dc.w    $0003,$FFFF,$FE00,$008B,$FFFF,$FF80,$03FF,$FFFF
L0001B74C   dc.w    $FFFC,$0000,$1000,$0000,$0000,$1000,$0000,$0000
L0001B75C   dc.w    $0000,$0000,$0000,$1000,$0000,$0000,$0000,$0000
L0001B76C   dc.w    $0000,$1001,$0000,$0000,$1001,$0000,$0000,$0000
L0001B77C   dc.w    $0000,$0000,$1001,$0000,$0200,$0001,$0000,$0100
L0001B78C   dc.w    $0800,$0000,$0080,$1901,$0000,$0008,$0900,$0000
L0001B79C   dc.w    $0040,$0901,$8000,$0060,$0101,$8000,$0300,$1901
L0001B7AC   dc.w    $8000,$0077,$0903,$8000,$0121,$0A03,$A020,$0088
L0001B7BC   dc.w    $1A83,$C020,$0002,$1A45,$1000,$1059,$0AC6,$9040
L0001B7CC   dc.w    $0049,$1A54,$A8C0,$4435,$8AD5,$2140,$071D,$BA13
L0001B7DC   dc.w    $A680,$01BA,$9A9A,$A300,$00CE,$C238,$4600,$000E
L0001B7EC   dc.w    $5222,$C684,$007E,$44AA,$0D0C,$0037,$2C3C,$1D18
L0001B7FC   dc.w    $000D,$AEA9,$2E24,$000D,$C0EA,$66F8,$0007,$226E
L0001B80C   dc.w    $7E40,$00CA,$8668,$7B80,$0067,$58F9,$2800,$0013
L0001B81C   dc.w    $3CE9,$2800,$0008,$D26B,$6600,$0008,$DA28,$4400
L0001B82C   dc.w    $0005,$6232,$0800,$0002,$FABD,$1880,$0001,$F85C
L0001B83C   dc.w    $2000,$0001,$68D5,$D200,$0003,$E851,$D800,$0003
L0001B84C   dc.w    $6613,$9000,$0001,$FC5C,$2000,$0001,$60D5,$D200
L0001B85C   dc.w    $0003,$EC51,$D800,$0003,$4613,$9000,$0003,$E451
L0001B86C   dc.w    $D800,$0003,$6613,$9000,$0001,$E421,$CA00,$02C5
L0001B87C   dc.w    $F292,$DB5C,$0000,$0000,$0000,$0000,$0000,$0000
L0001B88C   dc.w    $0000,$0000,$0000,$0000,$1000,$0000,$0000,$0000
L0001B89C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001B8AC   dc.w    $0000,$0000,$0000,$0001,$0000,$0000,$0000,$0000
L0001B8BC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001B8CC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001B8DC   dc.w    $1000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001B8EC   dc.w    $0000,$0000,$0000,$0000,$1000,$0000,$0000,$0080
L0001B8FC   dc.w    $0000,$0000,$1002,$0000,$0000,$0080,$0000,$0000
L0001B90C   dc.w    $0080,$0000,$0000,$1082,$0000,$0000,$0880,$0000
L0001B91C   dc.w    $0000,$1802,$0000,$0010,$0082,$0000,$0000,$0000
L0001B92C   dc.w    $0000,$0000,$0280,$0000,$0000,$0082,$0080,$0000
L0001B93C   dc.w    $0202,$0000,$0000,$0200,$0100,$0000,$0082,$0000
L0001B94C   dc.w    $0000,$0080,$0000,$0000,$0202,$0000,$0000,$0281
L0001B95C   dc.w    $0000,$0000,$000A,$0000,$0000,$0080,$0080,$0000
L0001B96C   dc.w    $0000,$0000,$0000,$0280,$0000,$0000,$0000,$0000
L0001B97C   dc.w    $0000,$0200,$0000,$0000,$0000,$0000,$0000,$0280
L0001B98C   dc.w    $0000,$0000,$0000,$0000,$0000,$2200,$0000,$0000
L0001B99C   dc.w    $0000,$0000,$0000,$0200,$0000,$0000,$0000,$0000
L0001B9AC   dc.w    $0008,$0000,$0080,$0000,$1000,$0000,$0000,$1000
L0001B9BC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001B9CC   dc.w    $0000,$0000,$0000,$1001,$0000,$0000,$1001,$0000
L0001B9DC   dc.w    $0000,$0000,$0000,$0000,$1000,$0000,$0200,$0001
L0001B9EC   dc.w    $0000,$0100,$0800,$0000,$0080,$1901,$0000,$0008
L0001B9FC   dc.w    $0900,$0000,$0040,$0901,$8000,$0060,$0101,$8000
L0001BA0C   dc.w    $0300,$0901,$8000,$0077,$0903,$8000,$0121,$0A03
L0001BA1C   dc.w    $A020,$0088,$1A83,$C020,$0002,$0A45,$1000,$1059
L0001BA2C   dc.w    $0A46,$9040,$0049,$0A54,$A8C0,$4435,$8A55,$2140
L0001BA3C   dc.w    $071D,$BA13,$A680,$01BA,$8A18,$A300,$00CE,$C238
L0001BA4C   dc.w    $4600,$000E,$4220,$C684,$006E,$4428,$0D0C,$0037
L0001BA5C   dc.w    $2C3C,$1D18,$000D,$AC29,$2E24,$000D,$C068,$6678
L0001BA6C   dc.w    $0007,$206C,$7E40,$00CA,$8468,$7A80,$0067,$5879
L0001BA7C   dc.w    $2800,$0013,$3C69,$2800,$0008,$D069,$6600,$0008
L0001BA8C   dc.w    $D828,$4400,$0005,$6230,$0800,$0002,$FA3D,$1800
L0001BA9C   dc.w    $0001,$F85C,$2000,$0001,$6855,$D200,$0003,$E851
L0001BAAC   dc.w    $D800,$0003,$6413,$9000,$0001,$FC5C,$2000,$0001
L0001BABC   dc.w    $6055,$D200,$0003,$EC51,$D800,$0003,$4413,$9000
L0001BACC   dc.w    $0003,$E451,$D800,$0003,$6413,$9000,$0001,$E421
L0001BADC   dc.w    $CA00,$02C5,$F292,$DB5C,$0000,$1000,$0000,$0000
L0001BAEC   dc.w    $1000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001BAFC   dc.w    $0000,$1000,$0000,$0000,$1001,$0000,$0000,$1001
L0001BB0C   dc.w    $0000,$0000,$0000,$0000,$0000,$1000,$0000,$0308
L0001BB1C   dc.w    $1001,$0000,$0182,$1801,$0000,$00C8,$1901,$0000
L0001BB2C   dc.w    $0048,$0900,$0000,$0162,$0901,$8000,$0041,$1101
L0001BB3C   dc.w    $8000,$0315,$0901,$8040,$0044,$1903,$9008,$0138
L0001BB4C   dc.w    $9B03,$A4A0,$00C3,$9B83,$C020,$000A,$8AC7,$1A60
L0001BB5C   dc.w    $0074,$DA46,$9A40,$1857,$4BD4,$BCC0,$4C3F,$5A57
L0001BB6C   dc.w    $3548,$061B,$7BD5,$AF80,$019F,$EB5C,$B200,$60CD
L0001BB7C   dc.w    $B2FE,$7690,$002D,$A2E4,$F584,$006D,$BD6D,$EF0C
L0001BB8C   dc.w    $0034,$F4FE,$FB5C,$000E,$FC6F,$F6DC,$000C,$BB6D
L0001BB9C   dc.w    $DE78,$0004,$F9ED,$EDC0,$00CF,$7DAF,$DCC0,$0064
L0001BBAC   dc.w    $B73E,$DF00,$0012,$DB3F,$DE00,$0008,$7DBD,$9600
L0001BBBC   dc.w    $0008,$7DFE,$E400,$0005,$3DF5,$C800,$0002,$BD7E
L0001BBCC   dc.w    $B800,$0001,$BFBF,$8900,$0001,$773E,$F200,$0003
L0001BBDC   dc.w    $BFBE,$FC00,$0003,$B9FE,$FC00,$0001,$BFBF,$8900
L0001BBEC   dc.w    $0001,$7F3E,$F200,$0003,$BBBE,$FC00,$0003,$99FE
L0001BBFC   dc.w    $FC00,$0003,$BBBE,$FC00,$0003,$B9FE,$FC00,$0001
L0001BC0C   dc.w    $BBFE,$F600,$03DD,$FFFF,$FFDC,$0000,$0001,$0000
L0001BC1C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001BC2C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001BC3C   dc.w    $0000,$0000,$0001,$0000,$0000,$0000,$0000,$0000
L0001BC4C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$1021,$0000
L0001BC5C   dc.w    $0000,$0400,$0000,$0000,$0000,$0100,$1020,$0000
L0001BC6C   dc.w    $0000,$0000,$1020,$0000,$0000,$0040,$1201,$0000
L0001BC7C   dc.w    $0000,$0000,$0025,$0000,$0000,$0020,$0220,$0000
L0001BC8C   dc.w    $0000,$0008,$0024,$0000,$0000,$0000,$8221,$0000
L0001BC9C   dc.w    $0000,$0504,$0301,$0000,$0000,$0080,$C265,$0000
L0001BCAC   dc.w    $0000,$0032,$4265,$0080,$0000,$0038,$A371,$0100
L0001BCBC   dc.w    $0000,$05F4,$1A71,$0000,$0000,$007F,$9A57,$0200
L0001BCCC   dc.w    $0000,$01FF,$EAD3,$1480,$8000,$07FF,$FEF7,$9809
L0001BCDC   dc.w    $0000,$0FFF,$7EEF,$8AEE,$0000,$12FF,$FCFF,$9CFF
L0001BCEC   dc.w    $0000,$101F,$FDFF,$F3FC,$A400,$2047,$FFFF,$EFF4
L0001BCFC   dc.w    $1000,$037F,$FFFF,$F7F9,$2000,$21FF,$FF7F,$F7F0
L0001BD0C   dc.w    $8000,$AFFF,$FFFE,$FFE7,$D000,$1FFF,$FFF7,$BFDF
L0001BD1C   dc.w    $0000,$13FF,$FFF7,$7FBC,$0000,$07FF,$FFFF,$FFF8
L0001BD2C   dc.w    $0000,$03FF,$FFFF,$BEE4,$0000,$17FF,$FFFF,$7FF9
L0001BD3C   dc.w    $8000,$27FF,$FFF6,$FFCA,$0000,$4FFF,$FFFF,$FFF0
L0001BD4C   dc.w    $0000,$077F,$FFFF,$FFE0,$0000,$087D,$FFFF,$FFFF
L0001BD5C   dc.w    $0000,$62FD,$FFFF,$FF80,$0000,$0FFF,$FFFF,$FFFC
L0001BD6C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001BD7C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001BD8C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001BD9C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001BDAC   dc.w    $0000,$0000,$1000,$0000,$0000,$0000,$0000,$0000
L0001BDBC   dc.w    $0000,$0000,$1000,$0000,$0000,$0000,$1000,$0000
L0001BDCC   dc.w    $0000,$0000,$1000,$0000,$0000,$0000,$0001,$0000
L0001BDDC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001BDEC   dc.w    $0000,$0000,$0201,$0000,$0000,$0000,$0200,$0000
L0001BDFC   dc.w    $0000,$0000,$0241,$0000,$0000,$0000,$0040,$0000
L0001BE0C   dc.w    $0000,$0000,$0250,$0000,$0000,$05E0,$0A11,$0000
L0001BE1C   dc.w    $0000,$005A,$0811,$0000,$0000,$01FB,$0A13,$0080
L0001BE2C   dc.w    $0000,$061D,$8211,$8008,$0000,$0BCE,$0E09,$826A
L0001BE3C   dc.w    $0000,$10FF,$1829,$8CB0,$0000,$001F,$8C39,$D110
L0001BE4C   dc.w    $A000,$2047,$F421,$E060,$0000,$001F,$7469,$E1C0
L0001BE5C   dc.w    $0000,$0092,$F06D,$7300,$0000,$05DF,$6A6E,$7FC1
L0001BE6C   dc.w    $D000,$1F77,$DCF4,$1F83,$0000,$13CF,$E8E4,$2F28
L0001BE7C   dc.w    $0000,$0794,$DE60,$7A10,$0000,$0201,$7A20,$A420
L0001BE8C   dc.w    $0000,$14FE,$5E38,$7C00,$0000,$2751,$7FB0,$F000
L0001BE9C   dc.w    $0000,$4D0F,$8EF8,$6000,$0000,$001C,$2FAC,$6000
L0001BEAC   dc.w    $0000,$0031,$7D13,$F0D7,$0000,$006D,$9FA1,$C800
L0001BEBC   dc.w    $0000,$0BD4,$BD82,$DB5C,$0000,$0000,$0000,$0000
L0001BECC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001BEDC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001BEEC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001BEFC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001BF0C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001BF1C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001BF2C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001BF3C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001BF4C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0001,$0000
L0001BF5C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001BF6C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001BF7C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001BF8C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001BF9C   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001BFAC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001BFBC   dc.w    $0000,$0000,$0200,$0000,$0000,$0000,$0082,$0000
L0001BFCC   dc.w    $0000,$0000,$0080,$0000,$0000,$0000,$0200,$0000
L0001BFDC   dc.w    $0000,$0000,$0280,$0020,$0000,$0000,$0000,$0000
L0001BFEC   dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L0001BFFC   dc.w    $0000,$0000,$0000



            ; If Test Build - Include the Bottom Panel (Score, Energy, Lives, Timer etc)
            IFD TEST_BUILD_LEVEL
                incdir      "../panel/"
                include     "panel.s" 
                even
            ENDC

            ; If test build - allocate display buffer memory
            IFD TEST_BUILD_LEVEL
            even
display_buffer1     dcb.b   BATCAVE_DISPLAY_BUFFER_SIZE,$0f
display_buffer2     dcb.b   BATCAVE_DISPLAY_BUFFER_SIZE,$33
            ENDC

                    ;-------------------------------------------------------------------------------------------
                    ; My Debug Routines
                    ;-------------------------------------------------------------------------------------------
                    ; I added the following routines to allow 'signals' to be flashed on screen, and/or
                    ; the game to be paused as required.
                    ;
                    ; The routines are used to modify routines so that I can flash the screen, pause the
                    ; game when certain code is executed.
                    ;

_DEBUG_COLOUR_RED
            move.w  #$f00,$dff180
            rts

_DEBUG_COLOUR_GREEN
            move.w  #$0f0,$dff180
            rts

_DEBUG_COLOUR_BLUE
            move.w  #$00f,$dff180
            rts                    

_DEBUG_COLOURS
            move.w  d0,$dff180
            add.w   #$1,d0
            btst    #6,$bfe001
            bne.s   _DEBUG_COLOURS
            rts
            
_DEBUG_RED_PAUSE
                    move.w  #$f00,$dff180
                    btst    #6,$bfe001
                    bne.s   _DEBUG_RED_PAUSE
                    rts

_MOUSE_WAIT
            btst    #6,$bfe001
            bne.s   _MOUSE_WAIT
            rts

