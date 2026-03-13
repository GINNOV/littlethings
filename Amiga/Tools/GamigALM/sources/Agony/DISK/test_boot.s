
debug	set     0
asm_absolute	set     0
asm_protect	set     0
asm_vdo_mode	set     0

	include work:global/preset.s
	include work:agony/disk/load.s

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

	lea	table,a0
	lea	$200,a1
reloc_t
	move.l	(a0)+,(a1)+
	cmp.l	#table_end,a0
	blt	reloc_t

	clr.l	Mem_Config
	clr	Audio_Mode
	clr.l	Curent_cl
	clr.l   Score

                  btst	#7,$bfe001	* FIRE TEST
	beq     Start

	LOAD	FILE_0_1,$600
	lea	$600,a1
	move.l	a1,a0
	move.l	a0,-(sp)
	jmp	$80
Start
	moveq	#0,d0
	move.l	d0,Score
	move	#%111,Life
	move.l	d0,Axe_Up_on
	move	d0,Fw_Fire_Weapon
	move.l	d0,Extra_Life
	move.l	d0,Spell_Advailable
	move.l	d0,Spell_Advailable+4
	move.l	d0,Spell_Advailable+8
	move.l	d0,Spell_Advailable+12
	move	d0,Spell_Next_Bonus

	LOAD	FILE_1_2,$61500
	lea	$61500,a1
	move.l	a1,a0
	move.l	a0,-(sp)
	jmp	$80


	LOAD_1
	LOAD_2
	LOAD_3
	LOAD_4
	LOAD_5
	LOAD_6
	LOAD_7
	LOAD_8
	LOAD_9
	LOAD_10
	LOAD_11
	LOAD_12
	LOAD_13
	LOAD_14
	LOAD_15
	LOAD_16

buffer_disk	EQU	$7c000

table
	incbin  work:agony/disk/load_data
table_end

DECRUNCHER
	incbin	work:agony/disk/decrunch.bin
DECEND


