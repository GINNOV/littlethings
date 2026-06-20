

MyWindow
	dc.w	178,37	;window XY origin relative to TopLeft of screen
	dc.w	304,133	;window width and height
	dc.b	0,1	;detail and block pens
	dc.l	MOUSEBUTTONS+GADGETUP+CLOSEWINDOW	;IDCMP flags
	dc.l	WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+ACTIVATE+RMBTRAP+NOCAREREFRESH	;other window flags
	dc.l	Gadget2	;first gadget in gadget list
	dc.l	0	;custom CHECKMARK imagery
	dc.l	NewWindowName1	;window title
	dc.l	0	;custom screen pointer
	dc.l	0	;custom bitmap
	dc.w	5,5	;minimum width and height
	dc.w	640,200	;maximum width and height
	dc.w	WBENCHSCREEN	;destination screen type
NewWindowName1:
	dc.b	'Try Filling The Pattern',0
	cnop 0,2



Gadget2:
	dc.l	Gadget3	;next gadget
	dc.w	34,16	;origin XY of hit box relative to window TopLeft
	dc.w	48,9	;hit box width and height
	dc.w	0	;gadget flags
	dc.w	RELVERIFY	;activation flags
	dc.w	BOOLGADGET	;gadget type flags
	dc.l	Border1	;gadget border or image to be rendered
	dc.l	0	;alternate imagery for selection
	dc.l	IText1	;first IntuiText structure
	dc.l	0	;gadget mutual-exclude long word
	dc.l	0	;SpecialInfo structure
	dc.w	0	;user-definable data
	dc.l	GreyPen	;pointer to user-definable data
Border1:
	dc.w	-2,-1	;XY origin relative to container TopLeft
	dc.b	1,0,RP_JAM1	;front pen, back pen and drawmode
	dc.b	5	;number of XY vectors
	dc.l	BorderVectors1	;pointer to XY vectors
	dc.l	0	;next border in list
BorderVectors1:
	dc.w	0,0
	dc.w	51,0
	dc.w	51,10
	dc.w	0,10
	dc.w	0,0
IText1:
	dc.b	1,0,RP_JAM2,0	;front and back text pens, drawmode and fill byte
	dc.w	3,1	;XY origin relative to container TopLeft
	dc.l	0	;font pointer or 0 for default
	dc.l	ITextText1	;pointer to text
	dc.l	0	;next IntuiText structure
ITextText1:
	dc.b	'Grey',0
	cnop 0,2
Gadget3:
	dc.l	Gadget4	;next gadget
	dc.w	90,16	;origin XY of hit box relative to window TopLeft
	dc.w	48,9	;hit box width and height
	dc.w	0	;gadget flags
	dc.w	RELVERIFY	;activation flags
	dc.w	BOOLGADGET	;gadget type flags
	dc.l	Border2	;gadget border or image to be rendered
	dc.l	0	;alternate imagery for selection
	dc.l	IText2	;first IntuiText structure
	dc.l	0	;gadget mutual-exclude long word
	dc.l	0	;SpecialInfo structure
	dc.w	0	;user-definable data
	dc.l	BlackPen	;pointer to user-definable data
Border2:
	dc.w	-2,-1	;XY origin relative to container TopLeft
	dc.b	1,0,RP_JAM1	;front pen, back pen and drawmode
	dc.b	5	;number of XY vectors
	dc.l	BorderVectors2	;pointer to XY vectors
	dc.l	0	;next border in list
BorderVectors2:
	dc.w	0,0
	dc.w	51,0
	dc.w	51,10
	dc.w	0,10
	dc.w	0,0
IText2:
	dc.b	1,0,RP_JAM2,0	;front and back text pens, drawmode and fill byte
	dc.w	1,1	;XY origin relative to container TopLeft
	dc.l	0	;font pointer or 0 for default
	dc.l	ITextText2	;pointer to text
	dc.l	0	;next IntuiText structure
ITextText2:
	dc.b	'Black',0
	cnop 0,2
Gadget4:
	dc.l	Gadget5	;next gadget
	dc.w	146,16	;origin XY of hit box relative to window TopLeft
	dc.w	48,9	;hit box width and height
	dc.w	0	;gadget flags
	dc.w	RELVERIFY	;activation flags
	dc.w	BOOLGADGET	;gadget type flags
	dc.l	Border3	;gadget border or image to be rendered
	dc.l	0	;alternate imagery for selection
	dc.l	IText3	;first IntuiText structure
	dc.l	0	;gadget mutual-exclude long word
	dc.l	0	;SpecialInfo structure
	dc.w	0	;user-definable data
	dc.l	WhitePen	;pointer to user-definable data
Border3:
	dc.w	-2,-1	;XY origin relative to container TopLeft
	dc.b	1,0,RP_JAM1	;front pen, back pen and drawmode
	dc.b	5	;number of XY vectors
	dc.l	BorderVectors3	;pointer to XY vectors
	dc.l	0	;next border in list
BorderVectors3:
	dc.w	0,0
	dc.w	51,0
	dc.w	51,10
	dc.w	0,10
	dc.w	0,0
IText3:
	dc.b	1,0,RP_JAM2,0	;front and back text pens, drawmode and fill byte
	dc.w	1,1	;XY origin relative to container TopLeft
	dc.l	0	;font pointer or 0 for default
	dc.l	ITextText3	;pointer to text
	dc.l	0	;next IntuiText structure
ITextText3:
	dc.b	'White',0
	cnop 0,2
Gadget5:
	dc.l	0	;next gadget
	dc.w	201,16	;origin XY of hit box relative to window TopLeft
	dc.w	48,9	;hit box width and height
	dc.w	0	;gadget flags
	dc.w	RELVERIFY	;activation flags
	dc.w	BOOLGADGET	;gadget type flags
	dc.l	Border4	;gadget border or image to be rendered
	dc.l	0	;alternate imagery for selection
	dc.l	IText4	;first IntuiText structure
	dc.l	0	;gadget mutual-exclude long word
	dc.l	0	;SpecialInfo structure
	dc.w	0	;user-definable data
	dc.l	BluePen	;pointer to user-definable data
Border4:
	dc.w	-2,-1	;XY origin relative to container TopLeft
	dc.b	1,0,RP_JAM1	;front pen, back pen and drawmode
	dc.b	5	;number of XY vectors
	dc.l	BorderVectors4	;pointer to XY vectors
	dc.l	0	;next border in list
BorderVectors4:
	dc.w	0,0
	dc.w	51,0
	dc.w	51,10
	dc.w	0,10
	dc.w	0,0
IText4:
	dc.b	1,0,RP_JAM2,0	;front and back text pens, drawmode and fill byte
	dc.w	3,1	;XY origin relative to container TopLeft
	dc.l	0	;font pointer or 0 for default
	dc.l	ITextText4	;pointer to text
	dc.l	0	;next IntuiText structure
ITextText4:
	dc.b	'Blue',0
	cnop 0,2



Image1:
	dc.w	0,0	;XY origin relative to container TopLeft
	dc.w	184,83	;Image width and height in pixels
	dc.w	2	;number of bitplanes in Image
	dc.l	ImageData1	;pointer to ImageData
	dc.b	$0001,$0000	;PlanePick and PlaneOnOff
	dc.l	0	;next Image structure


		section		gfx,data_c

ImageData1:
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FF00,$E000,$0020,$0000,$000A
	dc.w	$0000,$0000,$001C,$0000,$0003,$0000,$0000,$0100
	dc.w	$9800,$0010,$0000,$0011,$0000,$0000,$00E0,$0000
	dc.w	$0004,$8000,$0000,$0700,$8600,$0008,$0000,$0021
	dc.w	$0000,$0000,$0700,$0000,$0004,$4000,$0000,$1900
	dc.w	$8180,$0004,$0000,$0040,$8000,$0000,$7800,$0000
	dc.w	$0004,$2000,$0000,$6100,$8070,$0002,$0000,$0080
	dc.w	$4000,$0003,$8000,$0000,$0008,$2000,$0003,$8100
	dc.w	$800C,$0001,$0000,$0100,$4000,$001C,$0000,$0000
	dc.w	$0008,$1000,$000C,$0100,$8003,$0000,$8000,$021F
	dc.w	$FFFF,$FFFF,$FE00,$0000,$0008,$0800,$0030,$0100
	dc.w	$8000,$E000,$4000,$07E0,$10FF,$07FC,$01FE,$0000
	dc.w	$0010,$0400,$00C0,$0100,$8000,$1800,$4000,$7800
	dc.w	$3F00,$3803,$E001,$F800,$0010,$0200,$0700,$0100
	dc.w	$8000,$0600,$2001,$9003,$C801,$C000,$1F00,$0780
	dc.w	$0010,$0100,$1800,$0100,$8000,$0180,$1006,$103C
	dc.w	$041E,$0000,$00F0,$0078,$0020,$0080,$6000,$0100
	dc.w	$8000,$0070,$0804,$21C0,$04E0,$0000,$000F,$0007
	dc.w	$0020,$0043,$8000,$0100,$8000,$000C,$0404,$4E00
	dc.w	$0700,$0000,$0000,$E000,$E020,$002C,$0000,$0100
	dc.w	$8000,$0003,$0204,$B000,$3900,$0000,$0000,$1C00
	dc.w	$1840,$0030,$0000,$0100,$8000,$0000,$C105,$C001
	dc.w	$C100,$0000,$0000,$0380,$0740,$00D0,$0000,$0100
	dc.w	$FFFF,$FC00,$3886,$000E,$0080,$0000,$0000,$0060
	dc.w	$00C0,$0708,$0000,$0100,$F000,$03FF,$FFFF,$FFFF
	dc.w	$F080,$0000,$0000,$0010,$00B0,$1804,$0000,$0100
	dc.w	$8F00,$0000,$01EC,$0780,$0FFF,$FFFF,$FFFF,$C008
	dc.w	$008C,$6002,$0000,$0100,$80E0,$0000,$00F4,$3800
	dc.w	$0020,$0000,$0000,$3FFF,$FFFF,$FFFF,$0000,$0100
	dc.w	$801C,$0000,$032D,$C000,$0020,$1FFF,$FC00,$0004
	dc.w	$010D,$8000,$FFFF,$FF00,$8003,$C000,$044F,$0000
	dc.w	$0017,$E000,$03F0,$0004,$0130,$4000,$4000,$0100
	dc.w	$8000,$3800,$18F6,$C000,$0078,$0000,$000F,$0002
	dc.w	$01C0,$3000,$2000,$0100,$8000,$0700,$2385,$3800
	dc.w	$0788,$0000,$0007,$FF82,$0700,$0800,$2000,$0100
	dc.w	$8000,$00E0,$5E02,$8600,$1804,$0000,$0008,$0C7C
	dc.w	$1A00,$0400,$1000,$0100,$8000,$001F,$E402,$8180
	dc.w	$E002,$0000,$0010,$0387,$E200,$0200,$0800,$0100
	dc.w	$8000,$7FFF,$C801,$4073,$0002,$0000,$0010,$007B
	dc.w	$F400,$0100,$0400,$0100,$8003,$8077,$B801,$200C
	dc.w	$0001,$0000,$0010,$3FFC,$0E00,$0080,$0200,$0100
	dc.w	$800C,$0384,$7780,$9013,$0000,$8000,$0017,$C034
	dc.w	$0580,$0040,$0100,$0100,$8010,$1C08,$4C70,$4860
	dc.w	$C000,$8001,$FFF8,$01C3,$0860,$0020,$0080,$0100
	dc.w	$8020,$E008,$820E,$4480,$3800,$47FF,$C010,$0600
	dc.w	$8810,$0020,$0040,$0100,$8047,$0011,$0101,$E300
	dc.w	$0600,$7BC0,$3C08,$1800,$480C,$0010,$0020,$0100
	dc.w	$80F8,$0021,$0080,$3F00,$0183,$AC00,$0384,$6000
	dc.w	$3002,$0008,$0010,$0100,$8380,$0022,$0080,$0F80
	dc.w	$006C,$1000,$0063,$8000,$1001,$8008,$0010,$0100
	dc.w	$9D00,$0044,$0040,$0C70,$001C,$2800,$001D,$0000
	dc.w	$1800,$6004,$0008,$0100,$E200,$0048,$0040,$0B2F
	dc.w	$0063,$4800,$003C,$8000,$2800,$1004,$0004,$0100
	dc.w	$8200,$0050,$0040,$10D0,$E080,$C400,$01C2,$6000
	dc.w	$2400,$1004,$0002,$0100,$8400,$00A0,$0020,$1038
	dc.w	$1D01,$3A00,$0601,$1800,$2400,$0802,$0001,$0100
	dc.w	$8400,$00C0,$0020,$200C,$0382,$0600,$1801,$0600
	dc.w	$4200,$0802,$0000,$8100,$8400,$0080,$0020,$2003
	dc.w	$027A,$0180,$6000,$8180,$4200,$0802,$0000,$4100
	dc.w	$8400,$0180,$0020,$2001,$8207,$00E3,$8000,$8070
	dc.w	$4200,$0802,$0000,$2100,$8400,$0280,$0020,$2000
	dc.w	$8208,$E09C,$0000,$800E,$8200,$0802,$0000,$1100
	dc.w	$8400,$0480,$0040,$2001,$8210,$1E73,$0000,$8001
	dc.w	$8200,$0802,$0000,$1100,$8400,$0880,$0040,$2001
	dc.w	$4220,$01C0,$C000,$8000,$C200,$0802,$0000,$0900
	dc.w	$8200,$1080,$0040,$2002,$2140,$0638,$3001,$0000
	dc.w	$B200,$0802,$0000,$0500,$8200,$2080,$0080,$100C
	dc.w	$1140,$1817,$0E01,$0001,$0C00,$1002,$0000,$0300
	dc.w	$8100,$4040,$0080,$1030,$08C0,$6010,$F182,$0001
	dc.w	$0600,$6004,$0000,$0700,$8080,$8040,$0080,$08C0
	dc.w	$0463,$8008,$0E6C,$0001,$0900,$8004,$0000,$7900
	dc.w	$8081,$0040,$0100,$0F00,$023C,$0004,$01DC,$0002
	dc.w	$08C0,$8004,$0007,$8100,$8062,$0020,$0100,$3C00
	dc.w	$013C,$0004,$007F,$0002,$1041,$0008,$0078,$0100
	dc.w	$801C,$0020,$0603,$C200,$01C7,$8002,$0383,$C002
	dc.w	$2042,$0008,$0780,$0100,$800B,$0010,$39FC,$0100
	dc.w	$0640,$F801,$3C00,$7004,$4042,$0010,$F800,$0100
	dc.w	$8010,$FFFF,$FE00,$0080,$1820,$3FFF,$C000,$0E04
	dc.w	$8044,$002F,$0000,$0100,$8010,$000E,$0000,$0060
	dc.w	$6010,$03C0,$8000,$01E7,$0084,$00F0,$0000,$0100
	dc.w	$8020,$003C,$0000,$0013,$8008,$003C,$4000,$007C
	dc.w	$0082,$0F40,$0000,$0100,$8040,$00C2,$0000,$000C
	dc.w	$0004,$0003,$C000,$001B,$8101,$F080,$0000,$0100
	dc.w	$8080,$0301,$0000,$0033,$0002,$0000,$3E00,$006F
	dc.w	$7E1F,$7D00,$0000,$0100,$8100,$0C00,$8000,$01C0
	dc.w	$E001,$0000,$11FC,$0390,$DFE0,$03F8,$0000,$0100
	dc.w	$8200,$7000,$4000,$0600,$1801,$0000,$1003,$FFFF
	dc.w	$FEE0,$0407,$E000,$0100,$8401,$8000,$2000,$1800
	dc.w	$0780,$8000,$0800,$F011,$EE1C,$0800,$1FE0,$0100
	dc.w	$8806,$0000,$1800,$E000,$0078,$4000,$040F,$003E
	dc.w	$0183,$F000,$001F,$FF00,$9018,$0000,$0403,$0003
	dc.w	$FFFF,$FC00,$07F0,$03E0,$0060,$7800,$0000,$0100
	dc.w	$A020,$0000,$030C,$000C,$0000,$1FFF,$FE00,$3C20
	dc.w	$0019,$8700,$0000,$0100,$FFF0,$0000,$00B0,$0010
	dc.w	$0000,$08C0,$0103,$C040,$0007,$00F0,$0000,$0100
	dc.w	$804F,$FFFF,$01E0,$0010,$0000,$0420,$013C,$0040
	dc.w	$000C,$C00E,$0000,$0100,$8040,$0000,$FFFF,$F010
	dc.w	$0000,$0210,$03C0,$0040,$0030,$3001,$C000,$0100
	dc.w	$8020,$0000,$1806,$0FFF,$FF00,$0108,$3C40,$0080
	dc.w	$00C0,$0E00,$3800,$0100,$8020,$0000,$E001,$C020
	dc.w	$00FF,$FFF7,$C040,$0080,$0700,$0180,$0780,$0100
	dc.w	$8018,$0003,$0000,$3040,$0000,$007F,$FFFF,$8080
	dc.w	$1800,$0060,$0070,$0100,$8006,$000C,$0000,$0E40
	dc.w	$0000,$07A1,$0020,$7FFF,$F800,$0018,$000E,$0100
	dc.w	$8001,$E030,$0000,$01C0,$0000,$7810,$8010,$0107
	dc.w	$07FF,$FF87,$0001,$E100,$8000,$1DC0,$0000,$00BC
	dc.w	$0007,$8008,$4008,$0178,$0000,$007F,$FFF8,$1D00
	dc.w	$8000,$0700,$0000,$0103,$C0F8,$0004,$2008,$0780
	dc.w	$0000,$0000,$3007,$FF00,$8000,$18C0,$0000,$0200
	dc.w	$3F00,$0002,$1805,$FA00,$0000,$0000,$0C00,$0100
	dc.w	$8000,$E03E,$0000,$0C00,$F0FF,$0002,$05FE,$0200
	dc.w	$01F8,$0000,$0380,$0100,$8003,$0001,$F800,$100F
	dc.w	$0000,$FFFF,$FF02,$0403,$FE07,$0000,$0060,$0100
	dc.w	$800C,$0000,$0780,$20F0,$0000,$0000,$80F9,$041C
	dc.w	$0001,$8000,$0018,$0100,$8030,$0000,$007F,$DF00
	dc.w	$0000,$0000,$4007,$FFE0,$0000,$6000,$0007,$0100
	dc.w	$81C0,$0000,$0001,$E000,$0000,$0000,$2000,$8800
	dc.w	$0000,$3000,$0000,$C100,$8600,$0000,$001E,$0000
	dc.w	$0000,$0000,$1000,$4800,$0000,$0800,$0000,$3100
	dc.w	$9800,$0000,$01E0,$0000,$0000,$0000,$0800,$2800
	dc.w	$0000,$0C00,$0000,$0D00,$E000,$0000,$1E00,$0000
	dc.w	$0000,$0000,$0400,$3000,$0000,$0400,$0000,$0300
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FF00


; end of PowerWindows source generation
