				;Dave Shaw
				;15 Kirkton ave,
				;Flat 7/1,
				;Knightswood,
				;Glasgow,
				;G13 3SE
				;041-954-4493
;--------This was to be a small program to
;        run my most used utilities and has
;        expanded from this,the idea was taken
;        from Nico Francios program Selector
;        the only problem is that the program
;        name's have to be inserted before
;        assembly,maybe if I updated it it will
;        read files like Nicos don't know how just
;        yet but I am learning something new every day
;        so it might be soon.Set tabs to 12 for easy
;        reading.
;        Added a 3D look to gadgets and an inverted 3D
;        when they are selected.Had a problem when
;        quiting a program run from the menu,gadgets 
;        were being selected so I've decided to make
;        the menu go to sleep after selection,problem
;        solved.
	
;        PS.Thanks go out to Steve Marshall for the
;        help that he gave me over the phone 
;        And to Mark for the concept for ACC
;        where would we all be without it
;        more than likely slashing our wrists
;        in the Loo.		
				
				
;-----------added easystart.i for workbench startup
;	but have not tested it yet.
	
	opt	c-			

	Incdir	"sys:include/"
	include	"exec/exec_lib.i"
	include	"exec/exec.i"
	include	"intuition/intuition_lib.i"
	include	"intuition/intuition.i"
	include	"libraries/dos_lib.i"
	include	"libraries/dos.i"
	include	"libraries/dosextens.i"
	include	"misc/easystart.i"
	
;-----------Only two equ's one for mouse button register.

	
ciaapra	equ	$bfe001		;mouse button register
NULL	equ	0		;makes for easy reading

;-----------Added Steve Marshalls Macro call to speed up CALLINT etc

CALLSYS	MACRO		
        IFGT      NARG-1
        FAIL      !!!
        ENDC
        JSR       _LVO\1(A6)
        ENDM		


;-----------Program starts here the label main is inserted at
;	bsr openwin for the sleep routine to reopen the main
;	window with the gadgets,and graphics to appear again.

	bsr.s	openint
	beq.s	error
	bsr.s	opendos
	beq.s	error1
main	bsr	openwin
	beq.s	error2
	bsr	ok
	bsr	Graphics
	bra	wait_for_msg
	
	
;-----------Open the intuition library and store base ptr.


openint	lea	intname,a1		;library name a1
	moveq.l	#0,d0		;any version
	CALLEXEC	OpenLibrary		;and open
	move.l	d0,_IntuitionBase	;store pointer
	rts
		

;------------Open dos library and store base pointer


opendos	lea	dosname,a1	
	moveq.l	#0,d0		;any version
	CALLEXEC	OpenLibrary
	move.l	d0,_DOSBase		;save pointer
	rts
	

;-----------Error routine here

	
error2	bsr	closedos
error1	bsr	intclose
error	rts	

;-----------Routine taken from M.M examples on intuition

ok	move.l	#MEMF_CHIP,d1	type of mem
	CALLEXEC	AvailMem		how much is free?
	move.l	d0,d7		store free chip

	move.l	#MEMF_FAST,d1	type of mem
	CALLEXEC	AvailMem		how much is free?
	add.l	d7,d0		add free chip to this

	move.l	d0,DataStream	and store value
		
	lea	Template,a0		format string
	lea	DataStream,a1	data
	lea	PutChar,a2		subroutine
	lea	Text,a3		buffer
	CALLEXEC	RawDoFmt		create text string

	moveq.l	#1,d0		no errors

.error	rts

PutChar	move.b		d0,(a3)+	save next character
	rts			and return


;-----------Open the main window with attached gadgets.

openwin	lea	mainwindow,a0	;window struct
	CALLINT	OpenWindow		;open the window
	move.l	d0,wd_ptr		;save window pointer
	rts
	
;-----------Routine to attach logo graphics to main window

Graphics	move.l	wd_ptr,a0
	move.l	wd_RPort(a0),a0
	lea	red,a1
	move.l	#200,d0
	move.l	#15,d1
	CALLINT	DrawImage
	
	lea	WinText,a1
	move.l	wd_ptr,a0
	move.l	wd_RPort(a0),a0
	move.l	#450,d0
	moveq.l	#13,d1
	CALLINT	PrintIText
	rts
	
;-----------This routine waits for gadget select and branches to
;	a routine which finds out which was selected

wait_for_msg
	move.l	wd_ptr,a0
	move.l	wd_UserPort(a0),a0	;a0 holds address of userport
	CALLEXEC	WaitPort		;wait for something to happen
	move.l	wd_ptr,a0		;window pointer
	move.l	wd_UserPort(a0),a0
	CALLEXEC	GetMsg		;any messages
	tst.l	d0		;was there any
	beq.s	wait_for_msg	;if not loop
	move.l	d0,a1		;a1 holds message
	move.l	im_Class(a1),d2	;d2 holds IDCMP
	move.l	im_IAddress(a1),a2
	CALLEXEC	ReplyMsg		;answer o/s or it will cry
	cmp.l	#CLOSEWINDOW,d2	;window closed ?
	beq	quitreq		;display quit requester
	cmp.l	#GADGETUP,D2	;gadget selected ?
	beq.s	go_gadget		;find out which one
	bra.s	wait_for_msg	;loop


;-----------Find out which gadg was selected below

go_gadget
	move.l	gg_UserData(a2),a0
	cmpa.l	#0,a0
	beq.s	wait_for_msg
	
	jmp	(a0)

;-----------include the loader here,this is to keep the 
;	program readable
 
	include	"select-loader.i"

;-----------Routine to close main window and bring up sleep window

	
snooze	move.l	wd_ptr,a0		;main win struct ptr
	CALLINT	CloseWindow		;close main window
	
	lea	sleepwindow,a0	;sleep win struct in a0
	CALLINT	OpenWindow		;open sleep window
	move.l	d0,sleep_ptr	;save sleep ptr
	beq	error2		;test for error
	
;-----------Sleep wait for message routine 

sleepwait
	move.l	sleep_ptr,a0	;
	move.l	wd_UserPort(a0),a0	;
	CALLEXEC	WaitPort		;
	move.l	sleep_ptr,a0	;
	move.l	wd_UserPort(a0),a0	;
	CALLEXEC	GetMsg		;
	tst.l	d0		;
	beq	sleepwait		;
	move.l	d0,a1		;
	move.l	im_Class(a1),d2	;
	CALLEXEC	ReplyMsg		;
	cmp.l	#CLOSEWINDOW,d2	;
	beq	closesleep		;
	cmp.l	#ACTIVEWINDOW,D2	;
	beq	sleepactive		;
	bra.s	sleepwait		;
				
closesleep
	move.l	sleep_ptr,a0	;
	CALLINT	CloseWindow		;
				
	bra	closelib		;tidy up
	
sleepactive				
	btst	#10,$dff016		;Right mouse pressed
	beq	end_sleep		;Yes end sleep
	move.l	sleep_ptr,a0	;No continue
	move.l	wd_UserPort(a0),a0	;
	CALLEXEC	GetMsg		;
	tst.l	d0		;test for any message
	bne	readmsg		;which was it
	bra	sleepactive		;loop
	
readmsg
	move.l	d0,a1
	move.l	im_Class(a1),d2
	CALLEXEC	ReplyMsg
	cmp.l	#CLOSEWINDOW,d2
	beq	closesleep
	cmp.l	#INACTIVEWINDOW,d2
	beq	sleepwait
	bra	sleepactive
	
end_sleep
	move.l	sleep_ptr,a0
	CALLINT	CloseWindow
	
	bra	main

;-----------This is the routine to display the about window which was
;	selected by the about gadget


disp_about	lea	about_window,a0	;window address
	CALLINT	OpenWindow		;open it
	move.l	d0,about_ptr	;store ptr
	beq	abt_err		;shit error
	lea	about_text,a1	;message in a bottle 
	move.l	about_ptr,a0	;get ptr
	move.l	wd_RPort(a0),a0	;get window rasterport
	moveq.l	#5,d0		;x pos text
	moveq.l	#20,d1		;y pos text
	CALLINT	PrintIText 		;lets do it
wait_about	btst	#10,$dff016		;wait for msg
	bne	wait_about
	move.l	about_ptr,a0	;not again
	CALLINT	CloseWindow		;sob sob byeeeeeeee
abt_err	bra	wait_for_msg	;back to the future

;-----------Close libraries

intclose	move.l	_IntuitionBase,a1	;close intuition
	CALLEXEC	CloseLibrary
	rts
	
closedos	move.l	_DOSBase,a1		;close dos
	CALLEXEC	CloseLibrary
	rts
	

;-----------This displays quit requester and waits for click
;	then acts according to input


quitreq	move.l	wd_ptr,a0		;ptr to window
	lea	body,a1		;req boby
	lea	left,a2		;req left text
	lea	right,a3		;req right text
	moveq.l	#0,d0
	move.l	d0,d1
	move.l	#250,d2		;width
	moveq.l	#70,d3		;height
	CALLINT	AutoRequest		;do it
	tst.l	d0		;whats it to be?
	beq.s	dont_quit		;cont here
	bne.s	exit		;quit here
dont_quit	bra	wait_for_msg	;cont then loop


;-----------Exit from here

	
exit
	move.l	wd_ptr,a0		;window ptr
	CALLINT	CloseWindow
	
closelib	bsr	intclose
	bra	closedos
	

;-----------Main window structure

	SECTION Display_data,DATA

mainwindow
	dc.w	0,0		;x,y start position
	dc.w	640,256		;width and height
	dc.b	0,1		;detail and block pens
	dc.l	CLOSEWINDOW+GADGETUP	;idcmp flags
	dc.l	WINDOWCLOSE+WINDOWDEPTH+ACTIVATE+NOCAREREFRESH+SMART_REFRESH
	dc.l	Gadgetlist1		;first gadget in list
	dc.l	NULL		;custom CHECKMARK imagary
	dc.l	maintitle		;window title name
	dc.l	NULL		;custom screen pointer
	dc.l	NULL		;custom bitmap
	dc.w	640,256		;min size
	dc.w	640,256		;max size
	dc.w	WBENCHSCREEN	;dest screen type
maintitle
	dc.b	'Redline Utils V1.0 22/7/91 © MENU CODED BY ALADDIN SANE ',0
	even

;-----------Sleep window structure

sleepwindow
	dc.w	300,15		;x,y start position
	dc.w	250,20		;width and height
	dc.b	0,1		;detail and block pens
	dc.l	CLOSEWINDOW+ACTIVEWINDOW+INACTIVEWINDOW	;idcmp flags
	dc.l	WINDOWCLOSE+WINDOWDEPTH+ACTIVATE+NOCAREREFRESH+SMART_REFRESH
	dc.l	NULL		;first gadget in list
	dc.l	NULL		;custom CHECKMARK imagary
	dc.l	sleeptitle		;window title name
	dc.l	NULL		;custom screen pointer
	dc.l	NULL		;custom bitmap
	dc.w	5,5		;min size
	dc.w	200,10		;max size
	dc.w	WBENCHSCREEN	;dest screen type
sleeptitle
	dc.b	'Redline Utils V1.0',0
	even

;-----------About window structure

about_window:
	dc.w	200,42	;x,y start position
	dc.w	250,130	;width and height
	dc.b	0,1	;detail and block pens
	dc.l	NULL	;idcmp flags
	dc.l	WINDOWDRAG+ACTIVATE
	dc.l	NULL	;first gadget in list
	dc.l	NULL	;custom CHECKMARK imagary
	dc.l	About_title	;window title name
	dc.l	NULL	;custom screen pointer
	dc.l	NULL	;custom bitmap
	dc.w	5,5	;min size
	dc.w	300,150	;max size
	dc.w	WBENCHSCREEN	;dest screen type
About_title:
	dc.b	'About Redline Utils',0
	even

;-----------Quit requester structure

body	dc.b	2,2		;colours
	dc.b	0		;mode normal
	even
	dc.w	60,10		;text position
	dc.l	0		;standard font
	dc.l	b_text		;ptr to text
	dc.l	NULL		;end of text
b_text	dc.b	'ARE YOU SURE',0
	even
	
left	dc.b	2,2
	dc.b	0
	even
	dc.w	5,3
	dc.l	0
	dc.l	l_text
	dc.l	0
l_text	dc.b	'QUIT',0
	even
		
right	dc.b	2,2
	dc.b	0
	even
	dc.w	5,3
	dc.l	0
	dc.l	r_text
	dc.l	0
r_text	dc.b	'CONT' ,0
	even

;-----------Gadgets structures included as seperate file because
;	source was becoming messy with structures.Each gadget
;	has two border structures to give them a 3D effect
;	it took me a day to work these out.have a look at
;	gadget structures to see how it is done.
	
	
	include	"select-gadgets.i"	
	
;-----------Output lines text structure for about window

about_text	
text1	dc.b	3,0,RP_JAM2,0	;
	dc.w	45,0
	dc.l	NULL
	dc.l	line1
	dc.l	text2
	
line1	dc.b	'Redline Inc.1991',0
	even

text2	dc.b	1,0,RP_JAM2,0	;
	dc.w	20,10
	dc.l	NULL
	dc.l	line2
	dc.l	text3
	
line2	dc.b	'Present Mega Utils V1.0',0
	even
	
text3	dc.b	3,0,RP_JAM2,0	;
	dc.w	30,20
	dc.l	NULL
	dc.l	line3
	dc.l	text4
	
line3	dc.b	'Released on 10/8/91',0
	even

text4	dc.b	3,0,RP_JAM2,0	;
	dc.w	20,30
	dc.l	NULL
	dc.l	line4
	dc.l	text5
	
line4	dc.b	'Leave the run command',0
	even

text5	dc.b	3,0,RP_JAM2,0	;
	dc.w	40,40
	dc.l	NULL
	dc.l	line5
	dc.l	text6
	
line5	dc.b	'in the c/dir or',0
	even

text6	dc.b	3,0,RP_JAM2,0	;
	dc.w	10,50
	dc.l	NULL
	dc.l	line6
	dc.l	text7
	
line6	dc.b	'the programs will not load',0
	even

text7	dc.b	3,0,RP_JAM2,0	;
	dc.w	40,70
	dc.l	NULL
	dc.l	line7
	dc.l	text8
	
line7	dc.b	'Signed',0
	even

text8	dc.b	1,0,RP_JAM2,0	;
	dc.w	60,80
	dc.l	NULL
	dc.l	line8
	dc.l	text9
	
line8	dc.b	'Aladdin Sane',0
	even
	
text9	dc.b	3,0,RP_JAM2,0	;
	dc.w	10,100
	dc.l	NULL
	dc.l	line9
	dc.l	NULL
	
line9	dc.b	'PRESS RIGHT BUTTON TO QUIT',0
	even
	
WinText	dc.b	1,0,RP_JAM2,0	;FrontPen,BackPen,DrawMode
	dc.w	0,0		;x,y position
	dc.l	NULL		;font
OurText	dc.l	Text		;address of text to print
	dc.l	NULL		;no more text

Text	ds.b	100		;the text itself
	even

Template	dc.b	'Free memory : %ld ',0
	even
DataStream	dc.l	0
	


;-----------Logo graphic 

red	dc.w	0,0
	dc.w	230,28
	dc.w	2
	dc.l	reddat
	dc.b	3,0
	dc.l	0
	
	SECTION LOGO,DATA_C

reddat	dc.w	00000,00000,00000,00000,00000,00000,00000,00000
	dc.w	00000,00000,00000,00000,00000,00000,00000,00000
	dc.w	00000,00000,00000,00000,00000,00000,00000,00000
	dc.w	00000,00000,00000,00000,00000,00000,02046,00031
	dc.w	65280,65408,01984,00248,01793,57407,65024,00003
	dc.w	57372,01920,00960,00000,00000,02047,32799,65280
	dc.w	65504,01984,00248,01985,57407,65024,00003,57375
	dc.w	01920,04080,00000,00000,02047,49183,65280,65520
	dc.w	01984,00248,02017,57407,65024,00003,57375,34688
	dc.w	08184,00000,00000,02047,57375,65280,65528,01984
	dc.w	00248,02017,57407,65024,00003,57375,34688,16380
	dc.w	00000,00000,02047,57375,65280,65528,01984,00248
	dc.w	02033,57407,65024,00003,57375,51072,16380,00000
	dc.w	00000,01987,57375,00000,63612,01984,00248,02033
	dc.w	57406,00000,00003,57375,51072,32318,00000,00000
	dc.w	01985,57375,00000,63612,01984,00248,02041,57406
	dc.w	00000,00003,57375,59264,31772,00000,00000,01985
	dc.w	57375,00000,63548,01984,00248,02041,57406,00000
	dc.w	00003,57375,59264,30720,00000,00000,01987,57375
	dc.w	65024,63548,01984,00248,02045,57407,64512,00003
	dc.w	57375,63360,63488,00000,00000,02047,49183,65024
	dc.w	63548,01984,00248,02045,57407,64512,00003,57375
	dc.w	63360,63488,00000,00000,02047,49183,65024,63548
	dc.w	01984,00248,02047,57407,64512,00003,57375,65408
	dc.w	63488,00000,00000,02047,32799,65024,63548,01984
	dc.w	00248,02047,57407,64512,00003,57375,65408,63488
	dc.w	00000,00000,02047,49183,00000,63548,01984,00248
	dc.w	02015,57406,00000,00003,57375,32640,63488,00000
	dc.w	00000,01987,57375,00000,63548,01984,00248,01999
	dc.w	57406,00000,00003,57375,16256,30734,00000,00000
	dc.w	01985,57375,00000,63612,01984,00248,01999,57406
	dc.w	00000,00003,57375,16256,31774,00000,00000,01985
	dc.w	57375,65280,65532,02047,33016,01991,57407,65024
	dc.w	00003,57375,08064,32318,00000,00000,01985,57375
	dc.w	65280,65528,02047,33016,01991,57407,65024,00003
	dc.w	57375,08064,16380,00120,00000,01985,57375,65280
	dc.w	65528,02047,33016,01987,57407,65024,00003,57375
	dc.w	03968,08184,00120,00000,01985,57375,65280,65520
	dc.w	02047,33016,01987,57407,65024,00003,57375,03968
	dc.w	04080,00120,00000,01921,57375,65024,65472,02047
	dc.w	33016,01985,57407,64512,00003,57375,01920,02016
	dc.w	00120,00000,00000,00000,00000,00000,00000,00000
	dc.w	00000,00000,00000,00000,00000,00000,00000,00000
	dc.w	00000,00000,00000,00000,00000,00000,00000,00000
	dc.w	00000,00000,00000,00000,00000,00000,00000,00000
	dc.w	00000,00000,00000,00000,00000,00000,00000,00000
	dc.w	00000,00000,00000,00000,00000,00000,00000,00000
	dc.w	00000,00000,00000,00000,00000,00000,00000,00000
	dc.w	00000,00000,00000,00000,00000,00000,00000,00000
	dc.w	00000,00000,00000,00000,00000,00000,00000,00000
	dc.w	00000,00000,00000,00000,00000,00000,00000,00000
	dc.w	00000,00000,00000,00000,00000,00000,00000,00000
	dc.w	00000,00000,00000,00000
	dc.w	00000,00000,00000,00000,00000,00000,00000,00000
	dc.w	00000,00000,00000,00000,00000,00000,00000,00000
	dc.w	00000,00000,00000,00000,00000,00000,00000,00000
	dc.w	00000,00000,00000,00000,00000,00000,02046,00031
	dc.w	65280,65408,01984,00248,01793,57407,65024,00003
	dc.w	57372,01920,00960,00000,00000,02047,32799,65280
	dc.w	65504,01984,00248,01985,57407,65024,00003,57375
	dc.w	01920,04080,00000,00000,02047,49183,65280,65520
	dc.w	01984,00248,02017,57407,65024,00003,57375,34688
	dc.w	08184,00000,00000,02047,57375,65520,65528,02044
	dc.w	00255,34801,65087,65504,00003,65055,51192,16380
	dc.w	00000,00000,02047,63519,65520,65534,02044,00255
	dc.w	34813,65087,65504,00003,65055,63480,16383,00000
	dc.w	00000,02047,64543,65520,65535,02044,00255,34815
	dc.w	65087,65504,00003,65055,65528,32767,32768,00000
	dc.w	02047,65055,65520,65535,34812,00255,34815,65087
	dc.w	65504,00003,65055,65528,32767,49152,00000,02047
	dc.w	65055,65520,65535,34812,00255,34815,65087,65504
	dc.w	00003,65055,65528,31743,49152,00000,02047,65055
	dc.w	65024,65471,51196,00255,34815,65087,64512,00003
	dc.w	65055,65528,65507,57344,00000,02047,56863,65024
	dc.w	65471,51196,00255,34815,65087,64512,00003,65055
	dc.w	65528,65473,49152,00000,02047,56863,65024,65471
	dc.w	51196,00255,34815,65087,64512,00003,65055,65528
	dc.w	65408,00000,00000,02047,48671,65504,65471,51196
	dc.w	00255,34815,65087,65472,00003,65055,65528,65408
	dc.w	00000,00000,02047,64543,65504,65471,51196,00255
	dc.w	34815,65087,65472,00003,65055,65528,65408,00000
	dc.w	00000,02047,63519,65504,65471,51196,00255,34815
	dc.w	65087,65472,00003,65055,65528,32654,00000,00000
	dc.w	02047,63519,65504,65535,51196,00255,34815,65087
	dc.w	65472,00003,65055,65528,32670,00000,00000,02047
	dc.w	64543,65280,65535,51199,33023,34815,65087,65024
	dc.w	00003,65055,65528,32702,00000,00000,02045,65055
	dc.w	65280,65531,51199,33023,34815,65087,65024,00003
	dc.w	65055,65528,16380,57464,00000,02045,65055,65280
	dc.w	65535,51199,33023,34815,65087,65024,00003,65055
	dc.w	65528,08185,57464,00000,02045,65055,65520,65535
	dc.w	51199,63743,34815,65087,65504,00003,65055,65528
	dc.w	04083,57464,00000,02045,65055,65520,65535,34815
	dc.w	63743,34813,65087,65504,00003,65055,63480,02047
	dc.w	49279,32768,00124,07681,65520,04095,32895,63503
	dc.w	32892,15875,65504,00000,15873,61688,00511,32775
	dc.w	32768,00124,07681,65520,04095,00127,63503,32892
	dc.w	15875,65504,00000,15873,61688,00255,00007,32768
	dc.w	00120,07681,65504,04092,00127,63503,32892,07683
	dc.w	65472,00000,15873,61560,00126,00007,32768,00000
	dc.w	00000,00000,00000,00000,00000,00000,00000,00000
	dc.w	00000,00000,00000,00000,00000,00000,00000,00000
	dc.w	00000,00000,00000,00000,00000,00000,00000,00000
	dc.w	00000,00000,00000,00000,00000,00000,00000,00000
	dc.w	00000,00000,00000,00000,00000,00000,00000,00000
	dc.w	00000,00000,00000,00000
	


	SECTION DATA,DATA

;-----------Enter commands to be executed here.

command1:	dc.b	"",0 
command2:	dc.b	"Redline-Utils:Redline/Deluxe-Paint",0
command3:	dc.b	"Redline-Utils:Redline/Brushcon",0
command4:	dc.b	"Redline-Utils:Redline/Iff-converter",0
command5:	dc.b	"Redline-Utils:Redline/Iffmaster",0
command6:	dc.b	"Redline-Utils-2:3rdday",0
command7:	dc.b	"redline-utils-2:tgr",0
command8:	dc.b	"redline-utils-2:mod_processor",0
command9:	dc.b	"redline-utils:redline/reset60hz-II",0
command10:	dc.b	"",0
command11:	dc.b	"redline-utils:c/ppmore cli.txt",0
command12:	dc.b	"redline-utils:c/ppmore cli.txt",0
command13:	dc.b	"redline-utils:c/ppmore cli.txt",0
command14:	dc.b	"redline-utils:c/ppmore cli.txt",0
command15:	dc.b	"redline-utils:c/ppmore cli2.txt",0
command16:	dc.b	"redline-utils:c/ppmore redline-utils-2:dc.bconverter.doc",0
command17:	dc.b	"redline-utils:c/ppmore cli2.txt",0
command18:	dc.b	"redline-utils:c/ppmore cli2.txt",0
command19:	dc.b	"",0
command20:	dc.b	"redline-utils:redline/disk-master",0
command21:	dc.b	"redline-utils:redline/fix-disk",0
command22:	dc.b	"redline-utils:redline/setkey",0
command23:	dc.b	"redline-utils:redline/tx-ed",0
command24:	dc.b	"redline-utils:redline/diskx",0
command25:	dc.b	"redline-utils:redline/newzap",0
command26:	dc.b	"redline-utils-2:preferences",0
command27:	dc.b	"redline-utils-2:x-copy",0
command28:	dc.b	"redline-utils:redline/d-copy",0
command29:	dc.b	"",0
command30:	dc.b	"redline-utils:redline/power-packer",0
command31:	dc.b	"redline-utils:redline/imploder.turbo",0
command32:	dc.b	"",0
command33:	dc.b	"redline-utils:redline/virusexpert",0
command34:	dc.b	"redline-utils:redline/virus-x",0
command35:	dc.b	"",0
command36:	dc.b	"redline-utils:redline/artm",0
command37:	dc.b	"redline-utils-2:xoper",0
command38:	dc.b	"",0
command39:	dc.b	"redline-utils:c/ppmore redline-utils-2:greets.txt",0
command40:	dc.b	"redline-utils:c/ppmore redline-utils-2:powerpacker.doc",0
command41:	dc.b	"redline-utils-2:3rdday.info",0
command42:	dc.b	"redline-utils:c/ppmore redline-utils-2:quickram.doc",0
	
;-----------Variable store


intname	dc.b	'intuition.library',0
	even
dosname	dc.b	'dos.library',0
	even
_DOSBase	dc.l	0
_IntuitionBase	dc.l	0
wd_ptr	dc.l	0
sleep_ptr	dc.l	0	
about_ptr	dc.l	0

	end		;Well did that make any sense
			;cos I'm lost.
	
