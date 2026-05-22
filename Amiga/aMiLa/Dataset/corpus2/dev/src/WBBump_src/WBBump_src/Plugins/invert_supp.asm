******************
* invert_sub.asm *
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


	xdef	invert_buffer_iii


***	inver_buffer(inbuf, outbuf, size)

*** 12 inbuf	:	ucharptr
***  8 outbuf	:	ucharptr
***  4 size	:	ulong


invert_buffer_iii:
	move.l	12(sp),a0
	move.l	8(sp),a1
	move.l	4(sp),d0

	move.l	d0,d1
	and.l	#%1111,d0	*	rest in d0

	lsr.l	#4,d1		*	number of 16 byte words in d1

.l1
	move.l	(a0)+,d2
	move.l	(a0)+,d3
	move.l	(a0)+,d4
	move.l	(a0)+,d5
	not.l	d2
	not.l	d3
	not.l	d4
	not.l	d5
	move.l	d2,(a1)+
	move.l	d3,(a1)+
	move.l	d4,(a1)+
	move.l	d5,(a1)+

	sub.l	#1,d1
	bne		.l1

	* the rest

.l2
	move.b	(a0)+,d2
	not.b	d2
	move.b	d2,(a1)+
	sub.b	#1,d0
	bne		.l2

	rts
