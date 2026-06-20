** CODE:    HELPER
** AUTHERS: Raistlin (Leon Skeldon)  &  Hearwig (Rick Sandiford)
** DATE:    Febuary 1st  1991
** SIZE:	  33257 BYTES

*******************************************************************************
;		NOTE FROM HEARWIG
*****************************************************************************
* command name, in small letters
* null byte (ie. 0)
* brief description of command
* next byte = 255 (shows end of description)
* List of possible addressing modes:
* a) number of parameters+1 (eg. for Move An,An it would be 3, for rts it
*    would be 1, for bra <label> it would be 2
* b) letter following main command (space if none).  Eg. cmpm - ='m'
* c) bits  meaning
*    15-8  (high nybble).  If two parameters, it is the destination,
*           If one parameter, it is irrelevant.  Eg.  An,An - will be the
*	    1.  See the bottom of prog from modes onwards: Dn = 0, An =1
*	    (An) = 2, (An)+ = 3, etc.
*     7-0  (low nybble).  If two parameters, it is the source, if one
*	    parameter, it is the operand.
* d) Specifies whether byte, word or long word can be used
*    bits  meaning
*    7-5   unused
*     4    Always 1 (the close bracket)
*     3    Set to 1 if long word
*     2    Set to 1 if word
*     1    Set to 1 if byte
*     0    Always 1 (the open bracket)
* There can be as many of these modes as possible.  
* A 254 BYTE SHOWS THE END OF THE COMMAND DATA

* It's not the simpliest way to do it, but much better on the old memory space


*******************************************************************************
;	 	INITIALISZE THE PROGRAM
******************************************************************************
	opt	c-		;I'm not a fussy man

	
	move.l	4,a6		;Exec base
	lea	dosname(pc),a1	;name of lib to load
	moveq.l	#0,d0		;any version
	jsr	-408(a6)		;load dos
	move.l	d0,dosbase	;store dos.base
	
	move.l	dosbase,a6
	jsr	-60(a6)		;get handle for CLI
	move.l	d0,conhandl2	;save
	
**This section opens the window main window
	lea	consolnam(pc),a1	;Name of window	
	move.l	#1005,d2		;mode
	move.l	a1,d1		;name of window in d1
	move.l	dosbase,a6	;dos base in a6
	jsr	-30(a6)		;open the window
	move.l	d0,conhandle	;save the conahdle

**This section writes to the output window
	move.l	dosbase,a6	;address of dos.lib in a6
	move.l	conhandle,d1	;get conhandle
	move.l	#title,d2		;get address of text
	move.l	#titleend-title,d3	;get length of text
	jsr	-48(a6)		;write text to screen

********************************************************************************
;		CHECK FOR FKEYS!
******************************************************************************
KEY
	move.b	$bfec01,d0	;get raw key code
	not	d0		;invert
	ror.b	#1,d0
	cmpi.b	#$59,d0		;is it F10
	bhi	key		;if its higher go to key
	cmpi.b	#$4f,d0		;is it F1
	bls	key		;if its lower go to key
	
	sub.b	#$50,d0		;lets turn it into a decent number
	add.b	#1,d0		

F1	cmpi.b	#1,d0		;is it F1?
	bne	F2		;no, try F2
	bra	ASCII		;this guy wants the ASCII table
F2	cmpi.b	#2,d0		;is it F2?
	bne	F3		;no try F3
	bra	ALERT		;oops a guru eh?
F3	cmpi.b	#3,d0		;is it F3?
	bne	F4		;no, try F4
	bra	COPPER		;programming the hardware eh?
F4	cmpi.b	#4,d0		;is it F4?
	bne	F5		;no, try F5
	bra	DOS.LIB		;forgot a function call?
F5	cmpi.b	#5,d0		;is it F5?
	bne	F6		;nope, try F6
	bra	HELPER		;tut,tut dont know the instruction set!
F6	cmpi.b	#6,d0		;is it F6
	bne	F7		;wrong again!
	bra	ISET		;postman pat!!
F7	cmpi.b	#7,d0		;is it F7?
	bne	F8		;nope
	bra	MMAP		;lets go to London!
F8	cmpi.b	#8,d0		;is it F8?
	bne	F9		;no?
	bra	DMA
F9	cmpi.b	#9,d0		;is it F9?
	bne	F10		;it MUST be F10
	bra	CHARS		;character codes
F10	bra	QUIT		;bye,bye!

********************************************************************************
;		SHOW THE INFO REQUIRED!
******************************************************************************
ASCII
	bsr	open			;open window
	move.l	#asciitext,d2		;address of text in d2
	move.l	#asciiend-asciitext,d3	;lebght of text
	jsr	-48(a6)			;write text
	bsr	wait			;wait for RMB
	bsr	close			;close window
	bra	key			;go back to main menu
	
COPPER
	jsr	open			;open the window
	move.l	#coppertext,d2		;address of text
	move.l	#copperend-coppertext,d3	;length of text
	jsr	-48(a6)			;write text
	bsr	wait			;wait RMB
	bsr	close			;close window
	bra	key			;go back to main window
ALERT
	jsr	open1			;open the window
	move.l	#gurutext,d2		;get address of first lot of text
	move.l	#guruend-gurutext,d3	;length of text
	jsr	-48(a6)			;write text
	bsr	wait			;wait RMB
	move.l	conhandl1,d1		;after waiting shows
	move.l	#gurutext1,d2		;next page
	move.l	#guruend1-gurutext1,d3	
	jsr	-48(a6)
	bsr	wait
	move.l	conhandl1,d1		;show next page
	move.l	#gurutext2,d2
	move.l	#guruend2-gurutext2,d3
	jsr	-48(a6) 
	bsr	wait
	move.l	conhandl1,d1		;show next page
	move.l	#gurutext3,d2
	move.l	#guruend3-gurutext3,d3
	jsr	-48(a6)
	jsr	wait
	move.l	conhandl1,d1
	move.l	#gurutext4,d2		;show next page
	move.l	#guruend4-gurutext4,d3
	jsr	-48(a6)
	jsr	wait
	move.l	conhandl1,d1
	move.l	#gurutext5,d2		;show next page
	move.l	#guruend5-gurutext5,d3
	jsr	-48(a6)
	jsr	wait
	move.l	conhandl1,d1
	move.l	#gurutext6,d2		;show next page
	move.l	#guruend6-gurutext6,d3
	jsr	-48(a6)
	jsr	wait
	bsr	close			;close the window
	bra	key			;return to main menu
DMA
	jsr	open1			;open window
	move.l	conhandl1,d1
	move.l	#dmatext,d2		;print text
	move.l	#dmaend-dmatext,d3
	jsr	-48(a6)
	jsr	wait
	move.l	conhandl1,d1
	move.l	#dma1text,d2
	move.l	#dma1end-dma1text,d3	;next page
	jsr	-48(a6)
	jsr	wait
	move.l	conhandl1,d1
	move.l	#dma2text,d2		;next page
	move.l	#dma2end-dma2text,d3
	jsr	-48(a6)
	jsr	wait
	move.l	conhandl1,d1
	move.l	#dma3text,d2		;next page
	move.l	#dma3end-dma3text,d3
	jsr	-48(a6)
	jsr	wait
	move.l	conhandl1,d1
	move.l	#dma4text,d2		;next page
	move.l	#dma4end-dma4text,d3
	jsr	-48(a6)
	jsr	wait
	move.l	conhandl1,d1
	move.l	#dma5text,d2		;next page
	move.l	#dma5end-dma5text,d3
	jsr	-48(a6)
	jsr	wait
	move.l	conhandl1,d1
	move.l	#dma6text,d2		;next page
	move.l	#dma6end-dma6text,d3
	jsr	-48(a6)
	jsr	wait
	move.l	conhandl1,d1		;next page
	move.l	#dma7text,d2
	move.l	#dma7end-dma7text,d3
	jsr	-48(a6)
	jsr	wait
	move.l	conhandl1,d1
	move.l	#dma8text,d2		;next page
	move.l	#dma8end-dma8end,d3
	jsr	-48(a6)
	jsr	wait
	move.l	conhandl1,d1
	move.l	#dma9text,d2
	move.l	#dma9end-dma9text,d3	;next page
	jsr	-48(a6)
	jsr	wait
	move.l	conhandl1,d1
	move.l	#dmaatext,d2		;next page
	move.l	#dmaaend-dmaatext,d3
	jsr	-48(a6)	
	jsr	wait
	bsr	close			;close window
	bra	key			;return to main menu
CHARS
	jsr	open1			;open window
	move.l	conhandl1,d1
	move.l	#cstext,d2		;address of text
	move.l	#cstextend-cstext,d3	;length of text
	jsr	-48(a6)			;write text
	jsr	wait			;wait RMB
	move.l	conhandl1,d1
	move.l	#cs1text,d2
	move.l	#cs1textend-cs1text,d3	;next page
	jsr	-48(a6)
	jsr	wait
	move.l	conhandl1,d1
	move.l	#cs2text,d2		;next page
	move.l	#cs2textend-cs2text,d3
	jsr	-48(a6)
	jsr	wait
	bsr	close			;close window
	bra	key			;return to main menu
DOS.LIB
	jsr	open1			;open window
	move.l	conhandl1,d1
	move.l	#dostext1,d2		;get address of text
	move.l	#dosend1-dostext1,d3	;length of text
	jsr	-48(a6)			;write text
	bsr	wait			;wait LMB
	move.l	conhandl1,d1
	move.l	#dostext2,d2
	move.l	#dosend2-dostext2,d3	;page 2
	jsr	-48(a6)
	jsr	wait
	bsr	close			;close window
	bra	key			;main menu

;--------------------------------------------------------------------------------
;	THIS SECTION BY HEARWIG (RICK SANDIFORD)
;----------------------------------------------------------------------------
HELPER
	bsr	ricopen			;Open window
	move.l	conhandl1,d1		;Ask for a command to be entered
	move.l	#helphi,d2
	move.l	#helphie-helphi,d3
	jsr	-48(a6)
commin	move.l	conhandl1,d1
	move.l	#commreq,d2		
	move.l	#commend-commreq,d3
	jsr	-48(a6)
	move.l	conhandl1,d1
	move.l	#commbuff,d2
	move.l	#10,d3
	jsr	-42(a6)
	cmp.b	#10,commbuff
	beq	endcomm
	lea	commands,a2
check	
	lea	commbuff,a3
compare
	cmp.b	(a2)+,(a3)+	;are the 2 characters the same?
	bne	nextc		;if there different, try next command
	tst.b	(a2)		;reached end of command name yet?
	bne	compare		;If not try next 2 characters
	tst.b	(a2)+		;Move a2 onto next byte
	move.l	a3,d4		;Work out the length of the command name
	sub.l	#commbuff,d4	
	move.l	a2,d2		;put start of description into d2 ready for printing
nextz	cmp.b	#255,(a2)+	;Find end of description
	bne	nextz		
	move.l	a2,d3		;find length of description
	subq.b	#1,d3
	sub.l	d2,d3
	move.l	conhandl1,d1	;and print it
	jsr	-48(a6)
	move.l	#cmodei,d2	;now put "possible modes:" text onto screen
	move.l	#cmodeie-cmodei,d3
	move.l	conhandl1,d1
	jsr	-48(a6)
modepr	cmp.b	#254,(a2)		;reached end of command yet?
	beq	commin		;if so ask for another command
	move.l	d4,d3		;get length of command name
	move.l	#commbuff,d2	;and print the command
	move.l	conhandl1,d1
	jsr	-48(a6)
	move.b	(a2)+,type	;save number of parameters needed into type & set a2 to next byte(used all data regs so I have to use memory instead)
	move.l	a2,d2		;get the address of the leter to be added onto command name
	moveq.l	#1,d3
	move.l	conhandl1,d1
	jsr	-48(a6)		;& print it
	tst.b	(a2)+
	cmp.b	#1,type		;are there no parameters
	beq	retc		;if so go onto next possible mode
	bsr	spaces		;print a space
	clr.l	d7		;clear d7. d7 is used as a counter of the number of characters printed from now on, except a comma (if used)
	move.b	(a2),d5		;get the first parameter to be printed. Low nibble
	bsr	abitpr		;this routine prints the parameter
	cmp.b	#2,type		;is there only one parameter
	beq	sendspa		;if so skip next parameter and print possible length
	move.l	#comma,d2		;print a comma
	move.l	#1,d3
	move.l	conhandl1,d1
	jsr	-48(a6)
	move.b	(a2),d5		;get the parameter byte again
	lsr.l	#4,d5		;shift the high nibble down to the low nibble
	bsr	abitpr		;so it can be displayed
	addq.l	#1,d7		;this is needed to keep the rest of the line lined up with the modes where only one parameter is needed -the comma is counted as well now in d7
sendspa	tst.b	(a2)+		;this is where the one parameter instruction joins up again. move a2 onto next byte (the size byte)
	move.l	#13,d6		
	sub.l	d7,d6
sendsp	bsr	spaces		;and print d6 number of spaces. this aligns the sizing into wether one or two parameter are needed
	dbra	d6,sendsp
	move.b	(a2)+,d5		;load the size byte into d5, and point a2 to next possible mode
	moveq.l	#4,d6		;d6 is a counter - note the 'q'!
	moveq.l	#1,d3		;the dos print routine leaves d3 the same when it has finished, so the length can be specified outside loop, qicker
	move.l	#lengths,d2	;address of the sizing info
sizespr	lsr.b	#1,d5		;shift d5 left once, so c flag contains the least significant bit
	bcc	sizesc		;if the bit was a 0, dont print owt
retc	move.l	conhandl1,d1	;print this size
	jsr	-48(a6)
sizesc	addq.l	#1,d2		;move d2 onto the next sizing letter
	dbra	d6,sizespr	continue until d6= -1
	move.l	#cmodei,d2	;do a carriage return
	move.l	#1,d3
	move.l	conhandl1,d1
	jsr	-48(a6)
	bra	modepr		;see if there is another mode that needs printing

* In other words, the bits of the sizing byte can be aligned like this:
* bit                :01234   but the binary way round  43210
* character printed  :[bwl]   is how it is given :      ]lwb[
* So an example command would be rol
* dc.b 'rol'   :Command name
* dc.b 0       :End of command name
* dc.b         :Well, this would be the explanation.
* dc.b 255     :End of explanation
* 	       :Now, command 1 : rol dn,dn
* dc.b 3       :2 paramaters (dn and dn)
* dc.b 32      :No extra letter, so have a space
* dc.b $00     :high nybble and low nybble are 0 ; 0 = 'dn'
* dc.b %11111  :can be byte, word or long word
*	       :Now, command 2 : rol #xxx,dn
* dc.b 3       :2 parameters
* dc.b 32      :No extra letter
* dc.b $0b     :high nybble 0 : dn  and low nybble $b : #xxx
* dc.b %11111  :same size, b, w or l
*	       :And finally, rol <ea> 
* dc.b 2       :1 parameter this time
* dc.b 32      :No extra letter
* dc.b $c      :Low nybble only.  =$c : <ea>
* dc.b %11111  :same size
* dc.b 254     :And finally the end of command byte :254.  Whew!

spaces	move.l	#space,d2		;just prints a space
	move.l	#1,d3
	move.l	conhandl1,d1
	jmp	-48(a6)
abitpr	and.l	#$f,d5		;only want low nibble of d5, rest is rubbish
	asl.l	#2,d5		;times it by 4 (ie by 2 twice)
	add.l	#modes,d5		;add it to the address which contains the addresses of the parameters. So if d5 was 0 when routine was called, it is modes now, if d5 was 4, it is modes+16
	move.l	d5,a1		;move it into an address register
	move.l	(a1),a3		;and load the address of the parameter into a3
	move.b	(a3),d3		;get the length of parameter (see parameter block at end of prog
	tst.b	(a3)+   		;shift a3 onto next byte
	move.l	a3,d2		;a3 is now the address of the parameter, so copy it into d2 for printing
	add.l	d3,d7		;update d7, see above
	move.l	conhandl1,d1	;print the parameter
	jmp	-48(a6)		;BYE!
nextc	cmp.b	#254,(a2)+	;this searches for the end of the data for present command so it can check for the next one
	bne	nextc		
	cmp.b	#255,(a2)		;if the first byte is 255 then the end of the list has been reached, so input was a load of rubbish (bloody lamers!)
	bne	check 		;if it wasnt, see if this is the command
	move.l	conhandl1,d1	;that's right, tell 'em what u think of 'em!
	move.l	#rubbish,d2
	move.l	#rubend-rubbish,d3
	jsr	-48(a6)		
	jmp	commin		;and see if they'll enter someat better next time
endcomm	bsr	close
	bra	key
commbuff
	ds.b	10
ISET
	bsr	ricopen		;open window
	move.l	conhandl1,d1	
	move.l	#insset,d2	;get address of text
	move.l	#insend-insset,d3	;calculate length of text
	jsr	-48(a6)		;print
	bsr	wait		;wait
nohelp	bsr	close		;close window
	bra	key		;back to main window

;-----------------------------------------------------------------------------
;		RAIST'S CODE
;------------------------------------------------------------------------------
MMAP
	jsr	open		;open window
	move.l	#memtext,d2	;get address of text
	move.l	#memend-memtext,d3	;length of text
	jsr	-48(a6)		;write text
	bsr	wait		;wait RMB
	bsr	close		;close the window
	bra	key		;return to main menu

****************************************************************************
;	THESE ARE THE ROUTINES TO OPEN/CLOSE WINDOWS & WAIT RMB
****************************************************************************
		
	
open
	move.l	dosbase,a6	;dos base in a6
	lea	conname2(pc),a1	;we are opening a console
	move.l	#1005,d2		;mode is old
	move.l	a1,d1
	jsr	-30(a6)		;open
	move.l	d0,conhandl1	;store handle
	rts			return

open1	move.l	dosbase,a6	;a6 = dosbase
	lea	BIG(pc),a1	;conname
dowind	move.l	#1005,d2		;mode old
	move.l	a1,d1		;doesnt seem to work without!
	jsr	-30(a6)		;open
	move.l	d0,conhandl1	;store conhandle
	move.l	conhandl1,d1
	rts			;return

ricopen	move.l	dosbase,a6	;dosbase in a6
	lea	consl1(pc),a1	;con name
	bra	dowind		;open window

close	move.l	conhandl1,d1	;routine to close the windows
	move.l	dosbase,a6	;a6 = dosbase
	jsr	-36(a6)		;close
	rts			;return
;-----------------------------------------------------------------------------
**This is the exiting point
quit
	move.l	conhandle,d1	;get handle of window
	move.l	dosbase,a6	;dos base
	jsr	-36(a6)		;close window

	move.l	conhandl2,d1	;standard CLI window
	move.l	#byetext,d2	;point to text address
	move.l	#byeend-byetext,d3	;lencth of text
	jsr	-48(a6)		;write text

	move.l	4,a6		;exec base
	move.l	dosbase,a1	;dos base address in A1
	jsr	-414(a6)		;close dos library
	moveq.l	#0,d0		;keep CLI happy!
	rts			;bye!
;----------------------------------------------------------------------------
**This section waits for the right mouse button
wait	
	btst	#$a,$dff016	;check for R.button
	bne	wait		;is it pressed
	rts			;yes!


******************************************************************************
;		PROGRAM VARIABLES
******************************************************************************

dosname	dc.b	'dos.library',0		
	even	
dosbase	dc.l	0			;dos base will be stored here
	even
consolnam	dc.b	'CON:90/30/400/213/HELPER',0	;defs for the 4 windows
	even
conname2	dc.b	'CON:100/20/406/230/RAISTLIN',0
	even
big	dc.b	'CON:0/0/640/250/RAISTLIN',0
	even
consl1	dc.b	"CON:80/20/480/210/HEARWIG",0
	even
conhandle	dc.l	0			;handle for main window
conhandl1	dc.l	0			;handle for sub windows
conhandl2 dc.l	0			;CLI handle
*******************************************************************************
;		DATA FOR THE MAIN WINDOW
*****************************************************************************
title	dc.b	$9b,"1;37;40m",$0a		
	dc.b	"            Select an option!",$0a,$0a,$0a
	dc.b	$9b,"0;32;40m"
	dc.b	'  F1...ASCII TABLE      F6...ADDRESSING MODES',$0a,$0a
	dc.b	'  F2...GURU HELP        F7...MEMORY MAP',$0a,$0a
	dc.b	'  F3...COPPER ISET      F8...DMA REGISTERS',$0a,$0a
	dc.b	'  F4...DOS.LIB          F9...CONTROL SEQUENCES ',$0a,$0a
	dc.b	'  F5...68000 HELPER    F10...QUIT   ',$0a,$0a
	dc.b	$9b,"0;31;40m"
	dc.b	"OPTION:"
	dc.b	$0a,$0a,"  ",$9b,"3;31;42m"
	dc.b	"Helper coded by Raistlin of BANANA BEASTS",$0a
	dc.b	$9b,"1;33;40m"
	dc.b	'GREETS TO:',$0a
	dc.b	'          Mark Meany & all that supply to ACC'
	dc.b	$0a,'Hearwig for help, all members of Banana Beasts'
	dc.b	$0a,'NBS for being the best PD library. All my',$0a
	dc.b	'friends!! Caramon for his help (it made it a',$0a
	dc.b	'lot faster!), your chess is very good!!',$0a
	dc.b	$9b,"0;31;40m","       ",$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0

*********************************************************************************
;	THE FOLLOWING IS THE DATA STRUCTURES WICH ARE VERY! BIG
*********************************************************************************
titleend
asciitext	dc.b	"            ",$9b,"4;33;40m","ASCII TABLE",0
	dc.b	$0a,$9b,"0;31;40m",$0a
	dc.b	'20  21  22  23  24  25  26  27  28  29  2A  2B'
	dc.b	$0a,$9b,"0;32;40m"
	dc.b	'SP  !   ',34,'   #   $   %   &   ',39,'   (   )   *   + '   
	dc.b	$0a,$0a,$9b,"0;31;40m"
	dc.b	'2C  2D  2E  2F  30  31  32  33  34  35  36  37',$0A
	dc.b	$9b,"0;32;40m"
	dc.b	',   -   .   /   0   1   2   3   4   5   6   7',$0A
	dc.b	$0A,$9B,"0;31;40m"
	dc.b	'38  39  3A  3B  3C  3D  3E  3F  40  41  42  43',$0A
	dc.b	$9B,"0;32;40m"
	dc.b	'8   9   :   ;   <   =   >   ?   @   A   B   C',$0A,$0A
	dc.b	$9b,"0;31;40m"
	dc.b	'44  45  46  47  48  49  4A  4B  4C  4D  4E  4F',$0A
	dc.b	$9b,"0;32;40m"
	dc.b	'D   E   F   G   H   I   J   K   L   M   N   O',$0A,$0A
	dc.b	$9b,"0;31;40m"
	dc.b	'50  51  52  53  54  55  56  57  58  59  5A  5B',$0A
	dc.b	$9b,"0;32;40m"
	dc.b	'P   Q   R   S   T   U   V   W   X   Y   Z   [',$0A,$0a  
	dc.b	$9b,"0;31;40m"
	dc.b	'5C  5D  5E  5F  60  61  62  63  64  65  66  67',$0A
	dc.b	$9b,"0;32;40m"    
	dc.b	'\   ]   ^   _   ',$60,'   a   b   c   d   e   f   g',$0a,$0a 
	dc.b	$9b,"0;31;40m"
	dc.b	'68  69  6A  6B  6C  6D  6E  6F  70  71  72  73',$0A
	dc.b	$9b,"0;32;40m"
	dc.b	'h   i   j   k   l   m   n   o   p   q   r   s',$0a,$0a
	dc.b	$9b,"0;31;40m"
	dc.b	'74  75  76  77  78  79  7A  7B  7C  7D  7E  7F',$0A   
	dc.b	$9b,"0;32;40m"
	dc.b	't   u   v   w   x   y   z   {   |   }   ~   DEL'
asciiend
coppertext	dc.b	"            ",$9b,"3;33;40m","COPPER INSTRUCTIONS",$0a
	dc.b	$9b,"1;33;40m"
	dc.b	'          MOVE           WAIT          SKIP',$0a
	dc.b	$9b,"1;32;40m"
	dc.b	'  Bit#  IR1   IR2      IR1   IR2     IR1   IR2',$0a
	dc.b	$9b,"0;31;40m"
	dc.b	'  15  |  X  | RD15  |  VP7  | BFD  | VP7 | BFD',$0a
	dc.b	'  14  |  X  | RD14  |  VP6  | VE6  | VP6 | VE6',$0a
	dc.b	'  13  |  X  | RD13  |  VP5  | VE5  | VP5 | VE5',$0a
	dc.b	'  12  |  X  | RD12  |  VP4  | VE4  | VP4 | VE4',$0a
	dc.b	'  11  |  X  | RD11  |  VP3  | VE3  | VP3 | VE3',$0a
	dc.b	'  10  |  X  | RD10  |  VP2  | VE2  | VP2 | VE2',$0a
	dc.b	'  09  |  X  | RD09  |  VP1  | VE1  | VP1 | VE1',$0a
	dc.b	'  08  | DA8 | RD08  |  VP0  | VE0  | VP0 | VE0',$0a
	dc.b	'  07  | DA7 | RD07  |  HP8  | HE8  | HP8 | HE8',$0a
	dc.b	'  06  | DA6 | RD06  |  HP7  | HE7  | HP7 | HE7',$0a
	dc.b	'  05  | DA5 | RD05  |  HP6  | HE6  | HP6 | HE6',$0a
	dc.b	'  04  | DA4 | RD04  |  HP5  | HE5  | HP5 | HE5',$0a
	dc.b	'  03  | DA3 | RD03  |  HP4  | HE4  | HP4 | HE4',$0a
	dc.b	'  02  | DA2 | RD02  |  HP3  | HE3  | HP3 | HE3',$0a
	dc.b	'  01  | DA1 | RD01  |  HP2  | HE2  | HP2 | HE2',$0a
	dc.b	'  00  |  0  | RD00  |   1   |  0   |  1  |  1',$0a	    
	dc.b	'X=Dont care, but should be a 0 4 compatability.',$0a
	dc.b	'IR1=First instruction word.',$0a
	dc.b	'IR2=Second Instruction word.',$0a
	dc.b	'DA=Destination address.',$0a
	dc.b	'RD=RAM data to be moved to destination register.',$0a
	dc.b	'VP=Vertical Beam pos. HP=Horizontal beam pos.',$0a	
	dc.b	'VE=Enable comparison. HE=Enable comparison.',$0a
	dc.b	'BFD=Blitter-finished disable.',0
copperend
memtext
	dc.b	"               ",$9b,"4;33;40m"
	dc.b	'MEMORY MAP',$0a,$0a
	dc.b	$9b,"0;31;40m"
	dc.b	'ADDRESS RANGE      NOTES',$0a
	dc.b	$9b,"1;32;40m"
	dc.b	'$000000-$03FFFF    256K of CHIP RAM',$0a    
	dc.b	'$040000-$07FFFF    256K of CHIP RAM (opt. card)',$0a
	dc.b	'$080000-$0FFFFF    512K Ext. CHIP RAM (optnal)',$0a
	dc.b	'$100000-$1FFFFF    Reserved. Do not use',$0a
	dc.b	'$200000-$9FFFFF    Primary 8 MB space',$0a
	dc.b	'$A00000-$BEFFFF    Reserve. Do not use',$0a
	dc.b	'$BFD000-$BFDF00    8520-B (Access at even-bye',$0a
	dc.b	'    -       -              addresses only)',$0a
	dc.b	'$BFE001-$BFEF01    8520-A (Access at odd-bye',$0a
	dc.b	'    -       -              addesses only)',$0a
	dc.b	'$C00000-$DFEFFF    Reserved. Do not use',$0a
	dc.b	' |$C00000-$D7FFFF  Internal expansion memory',$0a
	dc.b	' |$D80000-$DBFFFF  Reserved. Do not use',$0a
	dc.b	' |$DC0000-$DCFFFF  Real time clock',$0a
	dc.b	' |$DFF000-$DFFFFF  Chip registers',$0a
	dc.b	'$E00000-$E7FFFF    Reserved. Do not use',$0a
	dc.b	'$E80000-$E8FFFF    Auto-config space. Boards',$0a
	dc.b	'	 appear here before the sys. relocates',$0a
	dc.b	'            them to their final addresses',$0a
	dc.b	'$E90000-$EFFFFF    Secondary auto-config space',$0a
	dc.b	'	       (Usually 64K I/O boards)',$0a
	dc.b	'$F00000-$FBFFFF    Reserved. Do not use',$0a
	dc.b	'$FC0000-$FFFFFF    256K system ROM',$0a
memend
gurutext	dc.b	"                              ",$9b,"4;33;40m"
	dc.b	'GURU HELP',$0a
	dc.b	$9b,"0;31;40m"
	dc.b	'A guru meditation number has 16 hexadecimal digits ie',$0a
	dc.b	'81000009.00281002',$0a
	dc.b	'This message can be decoded as follows',$0a
	dc.b	'SSGESPER.00ADDRES',$0a
	dc.b	'SS.....Two digit subsystem code        GE.......Two-digit general error code',$0a
	dc.b	'SPER...Four-digit specific error code  ADDRES...Six-digit task memory address',$0a
	dc.b	$0a,'SUBSYSTEMS: ',$0a
	dc.b	'CODE   MEANING			CODE   MEANING',$0a
	dc.b	' 00    CPU Trap (see below)	 21    Disk',$0a
	dc.b	' 01    Exec			 22    Miscellaneous',$0a
	dc.b	' 02    Graphics			 30    BootStrap',$0a
	dc.b	' 03    Layers			 31    Workbench ',$0a
	dc.b	' 04    Intuition		 32    Diskcopy',$0a
	dc.b	' 05    Math',$0a
	dc.b	' 06    Clist   *NB Sometimes the first digit of the subsystem is an 8',$0a
	dc.b	' 07    Dos	     (as in the example above). In that case, ignore the 8,',$0a
	dc.b	' 08    Ram	  and read the subsystem number, a 1 in our case. That',$0a
	dc.b	' 09    Icon     means there was an Exec error.',$0a
	dc.b	' 0A    Expansion',$0a
	dc.b	' 10    Audio',$0a
	dc.b	' 11    Console',$0a
	dc.b        ' 12    Gameport',$0a
	dc.b	' 13    Keyboard',$0a
	dc.b	' 14    Trackdisk',$0a
	dc.b	' 15    Timer',$0a
	dc.b	' 20    CIA chip',$0a	
guruend
gurutext1
	dc.b	$0a,'GENERAL ERROR CODES:',$0a
	dc.b	'CODE   MEANING			CODE   MEANING',$0a
	dc.b	' 01    Not enough memory	 02    Makelibrary',$0a
	dc.b	' 03    Openlibrary		 04    OpenDevice',$0a
	dc.b	' 05    OpenResource		 06    I/O Error',$0a
	dc.b	' 07    Signal Absent',$0a,$0a
	dc.b	'SPECIFIC ERROR CODE:',$0a
	dc.b	'EXEC',$0a
	dc.b	'CODE    MEANING			       CODE   MEANING',$0a
	dc.b	'0001    Checksum: exception vector     0002   Checksum: Execbase',$0a
	dc.b	'0003    Checksum: Library	       0004   No memory for library',$0a
	dc.b	'0005    Memory list damaged	       0006   No memory for interrupt server',$0a
	dc.b	'0007    InitAPtr		       0008   Damaged Semaphore',$0a
	dc.b	'0009    Cant free already free memor   000A   Bogus Exception',$0a
guruend1
gurutext2	dc.b	$0a,'GRAPHICS:',$0a
	dc.b	'CODE	MEANING',$0a
	dc.b	'0001       No memory for copper display list',$0a
	dc.b	'0002       No memory for copper instruction list',$0a
	dc.b	'0003       Overloaded copper list',$0a
	dc.b	'0004       Overloaded copper intermediate list',$0a
	dc.b	'0005       No memory for copper list head',$0a
	dc.b	'0006       No memory (long frame)',$0a
	dc.b	'0007       No memory (short frame)',$0a
	dc.b	'0008       No memory for flood fill',$0a
	dc.b	'0009       No memory for TmpRas in text operation',$0a
	dc.b	'000A       No memory for BlitBipmap call',$0a
	dc.b	'000B       Region Memory',$0a
	dc.b	'0030       MakeVPort error',$0a
	dc.b	'1234       GfxNoLCM',$0a,$0a
	dc.b	'Layers:',$0a
	dc.b	'CODE        MEANING',$0a
	dc.b	'0001        No memory',$0a,$0a
	
guruend2
gurutext3
	dc.b	'Intuition:',$0a
	dc.b	'CODE       MEANING',$0a
	dc.b	'0001       Unknown gadget type',$0a  
	dc.b	'0002       No memory for port',$0a
	dc.b	'0003       No memory to allocate item plane',$0a
	dc.b	'0004       No memory for sub allocation',$0a
	dc.b	'0005       No memory for plane allocation',$0a
	dc.b	'0006       Items top less than RelZero',$0a
	dc.b	'0007       No memory to open screen',$0a
	dc.b	'0008       No memory to allocate screen raster',$0a
	dc.b	'0009       Unknown screen type to window',$0a
	dc.b	'000A       No memory to add SW gadgets',$0a
	dc.b	'000B       No memory to open window',$0a
	dc.b	'000C       Bad state return entering intuition',$0a
	dc.b	'000D       Bad message recieved by IDCMP',$0a
	dc.b	'000E       Weird echo causing incomprehension',$0a
	dc.b	'000F       Cant open console device',$0a,$0a
guruend3
gurutext4
	dc.b	'Dos:',$0a
	dc.b	'CODE       MEANING',$0a
	dc.b	'0001       No memory at startup',$0a
	dc.b	'0002       EndTask did not end task',$0a
	dc.b	'0003       Qpkt quik I/O failure',$0a
	dc.b	'0004       Unexpected packet recieved',$0a
	dc.b	'0005       Freevec failure',$0a
	dc.b	'0006       Disk block sequence error',$0a
	dc.b	'0007       Bitmap damaged',$0a
	dc.b	'0008       Key already free',$0a
	dc.b	'0009       Checksum error',$0a
	dc.b	'000A       Disk error',$0a
	dc.b	'000B       Key out of ranged',$0a
	dc.b	'000C       Bad overlay (may be linker-related)',$0a,$0a
	dc.b	'RAM:',$0a
	dc.b	'CODE       MEANING',$0a
	dc.b	'0001       Bad smement list',$0a,$0a
	dc.b	'Expansion:',$0a
	dc.b	'CODE       MEANING',$0a
	dc.b	'0001       Bad expansion free',$0a,$0a
	dc.b	'TrackDisk:',$0a
	dc.b	'CODE       MEANING',$0a
	dc.b	'0001       Calibration timing seek error',$0a
	dc.b	'0002       Timer wait error',$0a,$0a,$0
guruend4
gurutext5
	dc.b	'Timer:',$0a
	dc.b	'CODE       MEANING',$0a
	dc.b	'0001       Bad request',$0a
	dc.b	'0002       Bad supply',$0a,$0a
	dc.b	'Disk:',$0a
	dc.b	'CODE       MEANING',$0a
	dc.b	'0001       Unit already has disk',$0a
	dc.b	'0002       Interrupt; no active unit',$0a,$0a
	dc.b	'BootStrap:',$0a
	dc.b	'CODE       MEANING',$0a
	dc.b	'0001       system boot code returned error',$0a,$0a
	dc.b	'CPU Traps are internal microprocessor error:',$0a
	dc.b	'CODE       MEANING',$0a
	dc.b	'0002       Bus error',$0a
	dc.b	'0003       Address error',$0a
	dc.b	'0004       Illegal instruction',$0a
	dc.b	'0005       Divide by zero',$0a
	dc.b	'0006       CHK instruction',$0a
	dc.b	'0007       TRAPV (TrapVector) instruction',$0a
	dc.b	'0008       Supervisor mode privilege violation',$0a
	dc.b	'0009       Trace',$0a
	dc.b	'000A       Line A trap (OpCode 1010)',$0a
	dc.b	'000B       Line B trap (OpCode 1011)',$0a,$0a,$0
guruend5
gurutext6
	dc.b	'The CPU trap errors can often be traced back to programming errors like',$0a
	dc.b	'misused instruction sizes. Arranging the program so that words or long',$0a
	dc.b	'words fall on odd memory addresses frequently results in 00000003 or',$0a
	dc.b	'00000004 errors.',$0a
	dc.b	'The actual subsystem general and specific errors above are usually traceable',$0a
	dc.b	'to misuse of memory (for instance, tyring to free memory that is already',$0a
	dc.b	'free) or the failure of a library function. If a library function call',$0a
	dc.b	'returns an error code and your program does not bother to repond to it, the',$0a
	dc.b	'program will usually crash and present you with a guru message. For example',$0a
	dc.b	'if OpemWindow fails and a program tries later to attach a menu to the ',$0a
	dc.b	'nonexistant window, you will run into problems. If you try to allocate',$0a
	dc.b	'memory and fail, and then try to use the nonexistant memory, be prepared',$0a
	dc.b	'to visit the guru. Memory that is not currently allocated cannt be freed.',$0a
	dc.b	' The process of debugging is an art, and a complete discussion of machine',$0a
	dc.b	'language debugging would fill an entire book. You should always check for',$0a
	dc.b	'errors after any library call, this will help to reduce problems later on.',$0a
	dc.b	'The best debugging is prevention! The Amiga ROM Kernal-Reference Manual:EXEC',$0a
	dc.b	'has more information on Amiga debugging tools.',$0a
	dc.b	' The guru meditation example 81000009.00xxxxxx means Exec error (ignore)',$0a
	dc.b	'initial eight), General Error 00 (no general error) and Specific Error 0009',$0a
	dc.b	'(tried to free memory already free). The xxxxx will be the address of the',$0a
	dc.b	' instruction that caused the error.',$0a,$0a
 	dc.b	'The information here was taken from a document by M J Cross.',$0a
	dc.b	'Typed for you by RAISTLIN 20:15   9 January 1990',$0
guruend6
dostext1
	dc.b	'                            ',$9b,"4;33;40m"
	dc.b	'dos.library'
	dc.b	$0a,$9b,"0;31;40m",'The parameter names & their parameters are in parenthesis after the function',$0a
	dc.b	'name. The 2nd set of parenthesis includes a list of registers that correspond',$0a
	dc.b	'to the parameter names. If no parameters are needed, Ive put () to let you   know.'
	dc.b	$0a,$9b,"0;32;40m"
	dc.b	'-30    Open (name,accesMode) (D1,D2)',$0a
	dc.b	'-36    Close (file) (D1)',$0a
	dc.b	'-42    Read (file,buffer,length) (D1,D2,D3)',$0a
	dc.b	'-48    Write (file,buffer,length) (D1,D2,D3)',$0a
	dc.b	'-54    Input ()',$0a	
	dc.b	'-60    Output ()',$0a
	dc.b	'-66    Seek (file,posistion,offset) (D1,D2,D3)',$0a
	dc.b	'-72    DeleteFile (name) (D1)',$0a
	dc.b	'-78    Rename (oldName,newName) (D1,D2)',$0a
	dc.b	'-84    Lock (name,type) (D1,D2)',$0a
	dc.b	'-90    Unlock (lock) (D1)',$0a
	dc.b	'-96    Duplock (lock) (D1)',$0a
	dc.b	'-102   Examine (lock,fileInfoBlock) (D1,D2)',$0a
	dc.b	'-108   ExNext (lock,fileInfoBlock) (D1,D2)',$0a
	dc.b	'-114   Info (lock,parameterBlock) (D1,D2)',$0a
	dc.b	'-120   CreateDir (name) (D1)',$0a
	dc.b	'-126   CurrentDir (lock) (D1)',$0a
	dc.b	'-132   IoErr ()',$0a
	dc.b	'-138   CreateProc (name,pri,segList,stackSize) (D1,D2,D3,D4)',$0a
	dc.b	'-144   Exit (returncode) (D1)',$0a
	dc.b	'-150   LoadSeg (FileName) (D1)',$0a
	dc.b	'-156   UnloadSeg (segment) (D1)',$0a
dosend1	dc.b	'-162   GetPacket (wait) (D1)',$0a
dostext2	dc.b	'-168   QueuePacket (packet) (D1)',$0a
	dc.b	'-174   DeviceProc (name) (D1)',$0a
	dc.b	'-180   SetComment (name,comment) (D1,D2)',$0a
	dc.b	'-186   SetProtection (name,mask) (D1,D2)',$0a
	dc.b	'-192   DateStamp (date) (D1)',$0a
	dc.b	'-198   Delay (timeout) (D1)',$0a
	dc.b	'-204   WaitForChar (file,timeout) (D1,D2)',$0a
	dc.b	'-210   ParentDir (lock) (D1)',$0a
	dc.b	'-216   IsInteractive (file) (D1)',$0a
	dc.b	'-222   Execute (string,file,file) (D1,D2,D3)',$0a,$0	
	dc.b	$9b,"4;33;40m",'console.library',$0a,$9b,"0;32;40m"
	dc.b	'-42    CDInputHandler (events,device) (A0,A1)',$0a
	dc.b	'-48    RawKeyConvert (events,buffer,length,KeyMap) (A0,A1,D1,A2)',$0a
	dc.b	$9b,"4;33;40m",'potogo.library',$0a,$9b,"0;32;40m"
	dc.b	'-6     AllocPotBits (bits) (D0)',$0a
	dc.b	'-12    FreePotBits (bits) (D0)',$0a
	dc.b	'-18    WritePotgo (word,mask) (D0,D1)',$0a
	dc.b	$9b,"4;33;40m",'timer.library',$0a,$9b,"0;32;40m"
	dc.b	'-42    AddTime (dest,src) (A0,A1)',$0a
	dc.b	'-48    SubTime (dest,src) (A0,A1)',$0a
	dc.b	'-54    CmpTime (dest,src) (A0,A1)',$0a
	dc.b	$9b,"4;33;40m",'translator.library',$0a,$9b,"0;32;40m"
	dc.b	'-30    Translate (inputString,inputLength,PotputBuffer,buffersize) (A0,D0,A1,D1)',$0a
	dc.b	$0a,$9b,"3;31;40m"
	dc.b	'These tables where taken from ABICUS',$27,'s AMIGA MACHINE LANGUAGE',$0a
	dc.b	'Brought to you by RAISTLIN  21:15  September 9th 1990',$9b,"0;31;40m",$0
dosend2

insset	dc.b	$9b,'3;33;40mAddressing Modes',$a,$a,$9b,'0;32;40m'
	dc.b	'<ea> can represent any of these below:',$a
	dc.b	'Dn      data register n (0-7)',$a
	dc.b	'An      address register n (0-7)',$a
	dc.b	'(An)    indirect addressing with address register',$a
	dc.b	'        - uses contents of address specified by register',$a
	dc.b	'(An)+   postincrement indirect - like (An) but the',$a 
	dc.b	'        register is increased by a byte word or long',$a
	dc.b	'        word after instrucion.',$a
	dc.b	'-(An)   predecrement indirect - like (An) but the',$a
	dc.b	'        register is decreased by a byte, word or',$a
	dc.b	'        long word before instruction',$a
	dc.b	'd(An)   indirect with offset - uses contents of',$a
	dc.b	'        address pointed to by address register + d',$a
	dc.b	'#xxx    the number xxx is used.',$a
	dc.b	'xxxx    contents of address xxxx.',$a
	dc.b	'CCR     control codes register.',$a
	dc.b	'SR      status register.',$a
	dc.b	'PC      program counter.  Can be used like',$a
	dc.b	'        d(An), ie. d is the offset from current',$a
	dc.b	'        instruction, ie. d(PC)',$a
	dc.b	'<label> offset used for branching'
insend

commreq	dc.b	$9b,"3;31;40m",$a,"Your command, please, sire, or return to quit",$a,$a,$9b,"0;32;40m"
commend
rubbish	dc.b	$9b,'0;33;40mCommand not recognised'
rubend
commands
	dc.b	'abcd',0,'add (in decimal) source and X flag to destination',255
	dc.b	3,32,0,$13,3,32,$44,$13
	dc.b	254,'add',0,'add source to destination',255
	dc.b	3,32,$c0,$1f,3,32,$c,$1f,3,'a',$1c,$1d,3,'i',$cb,$1f,3,'q',$cb,$1f,3,'x',0,$1f,3,'x',$44,$1f
	dc.b	254,'and',0,'and source with destination, the result going into the destination',255
	dc.b	3,32,$c0,$1f,3,32,$c,$1f,3,'i',$cb,$1f,3,'i',$db,$13
	dc.b	254,'asl',0,'shift operand left the specified number of times, the most significant bit going into the C and X flags, and a 0 is shifted into the lowest bit',255
	dc.b	3,32,0,$1f,3,32,$b,$1f,2,32,$c,$1f
	dc.b	254,'asr',0,'shift operand right the specified number of times, the least significant bit going into the C and X flags, and the most significant (sign) bit stays the same',255	
	dc.b	3,32,0,$1f,3,32,$b,$1f,2,32,$c,$1f
	dc.b	254,'bcc',0,'branch if condition set',255
	dc.b	2,32,$e,$17
	dc.b	254,'bchg',0,'test if the destination bit specified by source is 0, then change the bit',255
	dc.b	3,32,$c0,$1b,3,32,$cb,$1b
	dc.b	254,'bclr',0,'test if the destination bit specified by source is 0, then  clear the bit',255
	dc.b	3,32,$c0,$1b,3,32,$cb,$1b
	dc.b	254,'bra',0,'branch always - like jmp but shorter (uses 16 bit offset)',255
	dc.b	2,32,$e,$17
	dc.b	254,'bset',0,'test if the destination bit specified by source is 0, then set the bit',255
	dc.b	3,32,$c0,$1b,3,32,$cb,$1b
	dc.b	254,'bsr',0,'branch to subroutine - like jsr but shorter (uses 16 bit offset)',255
	dc.b	2,32,$e,$17
	dc.b	254,'btst',0,'test if the destination bit specified by source is 0',255
	dc.b	3,32,$c0,$1b,3,32,$cb,$1b
	dc.b	254,'clr',0,'clear operamd',255
	dc.b	2,32,$c,$1f
	dc.b	254,'cmp',0,'compare source with destination',255
	dc.b	3,32,$c,$1f,3,'a',$1c,$1d,3,'i',$cb,$1f,3,'m',$33,$1f
	dc.b	254,'dbcc',0,'if condition is met or data register =-1 then do nothing, else decrement data register and branch',255
	dc.b	3,32,$e0,$15
	dc.b	254,'div',0,'divide destination by source, putting result in destination.  divu is unsigned, divs is signed',255
	dc.b	3,'s',$c,$15,3,'u',$c,$15
	dc.b	254,'eor',0,'exclusive or the source and destination, putting result in destination',255
	dc.b	3,32,$c0,$1f,3,'i',$cb,$1f,3,'i',$db,$13
	dc.b	254,'exg',0,'exchange the source and destination, ie. source=destination and destination=source',255
	dc.b	3,32,0,$19,3,32,$11,$19,3,32,$10,$19
	dc.b	254,'ext',0,'destination extended from a byte to a word or a word to a long word.  The old sign bit is copied to the new one',255
	dc.b	2,32,0,$1d
	dc.b	254,'jmp',0,'jump to the specified address',255
	dc.b	2,32,$c,$11
	dc.b	254,'jsr',0,'jump to the specified address, and when an `rts` is executed, return to next instruction',255
	dc.b	2,32,$c,$11
	dc.b	254,'lea',0,'load effective address into address register',255
	dc.b	3,32,$1c,$19
	dc.b	254,'lsl',0,'logical shift left - shift operand left the specified number of times, the most significant bit going into the C and X flags, and a 0 being shifted into the lowest bit',255
	dc.b	3,32,0,$1f,3,32,$b,$1f,3,32,$c,$1f
	dc.b	254,'lsr',0,'logical shift right - shift operand right the specified number of times, the least signficant bit going into the C and X flags, and a 0 being shifted into the highest bit',255
	dc.b	3,32,0,$1f,3,32,$b,$1f,3,32,$c,$1f
	dc.b	254,'move',0,'move source into destination',255
	dc.b	3,32,$cc,$1f,3,'a',$1c,$1d,3,32,$cd,$15,3,32,$dc,$15,3,'m',$cf,$1d,3,'m',$fc,$1d,3,'p',$50,$1d,3,'p',5,$1d,3,'q',$b,$19
	dc.b	254,'mul',0,'signed multiply - the source and destination are multiplied, muls is signed, mulu is unsigned',255
	dc.b	3,'s',$c,$15,3,'u',$c,$15
	dc.b	254,'nbcd',0,'subtract (in decimal) the operand and X flag from 0, putting result in operand',255
	dc.b	2,32,$c,$13
	dc.b	254,'neg',0,'subtract operand from 0 and replace in operand.  negx takes operand and X flag from 0',255
	dc.b	2,32,$c,$1f,2,'x',$c,$1f
	dc.b	254,'nop',0,'no operation - does nothing',255
	dc.b	1,32
	dc.b	254,'not',0,'all affected bits of the operand are changed',255
	dc.b	2,32,$c,$1f
	dc.b	254,'or',0,'or the source and destination, putting the result into the destination',255
	dc.b	3,32,$c,$1f,3,32,$c0,$1f,3,'i',$cb,$1f,3,'i',$db,$13
	dc.b	254,'pea',0,'push the effective address onto the stack',255
	dc.b	2,32,$c,$19
	dc.b	254,'rol',0,'rotate operand left the specified number of times, the C flag going into the least significant bit and the highest bit going into the C flag.',255
	dc.b	3,32,0,$1f,3,32,$b,$1f,2,32,$c,$1f
	dc.b	254,'ror',0,'rotate operand right the specified number of times, the C flag going into the most significant bit and the lowest bit going into the C flag.',255
	dc.b	3,32,0,$1f,3,32,$b,$1f,2,32,$c,$1f
	dc.b	254,'roxl',0,'rotate operand left the specified number of times, the X flag going into the least significant bit, the highest bit going into the C flag and the C flag into the X flag.',255
	dc.b	3,32,0,$1f,3,32,$b,$1f,2,32,$c,$1f
	dc.b	254,'roxr',0,'rotate operand right the specified number of times, the X flag going into the most significant bit, the lowest bit going into the C flag and the C flag into the X flag,',255
	dc.b	3,32,0,$1f,3,32,$b,$1f,2,32,$c,$1f
	dc.b	254,'rtr',0,'pull condition codes and program counter from the stack',255
	dc.b	1,32
	dc.b	254,'rts',0,'return from subroutine - go back to instruction after last unreturned jsr command',255
	dc.b	1,32
	dc.b	254,'sbcd',0,'subtract (in decimal) source and X flag from destination',255
	dc.b	3,32,0,$13,1,32,$33,$13
	dc.b	254,'scc',0,'if condition true, operand filled with 1s else filled with 0s',255
	dc.b	2,32,$c,$13
	dc.b	254,'sub',0,'subtract source from destination',255
	dc.b	3,32,$c0,$1f,3,32,$c,$1f,3,'a',$1c,$1d,3,'i',$cb,$1f,3,'q',$cb,$1f,3,'x',0,$1f,3,'x',$33,$1f
	dc.b	254,'swap',0,'swap the two 16-bit halves of the data register round',255
	dc.b	2,32,0,$15
	dc.b	254,'tst',0,'compare operand with 0',255
	dc.b	2,32,$c,$1f
	dc.b	254,'unlk',0,'load stack pointer from address register',255
	dc.b	1,32
	dc.b	254,255
cmodei	dc.b	$a,$9b,'3;33;40mPossible modes:',$9b,'0;31;40m',$a
cmodeie
	even
modes	dc.l	dn,an,and,andp,andm,dan,danxx,xxxw,xxxl,dpc,dpcxx,xxx,ea,ccr,sr,reglist
dn	dc.b	2,'dn'
an	dc.b	2,'an'
and	dc.b	4,'(an)'
andp	dc.b	5,'(an)+'
andm	dc.b	5,'-(an)'
dan	dc.b	6,'(d,an)'
danxx	dc.b	8,'d(an,xx)'
xxxw	dc.b	5,'xxx W'
xxxl	dc.b	5,'xxx L'
dpc	dc.b	5,'d(pc)'
dpcxx	dc.b	8,'d(pc,xx)'
xxx	dc.b	4,'#xxx'
ea	dc.b	4,'<ea>'
ccr	dc.b	3,'ccr'
sr	dc.b	7,'<label>'
reglist	dc.b	8,'reg list'
comma	dc.b	','
space	dc.b	32
lengths	dc.b	'{bwl}'
type	dc.b	0
helphi	dc.b	$9b,'1;30;42mWhere control codes are concerned, please use cc instead of actual control code (eg. beq becomes bcc).  Type all commands in lower case.'
helphie
cstext
	dc.b	'             ',$9b,"4;33;40m"
	dc.b	'CONTROL CHARACTERS',$0a,$9b,"3;32;40m",$0a
	dc.b	'SEQUENCE		FUNCTION',$0a
	dc.b	$9b,"0;31;40m"
	dc.b	'08			Backspace',$0a
	dc.b	'0A			Line feed, cursor down',$0a
	dc.b	'0B			Move cursor up a line',$0a
	dc.b	'0C			Clear screen',$0a
	dc.b	'0D			Carriage return, cursor in the first column',$0a	
	dc.b	'0E			Turn on normal characters (cancels OF effects)',$0a
	dc.b	'0F			Turn on special characters',$0a
	dc.b	'1B			Escape',$0a
	dc.b	$9b,"0;32;40m"
	dc.b	'The following sequences begin with $9b, the CSI (Control Sequence ,',$0a
	dc.b	'Introducer). The characters that follow execute a function. The values',$0a
	dc.b	'in square brackets can be left off. The ns you see represent one or more',$0a
	dc.b	'digit decimal numbers given using ASCII characters. THe value that is used',$0a
	dc.b	'when n is left off, is given in the parenthesis that follow n in the description of the function table.',$0a
	dc.b	$9b,"0;33;40m"
	dc.b	'SEQUENCE		FUNCTION',$0a,$9b,"0;31;40m"
	dc.b	'9B [n]40		Insert n blanks',$0a
	dc.b	'9B [n]41		Move cursor n (1) lines up',$0a
	dc.b	'9B [n]42		Move cursor n (1) lines down',$0a
	dc.b	'9B [n]43		move cursor n (1) characters to the right',$0a
	dc.b	'9B [n]44		move cursor n (1) characters to the left',$0a
	dc.b	'9B [n]45		move cursor down n (1) lines into column 1',$0a
	dc.b	'9B [n]46		move cursor up n (1) lines and into column 1',$0a
	dc.b	'9B [n] [3B n]48		Cursor in line; set column',$0a
	dc.b	'9B 4A			Erase screen from the cursor',$0a
cstextend	dc.b	'9B 4B			Erase line from the cursor',$0a
cs1text
	dc.b	'9B 4C			Insert line',$0a
	dc.b	'9B 4D			Delete line',$0a
	dc.b	'9B [n] 50		Delte n characters starting at cursor',$0a
	dc.b	'9B [n] 53		Move up n lines',$0a
	dc.b	'9B [n] 54		Move down n lines',$0a
	dc.b	'9B 32 30 68		Line feed => line feed + return',$0a
	dc.b	'9B 32 30 6C		Line feed => just line feed',$0a
	dc.b	'9B 6E			Sends the cursor position! A string of the following                         form is retruned:'
	dc.b				'9B (line) 3B (column) 52',$0a,$0a
	dc.b	'9B (style);(foreground colour);(background colour); 6D',$0a
	dc.b	'The three parameters are decimal numbers in ASCII format. They mean',$0a
	dc.b	'		style	0=normal',$0a
	dc.b	'			1=bold',$0a
	dc.b	'			3=italic',$0a
	dc.b	'			4=underlined',$0a
	dc.b	'			7=inverse',$0a
	dc.b	'		Foreground colour: 30-37',$0a
	dc.b	'		Colour 0-7 for text',$0a
	dc.b	'		background colour: 40-47',$0a
	dc.b	'		colour 0-7 for background',$0a,$0a
	dc.b	'9B (length) 74		sets the maximum number lines to be displayed',$0a
cs1textend
cs2text
	dc.b	'9B (width) 75		sets the maximum line length',$0a
	dc.b	'9B (distance) 78	defines the distance in pixels from the left border ',$0a
	dc.b	'			of the window to the place where output should begin',$0a
	dc.b	'9B (distance) 79 	derines the distance in pixels from the upper border',$0a
	dc.b	'			of the window to the place where output should begin',$0a 
	dc.b	'9B 30 20 70		make cursor invisible!!',$0a
	dc.b	'9B 20 70			make cursor visible!!',$0a
	dc.b	'9B 71			sends window construction. A string of the following',$0a
	dc.b	'			form is returned:',$0a
	dc.b	'			9B 31 3B 31 3B (lines) 3B (columns) 73	'
	dc.b	$9b,"7;31;32m",$0a
	dc.b	'Info from Amiga machine language by Abicus.',$0a,$9b,"3;31;42m"
	dc.b	'Brought to you by Raistlin 21.2.91.'
cs2textend
dmatext	dc.b	'             		   ',$9b,"4;33;40m",'DMA REGISTERS',$0a,$0a
	dc.b	$9b,"0;33;40m"
	dc.b	'The following codes & abbreviations are used in this table:',$0a
	dc.b	'&..Register used by DMA channel only',$0a
	dc.b	'%..Register used by DMA channel usually, processor sometimes.',$0a
	dc.b      '+..Address regiseter pair. Must be an even address pointing to chip memory',$0a
	dc.b	'*..Address not writable by the copper',$0a
	dc.b	'~..Address not writeable by the copper unless copper danger bit is set,',$0a
	dc.b	'   COPCON is true',$0a
	dc.b	'A,D,P....A=agnus chip, D=Denise chip P=Paula chip',$0a
	dc.b	'W,R......W=Write only, R=Read only',$0a
	dc.b	'ER.......Early read. This is a DMA data transfer to ram, from either the disk',$0a
	dc.b	'or the blitter, RAM timing requires data to be on the bus earlier than',$0a
	dc.b	'microprocessor read cycles. These transfers are therefor initiated by Agnus',$0a
	dc.b	'timing, rarther than a read address on the destination address bus.',$0a
	dc.b	'S........Strobe (write address with no register bits). Writing the register',$0a
	dc.b	'         causes the effect.',$0a
dmaend
dma1text
	dc.b	$9b,"0;32;40m"
	dc.b	'NAME     ADD    R/W  CHIP                       FUNCTION',$0a
	dc.b	$9b,"0;31;40m"
	dc.b	'BLTDDAT  &*000   ER   A     Blitter destination early read (dummy address)',$0a
	dc.b	'DMACONR   *002   R    A P   DMA control (and blitter status read)',$0a 
	dc.b	'VPOSR     *004   R    A     Read vert most signif. bit (and frame flop)',$0a
	dc.b	'VHPOSR    *006   R    A     Read vert and horiz. posistion of beam',$0a
	dc.b	'DSKDATR  &*008   ER     P   Disk data read early read (dummy address)',$0a
	dc.b	'JOY0DAT   *00A   R   D      Joystick-mouse 0 data (vert,horiz)',$0a
	dc.b	'JOY1DAT   *00C   R   D      Joystick-mouse 1 data (vert,horiz)',$0a
	dc.b	'CLXDAT    *00E   R   D      Collision data register (read and clear)',$0a
	dc.b	'ADKCONR   *010   R     P    Audion, disk control register read',$0a
	dc.b	'POT0DAT   *012   R     P    Pot counter pair 0 data (vert,horiz)',$0a
	dc.b	'POT1DAT   *014   R     P    Pot counter pair 1 data (vert,horiz)',$0a
	dc.b	'POTGOR    *016   R     P    Pot port data read (formerly POTINP)',$0a
	dc.b	'SERDATR   *018   R     P    Serial port data and status read',$0a
	dc.b	'DSKBYTR   *01A   R     P    Disk data byte and status read',$0a
	dc.b	'INTENAR   *01C   R     P    Interupt enable bits read',$0a
	dc.b	'INTREQR   *01E   R     P    Interupt request bits read',$0a
	dc.b	'DSKPTH   +*020   W    A     Disk pointer (high 3 bits)',$0a
	dc.b	'DSKPTL   +*022   W    A     Disk pointer (low 15 bits)',$0a
	dc.b	'DSKLEN    *024   W     P    Disk length ',$0a
	dc.b	'DSKDAT   &*026   W     P    Disk DMA data write',$0a
	dc.b	'REFPTR   &*028   W    A     Refresh pointer',$0a
	dc.b	'VPOSW     *02A   W    A     Write vert most signif. Bit (& frame flop)',$0a
	dc.b	'VHPOSW    *02C   W    A     Write verst & horiz pos of beam',$0a
dma1end
dma2text
	dc.b	'COPCON    *02E   W    A     Coporocessor control register (CDANG)',$0a
	dc.b	'SERDAT    *030   W     P    Serial port data & stop bits write',$0a
	dc.b	'SERPER    *032   W     P    Serial port period & control',$0a
	dc.b	'POTGO     *034   W     P    Potpport data write & start',$0a
	dc.b	'JOYTEST   *036   W   D      Write to all 4 joystick-mouse counters at once',$0a
	dc.b	'STREQU   &*038   S   D      Strobe for horiz sync with VB & EQU',$0a
	dc.b	'STRVBL   &*03A   S   D      Strobe for horiz sync with VB (vert. blank)',$0a
	dc.b	'STRHOR   &*03C   S   D P    Strobe for horiz sync',$0a
	dc.b	'STRLONG  &*03E   S   D      Strobe for identification of long horiz. Line.',$0a
	dc.b	'BLTCON0   ~040   W    A     Blitter control register 0',$0a
	dc.b	'BLTCON1   ~042   W    A     Blitter control register 1',$0a
	dc.b	'BLTAFWM   ~044   W    A     Blitter 1st word mask for source A',$0a
	dc.b	'BLTALWM   ~046   W    A     Blitter last word mask for source A',$0a
	dc.b	'BLTCPTH  +~048   W    A     Blitter ptr to source C (high 3 bits)',$0a
	dc.b	'BLTCPTL  +~04A   W    A     Blitter ptr to source C (low 15 bits)',$0a
	dc.b	'BLTBPTH  +~04C   W    A     Blitter ptr to source B (high 3 bits)',$0a
	dc.b	'BLTBPTL  +~04E   W    A     Blitter ptr to source B (low 15 bits)',$0a
	dc.b	'BLTAPTH  +~050   W    A     Blitter ptr to source A (high 3 bits)',$0a
	dc.b	'BLTAPTL  +~052   W    A     Blitter ptr to source A (low 15 bits)',$0a
	dc.b	'BLTDPTH  +~054   W    A     Blitter ptr to destination D (high 3 bits)',$0a
	dc.b	'BLTDPTL  +~056   W    A     Blitter ptr to destination D (low 15 bits)',$0a
dma2end
dma3text
	dc.b	'BLTSIZE   ~058   W    A     Blitter start & size (window width, height)',$0a
	dc.b	'          ~05A',$0a   
	dc.b	'          ~05C',$0a
	dc.b	'          ~05E',$0a
	dc.b	'BLTCMOD   ~060   W    A     Blitter modulo for source C',$0a
	dc.b	'BLTBMOD   ~062   W    A     Blitter modulo for source B',$0a
	dc.b	'BLTAMOD   ~064   W    A     Blitter modulo for source A',$0a
	dc.b	'BLTDMOD   ~066   W    A     Blitter modulo for destination D',$0a
	dc.b	'          ~068',$0a
	dc.b	'          ~06A',$0a
	dc.b	'          ~06C',$0a
	dc.b	'          ~06E',$0a
	dc.b	'BLTCDAT  %~070   W    A     Blitter source C data register',$0a
	dc.b	'BLTDDAT  %~072   W    A     Blitter source B data register',$0a
	dc.b	'BLTADAT  %~074   W    A     Blitter source A data register',$0a
	dc.b	'          ~076',$0a
	dc.b	'          ~078',$0a
	dc.b	'          ~07A',$0a
	dc.b	'          ~07C',$0a
	dc.b	'DSKSYNC   ~07E   W     P    Disk sync pattern register for disk read',$0a
dma3end
dma4text
	dc.b	'COP1LCH   +080   W    A     Copper 1st location register (high 3 bits)',$0a
	dc.b	'COP1LCL   +082   W    A     Copper 1st location register (low 15 bits)',$0a
	dc.b	'COP2LCH   +084   W    A     Copper 2nd location register (high 3 bits)',$0a
	dc.b	'COP2LCL   +086   W    A     Copper 2nd location register (low 15 bits)',$0a
	dc.b	'COPJMP1    088   S    A     Copper restart at first location',$0a
	dc.b	'COPJMP2    08A   S    A     Copper restart at 2nd location',$0a
	dc.b	'COPINS     08C   W    A     Copper instruction identity',$0a
	dc.b	'DIWSTRT    08E   W    A     Display window start (upper left vert-horiz pos)',$0a
	dc.b	'DIWSTOP    090   W    A     Display window stop (lower right vert.-horiz. pos',$0a
	dc.b	'DDFSTRT    092   W    A     Display bitplane data fetch start (horiz. pos)',$0a
	dc.b	'DDFSTOP    094   W    A     Display bitplane data fetch stop (horiz. pos)',$0a
	dc.b	'DMACON     096   W   DAP    DMA control write (clear or set)',$0a
	dc.b	'CLXCON     098   W   D      Collision control',$0a
	dc.b	'INTENA     09A   W     P    Interupt enable bits (clear or set bits)',$0a
	dc.b	'INTREQ     09C   W     P    Interupt request bits (clear or set bits)',$0a
	dc.b	'ADKCON     09E   W     P    Audio, disk, UART control',$0a
	dc.b	'AUD0LCH   +0A0   W    A     Audio channel 0 location (high 3 bits)',$0a
	dc.b	'AUD0LCL   +0A2   W    A     Audio channel 0 location (low 15 bits)',$0a
dma4end
dma5text
	dc.b	'AUD0LEN    0A4   W     P    Audio channel 0 length',$0a
	dc.b	'AUD0PER    0A6   W     P    Audio channel 0 period',$0a
	dc.b	'AUD0VOL    0A8   W     P    Audio channel 0 volume',$0a
	dc.b	'AUD0DAT   &0AA   W     P    Audio channel 0 data',$0a
	dc.b	'           0AC',$0a
	dc.b	'           0AE',$0a
	dc.b	'AUD1LCH   +0B0   W    A     Audio channel 1 location (high 3 bits)',$0a
	dc.b	'AUD1LCL   +0B2   W    A       "      "    "     "    (low 15 bits)',$0a
	dc.b	'AUD1LEN    0B4   W     P      "      "    "  lenght',$0a
	dc.b	'AUD1PER    0B6   W     P      "      "    "  period',$0a
	dc.b	'AUD1VOL    0B8   W     P      "      "    "  volume',$0a
	dc.b	'AUD1DAT   &0BA   W     P      "      "    "  data',$0a
	dc.b	'           0BC',$0a
	dc.b	'           0BE',$0a
	dc.b	'AUD2LCH   +0C0   W    A     Audio channel 2 location (high 3 bits)',$0a
	dc.b	'AUD2LCL   +0C2   W    A       "      "    "     "    (low 15 bits)',$0a
	dc.b	'AUD2LEN    0C4   W     P      "      "    " length',$0a
	dc.b	'AUD2PER    0C6   W     P      "      "    " period',$0a
	dc.b	'AUD2VOL    0C8   W     P      "      "    " volume',$0a
	dc.b	'AUD2DAT   &0CA   W     P      "      "    " data',$0a
	dc.b	'           0CC',$0a
	dc.b	'           0CE',$0a

dma5end
dma6text
	dc.b	'AUD3LCH   +0D0   W    A     Audio channel 3 location (high 3 bits)',$0a
	dc.b	'AUD3LCL   +0D2   W    A       "      "    "      "   (low 15 bits)',$0a
	dc.b	'AUD3LEN    0D4   W     P      "      "    " length',$0a
	dc.b	'AUD3PER    0D6   W     P      "      "    " period',$0a
	dc.b	'AUD3VOL    0D8   W     P      "      "    " volume',$0a
	dc.b	'AUD3DAT   &0DA   W     P      "      "    " data',$0a
	dc.b	'           0DC',$0a
	dc.b	'           0DE',$0a
	dc.b	'BPL1PTH   +0E0   W    A     Bitplane 1 poniter (high 3 bits)',$0a
	dc.b	'BPL1PTL   +0E2   W    A       "      "    "    (low 15 bits)',$0a
	dc.b	'BPL2PTH   +0E4   W    A       "      2    "    (high 3 bits)',$0a
	dc.b	'BPL2PTL   +0E6   W    A       "      "    "    (low 15 bits)',$0a
	dc.b	'BPL3PTH   +0E8   W    A       "      3    "    (high 3 bits)',$0a
	dc.b	'BPL3PTL   +0EA   W    A       "      "    "    (low 15 bits)',$0a
	dc.b	'BPL4PTH   +0EC   W    A       "      4    "    (high 3 bits)',$0a
	dc.b	'BPL4PTL   +0EE   W    A       "      "    "    (low 15 bits)',$0a
	dc.b	'BPL5PTH   +0F0   W    A       "      5    "    (high 3 bits)',$0a
	dc.b	'BPL5PTL   +0F2   W    A       "      "    "    (low 15 bits)',$0a
	dc.b	'BPL6PTH   +0F4   W    A       "      6    "    (high 3 bits)',$0a
	dc.b	'BPL6PTL   +0F6   W    A       "      "    "    (low 15 bits)',$0a
	dc.b	'           0F8',$0a
	dc.b	'           0FA',$0a
	dc.b	'           0FC',$0a
	dc.b	'           0FE',$0a
dma6end
dma7text
	dc.b	'BPLCON0    100   W   DA      Bitplane control register (misc. control bits)',$0a
	dc.b	'BPLCON1    102   W   D          "         "      "     (scroll value PF1,PF2)',$0a
	dc.b	'BPLCON2    104   W   D          "         "      "     (priority control)',$0a
	dc.b	'           106',$0a
	dc.b	'BPL1MOD    108   W    A         "     modulo (odd planes)',$0a
	dc.b	'BPL2MOD    10A   W    A         "     modulo (even planes)',$0a
	dc.b	'           10C',$0a
	dc.b	'           10E',$0a
	dc.b	'BPL1DAT   &110   W   D       Bitplane 1 data (parallel-to-serial convert)',$0a
	dc.b	'BPL2DAT   &112   W   D          "     2   "  (    "      "    "     "   )',$0a
	dc.b	'BPL3DAT   &114   W   D          "     3   "  (    "      "    "     "   )',$0a
	dc.b	'BPL4DAT   &116   W   D          "     4   "  (    "      "    "     "   )',$0a
	dc.b	'BPL5DAT   &118   W   D          "     5   "  (    "      "    "     "   )',$0a
	dc.b	'BPL6DAT   &11A   W   D          "     6   "  (    "      "    "     "   )',$0a
	dc.b	'           11C',$0a
	dc.b	'           11E',$0a
	dc.b	'SPR0PTH   +120   W    A      Sprite 0 pointer (high 3 bits)',$0a
	dc.b	'SPR0PTL   +122   W    A         "   "     "   (low 15 bits)',$0a
	dc.b	'SPR1PTH   +124   W    A         "   1     "   (high 3 bits)',$0a
	dc.b	'SPR1PTL   +126   W    A         "   "     "   (low 15 bits)',$0a
	dc.b	'SPR2PTH   +128   W    A         "   2     "   (high 3 bits)',$0a
	dc.b	'SPR2PTL   +12A   W    A         "   "     "   (low 15 bits)',$0a
dma7end
dma8text
	dc.b	'SPR3PTH   +12C   W    A      Sprite 3 pointer (high 3 bits)',$0a
	dc.b	'SPR3PTL   +12E   W    A         "   "     "   (low 15 bits)',$0a
	dc.b	'SPR4PTH   +130   W    A         "   4     "   (high 3 bits)',$0a
	dc.b	'SPR4PTL   +132   W    A         "   "     "   (low 15 bits)',$0a
	dc.b	'SPR5PTH   +134   W    A         "   5     "   (high 3 bits)',$0a
	dc.b	'SPR5PTL   +136   W    A         "   "     "   (low 15 bits)',$0a
	dc.b	'SPR6PTH   +138   W    A         "   6     "   (high 3 bits)',$0a
	dc.b	'SPR6PTL   +13A   W    A         "   "     "   (low 15 bits)',$0a
	dc.b	'SPR7PTH   +13C   W    A         "   7     "   (high 3 bits)',$0a
	dc.b	'SPR7PTL   +13E   W    A         "   "     "   (low 15 bits)',$0a
	dc.b	'SPR0POS   %140   W   DA      Sprite 0 vert-horiz start pos. data',$0a
	dc.b	'SPR0CTL   %142   W   DA         "   " vert-stop pos. & control data',$0a
	dc.b	'SPR0DATA  %144   W   D          "   " image data register A',$0a
	dc.b	'SPR0DATB  %146   W   D          "   0   "     "     "     B',$0a
	dc.b	'SPR1POS   %148   W   DA         "   1 vert-horiz start pos.data',$0a
	dc.b	'SPR1CTL   %14A   W   DA         "   " vert-stop pos. & control data',$0a
	dc.b	'SPR1DATA  %14C   W   D          "   " image data register A',$0a
	dc.b	'SPR1DATB  %14E   W   D          "   "   "     "     "     B',$0a
	dc.b	'SPR2POS   %150   W   DA         "   2 vert-horiz start pos. data',$0a
	dc.b	'SPR2CTL   %152   W   DA         "   " vert-stop pos. & control data',$0a
	dc.b	'SPR2DATA  %154   W   D          "   " image data register A',$0a
	dc.b	'SPR2DATB  %156   W   D          "   "   "     "     "     B',$0a   
dma8end
dma9text
	dc.b	'SPR3POS   %158   W   DA      Sprite 3 vert-horiz start pos. data',$0a
	dc.b	'SPR3CTL   %15A   W   DA         "   " vert-stop pos. & control data',$0a
	dc.b	'SPR3DATA  %15C   W   D          "   " image data register A',$0a
	dc.b	'SPR3DATB  %15E   W   D          "   "   "     "     "     B',$0a
	dc.b	'SPR4POS   %160   W   DA         "   4 vert-horiz start pos. data',$0a
	dc.b	'SPR4CTL   %162   W   DA         "   " vert-stop pos. & control data',$0a
	dc.b	'SPR4DATA  %164   W   D          "   " image data register A',$0a
	dc.b	'SPR4DATB  %166   W   D          "   "   "     "     "     B',$0a
	dc.b	'SPR5POS   %168   W   DA         "   5 vert-horiz start pos. data',$0a
	dc.b	'SPR5CTL   %16A   W   DA         "   " vert-stop pos. & control data',$0a
	dc.b	'SPR5DATA  %16C   W   D          "   " image data register A',$0a
	dc.b	'SPR5DATB  %16E   W   D          "   "   "     "     "     B',$0a
	dc.b	'SPR6POS   %170   W   DA         "   6 vert-horiz start pos. data',$0a
	dc.b	'SPR6CTL   %172   W   DA         "   " vert-stop pos. & control data',$0a
	dc.b	'SPR6DATA  %174   W   D          "   " image data register A',$0a
	dc.b	'SPR6DATB  %176   W   D          "   "   "     "     "     B',$0a
	dc.b	'SPR7POS   %178   W   DA         "   7 vert-horiz start pos. data',$0a
	dc.b	'SPR7CTL   %17A   W   DA         "   " vert-stop pos. & control data',$0a
	dc.b	'SPR7DATA  %17C   W   D          "   " image data register A',$0a
	dc.b	'SPR7DATB  %17E   W   D          "   "   "     "     "     B',$0a 
dma9end
dmaatext
	dc.b	'COLOR00    180   W   D       Colour register 00',$0a
	dc.b	'COLOR01    182   W   D       Colour register 01',$0a
	dc.b	'.......    ...   .   .       ............... ..',$0a
	dc.b	'<add 1>  <add 2><W>  <D>           <add 1>',$0a
	dc.b	'.......    ...   .   .       ............... ..',$0a
	dc.b	'COLOR31    1BE   W   D       Colour register 31',$0a
	dc.b	'RESERVED  1110X',$0a
	dc.b	'RESERVED  1111X',$0a
	dc.b	'NO-OP(NULL) 1FE',$0a
	dc.b	$9b,"0;34;42m"
	dc.b	'Table taken from AMIGA HARDWARE REFERENCE MANUAL',$9b,"0;32;40m",$0a
	dc.b	'Brought to you by Raistlin & Caramon   22.2.91'
dmaaend
byetext
	dc.b	$9b,"3;32;40m",'Thanks for using Raistlin`s helper! ',$9b,"0;33;40m",$0a,'Thanks to Hearwig for his help',$0a,$9b,"0;31;40m"
byeend
