
; Subroutines and variables for CopperBuilder utility.

; Subroutine called when LoRes gadget is selected

DoLores		lea		LoresGadg,a1	a1->1st gadget to remove
		moveq.l		#2,d0		d0=number to remove
		bsr		RemoveGad	and do it
		
		lea		LoresGadg,a1	a1->gadget
		move.l		#SELECTED,d1	select gadget flag
		or.w		d1,gg_Flags(a1)	and select this gadget
		
		lea		HiresGadg,a0	a0->gadget
		not.w		d1		complement flag
		and.w		d1,gg_Flags(a0)	deselect this gadget
		
		moveq.l		#2,d1		number of gadgets
		bsr		AddGad		and add them back again
		
		move.w		#$0038,_DDFSTRT	set up values
		move.w		#$00D0,_DDFSTOP
		move.w		#0,Resolution
		move.w		#40,ModValue
		
		moveq.l		#0,d2
		rts

; Subroutine called when HiRes gadget is selected

DoHires		lea		LoresGadg,a1	a1->1st gadget to remove
		moveq.l		#2,d0		d0=number to remove
		bsr		RemoveGad	and do it
		
		lea		HiresGadg,a0	a0->gadget
		move.l		#SELECTED,d1	select gadget flag
		or.w		d1,gg_Flags(a0)	and select this gadget
		
		lea		LoresGadg,a1	a1->gadget
		not.w		d1		complement flag
		and.w		d1,gg_Flags(a1)	deselect this gadget
		
		moveq.l		#2,d1		number of gadgets
		bsr		AddGad		and add them back again
		
		move.w		#$003C,_DDFSTRT	set up values
		move.w		#$00D4,_DDFSTOP
		move.w		#$8000,Resolution
		move.w		#80,ModValue

		moveq.l		#0,d2
		rts

; Subroutine called when NTSC gadget is selected

DoNtsc		lea		NtscGadg,a1	a1->1st gadget to remove
		moveq.l		#2,d0		d0=number to remove
		bsr		RemoveGad	and do it
		
		lea		NtscGadg,a1	a1->gadget
		move.l		#SELECTED,d1	select gadget flag
		or.w		d1,gg_Flags(a1)	and select this gadget
		
		lea		PalGadg,a0	a0->gadget
		not.w		d1		complement flag
		and.w		d1,gg_Flags(a0)	deselect this gadget
		
		moveq.l		#2,d1		number of gadgets
		bsr		AddGad		and add them back again
		
		move.w		#$F4C1,_DIWSTOP	set up values

		moveq.l		#0,d2
		rts

; Subroutine called when PAL gadget is selected. 

DoPal		lea		NtscGadg,a1	a1->1st gadget to remove
		moveq.l		#2,d0		d0=number to remove
		bsr		RemoveGad	and do it
		
		lea		PalGadg,a0	a0->gadget
		move.l		#SELECTED,d1	select gadget flag
		or.w		d1,gg_Flags(a0)	and select this gadget
		
		lea		NtscGadg,a1	a1->gadget
		not.w		d1		complement flag
		and.w		d1,gg_Flags(a1)	deselect this gadget
		
		moveq.l		#2,d1		number of gadgets
		bsr		AddGad		and add them back again
		
		move.w		#$2CC1,_DIWSTOP	set up values

		moveq.l		#0,d2
		rts

; This subroutine resets all values to starting settings. Is called as part
;of initialisation routine as well as by clicking gadget.

DoDefault	bsr		DoLores			Lores mode

		bsr		DoPal			PAL screen
		
		lea		WidthGadg,a0		width=320
		move.l		#320,d0
		bsr		BuildIntStr

		lea		HeightGadg,a0		height=256
		move.l		#256,d0
		bsr		BuildIntStr

		lea		DepthGadg,a0		depth=4
		moveq.l		#4,d0
		bsr		BuildIntStr

		lea		LoresGadg,a0		refresh all gadgets
		move.l		window.ptr,a1
		suba.l		a2,a2
		CALLINT		RefreshGadgets

		move.w		#$2c81,_DIWSTRT	starts off LORES - PAL
		move.w		#$2cc1,_DIWSTOP
		move.w		#$0038,_DDFSTRT
		move.w		#$00d0,_DDFSTOP
		
		rts

; Subroutine that creates and saves the copper list designed to the users
;specification.

; First, BPLCON0 is calculated

DoSave		moveq.l		#0,d0		clear register
		move.w		Resolution,d0
		or.w		#$0200,d0
		
		lea		DepthGadg,a0	a0->int gadget
		move.l		gg_SpecialInfo(a0),a0	a0->StringInfo
		move.l		si_LongInt(a0),d1	d1=display depth
		
		cmp.l		#6,d1		see if > maxplanes
		ble.s		.ok		if so skip correction
		moveq.l		#6,d1		else set to maxplanes

.ok		move.w		d1,_DEPTH	store in DataStream
		asl.w		#8,d1		shift bits into position
		asl.w		#4,d1
		or.w		d1,d0		add to total
		move.w		d0,_BPLCON0	and save in DataStream

; Now the bitplane modulos, which I am assuming are the same ( no DUALPF )

		lea		WidthGadg,a0	a0->Int gadget
		move.l		gg_SpecialInfo(a0),a0	a0->StringInfo
		move.l		si_LongInt(a0),d0	d0=playfield width
		move.w		d0,_WIDTH	write into DataStream
		
		asr.l		#3,d0		divide by 8
		sub.w		ModValue,d0	calculate modulo
		move.w		d0,_BPL1MOD	and store in DataStream
		move.w		d0,_BPL2MOD

; Calculate how much space to leave for colour register assigns

		lea		DepthGadg,a0	a0->Int gadget
		move.l		gg_SpecialInfo(a0),a0	a0->StringInfo
		move.l		si_LongInt(a0),d0	d0=playfield depth

		cmp.l		#6,d0		compare to maxplanes
		ble.s		.ok1		skip if in range
		moveq.l		#6,d0		else set to maxplanes
		
.ok1		move.l		d0,d2		we need this value later!
		moveq.l		#2,d1		calc space
		asl.w		d0,d1
		move.w		d1,_COLOURSIZE	and write into DataStream

		asr.l		#1,d1		determine number of colours
		move.w		d1,_COLOURS	and write to DataStream

; Calculate how much space to leave for bitplane pointer assigns
		
		asl.w		#2,d2		calc space
		move.w		d2,_PLANESIZE	and write into DataStream

		lea		HeightGadg,a0	a0->Int gadget
		move.l		gg_SpecialInfo(a0),a0	a0->StringInfo
		move.w		si_LongInt+2(a0),_HEIGHT into DataStream

; All calculations now done, time to build the list.

		lea		CopListTemplate,a0	a0->Format String
		lea		DataStream,a1		a1->DataStream
		lea		PutChar,a2		a2->subroutine
		lea		CopListBuffer,a3	a3->Dest buffer
		CALLEXEC	RawDoFmt		and build list

; Open the destination file

		move.l		STD_OUT,Handle		save CLI handle

		move.l		#FileName,d1		name of file to open
		move.l		#MODE_NEWFILE,d2	accessmode
		CALLDOS		Open			and create it
		move.l		d0,STD_OUT		save handle
		beq.s		.error			quit if error
		
; Save source code

		lea		CopListBuffer,a0	a0->text
		bsr		DosMsg			print it

; Close destination file

		move.l		STD_OUT,d1		handle
		CALLDOS		Close			and close it

.error		move.l		Handle,STD_OUT		restore	CLI handle

; and return

		moveq.l		#0,d2
		rts

PutChar		move.b		d0,(a3)+
		rts
		
; Subroutine called when quit gadget is selected.

DoQuit		move.l		#CLOSEWINDOW,d2
		rts
		
***************	Remove gadgets from list

; Entry		a1->first gadget structure
;		d0= number of gadgets to remove

RemoveGad	move.l		window.ptr,a0
		CALLINT		RemoveGList
		rts

***************	Add gadgets back to list

; Entry		a1->first gadget to add to list
;		d1=num of gadgets to add

AddGad		movem.l		d1/a1,-(sp)	save d1,a1 numgad,gadget
		move.l		window.ptr,a0	get window ptr
		sub.l		a2,a2		clear a2
		CALLINT		AddGList	d0 should remain unchanged
		move.l		window.ptr,a1	since RemoveGList
		movem.l		(sp)+,d0/a0	set up d0,a0 numgad,gadget  
		CALLSYS		RefreshGList	refresh gadgets	
		rts		

; A subroutine to set an Integer gadget to a specified value.

; Entry		a0->Gadget structure
;		d0=long word value

BuildIntStr	movem.l		d0-d3/a0-a6,-(sp)	save registers

		move.l		gg_SpecialInfo(a0),a0	a0->StringInfo

		move.l		d0,si_LongInt(a0)	write long word

		lea		si_LongInt(a0),a1	a1->DataStream
		lea		.PutChar,a2		a2->Subroutine
		move.l		si_Buffer(a0),a3	a3->buffer
		lea		.Template,a0		a0->format string
		CALLEXEC	RawDoFmt		build text

		movem.l		(sp)+,d0-d3/a0-a6	restore registers
		rts					and return

.Template	dc.b		'%ld',0
		even

.PutChar	move.b		d0,(a3)+
		rts


*****************************************

;		Vars

Handle		dc.l		0
Resolution	dc.w		0		init to Lores
ModValue	dc.w		40		display width in bytes

DataStream
_WIDTH		dc.w		0
_HEIGHT		dc.w		0
_DEPTH		dc.w		0
_COLOURS	dc.w		0
_DIWSTRT	dc.w		$2c81		starts off LORES - PAL
_DIWSTOP	dc.w		$2cc1
_DDFSTRT	dc.w		$0038
_DDFSTOP	dc.w		$00d0
_BPLCON0	dc.w		0
_BPL1MOD	dc.w		0
_BPL2MOD	dc.w		0
_COLOURSIZE	dc.w		0
_PLANESIZE	dc.w		0

;DataStream:	diwstrt
;		diwstop
;		ddfstrt
;		ddfstop
;		bplcon0
;		bpl1mod
;		bpl2mod
;		space for colour register assigns
;		space for plane pointer assigns

CopListTemplate	incbin		SubTemplate.i
		dc.b		$09,$09,'Section',$09,$09,'Copper,Data_C',$0a,$0a
		dc.b		'Coplist'
		dc.b		$09,$09,'dc.w',$09,$09,'DIWSTRT,$%04x',$0a
		dc.b		$09,$09,'dc.w',$09,$09,'DIWSTOP,$%04x',$0a
		dc.b		$09,$09,'dc.w',$09,$09,'DDFSTRT,$%04x',$0a
		dc.b		$09,$09,'dc.w',$09,$09,'DDFSTOP,$%04x',$0a
		dc.b		$09,$09,'dc.w',$09,$09,'BPLCON0,$%04x',$0a
		dc.b		$09,$09,'dc.w',$09,$09,'BPLCON1,$0000',$0a
		dc.b		$09,$09,'dc.w',$09,$09,'BPLCON2,$0000',$0a
		dc.b		$09,$09,'dc.w',$09,$09,'BPL1MOD,$%04x',$0a
		dc.b		$09,$09,'dc.w',$09,$09,'BPL2MOD,$%04x',$0a
		dc.b		'CopColours'
		dc.b		$09,'ds.w',$09,$09,'$%04x',$0a
		dc.b		'CopPlanes'
		dc.b		$09,'ds.w',$09,$09,'$%04x',$0a
		dc.b		$09,$09,'dc.w',$09,$09,'$ffff,$fffe',$0a,$0a
		dc.b		'; Created by CopperBuilder, © M.Meany 1992.',$0a
		dc.b		0
		even

CopListBuffer	ds.b		2500
		even








