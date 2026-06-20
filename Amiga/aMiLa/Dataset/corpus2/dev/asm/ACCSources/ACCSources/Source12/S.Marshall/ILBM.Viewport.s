******************************************************************************
*
*		Example of using my IFF graphics file reader
*		This example shows how to use with viewports
*
*			Compiles with Devpac V2.14
*
*		By Steve Marshall. Use and abuse as you will.
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
		include		"misc/arpbase.i"

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
	
	moveq		#0,d1			;specify ordinary
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
	bra.s		main			;loop and go again
		
;------	Close the ARP library, this closes Intuition + Graphics libs.
Cancel
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
	
	move.l		gb_ActiView(a6),OldView ;save old view

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
	
	move.l		#10*50,d1		;d1=time in 1/50 seconds
	CALLARP		Delay			;call delay routine
	
;------	Restore screen then clean up
	
	move.l		OldView,a1		;get old view
	CALLGRAF	LoadView		;restore screen
	
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

*****************************************************************************
;		Include IFF code
*****************************************************************************

	include	source:s.marshall/ILBM.Code.s
