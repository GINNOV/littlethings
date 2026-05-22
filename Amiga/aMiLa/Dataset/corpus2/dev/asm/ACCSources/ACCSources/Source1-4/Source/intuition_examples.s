*	PROGRAMMING INTUITION BY MIKE CROSS
*	EXAMPLE PROGRAM FOR :
*	CUSTOM SCREENS AND WINDOWS
*	REQUESTERS
*	CUSTOM MOUSE POINTER

*	SOMETIMES THE POINTER CORRUPTS. DO NOT ASK ME WHY!


	section	INTUITION,code_c
	

	opt	c-
	
	move.l	$4,a6
	lea	IntName,a1
	jsr	-408(a6)	* OpenLibrary()
	beq	Exit
	move.l	d0,IntBase
	
	
	move.l	IntBase,a6
	lea	Screen1,a0
	jsr	-198(a6)	* OpenScreen()
	move.l	d0,SHandle
	
	move.l	IntBase,a6
	jsr	-210(a6)
	
	
	move.l	IntBase,a6
	lea	Window1,a0
	jsr	-204(a6)	* OpenWindow()
	move.l	d0,WHandle
	
	
	move.l	WHandle,a0
	lea	Pointer,a1
	move.w	#57,d0
	move.w	#7,d1
	move.w	#0,d2
	move.w	#0,d3
	
	move.l	IntBase,a6
	jsr	-270(a6)	* SetPointer
	
	
	
loop	move.l	$4,a6
	move.l	WHandle,a0
	move.l	86(a0),a0
	jsr	-372(a6)	* GetMsg() - Exec
	beq	loop
	move.l	d0,a0
	move.l	20(a0),d6
	
	cmpi.w	#$200,d6
	beq	Request
	jmp	loop
	

Request	move.l	#0,d0		* Clear check registers (D0, D1)
	move.l	#0,d1
	move.l	#160,d2		* Requester width
	move.l	#60,d3		* Requester height
	move.l	WHandle,a0	* Attach requester to this window
	lea	BText,a1	* Pointer to main requester text
	lea	LText,a2	* Text displayed on left
	lea	RText,a3	* Text displayed on right
	move.l	IntBase,a6	
	jsr	-348(a6)	* AutoRequest()
	
	cmpi.w	#1,d0		* If D0 = 0 then Left (quit) was selected
	bne.s	loop		* If D0 = 1 then Right (no) was selected
		
Out	move.l	IntBase,a6

	move.l	WHandle,a0
	jsr	-60(a6)		* ClearPointer
	
	move.l	WHandle,a0
	jsr	-72(a6)		* CloseWindow()

	move.l	SHandle,a0
	jsr	-66(a6)		* CloseScreen()
	
	move.l	$4,a6
	move.l	IntBase,a1
	jsr	-414(a6)	* CloseLibrary()  - Intuition 
Exit	rts
	



IntName	dc.b	"intuition.library",0

	even

IntBase	dc.l	0

WHandle	dc.l	0

	even
	
Screen1	dc.w	0,0,640,400,2			* Screen Structure
	dc.b	0,1
	dc.w	$8002,15
	dc.l	0
	dc.l	Title1
	dc.l	0,0
Title1	dc.b	" Intuition Screen ",169," 1990 Mike Cross",0
	
Window1	dc.w	0,11,640,238			* Window Structure
	dc.b	1,3
	dc.l	$200,$100f,0,0
	dc.l	Wtitle
SHandle	dc.l	0
	dc.l	0
	dc.w	150,50,320,250,15
Wtitle	dc.b	" Intuition Window ",0

	even
	
BText	dc.b	0,1
	dc.b	0
	even
	dc.w	10,10
	dc.l	0
	dc.l	BodyTxt
	dc.l	0
BodyTxt	dc.b	"Are you sure ?",0
	
	even

LText	dc.b	0,1
	dc.b	0
	even
	dc.w	5,3
	dc.l	0
	dc.l	LeftTxt
	dc.l	0
LeftTxt	dc.b	"Yes",0
	
	even
	
RText	dc.b	0,1
	dc.b	0
	even
	dc.w	5,3
	dc.l	0
	dc.l	RightTx
	dc.l	0
RightTx	dc.b	"No",0
	
	even
	
Pointer	dc.w	$0000,$0000
	dc.w	$0000,$1000,$0000,$1000,$3800,$0000,$3800,$0000
	dc.w	$7c00,$0000,$7c00,$0000,$7c00,$0000,$fe00,$0000
	dc.w	$fe00,$0000,$0000,$fe00,$0000,$fe00,$0000,$fe00
	dc.w	$0000,$fe00,$0000,$fe00,$0000,$fe00,$0000,$fe00
	dc.w	$0000,$fe00,$0000,$fe00,$0000,$fe00,$7c00,$8200
	dc.w	$0800,$f600,$0800,$f600,$7c00,$8200,$0000,$fe00
	dc.w	$0000,$fe00,$0000,$fe00,$0000,$fe00,$0000,$fe00
	dc.w	$0000,$fe00,$2400,$da00,$4400,$ba00,$4400,$ba00
	dc.w	$7c00,$8200,$0400,$fa00,$0400,$fa00,$0000,$fe00
	dc.w	$0000,$fe00,$0000,$fe00,$0000,$fe00,$7c00,$8200
	dc.w	$4400,$ba00,$4400,$ba00,$4400,$ba00,$0000,$fe00
	dc.w	$0000,$fe00,$0000,$fe00,$0000,$fe00,$0000,$fe00
	dc.w	$0000,$fe00,$fe00,$fe00,$fe00,$fe00,$0000,$fe00
	dc.w	$0000,$fe00,$0000,$fe00,$0000,$fe00,$0000,$fe00
	dc.w	$0000,$7c00,$0000
	dc.w	$0000,$0000

			
