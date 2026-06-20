***************************************************************************
*
*	Assembler AppWindow  and  AppIcon  Demonstration program 
*
*		    Requires KickStart V2.00 or higher
*
*		By Steve Marshall  for the Amiga Coders Club
*
*		Source code is public domain, use as you wish.
*
*			Compiles with Devpac V3.02
*
*	(I hate people who release demo source code then say that
*	you can't use it in your own programs without permission.
*	What is the point? Personal ego trip perhaps?)		
*
***************************************************************************



	incdir	sys:include2.0/
	include exec/exec.i
	include exec/exec_lib.i

	include libraries/dos.i
	include libraries/dosextens.i
	include libraries/dos_lib.i

	include graphics/gfxbase.i
	include	graphics/graphics_lib.i

	include intuition/intuition.i
	include intuition/intuition_lib.i

;	include	devices/console_lib.i
;	include devices/inputevent.i


	include		workbench/wb_lib.i
	include		workbench/workbench.i
	include		workbench/icon_lib.i
	include		graphics/gfxbase.i
	
	include		'misc/easystart.i'	;WBench + Cli startup


BuffSize	equ		2000		
NULL		equ		0

;===========================================================================
CALLSYS	MACRO
	IFGT	NARG-1		 
	FAIL	!!!		   
	ENDC
	JSR	_LVO\1(A6)
	ENDM
;===========================================================================
		
	bsr		OpenLibs		;open system libraries
	tst.l		d0			;check all opened
	beq.s		LibError		;branch on error
	
	bsr		OpenWindow		;open window and make App
	tst.l		d0			;test result
	beq.s		WindowError		;branch on error
	
	bsr		CreateAppIcon		;make an AppIcon for WB
	tst.l		d0			;test result
	beq.s		IconError		;branch on error
	
	bsr.s		GetMessage		;get and process messages
	
IconError
	bsr		DeleteAppIcon		;cleanup icon stuff
	
WindowError
	bsr		CloseWindow		;cleanup window stuff
	
LibError
	bsr		CloseLibs		;close all opened libraries
	
	moveq		#0,d0			;return no error
	rts
	
;---------------------------------------------------------------------------

GetMessage
 	move.l 		WindowSig(a5),d0	;get window signal
 	or.l		AppSignal(a5),d0	;or App signal
 	CALLEXEC 	Wait			;wait for signals
 	
 	cmp.l		WindowSig(a5),d0	;was it a window message
 	bne.s		AppEvent		;if not must be AppIcon/Window

;------ get the message - must be closewindow (only IDCMP specified)
  	move.l		WindowPort(a5),a0	;get port
  	CALLSYS		GetMsg			;get message from port
  	
  	move.l		d0,a1			;message
  	CALLSYS		ReplyMsg		;reply it
  	rts					;end of getmessage

;---------------------------------------------------------------------------

;------	We will define a constant for both icon and window events
;	note that we could check each individual type and act accordingly.

AppMessages	equ	MTYPE_APPWINDOW|MTYPE_APPICON

AppEvent
	move.l		MsgPort(a5),a0		;AppPort
	CALLSYS		GetMsg			;get message
	
	move.l		d0,a4			;message in a4
	move.w		am_Type(a4),d0		;get AppEvent Type
	or.w		#AppMessages,d0		;was it appwindow or appicon
	beq.s		NotApp			;branch if not appevent
	
	move.l		am_NumArgs(a4),d0	;get num of args
	beq		NotApp			;branch if doubleclick (ignore)
	move.l		am_ArgList(a4),a0	;get arglist
	
;------	Note that we don't reply the message until we have finished
;	with it. This is because we are using parts of the message.
;	For example locks. If we replied the message these would no
;	longer be valid.

	bsr.s		ProcessArgs
	
NotApp
	move.l		a4,a1			;message
	CALLEXEC	ReplyMsg		;reply it
	bra.s		GetMessage		;loop back for another message
			
;---------------------------------------------------------------------------

ProcessArgs
	movem.l		d5-d7/a2-a3,-(sp)	;save regs
	move.l		a0,a3			;save arglist
	move.l		d0,d7			;save numargs
	
	lea		Buffer(a5),a2		;buffer address

ArgLoop	
	move.l		(a3)+,d1		;get lock
	move.l		a2,d2			;buffer
	move.l		#200,d3			;buffer length
	CALLDOS		NameFromLock		;create full qualified pathname
	
	move.l		a2,d1			;dir
	move.l		(a3)+,d2		;file
	move.l		#200,d3			;size
	CALLSYS		AddPart			;append name
	
	move.l		a2,d1			;name
	move.l		#MODE_OLDFILE,d2	;mode
	CALLSYS		Open			;open file
	move.l		d0,d5			;save file handle
	beq.s		NotOpened		;branch if not opened
	
	moveq		#0,d1			;no flags
	jsr		LoadILBM		;load IFF ILBM file
	tst.l		d0			;test result
	beq.s		GFXError		;branch on error
	
	move.l		d0,-(sp)		;store bitmap
	bsr.s		Display			;display picture
	move.l		(sp)+,d0		;get bitmap
	jsr		CleanupGraf		;and free it

GFXError
	move.l		d5,d1			;filehandle
	CALLSYS		Close			;close file
		
NotOpened
	subq.l		#1,d7			;decrement args
	bne.s		ArgLoop			;branch till done
	
	movem.l		(sp)+,d5-d7/a2-a3	;restore regs
	rts

;---------------------------------------------------------------------------

;-------------- Create Viewport and display picture

Display
	movem.l		d2-d3/a2-a6,-(sp)	;save regs
	move.l		d0,a3			;ilbm struct in a5
	lea		MyView(a5),a1		;get our view
	CALLGRAF	InitView		;and initialise it
	
	lea		ViewPort1(a5),a4	;get first viewport
	move.l		a4,a0			;get first viewport
	CALLSYS		InitVPort		;initialise 2nd viewport
	
	lea		MyView(a5),a1		;get our view
	move.w		ilbm_Modes(a3),v_Modes(a1) ;set view modes
	move.w		ilbm_Modes(a3),vp_Modes(a4);set viewport modes
	move.l		a4,(a1)			;and link to view
	
	moveq		#32,d0			;number of colours
	CALLSYS		GetColorMap		;get colourmap
	move.l		d0,vp_ColorMap(a4)	;store colormap
	
	move.l		gb_ActiView(a6),OldView(a5) ;save old view

;------	This next piece of code attemts to centre the piture on screen
	
	move.w		ilbm_Width(a3),d0	;get width
	move.w		ilbm_Modes(a3),d1	;get mode
	btst		#15,d1			;test for lo-res
	beq.s		Lores			;branch if lo-res
	
	move.w		#640,d2			;std hi-res width
	sub.w		d0,d2			;subtract pic width
	cmpi.w		#-64,d2			;cmp with overscan
	bge.s		Xoffsetdone		;branch if not greater
	moveq		#-64,d2			;set to overscan
	bra.s		Xoffsetdone		;branch always
Lores
	move.w		#320,d2			;std lo-res width 
	sub.w		d0,d2			;subtract pic width
	cmpi.w		#-32,d2			;cmp with overscan
	bge.s		Xoffsetdone		;branch if greater
	moveq		#-32,d2			;set to overscan		
	
Xoffsetdone	
	asr.w		#1,d2			;divide by 2
	move.w		d2,vp_DxOffset(a4)	;set vp X offset
	
	move.w		ilbm_Height(a3),d0	;get height
	btst		#2,d1			;test for interlace
	beq.s		NoLace			;branch if not interlace
	
	move.w		gb_NormalDisplayRows(a6),d2 ;set max height
	add.w		d2,d2			;correct for interlace
	cmp.w		d2,d0			;is picture larger
	blt.s		NoOffset		;branch if not
	sub.w		d0,d2			;subtract height
	bra.s		Yoffsetdone		;branch always
NoLace
	move.w		gb_NormalDisplayRows(a6),d2 ;set max height
	cmp.w		d2,d0			;is picture larger
	blt.s		NoOffset		;branch if not
	sub.w		d0,d2			;subtract height
	bra.s		Yoffsetdone		;branch always
	
NoOffset
	moveq		#0,d2			;set no offset
	
Yoffsetdone	
	asr.w		#1,d2			;divide by 2
	move.w		d2,vp_DyOffset(a4)	;set vp Y offset

;------	Next we make sure the picture is not too large to display
	
	move.w		ilbm_Width(a3),d1	;get width
	move.w		ilbm_Modes(a3),d0	;get modes
	btst		#15,d0			;test hi-res
	bne.s		.Hires			;branch on hi-res
	cmpi.w		#352,d1			;cmp width with overscan
	bls.s		.WidthOK		;branch if less or equal 
	move.w		#352,d1			;set to overscan width
	bra.s		.WidthOK		;branch always

.Hires
	cmpi.w		#704,d1			;cmp width with overscan
	bls.s		.WidthOK		;branch if less or equal 
	move.w		#704,d1			;set to overscan width
.WidthOK
	move.w		d1,vp_DWidth(a4)	;set viewport width
	
	move.w		ilbm_Height(a3),d1	;get height
	btst		#2,d0			;test for interlace
	bne.s		.Lace			;branch if interlace
	
	cmpi.w		#290,d1			;cmp with nonlace overscan
	bls.s		.HeightOK		;branch if less or equal 	
	move.w		#290,d1			;set to overscan height
	bra.s		.HeightOK		;branch always
.Lace
	cmpi.w		#580,d1			;cmp with lace overscan
	bls.s		.HeightOK		;branch if less or equal 
	move.w		#580,d1			;set to lace overscan height
.HeightOK	
	move.w		d1,vp_DHeight(a4)	;set viewport height

;------	Attach the bitmap to rasinfo and the rasinfo to the viewport

	lea		MyRasinfo1(a5),a1	;get 1st rasinfo
	move.l		a1,vp_RasInfo(a4)	;and place in viewport
	 
	move.l		a3,ri_BitMap(a1)	;store bitmap in rasinfo
	
;------	Make view viewport then display
	
	lea		MyView(a5),a0		;get view
	move.l		a4,a1			;get first viewport
	CALLSYS		MakeVPort		;make viewports
	
	lea		MyView(a5),a1		;get view
	CALLSYS		MrgCop			;merge copper lists
	
	lea		MyView(a5),a1		;get view
	CALLSYS		LoadView		;display viewports
	
	move.l		a4,a0			;get first viewport
	move.l		ilbm_ColorMap(a3),a1	;get colourmap
	move.w		(a1)+,d0		;d0 = number of colours
	CALLSYS		LoadRGB4		;set colours

;------ Wait for 10 seconds
	
	move.l		#10*50,d1		;d1=time in 1/50 seconds
	CALLDOS		Delay			;call delay routine
	
;------	Restore screen then clean up
	
	move.l		OldView(a5),a1		;get old view
	CALLGRAF	LoadView		;restore screen
	
	move.l		a4,a0			;get first viewport
	move.l		vp_ColorMap(a0),d2	;save colormap
	CALLSYS		FreeVPortCopLists	;free copper lists
	
	lea		MyView(a5),a0		;get view
	move.l		v_SHFCprList(a0),d3	;save short frame
	move.l		v_LOFCprList(a0),a0	;set long frame
	CALLSYS		FreeCprList		;free copper list
	move.l		d3,a0			;get short frame
	CALLSYS		FreeCprList		;free copper list
	
	move.l		d2,a0			;get colormap
	CALLSYS		FreeColorMap		;and free it
	
	movem.l		(sp)+,d2-d3/a2-a6	;restore regs
	rts

;---------------------------------------------------------------------------

OpenLibs
	moveq		#36,d0			;lib version
	lea		dosname,a1		;lib name
	CALLEXEC	OpenLibrary		;open lib
	move.l		d0,_DOSBase		;save result
	beq.s		.liberror		;branch on error
	
	moveq		#36,d0			;lib version
	lea		grafname,a1		;lib name
	CALLEXEC	OpenLibrary		;open lib
	move.l		d0,_GfxBase		;save result
	beq.s		.liberror		;branch on error

	moveq		#36,d0			;lib version
	lea		intname,a1		;lib name
	CALLEXEC	OpenLibrary		;open lib
	move.l		d0,_IntuitionBase	;save result
	beq.s		.liberror		;branch on error
	
	moveq		#36,d0			;lib version
	lea		wbenchname,a1		;lib name
	CALLEXEC	OpenLibrary		;open lib
	move.l		d0,_WorkbenchBase	;save result
 
.liberror
	rts
	
;---------------------------------------------------------------------------

CloseLibs
	move.l		4.w,a6			;execbase for CloseLibrary
	
	move.l		_WorkbenchBase,d0	;get lib base
	bsr.s		CloseIt			;try to close it

	move.l		_IntuitionBase,d0	;get lib base
	bsr.s		CloseIt			;try to close it
	
	move.l		_GfxBase,d0		;get lib base
	bsr.s		CloseIt			;try to close it
	
	move.l		_DOSBase,d0		;get lib base
	bsr.s		CloseIt			;try to close it
	
	rts					;end of CloseLibs
	
CloseIt
	beq.s		NoLib			;branch if no lib 
	move.l		d0,a1			;lib base in correct reg
	CALLSYS		CloseLibrary		;close lib

NoLib
	rts					;end of CloseIt
	
;---------------------------------------------------------------------------

OpenWindow
	lea		Variables,a5		;pointer to variable block
	
	CALLEXEC	CreateMsgPort		;get a port
	move.l		d0,MsgPort(a5)		;save port
	beq.s		wdwError		;branch on error
	
	move.l		d0,a1			;port
	moveq		#0,d0			;clear d0
	moveq		#0,d1			;clear d1
	move.b		MP_SIGBIT(a1),d1	;get signal
	bset		d1,d0			;change bit num to mask
	move.l		d0,AppSignal(a5)	;save mask
	
	sub.l		a0,a0			;no newwindow struct
	lea		WindowTags,a1		;window tag list
	CALLINT		OpenWindowTagList	;open window
	move.l		d0,MyWindow(a5)		;save window
	beq.s		wdwError		;branch on error

	move.l		d0,a0			;window
	move.l		wd_UserPort(a0),a1	;get port
	moveq		#0,d0			;clear d0
	moveq		#0,d1			;clear d1
	move.b		MP_SIGBIT(a1),d1	;get signal
	bset		d1,d0			;change bit num to mask
	move.l		d0,WindowSig(a5)	;save mask
	move.l		a1,WindowPort(a5)	;save port
	
	moveq		#1,d0			;id
	moveq		#0,d1			;UserData
	move.l		MsgPort(a5),a1		;port
	sub.l		a2,a2			;taglist (not implemented)
	move.l		_WorkbenchBase,a6	;get lib base
	CALLSYS		AddAppWindowA		;add app window to WBench
	move.l		d0,MyAppWindow(a5)	;save result

wdwError
	rts	
	
;---------------------------------------------------------------------------

CloseWindow
	move.l		MyAppWindow(a5),d0	;get appwindow
	beq.s		noappwindow		;branch if none
	move.l		d0,a0			;appwindow in a0
	move.l		_WorkbenchBase,a6	;get lib base
	CALLSYS		RemoveAppWindow		;and remove it

noappwindow
	move.l		MsgPort(a5),d0		;get message port
	beq.s		noport			;branch if none
	move.l		d0,a0			;port in ao
	CALLEXEC	DeleteMsgPort		;and delete it
	
noport
	move.l		MyWindow(a5),d0		;get window
	beq.s		nowindow		;branch if no window
	move.l		d0,a0			;window in a0
	CALLINT		CloseWindow		;and close it
	
nowindow
	rts

;---------------------------------------------------------------------------

CreateAppIcon
	moveq		#2,d0			;id
	moveq		#0,d1			;UserData
	lea		AppIconText,a0		;icon name
	move.l		MsgPort(a5),a1		;port
	sub.l		a2,a2			;Lock (should be null)
	lea		DiskObj,a3		;disk Object
	sub.l		a4,a4			;taglist (not implemented)
	move.l		_WorkbenchBase,a6	;get lib base
	CALLSYS		AddAppIconA		;add app icon to WBench
	move.l		d0,MyAppIcon(a5)	;save result
	rts
	
;---------------------------------------------------------------------------

DeleteAppIcon
	move.l		MyAppIcon(a5),d0
	beq.s		NoIcon
	
	move.l		d0,a0
	move.l		_WorkbenchBase,a6	;get lib base
	CALLSYS		RemoveAppIcon		;remove app icon from WBench

NoIcon
	rts
	
*****************************************************************************
;		Include IFF code
*****************************************************************************

	include	ILBM.Code.s
	
****************************************************************************	
	SECTION	Constants,DATA
****************************************************************************	

dosname
	DOSNAME
	
grafname
	GRAFNAME

intname
	INTNAME
	
wbenchname
	dc.b	'workbench.library',0
	EVEN
	
AppIconText
	dc.b	'Demo AppIcon',0
	EVEN
		
WindowTags
	dc.l	WA_Left,50
	dc.l	WA_Top,50
	dc.l	WA_Width,400
	dc.l	WA_Height,100
	dc.l	WA_Flags,WINDOWDRAG|WINDOWDEPTH|WINDOWCLOSE
	dc.l	WA_IDCMP,CLOSEWINDOW
	dc.l	WA_Title,WdwTitle
	dc.l	WA_Zoom,ZoomData
	dc.l	TAG_DONE
	
ZoomData
	dc.w	400,0
	dc.w	180,11
	
WdwTitle
	dc.b	'AppWindow',0
	EVEN	

IconWidth	equ	132
IconHeight	equ	40

DiskObj:	
	dc.w	NULL
	dc.w	NULL
	
	;Gadget structure
	
	dc.l	NULL		only gadget in list
	dc.w	0,0,IconWidth,IconHeight left, top, width, height
  	dc.w	NULL		general flags
	dc.w	NULL		activation flags
  	dc.w	NULL		type
	dc.l	Icon0_image	pointer to primary image
	dc.l	NULL		pointer to selected image 
	dc.l	NULL		pointer to IntuiText
	dc.l	NULL		mutual exclude bit field
	dc.l	NULL		no special info for a boolean gadget
	dc.w	NULL		gadget ID
	dc.l	NULL		no known user data
	
	dc.w	NULL		icon type
	dc.l	NULL		default tool (Not Applicable)
	dc.l	NULL		pointer to tooltypes array
	dc.l	NO_ICON_POSITION   x pos     (doesn't live anywhere
	dc.l	NO_ICON_POSITION   y pos      in paticular)
	dc.l	NULL		drawer data (None)
	dc.l	NULL		tool window (None)
	dc.l	NULL		stacksize (use default)
	
	
Icon0_image:

	dc.w	0,0     	left, top
	dc.w	IconWidth,IconHeight,2	width, height, depth 
	dc.l	Icon0_data	image data
	dc.b	3,NULL	   	plane pick, plane on/off
	dc.l	NULL    	next image 

****************************************************************************	
	SECTION	IconData,DATA_C
****************************************************************************	

;Icon Data - Yep! I know it's crap

Icon0_data:
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$7E00,$0000,$007E
	dc.w	$0000,$0000,$0000,$07FF,$8000,$0003,$D9E0,$0000
	dc.w	$03D9,$E000,$0000,$0000,$06DF,$8000,$001C,$FCBC
	dc.w	$0000,$1CFC,$BC00,$0000,$0000,$0DBA,$4000,$0033
	dc.w	$B1AE,$0000,$33B1,$AE00,$0000,$0000,$0F6F,$C000
	dc.w	$00E0,$CDDF,$0000,$E0CD,$DF00,$0000,$0000,$167E
	dc.w	$A000,$01C8,$EC5C,$8001,$C8EC,$5C80,$0000,$0000
	dc.w	$157F,$E000,$02DA,$9D0E,$8002,$DA9D,$0E80,$0000
	dc.w	$0000,$17BA,$D000,$05FF,$FAF1,$4005,$FFFA,$F140
	dc.w	$0000,$0000,$3FCE,$7000,$06DF,$A2DD,$6006,$DFA2
	dc.w	$DD60,$0000,$0000,$3797,$6800,$0EDF,$2273,$F00E
	dc.w	$DF22,$73F0,$0000,$0000,$6FD3,$C800,$0ADD,$80C5
	dc.w	$700A,$DD80,$C570,$0000,$0000,$FEFB,$F800,$07CF
	dc.w	$0055,$4807,$CF00,$5548,$0000,$0000,$7D9B,$FC00
	dc.w	$0DDA,$002F,$B00D,$DA00,$2FB0,$0000,$0000,$FEF6
	dc.w	$EC00,$1FFE,$0024,$081F,$FE00,$2408,$0000,$0000
	dc.w	$FDAD,$2E00,$1BB6,$0000,$001B,$B600,$0000,$0000
	dc.w	$0000,$7999,$8200,$0FBC,$0000,$000F,$BC00,$0000
	dc.w	$0000,$0000,$FF9E,$4D00,$1FAC,$0000,$001F,$AC00
	dc.w	$0000,$0000,$0001,$FC0D,$EF00,$1EEC,$0000,$001E
	dc.w	$EC00,$0000,$0000,$0003,$9F0D,$BF80,$1BFC,$0000
	dc.w	$001B,$FC00,$0000,$0000,$0002,$F70D,$7780,$1C78
	dc.w	$0000,$001C,$7800,$0000,$0000,$0003,$FFFD,$7F80
	dc.w	$0FFC,$0000,$000F,$FC00,$0000,$0000,$0007,$E6CD
	dc.w	$2BC0,$13F8,$0000,$0013,$F800,$0000,$0000,$0006
	dc.w	$8FEC,$1DC0,$0FBC,$0000,$000F,$BC00,$0000,$0000
	dc.w	$0003,$F6BB,$EE20,$1F6C,$003F,$FE1F,$6C00,$3FFE
	dc.w	$0000,$000B,$DEAF,$F1E0,$053A,$0037,$BE05,$3A00
	dc.w	$37BE,$0000,$001B,$F178,$FFD0,$0E7E,$007B,$EA0E
	dc.w	$7E00,$7BEA,$0000,$001E,$FF05,$FDB0,$054F,$80F3
	dc.w	$FC05,$4F80,$F3FC,$0000,$003D,$FDA3,$F310,$05E3
	dc.w	$E3F6,$2C05,$E3E3,$F62C,$0000,$0033,$3E90,$94F8
	dc.w	$067F,$7EE5,$7806,$7F7E,$E578,$0000,$005F,$C600
	dc.w	$73F8,$03FF,$BDBD,$A003,$FFBD,$BDA0,$0000,$005B
	dc.w	$BC00,$7E1C,$017F,$BF3D,$E001,$7FBF,$3DE0,$0000
	dc.w	$0030,$2C00,$1764,$00E0,$E579,$4000,$E0E5,$7940
	dc.w	$0000,$00F6,$4800,$1092,$0052,$5BD6,$8000,$525B
	dc.w	$D680,$0000,$01D1,$E800,$30C6,$003D,$F99E,$0000
	dc.w	$3DF9,$9E00,$0000,$01DE,$9000,$15EF,$000D,$7318
	dc.w	$0000,$0D73,$1800,$0000,$0000,$1000,$2001,$0000
	dc.w	$B400,$0000,$00B4,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0100,$0000,$0001,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$1000,$0000,$0010
	dc.w	$0000,$0000,$0000,$0400,$0000,$0001,$6E40,$0000
	dc.w	$016E,$4000,$0000,$0000,$071D,$0000,$0013,$B5C4
	dc.w	$0000,$13B5,$C400,$0000,$0000,$0ED7,$8000,$001D
	dc.w	$EF26,$0000,$1DEF,$2600,$0000,$0000,$08DB,$0000
	dc.w	$00B5,$E020,$0000,$B5E0,$2000,$0000,$0000,$1BE7
	dc.w	$4000,$01F7,$4BF6,$0001,$F74B,$F600,$0000,$0000
	dc.w	$1BD3,$4000,$037F,$37D8,$8003,$7F37,$D880,$0000
	dc.w	$0000,$2AFC,$A000,$0791,$338E,$2007,$9133,$8E20
	dc.w	$0000,$0000,$2EB9,$0000,$0FF9,$FC33,$000F,$F9FC
	dc.w	$3300,$0000,$0000,$6DFF,$D000,$0F7D,$E3ED,$F00F
	dc.w	$7DE3,$EDF0,$0000,$0000,$7F7F,$D000,$1CBA,$80AF
	dc.w	$701C,$BA80,$AF70,$0000,$0000,$D3FF,$C800,$1A77
	dc.w	$003A,$F01A,$7700,$3AF0,$0000,$0000,$FBBD,$6000
	dc.w	$1766,$001E,$2817,$6600,$1E28,$0000,$0000,$FF34
	dc.w	$9800,$32DE,$001F,$FC32,$DE00,$1FFC,$0000,$0001
	dc.w	$7BD6,$FE00,$1ECA,$0000,$001E,$CA00,$0000,$0000
	dc.w	$0001,$D776,$7C00,$31F8,$0000,$0031,$F800,$0000
	dc.w	$0000,$0003,$2AF5,$EA00,$0874,$0000,$0008,$7400
	dc.w	$0000,$0000,$0002,$CFCB,$1100,$1FF0,$0000,$001F
	dc.w	$F000,$0000,$0000,$0005,$EECA,$5D00,$3F68,$0000
	dc.w	$003F,$6800,$0000,$0000,$0005,$EFCF,$3880,$0BC0
	dc.w	$0000,$000B,$C000,$0000,$0000,$000D,$3587,$2700
	dc.w	$16A0,$0000,$0016,$A000,$0000,$0000,$0003,$FD3A
	dc.w	$DFC0,$3F78,$0000,$003F,$7800,$0000,$0000,$0017
	dc.w	$7C53,$B400,$0D78,$0000,$000D,$7800,$0000,$0000
	dc.w	$000D,$EFFC,$F3E0,$0FFE,$0002,$000F,$FE00,$0200
	dc.w	$0000,$001C,$DF9C,$5EA0,$0F4E,$003C,$760F,$4E00
	dc.w	$3C76,$0000,$000B,$3FB7,$A4C0,$02EF,$0058,$9602
	dc.w	$EF00,$5896,$0000,$001D,$B5EB,$0950,$03FF,$808D
	dc.w	$7C03,$FF80,$8D7C,$0000,$004B,$B6BE,$FCF0,$02FD
	dc.w	$827A,$7402,$FD82,$7A74,$0000,$003E,$E3FF,$7F18
	dc.w	$01F8,$E23F,$0801,$F8E2,$3F08,$0000,$0035,$7E00
	dc.w	$0E28,$01BA,$EAC6,$5001,$BAEA,$C650,$0000,$0067
	dc.w	$4400,$247C,$00DD,$F692,$6000,$DDF6,$9260,$0000
	dc.w	$00F6,$EC00,$3B9C,$00BF,$9BAF,$C000,$BF9B,$AFC0
	dc.w	$0000,$0005,$F800,$0D7E,$006F,$EC5F,$8000,$6FEC
	dc.w	$5F80,$0000,$00EF,$B800,$0ABA,$0037,$F5CA,$0000
	dc.w	$37F5,$CA00,$0000,$0123,$F000,$0C35,$000E,$ACFC
	dc.w	$0000,$0EAC,$FC00,$0000,$03FF,$F000,$3FFF,$0003
	dc.w	$F9E0,$0000,$03F9,$E000,$0000,$0000,$0000,$0000
	dc.w	$0000,$3F00,$0000,$003F,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	;end of gadget data
	
****************************************************************************	
	SECTION	Variables,BSS
****************************************************************************	

_DOSBase	ds.l	1
_GfxBase	ds.l	1
_IntuitionBase	ds.l	1
_WorkbenchBase	ds.l	1

		RSRESET
MyWindow	rs.l	1
MyAppWindow	rs.l	1
WindowSig	rs.l	1
WindowPort	rs.l	1
MyAppIcon	rs.l	1
AppSignal	rs.l	1
MsgPort		rs.l	1
OldView		rs.l	1
MyView		rs.b	v_SIZEOF	
ViewPort1	rs.b	vp_SIZEOF
MyRasinfo1	rs.b	ri_SIZEOF
Buffer		rs.b	200
Var_Size	rs.b	0

Variables	ds.b	Var_Size
