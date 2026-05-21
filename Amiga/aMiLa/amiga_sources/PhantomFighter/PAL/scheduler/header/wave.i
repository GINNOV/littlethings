;/*
; * Wave data structures 
; *
; * Designed and coded by Billy Newport Apr 88
; *
; */

ANM_count	equ	0
ANM_frameno	equ	1
ANM_xoffset	equ	2
ANM_yoffset	equ	4
ANM_SIZE	equ	6


WBLK_flink	equ	0
WBLK_blink	equ	4
WBLK_pattern	equ	8
WBLK_flags	equ	12
WBLK_image	equ	16
WBLK_sizewave	equ	20
WBLK_aliensdead	equ	21
WBLK_count	equ	22
WBLK_numhitstokill equ	24
WBLK_score	equ	26

WPRM_flink	equ	0
WPRM_blink	equ	4
WPRM_curanim	equ	8
WPRM_count	equ	12
WPRM_class	equ	13
WPRM_framelist	equ	14
WPRM_dle	equ	18
WPRM_eqe	equ	22
WPRM_wve	equ	26
WPRM_numhitsleft equ	30

