; mc0202.s				; adressing modes
; not on disk
; only on letter_02 p. 06

; SEKA>ks	; (optional)
; Sure? y
; SEKA>r
; FILENAME>mc0202.s
; SEKA>a
; OPTIONS>
; No errors
; SEKA>j

start:						; Line 1: The word "start" is a LABEL. Without the colon ":" after the word the
							; assembler tries to interpret the word as a machine code instruction. This is
							; explained in more detail in a later section. At the moment it is sufficient to
							; keep in mind that the assembler marks the address of the assembled code with
							; the label in memory. Thereafter you can refer to the address in using the label
							; instead of the address. In this example the label "start" is at the beginning of
							; our program and therefore we can refer to the start address of our program
							; using this label. So when you want to start your program from within K-Seka
							; you just write: j start.
	move.l	#$50,D0			; Line 2: Moves the constant number $50 into the data register D0.
	add.l	#$10,D0			; Line 3: Adds the constant number $10 to the number in the data register D0.
	move.l	#$100,D1		; Line 4: Moves the constant number $100 into the data register D1.
	move.l	#$5,D2			; Line 5: Moves the constant number $5 into the data register D2.
	sub.l	D2,D1			; Line 6: Subtracts the number which is in the data register D2 from the number
							; contained in the data register D1 (Note: the result is in D1).
	RTS						; Line 7: This instruction means: RETURN FROM SUBROUTINE. This means that the
							; program or the routine ends and returns to the calling instance – whichever
							; instance it was (Workbench, CLI, or K-Seka).For instance when you start the
							; program from within K-Seka with the "j start" command so the program will
							; return to K-Seka after this RTS instruction was executed.
							; After the above program is complete, look at the registers’ content:
							; D0 contains $60 ($50 + $10)
							; D1 contains $CA ($100 - $05)
							; D2 contains $05
	
		end

Let’s look at some of the main machine code instructions:
MOVE, ADD, SUB, and LEA.

MOVE.B	8 Bits
MOVE.W	16 Bits
MOVE.L	32 Bits

Below you can see a few examples of this:

move.l #10, D0	IMMIDIATE ADRESSING
move.l #$10, D0	
move.l $10, D0	DIRECT ADRESSING

The first instruction moves the decimal number 10 into register D0. This way of
moving the numbers into a register is called "IMMIDIATE ADRESSING" and can be
translated as "the immediate transfer of data."
The second instruction moves the hex-number $10 (hexadecimal) into Register D0
in the same way. The name of this data transfer is the same as in the example
above. The last instruction is moving a longword which starts at the memory
address $000010 into D0. This is called "DIRECT ADRESSING".

You need not worry about what the different addressing modes are called. The
important thing is that you will be able to see and understand the difference
when you see the instructions. And believe us, you will be able to.
The character "#" indicates that a constant number is to be used. When the
character "#" is missing in front of a figure, it means that the processor must
retrieve a number from a memory address, and that number represents the address
of the memory cell where the number is to be fetched from. This does
MOVE.L $10,D0 as explained above: Go to memory-address $000010 and copies the
longword to the register D0. This last instruction is called
"LOAD EFFECTIVE ADDRESS. This is explained later".
There are several addressing modes (ADDRESSING MODES), but we will study them
as we will need them later in this course.

Another interesting register of the CPU is the PROGRAM COUNTER (PC). This
register contains the address of the next instruction/data that the CPU must
fetch and perform/process.
Each time it retrieves an instruction or data, the PC is increased, so it
points to the download next location where to fetch instructions or data the
next time. This register keeps track of the (address) location where the CPU
reads and executes the instructions of the current program.
You can use the program counter when you are programming, but we don’t think to
do it. There are other and better ways to use this register. More details on
this later. We take an example:

	lea.l copperlist,A1		; Line 1: Load effective address (.1 = LONG WORD)
							; of the copper list into the address register A1
	RTS						; Line 2: Return from subroutine. Go back to the
							; place where the program was called.
copperlist:					; Line 3: "copperlist" is not an instruction. This
							; is just to indicate a point in the machine
							; code program – we already explained it – it’s a
							; label. This label indicates the address of the
							; first byte in copper list ($2C).

	dc.w $2C01,$FFFE		; Line 4,5 and 6: Here begins the part of a larger
							; program which should be performed by
	dc.w $00E0,$0000		; copper.
	dc.w $00E2 …			; Programs that you write in K-Seka can be located
							; anywhere in the memory where there is free space. 

The operating system in the Amiga provides this functionality automatically. We
explain more on this later. Short the address that the label "copperlist"
represents can be anywhere in the machine memory.
The instruction "LEA" in our example determines the address of the copper list
by counting ahead of the instruction "lea" until the label "copper list. It
figures out how many bytes it should move forward to find the label
"copperlist". The number is called an offset.
Imagine the program as a ruler and Instruction "lea" is 16 cm mark. Instead of
saying that the copper list at 20 cm mark, we can say that it is 4 cm in front
the position where the program is started just now.
This similarly works with "lea". The current position in the program can be
found in the program counter - PC. What happens in reality is to take the
address from the PC, adds the distance between the two (instructions and
label), and then puts the result into A1.
Well: The distance between two instructions (or an instruction and a label) is
called an offset. It is used to find the instruction address by adding to a
different address. Do you understand?
If not, read it again. It is easier than you think.
