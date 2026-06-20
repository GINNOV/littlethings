	IFND	ppcmacros_i
ppcmacros_i	set	1



******* ppcmacros.i/LAPC ************************************************
*
*   MACRO
*        LAPC -- Load PC-Relativ Address into Register
*
*   SYNOPSIS
*        LAPC	register,label
*
*   INPUTS
*        \1 = Destination Register
*        \2 = Symbol that gets address PC
*
*   SEE ALSO
*        PPC standard macro "la",,ppcsymbols.i
*
*******************************************************************************

LAPC		macro
	bl		LAPC\@
LAPC\@:
	mfspr		\1,lr
	addi		\1,\1,#\2-LAPC\@
	ENDM

LALPC		macro
	bl		LALPC\@
LALPC\@:
	mfspr		\1,lr
	LIL		\3,\2-LALPC\@
	add		\1,\1,\3
	ENDM


******* ppcmacros.i/LIL ************************************************
*
*   MACRO
*        LIL -- Load LongValue into Register
*
*   SYNOPSIS
*        LIL	register,value
*
*   INPUTS
*        \1 = Destination Register
*        \2 = Value
*
*   SEE ALSO
*        PPC standard macro "li",ppcsymbols.i
*
*******************************************************************************

LIL	macro
	addis		\1,0,#((\2)&$ffff0000)>>16	;= HighWord of value | Highword of value
	ori		\1,\1,#(\2)&$ffff		;= LowWord) of value
	ENDM

******* ppcmacros.i/LIW ************************************************
*
*   MACRO
*        LIW -- Load LongValue into Register
*
*   SYNOPSIS
*        LIW	register,value
*
*   INPUTS
*        \1 = Destination Register
*        \2 = Value
*
*   SEE ALSO
*        PPC standard macro "li",ppcsymbols.i
*
*******************************************************************************

LIW	macro
	IFNE	\2&$8000				;If signed Bit..then use or
	subf		\1,\1,\1			;Clear register
	ori		\1,\1,#(\2)&$ffff		;Load lowword
	ELSE
;	subf		\1,\1,\1			;Clear register
	addi		\1,0,#(\2)&$ffff		;just load it
	ENDC

	ENDM


******* ppcmacros.i/CLEAR ************************************************
*
*   MACRO
*        CLEAR -- Clear Register
*
*   SYNOPSIS
*        CLEAR	register
*
*   INPUTS
*        \1 = Destination Register
*
*******************************************************************************

CLEAR	macro
	subf		\1,\1,\1
	ENDM





	ENDC	;ppcmacros_i

