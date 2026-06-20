; mc0602.s 				; blitter cookie-cut (by mouse movement)
; from disk1/brev06
; explanation on letter_06.pdf / p.16
; from Mark Wrobel course letter 19		

; SEKA>ks	; (optional)
; Sure? y
; SEKA>r
; FILENAME>mc0602
; SEKA>a
; OPTIONS>
; No errors
; SEKA>ri
; FILENAME>screen_brev6
; BEGIN>screen
; END>
; SEKA>ri
; FILENAME>fig
; BEGIN>fig
; END>
; SEKA>ri
; FILENAME>mask
; BEGIN>mask
; END>
; SEKA>j

start:							; comments from Mark Wrobel
	move.w	#$4000,$dff09a		; INTENA clr master interrupt

	;----Stop disk drives
	or.b	#%10000000,$bfd100	; set CIABPRB MTR
	and.b	#%10000111,$bfd100	; clr CIABPRB SEL3, SEL2, SEL1, SEL0

	move.w	#$01a0,$dff096		; DMACON clear bitplane, copper, blitter

	;-----Setup bitplanes, display and DMA data fetch---
	;-----Resolution 320*256 with 5 bitplanes
	move.w	#$5200,$dff100		; BPLCON0 use 5 bitplanes (32 colors)
	move.w	#$0000,$dff102		; BPLCON1 scroll
	move.w	#$0000,$dff104		; BPLCON2 video
	move.w	#0,$dff108			; BPL1MOD modulus odd planes
	move.w	#0,$dff10a			; BPL2MOD modulus even planes
	move.w	#$2c81,$dff08e		; DIWSTRT upper left corner ($81,$2c)
	;move.w	#$f4c1,$dff090		; DIWSTOP enaple PAL trick
	move.w	#$38c1,$dff090		; DIWSTOP lower right corner ($1c1,$12c)
	move.w	#$0038,$dff092		; DDFSTRT data fetch start at $38
	move.w	#$00d0,$dff094		; DDFSTOP data fetch stop at $d0

	;-----Transfer colors from screen to the color table registers
	lea.l	screen,a1			; write screen address into a1
	move.l	#$dff180,a2			; move address of COLOR00 into a2
	moveq	#31,d0				; set color counter to 31
		
colorloop:
	move.w	(a1)+,(a2)+			; move color from screen to color table
	dbra	d0,colorloop		; if not -1 then go to colorloop

	;-----Set bitplane pointers in bplcop---
	lea.l	bplcop,a2			; write bplcop address into a2
	addq.l	#2,a2				; add two bytes so a2 can set BPL1PTH
	move.l	a1,d1				; move a1 (points to screen data) into d1
	moveq	#4,d0				; set bitplane counter to 4

bplcoploop:
	swap	d1					; perform swap of words 
	move.w	d1,(a2)				; move bit 0-15 into what a2 points to (sets BPLxPTH)
	addq.l	#4,a2				; make a2 point to indput for PBLxPTL    
	swap	d1					; perform swap of words
	move.w	d1,(a2)				; move bit 0-15 into what a2 points to (sets BPLxPTL)
	addq.l	#4,a2				; make a2 point to the next BPLxPTH input
	add.l	#10240,d1			; make d1 point to next bitplane
	dbra	d0,bplcoploop		; decrement d0. if > -1 goto bplcoploop

	;-----Start copper---
	lea.l	copper,a1			; put address of copper into a1
	move.l	a1,$dff080			; set COP1LCH and COP1LCL to address in a1
	move.w	$dff088,d0			; start copper by read of strobe address COPJMP1

	move.w	#$8580,$dff096		; DMACON set BLTPRI, PBLEN, COPEN

	bsr	readmouse				; read mouse coordinates to determine blit area
	bsr	storeback				; store background to blit in backbuffer

mainloop:
	move.l	$dff004,d0			; read VPOSR and VHPOSR into d0 as one long word
	asr.l	#8,d0				; shift right 8 poositions
	and.l	#$1ff,d0			; and for immediate data
	cmp.w	#300,d0
	bne	mainloop				; if not at line 300 goto mainloop

	bsr	recallback				; recall blitted background from backbuffer
	bsr	readmouse				; read mouse coordinates to determine blit area
	bsr	storeback				; store background to blit in backbuffer
	bsr	shiftblit				; blit pixelwise horisontal
	bsr	blitin					; do the actual blit using cookie-cut

	btst	#6,$bfe001			; CIAAPRA FIR0 check mouse button
	bne	mainloop				; if not pressed goto mainloop

	move.w	#$0080,$dff096		; DMACON clear copper

	move.l	$4,a6				; reestablish DMA's and copper
	move.l	156(a6),a6
	move.l	38(a6),$dff080

	move.w	#$80a0,$dff096
	move.w	#$0400,$dff096

	move.w	#$c000,$dff09a
	rts							; return from mainloop

	;-----blitin is blitting in the data from A, B, and C into D 
	;-----using the cookie-cut logic function
blitin:
	lea.l	maskbuffer,a1		; store maskbuffer address in a1
	lea.l	backbuffer,a3		; store backbuffer address in a3
	lea.l	figbuffer,a2		; store figbuffer address in a2
	lea.l	screen,a4			; store screen in a4
	add.l	#64,a4				; skip first 64 bytes of color data

	lea.l	mousex,a0			; store mousex address in a0
	move.l	(a0),d0				; move mousex value into d0
	lea.l	mousey,a0			; store mousey address in a0
	move.l	(a0),d1				; move mousey value into d1

	;-----find first blit position
	lsr.l	#4,d0				; mouse x shift right 4 bits  
	lsl.l	#1,d0				; mouse x shift left 1 bit
	mulu	#40,d1				; unsigned multiply to mousey (40 bytes is width of screen)
	add.l	d0,a4				; add mousex to screen address in a1
	add.l	d1,a4				; add mousey to a1

	moveq	#4,d7				; initialize loop counter (5 bitplanes)
		
blitinloop:
	btst	#6,$dff002          ; wait for blitter
	bne	blitinloop

	move.l	a4,$dff054			; BLTDPTH and BLTDPTL points to screen
	move.l	a1,$dff050          ; BLTAPTH and BLTAPTL points to maskbuffer
	move.l	a2,$dff04c          ; BLTBTPH and BLTBPTL points to figbuffer
	move.l	a3,$dff048          ; BLTCPTH and BLTAPTL points to backbuffer
	move.w	#32,$dff066         ; BLTDMOD set modulus to 32 bytes on D 40-(64/8)
	move.w	#0,$dff064          ; BLTAMOD set modulus to 0 bytes on A
	move.w	#0,$dff062          ; BLTBMOD set modulus to 0 bytes on B
	move.w	#0,$dff060          ; BLTCMOD set modulus to 0 bytes on C
	move.l	#$ffffffff,$dff044  ; set BLTAFWM first word mask for A
	move.w	#$0fca,$dff040      ; BLITCON0 use A,B,C, and D, with cookie-cut
	move.w	#$0000,$dff042      ; BLITCON1
	move.w	#$0b44,$dff058      ; set BLTSIZE height 45 lines, width 4 words (64 pixels)

	add.l	#360,a2             ; point to next bitpane in figbuffer
	add.l	#360,a3             ; point to next bitplane in backbuffer
	add.l	#10240,a4           ; point to next bitplane in screen

	dbra	d7,blitinloop       ; if d7 > -1 goto blitinloop
	rts                         ; return from blitin

	;----shiftblit enables us to blit 
	;----pixelwise instead of wordwise horizontal
shiftblit:
	lea.l	fig,a1				; put fig address into a1
	lea.l	figbuffer,a2		; put figbuffer address into a2

	lea.l	mousex,a0			; put mousex address into a0
	move.l	(a0),d1				; put mousex value into d1

	;-----preparing a value for BLTCON0 by first setting up
	;-----the shift value (byte 12-15) and then use A and D
	;-----with the logic function D=A
	andi.l	#$f,d1				; clear all but first byte of mousex in d1
	lsl.l	#8,d1				; shift left 8 bits (max allowed)
	lsl.l	#4,d1				; shift left another 4 bits
	add.w	#$09f0,d1			; value for using A and D with logic function D=A

	moveq	#4,d7				; intialize loop counter (5 bitplanes)

shiftfigloop:
	btst	#6,$dff002			; wait for blitter to finish
	bne	shiftfigloop

	move.l	a2,$dff054          ; set BLTDPTH and BLTDPTL to figbuffer
	move.l	a1,$dff050          ; set BLTAPTH and BLTAPTL to fig
	move.w	#0,$dff066          ; set BLTDMOD modulus to 0 bytes on D
	move.w	#0,$dff064          ; set BLTAMOD modulus to 0 bytes on A
	move.l	#$ffffffff,$dff044  ; set BLTAFWM first word mask for A
	move.w	d1,$dff040          ; BLTCON0 see above for settings
	move.w	#$0000,$dff042      ; BLTCON1
	move.w	#$0b44,$dff058      ; set BLTSIZE height 45 lines, width 4 words (64 pixels)

	add.l	#360,a1             ; point to next bitplane in fig
	add.l	#360,a2             ; point to next bitplane in figbuffer

	dbra	d7,shiftfigloop     ; if d7 > -1 goto shiftfigloop

	lea.l	mask,a1             ; put mask address into a1
	lea.l	maskbuffer,a2       ; put maskbuffer address into a2

shiftmaskloop:
	btst	#6,$dff002          ; wait for blitter (BLTSIZE triggers the blitter)
	bne	shiftmaskloop

	move.l	a2,$dff054          ; set BLTDPTH and BLTDPTL to maskbuffer
	move.l	a1,$dff050          ; set BLTAPTH and BLTAPTL to mask
	move.w	#0,$dff066          ; set BLTDMOD modulus to 0 bytes on D
	move.w	#0,$dff064          ; set BLTAMOD modulus to 0 bytes on A
	move.l	#$ffffffff,$dff044  ; set BLTAFWM first word mask for A
	move.w	d1,$dff040          ; BLTCON0 see above for settings
	move.w	#$0000,$dff042      ; BLTCON1
	move.w	#$0b44,$dff058      ; set BLTSIZE height 45 lines, width 4 words 64 pixels

	rts                         ; return from shiftblit

	;-----subroutine read mouse x, y---
	;-----store result in mousex and mousey---
readmouse:
	move.w	$dff00a,d0			; move JOY0DAT into d0
	move.l	d0,d1				; move d0 value into d1
	lsr.w	#8,d1				; shift right 8 bits
	andi.l	#$ff,d0				; clean with and - d0 holds mouse x value
	andi.l	#$ff,d1				; clean with and - d1 holds mouse y value

	lea.l	mousex,a1			; store mousex result address into a1
	move.l	d0,(a1)				; write mouse x value into result address
	lea.l	mousey,a1			; same stuff for mouse y
	move.l	d1,(a1)

	rts							; return from readmouse

	;-----Store screen in backbuffer---
storeback:
	lea.l	screen,a1			; store screen address in a1
	add.l	#64,a1				; move address past color data
	lea.l	backbuffer,a2		; store backbuffer address in a2

	lea.l	mousex,a0			; store mousex address in a0
	move.l	(a0),d0				; move mouse x value into d0
	lea.l	mousey,a0			; store mousey address in a0
	move.l	(a0),d1				; move mouse y value into d1

	;-----find first blit position
	lsr.l	#4,d0				; mouse x shift right 4 bits 
	lsl.l	#1,d0				; mouse x shift left 1 bit
	mulu	#40,d1				; unsigned multiply to mousey (40 bytes is width of screen)
	add.l	d0,a1				; add mousex to screen address in a1
	add.l	d1,a1				; add mousey to a1

	moveq	#4,d7				; initializer loop counter (5 bitplanes)

storebackloop:
	btst	#6,$dff002          ; wait for blitter
	bne	storebackloop

	move.l	a2,$dff054			; set BLTDPTH and BLTDPTL to backbuffer
	move.l	a1,$dff050			; set BLTAPTH and BLTAPTL to mouse pos on screen
	move.w	#0,$dff066          ; set BLTDMOD modulus to 0 bytes on D
	move.w	#32,$dff064         ; set BLTAMOD modulus to 32 bytes on A
	move.l	#$ffffffff,$dff044  ; set BLTAFWM first word mask for A
	move.w	#$09f0,$dff040      ; BLTCON0 use A and D, set logic function D=A
	move.w	#$0000,$dff042      ; BLTCON1
	move.w	#$0b44,$dff058      ; set BLTSIZE height 45 lines, width 4 words 64 pixels

	add.l	#10240,a1           ; point to next bitplane in screen
	add.l	#360,a2             ; point to next bitplane in backbuffer (45 * 8 bytes)

	dbra	d7,storebackloop	; if d7 > -1 goto storebackloop
	rts                         ; return from storeback

	;-----Write backbuffer to screen
recallback:
	lea.l	screen,a1			; store screen address in a1
	add.l	#64,a1				; move address past color data
	lea.l	backbuffer,a2		; store backbuffer address in a2

	lea.l	mousex,a0			; store address of mousex in a0
	move.l	(a0),d0				; move mousex value into d0
	lea.l	mousey,a0			; store address of mousey in a0
	move.l	(a0),d1				; move mousey value into d1 

	;-----find first blit position
	lsr.l	#4,d0				; mouse x is shifted 4 bits right  
	lsl.l	#1,d0				; mouse x is shifted 1 bit left
	mulu	#40,d1				; unsigned multiply to mousey (40 bytes is width of screen)
	add.l	d0,a1				; add mousex to screen address in a1
	add.l	d1,a1				; add mousey to a1

	moveq	#4,d7				; initialize counter for the loop (5 bitplanes)

recallbackloop:
	btst	#6,$dff002          ; wait for blitter
	bne	recallbackloop          
                            
	move.l	a1,$dff054          ; set BLTDPTH and BLTDPTL to mouse pos on screen
	move.l	a2,$dff050          ; set BLTAPTH and BLTAPTL to backbuffer
	move.w	#32,$dff066         ; set BLTDMOD modulus to 32 bytes on D
	move.w	#0,$dff064          ; set BLTAMOD modulus to 0 bytes on A
	move.l	#$ffffffff,$dff044  ; set BLTAFWM mask for A
	move.w	#$09f0,$dff040      ; BLTCON0 use A and D, set logic function D=A
	move.w	#$0000,$dff042      ; BLTCON1
	move.w	#$0b44,$dff058      ; set BLTSIZE height 45 lines, width 4 words 64 pixels
                            
	add.l	#10240,a1           ; point to next bitplane in screen
	add.l	#360,a2             ; point to next bitplane in backbuffer (45 * 8 bytes)

	dbra	d7,recallbackloop   ; if d7 > -1 goto recallbackloop
	rts                         ; return from recallback

	copper:
	dc.w	$2c01,$fffe			; wait($01,$2c)
	dc.w	$0100,$5200			; (move) set BPLCON0 use 5 bitplanes, enable color burst

	bplcop:
	dc.w	$00e0,$0000			; BPL1PTH
	dc.w	$00e2,$0000			; BPL1PTL
	dc.w	$00e4,$0000			; BPL2PTH
	dc.w	$00e6,$0000			; BPL2PTL
	dc.w	$00e8,$0000			; BPL3PTH
	dc.w	$00ea,$0000			; BPL3PTL
	dc.w	$00ec,$0000			; BPL4PTH
	dc.w	$00ee,$0000			; BPL4PTL
	dc.w	$00f0,$0000			; BPL5PTH
	dc.w	$00f2,$0000			; BPL5PTL

	dc.w	$ffdf,$fffe			; wait($df,$ff) enable wait < $ff horiz
	dc.w	$2c01,$fffe			; wait($01,$12c) for PAL
	dc.w	$0100,$0200			; (move) set BPLCON0 disable bitplanes
								; needed to support older PAL chips
	dc.w	$ffff,$fffe			; end of copper

screen:
	blk.l	12816,0				; allocate 64 + 320/8*256*5 = 51264 bytes = 12816 longs

fig:
	blk.l	450,0				; 45 lines * 64 pixels * 5 bitplanes = 14400 bits = 450 longs

mask:
	blk.l	90,0				; allocate 45 lines * 64 pixels = 2880 bits = 90 longs

figbuffer:
	blk.l	450,0

maskbuffer:
	blk.l	90,0

backbuffer:
	blk.l	450,0

mousex:
	dc.l	0
mousey:
	dc.l	0

	end
	
;------------------------------------------------------------------------------
start:							; comments from letter letter_06 p. 16
	move.w	#$4000,$dff09a		; 9a	INTENA		Line 1-17: Sets up a screen with a resolution
								; of 320 * 256 pixels and with 5 bitplanes (32 colors).
	or.b	#%10000000,$bfd100					
	and.b	#%10000111,$bfd100					
							
	move.w	#$01a0,$dff096		; 96	DMACON		
							
	move.w	#$5200,$dff100		; 100	BPLCON0		
	move.w	#$0000,$dff102		; 102	BPLCON1		
	move.w	#$0000,$dff104		; 104	BPLCON2		
	move.w	#0,$dff108			; 108	BPL1MOD		
	move.w	#0,$dff10a			; 10a	BPL2MOD		
	move.w	#$2c81,$dff08e		; 8e	DIWSTRT		
	;move.w	#$f4c1,$dff090		; 90	DIWSTOP		
	move.w	#$38c1,$dff090		; 90	DIWSTOP		
	move.w	#$0038,$dff092		; 92	DDFSTRT		
	move.w	#$00d0,$dff094		; 94	DDFSOP		
							
	lea.l	screen,a1			;			Line 19-25: Here you put the colors (which are located at the beginning of the display
	move.l	#$dff180,a2			; 180	COLOR00		 buffer) into the color registers.
	moveq	#31,d0					
							
colorloop:							
	move.w	(a1)+,(a2)+					
	dbra	d0,colorloop					
							
	lea.l	bplcop,a2			;			Line 27-40: This code copies the addresses of the 5 bitplanes into the copper-list.
	addq.l	#2,a2					
	move.l	a1,d1					
	moveq	#4,d0					
							
bplcoploop:							
	swap	d1					
	move.w	d1,(a2)					
	addq.l	#4,a2					
	swap	d1					
	move.w	d1,(a2)					
	addq.l	#4,a2					
	add.l	#10240,d1					
	dbra	d0,bplcoploop					
							
	lea.l	copper,a1			;			Line 42-44: Move the address of the copper-list to the copper register.
	move.l	a1,$dff080			; 80	COP1LCH		
	move.w	$dff088,d0			; 88	COPJMP1		
							
	move.w	#$8580,$dff096		; 96	DMACON		Line 46: Start the bitplane and copper-DMA. As you see we have put an extra bit in the
								;			 register. This is bit 10 of the DMACON register. If you set this bit then the
	bsr	readmouse				;			 blitter will be somewhat faster at every blitt. The reason will be explained in a
	bsr	storeback				;			 later issue.
							
mainloop:							
	move.l	$dff004,d0			; 04	VPOSR		Line 52-65: This is the main routine, which is already known.
	asr.l	#8,d0					
	and.l	#$1ff,d0					
	cmp.w	#300,d0					
	bne	mainloop					
							
	bsr	recallback					
	bsr	readmouse					
	bsr	storeback					
	bsr	shiftblit					
	bsr	blitin					
							
	btst	#6,$bfe001					
	bne	mainloop					
							
	move.w	#$0080,$dff096		; 96	DMACON		Line 67-77: Retrieving the original copper-list back and exit the program.
							
	move.l	$4,a6					
	move.l	156(a6),a6					
	move.l	38(a6),$dff080					
							
	move.w	#$80a0,$dff096		; 96	DMACON		
	move.w	#$0400,$dff096		; 96	DMACON		
							
	move.w	#$c000,$dff09a		; 9a	INTENA		
	rts						
							
blitin:							;			Line 79-121: This routine copies our object to the screen.
	lea.l	maskbuffer,a1		;			Line 80: Loads the effective address of the "maskbuffer" to A1.
	lea.l	backbuffer,a3		;			Line 81: Loads the effective address of the "backbuffer" to A3.
	lea.l	figbuffer,a2		;			Line 82: Loads the effective address of "figbuffer" to A2.
	lea.l	screen,a4			;			Line 83: Loads the effective address of "screen" to A4.
	add.l	#64,a4				;			Line 84: Adds 64 to the address in A4. This is done to skip the color data that is at the
								;			 beginning of the display buffer.
	lea.l	mousex,a0			;			Line 86: Loads the effective address of "mousex" to A0.
	move.l	(a0),d0				;			Line 87: Moves the value A0 points to D0.
	lea.l	mousey,a0			;			Line 88-89: Do the same for the mouse y-position.
	move.l	(a0),d1				;			
								;			
	lsr.l	#4,d0				;			Line 91: Shift the contents of D0 four bits to the right. This instruction actually performs
								;			 a division by 16 (24 or 2 * 2 * 2 * 2).
	lsl.l	#1,d0				;			Line 92: Shift the contents of D0 one (1) bit to the left. This instruction actually
								;			 performs multiplication by 2 (21).
	mulu	#40,d1				;			Line 93: Multiply Dl by 40. This takes the y-position in relation to the screen (line 1 on
								;			 the screen is 40 bytes).
	add.l	d0,a4				;			Line 94: Add the contents of D0 (the x-position) to the value of A4 (screen).
	add.l	d1,a4				;			Line 95: Add the contents of D1 (the y-position) to the value of A4.(screen)
								;			
	moveq	#4,d7				;			Line 97: Moves the value 4 into D7 quickly.
							
blitinloop:						;			Line 99-101: Wait until the blitter is available.
	btst	#6,$dff002			; 02	DMACONR		
	bne	blitinloop					
							
	move.l	a4,$dff054			; 54	BLTDPTH		Line 103: Moves the address in A4 ("screen") into the D-channel register.
	move.l	a1,$dff050			; 50	BLTAPTH		Line 104: Moves the address in A1 ("maskbuffer") into the A-channel register.
	move.l	a2,$dff04c			; 4c	BLTBPTH		Line 105: Moves the address in A2 ("figbuffer") into the B-channel register.
	move.l	a3,$dff048			; 48	BLTCPTH		Line 106: Moves the address in A3 ("backbuffer") into the C-channel register.
	move.w	#32,$dff066			; 66	BLTDMOD		Line 107: Set the modulo for the D-channel to 32 (64 pixels wide by 40 - (64 / 8) = 32).
	move.w	#0,$dff064			; 64	BLTAMOD		Line 108-110: Put the modulo for A, B and C channels to 0
	move.w	#0,$dff062			; 62	BLTBMOD		
	move.w	#0,$dff060			; 60	BLTCMOD		
	move.l	#$ffffffff,$dff044	; 44	BLTAFWM		Line 111: Add value SFFFFFFFF into a mask register.
	move.w	#$0fca,$dff040		; 40	BLTCON0		Line 112: Here are the mini-terms  D = AB + AC  defined and all needed channels selected.
	move.w	#$0000,$dff042		; 42	BLTCON1		Line 113: Move the value 0 to BLTCON1.
	move.w	#$0b44,$dff058		; 58	BLTSIZE		Line 114: Move the blitt size to the BLITTSIZE register (height: 45 lines, width: 4 words
								;			 = 64 pixels).
	add.l	#360,a2				;			Line 116: Add 360 to the address in A2 so it points to the next bitplane in the "figbuffer"
								;			 (45 * (64 / 8) = 360).
	add.l	#360,a3				;			Line 117: Add 360 to the address in A3 so it points to the next bitplane in the
								;			 "backbuffer".
	add.l	#10240,a4			;			Line 118: Add 10240 to address in A4 so it points to the next bitplane in the "screen".
								;			The address of the "mask" buffer stays the same since it has only one bitplane.
	dbra	d7,blitinloop		;			Line 120: Repeat this blitt 5 times - once for each of the 5 bitplanes.
	rts							;			Line 121: Go back to the calling instance here the main routine.
								;			
shiftblit:						;			Line 123-171: This routine shifts the object and mask (bitwise) so that the figure can also be
								;			moved a horizontally.
	lea.l	fig,a1				;			Line 124: Load the effective address of the object "fig" to A1.
	lea.l	figbuffer,a2		;			Line 125: Load the effective address of "figbuffer" to A2.
								;			
	lea.l	mousex,a0			;			Line 127-128: Get the mouse x-position in D1.
	move.l	(a0),d1				;			
								;			
	andi.l	#$f,d1				;			Line 130: Mask out (set to 0) all bits except bit 0-3 in D1
	lsl.l	#8,d1				;			Line 131-132: Shift the content of Dl about 8 and then 4 bits to the left which turns out to be
	lsl.l	#4,d1				;			 12 bits in total. You have to change twice because MC-68000 (this method)
								;			 allows only 8 shifts at a time.
	add.w	#$09f0,d1			;			Line 133: Add value $09F0 to D1. D1 will now contain $x9F0 where "x" is the number
								;			 of data bits the blitter is shifting. In a issue VII, we looks at how the blitter
								;			 performs such a shift. This blitt retrieves all the data from the object-buffer
								;			 "fig" shifts the data for "x" bits to the right, and writes the result into the
								;			 "figbuffer". The logical operation (mini-term) is D = A and D and A channels
								;			 are selected.
	moveq	#4,d7				;			Line 135: Move the constant value 4 into D7 quickly (counter for the biplanes).
								;			
shiftfigloop:					;			Line 137-139: Wait until the blitter is available.
	btst	#6,$dff002			; 02	DMACONR		
	bne	shiftfigloop					
							
	move.l	a2,$dff054			; 54	BLTDPTH		Line 141: Move the address in A2 ("figbuffer") to the D-channel register.
	move.l	a1,$dff050			; 50	BLTAPTH		Line 142: Move the address in A1 ("fig") to the A-channel register.
	move.w	#0,$dff066			; 66	BLTDMOD		Line 143-144: Set modulo for A- and D-channel to 0 since they have both the same size.
	move.w	#0,$dff064			; 64	BLTAMOD		
	move.l	#$ffffffff,$dff044	; 44	BLTAFWM		Line 145: Set the A-mask register to $FFFFFFFF.
	move.w	d1,$dff040			; 40	BLTCON0		Line 146: Move value located in the D1 (the number shifts) into BLTCON0 register.
	move.w	#$0000,$dff042		; 42	BLTCON1		Line 147: Move the value 0 into BLTCON1 register.
	move.w	#$0b44,$dff058		; 58	BLTSIZE		Line 148: The size of this blitt is also 45 lines * 4 words (8 Bytes or 64 pixels).
							
	add.l	#360,a1				;			Line 150-151: Add 360 to both A1 and A2 to increase the addresses to their next bitplane.
	add.l	#360,a2				;			
								;			
	dbra	d7,shiftfigloop		;			Line 153: Repeats this piece of code for all 5 bitplanes.
								;			
	lea.l	mask,a1				;			Line 155-169: It is the same way for the mask. The only difference is that the mask has
	lea.l	maskbuffer,a2		;			 only one bitplane and therefore looping is not necessary.
							
shiftmaskloop:							
	btst	#6,$dff002			; 02	DMACONR		
	bne	shiftmaskloop					
							
	move.l	a2,$dff054			; 54	BLTDPTH		
	move.l	a1,$dff050			; 50	BLTAPTH		
	move.w	#0,$dff066			; 66	BLTDMOD		
	move.w	#0,$dff064			; 64	BLTAMOD		
	move.l	#$ffffffff,$dff044	; 44	BLTAFWM		
	move.w	d1,$dff040			; 40	BLTCON0		
	move.w	#$0000,$dff042		; 42	BLTCON1		
	move.w	#$0b44,$dff058		; 58	BLTSIZE		
							
	rts							;			Line 171: Go back to the calling instance – here the main routine.
							
readmouse:						;			Line173-185: This part reads out the mouse x- and y-position.
	move.w	$dff00a,d0			; 0a	JOY0DAT		Line 174-185: This routine reads the mouse positions and stores them into "mousex" and
								; "mousey". The register $DFF00A will be explained in issue XI.
	move.l	d0,d1					
	lsr.w	#8,d1					
	andi.l	#$ff,d0					
	andi.l	#$ff,d1					
							
	lea.l	mousex,a1					
	move.l	d0,(a1)					
	lea.l	mousey,a1					
	move.l	d1,(a1)					
							
	rts						
							
storeback:						;			Line 187-222: This routine copies the screen background (screen memory) into background
								;			 buffer ("backbuffer").
	lea.l	screen,a1			;			Line 188: Load the effective address of the "screen" to A1.
	add.l	#64,a1				;			Line 189: Add 64 to the address in A1. This causes A1 to skip the color data that is in
								;			 beginning of the display buffer.
	lea.l	backbuffer,a2		;			Line 190: Load the effective address of the "back buffer" to A2.
								;			
	lea.l	mousex,a0			;			Line 192-195: Read the addresses of mouse-position (x-and y-coordinates) and move them to
	move.l	(a0),d0				;			 D0 and D1.
	lea.l	mousey,a0			;			
	move.l	(a0),d1				;			
								;			
	lsr.l	#4,d0				;			Line 197-201: Find the first blitt position on the screen.
	lsl.l	#1,d0				;			
	mulu	#40,d1				;			
	add.l	d0,a1				;			
	add.l	d1,a1				;			
								;			
	moveq	#4,d7				;			Line 203: Move value 4 into the D7 quickly
							
storebackloop:					;			Line 205-207: Wait until the blitter is available.
	btst	#6,$dff002			; 02	DMACONR		
	bne	storebackloop					
							
	move.l	a2,$dff054			; 54	BLTDPTH		Line 209: Move the address in A2 ("backbuffer") into the D-channel register.
	move.l	a1,$dff050			; 50	BLTAPTH		Line 210: Move the address in A1 ("screen") into the A-channel register.
	move.w	#0,$dff066			; 66	BLTDMOD		Line 211: Set modulo for D-channel to 0
	move.w	#32,$dff064			; 64	BLTAMOD		Line 212: Set modulo for A-channel to 32
	move.l	#$ffffffff,$dff044	; 44	BLTAFWM		Line 213: A-mask register is set to $FFFFFFFF.
	move.w	#$09f0,$dff040		; 40	BLTCON0		Line 214: Set the logic operation (mini-terms) to D = A, and select the A- and D-channel.
	move.w	#$0000,$dff042		; 42	BLTCON1		Line 215: Move the value of 0 into BLTCON1 register.
	move.w	#$0b44,$dff058		; 58	BLTSIZE		Line 216: Set the size to 45 lines * 4 words to the BLTSIZE register.
							
	add.l	#10240,a1			;			Line 218-219: Add 10240 to the address in A1 ("screen") and add 360 to the address in A2
	add.l	#360,a2				;			 ("backbuffer") so that the registers point to the next bitplain.
							
	dbra	d7,storebackloop	;			Line 221: This blitt repeat 5 times (each for one bitplane).
	rts							;			Line 222: Go back to the calling instance – here the main routine.
							
recallback:						;			Line 224-259: This routine backs-up the screen from the background buffer.
	lea.l	screen,a1			;			Line 224-259: This routine is almost identical to the "storeback"-routine. The only difference
	add.l	#64,a1				;			 is that the data blitt is done in the opposite direction (from the background
	lea.l	backbuffer,a2		;			 buffer to the screen memory).
								;			To run this program you must first assemble it and then load the files: screen, figures and
	lea.l	mousex,a0			;			masks (with command "ri"). They are in the same directory as the source file).
	move.l	(a0),d0				;			We hope that you understand how the blitter works. We do not deny that understanding the
	lea.l	mousey,a0			;			blitter is the most complicated topic of the Amiga. Nevertheless it is possible to learn by
	move.l	(a0),d1				;			yourself through experimenting with the code. So even though you might think this
								;			chapter is completely incomprehensible, don’t give up. Dig it through over and over again!
	lsr.l	#4,d0					
	lsl.l	#1,d0			
	mulu	#40,d1			
	add.l	d0,a1			
	add.l	d1,a1			
					
	moveq	#4,d7			
					
recallbackloop:					
	btst	#6,$dff002			; 02	DMACONR
	bne	recallbackloop			
					
	move.l	a1,$dff054			; 54	BLTDPTH
	move.l	a2,$dff050			; 50	BLTAPTH
	move.w	#32,$dff066			; 66	BLTDMOD
	move.w	#0,$dff064			; 64	BLTAMOD
	move.l	#$ffffffff,$dff044	; 44	BLTAFWM
	move.w	#$09f0,$dff040		; 40	BLTCON0		
	move.w	#$0000,$dff042		; 42	BLTCON1		
	move.w	#$0b44,$dff058		; 58	BLTSIZE		
							
	add.l	#10240,a1					
	add.l	#360,a2					
							
	dbra	d7,recallbackloop					
	rts						
							
copper:							;			Line 261-280: Here is the copper list declared.
	dc.w	$2c01,$fffe					
	dc.w	$0100,$5200					
							
bplcop:							
	dc.w	$00e0,$0000					
	dc.w	$00e2,$0000					
	dc.w	$00e4,$0000					
	dc.w	$00e6,$0000					
	dc.w	$00e8,$0000					
	dc.w	$00ea,$0000					
	dc.w	$00ec,$0000					
	dc.w	$00ee,$0000					
	dc.w	$00f0,$0000					
	dc.w	$00f2,$0000					
							
	dc.w	$ffdf,$fffe					
	dc.w	$2c01,$fffe					
	dc.w	$0100,$0200					
	dc.w	$ffff,$fffe					
							
screen:							;			Line 282-298: Here memory for all necessary buffers is declared.
	blk.l	12816
	;incbin "screen_brev6"		; for asmone	
fig:		
	blk.l	450
	;incbin "fig"				; for asmone		
mask:		
	blk.l	90
	;incbin "mask"				; for asmone		
figbuffer:		
	blk.l	450
		
maskbuffer:		
	blk.l	90
		
backbuffer:		
	blk.l	450
							
mousex:							;			Line 300-303: Here we have declared two long-words to keep the mouse position (x-and ycoordinates).
	dc.l	0					
mousey:							
	dc.l	0					


	end
