
*****	Title		Decrunch
*****	Function	Demonstrates use of PowerPacker decrunch routine
*****			that was supplied as PD by Nico Francois
*****			
*****	Size		
*****	Author		Mark Meany
*****	Date Started	6 Feb 92
*****	This Revision	
*****	Notes		
*****			




Start		lea	c_file,a0
		move.l	4(a0),d0
	
		lea	DataEnd,a0
		lea	Buffer,a1
		bsr	PPDecrunch

; Use Monam to examine contents of buffer at this point. You should see the
;decrunched text there.

		rts

c_file		incbin	'ucase_pp.i'
DataEnd		dc.b	0
		even
Buffer		ds.b	2300







;
; PowerPacker Decrunch assembler subroutine V1.1
;
; NOTE:
;    Decrunch a few bytes higher (safety margin) than the crunched file
;    to decrunch in the same memory space. (64 bytes suffice)
;

* Entry	a0->End of crunched data + 1
*	a1->Start of decrunch block
*	d0=efficiency file was crunched with.

PPDecrunch
	movem.l d1-d7/a2-a6,-(a7)
	bsr.s Decrunch
	movem.l (a7)+,d1-d7/a2-a6
	rts

Decrunch:
	lea myBitsTable(PC),a5
	move.l d0,(a5)
	move.l a1,a2
	move.l -(a0),d5
	moveq #0,d1
	move.b d5,d1
	lsr.l #8,d5
	add.l d5,a1
	move.l -(a0),d5
	lsr.l d1,d5
	move.b #32,d7
	sub.b d1,d7
LoopCheckCrunch:
	bsr.s ReadBit
	tst.b d1
	bne.s CrunchedBytes
NormalBytes:
	moveq #0,d2
Read2BitsRow:
	moveq #2,d0
	bsr.s ReadD1
	add.w d1,d2
	cmp.w #3,d1
	beq.s Read2BitsRow
ReadNormalByte:
	move.w #8,d0
	bsr.s ReadD1
	move.b d1,-(a1)
	dbf d2,ReadNormalByte
	cmp.l a1,a2
	bcs.s CrunchedBytes
	rts
CrunchedBytes:
	moveq #2,d0
	bsr.s ReadD1
	moveq #0,d0
	move.b (a5,d1.w),d0
	move.l d0,d4
	move.w d1,d2
	addq.w #1,d2
	cmp.w #4,d2
	bne.s ReadOffset
	bsr.s ReadBit
	move.l d4,d0
	tst.b d1
	bne.s LongBlockOffset
	moveq #7,d0
LongBlockOffset:
	bsr.s ReadD1
	move.w d1,d3
Read3BitsRow:
	moveq #3,d0
	bsr.s ReadD1
	add.w d1,d2
	cmp.w #7,d1
	beq.s Read3BitsRow
	bra.s DecrunchBlock
ReadOffset:
	bsr.s ReadD1
	move.w d1,d3
DecrunchBlock:
	move.b (a1,d3.w),d0
	move.b d0,-(a1)
	dbf d2,DecrunchBlock
EndOfLoop:
_pp_DecrunchColor:
	move.w a1,$dff1a2
	cmp.l a1,a2
	bcs.s LoopCheckCrunch
	rts
ReadBit:
	moveq #1,d0
ReadD1:
	moveq #0,d1
	subq.w #1,d0
ReadBits:
	lsr.l #1,d5
	roxl.l #1,d1
	subq.b #1,d7
	bne.s No32Read
	move.b #32,d7
	move.l -(a0),d5
No32Read:
	dbf d0,ReadBits
	rts
myBitsTable:
	dc.b $09,$0a,$0b,$0b

_pp_CalcCheckSum:
	move.l 4(a7),a0
	moveq #0,d0
	moveq #0,d1
sumloop:
	move.b (a0)+,d1
	beq.s exitasm
	ror.w d1,d0
	add.w d1,d0
	bra.s sumloop
_pp_CalcPasskey:
	move.l 4(a7),a0
	moveq #0,d0
	moveq #0,d1
keyloop:
	move.b (a0)+,d1
	beq.s exitasm
	rol.l #1,d0
	add.l d1,d0
	swap d0
	bra.s keyloop
exitasm:
	rts
_pp_Decrypt:
	move.l 4(a7),a0
	move.l 8(a7),d1
	move.l 12(a7),d0
	move.l d2,-(a7)
	addq.l #3,d1
	lsr.l #2,d1
	subq.l #1,d1
encryptloop:
	move.l (a0),d2
	eor.l d0,d2
	move.l d2,(a0)+
	dbf d1,encryptloop
	move.l (a7)+,d2
	rts


