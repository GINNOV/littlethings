; Copyright 2021 ing. E. Th. van den Oosterkamp. Copyright 2024 Neil Davis
;
; Based on example software for the book "BareMetal Amiga Programming" (ISBN 9798561103261)
;
; Permission is hereby granted, free of charge, to any person obtaining a copy 
; of this software and associated files (the "Software"), to deal in the Software 
; without restriction, including without limitation the rights to use, copy,
; modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
; and to permit persons to whom the Software is furnished to do so,
; subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in 
; all copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
; INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
; PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
; HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION 
; OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
; SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


                  INCLUDE    "BareMetal.i"

;-----------------------------------------------------------

                  SECTION    Code,CODE_C		

                  INCLUDE    "SafeStart.i"

Main:
                  LEA.L      Coplist(PC),a0                 ; 
                  MOVE.L     a0,COP1LC(a5)                  ; Set start address for coplist

; Setup the bitplane pointers in the coplist
                  LEA.L      CopBPL(PC),a0
                  LEA.L      Bitplanes(PC),a1               ; APTR Start of bitplane 1
                  MOVE.L     a1,d0
                  MOVE.W     d0,6(a0)                       ; Place low word into coplist
                  SWAP       d0
                  MOVE.W     d0,2(a0)                       ; Place high word into coplist
                  ADDA.W     #40,a1                         ; Bitplane 2 starts one line later
                  MOVE.L     a1,d0
                  MOVE.W     d0,14(a0)                      ; Place low word into coplist
                  SWAP       d0
                  MOVE.W     d0,10(a0)                      ; Place high word into coplist

; Decompress background image data into Bitplanes
                  LEA.L      Background_ZX0,a0              ; ZX0 compressed SRC
                  LEA.L      Bitplanes,a1                   ; Bitplanes DEST
                  BSR        zx0_decompress

; Setup the sprite pointers in the coplist

                  LEA.L      CopSprite(PC),a0               ; APTR Sprite pointers in coplist
                  LEA.L      SpriteList(PC),a1              ; APTR List of sprite pointers
                  MOVEQ      #8-1,d7                        ; Process 8 sprite pointers
.NextSprite       MOVE.L     (a1)+,d0
                  MOVE.W     d0,6(a0)                       ; Place low word into coplist
                  SWAP       d0
                  MOVE.W     d0,2(a0)                       ; Place high word into coplist
                  ADDQ.L     #8,a0                          ; Move to next pointer in coplist
                  DBF        d7,.NextSprite

; Prepare the playfield. Note COLOURxx registers set by Copper palette include


                  MOVE.W     #40,BPL1MOD(a5)                ; All bitplanes need to skip one line
                  MOVE.W     #40,BPL2MOD(a5)                ; at the end of each line

                  MOVE.W     #$2200,BPLCON0(a5)             ; 2 bitplanes, enable colour on composite
                  MOVE.W     #0,BPLCON1(a5)                 ; No delay/shift on odd or even bitplane
                  MOVE.W     #0,BPLCON2(a5)                 ; Functionality not required
                  MOVE.W     #$24,BPLCON2(a5)               ; All sprites above pf1
 
                  MOVE.W     #0,FMODE(a5)                   ; AGA: Use 16 bit DMA transfers
                  MOVE.W     #$2C81,DIWSTRT(a5)             ; Left/top corner of display window
                  MOVE.W     #$2CC1,DIWSTOP(a5)             ; Right/bottom corner of display window
                  MOVE.W     #$38,DDFSTRT(a5)               ; Location of first DMA fetch each line
                  MOVE.W     #$D0,DDFSTOP(a5)               ; Location of last DMA fetch each line

                  MOVE.W     #$81E0,DMACON(a5)              ; Enable bitplane, Copper, Sprite and Blitter DMA

                  MOVE.W     PrevPos(PC),d0
                  MOVE.W     PrevPos+2(PC),d1
                  LEA.L      ObjectStore,a0
                  BSR        PrepBOB

; Wait for the user to click the mouse	

.WaitLoop
                  MOVE.L     VPOSR(a5),d0                   ; Get VPOSR and VHPOSR 
                  LSR.L      #8,d0                          ; Shift vertical pos to lowest 9 bits
                  AND.W      #$01FF,d0                      ; Remove unwanted bits
                  CMP.W      #$0001,d0                      ; On line 1?
                  BNE.B      .Skip                          ; No? Do nothing

                  BSR.W      MoveBOB
                  BSR.W      MoveSprites 
.Wait
                  MOVE.L     VPOSR(a5),d0                   ; Get vertical an horizontal position
                  LSR.L      #8,d0                          ; Shift vertical pos to lowest 9 bits
                  AND.W      #$01FF,d0                      ; Remove unwanted bits
                  CMP.W      #$0001,d0                      ; On line 1?
                  BEQ.B      .Wait                          ; Wait until no longer on line 1

.Skip
                  BTST       #6,CIAAPRA                     ; Check for left mouse click
                  BNE.B      .WaitLoop                      ; No click, keep testing
                  RTS


;-----------------------------------------------------------

PrevPos::         DC.W       0,0

Background_ZX0::  INCBIN     "assets/Background_raw.zx0"
                  EVEN


;-----------------------------------------------------------

                  SECTION    BitPlane,BSS_C

Bitplanes::       DS.B       320*256*2/8                    ; 320x256 screen, 2 (interleaved) bitplanes

ObjectStore::     DS.B       (80*64*2)/8

;-----------------------------------------------------------
