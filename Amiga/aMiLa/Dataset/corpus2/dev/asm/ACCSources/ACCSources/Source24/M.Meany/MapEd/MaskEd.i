
; Block mask editor subroutines and data

*************** Present the Mask Editor

; Allows mask of currently active block to be edited.

DoBME		move.l		ThisBlock(a4),a0	data addr
		move.l		_Depth(a4),d0		block depth
		asl.w		#5,d0			x bytes per plane
		adda.l		d0,a0			a0->blocks mask
		move.l		a0,BMEAddr(a4)		save address
		
		lea		BMEWindow,a0		a0->window args

		move.l		screen.ptr(a4),nw_Screen(a0)

		CALLINT		OpenWindow		and open it
		move.l		d0,BMEwin.ptr(a4)	save struct ptr
		beq		.error			quit if error

		move.l		d0,a0			a0->win struct	
		move.l		wd_UserPort(a0),BMEwin.up(a4) save up ptr
		move.l		wd_RPort(a0),BMEwin.rp(a4)    save rp ptr

; Draw borders - make it look nice

		move.l		BMEwin.rp(a4),a0	RastPort
		lea		BMEBorder,a1		Border
		moveq.l		#0,d0			X
		moveq.l		#0,d1			Y
		CALLINT		DrawBorder		draw 'em

; Add some text as well!

		move.l		BMEwin.rp(a4),a0	RastPort
		lea		BMEText,a1		IntuiText
		moveq.l		#0,d0			X
		moveq.l		#0,d1			Y
		CALLINT		PrintIText		draw 'em

; Copy mask to window

		move.l		BMEAddr(a4),a0		addr of mask
		bsr		BuildTmpMask

		bsr		RenderBlock		draw block & mask

		bsr		RenderMask		draw current mask
		
		bsr		RenderSMask		draw saved mask

; Deal with User interaction

.WaitForMsg	move.l		BMEwin.up(a4),a0	a0->user port
		CALLEXEC	WaitPort		wait for event
		move.l		BMEwin.up(a4),a0	a0->user port
		CALLSYS		GetMsg			get any messages
		tst.l		d0			was there a message ?
		beq.s		.WaitForMsg		if not loop back
		move.l		d0,a1			a1-->message
		move.l		im_Class(a1),d2		d2=IDCMP flags
		move.w		im_Code(a1),d3		key/mouse
		move.w		im_MouseX(a1),d4	mouse X coord
		move.w		im_MouseY(a1),d5	mouse Y coord
		move.l		im_IAddress(a1),a5 	a5=addr of structure
		CALLSYS		ReplyMsg		answer os

		cmp.l		#MOUSEBUTTONS,d2	mouse button pressed?
		bne.s		.test_tick		skip if not
		cmp.w		#SELECTDOWN,d3		check left down
		bne.s		.test_LMBup
		move.l		#1,SetBit(a4)
		bra		.WaitForMsg

.test_LMBup	cmp.w		#SELECTUP,d3		check left up
		bne.s		.test_RMBdown
		move.l		#0,SetBit(a4)
		bra		.WaitForMsg

.test_RMBdown	cmp.w		#MENUDOWN,d3		check right down
		bne.s		.test_RMBup
		move.l		#1,ClrBit(a4)
		bra		.WaitForMsg

.test_RMBup	cmp.w		#MENUUP,d3		check right up
		bne.s		.WaitForMsg
		move.l		#0,ClrBit(a4)
		bra		.WaitForMsg

.test_tick	cmp.l		#INTUITICKS,d2		check timer
		bne.s		.test_Gadg
		tst.l		SetBit(a4)
		beq.s		.t1
		bsr		SetMaskBit
		bsr		RenderMask
		bra		.WaitForMsg

.t1		tst.l		ClrBit(a4)
		beq		.WaitForMsg
		bsr		ClrMaskBit
		bsr		RenderMask
		bra		.WaitForMsg

.test_Gadg	cmp.l		#GADGETUP,d2		check gadget
		bne.s		.test_win
		move.l		gg_UserData(a5),d0
		beq		.WaitForMsg
		move.l		d0,a0
		jsr		(a0)

.test_win	cmp.l		#CLOSEWINDOW,d2  	window closed ?
		bne		.WaitForMsg	 	if not then jump

; Close the Intuition Block Mask Editor window.

		move.l		BMEwin.ptr(a4),a0	a0->Window struct
		CALLINT		CloseWindow		and close it

.error		moveq.l		#0,d2			not quitting
		rts

***************	Set a bit in the Mask

; Entry		d4.w = Mouse X coord
;		d5.w = Mouse Y coord

SetMaskBit	movem.l		d0-d6,-(sp)
		moveq.l		#0,d0
		move.l		d0,d1
		move.w		d4,d0			X
		move.w		d5,d1			Y

		asr.w		#2,d0
		subq.w		#5,d0			starts at x = 20
		bmi.s		.done
		cmp.w		#16,d0			only 0->15 supported
		bge.s		.done
		
		asr.w		#2,d1
		subq.w		#5,d1			starts at x = 20
		bmi.s		.done
		cmp.w		#16,d1			only 0->15 supported
		bge.s		.done
		
; X= 0->15, Y= 0->15

		moveq.l		#15,d4
		sub.w		d0,d4
		move.w		d1,d5
		asl.l		#1,d5
		
		move.w		MaskBits(a4,d5),d6
		bset.l		d4,d6
		move.w		d6,MaskBits(a4,d5)
		
		asl.w		#2,d0
		add.w		#20,d0
		
		asl.w		#2,d1
		add.w		#20,d1
		
		move.l		BMEwin.rp(a4),a0	Window
		lea		MaskImage,a1		Image
		move.l		#im1,ig_ImageData(a1)
		CALLINT		DrawImage

.done		movem.l		(sp)+,d0-d6
		rts

*************** Clear a bit in the mask

; Entry		d4.w = Mouse X coord
;		d5.w = Mouse Y coord

ClrMaskBit	movem.l		d0-d6,-(sp)
		moveq.l		#0,d0
		move.l		d0,d1
		move.w		d4,d0			X
		move.w		d5,d1			Y

		asr.w		#2,d0
		subq.w		#5,d0			starts at x = 20
		bmi.s		.done
		cmp.w		#16,d0			only 0->15 supported
		bge.s		.done
		
		asr.w		#2,d1
		subq.w		#5,d1			starts at x = 20
		bmi.s		.done
		cmp.w		#16,d1			only 0->15 supported
		bge.s		.done
		
; X= 0->15, Y= 0->15

		moveq.l		#15,d4
		sub.w		d0,d4
		move.w		d1,d5
		asl.l		#1,d5
		
		move.w		MaskBits(a4,d5),d6
		bclr.l		d4,d6
		move.w		d6,MaskBits(a4,d5)
		
		asl.w		#2,d0
		add.w		#20,d0
		
		asl.w		#2,d1
		add.w		#20,d1
		
		move.l		BMEwin.rp(a4),a0	Window
		lea		MaskImage,a1		Image
		move.l		#im2,ig_ImageData(a1)
		CALLINT		DrawImage
		
.done		movem.l		(sp)+,d0-d6
		rts

***************	Copy a mask into temporay buffer for editing

; Entry		a0->mask data to display and edit

BuildTmpMask	lea		MaskBits(a4),a1		temp mask buffer
		move.l		(a0)+,(a1)+		copy mask
		move.l		(a0)+,(a1)+
		move.l		(a0)+,(a1)+
		move.l		(a0)+,(a1)+
		move.l		(a0)+,(a1)+
		move.l		(a0)+,(a1)+
		move.l		(a0)+,(a1)+
		move.l		(a0)+,(a1)+

		moveq.l		#0,d7			Y
.Outer		moveq.l		#0,d6			X
		move.w		d7,d3			Y
		asl.w		#1,d3			y*2 = line offset
		move.w		MaskBits(a4,d3),d3	bit pattern

.Inner		move.l		d7,d5			Y
		asl.w		#2,d5			Y*4
		add.w		#20,d5			add offset
		move.l		d6,d4			X
		asl.w		#2,d4			X*4
		add.w		#20,d4			add offset
		asl.w		#1,d3			high bit into CARRY
		bcc.s		.clearit		skip if bit = 0
		bsr		SetMaskBit		else draw solid
		bra.s		.next			and skip

.clearit	bsr		ClrMaskBit		draw blank

.next		addq.w		#1,d6			bump X
		cmp.w		#16,d6			end of line?
		bne.s		.Inner			loop if not
		
		addq.w		#1,d7			bump Y
		cmp.w		#16,d7			all lines done
		bne		.Outer			loop if not

		bsr		RenderMask
		
		rts

***************	User selected USE option, so copy mask into data buffer

BMEUse		move.l		BMEAddr(a4),a1		dest
		lea		MaskBits(a4),a0		Src

		move.l		(a0)+,(a1)+		copy mask
		move.l		(a0)+,(a1)+
		move.l		(a0)+,(a1)+
		move.l		(a0)+,(a1)+
		move.l		(a0)+,(a1)+
		move.l		(a0)+,(a1)+
		move.l		(a0)+,(a1)+
		move.l		(a0)+,(a1)+
		
		moveq.l		#0,d7			set flag
		move.l		#CLOSEWINDOW,d2		signal all done
		rts					and exit

***************	User selected CANCEL option, so abort

BMECancel	moveq.l		#0,d7			clear flag
		move.l		#CLOSEWINDOW,d2		signal all done
		rts

***************	Clear the mask, set all bits to 0

ClrMask		lea		MaskBits(a4),a0		a0-> mask buffer
		moveq.l		#0,d0			clear
		move.l		d0,(a0)+
		move.l		d0,(a0)+
		move.l		d0,(a0)+
		move.l		d0,(a0)+
		move.l		d0,(a0)+
		move.l		d0,(a0)+
		move.l		d0,(a0)+
		move.l		d0,(a0)+

		lea		MaskBits(a4),a0		mask buffer
		bsr		BuildTmpMask

		bsr		RenderMask
		
		moveq.l		#0,d2			not quitting
		rts

***************	Fill the mask, set all bits to 1

FillMask	lea		MaskBits(a4),a0		a0-> mask buffer
		moveq.l		#-1,d0			clear
		move.l		d0,(a0)+
		move.l		d0,(a0)+
		move.l		d0,(a0)+
		move.l		d0,(a0)+
		move.l		d0,(a0)+
		move.l		d0,(a0)+
		move.l		d0,(a0)+
		move.l		d0,(a0)+

		lea		MaskBits(a4),a0		mask buffer
		bsr		BuildTmpMask
		
		bsr		RenderMask

		moveq.l		#0,d2			not quitting
		rts

***************	Set mask = to saved mask

BMERestore	lea		MaskBits(a4),a1		dest
		lea		StoredMask(a4),a0	Src

		move.l		(a0)+,(a1)+		copy mask
		move.l		(a0)+,(a1)+
		move.l		(a0)+,(a1)+
		move.l		(a0)+,(a1)+
		move.l		(a0)+,(a1)+
		move.l		(a0)+,(a1)+
		move.l		(a0)+,(a1)+
		move.l		(a0)+,(a1)+

		lea		MaskBits(a4),a0		mask buffer
		bsr		BuildTmpMask		redraw mask

		bsr		RenderMask

		moveq.l		#0,d2			not quitting
		rts


***************	Save mask for later use

BMEStore	lea		MaskBits(a4),a0		Src
		lea		StoredMask(a4),a1	Dest

		move.l		(a0)+,(a1)+		copy mask
		move.l		(a0)+,(a1)+
		move.l		(a0)+,(a1)+
		move.l		(a0)+,(a1)+
		move.l		(a0)+,(a1)+
		move.l		(a0)+,(a1)+
		move.l		(a0)+,(a1)+
		move.l		(a0)+,(a1)+

		lea		MaskBits(a4),a0		mask buffer
		bsr		BuildTmpMask		redraw mask

		bsr		RenderSMask		draw mask
		
		moveq.l		#0,d2			not quitting
		rts

***************	Display the current mask real-size 

RenderMask	lea		MaskBits(a4),a0		Src
		lea		im3,a1			Dest

		move.l		(a0)+,(a1)+		copy mask
		move.l		(a0)+,(a1)+
		move.l		(a0)+,(a1)+
		move.l		(a0)+,(a1)+
		move.l		(a0)+,(a1)+
		move.l		(a0)+,(a1)+
		move.l		(a0)+,(a1)+
		move.l		(a0)+,(a1)+

		move.l		BMEwin.rp(a4),a0	RastPort
		lea		DMaskImage,a1		Image
		move.l		#240,d0			X
		move.l		#200,d1			Y
		CALLINT		DrawImage		display mask
		
		rts
		

***************	Display the saved mask real-size

RenderSMask	lea		StoredMask(a4),a0	Src
		lea		im3,a1			Dest

		move.l		(a0)+,(a1)+		copy mask
		move.l		(a0)+,(a1)+
		move.l		(a0)+,(a1)+
		move.l		(a0)+,(a1)+
		move.l		(a0)+,(a1)+
		move.l		(a0)+,(a1)+
		move.l		(a0)+,(a1)+
		move.l		(a0)+,(a1)+

		move.l		BMEwin.rp(a4),a0	RastPort
		lea		DMaskImage,a1		Image
		move.l		#200,d0			X
		moveq.l		#30,d1			Y
		CALLINT		DrawImage		display mask
		
		rts
		

***************	Display the Block real-size 

RenderBlock	lea		BMEImage,a1		Image
		move.l		_Depth(a4),d0		block depth
		move.w		d0,ig_Depth(a1)		set depth
		move.l		ThisBlock(a4),a0	block gfx
		move.l		a0,ig_ImageData(a1)	set gfx address
		
		move.l		BMEwin.rp(a4),a0	RastPort
		moveq.l		#80,d0			X
		move.l		#200,d1			Y
		CALLINT		DrawImage		display mask
		
		move.l		BMEAddr(a4),a0		a0->Mask
		lea		im3,a1			Dest

		move.l		(a0)+,(a1)+		copy mask
		move.l		(a0)+,(a1)+
		move.l		(a0)+,(a1)+
		move.l		(a0)+,(a1)+
		move.l		(a0)+,(a1)+
		move.l		(a0)+,(a1)+
		move.l		(a0)+,(a1)+
		move.l		(a0)+,(a1)+

		move.l		BMEwin.rp(a4),a0	RastPort
		lea		DMaskImage,a1		Image
		move.l		#160,d0			X
		move.l		#200,d1			Y
		CALLINT		DrawImage		display mask
		
		rts

;***********************************************************
;	Window and Gadget defenitions
;***********************************************************

BMEWindow
	dc.w	0,0
	dc.w	320,256
	dc.b	0,1
	dc.l	MOUSEBUTTONS+GADGETUP+INTUITICKS
	dc.l	ACTIVATE+RMBTRAP+NOCAREREFRESH
	dc.l	BMEGadg1
	dc.l	0
	dc.l	.Name
	dc.l	0
	dc.l	0
	dc.w	5,5
	dc.w	640,200
	dc.w	CUSTOMSCREEN
.Name
	dc.b	'ScreenDesigner - Block Mask Editor',0
	even

BMEGadg1
	dc.l	BMEGadg2
	dc.w	10,108
	dc.w	57,15
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	.Border
	dc.l	0
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	FillMask
.Border
	dc.w	-2,-1
	dc.b	3,0,RP_JAM1
	dc.b	5
	dc.l	.Vectors
	dc.l	0
.Vectors
	dc.w	0,0
	dc.w	60,0
	dc.w	60,16
	dc.w	0,16
	dc.w	0,0
.IText
	dc.b	3,0,RP_JAM2,0
	dc.w	10,4
	dc.l	0
	dc.l	.Text
	dc.l	0
.Text
	dc.b	'Fill',0
	even
BMEGadg2
	dc.l	BMEGadg3
	dc.w	75,108
	dc.w	57,15
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	.Border
	dc.l	0
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	ClrMask
.Border
	dc.w	-2,-1
	dc.b	3,0,RP_JAM1
	dc.b	5
	dc.l	.Vectors
	dc.l	0
.Vectors
	dc.w	0,0
	dc.w	60,0
	dc.w	60,16
	dc.w	0,16
	dc.w	0,0
.IText
	dc.b	3,0,RP_JAM2,0
	dc.w	8,5
	dc.l	0
	dc.l	.Text
	dc.l	0
.Text
	dc.b	'Clear',0
	even
BMEGadg3
	dc.l	BMEGadg4
	dc.w	250,238
	dc.w	57,15
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	.Border
	dc.l	0
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	BMEUse
.Border
	dc.w	-2,-1
	dc.b	3,0,RP_JAM1
	dc.b	5
	dc.l	.Vectors
	dc.l	0
.Vectors
	dc.w	0,0
	dc.w	60,0
	dc.w	60,16
	dc.w	0,16
	dc.w	0,0
.IText
	dc.b	3,0,RP_JAM2,0
	dc.w	14,4
	dc.l	0
	dc.l	.Text
	dc.l	0
.Text
	dc.b	'USE',0
	even
BMEGadg4
	dc.l	BMEGadg5
	dc.w	10,238
	dc.w	57,15
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	.Border
	dc.l	0
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	BMECancel
.Border
	dc.w	-2,-1
	dc.b	3,0,RP_JAM1
	dc.b	5
	dc.l	.Vectors
	dc.l	0
.Vectors
	dc.w	0,0
	dc.w	60,0
	dc.w	60,16
	dc.w	0,16
	dc.w	0,0
.IText
	dc.b	3,0,RP_JAM2,0
	dc.w	5,4
	dc.l	0
	dc.l	.Text
	dc.l	0
.Text
	dc.b	'CANCEL',0
	even
BMEGadg5
	dc.l	BMEGadg6
	dc.w	245,20
	dc.w	57,15
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	.Border
	dc.l	0
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	BMEStore
.Border
	dc.w	-2,-1
	dc.b	3,0,RP_JAM1
	dc.b	5
	dc.l	.Vectors
	dc.l	0
.Vectors
	dc.w	0,0
	dc.w	60,0
	dc.w	60,16
	dc.w	0,16
	dc.w	0,0
.IText
	dc.b	3,0,RP_JAM2,0
	dc.w	-1,4
	dc.l	0
	dc.l	.Text
	dc.l	0
.Text
	dc.b	'->Store',0
	even
BMEGadg6
	dc.l	0
	dc.w	245,40
	dc.w	57,15
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	.Border
	dc.l	0
	dc.l	.IText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	BMERestore
.Border
	dc.w	-2,-1
	dc.b	3,0,RP_JAM1
	dc.b	5
	dc.l	.Vectors
	dc.l	0
.Vectors
	dc.w	0,0
	dc.w	60,0
	dc.w	60,16
	dc.w	0,16
	dc.w	0,0
.IText
	dc.b	3,0,RP_JAM2,0
	dc.w	-1,4
	dc.l	0
	dc.l	.Text
	dc.l	0
.Text
	dc.b	'<-Store',0
	even


MaskImage	dc.w	0,0		Used to render mask bits into window
		dc.w	4,4
		dc.w	1
		dc.l	0
		dc.b	$01,$00
		dc.l	0

DMaskImage	dc.w	0,0		Used to render full mask into window
		dc.w	16,16
		dc.w	1
		dc.l	im3
		dc.b	$01,$00
		dc.l	0

BMEImage	dc.w	0,0		Used to render block into window
		dc.w	16,16
		dc.w	0
		dc.l	0
		dc.b	$1f,$00
		dc.l	0

BMEBorder
	dc.w	18,18
	dc.b	3,0,RP_JAM1
	dc.b	5
	dc.l	.Vectors
	dc.l	.Border
.Vectors
	dc.w	0,0
	dc.w	68,0
	dc.w	68,68
	dc.w	0,68
	dc.w	0,0

.Border
	dc.w	4,16
	dc.b	3,0,RP_JAM1
	dc.b	5
	dc.l	.Vectors1
	dc.l	.Border1
.Vectors1
	dc.w	0,0
	dc.w	137,0
	dc.w	137,120
	dc.w	0,120
	dc.w	0,0

.Border1
	dc.w	198,28
	dc.b	3,0,RP_JAM1
	dc.b	5
	dc.l	.Vectors2
	dc.l	.Border2
.Vectors2
	dc.w	0,0
	dc.w	20,0
	dc.w	20,20
	dc.w	0,20
	dc.w	0,0

.Border2
	dc.w	194,17
	dc.b	3,0,RP_JAM1
	dc.b	5
	dc.l	.Vectors3
	dc.l	.Border3
.Vectors3
	dc.w	0,0
	dc.w	118,0
	dc.w	118,50
	dc.w	0,50
	dc.w	0,0

.Border3
	dc.w	78,198
	dc.b	3,0,RP_JAM1
	dc.b	5
	dc.l	.Vectors4
	dc.l	.Border4
.Vectors4
	dc.w	0,0
	dc.w	20,0
	dc.w	20,20
	dc.w	0,20
	dc.w	0,0


.Border4
	dc.w	158,198
	dc.b	3,0,RP_JAM1
	dc.b	5
	dc.l	.Vectors5
	dc.l	.Border5
.Vectors5
	dc.w	0,0
	dc.w	20,0
	dc.w	20,20
	dc.w	0,20
	dc.w	0,0


.Border5
	dc.w	238,198
	dc.b	3,0,RP_JAM1
	dc.b	5
	dc.l	.Vectors6
	dc.l	.Border6
.Vectors6
	dc.w	0,0
	dc.w	20,0
	dc.w	20,20
	dc.w	0,20
	dc.w	0,0


.Border6
	dc.w	5,196
	dc.b	3,0,RP_JAM1
	dc.b	5
	dc.l	.Vectors7
	dc.l	0
.Vectors7
	dc.w	0,0
	dc.w	310,0
	dc.w	310,34
	dc.w	0,34
	dc.w	0,0


BMEText
	dc.b	3,0,RP_JAM2,0
	dc.w	26,127
	dc.l	0
	dc.l	.Text
	dc.l	.IText
.Text
	dc.b	'Edit It Here',0
	even

.IText
	dc.b	3,0,RP_JAM2,0
	dc.w	229,58
	dc.l	0
	dc.l	.Text1
	dc.l	.IText1
.Text1
	dc.b	'Memory',0
	even

.IText1
	dc.b	3,0,RP_JAM2,0
	dc.w	66,222
	dc.l	0
	dc.l	.Text2
	dc.l	.IText2
.Text2
	dc.b	'Block',0
	even

.IText2
	dc.b	3,0,RP_JAM2,0
	dc.w	154,222
	dc.l	0
	dc.l	.Text3
	dc.l	.IText3
.Text3
	dc.b	'Mask',0
	even

.IText3
	dc.b	3,0,RP_JAM2,0
	dc.w	222,222
	dc.l	0
	dc.l	.Text4
	dc.l	0
.Text4
	dc.b	'Current',0
	even
