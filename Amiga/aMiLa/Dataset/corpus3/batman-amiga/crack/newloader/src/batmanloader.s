;-----------------------------------------------------------------------------------------------------------------------------
; A replacement loader for the game.
;-----------------------------------------------------------------------------------------------------------------------------


;               -- Copy protection addresses and values to restore
;               -- need to work out where in the relocated code below to insert these values.
;               -- 00000DCA 526F 6220 4E6F 7274 6865 6E20 436F 6D70  Rob Northen Comp
;               -- 00000DDA 6AD4 A952 A449 9327 A4AA 92A5 1455 1451  j..R.I.'.....U.Q
;               -- 00000DEA 152A 9444 5112 4449 1124 4492 9249 4925  .*.DQ.DI.$D..II%
;               -- 00000DFA 2495 0000 0000 0000 0000 0000 0000 0000  $...............
;               -- 00000E0A 0000 0000 0000 
                ; - $0E10 = D0 = FF7EEFAB - *** Protection Checksum Value ***




;---------- Includes ----------
              INCDIR        "include"
              INCLUDE       "hw.i"

              section       loader,code_c
              opt           o-

kill_system
                lea     $dff000,a6
                move.w  #$7fff,INTENA(a6)
                move.w  #$7fff,DMACON(a6)
                move.w  #$7fff,INTREQ(a6)   

.mouse_loop
                btst    #$6,$bfe001
                bne.s   .mouse_loop

                ;------------- reallocate the loader code ------------------
realloc_loader
                lea     loaderstart,a0
                lea     loaderend,a1
                lea     $800,a2
.realloc_loop
                move.w  (a0)+,(a2)+
                move.w  d0,COLOR00(a6)
                add.w   #1,d0
                cmp.l   a0,a1
                bne     .realloc_loop


                ;------------------- realloc cp data -----------------------
                ; copy the original copy protection data to the original
                ; location in the relocated loader memory.
;insert_cp_data
;                moveq   #$24,d7                       ; 37 - 1 - loop counter
;                lea     copy_protection_data(pc),a0
;                lea     $DCA,a1
;.copy_loop
;                move.w  (a0)+,(a1)+
;                dbra    d7,.copy_loop

                ; jump to start of relocated loader in memory
                jmp     $800



                ; -- Copy protection addresses and values to restore
                ; -- need to work out where in the relocated code below to insert these values.
                ; original address $00000DCA
copy_protection_data  
                dc.W  $526F, $6220, $4E6F, $7274, $6865, $6E20, $436F, $6D70      ;Rob Northen Comp
                dc.W  $6AD4, $A952, $A449, $9327, $A4AA, $92A5, $1455, $1451      ;j..R.I.'.....U.Q
                dc.W  $152A, $9444, $5112, $4449, $1124, $4492, $9249, $4925      ;.*.DQ.DI.$D..II%
                dc.W  $2495, $0000, $0000, $0000, $0000, $0000, $0000, $0000      ;$...............
                dc.W  $0000, $0000, $0000 
                dc.w  $FF7E, $EFAB

            ;-------------------- loader start -------------------
            ; entry point of relocated loader at address $800.l
            ; contains jump table as expected by the game to 
            ; load each game seciton

loaderstart:
                bra.b jump_table                                    ; Calls $0000081C - jmp_load_screen (addr: $00000800)
                                                                    ; This will get overwritten by the stack during loading

unused_globals_1
                dc.w    $0000, $22BA, $0000, $0000                  ; Unused memory, the stack will grown down over this.
                dc.w    $0000, $0000, $0000, $0000                  ; 
                dc.w    $0000, $0000, $0000, $0000                  ;
                dc.w    $0000                                       ;

stack                                                               ; Top of Loader Stack, (re)set each time a game section is loaded. (addr:$0000081C) 
jump_table                                                          ; Start of jump table for loading and executing the game sections. (original addr:$0000081C)
                bra.w  load_loading_screen                          ; Load Loading Screen (instruction addr:$0000081C)
                bra.w  load_title_screen2                           ; Load Title Screen2  (instruction addr:$00000820)
                bra.w  load_level_1                                 ; Load Level 1 - Axis Chemicals (instruction addr:$00000824)
                bra.w  load_level_2                                 ; Load Level 2 - Bat Mobile (instruction addr:$00000829)
                bra.w  load_level_3                                 ; Load Level 3 - Bat Cave Puzzle (instruction addr:$0000082C)
                bra.w  load_level_4                                 ; Load Level 4 - Batwing Parade (instruction addr:$00000830)
                bra.w  load_level_5                                 ; Load Level 5 - Cathedral (instruction addr:$00000834)



                    ;----------- load title screen & loading screen ------------
load_loading_screen
                    lea     stack(pc),a7                              ; initialise game stack (as per original game loader)
                    bsr     init_system                               ; kill the system         
                    lea     .loading_parameters(pc),a5                ; a5 = load data structure
                    bra     load_files

.loading_parameters
                    dc.l  $3f000                                    ; 00 - loading stack address
                    dc.l  $5d000                                    ; 04 - load data buffer
                    dc.l  $20000                                    ; 08 - load work buffer
                    dc.l  $1c000                                    ; 0C - start address
                    dc.l  .filename1-.loading_parameters,$7c7fc     ; panel
                    dc.l  .filename2-.loading_parameters,$3FFC      ; title prg
                    dc.l  .filename3-.loading_parameters,$3F236     ; title pic
                    dc.l  $00000000
.filename1          dc.b   "panel.zx0",0
.filename2          dc.b   "titleprg.zx0",0
.filename3          dc.b   "titlepic.zx0",0
;.filename1          dc.b   "panel.shrunk",0
;.filename2          dc.b   "titleprg.shrunk",0                  
;.filename3          dc.b   "titlepic.shrunk",0
                    even


                    ;----------- load title screen, after failed game end, maybe completion ------------
load_title_screen2
                    lea     stack(pc),a7                                ; initialise game stack (as per original game loader)
                    bsr     init_system                                 ; kill the system         
                    lea     .loading_parameters(pc),a5                  ; a5 = load data structure
                    bra     load_files
                
.loading_parameters
                    dc.l  $3f000                                        ; 00 - loading stack address
                    dc.l  $5d000                                        ; 04 - load data buffer
                    dc.l  $20000                                        ; 08 - load work buffer
                    dc.l  $1c004                                        ; 0C - start address
                    dc.l  .filename1-.loading_parameters,$3FFC          ; title prg
                    dc.l  .filename2-.loading_parameters,$3F236         ; title pic
                    dc.l  $00000000
.filename1          dc.b   "titleprg.zx0",0
.filename2          dc.b   "titlepic.zx0",0
;.filename1          dc.b   "titleprg.shrunk",0
;.filename2          dc.b   "titlepic.shrunk",0
                    even



                    ;--------------------- load level 1 ----------------------
load_level_1
                    lea     stack(pc),a7                                ; initialise game stack (as per original game loader)
                    bsr     init_system                                 ; kill the system         
                    lea     .loading_parameters(pc),a5                  ; a5 = load data structure
                    bra     load_files
                
.loading_parameters
                    dc.l  $47000                                        ; 00 - loading stack address
                    dc.l  $59000                                        ; 04 - load data buffer
                    dc.l  $2a000                                        ; 08 - load work buffer
                    dc.l  $3000                                         ; 0C - start address
                    dc.l  .filename1-.loading_parameters,$2ffc          ; code1
                    dc.l  .filename2-.loading_parameters,$7ffc          ; mapgr
                    dc.l  .filename3-.loading_parameters,$10ffc         ; batspr1
                    dc.l  .filename4-.loading_parameters,$47fe4         ; chem                    
                    dc.l  $00000000
.filename1          dc.b   "code1.zx0",0
.filename2          dc.b   "mapgr.zx0",0
.filename3          dc.b   "batspr1.zx0",0
.filename4          dc.b   "chem.zx0",0
;.filename1          dc.b   "code1.shrunk",0
;.filename2          dc.b   "mapgr.shrunk",0
;.filename3          dc.b   "batspr1.shrunk",0
;.filename4          dc.b   "chem.shrunk",0
                    even




                    ;--------------------- load level 2 ----------------------
load_level_2
                    lea     stack(pc),a7                                ; initialise game stack (as per original game loader)
                    bsr     init_system                                 ; kill the system         
                    lea     .loading_parameters(pc),a5                  ; a5 = load data structure
                    bra     load_files
                
.loading_parameters
                    dc.l  $1fffc                                        ; 00 - loading stack address
                    dc.l  $56a00                                        ; 04 - load data buffer
                    dc.l  $ce00                                         ; 08 - load work buffer
                    dc.l  $3000                                         ; 0C - start address
                    dc.l  .filename1-.loading_parameters,$2ffc          ; code
                    dc.l  .filename2-.loading_parameters,$1fffc         ; data
                    dc.l  .filename3-.loading_parameters,$2a416         ; data2
                    dc.l  .filename4-.loading_parameters,$68f7c         ; music                    
                    dc.l  $00000000
.filename1          dc.b   "code.zx0",0
.filename2          dc.b   "data.zx0",0
.filename3          dc.b   "data2.zx0",0
.filename4          dc.b   "music.zx0",0
;.filename1          dc.b   "code.shrunk",0
;.filename2          dc.b   "data.shrunk",0
;.filename3          dc.b   "data2.shrunk",0
;.filename4          dc.b   "music.shrunk",0
                    even




                    ;--------------------- load level 3 ----------------------
load_level_3
                    lea     stack(pc),a7                                ; initialise game stack (as per original game loader)
                    bsr     init_system                                 ; kill the system         
                    lea     .loading_parameters(pc),a5                  ; a5 = load data structure
                    bra     load_files
                
.loading_parameters
                    dc.l  $3f000                                        ; 00 - loading stack address
                    dc.l  $5d000                                        ; 04 - load data buffer
                    dc.l  $20000                                        ; 08 - load work buffer
                    dc.l  $d000                                         ; 0C - start address
                    dc.l  .filename1-.loading_parameters,$3ffc          ; batcave                   
                    dc.l  $00000000
.filename1          dc.b   "batcave.zx0",0
;;.filename1          dc.b   "batcave.shrunk",0
                    even




                    ;--------------------- load level 4 ----------------------
load_level_4
                    lea     stack(pc),a7                                ; initialise game stack (as per original game loader)
                    bsr     init_system                                 ; kill the system         
                    lea     .loading_parameters(pc),a5                  ; a5 = load data structure
                    bra     load_files
                
.loading_parameters
                    dc.l  $1fffc                                        ; 00 - loading stack address
                    dc.l  $56a00                                        ; 04 - load data buffer
                    dc.l  $ce00                                         ; 08 - load work buffer
                    dc.l  $00003002                                     ; 0C - start address
                    dc.l  .filename1-.loading_parameters,$2ffc          ; code
                    dc.l  .filename2-.loading_parameters,$1fffc         ; data
                    dc.l  .filename3-.loading_parameters,$2a416         ; data4
                    dc.l  .filename4-.loading_parameters,$68f7c         ; music                    
                    dc.l  $00000000
.filename1          dc.b   "code.zx0",0
.filename2          dc.b   "data.zx0",0
.filename3          dc.b   "data4.zx0",0
.filename4          dc.b   "music.zx0",0
;.filename1          dc.b   "code.shrunk",0
;.filename2          dc.b   "data.shrunk",0
;.filename3          dc.b   "data4.shrunk",0
;.filename4          dc.b   "music.shrunk",0
                    even




                    ;--------------------- load level 5 ----------------------
load_level_5
                    lea     stack(pc),a7                                ; initialise game stack (as per original game loader)
                    bsr     init_system                                 ; kill the system         
                    lea     .loading_parameters(pc),a5                  ; a5 = load data structure
                    bra     load_files
                
.loading_parameters
                    dc.l  $47000                                        ; 00 - loading stack address
                    dc.l  $59000                                        ; 04 - load data buffer
                    dc.l  $2a000                                        ; 08 - load work buffer
                    dc.l  $3000                                         ; 0C - start address
                    dc.l  .filename1-.loading_parameters,$2ffc          ; code5
                    dc.l  .filename2-.loading_parameters,$7ffc          ; mapgr2
                    dc.l  .filename3-.loading_parameters,$10ffc         ; batspr1
                    dc.l  .filename4-.loading_parameters,$47fe4         ; church                    
                    dc.l  $00000000
.filename1          dc.b   "code5.zx0",0
.filename2          dc.b   "mapgr2.zx0",0
.filename3          dc.b   "batspr1.zx0",0
.filename4          dc.b   "church.zx0",0
;.filename1          dc.b   "code5.shrunk",0
;.filename2          dc.b   "mapgr2.shrunk",0
;.filename3          dc.b   "batspr1.shrunk",0
;.filename4          dc.b   "church.shrunk",0
                    even



              ;----------------- Load Files ----------------
              ; IN: a5 = loading parameters
load_files
                lea     $dff000,a6                                ; a6 = custom base
                move.w  #$8360,DMACON(a6)                         ; enable DMA, MASTER, DISK, COPPER, BLITTER
                move.l  (a5),a7                                   ; set stack address
                lea.l   $10(a5),a4                                ; a4 = files to load
.loadloop
                tst.l   (a4)
                beq     .endload

.retryload
                move.w  VHPOSR(a6),COLOR00(a6)            ; change background colour for each file loading

                ; load file
                moveq.l #$00,d0                           ; d0 = rnc - load file command      
                move.l  (a4),d5                           ; d5 = filename offset
                lea.l   (a5,d5.w),a0                      ; a0 = filename to load
                move.l  4(a5),a1                          ; a1 = load address
                move.l  8(a5),a2                          ; a2 = track buffers
                bsr     dosio                             ; load file into memory
                tst.l   d0                                ; test load result
                bne     .load_error

;                ; zx0 - decrunch file
                movem.l d0-d7/a0-a6,-(a7)
                move.l  4(a5),a0                          ; compressed data
                move.l  4(a4),a1                          ; decompressed buffer
                bsr   zx0_decompress
                movem.l (a7)+,d0-d7/a0-a6

;                ; shrinkler - decrunch file
;                move.l  4(a5),a0                          ; compressed data
;                move.l  4(a4),a1                          ; decompressed buffer
;                lea     $0,a2
;                lea     $0,a3
;                moveq.l #$00,d2
;                moveq.l #$01,d7
;                bsr     ShrinklerDecompress

                ; next file
                lea.l   8(a4),a4                          ; next file to load
                bra     .loadloop
               
.endload
                lea     stack(pc),a7                      ; set game stack (as per original game)
                move.w  #$83ff,DMACON(a6)
                move.w  #$0fff,COLOR00(a6)
                move.l  $C(a5),a5
                bsr     set_exceptions

                btst.b  #$6,$bfe001
                bne.s   .start_game
.add_cheat
                bsr     add_cheat
.start_game
                movem.l d0-d7/a0-a6,-(a7)
                bsr     init_system
                movem.l (a7)+,d0-d7/a0-a6
                jmp     (a5)                              ; start execution address

.load_error
                move.w  #$ffff,d7
.error_loop
                move.w  #$f00,COLOR00(a6)
                dbra    d7,.error_loop
                jmp     .retryload                        ; retry



                ;------------------ set exceptions ----------------------
                ; set the original value to exception vectors that would
                ; be set by the game loader & copy protection
                ;
set_exceptions:
                move.l  #$00002070,$8
                move.l  #$00002070,$c
                move.l  #$FF7EEFAB,$24
                rts



                ;----------------- infinite energy cheat -----------------
add_cheat:
                move.w  #$4e71,$7fa76
                move.w  #$4e71,$7fa78
                move.w  #$4e71,$7fa7a
                rts



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
                move.w  #$e078,INTENA(a6)
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




                ;  unzx0_68000.s - ZX0 decompressor for 68000 - 88 bytes
                ;
                ;  in:  a0 = start of compressed data
                ;       a1 = start of decompression buffer
                ;
                even
                INCDIR        "zx0"
                INCLUDE       "unzx0_68000.S"
                even


                ; Decompress Shrinkler-compressed data produced with the --data option.
                ;
                ; A0 = Compressed data
                ; A1 = Decompressed data destination
                ; A2 = Progress callback, can be zero if no callback is desired.
                ;      Callback will be called continuously with
                ;      D0 = Number of bytes decompressed so far
                ;      A0 = Callback argument
                ;      D1 = Second callback argument
                ; A3 = Callback argument
                ; D2 = Second callback argument
                ; D7 = 0 to disable parity context (Shrinkler --bytes / -b option)
                ;      1 to enable parity context (default Shrinkler compression)
                ;
                ; Uses 3 kilobytes of space on the stack.
                ; Preserves D2-D7/A2-A6 and assumes callback does the same.
                ;
                ; Decompression code may read one byte beyond compressed data.
                ; The contents of this byte does not matter.

                ;ShrinklerDecompress:
                ;            INCDIR        "shrinkler"
                ;            INCLUDE       "ShrinklerDecompress.S"




                ;------------------------ Copy Protection Values -----------------------
                ; space to write the original copy protection values that are loaded in
                ; from the copylock track.
                ;dcb.l    64,$AAAAAAAA                               ;256 bytes of memory for original copy protection data
                ;even



                *	a0.l = full pathname of file, terminated with 0
                *	a1.l = file buffer (even word boundary)
                *		if d0.l=3 a1.l = ptr to file name buffer
                *	a2.l = workspace buffer ($4d00 bytes of CHIPmem required)
                INCDIR        "rnc/dosio"
                INCLUDE       "dosio.s"


                ; spare bytes
                dc.l      0,0,0,0

loaderend: