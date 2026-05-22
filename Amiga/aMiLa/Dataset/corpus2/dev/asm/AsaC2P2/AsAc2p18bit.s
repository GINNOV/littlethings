*-----------------------------------------------------------------------
*                            AsAc2p18bit.s  v1.5   05-10-96
*
*
*         a fast 18bit truecolor ham8 c2p routine by ASA/Cirion
*                Modified from Peter Mcgavins Gloom c2p
*  On 030/28Mhz machine this takes 1.6 frames from processor to convert
*                         ( 160*100 2x2 screen )
*         Then blitter is activated to do 1 blit for every plane
*                     Long word writes to chipmem !
*                           Double buffering !
*                                Linear !
*
*              Remember to thank me if you use this !  =)
*
* tchunky .l = ptr to truecolor chunky area in fast mem  160*100*4 RBGB
* Cbuf = buffer for c2p routine. Processor converts chunky to Cbuf
*        and then blitter converts from Cbuf to screen with 1 blit/plane
* Chip_map2 .l = ptr to 640/8*100*2 area in chip mem for Ham8 Mask bits
* Chip_map .l = ptr to 640/8*100*6 screen 1 in chip mem
* Chip_map3 .l = ptr to 640/8*100*6 screen 2 in chip mem
* c2p_blitter_4pass .w = blitter progress
*                       0-blitter is ready for blits
*                       10- blitting plane 1
*                       11- blitting plane 2
*                       12- blitting plane 3
*                       13- blitting plane 4
*                       14- blitting plane 5
*                       15- blitting plane 6
*                       16- all done   -> 0
*
*
* Works nice... Used in an intro called Hope2 by Cirion at Skenery'96
*               Look at cirhope2.lzx....
*
*  Don't blame me if you destroy your computer/software with this ! ;)
*
* My E-mail address:   juhpin@freenet.hut.fi
*
*
*               And get your ass to Demolition II -party
*                           at Joensuu !!!  22-24 NOV 96
*                  Read demolition.txt for more info !
*-----------------------------------------------------------------------



;--------------- Made with Trashm'one -------------
;----- So it works also with other compilers ------
;-------------- Just compile and run ! ------------
;---------------- Shows FPS rate (put fpss equ 1)--

;***********************************************************
tasta		equ	1	; 1-if run from asmone  0-if from shell
ntsc		equ	1	; 1-NTSC (full screen :-)  0-PAL
fpss		equ	0	; 1-fps numbers  0-no numbers
hiiri_nappi	equ	1

Y_SIZE		equ	100	; blitter y lines
BLTVERT		equ	Y_SIZE*80/2

_LVOAllocMem		equ	-$00c6
_LVOFreeMem		equ	-$00d2

call	MACRO
	jsr	_lvo\1(a6)
	ENDM

push	MACRO
	movem.l	d0-d7/a0-a6,-(sp)
	ENDM
pull	MACRO
	movem.l	(sp)+,d0-d7/a0-a6
	ENDM

waitblit	MACRO
_wait\@:	btst	#14,dmaconr+custom      ; use #6 if this don't work
		bne.s	_wait\@
	ENDM

;---- custom regs...
BLTSIZH	equ	$05e
BLTSIZV	equ	$05c

custom  = $dff000

bltcon0 = $040
bltcon1 = $042
bltafwm = $044
bltalwm = $046
bltapth = $050
bltbpth = $04c
bltdpth = $054
bltamod = $064
bltbmod = $062
bltdmod = $066
bltcdat = $070

bpl1pth = $0e0
bpl1ptl = $0e2
bpl2pth = $0e4
bpl2ptl = $0e6
bpl3pth = $0e8
bpl3ptl = $0ea
bpl4pth = $0ec
bpl4ptl = $0ee
bpl5pth = $0f0
bpl5ptl = $0f2
bpl6pth = $0f4
bpl6ptl = $0f6
bpl7pth = $0f8
bpl7ptl = $0fa
bpl8pth = $0fc
bpl8ptl = $0fe
bplcon0 = $100
bplcon1 = $102
bplcon2 = $104
bplcon3	= $106

cop1lch = $080
copjmp1 = $088

ddfstrt = $092
ddfstop = $094
diwstrt = $08e
diwstop = $090
dmacon  = $096
dmaconr = $002

intena  = $09a
intreq  = $09c
intreqr = $01e

spr0pth = $120
spr0ptl = $122
spr1pth = $124
spr1ptl = $126
spr2pth = $128
spr2ptl = $12a
spr3pth = $12c
spr3ptl = $12e
spr4pth = $130
spr4ptl = $132
spr5pth = $134
spr5ptl = $136
spr6pth = $138
spr6ptl = $13a
spr7pth = $13c
spr7ptl = $13e


EXT_0004	EQU	$DFF01F
FASTME		equ	%10000000000000001
CHIPME		equ	%10000000000000010

hiirulainen:	MACRO
;	  btst	#10,potgor+custom	; rigth mouse
	  btst	#6,$bfe001		; left mouse
	  beq	prgrts
	ENDM

getmem:	MACRO
	move.l	#\2,d0
	move.l	#\3,d1
	move.l	$4,a6
 	call	AllocMem
	move.l	d0,\1
	beq	\4
	ENDM

freeit:	MACRO
	move.l	\1,a1
	move.l	#\2,d0
	move.l	$4,a6
	call	FreeMem
	ENDM

clossi:	MACRO
	move.l	handle,d1	;
	move.l	dosbase,a6
	call	Close
	ENDM

opni:	MACRO
	move.l	#1005,d2
	move.l	dosbase,a6
	call	Open
	move.l	d0,handle
	ENDM

;**********************************************************************
	section	ohjelma,code

wbstartup:
	CLR.L	LAB_0003
	MOVE.L	#$00000000,A1
	MOVE.L	$4,A6
	JSR	-294(A6)		; findtask
	MOVE.L	D0,A4
	TST.L	172(A4)			; onko cli?
	BEQ.S	LAB_0000		; wb
	BRA.S	cli			; cli
LAB_0000:
	moveq	#0,d0
	cmp	#tasta,d0
	bne	cli
	LEA	92(A4),A0
	MOVE.L	$4,A6
	JSR	-384(A6)		; waitport
	LEA	92(A4),A0
	MOVE.L	$4,A6
	JSR	-384(A6)		; waitport
	MOVE.L	D0,LAB_0003
	MOVEM.L	(sp)+,D0/A0
cli:
	BSR.S	LAB_0004
	MOVE.L	D0,-(sp)
	TST.L	LAB_0003
	BEQ.S	LAB_0002
	MOVE.L	$4,A6
	JSR	-132(A6)		; forbid
	MOVE.L	LAB_0003(PC),A1
	MOVE.L	$4,A6
	JSR	-378(A6)		; replymsg

LAB_0002:
	MOVE.L	(sp)+,D0
	RTS
LAB_0003:
	ORI.B	#$00,D0

LAB_0004:

; --- varaa muistia
	getmem	fasti,160*128*4+94000,FASTME,ei_fastia2

	getmem	chip_map,80*100*8,CHIPME,ei_chip_map
	getmem	chip_map2,80*100*2,CHIPME,ei_chip_map2
	getmem	chip_map3,80*100*6,CHIPME,ei_chip_map3
	move.l	chip_map,chipbuf

;;;;;;;
	move.l	$4,a6
	move.l	#intuname,A1
	moveq	#0,d0
	jsr	-552(a6)		; openlibrary
	move.l	d0,intubase
	beq	ei_intu

	move.l	$4,a6
	move.l	#gfxname,A1
	moveq	#0,d0
	jsr	-552(a6)		; openlibrary
	move.l	d0,gfxbase
	beq	ei_gfx


	waitblit

	MOVE.L	gfxbase,A6
	JSR	-456(A6)		; own blitter

	MOVEQ	#0,D0
	MOVE.L	$4,A6
	BTST	#0,297(A6)		; flags
	BEQ.S	storevbr
	LEA	getvbr0(PC),A5
	JSR	-30(A6)			; supervisor
	BRA.S	storevbr
getvbr0:
	DC.W	$4E7A
	DC.W	$0801
	RTE

_vbr:	dc.l	0
	ORI.B	#$00,D0

storevbr:
	MOVE.L	D0,_vbr

;INT3 VBR
	MOVE.L	_vbr(PC),A0
	MOVE.L	108(A0),oldv

; reset screen hardware
	MOVE.L	gfxbase,A6
	MOVE.L	34(A6),oldview
	MOVE.L	#$00000000,A1
	JSR	-222(A6)		; loadview

	MOVE	#25-1,D7
nowaittof:
	MOVE	#$0020,intreq+custom
LAB_000B:
	BTST	#5,EXT_0004
	BEQ.S	LAB_000B
	DBF	D7,nowaittof

	MOVE	#$0020,dmacon
	MOVE	#$81C0,dmacon

;******************************************** our program
	BSR	prg
;******************************************** end of program

	MOVE	#$4000,intena+custom		; remove blitter
	MOVE.L	_vbr(PC),A0
	MOVE.L	oldv,108(A0)

	waitblit
	waitblit
	waitblit

	MOVE	#$07FC,intreq+custom
	MOVE	#$C000,intena+custom

	MOVE.L	gfxbase,A6
	JSR	-462(A6)		; disown blitter
	MOVE.L	oldview,A1
	JSR	-222(A6)		; loadview

	MOVE	#$0080,dmacon
	MOVE.L	gfxbase,A0
	MOVE.L	38(A0),cop1lch+custom
	MOVE	#$0000,copjmp1+custom
	MOVE	#$81A0,dmacon

	MOVE.L	intubase,A6
	JSR	-390(A6)		; rethinkdisplay

	MOVE.L	gfxbase,A1
	MOVE.L	$4,A6
	JSR	-414(A6)		; closelibrary
ei_gfx:
	MOVE.L	intubase,A1
	MOVE.L	$4,A6
	JSR	-414(A6)		; closelibrary
ei_intu:

;;;

	freeit	chip_map3,80*100*6
ei_chip_map3:
	freeit	chip_map2,80*100*2
ei_chip_map2:
	freeit	chip_map,80*100*8
ei_chip_map:

	freeit	fasti,160*128*4+94000
ei_fastia2:

	CLR.L	D0
	RTS


;**************************************************************

prg:
	move.l	chip_map,chipbuf
	move.l	chip_map,dispbuf

	move.l	_vbr,a1
	move.l	#vbi1,$6c(a1)

 ifne fpss
	moveq	#0,d6
	moveq	#0,d5
	move.l	#font_metal,a0
	move.l	#font_1,a1
	move.w	#80*8-1,d7
	jsr	convaa_flare
 endc


	clr.w	c2p_blitter_4pass
	move.w	#%1000000001100000,intena+custom	; blitter/vbi int
	move.w	#%0000010000000000,dmacon+custom

	jsr	init_ham8_screen

	bsr	ham8_ef
	 hiirulainen

prgrts:
	clr.w	c2p_blitter_4pass
	rts

;---------------------------------------------------------------------
ham8_ef
	move.w	#160*100-1,d5
tee_koko_kuva

	move.l	tchunky,a0	; ptr to screen
	add.l	menossa,a0
	move.b	luku_r,d0		; R
	lsl.l	#8,d0
	move.b	luku_b,d0		; B
	lsl.l	#8,d0
	move.b	luku_g,d0		; G
	lsl.l	#8,d0
	move.b	luku_b,d0		; B
	move.l	d0,(a0)		; RBGB

	addq.l	#4,menossa


	move.w	#30-1,d6
nopeemmin:
	addq.b	#1,luku_b		; add blue
	cmp.b	#63,luku_b		; if blue >63
	bls.s	ei_viela_g
	 clr.b	luku_b			; clear blue
	 addq.b	#1,luku_g		; add green
ei_viela_g

	cmp.b	#63,luku_g		; if green >63
	bls.s	ei_viela_r
	 clr.w	luku_g			; clear green
	 addq.b	#1,luku_r		; add red
ei_viela_r
	dbf	d6,nopeemmin
	dbf	d5,tee_koko_kuva

loop_ham8
;/////////////////
	ifne fpss
	 jsr	laita_numerot
	endc

	jsr	change_buffers
	jsr	convert_tchunky

	addq.w	#1,frameja
;/////////////////
	 ifne hiiri_nappi
	  btst	#6,$bfe001		; left mouse
;	  btst	#10,potgor+custom	; right mouse
	  beq.s	vituiks_pois
	 endc
	bra	loop_ham8
vituiks_pois
	rts

;////////////////////////////////////////////////////
;////////////////////////////////////////////////////////////////
init_ham8_screen:
	move.l	#c2p_cop,cop1lch+custom

	move.l	chip_map2,d0
	move.l	#bluit,a1
	swap	d0
	move.w	d0,(a1)
	swap	d0
	move.w	d0,4(a1)
	add.l	#80*100,d0
	swap	d0
	move.w	d0,8(a1)
	swap	d0
	move.w	d0,12(a1)

	jsr	aseta_disp

 move.l	chip_map2,a0		; tee 1/2 plane valmiiks ham8lle
 move.l	a0,a1
 add.l	#80*100,a1
 move.w	#80*100-1,d7
duu_rgb_plane_class:
 move.b	#%11001100,(a1)+	; plane 1
 move.b	#%01110111,(a0)+	; plane 0
 dbf	d7,duu_rgb_plane_class
 

	move.l	#tyhja,d0
	move.l	#spruit,a1
	move.w	d0,(a1)
	move.w	d0,4(a1)
	move.w	d0,8(a1)
	move.w	d0,12(a1)
	move.w	d0,16(a1)
	move.w	d0,20(a1)
	move.w	d0,24(a1)
	move.w	d0,28(a1)
	move.l	#spruit2,a1
	swap	d0
	move.w	d0,(a1)
	move.w	d0,4(a1)
	move.w	d0,8(a1)
	move.w	d0,12(a1)
	move.w	d0,16(a1)
	move.w	d0,20(a1)
	move.w	d0,24(a1)
	move.w	d0,28(a1)

	move.l	fasti,tchunky
	move.l	tchunky,tchunky_end
	add.l	#160*100*4,tchunky_end
	rts
;//////////////////////////////////////////////////////
;////////////////////////////////////////////////////////////////
aseta_disp:
	move.l	#bluit,a1
	move.l	dispbuf,d0
	swap	d0
	move.w	d0,16(a1)
	swap	d0
	move.w	d0,20(a1)
	add.l	#80*100,d0
	swap	d0
	move.w	d0,24(a1)
	swap	d0
	move.w	d0,28(a1)
	add.l	#80*100,d0
	swap	d0
	move.w	d0,32(a1)
	swap	d0
	move.w	d0,36(a1)
	add.l	#80*100,d0
	swap	d0
	move.w	d0,40(a1)
	swap	d0
	move.w	d0,44(a1)
	add.l	#80*100,d0
	swap	d0
	move.w	d0,48(a1)
	swap	d0
	move.w	d0,52(a1)
	add.l	#80*100,d0
	swap	d0
	move.w	d0,56(a1)
	swap	d0
	move.w	d0,60(a1)
	rts
;//////////////////////////////////////////////////////
change_buffers:
	cmp.w	#1,dbuffer
	beq.s	buffer_1
	  move.l	chip_map,chipbuf
	  move.l	chip_map3,dispbuf
	  move.w	#1,dbuffer
	bra.s	ei_vbi_viel

buffer_1
	  move.l	chip_map3,chipbuf
	  move.l	chip_map,dispbuf
	  move.w	#0,dbuffer
ei_vbi_viel
	  bsr	aseta_disp
	rts
;/////////////////////////////////
	cnop	0,4
blitter_4pass_cont:
	cmp.w	#10,c2p_blitter_4pass
	beq.s	_plane_0
	cmp.w	#11,c2p_blitter_4pass
	beq.w	_plane_1
	cmp.w	#12,c2p_blitter_4pass
	beq.w	_plane_2
	cmp.w	#13,c2p_blitter_4pass
	beq.w	_plane_3
	cmp.w	#14,c2p_blitter_4pass
	beq.w	_plane_4
	cmp.w	#15,c2p_blitter_4pass
	beq.w	_plane_5
	cmp.w	#16,c2p_blitter_4pass
	beq.w	_planes_ready
	rts
;0
_plane_0:
	move.l	#cbuf+4,bltapth+custom
	move.l	#cbuf+2,bltbpth+custom
	move.l	chipbuf,d0
	move.l	d0,bltdpth+custom
	move.w	#%0101010101010101,bltafwm+custom
	move.w	#%0101010101010101,bltalwm+custom
	move.w	#%0101010101010101,bltcdat+custom
	move.w	#2,bltamod+custom
	move.w	#2,bltbmod+custom
	move.w	#0,bltdmod+custom
	move.w	#%0000000000000000,bltcon1+custom
	move.w	#%1111110111111000,bltcon0+custom
	move.w	#BLTVERT,bltsizv+custom
	move.w	#1,bltsizh+custom
	move.w	#11,c2p_blitter_4pass
	rts
;1
_plane_1:
	move.l	#cbuf,bltapth+custom
	move.l	#cbuf+2,bltbpth+custom
	move.l	chipbuf,d0
	add.l	#8000,d0
	move.l	d0,bltdpth+custom
	move.w	#%1010101010101010,bltafwm+custom
	move.w	#%1010101010101010,bltalwm+custom
	move.w	#%0101010101010101,bltcdat+custom
	move.w	#2,bltamod+custom
	move.w	#2,bltbmod+custom
	move.w	#0,bltdmod+custom
	move.w	#%0001000000000000,bltcon1+custom
	move.w	#%0000110111111000,bltcon0+custom
	move.w	#BLTVERT,bltsizv+custom
	move.w	#1,bltsizh+custom
	move.w	#12,c2p_blitter_4pass
	rts
;2
_plane_2:
	move.l	#cbuf+8000*2+4,bltapth+custom
	move.l	#cbuf+8000*2+2,bltbpth+custom
	move.l	chipbuf,d0
	add.l	#8000*2,d0
	move.l	d0,bltdpth+custom
	move.w	#%0101010101010101,bltafwm+custom
	move.w	#%0101010101010101,bltalwm+custom
	move.w	#%0101010101010101,bltcdat+custom
	move.w	#2,bltamod+custom
	move.w	#2,bltbmod+custom
	move.w	#0,bltdmod+custom
	move.w	#%0000000000000000,bltcon1+custom
	move.w	#%1111110111111000,bltcon0+custom
	move.w	#BLTVERT,bltsizv+custom
	move.w	#1,bltsizh+custom
	move.w	#13,c2p_blitter_4pass
	rts
;3
_plane_3:
	move.l	#cbuf+8000*2,bltapth+custom
	move.l	#cbuf+8000*2+2,bltbpth+custom
	move.l	chipbuf,d0
	add.l	#8000*3,d0
	move.l	d0,bltdpth+custom
	move.w	#%1010101010101010,bltafwm+custom
	move.w	#%1010101010101010,bltalwm+custom
	move.w	#%0101010101010101,bltcdat+custom
	move.w	#2,bltamod+custom
	move.w	#2,bltbmod+custom
	move.w	#0,bltdmod+custom
	move.w	#%0001000000000000,bltcon1+custom
	move.w	#%0000110111111000,bltcon0+custom
	move.w	#BLTVERT,bltsizv+custom
	move.w	#1,bltsizh+custom
	move.w	#14,c2p_blitter_4pass
	rts
;4
_plane_4:
	move.l	#cbuf+8000*4+4,bltapth+custom
	move.l	#cbuf+8000*4+2,bltbpth+custom
	move.l	chipbuf,d0
	add.l	#8000*4,d0
	move.l	d0,bltdpth+custom
	move.w	#%0101010101010101,bltafwm+custom
	move.w	#%0101010101010101,bltalwm+custom
	move.w	#%0101010101010101,bltcdat+custom
	move.w	#2,bltamod+custom
	move.w	#2,bltbmod+custom
	move.w	#0,bltdmod+custom
	move.w	#%0000000000000000,bltcon1+custom
	move.w	#%1111110111111000,bltcon0+custom
	move.w	#BLTVERT,bltsizv+custom
	move.w	#1,bltsizh+custom
	move.w	#15,c2p_blitter_4pass
	rts
;5
_plane_5:
	move.l	#cbuf+8000*4,bltapth+custom
	move.l	#cbuf+8000*4+2,bltbpth+custom
	move.l	chipbuf,d0
	add.l	#8000*5,d0
	move.l	d0,bltdpth+custom
	move.w	#%1010101010101010,bltafwm+custom
	move.w	#%1010101010101010,bltalwm+custom
	move.w	#%0101010101010101,bltcdat+custom
	move.w	#2,bltamod+custom
	move.w	#2,bltbmod+custom
	move.w	#0,bltdmod+custom
	move.w	#%0001000000000000,bltcon1+custom
	move.w	#%0000110111111000,bltcon0+custom
	move.w	#BLTVERT,bltsizv+custom
	move.w	#1,bltsizh+custom
	move.w	#16,c2p_blitter_4pass
	rts

_planes_ready:
	move.w	#0,c2p_blitter_4pass
	rts
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;///////////////////////////////////////////////////
;///////////////////////////////////////////////////
laita_numerot:		; show fps
 ifne fpss
	moveq	#0,d0
	move.w	fps,d0
	moveq	#0,d5
kymppeja_viela:
	cmp.l	#10,d0
	blt.s	viel_ykoset
	sub.l	#10,d0
	addq.l	#1,d5
	bra	kymppeja_viela
viel_ykoset:
	move.l	#font_1,a0
	lsl.l	#3,d0
	 lsl.l	#2,d0		; rgb
	add.l	d0,a0
	move.l	#296*4,d3	; x
	bsr.s	skriivaa2

	move.l	#font_1,a0
	lsl.l	#3,d5
	 lsl.l	#2,d5		; rgb
	add.l	d5,a0
	move.l	#288*4,d3	; x
	bsr.s	skriivaa2
 endc
	rts

 ifne fpss
skriivaa2:			; 256x256 chunky
	move.l	tchunky,d4
	add.l	d3,d4
	add.l	#160*4*3,d4

	move.w	#8-1,d6
fon_y2:	move.l	d4,a1
	move.w	#8-1,d7
fon_x2:
	move.l	(a0)+,(a1)+
	dbra	d7,fon_x2

	lea	80*4-8*4(a0),a0
	add.l	#160*4,d4
	dbra	d6,fon_y2
	rts
 endc
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
convaa_flare:
	 move.w	(a0)+,d0	; lo
	 move.w	(a0)+,d2	; hi
	ror.w	#8,d0
	move.b	d0,d1
	ror.w	#8,d2
	ror.w	#2,d2		; 6 bit ei 8
	move.b	d2,d3
	and.b	#%11,d3
	lsl.b	#2,d1
	or.b	d3,d1
	;	 not.b	d1
 and.b	#%00111111,d1
; lsl.b	#2,d1
 lsr.b	d6,d1
 sub.b	d5,d1
		cmp.b	#63,d1
		bls.s	subbi_siibbi
		moveq	#0,d1
subbi_siibbi:
	move.b	d1,(a1)

	rol.w	#4,d0
	move.b	d0,d1
	rol.w	#4,d2
	move.b	d2,d3
	and.b	#%11,d3
	lsl.b	#2,d1
	or.b	d3,d1
	;	 not.b	d1
 and.b	#%00111111,d1
; lsl.b	#2,d1
 lsr.b	d6,d1
 sub.b	d5,d1
		cmp.b	#63,d1
		bls.s	subbi_siibbi2
		moveq	#0,d1
subbi_siibbi2:
	move.b	d1,2(a1)

	rol.w	#4,d0
	move.b	d0,d1
	rol.w	#4,d2
	move.b	d2,d3
	and.b	#%11,d3
	lsl.b	#2,d1
	or.b	d3,d1
	;	 not.b	d1
 and.b	#%00111111,d1
; lsl.b	#2,d1
 lsr.b	d6,d1
 sub.b	d5,d1
		cmp.b	#63,d1
		bls.s	subbi_siibbi3
		moveq	#0,d1
subbi_siibbi3:
	move.b	d1,1(a1)
	move.b	d1,3(a1)

	addq.l	#4,a1
	dbf	d7,convaa_flare
	rts
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
convert_tchunky:
	move.l	tchunky,a0
			;	move.l	chip_map,a1
	 move.l	#cbuf,a1
	move.l	#640,d0
	move.l	#100,d1
	move.l	#80*100,d2
	move.l	#80,d3
	jsr	_c2p

ei_olla_viel_4pass_tehty_tchu:
	tst.w	c2p_blitter_4pass
	bne.s	ei_olla_viel_4pass_tehty_tchu

	move.w	#10,c2p_blitter_4pass
	bsr	blitter_4pass_cont
	rts
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	section	muita_ohjelmia,code

hurja:	dc.w	0
vbi1:
;*******************************
	move.w	d0,hurja
	move.w	intreqr+custom,d0
	btst	#6,d0
	beq.s	ei_blitter_normaali_vbi22
		push
		jsr	blitter_4pass_cont
		pull
		move.w	#%0000000001000000,intreq+custom
ei_blitter_normaali_vbi22
	btst	#5,d0
	bne.s	edes_vbi_oli_se22
	move.w	#%0000000000100000,intreq+custom
	move.w	hurja,d0
	rte
edes_vbi_oli_se22
	move.w	hurja,d0

	push
	addq.l	#1,timer

	cmp.l	#50+10*NTSC,timer
	ble.s	lasketaan_FPS22
	move.w	frameja,fps
	clr.l	timer
	clr.w	frameja
lasketaan_FPS22

;*******************************
	move.w	#%0000000000100000,intreq+custom
	pull
	rte

timer:	dc.l	0

;////////////////////////////////////////////
	section	rojdua,data

dosname:	dc.b	'dos.library',0
intuname:	dc.b	'intuition.library',0
gfxname:	dc.b	'graphics.library',0
	even
dosbase:	dc.l	0
gfxbase:	dc.l	0
intubase:	dc.l	0
handle:		dc.l	0
c2p_blitter_4pass	dc.w	0
menossa:	dc.l	0
fps:		dc.w	0
fasti:		dc.l	0
frameja:	dc.w	1
chip_map:	dc.l	0
chip_map2:	dc.l	0
chip_map3:	dc.l	0
oldv:	dc.l	0
oldview:	dc.l	0
chipbuf:	dc.l	0	; ptr to draw buffer
dispbuf:	dc.l	0	; ptr to display buffer
dbuffer:	dc.w	0
tchunky:	dc.l	0
tchunky_end:	dc.l	0

luku_r:		dc.b	0
luku_g:		dc.b	0
luku_b:		dc.b	0
	even

 ifne fpss
		incdir	hd0:
font_metal:	incbin	fonttia_80x8.rgb
font_1:		blk.l	80*8,0
 endc


;------------------------------------------------------------------------
	section kuupperi,data_c
c2p_cop:
			;	dc.w	$01fc,3
	dc.w	$01fc,3+16384
	dc.w	$108,-80-8
	dc.w	$10a,-8

	ifne	ntsc
	 dc.w	$1dc,$0		; NTSC
	endc

	ifeq	ntsc
	 dc.w	diwstrt,$4481	; PAL
	else
	 dc.w	diwstrt,$2c81	; NTSC
	endc
	dc.w	diwstop,$0ac1

	dc.w	ddfstrt,$38
	dc.w	ddfstop,$d0

	dc.w	bplcon1,0
	dc.w	bplcon2,%0000001000000000
	dc.w	bplcon3,%0000000000100000

	dc.w	bplcon0,%1000101000010001

	dc.w	bpl1pth		; bitplanes
bluit:	dc.w	0,bpl1ptl
	dc.w	0,bpl2pth
	dc.w	0,bpl2ptl
	dc.w	0,bpl3pth
	dc.w	0,bpl3ptl
	dc.w	0,bpl4pth
	dc.w	0,bpl4ptl
	dc.w	0,bpl5pth
	dc.w	0,bpl5ptl
	dc.w	0,bpl6pth
	dc.w	0,bpl6ptl
	dc.w	0,bpl7pth
	dc.w	0,bpl7ptl
	dc.w	0,bpl8pth
	dc.w	0,bpl8ptl
	dc.w	0

	dc.w	spr0ptl		; sprites
spruit:	dc.w	0
	dc.w	spr1ptl,0
	dc.w	spr2ptl,0
	dc.w	spr3ptl,0
	dc.w	spr4ptl,0
	dc.w	spr5ptl,0
	dc.w	spr6ptl,0
	dc.w	spr7ptl,0

	dc.w	spr0pth
spruit2: dc.w	0
	dc.w	spr1pth,0
	dc.w	spr2pth,0
	dc.w	spr3pth,0
	dc.w	spr4pth,0
	dc.w	spr5pth,0
	dc.w	spr6pth,0
	dc.w	spr7pth,0

CO	SET $0180		; black palette for ham8  (first 64 colors)
CB	SET $0

	DC.W	$0106,(CB+0)<<13+$000
	DC.W	CO+00,0,CO+02,0,CO+04,0,CO+06,0
	DC.W	CO+08,0,CO+10,0,CO+12,0,CO+14,0
	DC.W	CO+16,0,CO+18,0,CO+20,0,CO+22,0
	DC.W	CO+24,0,CO+26,0,CO+28,0,CO+30,0
	DC.W	CO+32,0,CO+34,0,CO+36,0,CO+38,0
	DC.W	CO+40,0,CO+42,0,CO+44,0,CO+46,0
	DC.W	CO+48,0,CO+50,0,CO+52,0,CO+54,0
	DC.W	CO+56,0,CO+58,0,CO+60,0,CO+62,0
	DC.W	$0106,(CB+1)<<13+$000
	DC.W	CO+00,0,CO+02,0,CO+04,0,CO+06,0
	DC.W	CO+08,0,CO+10,0,CO+12,0,CO+14,0
	DC.W	CO+16,0,CO+18,0,CO+20,0,CO+22,0
	DC.W	CO+24,0,CO+26,0,CO+28,0,CO+30,0
	DC.W	CO+32,0,CO+34,0,CO+36,0,CO+38,0
	DC.W	CO+40,0,CO+42,0,CO+44,0,CO+46,0
	DC.W	CO+48,0,CO+50,0,CO+52,0,CO+54,0
	DC.W	CO+56,0,CO+58,0,CO+60,0,CO+62,0
	DC.W	$0106,(CB+0)<<13+$200
	DC.W	CO+00,0,CO+02,0,CO+04,0,CO+06,0
	DC.W	CO+08,0,CO+10,0,CO+12,0,CO+14,0
	DC.W	CO+16,0,CO+18,0,CO+20,0,CO+22,0
	DC.W	CO+24,0,CO+26,0,CO+28,0,CO+30,0
	DC.W	CO+32,0,CO+34,0,CO+36,0,CO+38,0
	DC.W	CO+40,0,CO+42,0,CO+44,0,CO+46,0
	DC.W	CO+48,0,CO+50,0,CO+52,0,CO+54,0
	DC.W	CO+56,0,CO+58,0,CO+60,0,CO+62,0
	DC.W	$0106,(CB+1)<<13+$200
	DC.W	CO+00,0,CO+02,0,CO+04,0,CO+06,0
	DC.W	CO+08,0,CO+10,0,CO+12,0,CO+14,0
	DC.W	CO+16,0,CO+18,0,CO+20,0,CO+22,0
	DC.W	CO+24,0,CO+26,0,CO+28,0,CO+30,0
	DC.W	CO+32,0,CO+34,0,CO+36,0,CO+38,0
	DC.W	CO+40,0,CO+42,0,CO+44,0,CO+46,0
	DC.W	CO+48,0,CO+50,0,CO+52,0,CO+54,0
	DC.W	CO+56,0,CO+58,0,CO+60,0,CO+62,0

	dc.w	bplcon3,%0000000000100000

	ifne	ntsc
	 dc.w	$f201,$ff00
	 dc.w	bplcon0,%0000000000000001
	endc
	dc.l	$fffffffe
	dc.l	$fffffffe

tyhja:	dc.l	0,0,0,0



	section	muunnooni,code

Suorista:	MACRO
	 move.l	d5,-(sp)
	move.l	(a0)+,d1
	move.l	(a0)+,d5
	move.l	(a0)+,d2
	 move.l	#$ff00ff00,d6

	move.l	d1,d0
	and.l	d6,d0
	eor.l	d0,d1
	lsl.l	#8,d1

	move.l	d2,d3
	and.l	d6,d3
	eor.l	d3,d2

	lsr.l	#8,d3
	or.l	d3,d0

	or.l	d2,d1

	 move.l	(a0)+,d3

	move.l	d5,d2
	and.l	d6,d2
	eor.l	d2,d5
	lsl.l	#8,d5

	move.l	d3,d4
	and.l	d6,d4
	eor.l	d4,d3

	lsr.l	#8,d4
	or.l	d4,d2

	or.l	d5,d3

	move.l	(sp)+,d5
	move.l	a2,d6
	ENDM


	section	planaari,code
_c2p:
		movea.l	d2,a5		; a5 = bpmod
		lsl.l	#2,d2
		add.l	a5,d2
		subq.l	#2*2,d2
		movea.l	d2,a6		; a6 = 5*bpmod-2

		lsr.w	#4,d0
		ext.l	d0
		move.l	d0,d4
		subq.l	#1,d4
		move.l	d4,-(sp)	; (4,sp) = num of 16 pix per row - 1

		add.l	d0,d0		; num of 8 pix per row (bytesperrow)
		sub.l	d0,d3
		sub.l	a6,d3
		move.l	d3,-(sp)	; (sp) = linemod-bytesperrow-5*bpmod+2

		move.w	d1,d7
		subq.w	#1,d7		; d7 = height-1

		movea.l	#$f0f0f0f0,a2	; a2 = 4 bit mask
		movea.l	#$cccccccc,a3	; a3 = 2 bit mask
		movea.l	#$aaaa5555,a4	; a4 = 1 bit mask
		move.l	a2,d6		; 4 bit mask = #$f0f0f0f0

;------------------------------------------------------------------------
;------------------------------------------------------------------------

		swap	d7
		move.w	6(sp),d7	; num 16 pix per row - 1

	 suorista
		move.l	d0,d4
		and.l	d6,d0
		eor.l	d0,d4
		lsl.l	#4,d4

		bra.w	.same_from_here

		cnop	0,4

.outerloop	swap	d7
		move.w	6(sp),d7	; num 16 pix per row - 1

	 suorista
	move.l	d5,(a1)		; 31 -> plane 4
	adda.l	a5,a1		; +bpmod

		move.l	d0,d4
		and.l	d6,d0
		eor.l	d0,d4
		lsl.l	#4,d4

		adda.l	(sp),a1		; +linemod-bytesperrow-5*bpmod+2

		bra.b	.same_from_here

.innerloop
	 suorista
	move.l	d5,(a1)		; 31 -> plane 4
	adda.l	a5,a1		; +bpmod


		move.l	d0,d4
		and.l	d6,d0
		eor.l	d0,d4
		lsl.l	#4,d4

		suba.l	a6,a1		; -5*bpmod+2

.same_from_here
		move.l	d2,d5
		and.l	d6,d5
		eor.l	d5,d2
		lsr.l	#4,d5

		or.l	d5,d0
		or.l	d4,d2		; 00x02 -> 10 11

		move.l	d1,d4
		and.l	d6,d1
		eor.l	d1,d4

		move.l	d3,d5
		and.l	d6,d5
		eor.l	d5,d3
		lsr.l	#4,d5
		lsl.l	#4,d4

		or.l	d5,d1
		or.l	d4,d3		; 01x03 -> 12 13

		move.l	a3,d6		; 2 bit mask = #$cccccccc

		move.l	d2,d4
		and.l	d6,d2
		eor.l	d2,d4

		move.l	d3,d5
		and.l	d6,d5
		eor.l	d5,d3

		lsl.l	#2,d4
		or.l	d4,d3		; 11x13b -> 23


	move.l	d3,(a1)		; 33 -> plane 0
	adda.l	a5,a1		; +bpmod
	 adda.l	a5,a1		; +bpmod

	 move.l	a4,d6		; 1 bit mask = #$aaaa5555

		lsr.l	#2,d5
		or.l	d5,d2		; 11x13a -> 22

	move.l	d2,(a1)		; 32 -> plane 2
	adda.l	a5,a1		; +bpmod
	 adda.l	a5,a1		; +bpmod

		lsl.l	#2,d0
		or.l	d0,d1		; 10x12b -> 21
	 move.l	d1,d5

		dbra	d7,.innerloop

		swap	d7
		dbra	d7,.outerloop

		move.l	d5,(a1)		; 31 -> plane 4

		addq.l	#8,sp		; remove locals
		rts

;-----------------------------------------------------------
	section feafae,data_c
cbuf:	blk.b	640/8*100*6,0


