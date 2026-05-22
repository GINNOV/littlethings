; mc0502.s 				; multiple moving sprites
; from disk1/brev05
; explanation on letter_05.pdf / p.07
; from Mark Wrobel course letter 16

; SEKA>ks	; (optional)
; Sure? y
; SEKA>r
; FILENAME>mc0502.s
; SEKA>a
; OPTIONS>
; SEKA>ri
; FILENAME>screen
; BEGIN>screen
; END>
; SEKA>ri
; FILENAME>movetable
; BEGIN>movetable
; END>
; SEKA>j

start:							; comments from letter letter_05 p. 07
	move.w	#$4000,$dff09a		; 9a			Line 1: Disables all interrupts
							
	or.b	#%10000000,$bfd100	;				Line 3-4: Stops engine in all diskette stations.
	and.b	#%10000111,$bfd100	;	
							
	move.w	#$01a0,$dff096		; 96			Line 6: Disable bitplane-, copper- and sprite-DMA.
							
	move.w	#$1200,$dff100		;100			Line 8-17: Sets up a 256 * 320 pixels display with a bitplane (two colors, 1 +
	move.w	#$0000,$dff102		;102			background) up.
	move.w	#$003f,$dff104		;104			
	move.w	#0,$dff108			;108			
	move.w	#0,$dff10a			;10a			
	move.w	#$2c81,$dff08e		; 8e			
	;move.w	#$f4c1,$dff090		; 90			
	move.w	#$38c1,$dff090		; 90			
	move.w	#$0038,$dff092		; 92			
	move.w	#$00d0,$dff094		; 94			
							
	lea.l	s1,a1				;	Lines 19-33: Adds sprite addresses into copper list. Please note that all sprite data are
	lea.l	copper,a2			;	defined successively in program. In line 32 an offset of 68 is added for
	add.l	#2,a2				;	each loop. It mages the register Dl pointing to the next start of the sprite
	move.l	a1,d1				;	data.
	move.l	#7,d0				;	
								;	
sprcoploop:						;	
	swap	d1					;	
	move.w	d1,(a2)				;	
	addq.l	#4,a2				;	
	swap	d1					;	
	move.w	d1,(a2)				;	
	addq.l	#4,a2				;	
	add.l	#68,d1				;	
	dbra	d0,sprcoploop		;	
								;	
	lea.l	screen,a1			;	Lines 35-40: Adds the address of the bitmap (screen) into the copper-list.
	lea.l	bplcop,a2			;	
	move.l	a1,d1				;	
	move.w	d1,6(a2)			;	
	swap	d1					;	
	move.w	d1,2(a2)			;	
								;	
	lea.l	copper,a1			;	Lines 42-44: Loads the effective address of our copper-list and moves it into copperpointer register ($DFF080).
	move.l	a1,$dff080			; 80			
	move.w	$dff088,d0			; 88			
	move.w	#$81a0,$dff096		; 96			Line 45: Opens bitplane, copper- and sprite-DMA again.
							
wait:							
	move.l	$dff004,d0			; 04			Line 48-52: Waiting (goes into loop) until the electron beam reaches line 0
	asr.l	#8,d0				;	
	and.l	#$1ff,d0			;	
	cmp.w	#0,d0				;	
	bne	wait					;	
								
	bsr	movesprite				;	Line 54: Jumps to the routine to move the sprites.
								;	
	btst	#6,$bfe001			;	Lines 56-57: Check if the left mouse button is pressed. If not jumping back to the
	bne	wait					;	label "wait".
								;	
	move.w	#$0080,$dff096		; 96			Line 59: Closes copper-DMA
							
	move.l	$04,a6				; Line 61-63: Retrieving the old (previous) COPPER-list address and puts it into
	move.l	156(a6),a6			; copper-pointer.
	move.l	38(a6),$dff080		; 80			
							
	move.w	#$8080,$dff096		; 96			Line 65: Starts copper-DMA again.
							
	move.w	#$c000,$dff09a		; 9a			Line 67: Starts all interrupt again.
	rts							;	Line 68: End the program returning to the calling instance (e.g. back to K-Seka
								;	or CLI).
movecount:						;	
	dc.w	$0000				;	Line 71: Here we have defined a word to keep the offset to the table containing
								;	Sprite coordinates.
movesprite:						;	Line 73: Here begins the routine for moving the sprites.
	lea.l	movecount,a5		;	Line 74: adds the address to "move count" (line 71) and puts it in A5.
	move.w	(a5),d5				;	Line 75: Retrieving the value from the address which is contained in A5.
	add.w	#4,(a5)				;	Line 76: Adds an offset of 4 to the value of the address in A5
								;	
	cmp.w	#12000,d5			;	Line 78: Compares the value in D5 with 12000.
	blt	notend					;	Line 79: If D5 is less than 12000 jump op to the label "notend".
								;	
	clr.l	d5					;	Line 81: Put the value 0 in D5(clear D5)
	clr.w	(a5)				;	Line 82: Clear the word the address in A5 points to (the move count).
								;	
notend:							;	
	clr.l	d1					;	Lines 85-86: Move the value 0 in Dl and D2.
	clr.l	d2						
	lea.l	movetable,a5		;	Line 87: Load the effective address of "move table" into the A5.
	move.l	#15,d3				;	Line 88: Move the value 15 in D3.
								;	
	move.w	(a5,d5.w),d1		;	Line 90: This variation of MOVE, you probably have not seen before. In this
								;	instruction D5 will be given as an offset to A5.
								;	Let us give an example:
								;	MOVE.W 10(A1), D1
								;	Performs the same as:
								;	MOVE.L #10, D2
								;	MOVE.W (A1, D2), D1
								;	This in turn performs the same as:
								;	MOVE.L #8, D2
								;	MOVE.W 2(A1, D2), D1
								;	We will explain this variation in more detail in the “machine code section” in this issue. In
								;	any case it loads the value of the address that A5 points to plus the offset from D5, and moves
								;	it into D1 (which represents the sprite x-position).
								;	
	move.w	2(a5,d5.w),d2		;	Line 91: Performs the same as the instructions above but also has a fixed offset
								;	of 2 and moves the value to D2 (which represents the y-position of the
								;	sprite).
	lea.l	s8,a1				;	Line 92: Loads the effective address of "S8" (sprite data on sprite 8) into the Al.
	bsr	setspr					;	Line 93: Jumps to the routine "setspr" which sets the new sprite position.
								;	
	move.w	16(a5,d5.w),d1		;	Line 95-128: Repeat the process for sprite 7 to 1. The only thing which is different is
	move.w	18(a5,d5.w),d2		;	the fixed OFFSET in the coordinate table (move table). The result is
	lea.l	s7,a1				;	that we have a snake-like effect (displacement) when the sprite is
	bsr	setspr					;	moved.
								;	
	move.w	32(a5,d5.w),d1		;	
	move.w	34(a5,d5.w),d2		;	
	lea.l	s6,a1				;	
	bsr	setspr					;	
								;	
	move.w	48(a5,d5.w),d1		;	
	move.w	50(a5,d5.w),d2		;	
	lea.l	s5,a1				;	
	bsr	setspr					;	
								;	
	move.w	64(a5,d5.w),d1		;	
	move.w	66(a5,d5.w),d2		;
	lea.l	s4,a1				;
	bsr	setspr					;
								;
	move.w	80(a5,d5.w),d1		;
	move.w	82(a5,d5.w),d2		;
	lea.l	s3,a1				;
	bsr	setspr					;
								;
	move.w	96(a5,d5.w),d1		;
	move.w	98(a5,d5.w),d2		;
	lea.l	s2,a1				;
	bsr	setspr					;
								;
	move.w	112(a5,d5.w),d1		;
	move.w	114(a5,d5.w),d2		;
	lea.l	s1,a1				;	
	bsr	setspr					;	
	rts							;	Line 129: Jumps back to line 54, and continues with the next instruction (program
								;	line 56).
setspr:							;	Line 131: This routine updates sprite positions in sprite table of data.
	movem.l	d0-d5,-(a7)			;	Line 132: This variant of the MOVE is explained later in the “machine code”
	add.w	#$81,d1				;	chapter of this issue.
								;	Line 133: Adds the constant of $81 to the previous content of D1. In D1 the sprite
								;	x-position is stored. We must add $81 (129) to get to the 0-position and
								;	to be at the edge of the screen.
	add.w	#$2c,d2				;	Line 134: Adding $2C (44) to D2 (which contains sprite y-position). We use $2C
								;	to get to the 0 position – meaning to be on the top line of the screen.
	clr.l	d5					;	Line 135: Setting the register D5 to 0.
	move.b	d2,(a1)				;	Line 136: Moving the first byte of D2 into the address A1 points to.
	move.l	d2,d4				;	Line 137: Moving (i.e. copy as you know) the content of D2 to D4.
	lsr.w	#8,d4				;	Line 138: This instruction will be explained in machine code chapter. It shifts the
								;	content of the register 8 bits to the right so the high-byte is at the lobyte’s place.
	lsl.w	#2,d4				;	Line 139: Shifts the content of D4 2 bits to the left.
	add.w	d4,d5				;	Line 140: Adding D4 to D5.
	add.w	d3,d2				;	Line 141: Adding D3 to D2.
	move.b	d2,2(a1)			;	Line 142: Moving the low-byte (bit 0-7) from D2 to the address where A1 + 2
								;	points to. The value 2, which is added to the address in A2 is called an
								;	offset.
	move.l	d2,d4				;	Line 143: Copies the whole content of D2 (32bit) to register D4.
	lsr.w	#8,d4				;	Line 144: Shifts the lower 16 bit of D4 for 8 bits to the right.
	lsl.w	#1,d4				;	Line 145: Shifting the lower 16 bit of D4 1 bit to the left.
	add.w	d4,d5				;	Line 146: Adds the lower 16 bit of D4 to D5.
	move.l	d1,d3				;	Line 147: Moves the whole content of D1 (32 bit) to D3.
	andi.l	#1,d1				;	Line 148: Performs a logical AND to D1, masking out all bits but the first (bits 1-
								;	31 are set to 0).
	add.w	d1,d5				;	Line 149: Adds the lower 16 bit of Dl to D5.
	move.b	d5,3(a1)			;	Line 150: Moving the low-byte from D5 into the address A1+3 points to.
	lsr.l	#1,d3				;	Line 151: Shifts the content of D3 for 1 bit to the right.
	move.b	d3,1(a1)			;	Line 152: Moves the low-byte (bit 0-7) in D3 to the address, A1 +1 points to
	movem.l	(a7)+,d0-d5			;	Line 153: restore registers d0-d5 from stack (details in chapter on machine code)
	rts							;	Line 154: Go back after the last "bsr setspr" instruction and continue with the next
								;	instruction there.
copper:							;	Lines 156-203: The copper list is defined here. The first sprite pointer starts at program
	dc.w	$0120,$0000			;	line 157 ($DFF000 + $0120 = $DFF120). Please note that we put color
	dc.w	$0122,$0000			;	registers to the copper list (program line 181-198), you should be
	dc.w	$0124,$0000			;	familiar with the rest of the copper list.
	dc.w	$0126,$0000			;	
	dc.w	$0128,$0000			;	
	dc.w	$012a,$0000			;	
	dc.w	$012c,$0000			;	
	dc.w	$012e,$0000			;	
	dc.w	$0130,$0000			;	
	dc.w	$0132,$0000			;	
	dc.w	$0134,$0000			;
	dc.w	$0136,$0000			;
	dc.w	$0138,$0000			;
	dc.w	$013a,$0000			;
	dc.w	$013c,$0000			;
	dc.w	$013e,$0000			;
						
	dc.w	$2c01,$fffe			;
	dc.w	$0100,$1200			;
						
bplcop:						
	dc.w	$00e0,$0000			;
	dc.w	$00e2,$0000			;
						
	dc.w	$0180,$0000			;
	dc.w	$0182,$00ff			;
						
	dc.w	$01a2,$0f00			;
	dc.w	$01a4,$0fff			;
	dc.w	$01a6,$000b			;
						
	dc.w	$01aa,$0f00			;
	dc.w	$01ac,$0fff			;
	dc.w	$01ae,$000b			;
						
	dc.w	$01b2,$0f00			;
	dc.w	$01b4,$0fff			;
	dc.w	$01b6,$000b			;
						
	dc.w	$01ba,$0f00			;
	dc.w	$01bc,$0fff			;
	dc.w	$01be,$000b			;
							
	dc.w	$ffdf,$fffe			;	
	dc.w	$2c01,$fffe			;	
	dc.w	$0100,$0200			;	
	dc.w	$ffff,$fffe			;	
							
screen:							
	blk.l	2560				;	Line 206: At this line a block of memory (10240 bytes or 2560 long-words) for
								;	the screen (bitmaps) is reserved.
	; incbin "Screen"			; for asmone
s1:								;	Lines 208-359: Here the data for all sprites are defined one after another.
	dc.w $0000,$0000			;	
	dc.w $FF00,$0000			;	
	dc.w $FF80,$0000			;	
	dc.w $FFC0,$0000			;	
	dc.w $FFC0,$0020			;	
	dc.w $03C0,$7C20			;	
	dc.w $03C0,$0020			;
	dc.w $FF80,$0060			;
	dc.w $FF00,$00C0			;
	dc.w $F380,$0C00			;
	dc.w $F3C0,$0800			;
	dc.w $FFC0,$0020			;
	dc.w $FFC0,$0020			;
	dc.w $FF80,$0060			;
	dc.w $FF00,$00C0			;
	dc.w $0000,$7F80			;
	dc.w $0000,$0000			;
						
s2:						
	dc.w $0000,$0000			;
	dc.w $FF00,$0000			;
	dc.w $FF80,$0000			;
	dc.w $FFC0,$0000			;
	dc.w $FFC0,$0020			;
	dc.w $03C0,$7C20			;
	dc.w $03C0,$0020			;
	dc.w $FFC0,$0020			;
	dc.w $FFC0,$0020			;
	dc.w $FF00,$00E0			;
	dc.w $FF80,$0000			;
	dc.w $F7C0,$0800			;
	dc.w $F3C0,$0820			;
	dc.w $F3C0,$0820			;
	dc.w $F3C0,$0820			;
	dc.w $0000,$79E0			;
	dc.w $0000,$0000			;
						
s3:						
	dc.w $0000,$0000			;
	dc.w $FFC0,$0000			;
	dc.w $FFC0,$0020			;
	dc.w $FFC0,$0020			;
	dc.w $FFC0,$0020			;
	dc.w $0000,$7FE0			;
	dc.w $0000,$0000			;
	dc.w $FF00,$0000			;
	dc.w $FF00,$0080			;
	dc.w $F000,$0F80			;
	dc.w $F000,$0800			;
	dc.w $FFC0,$0000			;
	dc.w $FFC0,$0020			;
	dc.w $FFC0,$0020			;
	dc.w $FFC0,$0020			;
	dc.w $0000,$7FE0			;
	dc.w $0000,$0000			;
						
s4:						
	dc.w $0000,$0000			;
	dc.w $F3C0,$0000			;
	dc.w $F3C0,$0820			;
	dc.w $F3C0,$0820			;
	dc.w $F3C0,$0820			;
	dc.w $F3C0,$0820			;
	dc.w $F3C0,$0820			;
	dc.w $F3C0,$0820			;
	dc.w $F3C0,$0820			;
	dc.w $FFC0,$0020			;
	dc.w $FFC0,$0020			;
	dc.w $7F80,$0060			;
	dc.w $3F00,$00C0			;
	dc.w $1E00,$0180			;
	dc.w $0C00,$0300			;
	dc.w $0000,$0600			;
	dc.w $0000,$0000			;
						
s5:						
	dc.w $0000,$0000			;
	dc.w $F3C0,$0000			;
	dc.w $F3C0,$0820			;
	dc.w $F3C0,$0820			;
	dc.w $F3C0,$0820			;
	dc.w $03C0,$7820			;
	dc.w $03C0,$0020			;
	dc.w $FF00,$00E0			;
	dc.w $FF80,$0000			;
	dc.w $F3C0,$0C00			;
	dc.w $F3C0,$0820			;
	dc.w $F3C0,$0820			;
	dc.w $F3C0,$0820			;
	dc.w $F3C0,$0820			;
	dc.w $F3C0,$0820			;
	dc.w $0000,$79E0			;
	dc.w $0000,$0000			;
						
s6:						
	dc.w $0000,$0000			;
	dc.w $F3C0,$0000			;
	dc.w $F3C0,$0820			;
	dc.w $F3C0,$0820			;
	dc.w $F3C0,$0820			;
	dc.w $F3C0,$0820			;
	dc.w $F3C0,$0820			;
	dc.w $F3C0,$0820			;
	dc.w $F3C0,$0820			;
	dc.w $F3C0,$0820			;
	dc.w $F3C0,$0820			;
	dc.w $FFC0,$0020			;
	dc.w $FFC0,$0020			;
	dc.w $7F80,$0060			;
	dc.w $3F00,$00C0			;
	dc.w $0000,$1F80			;
	dc.w $0000,$0000			;
						
s7:						
	dc.w $0000,$0000			;
	dc.w $FF00,$0000			;
	dc.w $FF80,$0000			;
	dc.w $FFC0,$0000			;
	dc.w $FFC0,$0020			;
	dc.w $03C0,$7C20			;
	dc.w $03C0,$0020			;
	dc.w $FFC0,$0020			;
	dc.w $FFC0,$0020			;
	dc.w $FF00,$00E0			;
	dc.w $FF80,$0000			;
	dc.w $F7C0,$0800			;
	dc.w $F3C0,$0820			;
	dc.w $F3C0,$0820			;
	dc.w $F3C0,$0820			;
	dc.w $0000,$79E0			;
	dc.w $0000,$0000			;
						
s8:						
	dc.w $0000,$0000			;
	dc.w $3FC0,$0000			;
	dc.w $7FC0,$0020			;
	dc.w $FFC0,$0020			;
	dc.w $FFC0,$0020			;
	dc.w $0000,$7FE0			;
	dc.w $0000,$0000			;
	dc.w $3F00,$0000			;
	dc.w $3F80,$0000			;
	dc.w $03C0,$1C00			;
	dc.w $03C0,$0020			;
	dc.w $FFC0,$0020			;
	dc.w $FFC0,$0020			;
	dc.w $FF80,$0060			;
	dc.w $FF00,$00C0			;
	dc.w $0000,$7F80			;
	dc.w $0000,$0000			;
	dc.w $0000,$0000			;	
								;	
movetable:						;	
	;incbin	"movetable"			; for asmone
	blk.l	3100				; "Line 362: Here we have reserved a block of memory (12400 bytes or 3100 longwords) 
								; to keep the coordinates of the sprites."
								;	To run this example, read the file "SCREEN" into the display buffer (labeled "screen" in the
								;	source) and the file "MOVETABLE" into "movetable" buffer as follows:
								;	Seka> ri
								;	FILENAME> screen
								;	BEGIN> screen
								;	END> (press RETURN or write -1 (logical END OF FILE))
								;	Seka> ri
								;	FILENAME> movetable
								;	BEGIN> movetable
								;	END> (press enter or return -1 (logical END OF FILE))
								;	It is also possible to make your own movement table or "waves". This is done with a program
								;	that is on the course disk 1.
								;	Boot from the course disk
								;	Put in a floppy disk you want to store your "wave"-data on, for example to "DF1:" and enter
								;	at the command line:
								;	1> wavegen DF1:mywave
								;	The screen gets black and the machine is waiting for the left mouse button.
								;	After pressing the mouse button the program starts the "recording" of your mouse movements.
								;	Move the mouse around the screen. When you are satisfied with the pattern, press again the
								;	mouse button and the recorded movement-data is stored onto disk.
								;	Note that one second of movement, use 200 bytes of your memory.
								;	When you finish this, go into the K-Seka again. Assemble your program and load your own
								;	file (df1:mywave) instead to the label "movetable". Please note that you must adjust the value
								;	at line 78 in the program to the actual length of your file. It may also be necessary to adjust
								;	the buffer size of line 362 (if your file is longer than 12400 bytes).
	end

