

* Opens a window on a screen, and prints a message in it


	LVER	intuition.library 36


LONG	Screen Window IMClass MsgSave
WORD	IMCode Height




	a0 = _GfxBase
	Height = 216(a0)	;gb_NormalDisplayRows

	Screen = OpenScreenTag( 0
			SA_Width 640
			SA_Height Height
			SA_Depth 2
			SA_DetailPen -1
			SA_BlockPen -1
			SA_Type $f
			SA_Quiet 1
			SA_DisplayID $8000
			TAG_END )
	beq	Exit

	Window = OpenWindowTag( 0
			WA_Left 20
			WA_Top 20
			WA_Width 300
			WA_Height 75
			WA_DetailPen -1
			WA_BlockPen -1
			WA_IDCMP $200
			WA_Flags $2100f
			WA_Title "My Window"
			WA_CustomScreen Screen
			WA_MaxWidth -1
			WA_MaxHeight -1
			TAG_END )
	beq	Exit

	a0 = Window
	Move( 50(a0) 20 30 )	;wd_RPort

	a0 = Window
	Text( 50(a0) "I hope you enjoy using EZAsm!" 29 )
	

*   Check for messages..


CheckMsg

	a1 = Window
	WaitPort( 86(a1) )		;wd_UserPort

GetMessage

	a1 = Window
	MsgSave = GetMsg( 86(a1) )
	beq	CheckMsg

*   Got something..

	a1 = MsgSave
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

