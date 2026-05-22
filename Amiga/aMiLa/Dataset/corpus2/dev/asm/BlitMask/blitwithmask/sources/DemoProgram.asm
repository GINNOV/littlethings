	*««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««*
	*
	*   © 1996 by Kenneth C. Nilsen. E-Mail: kennecni@idgOnline.no
	*
	*   Name
	*	DrawImageTrans(rastport,image,dx,dy) (a0/a1,d0/d1)  ver. 1.1
	*	(compatible with the DrawImage()!)
	*	Code is re-entrant!
	*
	*   Function
	*	DEMO program to show the new DrawImageTrans() function
	*	The new function will draw image, but background can be seen
	*	thrue.
	*
	*	The image does not have to be in CHIP ram. It can as well be
	*	in fastram since this function will check what type of mem the
	*	imagedata is in and if fast this routine will copy it down
	*	to chip mem temporarly.
	*
	*   Inputs
	*	rastport - pointer to the rastport the image will be drawn in
	*	image - pointer to an image structure
	*	dx - delta x to image structure position
	*	dy - delta y to image structure position
	*
	*   Notes
	*	To assemble this source you will need:
	*	NewStartup39.lha (Aminet:dev/asm/)
	*	or from Bodø BBS: + 47 7552 2008 (ABBS)
	*	Image data (make your own image, see bottom) just remember to
	*	reinitialize the image structure.
	*
	*	Only for OS 3.x and above because of AllocBitmap().
	*	This function may use the blitter.
	*	Image data can be in fastram (future feature)
	*
	*	This demo program uses BUSYWAIT loop to wait for the mouse.
	*	To /busy/ to fix that now.. do it yourself ;-)
	*
	*   Bugs
	*	One bitplane can only be 64Kb in size.
	*	If images are in fastram the total image can not be larger
	*	than 64Kb. Solve this by using a math library.
	*
	*   Created	: 28.10.96
	*   Last change	: 29.10.96
	*»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»*

*## For the Startup.asm (V3.9!):

; NewStartup39.lha can be downloaded from AmiNet from dev/asm/

StartSkip	=	0		;0=WB/CLI, 1=CLI only  (AsmOne)

;CpuCheck	set	1		;if these aren't defined the CPU or/
;MathCheck	set	1		;and math will be ignored

Processor	=	0		;0/680x0/0x0
MathProc	=	0		;0/68881/68882/68040/68060

*## For the DUMPSTRING macro:

;DODUMP		SET	1		;define to activate DebugDump and
					;InitDebugHandler
*## For the window we'are gonna open:

x	=	140
y	=	30
width	=	340
height	=	230

*## Default includes:

		Incdir	""

		Include	lvo:Exec_lib.i
		Include	lvo:Intuition_lib.i
		Include	lvo:Graphics_lib.i

		Incdir	inc:

		Include	Digital.macs
		Include	graphics/rastport.i
		Include	intuition/intuition.i
	
		Include	Startup.asm

		Incdir	""

	dc.b	"$VER: DrawImageTrans() 1.1 (29.10.96) ",10
	dc.b	"Copyright © 1996, Kenneth C. Nilsen. All rights reserved.",10
	dc.b	"This program is PUBLIC DOMAIN!",13,10,0
	even
*»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»*
Init	TaskName	"DrawImageTrans() DEMO"
	DefLib	graphics,39
	DefLib	intuition,39
	DefEnd

Start	InitDebugHandler	"CON:0/20/640/160/Debug Output/WAIT/CLOSE"

	DebugDump	"Program start",0

	LibBase	intuition

	sub.l	a0,a0
	lea	WinTags(pc),a1
	Call	OpenWindowtaglist
	move.l	d0,WinBase
	beq.w	Close

	move.l	d0,a0
	move.l	50(a0),Rast

* Draw some background fill, f.ex. lines :-)

	DebugDump	"Background...",1

	LibBase	graphics

	moveq	#10,d5		;steps
	moveq	#0,d6		;x position
	moveq	#0,d7		;color

.loopX	move.l	rast(pc),a1
	move.l	d7,d0
	Call	SetAPen
	addq.l	#1,d7

	move.l	rast(pc),a1
	moveq	#0,d0
	moveq	#0,d1
	Call	Move

	move.l	Rast(pc),a1
	move.w	d6,d0
	move.w	#height,d1
	Call	Draw

	add.w	d5,d6
	cmp.w	#width,d6
	blt.w	.loopX

	moveq	#10,d5		;steps
	moveq	#0,d6		;y position
	moveq	#0,d7		;color

.loopY	move.l	rast(pc),a1
	move.l	d7,d0
	Call	SetAPen
	addq.l	#1,d7

	move.l	rast(pc),a1
	moveq	#0,d0
	moveq	#0,d1
	Call	Move

	move.l	Rast(pc),a1
	move.w	#width,d0
	move.w	d6,d1
	Call	Draw

	add.w	d5,d6
	cmp.w	#height,d6
	blt.w	.loopY

* Outch, we were nasty so we'll make it up by refreshing the windowborder :*)

	LibBase	intuition

	move.l	WinBase(pc),a0
	Call	RefreshWindowFrame

* Show how the old DrawImage() works:

	DebugDump	"Draw image with DrawImage()",2

	move.l	Rast(pc),a0
	lea	ImageStruct,a1
	move.w	#(width-247)/2,d0		;justify into middle of window
	moveq	#32,d1
	Call	DrawImage

* Our routine:

	DebugDump	"Draw image with our function...",3

	move.l	Rast(pc),a0
	lea	ImageStruct,a1
	move.w	#(width-247)/2,d0
	moveq	#127,d1
	bsr.w	DrawImageTrans

	DebugDump	"Ok",4

	hold

*·············································································*
Close	LibBase	intuition

	CloseWin WinBase

	DebugDump	"Program end!",5

	Return	0
*»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»*
DrawImageTrans	;this routine should be called as a library routine!
		;See intuition.library/DrawImage() for more info.

** SOME COMMENTS **************************************************************
*
* This function only works with OS 3.x because of the AllocBitmap() function.
* However this can be worked around by making your own AllocBitmap() function.
* DFunc.library provides this function in OS 2.x and above as well (util/libs).
*
* How it works:
*
*	- First we create our own special private structure to contain
*	  important data. The reason is that this will be easier and more safer
*	  to program with.
*	- Then we initialize it with datas from the function call and from the
*	  image structure itself
*	- We allocate space for a rastport (we want this code to be re-entrant)
*	- Then we InitRastport on our own rastport
*	- Then we allocate a bitmap with same dimensions as the image
*	- We initialize our bitmap into that rastport
*	- Then we DrawImage() the image into our own rastport. This is because
*	  we need to get the plane datas and we will have an image to blit
*	  thrue the mask we're gonna create with the bitmap.
*	  NOTE: first we MUST clean next_image entry in the image structure or
*	  else the routine will draw a whole list with images if that's so.
*	  Also: we clear the x and y position since we need this image to be
*	  at a zero offset in our bitmap. After the DrawImage() we restore the
*	  values.
*	- Now we calculate how many bytes there are in one bitplane in image
*	- Then we allocate a mask buffer equal the calculated size
*	- We OR all bitplanes in our bitmap into our maskplane
*	- Then we invert the image in our bitmap
*	- And finally we set the destination position and blit it back to
*	  the final bitmap
*	- We take a clean up
*	- At last we check the Next_image field and if non-empty, repeat the
*	  process.
*	- Phew! :-)
*
* NOTES: Some differences from the DrawImage()
*
* If the image has less bitplanes than the bitmap it's suppose to be drawn in
* the last bitplane will not be considered (eg. not cleared) so pixels set in
* that last bitplane will be there on top of image.
*
* This routine is slower than the DrawImage() (not to suprising I guess :).
* It's uses the DrawImage() itself pluss a couple of blitter functions and
* OR algorithm and finally memory functions and precalculation.
* However, you could optimize this routine and sent a copy back to me. That
* would be nice considering my pre-work eh? :-) (kennecni@IDGonline.no).
*
* Returns NULL if any errors!
*
* SMART STUFF:
*
* The imagedata doesn't have to be in CHIP_MEM with this function. It will
* check the memory attributes of the imagedata block and if it's in FAST_MEM
* it will create a temporary chip_mem buffer and copy the image data into it.
* Then it will replace the imagedata pointer temporarly and restore it after
* use.
*
* This routine uses the original DrawImage() to make the PlanePickOnOff etc.
* to be compatible. This saves us for lot of problems calculatingthe image
* data itself.
*
* Another feature of this function is that it's not required to have as many
* bitplanes in the destination bitmap as the image itself. The DrawImage()
* would not work to well if the image had more bitplanes than the destBM.
* This function automatically truncates the bitmap thanks to the Blt** funcs.
* (don't take this statement to serious since I am not 100% ;-)
*
*
* This routine can be way optimized. If you do so please send a copy back to
* me.
*
*******************************************************************************

* To make the function work more flawlessly, we make a buffer for own data:

    STRUCTURE  PrivateDIT,0		;DIT ?!? :)

	long	dit_rastport		;destination rastport
	long	dit_myrastport		;our "fake" rastport
	long	dit_bitmap		;our bitmap
	long	dit_mask		;our maskplane
	long	dit_image		;image structure
	long	dit_imagedata		;ptr. to image data (body)
	long	dit_orgimage		;original imagedata if in fastram
	long	dit_imagesize		;total size of image in bytes
	word	dit_dx			;delta x
	word	dit_dy			;delta y
	word	dit_x			;image structure x
	word	dit_y			;image structure y
	word	dit_width
	word	dit_height
	word	dit_depth		;depth of image (we use word here)
	byte	dit_flag		;set if image is in fastram
	byte	dit_padme

	label	dit_sizeof

	movem.l	d2-d7/a2-a6,-(sp)	;preserve regs. Scratch: a0/a1/d0/d1

.start	move.l	d0,d2			;backup some values
	move.l	d1,d3
	move.l	a0,a2
	move.l	a1,a3

* Allocate our structure:

	LibBase	exec

	move.l	#dit_sizeof,d0
	move.l	#$10001,d1
	Call	AllocMem		;alloc structure
	tst.l	d0
	beq.w	.exit			;exit if error

* Init data:

	move.l	d0,a5			;our structure
	move.l	a2,dit_rastport(a5)	;function data:
	move.l	a3,dit_image(a5)
	move.w	d2,dit_dx(a5)
	move.w	d3,dit_dy(a5)
	move.l	0(a3),dit_x(a5)		;copy x and y
	move.l	4(a3),dit_width(a5)	;copy width and height
	move.w	8(a3),dit_depth(a5)
	move.l	10(a3),dit_imagedata(a5)
	move.l	10(a3),dit_orgimage(a5)

* Calculate number of bytes in image (one bitplane):

	move.w	dit_width(a5),d7
	ext.l	d7
	add.w	#15,d7			;word aligned
	divu	#8,d7			;get bytes (from word aligned pixels)
	ext.l	d7			;remove decimals
	move.w	dit_height(a5),d1	;number of rows (height)
	ext.l	d1			;remove trash in upper word
	mulu	d1,d7			;multiply the byte width and rows
	ext.l	d7			;number of bytes in one bitplane

* Check if imagedata is in chipmem or in fastmem:

	move.l	10(a3),a1
	Call	TypeOfMem
	cmp.l	#$703,d0	;$703 = CHIP_MEM
	beq.b	.inChip		;it's already in chip so don't bother

	move.l	d7,d0
	move.w	dit_depth(a5),d1
	ext.l	d1
	mulu	d1,d0
	move.l	d0,dit_imagesize(a5)
	move.l	d0,d2
	move.l	#$10002,d1
	Call	AllocMem		;alloc chip buffer for imagedata
	move.l	d0,dit_imagedata(a5)	;store in structure
	beq.w	.error2			;well, no chip buffer.. 8~(

	move.l	d0,a1
	move.l	dit_orgimage(a5),a0
	subq.l	#1,d2
.copyI	move.b	(a0)+,(a1)+		;copy imagedata to our chip buffer
	dbra	d2,.copyI

	st	dit_flag(a5)		;set flag telling we use own I-buffer

* Create a rastport structure

.inChip	move.l	#rp_sizeof,d0
	moveq.l	#$1,d1			;InitRastport() will clear the buffer
	Call	AllocMem		;allocate rastport structure
	move.l	d0,dit_myrastport(a5)
	beq.w	.error2

* Allocate bitmap for rastport:

	LibBase	graphics

	move.l	d0,a1
	Call	InitRastport		;make our rastport valid

	move.w	dit_width(a5),d0
	move.w	dit_height(a5),d1
	move.w	dit_depth(a5),d2
	move.l	#BMF_DISPLAYABLE,d3
	sub.l	a0,a0
	Call	AllocBitmap		;get a bitmap for our rastport
	move.l	d0,dit_bitmap(a5)
	beq.w	.error3

	move.l	dit_myrastport(a5),a0	;our rastport
	move.l	d0,rp_bitmap(a0)	;copy bitmap into rastport

* draw image into our rastport:

	LibBase	intuition

	move.l	dit_myrastport(a5),a0
	move.l	dit_image(a5),a1
	move.l	dit_imagedata(a5),10(a1)	;use our buffer in case no_chip
	move.l	16(a1),d3
	clr.l	(a1)		;no dx or dy
	clr.l	16(a1)		;and no next_image!
	moveq	#0,d0
	moveq	#0,d1
	Call	DrawImage		;DrawImage()
	move.l	dit_image(a5),a1
	move.l	dit_orgimage(a5),10(a1)	;restore original image buffer
	move.l	dit_x(a5),(a1)		;restore dx and dy
	move.l	d3,16(a1)		;restore next_image

	LibBase	exec

	tst.b	dit_flag(a5)
	beq.b	.noChip

	move.l	dit_imagesize(a5),d0
	move.l	dit_imagedata(a5),a1
	Call	FreeMem
	sf	dit_flag(a5)

.noChip	move.l	d7,d0
	move.l	#$10002,d1
	Call	AllocMem		;allocate mask space in chipram
	tst.l	d0
	beq.w	.cleanup

	move.l	d0,a4

* Now OR all planes together:

	move.l	dit_orgimage(a5),a3	;image data (body)
	move.w	dit_depth(a5),d6	;number of bitplanes in image
	ext.l	d6			;number of bitplanes
	bra.b	.goon2
.init	move.l	d7,d2			;number of bytes to count
	lea	(a4),a0			;mskplane start pointer
	bra.b	.goon1
.ORit	move.b	(a3)+,d0
	or.b	d0,(a0)+
.goon1	dbra	d2,.ORit
.goon2	dbra	d6,.init

* Blit image back from bitmap to rastport with our mask:

	LibBase	graphics

* Invert source bitmap:

	move.l	dit_bitmap(a5),a0
	lea	(a0),a1
	sub.l	a2,a2
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	move.w	dit_width(a5),d4
	move.w	dit_height(a5),d5
	move.b	#$30,d6		;invert source before copy back to itself
;here we invert the source first.. see below.
	move.l	d7,-(sp)
	moveq.l	#-1,d7
	Call	BltBitmap

	Call	WaitBlit

	move.l	dit_bitmap(a5),a0
	moveq	#0,d0
	moveq	#0,d1
	move.l	dit_rastport(a5),a1
	move.w	dit_x(a5),d2		;the image structure x pos.
	move.w	dit_y(a5),d3
	add.w	dit_dx(a5),d2		;add function delta x
	add.w	dit_dy(a5),d3		;the same with the y pos.
	move.l	#$20,d6			;Blitmode: ANBC
;If someone knows a combination to blit thrue the mask without inverting the
;source I would be pleased to hear from you! If so the function call above can
;be eliminated!
	lea	(a4),a2			;our maskplane
	Call	BltMaskBitMapRastPort

	Call	WaitBlit

	LibBase	exec

	lea	(a4),a1
	move.l	(sp)+,d0
	Call	FreeMem			;free maskplane

	LibBase	graphics
	move.l	dit_bitmap(a5),a0
	Call	FreeBitmap		;free bitmap

	LibBase	exec
	move.l	dit_myrastport(a5),a1
	move.l	#rp_sizeof,d0
	Call	FreeMem			;free rastport

	move.l	dit_rastport(a5),a3	;get function call datas
	move.l	dit_image(a5),a4
	move.w	dit_dx(a5),d2
	move.w	dit_dy(a5),d3

	lea	(a5),a1
	move.l	#dit_sizeof,d0
	Call	FreeMem			;free our struct (data becomes invalid)

	tst.l	16(a4)			;a next_image ?
	beq.b	.ok			;nope, exit
	lea	(a3),a0
	move.l	16(a4),a1
	move.w	d2,d0
	move.w	d3,d1
	bra.w	.start			;instant replay! :-)

.ok	moveq.l	#-1,d0			;no errors!

.exit	movem.l	(sp)+,d2-d7/a2-a6
	rts

.error2	LibBase	exec			*** failure at alloc rastport
	move.l	a5,a1
	move.l	#dit_sizeof,d0
	Call	FreeMem			;free our structure
	moveq.l	#0,d0
	movem.l	(sp)+,d2-d7/a2-a6
	rts

.error3	LibBase	exec			*** failure at allocbitmap
	move.l	dit_myrastport(a5),a1
	move.l	#rp_sizeof,d0
	Call	FreeMem			;free rastport

	move.l	a5,a1
	move.l	#dit_sizeof,d0
	Call	FreeMem			;free our structure
	moveq.l	#0,d0
	movem.l	(sp)+,d2-d7/a2-a6
	rts

.cleanup
	LibBase	graphics
	move.l	dit_bitmap(a5),a0
	Call	FreeBitmap		;free bitmap

	LibBase	exec
	move.l	dit_myrastport(a5),a1
	move.l	#rp_sizeof,d0
	Call	FreeMem			;free rastport

	tst.b	dit_flag(a5)
	beq.b	.noC
	move.l	dit_imagesize(a5),d0
	move.l	dit_imagedata(a5),a1
	Call	FreeMem			;free our chip buffer

.noC	move.l	a5,a1
	move.l	#dit_sizeof,d0
	Call	FreeMem			;free our structure
	moveq.l	#0,d0
	movem.l	(sp)+,d2-d7/a2-a6
	rts
*»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»*
WinTags	dc.l	WA_Left,x
	dc.l	WA_Top,y
	dc.l	WA_Width,width
	dc.l	WA_Height,height
	dc.l	WA_Activate,-1
	dc.l	WA_RMBTrap,-1
	dc.l	WA_Title,WinName
	dc.l	0,0
*·············································································*
ImageStruct
	dc.w	0,0,247,81,3
	dc.l	Image
	dc.b	%111,%111
	dc.l	0
*·············································································*
WinBase	dc.l	0
Rast	dc.l	0
*·············································································*
WinName	dc.b	"DEMO program for DrawImageTrans()",0
*»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»*
	even

* TRY to toggle the section and see what happans :) ... our routine still draws

	section	imagedata,data_c

	incdir
Image	incbin	data:pics/DemoImage247x81x3.raw

* convert a brush to raw (the size is up to you)
*»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»*
