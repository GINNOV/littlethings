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
*NUMBER OF MENUS 5 NUMBER OF ENTRYS PER MENU 10 THE LAST MENU HAS 5 SUB MENUS
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
	DC.B	"MENU 1",0
	EVEN
*******************************************************************************
MENU2:	DC.L	MENU3	*SAME AS ABOVE
	DC.W	55,30
	DC.W	50,10
	DC.W	1
	DC.L	MENUNAME2
	DC.L	MENU2ITEM1
	DC.W	0,0,0,0
MENUNAME2:
	DC.B	"MENU 2",0
	EVEN
*******************************************************************************
MENU3:	DC.L	MENU4	*SAME AS ABOVE
	DC.W	110,30
	DC.W	50,10
	DC.W	1
	DC.L	MENUNAME3
	DC.L	MENU3ITEM1
	DC.W	0,0,0,0
MENUNAME3:
	DC.B	"MENU 3",0
	EVEN
*******************************************************************************
MENU4:	DC.L	MENU5		*SAME AS ABOVE
	DC.W	165,30
	DC.W	50,10
	DC.W	1
	DC.L	MENUNAME4
	DC.L	MENU4ITEM1
	DC.W	0,0,0,0
MENUNAME4:
	DC.B	"MENU 4",0
	EVEN
*******************************************************************************
MENU5:	DC.L	0		* SAME AS ABOVE BUT NO MORE POINTERS TO MENUS
	DC.W	220,30
	DC.W	50,10
	DC.W	1
	DC.L	MENUNAME5
	DC.L	MENU5ITEM1
	DC.W	0,0,0,0
MENUNAME5:
	DC.B	"MENU 5",0
	EVEN
*******************************************************************************
*MENU ITEM DATA
*******************************************************************************
MENUITEM1:
	DC.L	MENUITEM2	*POINTER TO NEXT MENU ITEM
	DC.W	0,0		*X/Y POSTION OF THE MENU ITEMS
	DC.W	120,15		*WIDTH AND HIEGHT OF MENU ITEM
	DC.W	$9f		*FLAGS
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
	DC.B	" TEST 1",0
	EVEN
*******************************************************************************
MENUITEM2:
	DC.L	MENUITEM3	*SAME AS ABOVE
	DC.W	0,10
	DC.W	120,15
	DC.W	$9f
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
	DC.L	TEXTMENU2
	DC.L	0
TEXTMENU2:
	DC.B	" TEST 2",0
	EVEN
*******************************************************************************
MENUITEM3:
	DC.L	MENUITEM4	*SAME AS ABOVE
	DC.W	0,20
	DC.W	120,15
	DC.W	$9f
	DC.L	0
	DC.L	MENU3TEXT3
	DC.L	0
	DC.B	"0"
	EVEN
	DC.L	0
	DC.W	0
MENU3TEXT3
	DC.B	0,1
	DC.B	0
	EVEN
	DC.W	5,3
	DC.L	0
	DC.L	TEXTMENU3
	DC.L	0
TEXTMENU3:
	DC.B	" TEST 3",0
	EVEN
*******************************************************************************
MENUITEM4:
	DC.L	MENUITEM5	*SAME AS ABOVE
	DC.W	0,30
	DC.W	120,15
	DC.W	$9f
	DC.L	0
	DC.L	MENUTEXT4
	DC.L	0
	DC.B	"0"
	EVEN
	DC.L	0
	DC.W	0
MENUTEXT4
	DC.B	0,1
	DC.B	0
	EVEN
	DC.W	5,3
	DC.L	0
	DC.L	TEXTMENU4
	DC.L	0
TEXTMENU4:
	DC.B	" TEST 4",0
	EVEN
*******************************************************************************
MENUITEM5:
	DC.L	MENUITEM6	*SAME AS ABOVE
	DC.W	0,40
	DC.W	120,15
	DC.W	$9f
	DC.L	0
	DC.L	MENUTEXT5
	DC.L	0
	DC.B	"0"
	EVEN
	DC.L	0
	DC.W	0
MENUTEXT5:
	DC.B	0,1
	DC.B	0
	EVEN
	DC.W	5,3
	DC.L	0
	DC.L	TEXTMENU5
	DC.L	0
TEXTMENU5:
	DC.B	" TEST 5",0
	EVEN
*******************************************************************************
MENUITEM6:
	DC.L	MENUITEM7	*SAME AS ABOVE
	DC.W	0,50
	DC.W	120,15
	DC.W	$9f
	DC.L	0
	DC.L	MENUTEXT6
	DC.L	0
	DC.B	"0"
	EVEN
	DC.L	0
	DC.W	0
MENUTEXT6:
	DC.B	0,1
	DC.B	0
	EVEN
	DC.W	5,3
	DC.L	0
	DC.L	TEXTMENU6
	DC.L	0
TEXTMENU6:
	DC.B	" TEST 6",0
	EVEN
*******************************************************************************
MENUITEM7:
	DC.L	MENUITEM8	*SAME AS ABOVE
	DC.W	0,60
	DC.W	120,15
	DC.W	$9f
	DC.L	0
	DC.L	MENUTEXT7
	DC.L	0
	DC.B	"0"
	EVEN
	DC.L	0
	DC.W	0
MENUTEXT7:
	DC.B	0,1
	DC.B	0
	EVEN
	DC.W	5,3
	DC.L	0
	DC.L	TEXTMENU7
	DC.L	0
TEXTMENU7:
	DC.B	" TEST 7",0
	EVEN
*******************************************************************************
MENUITEM8:
	DC.L	MENUITEM9	*SAME AS ABOVE
	DC.W	0,70
	DC.W	120,15
	DC.W	$9f
	DC.L	0
	DC.L	MENUTEXT8
	DC.L	0
	DC.B	"0"
	EVEN
	DC.L	0
	DC.W	0
MENUTEXT8:
	DC.B	0,1
	DC.B	0
	EVEN
	DC.W	5,3
	DC.L	0
	DC.L	TEXTMENU8
	DC.L	0
TEXTMENU8:
	DC.B	" TEST 8",0
	EVEN
*******************************************************************************
MENUITEM9:
	DC.L	MENUITEM10	*SAME AS ABOVE
	DC.W	0,80
	DC.W	120,15
	DC.W	$9f
	DC.L	0
	DC.L	MENUTEXT9
	DC.L	0
	DC.B	"0"
	EVEN
	DC.L	0
	DC.W	0
MENUTEXT9:
	DC.B	0,1
	DC.B	0
	EVEN
	DC.W	5,3
	DC.L	0
	DC.L	TEXTMENU9
	DC.L	0
TEXTMENU9:
	DC.B	" TEST 9",0
	EVEN
*******************************************************************************
MENUITEM10:
	DC.L	0
	DC.W	0,90
	DC.W	120,15
	DC.W	$9f
	DC.L	0
	DC.L	MENUTEXT10
	DC.L	0
	DC.B	"0"
	EVEN
	DC.L	0
	DC.W	0
MENUTEXT10:
	DC.B	0,1
	DC.B	0
	EVEN
	DC.W	5,3
	DC.L	0
	DC.L	TEXTMENU10
	DC.L	0
TEXTMENU10:
	DC.B	" TEST 10",0
	EVEN
*******************************************************************************
MENU2ITEM1:
	DC.L	MENU2ITEM2	*POINTER TO NEXT MENU ITEM
	DC.W	0,0		*X/Y POSTION OF THE MENU ITEMS
	DC.W	120,15		*WIDTH AND HIEGHT OF MENU ITEM
	DC.W	$9f		*FLAGS
	DC.L	0		*EXCLUDE
	DC.L	MENU21TEXT1	*POINTER TO TEXT STRUCTURE
	DC.L	0		*MENU SELECT 0=FILL 1=BORDER
	DC.B	"0"		*COMMAND
	EVEN
	DC.L	0		*NO SUB ITEMS
	DC.W	0		*NEXT SELECT NONE
MENU21TEXT1:
	DC.B	0,1		*COLOURS
	DC.B	0		*MODE OVERWRITE
	EVEN
	DC.W	5,3		*X/Y POSTION
	DC.L	0		*STANDARD CHARACTER SET
	DC.L	TEXT2MENU1	*POINTER TO TEXT
	DC.L	0		*NO MORE TEXT
TEXT2MENU1:
	DC.B	" TEST 1",0
	EVEN
*******************************************************************************
MENU2ITEM2:
	DC.L	MENU2ITEM3	*SAME AS ABOVE
	DC.W	0,10
	DC.W	120,15
	DC.W	$9f
	DC.L	0
	DC.L	MENU22TEXT2
	DC.L	0
	DC.B	"0"
	EVEN
	DC.L	0
	DC.W	0
MENU22TEXT2:
	DC.B	0,1
	DC.B	0
	EVEN
	DC.W	5,3
	DC.L	0
	DC.L	TEXT2MENU2
	DC.L	0
TEXT2MENU2:
	DC.B	" TEST 2",0
	EVEN
*******************************************************************************
MENU2ITEM3:
	DC.L	MENU2ITEM4	*SAME AS ABOVE
	DC.W	0,20
	DC.W	120,15
	DC.W	$9f
	DC.L	0
	DC.L	MENU23TEXT3
	DC.L	0
	DC.B	"0"
	EVEN
	DC.L	0
	DC.W	0
MENU23TEXT3
	DC.B	0,1
	DC.B	0
	EVEN
	DC.W	5,3
	DC.L	0
	DC.L	TEXT2MENU3
	DC.L	0
TEXT2MENU3:
	DC.B	" TEST 3",0
	EVEN
*******************************************************************************
MENU2ITEM4:
	DC.L	MENU2ITEM5	*SAME AS ABOVE
	DC.W	0,30
	DC.W	120,15
	DC.W	$9f
	DC.L	0
	DC.L	MENU2TEXT4
	DC.L	0
	DC.B	"0"
	EVEN
	DC.L	0
	DC.W	0
MENU2TEXT4
	DC.B	0,1
	DC.B	0
	EVEN
	DC.W	5,3
	DC.L	0
	DC.L	TEXT2MENU4
	DC.L	0
TEXT2MENU4:
	DC.B	" TEST 4",0
	EVEN
*******************************************************************************
MENU2ITEM5:
	DC.L	MENU2ITEM6	*SAME AS ABOVE
	DC.W	0,40
	DC.W	120,15
	DC.W	$9f
	DC.L	0
	DC.L	MENU2TEXT5
	DC.L	0
	DC.B	"0"
	EVEN
	DC.L	0
	DC.W	0
MENU2TEXT5:
	DC.B	0,1
	DC.B	0
	EVEN
	DC.W	5,3
	DC.L	0
	DC.L	TEXT2MENU5
	DC.L	0
TEXT2MENU5:
	DC.B	" TEST 5",0
	EVEN
*******************************************************************************
MENU2ITEM6:
	DC.L	MENU2ITEM7	*SAME AS ABOVE
	DC.W	0,50
	DC.W	120,15
	DC.W	$9f
	DC.L	0
	DC.L	MENU2TEXT6
	DC.L	0
	DC.B	"0"
	EVEN
	DC.L	0
	DC.W	0
MENU2TEXT6:
	DC.B	0,1
	DC.B	0
	EVEN
	DC.W	5,3
	DC.L	0
	DC.L	TEXT2MENU6
	DC.L	0
TEXT2MENU6:
	DC.B	" TEST 6",0
	EVEN
*******************************************************************************
MENU2ITEM7:
	DC.L	MENU2ITEM8	*SAME AS ABOVE
	DC.W	0,60
	DC.W	120,15
	DC.W	$9f
	DC.L	0
	DC.L	MENU2TEXT7
	DC.L	0
	DC.B	"0"
	EVEN
	DC.L	0
	DC.W	0
MENU2TEXT7:
	DC.B	0,1
	DC.B	0
	EVEN
	DC.W	5,3
	DC.L	0
	DC.L	TEXT2MENU7
	DC.L	0
TEXT2MENU7:
	DC.B	" TEST 7",0
	EVEN
*******************************************************************************
MENU2ITEM8:
	DC.L	MENU2ITEM9	*SAME AS ABOVE
	DC.W	0,70
	DC.W	120,15
	DC.W	$9f
	DC.L	0
	DC.L	MENU2TEXT8
	DC.L	0
	DC.B	"0"
	EVEN
	DC.L	0
	DC.W	0
MENU2TEXT8:
	DC.B	0,1
	DC.B	0
	EVEN
	DC.W	5,3
	DC.L	0
	DC.L	TEXT2MENU8
	DC.L	0
TEXT2MENU8:
	DC.B	" TEST 8",0
	EVEN
*******************************************************************************
MENU2ITEM9:
	DC.L	MENU2ITEM10	*SAME AS ABOVE
	DC.W	0,80
	DC.W	120,15
	DC.W	$9f
	DC.L	0
	DC.L	MENU2TEXT9
	DC.L	0
	DC.B	"0"
	EVEN
	DC.L	0
	DC.W	0
MENU2TEXT9:
	DC.B	0,1
	DC.B	0
	EVEN
	DC.W	5,3
	DC.L	0
	DC.L	TEXT2MENU9
	DC.L	0
TEXT2MENU9:
	DC.B	" TEST 9",0
	EVEN
*******************************************************************************
MENU2ITEM10:
	DC.L	0
	DC.W	0,90
	DC.W	120,15
	DC.W	$9f
	DC.L	0
	DC.L	MENU2TEXT10
	DC.L	0
	DC.B	"0"
	EVEN
	DC.L	0
	DC.W	0
MENU2TEXT10:
	DC.B	0,1
	DC.B	0
	EVEN
	DC.W	5,3
	DC.L	0
	DC.L	TEXT2MENU10
	DC.L	0
TEXT2MENU10:
	DC.B	" TEST 10",0
	EVEN
*******************************************************************************
*******************************************************************************
MENU3ITEM1:
	DC.L	MENU3ITEM2	*POINTER TO NEXT MENU ITEM
	DC.W	0,0		*X/Y POSTION OF THE MENU ITEMS
	DC.W	120,15		*WIDTH AND HIEGHT OF MENU ITEM
	DC.W	$9f		*FLAGS
	DC.L	0		*EXCLUDE
	DC.L	MENU31TEXT1	*POINTER TO TEXT STRUCTURE
	DC.L	0		*MENU SELECT 0=FILL 1=BORDER
	DC.B	"0"		*COMMAND
	EVEN
	DC.L	0		*NO SUB ITEMS
	DC.W	0		*NEXT SELECT NONE
MENU31TEXT1:
	DC.B	0,1		*COLOURS
	DC.B	0		*MODE OVERWRITE
	EVEN
	DC.W	5,3		*X/Y POSTION
	DC.L	0		*STANDARD CHARACTER SET
	DC.L	TEXT3MENU1	*POINTER TO TEXT
	DC.L	0		*NO MORE TEXT
TEXT3MENU1:
	DC.B	" TEST 1",0
	EVEN
*******************************************************************************
MENU3ITEM2:
	DC.L	MENU3ITEM3	*SAME AS ABOVE
	DC.W	0,10
	DC.W	120,15
	DC.W	$9f
	DC.L	0
	DC.L	MENU32TEXT2
	DC.L	0
	DC.B	"0"
	EVEN
	DC.L	0
	DC.W	0
MENU32TEXT2:
	DC.B	0,1
	DC.B	0
	EVEN
	DC.W	5,3
	DC.L	0
	DC.L	TEXT3MENU2
	DC.L	0
TEXT3MENU2:
	DC.B	" TEST 2",0
	EVEN
*******************************************************************************
MENU3ITEM3:
	DC.L	MENU3ITEM4	*SAME AS ABOVE
	DC.W	0,20
	DC.W	120,15
	DC.W	$9f
	DC.L	0
	DC.L	MENU33TEXT3
	DC.L	0
	DC.B	"0"
	EVEN
	DC.L	0
	DC.W	0
MENU33TEXT3
	DC.B	0,1
	DC.B	0
	EVEN
	DC.W	5,3
	DC.L	0
	DC.L	TEXT3MENU3
	DC.L	0
TEXT3MENU3:
	DC.B	" TEST 3",0
	EVEN
*******************************************************************************
MENU3ITEM4:
	DC.L	MENU3ITEM5	*SAME AS ABOVE
	DC.W	0,30
	DC.W	120,15
	DC.W	$9f
	DC.L	0
	DC.L	MENU3TEXT4
	DC.L	0
	DC.B	"0"
	EVEN
	DC.L	0
	DC.W	0
MENU3TEXT4
	DC.B	0,1
	DC.B	0
	EVEN
	DC.W	5,3
	DC.L	0
	DC.L	TEXT3MENU4
	DC.L	0
TEXT3MENU4:
	DC.B	" TEST 4",0
	EVEN
*******************************************************************************
MENU3ITEM5:
	DC.L	MENU3ITEM6	*SAME AS ABOVE
	DC.W	0,40
	DC.W	120,15
	DC.W	$9f
	DC.L	0
	DC.L	MENU3TEXT5
	DC.L	0
	DC.B	"0"
	EVEN
	DC.L	0
	DC.W	0
MENU3TEXT5:
	DC.B	0,1
	DC.B	0
	EVEN
	DC.W	5,3
	DC.L	0
	DC.L	TEXT3MENU5
	DC.L	0
TEXT3MENU5:
	DC.B	" TEST 5",0
	EVEN
*******************************************************************************
MENU3ITEM6:
	DC.L	MENU3ITEM7	*SAME AS ABOVE
	DC.W	0,50
	DC.W	120,15
	DC.W	$9f
	DC.L	0
	DC.L	MENU3TEXT6
	DC.L	0
	DC.B	"0"
	EVEN
	DC.L	0
	DC.W	0
MENU3TEXT6:
	DC.B	0,1
	DC.B	0
	EVEN
	DC.W	5,3
	DC.L	0
	DC.L	TEXT3MENU6
	DC.L	0
TEXT3MENU6:
	DC.B	" TEST 6",0
	EVEN
*******************************************************************************
MENU3ITEM7:
	DC.L	MENU3ITEM8	*SAME AS ABOVE
	DC.W	0,60
	DC.W	120,15
	DC.W	$9f
	DC.L	0
	DC.L	MENU3TEXT7
	DC.L	0
	DC.B	"0"
	EVEN
	DC.L	0
	DC.W	0
MENU3TEXT7:
	DC.B	0,1
	DC.B	0
	EVEN
	DC.W	5,3
	DC.L	0
	DC.L	TEXT3MENU7
	DC.L	0
TEXT3MENU7:
	DC.B	" TEST 7",0
	EVEN
*******************************************************************************
MENU3ITEM8:
	DC.L	MENU3ITEM9	*SAME AS ABOVE
	DC.W	0,70
	DC.W	120,15
	DC.W	$9f
	DC.L	0
	DC.L	MENU3TEXT8
	DC.L	0
	DC.B	"0"
	EVEN
	DC.L	0
	DC.W	0
MENU3TEXT8:
	DC.B	0,1
	DC.B	0
	EVEN
	DC.W	5,3
	DC.L	0
	DC.L	TEXT3MENU8
	DC.L	0
TEXT3MENU8:
	DC.B	" TEST 8",0
	EVEN
*******************************************************************************
MENU3ITEM9:
	DC.L	MENU3ITEM10	*SAME AS ABOVE
	DC.W	0,80
	DC.W	120,15
	DC.W	$9f
	DC.L	0
	DC.L	MENU3TEXT9
	DC.L	0
	DC.B	"0"
	EVEN
	DC.L	0
	DC.W	0
MENU3TEXT9:
	DC.B	0,1
	DC.B	0
	EVEN
	DC.W	5,3
	DC.L	0
	DC.L	TEXT3MENU9
	DC.L	0
TEXT3MENU9:
	DC.B	" TEST 9",0
	EVEN
*******************************************************************************
MENU3ITEM10:
	DC.L	0
	DC.W	0,90
	DC.W	120,15
	DC.W	$9f
	DC.L	0
	DC.L	MENU3TEXT10
	DC.L	0
	DC.B	"0"
	EVEN
	DC.L	0
	DC.W	0
MENU3TEXT10:
	DC.B	0,1
	DC.B	0
	EVEN
	DC.W	5,3
	DC.L	0
	DC.L	TEXT3MENU10
	DC.L	0
TEXT3MENU10:
	DC.B	" TEST 10",0
	EVEN
*******************************************************************************
*******************************************************************************
MENU4ITEM1:
	DC.L	MENU4ITEM2	*POINTER TO NEXT MENU ITEM
	DC.W	0,0		*X/Y POSTION OF THE MENU ITEMS
	DC.W	120,15		*WIDTH AND HIEGHT OF MENU ITEM
	DC.W	$9f		*FLAGS
	DC.L	0		*EXCLUDE
	DC.L	MENU41TEXT1	*POINTER TO TEXT STRUCTURE
	DC.L	0		*MENU SELECT 0=FILL 1=BORDER
	DC.B	"0"		*COMMAND
	EVEN
	DC.L	0		*NO SUB ITEMS
	DC.W	0		*NEXT SELECT NONE
MENU41TEXT1:
	DC.B	0,1		*COLOURS
	DC.B	0		*MODE OVERWRITE
	EVEN
	DC.W	5,3		*X/Y POSTION
	DC.L	0		*STANDARD CHARACTER SET
	DC.L	TEXT4MENU1	*POINTER TO TEXT
	DC.L	0		*NO MORE TEXT
TEXT4MENU1:
	DC.B	" TEST 1",0
	EVEN
*******************************************************************************
MENU4ITEM2:
	DC.L	MENU4ITEM3	*SAME AS ABOVE
	DC.W	0,10
	DC.W	120,15
	DC.W	$9f
	DC.L	0
	DC.L	MENU42TEXT2
	DC.L	0
	DC.B	"0"
	EVEN
	DC.L	0
	DC.W	0
MENU42TEXT2:
	DC.B	0,1
	DC.B	0
	EVEN
	DC.W	5,3
	DC.L	0
	DC.L	TEXT4MENU2
	DC.L	0
TEXT4MENU2:
	DC.B	" TEST 2",0
	EVEN
*******************************************************************************
MENU4ITEM3:
	DC.L	MENU4ITEM4	*SAME AS ABOVE
	DC.W	0,20
	DC.W	120,15
	DC.W	$9f
	DC.L	0
	DC.L	MENU43TEXT3
	DC.L	0
	DC.B	"0"
	EVEN
	DC.L	0
	DC.W	0
MENU43TEXT3
	DC.B	0,1
	DC.B	0
	EVEN
	DC.W	5,3
	DC.L	0
	DC.L	TEXT4MENU3
	DC.L	0
TEXT4MENU3:
	DC.B	" TEST 3",0
	EVEN
*******************************************************************************
MENU4ITEM4:
	DC.L	MENU4ITEM5	*SAME AS ABOVE
	DC.W	0,30
	DC.W	120,15
	DC.W	$9f
	DC.L	0
	DC.L	MENU4TEXT4
	DC.L	0
	DC.B	"0"
	EVEN
	DC.L	0
	DC.W	0
MENU4TEXT4
	DC.B	0,1
	DC.B	0
	EVEN
	DC.W	5,3
	DC.L	0
	DC.L	TEXT4MENU4
	DC.L	0
TEXT4MENU4:
	DC.B	" TEST 4",0
	EVEN
*******************************************************************************
MENU4ITEM5:
	DC.L	MENU4ITEM6	*SAME AS ABOVE
	DC.W	0,40
	DC.W	120,15
	DC.W	$9f
	DC.L	0
	DC.L	MENU4TEXT5
	DC.L	0
	DC.B	"0"
	EVEN
	DC.L	0
	DC.W	0
MENU4TEXT5:
	DC.B	0,1
	DC.B	0
	EVEN
	DC.W	5,3
	DC.L	0
	DC.L	TEXT4MENU5
	DC.L	0
TEXT4MENU5:
	DC.B	" TEST 5",0
	EVEN
*******************************************************************************
MENU4ITEM6:
	DC.L	MENU4ITEM7	*SAME AS ABOVE
	DC.W	0,50
	DC.W	120,15
	DC.W	$9f
	DC.L	0
	DC.L	MENU4TEXT6
	DC.L	0
	DC.B	"0"
	EVEN
	DC.L	0
	DC.W	0
MENU4TEXT6:
	DC.B	0,1
	DC.B	0
	EVEN
	DC.W	5,3
	DC.L	0
	DC.L	TEXT4MENU6
	DC.L	0
TEXT4MENU6:
	DC.B	" TEST 6",0
	EVEN
*******************************************************************************
MENU4ITEM7:
	DC.L	MENU4ITEM8	*SAME AS ABOVE
	DC.W	0,60
	DC.W	120,15
	DC.W	$9f
	DC.L	0
	DC.L	MENU4TEXT7
	DC.L	0
	DC.B	"0"
	EVEN
	DC.L	0
	DC.W	0
MENU4TEXT7:
	DC.B	0,1
	DC.B	0
	EVEN
	DC.W	5,3
	DC.L	0
	DC.L	TEXT4MENU7
	DC.L	0
TEXT4MENU7:
	DC.B	" TEST 7",0
	EVEN
*******************************************************************************
MENU4ITEM8:
	DC.L	MENU4ITEM9	*SAME AS ABOVE
	DC.W	0,70
	DC.W	120,15
	DC.W	$9f
	DC.L	0
	DC.L	MENU4TEXT8
	DC.L	0
	DC.B	"0"
	EVEN
	DC.L	0
	DC.W	0
MENU4TEXT8:
	DC.B	0,1
	DC.B	0
	EVEN
	DC.W	5,3
	DC.L	0
	DC.L	TEXT4MENU8
	DC.L	0
TEXT4MENU8:
	DC.B	" TEST 8",0
	EVEN
*******************************************************************************
MENU4ITEM9:
	DC.L	MENU4ITEM10	*SAME AS ABOVE
	DC.W	0,80
	DC.W	120,15
	DC.W	$9f
	DC.L	0
	DC.L	MENU4TEXT9
	DC.L	0
	DC.B	"0"
	EVEN
	DC.L	0
	DC.W	0
MENU4TEXT9:
	DC.B	0,1
	DC.B	0
	EVEN
	DC.W	5,3
	DC.L	0
	DC.L	TEXT4MENU9
	DC.L	0
TEXT4MENU9:
	DC.B	" TEST 9",0
	EVEN
*******************************************************************************
MENU4ITEM10:
	DC.L	0
	DC.W	0,90
	DC.W	120,15
	DC.W	$9f
	DC.L	0
	DC.L	MENU4TEXT10
	DC.L	0
	DC.B	"0"
	EVEN
	DC.L	0
	DC.W	0
MENU4TEXT10:
	DC.B	0,1
	DC.B	0
	EVEN
	DC.W	5,3
	DC.L	0
	DC.L	TEXT4MENU10
	DC.L	0
TEXT4MENU10:
	DC.B	" TEST 10",0
	EVEN
*******************************************************************************
*******************************************************************************
MENU5ITEM1:
	DC.L	MENU5ITEM2	*POINTER TO NEXT MENU ITEM
	DC.W	0,0		*X/Y POSTION OF THE MENU ITEMS
	DC.W	120,15		*WIDTH AND HIEGHT OF MENU ITEM
	DC.W	$9f		*FLAGS
	DC.L	0		*EXCLUDE
	DC.L	MENU51TEXT1	*POINTER TO TEXT STRUCTURE
	DC.L	0		*MENU SELECT 0=FILL 1=BORDER
	DC.B	"0"		*COMMAND
	EVEN
	DC.L	0		*NO SUB ITEMS
	DC.W	0		*NEXT SELECT NONE
MENU51TEXT1:
	DC.B	0,1		*COLOURS
	DC.B	0		*MODE OVERWRITE
	EVEN
	DC.W	5,3		*X/Y POSTION
	DC.L	0		*STANDARD CHARACTER SET
	DC.L	TEXT5MENU1	*POINTER TO TEXT
	DC.L	0		*NO MORE TEXT
TEXT5MENU1:
	DC.B	" TEST 1",0
	EVEN
*******************************************************************************
MENU5ITEM2:
	DC.L	MENU5ITEM3	*SAME AS ABOVE
	DC.W	0,10
	DC.W	120,15
	DC.W	$9f
	DC.L	0
	DC.L	MENU52TEXT2
	DC.L	0
	DC.B	"0"
	EVEN
	DC.L	0
	DC.W	0
MENU52TEXT2:
	DC.B	0,1
	DC.B	0
	EVEN
	DC.W	5,3
	DC.L	0
	DC.L	TEXT5MENU2
	DC.L	0
TEXT5MENU2:
	DC.B	" TEST 2",0
	EVEN
*******************************************************************************
MENU5ITEM3:
	DC.L	MENU5ITEM4	*SAME AS ABOVE
	DC.W	0,20
	DC.W	120,15
	DC.W	$9f
	DC.L	0
	DC.L	MENU53TEXT3
	DC.L	0
	DC.B	"0"
	EVEN
	DC.L	0
	DC.W	0
MENU53TEXT3
	DC.B	0,1
	DC.B	0
	EVEN
	DC.W	5,3
	DC.L	0
	DC.L	TEXT5MENU3
	DC.L	0
TEXT5MENU3:
	DC.B	" TEST 3",0
	EVEN
*******************************************************************************
MENU5ITEM4:
	DC.L	MENU5ITEM5	*SAME AS ABOVE
	DC.W	0,30
	DC.W	120,15
	DC.W	$9f
	DC.L	0
	DC.L	MENU5TEXT4
	DC.L	0
	DC.B	"0"
	EVEN
	DC.L	0
	DC.W	0
MENU5TEXT4
	DC.B	0,1
	DC.B	0
	EVEN
	DC.W	5,3
	DC.L	0
	DC.L	TEXT5MENU4
	DC.L	0
TEXT5MENU4:
	DC.B	" TEST 4",0
	EVEN
*******************************************************************************
MENU5ITEM5:
	DC.L	MENU5ITEM6	*SAME AS ABOVE
	DC.W	0,40
	DC.W	120,15
	DC.W	$9f
	DC.L	0
	DC.L	MENU5TEXT5
	DC.L	0
	DC.B	"0"
	EVEN
	DC.L	0
	DC.W	0
MENU5TEXT5:
	DC.B	0,1
	DC.B	0
	EVEN
	DC.W	5,3
	DC.L	0
	DC.L	TEXT5MENU5
	DC.L	0
TEXT5MENU5:
	DC.B	" TEST 5",0
	EVEN
*******************************************************************************
MENU5ITEM6:
	DC.L	MENU5ITEM7	*SAME AS ABOVE
	DC.W	0,50
	DC.W	120,15
	DC.W	$9f
	DC.L	0
	DC.L	MENU5TEXT6
	DC.L	0
	DC.B	"0"
	EVEN
	DC.L	0
	DC.W	0
MENU5TEXT6:
	DC.B	0,1
	DC.B	0
	EVEN
	DC.W	5,3
	DC.L	0
	DC.L	TEXT5MENU6
	DC.L	0
TEXT5MENU6:
	DC.B	" TEST 6",0
	EVEN
*******************************************************************************
MENU5ITEM7:
	DC.L	MENU5ITEM8	*SAME AS ABOVE
	DC.W	0,60
	DC.W	120,15
	DC.W	$9f
	DC.L	0
	DC.L	MENU5TEXT7
	DC.L	0
	DC.B	"0"
	EVEN
	DC.L	0
	DC.W	0
MENU5TEXT7:
	DC.B	0,1
	DC.B	0
	EVEN
	DC.W	5,3
	DC.L	0
	DC.L	TEXT5MENU7
	DC.L	0
TEXT5MENU7:
	DC.B	" TEST 7",0
	EVEN
*******************************************************************************
MENU5ITEM8:
	DC.L	MENU5ITEM9	*SAME AS ABOVE
	DC.W	0,70
	DC.W	120,15
	DC.W	$9f
	DC.L	0
	DC.L	MENU5TEXT8
	DC.L	0
	DC.B	"0"
	EVEN
	DC.L	0
	DC.W	0
MENU5TEXT8:
	DC.B	0,1
	DC.B	0
	EVEN
	DC.W	5,3
	DC.L	0
	DC.L	TEXT5MENU8
	DC.L	0
TEXT5MENU8:
	DC.B	" TEST 8",0
	EVEN
*******************************************************************************
MENU5ITEM9:
	DC.L	MENU5ITEM10	*SAME AS ABOVE
	DC.W	0,80
	DC.W	120,15
	DC.W	$9f
	DC.L	0
	DC.L	MENU5TEXT9
	DC.L	0
	DC.B	"0"
	EVEN
	DC.L	0
	DC.W	0
MENU5TEXT9:
	DC.B	0,1
	DC.B	0
	EVEN
	DC.W	5,3
	DC.L	0
	DC.L	TEXT5MENU9
	DC.L	0
TEXT5MENU9:
	DC.B	" TEST 9",0
	EVEN
*******************************************************************************
MENU5ITEM10:
	DC.L	0
	DC.W	0,90
	DC.W	120,15
	DC.W	$9f
	DC.L	0
	DC.L	MENU5TEXT10
	DC.L	0
	DC.B	"0"
	EVEN
	DC.L	0
	DC.W	0
MENU5TEXT10:
	DC.B	0,1
	DC.B	0
	EVEN
	DC.W	5,3
	DC.L	0
	DC.L	TEXT5MENU10
	DC.L	0
TEXT5MENU10:
	DC.B	" TEST 10",0
	EVEN
*******************************************************************************
