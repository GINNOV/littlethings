; Data for QUIT requester

Qbody	dc.b	2,2	
	dc.b	0	
	even
	dc.w	50,10	
	dc.l	0	
	dc.l	.b_text	
	dc.l	.Qbody1	
	
.b_text	dc.b	'QUIT, are you sure ?',0
	even

.Qbody1	dc.b	2,2	
	dc.b	0	
	even
	dc.w	57,20	
	dc.l	0	
	dc.l	.b_text1	
	dc.l	0	
	
.b_text1	dc.b	'M.Meany  1990 ',0  message
	even


Qleft	dc.b	2,2	
	dc.b	0	
	even
	dc.w	5,3	
	dc.l	0	
	dc.l	.l_text	
	dc.l	0	
	
.l_text	dc.b	'CONT',0
	even


Qright	dc.b	2,2	
	dc.b	0	
	even
	dc.w	5,3	
	dc.l	0	
	dc.l	.r_text	
	dc.l	0	
	
.r_text	dc.b	'QUIT',0
	even

; Data for Load without saving changes requester


Lbody	dc.b	2,2	
	dc.b	0	
	even
	dc.w	50,10	
	dc.l	0	
	dc.l	.b_text	
	dc.l	.body1	
	
.b_text	dc.b	'!!    WARNING    !!',0
	even

.body1	dc.b	2,2	
	dc.b	0	
	even
	dc.w	50,20	
	dc.l	0	
	dc.l	.b_text1	
	dc.l	0	
	
.b_text1	dc.b	'CHANGES WILL BE LOST ',0  message
	even


Lleft	dc.b	2,2	
	dc.b	0	
	even
	dc.w	5,3	
	dc.l	0	
	dc.l	.l_text	
	dc.l	0	
	
.l_text	dc.b	' OK ',0
	even


Lright	dc.b	2,2	
	dc.b	0	
	even
	dc.w	5,3	
	dc.l	0	
	dc.l	.r_text	
	dc.l	0	
	
.r_text	dc.b	'CANCEL',0
	even

