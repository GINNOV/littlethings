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
  	beq.s		Error			;cleanup and quit if fail

	lea		ConName(pc),a0		;get console name string
	move.l		a0,d1			;and move to d1
	move.l		#MODE_OLDFILE,d2	;set open mode
	CALLDOS		Open
	move.l		d0,a2
  	
  	move.w		#100,-(sp)		;store number 100 on stack
Loop:
;------ a2 already holds console handle
 
	lea		String(pc),a0		;string address in a0
	move.l		sp,a1			;data stream address in a1
	bsr.s		fprintf			;do formatted print
	subq.w		#1,(sp)			;decrement counter
	bpl.s		Loop			;loop until negative
	
	addq.l		#2,sp			;pop number from stack 
	
	moveq		#50,d1			;set 1 second delay
	CALLDOS		Delay			;and wait

;------ remove menu and close window
KillWindow:
  	move.l 		a2,d1			;console handle in a0
  	CALLDOS 	Close			;close the console
  	
WdwError:  
	move.l		a6,a1			;dos lib base in a1
	CALLEXEC	CloseLibrary		;close dos
  	
Error
	rts					;quit

;***********************************************************
;	This is the printf routine
;***********************************************************
;	Called with     printf(String,args)
;                                a0    a1 

printf:
	movem.l		a0-a1,-(sp)
	CALLDOS		Output
	move.l		d0,a2
	movem.l		(sp)+,a0-a1

;***********************************************************
;	This is the printf routine
;***********************************************************
;	Called with     fprintf(String,args,Handle)
;                                a0    a1    a2

fprintf:
	movem.l		a2/a6,-(sp)		;save regs a2 and a6
	move.l		a2,a3			;window in a3
	lea		PutChar(pc),a2		;address of output routine
	CALLEXEC	RawDoFmt		;format and print string
	movem.l		(sp)+,a2/a6		;restore a2 and a6
	rts					;and quit
	
printfBuffer:
	dc.w		0			;temp buffer

PutChar:
	movem.l		d0-d3/a6,-(sp)		;save regs
	tst.b		d0			;check character
	beq.s		LastChar		;branch if null
	lea		printfBuffer(pc),a0	;buffer address in a0
	cmpi.b		#'\',(a0)		;was previous char a \
	beq.s		Escape			;yes branch to escape routine
	
	move.b		d0,(a0)			;move character to buffer
	cmpi.b		#'\',d0			;is it a \
	beq.s		LastChar		;if yes skip print routine

NotSupported:
	move.l		a3,d1			;output handle in d1
	move.l		a0,d2
	moveq		#1,d3			;number of chars = 1
	CALLDOS		Write			;write text
	
LastChar
	movem.l		(sp)+,d0-d3/a6		;restore regs
	rts
	
;===========================================================
Escape:
	cmpi.b		#'n',d0			;is it a newline
	beq.s		Newline			;if yes do it
	
	cmpi.b		#'c',d0			;is it a carraige return
	beq.s		CReturn			;if yes do it
	
	cmpi.b		#'b',d0			;is it a backspace
	beq.s		BackSpace		;if yes do it
	
	cmpi.b		#'f',d0			;is it a formfeed
	beq.s		FormFeed		;if yes do it
	
	move.b		d0,(a0)			;store char in buffer
	bra.s		NotSupported		;branch back and print it

;===========================================================
BackSpace:
	move.b		#$08,(a0)
	bra.s		NotSupported
		
;===========================================================
Newline:
	move.b		#$0a,(a0)
	bra.s		NotSupported
	
;===========================================================
FormFeed:
	move.b		#$0c,(a0)
	bra.s		NotSupported
	
;===========================================================
CReturn:
	move.b		#$0d,(a0)
	bra.s		NotSupported

;***********************************************************
;	End of printf routine
;***********************************************************

;------	Strings,Lib names  etc.	
	
DOSname
	DOSNAME			;macro for DOS lib name

String:
	dc.b	'\nPrinting 100 Times - Counting Down - $%04x',0
	
ConName:
	dc.b	'CON:0/0/640/200/Console printf Test',0 


;***********************************************************
	SECTION	Variables,BSS
;***********************************************************	

_DOSBase:
	ds.l	1		;storage for DOS lib pointer

