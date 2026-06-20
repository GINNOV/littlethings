******************************************************************************
*
*		Example of using my IFF graphics file reader
*		This example shows it's use with intuition screens
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

BuffSize	equ		2000		;size of load buffer	
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
	move.w		ilbm_Modes(a5),ns_ViewModes(a0) ;set modes
	move.b		bm_Depth(a5),ns_Depth+1(a0)	;set depth
	move.l		a5,ns_CustomBitMap(a0)	;set bitmap
		
	CALLINT		OpenScreen		;open the screen
	move.l		d0,screen.ptr		;store pointer returned

	beq.s		error1			;leave if screen failed to open
		
; Load correct colours into this screens viewport.

	move.l		d0,a0			;a0->screen structure
	lea		sc_ViewPort(a0),a0 	;a0->screens viewport struct
	move.l		ilbm_ColorMap(a5),a1	;a1->colours
	move.w		(a1)+,d0		;d0=number of colours
	ext.l		d0			;make d0 long
	CALLGRAF	LoadRGB4		;set colours
		
; Wait for 5 seconds

	move.l		#10*50,d1		;d1=time in 1/50 seconds
	CALLARP		Delay			;call delay routine
		
; Close the screen

	move.l		screen.ptr,a0		;a0->screen 
	CALLINT		CloseScreen		;and close it

error1
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

;-------------- Data Section

custom_screen
	dc.w	0,0			;x,y starting position
	dc.w	0,0			;width,height
	dc.w	0			;depth
	dc.b	0,0			;fgr pen,bgr pen
	dc.w	0			;normal mode
	dc.w	CUSTOMSCREEN!CUSTOMBITMAP!SCREENQUIET	;screen type
	dc.l	0			;standard font
	dc.l	0			;no title
	dc.l	0			;no gadgets
	dc.l	0			;addr of bitmap struct

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
_IntuitionBase
	ds.l	1
_DOSBase
	ds.l	1
screen.ptr
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
