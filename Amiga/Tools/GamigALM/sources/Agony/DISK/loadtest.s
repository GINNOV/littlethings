
	section	chip,code_f

debug	set     1
asm_absolute	set	0
asm_protect	set	0
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
	move.l	#sup,$20.w
sup
                  lea     $5f0,sp
	move.w	#$2700,sr

	lea	nocache(pc),a0
	move.l	a0,$10.w
	dc.w	$4e7a,2
	bclr	#0,d0
	dc.w	$4e7b,2
nocache
	lea	table,a0
	lea	$200,a1
reloc_t
	move.l	(a0)+,(a1)+
	cmp.l	#table_end,a0
	blt	reloc_t

	lea	dec,a0
	lea	$80,a1
reloc_d
	move.l	(a0)+,(a1)+
	cmp.l	#dec_end,a0
	blt	reloc_d

	move.l	#$c00000,Mem_Config
	clr	Audio_Mode

	LOAD	FILE_0_1,$600

	lea	$600,a0
	move.l	a0,a1
	jsr	$80
	jmp	$600

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
dec
                  incbin	work:agony/disk/decrunch.bin
dec_end



