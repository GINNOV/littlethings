; mc0501.s 				; norwegian sprite
; from disk1/brev05
; explanation on letter_05.pdf / p.02
; from Mark Wrobel course letter 16	

; SEKA>ks	; (optional)
; Sure? y
; SEKA>r
; FILENAME>mc0501.s
; SEKA>a
; OPTIONS>
; No errors
; SEKA>ri
; FILENAME>screen
; BEGIN>screen
; END>
; SEKA>j
	
start:							; comments from Mark Wrobel
	move.w	#$4000,$dff09a		; INTENA - clear external interrupt

	or.b	#%10000000,$bfd100	; CIABPRB stops drive motors
	and.b	#%10000111,$bfd100	; CIABPRB

	move.w	#$01a0,$dff096		; DMACON clear bitplane, copper, sprite

	move.w	#$1200,$dff100		; BPLCON0 one bitplane, color burst
	move.w	#$0000,$dff102		; BPLCON1 scroll
	move.w	#$003f,$dff104		; BPLCON2 video
	move.w	#0,$dff108			; BPL1MOD bitplane modulo odd planes
	move.w	#0,$dff10a			; BPL2MOD bitplane modulo even planes
	move.w	#$2c81,$dff08e		; DIWSTRT upper left corner of display ($81,$2c)
	;move.w	#$f4c1,$dff090		; DIWSTOP enable PAL trick
	move.w	#$38c1,$dff090		; DIWSTOP lower right corner of display ($1c1,$12c)
	move.w	#$0038,$dff092		; DDFSTRT Data fetch start
	move.w	#$00d0,$dff094		; DDFSTOP Data fetch stop

	lea.l	sprite,a1			; put sprite address into a1
	lea.l	copper,a2			; put copper address into a2
	move.l	a1,d1				; move sprite address into d1
	move.w	d1,6(a2)			; transfer sprite address high to copper
	swap	d1					; swap
	move.w	d1,2(a2)			; transfer sprite address low to copper

	lea.l	blanksprite,a1		; put blanksprite address into a1
	lea.l	copper,a2			; put copper address into a2
	add.l	#10,a2				; add 10 to copper address in a2
	move.l	a1,d1				; move blanksprite address into d1
	moveq	#6,d0				; setup sprite counter

sprcoploop:						; set all 7 sprite pointers
	swap	d1					; high and low to point to blanksprite 
	move.w	d1,(a2)
	addq.l	#4,a2
	swap	d1
	move.w	d1,(a2)
	addq.l	#4,a2
	dbra	d0,sprcoploop		; loop trough all 7 sprite pointers

	lea.l	screen,a1			; put screen address into a1
	lea.l	bplcop,a2			; put bplcop address into a2
	move.l	a1,d1				; transfer screen address to bplcop
	move.w	d1,6(a2)
	swap	d1
	move.w	d1,2(a2)

	lea.l	copper,a1			; put copper address into a1
	move.l	a1,$dff080			; COP1LCH (also sets COP1LCL)
	move.w	$dff088,d0			; COPJMP1 
	move.w	#$81a0,$dff096		; DMACON set bitplane, copper, sprite

wait:							; wait until at beam line 0
	move.l	$dff004,d0			; read VPOSR and VHPOSR into d0 as one long word
	asr.l	#8,d0				; shift right 8 places
	and.l	#$1ff,d0
	cmp.w	#0,d0
	bne	wait					; if not equal jump to wait

wait2:							; wait until at beam line 1
	move.l	$dff004,d0			; read VPOSR and VHPOSR into d0 as one long word
	asr.l	#8,d0
	and.l	#$1ff,d0
	cmp.w	#1,d0
	bne	wait2					; if not equal jump to wait

	bsr	movesprite				; branch to subroutine movesprite

	btst	#6,$bfe001			; test left mouse left mouse click
	bne	wait					; if not pressed jump to wait

	move.w	#$0080,$dff096		; reestablish DMA's and copper

	move.l	$04,a6
	move.l	156(a6),a1
	move.l	38(a1),$dff080

	move.w	#$8080,$dff096
	move.w	#$c000,$dff09a
	rts

movesprite:						; movesprite subroutine
	lea.l	sprite,a1
	cmp.b	#250,2(a1)			; sprite bottom line at 250
	bne	notbottom				; if not go to notbottom

	move.b	#30,(a1)
	move.b	#44,2(a1)

notbottom:
	add.b	#1,(a1)				; move sprite top line by 1
	add.b	#1,2(a1)			; move sprite bottom line by 1
	rts							; return from subroutine

copper:
	dc.w	$0120,$0000			; SPR0PTH
	dc.w	$0122,$0000			; SPR0PTL
	dc.w	$0124,$0000			; SPR1PTH
	dc.w	$0126,$0000			; SPR1PTL
	dc.w	$0128,$0000			; SPR2PTH
	dc.w	$012a,$0000			; SPR2PTL
	dc.w	$012c,$0000			; SPR3PTH
	dc.w	$012e,$0000			; SPR3PTL
	dc.w	$0130,$0000			; SPR4PTH
	dc.w	$0132,$0000			; SPR4PTL
	dc.w	$0134,$0000			; SPR5PTH
	dc.w	$0136,$0000			; SPR5PTL
	dc.w	$0138,$0000			; SPR6PTH
	dc.w	$013a,$0000			; SPR6PTL
	dc.w	$013c,$0000			; SPR7PTH
	dc.w	$013e,$0000			; SPR7PTL

	dc.w	$2c01,$fffe
	dc.w	$0100,$1200

bplcop:
	dc.w	$00e0,$0000			; BPL1PTH
	dc.w	$00e2,$0000			; BPL1PTL

	dc.w	$0180,$0000			; COLOR00 black
	dc.w	$0182,$0ff0			; COLOR01 yellow
	dc.w	$01a2,$0f00			; COLOR17 sprite0 red 
	dc.w	$01a4,$0fff			; COLOR18 sprite0 white
	dc.w	$01a6,$000b			; COLOR19 sprite0 blue

	dc.w	$ffdf,$fffe			; wait enables waits > $ff vertical
	dc.w	$2c01,$fffe			; wait for line - $2c is $12c
	dc.w	$0100,$0200			; BPLCON0 unset bitplanes, enable color burst
								; needed to support older PAL chips
	dc.w	$ffff,$fffe			; end of copper

screen:
	blk.b	10240,0				; allocate 1 kb of memory and set it to zero
	;incbin "Screen"			; for asmone

sprite:
	dc.w	$1e8c,$2c00
	dc.w	$FB7F,$0780 ; %1111 1011 0111 1111, %0000 0111 1000 0000
	dc.w	$FB7F,$0780 ; %1111 1011 0111 1111, %0000 0111 1000 0000
	dc.w	$FB7F,$0780 ; %1111 1011 0111 1111, %0000 0111 1000 0000
	dc.w	$FB7F,$0780 ; %1111 1011 0111 1111, %0000 0111 1000 0000
	dc.w	$FB7F,$0780 ; %1111 1011 0111 1111, %0000 0111 1000 0000
	dc.w	$0300,$FFFF ; %0000 0011 0000 0000, %1111 1111 1111 1111
	dc.w	$FFFF,$FFFF ; %1111 1111 1111 1111, %1111 1111 1111 1111
	dc.w	$FFFF,$FFFF ; %1111 1111 1111 1111, %1111 1111 1111 1111
	dc.w	$0300,$FFFF ; %0000 0011 0000 0000, %1111 1111 1111 1111
	dc.w	$FB7F,$0780 ; %1111 1011 0111 1111, %0000 0111 1000 0000
	dc.w	$FB7F,$0780 ; %1111 1011 0111 1111, %0000 0111 1000 0000
	dc.w	$FB7F,$0780 ; %1111 1011 0111 1111, %0000 0111 1000 0000
	dc.w	$FB7F,$0780 ; %1111 1011 0111 1111, %0000 0111 1000 0000
	dc.w	$FB7F,$0780 ; %1111 1011 0111 1111, %0000 0111 1000 0000
	dc.w	$0000,$0000 ; %0000 0000 0000 0000, %0000 0000 0000 0000
	dc.w	$0000,$0000 ; %0000 0000 0000 0000, %0000 0000 0000 0000

blanksprite:
	dc.w	$0000,$0000			; an empty sprite

	end

;------------------------------------------------------------------------------

start:							; comments from letter letter_05 p. 02
	move.w	#$4000,$dff09a		; 9a	INTENA		Line 1: This MOVE switches off all interrupts. The whole system is "frozen" so
								; that only our program runs. Interrupts will be examined and explained
								; in issue IX.
	or.b	#%10000000,$bfd100	; Line 3-4: If you start a program directly from the disk and turn off all interrupts it
	and.b	#%10000111,$bfd100	; has the effect that the disk station does not stop by itself when program
								; is read and immediately started. We solve this problem stopping the
								; motor inside our program. This will be explained in detail in the issue X.
	move.w	#$01a0,$dff096		; 96	DMACON		Lines 6-17: These lines set up a screen (bitmap) and should be already known.
							
	move.w	#$1200,$dff100		; 100	BPLCON0		
	move.w	#$0000,$dff102		; 102	BPLCON1		
	move.w	#$003f,$dff104		; 104	BPLCON2		
	move.w	#0,$dff108			; 108	BPL1MOD		
	move.w	#0,$dff10a			; 10a	BPL2MOD		
	move.w	#$2c81,$dff08e		; 8e	DIWSTRT		
	;move.w	#$f4c1,$dff090		; 90	DIWSTOP		
	move.w	#$38c1,$dff090		; 90	DIWSTOP		
	move.w	#$0038,$dff092		; 92	DDFSTRT		
	move.w	#$00d0,$dff094		; 94	DDFSTOP		
						
	lea.l	sprite,a1			; Lines 19-24: Adds sprite addresses into copper-list sprite pointers (sprites are
	lea.l	copper,a2			; numbered from 0 to 27). A sprite pointer is like a bitplane-pointer
	move.l	a1,d1				; divided into high and low address.
	move.w	d1,6(a2)			;			
	swap	d1					;			
	move.w	d1,2(a2)			;			
						
	lea.l	blanksprite,a1		; Line 26-39: Retrieving the address of the "blank" (or empty) sprite and put it in the
	lea.l	copper,a2			; copper list area to the sprites for sprite 1-7. You should configure all 8
	add.l	#10,a2				; sprites, even if you only want to use one.
	move.l	a1,d1					
	moveq	#6,d0							
							
sprcoploop:						;			
	swap	d1					;			
	move.w	d1,(a2)				;			
	addq.l	#4,a2				;			
	swap	d1					;			
	move.w	d1,(a2)				;			
	addq.l	#4,a2				;			
	dbra	d0,sprcoploop		;			
							
	lea.l	screen,a1			; Line 41-51: These lines retrieve the address to the screen and put it in copper list.
	lea.l	bplcop,a2			; Then the copper-DMA, the biplane-DMA and sprite-DMA is started.
	move.l	a1,d1				; Note the program line 50 – you might not have seen this MOVE to this
	move.w	d1,6(a2)			; address before. It is not entirely necessary but it should be in order to
	swap	d1					; ensure that the copper list is truly started at all Amiga (also in future).
	move.w	d1,2(a2)			;			
							
	lea.l	copper,a1			;			
	move.l	a1,$dff080			; 80	COP1LCH		
	move.w	$dff088,d0			; 88	COPJMP1		
	move.w	#$81a0,$dff096		; 96	DMACON		
							
wait:							; Line 53-58: This little routine will have the processor to wait until the electron beam
	move.l	$dff004,d0			; 04	VPOSR		reaches line 0. Remember that line 0 is not visible and it’s not the
	asr.l	#8,d0				; bitmap’s top line but the screen’s top line – the upper line on bitmap is
	and.l	#$1ff,d0			; usually line 44 ($2C). Imagine that the line 0 lies above the monitor’s
	cmp.w	#0,d0				; plastic edge. The screen lines 0-19 is often called the “verticalblanking”.
	bne	wait					;			
								;			
wait2:							; Line 60-65: This routine waits for the electron beam to reach line 1. The reason why
	move.l	$dff004,d0			; 04	VPOSR		we wait on line 0, and then line 1 is that if we just waiting in line 20, we
	asr.l	#8,d0				; risk getting an uneven movement of the sprite. The main routine
	and.l	#$1ff,d0			; performs so fast that when jumping back
	cmp.w	#1,d0				; to program line 53 (wait:), there is some possibility that the electron
	bne	wait2					; beam is still drawing line 0 - the Amiga is a fast computer!
							
	bsr	movesprite				; Line 67: This instruction jumps to the move sprite routine and jumps back again
								; when the processor encounters the RTS. For those who have knowledge
								; of BASIC: this instruction can be compared to the GOSUB and
								; RETURN instructions. The instruction will be reviewed in the section
								; about “machine code” in this issue.
							
	btst	#6,$bfe001			; CIA		Lines 69-70: Check if the left mouse button is pressed. If not, then jump back to label
	bne	wait					; wait.
							
	move.w	#$0080,$dff096		; 96	DMACON		Line 72: Turns off the copper DMA.
								
	move.l	$04,a6				; Line 74-76: Retrieving the address of the old copper list (that one which belongs to
	move.l	156(a6),a1			; the Workbench) and puts it into the copper-pointer.
	move.l	38(a1),$dff080		; 80	COP1LCH		
							
	move.w	#$8080,$dff096		; 96	DMACON		Line 78: Starts copper-DMA again.
							
	move.w	#$c000,$dff09a		; 9a	INTENA		Line 80: This MOVE enables all interrupts again.
	rts							;			Line 81: Exits the program.
									
					
movesprite:						; Line 84-94: This routine moves the sprite on the screen. View explanation below.
	lea.l	sprite,a1			;			
	cmp.b	#250,2(a1)			;			
	bne	notbottom				;			
							
	move.b	#30,(a1)			;			
	move.b	#44,2(a1)			;			
							
notbottom:						;			
	add.b	#1,(a1)				;			
	add.b	#1,2(a1)			;			
	rts						
							
copper:						; Line 97-130: The copper-list.
	dc.w	$0120,$0000		;			
	dc.w	$0122,$0000		;			
	dc.w	$0124,$0000		;			
	dc.w	$0126,$0000		;			
	dc.w	$0128,$0000		;			
	dc.w	$012a,$0000		;			
	dc.w	$012c,$0000		;			
	dc.w	$012e,$0000		;			
	dc.w	$0130,$0000		;			
	dc.w	$0132,$0000		;			
	dc.w	$0134,$0000		;			
	dc.w	$0136,$0000		;			
	dc.w	$0138,$0000		;			
	dc.w	$013a,$0000		;			
	dc.w	$013c,$0000		;			
	dc.w	$013e,$0000		;			
							
	dc.w	$2c01,$fffe		;			
	dc.w	$0100,$1200		;			
							
bplcop:							
	dc.w	$00e0,$0000		;			
	dc.w	$00e2,$0000		;			
						
	dc.w	$0180,$0000		;			
	dc.w	$0182,$0ff0		;			
	dc.w	$01a2,$0f00		;			
	dc.w	$01a4,$0fff		;			
	dc.w	$01a6,$000b		;			
							
	dc.w	$ffdf,$fffe		;			
	dc.w	$2c01,$fffe		;			
	dc.w	$0100,$0200		;			
	dc.w	$ffff,$fffe		;			
							
screen:						; Lines 132-133: Here is our memory four our screen defined.
	blk.b	10240			;			
							;			
sprite:						; Line 136-152: Sprite data is defined here (explained below.).
	dc.w	$1e8c,$2c00		;			
	dc.w	$FB7F,$0780		;			
	dc.w	$FB7F,$0780		;			
	dc.w	$FB7F,$0780		;			
	dc.w	$FB7F,$0780		;			
	dc.w	$FB7F,$0780		;			
	dc.w	$0300,$FFFF		;			
	dc.w	$FFFF,$FFFF		;			
	dc.w	$FFFF,$FFFF		;			
	dc.w	$0300,$FFFF		;			
	dc.w	$FB7F,$0780		;			
	dc.w	$FB7F,$0780		;			
	dc.w	$FB7F,$0780		;			
	dc.w	$FB7F,$0780		;			
	dc.w	$FB7F,$0780		;			
	dc.w	$0000,$0000		;			
	dc.w	$0000,$0000		;			
				;			
blanksprite:				; Lines 154-155: Here's the "blank" sprite defined. Study the sprite data in the example.
	dc.w	$0000,$0000		; As you see the first longword (2 words) are set to 0. This longword
				;			contains the position word, the position the sprite will have on the
				;			screen. Lines 84-94 update these values, so that the sprite moves around
				;			the screen. Let us now look at sprite data:
				;			LONGWORD 1: position and height of the sprite
				;			LONGWORD 2: graphics data
				;			LONGWORD 3: graphics data
				;			LONGWORD 4: graphics data
				;			... (as high as you want)
				;			LONGWORD ?: must be 0 (the last data line)
				;			We divide the first longword in bytes:
				;			LONGWORD: $00 00, $00 00
				;			BYTE-NR.: 0 1 2 3
				;			BYTE 0: Bit 0-7 defines the vertical position of the sprite’s top line.
				;			BYTE 1: Does the bit 1-8 in the horizontal position of sprite left edge.
				;			BYTE 2: Does the bit 0-7 for the vertical position of the sprite bottom line.
				;			BYTE 3: Bit 0 contains bit 0 of the horizontal position of the sprite’s left edge.
				;			Bit 1 contains bit 8 of the vertical position of the sprite’s bottom line.
				;			Bit 2 contains bit 8 for the vertical position of top line of sprite.
				;			Bit 3-6 are not used.
				;			Bit 7 is explained in issue XII. The bit is used to indicate "16 colors" sprite (1 =
				;			16 colors, and 0 = 4 colors).


line 116:	move.w	#$1200,$dff100	?$1200	=	0001 0010 0000 0000			BIT 12 - 14:  001 -
								This is a 3-bit group to specify how many bitplanes are used.
								1 Plane - 2 colors
								BIT 9 - 1
								This bit will be set to “1” to get the color signal video output (no effect on A500).
