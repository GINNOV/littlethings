; ---------------------------------------------------------------------

; Example CH14-1.s 

; ---------------------------------------------------------------------	
		include intuition/intuition.i
		include exec/exec_lib.i
		include intuition/intuition_lib.i


		XDEF	_main
		
		
NULL			EQU	   0

TRUE			EQU	   1

_AbsExecBase		EQU	   4

; ---------------------------------------------------------------------

CALLSYS		MACRO
		LINKLIB	_LVO\1,\2
		ENDM

; ---------------------------------------------------------------------

_main		movem.l  d3/a2-a3/a5,-(sp)      preserve registers

		move.l	_AbsExecBase,_SysBase	copy of exec library base
		lea	function_stack,a5	for alloc/dealloc operations
		lea 	lib_names,a2
		lea 	lib_base_start,a3
		move.w	#LIBRARY_COUNT-1,d3	loop counter
.loop		movea.l	(a2)+,a1		library name pointer
		moveq	#0,d0			any version will do
		CALLSYS	OpenLibrary,_SysBase
		move.l	d0,(a3)+		store returned base
		dbeq	d3,.loop

		beq.s	lib_error_exit				
		
		; all libraries are open and available for use.
						
		jsr	LockScreen
		beq.s	closedown
		
		jsr	OpenWindow
		beq.s	closedown

		; now everything is set up we call the event handler!

		movea.l window_p,a1
		movea.l wd_UserPort(a1),a2	user port address
		jsr	WaitForExitMessage	handle user actions

closedown	move.l	(a5)+,d0		retrieve function pointer
		beq.s	lib_normal_exit
		move.l	d0,a0
		jsr	(a0)			and execute routine if it exists!
		bra.s	closedown


lib_normal_exit	lea	lib_base_end,a3		
		moveq	#LIBRARY_COUNT,d2	library count
		jsr	CloseLibs		close libraries
		moveq	#0,d0			clear d0 for O/S
		movem.l  (sp)+,d3/a2-a3/a5      restore registers
		rts				and terminate program

lib_error_exit	moveq	#LIBRARY_COUNT-1,d2		
		sub	d3,d2
		jsr	CloseLibs		close libraries
		moveq	#0,d0			clear d0 for O/S
		movem.l  (sp)+,d3/a2-a3/a5      restore registers
		rts				and terminate program

; ---------------------------------------------------------------------		

; CloseLibs() On entry...

; 	a3 should hold address of the longword location just past 
; 	   that of the first library to close (this is because the 
;	   routine uses a backward reading loop).

; 	d2 should hold count of the number of libraries to close	

CloseLibs	tst.b	d2			test counter
		beq.s	.loop_end		
		movea.l	-(a3),a1		get library base
		CALLSYS	CloseLibrary,_SysBase
		subq.b	#1,d2
		bra.s	CloseLibs
.loop_end	rts

; ---------------------------------------------------------------------					

; LockScreen() and UnlkScreen() on entry... need no register parameters!


LockScreen	lea	workbench_name,a0	pointer to screen name
		CALLSYS	LockPubScreen,_IntuitionBase
		move.l	d0,workbench_p		save returned pointer
		beq.s	.error
		move.l	#UnlkScreen,-(a5)	push deallocation routine address
.error		rts

UnlkScreen	movea.w	#NULL,a0		screen name not needed
		movea.l	workbench_p,a1		screen to unlock
		CALLSYS	UnlockPubScreen,_IntuitionBase
		rts

; ---------------------------------------------------------------------					

; OpenWindow() and ShutWindow() on entry... need no register parameters!


OpenWindow	movea.w	#NULL,a0
		lea	window_tags,a1		start of tag list
		CALLSYS	OpenWindowTagList,_IntuitionBase
		move.l	d0,window_p		save returned pointer
		beq.s	.error
		move.l	#ShutWindow,-(a5)	push deallocation routine address
.error		rts

ShutWindow	movea.l	window_p,a0		window to close
		CALLSYS	CloseWindow,_IntuitionBase
		rts


; ---------------------------------------------------------------------	


; Function name:     WaitForExitMessage()


; Purpose:           Wait until user hits window's close gadget


; Input Parameters:  Address of IDCMP user-port should be in a2. 


; Output parameters: None


; Register Usage:    a0: Used by WaitPort() and GetMsg()  
                     
;                    a1: Used by ReplyMsg()
                     
;                    a2: Holds user-port address

;                    d0: Used by WaitPort() and GetMsg()
                     
;                    d1: Unused but possibly altered by system functions

;                    d2: Used as an exit flag (quit when non-zero)


; Other Notes:       All registers are preserved

; ---------------------------------------------------------------------

WaitForExitMessage   movem.l  d0-d2/a0-a2,-(sp)    preserve registers

                     clr.l    d2                   clear exit flag

WaitForExitMessage2  move.l   a2,a0                port address
  
                     CALLSYS  WaitPort,_SysBase  

                     jsr      GetMessage           

                     cmpi.l   #TRUE,d2             exit flag set?

                     bne.s    WaitForExitMessage2

                     movem.l  (sp)+,d0-d2/a0-a2    restore registers

                     rts                           logical end of routine

; ---------------------------------------------------------------------
                     
GetMessage           move.l   a2,a0                get port address in a0

                     CALLSYS  GetMsg,_SysBase      get the message

                     tst.l    d0

                     beq.s    GetMessageExit       did it exist?

                     move.l   d0,a1                copy pointer to a1

                     cmpi.l   #IDCMP_CLOSEWINDOW,im_Class(a1) 

                     bne.s    GetMessage1          

                     moveq   #TRUE,d2             user hit close gadget 

                     
GetMessage1          CALLSYS  ReplyMsg,_SysBase

                     bra.s    GetMessage           check for more messages

GetMessageExit       rts                           d2 holds exit flag
                     
; ---------------------------------------------------------------------



LIBRARY_COUNT	EQU  	1

lib_base_start
_IntuitionBase	ds.l 	1
lib_base_end					;end of library base variables

_SysBase	ds.l	1
window_p	ds.l 	1

stack_space	ds.l	2			space set as required
function_stack	dc.l	NULL			top of function stack

window_tags	dc.l	WA_PubScreen
workbench_p	ds.l	1
		dc.l	WA_Left,50
		dc.l	WA_Top,50
		dc.l	WA_Width,340
		dc.l	WA_Height,100
		dc.l	WA_DragBar,TRUE
		dc.l	WA_DepthGadget,TRUE
		dc.l	WA_CloseGadget,TRUE
		dc.l	WA_SizeGadget,TRUE
		dc.l	WA_MinWidth,100
		dc.l	WA_MinHeight,50
		dc.l	WA_MaxWidth,640
		dc.l	WA_MaxHeight,256
		dc.l	WA_IDCMP,IDCMP_CLOSEWINDOW
		dc.l	WA_Title,window_name
		dc.l	TAG_DONE,NULL

	
lib_names	dc.l lib1
lib1		dc.b 'intuition.library',NULL

workbench_name	dc.b 'Workbench',NULL

window_name	dc.b 'Example CH14-1',NULL

		END

; ---------------------------------------------------------------------


		