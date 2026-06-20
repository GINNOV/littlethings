
* Name		serialCommand_1.s
* Function	Preform some function depending on data received from serial
*		device.
* Programmer	M.Meany
* Assembler	Devpac III ( will assemble using Devpac II )
* Comments	It works!
*		Development of a NULL modem link-up of two Amigas
*		*D	return directory	eg. *D dh0:include
*		*G	return text file	eg. *G s:startup-sequence
*		*E	execute CLI command	eg. *E c:copy #? to ram:
*		*Q	quit			eg. *Q

*		Any line of text not starting with * is echoed to CLI and
*		ignored.

		incdir		sys:Include/
		include		exec/Exec.i
		include		exec/exec_lib.i
		include		libraries/dos.i
		include		libraries/dos_lib.i
		include		devices/serial.i
		include		marks/MM_Macros.i

; Start by opening the DOS library

Main		bsr		OpenLibs
		tst.l		d0
		beq		.Error1

; Open serial device for the really heavy stuff!

		bsr		OpenSer			open serial device
		tst.l		d0			ok?
		beq		.Error1			no, exit!

; Set pointer to command buffer

.ReadNextCmd	lea		CmdBuffer,a5		a5->buffer
		
; Read data from serial device one byte at a time.

.ReadNextChar	move.l		WriteReq,a1		a1-> IO request
		move.w		#CMD_READ,IO_COMMAND(a1) writing data
		move.l		#1,IO_LENGTH(a1)	number of bytes
		move.l		#buffer,IO_DATA(a1)	address of data
		CALLEXEC	DoIO			send message

; display data read

		move.b		buffer,(a5)+		copy byte to buffer

		move.l		std_out,d1		to CLI
		move.l		#buffer,d2		prmary buffer
		moveq.l		#1,d3			1 byte
		CALLDOS		Write			print it

		cmp.b		#$0d,buffer		
		beq.s		.done
		
		cmp.b		#$0a,buffer
		bne.s		.ReadNextChar

; Execute desired CLI command

.done		move.b		#0,-1(a5)		null terminate cmd
		bsr		DoCommand		and seervice it
		
		tst.l		d0			was quit selected?
		bne.s		.ReadNextCmd		no, so loop!

; Make sure prompt moves gracefully down

		move.b		#$0a,buffer
		move.l		std_out,d1
		move.l		#buffer,d2
		moveq.l		#1,d3
		CALLDOS		Write

; finished with serial device, so close it!

		bsr		CloseSer		close serial device

; Close DOS library as weve finished with it

.Error1		bsr		CloseLibs
		
; All Done so return

		moveq.l		#0,d0			no script errors
		rts

		****************************************
		*	   Deal with Commands	       *
		****************************************

DoCommand	moveq.l		#1,d0

		lea		CmdBuffer,a5
		cmp.b		#'*',(a5)+		is it a command?
		bne.s		.done			no, ignore it.

; Check for quit

		moveq.l		#0,d0
		cmp.b		#'Q',(a5)+
		beq.s		.done
		cmp.b		#'q',-1(a5)
		beq.s		.done

		move.b		-1(a5),d0		get byte
		addq.l		#1,a5			bump pointer
		
		cmp.b		#'Z',d0
		blt.s		.IsUpper
		sub.b		#'a'-'A',d0		convert to upper
		
; Check for *G, Get a file.

.IsUpper	cmp.b		#'G',d0
		bne.s		.TryDir
		bsr		GetFile
		bra		.AllOver

; Check for *D, directory

.TryDir		cmp.b		#'D',d0
		bne.s		.TryCli
		bsr		GetDir
		bra		.AllOver

; Check for *E, execute a CLI command

.TryCli		cmp.b		#'E',d0
		bne.s		.AllOver
		bsr		DoCLI
		bra		.AllOver
		
; All done so return

		nop
.AllOver	moveq.l		#1,d0
.done		rts

		****************************************
		*	 Copy A File Down Wire         *
		****************************************

;a5->filename

GetFile
		LOADFILE	a5
		
		move.l		a0,filebuf
		move.l		d0,filebufsize
		beq.s		.done
		
		bsr		ConvertLF
		
		move.l		WriteReq,a1		a1-> IO request
		move.w		#CMD_WRITE,IO_COMMAND(a1) writing data
		move.l		d0,IO_LENGTH(a1)	number of bytes
		move.l		a0,IO_DATA(a1)		address of data
		CALLEXEC	DoIO			send message

		move.l		filebuf,a1
		move.l		filebufsize,d0
		CALLEXEC	FreeMem

.done		rts

		****************************************
		*	 Send Required Directory       *
		****************************************

GetDir		lea		DirName,a0

.loop		move.b		(a5)+,(a0)+
		bne.s		.loop

		move.l		#DirComm,d1
		moveq.l		#0,d2
		moveq.l		#0,d3
		CALLDOS		Execute
		
		lea		dirfile,a5
		bsr		GetFile
		
		rts

		****************************************
		*	 Execute A CLI Command	       *
		****************************************

DoCLI		move.l		a5,d1
		moveq.l		#0,d2
		moveq.l		#0,d3
		CALLDOS		Execute
		
		rts


		****************************************
		*	 Replace $0a's with $0d's      *
		****************************************

; Entry a0->buffer
;	d0=length

ConvertLF	move.l		d0,-(sp)
		move.l		a0,-(sp)

.loop		subq.l		#1,d0
		beq.s		.done
		cmp.b		#$0a,(a0)+
		bne.s		.loop
		move.b		#$0d,-1(a0)
		bra.s		.loop

.done		move.l		(sp)+,a0
		move.l		(sp)+,d0
		rts


		****************************************
		*	 Open Required Libraries       *
		****************************************

OpenLibs	lea		dosname,a1		a1->library name
		moveq.l		#0,d0			any version
		CALLEXEC	OpenLibrary		open it
		move.l		d0,_DOSBase		save base pointer
		beq		.Error			exit on error

		CALLDOS		Output
		move.l		d0,std_out
		
		nop					DEBUG only
.Error		rts					and return

		****************************************
		*	   Close All Libraries	       *
		****************************************

CloseLibs	move.l		_DOSBase,d0
		beq		.Error			quit if not open
		move.l		d0,a1			a1-> lib base
		CALLEXEC	CloseLibrary		close it

.Error		rts

		****************************************
		*	  Open Serial Device	       *
		****************************************


		****************************************
		*	  Open Serial Device	       *
		****************************************

OpenSer		lea		pname,a0		a0->port name
		moveq.l		#0,d0			priority
		bsr		CreatePort		get a port
		move.l		d0,AccPort		save pointer
		beq		.Error1			exit if no port

; Create an IO structure for use with the port

		move.l		d0,a0			a0->port
		moveq.l		#IOEXTSER_SIZE,d0	size of structure
		bsr		CreateExtIO		get structure
		move.l		d0,WriteReq		save address
		beq		.Error2

; Open the serial device

		lea		sername,a0		a0->device name
		moveq.l		#0,d0			unit number
		move.l		WriteReq,a1		a1->IO structure
		moveq.l		#0,d0			no flags
		CALLEXEC	OpenDevice		open serial device
		tst.l		d0			open OK?
		bne		.Error3			no, exit now!

		moveq.l		#1,d0			no errors
		rts					so return

; Release the IO structure

.Error3		move.l		WriteReq,a1		a1->IO structure
		bsr		DeleteExtIO		release it

; Free the port

.Error2		move.l		AccPort,a0		a0->Port
		bsr		DeletePort		release it

		moveq.l		#0,d0			signal error

.Error1		rts					exit

		****************************************
		*	  Close Serial Device	       *
		****************************************

CloseSer	move.l		WriteReq,a1		a1->request
		CALLEXEC	CloseDevice		close serial device

; Release the IO structure

.Error3		move.l		WriteReq,a1		a1->IO structure
		bsr		DeleteExtIO		release it

; Free the port

.Error2		move.l		AccPort,a0		a0->Port
		bsr		DeletePort		release it

; all freed so return

		rts

		****************************************
		*	IO Routines by D.Edwards       *
		****************************************

		incdir		ACC29_A:Include/

		include		exec_support.i

		include		marks/MM_subs.i

		****************************************
		*	  Program Data Area	       *
		****************************************

pname		dc.b		'Amiganuts_Port',0
		even

sername		dc.b		'serial.device',0
		even

dosname		dc.b		'dos.library',0
		even

dirfile		dc.b		'ram:accdir.comm',0
		even

tempfile	dc.b		'ram:acctemp.comm',0
		even
temphandle	dc.l		0

_DOSBase	dc.l		0
std_out		dc.l		0		
AccPort		dc.l		0
WriteReq	dc.l		0

filebuf		dc.l		0
filebufsize	dc.l		0

; Commands

;		*E		execute CLI command
;		*D		directory
;		*G		get file -- doubling as type file at present
;		*T		type file
;		*Q		quit
;		*R		receive a file -- getting interactive :-)


DirComm		dc.b		'dir >ram:accdir.comm '
DirName		ds.b		100
		even

buffer		dc.b		0,$0a
		even

CmdBuffer	ds.b		100
