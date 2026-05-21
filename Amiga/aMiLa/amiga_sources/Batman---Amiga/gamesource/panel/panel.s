

INFINITE_ENERGY_CHEAT   SET 1                           ; if defined then the 'JAMMMM' cheat also gives infinite energy.


                section panel_iff,code_c

            IFND    TEST_BUILD_LEVEL
                org     $7C7FC                                      ; original load address
            ENDC


                IFND TEST_BUILD_LEVEL
; Panel Constants - original function addresses
PANEL_UPDATE                    EQU $0007c800                       ; called on VBL to update panel display
PANEL_INIT_TIMER                EQU $0007c80e                       ; initialise level timer (D0.w = BCD encoded MIN:SEC)
PANEL_INIT_SCORE                EQU $0007c81c                       ; initialise player score
PANEL_ADD_SCORE                 EQU $0007c82a                       ; add value to player score (D0.l = BCD encoded value)
PANEL_INIT_LIVES                EQU $0007c838                       ; initialise player lives
PANEL_ADD_LIFE                  EQU $0007c846                       ; add 1 to player lives
PANEL_INIT_ENERGY               EQU $0007c854                       ; initialise player energy to full value
PANEL_LOSE_LIFE                 EQU $0007c862                       ; sub 1 from player lives, check end game, set status bytes
PANEL_LOSE_ENERGY               EQU $0007c870                       ; reduce player energy (increase hit damage) D0.w = amount to lose
; Panel Constants - original data value addresses
PANEL_STATUS_1                  EQU $0007c874                       ; Game Status Bits
PANEL_STATUS_2                  EQU $0007c875                       ; Game Status Bits
PANEL_LIVES_COUNT               EQU $0007c876                       ; player lives left
PANEL_HISCORE                   EQU $0007c878                       ; hi-score BCD value
PANEL_SCORE                     EQU $0007c87c                       ; player score BCD value
PANEL_FRAMETICK                 EQU $0007c880                       ; counts down from 50 to 0 on each update
PANEL_TIMER_UPDATE_VALUE        EQU $0007c882                       ; Timer BCD update value
PANEL_TIMER_VALUE               EQU $0007c884                       ; Timer BCD value Min:Sec (word)
PANEL_TIMER_SECONDS             EQU $0007c885                       ; Timer BCD seconds value
PANEL_SCORE_UPDATE_VALUE        EQU $0007c886                       ; player score update value
PANEL_SCORE_DISPLAY_VALUE       EQU $0007c88a                       ; player score copy BCD value used for display
PANEL_ENERGY_VALUE              EQU $0007c88e                       ; player energy value (40 max value)
PANEL_HIT_DAMAGE                EQU $0007c890                       ; player hit damge (subtracted from player energy on each panel update)
; Panel Constants - resources
PANEL_GFX                       EQU $0007c89a                                                   ; main bottom display panel gfx
PANEL_BATMAN_GFX                EQU $0007e69a                                                   ; batman energy image
PANEL_JOKER_GFX                 EQU $0007ebba                                                   ; joker energy image
PANEL_SCORE_GFX                 EQU $0007f30a                                                   ; score digits gfx
PANEL_LIVES_ON_GFX              EQU $0007f374                                                   ; batman symbol - lives icon 'on'
PANEL_LIVES_OFF_GFX             EQU $0007f838                                                   ; batman symbol - lives icon 'off'
                    ENDC
                    IFD TEST_BUILD_LEVEL
; Panel Constants - original function addresses
PANEL_UPDATE                    EQU Panel_Update                    ; called on VBL to update panel display
PANEL_INIT_TIMER                EQU Initialise_Level_Timer          ; initialise level timer (D0.w = BCD encoded MIN:SEC)
PANEL_INIT_SCORE                EQU Initialise_Player_Score         ; initialise player score
PANEL_ADD_SCORE                 EQU Update_Player_Score             ; add value to player score (D0.l = BCD encoded value)
PANEL_INIT_LIVES                EQU Initialise_Player_Lives         ; initialise player lives
PANEL_ADD_LIFE                  EQU Add_Extra_Life                  ; add 1 to player lives
PANEL_INIT_ENERGY               EQU Initialise_Player_Energy        ; initialise player energy to full value
PANEL_LOSE_LIFE                 EQU Lose_a_Life                     ; sub 1 from player lives, check end game, set status bytes
PANEL_LOSE_ENERGY               EQU Add_Hit_Damage                  ; reduce player energy (increase hit damage) D0.w = amount to lose
; Panel Constants - original data value addresses
PANEL_STATUS_1                  EQU panel_status_1                  ; Game Status Bits
PANEL_STATUS_2                  EQU panel_status_2                  ; Game Status Bits
PANEL_LIVES_COUNT               EQU player_lives_count              ; player lives left
PANEL_HISCORE                   EQU High_Score                      ; hi-score BCD value
PANEL_SCORE                     EQU Player_Score                    ; player score BCD value
PANEL_FRAMETICK                 EQU frame_tick                      ; counts down from 50 to 0 on each update
PANEL_TIMER_UPDATE_VALUE        EQU clock_timer_update_value        ; Timer BCD update value
PANEL_TIMER_VALUE               EQU clock_timer_minutes             ; Timer BCD value Min:Sec (word)
PANEL_TIMER_SECONDS             EQU clock_timer_seconds             ; Timer BCD seconds value
PANEL_SCORE_UPDATE_VALUE        EQU Player_Score_Update_Value       ; player score update value
PANEL_SCORE_DISPLAY_VALUE       EQU Player_Score_Display_Value      ; player score copy BCD value used for display
PANEL_ENERGY_VALUE              EQU player_remaining_energy         ; player energy value (40 max value)
PANEL_HIT_DAMAGE                EQU player_hit_damage               ; player hit damge (subtracted from player energy on each panel update)
; Panel Constants - resources
PANEL_GFX                       EQU panel_gfx                                                   ; main bottom display panel gfx
PANEL_BATMAN_GFX                EQU batman_energy_gfx                                           ; batman energy image
PANEL_JOKER_GFX                 EQU joker_energy_gfx                                            ; joker energy image
PANEL_SCORE_GFX                 EQU score_digits                                                ; score digits gfx
PANEL_LIVES_ON_GFX              EQU batman_lives_icon_on_mask                                   ; batman symbol - lives icon 'on'
PANEL_LIVES_OFF_GFX             EQU batman_lives_icon_off_mask                                  ; batman symbol - lives icon 'off'
                ENDC



PANEL_DISPLAY_PIXELWIDTH        EQU $140                                                        ; 320 pixels wide
PANEL_DISPLAY_BYTEWIDTH         EQU PANEL_DISPLAY_PIXELWIDTH/8;                                 ; 40 bytes wide
PANEL_DISPLAY_LINEHEIGHT        EQU $30                                                         ; 48 Raster Lines High
PANEL_DISPLAY_BITPLANEBYTES     EQU PANEL_DISPLAY_BYTEWIDTH*PANEL_DISPLAY_LINEHEIGHT            ; 1920 bytes per bitplane
PANEL_DISPLAY_BITPLANEDEPTH     EQU $4                                                          ; 4 bitplanes - 16 colours
PANEL_DISPLAY_BYTESIZE          EQU PANEL_DISPLAY_BITPLANEBYTES*PANEL_DISPLAY_BITPLANEDEPTH
; Panel Status1 Bit Numbers
PANEL_ST1_TIMER_EXPIRED         EQU $0                                                          ; panel status 1 - bit 0 - Timer Expired
PANEL_ST1_NO_LIVES_LEFT         EQU $1                                                          ; panel status 1 - bit 1 - No Lives Remaining
PANEL_ST1_LIFE_LOST             EQU $2                                                          ; panel status 1 - bit 2 - Player Life Lost
; Panel Status1 Bit Values
PANEL_ST1_VAL_TIMER_EXPIRED     EQU 2^PANEL_ST1_TIMER_EXPIRED                                   ; panel status 1 - bit value/mask for Timer Expired
PANEL_ST2_VAL_NO_LIVES_LEFT     EQU 2^PANEL_ST1_NO_LIVES_LEFT                                   ; panel status 1 - bit value/mask for No Lives Left 
PANEL_ST2_VAL_LIFE_LOST         EQU 2^PANEL_ST1_LIFE_LOST                                       ; panel status 1 - bit value/mask for Life Lost 
; Panel_Status2 Bit Numbers
PANEL_ST2_MUSIC_SFX             EQU $0                                                          ; panel status 2 - bit 0 - Music/SFX selector bit
PANEL_ST2_GAME_OVER             EQU $5                                                          ; panel status 2 - bit 5 - Is Game Over
PANEL_ST2_LEVEL_COMPLETE        EQU $6                                                          ; panel status 2 - bit 6 - Is Level Complete
PANEL_ST2_CHEAT_ACTIVE          EQU $7                                                          ; panel status 2 - bit 7 - Is Cheat Active





                ;--------------------- includes and constants ---------------------------
                INCDIR      "include"
                INCLUDE     "hw.i"

           
                ; original load address $7C7FC-$80000
                ; The original program has a longword with the main enrty point
                ; address specified as the value.
panel_start
                dc.l    $0007C800                               ; entry point address




                ;----------------------- PANEL UPDATE - $0007c800 -----------------------
                ; This routine is called every frame (50hz) as a main panel update for
                ; each game loop cycle.
                ; 
                ; Somehow this gets called more frequently on my 'cracked' version of the 
                ; game after completion of level 1, Not sure why/how yet, as it seems to 
                ; be tied to the level 3 interrupt handlers called for ever vbl.
                ; Something else seems to be adding extra calls to this make make the 
                ; timer run down slightly quicker in the cracked version.
                ;
Panel_Update                                                        ; $0007c800 called every frame by game code level 3 VBL interrupt
                movem.l d0-d7/a0-a2,-(a7)                           ; original routine address $0007c800
                bsr.w   do_panel_update                             ; calls $0007fc98
                movem.l (a7)+,d0-d7/a0-a2
                rts



                ;----------------------- INITIALISE LEVEL TIMER - $0007c80e -----------------------
                ; initialise the level timer to the value set in d0.w, pause the timer by clearing
                ; the update value.
                ; 
                ; IN: D0.w - Game Level Timer Value (BCD Minutes:Seconds)
                ;           - high byte = BCD minutes
                ;           - low byte  = BCD seconds
                ;
Initialise_Level_Timer      
                movem.l d0-d7/a0-a2,-(a7)                           ; original routine address $0007c80e
                bsr.w   do_initialise_level_timer                   ; calls $0007fc78
                movem.l (a7)+,d0-d7/a0-a2
                rts  




                ;----------------- INITIALISE PLAYER SCORE - $0007c81c ------------------
                ; Initialise the Player's Score, and display initial score value.
                ;
                ; $0007c87c = $00000000 -> Player_Score
                ; $0007c886 = $00000000 -> Player_Score_Update_Value
                ; $0007c88a = $ffffffff
                ;
                ; plots lower 3 bytes (6 digits stored in location) 
                ;   - $0007c879
                ;   - $0007c87a
                ;   - $0007c87b
                ;
Initialise_Player_Score                                                       
                movem.l d0-d7/a0-a2,-(a7)                           ; original routine address $0007c81c
                bsr.w   do_init_player_score                        ; calls $0007fb40
                movem.l (a7)+,d0-d7/a0-a2
                rts



                ;------------------- UPDATE PLAYER SCORE - $007c82a -------------------
                ; Update the player's score, do extra life at every 100,000 points.
                ;
                ; IN: d0.l  - BCD encoded value to add to the score by.
                ;
Update_Player_Score      
                movem.l d0-d7/a0-a2,-(a7)                           ; original routine address $007c82a
                bsr.w   do_update_player_score                      ; calls $0007fb7e
                movem.l (a7)+,d0-d7/a0-a2
                rts  



                ;------------------ INITIALISE PLAYER LIVES - $0007c838 -------------------
                ; sets player lives to 2 and update the player lives icons on the panel.
Initialise_Player_Lives 
                movem.l d0-d7/a0-a2,-(a7)                           ; original routine address $0007c838 
                bsr.w   do_initialise_player_lives                  ; calls $0007f978
                movem.l (a7)+,d0-d7/a0-a2
                rts 



                ;----------------------- ADD EXTRA LIFE - $0007f95a -----------------------
                ; adds extra life to player lives count and updates the display panel.
Add_Extra_Life                                        
                movem.l d0-d7/a0-a2,-(a7)                           ; original routine address $0007c846
                bsr.w   do_add_extra_life                           ; calls $0007f95a
                movem.l (a7)+,d0-d7/a0-a2
                rts



                ;------------------ INTIALISE PLAYER ENERGY - $0007c854 ------------------
                ; reset the player's energy to 'full' and restore the bitplane ptrs
                ; and panel display graphics for the energy meter
Initialise_Player_Energy       
                movem.l d0-d7/a0-a2,-(a7)                           ; original routine address $0007c854
                bsr.w   do_initialise_player_energy                 ; calls $0007fa00
                movem.l (a7)+,d0-d7/a0-a2
                rts



                ;----------------------- LOSE A LIFE - $0007c862 -------------------------
                ; reduce player lives, reset vars and check no lioves remaining.
Lose_a_Life                                                         ; original routine address $0007c862       
                movem.l d0-d7/a0-a2,-(a7)                           ; original routine address $0007c862
                bsr.w   do_lose_a_life                              ; calls $0007fb00
                movem.l (a7)+,d0-d7/a0-a2
                rts



                ;----------------------- ADD HIT DAMAGE - $0007c870 -------------------------
                ; Add hit damage to the player, to be subtracted from their energy value.
                ; IN: D0.w - hit damage to add to player
Add_Hit_Damage       
                bra.w do_add_hit_damage                             ; calls $0007fa66 ; original routine address $0007c870





                ;----------------------- DATA/STATUS VALUES -----------------------
                ; various variables for keeping state of panel status:-
                ;   1) Player Lives
                ;   2) Player Energy Levels (including hit damage)
                ;   3) Clock Timer (Minutes:Seconds)
                ;   4) Frame Tick Counter
                ;   5) Status Bytes 1 & 2  (bit array of flags)
                ;
CLOCK_TIMER_EXPIRED     equ     0
NO_LIVES_REMAINING      equ     1
PLAYER_LIFE_LOST        equ     2
INFINITE_LIVES          equ     7
                even
panel_status_1                              ; original address $0007c874
                dc.b    $00                 ; status byte 1 (bits 0-clock timer expired, 1-no lives left, bit 2-life lost)
panel_status_2                              ; original address $0007c875
                dc.b    $00                 ; status byte 2 (bits 7 used for test if set - infinite lives?)
                                            ; bit 0 = music/sound fx. (0 = music, 1 = sfx)
                even
player_lives_count                          ; original address $0007c876
                dc.w    $0000               ; possible lives counter

High_Score
                dc.l    $00000000           ; High Score Value value, $0007c878

Player_Score
                dc.l    $00000000           ; Player Score Value $0007c87c (BCD 6 digits, first byte unused 000,000)

frame_tick                                  ; original address $0007c880
                dc.w    $0000               ; vbl ticker, ticks every frame from 50 to 0 (1 second at 50hz)

clock_timer_update_value                    ; original address $0007c882
                dc.w    $0000               ; BCD value subtracted from clock_timer when frame_tick = 0

                even
clock_timer
clock_timer_minutes
                dc.b    $00                 ; Clock Timer Minutes value, held in BCD Format, original address = $0007c884
clock_timer_seconds
                dc.b    $00                 ; Clock Timer Seconds Value, held in BCD Format, original address $0007c885

                even
Player_Score_Update_Value
                dc.l    $00000000           ; original address $0007c886

Player_Score_Display_Value
                dc.l    $ffffffff           ; copy of player score for display, original address $0007c88a

player_remaining_energy                     ; original address $0007c88e
                dc.w    $0000               ; player's remaining energy level, max/full level = #$28 (40)

player_hit_damage                           ; original address $0007C890
                dc.w    $0000               ; counter (count down, clamped at 0, possible energy hit/damage value)

joker_energy_gfx_ptr                        
                dc.l    $00000000           ; source ptr to the joker energy graphics, original address $0007c896

player_energy_display_location_ptr
                dc.l    $00000000           ; dest ptr to the panel display where the player energy meter is located, original address $0007C892




                ;---------------------- PANEL GRAPHICS -----------------------
                ; 40 bytes wide (320 pixels)
                ; 48 lines high 
                ; 1920 bytes per bitplane x 4 = 7680 bytes
                ;
                include ./gfx/panel_gfx.s         ; original address $0007c89a


                ;--------------------- BATMAN ENERGY GFX ---------------------
                ; batman image of energy display 64 x 41 pixels in size
                ; 64x41 pixels, 4 bitplanes. 1312 Bytes
                ;
                include ./gfx/batman_energy_gfx.s ; original address $0007E69A


                ;--------------------- JOKER ENERGY GFX ----------------------
                ; joker image of energy display 64 x 41 pixels in size
                ; 64x41 pixels, 4 bitplanes. 1312 Bytes
                include ./gfx/joker_energy_gfx.s  ; original address $0007EBBA


                ;--------------------- SCORE DIGITS GFX ----------------------
                ; 16 x 7 pixels, 4 bitplanes, 10 characters
                ; 560 bytes
                include ./gfx/score_digits_gfx.s  ; original address $0007F0DA


                ;--------------------- TIMER DIGITS GFX ----------------------
                ; 16 x 11 pixels, 4 bitplanes, 12 characters (including separators)
                ; 1056 bytes
                include ./gfx/timer_digits_gfx.s  ; original address $0007F30A


                ;----------------- BATMAN LIVES ON ICON GFX ------------------
                ; mask: 32 x 13 = 56 bytes
                ; image: 32 x 13, 4 bitplanes = 208 bytes
                include ./gfx/batman_lives_icon_on.s  ; original address $0007f734


                ;----------------- BATMAN LIVES OFF ICON GFX -----------------
                ; mask: 32 x 13 = 56 bytes
                ; image: 32 x 13, 4 bitplanes = 208 bytes
                include ./gfx/batman_lives_icon_off.s ; original address $0007f838






                ;---------------- do add extra life ----------------
                ; called from main api entry point at address $0007f95a
                ; also called from routine as address $0007fbbc
                ; Adds an extra player life & update the panel display.
                ;
                ; called from
                ;   Add_Extra_Life  - main api
                ;   in progress
                ;
do_add_extra_life                                                   ; original routine address - $0007f95a
                lea.l   batman_lives_icon_on,a0                     ; icon display address.                             - $0007f95a
                move.w  player_lives_count,d0                       ; d0 = player lives count (icon index)              - $0007f960
                add.w   #$0001,player_lives_count                   ; increment player lives count                      - $0007f966
                cmp.w   #$0003,d0                                   ; update display if lives <= 3                      - $0007f96e
                blt.w   display_batman_icon                         ; jmp $0007f9ac                                     - $0007f972
                rts




                ;----------- do initialise player lives -----------
                ; called from main api entry point to initialise
                ; player lives to 2 and update panel display.
                ;
                ; called from
                ;   Initialise_Player_Lives     - main api
                ;
do_initialise_player_lives                                          ; original routine address $0007f978
                move.w  #$0002,player_lives_count                   ; set player lives count = 2
                clr.b   panel_status_1                              ; clear panel status byte 1                 - 0007f980
                moveq   #$00,d0                                     ; D0 = icon index
                lea.l   batman_lives_icon_on,a0                     ; A0 = icon display address
                bsr.w   display_batman_icon                         ; calls $0007f9ac
                moveq   #$01,d0                                     ; D0 = icon index
                lea.l   batman_lives_icon_on,a0                     ; A0 = icon display address
                bsr.w   display_batman_icon                         ; calls $0007f9ac
                moveq   #$02,d0                                     ; D0 = icon index
                lea.l   batman_lives_icon_off,a0                    ; Display 'unlit' lives icon (posiiton 3), original icon address $0007f86c
                bsr.w   display_batman_icon                         ; calls $0007f9ac
                rts



                ;------------------------------------------------------------
                ; update player lives display/icon?
                ; IN: d0 = lives image to update (0 - 2) desintation index
                ; IN: a0 = source gfx address (mask must be 52 bytes before this address)
                ;
                ; panel gfx = 320 x 48 pixels (1920 bytes per bitplane)
                ; batman symbol = 32 x 13 pixels (52 bytes per bitplane)
                ;
                ; called from:
                ;   do_lose_a_life
                ;   do_add_extra_life
                ;   do_intiialise_player_lives
                ;
display_batman_icon                                                 ; orignal routine address $0007f9ac
                asl.w   #$02,d0                                     ; d0 = d0 * 4 (source image index)
                movea.l a0,a2                                       ; a0,a2 = copy source gfx ptr
                suba.l  #$00000034,a2                               ; a2 = subtract 52 from ptr = gfx mask start address (52 bytes before gfx data)
                lea.l   panel_gfx+((40*10)+26),a1                   ; a1 = desintaion address = $0007ca44 (1st batman lives icon)
                adda.w  d0,a1                                       ; a1 = destination address + offset to area to update (lives icon)
                move.w  #$000c,d0                                   ; d0 = 12 + 1 - loop counter 
.display_loop   move.l  (a2),d1                                     ; d1 = 32 bit mask value
                not.l   d1                                          ; d1 = invert bits
                and.l   d1,(a1)                                     ; mask d1.l with contents of      a1 = $7CA44 (start)
                and.l   d1,$0780(a1)                                ; mask d1.l with contents of a1+1920 = $7D1C4 (start)
                and.l   d1,$0f00(a1)                                ; mask d1.l with contents of a1+3840 = $7D944 (start)
                and.l   d1,$1680(a1)                                ; mask d1.l with contents of a1+5769 = $7E0C4 (start) 
                move.l  (a0),d2                                     ; d2 = 32 bits source gfx
                or.l    d2,(a1)                                     ; add source gfx to dest address (bitplane 1)
                move.l  $0034(a0),d2                                ; d2 = 32 bit source gfx (52 byte offset) (52/4 = 13 - 32 pixels wide x 13 pixels high )
                or.l    d2,$0780(a1)                                ; add source gfx to dest address (bitplane 2)
                move.l  $0068(a0),d2                                ; d2 = 32 bit source gfx (104 byte offset)
                or.l    d2,$0f00(a1)                                ; add source gfx to dest address (bitplane 3)
                move.l  $009c(a0),d2                                ; d2 = 32 bit source gfx (156 byte offset)
                or.l    d2,$1680(a1)                                ; add source gfx to dest address (biitplane 4)
                adda.l  #$00000028,a1                               ; a1 = add 40 bytes to destination address (next scanline bitplane 1)
                addq.l  #$04,a2                                     ; a2 = increase mask ptr
                addq.l  #$04,a0                                     ; a0 = increase source gfx ptr
                dbf.w   d0,.display_loop                            ; loop next display line
                rts




                ;---------------- DO INTIALISE PLAYER ENERGY - $0007fa00 ------------------
                ; called from the main api call at address $0007c854
                ; reset the player's energy to 'full' and restore the bitplane ptrs
                ; and panel display graphics for the energy meter
do_initialise_player_energy                                         ; original address $0007fa00
                move.w  #$0028,d0                                   ; D0 = 40 + 1 - loop counter (initial energy value)
                move.w  d0,player_remaining_energy                  ; set player remaining energy level as address $0007c88e
                clr.w   player_hit_damage                           ; L0007C890
                lea.l   batman_energy_gfx,a0                        ; batman energy meter source gfx address
                lea.l   panel_gfx+((40*4)+16),a1                   ; destination bitplanes for player energy display (batman/joker energy meter)
                move.l  a1,player_energy_display_location_ptr       ; store ptr to the energy meter location in the panel display.
.copy_loop      move.l  (a0),(a1)                                   ; bitplane 1 - copy 32bits gfx source to dest
                move.l  $0004(a0),$0004(a1)                         ; bitplane 1 - copy 32bits gfx source to dest
                move.l  $0148(a0),$0780(a1)                         ; bitplane 2 - copy 32bits gfx source to dest
                move.l  $014c(a0),$0784(a1)                         ; bitplane 2 - copy 32bits gfx source to dest
                move.l  $0290(a0),$0f00(a1)                         ; bitplane 3 - copy 32bits gfx source to dest
                move.l  $0294(a0),$0f04(a1)                         ; bitplane 4 - copy 32bits gfx source to dest
                move.l  $03d8(a0),$1680(a1)                         ; bitplane 4 - copy 32bits gfx source to dest
                move.l  $03dc(a0),$1684(a1)                         ; bitplane 4 - copy 32bits gfx source to dest
                addq.l  #$08,a0                                     ; increase source ptr by 64 bits
                adda.l  #$00000028,a1                               ; increase dest ptr by 320 pixels (40 bytes)
                dbf.w   d0,.copy_loop                               ; copy next scan line of gfx, jmp $0007fa22
                move.l  #joker_energy_gfx,joker_energy_gfx_ptr      ; initialise joker energy display gfx ptr in address $0007C896
Exit
                rts                                                 ; shared return with 'update_hit_damage'              - $L0007fa64.




                ;--------------------- do add hit damage -----------------------
                ; Add value in d0.w to player hit damage total. 
                ; The hit damage is gradually subtracted from the player energy
                ; during the regular panel_update call.
                ;
                ; called from
                ;   Add_Hit_Damage  - main api
                ;
do_add_hit_damage                                                   ; original routine address $0007fa66

            IFD INFINITE_ENERGY_CHEAT
                rts
            ENDC
.do_hit_damage
                tst.w   player_remaining_energy                     ; test player remaining energy with 0, as address $0007c88e    - 0007fa66
                bne.b   .increase_hit_damage                        ; if player has remaining energy, jmp $0007fa76                - 0007fa6c
                clr.w   player_hit_damage                           ; clear 16b its as address $0007C890                           - 0007fa6e
                rts                                                 ; return                                                       - 0007fa74

.increase_hit_damage
                add.w   d0,player_hit_damage                        ; add to player hit/damage as address $0007C890                - 0007fa76
.exit           rts                                                 ; return                                                       - 0007fa7c





                ;------------------- update hit damage -------------------
                ; called every frame from panel_update L0007fc98
                ; it looks like this routine is updating the player's
                ; energy from a hit/damage value stored in $0007C890 'player_hit_damage'
                ; The damage is decremented from the player's energy
                ; every frame, to give the smooth energy loss appearance
                ; over a number of display frames.
                ; The Player's total remaining life energy is stored in $0007C88E 'player_remaining_energy'
                ;
update_hit_damage                                                   ; original routine address $0007fa7e 
                move.w  player_hit_damage,d0                        ; d0 = stored word value at address $0007C890           - 0007fa7e
                bpl.w   .check_is_0                                 ; if D0 >= 0 jmp L0007fa90,                             - 0007fa84
.clamp_value_to_0
                clr.w   player_hit_damage                           ; set player hit/damage to 0 at address $0007C890,      - 0007fa88
                moveq   #$00,d0                                     ; d0.l = 0,                                             - 0007fa8e
.check_is_0
                beq.b   Exit                                        ; if d0 = 0, then exit (jmp L0007fa64),                 - 0007fa90
.decrement_value
                sub.w   #$0001,player_hit_damage                    ; reduce player hit/damage as address $0007C890         - 0007fa92


                ; copy bitplane graphics (32 pixels wide)
                ; update the batman energy display (one scanline)
                movea.l joker_energy_gfx_ptr,a0                     ; a0 = ptr to joker energy graphics                     - 0007fa9a
                movea.l player_energy_display_location_ptr,a1       ; a1 = dest ptr panel energy meter display,             - 0007faa0
                move.l  (a0),(a1)                                   ; copy 4 bytes source to dest,                          - 0007faa6
                move.l  $0004(a0),$0004(a1)                         ; copy 4 bytes source+4 to dest + 4                     - 0007faa8
                move.l  $0148(a0),$0780(a1)                         ; copy 4 bytes source+328 to dest+328                   - 0007faae
                move.l  $014c(a0),$0784(a1)                         ; copy 4 bytes source+332 to desc+332                   - 0007fab4
                move.l  $0290(a0),$0f00(a1)                         ; copy 4 bytes source+656 to desc+656                   - 0007faba
                move.l  $0294(a0),$0f04(a1)                         ; copy 4 bytes source+660 to dest+660                   - 0007fac0
                move.l  $03d8(a0),$1680(a1)                         ; copy 4 bytes source+984 to dest+984                   - 0007fac6
                move.l  $03dc(a0),$1684(a1)                         ; copy 4 bytes source+988 to dest+988                   - 0007facc
                addq.l  #$08,a0                                     ; increment source by 8 bytes                           - 0007fad2
                adda.l  #$00000028,a1                               ; increment dest by 40 bytes (320 pixel width)          - 0007fad4

                move.l  a0,joker_energy_gfx_ptr                     ; store updated ptr to joker energy graphics            - 0007fada
                move.l  a1,player_energy_display_location_ptr       ; store updated dest ptr to panel energy meter          - 0007fae0

                sub.w   #$0001,player_remaining_energy              ; subtract 1 from total energy at $0007c88e             - 0007fae6
                bne.w   Exit                                        ; not equal to 0 then exit (jmp L0007fa64)              - 0007faee
                bra.w   do_lose_a_life                              ; is equal to 0 then jmp L0007fb00                      - 0007faf2





                ; player has not lives left
set_no_lives_left
                bset.b  #NO_LIVES_REMAINING,panel_status_1          ; set bit 1 of status byte 1,               L0007faf6
                rts                                                 ; exit                                      007fafe

                ;---------------------- DO LOSE A LIFE - $0007fb00 ---------------------
                ; player lost a life, reset variables, check no lives left.
                ; sets status bits in 'panel_status_1' 
                ;
                ; called from:
                ;   - Lose_a_Life       - main api
                ;   - update_hit_damage -
                ;
do_lose_a_life                                                      ; original routine address $0007fb00
                clr.w   player_hit_damage                           ; clear 'energy hit/damage' counter as address $0007C890        - 0007fb00
                tst.w   player_lives_count                          ; test player lives count                                       - 0007fb06
                beq.b   set_no_lives_left                           ; lives = 0, jmp $0007faf6                                      - 0007fb0c 
.set_status
                bset.b  #PLAYER_LIFE_LOST,panel_status_1            ; set bit 2 of status byte 1,                                   - 0007fb0e
                btst.b  #INFINITE_LIVES,panel_status_2              ; test bit 7 of status byte 2,                                  - 0007fb16
                bne.b   .exit_do_lose_life                          ; if bit 7 = 1, jmp $0007fb3e                                   - 0007fb1e
.reduce_player_count
                subq.w  #$01,player_lives_count                     ; decrement player lives count                                  - 0007fb20
                move.w  player_lives_count,d0                       ; d0 = player lives count                                       - 0007fb26
.chk_update_display
                cmp.w   #$0002,d0                                   ; test lives remaining                                          - 0007fb2c
                bgt.w   .exit_do_lose_life                          ; if > 2 lives left then do not update display, jmp L0007fb3e   - 0007fb30
.update_display
                lea.l   batman_lives_icon_off,a0                    ; a0 = source gfx orignal address $0007f86c                     - 0007fb34
                bra.w   display_batman_icon                         ; d0 = icon to update, a0 = source gfx, jmp $0007f9ac           - 0007fb3a
.exit_do_lose_life
                rts                                                 ; L0007fb3e





                ;---------------------- do init player score - $0007fb40 ---------------------
                ;
                ; Player_Score = $0007c878
                ;
                ;   calls do_debug_plot (d0.l = $0)
                ;
do_init_player_score                                                ; original routine address $0007fb40
                clr.l   Player_Score                                ; fill longword with $00000000
                move.l  #$ffffffff,Player_Score_Display_Value       ; fill longword with $ffffffff
                moveq   #$00,d0                                     ; d0.l = $0
                move.b  High_Score+1,d0                             ; d0.b = byte value, $0007c879
                move.w  #$080e,d1                                   ; d1.w = X,Y (08,0e)
                bsr.w   plot_digits                                 ; calls $0007fd66 (d0 = chars, d1 = x,y)
                move.b  High_Score+2,d0
                move.w  #$0a0e,d1
                bsr.w   plot_digits                                 ; calls $0007fd66
                move.b  High_Score+3,d0
                move.w  #$0c0e,d1
                bsr.w   plot_digits                                 ; cllas $0007fd66
                moveq   #$00,d0




                ;---------------------- do update player score - $0007fb7e ---------------------
                ; Add update value to the player's score, check for extra life on every 100,000.
                ;
                ; IN: D0.l = value to plot
                ;
do_update_player_score                                              ; original routine address $0007fb7e
                move.l  d0,Player_Score_Update_Value                ; store update value in $7c886
                lea.l   Player_Score_Update_Value+4,a0              ; value initialised to $ffffffff above (-1)
                lea.l   Player_Score+4,a1                           ; a1 = Player Score Value
                and.l   #$000000ff,d0                               ; d0 = clamp to 0-255
.update_score
                movem.l d0-d1,-(a7)                                 ; Save Registers in Use
                move.b  Player_Score+1,d0                           ; d0 = hi 2 digits of player score.
                and.b   #$f0,d0                                     ; d0 = score's most significant digit (mask second digit)
                move    #$00,ccr
;L0007fba4       move.b #$00,ccr
                abcd.b  -(a0),-(a1)                                 ; Add Update Value to Player Score (BCD)
                abcd.b  -(a0),-(a1)                                 ; Add Update Value to Player Score (BCD)
                abcd.b  -(a0),-(a1)                                 ; Add Update Value to Player Score (BCD)

                move.b  Player_Score+1,d1                           ; d1 = hi 2 digits of player score
                and.b   #$f0,d1                                     ; d1 = score's most significant digit (mask second digit)
                cmp.b   d0,d1                                       ; d0 = MSD of score (before add), d1 = MSD of score (after add)
                beq.b   .skip_extra_life
                bsr.w   do_add_extra_life                           ; ticked over 100,000 points, calls $0007f95a
.skip_extra_life    ; L0007fbc0
                movem.l (a7)+,d0-d1                                 ; Restore Registers used above.

                ; display player score (also keep copy in $7C88A)
.display_score_hi
                move.b  Player_Score+3,d0
                cmp.b   Player_Score_Display_Value+3,d0
                beq.b   .display_score_mid
                move.b  d0,Player_Score_Display_Value+3             ; d0 = 2 digits for display
                move.w  #$0c1e,d1                                   ; d1 = x,y
                bsr.w   plot_digits                                 ; calls $0007fd66, d1=x,y, d0 = chars

.display_score_mid ; L0007fbe0
                move.b  Player_Score+2,d0
                cmp.b   Player_Score_Display_Value+2,d0
                beq.b   .display_score_lo 
                move.b  d0,Player_Score_Display_Value+2
                move.w  #$0a1e,d1
                bsr.w   plot_digits                                 ; calls $0007fd66, d1=x,y, d0 = chars

.display_score_lo   ; L0007fbfc
                move.b  Player_Score+1,d0
                cmp.b   Player_Score_Display_Value+1,d0
                beq.b   .chk_high_score
                move.b  d0,Player_Score_Display_Value+1
                move.w  #$081e,d1
                bsr.w   plot_digits                                 ; calls $0007fd66, d1=x,y, d0 = chars

.chk_high_score ; L0007fc18
                move.l  High_Score,d0
                cmp.l   Player_Score,d0
                bhi.w   .exit_update_player_score                   ; player score is not the high score

.plot_score_hi  ; L0007fc28                                                    ; plot highest 2 score digits
                moveq   #$00,d0
                move.b  Player_Score+3,d0
                cmp.b   High_Score+3,d0
                beq.b   .plot_score_mid
                move.w  #$0c0e,d1                                   ; d1.w = x,y
                bsr.w   plot_digits                                 ; calls $0007fd66, d1=x,y, d0=chars

.plot_score_mid     ; L0007fc40                                      ; plot middle 2 score digits
                move.b  Player_Score+2,d0
                cmp.b   High_Score+2,d0
                beq.b   .plot_score_lo 
                move.w  #$0a0e,d1
                bsr.w   plot_digits                                 ; calls $0007fd66, d1=x,y, d0=chars

.plot_score_lo  ; L0007fc56                                                     ; plot lowest 2 score digits
                move.b  Player_Score+1,d0
                cmp.b   High_Score+1,d0
                beq.b   .store_high_score
                move.w  #$080e,d1
                bsr.w   plot_digits                                 ; calls $0007fd66, d1=x,y, d0=chars

.store_high_score  ; L0007fc6c
                move.l Player_Score,High_Score

.exit_update_player_score ; L0007fc76
                rts




                ; reset frame_tick to 50
                ; clear level timer update value (assume pauses the level timer)
                ; clear panel_status_1 bit field (timer_expired,lost_life,game_over) flags
                ;
                ; IN: D0.w = value to set clock timer (BCD Minutes:Seconds)
                ;
do_initialise_level_timer                                           ; original routin address $0007fc78
L0007fc78       move.w  d0,clock_timer                              ; d0 = clock timer value (minutes and seconds) in BCD format $0007c884                 ; L0007fc78
                move.w  #$0032,frame_tick                           ; set frame_tick to 50, $0007c880       - 0007fc7e
                bsr.w   display_level_timer                         ; calls $0007fd28                       - 0007fc86
                clr.w   clock_timer_update_value                    ; pause the level timer                 - 0007fc8a
                clr.b   panel_status_1                              ; clear panel status byte 1             - 0007fc90
                rts                                                 ; return                                - 0007fc96





                ;--------------------- update panel --------------------------
                ; called every frame from $7c800 update_panel
                ; house keeping of the panel display, also setting status
                ; flags for lost_life, timer_expired, no_lives_remaining
                ;
do_panel_update                                                     ; original routine address
                bsr.w   update_hit_damage                           ; calls L0007fa7e,update energy loss / lives        - 0007fc98

                cmp.w   #$9999,clock_timer_update_value             ; test value in 0007c882.w                          - 0007fc9c
                beq.w   .exit_do_panel_update                       ; if = #$9999 then exit, jmp $7fd1a                 - 0007fca4

                sub.w   #$0001,frame_tick                           ; subtract 1 from frame tick $0007c880              `- 0007fca8
                bpl.w   .display_clock_timer_separator              ; if (tick > 0) jmp 0007fcf6                        - 0007fcb0

.reset_frame_tick                                                   ; else
                move.w  #$0032,frame_tick                           ; set tick to 50 $0007c880

                tst.w   clock_timer                                 ; test clock timer = 0 (minutes and seconds) $0007c884
                beq.w   .clock_timer_expired                        ; if clock_timer = 0, jmp $0007fd1c

                lea.l   clock_timer_update_value+2,a0               ; clock timer update value address
                lea.l   clock_timer+2,a1                            ; clock timer end address $0007c886
                move    #$10,ccr
;L0007fcd2      move.b  #$10,ccr
                sbcd.b  -(a0),-(a1)                                 ; subtract BCD byte from word before timer from clock seconds
                sbcd.b  -(a0),-(a1)                                 ; subtract BCD byte from word before time from clock minutes

.check_minutes_decremented
                move.b  clock_timer_seconds,d0                      ; d0 = timer seconds value $0007c885
                and.b   #$f0,d0                                     ; d0 = mask least significant seconds digit
                cmp.b   #$90,d0                                     ; if seconds value starts with '9' then minutes were decremented
                bne.b   .display_clock_timer_value                  ; else continue to display clock_timer value $0007fcf2
.minutes_decremented
                move.b  #$59,clock_timer_seconds                    ; set seconds from '99' to '59' for correct seconds value as BCD $7c885

.display_clock_timer_value
                bsr.w   display_level_timer                         ; calls $0007fd28

.display_clock_timer_separator
                move.w  #$000a,d0                                   ; d0 = timer separator 1 - table offset
                cmp.w   #$0019,frame_tick                           ; compare frame tick to #$19 (25) $0007c880
                beq.b   .display_timer_seperator                    ; on half second frame_tick - L0007fd12
                cmp.w   #$0032,frame_tick                           ; compare frame tick to #$32 (50) $0007c880
                bne.b   .exit_do_panel_update                       ; jump exit, $0007fd1a
                move.w  #$000b,d0                                   ; d0 = timer separator 2 - table offset
                                                                    ; on full second frame_tick 
.display_timer_seperator
                move.w  #$1d19,d1                                   ; d1 = x,y co-oords for display
                bsr.w   display_timer_digit                         ;display the separator character - calls $0007fde2
.exit_do_panel_update
                rts                                                 ; return

.clock_timer_expired                                                ; original routine address $0007fd1c
                bset.b  #CLOCK_TIMER_EXPIRED,panel_status_1         ; set bit 0 of status byte 1 (clock timer expired = 00:00)
                bra.w   .display_clock_timer_separator              ; L0007fcf6






                ;-------------------------- Display Level Timer --------------------------
                ; Displays 'minutes:seconds' (00:00) timer digits on the panel display.     
                ; uses:
                ; - d0  - lower 4 bts = BCD digit to display (0 - 9)
                ;
                ; - d1  - X,Y co-oord
                ;       - x = (8-15) byte, offset from the left
                ;       - y = (0-7)  byte, lines from top of display (320 wide assumed))
                ;
                ; - calls display_timer_digit - $0007c885
                ;       - display each timer digit in-turn
                ;
                ; called by:
                ;   - do_panel_update
                ;   - do_initialise_level_timer
                ;
display_level_timer                                                 ; original routine address $0007fd28
                moveq   #$00,d0                                     ; d0.l = 0 - holds BCD digit to disply
.disply_1st     move.b  clock_timer_seconds,d0                      ; d0.b = clock timer seconds in BCD from location $0007c885
                move.w  #$1f19,d1                                   ; d1.w = #$1f19 (x = 31, y = 25 - display co-ords)
                bsr.w   display_timer_digit                         ; Display the digit in lower 4 bits of d0, calls $0007fde2
.display_2nd    move.b  clock_timer_seconds,d0                      ; d0.b = clock timer seconds in BCD from location $0007c885
                lsr.b   #$04,d0                                     ; shift 2nd digit into low 4 bits for display
                move.w  #$1e19,d1                                   ; d1.w = #$1e19 (x = 30, y = 25 - display co-ords)
                bsr.w   display_timer_digit                         ; Display the digit in lower 4 bits of d0, calls $0007fde2
.display_3rd    move.b  clock_timer_minutes,d0                      ; d0.b = clock timer minutes in BCD from location $0007c885
                move.w  #$1c19,d1                                   ; d1.w = #$1c19 (x = 28, y = 25 - display co-ords)
                bsr.w   display_timer_digit                         ; Display the digit in lower 4 bits of d0, calls $0007fde2
.display_4th    move.b  clock_timer_minutes,d0                      ; d0.b = clock timer minutes in BCD from location $0007c885
                lsr.b   #$04,d0                                     ; shift 2nd digit into low 4 bits for display
                move.w  #$1b19,d1                                   ; d1.w = #$1b19 (x = 27, y = 25 - display co-ords)
                bra.w   display_timer_digit                         ; Display the digit in lower 4 bits of d0, calls $0007fde2
                ; uses rts in last call to return





                ;------------------------ plot digits -----------------------
                ; Plots score digits (2 digits at a time). Digits are passed
                ; in as BCD encoded digits in d0.w.
                ;
                ; plots a 8x7 pixel character into 4 bitplanes into a 
                ; location inside the panel_gfx
                ;
                ; IN: d0.w  - 2 BCD Characters to write
                ; IN: d1.w  - x,y characters as high/low bytes in word.
                ; 
plot_digits                                                         ; original routine address 0007fd66
                bsr.w   draw_digit                                  ; display first character, call $0007fd70
.display_2nd_digit
                lsr.b   #$04,d0                                     ; d0 = second bcd digit.
                sub.w   #$0100,d1                                   ; d1 = updated x co-ordinate
                ; fall through to display the second character




                ;------------------------ draw char -------------------------
                ; IN: d0.b  - low 4 bits = BCD Characters to write (digits)
                ; IN: d1.w  - X,Y plot co-ords (x = bytes offset, y = line count)
                ;
                ; NB: Source GFX address doesnot make sense, which is why this
                ;       is probably a debug routine, not in use by the game (TBD)
                ;
draw_digit                                                          ; original routine address $0007fd70
                movem.l d0-d1,-(a7)
                moveq   #$00,d2                                     ; d2.l = $0
                move.b  d1,d2                                       ; d2 = y (scan line offset)
                lsr.w   #$08,d1                                     ; d1 = x (byte offset)
                mulu.w  #$0028,d2                                   ; multiply y * 40 (320 pixels), d2 = scan line value
                add.l   #panel_gfx,d2                               ; d2 = start scan line into panel_gfx,         panel_gfx = $0007c89a
                add.b   d1,d2                                       ; d2 = add byte offset into scan line
                movea.l d2,a0                                       ; a0 = destination address.

                and.b   #$0f,d0                                     ; d0 = low 4 bits bcd character
                bne.b   .not_zero
.is_zero
                movea.l #score_digits+(56*9),a1                     ; address of '0' character (at end of 1-9)
                bra.w   .do_plot 
.not_zero
                mulu.w  #$0038,d0                                   ; d0 = d0 * 56 (56 bytes, 28 words) ,28/4 = 7 pixels high
                add.l   #score_digits-56,d0                         ; start of digit gfx - 56 bytes, original address $0007f0a2, gfx starts at '1' instead of '0'
                movea.l d0,a1                                       ; a1 = source gfx ptr of require digit
.do_plot
                moveq   #$03,d2                                     ; 3 + 1 - counter (4 lines of gfx, 4 bitplanes)
.plot_loop
                move.b  (a1),(a0)                                   ; copy src gfx -> dest line 1.
                move.b  $0002(a1),$0028(a0)                         ; copy src gfx -> dest line 2.
                move.b  $0004(a1),$0050(a0)                         ; copy src gfx -> dest line 3.
                move.b  $0006(a1),$0078(a0)                         ; copy src gfx -> dest line 4.
                move.b  $0008(a1),$00a0(a0)                         ; copy src gfx -> dest line 5.
                move.b  $000a(a1),$00c8(a0)                         ; copy src gfx -> dest line 6.
                move.b  $000c(a1),$00f0(a0)                         ; copy src gfx -> dest line 7.
                adda.l  #$00000780,a0                               ; dest next bitplane
                adda.l  #$0000000e,a1                               ; src next bitplane
                dbf.w   d2,.plot_loop                               ; plot loop,
                movem.l (a7)+,d0-d1
                rts




                ;--------------------- display timer digit  --------------------------
                ; The BCD digit to displayis passed in in the lower 4 bits of d0
                ; The co-ords passed in d1
                ;
                ; IN: d0.b = BCD value to display (byte)
                ;            - values 10 & 11 are animation for timer separator ':'
                ;
                ; IN: d1.w = x,y location to display the digits (x = horizontal bytes offest, y = scanline offset)
                ;
                ; called by:
                ;   - display_level_timer   - (display digits 'xx xx')
                ;   - do_panel_update       - (display separator ':')
                ;
display_timer_digit                                                 ; original routine address $0007fde2
                and.l   #$0000ffff,d0                               ; clamp d0.l to a 16bit word
                movem.l d0-d2,-(a7)                                 ; save registers
                moveq   #$00,d2                                     ; d2.l = 0
                move.b  d1,d2                                       ; d2.b = Y offset in bytes
                lsr.w   #$08,d1                                     ; d1.b = X offset in pixels
                mulu.w  #$0028,d2                                   ; d2 = Y offset in bytes (#$28 = 40 bytes per digit)
                add.l   #panel_gfx,d2                               ; panel_gfx address = $0007c89a
                add.w   d1,d2                                       ; d2 = start address in panel to draw the digit
                movea.l d2,a0                                       ; a0 = start address in panel to draw the digit
                and.w   #$000f,d0                                   ; d0 = first digit to draw
                add.w   d0,d0                                       ; d0 = word index to digit gfx
                lea.l   digit_gfx_offset_table,a2                   ; a2 = digit gfx offset lookup tablle
                move.w  (a2,d0),d0                                  ; d0 = digit byte offset into gfx data
                add.l   #timer_digit_gfx,d0                         ; d0 = address of digit to draw
                movea.l d0,a1                                       ; a1 = address of digit to draw
                moveq   #$03,d2                                     ; d2 = 3 + 1 = 4 bitplanes
.bitplane_loop  move.b  (a1),(a0)                                   ; copy gfx data - src to dest - line 0
                move.b  $0002(a1),$0028(a0)                           ; copy gfx data - src to dest - line 1
                move.b  $0004(a1),$0050(a0)                         ; copy gfx data - src to dest - line 2
                move.b  $0006(a1),$0078(a0)                         ; copy gfx data - src to dest - line 3
                move.b  $0008(a1),$00a0(a0)                         ; copy gfx data - src to dest - line 4
                move.b  $000a(a1),$00c8(a0)                         ; copy gfx data - src to dest - line 5
                move.b  $000c(a1),$00f0(a0)                         ; copy gfx data - src to dest - line 6
                move.b  $000e(a1),$0118(a0)                         ; copy gfx data - src to dest - line 7
                move.b  $0010(a1),$0140(a0)                         ; copy gfx data - src to dest - line 8
                move.b  $0012(a1),$0168(a0)                         ; copy gfx data - src to dest - line 9
                move.b  $0014(a1),$0190(a0)                         ; copy gfx data - src to dest - line 10
                adda.l  #$00000780,a0                               ; increment to next bitplane #$780 = 1920 bytes (height = 48 scanlines)
                adda.l  #$00000016,a1                               ; next digit bitplane (16 x 16 pixels )
                dbf.w   d2,.bitplane_loop                           ; do next bitplane, loop to $0007fe1a
                movem.l (a7)+,d0-d2                                 ; restore saved registers
                rts                                                 ; return





                ;-------------------- more data ---------------------
                ; this is a table of byte offsets for the digits
                ; 0-9 into the charset gfx and 2 separators.
            even
digit_gfx_offset_table             ; original address $0007FE6E 
            dc.w    $0370          ; digit 0 - offset 
            dc.w    $0058          ; digit 1 - offset
            dc.w    $00B0          ; digit 2 - offset
            dc.w    $0108          ; digit 3 - offset
            dc.w    $0160          ; digit 4 - offset
            dc.w    $01B8          ; digit 5 - offset
            dc.w    $0210          ; digit 6 - offset
            dc.w    $0268          ; digit 7 - offset
            dc.w    $02C0          ; digit 8 - offset
            dc.w    $0318          ; digit 9 - offset
            dc.w    $0000          ; Timer Separator Animation 1 - offset
            dc.w    $03C8          ; Timer Seperator Animation 2 - offset

