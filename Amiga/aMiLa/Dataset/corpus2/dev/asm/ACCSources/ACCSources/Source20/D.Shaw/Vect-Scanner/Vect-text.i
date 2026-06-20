;----------This is the info text.

Vecttext	
Vtxt1
	dc.b		3,0,RP_JAM2,0		front pen,back pen,and drawmode
	dc.w		150,40			position of text
	dc.l		NULL			Default font
	dc.l		Coldtxt			Ptr to text
	dc.l		Vtxt2			Next text struct null if last
		
Vtxt2
	dc.b		3,0,RP_JAM2,0		front pen,back pen,and drawmode
	dc.w		150,50			position of text
	dc.l		NULL			Default font
	dc.l		Cooltxt			Ptr to text
	dc.l		Vtxt3			Next text struct null if last
	
Vtxt3
	dc.b		3,0,RP_JAM2,0		front pen,back pen,and drawmode
	dc.w		150,60			position of text
	dc.l		NULL			Default font
	dc.l		Warmtxt			Ptr to text
	dc.l		Vtxt4			Next text struct null if last
	
Vtxt4
	dc.b		3,0,RP_JAM2,0		front pen,back pen,and drawmode
	dc.w		150,70			position of text
	dc.l		NULL			Default font
	dc.l		Ktptxt			Ptr to text
	dc.l		Vtxt5			Next text struct null if last

Vtxt5
	dc.b		3,0,RP_JAM2,0		front pen,back pen,and drawmode
	dc.w		150,80			position of text
	dc.l		NULL			Default font
	dc.l		Kcstxt			Ptr to text
	dc.l		Vtxt6			Next text struct null if last
		
Vtxt6
	dc.b		3,0,RP_JAM2,0		front pen,back pen,and drawmode
	dc.w		150,90			position of text
	dc.l		NULL			Default font
	dc.l		Kmptxt			Ptr to text
	dc.l		Null			Next text struct null if last

