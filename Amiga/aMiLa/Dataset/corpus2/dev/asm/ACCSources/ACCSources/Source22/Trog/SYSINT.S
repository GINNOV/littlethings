*******************************************************************************
**********************INTERUPT SERVER ROUTINE V1.0*****************************
*********************CODED BY THE THE TROG 23/12/91****************************
*******************************************************************************
* IMPORTANT INFO
* ALL CODE BY THE TROG/ODESSA IN DECEMBER 1991
* FULL A500 PLUS AND KICKSTART V2.0 (A3000) COMPATIBLE (AS ALWAYS)
* COMMODORES OFFICIAL O/S FREINDLY WAY OF ADDING INTERUPTS 
* EASY TO FOLLOW DOCUMENTATION 
* FOR FULL STRUCTURE INFO SEE MAPPING THE AMIGA (COMPUTE)
*******************************************************************************
	OPT C-				* NO CASE SENSATIVE AND MY MAGIC
	INCDIR  source:INCLUDE/		* INCLUDE FILE
	INCLUDE LIBOFFSETS.I
*******************************************************************************
* THE FOLLOWING ROUTINE WILL RESERVE MEMORY AND COPY THE INTERUPT CODE TO IT
*******************************************************************************
	MOVE.L	4,A6			*EXEC BASE ADRESS (ALWAYS 4 FOR ANY AMIGA)
	MOVE.L	#CODEND-CODESTART,D0	*SIZE OF CODE TO COPY
	MOVE.L  #MEMF_PUBLIC,D1		*MEMORY TYPE PUBLIC (CAN NOT BE MOVED)
	JSR	ALLOCMEM(A6)		*O/S CALL TO RESERVE MEMORY
	TST.L	D0			*WAS MEMORY CALL SUCCESFULL 
	BEQ	ERROR			*IF NOT THEN EXIT QUICK
	MOVE.L	D0,A5			*BASE ADRESS OF ALLOCATED MEMORY TO A5
	MOVE.L	D0,INTERMEM		*STORAGE SPACE FOR INTERUPT CODE START
        LEA	CODESTART,A0		*START OF CODE TO COPY
	MOVE.L  D0,A1			*START OF DESTINATION CODE
	MOVE.L  #CODEND-CODESTART,D0	*HOW MUCH CODE TO COPY
	JSR	COPYMEM(A6)		*O/S CALL TO COPY MEMORY
*******************************************************************************
* THE FOLLOWING CODE WILL INISIALIZE THE INTERUPT STRUCTURE
*******************************************************************************
	LEA	INTSTRCT-CODESTART(A5),A1	  * START OF INTERUPT STRUCTURE
        MOVE.B 	#NT_INTERRUPT,LN_TYPE(A1)	  * NODE TYPE = INTERUPT
        MOVE.B 	#-60,LN_PRI(A1)			  * PRIORITY = - 60 (-127 TO +128)
        MOVE.L 	MYNAME-CODESTART(A5),LN_NAME(A1)  * POINTER TO INTERUPT NAME
        MOVE.L 	#0,IS_DATA(A1)			  * SIZE OF INTERUPT DATA BUFFER
        MOVE.L  A5,IS_CODE(A1)                    * START OF INTERUPT CODE TO EXECUTE
*******************************************************************************
* THE FOLLOWING CODE IS THE O/S CALL TO ADD INTERUPT TO THE EXEC INTERUPT LIST
*******************************************************************************
        MOVE.L 	$4,A6			  * EXEC BASE ADRESS (ALWAYS 4)
        LEA	INTSTRCT-CODESTART(a5),A1 * START OF INTERUPT STRUCTURE
        MOVE.L 	#INTB_VERTB,D0			  * INTERUPT NUMBER PRIORITY=5 (1 TO 15)
        JSR 	ADDINTSERVER(A6)	  * O/S CALL TO ADD INTERUPT TO SYS LIST
ERROR:   
	RTS				  * NO MEMORY OR INTERUPT INSTALLED
********************************************************************************
* INTERUPT CODE AND INTERUPT STRUCTURE
********************************************************************************
CODESTART: 			* DOES IT REALLY NEED EXPLAINING
	BTST	#6,$BFE001	* YOUR INTERUPT CODE GOES HERE
	BNE	OUT		* NOTE = YOU MUST END WITH RTS NOT RTE
        BCHG	#1,$BFE001	* FOR GUIDLINES ON AMIGA PROGRAMING SEE (RKM)
OUT:	RTS
********************************************************************************
* VARIOUS SYSTEM STRUCTURES POINTERS AND STORAGE VALUES
********************************************************************************
MYNAME: 
	DC.B 'TROGS INTERUPT',0	* NAME OF INTERUPT (OPTIONAL)
	EVEN
INTERMEM:
	DC.L	0		* START ADRESS OF INTERUPT ALLOCATED MEMORY

INTSTRCT:
	DS.L	14		* INTERUPT NODE STRUCTURE 
	DC.L	0		* POINTER TO INTERUPT DATA BUFFER
	DC.L	0		* PROGRAME TO BE EXECUTED ON RESET

CODEND:

