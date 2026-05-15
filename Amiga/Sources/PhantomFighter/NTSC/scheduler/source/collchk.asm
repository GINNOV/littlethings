
		include	"header:displist.i"
                include	"header:collision.i"
		xdef	_CollisionCheck
                xref	_DSP_GoodCollisions
		xdef	_CollisionCheckSprites
                xref	_DSP_SpriteList

CollChkRegs:	reg	d2-d5/a2-a6

;- - - - - - - - - - - - CollisionCheck - - - - - - - - - - - - - - - - -
;
; MECHANISM
;    CollisionCheck()
;
; ACTION
;   This compares all Good DLEs hitboxs with all those in the
;   DSP_GoodCollisions queue. If they hit, then the Collision
;   function is called and the routine exits
;
; BUGS
;   None
;
;- - - - - Billy Newport  - - - - - - - - - - - - - - - - - - - - - - - -

_CollisionCheck:
		move.l	_DSP_DisplayList,DLEQ
                move.l	_DSP_GoodCollisions,COLQ
		jmp	CollisionCheck

;- - - - - - - - - - - - CollisionCheckSprites - - - - - - - - - - - - -
;
; MECHANISM
;    CollisionCheckSprites(Q)
;
; ACTION
;   This compares all Sprites DLEs hitboxs with all those in the
;   queue passed. If they hit, then the Collision
;   function is called and the routine exits
;
; BUGS
;   None
;
;- - - - - Billy Newport  - - - - - - - - - - - - - - - - - - - - - - - -

_CollisionCheckSprites:
		move.l	4(sp),DLEQ
                move.l	_DSP_SpriteList,COLQ
                jmp	CollisionCheck                

		dseg
COLQ:		dc.l	0
DLEQ:		dc.l	0
		cseg
CollisionCheck:
		movem.l	CollChkRegs,-(sp)

		movea.l	DLEQ,a5	* Get Start of Q
LOOP_DISP:	move.l	(a5),a5			* Get flink
		cmp.l	DLEQ,a5	* End of Q ?
                bne	10$                
		movem.l	(sp)+,CollChkRegs	* Restore and return
		rts

10$		lea.l	DLE_hitbox(a5),a3	* DLE->HitBox in a3

		move.w	DLE_newx(a5),d2		* NewX
		add.w	HB_txoff(a3),d2
		move.w	DLE_newy(a5),d3
                add.w	HB_tyoff(a3),d3
		move.w	DLE_newx(a5),d4		* NewX
		add.w	HB_bxoff(a3),d4
		move.w	DLE_newy(a5),d5
                add.w	HB_byoff(a3),d5
		move.l	COLQ,A6	* For Speed

		move.l	A6,a4			* Moves through Queue
CheckQ		move.l	(a4),a4			* COL=Col->Flink!=Head ?
		cmp.l	A6,a4
		beq	LOOP_DISP			* If yes, end of queue
		move.l	COL_dle(a4),a2		* Get DLE of Queue Elem
		movea.l	a2,a3
		lea.l	DLE_newx(a2),a2		* move up
		lea.l	DLE_hitbox(a3),a0	* Get HitBox of same

* Check Hitboxes for hit

		move.w	d4,d0			* bxoff
		sub.w	(a2)+,d0		* newx
                sub.w	(a0)+,d0
		bmi	CheckQ

		move.w	d5,d0			* byoff
		sub.w	(a2),d0			* newy
                sub.w	(a0)+,d0
		bmi	CheckQ

		move.w	-(a2),d0		* newx
		add.w	(a0)+,d0
		sub.w	d2,d0			* txoff
                bmi	CheckQ
	
		move.w	2(a2),d0		* newy
		add.w	(a0),d0
		sub.w	d3,d0			* tyoff
                bmi	CheckQ

		move.l	a3,-(sp)		* If they hit,
		move.l	A5,-(sp)	* Call collision function
		move.l	COL_function(a4),a1
		jsr	(a1)
		add.w	#8,sp
		jmp	LOOP_DISP

