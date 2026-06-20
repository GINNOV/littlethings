
; Simon Knipe asked for idaes on a calculator routine. Well this is a start !

; M.Meany April 91.

		incdir		"sys:include/"
		include		"exec/exec_lib.i"
		include		"exec/exec.i"
		include		"intuition/intuition_lib.i"
		include		"intuition/intuition.i"
		include		"libraries/dos.i"
		include		"libraries/dosextens.i"
		include		"graphics/gfx.i"
		include		"graphics/graphics_lib.i"
		include		"source:include/arpbase.i"

; Include easystart to allow a Workbench startup.

		include		"sys:include/misc/easystart.i"
		
ciaapra		equ		$bfe001
NULL		equ		0

;*****************************************

CALLSYS    MACRO		;added CALLSYS macro - using CALLARP
	IFGT	NARG-1       	;CALLINT etc can slow code down and  
	FAIL	!!!         	;waste a lot of memory  S.M. 
	ENDC                 
	JSR	_LVO\1(A6)
	ENDM
		
*****************************************************************************

; The main routine that opens and closes things
;** OPENARP moved to front as it will print a message on the CLI then **
;**   return to easystart if it can't find the ARP library ,we don't  **
;**                need to do any error checking of our own           **

start		OPENARP				;use arp's own open macro
		movem.l		(sp)+,d0/a0	;restore d0 and a0 as the
						;the macro leaves these on
						;the stack causing corrupt stack
		move.l		a6,_ArpBase	;store arpbase
		
;--------------	the ARP library opens and uses the graphics and intuition 
;		libs and it is quite legal for us to get these bases for 
;		our own use

		move.l		IntuiBase(a6),_IntuitionBase
		move.l		GfxBase(a6),_GfxBase

;--------------	Open the intuition window

		lea		CalcWindow,a0
		CALLINT		OpenWindow
		move.l		d0,window.ptr
		beq		error1
				
;--------------	Determine address of this windows rastport and userport.
;		save these for later use.

		move.l		d0,a0
		move.l		wd_RPort(a0),window.rp
		move.l		wd_UserPort(a0),window.up
		
;--------------	Wait for a message to arrive and process it.

; First wait for a message to arrive at the windows user port.

WaitForMsg	move.l		window.up,a0	a0-->window user port
		CALLEXEC	WaitPort	wait for something to happen

; Message arrived, so get its address

		move.l		window.up,a0	a0-->window user port
		CALLEXEC	GetMsg		get any messages

; If no address returned this was a bogus message, ignore it.

		tst.l		d0		was there a message ?
		beq		WaitForMsg	if not loop back

; Obtain message class and message source from message structure returned.

		move.l		d0,a1		a1-->message
		move.l		im_Class(a1),d2	d2=IDCMP flags
		move.l		im_IAddress(a1),a5 a5=addr of structure

; Answer the message now.

		CALLEXEC	ReplyMsg	answer o/s or it gets angry

; If message class was GADGETUP, a gadget has been selected. Jump to the
;gadget handaling code.

		cmp.l		#GADGETUP,d2
		beq		DoGadget

; If message class was CLOSEWINDOW user has hit the close window gadget
;on the window. If not then we ignore the message and loop back to wait for
;the next one to arrive.

		cmp.l		#CLOSEWINDOW,d2
		bne.s		WaitForMsg
		bra		done

; Message class was GADGETUP so a gadget has been selected. Register a5
;holds the address of the source of the message. This will be the gadget
;structure. We have stored the address of the subroutine to deal with 
;a gadgets selection in the UserData field, so now we retrieve this address
;and call the subroutine. This will work for any amount of gadgets of any
;type, providing you store the address of the appropriate subroutine to call
;in the UserData field. This is much simpler than the A & W way.

DoGadget	move.l		gg_UserData(a5),a0
		jsr		(a0)

; When the subroutine has finished control returns to this point, so branch
;back and wait for another message.

		bra		WaitForMsg
		
; If the windows close gadget was selected then control passes to this point.
;First the window is closed and the the ARP library is closed. The program
;then finishes.

done		move.l		window.ptr,a0
		CALLINT		CloseWindow
		
error1		move.l		_ArpBase,a1
		CALLEXEC	CloseLibrary
		
		rts
		
;--------------	Variables

_ArpBase	dc.l		0
_IntuitionBase	dc.l		0
_GfxBase	dc.l		0

window.ptr	dc.l		0
window.rp	dc.l		0
window.up	dc.l		0

BaseIdentifier	dc.l		0


; All subroutines used by the calculator program

; © M.Meany 1991

sub_hex		tst.w		NumBase
		beq.s		.ok
		move.w		#0,NumBase
		move.b		#'$',BaseIdentifier
		bsr		BaseChange
.ok		rts

sub_dec		cmpi.w		#1,NumBase
		beq.s		.ok
		move.w		#1,NumBase
		move.b		#' ',BaseIdentifier
		bsr		BaseChange
.ok		rts

sub_bin		cmpi.w		#2,NumBase
		beq.s		.ok
		move.w		#2,NumBase
		move.b		#'%',BaseIdentifier
		bsr		BaseChange
.ok		rts




sub_.b
sub_.w
sub_.l
sub_0
sub_1
sub_2
sub_3
sub_4
sub_5
sub_6
sub_7
sub_8
sub_9
sub_a
sub_b
sub_c
sub_d
sub_e
sub_f
sub_equ
sub_clr
sub_add
sub_sub
sub_div
sub_mul
sub_and
sub_or
sub_not
sub_sl
sub_sr
BaseChange		rts

;--------------	Subroutine data area


NumBase		dc.w		0	flag : 0=HEX, 1=DEC, 2=BIN

FirstNumber	dc.l		0
SecondNumber	dc.l		0
Result		dc.l		0
Operator	dc.l		0	to hold addr of operator routine

;--------------	Window and gadget defs

CalcWindow	dc.w		100,39
		dc.w		408,120
		dc.b		0,1
		dc.l		GADGETUP+CLOSEWINDOW
		dc.l		WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+ACTIVATE+NOCAREREFRESH
		dc.l		.GadgetList
		dc.l		0
		dc.l		.WindowName
		dc.l		0
		dc.l		0
		dc.w		5,5
		dc.w		640,200
		dc.w		WBENCHSCREEN

.WindowName	dc.b		'Calculator © M.Meany',0
		even
.GadgetList

Gadget2:
		dc.l		Gadget3
		dc.w		26,37
		dc.w		47,11
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		Border2
		dc.l		0
		dc.l		IText1
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		sub_hex
Border2:
		dc.w		-2,-1
		dc.b		2,0,RP_JAM1
		dc.b		5
		dc.l		BorderVectors2
		dc.l		0
BorderVectors2:
		dc.w		0,0
		dc.w		50,0
		dc.w		50,12
		dc.w		0,12
		dc.w		0,0
IText1:
		dc.b		1,0,RP_JAM2,0
		dc.w		11,2
		dc.l		0
		dc.l		ITextText1
		dc.l		0
ITextText1:
		dc.b		'HEX',0
		even
Gadget3:
		dc.l		Gadget4
		dc.w		84,37
		dc.w		47,11
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		Border3
		dc.l		0
		dc.l		IText2
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		sub_dec
Border3:
		dc.w		-2,-1
		dc.b		2,0,RP_JAM1
		dc.b		5
		dc.l		BorderVectors3
		dc.l		0
BorderVectors3:
		dc.w		0,0
		dc.w		50,0
		dc.w		50,12
		dc.w		0,12
		dc.w		0,0
IText2:
		dc.b		1,0,RP_JAM2,0
		dc.w		11,2
		dc.l		0
		dc.l		ITextText2
		dc.l		0
ITextText2:
		dc.b		'DEC',0
		even
Gadget4:
		dc.l		Gadget5
		dc.w		142,37
		dc.w		47,11
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		Border4
		dc.l		0
		dc.l		IText3
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		sub_bin
Border4:
		dc.w		-2,-1
		dc.b		2,0,RP_JAM1
		dc.b		5
		dc.l		BorderVectors4
		dc.l		0
BorderVectors4:
		dc.w		0,0
		dc.w		50,0
		dc.w		50,12
		dc.w		0,12
		dc.w		0,0
IText3:
		dc.b		1,0,RP_JAM2,0
		dc.w		11,2
		dc.l		0
		dc.l		ITextText3
		dc.l		0
ITextText3:
		dc.b		'BIN',0
		even
Gadget5:
		dc.l		Gadget6
		dc.w		337,37
		dc.w		47,11
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		Border5
		dc.l		0
		dc.l		IText4
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		sub_.l
Border5:
		dc.w		-2,-1
		dc.b		2,0,RP_JAM1
		dc.b		5
		dc.l		BorderVectors5
		dc.l		0
BorderVectors5:
		dc.w		0,0
		dc.w		50,0
		dc.w		50,12
		dc.w		0,12
		dc.w		0,0
IText4:
		dc.b		1,0,RP_JAM2,0
		dc.w		14,2
		dc.l		0
		dc.l		ITextText4
		dc.l		0
ITextText4:
		dc.b		'.L',0
		even
Gadget6:
		dc.l		Gadget7
		dc.w		280,37
		dc.w		47,11
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		Border6
		dc.l		0
		dc.l		IText5
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		sub_.w
Border6:
		dc.w		-2,-1
		dc.b		2,0,RP_JAM1
		dc.b		5
		dc.l		BorderVectors6
		dc.l		0
BorderVectors6:
		dc.w		0,0
		dc.w		50,0
		dc.w		50,12
		dc.w		0,12
		dc.w		0,0
IText5:
		dc.b		1,0,RP_JAM2,0
		dc.w		14,2
		dc.l		0
		dc.l		ITextText5
		dc.l		0
ITextText5:
		dc.b		'.W',0
		even
Gadget7:
		dc.l		Gadget8
		dc.w		223,37
		dc.w		47,11
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		Border7
		dc.l		0
		dc.l		IText6
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		sub_.b
Border7:
		dc.w		-2,-1
		dc.b		2,0,RP_JAM1
		dc.b		5
		dc.l		BorderVectors7
		dc.l		0
BorderVectors7:
		dc.w		0,0
		dc.w		50,0
		dc.w		50,12
		dc.w		0,12
		dc.w		0,0
IText6:
		dc.b		1,0,RP_JAM2,0
		dc.w		14,2
		dc.l		0
		dc.l		ITextText6
		dc.l		0
ITextText6:
		dc.b		'.B',0
		even
Gadget8:
		dc.l		Gadget9
		dc.w		27,55
		dc.w		21,11
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		Border8
		dc.l		0
		dc.l		IText7
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		sub_c
Border8:
		dc.w		-2,-1
		dc.b		2,0,RP_JAM1
		dc.b		5
		dc.l		BorderVectors8
		dc.l		0
BorderVectors8:
		dc.w		0,0
		dc.w		24,0
		dc.w		24,12
		dc.w		0,12
		dc.w		0,0
IText7:
		dc.b		1,0,RP_JAM2,0
		dc.w		6,2
		dc.l		0
		dc.l		ITextText7
		dc.l		0
ITextText7:
		dc.b		'C',0
		even
Gadget9:
		dc.l		Gadget10
		dc.w		27,70
		dc.w		21,11
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		Border9
		dc.l		0
		dc.l		IText8
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		sub_8
Border9:
		dc.w		-2,-1
		dc.b		2,0,RP_JAM1
		dc.b		5
		dc.l		BorderVectors9
		dc.l		0
BorderVectors9:
		dc.w		0,0
		dc.w		24,0
		dc.w		24,12
		dc.w		0,12
		dc.w		0,0
IText8:
		dc.b		1,0,RP_JAM2,0
		dc.w		6,2
		dc.l		0
		dc.l		ITextText8
		dc.l		0
ITextText8:
		dc.b		'8',0
		even
Gadget10:
		dc.l		Gadget11
		dc.w		27,85
		dc.w		21,11
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		Border10
		dc.l		0
		dc.l		IText9
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		sub_4
Border10:
		dc.w		-2,-1
		dc.b		2,0,RP_JAM1
		dc.b		5
		dc.l		BorderVectors10
		dc.l		0
BorderVectors10:
		dc.w		0,0
		dc.w		24,0
		dc.w		24,12
		dc.w		0,12
		dc.w		0,0
IText9:
		dc.b		1,0,RP_JAM2,0
		dc.w		6,2
		dc.l		0
		dc.l		ITextText9
		dc.l		0
ITextText9:
		dc.b		'4',0
		even
Gadget11:
		dc.l		Gadget12
		dc.w		27,100
		dc.w		21,11
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		Border11
		dc.l		0
		dc.l		IText10
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		sub_0
Border11:
		dc.w		-2,-1
		dc.b		2,0,RP_JAM1
		dc.b		5
		dc.l		BorderVectors11
		dc.l		0
BorderVectors11:
		dc.w		0,0
		dc.w		24,0
		dc.w		24,12
		dc.w		0,12
		dc.w		0,0
IText10:
		dc.b		1,0,RP_JAM2,0
		dc.w		6,2
		dc.l		0
		dc.l		ITextText10
		dc.l		0
ITextText10:
		dc.b		'0',0
		even
Gadget12:
		dc.l		Gadget13
		dc.w		57,100
		dc.w		21,11
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		Border12
		dc.l		0
		dc.l		IText11
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		sub_1
Border12:
		dc.w		-2,-1
		dc.b		2,0,RP_JAM1
		dc.b		5
		dc.l		BorderVectors12
		dc.l		0
BorderVectors12:
		dc.w		0,0
		dc.w		24,0
		dc.w		24,12
		dc.w		0,12
		dc.w		0,0
IText11:
		dc.b		1,0,RP_JAM2,0
		dc.w		6,2
		dc.l		0
		dc.l		ITextText11
		dc.l		0
ITextText11:
		dc.b		'1',0
		even
Gadget13:
		dc.l		Gadget14
		dc.w		88,100
		dc.w		21,11
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		Border13
		dc.l		0
		dc.l		IText12
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		sub_2
Border13:
		dc.w		-2,-1
		dc.b		2,0,RP_JAM1
		dc.b		5
		dc.l		BorderVectors13
		dc.l		0
BorderVectors13:
		dc.w		0,0
		dc.w		24,0
		dc.w		24,12
		dc.w		0,12
		dc.w		0,0
IText12:
		dc.b		1,0,RP_JAM2,0
		dc.w		6,2
		dc.l		0
		dc.l		ITextText12
		dc.l		0
ITextText12:
		dc.b		'2',0
		even
Gadget14:
		dc.l		Gadget15
		dc.w		119,100
		dc.w		21,11
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		Border14
		dc.l		0
		dc.l		IText13
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		sub_3
Border14:
		dc.w		-2,-1
		dc.b		2,0,RP_JAM1
		dc.b		5
		dc.l		BorderVectors14
		dc.l		0
BorderVectors14:
		dc.w		0,0
		dc.w		24,0
		dc.w		24,12
		dc.w		0,12
		dc.w		0,0
IText13:
		dc.b		1,0,RP_JAM2,0
		dc.w		6,2
		dc.l		0
		dc.l		ITextText13
		dc.l		0
ITextText13:
		dc.b		'3',0
		even
Gadget15:
		dc.l		Gadget16
		dc.w		57,85
		dc.w		21,11
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		Border15
		dc.l		0
		dc.l		IText14
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		sub_5
Border15:
		dc.w		-2,-1
		dc.b		2,0,RP_JAM1
		dc.b		5
		dc.l		BorderVectors15
		dc.l		0
BorderVectors15:
		dc.w		0,0
		dc.w		24,0
		dc.w		24,12
		dc.w		0,12
		dc.w		0,0
IText14:
		dc.b		1,0,RP_JAM2,0
		dc.w		6,2
		dc.l		0
		dc.l		ITextText14
		dc.l		0
ITextText14:
		dc.b		'5',0
		even
Gadget16:
		dc.l		Gadget17
		dc.w		88,70
		dc.w		21,11
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		Border16
		dc.l		0
		dc.l		IText15
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		sub_a
Border16:
		dc.w		-2,-1
		dc.b		2,0,RP_JAM1
		dc.b		5
		dc.l		BorderVectors16
		dc.l		0
BorderVectors16:
		dc.w		0,0
		dc.w		24,0
		dc.w		24,12
		dc.w		0,12
		dc.w		0,0
IText15:
		dc.b		1,0,RP_JAM2,0
		dc.w		6,2
		dc.l		0
		dc.l		ITextText15
		dc.l		0
ITextText15:
		dc.b		'A',0
		even
Gadget17:
		dc.l		Gadget18
		dc.w		119,55
		dc.w		21,11
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		Border17
		dc.l		0
		dc.l		IText16
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		sub_f
Border17:
		dc.w		-2,-1
		dc.b		2,0,RP_JAM1
		dc.b		5
		dc.l		BorderVectors17
		dc.l		0
BorderVectors17:
		dc.w		0,0
		dc.w		24,0
		dc.w		24,12
		dc.w		0,12
		dc.w		0,0
IText16:
		dc.b		1,0,RP_JAM2,0
		dc.w		6,2
		dc.l		0
		dc.l		ITextText16
		dc.l		0
ITextText16:
		dc.b		'F',0
		even
Gadget18:
		dc.l		Gadget19
		dc.w		88,55
		dc.w		21,11
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		Border18
		dc.l		0
		dc.l		IText17
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		sub_e
Border18:
		dc.w		-2,-1
		dc.b		2,0,RP_JAM1
		dc.b		5
		dc.l		BorderVectors18
		dc.l		0
BorderVectors18:
		dc.w		0,0
		dc.w		24,0
		dc.w		24,12
		dc.w		0,12
		dc.w		0,0
IText17:
		dc.b		1,0,RP_JAM2,0
		dc.w		6,2
		dc.l		0
		dc.l		ITextText17
		dc.l		0
ITextText17:
		dc.b		'E',0
		even
Gadget19:
		dc.l		Gadget20
		dc.w		57,70
		dc.w		21,11
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		Border19
		dc.l		0
		dc.l		IText18
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		sub_9
Border19:
		dc.w		-2,-1
		dc.b		2,0,RP_JAM1
		dc.b		5
		dc.l		BorderVectors19
		dc.l		0
BorderVectors19:
		dc.w		0,0
		dc.w		24,0
		dc.w		24,12
		dc.w		0,12
		dc.w		0,0
IText18:
		dc.b		1,0,RP_JAM2,0
		dc.w		6,2
		dc.l		0
		dc.l		ITextText18
		dc.l		0
ITextText18:
		dc.b		'9',0
		even
Gadget20:
		dc.l		Gadget21
		dc.w		57,55
		dc.w		21,11
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		Border20
		dc.l		0
		dc.l		IText19
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		sub_d
Border20:
		dc.w		-2,-1
		dc.b		2,0,RP_JAM1
		dc.b		5
		dc.l		BorderVectors20
		dc.l		0
BorderVectors20:
		dc.w		0,0
		dc.w		24,0
		dc.w		24,12
		dc.w		0,12
		dc.w		0,0
IText19:
		dc.b		1,0,RP_JAM2,0
		dc.w		6,2
		dc.l		0
		dc.l		ITextText19
		dc.l		0
ITextText19:
		dc.b		'D',0
		even
Gadget21:
		dc.l		Gadget22
		dc.w		88,85
		dc.w		21,11
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		Border21
		dc.l		0
		dc.l		IText20
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		sub_6
Border21:
		dc.w		-2,-1
		dc.b		2,0,RP_JAM1
		dc.b		5
		dc.l		BorderVectors21
		dc.l		0
BorderVectors21:
		dc.w		0,0
		dc.w		24,0
		dc.w		24,12
		dc.w		0,12
		dc.w		0,0
IText20:
		dc.b		1,0,RP_JAM2,0
		dc.w		6,2
		dc.l		0
		dc.l		ITextText20
		dc.l		0
ITextText20:
		dc.b		'6',0
		even
Gadget22:
		dc.l		Gadget23
		dc.w		119,70
		dc.w		21,11
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		Border22
		dc.l		0
		dc.l		IText21
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		sub_b
Border22:
		dc.w		-2,-1
		dc.b		2,0,RP_JAM1
		dc.b		5
		dc.l		BorderVectors22
		dc.l		0
BorderVectors22:
		dc.w		0,0
		dc.w		24,0
		dc.w		24,12
		dc.w		0,12
		dc.w		0,0
IText21:
		dc.b		1,0,RP_JAM2,0
		dc.w		6,2
		dc.l		0
		dc.l		ITextText21
		dc.l		0
ITextText21:
		dc.b		'B',0
		even
Gadget23:
		dc.l		Gadget24
		dc.w		119,85
		dc.w		21,11
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		Border23
		dc.l		0
		dc.l		IText22
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		sub_7
Border23:
		dc.w		-2,-1
		dc.b		2,0,RP_JAM1
		dc.b		5
		dc.l		BorderVectors23
		dc.l		0
BorderVectors23:
		dc.w		0,0
		dc.w		24,0
		dc.w		24,12
		dc.w		0,12
		dc.w		0,0
IText22:
		dc.b		1,0,RP_JAM2,0
		dc.w		6,2
		dc.l		0
		dc.l		ITextText22
		dc.l		0
ITextText22:
		dc.b		'7',0
		even
Gadget24:
		dc.l		Gadget25
		dc.w		168,55
		dc.w		21,11
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		Border24
		dc.l		0
		dc.l		IText23
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		sub_add
Border24:
		dc.w		-2,-1
		dc.b		2,0,RP_JAM1
		dc.b		5
		dc.l		BorderVectors24
		dc.l		0
BorderVectors24:
		dc.w		0,0
		dc.w		24,0
		dc.w		24,12
		dc.w		0,12
		dc.w		0,0
IText23:
		dc.b		1,0,RP_JAM2,0
		dc.w		6,2
		dc.l		0
		dc.l		ITextText23
		dc.l		0
ITextText23:
		dc.b		'+',0
		even
Gadget25:
		dc.l		Gadget26
		dc.w		168,70
		dc.w		21,11
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		Border25
		dc.l		0
		dc.l		IText24
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		sub_sub
Border25:
		dc.w		-2,-1
		dc.b		2,0,RP_JAM1
		dc.b		5
		dc.l		BorderVectors25
		dc.l		0
BorderVectors25:
		dc.w		0,0
		dc.w		24,0
		dc.w		24,12
		dc.w		0,12
		dc.w		0,0
IText24:
		dc.b		1,0,RP_JAM2,0
		dc.w		6,2
		dc.l		0
		dc.l		ITextText24
		dc.l		0
ITextText24:
		dc.b		'-',0
		even
Gadget26:
		dc.l		Gadget27
		dc.w		168,85
		dc.w		21,11
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		Border26
		dc.l		0
		dc.l		IText25
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		sub_div
Border26:
		dc.w		-2,-1
		dc.b		2,0,RP_JAM1
		dc.b		5
		dc.l		BorderVectors26
		dc.l		0
BorderVectors26:
		dc.w		0,0
		dc.w		24,0
		dc.w		24,12
		dc.w		0,12
		dc.w		0,0
IText25:
		dc.b		1,0,RP_JAM2,0
		dc.w		6,2
		dc.l		0
		dc.l		ITextText25
		dc.l		0
ITextText25:
		dc.b		'/',0
		even
Gadget27:
		dc.l		Gadget28
		dc.w		168,100
		dc.w		21,11
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		Border27
		dc.l		0
		dc.l		IText26
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		sub_mul
Border27:
		dc.w		-2,-1
		dc.b		2,0,RP_JAM1
		dc.b		5
		dc.l		BorderVectors27
		dc.l		0
BorderVectors27:
		dc.w		0,0
		dc.w		24,0
		dc.w		24,12
		dc.w		0,12
		dc.w		0,0
IText26:
		dc.b		1,0,RP_JAM2,0
		dc.w		6,2
		dc.l		0
		dc.l		ITextText26
		dc.l		0
ITextText26:
		dc.b		'*',0
		even
Gadget28:
		dc.l		Gadget29
		dc.w		197,85
		dc.w		21,11
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		Border28
		dc.l		0
		dc.l		IText27
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		sub_clr
Border28:
		dc.w		-2,-1
		dc.b		2,0,RP_JAM1
		dc.b		5
		dc.l		BorderVectors28
		dc.l		0
BorderVectors28:
		dc.w		0,0
		dc.w		24,0
		dc.w		24,12
		dc.w		0,12
		dc.w		0,0
IText27:
		dc.b		1,0,RP_JAM2,0
		dc.w		6,2
		dc.l		0
		dc.l		ITextText27
		dc.l		0
ITextText27:
		dc.b		'C',0
		even
Gadget29:
		dc.l		Gadget30
		dc.w		198,100
		dc.w		21,11
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		Border29
		dc.l		0
		dc.l		IText28
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		sub_equ
Border29:
		dc.w		-2,-1
		dc.b		2,0,RP_JAM1
		dc.b		5
		dc.l		BorderVectors29
		dc.l		0
BorderVectors29:
		dc.w		0,0
		dc.w		24,0
		dc.w		24,12
		dc.w		0,12
		dc.w		0,0
IText28:
		dc.b		1,0,RP_JAM2,0
		dc.w		6,2
		dc.l		0
		dc.l		ITextText28
		dc.l		0
ITextText28:
		dc.b		'=',0
		even
Gadget30:
		dc.l		Gadget31
		dc.w		254,100
		dc.w		47,11
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		Border30
		dc.l		0
		dc.l		IText29
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		sub_sl
Border30:
		dc.w		-2,-1
		dc.b		2,0,RP_JAM1
		dc.b		5
		dc.l		BorderVectors30
		dc.l		0
BorderVectors30:
		dc.w		0,0
		dc.w		50,0
		dc.w		50,12
		dc.w		0,12
		dc.w		0,0
IText29:
		dc.b		1,0,RP_JAM2,0
		dc.w		15,2
		dc.l		0
		dc.l		ITextText29
		dc.l		0
ITextText29:
		dc.b		'<<',0
		even
Gadget31:
		dc.l		Gadget32
		dc.w		309,100
		dc.w		47,11
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		Border31
		dc.l		0
		dc.l		IText30
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		sub_sr
Border31:
		dc.w		-2,-1
		dc.b		2,0,RP_JAM1
		dc.b		5
		dc.l		BorderVectors31
		dc.l		0
BorderVectors31:
		dc.w		0,0
		dc.w		50,0
		dc.w		50,12
		dc.w		0,12
		dc.w		0,0
IText30:
		dc.b		1,0,RP_JAM2,0
		dc.w		15,2
		dc.l		0
		dc.l		ITextText30
		dc.l		0
ITextText30:
		dc.b		'>>',0
		even
Gadget32:
		dc.l		Gadget33
		dc.w		281,85
		dc.w		47,11
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		Border32
		dc.l		0
		dc.l		IText31
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		sub_not
Border32:
		dc.w		-2,-1
		dc.b		2,0,RP_JAM1
		dc.b		5
		dc.l		BorderVectors32
		dc.l		0
BorderVectors32:
		dc.w		0,0
		dc.w		50,0
		dc.w		50,12
		dc.w		0,12
		dc.w		0,0
IText31:
		dc.b		1,0,RP_JAM2,0
		dc.w		11,2
		dc.l		0
		dc.l		ITextText31
		dc.l		0
ITextText31:
		dc.b		'NOT',0
		even
Gadget33:
		dc.l		Gadget34
		dc.w		281,70
		dc.w		47,11
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		Border33
		dc.l		0
		dc.l		IText32
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		sub_or
Border33:
		dc.w		-2,-1
		dc.b		2,0,RP_JAM1
		dc.b		5
		dc.l		BorderVectors33
		dc.l		0
BorderVectors33:
		dc.w		0,0
		dc.w		50,0
		dc.w		50,12
		dc.w		0,12
		dc.w		0,0
IText32:
		dc.b		1,0,RP_JAM2,0
		dc.w		15,2
		dc.l		0
		dc.l		ITextText32
		dc.l		0
ITextText32:
		dc.b		'OR',0
		even
Gadget34:
		dc.l		0
		dc.w		281,55
		dc.w		47,11
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		Border34
		dc.l		0
		dc.l		IText33
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		sub_and
Border34:
		dc.w		-2,-1
		dc.b		2,0,RP_JAM1
		dc.b		5
		dc.l		BorderVectors34
		dc.l		0
BorderVectors34:
		dc.w		0,0
		dc.w		50,0
		dc.w		50,12
		dc.w		0,12
		dc.w		0,0
IText33:
		dc.b		1,0,RP_JAM2,0
		dc.w		11,2
		dc.l		0
		dc.l		ITextText33
		dc.l		0
ITextText33:
		dc.b		'AND',0
		even



Border1:
		dc.w		-2,-1			25,18
		dc.b		1,0,RP_JAM1
		dc.b		5
		dc.l		BorderVectors1
		dc.l		0
BorderVectors1:
		dc.w		0,0
		dc.w		362,0
		dc.w		362,9
		dc.w		0,9
		dc.w		0,0


		

