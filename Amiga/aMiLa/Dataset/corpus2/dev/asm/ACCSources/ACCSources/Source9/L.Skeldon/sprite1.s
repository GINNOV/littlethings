;Note because sprite channles 0-7 are all enabled at same time channels 1-7
;MUST be pointed at a dummy sprite or garbage will be displlayed on screen 

	include	Source9:include/hardware.i
	opt	c-

; This program sets up a 1 bit plane screen. The copper list has loads of
;room (68 bytes) for expansion. Routines to operate on the bit plane 
;should be inserted where the program waits for a mouse press.

;Most of prog ripped from M.Meanys prog to display 1 bitplane
;Sprite routine added by Raistlin
;Its very simple so beginners WILL understand it or be shot

start

; Reserve memory for copper list and one bit plane

	move.l	execbase,a6	a6-->exec lib
	move.l	#40*256,d0	d0=size of bitplane
	moveq.l	#chip,d1	make sure its chip ram
	jsr	allocmem(a6)	get memory
	move.l	d0,bpl1	save pointer
	move.l	#100,d0
	moveq.l	#chip,d1	
	jsr	allocmem(a6)	;Give me sprite some memory
	move.l	d0,spr1
	beq	quit_fast	leave if error
	move.l	#80,d0	d0=size of copper list
	moveq.l	#chip,d1	make sure its chip ram
	jsr	allocmem(a6)	get memory
	move.l	d0,clist	save pointer
	beq	quit	leave if error
	
	move.l	spr1,a1
	lea	sprite(pc),a2
sprloop	move.l	(a2),(a1)+
	cmp.l	#$00000000,(a2)+
	bne	sprloop
; Build copper list

	move.l	d0,a0	a0-->copper list
	move.l	#bpl1pth,d1	d1-->DMA register
	move.w	d1,(a0)+	write into copper list
	move.l	bpl1,d0	d0-->bit plane
	swap	d0	get MSB of address
	move.w	d0,(a0)+	write into copper list
	move.l	#bpl1ptl,d1	d1-->DMA register
	move.w	d1,(a0)+	write into copper list
	swap	d0	get LSB of address
	move.w	d0,(a0)+	write into copper list
	move.w	#spr0pth,(a0)+
	move.l	spr1,d2
	swap	d2
	move.w	d2,(a0)+
	move.w	#spr0ptl,(a0)+	Basically same as above only 
	swap	d2		for sprite pointer
	move.w	d2,(a0)+
	move.w	#spr1pth,(a0)+	SEE TOP
	move.w	#$0003,(a0)+
	move.w	#spr1ptl,(a0)+
	move.w	#$0000,(a0)+
	move.w	#spr2pth,(a0)+
	move.w	#$0003,(a0)+
	move.w	#spr2ptl,(a0)+
	move.w	#$0000,(a0)+
	move.w	#spr3pth,(a0)+	"
	move.w	#$0003,(a0)+
	move.w	#spr3ptl,(a0)+
	move.w	#$0000,(a0)+
	move.w	#spr4pth,(a0)+
	move.w	#$0003,(a0)+
	move.w	#spr4ptl,(a0)+	"
	move.w	#$0000,(a0)+
	move.w	#spr5pth,(a0)+
	move.w	#$0003,(a0)+
	move.w	#spr5ptl,(a0)+
	move.w	#$0000,(a0)+
	move.w	#spr6pth,(a0)+	"
	move.w	#$0003,(a0)+
	move.w	#spr6ptl,(a0)+
	move.w	#$0000,(a0)+
	move.w	#spr7pth,(a0)+
	move.w	#$0003,(a0)+
	move.w	#spr7ptl,(a0)+	"
	move.w	#$0000,(a0)+
	move.l	#$fffffffe,d0	end of copper list
	move.l	d0,(a0)	write into copper list
	
; DMA off and o/s out

	jsr	forbid(a6)	switch out o/s
	lea	$dff000,a5	a5-->1st DMA register
	move.w	#$01e0,dmacon(a5) stop DMA
	
; Initialise copper list

	move.l	clist,cop1lch(a5) copper DMA-->our list
	clr.w	copjmp1(a5)	 start our list
	
; Initialise bitplane

	move.w	#$3081,diwstrt(a5) start of our screen
	move.w	#$30c1,diwstop(a5) end of our screen
	move.w	#$0038,ddfstrt(a5) start of DMA
	move.w	#$00d0,ddfstop(a5) end of DMA
	move.w	#%0001001000000000,bplcon0(a5) 1 bitplane
	clr.w	bplcon1(a5)	no scroll
	clr.w	bplcon2(a5)	no priority
	clr.w	bpl1mod(a5)	no modulo
	clr.w	bpl2mod(a5)	no modulo
	move.w	#$83a0,dmacon(a5)   enable DMA
	
; Clear this bit plane
	move.l	bpl1,a0	a0-->bitmap
	move.w	#(10*256)-1,d2	d2=counter
	move.l	#$00,d0	use d0 to clr bitmap
clrloop	move.l	d0,(a0)+	blank next piece
	dbra	d2,clrloop	loop back until finished



; Wait for mouse

loop	nop
	nop
	nop
	btst	#6,ciaapra	mouse button pressed?
	bne	loop	if not go back

; Activate system copper list

	move.l	#grname,a1	a1-->library name
 	moveq.l	#0,d0	any version
	jsr	openlibrary(a6) open graphics lib
	move.l	d0,a4	a4-->graphics lib
	move.l	startlist(a4),cop1lch(a5) DMA-->sys list
	clr.w	copjmp1(a5)	start sys list
	move.w	#$83e0,dmacon(a5) enable all DMA
	jsr	permit(a6)	bring back o/s
	
; Give reserved memory back to system

	move.l	clist,a1	a1-->mem to free
	move.l	#80,d0	d0=size of mem chunk
	jsr	freemem(a6)	free it
	
quit	move.l	bpl1,a1	a1-->mem to free
	move.l	#40*256,d0	d0=size of mem chunk
	jsr	freemem(a6)	free it

	move.l	spr1,a1
	move.l	#100,d0
	jsr	freemem(a6)	
quit_fast	rts

sprite
	dc.w	$6d60,$7200	;Sprite data
	dc.w	$0990,$07e0
	dc.w	$13c8,$0ff0
	dc.w	$23c4,$1ff8
	dc.w	$13c8,$0ff0
	dc.w	$0990,$07e0
	dc.w	$0000,$0000
; Program variable area

clist	dc.l	0
bpl1	dc.l	0
spr1	dc.l	0
grname	dc.b	'graphics.library',0
	even

;EXEC LIB. OFFSETS

openlibrary	=	-30-522
forbid	=	-30-102
permit	=	-30-108
allocmem	=	-30-168
freemem	=	-30-180

;GRAPHICS LIB. OFFSETS

startlist	=	38

;OTHER STUFF

execbase	=	$4
chip	=	$2


