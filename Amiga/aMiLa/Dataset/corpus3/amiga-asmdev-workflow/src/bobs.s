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

MoveBOB::
             MOVE.W     PrevPos(PC),d0
             MOVE.W     PrevPos+2(PC),d1
             LEA.L      ObjectStore,a0
             BSR.W      ClearBOB

             LEA.L      Sine(PC),a0
             MOVEQ      #0,d0
             MOVE.B     SinePos(PC),d0
             ADDQ.B     #1,d0
             MOVE.B     d0,SinePos
             MOVE.B     (a0,d0.W),d0
             EXT.W      d0
             ADD.W      #128,d0
             MOVE.W     d0,PrevPos

             MOVEQ      #0,d1
             MOVE.B     SinePos+1(PC),d1
             ADDQ.B     #2,d1
             MOVE.B     d1,SinePos+1
             MOVE.B     (a0,d1.W),d1
             EXT.W      d1
             ASR        d1
             ADD.W      #64,d1
             MOVE.W     d1,PrevPos+2

             LEA.L      ObjectStore,a0
             BSR.B      PrepBOB

             MOVE.W     PrevPos(PC),d0
             MOVE.W     PrevPos+2(PC),d1
             LEA.L      Object(PC),a0                   ; APTR object
             LEA.L      ObjectMask(PC),a1               ; APTR mask
             BSR.B      PlaceBOB

             RTS


;-----------------------------------------------------------
; INPUT:	A0   - APTR Storage space
; 		D0.W - X pos (hor) 
; 		D1.W - Y pos (vert) 

PrepBOB::
             LEA.L      Bitplanes(PC),a1                ; APTR interleaved playfield
             MULU       #80,d1                          ; Convert Y pos into offset
             ADD.L      d1,a1                           ; Add offset to destination
             AND.W      #$FFF0,d0                       ; Position without shift
             LSR.W      #3,d0                           ; Convert to byte offset
             ADDA.W     d0,a1                           ; Add ofset to destination

             BTST.B     #14-8,DMACONR(a5)               ; Dummy read
.BltBusy
             BTST.B     #14-8,DMACONR(a5)               ; Blitter ready?
             BNE.B      .BltBusy                        ; No. Wait a bit

             MOVE.L     a1,BLTAPT(a5)                   ; Source A = playfield
             MOVE.L     a0,BLTDPT(a5)                   ; Destination = storage
             MOVE.W     #$FFFF,BLTAFWM(a5)              ; No first word masking
             MOVE.W     #$FFFF,BLTALWM(a5)              ; No last word masking
             MOVE.W     #$09F0,BLTCON0(a5)              ; USEA, USED. Minterm $F0, D=A
             MOVE.W     #0,BLTCON1(a5)                  ; Data transfer, no fills
             MOVE.W     #0,BLTDMOD(a5)                  ; Skip 0 bytes of the storage
             MOVE.W     #30,BLTAMOD(a5)                 ; Skip 30 bytes of the playfield
             MOVE.W     #128<<6+5,BLTSIZE(a5)           ; 128 lines high, 5 words wide

             RTS


;-----------------------------------------------------------
; INPUT:	A0   - APTR Blitter object
;		A1   - APTR Mask for object
; 		D0.W - X pos (hor) 
; 		D1.W - Y pos (vert) 

PlaceBOB:
             LEA.L      Bitplanes(PC),a2                ; APTR interleaved playfield
             MULU       #80,d1                          ; Convert Y pos into offset
             ADD.L      d1,a2                           ; Add offset to destination
             EXT.L      d0                              ; Clear top bits of D0
             ROR.L      #4,d0                           ; Roll shift bits to top word 
             ADD.W      d0,d0                           ; Bottom word: convert to byte offset 
             ADDA.W     d0,a2                           ; Add byte offset to destination
             SWAP       d0                              ; Move shift value to top word

             BTST.B     #14-8,DMACONR(a5)               ; Dummy read
.BltBusy
             BTST.B     #14-8,DMACONR(a5)               ; Blitter ready?
             BNE.B      .BltBusy                        ; No. Wait a bit

             MOVE.L     a1,BLTAPT(a5)                   ; Source A = Mask
             MOVE.L     a0,BLTBPT(a5)                   ; Source B = Object
             MOVE.L     a2,BLTCPT(a5)                   ; Source C = Bitplanes
             MOVE.L     a2,BLTDPT(a5)                   ; Destination = Bitplanes
             MOVE.W     #$FFFF,BLTAFWM(a5)              ; No first word masking
             MOVE.W     #$FFFF,BLTALWM(a5)              ; No last word masking
             MOVE.W     d0,BLTCON1(a5)                  ; Use shift for source B
             OR.W       #$0FCA,d0                       ; USEA,B, C and D. Minterm $CA, D=AB+/AC
             MOVE.W     d0,BLTCON0(a5)                  ; 	
             MOVE.W     #0,BLTAMOD(a5)                  ; Skip 0 bytes of the mask
             MOVE.W     #0,BLTBMOD(a5)                  ; Skip 0 bytes of the object
             MOVE.W     #30,BLTCMOD(a5)                 ; Skip 30 bytes of the destination
             MOVE.W     #30,BLTDMOD(a5)                 ; Skip 30 bytes of the destination
             MOVE.W     #128<<6+5,BLTSIZE(a5)           ; 64 lines high, 5 words wide

             RTS


;-----------------------------------------------------------
; INPUT:	A0   - APTR Storage space
; 		D0.W - X pos (hor) 
; 		D1.W - Y pos (vert) 

ClearBOB:
             LEA.L      Bitplanes(PC),a1                ; APTR interleaved playfield
             MULU       #80,d1                          ; Convert Y pos into offset
             ADD.L      d1,a1                           ; Add offset to destination
             AND.W      #$FFF0,d0                       ; Position without shift
             LSR.W      #3,d0                           ; Convert to byte offset
             ADDA.W     d0,a1                           ; Add ofset to destination

             BTST.B     #14-8,DMACONR(a5)               ; Dummy read
.BltBusy
             BTST.B     #14-8,DMACONR(a5)               ; Blitter ready?
             BNE.B      .BltBusy                        ; No. Wait a bit

             MOVE.L     a0,BLTAPT(a5)                   ; Source A = storage
             MOVE.L     a1,BLTDPT(a5)                   ; Destination = playfield
             MOVE.W     #$FFFF,BLTAFWM(a5)              ; No first word masking
             MOVE.W     #$FFFF,BLTALWM(a5)              ; No last word masking
             MOVE.W     #$09F0,BLTCON0(a5)              ; USEA, USED. Minterm $F0, D=A
             MOVE.W     #0,BLTCON1(a5)                  ; Data transfer, no fills
             MOVE.W     #30,BLTDMOD(a5)                 ; Skip 30 bytes of the playfield
             MOVE.W     #0,BLTAMOD(a5)                  ; Skip 0 bytes of the storage
             MOVE.W     #128<<6+5,BLTSIZE(a5)           ; 128 lines high, 5 words wide

             RTS


;-----------------------------------------------------------

SinePos:     DC.B       64,0
Sine:        INCLUDE    "Sine256B.i"

Object:      INCBIN     "assets/ChickenLips.raw"
ObjectMask:  INCBIN     "assets/ChickenLipsMask.raw"
