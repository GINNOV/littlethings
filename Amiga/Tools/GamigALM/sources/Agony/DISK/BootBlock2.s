
*****************************************************************************
;                 Unreal Boot Block
*****************************************************************************

debug	set	0

	include	work:global/preset.s

compute_checksum
	lea	bbstart,a0
	lea	4(a0),a1
	clr.l	(a1)
	move	#$ff,d1
	moveq	#0,d0
cs_loop
	add.l	(a0)+,d0
	bcc	cs_cont
	addq.l	#1,d0
cs_cont
	dbra	d1,cs_loop
	not.l	d0
	move.l	d0,(a1)
	rts


BBSTART
	DC.B	'DOS',0		;DISK ID
	DC.L	0		;CHECKSUM
	DC.L	880		;ROOTBLOCK

;-------------------------------------------------------
;	START OF ROUTINE
;-------------------------------------------------------

	move.l	a1,-(sp)
	moveq   #2,d1
	move.l  #$2c00,d0
	move.l	4.w,a6						EXEC BASE PTR
	jsr	-$c6(a6)
	move.l	d0,d7

	move.l	(sp)+,a1
	move	#$666,$dff180
	move	#$2,$1c(a1)				IO COMMAND
	move.l	d7,$28(a1)		TRACK BUFFER
	move.l	#$2c00/2,$24(a1)				IOLEN
	clr.l	$2c(a1)					OFFSET FROM
	jsr	-456(a6)					PERFORM IO

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

	lea	nocache(pc),a0
	move.l	a0,$10.w
	dc.w	$4e7a,2
	bclr	#0,d0
	dc.w	$4e7b,2
nocache

	lea	$80,a0
	lea	decruncher(pc),a1
	lea	decend(pc),a2
loop
	move.l	(a1)+,(a0)+
	cmp.l	a2,a1
	blt	loop
	move.l	#bootend-bbend,d0
	add.l   #$200,d7
	move.l	d7,a1
	lea	$60000,a0
	jsr	$80
;	MOVE.W	#$700,$DFF180
	jmp	$60000
DECRUNCHER
	incbin	work:agony/disk/decrunch.bin
DECEND
	ifne	(decend-bbstart)>$200
	fail	"no mem"
	ENDC

	ds.b	$200-(decend-bbstart)
BBEND
	incbin	work:agony/disk/boot
BOOTEND



* Serialisation en $ac0
* ---------------------


*	$00	;Serial # 000 ME

*	$a7	;Serial # 001 Psygnosis
*	$0a	;Serial # 002 Psygnosis
*	$37	;Serial # 003 Psygnosis
*	$fe	;Serial # 004 Laurent Larminier

*	NEW VERSION (Marshes debuged)

*	$8a     ;Serial # 005 Psygnosis
*	$ce	;Serial # 006 Psygnosis

*	NEW VERSION (Marshes redebuged & no present)

*	$47     ;Serial # 007 Psygnosis
*	$a3     ;Serial # 008 Psygnosis
*	$c0     ;Serial # 009 Psygnosis

*	NEW VERSION (Work on 3000)

*	$36     ;Serial # 010 Psygnosis
*	$5a     ;Serial # 011 Psygnosis
*	$a9     ;Serial # 012 Psygnosis

*	NEW VERSION (Realy Work on 3000 + Menu Mode)

*	$59     ;Serial # 016 Psygnosis
*	$61     ;Serial # 017 Psygnosis
*	$88     ;Serial # 018 Psygnosis









