
;	OPT	L+
;File load/save, memory alloc/free routines
;Based on some code by T.K. for MED
;Additional code by P.Kent

;Use these XDEFS if linking
;	xdef	_LoadFile
;	xdef	_FreeFile
;	xdef	_InitFile
;	xdef	_SaveFile

;	Function: d0 = _LoadFile(a0)
;	a0 = file name
;	d0 = pointer to loaded file, zero if load failed

_LoadFile:
	movem.l a2-a4/a6/d2-d6,-(sp)
	moveq	#0,d6			;d6 = return value (zero = error)
	move.l  a0,a4			;a4 = file name
	movea.l 4,a6
	lea     dosname(pc),a1
	jsr     -$198(a6)		;OldOpenLibrary()
	tst.l   d0
	beq     xlm1
	move.l  d0,a3			;a3 = DOSBase
	move.l  d0,a6
	move.l  a4,d1			;name = d1
	move.l  #1005,d2		;accessmode = MODE_OLDFILE
	jsr     -$1e(a6)		;Open()
	move.l  d0,d4			;d4 = file handle
	beq     xlm2
	move.l  d4,d1
	moveq   #0,d2
	moveq   #1,d3			;OFFSET_END
	jsr     -$42(a6)		;Seek(fh,0,OFFSET_END)
	move.l  d4,d1
	moveq	#0,d3
	not.l   d3				;OFFSET_BEGINNING
	jsr     -$42(a6)		;Seek(fh,0,OFFSET_BEGINNING)

	move.l  d0,d5			;d5 = file size
	Bsr	_InitFile
	tst.l   d0
	beq.s   xlm3
	move.l  d0,a2			;a2 = pointer to buffer

	move.l  d4,d1			;file
	move.l  d0,d2			;buffer
	move.l  d5,d3			;length
	move.l  a3,a6
	jsr     -$2a(a6)		;Read()
	cmp.l   d5,d0
	beq.s   xlm3b			;nothing wrong...

	move.l  a2,a0			;error: free the memory
	bsr	_FreeFile
	bra.s	xlm3
xlm3b
	move.l	a2,d6
xlm3:
	move.l  a3,a6			;close the file
	move.l  d4,d1
	jsr     -$24(a6)		;Close(fhandle)
xlm2:
	move.l  a3,a1			;close dos.library
	movea.l 4,a6
	jsr     -$19e(a6)
xlm1:
	move.l  d6,d0			;push return value
	movem.l (sp)+,a2-a4/a6/d2-d6	;restore registers
	rts						;and exit...
dosname:	dc.b	'dos.library',0


;	Function: d0 = _SaveFile(a0,a1)
;	a0 = file name
;	a1 = source buffer
;	d0 = 0 ERROR, Non-zero save OK

_SaveFile
	movem.l a2-a6/d2-d6,-(sp)
	moveq	#0,d6			;d6 = return code
	move.l  a0,a4			;a4 = file name
	move.l	a1,a5

	movea.l 4,a6
	lea     dosname(pc),a1
	jsr     -$198(a6)		;OldOpenLibrary()
	tst.l   d0
	beq     xsm1
	move.l  d0,a3			;a3 = DOSBase
	move.l  d0,a6
	move.l  a4,d1			;name = d1
	move.l  #1006,d2		;accessmode = MODE_NEWFILE
	jsr     -$1e(a6)		;Open()
	move.l  d0,d4			;d4 = file handle
	beq     xsm2

	move.l  d4,d1			;file
	move.l  a5,d2			;buffer
	move.l  -4(a5),d3			;length
	move.l	a3,a6
	jsr     -$30(a6)		;Write()

	moveq	#1,d6			;return code... no error
	cmp.l	-4(a5),d0
	beq.s	xsne
	moveq	#0,d6			;error!
xsne

	move.l  a3,a6			;close the file
	move.l  d4,d1
	jsr     -$24(a6)		;Close(fhandle)
xsm2
	move.l  a3,a1			;close dos.library
	movea.l 4,a6
	jsr     -$19e(a6)
xsm1
	move.l  d6,d0			;push return value
	movem.l (sp)+,a2-a6/d2-d6	;restore registers
	rts						;and exit...

;
;	Function: _FreeFile(a0)
;	a0 = pointer to file
_FreeFile:
	move.l  a6,-(sp)
	move.l  a0,d0			;Error! Abort!
	beq.w   xunl
	movea.l 4,a6
	subq.l	#4,a0			;-Lw to get length LW
	move.l  (a0),d0
	beq.s   xunl
	addq.l	#4,d0			;Add LW ptr
	movea.l a0,a1
	jsr     -$d2(a6)		;FreeMem()
xunl:	move.l	(sp)+,a6
	rts

;	Function: _InitFile(d0)
;	d0 = length of file wanted
_InitFile
	movem.l	d1-d7/a0/a6,-(sp)
	tst.l	d0
	beq	xif
	move.l	d0,d7			;save length
	addq.l	#4,d0
	movea.l 4,a6
	move.l  #$10001,d1		;get free public mem
	jsr     -$c6(a6)		;AllocMem()
	tst.l	d0
	beq	xif
	move.l	d0,a0
	move.l	d7,(a0)+
	move.l	a0,d0
xif
	movem.l	(sp)+,d1-d7/a0/a6
	rts
	end

	