*****************************************************************************
* Devpac Compatible Implementation of FUNCDEF macro
* Required by exec/exec_lib.i
* 2024 www.youtube.com/@Davepoo2					    			    *					    			    *
*****************************************************************************
	include 	exec/libraries.i
	
FUNCDEF	MACRO
_LVO\1		=	FUNC_CNT
FUNC_CNT 	SET 	FUNC_CNT-LIB_VECTSIZE
	ENDM

FUNC_CNT	SET	LIB_USERDEF
