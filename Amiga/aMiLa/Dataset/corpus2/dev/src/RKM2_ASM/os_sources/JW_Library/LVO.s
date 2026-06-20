
 *
 * LVO Maker - Insert your own function's _LVOFunctionName for each of
 * your functions.
 *
 * Simply compile this program, as Linkable, to make an object (.o or .obj)
 * file and then JOIN it with Stubs.o
 *

	INCDIR	WORK:Include/

	INCLUDE	ram:system.gs

	SECTION	data

	LIBINIT

	LIBDEF	_LVODouble
	XDEF	_LVODouble
	
	LIBDEF	_LVOAddThese
	XDEF	_LVOAddThese
	
	END