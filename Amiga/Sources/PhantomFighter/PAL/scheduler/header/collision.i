;
; Structures for Collision software
;
; Written by Billy Newport
;
; Modification List :
; ===================
; 05/04/88 BN  Created It!
; 11/04/88 BN  Modified to Alert user on crashes
;

HB_txoff	equ	0
HB_tyoff	equ	2
HB_bxoff	equ	4
HB_byoff	equ	6 

COL_flink	equ	0
COL_blink	equ	4
COL_dle		equ	8
COL_function	equ	12
COL_name	equ	16

		XREF	_AllocCOL,_FreeCOL,_DSP_GoodCollisions
                XREF	_DSP_FreeCOLs
