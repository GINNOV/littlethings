;####################################################################
;#
;#			Sampled Sound Player  
;#			--------------------
;#	   Written by S.Marshall for NewsFlash U.K.
;#         This code is public domain and may be freely copied
;#
;#    This was written mainly as an exersise in using audio device
;#    The code is a little messy as the program was made to be ripped
;#    appart and the subroutines re-used 
;#    This code was assembled with Devpac V2.12 and requires my
;#    Startup include file.This file does all the fiddly bits like
;#    parsing the command line,opening libraries,dealing with WorkBench 
;#    messages etc.
;#    This soundplayer will play IFF and raw samples,allow you to set
;#    the volume,number of times to repeat,samplerate or period and
;#    length of the file to play.This allows you to play silly buggers
;#    and repeat the first part of a sample to create nnnnnnn nineteen
;#    (ugh!) type effects.The code is OS legal re-entrant and re-executable
;#    so it works fine as a resident program in amigashell.Because the
;#    player works in stereo and is OS legal you can only have two versions
;#    playing at once.Till one frees it's channels others will fail and
;#    return to CLI.This program will also work from Workbench using
;#    extended select.  
;#
;####################################################################

	INCDIR		"SYS:include/"
	INCLUDE		exec/devices.i
	INCLUDE		exec/ports.i
	INCLUDE		graphics/gfxbase.i
	INCLUDE		devices/audio.i
	INCLUDE		devices/clipboard.i

;use this to set the library version number for DOS,Graphics,Icon and 
;Intuition libraries.Defaults to 0 (any version).For use with mystartup.i
;which opens and closes these for you.  	

Libversion	EQU	33	;OS V1.2	

;use this to allocate some memory on startup.If you need only one 
;block of memory this saves you the bother.See first line of code
;to see how to get address of this memory.Defaults to 0 (no memory)

StartMem	EQU	70	;allocate 70 bytes of memory

	INCLUDE		source_1:include/deftoolstartup.i

;------	this sets the default playback rate in DMA periods.It is only
;------ only used if for some reason there is no VHDR chunk.Set it to
;------ whatever value you wish.Value here conforms to Psound default

DefPeriod	EQU	359

Start:
	lea		temp(a5),a4		;get workspace address
	lea		Msg,a0			;get message address
	jsr		Print			;print message
	
	move.w		#1,Repeat(a4)		;set default repeats
	move.w		#64,Volume(a4)		;and volume
	
	tst.l		_WBenchMsg(a5)		;find how we started
	bne.s		NoCli			;branch if from WBench
	
	cmpi.l		#1,argc(a5)		;check for just 1 arg
	beq.s		Help			;give help if only 1 arg
	
	ARG		1,a0			;address of 2nd argument
	cmpi.b		#'?',(a0)		;check for help prompt
	bne.s		NoHelp			;branch if no help reqd
Help
	lea		HelpMsg,a0		;address of help message
	jsr		Print			;print it
	rts					;quit
NoHelp
	bsr		ParseCmd		;parse command line args
	
NoCli
	moveq		#127,d0			;set max pri
	bsr		OpenStereo		;open Audio and get channels
	tst.l		d0			;Check if device opened
	bne		DevErr			;if no device - quit
	bset 		#1,$bfe001  		;LED off
	
;------ check to see if <filename> exists and if it is a file or
;	a directory.Return with size in d0 or 0 if error 
	ARG		1,d1			;address of filename in d0
	bsr		FileSize		;check file and find size
	move.l		d0,TempSize(a4)		;store result
	beq		DevErr			;branch on error
	
	ARG		1,d1			;address of filename in d1
	move.l		#MODE_OLDFILE,d2	;open mode 
	CALLSYS		Open			;open file
	move.l		d0,FileHndl(a4)		;store file handle
	
	lea		50(a4),a0		;temp buffer in our memory
	move.l		d0,d1			;file handle in d1
	move.l		a0,d2			;buffer in a0
	moveq.l		#12,d3			;size to read
	CALLSYS		Read			;read file
		
	movea.l		d2,a0			;address of buffer
	cmp.l		#'FORM',(a0)		;is it IFF file
	bne.s		Not_IFF			;if not quit 
	move.l		4(a0),d0		;d0 = length of file -8
	cmp.l		#"8SVX",8(a0)		;is it 8 bit sampled sound
	bne		Not_Soundfile		;if not quit
	moveq		#0,d3			;set for first chunk
	bra.s		Chunkloop
Not_IFF
	move.l		TempSize(a4),d0
	tst.l		SmplSize(a4)		;check if user set length
	beq.s		.noSizeSet
	cmp.l		SmplSize(a4),d0		;if user set too long
	bls.s		.noSizeSet
	move.l		SmplSize(a4),d0		;set user size
	
.noSizeSet
	move.l		d0,SmplSize(a4)		;store file size used if raw
	ARG		1,a0			;address of arg[1] in a0
	jsr		Print			;print it
	lea		NotIFF,a0		;address of error message
	jsr		Print			;print it
	
	move.l		FileHndl(a4),d1		;get file handle
	moveq		#0,d2			;set seek position
	moveq		#-1,d3			;set mode OFFSET_BEGINING
	CALLSYS		Seek			;seek file start
	
	move.l		SmplSize(a4),d0		;Length of file
	bra		NoComp
	
Chunkloop:
	move.l		FileHndl(a4),d1		;get file handle
	bsr		GetChunk		;get chunk name
	tst.l		d0			;check result
	beq		Closefile		;if end of file before BODY
	
	cmpi.l		#'BODY',d0		;is it BODY
	beq.s		BODY_Found		;if yes branch and do BODY
	
	cmpi.l		#'VHDR',d0		;is it VHDR chunk
	bne.s		Chunkloop		;if not get next chunk
	
	move.l		FileHndl(a4),d1		;get file handle
	CALLSYS		Read			;read VHDR chunk
	move.l		d2,a0			;buffer address in a0
	move.b		15(a0),Comp(a4)		;save compression type
	move.w		12(a0),d0		;sample rate in d0

;------ convert sample rate to Bus cycles if not already set by user
	tst.w		Period(a4)
	bne.s		PeriodSet
	bsr		SmpltoCyc		;do samplerate conversion
	move.w		d0,Period(a4)		;store sample rate
PeriodSet
	moveq		#0,d3			;flag chunk already read
	bra.s		Chunkloop		;if not get next chunk
	
BODY_Found:
	ARG		1,a0			;address of arg[1] in a0
	jsr		Print			;print it
	lea		IsIFF,a0		;address of IFF message
	jsr		Print			;print it
	
	tst.l		SmplSize(a4)		;check if user set length
	beq.s		.noSizeSet
	cmp.l		SmplSize(a4),d3		;if user set too long
	bls.s		.noSizeSet
	move.l		SmplSize(a4),d3		;set user size
	cmpi.b		#1,Comp(a4)		;test if compressed 
	bne.s 		.noSizeSet
	lsr.l		#1,d3			;if so halve size
.noSizeSet
	move.l		d3,d0			;size of chunk in d0
	move.b		Comp(a4),d4		;get compression type
	cmpi.b		#1,d4			;check compresion type
	bhi		Closefile		;comp type not known -quit
	blt.s		NoComp			;no compression skip to body		
	
;------ file must be compressed Fibbonacci Delta
	add.l		d0,d0			;d0 = double chunk size 
	subq.l		#2,d0			;subtract 2 from chunk size
	bsr		GetBuffer		;allocate sample buffer memory
	beq		No_Memory		;quit if no memory
	
	move.l		FileHndl(a4),d1		;get File Handle
	move.l		d3,d2			;chunk size in d2
	 
	subq.l		#2,d2			;read buffer in top half
	add.l		Sample(a4),d2		;calc address of source buffer
	CALLSYS		Read			;read file
	
	move.l		d2,a0			;source in a0
	move.l		Sample(a4),a1		;destination in a1
	move.l		d3,d0			;length in d0
	subq.l		#2,d0			;-2 to allow for initial value
	move.w		(a0)+,d1		;initial value in d1 
	bsr		Fib_Delta		;decompress file
	lea		deltaMsg,a0		;message in a0
	jsr		Print			;print it
	bra.s		Sampleloaded		;skip uncompressed loader
	
NoComp
	bsr.s		GetBuffer		;allocate sample buffer memory
	beq.s		No_Memory		;quit if no memory
	move.l		FileHndl(a4),d1		;get file handle
	move.l		Sample(a4),d2		;allocated memory address
	move.l		SmplSize(a4),d3
	CALLSYS		Read			;read file

Sampleloaded:
	move.w		Period(a4),d0		;get period
	cmpi.w		#124,d0			;test sample rate 
	blt.s		.SetDef
	cmpi.w		#2000,d0
	blt.s		.PeriodOK		;skip if we have sample rate
.SetDef
	move.w		#DefPeriod,Period(a4)	;use default
	
.PeriodOK
	jsr		playsnd			;play the sample


De_Allocate:
	movea.l		Sample(a4),a1		;allocated memory address
	move.l		SmplSize(a4),d0		;size of memory
	CALLEXEC	FreeMem			;return memory to free pool		
	bra.s		Closefile		;skip error messages

Not_Soundfile:
	ARG		1,a0			;address of arg[1] in a0
	jsr		Print			;print it
	lea		NotSound,a0		;address of error message
	bra.s		PrintMsg		;skip other error messages
No_Memory:
	lea		Nomem,a0		;address of error message
PrintMsg:
	jsr		Print			;print it
Closefile:
	move.l		FileHndl(a4),d1		;file handle in d1
	beq.s		DevErr
	CALL		DOS,Close		;close file
DevErr:
	bsr		CloseStereo
Error:
	bclr		#1,$bfe001  		;LED on
	rts					;return to startup code

**************************************************************
;			SubRoutines
**************************************************************	
;routine to allocate Chip memory to store the sample
;	Buffer = GetBuffer(size)
;	  d0		    d0  
GetBuffer:
	move.l		a6,-(sp)		;store a6
	cmpi.l		#262144,d0		;is sample >262144 (max size)
	bls.s		.small			;if < skip next instruction
	move.l		#262144,d0		;set d6 to max size
.small
	move.l		d0,SmplSize(a4)		;store sample size
	moveq		#MEMF_CHIP,d1		;type of memory required
	CALLEXEC	AllocMem		;get memory
	move.l		d0,Sample(a4)		;store memory address
	move.l		(sp)+,a6		;restore a6
	rts
	
;---------------------------------------------------------------------
;routine to skip through IFF chunks returning name and size
;size is returned in d3 ready for next call
;	Name = GetChunk(file,buffer,size)
;	 d0		 d1    d2    d3 
GetChunk:
	tst.l		d3			;is this first chunk
	beq.s		.First			;if yes skip this
	movem.l		d1-d2,-(sp)		;store regs
	move.l		d3,d2			;length in d2
	moveq		#0,d3			;seek mode in d3
	CALLSYS		Seek			;move to point in file
	movem.l		(sp)+,d1-d2		;restore regs
.First
	moveq		#8,d3			;length to read in d3
	CALLSYS		Read			;read name and length
	tst.l		d0			;read ok?
	beq.s 		.Error			;if error return error msg
	move.l		d2,a0			;buffer in a0
	move.l		(a0)+,d0		;name in d0 
	move.l		(a0)+,d3		;chunk length in d3
;------ round chunk length up to next word boundry
	addq.l		#1,d3			;add 1 to length 
	bclr		#0,d3			;make d3 even
.Error
	rts					;return with error or name in d0

;---------------------------------------------------------------------
;routine to parse the command line tail.Simple example of
;how to deal with multiple options.Command is made upper 
;case if it was lower case.This way we only need to check 
;for upper case chars.It's not very friendly to only except
;lower case.Someone ought to tell Commodore:-)
ParseCmd:
	movem.l		d6-d7/a2,-(sp)		;save regs
	lea		8+argvArray(a5),a2	;address of 3rd arg ptr
	move.l		argc(a5),d7		;number of args in d7
	subq.l		#2,d7			;ignore unwanted args
.argloop
	move.l		(a2)+,a0		;pointer to next arg
	move.b		(a0)+,d0		;address of arg
	cmpi.b		#'-',d0			;does it start with -
	bne.s		.NoPeram		;if not branch and ignore
	move.b		(a0)+,d6		;get first letter
	jsr		Asctobin		;convert rest to binary 
	cmpi.b		#$60,d6			;uppercase or lowercase
	blt.s		.UCase			;branch if uppercase
	subi.b		#$20,d6			;convert to uppercase
.UCase
	cmpi.b		#'S',d6			;is it S
	bne.s		.NotS			;branch if not
	bsr		SmpltoCyc		;if it is convert number
	move.w		d0,Period(a4)		;and store
	bra.s		.NoPeram		;skip rest

.NotS	cmpi.b		#'P',d6			;is it P
	bne.s		.NotP			;branch if not
	move.w		d0,Period(a4)		;if it is store it
	bra.s		.NoPeram		;skip rest

.NotP	cmpi.b		#'R',d6			;is it R
	bne.s		.NotR			;branch if not
	move.w		d0,Repeat(a4)		;if it is store it	
	bra.s		.NoPeram		;skip rest
	
.NotR	cmpi.b		#'L',d6			;is it L
	bne.s		.NotL			;branch if not
	bclr		#0,d0			;round d0 down
	move.l		d0,SmplSize(a4)		;if it is store it	
	bra.s		.NoPeram		;skip rest
	
.NotL	cmpi.b		#'V',d6			;is it V
	bne.s		.NoPeram		;if not skip rest
	move.w		d0,Volume(a4)		;if it is store it
.NoPeram
	dbra		d7,.argloop		;branch till done
	movem.l		(sp)+,d6-d7/a2
	rts
;---------------------------------------------------------------------
;Routine to test if a pathname exists and if it is a file or 
;a directory.If pathname is a directory or doesn't exist then
;an error is returned (0).Otherwise the file size is returned.

;	size = FileSize(name)
;	 d0              d1  
FileSize:
	movem.l		d2/d6-d7,-(sp)		;save regs
	CLEAR		d6			;clear reg d6
	moveq		#ACCESS_READ,d2		;Access_Read = -2
	CALLSYS		Lock			;get lock
	move.l		d0,d7			;store Lock
	beq.s		.LockError		;branch if error
	
	move.l		#fib_SIZEOF,d0		;size of fileinfo block
	move.l		#MEMF_PUBLIC!MEMF_CLEAR,d1 ;memory type
	CALLEXEC	AllocMem		;allocate memory
	move.l		d0,d2			;store Fileinfo block
	beq.s		.MemError		;branch if no memory
	
	move.l		d7,d1			;lock in d1
	CALL		DOS,Examine		;examine file
	move.l		d2,a1			;fileinfo address in a0
	tst.l		d0			;test result
	beq.s		.ExError		;branch on error
	tst.l		fib_DirEntryType(a1)	;test if file
	bpl.s		.ExError		;branch if a directory
	move.l		fib_Size(a1),d6		;Store length 

.ExError
	move.l		#fib_SIZEOF,d0		;fileinfo size
	CALLEXEC	FreeMem			;free memory
.MemError	
	move.l		d7,d1			;lock in d1
	CALL		DOS,UnLock		;UnLock File
	
.LockError
	move.l		d6,d0			;result in d0
	movem.l		(sp)+,d2/d6-d7		;restore regs
	rts

;---------------------------------------------------------------------
;Sample rate to bus cycle conversion routine.Calculates correct
;cycles on both PAL and NTSC systems.
;	Cycles = SmpltoCyc(SampleRate)
;	  d0		      d0
SmpltoCyc:
	tst.l		d0			;trap divide by 0 errors
	beq.s		.error			;branch if 0 samplerate
	move.l		_GfxBase(a5),a0		;graphics lib base in a0
	move.w		gb_DisplayFlags(a0),d1	;does DisplayFlags = PAL
	btst		#2,d1
	beq.s		.Ntsc 			;branch if not PAL
	move.l		#3546895,d1		;constant for PAL
	bra.s		.OK			;constant set do conversion
.Ntsc
	move.l		#3579545,d1		;constant for NTSC	
.OK
	divu		d0,d1			;do converion
	moveq		#0,d0			;clear d0
	move.w		d1,d0			;bus cycles in d0
.error	rts					;return with result in d0

;---------------------------------------------------------------------
;Routine to uncompress Fibonacci Delta compressed files
;	lastvalue = Delta_Fib(source,destination,length,initialvalue)
;	   d0			a0	  a1       d0       d1		

Fib_Delta:
	movem.l		d2-d3/a2,-(sp)		;save regs
	lea		.delta(pc),a2		;address of delta array in a2
	moveq		#0,d2			;clear d2
	moveq		#0,d3			;clear d3
.loop
	move.b		(a0)+,d2		;get data from buffer
	move.l		d2,d3			;and copy to d3
	lsr.b		#4,d2			;shift out low nibble
	add.b		0(a2,d2.w),d1		;add delta to sample
	move.b		d1,(a1)+		;store result
	and.b		#$0f,d3			;mask out high nibble
	add.b		0(a2,d3.w),d1		;add delta to sample
	move.b		d1,(a1)+		;store result
	subq.l		#1,d0			;decrement loop (dbra not large enough)
	bne.s		.loop			;branch until finished
	movem.l		(sp)+,d2-d3/a2		;restore regs
	move.l		d1,d0			;last value returned in d0
	rts					;finished
	
;----- this is the table of delta's used to calculate the samples 
;----- value.They are Fibonacci series numbers hence Fibonacci Delta
.delta	
	dc.b		-34,-21,-13,-8,-5,-3,-2,-1
	dc.b		0,1,2,3,5,8,13,21

;---------------------------------------------------------------------
;Create a port and add it to the system list enter with pointer to port 
;name in a0 exit with port address in d0 or 0 if port cannot be created
;this is not quit a full creatport routine a la amiga.lib but does for
;most needs.Priority is set to 0.I'll add the rest when I get round to it
;	port = CreatPort(name)
;	d0		  a0

CreatePort:	
	movem.l		d7/a4-a6,-(sp)	;save regs
	movea.l		a0,a5		;name ptr in a5
	moveq		#-1,d0		;request any signal
	CALLEXEC	AllocSignal	;allocate signal
	move.l		d0,d7		;store signal in d7
	bmi.s		.No_Signal	;neg ? - no signal allocated
	
	moveq		#MP_SIZE,d0	;port size in d0
	move.l		#MEMF_PUBLIC!MEMF_CLEAR,d1 ;mem type
	CALLSYS		AllocMem	;allocate memory
	movea.l		d0,a4		;mem pointer in a4 
	beq.s		.No_Port	;quit if no memory
	
	sub.l		a1,a1		;clear a0 (find own task)
	CALLSYS		FindTask	;find ourselves
	move.l		d0,MP_SIGTASK(a4) ;task into msg port
	move.b		d7,MP_SIGBIT(a4)  ;signal into port
	move.l		a5,LN_NAME(a4)	;name of port
	movea.l		a4,a1		;pointer to port in a1	
	CALLSYS		AddPort		;add port to system list
	move.l		a4,d0		;port address in d0
	bra.s		.Port_OK	;quit with port in d0

.No_Port:
	move.l		d7,d0		;signal in d0 
	CALLSYS		FreeSignal	;free it

.No_Signal
	moveq		#0,d0		;flag error

.Port_OK
	movem.l		(sp)+,d7/a4-a6	;restore regs
	rts
	
;---------------------------------------------------------------------
;routine to open Audio device and allocate a Stereo pair of channels

OpenStereo:
	movem.l		d7/a6,-(sp)		;store regs
	move.l		d0,d7			;save audio priority
	lea		Portname,a0		;address of port name
	bsr.s		CreatePort		;create port
	move.l		d0,Port(a4)		;store port address
	beq.s		.PortError		;if no port then quit	

	bsr		CreateIOB		;create an AudioIOB
	move.l		d0,AudIOB(a4)		;store pointer as AudIOB 
	beq.s		.PortError		;no IOB then quit
	
;------ initialise AudIOB structure
	movea.l		AudIOB(a4),a1		;IOB address in a1
	
;------ set maximum audio priority (127) if you don't want to lock the
;	channels that you allocated.
	move.b		d7,LN_PRI(a1)		;set audio priority
	move.l		Port(a4),MN_REPLYPORT(a1) ;set audio replyport

;------ tell audio device that we want channels allocating 
	move.w		#ADCMD_ALLOCATE,IO_COMMAND(a1) 
	move.l		#AllocMap,ioa_Data(a1)	;pointer to allocation map
	moveq		#4,d0			;size of map = 4 bytes
	move.l		d0,ioa_Length(a1)	;set map length
	
	moveq		#0,d0			;clear d0 (unit)
	moveq		#0,d1			;clear d1 (flags)
	lea		AudName,a0		;device name in a0
	CALLSYS		OpenDevice		;open device
	bra.s		.done

;------ if OpenDevice returns a zero then the channels have been 
;	allocated.If priority was max then these channels cannot be 
;	stolen and are ours until we release them.Also it is now
;	quite legal to hit the hardware as the system knows that
;	we have sole use of these channels and will not let another 
;	legal program interfere with us. 
.PortError
	moveq		#-1,d0			;error message in d0
.done
	movem.l		(sp)+,d7/a6		;restore regs
	rts

;------ Allocation map to select any stereo pair of channels

AllocMap:				;L R R L  
	
	dc.b		3		;0 0 1 1  = 3
	dc.b		5		;0 1 0 1  = 5
	dc.b		10		;1 0 1 0  = 10
	dc.b		12		;1 1 0 0  = 12

	
;---------------------------------------------------------------------
CloseStereo:
;------ closing the Audio device will free the channels allocated

	move.l		a6,-(sp)		;store a6
	tst.l		AudIOB(a4)		;test for IOB
	beq.s		.NoIOB			;branch if no IOB
	move.l		AudIOB(a4),a1		;AudIOB in a1
	tst.l		IO_DEVICE(a1)		;check for device
	bmi.s		.NoDev			;skip if no device
	CALLEXEC	CloseDevice		;close Audio device
.NoDev
	move.l		AudIOB(a4),d0		;AudIOB in d0
	bsr		DeleteIOB		;delete AudIOB
.NoIOB	
	move.l		Port(a4),d0		;port in d0
	bsr.s		DeletePort		;delete port
	move.l		(sp)+,a6		;restore a6
	rts

;---------------------------------------------------------------------
;Routine to delete a message port 
;	DeletePort(port)
;	            d0
DeletePort:	
	tst.l		d0			;test for valid port
	beq.s		.NoPort			;branch if no port
	movem.l		a5-a6,-(sp)		;save a5
	movea.l		d0,a5			;save d0
	moveq		#0,d0			;clear d0
	move.b		MP_SIGBIT(a5),d0	;signal in d0
	CALLEXEC	FreeSignal		;free the signal
	movea.l		a5,a1			;restore a1
	CALLSYS		RemPort			;remove port from system list
	moveq		#MP_SIZE,d0		;port size in d0
	movea.l		a5,a1			;restore a1 = port address
	CALLSYS		FreeMem			;free memory
	movem.l		(sp)+,a5-a6		;restore a5
.NoPort
	rts

;---------------------------------------------------------------------
;Routine to allocate memory for Audio IO block.Error if d0 = 0
;	IOB = CreatIOB()
;	d0 
CreateIOB:	
	moveq		#ioa_SIZEOF,D0		;size of Audio IO
	move.l		#MEMF_PUBLIC!MEMF_CLEAR,d1 ;memory type
	CALLEXEC	AllocMem		;allocate memory
	rts	

;---------------------------------------------------------------------
;Subroutine to play a sampled sound,takes parameters from structure pointed
;to by a4 - see end of file for offsets

playsnd:
	movem.l		d3-d7/a2/a6,-(sp)	;store regs
	bsr.s		CreateIOB		;create an AudioIOB
	move.l		d0,PlayIOB(a4)		;store pointer as PlayIOB
	beq		.IOBErr			;if no IOB then quit
		
	bsr.s		CreateIOB		;create an AudioIOB
	move.l		d0,Play2IOB(a4)		;store pointer as Play2IOB
	beq		.IOBErr			;if no IOB then quit

	bsr.s		CreateIOB		;create an AudioIOB
	move.l		d0,Play3IOB(a4)		;store pointer as Play3IOB
	beq		.IOBErr			;if no IOB then quit

	bsr.s		CreateIOB		;create an AudioIOB
	move.l		d0,Play4IOB(a4)		;store pointer as Play4IOB
	beq		.IOBErr			;if no IOB then quit

;------ Stop both allocated channels so we can set them up then start 
;	them both together.Events will be qued up until we start the 
;	channels again.	

	move.w		Repeat(a4),d4
	subq.w		#1,d4
		
.RepeatSmpl
	movea.l		AudIOB(a4),a1		;AudIOB in a1

	move.b		#IOF_QUICK,IO_FLAGS(a1)	;do quick IO 
	move.w		#CMD_STOP,IO_COMMAND(a1) ;command = STOP
	BEGINIO					;stop both channels
	
	movea.l		PlayIOB(a4),a1		;PlayIOB in a1
	btst		#0,IO_FLAGS(a1)		;has quick flag been cleared
	bne		.IOBErr			;if not quit
	
;------ audio device can only play samples up to 131072 (128K) bytes 
;	long in one go.We will split file into two and play it in two 
;	halves queueing up events.This will allow us to play samples 
;	up to 256K long.Samples longer than this may be played but
;	we would have to use double buffering.
	move.l		SmplSize(a4),d6		;sample size in d6
	lsr.l		#1,d6			;halve it - play in two halves

;------ round it down to even address as audio hardware can only fetch
;	data in words.Rounding up would mean playing past end of file
	bclr		#0,d6			

	movea.l		AudIOB(a4),a2		;AudIOB in a2
	movea.l		PlayIOB(a4),a1		;PlayIOB in a1
	bsr		CopyIOB			;initialise PlayIOB
	move.b		IO_UNIT+3(a2),d3	;channels in d3
	move.b		d3,IO_UNIT+3(a1)	;channels in PlayIOB
	andi.b		#9,IO_UNIT+3(a1)	;mask for left channels
	move.b		#ADIOF_PERVOL!IOF_QUICK,IO_FLAGS(a1) ;set period and vol
	move.l		Sample(a4),ioa_Data(a1)	;set address of sample
	move.l		d6,ioa_Length(a1)	;set length of sample
	move.w		Period(a4),ioa_Period(a1)   ;set playback period
	move.w		Volume(a4),ioa_Volume(a1)   ;set volume
	move.w		#1,ioa_Cycles(a1)  	 ;number of times to play sample
	move.w		#CMD_WRITE,IO_COMMAND(a1) ;command = WRITE
	BEGINIO					;play left channel

	movea.l		PlayIOB(a4),a1		;PlayIOB in a1
	btst		#0,IO_FLAGS(a1)		;has quick flag been cleared
	bne		.IOBErr			;if not quit

	movea.l		PlayIOB(a4),a2		;PlayIOB in a2
	movea.l		Play2IOB(a4),a1		;Play2IOB in a1
	bsr		CopyIOB			;initialise PlayIOB
	move.b		d3,IO_UNIT+3(a1)	;channels in PlayIOB
	andi.b		#6,IO_UNIT+3(a1)	;mask for left channels
	move.b		#ADIOF_PERVOL!IOF_QUICK,IO_FLAGS(a1) ;set period and vol
	move.l		Sample(a4),ioa_Data(a1)	;set address of sample
	move.l		d6,ioa_Length(a1)	;set length of sample
	move.w		#CMD_WRITE,IO_COMMAND(a1) ;command = WRITE
	BEGINIO					;play left channel
	
	movea.l		Play2IOB(a4),a1		;Play2IOB in a1
	btst		#0,IO_FLAGS(a1)		;has quick flag been cleared
	bne		.IOBErr			;if not quit
	
	move.l		Sample(a4),d5
	add.l		d6,d5

	movea.l		PlayIOB(a4),a2		;PlayIOB in a2
	movea.l		Play3IOB(a4),a1		;Play3IOB in a1
	bsr		CopyIOB			;initialise PlayIOB
	move.b		d3,IO_UNIT+3(a1)	;channels in PlayIOB
	andi.b		#9,IO_UNIT+3(a1)	;mask for left channels
	move.b		#ADIOF_PERVOL!IOF_QUICK,IO_FLAGS(a1) ;set period and vol
	move.l		d5,ioa_Data(a1)		;set address of sample
	move.l		d6,ioa_Length(a1)	;set length of sample
	move.w		#CMD_WRITE,IO_COMMAND(a1) ;command = WRITE
	BEGINIO					;play left channel
	
	movea.l		Play3IOB(a4),a1		;Play3IOB in a1
	btst		#0,IO_FLAGS(a1)		;has quick flag been cleared
	bne		.IOBErr			;if not quit

	movea.l		PlayIOB(a4),a2		;lockIOB in a2
	movea.l		Play4IOB(a4),a1		;PlayIOB in a1
	bsr		CopyIOB			;initialise PlayIOB
	move.b		d3,IO_UNIT+3(a1)	;channels in PlayIOB
	andi.b		#6,IO_UNIT+3(a1)	;mask for right channels
	move.b		#ADIOF_PERVOL,IO_FLAGS(a1) ;set period and vol
	move.l		d5,ioa_Data(a1)		;set address of sample
	move.l		d6,ioa_Length(a1)	;set length of sample
	move.w		#CMD_WRITE,IO_COMMAND(a1) ;command = WRITE
	BEGINIO					;play left channel
	
;------ as we stopped both channels nothing will have been played
;------ so far,the commands will have been queued up.To get both
;------ channels to start playing together we must issue 
;------ command CMD_START

	movea.l		AudIOB(a4),a1		;AudIOB in a1		
	move.b		#IOF_QUICK,IO_FLAGS(a1)	;do quick IO
	move.w		#CMD_START,IO_COMMAND(a1) ;command = START
	BEGINIO					;start both channels playing

	
	movea.l		Port(a4),a1		;Play4IOB in a1
	move.l		#$1000,d0		;control C mask (SIGBREAKF_CTRL_C)
	moveq		#0,d1			;clear d1
	move.b		MP_SIGBIT(a1),d1	;msgport signal number in d1
	bset		d1,d0			;change to mask and or it with d0
	move.l		d0,d7			;store d0
;------ wait for ctrl c or message arriving at msg port
	CALLSYS		Wait			

	btst		#12,d0			;test for ctrl c
	bne.s		.CtrlCErr		;branch if ctrl c
	
;------ wait for ctrl c or message arriving at msg port
	move.l		d7,d0			;restore mask in d0
	CALLSYS		Wait			;wait for ctrl c or msg

	btst		#12,d0			;test for ctrl c
	bne.s		.CtrlCErr		;branch if ctrl c

;------ remove all messages from port - just to be tidy really
;	if there was an error we should have already quit
.Portloop
	move.l		Port(a4),a0		;port address in a0
	CALLSYS		GetMsg			;get the massage
	tst.l		d0			;test result
	bne.s		.Portloop		;branch till port clear
	
;------ we shouldn't need to do this but if we don't the sample
;	tends to sound slightly different when repeated
	movea.l		AudIOB(a4),a1		;AudIOB in a1		
	move.w		#CMD_RESET,IO_COMMAND(a1) ;command = RESET
	CALLSYS		DoIO			;reset device
		
	tst.w		Repeat(a4)		;check if we run forever (0)
	beq		.RepeatSmpl		;branch if forever
	dbra		d4,.RepeatSmpl		;count & branch if not finished
	
;------ reset device and stop all IO before we clean up or we 
;	may run into trouble (very likely)
.CtrlCErr
	movea.l		AudIOB(a4),a1		;AudIOB in a1		
	move.w		#CMD_RESET,IO_COMMAND(a1) ;command = RESET
	CALLSYS		DoIO			;reset device

;------ clean up - free memory used by IOB's
.IOBErr
	move.l		Play4IOB(a4),d0		;Play4IOB in d0
	bsr.s		DeleteIOB		;delete PlayIOB

	move.l		Play3IOB(a4),d0		;Play3IOB in d0
	bsr.s		DeleteIOB		;delete Play3IOB

	move.l		Play2IOB(a4),d0		;Play2IOB in d0
	bsr.s		DeleteIOB		;delete Play2IOB

	move.l		PlayIOB(a4),d0		;PlayIOB in d0
	bsr.s		DeleteIOB		;delete PlayIOB
	movem.l		(sp)+,d3-d7/a2/a6	;restore regs
	rts

;---------------------------------------------------------------------
;Free memory used for AudioIO blocks a1 = IOB

DeleteIOB:	
	tst.l		d0			;do we have an IOB
	beq.s		.NoIOB			;if not then quit
	move.l		d0,a1			;memory address in a1
	moveq		#ioa_SIZEOF,d0		;size in d0
	CALLSYS		FreeMem			;free memory
.NoIOB
	rts
		
;---------------------------------------------------------------------
;copy information between Audio request blocks,a2 = source a1 = destination

CopyIOB:	
	move.l		MN_REPLYPORT(a2),MN_REPLYPORT(a1)
	move.l		IO_DEVICE(a2),IO_DEVICE(a1)
	move.w		ioa_AllocKey(a2),ioa_AllocKey(a1)
	move.w		ioa_Period(a2),ioa_Period(a1)
	move.w		ioa_Volume(a2),ioa_Volume(a1)	
	move.w		ioa_Cycles(a2),ioa_Cycles(a1)	
	rts

**************************************************************	
	SECTION	 AUDIODATA,DATA
**************************************************************	

	;------ Audio device and Port names
		
AudName:	AUDIONAME

Portname:
	dc.b		"Sound Example",0

	;------ Text for error messages

Msg:	
	dc.b	$0a,$9b,'1mIFF and RAW SoundPlayer',$9b,'0m by'
	dc.b	$9b,'3;33m S. Marshall',$0a,$9b
	dc.b	'0;31m      for ',$9b,'33;42m  NewsFlash UK  '
	dc.b	$9b,'0;31m',$0a,0

HelpMsg:
	dc.b	"USAGE: SndPlayer <Filename> -S<Samplerate>"
	dc.b	" -P<Period> -R<Repeats> -V<Volume> -L<Length>",$0a,0

deltaMsg:
	dc.b	'File compressed Fibonacci Delta',$0a,0
	
NotIFF:
	dc.b	' is a RAW file',$0a,0

NotSound:
	dc.b	' is IFF but not an 8SVX file',$0a,0
	
IsIFF:
	dc.b	' is an IFF 8SVX file',$0a,0
	
Nomem:
	dc.b	'Not enough CHIP memory',$0a,0
	EVEN
	
;---------------------------------------------------------------------
;------ Offsets used to create structure used by playsnd routine
;	First 6 should be initialised.The last 4 are for internal use 
	
	rsreset
Sample		rs.l	1	;sample start address pionter
SmplSize	rs.l	1	;size of sample (and memory buffer)
Period		rs.w	1	;audio playback rate in DMA periods
Volume		rs.w	1	;playback volume
Repeat		rs.w	1	;Number of times to repeat sample
AudIOB		rs.l	1	;pointer to AudIOB

PlayIOB		rs.l	1	;pointer to PlayIOB
Play2IOB	rs.l	1	;pointer to Play2IOB
Play3IOB	rs.l	1	;pointer to Play2IOB
Play4IOB	rs.l	1	;pointer to Play2IOB

;------	other pointers and variables used by main program

Port		rs.l	1	;pointer to replyport
FileHndl	rs.l	1	;pointer to File handle
TempSize	rs.l	1	;temp storage for file size
Comp		rs.b	1	;Delta Fibbonacci compression flag
 
