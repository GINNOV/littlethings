;MISC macros ; Simon Knipe ; v1.0

;	MAKECALL	make call from any open library
;	LMOUSE		wait for left mouse button press
;	RMOUSE		wait for right mouse button press

************************************************************** MISC ***
;Purpose: make call from any open library
;To call: MAKECALL LibraryBase,LibraryCallOffset

MAKECALL MACRO
	move.l	\1,a6	library to use
	jsr	\2(a6)	call to make
	ENDM
************************************************************** MISC ***
;Purpose: wait for left mouse button press
;To call: LMOUSE BranchNotEqualAddress

LMOUSE MACRO
		btst		#6,$bfe001	check for lmb
		bne		\1		branch not equal
						;don`t use short branch!
 ENDM
************************************************************** MISC ***
;Purpose: wait for right mouse button press
;To call: RMOUSE BranchNotEqualAddress

RMOUSE MACRO
		btst		#2,$dff016	check for rmb
		bne		\1		branch not equal
						;don`t use short branch!
		ENDM

