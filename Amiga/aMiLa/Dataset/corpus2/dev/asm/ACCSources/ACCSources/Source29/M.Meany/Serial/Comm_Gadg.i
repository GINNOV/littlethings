
; Gadget structures for use with serial device utility. M.Meany, Dec 92.

ReadGadg	dc.l		ViewGadg
		dc.w		214,134
		dc.w		60,10
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		0

ViewGadg	dc.l		HearGadg
		dc.w		214,145
		dc.w		60,10
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		0

HearGadg	dc.l		EditGadg
		dc.w		214,156
		dc.w		60,10
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		0

EditGadg	dc.l		MssgGadg
		dc.w		214,167
		dc.w		60,10
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		0

MssgGadg	dc.l		FileGadg
		dc.w		275,134
		dc.w		60,10
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		SendMsg

FileGadg	dc.l		CommGadg
		dc.w		275,145
		dc.w		60,10
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		SendFile

CommGadg	dc.l		BaudGadg
		dc.w		275,156
		dc.w		60,10
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		0

BaudGadg	dc.l		SmalGadg
		dc.w		275,167
		dc.w		60,10
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		0

SmalGadg	dc.l		BackGadg
		dc.w		336,134
		dc.w		60,10
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		0

BackGadg	dc.l		PopUGadg
		dc.w		336,145
		dc.w		60,10
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		0

PopUGadg	dc.l		QuitGadg
		dc.w		336,156
		dc.w		60,10
		dc.w		0
		dc.w		RELVERIFY+TOGGLESELECT
		dc.w		BOOLGADGET
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		0

QuitGadg	dc.l		0
		dc.w		336,167
		dc.w		60,10
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		DoQuitGadg
		
