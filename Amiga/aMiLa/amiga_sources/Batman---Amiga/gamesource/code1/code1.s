

                ;
                ;
                ; TERMINOLOGY
                ; -----------
                ; I've used the following teminology/metaphors etc to reverse engineer and label code and data.
                ; Some of these terms maybe correct, close to correct or just plain incorrect.
                ;
                ;   Term                        Description
                ;   -----------------           --------------------------------------------------------------------
                ;   Double Buffered Display     Twos display screens of memory 
                ;                               2 buffers, 42 bytes wide, 174 rasters high, 4 bitplanes deep (16 colours)
                ;                               The display/game runs at 25 frames per second.
                ;                               The buffers are swapped using the copper so that the next display
                ;                               can be calculated while the last display remains on screen.
                ;                               They are then swapped and the next frame is prepped, and so on.
                ;
                ;   Display Buffer              I use this term to mean the double buffered display or the
                ;                               Currently displayed fram of theDouble Buffer.
                ;
                ;   Back Buffer                 I use this term to mean the area of the double buffered display 
                ;                               being prepped for display.
                ;
                ;   Off Screen Buffer           Buffer used to perform background level scrolling. It is separate
                ;                               to the double buffered display.  Graphics (GFX) are copied from this
                ;                               'Off Screen Buffer' into the 'Back Buffer' of the 'Double Buffered'
                ;                               display.
                ;                               This buffer operated like a circular buffer in the Y axis, so,
                ;                               as the screen scolls vertically downwards then,
                ;                               the top of the display starts further down in the buffer and new data 
                ;                               is written into the top of the buffer to represent new graphics scrolling 
                ;                               into the display.
                ;                               The opposite occurs when the view scrolls upwards.
                ;                               I think of it like an old CRT display when the picture starts to roll.
                ;
                ;                               Buffer (no vertical scroll)                 Buffer (some vertical scroll)
                ;                               +---------------+ <-- Top of Display        +---------------+    
                ;                               |               |                           |               | 
                ;                               |               |                           |               |  <-- Bottom of Display
                ;                               |               |                           |---------------|  <-- Top of Display
                ;                               |               |                           |               |
                ;                               |               |                           |               |
                ;                               +---------------+ <-- Bottom of Display     +---------------+
                ;
                ;                               The above buffer is copied into the 'Back Buffer' to correct it for
                ;                               Display and adding sprites etc before being displayed to the player.
                ;
                ;
                ;   Sprites                     Game Objects overlayed on top of the background GFX, not hardware sprites
                ;                               Typically Blitter Objects (Bobs) - I haven't seen any use of hardware sprites
                ;                               in the code as yet. The Copper doesn't manage any, so a good indication
                ;                               that hardware sprites aren't being used anywhere in this code.
                ;
                ;
                ;  Player Control States        The main game loop contains some self-modifying JSR code whose destination
                ;                               address is modified depending upon whether the player is:-
                ;                                   - Walking on the Ground/Plaform
                ;                                   - Climbing up/down the stairs
                ;                                   - Falling from a platform/stairs
                ;                                   - Swinging from the Batrope.
                ;                               Depending on the current state, then the JSR is modified to point to the
                ;                               required handler.  The handler commands called by the JSR also manage the
                ;                               transition to other states. This means that there are many placed in the
                ;                               code where this JSR destination is modified (and that's the reason).
                ;
                ; NOTES:
                ; ------
                ; 1) If 'JAMMMM' cheat mode active then 'F10' skip to next level (Enter text 'JAMMMM' on title screen)
                ;
                ; 
                ;
                ;
                ; Level 1 - Memory Map
                ; ------------------------------
                ; The following files are loaded and decrunched into the following locations
                ; by the game loader
                ;
                ;
                ; Filename/Area     Start   End         Additional Info
                ;---------------------------------------------------------------------------------------------
                ; BATMAN            $800                - Game Loader (always resident across loads)
                ; CODE1             $2FFC   $6FFE       - $3000 = entry point for level code. (16Kb)
                ;
                ; MAPGR             $7FFC               - Game Tile map data and background GFX blocks
                ;                                       - $8002 - tile map width
                ;                                       - $807c - start of tilemap data
                ;                                       - $a07c - start of gfx block data
                ;       
                ;                   $10000              - Display Object List
                ;                                           - 305 - game display objects
                ;                                                   initialised from data in BATSPR1.IFF file.
                ;
                ; BATSPR1           $10FFC              - Display Objects & Graphics
                ;                                       - $11002 = 16 bit - number of display object
                ;                                       - $11004 = start of display object data
                ;                                                   - 8 byte structure per object
                ;                                                       - 1 word (unused $800f)
                ;                                                       - 1 byte pixel width
                ;                                                       - 1 byte pixel height
                ;                                                       - 4 bytes gfx start offset
                ;                                                           gfx base starts at end of list of objects
                ;                                                           (No of objects * 8) + $11004 = $1198C
                ;                                       - Total size with mirrored sprites $2e966
                ;                                       - $3f962 - end of sprite data (including precalced mirrored sprites)
                ;
                ; CHEM              $47FE4              - Level Music Player, Music & SFX
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

           




; Code1 - Constants
;-------------------
                IFND TEST_BUILD_LEVEL
STACK_ADDRESS                   EQU $0005a36c
                ENDC
                IFD TEST_BUILD_LEVEL
STACK_ADDRESS                   EQU start                                                       ; set stack to start of program.
                ENDC


CODE1_INITIAL_TIMER_BCD         EQU $0800                                                       ; BCD Vaue for 08:00 minutes
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



; Code1 - debug_print_word_value constants
FONT_8x8_HEIGHT     EQU         $8
ASCII_SPACE         EQU         $20

KEY_F1              EQU         $0081
KEY_F2              EQU         $0082
KEY_F10             EQU         $008a
KEY_ESC             EQU         $001b



; offscreen, double buffer display sizes
DISPLAY_MAX_Y           EQU         $57                                         ; max display Y value (87) represents line 174 of the display (87*2)
DISPLAY_BYTEWIDTH       EQU         $2a                                         ; 42 bytes wide
DISPLAY_2RASTERS        EQU         DISPLAY_BYTEWIDTH*2                         ; 84 bytes for two raster lines 
DISPLAY_BUFFER_BYTES    EQU         2*DISPLAY_MAX_Y*DISPLAY_BYTEWIDTH           ; size of display buffer in bytes
DISPLAY_BUFFER_BPL0_OFFSET  EQU     $0
DISPLAY_BUFFER_BPL1_OFFSET  EQU     DISPLAY_BUFFER_BYTES
DISPLAY_BUFFER_BPL2_OFFSET  EQU     DISPLAY_BUFFER_BYTES*2
DISPLAY_BUFFER_BPL3_OFFSET  EQU     DISPLAY_BUFFER_BYTES*3



                section code1_iff,code_c
                
             
            ; if not test then org $2FFC   
            IFND TEST_BUILD_LEVEL
                org     $2ffc                                           ; original load address $2FFC
            ENDC




                ;--------------------- includes and constants ---------------------------
                INCDIR      "include"
                INCLUDE     "hw.i"
                opt         o-



            ; if test then jump to game start
            IFD TEST_BUILD_LEVEL
start               ; added for testing (doesn't run yet!!!)
                    jmp game_start     
            ENDC


original_start:                                             ; original address $2FFC
                    dc.l    $00003000                       ; long word of start address




                    ; -------------------------- game start /  initialise system ---------------------------------
                    ; This is the Level 1 code entry point on loading.
                    ;
                    ; NOTES:
                    ; I added the 'supervisor mode' code as this was previously handled by the loader, and it is
                    ; required as some code performs 'move.w <ea>,SR' (priviledged instruction on 68000)
                    ;   NB: the code also performs 'move.w SR,<ea>' which is privileged on some processors.
                    ; 
                    ; I added the stack address setting code, which moves the stack to the start of the program,
                    ; hopefully out of harms way for rebuilding and executing.
                    ;
                    ;
game_start          ; original address $00003000
initialise_system   ; original address $00003000

                    ;JSR _DEBUG_COLOURS
                    
                    ; kill the system & initialise h/w
                    moveq   #$00,d0
                    move.w  #$1fff,$00dff09a                ; DMACON - Disable DMA (All DMA Channels)
                    move.w  #$1fff,$00dff096                ; INTENA - Disable Interrupts (apart from EXTER, INTEN) level 6 still active
                    move.w  #$0200,$00dff100                ; BPLCON0 - 0 bitplane display
                    move.l  d0,$00dff102                    ; BPLCON1 - Bitplane Scroll
                    move.w  #$4000,$00dff024                ; DSKLEN - Disable Disk DMA (as per h/w ref)
                    move.l  d0,$00dff040                    ; BLTCON0 - Clear minterms an DMA channels
                    move.w  #$0041,$00dff058                ; BLTSIZE - 1 word blit 
    
                    move.w  #$8340,$00dff096                ; DMACON - Enable Bitplane, Blitter, Master
                    move.w  #$7fff,$00dff09e                ; ADKCON - Clear Disk & Audio modulaton bits
            
                    ; clear all sprite postions
                    moveq   #$07,d7                         ; counter = 7 + 1
                    lea.l   $00dff140,a0                    ; SPR0POS - first sprite position
.sprite_loop
                    move.w  d0,(a0)                         ; clear sprite pos
                    addq.w #$08,a0                          ; next sprite pos address
                    dbf.w   d7,.sprite_loop                 ; L0000304e - loop for 8 sprites.

                    ; clear all audio volume
                    moveq   #$03,d7                         ; counter = 3 + 1
                    lea.l   $00dff0a8,a0                    ; AUD0VOL
.audio_loop
                    move.w  d0,(a0)                         ; clear volume level
                    lea.l   $0010(a0),a0                    ; next channel audio volume
                    dbf.w   d7,.audio_loop                  ; L0000305e - loop for 4 channels

                    ; all colour regs to black
                    lea.l   $00dff180,a0                    ; COLOR00
                    moveq   #$1f,d7                         ; counter 31 + 1
.color_loop
                    move.w  d0,(a0)+                        ; clear colour and move to next
                    dbf.w   d7,.color_loop                  ; L00003070 - loop for 32 colour registers

                    ; reset CIAA
                    move.b  #$7f,$00bfed01                  ; CIAA-ICR - clear interrupt enable bits
                    move.b  d0,$00bfee01                    ; CIAA-CRA - timer a control
                    move.b  d0,$00bfef01                    ; CIAA-CRB - timer b control
                    move.b  d0,$00bfe001                    ; CIAA-PRA - LED, OVL
                    move.b  #$03,$00bfe201                  ; CIAA-DDRA - LED, OVL output, remaining as inputs (disk/joybuttons)
                    move.b  d0,$00bfe101                    ; CIAA-PRB - Parallel port data
                    move.b  #$ff,$00bfe301                  ; CIAA-DDRB - Parallel port dir = output all bits

                    ; reset CIAB
                    move.b  #$7f,$00bfdd00                  ; CIAB-ICR - clear interrupt enable bits 
                    move.b  d0,$00bfde00                    ; CIAB-CRA - timer a control
                    move.b  d0,$00bfdf00                    ; CIAB-CRB - timer b control
                    move.b  #$c0,$00bfd000                  ; CIAB-PRA - PORT A (Keybboard serial data) (deselect DTR,RTS)
                    move.b  #$c0,$00bfd200                  ; CIAB-DDRA - PORT A dir = DTR,RTS pins/lines = output
                    move.b  #$ff,$00bfd100                  ; CIAB-PRB - PORT B (Disk ctrl) deselect all (active low)
                    move.b  #$ff,$00bfd300                  ; CIAB-DDRB - PORT B dir = all pins/lines = output



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


                    ; set stack address
                    lea.l   STACK_ADDRESS,a7                ; External Address - Stack = $0005a36c

                    ; set interrupt handlers (only level 1,2 & 3)
                    ; odd as additional handlers exist
                    moveq   #$02,d7                         ; count 2 + 1 
                    lea.l   interrupt_handlers_table,a0     ; L000031b0,a0
                    lea.l   $00000064,a1                    ; Level 1 Autovector Address
.int_loop
                    move.l  (a0)+,(a1)+                     ; Set autovectors for level 1,2 & 3
                    dbf.w   d7,.int_loop                    ; L000030ee


                    ; Initialise CIA Timers & 
                    move.w  #$ff00,$00dff034                ; POTGO
                    move.w  d0,$00dff036                    ; JOYTEST = $00 (reset counters)
                    or.b    #$ff,$00bfd100                  ; CIAB - PRB - deselect all drive bits
                    and.b   #$87,$00bfd100                  ; CIAB - PRB - latch motor off, deselect all drives
                    and.b   #$87,$00bfd100                  ; CIAB - PRB - latch motor off, deselect all drives
                    or.b    #$ff,$00bfd100                  ; CIAB - PRB - deselect all drive bits
                    move.b  #$f0,$00bfe601                  ; CIAA - TBLO - Timer B Low Byte
                    move.b  #$37,$00bfeb01                  ; CIAA - UNUSED - according to H/W Ref (BUG? )
                    move.b  #$11,$00bfef01                  ; CIAA - CRB - Force Load & Start Timer B

                    ; CIAA - Timer B Low = $f0      ; 0.33 second

                    move.b  #$91,$00bfd600                  ; CIAB - TBLO - Timer B Low Byte
                    move.b  d0,$00bfdb00                    ; CIAB - TBLO - Timer B Low Byte = $00
                    move.b  d0,$00bfdf00                    ; CIAB - CRB = $00

                    ; CIAB - Timer B Low = $00

                    move.w  #$7fff,$00dff09c                ; INTREQ - clear all interrupt request bits
                    tst.b   $00bfed01                       ; CIAA - ICR - Clear by reading (interrupt control)
                    move.b  #$8a,$00bfed01                  ; CIAA - ICR - Enable SP & Timer A & B Interrupts
                    tst.b   $00bfdd00                       ; CIAB - ICR - Clear by reading (interrupt control)
                    move.b  #$93,$00bfdd00                  ; CIAB - ICR - Enable FLG & Timer A & B Interrupts
                    move.w  #$e078,$00dff09a                ; INTENA - Enable - EXTER (disk sync), BLIT, VERTB, COPER, PORTS (keyboard & Timers)                
                                                            ;        - Level 2,3,6

                    ; start initialising the game           ; original address $0000317a
                    jsr     PANEL_INIT_LIVES                ; Panel - Initialise Player Lives - $0007c838
                    jsr     PANEL_INIT_SCORE                ; Panel - Initialise Player Score to 0 - $0007c81c
                    jsr     PANEL_INIT_ENERGY               ; Panel - Initialise Player Energy - $0007c854
                    ; set initial level timer value
                    move.w  #CODE1_INITIAL_TIMER_BCD,d0
                    jsr     PANEL_INIT_TIMER
                    
                    bsr.w   clear_display_memory
                    lea.l   copper_list,a0                  ; L000031c8,a0
                    bsr.w   reset_display                   ; reset display (320x218) 4 bitplanes - L0000368a
                    bsr.w   double_buffer_playfield         ; L000036fa

                    bra.w   initialise_game                      ; L00003ae4




                    ; maybe intended as a second copper list
L000031ac           dc.w $ffff                      ; not referenced by this code
L000031ae           dc.w $fffe                      ; not referenced by this code


interrupt_handlers_table
L000031b0           dc.l level1_interrupt_handler   ; $000032c0 - disabled
L000031b4           dc.l level2_interrupt_handler   ; $000032f8 - enabled
L000031b8           dc.l level3_interrupt_handler   ; $0000331e - enabled
L000031bc           dc.l level4_interrupt_handler   ; $0000335a - disabled - unused by game init above
L000031c0           dc.l level5_interrupt_handler   ; $00003370 - disabled - unused by game init above
L000031c4           dc.l level6_interrupt_handler   ; $00003396 - enabled  - unused by game init above




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
copper_list                                         ; original address $000031c8
                    ; ---- playfield display (scroll area) ---
                    dc.w $2c01,$fffe                ; $da - $2c = $ae (174 + 32 = 206) - aaauming 32 pixels for vertical scroll off-screen
                    dc.w BPL2MOD,$0002              ; BPL2MOD (extra 16 bits bitplane width)
                    dc.w BPL1MOD,$0002              ; BPL1MOD (extra 16 bits bitplane width)
copper_playfield_planes                             ; original address $000031d4
                    dc.w BPL1PTL                    ; $00e2                     
                    dc.w $7680                      
                    dc.w BPL1PTH                    ; $00e0 ($67680) - These ptrs are nonsense (set by swap buffers)                 
                    dc.w $0006
                    dc.w BPL2PTL                    ; $00e6               
                    dc.w $98e0                      
                    dc.w BPL2PTH                    ; $00e4 ($698e0) - These ptrs are nonsense (set by swap buffers)                     
                    dc.w $0006
                    dc.w BPL3PTL                    ; $00ea               
                    dc.w $bb40                      
                    dc.w BPL3PTH                    ; $00e8 ($6bb40) - These ptrs are nonsense (set by swap buffers)                        
                    dc.w $0006
                    dc.w BPL4PTL                    ; $00ee               
                    dc.w $dda0                      
                    dc.w BPL4PTH                    ; $00ec ($6dda0) - These ptrs are nonsense (set by swap buffers)                  
                    dc.w $0006
                    dc.w COLOR01,$0446
                    dc.w COLOR02,$088a                      
                    dc.w COLOR03,$0cce                      
                    dc.w COLOR04,$0048             
                    dc.w COLOR05,$028c
                    dc.w COLOR06,$0c64
                    dc.w COLOR07,$0a22
                    dc.w COLOR08,$06a6
                    dc.w COLOR09,$0c4a
                    dc.w COLOR10,$0ec6
                    dc.w COLOR11,$0e88
                    dc.w COLOR12,$0600
                    dc.w COLOR13,$0262
                    dc.w COLOR14,$0668
                    dc.w COLOR15,$06ae

                    ; ---- panel display (bottom score/energy etc) ----
                    dc.w $da01,$fffe
                    dc.w BPL2MOD,$0000              ; Modulo = 0
                    dc.w BPL1MOD,$0000              ; Modulo = 0
copper_panel_planes
                    dc.w BPL1PTL                    ; $00e2                     
                    dc.w $c89a                      ; Bitplane 1 - $7C89A = $780 (1920) bytes (48 Rasters @ 40 bytes per line (320 pixels))
                    dc.w BPL1PTH                    ; $00e0                      
                    dc.w $0007
                    dc.w BPL2PTL                    ; $00e6              
                    dc.w $d01a                      ; Bitplane 2 = $7D10A = $780 (1920) bytes (48 Rasters @ 40 bytes per line (320 pixels))
                    dc.w BPL2PTH                    ; $00e4                   
                    dc.w $0007
                    dc.w BPL3PTL                    ; $00ea             
                    dc.w $d79a                      ; Bitplane 3 = $7D79A = $780 (1920) bytes (48 Rasters @ 40 bytes per line (320 pixels))
                    dc.w BPL3PTH                    ; $00e8                  
                    dc.w $0007
                    dc.w BPL4PTL                    ; $00ee             
                    dc.w $df1a                      ; Bitplane 4 = $7DF1A = $780 (1920) bytes (48 Rasters @ 40 bytes per line (320 pixels))
                    dc.w BPL4PTH                    ; $00ec                     
                    dc.w $0007
copper_panel_colors                                 ; original address $0000325c
                    dc.w COLOR00,$0000
                    dc.w COLOR01,$0000
                    dc.w COLOR02,$0000
                    dc.w COLOR03,$0000
                    dc.w COLOR04,$0000
                    dc.w COLOR05,$0000
                    dc.w COLOR06,$0000
                    dc.w COLOR07,$0000
                    dc.w COLOR08,$0000
                    dc.w COLOR09,$0000
                    dc.w COLOR10,$0000
                    dc.w COLOR11,$0000
                    dc.w COLOR12,$0000
                    dc.w COLOR13,$0000
                    dc.w COLOR14,$0000
                    dc.w COLOR15,$0000
                    dc.w $ffff,$fffe


                    ;------------------- 16 colours for the Panel ---------------------
panel_colours                                       ; original address $000032a0
L000032a0           dc.w $0000,$0060,$0fff,$0008                      
                    dc.w $0a22,$0444,$0862,$0666               
                    dc.w $0888,$0aaa,$0a40,$0c60
                    dc.w $0e80,$0ea0,$0ec0,$0eee                      




                    ; -------------------- level 1 - interrupt handler --------------------
                    ; TBE, DSKBLK, SOFT - Interrupts, just clear the bits from INTREQ
                    ;  NB: not enabled by init_system above
                    ;
level1_interrupt_handler                            ; original addr: $000032c0
                    move.l  d0,-(a7)
                    move.w  $00dff01e,d0            ; INTREQR
                    btst.l  #$0002,d0               ; test SOFT 
                    bne.b   lvl1_clear_SOFT         ; .... yes - L000032ec
                    btst.l  #$0001,d0               ; test DSKBLK
                    bne.b   lvl1_clear_DSKBLK       ; .... yes - L000032e0
                    move.w  #$0001,$00dff09c        ; clear TBE (bit 0) - Transmit buffer empty
                    move.l  (a7)+,d0
                    rte

lvl1_clear_DSKBLK                                   ; original addr: $000032e0
                    move.w  #$0002,$00dff09c        ; Clear INTREQ - DSKBLK (bit 1)
                    move.l  (a7)+,d0
                    rte

lvl1_clear_SOFT                                     ; original addr: $000032ec
                    move.w  #$0004,$00dff09c        ; Clear INTREQ - SOFT (bit 2)
                    move.l  (a7)+,d0
                    rte




                    ; -------------------- level 2 - interrupt handler --------------------
                    ; CIA Ports & Timers
                    ; - Enabled by 'init_system' above
                    ;  
level2_interrupt_handler                            ; original address $000032f8
                    move.l  d0,-(a7)
                    move.b  $00bfed01,d0            ; CIAA - ICR - Clear by reading
                    bpl.b   lvl2_not_CIAA           ;   - No CIAA - Interrupt - $00003312
                    bsr.w   lvl2_CIAA_Interrupt     ;   - yes - $000033d4
                    move.w  #$0008,$00dff09c        ; Clear PORTS (bit 3)
                    move.l  (a7)+,d0
                    rte

lvl2_not_CIAA                                       ; original address $00003312
                    move.w #$0008,$00dff09c         ; Clear PORTS (bit 3)
                    move.l (a7)+,d0
                    rte




                    ; -------------------- level 3 - interrupt handler --------------------
                    ; COPER, VERTB, BLIT - interrupts
                    ; - Enabled by 'init_system' above
                    ;
level3_interrupt_handler                                    ; original addr: $0000331e
                    move.l  d0,-(a7) 
                    move.w  $00dff01e,d0                    ; d0 = INTREQR
                    btst.l  #$0004,d0                       ; Copper Interrupt?
                    bne.b   lvl3_coper                      ; .... yes - L0000334e
                    btst.l  #$0005,d0                       ; Vertical Blank
                    bne.b   lvl3_vertb                      ; .... yes - L0000333e
                    move.w  #$0040,$00dff09c                ; clear BLIT - INTREQ
                    move.l  (a7)+,d0
                    rte 



                    ; ------------------- Level 3 - VERTB - Handler --------------------
                    ; update music player.
                    ; level 3 vertical blank interrupt handler
lvl3_vertb                                                  ; original addr: $0000333e
                    bsr.w   lvl_3_update_sound_player       ; L00003526
                    move.w  #$0020,$00dff09c                ; clear VERTB - INTREQ
                    move.l  (a7)+,d0
                    rte 


                    ; ------------------- Level 3 - COPER - Handler -------------------
                    ; copper interrupt - do nothing
lvl3_coper                                                  ; original addr: $0000334e
                    move.w  #$0010,$00dff09c                ; clear COPER - INTREQ
                    move.l  (a7)+,d0
                    rte 





                    ; ------------------------ level 4 - interrupt handler ------------------------- 
                    ; not installed to autovector by the game init
                    ; unused handler
                    ; if used would clear raised audio interrupts.
level4_interrupt_handler                                    ; original address $0000335a
                    move.l  d0,-(a7)
                    move.w  $00dff01e,d0                    ; d0 = INTREQR
                    and.w   #$0780,d0                       ; Preserve Raised Audio Interrupts (level 4 for audio 0 - 3)
                    move.w  d0,$00dff09a                    ; clear raised audio interrupts
                    move.l  (a7)+,d0
                    rte





                    ; ----------------------- level 5 - interrupt handler -------------------------- 
                    ; not installed to autovector by the game init
                    ; unused handler
                    ; if usewd, then it would clear the disk sync interrupt & serial port interrupt
                    ;
level5_interrupt_handler                                    ; original address $00003370
                    move.l  d0,-(a7)
                    move.w  $00dff01e,d0                    ; d0 = INTREQR
                    btst.l  #$000c,d0                       ; Test DSKSYN bit?
                    bne.b   lvl5_clear_dsksyn               ; .... yes - L0000338a                   
                    move.w  #$0800,$00dff09c                ;  Clear RBF - Serial port buffer full (keyboard)
                    move.l  (a7)+,d0
                    rte 

lvl5_clear_dsksyn                                           ; original address $0000338a
                    move.w  #$1000,$00dff09c                ; Clear DSKSYN bit
                    move.l  (a7)+,d0
                    rte 





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
level6_interrupt_handler                            ; original addres $00003396
                    move.l  d0,-(a7)
                    move.w  $00dff01e,d0            ; d0 = INTREQR
                    btst.l  #$000e,d0               ; INTEN - Master Interrupt - set only (bug?)
                    bne.b   lvl6_clear_INTEN
                    move.b  $00bfdd00,d0            ; CIAB - ICR - read also clears
                    bpl.b   lvl6_clear_EXTER        ; MSB = 0, no CIAB interrupt
                    bsr.w   lvl6_timerb_interrupt
                    move.w  #$2000,$00dff09c        ; INTREQ - Clear EXTER - Level 6 CIAB - Disk Index
                    move.l  (a7)+,d0
                    rte 

lvl6_clear_EXTER                                ; original address $000033bc
                    move.w  #$2000,$00dff09c    ; INTREQ - Clear EXTER - Level 6 CIAB - Disk Index
                    move.l  (a7)+,d0
                    rte  

lvl6_clear_INTEN                                ; original address $000033c8
                    move.w  #$4000,$00dff09c    ; INTREQ - Clear INTEN (never set on read) - never called
                    move.l  (a7)+,d0
                    rte




                    ; ------------------ level 2 - CIAA - Interrupt Handler ------------------
                    ; Handles:
                    ;   CIAA - Timer B
                    ;   Reading the keybaord (adding ascii codes to the keyboard queue)
                    ;
                    ; IN:
                    ;  - D0 - CIAA - ICR
                    ;
lvl2_CIAA_Interrupt                                         ; original addr: $000033d4
lvl2_chk_TB                                                 ; original addr: $000033d4
                    lsr.b   #$02,d0                         ; chk for Timer B
                    bcc.b   lvl2_chk_SP                     ;   no  - not Timer B - $000033dc
                    bsr.w   lvl2_CIAB_TimerB_Handler        ;   yes - is Timer B Interrupt - $00003544
lvl2_chk_SP                                                 ; original addr: $000033dc
                    lsr.b   #$02,d0                         ; chk for SP 
                    bcc.b   lvl2_exit_handler               ;   no  - not SP - $0000344e

lvl2_SP             ; keyboard interrupt                    ; original address L000033e0
                    movem.l d1-d2/a0,-(a7)                  ;   yes - is SP
                    move.b  $00bfec01,d1                    ; CIAA - SDR - Serial Data Register (Keyboard)
                    not.b   d1                              ; d1 = inverted keycode
                    lsr.b   #$01,d1                         ; rotate out key down/up bit (1 = key up)
                    bcc.b   .not_key_up                     ; Not Key up? - L00003406

.is_key_up          ; key released (d1 = keycode)           ; original address L000033f0
                    ; get ascii code and clear key pressed in bitmap table
                    lea.l   keyboard_bitmap,a0              ; L000034f4,a0
                    ext.w   d1                              ; extend keycode to 16 bits from byte
                    move.b  acsii_lookup_table(pc,d1.w),d1  ; d1 = translated keycode ($00003450 = lookup table)
                    move.w  d1,d2
                    lsr.w   #$03,d2                         ; divide ascii code by 8 (d2 = get bitmap byte offset)
                    bclr.b  d1,$00(a0,d2.W)                 ; clear key pressed bit in the bitmap table 
                    bra.b   .set_ciaa_cra                    ; L00003442

.not_key_up         ; key pressed (d1 = keycode)            ; original address $00003406
                    lea.l   keyboard_bitmap,a0              ; L000034f4,a0
                    ext.w   d1
                    move.b  acsii_lookup_table(pc,d1.w),d1  ; d1 = translated keycode ($00003450 = lookup table)        
                    move.w  d1,d2
                    lsr.w   #$03,d2                         ; divide ascii code by 8 (d2 = get bitmap byte offset)
                    bset.b  d1,$00(a0,d2.W)                 ; set key pressed bit in the bitmap table
                    tst.b   d1                              ; test for NUL ascii code
                    beq.b   .set_ciaa_cra                    ; L00003442 ; is NUL key

                    ; enqueue the pressed key
.enqueue_key                                                ; original address L0000341e
                    lea.l   keyboard_buffer,a0              ; L000034d0,a0 ; keyboard queue.
                    move.w  keyboard_queue_head,d2          ; L000034f0,d2                    ; 
                    move.b  d1,$00(a0,d2.W)                 ; store ascii code in the queue
                    addq.w  #$01,d2                         ; increment queue head
                    and.w   #$001f,d2                       ; clamp head to end of buffer
                    cmp.w   keyboard_queue_tail,d2          ; is the queue full? L000034f2,d2
                    beq.b   .set_ciaa_cra                   ; yes, do not increment the queue head
                    move.w  d2,keyboard_queue_head          ; no, increment the queue head L000034f0

.set_ciaa_cra                                           ; original address $00003442
                    move.b  #$40,$00bfee01              ; CIAA - CRA - SPMODE = CNT, Stop Timer A
                    movem.l (a7)+,d1-d2/a0
lvl2_exit_handler                                       ; original address L0000344e
                    rts 


                    ; raw key code translation table (raw keycode index into the table, ascii lookup)
                    ; keycode in range $00 - $7f
acsii_lookup_table                          ; original address $00003450
                                            ; Offset |  Value
                    dc.b    $27             ; $00       ' - single quote
                    dc.b    $31             ; $01       '1'
                    dc.b    $32             ; $02       '2'
                    dc.b    $33             ; $03       '3'
                    dc.b    $34             ; $04       '4'
                    dc.b    $35             ; $05       '5'
                    dc.b    $36             ; $06       '6'
                    dc.b    $37             ; $07       '7'      
                    dc.b    $38             ; $08       '8'
                    dc.b    $39             ; $09       '9'
                    dc.b    $30             ; $0a       '0'
                    dc.b    $2d             ; $0b       '-'
                    dc.b    $3d             ; $0c       '='
                    dc.b    $5c             ; $0d       '\'   
                    dc.b    $00             ; $0e       NUL
                    dc.b    $30             ; $0f       0
                    dc.b    $51             ; $10       'Q'
                    dc.b    $57             ; $11       'W'
                    dc.b    $45             ; $12       'E'
                    dc.b    $52             ; $13       'R'   
                    dc.b    $54             ; $14       'T'
                    dc.b    $59             ; $15       'Y'             
                    dc.b    $55             ; $16       'U'
                    dc.b    $49             ; $17       'I'             
                    dc.b    $4f             ; $18       'O'
                    dc.b    $50             ; $19       'P'
                    dc.b    $5b             ; $1a       '['      
                    dc.b    $5d             ; $1b       ']'               
                    dc.b    $00             ; $1c       NUL
                    dc.b    $31             ; $1d       '1'
                    dc.b    $32             ; $1e       '2'
                    dc.b    $33             ; $1f       '3'
                    dc.b    $41             ; $20       'A'
                    dc.b    $53             ; $21       'S'    
                    dc.b    $44             ; $22       'D'     
                    dc.b    $46             ; $23       'F'                
                    dc.b    $47             ; $24       'G'
                    dc.b    $48             ; $25       'H'                
                    dc.b    $4a             ; $26       'J'
                    dc.b    $4b             ; $27       'K'                
                    dc.b    $4c             ; $28       'L'
                    dc.b    $3b             ; $29       ';'                
                    dc.b    $23             ; $2a       '#'
                    dc.b    $00             ; $2b       NUL                
                    dc.b    $00             ; $2c       NUL
                    dc.b    $34             ; $2d       '4'
                    dc.b    $35             ; $2e       '5'
                    dc.b    $36             ; $2f       '6'
                    dc.b    $00             ; $30       NUL
                    dc.b    $5a             ; $31       'Z'    
                    dc.b    $58             ; $32       'X'
                    dc.b    $43             ; $33       'C'              
                    dc.b    $56             ; $34       'V'
                    dc.b    $42             ; $35       'B'              
                    dc.b    $4e             ; $36       'N'
                    dc.b    $4d             ; $37       'M'                
                    dc.b    $2c             ; $38       ','
                    dc.b    $2e             ; $39       '.'
                    dc.b    $2f             ; $3a       '/'
                    dc.b    $00             ; $3b       NUL        
                    dc.b    $00             ; $3c       NUL
                    dc.b    $37             ; $3d       '7'
                    dc.b    $38             ; $3e       '8'
                    dc.b    $39             ; $3f       '9'
                    dc.b    $20             ; $40       ' ' (space)
                    dc.b    $08             ; $41       BS  (back space)     
                    dc.b    $09             ; $42       TAB (horizontal tab)
                    dc.b    $0d             ; $43       CR  (carriage return)
                    dc.b    $0d             ; $44       CR  (carriage return)
                    dc.b    $1b             ; $45       ESC (escape)   
                    dc.b    $7f             ; $46       DEL
                    dc.b    $00             ; $47                       
                    dc.b    $00             ; $48
                    dc.b    $00             ; $49
                    dc.b    $2d             ; $4a       '-'
                    dc.b    $00             ; $4b
                    dc.b    $8c             ; $4c
                    dc.b    $8d             ; $4d
                    dc.b    $8e             ; $4e
                    dc.b    $8f             ; $4f             
                    dc.b    $81             ; $50       F1
                    dc.b    $82             ; $51       F2       
                    dc.b    $83             ; $52       F3
                    dc.b    $84             ; $53       F4       
                    dc.b    $85             ; $54       F5
                    dc.b    $86             ; $55       F6    
                    dc.b    $87             ; $56       F7
                    dc.b    $88             ; $57       F8         
                    dc.b    $89             ; $58       F9
                    dc.b    $8a             ; $59       F10           
                    dc.b    $28             ; $5a       '('
                    dc.b    $29             ; $5b       ')'
                    dc.b    $2f             ; $5c       '/'
                    dc.b    $2a             ; $5d       '*'
                    dc.b    $2b             ; $5e       '+'
                    dc.b    $8b             ; $5f
                    dc.b    $00             ; $60       NUL
                    dc.b    $00             ; $61       NUL             
                    dc.b    $00             ; $62       NUL
                    dc.b    $00             ; $63       NUL
                    dc.b    $00             ; $64       NUL
                    dc.b    $00             ; $65       NUL 
                    dc.b    $00             ; $66       NUL
                    dc.b    $00             ; $67       NUL
                    dc.b    $00             ; $68       NUL
                    dc.b    $00             ; $69       NUL
                    dc.b    $00             ; $6a       NUL
                    dc.b    $00             ; $6b       NUL
                    dc.b    $00             ; $6c       NUL
                    dc.b    $00             ; $6d       NUL
                    dc.b    $00             ; $6e       NUL
                    dc.b    $00             ; $6f       NUL
                    dc.b    $00             ; $70       NUL
                    dc.b    $00             ; $71       NUL 
                    dc.b    $00             ; $72       NUL
                    dc.b    $00             ; $73       NUL
                    dc.b    $00             ; $74       NUL
                    dc.b    $00             ; $75       NUL
                    dc.b    $00             ; $76       NUL
                    dc.b    $00             ; $77       NUL
                    dc.b    $00             ; $78       NUL
                    dc.b    $00             ; $79       NUL
                    dc.b    $00             ; $7a       NUL 
                    dc.b    $00             ; $7b       NUL
                    dc.b    $00             ; $7c       NUL
                    dc.b    $00             ; $7d       NUL 
                    dc.b    $00             ; $7e       NUL
                    dc.b    $00             ; $7f       NUL
                    ; End of Keycode - Ascii lookup table



                    ; --------------- keyboard buffer ------------------
                    ; 32 byte keyboard buffer queue.
                    ;
keyboard_buffer                         ; original address L000034d0
L000034d0           dc.b    $00, $00, $00, $00, $00, $00, $00, $00
                    dc.b    $00, $00, $00, $00, $00, $00, $00, $00
                    dc.b    $00, $00, $00, $00, $00, $00, $00, $00
                    dc.b    $00, $00, $00, $00, $00, $00, $00, $00

                    even

                    ; Keyboard buffer index (where new keycodes are queued into)
keyboard_queue_head                     ; original address L000034f0
                    dc.w    $0000
                    ; Keyboard buffer index (where keycodes are dequeued from)
keyboard_queue_tail                     ; original address L000034f0                 
                    dc.w    $0000


                    ; A bitmap of the keys currently pressed on the keyboard
                    ; each bit records the key press or release status of the key.
                    ; range = $00 - $7f (16 bytes of bitmap data)
keyboard_bitmap                         ; original address $000034f4
                    dc.w    $0000, $0000, $0000, $0000
                    dc.w    $0000, $0000, $0000, $0000

                    ; extended bitmap for control keys (Function keys etc)
                    ; ascii codes $80-$ff
                    dc.w    $0000, $0000, $0000, $0000
                    dc.w    $0000, $0000, $0000, $0000





                    ;----------------------------------------------------------------------------
                    ; never called because a level 6 interrupt never genrated by level 1 code
                    ; IN:
                    ;   d0.b = CIAB - ICR
                    ;
lvl6_timerb_interrupt                           ; original address: $00003514
                    lsr.b   #$02,D0             ; test for TB interrupt
                    bcc.b   .exit               ; no Timer B Interrupt
                    move.b  #$00,$00bfee01      ; CIAA - CRA - Stop Timer A 
.exit               rts                     




                    ; unreferenced ptr?
L00003522           dc.l    lvl_3_sfx_exit      ; L00003542 ; unused ptr to 'rts' below




                    ; ---------------------- update music/sfx player ---------------------------
                    ; called from lvl3 vertb handler
                    ;   - increments the frame counter
                    ;   - play's current sfx/music
                    ;   - writes '$00' to CIAA CRA (this does nothing due to bit 7 being set/clr)
                    ;       - so it doesn't actuall clear any bits?
                    ;
lvl_3_update_sound_player                                   ; original address $00003526
                    movem.l d1-d7/a0-a6,-(a7)
                    addq.w  #$01,frame_counter              ; increment frame counter - $000036ee 
                    jsr     AUDIO_PLAYER_UPDATE                   ; External Address - CHEM.IFF (music player) - $00048018 
                    move.b  #$00,$00bfee01
                    movem.l (a7)+,d1-d7/a0-a6
lvl_3_sfx_exit                                              ; original address L00003542
                    rts






                    ; --------------------- Level 2 - CIAB Timer B Handler -------------------
                    ; CIAB - Timer B underflow handler (read joystick/mouse counters)
                    ;       - calls function ptr set at 'ciab_timerb_function_ptr'
                    ;       - default this is rts.
                    ;
lvl2_CIAB_TimerB_Handler                                    ; original address $00003544
                    movem.l d0-d7/a0-a6,-(a7)
                    bsr.w   ciab_timerb_function
                    addq.w  #$01,ciab_timerb_ticker
                    movea.l ciab_timerb_function_ptr,a0
                    jsr     (a0)
                    movem.l (a7)+,d0-d7/a0-a6
                    rts



ciab_timerb_function_ptr                    ; original address $00003560
                    dc.l    lvl_3_sfx_exit  ; L00003542 ; CIAB - Timer B - Handler Routine - Default ptr to 'rts' @ $00003542
ciab_timerb_ticker                          ; original address $00003564
                    dc.w    $0000           ; CIAB - Timer B - Ticker Count




                    ; --------------------- level 2 - Timer B - read ports -----------------------
                    ; read buttons and pot counters for joystick ports 0 and 1
                    ;
ciab_timerb_function                                ; original address $00003566
                    ; joystick 0 counters
                    move.w  $00dff00a,d0            ; d0 = JOY0DAT
                    move.w  Joystick_0,d1           ; L00003630 ; d1 = last JOY0DAT
                    move.w  d0,Joystick_0           ; L00003630 ; store new JOY0DAT
                    bsr.w   calc_counter_deltas     ; L000035fa
                    move.b  d0,joy0_random          ; L00003637 ; d0 = random number $00 - $0f
                    add.w   d1,pot0_horizontal      ; L00003646 ; d1 = horizontal count delta
                    add.w   d2,pot0_vertical        ; L00003648 ; d2 = vertical count delta
                    btst.b  #$0006,$00bfe001        ; Test Button 0
                    seq.b   joy0_button0            ; L00003636 ; Set Button 0 flag
                    seq.b   joy0_button0b           ; L00003644 ; Set Button 0 flag
                    btst.b  #$0002,$00dff016        ; test Button 1
                    seq.b   joy0_button1b           ; L00003645 ; Set Button 1 flag

                    ; joystick 1 counters
                    move.w  $00dff00c,d0            ; d0 = JOY1DAT
                    move.w  Joystick_1,d1           ; L00003632 ; d1 = last JOY1DAT
                    move.w  d0,Joystick_1           ; L00003632 ; store new JOY1DAT
                    bsr.b   calc_counter_deltas     ; L000035fa
                    move.b  d0,joy1_random          ; L0000363b ; d0 = random number $00 - $0f
                    add.w   d1,pot1_horizontal      ; L0000364c ; d1 = horizontal count delta
                    add.w   d2,pot1_vertical        ; 0000364e  ; d2 = vertical count delts
                    btst.b  #$0007,$00bfe001        ; Test Button 0
                    seq.b   joy1_button0            ; L0000363a ; Set Button 0 flag
                    seq.b   joy1_button0b           ; L0000364a ; Set Button 0 flag
                    btst.b  #$0006,$00dff016        ; test Button 1
                    seq.b   joy1_button1b           ; L0000364b ; Set Button 1 flag
                    rts 



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
calc_counter_deltas                                     ; original address $000035fa
                    move.w  d0,d3                       ; d0,d3 = current value
                    move.w  d1,d2                       ; d1,d2 = previous value
                    sub.b   d3,d1                       ; subtract (horizontal) new value from old value
                    neg.b   d1                          ; negate the result
                    ext.w   d1                          ; sign extend to 16 bits
                    lsr.w   #$08,d2
                    lsr.w   #$08,d3
                    sub.b   d3,d2                       ; subtract (vertical) new value fro mold value
                    neg.b   d2                          ; negate the result
                    ext.w   d2                          ; sign extend to 16 bits

                    ; random number $00 - $0f
                    moveq   #$03,d3
                    and.w   d0,d3                       ; d3 = masked low 2 bits
                    lsr.w   #$06,d0
                    and.w   #$000c,d0                   ; d0 = 2 MSB bits, d3 = 2 LSB bits
                    or.w    d3,d0                       ; combine 2 MSB & 2 LB bits
                    move.b  random_lookup(pc,d0.W),d0   ; L00003620
                    rts 


                    ; ----------- 16 byte lookup table above ------------
                    ; used by above routine to return a value beteen
                    ; $00 - $0f depending on mouse counter values.
                    ; could be a randomnumber seed or similar.
                    ; 
random_lookup                                       ; original address L00003620
                    dc.b $00
                    dc.b $04
                    dc.b $05
                    dc.b $01               
                    dc.b $08
                    dc.b $0c                      
L00003626           dc.b $0d
                    dc.b $09
                    dc.b $0a
                    dc.b $0e               
                    dc.b $0f
                    dc.b $0b
                    dc.b $02
                    dc.b $06               
                    dc.b $07
                    dc.b $03                      

Joystick_0                                          ; original address $00003630
                    dc.w $0000                      ; H/W register value read from JOY0DAT

Joystick_1                                          ; original address $00003632
                    dc.w $0000                      ; H/W register value read from JOY1DAT    

L00003634           dc.w $0000                      ; unreferenced word

joy0_button0
                    dc.b $00
joy0_random
                    dc.b $00   

L00003638           dc.w $0000                      ; unreferenced word

joy1_button0                                        ; original address L0000363a
                    dc.b $00
joy1_random
                    dc.b $00   

L0000363c           dc.w $0000                      ; unreferenced word
L0000363e           dc.w $0000                      ; unreferenced word               
L00003640           dc.w $0000                      ; unreferenced word
L00003642           dc.w $0000                      ; unreferenced word

joy0_button0b                                       ; original address $00003644
                    dc.b $00
joy0_button1b
                    dc.b $00                        ; original address $00003645
pot0_horizontal
                    dc.w $0000                      ; original address $00003646 
pot0_vertical           
                    dc.w $0000                      ; original address $00003648
joy1_button0b
                    dc.b $00                        ; original address $0000364a
joy1_button1b
                    dc.b $00                        ; original address $0000364b
pot1_horizontal             
                    dc.w $0000
pot1_vertical
                    dc.w $0000              




                    ; -------------------- wait key --------------------
                    ; wait/loop until a key is pressed
                    ;
waitkey                                                 ; Address L00003650 not called directly from this code.
                    move.l  d0,-(a7)
.getkey             bsr.b   getkey                      ; d0 = ascii code (z = 1 if no key) L0000365a
                    bne.b   .getkey                     ; loop until a key is pressed
                    move.l  (a7)+,d0
                    rts



                    ; -------------------- get key --------------------
                    ; dequeue an ascii code from the keybaord queue
                    ;
                    ; OUT:
                    ;   d0.b    - Ascii code (0 if queue empty)
                    ;           - Z = 1 if queue is empty
                    ;
getkey                                                  ; original address L0000365a
                    movem.l d1-d2/a0,-(a7)
                    lea.l   keyboard_buffer,a0          ; L000034d0,a0 ; a0 = keyboard buffer
                    moveq   #$00,d0
                    movem.w keyboard_queue_head,d1-d2   ; L000034f0,d1-d2 ; d1 = queue head, d2 = queue tail
                    cmp.w   d1,d2                       ; check queue full/empty
                    beq.b   .exit                       ; if queue is full/empty - jmp $00003682  
.dequeue                                                ; original address L00003672
                    move.b  $00(a0,d2.W),d0             ; d0 = get ascii code
                    addq.w  #$01,d2                     ; increment keyboard tail
                    and.w   #$001f,d2                   ; clamp queue size 32 bytes
                    move.w  d2,keyboard_queue_tail      ; store updated queue tail
.exit                                                   ; original address L00003682
                    tst.b   d0
                    movem.l (a7)+,d1-d2/a0
                    rts 



                    ;--------------- reset display -------------------
                    ; Set the copper list and 4 bitplane display,
                    ; reset bitplane modulos.
                    ; reset display fetch and window size (320x218)
                    ;
                    ; IN:
                    ;   a0 = copper list address
                    ;
reset_display                                               ; original address $0000368a
                    move.w  #$0080,$00dff096                ; Disable Copper DMA
                    move.l  a0,$00dff080                    ; Set Copper List COP1LC
                    move.w  a0,$00dff088                    ; Strobe Copper (force start COPJMP1)
                    move.w  #$0000,$00dff10a                ; BPL2MOD - modulo
                    move.w  #$0000,$00dff108                ; BPL1MOD - modulp
                    move.w  #$0038,$00dff092                ; DDFSTRT - DMA Fetch Start
                    move.w  #$00d0,$00dff094                ; DDFSTOP - DMA Fetch Stop
                    move.w  #$3080,$00dff08e                ; DIWSTRT - Display Window Start Vertical Start = $30, Horizontal Start = $80 (320x218 window)
                    move.w  #$0ac0,$00dff090                ; DIWSTOP - Display Window Stop Vertical Stop = $10a, Horizontal Stop = $1c0
                    move.w  #$4200,$00dff100                ; BPLCON0 - 4 bitplane, colour display 
 
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
 
                    clr.w   frame_counter                   ; L000036ee
.wait_vbl
                    tst.w   frame_counter                   ; L000036ee
                    beq.b   .wait_vbl                       ; L000036dc ; wait for next vertb
                    move.w  #$8180,$00dff096              ; Enable - Copper DMA
                    rts 



frame_counter_and_target_counter
frame_counter                                                       ; original address $000036ee
                    dc.w    $0000                                   ; incremeted every VERTB interrupt (level 3 interrupt handler)
target_frame_count                                                  ; original address $000036f0
                    dc.w    $0000                                   ; target frame count - (can be used to delay and wait for specific frame counter value)     

playfield_buffer_ptrs                                               ; original address $000036f2
playfield_buffer_1                                                  ; original address $000036f2
                    dc.l    CODE1_DISPLAY_BUFFER2_ADDRESS           ; double buffered playfield ptr 1 (current display by copper)
playfield_buffer_2                                                  ; original address $000036f6
                    dc.l    CODE1_DISPLAY_BUFFER1_ADDRESS           ; double buffered playfield ptr 2 (back buffer)




                    ; ----------------------- double buffer display playfield --------------------------
                    ; swap display buffer pointers and update the copper list display.
                    ; can wait for future frame count, typically waits for top of next frame.
                    ;
                    ; Code Checked 14/01/2025
                    ;
double_buffer_playfield ; original addr: $000036fa
.wait_target_frame
                    move.w  frame_counter,d0
.wait_raster_tof        ; L000063fe
                        cmp.w   frame_counter,d0
                        beq.b   .wait_raster_tof                    ; wait for top of next display frame
.chk_target_frame   ; L00003704
                    move.w  target_frame_count,d1
                    cmp.w   d0,d1
                    bpl.b   .wait_target_frame                      ; wait for target frame count (normally the next frame)

                    ; set target frame to current + 1
                    add.w   #$0001,d0
                    move.w  d0,target_frame_count

                    ; swap display buffer pointers                  ; original addr: $00003714
                    movem.l playfield_buffer_ptrs,d0-d1
                    exg.l   d0,d1
                    movem.l d0-d1,playfield_buffer_ptrs

                    ; set copper bitplane ptrs                      ; original address L00003722
                    lea.l   copper_playfield_planes+2,a0
                    move.l  #CODE1_DISPLAY_BITPLANEBYTES,d1 
                    moveq   #CODE1_DISPLAY_BITPLANEDEPTH-1,d7 
.next_bitplane      ; L0000372e
                    move.w  d0,(a0)                                 ; set copper bpl(x)ptl low word
                    addq.w  #$04,a0                                 ; increment copper ptr to bpl(x)pt high word
                    swap.w  d0
                    move.w  d0,(a0)                                 ; set copprt bpl(x)pth high word
                    addq.w  #$04,a0                                 ; increment copper ptr to next bpl(x)pt low word
                    swap.w  d0
                    add.l   d1,d0                                   ; calc next bitplane start address
                    dbf.w   d7,.next_bitplane

                    ; increment swap count
                    addq.w  #$01,playfield_swap_count
                    rts




                    ; ----------------------- clear display memory ---------------------------
                    ; Clear Double Buffer Display (back & front)
                    ; Clear Off-Screen Displaty Buffer
                    ;
                    ; Code Checked 14/01/2025
                    ;
clear_display_memory ; original address L00003746
                    ; clear double buffer display memory
                    lea.l   CODE1_DOUBLE_BUFFER_ADDRESS,a0
                    move.w  #(CODE1_DOUBLE_BUFFER_BYTESIZE/4)-1,d7    ; original #$3917 (now 3530)   
.clr_loop_1         ; L00003750
                    clr.l   (a0)+                                   ; clear 4 bytes
                    dbf.w   d7,.clr_loop_1

                    ; clear off-screen display buffer
                    lea.l   CODE1_CHIPMEM_BUFFER,a0
                    move.w  #(CODE1_DISPLAY_BUFFER_BYTESIZE/4)-1,d7 ; #$1c8c-1
.clr_loop_2         ; L00003760
                    clr.l   (a0)+                                   ; clear 4 bytes
                    dbf.w   d7,.clr_loop_2
                    rts 





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
debug_display_params                                                        ; original address L00003768
dp_xy_coords                                                                
                    dc.w $0a0a                                      ; location y,x (bytes) 
dp_ascii_string        
                    dc.b '0000',$00,$ff                             ; decoded ASCII string to display             

debug_print_word_value                                                      ; original address L00003770
                    lea.l   debug_display_params,a0
                    move.w  d1,(a0)                                 ; store display Y,X location.
                    moveq   #$03,d2                                 ; loop counter 3 + 1 (4 hex characters to decode for 16bit value)

.nibble_to_ascii    ; decode 4 nibbles to ASCII chars
                        clr.w   d1
                        move.w  d0,d1
                        and.w   #$000f,d1                           ; mask 4 bit value to decode (0-15)
                        cmp.w   #$000a,d1                           ; check d1 value
                        bcs.b   .digit0_9                           ; value < 10
.digit_a_f
                            addq.w  #$07,d1                         ; add ascii offset to char 'A' for value in range $a-$f
.digit0_9
                        add.b   #$30,d1                             ; add ascii offset to char '0' for all digits $0-$f
                        move.b  d1,$02(a0,d2.W)                     ; store ascii character for decoded hex digit
                        lsr.w   #$04,d0                             ; shift in next nibble to decode.
                    dbf.w   d2,.nibble_to_ascii
         
.calc_print_location ; calc destination display ptr                 ; original address - $00003798
                    move.b  (a0)+,d0                                ; get y co-ord value.
                    cmp.b   #$ff,d0                                 ; $ff = terminator value for exit.
                    beq.b   .exit                       

                    and.w   #$00ff,d0                               ; mask low byte value.
                    mulu.w  #PANEL_DISPLAY_BYTEWIDTH,d0
                    moveq   #$00,d1 
                    move.b  (a0)+,d1                                ; get x co-ord value (byte value)

                    add.w   d1,d0                                   ; d0 = x + y (print offset)
                    movea.l #PANEL_GFX,a1                           ; Panel GFX Address - $0007c89a.
                    lea.l   $02(a1,d0.w),a1                         ; a1 = display location.

.display_char       ; get char for display                          ; original address L000037b8
                    moveq   #$00,d0
                    move.b  (a0)+,d0
                    beq.b   .calc_print_location                    ; null terminator, could have exited here.
                    
                    ; calc source gfx ptr 
                    sub.w   #ASCII_SPACE,d0
                    lsl.w   #$03,d0                                 ; calc character GFX offset
                    lea.l   font8x8,a2                              ; 8x8 Character Font start address
                    lea.l   $00(a2,d0.w),a2                         ; source character GFX ptr

                    ; initialise print char loop
                    moveq   #FONT_8x8_HEIGHT-1,d7                   ; print_char_loop counter
                    movea.l a1,a3                                   ; gfx dest ptr copy

.print_char_loop    ; write gfx char to display - one raster line at a time
                    move.b  (a2),(a3)
                    move.b  (a2),PANEL_DISPLAY_BITPLANEBYTES(a3)
                    move.b  (a2),2*PANEL_DISPLAY_BITPLANEBYTES(a3)
                    move.b  (a2)+,3*PANEL_DISPLAY_BITPLANEBYTES(a3)
                    lea.l   PANEL_DISPLAY_BYTEWIDTH(a3),a3
                    dbf.w   d7,.print_char_loop

.next_char          ; set up next char for display                  ; original address L000037e8
                    lea.l   $0001(a1),a1                            ; increment destination ptr for display of next character
                    bra.b   .display_char                           ; display next char - L000037b8
.exit                                                               ; original address L000037ee
                    rts



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

actors_list         ; original address L000039c8
                    dc.w    $0000
                    dc.W    $0000                           ; actor X
                    dc.w    $003a                           ; actor Y
                    dc.w    $0097
                    dc.w    $0000
                    dc.w    $0000
                    dc.w    $0000
                    dc.w    $0000
                    dc.w    $0000
                    dc.w    $0000
                    dc.l    $00000000                       ; ptr to actor init data (actors_list)

                    dc.w    $0000
                    dc.w    $00a0
                    dc.w    $0038
                    dc.w    $0046
                    dc.w    $0000
                    dc.w    $0000
                    dc.w    $0000
                    dc.w    $0000
                    dc.w    $0000
                    dc.w    $0000
                    dc.l    $00000000           ; 16 bit address of actor data structure

                    dc.w    $0000
                    dc.w    $00a0
                    dc.w    $0038
                    dc.w    $0046
                    dc.w    $0000
                    dc.w    $0000
                    dc.w    $0000
                    dc.w    $0000
                    dc.w    $0000
                    dc.w    $0000
                    dc.l    $00000000           ; 16 bit address of actor data structure

                    dc.w    $0000
                    dc.w    $00a0
                    dc.w    $0038
                    dc.w    $0046
                    dc.w    $0000
                    dc.w    $0000
                    dc.w    $0000
                    dc.w    $0000
                    dc.w    $0000
                    dc.w    $0000
                    dc.l    $00000000           ; 16 bit address of actor data structure

                    dc.w    $0000
                    dc.w    $00a0
                    dc.w    $0038
                    dc.w    $0046
                    dc.w    $0000
                    dc.w    $0000
                    dc.w    $0000
                    dc.w    $0000
                    dc.w    $0000
                    dc.w    $0000
                    dc.l    $00000000           ; 16 bit address of actor data structure

                    dc.w    $0000
                    dc.w    $00a0
                    dc.w    $0038
                    dc.w    $0046
                    dc.w    $0000
                    dc.w    $0000
                    dc.w    $0000
                    dc.w    $0000
                    dc.w    $0000
                    dc.w    $0000
                    dc.l    $00000000           ; 16 bit address of actor data structure

                    dc.w    $0000
                    dc.w    $00a0
                    dc.w    $0038
                    dc.w    $0046
                    dc.w    $0000
                    dc.w    $0000
                    dc.w    $0000
                    dc.w    $0000
                    dc.w    $0000
                    dc.w    $0000
                    dc.l    $00000000           ; 16 bit address of actor data structure

                    dc.w    $0000
                    dc.w    $00a0
                    dc.w    $0038
                    dc.w    $0046
                    dc.w    $0000
                    dc.w    $0000
                    dc.w    $0000
                    dc.w    $0000
                    dc.w    $0000
                    dc.w    $0000
                    dc.l    $00000000           ; 16 bit address of actor data structure

                    dc.w    $0000
                    dc.w    $00a0
                    dc.w    $0038
                    dc.w    $0046
                    dc.w    $0000
                    dc.w    $0000
                    dc.w    $0000
                    dc.w    $0000
                    dc.w    $0000
                    dc.w    $0000
                    dc.l    $00000000           ; 16 bit address of actor data structure
last_active_actor   ; original address L00003a8e
L00003a8e           dc.w    $0000
                    dc.w    $00a0
                    dc.w    $0038
                    dc.w    $0046
                    dc.w    $0000
                    dc.w    $0000
                    dc.w    $0000
                    dc.w    $0000
                    dc.w    $0000
                    dc.w    $0000
                    dc.l    $00000000           ; 16 bit address of actor data structure


                    ; AXIS CHEMICAL FACTORY - Original Address L00003aa4
text_axis_chemicals
L00003aa4           
                    dc.b    $30,$09
                    dc.b    'TEST BUILD 16/01/2025',$00
                    dc.b    $50, $09                                    ; raster line (Y), byte offset (X)
                    dc.b    'AXIS '                                     ; $41, $58, $49, $53, $20
                    dc.b    'CHEMICAL '                                 ; $43, $48, $45, $4d, $49, $43, $41,$4c, $20
                    dc.b    'FACTORY'                                   ; $46, $41, $43, $54, $4f, $52, $59
                    dc.b    $00,$ff                                     ; Line Terminator

text_mouse_button   ; additional debug text             
                    dc.b    $70,$08
                    dc.b    'PRESS LEFT MOUSE BUTTON'
                    dc.b    $00,$ff                                     ; Message Terminator

                    ; JACK IS DEAD - Original Address L00003abd
text_jack_is_dead
L00003abd           dc.b    $40, $0e                                    ; raster line (Y), byte offset (X)
                    dc.b    'JACK '                                     ; $4a, $41, $43, $4b, $20
                    dc.b    'IS '                                       ; $49, $53, $20
                    dc.b    'DEAD'                                      ; $44, $45, $41, $44 
                    dc.b    $00, $ff                                    ; Message Terminator

                    ; THE JOKER LIVES - Original Address L00003acd
text_the_joker_lives
L00003acd           dc.b    $60, $0b                                    ; raster line (Y), byte offset (X)
                    dc.b    'THE '                                      ; $54, $48, $45, $20
                    dc.b    'JOKER '                                    ; $4a, $4f, $4b, $45, $52, $20
                    dc.b    'LIVES... '                                 ; $4c, $49, $56, $45, $53, $2e, $2e, $2e
                    dc.b    $00, $ff                                    ; Message Terminator

                    even







                    ; ----------------------- start game ------------------------
                    ; Called after the system is initialised, initialise the
                    ; game level & play the game loop
                    ;
initialise_game                                                     ; original address $00003ae4
                    clr.l   frame_counter_and_target_counter
                    bsr.w   double_buffer_playfield 

                    bsr.w   preprocess_data

                    jsr     AUDIO_PLAYER_INIT
                    clr.w   level_spawn_point_index                 ; start at beginning of the level - L000062fc
                    jsr     PANEL_INIT_LIVES

                    ; restart point after batman dies
restart_level                                                       ; original address L00003b02
                    clr.w   grappling_hook_height                   ; L00006318
                    clr.l   frame_counter_and_target_counter
                    bsr.w   clear_display_memory

                    move.w  #CODE1_INITIAL_TIMER_BCD,d0
                    jsr     PANEL_INIT_TIMER 
                    jsr     PANEL_INIT_ENERGY

                    bsr.w   panel_fade_in


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
                    lea.l   MAPGR_DATA_ADDRESS,a0
                    movea.l L00005f64,a5                            ; a5 = 00005fc4 (default do nothing data address ptr)
.do_update_loop                                                     ; original address L00003b30             
                    movem.w (a5)+,d2-d4                             ; d2, d3 d4 (6 bytes), initially all = $0000.w
                    tst.w   d3
                    beq.b   .exit_update_level_data
                    ; update level data indexed by d3, with values held in d2 & d4
                    ; move d2 value into level data indexed by D3
                    move.b  d2,$01(a0,d3.W)
                    lsr.w   #$08,d2
                    move.b  d2,$00(a0,d3.W)
                    ; move d4 value into level data indexed by D3 + 2
                    move.b  d4,$03(a0,d3.W)
                    lsr.w   #$08,d4
                    move.b  d4,$02(a0,d3.W)
                    bra.b   .do_update_loop                         ; loop again

.exit_update_level_data                                             ; original address L00003b4e
                    move.l  #L00005fc4,L00005f64                    ; reset ptr to default (no update data - all 0 values)



                    ; clear 40 longs (160 bytes)
                    ; data referenced by projectiles
clear_projectile_data                                               ; original address 00003b58
                    lea.l   projectile_list,a0                      
                    moveq   #$27,d7                                 ; loop counter = #$27 + 1 = #$28 (40 in decimal)
.loop               clr.l   (a0)+                   
                    dbf.w   d7,.loop



                    ; ------------ reset actors/triggers -------------
                    ; clear MSB flag of each data structure
                                                                    ; original address L00003b64
clear_msb           lea.l   trigger_definitions_list,a0             ; L0000642e,a0                
.loop1               bclr.b  #$0007,(a0)                            ; clear MSB (enable/disable flag?)
                    move.w  $0004(a0),d0                            ; count of data entries and/or offset to next structure, word at 4(a0) 
                    mulu.w  #$0006,d0                               ; size of each data entry (6 bytes)
                    lea.l   $06(a0,d0.w),a0                         ; increment pointer to next actor definition
                    cmp.l   #end_of_trigger_list,a0                 ; check if end of list
                    bcs.b   .loop1                                  ; loop until end of list.

                    ; clear MSB flag of each data structure
                    ; original address L00003b7e                 
.loop2              bclr.b  #$0007,$0004(a0)
                    addq.w  #$06,a0                                 ; start of next data structure
                    cmp.l   #end_of_actors,a0
                    bcs.b   .loop2




                    ; Clear Active Actors List?                     ; original address L00003b8c
L00003b8c           lea.l   actors_list,a0                          ; L000039c8,a0
                    moveq  #(ACTORLIST_SIZE/2)-1,d7
.loop
                    clr.w   (a0)+
                    dbf.w   d7,.loop



                    ; ------ Set initial batman sprite ids -----    ; original address L00003b98
init_batman_sprites clr.w   batman_sprite1_id
                    lea.l   batman_sprite_anim_standing,a0                ; L000063d3,a0
                    bsr.w   set_batman_sprites



                    ; ------ Set initial player control state ------
                    ; initial state is 'walking' on platform.
init_control_state  move.l  #player_move_commands,gl_jsr_address    ; set default player input state handler 'walking'



                    ; -------- set player spawn point --------
                    ; sets the player start location and display
                    ; window default values. 
                    ; Either start of level or halfway point.
set_player_defaults                                                  
                    lea.l   default_level_parameters,a0             ; start of spawn point array of default values
                    move.w  level_spawn_point_index,d6              ; Spawn Point Index 0 or 1
.outer_loop
                    moveq   #$06,d7                                 ; 7 values to copy for each spawn point (window pos, batman offset, batman target offset, tracker for max x distance travelled)
                    lea.l   level_parameters,a1                     ; address of current display parameters
.inner_loop 
                    move.w  (a0)+,(a1)+                             ; copy single parameter (0-6)
                    dbf.w   d7,.inner_loop                          ; parameter cop loop loop (7 times)
                    dbf.w   d6,.outer_loop                          ; loop again until required spawn point parameters have been copied 


                    

                    ; ---------- display level title -------
display_axis_chemical_factory                                       ; original address L00003bc2
                    lea.l   text_axis_chemicals,a0
                    bsr.w   large_text_plotter
                    bsr.w   double_buffer_playfield   

 

                    ; --------- pause for 1 second --------
one_second_wait     moveq   #$32,d0                                 ; 50 frame wait
                    bsr.w   wait_for_frame_count

                    ; ----------- display press mouse button -------
                    lea.l   text_axis_chemicals,a0
                    bsr.w   large_text_plotter 
                    lea.l   text_mouse_button,a0
                    bsr.w   large_text_plotter
                    bsr.w   double_buffer_playfield  

                    ; -------- initialise back buffer ------        ; original address L00003bce
init_back_buffer    bsr.w   initialise_offscreen_buffer             ; draw initial background gfx to offscreen buffer
                    bsr.w   copy_offscreen_to_backbuffer            ; copy initial level background gfx to back-buffer                              

                    ; -------- draw player in at point -------
draw_player         bsr.w   draw_batman_and_rope



                    ; ------- wait for mouse click ---------
                    JSR     _MOUSE_WAIT



                    ; --------- start music (if selected) ----------
set_music_sfx       btst.b  #PANEL_ST2_MUSIC_SFX,PANEL_STATUS_2     ; Panel - Status 2 Bytes - bit #$0000 of $0007c875 
                    bne.b   .no_music                              ; L00003bf2
.set_music
                    moveq   #$01,d0                                 ; song number - 01 = level music
                    jsr     AUDIO_PLAYER_INIT_SONG
.no_music


                    ; --------- wipe screen from text to level gfx ---------
                    bsr.w   screen_wipe_to_backbuffer
                    clr.l   frame_counter_and_target_counter





                    ; -----------------------------------------------------------------------------------------------------------
                    ;
                    ; Game Loop
                    ;
                    ; -----------------------------------------------------------------------------------------------------------
game_loop           ; original address $00003bfa


                    ; ---------- Start Key press checks -----------
                    ;
                    ; 'F1'  -  Pause Game
                    ;           1) when paused 'ESC' = exit game
                    ;           2) any other key resumes the game
                    ; 'F2'  - Toggle Music/SFX
                    ; 'F10' - Skip Level (if cheat mode is active)
                    ;
start_of_key_checks
                    bsr.w   getkey                                      ; d0 = ascii code (0 =  no key pressed)
                    beq.b   end_of_key_checks
.test_pause_game_f1
                        cmp.w   #KEY_F1,d0                              ; Test for Key = 'F1'
                        bne.b   .test_toggle_music_f2                    
.gl_pause_game_loop
                            bsr.w   getkey                  
                            beq.b   .gl_pause_game_loop 

                            cmp.w   #KEY_ESC,d0                         ; Test for Key = 'ESC'
                            bne.b   .test_toggle_music_f2
.exit_game
                                bsr.w   screen_wipe_to_black
                                bset.b  #PANEL_ST2_GAME_OVER,PANEL_STATUS_2
                                bra.w   return_to_title_screen 
                                ; ***************************                 
                                ; ****** NEVER RETURNS ******
                                ; **** LOAD TITLE SCREEN ****
                                ; ***************************

.test_toggle_music_f2
                        cmp.w   #KEY_F2,d0                              ; Test for Key = 'F2'
                        bne.b   .test_level_skip_f10
.toggle_music_sfx
                            bchg.b  #PANEL_ST2_MUSIC_SFX,PANEL_STATUS_2
                            bne.b   .init_music
.init_sfx
                                jsr     AUDIO_PLAYER_INIT_SFX_1
                                bra.w   end_of_key_checks
.init_music
                                moveq   #SFX_LEVEL_MUSIC,d0
                                jsr     AUDIO_PLAYER_INIT_SONG
                                bra.w   end_of_key_checks

.test_level_skip_f10
                        cmp.w   #KEY_F10,d0                              ; Test for key = 'F10'
                        bne.b   end_of_key_checks
.skip_level
                            btst.b  #PANEL_ST2_CHEAT_ACTIVE,PANEL_STATUS_2
                            bne.w   Load_level_2
                            ; ***************************                 
                            ; ****** NEVER RETURNS ******
                            ; ****** LOAD LEVEL 02 ******
                            ; ***************************

                    ; --------- End of Key Press Checks ---------
end_of_key_checks



                    ;jmp     do_system_updates

                    ; -------- start of player state machine updates ------------
gl_update_state_machine
                    btst.b  #PANEL_ST1_TIMER_EXPIRED,PANEL_STATUS_1         ; Test Timer has expired
                    bne.b   .execute_player_state                           ; if timer expired then continue
.timer_not_expired
                        ; tick panel update (level timer etc)
                        jsr     PANEL_UPDATE                
                        jsr     PANEL_UPDATE
                        ; check if timer now expired
                        btst.b  #PANEL_ST1_TIMER_EXPIRED,PANEL_STATUS_1     ; Test Timer has expired 
                        beq.b   .execute_player_state                       ; if timer expired then continue
.timer_still_not_expired
                            ; update player state and increment counters
                            moveq   #$01,d6
                            bsr.w   batman_collision_state_machine

.execute_player_state
                    clr.l   d0
                    clr.l   d1
                    bsr.w   read_player_input
                    movem.w batman_xy_offset,d0-d1

                    ; ----- SELF MODIFYING CODE -----
                    ; updated all over the place to run an alternative routine.
                    ; a bit of a state machine kinda update routine.
gl_jsr_intstruction dc.w    $4eb9                           ; jsr - opcode (jsr $L00004c3e) ; original address L00003c8e
gl_jsr_address      dc.l    player_move_commands            ; $00004c3e ; Self Modified Address ; original address L00003c90
                    ; ----- END OF SELF MODIFYING CODE -----

                    ; -------- end of player state machine updates ------------


do_system_updates
                    bsr.w   scroll_offscreen_buffer                 ; L00004936 ; Scroll Background Window GFX in Offscreen Scroll Buffer 
                    bsr.w   update_score_by_level_progress          ; L00003dd4 ; Update Score based upon progress from left to right through the level.
                    
                    bsr.w   trigger_new_actors                      ; L00003dfe ; Trigger new actors when in range.

                    bsr.w   copy_offscreen_to_backbuffer            ; L00004b62 ; Copy Off-Screen Background GFX to Back-Buffer
                    bsr.w   draw_batman_and_rope                    ; L000055c4 ; Draw Batman and Rope Swing
                    
                    bsr.w   update_active_actors                    ; L00003ee6 ; Update Level Actors 02
                    
                    bsr.w   update_projectiles                      ; L00004658 ; Update Projectiles (Bombs, Bullets, Batarang)
                    bsr.w   draw_projectiles                        ; L000045fe ; Draw Projectiles (Bombs, Buttles, Batarang)            
                    bsr.w   double_buffer_playfield                 ; L000036fa

                    bra.w   game_loop                               ; L00003bfa ; jump back to main loop


                    ;-----------------------------------------------------
                    ;------------------ End of Game Loop -----------------
                    ;-----------------------------------------------------




                    ; -------------- Wipe Screen to Black ----------------
                    ; Perform screen wipe to black.
                    ;   - Clears back buffer
                    ;   - falls through to screen_wipe_to_backbuffer
                    ;
screen_wipe_to_black                                        ; original address L00003cbc
                    bsr.w   clear_backbuffer_playfield      ; L00004e28


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
screen_wipe_to_backbuffer                                   ; original address L00003cc0
                    move.w  #$002a,d0
                    move.w  #$00ae,d1
                    movem.l playfield_buffer_ptrs,a0-a1     ; L000036f2,a0-a1
                    clr.w   d2
.wipe_outer_loop    ; outer loop
                        moveq   #$7f,d3
                        and.w   d2,d3
                        moveq   #$0f,d5
                        lsr.w   #$01,d3
                        bcc.b   .skip_d5
                        moveq   #-$16,d5                            ;  #$fffffff0,D5                    
.skip_d5
                        cmp.w   d0,d3
                        bcc.b   .skip_inner_loops                    ; L00003d32
                        move.w  d2,d4
                        lsr.w   #$05,d4
                        and.w   #$00fc,d4
                        cmp.w   d1,d4
                        bcc.b   .skip_inner_loops                    ; L00003d32
                        mulu.w  d0,d4
                        add.w   d3,d4
                        move.w  d2,-(a7)
                        move.w  d0,d3
                        mulu.w  d1,d3
                        moveq   #$03,d7
.wipe_middle_loop   ; middle loop                                                 ; original address L00003cf8
                            move.w  d4,-(a7)
                            moveq   #$03,d2
                            move.w  $0002(a7),d6
                            cmp.w   #$1580,d6
                            bcs.b   .wipe_inner_loop                     ; L00003d08
                            moveq   #$01,d2                             ; inner loop count
.wipe_inner_loop         ; inner loop                                ; original address L00003d08
                                move.b  d5,d6
                                not.w   d6
                                and.b   $00(a0,d4.W),d6
                                move.b  d6,$00(a0,d4.W)
                                move.b  d5,d6
                                and.b   $00(a1,d4.W),d6
                                or.b    $00(a0,d4.W),d6
                                move.b  d6,$00(a0,d4.W)
                                add.w   d0,d4
                            dbf.w   d2,.wipe_inner_loop                  ; L00003d08

                            move.w  (a7)+,d4
                            add.w   d3,d4
                        dbf.w   d7,.wipe_middle_loop                  ; L00003cf8

                        move.w  (a7)+,d2
.skip_inner_loops       mulu.w  #$5555,d2
                        addq.w  #$01,d2
                        and.w   #$1fff,d2
.exit_check         bne.b   .wipe_outer_loop                     ; L00003cd0
                    rts



                    ;---------------------- panel fade in -----------------------
                    ; fades the panel colours from black to expected colours.
                    ; waits 4 frames between each fade loop.
                    ; loops 16 times, 64 frames fade in. approx 1 seconds.
                    ;
panel_fade_in                                               ; original address $00003d40
                    moveq   #$0f,d7                         ; d7 = 15+1 - outer loop
.fade_loop                                                  ; original address $00003d42
                    lea.l   copper_panel_colors+2,a0 
                    lea.l   panel_colours,a1                ; $000032a0   
                    moveq   #$0f,d6
.next_colour                                                ; original address $00003d4c
                    move.w  (a0),d0                         ; d0 = current display colour
                    move.w  (a1)+,d1                        ; d1 = panel colour
                    eor.w   d0,d1                           ; XOR will result in 000 copper value = expected value
.fade_blue                                                  ; original address $00003d52
                    moveq   #$0f,d2                         ; blue bits mask
                    and.w   d1,d2                           ; d2 = blue bits
                    beq.b   .fade_green                     ; L00003d5a ; if blue bits == 0 then equals target colour
                    addq.w  #$01,d0                         ; else increment blue colour
.fade_green                                                 ; original address $00003d5a
                    move.l  #$fffffff0,D2                   ; d2 = green bits mask
                    and.b   d1,d2                           ; mask out blue bits, leaving green bits
                    beq.b   .fade_red                       ; L00003d64 ; if green bits == 0 then equals target colour
                    add.w   #$0010,d0                       ; else increment green bits
.fade_red                                                   ; original address $00003d64
                    and.w   #$0f00,d1                       ; mask out green & blue bits
                    beq.b   .end_fade                       ; L00003d6e ; if red bits == 0 then equals target colour
                    add.w   #$0100,d0                       ; else increment red bits
.end_fade                                                   ; original address $00003d6e
                    move.w  d0,(a0)                         ; store new colour in copper list
                    addq.w  #$04,a0                         ; next copper colour address ptr
                    dbf.w   d6,.next_colour                 ; L00003d4c ; fade next colour

                    ; wait for 4 frame counts
.wait_4_frames                                              ; original address $00003d76
                    move.w  frame_counter,d0                ; L000036ee,d0
                    addq.w  #$04,d0
.wait_frame_count                                           ; original address $00003d7e
                    cmp.w   frame_counter,d0                ; L000036ee,d0
                    bne.b   .wait_frame_count               ; L00003d7e
                    dbf.w   d7,.fade_loop                   ; L00003d42
                    rts



                    ;---------------------- panel fade out -----------------------
                    ; fades the panel colours to black.
                    ; waits 4 frames between each fade loop.
                    ; loops 16 times, 64 frames fade in. approx 1 seconds.
                    ;
panel_fade_out                                                          ; original address L00003d8c
                    moveq   #$0f,d7                                     ; Outer loop count (fade 16 colour registers, 16 shades of RGB in the copper)

                    ; outer loop fade 16 colour registers
.fade_all_colours_loop  
                        lea.l   copper_panel_colors+2,a0
                        moveq   #$0f,d6                                 ; Number of colours to fade (16 iterations)

.fade_next_colour       ; inner loop (fade individual colour)
                            move.w  (a0),d0                             ; d0 = colour value
.fade_blue
                            moveq   #$0f,d1                             ; blue bits mask        
                            and.w   d0,d1                               ; current blue value
                            beq.b   .fade_green
                            subq.w  #$01,d0                             ; decrement blue value if > 0
.fade_green
                            move.w  #$00f0,d1                           ; green bits mask
                            and.w   d0,d1                               ; current green value
                            beq.b   .fade_red
                            sub.w   #$0010,d0                           ; decrement green value if > 0
.fade_red
                            move.w  #$0f00,d1                           ; red bits mask
                            and.w   d0,d1                               ; current red value
                            beq.b   .store_fade
                            sub.w   #$0100,d0                           ; decrement red value if > 0
.store_fade
                            move.w  d0,(a0)                             ; store faded colour back to copper
                            addq.w  #$04,a0                             ; increment copper ptr to next colour value
                        dbf.w   d6,.fade_next_colour                    ; fade next colour loop (16 colours
     
.frame_delay            ; wait for 4 frame counts
                        move.w  frame_counter,d0                        ; get current vbl counter
                        addq.w  #$04,d0                                 ; wait for 4 vbl counts
.frame_delay_loop
                        cmp.w   frame_counter,d0                        ; compare current frame count with furture frame count
                        bne.b   .frame_delay_loop                       ; loop until equal (NB frame_counter incremented by level 3interrupt)

                    dbf.w   d7,.fade_all_colours_loop                   ; fade all colours to black (16 iterations)
                    rts





                    ; ----------------- update score by level progress ------------------   
                    ; Update the score based on X distance travelled through the level.
                    ;
update_score_by_level_progress                                         ; original address $00003dd4
                    clr.l   d0                                         ; clear score update value
                    move.w  scroll_window_x_coord,d1
                    sub.w   scroll_window_max_x_coord,d1
                    bls.b   .exit                                       ; if not progressed further then exit.

.do_update_score                                                                ; original address L00003de0
                    move.w  scroll_window_x_coord,scroll_window_max_x_coord     ; update new max x co-ord value
                    lsl.w   #$04,d1                                             ; multiply change by 16
                    move.b  d1,d0                                               ; copy d1 into d0 (low byte)
                    bra.b   .do_increase_score                       

                    ; increase score by 100 BCD for every 4 (64) X co-ord units moved to the right
.increase_score_loop                                                    ; original address L00003dec
                    add.w   #$0100,d0                                   ; add 100 BCD to score update
.do_increase_score                                                      ; original address L00003df0
                    sub.w   #$0064,d1                                   ; subtract 64 from d1 (distance delta * 16)
                    bcc.b   .increase_score_loop                        ; for every multiple of #$64, add 100 to the score.
.update_score_value                                                     ; original address L00003df6
                    jmp     PANEL_ADD_SCORE                             ; Panel Add Player Score (D0.l BCD value to add)- $0007c82a
.exit                                                                   ; original address L00003dfc
                    rts     






                    ; ---------------------- trigger-new-actors ----------------------
                    ; Processes the list of bad-guy triggers and list of 
                    ; gas-leaks/drips.
                    ; Spawns new actors if there is room to do so (max 10 at anytime)
                    ;
                    ; Code Checked 9/1/2025
                    ;
trigger_new_actors  ; original address L00003dfe
                    movem.w scroll_window_xy_coords,d0-d1               ; scroll window X, Y? - L000067bc,d0-d1 (updated_batman_distance_walked,unknown)
                    lea.l   trigger_definitions_list,a0                 ; L0000642e,a0
.process_next_trigger ; L00003e08
                    movem.w (a0)+,d2-d3                                 ; trigger X,Y co-ords?
                    sub.w   d0,d2                                       ; sub window x from actor x
                    cmp.w   #$0098,d2                                   ; compare 152 (304 decimal)
                    bcc.b   .skip_to_next                               ; actor is > 152 (304) from window X
                    sub.w   d1,d3                                       ; d3 = window Y - actor Y
                    cmp.w   #$0050,d3                                   ; is actor > 80 (160) from window Y
                    bcc.b   .skip_to_next                               ; actor is > 80 (160) from window Y

.trigger_in_range   ;L00003e1c - trigger is in window range
                    bset.b  #$7,-$0004(a0)                              ; set MSB of offset 0 (facing direction? enabled/disabled?)
                    move.w  (a0)+,d7                                    ; d7 = number of actors to spawn
                    subq.w  #$01,d7                                     ; counter (-1)
.spawn_actor_loop   ; L00003E26
                    bsr.w   spawn_new_actor                             ; spawn actor.
                    dbf.w   d7,.spawn_actor_loop                        ; loop for all actors on this trigger
                    bra.b   .continue_triggers
                   
.skip_to_next       ; L00003E30 - skip to next trigger data
                    move.w  (a0),d2                                     ; get number of actors associated with this trigger
                    add.w   d2,d2                                       ; 
                    add.w   (a0),d2                                     ; multiply by 6 to get size of actor data to skip
                    add.w   d2,d2                                       ; 
                    lea.l   $02(a0,d2.w),a0                             ; skip to start of next actor data structure

.continue_triggers  ; L00003e3c - check end of trigger list
                    cmpa.l  #end_of_trigger_list,a0                     ; converted to 32 bit address check - end_of_trigger_list
                    bcs.b   .process_next_trigger                        ; not at end of list (process next trigger in list)


                    ; ----------------------- trigger_gasleak_and_drips -------------------------
                    ; process list of 6 bytes (other actors - steam jets and toxic drips)
                    ;
                    ; IN:-
                    ;   a0.l = start of gasleak/drip trigger locations. (3 word structure per item)
                    ;
                    ; Code Checked 9/1/2025
                    ;
trigger_gasleak_and_drips  ; L00003e42                                  ; original address L00003e42
                    sub.w   #$0010,d0                                   ; sub 16 from window x
                    subq.w  #$08,d1                                     ; sub 8 from window y
.next_leak_or_drip  ; L00003e48
                    movem.w $0002(a0),d2-d3                             ; get actor x & y
                    sub.w   d0,d2                                       ; subtract window X from actor X
                    cmp.w   #$00c0,d2                                   ; compare 192 with actor X
                    bcc.b   .skip_to_next                               ; if actor X > 194 (388?)
                    sub.w   d1,d3
                    cmp.w   #$0060,d3
                    bcc.b   .skip_to_next
                    bsr.w   spawn_new_actor
                    bset.b  #$7,-$0002(a0)                              ; set triggered bit
                    bra.b   .continue_next

.skip_to_next        ; L00003e6a - skip to next                         ; original address L00003e6a
                    addq.w  #$06,a0                                     ; add structure size to address ptr                       
.continue_next      ; L00003e6c                                         ; original address L00003e6c
                    cmpa.l  #end_of_actors,a0                           ; check end address of actor list (converted to long word)
                    bcs.b   .next_leak_or_drip                          ; if not the end of the list then process next
                    rts




                    ; -------------------- spawn new actor ------------------------
                    ; Adds new actor to list of actors for processing.
                    ; Includes a bit of a copy protection check also at the start.
                    ;
                    ; IN:
                    ;   d0.w = window scroll x
                    ;   d1.w = window scroll y
                    ;   a0.l = ptr to actor init data in trigger data
                    ;
                    ; Code Checked 9/1/2025
                    ;
spawn_new_actor     ; original address L00003e74
                    movem.w (a0)+,d2-d4                             ; get 3 words of actor data 

.protection_check   ; L00003e78 - maybe protection check
                    cmp.w   $00000022,d0                            ; compare window X with value at $22.w (privilege violation vector - is set by Rob Northen protection)
.infinite_loop      beq.b   .infinite_loop                          
                    nop 

                    ; L00003e82 - find entry in list for the new actor
.alloc_list_entry   lea.l   actors_list,a6                          ; L000039c8,a6
                    moveq   #$09,d6                                 ; loop 10 times (max 10 active actors?)
.check_next_entry   ; L00003e88
                    tst.w   (a6)                                    ; look for blank entry
                    beq.b   initialise_new_actor
                    lea.l   ACTORLIST_STRUCT_SIZE(a6),a6            ; skip to next list entry
                    dbf.w   d6,.check_next_entry                    ; loop for 10 active actor entries
                    rts




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
                    ; Code Check 9/1/2025 - not understood yet
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

;actor_init_data     ; original address L00005a7a
;                            Actor Id?, Value
;L00005a7a           dc.w    $0004,$006b
;L00005a7e           dc.w    $0012,$0046
;L00005a82           dc.w    $0015,$0097
;L00005a86           dc.w    $0017,$0064
;L00005a8a           dc.w    $0018,$0085
;L00005a8e           dc.w    $001b,$00bc
;L00005a92           dc.w    $001f,$00c1
;L00005a96           dc.w    $00ff,$0000

initialise_new_actor ; original address L00003e96
                    move.l  a0,ACTORSTRUCT_INIT_PTR(a6)             ; offset 20 - (32 bit address) - store address of actor data struct
                    bset.l  #$0f,d2                                 ; set bit 15 - actor init data word 1 (disable?)
                    movem.w d2-d4,ACTORSTRUCT_INIT_DATA(a6)         ; offset 00 - store 3 actor init data words
                    clr.l   $0008(a6)
                    bclr.l  #$0f,d2                                 ; clear bit 15 - actor init data word 1 (enable?)
                    clr.l   $0010(a6)                               ; actor y top & bottom
 
                    ; L00003eae
                    lea.l   actor_init_data,a5                      ; L00005a7a,a5
L00003eb2           cmp.w   (a5)+,d2                                ; d2 = actor init data word 1
                    bcs.b   L00003eba                               ; if table entry > d2 
                    addq.l  #$02,a5                                 ; get next table entry
                    bra.b   L00003eb2                               ; loop next entry.

                    ; L00003eba
L00003eba           move.w  (a5),d3
                    cmp.w   #$0046,d3                           ; #$0046 is 2nd table entry
                    bne.b   L00003ed0
                    ; is 46 (2nd table entry)
                    bsr.w   L00003ed6                           ; d2 = psuedo random number
                    btst.l  #$000c,d2                           ; test bit 12
                    beq.b   L00003ed0
                    move.w  #$009e,d3

                    ; L00003ed0                                 ; all actors except 46 take table value
L00003ed0           move.w  d3,$0006(a6)                        ; apart from when bit 12 is 0
                    rts

                    ; L00003ed6
L00003ed6           movea.l L00006322,a1                        ; a ptr that points to code 'trigger_new_actors'
                    move.w  (a1)+,d2                            ; using code as a pseudo random number?
                    move.l  a1,L00006322
                    rts




                    ;-----------------------------------------------------------------------------------------------
                    ; -- Update Level Actors 02
                    ;-----------------------------------------------------------------------------------------------
                    ; called from game_loop every cycle.
                    ;
                    ; Code Checked 14/01/2025
                    ;
update_active_actors    ; original address L00003ee6
                    lea.l   actors_list,a6                              ; 24 byte struct, list of max 10 active actors
                    moveq   #$09,d7                                     ; actor count (10-1)

process_next_actor  ; L00003eec                                                     
                    move.w  (a6),d6                                     ; d6 = actor type/id?
                    beq.w   skip_to_next_actor

calc_actor_coords   ; L00003ef2
                    movem.w ACTORSTRUCT_XY(a6),d0-d1                    ; actor X,Y
                    move.w  d0,d4                                       ; d4 = actorX
                    movem.w scroll_window_xy_coords,d2-d3               ; d2,d3 = Scroll Window X & Y
                    sub.w   d2,d0                                       ; d0 = actorX - windowX
                    sub.w   d3,d1                                       ; d1 = actorY - windowY
actor_check_x       ; L00003f04
                    cmp.w   #$0140,d0                                   ; compare 320,d0 (screen width + 1 screen width)
                    bcs.b   actor_check_y                               ; L00003f10
                    cmp.w   #$ff60,d0                                   ; compare -160,d0 (-1 screen width)
                    bcs.b   forget_actor                                ; L00003f2e

actor_check_y       ; L00003f10
                    cmp.w   #$00a0,d1                                   ; compare 160,d1 (screen height + 1 screen height)
                    bcs.b   actor_in_range                              ; L00003f1c
                    cmp.w   #$ffb0,d1                                   ; compare -80,d1 (-1 screen height)
                    bcs.b   forget_actor                                ; L00003f2e

actor_in_range      ; L00003f1c
                    bclr.b  #$07,(a6)                                   ; test & clear
                    beq.b   execute_handler                             ; jmp if bit already clear (last execution before disabled?)
                    ; bit 7 was 1, then fall through

actor_in_display    ; L00003f22 check actor is in display window
                    cmp.w   #$0050,d1                       ; compare 80,d1 (y)
                    bcc.b   execute_handler                 ; jmp if d1 > 80 (I guess off screen)

                    cmp.w   #$00a0,d0                       ; compare 160,d0 (x)
                    bcc.b   execute_handler                 ; jmp id d0 > 160 (I guess offscreen)

forget_actor        ; L00003f2e - actor is out of bounds forget about it
                    cmp.w   #$0014,d6
                    bcs.b   remove_actor                    ; if actor type <= 14 then remove_actor

                    ; this code kills off actors out of scene
                    ; looks like it may kill-off the actor
                    ; jsr     _DEBUG_COLOURS
                    lea.l   $00000000,a0                    ; clear a0
                    movea.l d0,a0                           ; store actor x in a0?
                    movea.l ACTORSTRUCT_INIT_PTR(a6),a0     ; a0 = actor data ptr - conveted to 32 bit address
                    bclr.b  #$07,-$0002(a0)                 ; reenable actor

remove_actor        ; L00003f44 - remove actor
                    clr.w   (a6)                            ; take actor out of the list
                    bra.b   skip_to_next_actor              ; L00003fa8

execute_handler     ; L00003f48 - execute actor handler                 ; original address L00003f48
                    lea.l   actor_handler_table,a0          ; jmp table
                    add.w   d6,d6                           ; convert index to word value
                    add.w   d6,d6                           ; convert index to word value
;                    adda.w  d6,a0                           ; add word value to address - jmp table index (word table)
                    adda.w  d6,a0                           ; add word value to address - jmp table index (long table) - additional line of code (jmp table converted to long from word)
                    movea.l (a0),a0                         ; code change  (jmp table converted to long from word)
                    move.w  d7,-(a7)                        ; store loop count on stack
                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
                    jsr     (a0)                ; L00003f54


                    ; L00003f56 - check batman collision with actor?
L00003f56           movem.w $000e(a6),d0-d2         ; actor x,y
L00003f5c           sub.w   batman_x_offset,d0
L00003f60           addq.w  #$06,d0
L00003f62           cmp.w   #$000d,d0
L00003f66           bcc.b   end_L00003fa6

                    ; L00003f68
L00003f68           sub.w   batman_y_bottom,d1              ; L000062f0,d1
L00003f6c           subq.w  #$06,d1
L00003f6e           bmi.b   end_L00003fa6

                    ; L00003f70
L00003f70           sub.w   batman_y_offset,d2
L00003f74           bpl.b   end_L00003fa6

                    ; L00003f76
L00003f76           move.w  (a6),d0
L00003f78           subq.w  #$02,d0
L00003f7a           bmi.b   end_L00003fa6

                    ; L00003f7c
L00003f7c           move.w  #$0001,(a6)
L00003f80           moveq   #SFX_GUYHIT,d0
L00003f82           jsr     AUDIO_PLAYER_INIT_SFX
L00003f88           move.w  #$fffe,$000a(a6)

L00003f8e           tst.w   L000062fa
L00003f92           bmi.b   end_L00003fa6

                    ; L00003f94
L00003f94           tst.w   grappling_hook_height           ; L00006318
L00003f98           beq.b   L00003fa0

                    ; L00003f9a
L00003f9a           tst.w   batman_swing_speed              ; L000062f4
L00003f9e           bne.b   end_L00003fa6

                    ; L00003fa0
L00003fa0           moveq   #$05,d6                         ; Value of Energy to Lose (5 of 48)
L00003fa2           bsr.w   batman_lose_energy

                    ; L00003fa6
end_L00003fa6       move.w  (a7)+,d7                        ; pop loop counter from the stack


skip_to_next_actor  ; L00003fa8 - increment data struct ptr to next actor           ; original address L00003fa8
                   lea.l   ACTORLIST_STRUCT_SIZE(a6),a6
                   dbf.w   d7,process_next_actor                       ; loop upto 10 times - do next active actor
                   rts



                    ; ---------- calculate grenade inital drop speed ----------
                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
                    ;
                    ; Code Checked 14/01/2025
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
calc_grenade_speed  ; L00003fb2
L00003fb2           add.w   #$0002,(a6)                     ; add 2 to actor status/id
L00003fb6           movem.w batman_x_offset,d2
L00003fbc           move.w  batman_y_bottom,d3              ; L000062f0,d3
L00003fc0           add.w   #$0015,d3                       ; window y + 21
L00003fc4           sub.w   d1,d3                           ; d3 = batman distance from bottom window
L00003fc6           asl.w   #$03,d3                         ; d3 = multiply by 8
L00003fc8           ext.l   d3                              ; d3 = sign extend to long

L00003fca           sub.w   d0,d2                           ; d2 = x distance from batman
L00003fcc           bpl.b   L00003fd0
L00003fce           neg.w   d2                              ; make distance +ve
L00003fd0           beq.b   L00003fd4                       ; iif zero distance, skip divide by 0
L00003fd2           divs.w  d2,d3                           ; d3 = divide x distance by batman ditance from window y 
L00003fd4           asr.w   #$02,d2                         ; divide x distance by 4 (8 pixels)
L00003fd6           sub.w   d2,d3                           ; subtract from d3

L00003fd8           bsr.w   get_empty_projectile            ; a0 = empty projectile list entry or end of the list - L0000463e
L00003fdc           cmp.w   #$0008,d3
L00003fe0           bcs.b   L00003ff0                       ; if distance < 8, $3ff0
L00003fe2           bmi.b   L00003fe8                       ; if negative flag, $3fe8
L00003fe4           moveq.l #$08,d3                         ; clamp d3 to 8
L00003fe6           bra.b   L00003ff0

L00003fe8           cmp.w   #$ffe8,d3                       ; -24
L00003fec           bcc.b   L00003ff0                       ; if > -24
L00003fee           moveq.l  #$e8,d3                        ; clamp d3 to -24

L00003ff0           move.w  d3,$0006(a0)                    ; set projectile parameter
L00003ff4           cmp.w   #$0073,d1                       
L00003ff8           bpl.b   L0000400a                       ; if batman y bottom < 115, then exit
L00003ffa           movem.w d0-d1,-(a7)                     ; play sfx
L00003ffe           moveq.l #SFX_GRENADE,d0
L00004000           jsr     AUDIO_PLAYER_INIT_SFX
L00004006           movem.w (a7)+,d0-d1
L0000400a           rts



                    ; ---------------------- actor throw a grenade left ------------------
                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
                    ;
                    ; Code Checked 16/01/2025
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

actor_cmd_grenade_left_01
actor_cmd_05        ; L0000400c
                    ; do throw animation
L0000400c           move.w  ACTORSTRUCT_ANIMFRAME(a6),d2    ; d2 = animation index
L00004010           cmp.w   #$0007,d2                       ; compare last animation frame
L00004014           bne.b   L0000402e

                    ; do create new grenade
L00004016           subq.w  #$05,d0                     ; actor display x - 5
L00004018           bsr.w   calc_grenade_speed          ; out: a0 = new projectile - L00003fb2
L0000401c           move.w  #$000d,(a0)+                ; set projectile handler id (13)
L00004020           move.w  d1,d3
L00004022           sub.w   #$0011,d3                   ; grenade y
L00004026           movem.w d0/d3,(a0)                  ; store grenade x & y
L0000402a           addq.w  #$05,d0

                    ; draw final actor animation frame
L0000402c           moveq.l #$08,d2                     ; final animation index (8th entry)
                    ; draw actor animation frame
L0000402e           addq.w  #$01,$0008(a6)
L00004032           lea.l   badguy_actor_anim,a5        ; L000044d4,a5                ; sprite animation
L00004036           and.w   #$00fe,d2                   ; clamp d2
L0000403a           adda.w  d2,a5
L0000403c           add.w   d2,d2
L0000403e           adda.w  d2,a5
L00004040           bra.w   drawcollide_actor_sprites_a5    ; draw 3 sprites at specified table address
                    ; use rts in 'drawcollide_actor_sprites_a5' to return




                    ; called when green-guy throws a grenade
                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
                    ;
                    ; Code Checked 14/01/2025
                    ;
actor_cmd_grenade_left_02
actor_cmd_07        ; L00004044
L00004044           lea.l   throw_grenade_left,a5           ;L000044ec,a5
L00004048           bsr.w   drawcollide_actor_sprites_a5               ; L0000457c
L0000404c           subq.w  #$01,$0008(a6)
L00004050           bne.b   L0000405c                       ; if > 0, then exit
L00004052           move.w  #$0020,$0008(a6)                ; delay parameter (before throwing again)
L00004058           move.w  #$0002,(a6)                     ; actor status = 2
L0000405c           rts




                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
actor_cmd_green_walk_left
actor_cmd_03        ;move.w  #$f00,$dff180
L0000405e           cmp.w   #$ffc0,d0
L00004062           bmi.b   L000040b0
L00004064           subq.w  #$01,$0008(a6)
L00004068           bpl.b   L00004082
L0000406a           move.w  d0,d2
L0000406c           sub.w   batman_x_offset,d2
L00004070           cmp.w   #$0030,d2
L00004074           bcc.b   L00004082
L00004076           clr.w   $0008(a6)
L0000407a           move.w  #$0005,(a6)
L0000407e           bra.w   L0000431e

L00004082           moveq   #$07,d2
L00004084           and.w   d4,d2
L00004086           bne.w   L00004318
L0000408a           sub.w   #$000c,d0
L0000408e           bsr.w   get_map_tile_at_display_offset_d0_d1            ; out: d2.b = tile value
L00004092           add.w   #$000c,d0
L00004096           cmp.b   #$79,d2
L0000409a           bcc.w   L00004318
L0000409e           tst.w   $0008(a6)
L000040a2           bpl.b   L000040b0
L000040a4           move.w  d0,d2
L000040a6           sub.w   batman_x_offset,d2
L000040aa           cmp.w   #$0040,d2
L000040ae           bcs.b   L00004076

L000040b0           move.w  #$0002,(a6)
L000040b4           bra.w   L0000431e


                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
actor_cmd_grenade_right_01
actor_cmd_04        ;move.w  #$f00,$dff180
L000040b8           move.w  $0008(a6),d2
L000040bc           cmp.w   #$0007,d2
L000040c0           bne.b   L000040da
L000040c2           addq.w  #$05,d0
L000040c4           bsr.w   calc_grenade_speed                  ; out: a0 - projectile - L00003fb2
L000040c8           move.w  #$000c,(a0)+
L000040cc           move.w  d1,d3
L000040ce           sub.w   #$0011,d3
L000040d2           movem.w d0/d3,(a0)
L000040d6           subq.w  #$05,d0
L000040d8           moveq   #$08,d2
L000040da           addq.w  #$01,$0008(a6)
L000040de           lea.l   throw_grenade_right,a5          ;L000044f2,a5
L000040e2           and.w   #$00fe,d2
L000040e6           adda.w  d2,a5
L000040e8           add.w   d2,d2
L000040ea           adda.w  d2,a5
L000040ec           bra.w   drawcollide_actor_sprites_a5               ; L0000457c



                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
actor_cmd_grenade_right_02
actor_cmd_06        ;move.w  #$0f0,$dff180
L000040f0           lea.l   L0000450a,a5
L000040f4           bsr.w   drawcollide_actor_sprites_a5               ; L0000457c
L000040f8           subq.w  #$01,$0008(a6)
L000040fc           bne.b   L00004108
L000040fe           move.w  #$0020,$0008(a6)
L00004104           move.w  #$0003,(a6)
L00004108           rts



                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
actor_cmd_green_walk_right
actor_cmd_02        ;move.w  #$00f,$dff180
L0000410a           cmp.w   #$00e0,d0
L0000410e           bpl.b   L00004158
L00004110           subq.w  #$01,$0008(a6)
L00004114           bpl.b   L0000412e
L00004116           move.w  batman_x_offset,d2
L0000411a           sub.w   d0,d2
L0000411c           cmp.w   #$0030,d2
L00004120           bcc.b   L0000412e
L00004122           clr.w   $0008(a6)
L00004126           move.w  #$0004,(a6)
L0000412a           bra.w   L00004248

L0000412e           moveq   #$07,d2
L00004130           and.w   d4,d2
L00004132           bne.w   L00004242
L00004136           addq.w  #$08,d0
L00004138           bsr.w   get_map_tile_at_display_offset_d0_d1            ; d2.b = tile value
L0000413c           subq.w  #$08,d0
L0000413e           cmp.b   #$79,d2
L00004142           bcc.w   L00004242
L00004146           tst.w   $0008(a6)
L0000414a           bpl.b   L00004158
L0000414c           move.w  batman_x_offset,d2
L00004150           sub.w   d0,d2
L00004152           cmp.w   #$0040,d2
L00004156           bcs.b   L00004122
L00004158           move.w  #$0003,(a6)
L0000415c           bra.w   L00004248
L00004160           move.w  batman_y_offset,d5
L00004164           sub.w   d1,d5
L00004166           add.w   #$0010,d5
L0000416a           cmp.w   #$0020,d5
L0000416e           bcs.b   L000041a0
L00004170           bpl.b   L00004184
L00004172           move.w  MAPGR_BASE,d2        ; MAPGR.IFF (Value = $00c0)
L00004178           add.w   d2,d2
L0000417a           add.w   d2,d2
L0000417c           sub.w   d2,d3
L0000417e           clr.w   d2
L00004180           move.b  $00(a0,d3.W),d2
L00004184           cmp.b   #$85,d2
L00004188           bcs.b   L000041a0
L0000418a           move.w  #$0002,$0008(a6)
L00004190           move.w  #$000d,$000c(a6)
L00004196           subq.w  #$08,d5
L00004198           bpl.b   L000041a0
L0000419a           move.w  #$000c,$000c(a6)
L000041a0           rts


                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
actor_cmd_actor_brown_walk_right
actor_cmd_14        ;move.w  #$f00,$dff180
L000041a2           move.w  d4,d2
L000041a4           addq.w  #$04,d2
L000041a6           and.w   #$0007,d2
L000041aa           bne.w   L00004242
L000041ae           cmp.w   #$0140,d0
L000041b2           bpl.b   L000041c2
L000041b4           addq.w  #$07,d0
L000041b6           bsr.w   get_map_tile_at_display_offset_d0_d1            ; out: d2.b = tile value
L000041ba           subq.w  #$07,d0
L000041bc           cmp.b   #$79,d2
L000041c0           bcc.b   L000041ce
L000041c2           move.w  #$000f,(a6)
L000041c6           clr.w   $0008(a6)
L000041ca           bra.w   L00004242
L000041ce           bsr.w   L00004160
L000041d2           subq.w  #$01,$0008(a6)
L000041d6           beq.w   L00004348
L000041da           bpl.b   L00004242
L000041dc           move.w  batman_x_offset,d2
L000041e0           sub.w   d0,d2
L000041e2           bmi.b   L00004242
L000041e4           cmp.w   #$0020,d5
L000041e8           bpl.b   L00004224
L000041ea           bcc.b   L00004202
L000041ec           cmp.w   #$0038,d2
L000041f0           bcc.b   L00004242
L000041f2           move.w  #$0010,$000c(a6)
L000041f8           move.l  #$00010000,$0008(a6)        ; External Address?
L00004200           bra.b   L00004242
L00004202           sub.w   #$0010,d5
L00004206           add.w   d5,d2
L00004208           ble.b   L00004242
L0000420a           subq.w  #$04,d2
L0000420c           lsr.w   #$03,d2
L0000420e           addq.w  #$01,d2
L00004210           cmp.w   #$0008,d2
L00004214           bcc.b   L00004242
L00004216           move.w  d2,$0008(a6)
L0000421a           move.l  #$00050010,$000a(a6)        ; External Address? - CHEM.IFF
L00004222           bra.b   L00004242
L00004224           subq.w  #$08,d5
L00004226           sub.w   d5,d2
L00004228           bls.b   L00004242
L0000422a           subq.w  #$04,d2
L0000422c           lsr.w   #$03,d2
L0000422e           addq.w  #$01,d2
L00004230           cmp.w   #$0008,d2
L00004234           bcc.b   L00004242
L00004236           move.w d2,$0008(a6)
L0000423a           move.l #$00070010,$000a(a6)         ; External Address?
L00004242           addq.w #$01,d4
L00004244           move.w d4,$0002(a6)
L00004248           and.w   #$000e,d4
L0000424c           lsr.w   #$01,d4
L0000424e           move.w  d4,-(a7)
L00004250           addq.w  #$08,d4
L00004252           move.w  d4,d2
L00004254           bsr.w   draw_next_sprite            ; L000045bc
L00004258           move.w  (a7)+,d2
L0000425a           lsr.w   #$01,d2
L0000425c           bne.b   L00004260
L0000425e           addq.w  #$02,d2
L00004260           addq.w  #$04,d2
L00004262           bsr.w   draw_next_sprite            ; L000045bc
L00004266           moveq   #$04,d2
L00004268           bra.w   actor_collision_and_sprite1         ; L0000458a



                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
actor_cmd_brown_walk_left
actor_cmd_15_23     ;move.w  #$0f0,$dff180
L0000426c           move.w  d4,d2
L0000426e           addq.w  #$04,d2
L00004270           and.w   #$0007,d2
L00004274           bne.w   L00004318
L00004278           cmp.w   #$ff60,d0
L0000427c           bmi.b   L00004298
L0000427e           subq.w  #$07,d0
L00004280           bsr.w   get_map_tile_at_display_offset_d0_d1        ; out: d2.b = tile value
L00004284           addq.w  #$07,d0
L00004286           cmp.b   #$79,d2
L0000428a           bcc.b   L000042a4
L0000428c           move.w  $0006(a6),d2
L00004290           cmp.w   #$0085,d2
L00004294           beq.w   L0000440a
L00004298           move.w  #$000e,(a6)
L0000429c           clr.w   $0008(a6)
L000042a0           bra.w   L00004318
L000042a4           bsr.w   L00004160
L000042a8           subq.w  #$01,$0008(a6)
L000042ac           beq.w   L00004348
L000042b0           bpl.b   L00004318
L000042b2           move.w  d0,d2
L000042b4           sub.w   batman_x_offset,d2
L000042b8           bmi.b   L00004318
L000042ba           cmp.w   #$0020,d5
L000042be           bpl.b   L000042fa
L000042c0           bcc.b   L000042d8
L000042c2           cmp.w   #$0038,d2
L000042c6           bcc.b   L00004318
L000042c8           move.w  #$0010,$000c(a6)
L000042ce           move.l  #$00010001,$0008(a6)            ; External Address ?
L000042d6           bra.b   L00004318
L000042d8           sub.w   #$0010,d5
L000042dc           add.w   d5,d2
L000042de           ble.b   L00004318
L000042e0           subq.w  #$04,d2
L000042e2           lsr.w   #$03,d2
L000042e4           addq.w  #$01,d2
L000042e6           cmp.w   #$0008,d2
L000042ea           bcc.b   L00004318
L000042ec           move.w  d2,$0008(a6)
L000042f0           move.l  #$00040010,$000a(a6)            ; External Address ?
L000042f8           bra.b   L00004318
L000042fa           subq.w  #$08,d5
L000042fc           sub.w   d5,d2
L000042fe           bls.b   L00004318
L00004300           subq.w  #$04,d2
L00004302           lsr.w   #$03,d2
L00004304           addq.w  #$01,d2
L00004306           cmp.w   #$0008,d2
L0000430a           bcc.b   L00004318
L0000430c           move.w  d2,$0008(a6)
L00004310           move.l  #$00060010,$000a(a6)            ; External Address ?
L00004318           subq.w  #$01,d4
L0000431a           move.w  d4,$0002(a6)
L0000431e           and.w   #$000e,d4
L00004322           lsr.w   #$01,d4
L00004324           eor.w   #$e007,d4
L00004328           move.w  d4,-(a7)
L0000432a           addq.w  #$08,d4
L0000432c           move.w  d4,d2
L0000432e           bsr.w   draw_next_sprite                ; L000045bc
L00004332           move.w  (a7)+,d2
L00004334           lsr.b   #$01,d2
L00004336           bne.b   L0000433a
L00004338           addq.w  #$02,d2
L0000433a           addq.w  #$04,d2
L0000433c           bsr.w   draw_next_sprite                ; L000045bc
L00004340           move.w  #$e004,d2
L00004344           bra.w   actor_collision_and_sprite1         ; L0000458a
L00004348           move.w  $000c(a6),d6
L0000434c           move.w  d6,(a6)
L0000434e           cmp.w   #$0010,d6
L00004352           bne.b   L00004374
L00004354           move.w  #$0002,$0008(a6)
L0000435a           move.w  $000a(a6),d2
L0000435e           cmp.w   #$0002,d2
L00004362           bcc.b   L00004374
L00004364           move.w  $0012(a6),d2
L00004368           addq.w  #$04,d2
L0000436a           sub.w   batman_y_bottom,d2              ; L000062f0,d2
L0000436e           bpl.b   L00004374
L00004370           addq.w  #$02,$000a(a6)

L00004374           lea.l   actor_handler_table,a0          ; L00005a9a,a0                    ; jmp table
L00004378           add.w   d6,d6                           ; convert index to word value
L00004378a          add.w   d6,d6                           ; convert index to long value
L0000437a           adda.w  d6,a0                           ; add word value to address - jmp table index (word table)
;L0000437a1          adda.w  d6,a0                           ; add word value to address - jmp table index (long table) - additional line of code (jmp table converted to long from word)
;L0000437c           movea.w (a0),a0
L0000437c           movea.l (a0),a0                         ; code change  (jmp table converted to long from word)
L0000437e           jmp     (a0)


                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
actor_cmd_climb_down_ladder
actor_cmd_13        ;move.w  #$00f,$dff180
L00004380           move.w  $0004(a6),d4
L00004384           btst.b  #$0000,playfield_swap_count+1           ; test even/odd playfield buffer swap value
L0000438a           bne.b   L000043ce
L0000438c           addq.w  #$01,d4
L0000438e           move.w  d4,$0004(a6)
L00004392           addq.w  #$01,d1
L00004394           and.w   #$0007,d4
L00004398           bne.b   L000043ce
L0000439a           bsr.w   get_map_tile_at_display_offset_d0_d1        ; out: d2.b = tile value
L0000439e           bra.b   L000043c6


                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
actor_cmd_climb_up_ladder
actor_cmd_12        ;move.w  #$f00,$dff180
L000043a0           move.w  $0004(a6),d4
L000043a4           btst.b  #$0000,playfield_swap_count+1           ; test even/odd playfield buffer swap value
L000043aa           bne.b   L000043ce
L000043ac           subq.w  #$01,d4
L000043ae           move.w  d4,$0004(a6)
L000043b2           subq.w  #$01,d1
L000043b4           and.w   #$0007,d4
L000043b8           bne.b   L000043ce
L000043ba           sub.w   #$0018,d1
L000043be           bsr.w   get_map_tile_at_display_offset_d0_d1        ; out: d2.b = tile value
L000043c2           add.w   #$0018,d1

actor_cmd_climb_ladder_common
L000043c6           cmp.b   #$85,d2
L000043ca           bcc.b   L000043ce
L000043cc           bsr.b   L000043fc
L000043ce           not.w   d4
L000043d0           and.w   #$0007,d4
L000043d4           subq.w  #$01,d0
L000043d6           move.w  d4,d2
L000043d8           bclr.l  #$0002,d2
L000043dc           beq.b   L000043e4
L000043de           or.w    #$e000,d2
L000043e2           addq.w  #$01,d0
L000043e4           add.w   #$001b,d2
L000043e8           move.w  d2,-(a7)
L000043ea           bsr.w   draw_next_sprite                ; L000045bc
L000043ee           move.w  (a7)+,d2
L000043f0           and.w   #$e000,d2
L000043f4           add.w   #$001a,d2
L000043f8           bra.w   actor_collision_and_sprite1     ; L0000458a
L000043fc           moveq   #$07,d2
L000043fe           moveq   #$4c,d3
L00004400           sub.w   d0,d3
L00004402           add.w   d3,d3
L00004404           addx.w  d2,d2
L00004406           move.w  d2,(a6)
L00004408           rts

L0000440a           move.w  #$ffff,$0008(a6)
L00004410           moveq   #$06,d2
L00004412           cmp.w   batman_y_bottom,d1              ; L000062f0,d1
L00004416           bmi.b   L00004428
L00004418           moveq   #$01,d2
L0000441a           move.w  $0012(a6),d3
L0000441e           addq.w  #$04,d3
L00004420           cmp.w   batman_y_bottom,d2              ; L000062f0,d3
L00004424           bpl.b   L00004428
L00004426           addq.w  #$02,d2
L00004428           move.w  d2,$000a(a6)
L0000442c           move.w  #$0010,(a6)


                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
actor_cmd_shooting_diagonally_01
actor_cmd_16        ;move.w  #$0f0,$dff180
L00004430           bsr.w   drawcollide_sprites_from_actor_list_struct_0a   ; L00004570
L00004434           subq.w  #$01,$0008(a6)
L00004438           bpl.b   L00004442
L0000443a           addq.w  #$01,(a6)
L0000443c           move.w  #$0003,$0008(a6)
L00004442           rts


                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
actor_cmd_shooting_diagonally_02
actor_cmd_17        ;move.w  #$f00,$dff180
L00004444           bsr.w   drawcollide_sprites_from_actor_list_struct_0a   ; L00004570
L00004448           btst.b  #$0000,playfield_swap_count+1           ; test even/odd playfield buffer swap value
L00004450           bne.b   L00004442
L00004452           bsr.w   get_empty_projectile                    ; a0 = empty projectile entry or the end of the list - L0000463e
L00004456           sub.w   (a5)+,d1
L00004458           add.w   vertical_scroll_increments,d1           ; L00006310,d1
L0000445c           add.w   (a5)+,d0
L0000445e           add.w   L0000630e,d0
L00004462           move.w  (a5),(a0)+
L00004464           movem.w d0-d1,(a0)
L00004468           moveq   #SFX_Ricochet,d2
L0000446a           bsr.w   play_proximity_sfx                      ; play sfx if d0 < 160 & d1 < 89
L0000446e           subq.w  #$01,$0008(a6)
L00004472           bne.b   L00004442
L00004474           move.w  #$0006,$0008(a6)
L0000447a           addq.w  #$01,(a6)
L0000447c           rts 


                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
actor_cmd_shooting_horizontal
actor_cmd_18        ;move.w  #$f00,$dff180
L0000447e           bsr.w   drawcollide_sprites_from_actor_list_struct_0a   ; L00004570
L00004482           subq.w  #$01,$0008(a6)
L00004486           bne.b   L00004442
L00004488           move.w  #$0004,$0008(a6)
L0000448e           move.w  $000a(a6),d2
L00004492           move.w  $0006(a6),d3
L00004496           cmp.w   #$0085,d3
L0000449a           bne.b   L000044a0
L0000449c           move.w  #$0001,d2
L000044a0           not.w   d2
L000044a2           and.w   #$0001,d2
L000044a6           add.w   #$000e,d2
L000044aa           move.w  d2,(a6)
L000044ac           move.w  d2,$000c(a6)
L000044b0           move.w $0002(a6),d4
L000044b4           rts


                    ; ------------------- play proximity sfx ---------------------
                    ; Play SFX if X & Y co-ordinates within range
                    ; IN:-
                    ;   d0.w = probably X distance
                    ;   d1.w = probably Y distance
                    ;   d2 = sfx number to play 5 - 13
play_proximity_sfx                                                  ; original address L000044b6
                    cmp.w   #$00a0,d0
                    bcc.b   .exit
                    cmp.w   #$0059,d1
                    bcc.b   .exit
                    movem.w d0-d1,-(a7)
                    move.w  d2,d0                                   ; d0 = sfx number to play
                    jsr     AUDIO_PLAYER_INIT_SFX       
                    movem.w (a7)+,d0-d1
.exit           
                    rts


                    ; bad-guy - actor animation frames (left)
badguy_actor_anim   ; L000044d4
L000044d4           dc.w    $e004,$e005,$e008
L000044da           dc.w    $e010,$e011,$0000
                    dc.w    $e012,$e011,$0000
                    dc.w    $e013,$e014,$e011
throw_grenade_left                                  ; final animation frame?
L000044ec           dc.w    $e015,$e016,$e011

throw_grenade_right
L000044f2           dc.w    $0004,$0005,$0008
L000044f8           dc.w    $0010,$0011,$0000
                    dc.w    $0012,$0011,$0000
L00004504           dc.w    $0013,$0014,$0011
L0000450a           dc.w    $0015,$0016,$0011


; 12 byte sprite id structure 
;   Offset
;   0-1     - Sprite 1 Id
;   2-3     - Sprite 2 Id
;   4-5     - Sprite 3 Id
;   6-7     - ?????
;   8-9     - ?????
;   10-11   - ?????
actor_sprite_ids    ; original address 
L00004510           dc.w    $0010,$0011,$0012,$0012,$0008,$8006
L0000451c           dc.w    $e010,$e011,$e012,$0012,$fff8,$8007
L00004528           dc.w    $0017,$0018,$0019,$000e,$0008,$8006
L00004534           dc.w    $e017,$e018,$e019,$000e,$fff8,$8007
L00004540           dc.w    $e013,$e014,$e012,$0012,$fffd,$800b
L0000454c           dc.w    $0013,$0014,$0012,$0012,$0003,$800a
L00004558           dc.w    $e015,$e016,$e012,$000c,$fffb,$8009
L00004564           dc.w    $0015,$0016,$0012,$000c,$0005,$8008



                    ; ---------------------- draw and collide actor sprites ------------------------
                    ; Draws actor sprites using an offset specified in the 'actor list structure'
                    ; offset is a word at byte  offset #$0a (10)
                    ; 
                    ; IN:-
                    ;   a6 = actor list structure ptr
                    ;
drawcollide_sprites_from_actor_list_struct_0a
L00004570           move.w  ACTORSTRUCT_SPRITES_IDX(a6),d2      ; offset #$000a into actors_list structure               
L00004574           mulu.w  #$000c,d2                           ; structure 12 bytes in size
L00004578           lea.l   actor_sprite_ids(pc,d2.W),a5        ; table containing sprite data (12 byte struct, 1st 3 words sprite ids)
                    ; fall through to 'drawcollide_actor_sprites_a5' below...

                    ; ----------------------- draw and collide sprites ids --------------------------
                    ; draw and collide sprites using 3 word ids specified by address a5.
                    ;
                    ; IN:-
                    ;   a5 = address ptr to 3 sprite ids
                    ;
drawcollide_actor_sprites_a5  ; L0000457c - draw 3 actor sprites 3 ids at address a5
L0000457c           move.w  (a5)+,d2
L0000457e           bsr.b   actor_collision_and_sprite1     ; L0000458a
L00004580           move.w  (a5)+,d2
L00004582           bsr.b   draw_next_sprite                ; L000045bc
L00004584           move.w  (a5)+,d2
L00004586           bne.b   draw_next_sprite                ; L000045bc
L00004588           rts 




                    ; do bad guy collision
                    ; draw bad guy head/sprite 1
actor_collision_and_sprite1 ; original address L0000458a
L0000458a          
                    add.w   $0006(a6),d2        ; $00dff006
L0000458e           move.w  d2,d3
L00004590           and.w   #$1fff,d3           ; clamp value to max $1fff
L00004594           lsl.w   #$01,d3
L00004596           lea.l   display_object_coords,a0        ; L0000607c,a0
L0000459a           move.w  d1,d4
L0000459c           add.w   d4,d4
L0000459e           move.b  -$2(a0,d3.W),d5     ; $00000d11
L000045a2           ext.w   d5
L000045a4           sub.w   d5,d4
L000045a6           asr.w   #$01,d4
L000045a8           movem.w d0-d1/d4,$000e(a6)  ; update Sprite X, Y and Id to offset 14
                    ;  draw sprite
L000045ae           movem.w d0-d1/a5-a6,-(a7)
L000045b2           bsr.w   draw_sprite         ; draw top/head of bad guy  ; L000056f4
L000045b6           movem.w (a7)+,d0-d1/a5-a6
L000045ba           rts 


                    ; IN:-
                    ;   d0.w - Sprite X Position
                    ;   d1.w - Sprite Y Position
                    ;   d2.w - current sprite id
                    ;   a6.l - address of object/sprite struct
                    ; OUT:
                    ;   d2.w - updated sprite id
draw_next_sprite    ; original address L000045bc
L000045bc           add.w   $0006(a6),d2                                ; set sprite id
L000045c0           movem.w d0-d1/a5-a6,-(a7)
L000045c4           bsr.w   draw_sprite                                 ; d0.w - Sprite X Position, d1.w - Sprite Y Position,  d2.w - Sprite id
L000045c8           movem.w (a7)+,d0-d1/a5-a6
L000045cc           rts 




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
actor_cmd_falling   ; L000045ce
L000045ce           move.w  $000a(a6),d2            ; $00dff00a
L000045d2           addq.w  #$01,d2
L000045d4           cmp.w   #$000e,d2
L000045d8           bpl.b   L000045de
L000045da           move.w  d2,$000a(a6)            ; $00dff00a
L000045de           asr.w   #$01,d2
L000045e0           add.w   d2,$0004(a6)            ;$00dff004
L000045e4           lea.l   L000062de,a5
L000045e8           cmp.w   #$0064,d1
L000045ec           bmi.w   drawcollide_actor_sprites_a5   ; L0000457c
L000045f0           clr.w   (a6)
L000045f2           move.l  #$00000350,d0
L000045f8           jmp     PANEL_ADD_SCORE         ; ; Panel Add Player Score (D0.l BCD value to add)- $0007c82a
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
                    ; Code Checked 2/1/2025
                    ;
draw_projectiles    ; original address L000045fe
                    ;lea.l   projectile_jmp_table,a5         ; Unused here.
                    lea.l   projectile_list,a6              ; (Handler Index, X, Y, Grenade Acceleration)
                    moveq   #$13,d7                         ; d7 = 19 + 1 - counter (list of 20 entries)

.loop               ; L00004608
                    move.w  (a6)+,d2                        ; d2 = handler index (0 = unused/disabled)
                    beq.b   .skip_to_next                   ; if disabled then, skip_to_next

                    movem.w (a6),d0-d1                      ; d0,d1 = projectile X, Y
                    move.l  a6,-(a7)                        ; stash list ptr on stack for later.   
                    move.w  d7,-(a7)                        ; stash loop counter on stack for later.
                    btst.l  #$000f,d2                       ;   test sign bit 15 of handler index.
                    beq.b   .set_left_right                 ; if >= 0 then jmp set left/right facing

.negative_handler_index ; L0000461a                         ; else handler index < 0 then ...
                    ext.w   d2                              ;       make word +ve again
                    move.w  d2,-$0002(a6)                   ;       store in projectile handler
                    moveq   #$04,d2                         ;       set sprite index to #$04

.set_left_right     ; L00004622
                    ror.w   #$01,d2                         ;  divide by 2 and set sign bit if odd
                    bpl.b   .draw_sprite                    ;  test d2 is >= 0                                                    
                    or.w    #$e000,d2                       ;  if < 0 then set sprite direction left facing

.draw_sprite        ; L0000462A
                    add.w   #$003b,d2                       ; Add base projectile sprite id
                    bsr.w   draw_sprite                     ; Draw projectile sprite

                    move.w  (a7)+,d7                        ; restore counter - d7
                    movea.l (a7)+,a6                        ; restore data ptr - a6

.skip_to_next       ; L00004636
                    add.l   #PROJECTILE_LISTITEM_SIZE-2,a6  ; a6 = start next structure in list  (a6 + 6)    
                    dbf.w   d7,.loop                        
                    rts





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
                    ; Code Checked 2/1/2025
                    ;
get_empty_projectile    ; original address L0000463e
                    lea.l   projectile_list,a0      
                    moveq   #$13,d7                 ; loop counter (20 times)
.next_projectile     ; L00004644
                    tst.w   (a0)                    ; test projectile entry
                    beq.b   .exit                   ; if end of list then exit
                    lea.l   $0008(a0),a0            ; skip to next projectile entry in the list
                    dbf.w   d7,.next_projectile     ; L00004644
.not_found          ; L00004650
                    movea.l #$fffffff8,a0           ; a0 = ptr to last list entry.
.exit               ; L00004656
                    rts





                    ;-------------------------------------------------------------------------------------
                    ; -- Update the Projectiles (bombs, bullets, player's batarang)
                    ;-------------------------------------------------------------------------------------
                    ; update projectiles on the level, including the player's projectiles
                    ; it does not draw them..
                    ;
                    ; Code Checked: 2/1/2025
                    ;
update_projectiles  ; original address L00004658
                    lea.l   projectile_jmp_table,a5
                    lea.l   projectile_list,a6                  ; 'active' projectiles list
                    moveq   #$13,d7                             ; 19 + 1 - loop counter
.update_loop        ; L00004662
                    move.w  (a6)+,d6                            ; d6 = 1 based 'handler' index into address jmp table L00004866
                    beq.b   .skip_to_next
.do_projectile      ; L00004666
                    movem.w (a6),d0-d1                          ; d0,d1 = X, Y
                    sub.w   L0000630e,d0                        ; sub X scroll value?
                    sub.w   vertical_scroll_increments,d1       ; sub Y scroll value 
                    asl.w   #$02,d6                             ; modified address table to 32 bit addresses, original code 'asl.w #$01,d6'
                    clr.l   d2                                  ; clear d2
                    movea.l d2,a0                               ; clear a0
                    movea.l -$4(a5,d6.w),a0                     ; modified address table to 32 bit addresses, original code 'movea.w $fe(a5,d6.W),a0' 
                    jsr     (a0)
.skip_to_next       ;  L0000467e
                    addq.l  #$06,a6                             ; increase ptr 6 + 2 (8 bytes structure)
                    dbf.w   d7,.update_loop
                    rts




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
                    ; Code Checked 2/1/2025
                    ;
badguy_shooting     ; L00004686
                    movem.w d0-d1,(a6)                              ; store updated X,Y co-ords
                    bsr.w   get_map_tile_at_display_offset_d0_d1    ; out: d2.b = tile value
                    cmp.b   #$17,d2                                 ; bullet hit wall?
                    bcs.b   end_bullet                              ; .. yes, then set end bullet handler id
check_batman_collision ; L00004694                                  ; .. no
                    sub.w   batman_x_offset,d0                      ; .. no
                    addq.w  #$04,d0                                 ; 8 pixel width hit box?
                    cmp.w   #$0009,d0                               ; if not within 8 pixels, exit
                    bcc.b   exit_badguy_shooting
                    cmp.w   batman_y_offset,d1                      ; test batman_y_top?                
                    bpl.b   exit_badguy_shooting
                    cmp.w   batman_y_bottom,d1                      ; test batman_y_bottom?
                    bmi.b   exit_badguy_shooting
batman_shot         ; L000046ac
                    moveq   #$01,d6                                 ; Energy to lose value
                    bsr.w   batman_lose_energy
                    moveq   #SFX_GUYHIT,d0
                    jsr     AUDIO_PLAYER_INIT_SFX
end_bullet          ; L000046ba
                    move.w  #$0004,-$0002(a6)                       ; update handler id to display ricochet, etc?
exit_badguy_shooting ; L000046c0 
                    rts




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
                    ; Code Checked 2/1/2025
                    ;
badguy_shooting_left_up     ; original address L000046c2
                    subq.w  #$03,d0                         ; update X co-ord
                    cmp.w   #$fff6,d0                       ; compare left screen edge -10 (-20)
                    bmi.b   remove_projectile               ; if offscreen, then remove

                    subq.w  #$03,d1                         ; update Y co-ord
                    cmp.w   #$0058,d1                       ; compare #$0058 - 88 (176)
                    bcs.b   badguy_shooting                 ; if onscreen, then do common code
                    bra.b   remove_projectile               ; else, remove



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
badguy_shooting_right_up    ; original address L000046d4
                    addq.w  #$03,d0                         ; update X co-ord
                    cmp.w   #$00a8,d0                       ; compare right screen edge - #$a8 168 (336)
                    bpl.b   remove_projectile               ; if offscreen, then remove

                    subq.w  #$03,d1                         ; update Y co-ord
                    cmp.w   #$0058,d1                       ; compare #$58 - 88 (176)
                    bcs.b   badguy_shooting                 ; if onscreem, then do common code
                    bra.b   remove_projectile               ; else, remove



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
                    ; Code Checked 2/1/2-15
                    ;
badguy_shooting_left_down       ; original address L000046e6
                    subq.w  #$03,d0                         ; update X co-ord
                    cmp.w   #$fff6,d0                       ; compare left edge -10 (-20)
                    bmi.b   remove_projectile               ; if offscreen, then remove

                    addq.w  #$03,d1                         ; update Y co-ord
                    cmp.w   #$0058,d1                       ; compare #$58 - 88 (176)
                    bcs.b   badguy_shooting                 ; if onscreen, then do common code
                    bra.b   remove_projectile               ; else, remove




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
                    ; Code Checked 2/1/2025
                    ;
badguy_shooting_right_down  ; original address L000046f8
                    addq.w  #$03,d0                         ; update X co-ord
                    cmp.w   #$00a8,d0                       ; compare right screen edge - #$a8 168 (336)
                    bpl.b   remove_projectile               ; if offscreen, then remove

                    addq.w  #$03,d1                         ; update Y co-ord
                    cmp.w   #$0058,d1                       ; compare #$58 - 88 (176)
                    bcs.w   badguy_shooting                 ; if onscreen, then do common code
                    bra.b   remove_projectile               ; else, remove



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
                    ; Code Checked 2/1/2-15
                    ;
badguy_shooting_left    ; original address L0000470c
                    subq.w  #$05,d0                         ; update X co-ord
                    cmp.w   #$fff6,d0                       ; compare left edge -10 (-20)
                    bpl.w   badguy_shooting                 ; if onscreen
                    bra.b   remove_projectile               ; else, remove projectile



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
badguy_shooting_right   ; original address L00004718
                    addq.w  #$05,d0                         ; update X co-ord
                    cmp.w   #$00a8,d0                       ; compare right screen edge - #$a8 168 (336)
                    bmi.w   badguy_shooting                 ; if on screen 
                                                            ; else, fall through to remove_projectile 






        ;------------------------------------------------------------------------------------------------------
        ; Projectile Handling Code & Data
        ;------------------------------------------------------------------------------------------------------
        ; Code Checked 2/1/2025
        ;------------------------------------------------------------------------------------------------------
        


                    ; ---------------- remove projectile -----------------
                    ; IN:-
                    ;   a6.l = Projectile List Entry +2
                    ;
                    ; Code Checked 2/1/2-15
                    ;
remove_projectile   ; original address L00004722
                    clr.w   -$0002(a6)                      ; remove projectile Id from projectile list (make inactive)
                    rts



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
                    ; Code Checked 2/1/2015
                    ;
batarang_right      ; original address L00004728
                    addq.w  #$04,d0                                     ; increment X co-ord
                    cmp.w   #$00a8,d0                                   ; compare 168 (336)
                    bpl.b   remove_projectile                           ; if offscreen, remove 
                    ; LO00004730
                    bsr.w   get_map_tile_at_display_offset_d0_d1        ; out: d2.b = tile value
                    cmp.b   #$17,d2                                     ; compare with wall tile(s)
                    movem.w d0-d1,(a6)                                  ; store updated x, y
                    bcc.b   actor_projectile_collision_handler          ; if not a wall tile, check actor collision
                    bra.b   remove_projectile                           ; else, is wall tile so remove
                    ;bcs.b   remove_projectile                          ; L00004722 - original code



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
                    ; Code Checked 2/1/2015
                    ;
batarang_left       ; original address L00004740
                    subq.w  #$04,d0                                 ; decrement X co-ord               
                    cmp.w   #$fff6,d0                               ; compare left edge -10 (-20)
                    bmi.b   remove_projectile                       ; if offscreen then remove
                    ; L00004748
                    bsr.w   get_map_tile_at_display_offset_d0_d1    ; out: d2.b = tile value
                    cmp.b   #$17,d2                                 ; compare with wall tile      
                    movem.w d0-d1,(a6)                              ; store updated x,y co-ords
                    bcc.b   actor_projectile_collision_handler      ; if not wall tile, check active actor colliisions
                    bra.b   remove_projectile                       ; else, is wall tile so remove



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
                    ; Code Checked 2/1/2015
                    ;
batman_grappling_hook   ; original address L00004758
                    move.w  grappling_hook_height,d0
                    beq.b   remove_projectile           ; height = 0, then remove from game

                    movem.w batman_xy_offset,d0-d1      ; get batman x,y
                    add.w   L0000631a,d0                ; maybe grappling hook X offset from batman
                    sub.w   L0000631c,d1                ; maybe grappling hook Y offset from batman
                    sub.w   #$000c,d1                   ; subtract constant value 12 from Y
                    addq.w  #$05,d0                     ; add constant value 5 to X
                    tst.w   batman_sprite1_id           ; test facing left/right (negative = left)
                    bpl.b   .is_facing_right            ; if facing right, skip X modification
.is_facing_left     ; L00004778
                    subq.w  #$07,d0                     ;  ...else, if facing left then modify grappling hook X
.is_facing_right    ; L0000477A
                    movem.w d0-d1,(a6)                  ; store updated projectile height
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
                    ; Code Checked 2/1/2015
                    ;
actor_projectile_collision_handler                          ; original address L0000477e
                    lea.l   last_active_actor,a4            ; L00003a8e,a4 ; last active actor list
                    moveq   #$09,d6                         ; loop counter 10 (max active actors)
.loop               ; L00004784    
                    move.w  (a4),d2                         ; d2 = handler id/actor id
                    subq.w  #$02,d2                         ; actor 01 & 00, not collided with
                    bmi.b   .next_actor                     ; if actor 00 (free entry) or 01 (batman?) then skip

                    move.w  ACTORSTRUCT_X_CENTRE(a4),d2     ; offset 1$000e (actor x) maybe actor left X
                    sub.w   d0,d2                           ; d2 = projectile x - actor x
                    addq.w  #$04,d2                         ; add x boundary box (8 pixels?)
                    cmp.w   #$0008,d2                       ; test projectile in 8 pixels
                    bcc.b   .next_actor                     ; L000047a4

                    cmp.w   ACTORSTRUCT_Y_TOP(a4),d1        ; offset $0010 (actor y - top)
                    bpl.b   .next_actor                     ; actor is further down screen - L000047a4

                    cmp.w   ACTORSTRUCT_Y_BOTTOM(a4),d1                    ; offset $0012 (actor y - bottom)
                    bpl.b   projectile_hit_actor            ; if bottom of actor is futher down screen
.next_actor         ; L000047a4
                    lea.l   -ACTORLIST_STRUCT_SIZE(a4),a4   ; Check next actor, original was -$0016(a4),a4
                    dbf.w   d6,.loop                        ; loop 10 times
                    rts



                    ; ---------- actor collided with projectile -----------
                    ; Batman's bat-a-rang projectile has hit an actor.
                    ; This routine sets the handler index to $0001 (a4)
                    ;
                    ; IN:
                    ;   a4.l = Actor Structure
                    ;
                    ; Code Checked 2/1/2015
                    ;
projectile_hit_actor        ; original address L000047ae
                    move.w  #$0001,ACTORSTRUCT_STATUS(a4)           ; set actor killed status?
                    move.w  #$fffc,$000a(a4)                        ; -4 offset 10
                    bsr.w   remove_projectile                       ; remove projectile
                    moveq   #SFX_GUYHIT,d0
                    jmp     AUDIO_PLAYER_INIT_SFX
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
                    ; Code Checked 2/1/2015
                    ;                  
badguy_grenade_right    ; original address L000047c4
                    addq.w  #$02,d0                             ; update X co-ord
                    move.w  $0004(a6),d2                        ; d2 = grenade value 
                    cmp.w   #$0028,d2                           ; test value with 40
                    bpl.b   .clamp_at_40                        ; if value >= 40 then clamp value
.increment_value    ; L000047d0
                    addq.w  #$01,$0004(a6)                      ; else, increment value
.clamp_at_40        ; L000047d4
                    asr.w   #$02,d2                             ; divide by 4
                    bpl.b   .is_positive
.is_negative        ; L000047d8
                    addq.w  #$01,d2
.is_positive        ; L000047da
L000047da           add.w   d2,d1                               ; update projectile Y co-ord
                    ; L000047dc
L000047dc           cmp.w   #$0060,d1                           ; compare 96 (192) with Y co-ord
L000047e0           bpl.w   remove_projectile                   ; if greneade Y > 192 then remove
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
                    ; Code Checked 2/1/2015
                    ; 
badguy_grenade_common   ; original address L000047e4
                    movem.w d0-d1,(a6)                                  ; store X, Y
                    bsr.w   get_map_tile_at_display_offset_d0_d1        ; out: d2.b = tile value
                    cmp.b   #$17,d2                                     ; check wall tile
                    bcs.b   .hit_wall
                    ; L000047f2 - check X collision
.test_x_collision   sub.w   batman_x_offset,d0                          ; get x distance
                    addq.w  #$03,d0                                     ; add constant to x distance
                    cmp.w   #$0007,d0
                    bcc.b   .exit                                       ; grenade not in X range
                    ; L000047fe - check Y collision
.test_y_collision   cmp.w   batman_y_offset,d1                          ; get y distance
                    bpl.b   .exit                                       ; L00004820
                    cmp.w   batman_y_bottom,d1                          ; L000062f0,d1
                    bmi.b   .exit                                       ; L00004820
.batman_hit         ; L0000480a - batman hit
                    moveq   #$06,d6                                     ; energy to lose
                    bsr.w   batman_lose_energy
                    movem.w (a6),d0-d1                                  ; d0,d1 = x,y
.hit_wall
                    move.w  #$000e,-$0002(a6)                           ; update handler id = 14
                    moveq   #SFX_EXPLOSION,d2
                    bra.w   play_proximity_sfx                          ; play sfx if d0 > 160 & d1 >89 
.exit               ; L00004820
                    rts



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
                    ; Code Checked 2/1/2015
                    ; 
badguy_grenade_left     ; original address L00004822
                    subq.w  #$02,d0                         ; update X co-ord
                    move.w  $0004(a6),d2                    ; d2 = grenade value
                    cmp.w   #$0028,d2                       ; test value with 40
                    bpl.b   .clamp_at_40                    ; if value >= 40 then clamp value
.increment_value    ; L0000482e
                    addq.w  #$01,$0004(a6)
.clamp_at_40        ; L00004832  
                    asr.w   #$02,d2                         ; divide by 4
                    bpl.b   .is_positive 
.is_negative        ; L00004836 
                    addq.w  #$01,d2
.is_positive        ; L00004838
                    add.w   d2,d1                           ; update projectile Y co-ord
                    ; L0000483a
                    cmp.w   #$0060,d1                       ; compare 96 (192) with Y co-ord
                    bpl.w   remove_projectile               ; if greneade Y > 192 then remove
                    bra.b   badguy_grenade_common           ; else, do common grenade processing - L000047e4




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
                    ; Code Checked 2/1/2015
                    ; 
grenade_explosion_effect
                    movem.w d0-d1,(a6)                      ; store x,y
                    btst.b  #$0000,playfield_swap_count+1   ; test even/odd playfield buffer swap value
                    bne.b   .exit                           ; L00004864
.is_25hz            ; L00004850 - process only on even frame counts
                    move.w  -$0002(a6),d2                   ; get projectile handler index Id
                    addq.w  #$01,d2                         ; increment projectile handler index Id
                    cmp.w   #$0018,d2                       ; compare 24 with last projectile handler index
                    bne.w   .store_handler
                    clr.w   d2                              ; clear handler index Id (disable/remove projectile)
.store_handler      ; L00004860                             ; clear projectile handler index - remove projectile
                    move.w  d2,-$0002(a6)                   ; store handler index
.exit               ; L00004864
                    rts





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
                    ; Code Checked 2/1/2025
                    ;
projectile_jmp_table        ; original address L00004866
                    ;dc.l    batman_grappling_hook       ; 01 - L00004758 ; batman grappling hook
                    dc.l    batman_grappling_hook       ; 02 - L00004728 ; batman fire right
                    dc.l    batarang_right              ; 03 - L00004740 ; batman fire left
                    dc.l    batarang_left               ; 04 - L00004740 ; batman fire left
                    dc.l    remove_projectile           ; 05 - L00004722 ; remove projectile
                    dc.l    remove_projectile           ; 06 - L00004722 ; remove projectile
                    dc.l    badguy_shooting_right       ; 07 - L00004718 ; -> Bad Guy Shooting
                    dc.l    badguy_shooting_left        ; 08 - L0000470c ; <- Bad Guy Shooting
                    dc.l    badguy_shooting_right_down  ; 09 - L000046f8 ; \ Guy Shooting
                    dc.l    badguy_shooting_left_down   ; 10 - L000046e6 ; / Bad Guy Shooting
                    dc.l    badguy_shooting_right_up    ; 11 - L000046d4 ; / Bad Guy Shooting
                    dc.l    badguy_shooting_left_up     ; 12 - L000046c2 ; \ Bad Guy Shooting
                    dc.l    badguy_grenade_right        ; 13 - L000047c4 ; Grenade Right
                    dc.l    badguy_grenade_left         ; 14 - L00004822 ; Grenade Left
                    dc.l    grenade_explosion_effect    ; 15 - L00004844 ; runs while grenade explosion is displayed?
                    dc.l    grenade_explosion_effect    ; 16 - L00004844 ; runs while grenade explosion is displayed?
                    dc.l    grenade_explosion_effect    ; 17 - L00004844 ; runs while grenade explosion is displayed?
                    dc.l    grenade_explosion_effect    ; 18 - L00004844 ; runs while grenade explosion is displayed?
                    dc.l    grenade_explosion_effect    ; 19 - L00004844 ; runs while grenade explosion is displayed?
                    dc.l    grenade_explosion_effect    ; 20 - L00004844 ; runs while grenade explosion is displayed?
                    dc.l    grenade_explosion_effect    ; 21 - L00004844 ; runs while grenade explosion is displayed?
                    dc.l    grenade_explosion_effect    ; 22 - L00004844 ; runs while grenade explosion is displayed?
                    dc.l    grenade_explosion_effect    ; 23 - L00004844 ; runs while grenade explosion is displayed?
                    dc.l    grenade_explosion_effect    ; 24 - L00004844 ; runs while grenade explosion is displayed?
                    dc.l    grenade_explosion_effect    ; 24 - L00004844 ; runs while grenade explosion is displayed?


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
                    ; Code Checked 2/1/2025
                    ;

PROJECTILE_LISTITEM_SIZE    EQU $8                  ; 8 byte structure size
PROJECTILE_LISTITEM_HANDLER EQU $0                  ; Projectile Handler Index
PROJECTILE_LISTITEM_X       EQU $2                  ; Projectile X co-ord
PROJECTILE_LISTITEM_Y       EQU $4                  ; Projectile Y co-ord
PROJECTILE_LISTITEM_PARAM   EQU $6                  ; additional param (used for grenade acceleration)

projectile_list                             ; original address L00004894           
.entry_01           dc.w    $0000,$0000,$0000,$0000
.entry_02           dc.w    $0000,$0000,$0000,$0000
.entry_03           dc.w    $0000,$0000,$0000,$0000
.entry_04           dc.w    $0000,$0000,$0000,$0000
.entry_05           dc.w    $0000,$0000,$0000,$0000
.entry_06           dc.w    $0000,$0000,$0000,$0000
.entry_07           dc.w    $0000,$0000,$0000,$0000
.entry_08           dc.w    $0000,$0000,$0000,$0000
.entry_09           dc.w    $0000,$0000,$0000,$0000
.entry_10           dc.w    $0000,$0000,$0000,$0000
.entry_11           dc.w    $0000,$0000,$0000,$0000
.entry_12           dc.w    $0000,$0000,$0000,$0000
.entry_13           dc.w    $0000,$0000,$0000,$0000
.entry_14           dc.w    $0000,$0000,$0000,$0000
.entry_15           dc.w    $0000,$0000,$0000,$0000
.entry_16           dc.w    $0000,$0000,$0000,$0000
.entry_17           dc.w    $0000,$0000,$0000,$0000
.entry_18           dc.w    $0000,$0000,$0000,$0000
.entry_19           dc.w    $0000,$0000,$0000,$0000
.entry_20           dc.w    $0000,$0000,$0000,$0000



        ;------------------------------------------------------------------------------------------------------
        ; END OF - Projectile Handling Code & Data
        ;------------------------------------------------------------------------------------------------------
        ; Code Checked 2/1/2025
        ;------------------------------------------------------------------------------------------------------
        









                    ; ----------------------------------------------------------------------------------------------
                    ; -- Update Background Scroll (off screen buffer)
                    ;-----------------------------------------------------------------------------------------------
                    ; This routine manages the background level scrolling,
                    ; It draws the changes into the Off-Screen Buffer (kinda like a circular buffer of screen data)
                    ;
                    ;-----------------------------------------------------------------------------------------------
temp_vertical_scroll_increments                                     ; original address L00004934
                    dc.w    $0000                                   ; referenced as word below - oly set never read

scroll_offscreen_buffer                                             ; original address $00004936
                    movem.w batman_y_offset,D1-D2                   ; d1 = y offset, d2 = y offset (target Y) - window framing values
                    move.w  d1,d0
                    sub.w   d2,d0                                   ; d0 = difference new y and old y values
                    move.w  vertical_scroll_increments,temp_vertical_scroll_increments
                    move.w  d0,vertical_scroll_increments           ; store difference between values
                    beq.w   do_horizontal_scroll                    ; no vertical scroll, goto horizontal scroll.


                    ; think this is doing something to set the scroll speed.
                    ; it's fannying around with values in d0.
                    ; d0 is an offset added to the window Y coord further below.
scroll_speed_shenanigans                                            ; original address L0000494e
                    tst.w   L000062fa
                    ; check < 0
                    bmi.b   .is_negative                                ; L0000496c
                    ; check = 0
                    beq.b   .continue_vertical_scroll                    ; L00004980
                    ; check 1 to 4 scroll intervals
                    cmp.w   #$0004,d0
                    bcs.b   .continue_vertical_scroll                    ; L00004980
                    ; check -3 to -1 scroll intervals
                    cmp.w   #$fffd,d0
                    bcc.b   .continue_vertical_scroll                    ; L00004980
                    bpl.b   .L00004968
                    moveq   #-$2,d0                                     ; $fffffffe,D0           ; d0 = -2
                    bra.b   .continue_vertical_scroll                    ; L00004980

.L00004968          moveq   #$02,d0
                    bra.b   .continue_vertical_scroll                    ; L00004980

.is_negative        ; original address L0000496c
                    cmp.w   #$0008,d0
                    bcs.b   .continue_vertical_scroll                    ; L00004980
                    cmp.w   #$fffd,d0               ; -3
                    bcc.b   .continue_vertical_scroll                    ; L00004980
                    bmi.b   .L0000497e
                    moveq   #$07,d0
                    bra.b   .continue_vertical_scroll                    ; L00004980
.L0000497e          moveq   #-$3,d0                                     ;   #$fffffffd,D0           ; d0 = -3

.continue_vertical_scroll     ; original address L00004980
                    ; d0 = amount to scroll
                    move.w  scroll_window_y_coord,d1                    ; window Y coord
                    move.w  d1,d3                                       ; copy window Y coord
                    add.w   d0,d1                                       ; add scroll increment amount to Y coord
                    cmp.w   #$00f1,d1                                   ; 241 - Max Y coord?
                    bcs.b   .update_y_scroll_position                    ; no clamp required

                    bmi.b   .clamp_y_min                                ; L0000499c

.clamp_y_max        ; clamp to max Y coord                              ; original address L00004990
                    move.w  #$00f0,d2
                    sub.w   d2,d1                                       ; subtract max from y coord
                    sub.w   d1,d0                                       ; d0 = scroll amount to get to max Y 
                    move.w  d2,d1                                       ; d1 = window y coord - clamp Y at max value #$f0 (240)
                    bra.b   .update_y_scroll_position

.clamp_y_min        ; clamp to min Y coord?                             ; original address L0000499c
                    sub.w   d1,d0                                       ; d0 = scroll amount to get to #$00
                    clr.w   d1                                          ; d1 = window y coord - clamp Y at min value #$00

.update_y_scroll_position   ; original address L000049a0
                    sub.w   d0,batman_y_offset                          ; subtract scroll amount from $67c4
                    move.w  d1,scroll_window_y_coord                    ; update window Y coord

check_vertical_scroll  ; original address L000049a8
                    ; calculate the number of increments to scroll
                    sub.w   d3,d1                                       
                    move.w  d1,vertical_scroll_increments               ; store the number of increments to scroll            
                    beq.b   do_horizontal_scroll                        ; if no vertical scroll, skip to horizontal scroll
                    bmi.b   scroll_display_window_up

scroll_display_window_down                                              ; original address L000049b2 
                    add.w   #DISPLAY_MAX_Y,d3                           ; add 'display height' to Y position for tilemap to scroll in at bottom of display.
                    move.w  offscreen_y_coord,d2                        ; Y co-ord into destination gfx buffer
                    move.w  d1,d4                                       ; d1,d4 = number of rasters to scroll
                    add.w   d2,d4                                       ; add scroll increments to dest y co-ord
                    cmp.w   #DISPLAY_MAX_Y,d4                           ; check for display wrap - #$87 (174 display)
                    bcs.b   .no_display_wrap
.is_display_wrap
                    sub.w   #DISPLAY_MAX_Y,d4                           ; display wrapped, set y to top of buffer
.no_display_wrap
                    move.w  d4,offscreen_y_coord                        ; set new offscreen buffer y co-ord
                    bsr.w   draw_background_vertical_scroll
                    bra.w   do_horizontal_scroll
                    ;---------------------------------------

                    ; scroll display up (e.g. climbing upwards)
                    ; NB: d1 is negative
scroll_display_window_up    ; original address L000049d4
                    move.w  offscreen_y_coord,d2                        ; get current offscreen buffer Y co-ord
                    add.w   d1,d2                                       ; add number of scroll increments
                    ; test for underflow wrap at top
                    bpl.b   .no_underflow_wrap                          ; if +ve then no underflow wrap.
.is_enderflow_wrap
                    add.w   #DISPLAY_MAX_Y,d2                           ; wrap y co-ord to bottom of offscreen buffer
.no_underflow_wrap  ; L000049e0
                    move.w  d2,offscreen_y_coord                        ; store offscreen buffer Y co-ord
                    add.w   d1,d3                                       ; add scroll increments to world Y position
                    neg.w   d1                                          ; make number of scroll increments +ve
                    bsr.w   draw_background_vertical_scroll



                    ; ------- do horizontal scroll -------
do_horizontal_scroll    ; original address L000049ec
                    move.w  batman_x_offset,d0                          ; last batman X position scroll value
                    sub.w   target_window_x_offset,d0                   ; L000067c8,d0  ; current X scroll value
                    move.w  d0,L0000630e                                ; amount of scroll
                    beq.w   .exit_horizontal_scroll                     ; no horizontal scroll.

                    move.w  scroll_window_x_coord,d1                    ; d1 = current window X

.test_min_X         ; test window min X value (0)
                    move.w  d1,d2                                       ; d2 = copy of current window X
                    add.w   d0,d1                                       ; d1 = add amount of scroll
                    bpl.b   .test_max_X                                 ; L00004a0c
          
.clamp_low_X        ; clamp window at X=0
                    move.w  d1,d0
                    clr.w   d1                                          ; clamp X pos to 0.
                    bra.b   .cont_horiz_scroll                          ; L00004a1c
          

.test_max_X        ; test window max X value (1344) L00004a0c
                    clr.w   d0
                    cmp.w   #$0540,d1                                   ; #$540 = 1344
                    bls.b   .cont_horiz_scroll                          ; L00004a1c
                
.clamp_max_X        ; clamp window at x = 1344 (byte 168 just over one screen width from far right)
                    move.w  #$0540,d0
                    sub.w   d0,d1
                    exg.l   d1,d0

.cont_horiz_scroll  ; calc amount of horizontal scroll                  ; original address L00004a1c
                    add.w   target_window_x_offset,d0                   ; L000067c8,d0
                    move.w  d0,batman_x_offset
                    move.w  d1,scroll_window_x_coord                    ; update scroll window X coord
                    move.w  d1,d3
                    sub.w   d2,d3                                       ; d3 = difference between old and new X window 
                    move.w  d3,L0000630e                                ; store difference between old and new window X
                    beq.b   .exit_horizontal_scroll                     ; no horizontal scroll then exit.

                    ; check if coarse scroll                            ; original address L00004a32
                    eor.w   d1,d2                                       ; xor window X with old window X
                    btst.l  #$0003,d2                                   ; if not 16 pixel boundary change
                    beq.b   .exit_horizontal_scroll                     ; no coarse horizontal scroll then exit.

                    ; set up coarse scroll                              ; original address L00004a3a
                    move.l offscreen_display_buffer_ptr,a4
                    tst.w   d3                                          ; amount to scroll 
                    bmi.b   .scroll_left                                ; if -ve then scroll left

.scroll_right       ; do scroll right L00004a42                                   ; original address L00004a42
                    add.w   #$00a0,d1                                   ; add 160 (320 pixel to update column)
                    addq.w  #$02,a4                                     ; increase offscreen ptr 16 pixels to right
                    move.l  a4,offscreen_display_buffer_ptr             ; update offscreen buffer ptr
                    lea.l   $0028(a4),a4                                ; add 40 bytes to ptr (right hand side of screen)
                    bra.b   .update_horizontal

.scroll_left        ; do scroll left. L00004a52
                    subq.w  #$02,a4                                     ; sub 2 bytes to ptr (left hand side of screen)
                    move.l  a4,offscreen_display_buffer_ptr             ; update offscreen buffer ptr.

.update_horizontal  ; draw new column of tile map                       ; original address L00004a58
                    bsr.w   draw_background_horizontal_scroll
.exit_horizontal_scroll ; original address L00004a5c
                    rts  




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
draw_background_vertical_scroll                                         ; original address L00004a5e
                    subq.w  #$01,d1                                     ; adjust loop counter (number of 'scrolls' of 2 rasters per 'scroll')

                    ; calc source gfx start offset (depends on soft scroll value)
                    ; self modified code, updates LEA offset value below.
.draw_next_scroll_line ; draw new line (2 rasters) of scroll gfx
                        move.w  d3,d4                                   ; d3,d4 = Y value
                        and.w   #$0007,d4                               ; d4 = soft scroll value 0-7
                        asl.w   #$04,d4                                 ; multiply by 16 (width of gfx block - 4 bitplanes interleaved, 2 bytes wides, 2 rasters per scroll value)
                        move.b  d4,.gfx_lea_offset                      ; Self modified code - update $XX byte - lea $XX(a2,d0.W),a3

                        ; calc Y offset into map tile map data 
                        move.w  d3,d4                                   ; d3,d4 = Y value
                        lsr.w   #$03,d4                                 ; d3 = byte offset into map data table
                        lea.l   MAPGR_BASE,a0                           ; a0 = MAPGR.IFF (addr $8002)
                        mulu.w  (a0),d4                                 ; multiply d4 by #$c0 (size of level data block - maybe width of level map)
                                                                        ; d4 = offset into map data (y)
                        ; calc X offset into map tile map data
                        move.w  scroll_window_x_coord,d0
                        lsr.w   #$03,d0                                 ; d0 = X byte offset into tile map

                        ; calc total offset into tile map data
                        add.w   d0,d4                                   ; add X byte value
                        lea.l   MAPGR_TILEDATA_OFFSET(a0,d4.W),a0       ; a0 = tile map ptr

                        ; calc gfx destination address
                        move.w  d2,d4                                   ; d2 = dest buffer Y value / 2
                        mulu.w  #DISPLAY_2RASTERS,d4                    ; d4 = d4 * 84 (84 = two rasters height?)
                        add.l   offscreen_display_buffer_ptr,d4
                        movea.l d4,a1                                   ; store in a1 - destination GFX Display Address

                        ; Initialise Draw Loop 
                        ; width of display buffer - #$14 (21) words
                        moveq   #$14,d7                                 ; loop counter
                        movea.l background_gfx_base,a2

.draw_next_block         ; draw tile gfx (2 rasters worth)              ; original address L00004a98
                            clr.w   d0
                            move.b  (a0)+,d0                            ; read level tile map byte
                            asl.w   #$07,d0                             ; multiply tile map byte by 128

                            ; calc gfx source address ptr               ; original address L00004a9e
                            dc.w    $47f2                               ; lea.l   $XX(a2,d0.W),a3 - Self Modified Code                          
                            dc.b    $00
.gfx_lea_offset             dc.b    $00                                 ; $XX - byte offset value - original address L00004aa1

                            ; draw gfx block (2 rasters)
                            move.w  (a3)+,(a1)+                                                ; Line 1 - BPL 0
                            move.w  (a3)+,DISPLAY_BUFFER_BPL1_OFFSET-2(a1)                     ; Line 1 - BPL 1
                            move.w  (a3)+,DISPLAY_BUFFER_BPL2_OFFSET-2(a1)                     ; Line 1 - BPL 2
                            move.w  (a3)+,DISPLAY_BUFFER_BPL3_OFFSET-2(a1)                     ; Line 1 - BPL 3
                            move.w  (a3)+,DISPLAY_BUFFER_BPL0_OFFSET+DISPLAY_BYTEWIDTH-2(a1)   ; Line 2 - BPL 0
                            move.w  (a3)+,DISPLAY_BUFFER_BPL1_OFFSET+DISPLAY_BYTEWIDTH-2(a1)   ; Line 2 - BPL 1
                            move.w  (a3)+,DISPLAY_BUFFER_BPL2_OFFSET+DISPLAY_BYTEWIDTH-2(a1)   ; Line 2 - BPL 2
                            move.w  (a3)+,DISPLAY_BUFFER_BPL3_OFFSET+DISPLAY_BYTEWIDTH-2(a1)   ; Line 2 - BPL 3
                        dbf.w   d7,.draw_next_block     

                        ; update Y co-ords
                        addq.w  #$01,d3                                 ; Increment world Y value (index into tile map)
                        addq.w  #$01,d2                                 ; Increment dest buffer Y value  (index into dest gfx buffer)

                        ; test for dest gfx buffer overrun
                        cmp.w   #DISPLAY_MAX_Y,d2                       ; #$57 (87 decimal) (raster 174 - end of display buffer)
                        bcs.b   .no_wrap_dest_y                         ; branch when d2 > 87 (raster 174 - end of display buffer)
.wrap_dest_y            clr.w   d2                                      ; Wrap Scroll Offset to top of display buffer
.no_wrap_dest_y     dbf.w   d1,.draw_next_scroll_line                   ; L00004a60              

.exit           rts 



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
draw_background_horizontal_scroll                                       ; original address L00004ad6
                    movea.l background_gfx_base,a2                      ; $a07c - a2 = src gfx address MAPGR.IFF

                    ; calc tile map x offset
                    move.w  d1,d2                                       ; copy world X co-ord
                    lsr.w   #$03,d2                                     ; d2 = X co-ord byte offset 

                    ; calc src gfx Y clip
                    move.w  scroll_window_y_coord,d1
                    move.w  d1,d0                                       ; d0 = display window world Y co-ord
                    and.w   #$0007,d0                                   ; d0 = Y soft scroll bits
                    ; calc first tile draw loop count
                    ; clipping for first tile
                    move.w  d0,d5                                       ; d0, d5 = low 3 bits
                    not.w   d5
                    and.w   #$0007,d5                                   ; counter for number of initial tile rasters to draw (clip first tile)             
                    lsl.w   #$04,d0                                     ; d0 = src gfx clip offset. multiply soft scroll by 16 (bytes per tile raster)

                    ; calc tilemap src ptr
                    lsr.w   #$03,d1                                     ; d1 = Y world co-ord byte offset
                    lea.l   MAPGR_BASE,a0                               ; MAPGR.IFF (addr $8002)
                    move.w  (a0),d4                                     ; d4 = source map width (192 bytes? 48 bytes per plane interleaved? 384 pixels wide)
                    mulu.w  d4,d1                                       ; d1 = d1 * width
                    add.w   d2,d1                                       ; d1 = d1 + byte offset
                    lea.l   MAPGR_TILEDATA_OFFSET(a0,d1.W),a0           ; a0 = Tile Map source ptr

                    ; init display loop
                    moveq   #DISPLAY_MAX_Y-1,d7                         ; height of display / 2
                    move.w  offscreen_y_coord,d1                        ; start index into offscreen buffer Y

                    ; calc start dest buffer address
                    moveq   #DISPLAY_MAX_Y-1,d6                         ; d6 = inner counter $57 = 87 dec (*2 = 174 - height of display)
                    sub.w   d1,d6                                       ; subtract offscreen_y_coord
                    mulu.w  #DISPLAY_2RASTERS,d1
                    lea.l   $00(a4,d1.L),a1                             ; a1 = offscreen buffer, gfx destination ptr   

.calc_1st_gfx_offset ; calc 1st tile gfx offset (maybe clipped)          ; original address L00004b16
                    clr.w   d1
                    move.b  (a0),d1                                     ; d1 = tile map bytes
                    asl.w   #$07,d1                                     ; d1 = tile gfx offset (128 bytes per tile gfX)
                    add.w   d1,d0                                       ; d0 = add first block gfx clip offset
                    bra.b   .start_gfx_copy                              ; start drawing first tile
                    ;---------------------

.display_gfx_loop                                                        ; original address L00004b20
                    ; continue displaying current tile
                    dbf.w   d5,.copy_2_rasters                           ; d5 = tile height/2 (2 rasters per loop)

.do_next_tile        ; calc tile gfx offset                              ; original address L00004b24
                    moveq   #$07,d5                                     ; set tile height = 8 * 2 = 16 pixels 
                    clr.w   d0
                    move.b  (a0),d0                                     ; d0 = tile map byte
                    asl.w   #$07,d0                                     ; tile gfx offset (128 bytes per tile gfx)

.start_gfx_copy      ; in: d0 - src gfx offset                           ; original address L00004b2c
                    lea.l   $00(a2,d0.W),a3                             ; D0 = gfx start offset, a2 = gfx base address
                    adda.w  d4,a0                                       ; increment tile map ptr to next line down (d4 = tile map width)

                    
.copy_2_rasters      ; write 2 rasters of background gfx data            ; original address L00004b32
                    move.w  (a3)+,DISPLAY_BUFFER_BPL0_OFFSET(a1)                    ; line 0, bpl0
                    move.w  (a3)+,DISPLAY_BUFFER_BPL1_OFFSET(a1)                    ; line 0, bpl1 
                    move.w  (a3)+,DISPLAY_BUFFER_BPL2_OFFSET(a1)                    ; line 0, bpl2
                    move.w  (a3)+,DISPLAY_BUFFER_BPL3_OFFSET(a1)                    ; line 0, bpl3
                    move.w  (a3)+,DISPLAY_BUFFER_BPL0_OFFSET+DISPLAY_BYTEWIDTH(a1)  ; line 1, bpl0 + 42(a1)
                    move.w  (a3)+,DISPLAY_BUFFER_BPL1_OFFSET+DISPLAY_BYTEWIDTH(a1)  ; line 1, bpl1 + 42(a1)
                    move.w  (a3)+,DISPLAY_BUFFER_BPL2_OFFSET+DISPLAY_BYTEWIDTH(a1)  ; line 1, bpl2 + 42(a1)
                    move.w  (a3)+,DISPLAY_BUFFER_BPL3_OFFSET+DISPLAY_BYTEWIDTH(a1)  ; line 1, bpl3 + 42(a1)
                    lea.l   DISPLAY_2RASTERS(a1),a1                                 ; increase dest ptr by 2 rasters
                    dbf.w   d6,.continue_drawing
.top_buffer
                    lea.l   -DISPLAY_BUFFER_BYTES(a1),a1                            ; reset dest ptr to top of the buffer.
.continue_drawing
                    dbf.w   d7,.display_gfx_loop                         ; Loop for display height 174/2 = 87
.exit               rts 




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
copy_offscreen_to_backbuffer                                            ; original address L00004b62
                    move.w  #$8400,$00dff096                            ; set blitter nasty bit DMACON
                    ; init ptrs to display back buffer
                    movea.l playfield_buffer_2,a6                       ; a6 = back buffer address
                    subq.w  #$02,a6                                     ; a6 = decrement ptr by 16 pixels 

                    movea.l offscreen_display_buffer_ptr,a5             ; a5 = offscreen background scroll gfx buffer (circular buffer)
                    move.w  offscreen_y_coord,d1
                    clr.l   d6                                          ; d6 = $00000000
                    subq.w  #$01,d6                                     ; d6 = $0000ffff
                    swap.w  d6                                          ; d6 = $ffff0000
                    move.w  scroll_window_x_coord,d2                    ; d2 = word co-ord of display window
                    and.w   #$0007,d2                                   ; d2 = soft scroll value (0-7) co-ords are halved (2 pixel resolution)
                    beq.b   .no_soft_scroll                              ; if soft scroll = 0 (16 pixel boundary)
.is_soft_scroll
                    ; shift firstword/llastword mask?
                    ror.l   d2,d6                                       ; shift mask in d6 by soft scroll value
                    ror.l   d2,d6                                       ; shift mask in d6 by soft scroll value
.no_soft_scroll                                                          ; original address L00004b8c
                    ; calc blitter shift value (soft scroll value)
                    neg.w   d2
                    ror.w   #$03,d2
                    and.l   #$0000e000,d2                               ; d2 = blitter shift value?
                    bne.b   .set_minterms                                ; L00004b9a

.adjust_dest_ptr    ; no blit shift blit - align dest buffer exactly   
                    addq.w #$02,a6                                      ; a6 = backbuffer address (no need to shift into additional word of buffer)

.set_minterms        ; init BLTCON0 & BLTCON1
                    or.w    #$09f0,d2
                    swap.w  d2                                          ; d2 = BLTCON0 & BLTCON1

.calc_src_addr_1    ; calc source address - offscreen buffer
                    move.w  d1,d4                                       ; offscreen Y co-ord
                    mulu.w  #$0054,d4                                   ; multiply by 84 (2 rasters - coords are stored halved)
                    lea.l   $00(a5,d4.L),a1                             ; a1 = source address (start line of offscreen buffer)

                    ; calc dest gfx adddr
.set_dest_addr_1    movea.l a6,a0                                       ; a0 = destination buffer address

                    ; calc blit height
.calc_blit_height_1 moveq   #$28,d3                                     ; d3 = 40
                    move.w  #$00ae,d4                                   ; d4 = 174 (display height)
                    ; calc blit 1 display height
                    sub.w   d1,d4
                    sub.w   d1,d4

                    ; do blit 1 
                    ; (may  be whole buffer or part buffer depends on offscreen start Y bposition)
.do_blit_1          bsr.w   blit_src_to_dest                            ; L00004bde
   
.check_blit2_required ; check if 2nd blit required (second half of screen)
                    move.w  d1,d4
                    beq.b   .end_copy                                    ; first blit was full screen - no need for 2nd blit -L00004bd4

                    ; blit second half of buffer (circular offscreen buffer)
                    moveq   #$57,d3                                     ; d3 = 87 (full screen height/2)
                    sub.w   d4,d3                                       ; difference between offscreen Y and full screen height
                    mulu.w  #$0054,d3                                   ; multiple difference by 2 rasters (84 bytes) - dimensions held halved (resolution of 2 pixels)
                    ; calc 2nd blit dest ptr
.calc_dest_addr_2   lea.l   $00(a6,d3.L),a0                             ; a0 = back buffer destination ptr
                    ; calc 2nd blit height
.calc_blit_height_2 add.w   d4,d4
                    ; calc 2nd blit width 
.calc_blit_width_2  moveq   #$28,d3
                    ; dest ptr is top half of screen
.calc_src_addr_2    lea.l   (a5),a1
                    ; do blit 2
                    bsr.w   blit_src_to_dest                            ; L00004bde
.end_copy            ; turn off blitter nasty and exit
                    move.w  #$0400,$00dff096                            ; switch off blitter nasty
                    rts  


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
blit_src_to_dest                                                        ; original address L00004bde
                    move.l  d2,d5                                       ; copy bltcon value (unused)
                    swap.w  d5                                          ; swap low/high word (unused)
                    and.w   #$e000,d5                                   ; d5 = preserve shift value (unused)
                    addq.w  #$02,d3                                     ; add 2 bytes to blit width (for shifting?)
                    asl.w   #$06,d4                                     ; shift blit height to correct bits 15-6
                    move.w  d3,d5                                       ; copy blit width to d5
                    lsr.w   #$01,d5                                     ; divide blit width to get numberof words (instead of bytes)
                    add.w   d5,d4                                       ; set bits 0-5 for blit width
                    sub.w   #DISPLAY_BYTEWIDTH,d3                       ; subtract 42 from blit width (get modulo?)
                    neg.w   d3                                          ; make +ve if d3 < display width (will most likely be 0)
                    lea.l   CUSTOM,a4                                   ; a4 = custom base
                    move.l  #DISPLAY_BUFFER_BYTES,d5                    ; d5 = display bitplane size (offscreen buffer & back buffer same size)

.blit_wait                                                              ; original address L00004c02        
                    btst.b  #$0006,$00dff002                            ; test blitter finished dmaconr
                    bne.b   .blit_wait

                    move.l  d6,BLTAFWM(a4)                              ; BLTAFWM & BLTALWM - Channel A firt/last word mask
                    move.w  d3,BLTAMOD(a4)
                    move.w  d3,BLTDMOD(a4)
                    move.l  d2,BLTCON0(a4)                              ; BLTCON0 ($x9f0) & BLTCON1 ($0000) - x = shift ,$9 = use A & D, $f0 = minterms (D=A

                    moveq   #$03,d7                                     ; bitplane loop counter (3+1)
.blit_next_bitplane
                    btst.b  #$0006,$00dff002
                    bne.b   .blit_next_bitplane                         ; test blitter finished dmaconr

                    move.l  a1,BLTAPT(a4)                               ; BLTAPTH & BLTAPTL
                    move.l  a0,BLTDPT(a4)                               ; BLTDPTH & BLTDPTL
                    move.w  d4,BLTSIZE(a4)                              ; start the blit of required size.

                    adda.l  d5,a1                                       ; increment src ptr by bitplane size
                    adda.l  d5,a0                                       ; increment dest ptr by bitplane size

                    dbf.w   d7,.blit_next_bitplane                      ; loopto do next bitplane (4 in total)
                    rts  




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
player_move_commands    ; original address $00004c3e
                    clr.w   d2
                    move.b  player_input_command,d2                 ; player joystick input bits
                    asl.w   #$02,d2                                 ; convert value to table index (long word)
                    movea.l player_input_cmd_table(pc,d2.W),a0      ; get input command address.
                    jmp (a0)                                        ; execute input command
                    ; each command ends with an RTS that returns to caller.

                    ; ------------- player input jump table ------------
                    ; the player_input_command byte is used as an index
                    ; into the table to execute the command associated
                    ; with the jotstick input.
                    ;
                    ; Code Checked 3/1/2025
                    ;
player_input_cmd_table  
                    ; original address $00004c4c            ; Fire  | Up    | Down  | Left  | Right |
L00004c4c           dc.l    player_input_cmd_nop            ; 0     | 0     | 0     | 0     | 0     | - CMD00 - $00005290 - NOP - (no input)
L00004c50           dc.l    player_input_cmd_right          ; 0     | 0     | 0     | 0     | 1     | - CMD01 - $00005246 - Batman Right
L00004c54           dc.l    player_input_cmd_left           ; 0     | 0     | 0     | 1     | 0     | - CMD02 - $0000529c - Batman Left
L00004c58           dc.l    player_input_cmd_nop            ; 0     | 0     | 0     | 1     | 1     | - CMD03 - $00005290 - NOP - (input left and right)
L00004c5c           dc.l    player_input_cmd_down           ; 0     | 0     | 1     | 0     | 0     | - CMD04 - $000053f4 - Batman Down
L00004c60           dc.l    player_input_cmd_down_right     ; 0     | 0     | 1     | 0     | 1     | - CMD05 - $00005240 - Batman Down + Right
L00004c64           dc.l    player_input_cmd_down_left      ; 0     | 0     | 1     | 1     | 0     | - CMD06 - $00005292 - Batman Down + Left
L00004c68           dc.l    player_input_cmd_nop            ; 0     | 0     | 1     | 1     | 1     | - CMD07 - $00005290 - NOP - (input down, left & right)
L00004c6c           dc.l    player_input_cmd_up             ; 0     | 1     | 0     | 0     | 0     | - CMD08 - $00005202 - Batman Up 
L00004c70           dc.l    player_input_cmd_up_right       ; 0     | 1     | 0     | 0     | 1     | - CMD09 - $00005244 - Batman Up + Right
L00004c74           dc.l    player_input_cmd_up_left        ; 0     | 1     | 0     | 1     | 0     | - CMD10 - $00005298 - Batman Up + Left
L00004c78           dc.l    player_input_cmd_nop            ; 0     | 1     | 0     | 1     | 1     | - CMD11 - $00005290 - NOP - (input up, left & right)
L00004c7c           dc.l    player_input_cmd_nop            ; 0     | 1     | 1     | 0     | 0     | - CMD12 - $00005290 - NOP - (input up, & down)
L00004c80           dc.l    player_input_cmd_nop            ; 0     | 1     | 1     | 0     | 1     | - CMD13 - $00005290 - NOP - (input up, down & right)
L00004c84           dc.l    player_input_cmd_nop            ; 0     | 1     | 1     | 1     | 0     | - CMD14 - $00005290 - NOP - (input up, down & left)
L00004c88           dc.l    player_input_cmd_nop            ; 0     | 1     | 1     | 1     | 1     | - CMD15 - $00005290 - NOP - (input up, down, left & right)
L00004c8c           dc.l    player_input_cmd_fire           ; 1     | 0     | 0     | 0     | 0     | - CMD16 - $00004fe0 - Fire
L00004c90           dc.l    player_input_cmd_fire           ; 1     | 0     | 0     | 0     | 1     | - CMD17 - $00004fe0 - Fire + Right
L00004c94           dc.l    player_input_cmd_fire           ; 1     | 0     | 0     | 1     | 0     | - CMD18 - $00004fe0 - Fire + Left
L00004c98           dc.l    player_input_cmd_fire           ; 1     | 0     | 0     | 1     | 1     | - CMD19 - $00004fe0 - Fire + Left + Right
L00004c9c           dc.l    player_input_cmd_fire_down      ; 1     | 0     | 1     | 0     | 0     | - CMD20 - $000053d6 - Fire + Down
L00004ca0           dc.l    player_input_cmd_fire_down      ; 1     | 0     | 1     | 0     | 1     | - CMD21 - $000053d6 - Fire + Down + Right
L00004ca4           dc.l    player_input_cmd_fire_down      ; 1     | 0     | 1     | 1     | 0     | - CMD22 - $000053d6 - fire + Down + Left
L00004ca8           dc.l    player_input_cmd_fire_down      ; 1     | 0     | 1     | 1     | 1     | - CMD23 - $000053d6 - Fire + Down + Left + Right
L00004cac           dc.l    player_input_cmd_fire_up        ; 1     | 1     | 0     | 0     | 0     | - CMD24 - $000050f8 - Fire + Up
L00004cb0           dc.l    player_input_cmd_fire_up_right  ; 1     | 1     | 0     | 0     | 1     | - CMD25 - $000050e6 - Fire + Up + Right
L00004cb4           dc.l    player_input_cmd_fire_up_left   ; 1     | 1     | 0     | 1     | 0     | - CMD26 - $000050ee - Fire + Up + Left
L00004cb8           dc.l    player_input_cmd_nop            ; 1     | 1     | 0     | 1     | 1     | - CMD27 - $00005290 - NOP - (input fire, up, left & right)
L00004cbc           dc.l    player_input_cmd_nop            ; 1     | 1     | 1     | 0     | 0     | - CMD28 - $00005290 - NOP - (input fire, up & down)
L00004cc0           dc.l    player_input_cmd_nop            ; 1     | 1     | 1     | 0     | 1     | - CMD29 - $00005290 - NOP - (input fire, up, down & right)
L00004cc4           dc.l    player_input_cmd_nop            ; 1     | 1     | 1     | 1     | 0     | - CMD30 - $00005290 - NOP - (input fire, up, down & left)
L00004cc8           dc.l    player_input_cmd_nop            ; 1     | 1     | 1     | 1     | 1     | - CMD31 - $00005290 - NOP - (input firem up, down, left & right)



                    ; ------------------------- batman lose energy ---------------------------
                    ; IN: 
                    ;   d6.w - amount of energy to lose.
                    ;
batman_lose_energy                                                  ; original address L00004ccc
                    tst.b   PANEL_STATUS_1                          ; Test if Time UP, Life Lost, No Lives
                    bne     exit_rts                                ; exit if 'Timer Expired', 'Life Lost', 'No Lives Remaining'

                    movem.l d0-d7/a5-a6,-(a7)
                    move.w  d6,d0
                    jsr     PANEL_LOSE_ENERGY                       ; Panel - Lose Energy (D0.w) - $0007c870
                    movem.l (a7)+,d0-d7/a5-a6
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
                    ; Code Checked 7/1/2025
                    ;
batman_collision_state_machine  ; original address L00004ce4   
                    move.l  gl_jsr_address,d2               ; d2 = current state

.check_falling          ; L00004ce8
                        cmp.l   #player_state_falling,d2    
                        beq.b   .exit_rts                    
                        ; if state = 'falling' then exit
                                               
.check_collision_on_batrope ; L00004cee
                        move.l  #player_state_actor_collide_on_batrope,d3                           ; get new state
                        cmp.l   d3,d2                   
                        beq.b   .update_state               
                        ; if state equal, then state = 'actor_collide_on_batrope'
                        ; increment L00006306

.check_swing_on_rope    ; L00004cf6
                        cmp.l   #player_state_grappling_hook_attached,d2                           ; Address
                        beq.b   .update_state
                        ; if state equal then, state = 'actor_collide_on_batrope'
                        ; increment L00006306

.check_climb_on_platform ; L00004cfc
                        cmp.l   #player_state_climb_onto_platform,d2                           ; Address
                        beq.b   .increment_state_param_by_3
                        ; if state equal then, state = 'climb_onto_platform' 
                        ; increment state param by 3

.check_climbing_stairs  ; L00004d02
                        move.l  #player_state_actor_collide_on_ladder,d3                           ; Address
                        cmp.l   #state_climbing_stairs,d2                 ; Address
                        beq.b   .update_state
                        ; if 'climbing stairs', state = 'actor_collide_on_ladder'
                        ; increment L00006306

.check_collide_on_ladder ; L00004d0c
                        cmp.l   d2,d3
                        beq.b   .update_state
                        ; if 'actor_collide_on_ladder', state = 'actor_collide_on_ladder'
                        ; increment L00006306

.else_check_actor_collision   ; L00004d10 - collision with 'badguy', 'drip', 'gas leak'
                        ; while stasnding on a platform.
                        lea.l   batman_sprite_anim_fall_landing,a0
                        bsr.w   set_batman_sprites
                        move.l  #player_state_check_actor_collision,d3
                        ; set state to 'drip' or 'gasleak' collision
                        ; increment L00006306

.update_state           ; L00004d1c
                        move.l  d3,gl_jsr_address ; update state routine address

                        ; update value held in L00006306
                        ; by value passed in d6 (#$01 from main loop)
                        ; clamp value in range (0 - 12)
                        ; increment in steps of 4
.increment_L00006306    ; L00004d20
                        move.w  L00006306,d2                            ; d2 = current state?
                        add.w   d6,d6                                   ; multiply #$01 by 2
                        add.w   d6,d6                                   ; multiply #$02 by 2
                        add.w   d6,d2                                   ; add 4 to d2                  
                        cmp.w   #$000c,d2                               ; compare d2 with 12
                        bcs.b   .store_value                            ; if < 12
.clamp_d2               ; L00004d30
                        moveq   #$0c,d2                                 ; clamp d2 to max of 12
.store_value            ; L00004d32
                        move.w  d2,L00006306
.exit_rts           ; L00004d36  
                    rts 

                    ; if 'climbing onto platform'
.increment_state_param_by_3 ; L00004d38
                    move.w  state_parameter,d2              ; d2 = state parameter value
                    add.w   d6,d2                           ; add 1 to d2
                    add.w   d6,d2                           ; add 1 to d2
                    add.w   d6,d2                           ; add 1 to d2
                    move.w  d2,state_parameter              ; store updated value
                    rts 




                    ; -------------- player state - actor collision on ladder -------------
                    ; This state gets called when Batman collides with an actor when
                    ; climbing a ladder.
                    ;
player_state_actor_collide_on_ladder        ; original address L00004d48
L00004d48           ;jsr     _DEBUG_COLOURS
                    subq.w  #$01,L00006306
L00004d4c           bne.b   exit_rts                                    ; L00004d36
L00004d4e           move.l  #state_climbing_stairs,gl_jsr_address         ; L00003c90 ; Set Self Modifying Code JSR in game_loop
L00004d54           bra.b   L00004d7a

                    ; shared rts - moved to here
exit_rts            rts



                    ; -------------- player state - drip and leak collision -------------
                    ; This state is called when the player collides with a toxic drip
                    ; or gas jet. Also if colliding with a 'bad guy' actor.
                    ;
                    ; Only occurs when batman is standing on a platform, not when 
                    ; climbing a ladder or swinging on a rope..
                    ;
                    ;
player_state_check_actor_collision      ; original address L00004d56
L00004d56           ;jsr     _DEBUG_RED_PAUSE
                    tst.w   grappling_hook_height                       ; L00006318
L00004d5a           beq.b   L00004d60
L00004d5c           bsr.w   player_state_retract_grappling_hook         ; L000051b0
L00004d60           subq.w  #$01,L00006306
L00004d64           bne.b   exit_rts                                    ; L00004d36
L00004d66           move.l  #player_move_commands,gl_jsr_address        ; L00003c90 ; Set Self Modifying code - GameLoop JSR - L00003c92 = jsr address (low word) - Default Value = $4c3e (run command loop)
L00004d6c           tst.w   grappling_hook_height                       ; L00006318
L00004d70           beq.b   L00004d76
L00004d72           bsr.w   L000051a8
;L00004d76           bsr.w   L00005430 - added two lines below to replace this
L00004d76
L00005430a          lea.l   batman_sprite_anim_standing,a0
L00005434a          bsr     set_batman_sprites

L00004d7a           tst.b   PANEL_STATUS_1                              ; Panel - Status Byte 1 - $0007c874
L00004d80           beq.b   exit_rts                                    ; L00004d36



                    ; ----------------- set state - player life lost -----------------
                    ; This routine sets the state 'player life lost' state.
                    ; It updated the game loop state function to L00004da2
                    ; This method handles the player life lost animations etc.
                    ;
                    ; IN:-
                    ;   - D0.w = L000067c2 - batman_x_offset
                    ;   - D1.w = L000067c4 - batman_y_offset
                    ;
set_state_player_life_lost  ; original address L00004d82
                    jsr     AUDIO_PLAYER_SILENCE              
                    clr.w   grappling_hook_height
                    moveq   #SFX_LIFE_LOST,d0                                       ; song/sound number - 03 = player life lost
                    jsr     AUDIO_PLAYER_INIT_SONG            
                    move.l  #player_state_life_lost,gl_jsr_address           
                    move.l  #batman_sprite_anim_life_lost,batman_sprite_anim_ptr    ; modified ptr to longword - L00006326
                    rts 




                    ; ----------------- player state life lost ------------------
                    ; Routine set in player state in the game_loop to manage
                    ; the player life lost state.
                    ;
                    ; Code Checked 4/1/2025
                    ;
player_state_life_lost      ; original address L00004da2
                    ; player dead animation                             
                    movea.l batman_sprite_anim_ptr,a0                   ; modified to long pointer - L00006326,a0                               
                    bsr.w   set_batman_sprites
                    move.l  a0,batman_sprite_anim_ptr                   ; modified to long pointer - L00006326
                    tst.b   (a0)
;L00004db0            bne     exit_rts                                  ; original code ; Exit (JMP to RTS)
                    beq.s     .prep_display                             ; L00004db2                                 ; inverted the logic to aid readability
                    rts
          
.prep_display       ; L00004db2 - prepare audio & display buffers
                    jsr     AUDIO_PLAYER_INIT_SFX_2                    ; stop audio
                    move.w  #$0032,d0
                    bsr.w   wait_for_frame_count                       ; L00005e8c
                    bsr.w   clear_backbuffer_playfield                 ; L00004e28

.test_timer_expired ; L00004dc4
                    btst.b  #PANEL_ST1_TIMER_EXPIRED,PANEL_STATUS_1     ; Panel - Status Byte 1 bit #$0000 of $0007c874
                    beq.b   .test_game_over                             ; L00004dd6

.timer_expied       ; L00004dce - display time-up message
                    lea.l   text_time_up,a0                            ; L00004e1c,a0
                    bsr.w   large_text_plotter                         ; L000067ca

.test_game_over     ; L00004dd6
                    btst.b  #PANEL_ST1_NO_LIVES_LEFT,PANEL_STATUS_1     ; Panel - Status Byte 1 - bit #$0001 of $0007c874
                    beq.b   .wipe_display                               ; L00004de8

.game_over          ; L00004de0 - display game-over message
                    lea.l   text_game_over,a0                          ; L00004e0e,a0
                    bsr.w   large_text_plotter                         ; L000067ca

.wipe_display       ; L00004de8 - wipe display
                    bsr.w   screen_wipe_to_backbuffer                  ; L00003cc0
                    move.w  #$001e,d0
                    bsr.w   wait_for_frame_count                       ; L00005e8c

.test_lives_left    ; L00004df4
                    btst.b  #PANEL_ST1_NO_LIVES_LEFT,PANEL_STATUS_1     ; Panel - Status Byte 1 - bit #$0001 of $0007c874
                    beq.w   restart_level                              ; L00003b02
                    ; Fall through to return to Title Screen
                    ; if 'Game Over'



                    ; ------------------- return to title screen ------------------------
                    ; When the game is over, return to the titlle screen processing.
                    ; If test build then restart the level instead.
                    ;
return_to_title_screen  ; original address L00004e00
L00004e00           jsr     AUDIO_PLAYER_SILENCE                             ; Chem.iff - Music/SFX player - Silence Audio- $00048004           ; External Address - CHEM.IFF
L00004e06           bsr.w   panel_fade_out                             ; L00003d8c
                    
                    IFD TEST_BUILD_LEVEL
                        jsr _DEBUG_COLOURS
                        JMP return_to_title_screen
                    ENDC

                    bra.w   LOADER_TITLE_SCREEN                        ; $00000820 ; **** LOADER ****
                    ; *************************************
                    ; ****        LOAD TITLE SCREEN     ***
                    ; *************************************

                    
text_game_over      ; GAME OVER - original address L00004e0e
                    dc.b    $5f, $0f
                    dc.b    'GAME  '                   ; $47, $41, $4d, $45, $20, $20
                    dc.b    'OVER'                     ; $4f, $56, $45, $52
                    dc.b    $00, $ff

                    
text_time_up        ; TIME UP - original address L00004e1c
                    dc.b    $43, $10
                    dc.b    'TIME  '                   ; $54, $49, $4d, $45, $20, $20 
                    dc.b    'UP'                       ; $55, $50
                    dc.b    $00, $ff

                    even
                    

clear_backbuffer_playfield                              ; original address $00004e28
L00004e28           movea.l playfield_buffer_2,a0      ; 
                    move.w  #$1c8b,d7                  ; loop 7308 times / 42 = 174 rasters
.clear_loop                                             ; original address L00004e32
                    clr.l   (a0)+                      ; clear 29232 bytes = 4 bitplanes
                    dbf.w   d7,.clear_loop             ; loop to $00004e32
                    rts                                ; original address $00004e38






                    ; -------------- player state - actor collide on batrope -----------
                    ; game_loop - Self Modified JSR Address
                    ; set at line of code L00004cee
                    ; ---- player state - actor Collision on batrope ------
player_state_actor_collide_on_batrope   ; original address L00004e3a
L00004e3a           ;jsr _DEBUG_RED_PAUSE
                    ;move.w  #$f00,$dff180 
                    moveq   #$10,d3                    ; CMD16 - Fire - No Direction
L00004e3c           tst.b   PANEL_STATUS_1             ; Panel - Status Byte 1 - (Clock Timer Expired, No Lives, Life Lost bits)
L00004e42           bne.b   L00004e60

L00004e44            lea.l   grappling_hook_height,a0   ; L00006318,a0
L00004e48            move.w  (a0),d2
L00004e4a            cmp.w   #$0050,d2                  ; compare 80 with d2
L00004e4e            bcc.b   L00004e60                  ;   if d2 > 80 jmp $4e60
L00004e50            addq.w  #$01,(a0)
L00004e52            clr.w   d3                         ; Player Movement Command 00 - NOP
L00004e54            subq.w  #$01,L00006306
L00004e58            bne.b   L00004e60
L00004e5a            move.l  #player_state_grappling_hook_attached,gl_jsr_address  ; L00003c90        ; Set Self MOdified Code JSR in game_loop


                    ; update control command
L00004e60           move.b  d3,player_input_command    ; CMD00 (rts) or (CMD16) Fire no Direction
                    ; fall through to 'update_grppling_hook' below


                    ; --------- player state - grappling hook attached -----------
player_state_grappling_hook_attached    ; original address L00004e64
L00004e64           ;move.w #$00f,$dff180
                    lea.l   grappling_hook_height,a0               ; L00006318,a0                
L00004e68           move.w  (a0),d5
L00004e6a           move.b  player_input_command,d4                ; L00006308,d4
L00004e6e           btst.l  #PLAYER_INPUT_UP,d4
L00004e72           beq.b   L00004ea8
L00004e74           move.w  #$0048,target_window_y_offset          ; L000067c6
L00004e7a           subq.w  #$01,d5
L00004e7c           bhi.b   L00004ea6
L00004e7e           clr.w   (a0)
L00004e80           move.l  #player_state_climb_onto_platform,gl_jsr_address              ; L00003c90 ; Self modified code JSR game_loop
L00004e86           move.w  #$0005,state_parameter                 ; L000062f2
L00004e8c           move.l  #L00006426,batman_sprite_anim_ptr      ; modified to long pointer L00006326
L00004e92           move.w  d1,d2
L00004e94           add.w   scroll_window_y_coord,d2               ; L000067be,d2
L00004e98           subq.w  #$02,d2
L00004e9a           and.w   #$0007,d2
L00004e9e           sub.w   d2,d1
L00004ea0           move.w  d1,batman_y_offset
L00004ea4           rts  

                    ; d4.b = player_input_command
L00004ea6            move.w  d5,(a0) 
L00004ea8            btst.l  #PLAYER_INPUT_DOWN,d4
L00004eac            beq.w   L00004ec0
L00004eb0            move.w  #$0028,target_window_y_offset          ; L000067c6
L00004eb6            addq.w  #$01,d5
L00004eb8            cmp.w   #$0050,d5
L00004ebc            bcc.b   L00004ec0
L00004ebe            move.w  d5,(a0)
L00004ec0            lea.l   grappling_hook_params,a0                           ; grappling hook vars
L00004ec4            movem.w (a0),d2-d3
L00004ec8            clr.w   d7
L00004eca            moveq   #$07,d6
L00004ecc            cmp.w   #$0028,d5
L00004ed0            bcc.b   L00004edc
L00004ed2            moveq   #$03,d6
L00004ed4            cmp.w   #$0014,d6
L00004ed8            bcc.b   L00004edc
L00004eda            moveq   #$01,d6
L00004edc            and.w   playfield_swap_count,d6            ;  d6 = 1 or 0, even/odd playfield swap value
L00004ee0            bne.b   L00004eec
L00004ee2            and.w   #$0003,d4
L00004ee6            asr.w   #$01,d4
L00004ee8            subx.w  d7,d4
L00004eea            move.w  d4,d7
L00004eec            move.w  d2,d4
L00004eee            ext.l   d4
L00004ef0            divs.w  d5,d4
L00004ef2            sub.w   d7,d4
L00004ef4            add.w   d4,d3
L00004ef6            sub.w   d3,d2
L00004ef8            add.w   #$0080,d2
L00004efc            cmp.w   #$0100,d2
L00004f00            bcc.b   L00004f08
L00004f02            sub.w   #$0080,d2
L00004f06            bra.b   L00004f16
L00004f08            clr.w   d3
L00004f0a            sub.w   #$0080,d2
L00004f0e            bpl.b   L00004f14
L00004f10            MOVE.L  #$ffffff81,D2
L00004f12            bra.b   L00004f16
L00004f14            moveq   #$7f,d2
L00004f16            movem.w d2-d3,(a0)

L00004f1a            lea.l   grappling_hook_params,a0                               ; grappling hook vars
L00004f1e            lea.l   batman_xy_offset,a2
L00004f22            bsr.w   L000050aa

L00004f26            movem.w batman_xy_offset,d0-d1
L00004f2c            movem.w L00006328,d5-d6
L00004f32            sub.w   d3,d5
L00004f34            move.w  d5,batman_swing_speed                      ; L000062f4
L00004f38            move.w  d5,L0000630e
L00004f3c            sub.w   d6,d4
L00004f3e            move.w  d4,batman_fall_speed                           ; L000062f6
L00004f42            add.w   d4,d1
L00004f44            add.w   d5,d0
L00004f46            subq.w  #$04,d1
L00004f48            subq.w  #$05,d0
L00004f4a            bsr.w   get_map_tile_at_display_offset_d0_d1               ; out: d2.b = tile value
L00004f4e            moveq   #$02,d7
L00004f50            move.b  $00(a0,d3.W),d2
L00004f54            cmp.b   #$17,d2
L00004f58            bcs.b   L00004f8e
L00004f5a            move.b  $01(a0,d3.W),d2
L00004f5e            cmp.b   #$17,d2
L00004f62            bcs.b   L00004f8e
L00004f64            sub.w   MAPGR_BASE,d3            ; MAPGR.IFF (value $00c0)
L00004f6a            dbf.w   d7,L00004f50
L00004f6e            movem.w batman_xy_offset,d0-d1
L00004f74            add.w   d4,d1
L00004f76            add.w   d5,d0
L00004f78            movem.w d0-d1,batman_xy_offset
L00004f7e            move.l  L0000631a,L00006328
L00004f84            btst.b  #PLAYER_INPUT_FIRE,player_input_command            ; L00006308
L00004f8a            bne.b   L00004fae
L00004f8c            rts 


L00004f8e           tst.w   d4
L00004f90           bmi.b   L00004f9a
L00004f92           subq.w  #$02,grappling_hook_height              ; L00006318
L00004f96           bra.w   L00004f1a

L00004f9a           movem.w d0-d7,-(a7)
L00004f9e           moveq   #$02,d6                                 ; Value of Energy to Lose
L00004fa0           bsr.w   batman_lose_energy                      ; L00004ccc
L00004fa4           movem.w (a7)+,d0-d7
L00004fa8           clr.w   d4
L00004faa           clr.w   d5
L00004fac           bra.b   L00004fcc

L00004fae           movem.w batman_swing_fall_speed,d4-d5                ; L000062f4,d4-d5
L00004fb4           subq.w  #$03,d5
L00004fb6           cmp.w   #$fffa,d5
L00004fba           bpl.b   L00004fbe
L00004fbc           MOVE.L #$fffffffa,D5
L00004fbe           subq.w  #$02,d4
L00004fc0           cmp.w   #$fffc,d4
L00004fc4           bcc.b   L00004fca
L00004fc6           smi.b   d4
L00004fc8           asl.w   #$02,d4
L00004fca           addq.w  #$02,d4
L00004fcc           movem.w d4-d5,batman_swing_fall_speed            ; L000062f4
L00004fd2           clr.w   grappling_hook_height               ; L00006318
L00004fd6           movem.w batman_xy_offset,d0-d1
L00004fdc           bra.w   L00005464




                    ; --------------- player input command - fire ------------------
                    ; Called when the fire button is pressed on the joystick.
                    ;
                    ; IN:-
                    ;   - D0.w = L000067c2 - batman_x_offset
                    ;   - D1.w = L000067c4 - batman_y_offset
                    ;
                    ; Code Checked 4/1/2025
                    ;
player_input_cmd_fire   ; original address L00004fe0
                    move.l  #batman_sprite_anim_firing,batman_sprite_anim_ptr           
                    move.l  #player_state_firing,gl_jsr_address 
                    moveq   #SFX_BATARANG,d0
                    jsr     AUDIO_PLAYER_INIT_SFX
                    ; fall through to player_state_firing below...



                    ; ------------------- player state - firing ---------------------
                    ; batman state used to handle firing of 'bat-a-rang' projectile
                    ;
                    ; IN:-
                    ;   - D0.w = L000067c2 - batman_x_offset
                    ;   - D1.w = L000067c4 - batman_y_offset
                    ;                    ; 
                    ; Code Checked 4/1/2025
                    ;
player_state_firing ; original address L00004ff6
                    movea.l batman_sprite_anim_ptr,a0   ; set sprite anim
                    bsr.w   set_batman_sprites
                    move.l  a0,batman_sprite_anim_ptr   ; update anim ptr (next frame)
                    tst.b   (a0)                        ; test end of anim
                    bne.b   .exit                       ; if not anim end, then exit
.set_state          ; L00005006
                    move.w  #$0008,state_parameter      ; count for animation (next state) - L000062f2
                    move.l  #player_state_fired,gl_jsr_address  ; set 'fired' state
.set_projectile     ; L00005012
                    bsr.w   get_empty_projectile                ; out: a0 = emptyprojectile entry (or end of list) - L0000463e
                    sub.w   #$0007,d0                   ; adjust x co-ord (assume left facing)
.check_direction    ; 0000501a
                    move.w  batman_sprite1_id,d2        ; get 'arms' sprite id
                    spl.b   d2                          ; d2 = -1 if right facing?
                    ext.w   d2                          ; extend to 16 bits
                    bpl.b   .set_handler_id
.is_right_facing    ; L00005024
                    add.w   #$000e,d0                   ; if right facing, adjust x co-ord            
.set_handler_id     ; L00005028 - set handler based on facing direction
                    addq.w  #$03,d2                     ; d2, either 02 or 03 (depending on left/right facing)                
                    move.w  d2,(a0)+                    ; set projectile handler Id (left or right)
.set_coords         ; L0000502c - set start x,y
                    sub.w   #$0010,d1                   ; adjust y co-ord
                    movem.w d0-d1,(a0)                  ; set starting projectile x,y
.exit               ; L00005034
                    rts  


; shared rts    - removed all dependancies.
;shared_exit_rts     ; L00005034
;L00005034           rts



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
player_state_fired  ; original address L00005036
                    move.b  player_input_command,d4                 ; get player input value
                    bne.w   .set_player_move_commands_state         ; if input the short-cut state and return to normal state processing
 
.test_state_counter ; L00005040
                    subq.w  #$01,state_parameter                    ; decrement state counter
                    beq.b   .set_batman_sprites                     ; if 0 then set complete animation, modified to aid readability - original 'bne.b   L00005034 (exit)'
                    rts                                             ; modified to aid readability - additional code

.set_batman_sprites ; L00005046
                    lea.l   batman_sprite_anim_standing,a0          ; L000063d3,a0
                    bra.w   set_batman_sprites                      ; L00004538
                    ; use 'rts' in set_batman_sprites to return

.set_player_move_commands_state  ; L0000504e
                    move.l  #player_move_commands,gl_jsr_address    ; L00003c90 ; Set Self Modifying code - GameLoop JSR - L00003c92 = jsr address (low word) - Default Value = $4c3e (run command loop)
                    bra.w   player_move_commands                    ; L00004c3e
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
player_state_climb_onto_platform    ; original address L00005058
L00005058           ;jsr     _DEBUG_COLOURS
                    subq.w  #$01,state_parameter            ; L000062f2
;L0000505c           bne.b   shared_exit_rts                ; inverted logic for readability
L0000505c           beq     L0000505e
                    rts

L0000505e           move.w  #$0006,state_parameter          ; L000062f2
L00005064           subq.w  #$05,batman_y_offset
L00005068           subq.w  #$04,d1
L0000506a           move.w  batman_sprite1_id,d2                     ; L000062ee,d2
L0000506e           bmi.b   L00005082
L00005070           addq.w  #$07,d0
L00005072           bsr.w   get_map_tile_at_display_offset_d0_d1        ; out: d2.b = tile value
L00005076           cmp.b   #$17,d2
L0000507a           bcs.b   L00005092
L0000507c           addq.w  #$01,batman_x_offset
L00005080           bra.b   L00005092
L00005082           subq.w  #$06,d0
L00005084           bsr.w   get_map_tile_at_display_offset_d0_d1        ; out: d2.b = tile value
L00005088           cmp.b   #$17,d2
L0000508c           bcs.b   L00005092
L0000508e           subq.w  #$01,batman_x_offset
L00005092           movea.l batman_sprite_anim_ptr,a0                ; modified to long pointer - L00006326,a0
L00005096           bsr.w   set_batman_sprites
L0000509a           move.l  a0,batman_sprite_anim_ptr                ; modified to long pointer - L00006326
L0000509e           move.b  (a0),d7
L000050a0           bne.b   L000050a8
L000050a2           move.l  #L00005414,gl_jsr_address   ; Return to Standing - update self modified code JSR game_loop
L000050a8           rts 




                    ; This appears to be calculating the left/right swing position
                    ; from a sin table multiplied by the rope length.
                    ; also, calculating the slight up/down as the cosine of the
                    ; x position.
                    ;
                    ; This may be wrong, as modifying this makes the hook firing fail.
                    ;
                    ;   IN:-
                    ;       a0 = L00006314 - grappling hook vars
                    ;                       (x, y, height, swing width?, swing height?)
L000050aa           lea.l   $007c(a0),a1            ; a1 = L00006390 - data table mid point?
L000050ae           move.w  (a0),d2                 ; d2 = hook x offset
L000050b0           asr.w   #$01,d2                 ; d2 = divide by 2
L000050b2           move.w  d2,d4                   ; d4 = copy of d2
L000050b4           bpl.b   L000050b8
L000050b6           neg.w   d4

L000050b8           clr.w   d3
L000050ba           move.b  -64(a1,d4.W),d3         ; -64 = start of sine table, d4 = modified X offset
L000050be           mulu.w  $0004(a0),d3            ; multiply by hook height
L000050c2           btst.l  #$000f,d2               ; check negative x
L000050c6           beq.b   L000050ca

L000050c8           neg.w   d3                      ; make value +ve

L000050ca           asr.w   #$08,d3                 ; divide by 256
L000050cc           move.w  d3,$0006(a0)            ; update hook width

L000050d0           move.w  d4,d2                   ; d2 = table index
L000050d2           neg.w   d2                      ; d2 = negative index
L000050d4           clr.w   d4
L000050d6           move.b  63(a1,d2.W),d4          ; end of table, d2 = negative index back into table
L000050da           mulu.w  $0004(a0),d4
L000050de           lsr.w   #$08,d4                 ; divide by 256
L000050e0           move.w  d4,$0008(a0)            ; store value
L000050e4           rts 




                    ; ------------ player input command - fire + up + right --------------
                    ; Player input command executed when the joystick 'fire + up + right'
                    ; is selected;
                    ;
                    ; IN:-
                    ;   - D0.w = L000067c2 - batman_x_offset
                    ;   - D1.w = L000067c4 - batman_y_offset
                    ;
                    ; Code Checked 6/1/2025
                    ;
player_input_cmd_fire_up_right  ; original address L000050e6
                    clr.w   batman_sprite1_id                       ; set right facing sprite
                    moveq   #$7f,d0                                 ; d0 = +127
                    bra.b   player_input_fire_up_common             ; L000050fa



                    ; ------------ player input command - fire + up + left --------------
                    ; Player input command executed when the joystick 'fire + up + left'
                    ; is selected;
                    ;
                    ; IN:-
                    ;   - D0.w = L000067c2 - batman_x_offset
                    ;   - D1.w = L000067c4 - batman_y_offset
                    ;
                    ; Code Checked 6/1/2025
                    ;
player_input_cmd_fire_up_left   ; original address L000050ee
                    move.w  #$e000,batman_sprite1_id                ; set left facing sprite
                    move.l  #$ffffff81,D0                           ; d0 = -127
                    bra.b   player_input_fire_up_common             ; L000050fa



                    ; ------------ player input command - fire + up --------------
                    ; Player input command executed when the joystick 'fire + up'
                    ; is selected;
                    ;
                    ; IN:-
                    ;   - D0.w = L000067c2 - batman_x_offset
                    ;   - D1.w = L000067c4 - batman_y_offset
                    ;
                    ; Code Checked 6/1/2025
                    ;
player_input_cmd_fire_up    ; original address L000050f8
                    clr.w   d0                                      ; d0 = 0
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
player_input_fire_up_common ; original address L000050fa
                    move.w  #$0048,target_window_y_offset           ; see more level above batman

                    ; L00005100 - initialise grappling hook state
.init_hook_vars     lea.l   grappling_hook_params,a0                ; grappling hook vars
                    move.w  d0,(a0)+                                ; store hook x offset = batman x offset
                    clr.l   (a0)+                                   ; clear hooky y and hook height?

                    ; L00005108 - create projectile for grappling hook
.create_projectile  bsr.w   get_empty_projectile                    ; a0 = address of empty projectile or the end of the list - L0000463e
                    ; a0 (handlerId, X, Y, Param - 8bytes)
                    move.w  #$0001,(a0)                             ; set projectile handler Id = batman_grappling_hook
                    move.l  #player_state_firing_grappling_hook,gl_jsr_address               ; Set state 'firing_grappling_hook' - game_loop Self Modified Code JSR

                    ; L00005116 - set initial sprite animation
.set_animation      lea.l   batman_sprite_anim_fire_hook,a0                ; L000063d0,a0
                    bsr.w   set_batman_sprites

                    ; L0000511e - play sound fx
.play_sfx           moveq   #SFX_BATROPE,d0
                    jsr     AUDIO_PLAYER_INIT_SFX

                    ; L00005126 - init d0,d1 for player_state, clear fire button input
.init_for_state     movem.w batman_xy_offset,d0-d1                  ; d0,d1 = batman x,y offset
                    bclr.b  #PLAYER_INPUT_FIRE,player_input_command ; clear firebutton input
                    
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
player_state_firing_grappling_hook  ; original address L00005132
L00005132           lea.l   grappling_hook_params,a0                    ; a0 = grappling hook params
L00005136           btst.b  #PLAYER_INPUT_FIRE,player_input_command
L0000513e           bne     stop_grappling_hook                         ; if fire pressed then, stop grappling hook

.no_fire            ; L00005140
                    move.w  $0004(a0),d2                                ; d2 = hook height

.increment_height   ; L00005144 - make batrope longer (slows down as it get longer)
                    ; if longer than 40 then increment = 2.
                    ; if between 20 and 40 then increment by 3.
                    ; if shorter than 20 increment by 4.
                    addq.w  #$02,d2                                     ; increment by 2
.check_len_40       ; L00005146
                    cmp.w   #$0028,d2                                   ; compare 40 (80 pixels)
                    bcc.b   .L00005156                                  ; if height >= 40 then
.increment_len_1    ; L0000514c
                    addq.w  #$01,d2                                     ; if height < 40 then increment by additional 1
.check_len_20       ; L0000514e
                    cmp.w   #$0014,d2                                   ; compare 20 (40 pixels?)
                    bcc.b   .L00005156                                  ; if height < 20 then increment by additional 1
.increment_len_2    ;L00005154
                    addq.w  #$01,d2

.L00005156           move.w  d2,$0004(a0)                                ; store new hook height
L0000515a           bsr.w   L000050aa

L0000515e           addq.w  #$03,d3
L00005160           move.w  batman_sprite1_id,d7
L00005164           bpl.b   L00005168

L00005166           subq.w  #$07,d3

L00005168           add.w   #$000a,d4
L0000516c           sub.w   d4,d1                                       ; update batman y
L0000516e           bcs.b   L000051a8

L00005170           move.w  scroll_window_y_coord,d5 
L00005174           add.w   d1,d5
L00005176           btst.l  #$0002,d5
L0000517a           bne.b   L000051ae
L0000517c           add.w   d3,d0                                       ; update batman x

L0000517e           bsr.w   get_map_tile_at_display_offset_d0_d1        ; out: d2.b = tile value
L00005182           cmp.b   #$17,d2
L00005186           bcs.b   L000051a8               ; set retract hook

L00005188           cmp.b   #$85,d2
L0000518c           bcc.b   L000051a8               ; set retract hook

L0000518e           cmp.b   #$79,d2
L00005192           bcs.b   L000051ae               ; exit

                    ; grabed platform
L00005194           move.l  #player_state_grappling_hook_attached,gl_jsr_address               ; Set game_loop Self Modified Code JSR
L0000519a           move.l  L0000631a,L00006328

L000051a0           lea.l   batman_sprite_anim_07,a0                ; L00006416,a0
L000051a4           bra.w   set_batman_sprites
                    ; use 'rts' in set_batman_sprites to return

                    ; wall, ladder, collision
                    ; retract grappling hook state
L000051a8           move.l  #player_state_retract_grappling_hook,gl_jsr_address               ; Set game_loop Self Modified Code JSR
L000051ae           rts




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
player_state_retract_grappling_hook ; orignal address L000051b0
                    lea.l   grappling_hook_params,a0                            ; grappling hook vars
                    btst.b  #PLAYER_INPUT_FIRE,player_input_command      
                    beq.b   shorten_grappling_hook                              ; L000051c4
                    ; if fire is pressed then shortcut the retraction.
                    ; fall through to stop_grappling_hook

                    ; IN:-
                    ;   a0.l = L00006314  (offset 4 = grappling hook height)
                    ;
stop_grappling_hook ; original address L000051be
                    move.w  #$0002,$0004(a0)                        ; force grappling hook height to 2.
shorten_grappling_hook  ; L000051c4
                    subq.w  #$03,$0004(a0)                          ; shorten grappling hook height by 3
                    bls.b   exit_fire_grappling_hook_state          ; if negative, then exit state
                    bra.w   L000050aa



exit_fire_grappling_hook_state  ; original address L000051ce
L000051ce           clr.w   $0004(a0)
L000051d2           move.l  #player_move_commands,gl_jsr_address    ; L00003c90 ; Set Self Modifying code - GameLoop JSR - L00003c92 = jsr address (low word) - Default Value = $4c3e (run command loop)
L000051d8           lea.l   batman_sprite_anim_standing,a0                ; L000063d3,a0
L000051dc           bra.w   set_batman_sprites
L000051e0           rts 




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
                    ; Code Checked 3/1/2025
                    ;
player_check_climb_down ; original address L000051e2
                    move.w  #$0028,target_window_y_offset           ; move batman up in display window (show more bottom)
                    move.w  scroll_window_x_coord,d2                ; 
                    add.w   d0,d2                                   ; get batman x co-ord in world
                    and.w   #$0007,d2                               ; get soft scroll value low 3 bits (0-7)
                    subq.w  #$04,d2                                 
                    bne.b   .exit                                   ; if batman not halfway across tile, then exit
                    ; L000051f6 - check tile at batman position
                    bsr.w   get_map_tile_at_display_offset_d0_d1    ; out: d2.b = tile value
                    cmp.b   #$85,d2                                 ; test tile at batman location                              
                    bcs.b   .exit                                   ; tile <= 133
                    bra.b   set_player_state_climbing               ; tile >= 134
.exit               rts                                             ; added for readability L000051e0




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
player_input_cmd_up ; original address L00005202
                    bsr.b   input_up_common
                    ;bra.w   L00005430                      ; replaced code to aid readability
                    lea.l   batman_sprite_anim_standing,a0  ; modified code to aid readability
                    bra.w   set_batman_sprites              ; modified code to aid readability
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
input_up_common     ; original address L00005208
                    move.w  #$0048,target_window_y_offset           ; window, show more level above batman
                    move.w  scroll_window_x_coord,d2           
                    add.w   d0,d2                                   ; d2 = window Y + batman Y
                    and.w   #$0007,d2                               ; d2 = soft scroll value (0-7)
                    subq.w  #$04,d2
                    bne.b   .exit                                   ; if not 8 pixel boundary, exit

                    ; every 8 pixel boundary
                    ; check tile above batman
                    sub.w   #$000c,d1                               ; batman Y - 12 (24 pixels)
                    bsr.w   get_map_tile_at_display_offset_d0_d1    ; d2.b = tile value
                    add.w   #$000c,d1
                    cmp.b   #$85,d2                             ; if tile >= 133, thhen climbing
                    bcc.b   set_player_state_climbing           ; inverted logic (aid readability)
;L0000522c           bcs.b   L000051e0
.exit               ; new code (aid read ability)
                    rts



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
                    ; Code Checked 3/1/2025
                    ;
set_player_state_climbing   ; original address L0000522e
                    addq.w  #$04,a7                                     ; manipulate the stack. remove last return address to prevent default processing.
                    and.b   #$0c,player_input_command                   ; mask input bits leaving up and down state flags
                    move.l  #state_climbing_stairs,gl_jsr_address       ; Update game_loop player state processing
                    bra.w   state_climbing_stairs                       ; do climb stairs






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
player_input_cmd_down_right ; original address L00005240
                    bsr.b   player_check_climb_down                 ; L000051e2
                        ; if on a ladder then manipulates stack to return to caller
                        ; does not execute the following code.
                    bra.b   player_input_cmd_right                  ; perform common move right processing




                    ; ------------------- player input command - up right ------------------
                    ; Command executed when joystick input is set to diagonal 'up-right'
                    ;;
                    ; IN:-
                    ;   - D0.w = L000067c2 - batman_x_offset
                    ;   - D1.w = L000067c4 - batman_y_offset
                    ;
                    ; Code Checked 4/1/2025
                    ;
player_input_cmd_up_right   ; original address L00005244
L00005244           bsr.b  input_up_common                          ; L00005208  ; jmp table CMD7
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
player_input_cmd_right      ; original address L00005246

.wall_collider      ; test wall collision
                    addq.w  #$04,d0                                 ; add 4 to batman_x_offset
                    subq.w  #$02,d1                                 ; sub 2 from batman_y_offset
                    bsr.w   get_map_tile_at_display_offset_d0_d1    ; get tile 8 pixels to batman's right, middle, out: d2.b = tile value
                    cmp.b   #$17,d2
                    bcs.b   .exit                                   ; if tile > 23 then exit (wall I guess - can't move)

.update_x_pos       ; move batman to right (2 pixels)
                    addq.w  #$01,batman_x_offset                    ; increment batman x offset by 1

.platform_collider  ; L00005258 - test platform collison (14 pixels below)
                    addq.w  #$07,d1                                 ; d1 (y offset), already decremented by 2, increment by further 7 (+5)
                    subq.w  #$05,d0                                 ; d0 (x offset), already incremented by 4, decrement by further 5 (-1)
                    bsr.w   get_map_tile_at_display_offset_d0_d1    ; out: d2.b = tile value (tile by feet?)
                    sub.b   #$79,d2                                 ; #$79 (121)
                    cmp.b   #$0d,d2                                 ; check tile is >= 134
                    bcc.w   set_player_state_falling                ; if tile >= 134 then set falling

                    ; L0000526c - tile 121-133
                    ; update batman walk sprite animation
                    ; uses scroll position to choose animation
.set_animation      ; frame
                    lea.l   batman_sprite3_id,a0                    ; L000062ea,a0
                    add.w   scroll_window_x_coord,d0                ; d0 = world x co-ord
                    lsr.w   #$01,d0                                 ; divide window x co-ord by 2 (already divied by 2, now divided by 4)
                    and.w   #$0007,d0                               ; take value 0-7 (resolution 4 pixels)
                    addq.w  #$05,d0                                 ; 5 base value for sprite animation (legs?)                        
.set_sprite3        move.w  d0,(a0)+                                ; set sprite id value (range 5 - 13 decimal)

                    ; L0000527e - sprite 2 - batman arms
                    and.w   #$0006,d0                               ; animate arms at half speed to legs.
                    lsr.w   #$01,d0                                 ; convert into range 0 - 3
                    bne.b   .inc_sprite2

.rst_sprite2        moveq   #$02,d0                                 ; reset arms  animation frame to #$02 

.inc_sprite2        ; L00005288
                    addq.w  #$01,d0                                 ; increment arms animation
.set_sprite2        move.w  d0,(a0)+                                ; set sprite 2 (arms/body anim)

                    ; batman head
.set_sprite1        move.w  #$0001,(a0)                             ; set head spprite frame

                    ; L00005290
.exit               rts                                             ; added for readability




                    ; ----------- player_move_commands - input NOP -------------
                    ; Called by player_move_commands default input routine.
                    ; performs a op-operation for unexpected input values.
                    ; Also called as a quick exit from other routines.
                    ;
                    ; Code Checked 3/1/2025
                    ;
player_input_cmd_nop    ; original address L00005290
                    rts                      





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
player_input_cmd_down_left        ; original address L00005292
                    bsr.w   player_check_climb_down                         ; L000051e2
                        ; if on a ladder then manipulates stack to return to caller
                        ; does not execute the following code. 
                    bra.w   player_input_cmd_left                           ; L0000592c 



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
player_input_cmd_up_left       ; original address L00005298
                    bsr.w   input_up_common                     ; L00005208  ; Jump Table CMD8
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
player_input_cmd_left   ; original address L0000529c

.wall_collider      ; L0000529c - test wall collision
                    subq.w  #$05,d0                                 ; sub 5 from batman x
                    subq.w  #$02,d1                                 ; sub 2 from batman y
                    bsr.w   get_map_tile_at_display_offset_d0_d1    ; out: d2.b = tile value
                    cmp.b   #$17,d2
                    bcs.b   player_input_cmd_nop                    ; if tile > 23 then exit

.update_x_pos       ; L000052aa - move batman left (2 pixels)
                    subq.w  #$01,batman_x_offset                    ; decrement batman x

.platform_collider  ; L000052ae - test platform collision (10 pixels below)
                    addq.w  #$07,d1                                 ; d1 (y offset), already decremented by 2, increment by further 7 (+5)
                    addq.w  #$05,d0                                 ; d0 (x offset), already decremented by 5, increment by further 5 (0)
                    bsr.w   get_map_tile_at_display_offset_d0_d1    ; out: d2.b = tile value
                    sub.b   #$79,d2                                 ; #$79 (121)
                    cmp.b   #$0d,d2                                 ; check tile is >= 134
                    bcc.w   set_player_state_falling                ; if tile >= 134 then set falling

                    ; L000052c2 - tile 121 - 133?
                    ; update batman walk sprite animation
                    ; uses scroll position to choose animation
.set_animation      ; frame - L000052c2                  
                    lea.l   batman_sprite3_id,a0        ; L000062ea,a0
                    add.w   scroll_window_x_coord,d0    ; L000067bc,d0                ; updated_batman_distance_walked
                    not.w   d0
                    lsr.w   #$01,d0
                    and.w   #$0007,d0
                    add.w   #$e005,d0                   ; set left facing ($e000) and base value 5 for leg animation frame
.set_sprite3        move.w  d0,(a0)+                    ; set sprite id value (range 5 - 13 decimal)

                    ; L000052d8 - sprite 2 - batman arms
                    and.w   #$e006,d0
                    lsr.b   #$01,d0
                    bne.b   .inc_sprite2                ;  L000052e4

.rst_sprite2        move.w  #$e002,d0

.inc_sprite2        ; L000052e4
                    addq.w  #$01,d0
.set_sprite2        move.w  d0,(a0)+ 

                    ; L000052e8 - batman head
.set_sprite1        move.w  #$e001,(a0)

                    ; L000052ec
.exit               rts 



                    ; L000052ec - shared rts - TODO: remove dependency
L000052ec           rts



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
                    ; Code Checked 3/1/2025
                    ;
exit_climbing_state ; original address L000052ee
                    add.w   d5,d3
                    move.b  $00(a0,d3.W),d2                         ; Get map tile to left/right of batman
                    sub.b   #$79,d2                                 ; 121
                    cmp.b   #$0d,d2                                 ; if tile in range >= 134
                    bcc.w   L00005362           ; L00005368                               ; if tile >= 134, return to climbing? (Does this even execute? looks dodgy)
                    ; return to normal joystick movement state.
                    ; back on a platform.
                    ; L000052fe - Tile 121-133
                    move.l  #player_move_commands,gl_jsr_address    ; return to normal joystick handler
                    bra.w   player_move_commands                    ; call normal joystick handler.





                    ; ----------------- batman climb stairs -------------------
                    ; inserted into game loop self modified code for batman
                    ; control state updates.
                    ; state is entered via the up/down input command handlers
                    ;
                    ; IN:-
                    ;   - D0.w = L000067c2 - batman_x_offset
                    ;   - D1.w = L000067c4 - batman_y_offset
                    ;
                    ; Code Check 3/1/2025
                    ;
state_climbing_stairs  ; original address L00005308
                    btst.b  #PLAYER_INPUT_FIRE,player_input_command 
                    bne.w   set_player_state_falling                    ; Fire button pressed

                    ; L00005312 - check 25hz
                    btst.b  #$0000,playfield_swap_count+1               ; test even/odd playfield buffer swap value
                    bne     L000052ec                                   ; exit (25hz) L000052ec
                    
                    ; L0000531a - check if on tile boundary
                    clr.w   d4
                    move.b  player_input_command,d4                     ; L00006308,d4
                    move.w  scroll_window_y_coord,d2                    ; L000067be,d2
                    add.w   d1,d2                                       ; add batman y offset to scroll y
                    and.w   #$0007,d2                                   ; d2 = soft scroll value (0-7)
                    beq.b   on_tile_boundary                            ; on 16 pixel boundary, check left/right

climb_through_tile  ; L0000532c - climbing through a tile
                    btst.l  #PLAYER_INPUT_DOWN,d4
                    beq.b   L0000533a
.climb_down_in_tile                    
                    addq.w  #$01,d1                                     ; increment batman Y
                    move.w  #$0028,target_window_y_offset               ; show more level below batman

                    ; L0000533a - 
L0000533a           btst.l  #PLAYER_INPUT_UP,d4
                    beq.b   L00005348
.climb_up_in_tile
                    subq.w  #$01,d1                                     ; decrement batman Y
                    move.w  #$0048,target_window_y_offset               ; show more level above batman

                    ; L00005348 - store updated Y position
L00005348           move.w  d1,batman_y_offset
                    bra.b   L000053a6
                    ;----------------------

on_tile_boundary    ; L0000534e - on tile boundary - check climb exit
                    bsr.w   get_map_tile_at_display_offset_d0_d1        ; out: d2.b = tile value
                    move.w  d4,d5                                       ; copy player input command
                    and.b   #$03,d5                                     ; mask all but bits 0 & 1 (LEFT/RIGHT)
                    move.b  d5,player_input_command                     ; L00006308

                    ; L0000535c - check push right (exit climb)
                    moveq   #$01,d5                                     ; +1 (check tile to right)
                    asr.w   #$01,d4                                     ; c = 1 if input = right
                    bcs.w   exit_climbing_state                         ; if right then, exit climb ladder state 

                    ; L00005362 - check push left (exit climb)
L00005362           MOVE.L  #$ffffffff,D5                               ; -1 (check tile to left)
L00005368           asr.w   #$01,d4                                     ; c = 1 if input = left
                    bcs.w   exit_climbing_state                         ; if left then, exit climb ladder state

                    asr.w   #$01,d4                                     ; c = 1 if input = up
                    bcc.b   climb_up                                    ; if down then, climb up

climb_down          ; L0000536c
                    move.w  #$0028,target_window_y_offset               ; L000067c6
                    cmp.b   #$85,d2                                     ; compare tile value 133
                    bcs.w   set_player_move_commands_state              ; if tile < 133, return to joystick control state

                    ; L0000537a - climb down 2 pixels -tile >=134
                    addq.w  #$01,batman_y_offset
                    bra.b   L000053a6

climb_up            ; L00005380
                    asr.w   #$01,d4                                     ; c = 1 if input is up
                    bcc.b   exit_L000053cc                              ; L000053cc

                    ; L00005384
                    move.w  #$0048,target_window_y_offset               ; move window to show level above batman
                    move.w  MAPGR_BASE,d5                               ; d5 = map width from MAPGR.IFF (value = $00c0)
                    sub.w   d5,d3
                    sub.w   d5,d3
                    sub.w   d5,d3                                       ; offset up 3 tiles? (tile above batman's head?)
                    ; L00005396
                    move.b  $00(a0,d3.W),d2                             ; get tile above batman's head
                    cmp.b   #$85,d2                                     ; compare tile value 133
                    bcs.b   set_player_move_commands_state              ; if tile < 133 return to normal joystick control state

                    ; L000053a0
                    subq.w  #$01,d1                                     ; climb ladder (2 pixels)
                    move.w  d1,batman_y_offset                          ; store new Y position

                    ; L000053a6 - set sprite animation for climbing
L000053a6           move.w  scroll_window_y_coord,d2                    ; L000067be,d2
                    add.w   batman_y_offset,d2
                    addq.w  #$02,d2
                    not.w   d2
                    and.w   #$0007,d2
                    bclr.l  #$0002,d2
                    beq.b   L000053c0
                    
                    add.w   #$e000,d2                                   ; alternate left/right sprite image
                    ; L000053c0 
L000053c0           add.w   #$0020,d2                                   ; add base sprite id for climbing
                    lea.l   batman_sprite3_id,a0                        ; 1st sprite id
                    clr.l   (a0)+                                       ; clear sprite ids 3 & 2
                    move.w  d2,(a0)                                     ; set sprite 1 id

exit_L000053cc      ; L000053cc
                    rts 




set_player_move_commands_state
L000053ce           move.l  #player_move_commands,gl_jsr_address    ; L00003c90 ; Set Self Modifying code - GameLoop JSR - L00003c92 = jsr address (low word) - Default Value = $4c3e (run command loop)
L000053d4           rts



                    ; ------------------ player input command - fire + down ---------------------
                    ; Player input command called when joystick input 'fire and down' is selected
                    ; Also, used as game_loop state update routine $00005f38
                    ;
                    ; IN:-
                    ;   - D0.w = L000067c2 - batman_x_offset
                    ;   - D1.w = L000067c4 - batman_y_offset
                    ;
                    ; Code Check 4/1/2025
                    ;
player_input_cmd_fire_down     ; original address L000053d6
                    add.w   #$0008,d1                              ; update y co-ord
                    bsr.w   get_map_tile_at_display_offset_d0_d1   ; out: d2.b = tile value
                    movem.w batman_xy_offset,d0-d1                 ; d0,d1 = x,y co-ords
                    cmp.b   #$17,d2
                    bcs.b   player_input_cmd_down                  ; if tile < 17, then do notmal down processing

.fall_through_platform ; L000053ea - fall through platform
                    move.w  #$8000,L00005506                       ; temporarily disable platform collision by overwritting 'nop' with self modifying code - 'or.b d0,d0'
                    bra.w   set_player_state_falling               ; L0000545a
                    ; use 'rts' in set_player_falling_state to return



                    ; ------------------ player input command - down ---------------------
                    ; Player input command called when joystick input 'down' is selected
                    ;
                    ; IN:-
                    ;   - D0.w = L000067c2 - batman_x_offset
                    ;   - D1.w = L000067c4 - batman_y_offset
                    ;
                    ; Code Check 4/1/2025
                    ;
player_input_cmd_down   ; original address L000053f4
                    bsr.w   player_check_climb_down                 ; L000051e2
                        ; if on a ladder then manipulates stack to return to caller
                        ; does not execute the following code.
                    lea.l   batman_sprite_anim_ducking,a0           ; L000063d6,a0
                    bsr.b   set_batman_sprites
                    move.l  #player_state_ducking,gl_jsr_address    ; L00003c90 ; Set Self Modifying Code - game_loop JSR
                    rts



                    ; ----------------------- player state - ducking --------------------
                    ; The state entered into the game_loop when batman is ducking down.
                    ;
                    ; Code Checked 4/1/2025
                    ;
player_state_ducking    ; original address L00005406
                    lea.l   batman_sprite_anim_ducked,a0
                    bsr.b   set_batman_sprites
                    btst.b  #PLAYER_INPUT_DOWN,player_input_command ; L00006308
                    bne.b   ps_ducking_check_firebutton
L00005414
.return_to_standing ; L00005414                   
                    move.l  #set_player_state_standing,gl_jsr_address
                    lea.l   batman_sprite_anim_ducking,a0    
                    bra.b   set_batman_sprites
                    ; uses 'rts' in set_batman_sprites to return

ps_ducking_check_firebutton   ; L00005420 - ducking and firing doesn't do anything (same on original game)
                    btst.b  #PLAYER_INPUT_FIRE,player_input_command
                    bne.b   player_input_cmd_fire_down
                    rts 



                    ; --------------- set player status - standing ---------------
                    ; Called when leaving the 'ducked' state. Returns batman to
                    ; a standing sprite and standard input checing.
                    ;
                    ; Code Checked 4/1/2025
                    ;
set_player_state_standing   ; original address L0000542a
                    move.l  #player_move_commands,gl_jsr_address    ; L00003c90 ; Set Self Modifying code - GameLoop JSR - L00003c92 = jsr address (low word) - Default Value = $4c3e (run command loop)
                    lea.l   batman_sprite_anim_standing,a0                ; L000063d3,a0
                    bra.w   set_batman_sprites
                    ; use 'rts' in set_batman_sprites to return



                    ; ----------------- set batman sprites --------------------
                    ; Sets batman sprites 1, 2 & 3 from the values passed in 
                    ; the 3 byte array.
                    ;
                    ; IN: 
                    ;   A0.l = address ptr to animation (3 byte array of sprite id's)
                    ; 
set_batman_sprites                                                  ; original address L00005438
                    move.w  d7,-(a7)                        ; save d7
                    lea.l   batman_sprite1_id,a1
                    ; preserve left/right facing directions
                    move.w  (a1),d7
                    and.w   #$e000,d7
                    ; set first sprite id
                    add.b   (a0)+,d7
                    move.w  d7,(a1)
                    ; add second sprite id offset
                    add.b   (a0)+,d7
                    move.w  d7,-(a1)
                    ; add thrid sprite id offset
                    add.b   (a0)+,d7
                    move.w  d7,-(a1)
                    ; restore registers & exit
                    move.w  (a7)+,d7                        ; restore d7
                    rts 


batman_sprite_anim_falling       ; original address L00005454
                    dc.b    $0d,$01,$01                     ; 13, 14, 15

batman_sprite_anim_fall_landing  ; original address L00005457
                    dc.b    $11,$ff,$02                     ; 11, 10, 12




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
set_player_state_falling    ; original address L0000545a
                    movem.w batman_xy_offset,d0-d1                  ; d0,d1 = batman X,Y
                    clr.l   batman_swing_fall_speed                      ; L000062f4                               ; falling speed/distance
                    ; L00005464
L00005464           move.w  batman_y_offset,target_window_y_offset  ; set batman Y as target for centre window
                    lea.l   batman_sprite_anim_falling(pc),a0            ; L00005454(pc),a0                        ; 3 sprite id array
                    bsr.w   set_batman_sprites
                    move.l  #player_state_falling,gl_jsr_address    ; Set game_loop Self Modifying Code JSR 
                    move.w  #$ffff,L000062fa                        ; -1
                    clr.w   batman_fall_distance                    ; L000062f8                               ; 0




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
player_state_falling    ; original address L00005482
                    movem.w batman_swing_fall_speed,d4-d5        ; L000062f4,d4-d5         ; maybe fall speed/distance
                    move.w  d4,L0000630e
                    beq.b   .L000054cc

                    ; L0000548e
                    sub.w   #$0010,d1               ; subtract 16 from player Y
                    subq.w  #$04,d0                 ; subtract 4 from player X
                    add.w   d4,d0                   ; add offset to player X
                    bsr.w   get_map_tile_at_display_offset_d0_d1        ; out: d2.b = tile value
                    ; d2 = tile id
                    ; a0.l = tilemap ptr
                    ; d3.w = index into tile map
                    movem.w batman_xy_offset,d0-d1
                    moveq   #$01,d7                 ; loop counter
                    ; check for block of 4 wall tiles
                    ; if is wall tile then jmp L000054c8
.L000054a2          cmp.b   #$17,d2                 ; test wall tile
                    bcs.b   .L000054c8               ; is wall tile?

                    ; L000054a8
                    move.b  $01(a0,d3.w),d2         ; check next map tile
                    cmp.b   #$17,d2                 ; test wall tile
                    bcs.b   .L000054c8               ; is wall tile

                    ; L000054b2
                    add.w   MAPGR_BASE,d3           ; add map width (value = $00c0)
                    move.b  $00(a0,d3.w),d2         ; get tile 1 line down in d2
                    dbf.w   d7,.L000054a2
                    ; end of wall tile loop ttest

                    ; L000054c0 - do fall/swing x-axis
                    add.w   d0,d4                   ; add fall x speed to batman x pos
                    move.w  d4,batman_x_offset
                    bra.b   .L000054cc

                    ; L000054c8
.L000054c8          clr.w   batman_swing_speed      ; L000062f4               ; fall speed/distance?

                    ; L000054cc - do fall y-axis
.L000054cc          cmp.w   #$0010,d5
                    bpl.b   .L000054d4               ; clamp fall speed to 16
                    addq.w  #$01,d5                 ; else. increment fall speed
.L000054d4          move.w  d5,batman_fall_speed    ; L000062f6
                    ; L000054d8
                    asr.w   #$02,d5                 ; divide fall speed by 4
                    add.w   d5,d1                   ; add fall speed to batman Y position
                    move.w  d1,batman_y_offset      ; store new batman Y position
                    btst.l  #$000f,d1               ; test sign bit of Y position
                    beq.b   .L000054e8
                    rts                             ; d1 is negative, then exit?

.L000054e8          bsr.w   get_map_tile_at_display_offset_d0_d1    ; out: d2.b = tile value
                    cmp.b   #$17,d2                                 ; test tile value
                    bcc.b   .L000054fe                               ; if not wall, 
 
                    ; L000054f2 - Is Wall?
                    subq.w  #$07,batman_y_offset                    ; move up 14 pixels
                    movem.w batman_xy_offset,d0-d1                  ; get X,Y
                    bra.w   player_state_falling                    ; re-try player falling
                    ; ---------------------------

.L000054fe          sub.b   #$79,d2                     ; subtract 121 from tile id
                    cmp.b   #$0d,d2                     ; compare tile with 134 (platform)

                    ; L00005506 - self modified 'nop' or 'or.b d0,d0'
                    ; when 'nop' ccr is not altered for tile test above. (falling off platform)
                    ; when 'or.b d0,d0' ccr depends on value of d0. (input fire-down)
                    ; THIS IS USED TO PREVENT COLLISION OCCURING WITH
                    ; THE PLATFORM YOU ARE DROPPING THROUGH
L00005506           nop                                             ; #$8000 = or.b d0,d0

                    ; L00005508 - save status register
                    move.w  sr,d6                       ; store all SR & CCR bits
                    add.w   batman_fall_distance,d5     ; add value fall distance to fall speed
                    move.w  d5,batman_fall_distance     ; store new fall distance
                    cmp.w   #$0008,d5
                    bcs.b   .L0000551e                   ; if not fallen 16 pixels, continue
                    move.w  #$4e71,L00005506            ; else, re-insert 'nop' above to enable platform collisions again
                    ; L0000551e - restore status register
.L0000551e          move.w  d6,sr               ; restore all SR & CCR bits

                    ; ccr either tile compare, or value of d0.
                    bcc.b   .exit               ; if tile is >= 134 and 'nop', then exit

                    ; tile is 121-134 (platform?)
                    ; landing on platform/floor
                    ; L00005522
                    move.w  #$0028,target_window_y_offset       ; scroll window to show level below
                    lea.l   batman_sprite_anim_fall_landing,a0            ; L00005457,a0
                    bsr.w   set_batman_sprites      

                    ; L00005530 - batman landing (end falling?)
                    move.l  #player_state_fall_landing,gl_jsr_address           ; Set game_loop Self Modified Command JSR
                    clr.w   batman_fall_speed                   ; L000062f6
                    move.w  #$0001,L000062fa
                    move.w  #$0002,state_parameter              ; L000062f2
                    move.w  scroll_window_y_coord,d0 
                    add.w   d1,d0                       ; window y + batman y offset
                    and.w   #$0007,d0                   ; d0 = window soft scroll
                    sub.w   d0,d1                       ; subtract soft scroll
                    move.w  d1,batman_y_offset          ; set batman y offset to tile boundary?
.exit               rts




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
player_state_fall_landing   ; original address L0000555a
                    subq.w  #$01,state_parameter            ; L000062f2
                    bne.b   .exit_routine
 
                    ; L00005560 - test timer, life lost, no energy
.test_life_lost     tst.b   PANEL_STATUS_1                          ; Panel - Status Byte 1 - $0007c874
                    bne.w   set_state_player_life_lost              ; player dead?

                    ; L0000556a - reset state to joystick control state
.reset_control_state
                    move.l  #player_move_commands,gl_jsr_address            ; Set game_loop Self Modified Code JSR
                    lea.l   batman_sprite_anim_standing,a0                        ; L000063d3,a0

                    ; L00005576 - test fall distance
.test_fall_distance cmp.w   #$0050,batman_fall_distance                     ; 80 = max fall distance
                    bmi.w   set_batman_sprites                              ; a0 = 3 sprite array
                    ; use rts in set_batman_sprites to exit

                    ; L00005580 - batman fell too far
.fell_too_far       moveq   #$5a,d6                                         ; Value of Energy to Lose (90) - DEAD! (max is 48?)
                    bsr.w   batman_lose_energy
                    move.b  #PANEL_ST2_VAL_LIFE_LOST,PANEL_STATUS_1         ; Set - LIFE LOST
                    btst.b  #PANEL_ST2_CHEAT_ACTIVE,PANEL_STATUS_2          ; Check - CHEAT ACTIVE
                    bne.b   .exit_routine                                   ; if cheat active, skip lose a life
                    
                    jmp     PANEL_LOSE_LIFE                                 ; Panel - Lose a Life - $0007c862
                    ; never return (use panel rts)

.exit_routine       ; L0000559e
                    rts




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
get_map_tile_at_display_offset_d0_d1  ; original address L00055a0
                    movem.w scroll_window_xy_coords,d2-d3   ; get display window co-ords
                    add.w   d0,d2                           ; add offset to window X co-ord
                    add.w   d1,d3                           ; add offset to window Y co-ord
                    lsr.w   #$03,d2                         ; calc tile map X co-ord
                    lsr.w   #$03,d3                         ; calc tile map Y co-ord
                    mulu.w  MAPGR_BASE,d3                   ; multiply Y co-ord by tile map width ($c0 - 192)
                    add.w   d2,d3                           ; add x and y offset to get tile index
                    lea.l   MAPGR_DATA_ADDRESS,a0           ; $0000807c,a0 - tile map start data address
                    clr.w   d2                              ; initialise return value = $00000000
                    move.b  $00(a0,d3.W),d2                 ; get tile from tile map
                    rts





                    ;------------------------------------------------------------------------------------------
                    ; -- Draw Batman and Rope
                    ;------------------------------------------------------------------------------------------
                    ; This routine draws the Batman Player and the Rope Swing
                    ;
draw_batman_and_rope  ; original address L000055c4
                    ;jmp     draw_batman_sprite
                    move.w  grappling_hook_height,d2    ; L00006318,d2 ; grappling hook distance/height
                    beq.w   draw_batman_sprite          ; L000056a6
                    movem.w batman_xy_offset,d0-d1
                    sub.w   #$000c,d1
                    addq.w  #$03,d0
                    move.w  batman_sprite1_id,d2        ; L000062ee,d2
                    bpl.b   L000055e0
                    subq.w  #$07,d0                     ; update X
L000055e0           add.w   d1,d1   
                    move.w  d1,d7
                    mulu.w  #DISPLAY_BYTEWIDTH,d1       ; $002a,d1
                    ror.w   #$03,d0
                    move.w  d0,d2
                    and.w   #$0fff,d2
                    add.w   d2,d2
                    add.w   d2,d1
                    ext.l   d1
                    add.l   playfield_buffer_2,d1       ;  L000036f6,d1

                    movem.w L0000631a,d2-d3         ; hook details (hook point?)
                    add.w   d2,d2
                    add.w   d3,d3
                    beq.w   draw_batman_sprite          ; L000056a6                   ; Jmp Draw Batman Sprite
                    ; Draw BatRope as blitter line draw
                    and.w   #$e000,d0
                    moveq   #$05,d4
                    or.w    d0,d4
                    btst.l  #$000f,d2
                    beq.b   L0000561c
                    neg.w   d2
                    bset.l  #$0003,d4
L0000561c           add.w   d2,d2
                    move.w  d2,d5
                    sub.w   d3,d5
                    bpl.b   L00005628
                    bset.l  #$0006,d4
L00005628           move.w  d5,d6
                    sub.w   d3,d6
                    sub.w   d3,d7
                    subq.w  #$03,d7
                    bpl.b   L00005634
                    add.w   d7,d3
L00005634           asl.w   #$06,d3
                    addq.w  #$02,d3
                    or.w    #$0bca,d0
                    swap.w  d0
                    move.w  d4,d0

                    ; L00005640
                    lea.l   $00dff000,a5

                    ; blit wait
                    btst.b  #$0006,$00dff002            ; added extra read for OCS
L00005646           btst.b  #$0006,$00dff002
                    bne.b   L00005646

                    ; set blitter for line draw
                    move.w  d2,$0062(a5)            ; Channel B modulo
                    move.w  d6,$0064(a5)            ; Channel A modulo
                    move.w  #$002a,$0066(a5)        ; Channel D modulo
                    move.w  #$002a,$0060(a5)        ; Channel C modulo
                    move.w  #$c000,$0074(a5)        ; A Data Register
                    move.l  #$ffffffff,$0044(a5)    ; Channel A First/Last word mask
                    move.w  #$eeee,d6               ; Line Pattern Data
                    moveq   #$03,d7                 ; bitplane count

                    ; blit wait
L00005678           btst.b  #$0006,$00dff002        ; added extra read for OCS
L00005678a          btst.b  #$0006,$00dff002
                    bne.b   L00005678a
                    ; draw rope (Line Draw)
                    move.w  d5,$0052(a5)            ; A Channel
                    move.l  d0,$0040(a5)            ; BLTCON0
                    move.l  d1,$0048(a5)            ; C Channel
                    move.l  d1,$0054(a5)            ; D Channel
                    move.w  d6,$0072(a5)            ; B Data Register (line pattern)
                    move.w  d3,$0058(a5)            ; Blit Size
                    add.l   #DISPLAY_BUFFER_BYTES,d1    ;  $00001c8c,d1           ; next bitplane dest offset
                    not.w   d6                      ; invert mask/line pattern?
                    dbf.w   d7,L00005678            ; loop next bitplane

                    ; draw first Batman Sprite
draw_batman_sprite  ; original address L000056a6
                    movem.w batman_xy_offset,d0-d1                      ; batman object X & Y co-ords
                    move.w  batman_sprite1_id,d2                        ; sprite id
                    clr.w   d4
                    move.b  d2,d4
                    beq.w   exit_draw_batman                            ; if (sprite id) == 0 then exit
                    move.w  d1,d3                                       ; d1 = Y co-ord
                    lea.l   display_object_coords,a0                    ; L0000607c,a0            ; unknown table 
                    add.w   d4,d4                                       ; sprite id * 2
                    add.w   d3,d3                                       ; Y co-ord * 2
                    sub.b   -2(a0,d4.W),d3                              ; modify Y co-ord
                    asr.w   #$01,d3                                     ; divide y by 2 (X & Y stored as halved values)
                    move.w  d3,batman_y_bottom                          ; L000062f0                                ; store update Y co-ord
                    bsr.b   draw_sprite                                 ; Draw Batman Part - L000056f4

                    ; draw second Batman Sprite ; L000056ce
                    movem.w batman_xy_offset,d0-d1                      ; batman object X & Y co-ords
                    move.w  batman_sprite2_id,d2                        ; sprite id            
                    move.b  d2,d2
                    beq.w   exit_draw_batman                            ; if (sprite id) == 0 then exit
                    bsr.b   draw_sprite

                    ; draw third Batman Sprite; L000056e0
                    movem.w batman_xy_offset,d0-d1                      ; batman object X & Y co-ords
                    move.w  batman_sprite3_id,d2                        ; sprite id
                    move.b  d2,d2
                    beq.w   exit_draw_batman                            ; if (sprite id == 0) then exit
                    bsr.b   draw_sprite

exit_draw_batman    ; L000056f2
                    rts 



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
draw_sprite                                         ; original address $L000056f4
L000056f4           movea.l sprite_array_ptr,a1     ; L000062fe,a1        ; Sprite Structure Data Pointer
                    add.w   d1,d1                   ; d1 = d1 * 2
                    asl.w   #$03,d2                 ; d2 = d2 * 8 (sprite structure 8 bytes?)
                    lea.l   -8(a1,d2.W),a1          ; a1 = sprite data structure.
                    bcc.b   right_facing_sprite     ; L00005724 ; if d2 < 8192 (8k) then JMP 5724

                    ; Left Facing Sprite     
left_facing_sprite                                  ; original address L00005702
                    ; update X & Y with sprite offset            
                    move.b  (a1)+,d4                ; get sprite y offset
                    ext.w   d4                      ; extend to word length
                    sub.w   d4,d1                   ; subtract y offset from Y position
                    move.b  (a1)+,d4                ; get sprite x offset
                    ext.w   d4                      ; extend to word length
                    add.w   d4,d0                   ; add x offset to X position
                    clr.w   d2

                    ; get sprite width, height and gfx address ptr
                    move.b  (a1)+,d2                ; get sprite width in words
                    move.w  d2,d4                   ; d4 = copy of sprite width in words
                    lsl.w   #$03,d4                 ; multiply width by 8
                    sub.w   d4,d0                   ; subtract width from X position value
                    clr.w   d3
                    move.b  (a1)+,d3                ; get sprite height in lines
                    movea.l (a1)+,a0                ; get sprite gfx ptr (mask,bpl0,bpl1,bpl2,bpl3) ; a0 = start of gfx mask data
                    adda.l  sprite_gfx_left_offset,a0    ; L00006302,a0            ; additional code for left facing sprite
                    bra.b   calc_sprite_size        ; L0000573a

                    ; Right Facing Sprite
right_facing_sprite                                 ; original address L00005724
                    move.b  (a1)+,d4                ; get sprite y ofset - d4 = offset value.b
                    ext.w   d4                      ; d4 = offset value.w
                    sub.w   d4,d1                   ; Subtract d4 from Y co-ordinate value
                    move.b  (a1)+,d4                ; get sprite x offset - d4 = offset value.b
                    ext.w   d4                      ; d4 = offset value.w
                    sub.w   d4,d0                   ; Subtract d4 from X co-ordinate value
                    clr.w   d2                      ; init d2 = #$0.w
                    move.b  (a1)+,d2                ; sprite width in words- d2 = value.b
                    clr.w   d3                      ; init d3 = #$0.w
                    move.b  (a1)+,d3                ; sprite height in lines
                    movea.l (a1)+,a0                ; get sprite gfx ptr (mask,bpl0,bpl1,bpl2,bpl3) ; a0 = start of gfx mask data

                    ; left/right facing common processing
calc_sprite_size                                    ; original address L0000573a
                    move.w  d3,d4
                    mulu.w  d2,d4                   ; d4 = d3 * d2
                    add.l   d4,d4                   ; d4 = d4 * 2
                    movea.l d4,a1                   ; a1 = size of sprite bitplane (bytes)

                    ; sprite Y display clipping
sprite_y_clipping
                    ; check top of sprite on screen
                    move.w  d1,d1
                    bpl.b   clip_bottom_display     ; L00005758 ; top of sprite Y is +ve
                    ; top of sprite is -ve (i.e. off screen)
                    neg.w   d1                      ; y = y * -1
                    sub.w   d1,d3                   ; subtract sprite top from bottom
                    bls.w   exit_draw_sprite        ; L00005852 ; exit if whole sprite is off top of display

                    ; adjust gfx ptr 
                    ; clip top of sprite by the amount off top of display
                    ; d1 = number of lines to clip
                    ; d2 = sprite width
                    mulu.w  d2,d1
                    adda.l  d1,a0                           ; a0 = start of gfx mask data
                    adda.l  d1,a0                           ; a0 = start of gfx mask data
                    moveq   #$00,d1
                    bra.b   sprite_x_clipping               ; L00005768

                    ; check sprite top co-ord is off bottom of screen
clip_bottom_display
                    move.w  #$00ad,d6               ; #$ad = 173 (display window height)
                    sub.w   d1,d6                   ; subtract Y position from screen height
                    bls.w   exit_draw_sprite        ; L00005852 ; exit if sprite is off bottom of screen

                    ; check sprite bottom co-ord is off bottom of screen
                    ; if so, set bottom to display window size
                    cmp.w   d3,d6                   ; d3 = bottom of sprite
                    bpl.b   sprite_x_clipping       ; L00005768
                    move.w  d6,d3                   ; bottom  of sprite = end of display

                    ; Clip Sprite X Axis to the Display Size
                    ; d0 = X Position
                    ; d2 = width of sprite (words)
                    ; d1 = start raster of sprite display - Y co-ord
                    ; d3 = last raster of sprite display  - Y + height
                    ; a0 = start address offset of gfx mask data
sprite_x_clipping
                    MOVE.L  #$ffffffff,D7                   ; d7 = first word mask & last word mask (no mask)
                    move.w  d2,d5

                    moveq   #$07,d6                         ; d6 = bit shift (src gfx)
                    and.w   d0,d6                           ; d6 = shift value. d6 = bit shift (src gfx)
                    bne.b   calc_shifts_and_masks           ; L00005794 ; shift is > 0

                    ; 
                    ; shift value = 0 (on a byte boundary)
                    asr.w   #$03,d0                         ; divide x by 8 to get byte offset
                    bpl.b   clip_right_display              ; L00005784
                    ; byte offset is -ve
clip_left_display
                    neg.w   d0
                    sub.w   d0,d5                           ; subtract width from sprite
                    bls.w   exit_draw_sprite                ; sprite is off the left hand side of thhe screen
                    ; clip sprite left ptr
                    adda.w  d0,a0                           ; a0 = start of gfx mask data
                    adda.w  d0,a0                           ; a0 = start of gfx mask data
                    moveq   #$00,d0
                    ; byte offset is +ve
clip_right_display
                    moveq   #$14,d4                         ; d4 = #$14 (20 decimal #of words screen width?)
                    sub.w   d0,d4                           ; 
                    ble.w   exit_draw_sprite                ; sprite is off screen right hand side
                    cmp.w   d4,d5
                    bls.b   calc_bltsize_and_modulos        ; L000057ce
                    move.w  d4,d5                           ; trim sprite width (clip right)
                    bra.b   calc_bltsize_and_modulos        ; L000057ce

                    ; shift value is > 0
                    ; d0 = X Position
                    ; d2 = width of sprite (words)
                    ; d1 = start raster of sprite display - Y co-ord
                    ; d3 = last raster of sprite display  - Y + height
                    ; d5 = copy of sprite width (words)
                    ; a0 = start address offset of gfx mask data
calc_shifts_and_masks
                    clr.w   d7                              ; d7 = first word mask & last word mask
                    addq.w  #$01,d5                         ; add 1 to copy of width (words) - shifted bob needs area to shift into
                    asr.w   #$03,d0                         ; divide x by 8 - d0 - X word offset
                    bpl.b   x_co_ord_positive               ; L000057b8
                    ; x co-ord is -ve (off screen left)
x_co_ord_negative
                    neg.w   d0
                    subq.w  #$01,d0                         ; make x offset +ve
                    sub.w   d0,d5                           ; subtract from the sprite width
                    bls.w   exit_draw_sprite                ; sprite is off the screen (left hand side) - L00005852
                    ; sprite is on screen
                    adda.w  d0,a0                           ; a0 = start of gfx mask data
                    adda.w  d0,a0                           ; a0 = start of gfx mask data
                    move.l  #$ffffffff,D0                   ; first word & last word mask
                    moveq   #$08,d4
                    sub.w   d6,d4                           ; d4 = shift value - d6 = scroll value bit shift (src gfx)
                    add.w   d4,d4                           ; multiply shift by 2 (co-ords stored halved in a byte)
                    lsr.w   d4,d0                           ; shift mask by sprite shift value
                    swap.w  d0                              ; swap to high word (first word mask)
                    and.l   d0,d7                           ; d7 = first word mask, last word mask = #$ffff
                    ; x co-ord is +ve (on screen)
x_co_ord_positive
                    moveq   #$14,d4                         ; d4 = #$14 (20 decimal, width of display in words)
                    sub.w   d0,d4
                    ble.w   exit_draw_sprite                ; sprite is off screen (right hand side)
                    ; is sprite fully on screen (x axis) 
                    cmp.w   d4,d5
                    bls.b   calc_bltsize_and_modulos        ; L000057ce                       ; sprite is all on screen
                    ; clip sprite right hand side
                    move.w  d4,d5                           ; update sprite width
                    move.l  #$ffffffff,D4                   ; firat word & last word mask
                    lsl.w   d6,d4                           ; d6 = bit shift (src gfx)
                    lsl.w   d6,d4                           ; d6 = bit shift (src gfx)
                    move.w  d4,d7                           ; set last word mask - d7 = first word mask & last word mask


                    ; plot sprite positions
                    ; d0 = X Position
                    ; d2 = width of sprite (bytes)
                    ; d1 = start raster of sprite display - Y co-ord
                    ; d3 = last raster of sprite display  - Y + height
                    ; a0 = start address offset of gfx mask data
                    ; d6 = shift value / 2
                    ; d5 = sprite width (clipped)
                    ; d7 = Firstword & Lastword mask
calc_bltsize_and_modulos                            ; original address L000057ce
                    asl.w   #$06,d3                 ; shift sprite height << 6 (blitsize)
                    add.w   d5,d3                   ; d3 = bltsize - add blit with to bltsize
                    sub.w   d5,d2                   ; d2 = subtract blit width from sprite width
                    add.w   d2,d2                   ; d2 = source sprite modulo
                    moveq   #$15,d4                 ; screen buffer width (21 words)
                    sub.w   d5,d4                   ; subtract blit width (words)
                    add.w   d4,d4                   ; d4 = screen width modulo (words * 2)

                    ; d3 = blit size
                    ; d2 = source modulo
                    ; d4 = destination modulo
                    ; d0 = x word offset
                    ; d1 = y line offset
                    ; Calc destination Ptr
calc_dest_ptr                                               ; original address L000057dc
                    movea.l playfield_buffer_2,a2           ; L000036f6,a2
                    add.w   d0,d0                           ; d0 = d2 * 2 (x byte value)
                    adda.w  d0,a2
                    mulu.w  #$002a,d1                       ; d2 = d2 * 42 (y value)
                    adda.l  d1,a2                           ; a2 = destination address for blit.
calc_bltcons_shifts
                    ext.l   d6                              ; d6 = shift value - sign extend to long
                    ror.l   #$03,d6                         ; d6 = bit shift value (move shift value to top 3 bits of long word)
                    move.l  d6,d0                           ; copy d6 -> d0
                    swap.w  d0                              ; swap high/low words
                    or.l    d0,d6                           ; copy shift bits to top 3 bits of low word - bits 15-12 src b shift

                    ; d2 = source data modulo
                    ; d4 = dest data modulo
                    ; d6 = bltcon0 & bltcon1 (shift A & B) (top 3 bits of high word and low word)
                    ; d7 = first word mask & last word mask
                    ; a0 = gfx data ptr (starts with mask data)
                    ; a1 = offset to gfx data (size of mask data)
blit_sprite                                                 ; original address
                    movea.l #$00dff000,a5
                    or.l    #$0fca0000,d6                   ; D6 = BLTCON0 & BLTCON1 - apply minterms and chanel enable to shift bits
                                                            ;; No src A shift, use all DMA channels, Logic = $ca (cookie cutter)
                                                            ; use ABCD, D=AB+/AC
                                                            ; A = Mask
                                                            ; B = Source GFX
                                                            ; C = Dest GFX
                                                            ; D = Combined SRC & Dest
.initial_blit_wait                                                   
                    btst.b  #$0006,$00dff002                ; blit wait
                    bne.b   .initial_blit_wait              ; L00005802

                    move.w  d2,BLTAMOD(a5)                  ; $0064(a5)
                    move.w  d2,BLTBMOD(a5)                  ; $0062(a5)
                    move.l  d7,BLTAFWM(a5)                  ; $0044(a5)
                    move.w  d4,BLTCMOD(a5)                  ; $0060(a5)
                    move.w  d4,BLTDMOD(a5)                  ; $0066(a5)
                    move.l  d6,BLTCON0(a5)                  ; $0040(a5) & $0042(a5)
                    lea.l   (a0),a3                         ; copy a0 -> a3, a0 & a3 = gfx mask data

                    moveq   #$03,d7                         ; d7 = 4 bitplanes
                    ; bitplane blit loop
sprite_blit_loop                                            ; original address L00005828
.blit_loop_wait                                             ; original address L00005828
                    btst.b  #$0006,$00dff002
                    bne.b   .blit_loop_wait                 ; L00005828

                    lea.l   $00(a0,a1.L),a0                 ; a0 = gfx data (increase source gfx by sprite size)
                    move.l  a3,BLTAPT(a5)                   ;  $0050(a5) - A Channel = MASK GFX                  
                    move.l  a0,BLTBPT(a5)                   ;  $004c(a5) - B Channel = SPRTIE GFX
                    move.l  a2,BLTCPT(a5)                   ;  $0048(a5) ; C Channel = Dest GFX
                    move.l  a2,BLTDPT(a5)                   ;  $0054(a5) - D Channel = Dest GFX
                    move.w  d3,BLTSIZE(a5)                  ;  $0058(a5) - Start Blit
                    lea.l   $1c8c(a2),a2                    ; Increase Dest GFX prt for next bitplane.
                    dbf.w   d7,sprite_blit_loop             ; L00005828
exit_draw_sprite                                            ; original address L00005852
                    rts



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
read_player_input                                           ; original address L00005854       
                    move.w  $00dff00c,d0                    ; JOY1DAT
                    clr.b   d2
.do_left_right      ; detect left/right
                    btst.l  #$0001,d0                       ; 1 = Right
                    beq.b   .not_joy_right                  ; L00005866
.is_joy_right
                    bset.l  #PLAYER_INPUT_RIGHT,d2           ; bit 0 = joystick right pushed
.not_joy_right      ; 5866
                    btst.l  #$0009,d0                       ; 1 = Left
                    beq.b   .not_joy_left
.is_joy_left
                    bset.l  #PLAYER_INPUT_LEFT,d2           ; bit 1 = joystick left pushed

.not_joy_left       ; 5870            
.do_up_down         ; detect up/down                        ; original address L00005870
                    move.w  d0,d1                           ; xor requied to read up/down switch status
                    lsr.w   #$01,d1                         ;   -   up = bit 9 xor bit 8
                    eor.w   d0,d1                           ;   - down = bit 1 xor bit 0 
                    ; 5876
                    btst.l  #$0000,d1                       ; 1 = down - (bit 1 xor bit 0) 
                    beq.b   .not_joy_down
.is_joy_down
                    bset.l  #PLAYER_INPUT_DOWN,d2           ; bit 2 = joystick down
.not_joy_down       ; 5880
                    btst.l  #$0008,d1                       ; 1 = up (bit 9 xor bit 8)
                    beq.b   .not_joy_up
.is_joy_up          ; 5886
                    bset.l  #PLAYER_INPUT_UP,d2             ; bit 3 = joystick up
.not_joy_up         ;588a
                    ; test fire button
.do_fire_button
                    btst.b  #$0007,$00bfe001                ; 0 = joystick button pressed
                    seq.b   d0                              ; $ff = button pressed (active low)
.check_last_state   ; 5894
                    move.b  player_button_pressed,d1        ; d1 = last button pressed value
                    bne.b   .update_button_value            ; if previously pressed then update with new value
.pulse_bit4         ; pulse bit 4 if button pressed
                    and.w   #$0010,d0                       ; mask bit 2 (button)
                    or.w    d0,d2                           ; if button not previously pressed then set bit 4
.update_button_value ; set player button flag ; 58a0
                    move.b  d0,player_button_pressed
                    move.b  d2,player_input_command 
                    rts



                    ; -------------------- inititialise offscreen buffer --------------------
                    ; Draw the initial level bacground into the off-screen back buffer
                    ; This is the initial background starting point for batman.
                    ;
initialise_offscreen_buffer                                                 ; original address L000058aa
                    ; initialise offscreen buffer ptr
                    clr.l   d0
                    move.w  scroll_window_x_coord,d0                        ; Display Window X coord
                    lsr.w   #$03,d0                                         ; Display Window X byte index
                    add.w   d0,d0                                           ; Display Window Y Word Index
                    movea.l #CODE1_CHIPMEM_BUFFER,a4                        ; Off Screen Buffer Absolute Address 
                    adda.l  d0,a4                                           ; Destination GFX Address - in offscreen buffer
                    move.l  a4,offscreen_display_buffer_ptr                 ; Initialise Off Screen Dest GFX pointer

                    ; set up draw loop
                    clr.w   offscreen_y_coord                               ; reset offscreen buffer y index
                    clr.l   d1
                    move.w  scroll_window_x_coord,d1                        ; Display Window X Coord
                    moveq   #$14,d7                                         ; (21) - GFX Tile Columns to draw (42 bytes wide offscreen buffer)
.draw_gfx_column                                                            ; original address L000058cc
                    movem.l d1/d7/a4,-(a7)
                    bsr.w   draw_background_horizontal_scroll               ; a4 = off screen buffer, d1 = word x co-ord
                    movem.l (a7)+,d1/d7/a4
                    addq.w  #$08,d1                                         ; increase X co-ord by 8 (co-ords are stored halved - really 16 pixels)
                    addq.l  #$02,a4                                         ; increase dest gfx ptr by 16 pixels
                    dbf.w   d7,.draw_gfx_column
                    rts 



                    rsreset
char884_mask        rs.b    1
char884_bpl0        rs.b    1
char884_bpl1        rs.b    1
char884_bpl2        rs.b    1
char884_bpl3        rs.b    1


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
preproc_font                                            ; original address L000058e2
                    move.w  #$013f,d7                   ; $140 (320 decimal) - total number of font raster lines
                    lea.l   large_character_gfx,a0
.loop
                    move.b  char884_bpl3(a0),d0
                    and.b   char884_bpl0(a0),d0
                    not.b   d0
                    and.b   char884_bpl1(a0),d0
                    and.b   char884_bpl3(a0),d0
                    eor.b   d0,char884_bpl0(a0)
                    addq.w  #$05,a0                     ; 5 byte structure.
                    dbf.w   d7,.loop                    ; 


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
preproc_mapdata                                                         ; original address L00005906
                    lea.l   MAPGR_BLOCK_PARAMS,a0                       ; $8002 - physical address inside MAPGR.IFF
                    move.w  (a0)+,d5                                    ; Data Block Size
                    move.w  (a0)+,d6                                    ; Total Number of Data Blocks
                    lea.l   MAPGR_PREPROC_BLOCK_OFFSET(a0),a0           ; $807c - physical address of data block params
                    move.b  $0028(a0),d0                                ; d0 = (80a4)
                    cmp.b   #$17,d0                                     ; test byte value (in data block)
                    bcc.b   preproc_display_object_data                 ; Has data already been swapped? - skip swap if d0 > #$17 (23)

                    move.w  d6,d0                                       ; d0 = Total Number of Level Data Blocks
                    subq.w  #$01,d0
                    mulu.w  d5,d0                                       ; Offset to last Data Block in file
                    lea.l   $00(a0,d0.L),a1                             ; a1 = $9e7c
                    lsr.w   #$01,d6                                     ; d6 = Number of Data Blocks / 2
                    subq.w  #$01,d6                                     ; d6 = loop counter (20)
.swap_data_block
                        move.w  d5,d4                                   ; d4 = Data Block Size
                        subq.w  #$01,d4                                 ; d4 = loop counter (192)
.swap_data_loop 
                            move.b  (a0),d0                             ; 
                            move.b  (a1),(a0)+                          ; Swap Bytes between Low Block & High Block
                            move.b  d0,(a1)+                            ; 
                        dbf.w   d4,.swap_data_loop 

                        suba.w  d5,a1                                   ; next block ptr
                        suba.w  d5,a1
                    dbf.w   d6,.swap_data_block                         ; swap next data block


                    ; Initialise list of 305 display objects
                    ; Create list at $10000 in physical memory
preproc_display_object_data                                             ; original address L00005942
                    movea.l sprite_array_ptr,a1                         ; a1 = $10000
                    movea.l #BATSPR1_BASE,a0                            ; a0 = $11002 - physical address in BATSPR1.IFF 
                    lea.l   display_object_coords,a2                    ; a2 = L0000607c

                    move.w  (a0)+,d7                                    ; d7 = $0131 (305), a0 = $11004
                    clr.l   d0
                    move.w  d7,d0                                       ; d0 = $0131 (305)
                    subq.w  #$01,d7                                     ; adjust loop counter ($130)
                    move.w  d7,d6                                       ; store loop counter for 2nd preprocess below ($130)

                    ; calc start of sprite gfx
                    asl.w   #$03,d0                                     ; d0 = $0131 * 8 = $988 (2440)
                    add.l   a0,d0                                       ; d0 = $11004 + $988 = $1198C
                    movea.l d0,a5                                       ; A5 = $1198C - start of gfx offset

                    ; loop through 10 byte struct
                    ; first 2 bytes ignored ($800f)
                    ; next 2 bytes X & Y co-ords
                    ; next 2 bytes width (words) & height (lines)
                    ; next 4 bytes gfx start offset from $1198c ($98c in file)
                    ;
.sprite_list_loop                                               ; original address $00005962
                    ; skip first 2 bytes ($800f)
                        lea.l   $0002(a0),a0                                ; skip first 2 bytes (#$800f) A0 = $11004 + $2 = $11006
                        ; store inital X 7 Y co-ords
                        move.w  (a2)+,(a1)+                                 ; store X & Y co-ords - copy words from $607c -> $10000 (byte 0-1) 
                        ; calc sprite width
                        move.b  (a0)+,d0                                    ; ($11006)+   d0 = $09
                        lsr.b   #$04,d0                                     ; d0 = d0 / 16
                        addq.w  #$01,d0                                     ; d0 = d0 + 1
                        move.b  d0,(a1)+                                    ; sprite width - store d0.b -> $10000 (byte 2)
                        ; calc sprite height
                        move.b  (a0)+,d0                                    ; ($11007)+  d0 = $09
                        addq.w  #$01,d0                                     ; d0 = d0 + 1
                        move.b  d0,(a1)+                                    ; sprite height - store d0.b -> $10000 (byte 3)
                        ; calc sprite gfx ptr
                        move.l  (a0)+,d0                                    ; ($11008)+  d0 = $00000000
                        add.l   a5,d0                                       ; $0001198c + $00000000
                        move.l  d0,(a1)+
                        ; do next display object
                    dbf.w   d7,.sprite_list_loop 


                    ; ------- another display object preprocessor loop --------
                    ; 1) calculate the size of the sprite gfx data.
                    ; 2) calculate the offset to sprite sheet for left facing sprites (mirror image)
                    ; 3) make the mirror image sprite sheet?
                    ;
preproc_display_object_data_2                           ; original address L00005980
                    move.w  d6,d7                       ; loop counter
                    movea.l sprite_array_ptr,a2         ; a2 = display object array list
                    clr.l   d2
                    addq.w  #$02,a2                     ; skip X & Y co-ords
.calc_size_loop     ; accumulate the size of all display objects/sprites
                        clr.w   d0
                        move.b  (a2)+,d0                    ; d0 = object width
                        clr.w   d1
                        move.b  (a2)+,d1                    ; d1 = object height
                        mulu.w  d1,d0                       ; d0 = number of words for bitplane?
                        add.w   d0,d2                       ; d2 = accumulator of bitplane size?
                        addq.w  #$06,a2                     ; next display object               
                    dbf.w   d7,.calc_size_loop

                    ; calc start offset for left facing sprite sheet
.calc_left_offset                                       ; original address L0000599c
                    mulu.w  #$000a,d2                   ; d2 = size of display object gfx - Multiply by 10 (5 bitplanes, 2 bytes per word)
                    move.l  d2,sprite_gfx_left_offset        ; byte offset to be added to base sprite gfx ptr (for right facing sprites?)

                    ; prepare mirror image of sprites (left facing)
.prep_mirror_image                                      ; original address L000059a4
                    movea.l sprite_array_ptr,a1         ; a1 = display object array list
                    movea.l $0004(a1),a1                ; get sprite gfx ptr of first display object.
                    addq.w  #$01,a1     
                    btst.b  #$0000,(a1)                 ; test lsb of mask 1st word.
                    bne.w   preprocess_sprite_gfx       ; create left facing sprite sheet?

                    ;JSR     _DEBUG_COLOURS

                    rts




                    ; ---------------- pre-process sprite gfx ----------------
                    ; IN:-
                    ;   d6.w = number of display objects (305)
                    ;   a0.l = start of sprite gfx
                    ;
                    ; 1) inverts the sprites (upside down?)
                    ; 2) create mirror image of sprites
                    ;
preprocess_sprite_gfx                               ; original address L000059b8
                    ;JSR     _DEBUG_COLOURS
invert_sprites                                      ; original address L000059b8
                    move.w  d6,d7
                    movea.l sprite_array_ptr,a1     ; L000062fe,a1
                    addq.w  #$02,a1                 ; a1 = sprite 'width' ptr
                    movea.l a0,a5                   ; a5 = start of sprite gfx ptr
                    movea.l a0,a3                   ; a3 = start of sprite gfx ptr

.invert_next_sprite                                 ; original address L000059c4
                    clr.l   d5
                    clr.l   d0
                    move.b  (a1)+,d0                ; d0 = sprite width
                    move.b  (a1),d5                 ; d5 = sprite height
                    mulu.w  d0,d5                   ; d5 = sprite size in words (one bitplane)
                    move.l  d5,d4                   ; d4 = sprite size in words (one bitplane)
                    add.w   d4,d4                   ; d4 = sprite offset to bpl1
                    move.l  d4,d3                   ; 
                    add.w   d4,d3                   ; d3 = sprite offset to bpl2
                    move.l  d3,d2
                    add.w   d4,d2                   ; d2 = sprite offset to bpl3
                    move.l  d2,d1
                    add.w   d4,d1                   ; d1 = sprite offset to bpl4
                    subq.w  #$01,d5
                    movea.l #CODE1_DOUBLE_BUFFER_ADDRESS,a2 ; $61b9c
.copy_sprite_loop                                   ; original address L000059e6
                    move.w  (a0)+,(a2)              ; copy sprite mask
                    not.w   (a2)                    ; invert the mask bits
                    move.w  (a0)+,$00(a2,d4.W)      ; copy bpl1
                    move.w  (a0)+,$00(a2,d3.W)      ; copy bpl2
                    move.w  (a0)+,$00(a2,d2.W)      ; copy bpl3
                    move.w  (a0)+,$00(a2,d1.W)      ; copy bpl4
                    addq.w  #$02,a2                 ; increment dest address
                    dbf.w   d5,.copy_sprite_loop

                    move.w  #$0004,d4
.invert_sprite_bitplane                             ; original address L00005a04
                    clr.w   d5
                    move.b  (a1),d5                 ; d5 = sprite height
                    subq.w  #$01,d5                 ; d5 = loop counter
.invert_sprite_loop                                 ; original address L00005a0a
                    move.w  d0,d2                   ; d0,d2 = sprite width
                    subq.w  #$01,d2                 ; d2 = loop counter
                    suba.l  d0,a2
                    suba.l  d0,a2                   ; source ptr to start of line gfx
.invert_sprite_inner_loop                           ; copy sprites back to src gfx upside down (inverted)
                    move.w  (a2)+,(a3)+             ; copy sprite data from $61b9c to source gfx
                    dbf.w   d2,.invert_sprite_inner_loop  ; L00005a12
                    ; do for sprite height
                    suba.l  d0,a2
                    suba.l  d0,a2
                    dbf.w   d5,.invert_sprite_loop ;L00005a0a
                    ; do next bitplane
                    adda.l d3,a2                    ; do next bitplane
                    dbf.w   d4,.invert_sprite_bitplane ; L00005a04
                    ; do next sprite
                    lea.l   $0007(a1),a1
                    dbf.w   d7,.invert_next_sprite   ; L000059c4


                    ; mirror sprites - left facing sprite sheet
mirror_sprites
                    movea.l a3,a4                   ; sprite dest gfx ptr
                    movea.l sprite_array_ptr,a1     
                    move.w  d6,d7                   ; number of sprites
.mirror_next_sprite
                    moveq   #$04,d6                 ; d6 = number of bitplanes + mask
                    movea.l $0004(a1),a0            ; a0 = sprite gfx ptr
.mirror_sprite
                    clr.l   d5
                    clr.l   d4
                    move.b  $0002(a1),d4            ; d4 = width
                    move.b  $0003(a1),d5            ; d5 = height
                    subq.w  #$01,d5                 ; d5 = loop counter
.mirror_bitplane
                    move.w  d4,d3
                    add.w   d3,d3                   ; d3 = width in bytes
                    subq.w  #$01,d3                 ; d3 = loop counter
.mirror_line
                    move.b  $00(a0,d3.W),d0         ; get gfx byte
                    moveq   #$07,d2
.mirror_byte        ; mirror sprite byte
                    roxr.b  #$01,d0                 ; rotate bit LSB -> into Extend bit
                    roxl.b  #$01,d1                 ; rotate extennd bit <- into LSB
                    dbf.w   d2,.mirror_byte         ; L00005a56
                    ; mirror sprite line
                    move.b  d1,(a3)+
                    dbf.w   d3,.mirror_line         ; L00005a50
                    ; mirror bitplane
                    adda.l  d4,a0
                    adda.l  d4,a0
                    dbf.w   d5,.mirror_bitplane     ;L00005a4a
                    ; mirror sprite
                    dbf.w   d6,.mirror_sprite       ; L00005a3c
                    ; mirror all sprites
                    lea.l   $0008(a1),a1
                    dbf.w   d7,.mirror_next_sprite  ;L00005a36
                    rts


actor_init_data     ; original address L00005a7a
L00005a7a           dc.w    $0004,$006b
L00005a7e           dc.w    $0012,$0046
L00005a82           dc.w    $0015,$0097
L00005a86           dc.w    $0017,$0064
L00005a8a           dc.w    $0018,$0085
L00005a8e           dc.w    $001b,$00bc
L00005a92           dc.w    $001f,$00c1
L00005a96           dc.w    $00ff,$0000


                    ; ------- jmp table -----
                    ; converted from word to long addresses
                    ; when called the routines have the following
                    ; IN:-
                    ;   a6 = L000039c8  - 
actor_handler_table                                         ; original address L00005a9a
                                                            ; index | offset    | Description
L00005a9a           dc.l    actor_cmd_nop                   ;   0   |    0      |                        original 16 bit value $5290
                    dc.l    actor_cmd_falling               ;   1   |    4      |                        original 16 bit value $45ce
                    dc.l    actor_cmd_02                    ;   2   |    8      |                        original 16 bit value $410a
                    dc.l    actor_cmd_03                    ;   3   |    12     |                        original 16 bit value $405e
                    dc.l    actor_cmd_04                    ;   4   |    16     |                        original 16 bit value $40b8
                    dc.l    actor_cmd_05                    ;   5   |    20     |                        original 16 bit value $400c
                    dc.l    actor_cmd_06                    ;   6   |    24     |                        original 16 bit value $40f0
                    dc.l    actor_cmd_07                    ;   7   |    28     |                        original 16 bit value $4044
                    dc.l    actor_cmd_nop                   ;   8   |    32     |                        original 16 bit value $5290
                    dc.l    actor_cmd_nop                   ;   9   |    36     |                        original 16 bit value $5290
                    dc.l    actor_cmd_nop                   ;   10  |    40     |                        original 16 bit value $5290
                    dc.l    actor_cmd_nop                   ;   11  |    44     |                        original 16 bit value $5290
                    dc.l    actor_cmd_12                    ;   12  |    48     |                        original 16 bit value $43a0
                    dc.l    actor_cmd_13                    ;   13  |    52     |                        original 16 bit value $4380
                    dc.l    actor_cmd_14                    ;   14  |    56     |                        original 16 bit value $41a2
                    dc.l    actor_cmd_15_23                 ;   15  |    60     |                        original 16 bit value $426c
                    dc.l    actor_cmd_16                    ;   16  |    64     |                        original 16 bit value $4430
                    dc.l    actor_cmd_17                    ;   17  |    68     |                        original 16 bit value $4444
                    dc.l    actor_cmd_18                    ;   18  |    72     |                        original 16 bit value $447e
                    dc.l    $00000000                       ;   19  |    76     |                        original 16 bit value $0000
                    dc.l    actor_cmd_20                    ;   20  |    80     |                        original 16 bit value $5c6e
                    dc.l    actor_cmd_21                    ;   21  |    84     |                        original 16 bit value $5bea
                    dc.l    actor_cmd_22                    ;   22  |    88     |                        original 16 bit value $5c02
                    dc.l    actor_cmd_15_23                 ;   23  |    92     |                        original 16 bit value $426c
                    dc.l    actor_cmd_24                    ;   24  |    96     |                        original 16 bit value $5b5c
                    dc.l    actor_cmd_25                    ;   25  |    100    |                        original 16 bit value $5b06
                    dc.l    actor_cmd_26                    ;   26  |    104    |                        original 16 bit value $5eb8
                    dc.l    actor_cmd_27                    ;   27  |    108    |                        original 16 bit value $5ecc
                    dc.l    actor_cmd_28                    ;   28  |    112    |                        original 16 bit value $5f42
                    dc.l    actor_cmd_29                    ;   29  |    116    |                        original 16 bit value $5fcc
                    dc.l    actor_cmd_30                    ;   30  |    120    |                        original 16 bit value $6020
                    dc.l    actor_cmd_31                    ;   31  |    124    |                        original 16 bit value $5d04
                    dc.l    actor_cmd_32_jackvat            ;   32  |    128    |                        original 16 bit value $5d3c
                    dc.l    actor_cmd_33_level_complete     ;   33  |    132    |                        original 16 bit value $5db0
                    dc.l    set_player_spawn_point_1        ;   34  |    136    |                        original 16 bit value $5ae4
                    dc.l    set_player_spawn_point_2        ;   35  |    140    |                        original 16 bit value $5aee
                    dc.l    set_player_spawn_point_3        ;   36  |    144    |                        original 16 bit value $5af8



                    ; --------------- actor command nop -----------------------
                    ; Actor command - no operation, does nothing.
                    ; command added as extra code because this was previously
                    ; sharing the player_input_cmd_nop code.
                    ; It just aids readability to create an actor nop verison
                    ;
actor_cmd_nop       
                    rts
                    

                    ; a6 = L000039c8 - actors_list
set_player_spawn_point_1                                                ; original address L00005ae4
                    moveq   #$01,d0
                    cmp.w   level_spawn_point_index,d0                  ; compare current spawn point with suggested.
                    bcs.b   skip_set_spawn_point                        ; further spawn point already set, so exit
                    bra.b   store_player_spawn_point                    ; L00005afe
set_player_spawn_point_2                                                ; original address L00005aee
                    moveq   #$02,d0
                    cmp.w   level_spawn_point_index,d0                  ; compare current spawn point with suggested.
                    bcs.b   skip_set_spawn_point                        ; further spawn point already set, so exit
                    bra.b   store_player_spawn_point                    ; L00005afe
set_player_spawn_point_3                                                ; original address L00005af8
                    moveq   #$03,d0
                    cmp.w   level_spawn_point_index,d0                  ; compare current spawn point with suggested.
store_player_spawn_point                                                ; original address L00005afe
                    move.w  d0,level_spawn_point_index                  ; store new spawn point index.
skip_set_spawn_point                                                    ; original address L00005b02
                    clr.w   (a6)                                        ; clear something (command complete?)
                    rts 



                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
actor_cmd_25
L00005b06           move.w  #$0590,d0
L00005b0a           sub.w   scroll_window_x_coord,d0                ; L000067bc,d0                            ; updated_batman_distance_walked
L00005b0e           addq.w  #$02,$000a(a6)
L00005b12           movea.l $0008(a6),a5
L00005b16           move.w  (a5),d2
L00005b18           bpl.w   draw_next_sprite                        ; L000045bc
L00005b1c           bsr.w   double_buffer_playfield                 ; L000036fa
L00005b20           moveq   #$32,d0
L00005b22           bsr.w   wait_for_frame_count                    ; L00005e8c
L00005b26           bra.w   Load_level_2                            ; L00005e3a


L00005b2a           dc.w    $0001, $0001                            ; or.b #$01,d1
L00005b2e           dc.w    $0001, $0001                            ; or.b #$01,d1
L00005b32           dc.w    $0002, $0002                            ; or.b #$02,d2
L00005b36           dc.w    $0002, $0002                            ; or.b #$02,d2
L00005b3a           dc.w    $0003, $0003                            ; or.b #$03,d3
L00005b3e           dc.w    $0003, $0003                            ; or.b #$03,d3
L00005b42           dc.w    $0004, $0004                            ; or.b #$04,d4
L00005b46           dc.w    $0004, $0004                            ; or.b #$04,d4
L00005b4a           dc.w    $0002, $0002                            ; or.b #$02,d2
L00005b4e           dc.w    $0002, $0002                            ; or.b #$02,d2
L00005b52           dc.w    $0001, $0001                            ; or.b #$01,d1
L00005b56           dc.w    $0001, $0001                            ; or.b #$01,d1
L00005b5a           dc.w    $ffff                                   ; illegal



                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
actor_cmd_24
L00005b5c           move.w  #$0098,$0004(a6)                        ; $00dff004
L00005b62           lea.l   actors_list,a5                          ; L000039c8,a5
L00005b66           move.w  #$0085,d2
L00005b6a           moveq   #$09,d7
L00005b6c           cmp.w   $0006(a5),d2                            ; $00bfd106,d2
L00005b70           beq.b   L00005b7c
L00005b72           lea.l   ACTORLIST_STRUCT_SIZE(a5),a5
L00005b76           dbf.w   d7,L00005b6c
L00005b7a           bra.b   L00005b80
L00005b7c           move.w  (a5),d2
L00005b7e           bne.b   L00005b8c
L00005b80           bclr.b  #$0007,L0000670a
L00005b88           clr.w   (a6)
L00005b8a           rts


                    ; jack falls & hits the vat?
L00005b8c           subq.w  #$01,d2
L00005b8e           bne.b   L00005b8a                               ; jmp to rts above
L00005b90           jsr     AUDIO_PLAYER_INIT_SFX_1
L00005b96           bset.b  #PANEL_ST1_TIMER_EXPIRED,PANEL_STATUS_1 
L00005b9e           move.l  #player_input_cmd_nop,gl_jsr_address    ; Set game_loop Self Modifying Code JSR 
L00005ba4           clr.w   L000062fa
L00005ba8           clr.w   grappling_hook_height                   ; L00006318
L00005bac           move.w  $0004(a5),d0                            ; $00bfd104,d0
L00005bb0           cmp.w   #$00d4,d0
L00005bb4           bcs.b   L00005bd2
L00005bb6           move.w  #$0081,$0006(a5)                        ; $00bfd106
L00005bbc           move.l  #$00005b28,$0008(a5)                    ; $00bfd108
L00005bc4           move.w  #$0019,(a5)
L00005bc8           clr.w   (a6)
L00005bca           moveq   #SFX_SPLASH,d0
L00005bcc           jmp     AUDIO_PLAYER_INIT_SFX
                    ; uses rts in audio player


L00005bd2           subq.w  #$01,target_window_x_offset             ; L000067c8
L00005bd6           sub.w   #$0018,d0
L00005bda           sub.w   scroll_window_y_coord,d0                ; L000067be,d0
L00005bde           neg.w   d0
L00005be0           add.w   batman_y_offset,d0
L00005be4           move.w  d0,target_window_y_offset               ; L000067c6
L00005be8           rts


                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
actor_cmd_21
L00005bea           bsr.b   L00005c20
L00005bec           cmp.w   #$0008,d2
L00005bf0           bcc.b   L00005be8
L00005bf2           cmp.w   #$0004,d2
L00005bf6           bne.w   draw_next_sprite                    ; L000045bc
L00005bfa           bsr.b   L00005c4e
L00005bfc           moveq   #$04,d2
L00005bfe           bra.w   draw_next_sprite                    ; L000045bc


                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
actor_cmd_22
L00005c02           bsr.b   L00005c20
L00005c04           or.w    #$e000,d2
L00005c08           cmp.w   #$e008,d2
L00005c0c           bcc.b   L00005be8
L00005c0e           cmp.w   #$e004,d2
L00005c12           bne.w   draw_next_sprite                        ; L000045bc
L00005c16           bsr.b   L00005c42
L00005c18           move.w  #$e004,d2
L00005c1c           bra.w   draw_next_sprite                        ; L000045bc

L00005c20           clr.w   d2
L00005c22           move.w  $0008(a6),d2
L00005c26           addq.b  #$04,d2
L00005c28           bcc.b   L00005c32
L00005c2a           moveq   #SFX_GASLEAK,d2
L00005c2c           bsr.w   play_proximity_sfx                      ; play sfx if d0 < 160 & d1 < 89
L00005c30           clr.w   d2
L00005c32           move.w  d2,$0008(a6)
L00005c36           cmp.w   #$0037,d2
L00005c3a           bcc.b   L00005c40
L00005c3c           lsr.w   #$03,d2
L00005c3e           addq.w  #$01,d2
L00005c40           rts 


L00005c42           movem.w batman_xy_offset,d3-d4
L00005c48           add.w   #$0010,d3
L00005c4c           bra.b   L00005c56
L00005c4e           movem.w batman_xy_offset,d3-d4
L00005c54           addq.w  #$04,d3
L00005c56           sub.w   d0,d3
L00005c58           cmp.w   #$0016,d3
L00005c5c           bcc.b   L00005c40
L00005c5e           cmp.w   d1,d4
L00005c60           bmi.b   L00005c40
L00005c62           cmp.w   batman_y_bottom,d1              ; L000062f0,d1
L00005c66           bmi.b   L00005c40
L00005c68           moveq   #$03,d6                         ; Value of Energy to Lose (3 of 48)
L00005c6a           bra.w   batman_lose_energy              ; L00004ccc


                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
actor_cmd_20
L00005c6e           move.w  $000c(a6),d3            ; $00dff00c,d3
L00005c72           addq.b  #$06,d3
L00005c74           move.w  d3,$000c(a6)            ; $00dff00c
L00005c78           cmp.b   #$20,d3
L00005c7c           bcs.b   L00005c40
L00005c7e           moveq   #$01,d2
L00005c80           cmp.b   #$40,d3
L00005c84           bcs.w   draw_next_sprite        ; L000045bc
L00005c88           move.w  $000a(a6),d5
L00005c8c           cmp.w   #$0010,d5
L00005c90           bcc.w   L00005c96
L00005c94           addq.w  #$01,d5
L00005c96           move.w  d5,$000a(a6)
L00005c9a           lsr.w   #$01,d5
L00005c9c           add.w   $0008(a6),d5
L00005ca0           move.w  d5,$0008(a6)
L00005ca4           add.w   d5,d1
L00005ca6           bsr.w   get_map_tile_at_display_offset_d0_d1            ; out: d2 = tile value 
L00005caa           cmp.b   #$79,d2
L00005cae           bcs.b   L00005cd8
L00005cb0           move.w  scroll_window_y_coord,d3                         ; L000067be,d3
L00005cb4           add.w   d1,d3
L00005cb6           and.w   #$0007,d3
L00005cba           not.w   d3
L00005cbc           add.w   d3,d1
L00005cbe           moveq   #$04,d2
L00005cc0           eor.w   d2,$0002(a6)
L00005cc4           clr.l   $0008(a6)
L00005cc8           clr.w   $000c(a6)
L00005ccc           moveq   #SFX_DRIP,d2
L00005cce           bsr.w   play_proximity_sfx                      ; play sfx if d0 < 160 & d1 < 89
L00005cd2           moveq   #$02,d2
L00005cd4           bra.w   draw_next_sprite                        ; L000045bc
L00005cd8           moveq   #$01,d2
L00005cda           move.w  batman_x_offset,d3
L00005cde           sub.w   d0,d3
L00005ce0           addq.w  #$03,d3
L00005ce2           cmp.w   #$0007,d3
L00005ce6           bcc.w   draw_next_sprite                        ; L000045bc
L00005cea           cmp.w   batman_y_bottom,d1                      ; L000062f0,d1
L00005cee           bmi.w   draw_next_sprite                        ; L000045bc
L00005cf2           cmp.w   batman_y_offset,d1
L00005cf6           bpl.w   draw_next_sprite                        ; 
L00005cfa           moveq   #$02,d6                                 ; Value of Energy to Lose (2 of 48)
L00005cfc           bsr.w   batman_lose_energy
L00005d00           bra.b   L00005cbe
L00005d02           rts 



                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
actor_cmd_31
L00005d04           move.w  $0004(a6),d2
L00005d08           not.w   d2
L00005d0a           and.w   #$0007,d2
L00005d0e           bclr.l  #$0002,d2
L00005d12           bne.b   L00005d18
L00005d14           add.w   #$e000,d2
L00005d18           move.w  d2,-(a7)
L00005d1a           addq.w  #$02,d2
L00005d1c           bsr.w   draw_next_sprite                        ; L000045bc
L00005d20           move.w  (a7)+,d2
L00005d22           and.w   #$e000,d2
L00005d26           addq.w  #$01,d2
L00005d28           bsr.w   actor_collision_and_sprite1             ; L0000458a
L00005d2c           btst.b  #$0000,playfield_swap_count+1           ; test even/odd playfield buffer swap value
L00005d32           beq.b   L00005d02                               ; exit rts
L00005d34           subq.w  #$01,$0004(a6)
L00005d38           bmi.b   L00005d82
L00005d3a           rts 



                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX

                    ; jack falls hits the vat?
actor_cmd_32_jackvat
L00005d3c           btst.b  #$0000,playfield_swap_count+1           ; test even/odd playfield buffer swap value
L00005d42           beq.b   L00005d54
L00005d44           movem.l d0-d1/a6,-(a7)
L00005d48           moveq   #SFX_SPLASH,d0
L00005d4a           jsr     AUDIO_PLAYER_INIT_SFX
L00005d50           movem.l (a7)+,d0-d1/a6
L00005d54           move.w  playfield_swap_count,d2
L00005d58           lsr.w   #$02,d2
L00005d5a           and.w   #$0003,d2
L00005d5e           addq.w  #$01,d2
L00005d60           bsr.w   draw_next_sprite                        ; L000045bc
L00005d64           sub.w   #$0010,d1
L00005d68           bpl.b   L00005d54
L00005d6a           lea.l   actors_list,a5                          ; L000039c8,a5
L00005d6e           move.w  #$0103,d2
L00005d72           moveq   #$09,d7
L00005d74           cmp.w   $0006(a5),d2
L00005d78           beq.b   L00005d88
L00005d7a           lea.l   ACTORLIST_STRUCT_SIZE(a5),a5            ; #$0016(a5)
L00005d7e           dbf.w   d7,L00005d74
L00005d82           moveq   #$5a,d6                                 ; Value of Energy to Lose (90 of 48) - DEAD!
L00005d84           bra.w   batman_lose_energy


L00005d88           move.w  (a5),d2
L00005d8a           beq.b   L00005d82
L00005d8c           subq.w  #$01,d2
L00005d8e           bne.w   L00005d02                               ; exit rts
L00005d92           move.l  #player_input_cmd_nop,gl_jsr_address    ; L00003c90 ; Set Self Modifying Code JSR in game_loop
L00005d98           move.w  #$0021,(a5)
L00005d9c           clr.w   grappling_hook_height                   ; L00006318
L00005da0           move.w  #$ffff,L000062fa
L00005da6           move.b  #PANEL_ST1_VAL_TIMER_EXPIRED,PANEL_STATUS_1    ; Set TIMER EXPIRED 
L00005dae           rts



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
actor_cmd_33_level_complete
L00005db0           move.w  scroll_window_x_coord,d2
L00005db4           cmp.w   #$0540,d2                               ; 1344 (max X)
L00005db8           beq.b   L00005dce
L00005dba               addq.w  #$02,$0002(a6)
L00005dbe               moveq   #$70,d2
L00005dc0               sub.w   d0,d2
L00005dc2               cmp.w   #$fffd,d2
L00005dc6               bcc.b   L00005dca
L00005dc8                   move.l  #$fffffffe,D2
L00005dca               add.w   d2,target_window_x_offset           ; L000067c8

                    ; check level complete
L00005dce           cmp.w   #$0048,d1                       ; d1.w - maybe sprite Y co-ord  
L00005dd2           bcc.b   level_completed                 ; d0.w = Sprite X, a6.l = object/sprite struct?    ; d1 <= #$48 (72 dec) then Level Is Completed - L00005e26 

L00005dd4           move.w  $000a(a6),d3
L00005dd8           cmp.w   #$000e,d3
L00005ddc           bpl.b   L00005de4
L00005dde           addq.w  #$01,d3
L00005de0           move.w  d3,$000a(a6)
L00005de4           asr.w   #$01,d3
L00005de6           add.w   d3,$0004(a6)
L00005dea           moveq   #$18,d2
L00005dec           sub.w   d1,d2
L00005dee           add.w   d2,target_window_y_offset       ; L000067c6
L00005df2           moveq   #$06,d2
L00005df4           cmp.w   #$0004,d3
L00005df8           bmi.b   L00005e10
L00005dfa           moveq   #$07,d2
L00005dfc           cmp.w   #$0007,d2
L00005e00           bmi.b   L00005e10
L00005e02           moveq   #$0c,d2
L00005e04           and.w   playfield_swap_count,d2
L00005e08           lsr.w   #$02,d2                     ; divide swap count by 4
L00005e0a           bne.b   L00005e0e                   ; frame swaps 4-7 - jmp $5e0e
L00005e0c           moveq   #$02,d2                     ; frame swaps 0-3 - do this
L00005e0e           addq.w  #$07,d2
L00005e10           bsr.w   draw_next_sprite            ; L000045bc
L00005e14           jsr     AUDIO_PLAYER_SILENCE              ; Chem.iff - Music/SFX player - silence all audio - $00048004 ; External Address - CHEM.IFF
L00005e1a           move.l  #$00000210,d0
L00005e20           jmp     PANEL_ADD_SCORE             ; Panel Add Player Score (D0.l BCD value to add)- $0007c82a



                    ; ------------------------ level completed ------------------------
                    ; IN:
                    ;   d0.w - Sprite X
                    ;   a6.l - address of object/sprite structure
level_completed                                                         ; Original Address L00005e26
                    moveq   #$50,d1                                     ; Sprite Y position
                    moveq   #$0b,d2                                     ; current sprite id
                    bsr.w   draw_next_sprite                            
                    bsr.w   double_buffer_playfield 
                    bset.b  #PANEL_ST2_LEVEL_COMPLETE,PANEL_STATUS_2  
                    ; fall through to 'load_level_2'


                    ; -------------------------- load level 2 ------------------------
                    ; do level completed sequence of displaying the text:
                    ;   - Jack is Dead
                    ;   - The Joker Lives
                    ; then clear the screen and load level 2
                    ;
Load_level_2        ; silence current audio                             ; original address L00005e3a
                    jsr     AUDIO_PLAYER_SILENCE
                    ; play level complete audio
                    moveq   #SFX_LEVEL_COMPLETE,d0 
                    jsr     AUDIO_PLAYER_INIT_SONG 
                    ; wait for 5 seconds (250 frames)
                    move.w  #$00fa,d0
                    bsr.b   wait_for_frame_count
                    ; wait for 2 seconds (100 frames)
                    moveq   #$64,d0
                    bsr.w   wait_for_frame_count
                    ; display 'Jack is Dead' text
                    bsr.w   clear_backbuffer_playfield  
                    lea.l   text_jack_is_dead,a0        
                    bsr.w   large_text_plotter           
                    bsr.w   screen_wipe_to_backbuffer  
                    ; wait for 2 seconds (100 frames)
                    moveq   #$64,d0
                    bsr.w   wait_for_frame_count
                    ; display 'The Joker Lives' text
                    bsr.w   clear_backbuffer_playfield  
                    lea.l   text_the_joker_lives,a0    
                    bsr.w   large_text_plotter          
                    bsr.w   screen_wipe_to_backbuffer  
                    ; wait for 2 seconds (100 frames)
                    moveq   #$64,d0
                    bsr.w   wait_for_frame_count
                    bsr.w   screen_wipe_to_black
                    ; fade bottom panel (score etc)
                    bsr.w   panel_fade_out
                    ; jump to loader, load level 2
                IFND TEST_BUILD_LEVEL
                    bra.w   LOADER_LEVEL_2
                ELSE
.dont_load_loop
                    jsr     _DEBUG_COLOURS
                    bra     .dont_load_loop
                ENDC

                    ; -------- wait for frame count ---------
wait_for_frame_count                                                    ; original address L00005e8c
                    add.w   frame_counter,d0
.wait_loop
                    cmp.w   frame_counter,d0                            ; frame counter incremented by level 3 vbl interrrupt handler
                    bpl.b   .wait_loop
                    rts 


L00005e98           movem.w batman_xy_offset,d2-d3
L00005e9e           sub.w   d1,d3
L00005ea0           cmp.w   #$0001,d3
L00005ea4           bcc.b   L00005eca
L00005ea6           sub.w   d0,d2
L00005ea8           cmp.w   #$0020,d2
L00005eac           bcc.b   L00005eca
L00005eae           move.b  batman_sprite1_id+1,d2      ; L000062ee+1,d2
L00005eb2           cmp.b   #$24,d2
L00005eb6           rts



                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
actor_cmd_26
L00005eb8           bsr.b   L00005e98
L00005eba           bcc.b   L00005eca
L00005ebc           move.w  #$0018,target_window_y_offset       ; L000067c6
L00005ec2           addq.w  #$01,(a6)
L00005ec4           move.w  #$0020,$0008(a6)
L00005eca           rts  



                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
actor_cmd_27
L00005ecc           subq.w  #$01,$0008(a6)
L00005ed0           beq.b   L00005ef8
L00005ed2           moveq   #$27,d2
L00005ed4           sub.w   $0008(a6),d2
L00005ed8           lsr.w   #$03,d2
L00005eda           move.w  d2,-(a7)
L00005edc           bsr.w   draw_next_sprite            ; L000045bc
L00005ee0           addq.w  #$08,d0
L00005ee2           move.w  (a7),d2
L00005ee4           bsr.w   draw_next_sprite            ; L000045bc
L00005ee8           addq.w  #$08,d0
L00005eea           move.w  (a7),d2
L00005eec           bsr.w   draw_next_sprite            ; L000045bc
L00005ef0           addq.w  #$08,d0
L00005ef2           move.w  (a7)+,d2
L00005ef4           bra.w   draw_next_sprite            ; L000045bc

                    ; IN:-
                    ;   a0.l = level data index?
L00005ef8           clr.w   (a6)
L00005efa           bsr.w   get_map_tile_at_display_offset_d0_d1        ; out: d2.b = tile value
L00005efe           lsl.w   #$08,d2
L00005f00           move.b  $01(a0,d3.W),d2
L00005f04           move.b  $02(a0,d3.W),d4
L00005f08           lsl.w   #$08,d4
L00005f0a           move.b  $03(a0,d3.W),d4
L00005f0e           movea.l L00005f64,a5                ; get address ptr to level block update data
L00005f12           movem.w d2-d4,-(a5)                 ; modify level data (3 words - 2nd word = index into level data)
L00005f16           move.l  a5,L00005f64                ; store updated ptr to level block update ptr
L00005f1a           move.b  #$4f,$00(a0,d3.W)           ; write data #$4f into level data blocks?
L00005f20           move.b  #$4f,$01(a0,d3.W)
L00005f26           move.b  #$4f,$02(a0,d3.W)
L00005f2c           move.b  #$4f,$03(a0,d3.W)
L00005f32           bsr.w   L00005e98
L00005f36           bcc.b   actor_cmd_28                ; L00005f42
L00005f38           move.l  #player_input_cmd_fire_down,gl_jsr_address           ; L00003c90 ; Set Self Modifying Code JSR in game_loop
L00005f3e           clr.w   grappling_hook_height       ; L00006318


                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
actor_cmd_28
L00005f42           moveq   #$05,d2
L00005f44           bsr.w   draw_next_sprite                ; L000045bc
L00005f48           moveq   #$05,d2
L00005f4a           addq.w  #$08,d0
L00005f4c           bsr.w   draw_next_sprite                ; L000045bc
L00005f50           moveq   #$05,d2
L00005f52           addq.w  #$08,d0
L00005f54           bsr.w   draw_next_sprite                ; L000045bc
L00005f58           moveq   #$05,d2
L00005f5a           addq.w  #$08,d0
L00005f5c           bsr.w   draw_next_sprite                ; L000045bc
L00005f60           bra.w   initialise_offscreen_buffer         ; draw full background screen to offscreen buffer - L000058aa


L00005f64            dc.l L00005fc4 ;$00005fc4                     ; a ptr used with map data - to location down below

L00005f68            dc.w $0000,$0000 
L00005f6c            dc.w $0000,$0000 
L00005f70            dc.w $0000,$0000 
L00005f74            dc.w $0000,$0000 
L00005f78            dc.w $0000,$0000 
L00005f7c            dc.w $0000,$0000 
L00005f80            dc.w $0000,$0000 
L00005f84            dc.w $0000,$0000 
L00005f88            dc.w $0000,$0000 
L00005f8c            dc.w $0000,$0000 
L00005f90            dc.w $0000,$0000 
L00005f94            dc.w $0000,$0000 
L00005f98            dc.w $0000,$0000 
L00005f9c            dc.w $0000,$0000 
L00005fa0            dc.w $0000,$0000 
L00005fa4            dc.w $0000,$0000 
L00005fa8            dc.w $0000,$0000 
L00005fac            dc.w $0000,$0000 
L00005fb0            dc.w $0000,$0000 
L00005fb4            dc.w $0000,$0000 
L00005fb8            dc.w $0000,$0000 
L00005fbc            dc.w $0000,$0000 
L00005fc0            dc.w $0000,$0000 

L00005fc4           dc.w $0000                          ; data location initially pointed to by ptr above L00005f64
                    dc.w $0000                          ; 3 words used by level data initialisation
L00005fc8           dc.w $0000

                    dc.w $0000



                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
actor_cmd_29
L00005fcc           cmp.w   #$00c0,d0
L00005fd0           bpl.b   L00006012
L00005fd2           and.w   #$0007,d4
L00005fd6           bne.b   L00005fe6
L00005fd8           addq.w  #$08,d0
L00005fda           bsr.w   get_map_tile_at_display_offset_d0_d1        ; out: d2.b - tile value
L00005fde           subq.w  #$08,d0
L00005fe0           cmp.b   #$79,d2
L00005fe4           bcs.b   L00006012
L00005fe6           addq.w  #$01,$0002(a6)
L00005fea           subq.w  #$01,$0008(a6)
L00005fee           bpl.b   L00006016
L00005ff0           movem.w batman_xy_offset,d2-d3
L00005ff6           sub.w   d0,d2
L00005ff8           cmp.w   #$0008,d2
L00005ffc           bcc.b   L00006016
L00005ffe           sub.w   d1,d3
L00006000           cmp.w   #$0013,d3
L00006004           bcc.b   L00006016
L00006006           move.w  #$0019,$0008(a6)
L0000600c           moveq   #$02,d6                                 ; Value of Energy to Lose (2 of 48)
L0000600e           bsr.w   batman_lose_energy                      ; L00004ccc
L00006012           move.w  #$001e,(a6)
L00006016           move.w  d4,d2
L00006018           lsr.w   #$01,d2
L0000601a           addq.w  #$01,d2
L0000601c           bra.w   draw_next_sprite                        ; L000045bc


                    ; a6 = actor list struct ptr
                    ; d0 = actorX - display
                    ; d1 = actorY - display
                    ; d2 = windowX
                    ; d3 = windowY
                    ; d4 = actor WorldX
actor_cmd_30
L00006020           cmp.w   #$ffc0,d0
L00006024           bmi.b   L0000606a
L00006026           and.w   #$0007,d4
L0000602a           bne.b   L0000603e
L0000602c           sub.w   #$0010,d0
L00006030           bsr.w   get_map_tile_at_display_offset_d0_d1        ; out: d2.b = tile value
L00006034           add.w   #$0010,d0
L00006038           cmp.b   #$79,d2
L0000603c           bcs.b   L0000606a
L0000603e           subq.w  #$01,$0002(a6)
L00006042           subq.w  #$01,$0008(a6)
L00006046           bpl.b   L0000606e
L00006048           movem.w batman_xy_offset,d2-d3
L0000604e           sub.w   d0,d2
L00006050           add.w   #$000a,d2
L00006054           bcc.b   L0000606e
L00006056           sub.w   d1,d3
L00006058           cmp.w   #$0013,d3
L0000605c           bcc.b   L0000606e
L0000605e           move.w  #$0019,$0008(a6)
L00006064           moveq   #$02,d6                             ; Value of Enegy to Lose (2 of 48)
L00006066           bsr.w   batman_lose_energy                  ; L00004ccc
L0000606a           move.w  #$001d,(a6)
L0000606e           move.w  #$e003,d2
L00006072           lsr.w   #$01,d4
L00006074           eor.w   d4,d2
L00006076           addq.w  #$01,d2
L00006078           bra.w   draw_next_sprite                    ; L000045bc

                    even



                    ; ---------------- display object co-ordinates ---------------
                    ; Start of 305 (sprite x & y positions - initialisation data)
display_object_coords                                                               ; original address L0000607c
                    dc.w $2A02,$2005,$2005,$2004,$1505,$1506,$1506,$1507
                    dc.w $1507,$1506,$1507,$1507,$2C10,$2C08,$1402,$210D
                    dc.w $2B05,$1905,$2504,$1706,$1702,$2005,$0F06,$0006
                    dc.w $2405,$1507,$1C05,$1007,$1207,$1B03,$1308,$2C07
                    dc.w $2C07,$2C07,$2C07,$2904,$1A06,$03FE,$2902,$2008
                    dc.w $1306,$2A08,$2007,$2A04,$2A02,$24FA,$1405,$2A03
                    dc.w $2A08,$0F05,$0F05,$0F05,$0F05,$2A07,$1507,$1508
                    dc.w $1507,$1508,$0200,$0201,$0202,$0000,$0100,$0100
                    dc.w $0101,$0604,$0B07,$0F07,$0C07,$0B06,$2005,$1208
                    dc.w $1200,$2903,$2206,$2205,$2204,$1506,$1507,$1508
                    dc.w $1504,$1504,$1506,$1507,$1504,$2904,$25FD,$1305
                    dc.w $2904,$2CFD,$2904,$1BFD,$2004,$1CFD,$0C07,$2805
                    dc.w $1503,$1503,$1503,$1503,$0301,$0301,$0601,$0401
                    dc.w $0400,$04FD,$04FA,$1D05,$1108,$0809,$2903,$2006
                    dc.w $2005,$2004,$1506,$1507,$1508,$1504,$1504,$1506
                    dc.w $1507,$1504,$2906,$1306,$2A07,$2904,$2EFC,$2904
                    dc.w $25FB,$0C0F,$2211,$3416,$2C16,$2009,$1208,$0B08
                    dc.w $2903,$2005,$2004,$2004,$1505,$1506,$1507,$1503
                    dc.w $1504,$1505,$1506,$1503,$2903,$25FC,$1405,$0800
                    dc.w $0303,$2904,$1BFD,$2004,$1CFD,$0C07,$2004,$1207
                    dc.w $0B07,$2904,$2006,$2005,$2004,$1506,$1507,$1508
                    dc.w $1504,$1504,$1506,$1507,$1504,$2904,$25FD,$1405
                    dc.w $2B04,$2FFD,$2904,$18FC,$2004,$1CFD,$0C07,$2806
                    dc.w $1803,$1803,$1803,$1803,$0000,$0000,$0000,$0000
                    dc.w $0000,$0908,$0908,$0908,$0808,$1D05,$1308,$0809
                    dc.w $2904,$2006,$2005,$2004,$1506,$1507,$1508,$1504
                    dc.w $1504,$1506,$1507,$1503,$2904,$25FD,$1505,$2B04
                    dc.w $2FFE,$2904,$19FD,$2202,$1EFC,$1005,$2805,$1504
                    dc.w $1504,$1504,$1504,$2906,$1503,$1503,$1503,$1503
                    dc.w $1505,$0A08,$0009,$2903,$2005,$2004,$2004,$1405
                    dc.w $1406,$1407,$1404,$1404,$1405,$1406,$1402,$2906
                    dc.w $1506,$2906,$2A07,$2903,$2EFC,$2903,$24FC,$2004
                    dc.w $2004,$2004,$2004,$2706,$1304,$1304,$1304,$1303
                    dc.w $190B,$0F09,$120D,$130D,$1309,$0B0F,$1D05,$1208
                    dc.w $0808,$2903,$2005,$2004,$2004,$1405,$1406,$1407
                    dc.w $1404,$1404,$1405,$1406,$1402,$2903,$25FD,$1306
                    dc.w $2B04,$2FFD,$2903,$18FC,$2202,$1EFC,$1005,$2805
                    dc.w $1504,$1504,$1504,$1504,$2906,$1503,$1503,$1503 
                    dc.w $1503
; End of 305 (sprite x & y positions - initialisation data)

L000062de           dc.w $0001, $0002, $0003, $0004, $0005, $0007


                    ; sprite
batman_sprite3_id                                       ; original address L000062ea
L000062ea           dc.w $0005                          ; batman sprite id 3 (0 = do not display 3) (legs)
batman_sprite2_id                                       ; original address L000062ec
L000062ec           dc.w $0002                          ; batman sprite id 2 (0 = do not display 2,3) (middle)
batman_sprite1_id                                       ; original address L000062ee
L000062ee           dc.w $0001                          ; batman sprite id 1 (0 = do not display 1,2,3) (head)

batman_y_bottom                                         ; original address L000062f0
L000062f0           dc.w $0000                          ; batman y bottom co-ord, used for bullet collision (set in draw_batman_and_rope routine)
                    

state_parameter     ; original address L000062f2
L000062f2           dc.w $0000                          ; parameter that can be used by the current batman state
                                                        ; for its own use.


batman_swing_fall_speed     ; original address L000062f4 - used when accessing both
batman_swing_speed          ; original address L000062f4
L000062f4           dc.w $0000

batman_fall_speed           ; original address L000062f6
L000062f6           dc.w $0000                          ; current fall speed of batman (max 16)


batman_fall_distance        ; original address L000062f8
L000062f8           dc.w $0000                          ; tracks distance fallen

L000062fa           dc.w $0001      

level_spawn_point_index                                 ; original address L000062fc
L000062fc           dc.w $0000                          ; used by level init to specify the default level start point parameters
                                                        ; valid values are 0 = Level Start, 1 = Halfway Spawn Point


                    ; referenced by draw_sprite
sprite_array_ptr                        ; original address L000062fe
L000062fe           dc.l BATSPR1_SPRTIE_LIST    ; $00010000      ; ptr to an array of sprite definition data structures
                                        ; structure def:
                                        ;  byte offset | description
                                        ;           0  | Y Offset
                                        ;           1  | X Offset
                                        ;           2  | Width in Words
                                        ;           3  | Height in Lines
                                        ;         4-7  | Long Pointer to GFX Data (Mask, BPL0, BPL1, BPL2, BPL3)

sprite_gfx_left_offset                  ; original address L00006302
                    dc.l $00000000      ; appears to be an address offset value added to the base sprite data for left hand facing sprites
                                        ; used in draw_sprite
L00006304           dc.w $0000
L00006306           dc.w $0000



PLAYER_INPUT_RIGHT  EQU     $0          ; player_input_command - bit 0 = Player Right Pushed 
PLAYER_INPUT_LEFT   EQU     $1          ; player_input_command - bit 1 = Player Left Pushed
PLAYER_INPUT_DOWN   EQU     $2          ; player_input_command - bit 2 = Player Down Pushed
PLAYER_INPUT_UP     EQU     $3          ; player_input_command - bit 3 = Player Up Pushed
PLAYER_INPUT_FIRE   EQU     $4          ; player_input_command - bit 4 = Player Fire Pushed (pulsed for 1 frame)

player_input_command                                ; original address L00006308
                    dc.b $00                        ; bit 0 = left
                                                    ; bit 1 = right
                                                    ; bit 2 = down
                                                    ; bit 3 = up
                                                    ; bit 4 = pulse when button pressed

player_button_pressed                               ; original address L00006309
                    dc.b $00                        ; #$00 = not pressed, #$ff = button pressed





background_gfx_base                                 ; original address L0000630a
L0000630a           dc.l MAPGR_GFX_ADDRESS          ; base level gfx ptr? $0000A07C

L0000630e           dc.w $0000


vertical_scroll_increments                          ; original address L00006310
                    dc.w $0000                      ; the number of increments +/- the window has scrolled this frame.

offscreen_y_coord                                   ; original address L00006312
                    dc.w $0000                      ; Y co-ord into offscreen buffer (circular buffer).


                    ; L00006314 - grappling hook vars
grappling_hook_params   ; address L00006314 - (hook x?, hook y?, height, width?)
L00006314           dc.w $0000                      ; grappling hook x?
L00006316           dc.w $0000                      ; grappling hook y?
grappling_hook_height                               ; original address L00006318
L00006318           dc.w $0000                      ; length/height of grappling hook rope.
L0000631a           dc.w $0000 
L0000631c           dc.w $0034

offscreen_display_buffer_ptr                                        ; original address L0000631e
                    dc.l CODE1_CHIPMEM_BUFFER                       ; ptr to offscreen display buffer - $0005A36C

L00006322           dc.l trigger_new_actors                         ; $00003DFE

batman_sprite_anim_ptr  ; ----- ptr to batman sprite animation ---  ; original address L00006326
L00006326           dc.l $00000000                                  ; modified to long ptr to 3 byte animation array (originally a word)
;L00006326           dc.w $0000                                     ; ptr to 3 byte animation array (originally a word)

L00006328           dc.w $0000
L0000632a           dc.w $0000   

playfield_swap_count                                                ; original address L0000632c
                    dc.w $0000                                      ; word value incremented when playfield buffers are swapped



L0000632e           dc.w $2221,$201F,$1E1D,$1C1B,$1A19,$1817,$1615 
L0000633C           dc.w $1413,$1211,$100F,$0E0D,$0C0B,$0A09,$0807,$0605
L0000634C           dc.w $0403,$0201

                    ; L00006350 - grappling hook x sinus?
L00006350           dc.w $0003,$0609,$0D10,$1316,$191C,$1F22                ; start = L00006390 - 64 = L00006350
L0000635C           dc.w $2529,$2C2F,$3235,$383B,$3E41,$4447,$4A4D,$5053
L0000636C           dc.w $5659,$5C5F,$6264,$676A,$6D70,$7375,$787B,$7E80
L0000637C           dc.w $8386,$888B,$8E90,$9395,$989A,$9D9F,$A2A4,$A7A9
L0000638C           dc.w $ABAE,$B0B2
                    ; L00006390 = L00006314 + $7c (grappling hook code) - is this swing data?
L00006390           dc.w $B4B7,$B9BB,$BDBF,$C1C3,$C5C7,$C9CB
L0000639C           dc.w $CDCF,$D0D2,$D4D6,$D7D9,$DBDC,$DEDF,$E1E2,$E4E5
L000063AC           dc.w $E7E8,$E9EA,$ECED,$EEEF,$F0F1,$F2F3,$F4F5,$F6F7
L000063BC           dc.w $F7F8,$F9F9,$FAFB,$FBFC,$FCFD,$FDFD,$FEFE,$FEFF    ; end = L00006390 + 60 = L000063CC
L000063CC           dc.w $FFFF,$FFFF


                    ; sprite 3 array structure
                    ; byte 0 = initial sprite id
                    ; byte 1 = second sprite offset
                    ; byte 2 = third sprite offset
batman_sprite_anim_01                                       ; sprite ids - original address L000063d0
batman_sprite_anim_fire_hook                                ; sprite ids - original address L000063d0
                     dc.b $30,$D2,$04                       ; 48, 02, 06

batman_sprite_anim_02                                       ; sprite ids - original address L000063d3
batman_sprite_anim_standing                                 ; sprite ids - original address L000063d3
                    dc.b $01,$02,$07                        ; 01, 03, 10

batman_sprite_anim_03  
batman_sprite_anim_ducking                                     ; sprite ids - original address L000063d6
                    dc.b $19,$01,$E6                        ; 25, 26, 00

batman_sprite_anim_04
batman_sprite_anim_ducked                                   ; sprite ids - original address L000063d9
                    dc.b $1E,$01,$E1                        ; 30, 31, 00

batman_sprite_anim_0a                                       ; sprite ids - original address L000063DC
batman_sprite_anim_life_lost
                    dc.b $19,$01,$E6                        ; 25, 26, 00
                    dc.b $19,$01,$E6                        ; 25, 26, 00
                    dc.b $19,$01,$E6                        ; 25, 26, 00
                    dc.b $1B,$01,$E4                        ; 27, 28, 00
                    dc.b $1B,$01,$E4                        ; 27, 28, 00 
                    dc.b $1B,$01,$E4                        ; 27, 28, 00
                    dc.b $1B,$01,$E4                        ; 27, 28, 00
                    dc.b $1B,$01,$E4                        ; 27, 28, 00
                    dc.b $1B,$01,$E4                        ; 27, 28, 00
                    dc.b $1B,$01,$E4                        ; 27, 28, 00
                    dc.b $1B,$01,$E4                        ; 27, 28, 00
                    dc.b $1D,$E3,$00                        ; 29, 00, 00 
                    dc.b $1D,$E3,$00                        ; 29, 00, 00
                    dc.b $1D,$E3,$00                        ; 29, 00, 00
                    dc.b $1D,$E3,$00                        ; 29, 00, 00
                    dc.b $1D $E3,$00                        ; 29, 00, 00
                    dc.b $1D,$E3,$00                        ; 29, 00, 00
                    dc.b $1D,$E3,$00                        ; 29, 00, 00
                    dc.b $1D,$E3,$00                        ; 29, 00, 00
                    dc.b $00

batman_sprite_anim_07                                       ; sprite ids - original address L00006416
                    dc.b $24,$01,$01                        ; 36, 37, 38


batman_sprite_anim_firing   ; original address L00006419    ; sprite ids
                    dc.b $27,$01,$01                        ; 39, 40, 41
                    dc.b $2A,$01,$FE                        ; 42, 43, 41
                    dc.b $2C,$FD,$D7                        ; 44, 41, 00
                    dc.b $2D,$01,$01                        ; 45, 46, 47
                    dc.b $00

L00006426           dc.b $13,$01,$01                        ; 19, 20, 21
                    dc.b $16,$01,$01                        ; 22, 23, 24
                    dc.b $00
                    
                    dc.b $1B                      




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

                    ; 44 entries in list from this address
                    ; I think these maybe trigger-points for (x) number of bad guys to appear on the level.
                    ; e.g. - 
trigger_definitions_list                                                          ; original address L0000642e
L0000642e           dc.w $02C1,$0081,$0001,$0022,$0240,$00C0 
                    dc.w $0040,$00F0,$0002,$0003,$00C0,$0118,$000F,$00A0,$0118
                    dc.w $0040,$00E2,$0001,$0002,$0008,$00D8
                    dc.w $00A8,$00F0,$0003,$000E,$0010,$0118,$000F,$00C8,$0118,$000F,$00C8,$0138
                    dc.w $00E0,$00F0,$0001,$000F,$00F0,$00D8
                    dc.w $00E0,$00A7,$0001,$0003,$0080,$0098
                    dc.w $0038,$0078,$0001,$000E,$0008,$0098
                    dc.w $0024,$0078,$0001,$000F,$00C8,$0098
                    dc.w $0040,$001F,$0001,$0003,$00B0,$0018
                    dc.w $00A8,$0010,$0003,$000E,$0008,$0018,$000F,$00D0,$0018,$000F,$00D0,$0038
                    dc.w $00D8,$0040,$0003,$000E,$0008,$0018,$000F,$00F0,$0018,$000F,$00F0,$0058
                    dc.w $0128,$0040,$0002,$000E,$0140,$0078,$000E,$0088,$0018
                    dc.w $0178,$0040,$0002,$0003,$0190,$0038,$000F,$01B0,$0018
                    dc.w $01BC,$0011,$0002,$000F,$01D0,$0018,$000F,$01B0,$0078
                    dc.w $0168,$00B0,$0002,$000F,$0160,$00F8,$0003,$0150,$0118
                    dc.w $0190,$0111,$0002,$000E,$0138,$0138,$000F,$0178,$0138
                    dc.w $01E8,$0100,$0004,$000F,$0150,$0118,$000F,$0140,$0138,$000E,$0200,$0138,$0003,$0220,$0118
                    dc.w $0220,$00EF,$0002,$000F,$0188,$00B8, $000F, $0200, $00D8
                    dc.w $0240,$003B,$0001,$000F,$0250,$0038
                    dc.w $0280,$007B,$0001,$000E,$0250,$0098
                    dc.w $02B0,$0071,$0001,$000F,$02D0,$00B8
                    dc.w $02F0,$0071,$0002,$000E,$0258,$0098,$000F,$0300,$0078
                    dc.w $02E0,$00C2,$0003,$000E,$0250,$00D8,$000F,$0250,$00F8,$000F,$0300,$00D8
                    dc.w $025C,$00CF,$0003,$000F,$0300,$00D8,$000F,$02E8,$0118,$000F,$0230,$00D8
                    dc.w $02F8,$0120,$0003,$000E,$0250,$0118,$000E,$0250,$0138,$000F,$0320,$0138
                    dc.w $0318,$0120,$0003,$000E,$0340,$0138,$0003,$0260,$0118,$000F,$0260,$0138
                    dc.w $0360,$0118,$0002,$000F,$0378,$00F8,$000F,$0378,$0118
                    dc.w $02F0,$0048,$0003,$000F,$0288,$0038,$000E,$0310,$0038,$000F,$0288,$0018
                    dc.w $0360,$0038,$0001,$0003,$0370,$0018
                    dc.w $03B0,$00B0,$0002,$0003,$03C0,$00B8,$000F,$03E0,$00D8
                    dc.w $03F0,$0102,$0001,$000E,$03C0,$0138
                    dc.w $0450,$00F2,$0003,$000E,$03B8,$0138,$000F,$0460,$0138,$0003,$0470,$00F8
                    dc.w $0468,$00C6,$0001,$0003,$0470,$00B8
                    dc.w $0468,$00A6,$0001,$000E,$0400,$0078
                    dc.w $03A0,$0050,$0001,$000F,$0440,$0098
                    dc.w $03D0,$0020,$0001,$000F,$0420,$0018
                    dc.w $0430,$0001,$0002,$000F,$0450,$0018,$000F,$0440,$0038
                    dc.w $0480,$0012,$0002,$0003,$0490,$0058,$000E,$03E0,$0018
                    dc.w $04B8,$0093,$0001,$0002,$04A4,$00B8
                    dc.w $04D8,$0110,$0002,$000E,$04A4,$0138,$000F,$0500,$0118
                    dc.w $0530,$00F0,$0001,$0003,$0580,$00F0
                    dc.w $05B0,$00C8,$0002,$000F,$0540,$00B8,$000F,$0580,$00B8
                    dc.w $0580,$0090,$0002,$000E,$0568,$0078,$000F,$0568,$0078
L0000670a           dc.w $0574,$0030,$0003,$0018,$0520,$0018,$0017,$0580,$0018,$0002,$0530,$0018
end_of_trigger_list ; original address L00006722

                    ; 3 word/ 6 byte data structure list
                    ; MSB of byte 0 is cleared on game_start
                    ; 21 - entries in list
                    ; Type, X co-ord, y co-ord?
trigger_gas_drips   ; original address L00006722
L00006722           dc.w $0014,$0118,$0038
                    dc.w $0015,$00D0,$0028
                    dc.w $0014,$0070,$0068
                    dc.w $0014,$01B0,$0110
                    dc.w $0014,$01F0,$0038
                    dc.w $0015,$01EF,$0078
                    dc.w $0015,$0217,$0028
                    dc.w $0014,$0270,$0060
                    dc.w $0016,$0298,$0090
                    dc.w $0014,$0310,$0120
                    dc.w $0016,$0378,$0038
                    dc.w $0014,$0378,$0098
                    dc.w $0014,$0398,$0090
                    dc.w $0015,$0400,$0130
                    dc.w $0014,$0458,$0078
                    dc.w $0015,$04EC,$0064
                    dc.w $0014,$03C8,$0030
                    dc.w $0014,$03D8,$0030
                    dc.w $0014,$0510,$0100
                    dc.w $0014,$0570,$0108
                    dc.w $0014,$0578,$0108
end_of_actors                                               ; original address L000067a0

                    ; ---------- Start level_parameters on game_start ----------
default_level_parameters                                    ; original address L000067a0
                    dc.w $0000                              ; window x co-ord
                    dc.w $00F0                              ; window y co-ord
                    dc.w $0000                              ; scroll_window_max_x_coord
                    dc.w $0050                              ; default L000067c2 - batman_x_offset
                    dc.w $0048                              ; default L000067c4 - batman_y_offset
                    dc.w $0048                              ; default L000067c6 - target_window_y_offset
                    dc.w $0050                              ; default L000067c8 - target_window_x_offset


                    ; ---------- Halfway Spawn Point level parameters ----------
halfway_spawn_point_parameters                              ; original address L000067ae
                    dc.w $0200                              ; window x co-ord
                    dc.w $0000                              ; window y co-ord
                    dc.w $0200                              ; scroll_window_max_x_coord
                    dc.w $0050                              ; default L000067c2 - batman_x_offset
                    dc.w $0038                              ; default L000067c4 - batman_y_offset
                    dc.w $0038                              ; default L000067c6 - target_window_y_offset
                    dc.w $0050                              ; default L000067c8 - target_window_x_offset



                    ; 7 words from L000067a0 (default_level_parameters) copied here on game_start
level_parameters                                            ; original address L000067bc
updated_batman_distance_walked                              ; original address L000067bc

scroll_window_xy_coords                                     ; original address L000067bc
scroll_window_x_coord                                       ; original address L000067bc
                    dc.w $0000
scroll_window_y_coord                                       ; original address L000067be
                    dc.w $00F0

scroll_window_max_x_coord
batman_distance_walked                      ;               original address L000067c0
L000067c0           dc.w $0000              ; keeps track of max window scroll X value (i.e. progress though the level left to right)

batman_xy_offset                            ; original address L000067c2 (used as sometimes accessed both together movem)
batman_x_offset                             ; original address L000067c2
L000067c2           dc.w $0050              ; batman offset X co-ordinate (from window X co-ord)
batman_y_offset                             ; original address L000067c4
L000067c4           dc.w $0048              ; batman offset Y co-ordinate (from window Y co-ord)


target_window_y_offset                      ; original address L000067c6              
L000067c6           dc.w $0048              ; I think this is a target y offset for batman in the window (allows window to scroll around batman to show more of the level above/below)

target_window_x_offset                      ; original address L000067c8 
L000067c8           dc.w $0050              ; I think this is a target x offset for batmin in the window (allows window to scroll around batman to show more of the level left/right)



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
large_text_plotter                                                  ; original address L000067ca
.lpt_new_line                                                       ; original address L000067ca
                    move.b  (a0)+,d0                                ; Get raster/display line
                    bmi.w   .exit                                   ; L0000689e ; if negative then exit routine
                    and.w   #$00ff,d0
                    mulu.w  #$002a,d0                               ; d0 = byte offset for display line
                    move.b  (a0)+,d1                                ; d1 = raster/line byte offset
                    ext.w   d1
                    add.w   d1,d0                                   ; d0 = total display location byte offset
                    movea.l playfield_buffer_2,a1                   ; a1 = back buffer
                    lea.l   $00(a1,d0.W),a1                         ; a1 = address of display offset.
                    ; plot next character
.plot_loop                                                          ; original address
                    moveq   #$00,d0
                    move.b  (a0)+,d0                                ; d0 = ascii value?
                    beq.b   .lpt_new_line                           ; L000067ca ; if 0 then get new x & y position
                    cmp.b   #$20,d0                                 ; #$20 (32 decimal) - ASCII Space?
                    beq.w   .increase_cursor                        ; L00006896
                    move.l  #$ffffffcd,D1                           ; #$cd (-51 decimal)
                    cmp.b   #$41,d0                                 ; #$41 (65 decimal) - ASCII 'A'
                    bcc.b   .calc_src_gfx_ptr_1                     ; L00006822
                    move.l  #$ffffffd4,D1                           ; #$d4 (-44 decimal)
                    cmp.b   #$30,d0                                 ; #$30 (48 decimal) - ASCII '0'
                    bcc.b   .calc_src_gfx_ptr_1                     ; L00006822
                    moveq   #$00,d1
                    cmp.b   #$21,d0                                 ; #$21 (33 decimal) - ASCII '!'
                    beq.b   .calc_src_gfx_ptr_2                     ; L00006828
                    moveq   #$01,d1
                    cmp.b   #$28,d0                                 ; #$28 (40 decimal) - ASCII '('
                    beq.b   .calc_src_gfx_ptr_2                     ; L00006828
                    moveq   #$02,d1
                    cmp.b   #$29,d0                                 ; #$29 (41 decimal) - ASCII ')'
                    beq.b   .calc_src_gfx_ptr_2                     ; L00006828
                    moveq   #$03,d1
                    bra.b   .calc_src_gfx_ptr_2                     ;L00006828

                    ; adjust char index by value in d1
.calc_src_gfx_ptr_1                                                 ; original address L00006822
                    add.b   d0,d1                                   ; adjust initial char id (sub 51 for alph, sub 44 for numeric)
                    and.w   #$00ff,d1

                    ; muliply char index by size of char
                    ; add to base to get src gfx ptr
.calc_src_gfx_ptr_2                                                 ; original address L00006828
                    mulu.w  #$0028,d1                               ; #$28 (40 decimal) (source gfx size)
                    lea.l   large_character_gfx,a2                  ; L000068a0,a2 ; source gfx ptr
                    lea.l   $00(a2,d1.W),a2                         ;  == $0006d7e7,a2

                    ; a1 = gfx src ptr
                    ; a3 = display dest ptr
.draw_character                                                     ; original address L00006836
                    moveq   #$07,d7                                 ; loop count 7+1 = 8
                    movea.l a1,a3
.draw_loop                                                          ; original address L0000683a
                    ; print character line
                    ; mask
                    move.b  (a2)+,d1                                ; d1 = mask byte
                    ; bpl0
                    and.b   d1,(a3)
                    move.b  (a2)+,d2                                ; bpl0 = char data
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
                    lea.l   $002a(a3),a3                            ; increase display ptr 1 line (42 bytes)
                    lea.l   -$0005(a2),a2                           ; reset gfx ptr to start of src gfx data
                    
                    ; mask
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

                    lea.l   $002a(a3),a3                            ; increase display ptr 1 line (42 bytes)
                    dbf.w   d7,.draw_loop 
.increase_cursor 
                    lea.l   $0001(a1),a1                
                    bra.w   .plot_loop                              ; L000067e8
.exit 
                    rts 



                    ;----------------------------- large character font --------------------------------
                    ; Its actually an 8x8 pixel interleaved font in 4 bitplanes and a mask.
                    ; The large_text_plotter expands the font in the Y direction to double its height.
                    ; 
                    ; Source gfx for font data
                    ; Interleaved gfx 
                    ; 5 byte sequences of data (mask, bpl0, bpl2, bpl3, bpl4)
                    ;
large_character_gfx                                     ; original address L000068a0
                    include font8x8x4.s








                    ;-------------------------------------------------------------------------------------------
                    ; My Debug Routines
                    ;-------------------------------------------------------------------------------------------
                    ; I added the following routines to allow 'signals' to be flashed on screen, and/or
                    ; the game to be paused as required.
                    ;
                    ; The routines are used to modify routines so that I can flash the screen, pause the
                    ; game when certain code is executed.
                    ;

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
            dcb.B   1024,0

            ; If Test Build - Include the Level Music and SFX
            IFD TEST_BUILD_LEVEL
                incdir      "../chem/"
                include     "chem.s"
            ENDC

            ; padding - see if it fixes map data corruption
            dcb.B   1024,0

            ; If Test Build - Include the Bottom Panel (Score, Energy, Lives, Timer etc)
            IFD TEST_BUILD_LEVEL
                incdir      "../panel/"
                include     "panel.s"                                           ; original load address $2FFC
            ENDC

            ; padding - see if it fixes map data corruption
            dcb.B   1024,0

            ; If Test Build - Include the level map data and graphics
            IFD TEST_BUILD_LEVEL
                incdir      "../mapgr/"
                include     "mapgr.s"
            ENDC

            ; padding - see if it fixes map data corruption
            dcb.B   1024,0

            ; If Test Build - Include Batman Sprites File 1n( also allocate memory for mirrored sprites)
            IFD TEST_BUILD_LEVEL
                incdir      "../batspr1/"
                include     "batspr1.s"
                dcb.b       98856,0
            ENDC

            ; padding - see if it fixes map data corruption
            dcb.B   1024,0

            IFD TEST_BUILD_LEVEL
                even
sprite_list     dcb.b       305*8,0
            ENDC