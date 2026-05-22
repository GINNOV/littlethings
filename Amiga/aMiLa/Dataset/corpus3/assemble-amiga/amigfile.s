	include	"comequ.s"
	include	"amig_equ.s"

	XREF	OutMsg,CurModPtr,CurLNb,CurLPtr,MyMalloc
	XREF	IEnvFlg,LstErr,LstWarn,IEnvPtr,FstTime,TotTime
	XREF	NoPrtEnd
	XREF	StopFlg,LstCnt,LstHand

	XDEF	LoadBinary,save_file2,find_file
	XDEF	get_drive,get_path,set_path,open_dta,close_dta,
	XDEF	get_wd,find_first,find_next
	XDEF	open_file,create_file,write_file,read_file,
	XDEF	seek_file,close_file,rel_seek_file
	XDEF	GetIncBin,LoadSrc,WritePrt,PrtLine,PrtChar,StopTime
	XDEF	StrtTime,GetShifts,PrtNChar
	XDEF	Amiga_Inits,Amiga_desinit,DoEnd,IsFPU,GetMPU
	XDEF	amiga_cmd_line,LstOpen,LstClose,TestFile,IsAbsFname
	XDEF	FileError

CALLDOS	MACRO
	move.l	a6,-(sp)
	move.l	dosbase,a6
	jsr	\1(a6)
	move.l	(sp)+,a6
	ENDM

DTA_NAME	EQU	8
DTA_TYPE	EQU	4
DTA_SIZE	EQU	124
PATH_BUFFER_SIZE	EQU	256

;  #[ (Des)Inits:
Amiga_Inits:
	lea	4(sp),a1
	move.l	a1,initial_sp
	movem.l	d0/a0,amiga_cmd_line
	movem.l	d2-d7/a2-a6,-(sp)
	tst.l	d0
	beq.s	.ok
	cmp.b	#' ',-2(a0,d0.l)
	bne.s	.ok
	subq.l	#1,d0
	movem.l	d0/a0,amiga_cmd_line
.ok:	move.l	4.w,a6
	cmp.w	#34,LIB_VERSION(a6)
	sgt	Kick2Flg
	lea	dosname(pc),a1
	moveq	#0,d0
	jsr	OpenLibrary(a6)
	move.l	d0,dosbase
	beq	.error
	move.l	ThisTask(a6),a2
	tst.l	pr_CLI(a2)
	bne.s	.fromcli
	lea	$5c(a2),a0
	jsr	WaitPort(a6)
	lea	$5c(a2),a0
	jsr	GetMsg(a6)
	move.l	d0,WBenchMsg
.fromcli:	move.l	dosbase,a6
	jsr	Output(a6)
	move.l	d0,Stdout
	bne.s	.open
	lea	wname2(pc),a0
	tst.b	Kick2Flg
	bne.s	.do_open
	lea	wname1(pc),a0
.do_open:	move.l	a0,d1
	move.l	#1006,d2
	jsr	Open(a6)
	move.l	d0,Stdout
	move.l	d0,MyStdout
.open:	move.l	4.w,a6
	bsr	Init_VBL
	bne.s	.error
	move.l	#DTA_BUFFER_SIZE,d0
	moveq	#0,d1
	jsr	AllocMem(a6)
	move.l	d0,MyDtaPtr
	beq.s	.error
	bsr	get_intui_win
	move.l	d0,IntuiWindow
	bsr	InitHandler
	moveq	#0,d0
.end:	movem.l	(sp)+,d2-d7/a2-a6
	rts
.error:	moveq	#-1,d0
	bra.s	.end

Amiga_desinit:
	movem.l	d4/a6,-(sp)
	move.l	4.w,a6
	move.l	dosbase,d4
	beq.s	.end
	exg	d4,a6
	move.l	MyStdout,d1
	beq.s	.std
	tst.b	Kick2Flg	;flag CLOSE pour la fenetre
	bne.s	.std
	jsr	Close(a6)
.std:	move.l	a6,a1
	move.l	d4,a6
	jsr	CloseLibrary(a6)
	clr.l	dosbase
	bsr	Desinit_VBL
	move.l	MyDtaPtr,d0
	beq.s	.end
	move.l	d0,a1
	move.l	#DTA_BUFFER_SIZE,d0
	jsr	FreeMem(a6)
	bsr	RemHandler
.end:	movem.l	(sp)+,d4/a6
	rts
;  #] (Des)Inits:
;  #[ Vbl Stuff:
Init_VBL:	move.l	4.w,a6
	lea	Vbl_Server,a1
	moveq	#0,d0
	move.l	d0,14(a1)	; is_data
	move.b	d0,9(a1)	; ln_pri
	move.l	d0,10(a1)	; ln_name
	move.b	#2,8(a1)	; ln_type
	move.l	#my_vbl,18(a1)	; is_code
	moveq	#5,d0
	jsr	AddIntServer(a6)
	moveq	#0,d0
	rts

Desinit_VBL:
	move.l	4.w,a6
	lea	Vbl_Server,a1
	moveq	#5,d0
	jsr	RemIntServer(a6)
	moveq	#0,d0
	rts
my_vbl:	addq.l	#1,FstTime
	moveq	#0,d0
	rts
;  #] Vbl Stuff:
;  #[ LoadSource:
;GERER CLOSE ERROR
;--- IN ---
;a0=ptr sur nom de fichier
;d0=offset
;d1=taille si d0!=0
;--- INTERNAL ---
;d3=taille
;d4=handle
;a3=@ de chargement
;d7 sert en fin
;a3=new dta
;a4=olddta
;a5=nom de fichier
;--- OUT ---
;a0=@ de chargement
;a1=@ nom de fichier
;d0=taille chargee
LoadSrc:	movem.l	d3-d7/a2-a5,-(sp)
	move.l	d0,d7
	move.l	d1,d3
	move.l	a0,a5
	move.l	a1,a4
	move.l	MyDtaPtr,a3
	move.l	a5,a0
	bsr	find_file
	bmi.s	.erropen
.ffound:	tst.l	d7
	bne.s	.sizeset
	move.l	DTA_SIZE(a3),d3
.sizeset:	move.l	a5,a0
	bsr	open_file
	bmi.s	.erropen
	move.l	d0,d4
	move.l	d3,d0
	addq.l	#4,d0
	sf	d1
	jsr	MyMalloc
	beq.s	.errmem
	move.l	d0,a4
	move.l	d7,d0
	beq.s	.read
	move.l	d4,d1
	bsr	seek_file
	bmi.s	.errseek
.read:	move.l	a4,a0
	move.l	d3,d0
	move.l	d4,d1
	bsr	read_file
	cmp.l	d0,d3
	bne.s	.errread
	move.l	d4,d0
	bsr	close_file
	bne.s	.errclos
	lea	0(a4,d3.l),a0
	clr.b	(a0)+
	clr.b	(a0)+
	clr.b	(a0)+
	clr.b	(a0)+
.end:	move.l	d3,d0
	move.l	a5,a1
	move.l	a4,a0
	movem.l	(sp)+,d3-d7/a2-a5
	rts
.errmem:	move.w	#fileram_errno,d7
	bra.s	.print
.erropen:	move.w	#open_errno,d7
	bra.s	.print
.errclos:	move.w	#close_errno,d7
	bra.s	.print
.errread:	move.w	#read_errno,d7
	bra.s	.close
.errseek:	move.w	#seek_errno,d7
.close:	move.w	d4,d0
	bsr	close_file
.print:	move.w	d7,d0
	bra	filepfatal
;  #] LoadSource:
;  #[ GetIncBin:
GetIncBin:
	movem.l	d6-d7/a4-a5,-(sp)
	move.l	a0,a5
	bsr	find_file
	bne.s	.errfnf
.found:	move.l	MyDtaPtr,a0
	move.l	DTA_SIZE(a0),d0
	move.l	a5,a0
.end:	movem.l	(sp)+,d6-d7/a4-a5
	rts
.errfnf:	move.w	#open_errno,d0
	bra	filepfatal
;  #] GetIncBin: 
;  #[ LoadBinary:
;--- IN ---
;a0=ptr sur nom de fichier
;a1=ptr sur @ de chargement (nul ou negatif=pas d'@)
;d0=taille a charger
;d1=offset par rapport au debut du fichier a charger
;--- INTERNAL ---
;d3=taille
;d4=handle
;d6=@ de chargement
;d7 sert en fin
;a3=new dta
;a4=olddta
;a5=nom de fichier
;--- OUT ---
;a0=@ de chargement
;a1=@ nom de fichier
;d0=taille chargee,ou code d'erreur<0
LoadBinary:
	movem.l	d3-d7/a2-a5,-(sp)
	move.l	a0,a5
	move.l	a1,d6
	move.l	d0,d3
	move.l	d1,d5
	move.l	MyDtaPtr,a3
	move.l	a5,a0
	bsr	find_file
	bmi	.erropen
.ffound:	tst.l	d3
	bpl.s	.sizeset
	move.l	DTA_SIZE(a3),d3
.sizeset:	move.l	a5,a0
	bsr	open_file
	bmi.s	.erropen
	move.l	d0,d4
	move.l	d6,a3
	tst.l	d6
	bgt.s	.nores
	move.l	d3,d0
	sf	d1
	jsr	MyMalloc
	beq.s	.errmem
	move.l	d0,a3
.nores:	move.l	d5,d0		;seeker au besoin
	beq.s	.no_seek
	move.l	d4,d1
	bsr	seek_file
	bmi.s	.errseek
.no_seek:	move.l	a3,a0
	move.l	d3,d0
	move.l	d4,d1
	bsr	read_file
	cmp.l	d0,d3
	bne.s	.errread
	move.l	d0,d7
	move.l	d4,d0
	bsr	close_file
	move.l	a5,a1
	move.l	a3,a0
.end:	move.l	d7,d0
	movem.l	(sp)+,d3-d7/a2-a5
	rts
.errmem:	move.w	#fileram_errno,d7
	bra.s	.err
.erropen:	move.w	#open_errno,d7
	bra.s	.err
.errseek:	move.w	#seek_errno,d7
	bra.s	.close
.errread:	move.w	#read_errno,d7
.close:	move.l	d4,d0
	bsr	close_file
.err:	ext.l	d7
	bra.s	.end
;  #] LoadBinary:
;  #[ Save file:
;--- IN ---
;a0=nom de fichier
;a1=@ d'ou sauver
;d0=taille
;--- INTERNAL ---
;d3=taille
;d7=@ sauvegarde
;a5=nom de fichier
save_file2:
	movem.l	d3/d7/a3-a5,-(sp)
	move.l	d0,d3		;taille
	move.l	a1,d7		;@ sauvegarde
	move.l	a0,a5		;@ nom de fichier
	move.l	a5,a0
	bsr	create_file
	bmi.s	.open_error
	move.l	d0,d4		;handle
	move.l	d7,a0
	move.l	d3,d0
	move.w	d4,d1
	bsr	write_file
	cmp.l	d0,d3
	bne.s	.write_error
	move.l	d0,d7
.end:	move.w	d4,d0
	bsr	close_file
	bra.s	.fin
.memory_error
	move.w	#varram_errno,d7
	bra.s	.print
.open_error
	move.w	#create_errno,d7
	bra.s	.print
.write_error
	move.w	#write_errno,d7
.print:	bra	filepfatal
.fin:	move.l	d7,d0
	movem.l	(sp)+,d3/d7/a3-a5
	rts
;  #] Save file:
;	 #[ Find file:
;a0=nom de fichier
TestFile:
find_file:
	movem.l	d1-d3/a0-a1,-(sp)
	move.l	a0,d1
	moveq	#-2,d2
	CALLDOS	Lock
	move.l	d0,d3
	beq.s	.error
	move.l	d3,d1
	move.l	MyDtaPtr,d2
	CALLDOS	Examine
	move.l	d0,-(sp)
	move.l	d3,d1
	CALLDOS	UnLock
	tst.l	(sp)+
	beq.s	.error
.ok:	moveq	#0,d0
.end:	movem.l	(sp)+,d1-d3/a0-a1
	rts
.error:	moveq	#-1,d0
	bra.s	.end
;	 #] Find file:
;  #[ Disk functions:
;	 #[ Disk operation:
get_wd:	pea	_get_drivepath(pc)
	bra.s	disk_operation
get_drive:pea	_get_drive(pc)
	bra.s	disk_operation
get_path:	pea	_get_path(pc)
	bra.s	disk_operation
;set_drive:
;	pea	_set_drive(pc)
;	bra.s	disk_operation
set_path:	pea	_set_path(pc)
	bra.s	disk_operation
open_dta:	pea	_open_dta(pc)
	bra.s	disk_operation
find_first:
	pea	_find_first(pc)
	bra.s	disk_operation
find_next:pea	_find_next(pc)
	bra.s	disk_operation
open_file:pea	_open_file(pc)
	bra.s	disk_operation
create_file:
	pea	_create_file(pc)
	bra.s	disk_operation
write_file:
	pea	_write_file(pc)
	bra.s	disk_operation
read_file:
	pea	_read_file(pc)
	bra.s	disk_operation
seek_file:
	pea	_seek_file(pc)
	bra.s	disk_operation
rel_seek_file:
	pea	_rel_seek_file(pc)
	bra.s	disk_operation
close_dta:
	pea	_close_dta(pc)
	bra.s	disk_operation
close_file:
	pea	_close_file(pc)
;	bra.s	disk_operation
disk_operation:
	move.l	(sp)+,a1
	move.l	a2,-(sp)
	jsr	(a1)
	move.l	(sp)+,a2
	rts
;	 #] Disk operation:
;	 #[ Get drivepath:
;a0=ptr sur buffer devant contenir le path
_get_drivepath:
	movem.l	a2-a5,-(sp)
	; sauver debut de buffer
	move.l	a0,-(sp)
	lea	PATH_BUFFER_SIZE(a0),a3
	clr.b	-(a3)
	move.l	MyDtaPtr,a5
	move.l	#lock_empty_name,d1
	moveq	#-2,d2
	CALLDOS	Lock
	tst.l	d0
	beq	.error
	move.l	d0,a4
.next_level:
	move.l	a4,d1
	move.l	a5,d2
	CALLDOS	Examine
	tst.l	d0
	beq.s	.error_and_unlock
	lea	DTA_NAME(a5),a0
	clr.b	-1(a0)
.l0:	tst.b	(a0)+
	bne.s	.l0
	subq.w	#1,a0
.l1:	move.b	-(a0),-(a3)
	bne.s	.l1	
	move.b	#DIRSEP,(a3)
	move.l	a4,d1
	CALLDOS	ParentDir
	tst.l	d0
	beq.s	.no_more_parent

	move.l	d0,-(sp)
	move.l	a4,d1
	CALLDOS	UnLock
	move.l	(sp)+,a4
	bra.s	.next_level	
.no_more_parent:
	move.l	(sp)+,a0
	addq.w	#1,a3
.l2_0:	move.b	(a3)+,d0
	cmp.b	#DIRSEP,d0
	beq.s	.name_found
	move.b	d0,(a0)+
	bne.s	.l2_0
; juste le nom d'un drive
	move.b	#':',-1(a0)
	clr.b	(a0)
	bra.s	.ok
.name_found:
	move.b	#':',(a0)+
.l2:	move.b	(a3)+,(a0)+
	bne.s	.l2
.ok:	move.l	a4,d1
	CALLDOS	UnLock
	moveq	#0,d0
	bra.s	.end
.error_and_unlock:
	move.l	a4,d1
	CALLDOS	UnLock
.error:	moveq	#-1,d0
	addq.w	#4,sp
.end:	movem.l	(sp)+,a2-a5
	rts
;	 #] Get drivepath:
;	 #[ Set/Get drive & path:
set_drive:
_set_path:
_get_drive:
_get_path:
	rts
;	 #] Set/Get drive & path:
;	 #[ Set drivepath:
;a0=ptr sur nouveau path
_set_drivepath:
_cd:	movem.l	d1/a0,-(sp)
	move.l	a0,d1
	moveq	#-2,d2
	CALLDOS	Lock
	move.l	d0,d1
	beq.s	.no_cd
	move.l	d1,CurLock
	CALLDOS	CurrentDir
	move.l	d0,d1
	beq.s	.no_cd
	CALLDOS	UnLock ; unlocker l'ancien directory
	moveq	#0,d0
.fin:	movem.l	(sp)+,d1/a0
	rts
.no_cd:	move.w	#setpath_errno,d0
	bra	filepfatal
;	 #] Set drivepath:
;	 #[ Find first:
_find_first:
	move.l	a0,d1
	moveq	#-2,d2
	CALLDOS	Lock
	move.l	d0,d1
	beq.s	.error
	move.l	d1,CurLock
	move.l	MyDtaPtr,a0
	move.l	a0,d2
	CALLDOS	Examine
	move.l	d0,-(sp)
	move.l	CurLock,d1
	CALLDOS	UnLock
	move.l	(sp)+,d0 ; code retour de Examine
	beq.s	.error
	moveq	#0,d0
	bra.s	.end
.error:	moveq	#-1,d0
.end:	rts
;	 #] Find first:
;	 #[ Find next:
_find_next:
	move.l	MyDtaPtr,a0
	move.l	a0,d2
	move.l	CurLock,d1
	CALLDOS	ExNext
	rts
;	 #] Find next:
;	 #[ Open/close/create file:
;a0=nom de fichier
_open_file:
	move.l	#1005,d2
	bra.s	__open_file
_create_file:
	move.l	#1006,d2
__open_file:
	move.l	a0,d1
	CALLDOS	Open
	tst.l	d0
	beq.s	.err
	moveq	#1,d1
	rts
.err	moveq	#-1,d0
	rts
_close_file:
	move.l	d0,d1
	CALLDOS	Close
	moveq	#0,d0
	rts
;	 #] Open/close/create file:
;	 #[ Read/Write file:
;a0=ptr
;d0=taille
;d1=handle
_read_file:
	move.l	d3,-(sp)
	move.l	a0,d2
	move.l	d0,d3
	CALLDOS	Read
	move.l	(sp)+,d3
	rts
_write_file:
	move.l	d0,-(sp)
	movem.l	d2/d3,-(sp)
	move.l	a0,d2
	move.l	d0,d3
	CALLDOS	Write
	movem.l	(sp)+,d2/d3
	cmp.l	(sp)+,d0
	rts
;	 #] Read/Write file:
;	 #[ Seek file:
;d0=offset
;d1=handle
_seek_file:
	move.l	d3,-(sp)
	move.l	d0,d2
	moveq	#-1,d3		;OFFSET_BEGINNING
	CALLDOS	Seek		;d0 <- old offset
	move.l	(sp)+,d3
	moveq	#0,d0
	rts
;d0=offset
;d1=handle
_rel_seek_file:
	move.l	d3,-(sp)
	move.l	d0,d2
	moveq	#0,d3		;OFFSET_CURRENT
	CALLDOS	Seek		;d0 <- old offset
	move.l	(sp)+,d3
	moveq	#0,d0
	rts
;	 #] Seek file:
;	 #[ Dta stuff:
_open_dta:
_close_dta:
	rts
;	 #] Dta stuff:
;In: a0=@filename/directory name
IsAbsFname:
	movem.l	d1-d2/a0-a1,-(sp)
	move.l	a0,a1
	moveq	#':',d1
	moveq	#DIRSEP,d2
.l2:	move.b	(a0)+,d0
	beq.s	.no
	cmp.b	d1,d0
	bne.s	.l1
	move.l	a0,d0
	sub.l	a1,d0
	subq.l	#1,d0
	bne.s	.yes
	bra.s	.no
.l1:	cmp.b	d2,d0
	bne.s	.l2
.no:	moveq	#-1,d0
.end:	movem.l	(sp)+,d1-d2/a0-a1
	rts
.yes:	moveq	#0,d0
	bra.s	.end
;  #[ filepfatal:
filepfatal:
	neg.w	d0
	lea	filemsg,a0
	move.w	#MSG_FATL,MSG_flags(a0)
	move.w	d0,MSG_no(a0)
	move.l	CurModPtr,MSG_mod(a0)
	move.l	CurLNb,MSG_lnb(a0)
	move.l	CurLPtr,MSG_ln(a0)
	jmp	OutMsg
;  #] filepfatal:
;  #[ FileError:
FileError:neg.w	d0
	lea	filemsg,a0
	clr.w	MSG_flags(a0)
	move.w	d0,MSG_no(a0)
	move.l	CurModPtr,MSG_mod(a0)
	move.l	CurLNb,MSG_lnb(a0)
	move.l	CurLPtr,MSG_ln(a0)
	jmp	OutMsg
;  #] FileError:

StrtTime:	clr.l	FstTime
	rts

StopTime:	move.l	FstTime,d0
	move.l	4.w,a0
	move.b	VBlankFrequency(a0),d1
	ext.w	d1
	divu	d1,d0
	move.l	d0,TotTime
	rts

;In:a0=string
PrtLine:	tst.b	IEnvFlg
	beq.s	.noenv
	move.l	IEnvPtr,a1
	move.l	IENV_print(a1),a1
	jsr	(a1)
	tst.w	d0
	beq	NoPrtEnd
	rts
.noenv:	movem.l	d2-d3/a6,-(sp)
	PSTRLEN
	move.l	Stdout,d1
	move.l	a0,d2
	move.l	d0,d3
	move.l	dosbase,a6
	jsr	Write(a6)
	movem.l	(sp)+,d2-d3/a6
	rts

PrtNChar:
OutChar:
PrtChar:	movem.l	d2-d3/a6,-(sp)
	move.l	dosbase,a6
	subq.l	#4,sp
	move.l	sp,a0
	move.b	d0,(a0)
	move.l	a0,a2
	moveq	#1,d3
	move.l	Stdout,d1
	jsr	Write(a6)
	addq.l	#4,sp
	movem.l	(sp)+,d2-d3/a6
WritePrt:	rts

LstOpen:	move.l	a0,-(sp)
	lea	LstName,a0
	bsr	create_file
	move.l	(sp)+,a0
	bmi.s	.rcreate
	move.l	d0,LstHand
	rts
.rcreate:	move	#create_errno,d0
	bra	filepfatal

LstClose:	move.l	LstHand,d0
	beq.s	.noclose
	move.l	a0,-(sp)
	bsr	close_file
	move.l	(sp)+,a0
	clr.l	LstHand
.noclose:	rts

DoEnd:	bsr	Amiga_desinit
	move.l	initial_sp,sp
	move.l	4.w,a6
	jsr	Forbid(a6)
	move.l	WBenchMsg,d0
	beq.s	.cli
	move.l	d0,a1
	jsr	ReplyMsg(a6)
.cli:	jsr	Permit(a6)
	move.w	LstErr,d0
	ext.l	d0
	beq.s	.warn?
	moveq	#20,d0
.end:	rts
.warn?:	move.w	LstWarn,d0
	beq.s	.end
	moveq	#5,d0
	rts

get_intui_win:
	movem.l	a2-a6,-(sp)
	lea	-$24(sp),sp	;struct InfoData
	move.l	sp,a0
	move.l	a0,a2
	moveq	#($24>>2)-1,d0
.clr:	clr.l	(a0)+
	dbf	d0,.clr
	move.l	4.w,a6
	move.l	ThisTask(a6),a3
	move.l	a2,d0
	asr.l	#2,d0
	move.l	sp,a0
	lea	-8*4(sp),sp
	move.l	d0,(a0)
	move.l	pr_ConsoleTask(a3),d0
	beq.s	.end
	move.l	d0,a1
	moveq	#ACTION_DISK_INFO,d0
	bsr	SendPacket
	move.l	id_VolumeNode(a2),d0
.end:	lea	8*4+$24(sp),sp
	movem.l	(sp)+,a2-a6
	rts

SendPacket:
	movem.l	a2-a6,-(sp)
	lea	-100(sp),sp
	move.l	a1,a5
	move.l	4.w,a2
	move.l	ThisTask(a2),a4
	lea	tc_UserData(a4),a2
	move.l	sp,a1
	bsr	InitStdPacket
	move.l	sp,a1
	move.l	a5,a0		;***
	move.l	4.w,a6
	jsr	PutMsg(a6)
	move.l	pr_PktWait(a4),d0
	beq.s	.no_rout
	move.l	d0,a0
	jsr	(a0)
	bra.s	.suite
.no_rout:	move.l	a2,a0
	jsr	WaitPort(a6)
	move.l	a2,a0
	jsr	GetMsg(a6)
.suite:	movem.l	$20(a1),d0-d1
	lea	100(sp),sp
	movem.l	(sp)+,a2-a6
	rts

;In: d0,a0,a1,a2
InitStdPacket:
	move.l	a3,-(sp)
	lea	$14(a1),a3
	move.l	a3,$a(a1)
	movem.l	a1-a2,(a3)
	move.l	d0,8(a3)
	lea	$14(a3),a3
	moveq	#6,d1
	move.l	a0,d0
	bne.s	.cp
.clr:	clr.l	(a3)+
	dbf	d1,.clr
	bra.s	.end
.cp:	move.l	(a0)+,(a3)+
	dbf	d1,.cp
.end:	move.l	(sp)+,a3
	rts

InitHandler:
	movem.l	a2-a6,-(sp)
	move.l	4.w,a6
	lea	input_req,a3
	lea	reply_port,a2
	moveq	#-1,d0
	jsr	AllocSignal(a6)
	move.b	d0,MP_SIGBIT(a2)
	move.b	#NT_MSGPORT,ln_type(a2)
	move.b	#PA_SIGNAL,MP_FLAGS(a2)

	suba.l	a1,a1
	jsr	FindTask(a6)
	move.l	d0,MP_SIGTASK(a2)
	move.l	a2,a1
	jsr	AddPort(a6)
	move.l	d0,IO_DEVICE(a3)

	moveq	#0,d0
	move.l	d0,d1
	lea	inputdev_name,a0
	move.l	a3,a1
	jsr	OpenDevice(a6)
	move.l	a2,MN_REPLYPORT(a3)

	lea	input_int,a2
	move.l	#input_handler,IS_CODE(a2)
	clr.l	IS_DATA(a2)
	move.b	#127,ln_pri(a2)
	move.l	a3,a1
	move.l	a2,IO_DATA(a1)
	move.w	#IND_ADDHANDLER,IO_COMMAND(a1)
	jsr	DoIO(a6)
	movem.l	(sp)+,a2-a6
	rts

RemHandler:
	movem.l	a2-a6,-(sp)
	move.l	4.w,a6
	lea	input_int,a2
	lea	input_req,a1
	move.l	a2,IO_DATA(a1)
	move.w	#IND_REMHANDLER,IO_COMMAND(a1)
	jsr	DoIO(a6)
	lea	input_req,a1
	jsr	CloseDevice(a6)
	lea	reply_port,a2
	move.b	MP_SIGBIT(a2),d0
	jsr	FreeSignal(a6)
	move.l	a2,a1
	jsr	RemPort(a6)
	movem.l	(sp)+,a2-a6
	rts

;c=$33
;ctrl enfonce=$63,relache=$e3
input_handler:
	movem.l	a0-a2,-(sp)
	tst.l	IntuiWindow
	beq.s	.end
	lea	ctrl_flg,a1
.event:	cmp.b	#IECLASS_RAWKEY,ie_Class(a0)
	bne.s	.nx
	move.w	ie_Code(a0),d0
	cmp.w	#$63,d0
	bne.s	.l1
	st	(a1)
.l1:	cmp.w	#$e3,d0
	bne.s	.l2
	sf	(a1)
.l2:	cmp.w	#$33,d0
	bne.s	.nx
	tst.b	(a1)
	beq.s	.nx
	move.l	IntuiWindow,a2
	move.l	wd_Flags(a2),d0
	and.w	#$2000,d0		;window active ?
	beq.s	.nx
	st	StopFlg
	move.w	#1,LstCnt
.nx:	move.l	(a0),d0
	bne.s	.event
.end:	movem.l	(sp)+,a0-a2
	move.l	a0,d0
	rts

IsFPU:	move.l	4.w,a0
	btst	#4,AttnFlags+1(a0)	;AFB_68881
	sne	fpuflg
	rts

GetMPU:	move.l	4.w,a0
	move.b	AttnFlags+1(a0),d1
	moveq	#3,d0
.nxt:	btst	d0,d1
	dbne	d0,.nxt
	addq.w	#1,d0
	rts

GetShifts:
	moveq	#0,D0
	rts
lock_empty_name:	dc.w	0
dosname:	dc.b	"dos.library",0
conname:	dc.b	"*",0
inputdev_name:	dc.b	"input.device",0
LstName:	dc.b	"prt:",0
wname1:	dc.b	"CON:0/0/640/200/Assembly output",0
wname2:	dc.b	"CON:0/0/640/200/Assembly output/AUTO/WAIT/CLOSE",0
	even
;  #] Disk functions:
	BSS
amiga_cmd_line:	ds.l	2
WBenchMsg:	ds.l	1
initial_sp:	ds.l	1
IntuiWindow:	ds.l	1
MyDtaPtr:		ds.l	1
CurLock:		ds.l	1
SrcNameBuf:	ds.b	256
dosbase:		ds.l	1
Stdout:		ds.l	1
MyStdout:		ds.l	1
Vbl_Server:	ds.b	IS_SIZE
reply_port:	ds.b	MP_SIZE
input_req:	ds.b	IOSTD_SIZE
input_int:	ds.b	IS_SIZE
filemsg:		ds.b	MSG_SIZEOF
ctrl_flg:		ds.b	1
fpuflg:		ds.b	1
Kick2Flg:		ds.b	1
	even
