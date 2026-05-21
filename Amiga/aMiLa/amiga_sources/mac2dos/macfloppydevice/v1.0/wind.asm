*********************************************************
*							*
*		WIND.ASM				*
*							*
* 	Mac-2-Dos File Window Routines			*
*							*
*	Copyright (c) 1989 Central Coast Software	*
*	424 Vista Ave, Golden, CO 80401			*
*	All rights reserved, worldwide			*
*********************************************************

;	INCLUDE "mac.i"
;	INCLUDE	"VD0:MACROS.ASM"
	INCLUDE	"PRE.OBJ"
	INCLUDE	"boxes.asm"

	XDEF	ClearMacWindow,ClearDosWindow
	XDEF	ClearMacFiles,ClearDosFiles
	XDEF	BuildMacDir,BuildDosDir
	XDEF	UpdateDosWindow,UpdateMacWindow
	XDEF	ScrollLeftWindow,ScrollRightWindow
	XDEF	LeftUpArrow,LeftDnArrow,LeftPropHit
	XDEF	RightUpArrow,RightDnArrow,RightPropHit
	XDEF	APARENT,AROOT,MPARENT,MROOT
	XDEF	DosFileGad,MacFileGad
	XDEF	UpdateMacPath
	XDEF	UpdateMacVol
	XDEF	UpdateDosPath
	XDEF	UpdateMacSpace
	XDEF	UpdateDosSpace,ReloadDosSpace
	XDEF	MarkVolInvalid
	XDEF	GetDosVolume,DispDosDir

	XDEF	TMP.,TMP2.
	XDEF	UpdLWinFlg,UpdRWinFlg
	XDEF	NoMacDisk
	XDEF	MacFileCnt,DosFileCnt
	XDEF	MacToAmy

	XREF	SysBase,DosBase,IntuitionBase,GraphicsBase
	XREF	MacRootLevel,MacCurLevel
	XREF	DosRootLevel,DosCurLevel
	XREF	MSG_CLASS,GAD_PTR,FontPtr
	XREF	LOCK

;	XREF	SetArrowLeft,SetArrowRight
	XREF	GetVolName
	XREF	BuildDosPath,BldCurrentDosDir
	XREF	DosLowerLevel,DosParentLevel
	XREF	AppendDosPath,TruncateDosPath
	XREF	AppendMacPath,TruncateMacPath
;	XREF	LoadDirName
	XREF	CurrentDosPath
	XREF	ExcAll
	XREF	ExcMac,ExcDos

	XREF	WINDOW
	XREF	G_LeftProp,LeftPropPOT,LeftPropBODY
	XREF	G_RightProp,RightPropPOT,RightPropBODY
	XREF	G_COPY
	XREF	RT_ARROW,LT_ARROW,ARROW
	XREF	YESTXT,CANTXT,ASKCONT
	XREF	ABUF,CBUF,DBUF,MACDISK.
	XREF	MacVTxt

	XREF	VolBuf
;	XREF	ConvFlag
;	XREF	MacToAmy

	XREF	MacPath.,DosPath.
	XREF	MacVolName.,DosVolName.
	XREF	ValidMacVol,ValidDosVol

* Externals in DISK.ASM

	XREF	DiskLog,MotorOff

SPACE		EQU	32
FontHt		EQU	8

*************************************************************************
*	Macintosh (left) window routines				*
*************************************************************************

* Builds and Displays Mac directory in Mac window.

BuildMacDir:
	BSR	ClearMacWindow		;ERASE OLD DIR FRON SCREEN
	CLR.W	CurEnt
	CLR.W	MacMaxEnt
	IFNZB	ValidMacVol,3$		;if same disk, don't reread directory
	DispMsg	#LDIR_LE+40,#LDIR_TE+56,ReadMacDir.,WHITE,BLACK
	BSR	DiskLog	
	NOERROR	3$			;no disk...forget it
	BSR	MarkVolInvalid		;show not a Mac disk
	BRA.S	9$
3$:	BSR	GetVolName		;load volume name into MacVolName.
	BSR	UpdateMacVol
	LEA	MacRootLevel,A0		;display root level first
	MOVE.L	A0,MacCurLevel
	MOVE.L	dl_ChildPtr(A0),dl_CurFib(A0)
	BSR	CountMacMaxEnt
	BSR	UpdateMacPath
	BSR	UpdateMacWindow
;	BSR	LeftScrollBar
	BSR	UpdateMacSpace
9$:	BSR	MotorOff		;TURN OFF DRIVE
	RTS

MarkVolInvalid:
	BSR	ClearMacWindow
	CLR.B	ValidMacVol
	DispMsg	#MVGAD_LE,#MVGAD_TE,InvMacDisk.,WHITE,BLUE
	RTS

* Displays current directory in Mac window.

UpdateMacWindow:
	BSR	ClearMacFiles
UpdMacWinNoClear:
	PUSH	D2/A3
;	CLR.W	MacFileCnt		;NO FILES YET
	MOVE.L	MacCurLevel,A3		;current level
	IFZL	A3,9$			;nothing to display
	MOVE.L	dl_CurFib(A3),A3	;first file entry in window
	ZAP	D2			;line counter

1$:	INCW	D2
	IFGTIW	D2,#MaxFileGads,2$	;thats all we can have on screen
	MOVE.L	A3,A0
	IFZL	A0,2$			;no more files
	MOVE.L	(A0),A3			;get link to next entry
	MOVE.L	D2,D0			;display on this line of file wind
	BSR	DispMacFile		;display one line of file info
	BRA.S	1$

2$:	BSR	CountMacMaxEnt		;recalc number displayed
	BSR	LeftScrollBar		;update pos of scroll gadget
;	BSR	UpdateMacSpace
	CLC
9$:	POP	D2/A3
	RTS

UpdateMacSpace:
	CLRBOX	MFS,BLUE
	BSR	CalcMacSpace		;CALC SPACE AND MAKE STRING
	DispMsg	#MFS_LE+4,#MFS_TE+2,TMP.,WHITE,BLUE ;DISPLAY FREE BYTES
	RTS

UpdateMacPath:
	CLRBOX	MPATH,BLUE
	MOVE.	MacPath.,TMP.
	IFNZB	TMP.,1$
	MOVE.	Root.,TMP.
1$:	LEA	TMP.,A0
	CLR.B	39(A0)			;truncate to safe length
	DispMsg	#MPATH_LE+2,#MPATH_TE+2,TMP.,ORANGE
	RTS

UpdateMacVol:
	MOVE.	MacVolName.,TMP.
	CLR.B	TMP.+23			;limit Mac vol name
	DispMsg	#MVGAD_LE,#MVGAD_TE,TMP.,WHITE,BLUE 
	RTS

* Builds and displays one line of Mac directory.  Dir line number (1-20) in D0.
* Ptr to CurFib in A0.

DispMacFile:
	PUSH	D2-D5/A2-A5
;	INCW	MacFileCnt		;count the file
	MOVE.L	D0,D4			;line number
	MOVE.L	A0,A4			;CurFib
	MOVE.L	WINDOW,A5
	MOVE.L	wd_RPort(A5),A5
	MOVEQ	#JAM2,D0
	MOVE.L	A5,A1
	CALLSYS	SetDrMd,GraphicsBase
	MOVE.L	FontPtr,A0
	MOVE.L	A5,A1
	CALLSYS	SetFont			;force topaz 80
	MOVEQ	#WHITE,D2		;unselected file and dir
	MOVEQ	#BLACK,D3		;background
	BTST	#7,df_Flags(A4)		;directory?
	BNE.S	1$			;yes
;	EXG	D2,D3			;else select file colors
	BTST	#6,df_Flags(A4)		;file selected?
	BEQ.S	1$			;NO
	MOVEQ	#ORANGE,D3		;selected file colors
	MOVEQ	#BLACK,D2		;foreground
1$:	MOVE.L	D2,D0
	MOVE.L	A5,A1
	CALLSYS	SetAPen
	MOVE.L	D3,D0
	MOVE.L	A5,A1
	CALLSYS	SetBPen
	DECW	D4			;change to 0 origin for line
	MULU	#FontHt,D4		;figure out which line we are on
	ADD.W	#LDIR_TE+8,D4		;font offset + border
	MOVE.W	D4,D1			;y pos
	MOVE.W	#LDIR_LE+4,D0		;x pos
	MOVE.L	A5,A1
	CALLSYS	Move			;set x,y pos to proper line
	LEA	df_Name(A4),A0
	BSR	MovePad			;move to TMP. and pad to 31 chars
	MOVE.L	A1,A3			;save ptr to end of name string
	BTST	#7,df_Flags(A4)		;folder?
	BEQ.S	2$			;no...file
	APPEND.	Folder.,TMP.
	BRA.S	3$
2$:	BSR	BuildFileSize		;build filesize string in TMP2.

* This kludge puts highest byte of size, if non-blank, over last char of name.
* Only clobbers last name char if file size >999,999.

	LEA	TMP2.,A0
	MOVE.B	(A0)+,D0		;get 1st char of size
	IFEQIB	D0,#SPACE,4$		;it is space...ignore it
	MOVE.B	D0,-(A3)		;move 1st size char over last name char
4$:	APPEND.	A0,TMP.
;	ZAP	D0
3$:	LEN.	TMP.			;load A0, set D0 to length
	MOVE.L	A5,A1
	CALLSYS	Text			;send size/date/time to that line
	MOVEQ	#BLACK,D0		;restore background color
	MOVE.L	A5,A1
	CALLSYS	SetBPen
	POP	D2-D5/A2-A5
	RTS

* Clears Mac window.

ClearMacWindow:
	CLRBOX	MVGAD_LE,MVGAD_TE,MVGAD_WD,MVGAD_HT,BLUE
	CLRBOX	MPATH,BLUE
	CLRBOX	MFS,BLUE
ClearMacFiles:
	CLRBOX	LDIR,BLACK
	RTS

* Left wondow scrolling arrows

LeftUpArrow:
	IFEQL	MSG_CLASS,#GADGETUP,9$	;ignore up
	BSR	LeftNextUp
	BSR	LeftScrollBar
	BSR	ScrollDelay
	MOVE.L	GAD_PTR,A0
	BTST	#7,gg_Flags+1(A0)	;gadget still selected?
	BNE.S	LeftUpArrow		;yes
9$:	RTS				;else bail out

LeftNextUp:
	MOVE.L	MacCurLevel,A1
	MOVE.L	dl_ChildPtr(A1),A0
	MOVE.L	dl_CurFib(A1),A2
	IFEQL	A0,A2,9$		;already at top...can't do more
1$:	MOVE.L	A0,A3			;save ptr to 'previous'
	MOVE.L	df_Next(A0),A0
	IFNEL	A0,A2,1$		;loop till we find the current one
	MOVE.L	A3,dl_CurFib(A1)	;and make this one current top
	BSR	LeftScrollDown		;else make room at top
	MOVEQ	#1,D0			;display at line 1
	MOVE.L	A3,A0
	BSR	DispMacFile		;fill it in
	IFZW	CurEnt,8$
	DECW	CurEnt
8$:	RTS
9$:	CLR.W	CurEnt
	STC
	RTS

LeftDnArrow:
	IFEQL	MSG_CLASS,#GADGETUP,9$	;ignore up
	BSR	LeftNextDown
	BSR	LeftScrollBar
	BSR	ScrollDelay
	MOVE.L	GAD_PTR,A0
	BTST	#7,gg_Flags+1(A0)	;gadget still selected?
	BNE.S	LeftDnArrow		;yes
9$:	RTS				;else bail out

LeftNextDown:
	MOVE.L	MacCurLevel,A1		;this level
	MOVE.L	dl_CurFib(A1),A2	;get current top entry
	MOVE.L	A2,A0
	ZAP	D0			;start at level 1
1$:	MOVE.L	df_Next(A0),A0		;else get link
2$:	IFZL	A0,9$			;end of list before line 20
	INCW	D0
	IFLTIW	D0,#MaxFileGads,1$	;loop till we find last one
	MOVE.L	A0,A3			;save ptr to new last line
	MOVE.L	df_Next(A2),dl_CurFib(A1) ;make next entry the top item
	BSR	LeftScrollUp		;make room at bottom
	MOVEQ	#MaxFileGads,D0		;goes on line 20
	MOVE.L	A3,A0
	BSR	DispMacFile
	INCW	CurEnt
	RTS
9$:	STC
	RTS

LeftPropHit:
	MOVE.L	WINDOW,A0
	MOVE.L	wd_IDCMPFlags(A0),D0
	BCLR	#4,D0			;disable mousemove
	IFEQIL	MSG_CLASS,#GADGETUP,1$	;turn off mouse
	BSET	#4,D0			;enable mousemove
	SETF	UpdLWinFlg
1$:	CALLSYS	ModifyIDCMP,IntuitionBase ;enable/disable the mouse
	RTS

* Updates size and position of left scroll bar

LeftScrollBar:
	PUSH	D2-D5/A2
	MOVEQ	#-1,D1
	MOVE.W	D1,D4			;default body
	ZAP	D2			;default pot
	MOVEQ	#MaxFileGads,D0
	IFLEW	MacMaxEnt,D0,1$		;entire list on screen
;	IFGEW	D0,D2,1$		;entire text on screen
;	ZAP	D2
	MOVE.W	MacMaxEnt,D2
	MULU	D1,D0
	DIVU	D2,D0
	MOVE.W	D0,D4			;new slider size
	ZAP	D0
	MOVE.W	CurEnt,D0
	SUB.W	#MaxFileGads,D2
	MULU	D1,D0
	DIVU	D2,D0
	MOVE.W	D0,D2
1$:	LEA	G_LeftProp,A0
	MOVEQ	#5,D0
	ZAPA	A2
	MOVEQ	#1,D5
	MOVE.L	WINDOW,A1
	CALLSYS	NewModifyProp,IntuitionBase
	POP	D2-D5/A2
	RTS

ScrollLeftWindow:
	IFLEIW	MacMaxEnt,#MaxFileGads,9$,L ;nothing to scroll
	MOVE.W	MacMaxEnt,D1
	SUB.W	#MaxFileGads,D1		;calc based on top of window
	MOVE.W	D1,D0
	MULU	LeftPropPOT,D0
	DIVU	#$FFFF,D0
	IFLEW	D0,D1,13$		;valid pos
	MOVE.W	D1,D0
13$:	MOVE.W	D0,D6			;new pos
	MOVE.W	CurEnt,D7		;old pos to D7
	IFEQW	D0,D7,9$		;no change in pos...ignore it
	BCS.S	3$			;new>old...
	SUB.W	D0,D7			;new<old...how far?
	IFGTIW	D7,#5,5$		;more than 5
11$:	BSR	LeftNextUp
	ERROR	9$
	IFGTW	CurEnt,D6,11$		;loop till we'e there
	BRA.S	9$
3$:	SUB.W	D7,D0			;how far?
	IFGTIW	D0,#5,5$		;more than 5
12$:	BSR	LeftNextDown
	ERROR	9$
	IFLTW	CurEnt,D6,12$		;loop till we're there
	BRA.S	9$
5$:	MOVE.L	MacCurLevel,A0
	MOVE.L	dl_ChildPtr(A0),A1	;this is where we start counting
	BEQ.S	9$			;nothing to search
	MOVE.W	D6,CurEnt
	MOVE.W	D6,D1			;looking for this entry
	BEQ.S	8$			;first entry
6$:	MOVE.L	df_Next(A1),A1		;try the next one
	IFZL	A1,9$			;end of list...corrupted?
	DECW	D1			;when it goes to 0, we've found it
	BNE.S	6$			;not end of list...keep checking
8$:	MOVE.L	A1,dl_CurFib(A0)	;make this one the top item
	BSR	UpdMacWinNoClear	;and redisplay window
9$:	CLR.B	UpdLWinFlg
	RTS

* Scrolls the entire window one row up.

LeftScrollUp:
	MOVEQ	#FontHt,D1		;delta y
	BRA.S	LScrollCom

* Scrolls the entire window one row down.

LeftScrollDown:
	MOVEQ	#FontHt,D1		;delta y
	NEG.L	D1			;move away from 0,0
LScrollCom:
	MOVE.L	#LDIR_TE+1,D3		;miny
	MOVE.L	#LDIR_TE+LDIR_HT-3,D5	;maxy
	ZAP	D0			;delta x	
	MOVE.L	#LDIR_LE+2,D2		;minx
	MOVE.L	#LDIR_LE+LDIR_WD-3,D4	;maxx
	MOVE.L	WINDOW,A0
	MOVE.L	wd_RPort(A0),A1
	CALLSYS	ScrollRaster,GraphicsBase
	RTS

NoMacDisk:
	DispMsg	#MVGAD_LE,#MVGAD_TE,NoMacDisk.
	RTS

*************************************************************************
*	Amiga (right) window routines					*
*************************************************************************

* Builds and displays ADOS dir in right dir window.
* Called only at startup or when disk is changed.

BuildDosDir:
	BSR	GetDosVolume
	RTSERR
DispDosDir:
	BSR	UpdateDosPath		;display the current dir as path
	BSR	BldCurrentDosDir	;build dir for current dir
	BSR	LoadDosFreeSpace	;get free space for disk
	BSR	UpdateDosWindow		;put dir on screen
	BSR	UpdateDosSpace		;display free space
	RTS

GetDosVolume:
	BSR	ClearDosWindow		;clean up window
	CLR.B	ValidDosVol		;no longer valid dir info
	CLR.W	DosCurEnt
	CLR.W	DosMaxEnt
	BSR	BuildDosPath		;set path to current dir
	ERROR	9$
	DispMsg	#AVGAD_LE,#AVGAD_TE,DosVolName.,WHITE,BLUE
9$:	RTS

* DISPLAYS ADOS directory.

UpdateDosWindow:
	BSR	ClearDosFiles
UpdDosWinNoClear:
	PUSH	D2/A3
	MOVE.L	DosCurLevel,A3		;current level
	IFZL	A3,9$			;nothing to display
	MOVE.L	dl_CurFib(A3),A3	;first file entry in window
	ZAP	D2			;line counter
1$:	INCW	D2
	IFGTIW	D2,#MaxFileGads,2$	;thats all we can have on screen
	MOVE.L	A3,A0
	IFZL	A0,2$			;no more files
	MOVE.L	(A0),A3			;get link to next entry
	MOVE.L	D2,D0			;display on this line of file wind
	BSR	DispDosFile		;display one line of file info
	BRA.S	1$
2$:	BSR	CountDosMaxEnt
	BSR	RightScrollBar		;update pos of scroll gadget
	CLC
9$:	POP	D2/A3
	RTS

* Builds and displays one line of Mac directory.  Dir line number (1-20) in D0.
* Ptr to CurFib in A0.

DispDosFile:
	PUSH	D2-D5/A2-A5
	MOVE.L	D0,D4			;line number
	MOVE.L	A0,A4			;CurFib
	MOVE.L	WINDOW,A5
	MOVE.L	wd_RPort(A5),A5
	MOVEQ	#JAM2,D0
	MOVE.L	A5,A1
	CALLSYS	SetDrMd,GraphicsBase
	MOVE.L	FontPtr,A0
	MOVE.L	A5,A1
	CALLSYS	SetFont			;force topaz 80
	MOVEQ	#WHITE,D2		;dir or unselected file colors
	MOVEQ	#BLACK,D3		;background
	BTST	#7,df_Flags(A4)		;directory?
	BNE.S	1$			;yes
;	EXG	D2,D3			;else select file colors
	BTST	#6,df_Flags(A4)		;file selected?
	BEQ.S	1$			;no
	MOVEQ	#ORANGE,D3		;file selected colors
	MOVEQ	#BLACK,D2		;foreground
1$:	MOVE.L	D2,D0
	MOVE.L	A5,A1
	CALLSYS	SetAPen
	MOVE.L	D3,D0
	MOVE.L	A5,A1
	CALLSYS	SetBPen
	DECW	D4			;change to 0 origin for line
	MULU	#FontHt,D4		;figure out which line we are on
	ADD.W	#RDIR_TE+8,D4		;font offset + border
	MOVE.W	D4,D1			;y pos
	MOVE.W	#RDIR_LE+4,D0		;x pos
	MOVE.L	A5,A1
	CALLSYS	Move			;set x,y pos to proper line
	LEA	df_Name(A4),A0
	BSR	MovePad			;move to TMP. and pad to 31 chars
	MOVE.L	A1,A3			;save ptr to end of name string
	BTST	#7,df_Flags(A4)		;drawer?
	BEQ.S	2$			;no...file
	APPEND.	Drawer.,TMP.
	BRA.S	3$
2$:	BSR	BuildFileSize		;build filesize string in TMP2.

* This kludge puts highest byte of size, if non-blank, over last char of name.
* Only clobbers last name char if file size >999,999.

	LEA	TMP2.,A0
	MOVE.B	(A0)+,D0		;get 1st char of size
	IFEQIB	D0,#SPACE,4$		;it is space...ignore it
	MOVE.B	D0,-(A3)		;move 1st size char over last name char
4$:	APPEND.	A0,TMP.
;	ZAP	D0
3$:	LEN.	TMP.			;load A0, set D0 to length
	MOVE.L	A5,A1
	CALLSYS	Text			;send size/date/time to that line
	MOVEQ	#BLACK,D0		;restore background color
	MOVE.L	A5,A1
	CALLSYS	SetBPen
	POP	D2-D5/A2-A5
	RTS

* Displays Dos disk free space.

ReloadDosSpace:
	BSR	LoadDosFreeSpace
UpdateDosSpace:
	MOVE.L	DI_NBLKS,D0		;TOTAL BLOCKS
	SUB.L	DI_USED,D0		;MINUS NUMBER USED=FREE BLOCKS
	MOVE.L	DI_BYTES,D1
	MULU	D1,D0			;TIMES BYTES PER BLOCK
	BSR	BuildDiskFreeSpace
	DispMsg	#AFS_LE+4,#AFS_TE+2,TMP.,WHITE,BLUE ;DISPLAY FREE BYTES
	RTS

* Redisplays the current Dos subdirectory path minus the root string.

UpdateDosPath:
	CLRBOX	APATH,BLUE
	MOVE.	DosPath.,TMP.
	LEA	TMP.,A0			;scan path past root string
3$:	MOVE.B	(A0)+,D1
	BEQ.S	2$			;nothing in path...use root
	IFEQIB	D1,#':',1$		;found end of root string
	BRA.S	3$
1$:	TST.B	(A0)			;anything left?
	BNE.S	4$			;yes...use it
2$:	MOVE.	Root.,TMP.
	LEA	TMP.,A0
4$:	CLR.B	39(A0)			;truncate to safe length
	DispMsg	#APATH_LE+2,#APATH_TE+2,A0,ORANGE
	RTS

* Clears files from Dos window.

ClearDosWindow:
	CLRBOX	AVGAD_LE,AVGAD_TE,AVGAD_WD,AVGAD_HT,BLUE
;	CLRBOX	AVGAD,BLUE
	CLRBOX	AFS,BLUE
	CLRBOX	APATH,BLUE
ClearDosFiles:
	CLRBOX	RDIR,BLACK
	RTS

* Right wondow scrolling arrows

RightUpArrow:
	IFEQL	MSG_CLASS,#GADGETUP,9$	;ignore up
	BSR	RightNextUp
	BSR	RightScrollBar
	BSR	ScrollDelay
	MOVE.L	GAD_PTR,A0
	BTST	#7,gg_Flags+1(A0)	;gadget still selected?
	BNE.S	RightUpArrow		;yes
9$:	RTS				;else bail out

RightNextUp:
	PUSH	A2-A3
	MOVE.L	DosCurLevel,A1
	MOVE.L	dl_ChildPtr(A1),A0
	MOVE.L	dl_CurFib(A1),A2
	IFEQL	A0,A2,9$		;already at top...can't do more
1$:	MOVE.L	A0,A3			;save ptr to 'previous'
	MOVE.L	df_Next(A0),A0
	IFNEL	A0,A2,1$		;loop till we find the current one
	MOVE.L	A3,dl_CurFib(A1)	;and make this one current top
	BSR	RightScrollDown		;else make room at top
	MOVEQ	#1,D0			;display at line 1
	MOVE.L	A3,A0
	BSR	DispDosFile		;fill it in
	IFZW	DosCurEnt,8$
	DECW	DosCurEnt
	BRA.S	8$
9$:	CLR.W	DosCurEnt
	STC
8$:	POP	A2-A3
	RTS

RightDnArrow:
	IFEQL	MSG_CLASS,#GADGETUP,9$	;ignore up
	BSR	RightNextDown
	BSR	RightScrollBar
	BSR	ScrollDelay
	MOVE.L	GAD_PTR,A0
	BTST	#7,gg_Flags+1(A0)	;gadget still selected?
	BNE.S	RightDnArrow		;yes
9$:	RTS				;else bail out

RightNextDown:
	PUSH	A2-A3
	MOVE.L	DosCurLevel,A1		;this level
	MOVE.L	dl_CurFib(A1),A2	;get current top entry
	MOVE.L	A2,A0
	ZAP	D0			;start at level 1
1$:	MOVE.L	df_Next(A0),A0		;else get link
2$:	IFZL	A0,9$			;end of list before line 20
	INCW	D0
	IFLTIW	D0,#MaxFileGads,1$	;loop till we find last one
	MOVE.L	A0,A3			;save ptr to new last line
	MOVE.L	df_Next(A2),dl_CurFib(A1) ;make next entry the top item
	BSR	RightScrollUp		;make room at bottom
	MOVEQ	#MaxFileGads,D0		;goes on last line
	MOVE.L	A3,A0
	BSR	DispDosFile
	INCW	DosCurEnt
	BRA.S	8$
9$:	STC
8$:	POP	A2-A3
	RTS

RightPropHit:
	MOVE.L	WINDOW,A0
	MOVE.L	wd_IDCMPFlags(A0),D0
	BCLR	#4,D0			;disable mousemove
	IFEQIL	MSG_CLASS,#GADGETUP,1$	;turn off mouse
	BSET	#4,D0			;enable mousemove
	SETF	UpdRWinFlg
1$:	CALLSYS	ModifyIDCMP,IntuitionBase ;enable/disable the mouse
	RTS

* Updates size and position of Right scroll bar.

RightScrollBar:
	PUSH	D2-D5/A2
	MOVEQ	#-1,D1
	MOVE.W	D1,D4			;default body
	ZAP	D2			;default pot
	MOVEQ	#MaxFileGads,D0
	IFLEW	DosMaxEnt,D0,1$		;entire list on screen
;	IFGEW	D0,D2,1$		;entire text on screen
;	ZAP	D2
	MOVE.W	DosMaxEnt,D2
	MULU	D1,D0
	DIVU	D2,D0
	MOVE.W	D0,D4			;new slider size
	ZAP	D0
	MOVE.W	DosCurEnt,D0
	SUB.W	#MaxFileGads,D2
	MULU	D1,D0
	DIVU	D2,D0
	MOVE.W	D0,D2
1$:	LEA	G_RightProp,A0
	MOVEQ	#5,D0
	ZAPA	A2
	MOVEQ	#1,D5
	MOVE.L	WINDOW,A1
	CALLSYS	NewModifyProp,IntuitionBase
	POP	D2-D5/A2
	RTS

* Called from WaitForMsg in MAC.ASM when UpdRWinFlg is set.

ScrollRightWindow:
	PUSH	D2-D7
	IFLEIW	DosMaxEnt,#MaxFileGads,9$,L ;nothing to scroll
	MOVE.W	DosMaxEnt,D1
	SUB.W	#MaxFileGads,D1		;calc based on top of window
	MOVE.W	D1,D0
	MULU	RightPropPOT,D0
	DIVU	#$FFFF,D0
	IFLEW	D0,D1,13$		;valid pos
	MOVE.W	D1,D0
13$:	MOVE.W	D0,D6			;new pos
	MOVE.W	DosCurEnt,D7		;old pos to D7
	IFEQW	D0,D7,9$		;no change in pos...ignore it
	BCS.S	3$			;new>old...
	SUB.W	D0,D7			;new<old...how far?
	IFGTIW	D7,#5,5$		;more than 5
11$:	BSR	RightNextUp
	ERROR	9$
	IFGTW	DosCurEnt,D6,11$	;loop till we'e there
	BRA.S	9$
3$:	SUB.W	D7,D0			;how far?
	IFGTIW	D0,#5,5$		;more than 5
12$:	BSR	RightNextDown
	ERROR	9$
	IFLTW	DosCurEnt,D6,12$	;loop till we're there
	BRA.S	9$
5$:	MOVE.L	DosCurLevel,A0
	MOVE.L	dl_ChildPtr(A0),A1	;this is where we start counting
	BEQ.S	9$			;nothing to search
	MOVE.W	D6,DosCurEnt
	MOVE.W	D6,D1			;looking for this entry
	BEQ.S	8$			;first entry
6$:	MOVE.L	df_Next(A1),A1		;try the next one
	IFZL	A1,9$			;end of list...corrupted?
	DECW	D1			;when it goes to 0, we've found it
	BNE.S	6$			;not end of list...keep checking
8$:	MOVE.L	A1,dl_CurFib(A0)	;make this one the top item
	BSR	UpdDosWinNoClear	;and redisplay window
9$:	CLR.B	UpdRWinFlg
	POP	D2-D7
	RTS

* Scrolls the entire window one row up.

RightScrollUp:
	MOVEQ	#FontHt,D1		;delta y
	BRA.S	RScrollCom

* Scrolls the entire window one row down.

RightScrollDown:
	MOVEQ	#FontHt,D1		;delta y
	NEG.L	D1			;move away from 0,0
RScrollCom:
	PUSH	D2-D5
	MOVE.L	#RDIR_TE+1,D3		;miny
	MOVE.L	#RDIR_TE+RDIR_HT-3,D5	;maxy
	ZAP	D0			;delta x	
	MOVE.L	#RDIR_LE+2,D2		;minx
	MOVE.L	#RDIR_LE+RDIR_WD-3,D4	;maxx
	MOVE.L	WINDOW,A0
	MOVE.L	wd_RPort(A0),A1
	CALLSYS	ScrollRaster,GraphicsBase
	POP	D2-D5
	RTS

* Mac window directory level gadgets.

MROOT:	PUSH	A4
	IFZL	MacCurLevel,MPex,L	;no dir 
	LEA	MacRootLevel,A4		;reset to top level
	IFEQL	MacCurLevel,A4,MPex,L	;already there
	BSR	ExcMac			;exclude files already selected
	MOVE.L	A4,MacCurLevel
	CLR.B	MacPath.
;	BSR	InitPath
	BRA.S	MPCom

MPARENT:
	PUSH	A4
	MOVE.L	MacCurLevel,A4		;move back to prev level
	IFZL	A4,MPex			;no dir
	MOVE.L	dl_ParLevel(A4),A4
	IFZL	A4,MPex			;already at root level...stop here
	BSR	ExcMac
	MOVE.L	A4,MacCurLevel		;this is our current level
	BSR	TruncateMacPath

MPCom:
	MOVE.W	dl_CurEnt(A4),CurEnt
	BSR	CountMacMaxEnt
	BSR	UpdateMacPath
	BSR	UpdateMacWindow
	BSR	LeftScrollBar
MPex:	POP	A4
	RTS


AROOT:	BSR	TruncateDosPath
	NOERROR	AROOT			;loop till it hurts
	BRA.S	APCom

APARENT:
	BSR	TruncateDosPath
APCom:
	CLR.W	DosFileCnt
	BSR	UpdateDosPath
	BSR	CurrentDosPath		;make this new path current
	BSR	BldCurrentDosDir
	BSR	UpdateDosWindow
	BSR	UpdateDosSpace
	RTS

* Come here when user hits a file gadget.

DosFileGad:
	IFZB	ValidDosVol,10$,L	;not valid dir info
	MOVE.L	GAD_PTR,A0		;POINT TO GADGET
	MOVE.W	gg_GadgetID(A0),D0	;GET ID
	PUSH	A2
	MOVE.W	D0,D1
	MOVE.L	DosCurLevel,A2
	MOVE.L	dl_CurFib(A2),A1
	BRA.S	2$
1$:	MOVE.L	df_Next(A1),A1		;try next one
2$:	IFZL	A1,9$,L			;end of list...clicked on inactive gadget
	DECW	D1			;when goes to 0, we've found it
	BNE.S	1$			;not end of list
3$:	BTST	#7,df_Flags(A1)		;a directory?
	BNE.S	4$			;yes...go to next level
	BCHG	#6,df_Flags(A1)		;else reverse selected state
	BNE.S	5$			;WAS selected, deselected now
	INCW	DosFileCnt		;one more file selected
;	MOVE.B	ConvFlag,df_ConvType(A1) ;else save the selected conversion
	BRA.S	7$
5$:	DECW	DosFileCnt		;one less file selected
7$:	MOVE.L	A1,A0			;and update this line's color
	BSR	DispDosFile		;redisplay Dos line..number in D0
	BSR	SetArrowLeft
	BRA.S	9$

4$:	MOVE.L	A1,dl_LevFib(A2)	;make this the level fib
	LEA	df_Name(A1),A0
	BSR	AppendDosPath		;update dos  path
	BSR	APCom			;make this the current dir
9$:	POP	A2
10$:	RTS

MacFileGad:
	PUSH	A2-A3
	IFZB	ValidMacVol,10$,L	;nothing loaded...ignore
	MOVE.L	GAD_PTR,A2		;POINT TO GADGET
	MOVE.W	gg_GadgetID(A2),D0	;GET ID
	MOVE.W	D0,D1
	MOVE.L	MacCurLevel,A2
	MOVE.L	dl_CurFib(A2),A3
	BRA.S	2$
1$:	MOVE.L	df_Next(A3),A3		;try next one
2$:	IFZL	A3,10$,L		;end of list...clicked on inactive gadget
	DECW	D1			;when goes to 0, we've found it
	BNE.S	1$			;not end of list
3$:	BTST	#7,df_Flags(A3)		;a directory?
	BNE.S	4$			;yes...go to next level
	BCHG	#6,df_Flags(A3)		;else reverse selected state
	BNE.S	5$			;was selected, deselected now
;	MOVE.B	ConvFlag,df_ConvType(A3) ;else save the selected conversion
	INCW	MacFileCnt		;one more file selected
	BRA.S	6$
5$:	DECW	MacFileCnt		;one less file selected
6$:	MOVE.L	A3,A0			;and update this line's color
	BSR	DispMacFile		;redisplay Mac line
	BSR	SetArrowRight
	BRA.S	10$

4$:	BSR	ExcMac			;exclude all Mac files
	MOVE.W	CurEnt,dl_CurEnt(A2)	;save body prop value
	MOVE.L	df_SubLevel(A3),A2	;this becomes the current level
	IFZL	A2,10$
	MOVE.L	A2,MacCurLevel
;	MOVE.L	dl_ChildPtr(A2),dl_CurFib(A2) ;start at first file of level
	CLR.W	CurEnt
	LEA	df_Name(A3),A0
	BSR	AppendMacPath
	BSR	UpdateMacPath
	BSR	UpdateMacWindow
	BSR	CountMacMaxEnt
	BSR	LeftScrollBar
10$:	POP	A2-A3
	RTS

* CALCULATES AMOUNT OF FREE SPACE LEFT ON AMIGA-DOS DISK FROM INFO.

LoadDosFreeSpace:
	PUSH	D2-D3
	ZAP	D0
	MOVE.L	D0,DI_NBLKS
	MOVE.L	D0,DI_USED
	MOVE.L	D0,DI_BYTES
	MOVE.L	#DosPath.,D1
	MOVEQ	#ACCESS_READ,D2		;READ ACCESS
	CALLSYS	Lock,DosBase		;GET LOCK ON CURRENT DIR
	MOVE.L	D0,D3	
	MOVE.L	D0,D1
	BEQ.S	1$
	MOVE.L	#DISK_INFO,D2
	CALLSYS	Info			;get disk size info
	MOVE.L	D3,D1
	CALLSYS	UnLock
1$:	POP	D2-D3
	RTS

* CALCULATES AMOUNT OF FREE SPACE LEFT ON Mac DISK.

CalcMacSpace:
	CLR.B	TMP.
	IFNZB	ValidMacVol,1$
	RTS
1$:	MOVE.L	VolBuf+20,D0	;SIZE OF ALLOC BLOCK
	MOVE.W	VolBuf+34,D1	;NUMBER OF FREE BLOCKS
	MULU	D1,D0		;CONVERT TO BYTES
BuildDiskFreeSpace:
	BSR.S	BuildSizeStg
	STRIP_LB. TMP2.
	MOVE.	Bytes.,TMP.
	APPEND.	TMP2.,TMP.
	RTS

* Converts filesize to ASCII string in TMP2.  

BuildFileSize:
	MOVE.L	df_Size(A4),D0
BuildSizeStg:	
	ADD.L	#1023,D0		;round up
	LSR.L	#8,D0			;divide by 1024
	LSR.L	#2,D0
	STR.	L,D0,TMP2.,#32,#7 	;convert size to ASCII, blank fill
	ACHAR.	#'k',TMP2.
;	STRIP_LB. TMP2.
	RTS

* Waits for a while during scrolling, to prevent scrolling too fast.

ScrollDelay:
	MOVEQ	#4,D1
	CALLSYS	Delay,DosBase
	RTS

CountMacMaxEnt:
	MOVE.L	MacCurLevel,A1
	BSR.S	CntMaxEnt
	MOVE.W	D0,MacMaxEnt
	RTS
	
CountDosMaxEnt:
	MOVE.L	DosCurLevel,A1
	BSR.S	CntMaxEnt
	MOVE.W	D0,DosMaxEnt
	RTS

CntMaxEnt:
	MOVE.L	dl_ChildPtr(A1),A0
	ZAP	D0
1$:	IFZL	A0,9$
	INCW	D0
	MOVE.L	df_Next(A0),A0
	BRA.S	1$
9$:	RTS

* Moves file or dir name to TMP. and pads to 30 chars.  Ptr to name stg in A0.

MovePad:
	MOVEQ	#SPACE,D2
	MOVEQ	#MaxFileName-2,D1
	LEA	TMP.,A1
1$:	MOVE.B	(A0)+,D0
	BEQ.S	2$
	MOVE.B	D0,(A1)+
	DBF	D1,1$			;MOVE UP TO 31 CHARS
	BRA.S	9$
2$:	MOVE.B	D2,(A1)+
	DBF	D1,2$
9$:	CLR.B	(A1)			;terminate properly
	RTS

* SETS THE DIRECTION OF COPY ARROW.

SetArrowLeft:
	IFZB	MacToAmy,9$	;DO NOTHING
	BSR	SwapCopyDir
	BSR	ExcMac
	BSR	UpdateMacWindow
9$:	RTS
 
SetArrowRight:
	IFNZB	MacToAmy,9$
	BSR	SwapCopyDir
	BSR	ExcDos
	BSR	UpdateDosWindow
9$:	RTS

* Reverses copy arrow and changes state of direction flag.

SwapCopyDir:
;	BSR	ExcAll			;deselect any selected files
	BCHG	#0,MacToAmy		;REVERSE THE FLAG
	BNE.S	1$			;WAS 0 (LEFT), NOW 1
	LEA	RT_ARROW,A1		;ELSE USE OTHER ARROW
	BRA.S	2$
1$:	LEA	LT_ARROW,A1		;LEFT POINTING ARROW
2$:	LEA	ARROW,A0		;POINTER TO ARROW IMAGE
	MOVE.L	A1,IM_DATA(A0)		;STORE PROPER POINTER
	LEA	G_COPY,A0
	MOVE.L	WINDOW,A1
	ZAPA	A2
	MOVEQ	#1,D0
	CALLSYS	RefreshGList,IntuitionBase
	RTS

* LOCAL DATA

BAD_DIR.	TEXTZ	<'Invalid directory.'>
Bytes.		TEXTZ	<'Bytes free: '>
NO_PARENT.	TEXTZ	<'No parent directory.'>
NO_ROOT.	TEXTZ	<'No root directory.'>
ReadMacDir.	TEXTZ	<'Loading Mac disk directory...'>
Drawer.		TEXTZ	<' Drawer'>
Folder.		TEXTZ	<' Folder'>
Root.		TEXTZ	<'(root)'>
NoMacDisk.	TEXTZ	<'No Mac disk loaded'>
InvMacDisk.	TEXTZ	<'Not a Mac disk'>

MacToAmy	DC.B	1	;1=right: Mac-->Amy, 0=left: Mac<--Amy

* LOCAL DATA BUFFERS

	SECTION	MEM,BSS

	CNOP	0,4

DISK_INFO:
DI_ERR		DS.L	1
DI_UNIT		DS.L	1
DI_STATE	DS.L	1
DI_NBLKS	DS.L	1	;NUMBER OF BLOCKS ON DISK
DI_USED		DS.L	1	;NUMBER OF BLOCKS USED
DI_BYTES	DS.L	1	;BYTES PER BLOCK
DI_TYPE		DS.L	1
DI_NODE		DS.L	1
DI_INUSE	DS.L	1

CurLevel	DS.L	1	;local curlevel
CurEnt		DS.W	1	;current entry
DosCurEnt	DS.W	1	;dos current entry
MacMaxEnt	DS.W	1	;number of Mac files displayed
DosMaxEnt	DS.W	1	;number of Dos files displayed
MacFileCnt	DS.W	1	;Mac selected file count
DosFileCnt	DS.W	1	;Amiga selected file count
UpdRWinFlg	DS.B	1	;1=update right window
UpdLWinFlg	DS.B	1	;1=update left window

* TMP. MUST be on long boundary because of BSTR usage.  Don't screw it up!

	CNOP	0,4

TMP.		DS.B	400	;TEMP STRING
TMP2.		DS.B	400

	END

