; ===================================================================
;
;                             SINE.soslibrary
;   
;                          Sinuslistengenerator
;
;                                 V 1.0
;
;
;                             include-datei
;
; ===================================================================

; Library Offsets

_GenSinusTags	equ	-12

; ===================================================================
;
;  Tags
;
; ===================================================================

		rsreset
ST_Pad1		rs.l	1
ST_ADRESS	rs.l	1
ST_FORMAT	rs.l	1
ST_RANGEPOT	rs.l	1
ST_SIZEPOT	rs.l	1
ST_QUARTERS	rs.l	1
ST_START		rs.l	1
ST_LAST		rs.w	0

; ===================================================================
;
;  SINEBase
;
; ===================================================================

		rsreset
SINEB_Library	rs.b	LIB_SIZEOF
SINEB_Tags	rs.b	ST_LAST
SINEB_SIZEOF	rs.w	0

; ===================================================================
;
;  Format-Defines
;
; ===================================================================

SINE_WORD	equ	1
SINE_BYTE	equ	2

