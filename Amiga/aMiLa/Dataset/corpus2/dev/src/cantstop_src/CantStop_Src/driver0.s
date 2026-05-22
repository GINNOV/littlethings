
	;
	;  Simple driver for Logo-effect
	;
	;  (OK, it's really quick and dirty, but it's just enough to
	;  get the effect running! ;)
	;


	Lea	GfxName,a1
	Moveq	#0,d0
	Move.l	4.w,a6
	Jsr	-552(a6)		; _LVOOpenLibrary
	Move.l	d0,GfxBase

	Jsr	-132(a6)		; _LVOForbid





	; ************************
	; **                    **
	; **  START DEMO STUFF  **
	; **                    **
	; ************************


	; -- PRECALC ROUTINES HERE... --

	Jsr	LINE_INIT
	Jsr	BUMP_INIT
	Jsr	SCENE_INIT


	; -- SHOW THE EFFECT --

	Move.w	#$8380,$DFF096		; Setup DMA
	Move.w	#$0020,$DFF096		; Kill Sprites

	Jsr	LINE_SHOW
	Jsr	BUMP_SHOW
	Jsr	SCENE_SHOW


	; -- CLEANUP ROUTINES (END OF DEMO) --




	; **********************
	; **                  **
	; **  END DEMO STUFF  **
	; **                  **
	; **********************




	Move.l	4.w,a6
	Jsr	-138(a6)		; _LVOPermit


	Move.l	GfxBase,a6
	Move.l	38(a6),$DFF080
	Move.w	#-1,$DFF088

	Move.l	a6,a1
	Move.l	4.w,a6
	Jsr	-414(a6)		; _LVOCloseLibrary

	Move.w	#$8020,$DFF096		; Sprites back on!

	Rts




	; -- DATAS & STUFF --

GfxBase		dc.l	0
GfxName		dc.b	'graphics.library',0
		cnop	0,4		; Longword align


	include	'TheLot.s'
