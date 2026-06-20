;TOSPJPKPJPKAAAAJKHIAAAGDAKFAAAAFPIKAAAGDFAHAAABAJDIAAAFIOBHAAAFNMAJAAABAJDJAFOKCJMH

;---------------T-------T---------------T------------------------------------T

	IFND	GRConstants_I

GRConstants_I	set	1

;---- Exec includes, unincludable because of the lameness of ASM1! 
LN_PRI=	9
LN_TYPE=	8
LN_NAME=	10
NT_TASK=	1
NT_MSGPORT=	4
NT_PROCESS=	13
TC_STATE=	15
TC_SPREG=	54
TC_SIGWAIT=	22
TS_RUN=	2
LibList=	378
DeviceList=	350
lib_Version=	20
lib_Revision=	22
lib_NegSize=	16
lib_PosSize=	18
lib_OpenCnt=	32
ColdCapture=	42
CoolCapture=	46
ResourceList=	336
PortList=	392
ResModules=	300
KickMemPtr=	546
KickTagPtr=	550
AttnFlags=	296
mp_SigTask=	16
mp_SigBit=	15
mp_Flags=	14
mp_sizeof=	34
rt_EndSkip=	6
rt_Flags=	10
rt_Version=	11
rt_Type=	12
rt_Pri=	13
rt_Name=	14
rt_Init=	22
ml_NumEntries=	14
ml_ME=	16
;---- DOS includes
FIBB_DELETE=	0	;0=allowed
FIBB_EXECUTE=	1	;0=allowed
FIBB_WRITE=	2	;0=allowed
FIBB_READ=	3	;0=allowed
FIBB_ARCHIVE=	4
FIBB_PURE=	5
FIBB_SCRIPT=	6
FIBB_HARDLINK=	7	;Internal GR definitions. Only used for DIR-cmd.
FIBB_COMMENT=	8	;^ DO

ST_ROOT	=	1
ST_USERDIR	=	2
ST_SOFTLINK	=	3       ; looks like dir, but may point to a file!
ST_LINKDIR	=	4       ; hard link to dir
ST_FILE	=	-3      ; must be negative for FIB!
ST_LINKFILE	=	-4      ; hard link to file
ST_PIPEFILE	=	-5      ; for pipes that support ExamineFH

T_SHORT	=	2
T_LIST	=	16
T_DATA	=	8
T_CACHE	=	$21

FH_SELFPOINTER	=	1*4
FH_BLOCKCOUNT	=	2*4
FH_DIRECTORY	=	2*4
FH_CACHECOUNT	=	3*4
FH_HASHSIZE	=	3*4
FH_NEXTCACHE	=	4*4
FH_NEXTDATA	=	4*4
FH_FIRSTDATA	=	4*4
FH_CHECKSUM	=	5*4
FH_DATABLOCKS	=	6*4
FH_CACHEOFFSET	=	6*4
FH_DATABLOCKSE	=	78*4	;datablocks end+4
FH_BMFLAG	=	78*4
FH_BMPAGES	=	79*4
FH_PROTECTION	=	80*4
FH_BYTELEN	=	81*4
FH_COMMENT	=	82*4
FH_TIMEDAYS	=	105*4
FH_TIMEMINS	=	106*4
FH_TIMETICKS	=	107*4
FH_NAME	=	108*4
FH_CREATEDAYS	=	121*4
FH_CREATEMINS	=	122*4
FH_CREATETICKS	=	123*4

FH_HASHCHAIN	=	124*4
FH_PARENTDIR	=	125*4
FH_EXTENSION	=	126*4
FH_CACHEBLOCK	=	126*4
FH_SECTYPE	=	127*4

;---- Graphics
gb_actiview	=	34
gb_copinit	=	38

;---- Utility
sec	=	0
min	=	2
hour	=	4
mday	=	6
month	=	8
year	=	10
wday	=	12

;---- GhostRider.i
gr_ok	=	0	; Function succesful.
gr_grnotfound 	=	-2	; GhostRider was not found in memory.

;---- Codes returned by _LVOGRSetBreakPoint
gr_sbp_fail	=	-1	; Address could not be accessed.
gr_sbp_full	=	1	; Breakpoint table is full.
gr_sbp_isset	=	2	; Address already have a breakpoint.

;---- Codes returned by _LVOGRClrBreakPoint
gr_cbp_notset	=	-1	; Address does not have a breakpoint.


CIAA_PRA	=	$BFE001
CIAA_ICR	=	$bfed01
CIAA_SDR	=	$bfec01

CIAB_PRB	=	$BFD100
CIAB_TALO	=	$BFD400
CIAB_TAHI	=	$BFD500
CIAB_ICR	=	$BFDD00
CIAB_CRA	=	$BFDE00

CIAA_PRB	=	$BFe101
CIAA_TALO	=	$BFe401
CIAA_TAHI	=	$BFe501
CIAA_CRA	=	$BFeE01


;-- Start of "Constant definitions" ---------------------------------------;

;-- Disk Error Codes
DE_OK=		0
DE_ILLEGALTRACK=	1	;Access to illegal track
DE_NOSYNC=		2	;No sync found
DE_CHECKSUMERROR=	3	;Checksum error
DE_NODISK=		4	;No disk in drive
DE_DISKWRITEPROT=	5	;Disk writeprotected
DE_ILLSECTORCOUNT=	6	;Illegal sector count


UseProductivity=0


;---- Disk DMA load size
DBSize=[11*$440+$2e0];/2;disk buffer size (in words); for HD!!!!!!!

;---- Constants used by dis/assembler
MaxMnemonicLen=		9	;max letters in mnemonic name
DefaultSize=		%01	;word size
DisColTab=		13	;size of first column in disassembly
BreakLineLen=		DisColTab

NoAssembly=1	;returned if nothing was assembled
BreakAssembly=2	;returned if a breakline was "assembled"

;---- Constants used for defining buffer sizes
MaxSymbols=		32	;number of symbols
MaxAddresses=		32	;number of addresses in hunt/cmp-buffer
MaxNested=		16	;number of nested addresses
MaxHistory=		16
MaxHeadChars=		68	;#chars in header
MaxBreakPoints=		8	;#of breakpoints

;---- Constants used by screen library
MaxLines=	51		;max number of lines on screen
CharBSize=	MaxLines*80	;size of char buffer

;---- Constant describing the entry mode
em_NotRunning=		0	;checked at NMI entry
em_NMIEntry=		1
em_ResetEntry=		2
em_BreakPoint=		3
em_SystemEntry=		4
em_GenericEntry=	5

;---- Different GRAB IDs
gr_NoGrabbing=		0
gr_Grabbing256k=	1
gr_Grabbing512k=	2

;---- Different edit modes	;change name! (em_)
em_Disassemble=		0
em_HexDump=		4
em_ASCIIDump=		8
em_PeekerDump=		12
;em_SectorEdit... more ideas to come

;---- Mask for editor HELP
eh_Disassemble=		1
eh_HexEdit=		2
eh_ASCIIEdit=		4
eh_PeekerEdit=		8


;---- Exit types
et_Exit=		0
et_Call=		1
et_CallExit=		2

;---- Different commands to resume
res_FindText=		0
res_Find=		1
res_HuntBranch=		2
res_HuntPCRel=		3
res_Compare=		4
res_NOTFind=		5

;---- Flags for resetentry
re_Never=		-1
re_Always=		0
re_RightMouse=		1
re_LeftMouse=		2
re_Joystick=		3

;---- ParsePath types
pp_NEWFILE=		2	;Open new file
pp_FILE=		1	;find file
pp_DIR=		0	;find directory path

;---- DMA setting
;a - set/clr
;b - bltpri
;c - dmaen
;d - bplen
;e - copen
;f - blten
;g - spren
;h - dsken
;i - audxen
;	 a....bcdefghiiii 
GhostDMA=	%1000001111110000

;---- Error Values
;-- Should be returned in D1
EV_OK=			0
EV_SYNTAXERROR=			-1
EV_UNDEFINEDSYMBOL=		-2

EV_ILLEGALADDRESSINGMODE=	-3
EV_ILLEGALSIZE=			-4
EV_ILLEGALMNEMONIC=		-5

EV_UNEXPECTEDEOL=		-6
EV_UNKNOWNCOMMAND=		-7
EV_NODISK=			-8
EV_NOTALLSECTORS=		-9
EV_BADSECID=			-10
EV_BADUNITNUM=			-11;when decoding track
EV_CHECKSUMERROR=		-12
EV_ILLEGALBLOCK=		-13;when calling getblock
EV_SYMBOLTABLEFULL=		-14
EV_ILLEGALSYMBOLNAME=		-15
EV_ILLEGALSEPARATOR=		-16
EV_ILLEGALTRACK=		-17
EV_ILLEGALLEN=			-18
EV_ILLEGALAREA=			-19
EV_NOFINDDATA=			-20
EV_NOTFOUND=			-21
EV_JUMPTABLEFULL=		-22;nested jumps
EV_NONESTEDADDS=		-23
EV_NOTHINGTORESUME=		-24
EV_UNBALANCEDPARANTHES=		-25
EV_NOVALUE=			-26

EV_UNKNOWNDATATYPE=		-27
EV_ILLEGALREGNUM=		-28
EV_ILLEGALINDEX=		-29
EV_INVALIDSCALE=		-30
EV_NUMBERTOOBIG=		-31
EV_ONLYONEBDALLOWED=		-32
EV_ONLYONEODALLOWED=		-33
EV_ONLYONEINDEX=		-34
EV_WRONGREGORDER=		-35
EV_DESTINATIONNEEDED=		-36
EV_ILLEGALBITFIELD=		-37
EV_ILLEGALCC=			-38
EV_MUSTMATCHFIRSTHALF=		-39
EV_COULDNOTFINDHALF=		-40

EV_NOAREASELECTED=		-41
EV_DISKWRITEPROTECTED=		-42
EV_NOFILLDATA=			-43
EV_AREASOVERLAP=		-44

EV_UNKNOWNDRIVETYPE=		-45
EV_NOTAVALIDDRIVENO=		-46

EV_CORRUPTEXECBASE=		-47

EV_NOTAVALIDVECTOR=		-48
EV_NOTCHIPADDRESS=		-49
EV_VBRCONFLICT=			-50
EV_GRCONFLICT=			-51

EV_MISSINGID=			-52

EV_BPBUFFERFULL=		-53
EV_BPBUFFEREMPTY=		-54
EV_BPALREADYSET=		-55
EV_NOBREAKPOINT=		-56
EV_INVALIDTRAPNO=		-57

EV_ILLEGALDRIVE=		-58

EV_ILLEGALCOPPER=		-59
EV_ILLEGALCOPOFFSET=		-60

EV_ILLEGALCUSOFFSET=		-61

EV_CORRUPTDIRCACHE=		-62

EV_NOFILENAME=			-63
EV_CORRUPTFILENAME=		-64

EV_PRETTYFAST=			-65

EV_FILENOTFOUND=		-66

EV_PEEKERWIDTH=			-67

EV_NOSECHDR=			-68

EV_COULDNOTSETBP=		-69

EV_NOTADIRECTORY=		-70
EV_NOPARENTDIR=			-71
EV_NOTAFILE=			-72

EV_NOTENOUGHSPACE=		-73

EV_SEEKERROR=			-74
EV_NOTAMIGADOSFORMAT=		-75
EV_BADHDRSUM=			-76
EV_BADSECSUM=			-77
EV_DISKVERIFYERROR=		-78

;---- Keyboard qualifiers
kq_lshift=		0
kq_rshift=		1
kq_capslock=		2
kq_ctrl=		3
kq_lalt=		4
kq_ralt=		5
kq_lamiga=		6
kq_ramiga=		7

kq_shiftmask=		3
kq_altmask=		1<<kq_lalt!1<<kq_ralt
kq_amigamask=		1<<kq_lamiga!1<<kq_ramiga
kq_funcmask=		1<<kq_ramiga

key_PointerPos=		11	;signals new cursor pos
key_tab=		9
key_up=		1
key_down=		2
key_right=		3
key_left=		4
key_bs=		8
key_help=		138
key_ret=		10
key_del=		$7f
key_esc=		$1b

;---- Internal Pointer IDs
ip_END=	-1
ip_SysEntry=	0
ip_RSTEntry=	1
ip_NMIEntry=	2
ip_SetPort=	3
ip_RemPort=	4
ip_PrefsBase=	5
ip_SetBRKPT=	6
ip_ClrBRKPT=	7

;---- Constants used by the mouse reader
SPRHEI=	8
MMINX=	$80
MMAXX=	$1bf

SpriteYOffset=	43

;---- Constants for the cursor
CursorX=	$40		;xbase for cursor
CursorXCustom=	$22		;xbase for cursor

;---- Timer related constants
StepDelay=	3
SettleDelay=	15
ONEmsDelayPAL=	(1000*100000/140968+1)/10;1/10 ms
ONEmsDelayNTSC=	(1000*100000/139683+5)/10;1/10 ms


*----- End of "Constant definitions" -----------------------------------------*
	ENDC
