;$VER: library.i 1.1 (5.1.1995)  Rudolf Kudla

library_State	SET	'NILL'

LIBRARY		MACRO
		IFEQ	library_State-'NILL'
		moveq	#-1,d0
		rts
.\@ROMTag	DC.W	$4afc
		DC.L	.\@ROMTag,library_End
		DC.B	$80,\2,9,0
		DC.L	.\@lib_name,.\@id_string,.\@init
.\@init		DC.L	\5,library_Func,.\@init_data,library_Init
.\@init_data	DC.W	$a008,$0900,$800a
		DC.L	.\@lib_name,$A00E0600,$90140002,$90160000
		DC.W	$8018
		DC.L	.\@id_string,0
.\@lib_name	DC.B	'\1.library',0
.\@id_string	DC.B	'$VER: \1.library \2.\3 (\4)',13,10,0
		EVEN
library_Small	SET	1
library_State	SET	'INIT'
		MEXIT
		ENDC

		IFC	\1,'FUNCTIONS'
		IFNE	library_State-'INIT'
		FAIL	'You must declare head before functions!'
		ENDC
library_Func
library_FuncNum	 SET	0
library_State	 SET	'FUNC'
		 IFNE	library_Small
		  DC.W	-1
		 ENDC
		 MEXIT
		ENDC

		IFC	\1,'Init'
library_Init
		MEXIT
		ENDC

		IFC	\1,'CODE'
		 IFNE	library_State-'FUNC'
		  FAIL	'You must declare functions before code!'
		 ENDC
		 DC.W	-1
		 IFEQ	library_Small
		  DC.W	-1
		 ENDC
library_State	 SET	'CODE'
		 MEXIT
		ENDC

		IFC	\1,'END'
		 IFNE	library_State-'CODE'
		  FAIL	'You have to insert some head and code into library.'
		 ENDC
library_End
library_State	 SET	'DONE'
		 MEXIT
		ENDC

		IFC	\1,'LARGE'
		 IFNE	library_State-'INIT'
		  FAIL	'This must be in init part!'
		 ENDC
library_Small	 SET	0
		 MEXIT
		ENDC		

		IFNC	\1,''
		 IFEQ	library_State-'FUNC'
library_FuncNum	  SET	library_FuncNum+1
		  IFND	_LVO\1
_LVO\1		   EQU	-library_FuncNum*6
		  ENDC
		  IFNE	library_Small
		   DC.W	\1-library_Func
		  ELSE
		   DC.L	\1
		  ENDC
		 LIBRARY \2,\3,\4,\5,\6,\7,\8,\9
		 ENDC
		 IFEQ	library_State-'CODE'
;		  IFND	\1
\1
;		  ENDC
		  IFND	_LVO\1
		  PRINTT 'WARNING: Function \1 is not declared public in library header.'
		  ENDC
		 ENDC
		ENDC
		ENDM

