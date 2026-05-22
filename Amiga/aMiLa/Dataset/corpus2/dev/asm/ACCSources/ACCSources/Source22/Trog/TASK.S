*******************************************************************************
***************************SYSTEM TASK INSTALLER V1.1**************************
*******************************************************************************
************************CODED BY THE TROG IN DECEMBER 91***********************
*******************************************************************************
********************************IMPORTANT NOTES********************************
* ALL CODE WAS CODED BY THE TROG ON THE 18/12/91
* YET ANOTHER FINE DOCUMENTED ROUTINE BY TROG 
* FOR A REALLY GOOD INFO ON THE TASK STRUCTURE SEE (MAPPING THE AMIGA (COMPUTE)
* COMPLETE A 500 PLUS COMPATIBLE AS IT WAS CODED ON ONE (BRILLENT MACHINE)
* DESPRATELY WANTED KICKSTART 2 DOCUMENTS AND V2.0 INCLUDE FILES
* THIS CODE IS UNIQUE IN THE SENSE IVE NEVER SEEN ANY CODE ON INSTALLING TASKS
* ON ANY SOURCE CODE DISKS IVE BEEN SENT OR IN MAGAZINES IVE READ, APART FROM
* CRAPPY C LISTINGS THAT I DONT UNDERSTAND (THE MAIN REASON FOR WRITING THIS)
*******************************************************************************
	   OPT C-			*THE USUAL STUFF 
 	   INCDIR  source:INCLUDE/		
	   INCLUDE "liboffsets.i"  *MY SPECIAL INCLUDE FILE
*******************************************************************************
*USUAL EQAUTES FOR TASK STRUCTURE AND STACK SIZE ECT
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
* THE FOLLOWING CODE INITIALISES THE TASK NODE STRUCTURE AND SETS UP A STACK
********************************************************************************
	  MOVE.L D0,A1			*MOVE THE RESERVED MEMORY TO A1
	  ADD.L  #TASKSTRCSIZE,D0 	*ADD THE TASK STACK SIZE TO D0 
          MOVE.L D0,TC_SPLOWER(A1)	*MIN ADRESS PART OF THE STACK
	  ADD.L  #1024,D0		*ADD 1000 TO D0 = NEARLY 1K STACK
	  MOVE.L D0,TASKPRGST		*ADD THE START OF THE ACTUAL TASK TO D0
	  MOVE.L D0,TC_SPUPPER(A1)      *MAX ADRESS PART OF THE STACK
	  MOVE.L D0,TC_SPREG(A1)	*STACK POINTER START (DECENDING STACK)
          MOVE.L #TASKNAME,LN_NAME(A1)  *NAME OF TASK (MAKES DEBUGGING EASIER)
          MOVE.B #NT_TASK,LN_TYPE(A1)   *NODE TYPE = TASK NODE     
          MOVE.B #0,LN_PRI(A1)	        *TASK PRIORITY = (-127 TO +128) NORM = 0
********************************************************************************
* THIS CODE COPIES THE TASK PROGRAME TO PROTECTED MEMORY (ALLOCATED MEMORY)
********************************************************************************
	  MOVE.L #TASKEND-TASKSTART,D0  *TASK PRG LENGTH IN D0 
	  MOVE.L #TASKSTART,A0		*START OF TASK PRG
	  MOVE.L TASKPRGST,A1		*DESTINATION OF TASK PRG (ALLOCATED MEM)
COPYTASK:	
	  MOVE.B (A0)+,(A1)+		*COPY TASK TO ALLOCATED MEMORY 
	  DBRA	 D0,COPYTASK		*DECREMENT D0 TILL TASK PRG IS COPIED
********************************************************************************
* LIBRARY CALL TO ADD THE TASK TO THE SYSTEM TASKS
********************************************************************************
	  MOVE.L TASKMEM,A1	* START OF THE TASK NODE STRUCTURE = 92 BYTES
          MOVE.L TASKPRGST,A2	* FIRST INSTRUCTION TO EXECUTE ONCE TASK IS ADDED
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
TASKSTART: 
	BCLR	#1,$BFE001
	BSET	#1,$BFE001
	BTST	#7,$BFE001
	BNE	TASKSTART
	BTST    #6,$BFE001
	BNE	TASKSTART
	RTS

TASKNAME:
	DC.B	"TASK V1.1",0	* INCLUDED IN TASK PRG TO SHOW NAME OF 
	EVEN			* TASK ON A MONITOR OR DEBUUGER
TASKEND:    
