	
; Trainermenu by Einstein/Sceptic V0.985
; Sound and GFX by Flite/Sceptic
; Questions, bug reports or ideas .... leave me a messy on PALERIDER

; la tabella ha valori doppi come linevecs

; DO NOT SPREAD THIS SOURCE

auge		=	1024
obj		=	00


;------------------------------------------------------------------------------

xspeed		=	2	; Rotation Speed of Vectors x-,y-,zspeed
yspeed		=	1
zspeed		=	3
;------------------------------------------------------------------------------


start:
		movem.l	d0-a6,-(A7)

		lea	$dff000,a5

		move.w	$1c(A5),d0
		or.w	#$8000,d0
		move.w	d0,-(A7)

		move.w	$1e(A5),d0
		or.w	#$8000,d0
		move.w	d0,-(A7)
		
		move.w	#$7fff,$9a(a5)
		move.w	#$7fff,$9c(a5)
		


		lea	linebpl,a1
		moveq	#4-1,d7
.ilinebpl	move.l	a0,d0
		move.w	d0,6(a1)
		swap	d0
		move.w	d0,2(a1)
		addq.l	#8,a1
		lea	40(a0),a0
		dbf	d7,.ilinebpl
		
		lea	vecbpl1,a0
		lea	vecbpladr,a1
		move.l	a0,d0
		move.w	d0,6(A1)
		swap	d0
		move.w	d0,2(A1)

		
		lea	lines(pc),a0
		subq.w	#1,(A0)
		move.w	(A0)+,d7
.lineloop	move.w	(A0),d0
		asl.w	#2,d0
		move.w	d0,(a0)+
		move.w	(A0),d0
		asl.w	#2,d0
		move.w	d0,(a0)+
		dbf	d7,.lineloop

		lea	dots(pc),a0
		subq.w	#1,(A0)
		move.w	(A0)+,d7
.dotloop	move.w	(A0),d0
		sub.w	#160,d0
		move.w	d0,(A0)+
		move.w	(a0),d0
		sub.w	#128,d0
		move.w	d0,(A0)+
		dbf	d7,.dotloop

		move.l	$6c,-(a7)
		move.l	#vbi,$6c
		
		lea	coplist,a0
		move.l	a0,$80(A5)
		clr.w	$88(A5)
		
		move.w	#$c010,$9a(a5)


.waitoff1	btst	#6,$bfe001
		bne.s	.waitoff1

		move.l	4.w,a6
		lea	gfxname(pc),a1
		jsr	-408(A6)
		move.l	d0,a1
		move.l	38(A1),$80(A5)
		jsr	-414(A6)
		move.l	(a7)+,$6c
		move.w	#$8020,$96(a5)
		move.w	#$7fff,$9a(a5)
		move.w	#$7fff,$9c(a5)
		move.w	(a7)+,$9c(a5)
		move.w	(a7)+,$9a(a5)
		movem.l	(a7)+,d0-a6
		moveq	#0,d0
		rts
;------------------------------------------------------------------------------

;******************************************************************************
;------------------------------------------------------------------------------
vbi		movem.l	d0-a6,-(a7)
		lea	$dff000,a5
		bsr	dovecs
		move.w	#$10,$9c(a5)
		movem.l	(A7)+,d0-a6
		rte

;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
dovecs		lea	dbadrs(pc),a0
		move.l	(A0),d0
		move.l	4(A0),(a0)+
		move.l	4(A0),(A0)+
		move.l	4(a0),(A0)+
		move.l	4(A0),(A0)+
		move.l	d0,(A0)
		
		lea	dbadrs+4(pc),a0
		lea	vecbpladr,a1
		moveq	#4-1,d7
.loop		move.l	(A0)+,d0
		add.l	#33*40,d0
		move.w	d0,6(A1)
		swap	d0
		move.w	d0,2(A1)
		addq.l	#8,a1
		dbf	d7,.loop
wblit1:
		btst.b	#6,2(a5)
		btst.b	#6,2(a5)
		bne.s	wblit1

		move.l	dbadrs(pc),a0
		lea	30*40(a0),a0
		move.l	a0,$54(A5)
		move.l	#$01000000,$40(A5)
		move.w	#0,$66(A5)
		move.w	#200*64+20,$58(A5)

		lea	sinus(pc),a6
		lea	xangle(pc),a4
		move.w	(a4),d0
		add.w	#xspeed,d0
		cmp.w	#360,d0
		blt.s	.xangleok
		sub.w	#360,d0
.xangleok	move.w	d0,(a4)
		add.w	d0,d0
		move.w	(a6,d0.w),d3
		add.w	#180,d0
		move.w	(a6,d0.w),d4
		
		lea	yangle(pc),a4
		move.w	(a4),d0
		add.w	#yspeed,d0
		cmp.w	#360,d0
		blt.s	.yangleok
		sub.w	#360,d0
.yangleok	move.w	d0,(a4)
		add.w	d0,d0
		move.w	(a6,d0.w),a0
		add.w	#90,d0
		move.w	90(a6,d0.w),a1
		
		lea	zangle(pc),a4
		move.w	(a4),d0
		add.w	#zspeed,d0
		cmp.w	#360,d0
		blt.s	.zangleok
		sub.w	#360,d0
.zangleok	move.w	d0,(a4)
		add.w	d0,d0
		move.w	(a6,d0.w),a2
		add.w	#180,d0
		move.w	(a6,d0.w),a3
		
		; d0 - x
 		; d1 - y
		; d2 - z
		; d3 - Sin Alpha
		; d4 - Cos Alpha
		; d5 - Calculate Òegisteò
		; d6 - Calculate Register
		; d7 - Loop Counter
		; a0 - Sin Beta
		; a1 - Cos Beta
		; a2 - Sin Gamma
		; a3 - Cos Gamma
		; a4 - Dots
		; a5 - $dff000
		; a6 - DestiDots
		; a7 - Stack
		
		lea	dots(pc),a4
		lea	coordbuf(pc),a6
		move.w	(a4)+,d7
.rotateloop	movem.w	(a4)+,d0-d1		; Get Coords
		moveq	#0,d2

		; x - Rotation
		move.w	d2,d5		; z - d5
		muls	d4,d5		; cos(alpha)*z
		move.w	d1,d6		; y - d6
		muls	d3,d6		; sin(alpha)*y		
		add.l	d6,d5		; cos(alpha)*z+sin(alpha)*y
		add.l	d5,d5
		swap	d5
		muls	d4,d1		; cos(alpha)*y
		move.w	d2,d6		; z - d6
		muls	d3,d6		; sin(alpha)*z
		sub.l	d6,d1		; cos(alpha)*y-sin(alpha)*z
		add.l	d1,d1
		swap	d1
		move.w	d5,d2		; new z - d2		

		; y - Rotation
		move.w	a1,d5
		muls	d0,d5		; cos(beta)*x
		move.w	a0,d6
		muls	d2,d6		; sin(beta)*z
		add.l	d6,d5		; cos(beta)*x+sin(beta)*z
		add.l	d5,d5
		swap	d5
		move.w	a1,d6
		muls	d6,d2		; cos(beta)*z	
		move.w	a0,d6
		muls	d0,d6		; sin(beta)*x
		sub.l	d6,d2		; cos(beta)*z-sin(beta)*z
		add.l	d2,d2
		swap	d2
		move.w	d5,d0
						
		; z - Rotation
		move.w	a3,d5
		muls	d0,d5		; cos(gamma)*x
		move.w	a2,d6
		muls	d1,d6		; sin(gamma)*y
		add.l	d6,d5
		add.l	d5,d5
		swap	d5
		move.w	a3,d6
		muls	d6,d1		; cos(gamma)*y
		move.w	a2,d6
		muls	d0,d6		; sin(gamma)*x
		sub.l	d6,d1		; cos(gamma)*y-sin(gamma)*x
		add.l	d1,d1
		swap	d1
		move.w	d5,d0

		; 3d(x,y,z) - 2d(x,y)
		moveq	#10,d6
		move.w	#auge,d5	;auge
		add.w	#obj,d2
		sub.w	d5,d2
		ext.l	d0
		asl.l	d6,d0
		divs	d2,d0		;punkt x*auge/(punkt z-auge)
		neg.w	d0		;wert negieren
		add.w	#160,d0		;x coord addi 
		move.w	d0,(a6)+	;x
		ext.l	d1
		asl.l	d6,d1
		divs	d2,d1		;punkt y*auge/(punkt z-auge)
		add.w	#128,d1		;y coord addi
		move.w	d1,(a6)+	;y

		dbf	d7,.rotateloop

wblit2:
		btst.b	#6,2(a5)
		btst.b	#6,2(a5)
		bne.s	wblit2

		move.w	#$ffff,$72(a5)	
		move.w	#$ffff,$44(a5)	
		move.w	#$8000,$74(a5)
		moveq	#40,d4
		move.w	d4,$60(a5)
		move.w	d4,$66(a5)

		lea	lines(pc),a1
		lea	coordbuf(pc),a2

		move.w	(A1)+,d7
.lineloop	movem.w	(a1)+,d4-d5
		movem.w	(a2,d4.w),d0-d1
		movem.w	(a2,d5.w),d2-d3
		move.l	dbadrs(pc),a0
		bsr	drawline
		dbf	d7,.lineloop

wblit3:
		btst.b	#6,2(a5)
		btst.b	#6,2(a5)
		bne.s	wblit3

		move.l	dbadrs(pc),a0
		lea	320*240/8(a0),a0
		move.l	a0,$50(A5)
		move.l	a0,$54(A5)
		move.l	#-$1,$44(A5)
		move.l	#$09f00012,$40(A5)
		move.w	#0,d0
		move.w	d0,$64(A5)
		move.w	d0,$66(A5)		
		move.w	#220*64+20,$58(A5)

		rts
;------------------------------------------------------------------------------
outtxt		lea	offtab(pc),a2
		move.b	6*56(a4),6*40(a1)
		addq.l	#1,a1

.nnchar		rts
;------------------------------------------------------------------------------
; d0,d1,d2,d3	Coords
;------------------------------------------------------------------------------
drawline	move.w	d7,-(A7)
		cmp.w	d1,d3
		bgt.s	nohi2
		exg	d0,d2
		exg	d1,d3
nohi2		move.w	d0,d4
		move.w	d1,d5
		mulu	#40,d5
		add.w	d5,a0
		lsr.w	#4,d4
		add.w	d4,d4
		lea	(a0,d4.w),a0
		sub.w	d0,d2
		sub.w	d1,d3
		moveq	#$f,d5
		and.l	d5,d0
		moveq	#0,d7
		move.w	d0,d4
		eor.w	d5,d4
		bset	d4,d7
		ror.l	#4,d0
		move	#4,d0
		tst.w	d2
		bpl.s	l12
		addq.w	#1,d0
		neg.w	d2
l12		cmp.w	d2,d3
		ble.s	l21
		exg	d2,d3
		subq.w	#4,d0
		add.w	d0,d0
l21		move.w	d3,d4
		sub.w	d2,d4
		add.w	d4,d4
		add.w	d4,d4
		add.w	d3,d3
		move.w	d3,d6
		sub.w	d2,d6
		bpl.s	l31
		or.w	#16,d0
l31		add.w	d3,d3
		add.w	d0,d0
		add.w	d0,d0
		addq.w	#1,d2
		lsl.w	#6,d2
		addq.w	#2,d2
		swap	d3
		move.w	d4,d3
		or.l	#$0b5a0003,d0

wblit4:
		btst.b	#6,2(a5)
		btst.b	#6,2(a5)
		bne.s	wblit4

		eor.w	d7,(a0)
		move.l	d3,$62(a5)
		move	d6,$52(a5)
		move.l	a0,$48(a5)
		move.l	a0,$54(a5)
		move.l	d0,$40(a5)
		move	d2,$58(a5)
		move.w	(A7)+,d7
		rts


gfxname		dc.b	"graphics.library",0,0
oldvbi		dc.l	0
xangle		dc.w	0
yangle		dc.w	0
zangle		dc.w	0
coordbuf	DCB.l	100,0
dbadrs		dc.l	vecbpl1
		dc.l	vecbpl2
		dc.l	vecbpl3
		dc.l	vecbpl4
		dc.l	vecbpl5


offtab		DCB.b	255,0
scrollofftab	DCB.b	255,0
		even

dots		dc.w	$001F
		dc.l	$002800A9
		dc.l	$006700A9,$0076009A,$00280095,$00500095
		dc.l	$0049006D,$0028006D,$003E0057,$00760057
		dc.l	$0076006D,$00660082,$00910057,$008D00A9
		dc.l	$00B900A9,$00B90057,$00B90095,$00B9006D
		dc.l	$00850081,$00990095,$0099006D,$00BD00A9
		dc.l	$00D600A9,$00BD0057,$00FC0057,$00BD0076
		dc.l	$00EB0076,$00D6008A,$00BD006D,$00F4006D
		dc.l	$00F7008A,$0113006E

lines		dc.l	$001F0001
		dc.l	$00000002,$00010005,$00020003,$00000004
		dc.l	$00030006,$00040007,$00060008,$00070008
		dc.l	$00090009,$0005000B,$000A000C,$000A000D
		dc.l	$000C000B,$000E000E,$0010000D,$000F000F
		dc.l	$00120011,$00120013,$00110010,$00130015
		dc.l	$00140018,$00140019,$0018001C,$0019001B
		dc.l	$001C0016,$001B0017,$0016001A,$0015001D
		dc.l	$001A001E,$001D0017
		dc.w	$001E


sinus		dc.w	0,572,1144,1715,2286,2856,3425,3993
		dc.w	4560,5126,5690,6252,6813,7371,7927,8481
		dc.w	9032,9580,10126,10668,11207,11747,12275,12803
		dc.w	13328,13848,14364,14876,15383,15886,16383,16876
		dc.w	17364,17846,18323,18794,19260,19720,20173,20621
		dc.w	21062,21497,21925,22347,22762,23170,23571,23964
		dc.w	24351,24730,25101,25465,25821,26169,26509,26841
		dc.w	27165,27481,27788,28087,28377,28659,28932,29196
		dc.w	29451,29697,29934,30162,30381,30591,30791,30982
		dc.w	31163,31335,31498,31650,31794,31927,32051,32165
		dc.w	32269,32364,32448,32523,32588,32642,32687,32722
		dc.w	32747,32762,32767,32762,32747,32722,32687,32642
		dc.w	32587,32523,32448,32364,32269,32165,32051,31927
		dc.w	31794,31650,31498,31335,31163,30982,30791,30591
		dc.w	30381,30162,29934,29697,29451,29196,28932,28659
		dc.w	28377,28087,27788,27481,27165,26841,26509,26169
		dc.w	25821,25465,25101,24730,24351,23964,23571,23170
		dc.w	22762,22347,21925,21497,21062,20621,20173,19720
		dc.w	19260,18794,18323,17846,17364,16876,16384,15886
		dc.w	15383,14876,14364,13848,13328,12803,12275,11743
		dc.w	11207,10668,10126,9580,9032,8481,7927,7371
		dc.w	6813,6252,5690,5126,4560,3993,3425,2856
		dc.w	2286,1715,1144,572,0,-571,-1143,-1714
		dc.w	-2285,-2855,-3424,-3993,-4560,-5125,-5689,-6252
		dc.w	-6812,-7370,-7926,-8480,-9031,-9579,-10125,-10667
		dc.w	-11206,-11742,-12274,-12802,-13327,-13847,-14363,-14875
		dc.w	-15382,-15885,-16383,-16876,-17363,-17845,-18322,-18794
		dc.w	-19259,-19719,-20173,-20620,-21061,-21496,-21925,-22346
		dc.w	-22761,-23169,-23570,-23964,-24350,-24729,-25100,-25464
		dc.w	-25820,-26168,-26508,-26840,-27164,-27480,-27787,-28086
		dc.w	-28376,-28658,-28931,-29195,-29450,-29696,-29933,-30162
		dc.w	-30380,-30590,-30790,-30981,-31163,-31335,-31497,-31650
		dc.w	-31793,-31927,-32050,-32164,-32269,-32363,-32448,-32522
		dc.w	-32587,-32642,-32687,-32722,-32747,-32762,-32767,-32762
		dc.w	-32747,-32722,-32687,-32642,-32587,-32522,-32448,-32363
		dc.w	-32269,-32165,-32051,-31927,-31793,-31650,-31497,-31335
		dc.w	-31163,-30981,-30791,-30590,-30381,-30162,-29934,-29697
		dc.w	-29451,-29195,-28931,-28658,-28377,-28087,-27788,-27481
		dc.w	-27165,-26841,-26509,-26169,-25821,-25465,-25101,-24729
		dc.w	-24351,-23964,-23571,-23170,-22762,-22347,-21925,-21497
		dc.w	-21062,-20621,-20173,-19720,-19260,-18794,-18323,-17846
		dc.w	-17364,-16876,-16384,-15886,-15383,-14876,-14364,-13848
		dc.w	-13328,-12803,-12275,-11743,-11207,-10668,-10126,-9580
		dc.w	-9032,-8481,-7927,-7371,-6813,-6252,-5690,-5126
		dc.w	-4560,-3994,-3425,-2856,-2286,-1715,-1144,-572
		dc.w	0,572,1144,1715,2286,2856,3425,3993
		dc.w	4560,5126,5690,6252,6813,7371,7927,8481
		dc.w	9032,9580,10126,10668,11207,11743,12275,12803
		dc.w	13328,13848,14364,14876,15383,15886,16383,16876
		dc.w	17364,17846,18323,18794,19260,19720,20173,20621
		dc.w	21062,21497,21925,22347,22762,23170,23571,23964
		dc.w	24351,24730,25101,25465,25821,26169,26509,26841
		dc.w	27165,27481,27788,28087,28377,28659,28932,29196
		dc.w	29451,29697,29934,30162,30381,30591,30791,30982
		dc.w	31163,31335,31498,31650,31794,31927,32051,32165
		dc.w	32269,32364,32448,32523,32588,32642,32687,32722
		dc.w	32747,32762,32767,32762,32747,32722,32687,32642
		dc.w	32587,32523,32448,32364,32269,32165,32051,31927
		dc.w	31794,31650,31498,31335,31163,30982,30791,30591
		dc.w	30381,30162,29934,29697,29451,29196,28932,28659
		dc.w	28377,28087,27788,27481,27165,26841,26509,26169
		dc.w	25821,25465,25101,24730,24351,23964,23571,23170
		dc.w	22762,22347,21925,21497,21062,20621,20173,19720
		dc.w	19260,18794,18323,17846,17364,16876,16384,15886
		dc.w	15383,14876,14364,13848,13328,12803,12275,11743
		dc.w	11207,10668,10126,9580,9032,8481,7927,7371
		dc.w	6813,6252,5690,5126,4560,3993,3425,2856
		dc.w	2286,1715,1144,572,0
;------------------------------------------------------------------------------

		section	data,data_c
		
coplist:
		dc.w	$1fc,0
		dc.w	$106,0
		dc.l	$008e2c81,$00902ce1
		dc.l	$00920038,$009400d0
		dc.l	$01020000
		dc.l	$01080000+40*3
		dc.l	$010a0000+40*3
logobpl		dc.l	$00e00000,$00e20000
		dc.l	$00e40000,$00e60000
		dc.l	$00e80000,$00ea0000
		dc.l	$00ec0000,$00ee0000
		dc.l	$01000200
		dc.l	$00960020,$01400000,$01420000

		dc.l	$01800000
		dc.l	$01820DCD
		dc.l	$01840EDF
		dc.l	$01860012
		dc.l	$01880DCE
		dc.l	$018A0CBD
		dc.l	$018C0BAC
		dc.l	$018E0A9B
		dc.l	$0190098A
		dc.l	$01920879
		dc.l	$01940768
		dc.l	$01960657
		dc.l	$01980546
		dc.l	$019A0435
		dc.l	$019C0324
		dc.l	$019E0213
		dc.l	$560ffffe,$01800102
		
		dc.l	$580ffffe,$01000000
		dc.l	$008e2c81,$00902ce1
		dc.l	$00920038,$009400d0
		dc.l	$01080000,$010a0000,$01020000

origcols	dc.l	$01800102,$01820335,$01840557,$01860557
		dc.l	$01880779,$018a0779,$018c0779,$018e0779
		dc.l	$0190099b,$0192099b,$0194099b,$0196099b
		dc.l	$0198099b,$019a099b,$019c099b,$019e099b

tochangecols	dc.l	$01a00fff,$01a20def,$01a40def,$01a60def
		dc.l	$01a80def,$01aa0def,$01ac0def,$01ae0def
		dc.l	$01b00def,$01b20def,$01b40def,$01b60def
		dc.l	$01b80def,$01ba0def,$01bc0def,$01be0def

		dc.l	$590ffffe		
		dc.l	$01004200
vecbpladr	dc.l	$00e00000,$00e20000
		dc.l	$00e40000,$00e60000
		dc.l	$00e80000,$00ea0000
		dc.l	$00ec0000,$00ee0000
		dc.l	$00f00000,$00f20000

		dc.l	$600ffffe
		dc.l	$01800102,$01820335,$01840557,$01860557
		dc.l	$01880779,$018a0779,$018c0779,$018e0779
		dc.l	$0190099b,$0192099b,$0194099b,$0196099b
		dc.l	$0198099b,$019a099b,$019c099b,$019e099b

		dc.l	$700ffffe
		dc.l	$01800102,$01820335,$01840557,$01860557
		dc.l	$01880779,$018a0779,$018c0779,$018e0779
		dc.l	$0190099b,$0192099b,$0194099b,$0196099b
		dc.l	$0198099b,$019a099b,$019c099b,$019e099b

		dc.l	$ffdffffe,$009c8010

		dc.l	$150ffffe,$01000000
		dc.l	$008e2c81,$00902ce1
		dc.l	$00920038,$009400d0
		dc.l	$01080000+40*3,$010a0000+40*3
		dc.l	$01800000,$01820DCD,$01840EDF,$01860012
		dc.l	$01880DCE,$018A0CBD,$018C0BAC,$018E0A9B
		dc.l	$0190098A,$01920879,$01940768,$01960657
		dc.l	$01980546,$019A0435,$019C0324,$019E0213
		dc.l	$160ffffe
linebpl		dc.l	$00e00000,$00e20000
		dc.l	$00e40000,$00e60000
		dc.l	$00e80000,$00ea0000
		dc.l	$00ec0000,$00ee0000
		dc.l	$01000200

		dc.l	$01820123,$01820225,$01820436,$01820447
		dc.l	$01820558,$01820669,$0182067a,$0182078b
		dc.l	$0182089b,$018209ac,$01820abd,$01820bcd
		dc.l	$01820cde,$01820dee,$01820fff,$01820fff
		dc.l	$01820fff,$01820fff,$01820fff,$01820fff
		dc.l	$01820fff,$01820fff,$01820dee,$01820cde
		dc.l	$01820bcd,$01820abd,$018209ac,$0182089b
		dc.l	$0182078b,$0182067a,$01820669,$01820558
		dc.l	$01820447,$01820436,$01820225,$01820123,$01820000
		
		dc.l	$1f0ffffe
		dc.l	$01820fff		
		
		dc.l	$240ffffe,$01000000
		dc.l	$fffffffe
		


		section	buffer,bss_c


vecbpl1		ds.b	320*270/8
vecbpl2		ds.b	320*270/8
vecbpl3		ds.b	320*270/8
vecbpl4		ds.b	320*270/8
vecbpl5		ds.b	320*270/8

