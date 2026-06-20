
*
*    COOLCOPY: Version 1.00
*	
*    ©1991 By Raistlin.
*
     Section	CoolCopy,code	; Public memory

******************

; Tabs settings=12

; The Includes
	Section	CoolCopy,code	; Public memory

	incdir	'df0:include/'	; The include dir
	include	'exec/exec.i'
	include	'exec/exec_lib.i'
	include	'misc/powerpacker_lib.i'
	include	'misc/arpbase.i'
	include	'misc/ppbase.i'

******************

CALLSYS 	MACRO			; Basic Macro
	jsr	_LVO\1(a6)
	ENDM
	
******************



; First lets save the CLI parameters (if there where any)

	move.b	#0,-1(a0,d0)	; Place a NULL byte inplace of the $0a
	move.l	a0,Parameters	; Save the parameters
	move.l	d0,Parameterslen	; Save length of params


****************************************************************************
;---------- Lets Clear the Flags
****************************************************************************
	move.b	#0,DecrunchFlag
	move.b	#0,HelpFlag
	move.b	#0,ArpFlag
	move.b	#0,EraseFlag
	move.b	#0,WildFlag

	move.b	#0,OpenError
	move.b	#0,ReadError
	move.b	#0,MemError
	move.b	#0,CryptedError
	move.b	#0,PasswordError
	move.b	#0,UnknownError


OptionCheck
; Check that thier is a valid file name in the parameter list before
; Continuing to build the destination & source file names
	move.l	Parameters,a0	; A0=Parameters
	cmpi.b	#'?',(a0)		; see if thus guy needs help
	bne	.CheckArp		; If not check for arp
	move.b	#1,HelpFlag		; Set the help flag
	bra	LoadDos		; Load the Dos lib.
.CheckArp	cmpi.b	#$0,(a0)		; Is there a file name?
	beq	Arp		; If not
	cmpi.b	#'-',(a0)		; Just options present?
	beq	Options


****************************************************************************
;---------- Get useful information from the parameters list
****************************************************************************
; Make the name of the source file
	move.l	#PathBuffer1,a1	; A1=Address of PathBuffer1
MakeSourceName
	cmpi.b	#' ',(a0)		; End of Source file name?
	beq	.to		; If so check for 'To'
	move.b	(a0)+,(a1)+		; Else build the file name
	bra	MakeSourceName

; Was the word 'to' used between the file names?
.to
	move.l	a1,a4		; Save last address of source
	cmpi.b	#'t',1(a0)		; Try 'to'
	bne	.TO		; branch to
	cmpi.b	#'o',2(a0)		; .TO if not
	bne	.DestFile		; equal
	bra	.Space
	
.TO
	cmpi.b	#'T',1(a0)		; Try 'TO'
	bne	.DestFile		; branch to .DestFile
	cmpi.b	#'O',2(a0)		; if not equal
	bne	.DestFile

; Just make sure the 'to' wasn't part of the file name
.Space	cmpi.b	#' ',3(a0)		; Check the 'To' aint
	bne	.DestFile		; part of the dest. name
	add.l	#3,a0		; Point to destination file
				; name	

; Is there a destination file (do a simple delete function?)
.DestFile
	cmpi.b	#'-',1(a0)		; Is there a destination file
	bne	MDN		; If yes skip next part
	cmpi.b	#'e',2(a0)		; Does he wish to delete file
	bne	.DIR		; If not try directory
	bsr	LoadDos2		; Open the Dos library
	bsr	DelFile		; Perform a simple delete
	bra	Clean_up		; And exit

; Does the user want to create a directory?
.DIR
	cmpi.b	#'c',2(a0)		; Does he wish to MAKEDIR?
	bne	MDN		; If not skip next part
	bsr	LoadDos2		; Open the dos library
	bsr	MakeDir		; Make the directory
	bra	Clean_up		; And exit


; Make the name of the destination file
MDN	add.l	#1,a0		; Get past the space
	move.l	#PathBuffer2,a1	; A1=PathBuffer2
MakeDestinationName
	cmpi.b	#' ',(a0)		; End of dest. name?
	beq	WildCards
	cmpi.b	#$0,(a0)		; Null byte?
	beq	WildCards
	move.b	(a0)+,(a1)+		; Else build the file name
	bra	MakeDestinationName


; Find out if WildCard was specified
WildCards
	cmpi.b	#'?',-1(a4)		; Test for the
	bne	TestDestFileName	; Wild card
	cmpi.b	#'#',-2(a4)
	bne	TestDestFileName
	move.b	#1,WildFlag		; Set the wildflag
	move.b	#$0,-(a4)		; Delete the #?
	move.b	#$0,-(a4)		; for later
	cmpi.b	#$0,(a0)
	beq	LoadDos
	bra	IncOptions

; If no destination file name was specified use sources file name
TestDestFileName
	cmpi.b	#':',-1(a1)		; Was a destination
	beq	.SourceDest		; name specified?	
	cmpi.b	#'/',-1(a1)		; If yes leave
	bne	IncOptions		
.SourceDest
	move.l	a1,a3		; Save address of options
	
.Loop	cmpi.b	#'/',-1(a4)		; Find the start address
	beq	.DestFileName	; of the source file
	cmpi.b	#':',-1(a4)		; name
	beq	.DestFileName
	sub.l	#1,a4		
	bra	.Loop	

.DestFileName
	cmpi.b	#$0,(a4)		; End of file name?
	beq	IncOptions		; If so do the options
	move.b	(a4)+,(a3)+		; Build the file name
	bra	.DestFileName	; Keep building that name


; Get to the options 	
IncOptions
	cmpi.b	#$0,(a0)		; Options specified?
	beq	LoadDos		; If so jmp to LoadDos
	add.l	#2,a0		; Get a0 to point two bytes
				; after space
****************************************************************************
;---------- See what options where chosen
****************************************************************************
Options
	cmpi.b	#'-',(a0)		; - for option in a0?
	bne	.Nope
	add.l	#1,a0		; If so get to option
.Nope
	cmpi.b	#'D',(a0)		; Is decrunch set with 'D'?
	bne	.d?		; If not big D try little D
	bra	.SetDecrunchFlag	; else set the decrunch flag
.d?	cmpi.b	#'d',(a0)		; Is decrunch set with 'd'?
	bne	.TryEraseFlag	; If not try the Erase Flag
.SetDecrunchFlag
	move.b	#1,DecrunchFlag	; Set the decrunch flag
	add.l	#1,a0		; Increment a0
	cmpi.b	#'-',(a0)		; Another option to follow?
	bne	.TryArpFlag		; If not try the arp flag
	add.l	#1,a0		; Else get to second option


.TryEraseFlag	
	cmpi.b	#'E',(a0)		; Is erase set with 'E'?
	bne	.e		; If not try little 'e'
	bra	.SetEraseFlag	; else set the erase flag
.e	cmpi.b	#'e',(a0)		; Is erase set with 'e'?
	bne	.TryArpFlag		; If not try arp flag
.SetEraseFlag
	move.b	#1,EraseFlag	; Set erase flag


.TryArpFlag
	move.l	Parameters,a0	; Get to beginning of 
				; parameters list
	cmpi.b	#'-',(a0)		; Is Arp set with a options?
	bne	.NULL		; If not try a NULL byte
	bra	.SetArpFlag		; else set the Arp Flag
.NULL	cmpi.b	#$0,(a0)		; Set with a NULL?
	bne	LoadDos		; If not load dos lib
.SetArpFlag	
Arp	move.b	#1,ArpFlag		; Set the ArpFlag

****************************************************************************
;---------- This section loads the relevant libraries
****************************************************************************

LoadDos
	lea	dosname,a1		; name of lib in a1
	moveq.l	#0,d0		; Any version
	CALLEXEC	OpenLibrary		; Open the lib
	move.l	d0,_DOSBase		; Save the base address
	beq	NoDos		; error


LoadPowePacker
	cmpi.b	#1,DecrunchFlag	; Is PP library needed?
	bne	LoadArp		; If not how about the arp?
	lea	ppname,a1		; a1=name of library
	moveq.l	#0,d0		; Any version
	CALLEXEC	OpenLibrary		; Open the lib
	move.l	d0,_PPBase		; Save the base address
	beq	NoPP		; error


LoadArp
	cmpi.b	#1,ArpFlag		; Is arp library needed?
	bne	Start		; If not go to main program
	lea	arpname,a1		; a1=name of library
	moveq.l	#0,d0		; Any version
	CALLEXEC	OpenLibrary		; Open the lib
	move.l	d0,_ArpBase		; Save the base adddress
	beq	NoArp
	bra	Start		; Branch to the main program

LoadDos2	lea	dosname,a1		; A1=name of lib
	moveq.l	#0,d0		; Any version
	CALLEXEC	OpenLibrary		; Close the library
	move.l	d0,_DOSBase		; Save base address
	beq	NoDos		; Leave if erro
	rts


****************************************************************************
;-----------The main program starts here
****************************************************************************
Start	cmpi.b	#1,HelpFlag		; Does he need help?
	beq	DisplayTemplate	; If so display the tremplate

	cmpi.b	#1,WildFlag		; WildFlag set?
	bne	.NoWildFlag
	bsr	WildRoutine1
.WildFlag
	cmpi.b	#1,WildFlag
	bne	.NoWildFlag
	bsr	WildRoutine2
.NoWildFlag
	cmpi.b	#1,ArpFlag		; Does he want a reqester?
	bne	.DecrunchFile
	bsr	LoadReqester	; If so display a file req.
	tst.l	d0		; Was cancel selected?
	beq	Clean_up		; If so quit


.DecrunchFile
	cmpi.b	#1,DecrunchFlag	; Does he want the file 
	bne	.DosLoad		; decrunching?
	bsr	DecrunchFile	; If so decrunch the file
	tst.l	d7		; error?
	bne	Errors
	bra	.ArpSave?


.DosLoad	bsr	LoadFile		; Load file the dos way
	tst.l	d7		; error?
	bne	Errors


.ArpSave?	cmpi.b	#1,ArpFlag		; Does he want a file req?
	bne	.DosSave		; Else do it with dos
	bsr	SaveRequester	; display a file reqester
	tst.l	d0		; Was cancel selected?
	beq	Clean_up		; If so quit

.DosSave	bsr	SaveFile		; Save the file
	tst.l	d7		; error?
	bne	Errors

.EraseFile
	cmpi.b	#1,EraseFlag	; Erase the source file?
	bne	.WildCard?
	bsr	DelFile		; Else delete the file
.WildCard?	cmpi.b	#1,WildFlag		; WildFlag set?
	beq	Start		; If so get next file
	bra	Clean_up		; & Clean_up




		
****************************************************************************
;-----------O.K. lets clean-up the system & keep on good terms with EXEC
****************************************************************************
Clean_up
.CloseArp
	cmpi.b	#1,ArpFlag		; Was Arp lib loaded?
	bne	.NoNeedArp
	bsr	CloseArp
.NoNeedArp
error1	cmpi.b	#1,DecrunchFlag	; Was PP lib loaded?
	bne	CloseDos
	bsr	ClosePP
CloseDos
error2	move.l	_DOSBase,a1		; Address of DOS lib in a1
	CALLEXEC	CloseLibrary

error3	rts			; quit



****************************************************************************
;-----------Two subroutines to close the PP & Arp libs 
****************************************************************************
ClosePP
	move.l	_PPBase,a1
	CALLEXEC	CloseLibrary
	rts
CloseArp
	move.l	_ArpBase,a1
	CALLEXEC	CloseLibrary
	rts



****************************************************************************
;-----------Exctract the filenames for the wildcard function
****************************************************************************
WildRoutine1
	move.l	#PathBuffer1,d1	; D1=Address of dir to lock
	move.l	#ACCESS_READ,d2	; D2=Access mode
	CALLDOS	Lock		; Lock the directory
	move.l	d0,DirKey		; Save the key
;	ERROR ROUTINE
	
; Allocate some memory for the file block info structure
	move.l	#fib_SIZEOF,d0	; D0=Amount to reserve
	move.l	#MEMF_PUBLIC,d1	; D1=Type
	CALLEXEC	AllocMem		; Allocate it
	move.l	d0,WCfile_info	; Save the address of mem
;	ERROR ROUTINE

; Examine the file info block (FIB)
	move.l	DirKey,d1
	move.l	WCfile_info,d2
	CALLDOS	Examine		; Examine the FIB
	rts

WildRoutine2
; Get the next file name
	move.l	DirKey,d1
	move.l	WCfile_info,d2
	CALLDOS	ExNext
;	ERROR ROUTINE
	move.l	WCfile_info+8,FileBuffer2 ; Address of files name
	rts

****************************************************************************
;----------  Display a file reqester for choosing the Source file
****************************************************************************
LoadReqester
	lea	FileStruct1,a0	; A0=File Structure
	move.l	_ArpBase,a6		; A6=Arp Base
	CALLSYS	FileRequest		; Show the requester

	tst.l	d0		; Did user cancel?
	bne	.OK	
	rts			; If so return
.OK	
	lea	PathBuffer1,a0	; A0=Address of Pathbuffer
	lea	FileBuffer1,a1	; A1=Address of Filebuffer
	CALLSYS	TackOn		; Get the full pathname
	rts			; and return


****************************************************************************
;---------- Decrunch the file
****************************************************************************	
DecrunchFile
	lea	PathBuffer1,a0	; A0=name of file to load
	moveq.l	#DECR_COL0,d0	; D0=Decrunch options
	moveq.l	#MEMF_PUBLIC,d1	; D1=Memory options	
	lea	Buffer,a1		; Space for address of buffer
	lea	Length,a2		; Space for length of buffer
	move.l	#0,a3		; No password
	move.l	_PPBase,a6		; A6=PowerPacker lib base
	CALLSYS	ppLoadData		; Load the file
	tst.l	d0		; Test for an error
	bne	.PPerror		; Tell user of error
	rts			; And return to main branch
				; Routine
.PPerror
	cmpi.l	#PP_OPENERR,D0	; Unable to open file
	bne	_a
OpenErr	move.b	#1,OpenError
	move.l	#1,d7		; My error code
	rts
_a	cmpi.l	#PP_READERR,D0	; Unable to read file
	bne	_b
ReadErr	move.b	#1,ReadError
	move.l	#1,d7		; My error code
	rts
_b	cmpi.l	#PP_NOMEMORY,D0	; Not enough memory
	bne	_c
MemErr	move.b	#1,MemError
	move.l	#1,d7		; My error code
	rts
_c	cmpi.l	#PP_CRYPTED,D0	; File is encrypted
CryptErr	bne	_d
	move.b	#1,CryptedError
	move.l	#1,d7		; My error code
	rts
_d	cmpi.l	#PP_PASSERR,D0	; Wrong password
PassErr	bne	_e
	move.b	#1,PasswordError
	move.l	#1,d7		; My error code
	rts
_e	cmpi.l	#PP_UNKNOWNPP,D0	; Crunched by unknown Packer
UnknownErr	move.b	#1,UnknownError
	move.l	#1,d7		; My error code
	rts

****************************************************************************	
;--------- Load a File
****************************************************************************
LoadFile	
	move.l	#fib_SIZEOF,d0	; D0=length of file to load
	move.l	#MEMF_PUBLIC,d1	; D1=memory type
	CALLEXEC	AllocMem		; Allocate memory
	move.l	d0,RFfile_info	; Save the memory pointer
	beq	MemErr		; Quit if there is an error
	
; Having allocated meory lets lock the file
	move.l	#PathBuffer1,d1	; D1=address of file to lock
	move.l	#ACCESS_READ,d2	; D2=Access mode
	CALLDOS	Lock		; Lock the file
	move.l	d0,RFfile_lock	; Save the key value
	beq	OpenErr		; Branch if there is an error

; Now lets load the file information block to find the size of the file
	move.l	d0,d1		; D1=Key value
	move.l	RFfile_info,d2	; D2=Address to load file 
				; info block
	CALLDOS	Examine		; The the FIB	

; Copy the length of the file into RFfile_len
	move.l	RFfile_info,a0	; A0=Address of FIB
	move.l	fib_Size(a0),RFfile_len	; Find length of the file

; Now relase the file
	move.l	RFfile_lock,d1	; D1=Key value
	CALLDOS	UnLock		; Unlock the file
	
; Release the allocated meory
	move.l	RFfile_info,a1	; A1=Address of mem to free
	move.l	#fib_SIZEOF,d0	; D0=length of memory to free
	CALLEXEC	FreeMem		; Free the memory


; Load the file
	move.l	RFfile_len,d0	; D0=Size of mem to allocate
	move.l	#MEMF_PUBLIC+MEMF_CLEAR,d1 ; D1=Memory type
	CALLEXEC	AllocMem		; Allocate the memory
	move.l	d0,Buffer		; Space for address of buffer
	beq	MemErr		; Branch to error routine if 
				; not enough memory
; Open the file for reading
	move.l	#PathBuffer1,d1	; D1=Address of file name
	move.l	#MODE_OLDFILE,d2	; D2=Access mode
	CALLDOS	Open		; Open the file
	move.l	d0,filehd		; Save file handle
	beq	OpenErr		; Open the file

; Read the data from the file into the buffer
	move.l	filehd,d1		; D1=File handle
	move.l	Buffer,d2		; D2=Address of buffer
	move.l	RFfile_len,d3	; D3=Max No. of bytes to load
	CALLDOS	Read		; Read the file
	move.l	d0,Length		; Save number of bytes read

; Close the file
	move.l	filehd,d1		; D1=file handle
	CALLDOS	Close		; Close the file
	
	move.l	#0,d7		; No errors
	rts			; And return to main 
				; branching routine


****************************************************************************
;--------- Save Requester
****************************************************************************
SaveRequester
	lea	FileStruct2,a0	; A0=File Structure
	move.l	_ArpBase,a6		; A6=Arp lib base
	CALLSYS	FileRequest		; Show requester

	tst.l	d0		; Did user cancel?
	bne	.OK	
	rts			; If so return
.OK	
	lea	PathBuffer2,a0	; A0=Address of Pathbuffer
	lea	FileBuffer2,a1	; A1=Address of Filebuffer
	CALLSYS	TackOn		; Get the full pathname
	rts			; and return




****************************************************************************
;-------- Save the file
****************************************************************************
SaveFile
	move.l	#PathBuffer2,d1	; A0=File name
	move.l	#MODE_NEWFILE,d2	; D2=Access mode
	CALLDOS	Open		; Open the file
	move.l	d0,filehd		; Save handle
	bne	.NoOpenErr		; Branch if no error
	move.b	#1,OpenError2	; Set-up error
	move.l	#1,d7		; Codes
	rts			; And return

.NoOpenErr

;  Write contents of the buffer into the new file
	move.l	filehd,d1		; D1=Files handle
	move.l	Buffer,d2		; D2=Address of buffer
	move.l	Length,d3		; D3=Size of Buffer
	CALLDOS	Write		; Write the code

;  Close the file
	move.l	filehd,d1		; D1=Files handle
	CALLDOS	Close		; Close the file
	
; Release the buffer
	move.l	Buffer,a1		; A1=Address of buffer
	move.l	Length,d0		; D0=Size allocated
	CALLEXEC	FreeMem		; Free the memory
	
	move.l	#0,d7		; No errors
	rts			; And return



****************************************************************************
;---------- Delete The Source File 
****************************************************************************
DelFile
				; D1=Address holding name of
	move.l	#PathBuffer1,d1	; File to delete
	CALLDOS	DeleteFile		; Delete the file
	rts


****************************************************************************
;---------- Create A Directory
****************************************************************************
MakeDir
	move.l	#PathBuffer1,d1	; D1=Address of dir name
	CALLDOS	CreateDir		; Create the directory
	move.l	d0,d1		; Key value in d1
	CALLDOS	UnLock		; Unlock the directory
	rts




****************************************************************************
;----------- Display the Template
****************************************************************************
DisplayTemplate
	CALLDOS	Output		; Get the output handle

	move.l	d0,d1		; D1=Output handle
	move.l	#HelpMsg,d2		; D2=Address of msg
	move.l	#HelpMsgLen,d3	; D3=Length of msg

	CALLDOS	Write		; Display the template
	bra	Clean_up		; And clean_up











****************************************************************************
;-----------Inform the user which library could not be opened
****************************************************************************
NoDos
	CALLDOS	Output		; Get the CLI output handle
	move.l	d0,d1		; D1=CLI handle
	move.l	#NoDosText,d2	; Address of msg in d2
	move.l	#NoDosLen,d3	; Length of msg
	CALLDOS	Write		; Write the msg
	bra	error3		; exit

NoPP
	CALLDOS	Output		; Get the CLI ouputhandle	
	move.l	d0,d1
	move.l	#NoPPText,d2	; address of msg iun d2
	move.l	#NoPPLen,d3		; lenght of msg
	CALLDOS	Write		; Write the msg
	bra	error2

NoArp	
	CALLDOS	Output		; Get the CLI output jhandle
	move.l	d0,d1
	move.l	#NoArpText,d2
	move.l	#NoPPLen,d3
	CALLDOS	Write
	bra	error1




****************************************************************************
;---------- Inform the user why a file cannot be opened/copied
****************************************************************************
Errors
	cmpi.b	#1,OpenError	; Opening Error?
	bne	.OpenError2
	CALLDOS	Output		; Get Cli output handle
	move.l	d0,d1		; D1=Cli Handle
	move.l	#OpenMsg1,d2	; D2=Address of message
	move.l	#OpenLen1,d3	; D3=Length of message
	CALLDOS	Write		; Write the message
	bra	Clean_up		; & Clean_up
	

.OpenError2
	cmpi.b	#1,OpenError2	; OpenError2 Error?
	bne	.ReadError 
	CALLDOS	Output
	move.l	d0,d1
	move.l	#OpenMsg2,d2
	move.l	#OpenLen2,d3
	CALLDOS	Write
	bra	Clean_up


.ReadError	cmpi.b	#1,ReadError	; Reading Error?
	bne	.MemoryError 
	CALLDOS	Output
	move.l	d0,d1
	move.l	#ReadMsg,d2
	move.l	#ReadLen,d3
	CALLDOS	Write
	bra	Clean_up


.MemoryError 
	cmpi.b	#1,MemError		; Memory Error?
	CALLDOS	Output
	move.l	d0,d1
	move.l	#MemMsg,d2
	move.l	#MemLen,d3
	CALLDOS	Write
	bra	Clean_up

****************************************************************************
;-----------The Variables	
****************************************************************************

*********** Name of the librarys to load
dosname	dc.b	'dos.library',0
	even
ppname	dc.b	'powerpacker.library',0
	even
arpname	dc.b	'arp.library',0

	even

********** Space for base addresses of libraries
_DOSBase	dc.l	0
_PPBase	dc.l	0
_ArpBase	dc.l	0


********** Addresses to hold data on CLI parameters
Parameters	dc.l	0
Parameterslen dc.l	0
DFS	dc.l	0	; Holds address of where the destination
			; File name should go.

********** The flags
HelpFlag	dc.b	0
EraseFlag	dc.b	0
ArpFlag	dc.b	0
DecrunchFlag dc.b	0
WildFlag	dc.b	0

OpenError	dc.b	0
OpenError2	dc.b	0
ReadError	dc.b	0
MemError	dc.b	0
CryptedError dc.b	0
PasswordError dc.b	0
UnknownError dc.b	0

	even



********** The File structure
; Load file requester
FileStruct1
	dc.l	Greeting1
	dc.l	FileBuffer1
	dc.l	PathBuffer1
	dc.l	0
	dc.b	0
	dc.b	0
	dc.l	0
	dc.l	0

Greeting1	dc.b	'CoolCopy -Select File To Load',0
	even
FileBuffer1	ds.b	60
	even
PathBuffer1	ds.b	60

	even

; Save file requester
FileStruct2
	dc.l	Greeting2
	dc.l	FileBuffer2
	dc.l	PathBuffer2
	dc.l	0
	dc.b	0
	dc.b	0
	dc.l	0
	dc.l	0

Greeting2	dc.b	'CoolCopy -Name of File to Save',0
	even
FileBuffer2	ds.b	60
	even
PathBuffer2	ds.b	60
	even



*********** General data for file manipulation
Buffer	dc.l	0
Length	dc.l	0

DirKey	dc.l	0

filehd	dc.l	0

RFfile_lock	dc.l	0
RFfile_info	dc.l	0
RFfile_len	dc.l	0

WCfile_info	dc.l	0


*********** The Text to be displayed
;---------- The help template
HelpMsg	dc.b	$9b,"7;30;31m"	; Colour text
	dc.b	'CoolCopy'
	dc.b	$9b,"0;30;33m"
	dc.b	' From DragonMasters/Unity '
	dc.b	$9b,"0;30;31m"
	dc.b	'Coded by '
	dc.b	$9b,"3;31;32m"
	dc.b	'Raistlin',$0a
	dc.b	$9b,"0;30;31m"
	dc.b	'[USEAGE]',$0a
	dc.b	'CoolCopy [-D][-E] <RETURN> ... for ARP file reqester',$0a
	dc.b	'or',$0a
	dc.b	'CoolCopy <File> -E   ... To delete a file',$0a
	dc.b	'or',$0a
	dc.b	'CoolCopy <DirName> -C  ... To create a dir',$0a
	dc.b	'or',$0a      
	dc.b	'CoolCopy <Source> To <Destination> [-D][-E]',$0a,$0a
	dc.b	'-D=Decrunch Option  -E=Erase Source File option',$0a
	dc.b	'*NB if choosing two options dont leave a space between the options!',$0a
	dc.b	$0a
	dc.b	'Greets to:-',$0a
	dc.b	'           FM, Tech, Mark Meany, MasterBeat, NotMan, TreeBeard, Nipper',$0a
HelpMsgLen	equ	*-HelpMsg


;----------- The error messages for the libs
NoDosText	dc.b	'Couldnt open the DOS library, is your Amiga knackered?',$0a
NoDosLen	equ	*-NoDosText

NoPPText	dc.b	'The Decrunch option requires the PowerPacker library in the LIBS dir',$0a
NoPPLen	equ	*-NoPPText

NoArpText	dc.b	'The ARP file reqester option requires the ARP library in the LIBS dir',$0a
NoArpLen	equ	*-NoArpText

;---------- The error messages for the files
OpenMsg1 	dc.b	'Couldnt open the source file!',$0a
OpenLen1	equ	*-OpenMsg1

OpenMsg2	dc.b	'Couldnt open the destination file!',$0a
OpenLen2	equ	*-OpenMsg2

ReadMsg	dc.b	'Couldnt read the source file!',$0
ReadLen	equ	*-ReadMsg

MemMsg	dc.b	'Not Enough Memory! Try Closing windows, etc.',$0a
MemLen	equ	*-MemMsg

	even


