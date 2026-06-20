;Easy request demo
;


		incdir		sys:include2.0/
		include		exec/exec.i
		include		exec/exec_lib.i
		include		intuition/intuition.i
		include		intuition/intuition_lib.i
		include		clarityov_macros.i


			
NULL		EQU		0	
	
;----------------------------------------------------------------------------
MAIN
		lea		INTUITION_NAME,a1
		moveq.l		#0,d0
		CALLLEXEC	OpenLibrary
		move.l		d0,INTUITION_BASE
		beq		EXIT
		
REQUESTER
		move.l		#NULL,a0
		move.l		#NULL,a2
		
		move.l		#NULL,a3
		lea		ER_EASY_STRUCT,a1
		
		CALLLINT		EasyRequestArgs

THATS_ALL
		move.l		INTUITION_BASE,a1
		CALLLEXEC	CloseLibrary
		
EXIT
		rts
;----------------------------------------------------------------------------		
INTUITION_NAME	dc.b		'intuition.library',0
		cnop		0,4
INTUITION_BASE	ds.l		1

ER_EASY_STRUCT	dc.l		es_SIZEOF
		dc.l		0
		dc.l		ER_TITLE
		dc.l		ER_BODY
		dc.l		ER_GADGETS
		
ER_TITLE	dc.b		'Nice EasyRequest',0
ER_BODY		dc.b		'What a nice program',0
ER_GADGETS	dc.b		'Ok',0							