;----------This is the info text.

Infotext	
text
	dc.b		3,0,RP_JAM2,0		front pen,back pen,and drawmode
	dc.w		55,20			position of text
	dc.l		NULL			Default font
	dc.l		.Itext			Ptr to text
	dc.l		text2			Next text struct null if last
	
.Itext	dc.b		'««« Vector Scanner Vr0.1 »»»',0		text to be displayed
	even
	
text2
	dc.b		1,0,RP_JAM2,0		front pen,back pen,and drawmode
	dc.w		15,30			position of text
	dc.l		NULL			Default font
	dc.l		.Itext			Ptr to text
	dc.l		text3			Next text struct null if last
	
.Itext	dc.b		'A small utility to check for any changes',0		text to be displayed
	even
	
text3
	dc.b		1,0,RP_JAM2,0		front pen,back pen,and drawmode
	dc.w		15,40			position of text
	dc.l		NULL			Default font
	dc.l		.Itext			Ptr to text
	dc.l		text4			Next text struct null if last
	
.Itext	dc.b		'in the execbase reset vectors to detect',0		text to be displayed
	even
	
text4
	dc.b		1,0,RP_JAM2,0		front pen,back pen,and drawmode
	dc.w		15,50			position of text
	dc.l		NULL			Default font
	dc.l		.Itext			Ptr to text
	dc.l		text5			Next text struct null if last
	
.Itext	dc.b		'a virus before it manages to infects',0		text to be displayed
	even
	
text5
	dc.b		1,0,RP_JAM2,0		front pen,back pen,and drawmode
	dc.w		15,60			position of text
	dc.l		NULL			Default font
	dc.l		.Itext			Ptr to text
	dc.l		text6			Next text struct null if last
	
.Itext	dc.b		'your entire disk collection.',0		text to be displayed
	even
	
text6
	dc.b		1,0,RP_JAM2,0		front pen,back pen,and drawmode
	dc.w		15,70			position of text
	dc.l		NULL			Default font
	dc.l		.Itext			Ptr to text
	dc.l		text7			Next text struct null if last
	
.Itext	dc.b		'Run this program from your startup-',0		text to be displayed
	even
	
text7
	dc.b		1,0,RP_JAM2,0		front pen,back pen,and drawmode
	dc.w		15,80			position of text
	dc.l		NULL			Default font
	dc.l		.Itext			Ptr to text
	dc.l		text8			Next text struct null if last
	
.Itext	dc.b		'sequence eg:',0		text to be displayed
	even
	
text8
	dc.b		3,0,RP_JAM2,0		front pen,back pen,and drawmode
	dc.w		120,80			position of text
	dc.l		NULL			Default font
	dc.l		.Itext			Ptr to text
	dc.l		text9			Next text struct null if last
	
.Itext	dc.b		'RUN VECTOR-SCANNER',0		text to be displayed
	even
	
text9
	dc.b		1,0,RP_JAM2,0		front pen,back pen,and drawmode
	dc.w		15,90			position of text
	dc.l		NULL			Default font
	dc.l		.Itext			Ptr to text
	dc.l		text10			Next text struct null if last
	
.Itext	dc.b		'or click on its icon from workbench.',0		text to be displayed
	even
	
text10
	dc.b		1,0,RP_JAM2,0		front pen,back pen,and drawmode
	dc.w		15,100			position of text
	dc.l		NULL			Default font
	dc.l		.Itext			Ptr to text
	dc.l		text11			Next text struct null if last
	
.Itext	dc.b		'For more information please read the doc',0		text to be displayed
	even		

text11
	dc.b		1,0,RP_JAM2,0		front pen,back pen,and drawmode
	dc.w		15,110			position of text
	dc.l		NULL			Default font
	dc.l		.Itext			Ptr to text
	dc.l		text12			Next text struct null if last
	
.Itext	dc.b		'supplied.This program is Public Domain  ',0		text to be displayed
	even
	
text12
	dc.b		3,0,RP_JAM2,0		front pen,back pen,and drawmode
	dc.w		15,120			position of text
	dc.l		NULL			Default font
	dc.l		.Itext			Ptr to text
	dc.l		Null			Next text struct null if last
	
.Itext	dc.b		'Press left mouse Button to Continue',0		text to be displayed
	even
	

