; mc0804.s 					; "mulu", "muls", "divu" and "divs"
; not on disk
; explanation on letter_08.pdf / p.xx

; SEKA>ks	; (optional)
; Sure? y
; SEKA>r
; FILENAME>mc0804.s
; SEKA>a
; OPTIONS>
; No errors
; SEKA>j

start:
								; In this machine code section we review the instructions "mulu", "muls", "divu" and "divs".
								; Let us begin by mulu, which stands for: MULtiply Unsigned. Mulu performs a multiplication
								; with Unsigned values.
	MOVEQ #10,D1	
	MULU #5,D1	
								; First line moves the value of the constant 10 quickly into D1. The second line multiplies D1
								; by 5, so that D1 will contain the 50. The instruction "mulu" multiplies two 16bit words and
								; result in a 32bit long-word.
								; The next instruction we need to look at is "muls" it stands for (which you probably already
								; have guessed) MULtiply Signed. The difference between "mulu" and "muls" is that "muls"
								; multiplies two signed words and results in a signed long word as a result.
;Example:	
	MOVEQ #10,D1	
	MULS #-5,D1	
								; D1 will now contain -50 (FFFFFFCE).
								; The divu-instruction we examine now stands for: DIVision Unsigned. This instruction takes
								; A 32bit long word and divides it with a 16bit Word. At the result we will take a closer look.
								; But first let us take an example:
	MOVE.W #500,D1	
	DIVU #10,D1	

								; and one for ......	
	MOVEQ #10,D1	
	DIVU #3,D1	

								; and yet another ......	
	MOVE.W #1001,D1	
	DIVU #2,D1	

	rts

	end

		The first example will give the following value in D1: $ 00000032 (or 50 decimal).
		The second example is the number 10 which is divided by 3 => the result is equal to 3.33. It
		looks a bit "messy" out, right? Given that the binary numeral system can only contain integer
		Dl will look like this: $000100003 BIT 0-15 ($0003) gives the integer, and BIT 16-31 ($0001)
		gives the rest. (If we had divided by 5, then BIT 16-31 contains 0 since there’s no rest). So the
		result can be interpreted by: 3 plus a third, or 3.33.
		The last example also has a rest. D1 will now look as follows: $000101F4. So: 500 ($01F4 =
		500 decimal) plus 1 ($0001) half, which may be interpreted as written 500+1/2 or 500.5.
		The last instruction "divs" works the same way as DIVU, but operates with signed numbers.
		These instructions, although they are very effective, are not used very often. It is most when
		writing complex programs with a lot of mathematical calculations that they come to their full
		potential.
		This was the machine code chapter of this issue. In the next issue we look at INTERRUPTS
		and related instructions.
