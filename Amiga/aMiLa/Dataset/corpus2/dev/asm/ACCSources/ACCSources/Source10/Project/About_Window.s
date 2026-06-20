; About window data definition

about_win	dc.w		180,50		
		dc.w		300,130		
		dc.b		0,1		
		dc.l		0		
		dc.l		ACTIVATE	other window flags
		dc.l		0		
		dc.l		0		
		dc.l		AboutName	
		dc.l		0		
		dc.l		0		
		dc.w		5,5		
		dc.w		640,200		
		dc.w		WBENCHSCREEN	

AboutName	dc.b		'Programmed by S.Marshall & M.Meany.',0
		even


about_text	dc.b		2,0,RP_JAM2,0	
		dc.w		13,20		
		dc.l		0		
		dc.l		AboutText1	
		dc.l		About2		

AboutText1	dc.b		'This program © M.Meany 1990',0
		even

About2		dc.b		2,0,RP_JAM2,0	
		dc.w		13,31		
		dc.l		0		
		dc.l		AboutText2	
		dc.l		About3		

AboutText2	dc.b		'Feel free to write to me at',0
		even

About3		dc.b		2,0,RP_JAM2,0	
		dc.w		15,42		
		dc.l		0		
		dc.l		AboutText3	
		dc.l		About5		

AboutText3	dc.b		'the following address',0
		even

About5		dc.b		1,0,RP_JAM2,0	
		dc.w		80,64		
		dc.l		0		
		dc.l		AboutText5	
		dc.l		About6		

AboutText5	dc.b		'Mark Meany,',0
		even

About6		dc.b		1,0,RP_JAM2,0	
		dc.w		80,74		
		dc.l		0		
		dc.l		AboutText6	
		dc.l		About7		

AboutText6	dc.b		'1 Cromwell Road,',0
		even

About7		dc.b		1,0,RP_JAM2,0	
		dc.w		80,84		
		dc.l		0		
		dc.l		AboutText7	
		dc.l		About8		

AboutText7	dc.b		'Southampton,',0
		even

About8		dc.b		1,0,RP_JAM2,0	
		dc.w		80,94		
		dc.l		0		
		dc.l		AboutText8	
		dc.l		About9		

AboutText8	dc.b		'Hants.,',0
		even

About9		dc.b		1,0,RP_JAM2,0	
		dc.w		80,104		
		dc.l		0		
		dc.l		AboutText9	
		dc.l		0		

AboutText9	dc.b		'SO1 2JH',0
		even
