*******************************************************************************
*SET UP MENU
********************************************************************************
OPENMENU:
	MOVE.L	INTBASE,A6		* BASE ADRESS OF INTUITION.LIBRARY
	MOVE.L	WINDOWADRESS,A0		* WINDOW SCREEN ADRESS
	LEA	MENU1,A1		* MENU DATA START ADRESS
	JSR	SETMENUSTRIP(A6)	* LIBRARY CALL TO INSTALL
	RTS				* MENU

CLOSEMENU:
	MOVE.L	INTBASE,A6		* SAME AS ABOVE
	MOVE.L	WINDOWADRESS,A0		* SAME AS ABOVE
	JSR	CLOSEMENUSTRIP(A6)	* LIBRARY CALL TO CLOSE WINDOW
	RTS

*******************************************************************************
*MENU DATA
*NUMBER OF MENUS 2 ,3 ENTRYS EACH WITH 2ND MENU ENTRY 3 WITN 2 SUB ENTRYS
*******************************************************************************
MENU1:
	DC.L	MENU2		*NEXT MENU NUMBER
	DC.W	2,30    	*MENU X/Y CORDINATES
	DC.W	50,10		*WIDTH AND HIEGHT
	DC.W	1		*1=MENU ENABLED 0=MENU DISABLED
	DC.L	MENUNAME1	*MENU TITLE
	DC.L	MENUITEM1	*POINTER TO NEXT MENU ITEM
	DC.W	0,0,0,0		*INTERNAL SYSTEM FUNCTIONS
MENUNAME1:
	DC.B	"INF0",0
	EVEN
*******************************************************************************
MENU2:	DC.L	0		*SAME AS ABOVE
	DC.W	55,30
	DC.W	50,10
	DC.W	1
	DC.L	MENUNAME2
	DC.L	MENU2ITEM1
	DC.W	0,0,0,0
MENUNAME2:
	DC.B	"M.B V1",0
	EVEN
*******************************************************************************
*MENU ITEM DATA
*******************************************************************************
MENUITEM1:
	DC.L	MENUITEM2	*POINTER TO NEXT MENU ITEM
	DC.W	0,0		*X/Y POSTION OF THE MENU ITEMS
	DC.W	60,15		*WIDTH AND HIEGHT OF MENU ITEM
	DC.W	$52		*FLAGS
	DC.L	0		*EXCLUDE
	DC.L	MENU1TEXT1	*POINTER TO TEXT STRUCTURE
	DC.L	0		*MENU SELECT 0=FILL 1=BORDER
	DC.B	"0"		*COMMAND
	EVEN
	DC.L	0		*NO SUB ITEMS
	DC.W	0		*NEXT SELECT NONE
MENU1TEXT1:
	DC.B	0,1		*COLOURS
	DC.B	0		*MODE OVERWRITE
	EVEN
	DC.W	5,3		*X/Y POSTION
	DC.L	0		*STANDARD CHARACTER SET
	DC.L	TEXTMENU1	*POINTER TO TEXT
	DC.L	0		*NO MORE TEXT
TEXTMENU1:
	DC.B	"ABOUT",0
	EVEN
*******************************************************************************
MENUITEM2:
	DC.L	MENUITEM3	*SAME AS ABOVE
	DC.W	0,15
	DC.W	60,15
	DC.W	$52
	DC.L	0
	DC.L	MENU1TEXT2
	DC.L	0
	DC.B	"0"
	EVEN
	DC.L	0
	DC.W	0
MENU1TEXT2:
	DC.B	0,1
	DC.B	0
	EVEN
	DC.W	5,3
	DC.L	0
	DC.L	TEXTMENU2
	DC.L	0
TEXTMENU2:
	DC.B	"SLOADER",0
	EVEN
*******************************************************************************
MENUITEM3:
	DC.L	0	*SAME AS ABOVE
	DC.W	0,30
	DC.W	60,15
	DC.W	$52
	DC.L	0
	DC.L	MENU1TEXT3
	DC.L	0
	DC.B	"0"
	EVEN
	DC.L	0
	DC.W	0
MENU1TEXT3
	DC.B	0,1
	DC.B	0
	EVEN
	DC.W	5,3
	DC.L	0
	DC.L	TEXTMENU3
	DC.L	0
TEXTMENU3:
	DC.B	"QUIT",0
	EVEN
*******************************************************************************
*NEXTMENU 2
*******************************************************************************
MENU2ITEM1:
	DC.L	MENU2ITEM2	*SAME AS ABOVE
	DC.W	0,0
	DC.W	80,15
	DC.W	$52
	DC.L	0
	DC.L	MENU2TEXT1
	DC.L	0
	DC.B	"0"
	EVEN
	DC.L	0
	DC.W	0
MENU2TEXT1:
	DC.B	0,1
	DC.B	0
	EVEN
	DC.W	5,3
	DC.L	0
	DC.L	TEXT2MENU1
	DC.L	0
TEXT2MENU1:
	DC.B	"EDIT TEXT",0
	EVEN
*******************************************************************************
MENU2ITEM2:
	DC.L	MENU2ITEM3	*SAME AS ABOVE
	DC.W	0,15
	DC.W	80,15
	DC.W	$52
	DC.L	0
	DC.L	MENU2TEXT2
	DC.L	0
	DC.B	"0"
	EVEN
	DC.L	0
	DC.W	0
MENU2TEXT2:
	DC.B	0,1
	DC.B	0
	EVEN
	DC.W	5,3
	DC.L	0
	DC.L	TEXT2MENU2
	DC.L	0
TEXT2MENU2:
	DC.B	"TEST BOOT",0
	EVEN
*******************************************************************************
MENU2ITEM3:
	DC.L	0		*SAME AS ABOVE
	DC.W	0,30
	DC.W	80,15
	DC.W	$52
	DC.L	0
	DC.L	MENU2TEXT3
	DC.L	0
	DC.B	"0"
	EVEN
	DC.L	SUBMENU1ITEM1
	DC.W	0
MENU2TEXT3:
	DC.B	0,1
	DC.B	0
	EVEN
	DC.W	5,3
	DC.L	0
	DC.L	TEXT2MENU3
	DC.L	0
TEXT2MENU3:
	DC.B	"WRITE BOOT",0
	EVEN
*******************************************************************************
*SUBMENU START
*******************************************************************************
SUBMENU1ITEM1:
	DC.L	SUB1ITEM2	*SAME AS ABOVE
	DC.W	0,0
	DC.W	90,15
	DC.W	$52
	DC.L	0
	DC.L	SUBMENU1TEXT1
	DC.L	0
	DC.B	"0"
	EVEN
	DC.L	0
	DC.W	0
SUBMENU1TEXT1:
	DC.B	0,1
	DC.B	0
	EVEN
	DC.W	5,3
	DC.L	0
	DC.L	SUBTEXT1MENU1
	DC.L	0
SUBTEXT1MENU1:
	DC.B	"WRITE DF0:",0
	EVEN
*******************************************************************************
SUB1ITEM2:
	DC.L	0
	DC.W	0,15
	DC.W	90,15
	DC.W	$66
	DC.L	0
	DC.L	SUBMENU2TEXT2
	DC.L	0
	DC.B	"0"
	EVEN
	DC.L	0
	DC.W	0
SUBMENU2TEXT2:
	DC.B	0,1
	DC.B	0
	EVEN
	DC.W	5,3
	DC.L	0
	DC.L	SUBTEXT2MENU2
	DC.L	0
SUBTEXT2MENU2:
	DC.B	"WRITE DF1:",0
	EVEN
*******************************************************************************
