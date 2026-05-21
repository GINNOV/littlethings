; Copyright 2024 Neil Davis
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

;-----------------------------------------------------------
; Move sprites
; 		D0.W - BOB X pos (hor) 
; 		D1.W - BOB Y pos (vert) 
MoveSprites::
	; Very crude.
              MOVE.W     PrevPos(PC),d3
              MOVE.W     PrevPos+2(PC),d4
              ADDI.W     #$80-8,d3                          ; x pos in DISPW
              ADDI.W     #$2c+$40,d4                        ; y pos in DISPW
              MOVE.L     #16,d2                             ; height
			  ; A
              MOVE.W     d3,d0
              MOVE.W     d4,d1
              LEA.L      Sprite0,a0                         ; sprite ptr
              BSR.S      SetSprite
			  ; M
              ADDI.W     #20,d3
              MOVE.W     d3,d0
              MOVE.W     d4,d1
              LEA.L      Sprite2,a0                         ; sprite ptr
              BSR.S      SetSprite
			  ; I
              ADDI.W     #20,d3
              MOVE.W     d3,d0
              MOVE.W     d4,d1
              LEA.L      Sprite4,a0                         ; sprite ptr
              BSR.S      SetSprite
			  ; G
              ADDI.W     #12,d3
              MOVE.W     d3,d0
              MOVE.W     d4,d1
              LEA.L      Sprite6,a0                         ; sprite ptr
              BSR.S      SetSprite
			  ; A
              ADDI.W     #20,d3
              MOVE.W     d3,d0
              MOVE.W     d4,d1
              LEA.L      Sprite1,a0                         ; sprite ptr
              BSR.S      SetSprite
              RTS

;-----------------------------------------------------------
; Move sprite with low resolution steps
;
; INPUT:	A0 - APTR Sprite struct
; 		D0 - X pos (hor)  $80 to $1C0 with default display window
; 		D1 - Y pos (vert) $2C to $12C with default display window
; 		D2 - Height

SetSprite:    AND.B      #$80,3(a0)                         ; Clear all except ATTACH bit
              MOVE.B     d1,(a0)                            ; SV7 - SV0
              BTST       #8,d1
              BEQ.B      .NoSV8
              OR.B       #$04,3(a0)                         ; Set SV8
.NoSV8	
              ADD.W      d2,d1                              ; Add height to get end position
              MOVE.B     d1,2(a0)                           ; EV7 - EV0
              BTST       #8,d1
              BEQ.B      .NoEV8
              OR.B       #$02,3(a0)                         ; Set EV8
.NoEV8	
              BTST       #0,d0                              ; Check H0
              BEQ.B      .NoH0
              OR.B       #$01,3(a0)                         ; Set H0
.NoH0         ASR.W      #1,d0                              ; Shift out H0
              MOVE.B     d0,1(a0)                           ; Set H8 - H1
              RTS

;-----------------------------------------------------------
; Sprite structures

SpriteList::  DC.L       Sprite0,Sprite1,Sprite2,Sprite3
              DC.L       Sprite4,Sprite5,Sprite6,Sprite7

Sprite0::     DC.W       $1010,$2000
              INCBIN     "assets/spr0_a.raw"
              DC.W       0,0

Sprite2::     DC.W       $1010,$2000
              INCBIN     "assets/spr2_m.raw"
              DC.W       0,0

Sprite4::     DC.W       $1010,$2000
              INCBIN     "assets/spr4_i.raw"
              DC.W       0,0

Sprite6::     DC.W       $1010,$2000
              INCBIN     "assets/spr6_g.raw"
              DC.W       0,0

Sprite1::     DC.W       $1010,$2000
              INCBIN     "assets/spr0_a.raw"
              DC.W       0,0

Sprite3::
Sprite5::
Sprite7::
              DC.W       $1010,$2000
              DC.W       $2b20,$2b00                        ; pos
              DC.W       0,0                                ; data
              DC.W       0,0                                ; 'end of data'


