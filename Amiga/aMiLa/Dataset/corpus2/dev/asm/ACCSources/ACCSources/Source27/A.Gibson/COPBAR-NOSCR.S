**********COPPER ROTATE WITH MOVE***********************
** THIS IS SIMILAR TO THE BASIC COPPER ROTATE BUT     **
** NOW,THE POSITION OF WHERE THE DATA IS COPIED TO    **
** CHANGES THUS GIVING THE EFFECT OF A MOVING LINE    **
** THE SCROLLING ROUTINE HAS BEEN TAKEN OUT (SEE DOCS **
******************************************************** 

execbase=4
allocmem=-$c6
openlib=-408
permit=-138
forbid=-132
custom=$dff000
dmacon=$96
cop1lc=$80
freemem=-$d2
closelib=-414
copjmp1=$88


***********************************************
**** ALLOCATE MEMORY FOR BOTH COPPER LISTS ****

	move.l execbase,a6	;
	move.l clistsz,d0	;GET CLIST SIZE
	move.l #65539,d1	;CHIP MEMORY
	jsr allocmem(a6)	;ALLOCATE MEMORY
	move.l d0,clistadd1	;SAVE COPPERLIST MEMORY ADDRESS
	beq exit		;QUIT IF NO-GO
	move.l execbase,a6	;
	move.l clistsz,d0	;SAME AS ABOVE BUT
	move.l #65539,d1	;FOR THE SECOND LOCATION
	jsr allocmem(a6)	;OF THE COPPER LIST
	move.l d0,clistadd2	;
	beq exit		;

	
copylist
	lea clistst,a0		;START OF COPPER DATA IN A0
	move.l clistadd1,a1	;FIRST COPPER ADDRESS IN A1
	move.l clistadd2,a2	;SECOND COPPER ADDRESS IN A2
	move.l clistsz,d0	;SIZE OF LIST IN D0
	subi.l #1,d0		;TAKE ONE OFF IT
clistcopy

	move.b (a0),(a1)+	;MOVE DATA INTO FIRST PART OF CHIPMEM
	move.b (a0)+,(a2)+	;MOVE DATA INTO SECOND PART OF CHIPMEM
	dbra d0,clistcopy	;LOOP UNTIL D0=0

********************************************************************
setup_col_copy_size
	
	move.l clistsz,d0	;GET COPPER SIZE
	lsr #3,d0		;SHIFT RIGHT X 3 (DIVIDE BY 8)
	move.w d0,loopval	;STORE VALUE
	
*********************************************************************
openlibraries
	move.l execbase,a6	
	move.l #grapname,a1	;PUT LIB NAME POINTER IN A1
	jsr openlib(a6)		;OPEN LIBRARY
	move.l d0,grapbase	;STORE LIB BASE
*********************************************************************
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


	move.l #movedat,a1	;SET ADDRESS OF MOVEDATA START IN A1
	move.l a1,moveptr	;STORE VALUE IN MOVEPTR

loop

	move.l curradd,d4	;GET VALUE OF COPPERLIST IN USE
	cmp.l clistadd1,d4	;IS IT FIRST LIST ?
	beq second		;IF SO PUT SECOND LIST ADDRESS IN A2
	move.l clistadd1,a2	;ELSE PUT FIRST LIST ADDRESS IN A2
	bra skip		;AND BRANCH

second
	move.l clistadd2,a2	;PUT SECOND LIST ADDRESS IN A2
skip
	move.l a2,curradd	;STORE A2 AS ADDRESS TO BE UPDATED AND USED
				;A2 IS THE ADDRESS OF THE START OF THE COPPER LIST
				;TO BE UPDATED

	move.l moveptr,a1	;GET POINTER TO MOVEDATA INTO A1
	move.w (a1)+,d0		;GET OFFSET TO START CHANGING COPPER DATA
	move.l a1,moveptr	;SAVE UPDATED POINTER
	cmp #$ffff,d0		;IS DATA $FFFF
	bne continue		;IF SO,CARRY ON 

	move.l #movedat,a1	;PUT ADDRESS OF START OF MOVE TABLE IN A1
	move.w (a1),d0		;RE-READ MOVE DATA (from beginning of table)
	move.l a1,moveptr	;STORE UPDATED POINTER

continue
**************************************************************************
*** CALCULATE OFFSET FROM THE START OF THE COLOUR TABLE ***
**** AND THE OFFSET FROM THE START OF THE COLOUR LIST *****
	
	move.l d0,d4		;COPY D0 INTO D4 

	lsl #3,d0		;MULTIPLY BY 8
	add.w #2,d0		;ADD 2 TO GET TRUE OFFSET FROM START
				;OF COPPER LIST

	lsl #1,d4		;D4 X 2 TO GET CORRECT OFFSET OF COL TABLE IN WORDS
*************************************************************************************
**** SET UP COLOUR COPY VALUES ****

	add.w d0,a2 		;OFFSET COPPER POINTER BY D0
	move.l #table,a1	;PUT START ADDRESS OF COLOUR TABLE IN A1
	move.w loopval,d0	;GET COPY LOOP VALUE INTO D0
	sub.w #105,d0		;TAKE (LOOPVAL-WIDTH) OFF LOOP VALUE
	add d4,a1		;PUT  COL TABLE POSITION IN A1
**************************************************************************

blankcop
	move.l d0,temp_d0	;STORE D0
	move.l curradd,a4	;PUT START ADDRESS OF COPPLIST TO BE UPDATED IN A4
	add.W #2,a4		;PUT COPPER LIST OFFSET OF 2 (POINT TO COLOUR WORD)
	move.w loopval,d0	;SET NUMBER OF TIMES LOOPED
	sub.w #3,d0		;ADJUST LOOP COUNTER
blankloop
	clr.w (a4)		;CLEAR COPPERLIST COLOUR
	add.l #8,a4		;MOVE POINTER TO NEXT COPPER LIST COLOUR WORD
	dbra d0,blankloop	;REPEAT UNTIL D0=0

	move.l temp_d0,d0	;RESTORE D0


**************************************************************************
copy				
	move.w (a1)+,(a2)+	;COPY COLOUR DATA INTO CLIST DATA
	add.l #6,a2		;MOVE COPPER POINTER TO NEXT COLOUR DATA
	dbra d0,copy		;REPEAT UNTIL COPY IS COMPLETE (D0=0)
		
	lea custom,a5		;PUT CUSTOM REG ADDRESS INTO A5
	move.l curradd,cop1lc(a5)	;USE NEW UPDATED COPPERLIST



	move.l #$b00,d0		;PAUSE ROUTINE	
pause				;TO SLOW DOWN THE ACTION
	sub.l #1,d0		;NOT NECESSARY IF USING
	cmp #0,d0		;INTERRUPTS.
	bne pause		;PUT A BIGGER NUMBER IN D0 FOR A LONGER
				;DELAY AND VICE-VERSA

				
	btst #6,$bfe001		;TEST FOR LEFT MOUSE BUTTON
	bne loop		;OTHERWISE BRANCH TO NESTED LOOP

**************************************************************************
endloop

	move.l grapbase,a4		;GET GRAPHICS BASE
	move.l 38(a4),cop1lc(a5);RESTORE OLD COPPER LIST
	move.w #$83e0,dmacon(a5)	;ENABLE ALL DMA
	clr.w copjmp1(a5)		;START COPPER ACTIVITY
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
	dc.w $180,$0000
	dc.w $d80f,$fffe
	dc.w $180,$0000
	dc.w $da0f,$fffe
	dc.w $180,$0000
	dc.w $dc0f,$fffe
	dc.w $180,$0000
	dc.w $de0f,$fffe


	
	dc.w $180,$0000
	dc.w $e00f,$fffe
	dc.w $180,$0000
	dc.w $e20f,$fffe
	dc.w $180,$0000
	dc.w $e40f,$fffe
	dc.w $180,$0000
	dc.w $e60f,$fffe
	dc.w $180,$0000
	dc.w $e80f,$fffe
	dc.w $180,$0000
	dc.w $ea0f,$fffe
	dc.w $180,$0000
	dc.w $ec0f,$fffe
	dc.w $180,$0000
	dc.w $ee0f,$fffe


	dc.w $180,$0000
	dc.w $f00f,$fffe
	dc.w $180,$0000
	dc.w $f20f,$fffe
	dc.w $180,$0000
	dc.w $f40f,$fffe
	dc.w $180,$0000
	dc.w $f60f,$fffe
	dc.w $180,$0000
	dc.w $f80f,$fffe
	dc.w $180,$0000
	dc.w $fa0f,$fffe
	dc.w $180,$0000
	dc.w $fc0f,$fffe
	dc.w $180,$0000
	dc.w $fe0f,$fffe
	
	dc.w $180,$0000
	dc.w $ffff,$fffe

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
	dc.w 0,0,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	dc.w $10f,$20f,$30f,$40f,$50f,$60f,$70f,$80f
	dc.w $90f,$a0f,$b0f,$c0f,$d0f,$e0f,$f0f
	dc.w $f1e,$f2d,$f3c,$f4b,$f5a,$f69,$f78,$f87
	dc.w $f96,$fa5,$fb4,$fc3,$fd2,$fe1,$ff0
	dc.w $ff0,$ff0,$fe0,$fd0,$fc0,$fb0,$fa0,$f90
	dc.w $f80,$f70,$f60,$f50,$f40,$f30,$f20,$f10
	dc.w $f00,$f00,$e01,$d02,$c03,$b04,$a05,$906
	dc.w $807,$708,$609,$50a,$40b,$30c,$20d,$10e,15
	dc.w $0f,$1f,$2f,$3f,$4f,$5f,$6f,$7f,$8f,$9f,$af
	dc.w $bf,$cf,$df,$ef,$ff,$ff,$fe,$fd,$fc,$fb,$fa
	dc.w $f9,$f8,$f7,$f6,$f5,$f4,$f3,$f2,$f1,$f0
	dc.w $1f1,$2f2,$3f3,$4f4,$5f5,$6f6,$7f7,$8f8,$9f9
	dc.w $afa,$bfb,$cfc,$dfd,$efe,$fff,$ffe,$ffd,$ffc,$ffb
	dc.w $ffa,$ff9,$ff8,$ff7,$ff6,$ff5,$ff4,$ff3,$ff2,$ff1,$ff0
	dc.w $fe0,$fd0,$fc0,$fb0,$fa0,$f90,$f80,$f70,$f60,$f50,$f40
	dc.w $f30,$f20,$f10,$f00,$f00,$e00,$d00,$c00,$b00,$a00,$900
	dc.w $800,$700,$600,$500,$400,$300,$200,$100,$0,0

	
tableloop
	dc.w 0,0,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	dc.w $10f,$20f,$30f,$40f,$50f,$60f,$70f,$80f
	dc.w $90f,$a0f,$b0f,$c0f,$d0f,$e0f,$f0f
	dc.w $f1e,$f2d,$f3c,$f4b,$f5a,$f69,$f78,$f87
	dc.w $f96,$fa5,$fb4,$fc3,$fd2,$fe1,$ff0
	dc.w $ff0,$ff0,$fe0,$fd0,$fc0,$fb0,$fa0,$f90
	dc.w $f80,$f70,$f60,$f50,$f40,$f30,$f20,$f10
	dc.w $f00,$f00,$e01,$d02,$c03,$b04,$a05,$906
		











tablesz
	dc.w tableloop-table
loopval
	dc.l 0
moveptr
	dc.l 0
movedat
	dc.w 1,1,1,1,2,2,2,2,2,3,3,3,4,4,4
	dc.w 5,5,6,7,8,9
	dc.w 10,11,12,13,14,15,16,17,18,19
	dc.w 20,21,22,23,24,25,26,27,28,29
	dc.w 30,31,32,33,34,35,36,37,38,39
	dc.w 40,41,42,43,44,45,46,47,48,49
	dc.w 50,51,52,53,54,55,56,57,58,59
	dc.w 60,61,62,63,64,65,66,67,68,69
	dc.w 70,71,72,73,74,75,76,77,78,79
	dc.w 80,81,82,83,84,85,86,87,88,89
	dc.w 90,91,92,93,94,95,96,97,98,99
	dc.w 98,97,96,95,94,93,92,91,90,89
	dc.w 88,87,86,85,84,83,82,81,80,79
	dc.w 78,77,76,75,74,73,72,71,70,69
	dc.w 68,67,66,65,64,63,62,61,60,59
	dc.w 58,57,56,55,54,53,52,51,50,49
	dc.w 48,47,46,45,44,43,42,41,40,39
	dc.w 38,37,36,35,34,33,32,31,30,29
	dc.w 28,27,26,25,24,23,22,21,20,19
	dc.w 18,17,16,15,14,13,12,11,10,9
	DC.W 8,7,6,5,5,4,4,4,3,3,3,2,2,2,2
	dc.w 2,1,1
	dc.w $ffff


temp_d0
	dc.l 0
temp_a4
	dc.l 0
TEMP_A2
	DC.L 0



		************************************
		******* ENJOY THE CODE !!!!! *******
		************************************	

