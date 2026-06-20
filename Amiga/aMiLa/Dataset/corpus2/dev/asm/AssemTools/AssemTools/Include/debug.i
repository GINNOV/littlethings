;
; ### Library for debugging programs by JM  v1.21 ###
;
; - Created 890312 by JM -
;
; To fully utilize the macros in this file you also need program
; called DeBug by the Supervisor Software.
;
; Edited:
; - 890701 by JM -> v1.1	- .bug macro and data structure added.
; - 890701 by JM -> v1.11	- structure edited.
; - 890702 by JM -> v1.20	- .bug regs now acceps a string as the second
;			  	  parameter.
; - 890702 by JM -> v1.21	- .bug stra added.
;
;
;
;  .flash	flashes the screen in different colors.
;  .bug		currently only dumps the registers to a special screen
;		and watches the memory allocations made by one task.
;		syntax:
;		 .bug regs[,s]	causes the registers to be updated on
;				the screen.  If a string is used as the
;				second parameter the string will be printed
;				on screen.
;		 .bug memb	activates the memory watch for this task.
;				No other task can use this function before
;				the current task releases it using .bug meme
;		 .bug meme	stops the memory watch for this task.  If
;				the alerts were not disabled will inform
;				if any memory blocks were allocated but not
;				released between .bug memb and .bug meme.
;		 .bug stra,adr	prints a string starting at adr.
;
;  The corresponding debugging utility program is called DeBug.  Usage:
;  DeBug i	installes the routines and a global message port.
;  DeBug r	removes all routines and the message port.
;  DeBug c	clears the memory allocation data buffer.
;  DeBug l	lists the current allocations on the default output.
;  DeBug	prints a message telling if DeBug is currently installed.
;
;  The flag bits are supported by the DeBug program but not currently
;  by the command line parser.
;  With the flags you can disable:
;  - watching of memory allocated and freed by ROM routines.
;  - alerts from unreleased memory.
;  - alerts if a block of memory is released with a wrong size.
;
;


.flash		macro	*color
		movem.l	d0/d1,-(sp)
		ifc	'red','\1'
		move.w	#$f00,d0
		endc
		ifc	'green','\1'
		move.w	#$f0,d0
		endc
		ifc	'blue','\1'
		move.w	#$f,d0
		endc
		ifc	'yellow','\1'
		move.w	#$ff0,d0
		endc
		ifc	'white','\1'
		move.w	#$fff,d0
		endc
		ifc	'purple','\1'
		move.w	#$f0f,d0
		endc
		ifc	'cyan','\1'
		move.w	#$0ff,d0
		endc
		ifc	'black','\1'
		move.w	#$0,d0
		endc
		moveq.l	#-1,d1
\@.flash	move.w	d0,$dff180
		move.w	d0,$dff180
		move.w	d0,$dff180
		dbf	d1,\@.flash
		movem.l	(sp)+,d0/d1
		endm



      STRUCTURE MYP,MP_SIZE
	APTR	MyP_CODE		prg code buffer
	APTR	MyP_OBUF		output buffer for Text()
	APTR	MyP_ABUF		output buffer for alerts
	STRUCT	MyP_MYNAME,16		port name
	APTR	MyP_SCREEN		screen*
	APTR	MyP_RPORT		rport*
	APTR	MyP_VPORT		vport*
	APTR	MyP_GFX			gfxbase
	APTR	MyP_INTUITION		intuitionbase
	APTR	MyP_OLDALLOC		AllocMem() in Exec
	APTR	MyP_OLDFREE		FreeMem() in Exec
	APTR	MyP_MEMTASK		task using memwatch
	APTR	MyP_DUMPTASK		task using dumpreg()
	APTR	MyP_ALERTTASK		task using Malert()
	APTR	MyP_MEMBUF		buffer for allocation data
	ULONG	MyP_CHIP		allocated CHIP RAM
	ULONG	MyP_FAST		allocated FAST RAM
	ULONG	MyP_PIECES		# of blocks allocated
	ULONG	MyP_FLAGS		flags
	APTR	MyP_regs		pointer to dumpreg()
	APTR	MyP_memb		pointer to membeg()
	APTR	MyP_meme		pointer to memend()
	APTR	MyP_stra		pointer to prtstr()
	LABEL	MYSIZE


DEBUGPORTNAME	macro
		dc.b	'BuggerBoyPort',0	EVEN LENTGH!!
		endm


.bug		macro	*regs | memb | meme | stra[,string]
\@.bug1		movem.l	a0-a7/d0-d7,-(sp)
		lea.l	\@.bug1(pc),a4		get pc
		movea.l	$4,a6
		jsr	_LVOGetCC(a6)		get cc
		move.l	d0,d7
		lea.l	.debug_port(pc),a1
		jsr	_LVOFindPort(a6)
		tst.l	d0
		beq.s	\@.bug2
		move.l	d0,a1
		move.l	MyP_\1(a1),a1
		ifnc	'\1','stra'
		ifnc	'\2',''
		lea.l	\@.bugs(pc),a0
		endc
		endc
		ifc	'\1','stra'
		move.l	\2,a0
		endc
		jsr	(a1)
		ifnd	.debug_port
		bra.s	\@.bug2
.debug_port	DEBUGPORTNAME
		endc
		ifnc	'\1','stra'
		ifnc	'\2',''
		bra.s	\@.bug2
\@.bugs		dc.b	\2
		dc.b	0
		cnop	0,4
		endc
		endc
\@.bug2		move	d7,CCR
		movem.l	(sp)+,a0-a7/d0-d7
		endm

