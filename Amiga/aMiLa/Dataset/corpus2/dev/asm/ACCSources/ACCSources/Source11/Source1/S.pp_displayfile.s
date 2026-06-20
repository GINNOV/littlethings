; Load and decrunch Powerpacker data file ; Simon Knipe ; 11 Jan 91

; Firstly, it is MUCH easier to load files using the POWERPACKER.LIBRARY
; whether they are crunched or not!! The lib takes care of filesize,
; allocating memory, reading the data in, etc. All you have to do is
; return the memory to the system when it has finished!

		opt		o+,ow-
		incdir		"df0:include/"
		include		"libraries/dosextens.i"		need!
		incdir		source:include/
		include		"ppbase.i"
		include		"powerpacker_lib.i"
		include		SK_LoadMacros.i
***********************************************************************
; find us a few libraries
		SMARTOPENLIB dosname,dosbase,error0
		SMARTOPENLIB ppname,ppbase,error1

; load and decrunch data
		move.l		ppbase,a6		lib base
		lea		filename,a0		file to dec
		moveq		#DECR_POINTER,d0	from pp includes
		moveq		#0,d1
		lea		memptr,a1
		lea		filelen,a2
		move.l		#0,a3
		jsr		_LVOppLoadData(a6)	try to load

		tst.l		d0		check if ok
		bne.s		error1		no then get out fast!

; get cli handles
		GETHANDLE inputhd,outputhd

; display file in cli window
		WRITEDATA outputhd,memptr,filelen

; return mem allocated by pp
		RETURNMEM filelen,memptr

; close the used file
		CLOSEFILE filehd
***********************************************************************
; close PowerPacker library
		CLOSELIB ppbase

; Close the DOS library
error1		CLOSELIB dosbase

; All done so return
error0		rts
***********************************************************************
filename	dc.b		"source:source1/text.pp",0
		even
dosname		dc.b		"dos.library",0
		even
ppname		dc.b		"powerpacker.library",0
		even
dosbase		dc.l		0
ppbase		dc.l		0
filelen		dc.l		0
filehd		dc.l		0
inputhd		dc.l		0
outputhd	dc.l		0
memptr		dc.l		0

