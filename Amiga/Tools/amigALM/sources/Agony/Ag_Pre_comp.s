
***************************************************************************
*                                                                         *
*                                                                         *
*				            *
*		   A  G  O  N  Y		            *
*                          =================            	            *
*                                                                         *
*                                                                         *
*                                                                         *
*                          PRECOMPUTE MODULE                              *
*                          -----------------                              *
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



* BUILD 8 COL. SPR. MASK
* ----------------------


	clr.l	Bltcmod(C)
	clr.l	Bltamod(C)
	moveq	#-1,d0
	move.l	d0,Bltafwm(C)
	move.l	#$0ffe0000,Bltcon0(C)

	lea	Sprites_Mask,a2
	lea	Sprites_Struct(D),a0
	move	#((_Spr_Struct_End-_Sprites_Struct)/26)-1,d2
	move	d2,d4
Spr_Mask_Loop
	lea	2+4*3(a0),a0
	move.l	(a0)+,d0
	sub	#8,d0
	bpl	.do_mask
	lea	8(a0),a0
	bra	.no_mask
.do_mask
                  beq	.spr0
	subq	#1,d0
	beq	.spr1
	subq	#1,d0
	beq	.spr2
				* 64 x 64
	move.l	(a0)+,a1
	add.l	#Sprites_Bitmap,a1
	move.l	a1,Bltapt(C)
	lea     512(a1),a1
	move.l	a1,Bltbpt(C)
	lea     512(a1),a1
	move.l	a1,Bltcpt(C)
	move.l	a2,BltDpt(C)
	move.l	a2,(a0)+
                  lea	512(a2),a2
	move	#(64*64)+4,Bltsize(C)
	bra	.no_mask
.spr0				* 32 x 32
	move.l	(a0)+,a1
	add.l	#Sprites_Bitmap,a1
	move.l	a1,Bltapt(C)
	lea     128(a1),a1
	move.l	a1,Bltbpt(C)
	lea     128(a1),a1
	move.l	a1,Bltcpt(C)
	move.l	a2,BltDpt(C)
	move.l	a2,(a0)+
                  lea	128(a2),a2
	move	#(32*64)+2,Bltsize(C)
	bra	.no_mask
.spr1				* 64 x 32
	move.l	(a0)+,a1
	add.l	#Sprites_Bitmap,a1
	move.l	a1,Bltapt(C)
	lea     256(a1),a1
	move.l	a1,Bltbpt(C)
	lea     256(a1),a1
	move.l	a1,Bltcpt(C)
	move.l	a2,BltDpt(C)
	move.l	a2,(a0)+
                  lea	256(a2),a2
	move	#(32*64)+4,Bltsize(C)
	bra	.no_mask
.spr2                     		* 32 x 64
	move.l	(a0)+,a1
	add.l	#Sprites_Bitmap,a1
	move.l	a1,Bltapt(C)
	lea     256(a1),a1
	move.l	a1,Bltbpt(C)
	lea     256(a1),a1
	move.l	a1,Bltcpt(C)
	move.l	a2,BltDpt(C)
	move.l	a2,(a0)+
                  lea	256(a2),a2
	move	#(64*64)+2,Bltsize(C)
.no_mask
	dbra	d2,Spr_Mask_Loop



* TRANSFORM SPRITES STRUCT
* ------------------------


	lea	Sprites_Struct(D),a0
                  cmp.l	#1024,2(a0)
	bgt	Precomp_End

	lea	Mask_Blit_Rout_Ptr(D),a1
	lea	H_C_Blit_Rout_Ptr(D),a2
	lea	V_C_Blit_Rout_Ptr(D),a3
	lea	Blit_Routines_Ptr(D),a4
	move.l	#Sprites_Bitmap,d3
Spr_Str_Loop
	addq	#2,a0
	move	2(a0),d0
	add	d0,d0
	add	d0,d0
                  move.l	(a1,d0.w),(a0)+
                  move.l	(a2,d0.w),(a0)+
                  move.l	(a3,d0.w),(a0)+
                  move.l	(a4,d0.w),(a0)+
	add.l	d3,(a0)+
	addq	#4,a0

	dbra	d4,Spr_Str_Loop

Precomp_End
