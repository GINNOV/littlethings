************************************
* HARDWARE STARTUP FILE:           *
* FREEZES OS & FRIES ALL INTS/DMA  *
*                                  *
* BASED ON THE DAVE JONES STARTUP  *
* USED FOR MENACE.                 *
* CALLS _BOOT                      *
*                                  *
* LAST MOD 27.12.91 P.KENT         *
************************************

	 OPT W-
	 rsreset
SysInts	 rs.w 	1
SYsDMA	 rs.w 	1
lev2	 rs.l 	1
lev3	 rs.l 	1
InfoSize rs.w 	1

	list
* HWStart V2 1992 P.Kent *
	nolist
	Push d1-d7/a0-A6
	move.l	4.w,a6
	jsr	-132(a6)					* FORBID SYSTEM
	Lea	SysInfo(pc),a0
	Lea	$dff000,a6
	blitwait a6
	catchvb a6
	move.w	intenar(a6),SysInts(a0)	* SAVE INTS/DMA
	move.w	dmaconr(a6),SysDMA(a0)	
	move.w	#$7fff,intena(a6) 		* KILL INTS/DMA
	move.w	#$7fff,dmacon(a6)
	move.l	$68.w,Lev2(a0) 			
	move.l	$6c.w,Lev3(a0)  		
	bsr	_boot
	Lea $dff000,a6
	Lea Sysinfo(pc),a0
	move.l	Lev2(a0),$68.w			* RECOVER VECTORS
	move.l	Lev3(a0),$6c.w			
	move.l	4.w,a1					* RECOVER COPPER
	move.l  (a1),a1
	move.l  (a1),a1
	move.l	$26(a1),cop1lch(a6)	  
	move.l	$32(a1),cop2lch(a6)
	move.w	SysInts(a0),d0			* RECOVER INTS/DMA
	or.w	#$c000,d0
	move.w	d0,intena(a6)
	move.w	SysDMA(a0),d0
	or.w	#$8100,d0
	move.w	d0,dmacon(a6)
	move.l	4.w,a6
	jsr	-138(a6) 					* ENABLE MULTI-TASKING
	Pop d1-d7/a0-a6
	MOVEQ   #0,D0
	rts

Sysinfo ds.b	 Infosize
	OPT	W+
	
