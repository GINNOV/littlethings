		section	Fast_Unpacker,code_c

*****************************************************************************
* ByteKiller TURBO DataUnpacker v2.1         Regesters smashed: d0-d4/a0-a2
* ----------------------------------         ------------------------------
*
* a0 = Pointer to Packed Data
* a1 = Decrunch address ( location for unpacked data )
* then call "UnPack"
*
* Devpac v2 Compatible Source
*
*****************************************************************************
* Example call	

call_unpacker	lea	Packed_Data(pc),a0
		lea	(LocateAddress).l,a1

*****************************************************************************

UnPack		move.l	(a0)+,d0
		move.l	(a0)+,d1
		addq.l	#1,(a0)+
		move.l	a1,a2
		add.l	d0,a0
		add.l	d1,a2
		move.l	-(a0),d0
keepon:		lsr.l	#1,d0
		bne.s	notempty1
		bsr.s	getnextlwd
notempty1:	bcs.s	bigone
		moveq	#8,d1
		moveq	#1,d3
		lsr.l	#1,d0
		bne.s	notempty2
		bsr.s	getnextlwd
notempty2:	bcs.s	dodupl
		moveq	#3,d1
		moveq	#0,d4
dojump:		bsr.s	rdd1bits
		move	d2,d3
		add	d4,d3
getd3chr:	moveq	#7,d1
get8bits:	lsr.l	#1,d0
		bne.s	notempty3
		bsr.s	getnextlwd
notempty3:	roxl.l	#1,d2
		dbf	d1,get8bits
		move.b	d2,-(a2)
		dbf	d3,getd3chr
nextcmd:	cmp.l	a2,a1		; have we unpacked all bytes ??
		blt.s	keepon		; nope,so keep unpacking !!
		rts			; yep so return

bigjump:	moveq	#8,d1
		moveq	#8,d4	
		bra.s	dojump
bigone:		moveq	#2,d1
		bsr.s	rdd1bits
		cmp.b	#2,d2
		blt.s	midjumps
		cmp.b	#3,d2
		beq.s	bigjump
		moveq	#8,d1
		bsr.s	rdd1bits
		move	d2,d3
		move	#12,d1
		bra.s	dodupl
midjumps:	move	#9,d1
		add	d2,d1
		addq	#2,d2
		move	d2,d3
dodupl:		bsr.s	rdd1bits

copyd3bytes:	subq	#1,a2
		move.b	(a2,d2.w),(a2)
		dbf	d3,copyd3bytes
		bra.s	nextcmd
getnextlwd:	move.l	-(a0),d0
		move	#16,ccr
		roxr.l	#1,d0
		rts

rdd1bits:	subq	#1,d1
		moveq	#0,d2
getbits:	lsr.l	#1,d0
		bne.s	notempty
		move.l	-(a0),d0
		move	#16,ccr
		roxr.l	#1,d0
notempty:	roxl.l	#1,d2
		dbf	d1,getbits
		rts

Packed_Data	incbin	"ram:dec"
LocateAddress	equ	$50000

