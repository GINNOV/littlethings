	opt o+
;***********************************************************
;       
;      Program to test printf routine with Ordinary Windows
;	 
;	 Created 2/7/90 by S.Marshall for NewsFlash U.K
;     	
;	           Compiles with Devpac V2
;	
;***********************************************************

	INCDIR	 	"SYS:INCLUDE/"
	INCLUDE 	Intuition/Intuition.i
	INCLUDE 	Intuition/Intuition_lib.i
	INCLUDE		Graphics/Graphics_lib.i
	INCLUDE		Graphics/rastport.i
 	INCLUDE 	libraries/dos_lib.i
 	INCLUDE 	libraries/dos.i
 	INCLUDE 	Exec/Exec_lib.i

		
NULL	EQU	0

;*****************************************

CALLSYS    MACRO
	IFGT	NARG-1         
	FAIL	!!!           
	ENDC                 
	JSR	_LVO\1(A6)
	ENDM
		
;*****************************************

	moveq		#0,d0			;clear d0 (any lib version)
  	lea		DOSname(pc),a1		;lib name in a1
  	CALLEXEC	OpenLibrary		;try to open library
  	move.l		d0,_DOSBase		;store lib base
  	beq		Error			;cleanup and quit if fail

  	moveq		#0,d0			;clear d0 (any lib version)
  	lea		Grafname(pc),a1		;lib name in a1
  	CALLEXEC	OpenLibrary		;try to open library
  	move.l		d0,_GfxBase		;store lib base
  	beq		GfxError		;cleanup and quit if fail
  	
  	moveq		#0,d0			;clear d0 (any lib version)
  	lea		Intname(pc),a1		;lib name in a1
  	CALLSYS		OpenLibrary		;try to open library
  	move.l		d0,_IntuitionBase	;store lib base
  	beq.s		IntError		;cleanup and quit if fail
  	
  	lea 		MyNewWindow,a0		;newwindow struct in a0
  	CALLINT		OpenWindow		;open window
  	move.l 		d0,WindowPtr		;store window struct address
  	beq.s 		WdwError		;branch if openwindow failed
  	
  	move.w		#100,-(sp)		;store number 1000 on stack
  	move.l 		d0,a2			;window pointer in a2
  	move.l		wd_RPort(a2),a1		;rastport address in a1
  	moveq		#5,d0			;initial text x pos
  	moveq		#20,d1			;initial text y pos
  	CALLGRAF	Move			;set text position
  	move.l		wd_RPort(a2),a1		;rastport address in a1
  	moveq		#$01,d0			;set d0 to 1 (pen colour)
  	CALLSYS		SetAPen			;set pen colour to 1 (white)
  	
Loop:
;------ a2 already holds window pointer
 
	lea		String(pc),a0		;string address in a0
	move.l		sp,a1			;data stream address in a1
	bsr.s		printf			;do formatted print
	subq.w		#1,(sp)			;decrement counter
	bpl.s		Loop			;loop until negative
	
	addq.l		#2,sp			;pop number from stack 
	
	moveq		#50,d1			;set 1 second delay
	CALLDOS		Delay			;and wait

;------ remove menu and close window
KillWindow:
  	move.l 		WindowPtr,a0		;window in a0
  	CALLINT 	CloseWindow		;close the window
  	
WdwError:  
  	move.l 		_IntuitionBase,a1	;intuition lib base in a1
  	CALLEXEC 	CloseLibrary		;close intuition

IntError
	move.l 		_GfxBase,a1		;graphics lib base in a1
  	CALLEXEC 	CloseLibrary		;close graphics
  	
GfxError
	move.l		_DOSBase,a1		;dos lib base in a1
	CALLEXEC	CloseLibrary		;close dos
  	
Error
	rts					;quit

;***********************************************************
;	This is the printfat  routine
;***********************************************************
;	Called with     printfat(String,args,Window,XPos,YPos)
;                                  a0    a1    a2    d0   d1
printfat:
	movem.l		a0-a2/a6,-(sp)		;save regs
  	move.l		wd_RPort(a2),a1		;rastport address in a1
	CALLGRAF	Move			;set text position
	movem.l		(sp)+,a0-a2/a6		;restore regs
	bsr.s		printf			;print string
	rts					;and quit
	
;***********************************************************
;	This is the printf routine
;***********************************************************
;	Called with     printf(String,args,Window)
;                                a0    a1    a2

printf:
	movem.l		a2/a6,-(sp)		;save regs a2 and a6
	move.l		a2,a3			;window in a3
	lea		PutChar(pc),a2		;address of output routine
	CALLEXEC	RawDoFmt		;format and print string
	movem.l		(sp)+,a2/a6		;restore a2 and a6
	rts					;and quit
	
printfBuffer:
	dc.w		0			;temp buffer

PutChar:
	move.l		a6,-(sp)		;save reg a6
	tst.b		d0			;check character
	beq.s		LastChar		;branch if null
	lea		printfBuffer(pc),a0	;buffer address in a0
	cmpi.b		#'\',(a0)		;was previous char a \
	beq.s		Escape			;yes branch to escape routine
	
	move.b		d0,(a0)			;move character to buffer
	cmpi.b		#'\',d0			;is it a \
	beq.s		LastChar		;if yes skip print routine

NotSupported:
	moveq		#1,d0			;number of chars = 1
	move.l		wd_RPort(a3),a1		;rastport address in a1
	CALLGRAF	Text			;write text
	
LastChar
	move.l		(sp)+,a6		;restore a6
	rts
	
;===========================================================
Escape:
	cmpi.b		#'n',d0			;is it a newline
	beq.s		Newline			;if yes do it
	
	cmpi.b		#'c',d0			;is it a carraige return
	beq.s		CReturn			;if yes do it
	
	move.b		d0,(a0)			;store char in buffer
	bra.s		NotSupported		;branch back and print it
	
;===========================================================
Newline:
	move.l		d7,-(sp)		;save reg d7
	moveq		#5,d0			;set text x pos
	move.w		wd_Height(a3),d7	;window height in d7
	subq.w		#5,d7			;allow for border
	move.l		wd_RPort(a3),a1		;rastport address in a1
	moveq		#0,d1			;clear d1
	move.w		rp_cp_y(a1),d1		;get current text y pos
	add.w		rp_TxHeight(a1),d1	;get font height
	cmp.w		d1,d7			;are we past window bottom
	bls.s		Scroll			;if yes then scroll window up

ScrollDone:	
	CALLGRAF	Move			;set text position
	move.l		(sp)+,d7		;restore d7 
	bra.s		LastChar		;branch back -don't print 'n'
	
;===========================================================
;------ Note when this routine is called a1 already holds rastport address 
Scroll:
	movem.l		a1/d0-d5,-(sp)		;save regs
	moveq		#0,d0			;no x direction scroll
	move.w		rp_TxHeight(a1),d1	;font size in d1
	moveq		#5,d2			;x start position
	moveq		#10,d3			;y pos (allow for title bar)
	move.w		wd_Width(a3),d4		;get window width
	sub.w		#17,d4			;subtract sizing gadget
	move.l		d7,d5			;window height in d5
	addq.w		#3,d5			;add a little for descenders
	
	CALLGRAF	ScrollRaster		;scroll the window up
	movem.l		(sp)+,a1/d0-d5		;restore regs
	move.l		d7,d1			;reset text position
	bra.s		ScrollDone		;branch back 
	
;===========================================================
CReturn:
	moveq		#5,d0			;set x pos
	moveq		#0,d1			;clear d1
	move.l		wd_RPort(a3),a1		;rastport address in a1
	move.w		rp_cp_y(a1),d1		;get current text y pos
	CALLGRAF	Move			;set text position
	bra		LastChar		;branch back
	

;***********************************************************
;	End of printf routine
;***********************************************************

;------	Strings,Lib names  etc.	
	
DOSname
	DOSNAME			;macro for DOS lib name
Grafname
	GRAFNAME		;macro for Graphics lib name
Intname
	INTNAME			;macro for Intuition lib name
	
String:
	dc.b	'\nPrinting 100 Times - Counting Down - $%04x',0

;***********************************************************
	SECTION Display_Data,DATA
;***********************************************************

;------ window structure
MyNewWindow 
  	dc.w 		0,0
  	dc.w 		640,200
  	dc.b 		0,1
  	dc.l 		NULL
  	dc.l 		WINDOWDRAG!WINDOWSIZING!WINDOWDEPTH!ACTIVATE!NOCAREREFRESH
  	dc.l 		NULL
  	dc.l 		NULL
  	dc.l 		MYTITLE  
  	dc.l 		NULL
  	dc.l 		NULL
  	dc.w 		100,40
  	dc.w 		640,256
  	dc.w 		WBENCHSCREEN
  
MYTITLE:
  	dc.b 		"Printf Test Ordinary Window",0  
  	EVEN


;***********************************************************
	SECTION	Variables,BSS
;***********************************************************	

_GfxBase:
	ds.l	1		;storage for Graphics lib pointer
_IntuitionBase:
	ds.l	1		;storage for Intuition lib pointer
_DOSBase:
	ds.l	1		;storage for DOS lib pointer
WindowPtr:
	ds.l	1		;storage for window structure pointer
