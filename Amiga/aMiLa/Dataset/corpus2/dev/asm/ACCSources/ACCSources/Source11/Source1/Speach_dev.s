
; Following on from last months example, this is the correct way to open
;and use the narrator device. Because the Abacus example does not create
;and initialise a port for IO, the program is doomed and continualy GURUs

; Also illustrated is how to change the voice characteristics.

; M.Meany, March 91.

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
		include		devices/narrator.i

;--------------	Open the DOS library

		lea		dosname,a1
		moveq.l		#0,d0
		CALLEXEC	OpenLibrary
		move.l		d0,_DOSBase
		beq		error
	
;--------------	Open Translator library
	
		lea		transname,a1
		moveq.l		#0,d0
		CALLEXEC	OpenLibrary
		move.l		d0,_TranslatorBase
		beq		error1
		
;--------------	Initialise a port to use with narrator device

		lea		MyPortName,a0	name for port ( public )
		moveq.l		#0,d0		priority
		bsr		CreatePort	get a port
		move.l		d0,MyPort	save its address

;--------------	Attach port to narrator io structure

		lea		speak_io,a1		io request
		move.l		d0,MN_REPLYPORT(a1)	port addr
		
;--------------	Open the narrator device

		moveq.l		#0,d0
		move.l		d0,d1
		lea		narratorname,a0
		CALLEXEC	OpenDevice
		tst.l		d0
		bne		error2

;--------------	Initialise the narrator io structure

		lea		speak_io,a1		io request
		move.l		#audio_chans,NDI_CHMASKS(a1)	audio mask
		move.w		#4,NDI_NUMMASKS(a1)	number of mask
		move.l		#512,IO_LENGTH(a1)	buffer len
		move.w		#CMD_WRITE,IO_COMMAND(a1)	command write
		move.l		#outtext,IO_DATA(a1)	addr of buffer

		
;--------------	Convert a sentence to phonemes

		lea		intext,a0
		move.l		#intextlen,d0
		lea		outtext,a1
		move.l		#512,d1
		CALLTRANS	Translate
		
;--------------	Send phoneme list to narrator

		lea		speak_io,a1
		move.l		#512,36(a1)
		CALLEXEC	SendIO

;--------------	Wait for narrator to finish

		lea		speak_io,a1
		CALLEXEC	WaitIO

;--------------	Change to female voice

		lea		speak_io,a0
		move.w		#FEMALE,NDI_SEX(a0)
		move.w		#200,NDI_PITCH(a0)
		move.w		#95,NDI_RATE(a0)

;--------------	Convert a sentence to phonemes

		lea		woman,a0
		move.l		#womanlen,d0
		lea		outtext,a1
		move.l		#512,d1
		CALLTRANS	Translate
		
;--------------	Send phoneme list to narrator

		lea		speak_io,a1
		move.l		#512,36(a1)
		CALLEXEC	SendIO

;--------------	Wait for narrator to finish

		lea		speak_io,a1
		CALLEXEC	WaitIO
		
;--------------	Close narrator device

		lea		speak_io,a1
		CALLEXEC	CloseDevice
		
;--------------	Release the Port

		move.l		MyPort,a0
		bsr		DeletePort

error2		move.l		_TranslatorBase,a1
		CALLEXEC	CloseLibrary
		
error1		move.l		_DOSBase,a1
		CALLEXEC	CloseLibrary
		
error		rts

		Include		df1:subroutines/exec_support.i


dosname		DOSNAME
		even
_DOSBase	dc.l		0

transname	TRANSNAME
		even
_TranslatorBase	dc.l		0

narratorname	dc.b		'narrator.device',0
		even

MyPortName	dc.b		'Meanys-Port',0
		even

audio_chans	dc.b		3,5,10,12	channels to use
		even

speak_io	ds.l		NDI_SIZE	narrator IO request block

MyPort		ds.l		1		pointer to initialised port

intext		dc.b		'Welcome to Ay see see  disc ten',0
intextlen	equ		*-intext
		even
woman		dc.b		' get m off',0
womanlen	equ		*-woman
		even

outtext		ds.b		512
