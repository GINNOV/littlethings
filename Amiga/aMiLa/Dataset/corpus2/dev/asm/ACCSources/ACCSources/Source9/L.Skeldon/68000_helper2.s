** CODE:    HELPER
** AUTHERS: Raistlin (Leon Skeldon)  &  Hearwig (Rick Sandiford)
** DATE:    Febuary 1st  1991
** SIZE:

** PARTS WRITTEN BY RAISTLIN:

; MAIN PROGRAM, ASCII TABLE, COPPER, DOS.LIB, QUIT, MEMORY MAP, ALERT HELP
; VARIOUS SMALL PARTS OF PROGRAM.

** PARTS WRITTEN BY HEARWIG:

; 68000 HELPER & INSTRUCTION SET. 


*Note I've sent you two versions of this prog. This is the more complete
*However cos Rick fucked the fisrst copy up (one with comms) this copy
*has no comments. see other version for comments
*Sending the disk off in 30mins so I'm pushed for time. I'm about to add
*push both mouse buttons. If the source has any bugs when it gets to you
*its because of a feature I'm about to add. I'll label new features (n).

*The program is not quite finished. If you want I'll send you the finished
*version as soon as its ready. Sorry the source is such a mess!

*Ive avoided using includes as it makes it easyer to learn!


	opt	c-		;I'm not a fussy man

	
	move.l	4,a6		;Load dos.lib
	lea	dosname(pc),a1
	moveq.l	#0,d0
	jsr	-408(a6)
	move.l	d0,dosbase	;store dos.base
	
	
**This section opens the window
	lea	consolname(pc),a1	;Name of window	
	move.l	#1005,d2		;mode
	move.l	a1,d1		;name of window in d1
	move.l	dosbase,a6	;dos base in a6
	jsr	-30(a6)		;open the CONSOLE
	move.l	d0,conhandle	;save the conahdle

**This section writes to the output window
	move.l	dosbase,a6
	move.l	conhandle,d1	;get conhandle
	move.l	#title,d2		;get address of text
	move.l	#titleend-title,d3	;get length of text
	jsr	-48(a6)		;write function

**This section checks for input	
START	move.l	#inbuff,d2	;simple routine to get text
	move.l	dosbase,a6
	move.l	conhandle,d1
	move.l	#4,d3
	jsr	-42(a6)
	andi.b	#$df,inbuff	;converts lowercase input to uppercase
	cmpi.b	#65,inbuff
	beq	ASCII
	cmpi.b	#66,inbuff
	beq	ALERT		;This whole section checks the input 
	cmpi.b	#67,inbuff	;for a required ascii character
	beq	COPPER
	cmpi.b	#68,inbuff	;ie 68 is A
	beq	DOS.LIB
	cmpi.b	#72,inbuff
	beq	HELPER		;I intend to repalce this routine
	cmpi.b	#73,inbuff	;with a check for F1-F10
	beq	ISET
	cmpi.b	#77,inbuff
	beq	MMAP
	cmpi.b	#79,inbuff
	beq	EXEChelp
	cmpi.b	#81,inbuff
	beq	QUIT
	cmpi.b	#84,inbuff
	beq	TROUBLE
	cmpi.b	#85,inbuff
	beq	CHARS
	cmpi.b	#86,inbuff
	beq	GLOSSARY
	cmpi.b	#87,inbuff
	beq	WINDOW
	cmpi.b	#88,inbuff
	beq	COLORS
	

NOKEY
	bra	rit		;if no key is entered	
				;go to rit
ASCII
	bsr	open			;open window
	move.l	#asciitext,d2		;address of text in d2
	move.l	#asciiend-asciitext,d3	;lebght of text
	jsr	-48(a6)			;write text
	bsr	wait			;wait for L&B mouse buttons
	bsr	close			;close window
	bra	rit			;go back to main menu
	
COPPER
	jsr	open
	move.l	#coppertext,d2
	move.l	#copperend-coppertext,d3	;SEE ASCII
	jsr	-48(a6)
	bsr	wait
	bsr	close
	bra	rit
ALERT
	jsr	open1			;SEE ASCII
	move.l	#gurutext,d2
	move.l	#guruend-gurutext,d3
	jsr	-48(a6)
	bsr	wait
	move.l	conhandle1,d1		;after waiting shows
	move.l	#gurutext1,d2		;next sheet
	move.l	#guruend1-gurutext1,d3
	jsr	-48(a6)

	bsr	wait
	
	move.l	conhandle1,d1
	move.l	#gurutext2,d2
	move.l	#guruend2-gurutext2,d3
	jsr	-48(a6) 
	bsr	wait
	move.l	conhandle1,d1
	move.l	#gurutext3,d2
	move.l	#guruend3-gurutext3,d3
	jsr	-48(a6)
	jsr	wait
	move.l	conhandle1,d1
	move.l	#gurutext4,d2
	move.l	#guruend4-gurutext4,d3
	jsr	-48(a6)
	jsr	wait
	move.l	conhandle1,d1
	move.l	#gurutext5,d2
	move.l	#guruend5-gurutext5,d3
	jsr	-48(a6)
	jsr	wait
	move.l	conhandle1,d1
	move.l	#gurutext6,d2
	move.l	#guruend6-gurutext6,d3
	jsr	-48(a6)
	jsr	wait
	bsr	close
	bra	rit
EXECHELP
TROUBLE
CHARS
GLOSSARY
WINDOW
	
COLORS
DOS.LIB
	jsr	open1			;SEE ABOVE
	move.l	conhandle1,d1
	move.l	#dostext1,d2
	move.l	#dosend1-dostext1,d3
	jsr	-48(a6)
	bsr	wait
	move.l	conhandle1,d1
	move.l	#dostext2,d2
	move.l	#dosend2-dostext2,d3
	jsr	-48(a6)
	jsr	wait
	bsr	close
	bra	rit
HELPER
	bsr	ricopen			;SEE EXTERNAL NOTES
	move.l	conhandle1,d1
	move.l	#helphi,d2
	move.l	#helphie-helphi,d3
	jsr	-48(a6)
commin	move.l	conhandle1,d1
	move.l	#commreq,d2
	move.l	#commend-commreq,d3
	jsr	-48(a6)
	move.l	conhandle1,d1
	move.l	#commbuff,d2
	move.l	#10,d3
	jsr	-42(a6)
	cmp.b	#10,commbuff
	beq	endcomm
	lea	commands,a2
check	
	lea	commbuff,a3
compare
	cmp.b	(a2)+,(a3)+
	bne	nextc
	tst.b	(a2)
	bne	compare
	tst.b	(a2)+
	move.l	a3,d4
	sub.l	#commbuff,d4
	move.l	a2,d2
nextz	cmp.b	#255,(a2)+
	bne	nextz
	move.l	a2,d3
	subq.b	#1,d3
	sub.l	d2,d3
	move.l	conhandle1,d1
	jsr	-48(a6)
	move.l	#cmodei,d2
	move.l	#cmodeie-cmodei,d3
	move.l	conhandle1,d1
	jsr	-48(a6)
modepr	cmp.b	#254,(a2)
	beq	commin
	move.l	d4,d3
	move.l	#commbuff,d2
	move.l	conhandle1,d1
	jsr	-48(a6)
	move.b	(a2)+,type
	move.l	a2,d2
	moveq.l	#1,d3
	move.l	conhandle1,d1
	jsr	-48(a6)
	tst.b	(a2)+
	cmp.b	#1,type
	beq	retc
	bsr	spaces
	clr.l	d7
	move.b	(a2),d5
	bsr	abitpr
	cmp.b	#2,type
	beq	sendspa
	move.l	#comma,d2
	move.l	#1,d3
	move.l	conhandle1,d1
	jsr	-48(a6)
	move.b	(a2),d5
	lsr.l	#4,d5
	bsr	abitpr
	addq.l	#1,d7
sendspa	tst.b	(a2)+
	move.l	#13,d6
	sub.l	d7,d6
sendsp	bsr	spaces
	dbra	d6,sendsp
	move.b	(a2)+,d5
	moveq.l	#4,d6
	moveq.l	#1,d3
	move.l	#lengths,d2
sizespr	lsr.b	#1,d5
	bcc	sizesc
retc	move.l	conhandle1,d1
	jsr	-48(a6)
sizesc	addq.l	#1,d2
	dbra	d6,sizespr
	move.l	#cmodei,d2
	move.l	#1,d3
	move.l	conhandle1,d1
	jsr	-48(a6)
	bra	modepr
spaces	move.l	#space,d2
	move.l	#1,d3
	move.l	conhandle1,d1
	jmp	-48(a6)
abitpr	and.l	#$f,d5
	asl.l	#2,d5
	add.l	#modes,d5
	move.l	d5,a1
	move.l	(a1),a3
	move.b	(a3),d3
	tst.b	(a3)+
	move.l	a3,d2
	add.l	d3,d7
	move.l	conhandle1,d1
	jmp	-48(a6)
nextc	cmp.b	#254,(a2)+
	bne	nextc
	cmp.b	#255,(a2)
	bne	check
	move.l	conhandle1,d1
	move.l	#rubbish,d2
	move.l	#rubend-rubbish,d3
	jsr	-48(a6)
	jmp	commin
endcomm	bsr	close
	bra	rit
commbuff
	ds.b	10
ISET
	bsr	ricopen
	move.l	conhandle1,d1
	move.l	#insset,d2
	move.l	#insend-insset,d3
	jsr	-48(a6)
	bsr	wait
nohelp	bsr	close
	bra	rit
MMAP
	jsr	open
	move.l	#memtext,d2
	move.l	#memend-memtext,d3
	jsr	-48(a6)
	bsr	wait
	bsr	close
	bra	rit

		
**This section closes the window	
QUIT
end	move.l	conhandle,d1
	move.l	dosbase,a6
	jsr	-36(a6)
	rts

*This section works cos programs are fast!
wait	
	btst	#6,$bfe001	;check for L. button
	bne	wait
	btst	#$a,$dff016	;check for R.button
	bne	wait
	rts

rit
	move.l	dosbase,a6
	move.l	conhandle,d1
	move.l	#t,d2
	move.l	#e-t,d3
	jsr	-48(a6)
	jmp	start
	
open
	move.l	dosbase,a6
	lea	asciiname(pc),a1
	move.l	#1005,d2
	move.l	a1,d1
	jsr	-30(a6)
	move.l	d0,conhandle1
	move.l	conhandle1,d1
	rts

open1	move.l	dosbase,a6
	lea	BIG(pc),a1
dowind	move.l	#1005,d2
	move.l	a1,d1
	jsr	-30(a6)
	move.l	d0,conhandle1
	move.l	conhandle1,d1
	rts

ricopen	move.l	dosbase,a6
	lea	consl1(pc),a1
	bra	dowind

close	move.l	conhandle1,d1
	move.l	dosbase,a6
	jsr	-36(a6)
	rts
t	dc.b	$8,$8,$8,$8,$8,$8,$8,$8,$8,$8,$8,$8,$8,$8,$8
	dc.b	$8,$8,$8,$8,$8,$8,$8,$8,$8,$8,$8,$8,$8,$8,$8
	dc.b	$8,$8,$8,$8,$8,$8,$8,$8,$8,$8
e
inbuff	ds.b	4
dosname	dc.b	'dos.library',0
	even
dosbase	dc.l	0
consolname	dc.b	'CON:90/30/400/213/HELPER',0
	even
conhandle	dc.l	0	
title	dc.b	$9b,"1;37;40m"
	dc.b	"            Select an option!",$0a,$0a
	dc.b	$9b,"0;32;40m"
	dc.b	'  A...ASCII table       ',$0a,$0a
	dc.b	'  B...Alert.help        Q...Quit',$0a,$0a
	dc.b	'  C...Copper            T...Trouble Shooting',$0a,$0a
	dc.b	'  D...Dos.lib           U...Controll characters',$0a,$0a
	dc.b	'  H...68000-Helper      V...Common words',$0a,$0a
	dc.b	'  I...Instruction set   ',$0a,$0a
	dc.b	'  M...Memory map        ',$0a,$0a
	dc.b	$9b,"0;31;40m"
	dc.b	"OPTION:"
	dc.b	$0a,$0a,"  ",$9b,"3;31;42m"
	dc.b	"Helper coded by Raistlin of BANANA BEASTS",$0a
	dc.b	$9b,"1;33;40m"
	dc.b	'GREETS TO:',$0a
	dc.b	'          Mark Meany & all that supply to ACC'
	dc.b	$0a,'Rick Sandiford for help, all members of Banana'
	dc.b	$0a,'Beasts, NBS for being the best PD library',$0a,'All my friends!!',$0a
	dc.b	$9b,"0;31;40m","       ",$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0
titleend
	even
asciiname	dc.b	'CON:100/20/406/230/RAISTLIN',0
	even
big	dc.b	'CON:0/0/640/250/RAISTLIN',0
	even
conhandle1	dc.l	0
asciitext	dc.b	"            ",$9b,"4;33;40m","ASCII TABLE",0
	dc.b	$0a,$9b,"0;31;40m",$0a
	dc.b	'20  21  22  23  24  25  26  27  28  29  2A  2B'
	dc.b	$0a,$9b,"0;32;40m"
	dc.b	'SP  !   ',34,'   #   $   %   &   ',39,'   (   )   *   + '   
	dc.b	$0a,$0a,$9b,"0;31;40m"
	dc.b	'2C  2D  2E  2F  30  31  32  33  34  35  36  37',$0A
	dc.b	$9b,"0;32;40m"
	dc.b	',   -   .   /   0   1   2   3   4   5   6   7',$0A
	DC.B	$0A,$9B,"0;31;40m"
	DC.B	'38  39  3A  3B  3C  3D  3E  3F  40  41  42  43',$0A
	DC.B	$9B,"0;32;40m"
	DC.B	'8   9   :   ;   <   =   >   ?   @   A   B   C',$0A,$0A
	dc.b	$9b,"0;31;40m"
	dc.b	'44  45  46  47  48  49  4A  4B  4C  4D  4E  4F',$0A
	dc.b	$9b,"0;32;40m"
	dc.b	'D   E   F   G   H   I   J   K   L   M   N   O',$0A,$0A
	DC.B	$9b,"0;31;40m"
	dc.b	'50  51  52  53  54  55  56  57  58  59  5A  5B',$0A
	DC.B	$9b,"0;32;40m"
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
	even
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
	even
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
	even
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
	dc.b	'			Press Left Mouse Button',$0
guruend
gurutext1
	dc.b	$0a,'GENERAL ERROR CODES',$0a
	dc.b	'CODE   MEANING			CODE   MEANING',$0a
	dc.b	' 01    Not enough memory	 02    Makelibrary',$0a
	dc.b	' 03    Openlibrary		 04    OpenDevice',$0a
	dc.b	' 05    OpenResource		 06    I/O Error',$0a
	dc.b	' 07    Signal Absent',$0a,$0a
	dc.b	'SPECIFIC ERROR CODE',$0a
	dc.b	'EXEC',$0a
	dc.b	'CODE    MEANING			       CODE   MEANING',$0a
	dc.b	'0001    Checksum: exception vector     0002   Checksum: Execbase',$0a
	dc.b	'0003    Checksum: Library	       0004   No memory for library',$0a
	dc.b	'0005    Memory list damaged	       0006   No memory for interrupt server',$0a
	dc.b	'0007    InitAPtr		       0008   Damaged Semaphore',$0a
	dc.b	'0009    Cant free already free memor   000A   Bogus Exception',$0a
guruend1
gurutext2	dc.b	$0a,'GRAPHICS',$0a
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
	dc.b	'Intuition',$0a
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
	dc.b	'Dos',$0a
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
	dc.b	'Expansion',$0a
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
	dc.b	' CPU Traps are internal microprocessor error:',$0a
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
consl1	dc.b	"CON:80/20/480/210/Raistlin",0
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
