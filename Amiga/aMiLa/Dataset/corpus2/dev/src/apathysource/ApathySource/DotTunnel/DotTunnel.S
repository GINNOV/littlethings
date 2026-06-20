;;; "                 Includes & Defines"
		   Machine   68020

		   Incdir    "!includes:"
		   Include   "StdLibInc.i"
		   Include   "StdHardInc.i"

		   Include   "Loader.i"
		   Include   "Support.i"
		   Include   "Demo.i"

		   xdef      DotTunnel_Init
		   xdef      DotTunnel_Show
		   xdef      DotTunnel_Counter
		   xdef      DotTunnel_Main
		   xdef      DotTunnel_Remove

		   xdef      DotTunnel_Speed
		   xdef      DotTunnel_XS
		   xdef      DotTunnel_YS

KK                 Equ       85

DotTunnel_ID       Equ       1234

Farg1              Equ       $3af

Farg21             Equ       $05fb
Farg22             Equ       $07fc
Farg23             Equ       $0bfd
Farg24             Equ       $0fff

Back0              Equ       $0055
Back1              Equ       $0066
Back2              Equ       $0077
Back3              Equ       $0088

STARTRINGS         Equ       70
RINGAD             Equ       280

;;;

***************************************
*       Exempel/TestProgram...        *
***************************************

		   Section   code,CODE

		   IFND      noexample
;;; "                 Example"
Start:             Jsr       _InitDemo
		   Tst.l     d0
		   Bne       Exit

PlayMusic:         Bsr       _PlayMusic
		   Tst.l     d0
		   Bne       Uninit

		   Bsr       DotTunnel_Init
		   Tst.l     d0
		   Bne       StopMusic

		   Bsr       DotTunnel_Show

Main:              Bsr       _Sync

		   Bsr       DotTunnel_Counter

		   ;Move.w    #$0020,$dff106
		   ;Move.w    #$0a00,$dff180

		   Bsr       DotTunnel_Main

		   ;Move.w    #$0020,$dff106
		   ;Move.w    #$0000,$dff180

		   Btst      #6,$bfe001
		   Bne       Main
.waitlop           Btst      #6,$bfe001
		   Beq       .waitlop

		   Bsr       DotTunnel_Remove

StopMusic:         Bsr       _StopMusic
Uninit:            Bsr       _UninitDemo
Exit:              Moveq     #0,d0
		   Rts
;;;
		   ENDC

***************************************
*       Subrutiner nedanför....       *
***************************************

DotTunnel_Init:
;;; "                 Open Screen"
OpenScreen:        Move.l    #64*512*6,d0
		   Move.l    #DotTunnel_ID,d1
		   Bsr       _AllocChip
		   Tst.l     d0
		   Beq       InitError
		   Add.l     #64*512,d0
		   Add.l     #64*512,d0
		   Move.l    d0,ScreenPtr
		   Move.l    d0,PtrView
		   Add.l     #64*512,d0
		   Move.l    d0,PtrDraw

		   Lea       BplPtr,a0
		   Move.l    PtrView,d1
		   Add.l     #128*64+16,d1
		   Moveq     #1,d2
		   Moveq     #0,d0
		   Bsr       _SetPtrs

		   Lea       BplPtr+16,a0
		   Move.l    PtrView,d1
		   Add.l     #128*64+16+64,d1
		   Moveq     #1,d2
		   Moveq     #0,d0
		   Bsr       _SetPtrs
;;;
;;; "                 Install Sprites"
		   Lea       SprPtr,a0
		   Move.l    #SpriteDummy,d1
		   Moveq     #7,d2
		   Moveq     #0,d0
		   Bsr       _SetPtrs

		   ;- - - - - - - - - - - - -

		   IFD       kul
		   Lea       SprPtr,a0
		   Move.l    #Sprite1,d1
		   Moveq     #0,d2
		   Moveq     #0,d0
		   Jsr       _SetPtrs

		   Lea       SprPtr,a0
		   Lea       8(a0),a0
		   Move.l    #Sprite2,d1
		   Moveq     #0,d2
		   Moveq     #0,d0
		   Jsr       _SetPtrs

		   Lea       SprPtr,a0
		   Lea       16(a0),a0
		   Move.l    #Sprite3,d1
		   Moveq     #0,d2
		   Moveq     #0,d0
		   Jsr       _SetPtrs

		   Lea       SprPtr,a0
		   Lea       24(a0),a0
		   Move.l    #Sprite4,d1
		   Moveq     #0,d2
		   Moveq     #0,d0
		   Jsr       _SetPtrs

		   Lea       SprPtr,a0
		   Lea       32(a0),a0
		   Move.l    #Sprite5,d1
		   Moveq     #0,d2
		   Moveq     #0,d0
		   Jsr       _SetPtrs

		   Lea       SprPtr,a0
		   Lea       40(a0),a0
		   Move.l    #Sprite6,d1
		   Moveq     #0,d2
		   Moveq     #0,d0
		   Jsr       _SetPtrs

		   Lea       Custom,a5
		   Move.w    #DMAF_SETCLR!DMAF_SPRITE,dmacon(a5)
		   ENDC
;;;
;;; "                 Allocate perspective table 1"
AllocTable1:       Move.l    #64*640*2,d0        ; *2 = Words
		   Move.l    #DotTunnel_ID,d1
		   Bsr       _AllocPublic
		   Tst.l     d0
		   Beq       InitError
		   Move.l    d0,Table
;;;
;;; "                 Alloc Small Tables"
AllocSmall:        Move.l    #100*2*4+320*2+STARTRINGS*2*4*2,d0        ; *2 = Words
		   Move.l    #DotTunnel_ID,d1
		   Bsr       _AllocPublic
		   Tst.l     d0
		   Beq       InitError
		   Move.l    d0,X
		   Add.l     #100*2,d0
		   Move.l    d0,Y
		   Add.l     #100*2,d0
		   Move.l    d0,Z
		   Add.l     #100*2,d0
		   Move.l    d0,Draw
		   Add.l     #100*2,d0
		   Move.l    d0,K1
		   Add.l     #320*2,d0
		   Move.l    d0,BackBuffPtr
		   Add.l     #STARTRINGS*2*4,d0
		   Move.l    d0,BackBuffPtr2
;;;
;;; "                 Init XYZ-Coords"
InitXYZ:           Move.w    RINGS,d0
		   Subq.w    #1,d0
		   Ext.l     d0
		   Move.l    X,a0
		   Move.l    Y,a1
		   Move.l    Z,a2
		   Move.l    Draw,a3

.lop               Clr.w     (a0)+
		   Move.l    d0,d1
		   Clr.w     (a1)+
		   Mulu.w    #RINGAD,d1
		   Divu.w    RINGS,d1
		   Move.w    d1,(a2,d0.w*2)
		   Clr.w     (a3)+
		   Dbra      d0,.lop

		   Move.w    #0,C1
		   Move.w    #256*8,C2
		   Clr.w     OldTx
		   Clr.w     OldTy
		   Clr.w     Tx
		   Clr.w     Ty
		   Clr.w     Step
		   Clr.w     Rx
		   Clr.w     Ry
;;;
;;; "                 Init perspective table"
InitP1:            Move.l    #300,d0             ; Z läget i d0
		   Move.l    Table,a0            ; Perspektiv tabell
		   Lea       _Sin1024,a1          ; Sinus tabell
		   Moveq     #0,d7

.lop1              Move.l    #65536*110*128,d2    ; X,Y,R Konstant i d2
		   Move.l    #255+KK-4,d3         ; Z Konstant i d3
		   Sub.l     d0,d3               ; -Z läget i d3
		   Divu.l    d3,d2               ; /Z värde i d2
		   Swap      d2                  ; /65536 i d2
		   And.l     #$ffff,d2           ;

		   Move.l    #63,d1              ; Vinkeln i d1

.lop2              Move.l    d1,d4               ; Vinkeln i d4
		   Lsl.l     #4,d4               ; *16 i d4
		   Move.w    (a1,d4.w*2),d4      ; Sin(d4)*256 i d5
		   Muls.w    d2,d4               ; *K i d5
		   Asr.l     #8,d4               ; /256 i d5
		   Addx.l    d7,d4

		   Move.l    d1,d5               ; Vinkeln i d4
		   Add.l     #16,d5
		   And.l     #63,d5
		   Lsl.l     #4,d5               ; *16 i d4
		   Move.w    (a1,d5.w*2),d5      ; Sin(d4)*256 i d5
		   Muls.w    d2,d5               ; *K i d5
		   Asr.l     #8,d5               ; /256 i d5
		   Addx.l    d7,d5
		   Asl.l     #6,d5

		   Move.l    d0,d3               ; Z läget i d3
		   Lsl.l     #6,d3               ; *64 i d3
		   Add.l     d1,d3               ; +Vinkeln i d3
		   Move.w    d4,(a0,d3.w*4)     ; Konstant till Persp.tab.
		   Move.w    d5,2(a0,d3.w*4)      ; Konstant till Persp.tab.

		   Dbra      d1,.lop2            ;
		   Dbra      d0,.lop1            ;
;;;
;;; "                 Init second perspective table"
InitK1:            Move.l    #300,d0
		   Move.l    K1,a0
		   Moveq     #0,d7
.lop               Move.l    #110*65536,d1
		   Move.l    #255+KK-4,d2
		   Sub.l     d0,d2
		   Divu.l    d2,d1
		   Asr.l     #2,d1
		   Addx.l    d7,d1
		   Move.w    d1,(a0,d0.w*2)
		   Dbra      d0,.lop
;;;
;;; "                 Rts"
		   Moveq     #0,d0
		   Rts

InitError:         Move.l    #DotTunnel_ID,d0
		   Bsr       _FreeMany
		   Moveq     #1,d0
		   Rts
;;;

DotTunnel_Show:
;;; "                 Init Cols"
		   Move.w    #$0020,$dff106
		   Move.w    #$0000,$dff180    ; Bakgrund
		   Move.w    #Farg21,$dff182     ; 1
		   Move.w    #Farg21,$dff184     ;   2
		   Move.w    #Farg22,$dff186     ; 1 2
		   Move.w    #Farg21,$dff188     ;     3
		   Move.w    #Farg22,$dff18a     ; 1   3
		   Move.w    #Farg22,$dff18c     ;   2 3
		   Move.w    #Farg23,$dff18e     ; 1 2 3

		   Move.w    #Farg21,$dff190     ;       4
		   Move.w    #Farg22,$dff192     ; 1     4
		   Move.w    #Farg22,$dff194     ;   2   4
		   Move.w    #Farg23,$dff196     ; 1 2   4
		   Move.w    #Farg22,$dff198     ;     3 4
		   Move.w    #Farg23,$dff19a     ; 1   3 4
		   Move.w    #Farg23,$dff19c     ;   2 3 4
		   Move.w    #Farg24,$dff19e     ; 1 2 3 4
;;;
		   Lea       Copperlista,a0
		   Bsr       _InstallCopper
		   Rts

DotTunnel_Counter:
;;; "                 Increase Counters"

		   Move.w    #RINGAD,d2
		   Divu.w    RINGS,d2
		   Divu.w    DotTunnel_Speed,d2
		   Move.w    d2,AD

		   ;-------------------------

		   Move.w    DotTunnel_XS,d1
		   Muls.w    DotTunnel_Speed,d1
		   Move.w    DotTunnel_YS,d2
		   Muls.w    DotTunnel_Speed,d2

		   Add.w     d1,C1
		   And.w     #8191,C1
		   Add.w     d2,C2
		   And.w     #8191,C2
		   Subq.w    #1,Count

		   Moveq     #0,d2
		   Move.w    C1,d0
		   Asr.w     #3,d0
		   Addx.l    d2,d0
		   Move.w    d0,Co1

		   Move.w    C2,d0
		   Asr.w     #3,d0
		   Addx.l    d2,d0
		   Move.w    d0,Co2

		   Lea       OldTx,a0
		   Lea       Tx,a1
		   Lea       Step,a2
		   Lea       Rx,a3
		   Move.w    (a1),d0
		   Sub.w     (a0),d0
		   Asl.w     #2,d0
		   Muls.w    (a2),d0
		   Divs.w    AD,d0
		   Move.w    (a0),d1
		   Asl.w     #2,d1
		   Add.w     d1,d0
		   Move.w    d0,(a3)

		   Lea       OldTy,a0
		   Lea       Ty,a1
		   Lea       Step,a2
		   Lea       Ry,a3
		   Move.w    (a1),d0
		   Sub.w     (a0),d0
		   Asl.w     #2,d0
		   Muls.w    (a2),d0
		   Divs.w    AD,d0
		   Move.w    (a0),d1
		   Asl.w     #2,d1
		   Add.w     d1,d0
		   Move.w    d0,(a3)

		   Lea       Step,a0
		   Addq.w    #1,(a0)
		   Move.w    AD,d1
		   Cmp.w     (a0),d1
		   Bge       .ok
		   Sub.w     d1,(a0)
.ok
;;;
		   IFD       kul
;;; "                 Increase Sprite Positions"
		   Move.l    BackBuffPtr,a0

		   Move.w    BackBuffPos,d0
		   Move.w    (a0,d0.w*2),d1
		   Move.w    d1,SprX

		   Move.w    BackBuffPos,d0
		   Move.w    Co1,d1
		   Move.w    d1,(a0,d0.w*2)

		   Move.w    BackBuffPos,d0
		   Addq.w    #1,d0
		   Move.w    #STARTRINGS*4,d1
		   Divu.w    DotTunnel_Speed,d1
		   Divu.w    d1,d0
		   Swap      d0
		   Move.w    d0,BackBuffPos

		   Lea       _Sin1024,a3
		   Move.w    SprX,d0
		   ;Add.w     #512,d0
		   And.w     #1023,d0
		   Move.w    (a3,d0.w*2),d1      ;1 acc
		   Asr.w     #4,d1

		   And.w     #31,d1
		   Move.w    d1,SprX

		   ;-------------------------

		   Move.l    BackBuffPtr2,a0

		   Move.w    BackBuffPos,d0
		   Move.w    (a0,d0.w*2),d1
		   Move.w    d1,SprY

		   Move.w    BackBuffPos,d0
		   Move.w    Co2,d1
		   Move.w    d1,(a0,d0.w*2)

		   Lea       _Sin1024,a3
		   Move.w    SprY,d0
		   Add.w     #512,d0
		   And.w     #1023,d0
		   Move.w    (a3,d0.w*2),d1      ;1 acc
		   Asr.w     #3,d1

		   And.w     #15,d1
		   Move.w    d1,SprY
;;;
		   ENDC
		   Rts

DotTunnel_Main:
		   IFD       kul
;;; "                 Update Sprites"
		   Move.l    #$00200000,d1
		   Move.w    #$2c,d0
		   Sub.w     SprY,d0
		   Lsl.w     #8,d0

		   Move.w    #$40,d2
		   Sub.w     SprX,d2
		   Add.w     d2,d0
		   Swap      d0
		   And.l     #$ffff0000,d0
		   ;Or.l      #$4c000000,d0
		   Move.l    d0,Sprite1
		   Add.l     d1,d0
		   Move.l    d0,Sprite2
		   Add.l     d1,d0
		   Move.l    d0,Sprite3
		   Add.l     d1,d0
		   Move.l    d0,Sprite4
		   Add.l     d1,d0
		   Move.l    d0,Sprite5
		   Add.l     d1,d0
		   Move.l    d0,Sprite6
		   Add.l     d1,d0
;;;
		   ENDC
;;; "                 Clear Screen"
		   Move.l    PtrDraw,a0

Clear:             Moveq     #63,d0
		   Lea       24568(a0),a0    ;(64*128+16)+(64*255+40)
		   Moveq     #0,d1
		   Moveq     #0,d2
		   Moveq     #0,d3
		   Moveq     #0,d4
		   Moveq     #0,d5
		   Sub.l     a1,a1
		   Sub.l     a2,a2
		   Sub.l     a3,a3
		   Sub.l     a4,a4
		   Sub.l     a5,a5
		   Moveq     #24,d6
.loop
		   Movem.l   d1-d5/a1-a5,-(a0)
		   Sub.l     d6,a0
		   Movem.l   d1-d5/a1-a5,-(a0)
		   Sub.l     d6,a0
		   Movem.l   d1-d5/a1-a5,-(a0)
		   Sub.l     d6,a0
		   Movem.l   d1-d5/a1-a5,-(a0)
		   Sub.l     d6,a0
		   Dbra      d0,.loop
;;;
;;; "                 Dot It Out!"
DrawTunnel1:       Move.w    RINGS,d0
		   Subq.w    #1,d0
		   Ext.l     d0
		   Move.l    X,a0
		   Move.l    Y,a1
		   Move.l    Z,a2
		   Move.l    PtrDraw,a4
		   Add.l     #63,a4

		   Move.l    Table,CurrTable
		   Move.l    K1,d5
		   Moveq     #0,d2
		   Move.w    Ry,d6

		   Move.l    Draw,a6

.RingLoop          Move.w    (a2),d2              ;1 acc
		   Move.l    d5,a5

		   Move.w    (a0),d3              ;1 acc
		   Sub.w     Rx,d3
		   Move.w    (a5,d2.w*2),d7       ;1 acc
		   Muls.w    d7,d3
		   Add.l     #(256-3*8)*65536,d3

		   Move.w    (a1),d4              ;1 acc
		   Sub.w     d6,d4
		   Muls.w    d7,d4
		   Swap      d4
		   Add.w     #256*4,d4
		   Asr.w     #2,d4
		   Asl.w     #6,d4
		   Move.w    d4,d3

		   Lsl.l     #8,d2
		   Move.l    CurrTable,a5
		   Add.l     d2,a5

		   Move.w    DotTunnel_Speed,d7
		   Add.w     d7,(a2)         ;1 acc
		   Moveq     #15,d1
		   Tst.w     (a6)
		   Beq       .skipdraw
.DotLoop
		   REPT      4
		   Move.l    a4,a3               ;2
		   Move.l    d3,d4               ;2
		   Add.l     (a5)+,d4            ;5
		   Add.w     d4,a3               ;4
		   Swap      d4                  ;4
		   Move.w    d4,d7               ;2
		   Lsr.w     #3,d4               ;4
		   Sub.w     d4,a3               ;4
		   Bset      d7,(a3)             ;9
		   ENDR

		   Dbra.b    d1,.DotLoop         ;6                                                 ;---------------

.skipdraw          Cmp.w     #RINGAD-1,(a2)           ;1 acc
		   Ble       .skip
		   Sub.w     #RINGAD,(a2)           ;1 acc

		   Clr.w     Step               ;1 acc
		   Move.w    #1,(a6)

		   Lea       Tx,a3
		   Move.w    (a3),d3             ;1 acc
		   Move.w    d3,OldTx
		   Move.w    (a0),d3             ;1 acc
		   Asr.w     #2,d3
		   Move.w    d3,(a3)

		   Lea       Ty,a3
		   Move.w    (a3),d3             ;1 acc
		   Move.w    d3,OldTy
		   Move.w    (a1),d3             ;1 acc
		   Asr.w     #2,d3
		   Move.w    d3,(a3)

		   Lea       _Sin1024,a3
		   Move.w    Co1,d3
		   Move.w    (a3,d3.w*2),d4      ;1 acc
		   Muls.w    XX,d4
		   Asr.l     #8,d4
		   Move.w    d4,(a0)            ;1 acc

		   Move.w    Co2,d3
		   Add.w     #256,d3
		   And.w     #1023,d3
		   Move.w    (a3,d3.w*2),d4      ;1 acc
		   Muls.w    YY,d4
		   Asr.l     #8,d4
		   Move.w    d4,(a1)            ;1 acc

.skip              Addq.l    #2,a0
		   Addq.l    #2,a1
		   Addq.l    #2,a2
		   Addq.l    #2,a6

		   Dbra      d0,.RingLoop
;;;
;;; "                 Screen Swap"
ScreenSwap:        Move.l    PtrView,d0
		   Move.l    PtrDraw,PtrView
		   Move.l    d0,PtrDraw

		   Lea       BplPtr,a0
		   Move.l    PtrView,d1
		   Add.l     #128*64+16,d1
		   Moveq     #1,d2
		   Moveq     #0,d0
		   Bsr       _SetPtrs

		   Lea       BplPtr+16,a0
		   Move.l    PtrView,d1
		   Add.l     #128*64+16+64,d1
		   Moveq     #1,d2
		   Moveq     #0,d0
		   Bsr       _SetPtrs
;;;
		   Rts

DotTunnel_Remove:
;;; "                 Free Memory"
FreeMemory:        Move.l    #DotTunnel_ID,d0
		   Bsr       _FreeMany
;;;
		   Rts

***************************************
*                Data...              *
***************************************

		   Section   data,DATA
;;; "Data..."
BackBuffPtr:       Dc.l      0
BackBuffPtr2:      Dc.l      0
BackBuffPos:       Dc.l      0
BackBuffPos2:      Dc.l      0
SprX:              Dc.l      0
SprY:              Dc.l      0

StoryCount:        Dc.l      0
CurrTable:         Dc.l      0

DotTunnel_XS:      Dc.w      0
DotTunnel_YS:      Dc.w      0
XX:                Dc.w      512
YY:                Dc.w      2048

Count:             Dc.w      0
Persp:             Dc.w      0
Mode:              Dc.w      0
OldMode:           Dc.w      0

DotTunnel_Speed:   Dc.w      1
AD:                Dc.w      0
RINGS:             Dc.w      STARTRINGS
COPEFF:            Dc.w      0

C1:                Dc.w      0
C2:                Dc.w      256*8
Co1:               Dc.w      0
Co2:               Dc.w      0
Table:             Dc.l      0,0
ScreenPtr:         Dc.l      0
PtrView:           Dc.l      0
PtrDraw:           Dc.l      0

X:                 Dc.l      0
Y:                 Dc.l      0
Z:                 Dc.l      0
Draw:              Dc.l      0
K1:                Dc.l      0
K2:                Dc.l      0

OldTx:             Dc.w      0
OldTy:             Dc.w      0
Tx:                Dc.w      0
Ty:                Dc.w      0
Step:              Dc.w      0
Rx:                Dc.w      0
Ry:                Dc.w      0
;;;
		   IFD       kul2
;;; "StoryBoard"
StoryBoard:
		   ;Dc.w     XS,YS,TIME,PERSP,MODE: 0-1=true,2-3=half true
		   ; 4-5=false ,XX,YY,SPEED,RINGS,COPEFF
		   ;------------------------------
		   ;XS,YS: helst delbart med 8

		   Dc.w      34,38,100,2
		   Dc.w      36,32,200,2
		   Dc.w      16,46,100,2
		   Dc.w      26,24,200,2
		   Dc.w      24,34,100,2
		   Dc.w      16,26,100,2
		   Dc.w      32,24,100,2
		   Dc.w      24,14,50,2
		   Dc.w      22,24,50,2
		   Dc.w      14,35,50,2
		   Dc.w      17,24,50,4
		   Dc.w      34,14,50,4
		   Dc.w      32,34,50,4
		   Dc.w      14,18,50,4
		   Dc.w      32,24,50,4
		   Dc.w      19,9,100,4
		   Dc.w      19,19,50,4
		   Dc.w      29,9,20,4
		   Dc.w      19,29,20,4
		   Dc.w      40,23,50,4
		   Dc.w      12,20,20,4
		   Dc.w      19,9,50,4
		   Dc.w      39,29,20,4
		   Dc.w      29,49,20,4
		   Dc.w      19,29,50,4
		   Dc.w      10,23,20,4
		   Dc.w      12,30,20,4
		   Dc.w      29,9,50,4
		   Dc.w      19,29,20,4
		   Dc.w      40,23,20,4
		   Dc.w      12,20,50,4
		   Dc.w      19,19,20,4
		   Dc.w      39,29,20,4
		   Dc.w      29,49,50,4
		   Dc.w      19,29,20,4
		   Dc.w      10,23,20,4
		   Dc.w      12,30,100,4

		   Dc.w      $FFFF
;;;
		   ENDC

		   Section   chipdata,DATA_C
;;; "Copperlist"
Copperlista:       Dc.w      $008e,$2c81     ; DIWSTRT
		   Dc.w      $0090,$2bc1     ; DIWSTOP
		   Dc.w      $0092,$0038     ; DDFSTRT
		   Dc.w      $0094,$00d0     ; DDFSTOP
		   Dc.w      $0100,$4201     ; BPLCON0
		   Dc.w      $0102,$0001     ; BPLCON1
		   Dc.w      $0104,$0000     ; BPLCON2
		   Dc.w      $0106,$0020     ; BPLCON3 ($0020 = copborder)
		   Dc.w      $0108,24-8      ; BPLMOD1
		   Dc.w      $010a,24-8      ; BPLMOD2
		   Dc.w      $010c,$0022     ; Sprite palette = 32
		   Dc.w      $01fc,$000f     ; FETCHMODE
BplPtr             Dc.w      $00e0,$0000     ; BPL1PTH
		   Dc.w      $00e2,$0000     ; BPL1PTL
		   Dc.w      $00e4,$0000     ; BPL1PTL
		   Dc.w      $00e6,$0000     ; BPL1PTL
		   Dc.w      $00e8,$0000     ; BPL1PTL
		   Dc.w      $00ea,$0000     ; BPL1PTL
		   Dc.w      $00ec,$0000     ; BPL1PTL
		   Dc.w      $00ee,$0000     ; BPL1PTL

SprPtr:
SprNum             Set       $0120
		   Rept      16
		   Dc.w      SprNum,$0000    ; SPRxPT
SprNum             Set       SprNum+2
		   Endr

		   IFD       kul
		   Dc.w      $0106,$2020
		   Dc.w      $0180,Back0
		   Dc.w      $0182,Back1
		   Dc.w      $0184,Back2
		   Dc.w      $0186,Back3
		   ;--------------------
		   Dc.w      $0188,Back0
		   Dc.w      $018a,Back1
		   Dc.w      $018c,Back2
		   Dc.w      $018e,Back3
		   ;--------------------
		   Dc.w      $0190,Back0
		   Dc.w      $0192,Back1
		   Dc.w      $0194,Back2
		   Dc.w      $0196,Back3
		   ;--------------------
		   Dc.w      $0198,Back0
		   Dc.w      $019a,Back1
		   Dc.w      $019c,Back2
		   Dc.w      $019e,Back3
		   ENDC

		   Dc.w      $ffff,$fffe     ; End of list

;;;
		   IFD       kul
;;; "Sprites"
		   Cnop      0,8
Sprite1:           Dc.l      $2c400000,0,$2c020000,0
		   REPT      (256+16)/16
		   Include   "!intro:dottunnel/back.spr4"
		   ENDR
		   Dc.l      0,0,0,0

		   Cnop      0,8
Sprite2:           Dc.l      $2c600000,0,$2c020000,0
		   REPT      (256+16)/16
		   Include   "!intro:dottunnel/back.spr4"
		   ENDR
		   Dc.l      0,0,0,0

		   Cnop      0,8
Sprite3:           Dc.l      $2c800000,0,$2c020000,0
		   REPT      (256+16)/16
		   Include   "!intro:dottunnel/back.spr4"
		   ENDR
		   Dc.l      0,0,0,0

		   Cnop      0,8
Sprite4:           Dc.l      $2ca00000,0,$2c020000,0
		   REPT      (256+16)/16
		   Include   "!intro:dottunnel/back.spr4"
		   ENDR
		   Dc.l      0,0,0,0

		   Cnop      0,8
Sprite5:           Dc.l      $2cc00000,0,$2c020000,0
		   REPT      (256+16)/16
		   Include   "!intro:dottunnel/back.spr4"
		   ENDR
		   Dc.l      0,0,0,0

		   Cnop      0,8
Sprite6:           Dc.l      $2ce00000,0,$2c020000,0
		   REPT      (256+16)/16
		   Include   "!intro:dottunnel/back.spr4"
		   ENDR
		   Dc.l      0,0,0,0
;;;
		   ENDC
