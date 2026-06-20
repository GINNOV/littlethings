; mc0702.s						; scrolltext with changing colors
; from disk1/brev07
; explanation on letter_07.pdf / p. 8
; from Mark Wrobel course letter 21			

; SEKA>ks	; (optional)
; Sure? y
; SEKA>r
; FILENAME>mc0701.s
; SEKA>a
; OPTIONS>
; No errors
; SEKA>ri
; FILENAME>font
; BEGIN>font
; END>
; SEKA>j	

start:
		move.w	#$4000,$dff09a		; 9a	INTENA		
							
	or.b	#%10000000,$bfd100					
	and.b	#%10000111,$bfd100					
					
	move.w	#$01a0,$dff096		; 96	DMACON
					
	move.w	#$1200,$dff100		; 100	BPLCON0
	move.w	#0,$dff102			; 102	BPLCON1
	move.w	#0,$dff104			; 104	BPLCON2
	move.w	#2,$dff108			; 108	BPL1MOD
	move.w	#2,$dff10a			; 10a	BPL2MOD
	move.w	#$2c71,$dff08e		; 8e	DIWSTRT
	move.w	#$f4d1,$dff090		; 90	DIWSTOP
	move.w	#$38d1,$dff090		; 90	DIWSTOP
	move.w	#$0030,$dff092		; 92	DDFSTRT
	move.w	#$00d8,$dff094		; 94	DDFSOP
					
	lea.l	screen,a1			
	lea.l	bplcop,a2			
	move.l	a1,d1			
	swap	d1			
	move.w	d1,2(a2)			
	swap	d1			
	move.w	d1,6(a2)			
					
	lea.l	copper,a1			
	move.l	a1,$dff080			; 80	COP1LCH
	move.w	#$8180,$dff096		; 96	DMACON
					
mainloop:					
	move.l	$dff004,d0			; 04	VPOSR
	asr.l	#8,d0			
	and.l	#$1ff,d0			
	cmp.w	#300,d0			
	bne	mainloop			
							
	bsr	scroll					
							
	bsr	cycle					; Line 40: This instruction is added to the main routine to update color-cycling
							
	btst	#6,$bfe001			; CIA		
	bne	mainloop					
							
	move.w	#$0080,$dff096		; 96	DMACON		
							
	move.l	$04,a6					
	move.l	156(a6),a1					
	move.l	38(a1),$dff080		; 80	COP1LCH		
							
	move.w	#$80a0,$dff096		; 96	DMACON		
							
	move.w	#$c000,$dff09a		; 9a	INTENA
	rts				
					
scrollcnt:					
	dc.w	$0000			
					
	charcnt:				
	dc.w	$0000			
					
scroll:					
	lea.l	scrollcnt,a1			
	cmp.w	#8,(a1)			
	bne	nochar			
					
	clr.w	(a1)			
					
	lea.l	charcnt,a1					
	move.w	(a1),d1					
	addq.w	#1,(a1)					
							
	lea.l	text,a2					
	clr.l	d2					
	move.b	(a2,d1.w),d2					
							
	cmp.b	#42,d2					
	bne	notend					
							
	clr.w	(a1)					
	move.b	#32,d2					 
							
notend:							
	lea.l	convtab,a1					
	move.b	(a1,d2.b),d2
	asl.w	#1,d2
		
	lea.l	font,a1
	add.l	d2,a1
		
	lea.l	screen,a2
	add.l	#6944,a2
		
	moveq	#19,d0
		
putcharloop:		
	move.w	(a1),(a2)
	add.l	#64,a1
	add.l	#46,a2
	dbra	d0,putcharloop
					
	nochar:				
	btst	#6,$dff002			; 02	DMACONR
	bne	nochar			
					
	lea.l	screen,a1			
	add.l	#7820,a1			
					
	move.l	a1,$dff050			; 50	BLTAPTH
	move.l	a1,$dff054			; 54	BLTDPTH
	move.w	#0,$dff064			; 64	BLTAMOD
	move.w	#0,$dff066			; 66	BLTDMOD
	move.l	#$ffffffff,$dff044	; 44	BLTAFWM
	move.w	#$29f0,$dff040		; 40	BLTCON0
	move.w	#$0002,$dff042		; 42	BLTCON1
	move.w	#$0523,$dff058		; 58	BLTSIZE
							
	lea.l	scrollcnt,a1					
	addq.w	#1,(a1)					
							
	rts						
							
cyclecnt:							
	dc.w	$0000				;			Line 124: Here we have declared a word which holds the number of cycles for the cycle-
								;			 routine
cycle:							;			Line 126: Here begins the cycle routine
	lea.l	cyclecnt,a1			;			Line 127: Loads the effective address of "cyclecnt" to A1
	move.w	(a1),d1				;			Line 128: Moves the value of "cyclecnt", A1 points to, to D1
								;			
	addq.w	#2,(a1)				;			Line 130: Adds value to 2 to the value of "cyclecnt", A1 points to
								;			
	cmp.w	#96,d1				;			Line 132: Compares D1 with the value 96
	bne	notround				;			Line 133: If D1 is NOT EQUAL to 96, then BRANCH to the label "notround"
								;			
	clr.w	(a1)				;			Line 135: Clears "cyclecnt" (sets it to 0)
	clr.w	d1					;			Line 136: Clears D1 (sets it to 0)
								;			
notround:						;			
	lea.l	cycletable,a2		;			Line 139: Load the effective address of the "cycle table" into A1. The "cycletable" is the
								;			 table of colors which are to be rolled in text.
	lea.l	cyclecop,a3			;			Line 140: Loads the effective address of "cyclecop" into A3. This is the beginning of the
								;			 copper-instructions which change the contents of the color register. Read
								;			 copper-list. (line 153-208) to understand how the following lines of code work
	moveq	#19,d0				;			Line 142: Moves the constant value of 19 quickly into D0, which serves as a counter for
								;			 the number of color lines which has to be changed.
cycleloop:						;			Line 144: Here begins the loop which copied the color data into the copper-list.
	move.w	(a2,d1.w),6(a3)		;			Line 145: Move the value where the address of A1 + D1 points to, to the address
								;			 A3 +6 points to. Study the color table ("cycletable") and the copper-list
								;			 carefully and try to understand how the values are fetched and stored to the
								;			 copper list
	addq.w	#2,d1				;			Line 146: Adds 2 to D1 quickly. Next time the program executes the line 145, it will start
								;			 with the next color from the color table. We add the value of 2 since each color
								;			 in the table is defined as a word (2 bytes)
	addq.l	#8,a3				;			Line 147: Adds 8 to A3. A3 will now point to the next space in the copper-list where the
								;			 next color must be inserted.
	dbra	d0,cycleloop		;			Line 148: Decrement D0 by 1, checks if -1 and if not, branch back to the "cycleloop".
								;			 Note that this loop (line 145-148) is performed 20 times.
	rts							;			Line 150: Branched back to the calling instance – here the main routine
							
copper:							
	dc.w	$2c01,$fffe					
	dc.w	$0100,$1200					
							
bplcop:							
	dc.w	$00e0,$0000
	dc.w	$00e2,$0000
		
	dc.w	$0180,$0000
	dc.w	$0182,$0ff0
		
cyclecop:		
	dc.w	$c201,$fffe
	dc.w	$0182,$0000
	dc.w	$c301,$fffe
	dc.w	$0182,$0000
	dc.w	$c401,$fffe
	dc.w	$0182,$0000
	dc.w	$c501,$fffe
	dc.w	$0182,$0000
	dc.w	$c601,$fffe
	dc.w	$0182,$0000
	dc.w	$c701,$fffe
	dc.w	$0182,$0000
	dc.w	$c801,$fffe
	dc.w	$0182,$0000
	dc.w	$c901,$fffe
	dc.w	$0182,$0000
	dc.w	$ca01,$fffe
	dc.w	$0182,$0000
	dc.w	$cb01,$fffe
	dc.w	$0182,$0000
	dc.w	$cc01,$fffe
	dc.w	$0182,$0000
	dc.w	$cd01,$fffe
	dc.w	$0182,$0000
	dc.w	$ce01,$fffe
	dc.w	$0182,$0000					
	dc.w	$cf01,$fffe					
	dc.w	$0182,$0000					
	dc.w	$d001,$fffe					
	dc.w	$0182,$0000					
	dc.w	$d101,$fffe					
	dc.w	$0182,$0000					
	dc.w	$d201,$fffe					
	dc.w	$0182,$0000					
	dc.w	$d301,$fffe					
	dc.w	$0182,$0000					
	dc.w	$d401,$fffe					
	dc.w	$0182,$0000					
	dc.w	$d501,$fffe					
	dc.w	$0182,$0000					
								;			Line 203: Here is the definition of the copper-instructions which makes the color-scroll
	dc.w	$ffdf,$fffe			;			 possible. These copper-instructions can be explained as follows:
	dc.w	$2c01,$fffe			;			 - Wait until the electron beam has reached Line $C2 (194)
	dc.w	$0100,$0200			;			 - Move color "xxx" (what color at this moment since we change it all the time)
	dc.w	$ffff,$fffe			;			 into COLOR01 register ($ DFF182). This is our text color therefore it is
								;			visible wherever a character of the text is on the screen.
screen:							;			 - Wait until the electron beam reached line $C3 (195) ... and so on and so forth.
	blk.l	$b80,0				;			 This is repeated 20 times in copper-list and results in 2 different colored lines
								;			 on the screen.
	font:						
	blk.l	$140,0					
	;INCBIN "font"						
convtab:							
	dc.b	$00					
	dc.b	$00					
	dc.b	$00					
	dc.b	$00					
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$1f ;" "
	dc.b	$00
	dc.b	$00
	dc.b	$1b ;Ø
	dc.b	$1c ;Å
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$1d ;,
	dc.b	$00 ;-
	dc.b	$1e ;.
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$1a ;Æ
	dc.b	$00 ;A
	dc.b	$01 ;B
	dc.b	$02 ;C
	dc.b	$03 ;...
	dc.b	$04
	dc.b	$05
	dc.b	$06
	dc.b	$07
	dc.b	$08
	dc.b	$09
	dc.b	$0a
	dc.b	$0b
	dc.b	$0c
	dc.b	$0d
	dc.b	$0e
	dc.b	$0f
	dc.b	$10
	dc.b	$11
	dc.b	$12
	dc.b	$13					
	dc.b	$14					
	dc.b	$15					
	dc.b	$16 ;....					
	dc.b	$17 ;X					
	dc.b	$18 ;Y					
	dc.b	$19 ;Z					
	dc.b	$00					
	dc.b	$00					
	dc.b	$00					
							
cycletable:						; Line 313-322: Here the color table is declared.
	dc.w	$0f00,$0e01,$0d02,$0c03,$0b04,$0a05,$0906,$0807					
	dc.w	$0708,$0609,$050a,$040b,$030c,$020d,$010e,$000f					
	dc.w	$000f,$011e,$022d,$033c,$044b,$055a,$0669,$0778					
	dc.w	$0887,$0996,$0aa5,$0bb4,$0cc3,$0dd2,$0ee1,$0ff0					
	dc.w	$0ff0,$0fe0,$0fd0,$0fc0,$0fb0,$0fa0,$0f90,$0f80
	dc.w	$0f70,$0f60,$0f50,$0f40,$0f30,$0f20,$0f10,$0f00
		
	dc.w	$0f00,$0e01,$0d02,$0c03,$0b04,$0a05,$0906,$0807
	dc.w	$0708,$0609,$050a,$040b,$030c,$020d,$010e,$000f
	dc.w	$000f,$011e,$022d,$033c
		
text:		
	dc.b	"DETTE ER EN TEST AV EN SCROLL MED"
	dc.b	" COLORCYCLING P$ AMIGA....    *"

	end

	