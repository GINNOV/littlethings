
Start		lea	string,a0
		bsr	StrToVal
		bsr	StrToVal
		bsr	StrToVal
		bsr	StrToVal
		bsr	StrToVal
		rts
		
string		dc.b	'$2a0c%110101001099765&7642#1992',0
		even
		

*****************************************************************************
;			Numeric String Conversion Subroutine
*****************************************************************************

***************	Subroutine to convert a string into a long word value

; Entry		a0->start of string

; Exit		a0->character following last character in string
;		d0=long word value
;		d1=0 if error, 1 if converted ok.

; Corrupt	d0, d1 & a0.

StrToVal	movem.l		d2/d5/d6/d7/a1/a2,-(sp)	save registers

; a0->start of string at this point

		lea		SpecifierTable,a1	a1->start of table
		moveq.l		#0,d1			clear register

.next_specifier	move.w		(a1)+,d1		d1=next entry
		beq.s		.error			quit if end of table

		cmp.b		(a0),d1			found specifier?
		bne.s		.next_specifier		if not check next

; If we get to here, d1 contains the info we require on the specifier

		asr.w		#8,d1			base into lowest byte
		move.l		d1,d7			d7=conversion factor

; Scan the string to determine it's end

		move.l		a0,a1		make copy of string pointer

; Determine if 1st character is a specifier

		lea		SpecifierTable,a2	ptr to look-up table
		move.l		#NUM_SPECIFIERS-1,d1	loop counter

.spec_loop	move.w		(a2)+,d2		get next specifier
		cmp.b		(a1),d2			specifier found
		bne.s		.loop_end		if not skip!
		addq.l		#1,a1			else bump pointer
		moveq.l		#0,d1			force loop exit
.loop_end	dbra		d1,.spec_loop		check all specifiers

; a1 now points to the start of the digits in the string.

		bsr.s		GetByteVal		check 1st digit
		tst.l		d0			is it valid
		bne.s		.scan_loop		if so continue
		move.l		d0,d1			else set error
		bra.s		.error			and quit

.scan_loop	addq.l		#1,a1			bump to next char
		bsr.s		GetByteVal		convert char
		tst.l		d0			is it valid?
		bne.s		.scan_loop		if so loop back

; a1 now points to the byte after the last legal character and at least one
;legal digit exsists.

		moveq.l		#0,d6			will hold conversion
		moveq.l		#1,d5			index for conversion
		move.l		a1,a2			copy end pointer
		
.convert_loop	subq.l		#1,a1			back one char
		bsr.s		GetByteVal		convert it
		tst.l		d0			legal?
		beq.s		.convert_done		if not skip

		subq.l		#1,d0			must correct return		
		mulu		d5,d0			x index
		add.l		d0,d6			add to total
		mulu		d7,d5			index=index*base
		
		cmpa.l		a0,a1			at the start yet?
		bne.s		.convert_loop		if not loop back

.convert_done	move.l		d6,d0			total into d0
		moveq.l		#1,d1			no errors
		move.l		a2,a0			a0->next char
		
.error		movem.l		(sp)+,d2/d5/d6/d7/a1/a2	restore
		rts					and return
		
*****************************************************************************
;			Subroutines
*****************************************************************************

***************	Subroutine to convert a digit

;Entry		a1->character

;Exit		d0=0 if character is invalid or value of character plus 1

;Corrupt	d0

GetByteVal	move.l		a0,-(sp)	save registers
		move.l		d1,-(sp)

		moveq.l		#0,d0		clear register
		lea		CharTable,a0	a0->digit lookup table
		move.b		(a1),d1		d1=digit to convert

.loop		move.w		(a0)+,d0	get next entry
		beq.s		.done		quit if end of table

		cmp.b		d0,d1		found digit?
		bne.s		.loop		if not loop back

		asr.w		#8,d0		value into low byte

		cmp.b		d0,d7		compare with base
		bge.s		.done		if legal then skip
		moveq.l		#0,d0		else flag an error

.done		move.l		(sp)+,d1	restore registers
		move.l		(sp)+,a0
		rts

*****************************************************************************
;			Look-up Tables
*****************************************************************************


NUM_SPECIFIERS	equ		4		four unique base specifiers

; Look-up table that defines all legal number base specifiers

SpecifierTable	dc.b		16,'$'		$ is for base 16
		dc.b		10,'#'		# is for base 10
		dc.b		8,'&'		& is for base 8
		dc.b		2,'%'		% is for base 2
; The following entries are for strings with no specifier
		dc.b		10,'1'		1 is for base 10
		dc.b		10,'2'		1 is for base 10
		dc.b		10,'3'		1 is for base 10
		dc.b		10,'4'		1 is for base 10
		dc.b		10,'5'		1 is for base 10
		dc.b		10,'6'		1 is for base 10
		dc.b		10,'7'		1 is for base 10
		dc.b		10,'8'		1 is for base 10
		dc.b		10,'9'		1 is for base 10
		dc.b		10,'0'		1 is for base 10
		dc.b		0,0		end of table

; The following table defines the value of individual digits.

CharTable	dc.b		1,'0'
		dc.b		2,'1'
		dc.b		3,'2'
		dc.b		4,'3'
		dc.b		5,'4'
		dc.b		6,'5'
		dc.b		7,'6'
		dc.b		8,'7'
		dc.b		9,'8'
		dc.b		10,'9'
		dc.b		11,'A'
		dc.b		12,'B'
		dc.b		13,'C'
		dc.b		14,'D'
		dc.b		15,'E'
		dc.b		16,'F'
		dc.b		11,'a'
		dc.b		12,'b'
		dc.b		13,'c'
		dc.b		14,'d'
		dc.b		15,'e'
		dc.b		16,'f'
		dc.b		0,0		end of table
