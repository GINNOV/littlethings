; mc0902.s 						; MOVEM, JMP, JSR, BCHG, RTE, ROR, ROL
; not on disk
; explanation on letter_09.pdf / p.11

; only program fragmets

Interrupt:	
	 MOVEM.L D0-D7/A0-A6,-(A7)	
	 ;..... (some meaningful code)	
	 MOVEM.L (A7)+,D0-D7/A0-A6	
	 RTE	
	 
								; In this chapter we review the following instructions: MOVEM, JMP, JSR, BCHG, RTE, ROR
								; and ROL.
								; Let's start with the MOVEM instruction. The additional letter "M" in this instruction means
								; multiple. So: This MOVE moves several things at once and is often used to store register
								; content to and retrieve it back from the STACK:
								; This code …	
	 MOVEM.L D0-D2,-(A7)	
								; …does the same as these 3 lines:	
	 MOVE.L D0,-(A7)	
	 MOVE.L D1,-(A7)	
	 MOVE.L D2,-(A7)	

;Another example:	
	 MOVEM.L (A7)+,D1/A0-A4	
								; The first example stores data registers D0, D1 and D2 at to the stack. The second example
								; which performs the same as the first but it needs both more space and more time to execute.

								; The third example retrieves D1, A0, A1, A2, A3 and A4 from the stack. You can also use
								; other destination address than that in the A7 to store and retrieve data. In this way you can
								; make your own stack. Such a program could, for example. look like this:
	 LEA.L mystack, A0	
	 MOVEM.L D0-D5/A1-A4, -(A0)	
	 ;...	
	 MOVEM.L (A0)+, D0-D5/A1-A4	
	 ;...	
	 BLK.B 100,0	
mystack:	
								; The next instruction we must look at the JMP. This instruction
								; means JUMP. The difference of this instruction and the BRA is that BRA instruction jumps
								; relative (the jump over an OFFSET to the program counter).
								; The JMP instruction does not work the same way: Let us show it with an example:
								; JMP $FC00D2
								; It always jumps to a fixed address. So the BRA instruction is used most often when it comes
								; to jumping within the same program, while the JMP is most used to jump outside the program
								; (to another program).
								; Next instruction in the list is JSR. JSR means JUMP TO SUB ROUTINE. Until now we have
								; only used BSR instruction because we have only jumped to sub-routines, which lies within
								; our own program. If we perform a jump to a sub-routine, which is beyond our program, we
								; uses the JSR. Besides being able to jump to a permanent address as the JMP instruction can,
								; the JSR can be used indirectly with an address register. There may also be an offset specified
								; in addition to this. Here are some examples:
	 JSR $5000	
								; and an example of an indirect jump ...	
	 JSR (A0)	
	 JSR 20(A0)	
								; The first example performs a jump to address $5000, the second example uses the value that
								; is stored where the address in A0 points to, as the jumping address. So: If A0 contains
								; $10000 and at that address the value $50000 is stored the jump will to address $ 50000.

								; In the last example the jump will got to the address located where A0 + 20 points to. In other
								; words, it takes the value located at address $10000 + 20 = $10014, and uses this value as the
								; jump destination address.

								; The next instruction is BCHG and means BIT CHANGE. This instruction is used to invert a
								; special BIT at an address or in a register. Here are some examples:
	 ; D0 = %00101101	
								; we do ...	
	 BCHG #3,D0	
								; ... and D0 becomes:	
	 ; D0 =%00100101	
								; We perform the same instruction a second time ...
	 BCHG #3,D0	
								; ... and D0 are again:	
	 ; D0 =%00101101	
								; This instruction should be obvious. The next instruction, we already have explained a part in
								; the program example MC0901, namely RTE. RTE does ReTurn from Exceptions. We should
								; not overwhelm you too much trying to explain what EXCEPTIONs are in this chapter, but be
								; will explain how the instruction works. RTE works like the RTS instruction which is used at
								; the end of a routine. The difference is that we use the RTE to complete an interrupt routine.
								; The technical difference is that the RTS instruction just downloads the old program counter
								; from STACK while the RTE instruction additionally retrieves the old value of the STATUS
								; register.
								; The last two instructions are ROR and ROL which means “ROtate Right” and “ROtate Left”
								; respectively. These instructions are very similar to the LSR and LSL. The only difference is
								; that the BIT which falls out at one end comes back in at the other end of the BIT group.

;Let us again show some examples:	
	 ; D0 =%11010010	
								; We try this ...	
	 ROR.B #3,D0	
								; ... and D0 now becomes this:	
	; D0 =%01011010	
								; We take one to:	
	; D0 =%0110100101011011	
								; after the following is done ...	
	ROL.W #1, D0	
								; ... D0 is this:	
	; D0 =%1101001010110110	
								; It may also be mentioned that 8 is the number value of rotations. If you need to rotate the for
								; example 13 BITS, you can you either use two instructions, or take advantage of the following
Method:	
	 MOVEQ #13,D1	
	 ROL.L D1,D0	
								; We hope it was understandable - otherwise try one more time.
