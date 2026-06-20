*
*
*  A simple Julia routine for FPU
*  © 1993 Erik H. Bakke/Bakke SoftDev
*  Some auxillary code by PC PAY/Digital Surface
*
*
*  This routine is intended as illustration only.
*  If you use it in your own programs, give us credit
*  for it, and let us know.  (We like to keep track of how
*  our sources spread)
*
*
*  The Julia subroutine is © 1993 Erik H. Bakke/Bakke SoftDev
*  The system interface is © 1993 PC PAY/Digital Surface
*
*
*  OK, I know that this code could be more elegant, but I don't
*  have the time to do anything about it right now...  (So they all
*  say)
*
*



	include	"startup.i"			;startup code for Workbench

	include	"libraries/exec_lib.i"		;Exec library _LVO's
	include	"libraries/intuition_lib.i"	;Intution...
	include	"libraries/graphics_lib.i"	;Graphics...

	include	"intuition/intuition.i"		;Intuition related stuff
	include	"intuition/screens.i"		;Intuition screen stuff
	
Width=704					;Width of fractal
Height=1128					;Height of fractal
Depth=8						;Bitplanes used for display
Colors=256					;Colors used for display
DisplayID=DBLPALHIRESLACE_KEY			;Screenmode used for display

Init:	move.l	$4.w,a6				;Get execbase

	moveq	#36,d0				;Library version we want
	lea	(GfxName,pc),a1			;Name of library
	jsr	(_LVOOpenLibrary,a6)		;Open library
	move.l	d0,GfxBase			;Save library base
	beq.w	GfxError			;Exit if error

	moveq	#36,d0
	lea	(IntName,pc),a1
	jsr	(_LVOOpenLibrary,a6)
	move.l	d0,a6
	move.l	d0,IntBase
	beq.w	IntError

	lea	$0.w,a0				;Newscreen structure
	lea	(ScrAttrs,pc),a1		;Taglist for screen
	jsr	(_LVOOpenScreenTagList,a6)	;Open screen
	move.l	d0,Scr				;Save pointer
	beq.w	ScrError			;Exit if error
	
	lea	$0.w,a0				;Newwindow structure
	lea	(WinAttrs,pc),a1		;Taglist for window
	jsr	(_LVOOpenWindowTagList,a6)	;Open window
	move.l	d0,Win				;Save pointer
	beq.w	WinError			;Exit if error

	move.l	d0,a0				;Get window pointer
	move.l	(wd_RPort,a0),a5		;Get rastport pointer
	move.l	(GfxBase,pc),a6			;Get graphics base

	move.l	(Scr,pc),a0			;Get screen pointer
	add.l	#sc_ViewPort,a0			;Get viewport pointer
	lea	(Cols,pc),a1			;Colormap
	move.l	#Colors,d0			;Number of colors
	jsr	(_LVOLoadRGB4,a6)		;Set palette

	fmove.w	#270,fp0				;Find a good seed value
	fmove.x	fp0,fp1

	fmovecr.x	#0,fp2		        ;Calculate radians for
	fdiv.w	#180,fp2			;the trigonometric that
	fadd.x	fp2,fp2				;follows
	fmul.x	fp2,fp0
	fmul.x	fp2,fp1


	fsin.x	fp0				;Get a good starting spot
	fcos.x	fp1
	fdiv.w	#300,fp0
	fdiv.w	#300,fp1
	fmul.w	#190,fp0
	fmul.w	#190,fp1
	fmove.x	fp0,q
	fmove.x	fp1,p
	bsr	Julia				;Draw julia fractal

m:	btst	#$2,$dff016			;Wait for right mouse button
	bne	m

	move.l	(IntBase,pc),a6			;Get intuition base
	move.l	(Win,pc),a0			;Get window pointer
	jsr	(_LVOCloseWindow,a6)		;Close window
WinError:
	move.l	(Scr,pc),a0			;Get screen pointer
	jsr	(_LVOCloseScreen,a6)		;Close screen
ScrError:
	move.l	a6,a1				;Get library pointer
	move.l	$4.w,a6				;Get execbase
	jsr	(_LVOCloseLibrary,a6)		;Close library
IntError:
	move.l	(GfxBase,pc),a1			;Get library pointer
	jsr	(_LVOCloseLibrary,a6)		;Close library
GfxError:
	rts					;Exit



Julia:	fmove.l	#10000000,fp7			;Provide some decimal places
	fmove.l	#12000000,fp0		        ;xmax=1.2
	fdiv.x	fp7,fp0
	fmove.l	#-12000000,fp1			;xmin=-1.2
	fdiv.x	fp7,fp1
	fmove.l	#12000000,fp2			;ymax=1.2
	fdiv.x	fp7,fp2
	fmove.l	#-12000000,fp3			;ymin=-1.2
	fdiv.x	fp7,fp3

	fmove.x	(q,pc),fp5			;Get q and p
	fmove.x	(p,pc),fp4

	move.l	#Width,d0
	move.l	#Height,d1
	fmove.x	fp2,ymax			;Save ymax
	fsub.x	fp1,fp0				;get horizontal steprate
	fdiv.l	d0,fp0				; dx=(xmax-xmin)/width
	fsub.x	fp3,fp2				;get vertical steprate
	fdiv.l	d1,fp2				; dy=(ymax-ymin)/height

	fmove.x	fp5,fp3				;Get q
	
	fmove.x	fp0,xdelta			;save deltas
	fmove.x	fp2,ydelta
	
	move.w	#Height/2,d4			;Preload this one...

	moveq	#-$1,d7				;
.nextx	addq.w	#$1,d7				;
	cmp.w	#Width/2+1,d7			; for x=0 to 321
	beq.w	.exit
	moveq	#-$1,d6				;
.nexty	addq.w	#$1,d6				;
	cmp.w	#Height,d6			; for y=0 to 256
	beq.b	.nextx
	
	fmove.w	d7,fp7				;
	fmul.x	(xdelta,pc),fp7			; x=xc*dx+xmin
	fmove.w	d6,fp6				;
	fmul.x	(ydelta,pc),fp6			;
	fadd.x	fp1,fp7				; y=ymax-yc*dy
	fmove.x	(ymax,pc),fp0			;
	fsub.x	fp6,fp0

	fmove.w	#$0,fp6				;x²=0
	fmove.x	fp6,fp5				;y²=0

	move.w	#255,d5				;256 iterations
	moveq	#$4,d3				;preload this one too...

.iter
	fmove.x	fp6,fp2				;
	fadd.x	fp5,fp2				;if (x²+y²>4) then
	fcmp.w	d3,fp2
	fbgt.w	.growed
	fmove.x	fp7,fp6				;
	fmul.x	fp6,fp6				;x²=x*x
	fmove.x	fp0,fp5				;
	fmul.x	fp7,fp0				;y=2x*y+p
	fmul.x	fp5,fp5				;
	fadd.x	fp0,fp0				;
	fadd.x	fp4,fp0				;
	fmove.x	fp6,fp7				;x=x+q-y
	fadd.x	fp3,fp7				;
	fsub.x	fp5,fp7			
	dbf	d5,.iter

.growed
	move.w	d6,d1				;get x 
	move.w	d7,d0				;get y
	neg.w	d5
	add.w	#256,d5
	move.w	d5,d2				;get color
	ext.l	d2				;remove unwanted data
	bsr.w	PlotPoint			;Plot this point
	move.w	d6,d1				;get x
	move.w	d7,d0				;get y
	sub.w	#Width/2,d0			;
	neg.w	d0				;the julia fractal is symmetrical
	add.w	#Width/2,d0			;
	
	sub.w	d4,d1				;
	neg.w	d1				;
	add.w	d4,d1				;
	
	move.w	d5,d2				;get color
	ext.l	d2				;remove unwanted data
	bsr.w	PlotPoint			;Plot this point
	btst	#$2,$dff016
	beq	.exit
	bra.w	.nexty				;loop y-count

.exit	rts					;exit

ymax:	dc.x	0				;some variables
xdelta:	dc.x	0
ydelta:	dc.x	0
x:	dc.x	0
y:	dc.x	0
q:	dc.x	0
p:	dc.x	0

*
* d0=x d1=y d2=c
*

PlotPoint:
	movem.l	d0-d1,-(sp)			;store important registers
	move.l	(GfxBase,pc),a6			;get graphics library
	move.l	a5,a1				;Get rastport
	move.l	d2,d0				;Get color
	jsr	(_LVOSetAPen,a6)		;Set pen color
	movem.l	(sp)+,d0-d1			;restore important registers
	move.l	a5,a1				;Get rastport
	jsr	(_LVOWritePixel,a6)		;Write pixel
	rts					;Return
*-----------------------------------------------------------------------------
ScrAttrs:					;Taglist for screen
	dc.l	SA_Width,Width			;Screen width
	dc.l	SA_Height,Height		;Screen height
	dc.l	SA_Depth,Depth			;Screen depth
	dc.l	SA_Type,CUSTOMSCREEN		;Screen type
	dc.l	SA_DisplayID,DisplayID		;Screen display mode
	dc.l	TAG_END,0			;End of taglist
*-----------------------------------------------------------------------------
WinAttrs:
	dc.l	WA_Width,Width			;Window width
	dc.l	WA_Height,Height		;Window height
	dc.l	WA_Flags,WFLG_BORDERLESS	;Window flags
	dc.l	WA_CustomScreen			;Window screen pointer
Scr:	dc.l	0
	dc.l	TAG_END,0			;End of taglist
*-----------------------------------------------------------------------------
Cols:	dc.w	$000,$111,$222,$333,$444,$555,$666,$777	;colormap
	dc.w	$888,$999,$aaa,$bbb,$ccc,$ddd,$eee,$fff
	dc.w	$ffe,$ffd,$ffc,$ffb,$ffa,$ff9,$ff8,$ff7
	dc.w	$ff6,$ff5,$ff4,$ff3,$ff2,$ff1,$ff0,$fe0

	dc.w	$fd0,$fc0,$fb0,$fa0,$f90,$f80,$f70,$f60
	dc.w	$f50,$f40,$f30,$f20,$f10,$f00,$f01,$f02
	dc.w	$f03,$f04,$f05,$f06,$f07,$f08,$f09,$f0a
	dc.w	$f0b,$f0d,$f0e,$f0f,$e0f,$d0f,$c0f,$b0f

	dc.w	$a0f,$90f,$80f,$70f,$60f,$50f,$40f,$30f
	dc.w	$20f,$10f,$00f,$01f,$02f,$03f,$04f,$05f
	dc.w	$06f,$07f,$08f,$09f,$0af,$0bf,$0cf,$0df
	dc.w	$0ef,$0ff,$1ef,$2df,$3cf,$4bf,$5af,$69f

	dc.w	$78f,$87f,$96f,$a5f,$b4f,$c3f,$d2f,$e1f
	dc.w	$f0f,$f1f,$f2f,$f3f,$f4f,$f5f,$f6f,$f7f
	dc.w	$f8f,$f9f,$faf,$fbf,$fcf,$fdf,$fef,$fff
	dc.w	$eef,$ddf,$ccf,$bbf,$aaf,$99f,$88f,$77f

	dc.w	$66f,$55f,$44f,$33f,$22f,$11f,$00f,$01e
	dc.w	$888,$999,$aaa,$bbb,$ccc,$ddd,$eee,$fff
	dc.w	$ffe,$ffd,$ffc,$ffb,$ffa,$ff9,$ff8,$ff7
	dc.w	$ff6,$ff5,$ff4,$ff3,$ff2,$ff1,$ff0,$fe0

	dc.w	$000,$111,$222,$333,$444,$555,$666,$777	;The last 3 blocks
	dc.w	$888,$999,$aaa,$bbb,$ccc,$ddd,$eee,$fff ;are repetition...
	dc.w	$ffe,$ffd,$ffc,$ffb,$ffa,$ff9,$ff8,$ff7
	dc.w	$ff6,$ff5,$ff4,$ff3,$ff2,$ff1,$ff0,$fe0

	dc.w	$000,$111,$222,$333,$444,$555,$666,$777
	dc.w	$888,$999,$aaa,$bbb,$ccc,$ddd,$eee,$fff
	dc.w	$ffe,$ffd,$ffc,$ffb,$ffa,$ff9,$ff8,$ff7
	dc.w	$ff6,$ff5,$ff4,$ff3,$ff2,$ff1,$ff0,$fe0

	dc.w	$000,$111,$222,$333,$444,$555,$666,$777
	dc.w	$888,$999,$aaa,$bbb,$ccc,$ddd,$eee,$fff
	dc.w	$ffe,$ffd,$ffc,$ffb,$ffa,$ff9,$ff8,$ff7
	dc.w	$ff6,$ff5,$ff4,$ff3,$ff2,$ff1,$ff0,$000
*-----------------------------------------------------------------------------
Win:		dc.l	0			;Window pointer
IntBase:	dc.l	0			;Intuition library pointer
GfxBase:	dc.l	0			;Graphics library pointer
IntName:	dc.b	"intuition.library",0
GfxName:	dc.b	"graphics.library",0
