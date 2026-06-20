;-----------------------------------------------------------------------
;
;	Example of using the Trackdisk device to write bootblocks.
;	    These subroutines are fairly crude but work OK.
;			    By S. Marshall
;		      Compiles with Devpac V2.14
;
;-----------------------------------------------------------------------

	INCDIR		sys:Include/
	Include		Exec/exec_lib.i
	Include		Exec/memory.i
	Include		Exec/io.i
	Include		Devices/trackdisk.i

;*****************************************

CALLSYS	MACRO
	IFGT	NARG-1		 
	FAIL	!!!		   
	ENDC
	JSR	_LVO\1(A6)
	ENDM
		
;*****************************************

Start
	lea		diskbuffer,a0		;get bootblock data
	bsr		Checksum		;and checksum it
	
	moveq		#0,d0			;drive number 0 (df0:)
	bsr.s		OpenTrackDisk		;open trackdisk device
	cmpi.l		#-1,d0			;test for device error
	beq.s		NoTrackDisk		;branch on error
	
	move.l		a0,diskio		;save TD_IOB
	move.l		a0,d0			;TDIOB in d0
	bsr		ProtectState		;test write protect tab
	tst.l		d0			;test result
	bne.s		Protected		;branch if protected
	
	lea		diskbuffer,a0		;get data buffer
	move.l		diskio(pc),d0		;and TD_IOB
	moveq		#0,d1		;Offset = 0 (block 0 or boot block)
	moveq		#2,d2			;Length = 2 sectors
	bsr		PutSector		;write to disk

	move.l		diskio(pc),d0		;get TD_IOB
	bsr		MotorOff		;turn motor off
	
Protected
	move.l		diskio(pc),d0		;get TD_IOB
	bsr.s		CloseTrackDisk		;close Trackdisk device

NoTrackDisk
	rts

;-----------------------------------------------------------------------
;	Subroutine to open trackdisk device. Called as
;	TD_IOB=OpenTrackDisk (Drive)
;	  d0		        d0
;	Where drive is the drive number (0 to 3 for df0: to df3:)
;-----------------------------------------------------------------------
OpenTrackDisk:
	movem.l		d6/d7,-(sp)		;save regs
	move.l		d0,d7			;save d0 (drive number)
	lea		Portname(pc),a0		;get port name
	bsr		CreatePort		;and create a port
	move.l		d0,d6			;store result
	beq.s		error2			;branch on error
	
	moveq		#IOTD_SIZE,d0		;port size in d0
	move.l		#MEMF_PUBLIC!MEMF_CLEAR,d1 ;mem type
	CALLEXEC	AllocMem		;allocate memory
	beq.s		No_IOB			;quit if no memory
	movea.l		d0,a1			;mem pointer in a1 
	
	
	move.l		d6,MN_REPLYPORT(a1)	;store port in TD_IOB
	move.l		d7,d0			;unit number 0 = DF0: etc.
	moveq		#0,d1			;flags - none
	lea		trackdiskname(pc),a0	;device name
	move.l		a1,-(sp)		;store a1
	CALLSYS		OpenDevice		;open trackdisk
	move.l		(sp)+,a1		;TD_IOB in a1
	tst.l		d0			;test for device error
	bne.s		DevError		;branch on error
	move.l		a1,a0			;TD_IOB in a0
	movem.l		(sp)+,d6/d7		;restore regs	
	rts

;-----------------------------------------------------------------------
;	Subroutine to close trackdisk device. Called as
;	CloseTrackDisk (TD_IOB)
;			 d0
;-----------------------------------------------------------------------
CloseTrackDisk
	movem.l		d6/d7,-(sp)		;save regs
	move.l		d0,d7			;save d0 (TD_IOB)
	move.l		d0,a1			;get io struct
	move.l		MN_REPLYPORT(a1),d6	;save port address
	CALLEXEC	CloseDevice		;close trackdisk
	
	movea.l		d7,a1			;a1 = TD_IOB address

DevError	
	moveq		#IOTD_SIZE,d0		;port size in d0
	CALLSYS		FreeMem			;free memory

No_IOB
	move.l		d6,d0			;get port 
	bsr		DeletePort		;and delete it
error2
	movem.l		(sp)+,d6/d7		;restore regs
	moveq		#-1,d0		;flag error (used by OpenTrackDisk)
	rts

;-----------------------------------------------------------------------
;	Subroutine to test disks Write protect status. Called as
;	State=ProtectState (TD_IOB)
;	  d0		      d0
;-----------------------------------------------------------------------
ProtectState:	
	move.l		d7,-(sp)		;store d7
	move.l		d0,d7			;store d0
	move.l		d0,a1			;TD_IOB in a1
	move.w		#TD_PROTSTATUS,IO_COMMAND(a1) ;check
	CALLEXEC	DoIO			;for disk write protection
	move.l		d7,a1			;io request struct
	move.l		IO_ACTUAL(a1),d0	;result in d0
	move.l		(sp)+,d7		;restore d7
	rts

;-----------------------------------------------------------------------
;	Subroutine to Write Sectors to disk. Called as
;	PutSector (Buffer,TD_IOB,Offset,Length)
;		     a0     d0     d1     d2
;	Where Offset and Length are in sectors
;-----------------------------------------------------------------------
PutSector:	
	movem.l		d6/d7,-(sp)		;store d6 + d7
	move.l		d0,d7			;save d0
	move.l		d0,a1			;a1 = TD_IOB
	move.w		#CMD_WRITE,IO_COMMAND(a1) ;write
	move.l		a0,IO_DATA(a1)		;pointer to buffer
	move.l		#TD_SECTOR,d6		;sector len in d6
	mulu		d6,d1			;calc Offset
	move.l		d1,IO_OFFSET(a1)	;offset
	mulu		d6,d2			;calc length
	move.l		d2,IO_LENGTH(a1)	;length of file
	CALLEXEC	DoIO			;do write
	
;------	we really ought to do some error checking here
;	to make sure data was written correctly

	move.l		d7,a1
	move.w		#CMD_UPDATE,IO_COMMAND(a1) ;update will flush buffers

	CALLSYS		DoIO			;force write to disk
	
	movem.l		(sp)+,d6/d7		;store d6 + d7
	rts

;-----------------------------------------------------------------------
;	Subroutine to Read Sectors from disk. Called as
;	ReadSector (Buffer,TD_IOB,Offset,Length)
;		     a0     d0     d1     d2
;	Where Offset and Length are in sectors
;-----------------------------------------------------------------------
ReadSector:	
	movem.l		d6/d7,-(sp)		;store d6 + d7
	move.l		d0,d7			;save d0
	move.l		d0,a1			;a1 = TD_IOB
	move.w		#CMD_READ,IO_COMMAND(a1) ;write
	move.l		a0,IO_DATA(a1)		;pointer to buffer
	move.l		#TD_SECTOR,d6		;sector len in d6
	mulu		d6,d1			;calc Offset
	move.l		d1,IO_OFFSET(a1)	;offset
	mulu		d6,d2			;calc length
	move.l		d2,IO_LENGTH(a1)	;length of file
	CALLEXEC	DoIO			;do write
	
;------	we really ought to do some error checking here
;	to make sure data was read correctly

	movem.l		(sp)+,d6/d7		;store d6 + d7
	rts

;-----------------------------------------------------------------------
;	Subroutine to switch drive motor off. Called as
;	MotorOff (TD_IOB)
;		    d0
;-----------------------------------------------------------------------
MotorOff
	move.l		d0,a1			;get io struct
	move.w		#TD_MOTOR,IO_COMMAND(a1);command motor
	move.l		#0,IO_LENGTH(a1)	;motor off

	CALLEXEC	DoIO			;switch off motor
	rts

;-----------------------------------------------------------------------
;Create a port and add it to the system list enter with pointer to port 
;name in a0 exit with port address in d0 or 0 if port cannot be created
;this is not quit a full creatport routine a la amiga.lib but does for
;most needs.Priority is set to 0.I'll add the rest when I get round to it
;	port = CreatPort(name)
;	d0		  a0
;-----------------------------------------------------------------------
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
	tst.l		d0
	beq.s		.No_Port	;quit if no memory
	movea.l		d0,a4		;mem pointer in a4 
	
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
;Routine to delete a message port 
;	DeletePort(port)
;	            d0
;-----------------------------------------------------------------------

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

;-----------------------------------------------------------------------
;	Checksum - subroutine to calculate bootblock checksum
;	Checksum (Buffer)
;		   a0
;	where buffer is a pointer to the bootblock data that is to 
;	be checksummed. 
;-----------------------------------------------------------------------

Checksum	
	move.l		d3,-(sp)	;store d3
	clr.l		4(a0)		;clear old checksum
	move.w		#255,d3		;size in longs -1
	moveq		#0,d0		;start value
	
Sumloop
	move.l		(a0)+,d1	;get next longword
	addx.l		d1,d0
	dbra		d3,Sumloop	;branch if not done
	moveq		#-1,d1
	subx.l		d0,d1		;subtract
	move.l		d1,-1020(a0)	;store checksum
	move.l		(sp)+,d3	;restore d3
	rts

;-----------------------------------------------------------------------

trackdiskname	TD_NAME

Portname	dc.b	'TrackDiskPort',0
		EVEN

diskio		ds.l	1

;-----------------------------------------------------------------------
	section	buffer,data_c

;	This contains the bootblock code which should start
;	'DOS',0 (or 'DOS',1 for FFS)
;	Checksum
;	Root Block (usually $370)
;	Your boot code (Note all code must be position independant
;	as no reloction is done on code loaded).Just relocatable
;	code is not good enough (yes there is a difference).
;	The data MUST be held in CHIP ram for the trackdisk routines to work.

diskbuffer	
		INCBIN	Source9:S.Marshall/Bootcode
		
;-----------------------------------------------------------------------
