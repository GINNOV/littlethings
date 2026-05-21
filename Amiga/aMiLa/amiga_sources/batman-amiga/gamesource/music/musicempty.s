
                ; Load Address and File Size
                ;   Memory Contents     Stsrt Address   End Address     Byte Size
                ;   --------------------------------------------------------------
                ;       Music           $00068f7c       $0007c60e       $00013692
                ;
                ;
                ; This is music and player routine for Level 2/4 - Batmobile & Batwing
                ;
                ; $00068f80  Initialise Music Player    - Set up Player Samples & Instruments
                ; $00068f84  Silence All Audio          - Stop Playing and Silence Audio
                ; $00068f88  Stop Audio 
                ; $00068f8c  Stop Audio
                ; $00068f90  Init Song                  - Initialise Song to Play (D0 = song number)
                ; $00068f94  Play SFX                   - Initialise & PLay SFX on 4th audio channel (if not already playing or is higher priority of one that is playing) - L0004822c
                ; $00068f98  Play Song                  - Called every VBL to play music

                ;--------------------- includes and constants ---------------------------
                INCDIR      "include"
                INCLUDE     "hw.i"

;TEST_MUSIC_BUILD SET 1             ; run a test build with imported GFX


                section music_iff,code_c

                IFND TEST_BUILD_LEVEL
; Music Player Constants
AUDIO_PLAYER_INIT               EQU $00068f80                       ; initialise music/sfx player
AUDIO_PLAYER_SILENCE            EQU $00068f84                       ; Silence all audio
AUDIO_PLAYER_INIT_SFX_1         EQU $00068f88                       ; Initialise SFX Audio Channnel
AUDIO_PLAYER_INIT_SFX_2         EQU $00068f8c                       ; same as init_sfx_1 above
AUDIO_PLAYER_INIT_SONG          EQU $00068f90                       ; initialise song to play - D0.l = song/sound 1 to 13
AUDIO_PLAYER_INIT_SFX           EQU $00068f94                       ; initialise sfx to play - d0.l = sfx 5 to 13
AUDIO_PLAYER_UPDATE             EQU $00068f98                       ; regular update (vblank to keep sounds/music playing)
AUDIO_OFFSET_L000690a6          EQU $000690a6
AUDIO_OFFSET_L000690f0          EQU $000690f0

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
AUDIO_OFFSET_L000690a6          EQU L000690a6
AUDIO_OFFSET_L000690f0          EQU L000690f0 

                ENDC    

;Chem.iff - Level Music - Constants
;----------------------------------
SFX_LEVEL_MUSIC     EQU         $01
SFX_LEVEL_COMPLETE  EQU         $02
SFX_LIFE_LOST       EQU         $03
SFX_TIMER_EXPIRED   EQU         $04
SFX_DRIP            EQU         $05
SFX_GASLEAK         EQU         $06
SFX_BATROPE         EQU         $07
SFX_BATARANG        EQU         $08
SFX_GRENADE         EQU         $09
SFX_GUYHIT          EQU         $0a
SFX_SPLASH          EQU         $0b
SFX_Ricochet        EQU         $0c
SFX_EXPLOSION       EQU         $0d


Init_Player         rts
Stop_Playing        rts
Init_SFX_1          rts
Init_SFX_2          rts
Init_Song           rts
Init_SFX            rts
Play_Sounds         rts
L000690a6           dc.l    $0
L000690f0           dc.l    $0


