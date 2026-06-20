 OPT X+,D+,C-,L-,T- ;C a=A d=debuginfo l=link x=extenddebug t=tzpes
********************************************************************************
*********** Author: Conrad Wood                                           ******
*********** Programname:                                                  ******
*********** Date:                                                         ******
*********** Paras:                                                        ******
********************************************************************************

	incdir	ass_incl:
	include	asmtools/asmtools.i

	include	intuition.i
	include	dos.i
	include	dosextens.i
	include	wb.i
	include	macros.i
	include	graphics.i
	include	devices/input.i
	include	util.i
	include	tag.i
	include	AgentGUI/AgentGUI.i
	include	reminder.i
	include	commodity.i
	include	devices/input.i
	include	tcp/amitcp.i

CALLBSD:	macro
	move.l	bsdsocketlib,a6
	cmp.l	#0,a6
	beq.s	lsdff\@
	jsr	\1(a6)
lsdff\@:
	endm

PRINTDEBUG:	macro
	tst.b	debug
	beq	nodebugprint\@
	movem.l	d0-a6,-(sp)
	move.l	d0,-(sp)
	move.l	output,d0
	lea	\1,a0
	CALLASMTOOLS	printstring
	move.l	(sp),d0
	lea	decbuffer,a0
	move.b	#"(",(a0)+
	CALLASMTOOLS	Dec
	move.b	#"=",(a0)+
	move.l	(sp)+,d0
	CALLASMTOOLS	Hex
	move.b	#")",(a0)+
	move.b	#10,(a0)+
	clr.b	(a0)+
	lea	decbuffer,a0
	move.l	output,d0
	CALLASMTOOLS	Printstring
	movem.l	(sp)+,d0-a6
nodebugprint\@:
	endm
;-------------------------------------------------------------------

run:	clr.b	debug
	move.b	#-1,sigbit
	clr.b	docrlf
	clr.b	quietmode
	clr.b	rquiet
	lea	parabuffer,a1
	CALLASMTOOLS	CopyParas

	clr.l	bsdsocketlib
	move.l	#-1,socket
	move.l	#-1,socket2
	move.l	sp,stack
	SETEXIT	out

	OPENDOSLIB

	move.l	4.w,a6
	lea	bsdsocketname,a1
	jsr	-408(a6)
	move.l	d0,bsdsocketlib
	beq	errornotcpip
						;bsdsocketlib opened

decodeparas:						;get host and port
	moveq	#1,d0
	lea	parabuffer,a0
	lea	host,a1
	CALLASMTOOLS	GetStringPart
	tst.l	d0
	beq	missingportpara
	lea	host,a0
	CALLASMTOOLS	AscIIToDec
	tst.l	d1
	beq	missingportpara
	move.w	d0,port


	moveq	#2,d6
donextoption:	move.l	d6,d0
	lea	parabuffer,a0
	lea	decbuffer,a1
	CALLASMTOOLS	GetStringPart
	tst.l	d0
	beq.s	nomoreoptions		;last option has been processed
	lea	paratab,a0
	lea	decbuffer,a1
	CALLASMTOOLS	DecodeText
	cmp.l	#-1,d0
	beq	invalidoptionerr

	cmp.l	#1,d0			;option 1?
	bne.s	notoption1
	move.b	#1,docrlf
	bra.s	donethisoption
notoption1:	cmp.l	#2,d0			;option 2?
	bne.s	notoption2
	move.b	#1,quietmode
	bra.s	donethisoption
notoption2:	cmp.l	#3,d0			;option 3?
	bne.s	notoption3
	move.b	#1,debug
	bra.s	donethisoption
notoption3:	cmp.l	#4,d0			;option 4?
	bne.s	notoption4
	move.b	#1,rquiet
	bra.s	donethisoption
notoption4:

	bra	notyetimploptionerr

donethisoption:	addq.l	#1,d6			;do next option
	bra	donextoption		;and loop until no options left
nomoreoptions:

opensocket:
	move.l	#AF_INET,d0			;domain
	move.l	#SOCK_STREAM,d1		;type
	move.l	#0,d2				;protocol (TCP)
	CALLBSD	_LVOSocket
	move.l	d0,socket			;-> d0^socket
	cmp.l	#-1,d0
	beq	nosocketerr
		

	PRINTDEBUG	GOTSOCKETTXT

	move.l	socket,d0
	lea	sockaddr_in,a0
	move.l	#$01010248,sin_addr(a0)
	move.w	#23,sin_port(a0)
	move.b	#2,sin_family(a0)
	move.l	#sin_size,d1
	CALLBSD	_LVOBind
	cmp.l	#-1,d0
	beq	nobinderr

	PRINTDEBUG	GOTBINDTXT

	move.l	socket,d0
	moveq	#1,d1
	CALLBSD	_LVOListen
	cmp.l	#-1,d0
	beq	nolistenerr

	PRINTDEBUG	GOTlistenTXT

	move.l	socket,d0
	lea	connectorsockaddr,a0
	lea	connectorsinsize,a1
	CALLBSD	_LVOAccept
	move.l	d0,socket2
	cmp.l	#-1,d0
	beq	noaccepterr

	tst.b	quietmode
	bne.s	dontprintconnectmsg
	lea	connectedtxt,a0
	move.l	output,d0
	CALLASMTOOLS	Printstring
dontprintconnectmsg:

	tst.b	rquiet
	bne.s	dontprintremotemsg
	lea	greetingtxt,a0
	move.l	a0,a1
	moveq	#-1,d1
dskjfhglkdjfhglkdjfhg:addq.l	#1,d1
	tst.b	(a1)+
	bne.s	dskjfhglkdjfhglkdjfhg
	move.l	socket2,d0
	moveq	#0,d2
	CALLBSD	_LVOSend
dontprintremotemsg:

	PRINTDEBUG	GOTacceptTXT

	move.l	dosbase,a6
	move.l	#command,d1
	moveq	#0,d2
	moveq	#0,d3
	jsr	_LVOExecute(a6)

	move.l	dosbase,a6
	jsr	_LVOInput(a6)
	move.l	d0,input

	move.l	4.w,a6
	moveq	#-1,d0
	jsr	_LVOAllocSignal(a6)
	move.b	d0,sigbit
	cmp.b	#-1,d0
	beq	nosigbitavail
mainloop:			;check for break
	CHECKBREAK	aborted
receivesomething:



		;initalize for async IO
	lea	putsigbithere,a0
	move.b	sigbit,3(a0)
	lea	socketAsyncIOTags,a0
	CALLBSD	_LVOSocketBaseTagList		;tell amitcp which sigbit to use
	tst.l	d0
	bne	problemsettingsocktags


						;tell amitcp to use a sigbit atall :-)
	
	
	move.l	socket2,d0			;d0^socket
	move.l	#SOL_Socket,d1			;modify at socket level instead of protocol dependent
	move.l	#SO_EventMask,d2		;modify what? (the "eventmask")
	lea	putsigbithere,a0		;^value
	moveq	#4,d3				;^value size (4 = int)
	CALLBSD	_LVOSetSockOpt	
	cmp.l	#-1,d0
	beq	problemsettingsockopts
		; anything from socket??

	lea	mysockevents,a0
	CALLBSD	_LVOGetSocketEvents
	tst.b	debug
	beq.s	dontprintraweventnotification
	move.l	d0,d3
	move.l	mysockevents,d0
	lea	decbuffer,a0
	CALLASMTOOLS	Bin
	move.b	#" ",(a0)+
	move.b	#"(",(a0)+
	move.l	d3,d0
	CALLASMTOOLS	Dec
	move.b	#")",(a0)+
	move.b	#10,(a0)+
	clr.b	(a0)
	lea	decbuffer,a0
	move.l	output,d0
	CALLASMTOOLS	Printstring
dontprintraweventnotification:

	
	move.l	mysockevents,d0
	and.l	#fd_close,d0
	tst.l	d0
	bne	socketisclosedagain

	move.l	mysockevents,d0
	and.l	#fd_read,d0
	tst.l	d0
	beq.s	norecvcurrently

	move.l	socket2,d0
	lea	recbuf,a0
	moveq	#1,d1
	moveq	#0,d2
	CALLBSD	_LVORecv

	lea	decbuffer,a0
	move.b	recbuf,d0
	move.b	d0,(a0)+
	clr.b	(a0)
	lea	decbuffer,a0
	move.l	output,d0
	CALLASMTOOLS	Printstring

norecvcurrently:

writeloop:	move.l	dosbase,a6
	move.l	input,d1
	moveq	#10,d2
	jsr	_LVOWaitForChar(a6)
	tst.l	d0
	beq.s	nodataread
	move.l	input,d1
	move.l	#recbuf,d2
	moveq	#1,d3
	move.l	dosbase,a6
	jsr	_LVORead(a6)
	moveq	#1,d1
	move.l	socket2,d0
	lea	recbuf,a0
	tst.b	docrlf
	beq.s	noaddcrtolf
	cmp.b	#10,(a0)
	bne.s	noaddcrtolf
	moveq	#2,d1
	move.b	#13,(a0)
	move.b	#10,1(a0)	
noaddcrtolf:
	moveq	#0,d2
	CALLBSD	_LVOSend
	bra.s	writeloop
nodataread:
	bra	mainloop

socketisclosedagain:
	tst.b	quietmode
	bne.s	nodisconnectmsg
	lea	disconnectxt,a0
	move.l	output,d0
	CALLASMTOOLS	Printstring
nodisconnectmsg:
	bra	out
;-------------------------------------------------------------------
notyetimploptionerr:	lea	notyetimploptiontxt,a0
	bra	error
invalidoptionerr:	lea	invoptiontxt,a0
	bra	error
problemsettingsocktags:bsr	printsocketerror
	lea	nosocktagserrtxt,a0
	bra.s	error
problemsettingsockopts:bsr	printsocketerror
	lea	nosockopterrtxt,a0
	bra.s	error
nosigbitavail:	lea	nosigbittxt,a0
	bra.s	error
noaccepterr:	bsr	printsocketerror
	lea	noaccepterrtxt,a0
	bra.s	error
nobinderr:	bsr	printsocketerror
	lea	nobindtxt,a0
	bra.s	error
nolistenerr:	lea	nolistentxt,a0
	bra.s	error
aborted:	lea	abortedtxt,a0
	bra.s	error
missingportpara	lea	noporttxt,a0
	bra.s	error
missinghostpara	lea	nohosttxt,a0
	bra.s	error
invalidhosterr:	lea	invalidhosttxt,a0
	bra.s	error
noconnecterr:	bsr	printsocketerror
	lea	noconnecttxt,a0
	bra.s	error
nosocketerr:	bsr	printsocketerror
	lea	nosockettxt,a0
	bra.s	error
errornotcpip:	lea	notcpiptxt,a0
	bra.s	error
	nop
error:	move.l	output,d0
	CALLASMTOOLS	Printstring
	moveq	#10,d0
	bra.s	out_raw
out:	moveq	#0,d0
out_raw:	bsr	closetcpip
	bsr	freesignal
	move.l	stack,sp
	rts

freesignal:	moveq	#0,d0
	move.b	sigbit,d0
	cmp.b	#-1,d0
	beq.s	nosigbittofree
	move.l	4.w,a6
	jsr	_LVOFreeSignal(a6)
nosigbittofree:	move.b	#-1,sigbit
	rts
closetcpip:	lea	socket,a0
	bsr	closesocket
	lea	socket2,a0
	bsr	closesocket

	move.l	bsdsocketlib,a1
	cmp.l	#0,a1
	beq.s	nolibtoclose
	move.l	4.w,a6
	jsr	_LVOCloseLibrary(a6)
	PRINTDEBUG	closedlibTXT
nolibtoclose:	clr.l	bsdsocketlib
	rts



closesocket:	move.l	(a0),d0
	move.l	a0,-(sp)
	cmp.l	#-1,d0
	beq	nosockettoclose
	CALLBSD	_LVOCloseSocket
	cmp.l	#-1,d0
	bne.s	noprobclosingsock
	lea	socknotclosedtxt,a0
	move.l	output,d0
	CALLASMTOOLS	Printstring
noprobclosingsock:	move.l	(sp),a0
	move.l	(a0),d0
	PRINTDEBUG	closedsocketTXT
nosockettoclose:	move.l	(sp),a0
	clr.l	(a0)
	move.l	(sp)+,a0
	rts
;-------------------------------------------------------------------

printsocketerror:					;get socket error code (similar to IOERR of doslib)
	lea	geterrnotaglist,a4
	move.l	a4,a0
	CALLBSD	_LVOSocketBaseTagList
	move.l	4(a4),d0
	lea	decbuffer,a0		;d0^errorcode
	move.l	d0,-(sp)
	CALLASMTOOLS	Dec
	move.b	#"=",(a0)+
	move.l	(sp)+,d0
	CALLASMTOOLS	Hex
	move.b	#10,(a0)+
	clr.b	(a0)
	lea	decbuffer,a0
	move.l	output,d0
	CALLASMTOOLS	Printstring



	move.l	geterrnotaglist+4,d0
	lea	geterrstrtaglist,a4
	move.l	d0,4(a4)
	move.l	a4,a0
	CALLBSD	_LVOSocketBaseTagList
	move.l	4(a4),a0
	move.l	output,d0
	CALLASMTOOLS	Printstring

	lea	decbuffer,a0
	move.b	#10,(a0)
	clr.b	1(a0)
	move.l	output,d0
	CALLASMTOOLS	Printstring
	rts
;-------------------------------------------------------------------
	data
socketAsyncIOTags:	dc.l	SBTCR_SIGEVENTMASK
putsigbithere:	dc.l	1
	dc.l	0,0
geterrnotaglist:	dc.l	SBTCG_ERRNO,16
	dc.l	0,0
geterrstrtaglist:	dc.l	SBTCG_ERRNOSTRPTR,0
	dc.l	0,0

sendbuf:;	dc.b	0
	dc.b	"\0.conrad.users.flat\0",0
	dc.b	".conrad.users.flat\0",0
	dc.b	"VT100/9600\0",0
sendbufsize:	equ	*-sendbuf

paratab:	dc.b	1,"cr",0
	dc.b	2,"quiet",0
	dc.b	3,"debug",0
	dc.b	4,"rquiet",0
	dc.b	0,0
GOTSOCKETTXT:	dc.b	"Verbose: Socket() returned valid socket",0
gotbindtxt:	dc.b	"Verbose: bind() to socket.",0
GOTlistenTXT:	dc.b	"Verbose: listen() returned.",0
GOTacceptTXT:	dc.b	"Verbose: Accept() returned.",0
closedsocketTXT:	dc.b	"Verbose: CloseSocket() done.",0
closedlibTXT:	dc.b	"Verbose: Library closed.",0

connectedtxt:	dc.b	"*** Connected.",10,0
disconnectxt:	dc.b	"*** Disconnected.",10,0

notyetimploptiontxt:	dc.b	"Option not yet implemented.",10,0
invoptiontxt:	dc.b	"invalid option.",10,0
nosocktagserrtxt:	dc.b	"SocketBaseTagList() failed.",10,0
nosockopterrtxt:	dc.b	"SetSockOPT() failed.",10,0
nosigbittxt:	dc.b	"AllocSignal() failed",10,0
noaccepterrtxt:	dc.b	"Accept() failed.",10,0
nobindtxt:	dc.b	"Bind() failed.",10,0
nolistentxt:	dc.b	"Listen() failed",10,0
nohosttxt:	dc.b	"No host specified",10,0
noporttxt:	dc.b	"No destination port specified",10,0
bsdsocketname:	dc.b	"bsdsocket.library",0
notcpiptxt:	dc.b	"Couldn't open tcpip.library",10,0
nosockettxt:	dc.b	"Socket() failed.",10,0
noconnecttxt:	dc.b	"Connect() failed.",10,0
invalidhosttxt:	dc.b	"Invalid host syntax",10,0
socknotclosedtxt:	dc.b	"CloseSocket() failed!",10,0
abortedtxt:	dc.b	10,"*** listenport: aborted.",10,0
command:	dc.b	"sampleplay sound:enterprise/enterprisecalling.iff",0
greetingtxt:	dc.b	"****** YOU ARE CONNECTED TO AGENT ORANGE ****** ",13,10
	dc.b	"This server is powered by",13,10
	dc.b	"Amiga 4000, Hydranet card, 4MB Picasso IV, Cyberstorm 40/40",13,10
	dc.b	"134MB RAM 8GB HD, 4/8GB DAT Tape, 12x CD and",13,10
	dc.b	"AMITCP, assembler telnet server",13,10
	dc.b	"The routing is done by 4 Intranetware 4.11 Servers + Groupwise 5.2",13,10
	dc.b	"configured and coded by Agent Orange in 1996-1998",13,10
	dc.b	13,10
	dc.b	"Now stand by while I'm trying to find my sysop ;-)...",13,10
	dc.b	13,10,0
	bss
mysockevents:	dcb.l	1
input:	dcb.l	1
port:	dcb.w	1
myintadr:	dcb.l	1
sockaddr_in:	dcb.b	SIN_SIZE
socket:	dcb.l	1
socket2:	dcb.l	1	;this one comes from accept()
connectorsockaddr	dcb.l	20
connectorsinsize:	dcb.l	1
stack:	dcb.l	1
bsdsocketlib:	dcb.l	1
decbuffer:	dcb.b	256
host:	dcb.b	100
parabuffer:	dcb.b	256
recbuf:	dcb.b	1000
recbufsize:	EQU	*-recbuf
debug:	dcb.b	1
sigbit:	dcb.b	1
docrlf:	dcb.b	1	;1 if cr added to lf from con
quietmode:	dcb.b	1	;1 if no messages (like connect, disconnect)
rquiet:	dcb.b	1	;1 if no message send to remote
