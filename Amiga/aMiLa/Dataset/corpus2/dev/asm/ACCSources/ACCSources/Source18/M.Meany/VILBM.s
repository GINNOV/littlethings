

; Simple VILBM program. Run from CLI only with filename as a parameter.

; Uses S.Marshalls ILBM loader, talk about overkill.


		incdir		"sys:include/"
		include		"exec/exec_lib.i"
		include		"exec/exec.i"
		include		"intuition/intuition_lib.i"
		include		"intuition/intuition.i"
		include		"libraries/dos_lib.i"
		include		"libraries/dos.i"
		include		"libraries/dosextens.i"
		include		"graphics/gfx.i"
		include		graphics/gfxbase.i
		include		"graphics/graphics_lib.i"

CALLSYS		macro
		ifgt	NARG-1
		FAIL	!!!
		endc
		jsr	_LVO\1(a6)
		endm

		section		Skeleton,code

; Include easystart to allow a Workbench startup.

Start		move.l		a0,_args	save addr of CLI args
		move.l		d0,_argslen	and the length
		move.b		#0,-1(a0,d0)	NULL end calling param

		tst.b		(a0)		any parameters
		bne.s		.ok		if so skip next bit

		move.b		#'?',(a0)	else signal usage reqd

.ok		bsr.s		Openlibs	open libraries
		tst.l		d0		any errors?
		beq		no_libs		if so quit

		bsr		Init		Initialise data
		tst.l		d0		any errors?
		beq		no_libs		if so quit

		move.l		_args,a0	a0->filename

; Select the function to test here, make sure to change filename!

		jsr		ViewILBM

no_win		bsr		DeInit		free resources

no_libs		bsr		Closelibs	close open libraries

quitfast	rts				finish


;**************	Open all required libraries

; Open DOS, Intuition and Graphics libraries.

; If d0=0 on return then one or more libraries are not open.

Openlibs	moveq.l		#0,d0		clear base pointers
		move.l		d0,_DOSBase
		move.l		d0,_IntuitionBase
		move.l		d0,_GfxBase


		lea		dosname,a1	a1->lib name
		moveq.l		#0,d0		any version
		CALLEXEC	OpenLibrary	and open it
		move.l		d0,_DOSBase	save base ptr
		beq		.lib_error

		lea		intname,a1	a1->lib name
		moveq.l		#0,d0		any version
		CALLEXEC	OpenLibrary	and open it
		move.l		d0,_IntuitionBase	save base ptr
		beq		.lib_error

		lea		gfxname,a1	a1->lib name
		moveq.l		#0,d0		any version
		CALLEXEC	OpenLibrary	and open it
		move.l		d0,_GfxBase	save base ptr
		beq		.lib_error

.lib_error	rts

*************** Initialise any data

;--------------	At present just set STD_OUT and check for usage text

Init		
		CALLDOS		Output		determine CLI handle
		move.l		d0,STD_OUT	and save it for later
		beq		.err		quit if there is no handle

		move.l		_args,a0	get addr of CLI args
		cmpi.b		#'?',(a0)	is the first arg a ?
		bne.s		.ok		if not skip the next bit

		lea		_UsageText,a0	a0->the usage text
		bsr			DOSPrint	and display it
.err		moveq.l		#0,d0		set an error
		bra.s		.error		and finish

;--------------	Your Initialisations should start here

.ok		moveq.l		#1,d0		no error

.error		rts				back to main

***************	Release any additional resources used

DeInit		

.done		rts

***************	Close all open libraries

; Closes any libraries the program managed to open.

Closelibs	
		move.l		_DOSBase,d0		d0=base ptr
		beq		.pp2			quit if 0
		move.l		d0,a1			a1->lib base
		CALLEXEC	CloseLibrary		close lib

.pp2		move.l		_IntuitionBase,d0		d0=base ptr
		beq		.pp1			quit if 0
		move.l		d0,a1			a1->lib base
		CALLEXEC	CloseLibrary		close lib

.pp1		move.l		_GfxBase,d0		d0=base ptr
		beq.s		.lib_error		quit if 0
		move.l		d0,a1			a1->lib base
		CALLEXEC	CloseLibrary		close lib

.lib_error	rts


*****************************************************************************
*			Useful Subroutines Section					    *
*****************************************************************************

****************

;--------------	Subroutine to display any message in an open file.

; Entry		a0 must hold address of 0 terminated message.
;		d0 should hold handle of open file to be written to.

; Exit		None
;Corrupted	d0,d1,a0,a1

DOSPrint	move.l		d3,-(sp)	save work registers
		move.l		d2,-(sp)

		move.l		d0,d1		get a working copy of handle
		move.l		a0,a1		get a working copy

;--------------	Determine length of message

		moveq.l		#-1,d3		reset counter
.loop		addq.l		#1,d3		bump counter
		tst.b		(a1)+		is this byte a 0
		bne.s		.loop		if not loop back

;--------------	Make sure there was a message

		tst.l		d3		was there a message ?
		beq.s		.error		if not, graceful exit

;--------------	Get handle of output file

		tst.l		d1		d1=file handle
		beq.s		.error		leave if no handle

;--------------	Now print the message
;		At this point, d3 already holds length of message
;		and d1 holds the file handle.

		move.l		a0,d2		d2=address of message
		CALLDOS		Write		and print it

;--------------	All done so finish

.error		move.l		(sp)+,d2	restore registers
		move.l		(sp)+,d3
		rts				and return

*****************************************************************************

*****************************************************************************
*			Data Section					    *
*****************************************************************************

dosname		dc.b		'dos.library',0
		even

intname		dc.b		'intuition.library',0
		even

gfxname		dc.b		'graphics.library',0
		even

; replace the usage text below with your own particulars

_UsageText	dc.b		$0a
		dc.b		'Simple VILBM IFF viewer. ',$9b,"0;33;40m",'ACC, 91.',$9b,"0;31;40m"
		dc.b		$0a
		dc.b		'Run from CLI only with filename as only parameter.'
		dc.b		$0a
		dc.b		0
		even

;***********************************************************
	SECTION	Vars,BSS
;***********************************************************

_args		ds.l		1
_argslen	ds.l		1


_DOSBase	ds.l		1
_IntuitionBase	ds.l		1
_GfxBase	ds.l		1

STD_OUT		ds.l		1


		section		any,code

BuffSize	equ		10*1024		10k buffer


; Entry		a0->filename

ViewILBM
        movem.l		d0-d7/a0-a6,-(sp)

	move.l		a0,d1			;get filename to open
	move.l		#MODE_OLDFILE,d2	;open existing file
	CALLDOS		Open			;open file
	move.l		d0,FileHndl		;store handle
	beq.s		.error			;branch on error
	
	moveq		#0,d1			;specify ordinary
	jsr		LoadILBM		;load gfx file
	tst.l		d0			;test result
	beq.s		.GFXError		;branch on error
	move.l		d0,-(sp)		;store bitmap
	bsr.s		Display			;display picture
	move.l		(sp)+,d0		;get bitmap
	jsr		CleanupGraf		;and free it

.GFXError
	move.l		FileHndl,d1		;get file handle
	CALLDOS		Close			;and close file

.error	movem.l		(sp)+,d0-d7/a0-a6
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

;------ Wait for Left Mouse
	
.wait	btst		#6,$bfe001		lmb pressed?
	bne.s		.wait
	
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
*****************************************************************************
		SECTION	ILBMCode,CODE
*****************************************************************************
;Usage	GrafStruct = LoadILBM(FileHandle,Type)
;	    d0			  d0      d1

;	Grafstruct is an extended  Bitmap structure  which contains the
;	extra  width, height, modes  and colormap  information. See end
;	of this  file for  information on  this  structure. The  Bitmap
;	returned is  initialized  and ready  to use. Although  intended 
;	for use with viewports this structure can be used with intuition
;	screens  and windows. The  loader is  fairly  quick as it  uses
;	buffered loading instead of reading a few  bytes at a time. The
;	Type option is to allow you to  specify whether to load or skip
;	masks and  whether to load the  bitmap as separate planes or as
;	a single  block of contiguous  memory. This code is still a bit
;	messy though - sorry!.

;BUGS
;	Does not yey support IFF LIST and CAT. This should not cause too
;	much of a problem. I have  had no  call to need this. If someone
;	really  needs this I will  add it into the code. I will add code
;	for colour cycling later.  

*****************************************************************************
LoadILBM
	movem.l		a2-a6/d2-d7,-(sp)	;store regs
	link		a5,#BlkSIZEOF		;get temp variable space
	move.l		d0,GrafFileHndl(a5)	;save file handle
	move.w		d1,MemBlkType(a5)	;store load type
	move.l		d0,d1			;file handle in d1
	moveq		#0,d0			;clear d0
	move.b		d0,Stencil(a5)		;clear variables
	move.w		d0,CAMGloaded(a5)	;clear variables
	move.b		d0,ComprBit(a5)	;clear variables
	move.l		d0,MyBitmap(a5)	;clear memory pointer
	lea		Temp(a5),a0		;get read buffer
	move.l		a0,d2			;buffer in d2
	moveq		#12,d3			;size to read
	CALLDOS		Read			;read file
	cmpi.l		#-1,d0			;check for errors
	beq		CheckError		;branch on error
		
;------ currently only handles IFF FORM will add LIST and CAT later
	movea.l		d2,a0			;address of buffer
	cmp.l		#'FORM',(a0)		;is it IFF file
	bne.s		IFFErr			;if not quit 
	cmp.l		#"ILBM",8(a0)		;is it ILBM pic
	bne.s		IFFErr			;if not quit

	moveq		#ilbm_SIZEOF,d0		;get chunk size
	move.l		#MEMF_PUBLIC!MEMF_CLEAR,d1 ;set memory type
	CALLEXEC	AllocMem		;allocate memory for chunk
	move.l		d0,MyBitmap(a5)	;save memory pointer
	beq.s		GrafMemError		;branch if non allocated

;------	This next part is arranged so that adding handlers for extra
;	chunks is quite easy. For example you may wish to handle
;	colour cycling chunks.

Chunkloop:
	bsr.s		GetChunk		;get chunk name
	tst.l		d0			;check result
	beq.s		IFFErr			;if end of file before BODY
	
	cmpi.l		#'BMHD',d0		;is it BMHD chunk
	bne.s		NotBMHD			;branch if not BMHD
	bsr		BMHD1			;if yes process BMHD 
	bra.s		Chunkloop		;loop to Chunkloop
	
NotBMHD
	cmpi.l		#'CMAP',d0		;is it CMAP chunk
	bne.s		NotCMAP			;branch if not CMAP
	bsr		CMAP1			;if yes process CMAP
	bra.s		Chunkloop		;loop to Chunkloop

NotCMAP
	cmpi.l		#'CAMG',d0		;is it CAMG chunk
	bne.s		NotCAMG			;branch if not CAMG
	bsr		CAMG1			;if yes process CAMG 
	bra.s		Chunkloop		;loop to Chunkloop

NotCAMG
	cmpi.l		#'GRAB',d0		;is it GRAB chunk
	bne.s		NotGRAB			;branch if not GRAB
	bsr		GRAB1			;if yes process GRAB 
	bra.s		Chunkloop		;loop to Chunkloop
	
NotGRAB	
	cmpi.l		#'BODY',d0		;is it BODY
	bne.s		NotRecognised		;branch if chunk not recognized
	bsr		BODY1			;if yes branch and do BODY

LoadEnd
;------	Unlk has the nice property of correcting the stack for us
	unlk		a5			;free stack
	movem.l		(sp)+,a2-a6/d2-d7	;restore regs
	rts

GrafMemError:
	moveq		#1,d1			;set memory error
	bra.s		LoadEnd			;branch to end

IFFErr
	moveq		#4,d1			;flag iff error
	moveq		#0,d0			;flag error
	bra.s		LoadEnd			;branch to end
	
NotRecognised
	move.l		d2,-(sp)		;store regs
	move.l		GrafFileHndl(a5),d1	;get file handle
	move.l		d3,d2			;length in d2
	moveq		#0,d3			;seek mode in d3
	CALLDOS		Seek			;move to point in file
	move.l		(sp)+,d2		;restore regs
	cmpi.l		#-1,d0			;check for errors
	beq		CheckError		;branch on error
	
	bra.s		Chunkloop		;loop to Chunkloop

;---------------------------------------------------------------------
;routine to skip through IFF chunks returning name (d0) and size (d3)
GetChunk:
	move.l		GrafFileHndl(a5),d1	;get file handle
	moveq		#8,d3			;length to read in d3
	CALLDOS		Read			;read name and length
	tst.l		d0			;read ok?
	beq.s 		.Error			;if error return error msg
	cmpi.l		#-1,d0			;test for errors
	beq		CheckError		;branch on error
	
	move.l		d2,a0			;buffer in a0
	move.l		(a0)+,d0		;name in d0 
	move.l		(a0)+,d3		;chunk length in d3
;------ round chunk length up to next word boundry
	addq.l		#1,d3			;add 1 to length 
	bclr		#0,d3			;make d3 even
.Error
	rts					;return with error or name in d0

;---------------------------------------------------------------------
ReadPic
	move.l		d3,d0			;get chunk size
	move.l		#MEMF_PUBLIC!MEMF_CLEAR,d1 ;set memory type
	CALLEXEC	AllocMem		;allocate memory for chunk
	move.l		d0,ChunkBuf(a5)	;save memory pointer
	beq		MemError		;branch if non allocated
	move.l		d3,ChunkLen(a5)	;store chunk length

;------	d3 still contains chunk length
	move.l		GrafFileHndl(a5),d1		;get file handle
	move.l		d2,-(sp)		;store d2
	move.l		d0,d2			;get buffer
	CALLDOS		Read			;read chunk
	move.l		(sp)+,d2		;restore d2
	cmpi.l		#-1,d0			;check for errors
	beq.s		ReadError		;branch on error
	move.l		ChunkBuf(a5),d0	;return buffer address
	rts
	
ReadError
	bsr.s		FreeChunk
	bsr		CheckError		;branch to error handler
	
;---------------------------------------------------------------------
FreeChunk
	move.l		ChunkLen(a5),d0	;get chunk length
	beq.s		NoChunk			;branch if no chunk size
	move.l		ChunkBuf(a5),a1	;get buffer address
	CALLEXEC	FreeMem			;free chunk buffer
NoChunk
	rts
	
*********************** reads BMHD chunk **************************

BMHD1:
	bsr.s		ReadPic			;d3 already loaded
	move.l		d0,a3			;set a3 to memory
	move.b		9(a3),Stencil(a5)	;Mask bit - 0 = no mask
	move.b		10(a3),ComprBit(a5)	;compression bit

	move.l		MyBitmap(a5),a4		;bitmap struct
	move.w		(a3),ilbm_Width(a4)	;screen width
	move.w		2(a3),ilbm_Height(a4)	;screen height
	move.b		8(a3),bm_Depth(a4)	;Depth

;------	guessing Viewmodes if no CAMG chunk
	tst.w		CAMGloaded(a5)		;CAMG already read ?
	bne.s		BMHDexit		;yes
 
	cmpi.w		#352,16(a3)		;352 (max. width) compared with width
	bls.s		bmhd11			;if 352 equal or less
	move.w		#$8000,ilbm_Modes(a4)	;HiRes flag in ViewModes
	
bmhd11:
	cmpi.w		#290,18(a3)		;290= max non interlaced height
	bls.s		BMHDexit		;if 290 equal or less
	or.w		#4,ilbm_Modes(a4)	;interlace flag in ViewModes

BMHDexit:
	cmpi.b		#6,bm_Depth(a4)		;check depth
	blt.s		NotHAM			;branch if less than 6
	or.w		#$800,ilbm_Modes(a4)	;HAM flag in ViewModes

NotHAM
	bsr.s		FreeChunk		;free chunk buffer
	rts

*********************** reads CMAP chunk **************************

CMAP1:
	bsr		ReadPic			;d3 already loaded
	move.l		d2,-(sp)		;store d2
	move.l		d0,a3			;buffer address in a3
	move.l		MyBitmap(a5),a4     	;bitmap struct
	divu		#3,d3			;reduce d3 to colour number
	cmpi.w		#32,d3			; = 3 * 32 (max)
	ble.s		AllocCMAP		;branch if no more than 32 colours 
	move.w		#32,d3			;set to 32 colours

; Allocate memory for Colourmap
AllocCMAP
	move.w		d3,d0			;num colours in d0
	ext.l		d0			;make long
	add.l		d0,d0			;number of bytes for CMAP
	addq.l		#2,d0			;extra for num colors word
	move.l		#MEMF_CLEAR!MEMF_PUBLIC,d1 ;set memory type
	CALLEXEC	AllocMem		;allocate CMAP memory		
	move.l		d0,ilbm_ColorMap(a4)	;store result
	beq.s		CMAPError		;branch on error
	move.l		d0,a2			;colourmap in a2
	move.w		d3,(a2)+		;save number of colours

; Build the ColorMap, starting with d3=ColorNumber	
CMAPloop:
	moveq		#0,d0			;clear d0
	moveq		#0,d1			;clear d1
	moveq		#0,d2			;clear d2
	move.b		(a3)+,d0		;get red
	move.b		(a3)+,d1		;get green
	move.b		(a3)+,d2		;get blue

;------	correct red	
	lsl.w		#4,d0			;shift to left correct position
	clr.b		d0
	
;------	correct green
	andi.w		#$f0,d1			;mask out lower nibble
	
;------	correct blue
	lsr.w		#4,d2  			;shift right to correct position
	
	or.w		d0,d1			;logical or red and green
	or.w		d1,d2			;logical or red/green and blue
	move.w		d2,(a2)+		;store result
	subq.w		#1,d3			;decrement counter
	bne.s		CMAPloop		;branch if not finished

	bsr		FreeChunk		;free chunk buffer
	move.l		(sp)+,d2		;restore d2
	rts

CMAPError
	bsr		FreeChunk		;free chunk buffer
	bra		MemError

*********************** reads CAMG chunk **************************

FLAGMASK	EQU	~(V_SPRITES!$2000!$100!GENLOCK_VIDEO)
CAMGMASK	EQU	FLAGMASK&$FFFF

CAMG1:
	bsr		ReadPic			;d3 already loaded
	move.l		d0,a3		   	;buffer address in a3
	move.l		MyBitmap(a5),a4		;bitmap struct
	move.w		2(a3),d0		;get modes
	andi.w		#CAMGMASK,d0		;clear unwanted flags
	move.w		d0,ilbm_Modes(a4)	;write ViewModes in ViewPort
	move.w		#-1,CAMGloaded(a5)	;flag viewmodes set

	bsr		FreeChunk	   	;free chunk buffer
	rts

*********************** reads GRAB chunk **************************

GRAB1:
	bsr		ReadPic			;d3 already loaded
	move.l		d0,a3		   	;buffer address in a3
	move.l		MyBitmap(a5),a4		;bitmap struct
	move.w		(a3)+,ilbm_GrabX(a4)	;store X co-ord
	move.w		(a3),ilbm_GrabY(a4)	;store Y co-ord

	bsr		FreeChunk	   	;free chunk buffer
	rts

*********************** reads BODY chunk **************************


BODY1:
;------	reads the BODY chunk and writes into the bitmap.
	move.l		MyBitmap(a5),a4	;bitmap struct
	
	moveq		#0,d5			;clear d5
	moveq		#0,d6			;clear d6
	moveq		#0,d7			;clear d7
	move.w		ilbm_Width(a4),d5	;extract width in pixels
	move.w		ilbm_Height(a4),d6	;extract height
	move.b		bm_Depth(a4),Depth(a5)	;extract depth
	lea		bm_Planes(a4),a2	;get planes array
	move.w		MemBlkType(a5),d0	;get type
	cmpi.b		#1,Stencil(a5)		;is there a stencil
	bne.s		IgnoreStencil		;branch if no stencil
	btst		#1,d0			;load mask ?
	beq.s		IgnoreStencil		;branch if not
	addq.b		#1,Depth(a5)		;add 1 to planes
	clr.b		Stencil(a5)		;treat mask as extra plane

IgnoreStencil
	move.b		Depth(a5),d7		;extract depth
	btst		#0,d0			;is it contiguous
	bne.s		Contiguous		;branch if contiguous
	
PlaneLoop
	move.l		d5,d0			;width in d0
	move.l		d6,d1			;height in d1	
	CALLGRAF	AllocRaster		;get a bitplane
	move.l		d0,(a2)+		;store result
	beq		MemError		;branch on error
	subq.l		#1,d7			;decrement depth
	bne.s		PlaneLoop		;branch till planes allocated
	bra.s		PlanesDone		;branch always

Contiguous
	addq.l		#8,d5			;add 15	quickly
	addq.l		#7,d5			;two addq's faster than one add
	lsr.w		#3,d5			;convert to bytes
	bclr		#0,d5			;round down to next word
	mulu		d5,d6			;calc size of bitplane
	moveq		#0,d0			;clear d0
	bra.s		Loopstrt		;start loop at bottom
Sizeloop
	add.l		d6,d0			;calc total size needed
Loopstrt					;mulu won't handle planes 
	dbra		d7,Sizeloop		;larger than 64K
	
	move.l		d0,d2			;store size
	move.l		#MEMF_CLEAR!MEMF_CHIP,d1 ;mem type
	CALLEXEC	AllocMem		;allocate picture memory
	tst.l		d0			;test result
	beq		MemError		;branch on mem error
	
	move.l		d2,ilbm_Size(a4)	;save size
	lea		bm_Planes(a4),a2	;get planes array in BitMap
	moveq		#0,d1			;clear d1
	move.b		Depth(a5),d1		;extract depth
	bra.s		Loopstrt2		;start loop at bottom
Bmloop
	move.l		d0,(a2)+		;store in array
	add.l		d6,d0			;get pointer to next plane		
Loopstrt2
	dbra		d1,Bmloop		;branch till planes array created
	
PlanesDone
	move.l		a4,a0			;get bitmap in a0
	moveq		#0,d0			;clear d0
	move.b		Depth(a5),d0		;extract depth
	moveq		#0,d1			;clear d1
	moveq		#0,d2			;clear d2
	move.w		ilbm_Width(a4),d1	;extract width in pixels
	move.w		ilbm_Height(a4),d2	;extract height
	CALLGRAF	InitBitMap		;initialize bitmap
	
	tst.b		ComprBit(a5)		;is it byterun compressed
	beq.s		NoCompression		;branch if not compressed

	move.l		#BuffSize,d0		;get buffer size
	move.l		#MEMF_CLEAR!MEMF_PUBLIC,d1 ;set mem type		
	CALLEXEC	AllocMem		;allocate load buffer
	move.l		d0,ReadBuffer(a5)	;store buffer address
	beq		MemError		;branch if no buffer
	move.l		d0,a3			;buffer in a3
	
	move.l		GrafFileHndl(a5),d1	;get filehandle
	move.l		d0,d2			;buffer in d2
	move.l		#BuffSize,d3		;size in d3
	CALLDOS		Read			;read in buffer
	cmpi.l		#-1,d0			;check for errors
	beq		CheckError		;branch on error
	
NoCompression	
	move.l		_DOSBase,a6		;set for DOS lib
	moveq		#0,d4			;clear plane offset

GetPlanes
	moveq		#0,d7			;set height counter
	move.w		ilbm_Height(a4),d7	;extract height
	subq.w		#1,d7			;set for dbra
	
GetScanline
	moveq		#0,d6			;set depth counter
	move.b		Depth(a5),d6		;extract height
	subq.w		#1,d6			;set for dbra
	
RowLoop
	bsr.s		GetRow			;get a row
	dbra		d6,RowLoop		;branch till we have 1 scanline
	
	cmpi.b		#1,Stencil(a5)		;is there a stencil
	bne.s		NoStencil		;branch if no stencil
	
	bsr		SkipMask		;skip over stencil
	
NoStencil
	add.w		(a4),d4			;add bytes per row to offset
	dbra		d7,GetScanline		;branch till all scanlines done

	tst.b		ComprBit(a5)		;test compression type
	beq.s		NoBuffer		;branch on no compression
	
	move.l		ReadBuffer(a5),a1	;get temp read buffer
	move.l		#BuffSize,d0		;and its size
	CALLEXEC	FreeMem			;then free it

NoBuffer
	move.l		a4,d0			;bitmap in d0 for return
	rts

;---------------------------------------------------------------------

GetRow
	moveq		#0,d0			;clear d0
	move.b		Depth(a5),d0		;extract depth
	sub.w		d6,d0			;subtract from index
	lsl.w		#2,d0			;multiply by 4
	move.l		bm_Planes-4(a4,d0.w),a2	;get plane add from array
	adda.l		d4,a2			;add plane offset 
	
	tst.b		ComprBit(a5)		;test compression type
	beq.s		NoCompRow		;branch on no compression

	moveq		#0,d1			;clear d1
UnPackRow
	moveq		#0,d0			;clear d0
	move.b		(a3)+,d0		;get a byte of data
	bsr.s		CheckBuff		;check for buffer overflow
	cmpi.b		#-128,d0		;is it a no-op
	beq.s		UnPackRow		;yes branch back
	
	tst.b		d0			;test source byte
	bmi.s		Replicate		;branch if -1 to -127

Copyloop	
	move.b		(a3)+,(a2)+		;copy bytes
	addq.w		#1,d1			;bump byte counter
	bsr.s		CheckBuff		;check for buffer overflow
	dbra		d0,Copyloop		;branch back if not done
	
	bra.s		CheckRow		;branch always		

Replicate
	neg.b		d0			;make d0 positive
	move.b		(a3)+,d2		;copy bytes
	bsr.s		CheckBuff		;check for buffer overflow
	
Reploop
	move.b		d2,(a2)+		;replicate next byte
	addq.w		#1,d1			;bump byte counter
	dbra		d0,Reploop		;branch back if not done

CheckRow	
	cmp.w		(a4),d1			;is row complete
	blt.s		UnPackRow		;no carry on decoding
	bhi		FaultyCompError		;branch on compression error
	rts

;---------------------------------------------------------------------

NoCompRow
	move.l		GrafFileHndl(a5),d1	;get file handle
	move.l		a2,d2			;set read buffer
	moveq		#0,d3			;clear d3
	move.w		(a4),d3			;bytes to read
	CALLSYS		Read			;into bitplane
	cmpi.l		#-1,d0			;check for errors
	beq		CheckError		;branch if error
	rts

;---------------------------------------------------------------------
CheckBuff
	subq.w		#1,d3			;decrement counter
	bne.s		BuffOK			;branch if not empty
	
	movem.l		d0-d2,-(sp)		;save regs
	move.l		GrafFileHndl(a5),d1	;filehandle in d1
	move.l		ReadBuffer(a5),d2	;buffer add in d2
	move.l		#BuffSize,d3		;buffer size in d3
	CALLSYS		Read			;reload buffer
	cmpi.l		#-1,d0			;check for errors
	beq.s		BuffReadError		;branch on error
	move.l		d2,a3			;buffer add in a4
	movem.l		(sp)+,d0-d2		;restore regs
	
BuffOK
	rts
	
BuffReadError
	movem.l		(sp)+,d0-d2		;restore regs
	move.l		ReadBuffer(a5),a1	;get temp read buffer
	move.l		#BuffSize,d0		;and its size
	CALLEXEC	FreeMem			;then free it

	bra		CheckError		;branch to error handler
	
;---------------------------------------------------------------------
SkipMask:
	tst.b		ComprBit(a5)		;test compression type
	beq.s		NoCompMask		;branch on no compression
	
	moveq		#0,d1			;clear d1
CSkiploop
	moveq		#0,d0			;clear d0
	move.b		(a3)+,d0		;get a byte of data
	bsr.s		CheckBuff		;check for buffer overflow
	cmpi.b		#-128,d0		;is it a no-op
	beq.s		CSkiploop		;yes branch back
	
	tst.b		d0			;test source byte
	bmi.s		Replicate2		;branch if -1 to -127

Copyloop2	
	move.b		(a3)+,d2		;copy bytes
	addq.w		#1,d1			;bump byte counter
	bsr.s		CheckBuff		;check for buffer overflow
	dbra		d0,Copyloop2		;branch back if not done
	
	cmp.w		(a4),d1			;is row complete
	blt.s		CSkiploop		;no carry on decoding
	rts

Replicate2
	neg.b		d0			;make d0 positive
	addq.w		#1,d0			;add 1 for first byte
	add.w		d0,d1			;add copy num to byte counter 
	addq.l		#1,a3			;skip over copy byte 	
	bsr.s		CheckBuff		;check for buffer overflow
	
	cmp.w		(a4),d1			;is row complete
	blt.s		CSkiploop		;no carry on decoding
	rts
	
;---------------------------------------------------------------------
NoCompMask
	move.l		GrafFileHndl(a5),d1	;get file handle
	moveq		#0,d3			;clear d3
	move.w		(a4),d2			;bytes to read
	moveq		#OFFSET_CURRENT,d3	;set seek type
	CALLSYS		Seek			;into bitplane
	cmpi.l		#-1,d0			;check for errors
	beq.s		CheckError		;branch on error
	rts

;---------------------------------------------------------------------
CleanupGraf:
	tst.l		d0
	beq.s		NoBitmap
	
	movem.l		a2-a6/d2-d7,-(sp)	;store regs
	move.l		d0,a2			;get graf struct
	move.l		ilbm_Size(a2),d0	;get size
	beq.s		NotContiguous		;branch if not contiguous block
	move.l		bm_Planes(a2),a1	;get block
	CALLEXEC	FreeMem
	bra.s		NoPlane
	
NotContiguous	
	moveq		#0,d5			;clear d5
	moveq		#0,d6			;clear d6
	moveq		#0,d7			;clear d7
	move.w		ilbm_Width(a2),d5	;extract width in pixels
	move.w		ilbm_Height(a2),d6	;extract height
	move.b		bm_Depth(a2),d7		;extract depth
	ext.w		d7			;extend to word length		
	lea		bm_Planes(a2),a4	;get planes array

;------	Use dbra without subtracting 1. This will automatically de-allocate
;	a stencil plane if allocated. Otherwise loop will end at beq.s NoPlane
FreePlaneLoop
	move.l		(a4)+,d0		;get plane ptr
	beq.s		NoPlane			;branch if none allocated
	move.l		d0,a0			;plane in a0
	move.l		d5,d0			;width in d0
	move.l		d6,d1			;height in d1	
	CALLGRAF	FreeRaster		;free a bitplane
	dbra		d7,FreePlaneLoop	;branch till planes allocated
	
NoPlane
	move.l		ilbm_ColorMap(a2),d0	;get colourmap
	beq.s		NoCMAP			;branch if no CMAP
	move.l		d0,a1			;CMAP in a1
	move.w		(a1),d0			;num colours in d0
	ext.l		d0			;make long
	add.l		d0,d0			;convert to CMAP size
	addq.l		#2,d0			;add size word
	CALLEXEC	FreeMem
	
NoCMAP
	move.l		a2,a1			;get graf struct
	moveq		#ilbm_SIZEOF,d0		;and size
	CALLEXEC	FreeMem
	
	movem.l		(sp)+,a2-a6/d2-d7	;restore regs

NoBitmap
	rts

;---------------------------------------------------------------------
CheckError
	move.l		MyBitmap(a5),d0
	bsr.s		CleanupGraf
	CALLDOS		IoErr			;get file error
	move.l		d0,d1			;place in d1
	bra.s		ReturnError		;branch to cleanup and quit
	
;---------------------------------------------------------------------
MemError
	move.l		MyBitmap(a5),d0
	bsr		CleanupGraf
	moveq		#1,d1			;flag memory error
	bra.s		ReturnError		;branch to cleanup and quit
	
;---------------------------------------------------------------------
FaultyCompError
	move.l		MyBitmap(a5),d0
	bsr		CleanupGraf
	moveq		#2,d1			;flag iff comp error

ReturnError	
	moveq		#0,d0			;flag error

;------	Unlk has the nice property of correcting the stack for us
	unlk		a5			;free stack
	movem.l		(sp)+,a2-a6/d2-d7	;restore regs
	rts
	
;---------------------------------------------------------------------

MyBitmap	EQU	-4
ComprBit	EQU	-5
Stencil		EQU	-6
Depth		EQU	-8
MemBlkType	EQU	-10
CAMGloaded	EQU	-12
ReadBuffer	EQU	-16
GrafFileHndl	EQU	-20
ChunkLen	EQU	-24
ChunkBuf	EQU	-28
Temp		EQU	-40
BlkSIZEOF	EQU	-40

*******************************************************************
;	This is the custom structure returned by LoadILBM
*******************************************************************
	
	rsreset
ilbm_Bitmap	rs.b	bm_SIZEOF
ilbm_Pad	rs.l	1		;extra long for stencil plane
ilbm_Size	rs.l	1		;so we can still have up to 
ilbm_Width	rs.w	1		;8 planes
ilbm_Height	rs.w	1
ilbm_GrabX	rs.w	1
ilbm_GrabY	rs.w	1
ilbm_Modes	rs.w	1
ilbm_ColorMap	rs.l	1
ilbm_CycleInfo	rs.l	1		;will point to a linked list
ilbm_SIZEOF	rs.b	0		;of colour cycling info 

;Load options

ILBMCONTIGUOUS	EQU	$0001
ILBMLOADSTENCIL	EQU	$0002

;Error Return Codes

ILBMMEMERROR	EQU	$01
ILBMCOMPERROR	EQU	$02
ILBMTYPEERROR	EQU	$04



