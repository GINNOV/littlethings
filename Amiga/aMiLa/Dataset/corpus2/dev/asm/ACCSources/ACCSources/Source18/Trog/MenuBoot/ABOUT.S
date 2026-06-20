*******************************************************************************
*REQUESTER TO QUIT PROGRAM OR NOT
*******************************************************************************
ABOUTTEXT:
	MOVE.L	INTBASE,A6	*INTUTION BASE ADRESS IN A6
	MOVE.L	#0,D0		*CLEAR CHECK REGISTERS (D0, D1)
	MOVE.L	#0,D1		*SAME AS ABOVE
	MOVE.L	#320,D2		*REQUESTER WIDTH
	MOVE.L	#246,D3		*REQUESTER HEIGHT
	MOVE.L	WINDOWADRESS,A0	*ATTACH REQUESTER TO THIS WINDOW
	LEA	ATEXT,A1	*POINTER TO MAIN REQUESTER TEXT
	LEA	ALTEXT,A2	*TEXT DISPLAYED ON LEFT
	LEA	ARTEXT,A3	*TEXT DISPLAYED ON RIGHT
	JSR	AUTOREQUEST(A6)	*OPEN UP REQUESTER
	RTS
*******************************************************************************	
*TEXT FOR THE REQUESTER AS WELL AS COLOR AND POSTION
*******************************************************************************
*POINTERS AND TEXT DETAILS
*******************************************************************************
ATEXT	DC.B	0,1			*TEXT COLOR, BACKGROUND COLOR
	DC.B	0			*OUTPUT MODE 0=NORMAL 4=INVERTED
	EVEN		
	DC.W	0,10			*X AND Y POSTION OF TEXT
	DC.L	0			*FONT SET DETAILS 0=NORMAL
	DC.L	ABODYTXT		*POINTER TO TEXT TO OUTPUT
	DC.L	ABOUT2			*POINTER TO MORE TEXT 0=NO MORE TEXT
ABODYTXT DC.B	"  PIROSOFT  MENU BOOT VERSION 1.0   ",0 *OUTPUT TEXT	
	
	EVEN

ALTEXT	DC.B	0,1			*TEXT COLOR, BACKGROUND COLOR
	DC.B	0			*OUTPUT MODE 0=NORMAL 4=INVERTED
	EVEN		
	DC.W	5,3			*TEXT POSTION
	DC.L	0			*NORMAL FONT
	DC.L	ALEFTTXT		*POINTER TO TEXT TO BE OUTPUT
	DC.L	0			*NO MORE TEXT
ALEFTTXT DC.B	"CLICK HERE",0	*TEXT TO BE OUTPUT TO REQUESTER
	
	EVEN
	
ARTEXT	DC.B	0,1			*TEXT COLOR, BACKGROUND COLOR
	DC.B	0			*OUTPUT MODE 
	EVEN
	DC.W	5,3			*TEXT POSTION
	DC.L	0			*NO MORE TEXT
	DC.L	ARIGHTTX		*POINTER TO TEXT TO BE OUTPUT
	DC.L	0			*NO MORE TEXT 0=NO MORE TEXT
ARIGHTTX DC.B	"CLICK HERE",0	*TEXT TO BE OUTPUT TO REQUESTER
	
	EVEN
*******************************************************************************
ABOUT2		DC.B		2,0,0,0		*FOREGROUND AND BACKGROUND COLS
		DC.W		4,20		*TEXT POSTION
		DC.L		0		*POINTER TO FONT
		DC.L		ABOUTTEXT2	*POINTER TO TEXT TO OUTPUT
		DC.L		ABOUT3		*POINTER TO NEXT OUTPUT TEXT

ABOUTTEXT2	DC.B "      ",0			*OUTPUT TEXT
		EVEN
*******************************************************************************
*LINE 3
*******************************************************************************
ABOUT3		DC.B		1,0,0,0	        *THE FOLLOWING ARE ALL THE
		DC.W		4,32		*SAME AS THE ABOVE APART FROM
		DC.L		0		*TEXT POSTION AND TEXT CONTENTS
		DC.L		ABOUTTEXT3	
		DC.L		ABOUT5		

ABOUTTEXT3	DC.B " ",0
		EVEN
*******************************************************************************
*LINE 4
*******************************************************************************
ABOUT5		DC.B		2,0,0,0	
		DC.W		4,40		
		DC.L		0			    *
		DC.L		ABOUTTEXT5	
		DC.L		ABOUT6		

ABOUTTEXT5	DC.B "  ALL CODE AND GRAPHICS BY THE TROG   ",0
		EVEN
*******************************************************************************
*LINE 5
*******************************************************************************
ABOUT6		DC.B		2,0,0,0	
		DC.W		4,48	
		DC.L		0		
		DC.L		ABOUTTEXT6	
		DC.L		ABOUT7		

ABOUTTEXT6	DC.B "FINAL RELEASE VERSION 1.0 ON 23/7/91  ",0
		EVEN
*******************************************************************************
*LINE 6
*******************************************************************************
ABOUT7		DC.B		2,0,0,0	
		DC.W		4,56		
		DC.L		0		
		DC.L		ABOUTTEXT7	
		DC.L		ABOUT8		

ABOUTTEXT7	DC.B "   COPYRIGHT 1991 BY THE PIROSOFT      ",0
		EVEN
*******************************************************************************
*LINE 7
*******************************************************************************
ABOUT8		DC.B		2,0,0,0	
		DC.W		4,64		
		DC.L		0		
		DC.L		ABOUTTEXT8	
		DC.L		ABOUT9		

ABOUTTEXT8	DC.B "",0
		EVEN
*******************************************************************************
*LINE 8
*******************************************************************************
ABOUT9		DC.B		2,0,0,0	
		DC.W		4,72	
		DC.L		0		
		DC.L		ABOUTTEXT9	
		DC.L		ABOUT10	

ABOUTTEXT9	DC.B "     IMPORTANT COPYRIGHT NOTICE       ",0
		EVEN
********************************************************************************
*LINE 10
*******************************************************************************
ABOUT10		DC.B		2,0,0,0		*SAME AS ABOVE
		DC.W		4,80		
		DC.L		0		
		DC.L		ABOUTTEXT10	
		DC.L		ABOUT11		

ABOUTTEXT10	DC.B " THIS PRODUCT IS FREEWARE NO PAYMENT",0
		EVEN
*******************************************************************************
*LINE 11
*******************************************************************************
ABOUT11		DC.B		2,0,0,0	
		DC.W		4,88		
		DC.L		0		
		DC.L		ABOUTTEXT11
		DC.L		ABOUT12	

ABOUTTEXT11	DC.B "   SHOULD BE MADE FOR IT IN ANY WAY   ",0
		EVEN
*******************************************************************************
*LINE 12
*******************************************************************************
ABOUT12		DC.B		2,0,0,0	
		DC.W		4,98		
		DC.L		0		
		DC.L		ABOUTTEXT12
		DC.L		ABOUT13	

ABOUTTEXT12	DC.B "",0
		EVEN
*******************************************************************************
*LINE 13
*******************************************************************************
ABOUT13		DC.B		2,0,0,0	
		DC.W		4,106	
		DC.L		0		
		DC.L		ABOUTTEXT13
		DC.L		ABOUT14	

ABOUTTEXT13	DC.B "",0
		EVEN
*******************************************************************************
*LINE 14
*******************************************************************************
ABOUT14		DC.B		2,0,0,0	
		DC.W		4,114	
		DC.L		0		
		DC.L		ABOUTTEXT14
		DC.L		ABOUT15	

ABOUTTEXT14	DC.B "    IMPORTANT DISCLAIMER FOLLOWS",0
		EVEN
*******************************************************************************
*LINE 15
*******************************************************************************
ABOUT15		DC.B		2,0,0,0	
		DC.W		4,122	
		DC.L		0		
		DC.L		ABOUTTEXT15
		DC.L		ABOUT16

ABOUTTEXT15	DC.B "   WE TROG AND PIROSOFT  EXCEPT NO",0
		EVEN
*******************************************************************************
*LINE 16
*******************************************************************************
ABOUT16		DC.B		2,0,0,0	
		DC.W		4,130
		DC.L		0		
		DC.L		ABOUTTEXT16
		DC.L		ABOUT17	

ABOUTTEXT16	DC.B " RESPONSABILITY FOR THIS PRODUCT IN",0
		EVEN
*******************************************************************************
*LINE 17
*******************************************************************************
ABOUT17		DC.B		2,0,0,0	
		DC.W		4,138		*X/Y POSTION OF TEXT
		DC.L		0		
		DC.L		ABOUTTEXT17	*POINTER TO TEXT TO BE OUTPUT
		DC.L		ABOUT18	*POINTER TO SECOND LINE

ABOUTTEXT17	DC.B "  ANYWAY WHAT SO EVER FOR ANY DAMAGE",0
		EVEN
********************************************************************************
*LINE 18
*******************************************************************************
ABOUT18		DC.B		2,0,0,0		*SAME AS ABOVE
		DC.W		4,146	
		DC.L		0		
		DC.L		ABOUTTEXT18	
		DC.L		ABOUT19

ABOUTTEXT18	DC.B "CAUSED BY THIS PRODUCT TO THE USER'S",0
		EVEN
*******************************************************************************
*LINE 19
*******************************************************************************
ABOUT19		DC.B		2,0,0,0	
		DC.W		4,154	
		DC.L		0		
		DC.L		ABOUTTEXT19	
		DC.L		ABOUT20

ABOUTTEXT19	DC.B "        HARDWARE OR SOFTWARE",0
		EVEN
*******************************************************************************
*LINE 20
*******************************************************************************
ABOUT20		DC.B		2,0,0,0	
		DC.W		4,162	
		DC.L		0		
		DC.L		ABOUTTEXT20	
		DC.L		ABOUT22

ABOUTTEXT20	DC.B "",0
		EVEN
*******************************************************************************
*LINE 21
*******************************************************************************
ABOUT22		DC.B		2,0,0,0	
		DC.W		4,170
		DC.L		0		
		DC.L		ABOUTTEXT22	
		DC.L		ABOUT23

ABOUTTEXT22	DC.B "!!!!!!!!!!!!!!GREETINGS!!!!!!!!!!!!!!",0
		EVEN
*******************************************************************************
*LINE 23
*******************************************************************************
ABOUT23		DC.B		2,0,0,0	
		DC.W		4,178	
		DC.L		0		
		DC.L		ABOUTTEXT23	
		DC.L		ABOUT24

ABOUTTEXT23	DC.B "!!!!!!!!TO ALL OF OUR FRIENDS!!!!!!!!",0
		EVEN
*******************************************************************************
*LINE 24
*******************************************************************************
ABOUT24		DC.B		2,0,0,0	
		DC.W		4,186	
		DC.L		0		
		DC.L		ABOUTTEXT24
		DC.L		ABOUT25

ABOUTTEXT24	DC.B "!!!!!!!!!!!!!!WORLDWIDE!!!!!!!!!!!!!!",0
		EVEN
*******************************************************************************
*LINE 25
*******************************************************************************
ABOUT25		DC.B		2,0,0,0	
		DC.W		4,198
		DC.L		0		
		DC.L		ABOUTTEXT25
		DC.L		0

ABOUTTEXT25	DC.B "   YET ANOTHER NO.1 FROM TROG ",0
		EVEN
********************************************************************************
*LINE 26
*******************************************************************************
ABOUT26		DC.B		2,0,0,0		*SAME AS ABOVE
		DC.W		4,298	
		DC.L		0		
		DC.L		ABOUTTEXT26	
		DC.L		ABOUT27

ABOUTTEXT26	DC.B "   YET ANOTHER N0.1 FROM PIROSOFT ",0
		EVEN
*******************************************************************************
*LINE 27
*******************************************************************************
ABOUT27		DC.B		2,0,0,0	
		DC.W		4,210	
		DC.L		0		
		DC.L		ABOUTTEXT27
		DC.L		ABOUT28

ABOUTTEXT27	DC.B "  ",0
		EVEN
*******************************************************************************
*LINE 28
*******************************************************************************
ABOUT28		DC.B		1,0,0,0	
		DC.W		4,218	
		DC.L		0		
		DC.L		ABOUTTEXT28
		DC.L		ABOUT29

ABOUTTEXT28	DC.B "                    ",0
		EVEN
*******************************************************************************
*LINE 29
*******************************************************************************
ABOUT29		DC.B		1,0,0,0	
		DC.W		4,226	
		DC.L		0		
		DC.L		ABOUTTEXT29
		DC.L		ABOUT30

ABOUTTEXT29	DC.B "           ",0
		EVEN
*******************************************************************************
*LINE 30
*******************************************************************************
ABOUT30		DC.B		3,0,0,0	
		DC.W		4,234	
		DC.L		0		
		DC.L		ABOUTTEXT30
		DC.L		0

ABOUTTEXT30	DC.B "  YET ANOTHER NO.1 PIROSOFT  UTILITY",0
		EVEN
*******************************************************************************
