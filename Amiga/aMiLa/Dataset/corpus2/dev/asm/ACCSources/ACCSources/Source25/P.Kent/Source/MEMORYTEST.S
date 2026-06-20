	OPT	C-,O+,D+
******************************************************************************
*
* WORKING TITLE: MEMORY MANAGEMENT ROUTINES TEST
*        AUTHOR: PAUL KENT
*      COMPILER: DEVPAC3
*        MEMORY: AS PER VARIABLES!!! ( OR SYSTEM IN FINAL VERSION...)
*   DIARY/NOTES:
*  13/06/92 : First revision.
*
******************************************************************************

SYSTEM	; DEFINE THIS SO THAT DMA ETC. NOT KILLED BY HWSTART
		; HWSTART IS USED ONLY FOR THE ERROR DISPLAYER CODE + STACK RECOVERY
	INCLUDE source:INCLUDE/HARDWARE.I
	INCLUDE source:P.Kent/INCLUDES/MYMACROS.I
	INCLUDE	source:P.Kent/INCLUDES/COMBISTART.S
	INCLUDE	source:P.Kent/INCLUDES/HWSTART.S
;Memory alloc routines...
	INCLUDE	source:P.Kent/INCLUDES/MEMORYMNGR.S

;AMOUNT OF K TO SIMULATE...
SLOWK = 256
FASTK = 16
CHIPK = 256
_BOOT
	LEA	MEMINFO(PC),A1
	BSR	Minitialise

;(1)OVERLOAD THE CHIP MEMORY
;	MOVE.L	#1000*CHIPK,D1
;	BSR AllocChip
;	MOVE.L D1,A1
;	MOVE.L	#25*CHIPK,D1			; This will fail!
;	BSR AllocChip

;(2)OVERLOAD THE PUBLIC RAM
;	MOVE.L	#FASTK*1024,D1			; Should allocate slow...
;	BSR	AllocPublic
;	MOVE.L	#SLOWK*1000,D1			; This will allocate chip...
;	BSR AllocPublic
;	MOVE.L	#CHIPK*1024,D1			; This will fail!
;	BSR AllocPublic

;(3)NORMAL (DE)ALLOCATE...
;	MOVE.L #$1000,D1
;	BSR AllocPublic
; D0 = PTR
;	BSR FreeMem
	
;(4)SCRAMBLE CHIP MEMORY BLOCK...
	CLR.L CHIPLIST
	MOVE.L #$6666,D1				; Hehehehe...
	BSR	AllocChip

	RTS

MEMINFO DC.L 'RAMC',CHIPLIST,$400*CHIPK	;Chip ram : must be 1st in list!
		DC.L 'RAMS',SLOWLIST,$400*SLOWK	;Slow fast ram
		DC.L 'RAMF',FASTLIST,$400*FASTK	;True fast ram...
		DC.L 0

;Simulate CHIP ram...
	SECTION MEM,BSS_C
CHIPLIST	DS.B $400*ChipK
;Simulate 'slow' FAST ram $c00000+ (trapdoor)
	SECTION MOREMEM,BSS
SLOWLIST	DS.B $400*SlowK
;Simulate $200000+ ram (autoconfig etc)
	SECTION	AUTOMEM,BSS
FASTLIST	DS.B $400*FastK
