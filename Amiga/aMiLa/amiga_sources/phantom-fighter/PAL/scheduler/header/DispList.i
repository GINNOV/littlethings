;  
;   Structures for Display List software
;  
;   Written by Billy Newport
;  
;   Modification List :
;   ===================
;   05/04/88 BN  Created It!
;   11/04/88 BN  Modified to Alert user on crashes
;

DLE_flink	equ	0
DLE_blink	equ	4
DLE_col		equ	8
DLE_hitbox	equ	12
DLE_hitboxtx	equ	12
DLE_hitboxty	equ	14
DLE_hitboxbx	equ	16
DLE_hitboxby	equ	18
DLE_param	equ	20
DLE_flags	equ	24

DLE_Fdocollision	equ	 1
DLE_Falienparam	equ	  2
DLE_Fourship	equ	     4
DLE_Fcollision	equ		8
DLE_Ftoken	equ		16
DLE_Fturret	equ		32
DLE_Fbullet	equ		64
DLE_Fsatellite	equ		128
DLE_FBigGuy	equ		256

DLE_Fmask	equ	$2000000
DLE_Fdeadly	equ	$4000000
DLE_Fpending	equ	$8000000

DLE_oldx	equ	28
DLE_oldy	equ	30
DLE_oldclass	equ	32
DLE_oldimage	equ	34
DLE_newx	equ	38
DLE_newy	equ	40
DLE_newclass	equ	42
DLE_newimage	equ	44
DLE_maskoffset	equ	48
DLE_name	equ	52


		XREF	_AllocDLE,_FreeDLE,_DSP_DisplayList
                XREF	_DSP_FreeDLEs

CopyDownDLE	Macro
		lea.l	DLE_newx(a0),a1
                lea.l	DLE_oldx(a0),a0
		move.l	(a1)+,(a0)+	;X
                move.w	(a1)+,(a0)+	;Class
                move.l	(a1)+,(a0)+	;Image
		Endm

