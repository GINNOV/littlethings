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

		   ;------------------

		   xdef      MiniWall_Init
		   xdef      MiniWall_Show
		   xdef      MiniWall_Counter
		   xdef      MiniWall_Main
		   xdef      MiniWall_Remove

;precalc stuff
;-------------
UPP                Equ       128
LOW                Equ       32
DIFF               Equ       UPP-LOW

MUSIC              Equ       0
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

PlayMusic:
		   IFNE      MUSIC
		   Lea       Module,a0       ;Module
		   Sub.l     a1,a1           ;No separate samples
		   Lea       Samples,a2      ;Sample buffer
		   Jsr       _PlayMusic
		   Tst.l     d0
		   Bne       Exit
		   ENDC

		   Bsr       MiniWall_Init
		   Tst.l     d0
		   Bne       StopMusic

		   Bsr       MiniWall_Show

Main:              Bsr       _Sync
		   Bsr       MiniWall_Counter
		   Bsr       MiniWall_Main

		   Btst      #6,$bfe001
		   Bne       Main
.waitlop           Btst      #6,$bfe001
		   Beq       .waitlop

		   Bsr       MiniWall_Remove

StopMusic:
		   IFNE      MUSIC
		   Bsr       _StopMusic
		   ENDC

Exit:              Bsr       _UninitDemo
Exit2:             Moveq     #0,d0
		   Rts
;;;
		   ENDC


***************************************
*   MiniWall-Subrutiner nedanför....  *
***************************************

MiniWall_Init:
;;; "                 Allocate and init copperlist"
AllocCopper:       Move.l    #32*1024,d0                   ;Should be enough
							   ;for copper list.
		   Move.l    #PowerWall_ID,d1
		   Bsr       _AllocChip
		   Move.l    d0,CopperPtr
		   Beq       InitError

InitCopper:        Move.l    d0,a0

		   ;Basic Stuff...
		   ;--------------
		   Move.l    #$008e2c81,(a0)+    ; DIWSTRT
		   Move.l    #$00902cc1,(a0)+    ; DIWSTOP
		   Move.l    #$00920038,(a0)+    ; DDFSTRT
		   Move.l    #$009400d0,(a0)+    ; DDFSTOP
		   Move.l    #$0100c201,(a0)+    ; BPLCON0
		   Move.l    #$01020000,(a0)+    ; BPLCON1
		   Move.l    #$01040000,(a0)+    ; BPLCON2
		   Move.l    #$01060020,(a0)+    ; BPLCON3 ($0020 = copborder)
		   Move.l    #$01fc0003,(a0)+    ; FETCHMODE

		   Move.w    #$0108,(a0)+         ;Modulo
		   Move.w    #-88,(a0)+
		   Move.w    #$010a,(a0)+         ;Modulo
		   Move.w    #-88,(a0)+

		   ;Sprite pointers
		   ;---------------
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

		   Move.l    #$2a01fffe,(a0)+     ;Wait line $2A

		   ;Bitplane pointers
		   ;-----------------
		   Move.l    a0,BplPtr0
		   Move.l    #$00e00000,(a0)+     ; BPLxPTH
		   Move.l    #$00e20000,(a0)+     ; BPLxPTL
		   Move.l    #$00e40000,(a0)+     ; BPLxPTH
		   Move.l    #$00e60000,(a0)+     ; BPLxPTL
		   Move.l    #$00e80000,(a0)+     ; BPLxPTH
		   Move.l    #$00ea0000,(a0)+     ; BPLxPTL
		   Move.l    #$00ec0000,(a0)+     ; BPLxPTH
		   Move.l    #$00ee0000,(a0)+     ; BPLxPTL

		   ;Copperlist for every line (1)
		   ;-----------------------------
Lines1:            Move.l    a0,BplPtr
		   Moveq     #$2b,d0
		   Move.w    #213-1,d1
.lop1
		   Move.l    d0,d2
		   Lsl.l     #8,d2
		   Addq.l    #1,d2
		   Swap      d2
		   Move.w    #$fffe,d2
		   Move.l    d2,(a0)+

		   Move.w    #$0108,(a0)+         ;Modulo
		   Move.w    #-88,(a0)+
		   Move.w    #$010a,(a0)+         ;Modulo
		   Move.w    #-88,(a0)+

		   Move.w    #16-1,d2
		   Move.w    #$180,d3

.lop2              Move.w    d3,(a0)+
		   Move.w    #0,(a0)+
		   Addq.w    #2,d3
		   Dbra      d2,.lop2

		   Addq.l    #1,d0
		   Dbra      d1,.lop1

		   Move.l    #$ffdffffe,(a0)+     ;Copper wraps

		   ;Copperlist for every line (2)
		   ;-----------------------------
Lines2:            Move.l    a0,BplPtr2
		   Moveq     #$00,d0
		   Move.w    #44-1,d1
.lop1
		   Move.l    d0,d2
		   Lsl.l     #8,d2
		   Addq.l    #1,d2
		   Swap      d2
		   Move.w    #$fffe,d2
		   Move.l    d2,(a0)+

		   Move.w    #$0108,(a0)+         ;Modulo
		   Move.w    #-88,(a0)+
		   Move.w    #$010a,(a0)+         ;Modulo
		   Move.w    #-88,(a0)+

		   Move.w    #16-1,d2
		   Move.w    #$180,d3

.lop2              Move.w    d3,(a0)+
		   Move.w    #0,(a0)+
		   Addq.w    #2,d3
		   Dbra      d2,.lop2

		   Addq.l    #1,d0
		   Dbra      d1,.lop1

		   Move.l    #$fffffffe,(a0)+
;;;
;;; "                 Allocate Basepicture memory"
AllocBasePic:      Move.l    #80*256*4,d0

		   Move.l    #PowerWall_ID,d1
		   Bsr       _AllocChip
		   Move.l    d0,BasePicPtr
		   Beq       InitError
;;;
;;; "                 Init Screen (Ptrs & Copperlists)"
InitScreen:        Move.l    BplPtr0,a0
		   Move.l    BasePicPtr,d1
		   Moveq     #3,d2
		   Move.l    #10240*2,d0
		   Bsr       _SetPtrs

		   Lea       ObeyBpl,a0
		   Move.l    #ObeyPic,d1
		   Moveq     #0,d2
		   Move.l    #10240,d0
		   Bsr       _SetPtrs

		   Move.l    SprPtr,a0
		   Move.l    #SpriteDummy,d1
		   Moveq     #7,d2
		   Moveq     #0,d0
		   Bsr       _SetPtrs
;;;
;;; "                 PreCalc"
		   Move.w    #255,Counter
PreMain:
PreCalc:           Move.l    #UPP*256,d5
		   Move.w    Counter,d1
		   Muls.w    #DIFF,d1
		   Sub.l     d1,d5

		   ;-----------------------

		   Lea       .table,a2
		   Lea       PreCalcTable,a1
		   Move.l    BasePicPtr,a4
		   Move.l    #639,d0
		   Moveq     #0,d7
		   Move.l    #320,d6

.lop               Move.l    d0,d1
		   Sub.l     d6,d1
		   Asl.l     #8,d1
		   Asl.l     #8,d1
		   Divs.l    d5,d1
		   Asr.l     #4,d1
		   Addx.l    d7,d1
		   Add.l     d6,d1

		   Divu.w    #30,d1
		   Swap      d1

		   ;----- Sätt pixel ------

		   Move.l    a4,a0
		   Move.w    #255+1,d3
		   Sub.w     Counter,d3
		   Move.w    d3,d4
		   Lsl.w     #6,d3
		   Lsl.w     #4,d4
		   Add.w     d4,d3

		   Move.l    d0,d4
		   Lsr.l     #3,d4
		   Sub.l     d4,d3
		   Subq.l    #1,d3
		   Add.l     d3,a0

		   Move.w    (a1,d1.w*2),d2

		   ;-----------------------
		   Moveq     #1,d3
		   Move.l    d0,d4
		   Rol.b     d4,d3

		   Move.l    #10240*2,d4

		   Move.l    (a2,d2.w*4),a3
		   Jmp       (a3)

.table             Dc.l      .0,.1,.2,.3,.4,.5,.6,.7,.8,.9
		   Dc.l      .10,.11,.12,.13,.14,.15

.12:               Add.l     d4,a0
		   Or.b      d3,(a0,d4)
		   Or.b      d3,(a0,d4*2)
		   Bra       .done

.13:               Or.b      d3,(a0)
		   Or.b      d3,(a0,d4*2)
		   Add.l     d4,a0
		   Or.b      d3,(a0,d4*2)
		   Bra       .done

.10:               Add.l     d4,a0
		   Or.b      d3,(a0)
		   Or.b      d3,(a0,d4*2)
		   Bra       .done

.5:                Or.b      d3,(a0)
.4:                Or.b      d3,(a0,d4*2)
		   Bra       .done

.11:               Or.b      d3,(a0,d4)
.9:                Or.b      d3,(a0)
.8:                Add.l     d4,a0
		   Or.b      d3,(a0,d4*2)
		   Bra       .done

.14:               Add.l     d4,a0
		   Or.b      d3,(a0)
.6:                Add.l     d4,a0
		   Or.b      d3,(a0)
.2:                Or.b      d3,(a0,d4)
		   Bra       .done

.15:               Or.b      d3,(a0)
		   Add.l     d4,a0
.7:                Or.b      d3,(a0)
		   Add.l     d4,a0
.3:                Or.b      d3,(a0,d4)
.1:                Or.b      d3,(a0)
.0:
.done
		   Dbra      d0,.lop

		   Subq.w    #1,Counter
		   Bge       PreMain

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

MiniWall_Show:     Move.l    CopperPtr,a0
		   Bsr       _InstallCopper
		   Rts

MiniWall_Counter:
;;; "                 Counters"
SyncIt:
		   Lea       Custom,a5

		   Lea       Table1,a0
		   Move.l    a0,TablePtr1
		   Lea       Table2,a0
		   Move.l    a0,TablePtr2
		   Lea       Table3,a0
		   Move.l    a0,TablePtr3
		   Lea       Table4,a0
		   Move.l    a0,TablePtr4

		   Move.w    E8,d0
		   Move.w    P61_E8,d1
		   Move.w    d1,E8
		   Cmp.w     d1,d0
		   Beq       .skip

		   ;Move.l    #4,Event

.skip              Tst.l     Event
		   Beq       .ok
		   Subq.l    #1,Event
.ok

		   Add.l     #4,Co
		   And.l     #1023,Co

		   Add.l     #5,Co2
		   And.l     #1023,Co2

		   Add.l     #3,Co3
		   And.l     #1023,Co3
;;;
		   Rts

MiniWall_Main:
;;; "                 Events"
		   Cmp.l     #2,Event
		   Blt       .noevent1
		   Sub.l     #100,Co
		   Lea       Copper2,a0
		   Bsr       _InstallCopper
		   Move.w    #$fff,$dff180
		   Move.w    #$ccc,$dff182
		   Bra       .noevent3

.noevent1          Cmp.l     #1,Event
		   Bne       .noevent2
		   Move.w    #$000,$dff180
		   Move.w    #$000,$dff182
		   Bra       .noevent3

.noevent2          Move.l    CopperPtr,a0
		   Bsr       _InstallCopper
.noevent3
;;;
;;; "                 Ptr 1"
		   Clr.l     Vert
		   Lea       _Sin1024,a0
		   Move.l    BplPtr,a3
		   Move.l    TablePtr1,a2
		   Move.l    Co,d0
		   Move.l    #212,d1

		   ;--------------------

		   Move.l    d1,d3
		   Sub.l     d0,d3
		   Add.l     Co2,d3
		   Asl.l     #1,d3
		   And.l     #1023,d3
		   Move.w    (a0,d3.l*2),d2
		   Ext.l     d2
		   Add.l     d0,d2
		   Add.l     Co2,d2
		   ;Add.l     d1,d2
		   Add.l     d1,d2
		   Add.l     Co3,d2
		   And.l     #1023,d2

		   Move.w    (a0,d2.l*2),d7
		   Asr.w     #1,d7
		   Add.w     #128,d7
		   Move.w    d7,Pos
		   Muls.w    #80,d7

		   Move.l    BplPtr0,a0
		   Move.l    BasePicPtr,d1
		   Add.l     d7,d1
		   Moveq     #3,d2
		   Move.l    #10240*2,d0
		   Bsr       _SetPtrs

		   Lea       _Sin1024,a0
		   Move.l    BplPtr,a3
		   Lea       Table1,a2
		   Move.l    Co,d0
		   Move.l    #212,d1

		   ;----------------
PtrLoop:
		   Move.l    d1,d3
		   Sub.l     d0,d3
		   Add.l     Co2,d3
		   Asl.l     #1,d3
		   And.l     #1023,d3
		   Move.w    (a0,d3.l*2),d2
		   Ext.l     d2
		   Add.l     d0,d2
		   Add.l     Co2,d2
		   ;Add.l     d1,d2
		   Add.l     d1,d2
		   Add.l     Co3,d2
		   And.l     #1023,d2

		   Move.w    (a0,d2.l*2),d7
		   Asr.w     #1,d7
		   Add.w     #128,d7
		   Move.w    d7,d5
		   Move.w    #255+100,d2
		   Sub.w     d7,d2
		   Lsr.w     #4,d2
		   Add.w     d2,Vert
		   And.w     #255,Vert

		   ;------------------------

		   Move.w    Pos,d2
		   Move.w    d7,Pos              ;Store this position
		   Sub.w     d2,d7

		   Muls.w    #80,d7
		   Sub.l     #88,d7

		   Move.w    d7,6(a3)            ;Change modulos
		   Move.w    d7,10(a3)           ;Change modulos

		   ;------------------

		   Lsr.w     #4,d5
		   Lsl.w     #1,d5

		   Move.w    Vert,d2
		   Move.l    TablePtr1,a2
		   Cmp.w     #192,d2
		   Bgt       .skip
		   Move.l    TablePtr2,a2
		   Cmp.w     #128,d2
		   Bgt       .skip
		   Move.l    TablePtr3,a2
		   Cmp.w     #64,d2
		   Bgt       .skip
		   Move.l    TablePtr4,a2
.skip
		   Move.w    32*0(a2,d5.w),14(a3)
		   Move.w    32*1(a2,d5.w),18(a3)
		   Move.w    32*2(a2,d5.w),22(a3)
		   Move.w    32*3(a2,d5.w),26(a3)
		   Move.w    32*4(a2,d5.w),30(a3)
		   Move.w    32*5(a2,d5.w),34(a3)
		   Move.w    32*6(a2,d5.w),38(a3)
		   Move.w    32*7(a2,d5.w),42(a3)

		   Move.w    32*8(a2,d5.w),46(a3)
		   Move.w    32*9(a2,d5.w),50(a3)
		   Move.w    32*10(a2,d5.w),54(a3)
		   Move.w    32*11(a2,d5.w),58(a3)
		   Move.w    32*12(a2,d5.w),62(a3)
		   Move.w    32*13(a2,d5.w),66(a3)
		   Move.w    32*14(a2,d5.w),70(a3)
		   Move.w    32*15(a2,d5.w),74(a3)

		   Lea       19*4(a3),a3

		   Dbra      d1,PtrLoop
;;;
;;; "                 Ptr 2"
		   Move.l    BplPtr2,a3
		   Move.l    #43,d1
PtrLoop2:
		   Move.l    d1,d3
		   Sub.l     d0,d3
		   Add.l     Co2,d3
		   Sub.l     #44,d3
		   Asl.l     #1,d3
		   And.l     #1023,d3
		   Move.w    (a0,d3.l*2),d2
		   Ext.l     d2
		   Add.l     d0,d2
		   Add.l     Co2,d2
		   Add.l     d1,d2
		   ;Add.l     d1,d2
		   Sub.l     #44*1,d2
		   Add.l     Co3,d2
		   And.l     #1023,d2

		   Move.w    (a0,d2.l*2),d7
		   Asr.w     #1,d7
		   Add.w     #128,d7
		   Move.w    d7,d5
		   Move.w    #255+100,d2
		   Sub.w     d7,d2
		   Lsr.w     #4,d2
		   Add.w     d2,Vert
		   And.w     #255,Vert

		   ;------------------------

		   Move.w    Pos,d2
		   Move.w    d7,Pos              ;Store this position
		   Sub.w     d2,d7

		   Muls.w    #80,d7
		   Sub.l     #88,d7

		   Move.w    d7,6(a3)            ;Change modulos
		   Move.w    d7,10(a3)           ;Change modulos

		   ;------------------

		   Lsr.w     #4,d5
		   Lsl.w     #1,d5

		   Move.w    Vert,d2
		   Move.l    TablePtr1,a2
		   Cmp.w     #192,d2
		   Bgt       .skip
		   Move.l    TablePtr2,a2
		   Cmp.w     #128,d2
		   Bgt       .skip
		   Move.l    TablePtr3,a2
		   Cmp.w     #64,d2
		   Bgt       .skip
		   Move.l    TablePtr4,a2
.skip
		   Move.w    32*0(a2,d5.w),14(a3)
		   Move.w    32*1(a2,d5.w),18(a3)
		   Move.w    32*2(a2,d5.w),22(a3)
		   Move.w    32*3(a2,d5.w),26(a3)
		   Move.w    32*4(a2,d5.w),30(a3)
		   Move.w    32*5(a2,d5.w),34(a3)
		   Move.w    32*6(a2,d5.w),38(a3)
		   Move.w    32*7(a2,d5.w),42(a3)

		   Move.w    32*8(a2,d5.w),46(a3)
		   Move.w    32*9(a2,d5.w),50(a3)
		   Move.w    32*10(a2,d5.w),54(a3)
		   Move.w    32*11(a2,d5.w),58(a3)
		   Move.w    32*12(a2,d5.w),62(a3)
		   Move.w    32*13(a2,d5.w),66(a3)
		   Move.w    32*14(a2,d5.w),70(a3)
		   Move.w    32*15(a2,d5.w),74(a3)

		   Lea       19*4(a3),a3

		   Dbra      d1,PtrLoop2
;;;
		   Rts

MiniWall_Remove:
;;; "                 Free Memory"
FreeMemory:        Move.l    #PowerWall_ID,d0
		   Bsr       _FreeMany
;;;
		   Rts


***************************************
*          MiniWall data...          *
***************************************

;;; "Variables & Data"
E8:                Dc.l      0

Co:                Dc.l      0
Co2:               Dc.l      0
Co3:               Dc.l      0
Vert:              Dc.l      0

BasePicPtr:        Dc.l      0
CopperPtr:         Dc.l      0
SprPtr:            Dc.l      0
BplPtr0:           Dc.l      0
BplPtr:            Dc.l      0
BplPtr2:           Dc.l      0

TablePtr1:         Dc.l      0
TablePtr2:         Dc.l      0
TablePtr3:         Dc.l      0
TablePtr4:         Dc.l      0

Event:             Dc.l      0
Counter:           Dc.w      0
Pos:               Dc.w      0

PreCalcTable:      Dc.w      0,1,2,3,4,5,6,7,8,9,10,11,12,13,14
		   Dc.w      15,14,13,12,11,10,9,8,7,6,5,4,3,2,1
;;;
;;; "Table 1-4"
Table1:            Dc.w      $00f,$11f,$22f,$33f
		   Dc.w      $44f,$55f,$66f,$77f
		   Dc.w      $88f,$99f,$aaf,$bbf
		   Dc.w      $ccf,$ddf,$eef,$fff

		   Dc.w      $000,$100,$211,$322
		   Dc.w      $433,$544,$655,$766
		   Dc.w      $877,$988,$a99,$baa
		   Dc.w      $cbb,$dcc,$edd,$fee

		   Dc.w      $000,$100,$200,$311
		   Dc.w      $422,$533,$644,$755
		   Dc.w      $866,$977,$a88,$b99
		   Dc.w      $caa,$dbb,$ecc,$fdd

		   Dc.w      $000,$100,$200,$300
		   Dc.w      $411,$522,$633,$744
		   Dc.w      $855,$966,$a77,$b88
		   Dc.w      $c99,$daa,$ebb,$fcc

		   Dc.w      $000,$100,$200,$300
		   Dc.w      $400,$511,$622,$733
		   Dc.w      $844,$955,$a66,$b77
		   Dc.w      $c88,$d99,$eaa,$fbb

		   Dc.w      $000,$100,$200,$300
		   Dc.w      $400,$500,$611,$722
		   Dc.w      $833,$944,$a55,$b66
		   Dc.w      $c77,$d88,$e99,$faa

		   Dc.w      $000,$100,$200,$300
		   Dc.w      $400,$500,$600,$711
		   Dc.w      $822,$933,$a44,$b55
		   Dc.w      $c66,$d77,$e88,$f99

		   Dc.w      $000,$100,$200,$300
		   Dc.w      $400,$500,$600,$700
		   Dc.w      $811,$922,$a33,$b44
		   Dc.w      $c55,$d66,$e77,$f88


		   Dc.w      $000,$100,$200,$300
		   Dc.w      $400,$500,$600,$700
		   Dc.w      $800,$911,$a22,$b33
		   Dc.w      $c44,$d55,$e66,$f77

		   Dc.w      $000,$100,$200,$300
		   Dc.w      $400,$500,$600,$700
		   Dc.w      $800,$900,$a11,$b22
		   Dc.w      $c33,$d44,$e55,$f66

		   Dc.w      $000,$100,$200,$300
		   Dc.w      $400,$500,$600,$700
		   Dc.w      $800,$900,$a00,$b11
		   Dc.w      $c22,$d33,$e44,$f55

		   Dc.w      $000,$100,$200,$300
		   Dc.w      $400,$500,$600,$700
		   Dc.w      $800,$900,$a00,$b00
		   Dc.w      $c11,$d22,$e33,$f44

		   Dc.w      $000,$100,$200,$300
		   Dc.w      $400,$500,$600,$700
		   Dc.w      $800,$900,$a00,$b00
		   Dc.w      $c00,$d11,$e22,$f33

		   Dc.w      $000,$100,$200,$300
		   Dc.w      $400,$500,$600,$700
		   Dc.w      $800,$900,$a00,$b00
		   Dc.w      $c00,$d00,$e11,$f22

		   Dc.w      $000,$100,$200,$300
		   Dc.w      $400,$500,$600,$700
		   Dc.w      $800,$900,$a00,$b00
		   Dc.w      $c00,$d00,$e00,$f11

		   Dc.w      $006,$106,$205,$305
		   Dc.w      $404,$504,$603,$703
		   Dc.w      $802,$902,$a01,$b01
		   Dc.w      $c00,$d00,$e00,$f00


Table2:            Dc.w      $00f,$10f,$20f,$30f
		   Dc.w      $40f,$50f,$60f,$70f
		   Dc.w      $80f,$91f,$a2f,$b3f
		   Dc.w      $c4f,$d5f,$e6f,$f7f

		   Dc.w      $000,$100,$200,$300
		   Dc.w      $400,$500,$600,$700
		   Dc.w      $800,$900,$a11,$b22
		   Dc.w      $c33,$d44,$e55,$f66

		   Dc.w      $000,$100,$200,$300
		   Dc.w      $400,$500,$600,$700
		   Dc.w      $800,$900,$a00,$b11
		   Dc.w      $c22,$d33,$e44,$f55

		   Dc.w      $000,$100,$200,$300
		   Dc.w      $400,$500,$600,$700
		   Dc.w      $800,$900,$a00,$b00
		   Dc.w      $c11,$d22,$e33,$f44

		   Dc.w      $000,$100,$200,$300
		   Dc.w      $400,$500,$600,$700
		   Dc.w      $800,$900,$a00,$b00
		   Dc.w      $c00,$d11,$e22,$f33

		   Dc.w      $000,$100,$200,$300
		   Dc.w      $400,$500,$600,$700
		   Dc.w      $800,$900,$a00,$b00
		   Dc.w      $c00,$d00,$e11,$f22

		   Dc.w      $000,$100,$200,$300
		   Dc.w      $400,$500,$600,$700
		   Dc.w      $800,$900,$a00,$b00
		   Dc.w      $c00,$d00,$e00,$f11

		   Dc.w      $006,$106,$205,$305
		   Dc.w      $404,$504,$603,$703
		   Dc.w      $802,$902,$a01,$b01
		   Dc.w      $c00,$d00,$e00,$f00

		   Dc.w      $00f,$11f,$22f,$33f
		   Dc.w      $44f,$55f,$66f,$77f
		   Dc.w      $88f,$99f,$aaf,$bbf
		   Dc.w      $ccf,$ddf,$eef,$fff

		   Dc.w      $000,$100,$211,$322
		   Dc.w      $433,$544,$655,$766
		   Dc.w      $877,$988,$a99,$baa
		   Dc.w      $cbb,$dcc,$edd,$fee

		   Dc.w      $000,$100,$200,$311
		   Dc.w      $422,$533,$644,$755
		   Dc.w      $866,$977,$a88,$b99
		   Dc.w      $caa,$dbb,$ecc,$fdd

		   Dc.w      $000,$100,$200,$300
		   Dc.w      $411,$522,$633,$744
		   Dc.w      $855,$966,$a77,$b88
		   Dc.w      $c99,$daa,$ebb,$fcc

		   Dc.w      $000,$100,$200,$300
		   Dc.w      $400,$511,$622,$733
		   Dc.w      $844,$955,$a66,$b77
		   Dc.w      $c88,$d99,$eaa,$fbb

		   Dc.w      $000,$100,$200,$300
		   Dc.w      $400,$500,$611,$722
		   Dc.w      $833,$944,$a55,$b66
		   Dc.w      $c77,$d88,$e99,$faa

		   Dc.w      $000,$100,$200,$300
		   Dc.w      $400,$500,$600,$711
		   Dc.w      $822,$933,$a44,$b55
		   Dc.w      $c66,$d77,$e88,$f99

		   Dc.w      $000,$100,$200,$300
		   Dc.w      $400,$500,$600,$700
		   Dc.w      $811,$922,$a33,$b44
		   Dc.w      $c55,$d66,$e77,$f88


Table3:            Dc.w      $00f,$10f,$20f,$30f
		   Dc.w      $40f,$50f,$61f,$72f
		   Dc.w      $83f,$94f,$a5f,$b6f
		   Dc.w      $c7f,$d8f,$e9f,$faf

		   Dc.w      $000,$100,$200,$300
		   Dc.w      $400,$500,$600,$711
		   Dc.w      $822,$933,$a44,$b55
		   Dc.w      $c66,$d77,$e88,$f99

		   Dc.w      $000,$100,$200,$300
		   Dc.w      $400,$500,$600,$700
		   Dc.w      $811,$922,$a33,$b44
		   Dc.w      $c55,$d66,$e77,$f88

		   Dc.w      $000,$100,$200,$300
		   Dc.w      $400,$500,$600,$700
		   Dc.w      $800,$911,$a22,$b33
		   Dc.w      $c44,$d55,$e66,$f77

		   Dc.w      $000,$100,$200,$300
		   Dc.w      $400,$500,$600,$700
		   Dc.w      $800,$900,$a11,$b22
		   Dc.w      $c33,$d44,$e55,$f66

		   Dc.w      $000,$100,$200,$300
		   Dc.w      $400,$500,$600,$700
		   Dc.w      $800,$900,$a00,$b11
		   Dc.w      $c22,$d33,$e44,$f55

		   Dc.w      $000,$100,$200,$300
		   Dc.w      $400,$500,$600,$700
		   Dc.w      $800,$900,$a00,$b00
		   Dc.w      $c11,$d22,$e33,$f44

		   Dc.w      $000,$100,$200,$300
		   Dc.w      $400,$500,$600,$700
		   Dc.w      $800,$900,$a00,$b00
		   Dc.w      $c00,$d11,$e22,$f33

		   Dc.w      $000,$100,$200,$300
		   Dc.w      $400,$500,$600,$700
		   Dc.w      $800,$900,$a00,$b00
		   Dc.w      $c00,$d00,$e11,$f22

		   Dc.w      $000,$100,$200,$300
		   Dc.w      $400,$500,$600,$700
		   Dc.w      $800,$900,$a00,$b00
		   Dc.w      $c00,$d00,$e00,$f11

		   Dc.w      $006,$106,$205,$305
		   Dc.w      $404,$504,$603,$703
		   Dc.w      $802,$902,$a01,$b01
		   Dc.w      $c00,$d00,$e00,$f00

		   Dc.w      $00f,$11f,$22f,$33f
		   Dc.w      $44f,$55f,$66f,$77f
		   Dc.w      $88f,$99f,$aaf,$bbf
		   Dc.w      $ccf,$ddf,$eef,$fff

		   Dc.w      $000,$100,$211,$322
		   Dc.w      $433,$544,$655,$766
		   Dc.w      $877,$988,$a99,$baa
		   Dc.w      $cbb,$dcc,$edd,$fee

		   Dc.w      $000,$100,$200,$311
		   Dc.w      $422,$533,$644,$755
		   Dc.w      $866,$977,$a88,$b99
		   Dc.w      $caa,$dbb,$ecc,$fdd

		   Dc.w      $000,$100,$200,$300
		   Dc.w      $411,$522,$633,$744
		   Dc.w      $855,$966,$a77,$b88
		   Dc.w      $c99,$daa,$ebb,$fcc

		   Dc.w      $000,$100,$200,$300
		   Dc.w      $400,$511,$622,$733
		   Dc.w      $844,$955,$a66,$b77
		   Dc.w      $c88,$d99,$eaa,$fbb


Table4:            Dc.w      $00f,$10f,$20f,$30f
		   Dc.w      $40f,$50f,$60f,$70f
		   Dc.w      $80f,$90f,$a0f,$b0f
		   Dc.w      $c0f,$d1f,$e2f,$f3f

		   Dc.w      $000,$100,$200,$300
		   Dc.w      $400,$500,$600,$700
		   Dc.w      $800,$900,$a00,$b00
		   Dc.w      $c00,$d00,$e11,$f22

		   Dc.w      $000,$100,$200,$300
		   Dc.w      $400,$500,$600,$700
		   Dc.w      $800,$900,$a00,$b00
		   Dc.w      $c00,$d00,$e00,$f11

		   Dc.w      $000,$100,$200,$300
		   Dc.w      $400,$500,$611,$722
		   Dc.w      $833,$944,$a55,$b66
		   Dc.w      $c77,$d88,$e99,$faa

		   Dc.w      $000,$100,$200,$300
		   Dc.w      $400,$500,$600,$711
		   Dc.w      $822,$933,$a44,$b55
		   Dc.w      $c66,$d77,$e88,$f99

		   Dc.w      $000,$100,$200,$300
		   Dc.w      $400,$500,$600,$700
		   Dc.w      $811,$922,$a33,$b44
		   Dc.w      $c55,$d66,$e77,$f88

		   Dc.w      $000,$100,$200,$300
		   Dc.w      $400,$500,$600,$700
		   Dc.w      $800,$911,$a22,$b33
		   Dc.w      $c44,$d55,$e66,$f77

		   Dc.w      $000,$100,$200,$300
		   Dc.w      $400,$500,$600,$700
		   Dc.w      $800,$900,$a11,$b22
		   Dc.w      $c33,$d44,$e55,$f66

		   Dc.w      $000,$100,$200,$300
		   Dc.w      $400,$500,$600,$700
		   Dc.w      $800,$900,$a00,$b11
		   Dc.w      $c22,$d33,$e44,$f55

		   Dc.w      $000,$100,$200,$300
		   Dc.w      $400,$500,$600,$700
		   Dc.w      $800,$900,$a00,$b00
		   Dc.w      $c11,$d22,$e33,$f44

		   Dc.w      $006,$106,$205,$305
		   Dc.w      $404,$504,$603,$703
		   Dc.w      $802,$902,$a01,$b01
		   Dc.w      $c00,$d00,$e00,$f00

		   Dc.w      $00f,$11f,$22f,$33f
		   Dc.w      $44f,$55f,$66f,$77f
		   Dc.w      $88f,$99f,$aaf,$bbf
		   Dc.w      $ccf,$ddf,$eef,$fff

		   Dc.w      $000,$100,$211,$322
		   Dc.w      $433,$544,$655,$766
		   Dc.w      $877,$988,$a99,$baa
		   Dc.w      $cbb,$dcc,$edd,$fee

		   Dc.w      $000,$100,$200,$311
		   Dc.w      $422,$533,$644,$755
		   Dc.w      $866,$977,$a88,$b99
		   Dc.w      $caa,$dbb,$ecc,$fdd

		   Dc.w      $000,$100,$200,$300
		   Dc.w      $411,$522,$633,$744
		   Dc.w      $855,$966,$a77,$b88
		   Dc.w      $c99,$daa,$ebb,$fcc

		   Dc.w      $000,$100,$200,$300
		   Dc.w      $400,$511,$622,$733
		   Dc.w      $844,$955,$a66,$b77
		   Dc.w      $c88,$d99,$eaa,$fbb
;;;
		   Section   chipdata,DATA_C
;;; "ObeyPic"
ObeyPic:           ;Incbin    "!projects:powerwall/obeypwl.raw"
;;;
;;; "Obey Copperlist!"
Copper2:           Dc.w      $008e,$2c81     ; DIWSTRT
		   Dc.w      $0090,$2cc1     ; DIWSTOP
		   Dc.w      $0092,$0038     ; DDFSTRT
		   Dc.w      $0094,$00d0     ; DDFSTOP
		   Dc.w      $0100,$1201     ; BPLCON0
		   Dc.w      $0102,$0000     ; BPLCON1
		   Dc.w      $0104,$0000     ; BPLCON2
		   Dc.w      $0106,$0000     ; BPLCON3 ($0020 = copborder)
		   Dc.w      $0108,-8        ; BPLMOD1
		   Dc.w      $010a,-8        ; BPLMOD2
		   Dc.w      $01fc,$0003     ; FETCHMODE

ObeyBpl:           Dc.w      $00e0,$0000     ; BPL1PTH
		   Dc.w      $00e2,$0000     ; BPL1PTL

		   Dc.w      $ffff,$fffe
;;;
;;; "Music"
		   IFND      noexample
		   IFNE      MUSIC
Module:            Incbin    "!projects:Loader/P61.57remixMINI"

		   Section   Samples,bss_c
Samples:           Ds.b      34762
		   ENDC
		   ENDC
;;;
