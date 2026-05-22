*****************************************************************************
*						     			    *
*		Example of how to use PHD decompress			    *
*		routine. Also demo of Sprite X-flipping		    	    *
*		Press Joystick fire to flip screen    			    *
*		Left to Right!!	LMB to exit.				    *
*						    			    *
*		Paul Douglas  20/1/93			   		    *
*						    			    *
*		Piccy used is from unknown artist, found on		    *
*		ACC28, all due respect for its useage  			    *
*		Wish I could draw like that !!	    			    *
*						    			    *
*		Note. This proggy assumes compressed piccy		    *
*		can be found at df0:ScalerPic.PHD    			    *
*						    			    *
*		Paul Douglas  20/1/93			   		    *
*****************************************************************************

	opt		c-

	section		Eighties,code_c		check out that bassline?! DEJA VU!

	incdir		Source:P_Douglas/
	include 	include/customdff002.i	my custom hardware include file

****************************************************************************
;			Decompression equates

PHD_FileID		equ	'PHD'*256+1
PHD_SafetyNet		equ	256
PHD_WorkspaceSize	equ	3670

****************************************************************************

ExecBase		equ	4		equates for using AmigaDos
Hardware		equ	$dff002		libraries, only used to
OpenLibrary		equ	-552		start up !
CloseLibrary		equ	-414		Didn't use Dos Includes to 
AllocMem		equ	-198		speed up Assembly times
FreeMem			equ	-210
Open			equ	-30		Dos library includes
Close			equ	-36		for file I/O
Seek			equ	-66
Read			equ	-42
Mode_OldFile		equ	1005
SystemCopper1		equ	$26
SystemCopper2		equ	$32
PortA			equ	$bfe001		Fire butts and filter
IcrA			equ	$bfed01		cia-a interrupt reg.
LeftMouse		equ	6
JoyFire			equ	7

***************************************************************************

NoPlanes		equ	4		Piccy is 16 colours
PicPixelsHigh		equ	200		and 320*200 pixels
PicWordsWide		equ	20		ain't it pretty!
RasterMem		equ	32064*2

ChipMemNeeded		equ	RasterMem*2
PublicMemNeeded		equ	PHD_WorkspaceSize

*****************************************************************************
*****************************************************************************
*			START OF SOURCE CODE
*****************************************************************************
*****************************************************************************
Start
	move.l	ExecBase,a6			get execbase in a6

	move.l	#ChipMemNeeded,d0		allocate chip mem for piccy
	moveq.l	#2,d1				double amount for double 
	jsr	AllocMem(a6)			buffering for X-flip thang
	tst.l	d0
	beq	ChipMemError			Oh Dear! no chipmem avail!!
	move.l	d0,Variables+ChipMemAddr	store memory start address

	move.l	#PublicMemNeeded,d0		allocate space for decompression
	moveq.l	#2,d1				should be public but this is chip!
	jsr	Allocmem(a6)			return to DOS if an error happens
	tst.l	d0				here
	beq	PublicMemError
	move.l	d0,Variables+PublicMemAddr	save the addr of free mem

	lea	Variables,a5			snaff up variable ptr


	bsr	LOAD_COMPRESSED_FILE		load and depack file

	bsr	BOSH_SYS			bosh sys so I can display it

	bsr	SETUP_SCREEN			display screen

	bsr	X_FLIP_SCREEN			flip it if need be

	bsr	FREE_SYS			restore sys and return


	move.l	ExecBase,a6			free the memory we
	move.l	(Variables+PublicMemAddr),a1	took earlier!!
	move.l	#PublicMemNeeded,d0
	jsr	FreeMem(a6)
PublicMemError
	move.l	(Variables+ChipMemAddr),a1
	move.l	#ChipMemNeeded,d0		free the chipmem we took
	jsr	FreeMem(a6)
ChipMemError
	rts					back to where we came from

**************************************************************************
**************************************************************************
*		load and depack screen dump
**************************************************************************
**************************************************************************
LOAD_COMPRESSED_FILE
	lea	DOSName(pc),a1			open the DOS library to allow
	clr.l	d0				the loading of my file!!
	jsr	OpenLibrary(a6)			before i kill the sys!!
	move.l	d0,DOSBase
	beq	.Error				exit if error


	move.l	d0,a6				put dosbase in a6 
	lea	LoadPathName(pc),a0		open the file
	move.l	a0,d1				get file path name in d1
	move.l	#MODE_OLDFILE,d2		file mode
	jsr	Open(a6)			open the file please
	move.l	d0,d4				put file handle in d4
	beq	.Load_error1			exit if error

	move.l	d4,d1				file handle in d1
	moveq	#0,d2				this little bit gets
	moveq	#1,d3				the length of the file
	jsr	Seek(a6)			by seeking to the End
	move.l	d4,d1				and then to the start
	moveq	#0,d2				length is in d0
	moveq	#-1,d3
	jsr	Seek(a6)			seek Start Of File

	move.l	d0,CompFileLen(a5)		got length so store it
	beq	.Load_error2			if error exit and close file

	move.l	d4,d1				regrab handle
	moveq.l	#8,d3				set up read for 8 bytes
	lea	FileID(a5),a0			and put in variable area
	move.l	a0,d2				this reads my compressed
	jsr	Read(a6)			file header

	move.l	d4,d1				reseek to start of
	moveq	#0,d2				my file
	moveq	#-1,d3
	jsr	Seek(a6)

	bsr	CHECK_ID			check file is my type

	bsr	CALCULATE_ADDRESS		calculate addr to load
;
;Please note I dont really have to check that the file is compressed
;or work out the address to put it as i know all file lengths etc
;This is to show how to load general files as you would in a text viewer etc
;

	move.l	d1,CompFileAddr(a5)		save load addr

	move.l	d4,d1
	move.l	CompFileLen(a5),d3		read whole file this time
	move.l	CompFileAddr(a5),d2		d2 contains addr to
	jsr	Read(a6)			put file from above routine

	move.l	d4,d1				now close the
	jsr	Close(a6)			file and also 
	move.l	a6,a1				close Dos library
	move.l	ExecBase,a6
	jsr	CloseLibrary(a6)

	move.l	PublicMemAddr(a5),a2		workspace addr	     a2
	move.l	ChipMemAddr(a5),a1		original file addr   a1
	move.l	CompFileAddr(a5),a0		compressed file addr a0
	bsr	DECOMPRESS_FILE			finally depack file

	moveq	#0,d0				no errors!
	rts					and return

.Load_error2
	move.l	d4,d1				get file handle and
	jsr	Close(a6)			close file
.Load_error1
	move.l	a6,a1				close Dos library
	move.l	ExecBase,a6
	jsr	CloseLibrary(a6)
.Error	moveq	#-1,d0				flag an error
	rts

*************************************************************************
*************************************************************************
*			Check I.D. of compressed file
*************************************************************************
*************************************************************************
CHECK_ID
	cmp.l	#PHD_FileID,FileID(a5)		is ID verified
	bne.s	.IDerror
	moveq	#0,d0
	rts

.IDerror
	moveq.l	#-1,d0				not PHD compressed file
	rts					type!!

*************************************************************************
*************************************************************************
*		Calculate Memory and address to put file
*************************************************************************
*************************************************************************
CALCULATE_ADDRESS

; exit  d0  is memory required for decompression
;	    which is original file length + safety net
;           value for safety net can be fiddled around with at your risk!! 
;       d1  is address to load compressed file to

	move.l	OrigFileLen(a5),d0	get original length	
	add.l	#PHD_SafetyNet,d0	add on safety buffer

	move.l	d0,d1
	add.l	ChipMemAddr(a5),d1	add address we want to depack to
	sub.l	CompFileLen(a5),d1	subtract compressed length
	subq.l	#4,d1			now we make the address
	and.b	#$fe,d1			even which is essential!!!
	rts

*************************************************************************
*		decompress file subroutine
*************************************************************************
	Even
DECOMPRESS_FILE
			
;Entry		PHD_decompression
;	a0	source addr
;	a1	dest addr
;	a2	work space addr 3670 bytes word aligned
;Exit
;	none
;Trashes
;	none

	incbin	Source/PHD_Decompress.bin	decompression code
	Even					in binary dump format

**************************************************************************
*		set up screen to display
**************************************************************************
SETUP_SCREEN
	move.l	ChipMemAddr(a5),a0
	move.l	a0,BufScreenAddr(a5)
	add.l	#32000,a0
	move.l	a0,ScreenAddr(a5)	a0 now points to color map!

	lea	CLcolors+2(pc),a1	put the colors in copperlist
	moveq	#15,d0
.loop1	move.w	(a0)+,(a1)+
	addq.l	#2,a1
	dbra	d0,.loop1

	bsr	PutNewBPPointers	put the bitplane pointers

	move.l	#CopperList,cop1lc(a6)	set up copper list thingy
	move.w	d0,copjmp1(a6)		strobe
	move.w	#$87c0,dmacon(a6)	start dma

	rts

**************************************************************************
*		X-flip screen if need be else exit
**************************************************************************
X_FLIP_SCREEN
	btst	#LeftMouse,PortA	left mouse button to exit
	beq.s	.exit			
	bsr	GetJoyInput		is fire button pressed
	btst	#2,d0			if so flip screen
	beq.s	X_flip_screen		if not wait

	move.l	ScreenAddr(a5),a0	set up screen flip
	move.l	BufScreenAddr(a5),a1
	moveq	#PicWordsWide,d0
	move.w	#NoPlanes*PicPixelsHigh,d1
	bsr	SpriteXflip
	bsr	PutNewBPPointers	change buffers please
	bra.s	X_flip_screen		and repeat til LMB=>exit

.exit	rts

**************************************************************************
*		put the bitplane pointers in CL
**************************************************************************
PutNewBPPointers
.wait	btst.b	#0,vposr(a6)
	bne.s	PutNewBPPointers		wait for line 0
	tst.b	vhposr(a6)			before updating
	bne.s	PutNewBPPointers		else could corrupt??

	move.l	BufScreenAddr(a5),d0
	move.l	ScreenAddr(a5),BufScreenAddr(a5)
	move.l	d0,ScreenAddr(a5)
	lea	CopperList+2(pc),a0	first we put the bitplane
	moveq	#3,d1			pointers
.loop	bsr	PutPointerInCLM
	add.l	#40,d0
	dbf	d1,.loop
	rts

**************************************************************************
*!!		put pointer in copperlist
**************************************************************************
;entry  d0 pointer
;	a0 copper addr 
PutPointerInCLM
	move.w	d0,(a0)
	addq.l	#4,a0
	swap	d0
	move.w	d0,(a0)
	addq.l	#4,a0
	swap	d0
	rts

**************************************************************************
*!!		get joystick movement
**************************************************************************
GetJoyInput
	move.w	joy1dat(a6),d0		;on exit in d0.w
	and.w	#$0303,d0		left	9
	move.w	d0,d1			right	1
	lsr.w	#1,d1			up	8
	eor.w	d1,d0			down	0
	btst.b	#JoyFire,PortA		fire    2
	bne.s	.ret
	or.b	#$04,d0
.ret	rts


*****************************************************************************
*			Sprite X-flip Subroutine
*			   Paul Douglas 1992
*		flips Bitmap Image about vertical mid point
*****************************************************************************
;Entry	a0.l	address of graphics image (sprite) to flip
;	a1.l	destination addr for flipped sprite
;	d0.w	width of sprite in words
;	d1.w	height of sprite (ie pixels high * number bitplanes)
;
;Exit	none
;
;Trashs	a0-a1/d0-d4	

SpriteXflip
	moveq	#0,d4				clear all bits d4
	subq.w	#1,d1				get lines-1 for dbf
	move.w	d0,d3				copy width to d3
	subq.w	#1,d3				sub #1 for dbf
	add.w	d0,d0				get bytes wide ie words*2
	add.w	d0,a1				get end 1st line of dest
	add.w	d0,d0				get bytes wide * 2

.lineloop
	move.w	d3,d2				renew the width counter
.wordloop
	move.b	(a0)+,d4			get byte to flip
	move.b	.FlipTable(pc,d4.w),-(a1)	get flipped byte into dest
	move.b	(a0)+,d4			do it again so weve flipped
	move.b	.FlipTable(pc,d4.w),-(a1)	a word
	dbf	d2,.wordloop			do all words on scan line

	add.w	d0,a1				get to end next scan line in dest
	dbf	d1,.lineloop			loop *scanlines

	rts

*****************************************************************************

.FlipTable
.0.1f	dc.b	%00000000,%10000000,%01000000,%11000000		look-up
	dc.b	%00100000,%10100000,%01100000,%11100000		table for
	dc.b	%00010000,%10010000,%01010000,%11010000		flipped bytes
	dc.b	%00110000,%10110000,%01110000,%11110000		
	dc.b	%00001000,%10001000,%01001000,%11001000
	dc.b	%00101000,%10101000,%01101000,%11101000
	dc.b	%00011000,%10011000,%01011000,%11011000
	dc.b	%00111000,%10111000,%01111000,%11111000

.20.3f	dc.b	%00000100,%10000100,%01000100,%11000100
	dc.b	%00100100,%10100100,%01100100,%11100100
	dc.b	%00010100,%10010100,%01010100,%11010100
	dc.b	%00110100,%10110100,%01110100,%11110100
	dc.b	%00001100,%10001100,%01001100,%11001100
	dc.b	%00101100,%10101100,%01101100,%11101100
	dc.b	%00011100,%10011100,%01011100,%11011100
	dc.b	%00111100,%10111100,%01111100,%11111100

.40.5f	dc.b	%00000010,%10000010,%01000010,%11000010
	dc.b	%00100010,%10100010,%01100010,%11100010
	dc.b	%00010010,%10010010,%01010010,%11010010
	dc.b	%00110010,%10110010,%01110010,%11110010
	dc.b	%00001010,%10001010,%01001010,%11001010
	dc.b	%00101010,%10101010,%01101010,%11101010
	dc.b	%00011010,%10011010,%01011010,%11011010
	dc.b	%00111010,%10111010,%01111010,%11111010

.60.7f	dc.b	%00000110,%10000110,%01000110,%11000110
	dc.b	%00100110,%10100110,%01100110,%11100110
	dc.b	%00010110,%10010110,%01010110,%11010110
	dc.b	%00110110,%10110110,%01110110,%11110110
	dc.b	%00001110,%10001110,%01001110,%11001110
	dc.b	%00101110,%10101110,%01101110,%11101110
	dc.b	%00011110,%10011110,%01011110,%11011110
	dc.b	%00111110,%10111110,%01111110,%11111110

.80.9f	dc.b	%00000001,%10000001,%01000001,%11000001
	dc.b	%00100001,%10100001,%01100001,%11100001
	dc.b	%00010001,%10010001,%01010001,%11010001
	dc.b	%00110001,%10110001,%01110001,%11110001
	dc.b	%00001001,%10001001,%01001001,%11001001
	dc.b	%00101001,%10101001,%01101001,%11101001
	dc.b	%00011001,%10011001,%01011001,%11011001
	dc.b	%00111001,%10111001,%01111001,%11111001

.a0.bf	dc.b	%00000101,%10000101,%01000101,%11000101
	dc.b	%00100101,%10100101,%01100101,%11100101
	dc.b	%00010101,%10010101,%01010101,%11010101
	dc.b	%00110101,%10110101,%01110101,%11110101
	dc.b	%00001101,%10001101,%01001101,%11001101
	dc.b	%00101101,%10101101,%01101101,%11101101
	dc.b	%00011101,%10011101,%01011101,%11011101
	dc.b	%00111101,%10111101,%01111101,%11111101

.c0.df	dc.b	%00000011,%10000011,%01000011,%11000011
	dc.b	%00100011,%10100011,%01100011,%11100011
	dc.b	%00010011,%10010011,%01010011,%11010011
	dc.b	%00110011,%10110011,%01110011,%11110011
	dc.b	%00001011,%10001011,%01001011,%11001011
	dc.b	%00101011,%10101011,%01101011,%11101011
	dc.b	%00011011,%10011011,%01011011,%11011011
	dc.b	%00111011,%10111011,%01111011,%11111011

.e0.ff	dc.b	%00000111,%10000111,%01000111,%11000111
	dc.b	%00100111,%10100111,%01100111,%11100111
	dc.b	%00010111,%10010111,%01010111,%11010111
	dc.b	%00110111,%10110111,%01110111,%11110111
	dc.b	%00001111,%10001111,%01001111,%11001111
	dc.b	%00101111,%10101111,%01101111,%11101111
	dc.b	%00011111,%10011111,%01011111,%11011111
	dc.b	%00111111,%10111111,%01111111,%11111111

**************************************************************************
**************************************************************************
***********************    Variables	********************************** 
**************************************************************************
**************************************************************************

		RSReset
ChipMemAddr	rs.l	1	base of chip memory
PublicMemAddr	rs.l	1	addr of fast memory

CompFileLen	rs.l	1	length of compressed file inc ID
CompFileAddr	rs.l	1	address to load compressed file
FileID		rs.l	1	ID of file being loaded
OrigFileLen	rs.l	1	Original file length if PHD compressed file

ScreenAddr	rs.l	1	addr of current screen
BufScreenAddr	rs.l	1	addr of other double buffered screen

vars.length	rs.b	0
		Even
variables	ds.b	vars.length
		Even

LoadPathName	dc.b	'df0:ScalerPic.PHD',0	path and filename
		Even				of compressed piccy

**************************************************************************
**************************************************************************
*		Routines to take and restore AmigaDos
**************************************************************************
**************************************************************************
BOSH_SYS
	lea	GraphicsName(pc),a1		open the graphics library
	move.l	ExecBase,a6			to find the system copper
	clr.l	d0				so we can restore it!
	jsr	OpenLibrary(a6)
	move.l	d0,GraphicsBase

	move.l	#Hardware,a6			hardware base address in a6
	move.w	intenar(a6),SystemInts		save system interupts
	move.w	dmaconr(a6),SystemDMA		and DMA settings
	move.w	#$7fff,intena(a6)		kill interupts
.wait	btst.b	#0,vposr(a6)
	bne.s	.wait				wait for line 0
	tst.b	vhposr(a6)			before disabling
	bne.s	.wait				DMA else sprite corruption
	move.w	#$7fff,dmacon(a6)		kill all DMA
	move.b	#%01111111,IcrA			kill CIA-A interupts
	rts

**************************************************************************

FREE_SYS
	move.l	#Hardware,a6			repoint a6 just in case
	move.l	GraphicsBase,a1			get graphics base
	move.l	SystemCopper1(a1),cop1lc(a6)	replace system
	move.l	SystemCopper2(a1),cop2lc(a6)	copperlists
	move.w	SystemInts,d0			restore system
	or.w	#$c000,d0			interupts
	move.w	d0,intena(a6)
	move.w	SystemDMA,d0			and system DMA
	or.w	#$8100,d0
	move.w	d0,dmacon(a6)			finally CIA-A interupts
	move.w	#$000f,dmacon(a6)
	move.b	#%10011011,Icra			ie Keyboard,exec timing
	move.l	ExecBase,a6			get execbase in a6
	move.l	GraphicsBase(pc),a1		close grafix lib
	jsr	CloseLibrary(a6)
	clr.l	d0
	rts					back to where we came from

***************************************************************************

SystemInts		dc.w	0
SystemDMA		dc.w	0
DOSBase			dc.l	0
GraphicsBase		dc.l	0
			Even
GraphicsName		dc.b	'graphics.library',0
			Even
DOSName			dc.b	'dos.library',0

****************************************************************************

CopperList	dc.w	bpl1ptl+2,0		bitplane pointers
		dc.w	bpl1pth+2,0		Low word first!!!!
		dc.w	bpl2ptl+2,0
		dc.w	bpl2pth+2,0	
		dc.w	bpl3ptl+2,0
		dc.w	bpl3pth+2,0	
		dc.w	bpl4ptl+2,0
		dc.w	bpl4pth+2,0	

CLcolors	dc.w	color00+2,$0		screen colors
		dc.w	color01+2,$0		could bung these directly
		dc.w	color02+2,$0		into hardware registers
		dc.w	color03+2,$0		but I like to keep 
		dc.w	color04+2,$0		everything in the copper
		dc.w	color05+2,$0		list where I know I can
		dc.w	color06+2,$0		find it.
		dc.w	color07+2,$0
		dc.w	color08+2,$0
		dc.w	color09+2,$0
		dc.w	color10+2,$0
		dc.w	color11+2,$0
		dc.w	color12+2,$0
		dc.w	color13+2,$0
		dc.w	color14+2,$0
		dc.w	color15+2,$0

		dc.w	bplcon0+2,$4200		4 bitplanes
		dc.w	ddfstrt+2,$0038		standard screen
		dc.w	ddfstop+2,$00d0		set up please
		dc.w	bpl1mod+2,120
		dc.w	bpl2mod+2,120
		dc.w	diwstrt+2,$3781		display start
		dc.w	diwstop+2,$ffc1		panel stop

		dc.w	$ffff,$fffe		End copperlist

**************************************************************************
