		   Machine   68020

;;; "                 Includes"
		   Incdir    "!Includes:"
		   Include   "StdLibInc.i"
		   Include   "StdHardInc.i"
		   Include   "Screens.i"
		   Include   "Loader.i"
		   Include   "Support.i"

		   ;Incdir    "!intro:"
		   ;Include   "intromain.i"

		   xref      Writer_PutW
		   xref      PasteLetter

		   xref      _InitFade
		   xref      _DoFade

		   xref      P61_WaitCRow2
		   xref      P61_WaitCRow
		   xref      P61_WaitPos

		   xref      _SetColByte
;;;
;;; "                 Defines"
		   xdef      Intro_Init
		   xdef      Intro_Main
		   xdef      Intro_Remove

		   xdef      Apathy
		   xdef      WriteCList2
		   xdef      Wr1BplPtr_2
		   xdef      Wr1SprPtr2

		   ;----------------------

Intro_ID           Equ       42
FadeBuffSize       Equ       8*1024
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
Start:             Bsr       _InitDemo
		   Tst.l     d0
		   Bne       Exit2

PlayMusic:         Bsr       _PlayMusic
		   Tst.l     d0
		   Bne       Exit

		   Move.w    #0,P61_Play

		   Bsr       Intro_Init
		   Tst.l     d0
		   Bne       StopMusic

		   Bsr       Intro_Main

Main:              Btst      #6,$bfe001
		   Bne       Main
.waitlop           Btst      #6,$bfe001
		   Beq       .waitlop

		   Bsr       Intro_Remove

StopMusic:         Bsr       _StopMusic
Exit:              Bsr       _UninitDemo
Exit2:             Moveq     #0,d0
		   Rts
;;;
		   ENDC

***************************************
*     Intro-Subrutiner nedanför....   *
***************************************

Intro_Init:
;;; "                 Alloc Pics"
AllocPic1:         Move.l    #40*256*4,d0
		   Move.l    #Intro_ID,d1
		   Bsr       _AllocChip
		   Move.l    d0,Wr1Pic1Ptr
		   Beq       InitError

		   Move.l    #40*256*4,d0
		   Move.l    #Intro_ID,d1
		   Bsr       _AllocChip
		   Move.l    d0,Wr1Pic2Ptr
		   Beq       InitError

		   Move.l    #40*256*4,d0
		   Move.l    #Intro_ID,d1
		   Bsr       _AllocChip
		   Move.l    d0,Wr1Pic3Ptr
		   Beq       InitError

		   ;-------------------------

		   Move.l    #40*256*4,d0
		   Move.l    #Intro_ID,d1
		   Bsr       _AllocChip
		   Move.l    d0,Wr1Pic4Ptr
		   Beq       InitError

		   Move.l    #40*256*4,d0
		   Move.l    #Intro_ID,d1
		   Bsr       _AllocChip
		   Move.l    d0,Wr1Pic5Ptr
		   Beq       InitError

		   Move.l    #40*256*4,d0
		   Move.l    #Intro_ID,d1
		   Bsr       _AllocChip
		   Move.l    d0,Wr1Pic6Ptr
		   Beq       InitError

;;;
;;; "                 Init Pics"
		   Lea       Henke,a0
		   Move.l    Wr1Pic1Ptr,a1
		   Bsr       InitPic

		   Lea       Jeppe,a0
		   Move.l    Wr1Pic2Ptr,a1
		   Add.l     #40*128+20,a1
		   Bsr       InitPic

		   Lea       Alex,a0
		   Move.l    Wr1Pic3Ptr,a1
		   Add.l     #20,a1
		   Bsr       InitPic

		   Lea       Magnus,a0
		   Move.l    Wr1Pic4Ptr,a1
		   Add.l     #40*128,a1
		   Bsr       InitPic

		   Lea       Johnny,a0
		   Move.l    Wr1Pic5Ptr,a1
		   Bsr       InitPic

		   Lea       Oliver,a0
		   Move.l    Wr1Pic6Ptr,a1
		   Add.l     #40*128+20,a1
		   Bsr       InitPic
;;;
;;; "                 Open Writer Screen"
AllocWrite1Pic:    Move.l    #40*256*2,d0
		   Move.l    #Intro_ID,d1
		   Bsr       _AllocChip
		   Move.l    d0,WriteScr1Ptr
		   Beq       InitError

		   ;--------------------------

		   Lea       Wr1BplPtr,a0
		   Move.l    WriteScr1Ptr,d1
		   Moveq     #2-1,d2
		   Move.l    #40*256,d0
		   Bsr       _SetPtrs

		   Lea       Wr1BplPtr,a0
		   Lea       16(a0),a0
		   Move.l    Wr1Pic1Ptr,d1
		   Add.l     #40*128,d1
		   Moveq     #4-1,d2
		   Move.l    #40*256,d0
		   Bsr       _SetPtrs

		   Lea       Wr1BplPtr2,a0
		   Move.l    Wr1Pic2Ptr,d1
		   ;Add.l     #40*128,d1
		   Moveq     #4-1,d2
		   Move.l    #40*256,d0
		   Bsr       _SetPtrs

		   Lea       Wr1SprPtr,a0
		   Move.l    #SpriteDummy,d1
		   Moveq     #7,d2
		   Moveq     #0,d0
		   Bsr       _SetPtrs
;;;
;;; "                 Alloc Fade Buffer"
AllocFadeBuff:     Move.l    #8*1024,d0
		   Move.l    #Intro_ID,d1
		   Bsr       _AllocPublic
		   Move.l    d0,FadeBuffPtr
		   Beq       InitError
;;;
;;; "                 Rts"
		   Moveq     #0,d0
		   Rts
InitError:
		   Move.l    #Intro_ID,d0
		   Bsr       _FreeMany
		   Moveq     #1,d0
		   Rts
;;;

Intro_Main:
;;; "                 Show Screen"
		   Bsr       _Sync

		   Lea       WriteCList1,a0
		   Bsr       _InstallCopper
;;;
;;; "                 Init Colours"
		   Lea       Custom,a5
		   Move.w    #$0000,$106(a5)
		   Move.w    #$0000,$180(a5)
		   Move.w    #$0777,$182(a5)
		   Move.w    #$0bbb,$184(a5)
		   Move.w    #$0fff,$186(a5)
;;;

		   ;Move.w    #1,P61_Play

		   ;IFD       kulig
;;; "                 Scroll First"
		   Bsr       InitCols

		   Bsr       InitFade1

		   Move.l    Wr1Pic1Ptr,d0
		   Move.l    Wr1Pic2Ptr,d1
		   Bsr       ScrollPics
		   Tst.l     d0
		   Bne       Break

		   ;IFND      noexample
		   Move.w    #1,P61_Play
		   ;ENDC

		   Bsr       Fade
		   Tst.l     d0
		   Bne       Break
;;;
;;; "                 RayLight + Chip"
		   Bsr       InitFade3

		   Move.w    #28,d0
		   Bsr       P61_WaitCRow
		   Tst.l     d0
		   Bne       Break

		   Lea       Wr1Word1,a0
		   Move.l    #180,d0
		   Move.l    #25,d1
		   Bsr       Wr1_Write

		   Bsr       Fade
		   Tst.l     d0
		   Bne       Break

		   Bsr       InitFade3

		   Move.w    #32,d0
		   Bsr       P61_WaitCRow
		   Tst.l     d0
		   Bne       Break

		   Lea       Wr1Word2,a0
		   Move.l    #85,d0
		   Move.l    #195,d1
		   Bsr       Wr1_Write

		   Bsr       Fade
		   Tst.l     d0
		   Bne       Break

		   Bsr       InitFade2

		   Move.w    #52,d0
		   Bsr       P61_WaitCRow
		   Tst.l     d0
		   Bne       Break

		   Bsr       Fade
		   Tst.l     d0
		   Bne       Break

		   Move.w    #58,d0
		   Bsr       P61_WaitCRow
		   Tst.l     d0
		   Bne       Break

		   Bsr       Wr1_ClrScr
;;;

;;; "                 Scroll Second"
		   Bsr       InitCols
		   Bsr       InitFade1

		   Move.l    Wr1Pic3Ptr,d0
		   Move.l    Wr1Pic4Ptr,d1
		   Bsr       ScrollPics
		   Tst.l     d0
		   Bne       Break

		   Bsr       Fade
		   Tst.l     d0
		   Bne       Break
;;;
;;; "                 Wasp + Mad Druid"
		   Bsr       InitFade3

		   Move.w    #28,d0
		   Bsr       P61_WaitCRow
		   Tst.l     d0
		   Bne       Break

		   Lea       Wr1Word3,a0
		   Move.l    #80,d0
		   Move.l    #25,d1
		   Bsr       Wr1_Write

		   Bsr       Fade
		   Tst.l     d0
		   Bne       Break

		   Bsr       InitFade3

		   Move.w    #32,d0
		   Bsr       P61_WaitCRow
		   Tst.l     d0
		   Bne       Break

		   Lea       Wr1Word4,a0
		   Move.l    #170,d0
		   Move.l    #195,d1
		   Bsr       Wr1_Write

		   Lea       Wr1Word42,a0
		   Move.l    #170+55,d0
		   Move.l    #195,d1
		   Bsr       Wr1_Write

		   Bsr       Fade
		   Tst.l     d0
		   Bne       Break

		   Bsr       InitFade2

		   Move.w    #52,d0
		   Bsr       P61_WaitCRow
		   Tst.l     d0
		   Bne       Break

		   Bsr       Fade
		   Tst.l     d0
		   Bne       Break

		   Move.w    #58,d0
		   Bsr       P61_WaitCRow
		   Tst.l     d0
		   Bne       Break

		   Bsr       Wr1_ClrScr
;;;

;;; "                 Scroll Third"
		   Bsr       InitCols
		   Bsr       InitFade1

		   Move.l    Wr1Pic5Ptr,d0
		   Move.l    Wr1Pic6Ptr,d1
		   Bsr       ScrollPics
		   Tst.l     d0
		   Bne       Break

		   Bsr       Fade
		   Tst.l     d0
		   Bne       Break
;;;
;;; "                 GunRider + Oliver"
		   Bsr       InitFade3

		   Move.w    #28,d0
		   Bsr       P61_WaitCRow
		   Tst.l     d0
		   Bne       Break

		   Lea       Wr1Word5,a0
		   Move.l    #170,d0
		   Move.l    #25,d1
		   Bsr       Wr1_Write

		   Bsr       Fade
		   Tst.l     d0
		   Bne       Break

		   Bsr       InitFade3

		   Move.w    #32,d0
		   Bsr       P61_WaitCRow
		   Tst.l     d0
		   Bne       Break

		   Lea       Wr1Word6,a0
		   Move.l    #60,d0
		   Move.l    #195,d1
		   Bsr       Wr1_Write

		   Bsr       Fade
		   Tst.l     d0
		   Bne       Break

		   Bsr       InitFade2

		   Move.w    #52,d0
		   Bsr       P61_WaitCRow
		   Tst.l     d0
		   Bne       Break

		   Bsr       Fade
		   Tst.l     d0
		   Bne       Break

		   Move.w    #58,d0
		   Bsr       P61_WaitCRow
		   Tst.l     d0
		   Bne       Break

		   Bsr       Wr1_ClrScr
;;;

;;; "                 Blank Pics"
		   Lea       Wr1BplPtr,a0
		   Lea       16(a0),a0
		   Move.l    Wr1Pic1Ptr,d1
		   Add.l     #40*128,d1
		   Moveq     #4-1,d2
		   Move.l    #40*256,d0
		   Bsr       _SetPtrs

		   Lea       Wr1BplPtr2,a0
		   Move.l    Wr1Pic1Ptr,d1
		   Add.l     #40*128,d1
		   Moveq     #4-1,d2
		   Move.l    #40*256,d0
		   Bsr       _SetPtrs
;;;
;;; "                 PowerLine Proudly Presents"
		   Bsr       InitFade1

		   Move.w    #0,d0
		   Bsr       P61_WaitCRow2
		   Tst.l     d0
		   Bne       Break

		   Lea       Wr1Word7a,a0
		   Move.l    #88,d0
		   Move.l    #20,d1
		   Bsr       Wr1_Write

		   Bsr       Fade
		   Tst.l     d0
		   Bne       Break

		   Bsr       InitFade3

		   Move.w    #28,d0
		   Bsr       P61_WaitCRow
		   Tst.l     d0
		   Bne       Break

		   Lea       Wr1Word7,a0
		   Move.l    #95,d0
		   Move.l    #100,d1
		   Bsr       Wr1_Write

		   Bsr       Fade
		   Tst.l     d0
		   Bne       Break

		   Bsr       InitFade3

		   Move.w    #32,d0
		   Bsr       P61_WaitCRow
		   Tst.l     d0
		   Bne       Break

		   Lea       Wr1Word8,a0
		   Move.l    #89,d0
		   Move.l    #170,d1
		   Bsr       Wr1_Write

		   Bsr       Fade
		   Tst.l     d0
		   Bne       Break

		   Move.w    #0,d0
		   Bsr       P61_WaitCRow2
		   Tst.l     d0
		   Bne       Break

		   Bsr       Wr1_ClrScr
;;;
		   ;ENDC

;;; "                 Apathy Screen"
		   Bsr       InitFade6

		   Lea       Wr1BplPtr_2,a0
		   Move.l    #Apathy,d1
		   Moveq     #1-1,d2
		   Move.l    #80*256,d0
		   Bsr       _SetPtrs

		   Lea       Wr1SprPtr2,a0
		   Move.l    #SpriteDummy,d1
		   Moveq     #7,d2
		   Moveq     #0,d0
		   Bsr       _SetPtrs

		   Lea       WriteCList2,a0
		   Bsr       _InstallCopper

		   Bsr       Fade
		   Tst.l     d0
		   Bne       Break

		   Bsr       InitFade7

		   Move.w    #32,d0
		   Bsr       P61_WaitCRow
		   Tst.l     d0
		   Bne       Break

		   Bsr       Fade
		   Tst.l     d0
		   Bne       Break
;;;

		   Move.w    #0,d0
		   Bsr       P61_WaitCRow2

		   Lea       WriteCList1,a0
		   Bsr       _InstallCopper

;;; "                 PasteWord"
		   Lea       Wr1BplPtr,a0
		   Move.l    WriteScr1Ptr,d1
		   Moveq     #2-1,d2
		   Move.l    #40*256,d0
		   Bsr       _SetPtrs

		   Lea       Word1,a1

.wordlop

.again             Btst      #2,$dff016
		   Beq       Break

		   Move.w    Sync_Old,d0
		   Move.w    P61_CRow,d1
		   Move.w    d1,Sync_Old
		   Cmp.w     d0,d1
		   Beq       .again
		   And.w     #1,d1
		   Bne       .again

		   Move.b    (a1)+,d1
		   And.l     #255,d1

		   Cmp.l     #253,d1
		   Beq       .again
		   Cmp.l     #254,d1
		   Bne       .nocls

		   Movem.l   d0-a6,-(a7)
		   Bsr       InitFade5
		   Bsr       Fade
		   Tst.l     d0
		   Bne       Break2

		   Movem.l   (a7)+,d0-a6
		   Bsr       Wr1_ClrScr
		   Bra       .again

.nocls             Cmp.l     #255,d1
		   Beq       .done2

		   Move.b    (a1)+,d2
		   And.l     #255,d2

		   Move.l    #320,d3
		   Move.l    #256,d4

		   Move.l    WriteScr1Ptr,a0
		   Lea       WordTable,a2

.writelop          Move.b    (a1)+,d7
		   Extb.l    d7
		   Cmp.l     #END,d7
		   Beq       .done

		   Move.l    d7,d0

		   Lea       Custom,a5
		   Move.w    #$0000,$106(a5)
		   Move.w    #$0000,$180(a5)
		   Move.w    #$0777,$182(a5)
		   Move.w    #$0bbb,$184(a5)
		   Move.w    #$0fff,$186(a5)

		   Bsr       PasteLetter

		   Add.l     (a2,d7*4),d1

		   Bra       .writelop

.done
		   Bra       .wordlop
.done2

;;;

		   Moveq     #0,d0
		   Rts

Break:             Moveq     #1,d0
		   Rts

Break2:            Movem.l   (a7)+,d0-a6
		   Moveq     #1,d0
		   Rts


Intro_Remove:
;;; "                 Free Memory"
FreeMemory:        Move.l    #Intro_ID,d0
		   Bsr       _FreeMany
;;;
		   Rts


***************************************
*             Mera Subs...            *
***************************************
;;; "Wr1_Write"
********************************
* IN: a0 - Pekare till ordet   *
*     d0 - X pos               *
*     d1 - Y pos               *
********************************
Wr1_Write:         Movem.l   d0-d4/a0,-(a7)

		   Move.l    a0,a1
		   Move.l    WriteScr1Ptr,a0
		   Move.l    d1,d2
		   Move.l    d0,d1
		   Move.l    #320,d3
		   Move.l    #256,d4
		   Bsr       Writer_PutW

		   Movem.l   (a7)+,d0-d4/a0
		   Rts
;;;
;;; "Wr1_ClrScr"
Wr1_ClrScr:        Movem.l   a0/d0,-(a7)

		   Move.l    WriteScr1Ptr,a0
		   Move.l    #320/8*256*2/16-1,d0

.lop               Clr.l     (a0)+
		   Clr.l     (a0)+
		   Clr.l     (a0)+
		   Clr.l     (a0)+
		   Dbra      d0,.lop

		   Movem.l   (a7)+,a0/d0
		   Rts
;;;
;;; "InitPic"
****************************************
*IN: a0 - Pic                          *
*    a1 - Dest Screen                  *
****************************************
InitPic:           Move.l    a0,a2
		   Move.l    a1,a0
		   Move.l    #4-1,d4
.plane
		   Move.l    a2,a1

		   Move.l    #64-1,d7
.ylop

		   Move.l    #20-1,d6
.xlop              Moveq     #0,d0

		   Cmp.l     #3,d4
		   Bne       .next1

		   Move.b    (a1)+,d0
		   Move.b    d0,d1
		   And.w     #%10000,d0
		   Lsr.l     #4,d0
		   And.w     #%1,d1

		   Move.b    (a1)+,d2
		   Move.b    d2,d3
		   And.w     #%10000,d2
		   Lsr.l     #4,d2
		   And.w     #%1,d3
		   Bra       .done

.next1             Cmp.l     #2,d4
		   Bne       .next2

		   Move.b    (a1)+,d0
		   Move.b    d0,d1
		   And.w     #%100000,d0
		   Lsr.l     #5,d0
		   And.w     #%10,d1
		   Lsr.l     #1,d1

		   Move.b    (a1)+,d2
		   Move.b    d2,d3
		   And.w     #%100000,d2
		   Lsr.l     #5,d2
		   And.w     #%10,d3
		   Lsr.l     #1,d3
		   Bra       .done

.next2             Cmp.l     #1,d4
		   Bne       .next3

		   Move.b    (a1)+,d0
		   Move.b    d0,d1
		   And.w     #%1000000,d0
		   Lsr.l     #6,d0
		   And.w     #%100,d1
		   Lsr.l     #2,d1

		   Move.b    (a1)+,d2
		   Move.b    d2,d3
		   And.w     #%1000000,d2
		   Lsr.l     #6,d2
		   And.w     #%100,d3
		   Lsr.l     #2,d3

		   Bra       .done

.next3             Cmp.l     #0,d4
		   Bne       .done

		   Move.b    (a1)+,d0
		   Move.b    d0,d1
		   And.w     #%10000000,d0
		   Lsr.l     #7,d0
		   And.w     #%1000,d1
		   Lsr.l     #3,d1

		   Move.b    (a1)+,d2
		   Move.b    d2,d3
		   And.w     #%10000000,d2
		   Lsr.l     #7,d2
		   And.w     #%1000,d3
		   Lsr.l     #3,d3
.done

		   Lsl.l     #2,d0
		   Or.b      d1,d0
		   Lsl.l     #2,d0
		   Or.b      d2,d0
		   Lsl.l     #2,d0
		   Or.b      d3,d0

		   Move.b    d0,d1
		   Lsl.l     #1,d1
		   Or.b      d1,d0

		   Move.b    d0,(a0)+

		   Dbra      d6,.xlop

		   Add.l     #20,a0

		   Move.l    -40(a0),(a0)+
		   Move.l    -40(a0),(a0)+
		   Move.l    -40(a0),(a0)+
		   Move.l    -40(a0),(a0)+
		   Move.l    -40(a0),(a0)+

		   Add.l     #20,a0

		   Dbra      d7,.ylop

		   Add.l     #40*128,a0

		   Dbra      d4,.plane

		   Rts
;;;
;;; "ScrollPics"
***************************************
* IN: d0 - Pic1                       *
*     d1 - Pic2                       *
***************************************
ScrollPics:        Move.l    d0,d3
		   Move.l    d1,d4
		   Add.l     #40*128,d4

		   Move.l    #128-1,d7
		   Moveq     #2,d5
.lop               Bsr       _Sync

		   Btst      #2,$dff016
		   Beq       .break

		   Lea       Wr1BplPtr,a0
		   Lea       16(a0),a0
		   Move.l    d7,d1
		   Muls.w    #40,d1
		   Add.l     d3,d1
		   Moveq     #4-1,d2
		   Move.l    #40*256,d0
		   Bsr       _SetPtrs

		   Lea       Wr1BplPtr2,a0
		   Move.l    d7,d2
		   Muls.w    #40,d2
		   Move.l    d4,d1
		   Sub.l     d2,d1
		   Moveq     #4-1,d2
		   Move.l    #40*256,d0
		   Bsr       _SetPtrs

		   Move.l    d5,d1
		   Asr.l     #1,d1
		   Sub.l     d1,d7
		   Add.l     #1,d5

		   Tst.l     d7
		   Bgt       .lop

		   Lea       Wr1BplPtr,a0
		   Lea       16(a0),a0
		   Move.l    d3,d1
		   Moveq     #4-1,d2
		   Move.l    #40*256,d0
		   Bsr       _SetPtrs

		   Lea       Wr1BplPtr2,a0
		   Move.l    d4,d1
		   Moveq     #4-1,d2
		   Move.l    #40*256,d0
		   Bsr       _SetPtrs

		   Moveq     #0,d0
		   Rts

.break             Moveq     #1,d0
		   Rts
;;;
;;; "InitFade1"
InitFade1:         Move.l    #64,d0
		   Move.l    #16,d1
		   Move.l    #0,d2
		   Move.l    #0,d3
		   Lea       Pal3,a0
		   Lea       Pal5,a1
		   Move.l    FadeBuffPtr,a2
		   Bsr       _InitFade
		   Rts
;;;
;;; "InitFade2"
InitFade2:         Move.l    #4,d0
		   Move.l    #16,d1
		   Move.l    #0,d2
		   Move.l    #0,d3
		   Lea       Pal1,a0
		   Lea       Pal2,a1
		   Move.l    FadeBuffPtr,a2
		   Bsr       _InitFade
		   Rts
;;;
;;; "InitFade3"
InitFade3:         Move.l    #64,d0
		   Move.l    #16,d1
		   Move.l    #0,d2
		   Move.l    #0,d3
		   Lea       Pal4,a0
		   Lea       Pal1,a1
		   Move.l    FadeBuffPtr,a2
		   Bsr       _InitFade
		   Rts
;;;
;;; "InitFade4"
InitFade4:         Move.l    #4,d0
		   Move.l    #64,d1
		   Move.l    #0,d2
		   Move.l    #0,d3
		   Lea       Pal1,a0
		   Lea       Pal2,a1
		   Move.l    FadeBuffPtr,a2
		   Bsr       _InitFade
		   Rts
;;;
;;; "InitFade5"
InitFade5:         Move.l    #64,d0
		   Move.l    #4,d1
		   Move.l    #0,d2
		   Move.l    #0,d3
		   Lea       Pal1,a0
		   Lea       Pal2,a1
		   Move.l    FadeBuffPtr,a2
		   Bsr       _InitFade
		   Rts
;;;
;;; "InitFade6"
InitFade6:         Move.l    #2,d0
		   Move.l    #16,d1
		   Move.l    #0,d2
		   Move.l    #0,d3
		   Lea       Pal3,a0
		   Lea       Pal6,a1
		   Move.l    FadeBuffPtr,a2
		   Bsr       _InitFade
		   Rts
;;;
;;; "InitFade7"
InitFade7:         Move.l    #2,d0
		   Move.l    #64,d1
		   Move.l    #0,d2
		   Move.l    #0,d3
		   Lea       Pal6,a0
		   Lea       Pal2,a1
		   Move.l    FadeBuffPtr,a2
		   Bsr       _InitFade
		   Rts
;;;

;;; "Fade"
Fade:
.fade              Bsr       _Sync

		   Btst      #2,$dff016
		   Beq       .break

		   Move.l    FadeBuffPtr,a0
		   Bsr       _DoFade
		   Tst.l     d0
		   Beq       .fade

		   Moveq     #0,d0
		   Rts

.break             Moveq     #1,d0
		   Rts
;;;

;;; "Init Colours (pics)"
InitCols:          Moveq     #0,d0
		   Moveq     #0,d5
		   Moveq     #16-1,d7

.collop1           Move.l    d5,d1
		   Move.l    d5,d2
		   Move.l    d5,d3
		   Bsr       _SetColByte
		   Addq.l    #4,d0
		   Add.l     #16,d5
		   Dbra      d7,.collop1
		   Rts
;;;

***************************************
*             Intro Data...           *
***************************************
;;; "Variables / Data"
FadeBuffPtr:       Dc.l      0
Wr1FadeBuffPtr:    Dc.l      0
WriteScr1Ptr:      Dc.l      0

Wr1Pic1Ptr:        Dc.l      0
Wr1Pic2Ptr:        Dc.l      0
Wr1Pic3Ptr:        Dc.l      0
Wr1Pic4Ptr:        Dc.l      0
Wr1Pic5Ptr:        Dc.l      0
Wr1Pic6Ptr:        Dc.l      0

Sync_Old:          Dc.l      0

Wr1Word1:          Dc.b      R,A,Y,L,I,G,H,T,END
Wr1Word2:          Dc.b      C,H,I,P,END
Wr1Word3:          Dc.b      W,A,S,P,END
Wr1Word4:          Dc.b      M,A,D,END
Wr1Word42:         Dc.b      D,R,U,I,D,END
Wr1Word5:          Dc.b      G,U,N,R,I,D,E,R,END
Wr1Word6:          Dc.b      O,L,I,V,E,R,END

Wr1Word7a:         Dc.b      P,O,W,E,R,L,I,N,E,END
Wr1Word7:          Dc.b      P,R,O,U,D,L,Y,END
Wr1Word8:          Dc.b      P,R,E,S,E,N,T,S,END

Word1:             Dc.b      120,20,Y,O,U,END
		   Dc.b      190,70,W,I,L,L,END
		   Dc.b      160,130,A,L,L,END
		   Dc.b      253
		   Dc.b      140,200,D,I,E,UTR,END
		   Dc.b      253,253
		   Dc.b      254

		   Dc.b      150,30,Y,O,U,END
		   Dc.b      253
		   Dc.b      100,80,C,A,N,N,O,T,END
		   Dc.b      190,130,E,S,C,A,P,E,UTR,END
		   Dc.b      253,253
		   Dc.b      254

		   Dc.b      170,30,B,U,T,END
		   Dc.b      100,80,B,E,F,O,R,E,END
		   Dc.b      140,140,Y,O,U,END
		   Dc.b      253
		   Dc.b      200,210,D,I,E,END
		   Dc.b      253,253
		   Dc.b      254

		   Dc.b      180,20,W,E,END
		   Dc.b      253
		   Dc.b      80,80,W,I,L,L,END
		   Dc.b      150,140,S,H,O,W,END
		   Dc.b      253
		   Dc.b      210,210,Y,O,U,END
		   Dc.b      253,253
		   Dc.b      254

		   Dc.b      100,20,O,U,R,END
		   Dc.b      190,90,L,I,F,E,UTR,END
		   Dc.b      253,253
		   Dc.b      254

		   Dc.b      150,150,O,U,R,END
		   Dc.b      120,210,R,E,V,O,L,U,T,I,O,N,UTR,END
		   Dc.b      253,253
		   Dc.b      254

		   Dc.b      90,30,W,H,E,N,END
		   Dc.b      40,90,T,H,E,R,E,END
		   Dc.b      253
		   Dc.b      80,160,I,S,END
		   Dc.b      0,210,S,I,L,E,N,C,E,END
		   Dc.b      253,253
		   Dc.b      254

		   Dc.b      30,20,W,E,END
		   Dc.b      190,80,W,I,L,L,END
		   Dc.b      253
		   Dc.b      60,160,D,I,E,UTR,END
		   Dc.b      253,253
		   Dc.b      254

		   Dc.b      110,50,S,O,END
		   Dc.b      170,160,S,C,R,E,A,M,END
		   Dc.b      253,253
		   Dc.b      254

		   Dc.b      170,20,O,U,R,END
		   Dc.b      130,90,N,A,M,E,END
		   Dc.b      100,160,O,U,T,END
		   Dc.b      253
		   Dc.b      190,200,L,O,U,D,END
		   Dc.b      253,253
		   Dc.b      254

		   Dc.b      190,40,B,E,C,A,U,S,E,END
		   Dc.b      253
		   Dc.b      120,100,Y,O,U,END
		   Dc.b      160,150,W,O,N,T,END
		   Dc.b      130,210,S,E,E,END
		   Dc.b      253,253
		   Dc.b      254

		   Dc.b      120,30,A,N,Y,T,H,I,N,G,END
		   Dc.b      70,80,L,I,K,E,END
		   Dc.b      253
		   Dc.b      190,170,I,T,END
		   Dc.b      140,210,A,G,A,I,N,UTR,END
		   Dc.b      253,253
		   Dc.b      254

		   Dc.b      30,0,A,END
		   Dc.b      100,40,N2,X,N2,END
		   Dc.b      253
		   Dc.b      100,90,Z,O,O,M,R,O,T,A,T,E,END
		   Dc.b      253
		   Dc.b      60,150,N5,N0,F,P,S,UTR,END
		   Dc.b      253,253
		   Dc.b      254

		   Dc.b      130,80,W,I,T,H,END
		   Dc.b      90,170,F,A,S,T,M,E,M,END
		   Dc.b      253
		   Dc.b      254

		   Dc.b      160,20,N,O,END
		   Dc.b      100,80,B,L,I,T,T,E,R,S,C,R,E,E,N,UTR,END
		   Dc.b      253,253
		   Dc.b      254

		   Dc.b      190,40,N,O,END
		   Dc.b      100,120,N0,N3,N0,END
		   Dc.b      253
		   Dc.b      40,210,N,E,E,D,E,D,UTR,END
		   Dc.b      253,253
		   Dc.b      254

		   Dc.b      30,30,T,H,E,END
		   Dc.b      253
		   Dc.b      180,80,R,E,A,L,L,Y,END
		   Dc.b      70,160,F,A,S,T,E,S,T,END
		   Dc.b      253,253
		   Dc.b      254

		   Dc.b      160,60,E,V,E,R,END
		   Dc.b      30,170,S,E,E,N,UTR,END
		   Dc.b      253,253
		   Dc.b      254

		   Dc.b      255
		   Even

Pal1:              Dc.l      $000000,$777777,$bbbbbb,$ffffff
		   Dc.l      $001111,0,0,0
		   Dc.l      $002222,0,0,0
		   Dc.l      $003333,0,0,0

		   Dc.l      $004444,0,0,0
		   Dc.l      $005555,0,0,0
		   Dc.l      $006666,0,0,0
		   Dc.l      $007777,0,0,0

		   Dc.l      $008888,0,0,0
		   Dc.l      $009999,0,0,0
		   Dc.l      $00aaaa,0,0,0
		   Dc.l      $00bbbb,0,0,0

		   Dc.l      $00cccc,0,0,0
		   Dc.l      $00dddd,0,0,0
		   Dc.l      $00eeee,0,0,0
		   Dc.l      $00ffff,0,0,0

Pal2:
		   REPT      16
		   Dc.l      0,0,0,0
		   ENDR

Pal3:
		   REPT      16
		   Dc.l      $ffffff,$ffffff,$ffffff,$ffffff
		   ENDR

Pal4:              Dc.l      $444444,$bbbbbb,$ffffff,$ffffff
		   Dc.l      $555555,0,0,0
		   Dc.l      $666666,0,0,0
		   Dc.l      $777777,0,0,0

		   Dc.l      $888888,0,0,0
		   Dc.l      $999999,0,0,0
		   Dc.l      $aaaaaa,0,0,0
		   Dc.l      $bbbbbb,0,0,0

		   Dc.l      $cccccc,0,0,0
		   Dc.l      $dddddd,0,0,0
		   Dc.l      $eeeeee,0,0,0
		   Dc.l      $ffffff,0,0,0

		   Dc.l      $ffffff,0,0,0
		   Dc.l      $ffffff,0,0,0
		   Dc.l      $ffffff,0,0,0
		   Dc.l      $ffffff,0,0,0


Pal5:              Dc.l      $000000,$777777,$bbbbbb,$ffffff
		   Dc.l      $111111,0,0,0
		   Dc.l      $222222,0,0,0
		   Dc.l      $333333,0,0,0

		   Dc.l      $444444,0,0,0
		   Dc.l      $555555,0,0,0
		   Dc.l      $666666,0,0,0
		   Dc.l      $777777,0,0,0

		   Dc.l      $888888,0,0,0
		   Dc.l      $999999,0,0,0
		   Dc.l      $aaaaaa,0,0,0
		   Dc.l      $bbbbbb,0,0,0

		   Dc.l      $cccccc,0,0,0
		   Dc.l      $dddddd,0,0,0
		   Dc.l      $eeeeee,0,0,0
		   Dc.l      $ffffff,0,0,0

Pal6:              Dc.l      $0,$ff4433

;;;
;;; "Word Table"
_L                 Equ       16
_S1                Equ       6
_S2                Equ       9

WordTable:         Dc.l      _L,_L,_L,_L,_L,_L,_L,_L,_S1,_L,_L,_L,_L,_L,_L
		   Dc.l      _L,_L,_L,_L,_L,_L,_L,_L,_L,_L,_L,_L,_S2,_L,_L
		   Dc.l      _L,_L,_L,_L,_L,_L,_L,_S1,_L,_L
;;;

		   Section   data,DATA
;;; "Pics"
Henke:             Incbin    "!intro:intro/henke5.4bit"
Jeppe:             Incbin    "!intro:intro/jeppe1.4bit"
Alex:              Incbin    "!intro:intro/alex1.4bit"
Magnus:            Incbin    "!intro:intro/magnus4.4bit"
Johnny:            Incbin    "!intro:intro/johnny4.4bit"
Oliver:            Incbin    "!intro:intro/dog1.4bit"
;;;
		   Section   chipdata,DATA_C
;;; "Writer CopperList 1"
WriteCList1:       Dc.w      $008e,$2c81     ; DIWSTRT
		   Dc.w      $0090,$2bc1     ; DIWSTOP
		   Dc.w      $0092,$0038     ; DDFSTRT
		   Dc.w      $0094,$00d0     ; DDFSTOP
		   Dc.w      $0100,$6201     ; BPLCON0
		   Dc.w      $0102,$0000     ; BPLCON1
		   Dc.w      $0104,$0200     ; BPLCON2
		   Dc.w      $0108,-8        ; BPLMOD1
		   Dc.w      $010a,-8        ; BPLMOD2
		   Dc.w      $01fc,$0003     ; FETCHMODE

Wr1BplPtr:         Dc.w      $00e0,$0000     ; BPL1PTH
		   Dc.w      $00e2,$0000     ; BPL1PTL
		   Dc.w      $00e4,$0000     ; BPL1PTL
		   Dc.w      $00e6,$0000     ; BPL1PTL
		   Dc.w      $00e8,$0000     ; BPL1PTL
		   Dc.w      $00ea,$0000     ; BPL1PTL
		   Dc.w      $00ec,$0000     ; BPL1PTL
		   Dc.w      $00ee,$0000     ; BPL1PTL
		   Dc.w      $00f0,$0000     ; BPL1PTL
		   Dc.w      $00f2,$0000     ; BPL1PTL
		   Dc.w      $00f4,$0000     ; BPL1PTL
		   Dc.w      $00f6,$0000     ; BPL1PTL

Wr1SprPtr:
Wr1SprNum          Set       $0120
		   REPT      16
		   Dc.w      Wr1SprNum,$0000    ; SPRxPT
Wr1SprNum          Set       Wr1SprNum+2
		   ENDR

		   Dc.w      $ac01,$fffe
Wr1BplPtr2:        Dc.w      $00e8,$0000     ; BPL1PTL
		   Dc.w      $00ea,$0000     ; BPL1PTL
		   Dc.w      $00ec,$0000     ; BPL1PTL
		   Dc.w      $00ee,$0000     ; BPL1PTL
		   Dc.w      $00f0,$0000     ; BPL1PTL
		   Dc.w      $00f2,$0000     ; BPL1PTL
		   Dc.w      $00f4,$0000     ; BPL1PTL
		   Dc.w      $00f6,$0000     ; BPL1PTL

		   Dc.w      $ffff,$fffe     ; End of list
;;;
;;; "Writer CopperList 2"
		   Cnop      0,8
WriteCList2:       Dc.w      $008e,$2c81     ; DIWSTRT
		   Dc.w      $0090,$2bc1     ; DIWSTOP
		   Dc.w      $0092,$0038     ; DDFSTRT
		   Dc.w      $0094,$00d0     ; DDFSTOP
		   Dc.w      $0100,$9201     ; BPLCON0
		   Dc.w      $0102,$0000     ; BPLCON1
		   Dc.w      $0104,$0200     ; BPLCON2
		   Dc.w      $0108,0         ; BPLMOD1
		   Dc.w      $010a,0         ; BPLMOD2
		   Dc.w      $01fc,$0000     ; FETCHMODE

Wr1BplPtr_2:       Dc.w      $00e0,$0000     ; BPL1PTH
		   Dc.w      $00e2,$0000     ; BPL1PTL

Wr1SprPtr2:
Wr1SprNum2         Set       $0120
		   REPT      16
		   Dc.w      Wr1SprNum2,$0000    ; SPRxPT
Wr1SprNum2         Set       Wr1SprNum2+2
		   ENDR

		   Dc.w      $ffff,$fffe     ; End of list
;;;

;;; "Apathy"
		   Cnop      0,8
Apathy:            Incbin    "!intro:intro/apathy2.raw"
;;;
