;	Source Code:	AGAMandel.s
;
;	Produces a super high-res Mandelbrot set
;	uses AGA chipset to give 64 colours
;	Note: program runs much faster than 
;	old chipset with less bitplanes!!!!
;	Reason: new AGA chipset uses less processor
;	cycles when program in chip ram -
;	AGA set has wider bandwidth (32 bit)
;
;	Written by Chris Colman 
;	August 1993
;	
;	To change from super hires to hires,
;	just swap the following lines with
; 	their partners below.
;**************************
;Width	= 80	
;Plane0	= $e200
;Plane1	= $44dd
;dfst	= $28
;dfstp	= $c8
;Noxpixels = 640
;*************************



	INCLUDE	Registers.s

Width		= 160			; Super hi res
Depth		= 256			; (80 for hires)
Planes		= 6			; 6 bitplanes
Planesize	= Width*Depth*(Planes)
Planewidth	= Width*Planes		; Interleaved planes
Planelwords	= Planesize/4
Chip		= 2		
Clear		= Chip+$10000
Singleplane	= Width*Depth
Noplanes	= Planes-1		; Actual number -1 ( DBRA used)
Mask		= 63			; In case iterations >=63
Modulo		= Noplanes*Width-8
Plane0		= $6240			; BPLCON0 $e200 for hires
Plane1		= $00dd			; BPLCON1 $44dd for hires
dfst		= $30			; DDFSTRT $28 for hires
dfstp		= $d0			; DDFSTOP $c8 for hires
Noxpixels	= 1280			; Size of mandelbrot
Noypixels 	= 256			; on screen (640 for hires)
Noiterations	= 62			; Iterations (+1 for DBRA)

; ** Initialization **

Start:
	move.l 	Execbase,a6
	move.l	#Planesize,d0
	move.l	#Clear,d1
	jsr	AllocMem(a6)	; Reserve memory for screen
	move.l	d0,Planeadr	; Life would be easier with
	beq 	End		; Devpac 3
	move.l	#Bplanes,a0	; Bitplanes in copperlist
	moveq.l	#Noplanes,d3		
	clr.l	d1		; Set up pointers to bitplanes
	move.w	#BPL1PTH,d1
Setplanes:
	move.w	d1,(a0)+	; Store first high word
	swap	d0
	move.w	d0,(a0)+
	addq.w	#2,d1
	move.w	d1,(a0)+
	swap	d0		; Then low word
	move.w	d0,(a0)+
	addq.w	#2,d1
	add.l	#Width,d0		; Interleaved planes
	dbra	d3,Setplanes
	jsr	Disable(a6)	; Goodbye system (for now)
	lea	$dff000,a5	; Base address of hardware regs
	move.w	#$03E0,DMACON(a5)	; DMA off (except
Setcolors:				;	disk + audio)
	moveq.l	#63,d0		; 64 colours
	lea.l	Colorsetup,a1	; Space in copperlist
	moveq.l	#3,d1		; Start palette
	move.l	#$180,d2	; Color 0 first
Setem:
	move.w	d2,132(a1)	; Store in low 12 bits
	move.w	d1,134(a1)	
	move.w	d2,(a1)+	; and in high 12 bits	
	move.w	d1,(a1)+
	mulu	#3,d1		; give spread of colours
	addq.w	#2,d2		; next color register
	cmp.w	#32,d0		; reached next 'page' of
	bne	Samepage	; colours ?
	move.l	#$180,d2	; if so, restart from 0
	lea.l	Next32,a1	; but at new copper address
Samepage:			; which pages 32-63 on 0-31
	dbra	d0,Setem	; do for all 64
	move.l	#CopperList,COP1LC(a5)	; Start of list
	clr.w	COPJMP1(a5)	; Strobe !
	move.w	#$8380,DMACON(a5)	; Copper and Bplane DMA on
	move.l	Planeadr,a0
	move.l	#Planelwords-1,d0
	clr.l	d1
Blankscreen:			; Wipe screen
	move.l	d1,(a0)+
	dbra	d0,Blankscreen

	bsr	Mandelbrot	; Plot the mandelbrot

mouse:	btst	#6,CIAAPRA	; Mousey finishes
	bne	mouse

	move.l	#GRname,a1
	clr.l	d0
	jsr	OpenLibrary(a6)		; Get offset
	move.l	d0,a4			; for system
	move.l	StartList(a4),COP1LC(a5) ; copper (WB)
	clr.w	COPJMP1(a5)		
	move.w	#$8060,DMACON(a5)	; everything on
	jsr	Enable(a6)		; Tasks as well
FreePlane:
	move.l	Planeadr,a1
	move.l	#Planesize,d0		; Get back all
	jsr	FreeMem(a6)		; memory for 
End:					; screen
	clr.l	d0
	rts

	even

;	Following routine creates a mandelbrot set.
;	Needs to know: no. of pixels up and dowm
;			and range in complex plane
;			also no. iterations - speed and colour
;
;

Mandelbrot:
	move.l	Planeadr,a1	; Start of screen
	move.l	#7,d5		; leftmost pixel-see later
	clr.l	d6		; screen offset-see later
	move.l	xmax,d0
	move.l	xmin,d1
	sub.l	d1,d0
	divs	#Noxpixels-1,d0	; (xmax-xmin)/no.pixels
	ext.l	d0		; extend 16bit - 32bit
	move.l	d0,xfrac	; will be added each new pixel
	sub.l	d0,d1		; program initially adds xfrac
	move.l	d1,xmin		; so sub it here to cancel 
	move.l	d1,creal	; first addition. Start at xmin
	move.l	ymax,d0
	move.l	d0,cimag
	move.l	ymin,d1		; Start at ymax (top of screen)
	sub.l	d1,d0
	divs	#Noypixels-1,d0	; Same for y as for x
	ext.l	d0		; no need to pre-sub yfrac
	move.l	d0,yfrac	
Newpoint:			; Enter here every new pixel
	clr.l	imag		; z=x+iy
	clr.l	real		; these vars used for recursion
	move.l	xfrac,d1
	add.l	d1,creal	; update current complex coord
	move.l	#Noiterations,d3
Iterate:
	bsr	Calculate	; perform z-> z*z+c
	cmp.l	#4*8192*8192,d0	; is z*z > 4 ?
	bge	Diverge		; if so then not in set
	dbra	d3,Iterate
Nodiverge:
	bra	Nextpoint	; not diverged - black
Diverge:	
	addq.l	#1,d3		; d3 = 1 to 63
	and.l	#Mask,d3	; in case noiterations>62
	move.l	#Noplanes,d4	; plot to 6 planes
	move.l	a1,a0		; current screen posn
Multicolor:
	lsr	#1,d3		; rotate into carry
	bcc	Notset		; no carry - skip bitplane
	bset	d5,0(a0,d6)	; set point in bitplane
Notset:	
	add.l	#Width,a0		; next bitplane (interleaved)
	dbra	d4,Multicolor	; do for all planes
Nextpoint:
	subq.b	#1,d5		; decrease bit (go left a pixel)
	bcc	Samebyte	; d5>0
	moveq.l	#7,d5		; leftmost bit of next byte
	addq.l	#1,d6		; increase offset by 1 byte
Samebyte:
	addq.l	#1,xcoord	; x = x +1
	cmp.l	#Noxpixels,xcoord ; x = no. x pixels ?
	bne	Newpoint	; no, so do next pixel
	moveq.l	#7,d5		; yep so leftmost pixel
	clr.l	d6		; of next line
	add.l	#Planewidth,a1	; is needed
	move.l	xmin,d0		; reset x coord in  complex
	move.l	d0,creal	; plane
	move.l	yfrac,d0	; move down line in complex plane
	sub.l	d0,cimag	
	clr.l	xcoord		; first pixel for counter
	addq.l	#1,ycoord	; next y pixel (moving down screen)
	cmp.l	#Noypixels,ycoord ; reached last line ?
	bne	Newpoint	; not yet
	rts			; yes, finished


Calculate:			; need to calculate z*z+c
Rcalc:	move.l	real,d0		; using complex variables and
	move.l	imag,d1		; floating point (arghhh)
	muls	d0,d0		; in fact,
	muls	d1,d1		; x -> x*x-y*y+a
	sub.l	d1,d0		; i*y -> 2*x*y*i+b*i
	asr.l	#8,d0		; use integers*8192
	asr.l	#5,d0		; e.g 0.5 = 4096
	add.l	creal,d0	; hence multiply numbers
	move.l	d0,d4		; then rotate right 13 places
Icalc:	move.l	real,d0		; means no DIVS command 
	move.l	imag,d1		; = massive reduction in cycles
	move.l	cimag,d2	; also = limited resolution of
	muls	d1,d0		; xmax-xmin > 0.15
	asr.l	#8,d0		; factor of 2 in 2*x*y*i
	asr.l	#4,d0		; don't multiply by 2 then
	add.l	d2,d0		; divide by 2 - wastes cycles
	move.l	d4,real		; Store new calculated values 
	move.l	d0,imag		; for real and imaginary parts
Modcal:	muls	d4,d4		; calculate square of the 
	muls	d0,d0		; modulus
	add.l	d4,d0		; diverges if |z|>2 ie z*z>4
	rts
		
; As mentioned above, use fast integer arithmetic by 
; premultiplying all points by 8192 - then do integer
; arithmetic and replace DIVS with LSR. Resolution is
; limited to xmax-xmin = 1280/8192 = 0.15
; However, with 68020 can use QUAD WORDS 
; e.g DIV : 32*32->64 and DIVS : 64/32->32
; gives additional factor of 65536 in resolution
; ie resolution now becomes xmax-xmin>0.000002
; means magnifications of 1 million possible
; easy to implement - use QUADS and alter LSR's to
; 29 bit and 28 bit.

 
xmin:		dc.l	-8192	; For whole set use :
xmax:		dc.l	-2048	; (-3*8192,3*8192,
ymin:		dc.l	-8192	;   -3*8192,3*8192)
ymax:		dc.l	-4096
xfrac:		dc.l	0
yfrac:		dc.l	0
xcoord:		dc.l	0
ycoord:		dc.l	0
creal:		dc.l	0
cimag:		dc.l	0
real:		dc.l	0
imag:		dc.l	0
CLadr:		dc.l	0
Planeadr:	dc.l	0
GRname:		dc.b	"graphics.library",0
CopperList:	dc.w	$2601,$fffe,$106,$c40	; Colours 0-31 hi
Colorsetup:	ds.w	64
		dc.w	$106,$e40		; Colours 0-31 lo
		ds.w	64
		dc.w	$106,$2c40		; Colours 32-63 hi
Next32:		ds.w	64
		dc.w	$106,$2e40		; Colours 32-63 lo
		ds.w	64
		dc.w	$8e,$297e		; DIWSTART
		dc.w	$100,Plane0,$104,$224	; BPLCON0
		dc.w	$106,$c40,$90,$29be	; DIWSTOP
		dc.w	$92,dfst,$94,dfstp	; DDFSTRT,DDFSTOP
		dc.w	$102,Plane1,$108,Modulo	; BPLCON1
		dc.w	$10a,Modulo		; modulo 
Bplanes:	ds.w	4*(Noplanes+1)		
		dc.w	$ffff,$fffe
		end
