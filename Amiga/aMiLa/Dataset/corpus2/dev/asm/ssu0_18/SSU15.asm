;APS00000000000000000000000000000000000000000000000000000000000000000000000000000000
;*******************************************************
;*    SystemStartUp example that opens a screen and    *
;*          enables you to read the keyboard           *
;*                                                     *
;*      ASM-One example coded by Rune Gram-Madsen      *
;*                                                     *
;*       All rights reserved. Copyright (c) 1990       *
;*******************************************************

	include "exec/types.i"
	include "exec/exec.i"
	include "libraries/dos_lib.i"
	include "libraries/dos.i"
	include "devices/timer.i"
; This example could have been coded shorter using includefiles. But
; I think it is nice to have it all in one single program.

IECLASS_RAWKEY	= $01
OPENLIB	= -408
CLOSELIB	= -414
OPENSCREEN	= -198
CLOSESCREEN	= -66
OPENWINDOW	= -204
CLOSEWINDOW	= -72
_LVOCloseDevice		equ	-450
_LVOOpenDevice		equ	-444
_LVOOpenLibrary		equ	-552
_LVOCreateIORequest	equ	-654
_LVODeleteIORequest	equ	-660
_LVOCreateMsgPort	equ	-666
_LVODeleteMsgPort	equ	-672
	xdef	_LVOAddTime
_LVOAddTime	equ	-42
	xdef	_LVOSubTime
_LVOSubTime	equ	-48
	xdef	_LVOCmpTime
_LVOCmpTime	equ	-54
	xdef	_LVOReadEClock
_LVOReadEClock	equ	-60
	xdef	_LVOGetSysTime
_LVOGetSysTime	equ	-66

RAWKEYCONVERT	= -$30
FINDTASK	= -294
WAITPORT	= -384
REPLYMSG	= -378
GETMSG	= -372
LOADRGB4 	= -192

ALLOCMEM	= -198 
FREEMEM	= -210

RAWKEY	= $00000400

BACKDROP	= $00000100
BORDERLESS	= $00000800
ACTIVATE	= $00001000
RMBTRAP	= $00010000
                    
CUSTOMSCREEN	= $000F
                    
V_HIRES	= $8000
NULL	= 0
                   
CUSTOM	= $DFF000
DETAIL	= 16
DEEP	= 10
RENDER_H	= 100
;********************************
;*    System startup routine    *
;********************************

.MAIN	BSR.W	STARTUP
	BEQ.W	.ERROR		; An error ?
	
	
	
	move.l	4.w,a6
	move.l	#16000,d0
	move.l	#MEMF_CHIP,d1
	jsr	ALLOCMEM(a6)
	lea	gp_p_work_bp0(pc),a0	; A filet ahova betölthetem pointer
	move.l	d0,(a0)+		; 0 draw shape
	beq.w	.ESC
	
	add.l	#4000,d0
	move.l	d0,(a0)+		; 1 copy
	add.l	#4000,d0		
	move.l	d0,(a0)+		; 2 copy
	add.l	#4000,d0
	move.l	d0,(a0)+		; 2 copy
	
	
	lea	gp_s_level_01(pc),a0	; a file neve
	lea	gp_p_file_name(pc),a1
	move.l  a0,(a1)
		 
	lea	gp_pp_file_buf(pc),a2	; a load IO cime
	move.l	gp_p_level_ascii(pc),(a2)	; a regi buff cime
		
	bsr.w	GP_LOAD
	
	lea.l	gp_p_level_ascii(pc),a0	; uj buffer d0-ban
	move.l	d0,(a0)
	tst.l   d0
	beq	.ESC
	
	
	; gp_s_fulke. iff
	
	lea	gp_s_fulke(pc),a0	; a file neve
	lea	gp_p_file_name(pc),a1
	move.l	a0,(a1)
		 
	lea	gp_pp_file_buf(pc),a2	; a load IO cime
	move.l	gp_p_fulke(pc),(a2)	; a regi buff cime
		
	bsr.w	GP_LOAD
	
	lea.l	gp_p_fulke(pc),a0	; uj buffer d0-ban
	move.l	d0,(a0)
	tst.l	d0
	beq	.ESC
	
	move.l	gp_p_fulke(pc),a0
	bsr	GP_PIC_CPY
	
	; bent van a level ascii
	
	lea	gp_p_ascii(pc),a0
	move.l	gp_p_level_ascii(pc),(a0)
	
	bsr	GP_COMP_INIT
	bsr	GP_COMP
	
	; foglalunk helyet gp_p_shape-ba dolgozni
	lea 	gp_p_shape(pc), a0
	tst.l	(a0)
	bne	.p_shape_good
	move.l	#$10000, d5	; 64k
	move.l	#0, a5
	bsr	GP_FIX_JOIN
	move.l	(a0), d0
.p_shape_good	
	lea 	gp_n_idx(pc), a0
	move.l	gp_p_idx_s(PC), d0
	move.l	gp_p_idx_e(PC), d1
	sub.l	d0,d1
	lsr.l	#1,d1
	move.w	d1,(a0)
	
	move.l	gp_p_pat_s(PC), d0
	move.l	gp_p_pat_e(PC), d1
	sub.l	d0,d1
	lsr.l	#1,d1
	sub.l	#1,d1
	move.w	d1,2(a0)
	
	
;---  Place your main routine here  ---
.MAIN_LOOP
	; clera
	lea.l	gp_half(pc), a6
	cmp.l	#40,(a6)
	beq	.falf20
	move.l	#40,(a6)
	bra	.falf0	
.falf20:	move.l	#0,(a6)
	
.falf0:	bsr.w	GP_CLR
	; VERTEX SHADER :)
	;bsr	GP_TIMER
	
	move.l	gp_pos_z(pc), d0
	move.l	#DEEP,d7	; mélység
.vx_loop	
	move.l	d0,d1	; nagy Z-t a d1 be
	divu.w	#DETAIL,d1	; nagy Z/DETAIL
	move.w	d1,d2	; hanyadik DETAIL tart
	ext.l	d2 
	; pos in level_index
	add.l	d7,d2	; + mélység
	divu.w	gp_n_idx(pc),d2	; elosztjuk az összes index számával
	clr.w	d2	; de nekem a maradék kell
	swap	d2	; index helye
	
	; index
	move.l	gp_p_idx_s(PC),a0
	move.w	0(a0,d2.w*2),d2
	; patern
	ext.w	d2	; az index
	divu.w	gp_n_pat(pc),d2	; az össszes minta számával osztjuk 
	swap	d2	; és a maradék kell ;; minta
	; p_shp a1 a2
	move.l	gp_p_pat_s(PC),a0
	move.l	gp_p_shp_s(PC),a1
	move.l	a1,a2
	add.w	0(a0,d2.w*2),a1
	add.w	#1,d2
	;add.l	#2,a1	; a lut-ot átugorja
	lea.l	gp_dir(pc),a4
	move.w	(a1)+, -4(a4)
	add.w	0(a0,d2.w*2),a2	; minta a1->a2
		
	; projekcio
	swap	d1	; nagy Z/DETAIL maradéka
	ext.l	d1	
	move.l	#DETAIL*2,d5
	move.l	d7,d6
	add.l	#1,d6
	mulu.l	#DETAIL,d6
	sub.l	d1,d6
	swap	d6
	move.w	d5,d6	; d6 proj /:*
		
	move.l 	gp_p_shape(pc), a3
	
	;lea.l	gp_dir(pc),a4
	move.l	 4(a4), d4	; vx
	move.l	 8(a4), d5	; vy
	move.l	12(a4), a5	; pos
.vx_move
	move.l	(a1)+,d1
	; move
	exg	a5,d5
	sub.w	d5,d1
	swap	d1
	swap	d5
	sub.w	d5,d1
	swap	d1
	swap	d5
	exg	a5,d5
	
	;d1 y * vy
	;vyy		; d1 x:y
	move.w	d4,d2
	ext.l	d2
	muls.w	d1,d2
	asr.l	#7,d2
	move.w	d2,d3	; d3 x:y
	swap	d3	; d3 y:x
	;vyx
	move.l	d4,d2
	swap	d2
	ext.l	d2
	muls.w	d1,d2
	asr.l	#7,d2
	move.w	d2,d3	; d3 y:x
	
	swap	d1	; d1 y:x
	exg	d4,a6	; SAVE D4->a6
	
	;d1 y * vy
	;vxy
	move.w	d5,d2
	ext.l	d2
	muls.w	d1,d2
	asr.l	#7,d2
	move.w	d2,d4	; d4 x:y
	swap	d4	; d4 y:x
	;vxx
	move.l	d5,d2
	swap	d2
	ext.l	d2
	muls.w	d1,d2
	asr.l	#7,d2
	move.w	d2,d4	; d4 y:x
	
	; d1 = d4+d3
	move.l	d4,d1
	add.w	d3,d1	; d3 y:x 
	swap	d1
	swap	d3
	add.w	d3,d1
	
	exg	d4,a6	; BACK a6->D4
	
	
	;-------------------------------------------------------	
	; proj
	move.w	d1,d2
	swap	d1
	move.w	d1,d3
	
	muls.w	d6,d2	; d2 y *= 
	muls.w	d6,d3	; d3 x *=
	swap	d6	; d6 divs Z
	divs.w	d6,d2	; d2 y /= 
	divs.w	d6,d3	; d3 x /=
	swap	d6    	; d6 muls                                             	
	
	add.w	#160,d2
	swap	d2
	move.w	d3,d2
	asr.w	#1,d2
	add.w	#RENDER_H/2,d2
	move.l	d2,(a3)+
	
	cmp.l	a1,a2
	bhi	.vx_move

; cut
	move.l 	gp_p_shape(pc), a1
	move.l	a3,a2
	move.l	a3,a4
	sub.l	#4,a4
	move.l	#0,d6
.vx_cut
	move.l	(a1)+,d1
	move.l	(a1),d2
	
	cmp.w	d1,d2
	beq	.vx_skip_y
	cmp.w	d1,d2
	bge	.no_chg_y1y2
	move.l	#1,d6
	exg	d1,d2
.no_chg_y1y2	
	
	cmp.w	#RENDER_H,d1
	bge	.vx_skip_y
	cmp.w	#0,d2
	blt	.vx_skip_y
	
	cmp.w	#0,d1
	bge	.no_neg_yl
	; yl kissebb vágni kell
	move.w	d2,d5	; d5 yh	
	sub.w	d1,d5	; d5 yh-yl
	move.w	d1,d3	; d3 yl
	neg.w	d3	; d3 -yl
	cmp.w	d3,d5	; ?( yh-yl <= -yl )
	ble	.vx_skip_y	; yh kisebb vagy egyenlõ yl-gyel nem kell
		
	swap	d1	; d1 xl
	swap	d2	; d2 xh
	move.w	d2,d4	; d4 xh
	sub.w	d1,d4	; d4-d1 xh-xl
	muls.w	d3,d4	; d4 (xh-xl)*-yl
	divs.w	d5,d4	; d4 (xh-xl)*-yl /(yh-yl)
	add.w	d4,d1	; d4 (xh-xl)*-yl /(yh-yl) + xl
	swap	d1	; d1 yl
	clr.w	d1	; d1 yl = 0
	swap	d2	; d2 yh
.no_neg_yl
	cmp.w	#RENDER_H,d2
	blt	.no_cut_yh
	
	move.w	#RENDER_H-1,d3
	sub.w	d1,d3	; 200-yl
	sub.w	d1,d2	; yh-yl
						
	swap	d2	; d2 xh
	swap	d1	; d1 xl
	sub.w	d1,d2	; d2 xh-xl
	muls.w	d2,d3	; d3 (xh-xl)*(200-yl)
	swap	d2	; d2 yh-yl
	divs.w	d2,d3	; d3 (xh-xl)*(200-yl) / (yh-yl) 
	add.w	d1,d3	; d3 ((xh-xl)*(200-yl) / (yh-yl)) + xl
	swap	d1	; d1 yl
	swap	d2	; d2 xh
	move.w	d3,d2	; d2 x = ((xh-xl)*(200-yl) / (yh-yl)) + xl
	swap	d2	; d2 yh-yl
	move.w	#RENDER_H-1,d2
	
.no_cut_yh
	cmp.l	#0,d6
	beq	.d1d2_good1
	exg	d1,d2
	move.l	#0,d6
.d1d2_good1
;--------------
; x vágdosás
	swap	d1	; d1 yx1
	swap	d2	; d2 yx2
	
	cmp.w	d1,d2
	bge	.no_chg_x1x2
	move.l	#1,d6
	exg	d1,d2
.no_chg_x1x2
	cmp.w	#319,d1
	bge	.vx_skip_x
	cmp.w	#0,d2
	blt	.vx_skip_x
	
	
	cmp.w	#0,d1
	bge	.no_neg_xl
	; xl negatív
	move.w	d2,d5	; d5 xh	
	sub.w	d1,d5	; d5 xh-xl
	move.w	d1,d3	; d3 xl
	neg.w	d3	; d3 -xl
	cmp.w	d3,d5	; ?( xh-xl <= -xl )
	ble	.vx_skip_x	; xh kisebb vagy egyenlõ xl-gyel nem kell
	
	swap	d1	; d1 yl
	swap	d2	; d2 yh
	move.w	d2,d4	; d4 yh
	sub.w	d1,d4	; d4-d1 yh-yl
	muls.w	d3,d4	; d4 (yh-yl)*-xl
	divs.w	d5,d4	; d4 (yh-yl)*-xl /(xh-xl)
	add.w	d4,d1	; d4 (yh-yl)*-xl /(xh-xl) + yl
	swap	d1	; d1 xl
	clr.w	d1	; d1 xl = 0
	swap	d2	; d2 xh
.no_neg_xl	
	cmp.w	#320,d2
	blt	.no_cut_xh
	
	move.w	#319,d3
	sub.w	d1,d3	; 319-xl
	sub.w	d1,d2	; xh-xl
	beq	.vx_skip_x
	
	swap	d2	; d2 yh
	swap	d1	; d1 yl
	sub.w	d1,d2	; d2 yh-yl
	muls.w	d2,d3	; d3 (yh-yl)*(319-xl)
	swap	d2	; d2 xh-xl
	divs.w	d2,d3	; d3 (yh-yl)*(319-xl) / (yh-yl) 
	add.w	d1,d3	; d3 ((yh-yl)*(319-xl) / (yh-yl)) + yl
	swap	d1	; d1 xl
	swap	d2	; d2 yh
	move.w	d3,d2	; d2 y = ((yh-yl)*(319-xl) / (yh-yl)) + yl
	swap	d2	; d2 xh-xl
	move.w	#319,d2
	
.no_cut_xh
			
	cmp.l	#0,d6
	beq	.d1d2_good2
	exg	d1,d2
	move.l	#0,d6
.d1d2_good2
	
	
	swap	d1	; d1 xy1
	swap	d2	; d2 xy2
	
	
	
	move.l	d1,(a2)+
	move.l	d2,(a2)+
	cmp.l	a1,a4
	bhi	.vx_cut
	bra	.cut_done
	
.vx_skip_x	
	swap	d1	; d1 xy1
	swap	d2	; d2 xy2
	
	cmp.l	#0,d6
	beq	.d1d2_good_x
	exg	d1,d2
	move.l	#0,d6
.d1d2_good_x
	cmp.l	a1,a4
	bhi	.vx_cut
	bra	.cut_done
		
.vx_skip_y	
	cmp.l	#0,d6
	beq	.d1d2_good_y
	exg	d1,d2
	move.l	#0,d6
.d1d2_good_y	
	cmp.l	a1,a4
	bhi	.vx_cut
;-----------------
; SHAPE BLITTER
.cut_done	
	move.l	a2, d1
	sub.l 	a3, d1
	cmp.l	#4,d1
	blt	.skip_shape	
	
	bsr.w	GP_CLR
	
	move.l	a3,a0
	bsr.w	GP_SHAPE
	
	bsr	GP_FILL
	
	move.w	gp_lut(pc),d1
	bsr	GP_BLIT_CPY_LUT
			
.skip_shape		
	sub.l	#1,d7
	bne	.vx_loop
	
	lea.l	gp_pos_z(PC),a0
	add.l	#1,(a0)
	
	bsr	GP_BLIT_CPY

	bsr	GP_JOY
	
;.WVBlank
;	TST.B	$5(A6)
;	BEQ.S	.WVBlank
;.WVBloop
;	TST.B	$5(A6)
;	BNE.S	.WVBloop
	
.ESC	
	;BSR.W	KEYB_GETKEY	; Get key
	cmp.w	#10,gp_escape(pc)
	BNE.w	.MAIN_LOOP		; A space ?? No jump again
	
	move.l	4.w,a6
	move.l	#16000,d0
	move.l	gp_p_work_bp0(pc),a1
	jsr	-210(a6)
	
	BRA.W	CLOSEDOWN	; Closedown
.ERROR:	RTS
gp_escape:	dc.w	0
gp_n_idx:	dc.w	0
gp_n_pat:	dc.w	0
		even
gp_lut:	dc.w	0,0
gp_dir:	dc.w	0,0
gp_vx:	dc.w	128,0
gp_vy:	dc.w	0,128
gp_pos_xy:	dc.w	0,0
gp_pos_z:	dc.l	0		
gp_cos255:	dc.w	255,255,255,255,254,254,254,253,253,252,251,250,249,249,248,246
	dc.w	245,244,243,241,240,238,237,235,233,232,230,228,226,224,222,220
	dc.w	218,215,213,211,208,206,203,201,198,196,193,190,187,185,182,179
	dc.w	176,173,170,167,164,161,158,155,152,149,146,143,140,137,133,130
	
	dc.w	127,124,121,118,115,112,109,105,102, 99, 96, 93, 90, 87, 84, 81
	dc.w	 78, 76, 73, 70, 67, 65, 62, 59, 57, 54, 51, 49, 47, 44, 42, 40
	dc.w	 37, 35, 33, 31, 29, 27, 25, 23, 22, 20, 18, 17, 15, 14, 13, 11
	dc.w	 10,  9,  8,  7,  6,  5,  4,  4,  3,  3,  2,  2,  1,  1,  1,  1
	
	dc.w	  1,  1,  1,  1,  2,  2,  3,  3,  4,  4,  5,  6,  7,  8,  9, 10
	dc.w	 11, 13, 14, 15, 17, 18, 20, 22, 23, 25, 27, 29, 31, 33, 35, 37
	dc.w	 40, 42, 44, 47, 49, 51, 54, 57, 59, 62, 64, 67, 70, 73, 76, 78
	dc.w	 81, 84, 87, 90, 93, 96, 99,102,105,109,112,115,118,121,124,127
	
	dc.w	130,133,137,140,143,146,149,152,155,158,161,164,167,170,173,176
	dc.w	179,182,185,187,190,193,196,198,201,203,206,208,211,213,215,218
	dc.w	220,222,224,226,228,230,232,233,235,237,238,240,241,243,244,245
	dc.w	246,248,249,249,250,251,252,253,253,254,254,254,255,255,255,255
		even
;---------------------------------------------
; GP_JOY
GP_JOY	
	lea.l	gp_dir(pc),a1
	
; COS LUT INIT ----------------------------------	
	lea.l	gp_cos255(pc), a2
	cmp.w	#128,(a2)
	ble	.init_good
	move.l	a2,a3
	add.l	#512,a3
.init_cos
	sub.w	#128,(a2)+
	cmp.l	a2,a3
	bne	.init_cos
		
.init_good	clr.l	d0
	move.l	(a1),d1	;d1 roll_x:dir_y
	move.w	$dff00c,d6	; lekérdezem a joyt
	move.w	d6,d7
	lsr.w	#1,d7
	eor.w	d6,d7
	
; JOY1DAT ------------------------------- 
	btst	#8, d7
	beq	.no_forw
	; elölre
	move.w	#1,d1	
	bra	.no_back
	
.no_forw	btst	#0, d7
	beq	.no_back
	; hatra
	move.w	#-1,d1	 
	
.no_back	
	swap	d1	; d1 dir_y:roll_x
	
	btst	#9, d6
	beq	.no_left
	; balra	
	add.l	#1,d1
	bra	.fire
	
.no_left		
	btst	#1, d6
	beq	.fire
	; jobbra
	sub.l	#1,d1
.fire
	swap	d1	;d1 roll_x:dir_y
	
	; a tûzgomb
	btst	#$7,$bfe001
	bne.b	.play
	
	lea.l	gp_escape(pc),a2
	move.w	#10,(a2)
; PLAY ------------------------------------	
.play
		
	swap	d1	; d1 dir_y:roll_x
	cmp.w	#256,d1
	blt	.no_dhi
	sub.w	#256,d1
.no_dhi	
	tst.w	d1
	bpl	.no_dlo
	add.w	#256,d1
.no_dlo	
	move.w	(a1),d2
	cmp.w	d1,d2
	beq	.no_roll
	move.w	d1, (a1)
	
	move.w	d1,d2
	ext.l	d2
	add.l	#64,d2	;64 - 256/4 -> PI/2
	divu.w	#256,d2
	swap	d2
	
	move.w	0(a2,d1.w*2),d3		; d3 cos
	swap	d3		; d3 cos:sin
	move.w	0(a2,d2.w*2), d3		; d3 sin
	
	move.w	d3,  6(a1)		; vxy sin
	swap	d3		; d3 sin:cos
	move.w	d3,  4(a1)		; vxx cos
	
	
	move.w	d3,10(a1)		; vyy cos (vxx)
	swap	d3		; d3 cos:sin
	neg.w	d3
	move.w	d3,8(a1)		; vyx -sin (-vxy)
			
.no_roll	
	swap	d1	;d1 roll_x:dir_y
	cmp.w	#0, d1
	beq	.no_dir
	
	move.w	(a1),d4
	add.w	#256-64,d4
	ext.l	d4
	divu.w	#256,d4
	swap	d4
	
	move.w	d4,d2
	ext.l	d2
	add.l	#64,d2	;64 - 256/4 -> PI/2
	divu.w	#256,d2
	swap	d2
	
	move.w	0(a2,d4.w*2),d3		; d3 cos
	swap	d3		; d3 cos:sin
	move.w	0(a2,d2.w*2), d3		; d3 sin
	
	move.l	d3,d2
	
	
	;move.l	8(a1),d2	; d2 vy.X:Y
	move.w	d2,d3	; d3 vy.y
	swap	d2	; d2 vy.x
	muls.w	d1,d2
	muls.w	d1,d3
	ext.l	d2
	ext.l	d3
	divs.w	#64,d2
	divs.w	#64,d3
	
	move.l	12(a1),d4
	move.w	d4,d5	; d5 pos_y
	swap	d4	; d4 pos_x
	add.w	d2,d4	; d4 pos_x += dy.x
	add.w	d3,d5	; d5 pos_y += dy.y
	
	move.w	d4,d2	; d2 pos_x
	muls.w	d2,d2	; d2 pos_x^2
	move.w	d5,d3	; d3 pos_y
	muls.w	d3,d3	; d3 pos_y^2
	move.l	d3,d6	; d6 pos_y^2
	add.l	d2,d6	; d6 pos_y^2 += pos_x^2	
	
	cmp.l	#16384,d6
	ble	.pos_good
	
	move.l	d6,d0
	bsr	GP_SQRT	; d0 = sqrt(d6)
	
	muls.w	#127,d4
	muls.w	#127,d5
	divs.w	d0,d4
	divs.w	d0,d5
		
.pos_good
	swap	d4
	move.w	d5,d4
	move.l	d4,12(a1)
.no_dir
	rts	

GP_SQRT:
	movem.l	d1-d2/a0,-(a7)
	move.l	d0,a0		; eredeti
	beq.s	.sqrt_esc		; 0 nincs gyök
	moveq	#2,d1		; négyzetgyök
	
	move.l	d0,d2
	swap	d2		; do [and.l 0xFFFF0000,d2] this way to...
	tst.w	d2		; go faster on 68000 and to avoid having to...
	beq.s	.sqrt_skip8		; reload d2 for the next test below
	move.w	#$200,d1		; faster than lsl.w #8,d1 (68000)
	lsr.l	#8,d0
.sqrt_skip8	and.w	#$FE00,d2		; this value and shift by 5 are magic
	beq.s	.sqrt_skip4
	lsl.w	#5,d1
	lsr.l	#5,d0
.sqrt_skip4
.sqrt_loop	add.l	d1,d1
	lsr.l	#1,d0
	cmp.l	d0,d1
	bcs.s	.sqrt_loop
.sqrt_skip	lsr.l	#1,d1		; adjust the approximation
	add.l	d0,d1		; here we just add and shift to...
	lsr.l	#1,d1		; get the first iteration "for free"! 
	
.sqrt_loop2	move.l	a0,d2		; get original input value
	move.w	d1,d0		; save current guess
	divu.w	d1,d2		; do the Newton method thing
	bvs.s	.sqrt_esc		; if div overflows, exit with current guess
	add.w	d2,d1
	roxr.w	#1,d1		; roxr ensures shifting back carry overflow
	cmp.w	d0,d1
	bcs.s	.sqrt_loop2		; exit with result in d0.w
	
.sqrt_esc	
	movem.l	(a7)+,d1-d2/a0 
	rts
	
gp_s_level_01:	dc.b	"level_01.txt",0
		even
; class GP_LEVEL
gp_p_level_ascii:	dc.l	0		; GP_FIX* 
gp_p_lev_idx:	dc.l	0		; GP_FIX* struct lay_idx, off_x, off,_y
gp_p_lev_pat:	dc.l	0		; GP_FIX* struct start, end
gp_p_lev_shp:	dc.l	0		; GP_FIX* struct x, y


gp_s_fulke:	dc.b	"fulke5.iff",0
		even
gp_p_fulke:	dc.l	0

;-------------------------------------------------------
; class GP_COMP
;public
	;IN
	gp_p_ascii:	dc.l	0
	;OUT
	gp_p_idx_s:	dc.l	0
	gp_p_idx_e:	dc.l	0
	
	gp_p_pat_s:	dc.l	0
	gp_p_pat_e:	dc.l	0
	gp_p_shp_s:	dc.l	0
	gp_p_shp_e:	dc.l	0
;privat
	alfa_alt:	dc.l	0
	alfa_idx:	dc.l	0
	alfa_next:	dc.l	0
	even
GP_COMP_INIT
	clr.l	d0
	move.b	#'A'-$40,d0
	mulu.l	#27,d0
	add.l	#'L'-$40,d0
	mulu.l	#27,d0
	add.l	#'T'-$40,d0
	lea.l	alfa_alt(pc),a0
	move.l	d0,(a0)
	
	clr.l	d0
	move.b	#'I'-$40,d0
	mulu.l	#27,d0
	add.l	#'D'-$40,d0
	mulu.l	#27,d0
	add.l	#'X'-$40,d0
	move.l	d0, 4(a0)
	
	clr.l	d0
	move.b	#'N'-$40,d0
	mulu.l	#27,d0
	add.l	#'E'-$40,d0
	mulu.l	#27,d0
	add.l	#'X'-$40,d0
	mulu.l	#27,d0
	add.l	#'T'-$40,d0
	move.l	d0, 8(a0)
	rts

;------------------------------------------------------------------------
;
;	GP_COMP_DEC
;
;------------------------------------------

GP_COMP_DEC
	tst.l	d3
	beq	.cmp_wrie
	cmp.l	d3,d4
	beq	.cmp_wrie
; új alfa
; - p_SAVE ---------------------------------
; -- regi ----- switch( d4 ) -----------------------
	cmp.l	#0,d4
	beq	.p_save_break
	cmp.l	alfa_idx(pc),d4
	bne	.no_s_idx
;case idx	
	lea	gp_p_idx_e(pc),a5
	move.l	a2,(a5)
	bra	.p_save_break		
.no_s_idx	
	cmp.l	alfa_alt(pc),d4
	bne	.p_save_break
;case alt	
	lea	gp_p_shp_e(pc),a5
	move.l	a2,(a5)
	;bra	.p_save_break

.p_save_break
	move.l	#0,a2
	
;- uj ALFA ---- switch( d3 )-------------------------------------		
	cmp.l	alfa_alt(pc),d3
	bne	.no_alt
;case alt:
	move.l	gp_p_shp_s(pc), a1	
	move.l	gp_p_shp_e(pc), a2
	
	cmp.l	#0,a2
	bne	.alt_good	
	move.l	a1,a2
.alt_good	
	lea.l	gp_p_pat_e(pc), a3
	move.l	(a3), a4	
	
	cmp.l	#0,a4
	bne	.cmp_n_break
	move.l	gp_p_pat_s(pc),a4
	;bra	.cmp_n_break

.no_alt	
	cmp.l	#0,a3
	beq	.a4_empty
	cmp.l	#0,a4
	beq	.a4_empty
	move.l	a4,(a3)
.a4_empty
	cmp.l	alfa_idx(pc),d3
	bne	.no_idx
;case idx:	
	move.l	#0,a3
	move.l	#0,a4
	
	move.l	gp_p_idx_s(pc), a1	
	move.l	gp_p_idx_e(pc), a2
	cmp.l	#0,a2
	bne	.cmp_n_break
	move.l	a1,a2
	
	bra	.cmp_n_break
;case next:	
.no_idx	cmp.l	alfa_next(pc),d3
	bne	.cmp_n_break
	
	move.l	#0,a3
	move.l	#0,a4
	
	move.l	#0, a1	
	move.l	#0, a2
		
.cmp_n_break
	move.l	d3,d4
	clr.l	d3
		
.cmp_wrie	
	bclr.l	#0,d7
	beq	.cmp_n_loop
	; eltároljuk a számokat
	cmp.l	#0,a2
	beq	.cmp_n_esc
	
	muls.w	d2,d1
	move.w	d1,(a2)+
	move.l	#1,d2
	clr.l	d1
	; while elválasztó karakterek
.cmp_n_loop	
	move.b	(a0),d0
	beq	.cmp_n_esc	; ha a következõ már a vége
	cmp.w	#$30,d0	; vagy nem írásjel
	bge	.cmp_n_esc	
	cmp.b	#$a,d0	; vagy enter lf
	beq	.cmp_n_esc	
	cmp.b	#$d,d0	; vagy enter cr
	beq	.cmp_n_esc
	cmp.b	#$2d,d0	; vagy - (minusz)
	beq	.cmp_n_esc
			
.cmp_n_step	
	add.l	#1, a0
	bra	.cmp_n_loop
.cmp_n_esc	
	rts
;--------------------------------------------------------------
; GP_COMP	p_str: a0, data: a1-a2, idx: a3-a4 
	
GP_COMP
	move.l	gp_p_ascii(pc), a0
	move.l	-8(a0), d5
	bne	.ascii_good
	rts
.ascii_good	
	lea 	gp_p_idx_s(pc), a0
	tst.l	(a0)
	bne	.idx_s_good
	
	move.l	gp_p_ascii(pc), a1
	move.l	-8(a1), d5
	mulu.l	#$10, d5
	move.l	#0, a5
	bsr	GP_FIX_JOIN
	move.l	(a0), d0
.idx_s_good	
	lea 	gp_p_pat_s(pc), a0
	tst.l	(a0)
	bne	.pat_s_good
	move.l	gp_p_ascii(pc), a1
	move.l	-8(a1), d5
	mulu.l	#$10, d5
	move.l	#0, a5
	bsr	GP_FIX_JOIN
	move.l	(a0), d0
.pat_s_good
	lea 	gp_p_shp_s(pc), a0
	tst.l	(a0)
	bne	.shp_s_good
	move.l	gp_p_ascii(pc), a1
	move.l	-8(a1), d5
	mulu.l	#$10, d5
	move.l	#0, a5
	bsr	GP_FIX_JOIN
	move.l	(a0), d0
.shp_s_good
	
	move.l	gp_p_ascii(pc), a0
	move.l	-8(a0), d0
	move.l	a0,a6
	add.l	d0,a6
	clr.l	d0	; char
	clr.l	d1	; num
	move.l	#1,d2	; sign
	clr.l	d3	; alfa
	clr.l	d4	; alfa2
	clr.l	d7	; flag	0 num
	move.l	#0,a1	; p_data_start
	move.l	#0,a2	; p_data_end
	move.l	#0,a3	; pp_pat_e
	move.l	#0,a4           ; p_pat_e
.comp_loop
	move.b	(a0)+,d0
	cmp.b	#$0,d0
	beq	.comp_esc
; 09 TAB --------------------------------------
.comp_tab	cmp.b	#$9,d0
	bne	.comp_enter
	
	bsr	GP_COMP_DEC	
		
	bra	.comp_break
; 0a 0d ENTER --------------------------------------
.comp_enter	cmp.b	#$a,d0
	bne	.comp_enter2

.comp_enter3
	move.b	(a0),d0
	beq	.comp_enter4	; ha a következõ már a vége
	cmp.w	#$30,d0	; vagy nem írásjel
	bge	.comp_enter4
	cmp.b	#$2d,d0	; vagy - (minusz)
	beq	.comp_enter4
	add.l	#1, a0
	bra	.comp_enter3

.comp_enter4	
	bsr	GP_COMP_DEC
	
	cmp.l	#0,a3
	beq	.comp_break
	cmp.l	#0,a4
	beq	.comp_break
	move.l	a2,d6
	sub.l	a1,d6
	move.w	d6,(a4)+
	move.l	a4,(a3)
	
	bra	.comp_break
.comp_enter2	cmp.b	#$d,d0
	bne	.comp_num
		
	bra	.comp_enter3
	
; 30-39 NUM ----------------------------------------
.comp_num	cmp.b	#$39,d0
	bhi	.comp_alfa
	cmp.b	#$30,d0
	blt	.comp_space
	
	sub.b	#$30,d0
	mulu.l	#10,d1
	and.l	#$f,d0
	add.l	d0,d1
	bset.l	#0,d7
	bra	.comp_break
; 41-5a 61-7a ALFA ----------------------------------------
.comp_alfa	cmp.b	#$5a,d0
	bhi	.comp_ALFA
	cmp.b	#$41,d0
	blt	.comp_space
.comp_alfa3	
	sub.b	#$40,d0
	mulu.l	#27,d3
	and.l	#$ff,d0
	add.l	d0,d3
	bra	.comp_break
.comp_ALFA	cmp.b	#$7a,d0
	bhi	.comp_space
	cmp.b	#$61,d0
	blt	.comp_space
	sub.b	#$20,d0
	bra	.comp_alfa3
	
; 20 SPACE --------------------------------------
.comp_space	cmp.b	#$20,d0
	bne	.comp_sub
	
	bsr	GP_COMP_DEC
	
	bra	.comp_break
; 2d SUB ----------------------------------------	
.comp_sub	cmp.b	#$2d,d0
	bne	.comp_point
	move.l	#-1,d2
	bra	.comp_break
; 2e POINT ----------------------------------------	
.comp_point	cmp.b	#$2e,d0
	bne	.comp_num
	
	;vége a szám egész részének
.comp_point_loop
	move.b	(a0),d0
	beq	.comp_break	; ha a következõ már a vége
	cmp.w	#$41,d0	; vagy alfa
	bge	.comp_break
	cmp.b	#$9,d0	; vagy tab
	beq	.comp_break
	cmp.b	#$a,d0	; vagy enter lf
	beq	.comp_break
	cmp.b	#$d,d0	; vagy enter cr
	beq	.comp_break
	cmp.b	#$20,d0	; vagy space
	beq	.comp_break
	cmp.b	#$2d,d0	; vagy - (minusz)
	beq	.comp_break
	add.l	#1, a0
	bra	.comp_point_loop
	
	bra	.comp_break


; BREAK ----------------------------------------	
.comp_break	
	cmp.l	a0,a6
	bne	.comp_loop
.comp_esc

	bsr	GP_COMP_DEC
	
	cmp.l	#0,a3
	beq	.comp_esc2
	cmp.l	#0,a4
	beq	.comp_esc2
	move.l	a2,d6
	sub.l	a1,d6
	move.w	d6,(a4)+
	move.l	a4,(a3)
.comp_esc2		
	rts
		
;-------------------------------------------------------
; class GP_LOAD
;public
	; IN
	gp_p_file_name:	dc.l	0
	; IN/OUT	
	gp_pp_file_buf: dc.l	0	
;privat
	gp_p_file_open:	dc.l	0	; tmp file handle
	gp_p_dos_base:	dc.l	0	; global
	gp_s_dos_lib:	dc.b	"dos.library",0
		even
	
GP_LOAD
	move.l	4.w,a6
	; if( !gp_p_dos_base ) { open dos.lidrary }
	move.l	gp_p_dos_base(pc), d0
	bne	.dos_base
	lea 	gp_s_dos_lib(pc),a1
	jsr	OPENLIB(a6)
	tst.l	d0
	beq	.load_esc_01
	lea	gp_p_dos_base(pc),a0
	move.l	d0,(a0)
.dos_base
	move.l	d0,a6
	move.l	gp_p_file_name(pc),d1
	move.l	#$3ed,d2

	jsr	_LVOOpen(a6)

	tst.l	d0
	beq.s	.load_esc_01
	lea	gp_p_file_open(pc),a0
	move.l	d0,(a0)
	
	
	lea 	gp_pp_file_buf(pc), a0
	tst.l	(a0)
	bne	.buff_good
	move.l	#40*256*3, d5
	move.l	#0, a5
	bsr	GP_FIX_JOIN
.buff_good	 
	
	move.l	gp_p_dos_base(pc),a6
	
	move.l 	gp_p_file_open(pc), d1
	move.l 	gp_pp_file_buf(pc), a0
	move.l	-16(a0),d3
	move.l	a0,d2
	jsr	_LVORead(a6)
	tst.l	d0
	beq.b	.load_esc_02
	
	move.l 	gp_pp_file_buf(pc), a0
	move.l	-8(a0), d1
	cmp.l	d0,d1
	beq	.load_esc_02	
	move.l	d0,-8(a0)		; n_load
	
.load_esc_02
	move.l	gp_p_file_open(pc),d1
	jsr	_LVOClose(a6)
.load_esc_01
	move.l 	gp_pp_file_buf(pc), d0	
	rts

	
GP_PIC_CPY:	;move.l 	BITPLANE1_PTR(pc),a1
	;move.l 	BITPLANE2_PTR(pc),a3
	;move.l 	BITPLANE3_PTR(pc),a4
	move.l 	gp_p_bp1(pc),a1
	move.l 	gp_p_bp3(pc),a2
	move.l 	gp_p_bp5(pc),a3
	
	;move.l	FilePointer(pc),a2
	add.l	#$96,a0
	clr.l	d1
.pic_loop2:	clr.l	d0
.pic_loop1:	move.l	00(a0),(a1)+
	move.l	40(a0),(a2)+
	move.l	80(a0),(a3)+
	;move.l	240(a2),(a5)+
	;move.l	320(a2),(a6)+
	addq.l	#4,a0
	addq.l	#4,d0
	cmp.l	#40,d0
	bne.b	.pic_loop1
	add.l	#80,a0
	add.l	#1,d1
	cmp.l	#255,d1
	bne.b	.pic_loop2
	rts	
	
;-------------------------------------------------------
; class GP_DBUFF
;			gp_p_kill:	dc.l	0
; KILL -----------------------------------------
; a0 = pp_buff (==0 no operate ) (A0) = p_buff
;-----------------------------------------------
GP_FIX_KILL
	; a1 - p_kill
	cmp.l	#0, a0		; pp_fixbuff
	beq	.kill_esc
	cmp.l	#0, (a0)		; p_mem
	beq	.kill_esc
	
	movem.l	d1-d5/a0-a2,-(a7)	; elrakom a verembe a ; pp_fixbuff
		
	move.l	(a0),a1		; p_mem
	sub.l	#16,a1		; p_alloc
	move.l	(a1),d0		; size
	add.l	#32,d0
	MOVE.L	$4.W,A6
	jsr	FREEMEM(a6)
	
	movem.l	(a7)+,d1-d5/a0-a2
.kill_esc
	rts
; JOIN -----------------------------------------
; a0 - pp_buff ( == 0 new alloc ) a5 - p_buff ( == 0 no memcpy ) d5 - n_byte ( == 0 no operate )
;------------------------------------------------	
GP_FIX_JOIN	
	; source a5 - p_src, d5 - n_src
	cmp.l	#0, d5		; n_src
	beq	.join_esc	
		
	; dest a0 - pp_fixbuff
	cmp.l	#0, a0		; pp_fixbuff
	beq	.join_esc
	cmp.l	#0, (a0)		; p_mem
	bne	.realloc
	
	; inicializál
	move.l	#0,d0		; d0 - n_size
	move.l	#16,d1		; d1 - n_seg
	move.l	#0,d2		; d2 - n_load
	
	bra	.alloc
.realloc
	move.l	(a0),a1		; p_mem
	move.l	-16(a1),d0		; d0 - n_size
	move.l	-12(a1),d1		; d1 - n_seg
	bne	.good_seg	
	move.l	#16,d1		; n_deg = (!n_seg) ? 16 : n_seg; 
	move.l	d1, -12(a1)		
.good_seg	
	move.l	-8(a1),d2		; d2 - n_load
	
.alloc	
	move.l	d2,d3		; d3 = n_load;
	add.l	d5,d3		; d3 += n_src	
	
	cmp.l	d3,d0		; if( d0 > d3 ) elég nagy nem kell bõvíteni
	bhi	.no_realloc		
	; realloc
	move.l	d3,d4		; d4 = d3 "n_load + n_src"
	
	divu.l	d1,d4		; d4 /= n_seg
	ext.l	d4		
	add.l	#1,d4		; d4 += 1
	ext.l	d4		
	mulu.l	d1,d4		; n_new_size: d4 *= n_seg
				; "((n_load + n_src)/n_seg)*n_seg"
	
	movem.l	d1-d5/a0-a5,-(a7)
	
	move.l	d4, d0
	add.l	#32, d0		; 32 byte-al többet foglalok 16 a head és 16,
				; hogy ne kelje szarakodni a végén az operandusok nem simmelnek long-al
	move.l	#0, d1		; best
	MOVE.L	$4.W,A6
	jsr	ALLOCMEM(a6)
	movem.l	(a7)+,d1-d5/a0-a5
	move.l	d0,a2		; p_reallock
	beq	.join_esc	; nem sikerült a foglalás gáz
	
	move.l	d4,(a2)+	; n_nsize	-16
	move.l	d1,(a2)+	; n_seg		-12
	move.l	d2,(a2)+	; n_load	-8
	add.l	#4,a2		; reserved	-4
	tst.l	-8(a2)
	beq	.no_memcpy
	; memcpy 1 ---------------------------	
	move.l	a2,a3;
	move.l	a2,d3;
	add.l	d2,d3;
.memcpy1_loop
	move.l	(a1)+,(a3)+
	cmp.l	a3,d3
	blt	.memcpy1_loop
.no_memcpy
	bsr	GP_FIX_KILL
	move.l	a2,(a0)
	
.no_realloc
	cmp.l	#0, a5		; p_src
	beq	.join_esc
	; memcpy 2 ---------------------------
	add.l	d5,-8(a2)
	add.l	d2,a2
	move.l	a5,a3
	add.l	d5,a5
.memcpy2_loop
	move.l	(a3)+,(a2)+
	cmp.l	a3,d5
	blt	.memcpy2_loop
.join_esc
	rts
;-----------------------------------------------------------
; class GP_CLR
GP_CLR
	MOVEM.L	D0-D7/A0-A6,-(A7)
			
	LEA.L	$DFF000,A6
.wait_clr:	btst 	#$e,$2(A6)
	bne	.wait_clr
	
	MOVE.L	gp_p_work_bp0(PC),$54(A6)	;BLTDPTH : BLTDPTL
	MOVE.L	#$01000000,$40(A6)	;BLTCON0 : BLTCON1
	MOVE.L	#0,$44(A6)		;BLTAFWM : BLTALWM
	MOVE.w	#0,$64(A6)
	MOVE.w	#0,$66(A6)		;BLTAMOD : BLTDMOD
	MOVE.W	#RENDER_H*64+20,$58(A6)	;BLTSIZE
		
.GP_CLR_ESC	
	MOVEM.L	(A7)+,D0-D7/A0-A6	
	rts
;-----------------------------------------------------------
; class GP_BLIT_CPY	gp_p_work_bp1-X -> gp_p_bp2+gp_half
GP_BLIT_CPY:
	movem.l	D0-D7/A0-A6,-(A7)
	
	lea.l	$DFF000,A6
	move.l	gp_half(pc), d1
	
	move.l	gp_p_bp2(PC),d0 
	add.l	d1,d0
.wait_cpy1:	btst 	#$e,$2(A6)
	bne	.wait_cpy1
		
	move.l	#$09f00000,$40(A6)	;BLTCON0 : BLTCON1
	move.l	#-1,$44(A6)		;BLTAFWM : BLTALWM
	move.l	#40,$64(A6)		;BLTAMOD : BLTDMOD
	
	move.l	gp_p_work_bp1(PC),$50(A6)	;BLTAPTH : BLTAPTL
	move.l	d0,$54(A6)		;BLTDPTH : BLTDPTL
	move.w	#RENDER_H*64+20,$58(A6)	;BLTSIZE
		
	move.l	gp_p_bp4(PC),d0 
	add.l	d1,d0
.wait_cpy2:	btst 	#$e,$2(A6)
	bne	.wait_cpy2
	move.l	gp_p_work_bp2(PC),$50(A6)	;BLTAPTH : BLTAPTL
	move.l	d0,$54(A6)		;BLTDPTH : BLTDPTL
	move.w	#RENDER_H*64+20,$58(A6)	;BLTSIZE
	
	move.l	gp_p_bp6(PC),d0 
	add.l	d1,d0
.wait_cpy3:	btst 	#$e,$2(A6)
	bne	.wait_cpy3
	move.l	gp_p_work_bp3(PC),$50(A6)	;BLTAPTH : BLTAPTL
	move.l	d0,$54(A6)		;BLTDPTH : BLTDPTL
	move.w	#RENDER_H*64+20,$58(A6)	;BLTSIZE
	
.wait_clr:	btst 	#$e,$2(A6)
	bne	.wait_clr
	
	MOVE.L	gp_p_work_bp1(PC),$54(A6)	;BLTDPTH : BLTDPTL
	MOVE.L	#$01000000,$40(A6)	;BLTCON0 : BLTCON1
	MOVE.L	#0,$44(A6)		;BLTAFWM : BLTALWM
	MOVE.w	#0,$64(A6)
	MOVE.w	#0,$66(A6)		;BLTAMOD : BLTDMOD
	MOVE.W	#RENDER_H*3*64+20,$58(A6)	;BLTSIZE
	
	movem.l	(A7)+,D0-D7/A0-A6	
	rts

;-----------------------------------------------------------
; class GP_BLIT_CPY_LUT	d1 - LUT	gp_p_work_bp0 -> gp_p_work_bp1-X 	
GP_BLIT_CPY_LUT:
	movem.l	D0-D7/A0-A6,-(A7)
	
	lea.l	$DFF000,A6
;; majd kell méretet adni ne az egészet akarja másolni
	
; - gp_p_work_bp0 -> gp_p_work_bp1 -----------------------------------------------------------
	move.l	#$0b0a0000, d2		; LUT == 0 -> D = !A * C : 0A
	btst	#0, d1
	beq	.wait_cpy1
	move.l	#$0bfa0000, d2		; LUT == 1 -> D = A + C : FA
	
.wait_cpy1:
	btst 	#$e,$2(A6)
	bne	.wait_cpy1
		
	move.l	#-1,$44(A6)		;BLTAFWM : BLTALWM
	move.l	#0,$60(A6)		;BLTCMOD
	move.l	#0,$64(A6)		;BLTAMOD : BLTDMOD
	
	move.l	gp_p_work_bp0(PC),$50(A6)	;BLTAPTH : BLTAPTL
	move.l	d2,$40(A6)		;BLTCON0 : BLTCON1
	move.l	gp_p_work_bp1(PC), a0
	move.l	a0,$48(A6)		;BLTCPTH : BLTCPTL
	move.l	a0,$54(A6)		;BLTDPTH : BLTDPTL
	move.w	#RENDER_H*64+20,$58(A6)	;BLTSIZE
	
; - gp_p_work_bp0 -> gp_p_work_bp2 -----------------------------------------------------------		
	move.l	#$0b0a0000, d2
	btst	#1, d1
	beq	.wait_cpy2
	move.l	#$0bfa0000, d2
	
.wait_cpy2:
	btst 	#$e,$2(A6)
	bne	.wait_cpy2
	
	move.l	gp_p_work_bp0(PC),$50(A6)	;BLTAPTH : BLTAPTL
	move.l	d2,$40(A6)		;BLTCON0 : BLTCON1
	move.l	gp_p_work_bp2(PC), a0	
	move.l	a0,$48(A6)		;BLTCPTH : BLTCPTL
	move.l	a0,$54(A6)		;BLTDPTH : BLTDPTL
	move.w	#RENDER_H*64+20,$58(A6)	;BLTSIZE

; - gp_p_work_bp0 -> gp_p_work_bp3 -----------------------------------------------------------	
	move.l	#$0b0a0000, d2
	btst	#2, d1
	beq	.wait_cpy3
	move.l	#$0bfa000, d2	
	
.wait_cpy3:
	btst 	#$e,$2(A6)
	bne	.wait_cpy3
	
	move.l	gp_p_work_bp0(PC),$50(A6)	;BLTAPTH : BLTAPTL
	move.l	d2,$40(A6)		;BLTCON0 : BLTCON1
	move.l	gp_p_work_bp3(PC), a0	
	move.l	a0,$48(A6)		;BLTCPTH : BLTCPTL
	move.l	a0,$54(A6)		;BLTDPTH : BLTDPTL
	move.w	#RENDER_H*64+20,$58(A6)	;BLTSIZE
	
	movem.l	(A7)+,D0-D7/A0-A6	
	rts

;-----------------------------------------------------------
; class GP_FILL	
	
GP_FILL:
	MOVEM.L	D0-D7/A0-A6,-(A7)
			
	LEA.L	$DFF000,A6
	move.l	gp_p_work_bp0(PC),d0 
	add.l	 #RENDER_H*40+38,d0
	
.wait_fill:	btst 	#$e,$2(A6)
	bne	.wait_fill
	move.l	#0,$dff064        ;clear modulo A and D
	move.w	#%0000100111110000,$dff040    ;boolean minterms
	move.w	 #%0000000000010110,$dff042    ;descending and fill mode
	move.l	d0,$dff050        ;source A
	move.l 	d0,$dff054        ;destination    D
	move.w 	 #RENDER_H*64+20,$dff058
	
	MOVEM.L	(A7)+,D0-D7/A0-A6	
	rts

; class GP_SHAPE
gp_p_shape:		dc.l	0
gp_n_shape:		dc.w	0

GP_SHAPE	
	MOVEM.L	D0-D7/A0-A6,-(A7)
	;BSR.S	GP_SHAPE_INIT
		
	;move.l	gp_p_shape(pc),a0
	cmp.l	#0,a0
	beq.s	.GP_SHAPE_ESC	
	cmp.l	#0,d1
	beq.s	.GP_SHAPE_ESC
	
	move.l	a0,a1
	add.l	d1,a1
	
	LEA.L	$DFF000,A6

.WAIT:	BTST	#$E,$2(A6)
	BNE.S	.WAIT

	MOVEQ	#-1,D2
	MOVE.L	D2,$44(A6)		; FirstLastMask
	MOVE.W	#$8000,$74(A6)		; BLT data A
	MOVE.W	#BYTEWIDTH,$60(A6)	; Tot.Screen Width
	MOVE.W	#$FFFF,$72(A6)
	move.l	gp_p_work_bp0(PC),A5
	add.l	gp_half(pc),a5
	
.GP_SHAPE_LOOP
	clr.l	d0
	clr.l	d1
	clr.l	d2
	clr.l	d3
	move.w	(a0)+,d0
	move.w	(a0)+,d1
	move.w	(a0)+,d2
	move.w	(a0)+,d3
		
	bsr.s	DRAWLINE
	
	cmp.l	a0,a1
	bne.s	.GP_SHAPE_LOOP
		
.GP_SHAPE_ESC	
	MOVEM.L	(A7)+,D0-D7/A0-A6
	rts
	

;********************
;*  Init line draw  *
;********************

SINGLE =2		; 2 = SINGLE BIT WIDTH
BYTEWIDTH =40

;*****************
;*   DRAW LINE   *
;*****************

; USES D0/D1/D2/D3/D4/D7/A5/A6

DRAWLINE:
	SUB.W	D3,D1
	
	lea.l	gp_screen_def(PC),a4
	;move.l	#BYTEWIDTH,d4
	;lsr.w	#3,d4
	move.l	#BYTEWIDTH,d4
	MULU	d4,D3		; ScreenWidth * D3

	MOVEQ	#$F,D4
	AND.W	D2,D4		; Get lowest bits from D2

;--------- SELECT OCTANT ---------

	SUB.W	D2,D0
	BLT.S	DRAW_DONT0146
	TST.W	D1
	BLT.S	DRAW_DONT04

	CMP.W	D0,D1
	BGE.S	DRAW_SELECT0
	MOVEQ	#$11+SINGLE,D7		; Select Oct 4
	BRA.S	DRAW_OCTSELECTED
DRAW_SELECT0:
	MOVEQ	#1+SINGLE,D7		; Select Oct 0
	EXG	D0,D1
	BRA.S	DRAW_OCTSELECTED

DRAW_DONT04:
	NEG.W	D1
	CMP.W	D0,D1
	BGE.S	DRAW_SELECT1
	MOVEQ	#$19+SINGLE,D7		; Select Oct 6
	BRA.S	DRAW_OCTSELECTED
DRAW_SELECT1:
	MOVEQ	#5+SINGLE,D7		; Select Oct 1
	EXG	D0,D1
	BRA.S	DRAW_OCTSELECTED


DRAW_DONT0146:
	NEG.W	D0
	TST.W	D1
	BLT.S	DRAW_DONT25
	CMP.W	D0,D1
	BGE.S	DRAW_SELECT2
	MOVEQ	#$15+SINGLE,D7		; Select Oct 5
	BRA.S	DRAW_OCTSELECTED
DRAW_SELECT2:
	MOVEQ	#9+SINGLE,D7		; Select Oct 2
	EXG	D0,D1
	BRA.S	DRAW_OCTSELECTED
DRAW_DONT25:
	NEG.W	D1
	CMP.W	D0,D1
	BGE.S	DRAW_SELECT3
	MOVEQ	#$1D+SINGLE,D7		; Select Oct 7
	BRA.S	DRAW_OCTSELECTED
DRAW_SELECT3:
	MOVEQ	#$D+SINGLE,D7		; Select Oct 3
	EXG	D0,D1

;---------   CALCULATE START   ---------

DRAW_OCTSELECTED:
	ADD.W	D1,D1		; 2*dy
	ASR.W	#3,D2		; x=x/8
	EXT.L	D2
	ADD.L	D2,D3		; d3 = x+y*40 = screen pos
	MOVE.W	D1,D2		; d2 = 2*dy
	SUB.W	D0,D2		; d2 = 2*dy-dx
	BGE.S	DRAW_DONTSETSIGN
	ORI.W	#$40,D7		; dx < 2*dy
DRAW_DONTSETSIGN:

;---------   SET BLITTER   ---------

.WAIT:
	BTST	#$E,$2(A6)		; Wait on the blitter
	BNE.S	.WAIT

	MOVE.W	D2,$52(A6)		; 2*dy-dx
	MOVE.W	D1,$62(A6)		; 2*d2
	SUB.W	D0,D2			; d2 = 2*dy-dx-dx
	MOVE.W	D2,$64(A6)		; 2*dy-2*dx

;---------   MAKE LENGTH   ---------

	ASL.W	#6,D0		; d0 = 64*dx
	ADD.W	#$0042,D0		; d0 = 64*(dx+1)+2

;---------   MAKE CONTROL 0+1   ---------

	ROR.W	#4,D4
	ORI.W	#$BEA,D4		; $B4A - DMA + Minterm
	SWAP	D7
	MOVE.W	D4,D7
	SWAP	D7
	ADD.L	A5,D3		; SCREEN PTR

	MOVE.L	D7,$40(A6)		; BLTCON0 + BLTCON1
	MOVE.L	D3,$48(A6)		; Source C
	MOVE.L	D3,$54(A6)		; Destination D
	MOVE.W	D0,$58(A6)		; Size
	RTS




;********  Open up system structures  ********

STARTUP:
	MOVE.L	A7,ERROR_STACK	; Save stack pointer if an error
	BSR.W	TASK_FIND
	BSR.W	INTULIB_OPEN
	BSR.W	GRAPHLIB_OPEN
	BSR.W	SCREEN_OPEN
	BSR.W	WINDOW_OPEN
	BSR.W	KEYB_INIT
	BSR.W	COLORS_SET
	MOVEQ	#-1,D0		; Set ok value
	RTS

;--- An error has occured ---

STARTUP_ERROR:
	MOVE.L	ERROR_STACK,A7	; Restore old stackpointer
	MOVEQ	#0,D0		; Set error value
	RTS			; Return to main to main routine

;*******  Close down system structures  *********

CLOSEDOWN:
	;BSR.S	GP_TIMER_EXIT
	BSR.W	KEYB_EXIT
	BSR.W	WINDOW_CLOSE
	BSR.W	SCREEN_CLOSE
	BSR.W	GRAPHLIB_CLOSE
	BRA.W	INTULIB_CLOSE

;*******  Find our task  *******

TASK_FIND:
	SUB.L	A1,A1		; a1 = 0 Our task
	MOVE.L	$4.W,A6		; Exec pointer	
	JSR	FINDTASK(A6)	; Call Findtask
	MOVE.L	D0,TASK_PTR	; Store the pointer for our task
	RTS

;*******  Set the screen colors *******

COLORS_SET:
	MOVE.L	SCREEN_HANDLE(PC),A0	; Get screen handle
	LEA.L	44(A0),A0		; Get the screens viewport

	MOVE.L	GRAPHICS_BASE(PC),A6
	LEA.L	COLORS(PC),A1		; Pointer to the color list
	MOVEQ	#16,D0			; 32 colors to set
	JMP	LOADRGB4(A6)		; Set the colors

;-------------------------------------------------------
; GP_TIMER
gp_timer_dev:	ds.b	512
gp_time_req:	dc.l	0
gp_timer_first:	dc.l	0
gp_s_timer:	DC.B	'timer.device',0,0
gp_time_out: 	ds.b 8
gp_time_out2: 	ds.b 8
gp_timer_bool:	dc.l 0
	even
GP_TIMER_EXIT:
	lea     gp_timer_dev(pc),a1
	move.l  $4.w,a6
	jmp     _LVOCloseDevice(a6)
	
GP_TIMER:	
	tst.l	gp_timer_bool(pc)
	bne	.time_open
	lea 	gp_s_timer(pc),a0
	lea	gp_timer_dev(pc),a1
	moveq	#0,d0
	moveq	#0,d1
	jsr	_LVOOpenDevice(a6)
	tst.l	d0
	bne	STARTUP_ERROR
	lea	gp_timer_bool(pc),a0
	move.l	#1,(a0)
.time_open	
	lea	gp_timer_dev(pc),a1
	move.l	IO_DEVICE(a1),a6 
	
	lea 	gp_time_out(pc),a0
	jsr 	_LVOReadEClock(a6)
		
	lea 	gp_time_out(pc),a0
	move.l	4(a0),d1
	move.l	#12,d0
	lsr.l	d0,d1
	
	;move.l	IOTV_TIME+TV_MICRO(a0),d2
	
	tst.l	gp_timer_first(pc)
	bne	.no_first
	lea	gp_timer_first(pc), a0
	move.l	d1,(a0) 
.no_first
	move.l	d1,d0
	sub.l	gp_timer_first(pc),d0
	rts
;****** Initialize keyboardroutine *******

KEYB_INIT:
	MOVE.L	$4.W,A6
	LEA	CONSOLE_NAME(PC),A0	; Pointer to "Console.Device"
	LEA	IO_REQUEST(PC),A1	; Io Buffer
	MOVEQ	#-1,D0			; Flags
	MOVEQ	#0,D1			; Unit
	JSR	_LVOOpenDevice(A6)		
	TST.L	D0			; An error
	BNE.W	STARTUP_ERROR		; Error quit !!

	MOVE.L	IO_REQUEST+20,CONSOLE_DEVICE	; Get console device
	MOVE.L	WINDOW_HANDLE(PC),A0	; Window Handle
	MOVE.L	$56(A0),KEY_PORT	; Get this windows keyport
	RTS

;****** Exit keyboard ******

KEYB_EXIT:
	LEA	IO_REQUEST(PC),A1
	MOVE.L	$4.W,A6
	JMP	_LVOCloseDevice(A6)

;******* Open Intution-Library *******

INTULIB_OPEN:
	MOVE.L	$4.W,A6
	LEA	INTUITION_NAME(PC),A1	; Pointer to "intuition.library"
	JSR	OPENLIB(A6)
	MOVE.L	D0,INTUITION_BASE	; Store pointer
	BEQ.L	STARTUP_ERROR		; If error jump
	RTS

;******* Close intution-library *******

INTULIB_CLOSE:
	MOVE.L	$4.W,A6
	MOVE.L	INTUITION_BASE(PC),A1
	JMP	CLOSELIB(A6)

;******* Open Graphics-Library *******

GRAPHLIB_OPEN:
	MOVE.L	$4.W,A6
	LEA	GRAPHICS_NAME(PC),A1	; Pointer to "graphics.library"
	JSR	OPENLIB(A6)
	MOVE.L	D0,GRAPHICS_BASE	; Store pointer
	BEQ.L	STARTUP_ERROR		; If error jump
	RTS

;******* Close Graphics-library *******

GRAPHLIB_CLOSE:
	MOVE.L	$4.W,A6
	MOVE.L	GRAPHICS_BASE(PC),A1
	JMP	CLOSELIB(A6)

;******* Open Main Screen *******

SCREEN_OPEN:
	LEA.L	gp_screen_def(PC),A0	; Pointer to screen definitions
	MOVE.L	INTUITION_BASE(PC),A6	; Get intuition base
	JSR	OPENSCREEN(A6)		; Open the screen
	MOVE.L	D0,SCREEN_HANDLE
	BEQ.L	STARTUP_ERROR		; If not opened => error
	MOVE.L	D0,A0
	LEA.L	$C0(A0),A0		; Get bitplane pointers
	LEA.L	gp_p_bp1(PC),A1
	MOVE.L	(A0)+,(A1)+		; Bitplane 1
	MOVE.L	(A0)+,(A1)+		; Bitplane 2
	MOVE.L	(A0)+,(A1)+		; Bitplane 3
	MOVE.L	(A0)+,(A1)+		; Bitplane 4
	MOVE.L	(A0)+,(A1)+		; Bitplane 5
	MOVE.L	(A0)+,(A1)+		; Bitplane 6
	RTS

;******* Close Main Screen *******

SCREEN_CLOSE:
	MOVE.L	SCREEN_HANDLE(PC),A0
	MOVE.L	INTUITION_BASE(PC),A6
	JMP	CLOSESCREEN(A6)

;******* OPEN MAIN WINDOW *******

WINDOW_OPEN:
	MOVE.L	INTUITION_BASE(PC),A6	; Pointer to intuition library
	LEA	WINDOW_DEFS(PC),A0	; Pointer to window definitions
	JSR	OPENWINDOW(A6)
	MOVE.L	D0,WINDOW_HANDLE	; Store window handle
	BEQ.L	STARTUP_ERROR		; Error jump
	MOVE.L	TASK_PTR(PC),A0		; Get task pointer
	MOVE.L	$B8(A0),TASK_OLDWINDOW	; Store the old window
	MOVE.L	D0,$B8(A0)		; Make Reguesters turn up on this
	RTS				; Window
	
;******* CLOSE MAIN WINDOW *******

WINDOW_CLOSE:
	MOVE.L	TASK_PTR(PC),A0		; Get task ptr
	MOVE.L	TASK_OLDWINDOW(PC),$B8(A0)	; Restore old window
	MOVE.L	INTUITION_BASE(PC),A6
	MOVE.L	WINDOW_HANDLE(PC),A0
	JMP	CLOSEWINDOW(A6)

;******* GET KEY PRESS *******

KEYB_GETKEY:
	MOVE.W	KEYB_OUTBUFFER(PC),D0	; Buffer output pointer
	CMP.W	KEYB_INBUFFER(PC),D0	; Is buffer empty
	BNE.S	KEYB_STILLKEYSINBUFFER	; No ??
	BSR.W	KEYB_GETKEYS		; Empty, Wait on a key from
	BRA.S	KEYB_GETKEY		; the keyboard

KEYB_STILLKEYSINBUFFER:
	ADDQ.B	#1,KEYB_OUTBUFFER+1	; Increase out pointer
	LEA	KEYB_BUFFER(PC),A0	; Pointer to buffer
	MOVE.B	(A0,D0.W),D0		; Get the oldest key
	RTS

;******* GET KEY STRING *******

KEYB_GETKEYS:
	MOVE.L	KEY_PORT(PC),A5	; Our key port
	MOVE.L	A5,A0
	MOVE.L	$4.W,A6
	JSR	WAITPORT(A6)	; Wait for message on the port
	MOVE.L	A5,A0
	JSR	GETMSG(A6)	; Get the message
	MOVE.L	D0,KEY_MSG
	BEQ.S	KEYB_GETKEYS	; No message, strange, jump again

	MOVE.L	D0,A3		; Msg now in A3
	MOVE.L	20(A3),D3	; Get message type

;---  Check if raw key  ---

	MOVE.L	D3,D1
	AND.L	#RAWKEY,D1	; Was it a raw key ??
	BEQ.L	KEYB_ANSWER	; If no just answer

;---  Key Recieved  ---

	MOVE.W	24(A3),D4	; Key code
	BTST	#7,D4		; Bit 7 - Key release
	BNE.L	KEYB_ANSWER		; We dont need them
	MOVE.W	26(A3),D5	; QUALIFIER
	MOVE.L	28(A3),D6	; IADDRESS
	MOVE.W	D4,IECODE	; TRANSFER CODE
	MOVE.W	D5,IEQUAL	; QUALIFIERS
	MOVE.L	D6,IEADDR	; AND POINTER TO OLD KEYS

;---  Convert to ascii  ---

	LEA	MY_EVENT,A0	; Pointer to event structure
	LEA	KEY_BUFFER,A1	; Convert buffer
	MOVEQ	#80,D1		; Max 80 characters
	SUB.L	A2,A2		; A2 = 0 Keymap - Default
	MOVE.L	CONSOLE_DEVICE,A6
	JSR	RAWKEYCONVERT(A6) ; Convert the rawkey into Ascii

;---  Copy keys to buffer  ---

; d0 = number of chars in the convert buffer

KEYB_COPY_D0_CHARS:
	SUBQ.W	#1,D0
	BMI.S	KEYB_ANSWER		; No chars ??
	LEA	KEY_BUFFER(PC),A1
	LEA	KEYB_BUFFER(PC),A0
	MOVE.W	KEYB_INBUFFER,D1
.LOOP:	MOVE.B	(A1)+,(A0,D1.W)		; Copy the keys to the normal
	ADDQ.B	#1,D1			;  buffer.
	DBF	D0,.LOOP
	MOVE.W	D1,KEYB_INBUFFER
	BRA.W	KEYB_ANSWER		; Answer

;******* ANSWER KEYPRESS *******

KEYB_ANSWER:
	MOVE.L	KEY_MSG(PC),A1
	MOVE.L	$4.W,A6
	JMP	REPLYMSG(A6)		; Reply the message

gp_screen_def:
	DC.W	0,0		; X-Y position
	DC.W	320		; Width
	DC.W	256		; Hight
	DC.W	6		; Depth
	DC.B	0,1		; Pen colors
	DC.W	$6600		; V_HIRES
	DC.W	CUSTOMSCREEN
	DC.L	FONT_ATTR	; use Topaz 8 as standard font
	DC.L	SCREEN_NAME
	DC.L	0
	DC.L	0

;***  Window structure  ***

WINDOW_DEFS:
	dc.w	0,0		; X-Y position
	dc.w	320		; Current width
	dc.w	256		; Current higth
	dc.b	0,1
	dc.l	RAWKEY		; Report only raw keys
	dc.l	BACKDROP+BORDERLESS+ACTIVATE+RMBTRAP
	dc.l	NULL
	dc.l	NULL
	DC.L	REQUESTER_NAME	; Window name
SCREEN_HANDLE:
	dc.l	NULL	;custom screen pointer
	dc.l	NULL
	dc.w	320		; Min width 
	dc.w	256		; Min higth
	dc.w	320		; Max width
	dc.w	256		; Max higth
	dc.w	CUSTOMSCREEN	; A DUALPF? window
	EVEN

;---  Topaz font  ---

FONT_ATTR:
	DC.L	FONT_NAME	; Name
	DC.W	8		; Size
	DC.B	0
	DC.B	0
	DC.W	8		; Size

COLORS:
	; elõtér - azaz a fülke
	DC.W	$0000,$0111,$0323,$0534
	DC.W	$0744,$0985,$0120,$0150 
	; hatter
	DC.W	$0000,$0303,$0550,$0077
	DC.W	$0909,$0bb0,$00dd,$0f0f 
	
	
		
	
FONT_NAME:		DC.B	'topaz.font',0

CONSOLE_NAME:		DC.B	'console.device',0,0
REQUESTER_NAME:		DC.B	'My Requester',0
SCREEN_NAME:		DC.B	'My Screen - <SPACE> to quit',0
INTUITION_NAME:		DC.B	'intuition.library',0
GRAPHICS_NAME:		DC.B	'graphics.library',0
	even
TIMER_DEVICE:		DC.L	0
CONSOLE_DEVICE:		DC.L	0
INTUITION_BASE:		DC.L	0
GRAPHICS_BASE:		DC.L	0
TASK_OLDWINDOW:		DC.L	0

gp_half:		dc.l	40
gp_p_bp1:		DC.L	0
gp_p_bp2:		DC.L	0
gp_p_bp3:		DC.L	0

gp_p_bp4:		DC.L	0
gp_p_bp5:		DC.L	0
gp_p_bp6:		DC.L	0

gp_p_work_bp0:		DC.L	0
gp_p_work_bp1:		DC.L	0
gp_p_work_bp2:		DC.L	0
gp_p_work_bp3:		DC.L	0



TASK_PTR:		DC.L	0

KEYB_BUFFER:		DCB.B	256,0
KEYB_OUTBUFFER:		DC.W	0
KEYB_INBUFFER:		DC.W	0

ERROR_STACK:		DC.W	0

IO_REQUEST:		DCB.B	32,0
KEY_BUFFER:		DCB.B	80,0
KEY_PORT:		DC.L	0
KEY_MSG:		DC.L	0

MY_EVENT:	DC.L	0	; Insert after each event
EVENT_IECLASS:	DC.B	IECLASS_RAWKEY
		DC.B	0	; SUBCLASS - A Joke
IECODE:		DC.W	0	; RAWKEY - Inserted
IEQUAL:		DC.W	0	; QUALIFIER - SHIFT, CTRL, ETC.
IEADDR:		DC.L	0	; IAddress
		DC.L	0
		DC.L	0	; TimeStamp
WINDOW_HANDLE:	DC.L	0


