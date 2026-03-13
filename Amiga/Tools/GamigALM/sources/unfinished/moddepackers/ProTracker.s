;	Protracker 1.1B Song/Module Format
;	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	Offset  Bytes  Description
;	~~~~~~  ~~~~~  ~~~~~~~~~~~
;	   0     20    Songname. Padded with null bytes.
;	
;	  20     22    Samplename for sample 1. Padded with null bytes.
;	  42      2    Length/2
;	  44      1    Low 4 bits, Finetune. High 4 bits, Zero.
;	               0= 0,1=+1,2=+2,3=+3,4=+4,5=+5,6=+6,7=+7
;	               8=-8,9=-7,A=-6,B=-5,C=-4,D=-3,E=-2,F=-1
;	  45      1    Volume. Range is 0-64
;	  46      2    RepPnt/2
;	  48      2    RepLen/2
;	
;	  50     30    Sample 2...
;	  80     30    Sample 3...
;	   .
;	   .
;	 890     30    Sample 30...
;	 920     30    Sample 31...
;	
;	 950      1    Songlength. Range is 1-128.
;	 951      1    Set to 127 for compatability.
;	 952    128    Range is 0-63, pattern to play at that position.
;	1080      4    ID: "M.K."
;	
;	1084    1024   Data for pattern 0
;	
;	;--------------------------------------;
;	
;	Samples start at 1084+(Patterns*1024)
;	
;	Info for each note:
;	
;	 _____byte 1_____   byte2_    _____byte 3_____   byte4_
;	/                \ /      \  /                \ /      \
;	0000          0000-00000000  0000          0000-00000000
;	
;	Upper four    12 bits for    Lower four    Effect command.
;	bits of sam-  note period.   bits of sam-
;	ple number.                  ple number.
;	
;	Periodtable for Tuning 0, Normal
;	dc.w	856,808,762,720,678,640,604,570,538,508,480,453	; C-1 to B-1
;	dc.w	428,404,381,360,339,320,302,285,269,254,240,226	; C-2 to B-2
;	dc.w	214,202,190,180,170,160,151,143,135,127,120,113	; C-3 to B-3
;	
;	;--------------------------------------;
