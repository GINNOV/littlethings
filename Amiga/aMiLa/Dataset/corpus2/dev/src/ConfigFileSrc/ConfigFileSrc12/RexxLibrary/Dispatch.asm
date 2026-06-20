*
*  $PROJECT: RexxConfigFile.library
*  $FILE: Dispatch.h
*  $DESCRIPTION: Func entry for the ARexx interface.
*
*  (C) Copyright 1997 Marcel Karas
*      All Rights Reserved.
*

	XREF	_RexxDispatch
	XDEF	_AsmRexxDispatch

	SECTION	text,CODE

*---------------------------------------------------------------------------

_AsmRexxDispatch:

	SUBQ.L	#4,SP
	MOVE.L	SP,-(SP)
	MOVE.L	A0,-(SP)
	BSR.W		_RexxDispatch
	ADDQ.L	#8,SP
	MOVEA.L	(SP)+,A0
	RTS

*---------------------------------------------------------------------------

	END
