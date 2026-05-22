; xList.s v1.05 (23.10.95) revision 100
; Needs OS v37+ (or v39? not tested on v37)
; freely distributable,modifiable,trashable ==> adapt it to your needs !
; Recently written parts are not commented, it is total disorder !
; (but label names can be helpful)
	incdir	raminclude:
	include	"dos/dos.i"
	include	dos/var.i
	include	lvo/lvos.i ; all the _LVO equates
	include	exec/types.i
CALL	MACRO
	jsr	_LVO\1(a6)
	ENDM
JUMP	MACRO
	jmp	_LVO\1(a6)
	ENDM
OPLIB	MACRO ; OPLIB	label,version
	lea	\1,a1
	moveq	#\2,d0
	CALL	OpenLibrary
	ENDM
OPEN	MACRO ; OPEN	label,mode
	lea	\1,a0
	move.l	a0,d1
	move.l	#\2,d2
	CALL	Open
	ENDM
; kind of XpkHeader structure
      STRUCTURE XpkHeader,0
         ULONG xh_Reco  ;0 usually 'XPKF'
         ULONG xh_CLen  ;4 Crunched size
         ULONG xh_Type  ;8 sublibrary (NUKE,SQSH,...)
         ULONG xh_ULen  ;12 Uncrunched size
         UBYTE xh_Sample ;16 (1st char of 16 bytes of the uncrunched file)
         LABEL xheadlen ; old lenght of infos to be read (now read more datas)
; the Stonecracker Header
      STRUCTURE StcHeader,0
         ULONG stc_Version   ; only test 'S404'
         ULONG stc_SecurLen
         ULONG stc_UnpackLen
         ULONG stc_CrunchLen
         LABEL dummysize1
; the Crunchmania Header
      STRUCTURE CrmHeader,0
         ULONG crm_Version
         UWORD crm_Check
         ULONG crm_UnpackLen
         ULONG crm_CrunchLen
         LABEL dummysize2
; the Lha header
      STRUCTURE LhaHeader,0
         UWORD lha_garbage ;0 dunno what is it
         UBYTE lha_id0 ;2  '-'
         UWORD lha_id1 ;3 'lh'
         UWORD lha_id2 ;5 'n-' 0<=n<=5
         UBYTE lha_clen3 ;7 lenghts inverted. dunno why...
         UBYTE lha_clen2 ;8
         UBYTE lha_clen1 ;9
         UBYTE lha_clen0 ;10
         UBYTE lha_ulen3 ;11
         UBYTE lha_ulen2 ;12
         UBYTE lha_ulen1 ;13
         UBYTE lha_ulen0 ;14
         ULONG lha_chksum ;15 perhaps checksum? dunno
         UWORD lha_chksum2 ;19 =$2001 if done with lha on Unix
         UBYTE lha_namesize ;21 lenght of filename - last byte useful for lha
         UBYTE lha_char1 ;22 first char of filename
         UBYTE lha_char2 ;23
         ULONG lha_chars3 ;24 dummy ulongs...
         ULONG lha_chars4 ;28
         LABEL lha_size ;32 the new lenght of data - useful for XPK (modname)
;A3-relative table offsets
      STRUCTURE Variables,0
         ULONG args_result ; null offset removed (optimisation)
         ULONG pplast
         ULONG headbuf
         ULONG Packlib
         ULONG strloc
         ULONG oldlock
         ULONG strloc2
         ULONG utot
         ULONG dirs ; DIRS/M
         ULONG switch1 ; IT=INTROTEXT/K
         ULONG switch2 ; NT=NOTOTALS/S
         ULONG switch3 ; TR=TESTRIPP/S
         ULONG switch4 ; TD=TESTDURATION/S
         ULONG switch5 ; ET=ENDTEXT/K
         ULONG switch6 ; NOSORT/S
         ULONG switch7 ; NH=NOHEADER/S
         ULONG switch8 ; FO=FILESONLY/S
         ULONG switch9 ; FP=FULLPATH/S
         ULONG switch10 ; H2=HEADER2/S
         ULONG switch11 ; LF/N/K
         ULONG switch12 ; DL=DRAWLIMITS/S
         ULONG switch13 ; COF=COUNTONLYFILES/S
         ULONG switch14 ; SN=SONGNAME/S
         ULONG switch15 ; SU=SHOWULEN/S
         ULONG switch16 ; LA=LINEASPECT/K
         ULONG reserved ; not used yet - for recursivity
         ULONG numfiles
         ULONG numdirs
         ULONG ctot
         ULONG itfh
         ULONG itlock
         ULONG itsize
         ULONG itbuffer
         ULONG tmpfh
         ULONG tmpnameptr
         ULONG fh
         ULONG ofh
         ULONG seglist
         ULONG varfh
         ULONG sumvarbuff
         ULONG longsum
         ULONG numfiles_buffer
         ULONG tmp_lhsize
         ULONG lh_utot
         ULONG delim_strptr
         ULONG ext_linea
          BOOL entrytype
         UWORD spcecnt
          BOOL tmpdeleted
          BOOL atleastone
          BOOL sortflag
          BOOL onlydirs ; 0=dirs \ 1=files+dirs
          BOOL namegiv_bool
          BOOL xpked
         LABEL vars_sizeof ; total size of the array above
;output string structures
      STRUCTURE FileDatas,0
         ULONG Str_File ; filename (null offset)
         ULONG Dec_ULen ; unpacked
         ULONG Dec_CLen ; packed
         ULONG Str_Type ; compression format
         ULONG Dec_Ratio ; compression ratio
         ULONG Str_Comment ; file comments
         LABEL strlen ; max lenght for the output string above
      STRUCTURE Totals,0
         ULONG Tot_numf
         ULONG Tot_utot2
         ULONG Tot_ctot2
         ULONG Tot_ratio
         LABEL Tot_strlen2
numfbuff = 16
tot2 = (vars_sizeof+fib_SIZEOF+lha_size+strlen)
totalbuffer  = (tot2+Tot_strlen2+numfbuff)
VARSIZE		equ	8
FILE		equ	1
;reg. usage
; a6=mainly dosbase ;a5=args ;a4=utilitybase ;a3=membase (and dosbase)
; a2=output buffer ; d7=filehandle ; d6=lock ; d5=filename ; d4=fib


	section	xlist,code
init__
	move.l	4.w,a6
	OPLIB	dosname(pc),36
	move.l	d0,a5 ; 		a5= temp dosbase
	bne.s	allocmem

	moveq	#122,d0 ; invalid resident library
	rts


allocmem	; only one alloc for the 4 arrays
	move.l	#totalbuffer,d0
	move.l	#$10001,d1 ; (MEMF_PUBLIC!MEMF_CLEAR)
	CALL	AllocVec
	move.l	d0,a3 ; d0 will contain the start location of each array
	beq	close_dos

	; for the FileInfoBlock d0=location
	add.l	#vars_sizeof,d0 ; Fib goes after main vars data
	move.l	d0,d4 ;			d4=Fib (FileInfoBlock)

	; for the XpkHeader
	add.l	#fib_SIZEOF,d0 ; Readbuffer goes after Fib
	move.l	d0,headbuf(a3)

	; for our output buffer
	add.l	#lha_size,d0 ; last but not least the output buffer
	move.l	d0,a2 ; 		a2=output buffer

	add.l	#strlen,d0
	move.l	d0,strloc2(a3)

	add.l	#Tot_strlen2,d0
	move.l	d0,numfiles_buffer(a3)

open_utility
	OPLIB	uname(pc),36
	move.l	a5,a6 ; 		now a6=dosbase until exit
	move.l	d0,a4 ; a4=utilitybase
	beq	free_mem

	CALL	Output
	move.l	d0,ofh(a3)

readargs
	lea	args_template(pc),a0
	move.l	a0,d1
	lea	dirs(a3),a0
	move.l	a0,d2
	moveq	#0,d3
	CALL	ReadArgs
	move.l	d0,(a3) ; =0(a3)=args_result(a3)
	not.l	switch10(a3) ; Finally H2 becomes the def output !

	lea	delim(pc),a0
	move.l	a0,delim_strptr(a3)
	move.b	#0,ext_linea(a3)
	move.l	switch16(a3),a0
	tst.b	(a0)
	beq	test_tr

	move.l	a0,delim_strptr(a3)
	move.b	#1,ext_linea(a3)

test_tr
	tst.l	switch3(a3) ; TESTRIPP
	beq	test_td
	lea	tr.msg(pc),a0
	move.l	a0,d1
	CALL	PutStr
test_td
	tst.l	switch4(a3) ; TESTDURATION
	beq	test_sw1
	lea	td.msg(pc),a0
	move.l	a0,d1
	CALL	PutStr

test_sw1
	move.l	switch1(a3),d1 ; INTROTEXT
	beq	testsort1

	bsr	type ; write your intro text

testsort1
	tst.l	switch6(a3) ; NOSORT
	bne	giveargs


findseg ; if Sort is not yet resident
	lea	segname(pc),a0
	move.l	a0,d1
	moveq	#0,d2
	moveq	#0,d3
	CALL	FindSegment ; is Sort already resident ?
	tst.l	d0
	bne	giveargs ; yep, exit

	lea	cmdname(pc),a0
	move.l	a0,d1
	CALL	LoadSeg ; load code from c:Sort
	tst.l	d0
	bne	sortloaded

	move.l	#1,switch6(a3) ; unable to load c:Sort, activating NOSORT
	bra.s	giveargs

sortloaded
	move.l	d0,d2
	lea	segname(pc),a0
	move.l	a0,d1
	moveq	#1,d3
	CALL	AddSegment ; make it resident

giveargs
	move.l	dirs(a3),a0
	move.l	a0,a5 ; save dirs array
	move.l	(a5)+,d1 ; if a5 is null, no arg -> current dir is locked
	bne.s	lockfile ; branch if args

	move.l	d1,-(a5) ; if no arg was given, back to the old state

lockfile ;		 lock for Examine().
	move.l	d1,-(sp) ; push dirname
	moveq	#ACCESS_READ,d2
	CALL	Lock
	move.l	d0,d6 ; 		d6=lock on dir to scan
	beq.s	errlock ; branch to scan the dir, else...

	tst.l	switch7(a3) ; NOHEADER
	beq	examine
	bra	testsort


errlock
	CALL	IoErr ; get the error
	move.l	d0,d1
	moveq	#0,d2
	CALL	PrintFault ; output an error msg, then exit
	move.l	(sp)+,d1 ; pull dirname (to avoid crash at RTS)

free_args
	tst.b	tmpdeleted(a3) ; close+del tmpfile if break
	beq	free_args2

	move.l	tmpfh(a3),d1
	CALL	Close

	lea	tmpname(pc),a0
	move.l	a0,d1
	CALL	DeleteFile

free_args2
	bsr	multi_lf

	move.l	(a3),d1 ; =args_result(a3)
	CALL	FreeArgs

close_util
	move.l	a4,a1
	move.l	4.w,a6
	CALL	CloseLibrary

free_mem
	move.l	a3,a1
	move.l	a6,a5
	move.l	4.w,a6
	CALL	FreeVec

close_dos
	move.l	a5,a1
	move.l	4.w,a6
	CALL	CloseLibrary
	moveq	#0,d0
	rts ; ----------------------- exit


examine		; to get the comments and the crunched size
	move.l	delim_strptr(a3),d1
	bsr	wdelim
	clr.w	namegiv_bool(a3)
	move.l	(sp),a0
	tst.b	(a0)
	bne	findend

	move.w	#1,namegiv_bool(a3)

findend
	tst.b	(a0)+
	bne.s	findend
	lea	-2(a0),a0
	cmpi.b	#'/',(a0)
	bne.s	filepart
	clr.b	(a0) ; erase last '/' for good filepart (only dirname)
filepart
	cmpi.b	#':',(a0)
	bne.s	f_p2
	clr.b	(a0)
f_p2
	tst.l	switch9(a3)
	bne	fullpath
	move.l	(sp)+,d1 ; pull dirname
	CALL	FilePart
	move.l	d0,-(sp) ; push dirname
fullpath
	tst.l	switch10(a3)
	bne	nostars

	lea	stars(pc),a0
	move.l	a0,d1
	CALL	PutStr ; put '******'
nostars
	move.l	d6,d1 ; get lock
	move.l	d4,d2
	CALL	Examine
	tst.l	d0
	beq	exnext

good
	tst.w	namegiv_bool(a3)
	bne	nonamegiven

	move.l	(sp),d1
	bra.s	namegiven

nonamegiven
	move.l	d4,a0
	lea	fib_FileName(a0),a1
	move.l	a1,d1

namegiven
	tst.l	switch10(a3)
	beq	nocenter
	bsr	centersub

nocenter
	CALL	PutStr
	move.l	d4,a0
	lea	fib_Comment(a0),a0
	tst.b	(a0)
	beq.s	nodircomms

sel_headerfmt

	tst.l	switch10(a3)
	beq	hfmt1

	move.l	a0,-(sp) ; save comments
	bsr	linefeed
	bra	putcomms

hfmt1
	move.l	a0,-(sp)
	lea	inter(pc),a1
	move.l	a1,d1
	CALL	PutStr
putcomms
	move.l	(sp)+,a0
	move.l	a0,d1
	tst.l	switch10(a3)
	beq	nocentercomms
	bsr	centersub
nocentercomms
	CALL	PutStr

nodircomms
	tst.l	switch6(a3)
	bne	twolf

	tst.l	switch10(a3)
	bne	onelf

twolf
	bsr	linefeed

onelf
	tst.l	switch10(a3)
	bne	nolim2

	move.l	delim_strptr(a3),d1
	bsr	wdelim
nolim2

	bsr	linefeed
	move.l	ofh(a3),d1
	CALL	Flush

testsort
	tst.l	switch6(a3)
	bne	currentdir

opentmp
	OPEN	tmpname(pc),MODE_NEWFILE
	move.l	d0,tmpfh(a3)
	beq.s	clrsort
	move.b	#1,tmpdeleted(a3)
	bra.s	currentdir

clrsort
	move.b	#1,switch6(a3)

currentdir
	move.l	(sp)+,a0
	move.l	d6,d1
	CALL	CurrentDir
	move.l	d0,oldlock(a3) ; oldlock on prev dir
	move.l	d6,d1 ; 	d6=lock on dir to scan
	move.l	d4,d2
	CALL	Examine
	tst.l	d0
	beq.s	loop ; if error, unlock and try next arg

	move.l	d4,a0
	move.l	fib_DirEntryType(a0),d0
	bgt	exnext ; scan only if d0 > 0 (entry is a dir)


loop
	bsr.s	unlockdir
loop2

	move.l	(a5)+,d1 ; get the next arg
	bne	gotonext ; continue if arg found

nomore
	move.l	switch5(a3),d1
	beq	free_args
	bsr	type
	bra	free_args ; no more args, exit


gotonext
	move.l	d1,-(sp)

lf_mdirs_gry ; added on 20.10.95 on request of gryzor
	bsr	multi_lf

	move.l	(sp)+,d1
	bra	lockfile

unlockdir
	move.l	oldlock(a3),d1
	CALL	CurrentDir
	move.l	d0,d1
	CALL	UnLock
	rts


dirempty
	move.l	delim_strptr(a3),d1
	bsr	wdelim
	lea	empty.msg(pc),a0
	move.l	a0,d1
	CALL	PutStr

	move.l	tmpfh(a3),d1
	beq	deltmp2

	CALL	Close

deltmp2
	lea	tmpname(pc),a0
	move.l	a0,d1
	CALL	DeleteFile
	bra	free_args2

noexnext
	bsr.s	unlockdir
	tst.b	atleastone(a3)
	beq	dirempty

ins_totfiles
	tst.l	switch6(a3)
	bne	notmpclose

	tst.l	switch10(a3)
	beq.s	noftot

	tst.l	switch7(a3)
	bne.s	noftot

	move.l	strloc2(a3),a1
	tst.l	switch13(a3)
	bne.s	dontadd

	move.l	numdirs(a3),d0
	add.l	d0,numfiles(a3)

dontadd
	lea	fmtnum(pc),a0
	tst.b	onlydirs(a3)
	bne.s	keepfmt

	lea	fmtdnum(pc),a0

keepfmt
	move.l	numfiles(a3),(a1)
	tst.l	switch13(a3)
	beq	dontchangenum
	tst.b	onlydirs(a3)
	bne	dontchangenum

	move.l	numdirs(a3),(a1)

dontchangenum
	movem.l	a2/a3/a6,-(sp)
	move.l	numfiles_buffer(a3),a3
	bsr	sprintf
	movem.l	(sp)+,a2/a3/a6
	move.l	numfiles_buffer(a3),d1
	bsr	centersub
	CALL	PutStr
	bsr	linefeed

limafthead
	move.l	delim_strptr(a3),d1
	bsr	wdelim

nolim1
	bsr	linefeed
	move.l	ofh(a3),d1
	CALL	Flush

noftot
	tst.l	switch10(a3)
	bne	doneyet
	move.l	strloc2(a3),a1
	tst.l	switch13(a3)
	bne.s	doneyet

	move.l	numdirs(a3),d0
	add.l	d0,numfiles(a3)

doneyet
	move.l	tmpfh(a3),d1
	beq	notmpclose
	CALL	Close

	tst.b	sortflag(a3)
	beq.s	notmpclose

	moveq	#0,d2
	move.l	d2,d3
	lea	comline(pc),a0
	move.l	a0,d1
	CALL	Execute

type_files
	lea	sortedname(pc),a0
	move.l	a0,d1
	bsr	type
	tst.l	d0
	bne.s	notmpclose

	lea	sortedname(pc),a0
	move.l	a0,d1
	CALL	DeleteFile
deltmp
;	clr.b	fileshere(a3)
	lea	tmpname(pc),a0
	move.l	a0,d1
	CALL	DeleteFile

	clr.b	tmpdeleted(a3)

notmpclose
	tst.l	switch2(a3)
	bne	loop2

noloop2
	move.l	strloc2(a3),a1
	move.l	numfiles(a3),(a1)

	tst.b	onlydirs(a3)
	bne	ftot

	move.l	numdirs(a3),(a1)
	move.l	a1,d2
	lea	totdirfmt(pc),a0 ; the format
	move.l	a0,d1
	CALL	VPrintf ; printing the final string

	move.l	ofh(a3),d1
	CALL	Flush

	bra	wxltot

ftot
	move.l	utot(a3),Tot_utot2(a1)
	move.l	ctot(a3),Tot_ctot2(a1)
	tst.l	Tot_utot2(a1)
	bne.s	nonull
	moveq	#0,d2
	bra.s	wtot

nonull
	move.l	Tot_utot2(a1),d3
	move.l	ctot(a3),d0

	bsr	calc_ratio ; in: d3=utot,d0=ctot / out: d2=ratio

wtot
	move.l	d2,Tot_ratio(a1) ; ratio=100-100*CLen/ULen
	move.l	a1,d2
	lea	totfmt(pc),a0 ; the format

	tst.l	switch15(a3)
	bne	oldtot

	move.l	Tot_ctot2(a1),(Tot_ctot2-4)(a1) ; shift up struct (gry fmt)
	move.l	Tot_ratio(a1),(Tot_ratio-4)(a1)
	lea	grytot(pc),a0

oldtot
	move.l	a0,d1
	CALL	VPrintf ; printing the final string

	move.l	ofh(a3),d1
	CALL	Flush

wxltot
	OPEN	totvarname(pc),MODE_NEWFILE
	move.l	d0,varfh(a3)
	move.l	d0,d1

	move.l	strloc2(a3),d3
	tst.b	onlydirs(a3)
	bne	notonlyd

	tst.l	switch13(a3)
	beq	notonlyd
	move.l	strloc2(a3),a0
	clr.l	(a0)

notonlyd
	lea	fmtvar(pc),a0
	move.l	a0,d2
	CALL	VFWritef
	move.l	varfh(a3),d1
	CALL	Close

	bsr	dosumvar

clrintvars
	moveq	#0,d0
	move.l	d0,utot(a3)
	move.l	d0,ctot(a3)
	move.l	d0,numfiles(a3)
	move.l	d0,numdirs(a3)
	bra	loop2


isdir ; called when filename was a dir
	move.l	d4,a0
	move.l	fib_DirEntryType(a0),d0
	ble.s	exnext

	tst.l	switch8(a3)
	bne.s	exnext

	clr.b	entrytype(a3)
	lea	fib_FileName(a0),a1
	move.l	a1,(a2)
	move.l	#'Dir ',Packlib(a3)
	lea	Packlib(a3),a1
	move.l	a1,Str_Type(a2)
	clr.l	Dec_Ratio(a2)
	add.l	#1,numdirs(a3)
	bra	testsort2

;************  mainloop

exnext
	move.l	#SIGBREAKF_CTRL_C,d1 ; check for ctrl-c between each file.
	CALL	CheckSignal
	tst.l	d0
	beq.s	no_break

exit
	bsr	unlockdir
	bra	free_args


no_break
	move.l	d6,d1 ; d6=lock
	move.l	d4,d2 ; d4=fib
	CALL	ExNext
	tst.l	d0
	beq	noexnext ; break if error (like no more entries)


	move.l	d4,a0
	lea	fib_FileName(a0),a1
	move.l	a1,d5 ; 		d5=file to open
	move.l	fib_Size(a0),Dec_CLen(a2)
	move.l	fib_Size(a0),Dec_ULen(a2) ; ulen=clen for normal files
	lea	fib_Comment(a0),a1
	tst.l	switch3(a3)
	beq.s	cmp_dur

	moveq	#25,d0
rip
	cmpi.l	#'Ripp',(a1,d0)
	beq.s	cmp_dur
	dbra	d0,rip
	bra.s	exnext


cmp_dur
	tst.l	switch4(a3)
	beq.s	cmp_xfh

	moveq	#2,d0
dur
	cmpi.b	#'[',(a1,d0)
	beq.s	exnext
	dbra	d0,dur


cmp_xfh
	cmpi.l	#'XFH ',(a1) ; detects XFH comments (by xScan). 'Erase' them.
	bne.s	readhead

hide_comments__
	clr.b	(a1)

readhead	; lets read the first 16 bytes
	move.l	a1,Str_Comment(a2)
	move.l	d5,d1
	move.l	#MODE_OLDFILE,d2
	CALL	Open
	move.l	d0,d7 ; 		d7=filehandle#1
	beq	isdir ; if error (dir) examine next entry

	move.b	#FILE,entrytype(a3)
	move.b	#1,onlydirs(a3)
	move.l	d0,d1
	move.l	headbuf(a3),d2
	move.l	d2,a1 ; clear the readbuffer because old infos are...
	clr.l	(a1) ; ...still here. (Ex. if <.file> detected just before)
	moveq	#lha_size,d3
	CALL	Read
	move.l	d7,d1
	CALL	Close

testxpk__
	move.l	headbuf(a3),a1 ; 		a1=readbuffer
	move.l	(a1),d1 ; =xh_Reco(a1)		d1=first 4 bytes of the file
	cmpi.l	#'XPKF',d1
	bne.s	testpp20

hereisxpk__
	tst.l	switch14(a3)
	beq	nosong

	lea	xh_Sample(a1),a0
	move.l	a0,Str_File(a2)
	moveq	#$1f,d0
	moveq	#4,d1

.loop
	cmp.b	(a0,d1),d0
	bge	nosong
	dbra	d1,.loop

	move.l	#$80,d0
	moveq	#15,d1

.loop2
	cmp.b	(a0,d1),d0
	bge	nosong
	dbra	d1,.loop2

	move.w	#1,xpked(a3)

nosong
	move.l	xh_CLen(a1),d0
	addq	#8,d0
	cmp.l	Dec_CLen(a2),d0
	bne	noxpk
	move.l	xh_ULen(a1),Dec_ULen(a2) ; Unpacked lenght
	move.l	xh_Type(a1),Packlib(a3) ; Packing method

	bra	print ; output to stdio

noxpk
	move.l	#'!XPK',Packlib(a3)
	bra	print

testpp20
	move.l	d1,Packlib(a3) ; Packlib=PP20,Crm2 or S404
	cmpi.l	#'PP20',d1
	bne.s	testcrm2

hereispp20__		; reopen file for decrunched size
	move.l	d5,d1
	move.l	#MODE_OLDFILE,d2
	CALL	Open
	move.l	d0,d7 ; 		d7=filehandle#2
	beq	exnext

	move.l	d0,d1
	moveq	#-4,d2
	moveq	#OFFSET_END,d3 ; position : before last longword
	CALL	Seek
	move.l	d7,d1
	lea	pplast(a3),a0
	move.l	a0,d2
	moveq	#4,d3
	CALL	Read ; let's read the last 4 bytes
	move.l	d7,d1
	CALL	Close
	move.l	pplast(a3),d0 ; XXXXXXxx
	lsr.l	#8,d0 ; calculating the PP-Decrunch-Info
	move.l	d0,Dec_ULen(a2) ; 00XXXXXX
	cmp.l	Dec_CLen(a2),d0
	blt	nopp

	move.l	Dec_CLen(a2),d1
	move.l	d1,d2
	add.l	d1,d1 ; C*2
	add.l	d1,d1 ; C*4
	add.l	d1,d2 ; C*5
	add.l	d2,d2 ; C*10
	cmp.l	d2,d0
	blt	print

nopp
	move.l	Dec_CLen(a2),Dec_ULen(a2)
	move.l	#'!PP2',Packlib(a3)
	bra	print

testcrm2
	cmpi.l	#'Crm2',d1
	beq.s	hereiscrm
	cmpi.l	#'CrM2',d1
	beq.s	hereiscrm
	cmpi.l	#'CrM!',d1
	beq.s	hereiscrm
	cmpi.l	#'Crm!',d1
	bne.s	teststc

hereiscrm
	move.l	crm_CrunchLen(a1),d0
	add.l	#14,d0
	cmp.l	Dec_CLen(a2),d0
	bne.s	nocrm
	move.l	crm_UnpackLen(a1),Dec_ULen(a2)
	bra	print

nocrm
	move.l	#'!Crm',Packlib(a3)
	bra	print

teststc
	cmpi.l	#'S403',d1
	beq.s	hereisstc

	cmpi.l	#'S404',d1
	bne.s	testlha

hereisstc
	move.l	stc_CrunchLen(a1),d0
	add.l	#20,d0
	cmp.l	Dec_CLen(a2),d0
	bne.s	nostc
	move.l	stc_UnpackLen(a1),Dec_ULen(a2)
	bra	print

nostc
	move.l	#'!S40',Packlib(a3)
	bra	print

testlha
	move.l	headbuf(a3),a1
	move.w	3(a1),d1
	cmpi.w	#'lh',d1
	bne	nopacker

	move.b	2(a1),d1
	cmpi.b	#'-',d1
	bne	nopacker

hereislh5
	move.l	d4,-(sp)
	bsr	getlhanfo
	move.l	(sp)+,d4
	bra	print

nopacker
	move.l	#'    ',Packlib(a3)

print		; put the infos in the right places
	move.l	d5,d1
	CALL	FilePart ; trash the full path, keep basename
	tst.l	switch14(a3)
	beq	putfilename

	tst.w	xpked(a3)
	bne.s	printbis

putfilename
	move.l	d0,(a2)

printbis
	move.l	d0,a1
	cmpi.b	#'.',(a1) ; strip out the ".*" files (.EPDir)
	beq	exnext ; unlock and goto mainloop

	add.l	#1,numfiles(a3)
	lea	Packlib(a3),a1
	move.l	a1,Str_Type(a2)
	move.l	Dec_CLen(a2),d0
	move.l	Dec_ULen(a2),d3
	add.l	d0,ctot(a3)
	add.l	d3,utot(a3)

	bsr	calc_ratio

	move.l	d2,Dec_Ratio(a2) ; ratio=100-100*CLen/ULen

chstructs
	tst.l	switch15(a3)
	bne	testsort2

	move.l	Dec_CLen(a2),(Dec_CLen-4)(a2)
	move.l	Str_Type(a2),(Str_Type-4)(a2)
	move.l	Dec_Ratio(a2),(Dec_Ratio-4)(a2)
	move.l	Str_Comment(a2),(Str_Comment-4)(a2)

testsort2
	tst.l	switch6(a3)
	bne	printfd
	move.l	tmpfh(a3),fh(a3)
	beq.s	printfd

	move.b	#1,sortflag(a3)
	bra.s	vfprint

printfd
	move.l	ofh(a3),fh(a3)

vfprint
	move.l	fh(a3),d1

	move.l	a2,d3
	tst.b	entrytype(a3)
	beq	putdirfmt

	tst.l	switch15(a3)
	bne	ulenfmt

	lea	gryfmt(pc),a0
	bra	dddd

ulenfmt
	lea	cformat(pc),a0
	bra.s	dddd

putdirfmt
	lea	dirfmt(pc),a0

	tst.l	switch15(a3)
	bne	dddd

	move.l	Dec_CLen(a2),(Dec_CLen-4)(a2)
	move.l	Str_Type(a2),(Str_Type-4)(a2)
	move.l	Dec_Ratio(a2),(Dec_Ratio-4)(a2)
	move.l	Str_Comment(a2),(Str_Comment-4)(a2)
	lea	grydirfmt(pc),a0

dddd
	move.l	a0,d2
	CALL	VFPrintf
	move.l	fh(a3),d1
	CALL	Flush

	move.l	d4,a0
	lea	fib_Comment(a0),a1
	moveq	#18,d0

clrcomm
	clr.l	(a1)+
	dbra	d0,clrcomm
	move.b	#1,atleastone(a3)

	clr.w	xpked(a3)

	bra	exnext ; next entry please

;************************************************* subroutines


calc_ratio ; in: d0=ctot,d3=utot / out: d2=ratio
	move.l	a6,a0
	move.l	a4,a6

	tst.l	d3
	beq	dontcalc

	cmp.l	d0,d3 ; test if clen = ulen ( => ratio = 0% )
	bne.s	calc

dontcalc
	moveq	#0,d2
	bra.s	endcalc

calc
	moveq	#100,d1
	move.l	d0,d5
	move.l	d3,d0
	cmpi.l	#1000000,d3 ; change method at 1 Mb
	bgt.s	nozero ; bra if d3 is big enough for the "bigsizes" ratio

	move.l	d5,d0 ; classic method, for 0 => 21 Mo sizes
	CALL	UMult32 ; clen * 100 (oveflow with too big numbers!)
	move.l	d3,d1
	bra.s	div ; (clen * 100) / ulen

nozero ; 2nd method, for 1 Mb => 2 Gb (uncrunched) sizes
	CALL	UDivMod32 ; ulen / 100
	move.l	d0,d1
	move.l	d5,d0
div
	CALL	UDivMod32 ; clen / (ulen / 100)
	moveq	#100,d2
	sub.l	d0,d2 ; 100 - quotient = ratio
endcalc
	move.l	a0,a6
	rts


linefeed
	move.l	ofh(a3),d1
	moveq	#10,d2
	CALL	FPutC
	rts


multi_lf
	tst.l	switch11(a3) ; could have done a tst.l a0 on 020+ :-)
	beq	noelf

	move.l	switch11(a3),a0 ; LF
	move.l	(a0),d0
	tst.l	d0
	beq	noelf ; LF=0
	bmi	noelf ; LF=-n

	subq	#1,d0

putlf
	move.l	d0,-(sp)
	bsr	linefeed
	move.l	(sp)+,d0
	dbra	d0,putlf

noelf
	rts


type ; d1: strptr on file to write to stdout
	move.l	d1,-(sp)
	moveq	#ACCESS_READ,d2
	CALL	Lock
	move.l	d0,itlock(a3)
	bne.s	itlocked
	move.l	(sp)+,d1
	moveq	#-1,d0
	rts
itlocked
	move.l	d4,d2
	move.l	d0,d1
	CALL	Examine
	move.l	d4,a0
	move.l	fib_Size(a0),itsize(a3)
	move.l	#MODE_OLDFILE,d2
	move.l	(sp)+,d1
	CALL	Open
	move.l	d0,itfh(a3)
	bne.s	itopened
	bra	itunlock
itopened
	move.l	itsize(a3),d0
	move.l	#$10001,d1
	move.l	a6,-(sp)
	move.l	4.w,a6
	CALL	AllocVec
	move.l	(sp)+,a6
	move.l	d0,itbuffer(a3)
	beq	itclose
	move.l	d0,d2
	move.l	itfh(a3),d1
	move.l	itsize(a3),d3
	CALL	Read
	move.l	ofh(a3),d1
	move.l	itbuffer(a3),d2
	move.l	itsize(a3),d3
	CALL	Write
	move.l	itbuffer(a3),a1
	move.l	a6,-(sp)
	move.l	4.w,a6
	CALL	FreeVec
	move.l	(sp)+,a6
itclose
	move.l	itfh(a3),d1
	CALL	Close
itunlock
	move.l	itlock(a3),d1
	CALL	UnLock
	moveq	#0,d0
	rts


centersub ; d1=strptr on string to center (80 cols display)
	move.l	d1,-(sp)
	move.l	d1,a0
	moveq	#-1,d0

countlen
	addq	#1,d0
	tst.b	(a0)+
	bne.s	countlen

	moveq	#80,d1
	sub.b	d0,d1

	tst.b	d1
	bmi	endcenter

	tst.b	d1
	beq	endcenter

	lsr.l	#1,d1
	move.b	d1,spcecnt(a3)
	beq	endcenter

putspace
	move.l	ofh(a3),d1
	moveq	#' ',d2
	CALL	FPutC
	sub.b	#1,spcecnt(a3)
	tst.b	spcecnt(a3)
	bne	putspace
endcenter
	move.l	(sp)+,d1
	rts


dosumvar ; env:xlsumtot, sumvarfname
	lea	sumvarfname(pc),a0
	move.l	a0,d1
	moveq	#ACCESS_READ,d2
	CALL	Lock
	tst.l	d0
	bne	sdfg

	OPEN	sumvarfname(pc),MODE_NEWFILE
	move.l	d0,varfh(a3)
	move.l	d0,d1

	move.l	strloc2(a3),d3
	lea	fmtvar(pc),a0
	move.l	a0,d2
	CALL	VFWritef
	move.l	varfh(a3),d1
	JUMP	Close

sdfg ; nice label names !!!
	move.l	d0,d1
	CALL	UnLock

	moveq	#VARSIZE,d0
	move.l	#$10001,d1
	move.l	a6,-(sp)
	move.l	4.w,a6
	CALL	AllocVec
	move.l	(sp)+,a6
	tst.l	d0
	bne	vvdj
	rts

vvdj
	move.l	d0,sumvarbuff(a3)
	move.l	d0,d2
	moveq	#VARSIZE,d3
	lea	sumvarname(pc),a0
	move.l	a0,d1
	move.l	#GVF_GLOBAL_ONLY,d4
	CALL	GetVar

	move.l	sumvarbuff(a3),d1
	lea	longsum(a3),a0
	move.l	a0,d2
	CALL	StrToLong

	move.l	numfiles(a3),d0

	add.l	d0,longsum(a3)

	OPEN	sumvarfname(pc),MODE_NEWFILE
	move.l	d0,varfh(a3)
	move.l	d0,d1

	lea	longsum(a3),a0
	move.l	a0,d3
	lea	fmtvar(pc),a0
	move.l	a0,d2
	CALL	VFWritef ; I don't use SetVar() here for strange reasons
	move.l	varfh(a3),d1
	JUMP	Close

freevbuff
	move.l	sumvarbuff(a3),a1
	move.l	a6,-(sp)
	move.l	4.w,a6
	CALL	FreeVec
	move.l	(sp)+,a6
	rts


sprintf ; a0 - format, a1 - data, a3 - buffer
		lea	stuffChar(pc),a2
		move.l	4.w,a6
		JUMP	RawDoFmt

	stuffChar:
		move.b	d0,(a3)+
		rts


wdelim ; d1 - strptr on line to write
	tst.l	switch12(a3)
	beq	wd_end

	bsr	centersub
	CALL	PutStr
	move.l	ofh(a3),d1
	CALL	Flush

	tst.b	ext_linea(a3)
	beq	wd_end

	bsr	linefeed

wd_end
	rts


getlhanfo

	moveq	#0,d4 ; index

	bsr	getlh_clen

	move.l	tmp_lhsize(a3),d0
	cmp.l	Dec_CLen(a2),d0
	blt	goodlha

	move.l	#'!LHA',Packlib(a3)
	rts

goodlha
	add.l	#45,d0
	cmp.l	Dec_CLen(a2),d0
	bgt	onefileinside

multiplelha
	move.l	#'LHAs',Packlib(a3)
	clr.l	lh_utot(a3)

	move.l	d5,d1
	move.l	#MODE_OLDFILE,d2
	CALL	Open

	move.l	d0,d7
	beq	unopenlha

refreshindex
	move.l	headbuf(a3),a1
	cmpi.w	#$2001,lha_chksum2(a1) ; whaw! I was lucky to find this.
	bne	amilha
uxlha
	addq	#3,d4

amilha
	moveq	#0,d0
	move.l	headbuf(a3),a1
	move.b	lha_namesize(a1),d0
	add.l	d0,d4
	move.l	d4,d0

	add.l	#24,d4 ; 24=size of checksum and other stuff.
	move.l	d4,d0

	add.l	tmp_lhsize(a3),d4 ; tmp_lhsize=clen of an arc file
	move.l	d4,d0

	bsr	getlh_ulen

	move.l	Dec_ULen(a2),d0
	add.l	d0,lh_utot(a3) ; lh_utot = total unpacked lenght of files
	move.l	lh_utot(a3),d0


readnextlha

	move.l	d7,d1
	move.l	d4,d2
	move.l	#OFFSET_BEGINNING,d3
	CALL	Seek ; go to the next lha header
	CALL	IoErr
	tst.l	d0
	beq	morelha

endlha
	move.l	d7,d1
	CALL	Close

	move.l	Dec_ULen(a2),d1
	sub.l	d1,lh_utot(a3)
	move.l	lh_utot(a3),Dec_ULen(a2)
	tst.l	Dec_ULen(a2)
	bpl	sizeplus

unopenlha
	move.l	Dec_CLen(a2),Dec_ULen(a2)
sizeplus
	rts

morelha
	move.l	d7,d1
	move.l	headbuf(a3),d2
	moveq	#lha_size,d3
	CALL	Read ; read the next lha header in archive

	move.l	headbuf(a3),a1
	bsr	getlh_clen

	bra	refreshindex

;*----------------------------------
onefileinside

;	move.l	tmp_lhsize(a3),Dec_CLen(a2)
;this line above put the crunched size appearing in Lha. I choose not to
;do this here but feel free to do it if you want.

	bsr	getlh_ulen

	move.l	#'LHA ',Packlib(a3)

	rts

getlh_clen ; d1=index -> clen in tmp_lhsize
	move.b	lha_clen3(a1),(tmp_lhsize+3)(a3)
	move.b	lha_clen2(a1),(tmp_lhsize+2)(a3)
	move.b	lha_clen1(a1),(tmp_lhsize+1)(a3)
	move.b	lha_clen0(a1),tmp_lhsize(a3)
	rts

getlh_ulen ; d1=index -> ulen in dec_ulen
	move.b	lha_ulen3(a1),(Dec_ULen+3)(a2)
	move.b	lha_ulen2(a1),(Dec_ULen+2)(a2)
	move.b	lha_ulen1(a1),(Dec_ULen+1)(a2)
	move.b	lha_ulen0(a1),Dec_ULen(a2)
	rts

;subdebug
;	move.l	a1,-(sp)
;	move.l	d0,-(sp)
;	lea	debug(pc),a0
;	move.l	a0,d2
;	move.l	d0,(a0)
;	lea	debugfmt(pc),a0
;	move.l	a0,d1
;	CALL	VPrintf
;	move.l	(sp)+,d0
;	move.l	(sp)+,a1
;	rts

;---- datas ----

;debug
;	dc.l	0

;debugfmt
;	dc.b	'd0=%ld',10,0

;header
;	dc.b	'File                           Real   Packed Type/Ratio'
;	dc.b	'     Comment',10
;	dc.b	'~~~~                           ~~~~   ~~~~~~ ~~~~~~~~~~'
;	dc.b	'     ~~~~~~~',10,0

cformat
	dc.b	'%-26.26s %8ld %8ld (%s/%2ld%%) %s',$a,0

gryfmt
	dc.b	'%-30.30s %8ld (%s/%2ld%%) %s',$a,0


;File                           Real   Packed Type/Ratio     Comment

dirfmt
	dc.b	' %-25.25s %8ld %8ld (%s/%2ld%%) %s',$a,0

grydirfmt
	dc.b	' %-29.29s %8ld (%s/%2ld%%) %s',$a,0


grytot
	dc.b	'                                ~~~~~~~      ~~~~~',10
	dc.b	'=> %5ld file(s)               %8ld       %2ld%%',10,0


totfmt
	dc.b	'                            ~~~~~~~  ~~~~~~~      ~~~~~',10
	dc.b	'=> %5ld file(s)         %10ld %8ld       %2ld%%',10,0

totdirfmt
	dc.b	'~~~~~~~~~~~~',10,'=> %ld dirs',10,0

dosname
	dc.b	'dos.library',0

uname
	dc.b	'utility.library',0

empty.msg
	dc.b	'Directory is empty!',10,0

tr.msg
	dc.b	'(Filtering mods WITH "Ripp" in DOS_Comment)',10,0

td.msg
	dc.b	'(Filtering mods WITHOUT duration in DOS_Comment)',10,0

stars
	dc.b	'********** ',0

delim
	dc.b	'============================================================'
	dc.b	'===================',10,0

inter
	dc.b	' - ',0

fmtvar
	dc.b	'%N',0

fmtnum
	dc.b	'%ld files',0

fmtdnum
	dc.b	'%ld dirs',0

totvarname
	dc.b	'ENV:xltotal',0

sumvarfname
	dc.b	'ENV:'
sumvarname
	dc.b	'xlsumtot',0

tmpname
	dc.b	'T:xltmp1',0

sortedname
	dc.b	'T:xltmp2',0

cmdname
	dc.b	'C:'
segname
	dc.b	'Sort',0

comline ; lame but true
	dc.b	'Sort >NIL: T:xltmp1 to T:xltmp2',0

version_string
	dc.b	'$VER: xList 1.05 (23.10.95) by ReeZ/Osmose',0

args_template
	dc.b	'DIR/M,IT=INTROTEXT/K,NT=NOTOTALS/S,TR=TESTRIPP/S,'
	dc.b	'TD=TESTDURATION/S,ET=ENDTEXT/K,NOSORT/S,NH=NOHEADER/S,'
	dc.b	'FO=FILESONLY/S,FP=FULLPATH/S,H2=HEADER2/S,LF/N/K,'
	dc.b	'DL=DRAWLIMITS/S,COF=COUNTONLYFILES/S,SN=SONGNAME/S,'
	dc.b	'SU=SHOWUSIZE/S,LA=LINEASPECT/K',0

	end

; Contact me for ANY reason (especially for module-swapping, hehe) :
;Snail:  David Le Corfec            Email:
;        57 rue C.J. Romain
;        94170 Le Perreux           ->>>  lecorfec@merlin.univ-mlv.fr
;           - France -              
;                     -=: 100% aNSWeR! :=-
