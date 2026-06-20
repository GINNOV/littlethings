		section dosloader,code_c
		opt	c-,o+,a+

*****************************************************************************
*
*             RELOCATIBLE HARDWARE  « File Loading System » ( FLS v4.2 )
*           --------------------------------------------------------------
*
*   These routines allow loading of data using the normal dos filesystem
* but without having to have the os intact ( thus allowing it to be killed
* for memory usage purposes.
* 
*   For test purposes i've preserved system dma,intena,etc so that you can
* test load files and return to the devpac without having to reset and reload
* the devpac editor.
*
*   These routines =HAVE= been tested on several disks and they =DO= work
* properly now but you must use CAPITAL LETTERS when saving the files and
* loading them from disk. You can use all UpperCase letters in the save 
* and load filenames but no Lowercase letter or the file will fail to load
*
* ALSO you MUST save the files to the ROOT directory,not a subdir
*
* Before you assemble this,you must make sure that the file buffer (load address)
* is large enough for the file to be loaded into otherwise it will overflow 
* past you allocated file space. See bottom of file for more information...
*
* LAST WORD
* ---------
* Sorry that the actual routines are'nt fully commented,but I've tried to give
* you enough information here to get you up and running..
*
*****************************************************************************


*****************************************************************************
* Firstly Define some Equ's
* -------------------------
*****************************************************************************

_ciaa   equ $bfe001
_ciab   equ $bfd000
_custom equ $dff000
track	equ $0
gap	equ 3350
sync	equ $4489
dskdatr	equ $008
dskbytr	equ $01a
intenar	equ $01c
intreqr	equ $01e
dskpth	equ $020
dsklen	equ $024
dskdat	equ $026
dsksync	equ $07e
dmacon	equ $096
intena	equ $09a
intreq	equ $09c
dmaconr	equ $002
adkconr	equ $010
adkcon	equ $09e
bplcon0	equ $100
color00	equ $180


*****************************************************************************
* Save then Kill Operating system
* -------------------------------
*
* I've done this, simply for test purposes so that once the file has been
* loaded the os can be restored and you will be returned to devpac
*
*****************************************************************************

Kill:		movem.l	a0-a6/d0-d7,-(sp)	; save all regesters to stack
		move.l	sp,Stackpoint		; save stack to stackpointer

	        lea	(_custom).l,a6		; get base address in a6
	        move.w  dsklen(a6),d0
		move.w  d0,dsklensav		; preserve dsklen
	        move.w  dsksync(a6),d0
		move.w  d0,dsksyncsav		; preserve dsksync
	        move.w  dskpth(a6),d0
		move.w  d0,dskpthsav		; preserve dskpth
	        move.w  intenar(a6),d0
		move.w  d0,intesav		; preserve intena
	        move.w  intreqr(a6),d0
	        move.w  d0,intrsav		; preserve intreq
	        move.w  dmaconr(a6),d0
	       	move.w  d0,dmasav		; preserve dmaconr
	        move.w  adkconr(a6),d0
	        move.w  d0,adksav		; preserve adkconr


; if you don't intend reviving the os then just use this
; before calling the loader

		move.w	#$7fff,d0		; kill value in d0
	        move.w  d0,dmacon(a6)		; kill dmacon
	        move.w  d0,intena(a6)		; kill intena
	        move.w  d0,intreq(a6)		; kill intreq
	        move.w  d0,adkcon(a6)		; kill adkcon
		move.w	#$0200,_custom+bplcon0	; no bitplanes shown
		clr.w	_custom+color00		; screen black

*****************************************************************************
* Calling the loader routine       ( Register preserved and then restored )
* --------------------------       ----------------------------------------
*
* a0 = filename to load
* a1 = position in the memory to load file to
*
*****************************************************************************

		lea	Filename1(pc),a0	; filename to load
		lea	(LoadAddress).l,a1	; location to load file to

		bsr	AmigaDosLoad		; loads and decrunches file



; you can load lots of files using the same routines to diffent part of
; the memory
;		lea	Filename2(pc),a0	; filename to load
;		lea	(LoadAddress2).l,a1	; location to load file to
;
;		bsr	AmigaDosLoad		; loads and decrunches file
;etc...

*****************************************************************************
* Restore Operating System
* ------------------------
*
* This simply restores old values that were save at the start of the program
* so that the operating system will be restored and come back to life..
* 
*****************************************************************************

StartPrg        lea	(_custom).l,a6		; get base address in a6

	        move.w  dsklensav,d0
       	 	bset    #15,d0
        	move.w  d0,dsklen(a6)		; restore dsklen

	        move.w  dskpthsav,d0
       	 	bset    #15,d0
        	move.w  d0,dskpth(a6)		; restore dskpth

	        move.w  dsksyncsav,d0
       	 	bset    #15,d0
        	move.w  d0,dsksync(a6)		; restore dsksync

	        move.w  intesav,d0
       	 	bset    #15,d0
        	move.w  d0,intena(a6)		; restore intena

        	move.w  intrsav,d0
        	bset    #15,d0
        	move.w  d0,intreq(a6)		; restore intreq

        	move.w  dmasav,d0
        	bset    #15,d0
       		move.w  d0,dmacon(a6)		; restore dmacon

        	move.w  adksav,d0
        	bset    #15,d0
        	move.w  d0,adkcon(a6)		; restore adkcon

		move.l	Stackpoint(pc),sp	; restore stackpointer
		movem.l	(sp)+,a0-a6/d0-d7	; restore regesters

		;jmp (JumpAddress).l		; jump into the unpacked file
exit		rts				;return

*****************************************************************************
* Data Section !
*****************************************************************************
		even
StackPoint:	ds.l	2
		even
dsklensav	dc.w	0
		even
dskpthsav	dc.w	0
		even
dsksyncsav	dc.w	0
		even
intesav 	dc.w    0
		even
intrsav 	dc.w    0
		even
dmasav  	dc.w    0
		even
adksav  	dc.w    0
		even
Filename1:	dc.b    'ANYDOSFILE',0	; name of file to load ( CAPITALS !)
		even

*****************************************************************************
* AMIGA-DOS LOADER ROUTINES ( HARDWARE CONTROLLED )
*****************************************************************************

AmigaDosLoad	movem.l	d1-d7/a0-a6,-(sp)	;save regesters to stack

		move.l	#$BFD100,a5
		bclr	#7,(a5)

                lea	ldat1(pc),a6
                bset	#3,(a5)
                exg	a0,a1

                move.l	a0,-(sp)
                st	(a6)
                move.l	a0,4(a6)
                st      8(a6)
                bclr    #3,(a5)
                move.w  #880,d0		; rootblock
                bsr     l20
                move.l  a1,a2
l1              tst.b   (a2)+
                bne.s   l1
 
		sub.l   a1,a2
		subq.w  #1,a2
		move.l  a2,d2
		moveq.l #0,d3
		move.l  d2,d4
		move.l  d4,d6
		move.l  a1,a3
l2		mulu    #13,d2
		move.b  (a1)+,d3
		add.w   d3,d2
		and.w   #2047,d2
		subq.w  #1,d4
		bne.s   l2
 
		divu    #72,d2
		swap    d2
		addq.w  #6,d2
		lsl.w   #2,d2
		move.l  (a0,d2.w),d0
l3		bsr     l20
		moveq.l #0,d5
		lea     432(a0),a1
		cmp.b   (a1)+,d6
		bne.s   l7
 
		move.l  a3,a2
		move.w  d6,d0
l4		cmpm.b  (a1)+,(a2)+
		bne.s   l7
 
		subq.w  #1,d0
		bne.s   l4
 
		move.l  324(a0),d0
		add.l   ldat2,d0
		move.l  d0,8(a6)
l5		move.l  16(a0),d0
		beq.s   l8
 
		bsr     l20
		lea     24(a0),a1
		move.l  ldat2,a2
		move.l  ldat3,d0
		move.w  #487,d7
l6		move.b  (a1)+,(a2)+
		cmp.l   d0,a2
		dbeq    d7,l6
 
		move.l  a2,4(a6)
		bra.s   l5
 
l7		move.l  496(a0),d0
		bne.s   l3
 
l8		bset    #7,(a5)
		bset    #3,(a5)
		moveq.l #0,d0
		tst.l   d5
		bne.s   l9
 
		moveq.l #-1,d0
l9		bclr    #3,(a5)
		move.l  (sp)+,a0


; I've already sent you the decruncher source, so just call it from here.
; If you add it and the packed file will be decrunched...
;
	;	bsr	decrunch	; use with decruncher source

		movem.l	(sp)+,d1-d7/a0-a6	;restore regesters from stack
		rts     

*****************************************************************************
* subroutines called by AMIGA-DOS loader
*****************************************************************************

 
l10		bset    #1,(a5)
		bsr.s	l16
l11		btst    #4,$0F01(a5)
		bne.s   l10
 
		sf      (a6)
l12		tst.b   (a6)
		bmi.s   l11
 
l13		cmp.b   (a6),d2
		beq.s   l18
 
		bcc.s   l14
 
		bset    #1,(a5)
		subq.b  #1,(a6)
		bra.s   l15
 
l14		bclr    #1,(a5)
		addq.b  #1,(a6)
l15		bsr.s	l16
		bra.s   l13
 
l16		bclr    #0,(a5)
		bset    #0,(a5)
		move.b  #0,$0500(a5)
		move.b  #18,$0600(a5)
		move.b  #25,$0E00(a5)
l17		btst    #0,$0E00(a5)
		bne.s   l17
 
l18		btst    #5,$0F01(a5)
		bne.s   l18
 
		rts     
 
l19		moveq.l #0,d5
		addq.l  #4,sp
		bra.s   l8
 
l20		cmp.w   #1759,d0
		bgt.s   l19
 
		lea     (LoadPtrs).l,a4
		move.l  d0,d2
		ext.l   d2
		divu    #11,d2
		move.l  d2,d4
		swap    d4
		cmp.w   2(a6),d2
		beq.s   l25
 
		move.w  d2,2(a6)
		bset    #2,(a5)
		btst    #0,d2
		beq.s   l21
 
		bclr    #2,(a5)
l21		lsr.w   #1,d2
		bsr	l12
		move.w  #5,12(a6)
		bra.s   l23
 
l22		subq.w  #1,12(a6)
		bne.s   l23
 
		moveq.l #-1,d2
		move.l  d2,(a6)
		bra.s   l20
 
l23		bchg	#1,$bfe001			;filter led/toggles
							;during loading of file
		lea     (LoadPtrs).l,a4
		lea     (_custom+dskpth).l,a0		;dskpth
		move.l  a4,(a0)+

		move.w  #$8210,$072(a0)			;dmacon
		move.l  #$27F00,$078(a0)		;intreq
		move.w  #$9500,$07A(a0)			;adkcon
		move.w  #sync,$05A(a0)			;dsksync
		move.w  #($3400/2)!$8000,(a0)		;dsklen
		move.w  #($3400/2)!$8000,(a0)		;dsklen

		move.l  #$A0000,d7
l24		subq.l  #1,d7
		beq.s   l22
 
		btst    #1,-5(a0)
		beq.s   l24
 
l25		lea     12800(a4),a2
		move.l  a2,a0
		move.l  #$55555555,d5
		moveq.l #10,d1
l26		cmp.w   #sync,(a4)+
		bne.s   l26
 
		cmp.w   #sync,(a4)
		beq.s   l26
 
		movem.l	(a4),d2/d3
		bsr.s	l30
		lsr.w   #8,d2
		cmp.w   d4,d2
		beq.s   l27
 
		add.w   #1080,a4
		dbra    d1,l26
 
		bra   l22
 
l27		swap    d2
		cmp.b   3(a6),d2
		bne     l22
 
		lea     48(a4),a4
		move.l  (a4)+,d2
		move.l  (a4)+,d3
		bsr.s	l30
		move.w  #255,d7
		moveq.l #0,d3
l28		move.l  (a4)+,d4
		eor.l   d4,d3
		dbra    d7,l28
 
		and.l   d5,d3
		cmp.l   d3,d2
		bne     l22
 
		sub.w   #1024,a4
		moveq.l #127,d7
l29		move.l  512(a4),d3
		move.l  (a4)+,d2
		and.l   d5,d2
		and.l   d5,d3
		add.l   d2,d2
		or.l    d3,d2
		move.l  d2,(a2)+
		dbra    d7,l29
		rts      

l30		and.l   d5,d2
		and.l   d5,d3
		add.l   d2,d2
		or.l    d3,d2
		rts     

		even
ldat1		dc.l	0
		even
ldat2		dc.l	0
		even
ldat3		ds.l	2
		even

LoadPtrs	dcb.b	$3400,0	;zero'd bytes (space for trash from track reading!!)
		;or using an abs address (e.g.; equ	$7ca00


LoadAddress	dcb.b	71360,0	; LENGTH of file to load
		;or using an abs address (e.g.; equ	$50000

*****************************************************************************
*
* Additional info
* ---------------
* Because we want to load the file into a relocatible address you must make sure
* that you allocate enough space for the file to load into, i.e. i've dcb'ed 
* 24950 bytes for the file size,because that was the size of the file. If you
* want to use absolute addresses you could just use something like
* LoadAddress:	equ	$50000  and the file would load to the absolute address
* of $50000 in the memory..
*
*****************************************************************************
		
