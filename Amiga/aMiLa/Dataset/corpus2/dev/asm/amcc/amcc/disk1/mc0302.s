; mc0302.s
; only on letter_03 p. 07

; SEKA>ks	; (optional)
; Sure? y
; SEKA>r
; FILENAME>mc0302.s
; SEKA>a
; OPTIONS>
; No errors
; SEKA>j

start:
								; So we throw ourselves into the machine code again. We make a small program that loads the
								; content of the first 16 memory addresses of the Amiga. Then we put them somewhere else in
								; the machine memory in a buffer, which we have reserved ourselves.
								; We show two examples of the same program. The first is a bit clumsy but for clarity’s sake
								; (anyway correctly working), and second is slightly more advanced: shorter, faster and smarter.
								; Here is the first version:
	move.l #16,d0				; Line 1: Move the decimal number 16 into D0. This register is used as a counter in this
								; routine. We need that the loop should be executed a certain number of times
								; (here: 16 times). The character "#" indicates that the following number is a
								; constant and not an address. In line 6 for instance: add the following constant
								; number (1); in line 9: subtract following constant number (1), and in line 10:
								; compare the following constant number (0) with the register D0.
	move.l #$00,a0				; Line 2: Moves the constant number of $00 into the address register A0. Note that
								; longword is used for this operation which will reset all bits (32bit) of the
								; address register A0. This address register is used as a pointer (the pointer,
								; points at address $000000): the address that we will read from.
	lea.l buffer,a1				; Line 3: Loads the effective address of our buffer (see line 14) into A1. In other words:
								; We defined a part of Amiga memory at line 15 to be uses as a buffer for our
								; data. This part of memory starts at the address (after our program) where the
								; label "buffer" is located. It therefore represents the beginning of our buffer).
								; The address register A1 is used as a pointer where we want to store our data.
								; Please note that we do not change anything - we only read. The data is simply
								; copied into our buffer.
loop:							; Line 4: The label "loop".
	move.b (a0),d1				; Line 5: Copies the byte located at the address in address register A0 into the data
								; register D1. The round brackets around A0 mean that not the content of the
								; rgister is to copied, but the byte the register points to. This way of address
								; register use is called: REGISTER INDIRECT (indirect addressing) and is used
								; very often in MC on the Amiga.
	add.l #1,a0					; Line 6: Increasing the address in A0 by "1". This leads to A0 pointing to the next byte,
								; we will read.
	move.b d1,(a1)				; Line 7: Moves the byte from D1, to the location the address register A1 points to
								; (which is our buffer). View comments LINIE 5
	add.l #1,a1					; Line 8: Increase the address in A1 by "1". This leads to A1 pointing to the next free
								; byte in our buffer we can write to.
	sub.l #1,d0					; Line 9: Subtract the constant number "1" from D0. This is our counter, which is
								; reduced by one each time we copy our byte into our buffer - a total of 16 times.
	cmp.l #0,d0					; Line 10: Check the content of D0 if it is "0" CMP means "compare" and is used here to
								; see if we have already copied 16 bytes (this is the case when D0 is "0").
	BNE loop					; Line 11: If D0 is not equal to "0", the program jumps back to our label "loop" (line 4). If
								; D0 is equal to "0", the loop was already executed 16 times and the program
								; will not jump back. Instead the program provides with the next instruction.
	RTS							; Line 12: RETURN FROM SUBROUTINE (or quit), and give control back to the calling
								; instance (here: K-Seka).
buffer:							; Line 14: The label that identifies the beginning of our own buffer.
	blk.b 16,0					; Line 15: Here we have declared 16 bytes for our buffer. We could also have written:
								; blk.l 4.0 or blk.w 8.0.
								; It would be the same result. BLK stands for "block" and 4.0 (and 8.0) shows the number of
								; longwords (or number of words), we want to reserve as a buffer. The number "0" indicates the
								; pattern the free memory is filled with so that we get an empty buffer (so old data from the past
								; should be cleared). See also next section.

	end



Let us look at some new instructions:

CMP (compare)
BNE, BEQ, BHL, BLO (different "branch" commands)
BLK, DC (BLOCK and DECLARE commands)

We will first review the status register before we go through these instructions.
STATUS REGISTER
MSB LSB
CONTENTS: X N Z V C

This is part of the so-called STATUS REGISTER of our CPU (MC68000). We will not
read or write directly into this register. You do not know what bit numbers the
various "flags" have. Everything you need to know is the flags that are set what
they used for. The term FLAG is just another word for a bit which indicates a
certain condition or event.

The flags of the status register:
C - carry flag (indicator when an arithmetic carry or borrow has been generated)
V - overflow flag (warning, the figure was too large)
Z - zero flag (something has been zero)
N - negative flag (the number is negative)
X - extend flag (special purpose)

When flag is "1", the condition is true. Imagine a long-jump competition. The
referee will raise a red flag every time there is a violation - and white if the
jump is valid.

Here comes the second version of our program:

	move.l #15,d0		; Line 1: Moves the constant number of 15 into D0.
						; Here, D0 is used again as a counter.
	move.l #$00,a0		; Line 2: Moves the constant number of $00 into A0
						; (A0 points to address $000000)
	lea.l buffer,a1		; Line 3: loads the effective address of our buffer into A1.
loop:					; Line 4: The label "loop".
	move.b (a0)+,(a1)+	; Line 5: Replacing lines 5,6,7 and 8 in the second example.
	dbra d0, loop		; Line 6: Replace lines 9, 10 and 11 in the second example,
						; Again, this instruction will be explained below.
						; (We explain this instructions in detail below.)
						; Line 7: Exits the program.
	RTS	
						; Line 9: The label to our buffer.
buffer:					; Line 10: Reserves 16 bytes and set them to "0".
	blk.b 16,0	
		
The kind of move-instructions you see in line 5 is used very often, so let us
explain it first: You have learned that if you put brackets on the address
register as in line 5 in the first example, that then the content is used the
register points to. This new version works the same way but has an extra
finesse. View in this example:

	move.b (A0)+,D0		
	It performs the same as:
	move.b (A0), D0	
	add.l #1, A0	

The number, located in A0 is used as the address. The instruction fetches the
byte which is located at the address and copies it into the data register D0.
Then it automatically adds "1" to A0 because there is a "plus sign" after
parenthesis (post increment). Had there been "move.w" instead for "move.b" it
would have added "2" to A0 (because a word consists of two bytes). Had there
been "move.l" instead of "move.b" it would have added 4 to A0 (because a
longword consists of four bytes).

The instruction move.b (A0)+, (A1)+ will then:
1: Getting the byte A0 point to and stores it in the address A1 points to.
2: Increase the address in A0 about "1" (we work with the size bytes).
3: Increase the address in A1 about "1" (we work with the size bytes).
You will use this kind of way very often. Especially when you examine data
tables, and when you move around data in Amiga's memory. It is therefore very
important that you learn these things.

The next instruction we must have a look at is DBRA.:
	move.l #9,D0	
loop:	
	dbra D0,loop	
	RTS	

The example performs the same as:	What does DBRA (Decrement BRanch Always)
exactly do:
	move.l #10,d0	; 1: Subtract 1 from the register (in this case D0).
loop:				; 2: Compare with "-1".
	sub.l #l, d0	; 3: If it is larger "-1" jump back to loop.
	cmp.l #0, d0	; (How can a negative number be represented by a byte,
					; word or a longword? We’ll come back
	BNE loop		; to this topic later. At the moment do not worry about
					; this problem).
	RTS				; When D0 is "-1" the CPU will continue at the next
					; instruction. Notice that DBRA always

compares with "-1", so we must use a number in the register (here D0), which
is "1" less than the number of times we want the loop be executed.
