USEMAIN=1
PREDEMO=1
POSTDEMO=1
BUFFERSIZE=400
	section	cados,code
	include cados.asm

	section	main,code
_main	moveq	#-1,d1
	jsr	_FlushKeyboard
	lea	buffer,a0
.again	vsync
	jsr	_ReadKey
	cmp.b	#-1,d0
	beq.s	.again
	cmp.b	#KEY_RETURN,d0
	beq.s	.exit
.nodel	jsr	_TranslateKey
	tst.b	d0
	beq.s	.again
	move.b	d0,(a0)+
.noput	cmp.l	#buffer+BUFFERSIZE-1,a0
	bne.s	.again
.exit	move.b	#0,(a0)
	rts

_PreDemo
	lea	inmsg,a0
	lea	resp,a1
	lea	args,a2
	jmp	_SystemRequest
_PostDemo
	lea	outmsg,a0
	lea	resp,a1
	lea	args,a2
	jmp	_SystemRequest

	section	reqs,data
args	dc.l	buffer
	dc.w	BUFFERSIZE
inmsg	dc.b	'Keyboard routines test',10,10
	dc.b	'Type a few words, then press',10
	dc.b	'RETURN or RMB to quit.',10,10
	dc.b	'[keybuffer at $%lx, %d bytes]',0
outmsg	dc.b	'You typed "%s"',0
resp	dc.b	'OK',0

	section	out,bss
buffer	ds.b	BUFFERSIZE

