*
*
* HelloWorld.s	- a small helloworld example in assembler
*
*


	OUTPUT	'ram:HelloWorld'	; write executable to ram:HelloWorld


;
; exec function offsets
;
_LVOOpenLibrary		EQU	-552
_LVOCloseLibrary	EQU	-414
;
; dos function offsets
;
_LVOOutput		EQU	-60
_LVOWrite		EQU	-48

;
; program start
;
start:	lea	DosName(pc),a1
	moveq	#0,d0
	move.l	4,a6			;load execbase
	jsr	_LVOOpenLibrary(a6)	;open dos.library
	move.l	d0,DosBase
	beq.s	NoDosLibrary		;could not open library


	move.l	d0,a6
	jsr	_LVOOutput(a6)		;get StdOut handle (handle in d0)

	move.l	d0,d1
	move.l	#Text,d2
	moveq	#TextLength,d3
	move.l	DosBase,a6
	jsr	_LVOWrite(a6)		;write text to StdOut


Exit:	move.l	DosBase,a1
	move.l	4,a6
	jsr	_LVOCloseLibrary(a6)	;close dos.library

NoDosLibrary:
	moveq	#0,d0			;set AmigaDOS return code
	rts				;exit program


;
; data
;
Text:		DC.B	"Hello World!",$a,0
TextLength	EQU	*-Text

DosName:	DC.B	"dos.library",0
		EVEN

DosBase:	DC.L	0

	END
