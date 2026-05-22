                ; NOTES:
                ; ------
                ; 1) If 'JAMMMM' cheat mode active then 'F10' skip to next level (Enter text 'JAMMMM' on title screen)
                ;
                ; 
                ;
                ;
                ; Level 5 - Memory Map
                ; ------------------------------
                ; The following files are loaded and decrunched into the following locations
                ; by the game loader
                ;
                ;
                ; Filename/Area     Start   End         Additional Info
                ;---------------------------------------------------------------------------------------------
                ; BATMAN            $800                - Game Loader (always resident across loads)
                ; CODE1             $2FFC   $7300      - $3000 = entry point for level code. (16Kb)
                ;
                ; MAPGR2            $7FFC   $10000      - Game Tile map data and background GFX blocks
                ;                                       - $8002 - tile map width
                ;                                       - $807c - start of tilemap data
                ;                                       - $a07c - start of gfx block data
                ;       
                ;                   $10000              - Display Object List
                ;                                           - 305 - game display objects
                ;                                                   initialised from data in BATSPR1.IFF file.
                ;
                ; BATSPR1           $10FFC  $2897a      - Display Objects & Graphics
                ;                           $403f8      - $11002 = 16 bit - number of display object
                ;                                       - $11004 = start of display object data
                ;                                                   - 8 byte structure per object
                ;                                                       - 1 word (unused $800f)
                ;                                                       - 1 byte pixel width
                ;                                                       - 1 byte pixel height
                ;                                                       - 4 bytes gfx start offset
                ;                                                           gfx base starts at end of list of objects
                ;                                                           (No of objects * 8) + $11004 = $1198C
                ;                                       - Total size with mirrored sprites $2f2fc
                ;                                       - $3f962 - end of sprite data (including precalced mirrored sprites)
                ;
                ; CHURCH            $47FE4              - Level Music Player, Music & SFX
                ; STACK             $5a36c              - Address of program stack - not a file load.
                ;
                ; Off Screen Buffer - $5a36c            - $5a36c - $6159c - (size = $7230 - 29,232 bytes)
                ;                                           - This is an off-screen buffer used to prepare the background
                ;                                           - scroll graphics. It's a bit like a circular gfx buffer.
                ;                                           - A routine copies the data in this buffer to the back buffer
                ;                                           - which is eventually displayed as part of the double buffering.
                ;               
                ;
                ; DISPLAY BUFFER (Double Buffered Display)  
                ;    display buffer 1 - $61b9c - $68dcc 
                ;                       - Bitplane 1 = $61b9c ($1c8c - 7308 bytes) (174 rasters @ 42 bytes)
                ;                       - Bitplane 2 = $63828 ($1c8c - 7308 bytes) (174 rasters @ 42 bytes)
                ;                       - Bitplane 3 = $654b4 ($1c8c - 7308 bytes) (174 rasters @ 42 bytes)
                ;                       - Bitplane 4 = $67140 ($1c8c - 7308 bytes) (174 rasters @ 42 bytes)
                ;    display buffer 2 - $68dce - $6fffe
                ;                       - Bitplane 1 = $68dce ($1c8c - 7308 bytes) (174 rasters @ 42 bytes)
                ;                       - Bitplane 2 = $6aa5a ($1c8c - 7308 bytes) (174 rasters @ 42 bytes)
                ;                       - Bitplane 3 = $6c6e6 ($1c8c - 7308 bytes) (174 rasters @ 42 bytes)
                ;                       - Bitplane 4 = $6e372 ($1c8c - 7308 bytes) (174 rasters @ 42 bytes)
                ;
                ;
                ; LOADBUFFER        $5a36C  $7C7FC      - File Load Area (files loaded here before depacked/relocated)
                ; PANEL             $7C7FC  $80000      - Game State/Lives manager (always resident across loads)
                ;
                ;
                ;


TEST_BUILD_LEVEL    SET 1                              ; run a test build with imported GFX, level data and Panel




; Loader Constants
LOADER_TITLE_SCREEN             EQU $00000820                       ; Load Title Screen 
LOADER_LEVEL_1                  EQU $00000824                       ; Load Level 1
LOADER_LEVEL_2                  EQU $00000828                       ; Load Level 2
LOADER_LEVEL_3                  EQU $0000082c                       ; Load Level 3
LOADER_LEVEL_4                  EQU $00000830                       ; Load Level 4
LOADER_LEVEL_5                  EQU $00000834                       ; Load Level 5

           

; Code5 - Constants
;-------------------
                IFND TEST_BUILD_LEVEL
STACK_ADDRESS                   EQU $0005a36c
                ENDC
                IFD TEST_BUILD_LEVEL
STACK_ADDRESS                   EQU start                                                       ; set stack to start of program.
                ENDC


CODE1_INITIAL_TIMER_BCD         EQU $1200                                                       ; BCD Vaue for 08:00 minutes
CODE1_DISPLAY_PIXELSWIDE        EQU $150                                                        ; 336 pixels wide
CODE1_DISPLAY_BYTESWIDE         EQU (CODE1_DISPLAY_PIXELSWIDE/8)                                ; 42 bytes wide
CODE1_DISPLAY_LINESHIGH         EQU $ae                                                         ; 174 raster lines high
CODE1_DISPLAY_BITPLANEBYTES     EQU (CODE1_DISPLAY_BYTESWIDE*CODE1_DISPLAY_LINESHIGH)           ; 7308 bytes per bitplane
CODE1_DISPLAY_BITPLANEDEPTH     EQU $4                                                          ; 4 bitplanes (16 colour display)

                                ; screen display double buffer
                                IFND TEST_BUILD_LEVEL
CODE1_DOUBLE_BUFFER_ADDRESS     EQU $00061b9c                                                   ; original address - start of double buffer display in memory
                                ENDC
                                IFD TEST_BUILD_LEVEL
CODE1_DOUBLE_BUFFER_ADDRESS     EQU chipmem_doublebuffer
                                ENDC                                
CODE1_DISPLAY_BUFFER_BYTESIZE   EQU CODE1_DISPLAY_BITPLANEBYTES*CODE1_DISPLAY_BITPLANEDEPTH;    ; size of each display buffer in bytes
CODE1_DOUBLE_BUFFER_BYTESIZE    EQU CODE1_DISPLAY_BUFFER_BYTESIZE*2                             ; size of double buffer display in bytes
CODE1_DISPLAY_BUFFER1_ADDRESS   EQU CODE1_DOUBLE_BUFFER_ADDRESS                                 ; Address $61b9c
CODE1_DISPLAY_BUFFER2_ADDRESS   EQU CODE1_DOUBLE_BUFFER_ADDRESS+CODE1_DISPLAY_BUFFER_BYTESIZE   ; Address $68dcc

                                ; off-screen display buffer (maybe used for composing the back buffer display)
                                IFND TEST_BUILD_LEVEL
CODE1_CHIPMEM_BUFFER            EQU $0005a36c                                                   ; original address  $5a36c - $6159c - (size = $7230 - 29,232 bytes)
                                ENDC
                                IFD TEST_BUILD_LEVEL
CODE1_CHIPMEM_BUFFER            EQU chipmem_buffer 
                                ENDC

CODE1_CHIPMEM_BUFFER_BYTESIZE   EQU CODE1_DISPLAY_BUFFER_BYTESIZE           

                                even


PLAYER_INPUT_RIGHT  EQU     $0          ; player_input_command - bit 0 = Player Right Pushed 
PLAYER_INPUT_LEFT   EQU     $1          ; player_input_command - bit 1 = Player Left Pushed
PLAYER_INPUT_DOWN   EQU     $2          ; player_input_command - bit 2 = Player Down Pushed
PLAYER_INPUT_UP     EQU     $3          ; player_input_command - bit 3 = Player Up Pushed
PLAYER_INPUT_FIRE   EQU     $4          ; player_input_command - bit 4 = Player Fire Pushed (pulsed for 1 frame)


; Code1 - debug_print_word_value constants
FONT_8x8_HEIGHT     EQU         $8
ASCII_SPACE         EQU         $20

KEY_F1              EQU         $0081
KEY_F2              EQU         $0082
KEY_F10             EQU         $008a
KEY_ESC             EQU         $001b



; offscreen, double buffer display sizes
DISPLAY_MAX_Y               EQU     $57                                         ; max display Y value (87) represents line 174 of the display (87*2)
DISPLAY_BYTEWIDTH           EQU     $2a                                         ; 42 bytes wide
DISPLAY_2RASTERS            EQU     DISPLAY_BYTEWIDTH*2                         ; 84 bytes for two raster lines 
DISPLAY_BUFFER_BYTES        EQU     2*DISPLAY_MAX_Y*DISPLAY_BYTEWIDTH           ; size of display buffer in bytes
DISPLAY_BUFFER_BPL0_OFFSET  EQU     $0
DISPLAY_BUFFER_BPL1_OFFSET  EQU     DISPLAY_BUFFER_BYTES
DISPLAY_BUFFER_BPL2_OFFSET  EQU     DISPLAY_BUFFER_BYTES*2
DISPLAY_BUFFER_BPL3_OFFSET  EQU     DISPLAY_BUFFER_BYTES*3






                section code5_iff,code_c
                
             
            ; if not test then org $2FFC   
            IFND TEST_BUILD_LEVEL
                org     $2ffc                                           ; original load address $2FFC
            ENDC



                ;--------------------- includes and constants ---------------------------
                INCDIR      "include"
                INCLUDE     "hw.i"
                ;opt         o-




            ; if test then jump to game start
            IFD TEST_BUILD_LEVEL
start               ; added for testing 
                    jmp game_start     
            ENDC


original_start:     ; original address $00002ffc
                    dc.l    $00003000                           ; original address $00002ffc

                    ; -------------------------- game start /  initialise system ---------------------------------
                    ; This is the Level 5 code entry point on loading.
                    ;
                    ; NOTES:
                    ; I added the 'supervisor mode' code as this was previously handled by the loader, and it is
                    ; required as some code performs 'move.w <ea>,SR' (priviledged instruction on 68000)
                    ;   NB: the code also performs 'move.w SR,<ea>' which is privileged on some processors.
                    ; 
                    ; I added the stack address setting code, which moves the stack to the start of the program,
                    ; hopefully out of harms way for rebuilding and executing.
                    ;
                    ; Added a couple of Test build initialisations got playyer lives etc
                    ;
game_start          ; original address $00003000
initialise_system   ; original address $00003000 

                    ;JSR _DEBUG_COLOURS

                    ; kill the system & initialise h/w
                    moveq   #$00,D0
                    move.w  #$1fff,$00dff09a
                    move.w  #$1fff,$00dff096
                    move.w  #$0200,$00dff100
                    move.l  D0,$00dff102
                    move.w  #$4000,$00dff024
                    move.l  D0,$00dff040
                    move.w  #$0041,$00dff058

                    move.w  #$8340,$00dff096
                    move.w  #$7fff,$00dff09e

                    ; clear all sprite postions - L00003046
                    moveq.l #$07,D7
                    lea.l   $00dff140,A0

L0000304E            move.w  D0,(A0)
                     adda.w  #$08,A0
                     dbf.w   D7,L0000304E

                    ; clear all audio volume - L00003056
                    moveq.l #$03,D7
                    lea.l   $00dff0a8,A0

L0000305E            move.w  D0,(A0)
                     lea.l   $0010(A0),A0
                     dbf.w   D7,L0000305E

                    ; all colour regs to black -L00003068
                     lea.l   $00dff180,A0
                     moveq.l #$1f,D7
L00003070            move.w  D0,(A0)+
                     dbf.w   D7,L00003070

                    ; reset CIAA - L00003076
                    move.b  #$7f,$00bfed01
                    move.b  D0,$00bfee01
                    move.b  D0,$00bfef01
                    move.b  D0,$00bfe001
                    move.b  #$03,$00bfe201
                    move.b  D0,$00bfe101
                    move.b  #$ff,$00bfe301

                    ; reset CIAB - L000030A6
                    move.b  #$7f,$00bfdd00
                    move.b  D0,$00bfde00
                    move.b  D0,$00bfdf00
                    move.b  #$c0,$00bfd000
                    move.b  #$c0,$00bfd200
                    move.b  #$ff,$00bfd100
                    move.b  #$ff,$00bfd300



                    ; ------ enter supervisor mode -------
.enter_supervisor   LEA.L   .supervisor_trap(PC),A0         ; A0 = address of supervisor trap $00001F58
                    MOVE.L  A0,$00000080                    ; Set TRAP 0 vector
                    MOVEA.L A7,A0                           ; store stack pointer
                    TRAP    #$00000000                      ; do the trap (jmp to next instruction in supervisor mode)
                    ; this trap never returns.
                    ; enter supervisor mode
.supervisor_trap    MOVEA.L A0,A7                           ; restore the stack (i.e. rts return address etc)
                    ; ------ enter supervisor mode -------



                    ;jsr     _DEBUG_COLOURS


                    ; set stack address - L000030DA
                    LEA.L   STACK_ADDRESS,A7                ; STACK

                    ; set interrupt handlers (only level 1,2 & 3)
                    ; odd as additional handlers exist
                    MOVEQ.L #$02,D7
                    LEA.L   interrupt_handlers_table,A0
                    LEA.L   $00000064,A1
L000030EE           MOVE.L  (A0)+,(A1)+
                    DBF.W   D7,L000030EE

                    ; Initialise CIA Timers 
                    MOVE.W  #$ff00,$00dff034
                    MOVE.W  D0,$00dff036
                    OR.B    #$ff,$00bfd100
                    AND.B   #$87,$00bfd100
                    AND.B   #$87,$00bfd100
                    OR.B    #$ff,$00bfd100
                    MOVE.B  #$f0,$00bfe601
                    MOVE.B  #$37,$00bfeb01
                    MOVE.B  #$11,$00bfef01

                    ; CIAA - Timer B Low = $f0      ; 0.33 second
 
                    MOVE.B  #$91,$00bfd600
                    MOVE.B  D0,$00bfdb00
                    MOVE.B  D0,$00bfdf00

                    ; CIAB - Timer B Low = $00

                    MOVE.W  #$7fff,$00dff09c
                    TST.B   $00bfed01
                    MOVE.B  #$8a,$00bfed01
                    TST.B   $00bfdd00
                    MOVE.B  #$93,$00bfdd00
                    MOVE.W  #$e078,$00dff09a


                    ; start initialising the game 
                IFD TEST_BUILD_LEVEL
                    jsr     PANEL_INIT_LIVES                ; Panel - Initialise Player Lives - $0007c838
                    jsr     PANEL_INIT_SCORE                ; Panel - Initialise Player Score to 0 - $0007c81c
    
                ENDC
                    ; set initial level timer value
                    MOVE.W  #CODE1_INITIAL_TIMER_BCD,D0    ; timer 12:00 BCD
                    JSR     PANEL_INIT_TIMER               ; $0007c80e                       ; PANEL
                    JSR     PANEL_INIT_ENERGY              ; $0007c854  ; PANEL

                    BSR.W   clear_display_memory           ; L0000373a
                    LEA.L   copper_list,a0                 ; L000031bc,A0 ; Copper
                    BSR.W   reset_display                  ; L0000367e
                    BSR.W   double_buffer_playfield        ; L000036ee
 
                    BRA.W   initialise_game                ; L00003ad4 




                    ; maybe intended as a second copper list
L000031A0           dc.w    $ffff 
L000031A2           dc.w    $fffe 


interrupt_handlers_table    ; original address L000031A4
                    dc.l    level1_interrupt_handler        ; L000032b4
                    dc.l    level2_interrupt_handler        ; L000032ec
                    dc.l    level3_interrupt_handler        ; L00003312
                    dc.l    level4_interrupt_handler        ; L0000334e
                    dc.l    level5_interrupt_handler        ; L00003364
                    dc.l    level6_interrupt_handler        ; L0000338a




                    ; -------------------- copper list -------------------
                    ; Playfield Display
                    ; ($67680) - Bitplane1 size = $2260 (8800) (336*209 @ 42 bytes per raster)
                    ; ($698e0) - Bitplane2 size = $2260 (8800) (336*209 @ 42 bytes per raster)  
                    ; ($6bb40) - Bitplane3 size = $2260 (8800) (336*209 @ 42 bytes per raster) 
                    ; ($6dda0) - Bitplane4 size = $2260 (8800) (336*209 @ 42 bytes per raster) 
                    ;
                    ; Panel Display
                    ; ($67680) - Bitplane size = $2260 (8800) (336*209 @ 42 bytes per raster)  
                    ; ($698e0) - Bitplane size = $2260 (8800) (336*209 @ 42 bytes per raster)  
                    ; ($6bb40) - Bitplane size = $2260 (8800) (336*209 @ 42 bytes per raster)   
                    ; ($6dda0) - Bitplane size = $2260 (8800) (336*209 @ 42 bytes per raster)
                    ; 
copper_list         ;       original address L000031BC
                    ; ---- playfield display (scroll area) ---
                    dc.w    $2c01,$fffe
                    dc.w    BPL2MOD,$0002
                    dc.w    BPL1MOD,$0002
copper_playfield_planes     ; original address L000031C8
                    dc.w    BPL1PTL,$8dce
                    dc.w    BPL1PTH,$0006
                    dc.w    BPL2PTL,$aa5a 
                    dc.w    BPL2PTH,$0006
                    dc.w    BPL3PTL,$c6e6
                    dc.w    BPL3PTH,$0006
                    dc.w    BPL4PTL,$e372
                    dc.w    BPL4PTH,$0006
                    dc.w    COLOR01,$0446
                    dc.w    COLOR02,$088a
                    dc.w    COLOR03,$0cce 
                    dc.w    COLOR04,$0048
                    dc.w    COLOR05,$028c
                    dc.w    COLOR06,$0c64
                    dc.w    COLOR07,$0a22
                    dc.w    COLOR08,$06a6
                    dc.w    COLOR09,$0c4a
                    dc.w    COLOR10,$0ec6
                    dc.w    COLOR11,$0e88 
                    dc.w    COLOR12,$0600
                    dc.w    COLOR13,$0262
                    dc.w    COLOR14,$0668
                    dc.w    COLOR15,$06ae

                    ; ---- panel display (bottom score/energy etc) ---- 
                    ; original address L00003224                   
                    dc.w    $da01,$fffe
                    dc.w    BPL2MOD,$0000
                    dc.w    BPL1MOD,$0000
copper_panel_planes ; original address L00003230
L00003230           dc.w    BPL1PTL,$c89a
L00003234           dc.w    BPL1PTH,$0007
                    dc.w    BPL2PTL,$d01a
L0000323C           dc.w    BPL2PTH,$0007
                    dc.w    BPL3PTL,$d79a
L00003244           dc.w    BPL3PTH,$0007
                    dc.w    BPL4PTL,$df1a
L0000324C           dc.w    BPL4PTH,$0007
copper_panel_colors ; original address L00003250
                    dc.w    COLOR00,$0000
                    dc.w    COLOR01,$0000
                    dc.w    COLOR02,$0000
                    dc.w    COLOR03,$0000
                    dc.w    COLOR04,$0000
                    dc.w    COLOR05,$0000
                    dc.w    COLOR06,$0000
                    dc.w    COLOR07,$0000
                    dc.w    COLOR08,$0000
                    dc.w    COLOR09,$0000 
                    dc.w    COLOR10,$0000
                    dc.w    COLOR11,$0000
                    dc.w    COLOR12,$0000
                    dc.w    COLOR13,$0000 
                    dc.w    COLOR14,$0000
                    dc.w    COLOR15,$0000 
                    dc.w    $ffff,$fffe
                    dc.w    $ffff,$fffe


                    ;------------------- 16 colours for the Panel ---------------------
panel_colours       ; original address L00003294
L00003294           dc.w    $0000,$0060,$0fff,$0008
                    dc.w    $0a22,$0444,$0862,$0666
                    dc.w    $0888,$0aaa,$0a40,$0c60
                    dc.w    $0e80,$0ea0,$0ec0,$0eee




                    ; -------------------- level 1 - interrupt handler --------------------
                    ; TBE, DSKBLK, SOFT - Interrupts, just clear the bits from INTREQ
                    ;  NB: not enabled by init_system above
                    ;
level1_interrupt_handler    ; original addr: 000032B4
                        MOVE.L  D0,-(A7)
                        MOVE.W  $00dff01e,D0
                        BTST.L  #$0002,D0
                        BNE.B   .L000032E0
                        BTST.L  #$0001,D0
                        BNE.B   .L000032D4
                        MOVE.W  #$0001,$00dff09c
                        MOVE.L  (A7)+,D0
                        RTE 

.L000032D4               MOVE.W  #$0002,$00dff09c
                        MOVE.L  (A7)+,D0
                        RTE 

.L000032E0               MOVE.W  #$0004,$00dff09c
                        MOVE.L  (A7)+,D0
                        RTE 




                    ; -------------------- level 2 - interrupt handler --------------------
                    ; CIA Ports & Timers
                    ; - Enabled by 'init_system' above
                    ; 
level2_interrupt_handler    ; original address L000032EC
                        MOVE.L  D0,-(A7)
                        MOVE.B  $00bfed01,D0
                        BPL.B   .L00003306
                        BSR.W   lvl2_CIAA_Interrupt             ; L000033c8
                        MOVE.W  #$0008,$00dff09c
                        MOVE.L  (A7)+,D0
                        RTE 

.L00003306              MOVE.W  #$0008,$00dff09c
                        MOVE.L  (A7)+,D0
                        RTE 




                    ; -------------------- level 3 - interrupt handler --------------------
                    ; COPER, VERTB, BLIT - interrupts
                    ; - Enabled by 'init_system' above
                    ;
level3_interrupt_handler    ; original address L00003312
                        MOVE.L  D0,-(A7)
                        MOVE.W  $00dff01e,D0
                        BTST.L  #$0004,D0
                        BNE.B   .L00003342
                        BTST.L  #$0005,D0
                        BNE.B   .L00003332
                        MOVE.W  #$0040,$00dff09c
                        MOVE.L  (A7)+,D0
                        RTE 

.L00003332              BSR.W   lvl_3_update_sound_player           ; L0000351a
                        MOVE.W  #$0020,$00dff09c
                        MOVE.L  (A7)+,D0
                        RTE 

.L00003342              MOVE.W  #$0010,$00dff09c
                        MOVE.L  (A7)+,D0
                        RTE 




                    ; ------------------------ level 4 - interrupt handler ------------------------- 
                    ; not installed to autovector by the game init
                    ; unused handler
                    ; if used would clear raised audio interrupts.
level4_interrupt_handler    ; original address L0000334E
                    MOVE.L  D0,-(A7)
                    MOVE.W  $00dff01e,D0
                    AND.W   #$0780,D0
                    MOVE.W  D0,$00dff09a
                    MOVE.L  (A7)+,D0
                    RTE 




                    ; ----------------------- level 5 - interrupt handler -------------------------- 
                    ; not installed to autovector by the game init
                    ; unused handler
                    ; if used, then it would clear the disk sync interrupt & serial port interrupt
                    ;
level5_interrupt_handler    ; original address L00003364
                        MOVE.L  D0,-(A7)
                        MOVE.W  $00dff01e,D0
                        BTST.L  #$000c,D0
                        BNE.B   .L0000337E
                        MOVE.W  #$0800,$00dff09c
                        MOVE.L  (A7)+,D0
                        RTE 

.L0000337E              MOVE.W  #$1000,$00dff09c
                        MOVE.L  (A7)+,D0
                        RTE 




                    ; -------------------- level 6 - interrupt handler -------------------- 
                    ; not installed to autovector by the game init
                    ; NB: level 6 is enabled by 'init_system' but is not raised during 
                    ;     level 1 play.
                    ;
                    ; The Vector is still pointing to $2182 (the loader level6 handler)
                    ; a bug or intentional?
                    ;
                    ; unused handler
                    ;
level6_interrupt_handler    ; original address L0000338A
                        MOVE.L  D0,-(A7)
                        MOVE.W  $00dff01e,D0
                        BTST.L  #$000e,D0
                        BNE.B   .L000033BC
                        MOVE.B  $00bfdd00,D0
                        BPL.B   .L000033B0
                        BSR.W   lvl6_timerb_interrupt           ; L00003508
                        MOVE.W  #$2000,$00dff09c
                        MOVE.L  (A7)+,D0
                        RTE 

.L000033B0              MOVE.W  #$2000,$00dff09c
                        MOVE.L  (A7)+,D0
                        RTE 

.L000033BC              MOVE.W  #$4000,$00dff09c
                        MOVE.L  (A7)+,D0
                        RTE 




                    ; ------------------ level 2 - CIAA - Interrupt Handler ------------------
                    ; Handles:
                    ;   CIAA - Timer B
                    ;   Reading the keybaord (adding ascii codes to the keyboard queue)
                    ;
                    ; IN:
                    ;  - D0 - CIAA - ICR
                    ;
lvl2_CIAA_Interrupt ; original address L000033C8
                        LSR.B   #$02,D0
                        BCC.B   .L000033D0
                        BSR.W   lvl2_CIAB_TimerB_Handler            ; L00003538

.L000033D0              LSR.B   #$02,D0
                        BCC.B   .L00003442

                    ; keyboard interrupt
.L000033D4              MOVEM.L D1-D2/A0,-(A7)
                        MOVE.B  $00bfec01,D1
                        NOT.B   D1
                        LSR.B   #$01,D1
                        BCC.B   .L000033FA
                    ; key released (d1 = keycode) 
                    ; get ascii code and clear key pressed in bitmap table
.L000033E4              LEA.L   keyboard_bitmap,a0              ; L000034e8,A0
                        EXT.W   D1
                        MOVE.B  acsii_lookup_table(PC,D1.w),D1
                        MOVE.W  D1,D2
                        LSR.W   #$03,D2
                        BCLR.B  D1,$00(A0,D2.w)
                        BRA.B   .L00003436
                    ; key pressed (d1 = keycode) 
.L000033FA              LEA.L   keyboard_bitmap,a0              ; L000034e8,A0
                        EXT.W   D1
                        MOVE.B  acsii_lookup_table(PC,D1.w),D1
                        MOVE.W  D1,D2
                        LSR.W   #$03,D2
                        BSET.B  D1,$00(A0,D2.w)
                        TST.B   D1
                        BEQ.B   .L00003436

                    ; enqueue the pressed key
.L00003412              LEA.L   keyboard_buffer,A0
                        MOVE.W  keyboard_queue_head,d2          ; L000034e4,D2
                        MOVE.B  D1,$00(A0,D2.w)
                        ADDQ.W  #$01,D2
                        AND.W   #$001f,D2
                        CMP.W   keyboard_queue_tail,d2          ; L000034e6,D2
                        BEQ.B   .L00003436
                        MOVE.W  D2,keyboard_queue_head          ; L000034e4

.L00003436              MOVE.B  #$40,$00bfee01
                        MOVEM.L (A7)+,D1-D2/A0
.L00003442              RTS 


                    ; raw key code translation table (raw keycode index into the table, ascii lookup)
                    ; keycode in range $00 - $7f
acsii_lookup_table  ; original address 00003444
L00003444                
                        dc.b $27
                        dc.b $31 
                        dc.b $32
                        dc.b $33 
                        dc.b $34
                        dc.b $35 
                        dc.b $36
                        dc.b $37  
                        dc.b $38
                        dc.b $39 
                        dc.b $30
                        dc.b $2d 
                        dc.b $3d
                        dc.b $5c  
                        dc.b $00
                        dc.b $30 
                        dc.b $51
                        dc.b $57 
                        dc.b $45
                        dc.b $52 
                        dc.b $54
                        dc.b $59 
                        dc.b $55
                        dc.b $49 
                        dc.b $4f
                        dc.b $50 
                        dc.b $5b
                        dc.b $5d 
                        dc.b $00
                        dc.b $31 
                        dc.b $32
                        dc.b $33 
                        dc.b $41
                        dc.b $53 
                        dc.b $44
                        dc.b $46 
                        dc.b $47
                        dc.b $48 
                        dc.b $4a
                        dc.b $4b 
                        dc.b $4c
                        dc.b $3b
                        dc.b $23
                        dc.b $00
                        dc.b $00
                        dc.b $34 
                        dc.b $35
                        dc.b $36 
                        dc.b $00
                        dc.b $5a 
                        dc.b $58
                        dc.b $43 
                        dc.b $56
                        dc.b $42
                        dc.b $4e
                        dc.b $4d 
                        dc.b $2c
                        dc.b $2e 
                        dc.b $2f
                        dc.b $00  
                        dc.b $00
                        dc.b $37 
                        dc.b $38
                        dc.b $39 
                        dc.b $20
                        dc.b $08  
                        dc.b $09
                        dc.b $0d 
                        dc.b $0d
                        dc.b $1b
                        dc.b $7f
                        dc.b $00
                        dc.b $00
                        dc.b $00 
                        dc.b $2d
                        dc.b $00 
                        dc.b $8c
                        dc.b $8d
                        dc.b $8e
                        dc.b $8f
                        dc.b $81
                        dc.b $82
                        dc.b $83
                        dc.b $84
                        dc.b $85
                        dc.b $86
                        dc.b $87
                        dc.b $88
                        dc.b $89
                        dc.b $8a
                        dc.b $28
                        dc.b $29 
                        dc.b $2f
                        dc.b $2a
                        dc.b $2b
                        dc.b $8b 
                        dc.b $00
                        dc.b $00
                        dc.b $00
                        dc.b $00 
                        dc.b $00
                        dc.b $00
                        dc.b $00
                        dc.b $00 
                        dc.b $00
                        dc.b $00
                        dc.b $00
                        dc.b $00 
                        dc.b $00
                        dc.b $00
                        dc.b $00
                        dc.b $00 
                        dc.b $00
                        dc.b $00
                        dc.b $00
                        dc.b $00 
                        dc.b $00
                        dc.b $00
                        dc.b $00
                        dc.b $00 
                        dc.b $00
                        dc.b $00
                        dc.b $00
                        dc.b $00 
                        dc.b $00
                        dc.b $00
                        dc.b $00
                        dc.b $00
                    ; End of Keycode - Ascii lookup table


                    ; --------------- keyboard buffer ------------------
                    ; 32 byte keyboard buffer queue.
                    ;
keyboard_buffer     ; original address L000034C4  
L000034C4                   dc.b $00,$00,$00,$00,$00,$00,$00,$00 
                            dc.b $00,$00,$00,$00,$00,$00,$00,$00
                            dc.b $00,$00,$00,$00,$00,$00,$00,$00
                            dc.b $00,$00,$00,$00,$00,$00,$00,$00 


                    ; Keyboard buffer index (where new keycodes are queued into)
keyboard_queue_head ; original address L000034E2 
L000034E4                   dc.w $0000

                    ; Keyboard buffer index (where keycodes are dequeued from)
keyboard_queue_tail ; original address L000034E6
L000034E6                   dc.w $0000 


                    ; A bitmap of the keys currently pressed on the keyboard
                    ; each bit records the key press or release status of the key.
                    ; range = $00 - $7f (16 bytes of bitmap data)
keyboard_bitmap     ; original address L000034E8
L000034E8                   dc.w $0000,$0000,$0000,$0000
                            dc.w $0000,$0000,$0000,$0000 
                    ; extended bitmap for control keys (Function keys etc)
                    ; ascii codes $80-$ff
L000034F8                   dc.w $0000,$0000,$0000,$0000 
                            dc.w $0000,$0000,$0000,$0000 





                    ;----------------------------------------------------------------------------
                    ; never called because a level 6 interrupt never genrated by level 1 code
                    ; IN:
                    ;   d0.b = CIAB - ICR
                    ;
lvl6_timerb_interrupt       ; original address L00003508 
                            LSR.B   #$02,D0
                            BCC.B   .L00003514
                            MOVE.B  #$00,$00bfee01
.L00003514                  RTS 

                    ; unreferenced ptr?
L00003516                   dc.l    lvl_3_sfx_exit              ;  unused ptr to 'rts' below





                    ; ---------------------- update music/sfx player ---------------------------
                    ; called from lvl3 vertb handler
                    ;   - increments the frame counter
                    ;   - play's current sfx/music
                    ;   - writes '$00' to CIAA CRA (this does nothing due to bit 7 being set/clr)
                    ;       - so it doesn't actuall clear any bits?
                    ;
lvl_3_update_sound_player   ;original address L0000351A  
                            MOVEM.L D1-D7/A0-A6,-(A7)
                            ADDQ.W  #$01,frame_counter          ; L000036e2
                            JSR     AUDIO_PLAYER_UPDATE         ; $00048018  ; AUDIO PLAYER
                            MOVE.B  #$00,$00bfee01
                            MOVEM.L (A7)+,D1-D7/A0-A6
lvl_3_sfx_exit              ; original address L00003536                           
L00003536                   RTS 




                    ; --------------------- Level 2 - CIAB Timer B Handler -------------------
                    ; CIAB - Timer B underflow handler (read joystick/mouse counters)
                    ;       - calls function ptr set at 'ciab_timerb_function_ptr'
                    ;       - default this is rts.
                    ;
lvl2_CIAB_TimerB_Handler    ; original address L00003538
                            MOVEM.L D0-D7/A0-A6,-(A7)
                            BSR.W   ciab_timerb_function            ; L0000355A
                            ADDQ.W  #$01,ciab_timerb_ticker         ; L00003558
                            MOVEA.L ciab_timerb_function_ptr,a0     ; L00003554,A0
                            JSR (A0)
                            MOVEM.L (A7)+,D0-D7/A0-A6
                            RTS 

ciab_timerb_function_ptr    ; original address L00003554
L00003554                   dc.l lvl_3_sfx_exit            ; CIAB - Timer B - Handler Routine - Default ptr to 'rts' @ $00003542

ciab_timerb_ticker          ; original address L00003558
L00003558                   dc.w $0000                     ; CIAB - Timer B - Ticker Count 




                    ; --------------------- level 2 - Timer B - read ports -----------------------
                    ; read buttons and pot counters for joystick ports 0 and 1
                    ;
ciab_timerb_function    ; original address L0000355A
                            ; joystick 0 counters
                            MOVE.W  $00dff00a,D0
                            MOVE.W  Joystick_0,d1                   ; L00003624,D1
                            MOVE.W  d0,Joystick_0                   ; D0,$00003624
                            BSR.W   calc_counter_deltas             ; L000035ee
                            MOVE.B  D0,joy0_random                  ; L0000362b
                            ADD.W   D1,pot0_horizontal              ; L0000363a
                            ADD.W   D2,pot0_vertical                ; L0000363c
                            BTST.B  #$0006,$00bfe001
                            SEQ.B   joy0_button0                    ; L0000362a
                            SEQ.B   joy0_button0b                   ; L00003638
                            BTST.B  #$0002,$00dff016
                            SEQ.B   joy0_button1b                   ; L00003639

                            ; joystick 1 counters
                            MOVE.W  $00dff00c,D0
                            MOVE.W  Joystick_1,d1                   ; L00003626,D1
                            MOVE.W  d0,Joystick_1                   ; D0,L00003626
                            BSR.B   calc_counter_deltas             ; L000035ee
                            MOVE.B  D0,joy1_random                  ; L0000362f
                            ADD.W   D1,pot1_horizontal              ; L00003640
                            ADD.W   D2,pot1_vertical                ; L00003642
                            BTST.B  #$0007,$00bfe001
                            SEQ.B   joy1_button0                    ; L0000362e
                            SEQ.B   joy1_button0b                   ; L0000363e
                            BTST.B  #$0006,$00dff016
                            SEQ.B   joy1_button1b                   ; L0000363f
                            RTS 



                    ; --------------------- calculate mouse counter deltas --------------------
                    ; calculate delta differences for x,y pot counters.
                    ; also generate a pseudo random number $00 - $0f 
                    ;
                    ; IN:
                    ; d0.w = JOYxDAT - h/w register read value (current value)
                    ; d1.w = JOYxDAT - h/w register read value (previous value)
                    ; OUT:
                    ;   d0.b    = lookup table value (random number lookup?)
                    ;   d1.w    = Horizontal Counter Difference#
                    ;   d2.w    = Vertical Counter Difference
                    ; 
calc_counter_deltas     ; original address L000035EE
L000035EE                   MOVE.W  D0,D3
L000035F0                   MOVE.W  D1,D2
L000035F2                   SUB.B   D3,D1
L000035F4                   NEG.B   D1
L000035F6                   EXT.W   D1
L000035F8                   LSR.W   #$08,D2
L000035FA                   LSR.W   #$08,D3
L000035FC                   SUB.B   D3,D2
L000035FE                   NEG.B   D2
L00003600                   EXT.W   D2

L00003602                   MOVE.L  #$03,D3
L00003604                   AND.W   D0,D3
L00003606                   LSR.W   #$06,D0
L00003608                   AND.W   #$000c,D0
L0000360C                   OR.W    D3,D0
L0000360E                   MOVE.B  random_lookup(PC,D0.w),D0
L00003612                   RTS 



                ; Data - Joystick stuff (largely unused)
                    ; ----------- 16 byte lookup table above ------------
                    ; used by above routine to return a value beteen
                    ; $00 - $0f depending on mouse counter values.
                    ; could be a randomnumber seed or similar.
                    ; 
random_lookup       ; original address L00003614
L00003614                   dc.b    $00
                            dc.b    $04 
                            dc.b    $05
                            dc.b    $01
                            dc.b    $08
                            dc.b    $0c
L0000361A                   dc.b    $0d
                            dc.b    $09 
                            dc.b    $0a
                            dc.b    $0e
                            dc.b    $0f
                            dc.b    $0b
                            dc.b    $02
                            dc.b    $06
                            dc.b    $07
                            dc.b    $03 

Joystick_0          ; original address L00003624
L00003624                   dc.w    $d98c 

Joystick_1          ; original address L00003626 
L00003626                   dc.w    $0000

L00003628                   dc.w    $0000                      ; unreferenced word

joy0_button0        ; original address L0000362A
L0000362A                   dc.b    $00
joy0_random         ; original address L0000362B
L0000362B                   dc.b    $08 

L0000362C                   dc.w    $0000                      ; unreferenced word

joy1_button0        ; original address L0000362E
L0000362E                   dc.b    $00
joy1_random         ; original address L0000362F
L0000362F                   dc.b    $00

L00003630                   dc.w    $0000                      ; unreferenced word 
L00003632                   dc.w    $0000                      ; unreferenced word
L00003634                   dc.w    $0000                      ; unreferenced word 
L00003636                   dc.w    $0000                      ; unreferenced word

joy0_button0b       ; original address L00003638
L00003638                   dc.b    $00
joy0_button1b       ; original address L00003639
L00003639                   dc.b    $00 

pot0_horizontal     ; original address L0000363A
L0000363A                   dc.w    $f48c

pot0_vertical       ; original address L0000363C
L0000363C                   dc.w    $fdd9 

joy1_button0b       ; original address L0000363E  
L0000363E                   dc.b    $00
joy1_button1b       ; original address L0000363F
L0000363F                   dc.b    $00 

pot1_horizontal     ; original address L00003640
L00003640                   dc.w    $0000
pot1_vertical       ; original address L00003642
L00003642                   dc.w    $0000 




                    ; -------------------- wait key --------------------
                    ; wait/loop until a key is pressed
                    ;
waitkey             ; original address L00003644
L00003644                   MOVE.L  D0,-(A7)
L00003646                   BSR.B   getkey                  ;L0000364e
L00003648                   BNE.B   L00003646
L0000364A                   MOVE.L  (A7)+,D0
L0000364C                   RTS 



                    ; -------------------- get key --------------------
                    ; dequeue an ascii code from the keybaord queue
                    ;
                    ; OUT:
                    ;   d0.b    - Ascii code (0 if queue empty)
                    ;           - Z = 1 if queue is empty
                    ;
getkey              ; original address L0000364e
L0000364E                   MOVEM.L D1-D2/A0,-(A7)
L00003652                   LEA.L   keyboard_buffer,a0              ; L000034c4,A0
L00003658                   MOVE.L  #$00000000,D0
L0000365A                   MOVEM.W keyboard_queue_head,d1-d2       ; L000034e4,D1-D2
L00003662                   CMP.W   D1,D2
L00003664                   BEQ.B   L00003676

L00003666                   MOVE.B  $00(A0,D2.w),D0
L0000366A                   ADD.W   #$00000001,D2
L0000366C                   AND.W   #$001f,D2
L00003670                   MOVE.W  D2,keyboard_queue_tail          ; L000034e6

L00003676                   TST.B   D0
L00003678                   MOVEM.L (A7)+,D1-D2/A0
L0000367C                   RTS 




                    ;--------------- reset display -------------------
                    ; Set the copper list and 4 bitplane display,
                    ; reset bitplane modulos.
                    ; reset display fetch and window size (320x218)
                    ;
                    ; IN:
                    ;   a0 = copper list address
                    ;
reset_display
L0000367E                   MOVE.W  #$0080,$00dff096
L00003686                   MOVE.L  A0,$00dff080
L0000368C                   MOVE.W  A0,$00dff088
L00003692                   MOVE.W  #$0000,$00dff10a
L0000369A                   MOVE.W  #$0000,$00dff108
L000036A2                   MOVE.W  #$0038,$00dff092
L000036AA                   MOVE.W  #$00d0,$00dff094
L000036B2                   MOVE.W  #$3080,$00dff08e
L000036BA                   MOVE.W  #$0ac0,$00dff090
L000036C2                   MOVE.W  #$4200,$00dff100

 
                    ; set bitplane ptrs if running a test build
                IFD     TEST_BUILD_LEVEL
                    lea     copper_panel_planes,a0
                    move.l  #PANEL_GFX,d0
                    move.w  d0,2(a0)
                    swap.w  d0
                    move.w  d0,6(a0)
                    swap.w  d0
                    add.l   #PANEL_DISPLAY_BITPLANEBYTES,d0
                    move.w  d0,$0a(a0)
                    swap.w  d0
                    move.w  d0,$0e(a0)
                    swap.w  d0  
                    add.l   #PANEL_DISPLAY_BITPLANEBYTES,d0
                    move.w  d0,$12(a0)
                    swap.w  d0
                    move.w  d0,$16(a0)
                    swap.w  d0        
                    add.l   #PANEL_DISPLAY_BITPLANEBYTES,d0
                    move.w  d0,$1a(a0)
                    swap.w  d0
                    move.w  d0,$1e(a0)
                    swap.w  d0       
                ENDC


L000036CA                   CLR.W   frame_counter               ; $000036e2
L000036D0                   TST.W   frame_counter               ; $000036e2
L000036D6                   BEQ.B   L000036D0
L000036D8                   MOVE.W  #$8180,$00dff096         ; Enable - Copper DMA
L000036E0                   RTS 



frame_counter_and_target_counter
frame_counter               ; original address L000036E2
L000036E2                   dc.w $0000

target_frame_count          ; original address L000036E4
L000036E4                   dc.w $0000


playfield_buffer_ptrs       ; original address L000036E6
playfield_buffer_1          ; original address L000036E6
L000036E6                   dc.l CODE1_DISPLAY_BUFFER2_ADDRESS           ; double buffered playfield ptr 1 (current display by copper)
playfield_buffer_2          ; original address L000036EA
L000036EA                   dc.l CODE1_DISPLAY_BUFFER1_ADDRESS           ; double buffered playfield ptr 2 (back buffer)




                    ; ----------------------- double buffer display playfield --------------------------
                    ; swap display buffer pointers and update the copper list display.
                    ; can wait for future frame count, typically waits for top of next frame.
                    ;
double_buffer_playfield     ; original address L000036EE
L000036EE                   MOVE.W  frame_counter,D0
L000036F2                   CMP.W   frame_counter,D0
L000036F6                   BEQ.B   L000036F2

L000036F8                   MOVE.W  target_frame_count,D1
L000036FC                   CMP.W   D0,D1
L000036FE                   BPL.B   double_buffer_playfield         ; L000036ee 

L00003700                   ADD.W   #$0001,D0
L00003704                   MOVE.W  D0,target_frame_count

L00003708                   MOVEM.L playfield_buffer_ptrs,D0-D1
L0000370E                   EXG.L   D0,D1
L00003710                   MOVEM.L D0-D1,playfield_buffer_ptrs

L00003716                   LEA.L   copper_playfield_planes+2,A0
L0000371A                   MOVE.L  #CODE1_DISPLAY_BITPLANEBYTES,D1
L00003720                   MOVE.L  #CODE1_DISPLAY_BITPLANEDEPTH-1,D7

L00003722                   MOVE.W  D0,(A0)
L00003724                   ADDA.l  #$00000004,A0
L00003726                   SWAP.W  D0
L00003728                   MOVE.W  D0,(A0)
L0000372A                   ADDA.l  #$00000004,A0
L0000372C                   SWAP.W  D0
L0000372E                   ADD.L   D1,D0
L00003730                   DBF.W   D7,L00003722

L00003734                   ADDQ.W   #$01,playfield_swap_count
L00003738                   RTS 




                    ; ----------------------- clear display memory ---------------------------
                    ; Clear Double Buffer Display (back & front)
                    ; Clear Off-Screen Displaty Buffer
                    ;
clear_display_memory
L0000373A                   LEA.L   CODE1_DOUBLE_BUFFER_ADDRESS,A0              ; Screen Buffer
L00003740                   MOVE.W  #(CODE1_DOUBLE_BUFFER_BYTESIZE/4)-1,d7      ; #$3917,D7
L00003744                   CLR.L   (A0)+
L00003746                   DBF.W   D7,L00003744
L0000374A                   LEA.L   CODE1_CHIPMEM_BUFFER,A0        ; Screen Buffer
L00003750                   MOVE.W  #(CODE1_DISPLAY_BUFFER_BYTESIZE/4)-1,d7        ; #$1c8b,D7
L00003754                   CLR.L   (A0)+
L00003756                   DBF.W   D7,L00003754
L0000375A                   RTS 




                    ; ----------------------- debug print word value ------------------------
                    ; Debug print routine that converts an 16bit value into an ASCII string
                    ; and displays is in the 'Panel' area at the bottom of the screen.
                    ;
                    ; Doesn't appear to be in use by the code.
                    ; This code would be better suited as part of the Panel.s code.
                    ;
                    ; IN:
                    ;   d0 - 16bit value to be converted to ASCII characters for display
                    ;   d1 - Y,X co-ords for the display, 1 byte each.
                    ;
debug_display_params
L0000375C               dc.w $0a0a
L0000375E               dc.b '0000' 
L00003762               dc.b $00,$ff 

L00003764               LEA.L   debug_display_params,a0                 ;L0000375c,A0
L0000376A               MOVE.W  D1,(A0)
L0000376C               MOVE.L  #$00000003,D2

                    ; decode 4 nibbles to ASCII chars
L0000376E               CLR.W   D1
L00003770               MOVE.W  D0,D1
L00003772               AND.W   #$000f,D1
L00003776               CMP.W   #$000a,D1
L0000377A               BCS.B   L0000377E
L0000377C               ADD.W   #$00000007,D1
L0000377E               ADD.B   #$30,D1
L00003782               MOVE.B  D1,$02(A0,D2.w)
L00003786               LSR.W   #$00000004,D0
L00003788               DBF.W   D2,L0000376E

                    ; calc destination display ptr 
L0000378C               MOVE.B  (A0)+,D0
L0000378E               CMP.B   #$ff,D0
L00003792               BEQ.B   L000037E2

L00003794               AND.W   #$00ff,D0
L00003798               MULU.W  #PANEL_DISPLAY_BYTEWIDTH,d0             ;#$0028,D0
L0000379C               MOVE.L  #$00000000,D1
L0000379E               MOVE.B  (A0)+,D1

L000037A0               ADD.W   D1,D0
L000037A2               MOVEA.L #PANEL_GFX,a1                           ;#$0007c89a,A1       ; Panel
L000037A8               LEA.L   $02(A1,D0.w),A1

                    ; get char for display 
L000037AC               MOVE.L  #$00000000,D0
L000037AE               MOVE.B  (A0)+,D0
L000037B0               BEQ.B   L0000378C

                    ; calc source gfx ptr 
L000037B2               SUB.W   #ASCII_SPACE,d0                         ;#$0020,D0
L000037B6               LSL.W   #$00000003,D0
L000037B8               LEA.L   font8x8,a2                              ;L000037e4,A2
L000037BE               LEA.L   $00(A2,D0.w),A2

                    ; initialise print char loop
L000037C2               MOVE.L  #FONT_8x8_HEIGHT-1,d7                   ;#$00000007,D7
L000037C4               MOVEA.L A1,A3
                    ; write gfx char to display - one raster line at a time
L000037C6               MOVE.B  (A2),(A3)
L000037C8               MOVE.B  (A2),PANEL_DISPLAY_BITPLANEBYTES(a3)    ;$0780(A3)
L000037CC               MOVE.B  (A2),2*PANEL_DISPLAY_BITPLANEBYTES(a3)  ;$0f00(A3)
L000037D0               MOVE.B  (A2)+,3*PANEL_DISPLAY_BITPLANEBYTES(a3) ;$1680(A3)
L000037D4               LEA.L    PANEL_DISPLAY_BYTEWIDTH(a3),a3         ;$0028(A3),A3
L000037D8               DBF.W   D7,L000037C6
                    ; set up next char for display
L000037DC               LEA.L   $0001(A1),A1
L000037E0               BRA.B   L000037AC
L000037E2               RTS 


                    ; -------------------------- 8x8 pixel font ----------------------
                    ; This font is used by the routine above.
                    incdir  ./gfx/
                    include font8x8.s


                    ; active actors (potentially offscreen)
                    ; list of structures
                    ; original format (22 bytes): 220 bytes (10 entries)
                    ;
                    ; new format (24 bytes): 240 bytes (10 entries) - updated for long address pointers
                    ;
                    ;   Offset  |    Descripton
                    ;   ----------------------
                    ;   0-1     | Actor Id/Status - $0001 = killed
                    ;   2-3     | Actor X
                    ;   4-5     | Actor Y
                    ;   8
                    ;   12
                    ;   14-15   | Actor X - Centre?
                    ;   16-17   | Actor Y - Top
                    ;   18-19   | Actor Y - Bottom
                    ;   20-23   | (long updated from word) Address of actor data structure
                    ;
                    ; 
ACTORSTRUCT_INIT_DATA   EQU     $0
ACTORSTRUCT_STATUS      EQU     $0                          ; offset 0 used for Actor Status $0001 = killed
ACTORSTRUCT_XY          EQU     $2                          ; offset used for long reads of X & Y
ACTORSTRUCT_X           EQU     $2                          ; offset used for word reads of X
ACTORSTRUCT_Y           EQU     $4                          ; offset used for word reads of Y
ACTORSTRUCT_ANIMFRAME   EQU     $8                          ; 16 bits animation frame
ACTORSTRUCT_SPRITES_IDX EQU     $a                          ; offset 10 - set to -4 $fffc when hit by bat-a-rang
ACTORSTRUCT_X_CENTRE    EQU     $e                          ; offset 14 - actor X centre?
ACTORSTRUCT_Y_TOP       EQU     $10                         ; offset 16 - actor Y Top
ACTORSTRUCT_Y_BOTTOM    EQU     $12                         ; offset 18 - actor Y Bottom
ACTORSTRUCT_INIT_PTR    EQU     $14                         ; offset 20 - ptr to actor init data (trigger data)
ACTORLIST_STRUCT_SIZE   EQU     $18                         ;  new size #$18 (24 bytes) - original size #$16 (22 bytes) -
ACTORLIST_SIZE          EQU     ACTORLIST_STRUCT_SIZE*10    ; original size (220 bytes) - new size 240 bytes

actors_list         ; original address L000039BC
L000039BC               dc.w $0000
                        dc.w $0119
                        dc.w $003A
                        dc.w $0097
                        dc.w $0000
                        dc.w $0000
                        dc.w $0000
                        dc.w $0000
                        dc.w $0000
                        dc.w $0000
                        dc.l $00000000

                        dc.w $0000
                        dc.w $00A0
                        dc.w $0038
                        dc.w $0046
                        dc.w $0000
                        dc.w $0000
                        dc.w $0000
                        dc.w $0000
                        dc.w $0000
                        dc.w $0000
                        dc.l $00000000

                        dc.w $0000
                        dc.w $00A0
                        dc.w $0038
                        dc.w $0046
                        dc.w $0000
                        dc.w $0000
                        dc.w $0000
                        dc.w $0000
                        dc.w $0000
                        dc.w $0000
                        dc.l $00000000

                        dc.w $0000
                        dc.w $00A0
                        dc.w $0038
                        dc.w $0046
                        dc.w $0000
                        dc.w $0000
                        dc.w $0000
                        dc.w $0000
                        dc.w $0000
                        dc.w $0000
                        dc.l $00000000

                        dc.w $0000
                        dc.w $00A0
                        dc.w $0038
                        dc.w $0046
                        dc.w $0000
                        dc.w $0000
                        dc.w $0000
                        dc.w $0000
                        dc.w $0000
                        dc.w $0000
                        dc.l $00000000

                        dc.w $0000
                        dc.w $00A0
                        dc.w $0038
                        dc.w $0046
                        dc.w $0000
                        dc.w $0000
                        dc.w $0000
                        dc.w $0000
                        dc.w $0000
                        dc.w $0000
                        dc.l $00000000

                        dc.w $0000
                        dc.w $00A0
                        dc.w $0038
                        dc.w $0046
                        dc.w $0000
                        dc.w $0000
                        dc.w $0000
                        dc.w $0000
                        dc.w $0000
                        dc.w $0000
                        dc.l $00000000

                        dc.w $0000
                        dc.w $00A0
                        dc.w $0038
                        dc.w $0046
                        dc.w $0000
                        dc.w $0000
                        dc.w $0000
                        dc.w $0000
                        dc.w $0000
                        dc.w $0000
                        dc.l $00000000

                        dc.w $0000
                        dc.w $00A0
                        dc.w $0038
                        dc.w $0046
                        dc.w $0000
                        dc.w $0000
                        dc.w $0000
                        dc.w $0000
                        dc.w $0000
                        dc.w $0000
                        dc.l $00000000

last_active_actor       ; original address L00003A82
L00003A82               dc.w $0000
                        dc.w $00A0
                        dc.w $0038
                        dc.w $0046
                        dc.w $0000
                        dc.w $0000
                        dc.w $0000
                        dc.w $0000
                        dc.w $0000
                        dc.w $0000
                        dc.l $00000000


gotham_cathedral_text   ; original address L00003A98
L00003A98   
                    dc.b    $2a,$09
                    dc.b    'TEST BUILD 31/01/2025',$00
                    dc.b    $50,$09
                    dc.b    'GOTHAM CITY CATHEDRAL'
                    dc.b    $00,$ff  
                    
text_mouse_button   ; additional debug text             
                    dc.b    $70,$08
                    dc.b    'PRESS LEFT MOUSE BUTTON'
                    dc.b    $00,$ff   

the_end_text            ; original address L00003AB1
L00003AB1           dc.b    $40,$10
                    dc.b    'THE END.'
                    dc.b    $00,$FF

time_being_text         ; original address L00003ABD
L00003ABD           dc.b    $60,$0B
                    dc.b    'FOR THE TIME BEING.'
                    dc.b    $00,$FF

            even




                    ; ----------------------- start game ------------------------
                    ; Called after the system is initialised, initialise the
                    ; game level & play the game loop
                    ;
initialise_game    

                        ;jsr     _DEBUG_COLOURS

L00003AD4               CLR.L   frame_counter_and_target_counter    ;$000036e2
L00003ADA               BSR.W   double_buffer_playfield             ;L000036ee

L00003ADE               BSR.W   preprocess_data                     ;L00005922


L00003AE2               JSR     AUDIO_PLAYER_INIT                   ;$00048000       ; Audio
L00003AE8               CLR.W   level_spawn_point_index             ;L00006344
                IFD TEST_BUILD_LEVEL
                        jsr     PANEL_INIT_LIVES
                ENDC

                    ; restart point after batman dies
restart_level       ; L00003AEC
L00003AEC               CLR.W   grappling_hook_height               ;L00006360
L00003AF0               CLR.L   frame_counter_and_target_counter    ;L000036e2
L00003AF6               BSR.W   clear_display_memory                ;L0000373a

L00003AFA               MOVE.W  #CODE1_INITIAL_TIMER_BCD,d0         ;#$1200,D0
L00003AFE               JSR     PANEL_INIT_TIMER                    ;L0007c80e       ; Panel
L00003B04               JSR     PANEL_INIT_ENERGY                   ;L0007c854       ; Panel

L00003B0A               BSR.W   panel_fade_in                       ;L00003d2a


                        ;jsr     _DEBUG_COLOURS


                    ; ------------ modify level tile map ------------
                    ; Make data driven changes to level data blocks
                    ; doesn't appear to run on level 1.
                    ; Reads 3 words of data from address ptr L00005f64
                    ; d3 = index into level data
                    ; d2 = first value to write into level data
                    ; d4 = second value to write into level data
                    ;
                    ; Could be used for with game protection check to
                    ; alter the level to make it impossible to complete.
                    ; e.g. shorten platform, add/remove walls/doors etc
                    ;
update_level_data
L00003B0E               LEA.L   MAPGR_DATA_ADDRESS,a0               ;$0000807c,A0    ; Mapgr
L00003B14               MOVEA.L L00005FAC,A5
L00003B1A               MOVEM.W (A5)+,D2-D4
L00003B1E               TST.W D3
L00003B20               BEQ.B   L00003B38
L00003B22               MOVE.B  D2,$01(A0,D3.w)
L00003B26               LSR.W   #$08,D2
L00003B28               MOVE.B  D2,$00(A0,D3.w)
L00003B2C               MOVE.B  D4,$03(A0,D3.w)
L00003B30               LSR.W   #$08,D4
L00003B32               MOVE.B  D4,$02(A0,D3.w)
L00003B36               BRA.B   L00003B1A 
.exit_update_level_data   
L00003B38               MOVE.L  #L0000600C,L00005FAC



                    ; clear 40 longs (160 bytes)
                    ; data referenced by projectiles
clear_projectile_data 
L00003B42               LEA.L   projectile_list,a0          ;L000048d2,A0
L00003B46               MOVE.L  #$00000027,D7
L00003B48               CLR.L   (A0)+
L00003B4A               DBF.W   D7,L00003B48



                    ; ------------ reset actors/triggers -------------
                    ; clear MSB flag of each data structure
clear_msb 
L00003B4E               LEA.L   trigger_definitions_list,a0     ;L00006476,A0
L00003B52               BCLR.B  #$0007,(A0)
L00003B56               MOVE.W  $0004(A0),D0
L00003B5A               MULU.W  #$0006,D0
L00003B5E               LEA.L   $06(A0,D0.w),A0
L00003B62               CMPA.L  #end_of_trigger_list,a0         ;  #$6944,A0
L00003B66               BCS.B   L00003B52

                    ; clear MSB flag of each data structure
                    ; original address L00003b7e  
L00003B68               BCLR.B  #$0007,$0004(A0)
L00003B6E               ADDA.W  #$00000006,A0
L00003B70               CMPA.l  #end_of_actors,a0               ;#$69c2,A0
L00003B74               BCS.B   L00003B68




                    ; Clear Active Actors List? 
L00003B76               LEA.L   actors_list,a0                          ;L000039bc,A0
L00003B7A               MOVE.L  #(ACTORLIST_SIZE/2)-1,d7        ;#$0000006d,D7
L00003B7C               CLR.W   (A0)+
L00003B7E               DBF.W   D7,L00003B7C



                    ; ------ Set initial batman sprite ids ----- 
L00003B82               CLR.W   batman_sprite1_id                       ; L00006336
L00003B86               LEA.L   batman_sprite_anim_standing,a0          ;L0000641b,A0
L00003B8A               BSR.W   set_batman_sprites                      ;L00005470



                    ; ------ Set initial player control state ------
                    ; initial state is 'walking' on platform.
L00003B8E               MOVE.l  #player_move_commands,gl_jsr_address    ;#$00004c7c,L00003c7c



                    ; -------- set player spawn point --------
                    ; sets the player start location and display
                    ; window default values. 
                    ; Either start of level or halfway point.
L00003B94               LEA.L   spawn_point_parameters_0,a0             ;L000069c2,A0
L00003B98               MOVE.W  level_spawn_point_index,d6              ;L00006344,D6
L00003B9C               MOVE.L  #$00000006,D7
L00003B9E               LEA.L   level_parameters,a1                     ;L000069ec,A1
L00003BA2               MOVE.W  (A0)+,(A1)+
L00003BA4               DBF.W   D7,L00003BA2
L00003BA8               DBF.W   D6,L00003B9C


                        ; display level title & initialise back buffer
L00003BAC               LEA.L   gotham_cathedral_text,a0                ;L00003a98,A0
L00003BB0               BSR.W   large_text_plotter                      ;L000069fa
L00003BB4               BSR.W   double_buffer_playfield                 ;L000036ee

L00003BB8               BSR.W   initialise_offscreen_buffer             ;L000058ea
                        
L00003BBC               BSR.W   copy_offscreen_to_backbuffer            ;L00004ba0

L00003BC0               BSR.W   draw_batman_and_rope                    ;L00005604

                        ;jsr     _DEBUG_COLOURS
                        
                        ; wait for 1 second
L00003BC4               MOVE.L  #$00000032,D0
L00003BC6               BSR.W   wait_for_frame_count                    ;L00005ed4



                        ;jsr     _DEBUG_COLOURS

                        ; wait for 1 second
L00003BC4a               MOVE.L  #$00000032,D0
L00003BC6a               BSR.W   wait_for_frame_count                    ;L00005ed4


                        ; start music if selected
L00003BCA               BTST.B  #PANEL_ST2_MUSIC_SFX,PANEL_STATUS_2     ;#$0000,$0007c875    ; Panel
L00003BD2               BNE.B   L00003BDC

L00003BD4               MOVE.L  #$00000001,D0
L00003BD6               JSR     AUDIO_PLAYER_INIT_SONG                  ; $00048010           ; Audio?


                        ;jsr     _DEBUG_COLOURS



                        ; wipe screen to black
L00003BDC               BSR.W   screen_wipe_to_backbuffer               ;L00003caa
L00003BE0               CLR.L   frame_counter_and_target_counter        ;L000036e2




                    ; -----------------------------------------------------------------------------------------------------------
                    ;
                    ; Game Loop
                    ;
                    ; -----------------------------------------------------------------------------------------------------------

game_loop           ; original address L00003be4

                    ; ---------- Start Key press checks -----------
                    ;
                    ; 'F1'  -  Pause Game
                    ;           1) when paused 'ESC' = exit game
                    ;           2) any other key resumes the game
                    ; 'F2'  - Toggle Music/SFX
                    ; 'F10' - Skip Level (if cheat mode is active)
                    ;
L00003BE4               BSR.W   getkey                      ;L0000364e
L00003BE8               BEQ.B   end_of_key_checks           ;L00003c44

L00003BEA               CMP.W   #KEY_F1,d0                  ;#$0081,D0
L00003BEE               BNE.B   toggle_music_sfx            ;L00003c0c

game_pause_loop     ; game pause
L00003BF0               BSR.W   getkey                      ;L0000364e
L00003BF4               BEQ.B   game_pause_loop             ;L00003bf0

                        ; exit while paused
L00003BF6               CMP.W   #KEY_ESC,d0                 ;#$001b,D0
L00003BFA               BNE.B   toggle_music_sfx            ;L00003c0c

                        ; return to title screen
L00003BFC               BSR.W   screen_wipe_to_black                ;L00003ca6
L00003C00               BSET.B  #PANEL_ST2_GAME_OVER,PANEL_STATUS_2 ;#$0005,$0007c875           ; Panel
L00003C08               BRA.W   return_to_title_screen              ;L00004e3e
                                ; ***************************                 
                                ; ****** NEVER RETURNS ******
                                ; **** LOAD TITLE SCREEN ****
                                ; ***************************

toggle_music_sfx    ; L00003C0C
L00003C0C               CMP.W   #KEY_F2,d0                          ;#$0082,D0
L00003C10               BNE.B   L00003C32

                        ;toggle music/sfx
L00003C12               BCHG.B  #PANEL_ST2_MUSIC_SFX,PANEL_STATUS_2 ;#$0000,$0007c875    ; Panel
L00003C1A               BNE.B   init_music                          ;L00003c26

init_sfx                ;L00003C1C - sfx only
L00003C1C               JSR     AUDIO_PLAYER_INIT_SFX_1             ;$00048008           ; external
L00003C22               BRA.W   end_of_key_checks                   ;L00003c44

init_music              ;L00003C26 - init music
L00003C26               MOVE.L  #SFX_LEVEL_MUSIC,d0                 ;#$00000001,D0
L00003C28               JSR     AUDIO_PLAYER_INIT_SONG              ;$00048010           ; external
L00003C2E               BRA.W   end_of_key_checks                   ;L00003c44

                        ; check skip level cheat
L00003C32               CMP.W   #KEY_F10,d0                         ;#$008a,D0
L00003C36               BNE.B   end_of_key_checks                   ;L00003c44

L00003C38               BTST.B  #PANEL_ST2_CHEAT_ACTIVE,PANEL_STATUS_2  ;#$0007,$0007c875        ; Panel
L00003C40               BNE.W   cheat_complete_level                    ;L00005e7a
                            ; ***************************                 
                            ; ****** NEVER RETURNS ******
                            ; ****** LOAD LEVEL 02 ******
                            ; ***************************

                    ; --------- End of Key Press Checks ---------
end_of_key_checks   ; original address L00003C44


                    ;jmp     do_system_updates


                    ; -------- start of player state machine updates ------------
L00003C44               BTST.B  #PANEL_ST1_TIMER_EXPIRED,PANEL_STATUS_1 ;#$0000,$0007c874    ; Panel
L00003C4C               BNE.B   L00003C6A

                        ; tick panel update (level timer, score, energy etc)
L00003C4E               JSR     PANEL_UPDATE        ;$0007c800           ; panel
L00003C54               JSR     PANEL_UPDATE        ;$0007c800           ; panel

L00003C5A               BTST.B  #PANEL_ST1_TIMER_EXPIRED,PANEL_STATUS_1 ;#$0000,$0007c874    ; panel
L00003C62               BEQ.B   L00003C6A

L00003C64               MOVE.L  #$00000001,D6
L00003C66               BSR.W   batman_collision_state_machine  ;L00004d22

                    ; execute player state machine
L00003C6A               CLR.L   D0
L00003C6C               CLR.L   D1
L00003C6E               BSR.W   read_player_input               ;L00005894
L00003C72               MOVEM.W batman_xy_offset,d0-d1          ; L000069f2,D0-D1

                    ; ----- PLAYER STATE - SELF MODIFYING CODE -----
                    ; updated all over the place to run an alternative routine.
                    ; a bit of a state machine kinda update routine.
;L00003C78               JSR     L00004c7c
gl_jsr_instuction       ; original address L00003C78
L00003C78               dc.w    $4eb9                   ; JSR.L - opcode value
gl_jsr_address          ; original address L00003C7A
L00003C7A               dc.l    player_move_commands    ; Dest Address - Self Modified Code
                    ; ----- END OF SELF MODIFYING CODE -----



do_system_updates
L00003C7E               BSR.W   scroll_offscreen_buffer         ;L00004974
L00003C82               BSR.W   update_score_by_level_progress  ;L00003dbe
L00003C86               BSR.W   trigger_new_actors              ;L00003dec
L00003C8A               BSR.W   copy_offscreen_to_backbuffer    ;L00004ba0
L00003C8E               BSR.W   draw_batman_and_rope            ;L00005604
L00003C92               BSR.W   update_active_actors            ;L00003ed4
L00003C96               BSR.W   update_projectiles              ;L00004696
L00003C9A               BSR.W   draw_projectiles                ;L0000463c
L00003C9E               BSR.W   double_buffer_playfield         ;L000036ee

L00003CA2               BRA.W   game_loop                       ;L00003be4                       ; game_loop


                    ;-----------------------------------------------------
                    ;------------------ End of Game Loop -----------------
                    ;-----------------------------------------------------
                    ; code1.s - line1871







                    ; -------------- Wipe Screen to Black ----------------
                    ; Perform screen wipe to black.
                    ;   - Clears back buffer
                    ;   - falls through to screen_wipe_to_backbuffer
                    ;
screen_wipe_to_black    ; original address L00003ca6
L00003ca6               bsr.w clear_backbuffer_playfield        ;L00004e66

                    ; ---------------- Wipe Screen to Back buffer ---------------------
                    ; Gradually replace the current display buffer with the gfx from
                    ; the back buffer. Used to fade from display text to level gfx
                    ; at the start of the level. 'Axis Chemical Factory' screen on
                    ; start-up etc.
                    ; Probably works a bit like the CD randomise play, a psuedo random
                    ; generator which doesn't pick the same two numbers twice until
                    ; the entire sequence has been selected.
                    ;   - that particular routine would use the modulo of a prime
                    ;       number (much larger than the dataset) to loop through
                    ;       the data (wrapping around back to the start)
                    ;   - not sure if this does that, may take a look in the future.
                    ;   
                    ;   for now, knowing what the routine does it good enough.
                    ; 
screen_wipe_to_backbuffer   ; original address l00003caa
L00003caa               move.w  #$002a,d0
L00003cae               move.w  #$00ae,d1
L00003cb2               movem.l playfield_buffer_ptrs,a0-a1     ;L000036e6,a0-a1
L00003cb8               clr.w   d2
L00003cba               moveq   #$7f,d3
L00003cbc               and.w   d2,d3
L00003cbe               moveq   #$0f,d5
L00003cc0               lsr.w   #$01,d3
L00003cc2               bcc.b   L00003cc6
L00003cc4               moveq.l #$fffffff0,d5
L00003cc6               cmp.w   d0,d3
L00003cc8               bcc.b   L00003d1c
L00003cca               move.w  d2,d4
L00003ccc               lsr.w   #$05,d4
L00003cce               and.w   #$00fc,d4
L00003cd2               cmp.w   d1,d4
L00003cd4               bcc.b   L00003d1c
L00003cd6               mulu.w  d0,d4
L00003cd8               add.w   d3,d4
L00003cda               move.w  d2,-(a7) 
L00003cdc               move.w  d0,d3
L00003cde               mulu.w  d1,d3
L00003ce0               moveq   #$03,d7
L00003ce2               move.w  d4,-(a7) 
L00003ce4               moveq   #$03,d2
L00003ce6               move.w  $0002(a7),d6
L00003cea               cmp.w   #$1580,d6
L00003cee               bcs.b   L00003cf2
L00003cf0               moveq   #$01,d2
L00003cf2               move.b  d5,d6
L00003cf4               not.w   d6
L00003cf6               and.b   $00(a0,d4.w),d6
L00003cfa               move.b  d6,$00(a0,d4.w)
L00003cfe               move.b  d5,d6
L00003d00               and.b   $00(a1,d4.w),d6
L00003d04               or.b    $00(a0,d4.w),d6
L00003d08               move.b  d6,$00(a0,d4.w)
L00003d0c               add.w   d0,d4
L00003d0e               dbf.w   d2,L00003cf2
L00003d12               move.w  (a7)+,d4
L00003d14               add.w   d3,d4
L00003d16               dbf.w   d7,L00003ce2
L00003d1a               move.w  (a7)+,d2
L00003d1c               mulu.w  #$5555,d2
L00003d20               addq.w  #$01,d2
L00003d22               and.w   #$1fff,d2
L00003d26               bne.b   L00003cba
L00003d28               rts 




                    ;---------------------- panel fade in -----------------------
                    ; fades the panel colours from black to expected colours.
                    ; waits 4 frames between each fade loop.
                    ; loops 16 times, 64 frames fade in. approx 1 seconds.
                    ;
panel_fade_in       ; original address L00003d2a
L00003d2a               moveq   #$0f,d7
L00003d2c               lea.l   copper_panel_colors+2,a0    ;L00003252,a0
L00003d30               lea.l   panel_colours,a1            ;L00003294,a1
L00003d34               moveq   #$0f,d6
                    ; fade colour
L00003d36               move.w  (a0),d0
L00003d38               move.w  (a1)+,d1
L00003d3a               eor.w   d0,d1
                    ; fade blue
L00003d3c               moveq   #$0f,d2
L00003d3e               and.w   d1,d2
L00003d40               beq.b   L00003d44
L00003d42               addq.w  #$01,d0
                    ; fade green
L00003d44               moveq.l #$fffffff0,d2
L00003d46               and.b   d1,d2
L00003d48               beq.b   L00003d4e
L00003d4a               add.w   #$0010,d0
                    ; fade red
L00003d4e               and.w   #$0f00,d1
L00003d52               beq.b   L00003d58
L00003d54               add.w   #$0100,d0

                        ; store faded colour
L00003d58               move.w  d0,(a0)
                        ; next colour in copper
L00003d5a               addq.w  #$04,a0

                        ; fade next colour
L00003d5c               dbf.w   d6,L00003d36

                        ; wait 4 frames per fade
L00003d60               move.w  frame_counter,d0            ; L000036e2,d0
L00003d66               addq.w  #$04,d0
L00003d68               cmp.w   frame_counter,d0            ; L000036e2,d0
L00003d6e               bne.b   L00003d68
                        
                        ; fade in loop
L00003d70               dbf.w   d7,L00003d2c
L00003d74               rts



                    ;---------------------- panel fade out -----------------------
                    ; fades the panel colours to black.
                    ; waits 4 frames between each fade loop.
                    ; loops 16 times, 64 frames fade in. approx 1 seconds.
                    ;
panel_fade_out      ; original address L00003d76
L00003d76               moveq   #$0f,d7
L00003d78               lea.l   copper_panel_colors+2,a0    ;L00003252,a0
L00003d7c               moveq   #$0f,d6
L00003d7e               move.w  (a0),d0
                    ; fade blue
L00003d80               moveq   #$0f,d1
L00003d82               and.w   d0,d1
L00003d84               beq.b   L00003d88
L00003d86               subq.w  #$01,d0
                    ; fade green
L00003d88               move.w  #$00f0,d1
L00003d8c               and.w   d0,d1
L00003d8e               beq.b   L00003d94
L00003d90               sub.w   #$0010,d0
                    ; fade red
L00003d94               move.w  #$0f00,d1
L00003d98               and.w   d0,d1
L00003d9a               beq.b   L00003da0
L00003d9c               sub.w   #$0100,d0

                        ; store faded colour
L00003da0               move.w  d0,(a0)
                        ; get next colour in copper
L00003da2               addq.w  #$04,a0
                        ; fade next colour loop
L00003da4               dbf.w   d6,L00003d7e

                        ; wait for 4 frames per fade
L00003da8               move.w  frame_counter,d0            ;L000036e2,d0
L00003dae               addq.w  #$04,d0
L00003db0               cmp.w   frame_counter,d0            ;L000036e2,d0
L00003db6               bne.b   L00003db0

                        ; fade to black loop
L00003db8               dbf.w   d7,L00003d78
L00003dbc               rts  


                    ; ----------------- update score by level progress ------------------   
                    ; Update the score based on Y distance travelled through the level.
                    ;
update_score_by_level_progress  ; original address L00003dbe 
L00003dbe               clr.l   d0
L00003dc0               move.w  scroll_window_y_coord,d1        ;L000069ee,d1
L00003dc4               add.w   batman_y_offset,d1              ;L000069f4,d1
L00003dc8               sub.w   scroll_window_max_x_coord,d1    ;L000069f0,d1
L00003dcc               bpl.b   L00003dea

L00003dce               add.w   d1,scroll_window_max_x_coord    ;L000069f0
L00003dd2               neg.w   d1
L00003dd4               lsl.w   #$04,d1
L00003dd6               move.b  d1,d0
L00003dd8               bra.b   L00003dde

L00003dda               add.w   #$0100,d0
                    ; increase score
L00003dde               sub.w   #$0064,d1
L00003de2               bcc.b   L00003dda

L00003de4               jmp     PANEL_ADD_SCORE         ;$0007c82a           ; PANEL_ADD_SCORE
L00003dea               rts  



                    ; ---------------------- trigger-new-actors ----------------------
                    ; Processes the list of bad-guy triggers and list of 
                    ; gas-leaks/drips.
                    ; Spawns new actors if there is room to do so (max 10 at anytime)
                    ;
                    ;
                    ; Code CHecked 30/1/2025
                    ;
trigger_new_actors  ; original address L00003dec
L00003dec               movem.w scroll_window_xy_coord,d0-d1    ;L000069ec,d0-d1
L00003df2               lea.l   trigger_definitions_list,a0     ;L00006476,a0
                    ; do next trigger
L00003df6               movem.w (a0)+,d2-d3
L00003dfa               sub.w   d0,d2
L00003dfc               cmp.w   #$0098,d2
L00003e00               bcc.b   L00003e1e
L00003e02               sub.w   d1,d3
L00003e04               cmp.w   #$0050,d3
L00003e08               bcc.b   L00003e1e

                    ; trigger in window range
L00003e0a               bset.b  #$0007,-$0004(a0)
L00003e10               move.w  (a0)+,d7
L00003e12               subq.w  #$01,d7

                    ; spawn actor loop
L00003e14               bsr.w   spawn_new_actor                 ;L00003e62
L00003e18               dbf.w   d7,L00003e14
L00003e1c               bra.b   L00003e2a

                    ; skip to next trigger data
L00003e1e               move.w  (a0),d2
L00003e20               add.w   d2,d2
L00003e22               add.w   (a0),d2
L00003e24               add.w   d2,d2
L00003e26               lea.l   $02(a0,d2.w),a0

                    ; loop until end of list
L00003e2a               cmpa.l  #end_of_trigger_list,a0         ;#$00006944,a0
L00003e2e               bcs.b   L00003df6


                    ; ----------------------- trigger_gasleak_and_drips -------------------------
                    ; process list of 6 bytes (other actors - steam jets and toxic drips)
                    ;
                    ; IN:-
                    ;   a0.l = start of gasleak/drip trigger locations. (3 word structure per item)
                    ;
                    ; Code Checked 30/1/2025
                    ;
trigger_gasleak_and_drips   ; original address L00003e30 
L00003e30               sub.w   #$0010,d0
L00003e34               subq.w  #$08,d1

L00003e36               movem.w $02(a0),d2-d3
L00003e3c               sub.w   d0,d2
L00003e3e               cmp.w   #$00c0,d2
L00003e42               bcc.b   L00003e58           ; skip to next
L00003e44               sub.w   d1,d3
L00003e46               cmp.w   #$0060,d3
L00003e4a               bcc.b   L00003e58           ; skip to next
L00003e4c               bsr.w   spawn_new_actor                 ;L00003e62
L00003e50               bset.b  #$0007,-$0002(a0)
L00003e56               bra.b   L00003e5a           ; continue next

L00003e58               addq.w  #$06,a0

L00003e5a               cmpa.l  #end_of_actors,a0               ;#$000069c2,a0
L00003e5e               bcs.b   L00003e36
L00003e60               rts




                    ; -------------------- spawn new actor ------------------------
                    ; Adds new actor to list of actors for processing.
                    ; Includes a bit of a copy protection check also at the start.
                    ;
                    ; IN:
                    ;   d0.w = window scroll x
                    ;   d1.w = window scroll y
                    ;   a0.l = ptr to actor init data in trigger data
                    ;
                    ; Code Checked 30/1/2025
                    ;
spawn_new_actor     ; original address L00003e62
L00003e62               movem.w (a0)+,d2-d4

                        ; odd code - infinite loop - maybe protection check
L00003e66               cmp.w   $00000022,d0
L00003e6c               beq.b   L00003e6c
L00003e6e               nop

L00003e70               lea.l   actors_list,a6          ;L000039bc,a6
L00003e74               moveq   #$09,d6

L00003e76               tst.w   (a6)
L00003e78               beq.b   initialise_new_actor            ;L00003e84
L00003e7a               lea.l   ACTORLIST_STRUCT_SIZE(a6),a6    ;$0016(a6),a6
L00003e7e               dbf.w   d6,L00003e76
L00003e82               rts 




                    ; ----------------- initialise new actor ------------------
                    ; Sets up new actor in actor_list for processing each
                    ; game cycle.
                    ;
                    ; d2.w = actor init data
                    ; d3.w = actor init data
                    ; d4.w = actor init data
                    ; a6.l = address of blank entry in actors_list
                    ; a0.l = ptr to actor init data in trigger data
                    ;
;ACTORSTRUCT_STATUS      EQU     $0                          ; offset 0 used for Actor Status $0001 = killed
;ACTORSTRUCT_XY          EQU     $2                          ; offset used for long reads of X & Y
;ACTORSTRUCT_X           EQU     $2                          ; offset used for word reads of X
;ACTORSTRUCT_Y           EQU     $4                          ; offset used for word reads of Y
;ACTORSTRUCT_SPRITES_IDX EQU     $a                          ; offset 10 - set to -4 $fffc when hit by bat-a-rang
;ACTORSTRUCT_X_CENTRE    EQU     $e                          ; offset 14 - actor X centre?
;ACTORSTRUCT_Y_TOP       EQU     $10                         ; offset 16 - actor Y Top
;ACTORSTRUCT_Y_BOTTOM    EQU     $12                         ; offset 18 - actor Y Bottom
;ACTORSTRUCT_INIT_PTR    EQU     $14                         ; offset 20 - ptr to actor init data (trigger data)
;ACTORLIST_STRUCT_SIZE   EQU     $18                         ; new size #$18 (24 bytes) - original size #$16 (22 bytes) -
;ACTORLIST_SIZE          EQU     ACTORLIST_STRUCT_SIZE*10    ; original size (220 bytes) - new size 240 bytes

initialise_new_actor    ; original address L00003e84
L00003e84               move.l  a0,ACTORSTRUCT_INIT_PTR(a6)         ;$0014(a6)
L00003e88               bset.l  #$000f,d2
L00003e8c               movem.w d2-d4,(a6)                          ;(a6)
L00003e90               clr.l   $0008(a6)
L00003e94               bclr.l  #$000f,d2
L00003e98               clr.l   $0010(a6)

L00003e9c               lea.l   actor_init_data,a5      ;L00005aba,a5
L00003ea0               cmp.w   (a5)+,d2
L00003ea2               bcs.b   L00003ea8
L00003ea4               addq.l  #$02,a5
L00003ea6               bra.b   L00003ea0

L00003ea8               move.w  (a5),d3
L00003eaa               cmp.w   #$00c5,d3
L00003eae               bne.b   L00003ebe

L00003eb0               bsr.w   L00003ec4
L00003eb4               btst.l  #$000c,d2
L00003eb8               beq.b   L00003ebe
L00003eba               move.w  #$010e,d3

L00003ebe               move.w  d3,$0006(a6)
L00003ec2               rts 

L00003ec4               movea.l L0000636a,a1
L00003eca               move.w  (a1)+,d2
L00003ecc               move.l  a1,L0000636a
L00003ed2               rts  




                    ;-----------------------------------------------------------------------------------------------
                    ; -- Update Level Actors 02
                    ;-----------------------------------------------------------------------------------------------
                    ; called from game_loop every cycle.
                    ;
update_active_actors    ; original address L00003ed4 
L00003ed4               lea.l   actors_list,a6                  ;L000039bc,a6
L00003ed8               moveq   #$09,d7

process_next_actor  ;L00003eda
L00003eda               move.w  (a6),d6
L00003edc               beq.w   skip_to_next_actor              ;L00003f96

                    ; calc actor co-ords
calc_actor_coords   ;L00003ee0
L00003ee0               movem.w ACTORSTRUCT_XY(a6),d0-d1        ;$0002(a6),d0-d1
L00003ee6               move.w  d0,d4
L00003ee8               movem.w scroll_window_xy_coord,d2-d3    ;L000069ec,d2-d3
L00003eee               sub.w   d2,d0
L00003ef0               sub.w   d3,d1

                    ; check actor x in window/range
actor_check_x       ; L00003ef2
L00003ef2               cmp.w   #$0140,d0
L00003ef6               bcs.b   actor_check_y                   ;L00003efe
L00003ef8               cmp.w   #$ff60,d0
L00003efc               bcs.b   forget_actor                    ;L00003f1c

actor_check_y       ; check actor y in window/range
L00003efe               cmp.w   #$00a0,d1
L00003f02               bcs.b   actor_in_range                  ;L00003f0a
L00003f04               cmp.w   #$ffb0,d1
L00003f08               bcs.b   forget_actor                    ;L00003f1c

actor_in_range      ;L00003f0a
L00003f0a               bclr.b  #$07,(a6)
L00003f0e               beq.b   execute_handler                 ;L00003f36
                    ; check actor is in display window
L00003f10               cmp.w   #$0050,d1
L00003f14               bcc.b   execute_handler                 ;L00003f36

L00003f16               cmp.w   #$00a0,d0
L00003f1a               bcc.b   execute_handler                 ;L00003f36

                    ;actor is out of bounds forget about it
forget_actor        ; L00003f1c
L00003f1c               cmp.w   #$0014,d6
L00003f20               bcs.b   remove_actor                    ;L00003f32

                    ; this code kills off actors out of scene
L00003f22               lea.l   $00000000,a0
L00003f26               movea.l d0,a0
L00003f28               movea.l ACTORSTRUCT_INIT_PTR(a6),a0     ;$0014(a6),a0
L00003f2c               bclr.b  #$07,-$0002(a0)

remove_actor            ;L00003f32
L00003f32               clr.w   (a6)
L00003f34               bra.b   skip_to_next_actor    ; L00003f96   ; skip to next

execute_handler         ;L00003f36
L00003f36               lea.l   actor_handler_table,a0  ;L00005ae2,a0
L00003f3a               add.w   d6,d6
L00003f3aa              add.w   d6,d6
L00003f3c               adda.w  d6,a0
L00003f3e               movea.l (a0),a0
L00003f40               move.w  d7,-(a7)
                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
L00003f42               jsr     (a0)

                    ; L00003f44 - check batman collision with actor?
L00003f44               movem.w $000e(a6),d0-d2
L00003f4a               sub.w   batman_x_offset,d0      ;L000069f2,d0
L00003f4e               addq.w  #$06,d0
L00003f50               cmp.w   #$000d,d0
L00003f54               bcc.b   L00003f94

L00003f56               sub.w   batman_y_bottom,d1      ;L00006338,d1
L00003f5a               subq.w  #$06,d1
L00003f5c               bmi.b   L00003f94

L00003f5e               sub.w   batman_y_offset,d2      ;L000069f4,d2
L00003f62               bpl.b   L00003f94

L00003f64               move.w  (a6),d0
L00003f66               subq.w  #$02,d0
L00003f68               bmi.b   L00003f94

L00003f6a               move.w  #$0001,(a6)
L00003f6e               moveq   #SFX_GUYHIT,d0                  ;#$0a,d0                 ; SFX_GUYHIT
L00003f70               jsr     AUDIO_PLAYER_INIT_SFX           ;$00048014               ; AUDIO_PLAYER_INIT_SFX
L00003f76               move.w  #$fffe,$000a(a6)

L00003f7c               tst.w   L00006342
L00003f80               bmi.b   L00003f94

L00003f82               tst.w   grappling_hook_height           ;L00006360
L00003f86               beq.b   L00003f8e

L00003f88               tst.w   batman_swing_speed              ;L0000633c
L00003f8c               bne.b   L00003f94

L00003f8e               moveq   #$05,d6
L00003f90               bsr.w   batman_lose_energy              ;L00004d0a

                        ; do next actor - pop counter
L00003f94               move.w  (a7)+,d7
                        ; next actor
skip_to_next_actor      ; L00003f96
L00003f96               lea.l   ACTORLIST_STRUCT_SIZE(a6),a6    ;$0016(a6),a6
L00003f9a               dbf.w   d7,process_next_actor           ; L00003eda
L00003f9e               rts  


                    ; ---------- calculate grenade inital drop speed ----------
                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
                    ;
;ACTORSTRUCT_STATUS      EQU     $0                          ; offset 0 used for Actor Status $0001 = killed
;ACTORSTRUCT_XY          EQU     $2                          ; offset used for long reads of X & Y
;ACTORSTRUCT_X           EQU     $2                          ; offset used for word reads of X
;ACTORSTRUCT_Y           EQU     $4                          ; offset used for word reads of Y
;ACTORSTRUCT_SPRITES_IDX EQU     $a                          ; offset 10 - set to -4 $fffc when hit by bat-a-rang
;ACTORSTRUCT_X_CENTRE    EQU     $e                          ; offset 14 - actor X centre?
;ACTORSTRUCT_Y_TOP       EQU     $10                         ; offset 16 - actor Y Top
;ACTORSTRUCT_Y_BOTTOM    EQU     $12                         ; offset 18 - actor Y Bottom
;ACTORLIST_STRUCT_SIZE   EQU     $18                         ;  new size #$18 (24 bytes) - original size #$16 (22 bytes) -
;ACTORLIST_SIZE          EQU     ACTORLIST_STRUCT_SIZE*10    ; original size (220 bytes) - new size 240 bytes

calc_grenade_speed  ; original address L00003fa0
L00003fa0               add.w   #$0002,(a6)
L00003fa4               movem.w batman_x_offset,d2      ;L000069f2,d2
L00003faa               move.w  batman_y_bottom,d3      ;L00006338,d3
L00003fae               add.w   #$0015,d3
L00003fb2               sub.w   d1,d3
L00003fb4               asl.w   #$03,d3
L00003fb6               ext.l   d3

L00003fb8               sub.w   d0,d2
L00003fba               bpl.b   L00003fbe
L00003fbc               neg.w   d2
L00003fbe               beq.b   L00003fc2
L00003fc0               divs.w  d2,d3
L00003fc2               asr.w   #$02,d2
L00003fc4               sub.w   d2,d3

L00003fc6               bsr.w   get_empty_projectile        ;L0000467c
L00003fca               cmp.w   #$0008,d3
L00003fce               bcs.b   L00003fde
L00003fd0               bmi.b   L00003fd6
L00003fd2               moveq   #$08,d3
L00003fd4               bra.b   L00003fde

L00003fd6               cmp.w   #$ffe8,d3
L00003fda               bcc.b   L00003fde
L00003fdc               moveq.l #$ffffffe8,d3

L00003fde               move.w  d3,$0006(a0)
L00003fe2               cmp.w   #$0073,d1
L00003fe6               bpl.b   L00003ff8
L00003fe8               movem.w d0-d1,-(a7)
L00003fec               moveq   #SFX_GRENADE,d0                 ;#$09,d0             ; SFX_GRENADE
L00003fee               jsr     AUDIO_PLAYER_INIT_SFX           ;$00048014           ; AUDIO_PLAYER_INIT_SFX
L00003ff4               movem.w (a7)+,d0-d1
L00003ff8               rts  



                    ; ---------------------- actor throw a grenade left ------------------
                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
                    ;
;ACTORSTRUCT_STATUS      EQU     $0                          ; offset 0 used for Actor Status $0001 = killed
;ACTORSTRUCT_XY          EQU     $2                          ; offset used for long reads of X & Y
;ACTORSTRUCT_X           EQU     $2                          ; offset used for word reads of X
;ACTORSTRUCT_Y           EQU     $4                          ; offset used for word reads of Y
;ACTORSTRUCT_ANIMFRAME   EQU     $8                          ; 16 bits animation frame
;ACTORSTRUCT_SPRITES_IDX EQU     $a                          ; offset 10 - set to -4 $fffc when hit by bat-a-rang
;ACTORSTRUCT_X_CENTRE    EQU     $e                          ; offset 14 - actor X centre?
;ACTORSTRUCT_Y_TOP       EQU     $10                         ; offset 16 - actor Y Top
;ACTORSTRUCT_Y_BOTTOM    EQU     $12                         ; offset 18 - actor Y Bottom
;ACTORLIST_STRUCT_SIZE   EQU     $18                         ;  new size #$18 (24 bytes) - original size #$16 (22 bytes) -
;ACTORLIST_SIZE          EQU     ACTORLIST_STRUCT_SIZE*10    ; original size (220 bytes) - new size 240 bytes

actor_cmd_grenade_left_01   ; original address L00003FFA
                    ; do throw animation
L00003ffa               move.w  ACTORSTRUCT_ANIMFRAME(a6),d2    ;$0008(a6),d2
L00003ffe               cmp.w   #$0007,d2
L00004002               bne.b   L0000401c

                    ; do create new grenade
L00004004               subq.w  #$05,d0
L00004006               bsr.w   calc_grenade_speed              ;L00003fa0
L0000400a               move.w  #$000d,(a0)+
L0000400e               move.w  d1,d3
L00004010               sub.w   #$0011,d3
L00004014               movem.w d0/d3,(a0)
L00004018               addq.w  #$05,d0

                    ; draw final actor animation frame
L0000401a               moveq   #$08,d2
                    ; draw actor animation frame
L0000401c               addq.w  #$01,$0008(a6)
L00004020               lea.l   L00004512,a5
L00004024               and.w   #$00fe,d2
L00004028               adda.w  d2,a5
L0000402a               add.w   d2,d2
L0000402c               adda.w  d2,a5
L0000402e               bra.w   drawcollide_actor_sprites_a5    ;L000045ba
 ; use rts in 'drawcollide_actor_sprites_a5' to return



                    ; called when green-guy throws a grenade
                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
                    ;
actor_cmd_grenade_left_02   ; original address L00004032
L00004032           lea.l   throw_grenade_left,a5           ;L0000452a,a5
L00004036           bsr.w   drawcollide_actor_sprites_a5    ;L000045ba       ; drawcollide_actor_sprites_a5
L0000403a           subq.w  #$01,$0008(a6)
L0000403e           bne.b   L0000404a
L00004040           move.w  #$0020,$0008(a6)
L00004046           move.w  #$0002,(a6)
L0000404a           rts  


                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
actor_cmd_green_walk_left   ; original address L0000404C
L0000404c               cmp.w   #$ffc0,d0
L00004050               bmi.b   L0000409e
L00004052               subq.w  #$01,$0008(a6)
L00004056               bpl.b   L00004070
L00004058               move.w  d0,d2
L0000405a               sub.w   batman_x_offset,d2     ;L000069f2,d2
L0000405e               cmp.w   #$0030,d2
L00004062               bcc.b   L00004070
L00004064               clr.w   $0008(a6)
L00004068               move.w  #$0005,(a6)
L0000406c               bra.w   L0000432a

L00004070               moveq   #$07,d2
L00004072               and.w   d4,d2
L00004074               bne.w   L00004324
L00004078               sub.w   #$000c,d0
L0000407c               bsr.w   get_map_tile_at_display_offset_d0_d1    ; L000055e0
L00004080               add.w   #$000c,d0
L00004084               cmp.b   #$51,d2
L00004088               bcc.w   L00004324
L0000408c               tst.w   $0008(a6)
L00004090               bpl.b   L0000409e
L00004092               move.w  d0,d2
L00004094               sub.w   batman_x_offset,d2     ;L000069f2,d2
L00004098               cmp.w   #$0040,d2
L0000409c               bcs.b   L00004064

L0000409e               move.w  #$0002,(a6)
L000040a2               bra.w   L0000432a




                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
actor_cmd_grenade_right_01  ; original address L000040A6
L000040a6               move.w  $0008(a6),d2
L000040aa               cmp.w   #$0007,d2
L000040ae               bne.b   L000040c8
L000040b0               addq.w  #$05,d0
L000040b2               bsr.w   calc_grenade_speed              ;L00003fa0
L000040b6               move.w  #$000c,(a0)+
L000040ba               move.w  d1,d3
L000040bc               sub.w   #$0011,d3
L000040c0               movem.w d0/d3,(a0)
L000040c4               subq.w  #$05,d0
L000040c6               moveq   #$08,d2
L000040c8               addq.w  #$01,$0008(a6)
L000040cc               lea.l   throw_grenade_right,a5          ;L00004530,a5
L000040d0               and.w   #$00fe,d2
L000040d4               adda.w  d2,a5
L000040d6               add.w   d2,d2
L000040d8               adda.w  d2,a5
L000040da               bra.w   drawcollide_actor_sprites_a5    ;L000045ba



                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
actor_cmd_grenade_right_02  ; original address L000040DE
L000040de               lea.l   L00004548,a5
L000040e2               bsr.w   drawcollide_actor_sprites_a5    ;L000045ba
L000040e6               subq.w  #$01,$0008(a6)
L000040ea               bne.b   L000040f6
L000040ec               move.w  #$0020,$0008(a6)
L000040f2               move.w  #$0003,(a6)
L000040f6               rts  



                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
                    ;
                    ; Code Checked 29/1/2025
                    ;
actor_cmd_green_walk_right  ; original address L000040F8
L000040f8               cmp.w   #$00e0,d0
L000040fc               bpl.b   L00004146
L000040fe               subq.w  #$01,$0008(a6)
L00004102               bpl.b   L0000411c
L00004104               move.w  batman_x_offset,d2     ;L000069f2,d2
L00004108               sub.w   d0,d2
L0000410a               cmp.w   #$0030,d2
L0000410e               bcc.b   L0000411c
L00004110               clr.w   $0008(a6)
L00004114               move.w  #$0004,(a6)
L00004118               bra.w   L00004254

L0000411c               moveq   #$07,d2
L0000411e               and.w   d4,d2
L00004120               bne.w   L0000424e
L00004124               addq.w  #$08,d0
L00004126               bsr.w   get_map_tile_at_display_offset_d0_d1    ; L000055e0
L0000412a               subq.w  #$08,d0
L0000412c               cmp.b   #$51,d2
L00004130               bcc.w   L0000424e 
L00004134               tst.w   $0008(a6)

L00004138               bpl.b   L00004146 
L0000413a               move.w  batman_x_offset,d2                      ;L000069f2,d2
L0000413e               sub.w   d0,d2
L00004140               cmp.w   #$0040,d2
L00004144               bcs.b   L00004110
L00004146               move.w  #$0003,(a6)
L0000414a               bra.w   L00004254
L0000414e               move.w  batman_y_offset,d5                      ;L000069f4,d5
L00004152               sub.w   d1,d5
L00004154               add.w   #$0010,d5
L00004158               btst.b  #$0002,$0003(a6) 
L0000415e               beq.b   L000041ac
L00004160               cmp.w   #$0020,d5
L00004164               bcs.b   L000041ac 
L00004166               bpl.b   L0000417a 
L00004168               move.w  MAPGR_BASE,d2           ;$00008002,d2          ; MAPGR_BASE (width)
L0000416e               add.w   d2,d2
L00004170               add.w   d2,d2
L00004172               sub.w   d2,d3
L00004174               clr.w   d2

L00004176               move.b  $00(a0,d3.w),d2

                        ; different from code1.s
L0000417a               cmp.b   #$5f,d2
L0000417e               bcs.b   L000041ac
L00004180               move.b  $01(a0,d3.w),d2
L00004184               btst.b  #$0000,$0001(a6)
L0000418a               bne.b   L00004190
L0000418c               move.b  -$01(a0,d3.w),d2
L00004190               cmp.b   #$5f,d2
L00004194               bcs.b   L000041ac
L00004196               move.w  #$0002,$0008(a6)
L0000419c               move.w  #$000d,$000c(a6)
L000041a2               subq.w  #$08,d5
L000041a4               bpl.b   L000041ac
L000041a6               move.w  #$000c,$000c(a6)
L000041ac               rts  



                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
                    ;
                    ; Code Checked 29/1/2025
                    ;
actor_cmd_actor_brown_walk_right    ; original address L000041AE
L000041ae               move.w  d4,d2
L000041b0               addq.w  #$04,d2
L000041b2               and.w   #$0007,d2
L000041b6               bne.w   L0000424e
L000041ba               cmp.w   #$0140,d0
L000041be               bpl.b   L000041ce
L000041c0               addq.w  #$07,d0
L000041c2               bsr.w   get_map_tile_at_display_offset_d0_d1    ; L000055e0     ; get_map_tile_at_display_offset_d0_d1
L000041c6               subq.w  #$07,d0
L000041c8               cmp.b   #$51,d2
L000041cc               bcc.b   L000041da
L000041ce               move.w  #$000f,(a6)
L000041d2               clr.w   $0008(a6)
L000041d6               bra.w   L0000424e
L000041da               bsr.w   L0000414e
L000041de               subq.w  #$01,$0008(a6)
L000041e2               beq.w   L00004354
L000041e6               bpl.b   L0000424e
L000041e8               move.w  batman_x_offset,d2     ;L000069f2,d2
L000041ec               sub.w   d0,d2

L000041ee               bmi.b   L0000424e
L000041f0               cmp.w   #$0020,d5
L000041f4               bpl.b   L00004230
L000041f6               bcc.b   L0000420e
L000041f8               cmp.w   #$0038,d2
L000041fc               bcc.b   L0000424e 
L000041fe               move.w  #$0010,$000c(a6)
L00004204               move.l  #$00010000,$0008(a6)
L0000420c               bra.b   L0000424e
L0000420e               sub.w   #$0010,d5
L00004212               add.w   d5,d2
L00004214               ble.b   L0000424e
L00004216               subq.w  #$04,d2
L00004218               lsr.w   #$03,d2
L0000421a               addq.w  #$01,d2
L0000421c               cmp.w   #$0008,d2
L00004220               bcc.b   L0000424e
L00004222               move.w  d2,$0008(a6)
L00004226               move.l  #$00050010,$000a(a6)        ; external address?
L0000422e               bra.b   L0000424e

L00004230               subq.w  #$08,d5
L00004232               sub.w   d5,d2
L00004234               bls.b   L0000424e
L00004236               subq.w  #$04,d2
L00004238               lsr.w   #$03,d2
L0000423a               addq.w  #$01,d2
L0000423c               cmp.w   #$0008,d2
L00004240               bcc.b   L0000424e
L00004242               move.w  d2,$0008(a6)
L00004246               move.l  #$00070010,$000a(a6)    ; external address?
L0000424e               addq.w  #$01,d4
L00004250               move.w  d4,$0002(a6)
L00004254               and.w   #$000e,d4
L00004258               lsr.w   #$01,d4
L0000425a               move.w  d4,-(a7)
L0000425c               addq.w  #$08,d4
L0000425e               move.w  d4,d2
L00004260               bsr.w   draw_next_sprite        ;L000045fa               ; draw next sprite
L00004264               move.w  (a7)+,d2
L00004266               lsr.w   #$01,d2

L00004268               bne.b   L0000426c
L0000426a               addq.w  #$02,d2
L0000426c               addq.w  #$04,d2
L0000426e               bsr.w   draw_next_sprite                ;L000045fa
L00004272               moveq   #$04,d2
L00004274               bra.w   actor_collision_and_sprite1     ;L000045c8



                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
                    ;
                    ; Code Checked 29/1/2025
                    ;
actor_cmd_brown_walk_left_15_23   ; original address L00004278
L00004278               move.w  d4,d2
L0000427a               addq.w  #$04,d2
L0000427c               and.w   #$0003,d2
L00004280               bne.w   L00004324 
L00004284               cmp.w   #$ff60,d0
L00004288               bmi.b   L000042a4
L0000428a               subq.w  #$07,d0
L0000428c               bsr.w   get_map_tile_at_display_offset_d0_d1    ; L000055e0       ; get_map_tile_at_display_offset_d0_d1
L00004290               addq.w  #$07,d0
L00004292               cmp.b   #$51,d2

L00004296               bcc.b   L000042b0 
L00004298               move.w  $0006(a6),d2
L0000429c               cmp.w   #$0085,d2
L000042a0               beq.w   L00004448 
L000042a4               move.w  #$000e,(a6)
L000042a8               clr.w   $0008(a6)
L000042ac               bra.w   L00004324
L000042b0               bsr.w   L0000414e
L000042b4               subq.w  #$01,$0008(a6)
L000042b8               beq.w   L00004354

L000042bc               bpl.b   L00004324
L000042be               move.w  d0,d2
L000042c0               sub.w   batman_x_offset,d2     ;L000069f2,d2
L000042c4               bmi.b   L00004324
L000042c6               cmp.w   #$0020,d5
L000042ca               bpl.b   L00004306
L000042cc               bcc.b   L000042e4
L000042ce               cmp.w   #$0038,d2
L000042d2               bcc.b   L00004324
L000042d4               move.w  #$0010,$000c(a6)

L000042da               move.l  #$00010001,$0008(a6)            ; external address?
L000042e2               bra.b   L00004324 
L000042e4               sub.w   #$0010,d5
L000042e8               add.w   d5,d2
L000042ea               ble.b   L00004324
L000042ec               subq.w  #$04,d2
L000042ee               lsr.w   #$02,d2
L000042f0               addq.w  #$01,d2
L000042f2               cmp.w   #$0008,d2
L000042f6               bcc.b   L00004324

L000042f8               move.w  d2,$0008(a6)
L000042fc               move.l  #$00040010,$000a(a6)            ; external address?
L00004304               bra.b   L00004324
L00004306               subq.w  #$08,d5
L00004308               sub.w   d5,d2
L0000430a               bls.b   L00004324
L0000430c               subq.w  #$04,d2
L0000430e               lsr.w   #$02,d2
L00004310               addq.w  #$01,d2
L00004312               cmp.w   #$0008,d2
L00004316               bcc.b   L00004324
L00004318               move.w  d2,$0008(a6)
L0000431c               move.l  #$00060010,$000a(a6)            ; external address?
L00004324               subq.w  #$01,d4
L00004326               move.w  d4,$0002(a6)
L0000432a               and.w   #$000e,d4
L0000432e               lsr.w   #$01,d4
L00004330               eor.w   #$e007,d4
L00004334               move.w  d4,-(a7)
L00004336               addq.w  #$08,d4

L00004338               move.w  d4,d2
L0000433a               bsr.w   draw_next_sprite            ;L000045fa               ; draw next sprite
L0000433e               move.w  (a7)+,d2
L00004340               lsr.b   #$01,d2
L00004342               bne.b   L00004346
L00004344               addq.w  #$02,d2
L00004346               addq.w  #$04,d2
L00004348               bsr.w   draw_next_sprite            ;L000045fa               ; draw next sprite
L0000434c               move.w  #$e004,d2
L00004350               bra.w   actor_collision_and_sprite1     ;L000045c8
L00004354               move.w  $000c(a6),d6
L00004358               move.w  d6,(a6)
L0000435a               cmp.w   #$0010,d6
L0000435e               bne.b   L00004380
L00004360               move.w  #$0002,$0008(a6)
L00004366               move.w  $000a(a6),d2
L0000436a               cmp.w   #$0002,d2
L0000436e               bcc.b   L00004380
L00004370               move.w  $0012(a6),d2
L00004374               addq.w  #$04,d2

L00004376               sub.w   batman_y_bottom,d2              ;L00006338,d2
L0000437a               bpl.b   L00004380
L0000437c               addq.w  #$02,$000a(a6)

L00004380               lea.l   actor_handler_table,a0          ;L00005ae2,a0        ; actor_handler_table
L00004384               add.w   d6,d6
L00004384a              add.w   d6,d6               ; converted to long
L00004386               adda.w  d6,a0
L00004388               movea.l (a0),a0
L0000438a               jmp     (a0)



                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
                    ;
                    ; Differnet to Code1.s
actor_cmd_climb_down_ladder ; original address L0000438C
L0000438c               move.w  $0004(a6),d4
L00004390               btst.b  #$0000,playfield_swap_count+1           ;L00006375 
L00004396               bne.b   L000043b4
L00004398               addq.w  #$01,d4
L0000439a               move.w  d4,$0004(a6)
L0000439e               addq.w  #$01,d1
L000043a0               and.w   #$0007,d4
L000043a4               bne.b   L000043b4
L000043a6               bsr.w   get_map_tile_at_display_offset_d0_d1    ; L000055e0
                        ; Additional to code1.s
L000043aa               cmp.b   #$5f,d2
L000043ae               bcc.b   L000043b4
L000043b0               bsr.w   L0000443a
L000043b4               not.w   d4
L000043b6               and.w   #$0007,d4
L000043ba               subq.w  #$01,d0
L000043bc               move.w  d4,d2
L000043be               bclr.l  #$0002,d2
L000043c2               beq.b   L000043ca
L000043c4               or.w    #$e000,d2
L000043c8               addq.w  #$01,d0
L000043ca               add.w   #$0020,d2
L000043ce               move.w  d2,-(a7)
L000043d0               bsr.w   draw_next_sprite        ;L000045fa
L000043d4               move.w  (a7)+,d2
L000043d6               and.w   #$e000,d2
L000043da               add.w   #$001f,d2
L000043de               bra.w   actor_collision_and_sprite1     ;L000045c8 


                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
actor_cmd_climb_up_ladder   ; original address L000043E2
L000043e2               move.w  $0004(a6),d4
L000043e6               btst.b  #$0000,playfield_swap_count+1           ;L00006375 
L000043ec               bne.b   L0000440c
L000043ee               subq.w  #$01,d4
L000043f0               move.w  d4,$0004(a6)
L000043f4               subq.w  #$01,d1
L000043f6               and.w   #$0007,d4
L000043fa               bne.b   L0000440c 
L000043fc               subq.w  #$08,d1
L000043fe               bsr.w   get_map_tile_at_display_offset_d0_d1    ; L000055e0           ; get_map_tile_at_display_offset_d0_d1
L00004402               addq.w  #$08,d1

actor_cmd_climb_ladder_common   ; original address L00004404
L00004404               cmp.b   #$5f,d2
L00004408               bcc.b   L0000440c
L0000440a               bsr.b   L0000443a
L0000440c               not.w   d4
L0000440e               and.w   #$0007,d4
L00004412               subq.w  #$01,d0
L00004414               move.w  d4,d2
L00004416               bclr.l  #$0002,d2
L0000441a               beq.b   L00004422
L0000441c               or.w    #$e000,d2
L00004420               addq.w  #$01,d0
L00004422               add.w   #$001b,d2
L00004426               move.w  d2,-(a7)
L00004428               bsr.w   draw_next_sprite                ;L000045fa
L0000442c               move.w  (a7)+,d2
L0000442e               and.w   #$e000,d2
L00004432               add.w   #$001a,d2
L00004436               bra.w   actor_collision_and_sprite1     ;L000045c8
L0000443a               moveq   #$07,d2
L0000443c               moveq   #$4c,d3
L0000443e               sub.w   d0,d3
L00004440               add.w   d3,d3
L00004442               addx.w  d2,d2
L00004444               move.w  d2,(a6)
L00004446               rts 



L00004448               move.w  #$ffff,$0008(a6)
L0000444e               moveq   #$06,d2
L00004450               cmp.w   batman_y_bottom,d1              ;L00006338,d1
L00004454               bmi.b   L00004466
L00004456               moveq   #$01,d2
L00004458               move.w  $0012(a6),d3
L0000445c               addq.w  #$04,d3
L0000445e               cmp.w   batman_y_bottom,d3              ;L00006338,d3
L00004462               bpl.b   L00004466
L00004464               addq.w  #$02,d2
L00004466               move.w  d2,$000a(a6)
L0000446a               move.w  #$0010,(a6)


                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
actor_cmd_shooting_diagonally_01    ; original address L0000446E
L0000446e               bsr.w   drawcollide_sprites_from_actor_list_struct_0a   ;L000045ae
L00004472               subq.w  #$01,$0008(a6)
L00004476               bpl.b   L00004480
L00004478               addq.w  #$01,(a6)
L0000447a               move.w  #$0003,$0008(a6) 
L00004480               rts  


                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
actor_cmd_shooting_diagonally_02    ; original address L00004482
L00004482               bsr.w   drawcollide_sprites_from_actor_list_struct_0a   ;L000045ae           ; drawcollide_sprites_from_actor_list_struct_0a
L00004486               btst.b  #$0000,playfield_swap_count+1                   ;L00006375
L0000448e               bne.b   L00004480
L00004490               bsr.w   get_empty_projectile                            ;L0000467c
L00004494               sub.w   (a5)+,d1
L00004496               add.w   vertical_scroll_increments,d1                   ;L00006358,d1
L0000449a               add.w   (a5)+,d0
L0000449c               add.w   L00006356,d0
L000044a0               move.w  (a5),(a0)+
L000044a2               movem.w d0-d1,(a0)
L000044a6               moveq   #SFX_Ricochet,d2        ;#$0c,d2             ; SFX_Ricochet
L000044a8               bsr.w   play_proximity_sfx                              ;L000044f4 
L000044ac               subq.w  #$01,$0008(a6)
L000044b0               bne.b   L00004480
L000044b2               move.w  #$0006,$0008(a6)
L000044b8               addq.w  #$01,(a6)
L000044ba               rts  



                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
actor_cmd_shooting_horizontal   ; original address L000044BC
L000044bc               bsr.w   drawcollide_sprites_from_actor_list_struct_0a   ;L000045ae           ; drawcollide_sprites_from_actor_list_struct_0a
L000044c0               subq.w  #$01,$0008(a6)
L000044c4               bne.b   L00004480
L000044c6               move.w  #$0004,$0008(a6)
L000044cc               move.w  $000a(a6),d2
L000044d0               move.w  $0006(a6),d3
L000044d4               cmp.w   #$0085,d3
L000044d8               bne.b   L000044de
L000044da               move.w  #$0001,d2
L000044de               not.w   d2
L000044e0               and.w   #$0001,d2
L000044e4               add.w   #$000e,d2
L000044e8               move.w  d2,(a6)
L000044ea               move.w  d2,$000c(a6)
L000044ee               move.w  $0002(a6),d4
L000044f2               rts  


                    ; ------------------- play proximity sfx ---------------------
                    ; Play SFX if X & Y co-ordinates within range
                    ; IN:-
                    ;   d0.w = probably X distance
                    ;   d1.w = probably Y distance
                    ;   d2 = sfx number to play 5 - 13
play_proximity_sfx  ; original address L000044f4
L000044f4               cmp.w   #$00a0,d0
L000044f8               bcc.b   L000044f2
L000044fa               cmp.w   #$0059,d1
L000044fe               bcc.b   L000044f2
L00004500               movem.w d0-d1,-(a7)
L00004504               move.w  d2,d0
L00004506               jsr     AUDIO_PLAYER_INIT_SFX       ;$00048014           ; AUDIO_PLAYER_INIT_SFX
L0000450c               movem.w (a7)+,d0-d1
L00004510               rts 


                ; bad-guy - actor animation frames (left)
L00004512       dc.w $E010,$E011,$0000
                dc.w $E012,$E011,$0000
                dc.w $E013,$E011,$0000
L00004524       dc.w $E014,$E015,$E011

throw_grenade_left  ; L0000452A ; final animation frame?
                dc.w $E016,$E017,$E011

throw_grenade_right ; L00004530
L00004530       dc.w $0010,$0011,$0000
                dc.w $0012,$0011,$0000
                dc.w $0013,$0011,$0000
L00004542       dc.w $0014,$0015,$0011
L00004548       dc.w $0016,$0017,$0011


; 12 byte sprite id structure 
;   Offset
;   0-1     - Sprite 1 Id
;   2-3     - Sprite 2 Id
;   4-5     - Sprite 3 Id
;   6-7     - ?????
;   8-9     - ?????
;   10-11   - ?????
actor_sprite_ids    ; original address L0000454e
L0000454e       dc.w $0010,$0011,$0012,$0012,$0008,$8006
                dc.w $E010,$E011,$E012,$0012,$FFF8,$8007
                dc.w $0017,$0018,$0019,$000E,$0008,$8006 
L00004572       dc.w $E017,$E018,$E019,$000E,$FFF8,$8007
                dc.w $E013,$E014,$E012,$0014,$FFFE,$800B
                dc.w $0013,$0014,$0012,$0014,$0002,$800A
                dc.w $E015,$E016,$E012,$000B,$FFFC,$8009
L000045A2       dc.w $0015,$0016,$0012,$000B,$0004,$8008


                    ; ---------------------- draw and collide actor sprites ------------------------
                    ; Draws actor sprites using an offset specified in the 'actor list structure'
                    ; offset is a word at byte  offset #$0a (10)
                    ; 
                    ; IN:-
                    ;   a6 = actor list structure ptr
                    ;
drawcollide_sprites_from_actor_list_struct_0a   ; original address L000045ae
L000045ae               move.w ACTORSTRUCT_SPRITES_IDX(a6),d2   ;$000a(a6),d2
L000045b2               mulu.w #$000c,d2
L000045b6               lea.l actor_sprite_ids(pc,d2.w),a5      ;L0000454e(pc,d2.w),a5
                        ; fall through to 'drawcollide_actor_sprites_a5' below...

                    ; ----------------------- draw and collide sprites ids --------------------------
                    ; draw and collide sprites using 3 word ids specified by address a5.
                    ;
                    ; IN:-
                    ;   a5 = address ptr to 3 sprite ids
                    ;
drawcollide_actor_sprites_a5    ; original address L000045ba 
L000045ba               move.w  (a5)+,d2
L000045bc               bsr.b   actor_collision_and_sprite1     ;L000045c8
L000045be               move.w  (a5)+,d2
L000045c0               bsr.b   draw_next_sprite                ;L000045fa       
L000045c2               move.w  (a5)+,d2
L000045c4               bne.b   draw_next_sprite                ;L000045fa
L000045c6               rts  






                    ; do bad guy collision
                    ; draw bad guy head/sprite 1
actor_collision_and_sprite1 ; original address L000045c8
;000045c8        code1.s line 3087
L000045c8               add.w   $0006(a6),d2
L000045cc               move.w  d2,d3
L000045ce               and.w   #$1fff,d3
L000045d2               lsl.w   #$01,d3
L000045d4               lea.l   display_object_coords,a0        ;L000060c4,a0
L000045d8               move.w  d1,d4
L000045da               add.w   d4,d4
L000045dc               move.b  -$2(a0,d3.w),d5
L000045e0               ext.w   d5
L000045e2               sub.w   d5,d4
L000045e4               asr.w   #$01,d4
L000045e6               movem.w d0-d1/d4,$000e(a6)
                        ; draw sprite
L000045ec               movem.w d0-d1/a5-a6,-(a7)
L000045f0               bsr.w   draw_sprite                     ;L00005734
L000045f4               movem.w (a7)+,d0-d1/a5-a6
L000045f8               rts  


                    ; IN:-
                    ;   d0.w - Sprite X Position
                    ;   d1.w - Sprite Y Position
                    ;   d2.w - current sprite id
                    ;   a6.l - address of object/sprite struct
                    ; OUT:
                    ;   d2.w - updated sprite id
draw_next_sprite    ; original address L000045fa
L000045fa               add.w   $0006(a6),d2
L000045fe               movem.w d0-d1/a5-a6,-(a7)
L00004602               bsr.w   draw_sprite             ;L00005734
L00004606               movem.w (a7)+,d0-d1/a5-a6
L0000460a               rts  


                    ; -------------------- actor command - falling -----------------------
                    ; Called to handle actor killed/falling form playform.
                    ;   - Brown Bad Guy
                    ;   - Green Bad Guy
                    ;   - Grey Bad Guy (Jack)
                    ;
                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
                    ;
                    ;  Code Checked 29/1/2025
                    ;
actor_cmd_falling   ; original address L0000460C
L0000460c               move.w  $000a(a6),d2
L00004610               addq.w  #$01,d2
L00004612               cmp.w   #$000e,d2
L00004616               bpl.b   L0000461c
L00004618               move.w  d2,$000a(a6)
L0000461c               asr.w   #$01,d2
L0000461e               add.w   d2,$0004(a6)
L00004622               lea.l   L00006326,a5
L00004626               cmp.w   #$0064,d1
L0000462a               bmi.w   drawcollide_actor_sprites_a5    ;L000045ba           ; drawcollide_actor_sprites_a5
L0000462e               clr.w   (a6)
L00004630               move.l  #$00000350,d0
L00004636               jmp     PANEL_ADD_SCORE                 ;$0007c82a           ; PANEL_ADD_SCORE
                    ; uses rts in 'panel_add_score' above




                    ;-----------------------------------------------------------------------------------------------------------------------------
                    ;
                    ; END OF - ACTOR HANDLER CODE
                    ;
                    ;-----------------------------------------------------------------------------------------------------------------------------








                    ;-----------------------------------------------------------------------------------------------------------------------------
                    ;
                    ; PROJECTILE HANDLER CODE
                    ;
                    ;-----------------------------------------------------------------------------------------------------------------------------






                    ;----------------------------------------------------------------------------------------------
                    ; Draw Projectiles (bombs, bullets, batarang)
                    ;----------------------------------------------------------------------------------------------
                    ; draws the projectiles on the screen 
                    ;
                    ;  - bombs
                    ;  - bullets
                    ;  - player's batarang 
                    ;  - end of bat-rope
                    ;
                    ; L00004894 - 8 byte structure (20 active projectiles?)
                    ;               Handler Index, X Co-ord, Y Co-ord, Grenade Acceleration
                    ;
draw_projectiles    ; original address L0000463c
L0000463c               ;lea.l   projectile_jmp_table,a5         ;L000048a4,a5            ; projectile_jmp_table - unused here
L00004640               lea.l   projectile_list,a6              ;L000048d2,a6
L00004644               moveq   #$13,d7

L00004646               move.w  (a6)+,d2
L00004648               beq.b   L00004674 

L0000464a               movem.w (a6),d0-d1
L0000464e               move.l  a6,-(a7) 
L00004650               move.w  d7,-(a7) 
L00004652               btst.l  #$000f,d2
L00004656               beq.b   L00004660

L00004658               ext.w   d2
L0000465a               move.w  d2,-$0002(a6)
L0000465e               moveq   #$04,d2

                        ; set left/right
L00004660               ror.w   #$01,d2
L00004662               bpl.b   L00004668
L00004664               or.w    #$e000,d2

                        ; draw sprite
L00004668               add.w   #$003b,d2
L0000466c               bsr.w   draw_sprite             ;L00005734

                        ; restore counters
L00004670               move.w  (a7)+,d7
L00004672               movea.l (a7)+,a6

                        ; skip to next
L00004674               add.l  #PROJECTILE_LISTITEM_SIZE-2,a6  ;#$06,a6                 ; #PROJECTILE_LISTITEM_SIZE-2
L00004676               dbf.w   d7,L00004646
L0000467a               rts  





                    ; ---------------- find empty projectile entry ------------------
                    ; skips through the list of projectiles, returns the address of
                    ; the first empty entry in a0.
                    ; if there are no empty entries then a0 = the address of the
                    ; end of the list.
                    ;
                    ; OUT:
                    ;   a0.l = address of first empty entry in the list
                    ;           or the address of the end of the list if the list is full.
                    ;
get_empty_projectile    ; original address L0000467c
L0000467c               lea.l   projectile_list,a0          ;L000048d2,a0          ; projectile_list
L00004680               moveq   #$13,d7

L00004682               tst.w   (a0)
L00004684               beq.b   L00004694
L00004686               lea.l   $0008(a0),a0
L0000468a               dbf.w   d7,L00004682

L0000468e               movea.l #$fffffff8,a0
L00004694               rts  






                    ;-------------------------------------------------------------------------------------
                    ; -- Update the Projectiles (bombs, bullets, player's batarang)
                    ;-------------------------------------------------------------------------------------
                    ; update projectiles on the level, including the player's projectiles
                    ; it does not draw them..
                    ;
update_projectiles  ; original address L00004696
L00004696               lea.l   projectile_jmp_table,a5         ;L000048a4,a5        ; projectile_jmp_table
L0000469a               lea.l   projectile_list,a6              ;L000048d2,a6        ; projectile_list
L0000469e               moveq   #$13,d7

L000046a0               move.w (a6)+,d6
L000046a2               beq.b   L000046bc

L000046a4               movem.w (a6),d0-d1
L000046a8               sub.w   L00006356,d0
L000046ac               sub.w   vertical_scroll_increments,d1   ;L00006358,d1
L000046b0               asl.w   #$02,d6             ; modified address table to 32 bit addresses, original code 'asl.w #$01,d6'
L000046b2               clr.l   d2
L000046b4               movea.l d2,a0
L000046b6               movea.l -$4(a5,d6.w),a0     ; modified address table to 32 bit addresses, original code 'movea.w $fe(a5,d6.W),a0' 
L000046ba               jsr     (a0)

L000046bc               addq.l  #$06,a6
L000046be               dbf.w   d7,L000046a0
L000046c2               rts  




                    ; badguy shooting - common code
                    ; executed after the projectile x & y
                    ; has been updated and screen boundary checks
                    ; have passed.
                    ;       
                    ; PROJECTILE HANDLER 
                    ;   referenced from: projectile_jmp_table
                    ;
                    ; d0.w = X
                    ; d1.w = Y
                    ; d2.l = #$00000000
                    ; d6.w = index into projectile_list
                    ; d7.w = projectile loop counter
                    ; a0.l = routine address
                    ; a5.l = projectile_jmp_table
                    ; a6.l = projectile_list entry + 2
                    ;
badguy_shooting     ; original address L000046c4
L000046c4               movem.w d0-d1,(a6)
L000046c8               bsr.w   get_map_tile_at_display_offset_d0_d1    ; L000055e0       ; get_map_tile_at_display_offset_d0_d1
L000046cc               cmp.b   #$03,d2
L000046d0               bcs.b   L000046f8

L000046d2               sub.w   batman_x_offset,d0      ;L000069f2,d0
L000046d6               addq.w  #$04,d0
L000046d8               cmp.w   #$0009,d0
L000046dc               bcc.b   L000046fe

L000046de               cmp.w   batman_y_offset,d1      ;L000069f4,d1
L000046e2               bpl.b   L000046fe

L000046e4               cmp.w   batman_y_bottom,d1      ;L00006338,d1
L000046e8               bmi.b   L000046fe

L000046ea               moveq   #$01,d6
L000046ec               bsr.w   batman_lose_energy      ;L00004d0a
L000046f0               moveq   #SFX_GUYHIT,d0          ;#$0a,d0         ; SFX_GUYHIT
L000046f2               jsr     AUDIO_PLAYER_INIT_SFX   ;$00048014       ; AUDIO_PLAYER_INIT_SFX

L000046f8               move.w  #$0004,-$0002(a6)
L000046fe               rts  



                    ; ----------- badguy shooting left & up - diagonal ----------
                    ; Update X,Y co-ords, check bullet on screen and remove if not.
                    ; Perform common code if on screen.
                    ;
                    ; PROJECTILE HANDLER 
                    ;   referenced from: projectile_jmp_table
                    ;
                    ; d0.w = X
                    ; d1.w = Y
                    ; d2.l = #$00000000
                    ; d6.w = index into projectile_list
                    ; d7.w = projectile loop counter
                    ; a0.l = routine address
                    ; a5.l = projectile_jmp_table
                    ; a6.l = projectile_list entry + 2
                    ;
badguy_shooting_left_up ; original address L00004700
L00004700               subq.w  #$03,d0
L00004702               cmp.w   #$fff6,d0
L00004706               bmi.b   remove_projectile       ;L00004760           ; remove_projectile

L00004708               subq.w  #$03,d1
L0000470a               cmp.w   #$0058,d1
L0000470e               bcs.b   badguy_shooting         ;L000046c4
L00004710               bra.b   remove_projectile       ;L00004760



                    ; ---------- badguy shooting right & up - diagonal ----------
                    ;
                    ; PROJECTILE HANDLER 
                    ;   referenced from: projectile_jmp_table
                    ;
                    ; d0.w = X
                    ; d1.w = Y
                    ; d2.l = #$00000000
                    ; d6.w = index into projectile_list
                    ; d7.w = projectile loop counter
                    ; a0.l = routine address
                    ; a5.l = projectile_jmp_table
                    ; a6.l = projectile_list entry + 2
                    ;
                    ; Code Checked 2/1/2025
                    ;
badguy_shooting_right_up ; original address L00004712
L00004712               addq.w  #$03,d0
L00004714               cmp.w   #$00a8,d0
L00004718               bpl.b   remove_projectile       ;L00004760       ; remove_projectile

L0000471a               subq.w  #$03,d1
L0000471c               cmp.w   #$0058,d1
L00004720               bcs.b   badguy_shooting         ;L000046c4
L00004722               bra.b   remove_projectile       ;L00004760



                    ; --------- badguy shooting left & down - diagonal ----------
                    ;
                    ; PROJECTILE HANDLER 
                    ;   referenced from: projectile_jmp_table
                    ;
                    ; d0.w = X
                    ; d1.w = Y
                    ; d2.l = #$00000000
                    ; d6.w = index into projectile_list
                    ; d7.w = projectile loop counter
                    ; a0.l = routine address
                    ; a5.l = projectile_jmp_table
                    ; a6.l = projectile_list entry + 2
                    ;
badguy_shooting_left_down ; original address L00004724
L00004724               subq.w  #$03,d0
L00004726               cmp.w   #$fff6,d0
L0000472a               bmi.b   remove_projectile   ;L00004760       ; remove_projectile

L0000472c               addq.w  #$03,d1
L0000472e               cmp.w   #$0058,d1
L00004732               bcs.b   badguy_shooting     ;L000046c4
L00004734               bra.b   remove_projectile   ;L00004760       ; remove_projectile



                    ; ---------- badguy shooting right & down - diagonal ----------
                    ;
                    ; PROJECTILE HANDLER 
                    ;   referenced from: projectile_jmp_table
                    ;
                    ; d0.w = X
                    ; d1.w = Y
                    ; d2.l = #$00000000
                    ; d6.w = index into projectile_list
                    ; d7.w = projectile loop counter
                    ; a0.l = routine address
                    ; a5.l = projectile_jmp_table
                    ; a6.l = projectile_list entry + 2
                    ;
badguy_shooting_right_down ; original address L00004736
L00004736               addq.w  #$03,d0
L00004738               cmp.w   #$00a8,d0
L0000473c               bpl.b   remove_projectile   ;L00004760       ; remove_projectile

L0000473e               addq.w  #$03,d1
L00004740               cmp.w   #$0058,d1
L00004744               bcs.w   badguy_shooting     ;L000046c4
L00004748               bra.b   remove_projectile   ;L00004760       ; remove_projectile



                    ; ---------- badguy shooting left ----------
                    ;
                    ; PROJECTILE HANDLER 
                    ;   referenced from: projectile_jmp_table
                    ;
                    ; d0.w = X
                    ; d1.w = Y
                    ; d2.l = #$00000000
                    ; d6.w = index into projectile_list
                    ; d7.w = projectile loop counter
                    ; a0.l = routine address
                    ; a5.l = projectile_jmp_table
                    ; a6.l = projectile_list entry + 2
                    ;
badguy_shooting_left    ; original address L0000474A 
L0000474a               subq.w  #$05,d0
L0000474c               cmp.w   #$fff6,d0
L00004750               bpl.w   badguy_shooting         ;L000046c4
L00004754               bra.b   remove_projectile       ;L00004760       ; remove_projectile



                    ; ---------- badguy shooting right ----------
                    ;
                    ; PROJECTILE HANDLER 
                    ;   referenced from: projectile_jmp_table
                    ;
                    ; d0.w = X
                    ; d1.w = Y
                    ; d2.l = #$00000000
                    ; d6.w = index into projectile_list
                    ; d7.w = projectile loop counter
                    ; a0.l = routine address
                    ; a5.l = projectile_jmp_table
                    ; a6.l = projectile_list entry + 2
                    ;
                    ; Code Checked 2/1/2015
                    ;
badguy_shooting_right   ; original address L00004756
L00004756               addq.w  #$05,d0
L00004758               cmp.w   #$00a8,d0
L0000475c               bmi.w   badguy_shooting         ;L000046c4       ; badguy_shooting







        ;------------------------------------------------------------------------------------------------------
        ; Projectile Handling Code & Data
        ;------------------------------------------------------------------------------------------------------
        ; 
        ;------------------------------------------------------------------------------------------------------


                    ; ---------------- remove projectile -----------------
                    ; IN:-
                    ;   a6.l = Projectile List Entry +2
                    ;
remove_projectile       ; original address L00004760
L00004760               clr.w   -$0002(a6)
L00004764               rts 


                    ; ------------------- batarang fire right ------------------
                    ; batman firing a bat-a-rang projectile to the right
                    ;
                    ; PROJECTILE HANDLER 
                    ;   referenced from: projectile_jmp_table
                    ;
                    ; d0.w = X
                    ; d1.w = Y
                    ; d2.l = #$00000000
                    ; d6.w = index into projectile_list
                    ; d7.w = projectile loop counter
                    ; a0.l = routine address
                    ; a5.l = projectile_jmp_table
                    ; a6.l = projectile_list entry + 2
                    ;
batarang_right      ; original address L00004766
L00004766               addq.w  #$04,d0
L00004768               cmp.w   #$00a8,d0
L0000476c               bpl.b   remove_projectile                       ;L00004760
L0000476e               bsr.w   get_map_tile_at_display_offset_d0_d1    ;L000055e0  
L00004772               cmp.b   #$03,d2
L00004776               movem.w d0-d1,(a6)
L0000477a               bcc.b   actor_projectile_collision_handler      ;L000047bc 
L0000477c               bra.b   remove_projectile                       ;L00004760
;L0000477c               bcs.b   #$e2 == $00004760 (F)


                    ; ------------------ batarang fire left ----------------
                    ; batman firing a bat-a-rang projectile to the left.
                    ;
                    ; PROJECTILE HANDLER 
                    ;   referenced from: projectile_jmp_table
                    ;
                    ; d0.w = X
                    ; d1.w = Y
                    ; d2.l = #$00000000
                    ; d6.w = index into projectile_list
                    ; d7.w = projectile loop counter
                    ; a0.l = routine address
                    ; a5.l = projectile_jmp_table
                    ; a6.l = projectile_list entry + 2
                    ;
batarang_left       ; original address L0000477E 
L0000477e           subq.w  #$04,d0
L00004780           cmp.w   #$fff6,d0
L00004784           bmi.b   remove_projectile                       ;L00004760
L00004786           bsr.w   get_map_tile_at_display_offset_d0_d1    ;L000055e0
L0000478a           cmp.b   #$03,d2
L0000478e           movem.w d0-d1,(a6)
L00004792           bcc.b   actor_projectile_collision_handler      ;L000047bc  
L00004794           bra.b   remove_projectile                       ;L00004760  



                    ; ------------- batman grappling hook ---------------
                    ; Update grappling hook X,Y and whether it has hit
                    ; any actor to kill any bad guys.
                    ; This routine does not manage 'batman state', or
                    ; batman attaching and/or swinging from the rope etc. 
                    ; It is concerned only with the hook part used as a 
                    ; projectile (i.e. its travel and collision with actors)
                    ;
                    ; PROJECTILE HANDLER 
                    ;   referenced from: projectile_jmp_table
                    ;
                    ; d0.w = X - Current
                    ; d1.w = Y - Current
                    ; d2.l = #$00000000
                    ; d6.w = index into projectile_list
                    ; d7.w = projectile loop counter
                    ; a0.l = routine address
                    ; a5.l = projectile_jmp_table
                    ; a6.l = projectile_list entry + 2
                    ;
batman_grappling_hook   ; original address L00004796
L00004796               move.w  grappling_hook_height,d0    ;L00006360,d0
L0000479a               beq.b   remove_projectile           ;L00004760 
L0000479c               movem.w batman_xy_offset,d0-d1      ;L000069f2,d0-d1
L000047a2               add.w   L00006362,d0
L000047a6               sub.w   L00006364,d1
L000047aa               sub.w   #$000c,d1
L000047ae               addq.w  #$05,d0
L000047b0               tst.w   batman_sprite1_id           ;L00006336
L000047b4               bpl.b   L000047b8
L000047b6               subq.w  #$07,d0
L000047b8               movem.w d0-d1,(a6)
                    ; falls through to actor collision
                    ; can be used to kill bad guys



                    ; ------------- actor to projectile collision check -----------
                    ; Tests and if necessary handles the collision between the
                    ; batman's bat-a-rang projectile and an enemy actor.
                    ; It steps through active actor list backwards, maybe an optimisation
                    ; thinking that the most recently added actor is most likley to
                    ; be hit first?
                    ;
                    ; d0.w = X - Current
                    ; d1.w = Y - Current
                    ; d2.l = #$00000000
                    ; d6.w = index into projectile_list
                    ; d7.w = projectile loop counter
                    ; a0.l = routine address
                    ; a5.l = projectile_jmp_table
                    ; a6.l = projectile_list entry + 2
                    ;
actor_projectile_collision_handler  ; original address L000047bc
L000047bc               lea.l   last_active_actor,a4            ;L00003a82,a4            ; last_active_actor
L000047c0               moveq   #$09,d6

L000047c2               move.w  (a4),d2
L000047c4               subq.w  #$02,d2
L000047c6               bmi.b   L000047e2 

L000047c8               move.w  ACTORSTRUCT_X_CENTRE(a4),d2     ;$000e(a4),d2
L000047cc               sub.w   d0,d2
L000047ce               addq.w  #$04,d2
L000047d0               cmp.w   #$0008,d2
L000047d4               bcc.b   L000047e2

L000047d6               cmp.w   ACTORSTRUCT_Y_TOP(a4),d1        ;$0010(a4),d1
L000047da               bpl.b   L000047e2

L000047dc               cmp.w   ACTORSTRUCT_Y_BOTTOM(a4),d1     ;$0012(a4),d1
L000047e0               bpl.b   projectile_hit_actor            ;L000047ec
                        ; next actor
L000047e2               lea.l   -ACTORLIST_STRUCT_SIZE(a4),a4   ;-$0018(a4),a4
L000047e6               dbf.w   d6,L000047c2
L000047ea               rts  




                    ; ---------- actor collided with projectile -----------
                    ; Batman's bat-a-rang projectile has hit an actor.
                    ; This routine sets the handler index to $0001 (a4)
                    ;
                    ; IN:
                    ;   a4.l = Actor Structure
                    ;
projectile_hit_actor    ; original address L000047ec
L000047ec           move.w  #$0001,ACTORSTRUCT_STATUS(a4)
L000047f0           move.w  #$fffc,$000a(a4)
L000047f6           bsr.w   remove_projectile           ;L00004760 
L000047fa           moveq   #SFX_GUYHIT,d0              ;#$0a,d0  
L000047fc           jmp     AUDIO_PLAYER_INIT_SFX       ;$00048014  
                    ; use rts in audio player to return



                    ; --------------- bad guy grenade right ---------------
                    ; handle bad guy grenade thrown to the right.
                    ; update X, Y and check for off bottom of the screen
                    ;
                    ; d0.w = X - Current
                    ; d1.w = Y - Current
                    ; d2.l = #$00000000
                    ; d6.w = index into projectile_list
                    ; d7.w = projectile loop counter
                    ; a0.l = routine address
                    ; a5.l = projectile_jmp_table
                    ; a6.l = projectile_list entry + 2
                    ;                
badguy_grenade_right    ; original address L00004802
L00004802               addq.w  #$02,d0
L00004804               move.w  $0004(a6),d2
L00004808               cmp.w   #$0028,d2
L0000480c               bpl.b   L00004812
L0000480e               addq.w  #$01,$0004(a6)
L00004812               asr.w   #$02,d2
L00004814               bpl.b   L00004818
L00004816               addq.w  #$01,d2
L00004818               add.w   d2,d1
L0000481a               cmp.w   #$0060,d1   
L0000481e               bpl.w   remove_projectile       ;L00004760  
                    ; fall through to common processing



                    ; --------------- bad guy grenade common ---------------
                    ; common code for bad guy grenade when thrown left and right.
                    ; test for grenade collision with batman. 
                    ; If so, deplete energy level & explode the grenade & play SFX.
                    ;
                    ; test for collision with wall, if so then explode the grenade & play SFX.
                    ;
                    ; d0.w = X - Current
                    ; d1.w = Y - Current
                    ; d2.l = #$00000000
                    ; d6.w = index into projectile_list
                    ; d7.w = projectile loop counter
                    ; a0.l = routine address
                    ; a5.l = projectile_jmp_table
                    ; a6.l = projectile_list entry + 2
                    ;
badguy_grenade_common   ; original address L00004822
L00004822               movem.w d0-d1,(a6)
L00004826               bsr.w   get_map_tile_at_display_offset_d0_d1    ; L000055e0       ; get_map_tile_at_display_offset_d0_d1
L0000482a               cmp.b   #$03,d2
L0000482e               bcs.b   L00004852 
                        ; check x collision
L00004830               sub.w   batman_x_offset,d0      ;L000069f2,d0
L00004834               addq.w  #$03,d0
L00004836               cmp.w   #$0007,d0
L0000483a               bcc.b   L0000485e
                        ; check y collision
L0000483c               cmp.w   batman_y_offset,d1      ;L000069f4,d1
L00004840               bpl.b   L0000485e
L00004842               cmp.w   batman_y_bottom,d1      ;L00006338,d1
L00004846               bmi.b   L0000485e
                        ; batman hit
L00004848               moveq   #$06,d6
L0000484a               bsr.w   batman_lose_energy      ;L00004d0a 
L0000484e               movem.w (a6),d0-d1
                        ; hit wall
L00004852               move.w  #$000e,-$0002(a6)
L00004858               moveq   #SFX_EXPLOSION,d2       ;#$0d,d2                 ; SFX_EXPLOSION
L0000485a               bra.w   play_proximity_sfx      ;L000044f4
L0000485e               rts  




                    ; --------------- bad guy grenade left ---------------
                    ; handle bad guy grenade thrown to the left.
                    ; update X, Y and check for off bottom of the screen
                    ;
                    ; d0.w = X - Current
                    ; d1.w = Y - Current
                    ; d2.l = #$00000000
                    ; d6.w = index into projectile_list
                    ; d7.w = projectile loop counter
                    ; a0.l = routine address
                    ; a5.l = projectile_jmp_table
                    ; a6.l = projectile_list entry + 2
                    ;
badguy_grenade_left ; original address L00004860
L00004860           subq.w  #$02,d0
L00004862           move.w  $0004(a6),d2
L00004866           cmp.w   #$0028,d2
L0000486a           bpl.b   L00004870
L0000486c           addq.w  #$01,$0004(a6)
L00004870           asr.w   #$02,d2
L00004872           bpl.b   L00004876
L00004874           addq.w  #$01,d2
L00004876           add.w   d2,d1
L00004878           cmp.w   #$0060,d1
L0000487c           bpl.w   remove_projectile       ;L00004760       ; remove_projectile
L00004880           bra.b   badguy_grenade_common   ;L00004822       ; badguy_grenade_common




                    ; --------------- grenade explosion effect -----------------
                    ; Effect #14 is set to be executed after a grenade explodes.
                    ; Cycles through the handlers from 14-24 (10 handlers).
                    ; All handlers point to this routine.
                    ; When the last hander is executed, then the projectile is
                    ; removed from the list.  It's just a delay for the
                    ; grenade explosion, a bit of a hack, instead of holding
                    ; a couter value (which could be done in offset 6 of the struct (a6)
                    ;
                    ; d0.w = X - Current
                    ; d1.w = Y - Current
                    ; d2.l = #$00000000
                    ; d6.w = index into projectile_list
                    ; d7.w = projectile loop counter
                    ; a0.l = routine address
                    ; a5.l = projectile_jmp_table
                    ; a6.l = projectile_list entry + 2
                    ;
grenade_explosion_effect    ; original address L00004882
L00004882               movem.w d0-d1,(a6)
L00004886               btst.b  #$0000,playfield_swap_count+1       ;L00006375
L0000488c               bne.b   L000048a2
L0000488e               move.w  -$0002(a6),d2
L00004892               addq.w  #$01,d2
L00004894               cmp.w   #$0018,d2
L00004898               bne.w   L0000489e
L0000489c               clr.w   d2
L0000489e               move.w  d2,-$0002(a6)
L000048a2               rts  





                    ; ------------------- projectile handler jump table -------------------------
                    ; Used by the update_projectiles routine, along with the handler/index id
                    ; stored in the projectile_list entry to execute code to handle the 
                    ; lifetime of the projectile, i.e. flight, collision, deactivation.
                    ;
                    ; Entries 5 & 6 - used to remove projectiles on next execution.
                    ;
                    ; The handler entries alternate odd/even, the handler index id is used
                    ; to decide on left/right sprites to draw in the 'draw_projectiles' 
                    ; routine. A hidden aspect of the draw routine which may or may not
                    ; have any impact to the game, as i'm not sure whether the projectiles
                    ; have different GFX for left/right facing items.
                    ; The Batman Bat-a-rang left/right lookups do-not conform to this,
                    ; maybe a bug or maybe intensional.
                    ;

projectile_jmp_table    ; original adress L000048a4
L000048A4           dc.l batman_grappling_hook      ;L00004796
                    dc.l batarang_right             ;L00004766
                    dc.l batarang_left              ;L0000477E 
                    dc.l remove_projectile          ;L00004760 
                    dc.l remove_projectile          ;L00004760 
                    dc.l badguy_shooting_right      ;L00004756 
                    dc.l badguy_shooting_left       ;L0000474A 
                    dc.l badguy_shooting_right_down ;L00004736
L000048B4           dc.l badguy_shooting_left_down  ;L00004724
                    dc.l badguy_shooting_right_up   ;L00004712
                    dc.l badguy_shooting_left_up    ;L00004700 
                    dc.l badguy_grenade_right       ;L00004802 
                    dc.l badguy_grenade_left        ;L00004860 
                    dc.l grenade_explosion_effect   ;L00004882 
                    dc.l grenade_explosion_effect   ;L00004882 
                    dc.l grenade_explosion_effect   ;L00004882
L000048C4           dc.l grenade_explosion_effect   ;L00004882
                    dc.l grenade_explosion_effect   ;L00004882
                    dc.l grenade_explosion_effect   ;L00004882 
                    dc.l grenade_explosion_effect   ;L00004882 
                    dc.l grenade_explosion_effect   ;L00004882 
                    dc.l grenade_explosion_effect   ;L00004882 
                    dc.l grenade_explosion_effect   ;L00004882 
                    dc.l grenade_explosion_effect   ;L00004882 



projectile_nop
                move.w  #$00f,$dff180
                rts

                    ; ------------------------------ projectile list ----------------------------------
                    ; Active projectile list, i.e. bullets, grenades, bat-grappling hook, bat-a-rang.
                    ; Each entry is a 4 word structure and there are 20 entries, allowing a max of
                    ; 20 active projectiles on the screen at anytime.
                    ;
                    ;   Offset  | Length    | Description
                    ;       0   |   2 bytes | projectile_jmp_table handler number (0 = disabled)
                    ;       2   |   2 bytes | projectile X co-ord
                    ;       4   |   2 bytes | projectile Y co-ord
                    ;       6   |   2 bytes | parameter data (used for grenade acceleration factor)
                    ;
PROJECTILE_LISTITEM_SIZE    EQU $8                  ; 8 byte structure size
PROJECTILE_LISTITEM_HANDLER EQU $0                  ; Projectile Handler Index
PROJECTILE_LISTITEM_X       EQU $2                  ; Projectile X co-ord
PROJECTILE_LISTITEM_Y       EQU $4                  ; Projectile Y co-ord
PROJECTILE_LISTITEM_PARAM   EQU $6                  ; additional param (used for grenade acceleration)


projectile_list     ; original address L000048d2
L000048d2   
            dc.w $0000,$0000,$0000,$0000
            dc.w $0000,$0000,$0000,$0000
            dc.w $0000,$0000,$0000,$0000
            dc.w $0000,$0000,$0000,$0000
            dc.w $0000,$0000,$0000,$0000
            dc.w $0000,$0000,$0000,$0000
            dc.w $0000,$0000,$0000,$0000 
            dc.w $0000,$0000,$0000,$0000 
            dc.w $0000,$0000,$0000,$0000
            dc.w $0000,$0000,$0000,$0000 
            dc.w $0000,$0000,$0000,$0000 
            dc.w $0000,$0000,$0000,$0000 
            dc.w $0000,$0000,$0000,$0000
            dc.w $0000,$0000,$0000,$0000
            dc.w $0000,$0000,$0000,$0000
            dc.w $0000,$0000,$0000,$0000
            dc.w $0000,$0000,$0000,$0000
            dc.w $0000,$0000,$0000,$0000
            dc.w $0000,$0000,$0000,$0000 
            dc.w $0000,$0000,$0000,$0000

        ;------------------------------------------------------------------------------------------------------
        ; END OF - Projectile Handling Code & Data
        ;------------------------------------------------------------------------------------------------------
        ; 
        ;------------------------------------------------------------------------------------------------------



; Code1.s Line 3959


                    ; ----------------------------------------------------------------------------------------------
                    ; -- Update Background Scroll (off screen buffer)
                    ;-----------------------------------------------------------------------------------------------
                    ; This routine manages the background level scrolling,
                    ; It draws the changes into the Off-Screen Buffer (kinda like a circular buffer of screen data)
                    ;
                    ;-----------------------------------------------------------------------------------------------
temp_vertical_scroll_increments ; original address L00004972
L00004972   dc.w $0000 

scroll_offscreen_buffer ; original address L00004974
L00004974               movem.w batman_y_offset,d1-d2                   ;L000069f4,d1-d2
L0000497a               move.w  d1,d0
L0000497c               sub.w   d2,d0
L0000497e               move.w  vertical_scroll_increments,temp_vertical_scroll_increments  ;L00004972
L00004984               move.w  d0,vertical_scroll_increments           ;L00006358
L00004988               beq.w   do_horizontal_scroll                    ;L00004a2a 

                    ; think this is doing something to set the scroll speed.
                    ; it's fannying around with values in d0.
                    ; d0 is an offset added to the window Y coord further below.
scroll_speed_shenanigans    ; original address L0000498c 
L0000498c               tst.w   L00006342
                        ; check < 0
L00004990               bmi.b   L000049aa
                        ; check = 0
L00004992               beq.b   L000049be
                        ; check 1 to 4 scroll intervals
L00004994               cmp.w   #$0004,d0
L00004998               bcs.b   L000049be
                        ; check -3 to -1 scroll intervals
L0000499a               cmp.w   #$fffd,d0       ; -3
L0000499e               bcc.b   L000049be
L000049a0               bpl.b   L000049a6
L000049a2               moveq   #-$2,d0         ;#$fe,d0         ; -2
L000049a4               bra.b   L000049be

L000049a6               moveq   #$02,d0
L000049a8               bra.b   L000049be

L000049aa               cmp.w   #$0008,d0
L000049ae               bcs.b   L000049be
L000049b0               cmp.w   #$fffd,d0       ; -3
L000049b4               bcc.b   L000049be
L000049b6               bmi.b   L000049bc
L000049b8               moveq   #$07,d0
L000049ba               bra.b   L000049be
L000049bc               moveq   #-$3,d0         ;#$fd,d0         ; -3

.continue_vertical_scroll  
L000049be               move.w  scroll_window_y_coord,d1        ;L000069ee,d1
L000049c2               move.w  d1,d3
L000049c4               add.w   d0,d1
L000049c6               cmp.w   #$0601,d1
L000049ca               bcs.b   L000049de

L000049cc               bmi.b   L000049da

.clamp_y_max        ; clamp to max Y coord     
L000049ce               move.w  #$0600,d2
L000049d2               sub.w   d2,d1
L000049d4               sub.w   d1,d0
L000049d6               move.w  d2,d1
L000049d8               bra.b   L000049de

.clamp_y_min        ; clamp to min Y coord?   
L000049da               sub.w   d1,d0
L000049dc               clr.w   d1

.update_y_scroll_position   ; original address L000049a0
L000049de               sub.w   d0,batman_y_offset              ;L000069f4
L000049e2               move.w  d1,scroll_window_y_coord        ;L000069ee

check_vertical_scroll  ; original address L000049a8
                    ; calculate the number of increments to scroll
L000049e6               sub.w   d3,d1
L000049e8               move.w  d1,vertical_scroll_increments   ;L00006358
L000049ec               beq.b   do_horizontal_scroll            ;L00004a2a
L000049ee               bmi.b   scroll_display_window_up        ;L00004a12

scroll_display_window_down 
L000049f0               add.w   #DISPLAY_MAX_Y,d3               ;#$0057,d3
L000049f4               move.w  offscreen_y_coord,d2            ;L0000635a,d2
L000049f8               move.w  d1,d4
L000049fa               add.w   d2,d4
L000049fc               cmp.w   #DISPLAY_MAX_Y,d4               ;#$0057,d4
L00004a00               bcs.b   L00004a06
.is_display_wrap
L00004a02               sub.w   #DISPLAY_MAX_Y,d4               ;#$0057,d4
.no_display_wrap
L00004a06               move.w  d4,offscreen_y_coord            ;L0000635a
L00004a0a               bsr.w   draw_background_vertical_scroll ;L00004a9c
L00004a0e               bra.w   do_horizontal_scroll            ;L00004a2a

                    ;---------------------------------------

                    ; scroll display up (e.g. climbing upwards)
                    ; NB: d1 is negative
scroll_display_window_up    ; original address L00004a12
L00004a12               move.w  offscreen_y_coord,d2                ;L0000635a,d2
L00004a16               add.w   d1,d2
                        ; test for underflow wrap at top
L00004a18               bpl.b   L00004a1e
.is_enderflow_wrap
L00004a1a               add.w   #DISPLAY_MAX_Y,d2                   ;#$0057,d2
.no_underflow_wrap 
L00004a1e               move.w  d2,offscreen_y_coord                ;L0000635a
L00004a22               add.w   d1,d3
L00004a24               neg.w   d1
L00004a26               bsr.w   draw_background_vertical_scroll     ;L00004a9c       



                    ; ------- do horizontal scroll -------
do_horizontal_scroll    ; original address L00004a2a
L00004a2a               move.w  batman_x_offset,d0              ;L000069f2,d0
L00004a2e               sub.w   target_window_x_offset,d0       ;L000069f8,d0
L00004a32               move.w  d0,L00006356
L00004a36               beq.w   L00004a9a

L00004a3a               move.w  scroll_window_x_coord,d1        ;L000069ec,d1

.test_min_X         ; test window min X value (0)
L00004a3e               move.w  d1,d2
L00004a40               add.w   d0,d1
L00004a42               bpl.b   L00004a4a

.clamp_low_X        ; clamp window at X=0
L00004a44               move.w  d1,d0
L00004a46               clr.w   d1
L00004a48               bra.b   L00004a5a

.test_max_X        ; test window max X value
L00004a4a                clr.w   d0
L00004a4c                cmp.w   #$0230,d1
L00004a50                bls.b   L00004a5a

.clamp_max_X        ; clamp window at x = #$230
L00004a52               move.w  #$0230,d0
L00004a56               sub.w   d0,d1
L00004a58               exg.l   d1,d0

.cont_horiz_scroll  ; calc amount of horizontal scroll  
L00004a5a               add.w   target_window_x_offset,d0       ;L000069f8,d0
L00004a5e               move.w  d0,batman_x_offset              ;L000069f2
L00004a62               move.w  d1,scroll_window_x_coord        ;L000069ec
L00004a66               move.w  d1,d3
L00004a68               sub.w   d2,d3
L00004a6a               move.w  d3,L00006356
L00004a6e               beq.b   L00004a9a

                    ; check if coarse scroll     
L00004a70               eor.w   d1,d2
L00004a72               btst.l  #$0003,d2
L00004a76               beq.b   L00004a9a

                    ; set up coarse scroll  
L00004a78               movea.l offscreen_display_buffer_ptr,a4         ;L00006366,a4
L00004a7c               tst.w   d3
L00004a7e               bmi.b   L00004a90

.scroll_right       ; do scroll right 
L00004a80               add.w   #$00a0,d1
L00004a84               addq.w  #$02,a4
L00004a86               move.l  a4,offscreen_display_buffer_ptr         ;L00006366
L00004a8a               lea.l   $0028(a4),a4
L00004a8e               bra.b   L00004a96

.scroll_left        ; do scroll left. L00004a52
L00004a90               subq.w  #$02,a4
L00004a92               move.l  a4,offscreen_display_buffer_ptr         ;L00006366

.update_horizontal  ; draw new column of tile map
L00004a96               bsr.w   draw_background_horizontal_scroll       ;L00004b14

.exit_horizontal_scroll ; original address L00004a5c
L00004a9a               rts


                    ; -------------------- draw background vertical scroll --------------------
                    ; The vertical scroll window moves 2 rasters at a time.
                    ; This routine draws 2 raster lines of graphics that are being scrolled 
                    ; into the new window when the screen scrolls vertically.
                    ;
                    ; NB: This routine draws the background information into the 
                    ;       off-screen buffer. This buffer is a then presented into
                    ;       
                    ;
                    ; The way the scroll window works is that it moves to keep batman in
                    ; the frame.  The vertical scroll moves when the joystick movement
                    ; is made up/down and allows the player to see more background
                    ; displayed above or below batman on thhe platforms.
                    ;
                    ; it also scrolls when batman is hanging on his batrope.
                    ; it also scrolls when batman is falling between platforms.
                    ; it also scrolls when batman is climbing a ladder.
                    ;
                    ; IN:
                    ;   d1.w - Number of 'scroll' counts (two raster lines per scroll)
                    ;   d2.w - Destination GFX Buffer Y Value to add scroll GFX into. - Y value is divided by 2
                    ;   d3.w - Y value of world/tilemap location to display - Y value is divided by 2
                    ;   a3.l - source base gfx ptr
                    ;
draw_background_vertical_scroll ; original address L00004a9c
L00004a9c           ;rts
                     subq.w  #$01,d1

                    ; calc source gfx start offset (depends on soft scroll value)
                    ; self modified code, updates LEA offset value below.
.draw_next_scroll_line ; draw new line (2 rasters) of scroll gfx
L00004a9e               move.w  d3,d4
L00004aa0               and.w   #$0007,d4
L00004aa4               asl.w   #$04,d4
L00004aa6               move.b  d4,gfx_lea_offset       ; L00004adf 

                    ; calc Y offset into map tile map data
L00004aac               move.w  d3,d4
L00004aae               lsr.w   #$03,d4
L00004ab0               lea.l   MAPGR_BASE,a0                   ;$00008002,a0            ; MAPGR_BASE
L00004ab6               mulu.w  (a0),d4

                    ; calc X offset into map tile map data
L00004ab8               move.w  scroll_window_x_coord,d0        ;L000069ec,d0
L00004abc               lsr.w   #$03,d0

                    ; calc total offset into tile map data
L00004abe               add.w   d0,d4
L00004ac0               lea.l   MAPGR_TILEDATA_OFFSET(a0,d4.W),a0   ;$7a(a0,d4.w),a0         ; MAPGR_TILEDATA_OFFSET

                    ; calc gfx destination address
L00004ac4               move.w  d2,d4
L00004ac6               mulu.w  #$0054,d4
L00004aca               add.l   offscreen_display_buffer_ptr,d4     ;L00006366,d4
L00004ace               movea.l d4,a1

                    ; Initialise Draw Loop 
                    ; width of display buffer - #$14 (21) words
L00004ad0               moveq   #$14,d7
L00004ad2               movea.l background_gfx_base,a2          ;L00006352,a2

.draw_next_block    ; draw tile gfx (2 rasters worth)
L00004ad6               clr.w   d0
L00004ad8               move.b  (a0)+,d0
L00004ada               asl.w   #$07,d0

                    ; calc gfx source address ptr 
                    ; lea.l   $XX(a2,d0.W),a3 - Self Modified Code 
;00004adc                lea.l $00(a2,d0.W),a3
                        dc.w    $47f2                               ; lea.l   $XX(a2,d0.W),a3 - Self Modified Code                          
                        dc.b    $00
gfx_lea_offset          dc.b    $00                                 ; $XX - byte offset value - original address L00004aa1

                    ; draw gfx block (2 rasters)
L00004ae0               move.w  (a3)+,(a1)+
L00004ae2               move.w  (a3)+,DISPLAY_BUFFER_BPL1_OFFSET-2(a1)  ;$1c8a(a1)
L00004ae6               move.w  (a3)+,DISPLAY_BUFFER_BPL2_OFFSET-2(a1)  ;$3916(a1)
L00004aea               move.w  (a3)+,DISPLAY_BUFFER_BPL3_OFFSET-2(a1)  ;$55a2(a1)
L00004aee               move.w  (a3)+,DISPLAY_BUFFER_BPL0_OFFSET+DISPLAY_BYTEWIDTH-2(a1)    ;$0028(a1)
L00004af2               move.w  (a3)+,DISPLAY_BUFFER_BPL1_OFFSET+DISPLAY_BYTEWIDTH-2(a1)    ;$1cb4(a1)
L00004af6               move.w  (a3)+,DISPLAY_BUFFER_BPL2_OFFSET+DISPLAY_BYTEWIDTH-2(a1)    ;$3940(a1)
L00004afa               move.w  (a3)+,DISPLAY_BUFFER_BPL3_OFFSET+DISPLAY_BYTEWIDTH-2(a1)    ;$55cc(a1)
L00004afe               dbf.w   d7,L00004ad6

                        ; update Y co-ords
L00004b02               addq.w  #$01,d3
L00004b04               addq.w  #$01,d2

                        ; test for dest gfx buffer overrun
L00004b06               cmp.w   #DISPLAY_MAX_Y,d2               ;#$0057,d2
L00004b0a               bcs.b   L00004b0e
L00004b0c               clr.w   d2
L00004b0e               dbf.w   d1,L00004a9e
L00004b12               rts  



                    ; -------------------- draw background vertical scroll --------------------
                    ; draw background screen blocks for Horizonal Scroll.
                    ; Draws a column of tiles into the offscreen buffer.
                    ;
                    ; The draw loops for the tile are 'upsidedown' see 'dbf' at display_gfx_loop
                    ; this makes understanding the draw a little more complicated.
                    ; the d5 in this loop represents the count of 2 rasters of gfx displayed.
                    ; once this loop ends it moves on to the next tile to draw.
                    ;
                    ; IN: -
                    ;   d1.w = world X co-ordinate
                    ;   a4.l = offscreen display buffer. 
                    ;
draw_background_horizontal_scroll   ; original address L00004b14   
L00004b14               movea.l background_gfx_base,a2      ;L00006352,a2

                    ; calc tile map x offset
L00004b18               move.w  d1,d2
L00004b1a               lsr.w   #$03,d2

                    ; calc src gfx Y clip
L00004b1c               move.w  scroll_window_y_coord,d1    ;L000069ee,d1
L00004b20               move.w  d1,d0
L00004b22               and.w   #$0007,d0

                    ; calc first tile draw loop count
                    ; clipping for first tile
L00004b26               move.w  d0,d5
L00004b28               not.w   d5
L00004b2a               and.w   #$0007,d5
L00004b2e               lsl.w   #$04,d0

                    ; calc tilemap src ptr
L00004b30               lsr.w   #$03,d1
L00004b32               lea.l   MAPGR_BASE,a0           ;$00008002,a0        ; MAPGR_BASE
L00004b38               move.w  (a0),d4
L00004b3a               mulu.w  d4,d1
L00004b3c               add.w   d2,d1
L00004b3e               lea.l   MAPGR_TILEDATA_OFFSET(a0,d1.W),a0   ;$7a(a0,d1.w),a0         ; MAPGR_TILEDATA_OFFSET

L00004b42               moveq   #DISPLAY_MAX_Y-1,d7     ;#$56,d7
L00004b44               move.w  offscreen_y_coord,d1    ;L0000635a,d1

                    ; calc start dest buffer address
L00004b48               moveq   #DISPLAY_MAX_Y-1,d6     ;#$56,d6
L00004b4a               sub.w   d1,d6
L00004b4c               mulu.w  #DISPLAY_2RASTERS,d1    ;#$0054,d1
L00004b50               lea.l   $00(a4,d1.l),a1

                    ; calc 1st tile gfx offset (maybe clipped)
L00004b54               clr.w   d1
L00004b56               move.b  (a0),d1
L00004b58               asl.w   #$07,d1
L00004b5a               add.w   d1,d0
L00004b5c               bra.b   L00004b6a
                        ;-----------------

                    ; continue displaying current tile
L00004b5e               dbf.w   d5,L00004b70

                    ; calc tile gfx offset
L00004b62               moveq   #$07,d5
L00004b64               clr.w   d0
L00004b66               move.b  (a0),d0
L00004b68               asl.w   #$07,d0

L00004b6a               lea.l   $00(a2,d0.w),a3
L00004b6e               adda.w  d4,a0

                    ; write 2 rasters of background gfx data 
L00004b70               move.w  (a3)+,DISPLAY_BUFFER_BPL0_OFFSET(a1)    ;(a1)
L00004b72               move.w  (a3)+,DISPLAY_BUFFER_BPL1_OFFSET(a1)    ;$1c8c(a1)
L00004b76               move.w  (a3)+,DISPLAY_BUFFER_BPL2_OFFSET(a1)    ;$3918(a1)
L00004b7a               move.w  (a3)+,DISPLAY_BUFFER_BPL3_OFFSET(a1)    ;$55a4(a1)
L00004b7e               move.w  (a3)+,DISPLAY_BUFFER_BPL0_OFFSET+DISPLAY_BYTEWIDTH(a1)  ;$002a(a1)
L00004b82               move.w  (a3)+,DISPLAY_BUFFER_BPL1_OFFSET+DISPLAY_BYTEWIDTH(a1)  ;$1cb6(a1)
L00004b86               move.w  (a3)+,DISPLAY_BUFFER_BPL2_OFFSET+DISPLAY_BYTEWIDTH(a1)  ;$3942(a1)
L00004b8a               move.w  (a3)+,DISPLAY_BUFFER_BPL3_OFFSET+DISPLAY_BYTEWIDTH(a1)  ;$55ce(a1)
L00004b8e               lea.l   DISPLAY_2RASTERS(a1),a1            ;$0054(a1),a1
L00004b92               dbf.w   d6,L00004b9a

                        ; increment next bitplane
L00004b96               lea.l   -DISPLAY_BUFFER_BYTES(a1),a1       ;-$1c8c(a1),a1

L00004b9a               dbf.w   d7,L00004b5e
L00004b9e               rts  


                    ;-------------------- copy off-screen buffer to back buffer --------------------------
                    ; This routine copies the background scroll GFX from the off-screen buffer into
                    ; the back buffer of the double-buffered display.
                    ;
                    ; the offscreen buffer is circular (i.e it wraps in the Y direction)
                    ; This means that the start (source gfx ptr) of the back buffer may vary any number
                    ; of rasters down into the buffer.
                    ;
                    ; so, when the gfx in the off-screen buffer aligned to the top, then only a single
                    ; full screen blit is required.
                    ;
                    ; whem the gfx in the offscreen buffer starts (x) rasters down the buffer then
                    ; the gfx requires two blits to the back buffer.
                    ;   1) one for the first section of the display
                    ;   2) for the wrapped portion of the display. 
                    ;
                    ; I like to think of the back buffer like an old CRT monitor where the picture
                    ; is rolling (mechanism used to manage the 8 way scrolling without requiring huge
                    ; double buffering)
                    ;;
                    ; This off-screen buffer needs to be re-aligned to the back buffer before
                    ; being displayed to the player.
                    ;
copy_offscreen_to_backbuffer    ; original address L00004ba0
                        ; blitter nasty - on
L00004ba0               move.w  #$8400,$00dff096
                        ; back buffer ptr
L00004ba8               movea.l playfield_buffer_2,a6               ;L000036ea,a6
L00004bac               subq.w  #$02,a6

L00004bae               movea.l offscreen_display_buffer_ptr,a5     ;L00006366,a5
L00004bb2               move.w  offscreen_y_coord,d1                ;L0000635a,d1
L00004bb6               clr.l   d6
L00004bb8               subq.w  #$01,d6
L00004bba               swap.w  d6
L00004bbc               move.w  scroll_window_x_coord,d2        ;L000069ec,d2
L00004bc0               and.w   #$0007,d2
L00004bc4               beq.b   L00004bca 
                        ; shift firstword/last word mask
L00004bc6               ror.l   d2,d6
L00004bc8               ror.l   d2,d6
                        ; calc blitter shift value (soft scroll x-axis)
L00004bca               neg.w   d2
L00004bcc               ror.w   #$03,d2
L00004bce               and.l   #$0000e000,d2
L00004bd4               bne.b   L00004bd8
                        ; no blit shift
L00004bd6               addq.w  #$02,a6
                        ; bltcon0 & bltcon1
L00004bd8               or.w    #$09f0,d2
L00004bdc               swap.w  d2
                        ; calc src address
L00004bde               move.w  d1,d4
L00004be0               mulu.w  #$0054,d4
L00004be4               lea.l   $00(a5,d4.l),a1
                        ; calc dest address
L00004be8               movea.l a6,a0
                        ; calc blit height
L00004bea               moveq   #$28,d3
L00004bec               move.w  #$00ae,d4
L00004bf0               sub.w   d1,d4
L00004bf2               sub.w   d1,d4

                        ; do blit 1 (maybe whole buffer or part buffer)
L00004bf4               bsr.w   blit_src_to_dest            ;L00004c1c

                        ; test 2nd blit required
L00004bf8               move.w  d1,d4
L00004bfa               beq.b   L00004c12

                        ; blit second half of scroll buffer
L00004bfc               moveq   #$57,d3
L00004bfe               sub.w   d4,d3
L00004c00               mulu.w  #$0054,d3
                        ; calc dest ptr
L00004c04               lea.l   $00(a6,d3.l),a0
                        ; blit height & width
L00004c08               add.w   d4,d4
L00004c0a               moveq   #$28,d3
                        ; dest ptr is top half of screen
L00004c0c               lea.l   (a5),a1
L00004c0e               bsr.w   blit_src_to_dest            ;L00004c1c
                        ;blitter nasty - off
L00004c12               move.w  #$0400,$00dff096
L00004c1a               rts  


                    ; -------------------- blit source to destination --------------------
                    ; Routine used by the copy_offscreen_to_backbuffer routine above
                    ; to copy the off-screen background scroll gfx into the back buffer
                    ; of the double buffered display.
                    ;
                    ; IN:-
                    ;   d2.l = BLTCON0 & BLTCON1 ($x9f00000) x = shift
                    ;   d3.w = Blit Width
                    ;   d4.w = Blit Height
                    ;   d6.l = firstword/lastwoord mask
                    ;   a0.l = DEST Blitter Address ptr
                    ;   a1.l = GFX Source Address ptr
blit_src_to_dest    ; original address L00004c1c
L00004c1c               move.l  d2,d5
L00004c1e               swap.w  d5
L00004c20               and.w   #$e000,d5
L00004c24               addq.w  #$02,d3
L00004c26               asl.w   #$06,d4
L00004c28               move.w  d3,d5
L00004c2a               lsr.w   #$01,d5
L00004c2c               add.w   d5,d4
L00004c2e               sub.w   #DISPLAY_BYTEWIDTH,d3       ;#$002a,d3
L00004c32               neg.w   d3
L00004c34               lea.l   CUSTOM,a4                   ;$00dff000,a4
L00004c3a               move.l  #DISPLAY_BUFFER_BYTES,d5    ;#$00001c8c,d5

                        ; blit wait
L00004c40               btst.b  #$0006,$00dff002
L00004c48               bne.b   L00004c40

L00004c4a               move.l  d6,BLTAFWM(a4)              ;$0044(a4)
L00004c4e               move.w  d3,BLTAMOD(a4)              ;$0064(a4)
L00004c52               move.w  d3,BLTDMOD(a4)              ;$0066(a4)
L00004c56               move.l  d2,BLTCON0(a4)              ;$0040(a4)

L00004c5a               moveq   #$03,d7

                        ; blit wait
L00004c5c               btst.b  #$0006,$00dff002
L00004c64               bne.b   L00004c5c

L00004c66               move.l  a1,BLTAPT(a4)               ;$0050(a4)
L00004c6a               move.l  a0,BLTDPT(a4)               ;$0054(a4)
L00004c6e               move.w  d4,BLTSIZE(a4)              ;$0058(a4)

L00004c72               adda.l  d5,a1
L00004c74               adda.l  d5,a0
                        ; loop next bitplane
L00004c76               dbf.w   d7,L00004c5c 
L00004c7a               rts 





                    ;-----------------------------------------------------------------
                    ; Player Move Commands
                    ;-----------------------------------------------------------------
                    ; Perform the player move command using the player_input_command
                    ; value read from the current joystick inputs.
                    ; Jump table into player input/movement commands
                    ;
                    ; IN:-
                    ;   - D0.w = L000067c2 - batman_x_offset
                    ;   - D1.w = L000067c4 - batman_y_offset
                    ; 
                    ; Code Checked 3/1/2025
                    ;
player_move_commands    ; original address L00004c7c
                        ;jsr     _DEBUG_COLOUR_GREEN

L00004c7c               clr.w   d2
L00004c7e               move.b  player_input_command,d2                 ;L00006350,d2
L00004c82               asl.w   #$02,d2
L00004c84               movea.l player_input_cmd_table(pc,d2.w),a0      ; $00004c8a
L00004c88               jmp     (a0)
                    ; each command ends with an RTS that returns to caller.

                    ; ------------- player input jump table ------------
                    ; the player_input_command byte is used as an index
                    ; into the table to execute the command associated
                    ; with the jotstick input.
                    ;
player_input_cmd_table 

L00004C8A           dc.l player_input_cmd_nop           ; $000052B6  
                    dc.l player_input_cmd_right         ; $0000526C 
                    dc.l player_input_cmd_left          ; $000052C2 
                    dc.l player_input_cmd_nop           ; $000052B6  
L00004C9A           dc.l player_input_cmd_down          ; $0000542C 
                    dc.l player_input_cmd_down_right    ; $00005266 
                    dc.l player_input_cmd_down_left     ; $000052B8 
                    dc.l player_input_cmd_nop           ; $000052B6  
L00004CAA           dc.l player_input_cmd_up            ; $00005236 
                    dc.l player_input_cmd_up_right      ; $0000526A 
                    dc.l player_input_cmd_up_left       ; $000052BE 
                    dc.l player_input_cmd_nop           ; $000052B6  
L00004CBA           dc.l player_input_cmd_nop           ; $000052B6 
                    dc.l player_input_cmd_nop           ; $000052B6 
                    dc.l player_input_cmd_nop           ; $000052B6 
                    dc.l player_input_cmd_nop           ; $000052B6  
L00004CCA           dc.l player_input_cmd_fire          ; $0000501E 
                    dc.l player_input_cmd_fire          ; $0000501E 
                    dc.l player_input_cmd_fire          ; $0000501E 
                    dc.l player_input_cmd_fire          ; $0000501E  
L00004CDA           dc.l player_input_cmd_fire_down     ; $0000540E 
                    dc.l player_input_cmd_fire_down     ; $0000540E 
                    dc.l player_input_cmd_fire_down     ; $0000540E 
                    dc.l player_input_cmd_fire_down     ; $0000540E  
L00004CEA           dc.l player_input_cmd_fire_up       ; $00005136 
                    dc.l player_input_cmd_fire_up_right ; $00005124 
                    dc.l player_input_cmd_fire_up_left  ; $0000512C 
                    dc.l player_input_cmd_nop           ; $000052B6  
L00004CFA           dc.l player_input_cmd_nop           ; $000052B6 
                    dc.l player_input_cmd_nop           ; $000052B6 
                    dc.l player_input_cmd_nop           ; $000052B6 
                    dc.l player_input_cmd_nop           ; $000052B6 



                    ; ------------------------- batman lose energy ---------------------------
                    ; IN: 
                    ;   d6.w - amount of energy to lose.
                    ;
batman_lose_energy  ; original address L00004d0a
L00004d0a               tst.b   PANEL_STATUS_1              ;$0007c874           ; PANEL_STATUS_1
L00004d10               bne.b   exit_rts                    ;L00004d74           ; exit rts

L00004d12               movem.l d0-d7/a5-a6,-(a7)
L00004d16               move.w  d6,d0
L00004d18               jsr     PANEL_LOSE_ENERGY           ;$0007c870           ; PANEL_LOSE_ENERGY
L00004d1e               movem.l (a7)+,d0-d7/a5-a6
                    ; falls though to updating state below




                    ; --------------- batman collision - state machine --------------------
                    ; Update the Batman State Machine to Perform Collision Detection
                    ; approptiate to Batman's current state.
                    ;   If falling between plaforms then exit
                    ;   Else If On BatRope, then do collision on batrope
                    ;   Else If On Ladder, then do collision on Ladder
                    ;   Else do collision on platform.
                    ;
                    ; Converted all ptrs to 32bits, original game used 16bit ptrs
                    ; due to hardcoded memory locations.
                    ;
                    ; IN:-
                    ;   D6.l = #$01 (set from main loop)
                    ;
batman_collision_state_machine  ; original address L00004d22
L00004d22               move.l  gl_jsr_address,d2                           ;L0003c7c,d2 

L00004d26               cmp.l   #player_state_falling,d2                    ;$000054ba,d2
L00004d2a               beq.b   exit_rts                                    ;L00004d74

L00004d2c               move.l  #player_state_actor_collide_on_batrope,d3   ;#$00004e78,d3
L00004d30               cmp.l   d3,d2
L00004d32               beq.b   L00004d5a

L00004d34               cmp.l   #player_state_grappling_hook_attached,d2    ;#$00004ea2,d2
L00004d38               beq.b   L00004d5a

L00004d3a               cmp.l   #player_state_climb_onto_platform,d2        ;#$00005096,d2
L00004d3e               beq.b   L00004d76

L00004d40               move.l  #player_state_actor_collide_on_ladder,d3    ;#$00004d86,d3
L00004d44               cmp.l   #state_climbing_stairs,d2                   ;#$0000532e,d2
L00004d48               beq.b   L00004d5a

L00004d4a               cmp.l   d2,d3
L00004d4c               beq.b   L00004d5a

L00004d4e               lea.l   batman_sprite_anim_fall_landing,a0          ;$0000548f,a0
L00004d52               bsr.w   set_batman_sprites                          ;L00005470
L00004d56               move.l  #player_state_check_actor_collision,d3      ;#$00004d94,d3

L00004d5a               move.l  d3,gl_jsr_address                           ; L00003c7c

L00004d5e               move.w  L0000634e,d2
L00004d62               add.w   d6,d6
L00004d64               add.w   d6,d6
L00004d66               add.w   d6,d2
L00004d68               cmp.w   #$000c,d2
L00004d6c               bcs.b   L00004d70
L00004d6e               moveq   #$0c,d2
L00004d70               move.w  d2,L0000634e
exit_rts            ; L00004d74
L00004d74               rts 



                    ; if 'climbing onto platform'
L00004d76               move.w  state_parameter,d2      ; L0000633a,d2
L00004d7a               add.w   d6,d2
L00004d7c               add.w   d6,d2
L00004d7e               add.w   d6,d2
L00004d80               move.w  d2,state_parameter      ;L0000633a
L00004d84               rts  




                    ; -------------- player state - actor collision on ladder -------------
                    ; This state gets called when Batman collides with an actor when
                    ; climbing a ladder.
                    ;
player_state_actor_collide_on_ladder    ; original address L00004d86
L00004d86               subq.w  #$01,L0000634e
L00004d8a               bne.b   exit_rts                                ;L00004d74
L00004d8c               move.l  #state_climbing_stairs,gl_jsr_address       ;#$0000532e,L00003c7c
L00004d92               bra.b   L00004db8




                    ; -------------- player state - drip and leak collision -------------
                    ; This state is called when the player collides with a toxic drip
                    ; or gas jet. Also if colliding with a 'bad guy' actor.
                    ;
                    ; Only occurs when batman is standing on a platform, not when 
                    ; climbing a ladder or swinging on a rope..
                    ;
                    ;
player_state_check_actor_collision  ;original address L00004d94
L00004d94               tst.w   grappling_hook_height                   ;L00006360
L00004d98               beq.b   L00004d9e
L00004d9a               bsr.w   player_state_retract_grappling_hook     ;L000051ee
L00004d9e               subq.w  #$01,L0000634e
L00004da2               bne.b   exit_rts                                ;L00004d74
L00004da4               move.l  #player_move_commands,gl_jsr_address    ;#$00004c7c,L00003c7c
L00004daa               tst.w   grappling_hook_height                   ;L00006360
L00004dae               beq.b   L00004db4
L00004db0               bsr.w   L000051e6

L00004db4               bsr.w   set_batman_standing_sprites             ;L00005468

L00004db8               tst.b   PANEL_STATUS_1                          ;$0007c874       ; PANEL_STATUS_1        
L00004dbe               beq.b   exit_rts                                ;L00004d74       ; exit rts


                    ; ----------------- set state - player life lost -----------------
                    ; This routine sets the state 'player life lost' state.
                    ; It updated the game loop state function to L00004da2
                    ; This method handles the player life lost animations etc.
                    ;
                    ; IN:-
                    ;   - D0.w = L000067c2 - batman_x_offset
                    ;   - D1.w = L000067c4 - batman_y_offset
                    ;
set_state_player_life_lost  ; original address L00004dc0
L00004dc0               jsr     AUDIO_PLAYER_SILENCE                    ;$00048004                               ; AUDIO_PLAYER_SILENCE
L00004dc6               clr.w   grappling_hook_height                   ;L00006360
L00004dca               moveq   #SFX_LIFE_LOST,d0                                 ; SFX_LIFE_LOST
L00004dcc               jsr     AUDIO_PLAYER_INIT_SONG                  ;$00048010                               ; AUDIO_PLAYER_INIT_SONG
L00004dd2               move.l  #player_state_life_lost,gl_jsr_address  ;#$00004de0,L00003c7c 
L00004dd8               move.l  #batman_sprite_anim_life_lost,batman_sprite_anim_ptr           ;L0000636e                        ; batman_sprite_anim_ptr
L00004dde               rts 


                    ; ----------------- player state life lost ------------------
                    ; Routine set in player state in the game_loop to manage
                    ; the player life lost state.
                    ;
player_state_life_lost  ; original address L00004de0
L00004de0               movea.l batman_sprite_anim_ptr,a0       ;(long) batman_sprite_anim_ptr
L00004de4               bsr.w   set_batman_sprites              ;L00005470
L00004de8               move.l  a0,batman_sprite_anim_ptr       ;L0000636e                    ; (long) 
L00004dec               tst.b   (a0)

;L00004dee               bne     L00004d74
L00004dee               beq.b    L00004df0          ; inverted logic
                        rts

                        ; prepare audio & display buffers
L00004df0               jsr     AUDIO_PLAYER_INIT_SFX_2         ;$0004800c                       ; AUDIO_PLAYER_INIT_SFX_2
L00004df6               move.w  #$0032,d0
L00004dfa               bsr.w   wait_for_frame_count            ;L00005ed4
L00004dfe               bsr.w   clear_backbuffer_playfield      ;L00004e66

                        ; test time up
L00004e02               btst.b  #PANEL_ST1_TIMER_EXPIRED,PANEL_STATUS_1 ;#$0000,$0007c874                ; PANEL_STATUS_1
L00004e0a               beq.b   L00004e14
                        ; time up
L00004e0c               lea.l   text_time_up,a0                 ;L00004e5a,a0
L00004e10               bsr.w   large_text_plotter              ;L000069fa

                        ; test lives
L00004e14               btst.b  #PANEL_ST1_NO_LIVES_LEFT,PANEL_STATUS_1     ;#$0001,$0007c874                ; PANEL_STATUS_1
L00004e1c               beq.b   L00004e26
                        ; display game-over message
L00004e1e               lea.l   text_game_over,a0               ;L00004e4c,a0
L00004e22               bsr.w   large_text_plotter              ;L000069fa

                        ; wipe display
L00004e26               bsr.w   screen_wipe_to_backbuffer       ;L00003caa
L00004e2a               move.w  #$001e,d0
L00004e2e               bsr.w   wait_for_frame_count            ;L00005ed4
                        ; test lives
L00004e32               btst.b  #PANEL_ST1_NO_LIVES_LEFT,PANEL_STATUS_1     ;#$0001,$0007c874                ; PANEL_STATUS_1
L00004e3a               beq.w   restart_level                   ;L00003AEC                       ; restart level
                    ; Fall through to return to Title Screen
                    ; if 'Game Over'



                    ; ------------------- return to title screen ------------------------
                    ; When the game is over, return to the titlle screen processing.
                    ; If test build then restart the level instead.
                    ;
return_to_title_screen  ; original address L00004e3e
L00004e3e               jsr     AUDIO_PLAYER_SILENCE    ; $00048004 
L00004e44               bsr.w   panel_fade_out          ; L00003d76

                    IFD TEST_BUILD_LEVEL
                        jsr _DEBUG_COLOURS
                        JMP return_to_title_screen
                    ENDC

L00004e48               bra.w   LOADER_TITLE_SCREEN     ;L00000820 
                    ; *************************************
                    ; ****        LOAD TITLE SCREEN     ***
                    ; *************************************


text_game_over  ; original address L00004E4C
L00004E4C           dc.b $5F,$0F
                    dc.b 'GAME  OVER'
                    dc.b $00,$FF 

text_time_up    ; original address L00004E5A          
L00004E5A           dc.b $43,$10
L00004E5C           dc.b 'TIME  UP'
                    dc.b $00,$FF

                even


                    ; ------------- clear back buffer playfield ------------
clear_backbuffer_playfield  ; original address L00004e66
                        movea.l playfield_buffer_2,a0       ;L000036ea,a0
                        move.w  #$1c8b,d7
L00004e70               clr.l   (a0)+
                        dbf.w   d7,L00004e70
                        rts 





                    ; -------------- player state - actor collide on batrope -----------
                    ; game_loop - Self Modified JSR Address
                    ; set at line of code L00004cee
                    ; ---- player state - actor Collision on batrope ------
player_state_actor_collide_on_batrope   ; original address L00004e78
L00004e78               moveq   #$10,d3
L00004e7a               tst.b   PANEL_STATUS_1                  ;$0007c874
L00004e80               bne.b   L00004e9e

L00004e82               lea.l   grappling_hook_height,a0        ;L00006360,a0
L00004e86               move.w  (a0),d2
L00004e88               cmp.w   #$0050,d2
L00004e8c               bcc.b   L00004e9e 
L00004e8e               addq.w  #$01,(a0)
L00004e90               clr.w   d3
L00004e92               subq.w  #$01,L0000634e 
L00004e96               bne.b   L00004e9e 
L00004e98               move.L  #player_state_grappling_hook_attached,gl_jsr_address    ;#$00004ea2,00003c7c 

                    ; update control command
L00004e9e               move.b  d3,player_input_command         ;L00006350
                    ; fall through to 'update_grappling_hook' below


                    ; --------- player state - grappling hook attached -----------
player_state_grappling_hook_attached    ; original address L00004ea2

L00004ea2               lea.l   grappling_hook_height,a0            ;L00006360,a0
L00004ea6               move.w  (a0),d5
L00004ea8               move.b  player_input_command,d4             ;L00006350,d4
L00004eac               btst.l  #PLAYER_INPUT_UP,d4                 ;#$0003,d4
L00004eb0               beq.b   L00004ee6 
L00004eb2               move.w  #$0048,target_window_y_offset       ;L000069f6 
L00004eb8               subq.w  #$01,d5
L00004eba               bhi.b   L00004ee4 
L00004ebc               clr.w   (a0) 
L00004ebe               move.l  #player_state_climb_onto_platform,gl_jsr_address    ;#$00005096,L00003c7c
L00004ec4               move.w  #$0005,state_parameter              ;L0000633a
L00004eca               move.l  #batman_sprite_anim_climb_platform,batman_sprite_anim_ptr       ;L0000636e                    ; (long)
L00004ed0               move.w  d1,d2
L00004ed2               add.w   scroll_window_y_coord,d2            ;L000069ee,d2
L00004ed6               subq.w  #$02,d2
L00004ed8               and.w   #$0007,d2
L00004edc               sub.w   d2,d1
L00004ede               move.w  d1,batman_y_offset                  ;L000069f4
L00004ee2               rts 


                    ; d5.w = grapling hook hright
                    ; d4.b = player_input_command
L00004ee4               move.w  d5,(a0)
L00004ee6               btst.l  #$0002,d4                   ; PLAYER_INPUT_DOWN
L00004eea               beq.w   L00004efe
                        ; player input down
L00004eee               move.w  #$0028,target_window_y_offset       ; L000069f6
L00004ef4               addq.w  #$01,d5
L00004ef6               cmp.w   #$0050,d5
L00004efa               bcc.b   L00004efe
L00004efc               move.w  d5,(a0)

L00004efe               lea.l   grappling_hook_params,a0            ;L0000635c,a0
L00004f02               movem.w (a0),d2-d3
L00004f06               clr.w   d7
L00004f08               moveq   #$07,d6
L00004f0a               cmp.w   #$0028,d5
L00004f0e               bcc.b   L00004f1a 
L00004f10               moveq   #$03,d6
L00004f12               cmp.w   #$0014,d6
L00004f16               bcc.b   L00004f1a 
L00004f18               moveq   #$01,d6
L00004f1a               and.w   playfield_swap_count,d6         ; L00006374,d6
L00004f1e               bne.b   L00004f2a
L00004f20               and.w   #$0003,d4
L00004f24               asr.w   #$01,d4
L00004f26               subx.w  d7,d4
L00004f28               move.w  d4,d7
L00004f2a               move.w  d2,d4
L00004f2c               ext.l   d4
L00004f2e               divs.w  d5,d4
L00004f30               sub.w   d7,d4
L00004f32               add.w   d4,d3
L00004f34               sub.w   d3,d2
L00004f36               add.w   #$0080,d2
L00004f3a               cmp.w   #$0100,d2
L00004f3e               bcc.b   L00004f46 
L00004f40               sub.w   #$0080,d2
L00004f44               bra.b   L00004f54 
L00004f46               clr.w   d3
L00004f48               sub.w   #$0080,d2
L00004f4c               bpl.b   L00004f52 
L00004f4e               moveq.l #$ffffff81,d2
L00004f50               bra.b   L00004f54 
L00004f52               moveq   #$7f,d2
L00004f54               movem.w d2-d3,(a0)

L00004f58               lea.l   grappling_hook_params,a0                ;L0000635c,a0
L00004f5c               lea.l   batman_xy_offset,a2                     ;L000069f2,a2
L00004f60               bsr.w   L000050e8

L00004f64               movem.w batman_xy_offset,d0-d1                  ;L000069f2,d0-d1
L00004f6a               movem.w L00006370,d5-d6
L00004f70               sub.w   d3,d5
L00004f72               move.w  d5,batman_swing_speed                   ;L0000633c
L00004f76               move.w  d5,L00006356
L00004f7a               sub.w   d6,d4
L00004f7c               move.w  d4,batman_fall_speed                    ;L0000633e
L00004f80               add.w   d4,d1
L00004f82               add.w   d5,d0
L00004f84               subq.w  #$04,d1
L00004f86               subq.w  #$05,d0
L00004f88               bsr.w   get_map_tile_at_display_offset_d0_d1    ; L000055e0
L00004f8c               moveq   #$02,d7
L00004f8e               move.b  $00(a0,d3.w),d2
L00004f92               cmp.b   #$03,d2
L00004f96               bcs.b   L00004fcc
L00004f98               move.b  $01(a0,d3.w),d2
L00004f9c               cmp.b   #$03,d2
L00004fa0               bcs.b   L00004fcc
L00004fa2               sub.w   MAPGR_BASE,d2                           ;$00008002,d3            ; MAPGR.IFF
L00004fa8               dbf.w   d7,L00004f8e
L00004fac               movem.w batman_xy_offset,d0-d1                  ; L000069f2,d0-d1
L00004fb2               add.w   d4,d1
L00004fb4               add.w   d5,d0
L00004fb6               movem.w d0-d1,batman_xy_offset                  ; L000069f2
L00004fbc               move.l  L00006362,L00006370
L00004fc2               btst.b  #PLAYER_INPUT_FIRE,player_input_command             ;L00006350
L00004fc8               bne.b   L00004fec 
L00004fca               rts  


L00004fcc               tst.w   d4
L00004fce               bmi.b   L00004fd8
L00004fd0               subq.w  #$02,grappling_hook_height  ;L00006360
L00004fd4               bra.w   L00004f58 


L00004fd8               movem.w d0-d7,-(a7)
L00004fdc               moveq   #$02,d6
L00004fde               bsr.w   batman_lose_energy      ;L00004d0a
L00004fe2               movem.w (a7)+,d0-d7
L00004fe6               clr.w   d4
L00004fe8               clr.w   d5
L00004fea               bra.b   L0000500a

L00004fec               movem.w batman_swing_fall_speed,d4-d5       ;L0000633c,d4-d5
L00004ff2               subq.w  #$03,d5
L00004ff4               cmp.w   #$fffa,d5
L00004ff8               bpl.b   L00004ffc
L00004ffa               moveq.l #$fffffffa,d5
L00004ffc               subq.w  #$02,d4
L00004ffe               cmp.w   #$fffc,d4
L00005002               bcc.b   L00005008
L00005004               smi.b   d4
L00005006               asl.w   #$02,d4
L00005008               addq.w  #$02,d4
L0000500a               movem.w d4-d5,batman_swing_fall_speed       ;L0000633c
L00005010               clr.w   grappling_hook_height               ;L00006360
L00005014               movem.w batman_xy_offset,d0-d1              ;L000069f2,d0-d1
L0000501a               bra.w   L0000549c 



                    ; --------------- player input command - fire ------------------
                    ; Called when the fire button is pressed on the joystick.
                    ;
                    ; IN:-
                    ;   - D0.w = L000067c2 - batman_x_offset
                    ;   - D1.w = L000067c4 - batman_y_offset
                    ;
player_input_cmd_fire  
L0000501e           move.l  #batman_sprite_anim_firing,batman_sprite_anim_ptr       ; L0000636e
L00005026           move.l  #player_state_firing,gl_jsr_address ;#$00005034,L00003c7c
L0000502c           moveq   #SFX_BATARANG,d0                    ;#$08,d0
L0000502e           jsr     AUDIO_PLAYER_INIT_SFX               ;$00048014
                    ; fall through to player_state_firing below...



                    ; ------------------- player state - firing ---------------------
                    ; batman state used to handle firing of 'bat-a-rang' projectile
                    ;
                    ; IN:-
                    ;   - D0.w = L000067c2 - batman_x_offset
                    ;   - D1.w = L000067c4 - batman_y_offset
                    ;
player_state_firing     ; original address L00005034
L00005034               movea.l batman_sprite_anim_ptr,a0               ;L0000636e,a0
L00005038               bsr.w   set_batman_sprites                      ;L00005470
L0000503c               move.l  a0,batman_sprite_anim_ptr               ;L0000636e
L00005040               tst.b   (a0)
L00005042               bne.b   L00005072 

L00005044               move.w  #$0008,state_parameter                  ;L0000633a 
L0000504a               move.l  #player_state_fired,gl_jsr_address      ;#$00005074,L00003c7c 
L00005050               bsr.w   get_empty_projectile                    ;L0000467c
L00005054               sub.w   #$0007,d0
L00005058               move.w  batman_sprite1_id,d2                    ;L00006336,d2
L0000505c               spl.b   d2
L0000505e               ext.w   d2
L00005060               bpl.b   L00005066
                        ; left facing
L00005062               add.w   #$000e,d0
                        ; right facing
L00005066               addq.w  #$03,d2
L00005068               move.w  d2,(a0)+        ; handler id
L0000506a               sub.w   #$0010,d1
L0000506e               movem.w d0-d1,(a0)      ; x,y
L00005072               rts  




                    ; -------------------- player state - fired -------------------
                    ; batman state entered after 'firing' state has completed.
                    ; this state displayed the throw animation for 8 frames
                    ; i.e. the value set in 'state_parameter' by thhe previous state
                    ; if player input is received then it short-cuts the anim
                    ; and returns to normal input processing.
                    ;
                    ; IN:-
                    ;   - D0.w = L000067c2 - batman_x_offset
                    ;   - D1.w = L000067c4 - batman_y_offset
                    ;                    ; 
                    ; Code Checked 4/1/2025
                    ;
player_state_fired      ; original address L00005074
L00005074               move.b  player_input_command,d4                     ;L00006350,d4
L0000507a               bne.w   L0000508c

L0000507e               subq.w  #$01,state_parameter                        ;L0000633a
;L00005082               bne.b   L00005072 
L00005082               beq.b   L00005084       ; inverted logic
                        rts
                    ; set end amination
L00005084               lea.l   batman_sprite_anim_standing,a0              ;L0000641b,a0
L00005088               bra.w   set_batman_sprites                          ;L00005470
                    ; use 'rts' in set_batman_sprites to return

                    ; set notmal joystick input state      
L0000508c               move.l  #player_move_commands,gl_jsr_address        ;#$00004c7c,L00003c7c  
L00005092               bra.w   player_move_commands                        ;L00004c7c 
                    ; use 'rts' in player_move_commands to return



                    ; routine inserted into self modified JSR
                    ; in game_loop by code line L00004e80
                    ;
                    ; -------------- player state - climb onto plaform
                    ; Player state when climbing onto a platform from your
                    ; bat-rope/grappling hook
                    ;
                    ; game_loop - collision state update, increments state_parameter by 3
                    ;               on each game loop cycle.
                    ;
player_state_climb_onto_platform    ; original address L00005096 
L00005096               subq.w  #$01,state_parameter                    ;L0000633a
;L0000509a               bne.b   L00005072 
L0000509a               beq.b   L0000509c               ; inverted logic
                        rts

L0000509c               move.w  #$0006,state_parameter                  ;L0000633a
L000050a2               subq.w  #$05,batman_y_offset                    ;L000069f4 
L000050a6               subq.w  #$04,d1
L000050a8               move.w  batman_sprite1_id,d2                    ;L00006336,d2
L000050ac               bmi.b   L000050c0 
L000050ae               addq.w  #$07,d0
L000050b0               bsr.w   get_map_tile_at_display_offset_d0_d1    ;L000055e0
L000050b4               cmp.b   #$03,d2
L000050b8               bcs.b   L000050d0
L000050ba               addq.w  #$01,batman_x_offset                    ;L000069f2
L000050be               bra.b   L000050d0
L000050c0               subq.w  #$06,d0
L000050c2               bsr.w   get_map_tile_at_display_offset_d0_d1    ;L000055e0
L000050c6               cmp.b   #$03,d2
L000050ca               bcs.b   L000050d0
L000050cc               subq.w  #$01,batman_x_offset                    ;L000069f2
L000050d0               movea.l batman_sprite_anim_ptr,a0               ; L0000636e,a0
L000050d4               bsr.w   set_batman_sprites                      ;L00005470
L000050d8               move.l  a0,batman_sprite_anim_ptr               ;L0000636e
L000050dc               move.b  (a0),d7
L000050de               bne.b   L000050e6
L000050e0               move.l  #return_to_standing,gl_jsr_address      ;#$0000544c,L00003c7c 
L000050e6               rts  



                    ; This appears to be calculating the left/right swing position
                    ; from a sin table multiplied by the rope length.
                    ; also, calculating the slight up/down as the cosine of the
                    ; x position.
                    ;
                    ; This may be wrong, as modifying this makes the hook firing fail.
                    ;
                    ;   IN:-
                    ;       a0 = L00006314 - grappling hook vars
                    ; 
L000050e8               lea.l   $7c(a0),a1          ;  index into sine table?
L000050ec               move.w  (a0),d2
L000050ee               asr.w   #$01,d2
L000050f0               move.w  d2,d4
L000050f2               bpl.b   L000050f6
L000050f4               neg.w   d4

L000050f6               clr.w   d3
L000050f8               move.b  -$40(a1,d4.w),d3     ; $c0(a1,d4.w),d3 ($c0 = -64)
L000050fc               mulu.w  $0004(a0),d3
L00005100               btst.l  #$000f,d2
L00005104               beq.b   L00005108

L00005106               neg.w   d3

L00005108               asr.w   #$08,d3
L0000510a               move.w  d3,$0006(a0)

L0000510e               move.w  d4,d2
L00005110               neg.w   d2
L00005112               clr.w   d4
L00005114               move.b  $3f(a1,d2.w),d4         ; 63 =$3f
L00005118               mulu.w  $0004(a0),d4
L0000511c               lsr.w   #$08,d4
L0000511e               move.w  d4,$0008(a0)
L00005122               rts  



                    ; ------------ player input command - fire + up + right --------------
                    ; Player input command executed when the joystick 'fire + up + right'
                    ; is selected;
                    ;
                    ; IN:-
                    ;   - D0.w = L000067c2 - batman_x_offset
                    ;   - D1.w = L000067c4 - batman_y_offset
                    ;
                    ;
player_input_cmd_fire_up_right  ; original address L00005124
L00005124               clr.w   batman_sprite1_id               ;L00006336
L00005128               moveq   #$7f,d0
L0000512a               bra.b   player_input_fire_up_common     ;L00005138



                    ; ------------ player input command - fire + up + left --------------
                    ; Player input command executed when the joystick 'fire + up + left'
                    ; is selected;
                    ;
                    ; IN:-
                    ;   - D0.w = L000067c2 - batman_x_offset
                    ;   - D1.w = L000067c4 - batman_y_offset
                    ;
player_input_cmd_fire_up_left   ; original address L0000512c 
L0000512c               move.w  #$e000,batman_sprite1_id            ;L00006336
L00005132               moveq.l #$ffffff81,d0
L00005134               bra.b   player_input_fire_up_common         ;L00005138 



                    ; ------------ player input command - fire + up --------------
                    ; Player input command executed when the joystick 'fire + up'
                    ; is selected;
                    ;
                    ; IN:-
                    ;   - D0.w = L000067c2 - batman_x_offset
                    ;   - D1.w = L000067c4 - batman_y_offset
                    ;
player_input_cmd_fire_up    ; original address L00005136  
L00005136               clr.w d0
                    ; fall through to 'player_input_fire_up_common' below...



                    ; --------------- player input fire up common -----------------
                    ; Common code called by the routines:-
                    ;   player_input_cmd_fire_up_right
                    ;   player_input_cmd_fire_up_left
                    ;   player_input_cmd_fire_up
                    ;
                    ; IN:-
                    ;   d0.w - 0 = up, -127 = up + left, +127 = up + right
                    ;   d1.w = batman y offset
                    ;
                    ; Code Checked 6/1/2025
                    ;
player_input_fire_up_common ; original address L00005138
L00005138               move.w  #$0048,target_window_y_offset       ;L000069f6
L0000513e               lea.l   grappling_hook_params,a0            ;L0000635c,a0
L00005142               move.w  d0,(a0)+
L00005144               clr.l   (a0)+ 
L00005146               bsr.w   get_empty_projectile                ;L0000467c
                        ; a0 = emppty projectile
L0000514a               move.w  #$0001,(a0)
L0000514e               move.l  #player_state_firing_grappling_hook,gl_jsr_address  ;#$00005170,L00003c7c
                        ; set initial batman sprite animation
L00005154               lea.l   batman_sprite_anim_fire_hook,a0     ;;L00006418,a0
L00005158               bsr.w   set_batman_sprites                  ;L00005470
                        ; play sound fx
L0000515c               moveq   #SFX_BATROPE,d0                     ;#$07,d0
L0000515e               jsr     AUDIO_PLAYER_INIT_SFX               ;$00048014 

L00005164               movem.w batman_xy_offset,d0-d1              ; L000069f2,d0-d1
L0000516a               bclr.b  #PLAYER_INPUT_FIRE,player_input_command         ;L00006350
                    ; fall through to 'player_state_firing_grappling_hook' below



                    ; ------------------- player state - firing grappling hook ----------------
                    ; game_loop state for batman firing the gappling hook.
                    ; also initially called from player_input_fire_up_common above
                    ;
                    ; IN:-
                    ;   - D0.w = L000067c2 - batman_x_offset
                    ;   - D1.w = L000067c4 - batman_y_offset
                    ;   - D3.w = window x?
                    ;   - D4.w = window y?
                    ;
                    ;
                    ;
player_state_firing_grappling_hook  ; original address L00005170
L00005170               lea.l   grappling_hook_params,a0                ;L0000635c,a0
L00005174               btst.b  #PLAYER_INPUT_FIRE,player_input_command             ;L00006350 
L0000517c               bne     stop_grappling_hook                     ;L000051fc

L0000517e               move.w  $0004(a0),d2
                    ; increment len
                    ; make batrope longer (slows down as it get longer)
                    ; if longer than 40 then increment = 2.
                    ; if between 20 and 40 then increment by 3.
                    ; if shorter than 20 increment by 4.
L00005182               addq.w  #$02,d2

L00005184               cmp.w   #$0028,d2
L00005188               bcc.b   L00005194 
                        ; increment len
L0000518a               addq.w  #$01,d2

L0000518c               cmp.w   #$0014,d2
L00005190               bcc.b   L00005194
                        ; increment len
L00005192               addq.w  #$01,d2

L00005194               move.w  d2,$0004(a0)
L00005198               bsr.w   L000050e8

L0000519c               addq.w  #$03,d3
L0000519e               move.w  batman_sprite1_id,d7                    ;L00006336,d7
L000051a2               bpl.b   L000051a6

L000051a4               subq.w  #$07,d3

L000051a6               add.w   #$000a,d4
L000051aa               sub.w   d4,d1
L000051ac               bcs.b   L000051e6       ; set retract hook

L000051ae               move.w  scroll_window_y_coord,d5                ;L000069ee,d5
L000051b2               add.w   d1,d5
L000051b4               btst.l  #$0002,d5
L000051b8               bne.b   L000051ec       ; exit
L000051ba               add.w   d3,d0

                    ; tilemap collision
L000051bc               bsr.w   get_map_tile_at_display_offset_d0_d1    ;L000055e0
L000051c0               cmp.b   #$03,d2
L000051c4               bcs.b   L000051e6       ; set retract hook 

L000051c6               cmp.b   #$5f,d2
L000051ca               bcc.b   L000051e6       ; set retract hook 

L000051cc               cmp.b   #$51,d2
L000051d0               bcs.b   L000051ec       ; exit

                    ; grabed platform
                        
L000051d2               move.l  #player_state_grappling_hook_attached,gl_jsr_address    ;#$00004ea2,00003c7c 
L000051d8               move.l  L00006362,L00006370

L000051de               lea.l   batman_sprite_anim_07,a0        ;L0000645e,a0
L000051e2               bra.w   set_batman_sprites                                      ;L00005470 
                    ; use 'rts' in set_batman_sprites to return

                    ; wall, ladder, collision
                    ; retract grappling hook state
L000051e6               move.l  #player_state_retract_grappling_hook,gl_jsr_address     ;#$000051ee,L00003c7c
L000051ec               rts 





                    ; ------------- player state - retract grappling hook --------------
                    ; When firing the grappling hook and it hits the 'wall' or 'ladder'
                    ; then this state is used to retract the grappling hook back 
                    ; towards batman. 
                    ;
                    ; IN:-
                    ;   - D0.w = L000067c2 - batman_x_offset
                    ;   - D1.w = L000067c4 - batman_y_offset
                    ;   - D3.w = window x?
                    ;   - D4.w = window y?
                    ;
player_state_retract_grappling_hook     ; original address L000051ee
L000051ee               lea.l   grappling_hook_params,a0                    ;L0000635c,a0
L000051f2               btst.b  #PLAYER_INPUT_FIRE,player_input_command                 ;L00006350
L000051fa               beq.b   shorten_grappling_hook          ;L00005202
                    ; if fire is pressed then shortcut the retraction.
                    ; fall through to stop_grappling_hook

                    ; IN:-
                    ;   a0.l = L00006314  (offset 4 = grappling hook height)
                    ;                    
stop_grappling_hook     ; original address L000051fc                    
L000051fc               move.w  #$0002,$0004(a0)
shorten_grappling_hook  ; original address L00005202
L00005202               subq.w  #$03,$0004(a0)
L00005206               bls.b   exit_fire_grappling_hook_state      ;L0000520c 
L00005208               bra.w   L000050e8 




exit_fire_grappling_hook_state  ; original address L0000520c
L0000520c               clr.w   $0004(a0)
L00005210               move.l  #player_move_commands,gl_jsr_address        ;#$00004c7c,L00003c7c
L00005216               lea.l   batman_sprite_anim_standing,a0              ;L0000641b,a0
L0000521a               bra.w   set_batman_sprites                          ;L00005470 
L0000521e               rts  



                    ; ----------------------- check climb down --------------------
                    ; This routine checks whether batman is on the top of a ladder or
                    ; stairwell and if so, changes the state for the player input.
                    ;
                    ; called from:
                    ;           player_input_cmd_down
                    ;           player_input_cmd_down_right
                    ;           player_input_cmd_down_left
                    ;
                    ; IN:-
                    ;   - D0.w = L000067c2 - batman_x_offset
                    ;   - D1.w = L000067c4 - batman_y_offset
                    ;
player_check_climb_down ; original address L00005220
L00005220               move.w  #$0028,target_window_y_offset           ; L000069f6
L00005226               addq.w  #$04,d0
L00005228               bsr.w   get_map_tile_at_display_offset_d0_d1    ; L000055e0
L0000522c               subq.w  #$04,d0
L0000522e               cmp.b   #$5f,d2
L00005232               bne.b   L0000521e        ; exit
L00005234               bra.b   set_player_state_climbing               ;L00005254 



                    ; --------------------- player inpout command - up ----------------
                    ; Player input command, called from player move state when
                    ; joystick 'up' is selected
                    ;   
                    ; IN:-
                    ;   - D0.w = L000067c2 - batman_x_offset
                    ;   - D1.w = L000067c4 - batman_y_offset
                    ;
                    ; Code Checked 4/1/2025
                    ;
player_input_cmd_up
L00005236               bsr.b   input_up_common                 ;L0000523c
L00005238               bra.w   set_batman_standing_sprites     ;L00005468
                    ; use rts from set_batman_sprites to return



                    ; ------------------- input up common -----------------
                    ; Player input up common processing logic.
                    ;
                    ; Called from:
                    ;   player_input_cmd_up_left
                    ;   player_input_cmd_up_right
                    ;   player_input_cmd_up
                    ;
                    ; IN:-
                    ;   - D0.w = L000067c2 - batman_x_offset
                    ;   - D1.w = L000067c4 - batman_y_offset
                    ;
                    ; Code Checked 4/1/2025
                    ;
input_up_common     ; original address L0000523c
L0000523c               move.w  #$0048,target_window_y_offset           ;L000069f6
L00005242               addq.w  #$04,d0
L00005244               subq.w  #$04,d1
L00005246               bsr.w   get_map_tile_at_display_offset_d0_d1    ;L000055e0
L0000524a               addq.w  #$04,d1
L0000524c               subq.w  #$04,d0
L0000524e               cmp.b   #$62,d2
L00005252               bne.b   L0000521e



                    ; --------------------- set player state climbing --------------------
                    ; Change player state to climbing (ladder or stairs) in game_loop
                    ;
                    ; 1) Occurs when at bottom of ladder and start to climb.
                    ;    Also Occurs when climbed to top of ladder and up is pushed.
                    ; 2) Occirs when at top of ladder and start to descend.
                    ;    DOESN'T Occur when descened to bottom of ladder and down is pushed.
                    ;
                    ; Manipulates the stack, so that the caller returns and does not
                    ; proceed to call standard player_input_down processing
                    ;
set_player_state_climbing   ; original address L00005254
L00005254               addq.w  #$04,a7
L00005256               and.b   #$0c,player_input_command                   ;L00006350
L0000525c               move.l  #state_climbing_stairs,gl_jsr_address       ;#$000532e,L00003c7c
L00005262               bra.w   state_climbing_stairs                       ;L0000532e 






                    ; -------------------- player input command - down right --------------------
                    ; Command to execute when joystick input is set to diagaonal 'down-right'
                    ;
                    ;
                    ; IN:-
                    ;   - D0.w = L000067c2 - batman_x_offset
                    ;   - D1.w = L000067c4 - batman_y_offset
                    ;
                    ; Code Checked 3/1/2025
                    ;
player_input_cmd_down_right ; original address L00005266
L00005266               bsr.b player_check_climb_down                       ;L00005220
                        ; if on a ladder then manipulates stack to return to caller
                        ; does not execute the following code.
L00005268               bra.b player_input_cmd_right            ;L0000526c 



                    ; ------------------- player input command - up right ------------------
                    ; Command executed when joystick input is set to diagonal 'up-right'
                    ;;
                    ; IN:-
                    ;   - D0.w = L000067c2 - batman_x_offset
                    ;   - D1.w = L000067c4 - batman_y_offset
                    ;
                    ; Code Checked 4/1/2025
                    ;
player_input_cmd_up_right   ; original address L0000526a 
L0000526a               bsr.b input_up_common           ;L0000523c
                    ; perform common move right processing
                    ; falls through to player_input_cmd_right below




                    ; ------------------- player input command right ------------------------
                    ; Command to walk batman to the right, when joystick right is selected.
                    ;
                    ; Checks tile to batman's right, if wall (tile > 23) then exit.
                    ; otherwise move 1 unit to right (2 pixels) and check if now falling.
                    ; if not falling the set sprite walk right animation.
                    ;   - animation is selected from batman's x co-ordinate to choose
                    ;     animation frames for legs (sprite 3) and body (sprite 2)
                    ;     the head sprite is always set to id = 1 (sprite 1)
                    ;
                    ; IN:-
                    ;   - D0.w = L000067c2 - batman_x_offset
                    ;   - D1.w = L000067c4 - batman_y_offset
                    ;
                    ; Code Checked 3/1/2025
                    ;
player_input_cmd_right  ; original address L0000526c
                    ; test wall collision



L0000526c               addq.w  #$04,d0
L0000526e               subq.w  #$02,d1
L00005270               bsr.w   get_map_tile_at_display_offset_d0_d1    ;L000055e0
L00005274               cmp.b   #$03,d2
L00005278               bcs.b   early_exit_rts                          ; exit rts - L000052b6 

                    ; move batman to right (2 pixels)
L0000527a               addq.w  #$01,batman_x_offset                    ; L000069f2

                    ; test platform collison (14 pixels below)
L0000527e               addq.w  #$07,d1
L00005280               subq.w  #$05,d0
L00005282               bsr.w   get_map_tile_at_display_offset_d0_d1    ;L000055e0
L00005286               sub.b   #$51,d2
L0000528a               cmp.b   #$10,d2
L0000528e               bcc.w   set_player_state_falling                ;L00005492
                        ;--------------

                    ; update batman walk sprite animation
                    ; uses scroll position to choose animation
L00005292               lea.l   batman_sprite3_id,a0                    ;L00006332,a0
L00005296               add.w   scroll_window_x_coord,d0                ;L000069ec,d0
L0000529a               lsr.w   #$01,d0
L0000529c               and.w   #$0007,d0
L000052a0               addq.w  #$05,d0
L000052a2               move.w  d0,(a0)+
                    ; sprite 2 - batman arms
L000052a4               and.w   #$0006,d0
L000052a8               lsr.w   #$01,d0
L000052aa               bne.b   L000052ae
L000052ac               moveq   #$02,d0
L000052ae               addq.w  #$01,d0
L000052b0               move.w  d0,(a0)+ 
                    ; batman head
L000052b2               move.w  #$0001,(a0) 
                        rts



early_exit_rts          ; original address L000052b6
                        ; code added to separate out usage
                        rts

actor_handler_cmd_nop   ; original address L000052b6
                        ; code added to separate out usage
                        rts


                    ; ----------- player_move_commands - input NOP -------------
                    ; Called by player_move_commands default input routine.
                    ; performs a op-operation for unexpected input values.
                    ; Also called as a quick exit from other routines.
                    ;
player_input_cmd_nop    ; original address L000052b6
L000052b6               rts 





                    ; -------------------- player input command - down left --------------------
                    ; Command to execute when joystick input is set to diagaonal 'down-left'
                    ;
                    ;
                    ; IN:-
                    ;   - D0.w = L000067c2 - batman_x_offset
                    ;   - D1.w = L000067c4 - batman_y_offset
                    ;
                    ; Code Checked 4/1/2025
                    ;
player_input_cmd_down_left  ; original address L000052b8
L000052b8               bsr.w   player_check_climb_down                     ;L00005220
                        ; if on a ladder then manipulates stack to return to caller
                        ; does not execute the following code. 
L000052bc               bra.b   player_input_cmd_left       ; L000052c2 


                    ; -------------------- player input command - up left --------------------
                    ; Command to execute when joystick input is set to diagaonal 'up-left'
                    ;
                    ;
                    ; IN:-
                    ;   - D0.w = L000067c2 - batman_x_offset
                    ;   - D1.w = L000067c4 - batman_y_offset
                    ;
                    ; Code Checked 4/1/2025
                    ;
player_input_cmd_up_left    ; original address L000052be  
L000052be               bsr.w   input_up_common         ;L0000523c
                    ; falls through to player_input_cmd_left below



                    ; ------------------- player input command left ------------------------
                    ; Command to walk batman to the left, when joystick left is selected.
                    ;
                    ; Checks tile to batman's left, if wall (tile > 23) then exit.
                    ; otherwise move 1 unit to left (2 pixels) and check if now falling.
                    ; if not falling the set sprite walk left animation.
                    ;   - animation is selected from batman's x co-ordinate to choose
                    ;     animation frames for legs (sprite 3) and body (sprite 2)
                    ;     the head sprite is always set to id = 1 (sprite 1)
                    ;
                    ; IN:-
                    ;   - D0.w = L000067c2 - batman_x_offset
                    ;   - D1.w = L000067c4 - batman_y_offset
                    ;
                    ; Code Checked 4/1/2025
                    ;
player_input_cmd_left   ; original address L000052c2
                    ; test all collision
L000052c2               subq.w  #$05,d0
L000052c4               subq.w  #$02,d1
L000052c6               bsr.w   get_map_tile_at_display_offset_d0_d1    ;L000055e0
L000052ca               cmp.b   #$03,d2
L000052ce               bcs.b   early_exit_rts                          ; exit rts - L000052b6 

                    ; move batman left (2 pixels)
L000052d0               subq.w  #$01,batman_x_offset                    ;L000069f2

                    ; test platform collision
L000052d4               addq.w  #$07,d1
L000052d6               addq.w  #$05,d0
L000052d8               bsr.w   get_map_tile_at_display_offset_d0_d1    ;L000055e0
L000052dc               sub.b   #$51,d2
L000052e0               cmp.b   #$10,d2
L000052e4               bcc.w   set_player_state_falling                ;L00005492 
                        ;--------------
                        
                    ; update batman walk sprite animation
                    ; uses scroll position to choose animation
L000052e8               lea.l   batman_sprite3_id,a0                    ;L00006332,a0
L000052ec               add.w   scroll_window_x_coord,d0                ;L000069ec,d0
L000052f0               not.w   d0
L000052f2               lsr.w   #$01,d0
L000052f4               and.w   #$0007,d0
L000052f8               add.w   #$e005,d0
L000052fc               move.w  d0,(a0)+
                        ; set sprite 2 - batman arms
L000052fe               and.w   #$e006,d0
L00005302               lsr.b   #$01,d0
L00005304               bne.b   L0000530a
L00005306               move.w  #$e002,d0
L0000530a               addq.w  #$01,d0
L0000530c               move.w  d0,(a0)+ 
                        ; set sprite 1 - batman head
L0000530e               move.w  #$e001,(a0) 
L00005312               rts  


                    ; ------------------- exit climbing state ---------------------
                    ; Looks like code to return to normal joystick input handling.
                    ;
                    ; 1) Occurs when at top of ladder and Left/Right pushed
                    ; 2) Occurs when at bottom of ladder and Down-Left/Down/Right pushed
                    ;
                    ; DOESN'T Occur when at bottom of ladder and Down Only is pushed
                    ;
                    ; Not sure what the tile check 134 and the jump back into 
                    ; climbing code is doing. Look 'hacky' wish i knew what tile 134 was...
                    ;
                    ; IN:
                    ;   d5.w - +ve = Exit Right, -ve = Exit Left
                    ;
exit_climbing_state ; original address L00005314
L00005314               add.w   d5,d3
L00005316               move.b  $00(a0,d3.w),d2
L0000531a               sub.b   #$51,d2
L0000531e               cmp.b   #$10,d2
L00005322               bcc     L0000538e 
                    ; return to normal joystick movement state.
                    ; back on a platform.
L00005324               move.l  #player_move_commands,gl_jsr_address        ;#$0004c7c,L00003c7c
L0000532a               bra.w   player_move_commands                        ;L00004c7c 



                    ; ----------------- batman climb stairs -------------------
                    ; inserted into game loop self modified code for batman
                    ; control state updates.
                    ; state is entered via the up/down input command handlers
                    ;
                    ; IN:-
                    ;   - D0.w = L000067c2 - batman_x_offset
                    ;   - D1.w = L000067c4 - batman_y_offset
                    ;
                    ;
state_climbing_stairs   ; original address L0000532e
L0000532e               btst.b  #$0004,player_input_command             ;L00006350
L00005334               bne.w   set_player_state_falling                ;L00005492
                        ;-------------

                        ; 25hz update
L00005338               btst.b  #$0000,playfield_swap_count+1           ;L00006375 
L0000533e               bne.b   L00005312 

                        ; test for tile boundary
L00005340               clr.w   d4
L00005342               move.b  player_input_command,d4                 ;L00006350,d4
L00005346               move.w  scroll_window_y_coord,d2                ;L000069ee,d2
L0000534a               add.w   d1,d2
L0000534c               and.w   #$0007,d2
L00005350               beq.b   L00005374

L00005352               btst.l  #PLAYER_INPUT_DOWN,d4                   ;#$0002,d4
L00005356               beq.b   L00005360       

                        ; climb down through tile
L00005358               addq.w  #$01,d1
L0000535a               move.w  #$0028,target_window_y_offset           ;L000069f6

L00005360               btst.l  #PLAYER_INPUT_UP,d4                     ;#$0003,d4
L00005364               beq.b   L0000536e
                        ; climb up through tile
L00005366               subq.w  #$01,d1
L00005368               move.w  #$0048,target_window_y_offset           ;L000069f6

                        ; store updated Y position
L0000536e               move.w  d1,batman_y_offset                      ;L000069f4
L00005372               bra.b   L000053c8 
                        ;----------------

                        ; on tile boundary - check climb exit
L00005374               bsr.w   get_map_tile_at_display_offset_d0_d1    ;L000055e0
L00005378               move.w  d4,d5
L0000537a               and.b   #$03,d5
L0000537e               move.b  d5,player_input_command                 ;L00006350

                        ; check push right
L00005382               moveq   #$01,d5
L00005384               asr.w   #$01,d4
L00005386               bcs     exit_climbing_state                     ;L00005314

                        ; check push left
L00005388               moveq.l #$ffffffff,d5
L0000538a               asr.w   #$01,d4
L0000538c               bcs     exit_climbing_state                     ;L00005314

L0000538e               asr.w   #$01,d4
L00005390               bcc.b   L000053a6
                        ; check map tile
L00005392               move.w  #$0028,target_window_y_offset           ;L000069f6
L00005398               cmp.b   #$5f,d2
L0000539c               bcs.w   set_player_move_commands_state          ;L00005406
                        ; climb down
L000053a0               addq.w  #$01,batman_y_offset                    ;L000069f4
L000053a4               bra.b   L000053c8 
                        ;-----------------

                        ; do climb up
L000053a6               asr.w   #$01,d4
L000053a8               bcc.b   L00005404 

                        ; check map tile
L000053aa               move.w  #$0048,target_window_y_offset           ;L000069f6 
L000053b0               move.w  MAPGR_BASE,d5                           ;$00008002,d5
L000053b6               sub.w   d5,d3
L000053b8               move.b  $00(a0,d3.w),d2
L000053bc               cmp.b   #$5f,d2
L000053c0               bcs.b   set_player_move_commands_state          ;L00005406

                        ; climb ladder
L000053c2               subq.w  #$01,d1
L000053c4               move.w  d1,batman_y_offset                      ;L000069f4

                        ; different code to code1.s
L000053c8               moveq   #$31,d3
L000053ca               btst.b  #$0003,player_input_command             ;L00006350
L000053d0               bne.b   L000053dc
L000053d2               addq.w  #$05,d3
L000053d4               btst.b  #$0002,player_input_command             ;L00006350
L000053da               beq.b   L00005404

                        ; set climbing animation?
L000053dc               move.w  scroll_window_y_coord,d2                ;L000069ee,d2
L000053e0               add.w   batman_y_offset,d2                      ;L000069f4,d2
L000053e4               addq.w  #$02,d2
L000053e6               not.w   d2
L000053e8               and.w   #$0007,d2
L000053ec               bclr.l  #$0002,d2
L000053f0               beq.b   L000053f6 
                        ; left facing
L000053f2               add.w   #$e000,d3
                        ; right facing
L000053f6               addq.w  #$01,d2
L000053f8               add.w   d3,d2
L000053fa               lea.l   batman_sprite3_id,a0                    ;L00006332,a0
L000053fe               clr.w   (a0)+ 
L00005400               move.w  d2,(a0)+ 
L00005402               move.w  d3,(a0) 
L00005404               rts  


                        ;--------------- set player move commands state ----------------
                        ; restore player state to normal joystick control
set_player_move_commands_state      ; original address L00005406
L00005406                move.l #player_move_commands,gl_jsr_address        ;#$0004c7c,L00003c7c
L0000540c                rts 




                    ; ------------------ player input command - fire + down ---------------------
                    ; Player input command called when joystick input 'fire and down' is selected
                    ; Also, used as game_loop state update routine $00005f38
                    ;
                    ; IN:-
                    ;   - D0.w = L000067c2 - batman_x_offset
                    ;   - D1.w = L000067c4 - batman_y_offset
                    ;
                    ;
player_input_cmd_fire_down  ;original address L0000540e
L0000540e               add.w   #$0008,d1
L00005412               bsr.w   get_map_tile_at_display_offset_d0_d1    ; L000055e0
L00005416               movem.w batman_xy_offset,d0-d1
L0000541c               cmp.b   #$03,d2
L00005420               bcs.b   player_input_cmd_down                   ;L0000542c
                        ; fall through platform
                        ; disable platform collision
                        ; self modifiying code see address L00005546
L00005422               move.w  #$8000,L00005546
L00005428               bra.w   set_player_state_falling                ;L00005492
                    ; use 'rts' in set_player_falling_state to return
; Line 5885 in Code1.s



                    ; ------------------ player input command - down ---------------------
                    ; Player input command called when joystick input 'down' is selected
                    ;
                    ; IN:-
                    ;   - D0.w = L000067c2 - batman_x_offset
                    ;   - D1.w = L000067c4 - batman_y_offset
                    ;
player_input_cmd_down   ; original address L0000542c 
L0000542c               bsr.w   player_check_climb_down                     ;L00005220
L00005430               lea.l   batman_sprite_anim_ducking,a0               ;L0000641e,a0
L00005434               bsr.b   set_batman_sprites                          ;L00005470
L00005436               move.l  #player_state_ducking,gl_jsr_address        ;#$000543e,L00003c7c
L0000543c               rts  



                    ; ----------------------- player state - ducking --------------------
                    ; The state entered into the game_loop when batman is ducking down.
                    ;
                    ;
player_state_ducking    ; original address L0000543e
L0000543e               lea.l   batman_sprite_anim_ducked,a0                ;L00006421,a0
L00005442               bsr.b   set_batman_sprites                          ;L00005470
L00005444               btst.b  #PLAYER_INPUT_DOWN,player_input_command     ;L00006350
L0000544a               bne.b   L00005458

return_to_standing  ; original address L0000544c
L0000544c               move.l  #set_player_state_standing,gl_jsr_address   ;#$0005462,L00003c7c
L00005452               lea.l   batman_sprite_anim_ducking,a0               ;L0000641e,a0
L00005456               bra.b   set_batman_sprites                          ;L00005470
                        ; duck,check fire
L00005458               btst.b  #PLAYER_INPUT_FIRE,player_input_command     ;L00006350 
L0000545e               bne.b   player_input_cmd_fire_down                  ;L0000540e
L00005460               rts  


                    ; --------------- set player status - standing ---------------
                    ; Called when leaving the 'ducked' state. Returns batman to
                    ; a standing sprite and standard input checing.
                    ;
                    ;
set_player_state_standing   ; original address L00005462
L00005462               move.l  #player_move_commands,gl_jsr_address    ;#$0004c7c,L00003c7c


set_batman_standing_sprites ; original address L00005468        
L00005468               lea.l   batman_sprite_anim_standing,a0              ;L0000641b,a0
L0000546c               bra.w   set_batman_sprites                          ;L00005470
                    ; use 'rts' in set_batman_sprites to return


                    ; ----------------- set batman sprites --------------------
                    ; Sets batman sprites 1, 2 & 3 from the values passed in 
                    ; the 3 byte array.
                    ;
                    ; IN: 
                    ;   A0.l = address ptr to animation (3 byte array of sprite id's)
                    ; 
set_batman_sprites  ; original address L00005470
L00005470               move.w  d7,-(a7)
L00005472               lea.l   batman_sprite1_id,a1        ;L00006336,a1
                    ; preserve left/right facing directions
L00005476               move.w  (a1),d7
L00005478               and.w   #$e000,d7
                    ; set first sprite id
L0000547c               add.b   (a0)+,d7
L0000547e               move.w  d7,(a1)
                    ; add second sprite id offset
L00005480               add.b   (a0)+,d7
L00005482               move.w  d7,-(a1)
                    ; add thrid sprite id offset
L00005484               add.b   (a0)+,d7
L00005486               move.w  d7,-(a1)
                    ; restore registers & exit
L00005488               move.w  (a7)+,d7
L0000548a               rts  


batman_sprite_anim_falling      ; original address L0000548c
L0000548c   dc.b $0d,$01,$01

batman_sprite_anim_fall_landing ; original address L0000548f
L0000548f   dc.b $11,$ff,$02


                    ; -------------------- set player state falling ---------------------
                    ; Set player state to falling (between plaforms, from ladder/stairs)
                    ;
                    ; Runs when Dropping from one platform to another (Fire + Down)
                    ; Also Runs When walking off the end of a Platform.
                    ; IN:-
                    ;   - D0.w = L000067c2 - batman_x_offset
                    ;   - D1.w = L000067c4 - batman_y_offset
                    ;
                    ; Code Checked 3/1/2025
                    ;
set_player_state_falling    ; original address L00005492
L00005492               movem.w batman_xy_offset,d0-d1                  ;L000069f2,d0-d1
L00005498               clr.l   batman_swing_speed                      ;L0000633c
L0000549c               move.w  batman_y_offset,target_window_y_offset  ;L000069f6
L000054a2               lea.l   batman_sprite_anim_falling(pc),a0       ;L0000548c(pc),a0
L000054a6               bsr.w   set_batman_sprites                      ;L00005470
L000054aa               move.l  #player_state_falling,gl_jsr_address    ;#$00054ba,L00003c7c
L000054b0               move.w  #$ffff,L00006342
L000054b6               clr.w   batman_fall_distance                    ;L00006340





                    ; ------------------- player state falling --------------------
                    ; The player state execuuted when the player is falling,
                    ; either between platforms or from ladders/stairs.
                    ;
                    ; IN:- 
                    ;   d0.w - batman_x_offset
                    ;   d1.w - batman_y_offset
                    ;
                    ; Code Checked 3/1/2025
                    ;
player_state_falling    ; original address L000054ba
L000054ba               movem.w batman_swing_fall_speed,d4-d5           ; L0000633c,d4-d5
L000054c0               move.w  d4,L00006356
L000054c4               beq.b   L00005504

L000054c6               sub.w   #$0010,d1
L000054ca               subq.w  #$04,d0
L000054cc               add.w   d4,d0
L000054ce               bsr.w   get_map_tile_at_display_offset_d0_d1    ; L000055e0
                    ; d2 = tile id
                    ; a0.l = tilemap ptr
                    ; d3.w = index into tile map
L000054d2               movem.w batman_xy_offset,d0-d1                  ; L000069f2,d0-d1
L000054d8               moveq   #$01,d7
                        ; check block of 4 tiles
                        ; if wall tile then jmp 5500
L000054da               cmp.b   #$03,d2
L000054de               bcs.b   L00005500

L000054e0               move.b  $01(a0,d3.w),d2
L000054e4               cmp.b   #$03,d2
L000054e8               bcs.b   L00005500

L000054ea               add.w   MAPGR_BASE,d3                           ;$00008002,d3
L000054f0               move.b  $00(a0,d3.w),d2
L000054f4               dbf.w   d7,L000054da
                        ; end of wall tile loop test

                        ; do fall/swing x-axis
L000054f8               add.w   d0,d4
L000054fa               move.w  d4,batman_x_offset                      ;L000069f2
L000054fe               bra.b   L00005504
                        ;----------------

L00005500               clr.w   batman_swing_speed                      ;L0000633c

                        ; fall y-axis
L00005504               cmp.w   #$0010,d5
L00005508               bpl.b   L0000550c
L0000550a               addq.w  #$01,d5
L0000550c               move.w  d5,batman_fall_speed                    ;L0000633e

L00005510               asr.w   #$02,d5
L00005512               add.w   d5,d1
L00005514               move.w  d1,batman_y_offset                      ;L000069f4
L00005518               btst.l  #$000f,d1
L0000551c               beq.b   L00005520
L0000551e               rts                         ; exit early

;line 6069 - code1.s
L00005520               bsr.w   get_map_tile_at_display_offset_d0_d1    ;L000055e0
L00005524               cmp.b   #$03,d2
L00005528               bcc.b   L00005536 

                        ; is wall tile?
L0000552a               subq.w  #$07,batman_y_offset                    ;L000069f4
L0000552e               movem.w batman_xy_offset,d0-d1                  ;L000069f2,d0-d1
L00005534               bra     player_state_falling                    ;L000054ba
                    ; ---------------------------

                        ; ** different to code1.s **
L00005536               sub.b   #$50,d2
L0000553a               bne.b   L00005542
L0000553c               move.w  #$0070,batman_fall_distance             ;L00006340
L00005542               cmp.b   #$11,d2
;line 6082 - code1.s
                    ; L00005546 - self modified 'nop' or 'or.b d0,d0'
                    ; when 'nop' ccr is not altered for tile test above. (falling off platform)
                    ; when 'or.b d0,d0' ccr depends on value of d0. (input fire-down)
                    ; THIS IS USED TO PREVENT COLLISION OCCURING WITH
                    ; THE PLATFORM YOU ARE DROPPING THROUGH
L00005546               nop

                    ; manage fall through platform 
                    ; (restores platform collision when fallen far enough)
L00005548               move.w  sr,d6
L0000554a               add.w   batman_fall_distance,d5                 ;L00006340,d5
L0000554e               move.w  d5,batman_fall_distance                 ;L00006340
L00005552               cmp.w   #$0008,d5
L00005556               bcs.b   L0000555e
                        ; restore platform collision
L00005558               move.w  #$4e71,L00005546
L0000555e               move.w  d6,sr                   ; *** REQUIRES SUPERVISOR MODE ***

                    ; ccr either tile compare, or value of d0.
L00005560               bcc.b   L0000551e                                   ; rts exit

                    ; landing on platform/floor
L00005562               move.w  #$0028,target_window_y_offset               ;L000069f6
L00005568               lea.l   batman_sprite_anim_fall_landing,a0          ;L0000548f,a0
L0000556c               bsr.w   set_batman_sprites                          ;L00005470

                        ; landing on platform (end falling)
L00005570               move.l  #player_state_fall_landing,gl_jsr_address   ;#$0000559a,L00003c7a
L00005578               clr.w   batman_fall_speed                           ;L0000633e
L0000557c               move.w  #$0001,L00006342
L00005582               move.w  #$0002,state_parameter                      ;L0000633a
L00005588               move.w  scroll_window_y_coord,d0                    ;L000069ee,d0
L0000558c               add.w   d1,d0
L0000558e               and.w   #$0007,d0
L00005592               sub.w   d0,d1
L00005594               move.w  d1,batman_y_offset                          ;L000069f4
L00005598               rts  



                    ; ------------------- player state falling --------------------
                    ; The state is set when batmman is landing on a platform after
                    ; falling from above.
                    ;
                    ; IN:- 
                    ;   d0.w - batman_x_offset
                    ;   d1.w - batman_y_offset
                    ;
                    ; Code Checked 3/1/2025
                    ;
player_state_fall_landing   ; original address L0000559a
L0000559a               subq.w  #$01,state_parameter                    ;L0000633a
L0000559e               bne.b   L00005598                               ; exit rts
                        ; test timer, lost life, no energy
L000055a0               tst.b   PANEL_STATUS_1                          ;$0007c874
L000055a6               bne.w   L00004dc0 
                        ; set state to normal joystick control
L000055aa               move.l  #player_move_commands,gl_jsr_address    ;#$00004c7c,L00003c7a
L000055b2               lea.l   batman_sprite_anim_standing,a0          ;L0000641b,a0
                        ; test fall distance
L000055b6               cmp.w   #$0050,batman_fall_distance             ;L00006340 
L000055bc               bmi.w   set_batman_sprites                      ;L00005470

                        ; fell too far...dead...
L000055c0               moveq   #$5a,d6
L000055c2               bsr.w   batman_lose_energy                      ;L00004d0a
L000055c6               move.b  #PANEL_ST2_VAL_LIFE_LOST,PANEL_STATUS_1 ;#$04,$0007c874                          ;PANEL_STATUS_1
L000055ce               btst.b  #PANEL_ST2_CHEAT_ACTIVE,PANEL_STATUS_2  ;#$0007,$0007c875                        ;PANEL_STATUS_2
L000055d6               bne.b   L000055de

L000055d8               jmp     PANEL_LOSE_LIFE                         ;$0007c862 
                    ; never return (use panel rts) 
L000055de               rts     


                    ;----------------------- get tile at display offset d0 & d1 --------------------
                    ; using window x,y co-rds and a given pixel offset into the display,
                    ; return the value for the background map tile at this position.
                    ; NB: the pixel offsets have a resolution of 2 pixels in this game.
                    ;
                    ; IN:-
                    ;   - D0.w = L000067c2 - x_offset
                    ;   - D1.w = L000067c4 - y_offset
                    ; OUT:
                    ;   - D2.b = Tile Value
                    ;
get_map_tile_at_display_offset_d0_d1    ; original address L000055e0
L000055e0               movem.w scroll_window_xy_coord,d2-d3   ; L000069ec,d2-d3
L000055e6               add.w   d0,d2
L000055e8               add.w   d1,d3
L000055ea               lsr.w   #$03,d2
L000055ec               lsr.w   #$03,d3
L000055ee               mulu.w  MAPGR_BASE,d3           ;$00008002,d3            ; MAPGR_BASE
L000055f4               add.w   d2,d3
L000055f6               lea.l   MAPGR_DATA_ADDRESS,a0   ;$0000807c,a0        ; MAPGR_DATA_ADDRESS
L000055fc               clr.w   d2
L000055fe               move.b  $00(a0,d3.w),d2
L00005602               rts  

; Line 6196 - Code5.s
                    ;------------------------------------------------------------------------------------------
                    ; -- Draw Batman and Rope
                    ;------------------------------------------------------------------------------------------
                    ; This routine draws the Batman Player and the Rope Swing
                    ;
draw_batman_and_rope    ; original address L00005604
L00005604               move.w  grappling_hook_height,d2    ;L00006360,d2
L00005608               beq.w   draw_batman_sprite          ;L000056e6
L0000560c               movem.w batman_xy_offset,d0-d1      ;L000069f2,d0-d1
L00005612               sub.w   #$000c,d1
L00005616               addq.w  #$03,d0
L00005618               move.w  batman_sprite1_id,d2        ;L00006336,d2
L0000561c               bpl.b   L00005620
L0000561e               subq.w  #$07,d0
L00005620               add.w   d1,d1
L00005622               move.w  d1,d7
L00005624               mulu.w  #DISPLAY_BYTEWIDTH,d1       ;#$002a,d1
L00005628               ror.w   #$03,d0
L0000562a               move.w  d0,d2
L0000562c               and.w   #$0fff,d2
L00005630               add.w   d2,d2
L00005632               add.w   d2,d1
L00005634               ext.l   d1
L00005636               add.l   playfield_buffer_2,d1       ;L000036ea,d1

L0000563a               movem.w L00006362,d2-d3     ; hook details (hook point?)
L00005640               add.w   d2,d2
L00005642               add.w   d3,d3
L00005644               beq.w   draw_batman_sprite          ;L000056e6
                        ; draw bat rope (line draw)
L00005648               and.w   #$e000,d0
L0000564c               moveq   #$05,d4
L0000564e               or.w    d0,d4
L00005650               btst.l  #$000f,d2
L00005654               beq.b   L0000565c
L00005656               neg.w   d2
L00005658               bset.l  #$0003,d4
L0000565c               add.w   d2,d2
L0000565e               move.w  d2,d5
L00005660               sub.w   d3,d5
L00005662               bpl.b   L00005668
L00005664               bset.l  #$0006,d4
L00005668               move.w  d5,d6
L0000566a               sub.w   d3,d6
L0000566c               sub.w   d3,d7
L0000566e               subq.w  #$03,d7
L00005670               bpl.b   L00005674 
L00005672               add.w   d7,d3
L00005674               asl.w   #$06,d3
L00005676               addq.w  #$02,d3
L00005678               or.w    #$0bca,d0
L0000567c               swap.w  d0
L0000567e               move.w  d4,d0

L00005680               lea.l   $00dff000,a5
                        ; blit wait
L00005686               btst.b  #$0006,$00dff002
L0000568e               bne.b   L00005686
                        ; set blitter for line draw
L00005690               move.w  d2,$0062(a5)
L00005694               move.w  d6,$0064(a5)
L00005698               move.w  #$002a,$0066(a5)
L0000569e               move.w  #$002a,$0060(a5)
L000056a4               move.w  #$c000,$0074(a5)
L000056aa               move.l  #$ffffffff,$0044(a5)
L000056b2               move.w  #$eeee,d6
L000056b6               moveq   #$03,d7
                        ; per bitplane loop
                        ; blit wait
L000056b8               btst.b  #$0006,$00dff002
L000056c0               bne.b   L000056b8
                        ; draw rope (Line Draw)
L000056c2               move.w  d5,$0052(a5)
L000056c6               move.l  d0,$0040(a5)
L000056ca               move.l  d1,$0048(a5)
L000056ce               move.l  d1,$0054(a5)
L000056d2               move.w  d6,$0072(a5)
L000056d6               move.w  d3,$0058(a5)
L000056da               add.l   #DISPLAY_BUFFER_BYTES,d1    ;#$00001c8c,d1
L000056e0               not.w   d6
L000056e2               dbf.w   d7,L000056b8

                        ; draw first Batman Sprite
draw_batman_sprite      ;original address L000056e6
L000056e6               movem.w batman_xy_offset,d0-d1  ; L000069f2,d0-d1
L000056ec               move.w  batman_sprite1_id,d2    ;L00006336,d2
L000056f0               clr.w   d4
L000056f2               move.b  d2,d4
L000056f4               beq.w   L00005732               ; exit rts
L000056f8               move.w  d1,d3
L000056fa               lea.l   display_object_coords,a0        ;L000060c4,a0
L000056fe               add.w   d4,d4
L00005700               add.w   d3,d3
L00005702               sub.b   -2(a0,d4.w),d3
L00005706               asr.w   #$01,d3
L00005708               move.w  d3,batman_y_bottom      ;L00006338
L0000570c               bsr.b   draw_sprite             ;L00005734
                        ; draw 2nd sprite
L0000570e               movem.w batman_xy_offset,d0-d1  ;L000069f2,d0-d1
L00005714               move.w  batman_sprite2_id,d2    ;L00006334,d2
L00005718               move.b  d2,d2
L0000571a               beq.w   L00005732               ; exit rts
L0000571e               bsr.b   draw_sprite             ;L00005734
                        ; draw 3rd sprite
L00005720               movem.w batman_xy_offset,d0-d1  ;L000069f2,d0-d1
L00005726               move.w  batman_sprite3_id,d2    ;L00006332,d2
L0000572a               move.b  d2,d2
L0000572c               beq.w   L00005732               ; exit rts
L00005730               bsr.b   draw_sprite             ;L00005734
L00005732               rts  




                    ;------------------------------------------------------------------------
                    ; -- Draw Sprite
                    ;------------------------------------------------------------------------
                    ; This routine blits a sprite to the destination using a cookie cut blit.
                    ; There's a lot of faf around clipping sprites and working out shift, mask
                    ; and blit sizes for clipping around the screen edges.
                    ; This might be fine for a general sprite blit routine.
                    ; Could have avoided a lot of the faf by giving sprites a max size and
                    ; adding a bit of buffer around the screen edge -- maybe???
                    ;
                    ; Sprite X & Y is held in a byte value and multipled by 2 to give actual screen position.
                    ;           Sprites have a position resolution of 2 pixels.
                    ;
                    ;   sprite_array_ptr ($62FE) holds a sprite draw structure
                    ;       Byte 0 - Y Offset (2 pixel resolution)
                    ;       Byte 1 - X Offset (2 pixel resolution)
                    ;       Byte 2 - Sprite Width in Words
                    ;       Byte 3 - Sprite Height in Lines
                    ;       Long 4-7 - Sprite Data Memory Pointer (Mask, bpl0, bpl1, bpl2, bpl3)
                    ;
                    ; in:
                    ;   d0.w - Sprite X Position 
                    ;   d1.w - Sprite Y Position
                    ;   d2.w - Sprite id (1 based array index) - index into table $63fe (8 byte structure)
                    ;
draw_sprite         ; original address L00005734
L00005734               movea.l sprite_array_ptr,a1         ;L00006346,a1
L00005738               add.w   d1,d1
L0000573a               asl.w   #$03,d2
L0000573c               lea.l   -8(a1,d2.w),a1
L00005740               bcc.b   L00005764
                    ; left facing sprite
                    ; update x,y with sprite offset
L00005742               move.b  (a1)+,d4
L00005744               ext.w   d4
L00005746               sub.w   d4,d1
L00005748               move.b  (a1)+,d4
L0000574a               ext.w   d4
L0000574c               add.w   d4,d0
L0000574e               clr.w   d2

                    ; get sprite width,height,gfx ptr
L00005750               move.b  (a1)+,d2
L00005752               move.w  d2,d4
L00005754               lsl.w   #$03,d4
L00005756               sub.w   d4,d0
L00005758               clr.w   d3
L0000575a               move.b  (a1)+,d3
L0000575c               movea.l (a1)+,a0
L0000575e               adda.l  sprite_gfx_left_offset,a0   ;L0000634a,a0
L00005762               bra.b   L0000577a

                    ; Right Facing Sprite
L00005764               move.b  (a1)+,d4
L00005766               ext.w   d4
L00005768               sub.w   d4,d1
L0000576a               move.b  (a1)+,d4
L0000576c               ext.w   d4
L0000576e               sub.w   d4,d0
L00005770               clr.w   d2
L00005772               move.b  (a1)+,d2
L00005774               clr.w   d3
L00005776               move.b  (a1)+,d3
L00005778               movea.l (a1)+,a0

                    ; left/right facing common processing
L0000577a               move.w  d3,d4
L0000577c               mulu.w  d2,d4
L0000577e               add.l   d4,d4
L00005780               movea.l d4,a1

                    ; sprite Y display clipping
L00005782               move.w  d1,d1
L00005784               bpl.b   L00005798
L00005786               neg.w   d1
L00005788               sub.w   d1,d3
L0000578a               bls.w   L00005892
L0000578e               mulu.w  d2,d1
L00005790               adda.l  d1,a0
L00005792               adda.l  d1,a0
L00005794               moveq   #$00,d1
L00005796               bra.b   L000057a8

                    ; check sprite top co-ord is off bottom of screen
L00005798               move.w  #$00ad,d6
L0000579c               sub.w   d1,d6
L0000579e               bls.w   L00005892
L000057a2               cmp.w   d3,d6
L000057a4               bpl.b   L000057a8
L000057a6               move.w  d6,d3

                    ; Clip Sprite X Axis to the Display Size
                    ; d0 = X Position
                    ; d2 = width of sprite (words)
                    ; d1 = start raster of sprite display - Y co-ord
                    ; d3 = last raster of sprite display  - Y + height
                    ; a0 = start address offset of gfx mask data
L000057a8               move.l  #$ffffffff,d7
L000057aa               move.w  d2,d5
L000057ac               moveq   #$07,d6
L000057ae               and.w   d0,d6
L000057b0               bne.b   L000057d4
L000057b2               asr.w   #$03,d0
L000057b4               bpl.b   L000057c4
                    ; Clip left display
L000057b6               neg.w   d0
L000057b8               sub.w   d0,d5
L000057ba               bls.w   L00005892
L000057be               adda.w  d0,a0
L000057c0               adda.w  d0,a0
L000057c2               moveq   #$00,d0
                    ; Clip right display
L000057c4               moveq   #$14,d4
L000057c6               sub.w   d0,d4
L000057c8               ble.w   L00005892
L000057cc               cmp.w   d4,d5
L000057ce               bls.b   L0000580e
L000057d0               move.w  d4,d5
L000057d2               bra.b   L0000580e

                    ; calc shifts and masks
                    ; shift value is > 0
                    ; d0 = X Position
                    ; d2 = width of sprite (words)
                    ; d1 = start raster of sprite display - Y co-ord
                    ; d3 = last raster of sprite display  - Y + height
                    ; d5 = copy of sprite width (words)
                    ; a0 = start address offset of gfx mask data
L000057d4               clr.w   d7
L000057d6               addq.w  #$01,d5
L000057d8               asr.w   #$03,d0
L000057da               bpl.b   L000057f8
                        ; sprite is off left hand side (x-axis)
L000057dc               neg.w   d0
L000057de               subq.w  #$01,d0
L000057e0               sub.w   d0,d5
L000057e2               bls.w   L00005892
                        ; sprite is on screen
L000057e6               adda.w  d0,a0
L000057e8               adda.w  d0,a0
L000057ea               move.l  #$ffffffff,d0
L000057ec               moveq   #$08,d4
L000057ee               sub.w   d6,d4
L000057f0               add.w   d4,d4
L000057f2               lsr.w   d4,d0
L000057f4               swap.w  d0
L000057f6               and.l   d0,d7
                        ; left hand of sprite is on screen
L000057f8               moveq   #$14,d4
L000057fa               sub.w   d0,d4
L000057fc               ble.w   L00005892 
                        ; is sprite on screen (x-axis)
L00005800               cmp.w   d4,d5
L00005802               bls.b   L0000580e 
                        ; clip right hand side
L00005804               move.w  d4,d5
L00005806               move.l  #$ffffffff,d4
L00005808               lsl.w   d6,d4
L0000580a               lsl.w   d6,d4
L0000580c               move.w  d4,d7

                    ; plot sprite positions
                    ; d0 = X Position
                    ; d2 = width of sprite (bytes)
                    ; d1 = start raster of sprite display - Y co-ord
                    ; d3 = last raster of sprite display  - Y + height
                    ; a0 = start address offset of gfx mask data
                    ; d6 = shift value / 2
                    ; d5 = sprite width (clipped)
                    ; d7 = Firstword & Lastword mask
L0000580e               asl.w   #$06,d3
L00005810               add.w   d5,d3
L00005812               sub.w   d5,d2
L00005814               add.w   d2,d2
L00005816               moveq   #$15,d4
L00005818               sub.w   d5,d4
L0000581a               add.w   d4,d4

                    ; d3 = blit size
                    ; d2 = source modulo
                    ; d4 = destination modulo
                    ; d0 = x word offset
                    ; d1 = y line offset
                    ; Calc destination Ptr
L0000581c               movea.l playfield_buffer_2,a2       ;L000036ea,a2
L00005822               add.w   d0,d0
L00005824               adda.w  d0,a2
L00005826               mulu.w  #$002a,d1
L0000582a               adda.l  d1,a2
L0000582c               ext.l   d6
L0000582e               ror.l   #$03,d6
L00005830               move.l  d6,d0
L00005832               swap.w  d0
L00005834               or.l    d0,d6

                    ; blit sprite
                    ; d2 = source data modulo
                    ; d4 = dest data modulo
                    ; d6 = bltcon0 & bltcon1 (shift A & B) (top 3 bits of high word and low word)
                    ; d7 = first word mask & last word mask
                    ; a0 = gfx data ptr (starts with mask data)
                    ; a1 = offset to gfx data (size of mask data)
L00005836               movea.l #$00dff000,a5
L0000583c               or.l    #$0fca0000,d6

L00005842               btst.b  #$0006,$00dff002
L0000584a               bne.b   L00005842

L0000584c               move.w d2,$0064(a5)
L00005850               move.w d2,$0062(a5)
L00005854               move.l d7,$0044(a5)
L00005858               move.w d4,$0060(a5)
L0000585c               move.w d4,$0066(a5)
L00005860               move.l d6,$0040(a5)
L00005864               lea.l (a0),a3
L00005866               moveq #$03,d7
                        ; bitplane blit loop
L00005868               btst.b  #$0006,$00dff002
L00005870               bne.b   L00005868 (T)

L00005872               lea.l   $00(a0,a1.l),a0
L00005876               move.l  a3,$0050(a5)
L0000587a               move.l  a0,$004c(a5)
L0000587e               move.l  a2,$0048(a5)
L00005882               move.l  a2,$0054(a5)
L00005886               move.w  d3,$0058(a5)
L0000588a               lea.l   $1c8c(a2),a2
L0000588e               dbf.w   d7,L00005868 
L00005892               rts







                    ; ----------------- read player input -----------------
                    ; called from game loop, part of player state update?
                    ; IN:-
                    ;   d0.l = #$00000000
                    ;   d1.l = #$00000000  
                    ;
                    ; OUT:-
                    ;   d0.b = #$00 - not pressed, #$ff - button pressed
                    ;   d2.b = joystick direction bits
                    ;               bit 0 = left
                    ;               bit 1 = right
                    ;               bit 2 = down
                    ;               bit 3 = up
                    ;               bit 4 = pulse when button pressed
                    ;
read_player_input   ; original address L00005894
                        ;jsr _DEBUG_COLOUR_RED

L00005894               move.w  $00dff00c,d0
L0000589a               clr.b   d2
                        ; detect left/right
L0000589c               btst.l  #$0001,d0
L000058a0               beq.b   L000058a6
L000058a2               bset.l  #PLAYER_INPUT_RIGHT,d2      ;#$0000,d2
L000058a6               btst.l  #$0009,d0
L000058aa               beq.b   L000058b0
L000058ac               bset.l  #PLAYER_INPUT_LEFT,d2       ;#$0001,d2
                        ; detect up/down
L000058b0               move.w  d0,d1
L000058b2               lsr.w   #$01,d1
L000058b4               eor.w   d0,d1
L000058b6               btst.l  #$0000,d1
L000058ba               beq.b   L000058c0
L000058bc               bset.l  #PLAYER_INPUT_DOWN,d2       ;#$0002,d2
L000058c0               btst.l  #$0008,d1
L000058c4               beq.b   L000058ca
L000058c6               bset.l  #PLAYER_INPUT_UP,d2         ;#$0003,d2
                        ; detect fire button
L000058ca               btst.b  #$0007,$00bfe001
L000058d2               seq.b   d0 
L000058d4               move.b  player_button_pressed,d1    ;L00006351,d1
L000058d8               bne.b   L000058e0
L000058da               and.w   #$0010,d0
L000058de               or.w    d0,d2
L000058e0               move.b  d0,player_button_pressed    ;L00006351
L000058e4               move.b  d2,player_input_command     ;L00006350
L000058e8               rts  



                    ; -------------------- inititialise offscreen buffer --------------------
                    ; Draw the initial level background into the offscreen back buffer
                    ; This is the initial background starting point for batman.
                    ;
initialise_offscreen_buffer  ; original address L000058ea
L000058ea               clr.l   d0
L000058ec               move.w  scroll_window_x_coord,d0            ;L000069ec,d0
L000058f0               lsr.w   #$03,d0
L000058f2               add.w   d0,d0
L000058f4               movea.l #CODE1_CHIPMEM_BUFFER,a4            ;#$0005a36c,a4
L000058fa               adda.l  d0,a4
L000058fc               move.l  a4,offscreen_display_buffer_ptr     ;L00006366

                        ; init draw loop
L00005900               clr.w   offscreen_y_coord                   ;L0000635a
L00005904               clr.l   d1
L00005906               move.w  scroll_window_x_coord,d1            ;L000069ec,d1
L0000590a               moveq   #$14,d7
                        ; draw gfx column
L0000590c               movem.l d1/d7/a4,-(a7)
L00005910               bsr.w   draw_background_horizontal_scroll   ;L00004b14
L00005914               movem.l (a7)+,d1/d7/a4
L00005918               addq.w  #$08,d1
L0000591a               addq.l  #$02,a4
L0000591c               dbf.w   d7,L0000590c
L00005920               rts  


                    ; ----------------------- preprocess data ------------------------
                    ; Preprocess data ready to start the level.
                    ; 1) preprocess large font for display.
                    ; 2) preprocess map data (swap/invert level data blocks)
                    ; 3) preprocess sprites (set up display object lists, format gfx data, create mirrored sprite sheet)
                    ;
preprocess_data     ; original address L000058e2
                    
                    ; --------------- preprocess font gfx ---------------
                    ; when this routine is skipped it doesn't make any
                    ; difference to the display of the 'AXIS CHEMICAL FACTORY'
                    ; display which this font is used to display.
preproc_font        ; original address L00005922
L00005922               move.w  #$013f,d7
L00005926               lea.l   large_character_gfx,a0          ;$6ad0,a0
L0000592a               move.b  $0004(a0),d0
L0000592e               and.b   $0001(a0),d0
L00005932               not.b   d0
L00005934               and.b   $0002(a0),d0
L00005938               and.b   $0003(a0),d0
L0000593c               eor.b   d0,$0001(a0)
L00005940               addq.w  #$05,a0
L00005942               dbf.w d7,L0000592a


                    ; ------ init map data ------
                    ; swaps 20 blocks of level data (192 bytes)
                    ; outermost to inner most blocks are swapped (41 blocks in total)
                    ; effewctively the blocks are reversed in order in memory.
                    ; e.g.
                    ;       A  -----> E
                    ;       B  -----> D
                    ;       C  -----> C (middle block not swapped)
                    ;       D  -----> B
                    ;       E  -----> A
                    ;
                    ; if there is an odd number of blocks (which there are here)
                    ; then the last block is not swapped (its the middle block)
                    ;
                    ; Block No  | Block A       | Block B
                    ;   1       | 807c - 813c   | 9e7c - 9f3c
                    ;   2       | 813c - 81fc   | 9dbc - 9e7c
                    ;   3       | 81fc - 82bc   | 9cfc - 9dbc
                    ;   4       | 82bc - 837c   | 9c3c - 9cfc
                    ;   5       | 837c - 843c   | 9b7c - 9c3c
                    ;   6       | 843c - 84fc   | 9abc - 9b7c
                    ;   7       | 84fc - 85bc   | 99fc - 9abc
                    ;   8       | 85bc - 867c   | 993c - 99fc
                    ;   9       | 867c - 873c   | 987c - 993c
                    ;   10      | 873c - 87fc   | 97bc - 987c
                    ;   11      | 87fc - 88bc   | 96fc - 97bc
                    ;   12      | 88bc - 897c   | 963c - 96fc
                    ;   13      | 897c - 8a3c   | 957c - 963c
                    ;   14      | 8a3c - 8afc   | 94bc - 957c
                    ;   15      | 8afc - 8bbc   | 93fc - 94bc
                    ;   16      | 8bbc - 8c7c   | 933c - 9efc
                    ;   17      | 8c7c - 8d3c   | 927c - 933c
                    ;   18      | 8d3c - 8dfc   | 91bc - 927c
                    ;   19      | 8dfc - 8ebc   | 90fc - 91bc
                    ;   20      | 8ebc - 8f7c   | 903c - 90fc
                    ;
                    ;middle data block
                    ;   21      | 8f7c - 903d - NOT SWAPPED (Middle Data Block)
                    ;
                    ; These blocks of data are level map blocks,
                    ; If this code does not run then the level map data is
                    ; foobar. Maybe the data is in a format suitable
                    ; for a different platform (atari st maybe?)
                    ;
preproc_mapdata     ; original address L00005946   
L00005946               lea.l   MAPGR_BLOCK_PARAMS,a0               ;$00008002,a0            ; MAPGR_BLOCK_PARAMS
L0000594c               move.w  (a0)+,d5
L0000594e               move.w  (a0)+,d6
L00005950               lea.l   MAPGR_PREPROC_BLOCK_OFFSET(a0),a0   ;$0076(a0),a0
L00005954               move.b  $0028(a0),d0        ; $a4(a0)
L00005958               cmp.b   #$03,d0
L0000595c               bcc.b   preproc_display_object_data         ;L00005982

L0000595e               move.w  d6,d0
L00005960               subq.w  #$01,d0
L00005962               mulu.w  d5,d0
L00005964               lea.l   $00(a0,d0.l),a1
L00005968               lsr.w   #$01,d6
L0000596a               subq.w  #$01,d6
                        ; swap data block
L0000596c               move.w  d5,d4
L0000596e               subq.w  #$01,d4
                        ; swap data loop
L00005970               move.b  (a0),d0
L00005972               move.b  (a1),(a0)+
L00005974               move.b  d0,(a1)+ 
L00005976               dbf.w   d4,L00005970
L0000597a               suba.w  d5,a1
L0000597c               suba.w  d5,a1
L0000597e               dbf.w   d6,L0000596c



                    ; Initialise list of 305 display objects
                    ; Create list at $10000 in physical memory
preproc_display_object_data ; original address L00005982
L00005982               movea.l sprite_array_ptr,a1         ;L00006346,a1
L00005986               movea.l #BATSPR1_BASE,a0            ;#$00011002,a0
L0000598c               lea.l   display_object_coords,a2    ;L000060c4,a2

L00005992               move.w  (a0)+,d7
L00005994               clr.l   d0
L00005996               move.w  d7,d0
L00005998               subq.w  #$01,d7
L0000599a               move.w  d7,d6
                    ; calc start of sprite gfx
L0000599c               asl.w   #$03,d0
L0000599e               add.l   a0,d0
L000059a0               movea.l d0,a5

                    ; loop through 10 byte struct
                    ; first 2 bytes ignored ($800f)
                    ; next 2 bytes X & Y co-ords
                    ; next 2 bytes width (words) & height (lines)
                    ; next 4 bytes gfx start offset from $1198c ($98c in file)
                    ;
sprite_list_loop    ; original address L000059a2
L000059a2               lea.l   $0002(a0),a0
L000059a6               move.w  (a2)+,(a1)+
L000059a8               move.b  (a0)+,d0
L000059aa               lsr.b   #$04,d0
L000059ac               addq.w  #$01,d0
L000059ae               move.b  d0,(a1)+
L000059b0               move.b  (a0)+,d0
L000059b2               addq.w  #$01,d0
L000059b4               move.b  d0,(a1)+
L000059b6               move.l  (a0)+,d0
L000059b8               add.l   a5,d0
L000059ba               move.l  d0,(a1)+
L000059bc               dbf.w   d7,sprite_list_loop         ;L000059a2


                    ; ------- mirror sprites (left facing) --------
                    ; 1) calculate the size of the sprite gfx data.
                    ; 2) calculate the offset to sprite sheet for left facing sprites (mirror image)
                    ; 3) make the mirror image sprite sheet?
                    ;
preproc_display_object_data_2   ; original address L000059c0            
L000059c0               move.w  d6,d7
L000059c2               movea.l sprite_array_ptr,a2         ;L00006346,a2
L000059c6               clr.l   d2
L000059c8               addq.w  #$02,a2
L000059ca               clr.w   d0
L000059cc               move.b  (a2)+,d0
L000059ce               clr.w   d1
L000059d0               move.b  (a2)+,d1
L000059d2               mulu.w  d1,d0
L000059d4               add.w   d0,d2
L000059d6               addq.w  #$06,a2
L000059d8               dbf.w   d7,L000059ca
L000059dc               mulu.w  #$000a,d2
L000059e0               move.l  d2,sprite_gfx_left_offset   ;L0000634a
L000059e4               movea.l sprite_array_ptr,a1         ;L00006346,a1
L000059e8               movea.l $0004(a1),a1
L000059ec               addq.w  #$01,a1
L000059ee               btst.b  #$0000,(a1)
L000059f2               bne.w   preprocess_sprite_gfx       ;L000059f8
L000059f6               rts  



                    ; ----------------invert & mirror sprite gfx ----------------
                    ; IN:-
                    ;   d6.w = number of display objects (305)
                    ;   a0.l = start of sprite gfx
                    ;
                    ; 1) inverts the sprites (upside down?)
                    ; 2) create mirror image of sprites
                    ;
preprocess_sprite_gfx   ; original address L000059f8
invert_sprites          ; original address L000059f8 
L000059f8               move.w  d6,d7
L000059fa               movea.l sprite_array_ptr,a1                     ;L00006346,a1
L000059fe               addq.w  #$02,a1
L00005a00               movea.l a0,a5
L00005a02               movea.l a0,a3
                        ; invert next sprite
L00005a04               clr.l   d5
L00005a06               clr.l   d0
L00005a08               move.b  (a1)+,d0
L00005a0a               move.b  (a1),d5
L00005a0c               mulu.w  d0,d5
L00005a0e               move.l  d5,d4
L00005a10               add.w   d4,d4
L00005a12               move.l  d4,d3
L00005a14               add.w   d4,d3
L00005a16               move.l  d3,d2
L00005a18               add.w   d4,d2
L00005a1a               move.l  d2,d1
L00005a1c               add.w   d4,d1
L00005a1e               subq.w  #$01,d5
L00005a20               movea.l #CODE1_DOUBLE_BUFFER_ADDRESS,a2         ;#$00061b9c,a2
                        ; copy sprite loop
L00005a26               move.w  (a0)+,(a2)
L00005a28               not.w   (a2)
L00005a2a               move.w  (a0)+,$00(a2,d4.w)
L00005a2e               move.w  (a0)+,$00(a2,d3.w)
L00005a32               move.w  (a0)+,$00(a2,d2.w)
L00005a36               move.w  (a0)+,$00(a2,d1.w)
L00005a3a               addq.w  #$02,a2
L00005a3c               dbf.w   d5,L00005a26
L00005a40               move.w  #$0004,d4
                        ; invert sprite bitplane
L00005a44               clr.w   d5
L00005a46               move.b  (a1),d5
L00005a48               subq.w  #$01,d5
                        ; invert sprite - outer loop
L00005a4a               move.w  d0,d2
L00005a4c               subq.w  #$01,d2
L00005a4e               suba.l  d0,a2
L00005a50               suba.l  d0,a2
                        ; invert sprite - inner loop
L00005a52               move.w  (a2)+,(a3)+
L00005a54               dbf.w   d2,L00005a52
                        ; do for sprite height
L00005a58               suba.l  d0,a2
L00005a5a               suba.l  d0,a2
L00005a5c               dbf.w   d5,L00005a4a
                        ; do next bitplane
L00005a60               adda.l  d3,a2
L00005a62               dbf.w   d4,L00005a44 
                        ; do next sprite
L00005a66               lea.l   $0007(a1),a1
L00005a6a               dbf.w   d7,L00005a04


mirror_sprites          ; original address L00005a6e
L00005a6e               movea.l a3,a4
L00005a70               movea.l sprite_array_ptr,a1         ;L00006346,a1
L00005a74               move.w  d6,d7
                        ; mirror next sprite
L00005a76               moveq   #$04,d6
L00005a78               movea.l $0004(a1),a0
                        ; mirror sprite
L00005a7c               clr.l   d5
L00005a7e               clr.l   d4
L00005a80               move.b  $0002(a1),d4
L00005a84               move.b  $0003(a1),d5
L00005a88               subq.w  #$01,d5
                        ; mirror bitplane
L00005a8a               move.w  d4,d3
L00005a8c               add.w   d3,d3
L00005a8e               subq.w  #$01,d3
                        ; mirror raster line
L00005a90               move.b  $00(a0,d3.w),d0
L00005a94               moveq   #$07,d2
                        ; mirror byte
L00005a96               roxr.b  #$01,d0
L00005a98               roxl.b  #$01,d1
L00005a9a               dbf.w   d2,L00005a96
L00005a9e               move.b  d1,(a3)+
L00005aa0               dbf.w   d3,L00005a90
L00005aa4               adda.l  d4,a0
L00005aa6               adda.l  d4,a0
L00005aa8               dbf.w   d5,L00005a8a
L00005aac               dbf.w   d6,L00005a7c
L00005ab0               lea.l   $0008(a1),a1
L00005ab4               dbf.w   d7,L00005a76
L00005ab8               rts  





actor_init_data     ; original address L00005ABA
L00005ABA   dc.w    $0004,$00E8
            dc.w    $0012,$00C5
            dc.w    $0015,$0097
            dc.w    $0017,$0064 
L00005ACA   dc.w    $0018,$0085
            dc.w    $001B,$00BC
            dc.w    $001F,$00C1
            dc.w    $0020,$0103 
L00005ADA   dc.w    $0021,$00FF
            dc.w    $00FF,$0000 





                    ; ------- jmp table -----
                    ; converted from word to long addresses
                    ; when called the routines have the following
                    ; IN:-
                    ;   a6 = actor struct
                    ;   d0,d1 = Actor X,Y
                    ;   d2,d3 = Window X,Y
                    ;
                    ; Code Checked 28/1/2025
                    ;
actor_handler_table ; original address L00005ae2 
L00005AE2   dc.l    actor_handler_cmd_nop           ; L000052B6                   ;  $52B6
            dc.l    actor_cmd_falling               ; L0000460C                       ;  $460C
            dc.l    actor_cmd_green_walk_right      ; L000040F8                       ;  $40F8
            dc.l    actor_cmd_green_walk_left       ; L0000404C                       ;  $404C 
L00005AEA   dc.l    actor_cmd_grenade_right_01      ; L000040A6                       ;  $40A6
            dc.l    actor_cmd_grenade_left_01       ; L00003FFA                       ;  $3FFA
            dc.l    actor_cmd_grenade_right_02      ; L000040DE                       ;  $40DE
            dc.l    actor_cmd_grenade_left_02       ; L00004032                       ;  $4032 
            dc.l    actor_handler_cmd_nop           ; L000052B6                   ;  $52B6 
            dc.l    actor_handler_cmd_nop           ; L000052B6                   ;  $52B6 
            dc.l    actor_handler_cmd_nop           ; L000052B6                   ;  $52B6
            dc.l    actor_handler_cmd_nop           ; L000052B6                   ;  $52B6 
L00005AFA   dc.l    actor_cmd_climb_up_ladder       ; L000043E2                       ;  $43E2
            dc.l    actor_cmd_climb_down_ladder     ; L0000438C                       ;  $438C
            dc.l    actor_cmd_actor_brown_walk_right ; L000041AE                       ;  $41AE
            dc.l    actor_cmd_brown_walk_left_15_23  ; L00004278                       ;  $4278 
            dc.l    actor_cmd_shooting_diagonally_01 ; L0000446E                       ;  $446E
            dc.l    actor_cmd_shooting_diagonally_02 ; L00004482                       ;  $4482
            dc.l    actor_cmd_shooting_horizontal    ; L000044BC                       ;  $44BC
            dc.l    $00000000                       ;  $0000 
L00005B0A   dc.l    actor_cmd_20                    ; L00005CB6                       ;  $5CB6
            dc.l    actor_cmd_21                    ; L00005C32                   ;  $5C32
            dc.l    actor_cmd_22                    ; L00005C4A                   ;  $5C4A
            dc.l    actor_cmd_brown_walk_left_15_23 ; L00004278                       ;  $4278
            dc.l    actor_cmd_24                    ; L00005BA4                   ;  $5BA4
            dc.l    actor_cmd_joker_dead            ; L00005B4E                   ;  $5B4E
            dc.l    actor_cmd_26                    ; L00005F00                   ;  $5F00
            dc.l    actor_cmd_27                    ; L00005F14                   ;  $5F14 
L00005B1A   dc.l    actor_cmd_28                    ;  $5F8A
            dc.l    actor_cmd_29                    ; L00006014                   ;  $6014
            dc.l    actor_cmd_30                    ; L00006068                   ;  $6068
            dc.l    actor_cmd_31                    ; L00005D4C                   ;  $5D4C 
            dc.l    actor_cmd_32_jackfall           ; L00005D84                   ;  $5D84
            dc.l    actor_cmd_33_level_complete     ; L00005DF8                   ;  $5DF8
            dc.l    set_player_spawn_point_1        ; L00005B2C                   ;  $5B2C
            dc.l    set_player_spawn_point_2        ; L00005B36                   ;  $5B36 
L00005B2A   dc.l    set_player_spawn_point_3        ; L00005B40                   ;  $5B40 




                        ; ------------------- set player spawn points -------------------
                        ; a6 = actor struct
                        ; d0,d1 = actor x,y
                        ; d2,d3 = window x,y
                        ;
                        ; Code Checked 28/1/2025
                        ;
set_player_spawn_point_1    ; original address L00005b2c
L00005b2c               moveq   #$01,d0
L00005b2e               cmp.w   level_spawn_point_index,d0          ;L00006344,d0
L00005b32               bcs.b   L00005b4a
L00005b34               bra.b   L00005b46
set_player_spawn_point_2    ; original address L00005b36
L00005b36               moveq   #$02,d0
L00005b38               cmp.w   level_spawn_point_index,d0          ;L00006344,d0
L00005b3c               bcs.b   L00005b4a
L00005b3e               bra.b   L00005b46
set_player_spawn_point_3    ; original address L00005b40
L00005b40               moveq   #$03,d0
L00005b42               cmp.w   level_spawn_point_index,d0          ;L00006344,d0
L00005b46               move.w  d0,level_spawn_point_index          ; L00006344
L00005b4a               clr.w   (a6)
L00005b4c               rts  




                    ; ------------------- actor cmd load title screen ------------
                    ; Could execute to load title screen when the joker is killed
                    ; seems to draw a sprite, wait for 1 second and then
                    ; load the title screen.
                    ;
                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
                    ;
                    ; Code Checked 28/1/2025
                    ;
actor_cmd_25        ; original address L00005b4e
actor_cmd_joker_dead
L00005b4e               move.w  #$0590,d0                       ; d0 is unused
L00005b52               sub.w   scroll_window_x_coord,d0        ; d0 is unused
L00005b56               addq.l  #$02,$08(a6)                    ; address ptr by 2 (sprite addr?)
L00005b5a               movea.l $08(a6),a5
L00005b5e               move.w  (a5),d2                         ; get sprite id,
L00005b60               bpl.w   draw_next_sprite                ; add 6(a6) to d2 and draw sprite
L00005b64               bsr.w   double_buffer_playfield
L00005b68               moveq   #$32,d0
L00005b6a               bsr.w   wait_for_frame_count
L00005b6e               bra.w   Load_title_screen
                        ;******************************
                        ;       LOAD TITLE SCREEN
                        ;     NEVER RETURN FROM HERE
                        ;******************************


                    ; data is referened by routine below
L00005B72               dc.w    $0001,$0001
                        dc.w    $0001,$0001
                        dc.w    $0002,$0002
                        dc.w    $0002,$0002 
L00005B82               dc.w    $0003,$0003
                        dc.w    $0003,$0003
                        dc.w    $0004,$0004
                        dc.w    $0004,$0004 
L00005B92               dc.w    $0002,$0002
                        dc.w    $0002,$0002
                        dc.w    $0001,$0001
                        dc.w    $0001,$0001 
L00005BA2               dc.w    $FFFF





                    ;---------------------------- actor cmd 24 ------------------------------
                    ; Think this might have something to do with the Joker,
                    ; appears to search the actor list for an actor with a specific value.
                    ; updates screen y position to midpoint between the actor and batman.
                    ; could be jack climbing the rope ladder or something?
                    ; dont know at the moment.
                    ;
                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
                    ;
                    ; Code Checked 28/1/2025
                    ;
actor_cmd_24        ; original address L00005ba4
L00005ba4           move.w  #$0098,$0004(a6)
                ; find actor #$85
L00005baa           lea.l   actors_list,a5 
L00005bae           move.w  #$0085,d2                           ; search value = #$85
L00005bb2           moveq.l #$09,d7
L00005bb4           cmp.w   $0006(a5),d2                        ; search for actor = #$85
L00005bb8           beq.b   L00005bc4
L00005bba           lea.l   ACTORLIST_STRUCT_SIZE(a5),a5
L00005bbe           dbf.w   d7,L00005bb4
L00005bc2           bra.b   L00005bc8

                ; check actor active
L00005bc4           move.w  (a5),d2
L00005bc6           bne.b   L00005bd4 

                ; actor not found, or not active
L00005bc8           bclr.b  #$07,trigger_definitions_list       ; disable tiggers?
L00005bd0           clr.w   (a6)                                ; disable current actor
L00005bd2           rts  

                ; a5.l = actor struct
                ; d2.w = actor param/id? $00(a5)
                ; found active actor with value #$85
L00005bd4           subq.w  #$01,d2
L00005bd6           bne.b   L00005bd2                               ; exit until d2 == 0
                    ;-----------------
L00005bd8           jsr     AUDIO_PLAYER_INIT_SFX_1                 ; clear audio
L00005bde           bset.b  #PANEL_ST1_TIMER_EXPIRED,PANEL_STATUS_1 ; timer expired
L00005be6           move.l  #actor_handler_cmd_nop,gl_jsr_address   ; disable player input
L00005bec           clr.w   L00006342
L00005bf0           clr.w   grappling_hook_height
L00005bf4           move.w  $0004(a5),d0                            ; d0 = actor y value
L00005bf8           cmp.w   #$00d4,d0
L00005bfc           bcs.b   L00005c1a                               ; y < #$d4 then 5c1a
                    ;--------------------
L00005bfe           move.w  #$0081,$0006(a5)
L00005c04           move.l  #L00005B72-2,$08(a5)                    ;Actor Sprite Anim Address
L00005c0c           move.w  #$0019,(a5)                             ;Actor id/handler
L00005c10           clr.w   (a6)                                    ;Disable current actor
L00005c12           moveq   #SFX_SPLASH,d0                          ;#$0b,d0
L00005c14           jmp     AUDIO_PLAYER_INIT_SFX                   ;$00048014
                    ; uses rts in audio player


L00005c1a           subq.w  #$01,target_window_x_offset     ;L000069f8
L00005c1e           sub.w   #$0018,d0                       ; subtract actor Y value
L00005c22           sub.w   scroll_window_y_coord,d0        ; d0 = screen offset
L00005c26           neg.w   d0
L00005c28           add.w   batman_y_offset,d0              ; d0 = mid point between actor and batman
L00005c2c           move.w  d0,target_window_y_offset 
L00005c30           rts  




                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
                    ;
                    ; Code Checked 19/1/2025
                    ;
actor_cmd_21        ; original address L00005c32
L00005c32           bsr.b   L00005c68
L00005c34           cmp.w   #$0008,d2
L00005c38           bcc.b   L00005c30
L00005c3a           cmp.w   #$0004,d2
L00005c3e           bne.w   draw_next_sprite        ;L000045fa
L00005c42           bsr.b   L00005c96
L00005c44           moveq   #$04,d2
L00005c46           bra.w   draw_next_sprite        ;L000045fa 
                    ; uses rts in draw_next_sprite to return


                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
                    ;
                    ; Code Checked 29/1/2025
                    ;
actor_cmd_22        ; original address L00005c4a
L00005c4a           bsr.b   L00005c68
L00005c4c           or.w    #$e000,d2
L00005c50           cmp.w   #$e008,d2
L00005c54           bcc.b   L00005c30               ; exit rts
L00005c56           cmp.w   #$e004,d2
L00005c5a           bne.w   draw_next_sprite        ;L000045fa
L00005c5e           bsr.b   L00005c8a
L00005c60           move.w  #$e004,d2
L00005c64           bra.w   draw_next_sprite        ;L000045fa

L00005c68           clr.w   d2
L00005c6a           move.w  $0008(a6),d2
L00005c6e           addq.b  #$04,d2
L00005c70           bcc.b   L00005c7a
L00005c72           moveq   #SFX_GASLEAK,d3         ;#$06,d2
L00005c74           bsr.w   play_proximity_sfx      ;L000044f4
L00005c78           clr.w   d2
L00005c7a           move.w  d2,$0008(a6)
L00005c7e           cmp.w   #$0037,d2
L00005c82           bcc.b   L00005c88
L00005c84           lsr.w   #$03,d2
L00005c86           addq.w  #$01,d2
L00005c88           rts  


L00005c8a           movem.w batman_xy_offset,d3-d4
L00005c90           add.w   #$0010,d3
L00005c94           bra.b   L00005c9e
                    ; use 'rts' to return


L00005c96           movem.w batman_xy_offset,d3-d4
L00005c9c           addq.w  #$04,d3

L00005c9e           sub.w   d0,d3
L00005ca0           cmp.w   #$0016,d3
L00005ca4           bcc.b   L00005c88               ; exit rts 
L00005ca6           cmp.w   d1,d4
L00005ca8           bmi.b   L00005c88               ; exit rts
L00005caa           cmp.w   batman_y_bottom,d1
L00005cae           bmi.b   L00005c88               ; exit rts
L00005cb0           moveq   #$03,d6
L00005cb2           bra.w   batman_lose_energy
                    ; use 'rts' to exit



                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
                    ;
                    ; Code Checked 29/1/2025
                    ;
actor_cmd_20        ; original address L00005cb6
L00005cb6            move.w  $000c(a6),d3
L00005cba            addq.b  #$06,d3
L00005cbc            move.w  d3,$000c(a6)
L00005cc0            cmp.b   #$20,d3
L00005cc4            bcs.b   L00005c88                  ; exit rts
L00005cc6            moveq   #$01,d2
L00005cc8            cmp.b   #$40,d3
L00005ccc            bcs.w   draw_next_sprite     
L00005cd0            move.w  $000a(a6),d5
L00005cd4            cmp.w   #$0010,d5
L00005cd8            bcc.w   L00005cde 
L00005cdc            addq.w  #$01,d5
L00005cde            move.w  d5,$000a(a6)
L00005ce2            lsr.w   #$01,d5
L00005ce4            add.w   $0008(a6),d5
L00005ce8            move.w  d5,$0008(a6)
L00005cec            add.w   d5,d1
L00005cee            bsr.w   get_map_tile_at_display_offset_d0_d1  
L00005cf2            cmp.b   #$51,d2
L00005cf6            bcs.b   L00005d20
L00005cf8            move.w  scroll_window_y_coord,d3  
L00005cfc            add.w   d1,d3
L00005cfe            and.w   #$0007,d3
L00005d02            not.w   d3
L00005d04            add.w   d3,d1
L00005d06            moveq   #$04,d2
L00005d08            eor.w   d2,$0002(a6)
L00005d0c            clr.l   $0008(a6)
L00005d10            clr.w   $000c(a6)
L00005d14            moveq   #SFX_DRIP,d2
L00005d16            bsr.w   play_proximity_sfx
L00005d1a            moveq   #$02,d2
L00005d1c            bra.w   draw_next_sprite
L00005d20            moveq   #$01,d2
L00005d22            move.w  batman_x_offset,d3  
L00005d26            sub.w   d0,d3
L00005d28            addq.w  #$03,d3
L00005d2a            cmp.w   #$0007,d3
L00005d2e            bcc.w   draw_next_sprite   
L00005d32            cmp.w   batman_y_bottom,d1
L00005d36            bmi.w   draw_next_sprite    
L00005d3a            cmp.w   batman_y_offset,d1 
L00005d3e            bpl.w   draw_next_sprite    
L00005d42            moveq   #$02,d6
L00005d44            bsr.w   batman_lose_energy   
L00005d48            bra.b   L00005d06
L00005d4a            rts  



                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
                    ;
                    ; Code Checked 29/1/2025
                    ;
actor_cmd_31        ; original address L00005d4c
L00005d4c           move.w  $0004(a6),d2
L00005d50           not.w   d2
L00005d52           and.w   #$0007,d2
L00005d56           bclr.l  #$0002,d2
L00005d5a           bne.b   L00005d60
L00005d5c           add.w   #$e000,d2
L00005d60           move.w  d2,-(a7)
L00005d62           addq.w  #$02,d2
L00005d64           bsr.w   draw_next_sprite
L00005d68           move.w  (a7)+,d2
L00005d6a           and.w   #$e000,d2
L00005d6e           addq.w  #$01,d2
L00005d70           bsr.w   actor_collision_and_sprite1     ;L000045c8
L00005d74           btst.b  #$0000,playfield_swap_count+1   ;L00006375
L00005d7a           beq.b   L00005d4a                       ;exit rts
L00005d7c           subq.w  #$01,$0004(a6) 
L00005d80           bmi.b   L00005dca
L00005d82           rts 



                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
                    ;
                    ; Code Checked 29/1/2025
                    ;
                    ; jack falls hits the floor?
actor_cmd_32_jackfall   ; original address L00005d84
L00005d84           btst.b  #$0000,playfield_swap_count+1               ;L00006375
L00005d8a           beq.b   L00005d9c
L00005d8c           movem.l d0-d1/a6,-(a7)
L00005d90           moveq   #SFX_SPLASH,d0                              ;#$0b,d0
L00005d92           jsr     AUDIO_PLAYER_INIT_SFX                       ;$00048014
L00005d98           movem.l (a7)+,d0-d1/a6
L00005d9c           move.w  playfield_swap_count,d2                     ;L00006374,d2
L00005da0           lsr.w   #$02,d2
L00005da2           and.w   #$0003,d2
L00005da6           addq.w  #$01,d2
L00005da8           bsr.w   draw_next_sprite                            ;L000045fa
L00005dac           sub.w   #$0010,d1
L00005db0           bpl.b   L00005d9c
L00005db2           lea.l   actors_list,a5                              ;L000039bc,a5
L00005db6           move.w  #$0103,d2
L00005dba           moveq   #$09,d7
L00005dbc           cmp.w   $0006(a5),d2
L00005dc0           beq.b   L00005dd0 
L00005dc2           lea.l   ACTORLIST_STRUCT_SIZE(a5),a5                ;$0016(a5),a5
L00005dc6           dbf.w   d7,L00005dbc
L00005dca           moveq   #$5a,d6
L00005dcc           bra.w   batman_lose_energy                          ;L00004d0a
                    ; use rts to exit

L00005dd0           move.w  (a5),d2
L00005dd2           beq.b   L00005dca 
L00005dd4           subq.w  #$01,d2
L00005dd6           bne.w   L00005d4a                                   ; exit rts
L00005dda           move.l  #actor_handler_cmd_nop,gl_jsr_address       ;#$000052b6,L00003c7c
L00005de0           move.w  #$0021,(a5)
L00005de4           clr.w   grappling_hook_height                       ;L00006360
L00005de8           move.w  #$ffff,L00006342
L00005dee           move.b  #PANEL_ST1_VAL_TIMER_EXPIRED,PANEL_STATUS_1 ;#$01,$0007c874                          ; PANEL
L00005df6           rts  



                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
                    ; IN:
                    ;   d0.w - Sprite X co-ord
                    ;   d1.w - Unknown - maybe Sprite Y
                    ;   a6.l - object/sprite structure ptr
                    ;
                    ; Code Checked 29/1/2025
                    ;
actor_cmd_33_level_complete ; original address L00005df8
L00005df8           move.w  scroll_window_x_coord,d2        ;L000069ec,d2
L00005dfc           cmp.w   #$0230,d2
L00005e00           beq.b   L00005e16
L00005e02           addq.w  #$02,$0002(a6)
L00005e06           moveq   #$70,d2
L00005e08           sub.w   d0,d2
L00005e0a           cmp.w   #$fffd,d2
L00005e0e           bcc.b   L00005e12
L00005e10           moveq.l #$fffffffe,d2
L00005e12           add.w   d2,target_window_x_offset       ;L000069f8

                    ; check level complete
L00005e16           cmp.w   #$0048,d1
L00005e1a           bcc.b   level_completed                 ;L00005e6e

L00005e1c           move.w  $000a(a6),d3
L00005e20           cmp.w   #$000e,d3
L00005e24           bpl.b   L00005e2c
L00005e26           addq.w  #$01,d3
L00005e28           move.w  d3,$000a(a6)
L00005e2c           asr.w   #$01,d3
L00005e2e           add.w   d3,$0004(a6)
L00005e32           moveq   #$18,d2
L00005e34           sub.w   d1,d2
L00005e36           add.w   d2,target_window_y_offset       ;L000069f6
L00005e3a           moveq   #$06,d2
L00005e3c           cmp.w   #$0004,d3
L00005e40           bmi.b   L00005e58
L00005e42           moveq   #$07,d2
L00005e44           cmp.w   #$0007,d2
L00005e48           bmi.b   L00005e58
L00005e4a           moveq   #$0c,d2
L00005e4c           and.w   playfield_swap_count,d2         ;L00006374,d2
L00005e50           lsr.w   #$02,d2
L00005e52           bne.b   L00005e56
L00005e54           moveq   #$02,d2
L00005e56           addq.w  #$07,d2
L00005e58           bsr.w   draw_next_sprite                ;L000045fa
L00005e5c           jsr     AUDIO_PLAYER_SILENCE            ;$00048004               ; AUDIO_PLAYER
L00005e62           move.l  #$00000210,d0
L00005e68           jmp     PANEL_ADD_SCORE                 ;$0007c82a               ; PANEL_ADD_SCORE
                    ; use rts to return



                    ; ------------------------ level completed ------------------------
                    ; IN:
                    ;   d0.w - Sprite X
                    ;   a6.l - address of object/sprite structure
                    ;
                    ; Code Checked 29/1/2025
                    ;
level_completed     ; original address L00005e6e 
                    moveq   #$50,d1
                    moveq   #$0b,d2
                    bsr.w   draw_next_sprite                            ;L000045fa
                    bsr.w   double_buffer_playfield                     ;L000036ee

cheat_complete_level    ;original address L00005e7a
                    bset.b  #PANEL_ST2_LEVEL_COMPLETE,PANEL_STATUS_2    ;#$0006,$0007c875
                    ; fall through to 'load_level_2'




                    ; -------------------------- load title screen ------------------------
                    ; do level completed sequence of displaying the text:
                    ;   - The End.
                    ;   - For the time being.
                    ; then clear the screen and load the title screen
                    ;
                    ; Code Checked 29/1/2025
                    ;
Load_title_screen   ; original address L00005e82
                    jsr     AUDIO_PLAYER_SILENCE                ;$00048004
                    moveq   #SFX_LEVEL_COMPLETE,d0              ;#$02,d0
                    jsr     AUDIO_PLAYER_INIT_SONG              ;$00048010
                    ; pause
                    move.w  #$00fa,d0
                    bsr.b   wait_for_frame_count                ;L00005ed4
                    ; pause
                    moveq   #$64,d0
                    bsr.w   wait_for_frame_count                ;L00005ed4
                    ; display 'The End.'
                    bsr.w   clear_backbuffer_playfield          ;L00004e66
                    lea.l   the_end_text,a0                     ;L00003ab1,a0
                    bsr.w   large_text_plotter                  ;l000069fa
                    bsr.w   screen_wipe_to_backbuffer           ;l00003caa
                    ; pause
                    moveq   #$64,d0
                    bsr.w   wait_for_frame_count                ;L00005ed4
                    ; display 'For the time being.'
                    bsr.w   clear_backbuffer_playfield          ;L00004e66
                    lea.l   time_being_text,a0                  ;L00003abd,a0
                    bsr.w   large_text_plotter                  ;L000069fa
                    bsr.w   screen_wipe_to_backbuffer           ;L00003caa
                    ; pause
                    moveq   #$64,d0
                    bsr.w   wait_for_frame_count                ;L00005ed4
                    ; clear screen
                    bsr.w   screen_wipe_to_black                ;L00003ca6
                    bsr.w   panel_fade_out                      ;L00003d76
                    ; load & execute title screen
                    bra.w   LOADER_TITLE_SCREEN                 ;L00000820     
                    ;*******************************
                    ;       LOAD TITLE SCREEN
                    ;         NEVER RETURNS
                    ;*******************************



                    ; -------- wait for frame count ---------
wait_for_frame_count    ; original address L00005ed4
                    add.w   frame_counter,d0            ;L000036e2,d0
.wait_loop          ;L00005ed8
                    cmp.w   frame_counter,d0            ;L000036e2,d0
                    bpl.b   .wait_loop                  ;L00005ed8
                    rts  




                    ; IN:
                    ;   d0 = actorX - display
                    ;   d1 = actorY - display
                    ;
                    ; Code Checked 29/1/2025
                    ;
L00005ee0           movem.w batman_xy_offset,d2-d3  ;L000069f2,d2-d3
L00005ee6           sub.w   d1,d3
L00005ee8           cmp.w   #$0001,d3               ; diff dispY and batY
L00005eec           bcc.b   L00005f12               ; exit rts >= 1
L00005eee           sub.w   d0,d2                   ; diff dispX and batX
L00005ef0           cmp.w   #$0020,d2               ; exit rts >= 20
L00005ef4           bcc.b   L00005f12               ; exit rts
L00005ef6           move.b  batman_sprite1_id+1,d2  ; L00006337,d2
L00005efa           cmp.b   #$24,d2
L00005efe           rts  



                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
                    ;
                    ; Code Checked 29/1/2025
                    ;
actor_cmd_26        ; original address L00005f00
L00005f00           bsr.b   L00005ee0
L00005f02           bcc.b   L00005f12                           ; exit rts
L00005f04           move.w  #$0018,target_window_y_offset       ;L000069f6
L00005f0a           addq.w  #$01,(a6)
L00005f0c           move.w  #$0020,$0008(a6) 
L00005f12           rts  



                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
                    ;
                    ; Code Checked 29/1/2025
                    ;
actor_cmd_27        ; original address L00005f14
L00005f14           subq.w  #$01,$0008(a6)
L00005f18           beq.b   L00005f40
L00005f1a           moveq   #$27,d2
L00005f1c           sub.w   $0008(a6),d2
L00005f20           lsr.w   #$03,d2
L00005f22           move.w  d2,-(a7)
L00005f24           bsr.w   draw_next_sprite        ;L000045fa
L00005f28           addq.w  #$08,d0
L00005f2a           move.w  (a7),d2
L00005f2c           bsr.w   draw_next_sprite        ;L000045fa
L00005f30           addq.w  #$08,d0
L00005f32           move.w  (a7),d2
L00005f34           bsr.w   draw_next_sprite        ;L000045fa
L00005f38           addq.w  #$08,d0
L00005f3a           move.w  (a7)+,d2
L00005f3c           bra.w   draw_next_sprite        ;L000045fa 
                    ; uses rts in draw_next_sprite to exit

                    ; IN:-
                    ;   a0.l = level data index?
                    ;
                    ; Code Checked 29/1/2025
                    ;
L00005f40           clr.w   (a6)
L00005f42           bsr.w   get_map_tile_at_display_offset_d0_d1    ; L000055e0
L00005f46           lsl.w   #$08,d2
L00005f48           move.b  $01(a0,d3.w),d2
L00005f4c           move.b  $02(a0,d3.w),d4
L00005f50           lsl.w   #$08,d4
L00005f52           move.b  $03(a0,d3.w),d4
L00005f56           movea.l L00005FAC,a5
L00005f5a           movem.w d2-d4,-(a5)
L00005f5e           move.l  a5,L00005FAC
L00005f62           move.b  #$4f,$00(a0,d3.w)
L00005f68           move.b  #$4f,$01(a0,d3.w)
L00005f6e           move.b  #$4f,$02(a0,d3.w)
L00005f74           move.b  #$4f,$03(a0,d3.w)
L00005f7a           bsr.w   L00005ee0
L00005f7e           bcc.b   actor_cmd_28                                    ;L00005f8a 
L00005f80           move.l  #player_input_cmd_fire_down,gl_jsr_address      ;#$0000540e,00003c7c
L00005f86           clr.w   grappling_hook_height                           ;L00006360



                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
                    ;
                    ; Code Checked 29/1/2025
                    ;
actor_cmd_28        ; original address L00005f8a
L00005f8a           moveq   #$05,d2
L00005f8c           bsr.w   draw_next_sprite                ;L000045fa
L00005f90           moveq   #$05,d2
L00005f92           addq.w  #$08,d0
L00005f94           bsr.w   draw_next_sprite                ;L000045fa
L00005f98           moveq   #$05,d2
L00005f9a           addq.w  #$08,d0
L00005f9c           bsr.w   draw_next_sprite                ;L000045fa
L00005fa0           moveq   #$05,d2
L00005fa2           addq.w  #$08,d0
L00005fa4           bsr.w   draw_next_sprite                ;L000045fa
L00005fa8           bra.w   initialise_offscreen_buffer     ;L000058ea 




L00005FAC       dc.l    L0000600C       ;                   ; a ptr used with map data - to location down below

l00005FB0       dc.w    $0000,$0000 
                dc.w    $0000,$0000
                dc.w    $0000,$0000 
L00005FBC       dc.w    $0000,$0000 
                dc.w    $0000,$0000
                dc.w    $0000,$0000
                dc.w    $0000,$0000 
L00005FCC       dc.w    $0000,$0000 
                dc.w    $0000,$0000
                dc.w    $0000,$0000
                dc.w    $0000,$0000 
L00005FDC       dc.w    $0000,$0000 
                dc.w    $0000,$0000
                dc.w    $0000,$0000
                dc.w    $0000,$0000 
L00005FEC       dc.w    $0000,$0000 
                dc.w    $0000,$0000
                dc.w    $0000,$0000
                dc.w    $0000,$0000 
L00005FFC       dc.w    $0000,$0000 
                dc.w    $0000,$0000
                dc.w    $0000,$0000
                dc.w    $0000,$0000 

L0000600C       dc.w    $0000,$0000                 ; data location initially pointed to by ptr above L00005f64
L00006010       dc.w    $0000                       ; 3 words used by level data initialisation
                dc.w    $0000



                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
                    ;
                    ; Code Checked 29/1/2025
                    ;
actor_cmd_29        ; original address L00006014
; Line 7616 - code1.s
L00006014           cmp.w   #$00c0,d0
L00006018           bpl.b   L0000605a
L0000601a           and.w   #$0007,d4
L0000601e           bne.b   L0000602e
L00006020           addq.w  #$08,d0
L00006022           bsr.w   get_map_tile_at_display_offset_d0_d1    ; L000055e0
L00006026           subq.w  #$08,d0
L00006028           cmp.b   #$51,d2
L0000602c           bcs.b   L0000605a
L0000602e           addq.w  #$01,$0002(a6)
L00006032           subq.w  #$01,$0008(a6)
L00006036           bpl.b   L0000605e
L00006038           movem.w batman_xy_offset,d2-d3      ;L000069f2,d2-d3
L0000603e           sub.w   d0,d2
L00006040           cmp.w   #$0008,d2
L00006044           bcc.b   L0000605e
L00006046           sub.w   d1,d3
L00006048           cmp.w   #$0013,d3
L0000604c           bcc.b   L0000605e
L0000604e           move.w  #$0019,$0008(a6)
L00006054           moveq   #$02,d6
L00006056           bsr.w   batman_lose_energy      ;L00004d0a
L0000605a           move.w  #$001e,(a6)
L0000605e           move.w  d4,d2
L00006060           lsr.w   #$01,d2
L00006062           addq.w  #$01,d2
L00006064           bra.w   draw_next_sprite        ;L000045fa




                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
actor_cmd_30        ; original address L00006068
L00006068           cmp.w   #$ffc0,d0
L0000606c           bmi.b   L000060b2
L0000606e           and.w   #$0007,d4
L00006072           bne.b   L00006086
L00006074           sub.w   #$0010,d0
L00006078           bsr.w   get_map_tile_at_display_offset_d0_d1    ; L000055e0
L0000607c           add.w   #$0010,d0
L00006080           cmp.b   #$51,d2
L00006084           bcs.b   L000060b2
L00006086           subq.w  #$01,$0002(a6)
L0000608a           subq.w  #$01,$0008(a6)
L0000608e           bpl.b   L000060b6
L00006090           movem.w batman_xy_offset,d2-d3      ; L000069f2,d2-d3
L00006096           sub.w   d0,d2
L00006098           add.w   #$000a,d2
L0000609c           bcc.b   L000060b6
L0000609e           sub.w   d1,d3
L000060a0           cmp.w   #$0013,d3
L000060a4           bcc.b   L000060b6 
L000060a6           move.w  #$0019,$0008(a6)
L000060ac           moveq   #$02,d6
L000060ae           bsr.w   batman_lose_energy      ; L00004d0a
L000060b2           move.w  #$001d,(a6)
L000060b6           move.w  #$e003,d2
L000060ba           lsr.w   #$01,d4
L000060bc           eor.w   d4,d2
L000060be           addq.w  #$01,d2
L000060c0           bra.w   draw_next_sprite        ;L000045fa
                    ; use rts to return

                    even

;Line 7686 - Code1.s
                    ; ---------------- display object co-ordinates ---------------
                    ; Start of 305 (sprite x & y positions - initialisation data)
display_object_coords       ; original address L000060C4
L000060C4           dc.w    $2A02,$2005,$2005,$2004,$1505,$1506,$1506,$1507
L000060D4           dc.w    $1507,$1506,$1507,$1507,$2C10,$2C08,$1402,$210D
L000060E4           dc.w    $2B05,$1905,$2504,$1706,$1702,$2005,$0F06,$0006
L000060F4           dc.w    $2405,$1507,$1C05,$1007,$1207,$1B03,$1308,$2C07
L00006104           dc.w    $2C07,$2C07,$2C07,$2904,$1A06,$03FE,$2902,$2008
L00006114           dc.w    $1306,$2A08,$2007,$2A04,$2A02,$24FA,$1405,$2A03
L00006124           dc.w    $2A08,$0F05,$0F05,$0F05,$0F05,$2A07,$1507,$1508
L00006134           dc.w    $1507,$1508,$0200,$0201,$0202,$0000,$0100,$0100
L00006144           dc.w    $0101,$0604,$0B07,$0F07,$0C07,$0B06,$2005,$1208
L00006154           dc.w    $1200,$2903,$2206,$2205,$2204,$1506,$1507,$1508
L00006164           dc.w    $1504,$1504,$1506,$1507,$1504,$2904,$25FD,$1305
L00006174           dc.w    $2904,$2CFD,$2904,$1BFD,$2004,$1CFD,$0C07,$2805
L00006184           dc.w    $1503,$1503,$1503,$1503,$0301,$0301,$0601,$0401
L00006194           dc.w    $0400,$04FD,$04FA,$1D05,$1108,$0809,$2903,$2006
L000061A4           dc.w    $2005,$2004,$1506,$1507,$1508,$1504,$1504,$1506
L000061B4           dc.w    $1507,$1504,$2906,$1306,$2A07,$2904,$2EFC,$2904
L000061C4           dc.w    $25FB,$0C0F,$2211,$3416,$2C16,$2009,$1208,$0B08
L000061D4           dc.w    $2903,$2005,$2004,$2004,$1505,$1506,$1507,$1503
L000061E4           dc.w    $1504,$1505,$1506,$1503,$2903,$25FC,$1405,$0800
L000061F4           dc.w    $0303,$2904,$1BFD,$2004,$1CFD,$0C07,$2004,$1207
L00006204           dc.w    $0B07,$2904,$2006,$2005,$2004,$1506,$1507,$1508
L00006214           dc.w    $1504,$1504,$1506,$1507,$1504,$2904,$25FD,$1405
L00006224           dc.w    $2B04,$2FFD,$2904,$18FC,$2004,$1CFD,$0C07,$2806
L00006234           dc.w    $1803,$1803,$1803,$1803,$0000,$0000,$0000,$0000
L00006244           dc.w    $0000,$0908,$0908,$0908,$0808,$1D05,$1308,$0809
L00006254           dc.w    $2904,$2006,$2005,$2004,$1506,$1507,$1508,$1504
L00006264           dc.w    $1504,$1506,$1507,$1503,$2904,$25FD,$1505,$2B04
L00006274           dc.w    $2FFE,$2904,$19FD,$2202,$1EFC,$1005,$2805,$1504
L00006284           dc.w    $1504,$1504,$1504,$2906,$1503,$1503,$1503,$1503
L00006294           dc.w    $1505,$0A08,$0009,$2903,$2005,$2004,$2004,$1405
L000062A4           dc.w    $1406,$1407,$1404,$1404,$1405,$1406,$1402,$2906
L000062B4           dc.w    $1506,$2906,$2A07,$2903,$2EFC,$2903,$24FC,$2004
L000062C4           dc.w    $2004,$2004,$2004,$2706,$1304,$1304,$1304,$1303
L000062D4           dc.w    $190B,$0F09,$120D,$130D,$1309,$0B0F,$1D05,$1208
L000062E4           dc.w    $0808,$2903,$2005,$2004,$2004,$1405,$1406,$1407
L000062F4           dc.w    $1404,$1404,$1405,$1406,$1402,$2903,$25FD,$1306
L00006304           dc.w    $2B04,$2FFD,$2903,$18FC,$2202,$1EFC,$1005,$2805
L00006314           dc.w    $1504,$1504,$1504,$1504,$2906,$1503,$1503,$1503
L00006324           dc.w    $1503 
; End of 305 (sprite x & y positions - initialisation data)

L00006326           dc.w    $0001,$0002,$0003,$0004,$0005,$0007 

batman_sprite3_id       ; original address L00006332
L00006332           dc.w    $0005 
batman_sprite2_id       ; original address L00006334
L00006334           dc.w    $0002
batman_sprite1_id       ; original address L00006336
L00006336           dc.w    $0001 

batman_y_bottom         ; original address L00006338
L00006338           dc.w    $0000 

state_parameter         ; original address L0000633a
L0000633a           dc.w    $0000 

batman_swing_fall_speed ; original address L0000633c
batman_swing_speed      ; original address L0000633c
L0000633c           dc.w    $0000 

batman_fall_speed       ; original address L0000633E
L0000633E           dc.w    $0000 

batman_fall_distance    ; original address L00006340
L00006340           dc.w    $0000   

L00006342           dc.w    $0001

level_spawn_point_index ; original address L00006344
L00006344           dc.w    $0000 


sprite_array_ptr        ; original address L00006346
L00006346           dc.l   BATSPR1_SPRTIE_LIST  ; $00010000 ; $00010000      ; ptr to an array of sprite definition data structures
                                        ; structure def:
                                        ;  byte offset | description
                                        ;           0  | Y Offset
                                        ;           1  | X Offset
                                        ;           2  | Width in Words
                                        ;           3  | Height in Lines
                                        ;         4-7  | Long Pointer to GFX Data (Mask, BPL0, BPL1, BPL2, BPL3)

sprite_gfx_left_offset  ; original address L0000634A
L0000634A           dc.l    $00000000 

L0000634e           dc.w    $0000
                    ;dc.w    $0000
                    

player_input_command    ; original address L00006350
L00006350            dc.b $00                        ; bit 0 = left
                                                    ; bit 1 = right
                                                    ; bit 2 = down
                                                    ; bit 3 = up
                                                    ; bit 4 = pulse when button pressed

player_button_pressed   ; original address L00006351
L00006351            dc.b $00            ; #$00 = not pressed, #$ff = button pressed


background_gfx_base     ; original address L00006354
L00006352           dc.l    MAPGR_GFX_ADDRESS       ;$0000C77C      ; MAPGR_GFX_ADDRESS

L00006356           dc.w    $0000 

vertical_scroll_increments  ; original address L00006358
L00006358           dc.w    $0000           ; the number of increments +/- the window has scrolled this frame.

offscreen_y_coord       ; original address L0000635A
L0000635A           dc.w    $0000           ; Y co-ord into offscreen buffer (circular buffer).

grappling_hook_params   ; original address L0000635C
L0000635C           dc.w    $0000 
L0000635E           dc.w    $0000 
grappling_hook_height   ; original address L00006360
L00006360           dc.w    $0000 
L00006362           dc.w    $0000 
L00006364           dc.w    $0034 

offscreen_display_buffer_ptr    ; original address L00006366
L00006366           dc.l    CODE1_CHIPMEM_BUFFER        ;$0005A36C       ; CODE1_CHIPMEM_BUFFER

                    ; L0000636a
L0000636a           dc.l    trigger_new_actors          ;$00003DEC      ; trigger_new_actors

batman_sprite_anim_ptr  ; original address L0000636E  ; modified to long (haven't yet)
L0000636E           dc.l    $00000000 
;L0000636E           dc.w    $0000 

L00006370           dc.w    $0000 
L00006372           dc.w    $0000 

playfield_swap_count    ; original address L00006374
L00006374               dc.w    $0000

L00006376           dc.w    $2221,$201F,$1E1D,$1C1B,$1A19,$1817,$1615 
L00006384           dc.w    $1413,$1211,$100F,$0E0D,$0C0B,$0A09,$0807,$0605 
L00006394           dc.w    $0403,$0201 

L00006398           dc.w    $0003,$0609,$0D10,$1316,$191C,$1F22 
L000063A4           dc.w    $2529,$2C2F,$3235,$383B,$3E41,$4447,$4A4D,$5053 
L000063B4           dc.w    $5659,$5C5F,$6264,$676A,$6D70,$7375,$787B,$7E80 
L000063C4           dc.w    $8386,$888B,$8E90,$9395,$989A,$9D9F,$A2A4,$A7A9 
L000063D4           dc.w    $ABAE,$B0B2 
; 000063D8 = L0000635C + $7c (grappling hook code) - is this swing data?
L000063D8           dc.w    $B4B7,$B9BB,$BDBF,$C1C3,$C5C7,$C9CB 
L000063E4           dc.w    $CDCF,$D0D2,$D4D6,$D7D9,$DBDC,$DEDF,$E1E2,$E4E5 
L000063F4           dc.w    $E7E8,$E9EA,$ECED,$EEEF,$F0F1,$F2F3,$F4F5,$F6F7 
L00006404           dc.w    $F7F8,$F9F9,$FAFB,$FBFC,$FCFD,$FDFD,$FEFE,$FEFF 
L00006414           dc.w    $FFFF,$FFFF 


                    ; sprite 3 array structure
                    ; byte 0 = initial sprite id
                    ; byte 1 = second sprite offset
                    ; byte 2 = third sprite offset
batman_sprite_anim_fire_hook    ; original address L00006418
L00006418           dc.b    $30,$D2,$04

batman_sprite_anim_standing     ; original address L0000641B
L0000641B           dc.b    $01,$02,$07 

batman_sprite_anim_ducking      ; original address L0000641e
L0000641e           dc.b    $19,$01,$E6

batman_sprite_anim_ducked       ; original address L00006421
L00006421           dc.b    $1E,$01,$E1  

batman_sprite_anim_life_lost    ; original address L00006424
L00006424           dc.b    $19,$01,$E6
                    dc.b    $19,$01,$E6 
                    dc.b    $19,$01,$E6
                    dc.b    $1B,$01,$E4 
                    dc.b    $1B,$01,$E4
                    dc.b    $1B,$01,$E4 
                    dc.b    $1B,$01,$E4
                    dc.b    $1B,$01,$E4 
                    dc.b    $1B,$01,$E4
                    dc.b    $1B,$01,$E4 
                    dc.b    $1B,$01,$E4
                    dc.b    $1D,$E3,$00 
                    dc.b    $1D,$E3,$00
                    dc.b    $1D,$E3,$00 
                    dc.b    $1D,$E3,$00
                    dc.b    $1D,$E3,$00  
L00006454           dc.b    $1D,$E3,$00
                    dc.b    $1D,$E3,$00 
                    dc.b    $1D,$E3,$00
                    dc.b    $00 

batman_sprite_anim_07       ; original address L0000645E
L0000645E           dc.b    $24,$01,$01

batman_sprite_anim_firing   ; original address L00006461
L00006461           dc.b    $27,$01,$01  
L00006464           dc.b    $2A,$01,$FE
                    dc.b    $2C,$FD,$D7 
                    dc.b    $2D,$01,$01
                    dc.b    $00 

batman_sprite_anim_climb_platform ; original address L0000646E
L0000646E           dc.b    $13,$01,$01 
                    dc.b    $16,$01,$01 
L00006474           dc.b    $00

L00006475           dc.b    $E4 


                    ; referenced during game_start
                    ; appears to be a data structure where word at offet 4 is a multiple of 6 bytes to start of next structure.
                    ; each line of data below appears to be the start of a variable length data structure.
                    ; 
                    ; The MSB of byte offset 0 is a flag which is reset at level start.
                    ;
                    ;   Offset  |   Description
                    ;   --------|---------------
                    ;      0-1  | Possibly Actor/Trigger X Value in low byte  
                    ;           | MSB (bit 7) - flag
                    ;           |  
                    ;      2-3  | Possibly Actor/Trigger Y value in low byte
                    ;           |
                    ;      4-5  | Number of actors to trigger. 
                    ;           |
                    ;      (x)  | Remaining bytes ( 6 bytes per Actor Data ) -(type?, X co-ord, Y co-ord)
                    ;           |
                    ;
                    ;
                    even
                    ; I think these maybe trigger-points for (x) number of bad guys to appear on the level.
                    ; e.g. - 
trigger_definitions_list    ; original address L00006476
L00006476           dc.w    $0050,$041E,$0001,$0022,$0080,$0400,$0190,$0260             ;.P.....".......`
L00006486           dc.w    $0001,$0023,$0160,$0260,$0040,$0610,$0003,$0003             ;...#.`.`.@......
L00006496           dc.w    $00A8,$0628,$000F,$00A8,$0648,$000F,$00B8,$0648             ;...(.....H.....H
L000064A6           dc.w    $0080,$05F0,$0003,$000E,$0040,$05E8,$000F,$00C0             ;.........@......
L000064B6           dc.w    $05E8,$000F,$00C0,$05A8,$00E0,$0580,$0002,$0002             ;................
L000064C6           dc.w    $0040,$05A8,$0003,$00F0,$05A8,$0130,$05D2,$0002             ;.@.........0....
L000064D6           dc.w    $000E,$0128,$05E8,$0002,$00A4,$05A8,$0130,$0612             ;...(.........0..
L000064E6           dc.w    $0001,$000F,$0140,$0648,$01A6,$0640,$0002,$000F             ;.....@.H...@....
L000064F6           dc.w    $01C0,$0648,$000E,$0100,$0648,$0144,$0580,$0002             ;...H.....H.D....
L00006506           dc.w    $000E,$00A2,$05A8,$000F,$00A0,$05A8,$01FA,$0640             ;...............@
L00006516           dc.w    $0003,$000E,$0160,$0628,$000F,$0208,$0628,$0002             ;.....`.(.....(..
L00006526           dc.w    $0240,$0648,$0220,$0600,$0002,$000F,$0240,$05E8             ;.@.H. .......@..
L00006536           dc.w    $0003,$0260,$0648,$02B0,$057A,$0001,$000F,$0230             ;...`.H...z.....0
L00006546           dc.w    $05E8,$0070,$04F0,$0001,$0002,$0110,$0548,$0050             ;...p.........H.P
L00006556           dc.w    $04CE,$0003,$000F,$0110,$04E8,$000F,$0108,$04E8             ;................
L00006566           dc.w    $000F,$0118,$04E8,$0150,$04CE,$0002,$000F,$0160             ;.......P.......`
L00006576           dc.w    $04E8,$000F,$0060,$04E8,$0180,$04FF,$0001,$0003             ;.....`..........
L00006586           dc.w    $019F,$0528,$01A0,$0500,$0001,$0003,$01D0,$0548             ;...(...........H
L00006596           dc.w    $01F8,$0530,$0002,$000E,$0150,$0528,$0002,$0150             ;...0.....P.(...P
L000065A6           dc.w    $0548,$01A0,$05C5,$0001,$000F,$01B8,$05E8,$01E0             ;.H..............

L000065B6           dc.w    $0583,$0001,$0003,$0200,$05A8,$0201,$0580,$0003             ;................
L000065C6           dc.w    $000F,$0220,$05A8,$000F,$022C,$05A8,$000F,$0238             ;... .....,.....8
L000065D6           dc.w    $05A8,$0218,$0570,$0002,$000F,$0240,$0568,$000F             ;.....p.....@.h..
L000065E6           dc.w    $0260,$05A8,$0218,$0549,$0002,$000F,$0230,$0548             ;.`.....I.....0.H
L000065F6           dc.w    $000F,$0210,$0528,$0240,$051F,$0002,$000F,$01F8             ;.....(.@........
L00006606           dc.w    $0508,$000F,$01E0,$0508,$0240,$04F0,$0003,$000F             ;.........@......
L00006616           dc.w    $0250,$04E8,$000F,$0238,$04E8,$000F,$0220,$04E8             ;.P.....8..... ..
L00006626           dc.w    $01AB,$04A0,$0001,$0003,$0258,$04E8,$0130,$0440             ;.........X...0.@
L00006636           dc.w    $0002,$000F,$0148,$04A8,$000E,$01A0,$04A8,$00E0             ;.....H..........
L00006646           dc.w    $0468,$0002,$000F,$00D0,$0468,$000E,$0068,$04A8             ;.h.......h...h..
L00006656           dc.w    $0088,$0481,$0002,$000F,$0068,$04A8,$000F,$0088             ;.........h......
L00006666           dc.w    $0468,$0080,$03C0,$0001,$0003,$0120,$0408,$0159             ;.h......... ...Y
L00006676           dc.w    $03E0,$0003,$000E,$0188,$03E8,$000E,$0180,$0408             ;................
L00006686           dc.w    $0002,$01A0,$03E8,$01B4,$03E0,$0002,$000E,$00F4             ;................
L00006696           dc.w    $0408,$000E,$00E8,$0408,$01F8,$0411,$0001,$000F             ;................
L000066A6           dc.w    $0238,$0448,$0240,$03E4,$0003,$000E,$0200,$03E8             ;.8.H.@..........
L000066B6           dc.w    $000E,$0210,$03E8,$000E,$0220,$03E8,$0240,$03C0             ;......... ...@..
L000066C6           dc.w    $0003,$000F,$0240,$03A8,$000F,$0230,$03A8,$000F             ;.....@.....0....
L000066D6           dc.w    $0220,$03A8,$01E0,$0390,$0006,$0002,$01F0,$0388             ;. ..............
L000066E6           dc.w    $000E,$01A0,$03A8,$000E,$01F0,$0348,$000E,$0200             ;...........H....
L000066F6           dc.w    $0348,$000E,$01F0,$03A8,$000E,$01F8,$03A8,$01A0             ;.H..............
L00006706           dc.w    $02A8,$0001,$0002,$01A0,$0288,$015E,$0250,$0002             ;...........^.P..
L00006716           dc.w    $000F,$0218,$0288,$000F,$020C,$0288,$010C,$02C0             ;................
L00006726           dc.w    $0002,$0002,$00E0,$02E8,$0002,$00F0,$02E8,$00EA             ;................
L00006736           dc.w    $03AA,$0003,$000F,$0110,$03A8,$000F,$0100,$03A8             ;................
L00006746           dc.w    $0003,$01C0,$03A8,$00EA,$0398,$0002,$000F,$013C             ;...............<
L00006756           dc.w    $0408,$000F,$014C,$0408,$00D0,$0330,$0002,$000F             ;.....L.....0....
L00006766           dc.w    $01AC,$0348,$000F,$01A0,$0348,$00B0,$0380,$0002             ;...H.....H......
L00006776           dc.w    $0003,$015C,$03A8,$000E,$0088,$019E,$0070,$0380             ;...\.........p..
L00006786           dc.w    $0002,$000F,$0128,$03A8,$000F,$0138,$03A8,$0126             ;.....(.....8...&
L00006796           dc.w    $0350,$0001,$0003,$0158,$0348,$0189,$0350,$0002             ;.P.....X.H...P..
L000067A6           dc.w    $000E,$00E8,$0348,$000F,$0198,$0348,$00C0,$029B             ;.....H.....H....
L000067B6           dc.w    $0002,$000E,$0120,$0288,$000E,$0140,$0268,$00C0             ;..... .....@.h..
L000067C6           dc.w    $025E,$0003,$0003,$0150,$0268,$000F,$00F0,$0248             ;.^.....P.h.....H
L000067D6           dc.w    $000E,$00F0,$0248,$00CC,$021F,$0002,$000F,$00F0             ;.....H..........
L000067E6           dc.w    $0208,$000E,$00F0,$0208,$00CC,$01D0,$0001,$000F             ;................
L000067F6           dc.w    $00F0,$01C8,$0146,$01A0,$0001,$0003,$0160,$01C8             ;.....F.......`..
L00006806           dc.w    $018A,$0190,$0001,$000F,$01A0,$01A8,$01B3,$0180             ;................
L00006816           dc.w    $0001,$000F,$01D8,$01C8,$0210,$018C,$0003,$000E             ;................
L00006826           dc.w    $00A8,$0288,$000F,$0198,$0248,$0002,$01C8,$0228             ;.........H.....(

L00006836           dc.w    $01C0,$01F1,$0002,$000E,$01C8,$01E8,$000E,$01D8             ;................
L00006846           dc.w    $01E8,$0235,$01F8,$0002,$000E,$01C8,$01E8,$000E             ;...5............
L00006856           dc.w    $01D8,$01E8,$0235,$01CE,$0002,$000E,$0180,$01A8             ;.....5..........
L00006866           dc.w    $000E,$0188,$01A8,$0200,$019F,$0001,$0003,$0160             ;...............`
L00006876           dc.w    $01A8,$014C,$0170,$0002,$000F,$0120,$0168,$0003             ;...L.p..... .h..
L00006886           dc.w    $0130,$0168,$018A,$0100,$0002,$0002,$00E8,$0128             ;.0.h...........(
L00006896           dc.w    $0003,$01A0,$0128,$0124,$0120,$0003,$0002,$00E8             ;.....(.$. ......
L000068A6           dc.w    $0128,$000F,$0124,$0128,$000F,$01A0,$01A8,$01B0             ;.(...$.(........
L000068B6           dc.w    $0100,$0002,$000E,$01D0,$0108,$0003,$01D0,$0148             ;...............H
L000068C6           dc.w    $0194,$00C8,$0001,$0002,$0140,$00C8,$0180,$0080             ;.........@......
L000068D6           dc.w    $0004,$000E,$0120,$00C8,$000E,$0114,$00C8,$000E             ;..... ..........
L000068E6           dc.w    $0108,$00C8,$0002,$00F0,$00A8,$0107,$00A0,$0003             ;................
L000068F6           dc.w    $000E,$00E8,$00C8,$000E,$00E8,$00A8,$0003,$01C0             ;................
L00006906           dc.w    $00C8,$0140,$000F,$0002,$0003,$0168,$0048,$0003             ;...@.......h.H..
L00006916           dc.w    $0178,$0048,$0184,$0020,$0003,$000F,$01B0,$0048             ;.x.H... .......H
L00006926           dc.w    $000F,$01A0,$0048,$000E,$00E8,$0048,$01A6,$0020             ;.....H.....H...
L00006936           dc.w    $0002,$0020,$01C0,$0048,$001F,$01C0,$0038



;L00006476           dc.w    $0050,$041E,$0001,$0022,$0080,$0400 
;                    dc.w    $0190,$0260,$0001,$0023,$0160,$0260
;                    dc.w    $0040,$0610,$0003,$0003,$00A8,$0628,$000F,$00A8,$0648,$000F,$00B8,$0648 
;                    dc.w    $0080,$05F0,$0003,$000E,$0040,$05E8,$000F,$00C0,$05E8,$000F,$00C0,$05A8 
;                    dc.w    $00E0,$0580,$0002,$0002,$0040,$05A8,$0003,$00F0,$05A8 
;                    dc.w    $0130,$05D2,$0002,$000E,$0128,$05E8,$0002,$00A4,$05A8 
;                    dc.w    $0130,$0612,$0001,$000F,$0140,$0648 
;                    dc.w    $01A6,$0640,$0002,$000F,$01C0,$0648,$000E,$0100,$0648 
;                    dc.w    $0144,$0580,$0002,$000E,$00A2,$05A8,$000F,$00A0,$05A8 
;                    dc.w    $01FA,$0640,$0003,$000E,$0160,$0628,$000F,$0208,$0628,$0002,$0240,$0648 
;                    dc.w    $0220,$0600,$0002,$000F,$0240,$05E8,$0003,$0260,$0648 
;                    dc.w    $02B0,$057A,$0001,$000F,$0230,$05E8 
;                    dc.w    $0070,$04F0,$0001,$0002,$0110,$0548  
;                    dc.w    $0050,$04CE,$0003,$000F,$0110,$04E8,$000F,$0108,$04E8,$000F,$0118,$04E8
;                    dc.w    $0150,$04CE,$0002,$000F,$0160,$04E8,$000F,$0060,$04E8
;                    dc.w    $0180,$04FF,$0001,$0003,$019F,$0528
;                    dc.w    $01A0,$0500,$0001,$0003,$01D0,$0548 
;                    dc.w    $01F8,$0530,$0002,$000E,$0150,$0528 0002 0150 0548
;                    dc.w    $01A0,$05C5,$0001,$000F,$01B8,$05E8  
;L000065B4           dc.w    $01E0,$0583,$0001,$0003,$0200,$05A8 
;                    dc.w    $0201,$0580,$0003,$000F,$0220,$05A8,$000F,$022C,$05A8,$000F,$0238,$05A8 
;                    dc.w    $0218,$0570,$0002,$000F,$0240,$0568,$000F,$0260,$05A8 
;                    dc.w    $0218,$0549,$0002,$000F,$0230,$0548,$000F,$0210,$0528 
;                    dc.w    $0240,$051F,$0002,$000F,$01F8,$0508,$000F,$01E0,$0508 
;                    dc.w    $0240,$04F0,$0003,$000F,$0250,$04E8,$000F,$0238,$04E8,$000F,$0220,$04E8 
;                    dc.w    $01AB,$04A0,$0001,$0003,$0258,$04E8 
;                    dc.w    $0130,$0440,$0002,$000F,$0148,$04A8,$000E,$01A0,$04A8  
;L0006644            dc.w    $00E0,$0468,$0002,$000F,$00D0,$0468,$000E,$0068,$04A8 
;                    dc.w    $0088,$0481,$0002,$000F,$0068,$04A8,$000F,$0088,$0468 
;                    dc.w    $0080,$03C0,$0001,$0003,$0120,$0408  
;L00006674           dc.w    $0159,$03E0,$0003,$000E,$0188,$03E8,$000E,$0180,$0408,$0002,$01A0,$03E8 
;                    dc.w    $01B4,$03E0,$0002,$000E,$00F4,$0408,$000E,$00E8,$0408 
;                    dc.w    $01F8,$0411,$0001,$000F,$0238,$0448 
;                    dc.w    $0240,$03E4,$0003,$000E,$0200,$03E8,$000E,$0210,$03E8,$000E,$0220,$03E8 
;                    dc.w    $0240,$03C0,$0003,$000F,$0240,$03A8,$000F,$0230,$03A8,$000F,$0220,$03A8
;                    dc.w    $01E0,$0390,$0006,$0002,$01F0,$0388,$000E,$01A0,$03A8,$000E,$01F0,$0348,$000E,$0200,$0348,$000E,$01F0,$03A8,$000E,$01F8,$03A8  
;L00006704           dc.w    $01A0,$02A8,$0001,$0002,$01A0,$0288 
;                    dc.w    $015E,$0250,$0002,$000F,$0218,$0288,$000F,$020C,$0288 
;                    dc.w    $010C,$02C0,$0002,$0002,$00E0,$02E8,$0002,$00F0,$02E8 
;                    dc.w    $00EA,$03AA,$0003,$000F,$0110,$03A8,$000F,$0100,$03A8,$0003,$01C0,$03A8
;                    dc.w    $00EA,$0398,$0002,$000F,$013C,$0408,$000F,$014C,$0408 
;                    dc.w    $00D0,$0330,$0002,$000F,$01AC,$0348,$000F,$01A0,$0348 
;                    dc.w    $00B0,$0380,$0002,$0003,$015C,$03A8,$000E,$0088,$019E 
;                    dc.w    $0070,$0380,$0002,$000F,$0128,$03A8,$000F,$0138,$03A8 
;L00006794           dc.w    $0126,$0350,$0001,$0003,$0158,$0348 
;                    dc.w    $0189,$0350,$0002,$000E,$00E8,$0348,$000F,$0198,$0348
;                    dc.w    $00C0,$029B,$0002,$000E,$0120,$0288,$000E,$0140,$0268 
;L000067C4           dc.w    $00C0,$025E,$0003,$0003,$0150,$0268,$000F,$00F0,$0248,$000E,$00F0,$0248
;                    dc.w    $00CC,$021F,$0002,$000F,$00F0,$0208,$000E,$00F0,$0208 
;                    dc.w    $00CC,$01D0,$0001,$000F,$00F0,$01C8 
;                    dc.w    $0146,$01A0,$0001,$0003,$0160,$01C8
;                    dc.w    $018A,$0190,$0001,$000F,$01A0,$01A8 
;                    dc.w    $01B3,$0180,$0001,$000F,$01D8,$01C8 
;                    dc.w    $0210,$018C,$0003,$000E,$00A8,$0288,$000F,$0198,$0248,$0002,$01C8,$0228
;                    dc.w    $01C0,$01F1,$0002,$000E,$01C8,$01E8,$000E,$01D8,$01E8 
;                    dc.w    $0235,$01F8,$0002,$000E,$01C8,$01E8,$000E,$01D8,$01E8 
;                    dc.w    $0235,$01CE,$0002,$000E,$0180,$01A8,$000E,$0188,$01A8
;                    dc.w    $0200,$019F,$0001,$0003,$0160,$01A8 
;                    dc.w    $014C,$0170,$0002,$000F,$0120,$0168,$0003,$0130,$0168
;                    dc.w    $018A,$0100,$0002,$0002,$00E8,$0128,$0003,$01A0,$0128 
;                    dc.w    $0124,$0120,$0003,$0002,$00E8,$0128,$000F,$0124,$0128,$000F,$01A0,$01A8 
;L000068B4           dc.w    $01B0,$0100,$0002,$000E,$01D0,$0108,$0003,$01D0,$0148 
;                    dc.w    $0194,$00C8,$0001,$0002,$0140,$00C8 
;                    dc.w    $0180,$0080,$0004,$000E,$0120,$00C8,$000E,$0114,$00C8,$000E,$0108,$00C8,$0002,$00F0,$00A8 
;                    dc.w    $0107,$00A0,$0003,$000E,$00E8,$00C8,$000E,$00E8,$00A8,$0003,$01C0,$00C8 
;                    dc.w    $0140,$000F,$0002,$0003,$0168,$0048,$0003,$0178,$0048 
;                    dc.w    $0184,$0020,$0003,$000F,$01B0,$0048,$000F,$01A0,$0048,$000E,$00E8,$0048 
;                    dc.w    $01A6,$0020,$0002,$0020,$01C0,$0048,$001F,$01C0,$0038 
end_of_trigger_list     ; original address  00006944

                    ; 3 word/ 6 byte data structure list
                    ; MSB of byte 0 is cleared on game_start
                    ; 21 - entries in list
                    ; Type, X co-ord, y co-ord?
trigger_gas_drips   ; original address L00006722
L00006944           dc.w    $001D
L00006946           dc.w    $0120,$0088,$001D,$0120,$00A8,$001D,$0180,$0248             ;. ..... .......H
L00006956           dc.w    $001D,$01B0,$01C8,$001E,$0190,$0348,$001E,$0180             ;...........H....
L00006966           dc.w    $02A8,$001E,$01F0,$02C8,$001E,$0220,$0648,$001D             ;........... .H..
L00006976           dc.w    $0200,$0628,$001D,$0220,$05E8,$001E,$0140,$04E8              ;...(... .....@..
L00006986           dc.w    $001A,$00A0,$0548,$001A,$00A0,$0568,$001A,$0120              ;.....H.....h...
L00006996           dc.w    $0588,$001A,$01C0,$03E8,$001A,$01C0,$0408,$001A              ;................
L000069A6           dc.w    $01C0,$0428,$001A,$01C0,$0308,$001A,$0160,$01C8              ;...(.........`..
L000069B6           dc.w    $001D,$0240,$0488,$001D,$0120,$04A8


;L00006944           dc.w    $001D,$0120,$0088 
;                    dc.w    $001D,$0120,$00A8 
;                    dc.w    $001D,$0180,$0248 
;                    dc.w    $001D,$01B0,$01C8 
;                    dc.w    $001E,$0190,$0348 
;                    dc.w    $001E,$0180,$02A8 
;                    dc.w    $001E,$01F0,$02C8 
;                    dc.w    $001E,$0220,$0648  
;L00006974           dc.w    $001D,$0200,$0628
;                    dc.w    $001D,$0220,$05E8 
;                    dc.w    $001E,$0140,$04E8 
;                    dc.w    $001A,$00A0,$0548 
;                    dc.w    $001A,$00A0,$0568 
;                    dc.w    $001A,$0120,$0588 
;                    dc.w    $001A,$01C0,$03E8 
;                    dc.w    $001A,$01C0,$0408  
;L000069A4           dc.w    $001A,$01C0,$0428 
;                    dc.w    $001A,$01C0,$0308 
;                    dc.w    $001A,$0160,$01C8 
;                    dc.w    $001D,$0240,$0488 
;                    dc.w    $001D,$0120,$04A8 
end_of_actors       ; original address  000069C2

                    ; ---------- Start level_parameters on game_start ----------
default_level_parameters    ; original address L000069C2
spawn_point_parameters_0    ; original address L000069C2
L000069C2           dc.w    $0000 
L000069C4           dc.w    $0600 
                    dc.w    $0648 
                    dc.w    $0050 
                    dc.w    $0048 
                    dc.w    $0048 
                    dc.w    $0050 

spawn_point_parameters_1   ; original address L000069D0       
L000069D0           dc.w    $0040 
                    dc.w    $0440  
L000069D4           dc.w    $0468 
                    dc.w    $0050 
                    dc.w    $0028 
                    dc.w    $0028 
                    dc.w    $0050 

spawn_point_parameters_2   ; original address L000069DE         
L000069DE           dc.w    $01A0 
                    dc.w    $0260 
                    dc.w    $0288 
L000069E4           dc.w    $0050 
                    dc.w    $0028 
                    dc.w    $0028 
                    dc.w    $0050 


level_parameters
scroll_window_xy_coord      ; original address L000069EC
scroll_window_x_coord       ; original address L000069EC
L000069EC           dc.w    $0000 

scroll_window_y_coord       ; original address L000069EE
L000069EE           dc.w    $00F0 

scroll_window_max_x_coord   ; original address L000069F0
L000069F0           dc.w    $0000 

batman_xy_offset            ; original address L000069F2
batman_x_offset             ; original address L000069F2
L000069F2           dc.w    $0050 

batman_y_offset             ; original address L000069F4
L000069F4           dc.w    $0048 

target_window_y_offset      ; original address L000069F6
L000069F6           dc.w    $0048 

target_window_x_offset      ; original address L000069F8
L000069F8           dc.w    $0050 

                    even


                ; -------------------------- Large Text Plotter --------------------------
                ; Use to display large text on black background at:-
                ; - Start Level
                ; - Game Over
                ; - Time Up
                ; - Level Completed
                ; 
                ; Uses an 8*8 font to display 8*16 font by doubling the font height.
                ;
                ; Data structure:
                ; raster line (y co-ord), byte offset (x co-ord), null terminated string
                ; raster line, byte offset, null terminated string
                ; ...
                ; terminate print loop
                ;
                ;   e.g
                ;   dc.b $50,$10        -- (Y,X co-ords)
                ;   dc.b 'DISPLAY STRING'
                ;   dc.b $00,$ff        -- Terminator
                ;
large_text_plotter      ; original address L000069fa 
.lpt_new_line           ; L000069fa
                        move.b  (a0)+,d0
                        bmi.w   .exit                       ; L00006ace
                        and.w   #$00ff,d0
                        mulu.w  #$002a,d0
                        move.b  (a0)+,d1
                        ext.w   d1
                        add.w   d1,d0
                        movea.l playfield_buffer_2,a1       ; L000036ea,a1
                        lea.l   $00(a1,d0.w),a1
.plot_loop              ; L00006a18
                        moveq   #$00,d0
                        move.b  (a0)+,d0
                        beq.b   .lpt_new_line               ; L000069fa
                        cmp.b   #$20,d0
                        beq.w   .increase_cursor            ; L00006ac6 
                        move.l  #$ffffffcd,d1
                        cmp.b   #$41,d0
                        bcc.b   .calc_src_gfx_ptr_1         ; L00006a52 
                        move.l  #$ffffffd4,d1
                        cmp.b   #$30,d0
                        bcc.b   .calc_src_gfx_ptr_1         ; L00006a52
                        moveq   #$00,d1
                        cmp.b   #$21,d0
                        beq.b   .calc_src_gfx_ptr_2         ; L00006a58
                        moveq   #$01,d1
                        cmp.b   #$28,d0
                        beq.b   .calc_src_gfx_ptr_2         ; L00006a58 
                        moveq   #$02,d1
                        cmp.b   #$29,d0
                        beq.b   .calc_src_gfx_ptr_2         ; L00006a58
                        moveq   #$03,d1
                        bra.b   .calc_src_gfx_ptr_2         ; L00006a58
.calc_src_gfx_ptr_1     ; L00006a52 - adjust char index by value in d1
                        add.b   d0,d1
                        and.w   #$00ff,d1
.calc_src_gfx_ptr_2     ; L00006a58  - get character gfx ptr
                        mulu.w  #$0028,d1
                        lea.l   large_character_gfx,a2      ; L00006ad0,a2
                        lea.l   $00(a2,d1.w),a2
                        ; a1 = gfx src ptr
                        ; a3 = display dest ptr
.draw_character         ; L00006a66
                        moveq   #$07,d7
                        movea.l a1,a3                                         
                        ; print character line
                        ; mask
.draw_loop              ; L00006a6a  
                        move.b  (a2)+,d1
                        ; bpl0
                        and.b   d1,(a3)
                        move.b  (a2)+,d2
                        or.b    d2,(a3)
                        ; bpl1
                        and.b   d1,$1c8c(a3)
                        move.b  (a2)+,d2
                        or.b    d2,$1c8c(a3)
                        ; bpl2
                        and.b   d1,$3918(a3)
                        move.b  (a2)+,d2
                        or.b    d2,$3918(a3)
                        ; bpl3
                        and.b   d1,$55a4(a3)
                        move.b  (a2)+,d2
                        or.b    d2,$55a4(a3)

                    ; repeat character line
                    ; double size of character to 16 rasters high
                        lea.l   $002a(a3),a3
                        lea.l   -$0005(a2),a2
                        move.b  (a2)+,d1
                        ; bpl0
                        and.b   d1,(a3)
                        move.b  (a2)+,d2
                        or.b    d2,(a3)
                        ; bpl1
                        and.b   d1,$1c8c(a3)
                        move.b  (a2)+,d2
                        or.b    d2,$1c8c(a3)
                        ; bpl2
                        and.b   d1,$3918(a3)
                        move.b  (a2)+,d2
                        or.b    d2,$3918(a3)
                        ; bpl3
                        and.b   d1,$55a4(a3)
                        move.b  (a2)+,d2
                        or.b    d2,$55a4(a3)

                        lea.l   $002a(a3),a3
                        dbf.w   d7,.draw_loop           ; L00006a6a
.increase_cursor        ; L00006ac6
                        lea.l   $0001(a1),a1
                        bra.w   .plot_loop              ;L00006a18
.exit                   ; L00006ace
                        rts  


large_character_gfx      ; original address L00006ad0
                    include "./gfx/font8x8x4.s"






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


                    ;-------------------------------------------------------------------------------------------
                    ; End of My Debug Routines
                    ;-------------------------------------------------------------------------------------------




                    ;-------------------------------------------------------------------------------------------
                    ;
                    ;   TEST BUILD - Additional Code & Data
                    ;
                    ;-------------------------------------------------------------------------------------------
                    ; If running a test build then we need the following resources:-
                    ;
                    ;   - Screen Memory Buffers
                    ;       - Offscreen Scroll Buffer memory (29232 bytes)
                    ;       - Double Buffered screen memory (58464 bytes)
                    ;
                    ;   - Music Player Code & Data
                    ;       - chem1.s
                    ;
                    ;   - Panel Code & GFX (Bottom of screen lives/score/energy display)
                    ;       - panel.s
                    ;
                    ;   - Level 1 - Background Tile Map Data & GFX
                    ;       - mapgr.s
                    ;
                    ;   - Level 1 - Sprites (Batman, Bad guys, projectiles, Drips, Gasleak)
                    ;       - batspr1.s
                    ;       - buffer for mirrored sprites (calculated on level initialisation)
                    ;
                    ;   - Sprite List Buffer - Dynamically created list of Sprite Object
                    ;       - sprite_list
                    ;

            ; if test build, allocate backbuffers in chip memory
                                IFD TEST_BUILD_LEVEL
chipmem_buffer                  dcb.b   CODE1_DISPLAY_BUFFER_BYTESIZE,$01
                                dcb.B   40*10,0     ; padding fixed scroll corruption
                                even
chipmem_doublebuffer            dcb.b   CODE1_DOUBLE_BUFFER_BYTESIZE,$55
                                dcb.b   40*10,0     ; padding fixed scroll corruption
                                ENDC

            ; padding - see if it fixes map data corruption
            dcb.B   10240,0

            ; If Test Build - Include the Level Music and SFX
            IFD TEST_BUILD_LEVEL
                incdir      "../church/"
                include     "church.s"
            ENDC

            ; padding - see if it fixes map data corruption
            dcb.B   10240,0

            ; If Test Build - Include the Bottom Panel (Score, Energy, Lives, Timer etc)
            IFD TEST_BUILD_LEVEL
                incdir      "../panel/"
                include     "panel.s"                                           ; original load address $2FFC
            ENDC

            ; padding - see if it fixes map data corruption
            dcb.B   10240,0

            ; If Test Build - Include the level map data and graphics
            IFD TEST_BUILD_LEVEL
                incdir      "../mapgr2/"
                include     "mapgr2.s"
            ENDC

            ; padding - see if it fixes map data corruption
            dcb.B   10240,0

            ; If Test Build - Include Batman Sprites File 1n( also allocate memory for mirrored sprites)
            IFD TEST_BUILD_LEVEL
                incdir      "../batspr1/"
                include     "batspr1.s"
                dcb.b       110000,0
            ENDC

            ; padding - see if it fixes map data corruption
            dcb.B   10240,0

            IFD TEST_BUILD_LEVEL
                even
sprite_list     dcb.b       305*8,0
            ENDC


