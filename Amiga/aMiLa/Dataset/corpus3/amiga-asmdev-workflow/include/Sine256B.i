
; Copyright 2021 ing. E. Th. van den Oosterkamp
;
; Example software for the book "BareMetal Amiga Programming" (ISBN 9798561103261)
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

; 256 BYTE wide sine values calculated with Asm-Pro's "is" command

	DC.B	$02,$05,$08,$0B,$0E,$11,$14,$17,$1A,$1D,$20,$23,$26,$29,$2C,$2F
	DC.B	$32,$35,$38,$3A,$3D,$40,$43,$45,$48,$4A,$4D,$4F,$52,$54,$56,$59
	DC.B	$5B,$5D,$5F,$61,$63,$65,$67,$69,$6A,$6C,$6E,$6F,$71,$72,$73,$75
	DC.B	$76,$77,$78,$79,$7A,$7B,$7C,$7C,$7D,$7D,$7E,$7E,$7F,$7F,$7F,$7F
	DC.B	$7F,$7F,$7F,$7F,$7E,$7E,$7D,$7D,$7C,$7C,$7B,$7A,$79,$78,$77,$76
	DC.B	$75,$73,$72,$71,$6F,$6E,$6C,$6A,$69,$67,$65,$63,$61,$5F,$5D,$5B
	DC.B	$59,$56,$54,$52,$4F,$4D,$4A,$48,$45,$43,$40,$3D,$3A,$38,$35,$32
	DC.B	$2F,$2C,$29,$26,$23,$20,$1D,$1A,$17,$14,$11,$0E,$0B,$08,$05,$02
	DC.B	$FE,$FB,$F8,$F5,$F2,$EF,$EC,$E9,$E6,$E3,$E0,$DD,$DA,$D7,$D4,$D1
	DC.B	$CE,$CB,$C8,$C6,$C3,$C0,$BD,$BB,$B8,$B6,$B3,$B1,$AE,$AC,$AA,$A7
	DC.B	$A5,$A3,$A1,$9F,$9D,$9B,$99,$97,$96,$94,$92,$91,$8F,$8E,$8D,$8B
	DC.B	$8A,$89,$88,$87,$86,$85,$84,$84,$83,$83,$82,$82,$81,$81,$81,$81
	DC.B	$81,$81,$81,$81,$82,$82,$83,$83,$84,$84,$85,$86,$87,$88,$89,$8A
	DC.B	$8B,$8D,$8E,$8F,$91,$92,$94,$96,$97,$99,$9B,$9D,$9F,$A1,$A3,$A5
	DC.B	$A7,$AA,$AC,$AE,$B1,$B3,$B6,$B8,$BB,$BD,$C0,$C3,$C6,$C8,$CB,$CE
	DC.B	$D1,$D4,$D7,$DA,$DD,$E0,$E3,$E6,$E9,$EC,$EF,$F2,$F5,$F8,$FB,$FE


