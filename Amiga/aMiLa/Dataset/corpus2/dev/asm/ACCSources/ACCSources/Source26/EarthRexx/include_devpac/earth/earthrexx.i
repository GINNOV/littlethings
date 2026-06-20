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

		rsset	LIB_SIZE
erb_ExecBase	rs.l	1	Base of exec.library
erb_ArpBase	rs.l	1	Base of arp.library
erb_IntuitionBase rs.l	1	Base of intuition.library
erb_RexxBase	rs.l	1	Base of rxsyslib.library [or NULL]
erb_Resource	rs.l	1	Base of earthrexx.resource
erb_SegList	rs.l	1	Library segment
erb_AREXX	rs.b	1	Instance of string "AREXX"
erb_REXX	rs.b	5	Instance of string "REXX"
ERB_SIZE	rs.w	0

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

		rsreset
nrp_PortName	rs.l	1	Pointer to name of ARexx port.
nrp_Extension	rs.l	1	Pointer to extension string (or NULL).
nrp_Commands	rs.l	1	Address of command table (or NULL).
nrp_Functions	rs.l	1	Address of function table (or NULL).
nrp_UserFlags	rs.w	1	Various flags - see below.
nrp_Priority	rs.b	1	Port priority.
nrp_FHPriority	rs.b	1	Function host priority.
nrp_DispatchFn	rs.l	1	Address of user dispatch function (or NULL).
nrp_PassFn	rs.l	1	Address of user pass function (or NULL).
nrp_FailFn	rs.l	1	Address of user fail function (or NULL).
nrp_StackSize	rs.l	1	Stack size for recursions (or zero).
nrp_SIZE	rs.w	0

		rsreset
RPB_OLDCAT	rs.b	1	Set to use pre-existing MemoPad/ClipList.
RPB_ERRORS	rs.b	1	Set to use default FailFn() routine.
RPB_COMPACT	rs.b	1	Set to use compact cmd/func tables.
RPB_CASE	rs.b	1	Set to use case sensitive comparisons.
RPB_ABBREV	rs.b	1	Set to allow abbreviations.
RPB_SPACES	rs.b	1	Set to allow embedded spaces.
RPB_CLIPLIST	rs.b	1	Set to use cliplist for cmd/func tables.
RPB_MEMOPAD	rs.b	1	Set to use memopads for cmd/func tables.
RPB_NONSTD	rs.b	1	Set to allow nonstandard Rexx invokations.
RPB_DEADEND	rs.b	1	Set to fail messages not understood.
RPB_SINGLE	rs.b	1	Set to use single-port model.
RPB_ACTIVE	rs.b	1	Set to come up active.
RPB_INACTIVE	rs.b	1	Set to come up inactive.
RPB_NEWSTACK	rs.b	1	Set to give recursions new stack.

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

		rsreset
	;
	;	The embedded message port
	;	~~~~~~~~~~~~~~~~~~~~~~~~~
rp_Port 	rs.b	MP_SIZE The port itself
	;
	;	The NewRexxPort copy
	;	~~~~~~~~~~~~~~~~~~~~
rp_PortName	rs.l	1	Global port name
rp_Extension	rs.l	1	Pointer to extension string (or NULL)
rp_Commands	rs.l	1	Address of command table (or NULL)
rp_Functions	rs.l	1	Address of function table (or NULL)
rp_UserFlags	rs.w	1	Various flags - see above
rp_GlobSigBit	rs.b	1	Global port signal bit
rp_FHPriority	rs.b	1	Function host priority
rp_DispatchFn	rs.l	1	Address of user dispatch function (or NULL)
rp_PassFn	rs.l	1	Address of user pass function (or NULL)
rp_FailFn	rs.l	1	Address of user fail function (or NULL)
rp_StackSize	rs.l	1	Stack size for recursions (or zero)
	;
	;	Other fields of possible interest to user
	;	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
rp_UserData	rs.l	1	Anything you like
rp_WaitMask	rs.l	1	Mask to Wait() on for Rexx messages
rp_HostAddress1 rs.l	1	Primary host address
rp_HostAddress2 rs.l	1	Secondary host address
	;
	;	The rest of the structure - All this is private!
	;	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
rp_PrivSigMask	rs.l	1	Signal mask for this port
rp_GlobSigMask	rs.l	1	Signal mask for global port
rp_GlobalPort	rs.l	1	Address of global port
rp_MsgCount	rs.w	1	Counts messages we haven't had replied yet
rp_SysFlags	rs.w	1	System flags - see below
rp_Link 	rs.b	MLN_SIZE	Link to sibling ports
rp_SIZE 	rs.w	0

; Various flags may fill the rp_SysFlags field.
; These are as follows:
; (First the bit numbers)

		rsreset
RPSB_READY	rs.b	1	Set if port is ready to recieve
RPSB_NOREPLY	rs.b	1	Set to prevent msg from being replied
RPSB_SHUTDOWN	rs.b	1	Set if closing down the port
RPSB_REQUEST	rs.b	1	Set if StdFailFn wants requester

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

		rsreset 	struct CmdEntry
cme_CmdName	rs.l	1	Pointer to command name
cme_Handler	rs.l	1	Pointer to handler entry point
cme_SIZE	rs.w	0

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

