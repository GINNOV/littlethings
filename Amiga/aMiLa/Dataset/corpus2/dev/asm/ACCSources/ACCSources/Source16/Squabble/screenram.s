	
	xdef SCREEN1
	xdef SCREEN2
	xdef SCREEN3
	xdef SCREEN4
	xdef SCREEN5
	xdef SCREEN6

	even
SCREEN1
	dcb.w 4800,0
SCREEN2
	dcb.w 4800,0
SCREEN3
	incbin "Source:Squable/foreground48"
SCREEN4
	dcb.w 5760,0
SCREEN5
	incbin "Source:Squable/background48"
SCREEN6
	dcb.w 5760,0

	even


