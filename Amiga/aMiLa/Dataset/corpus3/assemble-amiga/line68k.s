	section	TEXT
	XDEF	OpSize
TERM_OPCODE	equ	'@'
ADDLNB		equr	d7	;line number to add
;  #[ Skip and test line:
Condition:
	moveq	#1,ADDLNB
	moveq	#13,d4
	lea	opcode,a2
	bra.s	.no_mac
.condition_loop:
	tst.w	MacStuff+MacNestCnt	;patch nase..a voir
	bne.s	.out
.no_mac:	moveq	#0,d0
	moveq	#0,d3
	move.l	a6,a4
.skip_label:
	move.b	(a6)+,d0
	move	d0,d2
	add	d2,d2
	move	.table1(pc,d2),d1	;14
	beq	.init_opcode
	jmp	.table1(pc,d1)		;14(16)
.out:	rts
;  #[ jump table 1:
.table1:
	dc.w	.error-.table1,Err_lt32-.table1,Err_lt32-.table1,Err_lt32-.table1,Err_lt32-.table1,Err_lt32-.table1,Err_lt32-.table1,Err_lt32-.table1
	dc.w	Err_lt32-.table1,0,.lf-.table1,Err_lt32-.table1,Err_lt32-.table1,.cr-.table1,Err_lt32-.table1,Err_lt32-.table1
	dc.w	Err_lt32-.table1,Err_lt32-.table1,Err_lt32-.table1,Err_lt32-.table1,Err_lt32-.table1,Err_lt32-.table1,Err_lt32-.table1,Err_lt32-.table1
	dc.w	Err_lt32-.table1,Err_lt32-.table1,Err_lt32-.table1,Err_lt32-.table1,Err_lt32-.table1,Err_lt32-.table1,Err_lt32-.table1,Err_lt32-.table1
	dc.w	0,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1
	dc.w	.skip_label-.table1,.skip_label-.table1,.semi-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1
	dc.w	.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1
	dc.w	.skip_label-.table1,.skip_label-.table1,.colon-.table1,.semi-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1
	dc.w	.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1
	dc.w	.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1
	dc.w	.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1
	dc.w	.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1
	dc.w	.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1
	dc.w	.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1
	dc.w	.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1
	dc.w	.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1

	dc.w	.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1
	dc.w	.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1
	dc.w	.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1
	dc.w	.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1
	dc.w	.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1
	dc.w	.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1
	dc.w	.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1
	dc.w	.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1
	dc.w	.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1
	dc.w	.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1
	dc.w	.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1
	dc.w	.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1
	dc.w	.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1
	dc.w	.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1
	dc.w	.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1
	dc.w	.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1,.skip_label-.table1
;  #] jump table 1: 
 
.error:
	movem.l	d0-a4,-(sp)
	jsr	End_of_include
	movem.l	(sp)+,d0-a4
	bmi	EndAsm
	addq.l	#1,ADDLNB
	bra	.condition_loop
;.rootmod:
;	bra	Error_lunexp_eosrc

.cr:
	bra	.cr_encountered
.lf:
	bra	.lf_encountered
.semi:
	bra	.NextLine

.colon:
;	move.b	(a6)+,d0
	;;;AMIGA
;	cmp.b	#10,d0
;	beq.s	.retour
	;;;
.init_opcode:
	move.l	a2,a3
	move.b	(a6)+,d0
	cmp.b	#32,d0
	bls.s	.retour_loop
.retour:
	move	d0,d1
	add	d1,d1
	move	.table2(pc,d1),d1
	jmp	.table2(pc,d1)

.retour_loop:
	beq.s	.space_again
	cmp.b	#9,d0
	bne.s	.retour
.space_again
	move.b	(a6)+,d0
	cmp.b	#32,d0
	bls.s	.retour_loop
	move	d0,d1
	add	d1,d1
	move	.table2(pc,d1),d1
	jmp	.table2(pc,d1)

;  #[ table de jmp:
.table2:
	dc.w	.error-.table2,Err_lt32-.table2,Err_lt32-.table2,Err_lt32-.table2,Err_lt32-.table2,Err_lt32-.table2,Err_lt32-.table2,Err_lt32-.table2
	dc.w	Err_lt32-.table2,.NextLine-.table2,.lf_encountered-.table2,Err_lt32-.table2,Err_lt32-.table2,.cr_encountered-.table2,Err_lt32-.table2,Err_lt32-.table2
	dc.w	Err_lt32-.table2,Err_lt32-.table2,Err_lt32-.table2,Err_lt32-.table2,Err_lt32-.table2,Err_lt32-.table2,Err_lt32-.table2,Err_lt32-.table2
	dc.w	Err_lt32-.table2,Err_lt32-.table2,Err_lt32-.table2,Err_lt32-.table2,Err_lt32-.table2,Err_lt32-.table2,Err_lt32-.table2,Err_lt32-.table2
	dc.w	.NextLine-.table2,.opcode-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2
	dc.w	.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.skip_label-.table2,.NextLine-.table2
	dc.w	.opcode-.table2,.opcode-.table2,.opcode-.table2,.opcode-.table2,.opcode-.table2,.opcode-.table2,.opcode-.table2,.opcode-.table2
	dc.w	.opcode-.table2,.opcode-.table2,.colon2-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.opcode-.table2
	dc.w	.NextLine-.table2,.opcode-.table2,.opcode-.table2,.opcode-.table2,.opcode-.table2,.opcode-.table2,.opcode-.table2,.opcode-.table2
	dc.w	.opcode-.table2,.opcode-.table2,.opcode-.table2,.opcode-.table2,.opcode-.table2,.opcode-.table2,.opcode-.table2,.opcode-.table2
	dc.w	.opcode-.table2,.opcode-.table2,.opcode-.table2,.opcode-.table2,.opcode-.table2,.opcode-.table2,.opcode-.table2,.opcode-.table2
	dc.w	.opcode-.table2,.opcode-.table2,.opcode-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.opcode-.table2
	dc.w	.NextLine-.table2,.lopcode-.table2,.lopcode-.table2,.lopcode-.table2,.lopcode-.table2,.lopcode-.table2,.lopcode-.table2,.lopcode-.table2
	dc.w	.lopcode-.table2,.lopcode-.table2,.lopcode-.table2,.lopcode-.table2,.lopcode-.table2,.lopcode-.table2,.lopcode-.table2,.lopcode-.table2
	dc.w	.lopcode-.table2,.lopcode-.table2,.lopcode-.table2,.lopcode-.table2,.lopcode-.table2,.lopcode-.table2,.lopcode-.table2,.lopcode-.table2
	dc.w	.lopcode-.table2,.lopcode-.table2,.lopcode-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2
	dc.w	.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2
	dc.w	.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2
	dc.w	.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2
	dc.w	.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2
	dc.w	.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2
	dc.w	.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2
	dc.w	.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2
	dc.w	.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2
	dc.w	.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2
	dc.w	.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2
	dc.w	.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2
	dc.w	.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2
	dc.w	.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2
	dc.w	.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2
	dc.w	.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2
	dc.w	.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2,.NextLine-.table2
;  #] table de jmp: 

.retour2:
	move	d0,d1
	add	d1,d1
	move	.table_fin(pc,d1),d1
	jmp	.table_fin(pc,d1)

;  #[ table de jmp:
.table_fin:
	dc.w	.test_instruction0-.table_fin,Err_lt32-.table_fin,Err_lt32-.table_fin,Err_lt32-.table_fin,Err_lt32-.table_fin,Err_lt32-.table_fin,Err_lt32-.table_fin,Err_lt32-.table_fin
	dc.w	Err_lt32-.table_fin,.test_instruction0-.table_fin,.lf1-.table_fin,Err_lt32-.table_fin,Err_lt32-.table_fin,.cr1-.table_fin,Err_lt32-.table_fin,Err_lt32-.table_fin
	dc.w	Err_lt32-.table_fin,Err_lt32-.table_fin,Err_lt32-.table_fin,Err_lt32-.table_fin,Err_lt32-.table_fin,Err_lt32-.table_fin,Err_lt32-.table_fin,Err_lt32-.table_fin
	dc.w	Err_lt32-.table_fin,Err_lt32-.table_fin,Err_lt32-.table_fin,Err_lt32-.table_fin,Err_lt32-.table_fin,Err_lt32-.table_fin,Err_lt32-.table_fin,Err_lt32-.table_fin
	dc.w	.test_instruction0-.table_fin,.opcode-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin
	dc.w	.NextLine-.table_fin,.NextLine-.table_fin,.semi2-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin
	dc.w	.opcode-.table_fin,.opcode-.table_fin,.opcode-.table_fin,.opcode-.table_fin,.opcode-.table_fin,.opcode-.table_fin,.opcode-.table_fin,.opcode-.table_fin
	dc.w	.opcode-.table_fin,.opcode-.table_fin,.colon2-.table_fin,.semi2-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.opcode-.table_fin
	dc.w	.NextLine-.table_fin,.opcode-.table_fin,.opcode-.table_fin,.opcode-.table_fin,.opcode-.table_fin,.opcode-.table_fin,.opcode-.table_fin,.opcode-.table_fin
	dc.w	.opcode-.table_fin,.opcode-.table_fin,.opcode-.table_fin,.opcode-.table_fin,.opcode-.table_fin,.opcode-.table_fin,.opcode-.table_fin,.opcode-.table_fin
	dc.w	.opcode-.table_fin,.opcode-.table_fin,.opcode-.table_fin,.opcode-.table_fin,.opcode-.table_fin,.opcode-.table_fin,.opcode-.table_fin,.opcode-.table_fin
	dc.w	.opcode-.table_fin,.opcode-.table_fin,.opcode-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.opcode-.table_fin
	dc.w	.NextLine-.table_fin,.lopcode-.table_fin,.lopcode-.table_fin,.lopcode-.table_fin,.lopcode-.table_fin,.lopcode-.table_fin,.lopcode-.table_fin,.lopcode-.table_fin
	dc.w	.lopcode-.table_fin,.lopcode-.table_fin,.lopcode-.table_fin,.lopcode-.table_fin,.lopcode-.table_fin,.lopcode-.table_fin,.lopcode-.table_fin,.lopcode-.table_fin
	dc.w	.lopcode-.table_fin,.lopcode-.table_fin,.lopcode-.table_fin,.lopcode-.table_fin,.lopcode-.table_fin,.lopcode-.table_fin,.lopcode-.table_fin,.lopcode-.table_fin
	dc.w	.lopcode-.table_fin,.lopcode-.table_fin,.lopcode-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin
	dc.w	.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin
	dc.w	.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin
	dc.w	.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin
	dc.w	.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin
	dc.w	.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin
	dc.w	.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin
	dc.w	.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin
	dc.w	.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin
	dc.w	.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin
	dc.w	.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin
	dc.w	.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin
	dc.w	.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin
	dc.w	.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin
	dc.w	.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin
	dc.w	.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin
	dc.w	.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin,.NextLine-.table_fin
;  #] table de jmp: 


.opcode:
	REPT	10
	move.b	d0,(a3)+
	move.b	(a6)+,d0
	move.b	.grande_table(pc,d0),d3
	bne.s	.opcode_exit
	ENDR
	bra	.NextLine	;attention si une instruction est >10 caracteres
;	bra.s	.opcode
.opcode_exit:
	bmi	.test_instruction0
	bra	.retour2

;  #[ table de test:
.grande_table:
	dc.b	1,1,1,1,1,1,1,1
	dc.b	1,$80,$80,1,1,$80,1,1
	dc.b	1,1,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1
	dc.b	$80,0,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,1,1,1,1,1,0
	dc.b	1,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,1,1,1,1,0
	dc.b	1,1,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
;  #] table de test: 

.lopcode:
	and	#$df,d0
	move.b	d0,(a3)+
	move.b	(a6)+,d0
	move.b	.petite_table(pc,d0),d3
	ble.s	.exitop
.lopcode2:
	REPT	6
	move.b	d3,(a3)+
	move.b	(a6)+,d0
	move.b	.petite_table(pc,d0),d3
	ble.s	.exitop
	ENDR
	bgt.s	.lopcode2
.exitop:
	bmi	.test_instruction0
	bra	.retour2

;  #[ table de test:
.petite_table:
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,$80,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	$80,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,'A','B','C','D','E','F','G'
	dc.b	'H','I','J','K','L','M','N','O'
	dc.b	'P','Q','R','S','T','U','V','W'
	dc.b	'X','Y','Z',0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;  #] table de test: 


.colon2:
	move.b	(a6)+,d0
	bra	.init_opcode


.cr1:
.lf1:
.semi2:
.test_instruction0:
.test_instruction:
	move.l	a3,d2
	sub.l	a2,d2
	tst.w	IfccStuff+IFccNestCnt
	beq.s	.no_ifcc
	tst.b	IfccStuff+IFccCondValue
	beq.s	.search_in_table
.no_ifcc:
	tst.b	MacStuff+InMacFlg
	beq.s	.exit
	cmp.l	#'ENDM',(a2)
	bne.s	.NextLine
	cmp.b	#4,d2
	bne.s	.NextLine
.exit:
	bsr	.gotoend2
	jmp	_endm

.search_in_table:
	moveq	#0,d6
	lea	.preproc_table(pc),a1
	move	(a1)+,d1
	cmp.b	(a1)+,d2
	bhi.s	.NextLine
.search_loop:
	move.l	a2,a0
	move.b	(a1)+,d3
	cmp.b	d3,d2
	bmi.s	.NextLine
	bne.s	.not_this_one
	subq	#1,d3
.compare_loop:
	cmpm.b	(a0)+,(a1)+
	dbne	d3,.compare_loop
	beq.s	.op_found
.not_this_one:
	add.l	d3,a1
	moveq	#0,d3
	addq	#4,d6
	dbf	d1,.search_loop
.NextLine:
	tst.w	MacStuff+MacNestCnt	;MACRO
	bne.s	.exit_anyway
	bsr	.gotoend2
	bmi	.error
	addq.l	#1,ADDLNB
	bra	.condition_loop
.exit_anyway:
	bsr	.gotoend4
	rts
.op_found:
	move.l	.if_table(pc,d6),a0
	jmp	(a0)

.if_table:
	dc.l	.ifplus,.ifplus,.ifplus,.endc,.ifplus,.ifplus,.ifplus,.ifplus
	dc.l	.ifplus,.ifplus,.ifplus,.ifplus,.elseif,.endm,.endc,.elseif
	dc.l	.elsifcc,.elsifcc,.elsifcc,.elsifcc,.elsifcc,.elsifcc,.elsifcc
	dc.l	.elsifcc,.elsifcc,.elsifcc

.preproc_table:
	dc.w	26-1		;nombre d'opcodes a reconnaitre - 1
	dc.b	8		;taille du plus grand
	dc.b	2,'IF'
	dc.b	3,'IFD'
	dc.b	3,'IFC'
	dc.b	4,'ENDC'
	dc.b	4,'IFEQ'
	dc.b	4,'IFNE'
	dc.b	4,'IFGT'
	dc.b	4,'IFGE'
	dc.b	4,'IFLT'
	dc.b	4,'IFLE'
	dc.b	4,'IFND'
	dc.b	4,'IFNC'
	dc.b	4,'ELSE'
	dc.b	4,'ENDM'
	dc.b	5,'ENDIF'
	dc.b	6,'ELSEIF'
	dc.b	8,'ELSEIFNE'
	dc.b	8,'ELSEIFEQ'
	dc.b	7,'ELSEIFD'
	dc.b	8,'ELSEIFND'
	dc.b	8,'ELSEIFGE'
	dc.b	8,'ELSEIFGT'
	dc.b	8,'ELSEIFLE'
	dc.b	8,'ELSEIFLT'
	dc.b	7,'ELSEIFC'
	dc.b	8,'ELSEIFNC'
	even

.endm:	tst.w	MacStuff+MacNestCnt	;MACRO
	beq	.NextLine
	bsr	.gotoend2
	jmp	_endm

.elseif:	tst.w	EndcCnt
	bne	.NextLine
	bsr	.gotoend2
	jmp	_elsif

.endc:	tst.w	EndcCnt
	beq.s	.endc0
	subq.w	#1,EndcCnt
	bra	.NextLine
.endc0:	bsr	.gotoend2
	jmp	_endc

.ifplus:	addq.w	#1,EndcCnt
	bra	.NextLine

.elsifcc:	move.l	a4,a6
	jmp	cond_elsifcc

.cr_encountered:
	bsr.s	.cr_skip
	bmi	.error
	addq.l	#1,ADDLNB
	bra	.condition_loop
.lf_encountered:
	bsr	.lf_skip
	bmi	.error
	addq.l	#1,ADDLNB
	bra	.condition_loop

.cr_loop:
	addq	#1,a6
	addq	#1,ADDLNB				;on saute une ligne: d7++
.cr_skip:
	cmp.b	#10,(a6)+
	bne.s	.other_case
	move.b	(a6),d0
	move.b	.cr_terminator_table(pc,d0),d1	;0 => caractere non saute
	bne.s	.skip_line0
	rts
.other_case:
	move.b	-(a6),d0
	move.b	.cr_terminator_table(pc,d0),d1	;0 => caractere non saute
	bne.s	.skip_line0
	rts
.skip_line0:			;a6 pointe sur l'octet qui pose probleme

; cas le plus courant: un nouveau Cr
	bmi.s	.cr_loop			;ff => cr

; cas moins courant: une ligne entierement en commentaire 1 => * et ; 
	subq.b	#1,d1
	bne.s	.Null				;2 => 0 (ou lf imprevu)
	addq.l	#1,ADDLNB				;on saute une ligne: d7++
.gotoend:
	move.b	(a6)+,d0
.gotoend2:
	cmp	d0,d4
	bcc.s	.exitend
.endloop:
	REPT	11
	cmp.b	(a6)+,d4
	bcc.s	.exitend
	ENDR
	bra.s	.endloop
.exitend:
	beq.s	.cr_skip
	move.b	-1(a6),d0
	move.b	.cr_terminator_table(pc,d0),d1
	beq.s	.gotoend
	bmi	.lf_skip
	moveq	#0,d0
	rts
.Null:
	moveq	#-1,d0
	rts

.gotoend3:
	move.b	(a6)+,d0
.gotoend4:
	cmp.b	d0,d4
	bcs.s	.end4_loop
	rts
.end4_loop:
	cmp.b	(a6)+,d4
	bcs.s	.end4_loop
	move.b	-1(a6),d0
	move.b	.cr_terminator_table(pc,d0),d1
	beq.s	.end4_loop			;rien de special, on saute
	rts

;  #[ table de test:
.cr_terminator_table:
	dc.b	2,0,0,0,0,0,0,0,0,0,254,0,0,255,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;  #] table de test: 

.lf_loop:
	addq	#1,a6
	addq	#1,ADDLNB				;on saute une ligne: d7++
.lf_skip:
	move.b	(a6),d0
	move.b	.terminator_table(pc,d0),d1	;0 => caractere non saute
	bne.s	.skip_line1
	rts
.skip_line1:			;a6 pointe sur l'octet qui pose probleme

; cas le plus courant: un nouveau Lf
	bmi.s	.lf_loop				;ff => Lf

; cas moins courant: une ligne entierement en commentaire 1 => * et ; 
	subq.b	#1,d1
	bne	.Null				;2 => 0 (ou lf imprevu)
	addq	#1,ADDLNB				;on saute une ligne: d7++
	bra	.gotoend

;  #[ table de test:
.terminator_table:
	dc.b	2,0,0,0,0,0,0,0,0,0,255,0,0,255,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;  #] table de test: 
;  #] Skip and test line: 
;  #[ Analyse line:

;	 #[ inits:
Ligne:
CHAMPS		equr	d6
BRACKETPARENT	equr	d4	;()
QUOTER		equr	d3	;bit 16 de d3 = 0 => ' sinon " 

	moveq	#0,d0
	moveq	#1,ADDLNB
	moveq	#-1,CHAMPS

;	 #] inits: 

;	 #[ variable:
;
; 1er caractere traite a part pour gagner du temps:
;

	move.b	(a6)+,d0
	move	d0,d2
	add	d2,d2
	move	tabfirst(pc,d2),d1	;14
	beq	no_variable
	jmp	tabfirst(pc,d1)		;14(16)

label_error:
	bra	Err_illlabel

;  #[ jump table 1:
tabfirst:
	dc.w	.null-tabfirst,Err_lt32-tabfirst,Err_lt32-tabfirst,Err_lt32-tabfirst,Err_lt32-tabfirst,Err_lt32-tabfirst,Err_lt32-tabfirst,Err_lt32-tabfirst
	dc.w	Err_lt32-tabfirst,0,lf_encountered-tabfirst,Err_lt32-tabfirst,Err_lt32-tabfirst,cr_encountered-tabfirst,Err_lt32-tabfirst,Err_lt32-tabfirst
	dc.w	Err_lt32-tabfirst,Err_lt32-tabfirst,Err_lt32-tabfirst,Err_lt32-tabfirst,Err_lt32-tabfirst,Err_lt32-tabfirst,Err_lt32-tabfirst,Err_lt32-tabfirst
	dc.w	Err_lt32-tabfirst,Err_lt32-tabfirst,Err_lt32-tabfirst,Err_lt32-tabfirst,Err_lt32-tabfirst,Err_lt32-tabfirst,Err_lt32-tabfirst,Err_lt32-tabfirst
	dc.w	0,label0-tabfirst,label_error-tabfirst,label_error-tabfirst,label_error-tabfirst,label_error-tabfirst,label_error-tabfirst,label_error-tabfirst
	dc.w	label_error-tabfirst,label_error-tabfirst,gotoend-tabfirst,label_error-tabfirst,label_error-tabfirst,label_error-tabfirst,point_var-tabfirst,label_error-tabfirst
	dc.w	metacomco-tabfirst,metacomco-tabfirst,metacomco-tabfirst,metacomco-tabfirst,metacomco-tabfirst,metacomco-tabfirst,metacomco-tabfirst,metacomco-tabfirst
	dc.w	metacomco-tabfirst,metacomco-tabfirst,label_error-tabfirst,gotoend-tabfirst,label_error-tabfirst,label_error-tabfirst,label_error-tabfirst,label0-tabfirst
	dc.w	label_error-tabfirst,label0-tabfirst,label0-tabfirst,label0-tabfirst,label0-tabfirst,label0-tabfirst,label0-tabfirst,label0-tabfirst
	dc.w	label0-tabfirst,label0-tabfirst,label0-tabfirst,label0-tabfirst,label0-tabfirst,label0-tabfirst,label0-tabfirst,label0-tabfirst
	dc.w	label0-tabfirst,label0-tabfirst,label0-tabfirst,label0-tabfirst,label0-tabfirst,label0-tabfirst,label0-tabfirst,label0-tabfirst
	dc.w	label0-tabfirst,label0-tabfirst,label0-tabfirst,label_error-tabfirst,label_error-tabfirst,label_error-tabfirst,label_error-tabfirst,label0-tabfirst
	dc.w	label_error-tabfirst,label0-tabfirst,label0-tabfirst,label0-tabfirst,label0-tabfirst,label0-tabfirst,label0-tabfirst,label0-tabfirst
	dc.w	label0-tabfirst,label0-tabfirst,label0-tabfirst,label0-tabfirst,label0-tabfirst,label0-tabfirst,label0-tabfirst,label0-tabfirst
	dc.w	label0-tabfirst,label0-tabfirst,label0-tabfirst,label0-tabfirst,label0-tabfirst,label0-tabfirst,label0-tabfirst,label0-tabfirst
	dc.w	label0-tabfirst,label0-tabfirst,label0-tabfirst,label_error-tabfirst,label_error-tabfirst,label_error-tabfirst,label_error-tabfirst,label_error-tabfirst
	dc.w	Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst
	dc.w	Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst
	dc.w	Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst
	dc.w	Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst
	dc.w	Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst
	dc.w	Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst
	dc.w	Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst
	dc.w	Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst
	dc.w	Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst
	dc.w	Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst
	dc.w	Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst
	dc.w	Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst
	dc.w	Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst
	dc.w	Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst
	dc.w	Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst
	dc.w	Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst,Err_gt127-tabfirst
;  #] jump table 1: 

.null:
	addq	#4,sp
	clr.l	incnum			;0 ligne traitee
	bra	EndAsm

colon:	subq.l	#1,d3
	move.l	d3,start_variable
	sub.l	a6,d3
	not.w	d3
	move.w	d3,length_variable
	move.b	(a6)+,d0
	move.l	a6,a1
	bra	init_retour

label0:	sf	loc_flag
	move.l	a6,d3
.boucle:
	REPT	9
	move.b	(a6)+,d0
	move.b	lab0tbl(pc,d0),d1
	bne.s	.exit
	ENDR
	bra.s	.boucle
.exit:
	bgt.s	colon
space0:
	neg.b	d1
	bvs.s	label_error1
	move.l	a6,a1
	subq.l	#1,d3
	move.l	d3,start_variable
	sub.l	a6,d3
	not.w	d3
	move.w	d3,length_variable
	bra	init_retour

label_error1:
	bra	Err_illlabel

;  #[ lab0tbl:
lab0tbl:	dc.b	-1,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,-1,-1,$80,$80,-1,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	-1,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,-1,$80,$80,$80,0,$80	;'.' rajoute
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,1,-1,$80,-1,$80,0
	dc.b	$80,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,$80,$80,$80,$80,0
	dc.b	$80,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
;  #] lab0tbl: 

colon_loc:
	move.l	d3,start_variable
	sub.l	a6,d3
	not.w	d3
	move.w	d3,length_variable
	move.b	(a6)+,d0
	move.l	a6,a1
	bra	init_retour

point_var:					;on repointe ici en 'espace .label'
	st	loc_flag
	move.l	a6,d3
boucle:
	REPT	9
	move.b	(a6)+,d0
	move.b	loclabtbl(pc,d0),d1
	bne.s	.exit
	ENDR
	bra.s	boucle
.exit:
	bgt.s	colon_loc
	neg.b	d1
	bvs.s	.label_error
	move.l	a6,a1
	move.l	d3,start_variable
	sub.l	a6,d3
	not.w	d3
	move.w	d3,length_variable
	bra	init_retour
.label_error:
	bra	Err_illlabel

;  #[ loclabtbl:
loclabtbl:
	dc.b	-1,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,-1,-1,$80,$80,-1,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	-1,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,-1,$80,$80,$80,0,$80	;'.' rajoute
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,1,-1,$80,-1,$80,0
	dc.b	$80,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,$80,$80,$80,$80,0
	dc.b	$80,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
;  #] loclabtbl: 

metacomco:
	st	loc_flag
	move.l	a6,d3
.label:	move.b	(a6)+,d0
	move.b	.table(pc,d0),d1
	beq.s	.label
	addq.b	#2,d1
	bne.s	.label_error
	move.b	(a6)+,d0
	move.b	.table(pc,d0),d1
	bmi	space0
	beq.s	.label_error
.colon:	subq.l	#1,d3
	move.l	d3,start_variable
	sub.l	a6,d3
	not.w	d3
	move.w	d3,length_variable
	move.b	(a6)+,d0
	move.l	a6,a1
	bra	init_retour

.label_error:
	subq.l	#1,a6
	bra	Err_illlabel
;  #[ table metacomco:
.table:	dc.b	-1,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,-1,-1,$80,$80,-1,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	-1,$80,$80,$80,-2,$80,$80,$80
	dc.b	$80,$80,-1,$80,$80,$80,$80,$80
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,1,-1,$80,-1,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80
;  #] table metacomco: 

;	 #] variable: 

;	 #[ opcode:
no_variable:
	move.l	a6,a1
	move.b	(a6)+,d0
init_retour:
	lea	fst68knode,a4
	lea	map68knode,a2
	lea	nxt68knode,a3
	move	d0,d1
	add	d1,d1
	move	.table3(pc,d1),d5
	beq	.opcode
	jmp	.table3(pc,d5)

.dcolon:	move.l	start_variable,a0
	move.w	length_variable,d0
	bsr	SetXdef

.space_again:
	move.l	a6,a1
	move.b	(a6)+,d0
	move	d0,d1
	add	d1,d1
	move	.table3(pc,d1),d5
	beq	.opcode
	jmp	.table3(pc,d5)

;  #[ table de jmp:
.table3:
	dc.w	Null-.table3,Err_lt32-.table3,Err_lt32-.table3,Err_lt32-.table3,Err_lt32-.table3,Err_lt32-.table3,Err_lt32-.table3,Err_lt32-.table3
	dc.w	Err_lt32-.table3,.space_again-.table3,lf_encountered-.table3,Err_lt32-.table3,Err_lt32-.table3,cr_encountered-.table3,Err_lt32-.table3,Err_lt32-.table3
	dc.w	Err_lt32-.table3,Err_lt32-.table3,Err_lt32-.table3,Err_lt32-.table3,Err_lt32-.table3,Err_lt32-.table3,Err_lt32-.table3,Err_lt32-.table3
	dc.w	Err_lt32-.table3,Err_lt32-.table3,Err_lt32-.table3,Err_lt32-.table3,Err_lt32-.table3,Err_lt32-.table3,Err_lt32-.table3,Err_lt32-.table3
	dc.w	.space_again-.table3,0,.opcode_error-.table3,.opcode_error-.table3,.opcode_error-.table3,.opcode_error-.table3,.opcode_error-.table3,.opcode_error-.table3
	dc.w	.opcode_error-.table3,.opcode_error-.table3,gotoend-.table3,.opcode_error-.table3,.opcode_error-.table3,.opcode_error-.table3,.variable_locale-.table3,.opcode_error-.table3

	dc.w	metacomco-.table3,metacomco-.table3,metacomco-.table3,metacomco-.table3,metacomco-.table3,metacomco-.table3,metacomco-.table3,metacomco-.table3
	dc.w	metacomco-.table3,metacomco-.table3,.dcolon-.table3,gotoend-.table3,.opcode_error-.table3,.egal-.table3,.opcode_error-.table3,0
	dc.w	.opcode_error-.table3,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,.opcode_error-.table3,.opcode_error-.table3,.opcode_error-.table3,.opcode_error-.table3,0
	dc.w	.opcode_error-.table3,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,.opcode_error-.table3,.opcode_error-.table3,.opcode_error-.table3,.opcode_error-.table3,.opcode_error-.table3
	dc.w	Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3
	dc.w	Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3
	dc.w	Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3
	dc.w	Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3
	dc.w	Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3
	dc.w	Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3
	dc.w	Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3
	dc.w	Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3
	dc.w	Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3
	dc.w	Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3
	dc.w	Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3
	dc.w	Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3
	dc.w	Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3
	dc.w	Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3
	dc.w	Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3
	dc.w	Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3,Err_gt127-.table3
;  #] table de jmp: 

.retour:
	move	d0,d1
	add	d1,d1
	move	.table2(pc,d1),d5
	jmp	.table2(pc,d5)

;  #[ table de jmp:
.table2:
	dc.w	.null-.table2,Err_lt32-.table2,Err_lt32-.table2,Err_lt32-.table2,Err_lt32-.table2,Err_lt32-.table2,Err_lt32-.table2,Err_lt32-.table2
	dc.w	Err_lt32-.table2,.fin-.table2,.lf-.table2,Err_lt32-.table2,Err_lt32-.table2,.cr-.table2,Err_lt32-.table2,Err_lt32-.table2
	dc.w	Err_lt32-.table2,Err_lt32-.table2,Err_lt32-.table2,Err_lt32-.table2,Err_lt32-.table2,Err_lt32-.table2,Err_lt32-.table2,Err_lt32-.table2
	dc.w	Err_lt32-.table2,Err_lt32-.table2,Err_lt32-.table2,Err_lt32-.table2,Err_lt32-.table2,Err_lt32-.table2,Err_lt32-.table2,Err_lt32-.table2
	dc.w	.fin-.table2,.opcode2-.table2,.opcode_error-.table2,.opcode_error-.table2,.opcode_error-.table2,.opcode_error-.table2,.opcode_error-.table2,.opcode_error-.table2
	dc.w	.opcode_error-.table2,.opcode_error-.table2,.semi-.table2,.opcode_error-.table2,.opcode_error-.table2,.opcode_error-.table2,.point-.table2,.opcode_error-.table2
	dc.w	.opcode2-.table2,.opcode2-.table2,.opcode2-.table2,.opcode2-.table2,.opcode2-.table2,.opcode2-.table2,.opcode2-.table2,.opcode2-.table2
	dc.w	.opcode2-.table2,.opcode2-.table2,.colon-.table2,.semi-.table2,.opcode_error-.table2,.opcode2-.table2,.opcode_error-.table2,.opcode2-.table2
	dc.w	.opcode_error-.table2,.opcode2-.table2,.opcode2-.table2,.opcode2-.table2,.opcode2-.table2,.opcode2-.table2,.opcode2-.table2,.opcode2-.table2
	dc.w	.opcode2-.table2,.opcode2-.table2,.opcode2-.table2,.opcode2-.table2,.opcode2-.table2,.opcode2-.table2,.opcode2-.table2,.opcode2-.table2
	dc.w	.opcode2-.table2,.opcode2-.table2,.opcode2-.table2,.opcode2-.table2,.opcode2-.table2,.opcode2-.table2,.opcode2-.table2,.opcode2-.table2
	dc.w	.opcode2-.table2,.opcode2-.table2,.opcode2-.table2,.opcode_error-.table2,.opcode_error-.table2,.opcode_error-.table2,.opcode_error-.table2,.opcode2-.table2
	dc.w	.opcode_error-.table2,.opcode3-.table2,.opcode3-.table2,.opcode3-.table2,.opcode3-.table2,.opcode3-.table2,.opcode3-.table2,.opcode3-.table2
	dc.w	.opcode3-.table2,.opcode3-.table2,.opcode3-.table2,.opcode3-.table2,.opcode3-.table2,.opcode3-.table2,.opcode3-.table2,.opcode3-.table2
	dc.w	.opcode3-.table2,.opcode3-.table2,.opcode3-.table2,.opcode3-.table2,.opcode3-.table2,.opcode3-.table2,.opcode3-.table2,.opcode3-.table2
	dc.w	.opcode3-.table2,.opcode3-.table2,.opcode3-.table2,.opcode_error-.table2,.opcode_error-.table2,.opcode_error-.table2,.opcode_error-.table2,.opcode_error-.table2
	dc.w	Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2
	dc.w	Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2
	dc.w	Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2
	dc.w	Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2
	dc.w	Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2
	dc.w	Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2
	dc.w	Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2
	dc.w	Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2
	dc.w	Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2
	dc.w	Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2
	dc.w	Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2
	dc.w	Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2
	dc.w	Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2
	dc.w	Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2
	dc.w	Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2
	dc.w	Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2,Err_gt127-.table2
;  #] table de jmp: 

.opcode_error:
	bra	Err_illopcode

.egal:	add.w	(a4),d1
	move.w	0(a3,d1.w),d2
	moveq	#$40,d1
	bra	.fin

.nf0:	bra	.find_macro

.opcode:	and	#$bf,d1
	add.w	(a4),d1
	tst.w	0(a2,d1.w)
	bne.s	.nf0
	move.w	0(a3,d1.w),d2
	move.b	(a6)+,d0
.opcode3:	moveq	#0,d1
	move.b	.grande_table(pc,d0),d1
	bge.s	.end_opcode
.opcode2:	add.w	0(a4,d2.w),d1
	sub.w	0(a2,d1.w),d2
	bne.s	.nf
	move.w	0(a3,d1.w),d1
	move.b	(a6)+,d0
	move.b	.grande_table(pc,d0),d2
	bge.s	.end_opcode1		;resultat in d1
	add.w	0(a4,d1.w),d2
	sub.w	0(a2,d2.w),d1
	bne.s	.nf
	move.w	0(a3,d2.w),d2
	move.b	(a6)+,d0
	move.b	.grande_table(pc,d0),d1
	bge.s	.end_opcode		;resultat in d2
	add.w	0(a4,d2.w),d1
	sub.w	0(a2,d1.w),d2
	bne.s	.nf
	move.w	0(a3,d1.w),d1
	move.b	(a6)+,d0
	move.b	.grande_table(pc,d0),d2
	bge.s	.end_opcode1		;resultat in d1
	add.w	0(a4,d1.w),d2
	sub.w	0(a2,d2.w),d1
	bne.s	.nf
	move.w	0(a3,d2.w),d2
	move.b	(a6)+,d0
	move.b	.grande_table(pc,d0),d1
	bmi.s	.opcode2		;resultat in d2
	bgt	.fin
	bra	.retour
.end_opcode1:
	exg	d1,d2
.end_opcode:
	bgt	.fin
	bra	.retour
.nf:	bra	.find_macro

;  #[ table de test:
.grande_table:
	dc.b	$40,0,0,0,0,0,0,0,0,$40,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	$40,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,'A'*2,'B'*2,'C'*2,'D'*2,'E'*2,'F'*2,'G'*2
	dc.b	'H'*2,'I'*2,'J'*2,'K'*2,'L'*2,'M'*2,'N'*2,'O'*2
	dc.b	'P'*2,'Q'*2,'R'*2,'S'*2,'T'*2,'U'*2,'V'*2,'W'*2
	dc.b	'X'*2,'Y'*2,'Z'*2,0,0,0,0,0
	dc.b	0,'A'*2,'B'*2,'C'*2,'D'*2,'E'*2,'F'*2,'G'*2
	dc.b	'H'*2,'I'*2,'J'*2,'K'*2,'L'*2,'M'*2,'N'*2,'O'*2
	dc.b	'P'*2,'Q'*2,'R'*2,'S'*2,'T'*2,'U'*2,'V'*2,'W'*2
	dc.b	'X'*2,'Y'*2,'Z'*2,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;  #] table de test: 

.null:
	move.w	#TERM_OPCODE*2,d1
	add.w	0(a4,d2.w),d1
	cmp.w	0(a2,d1.w),d2
	bne	.find_macro
	move.w	0(a3,d1.w),d2
	lea	OpTable(pc),a2
	sub.w	d2,a2		;@ structure instruction
	move	CHAMPS,OpSize
	moveq	#0,CHAMPS
	rts

.cr:
	move.w	#TERM_OPCODE*2,d1
	add.w	0(a4,d2.w),d1
	cmp.w	0(a2,d1.w),d2
	bne.s	.find_macro
	move.w	0(a3,d1.w),d2
	lea	OpTable(pc),a2
	sub.w	d2,a2		;@ structure instruction
	move	CHAMPS,OpSize
	moveq	#0,CHAMPS
	bra	cr_encountered

.lf:
	move.w	#TERM_OPCODE*2,d1
	add.w	0(a4,d2.w),d1
	cmp.w	0(a2,d1.w),d2
	bne.s	.find_macro
	move.w	0(a3,d1.w),d2
	lea	OpTable(pc),a2
	sub.w	d2,a2		;@ structure instruction
	move	CHAMPS,OpSize
	moveq	#0,CHAMPS
	bra	lf_encountered

.semi:
	move.w	#TERM_OPCODE*2,d1
	add.w	0(a4,d2.w),d1
	cmp.w	0(a2,d1.w),d2
	bne.s	.find_macro
	move.w	0(a3,d1.w),d2
	lea	OpTable(pc),a2
	sub.w	d2,a2		;@ structure instruction
	move	CHAMPS,OpSize
	moveq	#0,CHAMPS
	bra	gotoend

.find_macro_loop
	move.b	(a6)+,d0
.find_macro:
	move.b	.end_table(pc,d0),d2
	beq.s	.find_macro_loop
	bpl.s	.not_sized_macro
	neg.b	d2
	bvc.s	.opcode_error2
	move.l	a6,d0
	sub.l	a1,d0
	move.b	(a6)+,d1
	and	#$df,d1
	move.b	d1,MacStuff+MacCallSize
	move.l	a1,a0
	bra.s	.search_in_macro_table
.not_sized_macro:
	move.l	a1,a0
	sf	MacStuff+MacCallSize
	move.l	a6,d0
	sub.l	a1,d0
.search_in_macro_table:
	subq	#1,d0
	;;;AMIGA
	cmp.b	#10,-1(a6)
	bne.s	.nolf
	subq.w	#1,a6
.nolf:	;;;
	bsr	find_macro
	beq	.ropnf
	move.l	d0,MacNb
	lea	_macro_line,a2
	moveq	#0,d0
	moveq	#0,CHAMPS
	bra	.space_loop
.opcode_error2:
	subq.b	#1,d2
	bne	.colon
	bra	Err_illopcode
;  #[ table de test:
.end_table:
	dc.b	1,-1,-1,-1,-1,-1,-1,-1,-1,1,1,-1,-1,1,-1,-1
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.b	1,-1,-1,-1,-1,-1,-1,-1,1,-1,-1,-1,-1,-1,$80,-1
	dc.b	0,0,0,0,0,0,0,0,0,0,-2,1,-1,-1,-1,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,0
	dc.b	-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1
	dc.b	1,-1,-1,-1,-1,-1,-1,-1,1,-1,-1,-1,-1,-1,-1,-1
	dc.b	1,-1,-1,-1,-1,-1,-1,-1,1,-1,-1,-1,-1,-1,-1,-1
	dc.b	1,-1,-1,-1,-1,-1,-1,-1,1,-1,-1,-1,-1,-1,-1,-1
	dc.b	1,-1,-1,-1,-1,-1,-1,-1,1,-1,-1,-1,-1,-1,-1,-1
	dc.b	1,-1,-1,-1,-1,-1,-1,-1,1,-1,-1,-1,-1,-1,-1,-1
	dc.b	1,-1,-1,-1,-1,-1,-1,-1,1,-1,-1,-1,-1,-1,-1,-1
	dc.b	1,-1,-1,-1,-1,-1,-1,-1,1,-1,-1,-1,-1,-1,-1,-1
	dc.b	1,-1,-1,-1,-1,-1,-1,-1,1,-1,-1,-1,-1,-1,-1,-1
;  #] table de test: 

.ropnf:	subq.w	#1,d6			;champs--
	lea	premsg,a0
	move.w	#MSG_CORR,MSG_flags(a0)
	move.w	#-opnf_errno,MSG_no(a0)
	clr.w	MSG_len(a0)
	move.l	CurModPtr,MSG_mod(a0)
	move.l	CurLNb,MSG_lnb(a0)
	move.l	CurLPtr,MSG_ln(a0)
	jsr	OutMsg
	moveq	#0,d0
	bra	gotoend

.colon:	tst	length_variable
	bne.s	.opcode_error1
	sf	loc_flag
	move.l	a1,start_variable
	move.l	a6,d2
	sub.l	a1,d2
	subq	#1,d2
	move	d2,length_variable
	move.b	(a6)+,d0
	bra	init_retour
.opcode_error1:
	bra	Err_illopcode

.variable_locale:
	bra	point_var

.badsize:	lea	premsg,a0
	move.w	#MSG_CORR,MSG_flags(a0)
	move.w	#-opsz_forb_errno,MSG_no(a0)
	clr.w	MSG_len(a0)
	move.l	CurModPtr,MSG_mod(a0)
	move.l	CurLNb,MSG_lnb(a0)
	move.l	CurLPtr,MSG_ln(a0)
	jsr	OutMsg
	moveq	#0,d0
	bra	gotoend

.point:	move.w	#TERM_OPCODE*2,d1
	add.w	0(a4,d2.w),d1
	cmp.w	0(a2,d1.w),d2
	bne.s	.not_found
	move.w	0(a3,d1.w),d2
	lea	OpTable(pc),a2
	sub.w	d2,a2		;@ structure instruction

	move.b	(a6)+,d0
	lea	tab_car(pc),a3
	move.b	(a3,d0.w),d5
	lea	ins68ksize,a0
	move	d2,d1
	neg.w	d1
	asr.w	#4,d1
	and.b	(a0,d1.w),d5
	beq.s	.badsize
	moveq	#0,CHAMPS

	lea	tab_res(pc),a3
	move.b	(a3,d0.w),d0
	move.w	d0,OpSize

	move.l	FieldsPtr,a4
	move.l	a6,LINE_srcstart(a4)

	move.b	(a6)+,d0
	move.b	.space_table(pc,d0),d1
	beq	operande
	bpl.s	.space_loop1
	bra	exit_on_first

.not_found:
	bra	.find_macro
;	moveq	#0,CHAMPS
;	move.l	a6,d0
;	sub.l	a1,d0
;	sf	MacStuff+MacCallSize
;	move.l	a1,a0
;	bra	.search_in_macro_table
;	bra	.find_macro

.fin:
	add.b	d1,d1
	bpl.s	.point
	add.w	0(a4,d2.w),d1
	cmp.w	0(a2,d1.w),d2
	bne.s	.not_found
	move.w	0(a3,d1.w),d2
	lea	OpTable(pc),a2
	sub.w	d2,a2		;@ structure instruction
	move	CHAMPS,OpSize
	moveq	#0,CHAMPS
;	 #] opcode: 

;	 #[ operandes:
.space_loop:
	move.l	FieldsPtr,a4
.space_loop1:
	move.l	a6,LINE_srcstart(a4)
	move.b	(a6)+,d0
	move.b	.space_table(pc,d0),d1
	beq	operande
	bpl.s	.space_loop1
	bra	exit_on_first

;  #[ table de test:
	even
.space_table:
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,1,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	1,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,$ff,0,0,0,0

	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0

	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
;  #] table de test: 

operande:
	moveq	#0,BRACKETPARENT
	btst	#_FUNC_NOOPER,REF_flags(a2)
	bne.s	spurious_comment
	moveq	#0,QUOTER
	moveq	#0,d1
	clr.w	LINE_par0nb(a4)
	move.l	a4,a1
	move.l	d1,LINE_parnb(a4)
exit_on_first:
	move	d0,d5
	add	d5,d5
	move	first_table(pc,d5),d5
	jmp	first_table(pc,d5)

spurious_comment:
	bsr	Warn_comment
	moveq	#0,CHAMPS
	bra	gotoend_in_op

parentdfirst:
	addq	#1,BRACKETPARENT
diese:
	move.b	d0,(a1)+
	move.b	(a6)+,d0

first_char:
	move	d0,d5
	add	d5,d5
	move	first_table(pc,d5),d5
	jmp	first_table(pc,d5)

level:	move.b	d0,(a1)+			;ALEX poke la virgule
	move.l	a6,LINE_srccomma(a4)
	tst	BRACKETPARENT
	bne.s	.levbra
	addq	#1,LINE_parnb(a4)
	swap	BRACKETPARENT
	bra.s	first_general

.levbra:	swap	BRACKETPARENT
	tst	BRACKETPARENT
	beq.s	.rbra
	addq	#1,LINE_branb(a4)
	bra.s	first_general
.rbra:	bra	Err_unbal_bracket		;not unbal but wrong anyway

virgule:	swap	BRACKETPARENT
	bne.s	level

	st	(a1)
	move.l	a1,LINE_tokend(a4)

	move	d1,LINE_eval(a4)
	sf	d1

	lea	LINE_SIZEOF(a4),a4
	move.l	a4,a1
	move.l	a6,LINE_srcstart(a4)
	move.l	d1,LINE_parnb(a4)
	clr.w	LINE_par0nb(a4)
	addq.b	#1,CHAMPS
	bmi.s	toomany_operands

first_general:
	move.b	(a6)+,d0
	move	d0,d5
	add	d5,d5
	move	first_table(pc,d5),d5
	jmp	first_table(pc,d5)

toomany_operands:
	bra	Err_2manyoper

;  #[ Analyse branch table:

first_table:
	dc.w	Null-first_table,Err_lt32-first_table,Err_lt32-first_table,Err_lt32-first_table,Err_lt32-first_table,Err_lt32-first_table,Err_lt32-first_table,Err_lt32-first_table
	dc.w	Err_lt32-first_table,space3-first_table,lf_encountered-first_table,Err_lt32-first_table,Err_lt32-first_table,cr_encountered-first_table,Err_lt32-first_table,Err_lt32-first_table
	dc.w	Err_lt32-first_table,Err_lt32-first_table,Err_lt32-first_table,Err_lt32-first_table,Err_lt32-first_table,Err_lt32-first_table,Err_lt32-first_table,Err_lt32-first_table
	dc.w	Err_lt32-first_table,Err_lt32-first_table,Err_lt32-first_table,Err_lt32-first_table,Err_lt32-first_table,Err_lt32-first_table,Err_lt32-first_table,Err_lt32-first_table
	dc.w	space3-first_table,nomaj-first_table,guillem-first_table,diese-first_table,nomaj-first_table,nomaj-first_table,nomaj-first_table,quote0-first_table
	dc.w	parentdfirst-first_table,parentg-first_table,etoilefirst-first_table,nomaj-first_table,virgule-first_table,token_enable-first_table,start_point-first_table,token_enable-first_table	; (setflag)
	dc.w	nomaj-first_table,nomaj-first_table,nomaj-first_table,nomaj-first_table,nomaj-first_table,nomaj-first_table,nomaj-first_table,nomaj-first_table
	dc.w	nomaj-first_table,nomaj-first_table,token_enable-first_table,gotoend-first_table,nomaj-first_table,nomaj-first_table,nomaj-first_table,nomaj-first_table

	dc.w	nomaj-first_table,test_numbera-first_table,nomaj-first_table,tstccr-first_table,test_numberd-first_table,nomaj-first_table,nomaj-first_table,nomaj-first_table
	dc.w	nomaj-first_table,nomaj-first_table,nomaj-first_table,nomaj-first_table,nomaj-first_table,nomaj-first_table,nomaj-first_table,nomaj-first_table
	dc.w	tstc-first_table,nomaj-first_table,nomaj-first_table,tstp-first_table,nomaj-first_table,tstusp-first_table,nomaj-first_table,nomaj-first_table
	dc.w	nomaj-first_table,nomaj-first_table,zed-first_table,brackd-first_table,nomaj-first_table,brackg-first_table,nomaj-first_table,nomaj-first_table
	dc.w	nomaj-first_table,test_numbera-first_table,nomaj-first_table,tstccr-first_table,test_numberd-first_table,nomaj-first_table,nomaj-first_table,nomaj-first_table
	dc.w	nomaj-first_table,nomaj-first_table,nomaj-first_table,nomaj-first_table,nomaj-first_table,nomaj-first_table,nomaj-first_table,nomaj-first_table
	dc.w	tstc-first_table,nomaj-first_table,nomaj-first_table,tstp-first_table,nomaj-first_table,tstusp-first_table,nomaj-first_table,nomaj-first_table
	dc.w	nomaj-first_table,nomaj-first_table,zed-first_table,accol-first_table,nomaj-first_table,nomaj-first_table,nomaj-first_table,nomaj-first_table

	dc.w	Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table
	dc.w	Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table
	dc.w	Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table
	dc.w	Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table
	dc.w	Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table
	dc.w	Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table
	dc.w	Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table
	dc.w	Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table
	dc.w	Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table
	dc.w	Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table
	dc.w	Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table
	dc.w	Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table
	dc.w	Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table
	dc.w	Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table
	dc.w	Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table
	dc.w	Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table
	dc.w	Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table
	dc.w	Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table,Err_gt127-first_table
;  #] Analyse branch table: 

etoilefirst:
	btst	#_FUNC_NOOPER,REF_flags(a2)
	beq	nomaj
	bra	gotoend

parentd:	st	d1;	eval complexe
	addq	#1,BRACKETPARENT
	move.b	d0,(a1)+
	move.b	(a6)+,d0
saut:
	move	d0,d5
	add	d5,d5
	move	table(pc,d5),d5
	jmp	table(pc,d5)

deuxp:
	move.l	a6,LINE_srccomma(a4)
	bra.s	token_enable
eval2:
	st	d1
token_enable:
	move.b	d0,(a1)+
general:
	move.b	(a6)+,d0
	move	d0,d5
	add	d5,d5
	move	table(pc,d5),d5
	jmp	table(pc,d5)

;  #[ Analyse branch table:
	even
table:
	dc.w	null-table,Err_lt32-table,Err_lt32-table,Err_lt32-table,Err_lt32-table,Err_lt32-table,Err_lt32-table,Err_lt32-table
	dc.w	Err_lt32-table,space3-table,lf-table,Err_lt32-table,Err_lt32-table,cr-table,Err_lt32-table,Err_lt32-table
	dc.w	Err_lt32-table,Err_lt32-table,Err_lt32-table,Err_lt32-table,Err_lt32-table,Err_lt32-table,Err_lt32-table,Err_lt32-table
	dc.w	Err_lt32-table,Err_lt32-table,Err_lt32-table,Err_lt32-table,Err_lt32-table,Err_lt32-table,Err_lt32-table,Err_lt32-table
	dc.w	space3-table,eval-table,guillem-table,nomaj-table,nomaj-table,nomaj-table,eval-table,quote0-table
	dc.w	parentd-table,parentg-table,eval-table,eval-table,virgule-table,eval2-table,point-table,eval2-table	; (setflag)
	dc.w	nomaj-table,nomaj-table,nomaj-table,nomaj-table,nomaj-table,nomaj-table,nomaj-table,nomaj-table
	dc.w	nomaj-table,nomaj-table,token_enable-table,semi-table,eval-table,eval-table,eval-table,nomaj-table

	dc.w	nomaj-table,test_numbera-table,nomaj-table,tstccr-table,test_numberd-table,nomaj-table,nomaj-table,nomaj-table
	dc.w	nomaj-table,nomaj-table,nomaj-table,nomaj-table,nomaj-table,nomaj-table,nomaj-table,nomaj-table
	dc.w	tstc-table,nomaj-table,nomaj-table,tstp-table,nomaj-table,tstusp-table,nomaj-table,nomaj-table
	dc.w	nomaj-table,nomaj-table,zed-table,brackd-table,nomaj-table,brackg-table,eval-table,nomaj-table
	dc.w	nomaj-table,test_numbera-table,nomaj-table,tstccr-table,test_numberd-table,nomaj-table,nomaj-table,nomaj-table
	dc.w	nomaj-table,nomaj-table,nomaj-table,nomaj-table,nomaj-table,nomaj-table,nomaj-table,nomaj-table
	dc.w	tstc-table,nomaj-table,nomaj-table,tstp-table,nomaj-table,tstusp-table,nomaj-table,nomaj-table
	dc.w	nomaj-table,nomaj-table,zed-table,accol-table,eval-table,nomaj-table,eval-table,nomaj-table

	dc.w	Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table
	dc.w	Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table
	dc.w	Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table
	dc.w	Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table
	dc.w	Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table
	dc.w	Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table
	dc.w	Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table
	dc.w	Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table
	dc.w	Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table
	dc.w	Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table
	dc.w	Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table
	dc.w	Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table
	dc.w	Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table
	dc.w	Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table
	dc.w	Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table
	dc.w	Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table
	dc.w	Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table
	dc.w	Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table,Err_gt127-table
;  #] Analyse branch table: 

saut_patok:
	move	d0,d5
	add	d5,d5
	move	table2(pc,d5),d5
	beq.s	nomaj
	jmp	table2(pc,d5)

eval:
	st	d1
nomaj:
	move.b	d0,(a1)+
general_patok:
	REPT	7
	move.b	(a6)+,d0
	move	d0,d5
	add	d5,d5
	move	table2(pc,d5),d5
	bne.s	.tojump
	move.b	d0,(a1)+
	ENDR
	move.b	(a6)+,d0
	move	d0,d5
	add	d5,d5
	move	table2(pc,d5),d5
	beq.s	nomaj
.tojump:
	jmp	table2(pc,d5)

;  #[ Analyse branch table:
	even
table2:
	dc.w	null-table2,Err_lt32-table2,Err_lt32-table2,Err_lt32-table2,Err_lt32-table2,Err_lt32-table2,Err_lt32-table2,Err_lt32-table2
	dc.w	Err_lt32-table2,space3-table2,lf-table2,Err_lt32-table2,Err_lt32-table2,cr-table2,Err_lt32-table2,Err_lt32-table2
	dc.w	Err_lt32-table2,Err_lt32-table2,Err_lt32-table2,Err_lt32-table2,Err_lt32-table2,Err_lt32-table2,Err_lt32-table2,Err_lt32-table2
	dc.w	Err_lt32-table2,Err_lt32-table2,Err_lt32-table2,Err_lt32-table2,Err_lt32-table2,Err_lt32-table2,Err_lt32-table2,Err_lt32-table2

	dc.w	space3-table2,eval-table2,guillem-table2,0,0,0,eval-table2,quote0-table2
	dc.w	parentd-table2,parentg-table2,eval-table2,eval-table2,virgule-table2,eval2-table2,point-table2,eval2-table2	; (setflag)
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,deuxp-table2,semi-table2,eval-table2,eval-table2,eval-table2,0

	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0

	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,brackd-table2,0,brackg-table2,eval-table2,0

	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0

	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,accol-table2,eval-table2,0,eval-table2,0

	dc.w	Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2
	dc.w	Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2
	dc.w	Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2
	dc.w	Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2
	dc.w	Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2
	dc.w	Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2
	dc.w	Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2
	dc.w	Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2
	dc.w	Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2
	dc.w	Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2
	dc.w	Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2
	dc.w	Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2
	dc.w	Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2
	dc.w	Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2
	dc.w	Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2
	dc.w	Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2
	dc.w	Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2
	dc.w	Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2,Err_gt127-table2
;  #] Analyse branch table: 

null:
	tst.l	BRACKETPARENT
	bne.s	level_error
	st	(a1)
	move.l	a1,LINE_tokend(a4)
	move	d1,LINE_eval(a4)
	addq.b	#1,CHAMPS
	bmi.s	toomany
	rts

level_error:
	tst	BRACKETPARENT
	bne	Err_0parent
	bra	Err_unbal_bracket

lf:
	tst.l	BRACKETPARENT
	bne.s	level_error
	st	(a1)
	move.l	a1,LINE_tokend(a4)
	move	d1,LINE_eval(a4)
	addq.b	#1,CHAMPS
	bmi.s	toomany
	bra	lf_encountered

semi:
	tst.l	BRACKETPARENT
	bne.s	level_error
	st	(a1)
	move.l	a1,LINE_tokend(a4)
	move	d1,LINE_eval(a4)
	addq.b	#1,CHAMPS
	bmi.s	toomany
	bra	gotoend_in_op

toomany:
	bra	Err_2manyoper


space3:
	move.b	-2(a6),d5
.space3:
	move.b	(a6)+,d0
	move.b	.jolie_table(pc,d0),d3
	beq.s	.space3			;espace ou tab=0
	bmi	saut_patok		;cr ou lf ou ; =255
	addq.b	#1,d3
	bmi	next_field		;,=$7f
	addq.b	#1,d3
	bmi	Err_lt32		;<32=$7e
	subq.b	#3,d3			;etoile?
	bne.s	.etoile
	cmp.b	#',',d5
	beq	saut
.warning:
	bsr	Warn_comment		; autre = 1 (commentaire sans ;)
.etoile:
	cmp.l	a4,a1
	beq.s	.gotoend		;si rien n'a ete stocke => gotoend
	tst.l	BRACKETPARENT
	bne.s	.level_error
	st	(a1)
	move.l	a1,LINE_tokend(a4)
	move	d1,LINE_eval(a4)
	addq.b	#1,CHAMPS
	bmi	Err_2manyoper
.gotoend:	bra	gotoend
.level_error:
	tst	BRACKETPARENT
	bne	Err_0parent
	bra	Err_unbal_bracket

;  #[ table de test:
.jolie_table:
	dc.b	$7e,$7e,$7e,$7e,$7e,$7e,$7e,$7e
	dc.b	$7e,0,$ff,$7e,$7e,$ff,$7e,$7e
	dc.b	$7e,$7e,$7e,$7e,$7e,$7e,$7e,$7e
	dc.b	$7e,$7e,$7e,$7e,$7e,$7e,$7e,$7e
	dc.b	0,1,1,1,1,1,1,1
	dc.b	1,1,2,1,$7f,1,1,1
	dc.b	1,1,1,1,1,1,1,1
	dc.b	1,1,1,$ff,1,1,1,1
	rept	24
	dc.b	1,1,1,1,1,1,1,1
	endr
;  #] table de test: 

next_field:
	tst.l	BRACKETPARENT
	bne.s	.level_error

	st	(a1)
	move.l	a1,LINE_tokend(a4)
	move	d1,LINE_eval(a4)
	sf	d1

	lea	LINE_SIZEOF(a4),a4
	move.l	a4,a1
	move.l	a6,LINE_srcstart(a4)
	move.l	d1,LINE_parnb(a4)
	clr.w	LINE_par0nb(a4)

	addq.b	#1,CHAMPS
	bmi.s	.errmany
	move.b	(a6)+,d0
	bra	first_char
.level_error:
	tst	BRACKETPARENT
	bne	Err_unbal_parent
	bra	Err_unbal_bracket
.errmany:	bra	Err_2manyoper

guillem:
	bset	#16,QUOTER

quote0:	move.l	a1,a0
.quote:	move.b	d0,(a1)+
.again:	move.b	(a6)+,d0
	btst	#1,.table_quote(pc,d0)
	beq.s	.quote
	btst	#2,.table_quote(pc,d0)
	beq.s	.rquote
	cmp.b	#'"',d0
	beq.s	.verif0

.verif:	btst	#16,QUOTER
	bne.s	.quote
	cmp.b	(a6)+,d0
	beq.s	.quote		;.again
	subq.w	#1,a6		;rajout
	move.b	#TOKENQUOTE,(a1)+
	bclr	#16,QUOTER
	move.b	(a6)+,d0
	btst	#0,.table_quote(pc,d0)
	bne	saut_patok
	move.b	#TOKENQUOTE,(a0)
	bra	saut_patok

.verif0:	btst	#16,QUOTER
	beq.s	.quote
	cmp.b	(a6)+,d0
	beq.s	.quote		;.again
	subq.w	#1,a6		;rajout
	move.b	#TOKENQUOTE,(a1)+
	bclr	#16,QUOTER
	move.b	(a6)+,d0
	btst	#0,.table_quote(pc,d0)
	bne	saut_patok
	move.b	#TOKENQUOTE,(a0)
	bra	saut_patok
.rquote:	bra	Err_unbalquote

;  #[ table de test:
.table_quote:
	dc.b	2,0,0,0,0,0,0,0,0,0,2,0,0,2,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,1,7,1,1,1,1,7,1,1,1,1,0,1,1,1
	dc.b	1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1

	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1

	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;  #] table de test: 

parentg:	tst	BRACKETPARENT
	beq.s	.rpar
	subq	#1,BRACKETPARENT
	bne.s	.rien
	addq.w	#1,LINE_par0nb(a4)
.rien:	move.b	d0,(a1)+
	bra	general
.rpar:	bra	Err_unbal_parent

brackd:	swap	BRACKETPARENT
	addq	#1,BRACKETPARENT
	cmp	#2,BRACKETPARENT
	bge.s	.rbra
	swap	BRACKETPARENT
	move.b	d0,(a1)+
	bra	general

.rbra:	swap	BRACKETPARENT
	bra	Err_unbal_bracket

brackg:	swap	BRACKETPARENT
	tst	BRACKETPARENT
	beq.s	.rbra
	subq	#1,BRACKETPARENT
	bne.s	.rbra
	swap	BRACKETPARENT
	move.l	a1,LINE_btokend(a4)
	move.b	d0,(a1)+
	bra	general

.rbra:	bra	Err_unbal_bracket

zed:	cmp.b	#'p',(a6)
	beq.s	.oui
	cmp.b	#'P',(a6)
	bne.s	.testa
.oui:
	addq	#1,a6
	cmp.b	#'c',(a6)
	beq.s	.oui2
	cmp.b	#'C',(a6)
	bne.s	.nomaj1
.oui2:
	addq	#1,a6
	cmp.b	#',',(a6)
	beq.s	.good
	cmp.b	#')',(a6)
	beq.s	.good
	cmp.b	#']',(a6)
	bne.s	.nomaj2
.good:
	move.b	#TOKENZPC,(a1)+
	bra	general_patok
.testa:
	cmp.b	#'a',(a6)
	beq.s	.oui3
	cmp.b	#'A',(a6)
	bne.s	.nomaj
.oui3:
	addq	#1,a6
	cmp.b	#'7',(a6)
	bgt.s	.nomaj1
	cmp.b	#'0',(a6)
	blt.s	.nomaj1
.oui4:
	addq	#1,a6
	cmp.b	#',',(a6)
	beq.s	.good2
	cmp.b	#']',(a6)
	beq.s	.good2
	cmp.b	#')',(a6)
	bne.s	.nomaj2
.good2:
	move.b	#TOKENZAN,(a1)+
	bra	general_patok
.nomaj2:
	subq	#1,a6
.nomaj1:
	subq	#1,a6
.nomaj:
	move.b	d0,(a1)+
	bra	general_patok

tstc:
	cmp.b	#'c',(a6)
	beq.s	.maj_pc
	cmp.b	#'C',(a6)
	bne	nomaj
.maj_pc:
	addq	#1,a6
	cmp.b	#')',(a6)
	beq.s	.good
	cmp.b	#',',(a6)
	beq.s	.good
	cmp.b	#']',(a6)
	bne.s	.nomaj1
.good:	move.b	#TOKENPC,(a1)+
	bra	general_patok
.nomaj1:
	subq	#1,a6
.nomaj:
	move.b	d0,(a1)+
	bra	general_patok

tstp:
	cmp.b	#'p',(a6)
	beq.s	.maj_sp
	cmp.b	#'P',(a6)
	bne.s	.tstr		;pas nomaj a cause de sr
.maj_sp:
	move.b	1(a6),d3
	move.b	.table_again(pc,d3),d3
	ble.s	.nomaj0
	move.b	#TOKENA7,(a1)+
	addq	#1,a6
	bra	general_patok
.scaled:
	move.b	#TOKENA7,(a1)+
	addq	#2,a6
	bra	scalexn
.nomaj0:
	beq	nomaj
	neg.b	d3
	bvc.s	.scaled
	move.b	#TOKENA7,(a1)+
	addq	#2,a6
	bra	pointxn

.tstr:
	cmp.b	#'r',(a6)
	beq.s	.maj_sr
	cmp.b	#'R',(a6)
	bne	nomaj
.maj_sr:
	cmp.b	#32,1(a6)		;bug ici, si sr' ' en fin de ligne.
	ble.s	.goodsr		;bug idem pour ccr' '. Marc.
	cmp.b	#',',1(a6)	;je vais tracer, Laurent.
	bne	nomaj
.goodsr:
	move.b	#TOKENSR,(a1)+
	addq	#1,a6
	bra	general_patok

;  #[ table de test:
.table_again:
	dc.b	0,0,0,0,0,0,0,0,0,1,1,0,0,1,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	1,0,0,0,0,0,0,0,0,1,255,0,1,1,128,1
	dc.b	0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;  #] table de test: 


accol:
	;eol
	st	(a1)
	move.l	a1,LINE_tokend(a4)
	move	d1,LINE_eval(a4)
	sf	d1

	lea	LINE_SIZEOF(a4),a4
	move.l	a4,a1
	lea	-1(a6),a0
	move.l	a0,LINE_srcstart(a4)
	move.l	d1,LINE_parnb(a4)
	clr.w	LINE_par0nb(a4)

	addq.b	#1,CHAMPS
	bmi.s	.toomany
	move.b	d0,(a1)+
	bra	first_general
.toomany:
	bra	Err_2manyoper

point:
	lea	.before_point(pc),a0
	move.b	-2(a6),d3		;koikigna avant le .
	move.b	0(a0,d3),d3
	bne.s	.nomaj			;signe arithmetique ou betise, cassos
	move.b	1(a6),d3
	move.b	.table_point(pc,d3),d3
	bge.s	.nomaj
	move.b	(a6)+,d0
	move.b	.table_point(pc,d0),(a1)+
	ble.s	.error_size
	move.b	(a6),d3
	move.b	.table_point(pc,d3),d3
	neg.b	d3
	bvs	general_patok
	beq.s	.error_size
	addq	#1,a6
	bra	scalexn

.error_size:
	move.b	#'.',-1(a1)
.nomaj:
	move.b	d0,(a1)+
	bra	general_patok

;  #[ tables de test:
.table_point:
	dc.b	0,0,0,0,0,0,0,0,0,$80,$80,0,0,$80,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	$80,0,0,0,0,0,0,0,0,$80,255,0,$80,$80,$80,$80
	dc.b	0,0,0,0,0,0,0,0,0,0,0,$80,0,0,0,0
	dc.b	0,0,TOKENB,0,0,0,0,0,0,0,0,0,TOKENL,0,0,0
	dc.b	0,0,0,TOKENW,0,0,0,TOKENW,0,0,0,0,0,$80,0,0
	dc.b	0,0,TOKENB,0,0,0,0,0,0,0,0,0,TOKENL,0,0,0
	dc.b	0,0,0,TOKENW,0,0,0,TOKENW,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.before_point:
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1
	dc.b	0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1
	dc.b	1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0
	dc.b	1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
;  #] tables de test: 


start_point:
	move.b	#'.',(a1)+
	move.b	(a6)+,(a1)+
	bra	general_patok

test_numbera:
	move.b	(a6)+,d3
	move.b	.table_a(pc,d3),(a1)+
	bmi.s	.nomaj1
	move.b	(a6)+,d0
	btst	#4,.table_a(pc,d0)
	bne	saut_patok
	btst	#6,.table_a(pc,d0)
	bne.s	.pointan
	btst	#5,.table_a(pc,d0)
	bne.s	.scalean

	subq	#3,a6
	subq	#1,a1
	move.b	(a6)+,(a1)+
	bra	general_patok
.nomaj1:
	subq	#1,a6
	subq	#1,a1
	move.b	d0,(a1)+
	bra	general_patok
.pointan:
	bra	pointxn
.scalean:
	bra	scalexn

;  #[ table de test:
.table_a:
	dc.b	$90,$80,$80,$80,$80,$80,$80,$80,$80,$90,$90,$80,$80,$90,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$90,$80,$80,$80,$80,$80,$80,$80,$80,$90,$a0,$80,$90,$90,$c0,$90
	dc.b	8,9,10,11,12,13,14,15,$80,$80,$80,$90,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$90,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$88,$80,$88,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
;  #] table de test: 

test_numberd:
	move.b	(a6)+,d3
	move.b	.table_d(pc,d3),(a1)+
	bmi.s	.nomaj1
	move.b	(a6)+,d0
	btst	#3,.table_d(pc,d0)
	bne	saut_patok
	btst	#4,.table_d(pc,d0)
	bne.s	.pointdn
	btst	#5,.table_d(pc,d0)
	bne.s	.scaledn
	subq	#1,a1
	subq	#3,a6
	move.b	(a6)+,(a1)+
	bra	general_patok
.nomaj1:
	subq	#1,a1
	subq	#1,a6
	move.b	d0,(a1)+
	bra	general_patok
.pointdn:
	bra	pointxn
.scaledn:
	bra	scalexn

;  #[ table de test:
.table_d:
	dc.b	$88,$80,$80,$80,$80,$80,$80,$80,$80,$88,$88,$80,$80,$88,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$88,$80,$80,$80,$80,$80,$80,$80,$80,$88,$a0,$80,$88,$88,$90,$88
	dc.b	0,1,2,3,4,5,6,7,$80,$80,$88,$88,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$88,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$88,$80,$88,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
;  #] table de test: 

pointxn:
	move.b	(a6)+,d0
	move.b	.table_point(pc,d0),(a1)+
	ble.s	.error_size
	move.b	(a6),d3
	move.b	.table_point(pc,d3),d3
	neg.b	d3
	bvs	general_patok
	bne.s	.scaled
.error_size:
	bra	Err_szexp
.scaled:
	addq	#1,a6
	bra	scalexn
;  #[ table de test:
.table_point:
	dc.b	0,0,0,0,0,0,0,0,0,$80,$80,0,0,$80,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	$80,0,0,0,0,0,0,0,0,$80,255,0,$80,$80,$80,$80
	dc.b	0,0,0,0,0,0,0,0,0,0,0,$80,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,TOKENL,0,0,0
	dc.b	0,0,0,TOKENW,0,0,0,TOKENW,0,0,0,0,0,$80,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,TOKENL,0,0,0
	dc.b	0,0,0,TOKENW,0,0,0,TOKENW,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;  #] table de test: 


scalexn:
	move.b	1(a6),d0
	cmp.b	#',',d0
	beq.s	.good
	cmp.b	#')',d0
	beq.s	.good
	cmp.b	#']',d0
	bne	gotoend_in_op		;d0*x : *x = commentaire si pas suivi d'un des 3
.good:
	move.b	(a6)+,d0
	cmp.b	#'4',d0
	beq.s	.etoile4
	cmp.b	#'2',d0
	beq.s	.etoile2
	cmp.b	#'8',d0
	beq.s	.etoile8
	cmp.b	#'1',d0
	bne	gotoend_in_op		;x<>1248 => commentaire idem
.etoile1:
	moveq	#TOKENSC1,d0
	bra	nomaj
.etoile4:
	moveq	#TOKENSC4,d0
	bra	nomaj
.etoile2:
	moveq	#TOKENSC2,d0
	bra	nomaj
.etoile8:
	moveq	#TOKENSC8,d0
	bra	nomaj

tstccr:
	cmp.b	#'c',(a6)
	beq.s	.maj_cc
	cmp.b	#'C',(a6)
	bne	nomaj
.maj_cc:
	cmp.b	#'r',1(a6)
	beq.s	.maj_ccr
	cmp.b	#'R',1(a6)
	bne	nomaj
.maj_ccr:
	cmp.b	#',',2(a6)
	beq.s	.good
	cmp.b	#32,2(a6)
	bgt	nomaj
.good:	move.b	#TOKENCCR,(a1)+
	addq	#2,a6
	bra	general_patok

tstusp:
	cmp.b	#'s',(a6)
	beq.s	.maj_us
	cmp.b	#'S',(a6)
	bne	nomaj
.maj_us:
	cmp.b	#'p',1(a6)
	beq.s	.maj_usp
	cmp.b	#'P',1(a6)
	bne	nomaj
.maj_usp:
	cmp.b	#',',2(a6)
	beq.s	.good
	cmp.b	#32,2(a6)
	bgt	nomaj
.good:	move.b	#TOKENUSP,(a1)+
	addq	#2,a6
	bra	general_patok

toomany3:
	bra	Err_2manyoper


;	 #] operandes: 

;	 #[ fin de ligne:

cr_loop:
	addq	#1,a6
	addq	#1,ADDLNB			;on saute une ligne: d7++
	bra.s	cr_encountered

gotoend_in_op:
	tst.l	BRACKETPARENT
	beq.s	gotoend
level_error2:
	tst	BRACKETPARENT
	bne	Err_0parent
	bra	Err_unbal_bracket

cr:
	tst.l	BRACKETPARENT
	bne.s	level_error2
	st	(a1)
	move.l	a1,LINE_tokend(a4)
	move	d1,LINE_eval(a4)
	addq.b	#1,CHAMPS
	bmi.s	toomany3

cr_encountered:
	cmp.b	#10,(a6)+
	bne.s	.other_case
	move.b	(a6),d0
	move.b	cr_terminator_table(pc,d0),d1	;0 => caractere non saute
	bne.s	.skip_line
	rts
.other_case:
	move.b	-(a6),d0
	move.b	cr_terminator_table(pc,d0),d1	;0 => caractere non saute
	bne.s	.skip_line
	rts
.skip_line:			;a6 pointe sur l'octet qui pose probleme

; cas le plus courant: un nouveau Cr
	bmi.s	cr_loop				;ff => cr

; cas moins courant: une ligne entierement en commentaire 1 => * et ; 
	subq.b	#1,d1
	bne.s	Null				;2 => 0 (ou lf imprevu)
skip_line:
	addq	#1,ADDLNB			;on saute une ligne: d7++
gotoend:	moveq	#13,d2
.gotoend:
	REPT	17
	cmp.b	(a6)+,d2
	bcc.s	.exit
	ENDR
	bra.s	.gotoend
.exit:
	beq.s	cr_encountered
	move.b	-1(a6),d0
	move.b	cr_terminator_table(pc,d0),d1
	beq.s	.gotoend
	bmi	lf_encountered
Null:
	moveq	#0,d0
	rts

;  #[ table de test:
cr_terminator_table:
	dc.b	2,0,0,0,0,0,0,0,0,0,254,0,0,255,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;  #] table de test: 

lf_loop:
	addq	#1,a6
	addq	#1,ADDLNB			;on saute une ligne: d7++
lf_encountered:
	move.b	(a6),d0
	move.b	.terminator_table(pc,d0),d1	;0 => caractere non saute
	bne.s	.skip_line
	rts
.skip_line:			;a6 pointe sur l'octet qui pose probleme

; cas le plus courant: un nouveau Lf
	bmi.s	lf_loop				;ff => Lf

; cas moins courant: une ligne entierement en commentaire 1 => * et ; 
	subq.b	#1,d1
	bne.s	.Null			;2 => 0 (ou lf imprevu)
	addq	#1,ADDLNB			;on saute une ligne: d7+=1
	bra	gotoend
.Null:
	moveq	#0,d0
	rts

;  #[ table de test:
.terminator_table:
	dc.b	2,0,0,0,0,0,0,0,0,0,255,0,0,2,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;  #] table de test: 

;	 #] fin de ligne: 

;	 #[ erreurs:
Error_lunexp_eosrc:
	moveq	#unexp_eosrc_errno,d2
	movem.l	d0-d1/a0/a3-a4,-(sp)
	neg.w	d2
	lea	premsg,a0
	clr.w	MSG_flags(a0)
	move.w	d2,MSG_no(a0)
	move.l	CurModPtr,MSG_mod(a0)
	move.l	CurLNb,MSG_lnb(a0)
	add.l	ADDLNB,MSG_lnb(a0)
	move.l	CurLPtr,MSG_ln(a0)
	jsr	OutMsg
	movem.l	(sp)+,d0-d1/a0/a3-a4
	addq	#4,sp
	bra	EndAsm

Err_lt32:	moveq	#illchar_lt32_errno,d2
	bra.s	LineError
Err_gt127:
	moveq	#illchar_gt127_errno,d2
	bra.s	LineError
Err_illopcode:
	moveq	#illchar_opcode_errno,d2
	bra.s	LineError
Err_illlabel:
	moveq	#illchar_label_errno,d2
	bra.s	LineError
Err_szexp:
	moveq	#sz_exp_errno,d2
	bra.s	LineError
Err_2manyoper:
	moveq	#oper_2many_errno,d2
	bra.s	LineError
Err_unbalquote:
	moveq	#unbal_quote_errno,d2
	bra.s	LineError
Err_0parent:
	clr	BRACKETPARENT
Err_unbal_parent:
	moveq	#unbal_parent_errno,d2
	bra.s	LineError
Err_unbal_bracket:
	moveq	#unbal_bracket_errno,d2
;	bra.s	LineError
LineError:
	movem.l	d0-d1/a3-a4,-(sp)
	neg.w	d2
	lea	premsg,a0
	move.w	#MSG_CORR,MSG_flags(a0)
	move.w	d2,MSG_no(a0)
	clr.w	MSG_len(a0)
	move.l	CurModPtr,MSG_mod(a0)
	move.l	CurLNb,MSG_lnb(a0)
	move.l	CurLPtr,MSG_ln(a0)
	jsr	OutMsg
	movem.l	(sp)+,d0-d1/a3-a4
	moveq	#-1,CHAMPS
	bra	gotoend

Warn_comment:
	movem.l	d0/a0,-(sp)
	moveq	#comment_spur_warnno,d0
;	bra.s	LineWarn
LineWarn:	neg.w	d0
	lea	premsg,a0
	move.w	#MSG_WARN,MSG_flags(a0)
	move.w	d0,MSG_no(a0)
	move.l	CurModPtr,MSG_mod(a0)
	move.l	CurLNb,MSG_lnb(a0)
	move.l	CurLPtr,MSG_ln(a0)
	jsr	OutMsg
	movem.l	(sp)+,d0/a0
	rts

;	 #] erreurs: 

;	 #[ misc:
;In:
;a0=name @
;d0=name length
SetXdef:	movem.l	d0-a4,-(sp)
	move.l	CurLNb,-(sp)
	subq.l	#1,ADDLNB
	add.l	ADDLNB,CurLNb	;crade mais tant pis ...

	move.l	a0,a4
	move.w	d0,d4
	tst.w	OutType+2
	bne.s	.link
	jsr	Warnxdef_spur	;skip XDEF if executable
	bra	.end
.rloc:	jsr	Errlocal_forb
	bra	.end

.link:	tst.b	loc_flag
	bne.s	.rloc
	move.l	xdefs_ptr,d0
	bne.s	.nofirst
	jsr	alloc_xef_block
	move.l	d0,xdefs_ptr
.nofirst: move.l	d0,a2		;a2=pointeur sur 1er XREFL

	tst.w	VarRamFlg
	bne.s	.alloc
.fast:	move.w	VARL_nb(a2),d0
	cmp.w	#XREFS_PER_BLOCK,d0
	bne.s	.more
	tst.l	VARL_next(a2)
	beq.s	.no_next
	move.l	VARL_next(a2),a2
	bra.s	.fast

.rvarram: bra	Errxdef_ram
.rnamram: bra	Errname_ram

.alloc:	move.l	d4,d0		;alloc name
	bsr	AllocString
	beq.s	.rnamram
	move.l	a4,a0		;copy from token to alloc
	move.l	d0,a4		;new name @
	move.l	a4,a1
	move.w	d4,d0
	STRNCPY
	bra.s	.fast

.no_next: jsr	alloc_xef_block	;block plein -> creer suivant
	move.l	d0,VARL_next(a2)
	move.l	d0,a2

.more:	move.w	VARL_nb(a2),d0
	move.l	VARL_block(a2),a1
	add.w	d0,d0
	add.w	d0,d0
	lea	0(a1,d0.w),a1	;adresse ou stocker pointeur sur xdef_struct

	bsr	VarAlloc
	beq.s	.rvarram
	move.l	d0,a0
	move.l	a0,(a1)		;stockage de l'XEF
	addq.w	#1,VARL_nb(a2)
.nxt:	move.l	a4,VAR_start(a0)
	move.w	d4,VAR_len(a0)
	clr.l	VAR_value(a0)
	move.w	CurModNb+2,VAR_mod(a0)	;module courant
	move.w	#VAR_XDEF<<8,VAR_type(a0)
	move.l	CurLNb,VAR_lnb(a0)
	addq.l	#1,XdefNb

.end:	move.l	(sp)+,CurLNb
	movem.l	(sp)+,d0-a4
	rts
;	 #] misc:

;  #] Analyse line:
	BSS
	even
;  #[ BSS:
loc_flag:	ds.b	1
opcode_size:
	ds.b	1
	even
OpCode:		ds.w	1	;opcode (en word) lui-meme
OpSize:		ds.w	1	;taille indiquee
parent0_cnt:	ds.w	1
length_variable:	ds.w	1	;leave_here
;	 #[ Analyse stuff:
	even
start_variable:	ds.l	1
variable:		ds.b	256
opcode:		ds.b	256
FlshBuf:
FieldsPtr:	ds.l	1
;	 #] Analyse stuff: 
;  #] BSS: 
	section	TEXT
