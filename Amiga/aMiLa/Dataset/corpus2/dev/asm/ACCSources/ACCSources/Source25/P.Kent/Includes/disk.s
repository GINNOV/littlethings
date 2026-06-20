****************************************************
*												   *
*			   DISK ROUTINES			 	       *
*			 READ/WRITE VERSION					   *
*	USES TIMERS FOR DISK CONTROL.680x0 COMPATIBLE! *
*												   *
*  ALL DIRECT DISK ACCESS CODE BY *DEAN ASHTON*    *
*     DOS LOADER & MEMORY INTERFACE BY P.KENT      *
****************************************************
	RSRESET
LFE_ALLOK	RS.B	1				; :-)
LFE_NOFILE	RS.B	1				; Couldnt lock file!
LFE_NOBLOCK	RS.B	1				; Block read error of some kind!
LFE_NODISK	RS.B	1				; Hmmm... Trying to read air, OR disk name
									; not found.
LFE_NODRIVE RS.B	1				; Trying to read WITH air!

DISK_WRITE		= 0 	 			; 1 = include write routines
READTRIES		= 3					; Maximum no. of Track re-trys

LFTYPE_ABS		= 0
LFTYPE_CHIP		= 1
LFTYPE_PUBLIC	= 2

*****
* InitDisks()
* Initialise disk control routines etc
* Diskbuffer is a 20000 byte CHIP buffer (allocated)
* Determines which drives are present on system...
*****
InitDisks
	MOVE.L #20000,D1
	BSR AllocChip					; Set up disk buffers...
									; d0=diskbuffers
	MOVE.L	D0,TRACK(A5)			; Store address of Track (Decoded)
	ADD.L #6144,D0 					; Find address of Track Gap (Raw)
	MOVE.L	D0,TRACKGAP(A5)			; Store address of Track Gap
	ADD.L #700,D0					; Find address of Track Buffer (Raw)
	MOVE.L	D0,TRACKBUFF(A5)		; Store address of Track Buffer (Raw)
	MOVE.L	TRACKGAP(A5),A0			; Retrieve address of Track Gap
	MOVE.L	#(13756/4)-1,D0			; Number of Longwords to Initialise
	MOVE.L	#$AAAAAAAA,D1
INITMFM	MOVE.L	D1,(A0)+			; Write MFM coded Zero Bytes away..
	DBF	D0,INITMFM

	LEA LB.PRESLIST(A5),A0			; Suss available drives...
	MOVEQ	#4-1,D1
DRIVEIT_LP
	BSR.S	DRIVEPRESENT
	MOVE.B D0,(A0,D1.W)
	DBRA D1,DRIVEIT_LP
	CLR.W	W.ACTDRIVE(A5)			; Keep actdrive valid
	DRIVEOFF 1111					; All drives off!
	RTS


*****
* d0 = DRIVEPRESENT ( NUMBER )( D1)
* CHecks if drive is on system!
* Returns 0 if no drive!
*****
DrivePresent
	PUSH D1-D7/A0
	MOVEQ	#-1,D7					; Set drive present
	LEA	$BFD100,A0					; A0 points to Drive Select register
	MOVEQ	#0,D0					; Clear D0
	MOVE.L	D0,D2					; Clear D2
	MOVE.L	D0,D3					; Clear D3
	MOVE.W	W.ACTDRIVE(A5),D0		; Restore Drive Number
	ADDQ.W	#3,D0					; D0 points to Drive Bit
	MOVE.B	#$79,(A0)				; Motor is to be turned on
	BCLR	D0,(A0)					; Select Drive to be turned on...
	
	CMP.B	#3,D0					; Drive Zero isn't external so it
	BEQ.S	DP_DRIVEOK				; won't respond to ID request!
	
	MOVE.B	#$F9,(A0)				; Motor is to be turned off
	BCLR	D0,(A0)					; Select Drive to be turned off...
	
	MOVEQ	#32-1,D1				; Read 32 bits in Identification Mode
DP_DRIVEID	BCLR	D0,(A0)				; Place SELx line active
	MOVE.B	$BFE001,D2				; Read Drive status...
	LSL.B	#3,D2					; Move DSKRDY bit into carry bit...
	ROXL.L	#1,D3					; Rotate carry into Drive ID.
	BSET	D0,(A0)					; Place SELx line inactive
	DBF	D1,DP_DRIVEID				; Back for next bit of Identification
;	NOT.L	D3						; Invert as DSKRDY is active low..
;	CMP.L	#-1,D3					; Is it a 3.5" Amiga Drive?
	TST.L	D3						; -(-1)=0 two's complement
	BEQ.S	DP_DRIVEOK				; Yes? Then carry on!
	MOVEQ	#0,D7	
DP_DRIVEOK
	MOVE.L D7,D0
	POP D1-D7/A0
	RTS


***************************************************************
* LOADFILE (NAME [DESTADDR] LOADFUNC) (A0 [A1] D1)
*
* LOAD A DOS FILE
* SUPPORTS DISK NAMES/SUB DIRECTORIES ETC. :-)
* CAN HAVE SPACES ETC. QUOTES ETC. ARE TREATED AS PART OF THE FILENAME!
* EG.
* A keymap file:    `DF0:DEVS/KEYMAPS/GB`
* A crunched file:  `SOURCE:P.KENT/GFX/REALLY AWKWARD FILE NAME.LH`
*
* IF FILENAME ENDS IN A '.LH' FILE WILL BE DECRUNCHED USING
* THE LHLIB ROUTINES!
* NB: ERROR HANDLING IS (STILL) RATHER NAFF AT PRESENT!!!
* L.FILENAME = A0
* L.DESTADDR = A1					; LOAD ADDRESS IF ABSOLUTE
* W.LOADFUNC = D1					; LFTYPE_ABS    = ABSOLUTE ADDR
*                                   ; LFTYPE_CHIP   = CHIP MEMORY
*                                   ; LFTYPE_PUBLIC = PUBLIC
* RETURNS:
* D0 = PTR TO FILE
* D1 = LENGTH OF FILE
***************************************************************
LOADFILE
	MOVEM.L	D2-D4/A0,-(A7)	 		; Stack registers
	CLR.W W.ACTDRIVE(A5)
	MOVE.L A0,L.FILENAME(A5)
	MOVE.L A1,L.DESTADDR(A5)
	MOVE.W D1,W.LOADFUNC(A5)
	MOVE.W	#LFE_ALLOK,W.FERROR(A5)
	
	BSR FINDDISK					; Search filename for drive name/number
 									; Then set w.actdrive+zero tracks etc
									; Leave drive running if OK
	TST.W	W.FERROR(A5)
	BNE.S	LF_DONEIT2

	BSR LOCKFILE					; Locks file, sets length
	TST.W	W.FERROR(A5)
	BNE.S LF_DONEIT					; File lock failed!!!

;If filename ends in a '.lh' (upper or lower case) assume is lh encoded file
;Decrunch etc. is so...
	
	MOVE.L	L.FILENAME(A5),A0
	MOVE.W	W.NAMELEN(A5),D0
	LEA	-3(A0,D0.W),A0
	CMP.B	#'.',(A0)+
	BNE.S LF_NOTLH
	MOVE.B (A0)+,D2
	BSR	DISK_UPPERCASE
	CMP.B	#'L',D2
	BNE.S LF_NOTLH
	MOVE.B (A0),D2
	BSR	DISK_UPPERCASE
	CMP.B	#'H',D2
	BEQ.S	LF_ISLH					; ITS CRUNCHED!

LF_NOTLH
	MOVE.L L.FILELEN(A5),D1			; GET LENGTH
	BSR	LF_DOLOADFUNC
	MOVE.L	L.DESTADDR(A5),A2
	BSR LOADALL
;Any errors picked up now...
LF_DONEIT
	MOVE.W W.ACTDRIVE(A5),D1
	BSR DISKOFF
LF_DONEIT2 ;Handle errors etc. here GIVEN drive stopped
	TST.W	W.FERROR(A5)
	BEQ.S	LF_NOERROR
LF_DOERROR
	MOVEQ	#0,D1
	MOVEQ	#0,D0
	MOVE.W	W.FERROR(A5),D0
	BRA.S LF_QUIT
LF_NOERROR
	MOVE.L L.DESTADDR(A5),D0
	MOVE.L L.FILELEN(A5),D1
LF_QUIT
	MOVEM.L	(A7)+,D2-D4/A0 			; Restore register contents
	RTS

;LOAD AN LH CRUNCHED FILE...
LF_ISLH
;Allocate public memory to load in...
	MOVE.L	L.FILELEN(A5),D1
	BSR	AllocPublic
	MOVE.L	D0,L.SRCBUFF(A5)
;Load...
	MOVE.L	L.SRCBUFF(A5),A2		; To lh src buffer
	BSR LoadALL
	TST.W	W.FERROR(A5)
	BNE.S	LF_DOERROR				; Handle any errors now....
	MOVE.W W.ACTDRIVE(A5),D1		; STOP DRIVE so not left running
	BSR DISKOFF
;Suss end length..., alloc decrunch memory(if reqd) as per load func

	MOVE.L	L.SRCBUFF(A5),A0
	CMP.B	#$FF,(A0)				; Check for Header!
	BNE.S	LF_LHERROR
	MOVE.L	(A0)+,D1				; Put length in d1
	AND.L	#$00FFFFFF,D1			; MASK  -1 byte at start
	BSR.S LF_DOLOADFUNC				; AllocIt as reqd...

;Decode it...
	MOVE.L	L.FILELEN(A5),D0		; SOURCE length
	SUBQ.L	#4,D0
	MOVE.L	L.SRCBUFF(A5),A0		; A0 = Source ptr
	ADDQ.L	#4,A0					; SKIP LENGTH!$FF000000 LW at start...

	MOVE.L	L.DESTADDR(A5),A1		; Dest addr
	BSR LHDECODE					; See lhdecode.s
	MOVE.L D0,L.FILELEN(A5)			; Save decrunched length...
;Free source buffer
	MOVE.L	L.SRCBUFF(A5),D0
	BSR	FREEMEM
	CLR.L	L.SRCBUFF(A5)			; For safety clear ptr...
	BRA.S LF_DONEIT2				; Quit: handle errors etc.

LF_LHERROR
	LEA LF.LH.TXT(PC),A0
	BRA	_ERROR
LF.LH.TXT	dc.b 'DISK ROUTINES : #?.LH file does NOT appear encoded',0
	even

;LENGTH IN D1, GETS DEST.ADDR ACCORDING TO LOADFUNC...
LF_DOLOADFUNC						; Process load funcs...
	MOVE.W W.LOADFUNC(A5),D0
	CMP.W #LFTYPE_CHIP,D0
	BNE.S LF_DLFNCHIPALLOC
									; ALLOCATE CHIP RAM!
	BSR ALLOCCHIP					; Get chip : if no luck will quit out...
	MOVE.L	D0,L.DESTADDR(A5)
	BRA.S LF_DLFOK
LF_DLFNCHIPALLOC
	CMP.W #LFTYPE_PUBLIC,D0
	BNE.S LF_DLFNPUBLICALLOC
									; ALLOCATE PUBLIC RAM!
	BSR ALLOCPUBLIC					; Get publ : if no luck will quit out...
	MOVE.L	D0,L.DESTADDR(A5)
	BRA.S	LF_DLFOK
LF_DLFNPUBLICALLOC					; Absolute address?
	CMP.W	#LFTYPE_ABS,D0
	BNE.S	LF_UNKNOWNLOADTYPE
LF_DLFOK
	RTS

LF_UNKNOWNLOADTYPE
	LEA LF.UNKN.TXT(PC),A0
	BRA _ERROR
LF.Unkn.txt dc.b 'DISK ROUTINES : Unknown file load function!!!',0
	even

*****
* FINDDISK()
* Set w.Actdrive according to filename!
* Drives are specified as df0:, df1: etc. OR 'Source_1:'
*****
FindDisk
; Check for ONE drive specifier (:)
	MOVE.L L.FILENAME(A5),A0
	MOVEQ #0,D0
FD_lp1
	tst.b (a0)
	BEQ.S FD_END1
	CMP.B #':',(A0)+
	BNE.S FD_lp1
	ADDQ.L #1,D0
	BRA.S FD_LP1
FD_END1
	CMP.B #1,D0
	BNE FD_NOCOLONERR
; See if a specific drive is asked for...
	MOVE.L L.FILENAME(A5),A0
	CMP.B #':',3(A0)	;0D 1F 2x 3:
	BNE.S FD_DISKNAME
	MOVEQ #0,D2
	MOVE.B (A0)+,D2
	BSR DISK_UPPERCASE
	CMP.B #'D',D2
	BNE.S FD_DISKNAME
	MOVE.B (A0)+,D2
	BSR DISK_UPPERCASE
	CMP.B #'F',D2
	BNE.S FD_DISKNAME
	MOVE.B (A0)+,D2
	SUB.B #'0',D2
	BMI.S FD_DISKNAME
	CMP.B #4,D2
	BGE.S FD_DISKNAME
	MOVE.W D2,W.ACTDRIVE(A5)
	ADDQ.L #4,L.FILENAME(A5)		; Skip 'dfx:' bytes
	MOVE.W W.ACTDRIVE(A5),D1
	BSR DISKON						; Start drive...
	TST.W W.FERROR(A5)
	BNE.S FD_CONTERR
	BSR RESETDRIVE					; Zero etc.
FD_CONTERR
	RTS
FD_DISKNAME
;Set namelen to be length of disk name...

	MOVE.L	L.FILENAME(A5),A0		; A0 points to (disk-)Filename
	MOVE.L	A0,A1
FD_FLLP	CMP.B #':',(A1)+
	BNE.S FD_FLLP
	SUB.L	A0,A1
	MOVE.L	A1,D0
	SUBQ.L	#1,D0					; D0 holds length of diskname
	MOVE.W	D0,W.NAMELEN(A5)

;Scan drives 0-3 for a disk of correct name!
	CLR.W W.ACTDRIVE(A5)
	LEA LB.PRESLIST(A5),A4

FD_SCANLP
	TST.B (A4)+						; Drive present?
	BEQ.S FD_DNNP

	MOVE.W W.ACTDRIVE(A5),D1		; Start drive...
	BSR DISKON
	TST.W W.FERROR(A5)
	BNE.S FD_DERR

	BSR RESETDRIVE					; Zero tracks etc.
;Read root
	IFD HELP
	MOVE.W #$8,COLOR00(A6)
	ENDC

	MOVE.L #880,D0
	BSR GETBLOCK
	BEQ.S	FD_DERR
	IFD HELP
	MOVE.W #$F,COLOR00(A6)
	ENDC
	MOVE.L	D0,L.CURDBPTR(A5)

;Check disk name - check lengths, check chrs (not case sensitive!)
	MOVE.L  D0,A1
	LEA 432(A1),A1					; Disk name
;If a match hop out of check loop...
	MOVE.W	W.NAMELEN(A5),D0
	CMP.B	(A1)+,D0				; Is the length the same?
	BNE.S	FD_DERR					; No? Then get the next disk
	SUBQ	#1,D0					; Set D0 for counter
	MOVE.L	L.FILENAME(A5),A2
FD_CHECKNAME MOVE.B	(A1)+,D2		; Get Character from BLOCK
	BSR 	DISK_UPPERCASE			; Convert to Upper Case
	MOVE.W	D2,D1					; Keep the value
	MOVE.B	(A2)+,D2				; Get Character from DISKNAME
	BSR 	DISK_UPPERCASE			; Convert to Upper Case
	CMP.B	D1,D2					; Are the characters the same?
	BNE.S	FD_DERR					; No? Then get the next file
	DBF	D0,FD_CHECKNAME

	BRA.S	FD_GOTDISK				; It's the right disk!
FD_DERR	MOVE.W W.ACTDRIVE(A5),D1
	BSR DISKOFF
;
	MOVE.W #100,D0					; Wait 100ms
	BSR WAIT
;
	MOVE.W #LFE_ALLOK,W.FERROR(A5)
FD_DNNP
	ADDQ.W #1,W.ACTDRIVE(A5)		; Next drive - A4 already updated
	CMP.W #4,W.ACTDRIVE(A5)			; End ?
	BNE.S FD_SCANLP
	MOVE.W #LFE_NODISK,W.FERROR(A5)
	CLR.W W.ACTDRIVE(A5)			; Keep actdrive valid...
	RTS

FD_GOTDISK
;	MOVE.W W.ACTDRIVE(A5),D1
;	BSR DISKOFF
	MOVEQ #1,D0
	ADD.W W.NAMELEN(A5),D0
	CLR.W W.NAMELEN(A5)				; Just to be safe...
	ADD.L D0,L.FILENAME(A5)			; Skip name + ':'
	RTS

FD_NOCOLONERR
	lea fd.nocol.err.txt(pc),a0
	bra _error
fd.nocol.err.txt dc.b 'DISK ROUTINES : No '':'' drive specifier!!',0
	even

*****
* LOCKFILE()
* HASH FILENAME, TRACK IT DOWN!
*****
LOCKFILE
;CONVERT FILENAME/DIRS + ZERO /s
	MOVE.L	L.FILENAME(A5),A0
	MOVEQ	#1,D0
LF_Dlp
	TST.B	(A0)
	BEQ.S	LF_Dfin
	CMP.B #'/',(A0)
	BNE.S LF_DNo
	CLR.B (A0)
	ADDQ	#1,D0
LF_DNO
	ADDQ.L #1,A0
	BRA.S	LF_DLP
LF_DFIN
	MOVE.W	D0,W.NUMDIRS(A5)
;LOAD ROOT...
	MOVE.L	#880,D0
	BSR	GETBLOCK
	BEQ	LF_NOFILE
	MOVE.L	D0,L.CURDBPTR(A5)
;LOOP TO WALK THRO DIRECTORY STRUCTURE...
LF_DIRLP
	BSR GETHASH
	MOVE.L	L.CURDBPTR(A5),A0
	MOVE.W	W.HASH(A5),D0
	LSL.W	#2,D0
	MOVE.L	(A0,D0),D0				; Get number
	BEQ.S	LF_NOFILE				; DOESNT EXIST!!
LF_LP
	BSR GETBLOCK
	BEQ.S	LF_NOBLOCK
	MOVE.L	D0,L.CURDBPTR(A5)
	MOVE.L D0,A0
	LEA	432(A0),A1					; A1 Point to BCPL Name
	MOVE.W	W.NAMELEN(A5),D0
	CMP.B	(A1)+,D0				; Is the length the same?
	BNE.S	LF_NEXTSECT				; No? Then get the next file

	SUBQ	#1,D0					; Set D0 for counter
	MOVE.L	L.FILENAME(A5),A2
LF_CHECKNAME MOVE.B	(A1)+,D2		; Get Character from BLOCK
	BSR 	DISK_UPPERCASE				; Convert to Upper Case
	MOVE.W	D2,D1					; Keep the value
	MOVE.B	(A2)+,D2				; Get Character from FILENAME
	BSR 	DISK_UPPERCASE				; Convert to Upper Case
	CMP.B	D1,D2					; Are the characters the same?
	BNE.S	LF_NEXTSECT				; No? Then get the next file
	DBF	D0,LF_CHECKNAME
	BRA.S	LF_FOUNDIT				; It's the right file!!!

LF_NEXTSECT	MOVE.L	496(A0),D0		; Get the next sector number
									; Is there one there???
	BNE.S	LF_LP					; Yes? Then go get it !
	BRA.S	LF_NOFILE				; No? Then the file doesn't exist!
	
LF_FOUNDIT
	SUBQ.W	#1,W.NUMDIRS(A5)		; Was that it?
	BEQ.S	LF_DIRLPFIN
	MOVE.W	W.NAMELEN(A5),D0		; Update filename ptr...
	MOVE.L	L.FILENAME(A5),A0
	LEA 1(A0,D0),A0					; +1 for '/'
	MOVE.L	A0,L.FILENAME(A5)
	BRA.S	LF_DIRLP

LF_DIRLPFIN
	MOVE.L	324(A0),L.FILELEN(A5)	; Get filelength...
	CLR.W	W.DLEFT(A5)				; Clear data length...
	RTS

LF_NOBLOCK
	MOVE.W	#LFE_NOBLOCK,W.FERROR(A5)
	RTS
LF_NOFILE
	MOVE.W	#LFE_NOFILE,W.FERROR(A5)
	RTS

*****
* LOADALL
* *DESTADDR in A2*
* Load locked file to A2
*****
LOADALL
	MOVE.L	L.CURDBPTR(A5),A0		; Get ptr to current block...
;	MOVE.L	L.DESTADDR(A5),A2
	MOVE.L	L.FILELEN(A5),D7		; File size...
LA_lp
	MOVE.L	16(A0),D0
	BEQ.S	LA_Fin
	BSR GETBLOCK
	BEQ.S LA_ErrFin

	MOVE.L D0,A0
	MOVE.L D0,L.CURDBPTR(A5)		; Update records: tho not necessary...
	LEA	24(A0),A1					; A1 Points to actual data
	MOVE.L	#487,D0					; 488 bytes of data
LA_clp
	MOVE.B	(A1)+,(A2)+				; Copy it!
	SUBQ.L	#1,D7
	TST.L	D7
	BEQ.S	LA_Co
	DBF	D0,LA_clp					; Until all done
LA_Co	BRA.S	LA_lp
LA_Fin	RTS
LA_ErrFin	MOVE.W #LFE_NOBLOCK,W.FERROR(A5)
	RTS

************************
* Calculate Hash Value *
************************
GETHASH
	MOVE.L	L.FILENAME(A5),A0		; A0 points to Filename
	MOVE.L	A0,A1
GH_FLP	TST.B (A1)+
	BNE.S GH_FLP
	SUB.L	A0,A1
	MOVE.L	A1,D0
	SUBQ.L	#1,D0					; D0 holds length of Filename
	MOVE.W	D0,W.NAMELEN(A5)

	MOVEQ	#0,D2		
	MOVE.L	D0,D1					; Use D1 as the loop counter
	SUBQ	#1,D1					; Subtract 1 for use as counter
HASHLOOP	MULU.W	#13,D0			; Hash=Hash*13
	MOVE.B 	(A0)+,D2				; Read character from Filename
	BSR.S	DISK_UPPERCASE			; Convert to Upper Case
	ADD.W	D2,D0					; and add code to Hash
	AND.W	#$7FF,D0
	DBF 	D1,HASHLOOP
	DIVU.W	#72,D0					; Hash modulo 72
	SWAP 	D0
	ADDQ	#6,D0					; Hash Table offset in Root Block
	MOVE.W	D0,W.HASH(A5)			; And Store it away!
	RTS

***********************************
* Convert character to Upper Case *
***********************************
DISK_UPPERCASE	CMP.B 	#"a",D2		; Character < 'a' ?
	BLO.S	UPPEXIT				; Yes? Then leave alone
	CMP.B	#"z",D2				; Character > 'z' ?
	BHI.S	UPPEXIT				; Yes? Then leave alone
	SUB.B	#$20,D2				; Correct the character
UPPEXIT	RTS

*****
* DISKON(DRIVE)(D1 : 0-3 )
* ENABLE DRIVE AND CHECK DISK ETC.
*****
DISKON
	LEA LB.PRESLIST(A5),A0
	TST.B (A0,D1.W)
	BEQ DISKON_NODRIVEERR
	LEA	$BFD100,A0					; Point to Drive Select Register
	MOVE.B	#$79,(A0)				; Motor is to be turned on

	ADDQ.W #3,D1
	BCLR	D1,(A0)					; Select drive to be turned on...

	MOVE.W	#500,D0					; Must wait 500ms before continuing
	BSR	WAIT						; See Hardware Ref. Manual Page 239!
	STEP	OUT						; We only want to step the
	STEPTRACK	3,WAIT				; disk to get all of the drive flags
									; Wait the 3 milliseconds as stated
									; in Hardware Reference Manual...
	STEP	IN 						; We'll step out and then back in
	STEPTRACK	3,WAIT				; again, so we don't break the drive!
	BTST	#2,$BFE001				; Is there a disk in the drive?
	BNE.S DSKTHERE 					; Yes? Then continue!
									; 'No Disk'
	MOVE.W	#LFE_NODISK,W.FERROR(A5)
	BRA.S	DISKON_QUIT
DSKTHERE
;	BTST	#3,$BFE001				; Is the disk write protected?
;	BNE.S DISKOK					; No? Then all validation is Ok!

DISKOK	BTST	#5,$BFE001			; Is the Drive up to speed?
	BNE.S DISKOK					; No? Wait until it is!
DISKON_QUIT
	RTS
DISKON_NODRIVEERR
	MOVE.W	#LFE_NODRIVE,W.FERROR(A5)
	BRA.S	DISKON_QUIT

*****
* DISKOFF(DRIVE)(D1)
* KILL DRIVE SPECIFIED
*****
DISKOFF
	LEA	$BFD100,A0					; Point to Drive Select Register
	MOVE.B	#$F9,(A0)				; Motor is to be turned off
	ADDQ.W  #3,D1
	BCLR	D1,(A0)					; Select drive to be turned off...
	MOVE.W	#50,D0 					; We'll wait for 50 ms
	BSR	WAIT						
	RTS

*****
* RESETDRIVE()
* SETS DRIVE TO TRACK ZERO,SETS SYNC VALUES...
*****
RESETDRIVE
									; Set Disk DMA values
	MOVE.W	#$4489,DSKSYNC(A6)		; Syncword
	MOVE.W	#$4000,DSKLEN(A6) 		; Disable writing
	MOVE.W	#0,CURRTRACK(A5)		; Set as reference for FindTrack
	SEEKZERO 3,WAIT					; Find Track Zero
	LOWERHEAD						; Place head on correct side
	RTS

*****
* GETBLOCK(NUMBER) (D0)
* RETURNS: D0=PTR TO BLOCK 0:ERROR
*****
GETBLOCK
	DIVU #11,D0						; Find track, number...
	CMP.W	CURRTRACK(A5),D0		; If already in ok posn, just set ptr...
	BEQ.S GB_OK
	BSR.S FINDTRACK
	BSR READTRACK
	TST.B	D1
	BNE.S GETBLOCK_AG				; ERROR!
GB_OK
	SWAP	D0
	MULU	#$200,D0
	ADD.L	TRACK(A5),D0
	RTS
	
GETBLOCK_AG
	MOVEQ	#0,D0
	RTS

**************************************************************************
* WAIT :- 	Waits for a specific amount of time to pass before returning *
* 			Pass the number of Milliseconds in register D0.				 *
**************************************************************************

WAIT	MOVEM.L	D0-D1/A0,-(A7)		; Stack registers
	LEA	CIABPRA,A0					; Point to CIAB addresses
	MOVE.B	CIACRA(A0),D1 			; Set control register A on CIAB
	AND.B #%11000000,D1				; Don't trash bits we are not
	OR.B	#%00001000,D1			; using.....
	MOVE.B	D1,CIACRA(A0) 			; Write bits back...
	MOVE.B	#$CC,CIATALO(A0)		; Set Timer to wait for exactly
	MOVE.B	#$02,CIATAHI(A0)		; 1 millisecond..
	AND.L #$FFFF,D0					; Mask off the upper word
WAITTIMER	BTST.B	#0,CIAICR(A0) 	; Is Timer-Expired flag set?
	BEQ.S WAITTIMER					; No? Then wait until it is!
	BSET.B	#0,CIACRA(A0) 			; Restart timer...
	DBF	D0,WAITTIMER				; Back until done.
	MOVEM.L	(A7)+,D0-D1/A0 			; Restore registers
	RTS

**************************************************************
* FINDTRACK :- Load a specified track ( track number in D0 ) *
**************************************************************

FINDTRACK	MOVEM.L	D0-D2,-(A7)		; Save registers
	MOVE.W	D0,NEWTRACK(A5)			; Store new track number.
	MOVE.W	CURRTRACK(A5),D2		; Retrieve current track number
	BTST	#0,D0					; Is the new track number odd?
	BEQ.S TRACKLOW					; Yes? Then read the Lower Side
	UPPERHEAD						; No? Then read the Upper Side
	BRA.S FINDDIFF
TRACKLOW LOWERHEAD					; In that case read the UPPER side!
FINDDIFF CMP.W D2,D0 				; Is current track > new track
	BLE.S 	MOVEIN					; Yes? Then move towards Track Zero
	STEP	OUT						; Otherwise move to Track 159
	BRA.S FINDNUMB
MOVEIN	STEP	IN
FINDNUMB LSR.W D2					; Divide tracks by two because we
	LSR.W D0						; we aren't dealing with sides here!
	SUB.W D2,D0
	BPL.S NUMBEROK
	NEG.W D0						; How many tracks away is new track?
NUMBEROK TST.W D0					; If D0 is zero then we don't need
	BEQ.S OVERTRACK					; to step any tracks,and we've
	SUBQ	#1,D0					; Subtract one from it for counter.
LOCATEIT STEPTRACK	3,WAIT			; Step that track! 3ms wait time.
	DBF	D0,LOCATEIT					; Until I've reached the new track

OVERTRACK
	MOVE.W	NEWTRACK(A5),CURRTRACK(A5) ; Current Track is New Track
	MOVEM.L	(A7)+,D0-D2 ; Restore registers
	RTS

**********************************************************
* READTRACK :- Read a track in MFM Format using Disk DMA *
**********************************************************
READTRACK
	MOVEQ	#READTRIES-1,D2			; Maximum number of read attempts
RTRKLOOP MOVE.L	TRACKBUFF(A5),DSKPTH(A6)
	MOVE.W	#$7F00,ADKCON(A6)		; Clear ADKCON
	MOVE.W	#$9500,ADKCON(A6)		; MFM, with PRECOMP
	MOVE.W	#$9980,DSKLEN(A6)
	MOVE.W	#$9980,DSKLEN(A6)		; Read $1980 Words
	WAITDISK						; Wait for Disk DMA to Stop
	BSR.S DECODE
	TST.B D1						; Has the Decode worked?
	BEQ.S READEXIT					; Yes! Let's quit it!
	DBF	D2,RTRKLOOP					; No? Let's try again!
READEXIT
	RTS


***********************************************************
* SAVETRACK :- Write a track in MFM Format using Disk DMA *
***********************************************************
	IFD	DISK_WRITE
SAVETRACK	BSR	ENCODE				; Encode Scrambled Track to MFM Data
	MOVE.L	TRACKGAP(A5),DSKPTH(A6)
	MOVE.W	#$7F00,ADKCON(A6)		; Clear ADKCON
	CMP.W #80,CURRTRACK(A5)			; Is current track greater than 80
	BLT.S PRECOMP					; No? Then skip this setting
	MOVE.W	#$A500,ADKCON(A6)		; Set precomp to 140ns
	BRA.S SAVEIT					; Skip next setting
PRECOMP	MOVE.W	#$9500,ADKCON(A6)	; Set no precomp
SAVEIT	MOVE.W	#$D980,DSKLEN(A6)
	MOVE.W	#$D980,DSKLEN(A6)		; Write $1980 words
	WAITDISK						; Wait for Disk DMA to Stop
	MOVE.W	#$4000,DSKLEN(A6)		; Disable writing...
	RTS
	ENDC

******************************************************************
* DECODE :- Decodes MFM Format track pointed at by TRACKBUFF(A5) *
* D1=0 IF OK...
******************************************************************
DECODE	MOVEM.L	D0/D2-D6/A0-A2,-(A7); Save registers
	MOVE.L	TRACK(A5),A0	; Pointer to decoded data
	MOVE.L	TRACKBUFF(A5),A1	; Pointer to trackbuffer
	MOVE.L	#$55555555,D3	; Value for decoder
	MOVEQ #10,D5		; Decode 11 blocks
DECNEXTBK	CMP.W #$4489,(A1)+	; Check for next sync word
	BEQ.S NOGAP 	; Hey! There's no other syncs!
NOSYNC	CMP.W #$4489,(A1)+	; Search for next sync
	BNE.S NOSYNC		; Not there! Back we go!
NOGAP CMP.W #$4489,(A1) ; Skip all remaining syncs
	BNE.S SKIPSYNC
	ADDQ.W	#2,A1
	BRA.S NOGAP
SKIPSYNC MOVE.L	(A1)+,D0 	; Read data from buffer
	MOVE.L	(A1)+,D1
	AND.L D3,D0 	; Remove clock bits
	AND.L D3,D1
	ADD.L D0,D0
	OR.L	D1,D0
	MOVE.L	D0,D1
	AND.L #$FF000000,D1	; Check if header is alright
	CMP.L #$FF000000,D1
	BNE.S FATALERR 	; If not -> ERROR
	AND.L #$0000FF00,D0	; Get sector number
	ADD.L D0,D0
	MOVE.L	A0,A2
	ADD.L D0,A2 	; Add to get the right pos.
	LEA $28(A1),A1		; Skip the rest
	MOVE.L	(A1)+,D4 	; Decode Data-Checksum
	MOVE.L	(A1)+,D1 	; Store it in D4
	AND.L D3,D4
	AND.L D3,D1
	ADD.L D4,D4
	OR.L	D1,D4
	MOVEQ #127,D6		; Decode 2*128 longwords
	MOVEQ #0,D2
DECNEXT	MOVE.L	512(A1),D1	; Decode data block
	MOVE.L	(A1)+,D0
	EOR.L D0,D2 	; Calculate Checksum
	EOR.L D1,D2
	AND.L D3,D0 	; Decode longword
	AND.L D3,D1
	ADD.L D0,D0
	OR.L	D1,D0
	MOVE.L	D0,(A2)+ 	; Store longword in buffer
	DBF	D6,DECNEXT	; Decode next longword
	AND.L D3,D2 	; Skip illegal bits
	CMP.L D4,D2 	; Compare checksums
	BNE.S FATALERR 	; If not equal -> error
	LEA $200(A1),A1		; Add for next block
	DBF	D5,DECNEXTBK	; Back for next block
	MOVEQ #0,D1 	; Return code : OK
DCODEEXIT	MOVEM.L	(A7)+,D0/D2-D6/A0-A2; Restore registers
	RTS

FATALERR MOVEQ #-1,D1				; Failure
	BRA.S DCODEEXIT					; Leave properly!

**********************************************************
* ENCODE : Codes a track into MFM format for Writing		*
**********************************************************
	IFD	DISK_WRITE
ENCODE	MOVEM.L	D0-D7/A0-A4,-(A7) 	; Save registers
	MOVE.L	TRACK(A5),A0			; Get Data address
	MOVE.L	TRACKBUFF(A5),A1		; Get MFM Buffer address
	MOVE.L	#$55555555,D5			; Mask For Even Bits
	MOVEQ #11,D7					; Code 11 Sectors
	MOVEQ #0,D6 					; Sector Number

CODELOOP LEA	8(A1),A2
	MOVE.L	A1,A3
	MOVE.L	#$FF000000,D0	; Format Sign
	MOVEQ #0,D1
	MOVE.W	CURRTRACK(A5),D1	; Track number is needed for MFM
	SWAP	D1
	OR.L	D1,D0 		; Store Track Number (0-159)
	MOVE.W	D6,D1
	ASL.W #8,D1
	OR.W	D1,D0 		; Store Sector Number (0-10)
	OR.W	D7,D0 		; Store Sectors until gap (11-1)

	MOVE.L	#$00000000,(A1)+	; Store coded zero bytes
	MOVE.L	#$44894489,(A1)+	; Move in Sync bytes
	BSR	CODELONG 		; Code the Info-Block
	MOVE.L	D0,(A1)+ 	; Move in Odd Data
	MOVE.L	D1,(A1)+ 	; Move in Even Data

	MOVEQ #8-1,D2
STORELAB CLR.L (A1)+ 	; Store sector label ( not used )
	DBF	D2,STORELAB

	MOVEQ #0,D0
	MOVEQ #10-1,D2 		; Calculate checksum over 40 bytes
HEADCHECK	MOVE.L	(A2)+,D1
	EOR.L D1,D0
	DBF	D2,HEADCHECK
	BSR.S CODELONG 		; Code the Header Checksum
	MOVE.L	D0,(A1)+ 	; Store Header Checksum (Odd)
	MOVE.L	D1,(A1)+ 	; Store Header Checksum (Even)

	LEA	16(A2),A2		; Point to buffer for Odd bits
	LEA	512(A2),A4		; Point to buffer for Even bits
	MOVEQ #128-1,D2		; Code 128 longwords...

CODEDATA MOVE.L	(A0)+,D0 	; Fetch program data from memory
	BSR.S CODELONG
	MOVE.L	D0,(A2)+ 	; Store Coded Data (Odd)
	MOVE.L	D1,(A4)+ 	; Store Coded Data (Even)
	DBF	D2,CODEDATA

	LEA	8(A1),A2 		; Skip space for Data Checksum
	MOVEQ #0,D0 		; Clear checksum
	MOVE.W	#256-1,D2
DATACHECK	MOVE.L	(A2)+,D1
	EOR.L D1,D0 		; Calculate Data Checksum
	DBF	D2,DATACHECK
	BSR.S CODELONG 		; Code it into MFM format
	MOVE.L	D0,(A1)+ 	; Store Data Checksum (Odd)
	MOVE.L	D1,(A1)+ 	; Store Data Checksum (Even)

	MOVEQ #0,D4 		; Set Clock bits for InfoBlock
	BSR.S SETCLOCKS

	ADDQ.L	#4,A3 		; Skip syncs
	MOVE.W	#270-1,D4	; Set Clock bits for 270 Longwords
	BSR.S SETCLOCKS

	LEA 1024(A1),A1		; Skip coded Data bits
	ADDQ.W	#1,D6
	SUBQ.W	#1,D7
	BNE	CODELOOP 		; Right! Back for the next Sector
	MOVEQ #0,D0
	MOVEM.L	(A7)+,D0-D7/A0-A4 ; Restore registers
	RTS					; Back to the main program

SETCLOCKS
	MOVE.B	-1(A3),D3	; Byte from previous longword
	NOT.B D3 			; Invert it.
	ANDI.L	#1,D3 		; Mask off Bit 0
	ROR.L #1,D3 		; Shift Bit 0 to Bit 31
	MOVE.L	(A3),D0		; Fetch next longword
	MOVE.L	D0,D1
	EOR.L D5,D0
	MOVE.L	D0,D2
	LSL.L #1,D0
	LSR.L #1,D2
	OR.L	D3,D2 		; Set Bit 31 if necessary
	AND.L D2,D0
	OR.L	D1,D0
	MOVE.L	D0,(A3)+
	DBF	D4,SETCLOCKS

	RTS

CODELONG
	MOVE.L	D0,D1
	LSR.L #1,D0
	AND.L D5,D0 	; D0 is coded Odd  bits
	AND.L D5,D1 	; D1 is coded Even bits
	RTS
	ENDC

DISKVARS	MACRO
TRACK 		RS.L	1	; Holds address of Decoded Track Data
TRACKGAP	RS.L	1	; Holds address of Track Gap prior to MFM Data
TRACKBUFF	RS.L	1	; Holds address of MFM Data Buffer
LB.PRESLIST	RS.B	4	; Drives present: df0:-df3: inc. ZERO=Absent
CURRTRACK	RS.W	1	; Holds current track number
NEWTRACK 	RS.W	1	; Holds new track number
W.ACTDRIVE	RS.W	1	; CURRENT ACTIVE DRIVE
L.FILENAME  RS.L	1	; File name...
L.DESTADDR	RS.L	1	; Destination address for file
L.FILELEN	RS.L	1	; File length
W.LOADFUNC	RS.W	1	; Load function
L.CURDBPTR  RS.L	1	; PTR TO CURRENT DATA BLOCK
L.CURDPTR	RS.L	1	; PTR TO POS IN DATA IN BLOCK...
W.DLEFT		RS.W	1	; BYTES LEFT OF DATA IN CURRENT BLOCK...
W.NAMELEN	RS.W	1	; LENGTH OF FILE NAME...
W.NUMDIRS	RS.W	1   ; NO OF DIRS IN FILENAME...
W.HASH		RS.W	1	; HASH FOR FILENAME
W.FERROR	RS.W	1	; DISK ERROR NO.
L.SRCBUFF	RS.L	1	; TEMPORARY BUFFER FOR LH SOURCE REGION
	ENDM

