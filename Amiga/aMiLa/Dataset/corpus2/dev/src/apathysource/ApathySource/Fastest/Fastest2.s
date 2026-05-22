;;; "                 Includes & Defines"
		   Machine   68020
		   Incdir    "!Includes:"
		   Include   "StdLibInc.i"
		   Include   "StdHardInc.i"

		   Include   "Loader.i"
		   Include   "Support.i"
		   Include   "Demo.i"

		   Incdir    "!Includes:os3.0/"
		   Include   "exec/memory.i"

		   xdef      Fastest_Init
		   xdef      Fastest_Show
		   xdef      Fastest_Counter
		   xdef      Fastest_Main
		   xdef      Fastest_Remove

		   xdef      Fastest_Angle
		   xdef      Fastest_Zoom
		   xdef      Fastest_XOff
		   xdef      Fastest_YOff

		   xdef      Texture

Fastest_ID         Equ       101
SprCol             Equ       $0
NoGrid             Equ       0
Grey               Equ       0
Dither             Equ       1
MBlur              Equ       1

DIST               Equ       180

		   IFEQ      Grey

_Farg0             Equ       $0004
_Farg1             Equ       $0015
_Farg2             Equ       $0026
_Farg3             Equ       $0137
_Farg4             Equ       $0248
_Farg5             Equ       $0359
_Farg6             Equ       $046a
_Farg7             Equ       $057b

_Farg8             Equ       $068c
_Farg9             Equ       $079d
_Farg10            Equ       $08ae
_Farg11            Equ       $09bf
_Farg12            Equ       $0acf
_Farg13            Equ       $0bdf
_Farg14            Equ       $0cef
_Farg15            Equ       $0dff

		   ELSE

_Farg0             Equ       $0000
_Farg1             Equ       $0111
_Farg2             Equ       $0222
_Farg3             Equ       $0333
_Farg4             Equ       $0444
_Farg5             Equ       $0555
_Farg6             Equ       $0666
_Farg7             Equ       $0777

_Farg8             Equ       $0888
_Farg9             Equ       $0999
_Farg10            Equ       $0aaa
_Farg11            Equ       $0bbb
_Farg12            Equ       $0ccc
_Farg13            Equ       $0ddd
_Farg14            Equ       $0eee
_Farg15            Equ       $0fff

		   ENDC

Farg0              Equ        SprCol
Farg1              Equ        SprCol
Farg2              Equ        SprCol
Farg3              Equ        SprCol
Farg4              Equ        SprCol
Farg5              Equ        SprCol
Farg6              Equ        SprCol
Farg7              Equ        SprCol

Farg8              Equ        SprCol
Farg9              Equ        SprCol
Farg10             Equ        SprCol
Farg11             Equ        SprCol
Farg12             Equ        SprCol
Farg13             Equ        SprCol
Farg14             Equ        SprCol
Farg15             Equ        SprCol

;;;

		   xref      _SetColByte



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

		   Bsr       Fastest_Init
		   Tst.l     d0
		   Bne       StopMusic

		   Bsr       Fastest_Show

Main:              Bsr       _Sync

		   Move.w    #$0020,$dff106
		   Move.w    #$0a00,$dff180

		   Bsr       Fastest_Counter
		   Bsr       Fastest_Main

		   Move.w    #$0020,$dff106
		   Move.w    #$0000,$dff180

		   Btst      #6,$bfe001
		   Bne       Main
.waitlop           Btst      #6,$bfe001
		   Beq       .waitlop

		   Bsr       Fastest_Remove

StopMusic:         Bsr       _StopMusic
Uninit:            Bsr       _UninitDemo
Exit:              Moveq     #0,d0
		   Rts
;;;
		   ENDC

***************************************
*       Subrutiner nedanför....       *
***************************************

Fastest_Init:
;;; "                 Alloc CopperList"
AllocCopper:       Move.l    #10*1024,d0
		   Move.l    #Fastest_ID,d1
		   Jsr       _AllocChip
		   Tst.l     d0
		   Beq       InitError
		   Move.l    d0,CopperPtr
;;;
;;; "                 Init CopperList"
InitCList:         Move.l    CopperPtr,a0

		   Move.l    #$008e2c81,(a0)+     ; DIWSTRT
		   Move.l    #$00902cc1,(a0)+     ; DIWSTOP
		   Move.l    #$00920038,(a0)+     ; DDFSTRT
		   Move.l    #$009400d0,(a0)+     ; DDFSTOP
		   Move.l    #$01000211,(a0)+     ; BPLCON0
		   Move.l    #$01020010,(a0)+     ; BPLCON1
		   Move.l    #$01040024,(a0)+     ; BPLCON2
		   Move.l    #$01060020,(a0)+     ; BPLCON3 ($0020 = copborder)
		   Move.w    #$0108,(a0)+         ; BPLMOD1
		   Move.w    #-8,(a0)+
		   Move.w    #$010a,(a0)+         ; BPLMOD2
		   Move.w    #-8,(a0)+
		   Move.l    #$010c0000,(a0)+     ; Sprite palette = 31
		   Move.l    #$01fc000f,(a0)+     ; FETCHMODE

		   ;-----------------------------------

		   Move.l    a0,BplPtr
		   Move.l    #$00e00000,(a0)+     ; BPL1PTH
		   Move.l    #$00e20000,(a0)+     ; BPL1PTL
		   Move.l    #$00e40000,(a0)+     ; BPL1PTL
		   Move.l    #$00e60000,(a0)+     ; BPL1PTL
		   Move.l    #$00e80000,(a0)+     ; BPL1PTL
		   Move.l    #$00ea0000,(a0)+     ; BPL1PTL
		   Move.l    #$00ec0000,(a0)+     ; BPL1PTL
		   Move.l    #$00ee0000,(a0)+     ; BPL1PTL

		   Move.l    a0,BplPtr2
		   Move.l    #$00f00000,(a0)+     ; BPL1PTH
		   Move.l    #$00f20000,(a0)+     ; BPL1PTL
		   Move.l    #$00f40000,(a0)+     ; BPL1PTL
		   Move.l    #$00f60000,(a0)+     ; BPL1PTL
		   Move.l    #$00f80000,(a0)+     ; BPL1PTL
		   Move.l    #$00fa0000,(a0)+     ; BPL1PTL
		   Move.l    #$00fc0000,(a0)+     ; BPL1PTL
		   Move.l    #$00fe0000,(a0)+     ; BPL1PTL

		   ;--------------------------------

		   Move.l    a0,SprPtr
		   Move.l    #$01200000,(a0)+     ; SPRxPT
		   Move.l    #$01220000,(a0)+     ; SPRxPT
		   Move.l    #$01240000,(a0)+     ; SPRxPT
		   Move.l    #$01260000,(a0)+     ; SPRxPT
		   Move.l    #$01280000,(a0)+     ; SPRxPT
		   Move.l    #$012a0000,(a0)+     ; SPRxPT
		   Move.l    #$012c0000,(a0)+     ; SPRxPT
		   Move.l    #$012e0000,(a0)+     ; SPRxPT
		   Move.l    #$01300000,(a0)+     ; SPRxPT
		   Move.l    #$01320000,(a0)+     ; SPRxPT
		   Move.l    #$01340000,(a0)+     ; SPRxPT
		   Move.l    #$01360000,(a0)+     ; SPRxPT
		   Move.l    #$01380000,(a0)+     ; SPRxPT
		   Move.l    #$013a0000,(a0)+     ; SPRxPT
		   Move.l    #$013c0000,(a0)+     ; SPRxPT
		   Move.l    #$013e0000,(a0)+     ; SPRxPT

		   ;--------------------

		   Move.l    #$2c,d0
		   Move.l    #64+42-1,d7

.lop1              Move.l    d0,d1
		   Swap      d1
		   Lsl.l     #8,d1
		   Or.l      #$0001fffe,d1
		   Move.l    d1,(a0)+

		   Move.w    #$0108,(a0)+
		   Move.w    #-48,(a0)+
		   Move.w    #$010a,(a0)+
		   Move.w    #-48,(a0)+
		   Move.l    #$01020010,(a0)+

		   Move.l    d0,d1
		   Addq.l    #1,d1
		   Swap      d1
		   Lsl.l     #8,d1
		   Or.l      #$0001fffe,d1
		   Move.l    d1,(a0)+

		   Move.w    #$0108,(a0)+
		   Move.w    #-8,(a0)+
		   Move.w    #$010a,(a0)+
		   Move.w    #-8,(a0)+
		   Move.l    #$01020021,(a0)+

		   Addq.l    #2,d0
		   Dbra      d7,.lop1

		   ;--------------------------

		   Move.l    #$ffd9fffe,(a0)+

		   Move.l    #0,d0
		   Move.l    #22-1,d7

.lop2              Move.l    d0,d1
		   Swap      d1
		   Lsl.l     #8,d1
		   Or.l      #$0001fffe,d1
		   Move.l    d1,(a0)+

		   Move.w    #$0108,(a0)+
		   Move.w    #-48,(a0)+
		   Move.w    #$010a,(a0)+
		   Move.w    #-48,(a0)+
		   Move.l    #$01020010,(a0)+

		   Move.l    d0,d1
		   Addq.l    #1,d1
		   Swap      d1
		   Lsl.l     #8,d1
		   Or.l      #$0001fffe,d1
		   Move.l    d1,(a0)+

		   Move.w    #$0108,(a0)+
		   Move.w    #-8,(a0)+
		   Move.w    #$010a,(a0)+
		   Move.w    #-8,(a0)+
		   Move.l    #$01020021,(a0)+

		   Addq.l    #2,d0
		   Dbra      d7,.lop2

		   Move.l     #$fffffffe,(a0)+     ; End of list
;;;
;;; "                 Init Screen"
InitScreen:
		   Move.l    #40*128*4,d0
		   Move.l    #Fastest_ID,d1
		   Jsr       _AllocChip
		   Tst.l     d0
		   Beq       InitError
		   Move.l    d0,ScrPtr1
		   Add.l     #5120,d0
		   Move.l    d0,ScrPtr2
		   Add.l     #5120,d0
		   Move.l    d0,ViewPtr1
		   Add.l     #5120,d0
		   Move.l    d0,ViewPtr2

		   ;------------------------

		   Move.l    BplPtr,a0
		   Move.l    ScrPtr1,d1
		   Moveq     #2-1,d2
		   Move.l    #0,d0
		   Jsr       _SetPtrs

		   Move.l    BplPtr,a0
		   Lea       16(a0),a0
		   Move.l    ScrPtr2,d1
		   Moveq     #2-1,d2
		   Move.l    #0,d0
		   Jsr       _SetPtrs

		   ;- - - - - - - - - - - -

		   Move.l    BplPtr2,a0
		   Move.l    ScrPtr1,d1
		   Moveq     #2-1,d2
		   Move.l    #0,d0
		   Jsr       _SetPtrs

		   Move.l    BplPtr2,a0
		   Lea       16(a0),a0
		   Move.l    ScrPtr2,d1
		   Moveq     #2-1,d2
		   Move.l    #0,d0
		   Jsr       _SetPtrs

		   ;------------------------

		   Move.l    SprPtr,a0
		   Move.l    #SpriteDummy,d1
		   Moveq     #7,d2
		   Moveq     #0,d0
		   Jsr       _SetPtrs
;;;
;;; "                 Init Sprites"
InitSprites:       Move.l    #(16*2+16*256)*5,d0
		   Move.l    #Fastest_ID,d1
		   Jsr       _AllocChip
		   Tst.l     d0
		   Beq       InitError
		   Move.l    d0,Sprite1

		   ;-------------------------

		   Move.l    Sprite1,a0
		   Moveq     #5-1,d6
		   Move.l    #$40,d2

.spritelop         Move.l    d2,d0
		   Or.l      #$2c00,d0
		   Swap      d0
		   Move.l    d0,(a0)+
		   Add.l     #$20,d2

		   Clr.l     (a0)+
		   Move.l    #$2c020000,(a0)+
		   Clr.l     (a0)+

		   Move.l    #128-1,d7
		   Move.l    #$aaaaaaaa,d0
		   Move.l    #$55555555,d1

.linelop           Move.l    d0,(a0)+
		   Move.l    d0,(a0)+
		   Move.l    d0,(a0)+
		   Move.l    d0,(a0)+
		   Move.l    d1,(a0)+
		   Move.l    d1,(a0)+
		   Move.l    d1,(a0)+
		   Move.l    d1,(a0)+
		   Dbra      d7,.linelop

		   Clr.l     (a0)+
		   Clr.l     (a0)+
		   Clr.l     (a0)+
		   Clr.l     (a0)+
		   Dbra      d6,.spritelop

		   ;-------------------------

		   Move.l    SprPtr,a0
		   Move.l    Sprite1,d1
		   Moveq     #5-1,d2
		   Move.l    #16*2+16*256,d0
		   Jsr       _SetPtrs
;;;

;;; "                 Alloc TextureCopies"
AllocTextures:     Move.l    #256*256*2,d0
		   Move.l    #Fastest_ID,d1
		   Jsr       _AllocPublic
		   Tst.l     d0
		   Beq       InitError
		   Move.l    d0,TexturePtr1

		   Move.l    #256*256*2,d0
		   Move.l    #Fastest_ID,d1
		   Jsr       _AllocPublic
		   Tst.l     d0
		   Beq       InitError
		   Move.l    d0,TexturePtr2
;;;
;;; "                 Extract 4-bit Texture"
Extract:           Lea       Texture,a0
		   Move.l    TexturePtr1,a1
		   Move.l    #256/2*128-1,d7
.lop1
		   Move.b    (a0)+,d0
		   Move.b    d0,d1
		   And.l     #%11110000,d0
		   Lsr.l     #4,d0
		   And.l     #%00001111,d1

		   Move.w    d0,(a1)+
		   Move.w    d1,(a1)+

		   Dbra      d7,.lop1
;;;
;;; "                 Copy to second half"
Duplicate:         Move.l    TexturePtr1,a0
		   Move.l    TexturePtr1,a1
		   Add.l     #256*256,a1

		   Move.l    #256*256/4-1,d7
.copylop1          Move.l    (a0)+,(a1)+
		   Dbra      d7,.copylop1
;;;
;;; "                 Roll texture 1"
Copy2:             Move.l    TexturePtr1,a0

		   Move.l    #256*256*2/4-1,d7
.lop
		   Move.l    (a0),d0
		   Lsl.l     #8,d0
		   Move.l    d0,(a0)+

		   Dbra      d7,.lop
;;;
;;; "                 Copy to texture 2"
Copy4:             Move.l    TexturePtr1,a0
		   Move.l    TexturePtr2,a1

		   Move.l    #256*256*2/4-1,d7
.lop
		   Move.l    (a0)+,d0
		   Lsl.l     #4,d0
		   Move.l    d0,(a1)+

		   Dbra      d7,.lop
;;;
;;; "                 Rts"
		   Moveq     #0,d0
		   Rts

InitError:         Move.l    #Fastest_ID,d0
		   Bsr       _FreeMany
		   Moveq     #1,d0
		   Rts
;;;

Fastest_Show:
		   IFD       hehe
;;; "                 Init Colours"
InitCols1:         Move.w    #$0020,$dff106

		   Move.w    #_Farg0,$dff180
		   Move.w    #_Farg1,$dff182
		   Move.w    #_Farg2,$dff184
		   Move.w    #_Farg3,$dff186
		   Move.w    #_Farg4,$dff188
		   Move.w    #_Farg5,$dff18a
		   Move.w    #_Farg6,$dff18c
		   Move.w    #_Farg7,$dff18e
		   Move.w    #_Farg8,$dff190
		   Move.w    #_Farg9,$dff192
		   Move.w    #_Farg10,$dff194
		   Move.w    #_Farg11,$dff196
		   Move.w    #_Farg12,$dff198
		   Move.w    #_Farg13,$dff19a
		   Move.w    #_Farg14,$dff19c
		   Move.w    #_Farg15,$dff19e

		   Move.w    #$2020,$dff106

		   Move.w    #SprCol,$dff180
		   Move.w    #SprCol,$dff182
		   Move.w    #SprCol,$dff184
		   Move.w    #SprCol,$dff186
		   Move.w    #SprCol,$dff188
		   Move.w    #SprCol,$dff18a
		   Move.w    #SprCol,$dff18c
		   Move.w    #SprCol,$dff18e
		   Move.w    #SprCol,$dff190
		   Move.w    #SprCol,$dff192
		   Move.w    #SprCol,$dff194
		   Move.w    #SprCol,$dff196
		   Move.w    #SprCol,$dff198
		   Move.w    #SprCol,$dff19a
		   Move.w    #SprCol,$dff19c
		   Move.w    #SprCol,$dff19e
;;;
		   ENDC
;;; "                 Init Colours"
		   Moveq     #16,d0
		   Moveq     #15-1,d6
.collop2

		   Moveq     #16-1,d7
.collop1
		   Move.l    #15,d1
		   Sub.l     d7,d1
		   Lsl.l     #4,d1
		   Move.l    #15,d2
		   Sub.l     d6,d2
		   Lsl.l     #4,d2
		   Add.l     d2,d1
		   Lsr.l     #1,d1

		   Move.l    d1,d2
		   Move.l    d1,d3
		   Bsr       _SetColByte
		   Addq.l    #1,d0
		   Dbra      d7,.collop1
		   Dbra      d6,.collop2

		   ;-------------------

		   Moveq     #16-1,d7
.lop               Move.l    d7,d0
		   Moveq     #0,d1
		   Move.l    d1,d2
		   Move.l    d1,d3
		   Bsr       _SetColByte
		   Dbra      d7,.lop
;;;
;;; "                 Install Copperlist"
		   Lea       Custom,a5
		   Move.w    #DMAF_SETCLR!DMAF_SPRITE,dmacon(a5)

		   Move.l    CopperPtr,a0
		   Jsr       _InstallCopper
;;;
		   Rts

Fastest_Counter:
;;; "                 Add Counters"
AddCounters:       ;Add.l     #1,Fastest_Angle
		   ;And.l     #1023,Fastest_Angle

		   ;Add.l      #1024,Fastest_XOff
		   ;Add.l      #1024,Fastest_YOff

		   ;Add.l     #4,Zoom
		   ;And.l     #1023,Zoom

		   ;Lea       _Sin1024,a0
		   ;Move.l    Zoom,d0
		   ;Move.w    (a0,d0*2),d3
		   ;Asl.w     #1,d3
		   ;Add.w     #512+DIST,d3
		   ;Move.w    d3,Fastest_Zoom
;;;
		   Rts

Fastest_Main:
;;; "                 Make Adders"
		   Lea       _Sin1024,a0
		   Moveq     #0,d7

		   Move.w    Fastest_Zoom,d3

		   Move.l    Fastest_Angle,d0
		   And.l     #1023,d0
		   Move.w    (a0,d0*2),d1
		   Muls.w    d3,d1
		   Asr.l     #8,d1
		   Addx.l    d7,d1

		   Add.l     #256,d0
		   And.l     #1023,d0
		   Move.w    (a0,d0*2),d2
		   Muls.w    d3,d2
		   Asr.l     #8,d2
		   Addx.l    d7,d2

		   Move.l    d2,Yadd1
		   Move.l    d1,Yadd2
		   Move.l    d1,Xadd1
		   Neg.l     d2
		   Move.l    d2,Xadd2
;;;
;;; "                 Make Offset Table"
		   Moveq     #0,d6

		   Move.l    Yadd1,a4
		   Move.l    Yadd2,a5

		   Lea       PlotLop,a0
		   Lea       OffsetTable,a2

		   Moveq     #0,d2
		   Moveq     #0,d1
		   Moveq     #0,d0
		   Move.l    #16-1,d7

MakeTable:         Sub.l     a4,d1
		   Sub.l     a5,d2

		   Move.l    d1,d0
		   Asr.l     #8,d0
		   Addx.l    d6,d0
		   Asl.l     #8,d0

		   Move.l    d2,d3
		   Asr.l     #8,d3
		   Addx.l    d6,d0
		   Move.b    d3,d0
		   Asl.w     #1,d0               ;Words...
		   Move.l    (a2)+,d5            ;Get inst. offset
		   Move.w    d0,(a0,d5)          ;Poke instruction

		   Dbra      d7,MakeTable
;;;
;;; "                 Make Offset Table (16 Steps)"
		   Moveq     #0,d6

		   Move.l    Yadd1,d0
		   Asl.l     #4,d0
		   Move.l    d0,a4
		   Move.l    Yadd2,d0
		   ;Asl.l     #4,d0
		   Move.l    d0,a5

		   Lea       TempTable,a0

		   Moveq     #0,d2
		   Moveq     #0,d1
		   Moveq     #0,d0
		   Move.l    #16-1,d7

MakeTable16:       Add.l     a4,d1
		   Add.l     a5,d2

		   Move.l    d1,d0
		   Asr.l     #8,d0
		   Addx.l    d6,d0
		   Asl.l     #8,d0

		   Move.l    d2,d3
		   Asr.l     #4,d3
		   Addx.l    d6,d0
		   Move.b    d3,d0

		   Asl.w     #1,d0               ;Words...
		   Move.w    d0,(a0)+            ;Poke instruction

		   Dbra      d7,MakeTable16
;;;
;;; "                 Calculate Starting point"
		   Lea       _Sin1024,a0
		   Moveq     #0,d7

		   Move.w    Fastest_Zoom,d3

		   Move.l    Fastest_XOff,d4
		   Move.l    Fastest_YOff,d5

		   ;--------------------------

		   Move.l    Fastest_Angle,d0
		   Add.l     #256,d0
		   And.l     #1023,d0
		   Move.w    (a0,d0*2),d1
		   Muls.w    d3,d1
		   Muls.l    #-160/2,d1

		   Sub.l     #256,d0
		   And.l     #1023,d0
		   Move.w    (a0,d0*2),d2
		   Muls.w    d3,d2
		   Muls.l    #-128/2,d2

		   Add.l     d2,d1
		   Asr.l     #8,d1
		   Addx.l    d7,d1
		   Add.l     d4,d1
		   Move.l    d1,XStart

		   ;--------------------------

		   Move.l    Fastest_Angle,d0
		   Add.l     #0,d0
		   And.l     #1023,d0
		   Move.w    (a0,d0*2),d1
		   Muls.w    d3,d1
		   Muls.l    #-160/2,d1

		   Add.l     #256,d0
		   And.l     #1023,d0
		   Move.w    (a0,d0*2),d2
		   Muls.w    d3,d2
		   Muls.l    #-128/2,d2

		   Sub.l     d2,d1
		   Asr.l     #8,d1
		   Addx.l    d7,d1
		   Add.l     d5,d1
		   Move.l    d1,YStart
;;;
;;; "                 Clear Cache"
		   Move.l    _ExecBase,a6
		   Jsr       _LVOCacheClearU(a6)
		   Nop
;;;
;;; "                 Plot"
		   Move.l    ScrPtr1,a2
		   Move.l    ScrPtr2,a3

		   Move.l    XStart,XCurr1
		   Move.l    YStart,XCurr2

		   Move.l    #128-1,YCount
YLine:
		   Move.l    Xadd2,d1
		   Add.l     d1,XCurr2
		   Move.l    Xadd1,d1
		   Add.l     d1,XCurr1

		   Moveq     #0,d6
		   Move.l    XCurr1,d1
		   Asr.l     #8,d1
		   Addx.l    d6,d1
		   Asl.l     #8,d1

		   Move.l    XCurr2,d0
		   Asr.l     #8,d0
		   Addx.l    d6,d0
		   Move.b    d0,d1
		   Asl.w     #1,d1               ;Words...
		   Move.w    d1,d6

		   Move.l    TexturePtr1,a4
		   Add.l     #256*256,a4
		   Move.l    TexturePtr2,a5
		   Add.l     #256*256,a5

		   Lea       TempTable,a6

		   Move.l    #%00110011001100110011001100110011,d4
		   Move.l    #%11001100110011001100110011001100,d5

		   Move.l    #160/16-1,d7

XLine:             Move.w    (a6)+,d0
		   Add.w     d6,d0

		   Move.l    a4,a0
		   Add.w     d0,a0
		   Move.l    a5,a1
		   Add.w     d0,a1

PlotLop:           Move.w    2(a0),d3
		   Or.w      2(a1),d3
		   Move.b    2(a0),d3
		   Or.b      2(a1),d3
		   Swap      d3
		   Move.w    2(a0),d3
		   Or.w      2(a1),d3
		   Move.b    2(a0),d3
		   Or.b      2(a1),d3

		   Move.w    2(a0),d2
		   Or.w      2(a1),d2
		   Move.b    2(a0),d2
		   Or.b      2(a1),d2
		   Swap      d2
		   Move.w    2(a0),d2
		   Or.w      2(a1),d2
		   Move.b    2(a0),d2
		   Or.b      2(a1),d2

		   ;- - - - - - - - - - - - -

		   Move.l    d2,d1
		   Move.l    d3,d0

		   And.l     d4,d2
		   And.l     d5,d1
		   And.l     d4,d3
		   And.l     d5,d0

		   Lsl.l     #2,d2
		   Lsr.l     #2,d0

		   Or.l      d3,d2
		   Or.l      d0,d1
		   Move.l    d2,(a2)+
		   Move.l    d1,(a3)+

		   Dbra      d7,XLine

		   Subq.l    #1,YCount
		   Bge       YLine
;;;
;;; "                 Screen Swap"
		   Move.l    ScrPtr1,d0
		   Move.l    ViewPtr1,ScrPtr1
		   Move.l    d0,ViewPtr1

		   Move.l    ScrPtr2,d0
		   Move.l    ViewPtr2,ScrPtr2
		   Move.l    d0,ViewPtr2

		   ;--------------------------

		   Move.l    BplPtr,a0
		   Move.l    ViewPtr1,d1
		   Moveq     #2-1,d2
		   Move.l    #0,d0
		   Jsr       _SetPtrs

		   Move.l    BplPtr,a0
		   Lea       16(a0),a0
		   Move.l    ViewPtr2,d1
		   Moveq     #2-1,d2
		   Move.l    #0,d0
		   Jsr       _SetPtrs

		   ;- - - - - - - - - - - - -

		   Move.l    BplPtr2,a0
		   Move.l    ViewPtr1,d1
		   ;Add.l     #40,d1
		   Moveq     #2-1,d2
		   Move.l    #0,d0
		   Jsr       _SetPtrs

		   Move.l    BplPtr2,a0
		   Lea       16(a0),a0
		   Move.l    ViewPtr2,d1
		   ;Add.l     #40,d1
		   Moveq     #2-1,d2
		   Move.l    #0,d0
		   Jsr       _SetPtrs

;;;
		   Rts

Fastest_Remove:
;;; "                 Free Memory"
CloseScreen:       Move.l    #Fastest_ID,d0
		   Jsr       _FreeMany
;;;
		   Rts

***************************************
*                Data...              *
***************************************

;;; "Variables / Tables"
		   Cnop      0,8

Int1:              Dc.l      0

Temp1:             Dc.l      0
Temp2:             Dc.l      0
Temp3:             Dc.l      0
Temp4:             Dc.l      0

YCount:            Dc.l      0

Even:              Dc.l      0
Yadd1:             Dc.l      0
Yadd2:             Dc.l      0
Xadd1:             Dc.l      0
Xadd2:             Dc.l      0

XCurr1:            Dc.l      0
XCurr2:            Dc.l      0
Begin1:            Dc.l      0
Begin2:            Dc.l      0

XStart:            Dc.l      0
YStart:            Dc.l      0

Zoom:              Dc.l      0

Fastest_Angle:     Dc.l      0
Fastest_Zoom:      Dc.l      0
Fastest_XOff:      Dc.l      0
Fastest_YOff:      Dc.l      0

ScrPtr1:           Dc.l      0
ScrPtr2:           Dc.l      0
ViewPtr1:          Dc.l      0
ViewPtr2:          Dc.l      0
Plane5Ptr:         Dc.l      0

CopperPtr:         Dc.l      0
BplPtr:            Dc.l      0
BplPtr2:           Dc.l      0
SprPtr:            Dc.l      0

Sprite1:           Dc.l      0
Sprite2:           Dc.l      0
Sprite3:           Dc.l      0
Sprite4:           Dc.l      0
Sprite5:           Dc.l      0

TexturePtr1:       Dc.l      0
TexturePtr2:       Dc.l      0


OffsetTable:       Dc.l      28,62,32,66,20,54,24,58
		   Dc.l      10,44,14,48, 2,36, 6,40

TempTable:         Dc.w      0,0,0,0,0,0,0,0
		   Dc.w      0,0,0,0,0,0,0,0

ScrambleTable2:    Dc.l      9,1,8,0,11,3,10,2
		   Dc.l      13,5,12,4,15,7,14,6
;;;

		   Section   data,DATA
;;; "Texture"
		   Cnop      0,8
Texture:           Incbin    "!intro:fastest/textures/atomic.4bit"
;;;

