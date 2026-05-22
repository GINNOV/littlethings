; OpenWindowTagList()
;
; loadsa examples!

		incdir		sys:include2.0/
		include		exec/exec_lib.i
		include		intuition/intuition_lib.i
		include		intuition/intuition.i
		include		clarityov_macros.i


NULL		EQU		0
		

OPEN_INTUITION
		lea		INTUITION_NAME,a1		;library name in a1
		moveq.l		#36,d0				;library version in d0
		CALLLEXEC	OpenLibrary			;open library
		tst.l		d0
		beq		EXIT				;quit if cant
		move.l		d0,INTUITION_BASE		;get base addres
;----------------------------------------------------------------------------		
OPEN_WINDOW
		move.l		#NULL,a0			;new window structure which we dont need
		lea		MY_WINDOW,a1			;my new window taglist down at the bottom
		CALLLINT		OpenWindowTagList		;open us a window
		tst.l		d0				;see if we could open a window
		beq		CLOSE_INTUITION			;if not close intuition and exit
		move.l		d0,MY_WIN_POINTER		;save the address of out window
;----------------------------------------------------------------------------
HANDLE_MESSAGES
		move.l		MY_WIN_POINTER,a0		;get our windows address back
		move.l		wd_UserPort(a0),a2		;find the userport of our window so we can waitport()

WAIT_PORT
		move.l		a2,a0				;port address of our window goes from a2 to a0 
		CALLLEXEC	WaitPort			;go to sleep until we are woken
		
GET_MESSAGE
		move.l		a2,a0				;get our windows userport again!
		CALLLEXEC	GetMsg				;get the message
		tst.l		d0				;test to see if there is one
		beq.s		WAIT_PORT			;if not wait again
		move.l		d0,a1				;put the message address in a1

ACT_ON_MESSAGE
		cmpi.l		#CLOSEWINDOW,im_Class(a1)	;see if our message is a closewindow one
		beq		CLOSE_WINDOW_2			;if it was then close
		
REPLY_MESSAGE
		CALLLEXEC	ReplyMsg			;reply to exec
		bra.s		GET_MESSAGE			;check for more messages
;----------------------------------------------------------------------------
CLOSE_WINDOW_2
		CALLLEXEC	ReplyMsg			;we have to reply to exec every time we get one

CLOSE_WINDOW
		move.l		MY_WIN_POINTER,a0		;the address of our window in a0
		CALLLINT		CloseWindow			;get intuition to close it
		
CLOSE_INTUITION
		move.l		INTUITION_BASE,a1		;address of intuition in a1
		CALLLEXEC	CloseLibrary			;close the library
		
EXIT		
		clr.l		d0				;clr d0 so no error return code
		rts						;and exit!!!						
;----------------------------------------------------------------------------				
INTUITION_BASE	ds.l		1

MY_WIN_POINTER	ds.l		1

SINGLE_TAG	dc.l		TAG_DONE

MY_WINDOW	dc.l		WA_Left,0
		dc.l		WA_Top,0
		dc.l		WA_Width,160
		dc.l		WA_Height,50
		dc.l		WA_IDCMP,IDCMP_CLOSEWINDOW
		dc.l		WA_Flags,WFLG_CLOSEGADGET!WFLG_DRAGBAR!WFLG_DEPTHGADGET
		dc.l		WA_Title,WINDOW_TITLE
		dc.l		TAG_DONE
		
WINDOW_TITLE	dc.b		'Window',0
		cnop		0,4

INTUITION_NAME	dc.b		'intuition.library',0
