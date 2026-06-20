
** hardware locations **

cop1lc	equ	$dff080
copjmp1	equ	$dff088
vpos	equ	$dff004
vhpos	equ	$dff006
dmacon	equ	$dff096


** exec function offsets **

allocmem	equ	-198
copymem		equ	-624
freemem		equ	-210
forbid		equ	-132
permit		equ	-138
openlibrary	equ	-552
closelibrary	equ	-414

** dos library offsets **

open		equ	-30
close		equ	-36
read		equ	-42

** constants **
execbase	equ 	4
chip		equ	2
clear		equ	$10000
mode		equ	1005
joy		equ	$dff00c
keys		equ	$bfec01
	

		include source:include/hardware.i

** open dos library **
	
	move.l	execbase,a6
	move.l	#dosname,a1
	move.l	#0,d0
	jsr	openlibrary(a6)
	move.l	d0,dosbase		;save pointer to dos library


** allocate memory for sound **

	move.l	execbase,a6
	move.l	#wavelen,d0
	move.l	#chip+clear,d1
	jsr	allocmem(a6)
	tst	d0
	beq	abort
	move.l	d0,waveaddress		;save pointer to sound


** copy wave form data to chip memory **

	move.l	execbase,a6
	move.l	d0,a1
	move.l	#wave,a0
	move.l	#wavelen,d0
	jsr	copymem(a6)


** allocate memory for blank sprites **

	move.l	execbase,a6
	move.l	#12,d0
	move.l	#chip+clear,d1
	jsr	allocmem(a6)
	tst	d0
	beq	abort0
	move.l	d0,d5		;d5 holds blank sprite address
	
	
** allocate memory for sprite **

	move.l	execbase,a6
	move.l	#spritelen,d0
	move.l	#chip+clear,d1
	jsr	 allocmem(a6)
	tst	d0
	beq	abort1
	move.l	#150,xpos	;initial x position of player sprite
	move.l	#212,ypos	;initial y position of player sprite


** copy sprite structure to CHIP RAM **

	move.l	d0,d7
	move.l	d0,a1
	move.l	#sprite,a0
	move.l	#spritelen,d0
	move.l	execbase,a6
	jsr	copymem(a6)
	move.l	d7,a0
	move.l 	#$f66bff00,(a0)	;put position data in control words
	
** allocate memory for COPPER LIST **

	move.l	execbase,a6
	move.l	#copperlen,d0
	move.l	#chip,d1
	jsr	allocmem(a6)
	tst	d0
	beq	abort2
	move.l	d0,d6		;d6 holds address of copper list
	move.l	d0,a1
	move.l	#copper,a0
	move.l	#copperlen,d0
	move.l	execbase,a6
	jsr 	copymem(a6)
	
** allocate memory for 5 X LOW RES BIT PLANES (320x256)
	
	move.l	execbase,a6
	move.l	#(320/8*256)*5,d0		; calculation gives total bytes
	move.l	#chip,d1
	jsr	allocmem(a6)
	tst	d0
	beq	abort3
	move.l	d0,d4				;d4 holds bit plane address

** load data into bit planes **
	
	move.l	dosbase,a6
	move.l	#filename,d1
	move.l	#mode,d2
	jsr	open(a6)
	move.l	d0,filehandle
	move.l	d0,d1
	move.l	d4,d2
	move.l	#(320/8*256)*5,d3
	jsr	read(a6)
	move.l	d0,bytesrecieved




** copy BIT PLANE and SPRITE POINTERS  into COPPER LIST **

	move.l	d6,a0
	move.w	d4,242(a0)	;BPL1PTL
	swap	d4
	move.w	d4,238(a0)	;BPL1PTH
	swap	d4
	add.l	#10240,d4
	move.w	d4,250(a0)	;BPL2PTL
	swap	d4
	move.w	d4,246(a0)	;BPL2PTH
	swap	d4
	add.l	#10240,d4
	move.w	d4,258(a0)	;BPL3PTL
	swap	d4
	move.w	d4,254(a0)	;BPL3PTH
	swap	d4
	add.l	#10240,d4
	move.w	d4,266(a0)	;BPL4PTL
	swap	d4
	move.w	d4,262(a0)	;BPL4PTH
	swap	d4
	add.l	#10240,d4
	move.w	d4,274(a0)	;BPL5PTL
	swap	d4
	move.w	d4,270(a0)	;BPL5PTH
	swap	d4
	sub.l	#40960,d4

	move.w	d7,10(a0)	;SPR0PTL
	swap	d7
	move.w	d7,6(a0)	;SPR0PTH
	swap 	d7
	add.l	#56,d7
	move.w	d7,18(a0)	;SPR1PTL
	move.w	d5,26(a0)	;SPR2PTL
	move.w	d5,34(a0)	;SPR3PTL
	move.w	d5,42(a0)	;SPR4PTL
	move.w	d5,50(a0)	;SPR5PTL
	move.w	d5,58(a0)	;SPR6PTL
	move.w	d5,66(a0)	;SPR7PTL
	swap	d5
	swap	d7
	move.w	d7,14(a0)	;SPR1PTH
	swap	d7
	sub.l	#56,d7

	move.w	d5,22(a0)	;SPR2PTH
	move.w	d5,30(a0)	;SPR3PTH
	move.w	d5,38(a0)	;SPR4PTH
	move.w	d5,46(a0)	;SPR5PTH
	move.w	d5,54(a0)	;SPR6PTH
	move.w	d5,62(a0)	;SPR7PTH
	swap	d5

** all 8 sprites are turned on at once **
** be sure to have data for all 8 even if its only blank data **

** set up audio channel and volume **

	move.l	waveaddress,$dff0a0	;set pointer to waveform
	move.l	#wavelen/2,$dff0a4	;set length in words
	move.w	#50800,$dff0a6		;set rate i.e. frequency
	move.w	#64,$dff0a8		;set volume




** disable task switching **

	move.l	execbase,a6
	jsr	forbid(a6)

** put COPPER LIST address in hardware pointer **

	move.l	d6,cop1lc
	
** set COPPER LIST program counter **

	move.w	d0,copjmp1

** save data registers **

	movem.l	d0-d7,-(sp)
	move.l	#0,exists	;clear missile exists flag
	
	bsr	BlitBob		Do my stuff


loop
	cmp.b	#$37,keys	;check right ALT key
	beq	clean		; hit ? then exit
	bsr	joystick	;check joystick 
	bsr	fire		;check fire status
	bsr	update		;update missile
	clr.l	d1		;short delay count
	bsr	delay		;wait a short while
	bra	loop		;do it all again !

joystick
	move	joy,d0
        btst	#1,d0	;if true joystick moved right
	bne	right
	btst	#9,d0	;if true joystick moved left
	bne	left
	move	#0,$dff036
	rts


right
	
	move.l	xpos,d4		;move current x pos into d4
	cmp.l	#342,d4		;payer reached edge of screen ?
	bge	boundry.right	;yep ! don't let him move any more
	add	#1,d4		;increment position
	move.l	d4,xpos		;save new x position

	move.l	ypos,d5		;move y pos into d5

	bsr	calculate	;find new sprite control words
	move.l	d7,a0		
	move.l	d0,(a0)		;move new words into structure

boundry.right

	rts

left
	
	move.l	xpos,d4		;load x position into d4
	cmp.l	#68,d4		;reached edge of screen ?
	ble	boundry.left	;yep ! don't move any more
	sub	#1,d4		;decrement position
	move.l	d4,xpos		;save new position
	move.l	ypos,d5
	bsr	calculate	;find new words
	move.l	d7,a0
	move.l	d0,(a0)		;load new words into sprite structure


boundry.left

	rts

fire
	move.w	#$0001,dmacon	;make sure sound is off
	cmp.l	#1,exists	;does missile exist already ?
	beq	fire2		;yep ! don't shoot another
	tst.b	$bfe001		;fire pressed ?
	bpl	fire1		;yep ! launch missile
	rts
fire1
	move.w	#$8001,dmacon	;crap sound effects on
	move.l	xpos,d6
	move.l	ypos,d0
	sub.l	#6,d0
	add.l	#6,d6		;last 4 commands put missile over player
	move.l	d6,missilex
	move.l	d0,missiley	;save missile position
	move.l	d6,d4
	move.l	d0,d5
	bsr	calculate	;find control words for missile
	move.l	d7,a0
	move.l	d0,56(a0)	;put them in missile structure
	move.l	#1,exists	;set missile flag
	
fire2
	rts

update
	
	move.l	missilex,d4
	move.l	missiley,d5	;put co-ord's in registers
	cmp.l	#25,d5		;reached top of screen ?
	ble	offscreen	;yep ! turn it off
	sub.l	#1,d5		;move missile
	move.l	d5,missiley
	bsr	calculate	;find new words
	move.l	d7,a0
	move.l	d0,56(a0)	;load them into structure
	rts

offscreen

	move.l	d7,a0
	move.l	#$00000000,56(a0)	;turn it off
	move.l	#0,exists		;clear missile flag
	rts

calculate
	
	clr.l	d0
	add.w	#44-11,d5	;i'm not to hot on how this works
	lsl.w	#8,d5		;because i borrowed it from		
	add.w	#64,d4		;the AMIGA FORMAT menace series
	lsr.w	#1,d4		;by M.R LEMMINGS (DAVE JONES)
	or.w	d5,d4		; hope he doesn't mind
	move.w 	d4,d0
	swap	d0
	roxl.w	#1,d0
	add.w	#$0800,d5
	or.w	d5,d0
	nop
	rts

** clean up **
clean
	movem.l	(sp)+,d0-d7		;restore registers
	move.l	dosbase,a6
	move.l	filehandle,d1
	jsr	close(a6)		;close bitmap file
	move.l	execbase,a6
	move.l	dosbase,a1
	jsr	closelibrary(a6)	;close dos library

	move.l	execbase,a6
	move.l	#graphicsname,a1
	move.l	#0,d0
	jsr	openlibrary(a6)		;open graphics library
	move.l	d0,gfxbase
	move.l	d0,a0
	move.l	38(a0),cop1lc		;this location holds system COPPER LIST
	move.w	d0,copjmp1		;restart system copper
	move.l	gfxbase,a1
	move.l	execbase,a6
	jsr	closelibrary(a6)	;close graphics library
	move.l	execbase,a6
	jsr	permit(a6)		;restore task switching
	move.l	execbase,a6
	
	move.l	#(320/8*256)*5,d0	;free bit map memory
	move.l	d4,a1
	jsr	freemem(a6)

abort3
	move.l	execbase,a6
	move.l	#copperlen,d0
	move.l	d6,a1
	jsr	freemem(a6)		;free copper memory
	
abort2
	move.l	execbase,a6
	move.l	#spritelen,d0
	move.l	d7,a1
	jsr	freemem(a6)		;free sprite memory
	
abort1
	move.l	execbase,a6
	move.l	#12,d0
	move.l	d5,a1
	jsr	freemem(a6)		;free blank sprite memory
abort0
	move.l	execbase,a6
	move.l	waveaddress,a1
	move.l	#wavelen,d0
	jsr	freemem(a6)		;free crap sound memory
abort
	rts

** this routine waits  **

delay
	move.w	vhpos,d2
	and.w	#$5f00,d2
	bne	delay
	
delay1
	move.w	vpos,d2
	and.w	#$0001,d2
	bne	delay1
	
	rts


;--------------	
;--------------	Blitter Code
;--------------

; First, wait for Blitter to finish last blit.

BlitBob		lea		$dff000,a5		set base pointer

BLoop1		btst		#14,DMACONR(a5)		blitter busy?
		bne.s		BLoop1			if so loop

; Tell Blitter where to find data

		move.l		d4,a1			a1->Playfield data
		adda.l		#1700,a1	offset from TopLeft

		move.l		#Bob1,BLTAPTH(a5)	set source A
		move.l		a1,BLTBPTH(a5)		set source B
		move.l		a1,BLTDPTH(a5)		set destination

; Define block modulos ( playfield modulo = 40 bytes   -  4 bytes )
;					ie. playfield  -    bob

		move.w		#0,BLTAMOD(a5)		no source modulo
		move.w		#36,BLTBMOD(a5)		dest modulo
		move.w		#36,BLTDMOD(a5)

; Clear mask, not used for this example.

		move.w		#-1,BLTAFWM(a5)		no mask value
		move.w		#-1,BLTALWM(a5)

; Define shift value ( $0 ), channel usage ( $d ) and minterm ( $fc )
;		no shift         use A,B,D             D = A + B

		move.w		#$0dfc,BLTCON0(a5)	set bits

;--------------	Now the loop to blit each playfield

; set counter and start blitting the bob

		moveq.l		#3,d1			bob depth
BlitLoop	move.w		#$0802,BLTSIZE(a5)	start blitter

; Check if all planes of bob blitted, exit loop if so

		subq.w		#1,d1			dec counter
		beq.s		BlitDone		skip if bob finished

; Bump playfield pointer to point to next bitplane of display

		adda.l		#(320/8)*256,a1		update dest pointer

; Wait for Blitter to finish current playfield

BLoop		btst		#14,DMACONR(a5)		blitter busy
		bne.s		BLoop			if so wait

; Update blitter data address pointers ( Blitter will have updated BLTAPTH
;to the correct address itself ).

		move.l		a1,BLTBPTH(a5)		set next playfield
		move.l		a1,BLTDPTH(a5)		pointer

; now loop back and blit next bitplane of bob

		bra.s		BlitLoop		loop!

; When bob has been blitted, return to Main

BlitDone	rts


** program data section **

graphicsname	dc.b 'graphics.library',0
	even
gfxbase		dc.l 0

** COPPER LIST for single bit plane 320x200 with sprites **
copper
	dc.l $01800000		;background colour
	dc.l $01200000		;spr0pth
	dc.l $01220000		;spr0ptl
	dc.l $01240000		;spr1pth
	dc.l $01260000		;spr1ptl
	dc.l $01280000		;spr2pth
	dc.l $012a0000		;spr2ptl
	dc.l $012c0000		;spr3pth
	dc.l $012e0000		;spr3ptl
	dc.l $01300000		;spr4pth
	dc.l $01320000		;spr4ptl
	dc.l $01340000		;spr5pth
	dc.l $01360000		;spr5ptl	
	dc.l $01380000		;spr6pth
	dc.l $013a0000		;spr6ptl
	dc.l $013c0000		;spr7pth
	dc.l $013e0000		;spr7ptl
	dc.l $2b01fffe		;wait for y=43,x=0
	dc.w	$180,$000,$182,$fff,$184,$e00,$186,$0a1
	dc.w	$188,$d80,$18a,$c70,$18c,$c71,$18e,$b61
	dc.w	$190,$b62,$192,$a52,$194,$a52,$196,$000
	dc.w	$198,$01d,$19a,$f00,$19c,$f32,$19e,$f53
	dc.w	$1a0,$000,$1a2,$f00,$1a4,$fff,$1a6,$000
	dc.w	$1a8,$333,$1aa,$444,$1ac,$555,$1ae,$666
	dc.w	$1b0,$777,$1b2,$888,$1b4,$999,$1b6,$aaa
	dc.w	$1b8,$ccc,$1ba,$ddd,$1bc,$eee,$1be,$6f8
	dc.l $008e2c81		;diwstrt
	dc.l $01000200		;bplcon0
	dc.l $01040024		;bplcon2
	dc.l $00902cc1		;diwstop
	dc.l $00920038		;ddfstrt
	dc.l $009400d0		;ddfstop
	dc.l $01020000		;bplcon1
	dc.l $01080000		;bpl1mod
	dc.l $010a0000		;bpl2mod
	dc.l $00e00000		;bpl1pth
	dc.l $00e20000		;bpl1ptl
	dc.l $00e40000		;bpl2pth
	dc.l $00e60000		;bpl2ptl
	dc.l $00e80000		;bpl3pth
	dc.l $00ea0000		;bpl3ptl
	dc.l $00ec0000		;bpl4pth
	dc.l $00ee0000		;bpl4ptl
	dc.l $00f00000		;bpl5pth
	dc.l $00f20000		;bpl5ptl
	dc.l $2c01fffe		;wait for x=0 , y=44
	dc.l $01005200		;bplcon



	dc.l $01980005
	dc.l $5ce3fffe
	dc.l $01980006
	dc.l $7ee3fffe
	dc.l $01980007
	dc.l $8ee3fffe
	dc.l $01980008
	dc.l $9ee3fffe
	dc.l $01980009
	dc.l $aee3fffe
	dc.l $0198000a
	dc.l $bee3fffe
	dc.l $0198000b
	dc.l $cde3fffe
	dc.l $0198000c	
				; end of copper bar
	dc.l $ff01fffe
	dc.l $2c00fffe
	dc.l $01000200
	dc.l $fffffffe 

endcopper
copperlen	equ endcopper-copper

sprite

	dc.l	$00000000
	dc.w	$01c0,$01c0
	dc.w	$01c0,$0140
	dc.w	$03e0,$0360
	dc.w	$3ffe,$3c1e
	dc.w	$5ffd,$780f
	dc.w	$7fff,$4001
	dc.w	$5ffd,$780f
	dc.w	$3ffe,$7fff
	dc.w	$0000,$0000
	dc.w	$0000,$0000	;Sprite End
	


	dc.w	$0000,$0000	;SPRxPOS,SPRxCTL
	dc.w	$0000,$0000
	dc.w	$0000,$2000
	dc.w	$0000,$2000
	dc.w	$0000,$2000
	dc.w	$0000,$2000
	dc.w	$0000,$2000
	dc.w	$0000,$7000
	dc.w	$2000,$5000
	dc.w	$7000,$0000
	dc.w	$5000,$0000
	dc.w	$0000,$0000	;Sprite End

endsprite
spritelen 	equ endsprite-sprite

wave	dc.b	0,20,40
	dc.b	60,80,100
	dc.b	120,0,20
	dc.b	40,60,80,100
	dc.b 	120,0,20	
	dc.b	40,60
	dc.b	80,100,120,0

waveend
wavelen	equ	waveend-wave


dosname		dc.b 'dos.library',0
dosbase		dc.l 1
filename	dc.b 'Source:helpme/moonscape.bmap',0
filehandle	dc.l 1
bytesrecieved	dc.l 1
xpos		dc.l 1
ypos		dc.l 1
missilex	dc.l 1
missiley 	dc.l 1
exists		dc.l 1
waveaddress	dc.l 1

		section		blitter,data_c		CHIP mem
		
Bob1		dc.w		%0000000000000000,%0000000000000000	1
		dc.w		%0111111111111111,%1111111111111110	2
		dc.w		%0110000000000000,%0000000000000110	3
		dc.w		%0110000000000000,%0000000000000110	4
		dc.w		%0110000000000000,%0000000000000110	5
		dc.w		%0110000000000000,%0000000000000110	6
		dc.w		%0110000000000000,%0000000000000110	7
		dc.w		%0110000000000000,%0000000000000110	8
		dc.w		%0110000000000000,%0000000000000110	9
		dc.w		%0110000000000000,%0000000000000110	10
		dc.w		%0110000000000000,%0000000000000110	11
		dc.w		%0110000000000000,%0000000000000110	12
		dc.w		%0110000000000000,%0000000000000110	13
		dc.w		%0110000000000000,%0000000000000110	14
		dc.w		%0110000000000000,%0000000000000110	15
		dc.w		%0110000000000000,%0000000000000110	16
		dc.w		%0110000000000000,%0000000000000110	17
		dc.w		%0110000000000000,%0000000000000110	18
		dc.w		%0110000000000000,%0000000000000110	19
		dc.w		%0110000000000000,%0000000000000110	20
		dc.w		%0110000000000000,%0000000000000110	21
		dc.w		%0110000000000000,%0000000000000110	22
		dc.w		%0110000000000000,%0000000000000110	23
		dc.w		%0110000000000000,%0000000000000110	24
		dc.w		%0110000000000000,%0000000000000110	25
		dc.w		%0110000000000000,%0000000000000110	26
		dc.w		%0110000000000000,%0000000000000110	27
		dc.w		%0110000000000000,%0000000000000110	28
		dc.w		%0110000000000000,%0000000000000110	29
		dc.w		%0110000000000000,%0000000000000110	30
		dc.w		%0111111111111111,%1111111111111110	31
		dc.w		%0000000000000000,%0000000000000000	32

		dc.w		%0000000000000000,%0000000000000000
		dc.w		%0000000000000000,%0000000000000000
		dc.w		%0001111111111111,%1111111111111000
		dc.w		%0001100000000000,%0000000000011000
		dc.w		%0001100000000000,%0000000000011000
		dc.w		%0001100000000000,%0000000000011000
		dc.w		%0001100000000000,%0000000000011000
		dc.w		%0001100000000000,%0000000000011000
		dc.w		%0001100000000000,%0000000000011000
		dc.w		%0001100000000000,%0000000000011000
		dc.w		%0001100000000000,%0000000000011000
		dc.w		%0001100000000000,%0000000000011000
		dc.w		%0001100000000000,%0000000000011000
		dc.w		%0001100000000000,%1100110011011000
		dc.w		%0001100000000000,%0000000000011000
		dc.w		%0001111111111111,%0000000000011000
		dc.w		%0001100000000000,%0000000000011000
		dc.w		%0001100000000000,%0000000000011000
		dc.w		%0001100000000000,%0000000000011000
		dc.w		%0001100000000000,%0000000000011000
		dc.w		%0001100000000000,%0000000000011000
		dc.w		%0001100000000000,%0000000000011000
		dc.w		%0001100000000000,%0000000000011000
		dc.w		%0001100000000000,%0000000000011000
		dc.w		%0001100000000000,%0000000000011000
		dc.w		%0001100000000000,%0000000000011000
		dc.w		%0001100000000000,%0000000000011000
		dc.w		%0001100000000000,%0000000000011000
		dc.w		%0001100000000000,%0000000000011000
		dc.w		%0001100000000000,%0000000000011000
		dc.w		%0001111111111111,%1111111111111000
		dc.w		%0000000000000000,%0000000000000000
		dc.w		%0000000000000000,%0000000000000000

		dc.w		%0000000000000000,%0000000000000000
		dc.w		%0000000000000000,%0000000000000000
		dc.w		%0001111111111111,%1111111111111000
		dc.w		%0001100000000000,%0000000000011000
		dc.w		%0001100000000000,%0000000000011000
		dc.w		%0001100000000000,%0000000000011000
		dc.w		%0001100000000000,%0000000000011000
		dc.w		%0001100000000000,%0000000000011000
		dc.w		%0001100000000000,%0000000000011000
		dc.w		%0001100000000000,%0000000000011000
		dc.w		%0001100000000000,%0000000000011000
		dc.w		%0001100000000000,%0000000000011000
		dc.w		%0001100000000000,%0000000000011000
		dc.w		%0001100000000000,%1111111111111000
		dc.w		%0001100000000000,%0000000000011000
		dc.w		%0001100000000000,%0000000000011000
		dc.w		%0001100000000000,%0000000000011000
		dc.w		%0001100000000000,%0000000000011000
		dc.w		%0001100000000000,%0000000000011000
		dc.w		%0001100000000000,%0000000000011000
		dc.w		%0001100000000000,%0000000000011000
		dc.w		%0001100000000000,%0000000000011000
		dc.w		%0001100000000000,%0000000000011000
		dc.w		%0001100000000000,%0000000000011000
		dc.w		%0001100000000000,%0000000000011000
		dc.w		%0001100000000000,%0000000000011000
		dc.w		%0001100000000000,%0000000000011000
		dc.w		%0001100000000000,%0000000000011000
		dc.w		%0001100000000000,%0000000000011000
		dc.w		%0001100000000000,%0000000000011000
		dc.w		%0001111111111111,%1111111111111000
		dc.w		%0000000000000000,%0000000000000000
		dc.w		%0000000000000000,%0000000000000000


		dc.w		%0000000000000000,%0000000000000000	1
		dc.w		%0000000000000000,%0000000000000000	2
		dc.w		%0000000000000000,%0000000000000000	3
		dc.w		%0000000000000000,%0000000000000000	4
		dc.w		%0000000000000000,%0000000000000000	5
		dc.w		%0000000000000000,%0000000000000000	6
		dc.w		%0000000000000000,%0000000000000000	7
		dc.w		%0000000000000000,%0000000000000000	8
		dc.w		%0000000000000000,%0000000000000000	9
		dc.w		%0000000000000000,%0000000000000000	10
		dc.w		%0000000000000000,%0000000000000000	00
		dc.w		%0000000000000000,%0000000000000000	12
		dc.w		%0000000000000000,%0000000000000000	13
		dc.w		%0000000000000000,%0000000000000000	14
		dc.w		%0000000000000001,%1000000000000000	15
		dc.w		%0000000000000001,%1000000000000000	16
		dc.w		%0000000000000001,%1000000000000000	17
		dc.w		%0000000000000000,%0000000000000000	18
		dc.w		%0000000000000000,%0000000000000000	19
		dc.w		%0000000000000000,%0000000000000000	20
		dc.w		%0000000000000000,%0000000000000000	21
		dc.w		%0000000000000000,%0000000000000000	22
		dc.w		%0000000000000000,%0000000000000000	23
		dc.w		%0000000000000000,%0000000000000000	24
		dc.w		%0000000000000000,%0000000000000000	25
		dc.w		%0000000000000000,%0000000000000000	26
		dc.w		%0000000000000000,%0000000000000000	27
		dc.w		%0000000000000000,%0000000000000000	28
		dc.w		%0000000000000000,%0000000000000000	29
		dc.w		%0000000000000000,%0000000000000000	30
		dc.w		%0000000000000000,%0000000000000000	31
		dc.w		%0000000000000000,%0000000000000000	32


end



	
	

