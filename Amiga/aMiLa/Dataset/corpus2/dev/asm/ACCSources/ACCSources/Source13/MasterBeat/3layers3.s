	Incdir	source:Include/
	Include customregisters
	Section	Cube,Code_c

Ciaapra = $BFE001
Openlibrary = -30-522	
Disable	    = -120
Enable	    = -126
Startlist   = 38
Execbase = 4

bpl1pth:	equ	$e0
bpl1ptl:	equ	$e2
bpl2pth:	equ	$e4
bpl2ptl:	equ	$e6
bpl3pth:	equ	$e8
bpl3ptl:	equ	$ea
bpl4pth:	equ	$ec
bpl4ptl:	equ	$ee
bpl5pth:	equ	$f0
bpl5ptl:	equ	$f2
bpl6pth:	equ	$f4
bpl6ptl:	equ	$f6


color	equ	$180
TextHeight	equ	16

	Move.l	Execbase,a6
	Jsr	Disable(a6)
	jsr	Init_Music


	move.w	#$f0f,scrollcol		;
	move.w	#$fff,vucol		; Initialise the
	move.w	#0,backcol		; colours for end fade.
	move.w	#$007,logocol		;
	move.w	#0,backcol2
	
	move.l	#scrollplane,d0	; Get address of our scroll memory.
	move.w	d0,pl2l		; Move the low word into copper list.
	swap	d0		; Swap the low and high words in d0.
	move.w	d0,pl2h		; Move the high word into the copper
				; list.

	move.l	#logo,d0	; Get address of the logo memory. 
	move.w	d0,pl3l		; Move the low word into copper list.
	swap	d0		; Swap high and low words
	move.w	d0,pl3h		; Move high word into copper.

;-------- Switch Copper DMA ----------


	Move.l	#Clstart,Cop1lc
	Clr	Copjmp1

	Move.w	#$8780,Dmacon
	Move.w	#$0020,Dmacon
	Lea	Spr0data,a0
	Moveq	#7,d0
Clop
	Clr.l	(a0)
	Addq.l	#8,a0
	Dbf	d0,Clop


	lea	CopBar,a0	; Data for copper bar
	lea	Hsinedata,a1	; Data for horiz. sine
	move.w	#$20e1,d0	; Start of bar
	move.l	a1,a2		; Save color start
	move.w	#199,d2		; No. of lines -1	
Cloop	cmpi.w	#$01,(a1)	; Is it end of data?
	bne.s	Cocl		; No, then do loop
	move.l	a2,a1		; Restart current bar
Cocl	move.w	d0,(a0)+		; Address
	move.l	#$fffe0102,(a0)+	; Mask and register
	move.w	(a1)+,(a0)+	; Bplcon1 data
	addi.w	#$0100,d0	; Next line
	dbra	d2,Cloop

;------ Wait for Vertical position 1 --------

Wait:	Move.l	$dff004,d2
	And.l	#$0001ff00,d2	
	Cmp.l	#$00000100,d2
	Bne.s	Wait

	bsr	rottest		; Rotate the 3d
miss	bsr	TD_rout		; Draw the 3d

	move.w	#$20,$8(a5)
	jsr	Play_Music	; Future Composer player

	jsr	scrolly		; Twisty sine scroll
	jsr	Cycle		; Cycle the Bplcon1 contents

	
	Btst	#6,Ciaapra	; Test LMB
	Bne	Wait		; No, then loop

	
	jsr	End_Music
	move.w	#$777,logocol	; Lighten up the logo a bit

Wait2:	Move.l	$dff004,d2
	And.l	#$0001ff00,d2	
	Cmp.l	#$00000100,d2	; Are we at the bottom?
	Bne.s	Wait2		; No, then loop
	
	bsr	fadetest	; Fade our colours

	
	cmpi.w	#$fff,logocol	; Is the logo white yet?
	blt	Wait2		; No, then loop


;------ Restore old Copper list -----------

	Move.l	Execbase,a6
	Move.l	#Grname,a1
	Clr.l	d0
	Jsr	Openlibrary(a6)
	Move.l	d0,a4
	Move.l	Startlist(a4),Cop1lc
	Clr.w	Copjmp1
	Move.w	#$83E0,Dmacon
	Jsr	Enable(a6)
	Clr.l	d0
	RTS			; Quit back to DOS.....

fadetest:
	add.w	#1,fadecount	; Runs every 15th frame....
	cmpi.w	#15,fadecount	;
	beq	yesfade		;
	rts
	
yesfade:
	move.w	#0,fadecount	; Reset counter
	add.w	#$111,logocol	; Lighten colours up....
	add.w	#$222,backcol
	add.w	#$222,backcol2
	add.w	#$020,scrollcol
	rts


rottest	btst	#2,$dff016		; Is it RMB?
	bne	yesrottest		; No, then rotate the points
	rts

yesrottest	Addq	#2,Zrot
	And	#$1fe,Zrot
	Addq	#4,Yrot
	And	#$1fe,Yrot
	Subq	#2,Xrot
	And	#$1fe,Xrot

	rts

	
Cycle	lea	CopBar+6,a0		* First colour
	lea	8(a0),a1		* Next colour
	move.w	(a0),Store		* Store first in safe place
C_Loop	move.w	(a1),(a0)		* Second goes in first
	add.w	#8,a0			* Next bar
	add.w	#8,a1			* And next bar
	cmp.l	#C_Stop,a1		* End of list?
	blt.s	C_Loop			* No - continue
	sub.w	#8,a1			* Jump back
	move.w	Store,(a1)		* Load stored back
	rts

;--------- 3D graphics ------------
TD_rout
	Move.l	Current(pc),d0
	Move	d0,Screen+2
	Swap	d0
	Move	d0,Screen+6
	Eor.l	#$3000,Current
	Move.l	Current(pc),a0
	Move.l	#$1f00000,Bltcon0
	Move.l	a0,Bltdpth
	Clr	Bltadat
	Clr	Bltdmod
	Move	#256*64+20,Bltsize

	Move	#No_points-1,d7
	Lea	Points(pc),a4	
	Lea	Sintable+$40(pc),a1
	Lea	Rotated_coords(pc),a2
	Lea	Perspective(pc),a3
TD_loop
	Move	(a4)+,d0
	Move	d0,d2
	Move	(a4)+,d1
	Move	d1,d3

	Move	Zrot(pc),d6
	Move	$40(a1,d6),d4
	Move	-$40(a1,d6),d5
	Muls	d4,d0
	Muls	d5,d1
	Sub.l	d1,d0
	Add.l	d0,d0
	Swap	d0		;d0 holds intermediate x coord
	Muls	d5,d2
	Muls	d4,d3
	Add.l	d3,d2
	Add.l	d2,d2
	Swap	d2		;d2 holds intermediate y coord
	Move	d2,d4

	Move	(a4)+,d1	;z coord
	Move	d1,d3
	Move	Xrot(pc),d6
	Move	$40(a1,d6),d5
	Move	-$40(a1,d6),d6
	Muls	d5,d2
	Muls	d6,d1
	Sub.l	d1,d2
	Add.l	d2,d2
	Swap	d2		;d2 holds the final y coord
	Muls	d5,d3
	Muls	d6,d4
	Add.l	d4,d3
	Add.l	d3,d3
	Swap	d3		;d3 holds intermediate z coord

	Move	d0,d1
	Move	d3,d4
	Move	Yrot(pc),d6
	Move	$40(a1,d6),d5
	Move	-$40(a1,d6),d6
	Muls	d5,d3
	Muls	d6,d0
	Sub.l	d0,d3
	Add.l	d3,d3
	Swap	d3		;d3 holds the final z coord
	Muls	d6,d4
	Muls	d5,d1
	Add.l	d4,d1
	Add.l	d1,d1
	Swap	d1		;d1 holds the final x coord

	Add	Depth(pc),d3
	Add	d3,d3
	Move	(a3,d3),d5
	Muls	d5,d1
	Muls	d5,d2
	Add.l	d1,d1
	Swap	d1
	Add	#160,d1
	Add.l	d2,d2
	Swap	d2
	Add	#128,d2
	
	Move	d1,(a2)+
	Move	d2,(a2)+
	Dbf	d7,TD_loop

	Move	#No_connects-1,d7
	Lea	$dff000,a5
	Lea	Connect(pc),a3
	Lea	Rotated_coords(pc),a4
	Moveq	#40,d0
	Lea	Mul40(pc),a1
	Lea	Bits(pc),a2

B_wait2
	Btst	#14,Dmaconr
	Bne.s	B_wait2

	Move	#$ffff,Bltafwm
	Move	d0,$60(a5)	;Bltcmod
	Move	d0,$66(a5)	;Bltdmod
	Move	#$ffff,$72(a5)	;Bltbdat
Draw_loop
	Move	(a3)+,d6
	Move	(a4,d6),d0
	Move	2(a4,d6),d1
	Move	(a3)+,d6
	Move	(a4,d6),d2
	Move	2(a4,d6),d3
	Cmp	d0,d2
	Bne.s	Draw
	Cmp	d1,d3
	Beq.s	Nodraw	
Draw
	Bsr	Line
Nodraw
	Dbf	d7,Draw_loop
Bwit
	Btst	#14,Dmaconr
	Bne.s	Bwit
	Rts

;----------- Line Draw ------------
Line
	Moveq	#0,d4
	Move	d1,d4
	Add	d4,d4
	Move	(a1,d4),d4
	Moveq	#-$10,d5
	And	d0,d5
	Lsr	#3,d5
	Add	d5,d4
	Add.l	a0,d4

	Moveq	#0,d5
	Sub	d1,d3
	Roxl.b	d5
	Tst	d3
	Bge.s	Y2gy1
	Neg	d3
Y2gy1
	Sub	d0,d2
	Roxl.b	d5
	Tst	d2
	Bge.s	X2gx1
	Neg	d2
X2gx1

	Move	d3,d1
	Sub	d2,d1
	Bge.s	Dygdx
	Exg	d2,d3
Dygdx
	Roxl.b	d5
	Move.b	Octant_table(pc,d5),d5
	Add	d2,d2
Wblit
	Btst	#14,Dmaconr
	Bne.s	Wblit

	Move	d2,$62(a5)	;Bltbmod
	Sub	d3,d2
	Bge.s	Signn1
	Or.b	#$40,d5
Signn1
	Move	d2,$52(a5)	;Bltaptl
	Sub	d3,d2
	Move	d2,$64(a5)	;Bltamod

	Move	#$8000,$74(a5)	;Bltadat
	Add	d0,d0
	Move	(a2,d0),$40(a5)	;Bltcon0
	Move	d5,$42(a5)	;Bltcon1
	Move.l	d4,$48(a5)	;Bltcpth
	Move.l	d4,$54(a5)	;Bltdpth
	Lsl	#6,d3
	Addq	#2,d3
	Move	d3,$58(a5)	;Bltsize
	Rts

;---------- Constants -------------

Octant_table
	Dc.b	1,17,9,21,5,25,13,29

Grname:	Dc.b	"graphics.library",0

logo:	incbin source:bitmaps/mblogo8 	; 320*200*2 colours
	Even

;----------- Variables ------------

Xrot	Dc.w	$100
Yrot	Dc.w	0
Zrot	Dc.w	0
Current	Dc.l	$70000
Depth	Dc.w	180
Depthpt	Dc.w	0


waitrot dc.w	0
fadecount:	dc.w	0
Store:	dc.w	0

;---------- Copperlists -----------
Clstart:
	Wait	0,20
	Mov	$2f71,Diwstrt
	Mov	$f4c1,Diwstop
	Mov	$0038,Ddfstrt
	Mov	$00b0,Diwstop
Screen
	Mov	0,Bpl1ptl
	Mov	7,Bpl1pth
	Mov	%0011010000000000,Bplcon0
	Mov	0,Bpl1mod
	Mov	%0000000001000000,Bplcon2
	dc.w	$180
backcol dc.w	$000	
	dc.w	$182
vucol	dc.w	$fff
	dc.w	$192
scrollcol	dc.w	$f0f
	
	dc.w	$184
logocol dc.w	$007

	dc.w	$186,$fff


	dc.w bpl2pth		; Bitplane high word.
pl2h:
	dc.w 0

	dc.w bpl2ptl		; Bitplane low word.
pl2l:
	dc.w 0

	dc.w bpl3pth
pl3h:   dc.w 0

	dc.w bpl3ptl
pl3l:   dc.w 0


	
CopBar	dcb.b	1600,0		
				
	dc.w	color+$00
C_Stop	dc.w	0

	dc.w	$df09,$fffe	; This is here to mask a little
	dc.w	$100,$1200	; bugette....
	dc.w	$180
backcol2:
	dc.w $0000		; So is this....
	Wait	224,255
	Wait	$fe,$ff

;--------- Binaries -------------
No_points	= 32
No_connects	= 32
No_faces	= 6

Points				; Of the form X,Y,Z
				; The points are numbered in
				; steps of four, starting with 0
				
	Dc.w	-130,40,10	}
	Dc.w	-110,40,10	}
	Dc.w	-110,-30,10	}	L
	Dc.w	-70,-30,10	}
	Dc.w	-70,-50,10	}
	Dc.w	-130,-50,10	}
	
	
	dc.w	-60,40,20	}
	dc.w	-40,40,20	}
	dc.w	-40,-30,20	}
	dc.w	-20,-30,20	}  	U
	dc.w	-20,40,20	}
	dc.w	0,40,20		}
	dc.w	0,-50,20	}
	dc.w	-60,-50,20	}
	
	
	dc.w	10,40,10	}
	dc.w	60,40,10	}
	dc.w	60,20,10	}
	dc.w	30,20,10	}
	dc.w	30,0,10		}	F
	dc.w	50,0,10		}
	dc.w	50,-20,10	}
	dc.w	30,-20,10	}
	dc.w	30,-50,10	}
	dc.w	10,-50,10	}
	
	
	dc.w	70,40,20	}
	dc.w	120,40,20	}
	dc.w	120,20,20	}
	dc.w	90,20,20	}
	dc.w	90,-30,20	}	C
	dc.w	120,-30,20	}
	dc.w	120,-50,20	}
	dc.w	70,-50,20	}
	
	

Connect				; The connections between the points.
				; Form: First point,Second point
				
	Dc.w	0,4		}
	Dc.w	4,8		}
	Dc.w	8,12		}
	Dc.w	12,16		}	L connects
	Dc.w	16,20		}
	Dc.w	20,0		}


	dc.w	24,28		}
	dc.w	28,32		}
	dc.w	32,36		}
	dc.w	36,40		}	U connects
	dc.w	40,44		}
	dc.w	44,48		}
	dc.w	48,52		}
	dc.w	52,24		}
	
	
	dc.w	56,60		}
	dc.w	60,64		}
	dc.w	64,68		}
	dc.w	68,72		}
	dc.w	72,76		}	F connects
	dc.w	76,80		}
	dc.w	80,84		}
	dc.w	84,88		}
	dc.w	88,92		}
	dc.w	92,56		}
	
	
	dc.w	96,100		}
	dc.w	100,104		}
	dc.w	104,108		}
	dc.w	108,112		}
	dc.w	112,116		}	C connects
	dc.w	116,120		}
	dc.w	120,124		}
	dc.w	124,96		}
	
Rotated_coords	
	Dcb.w	No_points*2,0
Sintable
	Incbin	source:MasterBeat/Sin
	Incbin	source:masterbeat/Sin
Perspective
	Incbin	source:masterbeat/Perspective

Mul40
A set 0
	Rept	320
	Dc.w	A*40
A set A+1
	Endr

A set 0
Bits
	Rept	320
	Dc.w	((A&$f)*$1000)+$bca
A set A+1
	Endr

Size
A set 0
	Rept	320
	Dc.w	(A*64)+2
A set A+1
	Endr



	
sinscroll:
; first blit clear the scrolly

	lea scrollplane+35*40,a0		; visible bitplane
blitready:
	btst #14,$dff002		
	bne.s blitready			; wait till blitter ready

	move.l a0,$dff054		; source address
	move.l a0,$dff050		; destination address
	clr.l $dff044			; no FWM/LWM (see hardware manual)
	clr.l $dff064			; no MODULO (see hardware manual)

	move.w #%100000000,$dff040 	; Enable DMA channel D, nothing
					; else, no minterms active. 
	clr.w $dff042			; nothing set in BLTCON1
	move.w #65*64+21,$dff058
					; Window size = 21 words wide
					; 65 lines deep


	move.l sinpt,a3
	subq.l #1,a3
	move.b (a3),d0
	cmp.b #255,d0
	bne.s notendofsine
	lea sintabend(pc),a3
notendofsine:
	move.l a3,sinpt

	moveq #19,d0
	lea scplane2,a0
	lea scrollplane+35*40-2,a1

sloop3:

	bsr getsinval

blitready2
	btst #14,$dff002
	bne.s blitready2

	move.l a0,$dff050
	move.l a2,$dff054
	move.l #$f000f000,$dff044
	move.w #40,$dff064
	move.w #38,$dff066
	move.w #%0000100111110000,$dff040
	clr.w $dff042
	move.w #TextHeight*64+1,$dff058

	bsr getsinval

zonk2:
	btst #14,$dff002
	bne zonk2

	move.l a0,$dff050
	move.l a2,$dff054
	move.l a2,$dff04c
	move.l #$f000f00,$dff044
	move.w #40,$dff064
	move.w #38,$dff066
	move.w #38,$dff062
	move.w #%0000110111111100,$dff040
 	clr.w $dff042
	move.w #TextHeight*64+1,$dff058

	bsr getsinval
zonk3:
	btst #14,$dff002
	bne zonk3

	move.l a0,$dff050
	move.l a2,$dff054
	move.l a2,$dff04c
	move.l #$f000f0,$dff044
	move.w #40,$dff064
	move.w #38,$dff066
	move.w #38,$dff062
	move.w #%0000110111111100,$dff040
	clr.w $dff042
	move.w #TextHeight*64+1,$dff058

	bsr getsinval
zonk4:
	btst #14,$dff002
	bne zonk4
	move.l a0,$dff050
	move.l a2,$dff054
	move.l a2,$dff04c
	move.l #$f000f,$dff044
	move.w #40,$dff064
	move.w #38,$dff066
	move.w #38,$dff062
	move.w #%0000110111111100,$dff040
	clr.w $dff042
	move.w #TextHeight*64+1,$dff058



	addq.l #2,a0
LOAD	addq.l #2,a1
	dbra d0,sloop3

rts

getsinval:
	moveq #0,d1
	move.b (a3)+,d1
	move.b (a3),d2
	cmp.b #255,d2
	bne okyar
	move.l #sintab,a3
okyar:
	lsr.b #1,d1
	bclr #0,d1
	mulu #20,d1
	move.l a1,a2
	add.l d1,a2

	rts

scrolly: 
	bsr	sinscroll	; Perform sine movement 
	btst	#2,$dff016	; Is it RMB?
	bne	yesscrolly	; No, then move the scroll left
	rts

yesscrolly:
	move.b pause,d0
	cmp.b #0,d0		; Is the pause over?
	beq gopast		; Yes, then move scroll left
	sub.b #1,d0
	move.b d0,pause
	bra gopast2
gopast:
	move.l #scplane2,a0
	move.l #scplane2+2,a1

blitready3:
	btst #14,$dff002
	bne blitready3
	move.l a0,$dff054
	move.l a1,$dff050
	move.l #-1,$dff044
	clr.l $dff064
	move.w #%1100100111110000,$dff040
	clr.w $dff042
	move.w #TextHeight*64+23,$dff058
gopast2:
	move.b pause,d0
	cmp.b #0,d0		; Is the pause over?
	bne iuo			; No, then return

	move.b countdown,d0
	sub.b #1,d0
	cmp.b #0,d0
	beq mfc
	move.b d0,countdown
iuo:
	rts
	
countdown:
	dc.b 4,0


sinpt: 	dc.l sintabend		
sinpt2: dc.l sintab2

eqtab	ds.b 40


 	dc.b 255

sintab:			; As calculated by Cosaque


	dc.b	-56,-56,-57,-58,-59,-61,-63,-66
	dc.b	-68,-72,-75,-79,-83,-88,-92,-97
	dc.b	-102,-108,-113,-119,-125,125,119,113
	dc.b	106,100,94,87,81,75,69,63
	dc.b	57,52,46,41,36,32,27,23
	dc.b	19,16,12,10,7,5,3,2
	dc.b	1,0,0,0,1,2,3,5
	dc.b	7,10,12,16,19,23,27,32
	dc.b	36,41,46,52,57,63,69,75
	dc.b	81,87,94,100,106,113,119,125
	dc.b	-125,-119,-113,-108,-102,-97,-92,-88
	dc.b	-83,-79,-75,-72,-68,-66,-63,-61
	dc.b	-59,-58,-57,-56


sintabend:
 dc.b -56,255		; The first value is the end for the
 			; above table


sintab2:		; Don't know what this does......??

 dc.b $2D,$31,$34,$38,$3B,$3E,$41,$45,$47,$4A,$4D,$4F,$51,$53,$55,$57
 dc.b $58,$59,$59,$5A,$5A,$5A,$59,$59,$58,$57,$55,$53,$51,$4F,$4D,$4A
 dc.b $47,$45,$41,$3E,$3B,$38,$34,$31,$2D,$29,$26,$22,$1F,$1C,$19,$15
 dc.b $13,$10,$D,$B,$9,$7,$5,$3,$2,$1,$1,$0,$0,$0,$1,$1,$2,$3,$5,$7,$9
 dc.b $B,$D,$10,$13,$15,$19,$1C,$1F,$22,$26,$29,$ff

pause: 	dc.b 0
sinmodulo:
	dc.b 0

 	even
mfc:
	move.b #4,countdown
	clr.w scplane2+40
	clr.w scplane2+82
	move.l #scplane2+124,a1
	bsr CHARADDRESS

	moveq #15,d0
zonkin:
	move.w (a0),(a1)
	lea 40(a0),a0
	lea 42(a1),a1
	dbf d0,zonkin

	rts
CHARADDRESS:
	move.l mesptr,a0
	moveq #0,d0
	move.l d0,d1
	move.l d0,d2
	move.b (a0)+,d0
	cmp.b #$0a,d0
	bne wizy
	move.b #32,d0
wizy:
	cmp.b #120,d0		; Is it an 'x'?
	bne wazy		; No, then continue
	move.l #message,a0	; Restart the scroll
	move.b #32,d0		; Put a space in first...
wazy:
	cmp.b #97,d0		; Is it an 'a'?
	bne wozy		; No, then continue
	move.b #32,d0
	move.b #$60,pause	; Set the countdown to $60...
wozy:
	move.l a0,mesptr

	sub.b #32,d0 
 	moveq #0,d1
 	divu #20,d0  		; 20 chars on each line
 	move.b d0,d1 
 	clr.w d0
 	swap d0  
	move.l #fnt2,a0
	mulu #640,d1
	add.l d0,d0
	add.l d0,a0
	add.l d1,a0

	rts


 even
 
 
SPRITE0 DC.W 0,0,0,0,0,0
mesptr: dc.l message
message:
      
      ;12345678901234567890
      ; Lowercase 'a' to pause
      ; Lowercase 'x' to finish.....
       
 DC.B	"  SO WHAT IS IT NOW?        IT'S AN INTRO!  a"
 DC.B	"   RIGHT MOUSE TO PAUSE......   "
 DC.B	"I ACTUALLY HAD FUN WITH THIS ONE!   THE NICE MODULE IS "
 DC.B	"FROM A REBELS DEMO, THE 3D ROUTINE IS BY KREATOR/ANARCHY, "
 DC.B	"WHO SHOULD BE TAKING HIS FINAL EXAMS NOW.  GOOD LUCK MICHAEL!   "
 DC.B	"OH WELL, THAT'S ABOUT IT,  STAY COOL, HAVE FUN, UNITY IN '91....."
 
 DC.B 	"               x"
 

	
	even
scrollplane: 	ds.b 8000
scplane2: 	ds.b 2500
fnt2: 		incbin source:Fonts/16font3




*** END OF MY CODE ***

*	Future Composer Replay Routine. V1.0 - 1.3

*	Improved by hand from crappy Seka version

*	by Zaphod of Pendle Europa, July 1990

  
*  Jsr Init_Music  at start
*  Jsr Play_Music  in IRQ
*  Jsr End_Music   at end



Play_Music
        bra.w Play

End_Music
        clr.w onoff
        clr.l $dff0a6
        clr.l $dff0b6
        clr.l $dff0c6
        clr.l $dff0d6
        move.w #$000f,$dff096
        bclr #1,$bfe001
        rts

Init_Music
        move.w #1,onoff
        bset #1,$bfe001
        lea Module,a0
        lea 100(a0),a1
        move.l a1,SEQpoint
        move.l a0,a1
        add.l 8(a0),a1
        move.l a1,PATpoint
        move.l a0,a1
        add.l 16(a0),a1
        move.l a1,FRQpoint
        move.l a0,a1
        add.l 24(a0),a1
        move.l a1,VOLpoint
        move.l 4(a0),d0
        divu #13,d0

        lea 40(a0),a1
        lea Sound_Info+4(pc),a2
        moveq #10-1,d1
initloop:
        move.w (a1)+,(a2)+
        move.l (a1)+,(a2)+
        addq.w #4,a2
        dbf d1,initloop
        moveq #0,d2
        move.l a0,d1
        add.l 32(a0),d1
        sub.l #WaveForms,d1
        lea Sound_Info(pc),a0
        move.l d1,(a0)+
        moveq #9-1,d3
initloop1:
        move.w (a0),d2
        add.l d2,d1
        add.l d2,d1
        addq.w #6,a0
        move.l d1,(a0)+
        dbf d3,initloop1

        move.l SEQpoint(pc),a0
        moveq #0,d2
        move.b 12(a0),d2		;Get rePlay speed
        bne.s speedok
        move.b #3,d2			;Set default speed
speedok:
        move.w d2,respcnt		;Init repspeed counter
        move.w d2,repspd
INIT2:
        clr.w audtemp
        move.w #$000f,$dff096		;Disable audio DMA
        move.w #$0780,$dff09a		;Disable audio IRQ
        moveq #0,d7
        mulu #13,d0
        moveq #4-1,d6			;Number of soundchannels-1
        lea V1data(pc),a0		;Point to 1st voice data area
        lea Silent(pc),a1
        lea o4a0c8(pc),a2
initloop2:
        move.l a1,10(a0)
        move.l a1,18(a0)
        clr.l 14(a0)
        clr.b 45(a0)
        clr.b 47(a0)
        clr.w 8(a0)
        clr.l 48(a0)
        move.b #$01,23(a0)
        move.b #$01,24(a0)
        clr.b 25(a0)
        clr.l 26(a0)
        clr.w 30(a0)
        moveq #$00,d3
        move.w (a2)+,d1
        move.w (a2)+,d3
        divu #$0003,d3
        move.b d3,32(a0)
        mulu #$0003,d3
        andi.l #$00ff,d3
        andi.l #$00ff,d1
        addi.l #$dff0a0,d1
        move.l d1,a6
        move.l #$0000,(a6)
        move.w #$0100,4(a6)
        move.w #$0000,6(a6)
        move.w #$0000,8(a6)
        move.l d1,60(a0)
        clr.w 64(a0)
        move.l SEQpoint(pc),(a0)
        move.l SEQpoint(pc),52(a0)
        add.l d0,52(a0)
        add.l d3,52(a0)
        add.l d7,(a0)
        add.l d3,(a0)
        move.w #$000d,6(a0)
        move.l (a0),a3
        move.b (a3),d1
        andi.l #$00ff,d1
        lsl.w #6,d1
        move.l PATpoint(pc),a4
        adda.w d1,a4
        move.l a4,34(a0)
        clr.l 38(a0)
        move.b #$01,33(a0)
        move.b #$02,42(a0)
        move.b 1(a3),44(a0)
        move.b 2(a3),22(a0)
        clr.b 43(a0)
        clr.b 45(a0)
        clr.w 56(a0)
        adda.w #$004a,a0	;Point to next voice's data area
        dbf d6,initloop2
        rts


Play:
        lea pervol(pc),a6
        tst.w onoff
        bne.s music_on
        rts
music_on:
        subq.w #1,respcnt		;Decrease rePlayspeed counter
        bne.s nonewnote
        move.w repspd(pc),respcnt	;Restore rePlayspeed counter
        lea V1data(pc),a0		;Point to voice1 data area
        bsr.w New_Note
        lea V2data(pc),a0		;Point to voice2 data area
        bsr.w New_Note
        lea V3data(pc),a0		;Point to voice3 data area
        bsr.w New_Note
        lea V4data(pc),a0		;Point to voice4 data area
        bsr.w New_Note
nonewnote:
        clr.w audtemp
        lea V1data(pc),a0
        bsr.w Effects
        move.w d0,(a6)+
        move.w d1,(a6)+
        lea V2data(pc),a0
        bsr.w Effects
        move.w d0,(a6)+
        move.w d1,(a6)+
        lea V3data(pc),a0
        bsr.w Effects
        move.w d0,(a6)+
        move.w d1,(a6)+
        lea V4data(pc),a0
        bsr.w Effects
        move.w d0,(a6)+
        move.w d1,(a6)+
        lea pervol(pc),a6
        move.w audtemp(pc),d0
	ori.w #$8000,d0			;Set/        clr bit = 1
        move.w d0,-(a7)
        moveq #0,d1
        move.l start1(pc),d2		;Get samplepointers
        move.w offset1(pc),d1		;Get offset
        add.l d1,d2			;        add offset
        move.l start2(pc),d3
        move.w offset2(pc),d1
        add.l d1,d3
        move.l start3(pc),d4
        move.w offset3(pc),d1
        add.l d1,d4
        move.l start4(pc),d5
        move.w offset4(pc),d1
        add.l d1,d5
        move.w ssize1(pc),d0		;Get sound lengths
        move.w ssize2(pc),d1
        move.w ssize3(pc),d6
        move.w ssize4(pc),d7
        move.w (a7)+,$dff096		;Enable audio DMA
chan1:
        lea V1data(pc),a0
        tst.w 72(a0)
        beq.w chan2
        subq.w #1,72(a0)
        cmpi.w #1,72(a0)
        bne.s chan2
        clr.w 72(a0)
        move.l d2,$dff0a0		;Set soundstart
        move.w d0,$dff0a4		;Set soundlength
chan2:
        lea V2data(pc),a0
        tst.w 72(a0)
        beq.s chan3
        subq.w #1,72(a0)
        cmpi.w #1,72(a0)
        bne.s chan3
        clr.w 72(a0)
        move.l d3,$dff0b0
        move.w d1,$dff0b4
chan3:
        lea V3data(pc),a0
        tst.w 72(a0)
        beq.s chan4
        subq.w #1,72(a0)
        cmpi.w #1,72(a0)
        bne.s chan4
        clr.w 72(a0)
        move.l d4,$dff0c0
        move.w d6,$dff0c4
chan4:
        lea V4data(pc),a0
        tst.w 72(a0)
        beq.s setpervol
        subq.w #1,72(a0)
        cmpi.w #1,72(a0)
        bne.s setpervol
        clr.w 72(a0)
        move.l d5,$dff0d0
        move.w d7,$dff0d4
setpervol:
        lea $dff0a6,a5
        move.w (a6)+,(a5)	;Set period
        move.w (a6)+,2(a5)	;Set volume
        move.w (a6)+,16(a5)
        move.w (a6)+,18(a5)
        move.w (a6)+,32(a5)
        move.w (a6)+,34(a5)
        move.w (a6)+,48(a5)
        move.w (a6)+,50(a5)
        rts

New_Note:
        moveq #0,d5
        move.l 34(a0),a1
        adda.w 40(a0),a1
        cmp.w #64,40(a0)
        bne.w samepat
        move.l (a0),a2
        adda.w 6(a0),a2		;Point to next sequence row
        cmpa.l 52(a0),a2	;Is it the end?
        bne.s notend
        move.w d5,6(a0)		;yes!
        move.l (a0),a2		;Point to first sequence
notend:
        moveq #0,d1
        addq.b #1,spdtemp
        cmpi.b #4,spdtemp
        bne.s nonewspd
        move.b d5,spdtemp
        move.b -1(a1),d1	;Get new rePlay speed
        beq.s nonewspd
        move.w d1,respcnt	;store in counter
        move.w d1,repspd
nonewspd:
        move.b (a2),d1		;Pattern to Play
        move.b 1(a2),44(a0)	;Transpose value
        move.b 2(a2),22(a0)	;Soundtranspose value

        move.w d5,40(a0)
        lsl.w #6,d1
        add.l PATpoint(pc),d1	;Get pattern pointer
        move.l d1,34(a0)
        addi.w #$000d,6(a0)
        move.l d1,a1
samepat:
        move.b 1(a1),d1		;Get info byte
        move.b (a1)+,d0		;Get note
        bne.s ww1
        andi.w #%11000000,d1
        beq.s noport
        bra.s ww11
ww1:
        move.w d5,56(a0)
ww11:
        move.b d5,47(a0)
        move.b (a1),31(a0)

		;31(a0) = PORTAMENTO/INSTR. info
			;Bit 7 = portamento on
			;Bit 6 = portamento off
			;Bit 5-0 = instrument number
		;47(a0) = portamento value
			;Bit 7-5 = always zero
			;Bit 4 = up/down
			;Bit 3-0 = value
t_porton:
        btst #7,d1
        beq.s noport
        move.b 2(a1),47(a0)	
noport:
        andi.w #$007f,d0
        beq.w nextnote
        move.b d0,8(a0)
        move.b (a1),9(a0)
        move.b 32(a0),d2
        moveq #0,d3
        bset d2,d3
	or.w d3,audtemp
        move.w d3,$dff096
        move.b (a1),d1
        andi.w #$003f,d1	;Max 64 instruments
        add.b 22(a0),d1
        move.l VOLpoint(pc),a2
        lsl.w #6,d1
        adda.w d1,a2
        move.w d5,16(a0)
        move.b (a2),23(a0)
        move.b (a2)+,24(a0)
        move.b (a2)+,d1
        andi.w #$00ff,d1
        move.b (a2)+,27(a0)
        move.b #$40,46(a0)
        move.b (a2)+,d0
        move.b d0,28(a0)
        move.b d0,29(a0)
        move.b (a2)+,30(a0)
        move.l a2,10(a0)
        move.l FRQpoint(pc),a2
        lsl.w #6,d1
        adda.w d1,a2
        move.l a2,18(a0)
        move.w d5,50(a0)
        move.b d5,26(a0)
        move.b d5,25(a0)
nextnote:
        addq.w #2,40(a0)
        rts

Effects:
        moveq #0,d7
testsustain:
        tst.b 26(a0)		;Is sustain counter = 0
        beq.s sustzero
        subq.b #1,26(a0)	;if no, decrease counter
        bra.w VOLUfx
sustzero:		;Next part of effect sequence
        move.l 18(a0),a1	;can be executed now.
        adda.w 50(a0),a1
testEffects:
        cmpi.b #$e1,(a1)	;E1 = end of FREQseq sequence
        beq.w VOLUfx
        cmpi.b #$e0,(a1)	;E0 = loop to other part of sequence
        bne.s testnewsound
        move.b 1(a1),d0		;loop to start of sequence + 1(a1)
        andi.w #$003f,d0
        move.w d0,50(a0)
        move.l 18(a0),a1
        adda.w d0,a1
testnewsound:
        cmpi.b #$e2,(a1)	;E2 = set waveform
        bne.s o49c64
        moveq #0,d0
        moveq #0,d1
        move.b 32(a0),d1
        bset d1,d0
	or.w d0,audtemp
        move.w d0,$dff096
        move.b 1(a1),d0
        andi.w #$00ff,d0
        lea Sound_Info(pc),a4
        add.w d0,d0
        move.w d0,d1
        add.w d1,d1
        add.w d1,d1
        add.w d1,d0
        adda.w d0,a4
        move.l 60(a0),a3
        move.l (a4),d1
        add.l #WaveForms,d1
        move.l d1,(a3)
        move.l d1,68(a0)
        move.w 4(a4),4(a3)
        move.l 6(a4),64(a0)
	swap d1
        move.w #$0003,72(a0)
        tst.w d1
        bne.s o49c52
        move.w #$0002,72(a0)
o49c52:
        clr.w 16(a0)
        move.b #$01,23(a0)
        addq.w #2,50(a0)
        bra.w o49d02
o49c64:
        cmpi.b #$e4,(a1)
        bne.s testpatjmp
        move.b 1(a1),d0
        andi.w #$00ff,d0
        lea Sound_Info(pc),a4
        add.w d0,d0
        move.w d0,d1
        add.w d1,d1
        add.w d1,d1
        add.w d1,d0
        adda.w d0,a4
        move.l 60(a0),a3
        move.l (a4),d1
        add.l #WaveForms,d1
        move.l d1,(a3)
        move.l d1,68(a0)
        move.w 4(a4),4(a3)
        move.l 6(a4),64(a0)

	swap d1
        move.w #$0003,72(a0)
        tst.w d1
        bne.s o49cae
        move.w #$0002,72(a0)
o49cae:
        addq.w #2,50(a0)
        bra.s o49d02
testpatjmp:
        cmpi.b #$e7,(a1)
        bne.s testnewsustain
        move.b 1(a1),d0
        andi.w #$00ff,d0
        lsl.w #6,d0
        move.l FRQpoint(pc),a1
        adda.w d0,a1
        move.l a1,18(a0)
        move.w d7,50(a0)
        bra.w testEffects
testnewsustain:
        cmpi.b #$e8,(a1)	;E8 = set sustain time
        bne.s o49cea
        move.b 1(a1),26(a0)
        addq.w #2,50(a0)
        bra.w testsustain
o49cea:
        cmpi.b #$e3,(a1)
        bne.s o49d02
        addq.w #3,50(a0)
        move.b 1(a1),27(a0)
        move.b 2(a1),28(a0)
o49d02:
        move.l 18(a0),a1
        adda.w 50(a0),a1
        move.b (a1),43(a0)
        addq.w #1,50(a0)
VOLUfx:
        tst.b 25(a0)
        beq.s o49d1e
        subq.b #1,25(a0)
        bra.s o49d70
o49d1e:
        subq.b #1,23(a0)
        bne.s o49d70
        move.b 24(a0),23(a0)
o49d2a:
        move.l 10(a0),a1
        adda.w 16(a0),a1
        move.b (a1),d0
        cmpi.b #$e8,d0
        bne.s o49d4a
        addq.w #2,16(a0)
        move.b 1(a1),25(a0)
        bra.s VOLUfx
o49d4a:
        cmpi.b #$e1,d0
        beq.s o49d70
        cmpi.b #$e0,d0
        bne.s o49d68
        move.b 1(a1),d0
        andi.l #$003f,d0
        subq.b #5,d0
        move.w d0,16(a0)
        bra.s o49d2a
o49d68:
        move.b (a1),45(a0)
        addq.w #1,16(a0)
o49d70:
        move.b 43(a0),d0
	bmi.s o49d7e
        add.b 8(a0),d0
        add.b 44(a0),d0
o49d7e:
        andi.w #$007f,d0
        lea PERIODS(pc),a1
        add.w d0,d0
        move.w d0,d1
        adda.w d0,a1
        move.w (a1),d0
        move.b 46(a0),d7
        tst.b 30(a0)
        beq.s o49d9e
        subq.b #1,30(a0)

        bra.s o49df4
o49d9e:
        move.b d1,d5
        move.b 28(a0),d4
        add.b d4,d4
        move.b 29(a0),d1
        tst.b d7
	bpl.s o49db4
        btst #0,d7
        bne.s o49dda
o49db4:
        btst #5,d7
        bne.s o49dc8
        sub.b 27(a0),d1
	bcc.s o49dd6
        bset #5,d7
        moveq #0,d1
        bra.s o49dd6
o49dc8:
        add.b 27(a0),d1
        cmp.b d4,d1
	bcs.s o49dd6
        bclr #5,d7
        move.b d4,d1
o49dd6:
        move.b d1,29(a0)
o49dda:
	lsr.b #1,d4
        sub.b d4,d1
	bcc.s o49de4
        subi.w #$0100,d1
o49de4:
        addi.b #$a0,d5
	bcs.s o49df2
o49dea:
        add.w d1,d1
        addi.b #$18,d5
	bcc.s o49dea
o49df2:
        add.w d1,d0
o49df4:
	eori.b #$01,d7
        move.b d7,46(a0)

; DO THE PORTAMENTO THING
        moveq #0,d1
        move.b 47(a0),d1	;get portavalue
        beq.s a56d0		;0=no portamento
        cmpi.b #$1f,d1
	bls.s portaup
portadown: 
        andi.w #$1f,d1
	neg.w d1
portaup:
        sub.w d1,56(a0)
a56d0:
        add.w 56(a0),d0
o49e3e:
        cmpi.w #$0070,d0
	bhi.s nn1
        move.w #$0071,d0
nn1:
        cmpi.w #$06b0,d0
	bls.s nn2
        move.w #$06b0,d0
nn2:
        moveq #0,d1
        move.b 45(a0),d1
        rts



pervol: dcb.b 16,0	;Periods & Volumes temp. store
respcnt: dc.w 0		;RePlay speed counter 
repspd:  dc.w 0		;RePlay speed counter temp
onoff:   dc.w 0		;Music on/off flag.
firseq:	 dc.w 0		;First sequence
lasseq:	 dc.w 0		;Last sequence
audtemp: dc.w 0
spdtemp: dc.w 0

V1data:  dcb.b 64,0	;Voice 1 data area
offset1: dcb.b 02,0	;Is         added to start of sound
ssize1:  dcb.b 02,0	;Length of sound
start1:  dcb.b 06,0	;Start of sound

V2data:  dcb.b 64,0	;Voice 2 data area
offset2: dcb.b 02,0
ssize2:  dcb.b 02,0
start2:  dcb.b 06,0

V3data:  dcb.b 64,0	;Voice 3 data area
offset3: dcb.b 02,0
ssize3:  dcb.b 02,0
start3:  dcb.b 06,0

V4data:  dcb.b 64,0	;Voice 4 data area
offset4: dcb.b 02,0
ssize4:  dcb.b 02,0
start4:  dcb.b 06,0

o4a0c8: dc.l $00000000,$00100003,$00200006,$00300009
SEQpoint: dc.l 0
PATpoint: dc.l 0
FRQpoint: dc.l 0
VOLpoint: dc.l 0


        even
Silent  dc.w $0100,$0000,$0000,$00e1

PERIODS dc.w $06b0,$0650,$05f4,$05a0,$054c,$0500,$04b8,$0474
	dc.w $0434,$03f8,$03c0,$038a,$0358,$0328,$02fa,$02d0
	dc.w $02a6,$0280,$025c,$023a,$021a,$01fc,$01e0,$01c5
	dc.w $01ac,$0194,$017d,$0168,$0153,$0140,$012e,$011d
	dc.w $010d,$00fe,$00f0,$00e2,$00d6,$00ca,$00be,$00b4
	dc.w $00aa,$00a0,$0097,$008f,$0087,$007f,$0078,$0071
	dc.w $0071,$0071,$0071,$0071,$0071,$0071,$0071,$0071
	dc.w $0071,$0071,$0071,$0071,$0d60,$0ca0,$0be8,$0b40
	dc.w $0a98,$0a00,$0970,$08e8,$0868,$07f0,$0780,$0714
	dc.w $1ac0,$1940,$17d0,$1680,$1530,$1400,$12e0,$11d0
	dc.w $10d0,$0fe0,$0f00,$0e28

Sound_Info:
;Offset.l , Sound-length.w , Start-offset.w , Repeat-length.w 

;Reserved for samples
	dc.w $0000,$0000,$0000,$0000,$0001 
	dc.w $0000,$0000,$0000,$0000,$0001 
	dc.w $0000,$0000,$0000,$0000,$0001 
	dc.w $0000,$0000,$0000,$0000,$0001 
	dc.w $0000,$0000,$0000,$0000,$0001 
	dc.w $0000,$0000,$0000,$0000,$0001 
	dc.w $0000,$0000,$0000,$0000,$0001 
	dc.w $0000,$0000,$0000,$0000,$0001 
	dc.w $0000,$0000,$0000,$0000,$0001 
	dc.w $0000,$0000,$0000,$0000,$0001 
;Reserved for synth sounds
	dc.w $0000,$0000,$0010,$0000,$0010 
	dc.w $0000,$0020,$0010,$0000,$0010 
	dc.w $0000,$0040,$0010,$0000,$0010 
	dc.w $0000,$0060,$0010,$0000,$0010 
	dc.w $0000,$0080,$0010,$0000,$0010 
	dc.w $0000,$00a0,$0010,$0000,$0010 
	dc.w $0000,$00c0,$0010,$0000,$0010 
	dc.w $0000,$00e0,$0010,$0000,$0010 
	dc.w $0000,$0100,$0010,$0000,$0010 
	dc.w $0000,$0120,$0010,$0000,$0010 
	dc.w $0000,$0140,$0010,$0000,$0010 
	dc.w $0000,$0160,$0010,$0000,$0010 
	dc.w $0000,$0180,$0010,$0000,$0010 
	dc.w $0000,$01a0,$0010,$0000,$0010 
	dc.w $0000,$01c0,$0010,$0000,$0010 
	dc.w $0000,$01e0,$0010,$0000,$0010 
	dc.w $0000,$0200,$0010,$0000,$0010 
	dc.w $0000,$0220,$0010,$0000,$0010 
	dc.w $0000,$0240,$0010,$0000,$0010 
	dc.w $0000,$0260,$0010,$0000,$0010 
	dc.w $0000,$0280,$0010,$0000,$0010 
	dc.w $0000,$02a0,$0010,$0000,$0010 
	dc.w $0000,$02c0,$0010,$0000,$0010 
	dc.w $0000,$02e0,$0010,$0000,$0010 
	dc.w $0000,$0300,$0010,$0000,$0010 
	dc.w $0000,$0320,$0010,$0000,$0010 
	dc.w $0000,$0340,$0010,$0000,$0010 
	dc.w $0000,$0360,$0010,$0000,$0010 
	dc.w $0000,$0380,$0010,$0000,$0010 
	dc.w $0000,$03a0,$0010,$0000,$0010 
	dc.w $0000,$03c0,$0010,$0000,$0010 
	dc.w $0000,$03e0,$0010,$0000,$0010 
	dc.w $0000,$0400,$0008,$0000,$0008 
	dc.w $0000,$0410,$0008,$0000,$0008 
	dc.w $0000,$0420,$0008,$0000,$0008 
	dc.w $0000,$0430,$0008,$0000,$0008 
	dc.w $0000,$0440,$0008,$0000,$0008
	dc.w $0000,$0450,$0008,$0000,$0008
	dc.w $0000,$0460,$0008,$0000,$0008
	dc.w $0000,$0470,$0008,$0000,$0008
	dc.w $0000,$0480,$0010,$0000,$0010
	dc.w $0000,$04a0,$0008,$0000,$0008
	dc.w $0000,$04b0,$0010,$0000,$0010
	dc.w $0000,$04d0,$0010,$0000,$0010
	dc.w $0000,$04f0,$0008,$0000,$0008
	dc.w $0000,$0500,$0008,$0000,$0008
	dc.w $0000,$0510,$0018,$0000,$0018
 

WaveForms:
        dc.w $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
        dc.w $3f37,$2f27,$1f17,$0f07,$ff07,$0f17,$1f27,$2f37
        dc.w $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
        dc.w $c037,$2f27,$1f17,$0f07,$ff07,$0f17,$1f27,$2f37
        dc.w $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
        dc.w $c0b8,$2f27,$1f17,$0f07,$ff07,$0f17,$1f27,$2f37
        dc.w $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
        dc.w $c0b8,$b027,$1f17,$0f07,$ff07,$0f17,$1f27,$2f37
        dc.w $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
        dc.w $c0b8,$b0a8,$1f17,$0f07,$ff07,$0f17,$1f27,$2f37
        dc.w $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
        dc.w $c0b8,$b0a8,$a017,$0f07,$ff07,$0f17,$1f27,$2f37
        dc.w $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
        dc.w $c0b8,$b0a8,$a098,$0f07,$ff07,$0f17,$1f27,$2f37
        dc.w $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
        dc.w $c0b8,$b0a8,$a098,$9007,$ff07,$0f17,$1f27,$2f37
        dc.w $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
        dc.w $c0b8,$b0a8,$a098,$9088,$ff07,$0f17,$1f27,$2f37
        dc.w $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
        dc.w $c0b8,$b0a8,$a098,$9088,$8007,$0f17,$1f27,$2f37
        dc.w $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
        dc.w $c0b8,$b0a8,$a098,$9088,$8088,$0f17,$1f27,$2f37
        dc.w $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
        dc.w $c0b8,$b0a8,$a098,$9088,$8088,$9017,$1f27,$2f37
        dc.w $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
        dc.w $c0b8,$b0a8,$a098,$9088,$8088,$9098,$1f27,$2f37
        dc.w $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
        dc.w $c0b8,$b0a8,$a098,$9088,$8088,$9098,$a027,$2f37
        dc.w $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
        dc.w $c0b8,$b0a8,$a098,$9088,$8088,$9098,$a0a8,$2f37
        dc.w $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
        dc.w $c0b8,$b0a8,$a098,$9088,$8088,$9098,$a0a8,$b037
        dc.w $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
        dc.w $7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
        dc.w $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
        dc.w $817f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
        dc.w $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
        dc.w $8181,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
        dc.w $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
        dc.w $8181,$817f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
        dc.w $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
        dc.w $8181,$8181,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
        dc.w $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
        dc.w $8181,$8181,$817f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
        dc.w $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
        dc.w $8181,$8181,$8181,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
        dc.w $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
        dc.w $8181,$8181,$8181,$817f,$7f7f,$7f7f,$7f7f,$7f7f
        dc.w $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
        dc.w $8181,$8181,$8181,$8181,$7f7f,$7f7f,$7f7f,$7f7f
        dc.w $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
        dc.w $8181,$8181,$8181,$8181,$817f,$7f7f,$7f7f,$7f7f
        dc.w $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
        dc.w $8181,$8181,$8181,$8181,$8181,$7f7f,$7f7f,$7f7f
        dc.w $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
        dc.w $8181,$8181,$8181,$8181,$8181,$817f,$7f7f,$7f7f
        dc.w $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
        dc.w $8181,$8181,$8181,$8181,$8181,$8181,$7f7f,$7f7f
        dc.w $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
        dc.w $8181,$8181,$8181,$8181,$8181,$8181,$817f,$7f7f
        dc.w $8080,$8080,$8080,$8080,$8080,$8080,$8080,$8080
        dc.w $8080,$8080,$8080,$8080,$8080,$8080,$8080,$7f7f
        dc.w $8080,$8080,$8080,$8080,$8080,$8080,$8080,$8080
        dc.w $8080,$8080,$8080,$8080,$8080,$8080,$8080,$807f
        dc.w $8080,$8080,$8080,$8080,$7f7f,$7f7f,$7f7f,$7f7f
        dc.w $8080,$8080,$8080,$807f,$7f7f,$7f7f,$7f7f,$7f7f
        dc.w $8080,$8080,$8080,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
        dc.w $8080,$8080,$807f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
        dc.w $8080,$8080,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
        dc.w $8080,$807f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
        dc.w $8080,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
        dc.w $8080,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
        dc.w $8080,$9098,$a0a8,$b0b8,$c0c8,$d0d8,$e0e8,$f0f8
        dc.w $0008,$1018,$2028,$3038,$4048,$5058,$6068,$707f
        dc.w $8080,$a0b0,$c0d0,$e0f0,$0010,$2030,$4050,$6070
        dc.w $4545,$797d,$7a77,$7066,$6158,$534d,$2c20,$1812
        dc.w $04db,$d3cd,$c6bc,$b5ae,$a8a3,$9d99,$938e,$8b8a
        dc.w $4545,$797d,$7a77,$7066,$5b4b,$4337,$2c20,$1812
        dc.w $04f8,$e8db,$cfc6,$beb0,$a8a4,$9e9a,$9594,$8d83
        dc.w $0000,$4060,$7f60,$4020,$00e0,$c0a0,$80a0,$c0e0
        dc.w $0000,$4060,$7f60,$4020,$00e0,$c0a0,$80a0,$c0e0
        dc.w $8080,$9098,$a0a8,$b0b8,$c0c8,$d0d8,$e0e8,$f0f8
        dc.w $0008,$1018,$2028,$3038,$4048,$5058,$6068,$707f
        dc.w $8080,$a0b0,$c0d0,$e0f0,$0010,$2030,$4050,$6070

Module	incbin	source:Modules/rebels


	
Hsinedata:	
	

*	Medium size sine list (100 entries)
	
	dc.w	$f0,$f0,$f0,$f0,$f0,$f0,$e0,$e0
	dc.w	$e0,$e0,$e0,$d0,$d0,$d0,$c0,$c0
	dc.w	$c0,$b0,$b0,$a0,$a0,$90,$90,$80
	dc.w	$80,$70,$70,$70,$60,$60,$50,$50
	dc.w	$40,$40,$30,$30,$30,$20,$20,$20
	dc.w	$10,$10,$10,$10,$10,$00,$00,$00
	dc.w	$00,$00,$00,$00,$00,$00,$00,$00
	
	dc.w	$10,$10,$10,$10,$10,$20,$20,$20
	dc.w	$30,$30,$30,$40,$40,$50,$50,$60
	dc.w	$60,$70,$70,$80,$80,$80,$90,$90
	dc.w	$a0,$a0,$b0,$b0,$c0,$c0,$c0,$d0
	dc.w	$d0,$d0,$e0,$e0,$e0,$e0,$e0,$f0
	dc.w	$f0,$f0,$f0,$f0
	
	dc.w	$01	(end of table)	
	

