	XDEF	MyMalloc,MyMfree,AllocString,AllocLocString
	XDEF	LocStrMemHead

	section TEXT
;  #[ REMs + equates:
;
; Init de la gestion memoire
; Allocation de bloc (taille)
; Exit de la gestion memoire
;
VARS_PER_MBLOCK	equ	200
STRSPACE_SIZE	equ	10000
;  #] REMs + equates:
;  #[ Memory init:
InitMemory:
	IFNE	ATARI
	movem.l	d1-d2/a0-a2,-(sp)
	pea	-1.w
	move.w	#$48,-(sp)
	trap	#1
	tst.l	d0
	addq.w	#6,sp
	movem.l	(sp)+,d1-d2/a0-a2
	ble.s	.error
	move.l	d0,MemSize
	cmp.l	#$10000,d0
	blt.s	.error
	tst.w	SMemFlg
	bne.s	.end
.intmem:	sub.l	#$4000,d0			; -16Ko
	and.l	#$ffff8000,d0		; modulo 32Ko
	move.l	d0,MemSize
	bsr	SysAlloc
	clr.l	MemUsed
	move.l	d0,mem_addr
;	move.l	d0,real_bottom
	move.l	d0,current_bottom
	add.l	MemSize,d0
;	move.l	d0,real_top
	move.l	d0,current_top
.end:	moveq	#0,d0
	rts
.error:	moveq	#-1,d0
	rts
	ENDC	;ATARI
	IFNE	AMIGA
	move.l	a6,-(sp)
	moveq	#0,d1
	move.l	d1,MemUsed
	move.l	4.w,a6
	jsr	AvailMem(a6)
	move.l	d0,MemSize
	move.l	(sp)+,a6
	rts
	ENDC
;  #] Memory init:
;  #[ Memory exit:
MemoryExit:
	IFNE	ATARI
	tst.w	SMemFlg
	beq.s	.intmem
.end:	rts
.intmem:	move.l	mem_addr,d0
	beq.s	.end
	move.l	d0,a0
	bra	SysFree
	ENDC	;ATARI

	IFNE	AMIGA
	movem.l	d3/a6,-(sp)
	move.l	LastMalloc,d3
	beq.s	.end
	move.l	4.w,a6
.nx:	move.l	d3,a0
	move.l	8(a0),d3
	move.l	(a0),d0
	move.l	a0,a1
	addq.l	#1,MfreeNb
	jsr	FreeMem(a6)
	tst.l	d3
	bne.s	.nx
.end:	movem.l	(sp)+,d3/a6
	moveq	#0,d0
	move.l	d0,LastMalloc
	rts
	ENDC	;AMIGA
;  #] Memory exit:
;  #[ MyMalloc:
CHKMEM	MACRO
	move.l	d0,-(sp)
	move.l	MemUsed,d0
	cmp.l	MaxMemUsed,d0
	ble.s	.\@
	move.l	d0,MaxMemUsed
.\@:	move.l	(sp)+,d0
	ENDM

; IN
; d0 = size to allocate/-1 (free memory available)
; OUT
; d0 = address/0/memory available
; NE DOIT GARBAGER QUE d0 !
MyMalloc:	addq.l	#1,MallocNb
	IFNE	AMIGA
	movem.l	d1/d3/a0/a1/a6,-(sp)
	move.l	4.w,a6
	moveq	#0,d1
	add.l	#12,d0
	move.l	d0,d3
	jsr	AllocMem(a6)
	tst.l	d0
	beq.s	.end
	move.l	d0,a0
	add.l	d3,MemUsed
	CHKMEM
	move.l	LastMalloc,d0
	beq.s	.fst
	move.l	d0,a1
	move.l	a0,4(a1)
.fst:	move.l	d3,(a0)+		;size
	clr.l	(a0)+		;next
	move.l	d0,(a0)+		;prev
	move.l	a0,d0
	lea	-12(a0),a0
	move.l	a0,LastMalloc
.end:	movem.l	(sp)+,d1/d3/a0/a1/a6
	rts
	ENDC	;AMIGA

	IFNE	ATARI
	IFEQ	BLINDOS
	tst.w	SMemFlg
	beq.s	.intmem
	bsr	SysAlloc
	CHKMEM
	rts
.intmem:	move.l	d2,-(sp)
	btst	#0,d0
	beq.s	.even
.odd:	addq.l	#1,d0
.even:	move.l	current_bottom,d2
	add.l	d0,d2
	cmp.l	current_top,d2
	bge.s	.error
	add.l	d0,MemUsed
	move.l	d2,current_bottom
	sub.l	d2,d0
	neg.l	d0
	CHKMEM
.end:	movem.l	(sp)+,d2
	rts
.error:	moveq	#0,d0
	bra.s	.end
	ELSEIF	;BLINDOS
	tst.w	SMemFlg
	beq.s	.intmem
	add.l	#10,d0
	bsr	SysAlloc
	beq	.ret
	CHKMEM
	movem.l	d2/a0,-(sp)
	bra.s	.link
.intmem:	movem.l	d2/a0,-(sp)
	btst	#0,d0
	beq.s	.even
.odd:	addq.l	#1,d0
.even:	add.l	#10,d0
	move.l	current_bottom,d2
	add.l	d0,d2
	cmp.l	current_top,d2
	bge.s	.error
	add.l	d0,MemUsed
	move.l	d2,current_bottom
	sub.l	d2,d0
	neg.l	d0
	beq.s	.error
	CHKMEM
.link:	move.l	d0,a0
	move.l	8(sp),(a0)	;return @
	move.l	LastMalloc,4(a0)
	move.w	#'MA',8(a0)		;not freed
	move.l	a0,LastMalloc
	add.l	#10,d0
.end:	movem.l	(sp)+,d2/a0
.ret:	rts
.error:	moveq	#0,d0
	bra.s	.end
	ENDC	;BLINDOS
	ENDC	;ATARI
;  #] MyMalloc:
;  #[ MyMfree:
; IN
; a0
; NE DOIT GARBAGER QUE d0 !
MyMfree:	addq.l	#1,MfreeNb
	IFNE	AMIGA
	movem.l	d0/d1/a0/a1/a6,-(sp)
	lea	-12(a0),a0
	move.l	8(a0),d0		;prev
	beq.s	.noprev
	move.l	d0,a1
	move.l	4(a0),4(a1)	;next
.noprev:	move.l	4(a0),d1
	beq.s	.nonext
	move.l	d1,a1
	move.l	8(a0),8(a1)
	bra.s	.free
.nonext:	move.l	8(a0),LastMalloc
.free:	move.l	(a0),d0
	sub.l	d0,MemUsed
	move.l	a0,a1
	move.l	4.w,a6
	jsr	FreeMem(a6)
	movem.l	(sp)+,d0/d1/a0/a1/a6
	rts
	ENDC	;AMIGA

	IFNE	ATARI
	IFEQ	BLINDOS
	tst.w	SMemFlg
	bne	SysFree
	rts
	ELSEIF
	cmp.w	#'MA',-2(a0)
	bne.s	.twice
	move.w	#'FR',-2(a0)
	tst.w	SMemFlg
	beq.s	.intmem
	move.l	a0,d0
	lea	-10(a0),a0
	bra	SysFree
.intmem:	rts
.twice:	_Debugger
	ENDC	;BLINDOS
	ENDC	;ATARI
;  #] MyMfree:
;  #[ SysAlloc:
SysAlloc:
	IFNE	ATARI
	movem.l	d1-d2/a0-a2,-(sp)
	addq.l	#4,d0
	add.l	d0,MemUsed
	move.l	d0,-(sp)
	move.w	#$48,-(sp)
	trap	#1
	tst.l	d0
	beq.s	.end
	move.l	d0,a0
	move.l	2(sp),(a0)+	;size
	move.l	a0,d0
.end:	addq.w	#6,sp
	movem.l	(sp)+,d1-d2/a0-a2
	ENDC	;ATARI
	rts
;  #] SysAlloc:
;  #[ SysFree:
SysFree:
	IFNE	ATARI
	movem.l	d1-d2/a0-a2,-(sp)
	move.l	-(a0),d1
	sub.l	d1,MemUsed
	move.l	a0,-(sp)
	move.w	#$49,-(sp)
	trap	#1
	addq.w	#6,sp
	movem.l	(sp)+,d1-d2/a0-a2
	IFNE	BLINDOS
	tst.l	d0
	bne.s	.err
	ENDC
	rts
	IFNE	BLINDOS
.err:	_Debugger
	ENDC
	ENDC	;ATARI
;  #] SysFree:
;  #[ Test free:
	IFNE	BLINDOS
TstFree:
	IFNE	AMIGA
	rts
	ENDC
	IFNE	ATARI
	tst.w	SlowFlg
	bne.s	.end
	tst.w	SMemFlg
	bne.s	.end
	move.l	LastMalloc,d1
	beq.s	.end
.nx:	move.l	d1,a0
	cmp.w	#'FR',8(a0)
	bne.s	.err
	move.l	4(a0),d1
	bne.s	.nx
.end:	rts
.err:	_Debugger
	rts
	ENDC	;ATARI
	ENDC	;BLINDOS
;  #] Test free:
;  #[ MStat:
; OUT
; d0 = address/0/memory available
; NE DOIT GARBAGER QUE d0 !
	IFNE	ATARI
MStat:	tst.b	SMemFlg
	beq.s	.intmem
	moveq	#-1,d0
	bra	SysAlloc
.intmem:	move.l	current_top,d0
	sub.l	current_bottom,d0
	rts
	ENDC
;  #] MStat:
;  #[ Variables stuff:
VarAlloc:	move.l	a0,-(sp)
	move.l	MemVarCur,a0
	move.l	MEMBLOCK_cur(a0),d0
	cmp.l	MEMBLOCK_end(a0),d0
	bhs.s	.alloc
.add:	add.l	#VAR_SIZEOF,MEMBLOCK_cur(a0)
.end:	move.l	(sp)+,a0
	tst.l	d0
	rts
.alloc:	move.l	#VAR_SIZEOF*VARS_PER_MBLOCK+MEMBLOCK_SIZEOF,d0
	bsr	MyMalloc
	beq.s	.end
	move.l	d0,MEMBLOCK_next(a0)
	move.l	d0,a0
	add.l	#MEMBLOCK_SIZEOF,d0
	move.l	d0,MEMBLOCK_cur(a0)
	move.l	d0,MEMBLOCK_end(a0)
	add.l	#VAR_SIZEOF*VARS_PER_MBLOCK,MEMBLOCK_end(a0)
	clr.l	MEMBLOCK_next(a0)
	move.l	a0,MemVarCur
	bra.s	.add

FreeVars:	move.l	d2,-(sp)
	move.l	MemVarHead,a0
.nx:	move.l	MEMBLOCK_next(a0),a2
	bsr	MyMfree
	move.l	a2,a0
	move.l	a2,d0
	bne.s	.nx
	move.l	(sp)+,d2
	rts

FstVarAlloc:
	move.l	#VAR_SIZEOF*VARS_PER_MBLOCK+MEMBLOCK_SIZEOF,d0
	bsr	MyMalloc
	beq.s	.end
	move.l	d0,a0
	clr.l	MEMBLOCK_next(a0)
	add.l	#MEMBLOCK_SIZEOF,d0
	move.l	d0,MEMBLOCK_cur(a0)
	add.l	#VAR_SIZEOF*VARS_PER_MBLOCK,d0
	move.l	d0,MEMBLOCK_end(a0)
	move.l	a0,MemVarCur
	move.l	a0,MemVarHead
.end:	rts
;  #] Variables stuff:
;  #[ String Space:
;In d0.W=size
;Out d0.L=@string ou 0 et ccr.z
;garbage rien d'autre
AllocString:
	movem.l	d1/a0/a1,-(sp)
	move.w	d0,d1
	move.l	StrMemCur,d0
	move.l	d0,a0
	beq.s	.alloc
.got:	move.l	MEMBLOCK_cur(a0),d0
	move.l	d0,a1
	add.w	d1,a1
	cmp.l	MEMBLOCK_end(a0),a1
	bhi.s	.alloc
	move.l	a1,MEMBLOCK_cur(a0)	;ccr.z!=0
.end:	movem.l	(sp)+,d1/a0/a1
	rts
.alloc:	move.l	a0,a1
	move.l	#STRSPACE_SIZE+MEMBLOCK_SIZEOF,d0
	bsr	MyMalloc
	move.l	d0,StrMemCur
	beq.s	.end
	move.l	d0,a0
	move.l	a1,d0	;prev
	beq.s	.fst
	move.l	a0,MEMBLOCK_next(a1)	;link
.l1:	lea	MEMBLOCK_SIZEOF(a0),a1
	move.l	a1,MEMBLOCK_cur(a0)
	lea	STRSPACE_SIZE(a1),a1
	move.l	a1,MEMBLOCK_end(a0)
	clr.l	MEMBLOCK_next(a0)
	bra.s	.got
.fst:	move.l	a0,StrMemHead
	bra.s	.l1

FreeStrings:
	movem.l	d0-d1/a0,-(sp)
	move.l	StrMemHead,d1
freestrs:	beq.s	.end
.nx:	move.l	d1,a0
	move.l	MEMBLOCK_next(a0),d1
;	move.l	#STRSPACE_SIZE+MEMBLOCK_SIZEOF,d0
	bsr	MyMfree
	tst.l	d1
	bne.s	.nx
.end:	movem.l	(sp)+,d0-d1/a0
	rts

FreeLocStrings:
	movem.l	d0-d1/a0,-(sp)
	move.l	LocStrMemHead,d1
	bra.s	freestrs

;pareil que AllocString
AllocLocString:
	movem.l	d1/a0/a1,-(sp)
	move.w	d0,d1
	move.l	LocStrMemCur,d0
	move.l	d0,a0
	beq.s	.alloc
.got:	move.l	MEMBLOCK_cur(a0),d0
	move.l	d0,a1
	add.w	d1,a1
	cmp.l	MEMBLOCK_end(a0),a1
	bhi.s	.getnx
	move.l	a1,MEMBLOCK_cur(a0)	;ccr.z!=0
.end:	movem.l	(sp)+,d1/a0/a1
	rts
.getnx:	move.l	MEMBLOCK_next(a0),d0
	beq.s	.alloc
	move.l	d0,a0
	lea	MEMBLOCK_SIZEOF(a0),a1
	move.l	a1,MEMBLOCK_cur(a0)
	bra.s	.got
.alloc:	move.l	a0,a1
	move.l	#STRSPACE_SIZE+MEMBLOCK_SIZEOF,d0
	bsr	MyMalloc
	move.l	d0,LocStrMemCur
	beq.s	.end
	move.l	d0,a0
	move.l	a1,d0	;prev
	beq.s	.fst
	move.l	a0,MEMBLOCK_next(a1)	;link
.l1:	lea	MEMBLOCK_SIZEOF(a0),a1
	move.l	a1,MEMBLOCK_cur(a0)
	lea	STRSPACE_SIZE(a1),a1
	move.l	a1,MEMBLOCK_end(a0)
	clr.l	MEMBLOCK_next(a0)
	bra.s	.got
.fst:	move.l	a0,LocStrMemHead
	bra.s	.l1

;  #] String Space:
;  #[ Bss:
	BSS
mem_addr:		ds.l 1
;real_top:		ds.l 1
;real_bottom:	ds.l 1
current_top:	ds.l 1
current_bottom:	ds.l 1
MallocNb:		ds.l	1
MfreeNb:		ds.l	1
MemVarCur:	ds.l	1
MemVarHead:	ds.l	1
StrMemHead:	ds.l	1
StrMemCur:	ds.l	1
LocStrMemHead:	ds.l	1
LocStrMemCur:	ds.l	1
MemSize:		ds.l 1
MemUsed:		ds.l	1
MaxMemUsed:	ds.l	1
	IFNE	BLINDOS|AMIGA
LastMalloc:	ds.l	1
	ENDC
;  #] Bss:
	section TEXT
