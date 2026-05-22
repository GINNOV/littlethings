
*	Devpac III Mock.  Code - Mike Cross, July 1990

*	Only two menu functions actually work as yet.

*	This program is helpful to people interested in learning
*	how to set up menus, apart from that it is useless.  I just
*	found it on an old source disk, and I thought I would unleash
*	it upon a poor unsuspecting world.

*	P.s : All structures created by hand (without powerwindows!!!)

	
	opt	c-
	
	move.l	$4,a6		* Execbase
	lea	IntName,a1
	jsr	-408(a6)		* OldOpenLibrary()
	beq	Exit00
	move.l	d0,IntBase	* Save Intuition Address
	move.l	$4,a6		* Now that I have the Intuition base
	move.l	IntBase,a1	* Address, I can close the library 
	jsr	-414(a6)		* CloseLibrary()  - Intuition 

	move.l	$4,a6		* Do same for Dos Library
	lea	DosName,a1	
	jsr	-408(a6)		* OldOpenLibrary()
	beq	Exit00
	move.l	d0,DosBase	
	move.l	$4,a6		
	move.l	DosBase,a1	
	jsr	-414(a6)	 

	move.l	IntBase,a6	
	lea	Screen1,a0	* Pointer to Screen structure
	jsr	-198(a6)		* OpenScreen()
	move.l	d0,SHandle	* Save screen offset structure
	beq	Exit00
	
	move.l	IntBase,a6
	lea	Window1,a0	* Pointer to Window structure
	jsr	-204(a6)		* OpenWindow()
	move.l	d0,WHandle	* Save window offset structure
	beq	Exit01
	
	lea	Mtext,a1
	move.l	#-15,d0
	move.l	#239,d1
	move.l	IntBase,a6
	move.l	WHandle,a0
	move.l	50(a0),a0	* Screen rastport address
	jsr	-216(a6)		* PrintIText
	Beq	Exit01
	
	move.l	IntBase,a6
	move.l	WHandle,a0
	lea	Menu,a1
	jsr	-264(a6)		* SetMenuStrip()
	beq	Exit02
	

loop	move.l	$4,a6
	move.l	WHandle,a0
	move.l	86(a0),a0
	jsr	-372(a6)		* GetMsg() - Exec
	beq	loop
	move.l	d0,a0
	move.l	20(a0),d6
	
	cmpi.w	#$200,d6		* Was close window selected ?
	bne	CMenu00		* No. Then check for menu event
	jsr	End_Rqs		* Yes. Ask if sure and if so - exit
	bne	Out
	
	
CMenu00	cmpi.w	#$100,d6
	bne	FP0End

	
CMenu01	move.w	$18(a0),d7	* Get menu items
	move.w	d7,d6
	lsr	#8,d7
	lsr	#3,d7		* SubMenu No in D7
	clr.l	d5
	roxr	#1,d6
	roxl	#1,d5		* menu Number in D5
	and.l	#$7f,d6
	cmp	#$7f,d6
	beq	loop
	lsr	#4,d6		* Menu item in D6
	
	cmpi.b	#0,d5		* Was it first menu ?
	bne	FindPoint04	* If not check for Menu - 4
	
	
FindPoint00
	cmpi.b	#$00,d6		* Was it Clear (item 0)
	bne	FP02		* No, check next item
	jsr	End_Rqs		* Yes then ask end request
	bne	Out		* Was it an exit OK ?
	jmp	loop		* No - back to loop

FP02	cmpi.b	#$05,d6		Was it print block
	bne	FP03
	move.l	SHandle,a0
	move.l	IntBase,a6
	jsr	-96(a6)		* If so, do a flash.
	jmp	loop
	
FP03	cmpi.b	#$07,d6		* Was it Quit (item 7)
	bne	FP0End
	jsr	End_Rqs
	bne	Out
	jmp	loop
	

	
FP0End	jmp	loop
	
******************************************************	


FindPoint04
	cmpi.w	#3,d5		* Was it on Extra Menu ?
	bne	FP4End
	
	cmpi.w	#1,d6
	bne	FP4End
	
	move.l	SHandle,a0
	move.l	IntBase,a6
	jsr	-96(a6)
	
	
FP4End	jmp	loop


	
End_Rqs	move.l	#0,d0		* Clear check registers (D0, D1)
	move.l	#0,d1
	move.l	#250,d2		* End_Requester width
	move.l	#60,d3		* End_Requester height
	move.l	WHandle,a0	* Attach End_Requester to this window
	lea	BText,a1		* Pointer to main End_Requester text
	lea	LText,a2		* Text displayed on left
	lea	RText,a3		* Text displayed on right
	move.l	IntBase,a6	
	jsr	-348(a6)		* AutoEnd_Request()
	rts
	
	
Out	move.l	IntBase,a6
	move.l	WHandle,a0
	jsr	-54(a6)		* ClearMenuStrip()

Exit02	move.l	IntBase,a6
	move.l	WHandle,a0
	jsr	-72(a6)		* CloseWindow()

Exit01	move.l	IntBase,a6
	move.l	SHandle,a0
	jsr	-66(a6)		* CloseScreen()
	

Exit00	rts


IntName	dc.b	"intuition.library",0

DosName	dc.b	"dos.library",0

	even

IntBase	dc.l	0

DosBase	dc.l	0

WHandle	dc.l	0

Save_WH	dc.l	0

	even
	   
Screen1	dc.w	0,0,640,400,2	* Data structure for Screen
	dc.b	0,1
	dc.w	$8002,15
	dc.l	0
	dc.l	Title1
	dc.l	0,0
Title1	dc.b	'Devpac III Copyright ©1990, Cross-Soft ',0
	
	even
	
Window1	dc.w	0,0,640,255	* Data Structure for window
	dc.b	0,1
	dc.l	$300
	dc.l	%0001000000001111	* $100f
	dc.l	0,0
	dc.l	Wtitle
SHandle	dc.l	0
	dc.l	0
	dc.w	150,50,320,200,15
Wtitle	dc.b	'Devpac III Copyright ©1990, Cross-Soft ',0
	
	even

* SAVE WINDOW STRUCTURE

Save_Window	
	dc.w	20,20,100,100	* Data Structure for window
	dc.b	0,1
	dc.l	$300
	dc.l	%0001000000001111	* $100f
	dc.l	0,0
	dc.l	Savtitl
SaveWH	dc.l	0
	dc.l	0
	dc.w	150,50,320,200,15
Savtitl	dc.b	"Save File",0
	
	even
	
MText	dc.b	3,1
	dc.b	0
	even
	dc.w	20,6
	dc.l	0
	dc.l	BotTxt
	dc.l	0
BotTxt	dc.b	"Line:    1 Col:    1 Mem:100980",0
	
	even
	
BText	dc.b	0,1
	dc.b	0
	even
	dc.w	20,6
	dc.l	0
	dc.l	BodyTxt
	dc.l	0
BodyTxt	dc.b	"OK to lose changes?",0
	
	even

LText	dc.b	0,1
	dc.b	0
	even
	dc.w	5,3
	dc.l	0
	dc.l	LeftTxt  
	dc.l	0
LeftTxt	dc.b	"  OK  ",0
	
	even
	
RText	dc.b	0,1
	dc.b	0
	even
	dc.w	5,3
	dc.l	0
	dc.l	RightTx
	dc.l	0
RightTx	dc.b	"Cancel",0
	
	even
	
***********************************
Menu	dc.l	menu1
	dc.w	10,30,80,10,1
	dc.l	Name00
	dc.l	Item01
	dc.w	0,0,0,0
Name00	dc.b	"Project",0
	even
***********************************
Menu1	dc.l	Menu2
	dc.w	100,0,70,10,1
	dc.l	Name01
	dc.l	item11
	dc.w	0,0,0,0
Name01	dc.b	"Search",0
	even
***********************************
Menu2	dc.l	Menu3
	dc.w	180,0,80,10,1
	dc.l	Name02
	dc.l	item21		
	dc.w	0,0,0,0
Name02	dc.b	"Options",0
	even
***********************************
Menu3	dc.l	Menu4
	dc.w	270,0,80,10,1
	dc.l	Name03
	dc.l	item31		
	dc.w	0,0,0,0
Name03	dc.b	"Program",0
	even
***********************************	
Menu4	dc.l	0
	dc.w	360,0,70,10,1
	dc.l	Name04
	dc.l	item41		
	dc.w	0,0,0,0
Name04	dc.b	"Extras",0
	even
***********************************	



item01	dc.l	item02
	dc.w	0,0,162,8,$56
	dc.l	0
	dc.l	txt01
	dc.l	0
	dc.b	"C"
	even
	dc.l	0
	dc.w	0
txt01	dc.b	0,1,0
	even
	dc.w	5,0
	dc.l	0
	dc.l	Text01
	dc.l	0
text01	dc.b	"Clear",0
	even
***********************************
item02	dc.l	item03
	dc.w	0,10,162,8,$56
	dc.l	0
	dc.l	txt02
	dc.l	0
	dc.b	"L"
	even
	dc.l	0
	dc.w	0
txt02	dc.b	0,1,0
	even
	dc.w	5,0
	dc.l	0
	dc.l	text02
	dc.l	0
text02	dc.b	"Load",0
	even
***********************************
item03	dc.l	item04
	dc.w	0,22,162,8,$52
	dc.l	0
	dc.l	txt03
	dc.l	0
	dc.b	0
	even
	dc.l	0
	dc.w	0
txt03	dc.b	0,1,0
	even
	dc.w	5,0
	dc.l	0
	dc.l	text03
	dc.l	0
text03	dc.b	"Save",0
	even
***********************************
item04	dc.l	item05
	dc.w	0,32,162,8,$56
	dc.l	0
	dc.l	txt04
	dc.l	0
	dc.b	"S"
	even
	dc.l	0
	dc.w	0
txt04	dc.b	0,1,0
	even
	dc.w	5,0
	dc.l	0
	dc.l	text04
	dc.l	0
text04	dc.b	"Save As",0
	even
***********************************
item05	dc.l	item06
	dc.w	0,44,162,8,$56
	dc.l	0
	dc.l	txt05
	dc.l	0
	dc.b	"I"
	even
	dc.l	0
	dc.w	0
txt05	dc.b	0,1,0
	even
	dc.w	5,0
	dc.l	0
	dc.l	text05
	dc.l	0
text05	dc.b	"Insert file",0
	even
***********************************
item06	dc.l	item07
	dc.w	0,54,162,8,$56
	dc.l	0
	dc.l	txt06
	dc.l	0
	dc.b	"W"
	even
	dc.l	0
	dc.w	0
txt06	dc.b	0,1,0
	even
	dc.w	5,0
	dc.l	0
	dc.l	text06
	dc.l	0
text06	dc.b	"Print Block",0
	even
***********************************
item07	dc.l	item08
	dc.w	0,64,162,8,$56
	dc.l	0
	dc.l	txt07
	dc.l	0
	dc.b	"O"
	even
	dc.l	0
	dc.w	0
txt07	dc.b	0,1,0
	even
	dc.w	5,0
	dc.l	0
	dc.l	text07
	dc.l	0
text07	dc.b	"Directory",0
	even
***********************************
item08	dc.l	0
	dc.w	0,76,162,8,$56
	dc.l	0
	dc.l	txt08
	dc.l	0
	dc.b	"Q"
	even
	dc.l	0
	dc.w	0
txt08	dc.b	0,1,0
	even
	dc.w	5,0
	dc.l	0
	dc.l	text08
	dc.l	0
text08	dc.b	"Quit",0
	even
***********************************
* START OF MENU 2 LIST

Item11	dc.l	Item12
	dc.w	0,0,174,8,$56
	dc.l	0
	dc.l	txt11
	dc.l	0
	dc.b	"F"
	even
	dc.l	0
	dc.w	0
txt11	dc.b	0,1,0
	even
	dc.w	5,0
	dc.l	0
	dc.l	text11
	dc.l	0
text11	dc.b	"Find",0
	even
***********************************
Item12	dc.l	Item13
	dc.w	0,10,174,8,$56
	dc.l	0
	dc.l	txt12
	dc.l	0
	dc.b	"N"
	even
	dc.l	0
	dc.w	0
txt12	dc.b	0,1,0
	even
	dc.w	5,0
	dc.l	0
	dc.l	text12
	dc.l	0
text12	dc.b	"Find Next",0
	even
***********************************
Item13	dc.l	Item14
	dc.w	0,20,174,8,$56
	dc.l	0
	dc.l	txt13
	dc.l	0
	dc.b	"P"
	even
	dc.l	0
	dc.w	0
txt13	dc.b	0,1,0
	even
	dc.w	5,0
	dc.l	0
	dc.l	text13
	dc.l	0
text13	dc.b	"Find Previous",0
	even
***********************************
Item14	dc.l	item15
	dc.w	0,30,174,8,$56
	dc.l	0
	dc.l	txt14
	dc.l	0
	dc.b	"R"
	even
	dc.l	0
	dc.w	0
txt14	dc.b	0,1,0
	even
	dc.w	5,0
	dc.l	0
	dc.l	text14
	dc.l	0
text14	dc.b	"Replace",0
	even
***********************************
Item15	dc.l	0
	dc.w	0,40,174,8,$52
	dc.l	0
	dc.l	txt15
	dc.l	0
	dc.b	0
	even
	dc.l	submenu0
	dc.w	0
txt15	dc.b	0,1,0
	even
	dc.w	5,0
	dc.l	0
	dc.l	text15
	dc.l	0
text15	dc.b	"Replace All",0
	even
***********************************
Submenu0
	dc.l	0
	dc.w	130,8,120,10,$52
	dc.l	0
	dc.l	txts0
	dc.l	0
	dc.b	0
	even
	dc.l	0
	dc.w	0
txts0	dc.b	0,3,0
	even
	dc.w	5,2
	dc.l	0,textS0,0
textS0	dc.b	"Are you sure?",0
	even
***********************************
item21	dc.l	item22
	dc.w	0,0,176,8,$56
	dc.l	0
	dc.l	txt21
	dc.l	0
	dc.b	"G"
	even
	dc.l	0
	dc.w	0
txt21	dc.b	0,1,0
	even
	dc.w	5,0
	dc.l	0
	dc.l	Text21
	dc.l	0
text21	dc.b	"Goto line",0
	even
***********************************
item22	dc.l	item23
	dc.w	0,10,176,8,$56
	dc.l	0
	dc.l	txt22
	dc.l	0
	dc.b	"T"
	even
	dc.l	0
	dc.w	0
txt22	dc.b	0,1,0
	even
	dc.w	5,0
	dc.l	0
	dc.l	Text22
	dc.l	0
text22	dc.b	"Goto Top",0
	even	
***********************************
item23	dc.l	item24
	dc.w	0,20,176,8,$56  
	dc.l	0
	dc.l	txt23
	dc.l	0
	dc.b	"B"
	even
	dc.l	0
	dc.w	0
txt23	dc.b	0,1,0
	even
	dc.w	5,0
	dc.l	0
	dc.l	Text23
	dc.l	0
text23	dc.b	"Goto Bottom",0
	even		
***********************************
item24	dc.l	0
	dc.w	0,35,176,8,$52
	dc.l	0
	dc.l	txt24
	dc.l	0
	dc.b	0
	even
	dc.l	0
	dc.w	0
txt24	dc.b	0,1,0
	even
	dc.w	5,0
	dc.l	0
	dc.l	Text24
	dc.l	0
text24	dc.b	"Preferences",0
	even	
***********************************
item31	dc.l	item32
	dc.w	0,0,196,8,$56
	dc.l	0
	dc.l	txt31
	dc.l	0
	dc.b	"A"
	even
	dc.l	0
	dc.w	0
txt31	dc.b	0,1,0
	even
	dc.w	5,0
	dc.l	0
	dc.l	Text31
	dc.l	0
text31	dc.b	"Assemble",0
	even
***********************************
item32	dc.l	item33
	dc.w	0,10,196,8,$56
	dc.l	0
	dc.l	txt32
	dc.l	0
	dc.b	"X"
	even
	dc.l	0
	dc.w	0
txt32	dc.b	0,1,0
	even
	dc.w	5,0
	dc.l	0
	dc.l	Text32
	dc.l	0
text32	dc.b	"Run",0
	even
***********************************	
item33	dc.l	item34
	dc.w	0,20,196,8,$56
	dc.l	0
	dc.l	txt33
	dc.l	0
	dc.b	"D"
	even
	dc.l	0
	dc.w	0
txt33	dc.b	0,1,0
	even
	dc.w	5,0
	dc.l	0
	dc.l	Text33
	dc.l	0
text33	dc.b	"Debug",0
	even
***********************************	
item34	dc.l	item35
	dc.w	0,30,196,8,$56
	dc.l	0
	dc.l	txt34
	dc.l	0
	dc.b	"M"
	even
	dc.l	0
	dc.w	0
txt34	dc.b	0,1,0
	even
	dc.w	5,0
	dc.l	0
	dc.l	Text34
	dc.l	0
text34	dc.b	"MonAm",0
	even
***********************************	
item35	dc.l	item36
	dc.w	0,45,196,8,$56
	dc.l	0
	dc.l	txt35
	dc.l	0
	dc.b	"J"
	even
	dc.l	0
	dc.w	0
txt35	dc.b	0,1,0
	even
	dc.w	5,0
	dc.l	0
	dc.l	Text35
	dc.l	0
text35	dc.b	"Jump to Error",0
	even
***********************************
item36	dc.l	0
	dc.w	0,60,196,8,$56
	dc.l	0
	dc.l	txt36
	dc.l	0
	dc.b	"H"
	even
	dc.l	0
	dc.w	0
txt36	dc.b	0,1,0
	even
	dc.w	5,0
	dc.l	0
	dc.l	Text36
	dc.l	0
text36	dc.b	"Help",0
	even
**************************************	
* Extras Menu. All Extras (c) 1990 MJC
**************************************	
item41	dc.l	item42
	dc.w	0,0,180,8,$56
	dc.l	0
	dc.l	txt41
	dc.l	0
	dc.b	"1"
	even
	dc.l	0
	dc.w	0
txt41	dc.b	0,1,0
	even
	dc.w	5,0
	dc.l	0
	dc.l	Text41
	dc.l	0
text41	dc.b	"About",0
	even
***********************************
item42	dc.l	item43
	dc.w	0,10,180,8,$56
	dc.l	0
	dc.l	txt42
	dc.l	0
	dc.b	"2"
	even
	dc.l	0
	dc.w	0
txt42	dc.b	0,1,0
	even
	dc.w	5,0
	dc.l	0
	dc.l	Text42
	dc.l	0
text42	dc.b	"Evaluate",0
	even
***********************************
item43	dc.l	item44
	dc.w	0,20,180,8,$56
	dc.l	0
	dc.l	txt43
	dc.l	0
	dc.b	"3"
	even
	dc.l	0
	dc.w	0
txt43	dc.b	0,1,0
	even
	dc.w	5,0
	dc.l	0
	dc.l	Text43
	dc.l	0
text43	dc.b	"Interlace",0
	even
***********************************
item44	dc.l	0
	dc.w	0,30,180,8,$56
	dc.l	0
	dc.l	txt44
	dc.l	0
	dc.b	"4"
	even
	dc.l	0
	dc.w	0
txt44	dc.b	0,1,0
	even
	dc.w	5,0
	dc.l	0
	dc.l	Text44
	dc.l	0
text44	dc.b	"Colours",0
	even
***********************************

		
