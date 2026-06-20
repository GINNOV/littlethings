; mc0701.s 				; scrolltext	
; from disk1/brev07
; explanation on letter_07.pdf / p. 3
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

start:							; comments from Mark Wrobel				
	move.w	#$4000,$dff09a      ; INTENA clear master interupt
	;-----stop disk drives---
	or.b	#%10000000,$bfd100  ; set CIABPRB MTR
	and.b	#%10000111,$bfd100  ; clr CIABPRB SEL3, SEL2, SEL1, SEL0

	move.w	#$01a0,$dff096		; DMACON clear bitplane, copper, blitter
	;-----Setup bitplanes, display and DMA data fetch. Resolution 352*256 with 1 bitplane
	move.w	#$1200,$dff100		; BPLCON0 use 1 bitplanes (2 colors)
	move.w	#$0000,$dff102		; BPLCON1 scroll
	move.w	#$0000,$dff104		; BPLCON2 video
	move.w	#$0002,$dff108		; BPL1MOD modulus odd planes
	move.w	#$0002,$dff10a		; BPL2MOD modulus even planes
	move.w	#$2c71,$dff08e		; DIWSTRT upper left corner ($71,$2c)
	;move.w	#$f4d1,$dff090		; DIWSTOP enaple PAL trick
	move.w	#$38d1,$dff090		; DIWSTOP lower right corner ($1d1,$12c)
	move.w	#$0030,$dff092		; DDFSTRT data fetch start at $30
	move.w	#$00d8,$dff094		; DDFSTOP data fetch stop at $d8
	;-----set BPL1PTH/BPL1TPL in bplcop---
	lea.l	screen,a1			; write screen address into a1
	lea.l	bplcop,a2			; write bplcop address into a2
	move.l	a1,d1				; move a1 to d1
	swap	d1					; swap words
	move.w	d1,2(a2)			; write first word into a2+2 (BPL1PTH)
	swap	d1					; swap words
	move.w	d1,6(a2)			; write first word into a2+6 (BPL1PTL)
	;-----setup copper---
	lea.l	copper,a1			; put address of copper into a1
	move.l	a1,$dff080			; set COP1LCH and COP1LCL to address in a1
	move.w	#$8180,$dff096		; DMACON set PBLEN, COPEN

mainloop:
	move.l	$dff004,d0			; read VPOSR and VHPOSR into d0 as one long word
	asr.l	#8,d0				; shift right 8 poositions
	and.l	#$1ff,d0			; and for immediate data
	cmp.w	#300,d0    
	bne	mainloop				; if not at line 300 goto mainloop

	bsr	scroll					; scroll letters

	btst	#6,$bfe001			; CIAAPRA FIR0 check mouse button
	bne	mainloop				; if not pressed goto mainloop

	move.w	#$0080,$dff096 ; DMACON clear copper
	;-----reestablish DMA's and copper---
	move.l	$04,a6
	move.l	156(a6),a6
	move.l	38(a6),$dff080

	move.w	#$80a0,$dff096

	move.w	#$c000,$dff09a
	rts							; return from mainloop

scrollcnt:
	dc.w	$0000

charcnt:
	dc.w	$0000
	;-----scroll subroutine---
	scroll:
	lea.l	scrollcnt,a1		; move scrollcnt address into a1
	cmp.w	#8,(a1)				; compare scrollcnt with 8
	bne	nochar					; if not equal goto nochar

	clr.w	(a1)				; set scrollcnt to 0

	lea.l	charcnt,a1			; move charcnt address into a1
	move.w	(a1),d1				; move charcnt value into d1
	addq.w	#1,(a1)				; add 1 to charcnt value - d1 unaffected

	lea.l	text,a2				; move text address into a2
	clr.l	d2					; set d2 to 0 - d2 points to current char
	move.b	(a2,d1.w),d2		; move value in address text+charcnt into d2

	cmp.b	#42,d2				; check if d2 equals 42 (termination sign "*")
	bne	notend					; if not equal goto notend

	clr.w	(a1)				; set charcnt to 0
	move.b	#32,d2				; move 32 into d2 (space " " = 32)

notend:
	lea.l	convtab,a1			; move address of char convertion table into a1
	move.b	(a1,d2.b),d2		; d2 is an offset in the table. Store result in d2
	asl.w	#1,d2				; multiply d2 by two - font is 2 bytes wide - 16 pixels

	lea.l	font,a1				; move font address into a1
	add.l	d2,a1				; add offset d2 to a1 so it points to current letter

	lea.l	screen,a2			; move screen address into a2
	add.l	#6944,a2			; 46 * 150 + 44

	moveq	#19,d0				; use d0 as counter. Font is 20 lines heigh

putcharloop:					; loop over each horiz line in font
	move.w	(a1),(a2)			; move 16 pixels of current letter into a2
	add.l	#64,a1				; go to next line in current letter font
	add.l	#46,a2				; go to the next line on screen
	dbra	d0,putcharloop		; if d0 > -1 goto putcharloop

nochar:
	btst	#6,$dff002			; DMACONR test bit 6 BLTEN
	bne	nochar					; if blitter enabled goto nochar

	lea.l	screen,a1			; move screen address into a1
	add.l	#7820,a1			; add 46*(150+20) end of line 170
	; setup blitter
	move.l	a1,$dff050          ; BLTAPTH and BLTAPTL set to end of line 170
	move.l	a1,$dff054          ; BLTDPTH and BLTDPTL set to end of line 170
	move.w	#0,$dff064          ; BLTAMOD set modulo to 0 bytes on A
	move.w	#0,$dff066          ; BLTDMOD set modulo to 0 bytes on D
	move.l	#$ffffffff,$dff044  ; set BLTAFWM first word mask for A
	move.w	#$29f0,$dff040      ; BLTCON0 shift two bits on A, use A,D with D=A
	move.w	#$0002,$dff042      ; BLTCON1 enable decending mode
	move.w	#$0517,$dff058      ; BLTSIZE height 20 lines, width 23 words. 20 * 64 + 23

	lea.l	scrollcnt,a1        ; move scrollcnt address into a1
	addq.w	#1,(a1)             ; add 1 to scrollcnt value

	rts							; return from scroll subroutine

copper:
	dc.w	$2c01,$fffe			; wait($01,$2c)
	dc.w	$0100,$1200			; BPLCON0 use 1 bitplane, enable color burst

bplcop:
	dc.w	$00e0,$0000			; BPL1PTH
	dc.w	$00e2,$0000			; BPL1PTL

	dc.w	$0180,$0000			; COLOR00 black
	dc.w	$0182,$0ff0			; COLOR01 yellow

	dc.w	$ffdf,$fffe			; wait($df,$ff) enable wait < $ff horiz
	dc.w	$2c01,$fffe			; wait($01,$12c) for PAL
	dc.w	$0100,$0200			; (move) set BPLCON0 disable bitplanes needed to support older PAL chips
	dc.w	$ffff,$fffe			; end of copper

screen:
	blk.l	$b80,0

font:
	blk.l	$140,0

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

text:
	dc.b	"DETTE ER EN TEST AV EN SCROLL P$ AMIGA....    *"

	end
;------------------------------------------------------------------------------

start:							; comments from letter_07.pdf / p. 3
	move.w	#$4000,$dff09a		; 9a	INTENA		Line 1: Turn off all interrupts.
							
	or.b	#%10000000,$bfd100	; Line 3-4: Stops the floppy motor.
	and.b	#%10000111,$bfd100					
							
	move.w	#$01a0,$dff096		; 96	DMACON		Line 6: Turn off the bitplane, copper and sprite-DMA.
							
	move.w	#$1200,$dff100		; 100	BPLCON0		Line 8-17: Set up a 352 *256 pixel screen with a BITPLANE and with a value 2 for
	move.w	#$0000,$dff102		; 102	BPLCON1		 the MODULO. The modulo for bitplanes and how it works is explained later in
	move.w	#$0000,$dff104		; 104	BPLCON2		 this issue.
	move.w	#$0002,$dff108		; 108	BPL1MOD		
	move.w	#$0002,$dff10a		; 10a	BPL2MOD		
	move.w	#$2c71,$dff08e		; 8e	DIWSTRT		
	;move.w	#$f4d1,$dff090		; 90	DIWSTOP		
	move.w	#$38d1,$dff090		; 90	DIWSTOP		
	move.w	#$0030,$dff092		; 92	DDFSTRT		
	move.w	#$00d8,$dff094		; 94	DDFSOP		
							
	lea.l	screen,a1			; Lines 19-25: Moves the address of the bitplanes into the copper-list.
	lea.l	bplcop,a2					
	move.l	a1,d1					
	swap	d1					
	move.w	d1,2(a2)					
	swap	d1					
	move.w	d1,6(a2)					
							
	lea.l	copper,a1			; Lines 27-28: Moves the copper-list address into the copper register
	move.l	a1,$dff080			; 80	COP1LCH		
	move.w	#$8180,$dff096		; 96	DMACON		Line 29: Starts bitplane and copper-DMA again
							
mainloop:						; Line 31: Here begins the main loop
	move.l	$dff004,d0			; 04	VPOSR		Line 32-36: Waiting for the electron beam to reach screen line number 300
	asr.l	#8,d0					
	and.l	#$1ff,d0					
	cmp.w	#300,d0					
	bne	mainloop					
							
	bsr	scroll					; Line 38: Branch to sub-routine "scroll"
							
	btst	#6,$bfe001			; CIA Lines 40-41: Check whether left mouse button is pressed, if not, the program branches back
	bne	mainloop				; to "main loop"
							
	move.w	#$0080,$dff096		; 96	DMACON		Line 43: Turns off copper-DMA
							
	move.l	$04,a6				; Line 45-47: Moves the original address of the system copper-list into copper-register
	move.l	156(a6),a6					
	move.l	38(a6),$dff080		; 80	COP1LCH		
							
	move.w	#$80a0,$dff096		; 96	DMACON		Line 49: Starts copper and sprite-DMA
							
	move.w	#$c000,$dff09a		; 9a	INTENA		Line 51: Enable all interrrupts again
	rts						
								; Line 54-58: Here we reserved a word to be used as a scroll-counter
scrollcnt:							
	dc.w	$0000					
							
charcnt:							
	dc.w	$0000					
							
scroll:							; Line 60: Here begins the scroll- routine
	lea.l	scrollcnt,a1		; Line 61: Loads the effective address of "scrollcnt" into A1
	cmp.w	#8,(a1)				; Line 62: Compares "scrollcnt" with value 8
	bne	nochar					; Line 63: If the value of "scrollcnt" is not equal to 8 branch to label "nochar"
								;			
	clr.w	(a1)				; Line 65: Clears the "scrollcnt" (set to 0)
								;			
	lea.l	charcnt,a1			; Line 67: Load the effective address of "charcnt" to A1
	move.w	(a1),d1				; Line 68: Move the value A1 points to ("charcnt") to D1
	addq.w	#1,(a1)				; Line 69: Increase "charcnt" by 1; note that the value 1 is directly copied into the
								; address A1 points to and not in D1!
	lea.l	text,a2				; Line 71: Loads the effective address of the "text" into A2.
	clr.l	d2					; Line 72: Clears D2 (sets to 0)
	move.b	(a2,d1.w),d2		; Line 73: Moves the content, the address in A2 + D1 points to, into D2. This instruction
								;			 retrieves an ASCII code from your own text ("text"), where OFFSET to the
								;			 text is in D1. So if D1 contains 0, the first letter will be placed in D2. If D1
								;			 contains 1, it will move the second letter, etc.
								;			
	cmp.b	#42,d2				; Line 75: Check if D2 is equal to 42 ASCII code 42 is a "*". This "*" must be the last
								; character in the text to indicate that the text is finished.
	bne	notend					; Line 76: If we have NOT reached the last character, then branch to the label "notend".
								;			
	clr.w	(a1)				; Lines 78-79: If we reached the last character in the text, we reset "charcnt" to 0 and move an
	move.b	#32,d2				; value of 32 into D2 (ASCII code for space = 32).
								;			
notend:							;			
	lea.l	convtab,a1			; Line 82: Loads the effective address of the conversion-table "convtab" to A1. This table
								;			 contains the letters (characters) position in our font.
	move.b	(a1,d2.b),d2		; Line 83: Moves the content, the address in Al + D2 points to, into register D2. The old
								; value of D2 (which contained ASCII code for the character) is used here as an
								; offset for the table. So: If D2 contains 32 (a space), the 33rd byte (remember
								; counts from 0) from the table is moved to D2. In this case $1F or 31 decimal
								; was the offset. We now have created the ASCII code for our own font and used
								; only a single instruction!
	asl.w	#1,d2				; Line 84: The contents of D2 shifted one bit to the left. This is the same as a
								; multiplication by 2. It must be made because a character in FONT is 16
								; pixels (2 bytes) wide.
	lea.l	font,a1				; Line 86: Loads the effective address of the "font" to A1
	add.l	d2,a1				; Line 87: Add the value of D2 to the address in A1 – now A1 points to the first character
								;			 which in turn will be copied on the screen.
	lea.l	screen,a2			; Line 89: Loads the effective address of the display ("screen") into the A2
	add.l	#6944,a2			; Line 90: Add a constant value of 6944 to A2. As mentioned, the screen 352 pixels wide
								; (including 16 pixel overscan on each side) and 2 of modulo. So a screen line
								; has 46 bytes (352 / 8 + 2). With bitplanes modulo works the same way as with
								; the blitter. Because the visible screen width set to 352 pixels (the same as 44
								; bytes), there will be two bytes left over per screen line. When we define
								; modulo of 2 the BITPLANE-DMA jumps over 2 bytes at the end of each line.
								; This results in that we have 2 bytes of invisible display data on each line. In
								; this invisible area, we copy the characters which must be scrolled. When we do
								; it this way, it seems as if the characters scroll out of the edge of the screen. So:
								; When we add a constant of 6944 to the screen address we reach line 150 and
								; the byte position 44 (150 * 46 +44 = 6944).
	moveq	#19,d0				; Line 92: Moves quickly the constant value of 19 into D0. D0 is used as a counter to
								; count the height of the character to be added into the screen (display memory).
								; The font we use here has characters which are 20 pixels high.
putcharloop:					; Line 94: Here begins loop to put the characters from the font into screen memory.
	move.w	(a1),(a2)			; Line 95: Move the value, A1 points to (position in the font area), to the address A2
								; points to (certain position in the screen).
	add.l	#64,a1				; Line 96: Adds 64 to the address A1. Let A1 point to next line in font (32 characters * 16
								; pixels = 512; 512 / 8 = 64).
	add.l	#46,a2				; Line 97: Adds 46 to the address in A2 (certain position in the screen). A2 points now on
								; the next line in our video memory.
	dbra	d0,putcharloop		; Line 98: Decrement D0 by 1, check if D0 is -1, if not branch back to the label
								; " putcharloop".
nochar:							
	btst	#6,$dff002			; 02	DMACONR		Line 101-102: Waiting until the blitter is available.
	bne	nochar					
							
	lea.l	screen,a1			; Line 104: Loads the effective address of the screen ("screen") to A1
	add.l	#7820,a1			; Line 105: Add the constant value of 7820 to the address in Al. Al will now point to the
								; bottom of the line of the scroller (46 * (150 +20) = 7820). It is customary to
								; point to the upper left corner of blitt, but in this case we must point to the
								; bottom (last) line, which must be blitted. This is because we are using the
								; descending mode (i.e. to run blitter "backwards" so that it counts downwards
								; in memory). If we would use the blitter in normal modus the text would scroll
								; the wrong way.
	move.l	a1,$dff050			; 50	BLTAPTH		Line 107: Moves the address from A1 into the blitter A-channel register
	move.l	a1,$dff054			; 54	BLTDPTH		Line 108: Moves the address from A1 into the blitter D-channel register
	move.w	#0,$dff064			; 64	BLTAMOD		Line 109: Sets A-modulo to 0
	move.w	#0,$dff066			; 66	BLTDMOD		Line 110: Sets also D-modulo to 0
	move.l	#$ffffffff,$dff044	; 44	BLTAFWM		Line 111: Sets A-mask to $FFFFFFFF
	move.w	#$29f0,$dff040		; 40	BLTCON0		Line 112: Sets the logical operation D = A, giving 2 bits Shift on the A channel.
								; It is this
								; value containing the number of pixels, to be scrolled at a time. In this case we
								; scroll pixel pairs. If you want to scroll slower, you can set it to 1, and change
								; the number from 8 in the program line 62 to 16
	move.w	#$0002,$dff042		; 42	BLTCON1		Line 113: Bit 1 in BLTCON1 register is set to "1" to indicate the descending mode
	move.w	#$0523,$dff058		; 58	BLTSIZE		Line 114: The value of $5017 is moved into the BLTSIZE register (width = 23 word and
								; height = 20 lines). The value is calculated from following: 20 * 64 +23 =
								; $5017). This instruction starts the blitter automatically
	lea.l	scrollcnt,a1		; Line 116: Load the effective address of "scrollcnt" to A1.
	addq.w	#1,(a1)				; Line 117: Increase "scrollcnt" by 1
								; Line 119: Branch to the calling instance – here to line 38, and continue the program
	rts							; execution there
								;			
copper:							; Line 122-135: The copper list is declared here
	dc.w	$2c01,$fffe					
	dc.w	$0100,$1200					
							
bplcop:							
	dc.w	$00e0,$0000					
	dc.w	$00e2,$0000					
							
	dc.w	$0180,$0000					
	dc.w	$0182,$0ff0					
							
	dc.w	$ffdf,$fffe					
	dc.w	$2c01,$fffe					
	dc.w	$0100,$0200					
	dc.w	$ffff,$fffe					
							
screen:							; Line 138: Here we have reserved memory for the screen
	blk.l	$b80,0				;			
								; Line 141: Here memory for the font is reserved
font:							;			
	blk.l	$140,0				;			
								;			
convtab:						; Line 144-237: Here is the conversion table used to change from the ASCII code of characters
	dc.b	$00					; to position in our font
	dc.b	$00					; Line 240: Here is the scroll text which of course can be edited as you like. Add noticed
	dc.b	$00					; that we have used special characters. We have done so because it can be
	dc.b	$00					; difficult to get these letters to all keyboards.So, when you need an "Æ" type
	dc.b	$00					; "@" you will have a "0" use "#" and "A" is a "$" sign. Do not forget to write a
	dc.b	$00					; "*" character to finish the text.
	dc.b	$00					; To run this program you must first assemble it. Then attach the file "font" to the label
	dc.b	$00					; FONT as follows:
	dc.b	$00					; Seka> a
	dc.b	$00					; OPTIONS>
	dc.b	$00					; No errors
	dc.b	$00					; Seka> ri
	dc.b	$00					; FILNAME> font
	dc.b	$00					; BEGIN> font
	dc.b	$00					; END> (just press RETURN)
	dc.b	$00					; Seka> j
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
							
text:							
	dc.b	DETTE ER EN TEST AV EN SCROLL P$ AMIGA....    *					

	end



