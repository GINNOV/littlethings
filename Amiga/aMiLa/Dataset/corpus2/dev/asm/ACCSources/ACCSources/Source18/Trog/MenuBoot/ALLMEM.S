*******************************************************************************
*MEMORY ALLOCATION ROUTINE FOR THE BOOT BUFFER
*******************************************************************************
ALLOCATEMEM:
	MOVE.L  $4,A6		* ABSOLOTE EXECBASE ADRESS
	MOVE.L 	#BOOT,D0	* NUMBER OF BYTES TO RESERVE
	MOVE.L	#MEMF_CHIP,D1	* TYPE OF RAM FAST
	JSR	ALLOCMEM(A6)	* EXEC LIBRARY CALL
	MOVE.L  D0,BOOTDATA	* START ADRESS OF RESERVED MEMORY
	BEQ	CLOSELIB	* IF FALIES CLOSE PROG
	RTS
CLOSELIB:
	JSR	CLOSELIBRARYS
	RTS
*******************************************************************************
DEALLOCATEMEM:
	MOVE.L	$4,A6		* RETURN MEMORY BACK TO THE SYSTEM POOL
	MOVE.L  #BOOT,D0	* NUMBER OF BYTES TO RETERN
	MOVE.L  BOOTDATA,A1	* START OF RESERVED MEMORY
	JSR	FREEMEM(A6)	* EXEC LIBRARY CALL TO FREE MEM
	RTS

*******************************************************************************
*POINTERS AND MEMORY REQUIRED ROUTINE VARIBLES
*******************************************************************************
BOOT      EQU   $400	* MEMORY TO RESERVE = 1024 BYTES (1 K)
MEMF_CHIP EQU   $2 	* TYPE OF MEMORY = CHIP RAM (4 = FAST)
BOOTDATA: DC.L 0	* START LOCATION OF MEMORY
*******************************************************************************
