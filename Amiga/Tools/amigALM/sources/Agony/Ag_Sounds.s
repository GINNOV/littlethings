
***************************************************************************
*                                                                         *
*                                                                         *
*				            *
*		   A  G  O  N  Y		            *
*                          =================            	            *
*                                                                         *
*                                                                         *
*                                                                         *
*                           SOUNDS  MODULE                                *
*                           --------------                                *
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



; PLAY DMA SOUNDS
; ---------------


                  move	Sound0_b(D),d0       ;canal 0
	bmi	Sound0_End
	st	Sound0_b(D)
	lea	Sound_Dat,a0
                  move.l	a0,d1
	lsl	#3,d0
	add	d0,a0
                  add.l	(a0)+,d1
	move.l	d1,Aud0lc(C)
	move	(a0),d0
	lsr	#1,d0
	move	d0,Aud0len(C)
	clr	Sound0_Int_Step(D)
	move	Sound0_Vol(D),Aud0vol(C)
	move	#$8001,Dmacon(C)
	move	#%10000000,Intreq(C)
	move	#%1000000010000000,Intena(C)
Sound0_End



* DMA SOUND CTRL
* --------------



                  move    Sound0(D),d0
	bmi	.no_cmd
	st	Sound0(D)
	move	d0,Sound0_b(D)
	move	#$0001,Dmacon(C)
                 	clr	Aud0vol(C)
.no_cmd




