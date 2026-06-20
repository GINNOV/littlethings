
; MULTILOADER V2.0 by Raistlin

; This version of the multiload makesuse of the powerpacker library
; so you can crunch your gfx on the disc!  Or crunch the piccys in RAM
; and then uncrunch the ones you need!
; I've used Mark Meany power packer source 


; Tab settings = 8
	
	opt	c-
	
	include	source:include/hardware.i		; Hardware equates 
	incdir	sys:include/
	include	exec/types.i
	include	source:include/ppbase.i
	include	source:include/powerpacker_lib.i
	
; A macro that simplifies calling Nico's library.
		
CALLNICO	macro
	move.l		_PPBase,a6
	jsr		_LVO\1(a6)
	endm

	lea	$dff000,a5		; Offset in a5

	move.l	4,a6			; Exec base in a6

;Load GraphicsLibrary
	lea	gfxname,a1		; name of lib to load in a1
	move.l	#0,d0			; Any version
	jsr	-552(a6)		; Open gfx lib
	move.l	d0,gfxbase	
	beq	quit1
;Load PowerPacker Libary
	lea	PPName,a1		; a1->library name
	moveq.l	#0,d0			; any version
	jsr	-552(a6)		; open the library
	move.l	d0,_PPBase		; save base pointer
	beq	quit2			; leave if no library

	jsr	-132(a6)		; Forbid

	move.l	#pic1,d0		; Address of piccy into d0
	move.w	d0,bpl1+2
	swap	d0
	move.w	d0,bph1+2
	swap	d0
	move.w	d0,bpl2+2
	swap	d0
	move.w	d0,bph2+2
	swap	d0
	move.w	d0,bpl3+2
	swap	d0
	move.w	d0,bph3+2
	swap	d0
	move.w	d0,bpl4+2
	swap	d0
	move.w	d0,bph4+2
	swap	d0
	move.w	d0,bpl5+2
	swap	d0
	move.w	d0,bph5+2
		
	move.w	#$20,dmacon(a5)		; Disable sprites
	move.l	#Copperlist,cop1lch(a5)	; Insert my copper list
	move.w	#0,copjmp1(a5)		; Run my copper list

****************************************************************************
;		This part is the actual multi-load
****************************************************************************
	lea		filename,a0		a0->name of loadfile
	moveq.l		#0,d0			d0=decrunch options
	moveq.l		#2,d1			d1=Chip memory
	lea		pic2,a1		        a1->space for buf addr
	lea		length,a2		a2->space for len
	move.l		d1,a3			a3=> no password
	CALLNICO	ppLoadData		load the file
	tst.l		d0			test for error
	bne		quit2			leave if found

***************************************************************************
;    The bitplane pointers MUST be reset after loading the gfx!!
***************************************************************************
	move.l	pic2,d0			; Address of piccy into d0
	move.w	d0,bpl1+2
	swap	d0
	move.w	d0,bph1+2
	swap	d0
	add.l	#256*40,d0
	move.w	d0,bpl2+2
	swap	d0
	move.w	d0,bph2+2
	swap	d0
	add.l	#256*40,d0
	move.w	d0,bpl3+2
	swap	d0
	move.w	d0,bph3+2
	swap	d0
	add.l	#256*40,d0
	move.w	d0,bpl4+2
	swap	d0
	move.w	d0,bph4+2
	swap	d0
	add.l	#256*40,d0
	move.w	d0,bpl5+2
	swap	d0
	move.w	d0,bph5+2

Mouse_wait
	btst	#6,$bfe001		; Wait for LMB
	bne	Mouse_wait

Clean_up
	move.w	#$8e30,dmacon(a5)	; En-able sprites
	move.l	gfxbase,a1
	move.l	38(a1),cop1lch(a5)	; Insert sys copper list
	move.w	#$0,copjmp1(a5)		; Run sys copper list
quit2	move.l	4,a6
	move.l	pic2,a1			; a1->buffer
	move.l	length,d0		; d0=length of buffer
	jsr	-210(a6)		; release memory
quit1	move.l	4,a6			; Exec base in a6
	move.l	gfxbase,a1		; A1=Address of gfx base
	jsr	-408(a6)		; Close gfx lib
	jsr	-138(a6)		; Permit
quit	rts				; Quit


;This is the copperlist
	Section	CopperList,data_c	; Chip ram
Copperlist
	dc.w	diwstrt,$2c81	
	dc.w	diwstop,$2cc1
	dc.w	ddfstrt,$38
	dc.w	ddfstop,$d0
	dc.w	bplcon0,%0101001000000000
	dc.w	bplcon1,$0
	
;colours
	dc.w	color00,$000,color01,$200,color02,$400,color03,$040
	dc.w	color04,$221,color05,$421,color06,$233,color07,$711
	dc.w	color08,$642,color09,$940,color10,$644,color11,$03b
	dc.w	color12,$654,color13,$15b,color14,$a34,color15,$42b
	dc.w	color16,$864,color17,$26c,color18,$a64,color19,$876
	dc.w	color20,$988,color21,$49d,color22,$d95,color23,$bc4
	dc.w	color24,$ba7,color25,$ba9,color26,$ed7,color27,$cbb
	dc.w	color28,$adc,color29,$dca,color30,$dec,color31,$ffe

	; Ive just realised this is the wrong colour palette for this
	; file, sorry!
						

bph1	dc.w	bpl1pth,$0
bpl1	dc.w	bpl1ptl,$0
bph2	dc.w	bpl2pth,$0
bpl2	dc.w	bpl2ptl,$0
bph3	dc.w	bpl3pth,$0
bpl3	dc.w	bpl3ptl,$0
bph4	dc.w	bpl4pth,$0
bpl4	dc.w	bpl4ptl,$0
bph5	dc.w	bpl5pth,$0
bpl5	dc.w	bpl5ptl,$0
	
	dc.w	$ffff,$fffe


; Variables
PPName		PPNAME
		even
_PPBase		dc.l		0

length		dc.l		0	space to store buffer length


gfxname	dc.b	'graphics.library',0

filename
	dc.b	'source:bitmaps/fellowship.gfx',0
	even
gfxbase	dc.l	0
	
pic1	dcb.b	256*40,0
pic2	dc.l	0
