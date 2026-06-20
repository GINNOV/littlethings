; Small Test With Two Windows and Asynchronous File I/O
; (c) 1993 MJSoft System Software
; Martin Mares

	include	"ssmac.h"

	clistart

; I/O Buffers

bufsize	equ	256

	dbuf	buf1r,bufsize
	dbuf	buf2r,bufsize
	dbuf	buf1w,bufsize
	dbuf	buf2w,bufsize

; Open both windows

	dv.l	file1
	dv.l	file2

	dtl	<CON:0/0/640/100/First Window>,a0
	move.l	#MODE_OLDFILE,d0
	call	ss,TrackOpen
	put.l	d0,file1

	dtl	<CON:0/100/640/100/Second Window>,a0
	move.l	#MODE_OLDFILE,d0
	call	TrackOpen
	put.l	d0,file2

; Create packets

	dbuf	message1r,MN_SIZE
	dbuf	packet1r,dp_SIZEOF
	dbuf	message2r,MN_SIZE
	dbuf	packet2r,dp_SIZEOF
	dbuf	message1w,MN_SIZE
	dbuf	packet1w,dp_SIZEOF
	dbuf	message2w,MN_SIZE
	dbuf	packet2w,dp_SIZEOF

	geta	message1r,a2
	moveq	#3,d7
	move.l	4.w,a6
	move.l	ThisTask(a6),a3
	lea	pr_MsgPort(a3),a3
creapack	move.b	#NT_MESSAGE,LN_TYPE(a2)
	move.l	a3,MN_REPLYPORT(a2)
	lea	MN_SIZE(a2),a1
	move.l	a1,LN_NAME(a2)
	move.l	a2,(a1)+
	move.l	a3,(a1)+
	lea	(MN_SIZE+dp_SIZEOF)(a2),a2
	dbra	d7,creapack

; Send both read requests before trying to receive any data

	geta	packet1r,a0
	get.l	file1,d0
	geta	buf1r,a2
	bsr	sendreadreq

	geta	packet2r,a0
	get.l	file2,d0
	geta	buf2r,a2
	bsr	sendreadreq

; Wait for done packets - main loop

	moveq	#-64,d7			; Packet flags
		; Bit 3=Write2 in progress, Bit 2=Write1
		; Bit 1=Read2, Bit 0=Read1
		; Bit 7=Stop#2, 6=Stop#1
mainloop	move.l	4.w,a6
	move.l	ThisTask(a6),a0
	lea	pr_MsgPort(a0),a0
	call	GetMsg
	tst.l	d0
	bne.s	packget
	tst.b	d7
	beq	mainend
	move.l	#SIGF_DOS,d0
	call	Wait
	bra.s	mainloop

packget	geta	message1r,a0
	sub.l	a0,d0
	divu	#(MN_SIZE+dp_SIZEOF),d0
	swap	d0
	tst.w	d0
	bne.s	mainloop
	swap	d0
	cmp.w	#4,d0
	bcc.s	mainloop
	add.w	d0,d0
	move.w	jumptab(pc,d0.w),d0
	jmp	jumptab(pc,d0.w)

jumptab	dc.w	donerp1-jumptab,donerp2-jumptab
	dc.w	donewp1-jumptab,donewp2-jumptab

; Routines executed when various kinds of packets are done

donewp2	bclr	#3,d7
	bclr	#0,d7
	beq.s	mainloop
	bra.s	resend1

donewp1	bclr	#2,d7
	bclr	#1,d7
	beq.s	mainloop
	bra.s	resend2

donerp1	bset	#0,d7
	btst	#3,d7
	bne.s	mainloop
	bclr	#0,d7
resend1	geta	packet1r,a0
	geta	packet2w,a1
	get.l	file2,d0
	geta	buf2w,a2
	get.l	file1,d5
	moveq	#3,d6
	bra.s	resend

donerp2	bset	#1,d7
	btst	#2,d7
	bne	mainloop
	bclr	#1,d7
resend2	moveq	#2,d6
	geta	packet2r,a0
	geta	packet1w,a1
	get.l	file1,d0
	geta	buf1w,a2
	get.l	file2,d5

resend	move.l	dp_Arg2(a0),a3	; 'STOP' ?
	cmp.l	#'STOP',(a3)+
	bne.s	1$
	cmp.b	#10,(a3)
	beq.s	0$
1$	move.l	dp_Res1(a0),d4	; EOF ?
	beq.s	0$
	bmi.s	0$		; ERR ?

	bset	d6,d7
	mpush	a0-a1
	move.l	dp_Arg2(a0),a0	; Copy the text
	move.l	a2,a1
	bra.s	11$
10$	move.b	(a0)+,(a1)+
11$	dbra	d4,10$

	move.l	(sp),a0		; Resend read packet
	push	dp_Res1(a0)
	exg.l	d0,d5
	bsr.s	sendpac1
	mpop	d1/a0-a1
	move.l	d5,d0
	moveq	#ACTION_WRITE,d2
	move.l	a1,a0
	bsr.s	sendpacket
2$	bra	mainloop

0$	addq.b	#4,d6		; Stopped
	bclr	d6,d7
	bra.s	2$

; Send packet read request
; A0=Packet,D0=FileHandle,A2=buffer

sendreadreq	moveq	#ACTION_READ,d2
	move.l	#bufsize,d1

; Send packet request
; A0=Packet,D0=FileHandle,A2=buffer,D1=Size,D2=Action#

sendpacket	move.l	a2,dp_Arg2(a0)
	move.l	d1,dp_Arg3(a0)
	move.l	d2,dp_Type(a0)
sendpac1	move.l	d0,a1
	add.l	a1,a1
	add.l	a1,a1
	move.l	fh_Arg1(a1),dp_Arg1(a0)
	exg.l	a0,a1			; A1=Packet,A0=FH
	move.l	fh_Type(a0),a0		; A0=Port
	lea	-MN_SIZE(a1),a1
	move.l	MN_REPLYPORT(a1),dp_Port+MN_SIZE(a1)
	jump	exec,PutMsg

; Everything done

mainend	jump	ss,ExitCleanup

	tags
	finish
	end
