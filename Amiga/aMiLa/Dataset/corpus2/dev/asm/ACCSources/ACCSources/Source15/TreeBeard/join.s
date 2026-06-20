******************************************
; The Join Replacement project

; Writen by TreeBeard of DragonMasters
******************************************

OldOpenLibrary	=-408
CloseLibrary	=-414
Input	=-54
Output	=-60
Read	=-42
Write	=-48
Open    =-30
Close   =-36
Delete	=-72
Lock	=-84
Unlock	=-90
Examine	=-102
AllocMem	=-198
FreeMem	=-210
Oldfile	=1005
Newfile	=1006

Test	=0	; Set it to one if assembling to disk
		; If assembling to memory, label test contains the
		; parameters which are passed to the program

; The next two lines are there for testing the program

	IFEQ	Test
	lea	test,a0			Address of parameters in a0, like DOS does
	move.l	#teste-test,d0		Length of parameters in d0, like DOS does
	ENDC

; Main program

; Open libraries, etc...

	movem.l	d0-d7/a0-a6,-(sp)	Save registers
	move.l	a0,padd			Save address of parameter line
	move.l	d0,length		and its length
	move.l	4,a6			Open DOS library
	lea	doslib,a1
	jsr	OldOpenLibrary(a6)
	move.l	d0,a5			Keep it in a5
	beq	error
	jsr	Output(a5)		Get the CLI Output handle for text
	move.l	d0,outhandle
	
; If the parameter is just a question mark, give the command's syntax

	move.l	padd,a0			paramter address in a0
	cmp.b	#'?',(a0)		first char=`?' ?
	beq	format			if so, give format

; Find the filename to which files are joined.  The routine search is used
; which searches for one string inside another string
; Entry - a1=address of string to search for
;         a0=address of string to search in
;         d0=no. of chars that can be searched 
; Exit  - If not found, d0=0
;         If found:
;         d0=no. of chars left unsearched
;         a2=address of start of place in main string it was found
;         a0=end of place it was found
; searchstart just does the same, except it starts searching from start
; of parameter string.

; The string must follow a character with an ASCII value of less than 33,
; here it will either be a zero (put in by program) or a space.

	move.l	length,d0		get length in d0
	lea	to,a1			search for a `to ' in string
	bsr	search			search for it
	tst	d0			found?
	bgt	foundc			yes, jump next bit
	move.l	outhandle,d1		ERROR: No destination file found
	move.l	#nodest,d2
	move.l	#nodeste-nodest,d3
	jsr	Write(a5)		print error
	bra	format			print syntax to remind user
foundc	move.l	a2,outstart		save address of start of `to ' statement

; Here, finde is used.  It returns the addresses of the beginning and end of
; the next part of the command (eg. if string was '  ram:prog ', it would
; give the address of the first `r' as the beginning and the `g' as the the
; end.  This allows the user to use as many spaces as he (sorry, or she)
; wishes.
; On entry, a0 should be address of place to start from
; On exit,  a1 = address of beginning of next part
;           a0 =            end                    +1
 

	bsr	finde		find start/end of output filename
	move.l	a1,output	save beginning
	clr.b	(a0)		make the character after end of filaname a zero
	move.l	a0,a2		get the length of output filename
	sub.l	a1,a2		by subtracting the address of the beginning
	move.l	a2,outlen	from the address of the end, and save it in outlen

; Searches for the commands `del' (auto delete) and `addlet' (add letters
; to filenames).  Uses the search routine.  Bit 0 of flags set for del, and
; bit 1 for addlet

	lea	del,a1		Search for `del' - address in a1
	bsr	search		search
	clr.b	flags		clear flags
	tst	d0		was it found?
	ble.s	nodel		nope, skip next command
	or.b	#1,flags	set bit 0 of flags
nodel	lea	addlet,a1	Search for `addlet' - address in a1
	bsr	searchstart	search from start of parameters
	tst	d0		was it found?
	ble.s	noaddlet	nope, skip next bit
	or.b	#2,flags	set bit 1 of flags
	bsr	finde		get the start and end letters that follow
	move.b	(a1)+,addlets	save the start letter
	move.b	(a1),addlete	and the end letter

; tells user if you're creating a new file or replacing an old one, then
; opens it.

noaddlet
	move.l	output,d1	Does output file exist? (try to open it)
	move.l	#Oldfile,d2
	jsr	Open(a5)
	move.l	d0,d1
	beq	notthere	No, then say you're creating a new one
	jsr	Close(a5)	Close output file
	move.l	#replace,d6	Say you're replacing it - address of message in d6
	move.l	#replacee-replace,d7	length in d7
	bra	gotfile		print message
notthere
	move.l	#create,d6	address of message in d6
	move.l	#createe-create,d7	length in d7
gotfile	move.l	output,d1	Create new file
	move.l	#Newfile,d2
	jsr	Open(a5)
	move.l	d0,out_hd	output filename handle
	beq	cantopen	if d0=0 - ERROR:Can't open create file
	move.l	d6,d2		say if creating or replacing a file
	move.l	d7,d3
	move.l	outhandle,d1	CLI Window handle in d1
	jsr	Write(a5)	Print message	
	move.l	outhandle,d1	print the output
	move.l	output,d2	address of filename in d2
	move.l	outlen,d3	length in d3
	jsr	Write(a5)	print it
	move.l	padd,innames	start of paramters=start of input filenames

; Main Program: Do the Joining.  The main routine used by normal-join and
; addlet-join is dofile, which as it suggests, joins the current file to the
; main one.

getin	move.l	innames,a0	find beginning and end of next filename
	bsr	finde
	move.l	a1,innames	save beginning in innames
	move.l	a0,innamee	and end in innamee
	btst	#1,flags	doing an addlet command?
	bne	addletter	yep, different routine needed
	cmp.l	outstart,a1	done all the joining (reached the `to ' statement)?
	beq	doneall
	clr.b	(a0)		terminate this filename with a zero
	bsr	dofile		do the joining
nextone	move.l	innamee,innames	end of last filename=beginning of next
	bra	getin		and do the next filename
doneall	move.b	#2,complete	everything OK.
closef	move.l	out_hd,d1	close the output file
	jsr	Close(a5)

; The start of the cleanup routine.  First it checks the variable complete.
; If it = 0, there was a problem with the output file, so just quit without
; saying anything.  If it = 1, there was an error in joining so offer, to
; delete it.  If it = 2, it was successful, so say so.

out	move.b	complete,d0	get status
	beq	leave		=0, quit now
	cmp.b	#2,d0		=2, say it worked
	beq	happy
	move.l	outhandle,d1	Say it was aborted
	move.l	#request,d2
	move.l	#requeste-request,d3
	jsr	Write(a5)
	jsr	Input(a5)	Get the input handle for keyboard
	move.l	d0,d1		get 1 character from keyboard
	move.l	#spare,d2
	move.l	#1,d3
	jsr	Read(a5)
	move.b	spare,d0	get that character
	and.b	#$df,d0		make it a capital letter
	cmp.b	#'Y',d0		did he say yes?
	bne	leave		no, then leave now
	move.l	output,d1	Delete the output file
	jsr	Delete(a5)
	bra	leave		and then leave
happy	move.l	outhandle,d1	Say there was no problem
	move.l	#noprob,d2
	move.l	#noprobe-noprob,d3
	jsr	-48(a5)
	move.l	totlen,d7	Give the total length of the file
	bsr	printlen

; Finally leave

leave	
	IFEQ	Test
	btst	#10,$dff016	Waits for RMB to be pressed so when testing
	bne.s	leave		you can see what's been printed
	ENDC
	bsr	carret		print a carriage return
	move.l	a5,a1		Close the dos library
	move.l	4,a6
	jsr	CloseLibrary(a6)
	movem.l	(sp)+,d0-d7/a0-a6	Restore regs
error	rts

; Says you can't create output filename

cantopen
	move.l	#noopen,d2	Print message `Can't open file '
	move.l	#noopene-noopen,d3
	move.l	outhandle,d1
	jsr	Write(a5)
	move.l	outhandle,d1	and prints the output filename
	move.l	output,d2
	move.l	outlen,d3
	jsr	Write(a5)
	bra	leave		leaves

; The addletter routine which adds letters to the first input filename
; Entry from main program is a1=start of input filename and a0=end of
; filename+1

addletter
	clr.b	1(a0)		clear the next byte after end
	addq.l	#1,innamee	and add one to the end address,
;				both since an extra byte for letter is needed
.loop	move.l	innamee,a0	a0=end
	move.b	addlets,-(a0)	put the letter into it
	move.l	innames,a1	a0=start
	bsr	dofile		join it
.loop1	addq.b	#1,addlets	move on to the next letter
	move.b	addlets,d0	have we done the last letter yet?
	cmp.b	addlete,d0
	ble.s	.loop		no, then continue
	bra	doneall		finished

; This is called as a subroutine, but since there are a lot of errors
; which are found by this routine, it is helpful for stack-space to
; de-subroutinise it by pulling the return address from the stack into
; a3 by move.l (sp)+,a3, and at the end if no errors are found to
; do a jmp (a3) instruction.  This means you can branch out of routine
; at will.

; Joins the file, and prints its length, and deletes it if user wants to
; Entry a1=start of filename

dofile	move.l	(sp)+,a3
	move.l	a1,d1		Open the file
	move.l	#Oldfile,d2
	jsr	Open(a5)
	beq	badinf		If we can't, there is an error
	move.l	d0,inhandle	save handle
	bsr	carret		print a carriage return
	bsr	printin		print the filename
	move.l	innames,d1	Lock the file
	move.l	#-2,d2
	jsr	Lock(a5)
	move.l	d0,inlock	Save it
	beq	noinfo		if =0, can't lock it
	move.l	d0,d1		Examine file (to get length)
	move.l	#fib,d2
	jsr	Examine(a5)
	move.l	fib+124,d7	Get length into d7
	add.l	d7,totlen	add it to the total length of output file
	bsr	printlen	print length
	move.l	d7,d0		Reserve d7 bytes to read file
	move.l	#1,d1		MEMF_Public
	jsr	AllocMem(a6)
	move.l	d0,a4		move it to d4
	beq	noroom
	move.l	inhandle,d1	Read d7 bytes from file to address a4
	move.l	a4,d2
	move.l	d7,d3
	jsr	Read(a5)
	move.l	out_hd,d1	Write d7 bytes from address a4 to output
	move.l	a4,d2		file
	move.l	d7,d3
	jsr	Write(a5)
	move.l	d7,d0		Free the memory
	move.l	a4,a1
	jsr	FreeMem(a6)
	move.l	outhandle,d1	Say it was joined
	move.l	#doneone,d2
	move.l	#doneonee-doneone,d3
	jsr	Write(a5)
	move.l	inlock,d1	Unlock file
	jsr	Unlock(a5)
	move.l	inhandle,d1	and close it
	jsr	Close(a5)
	btst	#0,flags	should we delete it?
	beq.s	keepfile	no, then jump
	move.l	innames,d1	Delete file
	jsr	Delete(a5)
	tst	d0		Could we
	beq	keepfile	no, then jump
	move.l	outhandle,d1	Say it was deleted
	move.l	#anddel,d2
	move.l	#anddele-anddel,d3
	jsr	Write(a5)
keepfile
	
exitin	jmp	(a3)		Exit

; No room to load file in

noroom	move.l	outhandle,d1
	move.l	#noroomt,d2
	move.l	#noroomte-noroomt,d3
	jsr	Write(a5)
	move.b	#1,complete
	bra	closef

; Described above - searches for the start and end of a part of a string

finde	cmp.b	#33,(a0)+	next char<33? (ie. Space or zero, etc)
	bcs	finde		yes, then loop until it isn't
	subq.l	#1,a0		take 1 away
	move.l	a0,a1		put in a1
finde1	cmp.b	#33,(a0)+	next char>32?
	bcc	finde1		yes, then loop until it isn't
	subq.l	#1,a0		take 1 away
	rts

; Just uses one of the pieces of text which starts with a line feed to
; go onto next line

carret	move.l	outhandle,d1
	move.l	#noinfot,d2
	move.l	#1,d3
	jmp	Write(a5)
	

	even
length	dc.l	0	length of paramters passed to command
padd	dc.l	0	address "   "        "      "  "
outhandle
	dc.l	0	CLI Window handle
output	dc.l	0	address of output filename
outlen	dc.l	0	length of output filename
inlock	dc.l	0	input file lock
out_hd	dc.l	0	output file handle
inhandle
	dc.l	0	input file handle
innames	dc.l	0	start of input filename
innamee	dc.l	0	end of input filename
spare	dc.l	0	spare (used for getting keyboard input and printing a hex character)
outstart
	dc.l	0	address of `to ' statement in parameters
totlen	dc.l	0	total length of output file
complete
	dc.b	0	condition (0 output error, 1 input error, 2 Ok)
flags	dc.b	0	bit 0 = delete, bit 1 = add letters
addlets	dc.b	0	letter to start adding on
addlete	dc.b	0	letter to finish adding on

	even

; Prints command syntax

format
	move.l	outhandle,d1
	move.l	#comminf,d2
	move.l	#comminfe-comminf,d3
	jsr	Write(a5)
	bra	out

; Says you can't open input file

badinf	move.l	outhandle,d1
	move.l	#noopen,d2
	move.l	#noopene-noopen,d3
	jsr	Write(a5)

; Used by some errors (including badinf one) - prints name of file after
; error, and sets complete to Input Error status

inerror	bsr	printin
	move.b	#1,complete
	bra	closef		Close the output file

; Can't get info on command

noinfo	move.l	outhandle,d1
	move.l	#noinfot,d2
	move.l	#noinfote-noinfot,d3
	jsr	Write(a5)
	bra	inerror

; Prints input filename

printin	move.l	outhandle,d1
	move.l	innames,d2	Start of filename
	move.l	innamee,d3	Length=End-start
	sub.l	innames,d3
	jmp	Write(a5)

; Prints the lenght (d7) in hex

printlen
	move.l	outhandle,d1
	move.l	#length1,d2	Prints ` Length ('
	move.l	#length1e-length1,d3
	jsr	Write(a5)
	move.l	d7,d6		Print High byte
	lsr.l	#8,d6		by dividing it by 65536 (by 256 twice)
	lsr.l	#8,d6
	bsr	printhex
	move.l	d7,d6		Print middle byte
	lsr	#8,d6		by dividing it by 256
	bsr	printhex
	move.l	d7,d6		and print lower byte
	bsr	printhex
	move.l	outhandle,d1	Print the close bracket
	move.l	#length2,d2
	move.l	#1,d3
	jmp	Write(a5)

printhex
	move.l	d6,d5		Save number
	lsr	#4,d5		divide it by 16 for high nybble
	bsr	printchar	and print it
	move.l	d6,d5		do low nybble
printchar
	and.b	#15,d5		make sure it is in region of 0-15
	add.b	#'0',d5		add 48 to it to make it a number
	cmp.b	#'0'+10,d5	should it be a letter?
	bcs	notletter	no, then branch
	add.b	#7,d5		add seven to make a the right letter
notletter
	move.b	d5,spare	Use spare to save character
	move.l	outhandle,d1	Print it
	move.l	#spare,d2
	move.l	#1,d3
	jmp	Write(a5)

; Described above - searches for a string a1 in a0, in a maximum of
; d0 characters

searchstart
	move.l	length,d0	Start at beginning of paramters
	move.l	padd,a0
search	tst	d0		d0=0 (done all characters in string)?
	beq.s	notfound	yes, then exit with d0=0
	subq.l	#1,d0		take 1 from d0
	cmp.b	#33,(a0)+	is it >32 (not a space, etc.)
	bcc	search		yes, then branch until its not
	move.l	a0,a2		keep this address
	move.l	a1,a3		and copy a1 to a3 so that a1 stays the same
search1	move.b	(a0)+,d1	get next character of string
	and.b	#$df,d1		make it a capital letter
	cmp.b	(a3)+,d1	does it match?
	bne	search		no, then search again
	tst.b	(a3)		Reached end of string?
	bne	search1		no, then continue to search
notfound
	rts

; Paramters passed when assembled to memory

test	dc.b	'ram:Dos_Command to ram:Compilation del addlet ae',10
teste	

; Library name

doslib	dc.b	'dos.library',0

; Error and text messages

comminf	dc.b	'USAGE: Join <input files> to <output file> [del] [addlet <start><finish>]'
comminfe
	
nodest	dc.b	'No destination file;',10
nodeste

create	dc.b	'Creating new file...'
createe
	
replace	dc.b	'Replacing old file...'
replacee	
	
noopen	dc.b	10,10,"Can't open file "
noopene

noinfot	dc.b	10,10,"Can't get info on file "
noinfote

noprob	dc.b	10,10,'Output File created succesfully'
noprobe

request	dc.b	10,10,'ABORTED...Not all files are joined.  Delete output file ?'
requeste

noroomt	dc.b	'Not enough memory to join this file'
noroomte

doneone	dc.b	'...Joined'
doneonee

anddel	dc.b	' and Deleted'
anddele

length1	dc.b	' (Length $'
length1e

length2	dc.b	')'

to	dc.b	'TO',0

del	dc.b	'DEL',0

addlet	dc.b	'ADDLET',0
	even

	cnop	0,4

fib	ds.b	256
