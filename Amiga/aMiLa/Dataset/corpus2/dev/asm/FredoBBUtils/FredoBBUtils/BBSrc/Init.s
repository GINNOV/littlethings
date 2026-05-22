*** Standard 2.0+ bootblock code
Init:
	lea	expansion.name(pc),a1
	moveq	#37,d0
	jsr	-552(a6)	;OpenLibrary()
	tst.l	d0
	beq.b	.err
	move.l	d0,a1
	bset	#6,34(a1)
	jsr	-414(a6)	;CloseLibrary()
.err	lea	dos.name(pc),a1
	jsr	-96(a6)		;FindResident()
	tst.l	d0
	beq.b	.nodos
	move.l	d0,a0
	move.l	22(a0),a0
	moveq	#0,d0
	rts	
.nodos	moveq	#-1,d0
	rts
expansion.name	dc.b	'expansion.library',0
dos.name	dc.b	'dos.library',0
