;*********************************************************
;* Header file for interrupt driven blitter routines
;********************************************************/

MAXBLITS 	equ	128

BPLNE_apt	equ	0
BPLNE_bpt	equ	4
BPLNE_cpt	equ	8
BPLNE_dpt	equ	12
BPLNE_SIZE	equ	16

BOBJ_con0	equ	0
BOBJ_con1	equ	2
BOBJ_bmod	equ	4
BOBJ_amod	equ	6
BOBJ_cmod	equ	8
BOBJ_dmod	equ	10
BOBJ_afwm	equ	12
BOBJ_alwm	equ	14
BOBJ_ptr	equ	16
BOBJ_bltsize	equ	16+BPLNE_SIZE
BOBJ_SIZE	equ	16+BPLNE_SIZE+4


		XREF	_BLT_ObjectList
		XREF	_BLTListRead,_BLTListWrite
