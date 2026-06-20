****************************************************************************
*                                                                          *
*   _       _  _           Number Base Convertor                           *
*  |_| => || || ||                                                         *
*   _|    ||_||_|| etc     ©1993 Stuart Davis. All rights reserved.        *
*                                                                          *
*     Version : 1.01       Date : 29th March 1992                          *
*                                                                          *
****************************************************************************

	include	dh1:devpac/projects/baseconvertor/baseconvertorwindow.i

	XREF	_GadToolsBase
	XREF	_IntuitionBase
	XREF	_GfxBase
	XREF	_SysBase

	XREF	OpenLibs
	XREF	CloseLibs
	XREF	ErrorFlag


	incdir	sys:include/
	include	devices/inputevent.i
	include	devices/timer.i
	include	devices/serial.i

	include	exec/types.i
	include	exec/exec.i
	include	exec/exec_lib.i
	include	exec/io.i
	include	exec/libraries.i
	include	exec/lists.i
	include	exec/memory.i
	include	exec/nodes.i
	include	exec/ports.i
	include	exec/semaphores.i
	include	exec/tasks.i
	include	exec/execbase.i
	include	exec/errors.i
	include	exec/interrupts.i

	include	graphics/clip.i
	include	graphics/copper.i
	include	graphics/gfx.i
	include	graphics/gfxnodes.i
	include	graphics/graphics_lib.i
	include	graphics/layers.i
	include	graphics/rastport.i
	include	graphics/text.i
	include	graphics/view.i
	include	graphics/gfxbase.i

	include	hardware/intbits.i

	include	intuition/intuition.i
	include	intuition/intuition_lib.i
	include	intuition/intuitionbase.i
	include	intuition/iobsolete.i
	include	intuition/preferences.i
	include	intuition/screens.i

	include	libraries/dos.i
	include	libraries/dos_lib.i
	include	libraries/dosextens.i
	include	libraries/translator.i
	include	libraries/translator_lib.i
	include	libraries/gadtools.i
	include	libraries/gadtools_lib.i
	include	libraries/asl.i
	include	libraries/asl_lib.i
	include	libraries/reqtools.i
	include	libraries/reqtools_lib.i

	include	utility/utility.i
	include	utility/utility_lib.i
	include	utility/tagitem.i

	include	workbench/startup.i
	include	workbench/icon_lib.i

	include	easystart.i

run:
	bsr	OpenLibs
	tst.b	ErrorFlag
	bne.s	nolibs
	bsr	SetupScreen		;get visual info etc
	bsr	OpenProject0Window		;open window and render all

loop:	bsr.s	sortmsgs0			;get and sort messages
	bra.s	loop			;keep going
	
endahrm:					;start of closedown
	bsr	CloseProject0Window
	bsr	CloseDownScreen
nolibs:	bsr	CloseLibs
	moveq.l	#0,d0			;DOS error code
	rts				;done		

****************************************************************************
*                      sort messages subroutine
****************************************************************************
sortmsgs0:				;get and process any menu/gadget msgs
	move.l	Project0Wnd,a0		;get window handle
	move.l	wd_UserPort(a0),a0		;get userport
	CALLEXEC	WaitPort			;wait for some activity
	move.l	Project0Wnd,a0		;get window handle
	move.l	wd_UserPort(a0),a0		;get userport
	CALLGAD	GT_GetIMsg		;get address of msg
	tst.l	d0
	beq.s	endmsgs0			;branch if no message
	move.l	d0,a0			;msg pointer in a0
	move.l	im_Class(a0),d4		;event description
	move.w	im_Code(a0),d5		;menu number choice
	move.l	d0,a1			;reply to message
	CALLGAD	GT_ReplyIMsg		;thank you intuition

	cmpi.w	#CLOSEWINDOW,d4		;WINDOW CLOSE?
	beq.s	quit			;branch if so

	cmpi.w	#GADGETUP,d4		;was new number input?
	beq.s	newnumber			;branch if so
	
	cmpi.w	#GADGETDOWN,d4		;was mx gadget selected?
	bne.s	menu?			;try menus if not
	move.b	d5,inputbase		;save input base type
	bra.s	sortmsgs0			;and loop

menu?:	cmpi.w	#MENUPICK,d4		;has menu item been chosen?
	bne.s	endmsgs0			;branch if not

	cmpi.w	#$f800,d5			;check if about was selected
	beq	aboutme			;branch if it was
	cmpi.w	#$f820,d5			;check if quit was selected
	bne.s	endmsgs0			;branch if it wasn't
quit:	move.l	#endahrm,(SP)		;return to closedown proc
endmsgs0:	rts
****************************************************************************
*               new number input so convert and redisplay
****************************************************************************
newnumber:
	lea	Project0Gadgets,a0		;gadget pointer array
	move.l	GDX_Gadget10*4(a0),a0	;string gadget pointer
	move.l	34(a0),a0			;get pointer to ptr
	move.l	(a0),a0			;get pointer to input text

	cmpi.b	#0,inputbase		;is number decimal?
	beq	dectobin			;branch if so
	cmpi.b	#1,inputbase		;is number binary?
	beq.s	bintobin			;branch if so
	cmpi.b	#2,inputbase		;is number hex?
	beq.s	hextobin			;branch if so

********************** octal ascii to raw binary conversion

octtobin:					;else it must be octal
	bsr	octerrorcheck		;check string syntax
	tst.b	(a0)			;does digit exist?
	beq.s	ntascii			;branch if not
nextot:	move.b	(a0)+,d0			;else get ascii value
	sub.b	#$30,d0			;get raw binary value
	add.b	d0,d2			;and put value into d2
	tst.b	(a0)			;does next digit exist?
	beq.s	ntascii			;branch if not
	lsl.l	#3,d2			;move result reg up 1 nibble
	bra.s	nextot			;repeat for next digit
ntascii:	move.l	d2,rawbinary		;save value
	bra	bintoall			;now convert number to all

********************* hex ascii to raw binary conversion

hextobin:					;input number is hex
	bsr	hexerrorcheck		;check string syntax
	tst.b	(a0)			;does digit exist?
	beq.s	notasci			;branch if not
nexthx:	move.b	(a0)+,d0			;else get ascii value
	sub.b	#$30,d0			;get raw binary value
	cmpi.b	#9,d0			;is it a number?
	ble.s	nocompen			;branch if so
	sub.b	#39,d0			;else compensate for letter
nocompen:	add.b	d0,d2			;and put value into d2
	tst.b	(a0)			;does next digit exist?
	beq.s	notasci			;branch if not
	lsl.l	#4,d2			;move result reg up 1 nibble
	bra.s	nexthx			;repeat for next digit
notasci:	move.l	d2,rawbinary		;save value
	bra.s	bintoall			;now convert number to all

********************* bin ascii to raw binary conversion

bintobin:					;convert ascii bin to raw
	bsr	binerrorcheck		;check string for syntax
	moveq.l	#0,d0			;counter for number of bits
	moveq.l	#1,d5
terloop:	tst.b	(a0)+
	beq.s	terfnd
	addq.b	#1,d5
	bra.s	terloop
terfnd:	suba.w	#2,a0			;point to end of string
bin2binloop:
	cmpi.b	#"0",(a0)			;is digit a zero
	beq.s	setzero			;branch if so
	cmpi.b	#"1",(a0)			;is digit a 1
	bne.s	notone			;branch if not
	bset.l	d0,d2			;else set bit to 1
setzero:	addq.b	#1,d0			;next bit position
notone:	suba.w	#1,a0			;next sig posn in string
	tst.b	(a0)			;has user entered <32 bits
	beq.s	donebin2bin		;branch if terminator found
	cmp.b	d5,d0			;have we checked all posn
	bne.s	bin2binloop		;branch if not
donebin2bin:
	move.l	d2,rawbinary		;save value
	bra.s	bintoall			;now convert number to all

******************** decimal ascii to raw binary conversion

dectobin:					;input number is decimal
	bsr	decerrorcheck		;check string for syntax
	moveq.l	#0,d2			;clear regs
	moveq.l	#0,d3
cont:	moveq.l	#0,d1
	move.b	(a0)+,d1			;get ascii char
	beq.s	exit			;exit if terminator char
	subi.b	#$30,d1			;convert to raw
	add.l	d1,d2			;add to existing number
	move.l	d2,d1			;put back in adder
	cmpi.b	#0,(a0)			;is next char a terminator?
	beq.s	exit			;branch if so
	moveq.l	#1,d3			;else no. of times to loop
	asl.l	#3,d2			;multiply by 8
decloop:	add.l	d1,d2			;and loop 2 more times
	dbf	d3,decloop
	bra.s	cont
exit:	move.l	d2,rawbinary		;stick raw value in mem


**************************** raw binary to decimal ascii conversion

bintoall:					;convert binary to all bases
	moveq.l	#9,d0			;number of chars to clear
	lea	decstring(pc),a0		;address of string
cleardec:	move.b	#"0",(a0)+		;clear last value
	dbf	d0,cleardec
	move.l	rawbinary,d0		;get raw value
	lea	table(pc),a1		;table of 10->x for sub.l
	lea	decstring-1(pc),a0		;place to build ascii
	moveq.l	#0,d2			;clear offset reg
loadval:	addq.b	#1,d2			;inc offset to next char
	move.l	(a1)+,d1			;get sub value
          beq.s	out			;quit if terminating value
          btst.l	#31,d0			;is sign bit set?
          bne.s	dcasloop			;skip compare if so
          cmp.l	d1,d0			;else compare with raw
          blt.s	loadval			;branch if raw's too small
dcasloop: addq.b	#1,0(a0,d2.l)		;else for every sub, add
	sub.l	d1,d0			;1 to the ascii char and*
	btst.l	#31,d0			;is sign bit set?
          bne.s	dcasloop			;skip compare if so
	cmp.l	d1,d0			;*keep going until raw is
	blt.s	loadval			;too small
	bra.s	dcasloop
out:	add.b	d0,0(a0,d2.l)		;add final 1's digit


************************* raw binary to binary ascii conversion

	move.l	rawbinary,d0		;raw number
	lea	binstring,a0		;place for ascii conversion
	moveq.l	#31,d1			;counter for bits
binloop:	btst.l	#31,d0			;test if bit set
	beq.s	zero			;branch if it's a zero
	move.b	#"1",(a0)+		;else set ascii 1
	bra.s	pastzero			;and skip setting 0
zero:	move.b	#"0",(a0)+		;set ascii 0
pastzero:	rol.l	d0			;test next bit along
	cmpi.b	#24,d1
	beq.s	addspace
	cmpi.b	#16,d1
	beq.s	addspace
	cmpi.b	#8,d1
	bne.s	dbfloop
addspace:	move.b	#" ",(a0)+
dbfloop:	dbf	d1,binloop		;dec counter and branch
	move.b	#0,(a0)

************************* raw binary to hex ascii conversion

	move.l	rawbinary,d0		;raw number
	lea	hexstring+8,a0		;place for ascii conversion
	moveq.l	#7,d5			;number of times to loop
hexloop:	move.b	d0,d1			;get lower 8 bits
	andi.b	#%00001111,d1		;get lower nibble
	add.b	#"0",d1			;convert to ascii
	cmpi.b	#"9",d1			;compare to value below letter
	ble.s	noalter			;branch if ok
	add.b	#39,d1			;else convert to lower case
noalter:	move.b	d1,-(a0)			;stick in string
	ror.l	#4,d0			;rotate to get next nibble
	dbf	d5,hexloop		;dec and continue

************************** raw binary to octal ascii conversion

	move.l	rawbinary,d0		;raw number
	lea	octstring+11,a0		;place for ascii conversion
	moveq.l	#9,d5			;number of times to loop
octloop:	move.b	d0,d1			;get lower 8 bits
	andi.b	#%00000111,d1		;get lower 3 bits
	add.b	#"0",d1			;convert to ascii
	move.b	d1,-(a0)			;stick in string
	ror.l	#3,d0			;rotate to get next nibble
	dbf	d5,octloop		;dec and continue
	move.b	d0,d1			;get lower 8 bits
	andi.b	#%00000011,d1		;get last 2 bits
	add.b	#"0",d1			;convert to ascii
	move.b	d1,-(a0)			;stick in string

*************** change text in string gadgets to reflect new number

changestrings:				;change all the gadget strings
	moveq.l	#GDX_Gadget20*4,d6		;get initial offset
	moveq.l	#3,d7			;no. of times to loop
	pea	octtaglist		;push taglist addresses
	pea	hextaglist		;onto stack
	pea	bintaglist
	pea	dectaglist
textloop:	
	lea	Project0Gadgets,a0
	move.l	0(a0,d6.w),a0		;get gadget pointer
	move.l	Project0Wnd,a1
	sub.l	a2,a2
	move.l	(sp)+,a3			;get taglist pointer
	CALLGAD	GT_SetGadgetAttrsA
	addq.b	#4,d6			;increment offset
	dbf	d7,textloop		;loop d7 times
	rts

****************************************************************************
*           check input string for syntax according to input base
*  inputs-a0 must point to beginning of input string
****************************************************************************
decerrorcheck:
	moveq.l	#9,d7			;depth to search string
	moveq.l	#11,d6			;max number of chars
	bra.s	checkstring
binerrorcheck:
	moveq.l	#1,d7			;depth to search string
	moveq.l	#33,d6			;max number of chars
	bra.s	checkstring
octerrorcheck:
	moveq.l	#7,d7			;depth to search string
	moveq.l	#12,d6			;max number of chars
	bra.s	checkstring
hexerrorcheck:
	moveq.l	#15,d7			;depth to search string
	moveq.l	#9,d6			;max number of chars
checkstring:
	move.l	a0,a3			;save important regs
	lea	(a0,d6.w),a4		;get address of string end
	lea	syntax(pc),a5		;get acceptable char array
matchfnd:	moveq.l	#0,d0			;index into array
	cmpa.l	a0,a4			;test for max string length
	beq.s	nomatch			;branch if passed
	move.b	(a0)+,d2			;get ascii letter
	beq.s	allmatch			;branch if terminator
nextlett:	cmp.b	(a5,d0.w),d2		;compare letters
	beq.s	matchfnd			;branch if match found
	addq.b	#1,d0			;else increment index
	cmp.b	d0,d7			;compare with max depth
	blt.s	nomatch			;and branch if > max depth
	bra.s	nextlett			;else try next letter
nomatch:
	move.l	Scr,a0			;screen handle in a0
	CALLINT	DisplayBeep		;flash screen
	move.l	a3,a0			;restore important regs
	move.l	#sortmsgs0,(sp)		;return address
	rts				;return to msg routine

allmatch:			;arriving here we know that the input string is
			;O.K. for length and contains no illegal chars!
	cmpi.b	#3,inputbase		;is number octal?
	beq.s	testmaxoct		;branch if so
	cmpi.b	#0,inputbase		;is number decimal?
	bne.s	allmatch2			;branch if not

	move.l	a3,a0			;restore string pointer
	moveq.l	#0,d0			;init counter
mxdecloop:tst.b	(a0)+			;test current char
	beq.s	allmatch2			;branch if terminator
	addq.b	#1,d0			;else inc counter
	cmpi.b	#10,d0			;test string length
	beq.s	checkval			;branch to val check if 10
	bra.s	mxdecloop			;else cont loop
checkval:	move.l	a3,a0			;restore string pointer
	lea	maxdec(pc),a1		;pointer to max dec string
valloop:	tst.b	(a0)			;test for terminator
	beq.s	allmatch2			;branch if found
	cmp.b	(a1)+,(a0)+		;compare input with max
	blt.s	allmatch2			;quit check if digit's less
	bgt.s	nomatch			;bra to error rtn if to big
	bra.s	valloop			;else cont loop

testmaxoct:
	move.l	a3,a0			;restore string pointer
	moveq.l	#0,d0			;init counter
mxoctloop:tst.b	(a0)+			;test current char
	beq.s	allmatch2			;branch if terminator
	addq.b	#1,d0			;else inc counter
	cmpi.b	#11,d0			;test string length
	beq.s	chekval			;branch to val check if 10
	bra.s	mxoctloop			;else cont loop
chekval:	cmpi.b	#"3",(a3)			;test for a 3 in high byte
	bgt.s	nomatch			;error if greater than a 3

allmatch2:moveq.l	#0,d2			;clear raw binary var
	moveq.l	#0,d0			;clear scratch reg
	move.l	a3,a0			;restore important regs
	rts				;return to conversion
****************************************************************************
*      display requester with program/author info
****************************************************************************
aboutme:
	move.l	Project0Wnd,a0		;pointer to window
	lea	btext,a1			;pointer to body text
	sub.l	a2,a2			;no pos text
	lea	negtext,a3		;pointer to negative text
	moveq.l	#0,d0			;pos is activated by lmb
	moveq.l	#0,d1			;neg is activated by lmb
	move.l	#350,d2			;width of requester-this is ignored in wb2.0
	moveq.l	#60,d3			;height of requester- "   "    "     "   "
	CALLINT	AutoRequest		;create requester
	bra	sortmsgs0			;back to main
****************************************************************************
*                                Data Area
****************************************************************************

*********************** about requester structures *************************
	even
btext:					;text for body of requester
	dc.b	0,1			;colour
	dc.b	0			;mode
	even
	dc.w	10,10			;text posn
	dc.l	0			;standard font
	dc.l	bodytext			;pointer to text used
	dc.l	btext2			;more text
	even
bodytext:	dc.b	" Base Convertor V1.01  ©1993 Stuart Davis",0	;actual body text
	even
btext2:					;text for body of requester
	dc.b	0,1			;colour
	dc.b	0			;mode
	even
	dc.w	10,25			;text posn
	dc.l	0			;standard font
	dc.l	bodytext2			;pointer to text used
	dc.l	btext3			;more text
	even
bodytext2:dc.b	"          All rights reserved.",0	;actual body text
	even
btext3:					;text for body of requester
	dc.b	0,1			;colour
	dc.b	0			;mode
	even
	dc.w	10,40			;text posn
	dc.l	0			;standard font
	dc.l	bodytext3			;pointer to text used
	dc.l	btext4			;more text
	even
bodytext3:dc.b	"            * SHAREWARE *",0;actual body text
	even
btext4:	
	dc.b	0,1			;colour
	dc.b	0			;mode
	even
	dc.w	10,55			;text posn
	dc.l	0			;standard font
	dc.l	bodytext4			;pointer to text used
	dc.l	0			;no more text
	even
bodytext4:dc.b	"Coded using Devpac V3.04 & GadToolsBox V1.4",0
	even
negtext:
	dc.b	0,1			;colour
	dc.b	0			;mode
	even
	dc.w	5,3			;text posn
	dc.l	0			;standard font
	dc.l	negatext			;pointer to text used
	dc.l	0			;no more text
	even
negatext:	dc.b	"How interesting!",0	;negative text


****************************** Global variables ****************************

	even
rawbinary:dc.l	0			;space for binary input
	even
inputbase:dc.b	0			;input base type
	even
syntax:	dc.b	"0123456789abcdef",0	;acceptable input chars
	even
maxdec:	dc.b	"4294967295",0
	even
table:    dc.l      1000000000,100000000,10000000
	dc.l	1000000,100000,10000,1000,100,10,0
	even
dectaglist:
	dc.l	GTTX_Text
	dc.l	decstring
	dc.l	TAG_DONE
	even
decstring:dc.b	"0000000000",0
	even
bintaglist:
	dc.l	GTTX_Text
	dc.l	binstring
	dc.l	TAG_DONE
	even
binstring:dc.b	"                                    ",0
	even
hextaglist:
	dc.l	GTTX_Text
	dc.l	hexstring
	dc.l	TAG_DONE
	even
hexstring:dc.b	"        ",0
	even
octtaglist:
	dc.l	GTTX_Text
	dc.l	octstring
	dc.l	TAG_DONE
	even
octstring:dc.b	"           ",0

	end
