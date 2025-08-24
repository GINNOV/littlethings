Start	lea	y1f6,a0
	lea	Dat1(pc),a1
	lea	y42a,a4
	bsr	.2

	lea	y42a,a0
	lea	Dat2(pc),a1
	lea	y69a,a4
	bsr	.2

	lea	y69a,a0
	lea	Dat3(pc),a1
	lea	y93a,a4
	bsr	.2

	lea	y93a,a0
	lea	Dat4(pc),a1
	lea	yb4a,a4
	bsr	.2

	lea	yb4a,a0
	lea	Dat5(pc),a1
	lea	ycfa,a4
	bsr	.2

	lea	ycfa,a0
	lea	Dat6(pc),a1
	lea	yefa,a4
	bsr	.2

	lea	yefa,a0
	lea	Dat7(pc),a1
	lea	Pattern,a4
	bsr	.2

	rts


.2	lea	PerTble(pc),a2
.1	cmp.l	a0,a4
	beq	.9
	moveq	#0,d0
	move.l	(a0)+,d0
	move.l	d0,d1
	clr.b	d1
	rol.l	#8,d1
	lsl.w	#2,d1
	lea	(a1,d1),a3

	move.w	d0,d1
	and.w	#$fff,d1
	or.w	d1,2(a3)

	move.l	d0,d1
	lsr.l	#8,d1
	lsr.l	#4,d1
	and.w	#%11111,d1
	move.w	d1,d2
	lsl.b	#4,d1
	and.b	#$f0,d2
	or.b	d1,2(a3)
	or.b	d2,(a3)

	move.l	d0,d1
	swap	d1
	and.w	#%1111110,d1
	move.w	(a2,d1),d1
	or.w	d1,(a3)
	
	bra	.1
.9	rts

PerTble	dc.w	0
	dc.w	856,808,762,720,678,640,604,570,538,508,480,453
	dc.w	428,404,381,360,339,320,302,285,269,254,240,226
	dc.w	214,202,190,180,170,160,151,143,135,127,120,113

; _____byte 1_____   byte2_    _____byte 3_____   byte4_
;/                \ /      \  /                \ /      \
;0000          0000-00000000  0000          0000-00000000
;
;Upper four    12 bits for    Lower four    Effect command.
;bits of sam-  note period.   bits of sam-
;ple number.                  ple number.





;
;Have you ever wondered how a Protracker 1.1B module is built up?
;
;Well, here's the...
;
;Protracker 1.1B Song/Module Format:
;-----------------------------------
;
;Offset  Bytes  Description
;------  -----  -----------
;   0     20    Songname. Remember to put trailing null bytes at the end...
;
;Information for sample 1-31:
;
;Offset  Bytes  Description
;------  -----  -----------
;  20     22    Samplename for sample 1. Pad with null bytes.
;  42      2    Samplelength for sample 1. Stored as number of words.
;               Multiply by two to get real sample length in bytes.
;  44      1    Lower four bits are the finetune value, stored as a signed
;               four bit number. The upper four bits are not used, and
;               should be set to zero.
;               Value:  Finetune:
;                 0        0		0*72
;                 1       +1		1*72
;                 2       +2		2*72
;                 3       +3		3*72
;                 4       +4		4*72
;                 5       +5		5*72
;                 6       +6		6*72
;                 7       +7		7*72
;                 8       -8		8*72
;                 9       -7		9*72
;                 A       -6		a*72
;                 B       -5		b*72
;                 C       -4		c*72
;                 D       -3		d*72
;                 E       -2		e*72
;                 F       -1		f*72
;
;  45      1    Volume for sample 1. Range is $00-$40, or 0-64 decimal.
;  46      2    Repeat point for sample 1. Stored as number of words offset
;               from start of sample. Multiply by two to get offset in bytes.
;  48      2    Repeat Length for sample 1. Stored as number of words in
;               loop. Multiply by two to get replen in bytes.
;
;Information for the next 30 samples starts here. It's just like the info for
;sample 1.
;
;Offset  Bytes  Description
;------  -----  -----------
;  50     30    Sample 2...
;  80     30    Sample 3...
;   .
;   .
;   .
; 890     30    Sample 30...
; 920     30    Sample 31...
;
;Offset  Bytes  Description
;------  -----  -----------
; 950      1    Songlength. Range is 1-128.
; 951      1    Well... this little byte here is set to 127, so that old
;               trackers will search through all patterns when loading.
;               Noisetracker uses this byte for restart, but we don't.
; 952    128    Song positions 0-127. Each hold a number from 0-63 that
;               tells the tracker what pattern to play at that position.
;1080      4    The four letters "M.K." - This is something Mahoney & Kaktus
;               inserted when they increased the number of samples from
;               15 to 31. If it's not there, the module/song uses 15 samples
;               or the text has been removed to make the module harder to
;               rip. Startrekker puts "FLT4" or "FLT8" there instead.
;
;Offset  Bytes  Description
;------  -----  -----------
;1084    1024   Data for pattern 00.
;   .
;   .
;   .
;xxxx  Number of patterns stored is equal to the highest patternnumber
;      in the song position table (at offset 952-1079).
;
;Each note is stored as 4 bytes, and all four notes at each position in
;the pattern are stored after each other.
;
;00 -  chan1  chan2  chan3  chan4
;01 -  chan1  chan2  chan3  chan4
;02 -  chan1  chan2  chan3  chan4
;etc.
;
;Info for each note:
;
; _____byte 1_____   byte2_    _____byte 3_____   byte4_
;/                \ /      \  /                \ /      \
;0000          0000-00000000  0000          0000-00000000
;
;Upper four    12 bits for    Lower four    Effect command.
;bits of sam-  note period.   bits of sam-
;ple number.                  ple number.
;
;Periodtable for Tuning 0, Normal
;  C-1 to B-1 : 856,808,762,720,678,640,604,570,538,508,480,453
;  C-2 to B-2 : 428,404,381,360,339,320,302,285,269,254,240,226
;  C-3 to B-3 : 214,202,190,180,170,160,151,143,135,127,120,113
;
;To determine what note to show, scan through the table until you find
;the same period as the one stored in byte 1-2. Use the index to look
;up in a notenames table.
;
;This is the data stored in a normal song. A packed song starts with the
;four letters "PACK", but i don't know how the song is packed: You can
;get the source code for the cruncher/decruncher from us if you need it,
;but I don't understand it; I've just ripped it from another tracker...
;
;In a module, all the samples are stored right after the patterndata.
;To determine where a sample starts and stops, you use the sampleinfo
;structures in the beginning of the file (from offset 20). Take a look
;at the mt_init routine in the playroutine, and you'll see just how it
;is done.
;
;Lars "ZAP" Hamre/Amiga Freelancers






;

Module3	dc.b	"DarkRoom"
	dcb.b	12,0

	dcb.b	22,0
	dc.w	$0cfb
	dc.b	13
	dc.b	$40
	dc.w	($1096-$1096)/2
	dc.w	$0001

	dcb.b	22,0
	dc.w	$04ed
	dc.b	0
	dc.b	$30
	dc.w	($2fcc-$2a8c)/2
	dc.w	$024d

	dcb.b	22,0
	dc.w	$06af
	dc.b	13
	dc.b	$30
	dc.w	($3466-$3466)/2
	dc.w	$0001

	dcb.b	22,0
	dc.w	$064b
	dc.b	13
	dc.b	$40
	dc.w	($4e02-$41c4)/2
	dc.w	$002c

	dcb.b	22,0
	dc.w	$01bb
	dc.b	5
	dc.b	$20
	dc.w	($4e5a-$4e5a)/2
	dc.w	$0001

	dcb.b	22,0
	dc.w	$015b
	dc.b	0
	dc.b	$40
	dc.w	($51d0-$51d0)/2
	dc.w	$0001

	dcb.b	22,0
	dc.w	$0d62
	dc.b	13
	dc.b	$40
	dc.w	($5486-$5486)/2
	dc.w	$0001

	dcb.b	22,0
	dc.w	$0301
	dc.b	0
	dc.b	$20
	dc.w	($6f4c-$6f4a)/2
	dc.w	$0300

	dcb.b	22,0
	dc.w	$05d0
	dc.b	12
	dc.b	$30
	dc.w	($754c-$754c)/2
	dc.w	$0001

	dcb.b	22,0
	dc.w	$01a1
	dc.b	14
	dc.b	$40
	dc.w	($8146-$80ec)/2
	dc.w	$0174

	dcb.b	22,0
	dc.w	$2000
	dc.b	0
	dc.b	$40
	dc.w	($942e-$842e)/2
	dc.w	$1800

	dcb.b	22,0
	dc.w	$01ce
	dc.b	15
	dc.b	$30
	dc.w	($c42e-$c42e)/2
	dc.w	$0001

	dcb.b	22,0
	dc.w	$0000
	dc.b	0
	dc.b	$00
	dc.w	($c7ca-$c7ca)/2
	dc.w	$0001

	dcb.b	22,0
	dc.w	$0000
	dc.b	0
	dc.b	$00
	dc.w	($c7ca-$c7ca)/2
	dc.w	$0001

	dcb.b	22,0
	dc.w	$054b
	dc.b	0
	dc.b	$20
	dc.w	($c85e-$c7ca)/2
	dc.w	$0501

	dcb.b	22,0
	dc.w	$0000
	dc.w	$0000
	dc.w	($d260-$d260)/2
	dc.w	$0001

	dcb.b	22,0
	dc.w	$0000
	dc.w	$0000
	dc.w	($d260-$d260)/2
	dc.w	$0001

	dcb.b	22,0
	dc.w	$0000
	dc.w	$0000
	dc.w	($d260-$d260)/2
	dc.w	$0001

	dcb.b	22,0
	dc.w	$0000
	dc.w	$0000
	dc.w	($d260-$d260)/2
	dc.w	$0001

	dcb.b	22,0
	dc.w	$0000
	dc.w	$0000
	dc.w	($d260-$d260)/2
	dc.w	$0001

	dcb.b	22,0
	dc.w	$0000
	dc.w	$0000
	dc.w	($d260-$d260)/2
	dc.w	$0001

	dcb.b	22,0
	dc.w	$0000
	dc.w	$0000
	dc.w	($d260-$d260)/2
	dc.w	$0001

	dcb.b	22,0
	dc.w	$0000
	dc.w	$0000
	dc.w	($d260-$d260)/2
	dc.w	$0001

	dcb.b	22,0
	dc.w	$0000
	dc.w	$0000
	dc.w	($d260-$d260)/2
	dc.w	$0001

	dcb.b	22,0
	dc.w	$0000
	dc.w	$0000
	dc.w	($d260-$d260)/2
	dc.w	$0001

	dcb.b	22,0
	dc.w	$0000
	dc.w	$0000
	dc.w	($d260-$d260)/2
	dc.w	$0001

	dcb.b	22,0
	dc.w	$0000
	dc.w	$0000
	dc.w	($d260-$d260)/2
	dc.w	$0001

	dcb.b	22,0
	dc.w	$0000
	dc.w	$0000
	dc.w	($d260-$d260)/2
	dc.w	$0001

	dcb.b	22,0
	dc.w	$0000
	dc.w	$0000
	dc.w	($d260-$d260)/2
	dc.w	$0001

	dcb.b	22,0
	dc.w	$0000
	dc.w	$0000
	dc.w	($d260-$d260)/2
	dc.w	$0001

	dcb.b	22,0
	dc.w	$0000
	dc.w	$0000
	dc.w	($d260-$d260)/2
	dc.w	$0001

	dc.b	9
	dc.b	127
	dc.b	2,3,4,4,0,0,1,5,6
	dcb.b	128-9,0

	dc.b	"M.K."

Dat1	dcb.b	1024,0
Dat2	dcb.b	1024,0
Dat3	dcb.b	1024,0
Dat4	dcb.b	1024,0
Dat5	dcb.b	1024,0
Dat6	dcb.b	1024,0
Dat7	dcb.b	1024,0

	incbin	"DH1:DarkRoom/Music"
Module3End;	END


Module2	dc.l	Pattern-Module2
	dc.w	$0609


	;	  ?    Vol  SmpLn RepLn Smple-Offst Rpeat-Offst
	;	----- ----- ----- ----- ----------- -----------
	dc.w	$03a8,$0040,$0cfb,$0001,$0000,$1096,$0000,$1096
	dc.w	$0000,$0030,$04ed,$024d,$0000,$2a8c,$0000,$2fcc
	dc.w	$03a8,$0030,$06af,$0001,$0000,$3466,$0000,$3466
	dc.w	$03a8,$0040,$064b,$002c,$0000,$41c4,$0000,$4e02
	dc.w	$0168,$0020,$01bb,$0001,$0000,$4e5a,$0000,$4e5a
	dc.w	$0000,$0040,$015b,$0001,$0000,$51d0,$0000,$51d0
	dc.w	$03a8,$0040,$0d62,$0001,$0000,$5486,$0000,$5486
	dc.w	$0000,$0020,$0301,$0300,$0000,$6f4a,$0000,$6f4c
	dc.w	$0360,$0030,$05d0,$0001,$0000,$754c,$0000,$754c
	dc.w	$03f0,$0040,$01a1,$0174,$0000,$80ec,$0000,$8146
	dc.w	$0000,$0040,$2000,$1800,$0000,$842e,$0000,$942e
	dc.w	$0438,$0030,$01ce,$0001,$0000,$c42e,$0000,$c42e
	dc.w	$0000,$0000,$0000,$0001,$0000,$c7ca,$0000,$c7ca
	dc.w	$0000,$0000,$0000,$0001,$0000,$c7ca,$0000,$c7ca
	dc.w	$0000,$0020,$054b,$0501,$0000,$c7ca,$0000,$c85e
	dc.w	$0000,$0000,$0000,$0001,$0000,$d260,$0000,$d260
	dc.w	$0000,$0000,$0000,$0001,$0000,$d260,$0000,$d260
	dc.w	$0000,$0000,$0000,$0001,$0000,$d260,$0000,$d260
	dc.w	$0000,$0000,$0000,$0001,$0000,$d260,$0000,$d260
	dc.w	$0000,$0000,$0000,$0001,$0000,$d260,$0000,$d260
	dc.w	$0000,$0000,$0000,$0001,$0000,$d260,$0000,$d260
	dc.w	$0000,$0000,$0000,$0001,$0000,$d260,$0000,$d260
	dc.w	$0000,$0000,$0000,$0001,$0000,$d260,$0000,$d260
	dc.w	$0000,$0000,$0000,$0001,$0000,$d260,$0000,$d260
	dc.w	$0000,$0000,$0000,$0001,$0000,$d260,$0000,$d260
	dc.w	$0000,$0000,$0000,$0001,$0000,$d260,$0000,$d260
	dc.w	$0000,$0000,$0000,$0001,$0000,$d260,$0000,$d260
	dc.w	$0000,$0000,$0000,$0001,$0000,$d260,$0000,$d260
	dc.w	$0000,$0000,$0000,$0001,$0000,$d260,$0000,$d260
	dc.w	$0000,$0000,$0000,$0001,$0000,$d260,$0000,$d260
	dc.w	$0000,$0000,$0000,$0001,$0000,$d260,$0000,$d260

y1f6	dc.w	$002a,$1f08,$010c,$2000,$0226,$6c08,$030e,$9000
	dc.w	$0400,$0f05,$0800,$0f08,$0a0e,$6000,$0c00,$0f05
	dc.w	$102a,$7f08,$1100,$0c10,$1226,$6000,$130e,$9c20
	dc.w	$1400,$0f05,$182a,$3f08,$1900,$0c20,$1a12,$5c18
	dc.w	$1c00,$0f05,$1d00,$0c08,$202a,$3f08,$2100,$0c10
	dc.w	$2212,$5c26,$230e,$9c10,$2400,$0f05,$2500,$0c08
	dc.w	$262a,$5c10,$282a,$4f08,$2900,$0c04,$2c00,$0f05
	dc.w	$2e2a,$5c08,$302a,$7f08,$3226,$6000,$330e,$9c08
	dc.w	$3400,$0f05,$362a,$5c04,$3800,$0f08,$3a12,$5c10
	dc.w	$3c00,$0f05,$3e2a,$5c02,$402a,$1f08,$430e,$9c04
	dc.w	$4400,$0f05,$462a,$5c01,$4800,$0f08,$4900,$0c20
	dc.w	$4a06,$8000,$4c00,$0f05,$502a,$7f08,$5226,$6000
	dc.w	$530e,$9c02,$5400,$0f05,$5500,$0c08,$582a,$3f08
	dc.w	$5900,$0c16,$5a26,$6c18,$5c00,$0f05,$5d00,$0c06
	dc.w	$602a,$3f08,$6100,$0c0d,$621e,$a000,$6400,$0f05
	dc.w	$6500,$0c06,$682a,$4f08,$6900,$0c03,$6c00,$0f05
	dc.w	$702a,$7f08,$7226,$6000,$7400,$0f05,$7800,$0f08
	dc.w	$7a26,$6c18,$7c00,$0f05,$802a,$1f08,$810c,$2000
	dc.w	$8226,$6c08,$830e,$9000,$8400,$0f05,$8800,$0f08
	dc.w	$8a0e,$6000,$8c00,$0f05,$902a,$7f08,$9100,$0c10
	dc.w	$9226,$6000,$930e,$9c20,$9400,$0f05,$982a,$3f08
	dc.w	$9900,$0c20,$9a12,$5c18,$9c00,$0f05,$9d00,$0c08
	dc.w	$a02a,$3f08,$a100,$0c10,$a212,$5c26,$a30e,$9c10
	dc.w	$a400,$0f05,$a500,$0c08,$a62a,$5c10,$a82a,$4f08
	dc.w	$a900,$0c04,$ac00,$0f05,$ae2a,$5c08,$b02a,$7f08
	dc.w	$b226,$6000,$b30e,$9c08,$b400,$0f05,$b62a,$5c04
	dc.w	$b800,$0f08,$ba12,$5c10,$bc00,$0f05,$be2a,$5c02
	dc.w	$c02a,$1f08,$c30e,$9c04,$c400,$0f05,$c62a,$5c01
	dc.w	$c800,$0f08,$c900,$0c20,$ca06,$8000,$cc00,$0f05
	dc.w	$d02a,$7f08,$d226,$6000,$d30e,$9c02,$d400,$0f05
	dc.w	$d500,$0c08,$d82a,$3f08,$d900,$0c16,$da26,$6c18
	dc.w	$dc00,$0f05,$dd00,$0c06,$e02a,$3f08,$e100,$0c0d
	dc.w	$e21e,$a000,$e400,$0f05,$e500,$0c06,$e82a,$4f08
	dc.w	$e900,$0c03,$ec00,$0f05,$f02a,$7f08,$f226,$6000
	dc.w	$f400,$0f05,$f800,$0f08,$fa26,$6c18,$fc00,$0f05
	dc.w	$ff00,$0000

y42a	dc.w	$002a,$1f08,$010c,$2000,$0316,$bc20,$0400,$0f05
	dc.w	$0700,$0c21,$0800,$0f08,$0a0e,$6000,$0b00,$0c22
	dc.w	$0c00,$0f05,$0f00,$0c23,$102a,$7f08,$1100,$0c10
	dc.w	$1226,$6000,$1300,$0c24,$1400,$0f05,$1700,$0c25
	dc.w	$182a,$3f08,$1900,$0c20,$1a12,$5c18,$1b00,$0c26
	dc.w	$1c00,$0f05,$1d00,$0c08,$1f00,$0c27,$202a,$3f08
	dc.w	$2100,$0c10,$2212,$5c26,$2300,$0c28,$2400,$0f05
	dc.w	$2500,$0c08,$262a,$5c10,$2700,$0c29,$282a,$4f08
	dc.w	$2900,$0c04,$2b00,$0c2a,$2c00,$0f05,$2e2a,$5c08
	dc.w	$2f00,$0c2b,$302a,$7f08,$3226,$6000,$3300,$0c2c
	dc.w	$3400,$0f05,$362a,$5c04,$3700,$0c2d,$3800,$0f08
	dc.w	$3a12,$5c10,$3b00,$0c2e,$3c00,$0f05,$3e2a,$5c02
	dc.w	$3f00,$0c2f,$402a,$1f08,$4300,$0c30,$4400,$0f05
	dc.w	$462a,$5c01,$4700,$0c31,$4800,$0f08,$4900,$0c20
	dc.w	$4a06,$8000,$4b00,$0c32,$4c00,$0f05,$4f00,$0c33
	dc.w	$502a,$7f08,$5226,$6000,$5300,$0c34,$5400,$0f05
	dc.w	$5500,$0c08,$5700,$0c35,$582a,$3f08,$5900,$0c16
	dc.w	$5b00,$0c36,$5c00,$0f05,$5d00,$0c06,$5f00,$0c37
	dc.w	$602a,$3f08,$6100,$0c0d,$621e,$a000,$6300,$0c38
	dc.w	$6400,$0f05,$6500,$0c06,$6700,$0c39,$682a,$4f08
	dc.w	$6900,$0c03,$6b00,$0c3a,$6c00,$0f05,$6f00,$0c3b
	dc.w	$702a,$7f08,$7226,$6000,$7300,$0c3c,$7400,$0f05
	dc.w	$7700,$0c3d,$7800,$0f08,$7b00,$0c20,$7c00,$0f05
	dc.w	$802a,$1f08,$810c,$2000,$8316,$b000,$8400,$0f05
	dc.w	$8800,$0f08,$8a0e,$6000,$8c00,$0f05,$902a,$7f08
	dc.w	$9100,$0c10,$9226,$6000,$9400,$0f05,$982a,$3f08
	dc.w	$9900,$0c20,$9a12,$5c18,$9c00,$0f05,$9d00,$0c08
	dc.w	$a02a,$3f08,$a100,$0c10,$a212,$5c26,$a400,$0f05
	dc.w	$a500,$0c08,$a62a,$5c10,$a82a,$4f08,$a900,$0c04
	dc.w	$ac00,$0f05,$ae2a,$5c08,$b02a,$7f08,$b226,$6000
	dc.w	$b400,$0f05,$b62a,$5c04,$b800,$0f08,$ba12,$5c10
	dc.w	$bc00,$0f05,$be2a,$5c02,$c02a,$1f08,$c400,$0f05
	dc.w	$c62a,$5c01,$c800,$0f08,$c900,$0c20,$ca06,$8000
	dc.w	$cc00,$0f05,$d02a,$7f08,$d226,$6000,$d400,$0f05
	dc.w	$d500,$0c08,$d82a,$3f08,$d900,$0c16,$dc00,$0f05
	dc.w	$dd00,$0c06,$e02a,$3f08,$e100,$0c0d,$e21e,$a000
	dc.w	$e400,$0f05,$e500,$0c06,$e82a,$4f08,$e900,$0c03
	dc.w	$ec00,$0f05,$f02a,$7f08,$f226,$6000,$f300,$0a08
	dc.w	$f400,$0f05,$f800,$0f08,$fc00,$0f05
	dc.w	$ff00,$0000

y69a	dc.w	$0016,$bc10,$0300,$0f08,$0516,$bc08,$0700,$0f05
	dc.w	$0800,$0c11,$0900,$0c09,$0a2e,$cc20,$0b00,$0f08
	dc.w	$0d00,$0c0a,$0f00,$0f05,$1000,$0c12,$1100,$0c0b
	dc.w	$122e,$c000,$1300,$0f08,$1500,$0c0c,$1700,$0f05
	dc.w	$1800,$0c13,$1900,$0c0d,$1a16,$cc10,$1b00,$0f08
	dc.w	$1c00,$0c13,$1d00,$0c0e,$1f00,$0f05,$2000,$0f08
	dc.w	$2100,$0c0f,$2216,$c000,$2328,$ced4,$2400,$0f05
	dc.w	$2500,$0c10,$261a,$cc10,$2800,$0c15,$2900,$0f08
	dc.w	$2a32,$cc10,$2d00,$0f05,$2e36,$cc18,$3000,$0c16
	dc.w	$3100,$0f08,$3232,$c000,$3328,$cc18,$3500,$0f05
	dc.w	$361a,$cc10,$3800,$0c17,$3900,$0f08,$3a1e,$cc10
	dc.w	$3d00,$0f05,$3e28,$cc08,$4000,$0c18,$4100,$0f08
	dc.w	$4232,$cc18,$4328,$cc10,$4500,$0f05,$461a,$cc08
	dc.w	$4800,$0c19,$4900,$0f08,$4a1e,$cc08,$4d00,$0f05
	dc.w	$4e28,$cc04,$5000,$0c1a,$5100,$0f08,$5232,$cc0b
	dc.w	$5328,$cc08,$5500,$0f05,$561a,$cc05,$5800,$0c1b
	dc.w	$5900,$0f08,$5a1e,$cc05,$5d00,$0f05,$5e28,$cc02
	dc.w	$6000,$0c1c,$6100,$0f08,$6232,$cc07,$6328,$cc04
	dc.w	$6500,$0f05,$661a,$cc03,$6800,$0c1d,$6900,$0f08
	dc.w	$6a1e,$cc03,$6d00,$0f05,$6e28,$cc01,$7000,$0c1e
	dc.w	$7100,$0f08,$7232,$cc04,$7328,$cc02,$7500,$0f05
	dc.w	$761a,$cc02,$7800,$0c1f,$7900,$0f08,$7a1e,$cc02
	dc.w	$7d00,$0f05,$7e28,$cc01,$8000,$0c20,$8100,$0f08
	dc.w	$8500,$0f05,$8800,$0c21,$8900,$0f08,$8a2e,$cc20
	dc.w	$8d00,$0f05,$8f46,$cc10,$9000,$0c22,$9100,$0f08
	dc.w	$922e,$c000,$9500,$0f05,$9746,$cc06,$9800,$0c23
	dc.w	$9900,$0f08,$9a16,$cc10,$9d00,$0f05,$9f46,$cc03
	dc.w	$a000,$0c24,$a100,$0f08,$a210,$c000,$a31e,$cc04
	dc.w	$a500,$0f05,$a628,$cc10,$a800,$0c25,$a900,$0f08
	dc.w	$aa32,$cc10,$ad00,$0f05,$ae36,$cc18,$b000,$0c26
	dc.w	$b100,$0f08,$b228,$c000,$b31e,$cc04,$b500,$0f05
	dc.w	$b61a,$cc10,$b800,$0c27,$b900,$0f08,$ba1e,$cc10
	dc.w	$bd00,$0f05,$be36,$cc08,$c000,$0c28,$c100,$0f08
	dc.w	$c228,$cc18,$c31e,$cc04,$c500,$0f05,$c61a,$cc08
	dc.w	$c900,$0f08,$ca1e,$cc08,$cd00,$0f05,$ce36,$cc04
	dc.w	$d100,$0f08,$d228,$cc0b,$d31e,$cc04,$d500,$0f05
	dc.w	$d61a,$cc05,$d900,$0f08,$da1e,$cc05,$dd00,$0f05
	dc.w	$de36,$cc02,$e100,$0f08,$e228,$cc07,$e31e,$cc04
	dc.w	$e500,$0f05,$e61a,$cc03,$e900,$0f08,$ea1e,$cc03
	dc.w	$ed00,$0f05,$ee36,$cc01,$f100,$0f08,$f228,$cc04
	dc.w	$f31e,$cc04,$f500,$0f05,$f61a,$cc02,$f900,$0f08
	dc.w	$fa1e,$cc02,$fd00,$0f05,$fe36,$cc01
	dc.w	$ff00,$0000

y93a	dc.w	$0100,$0f08,$0500
	dc.w	$0f05,$0900,$0f08,$0a2e,$cc20,$0d00,$0f05,$1100
	dc.w	$0f08,$122e,$c000,$1500,$0f05,$1900,$0f08,$1a16
	dc.w	$cc10,$1d00,$0f05,$2100,$0f08,$2216,$c000,$2328
	dc.w	$ced4,$2500,$0f05,$261a,$cc10,$2900,$0f08,$2a32
	dc.w	$cc10,$2d00,$0f05,$2e36,$cc18,$3100,$0f08,$3232
	dc.w	$c000,$330e,$9c08,$3500,$0f05,$361a,$cc10,$3900
	dc.w	$0f08,$3a1e,$cc10,$3d00,$0f05,$3e28,$cc08,$4100
	dc.w	$0f08,$4232,$cc18,$430e,$9c10,$4500,$0f05,$461a
	dc.w	$cc08,$4900,$0f08,$4a1e,$cc08,$4d00,$0f05,$4e28
	dc.w	$cc04,$5100,$0f08,$5232,$cc0b,$530e,$9c20,$5500
	dc.w	$0f05,$561a,$cc05,$5900,$0f08,$5a1e,$cc05,$5d00
	dc.w	$0f05,$5e28,$cc02,$6100,$0f08,$6232,$cc07,$630e
	dc.w	$9000,$6500,$0f05,$661a,$cc03,$6900,$0f08,$6a1e
	dc.w	$cc03,$6d00,$0f05,$6e28,$cc01,$7100,$0f08,$7232
	dc.w	$cc04,$730e,$9c20,$7500,$0f05,$761a,$cc02,$7900
	dc.w	$0f08,$7a1e,$cc02,$7d00,$0f05,$7e28,$cc01,$8100
	dc.w	$0f08,$830e,$9c18,$8500,$0f05,$8900,$0f08,$8a2e
	dc.w	$cc20,$8d00,$0f05,$9100,$0f08,$922e,$c000,$930e
	dc.w	$9c10,$9500,$0f05,$9900,$0f08,$9a16,$cc10,$9d00
	dc.w	$0f05,$a100,$0f08,$a210,$c000,$a30e,$9c08,$a500
	dc.w	$0f05,$a628,$cc10,$a900,$0f08,$aa32,$cc10,$ad00
	dc.w	$0f05,$ae36,$cc18,$b100,$0f08,$b228,$c000,$b30e
	dc.w	$9c04,$b500,$0f05,$b61a,$cc10,$b900,$0f08,$ba1e
	dc.w	$cc10,$bd00,$0f05,$be36,$cc08,$c100,$0f08,$c228
	dc.w	$cc18,$c30e,$9c04,$c500,$0f05,$c61a,$cc08,$c900
	dc.w	$0f08,$ca1e,$cc08,$cd00,$0f05,$ce36,$cc04,$d100
	dc.w	$0f08,$d228,$cc0b,$d500,$0f05,$d61a,$cc05,$d900
	dc.w	$0f08,$da1e,$cc05,$dd00,$0f05,$de36,$cc02,$e100
	dc.w	$0f08,$e228,$cc07,$e500,$0f05,$e61a,$cc03,$e900
	dc.w	$0f08,$ea1e,$cc03,$ed00,$0f05,$ee36,$cc01,$f100
	dc.w	$0f08,$f228,$cc04,$f32a,$4000,$f500,$0f05,$f61a
	dc.w	$cc02,$f900,$0f08,$fa1e,$cc02,$fb2a,$7000,$fd00
	dc.w	$0f05,$fe36,$cc01
	dc.w	$ff00,$0000

yb4a	dc.w	$002a,$1f08,$0316,$bc20
	dc.w	$0400,$0f05,$0800,$0f08,$0b00,$0c21,$0c00,$0f05
	dc.w	$102a,$4f08,$1212,$bc10,$1300,$0c22,$1400,$0f05
	dc.w	$182a,$3f08,$1a00,$0c11,$1b00,$0c23,$1c00,$0f05
	dc.w	$202a,$3f08,$2200,$0c12,$2300,$0c24,$2400,$0f05
	dc.w	$282a,$4f08,$2a00,$0c13,$2b00,$0c25,$2c00,$0f05
	dc.w	$302a,$7f08,$3200,$0c14,$3300,$0c26,$3400,$0f05
	dc.w	$3800,$0f08,$3a00,$0c15,$3b00,$0c27,$3c00,$0f05
	dc.w	$402a,$1f08,$4200,$0c16,$4300,$0c28,$4400,$0f05
	dc.w	$4800,$0f08,$4a00,$0c17,$4b00,$0c29,$4c00,$0f05
	dc.w	$502a,$7f08,$5200,$0c18,$5300,$0c2a,$5400,$0f05
	dc.w	$582a,$3f08,$5a00,$0c19,$5c00,$0f05,$602a,$4f08
	dc.w	$6200,$0c1a,$6400,$0f05,$682a,$3f08,$6a00,$0c1b
	dc.w	$6c00,$0f05,$702a,$7f08,$7200,$0c1c,$7400,$0f05
	dc.w	$7800,$0f08,$7a00,$0c1d,$7c00,$0f05,$802a,$1f08
	dc.w	$8200,$0c1e,$8316,$b000,$8400,$0f05,$8800,$0f08
	dc.w	$8916,$bc20,$8a00,$0c1d,$8c00,$0f05,$8d00,$0e12
	dc.w	$902a,$4f08,$9200,$0c1c,$9400,$0f05,$982a,$3f08
	dc.w	$9a00,$0c1b,$9c00,$0f05,$a02a,$3f08,$a200,$0c1a
	dc.w	$a400,$0f05,$a82a,$4f08,$aa00,$0c19,$ac00,$0f05
	dc.w	$b02a,$7f08,$b200,$0c18,$b400,$0f05,$b800,$0f08
	dc.w	$ba00,$0c17,$bc00,$0f05,$c02a,$1f08,$c200,$0c16
	dc.w	$c400,$0f05,$c800,$0f08,$ca00,$0c15,$cc00
	dc.w	$0f05,$d02a,$7f08,$d200,$0c14,$d400,$0f05,$d82a
	dc.w	$3f08,$da00,$0c13,$dc00,$0f05,$e02a,$4f08,$e200
	dc.w	$0c12,$e400,$0f05,$e82a,$3f08,$ea00,$0c11,$ec00
	dc.w	$0f05,$f02a,$7f08,$f200,$0c10,$f400,$0f05,$f800
	dc.w	$0f08,$fc00,$0f05
	dc.w	$ff00,$0000

ycfa	dc.w	$002a,$1f08,$010c
	dc.w	$2000,$0316,$b000,$0400,$0f05,$0800,$0f08,$0a0e
	dc.w	$6000,$0c00,$0f05,$102a,$7f08,$1100,$0c10,$1226
	dc.w	$6000,$1400,$0f05,$182a,$3f08,$1900,$0c20,$1a12
	dc.w	$5c18,$1c00,$0f05,$1d00,$0c08,$202a,$3f08,$2100
	dc.w	$0c10,$2212,$5c26,$2400,$0f05,$2500,$0c08,$262a
	dc.w	$5c10,$282a,$4f08,$2900,$0c04,$2c00,$0f05,$2e2a
	dc.w	$5c08,$302a,$7f08,$3226,$6000,$3400,$0f05,$362a
	dc.w	$5c04,$3800,$0f08,$3a12,$5c10,$3c00,$0f05,$3e2a
	dc.w	$5c02,$402a,$1f08,$4400,$0f05,$462a,$5c01,$4800
	dc.w	$0f08,$4900,$0c20,$4a06,$8000,$4c00,$0f05,$502a
	dc.w	$7f08,$5226,$6000,$5400,$0f05,$5500,$0c08,$582a
	dc.w	$3f08,$5900,$0c16,$5c00,$0f05,$5d00,$0c06,$602a
	dc.w	$3f08,$6100,$0c0d,$621e,$a000,$6400,$0f05,$6500
	dc.w	$0c06,$682a,$4f08,$6900,$0c03,$6c00,$0f05,$702a
	dc.w	$7f08,$7226,$6000,$7400,$0f05,$7800,$0f08,$7b00
	dc.w	$0c20,$7c00,$0f05,$802a,$1f08,$810c,$2000,$8316
	dc.w	$b000,$8400,$0f05,$8800,$0f08,$8a0e,$6000,$8c00
	dc.w	$0f05,$902a,$7f08,$9100,$0c10,$9226,$6000,$9400
	dc.w	$0f05,$982a,$3f08,$9900,$0c20,$9a12,$5c18,$9c00
	dc.w	$0f05,$9d00,$0c08,$a02a,$3f08,$a100,$0c10,$a212
	dc.w	$5c26,$a400,$0f05,$a500,$0c08,$a62a,$5c10,$a82a
	dc.w	$4f08,$a900,$0c04,$ac00,$0f05,$ae2a,$5c08,$b02a
	dc.w	$7f08,$b226,$6000,$b400,$0f05,$b62a,$5c04,$b800
	dc.w	$0f08,$ba12,$5c10,$bc00,$0f05,$be2a,$5c02,$c02a
	dc.w	$1f08,$c400,$0f05,$c62a,$5c01,$c800,$0f08,$c900
	dc.w	$0c20,$ca06,$8000,$cc00,$0f05,$d02a,$7f08,$d226
	dc.w	$6000,$d400,$0f05,$d500,$0c08,$d82a,$3f08,$d900
	dc.w	$0c16,$dc00,$0f05,$dd00,$0c06,$e02a,$3f08,$e100
	dc.w	$0c0d,$e21e,$a000,$e42a,$7f05,$e500,$0c06,$e82a
	dc.w	$4f08,$e900,$0c03,$ec00,$0f05,$f02a,$7f08,$f226
	dc.w	$6000,$f300,$0a08,$f400,$0a0f,$f500,$0f05,$f800
	dc.w	$0f08,$fc00,$0f05
	dc.w	$ff00,$0000

yefa	dc.w	$0012,$1f08,$0106
	dc.w	$f000,$0202,$8000,$0306,$bc10,$0500,$0f05,$0900
	dc.w	$0f08,$0d00,$0f05,$1012,$1c10,$1100,$0f08,$1200
	dc.w	$0c04,$1300,$0c0f,$1500,$0f05,$1900,$0f08,$1d00
	dc.w	$0f05,$2012,$1c06,$2100,$0f08,$2300,$0c0e,$2500
	dc.w	$0f05,$2900,$0f08,$2d00,$0f05,$3012,$1c03,$3100
	dc.w	$0f08,$3300,$0c0d,$3500,$0f05,$3600,$0c20,$3900
	dc.w	$0f08,$3a00,$0c08,$3d00,$0f05,$4012,$1c01,$4100
	dc.w	$0f08,$4300,$0c0c,$4500,$0f05,$4600,$0c04,$480c
	dc.w	$fc08,$4900,$0f08,$4d00,$0f05,$5100,$0f08,$5300
	dc.w	$0c0b,$5500,$0f05,$5900,$0f08,$5d00,$0f05,$6100
	dc.w	$0f08,$6300,$0c0a,$6500,$0f05,$6900,$0f08,$6d00
	dc.w	$0f05,$7100,$0f08,$7300,$0c09,$7500,$0f05,$7900
	dc.w	$0f08,$7a00,$0c08,$7d00,$0f05,$8100,$0f08,$8300
	dc.w	$0c08,$8500,$0f05,$8900,$0f08,$8d00,$0f05,$9100
	dc.w	$0f08,$9300,$0c07,$9500,$0f05,$9900,$0f08,$9a00
	dc.w	$0c01,$9d00,$0f05,$a100,$0f08,$a300,$0c06,$a500
	dc.w	$0f05,$a900,$0f08,$ad00,$0f05,$b100,$0f08,$b300
	dc.w	$0c05,$b500,$0f05,$b900,$0f08,$bd00,$0f05,$c100
	dc.w	$0f08,$c300,$0c04,$c500,$0f05,$c900,$0f08,$cd00
	dc.w	$0f05,$d100,$0f08,$d300,$0c03,$d500,$0f05,$d900
	dc.w	$0f08,$dd00,$0f05,$e100,$0f08,$e300,$0c02,$e500
	dc.w	$0f05,$e900,$0f08,$ed00,$0f05,$f100,$0f08,$f500
	dc.w	$0f05,$f900,$0f08,$fd00,$0f00
	dc.w	$ff00,$0000

Pattern	dc.l	$0000069a
	dc.l	$0000093a
	dc.l	$00000b4a
	dc.l	$00000b4a
	dc.l	$000001f6
	dc.l	$000001f6
	dc.l	$0000042a
	dc.l	$00000cfa
	dc.l	$00000efa
	dc.l	-1

Samples	incbin	"DH1:DarkRoom/Music"

	END

;
; _____byte 1_____   byte2_    _____byte 3_____   byte4_
;/                \ /      \  /                \ /      \
;0000          0000-00000000  0000          0000-00000000
;
;Upper four    12 bits for    Lower four    Effect command.
;bits of sam-  note period.   bits of sam-
;ple number.                  ple number.
;
;Periodtable for Tuning 0, Normal
;  C-1 to B-1 : 856,808,762,720,678,640,604,570,538,508,480,453
;  C-2 to B-2 : 428,404,381,360,339,320,302,285,269,254,240,226
;  C-3 to B-3 : 214,202,190,180,170,160,151,143,135,127,120,113
;
	dc.w	$0016,$bc10
	dc.w	$0300,$0f08
	dc.w	$0516,$bc08
	dc.w	$0700,$0f05

	dc.w	$0016,$bc10,$0300,$0f08,$0516,$bc08,$0700,$0f05

	dc.w	$0016,$bc10
	00000000.00010110.10111100.00010000
(

