
*****************************************************************************
;                 Unreal Boot Block
*****************************************************************************

debug	set	0

	include work:global/preset.s

	lea	Custom,a0
	move	#$7fff,d0
	move	d0,Dmacon(a0)
	move	d0,Intena(a0)
	move	d0,Intreq(a0)
	move	d0,Adkcon(a0)
	clr.l	Cop1lc(a0)
	move	d0,Copjmp1(a0)
	lea	sup(pc),a0
	move.l	a0,$20.w				PRIVOLEGE  VIOL
sup
                  lea     $5f0,sp				SET STACK
	move.w	#$2700,sr				KILL INTER

;	MOVE.W	#$7,$DFF180
	lea	nocache(pc),a0
	move.l	a0,$10.w
	dc.w	$4e7a,2
	bclr	#0,d0
	dc.w	$4e7b,2
nocache

;	MOVE.W	#$70,$DFF180
	lea	$80,a0
	lea	decruncher(pc),a1
	lea	decend(pc),a2
loop
	move.l	(a1)+,(a0)+
	cmp.l	a2,a1
	blt	loop
	move.l	#bootend-bbend,d0
	lea	bbend,a1
	lea	$60000,a0
	jsr	$80
;	MOVE.W	#$700,$DFF180
	jmp	$60000
DECRUNCHER
	incbin	work:agony/disk/decrunch.bin
DECEND

BBEND
	incbin	work:agony/disk/boot
BOOTEND












