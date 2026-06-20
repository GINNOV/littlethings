	rsreset
MP_COls	rs.l	1
MP_Starts	rs.w	8
MP_Bonus	rs.w	8
MP_Modsig	rs.w	4
MP_Level	rs.w	20*16
MP_len	rs.w	1
EZLEV	MACRO
	dc.l	lw.map1cols
	incbin	Source:P.Kent/tankslevels/\1.levpak
	endm
	
;List of ptrs to maps & colmaps+pl1,2 start pos
lp.MapList
	EZLEV	00
	EZLEV	01
	EZLEV	02
	EZLEV	03
	EZLEV	04

; Get the September 1992 AmigaComputing version for the rest of the levels
; :-) (or write to me!)

;	EZLEV	05
;	EZLEV	06
;	EZLEV	07
;	EZLEV	08
;	EZLEV	09
;	EZLEV	10
;	EZLEV	11
;	EZLEV	12
;	EZLEV	13
;	EZLEV	14
;	EZLEV	15
;	EZLEV	16
;	EZLEV	17
;	EZLEV	18
;	EZLEV	19
;	EZLEV	20
;	EZLEV	21
;	EZLEV	22
;	EZLEV	23
;	EZLEV	24
	dc.l	0			; List terminated
