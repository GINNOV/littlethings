
                  org	$60000

debug	set     1
asm_absolute	set     1
asm_protect	set     0
asm_vdo_mode	set     0

	include work:global/preset.s
	include work:agony/disk/load.s

	moveq   #0,d0
	move.b  d0,cra+ciab
	move.b  d0,crb+ciab
	move.b  #$7f,icr+ciab
	tst.b   icr+ciab
	move.b  d0,cra+ciaa
	move.b  d0,crb+ciaa
	move.b  #$7f,icr+ciaa
	tst.b   icr+ciaa

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
	clr.l   Menu_Mode

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



