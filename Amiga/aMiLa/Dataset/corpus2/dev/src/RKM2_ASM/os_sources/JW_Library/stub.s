
 *
 * Stubs - Insert your own function's _LVOFunctionName for each of
 * your functions.
 *
 * Simply compile this program, as Linkable, to make an object (.o or .obj)
 * file and then JOIN it with LVO_Maker.o
 *

	INCDIR	WORK:Include/

	INCLUDE	ram:system.gs

	SECTION	code

	XREF	_JwBase

	XREF	_LVODouble
	XREF	_LVOAddThese

	XDEF	_Double
	XDEF	_AddThese

_Double:
	MOVE.L	A6,-(SP)
	MOVE.L	8(SP),D0
	MOVE.L	_JwBase,A6
	JSR	_LVODouble(A6)
	MOVE.L	(SP)+,A6
	RTS

_AddThese:
	MOVE.L	A6,-(SP)
	MOVEM.L	8(SP),D0/D1
	MOVE.L	_JwBase,A6
	JSR	_LVOAddThese(A6)
	MOVE.L	(SP)+,A6
	RTS


	END