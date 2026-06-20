

; qua la tabella e' il doppio di quella standard come logofx2- lsl #15?

;Project: Line Vectors
;Version: 1.0
;Coded by Wayne Mendoza / TRSI
;Copyright © Wayne Mendoza 1992
;Date: 24.05.92
;Time: 16:17 / 19:21
;
;Hmmm....this one is quite funny (hehe) looks like the line
;vector routine in hardwired (??).
;The Code itself is not highly optimized (especially the morph routine).
;The main mistake is that the morphing is NOT calculated while the
;lines are rotating but at the end of the rotation and this suxx.
;So optimize it if you dare and have fun !!
;
;I did not have any time to optimize it....it was planned for Wicked
;Sensation but it looks the same (sorry) as the Silents routine and
;so it was dropped into the crap directory (hehe)
;
;;----------------------------- System Constants ------------------------------

Execbase=4
OpenLibrary=-552
CloseLibrary=-414

;;----------------------------- Routine Constants -----------------------------

Width=40
Height=256
PlaneSize=Width*Height

MaxPoints=100

LineTerm=$BCA

FlickerEnable=0		;0=OFF / 1=ON

FlickerFreq=3

;--------------------------------- Metamorphosis ------------------------------

MetaStepWidth=2

;;------------------------------ Memory Section -------------------------------

 SECTION "Line Vectors V1.1",CODE_P

;;------------------------------- Local Macros --------------------------------

Wblt: MACRO
.W\@:
 btst #14,2(A6)
 bne.s .W\@
 ENDM

WbltSpeed: MACRO
 move.w #$8400,$96(A6)
 Wblt
 move.w #$400,$96(A6)
 ENDM

VertBlank: MACRO
 move.l d0,-(SP)
.W\@:
 move.l 4(A6),d0
 and.l #$fff000,d0
 cmp.l #$013000,d0
 bne.s .W\@
 move.l (Sp)+,d0
 ENDM

PlaneEntry: MACRO
 move.l a0,d0
 move.w d0,\2
 swap d0
 move.w d0,\1
 ENDM
 
;;------------------------------ Routine Inits --------------------------------

OpenGfx:
 move.l Execbase,A6
 moveq #0,d0
 lea Gfxname(Pc),a1
 JSR OpenLibrary(A6)
 move.l d0,Gfxbase
 beq Ende

LoadDMABase:
 lea $dff000,a6

SaveOldStatus:
 move.w $2(A6),OldDMA
 move.w $1c(A6),OldINTENA

FuckIRQ:
 move.w #$7fff,$9a(A6)

FuckSpriteDMA:
 move.l #0,$144(A6)
 move.w #$20,$96(A6)

ClearMem:
 lea ClearStart,a4
 lea ClearEnd,a5
 move.l a4,d0
 and.l #1,d0
 beq.s .no
 clr.b (A4)+
.No:
 movem.l ClearRegs(pc),d0-d7/a0-a3
.ClearLoop:
 lea 48(a4),a4
 cmp.l a5,a4
 bge.s .EndClear
 movem.l d0-d7/a0-a3,-48(a4) 
 bra.s .ClearLoop
.EndClear:
 lea -48(a4),a4
.RestClear:
 cmp.l a5,a4
 bge.s .End
 clr.b (a4)+
 bra.s .RestClear
.End:

InitMultiTab:
 lea MultiTab(pc),a0
 moveq #0,d0
 moveq #Width,d1
 move.w #Height-1,d2
.Loop:
 move.w d0,(A0)+
 add.w d1,d0
 dbf d2,.Loop

FirstPlaneInit:
 lea Plane1,a0
 PlaneEntry PlaneHi1,PlaneLo1	;Reine Tippfaulheit
 lea Plane2,a0
 PlaneEntry PlaneHi2,PlaneLo2
 lea Plane3,a0
 PlaneEntry PlaneHi3,PlaneLo3
 lea Plane4,a0
 PlaneEntry PlaneHi4,PlaneLo4
 lea Plane5,a0
 PlaneEntry PlaneHi4,PlaneLo4

AnimInit:
 lea AnimTab(Pc),a0
 movem.w (A0)+,d0-d1
 add.w d0,d0
 add.w d0,d0
 move.w d1,MaxEvent
 lea ObjectTab(pc),a0
 lea KoordTab(pc),a1
 move.l (a0,d0.w),ObjectPointer
 move.l (a1,d0.w),KoordPointer
 addq.w #4,AnimTabOffset

CopperInit:
 VertBlank
 move.l #CopperList,$80(A6)	;Hennenficken rulez

;--------------------------------- Main Routine -------------------------------

Routine: 
 BSR ClearScreen
 IF FlickerEnable=1
 BSR Flicker
 ENDIF
 tst.b MetaBit
 bne.s DoMeta
 BSR Rotation
 BSR Projection
 BSR DrawLines
 BSR SearchMinMax
 lea SXMin(pc),a0
 movem.w d0-d3,(A0)
 addq.w #1,XRot
 addq.w #2,YRot
 addq.w #1,ZRot
 bra.s TestAnim
DoMeta:
 BSR MetaPixels
 bra.s SkipAnim
TestAnim:
 lea EventCount(pc),a0
 addq.w #1,(A0)
 move.w (A0),d0
 cmp.w MaxEvent(pc),d0
 bmi.s .Ok
 BSR MakeAnim
.Ok:
SkipAnim:
 BSR DoubleBuffer
 btst #6,$bfe001
 bne Routine
CloseIt:
 move.w #$7fff,$9a(A6)
 move.w OldINTENA(pc),d0
 or.w #$8000,d0
 move.w d0,$9a(A6)
 move.w OldDMA(pc),d0
 or.w #$8000,d0
 move.w #$7fff,$96(A6)
 move.w d0,$96(A6)
 move.l Execbase,A6
 move.l Gfxbase(pc),a1
 move.l 38(a1),$dff080
 JSR CloseLibrary(A6)
Ende:
 move.w #$8020,$dff096
 moveq #0,d0
 RTS

;;------------------------------- Sub Routines --------------------------------

DoubleBuffer:
 WbltSpeed
 VertBlank
 lea PlanesTab(pc),a1
 add.w PlanesTabOffset(pc),a1
 tst.l (a1)
 bne.s .NoOffsetInit
 clr.w PlanesTabOffset
 lea PlanesTab(pc),a1
.NoOffsetInit:
 move.l (a1),a0
 addq.w #4,PlanesTabOffset 
 move.l PlanePointer(pc),a1
 move.l a0,PlanePointer
.DoSwap:
 move.l a1,a0
 move.w PlaneHi4,PlaneHi5		;Ebenfalls unoptimiert (direct suxx)
 move.w PlaneLo4,PlaneLo5
 move.w PlaneHi3,PlaneHi4
 move.w PlaneLo3,PlaneLo4
 move.w PlaneHi2,PlaneHi3
 move.w PlaneLo2,PlaneLo3
 move.w PlaneHi1,PlaneHi2
 move.w PlaneLo1,PlaneLo2
 PlaneEntry PlaneHi1,PlaneLo1
 RTS

Flicker:
 addq.b #1,FlickerCount
 cmp.b #FlickerFreq,FlickerCount
 ble.s .NoFlicker
 clr.b FlickerCount
 cmp.w #$200,FlickerData
 beq.s .Change
 move.w #$0200,FlickerData
 RTS 
.Change:
 move.w #$5200,FlickerData
.NoFlicker: 
 RTS

MakeAnim:
 clr.w EventCount
 lea AnimTab(pc),a0
 add.w AnimTabOffset(pc),a0
 tst.l (A0)
 bne.s .Normal
 clr.w AnimTabOffset
 lea AnimTab(pc),a0
.Normal:
 addq.w #4,AnimTabOffset
 movem.w (A0)+,d0-d1
 add.w d0,d0
 add.w d0,d0
 move.w d1,MaxEvent
 lea ObjectTab(pc),a0
 lea KoordTab(pc),a1
 move.l (A0,d0.w),ObjectPointer
 move.l (a1,d0.w),KoordPointer
 BSR GenerateSecondObject
 RTS

SearchMinMax:
 lea ZweiDTab(pc),a0
 move.l KoordPointer(pc),a1
 move.w (A1),d7
 move.w #400,d0
 move.w d0,d2
 moveq #-1,d1
 moveq #-1,d3
.SearchMinMaxLoop:
 cmp.w (A0),d0
 ble.s .NoXMin
 move.w (A0),d0
.NoXMin:
 cmp.w (A0),d1
 bge.s .NoXMax
 move.w (A0),d1
.NoXMax:
 cmp.w 2(A0),d2
 ble.s .NoYMin
 move.w 2(A0),d2
.NoYMin:
 cmp.w 2(A0),d3
 bge.s .NoYMax
 move.w 2(A0),d3
.NoYMax:
 addq.w #4,a0
 dbf d7,.SearchMinMaxLoop
 RTS

GenerateSecondObject:
 BSR Rotation
 BSR Projection
 BSR ClearDestObject
 move.l PlanePointer(pc),d0
 move.l d0,MetaSource
 move.l #SecondObject,PlanePointer
 BSR DrawLines
 BSR SearchMinMax
 lea DXMin(pc),a5
 movem.w d0-d3,(A5)
 BSR CalcMetamorphosis
 move.l MetaSource(pc),d0
 move.l d0,PlanePointer
 move.b #1,MetaBit
 RTS

ClearDestObject:
 movem.l d0-d7/a0-a5,-(Sp)
 lea SecondObject,a0
 WbltSpeed
 move.l a0,$54(A6)
 move.l #$01000000,$40(A6)
 move.w #0,$66(A6)
 move.w #128*64+20,$58(A6)
 lea SecondObject+10240,a6
 movem.l ClearRegs(pc),d0-d7/a0-a5
 REPT 92
 movem.l d0-d7/a0-a5,-(A6)
 ENDR
 lea $dff000,a6
 movem.l (Sp)+,d0-d7/a0-a5
 RTS 

ClearScreen:
 WbltSpeed
 move.l PlanePointer(pc),$54(A6)
 move.l #$01000000,$40(A6)
 move.w #0,$66(A6)
 move.w #128*64+20,$58(A6)
 move.l PlanePointer(pc),a6
 lea 10240(A6),a6
 movem.l ClearRegs(pc),d0-d7/a0-a5
 REPT 92
 movem.l d0-d7/a0-a5,-(A6)
 ENDR
 lea $dff000,a6 
 RTS

Projection:
 lea RotateTab(pc),a0
 lea ZweiDTab(pc),a1
 move.l KoordPointer(Pc),a2
 move.w (a2),d7
 lea ZoomX(pc),a2
 move.w #160,d3
 move.w #128,d4
.ProjectionLoop:
 movem.w (A0)+,d0-d2
 add.w (a2),d0
 add.w 2(a2),d1
 add.w 4(a2),d2
 asl.l #8,d0
 asl.l #8,d1
 divs d2,d0
 divs d2,d1
 add.w d3,d0
 add.w d4,d1
 movem.w d0-d1,(a1)
 addq.w #4,a1
 dbf d7,.ProjectionLoop
 RTS

DrawLines:
 WbltSpeed
 move.l #-1,$44(A6)		;CONSTANT
 move.l #$ffff8000,$72(A6)	;CONSTANT
 move.w #Width,$60(A6)		;CONSTANT
 move.w #Width,$66(A6)		;CONSTANT
 move.l ObjectPointer(pc),a0
 lea ZweiDTab(pc),a1
 lea OktList(Pc),a2
 move.l PlanePointer(pc),a3
 lea MultiTab(pc),a4
 move.w (A0)+,d7
.DrawLinesLoop1:
 move.w (A0)+,d5
 add.w d5,d5
 add.w d5,d5
 movem.w (a1,d5.w),d0-d1
 move.w (A0)+,d5
 add.w d5,d5
 add.w d5,d5
 movem.w (a1,d5.w),d2-d3
 BSR BlitterLine
 dbf d7,.DrawLinesLoop1
 RTS

BlitterLine:
 movem.l d4-d7/a0,-(Sp)
 cmp.w d1,d3
 ble.s .Y1Higher
 exg d0,d2
 exg d1,d3
.Y1Higher:
 moveq #0,d4
 sub.w d1,d3
 roxl.b #1,d4
 tst.w d3
 bpl.s .NoDYMinus
 neg.w d3
.NoDYMinus:
 sub.w d0,d2
 roxl.b #1,d4
 tst.w d2
 bpl.s .NoDXMinus
 neg.w d2
.NoDXMinus:
 move.w d3,d5
 sub.w d2,d5
 roxl.b #1,d4
 tst.w d5
 bpl.s .DYBiggerDX
 exg d2,d3
.DYBiggerDX:
 add.w d1,d1
 move.w (a4,d1.w),a0   
 add.l a3,a0
 move.w d0,d1
 lsr.w #3,d1
 bclr #0,d1
 add.w d1,a0
 add.w d2,d2
 move.w d2,d5
 move.b (a2,d4.w),d4
 sub.w d3,d5
 bpl.s .NoSignBit
 or.b #$40,d4
.NoSignBit:
 move.w d2,d6
 sub.w d3,d6
 sub.w d3,d6
 and.w #$f,d0
 ror.w #4,d0
 or.w #LineTerm,d0
 lsl.w #6,d3
 add.w #$42,d3
 Wblt
 move.w d6,$64(A6)
 move.w d2,$62(A6)
 move.w d5,$52(A6)
 move.w d0,$40(A6)
 move.w d4,$42(A6)
 move.l a0,$48(A6)
 move.l a0,$54(A6)
 move.w d3,$58(A6)
 movem.l (sp)+,d4-d7/a0
 RTS
 
OktList:
 dc.b 1,17,9,21,5,25,13,29
 EVEN

Rotation:
 BSR Calc_Sin_Cos
 move.l KoordPointer(pc),a0
 lea RotateTab(pc),a1
 lea SinValues(pc),a2
 move.w (a0)+,d6
.RotationLoop:
 movem.w (A0),d0-d2
 movem.w (a2),d3-d5
 muls d3,d0
 muls d4,d1
 muls d5,d2
 add.l d2,d1
 add.l d1,d0
 add.l d0,d0
 swap d0
 move.w d0,(A1)+ 
 movem.w (a0),d0-d2
 movem.w 6(a2),d3-d5
 muls d3,d0
 muls d4,d1
 muls d5,d2
 add.l d2,d1
 add.l d1,d0
 add.l d0,d0
 swap d0
 move.w d0,(a1)+
 movem.w (a0)+,d0-d2
 movem.w 12(a2),d3-d5
 muls d3,d0
 muls d4,d1
 muls d5,d2
 add.l d2,d1
 add.l d1,d0
 add.l d0,d0
 swap d0
 move.w d0,(a1)+
 dbf d6,.RotationLoop
 RTS

Calc_Sin_Cos:
 move.w #360,d3
 lea XRot(pc),a0
 movem.w (A0),d0-d2
 cmp.w d3,d0
 bmi.s .XRotOk
 sub.w d3,d0
 move.w d0,(a0)
.XRotOk:
 cmp.w d3,d1
 bmi.s .YRotOk
 sub.w d3,d1
 move.w d1,2(a0)
.YRotOk:
 cmp.w d3,d2
 bmi.s .ZRotOk
 sub.w d3,d2
 move.w d2,4(a0)
.ZRotOk:
 add.w d0,d0
 add.w d1,d1
 add.w d2,d2
 lea SinTab(pc),a0
 lea CosTab(pc),a1
 move.w (a0,d2.w),d4	;SIN(X) in d2
 move.w (a1,d2.w),d7	;SIN(Y) in d3
 move.w (a0,d0.w),d2	;SIN(Z) in d4
 move.w (a0,d1.w),d3	;COS(X) in d5
 move.w (a1,d0.w),d5	;COS(Y) in d6
 move.w (a1,d1.w),d6	;COS(Z) in d7
 lea SinValues(pc),a0
 move.w d6,d0
 muls d7,d0
 add.l d0,d0
 swap d0
 move.w d0,(a0)
 move.w d6,d0
 muls d4,d0
 add.l d0,d0
 swap d0
 move.w d0,2(A0)
 move.w d2,d0
 muls d3,d0
 add.l d0,d0
 swap d0
 move.w d0,a1
 muls d7,d0
 move.w d5,d1
 muls d4,d1
 sub.l d1,d0
 add.l d0,d0
 swap d0
 move.w d0,6(A0)
 move.w a1,d0
 muls d4,d0
 move.w d5,d1
 muls d7,d1
 add.l d1,d0
 add.l d0,d0
 swap d0
 move.w d0,8(A0)
 move.w d2,d0
 muls d6,d0
 add.l d0,d0
 swap d0
 move.w d0,10(A0)
 move.w d5,d0
 muls d3,d0
 add.l d0,d0
 swap d0
 move.w d0,a1
 muls d7,d0
 move.w d2,d1
 muls d4,d1
 add.l d1,d0
 add.l d0,d0
 swap d0
 move.w d0,12(A0)
 move.w a1,d0
 muls d4,d0
 muls d2,d7
 sub.l d7,d0
 add.l d0,d0
 swap d0
 move.w d0,14(A0)
 muls d5,d6
 add.l d6,d6
 swap d6
 move.w d6,16(A0)
 neg.w d3
 move.w d3,4(A0)
 RTS

;-------------------------------- Metamorphosis -------------------------------

MetaPixels:
 WbltSpeed
 addq.w #1,MetaTransCount
 cmp.w #33,MetaTransCount
 bge .MetaReady
 move.l MetaKoords(pc),a0
 move.l PlanePointer(pc),a1
 lea MultiTab(pc),a2
 move.w (A0)+,d7
 subq.w #1,d7
.MetaPixelsLoop:
 movem.w (A0),d0-d3
 add.w d2,d0
 add.w d3,d1
 movem.w d0-d1,(a0)
 addq.w #8,a0
 lsr.w #5,d0
 lsr.w #5,d1
 move.w d0,d2
 lsr.w #3,d0
 add.w d1,d1
 not.b d2
 add.w (a2,d1.w),d0
 bset d2,(a1,d0.w)
 dbf d7,.MetaPixelsLoop
 RTS
.MetaReady:
 clr.w MetaTransCount
 clr.b MetaBit
 RTS

CalcMetamorphosis:
 clr.b DEnd
 move.l MetaSource(pc),a0
 move.l MetaDest(pc),a1
 move.l MetaKoords(pc),a2
 lea SXMin(pc),a3
 lea TempKoords(pc),a4
 lea MultiTab(pc),a5
 addq.w #2,a2
 move.w (A3),d0
 move.w 4(a3),d1
 move.w 8(a3),(A4)
 move.w 12(A3),2(a4)
 moveq #0,d7
.CalcLoop1:
 movem.w d0-d1,-(SP)
 move.w d0,d2
 lsr.w #3,d0
 not.b d2
 add.w d1,d1
 add.w (a5,d1.w),d0
 btst d2,(a0,d0.w)
 beq.s .NoSourcePoint
 BSR SearchDestPoint
 movem.w (Sp),d0-d1
 addq.w #1,d7
 sub.w d0,d2
 sub.w d1,d3
 lsl.w #5,d0
 lsl.w #5,d1
 movem.w d0-d3,(a2)
 addq.w #8,a2
 movem.w (Sp)+,d0-d1
 bra.s .GetNext 
.NoSourcePoint:
 movem.w (Sp)+,d0-d1
.GetNext:
 addq.w #MetaStepWidth,d0
 cmp.w 2(A3),d0
 bmi.s .CalcLoop1
 addq.w #MetaStepWidth,d1
 move.w (A3),d0
 cmp.w 6(A3),d1
 bmi.s .CalcLoop1
 tst.b DEnd
 bne.s .EndMeta
 move.w 4(A3),d1
 bra.s .CalcLoop1
.EndMeta:
 move.l MetaKoords(pc),a0
 move.w d7,(A0)
 RTS

SearchDestPoint:
 movem.w (A4),d0-d1
.CalcLoop1:
 movem.w d0-d1,-(Sp)
 move.w d0,d2
 lsr.w #3,d0
 not.b d2
 add.w d1,d1
 add.w (a5,d1.w),d0
 btst d2,(a1,d0.w)
 beq.s .NoPoint
 movem.w (Sp)+,d0-d1
 move.w d0,d2			;Dest Koords in d2 and d3
 move.w d1,d3			
 addq.w #MetaStepWidth,d0
 movem.w d0-d1,(A4)
 RTS 
.NoPoint:
 movem.w (Sp)+,d0-d1
 addq.w #MetaStepWidth,d0
 cmp.w 10(A3),d0
 bmi.s .CalcLoop1
 move.w 8(a3),d0
 addq.w #MetaStepWidth,d1
 cmp.w 14(A3),d1
 bmi.s .CalcLoop1
 move.b #1,DEnd
 move.w 12(A3),d1
 bra.s .CalcLoop1

;;--------------------------------- Variables ---------------------------------

OldDMA:
 dc.w 0

OldINTENA:
 dc.w 0

OldIRQ:
 dc.l 0

Gfxname:
 dc.b "graphics.library",0
 EVEN

Gfxbase:
 dc.l 0

MetaBit:
 dc.b 0
 EVEN

PlanePointer:
 dc.l Plane1

XRot:
 dc.w 0
YRot:
 dc.w 0
ZRot:
 dc.w 0

SinValues:
 blk.w 9,0

ObjectPointer:
 dc.l 0

KoordPointer:
 dc.l 0

KoordTab:
 dc.l CrossPoints
 dc.l CubePoints
 dc.l TetraPoints

ObjectTab:
 dc.l Cross
 dc.l Cube
 dc.l Tetraeder

AnimTab:		;50 = 1 Second
 dc.w 1,200
 dc.w 0,250
 dc.w 2,180
 dc.w 0,120
 dc.l 0

AnimTabOffset:
 dc.w 0

ZoomX:
 dc.w 0
ZoomY:
 dc.w 0
ZoomZ:
 dc.w 400

PlanesTab:
 dc.l Plane1
 dc.l Plane2
 dc.l Plane3
 dc.l Plane4
 dc.l Plane5
 dc.l 0

PlanesTabOffset:
 dc.w 0

EventCount:
 dc.w 0

MaxEvent:
 dc.w 0

;------------------------------ Metamorphosis Variables -----------------------

DEnd:
 dc.b 0
 EVEN

TempKoords:
 blk.w 4,0

SXMin:
 dc.w 98
SXMax:
 dc.w 260
SYMin:
 dc.w 30
SYMax:
 dc.w 210
DXMin:
 dc.w 60
DXMax:
 dc.w 250
DYMin:
 dc.w 10
DYMax:
 dc.w 200
LastDest:
 dc.w 0,0

MetaTransCount:
 dc.w 0

MetaPoints:
 dc.w 0

MetaSource:
 dc.l Plane1

MetaDest:
 dc.l SecondObject

MetaKoords:
 dc.l MK

FlickerCount:
 dc.b 0
 EVEN

;;------------------------------- Lists and Tabs ------------------------------

ClearRegs:
 blk.l 16,0

CubePoints:
 dc.w 8-1
 dc.w -80,-80,-80
 dc.w  80,-80,-80
 dc.w  80, 80,-80
 dc.w -80, 80,-80
 dc.w -80,-80, 80
 dc.w  80,-80, 80
 dc.w  80, 80, 80
 dc.w -80, 80, 80

TetraPoints:
 dc.w 4-1
 dc.w -70,-70,-70
 dc.w  70,-70,-70
 dc.w   0,-70, 70
 dc.w   0, 70,  0

CrossPoints:
 dc.w 12-1
 dc.w -100,-20,0
 dc.w -100, 20,0
 dc.w -20, 20,0
 dc.w -20, 100,0
 dc.w  20, 100,0
 dc.w  20, 20,0
 dc.w  100, 20,0
 dc.w  100,-20,0
 dc.w  20,-20,0
 dc.w  20,-100,0
 dc.w -20,-100,0
 dc.w -20,-20,0

Cross:
 dc.w 11
 dc.w 0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,0

Tetraeder:
 dc.w 5
 dc.w 0,1
 dc.w 1,2
 dc.w 2,0
 dc.w 2,3
 dc.w 0,3
 dc.w 1,3

Cube:
 dc.w 11
 dc.w 0,1
 dc.w 1,2
 dc.w 2,3
 dc.w 3,7
 dc.w 0,4
 dc.w 4,5
 dc.w 5,6
 dc.w 2,6
 dc.w 7,6
 dc.w 4,7
 dc.w 3,0
 dc.w 1,5

RotateTab:
 blk.w MaxPoints*3,0

ZweiDTab:
 blk.w MaxPoints*2,0

MultiTab:
 blk.w Height,0

SinTab:
 dc.w $0000,$023C,$0478,$06B3,$08EE,$0B28,$0D61,$0F99,$11D0,$1406
 dc.w $163A,$186C,$1A9D,$1CCB,$1EF7,$2121,$2348,$256C,$278E,$29AC
 dc.w $2BC7,$2DDF,$2FF3,$3203,$3410,$3618,$381C,$3A1C,$3C17,$3E0E
 dc.w $3FFF,$41EC,$43D4,$45B6,$4793,$496A,$4B3C,$4D08,$4ECD,$508D
 dc.w $5246,$53F9,$55A5,$574B,$58EA,$5A82,$5C13,$5D9C,$5F1F,$609A
 dc.w $620D,$6379,$64DD,$6639,$678D,$68D9,$6A1D,$6B59,$6C8C,$6DB7
 dc.w $6ED9,$6FF3,$7104,$720C,$730B,$7401,$74EE,$75D2,$76AD,$777F
 dc.w $7847,$7906,$79BB,$7A67,$7B0A,$7BA2,$7C32,$7CB7,$7D33,$7DA5
 dc.w $7E0D,$7E6C,$7EC0,$7F0B,$7F4C,$7F82,$7FAF,$7FD2,$7FEB,$7FFA
CosTab:
 dc.w $7FFF,$7FFA,$7FEB,$7FD2,$7FAF,$7F82,$7F4B,$7F0B,$7EC0,$7E6C
 dc.w $7E0D,$7DA5,$7D33,$7CB7,$7C32,$7BA2,$7B0A,$7A67,$79BB,$7906
 dc.w $7847,$777F,$76AD,$75D2,$74EE,$7401,$730B,$720C,$7104,$6FF3
 dc.w $6ED9,$6DB7,$6C8C,$6B59,$6A1D,$68D9,$678D,$6639,$64DD,$6379
 dc.w $620D,$609A,$5F1F,$5D9C,$5C13,$5A82,$58EA,$574B,$55A5,$53F9
 dc.w $5246,$508D,$4ECD,$4D08,$4B3C,$496A,$4793,$45B6,$43D4,$41EC
 dc.w $4000,$3E0E,$3C17,$3A1C,$381C,$3618,$3410,$3203,$2FF3,$2DDF
 dc.w $2BC7,$29AC,$278E,$256C,$2348,$2121,$1EF7,$1CCB,$1A9D,$186C
 dc.w $163A,$1406,$11D0,$0F99,$0D61,$0B28,$08EE,$06B3,$0478,$023C
 dc.w $0000,$FDC4,$FB89,$F94D,$F712,$F4D8,$F29F,$F067,$EE30,$EBFA
 dc.w $E9C6,$E794,$E564,$E335,$E109,$DEDF,$DCB8,$DA94,$D873,$D654
 dc.w $D439,$D222,$D00D,$CDFD,$CBF1,$C9E8,$C7E4,$C5E4,$C3E9,$C1F2
 dc.w $C001,$BE14,$BC2C,$BA4A,$B86D,$B696,$B4C4,$B2F9,$B133,$AF73
 dc.w $ADBA,$AC07,$AA5B,$A8B5,$A716,$A57E,$A3EE,$A264,$A0E2,$9F67
 dc.w $9DF3,$9C87,$9B23,$99C7,$9873,$9727,$95E3,$94A7,$9374,$9249
 dc.w $9127,$900E,$8EFD,$8DF5,$8CF5,$8BFF,$8B12,$8A2E,$8953,$8882
 dc.w $87B9,$86FA,$8645,$8599,$84F6,$845E,$83CE,$8349,$82CD,$825B
 dc.w $81F3,$8194,$8140,$80F5,$80B5,$807E,$8051,$802E,$8015,$8006
 dc.w $8001,$8006,$8015,$802E,$8051,$807E,$80B4,$80F5,$8140,$8194
 dc.w $81F3,$825B,$82CD,$8349,$83CE,$845D,$84F6,$8599,$8645,$86FA
 dc.w $87B9,$8881,$8953,$8A2E,$8B12,$8BFF,$8CF5,$8DF4,$8EFC,$900D
 dc.w $9127,$9249,$9374,$94A7,$95E3,$9727,$9873,$99C7,$9B23,$9C87
 dc.w $9DF3,$9F66,$A0E1,$A263,$A3ED,$A57E,$A716,$A8B5,$AA5A,$AC06
 dc.w $ADB9,$AF73,$B132,$B2F8,$B4C4,$B695,$B86C,$BA49,$BC2C,$BE13
 dc.w $C000,$C1F2,$C3E8,$C5E4,$C7E3,$C9E7,$CBF0,$CDFC,$D00D,$D221
 dc.w $D438,$D653,$D872,$DA93,$DCB8,$DEDF,$E108,$E334,$E563,$E793
 dc.w $E9C5,$EBF9,$EE2F,$F066,$F29E,$F4D7,$F712,$F94C,$FB88,$FDC3
 dc.w $0000,$023C,$0478,$06B3,$08EE,$0B28,$0D61,$0F99,$11D0,$1406
 dc.w $163A,$186C,$1A9D,$1CCB,$1EF7,$2121,$2348,$256C,$278E,$29AC
 dc.w $2BC7,$2DDF,$2FF3,$3203,$3410,$3618,$381C,$3A1C,$3C17,$3E0E
 dc.w $3FFF,$41EC,$43D4,$45B6,$4793,$496A,$4B3C,$4D08,$4ECD,$508D
 dc.w $5246,$53F9,$55A5,$574B,$58EA,$5A82,$5C13,$5D9C,$5F1F,$609A
 dc.w $620D,$6379,$64DD,$6639,$678D,$68D9,$6A1D,$6B59,$6C8C,$6DB7
 dc.w $6ED9,$6FF3,$7104,$720C,$730B,$7401,$74EE,$75D2,$76AD,$777F
 dc.w $7847,$7906,$79BB,$7A67,$7B0A,$7BA2,$7C32,$7CB7,$7D33,$7DA5
 dc.w $7E0D,$7E6C,$7EC0,$7F0B,$7F4C,$7F82,$7FAF,$7FD2,$7FEB,$7FFA
 dc.w $7FFF

;;----------------------------- Copperlist (CHIP RAM) -------------------------

 SECTION "Chip Data",DATA_C

CopperList:
 dc.w $1fc,0
 dc.w $96,$20
 dc.w $8e,$2981
 dc.w $90,$29c1
 dc.w $92,$38
 dc.w $94,$d0
 dc.w $108,0
 dc.w $10a,0
 dc.w $e0
PlaneHi1:
 dc.w 0
 dc.w $e2
PlaneLo1:
 dc.w 0
 dc.w $e4
PlaneHi2:
 dc.w 0
 dc.w $e6
PlaneLo2:
 dc.w 0
 dc.w $e8
PlaneHi3:
 dc.w 0
 dc.w $ea
PlaneLo3:
 dc.w 0
 dc.w $ec
PlaneHi4:
 dc.w 0
 dc.w $ee
PlaneLo4:
 dc.w 0
 dc.w $f0
PlaneHi5:
 dc.w 0
 dc.w $f2
PlaneLo5:
 dc.w 0
 dc.w $100
FlickerData:
 dc.w $5200
 dc.w $180,$000		;%00000
 dc.w $182,$033		;%00001		1
 dc.w $184,$033		;%00010		1
 dc.w $186,$066		;%00011		2
 dc.w $188,$033		;%00100		1
 dc.w $18a,$066		;%00101		2
 dc.w $18c,$066		;%00110		2
 dc.w $18e,$099		;%00111		3
 dc.w $190,$033		;%01000		1
 dc.w $192,$066		;%01001		2
 dc.w $194,$066		;%01010		2
 dc.w $196,$099		;%01011		3
 dc.w $198,$066		;%01100		2
 dc.w $19a,$099		;%01101		3
 dc.w $19c,$099		;%01110		3
 dc.w $19e,$0CC		;%01111		4
 dc.w $1a0,$033		;%10000		1
 dc.w $1a2,$066		;%10001		2
 dc.w $1a4,$066		;%10010		2
 dc.w $1a6,$099		;%10011		3
 dc.w $1a8,$066		;%10100		2
 dc.w $1aa,$099		;%10101		3
 dc.w $1ac,$099		;%10110		3
 dc.w $1ae,$0CC		;%10111		4
 dc.w $1b0,$077		;%11000		2
 dc.w $1b2,$099		;%11001		3
 dc.w $1b4,$099		;%11010		3
 dc.w $1b6,$0CC		;%11011		4
 dc.w $1b8,$099		;%11100		3
 dc.w $1ba,$0CC		;%11101		4
 dc.w $1bc,$0CC		;%11110		4
 dc.w $1be,$0ff		;%11111		5
 dc.w $ffff,-2		

;---------------------------------- Bit Plane Data ----------------------------

 SECTION "Bit Planes",BSS_C

ClearStart:
SourcePlane:
 ds.b PlaneSize
Plane1:
 ds.b PlaneSize
Plane2:
 ds.b PlaneSize
Plane3:
 ds.b PlaneSize
Plane4:
 ds.b PlaneSize
Plane5:
 ds.b PlaneSize
SecondObject:
 ds.b PlaneSize
ClearEnd:
MK:
 ds.b 20000
 END
