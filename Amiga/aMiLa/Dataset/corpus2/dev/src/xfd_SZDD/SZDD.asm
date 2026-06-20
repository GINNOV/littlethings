; XFD external slave for SZDD files (C) 2000 Stuart Caie <kyzer@4u.net>
; $VER: SZDD.asm 1.3 (29.06.2000)
; v1.1: better xfd name, eliminated 4k buffer
; v1.2: better header text, no code changed
; v1.3: off-by-one error fixed, spaces-vs-nulls error fixed
; v1.4: added LPAK format. This is the same algo as the M$ format, but with
;       less headers and a different window start offset.
;
; Files in the SZDD file format are created with Microsoft's COMPRESS.EXE
; program, and decompressed with Microsoft's EXPAND.EXE program. The file,
; when compressed, usually has an underscore as the last character in its
; filename, ie HELLO.EX_ or VBRUN666.DL_
;
; File header format:
; 4 bytes : "SZDD" (0x53,0x5A,0x44,0x44) - magic ID
; 4 bytes : 0x88,0xF0,0x27,0x33 - more magic ID
; 1 byte  : compression mode - only 'A' (0x41) known
; 1 byte  : the character missing from the end of the filename (0=unknown)
; 4 bytes : A,B,C,D. unpacked size of file is (D<<24)|(C<<16)|(B<<8)|(A)
; n bytes : the compressed data
;
; The compressed data format is basically LZSS
; - one control byte, whose bits dictate the format of the next 8 elements,
;   in the order of LSB to MSB:
;   - if a bit is set, the next element is a single byte literal
;   - otherwise, the next element is a repeat: two bytes, %AAAAAAAA %BBBBCCCC
;     where offset = %BBBBAAAAAAAA and length is %CCCC + 3
; - this repeats until enough data has been unpacked
;
; A 4096 byte wraparound buffer must be kept by the decruncher. A wraparound
; pointer starts at 4096-16 and each outputted byte must be written at that
; position and the pointer advanced by one. The offsets of the compressed
; data refer to an absolute position in this buffer, which may be before the
; current pointer, or after it. The buffer's initial state is that all
; elements are the space character (0x20).
;
; Also, it seems that there can often be superfluous data at the end of a
; file - I can only go by the uncompressed size, so I can only really test
; running out of source data. Some files end in the middle of a run, so I
; can't test if they exactly reach the endpoint and no more.
;
; This code was based on code found in a document describing the Windows Help
; file format, written by M. Winterhoff <100326.2776@compuserve.com>.
;

SZDD_WNDSIZE=4096
SZDD_WNDMASK=4095
SZDD_HDRLEN=14
LPAK_HDRLEN=8
SZDD_OVERRUN=144

	include	exec/memory.i
	include	libraries/xfdmaster.i
	include	lvo/exec_lib.i

	IFD	TEST
	include	xfdExeHead.a
	ENDC

ForeMan	dc.l	$70FF4E75,XFDF_ID	; id
	dc.w	XFDF_VERSION		; foreman version
	dcb.w	5,0			; reserved stuff
	dc.l	SZDDslv			; first slave
SZDDslv	dc.l	LPAKslv
	dc.w	XFDS_VERSION,39
	dc.l	SZDDnam
	dc.w	XFDPFF_DATA!XFDPFF_RECOGLEN!XFDPFF_USERTARGET,0
	dc.l	SZDD_recog,SZDD_decrunch,0,0
	dc.l	0,SZDD_HDRLEN
LPAKslv	dc.l	0
	dc.w	XFDS_VERSION,39
	dc.l	LPAKnam
	dc.w	XFDPFF_DATA!XFDPFF_RECOGLEN!XFDPFF_USERTARGET,0
	dc.l	LPAK_recog,SZDD_decrunch,0,0
	dc.l	0,LPAK_HDRLEN

LPAK_recog
	cmp.l	#"LPAK",(a0)+
	bne.s	_rfail
	move.l	(a0)+,d0
	bra.s	_recog

SZDD_recog
	cmp.l	#"SZDD",(a0)
	bne.s	_rfail
	move.l	10(a0),d0
	rol.w	#8,d0
	swap	d0
	rol.w	#8,d0
_recog	move.l	d0,xfdrr_FinalTargetLen(a1)
	add.l	#SZDD_OVERRUN,d0
	move.l	d0,xfdrr_MinTargetLen(a1)
	moveq	#1,d0			; return success
	rts
_rfail	moveq	#0,d0
	rts

SZDD_decrunch
	movem.l	d2-d7/a2-a6,-(sp)
	move.l	a0,a4				; a4 = BufferInfo

	move.l	xfdbi_SourceBuffer(a4),a0	; a0 = src
	move.l	a0,a2
	adda.l	xfdbi_SourceBufLen(a4),a2	; a2 = ends

	; skip header and set up some stuff 
	cmp.l	#"SZDD",(a0)
	beq.s	.szdd
	addq.l	#LPAK_HDRLEN,a0
	move.w	#SZDD_WNDSIZE-18,d7		; d7 = posn
	bra.s	.cont
.szdd	adda.w	#SZDD_HDRLEN,a0
	move.w	#SZDD_WNDSIZE-16,d7		; d7 = posn
.cont

	move.l	xfdbi_UserTargetBuf(a4),a1	; a1 = dest
	move.l	a1,a3
	adda.l	xfdbi_TargetBufSaveLen(a4),a3	; a3 = endd
	move.l	a1,d3				; d3 = start

	move.w	#SZDD_WNDMASK,d6		; d6 = bufmask

.mainlp	move.b	(a0)+,d5			; d5 = bits
	moveq	#0,d4				; d4 = mask
.bitlp	btst.b	d4,d5
	beq.s	.rep

	; literal
	move.b	(a0)+,(a1)+
	addq.w	#1,d7
	bra.s	.nxtbit

.rep	; repeat
	moveq	#0,d0
	move.b	(a0)+,d0	; d0 = offset
	move.b	(a0)+,d1	; d1 = length

	moveq	#0,d2
	move.b	d1,d2
	asl.w	#4,d2
	move.b	#0,d2
	or.w	d2,d0

	andi.w	#$f,d1
	addq.b	#3,d1

	and.w	d6,d7
	cmp.w	d0,d7
	bhi.s	.noadd		; if (offset <= posn) don't add WNDSIZE
	add.w	#SZDD_WNDSIZE,d7; [or bset #12,d7 - but that's no shorter]
.noadd	lea	(a1,d0.w),a5	; a5 = rep, = dest+offset-posn
	suba.w	d7,a5
	add.w	d1,d7		; posn += length

.clr	cmp.l	a5,d3		; if rep >= base, stop doing clearing
	bls.s	.noclr
	move.b	#' ',(a1)+	; clear one byte
	addq.l	#1,a5
	subq.w	#1,d1		; length--
	beq.s	.nxtbit
	bra.s	.clr

.noclr	move.b	(a5)+,(a1)+	; *dest++=*rep++
	subq.w	#1,d1		; while (length--)
	bne.s	.noclr

.nxtbit	cmp.l	a1,a3		; if dest >= endd, stop now
	bcs.s	.done

	addq.l	#1,d4		; next bit, from 0-7
	cmp.b	#8,d4
	bcs.s	.bitlp		; if d4<8, goto .bitlp

	cmp.l	a0,a2
	bcc.s	.mainlp		; if src < ends, go back to main loop

.corupt	move.w	#XFDERR_CORRUPTEDDATA,xfdbi_Error(a4)
	moveq	#0,d0
 	bra.s	.exit
.done	clr.w	xfdbi_Error(a4)
	moveq	#1,d0
.exit	movem.l	(sp)+,d2-d7/a2-a6
	rts


SZDDnam	dc.b	'(SZDD) Microsoft Data Cruncher',0
LPAKnam	dc.b	'(LPAK) Data Cruncher',0
	dc.b	'$VER: SZDD 1.4 (16.09.2000) by <kyzer@4u.net>',0
