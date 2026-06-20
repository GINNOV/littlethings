
; Example of Dave Edwards encryption code ( with modified PRNG :-) 

; Use Monam to monitor whats going on.

Start		lea		CryptData,a6
		bsr		Encrypt
		move.l		#'ACC ',(a6)
		move.l		#0,4(a6)
		bsr		Decrypt
BP		rts


		even
String		dc.b		'Now you see me .....'
StrLen		equ		*-String
		even

CryptData	dc.b		'ACC ',0,0,0,0
		dc.l		String
		dc.l		StrLen

* Password based PRNG encryption system routines

* Passwords limited to 8 chars max.

* Routines that the USER needs to write are:

* 1)	Routine to get password from keyboard WITHOUT
*	displaying the characters on screen (a la UNIX Login)
*	and save it in key(a6) (zero padded at end if password
*	fewer than 8 chars)

* 2)	Routines to load and save the file (standard DOS library
*	stuff) being encrypted/decrypted

* 3)	Front end to allow either encryption or decryption



		rsreset
key		rs.l	2	;8 char password key
filebuf		rs.l	1	;pointer to plaintext/ciphertext
filesize	rs.l	1	;no of chars in file


* Encrypt(a6)
* a6 = ptr to variables defined in RS section above

* Take plaintext file, spit out ciphertext


* d0-d5/a0-a2 corrupt


Encrypt		move.l	filebuf(a6),a0		;ptr to file
		move.l	filesize(a6),d0		;no of chars

Encrypt_1	move.b	(a0),d1			;get plaintext char
		bsr	PRNG			;execute this
		lea	key(a6),a1		;this lot gets LSB of
		move.l	4(a1),d2		;the changed key
		add.b	d2,d1			;encrypt char
		move.b	d1,(a0)+		;replace ciphertext char
		subq.l	#1,d0			;done all chars?
		bne.s	Encrypt_1		;back if not
		rts				;else done


* Decrypt(a6)
* a6 = ptr to variables defined in RS section above

* Take ciphertext file, recreate plaintext


* d0-d5/a0-a2 corrupt


Decrypt		move.l	filebuf(a6),a0		;ptr to file
		move.l	filesize(a6),d0		;no of chars

Decrypt_1	move.b	(a0),d1			;get ciphertext char
		bsr	PRNG			;execute this
		lea	key(a6),a1		;this lot gets LSB of
		move.l	4(a1),d2		;the changed key
		sub.b	d2,d1			;decrypt char
		move.b	d1,(a0)+		;replace plaintext char
		subq.l	#1,d0			;done all chars?
		bne.s	Decrypt_1		;back if not
		rts				;else done


* PRNG(a6)
* a6 = ptr to variables above

* Pseudo random number generator (64 bits wide)
* Should be OK.

* d2-d5/a1-a2 corrupt


PRNG		lea	key(a6),a1
		move.l	a1,a2
		move.l	(a2)+,d2		;get key
		move.l	(a2)+,d3

		roxl.l	#1,d3			;this lot is a
		roxl.l	#1,d2			;64-bit rotate
		bcc.s	PRNG_1
		or.b	#1,d3

PRNG_1		move.l	d2,d4			;this lot does the
		moveq	#0,d5			;scrambling
		eor.l	d3,d4
		addx.l	d5,d3
		addx.l	d4,d3
		addx.l	d5,d2
		move.l	d2,(a1)+		save scrambled key
		move.l	d3,(a1)+
		rts

