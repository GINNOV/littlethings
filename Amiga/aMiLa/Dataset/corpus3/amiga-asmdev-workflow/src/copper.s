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

;-----------------------------------------------------------
; Small coplist for refreshing the bitplane pointers

Coplist::
  DC.W       $1807,$fffe               ; Wait for start of line $18 
CopBPL::
  DC.W       BPL1PTH,0                 ; High word APTR bitplane 1
  DC.W       BPL1PTL,0                 ; Low word APTR bitplane 1
  DC.W       BPL2PTH,0                 ; High word APTR bitplane 2
  DC.W       BPL2PTL,0                 ; Low word APTR bitplane 2

		; Set palette for bitplanes
  include    "Background_palette.i"
		; Set palette for sprites
  include    "sprites_01_palette.i"
  include    "sprites_23_palette.i"
  include    "sprites_45_palette.i"
  include    "sprites_67_palette.i"

CopSprite::
  DC.W       SPR0PTH,0                 ; High word APTR sprite 0
  DC.W       SPR0PTL,0                 ; Low word APTR sprite 0
  DC.W       SPR1PTH,0                 ; High word APTR sprite 1
  DC.W       SPR1PTL,0                 ; Low word APTR sprite 1
  DC.W       SPR2PTH,0                 ; High word APTR sprite 2
  DC.W       SPR2PTL,0                 ; Low word APTR sprite 2
  DC.W       SPR3PTH,0                 ; High word APTR sprite 3
  DC.W       SPR3PTL,0                 ; Low word APTR sprite 3
  DC.W       SPR4PTH,0                 ; High word APTR sprite 4
  DC.W       SPR4PTL,0                 ; Low word APTR sprite 4
  DC.W       SPR5PTH,0                 ; High word APTR sprite 5
  DC.W       SPR5PTL,0                 ; Low word APTR sprite 5
  DC.W       SPR6PTH,0                 ; High word APTR sprite 6
  DC.W       SPR6PTL,0                 ; Low word APTR sprite 6
  DC.W       SPR7PTH,0                 ; High word APTR sprite 7
  DC.W       SPR7PTL,0                 ; Low word APTR sprite 7

  DC.W       $ffff,$fffe               ; Wait indefinitely

