

*****	Title		Competition for ACC Disc21
*****	Function	Allows password entry and displays decrypted message
*****			
*****			
*****			
*****	Size		2380 bytes
*****	Author		Mark Meany
*****	Date Started	Feb 92
*****	This Revision	Feb 92
*****	Notes		 o o
*****			  |
*****			\___/


		incdir		"sys:include/"
		include		"exec/exec_lib.i"
		include		"exec/exec.i"
		include		"intuition/intuition_lib.i"
		include		"intuition/intuition.i"
		include		"libraries/dos_lib.i"
		include		"libraries/dos.i"
		include		"libraries/dosextens.i"
		include		"graphics/gfx.i"
		include		"graphics/graphics_lib.i"


		include		SysMacros.i

		bsr		OpenLibs		open libraries
		tst.l		d0			any errors?
		beq		no_libs			if so quit

; Open a window  and print some text

		OPENWIN		#MyWindow,#WinText
		move.l		d0,window.ptr		save struct ptr
		beq.s		no_libs			quit if error

; Wait for close gadget to be hit.

		HANDLEIDCMP	window.ptr		use macro

; close the window

		CLOSEWIN	window.ptr		use macro

no_libs		bsr		CloseLibs		close open libraries

		rts					finish

;--------------
;--------------	Deal with a new password
;--------------

DoPassword	lea		Header,a6
		move.l		#0,(a6)			clear last password
		move.l		#0,4(a6)

; Copy new password into data block

		lea		Password,a0
		move.l		a6,a1
.passloop	move.b		(a0)+,d0
		beq.s		.passdone
		move.b		d0,(a1)+
		bra.s		.passloop
		
; Copy encrypted text into decrypt buffer

.passdone	lea		String,a0
		lea		DecBuff,a1
		moveq.l		#StrLen,d0
		subq.l		#1,d0			dbcc adjust
.copyloop	move.b		(a0)+,(a1)+
		dbra		d0,.copyloop

; Decrypt the text using new password

		bsr		Decrypt

; Now print out the decryption

		move.l		window.ptr,a0
		move.l		wd_RPort(a0),a0
		lea		IText6,a1
		moveq.l		#0,d0
		moveq.l		#0,d1
		CALLINT		PrintIText
		
; Clear password and activate string gadget

		move.b		#0,Password
		lea		Gadget1,a0
		move.l		window.ptr,a1
		suba.l		a2,a2
		CALLSYS		ActivateGadget		

		moveq.l		#0,d2
		rts

* Password based PRNG encryption system routines

* Passwords limited to 8 chars max.

* Routines that the USER needs to write are:

* 1)	Routine to get password from keyboard WITHOUT
*	displaying the characters on screen (a la UNIX Login)
*	and save it in key(a6) (zero padded at end if password
*	fewer than 8 chars)

* 2)	Routines to load and save the file (standard DOS library
*	stuff) being encrypted/decrypted

* 3)	Front end to allow either encryption or decryption



		rsreset
key		rs.l	2	;8 char password key
filebuf		rs.l	1	;pointer to plaintext/ciphertext
filesize	rs.l	1	;no of chars in file


* Encrypt(a6)
* a6 = ptr to variables defined in RS section above

* Take plaintext file, spit out ciphertext


* d0-d5/a0-a2 corrupt


Encrypt		move.l	filebuf(a6),a0		;ptr to file
		move.l	filesize(a6),d0		;no of chars

Encrypt_1	move.b	(a0),d1			;get plaintext char
		bsr	PRNG			;execute this
		lea	key(a6),a1		;this lot gets LSB of
		move.l	4(a1),d2		;the changed key
		add.b	d2,d1			;encrypt char
		move.b	d1,(a0)+		;replace ciphertext char
		subq.l	#1,d0			;done all chars?
		bne.s	Encrypt_1		;back if not
		rts				;else done


* Decrypt(a6)
* a6 = ptr to variables defined in RS section above

* Take ciphertext file, recreate plaintext


* d0-d5/a0-a2 corrupt


Decrypt		move.l	filebuf(a6),a0		;ptr to file
		move.l	filesize(a6),d0		;no of chars

Decrypt_1	move.b	(a0),d1			;get ciphertext char
		bsr	PRNG			;execute this
		lea	key(a6),a1		;this lot gets LSB of
		move.l	4(a1),d2		;the changed key
		sub.b	d2,d1			;decrypt char
		move.b	d1,(a0)+		;replace plaintext char
		subq.l	#1,d0			;done all chars?
		bne.s	Decrypt_1		;back if not
		rts				;else done


* PRNG(a6)
* a6 = ptr to variables above

* Pseudo random number generator (64 bits wide)
* Should be OK.

* d2-d5/a1-a2 corrupt


PRNG		lea	key(a6),a1
		move.l	a1,a2
		move.l	(a2)+,d2		;get key
		move.l	(a2)+,d3

		roxl.l	#1,d3			;this lot is a
		roxl.l	#1,d2			;64-bit rotate
		bcc.s	PRNG_1
		or.b	#1,d3

PRNG_1		move.l	d2,d4			;this lot does the
		moveq	#0,d5			;scrambling
		eor.l	d3,d4
		addx.l	d5,d3
		addx.l	d4,d3
		addx.l	d5,d2
		move.l	d2,(a1)+		save scrambled key
		move.l	d3,(a1)+
		rts


;--------------
;--------------	Pull in subroutines
;--------------

		include		OpenCloseLibs.i
		include		Subroutines.i

****************************************************************************
*			Data						   *
****************************************************************************

String	dc.l	$35a6bf53,$fe7413ae,$1b80a4f4,$155c9765,$aa41d380
	dc.b	$f0,$23,$c2
StrLen	equ	*-String
	even

Header	dc.l	0,0		for password
	dc.l	DecBuff		addr of text to decypher
	dc.l	StrLen

;***********************************************************
;	Screen, Window and Gadget defenitions
;***********************************************************

NULL	equ	0

MyWindow
	dc.w	122,31
	dc.w	371,110
	dc.b	0,1
	dc.l	GADGETUP+CLOSEWINDOW
	dc.l	WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+ACTIVATE+NOCAREREFRESH
	dc.l	GadgetList1
	dc.l	NULL
	dc.l	WindowName
	dc.l	NULL
	dc.l	NULL
	dc.w	5,5
	dc.w	640,200
	dc.w	WBENCHSCREEN
WindowName
	dc.b	'         Competition Feb 92',0
	cnop 0,2
GadgetList1:
Gadget1:
	dc.l	NULL
	dc.w	140,69
	dc.w	76,10
	dc.w	NULL
	dc.w	RELVERIFY
	dc.w	STRGADGET
	dc.l	Border1
	dc.l	NULL
	dc.l	IText1
	dc.l	NULL
	dc.l	Gadget1SInfo
	dc.w	NULL
	dc.l	DoPassword
Gadget1SInfo:
	dc.l	Password
	dc.l	NULL
	dc.w	0
	dc.w	9
	dc.w	0
	dc.w	0,0,0,0,0
	dc.l	0
	dc.l	0
	dc.l	NULL
Password
	ds.b	9
	cnop 0,2
Border1:
	dc.w	-2,-1
	dc.b	3,0,RP_JAM1
	dc.b	5
	dc.l	BorderVectors1
	dc.l	NULL
BorderVectors1:
	dc.w	0,0
	dc.w	79,0
	dc.w	79,11
	dc.w	0,11
	dc.w	0,0
IText1:
	dc.b	3,0,RP_JAM2,0
	dc.w	-115,1
	dc.l	NULL
	dc.l	ITextText1
	dc.l	NULL
ITextText1:
	dc.b	'Password -->',0
	cnop 0,2

WinText
IText2:
	dc.b	3,0,RP_JAM2,0
	dc.w	48,19
	dc.l	NULL
	dc.l	ITextText2
	dc.l	IText3
ITextText2:
	dc.b	'You must enter correct password',0
	cnop 0,2
IText3:
	dc.b	3,0,RP_JAM2,0
	dc.w	45,29
	dc.l	NULL
	dc.l	ITextText3
	dc.l	IText4
ITextText3:
	dc.b	'to crack the code! First correct',0
	cnop 0,2
IText4:
	dc.b	3,0,RP_JAM2,0
	dc.w	52,39
	dc.l	NULL
	dc.l	ITextText4
	dc.l	IText5
ITextText4:
	dc.b	'solution wins AmigaDOS manual!',0
	cnop 0,2
IText5:
	dc.b	3,0,RP_JAM2,0
	dc.w	69,49
	dc.l	NULL
	dc.l	ITextText5
	dc.l	IText6
ITextText5:
	dc.b	'Send solutions to M.Meany.',0
	cnop 0,2
IText6:
	dc.b	2,0,RP_JAM2,0
	dc.w	8,91
	dc.l	NULL
	dc.l	ITextText6
	dc.l	DecryptText
ITextText6:
	dc.b	'Decryption ->'
	dcb.b	StrLen,' '
	dc.b	0
	cnop 0,2

DecryptText
	dc.b	2,0,RP_JAM2,0
	dc.w	8,91
	dc.l	NULL
	dc.l	ITextText7
	dc.l	NULL
ITextText7
	dc.b	'Decryption ->'
DecBuff	ds.b	StrLen
	dc.b	0
	cnop 0,2


; end of PowerWindows source generation

;***********************************************************
	SECTION	Vars,BSS
;***********************************************************

screen.ptr	ds.l		1

window.ptr	ds.l		1
window.rp	ds.l		1
window.up	ds.l		1
