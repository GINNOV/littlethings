******************************************************************************
*
*		Example of using my IFF graphics file reader
*		 This example shows it's use with intuition
*			   SuperBitMap Windows.
*
*			Compiles with Devpac V2.14
*
*		By Steve Marshall. Use and abuse as you will.
*
******************************************************************************

		incdir		"sys:include/"
		include		"exec/exec_lib.i"
		include		"exec/exec.i"
		include		"intuition/intuition_lib.i"
		include		"intuition/intuition.i"
		include		"libraries/dos.i"
		include		"graphics/gfx.i"
		include		"graphics/graphics_lib.i"
		include		"graphics/layers_lib.i
		include		"graphics/layers.i
		include		"misc/arpbase.i"

; Include easystart to allow a Workbench startup.

		include		"misc/easystart.i"

BuffSize	equ		2000		;size of load buffer	
NULL		equ		0

*****************************************************************************

CALLSYS    MACRO		;added CALLSYS macro - using CALLARP
	IFGT	NARG-1       	;CALLINT etc can slow code down and  
	FAIL	!!!         	;waste a lot of memory  S.M. 
	ENDC                 
	JSR	_LVO\1(A6)
	ENDM
		
*****************************************************************************

; The main routine that opens and closes things

start
	OPENARP				
	movem.l		(sp)+,d0/a0	
						
						
	move.l		a6,_ArpBase	
;--- naughty bit here.Trick subroutine into using ARP lib.
;--- saves us opening DOS lib  
	move.l		a6,_DOSBase
		
		
;------	the ARP library opens and uses the graphics and intuition 
;	libs and it is quite legal for us to get these bases for 
;	our own use.

	move.l		IntuiBase(a6),_IntuitionBase
	move.l		GFXBase(a6),_GfxBase
	
	moveq		#0,d0			;any version
	lea		LayersName,a1		;lib name
	CALLEXEC	OpenLibrary		;open layer library
	move.l		d0,_LayersBase		;save lib base
	beq		Cancel			;shouldn't happen

main
	lea		LoadFileStruct(pc),a0	;get filereq structure
	CALLARP		FileRequest 		;call filerequester
	tst.l		d0			;check return
	beq.s		Cancel			;branch if canceled
	
	lea		LoadFileStruct(pc),a0	;get filereq struct
	bsr		CreatePath		;create full pathname
	tst.b		LoadPathName		;check pathname
	beq.s		main			;branch if null string

	move.l		#LoadPathName,d1	;get filename to open
	move.l		#MODE_OLDFILE,d2	;open existing file
	CALLSYS		Open			;open file
	move.l		d0,FileHndl		;store handle
	beq.s		main			;branch on error

	moveq		#0,d1			;specify separate bitplanes
	jsr		LoadILBM		;load gfx file
	tst.l		d0			;test result
	beq.s		GFXError		;branch on error
	move.l		d0,-(sp)		;save bitmap 
	bsr.s		screen			;display graphics
	move.l		(sp)+,d0		;get bitmap
	jsr		CleanupGraf		;and free it

GFXError
	move.l		FileHndl,d1		;get file handle
	CALLARP		Close			;and close file
	bra.s		main			;loop and go again
	
	move.l		_LayersBase,a1		;get layersbase
	CALLEXEC	CloseLibrary
		
;------	Close the ARP library, this closes Intuition + Graphics libs.
Cancel
	move.l		_ArpBase,a1		;get arp lib base
	CALLEXEC	CloseLibrary		;and close it
	rts

*****************************************************************************
;------------------------------	SUBROUTINES
*****************************************************************************

;-------------- Open the intuition screen.

screen		

	move.l		d0,a5			;store bitmap
	lea		custom_screen(pc),a0	;a0->new screen structure
	move.w		ilbm_Width(a5),ns_Width(a0)	;set width
	move.w		ilbm_Height(a5),ns_Height(a0) 	;set height
	addq.w		#8,ns_Height(a0)	;allow for titlebar	
	addq.w		#2,ns_Height(a0)	;allow for titlebar	
	move.w		ilbm_Modes(a5),ns_ViewModes(a0) ;set modes
	move.b		bm_Depth(a5),ns_Depth+1(a0)	;set depth
		
	CALLINT		OpenScreen		;open the screen
	move.l		d0,screen.ptr		;store pointer returned

	beq		ScreenError		;quit if screen failed to open
		
; Load correct colours into this screens viewport.

	move.l		d0,a0			;a0->screen structure
	lea		sc_ViewPort(a0),a0 	;a0->screens viewport struct
	move.l		ilbm_ColorMap(a5),a1	;a1->colours
	move.w		(a1)+,d0		;d0=number of colours
	ext.l		d0			;extend to long
	CALLGRAF	LoadRGB4		;set colours
		
  	lea 		MyNewWindow,a0		;get new window
  	move.l		screen.ptr,nw_Screen(a0);point to our bitmap
  	;move.w		ilbm_Width(a5),nw_Width(a0)	;set width
	;move.w		ilbm_Height(a5),nw_Height(a0) 	;set height
  	move.l		a5,nw_BitMap(a0)	;point to our bitmap
  	CALLINT		OpenWindow		;and open it
  	move.l 		d0,WindowPtr		;store window ptr
  	beq.s 		WdwError		;branch if no window
	
ScrollLoop
  	move.l 		WindowPtr,a0		;get window
  	move.l 		wd_UserPort(a0),a0	;and it's user port
  	CALLEXEC	GetMsg			;get message
  	tst 		d0			;test message
  	beq.s 		ScrollLoop		;branch if no message
;------ store message 
  	move.l 		d0,a1			;message in a1
  	
;------ test for message type and act accordingly
  	move.l 		im_Class(a1),d2		;message class in d1
	move.w		im_Code(a1),d3		;get code
  	CALLEXEC	ReplyMsg		;and reply to it

  	cmp.l 		#CLOSEWINDOW,d2		;is it closewindow
  	beq.s	 	CloseWdw		;branch on closewindow

  	cmp.l 		#RAWKEY,d2		;is it rawkey
  	bne		ScrollLoop		;branch if not
	move.l		d3,d0			;get code
  	bsr.s		DoKeys			;scroll graphics
  	bra.s		ScrollLoop		;branch always
			
CloseWdw
	move.l		WindowPtr,a0		;get window
	CALLINT		CloseWindow		;and close it

WdwError
	move.l		screen.ptr,a0		;a0->screen 
	CALLINT		CloseScreen		;and close it

ScreenError
	rts

*****************************************************************************
;	Subroutines
*****************************************************************************
CreatePath:
	move.l		a2,-(sp)		;save a2
	move.l		a0,a2			;filestruct in a2
	move.l		fr_Dir(a2),a0		;dir name in a0
	move.l		fr_SIZEOF(a2),a1	;destination in a1
	moveq		#DSIZE,d0		;size in d0
	CALLEXEC	CopyMem			;copy dir name
	move.l		fr_SIZEOF(a2),a0	;destination in a0
	move.l		fr_File(a2),a1		;filename in a1
	CALLARP		TackOn			;create pathname
	move.l		(sp)+,a2		;restore a2
	rts
	
DoKeys
;------ test for message type and act accordingly
	cmp.w		#$4c,d0			;is it cursor up 
	bne.s		NotUp			;branch if not up
	moveq		#0,d0			;set no X scroll 
	moveq		#1,d1			;set scroll up 1
	bra.s		KeyDone			;scroll pic
NotUp
	cmp.w		#$4d,d0			;is it cursor down
	bne.s		NotDown			;branch if not down
	moveq		#0,d0			;set no X scroll 
	moveq		#-1,d1			;set scroll down 1
	bra.s		KeyDone			;scroll pic	
NotDown
	cmp.w		#$4e,d0			;is it cursor right
	bne.s		NotRight		;branch if not right
	moveq		#-1,d0			;set scroll right 1
	moveq		#0,d1			;set no Y scroll 
	bra.s		KeyDone			;scroll pic
NotRight
	cmp.w		#$4f,d0			;is it cursor left
	bne.s		NoScroll		;branch if not left
	moveq		#1,d0			;set scroll left 1
	moveq		#0,d1			;set no Y scroll 

KeyDone
	move.l		WindowPtr,a0		;set window
	move.l		wd_RPort(a0),a0		;get rastport
	move.l		(a0),a1			;get layer
	move.l		lr_LayerInfo(a1),a0	;get layerinfo
	move.l		_LayersBase,a6		;get layersbase
	CALLSYS		ScrollLayer		;scroll layer

NoScroll
	rts 

*****************************************************************************
;------------------------------	DATA
*****************************************************************************

;-------------- Data Section

custom_screen
	dc.w	0,0			;x,y starting position
	dc.w	0,0			;width,height
	dc.w	0			;depth
	dc.b	0,1			;fgr pen,bgr pen
	dc.w	0			;normal mode
	dc.w	CUSTOMSCREEN		;screen type
	dc.l	0			;standard font
	dc.l	ScrTitle			;title
	dc.l	0			;no gadgets
	dc.l	0			;addr of bitmap struct

ScrTitle
	dc.b	'IFF Loader Demo',0
	EVEN

;------ window structure
WindowFlags	SET	WINDOWDEPTH!WINDOWCLOSE!WINDOWSIZING!WINDOWDRAG
WindowFlags	SET	WindowFlags!SUPER_BITMAP!GIMMEZEROZERO!ACTIVATE
;		Phew !

MyNewWindow 
  	dc.w 	85,40
  	dc.w 	180,60
  	dc.b 	-1,-1
  	dc.l 	CLOSEWINDOW!RAWKEY
  	dc.l	WindowFlags
  	dc.l 	NULL
  	dc.l 	NULL
  	dc.l 	WdwTitle
  	dc.l 	NULL
  	dc.l 	NULL
  	dc.w 	40,20
  	dc.w 	-1,-1
  	dc.w 	CUSTOMSCREEN
  
WdwTitle:
  	dc.b 	"Use Cursor Keys",0  
  	EVEN


LoadFileStruct:
	dc.l	LoadText
	dc.l	LoadFileData
	dc.l	LoadDirData
	dc.l	NULL
	dc.b	NULL
	dc.b	0
	dc.l	NULL
	dc.l	0
	dc.l	LoadPathName
	
LoadText
	dc.b	'Select Pic to View',0
	EVEN
	
LayersName
	dc.b	'layers.library',0
		
*****************************************************************************
		SECTION	Variables,BSS
*****************************************************************************
	
_ArpBase
	ds.l	1
_GfxBase
	ds.l	1
_IntuitionBase
	ds.l	1
_DOSBase
	ds.l	1
_LayersBase
	ds.l	1
screen.ptr
	ds.l	1
WindowPtr
	ds.l	1
RPort
	ds.l	1
FileHndl
	ds.l	1
	
LoadFileData:
	ds.b	FCHARS+1
	EVEN
	
LoadDirData:
	ds.b	DSIZE+1
	EVEN
	
LoadPathName:
	ds.b	DSIZE+FCHARS+2
	EVEN

*****************************************************************************
;		Include IFF code
*****************************************************************************

	include	source:s.marshall/ILBM.Code.s
