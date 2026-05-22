	opt	c-

	incdir	sys:include/
	include	exec/exec_lib.i
	include	exec/io.i
	include	exec/memory.i
	include	intuition/intuition.i
	include	intuition/intuition_lib.i
	include	libraries/dos_lib.i
	include	libraries/dos.i
	include	devices/trackdisk.i

CALLSYS	Macro
	jsr	_LVO\1(a6)
	Endm

; Arp includes take too long and you can't use opt c- with them

CALLARP	Macro
	move.l	_ArpBase,a6
	jsr	_LVO\1(a6)
	Endm

_LVOCreatePort	=-$132
_LVODeletePort	=-$138
_LVOFileRequest	=-$126
_LVOTackOn	=-$270

	move.l	#iotd_size,d0		; Reserve space for trackdisk io
	move.l	#MEMF_CLEAR+MEMF_PUBLIC,d1	; Clear and public memory
	CALLEXEC	AllocMem
	move.l	d0,a5		; Keep it an a5 for easy access
	beq	Quit
	lea	IntLib,a1	; Open intuition library
	moveq.l	#0,d0		; any version
	CALLSYS	OpenLibrary
	move.l	d0,_IntuitionBase	; Save base
	lea	ArpName,a1	; Open arp library
	moveq.l	#0,d0
	CALLSYS	OpenLibrary
	move.l	d0,_ArpBase	; Save base
	beq	FreeMem
	move.l	d0,a6		; Get it into a6
	moveq.l	#0,d0		; Create port with Arp - priority 0
	move.l	d0,a0		; No name (private port)
	CALLSYS	CreatePort
	move.l	a5,a1		; Save port address in io struct
	move.l	d0,mn_ReplyPort(a1)
	move.b	#nt_Message,ln_type(a1)	; Node type = a message
	move.b	#20,ln_pri(a1)		; Priority 20 (just felt like it)
	move.w	#iotd_size,mn_Length(a1)	; Length of trackdisk io
	lea	TDName,a0	; Name of device in a0
	moveq.l	#0,d0		; Use on df0:
	moveq.l	#0,d1		; No flags
	CALLEXEC	OpenDevice	; Open it
	tst.l	d0		; Error?
	bne	CloseArp

	lea	MainWindow,a0	; Open window
	CALLINT	OpenWindow
	move.l	d0,Window.ptr
	beq	CloseIO		; Exit on error
	move.l	d0,a0
	move.l	50(a0),Window.rp
	move.l	86(a0),Window.port
	move.l	50(a0),a0
	lea	MainWDText,a1	; Print window text
	moveq.l	#0,d0		; xpos
	moveq.l	#0,d1		; ypos
	CALLSYS	PrintIText
	move.l	Window.rp,a0	; Draw borders
	lea	MainWDBorder,a1
	moveq.l	#0,d0
	moveq.l	#0,d1
	CALLSYS	DrawBorder

GetMessage:
	move.l	Window.port,a0	; Wait for a message (yamn)
	CALLEXEC	WaitPort
	move.l	Window.port,a0	; What is it then?
	CALLSYS	GetMsg
	move.l	d0,a1
	beq	GetMessage
	move.l	im_Class(a1),d7	; Get cause in d7
	move.l	im_IAddress(a1),a4	; If gadgetup, points to gadget
	CALLSYS	ReplyMsg
	cmp.l	#GADGETUP,d7	; Gadget?
	bne	CheckClose	; No, see if its close window
	bsr	NoError		; Wipe error status
	move.l	gg_UserData(a4),a0	; Get routine address from structure
	jmp	(a0)		; And jump to it
CheckClose:
	cmp.l	#CLOSEWINDOW,d7	; Close window?
	bne	GetMessage	; No, wait a bit more

CloseUp:
	bsr	DeleteProg	; Free program memory
	move.l	Window.ptr,a0	; Close window
	CALLINT	CloseWindow

CloseIO:
	move.l	mn_ReplyPort(a5),a1	; Delete reply port
	CALLARP	DeletePort
	move.l	a5,a1		; And close the device
	CALLEXEC	CloseDevice
CloseArp:
	move.l	_ArpBase,a1	; Close the libraries
	CALLSYS	CloseLibrary
FreeMem:
	move.l	_IntuitionBase,a1
	CALLSYS	CloseLibrary
	move.l	#iotd_size,d0	; Free memory
	move.l	a5,a1
	CALLSYS	FreeMem
Quit:
	rts

LoadProg:
	bsr	Load		; Load file
	beq	GetMessage	; Quit if error or CANCEL selected
	move.l	d7,d0		; Make length divisible by 512:
	add.l	#512-$20,d0	; 1) take away length of Hunk header ($20)
				; 2) Add length of 1 sector (512)
	and.w	#$fe00,d0	; 3) Make it divisible by 512
	move.l	d0,UseLength	; Save modified length
	move.l	LoadAddr,d0	; The address to write from is $20 from
	add.l	#$20,d0		; start of file
	move.l	d0,WriteAddr
	bsr	DisplayLength	; Display length
	bra	GetMessage	; Back to the main loop
LoadBinary:
	bsr	Load		; Load file
	beq	GetMessage	; Exit on error
	move.l	d7,d0		; Much as before - except Write address
	add.l	#512,d0		; is the start of file, not $20 after it
	and.w	#$fe00,d0
	move.l	d0,UseLength
	move.l	LoadAddr,WriteAddr
	bsr	DisplayLength
	bra	GetMessage
Load:
	bsr	DeleteProg	; Delete any previous program from memory
	lea	FileReq,a0	; Point a0 to filerequester
	CALLARP	FileRequest	; Get filename
	tst.l	d0		; CANCEL selected?
	beq	Error		; Yep
	lea	PathName,a0	; Copy dirname to pathname
	lea	DirName,a1
.loop	move.b	(a1)+,(a0)+	; Copy a byte
	bne.s	.loop		; If not null terminator, copy another
	lea	PathName,a0	; Use TackOn to construct whole pathname
	lea	FileName,a1
	CALLSYS	TackOn
	move.l	#PathName,d1	; Lock file
	CALLSYS	Lock
	move.l	d0,FileLock	; Save it
	beq	LockError	; Quit now if error
	move.l	d0,d1		; Get lock in d1
	move.l	#fib,d2		; and address of fib in d2
	CALLSYS	Examine		; Examine file
	move.l	fib+fib_size,d7	; Get length of file in d7
	move.l	FileLock,d1	; Unlock file
	CALLSYS	UnLock
	move.l	d7,d0		; Reserve d7 bytes of chip memory
	moveq.l	#MEMF_Chip,d1
	CALLEXEC	AllocMem
	move.l	d0,LoadAddr	; Save addres
	beq	MemoryError	; cock up
	move.l	#PathName,d1	; Open file
	move.l	#MODE_OLDFILE,d2
	CALLARP	Open
	move.l	d0,FileLock
	move.l	d0,d1		; Read d7 bytes to address in LoadAddr
	move.l	LoadAddr,d2
	move.l	d7,d3
	CALLSYS	Read
	move.l	FileLock,d1	; Close file
	CALLSYS	Close
	moveq.l	#1,d0		; No error
Error:
	rts
LockError:
	lea	er_Lock,a0	; Error trying to lock file
	bra	PrintError
MemoryError:
	lea	er_Mem,a0	; Not enough memory
	bra	PrintError

DisplayLength:
	move.l	UseLength,d0	; Get length (in bytes)
	lsr.l	#5,d0		; Divide by 512
	lsr.l	#4,d0

; Convert number into decimal ascii

	lea	Number,a0	; Place to put ascii characters
	move.w	#1000,d2		; Get 1000ths first
	bsr	.loop		; Get ascii
	move.w	#100,d2		; Then 100ths
	bsr	.loop
	move.w	#10,d2		; Then 10ths
	bsr	.loop
	bsr	.loop2		; Add 1s (number left in d0)
	move.l	Window.rp,a0	; Print length
	lea	LengthText,a1
	moveq.l	#0,d0		; xpos
	moveq.l	#0,d1		; ypos
	CALLINT	PrintIText
	move.l	Window.rp,a0	; Draw the border round text
	lea	LengthBorder,a1
	moveq.l	#0,d0		; xpos
	moveq.l	#0,d1		; ypos
	CALLSYS	DrawBorder
	rts
.loop	divu	d2,d0		; Divide by number (1000, 100, etc)
.loop2	add.b	#48,d0		; Add 48 (ascii value of 0)
	move.b	d0,(a0)+		; Add it to ascii version of number
	clr.w	d0		; Get remainder in d0
	swap	d0		; for other units
	rts

DeleteProg:
	move.l	LoadAddr,d0	; Get address in d0
	beq	.end		; Quit if none loaded anyway
	move.l	d0,a1		; (move.l LoadAddr,a1 doesn't set CCs)
	move.l	d7,d0		; Length of program in d0
	CALLEXEC	FreeMem		; Free memory
	clr.l	LoadAddr		; No program loaded now
.end	rts

WriteToDisk:
	tst.l	LoadAddr		; Quit if no program loaded
	beq	GetMessage
	move.w	#TD_Motor,io_Command(a5)	; MOTOR command
	move.l	#1,io_Length(a5)		; Switch motor on
	move.l	a5,a1			; IO Structure in a5
	CALLEXEC	DoIo			; Do it!
	move.w	#CMD_Write,io_Command(a5)	; WRITE command
	move.l	WriteAddr,io_Data(a5)	; Address of data to write
	move.l	UseLength,io_Length(a5)	; Length of data to write
	move.l	SectorNumber,d0		; Get sector number
	cmp.l	#1760,d0			; Is it 1760 or more
	bcc	RangeError		; If so, too big
	lsl.l	#5,d0			; Multiply by 512
	lsl.l	#4,d0
	move.l	d0,io_Offset(a5)		; This is the sector offset
	move.l	a5,a1
	CALLSYS	DoIo

	move.l	d0,d6		; Save return code to test for errors

	move.w	#TD_Motor,io_Command(a5)	; MOTOR command
	move.l	#0,io_Length(a5)		; Switch motor off
	move.l	a5,a1
	CALLSYS	DoIo

	tst.l	d6		; Error during write?
	beq	.ok		; No, ok
	lea	er_Write,a0	; Say there was an error
	bsr	PrintError
.ok	bra	GetMessage
RangeError:
	lea	er_Range,a0	; Complain about sector number
	bsr	PrintError
	bra	GetMessage

DoHelp:
	lea	HelpWindow,a0
	CALLINT	OpenWindow
	move.l	d0,a4
	move.l	86(a4),a3
	move.l	50(a4),a0
	lea	HelpText,a1
	moveq.l	#0,d0
	moveq.l	#0,d1
	CALLSYS	PrintIText
.loop	move.l	a3,a0
	CALLEXEC	WaitPort
	move.l	a3,a0
	CALLSYS	GetMsg
	move.l	d0,a1
	beq	.loop
	move.l	a4,a0
	CALLINT	CloseWindow
	bra	GetMessage

NoError:
	lea	er_None,a0	; A row of spaces to wipe out other errors
PrintError:
	move.l	a0,ErrorAddr	; Save address of error in IText struct
	move.l	Window.rp,a0	; Print text
	lea	ErrorText,a1
	moveq.l	#0,d0		; xpos
	moveq.l	#0,d1		; ypos
	CALLINT	PrintIText
	rts

IOAddress:
	dc.l	0
_ArpBase:
	dc.l	0
_IntuitionBase
	dc.l	0
FileLock	dc.l	0
LoadAddr	dc.l	0
WriteAddr:
	dc.l	0
Window.ptr:
	dc.l	0
Window.rp:
	dc.l	0
Window.port:
	dc.l	0
UseLength:
	dc.l	0
ArpName:
	dc.b	'arp.library',0
IntLib:
	dc.b	'intuition.library',0
TDName:
	dc.b	'trackdisk.device',0
	even

MainWindow:
	dc.w	160
	dc.w	64
	dc.w	320
	dc.w	124
	dc.b	3
	dc.b	2
	dc.l	GADGETUP+CLOSEWINDOW
	dc.l	ACTIVATE+WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE
	dc.l	HelpGadg
	dc.l	0
	dc.l	WindowName
	dc.l	0
	dc.l	0
	dc.w	320
	dc.w	128
	dc.w	320
	dc.w	128
	dc.w	WBENCHSCREEN

HelpWindow:
	dc.w	160
	dc.w	64
	dc.w	320
	dc.w	104
	dc.b	0
	dc.b	3
	dc.l	GADGETUP
	dc.l	ACTIVATE+WINDOWDRAG+WINDOWDEPTH
	dc.l	HWGadg
	dc.l	0
	dc.l	HelpName
	dc.l	0
	dc.l	0
	dc.w	320
	dc.w	128
	dc.w	320
	dc.w	128
	dc.w	WBENCHSCREEN


HelpGadg:
	dc.l	LProgGadg
	dc.w	23,80
	dc.w	52,10
	dc.w	GADGHCOMP
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	StandBorder,0
	dc.l	.text,0,0
	dc.w	0
	dc.l	DoHelp
.text	dc.b	1,0,1,0
	dc.w	10,1
	dc.l	0,gt_Help,0

LProgGadg:
	dc.l	WriteGadg
	dc.w	97,80
	dc.w	52,10
	dc.w	GADGHCOMP
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	StandBorder,0
	dc.l	.text,0,0
	dc.w	0
	dc.l	LoadProg
.text	dc.b	2,0,1,0
	dc.w	10,1
	dc.l	0,gt_Load,0
WriteGadg:
	dc.l	QuitGadg
	dc.w	171,80
	dc.w	52,10
	dc.w	GADGHCOMP
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	StandBorder,0
	dc.l	.text,0,0
	dc.w	0
	dc.l	WriteToDisk
.text	dc.b	2,0,1,0
	dc.w	6,1
	dc.l	0,gt_Write,0
QuitGadg:
	dc.l	SectorGadg
	dc.w	245,80
	dc.w	52,10
	dc.w	GADGHCOMP
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	StandBorder,0
	dc.l	.text,0,0
	dc.w	0
	dc.l	CloseUp
.text	dc.b	1,0,1,0
	dc.w	10,1
	dc.l	0,gt_Quit,0
SectorGadg:
	dc.l	LBinGadg
	dc.w	127,58
	dc.w	48,8
	dc.w	GADGHCOMP
	dc.w	GADGIMMEDIATE+LONGINT
	dc.w	STRGADGET
	dc.l	0,0,0,0,SectorString
	dc.w	0
	dc.l	GetMessage
SectorString:
	dc.l	NoBuffer
	dc.l	0
	dc.w	0,5,5,0
	dc.w	0,0,0,0,0,0
SectorNumber:
	dc.l	0,0
NoBuffer	dc.b	'0',0,0,0,0,0
LBinGadg:
	dc.l	0
	dc.w	97,96
	dc.w	126,10
	dc.w	GADGHCOMP
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	.Border,0
	dc.l	.text,0,0
	dc.w	0
	dc.l	LoadBinary
.text	dc.b	2,0,1,0
	dc.w	19,1
	dc.l	0,gt_LBinary,0
.Border	dc.w	-1,-1
	dc.b	3,0,1,5
	dc.l	.Vector,0
.Vector	dc.w	0,0
	dc.w	125,0
	dc.w	125,11
	dc.w	0,11
	dc.w	0,0

StandBorder:
	dc.w	-1,-1
	dc.b	3,0,1,5
	dc.l	StandVectors,0
StandVectors:
	dc.w	0,0
	dc.w	53,0
	dc.w	53,11
	dc.w	0,11
	dc.w	0,0

MainWDText:
	dc.b	3,0,1,0
	dc.w	104,16
	dc.l	0,WindowName,.text
.text	dc.b	1,0,1,0
	dc.w	24,32
	dc.l	0,wdt_T1,.text1
.text1	dc.b	1,0,1,0
	dc.w	24,42
	dc.l	0,wdt_T2,.text2
.text2	dc.b	3,0,1,0
	dc.w	23,58
	dc.l	0,wdt_T3,0

MainWDBorder:
	dc.w	100,14
	dc.b	1,0,1,5
	dc.l	.Vector,.Border1
.Vector	dc.w	0,0
	dc.w	119,0
	dc.w	119,11
	dc.w	0,11
	dc.w	0,0
.Border1	dc.w	19,56
	dc.b	2,0,1,5
	dc.l	.Vector1,0
.Vector1	dc.w	0,0
	dc.w	151,0
	dc.w	151,11
	dc.w	0,11
	dc.w	0,0
LengthBorder:
	dc.w	187,56
	dc.b	2,0,1,5
	dc.l	.Vector2,0
.Vector2	dc.w	0,0
	dc.w	103,0
	dc.w	103,11
	dc.w	0,11
	dc.w	0,0

HWGadg:
	dc.l	0
	dc.w	126,88
	dc.w	68,10
	dc.w	GADGHCOMP
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	.Border,0
	dc.l	.text,0,0
	dc.w	0
	dc.l	0
.text	dc.b	1,0,1,0
	dc.w	26,1
	dc.l	0,gt_OK,0
.Border	dc.w	-1,-1
	dc.b	3,0,1,5
	dc.l	.Vector,.Border1
.Border1	dc.w	-5,-3
	dc.b	2,0,1,5
	dc.l	.Vector1,0
.Vector	dc.w	0,0
	dc.w	69,0
	dc.w	69,11
	dc.w	0,11
	dc.w	0,0
.Vector1	dc.w	0,0
	dc.w	77,0
	dc.w	77,15
	dc.w	0,15
	dc.w	0,0

HelpText:
	dc.b	2,0,1,0
	dc.w	8,20
	dc.l	0,ht_SecNo,.text
.text	dc.b	1,0,1,0
	dc.w	104,20
	dc.l	0,ht_Sec1,.text1
.text1	dc.b	1,0,1,0
	dc.w	8,28
	dc.l	0,ht_Sec2,.text2
.text2	dc.b	2,0,1,0
	dc.w	8,40
	dc.l	0,ht_Load,.text3
.text3	dc.b	1,0,1,0
	dc.w	56,40
	dc.l	0,ht_Load1,.text4
.text4	dc.b	1,0,1,0
	dc.w	8,48
	dc.l	0,ht_Load2,.text5
.text5	dc.b	2,0,1,0
	dc.w	8,60
	dc.l	0,ht_LBin,.text6
.text6	dc.b	1,0,1,0
	dc.w	112,60
	dc.l	0,ht_LBin1,.text7
.text7	dc.b	2,0,1,0
	dc.w	8,72
	dc.l	0,ht_Write,.text8
.text8	dc.b	1,0,1,0
	dc.w	64,72
	dc.l	0,ht_Write1,0

FileReq:
	dc.l	LoadProgText
	dc.l	FileName
	dc.l	DirName
	dc.l	0
	dc.b	0,0
	dc.l	0,0

ErrorText:
	dc.b	3,0,1,0
	dc.w	24,112
	dc.l	0
ErrorAddr:
	dc.l	0,0

LengthText:
	dc.b	3,0,1,0
	dc.w	191,58
	dc.l	0,Length,.text1
.text1	dc.b	1,0,1,0
	dc.w	255,58
	dc.l	0,Number,0

FileName:
	ds.b	34
DirName:
	ds.b	34
PathName:
	ds.b	68

WindowName:
	dc.b	'Sector Control',0
wdt_T1	dc.b	'LOAD an origin program into memory',0
wdt_T2	dc.b	'WRITE it to any sector on the disc',0
wdt_T3	dc.b	'Sector no. : ',0
HelpName:
	dc.b	'Sector Control Help',0

gt_Help	dc.b	'Help',0
gt_Load	dc.b	'Load',0
gt_Write	dc.b	'Write',0
gt_Quit	dc.b	'Quit',0
gt_LBinary
	dc.b	'Load Binary',0
gt_OK	dc.b	'OK',0

;		 ----|----*----|----*----|----*----|--*
ht_SecNo	dc.b	'Sector No.:',0
ht_Sec1	dc.b	'Range is 0 to 1759.',0
ht_Sec2	dc.b	'It is Sector + Surface*11 + Track*22',0
ht_Load	dc.b	'Load:',0
ht_Load1	dc.b	'This loads a program which has',0
ht_Load2	dc.b	'been assembled with the ORG directive',0
ht_LBin	dc.b	'Load Binary:',0
ht_LBin1	dc.b	'Loads a pure binary file'
ht_Write	dc.b	'Write:',0
ht_Write1
	dc.b	'Write loaded program to disk',0

LoadProgText:
	dc.b	'Load File',0

Length	dc.b	'Length:',0

Number	dc.b	0,0,0,0,0

; Errors:

er_Write	dc.b	'Sector write error!',0
er_Lock	dc.b	'Unable to lock file',0
er_Range	dc.b	'Sector out of range',0
er_Mem	dc.b	'Not enough memory',0
er_None	dc.b	'                   ',0

	cnop	0,4
fib	ds.b	256
