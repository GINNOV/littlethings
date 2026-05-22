
MyScreen
	dc.w	0,0	;screen XY origin relative to View
	dc.w	640,256	;screen width and height
	dc.w	3	;screen depth (number of bitplanes)
	dc.b	0,1	;detail and block pens
	dc.w	V_HIRES	;display modes for this screen
	dc.w	CUSTOMSCREEN	;screen type
	dc.l	0	;pointer to default screen font
	dc.l	0	;screen title
	dc.l	0	;first in list of custom screen gadgets
	dc.l	0	;pointer to custom BitMap structure

Palette	dc.w	$0556	;color #0
	dc.w	$0FFF	;color #1
	dc.w	$015C	;color #2
	dc.w	$09BB	;color #3
	dc.w	$0FE0	;color #4
	dc.w	$0444	;color #5
	dc.w	$0B52	;color #6
	dc.w	$0CA9	;color #7

MyWindow
	dc.w	0,0
	dc.w	640,256
	dc.b	0,1
	dc.l	GADGETUP+RAWKEY+GADGETDOWN
	dc.l	BORDERLESS+ACTIVATE+NOCAREREFRESH
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	5,5
	dc.w	640,256
	dc.w	CUSTOMSCREEN

Str1Gadg:
	dc.l	Str2Gadg
	dc.w	44,80
	dc.w	270,8
	dc.w	0
	dc.w	GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	0	
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	GotSelection

Str2Gadg:
	dc.l	Str3Gadg
	dc.w	44,89
	dc.w	270,8
	dc.w	0
	dc.w	GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	1
	dc.l	GotSelection
Str3Gadg:
	dc.l	Str4Gadg
	dc.w	44,98
	dc.w	270,8
	dc.w	0
	dc.w	GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	2
	dc.l	GotSelection
Str4Gadg:
	dc.l	Str5Gadg
	dc.w	44,107
	dc.w	270,8
	dc.w	0
	dc.w	GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	3
	dc.l	GotSelection
Str5Gadg:
	dc.l	Str6Gadg
	dc.w	44,116
	dc.w	270,8
	dc.w	0
	dc.w	GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	4
	dc.l	GotSelection
Str6Gadg:
	dc.l	Str7Gadg
	dc.w	44,125
	dc.w	270,8
	dc.w	0
	dc.w	GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	5
	dc.l	GotSelection
Str7Gadg:
	dc.l	Str8Gadg
	dc.w	44,134
	dc.w	270,8
	dc.w	0
	dc.w	GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	6
	dc.l	GotSelection
Str8Gadg:
	dc.l	Str9Gadg
	dc.w	44,143
	dc.w	270,8
	dc.w	0
	dc.w	GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	7
	dc.l	GotSelection
Str9Gadg:
	dc.l	Str10Gadg
	dc.w	44,152
	dc.w	270,8
	dc.w	0
	dc.w	GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	8
	dc.l	GotSelection
Str10Gadg:
	dc.l	Str11Gadg
	dc.w	44,161
	dc.w	270,8
	dc.w	0
	dc.w	GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	9
	dc.l	GotSelection
Str11Gadg:
	dc.l	Str12Gadg
	dc.w	44,170
	dc.w	270,8
	dc.w	0
	dc.w	GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	10
	dc.l	GotSelection
Str12Gadg:
	dc.l	Str13Gadg
	dc.w	44,179
	dc.w	270,8
	dc.w	0
	dc.w	GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	11
	dc.l	GotSelection
Str13Gadg:
	dc.l	Str14Gadg
	dc.w	44,188
	dc.w	270,8
	dc.w	0
	dc.w	GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	12
	dc.l	GotSelection
Str14Gadg:
	dc.l	Str15Gadg
	dc.w	44,197
	dc.w	270,8
	dc.w	0
	dc.w	GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	13
	dc.l	GotSelection
Str15Gadg:
	dc.l	Str16Gadg
	dc.w	44,206
	dc.w	270,8
	dc.w	0
	dc.w	GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	14
	dc.l	GotSelection
Str16Gadg:
	dc.l	Str17Gadg
	dc.w	44,215
	dc.w	270,8
	dc.w	0
	dc.w	GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	15
	dc.l	GotSelection
Str17Gadg:
	dc.l	UpGadg
	dc.w	44,224
	dc.w	270,8
	dc.w	0
	dc.w	GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	16
	dc.l	GotSelection
UpGadg:
	dc.l	DownGadg
	dc.w	325,77
	dc.w	15,11
	dc.w	GADGHIMAGE+GADGIMAGE
	dc.w	GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	.Image1
	dc.l	.Image2
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	Up
.Image1
	dc.w	0,0
	dc.w	15,11
	dc.w	2
	dc.l	UpIm1
	dc.b	$0003,$0000
	dc.l	0
.Image2
	dc.w	0,0
	dc.w	15,11
	dc.w	2
	dc.l	UpIm2
	dc.b	$0003,$0000
	dc.l	0
DownGadg
	dc.l	0
	dc.w	325,221
	dc.w	15,11
	dc.w	GADGHIMAGE+GADGIMAGE
	dc.w	GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	.Image1
	dc.l	.Image2
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	Down
.Image1
	dc.w	0,0
	dc.w	15,11
	dc.w	2
	dc.l	DownIm1
	dc.b	$0003,$0000
	dc.l	0
.Image2
	dc.w	0,0
	dc.w	15,11
	dc.w	2
	dc.l	DownIm2
	dc.b	$0003,$0000
	dc.l	0

Image1
	dc.w	0,0
	dc.w	640,256
	dc.w	3
	dc.l	ImageData1
	dc.b	$0007,$0000
	dc.l	0

BoxText
	dc.b	1,3,RP_JAM2,0
	dc.w	45,80
	dc.l	0
	dc.l	mt
	dc.l	.clr1

.clr1	dc.b	1,3,RP_JAM2,0
	dc.w	45,89
	dc.l	0
	dc.l	mt
	dc.l	.clr2

.clr2	dc.b	1,3,RP_JAM2,0
	dc.w	45,98
	dc.l	0
	dc.l	mt
	dc.l	.clr3

.clr3	dc.b	1,3,RP_JAM2,0
	dc.w	45,107
	dc.l	0
	dc.l	mt
	dc.l	.clr4

.clr4	dc.b	1,3,RP_JAM2,0
	dc.w	45,116
	dc.l	0
	dc.l	mt
	dc.l	.clr5

.clr5	dc.b	1,3,RP_JAM2,0
	dc.w	45,125
	dc.l	0
	dc.l	mt
	dc.l	.clr6

.clr6	dc.b	1,3,RP_JAM2,0
	dc.w	45,134
	dc.l	0
	dc.l	mt
	dc.l	.clr7

.clr7	dc.b	1,3,RP_JAM2,0
	dc.w	45,143
	dc.l	0
	dc.l	mt
	dc.l	.clr8

.clr8	dc.b	1,3,RP_JAM2,0
	dc.w	45,152
	dc.l	0
	dc.l	mt
	dc.l	.clr9

.clr9	dc.b	1,3,RP_JAM2,0
	dc.w	45,161
	dc.l	0
	dc.l	mt
	dc.l	.clr10

.clr10	dc.b	1,3,RP_JAM2,0
	dc.w	45,170
	dc.l	0
	dc.l	mt
	dc.l	.clr11

.clr11	dc.b	1,3,RP_JAM2,0
	dc.w	45,179
	dc.l	0
	dc.l	mt
	dc.l	.clr12

.clr12	dc.b	1,3,RP_JAM2,0
	dc.w	45,188
	dc.l	0
	dc.l	mt
	dc.l	.clr13

.clr13	dc.b	1,3,RP_JAM2,0
	dc.w	45,197
	dc.l	0
	dc.l	mt
	dc.l	.clr14

.clr14	dc.b	1,3,RP_JAM2,0
	dc.w	45,206
	dc.l	0
	dc.l	mt
	dc.l	.clr15

.clr15	dc.b	1,3,RP_JAM2,0
	dc.w	45,215
	dc.l	0
	dc.l	mt
	dc.l	.clr16

.clr16	dc.b	1,3,RP_JAM2,0
	dc.w	45,224
	dc.l	0
	dc.l	mt
	dc.l	clr1


clr1	dc.b	1,3,RP_JAM2,0
	dc.w	45,80
	dc.l	0
ptr1	dc.l	mt
	dc.l	clr2

clr2	dc.b	1,3,RP_JAM2,0
	dc.w	45,89
	dc.l	0
ptr2	dc.l	mt
	dc.l	clr3

clr3	dc.b	1,3,RP_JAM2,0
	dc.w	45,98
	dc.l	0
ptr3	dc.l	mt
	dc.l	clr4

clr4	dc.b	1,3,RP_JAM2,0
	dc.w	45,107
	dc.l	0
ptr4	dc.l	mt
	dc.l	clr5

clr5	dc.b	1,3,RP_JAM2,0
	dc.w	45,116
	dc.l	0
ptr5	dc.l	mt
	dc.l	clr6

clr6	dc.b	1,3,RP_JAM2,0
	dc.w	45,125
	dc.l	0
ptr6	dc.l	mt
	dc.l	clr7

clr7	dc.b	1,3,RP_JAM2,0
	dc.w	45,134
	dc.l	0
ptr7	dc.l	mt
	dc.l	clr8

clr8	dc.b	1,3,RP_JAM2,0
	dc.w	45,143
	dc.l	0
ptr8	dc.l	mt
	dc.l	clr9

clr9	dc.b	1,3,RP_JAM2,0
	dc.w	45,152
	dc.l	0
ptr9	dc.l	mt
	dc.l	clr10

clr10	dc.b	1,3,RP_JAM2,0
	dc.w	45,161
	dc.l	0
ptr10	dc.l	mt
	dc.l	clr11

clr11	dc.b	1,3,RP_JAM2,0
	dc.w	45,170
	dc.l	0
ptr11	dc.l	mt
	dc.l	clr12

clr12	dc.b	1,3,RP_JAM2,0
	dc.w	45,179
	dc.l	0
ptr12	dc.l	mt
	dc.l	clr13

clr13	dc.b	1,3,RP_JAM2,0
	dc.w	45,188
	dc.l	0
ptr13	dc.l	mt
	dc.l	clr14

clr14	dc.b	1,3,RP_JAM2,0
	dc.w	45,197
	dc.l	0
ptr14	dc.l	mt
	dc.l	clr15

clr15	dc.b	1,3,RP_JAM2,0
	dc.w	45,206
	dc.l	0
ptr15	dc.l	mt
	dc.l	clr16

clr16	dc.b	1,3,RP_JAM2,0
	dc.w	45,215
	dc.l	0
ptr16	dc.l	mt
	dc.l	clr17

clr17	dc.b	1,3,RP_JAM2,0
	dc.w	45,224
	dc.l	0
ptr17	dc.l	mt
	dc.l	0


clrT	dc.b	1,3,RP_JAM2,0
	dc.w	45,80
	dc.l	0
ptrT	dc.l	mt
	dc.l	0


clrB	dc.b	1,3,RP_JAM2,0
	dc.w	45,224
	dc.l	0
ptrB	dc.l	mt
	dc.l	0



mt	dc.b	'                                ',0
		even

	section		piccy,data_c

UpIm1
	dc.w	$0000,$0780,$0FC0,$1FE0,$3FF0,$0780,$0780,$0780
	dc.w	$0780,$0780,$0000,$0000,$0180,$03C0,$07E0,$0FF0
	dc.w	$0180,$0180,$0180,$0180,$0180,$0000
UpIm2
	dc.w	$0000,$0780,$0FC0,$1FE0,$3FF0,$0780,$0780,$0780
	dc.w	$0780,$0780,$0000,$0000,$0600,$0F00,$1F80,$3FC0
	dc.w	$0600,$0600,$0600,$0600,$0600,$0000
DownIm1
	dc.w	$0000,$03C0,$03C0,$03C0,$03C0,$03C0,$1FF8,$0FF0
	dc.w	$07E0,$03C0,$0000,$0000,$00C0,$00C0,$00C0,$00C0
	dc.w	$00C0,$07F8,$03F0,$01E0,$00C0,$0000
DownIm2
	dc.w	$0000,$03C0,$03C0,$03C0,$03C0,$03C0,$1FF8,$0FF0
	dc.w	$07E0,$03C0,$0000,$0000,$0300,$0300,$0300,$0300
	dc.w	$0300,$1FE0,$0FC0,$0780,$0300,$0000

ImageData1	incbin		Menu_win.bm
		even


