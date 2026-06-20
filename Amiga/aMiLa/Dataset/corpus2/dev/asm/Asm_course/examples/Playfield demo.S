	incdir	df0:include/
	include exec/exec_lib.i
	include exec/memory.i
	include hardware/custom.i
	include graphics/graphics_lib.i

;----------------------------
;-   constant definitions   -  
;---------------------------

custom=$dff000			;base odf cvustom chips
pf1_width	=	40	;playfield 1 byte width
pf1_height	=	200	;lines height
pf1_depth	=	3	;planes depth
pf1_planesize	=	pf1_width*pf1_height
pf1_sizeOf	=	pf1_planesize*pf1_depth 

pf2_width	=	40	;playfield 1 byte width
pf2_height	=	200	;lines height
pf2_depth	=	3	;planes depth
pf2_planesize	=	pf1_width*pf2_height
pf2_sizeOf	=	pf1_planesize*pf2_depth

mem_required	=	pf1_sizeOf+pf2_sizeOf

main:
	lea	gfxLIB(pc),a1		;library to open
	moveq	#$00,d0			;any version
	callexec	OpenLibrary	;Attempt open
	move.l	d0,_gfxBase		;store pointer
	beq	Nolib_exit		;0 pointer=no library
	move.l	#mem_required,d0	;byte size
	move.l	#memf_chip+memf_clear,d1;type of memory required
	callexec	AllocMem	

	move.l	d0,membase		;store pointer
	beq	nomem_exit		;didnt get memory
	bsr	plane_adresses		;insert plain adresses
	bsr	draw_squares		;make patter to bot. plfld
	bsr	fill_top_pf		;make window in top Plfld
	move.l	_gfxBase,a0		;library base
	move.l	50(a0),oldCop		;store system copperlist
	move.l	#NewCop,50(a0)		;insert our copperlist

wait:
	Callgraf	WaitTOF		;wait 4 raster
	bsr 	scroll_playfield	;pixel scroll bottom
					;playfield.
	btst	#6,$bfe001		;Wait for LMB
	bne	wait
	move.l	_gfxBase,a0		;get library base
	move.l	Oldcop,50(a0)		;restore old Copperlist

Dealloc:
	move.l	membase,a1		;deallocate memory
	move.l	#mem_required,d0	
	Callexec	Freemem


NoMem_exit:
	move.l	_gfxBase,a1		;close gfx library
	CallEXEC	closeLibrary


NoLib_exit:
	rts

;----------------------------------------------------------

plane_adresses:
	move.l	membase,d0		;bottom playfield
	move.l	d0,d3			;preserve
	lea	top_planes,a0		;pointer to label in Coplist
	move.l	#pf1_planeSize,d1	;size of 1 plane
	bsr	pa_main			;insert adresses
	move.l	d3,d0			;retrieve pointer
	add.l	#pf1_sizeOf,d0		;Inc. to top Playfield.
	move.l	d0,pf2_base		;store to PF adress
	lea	bottom_planes,a0	;pointer to label in Coplist
	move.l	#pf2_planesize,d1	

pa_main:
	moveq	#$02,d2		;for 3 planes both playfields.

pa_loop:
	move	d0,6(a0)		;insert low word of adress
	swap	d0
	move	d0,2(a0)		;insert high word of adress
	swap 	d0
	add.l	d1,d0			;add plane offset
	lea	8(a0),a0		;incr past plane pointers
	dbra	d2,pa_loop		;for all planes
	rts

;-------------------------------------------------------------

draw_squares:
	move.l	membase,a0		;pointer to bot. PF
	move.l	#$ff00ff00,d0		;pattern to draw
	move	#24,d2			;do block 25 times

ds_outer:
	move	#8*10-1,d3		;10 longwords*10 lines

ds_inner:
	move.l	d0,(a0)+		;write into memory
	dbra	d3,ds_inner		;for 8 lines
	not.l	d0			;invert pattern for chequered effect
	dbra	d2,ds_outer		;for whole PF
	rts

;=====================================================

fill_top_pf:
	move.l	pf2_base,a0		;pointer to top PF
	move.l	a0,a1			;copy pointer
	moveq	#-1,d0			;fill memory pattern.
	move.w	#(pf2_planesize/4)-1,d2	;1 plane

ft_fill_loop:
	move.l	d0,(a0)+		;fill memory
	dbra	d2,ft_fill_loop		;for whole plane
	lea	pf1_width*50+10(a1),a1	;incr to mid-screen

ft_clear_outer:
	moveq	#$04,d2			;longwords to clear

ft_clear_inner:
	move.l	d0,(a1)+		;write to memory
	dbra	d2,ft_clear_inner	
	lea	20(a1),a1		;add module
	dbra	d1,ft_clear_outer
	rts

;================================================================

scroll_playfield:
	lea	newcop,a0		;pointer to copperlist
	move.w	scroll,d0		;scroll value
	addi.w	#$01,d0			;increment
	addi.w	#$0f,d0			;mask of unneded bits
	move.w	d0,scroll		;replace
	move.w 	d0,6(a0)		;and place in relevant register
	rts

;=======================================================

gfxLib:
	dc.b	"graphics.library",0
	even

_gfxbase:	dc.l	0
membase:	dc.l	0
pf2_base:	dc.l	0
oldCop:		dc.l	0
scroll:		dc.w	0

;=============================================================

	section	chipstuff,data_c

newcop:
	dc.w	$0100,$6600,$0102,$0000,$0104,$0060
	dc.w	$0108,$0000,$010a,$0000
	dc.w	$0092,$0038,$0094,$00d0
	dc.w	$008e,$2c81,$0090,$f4c0

top_planes:
	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e8,$0000,$00ea,$0000
	dc.w	$00f0,$0000,$00f2,$0000

bottom_planes:
	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$00ec,$0000,$00ee,$0000
	dc.w	$00f4,$0000,$00f4,$0000

	dc.w	$0180,$0888,$0182,$0026
	dc.w	$0184,$0440,$0186,$0a66
	dc.w	$0188,$06aa,$018a,$0056
	dc.w	$018c,$0340,$018e,$0ddd

	dc.w	$0190,$0000,$0192,$0500
	dc.w	$0194,$0600,$0196,$0a33
	dc.w	$0192,$0eaa,$019a,$00a4
	dc.w	$019c,$004b,$019e,$0fef

	dc.w	$ffff,$fffe

