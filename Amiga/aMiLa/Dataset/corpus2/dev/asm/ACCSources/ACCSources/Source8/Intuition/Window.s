
; The window structure used by all gadget examples.
; M.Meany Jan 91

window		dc.w		171,46		window XY origin 
		dc.w		317,121		window width and height
		dc.b		0,1		detail and block pens
		dc.l	CLOSEWINDOW+GADGETUP	IDCMP flags
		dc.l	WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE other window flags
		dc.l		Gadg		first gadget in list
		dc.l		0		no custom CHECKMARK
		dc.l		WindowName	window title
		dc.l		0		custom screen pointer
		dc.l		0		no custom bitmap
		dc.w		5,5		min width and height
		dc.w		640,200		max width and height
		dc.w		WBENCHSCREEN	destination screen type

WindowName	dc.b		'Your new window',0
		even
