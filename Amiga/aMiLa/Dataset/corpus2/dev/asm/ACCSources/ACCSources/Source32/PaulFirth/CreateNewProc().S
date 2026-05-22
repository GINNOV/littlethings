; Demo to test CreateNewProc()
;

		incdir		sys:include2.0/
		include		exec/exec_lib.i
		include		dos/dos_lib.i
		include		dos/dostags.i
;		include		hardware/debtones.i
		include		clarityov_macros.i


OPEN_DOS
		lea		DOS_NAME,a1
		moveq.l		#39,d0
		CALLLEXEC	OpenLibrary
		tst.l		d0
		beq		EXIT
		move.l		d0,DOS_BASE

NORMAL_BEEP	
		DEBTONE		400
		
CREATE_PROCESS
		lea		PROCESS_TAGS,a1			;why on earth they want the tag address
		move.l		a1,d1				;in d1 I dont know!
		CALLLDOS		CreateNewProc
		
.LOOP
		cmpi.l		#1,TEST
		bne.s		.LOOP
		
CLOSE_DOWN
		move.l		DOS_BASE,a1
		CALLLEXEC	CloseLibrary
		
EXIT		
		clr.l		d0
		rts				
;----------------------------------------------------------------------------
PROCESS_TAGS	dc.l		NP_Entry,NEW_PROCESS
		dc.l		TAG_DONE
		
TEST		dc.l		0

DOS_BASE	ds.l		1
DOS_NAME	dc.b		'dos.library',0
		cnop		0,4
;----------------------------------------------------------------------------							
NEW_PROCESS
		DEBTONE		1200
		move.l		#1,TEST
		rts