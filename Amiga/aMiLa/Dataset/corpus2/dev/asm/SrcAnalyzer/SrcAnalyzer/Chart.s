*****************************************************************************
*
* Barchart plotter 	V0.91 (7-8/10/89)	© L. Vanhelsuwé
*
* This program takes a filename as argument.	(1> CHART file)
* It loads the ASCII file in and converts it to the internal representation
* of the barchart data structure.
* The ASCII file is constructed from 1..N (N <50) lines structured as follows:
*  |<decimal number 0..65535> <column label>|
*
* The main feature of the program is the scalability of the chart via the
* intuition sizing gadget.
*
* 27/10/90 Cleaned up program to use EXEC,DOS,INTUI macros...
*	   Changed Chart display so that bar labels are printed just below
*	   bar bases.
* 15/03/91 Changed maximum window size to 8192,8192 for Workbench 2.0 etc...
*	   Made argument decoding more robust (i.e. handle A-Shell !)
*
*
*	**!! WARNING: This program is not generic. It is currently suited
*	**!!		only to display output from SrcAnalyzer
*	**!!	Find comments marked **!! for areas which need generalizing!
*
******************************************************************************

		INCLUDE	std

TOP_CLEARANCE	equ	65	;dragbar,labels
LABELS		equ	52	;enough for "MOVE.L"		**!!
BOT_CLEARANCE	equ	2+LABELS ;

WINDOW_WIDTH	equ	480
WINDOW_LINES	equ	150

WINDOW_IDCMP	equ	REFRESHWINDOW+NEWSIZE+CLOSEWINDOW

STD_FLAGS	equ	WINDOWCLOSE+WINDOWDRAG+WINDOWDEPTH+WINDOWSIZING
WINDOW_FLAGS	equ	STD_FLAGS+SIMPLE_REFRESH+ACTIVATE


GFXR		MACRO
		move.l	rastport,a1
		GFX	\1
		ENDM

;---------------------------------------
START:		move.l	SP,top_level	;save initial for SP for break-outs

		bsr	process_args	;check arguments out

		bsr	open_libraries	;DOS, stdout

		move.l	DOS_LIB_PTR,a6
		move.l	args_ptr,d1
		move.l	#MODE_OLDFILE,d2
		DOS	Open		;open ASCII data file
		move.l	d0,in_fhandle
		bne	got_datafile
		moveq	#-2,d7
		jmp	error
		
got_datafile	move.l	args_ptr,a0		;add data filename to
		lea	window_title,a1	;window name string
copy_filename	move.b	(a0)+,(a1)+
		bne.s	copy_filename

		move.l	INTUI_LIB_PTR,a6
		lea	chart_windowdef,a0
		INTUI	OpenWindow		;open window in Workbench
		move.l	d0,window
		bne	got_window
		moveq	#-1,d7
		jmp	error

got_window	move.w	#WINDOW_WIDTH,w_width
		move.w	#WINDOW_LINES,w_lines
		move.l	d0,a0
		move.l	wd_RPort(a0),rastport	;for later graphics calls
		move.l	wd_UserPort(a0),msgport	;for receiving IDCMP msgs

		bsr	read_data		;read in ASCII data file
		bsr	gen_chart_struct	;cvt data to internal form
		bsr	refresh_window		;repaint barchart

MAIN:		bsr	test_IDCMP		;act on close/refresh msgs

		move.l	DOS_LIB_PTR,a6
		move.l	#25,d1
		DOS	Delay		;sleep for 1/2 sec
		bra	MAIN
;---------------------------------------
test_IDCMP	move.l	4.w,a6
		move.l	msgport,a0
		EXEC	GetMsg			;see if Intuition sent us
		tst.l	d0			;an IntuiMsg
		beq	dummy

		move.l	d0,a1
		move.l	im_Class(a1),imsg_class		;copy relevant info
		move.w	im_Code(a1),imsg_code
		move.l	im_IAddress(a1),imsg_addr
		move.l	im_MouseX(a1),imsg_ratcords
		EXEC	ReplyMsg			;and return msg

		move.l	imsg_class,d0	;find our handler for
		lea	event_routines,a0	;this event
		bra.s	scan_types
possible_event	move.l	(a0)+,a1
		cmp.l	d0,d1
		bne.s	scan_types
		jmp	(a1)			;execute event handler

scan_types	move.l	(a0)+,d1
		bpl.s	possible_event
		rts

event_routines	dc.l	REFRESHWINDOW,refresh_window
		dc.l	CLOSEWINDOW,quit_me
		dc.l	NEWSIZE,size_chart
		dc.l	-1

*		dc.l	VANILLAKEY,keypress
*		dc.l	RAWKEY,keypress
*		dc.l	GADGETUP,intui_gadget
*		dc.l	MOUSEBUTTONS,gadget_press
;---------------------------------------
size_chart	move.l	window,a0		;only if the window
		move.w	wd_Width(a0),d0		;really changed dimension,
		move.w	wd_Height(a0),d1
		cmp.w	w_width,d0
		bne	real_change
		cmp.w	w_lines,d1
		beq	dummy

real_change	move.w	d0,w_width		;should you update vars &
		move.w	d1,w_lines
		bsr	refresh_window		;redraw the lot

		bset	#0,flags		;swallow next refresh msg !
		rts
;---------------------------------------
quit_me		moveq	#0,d7			;normal exit code..
		jmp	error
;---------------------------------------
refresh_window	bclr	#0,flags		;don't refresh twice after a size refr.
		rne

		move.l	GFX_LIB_PTR,a6

		moveq	#0,d0			;clear window pane to BG color
		GFXR	SetAPen

		moveq	#4,d0			;get Window dimensions
		moveq	#10,d1
		move.w	d0,d2
		move.w	d1,d3
		add.w	w_width,d2
		add.w	w_lines,d3
		sub.w	#23,d2
		sub.w	#13,d3
		GFXR	RectFill
		
		lea	chart_data,a4
		bsr	draw_barchart		;and draw new one.
		rts
;---------------------------------------
; Draw entire BarChart in window.
;
; A4 -> chart structure

draw_barchart	move.l	a4,a3
		bsr	find_max		;find highest column
		bsr	find_factor		;calc zoom/shrink factor
		bsr	draw_intervals		;dividing lines & Y scale

		moveq	#0,d4
		move.w	w_width,d4
		sub.w	#50,d4			;usable width of window
		move.w	num_values,d7
		divu	d7,d4			;d4=adjusted width for bars
		moveq	#40,d5			;starting X coord
		subq.w	#1,d7

draw_columns	move.w	(a4)+,d0		;get absolute height
		move.l	(a4)+,a3		;get string ptr
		mulu	factor,d0		;size column
		lsr.l	#8,d0			;256 = 1.0
		move.w	d4,d1
		subq.w	#4,d1			;leave gaps between columns
		bsr	draw_column
		bsr	print_label		;print associated label
		add.w	d4,d5			;goto next bar (inc XCO)
		dbra	d7,draw_columns		;all columns done ?
		rts
;---------------------------------------
; D0/D1 = height/width	D4=column spacing	D5= X coord	D7=column #

draw_column	move.l	GFX_LIB_PTR,a6	;use GRAPHICS library

		tst.w	-6(a4)			;if real height is zero
		beq	dummy			;don't draw anything

		tst.w	d0			;if drawn height is zero
		bne.s	not_neglectable
		move.w	d0,-(SP)
		move.w	d1,-(SP)
		moveq	#2,d0			;then draw strip in
		GFXR	SetAPen
		move.w	(SP)+,d1
		move.w	(SP)+,d0

not_neglectable	move.w	d5,d2			;max x = X + width
		add.w	d1,d2
		move.w	w_lines,d3		;max y = lines -n
		sub.w	#BOT_CLEARANCE,d3
		move.w	d3,d1			;min y = lines -n -height
		sub.w	d0,d1
		move.w	d5,d0			;min x = X
		GFXR	RectFill		;fill rectangle

		moveq	#1,d0			;use normal filling
		GFXR	SetAPen
		rts
;---------------------------------------
; A3 -> C-string	D5= column X

print_label	move.l	GFX_LIB_PTR,a6

		moveq	#RP_JAM2,d0		;2-color chars
		GFXR	SetDrMd

		moveq	#3,d0			;1 pixels : pen 3
		GFXR	SetAPen
		moveq	#2,d0			;0 pixels : pen 2
		GFXR	SetBPen

		move.w	w_lines,d2
		sub.w	#BOT_CLEARANCE-9,d2	;starting Y
		bra.s	wh_chars		;(just under chart bars)

plot_char	move.w	d2,d1			;base Y of char
		move.w	d5,d0			;same X as column
		GFXR	Move			;position pen

		moveq	#1,d0			;1 char to plot
		move.l	a3,a0			;address from char
		GFXR	Text

		addq.w	#1,a3			;advance char ptr
		add.w	#8,d2			;move down vertically

wh_chars	tst.b	(a3)			;EOS ?
		bne.s	plot_char
		rts
;---------------------------------------
draw_intervals	move.l	GFX_LIB_PTR,a6

		moveq	#5-1,d7			;5 divisions
		moveq	#0,d6
		move.w	axis_max,d6		;divide 100% up into 20%
		divu	#5,d6			;interval size
		move.w	d6,d5			;1st height

print_heights	moveq	#2,d0			;switch pen back to normal
		GFXR	SetAPen

		move.w	w_lines,d1		;calc Y-coordinate for next
		sub.w	#BOT_CLEARANCE,d1	;gradient (bottom-to-top)
		move.w	d5,d0
		mulu	factor,d0
		lsr.l	#8,d0
		sub.w	d0,d1
		move.w	d1,d3			;cache current working Y

		moveq	#40,d0			;X1 = 40
		GFXR	Move

		move.w	d3,d1			;Y coord
		move.w	w_width,d0
		sub.w	#20,d0			;horizontal line across window
		GFXR	Draw			;(30,y)-(w-40,y)

		moveq	#0,d0			;now print height
		move.w	d5,d0			;textually
		moveq	#4,d1			;e.g. '0080'
		lea	dec_out,a0
		bsr	bin_to_dec		;make ASCII axis label

		moveq	#4,d0			;crsr_X for text = 4
		move.w	d3,d1			;Y coord
		addq.w	#5,d1			;label slightly lower
		GFXR	Move			;goto printing position

		moveq	#3,d0			;labels printed in diff color
		GFXR	SetAPen

		lea	dec_out,a0		;-> label to print
		moveq	#4,d0			;4 chars long
		GFXR	Text		;print it (next to line)

		add.w	d6,d5			;go up in steps of 20%
		dbra	d7,print_heights
		rts
;---------------------------------------
; A3 -> new chart structure
find_max	moveq	#0,d0			;# of items
		moveq	#0,d1			;maximum height so far
		moveq	#-1,d7			;max 64k values
		bra	wh_values

scan_chart	addq.w	#1,d0			;inc # of items
		cmp.w	d1,d2
		bcs	wh_values		;is this value > max
		move.w	d2,d1			;update max
wh_values	move.w	(a3)+,d2
		tst.l	(a3)+
		dbeq	d7,scan_chart

		move.w	d0,num_values
		move.w	d1,max_value
		rts
;---------------------------------------
; find optimal sizing factor to fit barchart in 

find_factor	move.w	#256,d0			;sample sizing factor = 1.0
		move.w	#100,d2			;'100' = 100 %
		move.w	max_value,d1
		cmp.w	#100,d1			;best fit in 100 lines (100%)
		bgt	halve_max

double_max	add.w	d0,d0			;sample factor *2
		lsr.w	#1,d2			;100 -> 50
		add.w	d1,d1			;max *2
		cmp.w	#100,d1
		blt	double_max

		lsr.w	#1,d0			;undo overshooting
		add.w	d2,d2
		lsr.w	#1,d1
		bra	window_factor
;- - - - - - - -
halve_max	lsr.w	#1,d0			;factor <- factor/2
		add.w	d2,d2			;100 -> 200
		lsr.w	#1,d1			;max <- max/2
		cmp.w	#100,d1
		bgt	halve_max

window_factor	move.w	d2,axis_max

		move.w	w_lines,d1
		sub.w	#TOP_CLEARANCE,d1	;-dragbar/borders/labels
		mulu	d1,d0
		divu	#100,d0
		move.w	d0,factor
		rts
;---------------------------------------
read_data	move.l	4.w,a6
		move.l	#50000,d0		;allocate memory to read **!!
		moveq	#0,d1			;entire file
		EXEC	AllocMem
		move.l	d0,file_buffer
		beq	error

		move.l	DOS_LIB_PTR,a6
		move.l	in_fhandle,d1
		move.l	file_buffer,d2
		move.l	#50000,d3		;**!! should find out how big
		DOS	Read			;file is **!!

		add.l	file_buffer,d0
		move.l	d0,file_end		;calc addr of end of buffer
		rts
;---------------------------------------
gen_chart_struct
		move.l	file_buffer,a0	;ASCII source file
		lea	chart_data,a5	;destination chart structure

convert_file	bsr	get_decimal		;get height value (0..64K)
		move.w	d0,(a5)+		;save value
		move.l	a0,(a5)+		;save label pointer

find_eos	move.b	(a0)+,d0		;find end of label
		cmp.b	#LF,d0			;1st space or LF
		beq	mark_eos
		cmp.b	#SPC,d0
		bne.s	find_eos
		clr.b	-1(a0)

find_eol	cmp.b	#LF,(a0)+
		bne	find_eol
		bra	check_done

mark_eos	clr.b	-1(a0)			;then change into C-string

check_done	cmp.l	file_end,a0		;all lines done ?
		bne.s	convert_file

		move.w	#-1,(a5)+		;mark end of list
		clr.l	(a5)+
		rts
;---------------------------------------
; A0 -> start of argument line		**!!
; D0 = # of args chars

process_args	cmp.b	#' ',(a0)+	;skip any leading spaces
		beq.s	process_args
		subq.w	#1,a0
		move.l	a0,args_ptr	;save addr of argument to prg

find_eo_fname	cmp.b	#LF,(a0)+	;scan to first LF or SPC
		beq.s	mark_eofn
		cmp.b	#' ',-1(a0)
		bne.s	find_eo_fname

mark_eofn	clr.b	-1(a0)		;change LF to NULL (C-string)
		rts
;---------------------------------------
; A0 -> string dest
; D0 = # to be cvtd (LONG)
; D1 = # of chars wanted			USES: D0/D1/D2 A0/A1

bin_to_dec	subq.w	#8,d1
		neg.w	d1
		add.w	d1,d1
		add.w	d1,d1
		lea	powers(PC,d1),a1

next_pow	move.l	(a1)+,d1
		moveq	#0,d2
weigh		sub.l	d1,d0
		bcs.s	gotya
		addq.w	#1,d2
		bra.s	weigh
gotya		add.l	d1,d0
		add.b	#'0',d2
		move.b	d2,(a0)+
		subq.l	#1,d1
		bne.s	next_pow
		rts

powers		dc.l	10000000	7
		dc.l	1000000		6
		dc.l	100000		5
		dc.l	10000		4
		dc.l	1000		3
		dc.l	100		2
		dc.l	10		1
		dc.l	1		0
;---------------------------------------
; A0 -> decimal string 
; RETURNS D0.W = number (0..65535)		**!!
;	A0-> first non-numeric char

get_decimal	moveq	#0,d0		;clear Accum.
		moveq	#0,d1		;clear LONG reception reg
		bra	wh_decimal

accum_digit	mulu	#10,d0		;shift curr value
		add.w	d1,d0		;OR new digit

wh_decimal	move.b	(a0)+,d1	;get char
		sub.b	#'0',d1		;must be digit
		bcs	not_digit
		cmp.b	#10,d1
		bcs	accum_digit

not_digit	subq.w	#1,a0		;backtrack over offending char

skip_spaces	cmp.b	#' ',(a0)+
		beq.s	skip_spaces

		subq.w	#1,a0		;backtrack over 1st non-num/spc
		rts
;---------------------------------------
open_libraries	move.l	4.w,a6
		lea	dos_name,a1
		moveq	#0,d0
		EXEC	OpenLibrary		;open DOS
		move.l	d0,DOS_LIB_PTR
		bne	got_dos
		moveq	#-1,d7
		jmp	error

got_dos		lea	gfx_name,a1
		moveq	#0,d0
		EXEC	OpenLibrary		;open GFX
		move.l	d0,GFX_LIB_PTR
		bne	got_gfx
		moveq	#-1,d7
		jmp	error

got_gfx		lea	intui_name,a1
		moveq	#0,d0
		EXEC	OpenLibrary		;open Intuition
		move.l	d0,INTUI_LIB_PTR
		bne	got_intui
		moveq	#-1,d7
		jmp	error

got_intui	rts
;---------------------------------------
error		move.l	top_level,SP

		move.l	DOS_LIB_PTR,d0	;did we ever get DOS ?
		beq	no_dos
		move.l	d0,a6
		move.l	in_fhandle,d1	;yes, then maybe the file
		beq	no_file
		DOS	Close			;yes: close

no_file		move.l	4.w,a6
		move.l	DOS_LIB_PTR,a1	;& close DOS
		EXEC	CloseLibrary

no_dos		move.l	GFX_LIB_PTR,a1
		EXEC	CloseLibrary	;close GFX

		move.l	INTUI_LIB_PTR,d0	;did we ever get Intuition?
		beq	no_intuition		;yes,
		move.l	d0,a6
		move.l	window,d0
		beq	no_window
		move.l	d0,a0			;maybe the window too?
		INTUI	CloseWindow		;yes: close

no_window	move.l	a6,a1			;& close Intuition
		move.l	4.w,a6
		EXEC	CloseLibrary

no_intuition	move.l	4.w,a6			;free file buffer
		move.l	file_buffer,d1
		beq	exit			;if ever gotten !
		move.l	#50000,d0
		move.l	d1,a1
		EXEC	FreeMem

exit		move.l	d7,d0

dummy		rts
;---------------------------------------
chart_windowdef	dc.w	320-WINDOW_WIDTH/2,32		;origin
		dc.w	WINDOW_WIDTH,WINDOW_LINES	;dimensions
		dc.b	0,1
		dc.l	WINDOW_IDCMP
		dc.l	WINDOW_FLAGS
		dc.l	0		;no gadgets
		dc.l	0		;std checkmark
		dc.l	window_name
		dc.l	0,0		;Workbench screen, no custom Bitmap
		dc.w	300,110		;min W,H
		dc.w	8192,8192	;max W,H
		dc.w	WBENCHSCREEN

window_name	dc.b	'Barchart V0.91 ©LVA 9/10/89       file:'
window_title	ds.b	256
;---------------------------------------
chart_data	ds.w	50*(1+2)	;**!! should allocate depending on
		dc.w	-1,0,0		;# of input file entries **!!
;---------------------------------------
dec_out		ds.b	6
;---------------------------------------

dos_name	DOSNAME
gfx_name	GRAFNAME
intui_name	INTNAME

DOS_LIB_PTR	ds.l	1
GFX_LIB_PTR	ds.l	1
INTUI_LIB_PTR	ds.l	1

top_level	ds.l	1		;for SP
args_ptr	ds.l	1		;for CLI args
file_buffer	ds.l	1
file_end	ds.l	1
in_fhandle	ds.l	1
window		ds.l	1
rastport	ds.l	1
msgport		ds.l	1
imsg_class	ds.l	1
imsg_code	ds.w	1
imsg_addr	ds.l	1
imsg_ratcords	ds.l	1

w_width		ds.w	1		;window width in pixels
w_lines		ds.w	1		;window lines
num_values	ds.w	1
max_value	ds.w	1
factor		ds.w	1
axis_max	ds.w	1

flags		ds.b	1

		END
