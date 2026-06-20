*************************************************************************
*
*	This is an example of using multiple viewports on the
*	same display and was created in response to Marks plea
*	for help with his problem with viewports.This program
*	creates three viewports then scrolls the top and bottom
*	viewports.As these two viewports have the same bitmap 
*	structure and are scrolled together the effect is similar
*	to a dual playfield display.Many other effects can be used
*	by changing the viewport and rasinfo structures.The scroll
*	was done by simply changing the ri_RyOffset variable in
*	the rasinfo structures and then remaking the display.This
*	method seems better than using the graphics lib ScrollVPort
*	as this call is slightly bugged (there is some visible hashing
*	of the display whilst scrolling).I also used the graphics lib
*	WaitTOF to slow things down a little.This file compiles with
*	Devpac V2 and was created by Steve Marshall.Use and abuse as
*	you please.
*
*************************************************************************


	INCDIR	'SYS:include/'
	INCLUDE	exec/types.i
	INCLUDE	exec/exec_lib.i
	INCLUDE	graphics/gfx.i
	INCLUDE	graphics/gfxbase.i
	INCLUDE	graphics/graphics_lib.i
	INCLUDE	graphics/view.i
	INCLUDE	graphics/rastport.i
	
CALLSYS		MACRO
	jsr	_LVO\1(a6)
	ENDM
	
_main
	moveq		#0,d0			;any lib version
	lea		GfxName(pc),a1		;graphics lib name
	CALLEXEC	OpenLibrary		;oprn graphics lib
	move.l		d0,_GfxBase		;store lib base
	beq		GfxError		;quit if not opened
	
	move.l		d0,a0			;gfxbase to a0
	move.l		gb_ActiView(a0),Oldview	;store old view
	
	bset		#1,$bfe001  		;**** LED off ****
	bsr		SetupVports
	bsr		StartMusic

ScrollUp	
	lea		MyRasinfo1,a0		;get rasinfo for vp 1
	cmpi.w		#63,ri_RyOffset(a0)	;are we at top of scroll
	bge.s		ScrollDown		;yes the scroll down
	
	addq.w		#1,ri_RyOffset(a0)	;set rasinfo to scroll up 1
	lea		MyRasinfo3,a0		;get vp 3's rasinfo
	addq.w		#1,ri_RyOffset(a0)	;and scroll up 1
	
	bsr		DoScroll		;do the scroll
	
	btst		#6,$bfe001		;check left mousebutton
	beq.s		Cleanup			;branch if pressed
	bra.s		ScrollUp		;loop back to scroll again
	
ScrollDown
	lea		MyRasinfo1,a0		;get vp 1's rasinfo
	tst.w		ri_RyOffset(a0)		;have we finished scroll down
	beq.s		ScrollUp		;yes then scroll up
	
	subq.w		#1,ri_RyOffset(a0)	;set to scroll down 1
	
	lea		MyRasinfo3,a0		;get vp 3's rasinfo
	subq.w		#1,ri_RyOffset(a0)	;set to scroll down 1
	
	bsr		DoScroll		;do the scroll

	btst		#6,$bfe001		;check left mousebutton
	bne.s		ScrollDown		;branch if not pressed

Cleanup	
	bsr		StopMusic		;stop the music
	bclr  		#1,$bfe001  		;**** LED on ****
	move.l		Oldview,a1		;get old view
	CALLGRAF	LoadView		;and resore it
	
	lea 		ViewPort1,a0		;get vp 1
	move.l		vp_ColorMap(a0),a0	;get color map
	CALLSYS		FreeColorMap		;and free it

	lea 		ViewPort2,a0		;get vp 2
	move.l		vp_ColorMap(a0),a0	;get color map
	CALLSYS		FreeColorMap		;and free it
	
	lea 		ViewPort3,a0		;get vp 2
	move.l		vp_ColorMap(a0),a0	;get color map
	CALLSYS		FreeColorMap		;and free it

	move.l		_GfxBase,a1		;get gfxbase
	CALLEXEC	CloseLibrary		;and close graphics lib
	
GfxError
	rts					;the end


;######################################################################

DoScroll
	lea		MyView,a3		;get view
	move.l		a3,a0
	
	lea		ViewPort1,a1		;and first viewport
	CALLGRAF	MakeVPort		;make viewports
	
	move.l		a3,a0
	lea		ViewPort2,a1		;and first viewport
	CALLSYS		MakeVPort		;make viewports
	
	move.l		a3,a0
	lea		ViewPort3,a1		;and first viewport
	CALLSYS		MakeVPort		;make viewports
	
	move.l		a3,a1
	CALLSYS		MrgCop			;merge copper lists
	
	CALLSYS		WaitTOF
	
	move.l		a3,a1
	CALLSYS		LoadView		;display viewports
	
	rts

;=====================================================================
SetupVports
	lea		ColourMap1+8*2,a0	;get address of 1st raster
	lea		MyBitmap1,a1		;get bitmap
	lea		bm_Planes(a1),a1	;get planes structure
	moveq		#2,d0			;number of planes -1
.bmloop
	move.l		a0,(a1)+		;and place in bitmap
	add.l		#12800,a0		;add bytes to next raster
	dbra		d0,.bmloop		;branch to do others
	
	
	lea		ColourMap2+8*2,a0 	;get address of 1st raster
	lea		MyBitmap2,a1		;get bitmap
	lea		bm_Planes(a1),a1	;get planes structure
	moveq		#2,d0			;number of planes -1

.bmloop2
	move.l		a0,(a1)+		;and place in bitmap
	add.l		#1716,a0		;add bytes to next raster
	dbra		d0,.bmloop2		;branch to do others

	lea		MyView,a1		;get our view
	CALLGRAF	InitView		;and initialise it
	
	lea		ViewPort1,a0		;get first viewport
	move.l		a0,MyView		;and link to view
	
	lea		ViewPort1,a0		;get first viewport
	CALLSYS		InitVPort		;initialise 2nd viewport

	lea		ViewPort2,a0		;get second viewport
	CALLSYS		InitVPort		;and initialise that
	
	lea		ViewPort3,a0		;get third viewport
	CALLSYS		InitVPort		;and initialise that
	
;------	we have to link the viewports now as InitVPort breaks the linked list

	lea		ViewPort3,a1		;get second viewport
	move.l		a1,ViewPort2		;and link to first viewport
	lea		ViewPort2,a0		;get third viewport
	move.l		a0,ViewPort1		;and link to second
	
	moveq		#16,d0			;number of colours
	CALLSYS		GetColorMap		;get colourmap
	lea		ViewPort1,a0		;get first viewport
	move.l		d0,vp_ColorMap(a0)	;store colormap
	lea		MyRasinfo1,a1		;get 1st rasinfo
	move.l		a1,vp_RasInfo(a0)	;and place in viewport
	move.w		#320,vp_DWidth(a0)	;set width
	move.w		#107,vp_DHeight(a0)	;and height
	move.w		#0,vp_DyOffset(a0)	;set vp2 Y offset
	move.w		#0,vp_Modes(a0)		;set mode to lo-res
	lea		MyBitmap1,a0		;get 1st bitmap
	move.l		a0,ri_BitMap(a1)	;and store in rasinfo
	;move.w		#100,ri_RyOffset(a1)	;set position in bitmap
	moveq		#3,d0			;set depth
	move.l		#320,d1			;width
	move.l		#768,d2			;height
	CALLSYS		InitBitMap		;initialize bitmap
	
	moveq		#8,d0			;number of colours
	CALLSYS		GetColorMap		;get colourmap
	lea		ViewPort2,a0		;get first viewport
	move.l		d0,vp_ColorMap(a0)	;store colormap
	lea		MyRasinfo2,a1		;get 1st rasinfo
	move.l		a1,vp_RasInfo(a0)	;and place in viewport
	move.w		#352,vp_DWidth(a0)	;set width
	move.w		#39,vp_DHeight(a0)	;and height
	move.w		#108,vp_DyOffset(a0)	;set vp2 Y offset
	move.w		#-16,vp_DxOffset(a0)	;set vp2 Y offset
	move.w		#0,vp_Modes(a0)		;set mode to lo-res
	lea		MyBitmap2,a0		;get 2nd bitmap
	move.l		a0,ri_BitMap(a1)	;and store in rasinfo
	moveq		#3,d0			;set depth
	move.l		#352,d1			;width
	moveq		#39,d2			;height
	CALLSYS		InitBitMap		;initialize bitmap
	
	moveq		#16,d0			;number of colours
	CALLSYS		GetColorMap		;get colourmap
	lea		ViewPort3,a0		;get first viewport
	move.l		d0,vp_ColorMap(a0)	;store colormap
	lea		MyRasinfo3,a1		;get 1st rasinfo
	move.l		a1,vp_RasInfo(a0)	;and place in viewport
	move.w		#320,vp_DWidth(a0)	;set width
	move.w		#108,vp_DHeight(a0)	;and height
	move.w		#148,vp_DyOffset(a0)	;set vp2 Y offset
	move.w		#0,vp_Modes(a0)		;set mode to lo-res
	lea		MyBitmap1,a0		;get 2nd bitmap
	move.l		a0,ri_BitMap(a1)	;and store in rasinfo
	move.w		#148,ri_RyOffset(a1)	;set position in bitmap

	lea		MyView,a0		;get view
	lea		ViewPort1,a1		;and first viewport
	CALLSYS		MakeVPort		;make viewports
	
	lea		MyView,a0		;get view
	lea		ViewPort2,a1		;and first viewport
	CALLSYS		MakeVPort		;make viewports
	
	lea		MyView,a0		;get view
	lea		ViewPort3,a1		;and first viewport
	CALLSYS		MakeVPort		;make viewports
	
	lea		MyView,a1		;get view
	CALLSYS		MrgCop			;merge copper lists
	
	lea		MyView,a1		;get view
	CALLSYS		LoadView		;display viewports
	
	lea		MyRastport1,a1		;get rastport
	CALLSYS		InitRastPort		;and initialize
	
	lea		MyRastport1,a0		;get rastport
	lea		MyBitmap2,a1		;get bitmap2
	move.l		a1,rp_BitMap(a0)	;and attach to rastport
	
	moveq		#16,d0			;number of colours
	lea		ColourMap1,a1		;get colourmap
	lea		ViewPort1,a0		;get viewport
	CALLSYS		LoadRGB4		;set colours
	
	moveq		#16,d0			;number of colours
	lea		ColourMap1,a1		;get colourmap
	lea		ViewPort3,a0		;get viewport
	CALLSYS		LoadRGB4		;set colours
	
	moveq		#8,d0			;number of colours
	lea		ColourMap2,a1		;get colourmap
	lea		ViewPort2,a0		;get viewport
	CALLSYS		LoadRGB4		;set colours
	
	moveq		#0,d0			;set pen colour
	lea		MyRastport1,a1		;get rastport
	CALLSYS		SetAPen			;set pen colour
	
	moveq		#3,d0			;set background colour
	lea		MyRastport1,a1		;get rastport
	CALLSYS		SetBPen			;set background colour
	
	rts


TextScroll
	move.l		#2,d0			;dx, 2 pixels to the left
	moveq		#0,d1			;dy
	moveq		#0,d2			;min x
	moveq		#16,d3			;min y
	move.l		#352,d4			;max x
	moveq		#25,d5			;max y
	lea		MyRastport1,a1		;rastport pointer
	CALLGRAF	ScrollRaster
	subq.w		#1,scrcount		;Counter for newtext
	beq		newtext			;is zero->new char
	rts					;else->bye ??

newtext:move.w		#5,scrcount		;newtext delay set
	lea		MyRastport1,a1
	move.l		#344,d0			;x
	move.l		#22,d1			;y
	CALLSYS		Move
	move.l		stringpointer,a0	;pointer to string
	cmpi.b		#32,(a0)
	bge.s		TextOK
	lea		SpaceText(pc),a0

TextOK
	move.l		#1,d0			;1 char
	CALLSYS		Text
	addq.l		#1,stringpointer	;Next char
	cmpi.l		#endstring,stringpointer
	bne		notend			;end of string reached
	move.l		#string,stringpointer	;Start al over
notend:	rts

;=======================================================================
;	this is the player source for Brian Postma's soundmonitor
;	the music file is small because the song uses synthetical
;	instruments and not samples.The song used here is the theme
;	from 'The Neverending Story' and was created by Alastair
;	Brimble.
;=======================================================================



StartMusic
 lea		samples,a0
 lea		bpsong,a1
 clr.b		numtables
 cmpi.w		#'V.',26(a1)
 bne.s		bpnotv2
 cmpi.b		#'2',28(a1)
 bne.s		bpnotv2
 move.b		29(a1),numtables
bpnotv2:
 move.l		#512,d0
 move.w		30(a1),d1	;d1 now contains length in steps
 moveq		#1,d2		;1 is highest pattern number
 mulu		#4,d1		;4 voices per step
 subq.w		#1,d1		;correction for DBRA
findhighest:
 cmp.w		(a1,d0.w),d2	;Is it higher
 bge.s 		nothigher	;No
 move.w		(a1,d0.w),d2	;Yes, so let D2 be highest
nothigher:
 addq.w		#4,d0		;Next Voice
 dbra		d1,findhighest	;And search
 move.w		30(a1),d1
 move.l		#512,d0		;header is 512 bytes
 mulu		#16,d1		;16 bytes per step
 mulu		#48,d2		;48 bytes per pattern
 add.l		d2,d0
 add.l		d1,d0		;offset for samples

 add.l		#bpsong,d0
 move.l		d0,tables
 moveq		#0,d1
 move.b		numtables,d1	;Number of tables
 lsl.l		#6,d1		;x 64
 add.l		d1,d0
 moveq		#14,d1		;15 instruments
 add.l		#32,a1
initloop:
 move.l		d0,(a0)+
 cmpi.b		#$ff,(a1)
 beq.s		bpissynth
 move.w		24(a1),d2
 mulu		#2,d2		;Length is in words
 add.l		d2,d0		;offset next sample
bpissynth:
 lea		32(a1),a1	;Length of Sample Part in header
 dbra		d1,initloop

	lea	inter(pc),a1
	moveq	#5,d0
	move.l	4.w,a6
	jsr	-168(a6)	; Interrupt on
	rts

*****************************************
;	Interrupt code

BS_Music:
	movem.l	d2-d7/a2-a6,-(sp)
	bsr.s	bpmusic
	bsr	TextScroll
	movem.l	(sp)+,d2-d7/a2-a6
	moveq	#$00,d0
	rts	

*****************************************


StopMusic
 moveq		#3,d7
 lea		bpbuffer(pc),a0
bpmoloop:
 tst.l		(a0)
 beq.s		bpnotcopy
 move.l		a0,a2
 move.l		(a2),a1
 clr.l		(a2)+
 moveq		#7,d6		;copy 8 longs
bpmoloop2:
 move.l		(a2),(a1)+
 clr.l		(a2)+
 dbra		d6,bpmoloop2
bpnotcopy:
 add.l		#36,a0
 dbra		d7,bpmoloop

 move.l	4.w,a6
 moveq	#32,d0
 lea	inter(pc),a1
 jsr	-174(a6)	; Interrupt Off
 move.w	#$f,$dff096
 moveq	#0,d0
 rts

bpmusic:
 bsr		bpsynth
 subq.b		#1,arpcount
 moveq		#3,d0
 lea		bpcurrent,a0
 move.l		#$dff0a0,a1
bploop1:
 move.b		12(a0),d4
 ext.w		d4
 add.w		d4,(a0)
 tst.b		$1e(a0)
 bne.s		bplfo
 move.w		(a0),6(a1)
bplfo:
 move.l		4(a0),(a1)
 move.w		8(a0),4(a1)
 tst.b		11(a0)
 bne.s		bpdoarp
 tst.b		13(a0)
 beq.s		not2
bpdoarp:
 tst.b		arpcount
 bne.s		not0
 move.b		11(a0),d3
 move.b		13(a0),d4
 and.w		#240,d4
 and.w		#240,d3
 lsr.w		#4,d3
 lsr.w		#4,d4
 add.w		d3,d4
 add.b		10(a0),d4
 bsr		bpplayarp
 bra.s		not2
not0:
 cmpi.b		#1,arpcount 
 bne.s		not1
 move.b		11(a0),d3
 move.b		13(a0),d4
 and.w		#15,d3
 and.w		#15,d4
 add.w		d3,d4
 add.b		10(a0),d4
 bsr		bpplayarp
 bra.s		not2
not1:
 move.b		10(a0),d4
 bsr		bpplayarp
not2:
 lea		$10(a1),a1
 lea		$20(a0),a0
 dbra		d0,bploop1
 tst.b		arpcount
 bne.s		arpnotzero
 move.b		#3,arpcount
arpnotzero:
 subq.b		#1,bpcount
 beq.s		bpskip1
 rts
bpskip1:
 move.b		bpdelay,bpcount
bpplay:
 bsr.s		bpnext
 move.w		dma,$dff096
 moveq		#$6f,d0
bpxx:
 dbf		d0,bpxx
 moveq		#3,d0
 move.l		#$dff0a0,a1
 moveq		#1,d1
 lea		bpcurrent,a2
 lea		bpbuffer,a5
bploop2:
 btst		#15,(a2)
 beq.s		bpskip7
 bsr		bpplayit
bpskip7:
 asl.w		#1,d1
 lea		$10(a1),a1
 lea		$20(a2),a2
 lea		$24(a5),a5
 dbra		d0,bploop2
 rts

bpnext:
 clr.w		dma
 lea		bpsong,a0
 lea		bpcurrent,a1
 move.l		#$dff0a0,a3
 moveq		#3,d0
 move.w		#1,d7
bploop3:
 moveq		#0,d1
 move.w		bpstep,d1
 lsl.w		#4,d1
 move.l		d0,d2
 lsl.l		#2,d2
 add.l		d2,d1
 add.l		#512,d1
 move.w		(a0,d1),d2
 move.b		2(a0,d1),st
 move.b		3(a0,d1),tr
 subq.w		#1,d2
 mulu		#48,d2
 moveq		#0,d3
 move.w		30(a0),d3
 lsl.w		#4,d3
 add.l		d2,d3
 move.l	  	#$00000200,d4
 move.b		bppatcount,d4
 add.l		d3,d4
 move.l		d4,a2
 add.l		a0,a2

 moveq		#0,d3 
 move.b		(a2),d3
 bne.s		bpskip4
 bra		bpoptionals
bpskip4:
 clr.w		12(a1)	  ;Clear autoslide/autoarpeggio
 move.b		1(a2),d4
 and.b		#15,d4
 cmpi.b		#10,d4    ;Option 10->transposes off
 bne.s		bp_do1
 move.b		2(a2),d4
 and.b		#240,d4	  ;Higher nibble=transpose
 bne.s		bp_not1
bp_do1:
 add.b		tr,d3
 ext.w		d3
bp_not1:
 move.b		d3,10(a1) ; Voor Arpeggio's
 lea		bpper,a4
 lsl.w		#1,d3
 move.w		-2(a4,d3.w),(a1)
 bset		#15,(a1)
 move.b		#$ff,2(a1)

 clr.w		d3
 move.b		1(a2),d3
 lsr.b		#4,d3
 and.b		#15,d3
 tst.b		d3
 bne.s		bpskip5
 move.b		3(a1),d3 
bpskip5: 
 move.b		1(a2),d4
 and.b		#15,d4
 cmpi.b		#10,d4		;option 10
 bne.s		bp_do2
 move.b		2(a2),d4
 and.b		#15,d4
 bne.s		bp_not2
bp_do2:
 add.b		st,d3
bp_not2:
 cmpi.w		#1,8(a1)
 beq.s		bpsamplechange
 cmp.b		3(a1),d3
 beq.s		bpoptionals
bpsamplechange:
 move.b		d3,3(a1)
 or.w		d7,dma
 
bpoptionals: 
 moveq		#0,d3
 moveq		#0,d4
 move.b		1(a2),d3
 and.b		#15,d3
 move.b		2(a2),d4
 
; Optionals Here
 tst.b		d3
 bne.s		notopt0
 move.b		d4,11(a1)
 bra		bpskip2
notopt0:
 cmpi.b		#1,d3
 bne.s		bpskip3
 move.w		d4,8(a3)
 move.b		d4,2(a1) ; Volume ook in BPCurrent
 bra		bpskip2
bpskip3:
 cmpi.b		#2,d3  ; Set Speed
 bne.s		bpskip9
 move.b		d4,bpcount
 move.b		d4,bpdelay
 bra.s		bpskip2
bpskip9:
 cmpi.b		#3,d3 ; Filter = LED control
 bne.s		bpskipa
 tst.b		d4
 bne.s		bpskipb
 bset		#1,$bfe001
 bra.s		bpskip2
bpskipb:
 bclr		#1,$bfe001
 bra.s		bpskip2
bpskipa:
 cmpi.b		#4,d3 ; PortUp
 bne.s		noportup
 sub.w		d4,(a1) ; Slide data in BPCurrent
 clr.b		11(a1) ; Arpeggio's uit
 bra.s		bpskip2
noportup:
 cmpi.b		#5,d3 ; PortDown
 bne.s		noportdn
 add.w		d4,(a1) ; Slide down
 clr.b		11(a1)
 bra.s		bpskip2
noportdn:
 cmpi.b		#6,d3	; SetRepCount
 bne.s		notopt6
 move.b		d4,bprepcount
 bra.s		bpskip2
notopt6:
 cmpi.b		#7,d3	; DBRA repcount
 bne.s		notopt7
 subq.b		#1,bprepcount
 beq.s		bpskip2
 move.w		d4,bpstep
 bra.s		bpskip2
notopt7:
 cmpi.b		#8,d3	;Set AutoSlide
 bne.s		notopt8
 move.b		d4,12(a1)
 bra.s		bpskip2
notopt8:
 cmpi.b		#9,d3	;Set AutoArpeggio
 bne.s		notopt9
 move.b		d4,13(a1)
notopt9:
bpskip2
 lea		$10(a3),a3
 lea		$20(a1),a1
 asl.w		#1,d7
 dbra		d0,bploop3 				
 addq.b		#3,bppatcount
 cmpi.b		#48,bppatcount
 bne.s		bpskip8
 clr.b		bppatcount
 addq.w		#1,bpstep
 lea		bpsong,a0
 move.w		30(a0),d1
 cmp.w		bpstep,d1
 bne.s		bpskip8
 clr.w		bpstep
bpskip8:
 rts

bpplayit:
 bclr		#15,(a2)
 tst.l		(a5)		;Was EG used
 beq.s		noeg1		;No ??
 clr.w		d3		;Well then copy
 move.l		(a5),a4		;Old waveform back
 moveq		#7,d7		;to waveform tables
eg1loop:
 move.l		4(a5,d3.w),(a4)+;Copy...
 addq.w		#4,d3		;Copy...
 dbra		d7,eg1loop	;Copy...
noeg1:
 move.w		(a2),6(a1)	;Period from bpcurrent
 moveq		#0,d7
 move.b		3(a2),d7	;Instrument number
 move.l		d7,d6		;Also in d6
 lsl.l		#5,d7		;Header offset	
 lea		bpsong,a3
 cmpi.b		#$ff,(a3,d7.w)	;Is synthetic
 beq.s		bpplaysynthetic	;Yes ??
 clr.l		(a5)		;EG Off
 clr.b		$1a(a2)		;Synthetic mode off
 clr.w		$1e(a2)		;Lfo Off
 add.l		#24,d7		;24 is name->ignore
 lsl.l		#2,d6		;x4 for sample offset
 lea		samples,a4
 move.l		-4(a4,d6),d4	;Fetch sample pointer
 beq.s		bp_nosamp	;is zero->no sample
 move.l		d4,(a1)		;Sample pointer in hardware
 move.w		(a3,d7),4(a1)	;length in hardware
 move.b		2(a2),9(a1)	;and volume from bpcurrent
 cmpi.b		#$ff,2(a2)	;Use default volume
 bne.s		skipxx		;No ??
 move.w		6(a3,d7),8(a1)	;Default volume in hardware
skipxx: 
 move.w		4(a3,d7),8(a2)	;Length in bpcurrent
 moveq		#0,d6
 move.w		2(a3,d7),d6	;Calculate repeat
 add.l		d6,d4
 move.l		d4,4(a2)	;sample start in bpcurrent
 cmpi.w		#1,8(a2)	;has sample repeat part
 bne.s		bpskip6		;Yes ??
bp_nosamp:
 move.l		#null,4(a2)	;Play no sample
 bra.s		bpskip10
bpskip6:
 move.w		8(a2),4(a1)	;Length to hardware
 move.l		4(a2),(a1)	;pointer to hardware
bpskip10:
 add.w		#$8000,d1	;Turn on DMA for this voice
 move.w		d1,$dff096	;Yeah, do it
 rts

bpplaysynthetic:
 move.b		#$1,$1a(a2)	;Synthetic mode on
 clr.w		$e(a2)		;EG Pointer restart
 clr.w		$10(a2)		;LFO Pointer restart
 clr.w		$12(a2)		;ADSR Pointer restart
 move.w		22(a3,d7.w),$14(a2);EG Delay
 addq.w		#1,$14(a2)	;0 is nodelay
 move.w		14(a3,d7.w),$16(a2);LFO Delay
 addq.w		#1,$16(a2)	;So I need correction
 move.w		#1,$18(a2)	;ADSR Delay->Start immediate
 move.b		17(a3,d7.w),$1d(a2);EG OOC
 move.b		9(a3,d7.w),$1e(a2);LFO OOC
 move.b		4(a3,d7.w),$1f(a2);ADSR OOC
 move.b		19(a3,d7.w),$1c(a2);Current EG Value
; so far so good,now what ??
 move.l		tables,a4	;Pointer to waveform tables
 clr.l		d3
 move.b		1(a3,d7.w),d3	;Which waveform
 lsl.l		#6,d3		;x64 is length waveform table
 add.l		d3,a4
 move.l		a4,(a1)		;Sample Pointer
 move.l		a4,4(a2)	;In bpcurrent
 move.w		2(a3,d7.w),4(a1);Length in words
 move.w		2(a3,d7.w),8(a2);Length in bpcurrent
 tst.b		4(a3,d7.w)	;Is ADSR on
 beq.s		bpadsroff	;No ??
 move.l		tables,a4	;Tables
 clr.l		d3
 move.b		5(a3,d7.w),d3	;ADSR table number
 lsl.l		#6,d3		;x64 for length
 add.l		d3,a4		;Add it
 clr.w		d3
 move.b		(a4),d3		;Get table value
 add.b		#128,d3		;I want it from 0..255
 lsr.w		#2,d3		;Divide by 4->0..63
 cmpi.b		#$ff,2(a2)
 bne.s		bpskip99
 move.b		25(a3,d7.w),2(a2)
bpskip99:
 clr.w		d4
 move.b		2(a2),d4	;Default volume
 mulu		d4,d3		;default maal init volume
 lsr.w		#6,d3		;divide by 64
 move.w		d3,8(a1)	;is new volume
 bra.s		bpflipper
bpadsroff:
 move.b		2(a2),9(a1)
 cmpi.b		#$ff,2(a2)
 bne.s		bpflipper	;No ADSR
 move.b		25(a3,d7.w),9(a1);So use default volume
bpflipper:
 move.l		4(a2),a4	;Pointer on waveform
 move.l		a4,(a5)		;Save it
 clr.w		d3		;Save Old waveform
 moveq		#7,d4		;data in bpbuffer
eg2loop:
 move.l		(a4,d3.w),4(a5,d3.w)
 addq.w		#4,d3		;Copy !!
 dbra		d4,eg2loop
 tst.b		17(a3,d7.w)	;EG off
 beq		bpskip10	;Yes ??
 tst.b		19(a3,d7.w)	;Is there an init value for EG
 beq		bpskip10	;No ??
 clr.l		d3
 move.b		19(a3,d7.w),d3
 lsr.l		#3,d3		;Divide by 8 ->0..31
 move.b		d3,$1c(a2)	;Current EG Value
 subq.l		#1,d3		;-1,DBRA correction
eg3loop:
 neg.b		(a4)+
 dbra		d3,eg3loop
 bra		bpskip10

bpplayarp:
 lea		bpper,a4
 ext.w		d4
 asl.w		#1,d4
 move.w		-2(a4,d4.w),6(a1)
 rts

bpsynth:
 moveq		#3,d0
 lea		($dff0a0).l,a1
 lea		bpcurrent,a2
 lea		bpsong,a3
 lea		bpbuffer,a5
bpsynthloop:
 tst.b		$1a(a2)		;Is synthetic sound
 beq.s		bpnosynth	;No ??
 bsr.s		bpyessynth	;Yes !!
bpnosynth:
 lea		$24(a5),a5
 lea		$20(a2),a2
 lea		$10(a1),a1
 dbra		d0,bpsynthloop
 rts
bpyessynth:
 clr.w		d7
 move.b		3(a2),d7	;Which instr. was I playing
 lsl.w		#5,d7		;x32, is length of instr.
 tst.b		$1f(a2)		;ADSR off
 beq.s		bpendadsr	;Yes ??
 subq.w		#1,$18(a2)	;Delay,May I
 bne.s		bpendadsr	;No ??
 moveq		#0,d3
 move.b		8(a3,d7.w),d3
 move.w		d3,$18(a2)	;Reset Delay Counter
 move.l		tables,a4
 move.b		5(a3,d7.w),d3	;Which ADSR table
 lsl.l		#6,d3		;x64
 add.l		d3,a4		;This is my table
 move.w		$12(a2),d3	;Get ADSR table pointer
 clr.w		d4
 move.b		(a4,d3.w),d4	;Value from table
 add.b		#128,d4		;Want it from 0..255
 lsr.w		#2,d4		;And now from 0..63
 clr.w		d3
 move.b		2(a2),d3	;Current Volume
 mulu		d3,d4		;MultiPly with table volume
 lsr.w		#6,d4		;Divide by 64=New volume
 move.w		d4,8(a1)	;Volume in hardware
 addq.w		#1,$12(a2)	;Increment of ADSR pointer
 move.w		6(a3,d7.w),d4	;Length of adsr table
 cmp.w		$12(a2),d4	;End of table reached
 bne.s		bpendadsr	;No ??
 clr.w		$12(a2)		;Clear ADSR Pointer
 cmpi.b		#1,$1f(a2)	;Once
 bne.s		bpendadsr	;No ??
 clr.b		$1f(a2)		;ADSR off
bpendadsr:
 tst.b		$1e(a2)		;LFO On
 beq.s		bpendlfo	;No ??
 subq.w		#1,$16(a2)	;LFO delay,May I
 bne.s		bpendlfo	;No
 moveq		#0,d3
 move.b		16(a3,d7.w),d3
 move.w		d3,$16(a2)	;Set LFO Count
 move.l		tables,a4
 move.b		10(a3,d7.w),d3	;Which LFO table
 lsl.l		#6,d3		;x64
 add.l		d3,a4
 move.w		$10(a2),d3	;LFO pointer
; clr.l		d4
 move.b		(a4,d3.w),d4	;That's my value
 ext.w		d4		;Make it a word
 ext.l		d4		;And a longword
 moveq		#0,d5
 move.b		11(a3,d7.w),d5	;LFO depth
 beq.s		bpnotx
 divs		d5,d4		;Calculate it
bpnotx:
 move.w		(a2),d5		;Period
 add.w		d4,d5		;New Period
 move.w		d5,6(a1)	;In hardware
 addq.w		#1,$10(a2)	;Next position
 move.w		12(a3,d7.w),d3	;LFO table Length
 cmp.w		$10(a2),d3	;End Reached
 bne.s		bpendlfo	;NO ??
 clr.w	 	$10(a2)		;Reset LFO Pointer
 cmpi.b		#1,$1e(a2)	;Once LFO
 bne.s		bpendlfo	;NO ??
 clr.b		$1e(a2)		;LFO Off
bpendlfo:
 tst.b		$1d(a2)		;EG On
 beq		bpendeg		;No ??
 subq.w		#1,$14(a2)	;EG delay,May I
 bne.s		bpendeg		;No
 tst.l		(a5)
 beq.s		bpendeg
 moveq		#0,d3
 move.b		24(a3,d7.w),d3
 move.w		d3,$14(a2)	;Set EG Count
 move.l		tables,a4
 move.b		18(a3,d7.w),d3	;Which EG table
 lsl.l		#6,d3		;x64
 add.l		d3,a4
 move.w		$e(a2),d3	;EG pointer
 moveq		#0,d4
 move.b		(a4,d3.w),d4	;That's my value
 move.l		(a5),a4		;Pointer to waveform
 add.b		#128,d4		;0..255
 lsr.l		#3,d4		;0..31
 moveq		#0,d3
 move.b		$1c(a2),d3	;Old EG Value
 move.b		d4,$1c(a2)
 add.l		d3,a4		;WaveForm Position
 move.l		a5,a6		;Buffer
 add.l		d3,a6		;Position
 addq.l		#4,a6		;For adress in buffer
 cmp.b		d3,d4		;Compare old with new value
 beq.s		bpnexteg	;no change ??
 bgt.s		bpishigh	;new value is higher
bpislow:
 sub.l		d4,d3		;oldvalue-newvalue
 subq.w		#1,d3		;Correction for DBRA
bpegloop1a:
 move.b		-(a6),-(a4)
 dbra		d3,bpegloop1a 		
 bra.s		bpnexteg
bpishigh:
 sub.l		d3,d4		;Newvalue-oldvalue
 subq.w		#1,d4		;Correction for DBRA
bpegloop1b:
 move.b		(a6)+,d3
 neg.b		d3
 move.b		d3,(a4)+	;DoIt
 dbra		d4,bpegloop1b
bpnexteg:
 addq.w		#1,$e(a2)	;Next position
 move.w		20(a3,d7.w),d3	;EG table Length
 cmp.w		$e(a2),d3	;End Reached
 bne.s		bpendeg		;NO ??
 clr.w	 	$e(a2)		;Reset EG Pointer
 cmpi.b		#1,$1d(a2)	;Once EG
 bne.s		bpendeg		;NO ??
 clr.b		$1d(a2)		;EG Off
bpendeg:
 rts
					    
null: dc.w 0
bpcurrent: dc.w 0,0	;periode,instrument =(volume.b,instr nr.b)
	   dc.l null	;start
           dc.w 1	;length (words)
	   dc.b 0,0,0,0 ;noot,arpeggio,autoslide,autoarpeggio
	   dc.w 0,0,0	;EG,LFO,ADSR pointers
	   dc.w 0,0,0	;EG,LFO,ADSR count
	   dc.b	0,0	;Synthetic yes/no, Volume Slide
	   dc.b	0,0	;Current EG value,EG OOC
	   dc.b	0,0	;LFO OOC,ADSR OOC

           dc.w 0,0
	   dc.l null
	   dc.w 1,0,0
	   dc.w	0,0,0,0,0,0,0,0,0

 	   dc.w 0,0
	   dc.l null
	   dc.w 1,0,0
	   dc.w 0,0,0,0,0,0,0,0,0

	   dc.w 0,0
	   dc.l null
	   dc.w 1,0,0
	   dc.w 0,0,0,0,0,0,0,0,0

bpstep:
	dc.w 0
bppatcount: 
	dc.b 0
st: 
	dc.b 0
tr: 
	dc.b 0
bpcount: 
	dc.b 1
bpdelay: 
	dc.b 6
arpcount: 	
	dc.b 1
bprepcount: 
	dc.b 1
numtables: 
	dc.b	0
 even
dma: 	
	dc.w 0
tables:	
	dc.l 0

bpbuffer:
 dcb.b	144,0

 dc.w	6848,6464,6080,5760,5440,5120,4832,4576,4320,4064,3840,3616
 dc.w	3424,3232,3040,2880,2720,2560,2416,2288,2160,2032,1920,1808
 dc.w	1712,1616,1520,1440,1360,1280,1208,1144,1080,1016,0960,0904
bpper:
 dc.w	0856,0808,0760,0720,0680,0640,0604,0572,0540,0508,0480,0452
 dc.w	0428,0404,0380,0360,0340,0320,0302,0286,0270,0254,0240,0226
 dc.w	0214,0202,0190,0180,0170,0160,0151,0143,0135,0127,0120,0113
 dc.w	0107,0101,0095,0090,0085,0080,0076,0072,0068,0064,0060,0057

inter:
	dc.l	0,0
	dc.b	0,9
	dc.l	0,0
	dc.l	BS_Music	
		
samples:
 dcb.l	15,0
 
scrcount:	dc.w	1
stringpointer:	dc.l	string
SpaceText:	dc.b	'  '		;two spaces - one for padding


GfxName
	dc.b		'graphics.library',0
	EVEN
	
string

	INCBIN		Source5:source/readme_SM
	
endstring


**************************************
**PLACE THE MODULE AT THE INCBIN   **
**************************************
	SECTION	BSMusicdata,DATA_C

bpsong:
		INCBIN	Source5:modules/neverending

	
;######################################################################
	SECTION	Structures,BSS
;######################################################################

Oldview
	ds.l		1
	
_GfxBase
	ds.l		1

MyView
	ds.b		v_SIZEOF	

ViewPort1
	ds.b		vp_SIZEOF
	
ViewPort2
	ds.b		vp_SIZEOF
	
ViewPort3
	ds.b		vp_SIZEOF
	
MyRasinfo1
	ds.b		ri_SIZEOF
	
MyRasinfo2
	ds.b		ri_SIZEOF
	
MyRasinfo3
	ds.b		ri_SIZEOF
	
MyRastport1
	ds.b		rp_SIZEOF
	
MyBitmap1
	ds.b		bm_SIZEOF
	
MyBitmap2
	ds.b		bm_SIZEOF

;######################################################################
	SECTION	Graphicsdata,DATA_C
;######################################################################

;------	these are just raw bitmaps with the colourmap before the bitmaps

ColourMap1
	INCBIN		Source5:bitmaps/longscreen.bm
	
ColourMap2
	INCBIN		Source5:bitmaps/scrollscreen.bm

