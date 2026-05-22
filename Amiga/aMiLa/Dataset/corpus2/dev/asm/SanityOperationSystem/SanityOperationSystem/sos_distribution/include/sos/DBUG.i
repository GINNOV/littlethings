; ===================================================================
;
;                             DBUG.soslibrary
;   
;                           Debugging Functions
;
;                                 V 1.3
;
;
;                             include-datei
;
; ===================================================================

; Library Offsets

_SetPSS		equ	-30
_StripColor0	equ	-24
_LoadDebugger	equ	-18
_CheckDBUG	equ	-12


; ===================================================================
;
;  Processor Save Structure
;
; ===================================================================

		rsreset
PSS_Data		rs.l	8	; 8 Datenregister
PSS_Adress	rs.l	7	; 7 Adressregister
PSS_USP		rs.l	1	; User Stack Pointer (USP)

PSS_ISP		rs.l	1	; Supervisor Stack Pointer 1 (SSP/ISP)
PSS_MSP		rs.l	1	; Supervisor Stack Pointer 2 (SSP/MSP)
PSS_PC		rs.l	1	; Programm Counter
PSS_ACCESS	rs.l	1	; Zugriffsadresse bei Bus/Adressfehler
PSS_SR		rs.w	1	; Status Register
PSS_ER		rs.w	1	; Error Register (Bus/Adressfehler)
PSS_SIZEOF	rs.w	0


