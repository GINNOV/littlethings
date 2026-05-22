
; Data defenitions for user window in Window Maker utility.

UserWindow	dc.w		170,50
		dc.w		300,100
		dc.b		0,1
		dc.l		0
		dc.l		WINDOWSIZING+WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+NOCAREREFRESH
		dc.l		0
		dc.l		0
		dc.l		UserName
		dc.l		0
		dc.l		0
		dc.w		10,10
		dc.w		640,256
		dc.w		WBENCHSCREEN

UserName	dc.b		'Default Window',0
		even


