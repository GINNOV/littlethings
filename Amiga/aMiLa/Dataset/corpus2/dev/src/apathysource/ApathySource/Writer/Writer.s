;;; "                 Includes & Defines"
		   Machine   68020
		   Incdir    "!Includes:"
		   Include   "StdLibInc.i"
		   Include   "StdHardInc.i"

		   Include   "Loader.i"
		   Include   "Support.i"
		   Include   "Demo.i"

		   xdef      Writer_PutW
		   xdef      PasteLetter

		   ;Incdir    "!Includes:os3.0/"
		   ;Include   "exec/memory.i"

Writer_ID          Equ       4455

;;;
;;; "                 Letter Defines"
END                Equ       100

A                  Equ       0
B                  Equ       1
C                  Equ       2
D                  Equ       3
E                  Equ       4
F                  Equ       5
G                  Equ       6
H                  Equ       7
I                  Equ       8
J                  Equ       9
K                  Equ       10
L                  Equ       11
M                  Equ       12
N                  Equ       13
O                  Equ       14
P                  Equ       15
Q                  Equ       16
R                  Equ       17
S                  Equ       18
T                  Equ       19
U                  Equ       20
V                  Equ       21
W                  Equ       22
X                  Equ       23
Y                  Equ       24
Z                  Equ       25
N0                 Equ       26
N1                 Equ       27
N2                 Equ       28
N3                 Equ       29
N4                 Equ       30
N5                 Equ       31
N6                 Equ       32
N7                 Equ       33
N8                 Equ       34
N9                 Equ       35
PNK                Equ       36        ;.
UTR                Equ       37        ;!
FRA                Equ       38        ;?
KOL                Equ       39        ;:

;;;

***************************************
*       Exempel/TestProgram...        *
***************************************

		   Section   code,CODE

		   IFND      noexample
;;; "                 Example"
Start:             Jsr       _InitDemo
		   Tst.l     d0
		   Bne       Exit2

PlayMusic:         Bsr       Init
		   Tst.l     d0
		   Bne       Exit

		   ;Move.l    ScreenPtr,a0
		   ;Moveq     #0,d0
		   ;Move.l    #100,d1
		   ;Move.l    #50,d2
		   ;Move.l    #320,d3
		   ;Move.l    #256,d4
		   ;Bsr       PasteWord

Main:              Btst      #6,$bfe001
		   Bne       Main
.waitlop           Btst      #6,$bfe001
		   Beq       .waitlop

		   Bsr       Uninit

Exit:              Bsr       _UninitDemo
Exit2:             Moveq     #0,d0
		   Rts
;;;
		   ENDC

***************************************
*       Subrutiner nedanför....       *
***************************************

Init:
;;; "                 Allocate Screem Memory"
AllocBasePic:      Move.l    #40*256*2,d0
		   Move.l    #Writer_ID,d1
		   Bsr       _AllocChip
		   Move.l    d0,ScreenPtr
		   Beq       InitError
;;;
;;; "                 Init Screen (Ptrs & Copperlists)"
InitScreen:        Lea       BplPtr,a0
		   Move.l    ScreenPtr,d1
		   Moveq     #2-1,d2
		   Move.l    #40*256,d0
		   Bsr       _SetPtrs

		   Lea       SprPtr,a0
		   Move.l    #SpriteDummy,d1
		   Moveq     #7,d2
		   Moveq     #0,d0
		   Bsr       _SetPtrs

		   Lea       CopperList,a0
		   Bsr       _InstallCopper
;;;
;;; "                 Rts"
		   Moveq     #0,d0
		   Rts
InitError:
		   Move.l    #PowerWall_ID,d0
		   Bsr       _FreeMany
		   Moveq     #1,d0
		   Rts
;;;


Uninit:
;;; "                 Free Memory"
FreeMemory:        Move.l    #Writer_ID,d0
		   Bsr       _FreeMany
;;;
		   Rts

;;; "                 PasteWord"
****************************************
* IN: a0 - Pekare till skärmen         *
*     a1 - Pekare till ordet           *
*     d1 - X pos                       *
*     d2 - Y pos                       *
*     d3 - Width                       *
*     d4 - Height                      *
****************************************
Writer_PutW:       ;Move.l    ScreenPtr,a0
		   ;Lea       Word1,a1
		   ;Move.l    #98,d1
		   ;Move.l    #50,d2
		   ;Move.l    #320,d3
		   ;Move.l    #256,d4

		   ;---------------------

		   Movem.l   d0-d7/a0-a6,-(a7)

		   Lea       WordTable,a2

.writelop          Move.b    (a1)+,d7
		   Extb.l    d7
		   Cmp.l     #END,d7
		   Beq       .done

		   Move.l    d7,d0

		   Bsr       PasteLetter

		   Add.l     (a2,d7*4),d1

		   Bra       .writelop

.done              Movem.l   (a7)+,d0-d7/a0-a6

		   Rts
;;;
;;; "                 PasteLetter"
**************************************************
* IN: a0 - ScreenPtr                             *
*     d0 - Number of Letter (0-39)               *
*     d1 - X pos                                 *
*     d2 - Y pos                                 *
*     d3 - Width                                 *
*     d4 - Height                                *
**************************************************
PasteLetter:
		   Movem.l   d0-d7/a0-a6,-(a7)

		   Move.l    a0,a1
		   Lea       Font,a0
		   Mulu.w    #35*4,d0
		   Add.l     d0,a0

		   Move.l    d1,d0               ;dest pos X
		   Move.l    d2,d1               ;dest pos Y

		   Move.l    d3,d6
		   Move.l    d4,d7

		   Move.l    #32,d2              ;size X
		   Move.l    #35,d3              ;size Y
		   Move.l    #$0dfc,d4           ;bltcon 0 mask

		   Movem.l   d0-d7/a0-a6,-(a7)
		   Bsr       _PasteBob
		   Movem.l   (a7)+,d0-d7/a0-a6

		   Lea       4*1440(a0),a0
		   Move.l    d6,d5
		   Lsr.l     #3,d5
		   Mulu.w    d7,d5
		   Add.l     d5,a1

		   Bsr       _PasteBob

		   Movem.l   (a7)+,d0-d7/a0-a6

		   Rts
;;;
;;; "                 _PasteBob"
_PasteBob:
	;a0/a1  :       bob,bitplane
	;d0/d1  :       x/y
	;d2/d3  :       w/h
	;d4     :       bltcon0 mask
	;d6/d7  :       width of x/height of y

	Movem.l d0-d2/a0-a2,-(a7)
	move.l  _GfxBase,a6
	jsr     _LVOWaitBlit(a6)
	Movem.l (a7)+,d0-d2/a0-a2

	Lea.l   Custom,a5

	move.w  d1,d5
	add.w   d3,d5
	tst.w   d5
	bmi     noblit          ;if image isn't visible up

	move.w  d0,d5
	add.w   d2,d5
	tst.w   d5
	bmi     noblit          ;if image isn't visible left

	tst.w   d1
	bpl     noclipyop

	add.w   d1,d3
	neg.w   d1
	ext.l   d1
	muls.w  d2,d1
	asr.l   #3,d1           ;cut ypic upper
	add.l   d1,a0
	move.w  #0,d1


noclipyop

	sub.w   #1,d7
	cmp.w   d7,d1
	bhi     noblit          ;ypos larger than clipsize?
	add.w   #1,d7

	move.w  d1,d5
	add.w   d3,d5
	sub.w   d7,d5
	tst.w   d5
	bmi     noclipy

	sub.w   d5,d3           

noclipy


	tst.w   d0
	bpl     noclipxlf

	move.w  d0,d5
	neg.w   d0
	ext.l   d0
	and.l   #$fff0,d0
	asr.l   #3,d0           ;cut xpic left
	add.l   d0,a0
	swap.w  d4
	move.w  d0,d4
	swap    d4
	asl.l   #3,d0
	sub.w   d0,d2

	move.w  d5,d0           ;try to remove flicker
	and.w   #$f,d0

noclipxlf

	asr.w   #3,d6           ;get xsize in bytes
	mulu.w  d6,d1           ;make a quick and dirty calculation
	add.l   d1,a1           ;of ypos. adjustable sizes!

	move.l  d0,d1
	and.l   #$fff0,d0
	asr.w   #3,d0
	bclr.w  #0,d0
	subq.w  #2,d6
	cmp.w   d6,d0
	bhi     noblit
	addq.w  #2,d6
	move.w  d0,d7
	add.l   d0,a1           ;calculate and set xpos in dest and
	asl.w   #8,d1           ;bltcon0
	asl.w   #4,d1
	or.w    d1,d4
	move.w  d1,a2

	asr.w   #3,d2           ;get xsize in byte-value(from pixelval)

	clr.w   d5

	move.w  d2,d1
	add.w   d7,d1
	sub.w   d6,d1
	tst.w   d1
	bmi     noclipx

	sub.w   d1,d2           
	move.w  d1,d5
noclipx

	swap    d4
	tst.w   d4
	beq     .noaddmod
	
	move.w  d4,d5

.noaddmod
	swap    d4
	move.w  d6,d0
	move.w  d2,d1           ;calculate xmodulo
	sub     d1,d0
	move.w  d0,d6


	asr.w   #1,d2           ;get size in words
	asl.w   #6,d3           ;calculate blit size
	add.w   d2,d3

	move.w  #0,bltcon1(a5)
	move.l  a0,bltapt(a5)
	move.w  d4,bltcon0(a5)
	move.w  d5,bltamod(a5)  ;modulo if clipped
	move.w  d6,bltbmod(a5)  ;same modulo for mask and
	move.w  d6,bltdmod(a5)  ;dest
	move.l  a1,bltdpt(a5)
	move.l  #0,bltcpt(a5)
	move.l  a1,bltbpt(a5)
	move.w  #$ffff,bltafwm(a5)
	move.w  #$ffff,bltalwm(a5)

	tst.w   d5
	beq     .nobltclwm
	lea     bltclwm,a0
	move.w  a2,d0
	lsr.w   #8,d0
	lsr.w   #4,d0
	move.w  (a0,d0.w*2),d0
	move.w  d0,bltalwm(a5)
.nobltclwm

	move.w  d3,bltsize(a5)
noblit
	clr.l   d4

	Rts
;;;

***************************************
*                Data...              *
***************************************

;;; "Variables & Data"
ScreenPtr:         Dc.l      0
;;;
;;; "Paste Bob Data"
bltclwm
	dc.w    %1111111111111110
	dc.w    %1111111111111100
	dc.w    %1111111111111000
	dc.w    %1111111111110000
	dc.w    %1111111111100000
	dc.w    %1111111111000000
	dc.w    %1111111110000000
	dc.w    %1111111100000000
	dc.w    %1111111000000000
	dc.w    %1111110000000000
	dc.w    %1111100000000000
	dc.w    %1111000000000000
	dc.w    %1110000000000000
	dc.w    %1100000000000000
	dc.w    %1000000000000000
	dc.w    %0000000000000000

bltcfwm
	dc.w    %0111111111111111
	dc.w    %0011111111111111
	dc.w    %0001111111111111
	dc.w    %0000111111111111
	dc.w    %0000011111111111
	dc.w    %0000001111111111
	dc.w    %0000000111111111
	dc.w    %0000000011111111
	dc.w    %0000000001111111
	dc.w    %0000000000111111
	dc.w    %0000000000011111
	dc.w    %0000000000001111
	dc.w    %0000000000000111
	dc.w    %0000000000000011
	dc.w    %0000000000000001
	dc.w    %0000000000000000

;scrollmask
	dc.w    %0000
	dc.w    %1000
	dc.w    %0100
	dc.w    %1100
	dc.w    %0010
	dc.w    %1010
	dc.w    %0110
	dc.w    %1110
	dc.w    %0001
	dc.w    %1001
	dc.w    %0101
	dc.w    %1101
	dc.w    %0011
	dc.w    %1011
	dc.w    %0111
	Dc.w    %1111
;;;
;;; "Word Table"
_L                 Equ       16
_S1                Equ       6
_S2                Equ       9

WordTable:         Dc.l      _L,_L,_L,_L,_L,_L,_L,_L,_S1,_L,_L,_L,_L,_L,_L
		   Dc.l      _L,_L,_L,_L,_L,_L,_L,_L,_L,_L,_L,_L,_S2,_L,_L
		   Dc.l      _L,_L,_L,_L,_L,_L,_L,_S1,_L,_L
;;;

		   Section   chipdata,DATA_C
;;; "Copperlist"
CopperList:        Dc.w      $008e,$2c81     ; DIWSTRT
		   Dc.w      $0090,$2bc1     ; DIWSTOP
		   Dc.w      $0092,$0038     ; DDFSTRT
		   Dc.w      $0094,$00d0     ; DDFSTOP
		   Dc.w      $0100,$2201     ; BPLCON0
		   Dc.w      $0102,$0000     ; BPLCON1
		   Dc.w      $0104,$0000     ; BPLCON2
		   Dc.w      $0106,$0020     ; BPLCON3 ($0020 = copborder)
		   Dc.w      $0108,-8        ; BPLMOD1
		   Dc.w      $010a,-8        ; BPLMOD2
		   Dc.w      $01fc,$0003     ; FETCHMODE

BplPtr:            Dc.w      $00e0,$0000     ; BPL1PTH
		   Dc.w      $00e2,$0000     ; BPL1PTL
		   Dc.w      $00e4,$0000     ; BPL1PTL
		   Dc.w      $00e6,$0000     ; BPL1PTL

SprPtr:
SprNum             Set       $0120
		   REPT      16
		   Dc.w      SprNum,$0000    ; SPRxPT
SprNum             Set       SprNum+2
		   ENDR

		   Dc.w      $0106,$0020
		   Dc.w      $0180,$0000
		   Dc.w      $0182,$0777
		   Dc.w      $0184,$0bbb
		   Dc.w      $0186,$0fff

		   Dc.w      $ffff,$fffe     ; End of list
;;;
;;; "Font"
		   Cnop      0,8
Font:              Incbin    "!intro:writer/font2.raw"
;;;
