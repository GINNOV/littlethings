		include	"header:bullets.i"
                include	"header:displist.i"
                include "header:view.i"
                include	"header:iff.i"
		include	"header:wave.i"
                
*-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
*								*
* FUNCTION: MoveAlienMissile					*
* FUNCTION: MoveMissile						*
* FUNCTION: MovePatternedMissile				*
*								*
*								*
*-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

		xref	_RemQue,_Move_Sprite
		xref	_SetUpHitBox,_SmallBlit,_CopyDownDLE

		xdef	_MoveAlienMissile,_MoveMissile,_MovePatternedMissile
                
*-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-*
*						*
* FUNCTION int MoveAlienMissile(BUL_PMissile)	*
*						*
* ACTION:					*
*   Moves an enemy missile in its direction,  	*
*   checks for collision, and to see if its	*
*   off-screen					*
*						*
*-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-*

_MoveAlienMissile:
10$	equ	0
20$	reg	a2/a3/a4
		move.l	4(sp),a0
		movem.l	20$,-(sp)
;  DLE=param->DLE;			/* For Speed */
		move.l	a0,a4
		move.l	MPRM_dle(a4),a2
;  Sprite=param->Shape.Bob;
		move.l	MPRM_shape(a4),a3
;
;  CopyDownDLE(DLE);
		lea.l	DLE_newx(a2),a0		* CopyDownDLE
                lea.l	DLE_oldx(a2),a1
		move.l	(a0)+,(a1)+	;X
                move.w	(a0)+,(a1)+	;Class	extra byte for word
                move.l	(a0)+,(a1)+	;Image
;
		move.b	#CLS_Bob,DLE_newclass(a2) * say draw new image
                movea.l	a3,a0			* Get SpriteImage
		move.w	MPRM_powimage(a4),d0	* Get CurImage
		add.w	#1,MPRM_powimage(a4)	* increment frame no
		asl.w	#2,d0			* New image is that frame
		ext.l	d0
		add.l	d0,a0
		move.l	SPRI_frames(a0),DLE_newimage(a2)
;
;  SetUpHitBox(&DLE->HitBox,DLE->NewImage);
		lea.l	DLE_hitbox(a2),a0	* Get HitBox
                move.l	DLE_newimage(a2),a1	* Get image
                clr.l	(a0)+			* Corner TL corner
		move.w	GOBJ_width(a1),(a0)+	* Set BR corner
                move.w	GOBJ_height(a1),(a0)
		subi.w	#1,(a0)
                subi.w	#1,-(a0)
;
;  if(param->PowImage.CurImage==Sprite->Count)
;     param->PowImage.CurImage=0;
		move.w	MPRM_powimage(a4),d0
		ext.l	d0
		move.l	#0,d1
		move.b	SPRI_count(a3),d1
		cmp.l	d1,d0
		bne	30$
		clr.w	MPRM_powimage(a4)
;  DLE->NewX+=param->Dx;
30$
		move.w	MPRM_dx(a4),d0
		add.w	d0,DLE_newx(a2)
;  DLE->NewY+=param->Dy;
		move.w	MPRM_dy(a4),d0
		add.w	d0,DLE_newy(a2)
;
;  if (DLE->NewX<-16 || DLE->NewX>VIEW_WIDTH ||
;      DLE->NewY<-16 || DLE->NewY>VIEW_HEIGHT) /* then he's offs
;creen */
;      DLE->flags|=DLE_collision;	/* So kill him */
		cmp.w	#-16,DLE_newx(a2)
		blt	50$
		cmp.w	#320,DLE_newx(a2)
		bgt	50$
		cmp.w	#-16,DLE_newy(a2)
		blt	50$
		cmp.w	#170,DLE_newy(a2)
		ble	40$
50$
	bset.b	#3,DLE_flags+3(a2)
;
;  if(DLE->flags&DLE_collision) {	/* I'm dead */
40$
		btst.b	#3,DLE_flags+3(a2)
		beq	60$
;    DLE->NewClass=CLS_none;		/* Erase bullet */
		clr.b	DLE_newclass(a2)
;    StopCollisionCheckingOn(DLE);
		move.l	a2,-(sp)
		jsr	_RemQue
		add.w	#4,sp
;    DisplaySoftBob(DLE);
		tst.b	DLE_oldclass(a2)
		beq	70$
		move.w	DLE_oldy(a2),d0
		ext.l	d0
		move.l	d0,-(sp)
		move.w	DLE_oldx(a2),d0
		ext.l	d0
		move.l	d0,-(sp)
		move.l	DLE_oldimage(a2),-(sp)
		jsr	_SmallBlit
		lea	12(sp),sp
70$
;    (*param->Count)++;			/* Give Aliens bullet back */
		move.l	MPRM_count(a4),a1
		add.b	#1,(a1)
;    return 1;
		move.l	#1,d0
90$
		movem.l	(sp)+,20$
		rts
;  DisplaySoftBob(DLE);			/* Update Screen */
60$
		tst.b	DLE_oldclass(a2)
		beq	100$
		move.w	DLE_oldy(a2),d0
		ext.l	d0
		move.l	d0,-(sp)
		move.w	DLE_oldx(a2),d0
		ext.l	d0
		move.l	d0,-(sp)
		move.l	DLE_oldimage(a2),-(sp)
		jsr	_SmallBlit
		lea	12(sp),sp
100$
		move.w	DLE_newy(a2),d0
		ext.l	d0
                move.l	d0,-(sp)
		move.w	DLE_newx(a2),d0
		ext.l	d0
                move.l	d0,-(sp)
		move.l	DLE_newimage(a2),-(sp)
		jsr	_SmallBlit
		lea	12(sp),sp
;  return 0;
		move.l	#0,d0
		bra	90$
;}

*-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-*
*						*
* FUNCTION int MoveMissile(BUL_PMissile)	*
*						*
* ACTION:					*
*   Moves a player missile in its direction,  	*
*   checks for collision, and to see if its	*
*   off-screen					*
*						*
*-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-*

_MoveMissile:
10$	equ	0
20$	reg	a2/a3/a4
		move.l	4(sp),a0
		movem.l	20$,-(sp)
		move.l	a0,a4		* Get DLE
		move.l	MPRM_dle(a4),a2
		move.l	MPRM_shape(a4),a3
		lea.l	8(a3),a3	* SimpleSprite

		move.w	MPRM_dx(a4),d0	* Add x inc
		add.w	d0,DLE_newx(a2)
		move.w	MPRM_dy(a4),d0	* Add y inc
		add.w	d0,DLE_newy(a2)

		tst.w	DLE_newx(a2)	* Clip sprite
		blt	50$
		cmp.w	#320,DLE_newx(a2)
		bgt	50$
		tst.w	DLE_newy(a2)
		blt	50$
		cmp.w	#view_height,DLE_newy(a2)
		bgt	50$
40$		btst.b	#3,DLE_flags+3(a2)	* Test for collision
		beq	60$
50$		move.l	DLE_col(a2),-(sp)	* Stop collision checking
		jsr	_RemQue
		pea	0
                pea	-50
                move.l	a3,-(sp)
                jsr	_Move_Sprite
                lea.l	16(sp),sp
		move.l	MPRM_count(a4),a1	* Give bullet back
		add.b	#1,(a1)
		move.l	#1,d0			* REturn gimmesprite
90$		movem.l	(sp)+,20$
		rts
60$		move.w	DLE_newy(a2),-(sp)	* MoveSprite -50,0
                clr.w	-(sp)
                move.w	DLE_newx(a2),-(sp)
                clr.w	-(sp)
                move.l	DLE_newimage(a2),-(sp)
                jsr	_Move_Sprite
                lea.l	12(sp),sp		
		move.l	#-1,d0			* Return -1
		bra	90$

*-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-*
*						*
* FUNCTION int MovePatternedMissile		*
*				(BUL_PMissile)	*
*						*
* ACTION:					*
*   Moves a player missile in its pattern,  	*
*   checks for collision, and to see if its	*
*   off-screen					*
*						*
*-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-*

_MovePatternedMissile:
10$	equ	0
20$	reg	a2/a3/a4
		move.l	4(sp),a0
		movem.l	20$,-(sp)
		move.l	a0,a4		* Get DLE
		move.l	MPRM_dle(a4),a2
		move.l	MPRM_shape(a4),a3
		lea.l	8(a3),a3	* SimpleSprite

* Here add x and y offsets, negating x if necessary

		move.l	MPRM_target(a4),a0	* Add x inc
		move.w	ANM_xoffset(a0),d0
		btst	#3,MPRM_flags+3(a4)	* Test negate flag
		bne.s	1$
		add.w	d0,DLE_newx(a2)
		jmp	2$
1$		sub.w	d0,DLE_newx(a2)
2$		move.w	ANM_yoffset(a0),d0	* Add y inc
		add.w	d0,DLE_newy(a2)

* Here see if all iterations of the current set have expired
* if they have, move to the next set if there is one

		sub.w	#1,MPRM_timanim(a4)
                bne	3$			* if not time to change set
                lea.l	ANM_SIZE(a0),a0		* Advance a set
                move.l	a0,MPRM_target(a4)
                tst.b	ANM_count(a0)
                beq	50$
                move.w	#0,d0
                move.b	ANM_count(a0),d0
                move.w	d0,MPRM_timanim(a4)

3$		tst.w	DLE_newx(a2)	* Clip sprite
		blt	50$
		cmp.w	#320,DLE_newx(a2)
		bgt	50$
		tst.w	DLE_newy(a2)
		blt	50$
		cmp.w	#view_height,DLE_newy(a2)
		bgt	50$
40$		btst.b	#3,DLE_flags+3(a2)	* Test for collision
		beq	60$
50$		move.l	DLE_col(a2),-(sp)	* Stop collision checking
		jsr	_RemQue
		pea	0
                pea	-50
                move.l	a3,-(sp)
                jsr	_Move_Sprite
                lea.l	16(sp),sp
		move.l	MPRM_count(a4),a1	* Give bullet back
		add.b	#1,(a1)
		move.l	#1,d0			* REturn gimmesprite
90$		movem.l	(sp)+,20$
		rts
60$		move.w	DLE_newy(a2),-(sp)	* MoveSprite -50,0
                clr.w	-(sp)
                move.w	DLE_newx(a2),-(sp)
                clr.w	-(sp)
                move.l	DLE_newimage(a2),-(sp)
                jsr	_Move_Sprite
                lea.l	12(sp),sp		
		move.l	#-1,d0			* Return -1
		bra	90$

