
; Displays a 320*256*4 picture using custom copper list.

; Written to test PutPlane subroutine.

; M.Meany, 16-3-91.


		opt		c-

		include		sys:include/exec/exec_lib.i
		include		source:include/hardware.i

		lea		$dff000,a5	Offset for hardware registers

;--------------	Set up Copper List, 1st bit plane pointers then colour reg.

		move.l		#Picture,d0	d0->pic

		lea		CopPlanes,a0
		move.w		d0,4(a0)
		swap		d0
		move.w		d0,(a0)

;--------------	Get addr of current Copper List and save it

		lea		Gfxname,a1	library name
		moveq		#0,d0		any version
		CALLEXEC	OpenLibrary	and open it
		tst.l		d0		all ok ?
		beq.s		quit_fast	if not quit
		move.l		d0,a1		base ptr int a1
		move.l		38(a1),Old	Save old copper address
		CALLEXEC	CloseLibrary	Close graphics library

;--------------	Activate our Copper List

		CALLEXEC	Forbid
		move.w		#$0020,dmacon(a5) Disable sprites
		move.l		#Newcop,cop1lch(a5)  Insert new copper data

;--------------	Print a line of text ( test PrintLine subroutine )

 
Wait_VBL	cmpi.b		#$f0,$dff006	VBL
		bne.s		Wait_VBL

		moveq.l		#0,d7

LLOOPP		lea		TestLine,a0
		lea		Picture,a1
		move.l		d7,d0
		bsr		PrintLine

		addq.l		#1,d7
		cmpi.b		#22,d7
		bne.s		LLOOPP

;		move.w		#$0f00,color00(a5)

;--------------	Wait for LMB to be pressed
 
Wait		btst		#6,CIAAPRA	LMB pressed ?
		bne.s		Wait_VBL	loop back if not

;--------------	Restore original Copper List

		move.l		Old,cop1lch(a5)	Restore copper
		move.w		#$83e0,dmacon(a5) Restore DMA channel

;--------------	And finish

		CALLEXEC	Permit		Restore multi-tasking
quit_fast	rts				Exit

;--------------	
;--------------	Subroutines
;--------------	

;--------------	Print a line of text to the screen
*************************************************************************
*									*
*Entry		a0->line of text ( $0a terminated ASCII chars )		*
*		a1->Start of bitplane					*
*		d0=line number (0 to 20)				*
*									*
* Assumes ALL lines of text have been clipped or expanded to 8O chars.  *
* See the text file loader to see how this is done. I have sacrificed   *
* Memory in order to simplify the programming required. This method also*
* Does away with the need to have a screen clear routine.		*
*									*
* M.Meany, July 91							*
*									*
*************************************************************************

; Leaves 50 lines at top of bitplane for a logo if required.

PrintLine	cmpi.b		#20,d0		is text on screen ?
		bgt		.done		if not quit

		asl.l		#3,d0		line num x 8
		add.l		#50,d0		add space for logo
		mulu.w		#80,d0		address of 1st byte in line
		lea		0(a1,d0),a1	a1->bpl start position
		moveq.l		#79,d1		character counter for loop

		moveq.l		#0,d3
		moveq.l		#' ',d4
		moveq.l		#3,d5

.loop		move.l		d3,d2		clear register
		move.b		(a0)+,d2	get next char
		sub.l		d4,d2		adjust ASCII to actual
		asl.l		d5,d2		x8 to get offset to data

		lea		CHARS,a2	a2->character set data
		lea		0(a2,d2),a2	a2->data for this char

		move.b		(a2)+,(a1)	1st line of char
		move.b		(a2)+,80(a1)	2nd line of char
		move.b		(a2)+,160(a1)	3rd line of char
		move.b		(a2)+,240(a1)	4th line of char
		move.b		(a2)+,320(a1)	5th line of char
		move.b		(a2)+,400(a1)	6th line of char
		move.b		(a2)+,480(a1)	7th line of char
		move.b		(a2)+,560(a1)	last line of char
		lea		1(a1),a1	bump to next screen pos

		dbra		d1,.loop	for whole line

.done		rts				all done so return
		


;--------------	
;--------------	Data Section		
;--------------	

Gfxname 	dc.b "graphics.library",0   Pointer for library
 		even

Old 		dc.l 0			Storage point


TestLine	dc.b "THIS TEXT IS BEING REPRINTED EVERY 50TH OF A SECOND "
		dcb.b 80,"!"

; Character set


CHARS:   DC.B $00,$00,$00,$00,$00,$00,$00,$00 ;SPACE	00
         DC.B $18,$18,$18,$18,$00,$18,$18,$00 ;!	01
         DC.B $6C,$6C,$00,$00,$00,$00,$00,$00 ;"	02
         DC.B $1C,$36,$7C,$78,$7C,$3E,$1C,$00 ;#	03	
         DC.B $1C,$36,$1F,$0F,$1F,$3E,$1C,$00 ;$	04
         DC.B $00,$00,$00,$00,$00,$00,$00,$00 ;%	05
         DC.B $00,$00,$00,$00,$00,$00,$00,$00 ;&	06
         DC.B $0C,$0C,$18,$00,$00,$00,$00,$00 ;'	07
         DC.B $18,$30,$30,$30,$30,$30,$18,$00 ;(	08
         DC.B $18,$0C,$0C,$0C,$0C,$0C,$18,$00 ;)	09
         DC.B $00,$00,$00,$00,$00,$00,$00,$00 ;*	0A
         DC.B $00,$18,$18,$7E,$7E,$18,$18,$00 ;+	0B
         DC.B $00,$00,$00,$00,$0C,$0C,$18,$00 ;,	0C
         DC.B $00,$00,$00,$7E,$7E,$00,$00,$00 ;-	0D
         DC.B $00,$00,$00,$00,$00,$18,$18,$00 ;.	0E
         DC.B $02,$06,$0C,$18,$30,$60,$C0,$00 ;/	0F
         DC.B $7C,$C6,$CE,$DE,$F6,$E6,$7C,$00 ;0	10
         DC.B $38,$78,$18,$18,$18,$18,$7E,$00 ;1	11
         DC.B $7C,$C6,$06,$7C,$C0,$C0,$FE,$00 ;2	12
         DC.B $FC,$06,$06,$7C,$06,$06,$FC,$00 ;3	13
         DC.B $1C,$3C,$6C,$CC,$FE,$0C,$0C,$00 ;4	14
         DC.B $FE,$C0,$C0,$FC,$06,$06,$FC,$00 ;5	15
         DC.B $7E,$C0,$C0,$FC,$C6,$C6,$7C,$00 ;6	16
         DC.B $FE,$06,$06,$0C,$0C,$18,$18,$00 ;7	17
         DC.B $7C,$C6,$C6,$7C,$C6,$C6,$7C,$00 ;8	18
         DC.B $7C,$C6,$C6,$7E,$06,$06,$06,$00 ;9	19
         DC.B $00,$18,$18,$00,$00,$18,$18,$00 ;:	1A
         DC.B $00,$18,$18,$00,$18,$18,$30,$00 ;;	1B
         DC.B $06,$1C,$70,$E0,$70,$1C,$06,$00 ;<	1C
         DC.B $00,$00,$00,$00,$00,$00,$00,$00 ;=	1D
         DC.B $60,$38,$0E,$07,$0E,$38,$60,$00 ;>	1E
         DC.B $7C,$C6,$C6,$0C,$18,$00,$18,$00 ;?	1F
         DC.B $00,$00,$00,$00,$00,$00,$00,$00 ;@	20
         DC.B $7C,$C6,$C6,$FE,$C6,$C6,$C6,$00 ;A	21
         DC.B $FC,$C6,$C6,$FC,$C6,$C6,$FC,$00 ;B
         DC.B $7E,$C0,$C0,$C0,$C0,$C0,$7E,$00 ;C
         DC.B $FC,$C6,$C6,$C6,$C6,$C6,$FC,$00 ;D
         DC.B $7E,$C0,$C0,$FE,$C0,$C0,$7E,$00 ;E
         DC.B $7E,$C0,$C0,$FE,$C0,$C0,$C0,$00 ;F
         DC.B $7E,$C0,$C0,$DE,$C6,$C6,$7C,$00 ;G
         DC.B $C6,$C6,$C6,$FE,$C6,$C6,$C6,$00 ;H
         DC.B $7E,$18,$18,$18,$18,$18,$7E,$00 ;I
         DC.B $FE,$06,$06,$C6,$C6,$C6,$7C,$00 ;J
         DC.B $C6,$CC,$D8,$F0,$D8,$CC,$C6,$00 ;K
         DC.B $C0,$C0,$C0,$C0,$C0,$C0,$FE,$00 ;L
         DC.B $C6,$EE,$FE,$D6,$C6,$C6,$C6,$00 ;M
         DC.B $E6,$F6,$DE,$CE,$C6,$C6,$C6,$00 ;N
         DC.B $7C,$C6,$C6,$C6,$C6,$C6,$7C,$00 ;O
         DC.B $FC,$C6,$C6,$FC,$C0,$C0,$C0,$00 ;P
         DC.B $7C,$C6,$C6,$C6,$C6,$DA,$C6,$00 ;Q
         DC.B $FC,$C6,$C6,$FE,$CC,$C6,$C6,$00 ;R
         DC.B $7E,$C0,$C0,$7C,$06,$06,$FC,$00 ;S
         DC.B $7E,$18,$18,$18,$18,$18,$18,$00 ;T
         DC.B $C6,$C6,$C6,$C6,$C6,$C6,$7C,$00 ;U
         DC.B $C6,$C6,$C6,$C6,$C6,$38,$38,$00 ;V
         DC.B $C6,$C6,$C6,$D6,$FE,$EE,$C6,$00 ;W
         DC.B $C6,$6C,$38,$10,$38,$6C,$C6,$00 ;X
         DC.B $C6,$C6,$C6,$7E,$06,$06,$FC,$00 ;Y
         DC.B $FE,$0E,$1C,$38,$70,$E0,$FE,$00 ;Z


		section mm,data_c

Newcop                   
		dc.w diwstrt,$2c81	Top left of screen
		dc.w diwstop,$2cc1	Bottom right of screen - NTSC ($2cc1 for PAL)
		dc.w ddfstrt,$3c	Data fetch start
		dc.w ddfstop,$d4	Data fetch stop
		dc.w bplcon0,$9200	Select lo-res 16 colour 
		dc.w bplcon1,0		No horizontal offset

		dc.w color00,$0000	black background
		dc.w color01,$0fff	white foreground
 
		dc.w bpl1pth		Plane pointers for 4 planes          
CopPlanes	dc.w 0,bpl1ptl          
		dc.w 0

		dc.w $ffff,$fffe	End of copper list
 

Picture 	ds.b (640/8)*256


