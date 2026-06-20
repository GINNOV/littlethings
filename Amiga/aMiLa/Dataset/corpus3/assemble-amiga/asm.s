;  #[ Bugs & A faire:
	IFNE	0
-prendre -u (GCC)
-__MCH (Atari/Amiga)
-rorg
-even/cargs/pargs/dc/ds/dcb/rs/rseven.sdxp
-inconce
-opt p=xxx/xxx
-listing binaire etc... (FORMAT)
-pas de crlf apres ENDM
-les macros inter-fichiers en mode slow
-@<letter[s]>=local label
-reconnaitre:
	-COMM(LCOMM)	(GCC)
	-STABD,STABN,STABS	(GCC)
	-MACRO.Sz
	-MACHINE MCxxx
	-EQUENV
	-MCALL
	-PATH (GFA,TA),ASSERT(GFA,MAD)
	-IIFcc,IFF,IFB,IFNB (PA)
	-BASE,ENDB (TA,PRO)
	-LOCAL (macro:\@(PA),zone locale(GFA)),REPEAT..UNTIL(PRO)
	-INIT (GFA,MAD)
-warning data/bss aligned
-prendre .directive
  	ENDC
;  #] Bugs & A faire:
	opt	o+,ow-,o1-,w-
DEBUG	equ	0
TEST_VAR	equ	0
TEST_LOC	equ	0
TEST_EQU	equ	0
	include	"comequ.s"
	IFNE	AMIGA
	include	"amig_equ.s"
	ENDC
	IFNE	BLINDOS
STKSIZE	equ	8192
	ELSEIF
STKSIZE	equ	32768
	ENDC
;  #[ Xref:
	XREF	GlobalPatch,LocalPatch,StoreEXP,ResetLocEXPs,BsdCreateOffsets
	XREF	LoadSrc,FlushPrg,OutMsg,OutLst,PSymTab
	XREF	Sprintf,FreeEval,FreeEXPs,GetMPU
	XREF	PrtLine,PrtChar,GetIEnv,StrtTime,StopTime,DoEnd
	XREF	GlobPatchFlag,LocPatchFlag,HeadExp,TotExpNb
	XREF	TotErr,TotWarn,LstErr,LstWarn
	XREF	HeadEditBlock,CurEditBlock,IEnvFlg,IEnvPtr,IAsmBuf
	XREF	EaSp,CursPtr,CursW
	IFNE	AMIGA
	XREF	Amiga_Inits,FreeSections,amiga_cmd_line
	ENDC
;  #] Xref:
;  #[ Xdef:
	XDEF	ReserveMemory,UpdateBinBuffer,FreeMemory
	XDEF	FatalError,NoPrtEnd
	XDEF	RetNor,RetMac
	XDEF	TopStack,CurModPtr,FlshBuf
;  #] Xdef:
;  #[ Main:
	bra.s	main
	dc.l	0		;stksize
	dc.b	0,'ASM'		;magic
	dc.l	VERSION		;version #
	dc.l	IAsmBuf		;IAsm struct
	dc.l	startenv		;start @ if ienv
main:
	IFNE	AMIGA
	jsr	Amiga_Inits
	ENDC	;AMIGA

	lea	NoneTxt,a0
	lea	OutName,a1
	STRCPY

	IFNE	ATARI
	move.l	4(a7),a3
	lea	mystack,a7
	move.l	$c(a3),d0
	add.l	$14(a3),d0
	add.l	$1c(a3),d0
	add.l	#$100,d0
	move.l	d0,-(sp)
	move.l	a3,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	lea	12(sp),sp
	move.l	a3,a0
	ENDC	;ATARI

startenv:	move.l	d0,-(sp)
	jsr	GetIEnv
	tst.b	IEnvFlg
	bne.s	.nopres
	lea	PresTxt,a0
	jsr	PrtLine
.nopres:	move.l	(sp)+,d0
	bne	FstFatal

	tst.b	IEnvFlg
	beq.s	.noienv

	bsr	InitMemory
	bmi	FstFatal

	jsr	InitPaths
	bmi	FstFatal
	bra	.ienv

.noienv:
	IFNE	ATARI
	dc.w	$a000
	move.w	-44(a0),CursW
	lea	-28(a0),a0
	move.l	a0,CursPtr
	ENDC	;ATARI

	;default values
	move.w	#3,MacAroDigit	;\@ xxx
	move.w	#132,LstLnLen	;default line length = 132
	move.w	#60,LstPgLen	;default page length = 60
	moveq	#-1,d0
	move.w	d0,CaseFlg	;case sensitive
	move.w	d0,EquFFlg	;flush equs
	move.w	d0,LstCnt		;no list
	move.b	#1,FPUId		;FPU Id=1
	move.w	#17,FPUk		;FPU k=+17
	lea	$80(a3),a0	;cmd line
	bsr	GetCmdLine

	lea	-256(sp),sp
	move.l	sp,a0
	pea	SrcOrgName
	lea	WorkTxt,a1
	jsr	Sprintf
	addq.w	#4,sp
	move.l	sp,a0
	jsr	PrtLine
	lea	256(sp),sp

.ienv:	bsr	InitMemory
	bmi	FstFatal

	jsr	InitPaths
	bmi	FstFatal

	lea	IncBuf,a0
	tst.b	(a0)
	beq.s	.noincl
	jsr	AddPathList
	clr.b	IncBuf

.noincl:	jsr	StrtTime

	IFEQ	_68000
	jsr	GetMPU
	subq.w	#1,d0
	bhi.s	.mpuok
	move	#bad_mpu_errno,d0
	jmp	prepfatal
.mpuok:	ENDC

	move.l	#LINEBUF_SIZE,d0
	bsr	MyMalloc
	beq	FstFatal
	move.l	d0,FieldsPtr

	tst.b	IEnvFlg
	beq.s	.loadsrc
	;;;;;; IENV ;;;;;;;
	move.l	CurModPtr,a0
	bsr	ModUpdate
	clr.l	MOD_father(a0)
	move.l	MOD_addr(a0),a6
	move.l	a6,SrcCurStart
	bra.s	.suite
	;;;; pas IENV ;;;;;
.loadsrc:	lea	-PATHSZ(sp),sp
	move.l	sp,a1
	lea	SrcOrgName,a0
	jsr	FindIncFile
	bpl.s	.ff
.errf:	lea	PATHSZ(sp),sp
	bra	PrintUsage
.ff:	move.l	sp,a0
	moveq	#0,d0
	jsr	LoadSrc
	bmi.s	.errf
	move.l	d0,SrcOrgLen		;ds d0 la longueur du fichier
	move.l	a0,SrcOrgStart
	move.l	a0,SrcCurStart
	move.l	a0,a6			;a6=pointeur sur le source courant
	move.l	sp,a0
	bsr	ModAlloc			;premier mod buffer alloue
	move.l	CurModPtr,a0
	move.l	a6,MOD_addr(a0)
	move.l	SrcOrgLen,MOD_size(a0)
	lea	PATHSZ(sp),sp
	;;;;;;;;;;;;;;;;;;;;;;
.suite:	jsr	InitOutName
	bsr	init_var			;Initialisation des variables de stockage variables
	bmi	FatalError
	move.l	CurModPtr,a0
	move.l	a0,FstModPtr		;addr premier module alloue
	move.l	SrcOrgLen,MOD_size(a0)
	move.l	HeadEditBlock,MOD_headed(a0)
	bsr	CreateIntVars
	bsr	CreateDefVars	;Analyse DefBuf
	jsr	InitPrep
	moveq	#1,d0
	move.l	d0,incnum
	move.l	sp,TopStack
	jsr	UpdVarRamFlg
	bra	RetNor

RetMac:	lea	incnum,a0
	move.l	(a0)+,d0	;incnum
	add.l	d0,(a0)+	;CurLNb
	move.l	a6,(a0)	;CurLPtr
	jsr	ExpandMacLine
	tst.w	PrepSkipCnt
	beq.s	.ligne
	bsr	Condition
	tst.w	LstCnt
	bmi.s	RetMac
	tst.b	LstMacFlg
	beq.s	RetMac
	bsr	DoLst
	bra.s	RetMac
.ligne:	bsr	Ligne
	move.l	d7,incnum
	tst.w	LstCnt
	bpl.s	.dolst
.fwlst:	tst.w	length_variable
	bne.s	.stock
	move.w	d6,d3
	bmi.s	RetMac		;pas d'opcode
	beq.s	.nooper
.leas:	move.l	FieldsPtr,FIELDPTR	;@ debut de l'operande
	lea	maflags,EAPTR	;@ modes d'adressage
.nooper:	pea	RetMac(pc)	;@ de retour en cas d'erreur ou non
	move.l	sp,EaSp
	move.w	REF_opcode(REFPTR),d4	;opcode

	IFNE	_68000
	lea	StartRoutines(pc),a1
	add.w	REF_rout(REFPTR),a1
	jmp	(a1)
	ELSEIF
	move.w	REF_rout(REFPTR),a1
	jmp	(StartRoutines.l,a1)
;	jmp	([REF_rout.w,REFPTR],StartRoutines)
	ENDC	;_68000

.dolst:	tst.b	StopFlg
	bne	FatalError
	tst.b	LstMacFlg
	beq.s	.fwlst
	bsr	DoLst
	bra.s	.fwlst
.stock:	move.w	d6,d3
	bmi.s	.just_stock
	btst	#_FUNC_VAR,REF_flags(REFPTR)
	bne.s	.leas	;pas stocker mais JMPer
;stocker et JMPer a la routine
	bsr	StockVar
	bra.s	.leas

.just_stock:	;pas d'opcode
	bsr	StockVar
	bra	RetMac

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
RetNor:	lea	incnum,a0
	move.l	(a0)+,d0		;incnum
	add.l	d0,(a0)+		;CurLNb
	move.l	a6,(a0)		;CurLPtr
.ligne:	bsr	Ligne
	move.l	d7,incnum
	tst.w	LstCnt
	bpl.s	.dolst
.fwlst:	tst.w	length_variable
	bne.s	.stock
	move.w	d6,d3
	bmi.s	RetNor		;pas d'opcode
	beq.s	.nooper
.leas:	move.l	FieldsPtr,FIELDPTR	;@ debut de l'operande
	lea	maflags,EAPTR	;@ modes d'adressage
.nooper:	pea	RetNor(pc)	;@ de retour en cas d'erreur ou non
	move.l	sp,EaSp
	move.w	REF_opcode(REFPTR),d4	;opcode

	IFNE	_68000
	lea	StartRoutines(pc),a1
	add.w	REF_rout(REFPTR),a1
	jmp	(a1)
	ELSEIF
	move.w	REF_rout(REFPTR),a1
	jmp	(StartRoutines.l,a1)
;	jmp	([REF_rout.w,REFPTR],StartRoutines)
	ENDC	;_68000

.dolst:	tst.b	StopFlg
	bne	FatalError
	bsr	DoLst
	bra.s	.fwlst
.stock:
	move.w	d6,d3
	bmi.s	.just_stock
	btst	#_FUNC_VAR,REF_flags(REFPTR)
	bne.s	.leas	;pas stocker mais JMPer
;stocker et JMPer a la routine
	bsr	StockVar
	bra.s	.leas

.just_stock:	;pas d'opcode
	bsr	StockVar
	bra	RetNor

DoLst:	cmp.w	#-NOLIST_NUM,d2
	beq.s	.end
	move.l	CurLPtr,a0
	jmp	OutLst
.end:	rts

EndAsm:	tst.b	IEnvFlg
	beq.s	.ttp
	move.l	CurEditBlock,d0
	beq.s	.ttp
	move.l	d0,a0
	move.l	TXT_next(a0),d0
	beq.s	.ttp
	move.l	d0,a0
	tst.l	TXT_size(a0)
	bne.s	.eoi
.ttp:	move.l	incnum,d0
	subq.l	#1,d0
	add.l	d0,CurLNb
	move.l	CurLNb,d0
	add.l	d0,TotLNb

	tst.w	SrcType
	beq.s	.nosrc
;	move.w	CurSecType,d0
;	bmi.s	.nosrc
;	cmp.w	#SEC_bss,d0
;	beq.s	.nosrc
;	bsr	LinnAlloc		;last line if TEXT or DATA
	bsr	LinrEnd
.nosrc:	move.l	CurModPtr,a0
	move.l	MOD_father(a0),d0
	beq.s	.rootmod
.eoi:	jsr	End_of_include
	tst.w	MacStuff+MacNestCnt
	beq	RetNor
	bra	RetMac

.rootmod:	jsr	end_locals
	jsr	ExitPreproc

	tst.b	StopFlg
	bne.s	.noflush
	IFNE	TEST_EQU
	bsr	print_equs
	ENDC	;de TEST_EQU

	jsr	FreeLocals

	tst.l	VarNb
	beq.s	.no_var
	bsr	create_vars_table
	move.l	GloTbl,a0
	move.l	VarNb,d0
	lea	Qs_doubly,a1
	bsr	QsortL
	move.l	VarNb,d0
	bsr	create_sizes_table

	IFNE	TEST_VAR
	bsr	print_vars
	ENDC	;de TEST_VAR
	
.no_var:	bsr	create_xref_table
	jsr	BsdCreateOffsets
	jsr	GlobalPatch
	jsr	FreeEval
	jsr	PSymTab
	tst.w	ChckFlg
	bne.s	.noflush
	tst.b	StopFlg
	bne.s	.noflush
	jsr	FlushPrg
.noflush:
	move.l	FieldsPtr,a0		;free fields (32K!)
	bsr	MyMfree

	jsr	FreeStrings
	jsr	FreeLocStrings
	jsr	FreeAllVars
	jsr	FreeMods
	jsr	FreeBinBlocks
	jsr	FreeEXPs
	jsr	FreeSrc
	IFNE	AMIGA
	jsr	FreeSections
	ENDC
	IFNE	BLINDOS
	jsr	TstFree
	ENDC
FatalError:
	jsr	StopTime
	bsr	EndTime
	bsr	PNormal
	bsr	PVerbose
NoPrtEnd:	bsr	MemoryExit
	jmp	DoEnd

;Errram_mem:
;	move	#memram_errno,d0
;	jmp	prepfatal

EndTime:	move.l	TotTime,d0		;nb de 100emes ecoules
	moveq	#0,d1			;converti en centiemes
	swap	d0			;nb de centiemes restant
	move.w	d0,d1
	move.l	d1,CenTime
	swap	d0			;nb de secondes
	move.w	d0,d1
	move.l	d1,SecTime
	rts

PNormal:	tst.b	StopFlg
	beq.s	.nostp
	lea	.stptxt(pc),a0
	jmp	PrtLine
.nostp:	tst.w	VerbFlg
	beq.s	.do
	rts
.do:	lea	-256(sp),sp

	move.l	sp,a0
	move.l	CenTime,-(sp)
	move.l	SecTime,-(sp)
	move.l	TotWarn,-(sp)
	move.l	TotErr,-(sp)
	pea	OutName
	move.l	TotLNb,-(sp)
	lea	.endtxt,a1
	jsr	Sprintf
	lea	24(sp),sp
	move.l	sp,a0
	jsr	PrtLine

	lea	256(sp),sp
	rts
.endtxt:	dc.b	"Assembled %=ld line(s)"
	dc.b	" into %s,"
	dc.b	" %ld error(s),"
	dc.b	" %ld warning(s),"
	ASCINLZ	<" %ld.%02ld sec.">
.stptxt:	ASCINLZ	<"Assembly interrupted">
	even

PVerbose:	tst.b	StopFlg
	bne.s	.out
	tst.w	VerbFlg
	bne.s	.do
.out:	rts
.do:	lea	-256(sp),sp

	move.l	sp,a0
	move.l	TotWarn,-(sp)
	move.l	TotErr,-(sp)
	move.l	CenTime,-(sp)
	move.l	SecTime,-(sp)
	move.l	TotLNb,-(sp)
	pea	OutName
	lea	.endtxt,a1
	jsr	Sprintf
	lea	24(sp),sp
	move.l	sp,a0
	jsr	PrtLine

	move.l	sp,a0
	lea	SecSizes,a1		;sections
	move.l	12(a1),-(sp)
	move.l	8(a1),-(sp)
	move.l	4(a1),-(sp)
	move.l	(a1),-(sp)
	lea	.siztxt(pc),a1
	jsr	Sprintf
	lea	16(sp),sp
	move.l	sp,a0
	jsr	PrtLine

	move.l	sp,a0
	move.l	TotMacNb,-(sp)	;macros
	move.l	TotEquNb,-(sp)	;equs
	move.l	TotLocNb,-(sp)	;locals
	move.l	GloNb,-(sp)	;globals
	lea	.vartxt(pc),a1
	jsr	Sprintf
	lea	16(sp),sp
	move.l	sp,a0
	jsr	PrtLine

	move.l	sp,a0
	move.l	TotExpNb,-(sp)		;exps
	move.l	MemSize,d0
	move.l	MaxMemUsed,d1
	sub.l	d1,d0
	move.l	d0,-(sp)
	move.l	d1,-(sp)
	lea	.inttxt(pc),a1
	jsr	Sprintf
	lea	12(sp),sp
	move.l	sp,a0
	jsr	PrtLine

	IFNE	BLINDOS
	move.l	sp,a0
	move.l	MfreeNb,-(sp)
	move.l	MallocNb,-(sp)
	lea	.alltxt(pc),a1
	jsr	Sprintf
	addq.w	#8,sp
	move.l	sp,a0
	jsr	PrtLine
	ENDC	;BLINDOS

	move.l	OutType,d0
	ble.s	.nolnk
;	cmp.w	#BSD_OBJ,d0
;	bgt.s	.nolnk

	move.l	sp,a0
	move.l	XdefNb,-(sp)
	move.l	XrefNb,-(sp)
	lea	.lnktxt(pc),a1
	jsr	Sprintf
	lea	8(sp),sp
	move.l	sp,a0
	jsr	PrtLine

.nolnk:	tst.l	OptiNb
	beq.s	.noopt

	move.l	sp,a0
	move.l	OptiSz,-(sp)
	move.l	OptiNb,-(sp)
	lea	.opttxt(pc),a1
	jsr	Sprintf
	lea	8(sp),sp
	move.l	sp,a0
	jsr	PrtLine

.noopt:	lea	256(sp),sp
	rts

SEP	equ	' '
.endtxt:	ASCINL	<"Output of %s:">
	ASCINL	<"Line(s)  : % 8ld",SEP,"Time:    : %=ld.%02ld sec">
	ASCINL	<"Error(s) : % 8ld",SEP,"Warn.(s) : % 8ld">
	dc.b	0
.siztxt:	ASCINL	<"Text     : % 8ld",SEP,"Data     : % 8ld">
	ASCINL	<"Bss      : % 8ld",SEP,"Symbols  : % 8ld">
	dc.b	0
.vartxt:	ASCINL	<"Global(s): % 8ld",SEP,"Local(s) : % 8ld">
	ASCINL	<"Equ(s)   : % 8ld",SEP,"Macro(s) : % 8ld">
	dc.b	0
.alltxt:
	IFNE	BLINDOS
	ASCINL	<"Malloc(s): % 8ld",SEP,"Free(s)  : % 8ld">
	ENDC	;BLINDOS
	dc.b	0
.inttxt:	ASCINL	<"Used mem : % 8ld",SEP,"Free mem : % 8ld">
	ASCINL	<"Patch(es): % 8ld">
	dc.b	0
.lnktxt:	ASCINL	<"Xref(s)  : % 8ld",SEP,"Xdef(s)  : % 8ld">
	dc.b	0
.opttxt:	ASCINL	<"Opti(s)  : % 8ld",SEP,"Saved    : % 8ld">
	dc.b	0
	even

	IFNE	TEST_EQU
print_equs:
	move.l	EqusPtr,a4
.nxblock:	move.w	EQUL_nb(a4),d7
	subq.w	#1,d7
	bmi.s	.end_equ
	lea	.txt(pc),a0
	jsr	PrtLine
	move.l	EQUL_block(a4),a3
.next:	move.l	(a3)+,a0
	move.l	EQU_start(a0),a4
	move.w	EQU_len(a0),d3
	subq.w	#1,d3
.aff:	move.b	(a4)+,d0
	bsr	PrtChar
	dbf	d3,.aff
	moveq	#13,d0
	bsr	PrtChar
	moveq	#10,d0
	bsr	PrtChar
	dbf	d7,.next
	move.l	EQUL_next(a4),d0
	move.l	d0,a4
	bne.s	.nxblock
.end_equ:	rts
.txt:	dc.b	"------------------",13,10,0
	ENDC	;TEST_EQU
	IFNE	TEST_VAR
print_vars:
	lea	-256(sp),sp
	move.l	sp,a5
	lea	glob_table,a2
	move.w	#254,d6
.nxlen:	move.l	(a2)+,a3
	move.l	(a2)+,d7
	bmi.s	.l1
.nxvar:	move.l	0(a3,d7.l),a4
	move.w	VAR_len(a4),d3
	move.l	VAR_value(a4),d4
	move.l	VAR_start(a4),a4
	subq.w	#1,d3
.aff:	move.b	(a4)+,d0
	bsr	PrtChar
	dbf	d3,.aff
	move.l	d4,-(sp)
	move.l	a5,a0
	lea	.varfmt(pc),a1
	jsr	Sprintf
	addq.w	#4,sp
	move.l	a5,a0
	jsr	PrtLine
	subq.l	#4,d7
	bpl.s	.nxvar
.l1:	dbf	d6,.nxlen
	lea	256(sp),sp
	rts
.varfmt:	dc.b	" % 8ld",13,10,0
	even
	ENDC	;TEST_VAR
	IFNE	TEST_LOC
print_locs:
	move.l	LocPtr,a3
	move.l	LocNb,d7
	subq.l	#1,d7
.next:	move.l	VAR_start(a3),a4
;	move.l	a4,a0
;	bsr	recherche
	move.w	VAR_len(a3),d3
	subq.w	#1,d3
.aff:	move.b	(a4)+,d0
	bsr	PrtChar
	dbf	d3,.aff
	moveq	#13,d0
	bsr	PrtChar
	moveq	#10,d0
	bsr	PrtChar
	lea	VAR_SIZEOF(a3),a3
	dbf	d7,.next
	rts
	ENDC	;TEST_LOC
;  #] Main:
;  #[ GetCmdLine:
GetCmdLine:
	move.l	a3,-(sp)

	IFNE	ATARI
	move.l	a0,a3
	moveq	#0,d0
	move.b	(a3)+,d0
	ENDC	;ATARI

	IFNE	AMIGA
	movem.l	amiga_cmd_line,d0/a3
	subq.w	#1,d0
	ENDC	;AMIGA

	ble.s	.usage		;nothing
	clr.b	0(a3,d0.w)	;end of cmd line
.l1:	move.b	(a3)+,d0
	beq	.end
	cmp.b	#9,d0		;skip space & tab
	beq.s	.l1
	cmp.b	#' ',d0
	beq.s	.l1
	cmp.b	#'-',d0		;option
	bne.s	.notopt
	move.l	a3,a0
.next:	move.b	(a3)+,d0
	beq.s	.getopt
	cmp.b	#' ',d0
	beq.s	.getopt
	cmp.b	#9,d0
	bne.s	.next
.getopt:	subq.w	#1,a3
	move.b	(a3),-(sp)
	SETEOL	(a3)
	moveq	#0,d0		;in cmd line
	jsr	GetOpt		;get it
	move.b	(sp)+,(a3)
	tst.l	d0
	bpl.s	.l1
	move.w	d0,LstErr
.usage:	bra	PrintUsage
.notopt:	lea	-1(a3),a0
.l2:	move.b	(a3)+,d0
	beq.s	.getname
	cmp.b	#' ',d0
	beq.s	.getname
	cmp.b	#9,d0
	bne.s	.l2
.getname:	lea	SrcOrgName,a1		;nom du premier source
	tst.b	(a1)
	bne.s	.usage
	subq.w	#1,a3
	move.b	(a3),-(sp)
	clr.b	(a3)
	PSTRCPY
	lea	SrcCurName,a1		;nom du source courant
	STRCPY
	move.b	(sp)+,(a3)
	bra	.l1
.end:	tst.b	SrcOrgName
	beq.s	.usage
	move.l	(sp)+,a3
	rts

FstFatal:	lea	FatalTxt,a0
	jsr	PrtLine
	jmp	DoEnd

PrintUsage:
	lea	UsageTxt,a0
	jsr	PrtLine
	jmp	DoEnd

;  #] GetCmdLine:
	include	"line68k.s"
	include	"si.s"
	include	"qsort.s"
	include	"memory.s"
	include	"mm.s"
	include	"ins68k.s"
	include	"tbl68k.s"
	include	"prep.s"

	DATA
;  #[ Miscellaneous strings:
PresTxt:	dc.b	"Assemble 68xxx/CPU32 v"
	dc.b	(VERSION>>12)&$f+'0',(VERSION>>8)&$f+'0','.',(VERSION>>4)&$f+'0',VERSION&$f+'0'
	IFEQ	_68000
	dc.b	" 68020"
	ENDC
	IFNE	BLINDOS
	IFNE	ATARI
	dc.b	" ","p","DEBUG","","q"
	ELSEIF
	dc.b	" DEBUG"
	ENDC	;ATARI
	ENDC	;BLINDOS
	ASCINLZ	<" (c)1993-95 Brainstorm">
UsageTxt:	ASCINL	<"Usage: assemble [-<opt>>,...] <filename>>">
	ASCINL	<"where <opt>> is:">
	ASCINL	<" @<#>>		\@ digits <number>> (default: 3).">
	ASCINL	<" b		Assemble to none (syntax check only).">
	ASCINL	<" c		Labels are case significant (default).">
	IFNE	ATARI
	ASCINL	<" d		Output 8 caracters debug symbols (DRI).">
	ENDC	;ATARI
	IFNE	AMIGA
	ASCINL	<" d		Output debug symbols.">
	ENDC	;AMIGA
	ASCINL	<" d=<exp>>	Define equate.">
	IFNE	ATARI
	ASCINL	<" e		Output equates as symbols (default).">
	ENDC	;ATARI
	ASCINL	<" i<path>>	Include <pathname>>.">
	IFNE	ATARI
	ASCINL	<" l<0|1|2|3>>	Output program | Pure C object | DRI object | BSD object.">
	ENDC	;ATARI
	IFNE	AMIGA
	ASCINL	<" l		Output linkable object.">
	ENDC	;AMIGA
	ASCINL	<" m		Add macro expansion in listing.">
	ASCINL	<" n		Use less memory.">
	ASCINL	<" o[#]		Optimise [number].">
	ASCINL	<" ow[#]		Warn on optimise [number].">
	ASCINL	<" o=<name>>	Set output name to <name>>.">
	ASCINL	<" p=<#>>		Select processor <number>>.">
	IFNE	ATARI
	ASCINL	<" r		Use system allocation.">
	ENDC	;ATARI
	ASCINL	<" s		Add symbol table in listing.">
	ASCINL	<" t<#>>		Tab stop <number>>.">
	ASCINL	<" u		User instructions only.">
	ASCINL	<" v		Verbose output.">
	ASCINL	<" w		Display warnings.">
	IFNE	ATARI
	ASCINL	<" x		Output 22 caracters debug symbols.">
	ENDC	;ATARI
	ASCINLZ	<" y		Output source level debug">
WorkTxt:	ASCINLZ	<"Working on %s">
FatalTxt:	ASCINLZ	<"Fatal memory error. Press any key.">
NoneTxt:	dc.b	"'nothing'",0
;  #] Miscellaneous strings:
	BSS
;  #[ Stack:
TopStack:	ds.l	1
	ds.b	STKSIZE
mystack:	ds.l	1
;  #] Stack:
	END
