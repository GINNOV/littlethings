******************************************************************************
*
*		This little prog is an adaption of Steve Marshalls Viewport
*		code on Disc12. It utalises Steves ILBM load subroutine to
*		present a very simple IFF slide show. All IFF files should
*		be in the current directory and should be named a,b,c,d...z
*
*		Use the right mouse button to step on a pic.
*
*		The program continualy loops round the pics until the left
*		mouse button is pressed.
*
******************************************************************************

		incdir		"sys:include/"
		include		"exec/exec_lib.i"
		include		"exec/exec.i"
		include		"libraries/dos.i"
		include		"graphics/gfxbase.i"
		include		"graphics/gfx.i"
		include		"graphics/view.i"
		include		"graphics/graphics_lib.i"
		include		source:include/arpbase.i

; Include easystart to allow a Workbench startup.

		include		"misc/easystart.i"

BuffSize	equ		2000		
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

	move.l		GFXBase(a6),_GfxBase

	bsr		SetDefault
	jsr		Play
main
	move.l		#filename,d1	;get filename to open
	move.l		#MODE_OLDFILE,d2	;open existing file
	CALLARP		Open			;open file
	move.l		d0,FileHndl		;store handle
	bne.s		.ok			;branch on error

	cmpi.b		#'a',filename		no first file
	beq		Cancel			leave if not
	move.b		#'a',filename		else restart
	bra		main

.ok	moveq		#0,d1			;specify ordinary
	jsr		LoadILBM		;load gfx file
	tst.l		d0			;test result
	beq.s		GFXError		;branch on error
	move.l		d0,-(sp)		;store bitmap
	bsr.s		Display			;display picture
	move.l		(sp)+,d0		;get bitmap
	jsr		CleanupGraf		;and free it

GFXError
	move.l		FileHndl,d1		;get file handle
	CALLARP		Close			;and close file
	move.b		filename,d1
	addq.l		#1,d1
	cmpi.b		#'s',d1
	bne.s		.ok
	addq.b		#1,d1
.ok	move.b		d1,filename
	tst.w		quit_flag
	beq		main
		
;------	Close the ARP library, this closes Intuition + Graphics libs.
Cancel	bsr		FreeDefault
	jsr		Stop
	move.l		_ArpBase,a1		;get arp lib base
	CALLEXEC	CloseLibrary		;and close it
	rts

*****************************************************************************
;------------------------------	SUBROUTINES
*****************************************************************************

;-------------- Create Viewport and display picture

Display
	move.l		d0,a5			;ilbm struct in a5
	lea		MyView,a1		;get our view
	CALLGRAF	InitView		;and initialise it
	
	lea		ViewPort1,a4		;get first viewport
	move.l		a4,a0			;get first viewport
	CALLSYS		InitVPort		;initialise 2nd viewport
	
	lea		MyView,a1		;get our view
	move.w		ilbm_Modes(a5),v_Modes(a1) ;set view modes
	move.w		ilbm_Modes(a5),vp_Modes(a4);set viewport modes
	move.l		a4,(a1)			;and link to view
	
	moveq		#32,d0			;number of colours
	CALLSYS		GetColorMap		;get colourmap
	move.l		d0,vp_ColorMap(a4)	;store colormap
	
;------	This next piece of code attemts to centre the piture on screen
	
	move.w		ilbm_Width(a5),d0	;get width
	move.w		ilbm_Modes(a5),d1	;get mode
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
	
	move.w		ilbm_Height(a5),d0	;get height
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
	
	move.w		ilbm_Width(a5),d1	;get width
	move.w		ilbm_Modes(a5),d0	;get modes
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
	
	move.w		ilbm_Height(a5),d1	;get height
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

	lea		MyRasinfo1,a1		;get 1st rasinfo
	move.l		a1,vp_RasInfo(a4)	;and place in viewport
	 
	move.l		a5,ri_BitMap(a1)	;store bitmap in rasinfo
	
;------	Make view viewport then display
	
	lea		MyView,a0		;get view
	move.l		a4,a1			;get first viewport
	CALLSYS		MakeVPort		;make viewports
	
	lea		MyView,a1		;get view
	CALLSYS		MrgCop			;merge copper lists
	
	lea		MyView,a1		;get view
	CALLSYS		LoadView		;display viewports
	
	move.l		a4,a0			;get first viewport
	move.l		ilbm_ColorMap(a5),a1	;get colourmap
	move.w		(a1)+,d0		;d0 = number of colours
	CALLSYS		LoadRGB4		;set colours

;------ Wait for 10 seconds
	
.chkrt	btst		#2,$dff016		RMB
	bne.s		.chklft			branch if not
	not.w		quit_flag		else set flag
	bra		.gogo			and leave

.chklft	btst		#6,$bfe001		LMB
	bne.s		.chkrt			branch back if not

;------	Restore screen then clean up

.gogo	move.l		OldView,a1
	CALLGRAF	LoadView
	
	move.l		a4,a0			;get first viewport
	move.l		vp_ColorMap(a0),d2	;save colormap
	CALLSYS		FreeVPortCopLists	;free copper lists
	
	lea		MyView,a0		;get view
	move.l		v_SHFCprList(a0),d3	;save short frame
	move.l		v_LOFCprList(a0),a0	;set long frame
	CALLSYS		FreeCprList		;free copper list
	move.l		d3,a0			;get short frame
	CALLSYS		FreeCprList		;free copper list
	
	move.l		d2,a0			;get colormap
	CALLSYS		FreeColorMap		;and free it
	rts

***************	Subroutine that returns the length of a file in bytes.

; Entry		a0 = address of file name

; Exit		d0 = length of file in bytes or 0 if any error occurred

; Corrupted	a0

;-------------- Save register values

FileLen		movem.l		d1-d4/a1-a4,-(sp)

;-------------- Save address of filename and clear file length

		move.l		a0,RFfile_name
		move.l		#0,RFfile_len

;-------------- Allocate some memory for the File Info block

		move.l		#fib_SIZEOF,d0
		move.l		#MEMF_PUBLIC,d1
		CALLEXEC	AllocMem
		move.l		d0,RFfile_info
		beq		.error1
		
;-------------- Lock the file
		
		move.l		RFfile_name,d1
		move.l		#ACCESS_READ,d2
		CALLDOS		Lock
		move.l		d0,RFfile_lock
		beq		.error2

;-------------- Use Examine to load the File Info block

		move.l		d0,d1
		move.l		RFfile_info,d2
		CALLSYS		Examine

;-------------- Copy the length of the file into RFfile_len

		move.l		RFfile_info,a0
		move.l		fib_Size(a0),RFfile_len

;-------------- Release the file

		move.l		RFfile_lock,d1
		CALLSYS		UnLock

;-------------- Release allocated memory

.error2		move.l		RFfile_info,a1
		move.l		#fib_SIZEOF,d0
		CALLEXEC	FreeMem


;-------------- All done so return

.error1		move.l		RFfile_len,d0
		movem.l		(sp)+,d1-d4/a1-a4
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

SetDefault

; Get pointer to system copper list and save it for later

	move.l	_GfxBase,a0
	move.l	gb_ActiView(a0),oldcopper
	
; Initialise a View structure

	lea	my_view,a1
	move.l	a1,OldView
	CALLGRAF	InitView
	

; Initialise a View Port structure. This will be used to display my screen

	lea	my_viewport,a0
	CALLGRAF	InitVPort

; Link Viewport structure to the View structure.

	lea	my_view,a0
	move.l	#my_viewport,v_ViewPort(a0)

; Initialise a Bitmap structure

	lea	my_bitmap,a0
	moveq.l	#0,d0
	move.l	#320,d1
	move.l	#200,d2
	CALLGRAF	InitBitMap

; Link Bitmap structure to a RasInfo structure and set screen x & y offsets

	lea	my_rasinfo,a0
	move.l	#my_bitmap,ri_BitMap(a0)
	move.w	#0,ri_RxOffset(a0)
	move.w	#0,ri_RyOffset(a0)

; Link Rasinfo structure to the ViewPort structure and set
; DWidth and DHeight which define height of visible bitmap in the ViewPort.

	lea	my_viewport,a0
	move.l	#my_rasinfo,vp_RasInfo(a0)
	move.w	#320,vp_DWidth(a0)
	move.w	#200,vp_DHeight(a0)

; Get system to prepare display instructions for copper.

	lea	my_view,a0
	lea	my_viewport,a1
	CALLGRAF	MakeVPort

; Merge this list into a real copper list.

	lea	my_view,a1
	CALLGRAF	MrgCop

; Display this view.

	lea	my_view,a1
	CALLGRAF	LoadView
error	rts
	
mouse_test	btst	#6,$bfe001
	bne	mouse_test

FreeDefault
	
; Free up memory allocated to us

	lea	my_viewport,a0
	CALLGRAF	FreeVPortCopLists
	lea	my_view,a0
	move.l	v_LOFCprList(a0),a0
	CALLGRAF	FreeCprList
	
; Restore systems copper list.  

	move.l	oldcopper,a1
	CALLGRAF	LoadView
	rts


*****************************************************************************
;------------------------------	DATA
*****************************************************************************

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
	even

filename	dc.b	'a',0		
*****************************************************************************
		SECTION	Variables,BSS
*****************************************************************************
	
_ArpBase
	ds.l	1
_GfxBase
	ds.l	1
_DOSBase
	ds.l	1
FileHndl
	ds.l	1
OldView
	ds.l	1
MyView
	ds.b	v_SIZEOF	
ViewPort1
	ds.b	vp_SIZEOF
MyRasinfo1
	ds.b	ri_SIZEOF
	
LoadFileData:
	ds.b	FCHARS+1
	EVEN
	
LoadDirData:
	ds.b	DSIZE+1
	EVEN
	
LoadPathName:
	ds.b	DSIZE+FCHARS+2
	EVEN
	
my_view		ds.b	v_SIZEOF
my_viewport	ds.b	vp_SIZEOF
my_rasinfo	ds.b	ri_SIZEOF
my_bitmap	ds.b	bm_SIZEOF
oldcopper	ds.l	1
quit_flag	ds.w	1


RFfile_name	ds.l		1
RFfile_lock	ds.l		1
RFfile_info	ds.l		1
RFfile_len	ds.l		1

		section	ILBMCode,code
*****************************************************************************
;		Include NoiseTracker replay code
*****************************************************************************

	include play.s

*****************************************************************************
;		Include IFF code
*****************************************************************************

	include	source:m.meany/ILBM.Code.s
