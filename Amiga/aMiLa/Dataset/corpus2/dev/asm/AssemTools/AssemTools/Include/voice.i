
VOICE	equ	$dff0a0
AUD_LC	equ	$00
AUD_LEN	equ	$04
AUD_PER	equ	$06
AUD_VOL	equ	$08


_VoiceBase dc.l	_vPlay


; Play(voice,frq,vol);


_vPlay	push	a0/d0-d1	;d0=voice, d1=freq, d2=volume
	move.w	d0,-(sp)
	tst.w	d1
	beq	_vPlay1
	lea	VOICE,a0
	asl.w	#4,d0
	lea	0(a0,d0.w),a0
	move.l	waveform(pc),AUD_LC(a0)
	move.w	#WAVEFORM/2,AUD_LEN(a0)
	move.w	d2,AUD_VOL(a0)
	move.w	d1,AUD_PER(a0)
	move.w	(sp)+,d0
	move.w	#$8200,d1
	bset	d0,d1
	move.w	d1,$dff096	;DMA & AUDIO ON
	pull	a0/d0-d1
	rts
_vPlay1	move.w	(sp)+,d0
	moveq	#$0000,d1
	bset	d0,d1
	move.w	d1,$dff096	;DMA & AUDIO OFF
	pull	a0/d0-d1
	rts

_vResetVoices
	move.w	#$020f,$dff096	;DMA & ALL AUDIO OFF
	rts


_LVOPlay equ	0
_LVOResetVoices equ _vResetVoices-_vPlay


