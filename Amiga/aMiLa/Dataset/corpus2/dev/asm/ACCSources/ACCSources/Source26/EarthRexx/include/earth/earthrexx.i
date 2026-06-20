	IFND	EARTH_EARTHREXX_I
EARTH_EARTHREXX_I	set	1

	include	exec/types.i
	include	exec/ports.i
	include	exec/lists.i
	include	exec/nodes.i
	include	exec/libraries.i

	include	rexx/storage.i
	include	rexx/errors.i

;==================================================================
;	EarthRexxBase
;==================================================================

	STRUCTURE EarthRexxBase,LIB_SIZE
	APTR	erb_SysBase		Base of exec.library
	APTR	erb_ArpBase		Base of arp.library
	APTR	erb_IntuitionBase	Base of intuition.library
	APTR	erb_RexxBase		Base of rxsyslib.library [or 0]
	APTR	erb_Resource		Base of earthrexx.resource
	BPTR	erb_SegList		Library segment
	STRPTR	erb_AREXX		Pointer to string "AREXX"
	STRPTR	erb_REXX		Pointer to string "REXX"
	LABEL	erb_SIZE

;==================================================================
;	NewRexxPort
;==================================================================
;
; The NewRexxPort structure....
; Allocate or otherwise obtain one of these.
; Fill in EVERY field.
; Then call OpenRexxPort().
; On return you get a struct RexxPort.
; You are then free to deallocate or reuse the NewRexxPort.

	STRUCTURE NewRexxPort,0
	STRPTR	nrp_PortName	Pointer to name of ARexx port.
	STRPTR	nrp_Extension	Pointer to extension string (or NULL).
	APTR	nrp_Commands	Address of command table (or NULL).
	APTR	nrp_Functions	Address of function table (or NULL).
	UWORD	nrp_UserFlags	Various flags - see below.
	BYTE	nrp_Priority	Port priority.
	BYTE	nrp_FHPriority	Function host priority.
	APTR	nrp_DispatchFn	Address of user dispatch function (or NULL).
	APTR	nrp_PassFn	Address of user pass function (or NULL).
	APTR	nrp_FailFn	Address of user fail function (or NULL).
	ULONG	nrp_StackSize	Stack size for recursions (or zero).
	LABEL	nrp_SIZE	

RPB_OLDCAT	equ	0	Set to use pre-existing MemoPad/ClipList.
RPB_ERRORS	equ	1	Set to use default FailFn() routine.
RPB_COMPACT	equ	2	Set to use compact cmd/func tables.
RPB_CASE	equ	3	Set to use case sensitive comparisons.
RPB_ABBREV	equ	4	Set to allow abbreviations.
RPB_SPACES	equ	5	Set to allow embedded spaces.
RPB_CLIPLIST	equ	6	Set to use cliplist for cmd/func tables.
RPB_MEMOPAD	equ	7	Set to use memopads for cmd/func tables.
RPB_NONSTD	equ	8	Set to allow nonstandard Rexx invokations.
RPB_DEADEND	equ	9	Set to fail messages not understood.
RPB_SINGLE	equ	10	Set to use single-port model.
RPB_ACTIVE	equ	11	Set to come up active.
RPB_INACTIVE	equ	12	Set to come up inactive.
RPB_NEWSTACK	equ	13	Set to give recursions new stack.

; (Then the fields)

RPF_OLDCAT	equ	1<<RPB_OLDCAT
RPF_ERRORS	equ	1<<RPB_ERRORS
RPF_COMPACT	equ	1<<RPB_COMPACT
RPF_CASE	equ	1<<RPB_CASE
RPF_ABBREV	equ	1<<RPB_ABBREV
RPF_SPACES	equ	1<<RPB_SPACES
RPF_CLIPLIST	equ	1<<RPB_CLIPLIST
RPF_MEMOPAD	equ	1<<RPB_MEMOPAD
RPF_NONSTD	equ	1<<RPB_NONSTD
RPF_DEADEND	equ	1<<RPB_DEADEND
RPF_SINGLE	equ	1<<RPB_SINGLE
RPF_ACTIVE	equ	1<<RPB_ACTIVE
RPF_INACTIVE	equ	1<<RPB_INACTIVE
RPF_NEWSTACK	equ	1<<RPB_NEWSTACK

;==================================================================
;	RexxPort
;==================================================================
;
; The RexxPort structure....
; Strictly READ-ONLY! No write access is allowed,
; except through prescribed functions and macros.

	STRUCTURE RexxPort,0
	;
	;	The embedded message port
	;	~~~~~~~~~~~~~~~~~~~~~~~~~
	STRUCT	rp_Port,MP_SIZE		The port itself
	;
	;	The NewRexxPort copy
	;	~~~~~~~~~~~~~~~~~~~~
	STRPTR	rp_PortName		Global port name
	STRPTR	rp_Extension		Pointer to extension string (or NULL)
	APTR	rp_Commands		Address of command table (or NULL)
	APTR	rp_Functions		Address of function table (or NULL)
	UWORD	rp_UserFlags		Various flags - see above
	UBYTE	rp_GlobSigBit		Global port signal bit
	BYTE	rp_FHPriority		Function host priority
	APTR	rp_DispatchFn		Address of user dispatch function (or NULL)
	APTR	rp_PassFn		Address of user pass function (or NULL)
	APTR	rp_FailFn		Address of user fail function (or NULL)
	ULONG	rp_StackSize		Stack size for recursions (or zero)
	;
	;	Other fields of possible interest to user
	;	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	ULONG	rp_UserData		Anything you like
	ULONG	rp_WaitMask		Mask to Wait() on for Rexx messages
	STRPTR	rp_HostAddress1 	Primary host address
	STRPTR	rp_HostAddress2 	Secondary host address
	;
	;	The rest of the structure - All this is private!
	;	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	ULONG	rp_PrivSigMask		Signal mask for this port
	ULONG	rp_GlobSigMask		Signal mask for global port
	APTR	rp_GlobalPort		Address of global port
	UWORD	rp_MsgCount		Counts messages we haven't had replied yet
	UWORD	rp_SysFlags		System flags - see below
	STRUCT	rp_Link,MLN_SIZE	Link to sibling ports
	LABEL	rp_SIZE

; Various flags may fill the rp_SysFlags field.
; These are as follows:
; (First the bit numbers)

RPSB_READY	equ	0	Set if port is ready to recieve
RPSB_NOREPLY	equ	1	Set to prevent msg from being replied
RPSB_SHUTDOWN	equ	2	Set if closing down the port
RPSB_REQUEST	equ	3	Set if StdFailFn wants requester

; (Then the fields)

RPSF_READY	equ	1<<RPSB_READY
RPSF_NOREPLY	equ	1<<RPSB_NOREPLY
RPSF_SHUTDOWN	equ	1<<RPSB_SHUTDOWN
RPSF_REQUEST	equ	1<<RPSB_REQUEST

;==================================================================
;	CmdEntry
;==================================================================
;
; This is the default structure for specifying commands and functions.
; You supply an array of these structures, terminated by a NULL longword.

	STRUCTURE CmdEntry,0
	STRPTR	cme_CmdName	Pointer to command name
	APTR	cme_Handler	Pointer to handler entry point
	LABEL	cme_SIZE

; This is NOT the most memory efficient way of doing things.
; Machine code programmers may prefer to use the DEFCMD and DEFFN macros
; (set RPF_COMPACT if you do this).

DEFCMD	MACRO	;[command[,routine]]
	IFC	'\1',''
	dc.w	0
	ELSEIF
	dc.b	"\1",0
	even
	IFC	'\2',''
	dc.l	\1
	ELSEIF
	dc.l	\2
	ENDC
	ENDC
	ENDM

DEFFN	MACRO	;[function[,routine]]
	DEFCMD	\1,\2
	ENDM

;==================================================================
;	Argstring (negative offsets)
;==================================================================

as_Size 	equ	ra_Size-ra_Buff
as_Length	equ	ra_Length-ra_Buff
as_Flags	equ	ra_Flags-ra_Buff
as_Hash 	equ	ra_Hash-ra_Buff

rm_RRI		equ	rm_Args+15*4

;==================================================================
;	Action codes for messages expressed as bytes
;==================================================================

RX_COMM 	equ	RXCOMM>>24
RX_FUNC 	equ	RXFUNC>>24
RX_CLOSE	equ	RXCLOSE>>24
RX_QUERY	equ	RXQUERY>>24
RX_ADDFH	equ	RXADDFH>>24
RX_ADDLIB	equ	RXADDLIB>>24
RX_REMLIB	equ	RXREMLIB>>24
RX_ADDCON	equ	RXADDCON>>24
RX_REMCON	equ	RXREMCON>>24
RX_TCOPN	equ	RXTCOPN>>24
RX_TCCLS	equ	RXTCCLS>>24

;==================================================================
;	ARexx error codes
;==================================================================

RXERR_PROGRAM_NOT_FOUND 		equ	ERR10_001
RXERR_EXECUTION_HALTED			equ	ERR10_002
RXERR_NO_MEMORY 			equ	ERR10_003
RXERR_INVALID_CHARACTER 		equ	4
RXERR_UNMATCHED_QUOTE			equ	ERR10_005
RXERR_UNTERMINATED_COMMENT		equ	ERR10_006
RXERR_CLAUSE_TOO_LONG			equ	7
RXERR_UNRECOGNISED_TOKEN		equ	ERR10_008
RXERR_UNRECOGNIZED_TOKEN		equ	ERR10_008
RXERR_SYMBOL_TOO_LONG			equ	ERR10_009
RXERR_STRING_TOO_LONG			equ	ERR10_009

RXERR_INVALID_MESSAGE_PACKET		equ	ERR10_010
RXERR_COMMAND_STRING_ERROR		equ	ERR10_011
RXERR_ERROR_RETURN			equ	ERR10_012
RXERR_HOST_NOT_FOUND			equ	ERR10_013
RXERR_LIBRARY_NOT_FOUND 		equ	ERR10_014
RXERR_FUNCTION_NOT_FOUND		equ	ERR10_015
RXERR_NO_RETURN_VALUE			equ	ERR10_016
RXERR_WRONG_NUMBER_OF_ARGUMENTS 	equ	ERR10_017
RXERR_INVALID_ARGUMENT			equ	ERR10_018
RXERR_INVALID_PROCEEDURE		equ	ERR10_019

RXERR_UNEXPECTED_THEN			equ	ERR10_020
RXERR_UNEXPECTED_ELSE			equ	ERR10_020
RXERR_UNEXPECTED_WHEN			equ	ERR10_021
RXERR_UNEXPECTED_OTHERWISE		equ	ERR10_021
RXERR_UNEXPECTED_LEAVE			equ	ERR10_022
RXERR_UNEXPECTED_ITERATE		equ	ERR10_022
RXERR_SELECT_ERROR			equ	ERR10_023
RXERR_MISSING_THEN			equ	ERR10_024
RXERR_MISSING_OTHERWISE 		equ	ERR10_025
RXERR_MISSING_END			equ	ERR10_026
RXERR_UNEXPECTED_END			equ	ERR10_026
RXERR_SYMBOL_MISMATCH			equ	ERR10_027
RXERR_INVALID_DO			equ	ERR10_028
RXERR_INCOMPLETE_DO			equ	ERR10_029
RXERR_INCOMPLETE_IF			equ	ERR10_029
RXERR_INCOMPLETE_SELECT 		equ	ERR10_029

RXERR_LABEL_NOT_FOUND			equ	ERR10_030
RXERR_SYMBOL_EXPECTED			equ	ERR10_031
RXERR_STRING_EXPECTED			equ	ERR10_032
RXERR_INVALID_SUB_KEYWORD		equ	ERR10_033
RXERR_KEYWORD_MISSING			equ	ERR10_034
RXERR_EXTRANEOUS_CHARACTERS		equ	ERR10_035
RXERR_SUB_KEYWORD_CONFLICT		equ	ERR10_036
RXERR_INVALID_TEMPLATE			equ	ERR10_037
RXERR_INVALID_TRACE_REQEST		equ	38
RXERR_UNINITIALISED_VARIABLE		equ	ERR10_039

RXERR_INVALID_NAME			equ	ERR10_040
RXERR_INVALID_EXPRESSION		equ	ERR10_041
RXERR_UNBALANCED_PARENTHESES		equ	ERR10_042
RXERR_NEST_TOO_DEEP			equ	ERR10_043
RXERR_INVALID_RESULT			equ	ERR10_044
RXERR_EXPRESSION_REQUIRED		equ	ERR10_045
RXERR_INVALID_BOOLEAN			equ	ERR10_046
RXERR_ARITHMETIC_ERROR			equ	ERR10_047
RXERR_INVALID_OPERAND			equ	ERR10_048

;==================================================================
;	Useful macros and constants
;==================================================================

ADDRESS MACRO	;[host]
	move.l	a0,d0
	beq.b	.ad\@
	IFC	'\1',''
	move.l	rp_HostAddress2(a0),a1
	move.l	rp_HostAddress(a0),rp_HostAddress2(a0)
	move.l	a1,rp_HostAddress2(a0)
	ELSEIF
	move.l	rp_HostAddress(a0),rp_HostAddress2(a0)
	move.l	\1,rp_HostAddress2(a0)
	ENDC
.ad\@	;
	ENDM

PACK	MACRO	;longword
	move.l	\1,-(sp)
	move.l	sp,a0
	moveq	#4,d0
	jsr	_LVONewCreateArgstring(a6)
	lea.l	4(sp),sp
	ENDM

UNPACK	MACRO	;argstring,dest
	move.l	(\1),\2
	ENDM

EARTHREXXNAME	MACRO
	dc.b	"earthrexx.library",0
	ENDM

EARTHREXXVERSION equ	2	Current version number of library

RP_OK		equ	0	All OK
RP_NOREPLY	equ	-129	Postpone reply of message
RP_STRING	equ	-131	Convert string to argstring
RP_ARGSTRING	equ	-133	Copy argstring
RP_PACKED	equ	-135	Convert address to packed argstring
RP_DECIMAL	equ	-137	Convert integer to decimal argstring
RP_SYNC 	equ	-139	Send synchronous message

;==================================================================
;	That's All Folks!
;==================================================================

	ENDC

