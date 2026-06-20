
; MULTILOADER V2.0 by Raistlin

; This version of the multiload makes use of the powerpacker library
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

***************************************************************************
;			Start Of Source Code 
***************************************************************************
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
	beq	quit1			; leave if no library

	jsr	-132(a6)		; Forbid

	jsr	blankScreen		; Blank the screen

***************************************************************************		
;		Set-up DMA the way I like it!
***************************************************************************
	move.w	#$20,dmacon(a5)		; Disable sprites
	move.l	#Copperlist,cop1lch(a5)	; Insert my copper list
	move.w	#0,copjmp1(a5)		; Run my copper list


***************************************************************************
;   Set-up parameters to pass to multi-load routine for 1st piccy
***************************************************************************
	move.l	DECR_COL0,d0		; Decruunch options in d0
	move.l	#2,d1			; D1=Memory type
	move.l	#pic2name,filename	; filename=Address containing name
					; of file to load
	move.l	#pic2,buffer		; Buffer=Address to load file
	move.l	#pic2length,length	; Length=Length of file loaded
 				
	jsr	Multi_Load		; Load the gfx

	move.l	pic2,d0			; Address of gfx in d0
	jsr	Load_Bitplane_Pointers	; Load the bitplane pointers

Mouse_wait1
	btst	#6,$bfe001		; Wait for LMB
	bne	Mouse_wait1

; Give-up memory help for gfx
	move.l	pic2length,d0		; D0=Length of buffer
	move.l	pic2,a1			; A1=Address of buffer
	jsr	Freememory		; Free the memory


***************************************************************************
;   Set-up parameters to pass to multi-load routine for 2nd piccy
***************************************************************************
	move.l	DECR_COL0,d0		; Decruunch options in d0
	move.l	#2,d1			; D1=Memory type
	move.l	#pic3name,filename	; filename=Address containing name
					; of file to load
	move.l	#pic3,buffer		; Buffer=Address to load file
	move.l	#pic3length,length	; Length=Length of file loaded
 				
	jsr	Multi_Load		; Load the gfx

	move.l	pic3,d0			; Address of gfx in d0
	jsr	Load_Bitplane_Pointers	; Load the bitplane pointers

Mouse_wait2
	btst	#6,$bfe001		; Wait for LMB
	bne	Mouse_wait2

; Give-up memory help for gfx
	move.l	pic3length,d0		; D0=Length of buffer
	move.l	pic3,a1			; A1=Address of buffer
	jsr	Freememory		; Free the memory


***************************************************************************
;		Branch to subroutines here
***************************************************************************
Mouse_wait3
	btst	#6,$bfe001		; Wait for LMB
	bne	Mouse_wait3

	


***************************************************************************
;		This is the clean-up section
***************************************************************************
Clean_up
	move.w	#$8e30,dmacon(a5)	; En-able sprites
	move.l	gfxbase,a1
	move.l	38(a1),cop1lch(a5)	; Insert sys copper list
	move.w	#$0,copjmp1(a5)		; Run sys copper list
quit2	move.l	4,a6			; A6=Exec base
	move.l	_PPBase,a1		; a1=Base address of PPlibrary
	jsr	-408(a6)		; Close PP library
quit1	move.l	4,a6			; Exec base in a6
	move.l	gfxbase,a1		; A1=Address of gfx base
	jsr	-408(a6)		; Close gfx lib
	jsr	-138(a6)		; Permit
quit	rts				; Quit


Freememory
	move.l	4,a6
	jsr	-210(a6)		; release memory


***************************************************************************
;		Blank the screen during a multi-load
***************************************************************************
BlankScreen
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
	rts


****************************************************************************
;		This part is the actual multi-load
****************************************************************************
Multi_Load
	move.l		filename,a0		a0->name of loadfile
	move.l		buffer,a1		a1->space for buf addr
	move.l		length,a2		a2->space for len
	move.l		#0,a3			a3=> no password
	CALLNICO	ppLoadData		load the file
	tst.l		d0			test for error
	bne		quit2			leave if found
	rts


***************************************************************************
;    The bitplane pointers MUST be reset after loading the gfx!!
***************************************************************************
Load_Bitplane_Pointers
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
	swap	d0
	add.l	#256*40,d0

;Load colours into table
	lea	colours,a3		; Address of colours in CList
	move.l	d0,a4			; Address of colours in file
	move.w	#$180,d0		; d0=Colorregister 0
	moveq.l	#31,d5			; D5=Number of colours to load

Colloop
	move.w	d0,(a3)+		; Insert color register into a3
	move.w	(a4)+,(a3)+		; Color into a3
	addq.l	#2,d0			; Next colour register in d0
	dbra	d5,colloop		; Keep loading colours until end
	rts



***************************************************************************
		;This is the copperlist
***************************************************************************
	Section	CopperList,data_c	; Chip ram
Copperlist
	dc.w	diwstrt,$2c81	
	dc.w	diwstop,$2cc1
	dc.w	ddfstrt,$38
	dc.w	ddfstop,$d0
planes	dc.w	bplcon0,%0101001000000000
	dc.w	bplcon1,$0
	
colours	
	dc.w	color00,$000,color01,$000,color02,$000,color03,$000
	dc.w	color04,$000,color05,$000,color06,$000,color07,$000
	dc.w	color08,$000,color09,$000,color10,$000,color11,$000
	dc.w	color12,$000,color13,$000,color14,$000,color15,$000
	dc.w	color16,$000,color17,$000,color18,$000,color19,$000
	dc.w	color20,$000,color21,$000,color22,$000,color23,$000
	dc.w	color24,$000,color25,$000,color26,$000,color27,$000
	dc.w	color28,$000,color29,$000,color30,$000,color31,$000	

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



***************************************************************************
			; Variables
***************************************************************************
; Variables for librarys
PPName	PPNAME
	even
_PPBase	dc.l	0


gfxbase	dc.l	0

gfxname	dc.b	'graphics.library',0

; Variables for multi-load
length	dc.l	0			; space to store buffer length
filename dc.l	0			
buffer	dc.l	0			; Address of where to load file

; Data for blank screen	
pic1	dcb.b	256*40,0

; Data for picture 2 file
pic2name dc.b	'source:bitmaps/Necromancer.gfx',0
pic2length dc.l	0
pic2	dc.l	0

; Data for picture 3 file
pic3name dc.b	'source:bitmaps/Fellowship.gfx',0
pic3length dc.l	0
pic3	dc.l	0
