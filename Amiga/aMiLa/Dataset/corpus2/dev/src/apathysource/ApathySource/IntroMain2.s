		   Machine   68020

;;; "                 Includes"
		   Incdir    "!Includes:"
		   Include   "StdLibInc.i"
		   Include   "StdHardInc.i"
		   Include   "Screens.i"
		   Include   "Loader.i"
		   Include   "Support.i"

		   Incdir    "!intro:"
		   Include   "introMain.i"
;;;
;;; "                 Defines"
IntroMain_ID       Equ       42
FadeBuffSize       Equ       8*1024
;;;

		   xref      Texture

		   xref      _InitFade
		   xref      _DoFade

		   xref      _InitSinus
		   xref      _InitSinus2

***********************************************************

		   Section   code,CODE

;;; "                 Init (IconStartup & _InitDemo"
Init:              Bsr       _Startup            ;Iconstartup

		   Bsr       _InitDemo
		   Tst.l     d0
		   Bne       Exit

		   Bsr       _InitSinus
;;;
;;; "                 PreCalcing"
		   Bsr       Fastest_Init
		   Tst.l     d0
		   Bne       RunDown

		   Bsr       DotTunnel_Init
		   Tst.l     d0
		   Bne       RunDown

		   Bsr       MiniWall_Init
		   Tst.l     d0
		   Bne       RunDown
;;;
;;; "                 Play Music"
		   Bsr       _PlayMusic
		   Tst.l     d0
		   Bne       Uninit

		   Move.w    #0,P61_Play
;;;

		   Bsr       Intro_Init
		   Tst.l     d0
		   Bne       RunDown

		   Bsr       Intro_Main
		   Tst.l     d0
		   Bne       RunDown

		   Bsr       Intro_Remove

		   ;Move.w    #1,P61_Play

		   ;----------------------------

Loop:              Btst      #2,$dff016
		   Beq       RunDown
		   Cmp.w     #6,P61_Pos
		   Bne       Loop

		   Bsr       Atomic_Init
		   Tst.l     d0
		   Bne       RunDown

		   Bsr       Fastest
		   Tst.l     d0
		   Bne       RunDown

		   Bsr       Atomic_Main
		   Tst.l     d0
		   Bne       RunDown

		   Bsr       MiniWall
		   Tst.l     d0
		   Bne       RunDown

		   Bsr       Write2
		   Tst.l     d0
		   Bne       RunDown

		   Bsr       DotTunnel
		   Tst.l     d0
		   Bne       RunDown

Loop2:             Btst      #2,$dff016
		   Beq       RunDown
		   Cmp.w     #20,P61_Pos
		   Bne       Loop2

		   Bsr       Write3
		   Tst.l     d0
		   Bne       RunDown

		   ;----------------------------

;;; "                 RunDown"
RunDown:           Bsr       _StopMusic
		   Bsr       _FreeAll
Uninit:            Bsr       _UninitDemo
Exit:              Bsr       _Closedown          ;Iconstartup
;;;

		   Moveq     #0,d0
		   Rts

;;; "Effect: Fastest"

Fastest:           Move.l    #256*256,Fastest_Angle2
		   Move.l    #1000*256,Fastest_Zoom2
		   Move.l    #64*256,Fastest_XOff
		   Move.l    #128*256,Fastest_YOff

		   Bsr       Fastest_Show

		   Lea       Fastest_Add,a0
		   Bsr       _AddVBLInt
		   Move.l    d0,Fastest_Int
		   Beq       RunDown

.lop               Bsr       _Sync

		   Bsr       Fastest_Main

		   Cmp.w     #10,P61_Pos
		   Beq       .done

		   Btst      #2,$dff016
		   Beq       .break

		   Tst.l     Fastest_Exit
		   Beq       .lop

.done              Move.l    Fastest_Int,d0
		   Bsr       _RemVBLInt

		   Bsr       Fastest_Remove

		   Moveq     #0,d0
		   Rts

.break             Moveq     #1,d0
		   Rts
;;;
;;; "Fastest_Add"
Fastest_Add:       Lea       Fastest_Story,a0
		   Add.l     Fastest_Curr,a0

		   Tst.l     Fastest_Time
		   Bne       .exit

.newentry          Move.b    (a0)+,d0
		   Extb.l    d0
		   Cmp.l     #-1,d0
		   Bne       .noend
		   Move.l    #1,Fastest_Exit
		   Bra       .exit
.noend             Move.l    d0,Fastest_Time

		   Move.b    (a0)+,d0
		   Extb.l    d0
		   Move.l    d0,Fastest_AngleAdd2

		   Move.b    (a0)+,d0
		   Extb.l    d0
		   Move.l    d0,Fastest_ZoomAdd2

		   Move.b    (a0)+,d0
		   Extb.l    d0
		   Move.l    d0,Fastest_XOffAdd2

		   Move.b    (a0)+,d0
		   Extb.l    d0
		   Move.l    d0,Fastest_YOffAdd2

		   Add.l     #5,Fastest_Curr
.exit              Subq.l    #1,Fastest_Time

		   ;------------------------------

		   Move.l    Fastest_AngleAdd,d0
		   Add.l     d0,Fastest_Angle2
		   Move.l    Fastest_Angle2,d0
		   Asr.l     #8,d0
		   Move.l    d0,Fastest_Angle
		   And.l     #1023,Fastest_Angle

		   Move.l    Fastest_AngleAdd2,d0
		   Add.l     d0,Fastest_AngleAdd


		   Move.l    Fastest_ZoomAdd,d0
		   Add.l     d0,Fastest_Zoom2
		   Move.l    Fastest_Zoom2,d0
		   Asr.l     #8,d0
		   Move.w    d0,Fastest_Zoom

		   Move.l    Fastest_ZoomAdd2,d0
		   Add.l     d0,Fastest_ZoomAdd


		   Move.l    Fastest_XOffAdd,d0
		   Add.l     d0,Fastest_XOff

		   Move.l    Fastest_XOffAdd2,d0
		   Add.l     d0,Fastest_XOffAdd


		   Move.l    Fastest_YOffAdd,d0
		   Add.l     d0,Fastest_YOff

		   Move.l    Fastest_YOffAdd2,d0
		   Add.l     d0,Fastest_YOffAdd

		   Rts
;;;
;;; "Fastest Story"
Fastest_Story:
		   Dc.b      100,1,-3,0,0
		   Dc.b      100,1,-3,0,0
		   Dc.b      100,1,0,2,0
		   Dc.b      100,0,3,3,0
		   Dc.b      100,0,3,4,0
		   Dc.b      100,0,0,4,0
		   Dc.b      100,0,0,5,1
		   Dc.b      70,0,3,5,1
		   Dc.b      100,20,0,10,10
		   Dc.b      100,-5,6,-10,10
		   Dc.b      100,-5,6,-10,10
		   Dc.b      100,-5,-45,-5,-5
		   Dc.b      100,-10,65,0,0
		   Dc.b      70,-30,-55,0,0
		   Dc.b      75,20,65,0,0
		   Dc.b      70,-10,-45,0,0
		   Dc.b      75,-50,25,0,0
		   Dc.b      -1
		   Even
;;;;
;;; "Fastest Vars"
Fastest_Exit:      Dc.l      0
Fastest_Curr:      Dc.l      0
Fastest_Time:      Dc.l      0

Fastest_AngleAdd:  Dc.l      16
Fastest_AngleAdd2: Dc.l      0
Fastest_Angle2:    Dc.l      0

Fastest_ZoomAdd:   Dc.l      0
Fastest_ZoomAdd2:  Dc.l      0
Fastest_Zoom2:     Dc.l      0

Fastest_XOffAdd:   Dc.l      0
Fastest_XOffAdd2:  Dc.l      0

Fastest_YOffAdd:   Dc.l      0
Fastest_YOffAdd2:  Dc.l      0

Fastest_Int:       Dc.l      0
;;;

;;; "Effect: DotTunnel"
DotTunnel:         Move.w    #4,DotTunnel_Speed
		   Move.l    #0*256,DotTunnel_XS2
		   Move.l    #0*256,DotTunnel_YS2

		   Bsr       DotTunnel_Show

.lop               Bsr       _Sync

		   Btst      #2,$dff016
		   Beq       .break

		   Bsr       DotTunnel_Add
		   Bsr       DotTunnel_Counter
		   Bsr       DotTunnel_Main

		   Cmp.w     #20,P61_Pos
		   Beq       .done

		   Tst.l     DotTunnel_Exit
		   Beq       .lop

.done              Bsr       DotTunnel_Remove

		   Moveq     #0,d0
		   Rts

.break             Moveq     #1,d0
		   Rts
;;;
;;; "DotTunnel_Add"
DotTunnel_Add:     Lea       DotTunnel_Story,a0
		   Add.l     DotTunnel_Curr,a0

		   Tst.l     DotTunnel_Time
		   Bne       .exit

.newentry          Move.b    (a0)+,d0
		   Extb.l    d0
		   Cmp.l     #-1,d0
		   Bne       .noend
		   Move.l    #1,DotTunnel_Exit
		   Bra       .exit

.noend             Ext.w     d0
		   Move.w    d0,DotTunnel_Speed

		   Move.l    #16,DotTunnel_Time

		   Move.b    (a0)+,d0
		   Extb.l    d0
		   Move.l    d0,DotTunnel_XS2

		   Move.b    (a0)+,d0
		   Extb.l    d0
		   Move.l    d0,DotTunnel_YS2

		   Add.l     #3,DotTunnel_Curr

		   ;-----------------------------

.exit              Move.w    DotTunnel_Old,d0
		   Move.w    P61_CRow,d1
		   Cmp.w     d0,d1
		   Beq       .donesync
		   Subq.l    #1,DotTunnel_Time
.donesync          Move.w    d1,DotTunnel_Old

		   ;------------------------------

		   Move.l    DotTunnel_XSAdd,d0
		   Add.l     d0,DotTunnel_XS2
		   Move.l    DotTunnel_XS2,d0
		   ;Asr.l     #8,d0
		   Move.w    d0,DotTunnel_XS

		   Move.l    DotTunnel_XSAdd2,d0
		   Add.l     d0,DotTunnel_XSAdd


		   Move.l    DotTunnel_YSAdd,d0
		   Add.l     d0,DotTunnel_YS2
		   Move.l    DotTunnel_YS2,d0
		   ;Asr.l     #8,d0
		   Move.w    d0,DotTunnel_YS

		   Move.l    DotTunnel_YSAdd2,d0
		   Add.l     d0,DotTunnel_YSAdd

		   Rts
;;;
;;; "DotTunnel Story"
DotTunnel_Story:   Dc.b      4,37,3
		   Dc.b      4,21,37
		   Dc.b      4,13,36
		   Dc.b      4,24,5
		   Dc.b      4,17,26
		   Dc.b      4,13,26
		   Dc.b      4,24,10
		   Dc.b      4,17,26
		   Dc.b      4,23,36
		   Dc.b      4,34,30
		   Dc.b      4,27,16
		   Dc.b      4,27,16
		   Dc.b      4,34,10
		   Dc.b      4,17,6
		   Dc.b      4,13,26
		   Dc.b      4,24,34
		   Dc.b      4,27,16
		   Dc.b      4,27,36
		   Dc.b      4,14,20
		   Dc.b      4,27,16
		   Dc.b      4,20,26
		   Dc.b      4,34,35
		   Dc.b      4,16,16
		   Dc.b      4,33,36

		   Dc.b      -1
		   Even
;;;;
;;; "DotTunnel Vars"
DotTunnel_Fade:    Dc.l      0
DotTunnel_Done:    Dc.l      0

DotTunnel_Exit:    Dc.l      0
DotTunnel_Curr:    Dc.l      0
DotTunnel_Time:    Dc.l      0

DotTunnel_XSAdd:   Dc.l      0
DotTunnel_XSAdd2:  Dc.l      0
DotTunnel_XS2:     Dc.l      0

DotTunnel_YSAdd:   Dc.l      0
DotTunnel_YSAdd2:  Dc.l      0
DotTunnel_YS2:     Dc.l      0

DotTunnel_Old:     Dc.w      0
;;;

;;; "Effect: MiniWall"

MiniWall:          Move.l    #2*256,MiniWall_CoAdd
		   Move.l    #3*256,MiniWall_Co2Add
		   Move.l    #5*256,MiniWall_Co3Add

		   Bsr       MiniWall_Show

.lop               Bsr       _Sync

		   Btst      #2,$dff016
		   Beq       .break

		   Bsr       MiniWall_Add
		   Bsr       MiniWall_Counter
		   Bsr       MiniWall_Main

		   Cmp.w     #14,P61_Pos
		   Beq       .done

		   Tst.l     MiniWall_Exit
		   Beq       .lop

.done              Bsr       MiniWall_Remove
		   Moveq     #0,d0
		   Rts

.break             Bsr       MiniWall_Remove
		   Moveq     #1,d0
		   Rts

;;;
;;; "MiniWall_Add"
MiniWall_Add:      Lea       MiniWall_Story,a0
		   Add.l     MiniWall_Curr,a0

		   Tst.l     MiniWall_Time
		   Bne       .exit

.newentry          Move.b    (a0)+,d0
		   Extb.l    d0
		   Cmp.l     #-1,d0
		   Bne       .noend
		   Move.l    #1,MiniWall_Exit
		   Bra       .exit
.noend             Move.l    d0,MiniWall_Time

		   Move.b    (a0)+,d0
		   Extb.l    d0
		   Move.l    d0,MiniWall_CoAdd2

		   Move.b    (a0)+,d0
		   Extb.l    d0
		   Move.l    d0,MiniWall_Co2Add2

		   Move.b    (a0)+,d0
		   Extb.l    d0
		   Move.l    d0,MiniWall_Co3Add2

		   Add.l     #4,MiniWall_Curr
.exit              Subq.l    #1,MiniWall_Time

		   ;------------------------------

		   Move.l    MiniWall_CoAdd,d0
		   Add.l     d0,MiniWall_Co_2
		   Move.l    MiniWall_Co_2,d0
		   Asr.l     #8,d0
		   Move.l    d0,MiniWall_Co
		   And.l     #1023,MiniWall_Co

		   Move.l    MiniWall_CoAdd2,d0
		   Add.l     d0,MiniWall_CoAdd


		   Move.l    MiniWall_Co2Add,d0
		   Add.l     d0,MiniWall_Co2_2
		   Move.l    MiniWall_Co2_2,d0
		   Asr.l     #8,d0
		   Move.l    d0,MiniWall_Co2
		   And.l     #1023,MiniWall_Co2

		   Move.l    MiniWall_Co2Add2,d0
		   Add.l     d0,MiniWall_Co2Add


		   Move.l    MiniWall_Co3Add,d0
		   Add.l     d0,MiniWall_Co3_2
		   Move.l    MiniWall_Co3_2,d0
		   Asr.l     #8,d0
		   Move.l    d0,MiniWall_Co3
		   And.l     #1023,MiniWall_Co3

		   Move.l    MiniWall_Co3Add2,d0
		   Add.l     d0,MiniWall_Co3Add

		   Rts
;;;
;;; "MiniWall Story"
MiniWall_Story:
		   Dc.b      64,0,0,4
		   Dc.b      64,0,-4,0
		   Dc.b      64,0,0,0
		   Dc.b      64,-8,0,0
		   Dc.b      64,0,8,2
		   Dc.b      64,2,0,2
		   Dc.b      64,0,-8,0
		   Dc.b      64,-4,0,8
		   Dc.b      64,0,0,2
		   Dc.b      64,8,-8,0
		   Dc.b      64,0,0,-4
		   Dc.b      64,-16,0,2
		   Dc.b      64,0,-8,0
		   Dc.b      64,0,0,-4
		   Dc.b      64,0,8,2
		   Dc.b      64,2,0,2
		   Dc.b      48,0,-4,0
		   Dc.b      32,-4,0,8
		   Dc.b      32,0,0,2
		   Dc.b      32,16,-8,0
		   ;Dc.b      32,0,0,-4

		   Dc.b      -1
		   Even
;;;;
;;; "MiniWall Vars"
MiniWall_Exit:     Dc.l      0
MiniWall_Curr:     Dc.l      0
MiniWall_Time:     Dc.l      0

MiniWall_CoAdd:    Dc.l      0
MiniWall_CoAdd2:   Dc.l      0
MiniWall_Co_2:     Dc.l      0

MiniWall_Co2Add:   Dc.l      0
MiniWall_Co2Add2:  Dc.l      0
MiniWall_Co2_2:    Dc.l      0

MiniWall_Co3Add:   Dc.l      0
MiniWall_Co3Add2:  Dc.l      0
MiniWall_Co3_2:    Dc.l      0
;;;

*********************************************************

Atomic_Init:
;;; "Open Screen"
A_AllocPic:
		   Move.l    #40*256*4,d0
		   Move.l    #IntroMain_ID,d1
		   Bsr       _AllocChip
		   Move.l    d0,A_PicPtr
		   Beq       A_InitError

		   Move.l    #40*256*2,d0
		   Move.l    #IntroMain_ID,d1
		   Bsr       _AllocChip
		   Move.l    d0,A_ScreenPtr
		   Beq       A_InitError

		   ;------------------------

		   Lea       A_BplPtr,a0
		   Move.l    A_ScreenPtr,d1
		   Moveq     #2-1,d2
		   Move.l    #40*256,d0
		   Bsr       _SetPtrs

		   Lea       A_BplPtr,a0
		   Lea       16(a0),a0
		   Move.l    A_PicPtr,d1
		   Moveq     #4-1,d2
		   Move.l    #40*256,d0
		   Bsr       _SetPtrs

		   Lea       A_SprPtr,a0
		   Move.l    #SpriteDummy,d1
		   Moveq     #7,d2
		   Moveq     #0,d0
		   Bsr       _SetPtrs
;;;
;;; "Alloc FadeBuffer"
		   Move.l    #8*1024,d0
		   Move.l    #IntroMain_ID,d1
		   Bsr       _AllocPublic
		   Move.l    d0,A_FadeBuffPtr
		   Beq       A_InitError
;;;
;;; "Init Pic"

A_InitPic:         Lea       Texture,a3
		   Move.l    A_PicPtr,a0
		   Add.l     #4,a0
		   Move.l    #%10000,d5
		   Move.l    #4,a4

		   Move.l    #4-1,d4
.plane
		   Move.l    a3,a2

		   Move.l    #128-1,d7
.ylop
		   Move.l    a2,a1
		   Addq.l    #1,a2

		   Move.l    #32-1,d6
.xlop              Moveq     #0,d0

		   Movem.l   d6,-(a7)
		   Move.l    a4,d6

		   Move.b    (a1),d0
		   Add.l     #256/2,a1
		   And.w     d5,d0
		   Lsr.l     d6,d0
		   Move.b    (a1),d1
		   Add.l     #256/2,a1
		   And.w     d5,d1
		   Lsr.l     d6,d1
		   Move.b    (a1),d2
		   Add.l     #256/2,a1
		   And.w     d5,d2
		   Lsr.l     d6,d2
		   Move.b    (a1),d3
		   Add.l     #256/2,a1
		   And.w     d5,d3
		   Lsr.l     d6,d3

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

		   Movem.l   (a7)+,d6

		   Dbra      d6,.xlop

		   Add.l     #8+40,a0

		   Dbra      d7,.ylop

		   Lsl.l     #1,d5
		   Add.l     #1,a4

		   Dbra      d4,.plane
;;;
;;; "Rts"
		   Moveq     #0,d0
		   Rts
A_InitError:
		   Move.l    #IntroMain_ID,d0
		   Bsr       _FreeMany
		   Moveq     #1,d0
		   Rts
;;;

Atomic_Main:
;;; "Install Screen"
		   Move.l    #64,d0
		   Move.l    #64,d1
		   Move.l    #0,d2
		   Move.l    #0,d3
		   Lea       A_Pal2,a0
		   Lea       A_Pal1,a1
		   Move.l    A_FadeBuffPtr,a2
		   Bsr       _InitFade
;;;
;;; "Fade Pic"
		   Bsr       _Sync

		   Lea       A_CList,a0
		   Bsr       _InstallCopper

.fade              Move.l    A_FadeBuffPtr,a0
		   Bsr       _DoFade
		   Bsr       _Sync

		   Btst      #2,$dff016
		   Beq       A_Break

		   Tst.l     d0
		   Beq       .fade
;;;
;;; "It is.."
A_XPos1            Equ       38
A_YPos1            Equ       17

A_XPos2            Equ       85
A_YPos2            Equ       207

A_First:           Move.l    #64,d0
		   Move.l    #8,d1
		   Move.l    #0,d2
		   Move.l    #0,d3
		   Lea       A_Pal2,a0
		   Lea       A_Pal1,a1
		   Move.l    A_FadeBuffPtr,a2
		   Bsr       _InitFade

		   Move.w    #32,d0
		   Bsr       P61_WaitCRow
		   Tst.l     d0
		   Bne       A_Break

		   Lea       A_Word1a,a0
		   Move.l    #A_XPos1,d0
		   Move.l    #A_YPos1,d1
		   Bsr       Wr1_Write

		   Lea       A_Word1b,a0
		   Move.l    #A_XPos1+35,d0
		   Move.l    #A_YPos1,d1
		   Bsr       Wr1_Write

		   Lea       A_Word1c,a0
		   Move.l    #A_XPos1+70,d0
		   Move.l    #A_YPos1,d1
		   Bsr       Wr1_Write

		   Lea       A_Word1d,a0
		   Move.l    #A_XPos1+148,d0
		   Move.l    #A_YPos1,d1
		   Bsr       Wr1_Write

.fade              Move.l    A_FadeBuffPtr,a0
		   Bsr       _DoFade
		   Bsr       _Sync

		   Btst      #2,$dff016
		   Beq       A_Break

		   Tst.l     d0
		   Beq       .fade

		   ;-------------------------
A_Second:
		   Move.l    #64,d0
		   Move.l    #8,d1
		   Move.l    #0,d2
		   Move.l    #0,d3
		   Lea       A_Pal2,a0
		   Lea       A_Pal1,a1
		   Move.l    A_FadeBuffPtr,a2
		   Bsr       _InitFade

		   Move.w    #0,d0
		   Bsr       P61_WaitCRow2
		   Tst.l     d0
		   Bne       A_Break

		   Lea       A_Word2a,a0
		   Move.l    #A_XPos2,d0
		   Move.l    #A_YPos2,d1
		   Bsr       Wr1_Write

		   Lea       A_Word2b,a0
		   Move.l    #A_XPos2+61,d0
		   Move.l    #A_YPos2,d1
		   Bsr       Wr1_Write

.fade              Move.l    A_FadeBuffPtr,a0
		   Bsr       _DoFade
		   Bsr       _Sync

		   Btst      #2,$dff016
		   Beq       A_Break

		   Tst.l     d0
		   Beq       .fade
;;;
;;; "Fade Up"
A_FadeUp:          Move.l    #64,d0
		   Move.l    #8,d1
		   Move.l    #0,d2
		   Move.l    #0,d3
		   Lea       A_Pal1,a0
		   Lea       A_Pal2,a1
		   Move.l    A_FadeBuffPtr,a2
		   Bsr       _InitFade

		   Move.w    #32,d0
		   Bsr       P61_WaitCRow
		   Tst.l     d0
		   Bne       A_Break

		   Move.w    #0,d0
		   Bsr       P61_WaitCRow2
		   Tst.l     d0
		   Bne       A_Break

.fade              Move.l    A_FadeBuffPtr,a0
		   Bsr       _DoFade
		   Bsr       _Sync

		   Btst      #2,$dff016
		   Beq       A_Break

		   Tst.l     d0
		   Beq       .fade
;;;
		   Moveq     #0,d0
		   Rts
A_Break:
		   Moveq     #1,d0
		   Rts

;;; "Atomic Data"
A_PicPtr:          Dc.l      0
A_ScreenPtr:       Dc.l      0
A_FadeBuffPtr:     Dc.l      0

A_Pal1:            Dc.l      $000000,$777777,$bbbbbb,$ffffff
		   Dc.l      $000011,$777777,$bbbbbb,$ffffff
		   Dc.l      $000022,$777777,$bbbbbb,$ffffff
		   Dc.l      $111133,$777777,$bbbbbb,$ffffff

		   Dc.l      $222244,$777777,$bbbbbb,$ffffff
		   Dc.l      $333355,$777777,$bbbbbb,$ffffff
		   Dc.l      $444466,$777777,$bbbbbb,$ffffff
		   Dc.l      $555577,$777777,$bbbbbb,$ffffff

		   Dc.l      $666688,$777777,$bbbbbb,$ffffff
		   Dc.l      $777799,$777777,$bbbbbb,$ffffff
		   Dc.l      $8888aa,$777777,$bbbbbb,$ffffff
		   Dc.l      $9999bb,$777777,$bbbbbb,$ffffff

		   Dc.l      $aaaacc,$777777,$bbbbbb,$ffffff
		   Dc.l      $bbbbdd,$777777,$bbbbbb,$ffffff
		   Dc.l      $ccccee,$777777,$bbbbbb,$ffffff
		   Dc.l      $ddddff,$777777,$bbbbbb,$ffffff

A_Pal2:
		   REPT      16
		   Dc.l      $ffffff,$ffffff,$ffffff,$ffffff
		   ENDR

A_Pal3:
		   REPT      16
		   Dc.l      0,0,0,0
		   ENDR

A_Word1a:          Dc.b      I,T,END
A_Word1b:          Dc.b      I,S,END
A_Word1c:          Dc.b      Y,O,U,R,END
A_Word1d:          Dc.b      F,U,T,U,R,E,END

A_Word2a:          Dc.b      Y,O,U,END
A_Word2b:          Dc.b      D,E,C,I,D,E,UTR,END
;;;
;;; "Wr1_Write"
********************************
* IN: a0 - Pekare till ordet   *
*     d0 - X pos               *
*     d1 - Y pos               *
********************************
Wr1_Write:         Movem.l   d0-d4/a0,-(a7)

		   Move.l    a0,a1
		   Move.l    A_ScreenPtr,a0
		   Move.l    d1,d2
		   Move.l    d0,d1
		   Move.l    #320,d3
		   Move.l    #256,d4
		   Bsr       Writer_PutW

		   Movem.l   (a7)+,d0-d4/a0
		   Rts
;;;

*********************************************************


Write2:
;;; "Install Screen"
		   Move.l    A_PicPtr,a0
		   Move.l    #40*256*4/16-1,d0
.clrlop1           Clr.l     (a0)+
		   Clr.l     (a0)+
		   Clr.l     (a0)+
		   Clr.l     (a0)+
		   Dbra      d0,.clrlop1

		   Move.l    A_ScreenPtr,a0
		   Move.l    #40*256*2/16-1,d0
.clrlop2           Clr.l     (a0)+
		   Clr.l     (a0)+
		   Clr.l     (a0)+
		   Clr.l     (a0)+
		   Dbra      d0,.clrlop2

		   Move.l    #64,d0
		   Move.l    #64,d1
		   Move.l    #0,d2
		   Move.l    #0,d3
		   Lea       A_Pal2,a0
		   Lea       A_Pal1,a1
		   Move.l    A_FadeBuffPtr,a2
		   Bsr       _InitFade
;;;
;;; "Fade Pic"
		   Bsr       _Sync

		   Lea       A_CList,a0
		   Bsr       _InstallCopper

.fade              Btst      #2,$dff016
		   Beq       W2_Break

		   Move.l    A_FadeBuffPtr,a0
		   Bsr       _DoFade
		   Bsr       _Sync
		   Tst.l     d0
		   Beq       .fade
;;;
;;; "God is.."
A_XPos1_           Equ       73
A_YPos1_           Equ       47

A_XPos2_           Equ       50
A_YPos2_           Equ       177

A_First2:          Move.l    #64,d0
		   Move.l    #8,d1
		   Move.l    #0,d2
		   Move.l    #0,d3
		   Lea       A_Pal2,a0
		   Lea       A_Pal1,a1
		   Move.l    A_FadeBuffPtr,a2
		   Bsr       _InitFade

		   Move.w    #32,d0
		   Bsr       P61_WaitCRow
		   Tst.l     d0
		   Bne       W2_Break

		   Lea       W_Word1a,a0
		   Move.l    #A_XPos1_,d0
		   Move.l    #A_YPos1_,d1
		   Bsr       Wr1_Write

		   Lea       W_Word1b,a0
		   Move.l    #A_XPos1_+62,d0
		   Move.l    #A_YPos1_,d1
		   Bsr       Wr1_Write

		   Lea       W_Word1c,a0
		   Move.l    #A_XPos1_+98,d0
		   Move.l    #A_YPos1_,d1
		   Bsr       Wr1_Write

.fade              Btst      #2,$dff016
		   Beq       W2_Break

		   Move.l    A_FadeBuffPtr,a0
		   Bsr       _DoFade
		   Bsr       _Sync
		   Tst.l     d0
		   Beq       .fade

		   ;-------------------------
A_Second2:
		   Move.l    #64,d0
		   Move.l    #8,d1
		   Move.l    #0,d2
		   Move.l    #0,d3
		   Lea       A_Pal2,a0
		   Lea       A_Pal1,a1
		   Move.l    A_FadeBuffPtr,a2
		   Bsr       _InitFade

		   Move.w    #0,d0
		   Bsr       P61_WaitCRow2
		   Tst.l     d0
		   Bne       W2_Break

		   Lea       W_Word2a,a0
		   Move.l    #A_XPos2_,d0
		   Move.l    #A_YPos2_,d1
		   Bsr       Wr1_Write

		   Lea       W_Word2b,a0
		   Move.l    #A_XPos2_+65,d0
		   Move.l    #A_YPos2_,d1
		   Bsr       Wr1_Write

		   Lea       W_Word2c,a0
		   Move.l    #A_XPos2_+154,d0
		   Move.l    #A_YPos2_,d1
		   Bsr       Wr1_Write

.fade              Btst      #2,$dff016
		   Beq       W2_Break

		   Move.l    A_FadeBuffPtr,a0
		   Bsr       _DoFade
		   Bsr       _Sync
		   Tst.l     d0
		   Beq       .fade
;;;
;;; "Fade Up"
A_FadeUp2:         Move.l    #64,d0
		   Move.l    #8,d1
		   Move.l    #0,d2
		   Move.l    #0,d3
		   Lea       A_Pal1,a0
		   Lea       A_Pal2,a1
		   Move.l    A_FadeBuffPtr,a2
		   Bsr       _InitFade

		   Move.w    #32,d0
		   Bsr       P61_WaitCRow
		   Tst.l     d0
		   Bne       W2_Break

		   Move.w    #0,d0
		   Bsr       P61_WaitCRow2
		   Tst.l     d0
		   Bne       W2_Break

.fade              Btst      #2,$dff016
		   Beq       W2_Break

		   Move.l    A_FadeBuffPtr,a0
		   Bsr       _DoFade
		   Bsr       _Sync
		   Tst.l     d0
		   Beq       .fade
;;;
		   Moveq     #0,d0
		   Rts

W2_Break:          Moveq     #1,d0
		   Rts

;;; "Write2 Data"
W_Word1a:          Dc.b      G,O,D,END
W_Word1b:          Dc.b      I,S,END
W_Word1c:          Dc.b      D,E,A,D,UTR,END

W_Word2a:          Dc.b      H,O,W,END
W_Word2b:          Dc.b      A,B,O,U,T,END
W_Word2c:          Dc.b      Y,O,U,FRA,END
;;;

Write3:
;;; "Clear Screen"
		   Move.l    A_PicPtr,a0
		   Move.l    #40*256*4/16-1,d0
.clrlop1           Clr.l     (a0)+
		   Clr.l     (a0)+
		   Clr.l     (a0)+
		   Clr.l     (a0)+
		   Dbra      d0,.clrlop1

		   Move.l    A_ScreenPtr,a0
		   Move.l    #40*256*2/16-1,d0
.clrlop2           Clr.l     (a0)+
		   Clr.l     (a0)+
		   Clr.l     (a0)+
		   Clr.l     (a0)+
		   Dbra      d0,.clrlop2
;;;
;;; "Init Colours"
		   Lea       Custom,a5
		   Move.w    #$0000,$106(a5)
		   Move.w    #$0000,$180(a5)
		   Move.w    #$0777,$182(a5)
		   Move.w    #$0bbb,$184(a5)
		   Move.w    #$0fff,$186(a5)
;;;
;;; "Show Screen"
		   Lea       A_CList,a0
		   Bsr       _InstallCopper
;;;
;;; "HardLine.."
A_First3:          Move.l    #64,d0
		   Move.l    #4,d1
		   Move.l    #0,d2
		   Move.l    #0,d3
		   Lea       A_Pal2,a0
		   Lea       A_Pal1,a1
		   Move.l    A_FadeBuffPtr,a2
		   Bsr       _InitFade

		   Lea       W3_Word1,a0
		   Move.l    #100,d0
		   Move.l    #20,d1
		   Bsr       Wr1_Write

.fade              Btst      #2,$dff016
		   Beq       W3_Break

		   Move.l    A_FadeBuffPtr,a0
		   Bsr       _DoFade
		   Bsr       _Sync
		   Tst.l     d0
		   Beq       .fade

		   ;-------------------------
A_Second3:
		   Move.l    #64,d0
		   Move.l    #4,d1
		   Move.l    #0,d2
		   Move.l    #0,d3
		   Lea       A_Pal2,a0
		   Lea       A_Pal1,a1
		   Move.l    A_FadeBuffPtr,a2
		   Bsr       _InitFade

		   Move.w    #2,d0
		   Bsr       P61_WaitCRow
		   Tst.l     d0
		   Bne       W3_Break

		   Lea       W3_Word2,a0
		   Move.l    #106,d0
		   Move.l    #110,d1
		   Bsr       Wr1_Write

.fade              Btst      #2,$dff016
		   Beq       W3_Break

		   Move.l    A_FadeBuffPtr,a0
		   Bsr       _DoFade
		   Bsr       _Sync
		   Tst.l     d0
		   Beq       .fade

A_Third3:          Move.l    #64,d0
		   Move.l    #4,d1
		   Move.l    #0,d2
		   Move.l    #0,d3
		   Lea       A_Pal2,a0
		   Lea       A_Pal1,a1
		   Move.l    A_FadeBuffPtr,a2
		   Bsr       _InitFade

		   Move.w    #4,d0
		   Bsr       P61_WaitCRow
		   Tst.l     d0
		   Bne       W3_Break

		   Lea       W3_Word3,a0
		   Move.l    #100,d0
		   Move.l    #200,d1
		   Bsr       Wr1_Write

.fade              Btst      #2,$dff016
		   Beq       W3_Break

		   Move.l    A_FadeBuffPtr,a0
		   Bsr       _DoFade
		   Bsr       _Sync
		   Tst.l     d0
		   Beq       .fade
;;;
;;; "Fade Down"
A_FadeUp3:         Move.l    #64,d0
		   Move.l    #128,d1
		   Move.l    #0,d2
		   Move.l    #0,d3
		   Lea       A_Pal1,a0
		   Lea       A_Pal3,a1
		   Move.l    A_FadeBuffPtr,a2
		   Bsr       _InitFade

		   Move.l    #170-1,d0
.loop              Bsr       _Sync
		   Dbra      d0,.loop

.fade              Btst      #2,$dff016
		   Beq       W3_Break

		   Move.l    A_FadeBuffPtr,a0
		   Bsr       _DoFade
		   Bsr       _Sync
		   Tst.l     d0
		   Beq       .fade
;;;
		   Moveq     #0,d0
		   Rts

W3_Break:          Moveq     #1,d0
		   Rts


;;; "Write3 Data"
W3_Word1:          Dc.b      H,A,R,D,L,I,N,E,END
W3_Word2:          Dc.b      A,G,A,I,N,S,T,END
W3_Word3:          Dc.b      H,A,R,D,L,I,N,E,END
;;;

		   Section chipdata,DATA_C
;;; "Atomic CopperList"
A_CList:           Dc.w      $008e,$2c81     ; DIWSTRT
		   Dc.w      $0090,$2bc1     ; DIWSTOP
		   Dc.w      $0092,$0038     ; DDFSTRT
		   Dc.w      $0094,$00d0     ; DDFSTOP
		   Dc.w      $0100,$6201     ; BPLCON0
		   Dc.w      $0102,$0000     ; BPLCON1
		   Dc.w      $0104,$0200     ; BPLCON2
		   Dc.w      $0108,-8        ; BPLMOD1
		   Dc.w      $010a,-8        ; BPLMOD2
		   Dc.w      $01fc,$0003     ; FETCHMODE

A_BplPtr:          Dc.w      $00e0,$0000     ; BPL1PTH
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

A_SprPtr:
A_SprNum           Set       $0120
		   REPT      16
		   Dc.w      A_SprNum,$0000    ; SPRxPT
A_SprNum           Set       A_SprNum+2
		   ENDR

		   Dc.w      $ffff,$fffe     ; End of list
;;;

