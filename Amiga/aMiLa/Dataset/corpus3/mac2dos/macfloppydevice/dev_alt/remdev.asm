*************************************************
*						*
*	Utility to Remove a Device		*
*						*
*************************************************

	INCLUDE "VD0:MACROS.ASM"

	XREF	_AbsExecBase

DeviceList	EQU	$15E

	MOVE.L	_AbsExecBase,A6
	CALLSYS	Forbid
	MOVE.L	DeviceList(A6),A0	;scan device list
	LEA	DevName,A1
	CALLSYS	FindName
	TST.L	D0			;got it?
	BEQ.S	9$			;no
	MOVE.L	D0,A1
	CALLSYS	RemDevice		;try to get the device to expunge
9$:	CALLSYS	Permit
	RTS				;back to DOS


DevName	DC.B	'macfloppy.device',0


	END
