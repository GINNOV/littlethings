** MeasureContextPUP
** by Álmos Rajnai (Rachy/BiøHazard)
** on 28.12.1999
**
**  mailto: racs@fs2.bdtf.hu
**
** measurecontextpup68k.asm
** This part is the 68K core code.
** Done in assembly, for less fuss around the main cycle.
**
** See .build file for compiling!


	INCDIR	include:

	INCLUDE	exec/exec_lib.i
	INCLUDE	exec/execbase.i
	INCLUDE	exec/types.i

_LVOPPCGetMessage	EQU	-312
_LVOPPCSendMessage	EQU	-330
_LVOPPCWaitPort		EQU	-336
_LVOPPCCacheClearE	EQU	-342

	STRUCTURE PPCmessage,0
	 LONG PPCmsg_type
	 LONG PPCmsg_regD0
	 LONG PPCmsg_regD1
	 LONG PPCmsg_regA0
	 LONG PPCmsg_regA1
	LABEL PPCmessage_SIZE

	XREF	_PPCLibBase
	XREF	_PPCPort
	XREF	_M68kPort
	XREF	_ReplyPort
	XREF	_M68kMsg
	XREF	_Body

	XDEF	_timer68k


; *** D0 - number of switching

_timer68k:
	movem.l	d0-d7/a0-a6,-(sp)
.loop
	movem.l	d0,-(sp)

; We MUST empty data cache at every context switch

	movea.l	_PPCLibBase,a6
	suba.l	a0,a0
	move.l	#$ffffffff,d0
	move.l	#CACRF_ClearD,d1
	jsr	_LVOPPCCacheClearE(a6)

	movea.l	_PPCPort,a0
	movea.l _M68kMsg,a1
	movea.l _Body,a2
	move.l	#PPCmessage_SIZE,d0
	move.l	#$12345678,d1
	jsr	_LVOPPCSendMessage(a6)	
.1
	movea.l	_ReplyPort,a0
	jsr	_LVOPPCWaitPort(a6)

	movea.l	_ReplyPort,a0
	jsr	_LVOPPCGetMessage(a6)

	cmp.l	_M68kMsg,d0
	bne.b	.1

	movem.l	(sp)+,d0
	dbf	d0,.loop

	movem.l	(sp)+,d0-d7/a0-a6

	rts

