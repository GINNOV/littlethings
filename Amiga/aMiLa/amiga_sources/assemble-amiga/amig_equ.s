DTA_BUFFER_SIZE	EQU	256

	; Exec
Forbid		equ	-132
Permit		equ	-138
AllocMem		equ	-198
FreeMem		equ	-210
AvailMem		equ	-216
OldOpenLib	equ	-408
CloseLibrary	equ	-414
OpenLibrary	equ	-552
SetFunction	equ	-420
RemTask		equ	-288
FindTask		equ	-294
AddIntServer	equ	-168
RemIntServer	equ	-174
FindName		equ	-276
PutMsg		equ	-366
GetMsg		equ	-372
ReplyMsg		equ	-378
WaitPort		equ	-384
AllocSignal	equ	-330
FreeSignal	equ	-336
AddPort		equ	-354
RemPort		equ	-360
OpenDevice	equ	-444
CloseDevice	equ	-450
DoIO		equ	-456

	; Dos
Open	equ	-30
Close	equ	-36
Read	equ	-42
Write	equ	-48
Input	EQU	-54 
Output	EQU	-60 
Seek	equ	-66
Lock	equ	-84
UnLock	equ	-90
Examine	equ	-102
ExNext	equ	-108
IOErr	equ	-132
CreateProc	equ	-138
CurrentDir	equ	-126
Delay		equ	-198
WaitForChar	equ	-204
ParentDir	equ	-210
Execute		equ	-222
	; Intuition
OpenWindow	equ	-204
CloseWindow	equ	-72
IECLASS_RAWKEY	EQU	1
ie_Class	equ	4
ie_SubClass	equ	5
ie_Code		equ	6
ie_Qualifier	equ	8
ie_EventAddress	equ	10
ie_TimeStamp	equ	14 (2 longs TV_SECS et TV_MICRO)

MEMF_LARGEST	EQU	$20000
VBlankFrequency	EQU	$212
AttnFlags		equ	$128

MP_FLAGS	equ	14
MP_SIGBIT	equ	15
MP_SIGTASK	equ	16
PA_SIGNAL	equ	0
NT_MSGPORT	equ	4

IO_DEVICE	equ	20
IO_COMMAND	equ	$1c
IO_ERROR	equ	$1f
IO_SIZE		equ	$20
IO_LENGTH	equ	$24
IO_DATA		equ	$28
IND_ADDHANDLER	equ	9
IND_REMHANDLER	equ	10
MN_REPLYPORT	equ	14
IS_DATA		equ	14
IS_CODE		equ	18

MP_SIZE		equ	$22
IOSTD_SIZE	equ	$30
IS_SIZE		equ	$16

ACTION_DISK_INFO	equ	25
id_VolumeNode	equ	28

ThisTask		equ	$114
tc_UserData	equ	$5c
pr_ConsoleTask	equ	$a4
pr_CLI		equ	$ac
pr_PktWait	equ	$b4
wd_Flags		equ	$18
LIB_VERSION	EQU	$14
	rsreset
ln_succ		rs.l	1
ln_pred		rs.l	1
ln_type		rs.b	1
ln_pri		rs.b	1
ln_name		rs.l	1

;struct representant une section
	STRUCTINIT
	PTR	SECTION_next
	PTR	SECTION_samenext
	PTR	SECTION_sameprev
	BYTE	SECTION_ok
	BYTE	SECTION_mem	;0:rien,30:chip,31:fast
	WORD	SECTION_type	;0:text,4:data,8:bss
	WORD	SECTION_num	;CurSection
	LONG	SECTION_size
	LONG	SECTION_offs
	LONG	SECTION_partsize
	PTR	SECTION_bin_bl		;@ binary block descriptor
	PTR	SECTION_bin_start	;@ binary section start
	PTR	SECTION_expstrtbl	;CurGloExp au moment de la decl
	PTR	SECTION_expstrtcur	;HEAD_current
	PTR	SECTION_expendbl	;CurGloExp fin de section
	PTR	SECTION_expendcur	;HEAD_current
	PTR	SECTION_name
	LONG	SECTION_maxreloc	;nb d'exps P_ABSL et P_DCL
	LONG	SECTION_relocnb
	PTR	SECTION_reltab
	PTR	SECTION_currel
	PTR	SECTION_xreflist
	LONG	SECTION_xrefnb
	SIZEOF	DESC_SECTION_SIZEOF

	STRUCTINIT
	PTR	XREFL_next
	PTR	XREFL_cur
	PTR	XREFL_end
	PTR	XREFL_start
	WORD	XREFL_nb
	SIZEOF	XREFL_SIZEOF

HUNK_UNIT		equ	$3e7
HUNK_NAME		equ	$3e8
HUNK_CODE		equ	$3e9
HUNK_DATA		equ	$3ea
HUNK_BSS		equ	$3eb
HUNK_RELOC32	equ	$3ec
HUNK_RELOC16	equ	$3ed
HUNK_RELOC8	equ	$3ee
HUNK_EXT		equ	$3ef
HUNK_SYMBOL	equ	$3f0
HUNK_DEBUG	equ	$3f1
HUNK_END		equ	$3f2
HUNK_HEADER	equ	$3f3
