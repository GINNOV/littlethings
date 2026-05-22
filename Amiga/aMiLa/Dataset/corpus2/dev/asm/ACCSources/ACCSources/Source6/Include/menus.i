****** intuition_menus.i ******************************************
*
*         By Steve Marshall
*
*******************************************************************	
	
	IFND	INTUITION_INTUITION_I
	INCLUDE 'INTUITION/INTUITION.I'
	ENDC	
	IFND	GRAPHICS_RASTPORT_I
	INCLUDE GRAPHICS/RASTPORT.I
	ENDC

; Macros to set global variables for MENUITEM and SUBMENUITEM macros.

MENUFLAGS	MACRO
MYMENUFLAGS	SET \1
	ENDM

MENUWIDTH	MACRO
MYMENUWIDTH	SET \1
	ENDM

SUBMENUWIDTH	MACRO
MYSUBMENUWIDTH	SET \1
	ENDM

; Macro to bump variable for menu Y position,
; the effect is to create a space between items

MENUSPACE	MACRO
YPOS		SET YPOS+10
  	ENDM 	
	
; Macro to create Menu structure,the main limitation is that the name 
; can't include spaces.The macro,at least those with Devpac can't pass
; them properly.I have left it this way as menu titles are usually
; simple short words with no spaces like "Project".

; Usage: MENU  Menu number,X position,Width,Next menu number,'Title'

MENU	MACRO
	EVEN
MENU\1:
	IFEQ		\5
	dc.l		0
	ELSEIF
  	dc.l 		MENU\5
  	ENDC
  	dc.w 		\2,0,\3,10
  	dc.w 		MENUENABLED
  	dc.l 		MENUTITLE\1
  	dc.l 		MENUITEM\11
  	dc.w 		0,0,0,0
MENUTITLE\1:
	dc.b		\4,0
	EVEN
YPOS		SET 0
  	ENDM	
  	
; Macro to create menuitem structure

; USAGE: MENUITEM item number,next item number,submenu number,fgnd,bgnd pens,submenu 
; Commseq char,Pointer,mutual exclude (optional).
; dc.b	"Title" 

; the text is seperate to allow for spaces (more common in menu items)
; word alignment is taken care of for all but the last item.
; POINTER is for your own use and may contain a number to identify the 
; menuitem or a pointer to the subroutine to jump to.It is acsessed by
; move.l	MI_SIZEOF(A0),D0 
; for instance,presuming A0 contains the address of the menu structure. 

MENUITEM	MACRO  
	EVEN
MENUITEM\1:
	IFEQ		\2
	dc.l		\2
	ELSEIF
  	dc.l 		MENUITEM\2
  	ENDC
  	dc.w 		0,YPOS,MYMENUWIDTH,10
  	dc.w 		MYMENUFLAGS
  	IFC		'','\8'
  	dc.l 		0
  	ELSEIF
  	dc.l		\8
  	ENDC
  	dc.l 		INTEXT\1,NULL
  	dc.b 		\6,0
  	IFEQ		\3
  	dc.l 		\3
  	ELSEIF
  	dc.l		SUBMENUITEM\3
  	ENDC
  	dc.w 		MENUNULL
  	dc.l 		\7
  	
  	IFNE		MYMENUFLAGS&CHECKIT
TEXTPOSX		SET 24
	ELSEIF
TEXTPOSX		SET 6
	ENDC

  
INTEXT\1:
  	dc.b 		\4,\5,RP_JAM2,0
  	dc.w 		TEXTPOSX,1
  	dc.l 		0,MENUSTRING\1,0

MENUSTRING\1:
YPOS		SET YPOS+10
  	ENDM  	

; Much the same as MENUITEM except first two items are 
; Menuitem number,subitem number.The submenu number can't
; be used so isn't included.Yeah I know,thats as clear as
; mud.In fact I'm getting confused myself.See the accompanying
; example program and source code.

SUBMENUITEM	MACRO  
	EVEN
SUBMENUITEM\1\2:
YPOS		SET \2*10-5
XPOS		SET MYMENUWIDTH-20
	IFEQ		\3
	dc.l		\3
	ELSEIF
  	dc.l 		SUBMENUITEM\3
  	ENDC
  	dc.w 		XPOS,YPOS,MYSUBMENUWIDTH,10
  	dc.w 		MYMENUFLAGS
  	IFC		'','\8'
  	dc.l 		0
  	ELSEIF
  	dc.l		\8
  	ENDC
  	dc.l 		INTEXT\1\2,NULL
  	dc.b 		\6,0
  	dc.l 		0
  	dc.w 		MENUNULL
  	dc.l 		\7
  	
    	IFNE		MYMENUFLAGS&CHECKIT
TEXTPOSX		SET 24
	ELSEIF
TEXTPOSX		SET 6
	ENDC
	
INTEXT\1\2:
  	dc.b 		\4,\5,RP_JAM2,0
  	dc.w 		TEXTPOSX,1
  	dc.l 		0,SUBMENUSTRING\1\2,0

SUBMENUSTRING\1\2:
  	ENDM 
