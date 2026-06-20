;bltcon0     EQU   $040
;bltcon1     EQU   $042
;bltafwm     EQU   $044
;bltalwm     EQU   $046
bltcpt	    EQU   $048
bltbpt	    EQU   $04C
bltapt	    EQU   $050
bltdpt	    EQU   $054
;bltsize     EQU   $058
;bltcon0l    EQU   $05B		; note: byte access only
bltsizv     EQU   $05C
bltsizh     EQU   $05E
;
;bltcmod     EQU   $060
;bltbmod     EQU   $062
;bltamod     EQU   $064
;bltdmod     EQU   $066
;
;bltcdat     EQU   $070
;bltbdat     EQU   $072
;bltadat     EQU   $074


	xdef	_BlitterConvert

;note: destination bitplanes have to be in this order: 7, 3, 5, 1, 6, 2, 4, 0
;      and the chunky buffer must be in chip
;      this routine is best used on machines with a slow CPU and chipram only

; void __asm BlitterConvert (register __d2 UBYTE *chunky,
;                            register __d3 PLANEPTR raster,
;                            register __a6 struct GfxBase *GfxBase);


Width	= 320	; must be a multiple of 16
Height	= 200
Depth	= 8
BplSize = Width/8*Height
Size	= Width/8*Height*Depth
Pixels	= Width*Height


_BlitterConvert:

	movem.l	d2-d3/a5,-(sp)

	jsr	_LVOOwnBlitter(a6)
	lea	($dff000),a5


	;PASS-1

	;subpass1
	jsr	_LVOWaitBlit(a6)

	moveq	#-1,d0
	move.l	d0,bltafwm(a5)

	move.w	#0,bltdmod(a5)

	move.l	d2,bltapt(a5)		; Chunky
	addq.l	#8,d2
	move.l	d2,bltbpt(a5)		; Chunky+8

	move.l	#Buff1,bltdpt(a5)

	move.w	#8,bltamod(a5)
	move.w	#8,bltbmod(a5)

	move.w	#%1111111100000000,bltcdat(a5)
	move.l	#$0DE48000,bltcon0(a5)	;D=AC+Bc [C const]

	move.w	#Pixels/16,bltsizv(a5)
	move.w	#4,bltsizh(a5)		;do blit

	;subpass2
	jsr	_LVOWaitBlit(a6)

	add.l	#Size-8-2-8,d2
	move.l	d2,bltapt(a5)		; Chunky+Size-8-2
	addq.l	#8,d2
	move.l	d2,bltbpt(a5)		; Chunky+Size-2

	move.l	#Buff1+Size-2,bltdpt(a5)

	move.l	#$8DE40002,bltcon0(a5)	;D=AC+Bc [C const], descending mode

	move.w	#4,bltsizh(a5)		;do blit


	;PASS-2

	;subpass1
	jsr	_LVOWaitBlit(a6)

	move.l	#Buff1,bltapt(a5)
	move.l	#Buff1+4,bltbpt(a5)

	move.l	#Buff2,bltdpt(a5)

	move.w	#4,bltamod(a5)
	move.w	#4,bltbmod(a5)

	move.w	#%1111000011110000,bltcdat(a5)
	move.l	#$0DE44000,bltcon0(a5)	;D=AC+Bc [C const]

	move.w	#Pixels/8,bltsizv(a5)
	move.w	#2,bltsizh(a5)		;do blit

	;subpass2
	jsr	_LVOWaitBlit(a6)

	move.l	#Buff1+Size-2-4,bltapt(a5)
	move.l	#Buff1+Size-2,bltbpt(a5)

	move.l	#Buff2+Size-2,bltdpt(a5)

	move.l	#$4DE40002,bltcon0(a5)	;D=AC+Bc [C const], descending mode

	move.w	#2,bltsizh(a5)		;do blit


	;PASS-3

	;subpass1
	jsr	_LVOWaitBlit(a6)

	move.l	#Buff2,bltapt(a5)
	move.l	#Buff2+2,bltbpt(a5)

	move.l	#Buff3,bltdpt(a5)

	move.w	#2,bltamod(a5)
	move.w	#2,bltbmod(a5)
	move.w	#Pixels/4,bltsizv(a5)
	move.w	#%1100110011001100,bltcdat(a5)

	move.l	#$0DE42000,bltcon0(a5)	;D=AC+Bc [C const]

	move.w	#1,bltsizh(a5)		;do blit

	;subpass2
	jsr	_LVOWaitBlit(a6)

	move.l	#Buff2+Size-2-2,bltapt(a5)
	move.l	#Buff2+Size-2,bltbpt(a5)

	move.l	#Buff3+Size-2,bltdpt(a5)

	move.l	#$2DE40002,bltcon0(a5)	;D=AC+Bc [C const], descending mode
	move.w	#1,bltsizh(a5)		;do blit


	;PASS-4

	;subpass1
	jsr	_LVOWaitBlit(a6)

	move.l	#Buff3,bltapt(a5)
	move.l	#Buff3+1*Size/8,bltbpt(a5)

	move.l	d3,bltdpt(a5)		; Planes
	move.w	#0,bltamod(a5)
	move.w	#0,bltbmod(a5)
	move.w	#Size/16,bltsizv(a5)	;/8???
	move.w	#%1010101010101010,bltcdat(a5)

	move.l	#$0DE41000,bltcon0(a5)	;D=AC+Bc [C const]
	move.w	#1,bltsizh(a5)		;do blit

	jsr	_LVOWaitBlit(a6)
	move.l	#Buff3+2*Size/8,bltapt(a5)
	move.l	#Buff3+3*Size/8,bltbpt(a5)
	move.w	#1,bltsizh(a5)

	jsr	_LVOWaitBlit(a6)
	move.l	#Buff3+4*Size/8,bltapt(a5)
	move.l	#Buff3+5*Size/8,bltbpt(a5)
	move.w	#1,bltsizh(a5)

	jsr	_LVOWaitBlit(a6)
	move.l	#Buff3+6*Size/8,bltapt(a5)
	move.l	#Buff3+7*Size/8,bltbpt(a5)
	move.w	#1,bltsizh(a5)

	;subpass2
	jsr	_LVOWaitBlit(a6)

	move.l	#Buff3+7*Size/8-2,bltapt(a5)
	move.l	#Buff3+8*Size/8-2,bltbpt(a5)

	add.l	#Size-2,d3
	move.l	d3,bltdpt(a5)		; Planes+Size-2

	move.l	#$1DE40002,bltcon0(a5)	;D=AC+Bc [C const], descending mode
	move.w	#1,bltsizh(a5)		;do blit

	jsr	_LVOWaitBlit(a6)
	move.l	#Buff3+5*Size/8-2,bltapt(a5)
	move.l	#Buff3+6*Size/8-2,bltbpt(a5)
	move.w	#1,bltsizh(a5)		

	jsr	_LVOWaitBlit(a6)
	move.l	#Buff3+3*Size/8-2,bltapt(a5)
	move.l	#Buff3+4*Size/8-2,bltbpt(a5)
	move.w	#1,bltsizh(a5)		

	jsr	_LVOWaitBlit(a6)
	move.l	#Buff3+1*Size/8-2,bltapt(a5)
	move.l	#Buff3+2*Size/8-2,bltbpt(a5)
	move.w	#1,bltsizh(a5)		

	jsr	_LVODisownBlitter(a6)

	movem.l	(sp)+,d2-d3/a5

	rts


         SECTION  segment1,BSS,chip		; MUST BE IN CHIP !!!!!

;Chunky  ds.b Size	;Chunky buffer
Buff1	ds.b Size 	;Intermediate buffer 1
Buff2	ds.b Size	;Intermediate buffer 2
Buff3	ds.b Size	;Intermediate buffer 3

;Planes	ds.b Size+100	;Planes as used on screen
;L29	=Planes+BplSize
;L30	=L29+BplSize
;L31	=L30+BplSize
;L32	=L31+BplSize
;L33	=L32+BplSize
;L34	=L33+BplSize
;L35	=L34+BplSize

	END
