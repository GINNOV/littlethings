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
	sub.w #3,d0		;TAKE 4 OFF LOOP VALUE
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

	move.l #$1B00,d0		;PAUSE ROUTINE	
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
	move.l 38(a4),cop1lc(a5)	;RESTORE OLD COPPER LIST
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
	dc.w $180,$0001
	dc.w $020f,$fffe
	dc.w $180,$0002
	dc.w $040f,$fffe
	dc.w $180,$0003
	dc.w $060f,$fffe
	dc.w $180,$0004
	dc.w $080f,$fffe
	dc.w $180,$0005
	dc.w $0a0f,$fffe
	dc.w $180,$0006
	dc.w $0c0f,$fffe
	dc.w $180,$0007
	dc.w $0e0f,$fffe


	dc.w $180,$0008
	dc.w $100f,$fffe
	dc.w $180,$0009
	dc.w $100f,$fffe
	dc.w $180,$000a
	dc.w $120f,$fffe
	dc.w $180,$000b
	dc.w $140f,$fffe
	dc.w $180,$000c
	dc.w $160f,$fffe
	dc.w $180,$000d
	dc.w $180f,$fffe
	dc.w $180,$000e
	dc.w $1a0f,$fffe
	dc.w $180,$000f
	dc.w $1c0f,$fffe
	dc.w $180,$001f
	dc.w $1e0f,$fffe


	dc.w $180,$002f
	dc.w $200f,$fffe
	dc.w $180,$003f
	dc.w $220f,$fffe
	dc.w $180,$004f
	dc.w $240f,$fffe
	dc.w $180,$005f
	dc.w $260f,$fffe
	dc.w $180,$006f
	dc.w $280f,$fffe
	dc.w $180,$007f
	dc.w $2a0f,$fffe
	dc.w $180,$008f
	dc.w $2c0f,$fffe
	dc.w $180,$009f
	dc.w $2e0f,$fffe


	dc.w $180,$00af
	dc.w $300f,$fffe
	dc.w $180,$00bf
	dc.w $320f,$fffe
	dc.w $180,$00cf
	dc.w $340f,$fffe
	dc.w $180,$00df
	dc.w $360f,$fffe
	dc.w $180,$00ef
	dc.w $380f,$fffe
	dc.w $180,$00ff
	dc.w $3a0f,$fffe
	dc.w $180,$00fe
	dc.w $3c0f,$fffe
	dc.w $180,$00fd
	dc.w $3e0f,$fffe


	dc.w $180,$00fc
	dc.w $400f,$fffe
	dc.w $180,$00fb
	dc.w $420f,$fffe
	dc.w $180,$00fa
	dc.w $440f,$fffe
	dc.w $180,$00f9
	dc.w $460f,$fffe
	dc.w $180,$00f8
	dc.w $480f,$fffe
	dc.w $180,$00f7
	dc.w $4a0f,$fffe
	dc.w $180,$00f6
	dc.w $4c0f,$fffe
	dc.w $180,$00f5
	dc.w $4e0f,$fffe
	dc.w $180,$00f4


	dc.w $500f,$fffe
	dc.w $180,$00f3
	dc.w $520f,$fffe
	dc.w $180,$00f2
	dc.w $540f,$fffe
	dc.w $180,$00f1
	dc.w $560f,$fffe
	dc.w $180,$00f0
	dc.w $580f,$fffe
	dc.w $180,$01f0
	dc.w $5a0f,$fffe
	dc.w $180,$02f0
	dc.w $5c0f,$fffe
	dc.w $180,$03f0
	dc.w $5e0f,$fffe


	dc.w $180,$04f0
	dc.w $600f,$fffe
	dc.w $180,$05f0
	dc.w $620f,$fffe
	dc.w $180,$06f0
	dc.w $640f,$fffe
	dc.w $180,$07f0
	dc.w $660f,$fffe
	dc.w $180,$08f0
	dc.w $680f,$fffe
	dc.w $180,$09f0
	dc.w $6a0f,$fffe
	dc.w $180,$0af0
	dc.w $6c0f,$fffe
	dc.w $180,$0bf0
	dc.w $6e0f,$fffe


	dc.w $180,$0cf0
	dc.w $700f,$fffe
	dc.w $180,$0df0
	dc.w $720f,$fffe
	dc.w $180,$0ef0
	dc.w $740f,$fffe
	dc.w $180,$0ff0
	dc.w $760f,$fffe
	dc.w $180,$0ff0
	dc.w $780f,$fffe
	dc.w $180,$0fe0
	dc.w $7a0f,$fffe
	dc.w $180,$0fd0
	dc.w $7c0f,$fffe
	dc.w $180,$0fc0
	dc.w $7e0f,$fffe
	

	dc.w $180,$0fb0
	dc.w $800f,$fffe
	dc.w $180,$0fa0
	dc.w $820f,$fffe
	dc.w $180,$0f90
	dc.w $840f,$fffe
	dc.w $180,$0f80
	dc.w $860f,$fffe
	dc.w $180,$0f70
	dc.w $880f,$fffe
	dc.w $180,$0f60
	dc.w $8a0f,$fffe
	dc.w $180,$0f50
	dc.w $8c0f,$fffe
	dc.w $180,$0f40
	dc.w $8e0f,$fffe
	

	dc.w $180,$0f20
	dc.w $900f,$fffe
	dc.w $180,$0f10
	dc.w $920f,$fffe
	dc.w $180,$0f00
	dc.w $940f,$fffe
	dc.w $180,$0f01
	dc.w $960f,$fffe
	dc.w $180,$0f02
	dc.w $980f,$fffe
	dc.w $180,$0f03
	dc.w $9a0f,$fffe
	dc.w $180,$0f04
	dc.w $9c0f,$fffe
	dc.w $180,$0f05
	dc.w $9e0f,$fffe
		

	dc.w $180,$0f06
	dc.w $a00f,$fffe
	dc.w $180,$0f07
	dc.w $a20f,$fffe
	dc.w $180,$0f08
	dc.w $a40f,$fffe
	dc.w $180,$0f09
	dc.w $a60f,$fffe
	dc.w $180,$0f0a
	dc.w $a80f,$fffe
	dc.w $180,$0f0b
	dc.w $aa0f,$fffe
	dc.w $180,$0f0c
	dc.w $ac0f,$fffe
	dc.w $180,$0f0d
	dc.w $ae0f,$fffe
	

	dc.w $180,$0f0f
	dc.w $b00f,$fffe
	dc.w $180,$0f1f
	dc.w $b20f,$fffe
	dc.w $180,$0f2f
	dc.w $b40f,$fffe
	dc.w $180,$0f3f
	dc.w $b60f,$fffe
	dc.w $180,$0f4f
	dc.w $b80f,$fffe
	dc.w $180,$0f5f
	dc.w $ba0f,$fffe
	dc.w $180,$0f6f
	dc.w $bc0f,$fffe
	dc.w $180,$0f7f
	dc.w $be0f,$fffe
	

	dc.w $180,$0f8f
	dc.w $c00f,$fffe
	dc.w $180,$0f9f
	dc.w $c20f,$fffe
	dc.w $180,$0faf
	dc.w $c40f,$fffe
	dc.w $180,$0fbf
	dc.w $c60f,$fffe
	dc.w $180,$0fcf
	dc.w $c80f,$fffe
	dc.w $180,$0fdf
	dc.w $ca0f,$fffe
	dc.w $180,$0fef
	dc.w $cc0f,$fffe
	dc.w $180,$0fff
	dc.w $ce0f,$fffe

	
	dc.w $180,$0fdf
	dc.w $d00f,$fffe
	dc.w $180,$0fcf
	dc.w $d20f,$fffe
	dc.w $180,$0fbf
	dc.w $d40f,$fffe
	dc.w $180,$0faf
	dc.w $d60f,$fffe
	dc.w $180,$0f9f
	dc.w $d80f,$fffe
	dc.w $180,$0f8f
	dc.w $da0f,$fffe
	dc.w $180,$0f7f
	dc.w $dc0f,$fffe
	dc.w $180,$0f6f
	dc.w $de0f,$fffe
	

	dc.w $180,$0f5f
	dc.w $e00f,$fffe
	dc.w $180,$0f4f
	dc.w $e20f,$fffe
	dc.w $180,$0f3f
	dc.w $e40f,$fffe
	dc.w $180,$0f2f
	dc.w $e60f,$fffe
	dc.w $180,$0f1f
	dc.w $e80f,$fffe
	dc.w $180,$0f0f
	dc.w $ea0f,$fffe
	dc.w $180,$0f0e
	dc.w $ec0f,$fffe
	dc.w $180,$0f0d
	dc.w $ee0f,$fffe

	
	dc.w $180,$0f0b
	dc.w $f00f,$fffe
	dc.w $180,$0f0a
	dc.w $f20f,$fffe
	dc.w $180,$0f09
	dc.w $f40f,$fffe
	dc.w $180,$0f08
	dc.w $f60f,$fffe
	dc.w $180,$0f07
	dc.w $f80f,$fffe
	dc.w $180,$0f06
	dc.w $fa0f,$fffe
	dc.w $180,$0000
	dc.w $fc0f,$fffe
	dc.w $180,$0000
	dc.w $fe0f,$fffe
	
	dc.w $180,$0000
	dc.w $ffff,$fffe 	;SIGNIFIES END OF COPPER LIST (DON'T DELETE)
	

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
**** THE TABLE OF DATA (SEE DOCS).			****
************************************************************


table
	dc.w 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	dc.w 15,14,13,12,11,10,9,8,7,6,5,4,3,2,1
	

tableloop
	dc.w 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	dc.w 15,14,13,12,11,10,9,8,7,6,5,4,3,2,1
	dc.w 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	dc.w 15,14,13,12,11,10,9,8,7,6,5,4,3,2,1
	dc.w 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	dc.w 15,14,13,12,11,10,9,8,7,6,5,4,3,2,1
	dc.w 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	dc.w 15,14,13,12,11,10,9,8,7,6,5,4,3,2,1
	dc.w 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	dc.w 15,14,13,12,11,10,9,8,7,6,5,4,3,2,1
	dc.w 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	dc.w 15,14,13,12,11,10,9,8,7,6,5,4,3,2,1
	dc.w 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	dc.w 15,14,13,12,11,10,9,8,7,6,5,4,3,2,1
	dc.w 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	dc.w 15,14,13,12,11,10,9,8,7,6,5,4,3,2,1
	dc.w 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	dc.w 15,14,13,12,11,10,9,8,7,6,5,4,3,2,1
	dc.w 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	dc.w 15,14,13,12,11,10,9,8,7,6,5,4,3,2,1



tablesz
	dc.w tableloop-table
loopval
	dc.l 0		


		*********************************
		***** ENJOY YOURSELVES !!!! *****
		*********************************
*	A.GIBSON
*	PLEASE USE AS FREELY AS YOU WISH
* 	COPY,ALTER USE THIS CODE AS MUCH AS YOU WANT



