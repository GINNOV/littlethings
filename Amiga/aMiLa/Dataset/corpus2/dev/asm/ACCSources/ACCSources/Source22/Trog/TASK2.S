*******************************************************************************
***************************SYSTEM TASK INSTALLER V1.5**************************
*******************************************************************************
************************CODED BY THE TROG IN DECEMBER 91***********************
*******************************************************************************
********************************IMPORTANT NOTES********************************
* ALL CODE WAS CODED BY THE TROG/ODESSA ON THE 18/12/91 UPDATED 24/12/91
* YET ANOTHER FINE DOCUMENTED ROUTINE BY TROG 
* FOR A REALLY GOOD INFO ON THE TASK STRUCTURE SEE (MAPPING THE AMIGA (COMPUTE)
* COMPLETE A 500 PLUS COMPATIBLE AS IT WAS CODED ON ONE (BRILLENT MACHINE)
* DESPRATELY WANTED KICKSTART 2 DOCUMENTS AND V2.0 INCLUDE FILES
* THIS CODE IS UNIQUE IN THE SENSE IVE NEVER SEEN ANY CODE ON INSTALLING TASKS
* ON ANY SOURCE CODE DISKS IVE BEEN SENT OR IN MAGAZINES IVE READ, APART FROM
* CRAPPY C LISTINGS THAT I DONT UNDERSTAND (THE MAIN REASON FOR WRITING THIS)
*******************************************************************************
	   OPT C-			*THE USUAL STUFF NO CASE SENSATIVE
  	   INCDIR  source:INCLUDE/		
	   INCLUDE LIBOFFSETS.I    *MY SPECIAL INCLUDE FILE
*******************************************************************************
*USUAL EQAUTES FOR TASK STRUCTURE SIZE AND STACK SIZE ECT
*******************************************************************************
TASKSTRCSIZE:	EQU	92		*SIZE OF THE TASK STRUCTURE 92 BYTES
TASKSTACKSIZE:	EQU	1024		*TASK STACK SIZE (MIN 72 BYTES)
*******************************************************************************
* RESERVE MEMORY FOR TASK CODE,TASK STACK AND TASK NODE STRUCTURE 
*******************************************************************************
INSTALLTASK:	  
	  MOVE.L $4,A6				*EXEC BASE ADRESS   	
          MOVE.L #MEMF_PUBLIC!MEMF_CLEAR,D1	*MEMORY REQUIRMENTS (IMPORTANT)
          MOVE.L #TASKSTRCSIZE,D0		*SIZE OF TASK STRUCTURE +
	  ADD.L  #TASKSTACKSIZE,D0		*SIZE OF TASK STACK +
	  ADD.L  #TASKEND-TASKSTART,D0		*SIZE OF TASK PRG = TOTAL REQ.
	  JSR	 ALLOCMEM(A6)			*LIBRARY CALL TO RESERVE MEM
          TST.L  D0				*WAS THE MEMORY AVALIBLE
	  BEQ	 ERROR				*IF NOT THEN CANT INSTALL TASK
	  MOVE.L D0,TASKMEM			*EVERY THING O.K (STORE ADRESS)
********************************************************************************
* ROUTINE TO COPY TASK TO ALLOCATED MEMORY
********************************************************************************
	  MOVE.L #TASKEND-TASKSTART,D0 * HOW MUCH MEMORY TO COPY
	  MOVE.L #TASKSTART,A0	       * START ADRESS OF TASK PROGRAME
	  MOVE.L TASKMEM,D6	       * START ADRESS OF MEMORY FOR TASK
	  ADD.L	 #TASKSTACKSIZE+TASKSTRCSIZE,D6 * D6 = START ADRESS TO COPY PRG
	  MOVE.L D6,A1		       * START ADRESS OF TASK CODE TO A1
 	  JSR	 COPYMEM(A6)	       * O/S CALL TO COPY MEMORY
	  MOVE.L TASKMEM,A1            * START ADRESS OF ALLOCATED MEMORY TO A1
	  MOVE.L A1,D0		       * START ADRESS OF TASK STRUCTURE 96 BYTES
********************************************************************************
* THE FOLLOWING CODE INITIALISES THE TASK NODE STRUCTURE AND SETS UP A STACK
********************************************************************************
	  ADD.L  #TASKSTRCSIZE,D0 	*ADD THE TASKSTRUC SIZE TO D0 = THE
          MOVE.L D0,TC_SPLOWER(A1)	*LOWER ADRESS OF THE STACK
	  ADD.L  #TASKSTACKSIZE,D0	*ADD 1024 TO D0 = A 1K STACK = CODE START
	  MOVE.L D0,TASKPRGST		*STORE START OF TASK-CODE FOR LATER USE
  	  MOVE.L D0,TC_SPUPPER(A1)      *UPPER ADRESS OF THE STACK
	  MOVE.L D0,TC_SPREG(A1)	*STACK POINTER START (DECENDING STACK)
	  MOVE.L TASKPRGST,A5		*TASK CODE START ADRESS
          LEA	 TASKNAME-TASKSTART(A5),A5  *POINTER TO TASK NAME 
	  MOVE.L A5,LN_NAME(A1)		*COPY TASK NAME INTO TASK STRUCTURE
          MOVE.B #NT_TASK,LN_TYPE(A1)   *NODE TYPE = TASK NODE     
          MOVE.B #0,LN_PRI(A1)	        *TASK PRIORITY = (-127 TO +128) NORM = 0
********************************************************************************
* LIBRARY CALL TO ADD THE TASK TO THE SYSTEM TASKS
********************************************************************************
	  MOVE.L TASKMEM,A1	* START OF THE TASK NODE STRUCTURE = 92 BYTES
          MOVE.L A1,D0		* COPY TO D0 SO WE CAN ADD TASK STRUCTURE AND			
	  ADD.L  #TASKSTRCSIZE+TASKSTACKSIZE,D0 *STACK SIZE FOR TASKCODE START
	  MOVE.L D0,A2 		* FIRST INSTRUCTION TO EXECUTE ONCE TASK IS ADDED
          MOVE.L #0,A3		* SET TO 0 FOR EXEC DEFAULT TASK REMOVAL
          MOVE.L $4,A6 		* EXEC (THE ONLY ABSOLUTE BASE ADRESS ON AMIGA)
          JSR    ADDTASK(A6)	* LIBRARY CALL TO ADD TASK TO SYSTEM TASKS
ERROR:	  RTS			* END OF TASK INSTALLATION OR NO MEMORY RETURN
********************************************************************************
* VARIOUS STORAGE POINTERS (THE USUAL STUFF)
********************************************************************************
TASKMEM:	
	DC.L	0		* START OF ALLOCATED MEM TASK STRUCTURE 92 BYTES
TASKPRGST:
	DC.L	0		* START OF THE TASK TO RUN AFTER INSILIZATION
*********************************************************************************
* ACTUAL TASK PROGRAME DOES IT REALLY NEED EXPLAINING
*********************************************************************************
TASKSTART: 			* YOUR TASK GOES HERE MAKE SURE CODE IS 
	BCLR	#1,$BFE001	* P.C RELATIVE ELSE PROBLEMS WILL ARISE
	BSET	#1,$BFE001	* BECASE OF LABELS AND JSR ECT.
	BTST	#7,$BFE001	* OR YOU COULD WRITE YOUR OWN HUNK LOADER
	BNE	TASKSTART	* TO CORRECT THE WRONG ADRESSES OR EVEN BETTER
	BTST    #6,$BFE001	* ONCE YOU START TO RUN THE TASK ALLOCATE MEMORY
	BNE	TASKSTART	* FROM THE TASK ITSELF BUT MAKE SURE THE TASK
	RTS			* OR PRG IT WAS STARTED FROM HAS ENDED FIRST
				* AND YOU SPECIFY THE TASKS START AND END ADRESS
*********************************************************************************
* VARIOUS TASK VARIBLES AND POINTERS
*********************************************************************************
TASKNAME:
	DC.B	"TASK V1.1",0	* INCLUDED IN TASK PRG TO SHOW NAME OF 
	EVEN			* TASK ON A MONITOR OR DEBUUGER
TASKEND:    
