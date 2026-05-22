


* hardware capture intro file
* this file is a header for all programs that seize
* control of the machine hardware & tell the operating
* system to go and take a hike

* NB : header file "my_hardware.i" myst be included BEFORE this one!!!



begin		bra.s	boot

* trap1 : entered using TRAP #1 instruction
* set supervisor mode for 68000

trap1		move.w	(sp)+,d0		;get status reg
		bset	#13,d0		;set supervisor mode
		move.w	d0,-(sp)		;put back
null_vector	rte			;return in supervisor mode

* main boot procedure for non-AmigaDos programs

boot		lea	trap1(pc),a0
		move.l	a0,$84.W		;set up trap #1 vector
		trap	#1		;get into supervisor mode

		or.w	#$700,sr		;kill interrupts

		lea	$DFF000,a5	;a5 always points to custom chips!

		move.w	#$7FFF,INTENA(a5)	;disable ints
		move.w	#$7FFF,INTREQ(a5)	;halt all int requests
		move.w	#$7FFF,DMACON(a5)	;kill DMA for now
		
* from here on, set up user Copper list, bitplanes,
* screen parameters and other features in the including file
* Note : only re-enable DMA & ints once Copper, VBL routines
* and other stuff are on-line.


