; mc0401.s 				; sum of elements from table
; from disk1/brev04
; explanation on letter_04.pdf / p.2-4
; from Mark Wrobel course letter 11

; SEKA>ks	; (optional)
; Sure? y
; SEKA>r
; FILENAME>mc0401.s
; SEKA>a
; OPTIONS>
; No errors
; SEKA>j

start:
	move.l	#$00,d0
	move.l	#$04,d1
	lea.l	table,a0

loop01:
	add.w	(a0)+,d0
	dbra	d1,loop01

	lea.l	result,a0
	move.l	d0,(a0)

	rts

result:
	blk.l	1,0

table:
	dc.w	2,4,6,8,10

	end

;------------------------------------------------------------------------------
MACHINE CODE III				
		So we need to program a bit in the MC again. We start with an easy program example that		
		illustrates how different things are done in MC. First, the program's layout:		
		Program example 0401:		
		This program takes the numbers defined in line 19 and adds them. The result ends up in a		
		longword in the data register D0. The program performs not much, but it gives useful insights		
		for later use.		
1	start:	Line 1: This is the start of the program and the starting point has been labeled "start".		
		K-Seka has now a reference named "start" and puts the address of the		
		beginning of the program into this variable.		
		Line 2: We need a data register to sum up the numbers (2, 4, 6, 8, and 10) – here we		
2	move.l #$00, D0	chose register D0. We clear the register by moving the constant value $00 into		
		it. We could have used the command “clr.l D0” (clear long word of data		
		register D0) instead. It would have given a faster code than		
		“move.l #$00, D0”.		
3	move.l #$04, D1	Line 3: We must sum up 5 numbers, so we put a counter into data register D1. The		
		loop01 we let run five times and each time load the next number, which we		
		sum to the number in D0. Since the loop01 has to be executed five times, we		
		move the constant value of 4 into register D1 in which we count the number of		
		loops. We count down this way: 4, 3, 2, 1 and 0 – in total 5.		
4	lea.l table, A0	Line 4: Loads the effective address of the start of the five numbers (from Line 19) into		
5		the address register A0. In line 19 we define five constant words and store the		
		numbers 2,4,6,8 and 10. The assembler creates a variable called "table" (in line		
		18) and puts the address of the first of our five numbers (2) into the variable; to		
		know where it can reference the numbers. We can properly access the		
		subsequent numbers by using an offset. This offset is the distance (measured in		
		number of bytes) between the first defined number (where the label points to),		
		and the number we want to access. In this example it plays no role, where our		
		machine program ends. There will always be the same distance between		
		program startup and our five constants we have defined.		
6	loop0l:	Line 6: Is a label we have called the “loop0l”. Add note the colon (:) to show that this		
		is a label, and that the word “loop0l” is unique. See also the explanation for		
		line 1 if you have many loops in your program, and this is very likely, it may		
		make sense either to enumerate them sequentially: loop0l, loop02, loop03 etc.		
		or providing them with descriptive name like e.g. “test”, “copper”, “buffer”, etc.		
		In K-Seka the labels can consist of as many characters (and almost all		
		characters) you want. You are not bound by a maximum length for your label		
		names. Labels are not case-sensitive, so if you have two labels, called		
		“dataschool” and "DATASCHOOL" K-Seka will give you an error because it		
		sees the two labels as the same.		
7	add.w (A0)+,D0	Line 7: In the first execution run of our loop “2” is fetched from the memory - A0		
		contains the address of the first number. It is then added to the register D0 and		
		the address in A0 is increased by two bytes (remember we're working with		
		words = 2 bytes) so the address in A0 points to the next number in memory.		
8	dbra D1, loop01	Line 8: The instruction "dbra" decreases the register D1 about 1 and then D1 is tested		
9		if the content is less than zero (actually “-1”, it is explained in the second issue).		
		If not the program jumps back to line 7, and the loop is executed once more.		
10	lea.l result, A0	Line 10: When all our numbers are added, we load the effective address of the memory		
		we labeled "result" into A0 – which is defined at line 15.		
11	move.l D0,(A0)	Line 11: The result of the addition (as a longword) is moved from D0 to the memory		
		part labeled “result” which address was previously loaded to A0 - see Line 10		
13	RTS	Line 13: The program ends here and returns to the calling instance (e,g, to K-Seka if you		
14		started the program from within K-Seka or to the CLI if you started it from		
		there).		
15	result:	Line 15: The label of the memory part called "result".		
16	blk.l 1,0	Line 16: Here a longword is reserved which is set to 0. In this longword our result is		
17		stored.		
18	table:	Line 18: Read the explanation for line 4 again (was explained there). Once you have		
19	dc.w 2,4,6,8,10	written this program into the editor, you must assemble it. You have to type "a",	a	
		and when K-Seka prompts for OPTIONS> write “vh” and press RETURN. It	OPTIONS> vh	stop on each line
		will now assemble the program and stop on each line. Press the spacebar to		
		continue. If you simply type "v" as an option then the assembler will scroll	OPTIONS> v	scroll non-stop
		non-stop. If you do not enter any options there is no output on the screen.		
		You start the program by typing "jstart" (jump to label "start").	jstart	jump to label start
		At the list of registers the K-Seka shows after the program was executed, one can see that D0		
		contains $1E (30) - and it is just the sum of 2+4+6+8+10.		
		But we put the result into memory as a word (line 11). Can we get K-Seka to show it to us? If		
		you writes "qresult" ("q" stands for query) K-Seka shows up the portion of memory that	qresult	Abfrage Inhalt Speicher
		contains our longword (with sum $1E). In the label “result” the address was stored pointing to		
		the definition of our longword. Beside the result you will see the figures $0002, $0004,		
		$0006,$0008, $000A, which is the hexadecimal representation of our numbers.		
		TASK 0401: We hope you understand everything so far and you are able and willing to		
		experiment with the program and change here and there. You can, for example, change the		
		values of the numbers to be summed.		


