;***********************************************************
;	Short program to explain the use of my menu
;	macros.A better way by far is to use something 
;	like Power Windows but failing that this may 
;	help a little.This code reproduces the menu
;	from Notepad.The only item that works is the 
;	quit item.Just select menuitems and seeing how
;	the mutual exclude works on menus like Style
;	etc.When you get p##*%@ off use the close 
;	gadget or Quit from the menu.These macros aren't 
;	perfect by any means but I managed to create
;	this menu in about 15 mins.It would have taken
;	me a lot longer doing it the longhanded way.
;	Anyway,if you don't like it you've lost nowt.
;	For more information on the use of the macros
;	refer to the include file intuition/intuition_menus.i  
;***********************************************************
	INCDIR 		"SYS:INCLUDE/"
	INCLUDE 	INTUITION/INTUITION.I
	INCLUDE 	source6:include/MENUS.I
	INCLUDE		source6:include/deftoolstartup.i

NULL EQU 0

;------ open a window and attach the menu to it
  	lea 		MyNewWindow,A0
  	CALL		Intuition,OpenWindow
  	move.l 		D0,WINDOWHD
  	beq 		IntError
  	move.l 		D0,A0
  	lea 		MENU1,A1
  	CALLSYS 	SetMenuStrip
  	
;------ wait for an intuition message
Loop:
  	move.l 		WINDOWHD,A0
  	move.l 		wd_UserPort(A0),A0
  	move.l 		A0,MPort
 	CALLEXEC 	WaitPort
 	
;------ get the message
  	move.l 		MPort,A0
  	CALLSYS		GetMsg
  	tst 		D0
  	beq.s 		Loop 

;------ store message 
  	move.l 		D0,A1
  	move.l 		A1,MESSAGE
  	
;------ test for message type and act accordingly
  	move.l 		im_Class(A1),D1
  	cmp.l 		#CLOSEWINDOW,D1
  	beq.s	 	KillWindow
  	cmp.l 		#MENUPICK,D1
  	bne.s 		EndMenu
  	
;------ if we reach here the message was MENUPICK
  	lea 		MENU1,A0		;A0 = menustrip
  	move.l 		MESSAGE,A1		;A1 = message
  	
;------ im_Code holds the menunumber of the type 
;	required by ItemAddress
  	move.w 		im_Code(A1),D0		;D0 = MenuNumber
  	CALL		Intuition,ItemAddress
  	tst.l		D0
  	beq.s		EndMenu			;trap any errors
  	
;------ D0 now contains the address of the calling menuitem structure
  	move.l 		D0,A0
;------ get pointer (our extension) from end of structure
  	move.l 		mi_SIZEOF(a0),a0
  	jsr 		(A0)			;jmp to menu's routine 

;------ reply to message then lopp back to go again
EndMenu:
  	move.l 		MESSAGE,A1
  	CALLEXEC	ReplyMsg
  	bra.s	 	Loop

;------ remove menu and close window
KillWindow: 
  	move.l 		WINDOWHD,A0
  	CALL		Intuition,ClearMenuStrip
  	move.l 		WINDOWHD,A0
  	CALLSYS 	CloseWindow
  
DONOTHING:
IntError:
	rts
  	
;------ routine called by Quit menu item as we are already 
;	within a subroutine we shall have to pop subroutines 
;	return address from the stack - messy but it works
QUIT:
	addq		#4,sp
	move.l 		MESSAGE,A1
  	CALLEXEC	ReplyMsg
	bra.s		KillWindow
 

;*****************************************
	SECTION Display_Data,DATA
;*****************************************

;------ window structure
MyNewWindow 
  	dc.w 		10,20
  	dc.w 		310,30
  	dc.b 		-1,-1
  	dc.l 		CLOSEWINDOW!MENUPICK!GADGETDOWN
  	dc.l 		WINDOWDRAG!WINDOWDEPTH!WINDOWCLOSE!ACTIVATE
  	dc.l 		NULL
  	dc.l 		NULL
  	dc.l 		MYTITLE  
  	dc.l 		NULL
  	dc.l 		NULL
  	dc.w 		255,111
  	dc.w 		320,160
  	dc.w 		WBENCHSCREEN
  
MYTITLE:
  	dc.b 		"Menu Demo",0  
  	EVEN
  	
;***********************************************************
;	This bit is the menu macros which define
;	the menu structures

;------ menu 1
  	
	MENU		1,0,100,"Project",2
	
	MENUFLAGS	ITEMTEXT!ITEMENABLED!HIGHCOMP	
	MENUWIDTH	130
	MENUITEM 	11,12,0,0,1,0,DONOTHING
	dc.b 	"New",0
	
	MENUFLAGS	ITEMTEXT!ITEMENABLED!COMMSEQ!HIGHCOMP
	MENUITEM 	12,13,0,0,1,"O",DONOTHING
  	dc.b 	"Open",0
  	
	MENUITEM 	13,14,0,0,1,"S",DONOTHING
	dc.b 	"Save",0
	
	MENUFLAGS	ITEMTEXT!ITEMENABLED!HIGHCOMP
	MENUITEM 	14,15,0,0,1,0,DONOTHING
	dc.b 	"Save As",0
	
	MENUITEM 	15,16,151,0,1,0,DONOTHING
	dc.b 	"Print",0
	
	MENUITEM 	16,17,161,0,1,0,DONOTHING
	dc.b 	"Print As ",0
	
	MENUITEM 	17,18,0,0,1,0,DONOTHING
	dc.b 	"Read Fonts",0
	
	MENUITEM 	18,0,0,0,1,0,QUIT
	dc.b 	"Quit",0
	
;------ submenus for menu 1
	
	
	SUBMENUWIDTH	100
	SUBMENUITEM 	15,1,152,0,1,0,DONOTHING
  	dc.b 	"Auto-Size",0
  	
	SUBMENUITEM 	15,2,153,0,1,0,DONOTHING
	dc.b 	"Small",0
	
	SUBMENUITEM 	15,3,154,0,1,0,DONOTHING
	dc.b 	"Medium",0
	
	SUBMENUITEM 	15,4,0,0,1,0,DONOTHING
	dc.b 	"Large",0
	
	
	SUBMENUITEM 	16,1,162,0,1,0,DONOTHING
	dc.b 	"Graphic",0
	
	SUBMENUITEM 	16,2,164,0,1,0,DONOTHING
	dc.b 	"Draft",0
	
	SUBMENUITEM 	16,4,0,0,1,0,DONOTHING
	dc.b 	"Form-feeds",0
	
;------ menu 2
	
	
	MENU		2,100,100,"Edit",3	
	
	MENUWIDTH	150
	MENUFLAGS	ITEMTEXT!ITEMENABLED!COMMSEQ!HIGHCOMP
	MENUITEM 	21,22,0,0,1,"Q",DONOTHING
	dc.b 	"Cancel",0
	
	MENUITEM 	22,23,0,0,1,"X",DONOTHING
	dc.b 	"Cut",0 
	
	MENUITEM 	23,24,0,0,1,"&",DONOTHING
	dc.b 	"Paste",0
	
	MENUITEM 	24,25,0,0,1,"C",DONOTHING
	dc.b 	"Copy",0
	
	MENUITEM 	25,26,0,0,1,"M",DONOTHING
	dc.b 	"Mark Place",0
	
	MENUSPACE
	
	MENUITEM 	26,27,0,0,1,"F",DONOTHING
	dc.b 	"Find",0
	
	MENUITEM 	27,28,0,0,1,"N",DONOTHING
	dc.b 	"Find Next",0
	
	MENUITEM 	28,29,0,0,1,"-",DONOTHING
	dc.b 	"Find Prev",0
	
	MENUITEM 	29,0,0,0,1,"R",DONOTHING
	dc.b 	"Replace",0
	
;------ menu 3
	
	MENU		3,200,100,"Font",4	
	
	MENUWIDTH	130
	MENUFLAGS	ITEMTEXT!ITEMENABLED!CHECKIT!HIGHCOMP!CHECKED
	MENUITEM 	31,0,311,0,1,0,DONOTHING
	dc.b 	"topaz",0
	
;------ submenus for menu 3
	
	SUBMENUWIDTH	50
	SUBMENUITEM	31,1,312,0,1,0,DONOTHING,6
	dc.b 	" 8",0
	
	MENUFLAGS	ITEMTEXT!ITEMENABLED!CHECKIT!HIGHCOMP
	SUBMENUITEM	31,2,313,0,1,0,DONOTHING,5
	dc.b	" 9",0
	
	SUBMENUITEM	31,3,0,0,1,0,DONOTHING,3
	dc.b 	" 11",0
	
;------ menu 4
	
	MENU		4,300,100,"Style",5	
	
	MENUWIDTH	150
	MENUFLAGS	ITEMTEXT!ITEMENABLED!COMMSEQ!CHECKIT!HIGHCOMP!CHECKED
	MENUITEM 	41,42,0,0,1,"P",DONOTHING,14
	dc.b 	"Plain",0
	
	MENUFLAGS	ITEMTEXT!ITEMENABLED!COMMSEQ!CHECKIT!HIGHCOMP
	MENUITEM 	42,43,0,0,1,"I",DONOTHING,1
	dc.b 	"Italic",0
	
	MENUITEM 	43,44,0,0,1,"B",DONOTHING,1
	dc.b 	"Bold",0
	
	MENUITEM 	44,0,0,0,1,"U",DONOTHING,1
	dc.b 	"Underline",0
	
;------ menu 5

  	MENU		5,400,100,"Format",0	
  	
  	MENUFLAGS	ITEMTEXT!ITEMENABLED!HIGHCOMP
  	MENUITEM 	51,52,511,0,1,0,DONOTHING
	dc.b 	"  Paper Color",0 
	
	MENUITEM 	52,53,521,0,1,0,DONOTHING
	dc.b 	"  Pen Color",0
	
	MENUFLAGS	ITEMTEXT!ITEMENABLED!CHECKIT!HIGHCOMP!CHECKED
	MENUITEM 	53,54,0,0,1,0,DONOTHING
	dc.b 	"Word Wrap",0 
	
	MENUITEM 	54,55,0,0,1,0,DONOTHING
	dc.b 	"Global Font",0 
	
	MENUFLAGS	ITEMTEXT!ITEMENABLED!HIGHCOMP
	MENUITEM 	55,56,0,0,1,0,DONOTHING
	dc.b 	"  Remove Fonts",0 
	
	MENUITEM 	56,0,0,0,1,0,DONOTHING
	dc.b 	"  Remove Styles",0 
	
;------ submenus for menu 5
	
	
	MENUFLAGS	ITEMTEXT!ITEMENABLED!CHECKIT!HIGHCOMP
	SUBMENUITEM	51,1,512,0,0,0,DONOTHING,14
	dc.b 	"   ",0
	
	MENUFLAGS	ITEMTEXT!ITEMENABLED!CHECKIT!HIGHCOMP!CHECKED
	SUBMENUITEM	51,2,513,0,1,0,DONOTHING,13
	dc.b 	"   ",0
	
	MENUFLAGS	ITEMTEXT!ITEMENABLED!CHECKIT!HIGHCOMP
	SUBMENUITEM	51,3,514,0,2,0,DONOTHING,11
	dc.b 	"   ",0
	
	SUBMENUITEM	51,4,0,0,3,0,DONOTHING,7
	dc.b 	"   ",0
	
	
	SUBMENUITEM	52,1,522,0,0,0,DONOTHING,14
	dc.b 	"   ",0
	
	SUBMENUITEM	52,2,523,0,1,0,DONOTHING,13
	dc.b 	"   ",0
	
	MENUFLAGS	ITEMTEXT!ITEMENABLED!CHECKIT!HIGHCOMP!CHECKED
	SUBMENUITEM	52,3,524,0,2,0,DONOTHING,11
	dc.b 	"   ",0
	
	MENUFLAGS	ITEMTEXT!ITEMENABLED!CHECKIT!HIGHCOMP
	SUBMENUITEM	52,4,0,0,3,0,DONOTHING,7
	dc.b 	"   ",0
	
	EVEN
	
;----- end of menu definitions
	
MPort:			dc.l	0

MESSAGE:		dc.l	0

WINDOWHD:		dc.l	0
