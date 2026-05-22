;
; FakeFastMemPatch
; Assemble to executable.
;
; This program is so short that this source file comprises the
; entire documentation!
;
; This is a patch to AllocMem() which causes it to ignore all memory
; requirements of MEMF_FAST. This means that all requests for fast
; memory get turned into requests for don't care memory, which means
; that otherwise incompatable programs will run on machines with no
; fast memory.
;
; To use this program, place it somewhere in your command searchpath
; and then add the following line to your user-startup file
; (at any point after the command search path has been established).
;
; FakeFastMemPatch
;
; It is impossible to remove the patch once it has been installed,
; except by resetting the machine. The patch stays in effect until
; you reset.
;
	include	earth/earth.i
;
; This bit of code allocates the patch and copies code into it.
;
FakeFastMemPatch
	move.l	a2,-(sp)
	move.l	#FFMPEnd-FFMPPatch,d0
	move.l	#MEMF_PUBLIC|MEMF_REVERSE,d1	See below
	move.l	4,a6
	CALL	AllocMem		Attempt to get memory for patch
	tst.l	d0
	beq.b	FFMPExit		Abort if attempt failed
	move.l	d0,a2

	lea.l	FFMPPatch,a0
	move.l	a2,a1
	move.l	#FFMPEnd-FFMPPatch,d0
	CALL	CopyMem			Copy code into allocated memory

	CALL	Forbid			Forbid so noone can call AllocMem()
	move.l	4,a1
	move.l	#_LVOAllocMem,a0
	move.l	a2,d0
	CALL	SetFunction		Patch AllocMem()
	move.l	d0,FFMPEnd-FFMPPatch-4(a2)
	;				Update jump vector within patch
	CALL	Permit			Permit so we can call AllocMem()

FFMPExit
	move.l	(sp)+,a2
FFMPFail
	move.l	#0,d0
	rts
;
; This is the patch itself.
; Note that the jump destination will get overwritten with the
; original AllocMem() entry point.
;
FFMPPatch
	and.l	#~MEMF_FAST,d1
	jmp	FFMPFail
FFMPEnd
;
; Version string.
;
	dc.b	'$VER: FakeFastMemPatch 1.0 (13.07.92)',0
;
; Some notes about MEMF_REVERSE.
;
; On WB1.2 and WB1.3 machines, MEMF_REVERSE requirements are ignored.
; On WB2.0 machines, MEMF_REVERSE will allocate at the highest
; possible address instead of the lowest possible address. The
; reccommended use for MEMF_REVERSE is for patches, resources, and
; any other stuff which remains in memory until reset. Do not use
; it for memory which will be freed. These guidelines will keep
; memory fragmentation to a minimum.
;
