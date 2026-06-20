******************
* blur_sub.asm *
******************



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


	xdef	blur_buffer_iiii


***	blur_buffer(inbuf, outbuf, width, height)

*** 16 inbuf	:	ucharptr
*** 12 outbuf	:	ucharptr
***  8 width	:	ulong
***  4 height	:	ulong


blur_buffer_iiii:
	move.l	16(sp),a0	*	input
	move.l	12(sp),a3	*	output
	move.l	 8(sp),d0	*	width
	move.l	 4(sp),d1	*	height

	add.l	d0,a0		*	one line down
	add.l	#1,a0		*	one line + 1 pixel to the right (boundry)
	move.l	a0,a1
	sub.l	d0,a1		*	one line up
	move.l	a0,a2
	add.l	d0,a2		*	one line down


	sub.l	#2,d0		*	width-2
	sub.l	#2,d1		*	height-2


.ly
	move.l	d0,d2
.lx

	clr.w	d3
	clr.w	d4

	move.b	(a1)+,d3
	move.b	(a2)+,d4
	add.w	d4,d3
	move.b	-1(a0),d4
	add.w	d4,d3
	move.b	1(a0),d4
	add.w	d4,d3
	move.b	(a0)+,d4
	lsl.w	#2,d4
	add.w	d4,d3
	lsr.w	#3,d3

	move.b	d3,(a3)+

	subq.l	#1,d2
	bne	.lx

	add.l	#2,a0
	add.l	#2,a1
	add.l	#2,a2
	add.l	#2,a3

	subq.l	#1,d1
	bne	.ly

	rts
