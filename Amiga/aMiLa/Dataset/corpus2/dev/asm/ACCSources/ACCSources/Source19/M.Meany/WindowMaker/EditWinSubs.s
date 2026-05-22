

Edit		move.l		user.ptr(a4),a0		addr of window struct
		lea		WinStruct(a4),a1	addr of save buffer

; Copy details from windows structure into window i/o buffer.

		move.w		wd_LeftEdge(a0),nw_LeftEdge(a1)
		move.w		wd_TopEdge(a0),nw_TopEdge(a1)
		move.w		wd_Width(a0),nw_Width(a1)
		move.w		wd_Height(a0),nw_Height(a1)
		move.b		wd_DetailPen(a0),nw_DetailPen(a1)
		move.b		wd_BlockPen(a0),nw_BlockPen(a1)
		move.l		Winidcmp(a4),nw_IDCMPFlags(a1)
		move.l		wd_Flags(a0),nw_Flags(a1)
		move.l		#0,nw_FirstGadget(a1)
		move.l		#0,nw_CheckMark(a1)
		move.l		#0,nw_Title(a1)
		move.l		#0,nw_Screen(a1)
		move.l		#0,nw_BitMap(a1)
		move.w		wd_MinWidth(a0),nw_MinWidth(a1)
		move.w		wd_MinHeight(a0),nw_MinHeight(a1)
		move.w		wd_MaxWidth(a0),nw_MaxWidth(a1)
		move.w		wd_MaxHeight(a0),nw_MaxHeight(a1)
		move.w		#$1,nw_Type(a1) 	WBENCHSCREEN

; Now copy windows title into buffer. No overflow check ( you'll know! ).

		move.l		wd_Title(a0),a0		a0->windows title
		lea		TempTitleBuffer,a1	a1->buffer space
		lea		WinTitle(a4),a2		a2->window title
.loop		move.b		(a0),(a1)+		copy char
		move.b		(a0)+,(a2)+
		bne.s		.loop			until end of name

; The editor requires a few ASCII buffers to be primed, so.....

		lea		WinStruct(a4),a1	addr of save buffer

		moveq.l		#0,d0
		move.w		nw_LeftEdge(a1),d0
		lea		TempLEBuffer,a0
		move.l		d0,-8(a0)		set si_LongInt
		bsr		DecCon

		move.w		nw_TopEdge(a1),d0
		lea		TempTEBuffer,a0
		move.l		d0,-8(a0)		set si_LongInt
		bsr		DecCon

		move.w		nw_Width(a1),d0
		lea		TempWBuffer,a0
		move.l		d0,-8(a0)		set si_LongInt
		bsr		DecCon

		move.w		nw_Height(a1),d0
		lea		TempHBuffer,a0
		move.l		d0,-8(a0)		set si_LongInt
		bsr		DecCon

		moveq.l		#0,d0
		move.b		nw_DetailPen(a1),d0
		lea		TempDPBuffer,a0
		move.l		d0,-8(a0)		set si_LongInt
		bsr		DecCon

		move.b		nw_BlockPen(a1),d0
		lea		TempBPBuffer,a0
		move.l		d0,-8(a0)		set si_LongInt
		bsr		DecCon

		move.w		nw_MinWidth(a1),d0
		lea		TempMinWBuffer,a0
		move.l		d0,-8(a0)		set si_LongInt
		bsr		DecCon

		move.w		nw_MinHeight(a1),d0
		lea		TempMinHBuffer,a0
		move.l		d0,-8(a0)		set si_LongInt
		bsr		DecCon

		move.w		nw_MaxWidth(a1),d0
		lea		TempMaxWBuffer,a0
		move.l		d0,-8(a0)		set si_LongInt
		bsr		DecCon

		move.w		nw_MaxHeight(a1),d0
		lea		TempMaxHBuffer,a0
		move.l		d0,-8(a0)		set si_LongInt
		bsr		DecCon

; Now set gadgets up according to IDCMP and Flag bits

		bsr		SetFlags

; Now open the charecteristics editor window.

		lea		SetWinDefs,a0
		CALLINT		OpenWindow
		move.l		d0,editwin.ptr(a4)
		bne.s		.ok

		move.l		#ErrOpenEdit,d0
		bsr		SetError
		bra		.error

.ok		move.l		d0,a0			a0->edit window
		move.l		wd_RPort(a0),editwin.rp(a4)
		move.l		wd_UserPort(a0),editwin.up(a4)

		move.l		user.ptr(a4),a0
		CALLINT		CloseWindow

.WaitForMsg	move.l		editwin.up(a4),a0	a0-->user port
		CALLEXEC	WaitPort	wait for something to happen
		move.l		editwin.up(a4),a0	a0-->window pointer
		CALLEXEC	GetMsg		get any messages
		tst.l		d0		was there a message ?
		beq.s		.WaitForMsg	if not loop back
		move.l		d0,a1		a1-->message
		move.l		im_Class(a1),d2	d2=IDCMP flags
		move.l		im_IAddress(a1),a5 a5=addr of structure
		CALLEXEC	ReplyMsg	answer os or it get angry

		move.l		d2,d0
		and.l		#GADGETUP!GADGETDOWN,d0
		beq.s		.test_win
		move.l		gg_UserData(a5),a0
		cmpa.l		#0,a0
		beq.s		.test_win
		jsr		(a0)

.test_win	cmp.l		#CLOSEWINDOW,d2  window closed ?
		bne.s		.WaitForMsg	 if not then jump

		move.l		editwin.ptr(a4),a0
		CALLINT		CloseWindow

; User has closed the edit window, see if Ok or Cancel

		tst.l		CancelFlag(a4)
		beq		.cont

; OK was selected, so set up a NewWindow...

		lea		TempTitleBuffer,a0	a0->new name
		lea		WinTitle(a4),a1		a1->title buffer
.loop1		move.b		(a0)+,(a1)+		copy char
		bne.s		.loop1			until end of name

		lea		WinStruct(a4),a0	a0->new win struct
		move.l		tempidcmp,nw_IDCMPFlags(a0)
		move.l		tempflags,nw_Flags(a0)

; Now copy size, position and colour details from gadgets to structure

		move.l		a0,a2			a2->struct

		lea		EdGadget44,a1
		move.l		gg_SpecialInfo(a1),a1
		move.l		si_LongInt(a1),d1	copy min width

		lea		EdGadget45,a1
		move.l		gg_SpecialInfo(a1),a1
		move.l		si_LongInt(a1),d2	copy max width

		cmp.l		d1,d2			min < max ?
		bge.s		.isok			if so skip

		move.l		d1,d2			else set max=min
		move.l		d1,d0
		lea		TempMaxWBuffer,a0
		bsr		DecCon			and resave!

.isok		lea		EdGadget42,a1
		move.l		gg_SpecialInfo(a1),a1
		move.l		si_LongInt(a1),d0	copy width

; Ensure width is within specified limits and write values into buffer

		cmp.l		d1,d0			width > min ?
		bge.s		.isok1			if so skip
		move.l		d1,d0			else width=min
		bra.s		.resave			and resave!

.isok1		cmp.l		d2,d0			width < max ?
		ble.s		.isok2			if so skip
		move.l		d2,d0			else width=max
.resave		lea		TempWBuffer,a0		a0->buffer
		bsr		DecCon			and save

.isok2		move.w		d0,nw_Width(a2)		write width
		move.w		d1,nw_MinWidth(a2)	write min width
		move.w		d2,nw_MaxWidth(a2)	write max width

		lea		EdGadget46,a1
		move.l		gg_SpecialInfo(a1),a1
		move.l		si_LongInt(a1),d1	copy min height

		lea		EdGadget47,a1
		move.l		gg_SpecialInfo(a1),a1
		move.l		si_LongInt(a1),d2	copy max height

		cmp.l		d1,d2			min < max ?
		bge.s		.isok3			if so skip

		move.l		d1,d2			else set max=min
		move.l		d1,d0
		lea		TempMaxHBuffer,a0
		bsr		DecCon			and resave!

.isok3		lea		EdGadget43,a1
		move.l		gg_SpecialInfo(a1),a1
		move.l		si_LongInt(a1),d0	copy height

; Ensure height is within specified limits and write values into buffer

		cmp.l		d1,d0			height > min ?
		bge.s		.isok4			if so skip
		move.l		d1,d0			else height=min
		bra.s		.resave1		and resave!

.isok4		cmp.l		d2,d0			height < max ?
		ble.s		.isok5			if so skip
		move.l		d2,d0			else height=max
.resave1	lea		TempHBuffer,a0		a0->buffer
		bsr		DecCon			and save

.isok5		move.w		d0,nw_Height(a2)		write height
		move.w		d1,nw_MinHeight(a2)	write min height
		move.w		d2,nw_MaxHeight(a2)	write max height

		lea		EdGadget48,a1
		move.l		gg_SpecialInfo(a1),a1
		move.l		si_LongInt(a1),d0	copy x origin
		move.w		d0,nw_LeftEdge(a2)	into buffer

		lea		EdGadget49,a1
		move.l		gg_SpecialInfo(a1),a1
		move.l		si_LongInt(a1),d0	copy y origin
		move.w		d0,nw_TopEdge(a2)	into buffer

		lea		EdGadget50,a1
		move.l		gg_SpecialInfo(a1),a1
		move.l		si_LongInt(a1),d0	copy detail pen
		move.b		d0,nw_DetailPen(a2)	into buffer

		lea		EdGadget27,a1
		move.l		gg_SpecialInfo(a1),a1
		move.l		si_LongInt(a1),d0	copy block pen
		move.b		d0,nw_BlockPen(a2)	into buffer

.cont		lea		WinStruct(a4),a0	a0->new win struct
		move.l		nw_IDCMPFlags(a0),Winidcmp(a4)  save IDCMP
		move.l		#0,nw_IDCMPFlags(a0)		and clear from nw

		lea		WinTitle(a4),a1		a1->window title
		move.l		a1,nw_Title(a0)		write into struct

		CALLINT		OpenWindow		and open loaded win
		tst.l		d0			open ok?
		bne.s		.ok1			if so skip

		move.l		#ErrOpenUser,d0		set error code
		bsr		SetError
		bra		.error			and quit

.ok1		move.l		d0,user.ptr(a4)		save win pointer
		move.l		d0,a0
		move.l		wd_RPort(a0),user.rp(a4)

.error		moveq.l		#0,d2			don't quit
		rts
		

		

;--------------	Convert word into decimal ascii string

; Entry		a0->buffer
;		d0=value to convert

DecCon		movem.l		d0-d7/a0-a6,-(sp)

		move.w		d0,_Dstream
		move.l		a0,a3
		lea		DecConTemplate,a0
		lea		_Dstream,a1
		lea		PutC,a2
		CALLEXEC	RawDoFmt

		movem.l		(sp)+,d0-d7/a0-a6
		rts

PutC		move.b		d0,(a3)+
		rts
_Dstream	dc.l		0
DecConTemplate	dc.b		'%d',0
		even


;--------------	Sets appropriate gadgets according to windows current
;		flags and IDCMP settings.

SetFlags	move.l		Winidcmp(a4),d0		get IDCMP values
		move.l		d0,tempidcmp		save working copy
		move.l		#SELECTED,d2		set SELECTED
		move.l		d2,d3			set NOT SELECTED
		not.l		d3			
; SIZEVERIFY
		lea		EditorGadgets,a0	a0->gadget
		and.w		d3,gg_Flags(a0)		deSELECT gadget
		asr.l		#1,d0			move bit into C flag
		bcc.s		.ok			skip if flag clear
		or.w		d2,gg_Flags(a0)		SELECT gadget
; NEWSIZE
.ok		lea		EdGadget4,a0		a0->gadget
		and.w		d3,gg_Flags(a0)		deSELECT gadget
		asr.l		#1,d0			move bit into C flag
		bcc.s		.ok1			skip if flag clear
		or.w		d2,gg_Flags(a0)		SELECT gadget
; REFRESHWINDOW
.ok1		lea		EdGadget3,a0		a0->gadget
		and.w		d3,gg_Flags(a0)		deSELECT gadget
		asr.l		#1,d0			move bit into C flag
		bcc.s		.ok2			skip if flag clear
		or.w		d2,gg_Flags(a0)		SELECT gadget
; MOUSEBUTTONS
.ok2		lea		EdGadget5,a0		a0->gadget
		and.w		d3,gg_Flags(a0)		deSELECT gadget
		asr.l		#1,d0			move bit into C flag
		bcc.s		.ok3			skip if flag clear
		or.w		d2,gg_Flags(a0)		SELECT gadget
; MOUSEMOVE
.ok3		lea		EdGadget6,a0		a0->gadget
		and.w		d3,gg_Flags(a0)		deSELECT gadget
		asr.l		#1,d0			move bit into C flag
		bcc.s		.ok4			skip if flag clear
		or.w		d2,gg_Flags(a0)		SELECT gadget
; GADGETDOWN
.ok4		lea		EdGadget7,a0		a0->gadget
		and.w		d3,gg_Flags(a0)		deSELECT gadget
		asr.l		#1,d0			move bit into C flag
		bcc.s		.ok5			skip if flag clear
		or.w		d2,gg_Flags(a0)		SELECT gadget
; GADGETUP
.ok5		lea		EdGadget8,a0		a0->gadget
		and.w		d3,gg_Flags(a0)		deSELECT gadget
		asr.l		#1,d0			move bit into C flag
		bcc.s		.ok6			skip if flag clear
		or.w		d2,gg_Flags(a0)		SELECT gadget
; REQSET
.ok6		lea		EdGadget9,a0		a0->gadget
		and.w		d3,gg_Flags(a0)		deSELECT gadget
		asr.l		#1,d0			move bit into C flag
		bcc.s		.ok7			skip if flag clear
		or.w		d2,gg_Flags(a0)		SELECT gadget
; MENUPICK
.ok7		lea		EdGadget10,a0		a0->gadget
		and.w		d3,gg_Flags(a0)		deSELECT gadget
		asr.l		#1,d0			move bit into C flag
		bcc.s		.ok8			skip if flag clear
		or.w		d2,gg_Flags(a0)		SELECT gadget
; CLOSEWINDOW
.ok8		lea		EdGadget11,a0		a0->gadget
		and.w		d3,gg_Flags(a0)		deSELECT gadget
		asr.l		#1,d0			move bit into C flag
		bcc.s		.ok9			skip if flag clear
		or.w		d2,gg_Flags(a0)		SELECT gadget
; RAWKEY
.ok9		lea		EdGadget12,a0		a0->gadget
		and.w		d3,gg_Flags(a0)		deSELECT gadget
		asr.l		#1,d0			move bit into C flag
		bcc.s		.ok10			skip if flag clear
		or.w		d2,gg_Flags(a0)		SELECT gadget
; REQVERIFY
.ok10		lea		EdGadget13,a0		a0->gadget
		and.w		d3,gg_Flags(a0)		deSELECT gadget
		asr.l		#1,d0			move bit into C flag
		bcc.s		.ok11			skip if flag clear
		or.w		d2,gg_Flags(a0)		SELECT gadget
; REQCLEAR
.ok11		lea		EdGadget14,a0		a0->gadget
		and.w		d3,gg_Flags(a0)		deSELECT gadget
		asr.l		#1,d0			move bit into C flag
		bcc.s		.ok12			skip if flag clear
		or.w		d2,gg_Flags(a0)		SELECT gadget
; MENUVERIFY
.ok12		lea		EdGadget20,a0		a0->gadget
		and.w		d3,gg_Flags(a0)		deSELECT gadget
		asr.l		#1,d0			move bit into C flag
		bcc.s		.ok13			skip if flag clear
		or.w		d2,gg_Flags(a0)		SELECT gadget
; NEWPREFS
.ok13		lea		EdGadget19,a0		a0->gadget
		and.w		d3,gg_Flags(a0)		deSELECT gadget
		asr.l		#1,d0			move bit into C flag
		bcc.s		.ok14			skip if flag clear
		or.w		d2,gg_Flags(a0)		SELECT gadget
; DISKINSERTED
.ok14		lea		EdGadget18,a0		a0->gadget
		and.w		d3,gg_Flags(a0)		deSELECT gadget
		asr.l		#1,d0			move bit into C flag
		bcc.s		.ok15			skip if flag clear
		or.w		d2,gg_Flags(a0)		SELECT gadget
; DISKREMOVED
.ok15		lea		EdGadget17,a0		a0->gadget
		and.w		d3,gg_Flags(a0)		deSELECT gadget
		asr.l		#1,d0			move bit into C flag
		bcc.s		.ok16			skip if flag clear
		or.w		d2,gg_Flags(a0)		SELECT gadget
; WBENCHMESSAGE
.ok16		lea		EdGadget16,a0		a0->gadget
		and.w		d3,gg_Flags(a0)		deSELECT gadget
		asr.l		#1,d0			move bit into C flag
		bcc.s		.ok17			skip if flag clear
		or.w		d2,gg_Flags(a0)		SELECT gadget
; ACTIVEWINDOW
.ok17		lea		EdGadget15,a0		a0->gadget
		and.w		d3,gg_Flags(a0)		deSELECT gadget
		asr.l		#1,d0			move bit into C flag
		bcc.s		.ok18			skip if flag clear
		or.w		d2,gg_Flags(a0)		SELECT gadget
; INACTIVEWINDOW
.ok18		lea		EdGadget2,a0		a0->gadget
		and.w		d3,gg_Flags(a0)		deSELECT gadget
		asr.l		#1,d0			move bit into C flag
		bcc.s		.ok19			skip if flag clear
		or.w		d2,gg_Flags(a0)		SELECT gadget
; DELTAMOVE
.ok19		lea		EdGadget23,a0		a0->gadget
		and.w		d3,gg_Flags(a0)		deSELECT gadget
		asr.l		#1,d0			move bit into C flag
		bcc.s		.ok20			skip if flag clear
		or.w		d2,gg_Flags(a0)		SELECT gadget
; VANILLAKEY
.ok20		lea		EdGadget21,a0		a0->gadget
		and.w		d3,gg_Flags(a0)		deSELECT gadget
		asr.l		#1,d0			move bit into C flag
		bcc.s		.ok21			skip if flag clear
		or.w		d2,gg_Flags(a0)		SELECT gadget
; INTUITICKS
.ok21		lea		EdGadget22,a0		a0->gadget
		and.w		d3,gg_Flags(a0)		deSELECT gadget
		asr.l		#1,d0			move bit into C flag
		bcc.s		.ok22			skip if flag clear
		or.w		d2,gg_Flags(a0)		SELECT gadget

; Thats all the idcmp flags dealt with, now for window flags.


.ok22		lea		WinStruct(a4),a0
		move.l		nw_Flags(a0),d0		d0=flags
		move.l		d0,tempflags		save working copy
; WINDOWSIZING
		lea		EdGadget28,a0		a0->gadget
		and.w		d3,gg_Flags(a0)		deSELECT gadget
		asr.l		#1,d0			move bit into C flag
		bcc.s		.ok23			skip if flag clear
		or.w		d2,gg_Flags(a0)		SELECT gadget
; WINDOWDRAG
.ok23		lea		EdGadget26,a0		a0->gadget
		and.w		d3,gg_Flags(a0)		deSELECT gadget
		asr.l		#1,d0			move bit into C flag
		bcc.s		.ok24			skip if flag clear
		or.w		d2,gg_Flags(a0)		SELECT gadget
; WINDOWDEPTH
.ok24		lea		EdGadget29,a0		a0->gadget
		and.w		d3,gg_Flags(a0)		deSELECT gadget
		asr.l		#1,d0			move bit into C flag
		bcc.s		.ok25			skip if flag clear
		or.w		d2,gg_Flags(a0)		SELECT gadget
; WINDOWCLOSE
.ok25		lea		EdGadget30,a0		a0->gadget
		and.w		d3,gg_Flags(a0)		deSELECT gadget
		asr.l		#1,d0			move bit into C flag
		bcc.s		.ok26			skip if flag clear
		or.w		d2,gg_Flags(a0)		SELECT gadget
; SIZEBRIGHT
.ok26		lea		EdGadget31,a0		a0->gadget
		and.w		d3,gg_Flags(a0)		deSELECT gadget
		asr.l		#1,d0			move bit into C flag
		bcc.s		.ok27			skip if flag clear
		or.w		d2,gg_Flags(a0)		SELECT gadget
; SIZEBBOTTOM
.ok27		lea		EdGadget32,a0		a0->gadget
		and.w		d3,gg_Flags(a0)		deSELECT gadget
		asr.l		#1,d0			move bit into C flag
		bcc.s		.ok28			skip if flag clear
		or.w		d2,gg_Flags(a0)		SELECT gadget
; SIMPLE_REFRESH
.ok28		lea		EdGadget33,a0		a0->gadget
		and.w		d3,gg_Flags(a0)		deSELECT gadget
		asr.l		#1,d0			move bit into C flag
		bcc.s		.ok29			skip if flag clear
		or.w		d2,gg_Flags(a0)		SELECT gadget
; SUPERBITMAP
.ok29		lea		EdGadget25,a0		a0->gadget
		and.w		d3,gg_Flags(a0)		deSELECT gadget
		asr.l		#1,d0			move bit into C flag
		bcc.s		.ok30			skip if flag clear
		or.w		d2,gg_Flags(a0)		SELECT gadget
; BACKDROP
.ok30		lea		EdGadget34,a0		a0->gadget
		and.w		d3,gg_Flags(a0)		deSELECT gadget
		asr.l		#1,d0			move bit into C flag
		bcc.s		.ok31			skip if flag clear
		or.w		d2,gg_Flags(a0)		SELECT gadget
; REPORTMOUSE
.ok31		lea		EdGadget35,a0		a0->gadget
		and.w		d3,gg_Flags(a0)		deSELECT gadget
		asr.l		#1,d0			move bit into C flag
		bcc.s		.ok32			skip if flag clear
		or.w		d2,gg_Flags(a0)		SELECT gadget
; GIMMEZEROZERO
.ok32		lea		EdGadget36,a0		a0->gadget
		and.w		d3,gg_Flags(a0)		deSELECT gadget
		asr.l		#1,d0			move bit into C flag
		bcc.s		.ok33			skip if flag clear
		or.w		d2,gg_Flags(a0)		SELECT gadget
; BORDERLESS
.ok33		lea		EdGadget37,a0		a0->gadget
		and.w		d3,gg_Flags(a0)		deSELECT gadget
		asr.l		#1,d0			move bit into C flag
		bcc.s		.ok34			skip if flag clear
		or.w		d2,gg_Flags(a0)		SELECT gadget
; ACTIVATE
.ok34		lea		EdGadget38,a0		a0->gadget
		and.w		d3,gg_Flags(a0)		deSELECT gadget
		asr.l		#1,d0			move bit into C flag
		bcc.s		.ok35			skip if flag clear
		or.w		d2,gg_Flags(a0)		SELECT gadget
; RMBTRAP
.ok35		lea		EdGadget39,a0		a0->gadget
		and.w		d3,gg_Flags(a0)		deSELECT gadget
		asr.l		#1,d0			move bit into C flag
		asr.l		#1,d0
		asr.l		#1,d0
		asr.l		#1,d0
		bcc.s		.ok36			skip if flag clear
		or.w		d2,gg_Flags(a0)		SELECT gadget
; NOCAREREFRESH
.ok36		lea		EdGadget40,a0		a0->gadget
		and.w		d3,gg_Flags(a0)		deSELECT gadget
		asr.l		#1,d0			move bit into C flag
		bcc.s		.ok37			skip if flag clear
		or.w		d2,gg_Flags(a0)		SELECT gadget

.ok37		rts

tempidcmp	dc.l		1
tempflags	dc.l		1


************************************************************************

; Subroutines to test integrity of data.


; Called when an IDCMP gadget is clicked on. Toggles state of flag bit.
;Assumes a5->gadget structure and gadget structure is followed by a long
;word bit field offset.

SetWinidcmp	move.l		gg_SIZEOF(a5),d0	d0=bit offset
		move.l		tempidcmp,d1		d1=IDCMP
		subq.l		#1,d0			correct it
		bmi.s		.error
		bchg.l		d0,d1			toggle flag
		move.l		d1,tempidcmp		and save
.error		rts

; Called when a window flag gadget is clicked on. Toggles state of flag bit.
;Assumes a5->gadget structure and gadget structure is followed by a long
;word bit field offset.

SetWinflags	move.l		gg_SIZEOF(a5),d0	d0=bit offset
		move.l		tempflags,d1		d1=flags
		subq.l		#1,d0			correct it
		bmi.s		.error
		bchg.l		d0,d1			toggle flag
		move.l		d1,tempflags
.error		rts

DoNothing	rts

DoWinDef	move.l		#CLOSEWINDOW,d2
		move.l		#1,CancelFlag(a4)
		rts

CancelWinDef	move.l		#CLOSEWINDOW,D2
		move.l		#0,CancelFlag(a4)
		rts

************************************************************************


