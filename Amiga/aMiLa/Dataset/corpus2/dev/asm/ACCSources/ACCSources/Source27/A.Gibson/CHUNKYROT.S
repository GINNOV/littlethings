**********COPPER ROTATE********************
** this is the basic version without any **
** effects on......			 **
******************************************* 

execbase=4
alocmem=-$c6
openlib=-408
permit=-138
forbid=-132
custom=$dff000
dmacon=$96
cop1lc=$80
freemem=-$d2
closelib=-414
copjmp1=$88

******************************************************************

allocate_mem

	move.l execbase,a6	;
	move.l clistsz,d0	;GET COPPER LIST SIZE
	move.l #65539,d1	;CHIP MEMORY
	jsr alocmem(a6)		;ALLOCATE MEMORY
	move.l d0,clistadd1	;SAVE COPPERLIST MEMORY ADDRESS
	beq exit		;QUIT IF NO-GO
	move.l execbase,a6	;
	move.l clistsz,d0	;SAME AS ABOVE BUT
	move.l #65539,d1	;FOR THE SECOND LOCATION
	jsr alocmem(a6)		;OF THE COPPER LIST
	move.l d0,clistadd2	;
	beq exit		;

	
copylist
	lea clistst,a0		;START OF COPPER DATA IN A0
	move.l clistadd1,a1	;FIRST COPPER ADDRESS IN A1
	move.l clistadd2,a2	;SECOND COPPER ADDRESS IN A2
	move.l clistsz,d0	;SIZE OF LIST IN D0
	subi.l #1,d0		;TAKE ONE OFF IT (USING DBRA)
clistcopy

	move.b (a0),(a1)+	;MOVE DATA INTO FIRST PART OF CHIPMEM
	move.b (a0)+,(a2)+	;MOVE DATA INTO SECOND PART OF CHIPMEM
	dbra d0,clistcopy	;LOOP UNTIL D0=0

******************************************
setup_copy_size
				;FIND NUMBER OF 4 WORD SECTIONS
	
	move.l clistsz,d0	;GET COPPER SIZE
	lsr #3,d0		;SHIFT RIGHT X 3 (DIVIDE BY 8)
	move.w d0,loopval	;STORE VALUE
	
******************************************************
openlibraries
	move.l execbase,a6	
	move.l #grapname,a1	;PUT LIB NAME POINTER IN A1
	jsr openlib(a6)		;OPEN LIBRARY
	move.l d0,grapbase	;STORE LIB BASE
******************************************************


main
	

	move.l execbase,a6		;
	jsr forbid(a6)			;STOP TASK SWITCHING
	lea custom,a5			;PUT CUSTOM STRT ($DFF000) IN A5
	move.w #$03a0,dmacon(a5)      	;
	move.l clistadd1,cop1lc(a5)   	;PUT COP ADDRS1 INTO COPPER PNTR	
	clr.w copjmp1(a5)		;START COPPER ACTIVITY
	move.w #$8280,dmacon(a5)	;

	move.l clistadd1,a3	;PUT FIRST COPPER LIST ADDRESS
	move.l a3,curradd	;INTO CURRADD

	move.l #table,a0	;INITIALIZE TABLE POINTER

bigloop
	move.l #0,d3		;SET COLOUR TABLE OFFSET TO 0
loop

	move.l curradd,d4	;GET ADDRESS OF COPPERLIST IN USE
	cmp.l clistadd1,d4	;IS IT FIRST LIST ?
	beq second		;IF SO PUT SECOND LIST ADDRESS IN A2
	move.l clistadd1,a2	;ELSE PUT FIRST LIST ADDRESS IN A2
	bra skip		;AND BRANCH TO AVOID PUTTING 2nd LIST
				;ADDRESS INTO USE

second
	move.l clistadd2,a2	;PUT SECOND LIST ADDRESS IN A2
skip

	move.l a2,curradd	;STORE A2 AS CURRENT ADDRESS IN USE

***********************************************************************
SETUP_COLOUR_COPY

	add.w #2,a2 		;OFFSET COPPER POINTER BY 2
	move.w loopval,d0	;PUT COPY LOOP VALUE INTO D0
	move.l a0,a1		;COPY TABLE ADDRESS
	sub.w #4,d0		;TAKE 4 OFF LOOP VALUE
	add d3,a1		;PUT CURRENT COLOUR TABLE POSITION IN A1
	add #2,d3		;MOVE COLOUR TABLE POINTER ON TO NEXT WORD (2BYTES)
copy				
	move.w (a1)+,(a2)+	;COPY COLOUR DATA INTO CLIST DATA
	add.l #6,a2		;MOVE COPPER POINTER TO NEXT COLOUR DATA
	dbra d0,copy		;REPEAT UNTIL COPY IS COMPLETE (D0=0)

************************************************************************
****PUT UPDATED COPPER LIST INTO USE****
		
	lea custom,a5		;PUT CUSTOM REG ADDRESS INTO A5
	move.l curradd,a2	;PUT UPDATED COLOUR LIST ADDRESS IN A4
	move.l a2,cop1lc(a5)	;USE NEW UPDATED COPPERLIST

*************************************************************************
**** HANG AROUND FOR A WHILE ****

	move.l #$fff,d0		;PAUSE ROUTINE	
pause				;TO SLOW DOWN THE ACTION
	sub.l #1,d0		;NOT NECESSARY IF USING
	cmp #0,d0		;INTERRUPTS.
	bne pause		;PUT A BIGGER NUMBER IF D0 FOR A LONGER
				;DELAY AND VICE-VERSA

*************************************************************************
				
	btst #6,$bfe001		;TEST FOR LEFT MOUSE BUTTON
	beq.s endloop		;BRANCH IF PRESSED TO ENDLOOP


	cmp tablesz,d3		;SHOULD TABLE POINTER BE RESET?
	beq bigloop		;IF SO BRANCH TO BIGLOOP (RESETS COL PTR)
	bne loop		;OTHERWISE BRANCH TO NESTED LOOP

endloop

	move.l grapbase,a4		;GET GRAPHICS BASE
	move.l 38(a4),cop1lc(a5);RESTORE OLD COPPER LIST
	clr.w copjmp1(a5)		;START COPPER ACTIVITY
	move.w #$83e0,dmacon(a5)	;ENABLE ALL DMA
	move.l execbase,a6		;
	jsr permit(a6)			;ALLOW TASK SWITCHING

cleaner
	move.l clistadd1,a1	;
	move.l clistsz,d0	;FREE FIRST COPPER LIST MEMORY
	jsr freemem(a6)		;

	move.l clistsz,d0	;
	move.l clistadd2,a1	;FREE SECOND COPPER LIST MEMORY
	jsr freemem(a6)		;
	
	move.l execbase,a6	;
	move.l grapbase,a1	;CLOSE GRAPHICS LIBRARY
	jsr closelib(a6)	;

exit
	rts

******************************************************************************	
	even
grapname
	dc.b "graphics.library",0,0
	even
grapbase
	dc.l 0
****************************************************************************
**** HERE COMES THE COPPER LIST!! ****
*** NEEDS TO BE COPIED TO CHIP RAM ***

clistst
	
	dc.w $180,$0000
	dc.w $000f,$fffe
	dc.w $180,$0000
	dc.w $080f,$fffe
	dc.w $180,$0000
	dc.w $100f,$fffe
	dc.w $180,$0000
	dc.w $180f,$fffe
	dc.w $180,$0000
	dc.w $200f,$fffe
	dc.w $180,$0000
	dc.w $280f,$fffe
	dc.w $180,$0000
	dc.w $300f,$fffe
	dc.w $180,$0000
	dc.w $380f,$fffe
	dc.w $180,$0000
	dc.w $400f,$fffe
	dc.w $180,$0000
	dc.w $480f,$fffe
	dc.w $180,$0000
	dc.w $500f,$fffe
	dc.w $180,$0000
	dc.w $580f,$fffe
	dc.w $180,$0000
	dc.w $600f,$fffe
	dc.w $180,$0000
	dc.w $680f,$fffe
	dc.w $180,$0000
	dc.w $700f,$fffe
	dc.w $180,$0000
	dc.w $780f,$fffe
	dc.w $180,$0000
	dc.w $800f,$fffe
	dc.w $180,$0000
	dc.w $880f,$fffe
	dc.w $180,$0000
	dc.w $900f,$fffe
	dc.w $180,$0000
	dc.w $980f,$fffe
	dc.w $180,$0000
	dc.w $a00f,$fffe
	dc.w $180,$0000
	dc.w $a80f,$fffe
	dc.w $180,$0000
	dc.w $b00f,$fffe
	dc.w $180,$0000
	dc.w $b80f,$fffe
	dc.w $180,$0000
	dc.w $c00f,$fffe
	dc.w $180,$0000
	dc.w $c80f,$fffe
	dc.w $180,$0000
	dc.w $d00f,$fffe
	dc.w $180,$0000
	dc.w $d80f,$fffe
	dc.w $180,$0000
	dc.w $e00f,$fffe
	dc.w $180,$0000
	dc.w $e80f,$fffe
	dc.w $180,$0000
	dc.w $f000,$fffe
	dc.w $180,$0000
	dc.w $f800,$fffe
	dc.w $180,$0000
	dc.w $ffff,$fffe
***********************
*********************************	
clistsz
	dc.l clistsz-clistst

clistadd1
	dc.l 0
clistadd2
	dc.l 0
curradd
	dc.l 0
************************************************************
**** TABLE FOR THE COLOUR CHANGES ,STORED AS RGB VALUES ****
**** TO MAKE YOUR OWN,MAKE SURE THAT THE DATA FOLLOWING ****
**** TABLE LOOP IS THE SAME AS THE DATA AT THE START OF ****
**** THE TABLE OF DATA.  				****
************************************************************

table
	dc.w 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,$1f,$2f,$3f,$4f
	dc.w $5f,$6f,$7f,$8f,$9f,$af,$bf,$cf,$df,$ef,$ff,$fe,$fd
	dc.w $fc,$fb,$fa,$f9,$f8,$f7,$f6,$f5,$f4,$f3,$f2,$f1,$f0
	dc.w $1f0,$2f0,$3f0,$4f0,$5f0,$6f0,$7f0,$8f0,$9f0,$af0,$bf0
	dc.w $cf0,$df0,$ef0,$ff0,$fe0,$fd0,$fc0,$fb0,$fa0,$f90,$f80
	dc.w $f70,$f60,$f50,$f40,$f30,$f20,$f10,$f00,$e00,$d00,$c00
	dc.w $b00,$a00,$900,$800,$700,$600,$500,$400,$300,$200,$100
	dc.w 0,0,0,0		

*NOTE: DOES NOT NEED TO BE ENDED WITH A NULL DATA ITEM!!!!
***********************************************************************

tableloop
	dc.w 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,$1f,$2f,$3f,$4f
	dc.w $5f,$6f,$7f,$8f,$9f,$af,$bf,$cf,$df,$ef,$ff,$fe,$fd

tablesz
	dc.w tableloop-table
loopval
	dc.l 0

		************************************
		******* ENJOY THE CODE !!!!! *******
		************************************		
