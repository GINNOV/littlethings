*******************************************************************************
*ABOUT ROUTINE OUTPUTS TEXT WITH PRG DETAILS ECT TO A WINDOW
*******************************************************************************
ABOUTDOCS:	MOVE.L	INTBASE,A6	*INTUTION LIBS BASE ADRESS
		LEA	DOCSWINDOW,A0	*A0-->WINDOW STRUCTURE
		JSR	OPENWINDOW(A6)  *LIBRARY CALL TO OPEN ABOUT WINDOW
		MOVE.L	D0,DOCSADRESS	*SAVE WINDOW POINTER
		BEQ.S	NODOCSWINDOW	*COULD NOT OPEN WINDOW
		MOVE.L	INTBASE,A6	*INTUTION BASE ADRESS FOR LIBS
		LEA	DOCSTEXT,A1	*A1-->TEXT STRUCTURE
		MOVE.L	DOCSADRESS,A0	*A0-->WINDOW
		MOVE.L	50(A0),A0	*RASPORT ADRESS FOR TEXT
		MOVEQ.L	#0,D0		*X POSITION OF TEXT
		MOVE.L	#0,D1		*Y POSITION OF TEXT
		JSR	PRINTITEXT(A6)	*COPY TEXT INTO WINDOW
WAITLEFTMOUSE:	BTST	#6,CIAPRA	*WAIT FOR LEFT MOUSE BUTTON
		BNE.S	WAITLEFTMOUSE	*WAS IT PRESSED
		MOVE.L	INTBASE,A6	*INTUITION LIBS BASE ADRESS
		MOVE.L	DOCSADRESS,A0	*A0-->WINDOW
		JSR	CLOSEWINDOW(A6)	*CLOSE THIS WINDOW
NODOCSWINDOW:	RTS
*******************************************************************************
DOCSADRESS:	DC.L		0	*STORE FOR THE WINDOW ADRESS
*******************************************************************************
*DEFINITIONS FOR THE SIZE OF THE WINDOW ECT
********************************************************************************
DOCSWINDOW:
X.AND.Y.POSTION:		DC.W		0,10		
WIDTH.AND.HEIGHT:		DC.W		320,246		
PRINT.AND.BACKGROUND.COLORS:	DC.B		0,1		
IDCMP.FLAGS:			DC.L		0		
ACITIVATE.FOR.OTHER.GADGETS:	DC.L		0	OTHER WINDOW FLAGS
GADGETS.:			DC.L		0		
CHECKMARK.:			DC.L		0		
POINTER.TO.WINDOW.NAME:		DC.L		DOCSNAME	
SCREENPOINTER:			DC.L		0	
BITMAP.POINTER:			DC.L		0		
SMALLEST.WIDTH.AND.HIEGHT:	DC.W		5,5	
WINDOW.WIDTH.AND.HIEGHT		DC.W		200,200		
SCREENTYPE.:			DC.W		CUSTOMSCREEN

DOCSNAME	DC.B		"SLIPSTREAM BOOT MENU V1.0 DOCS ",0
		EVEN
*******************************************************************************
*TEXT TO BE OUTPUT STARTING WITH LINE 1
*******************************************************************************
DOCSTEXT	DC.B		2,0,0,0	
		DC.W		4,12		*X/Y POSTION OF TEXT
		DC.L		0		
		DC.L		DABOUTTEXT1	*POINTER TO TEXT TO BE OUTPUT
		DC.L		DABOUT2		*POINTER TO SECOND LINE

DABOUTTEXT1	DC.B "*SLIPSTREAMS MENU BOOT VERSION 1.0 DOC*",0
		EVEN
********************************************************************************
*LINE 2
*******************************************************************************
DABOUT2		DC.B		2,0,0,0		*SAME AS ABOVE
		DC.W		4,20		
		DC.L		0		
		DC.L		DABOUTTEXT2	
		DC.L		DABOUT3		

DABOUTTEXT2	DC.B "        *MENU SELECTION NOTES*        ",0
		EVEN
*******************************************************************************
*LINE 3
*******************************************************************************
DABOUT3		DC.B		1,0,0,0	
		DC.W		4,32		
		DC.L		0		
		DC.L		DABOUTTEXT3	
		DC.L		DABOUT5		

DABOUTTEXT3	DC.B " ",0
		EVEN
*******************************************************************************
*LINE 4
*******************************************************************************
DABOUT5		DC.B		1,0,0,0	
		DC.W		4,40		
		DC.L		0		
		DC.L		DABOUTTEXT5	
		DC.L		DABOUT6		

DABOUTTEXT5	DC.B "ABOUT =INFO AND CHANGES ECT.",0
		EVEN
*******************************************************************************
*LINE 5
*******************************************************************************
DABOUT6		DC.B		1,0,0,0	
		DC.W		4,48	
		DC.L		0		
		DC.L		DABOUTTEXT6	
		DC.L		DABOUT7		

DABOUTTEXT6	DC.B "DOCS  =DETAILS ON INSTALLING BOOT MENUS",0
		EVEN
*******************************************************************************
*LINE 6
*******************************************************************************
DABOUT7		DC.B		1,0,0,0	
		DC.W		4,56		
		DC.L		0		
		DC.L		DABOUTTEXT7	
		DC.L		DABOUT8		

DABOUTTEXT7	DC.B "QUIT  =RETURN TO CLI OR THE WORKBENCH",0
		EVEN
*******************************************************************************
*LINE 7
*******************************************************************************
DABOUT8		DC.B		1,0,0,0	
		DC.W		4,64		
		DC.L		0		
		DC.L		DABOUTTEXT8	
		DC.L		DABOUT9		

DABOUTTEXT8	DC.B "EDIT  =EDIT THE BOOT MENU TEXT F1 TO F0",0
		EVEN
*******************************************************************************
*LINE 8
*******************************************************************************
DABOUT9		DC.B		1,0,0,0	
		DC.W		4,72	
		DC.L		0		
		DC.L		DABOUTTEXT9	
		DC.L		DABOUT10	

DABOUTTEXT9	DC.B "TEST  =SEE THE BOOT DEMONSTRATION",0
		EVEN
********************************************************************************
*LINE 10
*******************************************************************************
DABOUT10	DC.B		1,0,0,0		*SAME AS ABOVE
		DC.W		4,80		
		DC.L		0		
		DC.L		DABOUTTEXT10	
		DC.L		DABOUT11		

DABOUTTEXT10	DC.B "WRITE =WRITE BOOT TO DF0: OR DF1:",0
		EVEN
*******************************************************************************
*LINE 11
*******************************************************************************
DABOUT11	DC.B		1,0,0,0	
		DC.W		4,88		
		DC.L		0		
		DC.L		DABOUTTEXT11
		DC.L		DABOUT12	

DABOUTTEXT11	DC.B "SAVEL =SAVE LOADER TO S DIR *DF0: ONLY*",0
		EVEN
*******************************************************************************
*LINE 12
*******************************************************************************
DABOUT12	DC.B		1,0,0,0	
		DC.W		4,98		
		DC.L		0		
		DC.L		DABOUTTEXT12
		DC.L		DABOUT13	

DABOUTTEXT12	DC.B "",0
		EVEN
*******************************************************************************
*LINE 13
*******************************************************************************
DABOUT13	DC.B		2,0,0,0	
		DC.W		4,106	
		DC.L		0		
		DC.L		DABOUTTEXT13
		DC.L		DABOUT14	

DABOUTTEXT13	DC.B "          *IMPORTANT NOTES*         ",0
		EVEN
*******************************************************************************
*LINE 14
*******************************************************************************
DABOUT14	DC.B		1,0,0,0	
		DC.W		4,114	
		DC.L		0		
		DC.L		DABOUTTEXT14
		DC.L		DABOUT15	

DABOUTTEXT14	DC.B "THE FILE LOADER MUST BE IN THE S DIR",0
		EVEN
*******************************************************************************
*LINE 15
*******************************************************************************
DABOUT15	DC.B		1,0,0,0	
		DC.W		4,122	
		DC.L		0		
		DC.L		DABOUTTEXT15
		DC.L		DABOUT16

DABOUTTEXT15	DC.B "YOUR EXACUTABLE FILES MUST BE CALLED",0
		EVEN
*******************************************************************************
*LINE 16
*******************************************************************************
DABOUT16	DC.B		1,0,0,0	
		DC.W		4,130
		DC.L		0		
		DC.L		DABOUTTEXT16
		DC.L		DABOUT17	

DABOUTTEXT16	DC.B "PRGA TO PRGJ",0
		EVEN
*******************************************************************************
*LINE 17
*******************************************************************************
DABOUT17	DC.B		1,0,0,0	
		DC.W		4,138		*X/Y POSTION OF TEXT
		DC.L		0		
		DC.L		DABOUTTEXT17	*POINTER TO TEXT TO BE OUTPUT
		DC.L		DABOUT18	*POINTER TO SECOND LINE

DABOUTTEXT17	DC.B "",0
		EVEN
********************************************************************************
*LINE 18
*******************************************************************************
DABOUT18	DC.B		1,0,0,0		*SAME AS ABOVE
		DC.W		4,146	
		DC.L		0		
		DC.L		DABOUTTEXT18	
		DC.L		DABOUT19

DABOUTTEXT18	DC.B "IF THE PROGRAME APEARS TO CRASH OR THE",0
		EVEN
*******************************************************************************
*LINE 19
*******************************************************************************
DABOUT19	DC.B		1,0,0,0	
		DC.W		4,154	
		DC.L		0		
		DC.L		DABOUTTEXT19	
		DC.L		DABOUT20

DABOUTTEXT19	DC.B "MENUS FAIL THEN CLICK THE MOUSE POINTER",0
		EVEN
*******************************************************************************
*LINE 20
*******************************************************************************
DABOUT20	DC.B		1,0,0,0	
		DC.W		4,162	
		DC.L		0		
		DC.L		DABOUTTEXT20	
		DC.L		DABOUT22

DABOUTTEXT20	DC.B "IN THE TOP LEFT OF THE SCREEN",0
		EVEN
*******************************************************************************
*LINE 21
*******************************************************************************
DABOUT22	DC.B		1,0,0,0	
		DC.W		4,170
		DC.L		0		
		DC.L		DABOUTTEXT22	
		DC.L		DABOUT23

DABOUTTEXT22	DC.B "PRESSING THE LEFT MOUSE BUTTON IN THE BOOT",0
		EVEN
*******************************************************************************
*LINE 23
*******************************************************************************
DABOUT23	DC.B		1,0,0,0	
		DC.W		4,178	
		DC.L		0		
		DC.L		DABOUTTEXT23	
		DC.L		DABOUT24

DABOUTTEXT23	DC.B "           ",0
		EVEN
*******************************************************************************
*LINE 24
*******************************************************************************
DABOUT24	DC.B		2,0,0,0	
		DC.W		4,186	
		DC.L		0		
		DC.L		DABOUTTEXT24
		DC.L		DABOUT25

DABOUTTEXT24	DC.B "WILL EXECUTE A NORMAL WB BOOT NO PRG ",0
		EVEN
*******************************************************************************
*LINE 25
*******************************************************************************
DABOUT25	DC.B		1,0,0,0	
		DC.W		4,194
		DC.L		0		
		DC.L		DABOUTTEXT25	
		DC.L		DABOUT26

DABOUTTEXT25	DC.B "            ",0
		EVEN
********************************************************************************
*LINE 26
*******************************************************************************
DABOUT26	DC.B		2,0,0,0		*SAME AS ABOVE
		DC.W		4,202	
		DC.L		0		
		DC.L		DABOUTTEXT26	
		DC.L		DABOUT27

DABOUTTEXT26	DC.B "              ",0
		EVEN
*******************************************************************************
*LINE 27
*******************************************************************************
DABOUT27	DC.B		1,0,0,0	
		DC.W		4,210	
		DC.L		0		
		DC.L		DABOUTTEXT27
		DC.L		DABOUT28

DABOUTTEXT27	DC.B "               ",0
		EVEN
*******************************************************************************
*LINE 28
*******************************************************************************
DABOUT28	DC.B		1,0,0,0	
		DC.W		4,218	
		DC.L		0		
		DC.L		DABOUTTEXT28
		DC.L		DABOUT29

DABOUTTEXT28	DC.B "                    ",0
		EVEN
*******************************************************************************
*LINE 29
*******************************************************************************
DABOUT29	DC.B		1,0,0,0	
		DC.W		4,226	
		DC.L		0		
		DC.L		DABOUTTEXT29
		DC.L		DABOUT30

DABOUTTEXT29	DC.B "           ",0
		EVEN
*******************************************************************************
*LINE 30
*******************************************************************************
DABOUT30	DC.B		3,0,0,0	
		DC.W		4,234	
		DC.L		0		
		DC.L		DABOUTTEXT30
		DC.L		0

DABOUTTEXT30	DC.B "  YET ANOTHER NO.1 SLIPSTREAM UTILITY",0
		EVEN
*******************************************************************************
