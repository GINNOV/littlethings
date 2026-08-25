; ---------------------------------------------------------------------

; scroll.s source

; ---------------------------------------------------------------------

NULL			EQU	0
TRUE			EQU	1
FALSE			EQU   	0
SCROLL_DELAY		EQU	1

SCREEN_HEIGHT		EQU	600
SCREEN_WIDTH		EQU 	640
SCREEN_DEPTH		EQU	3

WINDOW_HEIGHT		EQU	600
WINDOW_WIDTH		EQU	640

TAG_DONE		EQU	0
SA_BASE			EQU 	$80000020 
SA_Left			EQU	SA_BASE+$01
SA_Top			EQU	SA_BASE+$02
SA_Width		EQU	SA_BASE+$02
SA_Height		EQU	SA_BASE+$04
SA_Depth		EQU	SA_BASE+$05
SA_DisplayID		EQU	SA_BASE+$12
SA_Quiet		EQU	SA_BASE+$18
SA_Pens			EQU	SA_BASE+$1A

HIRES_KEY		EQU	$008000

WA_BASE			EQU 	$80000063
WA_Left			EQU	WA_BASE+$01
WA_Top			EQU	WA_BASE+$02
WA_Width		EQU	WA_BASE+$03
WA_Height		EQU	WA_BASE+$04
WA_Title		EQU	WA_BASE+$0B
WA_CustomScreen		EQU	WA_BASE+$0D
WA_DragBar		EQU	WA_BASE+$1F
WA_DepthGadget		EQU	WA_BASE+$20
WA_CloseGadget		EQU	WA_BASE+$21
WA_Backdrop		EQU	WA_BASE+$22
WA_Borderless		EQU	WA_BASE+$25
WA_SimpleRefresh	EQU	WA_BASE+$29


v_LOFCprList		EQU	4
crl_start		EQU	4
sc_ViewPort		EQU	44
sc_BitMap		EQU	184
bm_BytesPerRow		EQU	0
bm_Depth		EQU	5
bm_Planes		EQU	8
wd_RPort		EQU	50
ig_Width		EQU	4
ig_Height		EQU	6

_AbsExecBase		EQU	   4

_LVOOpenLibrary		EQU	-552

_LVOCloseLibrary	EQU	-414

_LVOOpenScreenTagList	EQU	-612

_LVOCloseScreen		EQU	 -66

_LVOOpenWindowTagList	EQU	-606

_LVOCloseWindow		EQU	 -72

_LVODelay		EQU	-198

_LVOViewAddress		EQU	-294

_LVOWaitTOF		EQU	-270

_LVODrawImage		EQU	-114

; ---------------------------------------------------------------------

LINKLIB		MACRO
		move.l	a6,-(a7)
		movea.l	\2,a6
		jsr	\1(a6)
		move.l	(a7)+,a6
		ENDM

CALLSYS		MACRO
		LINKLIB	_LVO\1,\2
		ENDM

; ---------------------------------------------------------------------

		XDEF	_main
		
_main		lea	function_stack,a5	for alloc/dealloc operations
		lea 	lib_names,a2
		lea 	_DOSBase,a3
		move.w	#(LIBRARY_COUNT-1),d3	loop counter
.loop		movea.l	(a2)+,a1		library name pointer
		moveq	#36,d0			minimum library versions
		CALLSYS	OpenLibrary,_AbsExecBase
		move.l	d0,(a3)+		store returned base
		dbeq	d3,.loop

		beq	lib_error_exit				
		
		; all libraries are open and available for use.
						
		jsr	OpenScreen
		beq	closedown

		jsr	OpenWindow
		beq	closedown
		

		; Display is now up and running so now we
		; can get the address of the Intuition View 
		; structure, find the hardware copper list 
		; and locate the copper list instructions that
		; relate to the display's bitplane pointers... 

		CALLSYS	ViewAddress,_IntuitionBase
		move.l	d0,a0			copy to an address register
		move.l	v_LOFCprList(a0),a0
		move.l	crl_start(a0),a0	pointer to start of list

		
.search		cmpi.w	#$e0,(a0)		look at instruction
		beq.s	.searchend		found e0 instruction 
		addq.l	#4,a0			move to next instruction
		bra.s	.search			and keep searching
.searchend	addq.l	#2,a0			move to second word
		move.l	a0,copperlist_p		and store this pointer
	
		move.l	screen_p,a0
		adda.w	#sc_BitMap,a0
		move.l	a0,bitmap_p		store bitmap pointer

		move.l	screen_p,a0
		adda.w	#sc_ViewPort,a0
		move.l	a0,viewport_p		store viewport pointer

set_display	move.l	window_p,a1		window address in a1
		move.l	wd_RPort(a1),a0 	copy rastport pointer into a0
		lea	Image1,a1		pointer to image
		moveq	#0,d0		        left offset
		moveq	#0,d1			top offset
		moveq	#2,d2			columns count
		moveq	#5,d3			rows count
		jsr	DrawBlocks					

		jsr	ScrollUp

change_display	move.l	window_p,a1		window address in a1
		move.l	wd_RPort(a1),a0 	copy rastport pointer into a0
		lea	Image2,a1		pointer to image
		moveq	#0,d0		        left offset
		moveq	#10,d1			top offset
		moveq	#2,d2			columns count
		moveq	#5,d3			rows count
		jsr	DrawBlocks					

		jsr	ScrollDown
			
closedown	move.l	(a5)+,d0		retrieve function pointer
		beq.s	lib_normal_exit
		move.l	d0,a0
		jsr	(a0)			and execute routine if it exists!
		bra.s	closedown


lib_normal_exit	lea	lib_base_end,a3		
		moveq	#LIBRARY_COUNT,d2	library count
		jsr	CloseLibs		close libraries
		moveq	#0,d0			clear d0 for O/S
		rts				and terminate program

lib_error_exit	moveq	#(LIBRARY_COUNT-1),d2	count	
		sub	d3,d2
		jsr	CloseLibs		close libraries
		moveq	#0,d0			clear d0 for O/S
		rts				and terminate program

; ---------------------------------------------------------------------		

; CloseLibs() On entry...

; 	a3 should hold address of the longword location just past 
; 	   that of the first library to close (this is because the 
;	   routine uses a backward reading loop).

; 	d2 should hold count of the number of libraries to close	

CloseLibs	tst.b	d2			test counter
		beq.s	loop_end		
		movea.l	-(a3),a1		get library base
		CALLSYS	CloseLibrary,_AbsExecBase
		subq.b	#1,d2
		bra.s	CloseLibs
loop_end	rts

; ---------------------------------------------------------------------									

; OpenScreen() and CloseScreen() on entry... need no register parameters!


OpenScreen	movem.l	a0-a1/d0-d1,-(a7)	preserve regs
		movea.w	#NULL,a0
		lea	screen_tags,a1		start of  tag list
		CALLSYS	OpenScreenTagList,_IntuitionBase
		move.l	d0,screen_p		save returned pointer
		beq.s	.error
		move.l	#CloseScreen,-(a5)	push deallocation routine address
.error		movem.l	(a7)+,a0-a1/d0-d1	restore regs
		rts

CloseScreen	movem.l	a0-a1/d0-d1,-(a7)	preserve regs
		movea.l	screen_p,a0		screen to close
		CALLSYS	CloseScreen,_IntuitionBase
		movem.l	(a7)+,a0-a1/d0-d1	restore regs
		rts

; ---------------------------------------------------------------------					
				

; OpenWindow() and CloseWindow() on entry... need no register parameters!


OpenWindow	movem.l	a0-a1/d0-d1,-(a7)	preserve regs
		movea.w	#NULL,a0
		lea	window_tags,a1			start of  tag list
		CALLSYS	OpenWindowTagList,_IntuitionBase
		move.l	d0,window_p		save returned pointer
		beq.s	.error
		move.l	#CloseWindow,-(a5)	push deallocation routine address
.error		movem.l	(a7)+,a0-a1/d0-d1	restore regs
		rts

CloseWindow	movem.l	a0-a1/d0-d1,-(a7)	preserve regs
		movea.l	window_p,a0		window to close
		CALLSYS	CloseWindow,_IntuitionBase
		movem.l	(a7)+,a0-a1/d0-d1	restore regs
		rts

; ---------------------------------------------------------------------					

;ScrollUp() on entry... needs no register parameters!

; Register Use: d2 used as a loop counter
;		d3 holds bytes per row
;		d4 holds modified bitplane pointers
;		d5 used as screenline scroll loop counter
;		a2 holds bitmap pointer 
;		a3 holds successive bitplane pointers 
;		a4 after initial temporary use holds copperlist pointer


ScrollUp	movem.l	a0-a4/d0-d5,-(a7)	preserve regs

		move.l	bitmap_p,a2
		move.l	a2,a4			temporary copy
		addq.l	#bm_Planes,a4		a2 now points to bitplanes
		moveq	#0,d2
		move.b	bm_Depth(a2),d2		initialise loop counter
		subq.b	#1,d2			counter goes to -1
		moveq	#0,d3
		move.w	bm_BytesPerRow(a2),d3
		lea	bitplane_copies,a3	points to bitplane copy area
.loop		move.l	(a4)+,(a3)+		copy all bitplane pointers
		dbra	d2,.loop

		move.l	#SCREEN_HEIGHT/2,d5			

do_next_line	move.l	viewport_p,a0
		CALLSYS	WaitTOF,_GfxBase
		moveq	#0,d2
		move.b	bm_Depth(a2),d2		
		subq.b	#1,d2		
		lea	bitplane_copies,a3	


.calculate	add.l	d3,(a3)+		adjust bitplane addresses
 		dbra	d2,.calculate

		moveq	#0,d2
		move.b	bm_Depth(a2),d2		re-initialise pointers	
		subq.b	#1,d2		
		lea	bitplane_copies,a3	
		move.l	copperlist_p,a4

.loop		move.l	(a3)+,d4		get full bitplane pointer
 		swap	d4
 		move.w	d4,(a4)			store pointer upper word
		addq.l	#4,a4			move to next copper instruction
		swap	d4
		move.w	d4,(a4)			store pointer lower word		
		addq.l	#4,a4			move to next copper instruction
		dbra	d2,.loop
		
                move.l	#SCROLL_DELAY,d1	load time delay value
		CALLSYS	Delay,_DOSBase

		dbra	d5,do_next_line
		
		movem.l	(a7)+,a0-a4/d0-d5	restore regs
		rts

; ---------------------------------------------------------------------					

;ScrollDown() on entry... needs no register parameters!


; BUT...        it does expect that ScrollUp() has already
;	  	been used so that fully scrolled bitplane
;		pointers are already in the bitplane pointer
;		copy area!

; Register Use: d2 used as a loop counter
;		d3 holds bytes per row
;		d4 holds modified bitplane pointers
;		d5 used as screenline scroll loop counter
;		a2 holds bitmap pointer 
;		a3 holds successive bitplane pointers 
;		a4 after initial temporary use holds copperlist pointer


ScrollDown	movem.l	a0-a4/d0-d5,-(a7)	preserve regs

		move.l	bitmap_p,a2
		moveq	#0,d3
		move.w	bm_BytesPerRow(a2),d3
		
		move.l	#SCREEN_HEIGHT/2,d5			
do_next_line2	move.l	viewport_p,a0
		CALLSYS	WaitTOF,_GfxBase

		moveq	#0,d2
		move.b	bm_Depth(a2),d2		
		subq.b	#1,d2
		lea	bitplane_copies,a3	
.calculate	sub.l	d3,(a3)+		adjust bitplane addresses
 		dbra	d2,.calculate

		moveq	#0,d2
		move.b	bm_Depth(a2),d2		re-initialise pointers	
		subq.b	#1,d2
		lea	bitplane_copies,a3	
		move.l	copperlist_p,a4

.loop		move.l	(a3)+,d4		get full bitplane pointer
 		swap	d4
 		move.w	d4,(a4)			store pointer upper word
		addq.l	#4,a4			move to next copper instruction
		swap	d4
		move.w	d4,(a4)			store pointer lower word		
		addq.l	#4,a4			move to next copper instruction
		dbra	d2,.loop
		
                move.l	#SCROLL_DELAY,d1	load time delay value
		CALLSYS	Delay,_DOSBase

		dbra	d5,do_next_line2
		
		movem.l	(a7)+,a0-a4/d0-d5	restore regs
		rts

; ---------------------------------------------------------------------					

DrawBlocks:
;		Requires following parameters on entry...
;		a0 = window rastport pointer
;		a1 = image pointer
;		d0 = starting left offset value
;		d1 = starting top offset value
;		d2 = required horizontal block count
;		d3 = required vertical block count

		movem.l	d0-d7/a0-a6,-(sp)		preserve regs
		move.l	_IntuitionBase,a6		library base
		move.l	a0,a2				rastport pointer
		move.l	a1,a3			 	image pointer
		move.w	d0,d6				d6 = current left offset
		move.w	d0,d7				left offset for reuse
		move.w	d1,a4				top offset
		move.w	d2,a5				column count for reuse
		move.w	ig_Width(a1),d4		        image width in d4
		move.w	ig_Height(a1),d5		image height in d5
draw_row	jsr	_LVODrawImage(a6)		
		subq	#1,d2				decrease count
		beq	next_row
		move.w	a4,d1				set top offset
		add.w	d4,d6				form new left offset
draw_row2	move.w	d6,d0				needed for library function call
		move.l	a2,a0				restore rastport pointer
		move.l	a3,a1				restore image pointer
		bra	draw_row			keep going
next_row	subq	#1,d3				decrease count
		beq	draw_end
		move.w	d7,d6				reset start left offset for row
		move.w	a5,d2				reset column count
		move.w	a4,d1
		add.w	d5,d1
		move.w	d1,a4				top offset for next row
		bra	draw_row2
draw_end	movem.l	(sp)+,d0-d7/a0-a6		restore regs
		rts
; ---------------------------------------------------------------------					


_DOSBase	ds.l 	1
_GfxBase	ds.l 	1
_IntuitionBase	ds.l 	1
lib_base_end					;end of library base variables

window_p	ds.l 	1
viewport_p	ds.l	1
copperlist_p	ds.l	1
bitmap_p	ds.l	1
bitplane_copies ds.l	8

screen_pens	dc.l	$FFFFFFFF

screen_tags     dc.l	SA_DisplayID,HIRES_KEY
		dc.l	SA_Quiet,TRUE
		dc.l	SA_Left,0
		dc.l	SA_Top,0
		dc.l	SA_Width,SCREEN_WIDTH
		dc.l	SA_Height,SCREEN_HEIGHT
		dc.l	SA_Depth,SCREEN_DEPTH
		dc.l	SA_Pens,screen_pens
		dc.l	TAG_DONE,NULL


window_tags	dc.l	WA_CustomScreen
screen_p	ds.l	1
		dc.l	WA_Left,0
		dc.l	WA_Top,0
		dc.l	WA_Width,WINDOW_WIDTH
		dc.l	WA_Height,WINDOW_HEIGHT
		dc.l	WA_SimpleRefresh,TRUE
		dc.l	WA_DragBar,FALSE
		dc.l	WA_Title,NULL
		dc.l 	WA_Borderless,TRUE
		dc.l	WA_Backdrop,TRUE
		dc.l    WA_DepthGadget,FALSE
		dc.l	WA_CloseGadget,FALSE
		dc.l	TAG_DONE,NULL

stack_space	ds.l	2			
function_stack	dc.l	NULL			top of function stack

LIBRARY_COUNT	EQU	3
lib_names	dc.l lib1,lib2,lib3

lib1		dc.b 'dos.library',NULL
lib2		dc.b 'graphics.library',NULL
lib3		dc.b 'intuition.library',NULL


			SECTION Image,DATA_C

Image1:
	dc.w	0,0	;XY origin relative to container TopLeft
	dc.w	320,60	;Image width and height in pixels
	dc.w	3	;number of bitplanes in Image
	dc.l	ImageData1	;pointer to ImageData
	dc.b	$0007,$0000	;PlanePick and PlaneOnOff
	dc.l	NULL	;next Image structure
ImageData1:
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0004,$0000,$0000,$0000
	dc.w	$0001,$0000,$0000,$0000,$0400,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$000E,$0000,$0000,$0000,$0003,$8000,$0000,$0000
	dc.w	$0E00,$0000,$1000,$0000,$0000,$0400,$0000,$4000
	dc.w	$0000,$0000,$0000,$0000,$000E,$0000,$0000,$0000
	dc.w	$0003,$8000,$0000,$0000,$0E00,$0000,$3800,$0000
	dc.w	$0000,$0E00,$0000,$E000,$0000,$0000,$0000,$0000
	dc.w	$001F,$0000,$0000,$0000,$0007,$C000,$0000,$0000
	dc.w	$1F00,$0000,$3800,$0000,$0000,$0E00,$0000,$E000
	dc.w	$0000,$0000,$0000,$0000,$001D,$0000,$0000,$0000
	dc.w	$0007,$4000,$0000,$0000,$1D00,$0000,$7C00,$0000
	dc.w	$0000,$1F00,$0001,$F000,$0000,$0000,$0000,$0000
	dc.w	$003F,$8000,$0000,$0000,$000F,$E000,$0000,$0000
	dc.w	$3F80,$0000,$7400,$0000,$0000,$1D00,$0001,$D000
	dc.w	$0000,$0000,$0000,$0000,$002E,$8000,$0000,$0000
	dc.w	$000B,$A000,$0000,$0000,$2E80,$0000,$FE00,$0000
	dc.w	$0000,$3F80,$0003,$F800,$0000,$0000,$0000,$0000
	dc.w	$006E,$C000,$0000,$0000,$001B,$B000,$0000,$0000
	dc.w	$6EC0,$0000,$BA00,$0000,$0000,$2E80,$0002,$E800
	dc.w	$0000,$0000,$0000,$0000,$004E,$4000,$0000,$0000
	dc.w	$0013,$9000,$0000,$0000,$4E40,$0001,$BB00,$0000
	dc.w	$0000,$6EC0,$0006,$EC00,$0000,$0000,$0000,$0000
	dc.w	$000E,$0000,$0000,$0000,$0003,$8000,$0000,$0000
	dc.w	$0E00,$0001,$3900,$0000,$0000,$4E40,$0004,$E400
	dc.w	$0000,$0000,$0000,$0000,$000E,$0000,$0000,$0000
	dc.w	$0003,$8000,$0000,$0000,$0E00,$0000,$3800,$0000
	dc.w	$0000,$0E00,$0000,$E000,$0000,$0000,$0000,$0000
	dc.w	$000E,$0000,$0000,$0000,$0003,$8000,$0000,$0000
	dc.w	$0E00,$0000,$3800,$0000,$0000,$0E00,$0000,$E000
	dc.w	$0000,$0000,$0000,$0000,$000E,$0000,$0000,$0000
	dc.w	$0003,$8000,$0000,$0000,$0E00,$0000,$3800,$0000
	dc.w	$0000,$0E00,$0000,$E000,$0000,$0000,$0000,$0000
	dc.w	$000E,$0000,$0000,$0000,$0003,$8000,$0000,$0000
	dc.w	$0E00,$0000,$3800,$0000,$0000,$0E00,$0000,$E000
	dc.w	$0000,$0000,$0000,$0000,$000E,$0000,$0000,$0000
	dc.w	$0003,$8000,$0000,$0000,$0E00,$0000,$3800,$0000
	dc.w	$0000,$0E00,$0000,$E000,$0000,$0000,$0000,$0000
	dc.w	$000E,$0000,$0000,$0000,$0003,$8000,$0000,$0000
	dc.w	$0E00,$0000,$3800,$0000,$0000,$0E00,$0000,$E000
	dc.w	$0000,$0000,$0000,$0000,$000E,$0000,$0000,$0000
	dc.w	$0003,$8000,$0000,$0000,$0E00,$0000,$3800,$0000
	dc.w	$0000,$0E00,$0000,$E000,$0000,$0000,$0000,$0000
	dc.w	$000E,$0000,$0000,$0000,$0003,$8000,$0000,$0000
	dc.w	$0E00,$0000,$3800,$0000,$0000,$0E00,$0000,$E000
	dc.w	$0000,$0000,$0000,$0000,$000E,$0000,$0000,$0000
	dc.w	$0003,$8000,$0000,$0000,$0E00,$0000,$3800,$0000
	dc.w	$0000,$0E00,$0000,$E000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$3800,$0000,$0000,$0E00,$0000,$E000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$7FFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
	dc.w	$7FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFE,$7FFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
	dc.w	$7FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFE,$7FFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
	dc.w	$7FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFE,$7FFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
	dc.w	$7FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFE,$7FFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
	dc.w	$7FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFE,$7FFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
	dc.w	$7FE0,$01CF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$E3FF,$FFFF,$FFFF,$FFFF,$FFC7,$1E7F,$FFFF
	dc.w	$FFFF,$FFFF,$FEFF,$FFFE,$7FF9,$F9CF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$F3FF,$FFFF,$FFFF
	dc.w	$FFFF,$FFE7,$9E7F,$FFFF,$FFFF,$FFFF,$FC7F,$FFFE
	dc.w	$7FF9,$FDFF,$FFFF,$F7FF,$FFFF,$FFFF,$FFFB,$FFFF
	dc.w	$FF7F,$F3FF,$FFFF,$FFFF,$FFFF,$FFE7,$9FFF,$FFFF
	dc.w	$FFFF,$FFFF,$FC7F,$FFFE,$7FF9,$FDFF,$FFFF,$E7FF
	dc.w	$FFFF,$FFFF,$FFF3,$FFFF,$FE7F,$F3FF,$FFFF,$FFFF
	dc.w	$FFFF,$FFE7,$9FFF,$FFFF,$FFFF,$FFFF,$FC7F,$FFFE
	dc.w	$7FF9,$FFFF,$FFFF,$E7FF,$FFFF,$FFFF,$FFF3,$FFFF
	dc.w	$FE7F,$F3FF,$FFFF,$FFFF,$FFFF,$FFE7,$9FFF,$FFFF
	dc.w	$FFFF,$FFFF,$FC7F,$FFFE,$7FF9,$FF8E,$27C1,$80FC
	dc.w	$3861,$E1FF,$E0C0,$7078,$980F,$F23C,$387F,$C1F8
	dc.w	$389F,$87E7,$9C71,$8FF0,$1FE3,$C711,$FC7F,$FFFE
	dc.w	$7FF9,$FBCF,$23B9,$E7FE,$7CF3,$9CFF,$DCF3,$E63C
	dc.w	$8E7F,$F18E,$7CFF,$B9E7,$1C8E,$31E7,$9E79,$07E6
	dc.w	$7FF3,$E78C,$7C7F,$FFFE,$7FF9,$FBCF,$1F3D,$E7FE
	dc.w	$7CF7,$BE7F,$9EF3,$E73C,$7E7F,$F3CE,$7DFF,$3DEF
	dc.w	$9C7E,$79E7,$9E78,$E3CF,$3FF3,$E79E,$7C7F,$FFFE
	dc.w	$7FF8,$03CF,$3F1F,$E7FF,$3CF7,$3E7F,$8FF3,$FF3C
	dc.w	$FE7F,$F3E7,$3DFF,$1FCF,$FCFC,$FCE7,$9E79,$F3CF
	dc.w	$3FF3,$E79F,$3EFF,$FFFE,$7FF9,$FBCF,$3F8F,$E7FF
	dc.w	$3CF7,$007F,$C7F3,$FC3C,$FE7F,$F3E7,$3DFF,$8FCF
	dc.w	$FCFC,$FCE7,$9E79,$F3CF,$3FF3,$E79F,$3EFF,$FFFE
	dc.w	$7FF9,$FBCF,$3F83,$E7FF,$3A6F,$3FFF,$C1F3,$F13C
	dc.w	$FE7F,$F3E7,$3BFF,$83CF,$FCFC,$FCE7,$9E79,$F3CF
	dc.w	$3FF3,$E79F,$3EFF,$FFFE,$7FF9,$FFCF,$3FE1,$E7FF
	dc.w	$9A6F,$3FFF,$F0F3,$E73C,$FE7F,$F3E7,$9BFF,$E1CF
	dc.w	$FCFC,$FCE7,$9E79,$F3E6,$7FF3,$E79F,$3EFF,$FFFE
	dc.w	$7FF9,$FFCF,$3FF8,$E7FF,$966F,$3FFF,$FC73,$CF3C
	dc.w	$FE7F,$F3E7,$9BFF,$F8CF,$FCFC,$FCE7,$9E79,$F3E0
	dc.w	$FFF3,$E79F,$3FFF,$FFFE,$7FF9,$FFCF,$3FFC,$E7FF
	dc.w	$975F,$1FFF,$FE73,$CF3C,$FE7F,$F3E7,$97FF,$FCC7
	dc.w	$FCFC,$FCE7,$9E79,$F3E7,$FFF3,$E79F,$3FFF,$FFFE
	dc.w	$7FF9,$FFCF,$3F7C,$E7FF,$C71F,$8F7F,$BE73,$CE3C
	dc.w	$FE7F,$F3CF,$C7FF,$7CE3,$DCFE,$79E7,$9E79,$F3CF
	dc.w	$FFF1,$C79E,$7FFF,$FFFE,$7FF9,$FFCF,$3F39,$E6FF
	dc.w	$C71F,$80FF,$9CF3,$413C,$FE6F,$F18F,$C7FF,$39E0
	dc.w	$3CFE,$31E7,$9E79,$F3C0,$7FF8,$278C,$7CFF,$FFFE
	dc.w	$7FE0,$7F86,$1F07,$F1FF,$EFBF,$E1FF,$83F8,$E398
	dc.w	$7F1F,$F43F,$EFFF,$07F8,$787F,$87C3,$0C30,$E1E0
	dc.w	$1FFC,$6391,$FCFF,$FFFE,$7FFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$CFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFCF,$CFFF,$FF9F,$FFFF,$FFFE
	dc.w	$7FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$DFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FF9F
	dc.w	$EFFF,$FF9F,$FFFF,$FFFE,$7FFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$9FFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FF9F,$CFFF,$FF9F,$FFFF,$FFFE
	dc.w	$7FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFC,$3FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FF87
	dc.w	$1FFF,$FF9F,$FFFF,$FFFE,$7FFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFC,$7FFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFE0,$7FFF,$FF0F,$FFFF,$FFFE
	dc.w	$7FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFE,$7FFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
	dc.w	$7FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFE,$7FFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
	dc.w	$7FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFE,$7FFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
	dc.w	$7FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFE,$7FFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
	dc.w	$7FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFE,$7FFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
	dc.w	$7FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFE,$7FFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
	dc.w	$7FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFE,$7FFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
	dc.w	$7FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFE,$7FFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
	dc.w	$7FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFE,$7FFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
	dc.w	$7FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFE,$7FFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
	dc.w	$7FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFE,$7FFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
	dc.w	$7FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFE,$7FFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000




Image2:
	dc.w	0,0	;XY origin relative to container TopLeft
	dc.w	320,59	;Image width and height in pixels
	dc.w	3	;number of bitplanes in Image
	dc.l	ImageData2	;pointer to ImageData
	dc.b	$0007,$0000	;PlanePick and PlaneOnOff
	dc.l	NULL	;next Image structure
ImageData2:
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$7FFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
	dc.w	$7FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFE,$7FFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
	dc.w	$7FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFE,$7FFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
	dc.w	$7FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFE,$7FFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
	dc.w	$7FFF,$FFFD,$FFFF,$FFE3,$FFFC,$7FFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FE7F,$FFFC,$7FFF,$CFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFE,$7FFF,$FFF8,$FFFF,$FFF3
	dc.w	$FFFE,$7FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FE7F
	dc.w	$FFFE,$7FFF,$CFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
	dc.w	$7FFF,$FFF8,$FFFF,$FFF3,$FFBE,$7FFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFD,$FFFE,$7FFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFE,$7FFF,$FFFA,$7FFF,$FFF3
	dc.w	$FF3E,$7FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFF9
	dc.w	$FFFE,$7FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
	dc.w	$7FFF,$FFF6,$7FFF,$FFF3,$FF3E,$7FFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFF9,$FFFE,$7FFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFE,$7FFF,$FFF7,$3F18,$FF13
	dc.w	$FC06,$63FC,$3C63,$FF0E,$1878,$7FF8,$30E1,$8460
	dc.w	$3C1E,$63FF,$8E31,$E3F8,$3F80,$F87E,$0FFF,$FFFE
	dc.w	$7FFF,$FFE7,$3F90,$7C63,$FF3E,$41F3,$9E41,$FF9F
	dc.w	$3CE7,$3FF7,$39F3,$CE79,$F38E,$41FF,$CF20,$C1F3
	dc.w	$1F33,$E73D,$CFFF,$FFFE,$7FFF,$FFEF,$3F8E,$3CF3
	dc.w	$FF3E,$38F7,$CE38,$FF9F,$3DEF,$9FE7,$B9F3,$DE79
	dc.w	$F7CE,$38FF,$CF1C,$38F3,$9E79,$EF99,$EFFF,$FFFE
	dc.w	$7FFF,$FFEF,$9F9F,$39F3,$FF3E,$7CE7,$CE7C,$FFCF
	dc.w	$3DCF,$9FE3,$FCF3,$DE79,$E7FE,$7CFF,$CF3E,$7CFF
	dc.w	$9E79,$CF98,$FFFF,$FFFE,$7FFF,$FFCF,$9F9F,$39F3
	dc.w	$FF3E,$7CE0,$0E7C,$FFCF,$3DC0,$1FF1,$FCF3,$DE79
	dc.w	$E7FE,$7CFF,$CF3E,$7CFE,$1E79,$C01C,$7FFF,$FFFE
	dc.w	$7FFF,$FFC0,$1F9F,$39F3,$FF3E,$7CE7,$FE7C,$FFCE
	dc.w	$9BCF,$FFF0,$7CE9,$BE79,$E7FE,$7CFF,$CF3E,$7CF8
	dc.w	$9E79,$CFFC,$1FFF,$FFFE,$7FFF,$FFDF,$CF9F,$39F3
	dc.w	$FF3E,$7CE7,$FE7C,$FFE6,$9BCF,$FFFC,$3E69,$BE79
	dc.w	$E7FE,$7CFF,$CF3E,$7CF3,$9F33,$CFFF,$0FFF,$FFFE
	dc.w	$7FFF,$FF9F,$CF9F,$39F3,$FF3E,$7CE7,$FE7C,$FFE5
	dc.w	$9BCF,$FFFF,$1E59,$BE79,$E7FE,$7CFF,$CF3E,$7CE7
	dc.w	$9F07,$CFFF,$C7FF,$FFFE,$7FFF,$FFBF,$CF9F,$39F3
	dc.w	$FF3E,$7CE3,$FE7C,$FFE5,$D7C7,$FFFF,$9E5D,$7E79
	dc.w	$E3FE,$7CFF,$CF3E,$7CE7,$9F3F,$C7FF,$E7FF,$FFFE
	dc.w	$7FFF,$FFBF,$E79F,$3CF3,$FF3E,$7CF1,$EE7C,$FFF1
	dc.w	$C7E3,$DFEF,$9F1C,$7E79,$F1EE,$7CFF,$CF3E,$7CE7
	dc.w	$1E7F,$E3DB,$E7FF,$FFFE,$7FFF,$FF3F,$E79F,$3C63
	dc.w	$FF36,$7CF0,$1E7C,$FFF1,$C7E0,$3FE7,$3F1C,$7E79
	dc.w	$B01E,$7CFF,$CF3E,$7CE0,$9E03,$E039,$CFFF,$FFFE
	dc.w	$7FFF,$FC0F,$810E,$1F09,$FF8C,$387C,$3C38,$7FFB
	dc.w	$EFF8,$7FE0,$FFBE,$FC3C,$7C3C,$387F,$861C,$3871
	dc.w	$CF00,$F878,$3FFF,$FFFE,$7FFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FE7E,$7FFF,$FFFF,$FFFE
	dc.w	$7FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FCFF,$7FFF,$FFFF,$FFFE,$7FFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FCFE,$7FFF,$FFFF,$FFFE
	dc.w	$7FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FC38,$FFFF,$FFFF,$FFFE,$7FFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FF03,$FFFF,$FFFF,$FFFE
	dc.w	$7FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFE,$7FFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
	dc.w	$7FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFE,$7FFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FF1F,$FE3F,$F8FE
	dc.w	$7FFF,$FFFF,$FFFF,$F8FF,$FFFF,$FFFF,$FFE3,$8FFF
	dc.w	$E3FF,$FFFF,$FFFF,$FF8F,$38FF,$FFFF,$FFC7,$FF3F
	dc.w	$FFDF,$FF1F,$FE3F,$F8FE,$7FFF,$FFFF,$FFFF,$FCFF
	dc.w	$FFFF,$FFFF,$FFF3,$CFFF,$F3FF,$FFFF,$FFFF,$FFCF
	dc.w	$3CFF,$FFFF,$FFE7,$FF3F,$FF8F,$FF1F,$FE3F,$F8FE
	dc.w	$7FFF,$FFFF,$FFFF,$FCFF,$FFFF,$FFFF,$FFF3,$CFFF
	dc.w	$F3FF,$FFFF,$FFFF,$FFCF,$FCFF,$FFFF,$FBE7,$FFFF
	dc.w	$FF8F,$FF1F,$FE3F,$F8FE,$7FFF,$FFFF,$FFFF,$FCFF
	dc.w	$FFFF,$FFFF,$FFF3,$CFFF,$F3FF,$FFFF,$FFFF,$FFCF
	dc.w	$FCFF,$FFFF,$F3E7,$FFFF,$FF8F,$FF1F,$FE3F,$F8FE
	dc.w	$7FFF,$FFFF,$FFFF,$FCFF,$FFFF,$FFFF,$FFF3,$CFFF
	dc.w	$F3FF,$FFFF,$FFFF,$FFCF,$FCFF,$FFFF,$F3E7,$FFFF
	dc.w	$FF8F,$FF1F,$FE3F,$F8FE,$7FFF,$FF83,$C63F,$C4FF
	dc.w	$E0FC,$1C4F,$C3F3,$CFFF,$13F0,$F0E1,$8463,$FFCE
	dc.w	$3CC1,$F87F,$C066,$3E3E,$0F8F,$FF1F,$FE3F,$F8FE
	dc.w	$7FFF,$FF31,$E41F,$18FF,$DCF3,$8E47,$18F3,$CFFC
	dc.w	$63C6,$39F3,$CE41,$FFCF,$3CE7,$E73F,$F3E4,$1F3D
	dc.w	$CF8F,$FF1F,$FE3F,$F8FE,$7FFF,$FF39,$E38F,$3CFF
	dc.w	$9EF7,$CE3F,$3CF3,$CFFC,$F3CF,$39F3,$DE38,$FFCF
	dc.w	$3CCF,$EF9F,$F3E3,$8F39,$EF8F,$FF1F,$FE3F,$F8FE
	dc.w	$7FFF,$FFF9,$E7CE,$7CFF,$8FE7,$FE7E,$7E73,$CFF9
	dc.w	$F39F,$9CF3,$DE7C,$FFCF,$3CDF,$CF9F,$F3E7,$CF38
	dc.w	$FFDF,$FF1F,$FE3F,$F8FE,$7FFF,$FFE1,$E7CE,$7CFF
	dc.w	$C7E7,$FE7E,$7E73,$CFF9,$F39F,$9CF3,$DE7C,$FFCF
	dc.w	$3CBF,$C01F,$F3E7,$CF3C,$7FDF,$FB1B,$F637,$D8DE
	dc.w	$7FFF,$FF89,$E7CE,$7CFF,$C1E7,$FE7E,$7E73,$CFF9
	dc.w	$F39F,$9CE9,$BE7C,$FFCF,$3C3F,$CFFF,$F3E7,$CF3C
	dc.w	$1FDF,$F913,$F227,$C89E,$7FFF,$FF39,$E7CE,$7CFF
	dc.w	$F0E7,$FE7E,$7E73,$CFF9,$F39F,$9E69,$BE7C,$FFCF
	dc.w	$3C9F,$CFFF,$F3E7,$CF3F,$0FDF,$FD17,$FA2F,$E8BE
	dc.w	$7FFF,$FE79,$E7CE,$7CFF,$FC67,$FE7E,$7E73,$CFF9
	dc.w	$F39F,$9E59,$BE7C,$FFCF,$3C8F,$CFFF,$F3E7,$CF3F
	dc.w	$C7FF,$FC07,$F80F,$E03E,$7FFF,$FE79,$E7CE,$7CFF
	dc.w	$FE63,$FE7E,$7E73,$CFF9,$F39F,$9E5D,$7E7C,$FFCF
	dc.w	$3CC7,$C7FF,$F3E7,$CF3F,$E7FF,$FE2F,$FC5F,$F17E
	dc.w	$7FFF,$FE71,$E7CF,$3CFF,$BE71,$EE7F,$3CF3,$CFFC
	dc.w	$F3CF,$3F1C,$7E7C,$FFCF,$3CE3,$E3DF,$F3E7,$CF3B
	dc.w	$E7FF,$FE0F,$FC1F,$F07E,$7FFF,$FE09,$E7CF,$18FF
	dc.w	$9CF0,$1E7F,$18F3,$CFFC,$63C6,$3F1C,$7E7C,$FFCF
	dc.w	$3CF1,$E03F,$F367,$CF39,$CF9F,$FF1F,$FE3F,$F8FE
	dc.w	$7FFF,$FF1C,$C387,$C27F,$83FC,$3C3F,$C3E1,$87FF
	dc.w	$09F0,$FFBE,$FC38,$7F86,$1860,$F87F,$F8C3,$8618
	dc.w	$3F9F,$FF1F,$FE3F,$F8FE,$7FFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFBF,$FF7F,$FDFE
	dc.w	$7FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFE,$7FFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
	dc.w	$7FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFE,$7FFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
	dc.w	$7FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFE,$7FFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$00E0,$01C0,$0700,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$00E0,$01C0,$0700
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$00E0,$01C0,$0700,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$00E0,$01C0,$0700
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$00E0,$01C0,$0700,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$00E0,$01C0,$0700
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$00E0,$01C0,$0700,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$00E0,$01C0,$0700
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$00E0,$01C0,$0700,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$00E0,$01C0,$0700
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$04E4,$09C8,$2720,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$06EC,$0DD8,$3760
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$02E8,$05D0,$1740,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$03F8,$07F0,$1FC0
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$01D0,$03A0,$0E80,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$01F0,$03E0,$0F80
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$00E0,$01C0,$0700,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$00E0,$01C0,$0700
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0040,$0080,$0200,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$00E0,$01C0,$0700
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$00E0,$01C0,$0700,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$00E0,$01C0,$0700
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$00E0,$01C0,$0700,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$00E0,$01C0,$0700
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$00E0,$01C0,$0700,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$00E0,$01C0,$0700
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$00E0,$01C0,$0700,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$00E0,$01C0,$0700
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$00E0,$01C0,$0700,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$04E4,$09C8,$2720
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$06EC,$0DD8,$3760,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$02E8,$05D0,$1740
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$03F8,$07F0,$1FC0,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$01D0,$03A0,$0E80
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$01F0,$03E0,$0F80,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$00E0,$01C0,$0700
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$00E0,$01C0,$0700,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0040,$0080,$0200
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000

		END

; ---------------------------------------------------------------------


		