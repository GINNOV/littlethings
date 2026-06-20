;----------This is the window Def's.

		section Data,Data

Vect_window
	dc.w		0,0			x,y start position
	dc.w		350,155			width and height
	dc.b		0,1			detail and block pens
	dc.l		CLOSEWINDOW+GADGETUP	idcmp flags
	dc.l		WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+ACTIVATE+NOCAREREFRESH+SMART_REFRESH
	dc.l		Gadgets			first gadget in list
	dc.l		NULL			custom CHECKMARK imagary
	dc.l		.title			window title name
	dc.l		NULL			custom screen pointer
	dc.l		NULL			custom bitmap
	dc.w		5,5			min size
	dc.w		400,200			max size
	dc.w		WBENCHSCREEN		dest screen type
.title
	dc.b	'Vector-Scanner Vr0.1ай Davie Shaw',0
	even

