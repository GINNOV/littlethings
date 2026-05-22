****************************************************************************
*   ___
*  /   \    "About Clock" - a clock with a difference!
* |  |  |
* |  |  |   A workbench clock that tells the time in words, like humans do.
* |   \ |
*  \___/    ©1993 Rude Kyd of Phreshers Inc. U.K.    V2.01  9-4-93
*
****************************************************************************


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

CALLUTIL macro
	 move.l	_UtilityBase,a6
	 jsr	_LVO\1(a6)
	 endm

	SECTION	exe,CODE

	include	/easystart.i		;make wbicon-compliant

* constant
timeout	equ	49			;in 50ths of a second
speechbuf	equ	100			;output buffer in bytes

* de-encrypt my name in the about requester
	lea	bodytext,a0
keepgoing:add.b	#10,(a0)+
	tst.b	(a0)
	bne.s	keepgoing
* open icon library
	lea	iconname,a1
	moveq.l	#0,d0
	CALLEXEC	OpenLibrary
	move.l	d0,_IconBase
	beq	goawaynoicon
* open graphics library
	lea	grafname(pc),a1
	moveq.l	#0,d0
	CALLEXEC	OpenLibrary
	move.l	d0,_GfxBase
	beq	goawayfast
* open the intuition library
	lea	intname(pc),a1
	moveq.l	#0,d0			;dont care which version
	CALLEXEC	OpenLibrary
	move.l	d0,_IntuitionBase		;store lib pointer
	beq	goawayclosegraf		;if didnt open
* and open the DOS library
	lea	dosname(pc),a1
	moveq.l	#0,d0
	CALLEXEC	OpenLibrary
	move.l	d0,_DOSBase
	beq	goawaycloseint
* and open the utility library
	lea	utilname(pc),a1
	moveq.l	#36,d0			;release 2 library
	CALLEXEC	OpenLibrary
	move.l	d0,_UtilityBase
* open translator lib
	lea	transname(pc),a1
	moveq.l	#0,d0
	CALLEXEC	OpenLibrary		;open translator library
	move.l	d0,_TranslatorBase		;and save base address
	bne.s	setupnarr			;branch if open
	move.w	#0,speakon		;and ghost menu
	bra.s	devopen			;and skip opening device
* set up i/o area for narrator
setupnarr:lea	talkio(pc),a1		;pointer to I/O area in a1
	move.l	#nwrrep,14(a1)		;enter port address
	move.l	#amaps,48+8(a1)		;pointer to audio mask
	move	#4,48+12(a1)		;number of the mask
	move.l	#speechbuf,36(a1)		;length of the output area
	move	#3,28(a1)			;command:write
	move.l	#outtext,40(a1)		;address of output area
* open narrator device
	moveq.l	#0,d0			;number 0
	moveq.l	#0,d1			;no flags
	lea	nardevice(pc),a0		;pointer to device name
	CALLEXEC	OpenDevice		;do it
	tst.l	d0			;error?
	beq.s	devopen			;branch if no error
	bsr	transerror		;else inform user of error
	move.w	#0,speakon		;and ghost menu

* find out title bar height
devopen:	tst.l	_UtilityBase
	beq.s	testicon
	move.w	#0,a0			;null means default public
	CALLINT	LockPubScreen		;get screen struct address
	tst.l	d0
	beq	closedevice		;0 if unsuccessful
	move.l	d0,a5			;for indirect addressing
	lea	windowdef(pc),a1		;newwindow struct
	move.b	30(a5),7(a1)		;put bar height in win struct
	addq.b	#1,7(a1)			;we need an extra line
	move.w	12(a5),width		;get screen width
	lea	menuitem1(pc),a2
	lea	menuitem2(pc),a3
	move.b	30(a5),11(a2)		;adjust menu item 1.1 height
	move.b	30(a5),11(a3)		;adjust menu item 1.2 height
	move.b	30(a5),7(a3)		;adjust menu item 1.2 posn
	lea	menuitem102(pc),a2
	lea	menuitem202(pc),a3
	move.b	30(a5),11(a2)		;adjust menu item 2.1 height
	move.b	30(a5),11(a3)		;adjust menu item 2.2 height
	move.b	30(a5),7(a3)		;adjust menu item 2.2 posn





****************************************************************************

*                    here we go with the problem!!!!

* you will notice that I test for WB2 and if we are using it then I try to
* use the new functions in DOS.library to get the programs name, otherwise
* I have to use the name of the program hardcoded in. The actual problem
* as a whole stems from here because the rest of the code to check the tool-
* types does actually work if given the correct disk object info to work
* with.

****************************************************************************

* read icon and adjust window posn and/or speech if necessary
testicon:
	tst.l	_UtilityBase		;are we in WB2?
	beq.s	nodecentrom		;branch if not
	CALLDOS	GetProgramDir		;get lock on prg dir in d0
	move.l	d0,d1			;lock pointer for CD
	beq.s	nodecentrom		;branch if from resident
	CALLDOS	CurrentDir		;make locked dir the cd
	move.l	#infoname,d1		;pointer to name buffer
	moveq.l	#30,d2			;length of buffer in bytes
	CALLDOS	GetProgramName		;get our prg name
nodecentrom:
	lea	infoname(pc),a0		;icon name
	CALLICON	GetDiskObject		;get icon
	move.l	d0,icondata		;save pointer to info
	beq	openwin			;quit this if not opened
	move.l	d0,a0
	move.l	54(a0),a0			;pointer to tool types array
	lea	xtype(pc),a1		;x-position tool type
	CALLICON	FindToolType		;see if it's there
	tst.l	d0			;test for pointer
	beq.s	getytype			;skip if not there
	move.l	d0,a0			;pointer to y coord(ascii)
	bsr	asciiconvert		;convert pos to binary
	move.w	width,d1			;get screen width
	subi.w	#30,d1			;allow for initial win size
	cmp.w	d1,d2			;compare with screen width
	bgt.s	getytype			;dont alter win pos if greater
	move.w	d2,xpos			;new window x posn
getytype:
	move.l	icondata,a0
	move.l	54(a0),a0
	lea	ytype(pc),a1
	CALLICON	FindToolType
	tst.l	d0
	beq.s	getspeechtype
	move.l	d0,a0
	bsr	asciiconvert		;convert pos to binary
	cmp.w	#180,d2			;compare with screen bottom
	bgt.s	getspeechtype		;dont alter win pos if greater
	move.w	d2,ypos			;new window y posn

getspeechtype:
	move.l	icondata,a0
	move.l	54(a0),a0
	lea	speechtype(pc),a1
	CALLICON	FindToolType
	tst.l	d0
	beq.s	freedo
	move.l	d0,a0
	lea	speechenable(pc),a1		;compare it with "ON"
	CALLICON	MatchToolValue
	tst.b	d0			;a 0 means it wasn't ON
	beq.s	freedo			;and so ignore next lines
	tst.w	speakon			;test device availability
	beq.s	freedo			;branch if not there
	bset.b	#0,status			;else turn on speech
freedo:
	move.l	icondata,a0
	CALLICON	FreeDiskObject

* open a window next
openwin:	
	tst.l	_UtilityBase		;has it been opened?
	beq.s	makewin			;branch if not	
	move.l	a5,a1			;screen address to unlock
	move.w	#0,a0			;null name
	CALLINT	UnlockPubScreen		;release lock
					;Unlocking the screen here
					;is important because if
					;the OpenWindow call fails
					;then the screen will still
					;have a lock on it?
makewin:	lea	windowdef(pc),a0
	CALLINT	OpenWindow
	move.l	d0,windowptr		;store the pointer
	beq	closedevice		;branch if no window
	move.l	d0,a0			;for indirect addressing
	move.l	wd_UserPort(a0),UserPort	;windows message port
	move.l	wd_RPort(a0),RPort		;save rastport

	move.l	windowptr,a0		;window pointer
	lea	menu(pc),a1		;pointer to menu structure
	CALLINT	SetMenuStrip		;create menu

* now see if a message is waiting for me
mainloop:
	move.l	UserPort,a0		;speedy method of getting userport
	CALLEXEC	GetMsg			;get address of msg
	tst.l	d0
	beq.s	gettime			;branch if no message
	move.l	d0,a0			;msg pointer in a0
	move.l	im_Class(a0),d4		;event description
	move.w	im_Code(a0),d5		;menu number choice
	move.l	d0,a1			;reply to message
	CALLEXEC	ReplyMsg			;thank you intuition

	cmpi.w	#CLOSEWINDOW,d4		;WINDOW CLOSE?
	beq.s	closewindow		;branch if so

	cmpi.w	#MENUPICK,d4		;has menu item been chosen?
	bne.s	gettime			;branch if not

	cmpi.w	#$f800,d5			;was about selected?
	beq	aboutme			;branch if it was
	cmpi.w	#$f820,d5			;was quit selected?
	beq.s	closewindow		;branch if it was
	cmpi.w	#$f801,d5			;was time request selected?
	bne.s	mainloop			;if not, branch
	bsr	sayit			;else say time
	bra.s	mainloop


* no messages waiting, so suspend myself for a short while then
* do it all again......what fun !!!
gettime:	lea	seconds(pc),a0
	lea	micros(pc),a1
	CALLINT	CurrentTime		;get seconds since 1-1-78
	
	move.l	seconds,d0
	lea	clockdata(pc),a0
	tst.l	_UtilityBase		;are we using WB2?
	beq.s	noutil			;branch if we're not
	CALLUTIL	Amiga2Date		;convert to time & date
	bra.s	noconvert
noutil:	bsr	convert			;do it myself-arrgghh!

noconvert:move.l	min,d3			;loads hrs and mins for cmp
	move.l	tempmin,d2		;compare with last hrs/mins
	cmp.l	d2,d3			;have the mins/hrs changed?
	beq.s	waitabit			;branch if not
	bsr	change			;change the window title

waitabit:	moveq.l	#timeout,d1
	CALLDOS	Delay			;non cpu intensive wait
	bra	mainloop

* message was CLOSEWINDOW,
* so we should quit
closewindow:
	move.l	windowptr,a0
	CALLINT	ClearMenuStrip		;do this or it will crash!
	move.l	windowptr,a0
	CALLINT	CloseWindow		;shut window

closedevice:
	tst.w	speakon
	beq.s	goawaycloseall
	lea	talkio(pc),a1
	CALLEXEC	CloseDevice		;close narrator.device

* close utility library
goawaycloseall:
	tst.l	_TranslatorBase
	beq.s	goawaycloseutil
	move.l	_TranslatorBase,a1
	CALLEXEC	CloseLibrary
goawaycloseutil:
	tst.l	_UtilityBase		;this wasn't present at
	beq.s	goawayclosedos		;first and crashed on wb1.3
	move.l	_UtilityBase,a1
	CALLEXEC	CloseLibrary
* close dos library
goawayclosedos:
	move.l	_DOSBase,a1
	CALLEXEC	CloseLibrary
* finished so close Intuition library
goawaycloseint:
	move.l	_IntuitionBase,a1
	CALLEXEC	CloseLibrary
* close graphics library
goawayclosegraf:
	move.l	_GfxBase,a1
	CALLEXEC	CloseLibrary
* close icon library
goawayfast:
	move.l	_IconBase,a1
	CALLEXEC	CloseLibrary
goawaynoicon:
	moveq.l	#0,d0			;error code for DOS
	rts
****************************************************************************
*      display requester with program/author info
****************************************************************************
aboutme:
	move.l	windowptr,a0		;pointer to window
	lea	btext(pc),a1		;pointer to body text
	sub.l	a2,a2			;no pos text
	lea	negtext(pc),a3		;pointer to negative text
	moveq.l	#0,d0			;pos is activated by lmb
	moveq.l	#0,d1			;neg is activated by lmb
	move.l	#335,d2			;width of requester-this is ignored in wb2.0
	moveq.l	#100,d3			;height of requester- "   "    "     "   "
	CALLINT	AutoRequest		;create requester
	bra	mainloop			;back to main
****************************************************************************
*      display requester telling lack of translator device
****************************************************************************
transerror:
	sub.l	a0,a0			;pointer to window
	lea	transbtext(pc),a1		;pointer to body text
	sub.l	a2,a2			;no pos text
	lea	transnegtext(pc),a3		;pointer to negative text
	moveq.l	#0,d0			;pos is activated by lmb
	moveq.l	#0,d1			;neg is activated by lmb
	move.l	#320,d2			;width of requester-this is ignored in wb2.0
	moveq.l	#60,d3			;height of requester- "   "    "     "   "
	CALLINT	AutoRequest		;create requester
	rts

****************************************************************************
*               convert seconds from 1-1-78 to sec,min,hours
*    seconds are in d0.l
*    clockdata struct pointer is in a0
****************************************************************************
convert:
	subi.l	#473385600,d0		;get rid of years 78-92
days:	cmpi.l	#86400,d0			;get rid of days
	blt.s	ganja
	subi.l	#86400,d0			;d0 contains secs for today
	bra.s	days

ganja:					;©Labels Unlimited!?
	moveq.l	#0,d1			;compare counter
	moveq.l	#0,d2			;hours
	moveq.l	#0,d3			;mins
	moveq.l	#0,d4			;secs
def:	addi.l	#3600,d1
	addq.b	#1,d2
	cmp.l	d0,d1
	bgt.s	fbi
	bra.s	def

fbi:	subi.w	#3600,d1			;get actual hours in scs
	subq.b	#1,d2			;get real hours
joint:	addi.w	#60,d1
	addq.b	#1,d3
	cmp.l	d0,d1
	bgt.s	scs
	bra.s	joint
	
scs:	subi.w	#60,d1			;get actual mins in secs
	subq.b	#1,d3			;get real mins
spliff:	addq.w	#1,d1
	addq.b	#1,d4
	cmp.l	d0,d1
	bgt.s	done
	bra.s	spliff

done:	subq.b	#1,d4			;get real secs
	move.w	d4,(a0)			;secs
	move.w	d3,2(a0)			;mins
	move.w	d2,4(a0)			;hours
	
	rts

****************************************************************************
*                     change the window title string
****************************************************************************
change:
	move.w	#5,count			;reset counter
	move.b	#1,oclockflag		;reset flag to have o'clock

	moveq.l	#0,d0			;clear because convert
	moveq.l	#0,d1			;routine messes them up
	move.l	min,tempmin		;save new minutes
	lea	windowtitle+4(pc),a4	;point to start insertion

	move.w	min,d1			;minutes
	moveq.w	#5,d0			;to divide by
	divu	d0,d1			;see if minutes are *5
	swap	d1			;get remainder in low bits
	tst.w	d1			;see if a remainder exists
	beq.s	mints			;if not,ignore this bit
	cmpi.w	#3,d1			;see how it compares to 3
	blt.s	jg			;branch if 1-2 minutes past
	lea	nearly(pc),a5		;string to insert
	bsr	insert			;stick it in
	bra.s	mints			;skip next bit
jg:	lea	justgone(pc),a5		;string to insert
	bsr	insert			;stick it in

mints:					;how many minutes?
	cmpi.w	#57,min			;see if near the hour
	bgt	compen			;if so,go straight to hr
	swap	d1			;get quotient in d1
	moveq.w	#5,d2			;to multiply by
	mulu	d1,d2			;minutes in d2 as *5
	swap	d1			;get remainder in low bits
	cmpi.w	#3,d1			;see how it compares to 3
	blt.s	insmins			;branch if within 2 mins
	addq.w	#5,d2			;else get next 5th minute
insmins:
	cmpi.w	#3,d2			;is it just past the hour?
	blt	compen
	move.b	#0,oclockflag		;set flag for no o'clock
	cmpi.w	#5,d2			;5 mins?
	beq.s	yesf
	cmpi.w	#55,d2
	bne.s	t
yesf:	lea	five(pc),a5
	bsr	insert
	bra.s	tp
t:	cmpi.w	#10,d2			;10 mins?
	beq.s	yest
	cmpi.w	#50,d2
	bne.s	f
yest:	lea	ten(pc),a5
	bsr	insert
	bra.s	tp
f:	cmpi.w	#15,d2			;15 mins?
	beq.s	yesfi
	cmpi.w	#45,d2
	bne.s	tw
yesfi:	lea	quarter(pc),a5
	bsr	insert
	bra.s	tp
tw:	cmpi.w	#20,d2			;20 mins?
	beq.s	yestw
	cmpi.w	#40,d2
	bne.s	tf
yestw:	lea	twentym(pc),a5
	bsr	insert
	bra.s	tp
tf:	cmpi.w	#25,d2			;25 mins?
	beq.s	yestf
	cmpi.w	#35,d2
	bne.s	ha
yestf:	lea	twentyfivem(pc),a5
	bsr	insert
	bra.s	tp
ha:	lea	half(pc),a5		;it must be 30 mins!
	bsr	insert

tp:					;to or past the hour
	cmpi.w	#0,min
	beq.s	hr
	cmpi.w	#33,min
	blt.s	pa
	lea	to(pc),a5
	bsr	insert
compen:	cmpi.w	#33,min
	blt.s	hr
	addq.w	#1,hour			;compensate for next hour
	bra.s	hr
pa:	lea	past(pc),a5
	bsr	insert

hr:					;the hour in question
	
	move.w	hour,d0
	cmpi.w	#12,d0			;is it PM?
	blt.s	am			;branch if not
	sub.w	#12,d0			;make it 12-hour clock
	cmpi.w	#0,d0			;is it midnight?
	bne.s	am			;branch if not
	lea	midday(pc),a5
	bsr	insert
	move.b	#0,oclockflag		;set flag for no o'clock
	bra	oclock
am:	cmpi.w	#1,d0			;1 o'clock
	bne.s	h2
	lea	one(pc),a5
	bsr	insert
	bra	oclock
h2:	cmpi.w	#2,d0			;2 o'clock
	bne.s	h3
	lea	two(pc),a5
	bsr	insert
	bra	oclock	
h3:	cmpi.w	#3,d0			;3 o'clock
	bne.s	h4
	lea	three(pc),a5
	bsr	insert
	bra	oclock	
h4:	cmpi.w	#4,d0			;4 o'clock
	bne.s	h5
	lea	four(pc),a5
	bsr	insert
	bra	oclock	
h5:	cmpi.w	#5,d0			;5 o'clock
	bne.s	h6
	lea	five(pc),a5
	bsr	insert
	bra.s	oclock	
h6:	cmpi.w	#6,d0			;6 o'clock
	bne.s	h7
	lea	six(pc),a5
	bsr	insert
	bra.s	oclock	
h7:	cmpi.w	#7,d0			;7 o'clock
	bne.s	h8
	lea	seven(pc),a5
	bsr	insert
	bra.s	oclock	
h8:	cmpi.w	#8,d0			;8 o'clock
	bne.s	h9
	lea	eight(pc),a5
	bsr	insert
	bra.s	oclock	
h9:	cmpi.w	#9,d0			;9 o'clock
	bne.s	h10
	lea	nine(pc),a5
	bsr	insert
	bra.s	oclock	
h10:	cmpi.w	#10,d0			;10 o'clock
	bne.s	h11
	lea	ten(pc),a5
	bsr	insert
	bra.s	oclock	
h11:	cmpi.w	#11,d0			;11 o'clock
	bne.s	h12
	lea	eleven(pc),a5
	bsr	insert
	bra.s	oclock	
h12:	lea	midnight(pc),a5		;it must be midnight
	bsr	insert
	move.b	#0,oclockflag		;set flag for no o'clock

oclock:	tst.b	oclockflag		;test for o'clock req
	beq.s	nochange			;branch if not needed
	lea	oclk(pc),a5		;otherwise stick o'clock in
	bsr	insert
	
nochange:
	move.w	count,d0
	cmp.w	oldcount,d0		;check if different to
	beq	nodiff			;last time

	move.b	#0,(a4)			;terminate string
	bsr	resize			;change window size
	move.l	windowptr,a0		;window pointer
	lea	windowtitle(pc),a1		;point to title string
	move.w	#-1,a2			;pointer to screen title
	CALLINT	SetWindowTitles		;do it

* test if speech needed

	btst.b	#0,status			;test flag bit in struct
	beq.s	nodiff			;branch if not set
	
* translate the text into a form that the computer can use

sayit:					;have the text said
	lea	windowtitle(pc),a0		;address of the text
	move.l	count,d0			;length of the text
	lea	outtext(pc),a1		;address of output area
	moveq.l	#speechbuf,d1		;length of output area
	CALLTRANS	Translate
	tst.l	d0			;was it successful?
	bne.s	emptybuff			;branch if not

* speech output

	lea	talkio(pc),a1		;address of i/o structure
	move.l	#speechbuf,36(a1)		;length of output area
	CALLEXEC	SendIO			;start speech output
	
	move.l	#200,d1			;allow time for speech!
	CALLDOS	Delay
	
	lea	talkio(pc),a1		;pointer to io area
	CALLEXEC	AbortIO
	
emptybuff:lea	outtext(pc),a0		;clear output buffer to
	moveq.l	#speechbuf-1,d0		;prevent garbage from being
clrloop:	move.b	#0,(a0)+			;said later on.
	dbf	d0,clrloop

nodiff:	move.w	count,oldcount		;save last count
	rts
****************************************************************************
*                      Insert String Subroutine
* - a4 holds address to start inserting string.
* - a5 holds address of 'C' formatted string to insert(i.e. null terminated)
**************************************************************************** 
insert:
	tst.b	(a5)			;test that letter is valid
	beq.s	noinsert			;branch if equal to 0
	move.b	(a5)+,(a4)+		;copy & increment pointers
	addq.w	#1,count			;increment counter
	bra.s	insert			;do it again
noinsert:
	rts				;no more to do
****************************************************************************
*              resize the window according to string length
****************************************************************************
resize:
	move.l	RPort,a1
	lea	windowtitle(pc),a0
	move.w	count,d0
	CALLGRAF	TextLength		;puts text length in d0
	add.l	#59,d0			;add on gadgets width
	tst.l	_UtilityBase
	bne.s	notwb2
	add.l	#20,d0			;needed for wb1.3's two gadgets
notwb2:	
	move.l	d0,-(SP)			;save new width
	move.l	windowptr,a0		;get window structure
	moveq.l	#0,d2
	move.w	4(a0),d2			;get left edge of window
	add.w	d0,d2			;get new right edge of window
	cmp.w	width,d2			;is right edge off screen?
	ble.s	nomove			;branch if not
	sub.w	width,d2			;get amount off-screen
	neg.w	d2			;make it a leftwards displacement
	move.l	d2,d0			;put x-displacement in d0
	moveq.l	#0,d1			;put y-displacement in d1
	CALLINT	MoveWindow		;do it

nomove:	move.l	(SP)+,d0			;restore new width
	move.l	windowptr,a0
	sub.w	8(a0),d0			;get x-offset from current x-coord
	moveq.l	#0,d1			;y-offset
	move.l	windowptr,a0
	CALLINT	SizeWindow
	rts
****************************************************************************
*               convert ascii number string to binary
* inputs  - a0 points to beginning of null terminated string
* outputs - d2.w contains real value of ascii string
* effects - destroys d1.b, d2.w, d3.w, d4.w, a0
****************************************************************************
asciiconvert:
	ori.b	#255,d1			;counter for no. of digits
trynext:	tst.b	(a0)+			;is this a terminator char?
	beq.s	notascii			;no it's not
	addq.b	#1,d1			;increment counter
	bra.s	trynext			;and test next char
notascii:	moveq.w	#0,d2			;clear reg to hold posn
	moveq.w	#1,d3			;value to mulu ascii by
	moveq.w	#0,d4			;temp storage area
	suba.w	#2,a0			;point to end of string
asciiloop:move.b	(a0),d4			;put in temp reg
	subi.b	#$30,d4			;convert to raw
	mulu.w	d3,d4			;get real value of digit
	add.w	d4,d2			;and put in posn reg
	subq.l	#1,a0			;point to next ascii letter
	mulu.w	#10,d3			;increment mulu value
	dbf	d1,asciiloop		;loop until no more chars
	rts
****************************************************************************
*             data definition section
****************************************************************************
	even
windowdef:
xpos:	dc.w	0			;x posn
ypos:	dc.w	0			;y posn
	dc.w	30,10			;initial width,height
	dc.b	-1,-1			;default pens
	dc.l	MENUPICK!CLOSEWINDOW	;easy IDCMP flag
	dc.l	WINDOWDEPTH!WINDOWCLOSE!SMART_REFRESH!WINDOWDRAG
	dc.l	0			;no gadgets
	dc.l	0			;no checkmarks
	dc.l	windowtitle		;title of window
	dc.l	0			;no screen
	dc.l	0			;no bitmap
	dc.w	0,0,0,0			;min/max size-irrelevant as no sizing gadget
	dc.w	WBENCHSCREEN		;in workbench

************************** speech stuff data ***********************

nardevice:
	dc.b	"narrator.device",0	
	even
amaps:	dc.b	3,5,10,12
	even
talkio:	dcb.l	20,0
nwrrep:	dcb.l	8,0
	even
outtext:	dcb.b	speechbuf,0		;buffer for translated text

************************* structures for menu-so much for so little!


	even
menu:					;menu structure
	dc.l	menu02			;pointer to next menu
	dc.w	0,0			;menu x,y position
menwid:	dc.w	100			;width of title-default
	dc.w	10			;height of title-default
	dc.w	MENUENABLED		;mode bits
	dc.l	menutext			;pointer to menu text
	dc.l	menuitem1			;pointer to menu item 1
	dc.w	0,0,0,0			;for internal functions
	even
menutext:	dc.b	"Project",0		;menu title text
	even
menuitem1:				;submenu structure
	dc.l	menuitem2			;pointer to next entry
	dc.w	0,0			;x,y position
	dc.w	120			;width in pixels
	dc.w	10			;height in pixels
	dc.w	COMMSEQ!ITEMTEXT!ITEMENABLED!HIGHCOMP	;mode bits
	dc.l	0			;affect another item
	dc.l	menu1			;pointer to text
	dc.l	0			;no drawing when clicked
	dc.b	"A"			;choose using <Amiga><A>
	even
	dc.l	0			;no submenu
	dc.l	0			;intuition multiple choice
	even
menu1:					;intuitext struct
	dc.b	0,1			;front/back pen
	dc.b	1			;drawing mode-JAM1
	even
	dc.w	0,0			;left edge/top edge
	dc.l	0			;pointer to font-default
	dc.l	menu1text			;pointer to actual text
	dc.l	0			;pointer to next text
	even
menu1text:dc.b	"About...",0		;first item
	even
menuitem2:
	dc.l	0			;pointer to next entry
	dc.w	0,10			;x,y position
	dc.w	120			;width in pixels
	dc.w	10			;height in pixels
	dc.w	COMMSEQ!ITEMTEXT!ITEMENABLED!HIGHCOMP	;mode bits
	dc.l	0			;affect another item
	dc.l	menu2			;pointer to text
	dc.l	0			;no drawing when clicked
	dc.b	"Q"			;choose using <Amiga><Q>
	even
	dc.l	0			;no submenu
	dc.l	0			;intuition multiple choice
	even
menu2:
	dc.b	0,1			;front/back pen
	dc.b	1			;drawing mode
	even
	dc.w	0,0			;left edge/top edge
	dc.l	0			;pointer to font
	dc.l	menu2text			;pointer to actual text
	dc.l	0			;pointer to next text
	even
menu2text:dc.b	"Quit",0			;last item

************* second menu ***************************************

	even
menu02:					;menu structure
	dc.l	0			;pointer to next menu
	dc.w	110,0			;menu x,y position
menwid02:	dc.w	100			;width of title-default
	dc.w	10			;height of title-default
speakon:	dc.w	MENUENABLED		;mode bits-default=1
	dc.l	menutext02		;pointer to menu text
	dc.l	menuitem102		;pointer to menu item 1
	dc.w	0,0,0,0			;for internal functions
	even
menutext02:
	dc.b	"Speech",0		;menu title text
	even
menuitem102:				;submenu structure
	dc.l	menuitem202		;pointer to next entry
	dc.w	0,0			;x,y position
	dc.w	140			;width in pixels
	dc.w	10			;height in pixels
	dc.w	COMMSEQ!ITEMTEXT!ITEMENABLED!HIGHCOMP	;mode bits
	dc.l	0			;affect another item
	dc.l	menu102			;pointer to text
	dc.l	0			;no drawing when clicked
	dc.b	"T"			;choose using <Amiga><A>
	even
	dc.l	0			;no submenu
	dc.l	0			;intuition multiple choice
	even
menu102:					;intuitext struct
	dc.b	0,1			;front/back pen
	dc.b	1			;drawing mode-JAM1
	even
	dc.w	0,0			;left edge/top edge
	dc.l	0			;pointer to font-default
	dc.l	menu1text02		;pointer to actual text
	dc.l	0			;pointer to next text
	even
menu1text02:
	dc.b	"Time?...",0		;first item
	even
menuitem202:
	dc.l	0			;pointer to next entry
	dc.w	0,10			;x,y position
	dc.w	140			;width in pixels
	dc.w	10			;height in pixels
status:	dc.w	COMMSEQ!ITEMTEXT!ITEMENABLED!HIGHCOMP!CHECKIT!MENUTOGGLE
	dc.l	0			;affect another item
	dc.l	menu202			;pointer to text
	dc.l	0			;no drawing when clicked
	dc.b	"S"			;choose using <Amiga><Q>
	even
	dc.l	0			;no submenu
	dc.l	0			;intuition multiple choice
	even
menu202:
	dc.b	0,1			;front/back pen
	dc.b	1			;drawing mode
	even
	dc.w	0,0			;left edge/top edge
	dc.l	0			;pointer to font
	dc.l	menu2text02		;pointer to actual text
	dc.l	0			;pointer to next text
	even
menu2text02:
	dc.b	"   Speech",0		;last item

************ structures for requester used when about is selected ******
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
bodytext:	dc.b	55,88,101,107,106,57,98,101,89,97,22,76,40,36,38,39
		;A  b   o  u   t   C  l  o   c  k     V  2  .  0  1
	dc.b	22,22,159,39,47,47,41,22,73,106,107,87,104,106,22
	          ;      ©   1  9  9  3     S  t   u   a  r   t    
	dc.b	58,87,108,95,105,0
		;D  a  v   i  s",0-actual body text

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
bodytext2:dc.b	"        All rights reserved.",0	;actual body text
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
bodytext3:dc.b	"         *SHAREWARE*",0	;actual body text
	even
btext4:	
	dc.b	0,1			;colour
	dc.b	0			;mode
	even
	dc.w	10,50			;text posn
	dc.l	0			;standard font
	dc.l	bodytext4			;pointer to text used
	dc.l	0			;no more text
	even
bodytext4:dc.b	"     Coded using Devpac V3.04",0
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


************ structures for requester used when trans.device error *******

	even
transbtext:				;text for body of requester
	dc.b	0,1			;colour
	dc.b	0			;mode
	even
	dc.w	10,10			;text posn
	dc.l	0			;standard font
	dc.l	transbodytext		;pointer to text used
	dc.l	0			;no more text
	even
transbodytext:
	dc.b	"Required files missing-see docs!",0	;actual body text
	even
transnegtext:
	dc.b	0,1			;colour
	dc.b	0			;mode
	even
	dc.w	5,3			;text posn
	dc.l	0			;standard font
	dc.l	transnegatext		;pointer to text used
	dc.l	0			;no more text
	even
transnegatext:
	dc.b	"I'll do that!",0		;negative text

	even
clockdata:
sec:	dc.w	0			;seconds
min:	dc.w	0			;minutes
hour:	dc.w	0			;hours
mday:	dc.w	0			;day of the month
month:	dc.w	0			;month of the year
year:	dc.w	0			;year
wday:	dc.w	0			;weekday 0-6(0=sun)

* strings here
	even
intname	INTNAME				;name of intuition lib
	even
dosname	DOSNAME				;name of dos library
	even
utilname	UTILITYNAME				;name of utility library
	even
grafname	GRAFNAME				;name of graphics library
	even
transname	TRANSNAME				;name of translator library
	even
iconname	ICONNAME				;name of icon library
	even
infoname:	dc.b	"AboutClock",0,"                   ",0
	even
xtype:	dc.b	"POSX",0
	even
ytype:	dc.b	"POSY",0
	even
speechtype:
	dc.b	"SPEECH",0
	even
speechenable:
	dc.b	"ON",0

	even
windowtitle:
	dc.b	"It's                                    ",0
one:	dc.b	" one",0
two:	dc.b	" two",0
three:	dc.b	" three",0
four:	dc.b	" four",0
five:	dc.b	" five",0
six:	dc.b	" six",0
seven:	dc.b	" seven",0
eight:	dc.b	" eight",0
nine:	dc.b	" nine",0
ten:	dc.b	" ten",0
eleven:	dc.b	" eleven",0
midday:	dc.b	" midday",0
midnight:	dc.b	" midnight",0
twentym:	dc.b	" twenty",0
twentyfivem:dc.b	" twenty-five",0
quarter:	dc.b	" quarter",0
half:	dc.b	" half",0
nearly:	dc.b	" nearly",0
justgone:	dc.b	" just gone",0
justpast:	dc.b	" just past",0
past:	dc.b	" past",0
to:	dc.b	" to",0
oclk:	dc.b	" o'clock",0
* variables here
	even
_IntuitionBase:
	dc.l	0			;for int library
_DOSBase:	dc.l	0			;for dos library
_UtilityBase:
	dc.l	0			;for utility library
_GfxBase:	dc.l	0			;for graphics library
_TranslatorBase:
	dc.l	0			;for translator library
_IconBase:dc.l	0			;for icon library
icondata:	dc.l	0			;pointer to icon info
windowptr:dc.l	0			;for window ptr
UserPort:	dc.l	0			;for user port
RPort:	dc.l	0			;for rastport
seconds:	dc.l	0			;save seconds
micros:	dc.l	0			;save micros
tempmin:	dc.l	$FFFFFFFF			;temp to holding last mins
count:	dc.w	5			;used to help erase old
oldcount:	dc.w	0			;used for cmp with count
width:	dc.w	640			;for saving screen width
oclockflag:
	dc.b	0			;o'clock flag-0=no o'clock

	end
