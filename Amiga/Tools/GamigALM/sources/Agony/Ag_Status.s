
***************************************************************************
*                                                                         *
*                                                                         *
*				            *
*		   A  G  O  N  Y		            *
*                          =================            	            *
*                                                                         *
*                                                                         *
*                                                                         *
*                             STATUS LINE                                 *
*                             -----------                                 *
*                                                                         *
*                                                                         *
***************************************************************************


* by ART & MAGIC


* Artwork:        Franck Sauer
*	Marc Albinet

* Coding:	Yves Grolet
* Date:	25/06/1990
* Tab:            custom



***************************************************************************



	tst	Text_Delay(D)
	bne     No_Life_Update

* SCORE
* -----


	tst.l	Point(D)
	beq	.no_point
                  lea	Score+4,a1
	lea	Point+4(D),a2
                  move	#%0010000000000000,SR
	abcd	-(a2),-(a1)
	abcd	-(a2),-(a1)
	abcd	-(a2),-(a1)
                  lea	Extra_Life+4,a1
	lea	Point+4(D),a2
                  move	#%0010000000000000,SR
	abcd	-(a2),-(a1)
	abcd	-(a2),-(a1)
	abcd	-(a2),-(a1)
	clr.l	Point(D)
	cmp.l	#$80000,Extra_Life
	blt	.no_extra_life
	lsl     Life
	or	#1,Life
	and	#%11111,Life
	move	#12,Text_Num(D)
	move	#50,Text_Delay(D)
	clr.l	Extra_Life
.no_extra_life
	st	Refresh_Status+1(D)
.no_point
	tst	Refresh_Status(D)
	bne	.Refresh
                  tst	Text_Delay(D)
	bne	No_Life_Update
	addq	#1,Status_Delay(D)
	cmp	#20,Status_Delay(D)
	bne	No_Life_Update
	clr	Status_Delay(D)
.Refresh
	clr	Refresh_Status(D)

	move.l	Score,d5
                  cmp.l	Old_Score(D),d5
	beq	No_Score_Update
	move.l	d5,Old_Score(D)

	move	d5,d0
	and	#%1111,d0
	lsl	#4,d0
	move	d5,d1
                  and	#$f0,d1
	lsr.l	#4,d5
	move	d5,d2
	and	#$f0,d2
	lsr.l	#4,d5
	move	d5,d3
	and	#$f0,d3
	lsr	#4,d5
	move	d5,d4
	and	#$f0,d4
	lsr	#4,d5
	and	#$f0,d5

                  lea	Status_Screen+38(D),a0
	lea	Status_Digit(D),a1

	lea	(a1,d5.w),a2
	moveq	#15,d6
.Char0_Loop
	move.b	(a2)+,(a0)
	lea	76(a0),a0
                  dbra	d6,.Char0_Loop

                  lea	1-1216(a0),a0
	lea	(a1,d4.w),a2
	moveq	#15,d6
.Char1_Loop
	move.b	(a2)+,(a0)
	lea	76(a0),a0
                  dbra	d6,.Char1_Loop

                  lea	1-1216(a0),a0
	lea	(a1,d3.w),a2
	moveq	#15,d6
.Char2_Loop
	move.b	(a2)+,(a0)
	lea	76(a0),a0
                  dbra	d6,.Char2_Loop

                  lea	1-1216(a0),a0
	lea	(a1,d2.w),a2
	moveq	#15,d6
.Char3_Loop
	move.b	(a2)+,(a0)
	lea	76(a0),a0
                  dbra	d6,.Char3_Loop

                  lea	1-1216(a0),a0
	lea	(a1,d1.w),a2
	moveq	#15,d6
.Char4_Loop
	move.b	(a2)+,(a0)
	lea	76(a0),a0
                  dbra	d6,.Char4_Loop

                  lea	1-1216(a0),a0
	lea	(a1,d0.w),a2
	moveq	#15,d6
.Char5_Loop
	move.b	(a2)+,(a0)
	lea	76(a0),a0
                  dbra	d6,.Char5_Loop

No_Score_Update



* SPELL TIME
* ----------


	move	Spell_Time(D),d5
                  cmp	Old_Spell_Time(D),d5
	beq	No_Stime_Update
	move	d5,Old_Spell_Time(D)

	move	d5,d0
	and	#%1111,d0
	lsl	#4,d0
                  and	#$f0,d5

                  lea	Status_Screen+12(D),a0
	lea	Status_Digit(D),a1

	lea	(a1,d5.w),a2
	moveq	#15,d6
.Char0_Loop
	move.b	(a2)+,(a0)
	lea	76(a0),a0
                  dbra	d6,.Char0_Loop

                  lea	1-1216(a0),a0
	lea	(a1,d0.w),a2
	moveq	#15,d6
.Char1_Loop
	move.b	(a2)+,(a0)
	lea	76(a0),a0
                  dbra	d6,.Char1_Loop


No_Stime_Update



* LIFE
* ----


	move	Life,d5
                  cmp	Old_Life(D),d5
	beq	No_Life_Update
	move	d5,Old_Life(D)

	move	#$2b*16,d0
	btst	#0,d5
	beq	.No0
	move	#160,d0
.No0
	move	#$2b*16,d1
	btst	#1,d5
	beq	.No1
	move	#160,d1
.No1
	move	#$2b*16,d2
	btst	#2,d5
	beq	.No2
	move	#160,d2
.No2
	move	#$2b*16,d3
	btst	#3,d5
	beq	.No3
	move	#160,d3
.No3
	move	#$2b*16,d4
	btst	#4,d5
	beq	.No4
	move	#160,d4
.No4
                  lea	Status_Screen+68(D),a0
	lea	Status_Digit(D),a1

	lea	(a1,d4.w),a2
	moveq	#15,d6
.Char0_Loop
	move.b	(a2)+,(a0)
	lea	76(a0),a0
                  dbra	d6,.Char0_Loop

                  lea	1-1216(a0),a0
	lea	(a1,d3.w),a2
	moveq	#15,d6
.Char1_Loop
	move.b	(a2)+,(a0)
	lea	76(a0),a0
                  dbra	d6,.Char1_Loop

                  lea	1-1216(a0),a0
	lea	(a1,d2.w),a2
	moveq	#15,d6
.Char2_Loop
	move.b	(a2)+,(a0)
	lea	76(a0),a0
                  dbra	d6,.Char2_Loop

                  lea	1-1216(a0),a0
	lea	(a1,d1.w),a2
	moveq	#15,d6
.Char3_Loop
	move.b	(a2)+,(a0)
	lea	76(a0),a0
                  dbra	d6,.Char3_Loop

                  lea	1-1216(a0),a0
	lea	(a1,d0.w),a2
	moveq	#15,d6
.Char4_Loop
	move.b	(a2)+,(a0)
	lea	76(a0),a0
                  dbra	d6,.Char4_Loop


No_Life_Update



* TEXT DISPLAY
* ------------


	tst	Text_Delay(D)
	beq     No_Text_Display

	subq	#1,Text_Delay(D)

	move	Text_Num(D),d0
	beq	No_Text_Display
	cmp	Old_Text_Num(D),d0
	beq     No_Text_Display
	move	d0,Old_Text_Num(D)
	clr	Text_Num(D)

	lea	Status_Screen(D),a1
	move	#76*18/4,d1
.clr_loop
	clr.l	(a1)+
	dbra	d1,.clr_loop

	subq	#1,d0
	add	d0,d0
	lea	Text_Dat(D),a0
	add	(a0,d0.w),a0
	lea	Status_Screen+10(D),a1
.Sentence_Loop
	moveq	#0,d0
	move.b	(a0)+,d0
	bmi     No_Text_Display
	lsl	#4,d0
	lea	Status_Digit(D),a2
	add	d0,a2
	moveq	#15,d0
.Char_Loop
	move.b	(a2)+,(a1)
	lea	76(a1),a1
	dbra	d0,.Char_Loop
	Sub	#76*16-1,a1

	bra	.Sentence_Loop
No_Text_Display
	cmp	#1,Text_Delay(D)
	bne	.No_Clr

	lea	Status_Screen(D),a1
	move	#76*18/4,d1
.clr_loop
	clr.l	(a1)+
	dbra	d1,.clr_loop
	st	Old_Score(D)
	st	Old_Spell_Time(D)
	st	Old_life(D)
	st	Refresh_Status(D)
	st	Old_Text_Num(D)
.No_Clr



