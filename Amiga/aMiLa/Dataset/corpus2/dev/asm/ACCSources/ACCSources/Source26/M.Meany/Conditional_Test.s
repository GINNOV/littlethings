
; This program demonstrates use of conditional assembly to include only
;required subroutines.

; First the macros that are available. Not all are used in following code.
;When a macro is used it sets a switch that causes appropriate subroutine
;to be included.

STRCPY		macro		src,dest

		IFND		STRSUB_COPY
STRSUB_COPY	SET		1
		ENDC

		move.l		\1,a0
		move.l		\2,a1
		bsr		MVM_StrCpy
		
		endm
		

STRLEN		macro		string,[reg]

		IFND		STRSUB_LENGTH
STRSUB_LENGTH	SET		1
		ENDC
		
		IFNC		'','\2'
		move.l		d0,-(sp)
		ENDC
		
		move.l		\1,a0
		bsr		MVM_StrLen

		IFNC		'','\2'
		move.l		d0,\2
		move.l		(sp)+,d0
		ENDC
		
		endm

; The code itself. Uses only two of three available subroutines. You will
;have to use Monam to see the results!

Start		STRCPY		#string1,#string2

		moveq.l		#15,d0

		STRLEN		#string2,d2
		
		rts

string1		dc.b		'M.Meany',0
		even
string2		dc.b		'            ',0
		even


; Following subroutine will be included since STRCPY routine has been used!

		IFD		STRSUB_COPY
MVM_StrCpy	move.b		(a0)+,(a1)+
		bne.s		MVM_StrCpy
		rts
		ENDC

; Following subroutine will be included since STRLEN routine has been used!

		IFD		STRSUB_LENGTH
MVM_StrLen	moveq.l		#-1,d0

.loop		addq.l		#1,d0
		tst.b		(a0)+
		bne.s		.loop
		rts
		ENDC

; Following routine will be omitted since STRSUB_COMPARE has not been SET!

		IFD		STRSUB_COMPARE
MVM_StrCmp	moveq.l		#0,d0
		rts
		ENDC
	
