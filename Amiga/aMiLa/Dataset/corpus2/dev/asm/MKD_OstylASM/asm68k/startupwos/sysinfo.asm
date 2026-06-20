שתשתÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
	INCDIR	INCLUDES:

	INCLUDE	EXEC/EXECBASE.i
	INCLUDE	EXEC/LIBRARIES.i
	INCLUDE	DOS/DOS.i
	INCLUDE	POWERPC/POWERPC.i
	INCLUDE	POWERPC/TASKSPPC.i

	INCLUDE	MACROS/MACROS.i
	INCLUDE	MACROS/POWERPC.i
	INCLUDE	MISC/DEVPACMACROS.i

	XREF	_PowerPCBase
	XREF	_DosBase

	XDEF	SysInfo
	XDEF	K68HasFPU

SysInfo	;---- 68k type

	Move.L	4.w,a6
	Moveq	#0,d0
	Moveq	#0,d1
	Move	AttnFlags(a6),d0
	St.B	K68HasFPU

	Btst	#7,d0			;test le 68060
	Bne.B	PPType
	Addq.B	#4,d1
	Btst	#AFB_FPU40,d0
	Bne.B	PPType
	Addq.B	#4,d1
	Btst	#AFB_68040,d0
	Bne.B	PPType
	Addq.B	#4,d1
	Sf.B	K68HasFPU

	;---- PowerPC type
	
PPType	Move.L	_PowerPCBase,a6
	Lea	PPCInfo_PPStruct(pc),a0
	Move.L	#PPCInfoTagList,PP_REGS+r4(a0)
	CallPPC	GetInfo
	Move.L	PPCInfoTagList+4(pc),d0
	Moveq	#0,d1
	
	Btst	#CPUB_603,d0
	Bne.B	PPSpeed
	Addq.B	#4,d1
	Btst	#CPUB_603E,d0
	Bne.B	PPSpeed
	Addq.B	#4,d1
	Btst	#CPUB_604,d0
	Bne.B	PPSpeed
	Addq.B	#4,d1
	Btst	#CPUB_604E,d0
	Bne.B	PPSpeed
	Addq.B	#4,d1
	Btst	#CPUB_620,d0
	Bne.B	PPSpeed
	Addq.B	#4,d1

	;---- PowerPC speed
	
PPSpeed	Move.L	PPCInfoTagList+28(pc),d0	
	Divu.L	#1000000,d0
	Move	d0,PPC_CLK

	;---- WarpOS

	Move.L	_PowerPCBase,a6
	Move	LIB_VERSION(a6),PPC_LIBVER
	Move	LIB_REVISION(a6),PPC_LIBVER+2

	Moveq	#0,d0
	Rts	

;------------------------------------------

PrintFmtd
	Move.L	4.w,a6
	Lea	PutChProc(pc),a2
	Lea	TextBuffer(pc),a3
	Move.L	a3,-(sp)
	Jsr	_LVORawDoFmt(a6)
	Rts

PutChProc
	Move.B	d0,(a3)+
	Rts

TextBuffer	Ds.B	80

***********************************************
*
*	Datas sections
*
*
***********************************************

K68HasFPU	Ds.B	1

;---

PPCInfo_PPStruct
	Ds.B	PP_SIZE

PPCInfoTagList
	Dc.L	PPCINFO_CPU,0
	Dc.L	PPCINFO_ICACHE,0
	Dc.L	PPCINFO_DCACHE,0
	Dc.L	PPCINFO_CPUCLOCK,0
	Dc.L	PPCINFO_BUSCLOCK,0
	Dc.L	PPCINFO_SYSTEMLOAD,0
	Dc.L	TAG_DONE,0

;---

K68TYPE_LIST	Dc.L	K68_060,K68_040FPU,K68_040,UNKNOW_CPUTYPE
PPCTYPE_LIST	Dc.L	PPC603,PPC603E,PPC604,PPC604E,PPC620,UNKNOW_CPUTYPE

CACHE_LIST	Dc.L	PPC_CACHE_ON_ULKD,PPC_CACHE_ON_LKD	
		Dc.L	PPC_CACHE_OFF_ULKD,0,PPC_CACHE_OFF_LKD

PPC_MMU		Dc.L	MMUSTAND_TXT,MMUBAT_TXT

PPC_IC_STATUS	Ds.L	1
PPC_DC_STATUS	Ds.L	1

PPC_LIBVER	Ds	2
PPC_CLK		Ds	1

;---

PPC_CACHE_ON_ULKD
	Dc.L	ON_TXT
	Dc.L	ULKD_TXT

PPC_CACHE_ON_LKD
	Dc.L	ON_TXT
	Dc.L	LKD_TXT

PPC_CACHE_OFF_ULKD
	Dc.L	OFF_TXT
	Dc.L	ULKD_TXT

PPC_CACHE_OFF_LKD
	Dc.L	OFF_TXT
	Dc.L	LKD_TXT

;---	
		
K68_040		Dc.B	'68040',0
K68_040FPU	Dc.B	'68040 FPU',0
K68_060		Dc.B	'68060',0

PPC603		Dc.B	'603',0
PPC603E		Dc.B	'603e',0
PPC604		Dc.B	'604',0
PPC604E		Dc.B	'604e',0
PPC620		Dc.B	'620',0

UNKNOW_CPUTYPE	Dc.B	$9b,"1;31;40",$6d,'???',$9b,"0;31;40",$6d,0

ON_TXT		Dc.B	'Enabled',0
OFF_TXT		Dc.B	'Disabled',0
ULKD_TXT	Dc.B	'Unlocked',0
LKD_TXT		Dc.B	'Locked',0

MMUSTAND_TXT	Dc.B	'Standard (slow!)',0
MMUBAT_TXT	Dc.B	'Block Address Translation (BAT registers)',0
