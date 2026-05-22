; Data for QUIT requester

body	dc.b	2,2	
	dc.b	0	
	even
	dc.w	50,10	
	dc.l	0	
	dc.l	b_text	
	dc.l	body1	
	
b_text	dc.b	'QUIT, are you sure ?',0
	even
body1	dc.b	2,2	
	dc.b	0	
	even
	dc.w	57,20	
	dc.l	0	
	dc.l	b_text1	
	dc.l	0	
	
b_text1	dc.b	'M.Meany  1990 ',0  message
	even


left	dc.b	2,2	
	dc.b	0	
	even
	dc.w	5,3	
	dc.l	0	
	dc.l	l_text	
	dc.l	0	
	
l_text	dc.b	'CONT',0
	even


right	dc.b	2,2	
	dc.b	0	
	even
	dc.w	5,3	
	dc.l	0	
	dc.l	r_text	
	dc.l	0	
	
r_text	dc.b	'QUIT',0
	even
