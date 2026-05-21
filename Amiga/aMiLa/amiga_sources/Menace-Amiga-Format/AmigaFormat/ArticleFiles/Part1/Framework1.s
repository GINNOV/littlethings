*****************************************************************************
*									    *
*	Amiga system takeover framework					    *
*	1988 Dave Jones, DMA Design			   	   	    *
*						    			    *
* Allows killing of system, allowing changing of all display & blitter	    *
* hardware, restoring to normal after exiting.			     	    *
* Memory must still be properly allocated/deallocated upon entry/exit       *
* DOS routines for loading must be called BEFORE killing the system   	    *
*						    			    *
* Written using Devpac2					    		    *
*						    			    *
*****************************************************************************

	section	Framework,code_c	


*** READ ME!! ***************************************************
*
*  I've changed Dave's original code to allow both ArgAsm and
*  Devpac users to use this source code without modification.
*  The include files included with ArgAsm are not the same as
*  those found on the Devpac program disk, therefore several
*  assignments need to be made to make things work.
*
*                                             - Jason H.
*
*****************************************************************

	ifd	__ArgAsm

	incdir          "include:"
	include         exec/funcdef.i

_SysBase	equ	$04

	elseif

	incdir          "include/"

	endc

** END OF CONDITIONAL STUFF *************************************


	include 	libraries/dos_lib.i
	include 	exec/exec_lib.i
	include 	hardware/custom.i

Hardware		equ	$dff000
MemNeeded		equ	32000
SystemCopper1	equ	$26
SystemCopper2	equ	$32
PortA		equ	$bfe001
ICRA		equ	$bfed01
LeftMouse		equ	6

*******************************************************************************

start	lea	GraphicsName(pc),a1	open the graphics library purely
	move.l	_SysBase,a6		to find the system copper
	clr.l	d0
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,GraphicsBase
	lea	DOSName(pc),a1		open the DOS library to allow
	clr.l	d0			the loading of data before
	jsr	_LVOOpenLibrary(a6)	killing the system
	move.l	d0,DOSBase

	move.l	#MemNeeded,d0		properly allocate some chip
	moveq.l	#2,d1			memory for screens etc.
	jsr	_LVOAllocMem(a6)	d1 = 2, specifies chip memory
	tst.l	d0			where screens,samples etc
	beq	MemError		must be (bottom 512K)
	move.l	d0,MemBase

*******************************************************************************

	move.l	#Hardware,a6		due to constant accessing
	bsr	TakeSystem		of the hardware registers
*					it is better to offset
wait	btst	#LeftMouse,PortA	them from a register for
	bne	wait			speed & memory saving (a6)

*******************************************************************************

	bsr	FreeSystem

	move.l	_SysBase,a6
	move.l	MemBase,a1
	move.l	#MemNeeded,d0		free the memory we took
	jsr	_LVOFreeMem(a6)
MemError	move.l	GraphicsBase,a1	
	jsr	_LVOCloseLibrary(a6)
	move.l	DOSBase,a1		finally close the 
	jsr	_LVOCloseLibrary(a6)	libraries
	clr.l	d0
	rts

*******************************************************************************

TakeSystem	move.w	intenar(a6),SystemInts	save system interupts
	move.w	dmaconr(a6),SystemDMA		and DMA settings
	move.w	#$7fff,intena(a6)		kill everything!
	move.w	#$7fff,dmacon(a6)
	move.b	#%01111111,ICRA			kill keyboard
	move.l	$68,Level2Vector		save these interrupt vectors
	move.l	$6c,Level3Vector		as we will use our own 
	rts					keyboard & vblank routines

FreeSystem	move.l	Level2Vector,$68	restore the system vectors
	move.l	Level3Vector,$6c		and interrupts and DMA
	move.l	GraphicsBase,a1			and replace the system
	move.l	SystemCopper1(a1),Hardware+cop1lc	copper list
	move.l	SystemCopper2(a1),Hardware+cop2lc
	move.w	SystemInts,d0
	or.w	#$c000,d0
	move.w	d0,intena(a6)
	move.w	SystemDMA,d0
	or.w	#$8100,d0
	move.w	d0,dmacon(a6)
	move.b	#%10011011,ICRA			keyboard etc back on
	rts

*******************************************************************************

Level2Vector	dc.l	0
Level3Vector	dc.l	0
SystemInts	dc.w	0
SystemDMA	dc.w	0
MemBase		dc.l	0
DOSBase		dc.l	0
GraphicsBase	dc.l	0
crap		dc.b	0

	even
GraphicsName	dc.b	'graphics.library',0
	even
DOSName		dc.b	'dos.library',0
	end

