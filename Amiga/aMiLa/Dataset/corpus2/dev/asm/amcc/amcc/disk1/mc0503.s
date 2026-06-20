; mc0503.s		
; not on disk
; only on letter_05 p. 14

start:	
								; Line 90: This variation of MOVE, you probably have not seen before. In this
								; instruction D5 will be given as an offset to A5.
								; Let us give an example:	
	MOVE.W 10(A1),D1	
								; Performs the same as:	
	MOVE.L #10,D2	
	MOVE.W (A1,D2),D1	
								; This in turn performs the same as:
	MOVE.L #8,D2	
	MOVE.W 2(A1,D2),D1	
								; We will explain this variation in more detail in the “machine code section” in this issue. In
								; any case it loads the value of the address that A5 points to plus the offset from D5, and moves
								; it into D1 (which represents the sprite x-position).


								; The first instruction, we must review is a special variant of the move instruction - and it looks
like:
	MOVE.W (A1,D1),D2	
								; This addressing method is called register offset. It works as follows (see example):
								; The contents of A1 and the content of D1 are added. Neither the content of A1 or D1 is
								; changed in this aggregation. The result of the addition is used as the address to move the data
								; (in this example 16bit – a word) into D2.
								; It all can also be written in a direct way using the absolute address, namely:
	MOVE.W #$10010,D2	
								; But because of using tables with data, the exact address is not always known from which the
								; data in the table is to be retrieved. So the register offset is ideal to move through the table and
								; just change the offset. So if we use the register offset the above example it looks like this:
	MOVE.L #$100000,A1	
	MOVE.L #$10,D1	
	MOVE.W (A1,D1),D2	
								; This instruction may also the have a solid offset. this can be very handy to have when it
								; comes the use of tables (lists) of data. Try to guess what this instruction performs:
	MOVE.L 10(A1,D1),D2	
								; Did you find out? The explanation is that the address in A1, the value of D1 and the fixed
								; offset are added to form the address the data is moved from to the register D2. (the fixed So:
								; A1 + D1 + 10 forms the effective address without changing neither A1 or D1. This is an
								; addressing method can be very handy. Read this section several times, so you are sure that
								; you understand how it works and what it means.

								; The next instruction we need to look at may seem a little more complicated at a first glance,
								; but they are quite logical in their functionality and therefore not so difficult to understand,
								;after all. These instructions work on bit level.


; LSL and LSR.
								; They mean the Logical Shift Left and Logical Shift Right.
								; We illustrate the functionality with an example:
	MOVE.B #%00101100,D0	
								; D0 (bit 0-7) contains the bit-pattern 00101100 after this instruction is executed.
								; Then we perform, for example, the following instructions:
	LSL.B #1,D0					; (logical shift of one bit to the left)	
								; After this instruction is executed, the contents of D0 (bit 0-7) has changed to the following
								; pattern: 01011000 (binary of course).
								; Notice that only the first byte (bit 0-7) at D0, was affected by the previous instruction. This is
								; because we used the ".B" in the LSL instruction. They other 24 bits (bit 8-32) in D0 will be
								; left unchanged.
								; Let us take an example:	
	MOVE.L #$645A4364,D0	
								; D0 will now look as in Figure 1a. (Have a look at the end of this issue).
								; Then we perform the following instructions:
	LSL.W #1,D0	
								; Bit 0-15 will now have changed / moved one bit to the left as shown in Figure 1b (have a look
								; at the end of this issue). Bit 0 will have a "0" coming from the right, while the contents of the
								; bit 15 will "fall out". It does not disappear completely, but lands in carry. This will be
								; explained in more detail in a later issue. The results can be seen in Figure 1c (have a look at
								; the end of this issue).

								; As you see only the first word (bit 0-15) is shifted one bit to the left. The bits 16-31 remain
								; untouched, because we used the ".W" in the LSL instruction. Shifting in the other direction –
								; to the right (LSR) works the same way. You can also shift the register content for several bits
								; (up to 8 bits) at a time, like this:
	LSR #5,D0	
								; This is a way to write shift operations but there are three other variants which will be
								; explained in a later issue.
	
; BSR – BRANCH TO SUBROUTINE
								; The next instruction is BSR (branch to subroutine).
								; This instruction can be compared with the BASIC command GOSUB.
								; Let us begin with an example:	
	MOVE.L #5,D0				; Line 1: Moving the constant value of 5 into D0.
	BSR routine					; Line 2: Go to the label "routine" an continue to execute instructions
	RTS							; Line 3:	Exit the program (return to the calling instance)
	
routine:	
	ADD.L #1,D0					; Line 6: Adding the constant value of 1 to D0.
	RTS							; Line 7: Go back after line 2 and continue with the next instruction

	end


	If you are unsure of this nonetheless continue to read about the stack - which helps to
	understand the BSR instruction.

	WHAT IS A STACK?
	In the Amiga (and all other computers) there is an area in memory which is used as a
	temporary storage for data that is needed for program execution. Among other things, it must
	be able to store addresses when jumping from one point in a program to a another, in order to
	be able to come back again.
	The word "stack" means "pillar / column" or "pile". The last translation describes it best in
	this case. We must explain how a stack works and how it is used. For explanatory purpose we
	have created a graph (see Figure 2a, 2b, 2c, 2d and 2e on the pages at the end of this issue).
	Look at the figures while we explain the term stack and the concept behind it.
	A Stack is used to store values / data for a short time during the execution of a program. The
	processor (MC-68000) uses the stack to store data - data that must be remembered for further
	processing later in the program.
	You may have wondered how the processor can remember which address it has to jump back
	to where it jumped to the sub-routine. It uses the stack to remember the return address. When
	the program, for example, needs to jump to a sub-routine, it stores the address of the current
	location (the return address) at the stack. When the sub-routine is completed, the processor
	retrieves the previous address from the stack it has stored before it made the jump. This
	happens quite ("automatic") without your involvement.
	You can also use the stack to store data temporarily. However, it is important that you know
	what you are doing, so that when - or if - the processor must retrieve the address it has stored
	previously, do not get your data instead of the return address. Your program will inevitably
	crash if this happens.
	To get a visual image of the stack, one can imagine the following:
	Imagine the stack as a pipe that is vertical. Down the pipe there is space for a number of
	plates. At the bottom of the pipe one can imagine that there is a spring which makes the upper
	plate to be as high at the edge of the pipe. If we put a plate in the pipe, it will be available at
	the top. If we put another plate in the pipe, it will be placed at the top and hence the previous
	plate will be available under the new plate.
	The more plates we put in the pipe, the more the spring is pressed down and the plates which
	were put first are the lowest – therefore a stack is also called LIFO – Last In First Out.

	Now we try to connect this image with what is happening in the Amiga when the stack is used.
	Go back to the program example MC0502, and the program line 132 (which looks like this):
MOVE.L D0-D5, -(A7)	
	This instruction will place the content of the registers from D0, D1, D2, D3, D4 and D5 onto
	the stack.
	Let’s now have a look at the program line 153:
MOVE.L (A7)+, D0-D5	
	This instruction does exactly the opposite of the previous instruction from line 132. It
	retrieves the register content from the stack and puts it back to into D0, D1, D2, D3, D4 and
	D5 again.
	What is the reason for this? It is because the registers are used in the program routine in a way
	that the values in the registers are changed, so when the processor jumps back to the main
	routine again (program line 47-57), it is necessary to save the previous values. This is done at
	the beginning of the routine and at the end of the routine those values are restored before the
	jump back.
	Let us now see what is happening in the Amiga when the stack is used:
	Address register A7 is also called stack-pointer. Figure 2a at the end of the issue is a draft od
	a stack. The numbers on the left side of the diagram represent the addresses of the stack--
	memory, while the arrow (SP) on the right side represents the stack-pointer. Pointing to the
	address 1000 (A7 contains the value 1000). Imagine now these instructions are executed:
MOVE.L #10, D0	
MOVE.B D0, -(A7)	
	The stack will now look like in Figure 2b.
	You've already learned about the "(A7)+" functionality (See NOTE III) but you have not
	learned anything about "-(A7)". It works in a slightly different way than the "+" because the
	minus sign stands in front of the brackets and the "+" is placed after the brackets. The "-(A7)"
	part of the instruction causes the processor to decrease the address in A7 about 1,2 or 4 bytes
	(depending whether you specified ".B", ".W" or ".L"). Then the content of the address, which
	is held by register A7 is retrieved.
	The value 10 (decimal) is moved into D0. The address in A7 is decreased by 1 and the content
	of D0 (in this example the lowest byte of the register) is stored to the address A7 points to.
MOVE.L #25, D0	
MOVE.B D0, -(A7)	
	After these instructions the stack will look like depicted in Figure 2c. And so we continue:

CLR.L D0	
MOVE.B (A7)+, D0	
	After these instructions the stack will look like in Figure 2d. The register D0 is set to 0 (CLR)
	and one byte is restored to register D0 from the address A7 points and the address is increased
	about 1 afterwards. D0 now contains 25 (decimal). Then we perform following instructions:
MOVE.B (A7)+, D0	
	After this instruction the stack will look like in Figure 2e and D0 will now contain the value
	10 (decimal).
	MORE ON BSR
	We will now explain BSR in more detail. It also uses the stack, and as mentioned earlier this
	is done automatically.
BSR routine	
 .....	
RTS	
 routine:	
 .....	
RTS	
	When the processor performs a BSR, the address the program counter points to (PC, see issue
	II) is saved onto the stack, then the processor branched "routine". When the processor
	encounters an RTS instruction at the end of the "routine" the processor will load the
	previously stored address from back into the program counter.
	Imagine that we ran this program from K-Seka:
MOVE.L #5, D0	
RTS	

First we assemble the program.	
Seka> a	
OPTIONS> <RETURN>	
No Errors	
Seka>	
Then we start it.	
Seka> j	

	Before K-Seka jump to the beginning of your program, it puts the current program counter
	address (a position in the K-Seka program) onto the stack. Then the processor branches to
	your program.

	Once your application is complete (it ends with an RTS), the processor acts in the same way
	as explained above, the stored value of the program counter is retrieved from the stack, loaded
	into the program counter (PC) and you end up back in the K-Seka.
	NOTA BENE
	It is important that you understand how the stack works – this principle applies to all
	computers. In the Amiga operating system the stack size is usually set to 4000 bytes but you
	can increase this value through the stack-command in the CLI.
	Read the sections on stack over and over again until you are sure you understand the principle.
	We promise you it is worth it.
