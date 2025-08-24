
***************************************************************************
*                                                                         *
*                                                                         *
*				            *
*		   A  G  O  N  Y		            *
*                          =================            	            *
*                                                                         *
*                                                                         *
*                                                                         *
*                            FRONT  SCROLL                                *
*                            -------------                                *
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



* PAUSE2 & STOP2 CTRL
* -------------------


                  move	Front_Shift(D),d0
                  beq	.no_p
	cmp	#15,d0
                  beq	.no_p
	cmp	#31,d0
                  beq	.no_p
	tst     Stop(D)
	bne	.ok
	tst	Prg_Pause(D)
	bne	.no_s
	cmp	#2,Curent_Spell(D)
	beq     .no_s
.ok
	move	Stop(D),Stop2(D)
.no_s
	move	Pause(D),Pause2(D)
.no_p
	tst	Stop2(D)
	bne	Front_End



* PALETTE
* -------


                  tst	Front_Pal_Count(D)
	bne	No_New_Palette
	tst	Front_Phase(D)
	bne	No_New_Palette

	st      Refresh_Pal+1(D)
	add.l	#6*7*2,Front_Pal_Ptr(D)
No_New_Palette



* TEST PHASE
* ----------


                  move.l	#32*64+2,d2
	move.l	#44*192,d3

                  move	Front_Phase(D),d0
	beq	Front_Blit_End
                  subq	#1,d0
	beq	Front_Blit_End
                  subq	#1,d0
	cmp	#12,d0
	bge	Front_Blit_End
	btst	#0,d0
	bne     Char_Copy



* CHAR INIT
* ---------


	move.l	Front_Read_Ptr(D),a0
	moveq	#0,d1
	move.b	(a0)+,d1	* d1 curent char
	add	d1,d1
	add	d1,d1
	lea	X384(D),a1
	move.l	(a1,d1.w),d1
	add.l	#Front_Charset,d1
	move.l	d1,Bltapt(C)
	lea	Front_Table(D),a1
                  add	d0,a1	* a1 read table ptr
	moveq	#0,d0
	move	(a1),d0
	move	d0,Safe_Dest_off(D)
	add.l	Cur_Front_Build(D),d0
	move.l	d0,Bltdpt(C)
	move.l	d0,Safe_Dest_Ptr(D)
                  move.l	#$00000028,Bltamod(C)
	move.l	#$ffffffff,Bltafwm(C)
	move.l	#$09f00000,Bltcon0(C)
	move	d2,Bltsize(C)
	WAIT_BLIT
	add.l	d3,d0
	move.l	d0,Bltdpt(C)
	move	d2,Bltsize(C)
	WAIT_BLIT
	add.l	d3,d0
	move.l	d0,Bltdpt(C)
	move	d2,Bltsize(C)
	WAIT_BLIT

	moveq	#0,d1
	move.b	(a0),d1	* d1 curent char
	add	d1,d1
	add	d1,d1
	lea	X384(D),a1
	move.l	(a1,d1.w),d1
	add.l	#Front_Charset,d1
	move.l	d1,Safe_Src_Ptr(D)
	move.l	d1,Bltapt(C)
	add.l	#128,d1
	move.l	d1,Bltbpt(C)
	add.l	#128,d1
	move.l	d1,Bltcpt(C)
	lea	Front_Mask(D),a1
	move.l	a1,Bltdpt(C)
	move	#$0ffe,Bltcon0(C)
	clr.l	Bltamod(C)
	clr.l	Bltcmod(C)
	move	d2,Bltsize(C)
	WAIT_BLIT

	bra	Front_Blit_End



* CHAR COPY
* ---------


Char_Copy
	move.l	#$ffffffff,Bltafwm(C)
                  move.l	#$00000028,Bltamod(C)
                  move.l	#$00280000,Bltcmod(C)
	move.l	#$0ff20000,Bltcon0(C)
	move.l	Safe_Dest_Ptr(D),d4
	move.l	d4,d1
	move.l	d4,Bltcpt(C)
	move.l	d4,Bltdpt(C)
	lea	Front_Mask(D),a1
	move.l	a1,Bltbpt(C)
	move.l	Safe_Src_Ptr(D),Bltapt(C)
	move	d2,Bltsize(C)
	WAIT_BLIT
	move.l	a1,Bltbpt(C)
	add.l	d3,d4
	move.l	d4,Bltcpt(C)
	move.l	d4,Bltdpt(C)
	move	d2,Bltsize(C)
	WAIT_BLIT
	move.l	a1,Bltbpt(C)
	add.l	d3,d4
	move.l	d4,Bltcpt(C)
	move.l	d4,Bltdpt(C)
	move	d2,Bltsize(C)
	WAIT_BLIT

	move	#$09f0,Bltcon0(C)
                  move.l	#$00280028,Bltamod(C)
	moveq	#0,d0
                  move	Safe_Dest_Off(D),d0
	add.l	Cur_Front_Build(D),d0
	move.l	d0,Bltdpt(C)
	move.l	d1,Bltapt(C)
	move.l	d1,d4
	move	d2,Bltsize(C)
	WAIT_BLIT
	add.l   d3,d0
	add.l   d3,d1
	move.l	d0,Bltdpt(C)
	move.l	d1,Bltapt(C)
	move	d2,Bltsize(C)
	WAIT_BLIT
	add.l   d3,d0
	add.l   d3,d1
	move.l	d0,Bltdpt(C)
	move.l	d1,Bltapt(C)
	move	d2,Bltsize(C)
	WAIT_BLIT

	moveq	#0,d0            	* cpy in restore screen
                  move	Safe_Dest_Off(D),d0
	add.l	Rest_Screen_Ptr(D),d0
	move.l	d0,Bltdpt(C)
	move.l	d4,Bltapt(C)
	move	d2,Bltsize(C)
	WAIT_BLIT
	add.l   d3,d0
	add.l   d3,d4
	move.l	d0,Bltdpt(C)
	move.l	d4,Bltapt(C)
	move	d2,Bltsize(C)
	WAIT_BLIT
	add.l   d3,d0
	add.l   d3,d4
	move.l	d0,Bltdpt(C)
	move.l	d4,Bltapt(C)
	move	d2,Bltsize(C)
	WAIT_BLIT

	addq.l	#2,Front_Read_Ptr(D)
Front_Blit_End



* FRONT SCROLL CONTROL
* --------------------


	addq    #1,Front_Phase(D)
	move	Front_Phase(D),d0
	moveq	#16,d1
	sub	d0,d1
	add	d1,d1
	move	d1,Front_Shift(D)
	clr	Vdo_S_Inc(D)
	cmp	#16,d0
	bne	Front_End
	move	#32,Front_Shift(D)
                  addq	#1,Front_Pal_Count(D)
                  cmp	#10,Front_Pal_Count(D)
	bne     Front_End
                  clr	Front_Pal_Count(D)
Front_End



