
WBSpr_CLI	=	$AC
WBSpr_MSGPORT	=	$5C

WBSsm_ARGLIST	=	$24
WBSsm_NUMARGS	=	$1C

WBSFindTask	=	-294
WBSWaitPort	=	-384
WBSGetMsg	=	-372
WBSReplyMsg	=	-378

***********************************************************************


StartUp
	movem.l	d0/a0,-(sp)	;Args auf den Stack
	sub.l	a1,a1		;uns selbst
	move.l	4.w,a6	;Execbase nach a6
	jsr	WBSFindTask(a6)	;suchen

	sub.l	a1,a1		;keine WB_MSG !
	move.l	d0,a2		;nach a2
	tst.l	WBSpr_CLI(a2)	;kommen wir vom CLI ?
	bne.s	kaaa		;ja,dann weiter !!!

	lea	WBSpr_MSGPORT(a2),a0	;MsgPort nach a0
	jsr	WBSWaitPort(a6)		;warten
	lea	WBSpr_MSGPORT(a2),a0
	jsr	WBSGetMsg(a6)
	move.l	d0,a1			;WB_Startup nach a1 retten

	move.l	WBSsm_NUMARGS(a1),d0	;Anzahl nach d0
	move.l	WBSsm_ARGLIST(a1),a0	;Liste nach a0
	moveq	#-1,d1			;<>0 bed. wir kommen von WB !
	addq.w	#8,sp			;Stack korrigieren
	bra.s	laaa
kaaa
	movem.l	(sp)+,d0/a0		;Args vom Stack
	moveq	#0,d1			;=0 bed. wir kommen vom CLI !
laaa
	movem.l	a1/a6,-(sp)		;retten
	jsr	naaa			;Hauptprogramm abarbeiten
	movem.l	(sp)+,a1/a6		;wieder vom Stack

	move.l	a1,d1			;kamen wir von WB ?
	beq.s	maaa			;nein,dann fertig !
	move.l	d0,d2			;Returncode retten
	jsr	WBSReplyMsg(a6)		;WB_MSG zurück !
	move.l	d2,d0			;Returncode wieder nach d0
maaa
	rts				;und fertig !
naaa
