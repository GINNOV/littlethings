; mc0901.s			; toggle Power LED with F10 (by keyboard interrupt)
; from disk1/brev09
; explanation on letter_09.pdf / p.08
; from Mark Wrobel course letter 25		
	
; SEKA>ks	; (optional)
; Sure? y
; SEKA>r
; FILENAME>mc0901.s
; SEKA>a
; OPTIONS>
; No errors
; SEKA>j	
	
start:							; comments from Mark Wrobel
	lea.l	jump,a1				; move address of jump into a1
	move.l	$68,2(a1)			; move value in address $68 (interupt 2)
								; into memory pointed to by a1+2

	moveq	#100,d0				; move 100 into d0

	moveq	#1,d1				; move 1 into d1
	swap	d1					; swap words in d1, value is now $10000 
	move.l	$4,a6				; move value (ExecBase of exec.library) in address $4 into a6
	jsr	-198(a6)				; Jump to subroutine AllocMem in exec.library, d0 = AllocMem(d0, d1),
								; allocate 100 bytes with type of memory MEMF_CLEAR.
	move.l	d0,a1				; put address of allocated memory stored in d0 into a1
	move.l	d0,d7				; put address of allocated memory stored in d0 into d7

	lea.l	interrupt,a0		; move address of interrupt into a0
	moveq	#24,d0				; set d0 to 24. Use d0 as a copyloop counter

copyloop:
	move.l	(a0)+,(a1)+			; copy value pointed to by a0 into address pointed to by a1.
								; Increment both with 4 bytes (1 long word)
	dbra	d0,copyloop			; if d0 > -1 goto copyloop

	move.w	#$4000,$dff09a		; INTENA Interupt enable bits - disable all interrupts
	move.l	d7,$68				; move value in d7 that points to our allocated memory into $68 (interupt 2)
	move.w	#$c000,$dff09a		; INTENA Interupt enable bits - enable all interrupts

	rts							; return from subroutine (main program)

interrupt:						; begin interrupt handler routine
	move.l	d0,-(a7)			; push value in d0 onto the stack
	move.b	$bfec01,d0			; read a byte from CIAA serial data register connected to keyboard into d0
	not.b	d0					; negate a byte in d0
	ror.b	#1,d0				; rotate right 1 bit

	cmp.b	#$59,d0				; compare F10 key value with d0
	bne.s	wrongkey			; if not F10 pressed - goto wrongkey

	bchg	#1,$bfe001			; Test bit and change. Bit 1 is power LED

wrongkey:
	move.l	(a7)+,d0			; pop the stack and put value into d0 - 
								; reestablish d0 to it's previous value

jump:
	jmp	$0						; the jump was previously set to the value in address $68 (interrupt 2)
								; so this interupt function is linked together with the previous one
	end

;------------------------------------------------------------------------------

start:					; comments from letter letter_09 p. 08
	lea.l	jump,a1		; Line 1: loads the effective address of the "jump" into A1. Notice that the label "jump"
						; points to an instruction (program line 42)
	move.l	$68,2(a1)	; Line 2: moves the value, located at address $68, to the address A1 +2 are pointing to.
						; This instruction moves a value into the instruction at program line 42:
	moveq	#100,d0		; First we get the value which is located at address $68. This address contains
						; a pointer (vector) to the INTERRUPT level-2 routine - which will be stored
						; to the JMP instruction at program line 42. The JMP instruction performs a
						; jump like the BRA. The difference between these two is that BRA uses an
						; offset from the current instruction location, while JMP jumps directly to a
						; given address (absolute address – see also the machine code chapter later in
						; this issue). As you look at line 42, this JMP instruction is initially set to address
						; $0. When we have done this MOVE instruction the JMP instruction will have a
						; new address - the address which points to the old interrupt routine.
						; Line 4: Moves quickly the constant value of 100 to register D0.
	moveq	#1,d1		; Line 6: Moves quickly the constant value of 1 to register D1.
	swap	d1			; Line 7: Swapping the Word in D1. This leads to D1 containing $10000
	move.l	$4,a6		; Line 8: Moves the value from address $4 into the A6.
	jsr	-198(a6)		; Line 9: This is a new instruction. JSR means jump to sub routine, or jump to (see also
						; machine code chapter in this issue). In a issue X, we will work in detail on JSR
						; commands. In all simplicity what lines 4 to 9 do is to allocate memory of 100
						; bytes. This means that we ask the operating system to reserve a memory block
						; of 100 Bytes for us. Doing so we obtained a place in memory where
						; the interrupt routine can be safe. Do not worry so much about it right now - it's
						; important to understand how interrupt routines work, but to know where in
						; memory it is located.
	move.l	d0,a1		; Line 11: Moves the value of D0 into A1. The routine (system routine for memory
						; allocation) which was performed by program line 9, returns the address of the
						; reserved memory block in d0. This address points to the first byte of the 100
						; byte block which was allocated.
	move.l	d0,d7		; Line 12: Moves the value in D0 into D7.
						;		
	lea.l	interrupt,a0; Line 14: Loads the effective address of "interrupt" into A0.
	moveq	#24,d0		; Line 15: Moves the constant value of 24 quickly into D0. It is used as a counter.
						;			
	copyloop:			;			
						;			
	move.l	(a0)+,(a1)+	; Line 18: Copies the long value, A0 points to, to the address A1 points to. Then both
						; both addresses (in a0 and a1) are increased by 4 bytes or 1 long word.
	dbra	d0,copyloop	; Line 19: Subtracts the value 1 from D0 and check if D0 is negative - if not branching
						; back to the label "copy loop". After finishing this loop the "interrupt"-routine
						; (program line 28 to 42) was copied into the "block" of memory that we
						; allocated earlier.
	move.w	#$4000,$dff09a	; 9a	INTENA		Line 21: Turns off all interrupts.
	move.l	d7,$68		; Line 22: Moves the value which lies in D7 in to address $68. The address of the
						; memory block that we allocated earlier and we copied our interrupt routine to,
						; is put into the pointer for interrupt level 2. Notice that we switched off all
						; interrupts in the previous line. This must be done before you submit a new
						; value into the interrupt vectors.
	move.w	#$c000,$dff09a		; 9a	INTENA		Line 23: Turns on all interrupts again. Now our interrupt routine is called when there is
						; a signal for an interrupt level 2. When our interrupt routine is executed, it will
						; not return to the main program - but through the JMP instruction at line 42 -
						; jump to the old interrupt routine (which belongs to the operating system). This
						; allows us to keep the operating system intact. So we have just "sneaked" our
						; own interrupt routine before entering the operating system's own interrupt
						; routine. This is known to link or hook into a routine.
	rts					; Line 25: Ends the program (NOTE: Interrupt routine does not finish).
						;			
interrupt:				; Line 27: Here is our custom interrupt routine.
	move.l	d0,-(a7)	; Line 28: Stores the value in D0 onto the stack. We do not need a MOVEM instruction
						; here, because we only need to store a single register. MOVEM is used only
						; when we want to store more registers at a time.
	move.b	$bfec01,d0	; Line 29: Moves the byte value located at address $BFEC01 into D0. This address
						; contains the codes to be sent from the keyboard when you press a key. We will
						; explain this register in more detail in issue XI.
	not.b	d0			; Line 30: Inverts the byte in register D0.
	ror.b	#1,d0		; Line 31: Rotating the byte in D0 by 1 bit to the right. More detailed explanation of this
						; instruction can be read in the machine code chapter.
	cmp.b	#$59,d0		; Line 33: D0 is compared with the constant value of 59.
	bne.s	wrongkey	; Line 34: If D0 was not 59, jump to the label "wrongkey". Program lines 29 to 34 reads
						; the keyboard and checking whether a special key has been pressed.
	bchg	#1,$bfe001	; Line 36: This instruction does a bit change. It inverts bit 1 at address $BFE001. Bit 1 of
						; this address controls the "POWER" led which respectively is switched on and
wrongkey:				; off. This instruction will therefore result in a change of the power-led. This
						; instruction is also explained in machine code chapter.
	move.l	(a7)+,d0	; Line 39: Restoring the old contents of D0 from the stack.
						;			
jump:					;			
	jmp	$0				; Line 42: Jumps to the old interrupt routine.
						; To run this program, you must assemble it as usual. Then all you need is the command "j" to
						; start it. After you run the program, try pressing "F10" while looking at the "POWER" lamp.
						; That was the chapter on INTERRUPTS. We may mention that in issue XII some slightly
						; more complicated INTERRUPT routines are explained (for MIDI) which will take care of
						; automatically sending and receiving data on the serial port.
	end
	