	XDEF	find_file	;,save_file2
	XDEF	get_drive,get_path,set_path,open_dta,close_dta,get_wd,find_first,find_next
	XDEF	open_file,create_file,write_file,read_file,seek_file,rel_seek_file,close_file
	XDEF	DoEnd,PrtLine,OutChar,PrtChar,PrtNChar,GetShifts,StrtTime,StopTime
	XDEF	GetIncBin,LoadSrc,LoadBin,IsFPU,GetMPU,LstOpen,LstClose,TestFile,IsAbsFname
	XDEF	FreeEditBlocks

	XREF	OutMsg,NoPrtEnd,MyMalloc,MyMfree
	XREF	TopStack
	XREF	LstCnt,LstName,LstHand,LstPgFlg,LstMttl,LstSttl,LstLnNb,LstPgNb,LstLnLen,LstPgLen
	XREF	IEnvFlg,IEnvPtr,HeadEditBlock,CurEditBlock
	XREF	FstTime,TotTime,LstErr
	XREF	CurLNb,CurModPtr,CurLPtr

	include	"comequ.s"

	section TEXT

TSTIENV	EQU	0
EDIT_BLK_SIZE	EQU	16384
DTA_TYPE	EQU	21
DTA_SIZE	EQU	26
DTA_NAME	EQU	30

;  #[ cd: change directory
_cd:	move.l	a0,a3
	cmpi.b	#':',1(a3)
	bne.s	.nodrive
	move.b	(a3),d0
	cmpi.b	#'A',d0
	blt.s	.rpath
	cmpi.b	#'P',d0
	ble.s	.maj
	cmpi.b	#'a',d0
	blt.s	.rpath
	cmpi.b	#'p',d0
	bgt.s	.rpath
	subi.b	#'a',d0
	bra.s	.set_drv
.maj:	subi.b	#'A',d0
.set_drv:	bsr	set_drive
	bmi.s	.rpath
.nodrive:	move.l	a3,a0
	bsr	set_path
	bmi.s	.rpath
	moveq	#0,d0
	rts
.rpath:	move	#setpath_errno,d0
	bra	filepfatal
;  #] cd:
;  #[ LoadSrc:
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
;a6=nom de fichier
;--- OUT ---
;a0=@ de chargement
;a1=@ nom de fichier
;d0=taille chargee
LoadSrc:	movem.l	d3-d7/a2-a6,-(sp)
	move.l	d0,d7
	move.l	d1,d3
	move.l	a0,a6
	move.l	a1,a4
	lea	MyDta,a3
;	IFEQ	TSTIENV
;	tst.b	IEnvFlg
;	beq.s	.noenv
;	move.l	CurEditBlock,a1
;	move.l	TXT_text(a1),a4
;	move.l	TXT_size(a1),d3
;	bra	.end
;.noenv:
;	ENDC	:TSTIENV
	move.l	a6,a0
	bsr	find_file
	bmi.s	.rfind
.ffound:	tst.l	d7
	bne.s	.sizeset
	move.l	DTA_SIZE(a3),d3
.sizeset:	move.l	a6,a0
	bsr	open_file
	bmi.s	.ropen
	move.l	d0,d4
;	IFNE	TSTIENV
;	tst.b	IEnvFlg
;	beq.s	.ttp
;	bsr	get_edit_file
;	bra.s	.end
;.ttp:
;	ENDC
	move.l	d3,d0
	addq.l	#4,d0
	sf	d1
	jsr	MyMalloc
	beq.s	.rmem
	move.l	d0,a4
	move.l	d7,d0
	beq.s	.read
	move.l	d4,d1
	bsr	seek_file
	bmi.s	.rseek
.read:	move.l	a4,a0
	move.l	d3,d0
	move.l	d4,d1
	bsr	read_file
	cmp.l	d0,d3
	bne.s	.rread
	move.l	d4,d0
	bsr	close_file
	bne.s	.rclose
	lea	0(a4,d3.l),a0
	clr.b	(a0)+
	clr.b	(a0)+
	clr.b	(a0)+
	clr.b	(a0)+
.end:	move.l	d3,d0
	move.l	a6,a1
	move.l	a4,a0
	movem.l	(sp)+,d3-d7/a2-a6
	rts
.rmem:	move	#fileram_errno,d7
	bra.s	.print
.rfind:
.ropen:	move	#open_errno,d7
	bra.s	.print
.rclose:	move	#close_errno,d7
	bra.s	.print
.rread:	move	#read_errno,d7
	bra.s	.close
.rseek:	move	#seek_errno,d7
.close:	move.l	d4,d0
	bsr	close_file
.print:	move.w	d7,d0
	bra	filepfatal

;.incdir:	lea	InclDir,a0
;	tst.b	(a0)
;	beq.s	.erropen
;	lea	SrcNameBuf,a2
;	move.l	a2,a1
;	STRCPY
;	subq.w	#1,a1
;	move.l	a6,a0
;	STRCPY
;	lea	MyDta,a3
;	move.l	a2,a0
;	bsr	find_file
;	bmi.s	.erropen
;	move.l	a2,a6
;	bra	.ffound

	IFNE	TSTIENV
;Input: d4:file handle,d3:size
get_edit_file:
	clr.l	HeadEditBlock
	clr.l	CurEditBlock
	movem.l	d3/a6,-(sp)
.read:	bsr.s	.alloc
	move.l	a0,a2
	move.l	TXT_text(a2),a0
	move.l	d4,d1
	move.l	#EDIT_BLK_SIZE,d0
	bsr	read_file
	tst.l	d0
	beq.s	.end
	cmp.l	#EDIT_BLK_SIZE,d0
	bne.s	.notfull
	bsr	.cut
	move.l	d0,-(sp)
	sub.l	#EDIT_BLK_SIZE,d0
	move.l	d4,d1
	bsr	rel_seek_file
	move.l	(sp)+,d0
.notfull:	move.l	d0,TXT_size(a2)
	move.l	TXT_text(a2),a0
	adda.l	d0,a0
	REPT	4
	clr.b	(a0)+
	ENDR
	bra.s	.read
.end:	move.l	HeadEditBlock,a0
	move.l	a0,CurEditBlock
	move.l	TXT_text(a0),a4
	movem.l	(sp)+,d3/a6
	rts			;attention dernier block de taille 0

.alloc:	move.l	CurEditBlock,d1
	move.l	#TXT_SIZEOF,d0
	jsr	MyMalloc
	beq.s	.errmem
	move.l	d0,a0
	move.l	#EDIT_BLK_SIZE+4,d0
	jsr	MyMalloc
	move.l	d0,TXT_text(a0)
	beq.s	.errmem
	move.l	d1,TXT_prev(a0)
	beq.s	.first
	move.l	d1,a1
	move.l	a0,TXT_next(a1)
.link:	clr.l	TXT_next(a0)
	clr.l	TXT_size(a0)
	move.l	a0,CurEditBlock
	rts
.first:	move.l	a0,HeadEditBlock
	bra.s	.link
.errmem:	move	#fileram_errno,d0
	bra	filepfatal

;d0=taille lue
.cut:	move.l	TXT_text(a2),a0
	lea	0(a0,d0.l),a1
	moveq	#13,d1
	moveq	#10,d2
.l1:	cmp.b	-(a1),d1
	bhs.s	.line
.tst:	cmp.l	a0,a1
	bgt.s	.l1
	IFNE	BLINDOS
	_Debugger
	ENDC
	bra.s	.ok
.line:	cmp.b	(a1),d2
	beq.s	.ok
	cmp.b	(a1),d1
	bne.s	.tst
.ok:	addq.w	#1,a1
	move.l	a1,d0
	sub.l	a0,d0
	rts
	ENDC	;TSTIENV

FreeEditBlocks:
	IFNE	TSTIENV
	move.l	d1,-(sp)
	move.l	HeadEditBlock,d1
	beq.s	.end
.nx:	move.l	d1,a0
	move.l	TXT_next(a0),d1
	jsr	MyMfree
	tst.l	d1
	bne.s	.nx
.end:	move.l	(sp)+,d1
	ENDC
	rts
;  #] LoadSrc:
;  #[ GetIncBin:
;Out: a0=@nom avec chemin eventuel
GetIncBin:
	movem.l	d6-d7/a4-a6,-(sp)
	move.l	a0,a6
	bsr	open_dta
	move.l	a6,a0
	moveq	#$22,d0
	bsr	find_first
	move.l	d0,d6
	bsr	close_dta
	move.l	d6,d0
	bne.s	.rfnf
	move.l	a6,a0
.found:	move.l	MyDta+DTA_SIZE,d0
.end:	movem.l	(sp)+,d6-d7/a4-a6
	rts
.rfnf:	move	#open_errno,d0
	bra	filepfatal
;  #] GetIncBin:
;  #[ LoadBin:
;GERER CLOSE ERROR
;--- IN ---
;a0=ptr sur nom de fichier
;a1=ptr sur @ de chargement (nul ou negatif=pas d'@)
;d0=taille a charger (<0 if none)
;d1=offset par rapport au debut du fichier a charger (0 if none)
;--- INTERNAL ---
;d3=taille
;d4=handle
;d6=@ de chargement
;d7 sert en fin
;a3=new dta
;a4=olddta
;a6=nom de fichier
;--- OUT ---
;a0=@ de chargement
;a1=@ nom de fichier
;d0=taille chargee
LoadBin:	movem.l	d3-d7/a2-a6,-(sp)
	move.l	a0,a6
	move.l	a1,d6
	move.l	d0,d3
	move.l	d1,d5
	lea	MyDta,a3
	move.l	a6,a0
	bsr	find_file
	bmi.s	.rfind
.ffound:	tst.l	d3
	bpl.s	.sizeset
	move.l	DTA_SIZE(a3),d3
.sizeset:	move.l	a6,a0	;lea	DTA_NAME(a3),a6
	bsr	open_file
	bmi.s	.ropen
	move.l	d0,d4
	move.l	d6,a3
	tst.l	d6
	bgt.s	.nores
	move.l	d3,d0
	sf	d1
	jsr	MyMalloc
	beq.s	.rmem
	move.l	d0,a3
.nores:	move.l	d5,d0		;seeker au besoin
	beq.s	.no_seek
	move.l	d4,d1
	bsr	seek_file
	bmi.s	.rseek
.no_seek:	move.l	a3,a0
	move.l	d3,d0
	move.l	d4,d1
	bsr	read_file
	cmp.l	d0,d3
	bne.s	.rread
	move.l	d0,d7
	move.l	d4,d0
	bsr	close_file
.end:	move.l	d7,d0
	move.l	a6,a1
	move.l	a3,a0
	movem.l	(sp)+,d3-d7/a2-a6
	rts
.rmem:	move	#fileram_errno,d7
	bra.s	.print
.rfind:
.ropen:	move	#open_errno,d7
	bra.s	.print
.rclos:	move	#close_errno,d7
	bra.s	.print
.rseek:	move	#seek_errno,d7
	bra.s	.close
.rread:	move	#read_errno,d7
.close:	move.l	d4,d0
	bsr	close_file
.print:	move.l	d7,d0
	bra	filepfatal
;.incdir?:	lea	InclDir,a0
;	tst.b	(a0)
;	beq.s	.erropen
;	lea	SrcNameBuf,a2
;	move.l	a2,a1
;	STRCPY
;	subq.w	#1,a1
;	move.l	a6,a0
;	STRCPY
;	lea	MyDta,a3
;	move.l	a2,a0
;	bsr.s	find_file
;	bmi.s	.erropen
;	move.l	a2,a6
;	bra	.ffound
;  #] LoadBin:
;  #[ Save file:
;--- IN ---
;a0=nom de fichier
;a1=@ d'ou sauver
;d0=taille
;--- INTERNAL ---
;d3=taille
;d7=@ sauvegarde
;a6=nom de fichier
;save_file2:
;	movem.l	d3/d7/a3-a6,-(sp)
;	move.l	d0,d3		;taille
;	move.l	a1,d7		;@ sauvegarde
;	move.l	a0,a6		;@ nom de fichier
;;	move.l	a6,a0
;	bsr	create_file
;	bmi.s	.open_error
;	move.l	d0,d4		;handle
;	move.l	d7,a0
;	move.l	d3,d0
;	move.w	d4,d1
;	bsr	write_file
;;	cmp.l	d0,d3
;	bne.s	.write_error
;	move.l	d0,d7
;.end:	move.w	d4,d0
;	bsr	close_file
;.fin:	move.l	d7,d0
;	movem.l	(sp)+,d3/d7/a3-a6
;	rts
;.memory_error
;	move	#fileram_errno,d7
;	bra.s	.print
;.open_error
;	move	#create_errno,d7
;	bra.s	.print
;.write_error
;	move	#write_errno,d7
;.print:	bra	filepfatal
;  #] Save file:
;  #[ Disk functions:
;	 #[ Find file:
;a0=nom de fichier
TestFile:
find_file:
	movem.l	d6-d7/a3-a4,-(sp)
	move.l	a0,a3

	bsr.s	open_dta
	move.l	a3,a0
	moveq	#$22,d0
	bsr.s	find_first
	move.l	d0,d6
	bsr	close_dta

	tst.w	d6
	bne.s	.end

	move.l	a3,a0
	STRLEN
	beq.s	.error
	lea	0(a3,d0.w),a4
	subq.w	#1,d0
.l1:	move.b	-(a4),d1
	cmp.b	#DIRSEP,d1
	beq.s	.cd
	cmp.b	#':',d1
	beq.s	.cd
	dbf	d0,.l1
	bra.s	.end
.cd:	move.b	1(a4),d7
	clr.b	1(a4)
	move.l	a3,a0
	bsr	_cd
	bmi.s	.end
	move.b	d7,1(a4)
	bra.s	.end
.error:	moveq	#-1,d6
.end:	move.l	d6,d0
	movem.l	(sp)+,d6-d7/a3-a4
	rts
;	 #] Find file:
;	 #[ Disk operation:
get_wd:	pea	_get_drivepath(pc)
	bra.s	disk_operation
get_drive:
	pea	_get_drive(pc)
	bra.s	disk_operation
get_path:
	pea	_get_path(pc)
	bra.s	disk_operation
;set_drive:
;	pea	_set_drive(pc)
;	bra.s	disk_operation
set_path:
	pea	_set_path(pc)
	bra.s	disk_operation
open_dta:
	pea	_open_dta(pc)
	bra.s	disk_operation
find_first:
	pea	_find_first(pc)
	bra.s	disk_operation
find_next:
	pea	_find_next(pc)
	bra.s	disk_operation
open_file:
	pea	_open_file(pc)
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
;	 #[ Get drive:
_get_drive:
	move.w	#$19,-(sp)
	trap	#1
	addq.w	#2,sp
	rts
;	 #] Get drive:
;	 #[ Get drivepath:
;a0=ptr sur buffer devant contenir le path
_get_drivepath:
	move.l	a0,-(sp)
	bsr.s	_get_drive
	move.l	(sp)+,a0
	add.b	#'A',d0
	move.b	d0,(a0)+
	move.b	#':',(a0)+
;	bra	_get_path
;	 #] Get drivepath:
;	 #[ Get path:
;a0=ptr sur buffer devant contenir le path
_get_path:
	move.l	a0,-(sp)
	clr.w	-(sp)
	move.l	a0,-(sp)
	move.w	#$47,-(sp)
	trap	#1
	addq.w	#8,sp
	move.l	(sp)+,a0
	tst.b	(a0)
	bne.s	.end
	move.b	#DIRSEP,(a0)+
	clr.b	(a0)
.end:	;tst.l	d0
	rts
;	 #] Get path:
;	 #[ Set drive:
;d0=nouveau numero de drive
set_drive:
;_set_drive:
	move.w	d0,-(sp)
	move.w	#$e,-(sp)
	trap	#1
	addq.w	#4,sp
	rts
;	 #] Set drive:
;	 #[ Set path:
;a0=ptr sur nouveau path
_set_path:
	move.l	a0,-(sp)
	move.w	#$3b,-(sp)
	trap	#1
	addq.w	#6,sp
	rts
;	 #] Set path:
;	 #[ Open dta:
_open_dta:
	moveq	#0,d0
	tst.l	OldDta
	bne.s	.no_setdta

	move.w	#$2f,-(sp)
	trap	#1
	addq.w	#2,sp
	move.l	d0,OldDta

	pea	MyDta
	move.w	#$1a,-(sp)
	trap	#1
	addq.w	#6,sp
.no_setdta:
	rts
;	 #] Open dta:
;	 #[ Find first:
_find_first:
	move.w	d0,-(sp)
	move.l	a0,-(sp)
	move.w	#$4e,-(sp)
	trap	#1
	addq.w	#8,sp
	rts
;	 #] Find first:
;	 #[ Find next:
_find_next:
	move.w	#$4f,-(sp)
	trap	#1
	addq.w	#2,sp
	rts
;	 #] Find next:
;	 #[ Open file:
;a0=nom de fichier
_open_file:
	clr.w	-(sp)
	move.l	a0,-(sp)
	move.w	#$3d,-(sp)
	trap	#1
	addq.w	#8,sp
	tst.l	d0
	rts
;	 #] Open file:
;	 #[ Create file:
;a0=nom de fichier
_create_file:
;	move.l	a0,-(sp)
	clr.w	-(sp)
	move.l	a0,-(sp)
	move.w	#$3c,-(sp)
	trap	#1
	addq.w	#8,sp
	tst.l	d0
;	move.l	(sp)+,a0
;	tst.l	d0
;	bne.s	.end
;	bsr	find_file
;.end:
	rts
;	 #] Create file:
;	 #[ Write file:
;a0=nom de fichier
;d0=taille
;d1.w=handle
_write_file:
	move.l	d0,-(sp)
	move.l	a0,-(sp)
	move.l	d0,-(sp)
	move.w	d1,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	lea	12(sp),sp
	move.l	(sp)+,d1
	cmp.l	d0,d1
	rts
;	 #] Write file:
;	 #[ Read file:
;a0=ptr
;d0=taille
;d1.w=handle
_read_file:
	move.l	d0,-(sp)
	move.l	a0,-(sp)
	move.l	d0,-(sp)
	move.w	d1,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	lea	12(sp),sp
	move.l	(sp)+,d1
	cmp.l	d0,d1
	rts
;	 #] Read file:
;	 #[ Seek file:
;d0=offset
;d1.w=handle
_seek_file:
	clr.w	-(sp)
	move.w	d1,-(sp)
	move.l	d0,-(sp)
	move.w	#$42,-(sp)
	trap	#1
	lea	10(sp),sp
	tst.l	d0
	rts
;d0=offset
;d1.w=handle
_rel_seek_file:
	move.w	#1,-(sp)
	move.w	d1,-(sp)
	move.l	d0,-(sp)
	move.w	#$42,-(sp)
	trap	#1
	lea	10(sp),sp
	tst.l	d0
	rts
;	 #] Seek file:
;	 #[ Close dta:
_close_dta:
	tst.l	OldDta
	beq.s	.end
	move.l	OldDta,-(sp)
	move.w	#$1a,-(sp)
	trap	#1
	addq.w	#6,sp
	clr.l	OldDta
.end:
	rts
;	 #] Close dta:
;	 #[ Close file:
;handle ds d0
_close_file:
	move.w	d0,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.w	#4,sp
	tst.l	d0
	rts
;	 #] Close file:
;	 #[ IsAbsFname:
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
;	 #] IsAbsFname:
;  #] Disk functions:
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
;  #[ Out functions:
;Input:
;d0	char to print
;Output:
;ccr+d0:	<0:error
;WritePrt:	move.w	d0,-(sp)
;	move.w	#5,-(sp)
;	trap	#1
;	addq.w	#4,sp
;	not.l	d0
;	rts

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

;Input:
;d0.l=strlen
;a0=src @
;a1=dst @
expttl:	move.w	LstLnLen,d1
	sub.w	d0,d1
	lsr.w	#1,d1
	subq.w	#1,d1
	bmi.s	.cpy
	moveq	#' ',d0
.l1:	move.b	d0,(a1)+
	dbf	d1,.l1
.l2:	move.b	(a0)+,(a1)+
	bne.s	.l2
.crlf:	subq.w	#1,a1
	move.b	#13,(a1)+
	move.b	#10,(a1)+
	clr.b	(a1)
	rts
.cpy:	STRCPY
	bra.s	.crlf

;In:a0=string
PrtLine:	tst.w	LstCnt
	bne	.nolst
	tst.l	LstHand
	beq	.nolst

	tst.b	LstPgFlg
	beq.s	.nohead

	movem.l	a0-a2,-(sp)
	lea	-256(sp),sp

	lea	LstLnNb,a0
	move.l	(a0),d0
	move.w	LstPgLen,d1
	divu	d1,d0
	swap	d0
	tst.w	d0
	bne.s	.nopage

	moveq	#$c,d0		;form feed
	bsr	PrtChar

	addq.l	#1,LstPgNb	;pnb++

	lea	LstMttl,a0
	PSTRLEN
	beq.s	.nottl
	move.l	sp,a1
	bsr	expttl
	move.l	sp,a0
	bsr.s	.nohead
.nottl:	lea	LstSttl,a0
	PSTRLEN
	beq.s	.nopage
	move.l	sp,a1
	bsr	expttl
	move.l	sp,a0
	bsr.s	.nohead
.nopage:	addq.l	#1,LstLnNb	;lnb++
	lea	256(sp),sp
	movem.l	(sp)+,a0-a2

.nohead:	PSTRLEN
	move.l	LstHand,d1
	bsr	write_file
	bne.s	.rwrite
	rts

.nolst:	tst.b	IEnvFlg
	beq.s	.noenv
	move.l	IEnvPtr,a1
	move.l	IENV_print(a1),a1
	jsr	(a1)
	tst.w	d0
	bne.s	.ok
	jmp	NoPrtEnd
.ok:	rts
.noenv:	move.l	a2,-(sp)
	move.l	a0,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.w	#6,sp
	move.l	(sp)+,a2
	rts
.rwrite:	bsr	LstClose
	move	#write_errno,d0
	bra	filepfatal
;	move.l	a2,-(sp)
;.l1:	move.b	(a0)+,d0
;	beq.s	.end
;	cmp.b	#10,d0
;	beq.s	.print
;	cmp.b	#13,d0
;	beq.s	.print
;	cmp.b	#9,d0
;	beq.s	.print
;	cmp.b	#31,d0
;	bgt.s	.print
;	move.l	a0,-(sp)
;	bsr	out_char
;	move.l	(sp)+,a0
;	bra.s	.l1
;.print:	move.l	a0,-(sp)
;	bsr	print_char
;	move.l	(sp)+,a0
;	bra.s	.l1
;.end:	move.l	(sp)+,a2
;	rts

OutChar:	move.w	d0,-(sp)
	move.l	#$30005,-(sp)
	trap	#13		;print 'raw'
	addq.w	#6,sp
	rts

PrtChar:	tst.w	LstCnt
	bne.s	.nolst
	move.l	LstHand,d1
	beq.s	.nolst
	move.b	d0,-(sp)
	move.l	sp,a0
	moveq	#1,d0
	bsr	write_file
	addq.w	#2,sp
	bne.s	.rwrite
	rts
.rwrite:	bsr	LstClose
	move	#write_errno,d0
	bra	filepfatal

.nolst:	tst.b	IEnvFlg
	bne.s	.end
	move.w	d0,-(sp)
	move.w	#2,-(sp)
	trap	#1		;print VT52
	addq.w	#4,sp
.end:	rts

PrtNChar:	move.w	d0,-(sp)
	move.l	#$30002,-(sp)
	trap	#13
	addq	#6,sp
	rts
;  #] Out functions:
;  #[ Kbd functions:
GetShifts:
	move.l	#$affff,-(sp)
	trap	#13
	addq.w	#4,sp
	rts
;  #] Kbd functions:
;  #[ Time functions:
StrtTime:	pea	.rout(pc)
	move.w	#$26,-(sp)
	trap	#14
	addq.w	#6,sp
	rts
.rout:	move.l	$4ba.w,d0
.wait	cmp.l	$4ba.w,d0
	beq.s	.wait
	move.l	d0,FstTime
	rts

StopTime:	pea	.rout(pc)
	move.w	#$26,-(sp)
	trap	#14
	addq.w	#6,sp
	sub.l	FstTime,d0
	lsr.l	#1,d0			;200Hz->100Hz
	divu	#100,d0
	move.l	d0,TotTime
	rts
.rout:	move.l	$4ba.w,d0
.wait	cmp.l	$4ba.w,d0
	beq.s	.wait
	rts
;  #] Time functions:
;  #[ IsFPU:
;Out:
;d0.b=-1:no fpu -> bmi error
;d0.b=1:fpu present
IsFPU:	move.b	fpuflg,d0
	bne.s	.ok
	pea	.getfpu(pc)
	move.w	#$26,-(sp)
	trap	#14
	addq.w	#6,sp
	move.b	d0,fpuflg
.ok:	rts
.getfpu:	move.l	$5a0.w,d0
	beq.s	.no
	move.l	d0,a0
.l1:	move.l	(a0)+,d0
	beq.s	.no
	cmp.l	#'_FPU',d0
	beq.s	.chk
	addq.w	#4,a0
	bra.s	.l1
.chk:	move.w	(a0),d0
	lsr.w	#1,d0
	beq.s	.no
	rts
.no:	moveq	#-1,d0
	rts
;  #] IsFPU:
;  #[ GetMPU:
;Out:
;d0.w=MPU #
GetMPU:	pea	.getmpu(pc)
	move.w	#$26,-(sp)
	trap	#14
	addq.w	#6,sp
	rts
.getmpu:	move.l	$5a0.w,d0
	beq.s	.no
	move.l	d0,a0
.l1:	move.l	(a0)+,d0
	beq.s	.no
	cmp.l	#'_CPU',d0
	beq.s	.chk
	addq.w	#4,a0
	bra.s	.l1
.chk:	move.l	(a0),d0
	divu	#10,d0
	rts
.no:	moveq	#0,d0
	rts
;  #] GetMPU:
;  #[ End function:
DoEnd:	move.l	LstHand,d0
	beq.s	.nolst
	bsr	close_file
.nolst:	move.w	LstErr,d0
	tst.b	IEnvFlg
	bne.s	.ienv
	move.w	d0,-(sp)
	move.w	#$4c,-(sp)
	trap	#1
	_Debugger
.ienv:	move.l	TopStack,sp
	rts
;  #] End function:
	BSS
OldDta:		ds.l	1	;Ptr vers ancienne dta
MyDta:		ds.b	44	;dta locale
SrcNameBuf:	ds.b	PATHSZ
filemsg:		ds.b	MSG_SIZEOF
fpuflg:		ds.b	1
	END
