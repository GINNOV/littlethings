
* AMIGA ----> PC/VAX - BY AXAL

* I don't know if this will be of any use to you's lot
* but I wrote it so I could take Daves docs to college
* and transfer them to the VAX mini-computer and print
* them out using the college printers (and paper and ink!).
* I done this by formating a PC disk using Dos2Dos and
* then running this program on the docs and saving them
* to the PC disk using CrossDos.  This disk was then
* taken to college and copied on to my VAX account cos
* our PC's are linked to the VAX.  I then entered my
* account and sent the stuff to the printer.  If you
* don't convert your docs using this program, it f**ks
* up the output.

* It's simple to use.  When you run it, select convert
* and choose then doc you want to convert.  The screen
* will flash and then you can select where to save it.
* That's it!  Press quit to quit!

;	opt	o+,ow-,d-,c+

	incdir sys:include/
	include exec/exec_lib.i
	include	exec/types.i
	include	source:include/libraries/reqtools.i
	include	source:include/libraries/reqtools_lib.i
	include	source:include/acc_lib.i

CALLREQ		macro
		move.l		_ReqBase,a6
		jsr		_LVO\1(a6)
		endm

*---------------------------------------
* GET MEMORY NEEDED
*---------------------------------------

	lea	ACCLIBNAME(pc),a1	lib to open
	moveq	#0,d0			any version
	CALLEXEC	OpenLibrary		open lib
	move.l	d0,_AccBase		save base
	beq	openerror1		branch if not open

	lea	REQTOOLSNAME(pc),a1	lib to open
	moveq	#0,d0			any version
	CALLEXEC	OpenLibrary		open lib
	move.l	d0,_ReqBase		save base
	beq	openerror2		branch if not open

	moveq.l	#RT_FILEREQ,d0		type of request
	move.l	d0,a0			null taglist
	CALLREQ	rtAllocRequestA		alloc a file request
	move.l	d0,myfilerequest	save my request
	beq	requesterror1		branch if not opened

	moveq.l	#RT_REQINFO,d0		type of request
	move.l	d0,a0			null taglist
	CALLREQ	rtAllocRequestA		alloc a info request
	move.l	d0,myinforequest	save my request
	beq	requesterror2		branch if not opened

*---------------------------------------

main_loop
	lea	mainmenutxt(pc),a1	text to place in requester
	lea	mainmenudat(pc),a2	my gadget list
	bsr	get_request		get a request

	cmpi.w	#1,d0			was it 1
	beq	do_convert		branch if it was
	cmpi.w	#0,d0			was it quit
	bne.s	main_loop		do it all again

*---------------------------------------
* GIVE BACK MEMORY
*---------------------------------------

file_loaderror1
	move.l	myinforequest(pc),a1	get address of my base
	CALLREQ	rtFreeRequest		and free it
requesterror2
	move.l	myfilerequest(pc),a1	get address of my base
	CALLREQ	rtFreeRequest		and free it
requesterror1
	move.l	_ReqBase(pc),a1		lib to close
	CALLEXEC	CloseLibrary		close it
openerror2
	move.l	_AccBase(pc),a1		lib to close
	CALLEXEC	CloseLibrary		close it
openerror1
	rts

*---------------------------------------
do_convert
	bsr	load_a_file		load a file into memory
	tst.l	d0			did file load
	beq	main_loop		quit if did not load

	move.l	file_address(pc),a0	doc to do
	move.l	file_length(pc),d1	many times to do
	moveq	#0,d0			clear counter
.loop0
	move.w	d0,$dff180		show colour
	cmpi.b	#$0a,(a0)+		have we got one?
	bne.s	.no0			branch if not
	addq.l	#1,d0			add 1 to counter
.no0
	subq.l	#1,d1			subtract 1 from counter
	bne.s	.loop0			do all

	add.l	file_length(pc),d0	add on length
	move.l	d0,mem_length		save length
	move.l	#$10001,d1		public memory
	CALLEXEC	AllocMem	get memory
	move.l	d0,mem_address		save address
	beq.s	.error0			branch if no memory

	move.l	d0,a1			where to save
	move.l	file_address(pc),a0	doc to convert
	move.l	file_length(pc),d1	number of bytes
	moveq	#0,d0			clear holder
.loop1
	move.w	d0,$dff180		show colour
	move.b	(a0)+,d0		get new byte
	cmpi.b	#$0a,d0			is it a return
	bne.s	.no1			branch if not
	move.b	#$0d,(a1)+		shift in for pc and vax
.no1
	move.b	d0,(a1)+		save byte
	subq.l	#1,d1			subtract 1 from counter
	bne.s	.loop1			do all

	bsr	save_a_file		save the file

	move.l	mem_length(pc),d0	amount to free
	move.l	mem_address(pc),a1	where to free
	CALLEXEC	FreeMem			free it
.error0
	move.l	file_length(pc),d0	amount to free
	move.l	file_address(pc),a1	where to free
	CALLEXEC	FreeMem			free it
	bra	main_loop		back to menu
*---------------------------------------
load_a_file
	lea	myloadtitle(pc),a3	window title
	bsr	get_file_name		get a file to load
	tst.l	d0			did a file load
	bne.s	.nameok			branch if cancel not pressed
	rts
.nameok
	lea	myfullnamebuff(pc),a0	file to load
	moveq	#1,d0			public memory
	CALLACC	LoadFile		and load the file
	move.l	d0,file_length		save file length
	beq	.file_err1		branch if did not load
	move.l	a0,file_address		address of the file
	moveq.l	#-1,d0			set file loaded
	rts
.file_err1	
	lea	fileloade1txt(pc),a1	text to place in requester
	lea	okdat(pc),a2		my gadget list
	bsr.s	get_request		show text
	bra	load_a_file		do it all again
*---------------------------------------
save_a_file
	lea	mysavetitle(pc),a3	window title
	bsr	get_file_name		get a file to save to
	tst.l	d0			was a file picked
	bne.s	.name_ok		branch if file selected
	rts
.name_ok
	lea	myfullnamebuff(pc),a0	file to save
	move.l	mem_address(pc),a1	buffer address
	move.l	mem_length(pc),d0	length to save
	CALLACC	SaveFile		save the file
	tst.l	d0			has it save
	bne.s	.save_ok		branch if it did
	lea	filesavee1txt(pc),a1	text to show
	lea	okdat(pc),a2		gadget list
	bsr	get_request		show it
.save_ok
	rts
*---------------------------------------

get_request
	move.l	myinforequest(pc),a3	request base
	move.l	#0,a4			null arg array
	move.l	#0,a0			null tag list
	CALLREQ	rtEZRequestA		get request info
	rts

*---------------------------------------
* WINDOW TITLE IN A3

get_file_name
	move.l	myfilerequest(pc),a1	file request base
	lea	myfilenamebuff(pc),a2	buffer for filename
	move.l	#0,a0			null taglist
	CALLREQ	rtFileRequestA		open file selecter
	tst.b	d0			check to see if opened
	beq.s	.nofilerror1		branch if no file picked

	lea	myfullnamebuff(pc),a0	point to buffer for full name
	move.l	myfilerequest(pc),a1	point to file base
	move.l	rtfi_Dir(a1),a1		get dir address
	bsr.s	copytobuffer		copy dir to main buffer

	cmpi.b	#":",-1(a0)		check for root dir
	beq.s	.gf_rootok		branch if there
	move.b	#"/",(a0)+		shift in a slash for dir
.gf_rootok
	lea	myfilenamebuff(pc),a1	poin to  name of file
	bsr.s	copytobuffer		copy filename to main buffer
	move.b	#0,(a0)			null terminater
	moveq	#-1,d0			set file loaded
.nofilerror1
	rts
copytobuffer
	tst.b	(a1)			is it a null byte
	beq.s	ctb_end			branch if it is
	move.b	(a1)+,(a0)+		copy text to buffer
	bra.s	copytobuffer		loop again
ctb_end
	rts

*---------------------------------------

ACCLIBNAME	dc.b	"acc.library",0
		even
REQTOOLSNAME	dc.b	"reqtools.library",0
		even
_AccBase	ds.l	1
_ReqBase	ds.l	1
myfilerequest	ds.l	1
myinforequest	ds.l	1
file_length	ds.l	1
file_address	ds.l	1
mem_length	ds.l	1
mem_address	ds.l	1
myloadtitle	dc.b	"Load a File",0
		even
mysavetitle	dc.b	"Save a File",0
		even
mainmenudat	dc.b	"CONVERT|QUIT",0
		even
fileloade1txt	dc.b	"Could not LOAD file!!!",0
		even
filesavee1txt	dc.b	"Could not SAVE file!!!",0
		even
okdat		dc.b	"OK",0
		even
mainmenutxt
	dc.b	"  AMIGA DOC ---> PC/VAX-11 DOC",10
	dc.b	">------------------------------<",10,0
	even

myfilenamebuff	dcb.b	108
myfullnamebuff	dcb.b	216

		even
		end

