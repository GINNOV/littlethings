****open playfield of 2 bit planes****

execbase=4
allocmem=-198
freemem=-210
permit=-138
forbid=-132
ciaapra=$bfe001
startlist=38
openlib=-408
colour0=$0000
colour1=$0117
colour2=$044b
colour3=$088f

****reset colour values in data section****

	move.l #col0,a0			THIS LITTLE SECTION
					;HERE RESTORES ALL THE 
	move.w #colour0,(a0)+		VALUES IN MEMORY SO
	move.w #colour1,(a0)+		THAT THE PROGRAM CAN
	move.w #colour2,(a0)+		BE RERUN WITHOUT HAVING
	move.w #colour3,(a0)+		TO ASSEMBLE IT AGAIN

	move.l #clistdata,a0		IT RESTORES ALL THE COLOUR
	add.l #2,a0			VALUES IN MEMORY TO THEIR
					;ORIGINAL STATES AS AFTER THE PROG
	move.w #colour0,(a0)		HAS FINISHED,ALL COLOUR VARIABLES
	add.l #4,a0			ARE SET TO 0 DUE TO THE FADE.

	move.w #colour1,(a0)
	add.l #4,a0

	move.w #colour2,(a0)
	add.l #4,a0

	move.w #colour3,(a0)

****reserve memory for copper list ****
	move.l #80,d0			PUT A ROUGH SIZE VALUE,80,IN
	move.l #2,d1			MAKE IT CHIP MEM
	move.l execbase,a6
	jsr allocmem(a6)	
	move.l d0,clist			STORE MEM ADDRESS
	cmp #0,d0
	beq fastexit
********reserve memory for the 2 bit planes****
	move.l #2*256*40,d0		BIT PLANE SIZE * 2
	move.l #2,d1			CHIP MEM
	move.l execbase,a6
	jsr allocmem(a6)
	move.l d0,bpladd		STORE START OF BIT PLANE MEMORY
	cmp #0,d0	
	beq exit

****clear both bit planes***

	move.l bpladd,a1		A LOOP TO PUT 0'S IN THE
	move.l #5119,d3			BIT PLANE MEMORY TO CLEAR THE
clearplane				;SCREEN
	move.l #0,(a1)+
	dbra d3,clearplane

********sort out copper bit planes****
	move.l bpladd,d0		D0-->START OF BIT PLANE MEM
	move.l #copplanes,a0		A0-->BPL POINTER VAL IN COP LIST
	swap d0				SWAP HI AND LO WORDS IN D0
	move.w d0,(a0)			STORE IN BPLPTH1 IN COP LIST
	add.l #4,a0			INCREMENT COPPER POINTER
	swap d0				RE SWAP D0 (TO ORIGINAL STATE)
	move.w d0,(a0)			STORE OTHER HALF OF D0 IN BPL1PTL1

	add.l #256*40,d0		D0-->START ADDRESS OF SECOND BPL
	add.l #4,a0			INCREMENT COPPER POINTER

	swap d0				SWAP HI AND LO WORDS IN D0
	move.w d0,(a0)			STORE HI WORD IN BPL2PTH IN COP LIST
	add.l #4,a0			INCREMENT POINTER
	swap d0				RE SWAP D0 TO ORIGINAL STATE
	move.w d0,(a0)			STORE LO WORD OF D0 IN BPL2PTL
****copy copperlist****	
	move.l clist,a0			A0-->CHIP MEM LOC FOR COPPERLIST (DESTINATION)
	move.l #clistdata,a1 		A1-->COP LIST TO BE COPIED (AT THE END OF THE CODE)
cloop
	move.l (a1)+,(a0)+		COPY DATA INTO CHIP MEM
	move.l (a1),d0			D0=DATA POINTED TO BY A1
	cmp.l #0,d0			IS IT 0
	bne cloop			IF NOT CARRY ON COPYING

**** KILL O/S ****
	move.l execbase,a6
	jsr forbid(a6)			STOP MUTITASKING
	lea $dff000,a5			PUT CUSTOM CHIP BASE IN A5
	move.w #$01e0,dmacon(a5)	STOP DMA	

****start copper list****

	move.l clist,cop1lch(a5)	LOAD ADDRESS OF CLIST INTO COPPER PC
	move.w #0,copjmp1(a5)		STROBE ADDRESS TO START COPPER LIST

****start bitplane****
	move.w #$3081,diwstrt(a5)	SET DIsplay Window START
	move.w #$30c1,diwstop(a5)	SET DIsplay Window STOP
	move.w #$0038,ddfstrt(a5)	SET Data Fetch START
	move.w #$00d0,ddfstop(a5)	SET Data Fetch STOP
	move.w #%0010001000000000,bplcon0(a5)	SET 2 BITPLANES,COLOUR ON
	move.w #0,bplcon1(a5)		
	move.w #0,bplcon2(a5)		
	move.w #0,bpl1mod(a5)		NO MODULO
	move.w #0,bpl2mod(a5)		NO MODULO
	move.w #$8380,dmacon(a5)	ALLOW DMA ACCESS
**** finish bitplane setup***
************************************************************************

***load picture into bitplanes***

	
	move.l #1,d0		d0=line numbers to show
picloop
	move.l bpladd,a0	a0-->bit plane plane address
	move.l #picture,a1	a1-->picture start address
	add.l #10240,a1		a1-->end of picture BP
	move.l d0,d1		save d0
	mulu #40,d0		mutiply line num by bytes per line
	sub.l d0,a1		a1-->start of data to be copied

	sub.l #1,d0		TAKE 1 OFF D0 (USING DBRA!)

	move.l a0,a3		COPY DEST ADD IN A3
	move.l a1,a4		COPY SOURCE ADD IN A4
	add.l #10240,a3		GIVE OFFSET (TO POINT TO NEXT PLANE)
	add.l #10240,a4		"	"	"	"	"

	lsr #2,d0		DIVIDE D0 BY 4 (USING LONG WRDS NOT BYTES)

waitforpos
	cmpi.b #55,$dff006	IS VIDEO BEAM AT LINE 310
	bne waitforpos		IF NOT WAIT

copyloop1
	move.l (a4)+,(a3)+	COPY FROM PIC PLANE 1 TO BIT PLANE 1
	move.l (a1)+,(a0)+	COPY FROM PIC PLANE 2 TO BIT PLANE 2
	dbra d0,copyloop1	REPEAT UNTIL COPY IS COMPLETE


*******pause process*******

	move.l #$6ff,d3		HANG ABOUT FOR A BIT SO YOU CAN SEE
pauseloop
	sub.l #1,d3		THE SCROLL GOING ON
	cmp #0,d3
	bne pauseloop
***************************

	move.l d1,d0		restore d0=line num
	add.l #1,d0		increment line num
	cmp #256,d0		should we exit?
	bne picloop		no repeat scroll
	
wait

****check mouse button****

	btst #6,ciaapra		HAVE LEFT MOUSE BUTTON BEEN PRESSED
	bne.s wait		IF NO,WAIT AROUND

****colour fade****

repeatfade

	move.l #$48ff,d0	PAUSE IN THE FADE LOOP
waitloop
	sub.l #1,d0
	cmp #0,d0
	bne waitloop
********************************************
		
	move.l #col0,a0		A0-->FIRST COLOUR IN LIST IN MEMORY
	move.l #3,d2		D2=LOOP COUNTER (No. OF COLS-1(USING DBRA))
	clr.l d0		CLEAR D0
	clr.l d1		CLEAR D1

fadeloop

	move.w (a0),d0		PUT COLOUR VALUE ($0RGB) IN D0
	move.l d0,d1		MAKE A COPY OF IT
	and #%1111,d0		ANY OF THE FIRST FOUR BITS SET?
	beq skip1		IF NOT GOTO SKIP1
	sub #1,d1		TAKE 1 OFF THE COLOUR VALUE IN D1

skip1
	move.l d1,d0		RESTORE COLOUR VALUE IN D0
	and #%11110000,d0	ARE ANY OF THE MIDDLE 4 BITS SET?
	beq skip2		IF NOT,GOTO SKIP2
	sub #$10,d1		ELSE TAKE #$10 OF BACKUP COLOUR VALUE

skip2
	move.l d1,d0		RESTORE COLOUR VALUE IN D0
	and #%111100000000,d0	ARE ANY OF THE FINAL(RED) 4 BITS SET?
	beq skip3		IF NOT,GOTO SKIP3
	sub #$100,d1		ELSE TAKE $100 OF THE BACKUP COLOUR VALUE

skip3
	move.w d1,(a0)+		PUT UPDATED COLOUR VALUES INTO COLOUR TABLE

	dbra d2,fadeloop	REPEAT FOR NEXT COLOUR

	move.l clist,a0		A0-->LIST IN CHIP MEM
	move.l #col0,a1		A1-->COLOUR TABLE
	move.l #3,d2		D2=LOOP COUNTER =(No. OF COLOURS-1)
	add.l #2,a0		MOVE COPPER PTR ON 1 WORD TO POINT
				;TO COLOUR VALUE IN COP LIST
colcoploop

	move.w (a1)+,(a0)	COPY COLOUR VALUE TO COPPER COL VAL
	add.l #4,a0		INCR COPPER PTR TO NEXT COLOUR VALUE
	dbra d2,colcoploop	END OF LOOP?
			
***check if fade finished?***

	move.w col0,d0		PUT FIRST COLOUR VALUE IN D0
	add.w (col1),d0		ADD SECOND VALUE TO D0
	add.w (col2),d0		ADD THIRD VALUE TO D0
	add.w (col3),d0		ADD FOURTH VALUES
	
	cmp #0,d0		IS THE SUM=0
	bne repeatfade		NO,COLOUR ARE NOT ALL 0,REPEAT FADE

**** restore system copper list ****
 
	move.l #$dff000,a5	PUT CUSTOM BASE IN A5
	lea libname,a1		A1-->LIBRARY NAME
	move.l #0,d0		CLEAR D0
	move.l execbase,a6	
	jsr openlib(a6)		OPEN GRAPHICS LIBRARY
	move.l d0,a4		A4=GRAPHICS LIB BASE
	move.l startlist(a4),cop1lch(a5)	PUT SYS COP LIST IN COPPER PC
	move.w #0,copjmp1(a5)	STROBE COPPER,START LIST
	move.w #$83e0,dmacon(a5)	ENABLE SYS DMA
	jsr permit(a6)		ALLOW MUTITASKING

**** free memory ****

	move.l clist,a1		FREE COPPER
	move.l #80,d0		LIST CHIP MEMORY
	jsr freemem(a6)

exit
 	move.l bpladd,a1	FREE BIT PLANE
	move.l #40*256*2,d0	CHIP MEMORY
	jsr freemem(a6)

fastexit
	rts


				;COPPER LIST DATA
clistdata	
	dc.l $01800000		;COLOUR 0
	dc.l $01820000		;COLOUR 1
	dc.l $01840000		;COLOUR 2
	dc.l $01860000		;COLOUR 3

	dc.w bpl1pth		
copplanes			;THESE ARE THE
	dc.w 0,bpl1ptl		;BIT PLANE POINTERS
	dc.w 0,bpl2pth		;WHICH POINT TO THE
	dc.w 0,bpl2ptl		;START OF THE BITPLANES
	dc.w 0			;FOR THE SCREEN
	
	dc.l $fffffffe		;END COPPER
	dc.l 0,0		;NULL BYTE TO TERMINATE (DON'T DELETE)
clist
	dc.l 0

bpladd
	dc.l 0
libname
	dc.b "graphics.library",0,0
	even
col0
	dc.w 0		;COPIES OF THE
col1			;COLOURS IN USE
	dc.w 0		;FOR USE IN THE FADE
col2			;ROUTINE
	dc.w 0
col3
	dc.w 0

picture
	incbin dk.bm

*********************************************
bpl1pth=$e0
bpl2pth=$e4
dmacon=$96
cop1lch=$80
copjmp1=$88
bpl1mod=$108
bpl2mod=$10a
diwstrt=$08e
diwstop=$090
ddfstrt=$092
ddfstop=$094
bplcon0=$100
bplcon1=$102
bplcon2=$104
bpl1ptl=$e2
bpl2ptl=$e6

