; The Special Support Library
; (c) 1993,1994 Martin Mares, MJSoft System Software
; --------------------------------------------------------------------------

; Fields marked with 'R' are read-only, 'P' are private...

; Library Version

SSVer	equ	5

; Library Vector Offsets

_FuncOffset	set	-30
Func	macro	*fname
_LVO\1	equ	_FuncOffset
_FuncOffset	set	_FuncOffset-6
	endm

; Program startup and exit
	Func	StartupInit	; (A0=StartupStruct,D7=WbMsg)
	Func	ExitCleanup	; ()
	Func	ExitError	; (A0=Text,A1=Params)
	Func	DisplayError	; (A0=Text,A1=Params)
	Func	DosError	; (A0=optional text,A1=Params)
	Func	ReportError	; (D0=ErrorCode,A1/D2/D3=Params)
	Func	TestBreak	; ()
; Miscellaneous services
	Func	Printf		; (A0=Text,A1=Params)
	Func	Puts		; (A0=Text)
	Func	PutsNL		; (A0=Text)
	Func	FormatStr	; (A0=Format,A1=Data,A2=DestBuf)
	Func	StrCat		; (A0=Dest,A1=Source) -> A0=AfterPtr
	Func	StrToL		; (A0=String)
	Func	ParseArgs	; (A0=Src,A1=Tmpl,A2=ExHelp,A3=StoreTo,
				;  D0=Flags)
; General tracking services
	Func	CreateResList	; ()
	Func	GetResList	; ()
	Func	FreeResList	; ()
	Func	FreeAllResLists	; ()
	Func	TrackObject	; (D0=type)
	Func	FreeObject	; (A0=tracker)
	Func	TrackRoutine	; (A0=routine,A1=args)
	Func	TrackExtd	; (D0=type,D1=extsize)
	Func	TrackSlave	; (A0=master,A1=slave)
; Special tracking services
	Func	TrackAllocMem	; (D0=size,D1=requirements)
	Func	TrackAlloc	; (D0=size)
	Func	TrackOpen	; (A0=name,D0=openmode)
	Func	TrackLock	; (A0=name,D0=lockmode)
	Func	TrackPort	; ()
	Func	TrackIoRq	; (A0=OptionalPort,D0=size or 0)
	Func	TrackSignal	; ()
	Func	TrackDevice	; (A0=DevName,A1=IORQ,D0=unit,D1=flags,
				;  A2=ErrorTable)
	Func	TrackLibrary	; (A0=LibName,D0=version)
	Func	TrackDosObject	; (D0=Type,A0=Tags)
; File operations
	Func	LoadFile	; (A0=name)
	Func	ChkRead		; (A0=tracker,A1=buffer,D0=size)
	Func	ChkWrite	; (A0=tracker,A1=buffer,D0=size)
; Hashed trees
	Func	InitHashTree	; (D0=NumBranches,D1=Flags)
	Func	AddHashItem	; (A0=HashTree,A1=Name,D0=DataSize)
	Func	FindHashItem	; (A0=HashTree,A1=Name)
; Filename manipulation
	Func	AddExtension	; (A0=Source,A1=Dest,A2=Ext,D0=MaxSize)
	Func	SetExtension	; (A0=Source,A1=Dest,A2=Ext,D0=MaxSize)
	Func	GetExtension	; (A0=FileName)
	Func	RemExtension	; (A0=FileName)
; Next generation of names ...
	Func	ChkDoIO		; (A0=Messsage,A1=DeviceTracker)
	Func	SimpleRequest	; (A0=Msg,A1=Params,A2=Gadgets)
; Private functions allowing SS extensions
	Func	AddSSExtens	; (A0=ExtNode)
	Func	RemSSExtens	; (A0=ExtNode)
; Version 3: Memory allocation with pools
	Func	TrackPool	; (D0=Quantum,D1=Threshold,D2=Flags)
	Func	PoolAlloc	; (A0=Pool,D0=size)
	Func	PoolFree	; (A0=Pool,A1=Address,D0=Size)
	Func	TrackLinPool	; (D0=Quantum,D1=Flags)
	Func	LinearAlloc	; (A0=Pool,D1=size)
	Func	LinearAllocN	; (A0=Pool,D1=size)
; Version 4: Sorting and misc
	Func	MergeResLists	; ()
	Func	CallBlock	; (A0=Routine,D0=LeaveResources)
	Func	QuickSort	; (A0=Field,D0=NumEl,D1=ElSize,A1=CFunc)
	Func	SortStrings	; (A0=Field,D0=NumEl)
	Func	SortLongs	; (A0=Field,D0=NumEl)
	Func	SortList	; (A0=List,A1=CompFunc)
	Func	SortListName	; (A0=List)
	Func	TrackAllocPub	; (D0=Size)
	Func	RelinkObject	; (A0=Object)
	Func	TestStack	; ()
; Version 5: Buffered I/O
	Func	TrackOpenBuf	; (A0=name,D0=openmode,D1=bufsize)
	Func	TrackOpenBufFH	; (A0=name,D0=openmode,D1=bufsize,D2=fh)
	Func	TrackBufHandle	; (A0=name,D0=openmode,D1=bufsize)
	Func	ChkTryRead	; (A0=tracker,A1=buffer,D0=size)
	Func	BGetByte	; (A2=tracker)
	Func	BGetWord	; (A2=tracker)
	Func	BGetLong	; (A2=tracker)
	Func	BPutByte	; (D0=char,A3=tracker)
	Func	BPutWord	; (D0=char,A3=tracker)
	Func	BPutLong	; (D0=char,A3=tracker)
	Func	BPutChar	; (D0=char,A3=tracker)
	Func	BPutString	; (A0=string,A3=tracker)
	Func	BGetString	; (A0=buf,D0=size,A2=tracker)
	Func	BPuts		; (A0=string,A3=tracker)
	Func	BPutsNL		; (A0=string,A3=tracker)
	Func	BGets		; (A0=buf,D0=size,A2=tracker)
	Func	BPrintf		; (A0=string,A1=data,A3=tracker)
	Func	BRead		; (A0=tracker,A2=buffer,D0=size)
	Func	BWrite		; (A0=tracker,A3=buffer,D0=size)
	Func	BSeek		; (A2=tracker,D0=offset)
	Func	BRelSeek	; (A2=tracker,D0=offset)
	Func	BTell		; (A2=tracker)
	Func	BUnGetc		; (D0=char,A2=tracker)
	Func	BFlush		; (A2=tracker)
; And some additional services:
	Func	IPAlloc		; (D0=size)
	Func	IPFree		; (A1=address,D0=size)

; System Variables

_SysVarCnt	set	0
SysVar	macro	*size,name
_SysVarCnt	set	_SysVarCnt-\1
\2	equ	_SysVarCnt
	endm

	SysVar	0,ssbase	;R Library base
	SysVar	4,sv_basesize	;P Size of system vars + user data above
	SysVar	4,sv_wbmsg	;R Workbench message (0=CLI)
	SysVar	4,sv_thistask	;R Pointer to task node
	SysVar	4,sv_errsp	;R Stack pointer to program return address
	SysVar	4,sv_checkbase	;P Base checkpoint - (0-BaseAddress)
	SysVar	4,dosbase	;R Dos base
	SysVar	4,intuitionbase	;R Intuition base
	SysVar	4,gfxbase	;R Graphics base
	SysVar	4,gadtoolsbase	;R Gadtools base
	SysVar	4,utilitybase	;R Utility base
	SysVar	4,stdin		;  Standard input stream
	SysVar	4,stdout	;  Standard output stream
	SysVar	4,stderr	;  Standard error stream
	SysVar	4,sv_errsw	;  Error switches (bitmap)
	SysVar	4,sv_progname	;  Program name
	SysVar	4,sv_errrc	;  ReturnCode for error, default=10

	SysVar	12,sv_reslistlist	;P A list of resource lists
	SysVar	8,sv_callernode	;P Node of CallerList
	SysVar	4,sv_rc		;  ReturnCode

	SysVar	4,sv_wbcon	;P Workbench console
	SysVar	4,sv_template	;P Program template
	SysVar	4,sv_extrahelp	;P Program extra help string
	SysVar	4,sv_envvar	;R Environment variable name
	SysVar	4,sv_exitrout	;  Subroutine called before res.freeing
				;  (this pointer is cleared before calling)
	SysVar	4,sv_msgrout	;  Error message routine
				;  (this pointer is cleared before calling)
	SysVar	4,sv_oldexcept	;P Pointer to original exception routine
	SysVar	4,sv_flags	;  Various flags (see below)
	SysVar	4,sv_argdest	;P Address to store arguments at
	SysVar	4,sv_iconbase	;P Pointer to IconBase
	SysVar	4,sv_usertrk	;  Pointer to UserTrkTypes structure or 0
	SysVar	24,sv_mempool	;P Task memory pool
	SysVar	4,sv_lowmem	;  Routine to be called when out of mem.
	SysVar	4,sv_stklimit	;  The lowest allowed SP value
	SysVar	4,sv_defstderr	;P Default stderr or 0
	SysVar	4,sv_memattr	;  Memory attributes for TrackAllocPub

	SysVar	0,sv_sizeof	; Size of system variables block

; Flags in sv_flags

svfb_nowbargs	equ	0		;  Ignore WB arguments
svfb_noprogname	equ	1		;  Don't print program's name in CLI error msgs
svfb_errorreq	equ	2		;  Always use requesters for error msgs
svfb_intrap	equ	3		;P Running trap handler
svfb_nostderr	equ	4		;P sst_nostderr specified
svfb_noiconarg	equ	5		;  Don't pass names of multiselected icons as arg #1
svfb_nocliargs	equ	6		;  Pass CLI arguments directly w/o processing
svfb_dontfree	equ	7		;P Don't free memory from task mempool

svfm_nowbargs	equ	1
svfm_noprogname	equ	2
svfm_errorreq	equ	4
svfm_intrap	equ	8
svfm_nostderr	equ	16
svfm_noiconarg	equ	32
svfm_nocliargs	equ	64
svfm_dontfree	equ	128

; SS.library Base

_LibCnt	set	LIB_SIZE
LibVar	macro	*size,name
ssb_\2	equ	_LibCnt
_LibCnt	set	_LibCnt+\1
	endm

	LibVar	4,seglist	;P SegList
	LibVar	2,ksversion	;R Kickstart version
	LibVar	1,flags		;  Some flags (see below)
	LibVar	1,pad		;P Not used yet
	LibVar	4,dosbase	;R DosBase
	LibVar	4,intuibase	;R IntuitionBase
	LibVar	4,gfxbase	;R GraphicsBase
	LibVar	4,gadtoolsbase	;R GadtoolsBase
	LibVar	4,utilitybase	;R UtilityBase
	LibVar	12,callerlist	;P A list of callers -used for crash recovery
	LibVar	1,cputype	;R CPU type (see tags for IDs)
	LibVar	1,fputype	;R FPU type ( --    ""    -- )
	LibVar	16,extlist	;P SS Extensions
	LibVar	2,opencnt	;P Private OpenCount
	LibVar	SS_SIZE,callis	;P Callerlist semaphore
	LibVar	0,sizeof

; Flags in ssb_flags

SSB_allow30	equ	0		;R KS 3.0 services can be used

; Startup structure

pa_varsize	equ	0		;  Size of user's variables, incl. ssbase
pa_reqssver	equ	2		;  Required version of ss.library
pa_firsttag	equ	4		;  First tag

; Tag types

sstag_old	equ	$0000		; Old SSLib tags
sstag_ext	equ	$4000		; Extended tags
sstag_std	equ	$8000		; Standard tags (two longwords)
sstag_new	equ	$C000		; New tags (ignored when not understood)

sstag_nopar	equ	$0000		; No parameters or special processing
sstag_word	equ	$1000		; One word
sstag_long	equ	$2000		; One longword
sstag_string	equ	$3000		; One string

; Tags
; (The tag array = { DC.W TagType [ Parameters ] EVEN } ... )
; RelPtr = APTR - *

sst_finish	equ	0	; End of the TagList
sst_wbconsole	equ	1	; Create console if started from WB
sst_template	equ	2	; Template: STR,A5-offset-to-store-args-on
sst_usertrk	equ	3	; Define UserTrkTypes: WORD RelPtr
sst_extrahelp	equ	4	; Extra help string: STR
sst_exitrout	equ	5	; Exit routine: WORD RelPTR
sst_usererr	equ	6	; Err routine: WORD RelPTR
sst_nowbstart	equ	7	; Forbid start from workbench
sst_library	equ	8	; Open library: STR,WORD MinVer,WORD BaseOffset
sst_trylib	equ	9	; Try to open library (don't fail) - same as ^
sst_nowbargs	equ	10	; Ignore WB arguments
sst_noprogname	equ	11	; Don't print program's name in error messages
sst_cputype	equ	12	; Required CPU type: BYTE Min,Max
			; 0..4=68000..68040,-1=NoMax
sst_fputype	equ	13	; Required FPU type: BYTE Min,-1 (max not supported)
			; 0=none,1=68881,2=68882,3=68040
sst_sysver	equ	14	; Required kickstart version: BYTE Min,Max(-1=NoMax)
sst_errorreq	equ	15	; Forces using of requesters for error messages
sst_nostderr	equ	16	; stderr=stdout (don't open '*')
sst_errors	equ	17	; Disable automatic error processing:
			; (default is to write an error message and exit)
			; LONG ErrBitMap
sst_wbconname	equ	18	; WB Console specified by name: STR FileName
sst_envvar	equ	19	; ENV variable: STR
sst_last	equ	20

sst_poolsize	equ	$E000	; Set size of task private mempool: LONG size
PMP_DEFSIZE	equ	512	; Default value
sst_poolthresh	equ	$E001	; Set threshold of priv. mempool: LONG threshold
PMP_DEFTHRESH	equ	373	; Default value
sst_noiconarg	equ	$C002	; Don't use names of multiselected icons as arg #1
sst_nocliargs	equ	$C003	; Pass CLI arguments directly without any processing

; Error numbers - normal errors - can be disabled (-> 0 is returned as a result)

err_memory	equ	0	; Insufficient memory
err_openread	equ	1	; Unable to open file %s for reading
err_openwrite	equ	2	; Unable to open file %s for writing
err_lock	equ	3	; Unable to access %s (usually when locking)
err_signal	equ	4	; Unable to get free signal
err_device	equ	5	; Unable to open device %s
err_read	equ	6	; Error reading file %s
err_write	equ	7	; Error writing file %s
err_break	equ	8	; Break
err_port	equ	9	; Unable to get message port
err_iorq	equ	10	; Unable to get iorq
err_library	equ	11	; You need %s.library
err_library2	equ	12	; You need version %ld of %s.library
err_number	equ	13	; Bad number
err_iofail	equ	14	; %s: %s error #%ld (ChkDoIO failed, unknown error)
err_iofail2	equ	15	; %s: %s (ChkDoIO failed, error found in table)
err_interact	equ	16	; File %s is interactive and cannot be loaded
err_stack	equ	17	; Stack overflow. Turning off ignored.
err_unpack	equ	18	; Error while decrunching
err_seek	equ	19	; Seek error on %s
err_over	equ	20	; Buffer overflow while reading %s
err_maximal	equ	21

; Alerts

AN_SSLIB	equ	$35530000
AN_ExitCrash	equ	$35530001	; ExitCleanup can't locate caller
AN_BadTag	equ	$35530002	; Invalid tag ID encountered
AN_BadTracker	equ	$35530003	; Invalid tracker ID in FreeObject()
AN_BadUsrTrkr	equ	$35530004	; Bad user tracker ID in FreeObject()
AN_BadExtTrkr	equ	$35530005	; Bad extension tracker ID, FreeObject()
AN_FreeObject	equ	$35530006	; Freeing already freed tracker
AN_DupSlave	equ	$35530007	; Slave of two masters (TrackSlave())
AN_PoolFree	equ	$35530008	; MemList not found
AN_AllocZero	equ	$35530009	; Attempt to allocate 0 bytes of memory
AN_IoNotSupported equ	$3553000A	; Attempt to write a read stream etc.

; Resource list, must be allocated by CreateResList, freed by FreeResList

resl_node	equ	0		;  Standard MinNode
resl_list	equ	8		;  Standard MinList of resource trackers
resl_sizeof	equ	20

; Resource tracker, must be allocated and freed using SSLib

trk_node	equ	0		;  Standard MinNode
trk_type	equ	8		;R Tracker type (byte)
trk_flags	equ	9		;R Tracker flags (byte)
trk_size	equ	10		;R Size of tracker node (word)
trk_chain	equ	12		;R Pointer to next slave in chain
trk_data	equ	16		;  First data longword
trk_ext	equ	20		;  Second data longword
trk_sizeof	equ	24

; Tracker flags

trf_master	equ	0		;P Is a master tracker
trf_slave	equ	1		;P Is a slave tracker

; UserTrkTypes structure

utt_nr	equ	0		;  Number of user tracker types
utt_flags	equ	1		;  Reserved for future use
utt_addrs	equ	2		;  Array of RelPtrs to freeing routines
				;  Routines called with: A0=tracker
				;  A2=pointer to trk_data in the tracker

; Standard tracker types

trt_null	equ	0		;  Do nothing - you can use it freely
trt_routine	equ	1		;  Call routine (trk_data=routine)
trt_memory	equ	2		;  Free memory (address,length)
trt_file	equ	3		;  Close file (handle,name)
trt_lock	equ	4		;  Unlock lock (lock,name)
trt_port	equ	5		;  Remove port (port)
trt_iorq	equ	6		;  Remove IoRequest (iorq,port tracker)
trt_signal	equ	7		;  Free signal (signal)
trt_device	equ	8		;  Close device (iorq,-,errtable)
trt_library	equ	9		;  Close library (libbase)
trt_dosobj	equ	10		;  Free dos object (object,type)
trt_diskobj	equ	11		;P FreeDiskObject() (used by WB startup)
trt_mempool	equ	12		;P Free memory pool
trt_args	equ	13		;P Free argument buffer
trt_linpool	equ	14		;P Free linear memory pool
trt_bufioh	equ	15		;  Buffered I/O handle
trt_max	equ	16		;  Number of standard tracker types

trt_free	equ	$3F		;P Freed tracker (Freeing causes alert)
trt_ext	equ	$40		;P First tracker type reserved for SSLib
				;P extensions
trt_extmax	equ	$7F		;P Last type for extensions
trt_user	equ	$80		;  First tracker type available to user
trt_usermax	equ	$FF		;  Last tracker type available to user

; Special open modes

OPEN_NEW	equ	-1		;  Create new file (MODE_NEWFILE)
OPEN_OLD	equ	-2		;  Open old file R/W (MODE_OLDFILE)
OPEN_APPEND	equ	-3		;  MODE_READWRITE and seek to end

; Hashed tree - internal structure stored in HashTree tracker

htr_numbr	equ	trk_sizeof+0	;P Number of branches - 1
htr_flags	equ	trk_sizeof+4	;P Flags
htr_pad	equ	trk_sizeof+5	;P Unused
htr_partsize	equ	trk_sizeof+6	;P Size of each tree part
htr_firstpart	equ	trk_sizeof+10	;P Pointer to first tree part
htr_partfree	equ	trk_sizeof+14	;P Free bytes in first tree part
htr_hashtable	equ	trk_sizeof+18	;P Pointer to hash table
htr_sizeof	equ	22

partsize_def	equ	4096		;P Default part size

; Hashed tree flags

htf_nocase	equ	0		;  Case insensitive
htb_nocase	equ	1

; Hashed tree part

hpa_nextpart	equ	0		;P Pointer to next part
hpa_partdata	equ	4		;P Data stored in this part

; Hashed tree item

hit_next	equ	0		;P Next entry with the same hash value
hit_udsize	equ	4		;R Size of user data
hit_ud	equ	6		;  User data followed by key string

; Memory pool - internal structure stored in MemPool tracker

mpt_quantum	equ	trk_data	;P Memory quantum
mpt_thresh	equ	trk_ext		;P Allocation threshold
mpt_flags	equ	trk_sizeof+0	;P Memory flags
mpt_fraglist	equ	trk_sizeof+4	;P List of memory fragments
mpt_sizeof	equ	trk_sizeof+16

; Memory fragment header

mfr_node	equ	0		;P MemHeader of this fragment
mfr_size	equ	MH_SIZE		;P Size of memory fragment header

; Linear memory pool - stored in LinPool tracker

lmp_quantum	equ	trk_data	;P Memory quantum
lmp_flags	equ	trk_ext		;P Memory flags
lmp_first	equ	trk_sizeof+0	;P First fragment
lmp_free	equ	trk_sizeof+4	;P First free zone
lmp_last	equ	trk_sizeof+8	;P End of this free zone
lmp_sizeof	equ	trk_sizeof+12

; ParseArgs flags

pafb_nofail	equ	0		;  Return 0 on errors (default: msg+exit)
pafb_noclear	equ	1		;  Don't clear argument field (leave defaults)
pafb_ignorea	equ	2		;  Don't check presence of /A arguments

pafm_nofail	equ	1
pafm_noclear	equ	2
pafm_ignorea	equ	4

; Extension node (private)

exn_number	equ	0		;P extension number (0-3)
exn_rfu	equ	1		;P should be 0
exn_trktypes	equ	2		;P pointer to UserTrk-style array
exn_sizeof	equ	6

; Buffered I/O Handle Tracker

bh_handle	equ	trk_data	;  File handle (passed to I/O routines)
bh_name	equ	trk_ext		;  File name (for error reports)
bh_readfunc	equ	trk_sizeof	;  Function for reading (Trk,Buf,Size)
bh_writefunc	equ	trk_sizeof+4	;  Function for writing (Trk,Buf,Size)
bh_seekfunc	equ	trk_sizeof+8	;  Function for seeking (Trk,AbsPos)
bh_bufsize	equ	trk_sizeof+12	;R Buffer size
bh_buffer	equ	trk_sizeof+16	;R Pointer to buffer start
bh_current	equ	trk_sizeof+20	;  Pointer to current pos'n in buffer
bh_dataend	equ	trk_sizeof+24	;R Pointer to 1st byte after data in buf
				;  (read streams only)
bh_bufend	equ	trk_sizeof+28	;R Pointer to 1st byte after buffer
bh_position	equ	trk_sizeof+32	;R Position of 1st char in buffer
bh_a5	equ	trk_sizeof+36	;P Backup of caller's A5
bh_eofhook	equ	trk_sizeof+40	;  Routine to be called on EOF
bh_flags	equ	trk_sizeof+44	;R Flags (byte)
bh_pad	equ	trk_sizeof+45	;P RFU
bh_arg1	equ	trk_sizeof+46	;  Reserved for I/O routines
bh_arg2	equ	trk_sizeof+50	;  Reserved for I/O routines
bh_sizeof	equ	trk_sizeof+54

; Buffered I/O Flags

biob_read	equ	0		;P Read stream
biob_write	equ	1		;P Write stream
biob_linebuf	equ	2		;P Line buffering
biob_closefh	equ	3		;P bh_handle contains FH to be freed
biob_eof	equ	7		;R EOF encountered

biof_read	equ	1
biof_write	equ	2
biof_linebuf	equ	4
biof_closefh	equ	8
biof_eof	equ	128

; Buffered I/O Open Flags (ADDed, not ORed !!!)

OPEN_LINEBUF	equ	16		;  Use line buffering if interactive
