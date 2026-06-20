;----------This is the info text.

maintext	
txt
	dc.b		3,0,RP_JAM2,0		front pen,back pen,and drawmode
	dc.w		55,20			position of text
	dc.l		NULL			Default font
	dc.l		.Itext			Ptr to text
	dc.l		txt2			Next text struct null if last
	
.Itext	dc.b		'««« Vector Scanner Vr0.1 »»»',0		text to be displayed
	even
	
txt2
	dc.b		1,0,RP_JAM2,0		front pen,back pen,and drawmode
	dc.w		15,40			position of text
	dc.l		NULL			Default font
	dc.l		.Itext			Ptr to text
	dc.l		txt3			Next text struct null if last
	
.Itext	dc.b		'COLDCAPTURE  >>>:                       ',0		text to be displayed
	even
	
txt3
	dc.b		1,0,RP_JAM2,0		front pen,back pen,and drawmode
	dc.w		15,50			position of text
	dc.l		NULL			Default font
	dc.l		.Itext			Ptr to text
	dc.l		txt4			Next text struct null if last
	
.Itext	dc.b		'COOLCAPTURE  >>>:                       ',0		text to be displayed
	even
	
txt4
	dc.b		1,0,RP_JAM2,0		front pen,back pen,and drawmode
	dc.w		15,60			position of text
	dc.l		NULL			Default font
	dc.l		.Itext			Ptr to text
	dc.l		txt5			Next text struct null if last
	
.Itext	dc.b		'WARMCAPTURE  >>>:                       ',0		text to be displayed
	even
	
txt5
	dc.b		1,0,RP_JAM2,0		front pen,back pen,and drawmode
	dc.w		15,70			position of text
	dc.l		NULL			Default font
	dc.l		.Itext			Ptr to text
	dc.l		txt6			Next text struct null if last
	
.Itext	dc.b		'KICKTAGPTR   >>>:                       ',0		text to be displayed
	even
	
txt6
	dc.b		1,0,RP_JAM2,0		front pen,back pen,and drawmode
	dc.w		15,80			position of text
	dc.l		NULL			Default font
	dc.l		.Itext			Ptr to text
	dc.l		txt7			Next text struct null if last
	
.Itext	dc.b		'KICKCHECKSUM >>>:                       ',0		text to be displayed
	even
	
txt7
	dc.b		1,0,RP_JAM2,0		front pen,back pen,and drawmode
	dc.w		15,90			position of text
	dc.l		NULL			Default font
	dc.l		.Itext			Ptr to text
	dc.l		txt8			Next text struct null if last
	
.Itext	dc.b		'KICKMEMPTR   >>>:                       ',0		text to be displayed
	even
	
txt8
	dc.b		3,0,RP_JAM2,0		front pen,back pen,and drawmode
	dc.w		15,110			position of text
	dc.l		NULL			Default font
	dc.l		.Itext			Ptr to text
	dc.l		Null			Next text struct null if last
	
.Itext	dc.b		'TO STOP SCANNING PRESS RIGHTMOUSE BUTTON',0		text to be displayed
	even
	

	

