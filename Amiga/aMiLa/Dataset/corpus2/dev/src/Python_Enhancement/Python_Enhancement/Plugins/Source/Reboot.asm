;
;                The COMMODORE approved 'Reboot' routine.
;                ----------------------------------------
;
;              Assembled using a68k, and linked using blink.
;
_ColdReboot:				;Calling from 'CLI'.
	move.l	4,a6			;Pointer to ExecBase.
	lea.l	MagicResetCode(pc),a5	;Location of code to trap.
	jsr	-30(a6)			;_LVOSupervisor mode, do it.
					;
	cnop	0,4			;This is IMPORTANT, longword aligned.
MagicResetCode:				;
	lea.l	2,a0			;Point to JMP instruction in ROM.
	RESET				;Obvious!!!
	jmp	(a0)			;Rely on prefetch to execute this code.
					;
	cnop	0,4			;Same as above.
	END				;Obvious!!!
