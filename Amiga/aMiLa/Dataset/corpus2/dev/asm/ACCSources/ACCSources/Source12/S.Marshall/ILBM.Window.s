******************************************************************************
*
*		Example of using my IFF graphics file reader
*		This example loads a brush then move it around.
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
		include		"misc/arpbase.i"

; Include easystart to allow a Workbench startup.

		include		"misc/easystart.i"

BuffSize	equ		2000		;load buffer size
NULL		equ		0

;*****************************************

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

	moveq		#ILBMCONTIGUOUS,d1	;specify contiguous
	jsr		LoadILBM		;load gfx file
	tst.l		d0			;test result
	beq.s		GFXError		;branch on error
	move.l		d0,-(sp)		;save bitmap
	bsr.s		window			;display brush
	move.l		(sp)+,d0		;get bitmap
	jsr		CleanupGraf		;and free it

GFXError
	move.l		FileHndl,d1		;get file handle
	CALLARP		Close			;and close file
	bra.s		main			;loop and go again
		
;------	Close the ARP library, this closes Intuition + Graphics libs.
Cancel
	move.l		_ArpBase,a1		;get arp lib base
	CALLEXEC	CloseLibrary		;and close it
	rts

*****************************************************************************
;------------------------------	SUBROUTINES
*****************************************************************************

;-------------- Open the intuition Window

window

	move.l		d0,a5			;store bitmap
	lea		Img0_image(pc),a4		;a0->new screen structure
	move.w		ilbm_Width(a5),ig_Width(a4)	;set width
	move.w		ilbm_Height(a5),ig_Height(a4) 	;set height
	move.l		bm_Planes(a5),ig_ImageData(a4)	;set image data
	
  	lea 		MyNewWindow,a0		;get new window
  	CALLINT		OpenWindow		;and open it
  	move.l 		d0,WindowPtr		;store window ptr
  	beq.s 		WdwError		;branch if no window
	
	move.l		d0,a0			;window to a0
	move.l		wd_RPort(a0),RPort	;save rastport
InitLoop
  	move.l		#340,d7			;loop size

MoveLoop  	
  	move.l		RPort,a0		;get rastport
  	lea		Img0_image,a1		;get image
  	moveq		#0,d0			;x pos
  	moveq		#0,d1			;y pos
  	CALLINT		DrawImage		;draw it
	
	btst		#6,$bfe001		;test mousebutton
	beq.s		CloseWdw		;branch if pressed
	
	move.w		Direction,d0		;get direction
	add.w		d0,(a4)			;add direction x pos
	dbra		d7,MoveLoop		;loop till done
	neg.w		Direction		;set other direction
	bra.s		InitLoop		;and restart loop
		
CloseWdw
	move.l		WindowPtr,a0		;get window
	CALLINT		CloseWindow		;and close it

WdwError
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

*****************************************************************************
;------------------------------	DATA
*****************************************************************************

;------ window structure
MyNewWindow 
  	dc.w 		0,0
  	dc.w 		640,200
  	dc.b 		-1,-1
  	dc.l 		CLOSEWINDOW
  	dc.l 		WINDOWDEPTH!WINDOWCLOSE!ACTIVATE
  	dc.l 		NULL
  	dc.l 		NULL
  	dc.l 		WdwTitle
  	dc.l 		NULL
  	dc.l 		NULL
  	dc.w 		0,0
  	dc.w 		-1,-1
  	dc.w 		WBENCHSCREEN
  
WdwTitle:
  	dc.b 		"IFF Loader Demo",0  
  	EVEN

Img0_image
	dc.w	40,30          	;left, top
	dc.w	0,0,2	 	;width, height, depth 
	dc.l	NULL		;image data
	dc.b	3,0	       	;plane pick, plane on/off
	dc.l	0              	;next image

Direction
	dc.w	1

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
	dc.b	'Select Brush to View',0
		
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
WindowPtr
	ds.l	1
RPort
	ds.l	1
FileHndl
	ds.l	1
XLimit
	ds.l	1
YLimit
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
