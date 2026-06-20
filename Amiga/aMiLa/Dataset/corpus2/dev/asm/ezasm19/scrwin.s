

* Opens a Screen and a Window, and prints a message in it



LONG	Screen Window IMClass MsgSave
WORD	IMCode



	a1 = &NewScr
	a0 = _GfxBase
	6(a1) = 216(a0) w	;ns_Height = gb_NormalDisplayRows

	Screen = OpenScreen( &NewScr )
	beq	Exit

	a0 = &NewWin
	30(a0) = Screen		;nw_Screen

	Window = OpenWindow( * )
	beq	Exit

	a0 = d0			;( Window )
	Move( 50(a0) 20 30 )	;wd_RPort

	a0 = Window
	Text( 50(a0) "I hope you enjoy using EZAsm!" 29 )
	

*   Check for messages..


CheckMsg

	a1 = Window
	WaitPort( 86(a1) )	;wd_UserPort

GetMessage

	a1 = Window
	MsgSave = GetMsg( 86(a1) )
	beq	CheckMsg

*   Got something..

	a1 = d0			;( MsgSave )
	IMClass = 20(a1)	;im_Class
	IMCode = 24(a1)		;im_Code

	ReplyMsg( d0 )

	IMClass != 512 GetMessage	;CLOSEWINDOW?


Exit

	Window != 0 {

		Forbid()	;( stop messages )

FreeLoop	a1 = Window
		GetMsg( 86(a1) )

		d0 != 0 {
			ReplyMsg( d0 )
			bra	FreeLoop
		}

		CloseWindow( Window )
		Permit()
	}

	Screen != 0 {
		CloseScreen( Screen )
	}


	END





	ds.w	0		;( word align )
NewScr	dc.w	0,0,640,0,2	;LeftEdge,TopEdge,Width,Height,Depth
	dc.b	-1,-1		;DetailPen,BlockPen
	dc.w	$8000,$f	;ViewModes HIRES,Type CUSTOMSCREEN
	dc.l	0,0		;Font,DefaultTitle
	dc.l	0		;Gadgets
	dc.l	0		;CustomBitMap


	ds.w	0		;( word align )
NewWin	dc.w	20,20,300,75	;LeftEdge,TopEdge,Width,Height	
	dc.b	-1,-1		;DetailPen,BlockPen
	dc.l	$200		;IDCMPFlags CLOSEWINDOW
	dc.l	$2100f		;Flags
	dc.l	0,0,0		;FirstGadget,CheckMark,Title
	dc.l	0,0		;Screen,BitMap
	dc.w	400,75		;MinWidth,MinHeight
	dc.w	-1,-1		;MaxWidth,MaxHeight
	dc.w	$f		;Type CUSTOMSCREEN


*  Flags      = WINDOWCLOSE | SMART_REFRESH | ACTIVATE | WINDOWDRAG
*		| WINDOWDEPTH | WINDOWSIZING | NOCAREREFRESH

