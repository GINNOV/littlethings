*****************
* hmap2true.asm *
*****************



***    WBBump - Bumpmapping on the Workbench!

***    Copyright (C) 1999  Thomas Jensen - dm98411@edb.tietgen.dk

***    This program is free software; you can redistribute it and/or modify
***    it under the terms of the GNU General Public License as published by
***    the Free Software Foundation; either version 2 of the License, or
***    (at your option) any later version.

***    This program is distributed in the hope that it will be useful,
***    but WITHOUT ANY WARRANTY; without even the implied warranty of
***    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
***    GNU General Public License for more details.

***    You should have received a copy of the GNU General Public License
***    along with this program; if not, write to the Free Software Foundation,
***    Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.




	MACHINE	68020


	XDEF	hmap2true_iiiiiiiii



BOUNDS_UBYTE	MACRO		* \1 = reg

	cmp.w	#$ff,\1
	bls	.j1\@
	move.w	#$ff,\1
.j1\@
	ENDM




GET_DIST	MACRO	* \1 = Dx	result reg (bits 0-15 will be cleared)
			* \2 = Dx	temp reg (bits 8-15 must be 0)
			* \3 = Dx	current pixel position
			* \4 = Dx	current light position
			* \5 = Ax	pointer to pixel 1 (eg. -1(a0))
			* \6 = Ax	pointer to pixel 2 (eg. 1(a0))

	clr.w	\1
	move.b	\6,\2		* pixel to the right
	move.b	\5,\1		* pixel to the left
	sub.w	\2,\1		* sub right pixel

*	asl.w	#2,\1		* make it look nicer

	add.w	\3,\1		* add current pixel position
	sub.w	\4,\1		* sub light position

	* convert to positive value
	bpl	.j1\@		* branch if plus
	neg.w	\1		* else negate
.j1\@

	ENDM




***	hmap2true( brighttable[256][256], hmap, inbuf:RGB, outbuf:RGB, skip, width, height, lightx, lighty )


*** 36 brigthtable:	uchar ptr	- ptr to 256*256 table
*** 32 hmap	:	char ptr	- ptr to heightmap
*** 28 inbuf	:	RGB ptr		- ptr to src rgb buffer
*** 24 outbuf	:	RGB ptr		- ptr to dest rgb buffer
*** 20 skip	:	uchar		- value to add to in/out buf after each line
*** 16 width	:	uword
*** 12 height	:	uword
***  8 lightx	:	sword
***  4 lighty	:	sword


hmap2true_iiiiiiiii:
	* store value af A4 (E requirement)
	move.l	a4,a4store
	move.l	a5,a5store

	* get arguments from stack

	move.l	36(sp),.brighttable
	move.l	.brighttable,a2

	move.l	32(sp),.hmap
	move.l	.hmap,a0

	move.l	28(sp),.inbuf
	move.l	.inbuf,a1

	move.l	24(sp),.outbuf
	move.l	.outbuf,a5

	move.l	20(sp),.skip

	move.w	16+2(sp),.width
	move.w	12+2(sp),.height

	move.w	8+2(sp),.lightx
	move.w	4+2(sp),.lighty

	move.l	.hmap,a3
	sub.l	16(sp),a3

	move.l	.hmap,a4
	add.l	16(sp),a4



	clr.l	d2	* we need to use (Ax,D2.l)

	clr.l	d7


	moveq.l	#0,d1	* d1 is y loop counter
.ly
	moveq.l	#0,d0	* d0 is x loop counter
.lx

	* should we calc brightness ?
	cmp.b	#05,(a0)
	bls	.drawtrough

	* light x

	GET_DIST	d2, d7, d0, .lightx, -1(a0), 1(a0)


	* light y

	GET_DIST	d3, d7, d1, .lighty, (a3), (a4)



	* bounds check

	BOUNDS_UBYTE	d2	* convert values > 255 to 255

	BOUNDS_UBYTE	d3	* convert values > 255 to 255


	* prepare index word

	lsl.w	#8,d2		* x in upper 8 bits of index word
	move.b	d3,d2		* and y in the lower


	* get the actual brightness and put it into buffer

	move.b	0(a2,d2.l),d7	* brightness in d7

	not.b	d7		* the brightness is actually darkness in the table (might change that)


	MACRO	DO_COLOR

	clr.w	d4

	move.b	(a1)+,d4	* get color value
	add.w	d7,d4		* add brightness
	BOUNDS_UBYTE d4		* overflow ?

	move.b	d4,(a5)+
	ENDM


	REPT 3
	DO_COLOR	* red, green and blue
	ENDR

	bra	.loopout	* skip the drawtrough


.drawtrough	* just copy

	REPT 3
	move.b	(a1)+,(a5)+
	ENDR

.loopout

	* increase pointers
	addq	#1,a0
	addq	#1,a3
	addq	#1,a4



	*** x loop ***
	addq.w	#1,d0
	cmp.w	.width,d0
	bne	.lx

	* add skip values
	REPT 3
	add.l	.skip,a1
	add.l	.skip,a5
	ENDR

	*** y loop ***
	addq.w	#1,d1
	cmp.w	.height,d1
	bne	.ly

	* put original a4 value back where it belongs
	move.l	a4store,a4
	move.l	a5store,a5

	rts


*** local variables

.brighttable	dc.l	0
.hmap		dc.l	0
.inbuf		dc.l	0
.outbuf		dc.l	0
.skip		dc.l	0
.width		dc.w	0
.height		dc.w	0
.lightx		dc.w	0
.lighty		dc.w	0

a4store:	dc.l	0
a5store:	dc.l	0
