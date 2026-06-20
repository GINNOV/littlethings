; DumpFile, using ARP and PowerPacker libraries ; SK 24 JAN 91.
************************************************************************
		SECTION DumpFile,CODE
************************************************************************
 opt			o+,ow-
 incdir			"df0:include/"
 include		"libraries/dosextens.i"
 incdir			source:include/
 include		"ppbase.i"
 include		"powerpacker_lib.i"
 include		"arpbase.i"
 include		"SK_LoadMacros.i"

		SMARTOPENLIB dosname,dosbase,error0
		SMARTOPENLIB ppname,ppbase,error1
		SMARTOPENLIB intname,intbase,error2
		SMARTOPENLIB arpname,_ArpBase,error3

DoRequestor	lea		LoadFileStruct,a0	get file struct
		CALLARP		FileRequest 		and open requester
		tst.l		d0			did the user cancel ?
		beq		error4			yes then quit
		lea		LoadFileStruct,a0	get file struct
		bsr		CreatePath		make full pathname
		moveq.l		#0,d0			reset flag
		tst.b		LoadPathName		is there a pathname ?
		beq		error4			no - then quit
		moveq.l		#1,d0			else set flag

loadfile	move.l		ppbase,a6		lib base
		lea		LoadPathName,a0
		moveq		#DECR_POINTER,d0	from pp includes
		moveq		#0,d1
		lea		memptr,a1
		lea		filelen,a2
		move.l		#0,a3
		jsr		_LVOppLoadData(a6)	try to load

		tst.l		d0		check if ok
		bne		error1		no then get out fast!

		GETHANDLE inputhd,outputhd	get cli handles
		WRITEDATA outputhd,memptr,filelen	dump file into it!
		RETURNMEM filelen,memptr	return PP allocated mem
		CLOSEFILE filehd		close the file

error4		CLOSELIB _ArpBase
error3		CLOSELIB intbase
error2		CLOSELIB ppbase
error1		CLOSELIB dosbase
error0		rts
***********************************************************
;	General ARP subroutines called by anybody
***********************************************************
;Subroutine to create a single pathname from the seperate directory
;and filename strings.Adds ':' or '/' as needed.Called by

;CreatePath(FileRequest)
;		a0

;This routine assumes that a pointer to the pathname buffer
;is placed directly after the FileRequest structure.(My extension)
		
CreatePath:
	move.l		a2,-(sp)		;save a2
	move.l		a0,a2			;file struct to a2
	move.l		fr_Dir(a2),a0		;directory string to a0
	move.l		fr_SIZEOF(a2),a1	;get destination address
	moveq		#DSIZE,d0		;get size
	MAKECALL	execbase,-624		;and copy dir string
	
	move.l		fr_SIZEOF(a2),a0	;get path (dest) address
	move.l		fr_File(a2),a1		;get file string
	CALLARP		TackOn			;and tack onto dir string
	move.l		(sp)+,a2		;restore a2
	rts					;and quit
***********************************************************
	SECTION	FileRequestSpace_and_other_pointers,BSS
***********************************************************
LoadFileData:
		ds.b	FCHARS+1	;reserve space for filename buffer
		EVEN
LoadDirData:
		ds.b	DSIZE+1		;reserve space for path buffer
		EVEN
LoadPathName	ds.b	DSIZE+FCHARS+2	;reserve space for full pathname name buffer
		EVEN
_ArpBase	ds.l		1
intbase		ds.l		1
dosbase		ds.l		1
ppbase		ds.l		1
filelen		ds.l		1
filehd		ds.l		1
inputhd		ds.l		1
outputhd	ds.l		1
memptr		ds.l		1
***********************************************************
	SECTION names_and_other,DATA
***********************************************************
dosname		dc.b		"dos.library",0
		even
ppname		dc.b		"powerpacker.library",0
		even
intname		dc.b		"intuition.library",0
		even
arpname		dc.b		"arp.library",0
		even
LoadFileStruct:
	dc.l		LoadText	;pointer to hail text
	dc.l		LoadFileData	;pointer to filename buffer
	dc.l		LoadDirData	;pointer to path buffer
	dc.l		0		;window to attach to - none if on WB
	dc.b		0		;flags - none
	dc.b		0		;reserved
	dc.l		0		;fr_Function
	dc.l		0		;reserved2
	dc.l		LoadPathName
LoadText:
	dc.b	"DumpFile by SK (of all people)",0
	even

