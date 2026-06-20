
; A short while ago someone asked me how to get the narrator source from
;the Abacus book to work. Well here it is.

; You will need translator.library in the libs: directory of your sys:
;disc and narrator.device in the devs: directory in order to run this.

; M.Meany, 1991.

		incdir		"sys:include/"
		include		"exec/exec_lib.i"
		include		"exec/exec.i"
		include		libraries/dos_lib.i
		include		"libraries/dos.i"
		include		"libraries/dosextens.i"
		include		libraries/translator_lib.i
		include		libraries/translator.i

		lea		dosname,a1
		moveq.l		#0,d0
		CALLEXEC	OpenLibrary
		move.l		d0,_DOSBase
		beq		error
		
		lea		transname,a1
		moveq.l		#0,d0
		CALLEXEC	OpenLibrary
		move.l		d0,_TranslatorBase
		beq		error1
		
		lea		talkio,a1		io request
		move.l		#nwrrep,14(a1)		port addr
		move.l		#amaps,56(a1)		audio mask
		move.w		#4,60(a1)		mask number
		move.l		#512,36(a1)		buffer len
		move.w		#3,28(a1)		command write
		move.l		#outtext,40(a1)		addr of buffer
		
		moveq.l		#0,d0
		move.l		d0,d1
		lea		narratorname,a0
		CALLEXEC	OpenDevice
		tst.l		d0
		bne		error2
		
		lea		intext,a0
		move.l		#intextlen,d0
		lea		outtext,a1
		move.l		#512,d1
		CALLTRANS	Translate
		
		lea		talkio,a1
		move.l		#512,36(a1)
		CALLEXEC	SendIO
		
		move.l		#150,d1
		CALLDOS		Delay
		
		lea		talkio,a1
		CALLEXEC	AbortIO
		
		lea		talkio,a1
		CALLEXEC	CloseDevice
		
error2		move.l		_TranslatorBase,a1
		CALLEXEC	CloseLibrary
		
error1		move.l		_DOSBase,a1
		CALLEXEC	CloseLibrary
		
error		rts


dosname		DOSNAME
		even
_DOSBase	dc.l		0

transname	TRANSNAME
		even
_TranslatorBase	dc.l		0

narratorname	dc.b		'narrator.device',0
		even

		section		ss,data_c

amaps		dc.b		3,5,10,12
		even

talkio		ds.l		20

nwrrep		ds.l		8

intext		dc.b		'Welcome to Ay see see  disc ten',0
intextlen	equ		*-intext
		even

outtext		ds.b		512
