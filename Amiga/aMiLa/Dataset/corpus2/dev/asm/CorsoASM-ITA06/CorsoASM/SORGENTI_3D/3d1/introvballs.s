
*   to edit text on screen, simply go to the bottom of the file!

	
	SECTION	DEM1,CODE_C

	movem.l d0-d7/a0-a6,-(a7)
	bsr init
mouse:
	move.l $dff004,d0
	and.l #$0001ff00,d0
	cmp.l #$00012000,d0
	bne mouse
	btst #6,$bfe001
	beq end
;	move.w #$00a0,$dff180
	bsr wave
	bsr vectorbobs
;	move.w #$0a00,$dff180
	bra mouse

end:
	move.w #$7fff,$dff09a
	move.l old2,$6c
	move.w old1,$dff09a
	move.w #$040f,$dff096
	move.l 4,a0
	move.l 156(a0),a1
	move.l 38(a1),$dff080
	movem.l (a7)+,d0-d7/a0-a6
	rts

**********************************************

init:
	move.w #$8420,$dff096
	move.w $dff01c,old1
	add.w #$8000,old1
	move.l $6c,old2
	move.w #$7fff,$dff09a
	move.l #int1,$6c
	move.l #$fe00ff00,$7fff8
	move.l #0,$7fffc
	lea $60000,a0
	lea $80000,a1
	bsr clear
	bsr sprite
	move.l #copper,$dff080
	bsr bpinit
	bsr rfhonda
	move.w #$c020,$dff09a
	rts

clear:
	clr.l (a0)+
	cmp.l a0,a1
	bne clear
	rts

sprite:
	lea copper,a1
	lea sp1,a0
	bsr sprite2
	lea sp2,a0
	bsr sprite2
	lea sp3,a0
	bsr sprite2
	lea sp4,a0

sprite2:
	move.l a0,d0
	move.w d0,6(a1)
	swap d0
	move.w d0,2(a1)
	addq.l #8,a1
	rts

old1: dc.w 0
old2: dc.l 0

****************************************

int1:
	movem.l d0-d7/a0-a6,-(a7)
	bsr writing
	bsr scols
	add.w #dxangle,xangle
	add.w #dyangle,yangle
	add.w #dzangle,zangle
	bsr bpmusic
	movem.l (a7)+,d0-d7/a0-a6
	move.w #$0020,$dff09c
	rte

****************************************

ke: dc.w 4
scols:
	subq.w #1,ke
	beq rg
	rts
rg:
	move.w #4,ke
	move.l cad,a0
	lea scol,a1
	bsr spr1
	bsr spr1
	bsr spr1
	bsr spr1
	bsr spr1
	bsr spr1
	bsr spr1
	bsr spr1
	move.l cad,a0
	addq.l #4,a0
	cmp.l #cend,a0
	blt spr3
	sub.l #cend-cstart,a0
spr3:
	move.l a0,cad
	rts

spr1:
	cmp.l #cend,a0
	blt spr2
	sub.l #cend-cstart,a0
spr2:
	move.w (a0),2(a1)
	addq.l #4,a1
	add.l #8,a0
	rts

cad:	dc.l cstart
cstart:

	dc.w	$028f,$048f,$068f,$088f,$0a8f,$0c8f,$0e8f,$0f8f
	dc.w	$0f6f,$0f4f,$0f2f,$0f0f,$0f0e,$0f0c,$0f0a,$0f08
	dc.w	$0f06,$0f04,$0f02
	dc.w	$0f00,$0f10,$0f20,$0f30,$0f40,$0f50,$0f60,$0f70
	dc.w	$0f80,$0f90,$0fa0,$0fb0,$0fc0,$0fd0,$0fe0,$0ff0
	dc.w	$0ef0,$0df0,$0cf0,$0bf0,$0af0,$09f0,$08f0,$07f0
	dc.w	$06f0,$05f0,$04f0,$03f0,$02f0,$01f0,$00f0,$00f1
	dc.w	$00f2,$00f3,$00f4,$00f5,$00f6,$00f7,$00f8,$00f9
	dc.w	$00fa,$00fb,$00fc,$00fd,$00fe,$00ff,$00ef,$00df
	dc.w	$00cf,$00bf,$00af,$009f,$008f,$007f,$006f,$005f
	dc.w	$004f,$003f,$002f,$001f,$000f,$000f,$000f,$000f
	dc.w	$000f,$000f,$011f,$012f,$013f,$014f,$015f,$016f
	dc.w	$017f,$018f

cend:

dxangle=-5
dyangle=-10
dzangle=0

wave:
	move.l pointlist,a1
	move.w nopoints,d7
	move.l code1,a0
poo1:
	clr.l d1
	move.w (a1)+,d1
	addq.l #2,a1
	add.w #200,d1
	lsl.w #1,d1
	move.w (a0,d1.w),d0
	sub.w #$38,d0
	move.w d0,(a1)+
	dbf d7,poo1

	add.l #8,code1
	move.l code1,a0
	cmp.l #coend,a0
	blt fast
	sub.l #coend-codes,a0
	move.l a0,code1
fast:
	rts

code1: dc.l codes
codes:

 dc.w	$0038,$0039,$003a,$003b,$003c,$003d,$003e,$003f
 dc.w	$0040,$0041,$0042,$0043,$0044,$0045,$0046,$0046
 dc.w	$0047,$0048,$0049,$004a,$004b,$004c,$004d,$004e
 dc.w	$004f,$0050,$0051,$0051,$0052,$0053,$0054,$0055
 dc.w	$0056,$0056,$0057,$0058,$0059,$005a,$005a,$005b
 dc.w	$005c,$005d,$005d,$005e,$005f,$0060,$0060,$0061
 dc.w	$0062,$0062,$0063,$0064,$0064,$0065,$0065,$0066
 dc.w	$0066,$0067,$0067,$0068,$0068,$0069,$0069,$006a
 dc.w	$006a,$006b,$006b,$006c,$006c,$006c,$006d,$006d
 dc.w	$006d,$006e,$006e,$006e,$006e,$006f,$006f,$006f
 dc.w	$006f,$006f,$006f,$0070,$0070,$0070,$0070,$0070
 dc.w	$0070,$0070,$0070,$0070,$0070,$0070,$0070,$0070
 dc.w	$0070,$0070,$006f,$006f,$006f,$006f,$006f,$006f
 dc.w	$006e,$006e,$006e,$006e,$006d,$006d,$006d,$006c
 dc.w	$006c,$006c,$006b,$006b,$006a,$006a,$0069,$0069
 dc.w	$0068,$0068,$0067,$0067,$0066,$0066,$0065,$0065
 dc.w	$0064,$0064,$0063,$0062,$0062,$0061,$0060,$0060
 dc.w	$005f,$005e,$005d,$005d,$005c,$005b,$005a,$005a
 dc.w	$0059,$0058,$0057,$0056,$0056,$0055,$0054,$0053
 dc.w	$0052,$0051,$0051,$0050,$004f,$004e,$004d,$004c
 dc.w	$004b,$004a,$0049,$0048,$0047,$0046,$0046,$0045
 dc.w	$0044,$0043,$0042,$0041,$0040,$003f,$003e,$003d
 dc.w	$003c,$003b,$003a,$0039,$0038,$0037,$0036,$0035
 dc.w	$0034,$0033,$0032,$0031,$0030,$002f,$002e,$002d
 dc.w	$002c,$002b,$002a,$002a,$0029,$0028,$0027,$0026
 dc.w	$0025,$0024,$0023,$0022,$0021,$0020,$001f,$001f
 dc.w	$001e,$001d,$001c,$001b,$001a,$001a,$0019,$0018
 dc.w	$0017,$0016,$0016,$0015,$0014,$0013,$0013,$0012
 dc.w	$0011,$0010,$0010,$000f,$000e,$000e,$000d,$000c
 dc.w	$000c,$000b,$000b,$000a,$000a,$0009,$0009,$0008
 dc.w	$0008,$0007,$0007,$0006,$0006,$0005,$0005,$0004
 dc.w	$0004,$0004,$0003,$0003,$0003,$0002,$0002,$0002
 dc.w	$0002,$0001,$0001,$0001,$0001,$0001,$0001,$0000
 dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
 dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0001,$0001
 dc.w	$0001,$0001,$0001,$0001,$0002,$0002,$0002,$0002
 dc.w	$0003,$0003,$0003,$0004,$0004,$0004,$0005,$0005
 dc.w	$0006,$0006,$0007,$0007,$0008,$0008,$0009,$0009
 dc.w	$000a,$000a,$000b,$000b,$000c,$000c,$000d,$000e
 dc.w	$000e,$000f,$0010,$0010,$0011,$0012,$0013,$0013
 dc.w	$0014,$0015,$0016,$0016,$0017,$0018,$0019,$0019
 dc.w	$001a,$001b,$001c,$001d,$001e,$001f,$001f,$0020
 dc.w	$0021,$0022,$0023,$0024,$0025,$0026,$0027,$0028
 dc.w	$0029,$002a,$002a,$002b,$002c,$002d,$002e,$002f
 dc.w	$0030,$0031,$0032,$0033,$0034,$0035,$0036,$0037

coend:

 dc.w	$0038,$0039,$003a,$003b,$003c,$003d,$003e,$003f
 dc.w	$0040,$0041,$0042,$0043,$0044,$0045,$0046,$0046
 dc.w	$0047,$0048,$0049,$004a,$004b,$004c,$004d,$004e
 dc.w	$004f,$0050,$0051,$0051,$0052,$0053,$0054,$0055
 dc.w	$0056,$0056,$0057,$0058,$0059,$005a,$005a,$005b
 dc.w	$005c,$005d,$005d,$005e,$005f,$0060,$0060,$0061
 dc.w	$0062,$0062,$0063,$0064,$0064,$0065,$0065,$0066
 dc.w	$0066,$0067,$0067,$0068,$0068,$0069,$0069,$006a
 dc.w	$006a,$006b,$006b,$006c,$006c,$006c,$006d,$006d
 dc.w	$006d,$006e,$006e,$006e,$006e,$006f,$006f,$006f
 dc.w	$006f,$006f,$006f,$0070,$0070,$0070,$0070,$0070
 dc.w	$0070,$0070,$0070,$0070,$0070,$0070,$0070,$0070
 dc.w	$0070,$0070,$006f,$006f,$006f,$006f,$006f,$006f
 dc.w	$006e,$006e,$006e,$006e,$006d,$006d,$006d,$006c
 dc.w	$006c,$006c,$006b,$006b,$006a,$006a,$0069,$0069
 dc.w	$0068,$0068,$0067,$0067,$0066,$0066,$0065,$0065
 dc.w	$0064,$0064,$0063,$0062,$0062,$0061,$0060,$0060
 dc.w	$005f,$005e,$005d,$005d,$005c,$005b,$005a,$005a
 dc.w	$0059,$0058,$0057,$0056,$0056,$0055,$0054,$0053
 dc.w	$0052,$0051,$0051,$0050,$004f,$004e,$004d,$004c
 dc.w	$004b,$004a,$0049,$0048,$0047,$0046,$0046,$0045
 dc.w	$0044,$0043,$0042,$0041,$0040,$003f,$003e,$003d
 dc.w	$003c,$003b,$003a,$0039,$0038,$0037,$0036,$0035
 dc.w	$0034,$0033,$0032,$0031,$0030,$002f,$002e,$002d
 dc.w	$002c,$002b,$002a,$002a,$0029,$0028,$0027,$0026
 dc.w	$0025,$0024,$0023,$0022,$0021,$0020,$001f,$001f
 dc.w	$001e,$001d,$001c,$001b,$001a,$001a,$0019,$0018
 dc.w	$0017,$0016,$0016,$0015,$0014,$0013,$0013,$0012
 dc.w	$0011,$0010,$0010,$000f,$000e,$000e,$000d,$000c
 dc.w	$000c,$000b,$000b,$000a,$000a,$0009,$0009,$0008
 dc.w	$0008,$0007,$0007,$0006,$0006,$0005,$0005,$0004
 dc.w	$0004,$0004,$0003,$0003,$0003,$0002,$0002,$0002
 dc.w	$0002,$0001,$0001,$0001,$0001,$0001,$0001,$0000
 dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
 dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0001,$0001
 dc.w	$0001,$0001,$0001,$0001,$0002,$0002,$0002,$0002
 dc.w	$0003,$0003,$0003,$0004,$0004,$0004,$0005,$0005
 dc.w	$0006,$0006,$0007,$0007,$0008,$0008,$0009,$0009
 dc.w	$000a,$000a,$000b,$000b,$000c,$000c,$000d,$000e
 dc.w	$000e,$000f,$0010,$0010,$0011,$0012,$0013,$0013
 dc.w	$0014,$0015,$0016,$0016,$0017,$0018,$0019,$0019
 dc.w	$001a,$001b,$001c,$001d,$001e,$001f,$001f,$0020
 dc.w	$0021,$0022,$0023,$0024,$0025,$0026,$0027,$0028
 dc.w	$0029,$002a,$002a,$002b,$002c,$002d,$002e,$002f
 dc.w	$0030,$0031,$0032,$0033,$0034,$0035,$0036,$0037

 dc.w	$0038,$0039,$003a,$003b,$003c,$003d,$003e,$003f
 dc.w	$0040,$0041,$0042,$0043,$0044,$0045,$0046,$0046
 dc.w	$0047,$0048,$0049,$004a,$004b,$004c,$004d,$004e
 dc.w	$004f,$0050,$0051,$0051,$0052,$0053,$0054,$0055
 dc.w	$0056,$0056,$0057,$0058,$0059,$005a,$005a,$005b
 dc.w	$005c,$005d,$005d,$005e,$005f,$0060,$0060,$0061
 dc.w	$0062,$0062,$0063,$0064,$0064,$0065,$0065,$0066
 dc.w	$0066,$0067,$0067,$0068,$0068,$0069,$0069,$006a
 dc.w	$006a,$006b,$006b,$006c,$006c,$006c,$006d,$006d
 dc.w	$006d,$006e,$006e,$006e,$006e,$006f,$006f,$006f
 dc.w	$006f,$006f,$006f,$0070,$0070,$0070,$0070,$0070
 dc.w	$0070,$0070,$0070,$0070,$0070,$0070,$0070,$0070
 dc.w	$0070,$0070,$006f,$006f,$006f,$006f,$006f,$006f
 dc.w	$006e,$006e,$006e,$006e,$006d,$006d,$006d,$006c
 dc.w	$006c,$006c,$006b,$006b,$006a,$006a,$0069,$0069
 dc.w	$0068,$0068,$0067,$0067,$0066,$0066,$0065,$0065
 dc.w	$0064,$0064,$0063,$0062,$0062,$0061,$0060,$0060
 dc.w	$005f,$005e,$005d,$005d,$005c,$005b,$005a,$005a
 dc.w	$0059,$0058,$0057,$0056,$0056,$0055,$0054,$0053
 dc.w	$0052,$0051,$0051,$0050,$004f,$004e,$004d,$004c
 dc.w	$004b,$004a,$0049,$0048,$0047,$0046,$0046,$0045
 dc.w	$0044,$0043,$0042,$0041,$0040,$003f,$003e,$003d
 dc.w	$003c,$003b,$003a,$0039,$0038,$0037,$0036,$0035
 dc.w	$0034,$0033,$0032,$0031,$0030,$002f,$002e,$002d
 dc.w	$002c,$002b,$002a,$002a,$0029,$0028,$0027,$0026
 dc.w	$0025,$0024,$0023,$0022,$0021,$0020,$001f,$001f
 dc.w	$001e,$001d,$001c,$001b,$001a,$001a,$0019,$0018
 dc.w	$0017,$0016,$0016,$0015,$0014,$0013,$0013,$0012
 dc.w	$0011,$0010,$0010,$000f,$000e,$000e,$000d,$000c
 dc.w	$000c,$000b,$000b,$000a,$000a,$0009,$0009,$0008
 dc.w	$0008,$0007,$0007,$0006,$0006,$0005,$0005,$0004
 dc.w	$0004,$0004,$0003,$0003,$0003,$0002,$0002,$0002
 dc.w	$0002,$0001,$0001,$0001,$0001,$0001,$0001,$0000
 dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
 dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0001,$0001
 dc.w	$0001,$0001,$0001,$0001,$0002,$0002,$0002,$0002
 dc.w	$0003,$0003,$0003,$0004,$0004,$0004,$0005,$0005
 dc.w	$0006,$0006,$0007,$0007,$0008,$0008,$0009,$0009
 dc.w	$000a,$000a,$000b,$000b,$000c,$000c,$000d,$000e
 dc.w	$000e,$000f,$0010,$0010,$0011,$0012,$0013,$0013
 dc.w	$0014,$0015,$0016,$0016,$0017,$0018,$0019,$0019
 dc.w	$001a,$001b,$001c,$001d,$001e,$001f,$001f,$0020
 dc.w	$0021,$0022,$0023,$0024,$0025,$0026,$0027,$0028
 dc.w	$0029,$002a,$002a,$002b,$002c,$002d,$002e,$002f
 dc.w	$0030,$0031,$0032,$0033,$0034,$0035,$0036,$0037

********************************************

scr1=$60000
scr2=$62800
scr3=$65000
e6: dc.w 1
mintime=300
maxtime=600
e9: dc.w 4

writing:
	tst.w e6
	beq dof
	subq.w #1,e6
	cmp.w #2,e6
	beq cbpl1
	cmp.w #1,e6
	beq cbpl2
	bsr colours
	rts

cbpl1:
	bsr blitwait
	move.l #$01000000,$dff040
	move.l #scr1,$dff054
	move.w #0,$dff066
	move.w #[maxy*$40]+[res/2],$dff058
	rts

cbpl2:
	bsr blitwait
	move.l #$01000000,$dff040
	move.l #scr2,$dff054
	move.w #0,$dff066
	move.w #[maxy*$40]+[res/2],$dff058
	rts

temp1: dc.l scr1+[6*42]

dof:
	move.l text1,a0
	move.l temp1,a3
	lea $2800(a3),a4
tif:
	move.w #9,d7
te1:
	clr.w d0
	move.b (a0)+,d0
	cmp.b #'o',d0
	bne half
	move.b (a0)+,d0
	cmp.b #'0',d0
	beq tend
	cmp.b #'1',d0
	beq tnew
	cmp.b #'2',d0
	beq teq
	move.w #$0fff,$dff180	;error in opcodes
	rts

tend:
	lea text,a0
	bra t1
teq:
	move.w #maxtime,e6
	bra t1
tnew:
	move.w #mintime,e6
t1:
	move.l a0,text1
	move.l #scr1+[6*42],temp1
	rts

half:
	lea font1,a1
	lea $500(a1),a2
	sub.b #$20,d0
	lsl.w #4,d0
	add.w d0,a1
	add.w d0,a2
	bsr dochar
	addq.l #1,a3
	addq.l #1,a4
	dbf d7,te1
	subq.w #1,e9
	bne rabbi
	add.l #674,a3
	move.w #4,e9
rabbi:
	move.l a3,temp1
	move.l a0,text1
	rts

*************************************

dochar:
	move.b (a1)+,(a3)
	move.b (a1)+,42(a3)
	move.b (a1)+,84(a3)
	move.b (a1)+,126(a3)
	move.b (a1)+,168(a3)
	move.b (a1)+,210(a3)
	move.b (a1)+,252(a3)
	move.b (a1)+,294(a3)
	move.b (a1)+,336(a3)
	move.b (a1)+,378(a3)
	move.b (a1)+,420(a3)
	move.b (a1)+,462(a3)
	move.b (a1)+,504(a3)
	move.b (a1)+,546(a3)
	move.b (a1)+,588(a3)
	move.b (a1)+,630(a3)

	move.b (a2)+,(a4)
	move.b (a2)+,42(a4)
	move.b (a2)+,84(a4)
	move.b (a2)+,126(a4)
	move.b (a2)+,168(a4)
	move.b (a2)+,210(a4)
	move.b (a2)+,252(a4)
	move.b (a2)+,294(a4)
	move.b (a2)+,336(a4)
	move.b (a2)+,378(a4)
	move.b (a2)+,420(a4)
	move.b (a2)+,462(a4)
	move.b (a2)+,504(a4)
	move.b (a2)+,546(a4)
	move.b (a2)+,588(a4)
	move.b (a2)+,630(a4)
	rts

blitwait:
	btst #14,$dff002
	bne blitwait
	rts

text1: dc.l text

***************************************

colours:
	cmp.w #16,e6
	blt sa1
	lea colup,a1
	bra bbr
sa1:
	lea coldown,a1
bbr:
	lea cols,a0
	move.w #15,d7
sd1:
	move.w 2(a0),d0
	move.w (a1)+,d1
	bsr shades
	move.w d2,2(a0)
	addq.l #4,a0
	dbf d7,sd1
	rts

colup:
 dc.l	$000006f6,$04d402a2,$066f06f6,$04d402a2
 dc.l	$044c06f6,$04d402a2,$022906f6,$04d402a2
coldown:
 dc.l	$00000000,$00000000,$066f066f,$066f066f
 dc.l	$044c044c,$044c044c,$02290229,$02290229

********************************

*     Colour Shader by Jarre 1990
*     d0=source colour   d1=dest colour
*     d2=final colour

shades:
	move.w d0,d2
	move.w d1,d3
	and.w #$0f00,d2
	and.w #$0f00,d3
	cmp.w d2,d3
	beq note1
	bgt up1
	sub.w #$0100,d2
	bra note1
up1:
	add.w #$0100,d2
note1:
	move.w d0,d3
	move.w d1,d4
	and.w #$00f0,d3
	and.w #$00f0,d4
	cmp.w d3,d4
	beq note2
	bgt up2
	sub.w #$0010,d3
	bra note2
up2:
	add.w #$0010,d3
note2:
	or.w d3,d2
	move.w d0,d3
	move.w d1,d4
	and.w #$000f,d3
	and.w #$000f,d4
	cmp.w d3,d4
	beq note3
	bgt up3
	sub.w #$0001,d3
	bra note3
up3:
	add.w #$0001,d3
note3:
	or.w d3,d2
	rts

*********************************************

screen1: dc.l $70000
screen2: dc.l $72800
screen3: dc.l $77800
screen4: dc.l $7a000
res=42
minx=0
miny=0
maxx=320
maxy=232

dist:	dc.w 500
xorg:	dc.w 150
yorg:	dc.w 100
nopoints: dc.w 0
nopoints1: dc.w 70
nopoints2: dc.w 70
pointlist: dc.l 0
spoint: dc.l slist
slist:

 dc.l	angels
 dc.l	defjam
 dc.l	0

angels:

 dc.w	70
 dc.w	-120,20,0,-110,20,0,-100,20,0,-90,20,0
 dc.w	-120,10,0,-120,0,0,-120,-10,0,-120,-20,0
 dc.w	-110,0,0,-100,0,0,-90,10,0,-90,0,0,-90,-10,0,-90,-20,0

 dc.w	-75,20,0,-65,20,0,-55,20,0,-75,10,0,-75,0,0,-75,-10,0,-75,-20,0
 dc.w	-45,10,0,-45,0,0,-45,-10,0,-45,-20,0

 dc.w	0,20,0,-10,20,0,-20,20,0,-30,10,0,-30,0,0,-30,-10,0
 dc.w	-20,-20,0,-10,-20,0,0,-20,0,0,-10,0,0,0,0,-10,0,0

 dc.w	45,20,0,35,20,0,25,20,0,15,10,0,15,0,0,15,-10,0,25,-20,0
 dc.w	35,-20,0,45,-20,0,25,0,0,35,0,0

 dc.w	60,20,0,60,10,0,60,0,0,60,-10,0,60,-20,0,70,-20,0
 dc.w	80,-20,0,90,-20,0

 dc.w	135,20,0,125,20,0,115,20,0,105,20,0,105,10,0,105,0,0
 dc.w	115,0,0,125,0,0,135,0,0,135,-10,0,135,-20,0
 dc.w	125,-20,0,115,-20,0,105,-20,0

defjam:

 dc.w	67
 dc.w	-105,20,0,-105,10,0,-105,0,0,-105,-10,0,-105,-20,0
 dc.w	-95,20,0,-85,20,0,-75,10,0,-75,0,0,-75,-10,0
 dc.w	-85,-20,0,-95,-20,0

 dc.w	-40,20,0,-50,20,0,-60,10,0,-60,0,0,-60,-10,0,-50,-20,0
 dc.w	-40,-20,0,-50,0,0,-40,0,0

 dc.w	-25,20,0,-15,20,0,-5,20,0,-25,10,0,-25,0,0,-25,-10,0
 dc.w	-25,-20,0,-15,0,0

 dc.w	10,20,0,20,20,0,30,20,0,20,10,0,20,0,0,20,-10,0
 dc.w	20,-20,0,10,-20,0,0,-20,0

 dc.w	45,20,0,55,20,0,65,20,0,75,20,0,45,10,0,45,0,0
 dc.w	45,-10,0,45,-20,0,55,0,0,65,0,0
 dc.w	75,0,0,75,10,0,75,-10,0,75,-20,0

 dc.w	90,20,0,90,10,0,90,0,0,90,-10,0,90,-20,0,100,20,0,110,20,0
 dc.w	110,10,0,110,0,0,120,20,0,130,20,0,130,10,0,130,0,0
 dc.w	130,-10,0,130,-20,0

vectorbobs:
	bsr newshape
	bsr pageswitch
	bsr rotate
	bsr bobs
	rts

*****************************************

ele:	dc.w 400
newshape:
	move.w nopoints1,nopoints2
	move.w nopoints1,d0
	cmp.w ele,d0
	blt rimm
	subq.w #1,nopoints1
	bra ramm
rimm:
	move.w nopoints,d0
	cmp.w nopoints1,d0
	beq ramm
	addq.w #1,nopoints1
ramm:
	subq.w #1,ele
	tst.w ele
	beq rfhonda
	rts
rfhonda:
	move.w #400,ele
	move.l spoint,a0
	tst.l (a0)
	bne rrap
	move.l #slist,spoint
	bra rfhonda
rrap:
	move.l (a0),a0
	move.w (a0)+,d0
	subq.w #1,d0
	move.w d0,nopoints
	move.l a0,pointlist
	addq.l #4,spoint
	move.w #0,nopoints1
	rts

*****************************************

pageswitch:
	move.l screen1,d0
	move.l screen2,d1
	move.l screen3,screen1
	move.l screen4,screen2
	move.l d0,screen3
	move.l d1,screen4
	move.l cl1,d2
	move.l cl2,cl1
	move.l d2,cl2
	add.l #$2a2,d0
	add.l #$2a2,d1
	lea bpl,a0
	move.w d0,6(a0)
	move.w d1,14(a0)
	rts

*********************************

rotate:
	move.w #3600,d3
	move.w zangle,d0
	bpl z1ok
	add.w d3,d0
z1ok:
	cmp.w d3,d0
	bmi zok
	sub.w d3,d0
zok:
	move.w d0,zangle
	move.w yangle,d0
	bpl y1ok
	add.w d3,d0
y1ok:
	cmp.w d3,d0
	bmi yok
	sub.w d3,d0
yok:
	move.w d0,yangle
	move.w xangle,d0
	bpl x1ok
	add.w d3,d0
x1ok:
	cmp.w d3,d0
	bmi xok
	sub.w d3,d0
xok:
	move.w d0,xangle

	lea xangle,a0
	lea sincos,a1
	lea 1800(a1),a2
	lea mulint,a4

	movem.w (a0),d1-d3
	add.w d1,d1
	add.w d2,d2
	add.w d3,d3
	move.w (a1,d1.w),d5
	move.w (a1,d2.w),d6
	move.w (a1,d3.w),d7
	move.w (a2,d1.w),d1
	move.w (a2,d2.w),d2
	move.w (a2,d3.w),d3
	move.w d1,d4
	muls d2,d4
	move.w d4,(a4)
	move.w d5,d4
	muls d2,d4
	neg.l d4
	move.w d4,2(a4)
	move.w d6,d4
	asl.w #7,d4
	move.w d4,4(a4)
	move.w d5,d4
	muls d3,d4
	move.w d1,d0
	muls d6,d0
	muls d7,d0
	asr.l #7,d0
	add.w d0,d4
	move.w d4,6(a4)
	move.w d1,d0
	muls d3,d0
	move.w d0,d4
	move.w d5,d0
	muls d6,d0
	muls d7,d0
	asr.l #7,d0
	sub.w d0,d4
	move.w d4,8(a4)
	move.w d2,d0
	muls d7,d0
	neg.l d0
	move.w d0,10(a4)
	move.w d5,d0
	muls d7,d0
	move.w d0,d4
	move.w d1,d0
	muls d6,d0
	muls d3,d0
	asr.l #7,d0
	sub.w d0,d4
	move.w d4,12(a4)
	move.w d1,d0
	muls d7,d0
	move.w d0,d4
	move.w d5,d0
	muls d6,d0
	muls d3,d0
	asr.l #7,d0
	add.w d0,d4
	move.w d4,14(a4)
	move.w d2,d0
	muls d3,d0
	move.w d0,16(a4)

	lea finalz,a1
	move.w dist,a2
	move.l pointlist,a3
	lea xycord,a5
	move.w nopoints1,d7
	tst.w d7
	bne rp
	rts
rp:
	movem.w (a3)+,d4-d6
	move.w d4,d0
	muls (a4),d0
	move.w d6,d1
	muls 2(a4),d1
	move.w d5,d2
	muls 4(a4),d2
	add.l d1,d0
	add.l d2,d0
	asr.l #5,d0
	move.w d4,d1
	muls 6(a4),d1
	move.w d6,d2
	muls 8(a4),d2
	move.w d5,d3
	muls 10(a4),d3
	add.l d2,d1
	add.l d3,d1
	asr.l #5,d1
	muls 12(a4),d4
	muls 14(a4),d6
	add.l d6,d4
	muls 16(a4),d5
	add.l d5,d4
	lsl.l #2,d4
	swap d4
	move.w d4,(a1)+
	add.w a2,d4
	divs d4,d0
	divs d4,d1
	add.w xorg,d0
	add.w yorg,d1
	move.w d0,(a5)+
	move.w d1,(a5)+
	dbf d7,rp
	rts

*******************************************

bobs:
	move.l cl1,a0
	move.w nopoints,d7
	bsr blitwait
	move.l #$01000000,$dff040
	move.w #$0026,$dff066
b1:
	bsr blitwait
	move.l (a0)+,d0
	move.l d0,$dff054
	move.w #$0402,$dff058
	add.l #$2800,d0
	bsr blitwait
	move.l d0,$dff054
	move.w #$0402,$dff058
	dbf d7,b1

	move.w #$0020,$dff09a
	bsr blitwait
	lea $dff000,a6
	move.l #$ffff0000,$44(a6)
	move.w #-2,$62(a6)
	move.w #-2,$64(a6)
	move.w #$26,$60(a6)
	move.w #$26,$66(a6)

	lea xycord,a0
	move.l cl1,a1
	lea finalz,a2
	move.l screen1,a3
	lea blankbob,a4
	move.w nopoints1,d7
	tst.w d7
	bne lp1
	rts
lp1:
	clr.l d0
	clr.l d1
	movem.w (a0)+,d0/d1
	cmp.w #minx,d0
	ble ede
	cmp.w #maxx,d0
	bge ede
	cmp.w #miny,d1
	ble ede
	cmp.w #maxy,d1
	bge ede
	move.w d0,d3
	and.w #$0f,d3
	ror.w #4,d3
	move.w d3,$42(a6)
	or.w #$0fca,d3
	move.w d3,$40(a6)
	lsr.w #3,d0
	mulu #res,d1
	add.l d1,d0
	add.l a3,d0
	move.l d0,(a1)+

	clr.l d1
	move.w (a2),d1
	add.w #$a0,d1
	lsr.w #7,d1
	eor.w #3,d1
	lsl.w #5,d1
	move.l a4,a5
	add.l d1,a5
	add.l #bob1,d1
	move.l d0,$54(a6)
	move.l d0,$48(a6)
	move.l a5,$4c(a6)
	move.l d1,$50(a6)
	move.w #$0402,$58(a6)
	add.l #$2800,d0
	add.l #bob2-bob1,d1
	bsr blitwait
	move.l d0,$54(a6)
	move.l d0,$48(a6)
	move.l a5,$4c(a6)
	move.l d1,$50(a6)
	move.w #$0402,$58(a6)
ede:
	addq.l #2,a2
	dbf d7,lp1
	move.w #$c020,$dff09a
	rts

maxpoints=100
xangle:	dc.w 0
yangle:	dc.w 0
zangle:	dc.w $2f8
ax: dc.w 0
ay: dc.w 0
az: dc.w 4
mulint: blk.w 18,0
cl1: dc.l cls1
cl2: dc.l cls2
cls1: blk.l maxpoints,$70000
cls2: blk.l maxpoints,$70000
xycord:	blk.l maxpoints,0
finalz:	blk.w maxpoints,0

;************** brian postma replay routine

bpinit:		lea	samples(pc),a0
		lea	bpsong,a1
		clr.b	numtables
		cmp	#'v.',26(a1)
		bne.s	bpnotv2
		cmp.b	#'2',28(a1)
		bne.s	bpnotv2
		move.b	29(a1),numtables
bpnotv2:	move.l	#512,d0
		move	30(a1),d1
		moveq	#1,d2
		mulu	#4,d1
		subq	#1,d1
findhighest:	cmp	(a1,d0.w),d2
		bge.s	nothigher
		move	(a1,d0.w),d2
nothigher:	addq.l	#4,d0
		dbf	d1,findhighest
		move	30(a1),d1
		mulu	#16,d1
		move.l	#512,d0
		mulu	#48,d2
		add.l	d2,d0
		add.l	d1,d0
		add.l	#bpsong,d0
		move.l	d0,tables
		moveq	#0,d1
		move.b	numtables,d1
		lsl.l	#6,d1
		add.l	d1,d0
		move.l	#14,d1
		add.l	#32,a1
initloop:	move.l	d0,(a0)+
		cmp.b	#$ff,(a1)
		beq.s	bpissynth
		move	24(a1),d2
		mulu	#2,d2
		add.l	d2,d0
bpissynth:	add.l	#32,a1
		dbf	d1,initloop
		rts

bpmusic:	bsr.w	bpsynth
		subq.b	#1,arpcount
		moveq	#3,d0
		lea	bpcurrent(pc),a0
		move.l	#$dff0a0,a1
bploop1:	move.b	12(a0),d4
		ext	d4
		add	d4,(a0)
		tst.b	$1e(a0)
		bne.s	bplfo
		move	(a0),6(a1)
bplfo:		move.l	4(a0),(a1)
		move.w	8(a0),4(a1)
		tst.b	11(a0)
		bne.s	bpdoarp
		tst.b	13(a0)
		beq.s	not2
bpdoarp:	tst.b	arpcount
		bne.s	not0
		move.b	11(a0),d3
		move.b	13(a0),d4
		and	#240,d4
		and	#240,d3
		lsr	#4,d3
		lsr	#4,d4
		add	d3,d4
		add.b	10(a0),d4
		bsr.w	bpplayarp
		bra.s	not2
not0:		cmp.b	#1,arpcount 
		bne.s	not1
		move.b	11(a0),d3
		move.b	13(a0),d4
		and	#15,d3
		and	#15,d4
		add	d3,d4
		add.b	10(a0),d4
		bsr.w	bpplayarp
		bra.s	not2
not1:		move.b	10(a0),d4
		bsr.w	bpplayarp
not2:		lea	$10(a1),a1
		lea	$20(a0),a0
		dbf	d0,bploop1
		tst.b	arpcount
		bne.s	arpnotzero
		move.b	#3,arpcount
arpnotzero:	subq.b	#1,bpcount
		beq.s	bpskip1
		rts
bpskip1:	move.b	bpdelay,bpcount
bpplay:		bsr.s	bpnext
		move	dma,$dff096
		moveq	#3,d0
		move.l	#$dff0a0,a1
		moveq	#1,d1
		lea	bpcurrent(pc),a2
		lea	bpbuffer(pc),a5
bploop2:	btst	#15,(a2)
		beq.s	bpskip7
		bsr.w	bpplayit
bpskip7:	asl	#1,d1
		lea	$10(a1),a1
		lea	$20(a2),a2
		lea	$24(a5),a5
		dbf	d0,bploop2
		rts
bpnext:		clr	dma
		lea	bpsong,a0
		move.l	#$dff0a0,a3
		moveq	#3,d0
		moveq	#1,d7
		lea	bpcurrent(pc),a1
bploop3:	moveq	#0,d1
		move	bpstep,d1
		lsl	#4,d1
		move.l	d0,d2
		lsl.l	#2,d2
		add.l	d2,d1
		add.l	#512,d1
		move	(a0,d1.w),d2
		move.b	2(a0,d1.w),st
		move.b	3(a0,d1.w),tr
		subq	#1,d2
		mulu	#48,d2
		moveq	#0,d3
		move	30(a0),d3
		lsl	#4,d3
		add.l	d2,d3
		move.l	#$00000200,d4
		move.b	bppatcount,d4
		add.l	d3,d4
		move.l	d4,a2
		add.l	a0,a2
		moveq	#0,d3
		move.b	(a2),d3
		tst.b	d3
		bne.s	bpskip4
		bra.w	bpoptionals
bpskip4:	clr	12(a1)
		move.b	1(a2),d4
		and.b	#15,d4
		cmp.b	#10,d4
		bne.s	bp_do1
		move.b	2(a2),d4
		and.b	#240,d4
		bne.s	bp_not1
bp_do1:		add.b	tr,d3
		ext	d3
bp_not1:	move.b	d3,10(a1)
		lea	bpper(pc),a4
		lsl	#1,d3
		move	-2(a4,d3.w),(a1)
		bset	#15,(a1)
		move.b	#$ff,2(a1)
		moveq	#0,d3
		move.b	1(a2),d3
		lsr.b	#4,d3
		and.b	#15,d3
		tst.b	d3
		bne.s	bpskip5
		move.b	3(a1),d3
bpskip5: 	move.b	1(a2),d4
		and.b	#15,d4
		cmp.b	#10,d4
		bne.s	bp_do2
		move.b	2(a2),d4
		and.b	#15,d4
		bne.s	bp_not2
bp_do2:		add.b	st,d3
bp_not2:	cmp	#1,8(a1)
		beq.s	bpsamplechange
		cmp.b	3(a1),d3
		beq.s	bpoptionals
bpsamplechange:	move.b	d3,3(a1)
		or	d7,dma
bpoptionals: 	moveq	#0,d3
		moveq	#0,d4
		move.b	1(a2),d3
		and.b	#15,d3
		move.b	2(a2),d4
		cmp.b	#0,d3
		bne.s	notopt0
		move.b	d4,11(a1)
notopt0:	cmp.b	#1,d3
		bne.s	bpskip3
		move	d4,8(a3)
		move.b	d4,2(a1)
bpskip3:	cmp.b	#2,d3
		bne.s	bpskip9
		move.b	d4,bpcount
		move.b	d4,bpdelay
bpskip9:	cmpi.b	#3,d3
		bne.s	bpskipa
		tst.b	d4
		bne.s	bpskipb
		bset	#1,$bfe001
		bra.s	bpskip2
bpskipb:	bclr	#1,$bfe001
bpskipa:	cmp.b	#4,d3
		bne.s	noportup
		sub	d4,(a1)
		clr.b	11(a1)
noportup:	cmp.b	#5,d3
		bne.s	noportdn
		add	d4,(a1)
		clr.b	11(a1)
noportdn:	cmp.b	#6,d3
		bne.s	notopt6
		move.b	d4,bprepcount
notopt6:	cmp.b	#7,d3
		bne.s	notopt7
		subq.b	#1,bprepcount
		beq.s	notopt7
		move	d4,bpstep
notopt7:	cmp.b	#8,d3
		bne.s	notopt8
		move.b	d4,12(a1)
notopt8:	cmp.b	#9,d3
		bne.s	notopt9
		move.b	d4,13(a1)
notopt9:
bpskip2:	lea	$10(a3),a3
		lea	$20(a1),a1
		asl	#1,d7
		dbf	d0,bploop3
		addq.b	#3,bppatcount
		cmpi.b	#48,bppatcount
		bne.s	bpskip8
		move.b	#0,bppatcount
		addq	#1,bpstep
		lea	bpsong,a0
		move	30(a0),d1
		cmp	bpstep,d1
		bne.s	bpskip8
		move	#0,bpstep
bpskip8:	rts
bpplayit:	bclr	#15,(a2)
		tst.l	(a5)
		beq.s	noeg1
		moveq	#0,d3
		move.l	(a5),a4
		moveq	#7,d7
eg1loop:	move.l	4(a5,d3.w),(a4)+
		addq	#4,d3
		dbf	d7,eg1loop
noeg1:		move	(a2),6(a1)
		move.l	#0,d7
		move.b	3(a2),d7
		move.l	d7,d6
		lsl.l	#5,d7
		lea	bpsong,a3
		cmp.b	#$ff,(a3,d7.w)
		beq.s	bpplaysynthetic
		clr.l	(a5)
		clr.b	$1a(a2)
		clr	$1e(a2)
		add.l	#24,d7
		lsl.l	#2,d6
		move.l	#samples,a4
		move.l	-4(a4,d6),d4
		beq.s	bp_nosamp
		move.l	d4,(a1)
		move	(a3,d7),4(a1)
		move.b	2(a2),9(a1)
		cmpi.b	#$ff,2(a2)
		bne.s	skipxx
		move	6(a3,d7),8(a1)
skipxx: 	move	4(a3,d7),8(a2)
		moveq	#0,d6
		move	2(a3,d7),d6
		add.l	d6,d4
		move.l	d4,4(a2)
		cmp	#1,8(a2)
		bne.s	bpskip6
bp_nosamp:	move.l	#null,4(a2)
		bra.s	bpskip10
bpskip6:	move	8(a2),4(a1)
		move.l	4(a2),(a1)
bpskip10:	or	#$8000,d1
		move	d1,$dff096
		rts
bpplaysynthetic:move.b	#$1,$1a(a2)
		clr	$e(a2)
		clr	$10(a2)
		clr	$12(a2)
		move	22(a3,d7.w),$14(a2)
		addq	#1,$14(a2)
		move	14(a3,d7.w),$16(a2)
		addq	#1,$16(a2)
		move	#1,$18(a2)
		move.b	17(a3,d7.w),$1d(a2)
		move.b	9(a3,d7.w),$1e(a2)
		move.b	4(a3,d7.w),$1f(a2)
		move.b	19(a3,d7.w),$1c(a2)
		move.l	tables,a4
		moveq	#0,d3
		move.b	1(a3,d7.w),d3
		lsl.l	#6,d3
		add.l	d3,a4
		move.l	a4,(a1)
		move.l	a4,4(a2)
		move	2(a3,d7.w),4(a1)
		move	2(a3,d7.w),8(a2)
		tst.b	4(a3,d7.w)
		beq.s	bpadsroff
		move.l	tables,a4
		move.l	#0,d3
		move.b	5(a3,d7.w),d3
		lsl.l	#6,d3
		add.l	d3,a4
		moveq	#0,d3
		move.b	(a4),d3
		add.b	#128,d3
		lsr	#2,d3
		cmp.b	#$ff,2(a2)
		bne.s	bpskip99
		move.b	25(a3,d7.w),2(a2)
bpskip99:	moveq	#0,d4
		move.b	2(a2),d4
		mulu	d4,d3
		lsr	#6,d3
		move	d3,8(a1)
		bra.s	bpflipper
bpadsroff:	move.b	2(a2),9(a1)
		cmp.b	#$ff,2(a2)
		bne.s	bpflipper
		move.b	25(a3,d7.w),9(a1)
bpflipper:	move.l	4(a2),a4
		move.l	a4,(a5)
		moveq	#0,d3
		moveq	#7,d4
eg2loop:	move.l	(a4,d3.w),4(a5,d3.w)
		addq	#4,d3
		dbf	d4,eg2loop
		tst.b	17(a3,d7.w)
		beq.w	bpskip10
		tst.b	19(a3,d7.w)
		beq.w	bpskip10
		moveq	#0,d3
		move.b	19(a3,d7.w),d3
		lsr.l	#3,d3
		move.b	d3,$1c(a2)
		subq.l	#1,d3
eg3loop:	neg.b	(a4)+
		dbf	d3,eg3loop
		bra.w	bpskip10
bpplayarp:	lea	bpper(pc),a4
		ext	d4
		asl	#1,d4
		move	-2(a4,d4.w),6(a1)
		rts
bpsynth:	move.l	#3,d0
		lea	bpcurrent(pc),a2
		lea	$dff0a0,a1
		lea	bpsong,a3
		lea	bpbuffer(pc),a5
bpsynthloop:	tst.b	$1a(a2)
		beq.s	bpnosynth
		bsr.s	bpyessynth
bpnosynth:	lea	$24(a5),a5
		lea	$20(a2),a2
		lea	$10(a1),a1
		dbf	d0,bpsynthloop
		rts
bpyessynth:	moveq	#0,d7
		move.b	3(a2),d7
		lsl	#5,d7
		tst.b	$1f(a2)
		beq.s	bpendadsr
		subq	#1,$18(a2)
		bne.s	bpendadsr
		moveq	#0,d3
		move.b	8(a3,d7.w),d3
		move	d3,$18(a2)
		move.l	tables,a4
		move.b	5(a3,d7.w),d3
		lsl.l	#6,d3
		add.l	d3,a4
		move	$12(a2),d3
		moveq	#0,d4
		move.b	(a4,d3.w),d4
		add.b	#128,d4
		lsr	#2,d4
		moveq	#0,d3
		move.b	2(a2),d3
		mulu	d3,d4
		lsr	#6,d4
		move	d4,8(a1)
		addq	#1,$12(a2)
		move	6(a3,d7.w),d4
		cmp	$12(a2),d4
		bne.s	bpendadsr
		clr	$12(a2)
		cmp.b	#1,$1f(a2)
		bne.s	bpendadsr
		clr.b	$1f(a2)
bpendadsr:	tst.b	$1e(a2)
		beq.s	bpendlfo
		subq	#1,$16(a2)
		bne.s	bpendlfo
		moveq	#0,d3
		move.b	16(a3,d7.w),d3
		move	d3,$16(a2)
		move.l	tables,a4
		move.b	10(a3,d7.w),d3
		lsl.l	#6,d3
		add.l	d3,a4
		move	$10(a2),d3
		moveq	#0,d4
		move.b	(a4,d3.w),d4
		ext	d4
		ext.l	d4
		moveq	#0,d5
		move.b	11(a3,d7.w),d5
		tst.b	d5
		beq.s	bpnotx
		divs	d5,d4
bpnotx:		move	(a2),d5
		add	d4,d5
		move	d5,6(a1)
		addq	#1,$10(a2)
		move	12(a3,d7.w),d3
		cmp	$10(a2),d3
		bne.s	bpendlfo
		clr	$10(a2)
		cmp.b	#1,$1e(a2)
		bne.s	bpendlfo
		clr.b	$1e(a2)
bpendlfo:	tst.b	$1d(a2)
		beq.w	bpendeg
		subq	#1,$14(a2)
		bne.w	bpendeg
		tst.l	(a5)
		beq.w	bpendeg
		move.l	#0,d3
		move.b	24(a3,d7.w),d3
		move	d3,$14(a2)
		move.l	tables,a4
		move.b	18(a3,d7.w),d3
		lsl.l	#6,d3
		add.l	d3,a4
		move	$e(a2),d3
		moveq	#0,d4
		move.b	(a4,d3.w),d4
		move.l	(a5),a4
		add.b	#128,d4
		lsr.l	#3,d4
		moveq	#0,d3
		move.b	$1c(a2),d3
		move.b	d4,$1c(a2)
		add.l	d3,a4
		move.l	a5,a6
		add.l	d3,a6
		addq.l	#4,a6
		cmp.b	d3,d4
		beq.s	bpnexteg
		bgt.s	bpishigh
bpislow:	sub.l	d4,d3
		subq.l	#1,d3
bpegloop1a:	move.b	-(a6),d4
		move.b	d4,-(a4)
		dbf	d3,bpegloop1a
		bra.s	bpnexteg
bpishigh:	sub.l	d3,d4
		subq.l	#1,d4
bpegloop1b:	move.b	(a6)+,d3
		neg.b	d3
		move.b	d3,(a4)+
		dbf	d4,bpegloop1b
bpnexteg:	addq	#1,$e(a2)
		move	20(a3,d7.w),d3
		cmp	$e(a2),d3
		bne.s	bpendeg
		clr	$e(a2)
		cmp.b	#1,$1d(a2)
		bne.s	bpendeg
		clr.b	$1d(a2)
bpendeg:	rts

;************** donnees music

null:		dc.w	0
bpcurrent:	dc.w	0,0
		dc.l	null
		dc.w	1
		dc.b	0,0,0,0
		dc.w	0,0,0
		dc.w	0,0,0
		dc.b	0,0
		dc.b	0,0
		dc.b	0,0
		dc.w	0,0
		dc.l	null
		dc.w	1,0,0
		dc.w	0,0,0,0,0,0,0,0,0
		dc.w	0,0
		dc.l	null
		dc.w	1,0,0
		dc.w	0,0,0,0,0,0,0,0,0
		dc.w	0,0
		dc.l	null
		dc.w	1,0,0
		dc.w	0,0,0,0,0,0,0,0,0
bpstep:		dc.w	0
bppatcount:	dc.b	0
st:		dc.b	0
tr:		dc.b	0
bpcount:	dc.b	1
bpdelay:	dc.b	6
arpcount:	dc.b	1
bprepcount:	dc.b	1
numtables:	dc.b	0
		even
dma:		dc.w	0
tables:		dc.l	0
bpbuffer:	blk.b	144,0
		dc.w	6848,6464,6080,5760,5440,5120,4832,4576,4320,4064,3840,3616
		dc.w	3424,3232,3040,2880,2720,2560,2416,2288,2160,2032,1920,1808
		dc.w	1712,1616,1520,1440,1360,1280,1208,1144,1080,1016,0960,0904
bpper:		dc.w	0856,0808,0760,0720,0680,0640,0604,0572,0540,0508,0480,0452
		dc.w	0428,0404,0380,0360,0340,0320,0302,0286,0270,0254,0240,0226
		dc.w	0214,0202,0190,0180,0170,0160,0151,0143,0135,0127,0120,0113
		dc.w	0107,0101,0095,0090,0085,0080,0076,0072,0068,0064,0060,0057
samples:	blk.l	15,0

**********************************************************************

sp1:
 dc.l	$f6d0fd80
 dc.w	$3c07,$01f7,$0404,$0114,$0404,$0114,$0407,$01f7
 dc.w	$0404,$0114,$8404,$0114,$fc04,$0114
sp2:
 dc.l	$f6d0fd80
 dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
 dc.w	$0000,$0000,$0000,$0000,$0000,$0000
sp3:
 dc.l	$f6d8fd80
 dc.w	$9e00,$803c,$5100,$4040,$5100,$4040,$9e00,$807c
 dc.w	$5100,$4040,$5100,$4040,$5100,$403c
sp4:
 dc.l	$f6d8fd80
 dc.w	$1e3c,$0000,$1140,$0000,$1140,$0000,$1e7c,$0000
 dc.w	$1140,$0000,$1140,$0000,$113c,$0000

**********************************************************************

copper:
 dc.l	$01200007,$0122fff8,$01240007,$0126fff8,$01280007,$012afff8
 dc.l	$012c0007,$012efff8,$01300007,$0132fff8,$01340007,$0136fff8
 dc.l	$01380007,$013afff8,$013c0007,$013efff8
 dc.l	$01020000,$01080002,$010a0002
 dc.l	$008e2581,$00903fc1,$00920038,$009400d0
 dc.l	$00e00006,$00e20000,$00e40006,$00e62800
bpl:
 dc.l	$00e80007,$00ea0000,$00ec0007,$00ee2000
cols:
 dc.l	$01800000,$01820000,$01840000,$01860000
 dc.l	$0188066f,$018a066f,$018c066f,$018e066f
 dc.l	$0190044c,$0192044c,$0194044c,$0196044c
 dc.l	$0198022a,$019a022a,$019c022a,$019e022a
scol:
 dc.l	$01a00fff,$01a20eee,$01a40ddd,$01a60ccc
 dc.l	$01a80bbb,$01aa0000,$01ac0000,$01ae0000
 dc.l	$2611fffe,$0180066f
 dc.l	$2711fffe,$0180044d
 dc.l	$280bfffe,$01004200,$01800000
 dc.l	$fd11fffe,$01000200,$0180066f
 dc.l	$fe11fffe,$0180044d
 dc.l	$ff11fffe,$01800000
 dc.w	$1fc,0
 dc.l	$fffffffe
 dc.l	$fffffffe

***************************************

text:

;    opcodes (special instructions) inside text:

;    first of all,  small o for opcode
;    0 after o  =  end of list
;    1 after o  =  short wait at end of page
;    2 after o  =  long wait at end of page

*   remeber -   only 12 lines per page

 dc.b	"       ANGELS & DEFJAM PRESENTS:        "
 dc.b	"                                        "
 dc.b	"                                        "
 dc.b	"          (CRACK NAME HERE!!)           "
 dc.b	"                                        "
 dc.b	"                                        "
 dc.b	"      CRACKED BY (CRACKERS NAME!)       "
 dc.b	"                                        "
 dc.b	"     ORIGINAL BY (SUPPLIERS NAME!!)     "
 dc.b	"                                        "
 dc.b	"         INTRO CODED BY JARRE           o2"

 dc.b	"           CALL AN ANGELS BBS :         "
 dc.b	"                                        "
 dc.b	"    AMIGA EAST      -  804 499 2266     "
 dc.b	"    WRECK HOUSE     -  201 751 2175     "
 dc.b	"    BLACK PLAGUE    -  201 946 2764     "
 dc.b	"    ESCAPE ZONE     -  704 254 6448     "
 dc.b	"    REIGN IN BLOOD  -  +49 203 406 0981 "
 dc.b	"    DULCET TONES    -  +44 382 739 192  "
 dc.b	"    SOFTWARE HOUSE  -  +45 867 750 750  "
 dc.b	"    DUTCH PIRATE    -  +31 117 200 16   o2"

 dc.b	"           CALL A DEFJAM BBS :          "
 dc.b	"                                        "
 dc.b	"     PLEASURE POINT -  415 649 8588     "
 dc.b	"     MOTHERBOARD    -  516 783 1450     "
 dc.b	"     EAST BBS       -  +46 313 118 79   "
 dc.b	"     WEST BBS       -  +46 894 0614     o2o1o0"

even

bob1:

		dc.w	0,0,0,$1C0,$7F0,$7F0,$FF8,$FF8
		dc.w	$FE8,$7C0,$790,$1C0,0,0,0,0
		dc.w	0,0,$3E0,$7F0,$FF8,$1FFC,$1FFC,$1FFC
		dc.w	$1FF4,$1FE4,$FC8,$790,$3E0,0,0,0
		dc.w	0,$3E0,$FF8,$1FFC,$1FFC,$3FFE,$3FFE,$3FFE
		dc.w	$3FFA,$3FFA,$1FF0,$1FE4,$F88,$3E0,0,0
		dc.w	$3E0,$FF8,$1FFC,$3FFE,$3FFE,$7FFF,$7FFF,$7FFF
		dc.w	$7FFD,$7FFD,$3FF8,$3FF2,$1FE4,$F88,$3E0,0
bob2:
		dc.w	0,0,0,$1C0,$430,$F0,$9F8,$BF8
		dc.w	$BF8,$7F0,$7F0,$1C0,0,0,0,0
		dc.w	0,0,$3E0,$430,$8F8,$11FC,$13FC,$17FC
		dc.w	$17FC,$1FFC,$FF8,$7F0,$3E0,0,0,0
		dc.w	0,$3E0,$838,$11FC,$3FC,$27FE,$2FFE,$2FFE
		dc.w	$2FFE,$3FFE,$1FFC,$1FFC,$FF8,$3E0,0,0
		dc.w	$3E0,$838,$10FC,$23FE,$7FE,$4FFF,$4FFF,$5FFF
		dc.w	$5FFF,$7FFF,$3FFE,$3FFE,$1FFC,$FF8,$3E0,0

blankbob:
		dc.w	0,0,0,$1C0,$7F0,$7F0,$FF8,$FF8
		dc.w	$FF8,$7F0,$7F0,$1C0,0,0,0,0
		dc.w	0,0,$3E0,$7F0,$FF8,$1FFC,$1FFC,$1FFC
		dc.w	$1FFC,$1FFC,$FF8,$7F0,$3E0,0,0,0
		dc.w	0,$3E0,$FF8,$1FFC,$1FFC,$3FFE,$3FFE,$3FFE
		dc.w	$3FFE,$3FFE,$1FFC,$1FFC,$FF8,$3E0,0,0
		dc.w	$3E0,$FF8,$1FFC,$3FFE,$3FFE,$7FFF,$7FFF,$7FFF
		dc.w	$7FFF,$7FFF,$3FFE,$3FFE,$1FFC,$FF8,$3E0,0


sincos:
 dc.w 0,0,0,0,0,1,1,1,1,2,2,2,2,2,3,$3,3,3,4,4,4,4,4,$5,5,5,5,6,6,6,6,$6
 dc.w 7,7,7,7,8,8,8,$8,8,9,9,9,9,$A,$A,$A,$A,$A,$B,$B,$B,$B,$C,$C
 dc.w $C,$C,$C,$D,$D,$D,$D,$E,$E,$E,$E,$E,$F,$F,$F,$F
 dc.w $10,$10,$10,$10,$10,$11,$11,$11,$11,$12,$12,$12,$12,$12,$13,$13
 dc.w $13,$13,$14,$14,$14,$14,$14,$15,$15,$15,$15,$16,$16,$16,$16,$16
 dc.w $17,$17,$17,$17,$17,$18,$18,$18,$18,$19,$19,$19,$19,$19,$1A,$1A
 dc.w $1A,$1A,$1B,$1B,$1B,$1B,$1B,$1C,$1C,$1C,$1C,$1D,$1D,$1D,$1D,$1D
 dc.w $1E,$1E,$1E,$1E,$1E,$1F,$1F,$1F,$1F,$20,$20,$20,$20,$20,$21,$21
 dc.w $21,$21,$21,$22,$22,$22,$22,$23,$23,$23,$23,$23,$24,$24,$24,$24
 dc.w $24,$25,$25,$25,$25,$26,$26,$26,$26,$26,$27,$27,$27,$27,$27,$28
 dc.w $28,$28,$28,$29,$29,$29,$29,$29,$2A,$2A,$2A,$2A,$2A,$2B,$2B,$2B
 dc.w $2B,$2B,$2C,$2C,$2C,$2C,$2D,$2D,$2D,$2D,$2D,$2E,$2E,$2E,$2E,$2E
 dc.w $2F,$2F,$2F,$2F,$2F,$30,$30,$30,$30,$30,$31,$31,$31,$31,$32,$32
 dc.w $32,$32,$32,$33,$33,$33,$33,$33,$34,$34,$34,$34,$34,$35,$35,$35
 dc.w $35,$35,$36,$36,$36,$36,$36,$37,$37,$37,$37,$37,$38,$38,$38,$38
 dc.w $38,$39,$39,$39,$39,$39,$3A,$3A,$3A,$3A,$3A,$3B,$3B,$3B,$3B,$3B
 dc.w $3C,$3C,$3C,$3C,$3C,$3D,$3D,$3D,$3D,$3D,$3E,$3E,$3E,$3E,$3E,$3F
 dc.w $3F,$3F,$3F,$3F,$40,$40,$40,$40,$40,$40,$41,$41,$41,$41,$41,$42
 dc.w $42,$42,$42,$42,$43,$43,$43,$43,$43,$44,$44,$44,$44,$44,$44,$45
 dc.w $45,$45,$45,$45,$46,$46,$46,$46,$46,$47,$47,$47,$47,$47,$47,$48
 dc.w $48,$48,$48,$48,$49,$49,$49,$49,$49,$49,$4A,$4A,$4A,$4A,$4A,$4B
 dc.w $4B,$4B,$4B,$4B,$4B,$4C,$4C,$4C,$4C,$4C,$4D,$4D,$4D,$4D,$4D,$4D
 dc.w $4E,$4E,$4E,$4E,$4E,$4E,$4F,$4F,$4F,$4F,$4F,$50,$50,$50,$50,$50
 dc.w $50,$51,$51,$51,$51,$51,$51,$52,$52,$52,$52,$52,$52,$53,$53,$53
 dc.w $53,$53,$53,$54,$54,$54,$54,$54,$54,$55,$55,$55,$55,$55,$55,$56
 dc.w $56,$56,$56,$56,$56,$57,$57,$57,$57,$57,$57,$58,$58,$58,$58,$58
 dc.w $58,$59,$59,$59,$59,$59,$59,$5A,$5A,$5A,$5A,$5A,$5A,$5A,$5B,$5B
 dc.w $5B,$5B,$5B,$5B,$5C,$5C,$5C,$5C,$5C,$5C,$5D,$5D,$5D,$5D,$5D,$5D
 dc.w $5D,$5E,$5E,$5E,$5E,$5E,$5E,$5E,$5F,$5F,$5F,$5F,$5F,$5F,$60,$60
 dc.w $60,$60,$60,$60,$60,$61,$61,$61,$61,$61,$61,$61,$62,$62,$62,$62
 dc.w $62,$62,$62,$63,$63,$63,$63,$63,$63,$63,$64,$64,$64,$64,$64,$64
 dc.w $64,$65,$65,$65,$65,$65,$65,$65,$65,$66,$66,$66,$66,$66,$66,$66
 dc.w $67,$67,$67,$67,$67,$67,$67,$67,$68,$68,$68,$68,$68,$68,$68,$68
 dc.w $69,$69,$69,$69,$69,$69,$69,$69,$6A,$6A,$6A,$6A,$6A,$6A,$6A,$6A
 dc.w $6B,$6B,$6B,$6B,$6B,$6B,$6B,$6B,$6C,$6C,$6C,$6C,$6C,$6C,$6C,$6C
 dc.w $6D,$6D,$6D,$6D,$6D,$6D,$6D,$6D,$6D,$6E,$6E,$6E,$6E,$6E,$6E,$6E
 dc.w $6E,$6E,$6F,$6F,$6F,$6F,$6F,$6F,$6F,$6F,$6F,$70,$70,$70,$70,$70
 dc.w $70,$70,$70,$70,$71,$71,$71,$71,$71,$71,$71,$71,$71,$71,$72,$72
 dc.w $72,$72,$72,$72,$72,$72,$72,$72,$73,$73,$73,$73,$73,$73,$73,$73
 dc.w $73,$73,$74,$74,$74,$74,$74,$74,$74,$74,$74,$74,$74,$75,$75,$75
 dc.w $75,$75,$75,$75,$75,$75,$75,$75,$75,$76,$76,$76,$76,$76,$76,$76
 dc.w $76,$76,$76,$76,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77
 dc.w $77,$78,$78,$78,$78,$78,$78,$78,$78,$78,$78,$78,$78,$78,$79,$79
 dc.w $79,$79,$79,$79,$79,$79,$79,$79,$79,$79,$79,$79,$7A,$7A,$7A,$7A
 dc.w $7A,$7A,$7A,$7A,$7A,$7A,$7A,$7A,$7A,$7A,$7A,$7A,$7B,$7B,$7B,$7B
 dc.w $7B,$7B,$7B,$7B,$7B,$7B,$7B,$7B,$7B,$7B,$7B,$7B,$7B,$7C,$7C,$7C
 dc.w $7C,$7C,$7C,$7C,$7C,$7C,$7C,$7C,$7C,$7C,$7C,$7C,$7C,$7C,$7C,$7C
 dc.w $7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D
 dc.w $7D,$7D,$7D,$7D,$7D,$7D,$7D,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E
 dc.w $7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E
 dc.w $7E,$7E,$7E,$7E,$7E,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F
 dc.w $7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F
 dc.w $7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F
 dc.w $7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F
 dc.w $7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$80,$7F,$7F,$7F
 dc.w $7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F
 dc.w $7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F
 dc.w $7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F
 dc.w $7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F
 dc.w $7F,$7F,$7F,$7F,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E
 dc.w $7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E
 dc.w $7E,$7E,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D
 dc.w $7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7C,$7C,$7C,$7C,$7C,$7C,$7C
 dc.w $7C,$7C,$7C,$7C,$7C,$7C,$7C,$7C,$7C,$7C,$7C,$7C,$7B,$7B,$7B,$7B
 dc.w $7B,$7B,$7B,$7B,$7B,$7B,$7B,$7B,$7B,$7B,$7B,$7B,$7B,$7A,$7A,$7A
 dc.w $7A,$7A,$7A,$7A,$7A,$7A,$7A,$7A,$7A,$7A,$7A,$7A,$7A,$79,$79,$79
 dc.w $79,$79,$79,$79,$79,$79,$79,$79,$79,$79,$79,$78,$78,$78,$78,$78
 dc.w $78,$78,$78,$78,$78,$78,$78,$78,$77,$77,$77,$77,$77,$77,$77,$77
 dc.w $77,$77,$77,$77,$77,$76,$76,$76,$76,$76,$76,$76,$76,$76,$76,$76
 dc.w $75,$75,$75,$75,$75,$75,$75,$75,$75,$75,$75,$75,$74,$74,$74,$74
 dc.w $74,$74,$74,$74,$74,$74,$74,$73,$73,$73,$73,$73,$73,$73,$73,$73
 dc.w $73,$72,$72,$72,$72,$72,$72,$72,$72,$72,$72,$71,$71,$71,$71,$71
 dc.w $71,$71,$71,$71,$71,$70,$70,$70,$70,$70,$70,$70,$70,$70,$6F,$6F
 dc.w $6F,$6F,$6F,$6F,$6F,$6F,$6F,$6E,$6E,$6E,$6E,$6E,$6E,$6E,$6E,$6E
 dc.w $6D,$6D,$6D,$6D,$6D,$6D,$6D,$6D,$6D,$6C,$6C,$6C,$6C,$6C,$6C,$6C
 dc.w $6C,$6B,$6B,$6B,$6B,$6B,$6B,$6B,$6B,$6A,$6A,$6A,$6A,$6A,$6A,$6A
 dc.w $6A,$69,$69,$69,$69,$69,$69,$69,$69,$68,$68,$68,$68,$68,$68,$68
 dc.w $68,$67,$67,$67,$67,$67,$67,$67,$67,$66,$66,$66,$66,$66,$66,$66
 dc.w $65,$65,$65,$65,$65,$65,$65,$65,$64,$64,$64,$64,$64,$64,$64,$63
 dc.w $63,$63,$63,$63,$63,$63,$62,$62,$62,$62,$62,$62,$62,$61,$61,$61
 dc.w $61,$61,$61,$61,$60,$60,$60,$60,$60,$60,$60,$5F,$5F,$5F,$5F,$5F
 dc.w $5F,$5E,$5E,$5E,$5E,$5E,$5E,$5E,$5D,$5D,$5D,$5D,$5D,$5D,$5D,$5C
 dc.w $5C,$5C,$5C,$5C,$5C,$5B,$5B,$5B,$5B,$5B,$5B,$5A,$5A,$5A,$5A,$5A
 dc.w $5A,$5A,$59,$59,$59,$59,$59,$59,$58,$58,$58,$58,$58,$58,$57,$57
 dc.w $57,$57,$57,$57,$56,$56,$56,$56,$56,$56,$55,$55,$55,$55,$55,$55
 dc.w $54,$54,$54,$54,$54,$54,$53,$53,$53,$53,$53,$53,$52,$52,$52,$52
 dc.w $52,$52,$51,$51,$51,$51,$51,$51,$50,$50,$50,$50,$50,$50,$4F,$4F
 dc.w $4F,$4F,$4F,$4E,$4E,$4E,$4E,$4E,$4E,$4D,$4D,$4D,$4D,$4D,$4D,$4C
 dc.w $4C,$4C,$4C,$4C,$4B,$4B,$4B,$4B,$4B,$4B,$4A,$4A,$4A,$4A,$4A,$49
 dc.w $49,$49,$49,$49,$49,$48,$48,$48,$48,$48,$47,$47,$47,$47,$47,$47
 dc.w $46,$46,$46,$46,$46,$45,$45,$45,$45,$45,$44,$44,$44,$44,$44,$44
 dc.w $43,$43,$43,$43,$43,$42,$42,$42,$42,$42,$41,$41,$41,$41,$41,$40
 dc.w $40,$40,$40,$40,$40,$3F,$3F,$3F,$3F,$3F,$3E,$3E,$3E,$3E,$3E,$3D
 dc.w $3D,$3D,$3D,$3D,$3C,$3C,$3C,$3C,$3C,$3B,$3B,$3B,$3B,$3B,$3A,$3A
 dc.w $3A,$3A,$3A,$39,$39,$39,$39,$39,$38,$38,$38,$38,$38,$37,$37,$37
 dc.w $37,$37,$36,$36,$36,$36,$36,$35,$35,$35,$35,$35,$34,$34,$34,$34
 dc.w $34,$33,$33,$33,$33,$33,$32,$32,$32,$32,$32,$31,$31,$31,$31,$30
 dc.w $30,$30,$30,$30,$2F,$2F,$2F,$2F,$2F,$2E,$2E,$2E,$2E,$2E,$2D,$2D
 dc.w $2D,$2D,$2D,$2C,$2C,$2C,$2C,$2B,$2B,$2B,$2B,$2B,$2A,$2A,$2A,$2A
 dc.w $2A,$29,$29,$29,$29,$29,$28,$28,$28,$28,$27,$27,$27,$27,$27,$26
 dc.w $26,$26,$26,$26,$25,$25,$25,$25,$24,$24,$24,$24,$24,$23,$23,$23
 dc.w $23,$23,$22,$22,$22,$22,$21,$21,$21,$21,$21,$20,$20,$20,$20,$20
 dc.w $1F,$1F,$1F,$1F,$1E,$1E,$1E,$1E,$1E,$1D,$1D,$1D,$1D,$1D,$1C,$1C
 dc.w $1C,$1C,$1B,$1B,$1B,$1B,$1B,$1A,$1A,$1A,$1A,$19,$19,$19,$19,$19
 dc.w $18,$18,$18,$18,$17,$17,$17,$17,$17,$16,$16,$16,$16,$16,$15,$15
 dc.w $15,$15,$14,$14,$14,$14,$14,$13,$13,$13,$13,$12,$12,$12,$12,$12
 dc.w $11,$11,$11,$11,$10,$10,$10,$10,$10,$F,$F,$F,$F,$E,$E,$E
 dc.w $E,$E,$D,$D,$D,$D,$C,$C,$C,$C,$C,$B,$B,$B,$B,$A
 dc.w $A,$A,$A,$A,9,9,9,$9,8,8,8,8,8,7,7,$7,7,6,6,6,6,6,5,5
 dc.w 5,5,4,4,4,4,4,$3,3,3,3,2,2,2,2,2,1,1,1,1,0,0,0,0
 dc.w -1,-1,-1,-1,-1,-2,-2,-2
 dc.w -2,-3,-3,-3,-3,-3,-4,-4
 dc.w -4,-4,-5,-5,-5,-5,-5,-6
 dc.w -6,-6,-6,-7,-7,-7,-7,-7
 dc.w -8,-8,-8,-8,-9,-9,-9,-9
 dc.w -9,$FFF6,$FFF6,$FFF6,$FFF6,$FFF5,$FFF5,$FFF5
 dc.w $FFF5,$FFF5,$FFF4,$FFF4,$FFF4,$FFF4,$FFF3,$FFF3
 dc.w $FFF3,$FFF3,$FFF3,$FFF2,$FFF2,$FFF2,$FFF2,$FFF1
 dc.w $FFF1,$FFF1,$FFF1,$FFF1,$FFF0,$FFF0,$FFF0,$FFF0
 dc.w $FFEF,$FFEF,$FFEF,$FFEF,$FFEF,$FFEE,$FFEE,$FFEE
 dc.w $FFEE,$FFED,$FFED,$FFED,$FFED,$FFED,$FFEC,$FFEC
 dc.w $FFEC,$FFEC,$FFEB,$FFEB,$FFEB,$FFEB,$FFEB,$FFEA
 dc.w $FFEA,$FFEA,$FFEA,$FFE9,$FFE9,$FFE9,$FFE9,$FFE9
 dc.w $FFE8,$FFE8,$FFE8,$FFE8,$FFE8,$FFE7,$FFE7,$FFE7
 dc.w $FFE7,$FFE6,$FFE6,$FFE6,$FFE6,$FFE6,$FFE5,$FFE5
 dc.w $FFE5,$FFE5,$FFE4,$FFE4,$FFE4,$FFE4,$FFE4,$FFE3
 dc.w $FFE3,$FFE3,$FFE3,$FFE2,$FFE2,$FFE2,$FFE2,$FFE2
 dc.w $FFE1,$FFE1,$FFE1,$FFE1,$FFE1,$FFE0,$FFE0,$FFE0
 dc.w $FFE0,$FFDF,$FFDF,$FFDF,$FFDF,$FFDF,$FFDE,$FFDE
 dc.w $FFDE,$FFDE,$FFDE,$FFDD,$FFDD,$FFDD,$FFDD,$FFDC
 dc.w $FFDC,$FFDC,$FFDC,$FFDC,$FFDB,$FFDB,$FFDB,$FFDB
 dc.w $FFDA,$FFDA,$FFDA,$FFDA,$FFDA,$FFD9,$FFD9,$FFD9
 dc.w $FFD9,$FFD9,$FFD8,$FFD8,$FFD8,$FFD8,$FFD8,$FFD7
 dc.w $FFD7,$FFD7,$FFD7,$FFD6,$FFD6,$FFD6,$FFD6,$FFD6
 dc.w $FFD5,$FFD5,$FFD5,$FFD5,$FFD5,$FFD4,$FFD4,$FFD4
 dc.w $FFD4,$FFD4,$FFD3,$FFD3,$FFD3,$FFD3,$FFD2,$FFD2
 dc.w $FFD2,$FFD2,$FFD2,$FFD1,$FFD1,$FFD1,$FFD1,$FFD1
 dc.w $FFD0,$FFD0,$FFD0,$FFD0,$FFD0,$FFCF,$FFCF,$FFCF
 dc.w $FFCF,$FFCF,$FFCE,$FFCE,$FFCE,$FFCE,$FFCD,$FFCD
 dc.w $FFCD,$FFCD,$FFCD,$FFCC,$FFCC,$FFCC,$FFCC,$FFCC
 dc.w $FFCB,$FFCB,$FFCB,$FFCB,$FFCB,$FFCA,$FFCA,$FFCA
 dc.w $FFCA,$FFCA,$FFC9,$FFC9,$FFC9,$FFC9,$FFC9,$FFC8
 dc.w $FFC8,$FFC8,$FFC8,$FFC8,$FFC7,$FFC7,$FFC7,$FFC7
 dc.w $FFC7,$FFC6,$FFC6,$FFC6,$FFC6,$FFC6,$FFC5,$FFC5
 dc.w $FFC5,$FFC5,$FFC5,$FFC4,$FFC4,$FFC4,$FFC4,$FFC4
 dc.w $FFC3,$FFC3,$FFC3,$FFC3,$FFC3,$FFC2,$FFC2,$FFC2
 dc.w $FFC2,$FFC2,$FFC1,$FFC1,$FFC1,$FFC1,$FFC1,$FFC0
 dc.w $FFC0,$FFC0,$FFC0,$FFC0,$FFBF,$FFBF,$FFBF,$FFBF
 dc.w $FFBF,$FFBF,$FFBE,$FFBE,$FFBE,$FFBE,$FFBE,$FFBD
 dc.w $FFBD,$FFBD,$FFBD,$FFBD,$FFBC,$FFBC,$FFBC,$FFBC
 dc.w $FFBC,$FFBB,$FFBB,$FFBB,$FFBB,$FFBB,$FFBB,$FFBA
 dc.w $FFBA,$FFBA,$FFBA,$FFBA,$FFB9,$FFB9,$FFB9,$FFB9
 dc.w $FFB9,$FFB8,$FFB8,$FFB8,$FFB8,$FFB8,$FFB8,$FFB7
 dc.w $FFB7,$FFB7,$FFB7,$FFB7,$FFB6,$FFB6,$FFB6,$FFB6
 dc.w $FFB6,$FFB6,$FFB5,$FFB5,$FFB5,$FFB5,$FFB5,$FFB4
 dc.w $FFB4,$FFB4,$FFB4,$FFB4,$FFB4,$FFB3,$FFB3,$FFB3
 dc.w $FFB3,$FFB3,$FFB2,$FFB2,$FFB2,$FFB2,$FFB2,$FFB2
 dc.w $FFB1,$FFB1,$FFB1,$FFB1,$FFB1,$FFB1,$FFB0,$FFB0
 dc.w $FFB0,$FFB0,$FFB0,$FFAF,$FFAF,$FFAF,$FFAF,$FFAF
 dc.w $FFAF,$FFAE,$FFAE,$FFAE,$FFAE,$FFAE,$FFAE,$FFAD
 dc.w $FFAD,$FFAD,$FFAD,$FFAD,$FFAD,$FFAC,$FFAC,$FFAC
 dc.w $FFAC,$FFAC,$FFAC,$FFAB,$FFAB,$FFAB,$FFAB,$FFAB
 dc.w $FFAB,$FFAA,$FFAA,$FFAA,$FFAA,$FFAA,$FFAA,$FFA9
 dc.w $FFA9,$FFA9,$FFA9,$FFA9,$FFA9,$FFA8,$FFA8,$FFA8
 dc.w $FFA8,$FFA8,$FFA8,$FFA7,$FFA7,$FFA7,$FFA7,$FFA7
 dc.w $FFA7,$FFA6,$FFA6,$FFA6,$FFA6,$FFA6,$FFA6,$FFA5
 dc.w $FFA5,$FFA5,$FFA5,$FFA5,$FFA5,$FFA5,$FFA4,$FFA4
 dc.w $FFA4,$FFA4,$FFA4,$FFA4,$FFA3,$FFA3,$FFA3,$FFA3
 dc.w $FFA3,$FFA3,$FFA2,$FFA2,$FFA2,$FFA2,$FFA2,$FFA2
 dc.w $FFA2,$FFA1,$FFA1,$FFA1,$FFA1,$FFA1,$FFA1,$FFA1
 dc.w $FFA0,$FFA0,$FFA0,$FFA0,$FFA0,$FFA0,$FF9F,$FF9F
 dc.w $FF9F,$FF9F,$FF9F,$FF9F,$FF9F,$FF9E,$FF9E,$FF9E
 dc.w $FF9E,$FF9E,$FF9E,$FF9E,$FF9D,$FF9D,$FF9D,$FF9D
 dc.w $FF9D,$FF9D,$FF9D,$FF9C,$FF9C,$FF9C,$FF9C,$FF9C
 dc.w $FF9C,$FF9C,$FF9B,$FF9B,$FF9B,$FF9B,$FF9B,$FF9B
 dc.w $FF9B,$FF9A,$FF9A,$FF9A,$FF9A,$FF9A,$FF9A,$FF9A
 dc.w $FF9A,$FF99,$FF99,$FF99,$FF99,$FF99,$FF99,$FF99
 dc.w $FF98,$FF98,$FF98,$FF98,$FF98,$FF98,$FF98,$FF98
 dc.w $FF97,$FF97,$FF97,$FF97,$FF97,$FF97,$FF97,$FF97
 dc.w $FF96,$FF96,$FF96,$FF96,$FF96,$FF96,$FF96,$FF96
 dc.w $FF95,$FF95,$FF95,$FF95,$FF95,$FF95,$FF95,$FF95
 dc.w $FF94,$FF94,$FF94,$FF94,$FF94,$FF94,$FF94,$FF94
 dc.w $FF93,$FF93,$FF93,$FF93,$FF93,$FF93,$FF93,$FF93
 dc.w $FF92,$FF92,$FF92,$FF92,$FF92,$FF92,$FF92,$FF92
 dc.w $FF92,$FF91,$FF91,$FF91,$FF91,$FF91,$FF91,$FF91
 dc.w $FF91,$FF91,$FF90,$FF90,$FF90,$FF90,$FF90,$FF90
 dc.w $FF90,$FF90,$FF90,$FF8F,$FF8F,$FF8F,$FF8F,$FF8F
 dc.w $FF8F,$FF8F,$FF8F,$FF8F,$FF8E,$FF8E,$FF8E,$FF8E
 dc.w $FF8E,$FF8E,$FF8E,$FF8E,$FF8E,$FF8E,$FF8D,$FF8D
 dc.w $FF8D,$FF8D,$FF8D,$FF8D,$FF8D,$FF8D,$FF8D,$FF8D
 dc.w $FF8C,$FF8C,$FF8C,$FF8C,$FF8C,$FF8C,$FF8C,$FF8C
 dc.w $FF8C,$FF8C,$FF8B,$FF8B,$FF8B,$FF8B,$FF8B,$FF8B
 dc.w $FF8B,$FF8B,$FF8B,$FF8B,$FF8B,$FF8A,$FF8A,$FF8A
 dc.w $FF8A,$FF8A,$FF8A,$FF8A,$FF8A,$FF8A,$FF8A,$FF8A
 dc.w $FF89,$FF89,$FF89,$FF89,$FF89,$FF89,$FF89,$FF89
 dc.w $FF89,$FF89,$FF89,$FF89,$FF88,$FF88,$FF88,$FF88
 dc.w $FF88,$FF88,$FF88,$FF88,$FF88,$FF88,$FF88,$FF88
 dc.w $FF88,$FF87,$FF87,$FF87,$FF87,$FF87,$FF87,$FF87
 dc.w $FF87,$FF87,$FF87,$FF87,$FF87,$FF87,$FF86,$FF86
 dc.w $FF86,$FF86,$FF86,$FF86,$FF86,$FF86,$FF86,$FF86
 dc.w $FF86,$FF86,$FF86,$FF86,$FF85,$FF85,$FF85,$FF85
 dc.w $FF85,$FF85,$FF85,$FF85,$FF85,$FF85,$FF85,$FF85
 dc.w $FF85,$FF85,$FF85,$FF85,$FF84,$FF84,$FF84,$FF84
 dc.w $FF84,$FF84,$FF84,$FF84,$FF84,$FF84,$FF84,$FF84
 dc.w $FF84,$FF84,$FF84,$FF84,$FF84,$FF83,$FF83,$FF83
 dc.w $FF83,$FF83,$FF83,$FF83,$FF83,$FF83,$FF83,$FF83
 dc.w $FF83,$FF83,$FF83,$FF83,$FF83,$FF83,$FF83,$FF83
 dc.w $FF82,$FF82,$FF82,$FF82,$FF82,$FF82,$FF82,$FF82
 dc.w $FF82,$FF82,$FF82,$FF82,$FF82,$FF82,$FF82,$FF82
 dc.w $FF82,$FF82,$FF82,$FF82,$FF82,$FF82,$FF82,$FF81
 dc.w $FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81
 dc.w $FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81
 dc.w $FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81
 dc.w $FF81,$FF81,$FF81,$FF81,$FF81,$FF80,$FF80,$FF80
 dc.w $FF80,$FF80,$FF80,$FF80,$FF80,$FF80,$FF80,$FF80
 dc.w $FF80,$FF80,$FF80,$FF80,$FF80,$FF80,$FF80,$FF80
 dc.w $FF80,$FF80,$FF80,$FF80,$FF80,$FF80,$FF80,$FF80
 dc.w $FF80,$FF80,$FF80,$FF80,$FF80,$FF80,$FF80,$FF80
 dc.w $FF80,$FF80,$FF80,$FF80,$FF80,$FF80,$FF80,$FF80
 dc.w $FF80,$FF80,$FF80,$FF80,$FF80,$FF80,$FF80,$FF80
 dc.w $FF80,$FF80,$FF80,$FF80,$FF80,$FF80,$FF80,$FF80
 dc.w $FF80,$FF80,$FF80,$FF80,$FF80,$FF80,$FF80,$FF80
 dc.w $FF80,$FF80,$FF80,$FF80,$FF80,$FF80,$FF80,$FF80
 dc.w $FF80,$FF80,$FF80,$FF80,$FF80,$FF80,$FF80,$FF80
 dc.w $FF80,$FF80,$FF80,$FF80,$FF80,$FF80,$FF80,$FF80
 dc.w $FF80,$FF80,$FF80,$FF80,$FF80,$FF80,$FF80,$FF80
 dc.w $FF80,$FF80,$FF80,$FF80,$FF80,$FF80,$FF80,$FF80
 dc.w $FF80,$FF80,$FF80,$FF80,$FF80,$FF80,$FF80,$FF80
 dc.w $FF80,$FF80,$FF80,$FF80,$FF80,$FF80,$FF80,$FF80
 dc.w $FF80,$FF80,$FF80,$FF80,$FF80,$FF80,$FF80,$FF80
 dc.w $FF80,$FF80,$FF80,$FF80,$FF80,$FF80,$FF80,$FF80
 dc.w $FF80,$FF80,$FF80,$FF80,$FF81,$FF81,$FF81,$FF81
 dc.w $FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81
 dc.w $FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81
 dc.w $FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81
 dc.w $FF81,$FF81,$FF82,$FF82,$FF82,$FF82,$FF82,$FF82
 dc.w $FF82,$FF82,$FF82,$FF82,$FF82,$FF82,$FF82,$FF82
 dc.w $FF82,$FF82,$FF82,$FF82,$FF82,$FF82,$FF82,$FF82
 dc.w $FF82,$FF83,$FF83,$FF83,$FF83,$FF83,$FF83,$FF83
 dc.w $FF83,$FF83,$FF83,$FF83,$FF83,$FF83,$FF83,$FF83
 dc.w $FF83,$FF83,$FF83,$FF83,$FF84,$FF84,$FF84,$FF84
 dc.w $FF84,$FF84,$FF84,$FF84,$FF84,$FF84,$FF84,$FF84
 dc.w $FF84,$FF84,$FF84,$FF84,$FF84,$FF85,$FF85,$FF85
 dc.w $FF85,$FF85,$FF85,$FF85,$FF85,$FF85,$FF85,$FF85
 dc.w $FF85,$FF85,$FF85,$FF85,$FF85,$FF86,$FF86,$FF86
 dc.w $FF86,$FF86,$FF86,$FF86,$FF86,$FF86,$FF86,$FF86
 dc.w $FF86,$FF86,$FF86,$FF87,$FF87,$FF87,$FF87,$FF87
 dc.w $FF87,$FF87,$FF87,$FF87,$FF87,$FF87,$FF87,$FF87
 dc.w $FF88,$FF88,$FF88,$FF88,$FF88,$FF88,$FF88,$FF88
 dc.w $FF88,$FF88,$FF88,$FF88,$FF88,$FF89,$FF89,$FF89
 dc.w $FF89,$FF89,$FF89,$FF89,$FF89,$FF89,$FF89,$FF89
 dc.w $FF8A,$FF8A,$FF8A,$FF8A,$FF8A,$FF8A,$FF8A,$FF8A
 dc.w $FF8A,$FF8A,$FF8A,$FF8A,$FF8B,$FF8B,$FF8B,$FF8B
 dc.w $FF8B,$FF8B,$FF8B,$FF8B,$FF8B,$FF8B,$FF8C,$FF8C
 dc.w $FF8C,$FF8C,$FF8C,$FF8C,$FF8C,$FF8C,$FF8C,$FF8C
 dc.w $FF8C,$FF8D,$FF8D,$FF8D,$FF8D,$FF8D,$FF8D,$FF8D
 dc.w $FF8D,$FF8D,$FF8D,$FF8E,$FF8E,$FF8E,$FF8E,$FF8E
 dc.w $FF8E,$FF8E,$FF8E,$FF8E,$FF8E,$FF8F,$FF8F,$FF8F
 dc.w $FF8F,$FF8F,$FF8F,$FF8F,$FF8F,$FF8F,$FF90,$FF90
 dc.w $FF90,$FF90,$FF90,$FF90,$FF90,$FF90,$FF90,$FF91
 dc.w $FF91,$FF91,$FF91,$FF91,$FF91,$FF91,$FF91,$FF91
 dc.w $FF92,$FF92,$FF92,$FF92,$FF92,$FF92,$FF92,$FF92
 dc.w $FF92,$FF93,$FF93,$FF93,$FF93,$FF93,$FF93,$FF93
 dc.w $FF93,$FF94,$FF94,$FF94,$FF94,$FF94,$FF94,$FF94
 dc.w $FF94,$FF95,$FF95,$FF95,$FF95,$FF95,$FF95,$FF95
 dc.w $FF95,$FF96,$FF96,$FF96,$FF96,$FF96,$FF96,$FF96
 dc.w $FF96,$FF97,$FF97,$FF97,$FF97,$FF97,$FF97,$FF97
 dc.w $FF97,$FF98,$FF98,$FF98,$FF98,$FF98,$FF98,$FF98
 dc.w $FF98,$FF99,$FF99,$FF99,$FF99,$FF99,$FF99,$FF99
 dc.w $FF9A,$FF9A,$FF9A,$FF9A,$FF9A,$FF9A,$FF9A,$FF9B
 dc.w $FF9B,$FF9B,$FF9B,$FF9B,$FF9B,$FF9B,$FF9B,$FF9C
 dc.w $FF9C,$FF9C,$FF9C,$FF9C,$FF9C,$FF9C,$FF9D,$FF9D
 dc.w $FF9D,$FF9D,$FF9D,$FF9D,$FF9D,$FF9E,$FF9E,$FF9E
 dc.w $FF9E,$FF9E,$FF9E,$FF9E,$FF9F,$FF9F,$FF9F,$FF9F
 dc.w $FF9F,$FF9F,$FFA0,$FFA0,$FFA0,$FFA0,$FFA0,$FFA0
 dc.w $FFA0,$FFA1,$FFA1,$FFA1,$FFA1,$FFA1,$FFA1,$FFA1
 dc.w $FFA2,$FFA2,$FFA2,$FFA2,$FFA2,$FFA2,$FFA3,$FFA3
 dc.w $FFA3,$FFA3,$FFA3,$FFA3,$FFA3,$FFA4,$FFA4,$FFA4
 dc.w $FFA4,$FFA4,$FFA4,$FFA5,$FFA5,$FFA5,$FFA5,$FFA5
 dc.w $FFA5,$FFA5,$FFA6,$FFA6,$FFA6,$FFA6,$FFA6,$FFA6
 dc.w $FFA7,$FFA7,$FFA7,$FFA7,$FFA7,$FFA7,$FFA8,$FFA8
 dc.w $FFA8,$FFA8,$FFA8,$FFA8,$FFA9,$FFA9,$FFA9,$FFA9
 dc.w $FFA9,$FFA9,$FFAA,$FFAA,$FFAA,$FFAA,$FFAA,$FFAA
 dc.w $FFAB,$FFAB,$FFAB,$FFAB,$FFAB,$FFAB,$FFAC,$FFAC
 dc.w $FFAC,$FFAC,$FFAC,$FFAC,$FFAD,$FFAD,$FFAD,$FFAD
 dc.w $FFAD,$FFAD,$FFAE,$FFAE,$FFAE,$FFAE,$FFAE,$FFAE
 dc.w $FFAF,$FFAF,$FFAF,$FFAF,$FFAF,$FFAF,$FFB0,$FFB0
 dc.w $FFB0,$FFB0,$FFB0,$FFB1,$FFB1,$FFB1,$FFB1,$FFB1
 dc.w $FFB1,$FFB2,$FFB2,$FFB2,$FFB2,$FFB2,$FFB2,$FFB3
 dc.w $FFB3,$FFB3,$FFB3,$FFB3,$FFB4,$FFB4,$FFB4,$FFB4
 dc.w $FFB4,$FFB4,$FFB5,$FFB5,$FFB5,$FFB5,$FFB5,$FFB6
 dc.w $FFB6,$FFB6,$FFB6,$FFB6,$FFB6,$FFB7,$FFB7,$FFB7
 dc.w $FFB7,$FFB7,$FFB8,$FFB8,$FFB8,$FFB8,$FFB8,$FFB8
 dc.w $FFB9,$FFB9,$FFB9,$FFB9,$FFB9,$FFBA,$FFBA,$FFBA
 dc.w $FFBA,$FFBA,$FFBB,$FFBB,$FFBB,$FFBB,$FFBB,$FFBC
 dc.w $FFBC,$FFBC,$FFBC,$FFBC,$FFBC,$FFBD,$FFBD,$FFBD
 dc.w $FFBD,$FFBD,$FFBE,$FFBE,$FFBE,$FFBE,$FFBE,$FFBF
 dc.w $FFBF,$FFBF,$FFBF,$FFBF,$FFC0,$FFC0,$FFC0,$FFC0
 dc.w $FFC0,$FFC0,$FFC1,$FFC1,$FFC1,$FFC1,$FFC1,$FFC2
 dc.w $FFC2,$FFC2,$FFC2,$FFC2,$FFC3,$FFC3,$FFC3,$FFC3
 dc.w $FFC3,$FFC4,$FFC4,$FFC4,$FFC4,$FFC4,$FFC5,$FFC5
 dc.w $FFC5,$FFC5,$FFC5,$FFC6,$FFC6,$FFC6,$FFC6,$FFC6
 dc.w $FFC7,$FFC7,$FFC7,$FFC7,$FFC7,$FFC8,$FFC8,$FFC8
 dc.w $FFC8,$FFC8,$FFC9,$FFC9,$FFC9,$FFC9,$FFC9,$FFCA
 dc.w $FFCA,$FFCA,$FFCA,$FFCA,$FFCB,$FFCB,$FFCB,$FFCB
 dc.w $FFCB,$FFCC,$FFCC,$FFCC,$FFCC,$FFCC,$FFCD,$FFCD
 dc.w $FFCD,$FFCD,$FFCE,$FFCE,$FFCE,$FFCE,$FFCE,$FFCF
 dc.w $FFCF,$FFCF,$FFCF,$FFCF,$FFD0,$FFD0,$FFD0,$FFD0
 dc.w $FFD0,$FFD1,$FFD1,$FFD1,$FFD1,$FFD1,$FFD2,$FFD2
 dc.w $FFD2,$FFD2,$FFD2,$FFD3,$FFD3,$FFD3,$FFD3,$FFD4
 dc.w $FFD4,$FFD4,$FFD4,$FFD4,$FFD5,$FFD5,$FFD5,$FFD5
 dc.w $FFD5,$FFD6,$FFD6,$FFD6,$FFD6,$FFD6,$FFD7,$FFD7
 dc.w $FFD7,$FFD7,$FFD8,$FFD8,$FFD8,$FFD8,$FFD8,$FFD9
 dc.w $FFD9,$FFD9,$FFD9,$FFD9,$FFDA,$FFDA,$FFDA,$FFDA
 dc.w $FFDB,$FFDB,$FFDB,$FFDB,$FFDB,$FFDC,$FFDC,$FFDC
 dc.w $FFDC,$FFDC,$FFDD,$FFDD,$FFDD,$FFDD,$FFDE,$FFDE
 dc.w $FFDE,$FFDE,$FFDE,$FFDF,$FFDF,$FFDF,$FFDF,$FFDF
 dc.w $FFE0,$FFE0,$FFE0,$FFE0,$FFE1,$FFE1,$FFE1,$FFE1
 dc.w $FFE1,$FFE2,$FFE2,$FFE2,$FFE2,$FFE3,$FFE3,$FFE3
 dc.w $FFE3,$FFE3,$FFE4,$FFE4,$FFE4,$FFE4,$FFE4,$FFE5
 dc.w $FFE5,$FFE5,$FFE5,$FFE6,$FFE6,$FFE6,$FFE6,$FFE6
 dc.w $FFE7,$FFE7,$FFE7,$FFE7,$FFE8,$FFE8,$FFE8,$FFE8
 dc.w $FFE8,$FFE9,$FFE9,$FFE9,$FFE9,$FFEA,$FFEA,$FFEA
 dc.w $FFEA,$FFEA,$FFEB,$FFEB,$FFEB,$FFEB,$FFEC,$FFEC
 dc.w $FFEC,$FFEC,$FFEC,$FFED,$FFED,$FFED,$FFED,$FFED
 dc.w $FFEE,$FFEE,$FFEE,$FFEE,$FFEF,$FFEF,$FFEF,$FFEF
 dc.w $FFEF,$FFF0,$FFF0,$FFF0,$FFF0,$FFF1,$FFF1,$FFF1
 dc.w $FFF1,$FFF1,$FFF2,$FFF2,$FFF2,$FFF2,$FFF3,$FFF3
 dc.w $FFF3,$FFF3,$FFF3,$FFF4,$FFF4,$FFF4,$FFF4,$FFF5
 dc.w $FFF5,$FFF5,$FFF5,$FFF5,$FFF6,$FFF6,$FFF6,$FFF6
 dc.w -9,-9,-9,-9,-9,-8,-8,-8
 dc.w -8,-7,-7,-7,-7,-7,-6,-6
 dc.w -6,-6,-5,-5,-5,-5,-4,-4
 dc.w -4,-4,-4,-3,-3,-3,-3,-2
 dc.w -2,-2,-2,-2,-1,-1,-1,-1
 dc.w 0,0,0,0,0,1,1,1,1,2,2,2,2,2,3,$3,3,3,4,4,4,4,4,$5
 dc.w 5,5,5,6,6,6,6,$6,7,7,7,7,8,8,8,$8
 dc.w 8,9,9,9,9,$A,$A,$A,$A,$A,$B,$B,$B,$B,$C,$C
 dc.w $C,$C,$C,$D,$D,$D,$D,$E,$E,$E,$E,$E,$F,$F,$F,$F
 dc.w $10,$10,$10,$10,$10,$11,$11,$11,$11,$12,$12,$12,$12,$12,$13,$13
 dc.w $13,$13,$14,$14,$14,$14,$14,$15,$15,$15,$15,$16,$16,$16,$16,$16
 dc.w $17,$17,$17,$17,$18,$18,$18,$18,$18,$19,$19,$19,$19,$19,$1A,$1A
 dc.w $1A,$1A,$1B,$1B,$1B,$1B,$1B,$1C,$1C,$1C,$1C,$1D,$1D,$1D,$1D,$1D
 dc.w $1E,$1E,$1E,$1E,$1E,$1F,$1F,$1F,$1F,$20,$20,$20,$20,$20,$21,$21
 dc.w $21,$21,$22,$22,$22,$22,$22,$23,$23,$23,$23,$23,$24,$24,$24,$24
 dc.w $25,$25,$25,$25,$25,$26,$26,$26,$26,$26,$27,$27,$27,$27,$28,$28
 dc.w $28,$28,$28,$29,$29,$29,$29,$29,$2A,$2A,$2A,$2A,$2A,$2B,$2B,$2B
 dc.w $2B,$2C,$2C,$2C,$2C,$2C,$2D,$2D,$2D,$2D,$2D,$2E,$2E,$2E,$2E,$2E
 dc.w $2F,$2F,$2F,$2F,$2F,$30,$30,$30,$30,$31,$31,$31,$31,$31,$32,$32
 dc.w $32,$32,$32,$33,$33,$33,$33,$33,$34,$34,$34,$34,$34,$35,$35,$35
 dc.w $35,$35,$36,$36,$36,$36,$36,$37,$37,$37,$37,$37,$38,$38,$38,$38
 dc.w $38,$39,$39,$39,$39,$39,$3A,$3A,$3A,$3A,$3A,$3B,$3B,$3B,$3B,$3B
 dc.w $3C,$3C,$3C,$3C,$3C,$3D,$3D,$3D,$3D,$3D,$3E,$3E,$3E,$3E,$3E,$3F
 dc.w $3F,$3F,$3F,$3F,$40,$40,$40,$40,$40,$40,$41,$41,$41,$41,$41,$42
 dc.w $42,$42,$42,$42,$43,$43,$43,$43,$43,$44,$44,$44,$44,$44,$44,$45
 dc.w $45,$45,$45,$45,$46,$46,$46,$46,$46,$47,$47,$47,$47,$47,$47,$48
 dc.w $48,$48,$48,$48,$49,$49,$49,$49,$49,$49,$4A,$4A,$4A,$4A,$4A,$4B
 dc.w $4B,$4B,$4B,$4B,$4B,$4C,$4C,$4C,$4C,$4C,$4D,$4D,$4D,$4D,$4D,$4D
 dc.w $4E,$4E,$4E,$4E,$4E,$4F,$4F,$4F,$4F,$4F,$4F,$50,$50,$50,$50,$50
 dc.w $50,$51,$51,$51,$51,$51,$51,$52,$52,$52,$52,$52,$52,$53,$53,$53
 dc.w $53,$53,$54,$54,$54,$54,$54,$54,$55,$55,$55,$55,$55,$55,$56,$56
 dc.w $56,$56,$56,$56,$56,$57,$57,$57,$57,$57,$57,$58,$58,$58,$58,$58
 dc.w $58,$59,$59,$59,$59,$59,$59,$5A,$5A,$5A,$5A,$5A,$5A,$5B,$5B,$5B
 dc.w $5B,$5B,$5B,$5B,$5C,$5C,$5C,$5C,$5C,$5C,$5D,$5D,$5D,$5D,$5D,$5D
 dc.w $5D,$5E,$5E,$5E,$5E,$5E,$5E,$5E,$5F,$5F,$5F,$5F,$5F,$5F,$60,$60
 dc.w $60,$60,$60,$60,$60,$61,$61,$61,$61,$61,$61,$61,$62,$62,$62,$62
 dc.w $62,$62,$62,$63,$63,$63,$63,$63,$63,$63,$64,$64,$64,$64,$64,$64
 dc.w $64,$65,$65,$65,$65,$65,$65,$65,$65,$66,$66,$66,$66,$66,$66,$66
 dc.w $67,$67,$67,$67,$67,$67,$67,$67,$68,$68,$68,$68,$68,$68,$68,$69
 dc.w $69,$69,$69,$69,$69,$69,$69,$6A,$6A,$6A,$6A,$6A,$6A,$6A,$6A,$6B
 dc.w $6B,$6B,$6B,$6B,$6B,$6B,$6B,$6B,$6C,$6C,$6C,$6C,$6C,$6C,$6C,$6C
 dc.w $6D,$6D,$6D,$6D,$6D,$6D,$6D,$6D,$6D,$6E,$6E,$6E,$6E,$6E,$6E,$6E
 dc.w $6E,$6E,$6F,$6F,$6F,$6F,$6F,$6F,$6F,$6F,$6F,$70,$70,$70,$70,$70
 dc.w $70,$70,$70,$70,$71,$71,$71,$71,$71,$71,$71,$71,$71,$71,$72,$72
 dc.w $72,$72,$72,$72,$72,$72,$72,$72,$73,$73,$73,$73,$73,$73,$73,$73
 dc.w $73,$73,$74,$74,$74,$74,$74,$74,$74,$74,$74,$74,$74,$75,$75,$75
 dc.w $75,$75,$75,$75,$75,$75,$75,$75,$76,$76,$76,$76,$76,$76,$76,$76
 dc.w $76,$76,$76,$76,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77
 dc.w $77,$78,$78,$78,$78,$78,$78,$78,$78,$78,$78,$78,$78,$78,$79,$79
 dc.w $79,$79,$79,$79,$79,$79,$79,$79,$79,$79,$79,$79,$7A,$7A,$7A,$7A
 dc.w $7A,$7A,$7A,$7A,$7A,$7A,$7A,$7A,$7A,$7A,$7A,$7A,$7B,$7B,$7B,$7B
 dc.w $7B,$7B,$7B,$7B,$7B,$7B,$7B,$7B,$7B,$7B,$7B,$7B,$7B,$7C,$7C,$7C
 dc.w $7C,$7C,$7C,$7C,$7C,$7C,$7C,$7C,$7C,$7C,$7C,$7C,$7C,$7C,$7C,$7C
 dc.w $7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D
 dc.w $7D,$7D,$7D,$7D,$7D,$7D,$7D,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E
 dc.w $7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E
 dc.w $7E,$7E,$7E,$7E,$7E,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F
 dc.w $7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F
 dc.w $7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F
 dc.w $7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F
 dc.w $7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F

font1:

 dc.w 0,0,0,0,0,0,0,0,$18,$1008,$1818,$1818,$1818,$1818,$10,$800
 dc.w $24,$1224,0,0,0,0,0,0
 dc.w 0,0,$1414,$3E14,$3E14,$1414,$400,0
 dc.w $808,$81E,$3828,$2838,$C0E,$4A7E,$1C08,$800
 dc.w 0,$7352,$7404,$818,$1037,$6567,0,0
 dc.w $30,$3828,$292B,$3A1A,$2C2C,$6A38,0,0,$10,$808,0,0,0,0,0,0
 dc.w $20D,$1020,$2040,$4020,$6060,$3030,$1C0F,$300
 dc.w $6048,$1C06,$603,$303,$303,$606,$1C78,$6000
 dc.w 0,$8,$2A1C,$7F1C,$2A08,0,0,0
 dc.w 0,$18,$1000,$6E,$5E18,$1818,0,0,0,0,0,0,0,0,$1008,$800
 dc.w 0,0,0,$6F5F,0,0,0,0,0,0,0,0,0,0,$1008,0
 dc.w $101,$302,$40C,$818,$1010,$3020,$2040,$4000
 dc.w $366F,$4323,$6363,$6363,$6363,$6363,$637F,$3E00
 dc.w $810,$2858,$1818,$1818,$1818,$1818,$1818,$1800
 dc.w $6E5F,$303,$303,$32F,$5E20,$6060,$607F,$3F00
 dc.w $6C5E,$703,$303,$372F,$303,$303,$76E,$5C00
 dc.w $6060,$4020,$6864,$7F7F,$C0C,$C0C,$C0C,$C00
 dc.w $6F5F,$2060,$6060,$7F7F,$303,$303,$36F,$5F00
 dc.w $6060,$4020,$6060,$607E,$7F63,$6363,$637F,$3E00
 dc.w $776F,$303,$303,$303,$303,$303,$303,$300
 dc.w $366F,$4323,$6363,$7F3E,$7F63,$6363,$637F,$3E00
 dc.w $376F,$4323,$6363,$7F3F,$303,$303,$303,$300
 dc.w 0,0,$10,$800,$10,$800,0,0,0,0,$10,$800,$10,$808,0,0
 dc.w $306,$C18,$1030,$6060,$2010,$180C,$406,$300
 dc.w 0,0,$6F,$5F00,$6F,$5F00,0,0
 dc.w $6020,$3018,$804,$203,$204,$C18,$3060,$4000
 dc.w $2E5F,$2363,$303,$170E,$1818,$1800,$10,$800
 dc.w 0,$3E,$6E4E,$5252,$5C40,$4143,$7E00,0
 dc.w $6C5E,$2763,$6363,$637F,$7F63,$6363,$6363,$6300
 dc.w $6C5E,$2763,$6367,$7E7C,$7E67,$6363,$677E,$7C00
 dc.w $172F,$5020,$6060,$6060,$6060,$6060,$703F,$1F00
 dc.w $6C5E,$2763,$6363,$6363,$6363,$6363,$677E,$7C00
 dc.w $172F,$5020,$6060,$7E7E,$6060,$6060,$703F,$1F00
 dc.w $6F5F,$2060,$6060,$7C7C,$6060,$6060,$6060,$6000
 dc.w $6F5F,$2060,$6060,$6665,$6363,$6363,$637F,$7F00
 dc.w $6342,$2163,$6363,$7F7F,$6363,$6363,$6363,$6300
 dc.w $6E5E,$1818,$1818,$1818,$1818,$1818,$185E,$3E00
 dc.w $6E5E,$1818,$1818,$1818,$1818,$1818,$1858,$3800
 dc.w $6347,$2E7C,$7870,$7078,$786C,$6C66,$6663,$6300
 dc.w $6040,$2060,$6060,$6060,$6060,$6060,$607F,$7F00
 dc.w $6E5F,$2B6B,$6B6B,$6B6B,$6B6B,$6B6B,$6B6B,$6B00
 dc.w $6C5E,$2763,$6363,$6363,$6363,$6363,$6363,$6300
 dc.w $366F,$4323,$6363,$6363,$6363,$6363,$637F,$3E00
 dc.w $6E5F,$2363,$6363,$7F7E,$6060,$6060,$6060,$6000
 dc.w $1A37,$6F43,$2363,$6363,$6363,$6367,$7F7F,$3F00
 dc.w $6E5F,$2363,$6363,$7F7E,$7078,$7C6E,$6763,$6100
 dc.w $1B37,$6040,$2070,$3C1E,$703,$303,$77E,$7C00
 dc.w $6E5E,$1818,$1818,$1818,$1818,$1818,$1818,$1800
 dc.w $6342,$2163,$6363,$6363,$6363,$6363,$637F,$7F00
 dc.w $6342,$2163,$6363,$6363,$6363,$6363,$773E,$1C00
 dc.w $6B4A,$216B,$6B6B,$6B6B,$6B6B,$6B6B,$6B7F,$7E00
 dc.w $6342,$2136,$361C,$1C1C,$1C1C,$3636,$6363,$6300
 dc.w $6342,$2163,$6373,$3F1F,$303,$303,$77E,$7C00
 dc.w $6F5F,$306,$60C,$C18,$1830,$3060,$607F,$7F00
 dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
 dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 dc.w 0,$818,$1818,$1818,$1818,$1818,$8,$1800,$12,$3624,0,0,0,0,0,0
 dc.w 0,0,$1414,$3E14,$3E14,$1414,$400,0
 dc.w $808,$81E,$3828,$2838,$C0E,$4A7E,$1C08,$800
 dc.w 0,$7352,$7404,$818,$1037,$6567,0,0
 dc.w $30,$3828,$292B,$3A1A,$2C2C,$6A38,0,0,8,$1808,0,0,0,0,0,0
 dc.w $103,$C10,$1020,$2060,$6060,$3030,$1C0F,$300
 dc.w $38,$1C06,$603,$303,$303,$606,$1C78,$6000
 dc.w 0,$8,$2A1C,$7F1C,$2A08,0,0,0,0,0,$818,$181E,$3E18,$1818,0,0
 dc.w 0,0,0,0,0,0,$818,$800,0,0,0,$1F3F,0,0,0,0,0,0,0,0,0,0,$818,0
 dc.w $101,$302,$40C,$818,$1010,$3020,$2040,$4000
 dc.w $E1F,$2363,$6363,$6363,$6363,$6363,$637F,$3E00
 dc.w $8,$1838,$1818,$1818,$1818,$1818,$1818,$1800
 dc.w $1E3F,$303,$303,$31F,$3E60,$6060,$607F,$3F00
 dc.w $1C3E,$703,$303,$F1F,$303,$303,$71E,$3C00
 dc.w 0,$2060,$646C,$7F7F,$C0C,$C0C,$C0C,$C00
 dc.w $1F3F,$6060,$6060,$7F7F,$303,$303,$31F,$3F00
 dc.w 0,$2060,$6060,$607E,$7F63,$6363,$637F,$3E00
 dc.w $F1F,$303,$303,$303,$303,$303,$303,$300
 dc.w $E1F,$2363,$6363,$7F3E,$7F63,$6363,$637F,$3E00
 dc.w $F1F,$2363,$6363,$7F3F,$303,$303,$303,$300
 dc.w 0,0,$8,$1800,$8,$1800,0,0,0,0,$8,$1800,$8,$1808,0,0
 dc.w $306,$C18,$1030,$6060,$2010,$180C,$406,$300
 dc.w 0,0,$1F,$3F00,$1F,$3F00,0,0
 dc.w $6020,$3018,$804,$203,$204,$C18,$3060,$4000
 dc.w $1E3F,$6363,$303,$F1E,$1818,$1800,$8,$1800
 dc.w 0,$3E,$6E4E,$5252,$5C40,$4143,$7E00,0
 dc.w $1C3E,$6763,$6363,$637F,$7F63,$6363,$6363,$6300
 dc.w $1C3E,$6763,$6367,$7E7C,$7E67,$6363,$677E,$7C00
 dc.w $F1F,$3060,$6060,$6060,$6060,$6060,$703F,$1F00
 dc.w $1C3E,$6763,$6363,$6363,$6363,$6363,$677E,$7C00
 dc.w $F1F,$3060,$6060,$7E7E,$6060,$6060,$703F,$1F00
 dc.w $1F3F,$6060,$6060,$7C7C,$6060,$6060,$6060,$6000
 dc.w $1F3F,$6060,$6060,$6163,$6363,$6363,$637F,$7F00
 dc.w $21,$6363,$6363,$7F7F,$6363,$6363,$6363,$6300
 dc.w $1E3E,$1818,$1818,$1818,$1818,$1818,$183E,$7E00
 dc.w $1E3E,$1818,$1818,$1818,$1818,$1818,$1838,$7800
 dc.w $327,$6E7C,$7870,$7078,$786C,$6C66,$6663,$6300
 dc.w $20,$6060,$6060,$6060,$6060,$6060,$607F,$7F00
 dc.w $1E3F,$6B6B,$6B6B,$6B6B,$6B6B,$6B6B,$6B6B,$6B00
 dc.w $1C3E,$6763,$6363,$6363,$6363,$6363,$6363,$6300
 dc.w $E1F,$2363,$6363,$6363,$6363,$6363,$637F,$3E00
 dc.w $1E3F,$6363,$6363,$7F7E,$6060,$6060,$6060,$6000
 dc.w $60F,$1F23,$6363,$6363,$6363,$6367,$7F7F,$3F00
 dc.w $1E3F,$6363,$6363,$7F7E,$7078,$7C6E,$6763,$6100
 dc.w $70F,$1020,$6070,$3C1E,$703,$303,$77E,$7C00
 dc.w $1E3E,$1818,$1818,$1818,$1818,$1818,$1818,$1800
 dc.w $21,$6363,$6363,$6363,$6363,$6363,$637F,$7F00
 dc.w $21,$6363,$6363,$6363,$6363,$6363,$773E,$1C00
 dc.w $21,$6B6B,$6B6B,$6B6B,$6B6B,$6B6B,$6B7F,$7E00
 dc.w $21,$6336,$361C,$1C1C,$1C1C,$3636,$6363,$6300
 dc.w $21,$6363,$6373,$3F1F,$303,$303,$77E,$7C00
 dc.w $1F3F,$306,$60C,$C18,$1830,$3060,$607F,$7F00,0,0,0,0,0,0,0,0
 dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 
bpsong:	;COMMANDO

 dc.w $434F,$4D4D,$414E,$444F,$4849,0,0,0
 dc.w 0,0,0,0,0,$562E,$3214,$18,$FF04,$10,$105,$20,$100,$28,$40,0
 dc.w $100,0,$40,0,$128,0,0,0,$FF11,$40,$10E,$40,$102,$F04,$8,$8
 dc.w $102,$1000,$10,0,$128,0,0,0,$FF08,$20,$109,$40,$101,$A01,$40,0
 dc.w $102,$B00,$40,0,$140,0,0,0,$FF00,$10,$101,$40,$102,$308,$8,$A
 dc.w $100,$300,0,0,$140,0,0,0,0,0,0,0,0,0,0,0
 dc.w 0,0,0,0,0,0,$1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$1,0,0,0,0,0,0,0,0,0
 dc.w 0,0,0,0,0,0,$1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$1,0
 dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,$1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$1,0
 dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,$1,0,0,0,0,0,0,0,0,0
 dc.w 0,0,0,0,0,0,$1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$1,0,0,0,0,0,0,0,0,0
 dc.w 0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$1,0,2,0,$3,0,$4,0,$5,0
 dc.w 2,0,$6,0,$7,0,$8,0,2,0,$9,0,$A,0,$B,0,2,0,$C,0,$D,0,$E,0
 dc.w 2,0,$3,0,$4,0,$5,0,2,0,$6,0,$7,0,$8,0,2,0,$9,0,$A,0,$B,0
 dc.w 2,0,$C,0,$7,$FB,$F,5,2,0,$10,0,$11,0,$5,$FB,2,0,$12,0,$13,0,$14,0
 dc.w 2,0,$9,0,$15,0,$16,0,2,0,$C,0,$17,0,$18,0,2,0,$3,0,$4,0,$5,0
 dc.w 2,0,$6,0,$7,0,$8,0,2,0,$9,0,$A,0,$B,0,2,0,$C,0,$7,$FB,$F,0
 dc.w 2,0,$3,0,$A,0,$1,0,2,0,$19,0,$1A,0,$1B,0,2,0,$1C,0,$A,0,$1,0
 dc.w 2,0,$19,0,$1A,0,$1B,0,2,0,$3,0,$A,0,$1,0,2,0,$19,0,$1D,0,$1E,0
 dc.w 2,0,$1C,0,$A,0,$1,0,2,0,$19,0,$1A,0,$1B,0,0,0,0,0,0,0,0,0
 dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$A10,$C00,$C,$1110,$C00,$C,$1610,$C00
 dc.w $C,$1110,$C00,$C,$1610,$C00,$C,$1610
 dc.w $C00,$C,$1110,$C00,$C,$1610,$C00,$C,$A23,0,0,$A20,0,0,$139,$4700
 dc.w 0,$A20,0,0,$A20,0,0,$A20,0,0,$139,$4700,0,$A20,0,0,$1A42,$700,0,0,0,0,0,0
 dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$2,$700,0,0,0,0,0,0
 dc.w 0,0,0,0,0,0,0,0,0,0,$1840,0,0,0,0,0,$820,0,0,$820,0,0,$139,$4700
 dc.w 0,$820,0,0,$820,0,0,$820,0,0,$139,$4700,0,$820,0,0,$1B40,0,0,0,0,0,0,0
 dc.w 0,$1840,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$1A40,0,0,0,0
 dc.w 0,0,0,0,0,0,0,$1A40,0,0,0,0,0,0,0,0,$F20,0,0,$F20,0,0,$139,$4700
 dc.w 0,$F20,0,0,$F20,0,0,$F20,0,0,$139,$4700,0,$F20,0,0
 dc.w $1640,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 dc.w 0,0,0,0,0,0,0,0,0,0,$1640,0,0,0,0,0,$1120,0,0,$1120,0,0,$139,$4700
 dc.w 0,$1120,0,0,$1120,0,0,$1120,0,0,$139,$4700,0,$1120,0,0
 dc.w $1640,0,0,0,0,0,0,0,0,$1340,0,0,0,0,0,0,0,0,0,0,0,$1640,0,0
 dc.w 0,0,0,$1540,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$1540,0,0,0,0,0
 dc.w 0,0,0,$1540,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$1140,0,0,0,0,0
 dc.w $132F,0,0,$1320,0,0,$139,$4700,0,$1320,0,0,$1320,0,0,$1320
 dc.w 0,0,$139,$4700,0,$1320,0,0,$1142,$700,0,0,0,0,0,0
 dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,$1640,0,0,$E20,0,0,$E20,0,0,$139,$4700
 dc.w 0,$E20,0,0,$E20,0,0,$E20,0,0,$139,$4700,0,$E20,0,0,0,0,0,0,0,0,$1540,0
 dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,$1840,0,0,$1640,0,0,0,0,0,0,0
 dc.w 0,0,0,0,0,0,0,0,0,0,$1640,0,0,0,0,0,0,0,0,0,0,0,$1840,0
 dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$1A40,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 dc.w 0,0,0,0,0,$1A40,0,0,$1B40,0,0,0,0,0,0,0,0,$1A40,0,0,0,0,0,0
 dc.w 0,0,0,0,0,$1A40,0,0,0,0,0,$1B40,0,0,0,0,0,0,0,0,0,0,0,$1840
 dc.w 0,0,0,0,0,0,0,0,$F20,0,0,$F20,0,0,$139,$4700,0,$F20,0,0,$1120,0,0,$1120
 dc.w 0,0,$139,$5900,0,$1120,0,0,0,0,0,0,0,0,$1140,0,0,0,0,0,$1640,0,0,0
 dc.w 0,0,$1140,0,0,0,0,0,0,0,0,$F40,0,0,0,0,0,$F40,0,0,0,0,0,$1540
 dc.w 0,0,0,0,0,$1840,0,0,$A20,0,0,$A20,0,0,$139,$4700
 dc.w 0,$A20,0,0,$A20,0,0,$A20,0,0,$139,$6A00,0,$A20,0,0
 dc.w 0,0,0,0,0,0,$F40,0,0,0,0,0,$1640,0,0,0,0,0,$1140,0,0,0,0,0
 dc.w 0,0,0,$1140,0,0,0,0,0,$1140,0,0,0,0,0,$1540,0,0,0,0,0,$F40,0,0
 dc.w $2F2E,$2526,$2026,$242D,$2F42,$667D,$A87,$94BA
 dc.w $D0D2,$DAD9,$DFDA,$DBD2,$D1BE,$9982,$178,$6C46
 dc.w $2F2E,$2526,$2026,$242D,$2F42,$667D,$A87,$94BA
 dc.w $D0D2,$DAD9,$DFDA,$DBD2,$D1BE,$9982,0,0
 dc.w $B125,$4D69,$797F,$796B,$594F,$4B45,$3F3B,$352F
 dc.w $2B27,$251F,$1B17,$130F,$D09,$501,$FDF9,$F5F3
 dc.w $F1ED,$E9E7,$E5E1,$DFDB,$D9D7,$D3D1,$CFCB,$C9C5
 dc.w $C3C1,$BBB9,$B7B3,$B1AD,$ABA9,$A5A3,$A19F,$9D9D
 dc.w $4963,$7E7C,$6548,$393F,$421C,$DFC9,$FD34,$27EC
 dc.w $C0C1,$C8BC,$9F86,$8299,$B7B0,$919F,$15A,$7254
 dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 dc.w $F,$230F,$ED,$D7ED,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 dc.w 0,0,0,0,0,0,0,0,$88B4,$43,$747C,$643F,$2625,$3749,$4424,$F3C5
 dc.w $B6CC,$FC2C,$4539,$10DF,$BBB4,$C3D5,$D7C2,$9F84
 dc.w $87B3,$42,$737C,$6744,$2B2B,$3A4A,$4624,$F5C8
 dc.w $B9CE,$FE2B,$4337,$EE0,$BCB5,$C0CF,$D1BC,$9B83
 dc.w $7F6F,$574D,$3D31,$2315,$3F5,$DFCF,$BBAD,$9F99
 dc.w $918D,$8987,$8583,$8381,$8181,$8181,$8181,$8181
 dc.w $8181,$8181,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 dc.w $FF6D,$C525,$43D9,$391F,$65BF,$ED8F,$2BF5,$6BBF
 dc.w $3B05,$71AF,$D553,$15A9,$2D65,$CFF3,$B539,$896D
 dc.w $C109,$B5D,$D999,$F335,$B94D,$5F13,$CDF3,$A567
 dc.w $1319,$2DDD,$77B5,$4793,$93ED,$6FE3,$6531,$91DB
 dc.w $7945,$F05,$F9EF,$E3DB,$D3C9,$C1B7,$ADA3,$9B93
 dc.w $8D85,$8387,$8787,$8787,$8787,$8787,$8787,$8787
 dc.w $8787,$8787,$8787,$8787,$8787,$8787,$8585,$8385
 dc.w $8787,$8383,$8383,$8383,$8383,$8383,$8381,$8783
 dc.w $81B1,$D5F7,$1B35,$4B5B,$6771,$7375,$7575,$7373
 dc.w $7373,$7577,$7779,$7979,$7979,$7B7B,$7B7B,$7B7D
 dc.w $7D7D,$7D7D,$7D7D,$7D7D,$7D7D,$7F7F,$7F7F,$7D7F
 dc.w $7F79,$7371,$7979,$7B7B,$7D7D,$7F7F,$7F7F,$7F7F
 dc.w $FF6D,$C525,$43D9,$391F,$65BF,$ED8F,$2BF5,$6BBF
 dc.w $3B05,$71AF,$D553,$15A9,$2D65,$CFF3,$B539,$896D
 dc.w $C109,$B5D,$D999,$F335,$B94D,$5F13,$CDF3,$A567
 dc.w $1319,$2DDD,$77B5,$4793,$93ED,$6FE3,$6531,$91DB,0,0,0,0,0,0,0,0
 dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 dc.w $7D7D,$7D7D,$7D7D,$7D7D,$7D7D,$7D7D,$7D7D,$7D7D
 dc.w $7D7D,$7D7D,$7D7D,$7D7D,$7D7D,$7D7D,$7D7D,$7D87
 dc.w $8787,$8787,$8787,$8787,$8787,$8787,$8787,$8787
 dc.w $8787,$8787,$8787,$8787,$8787,$8787,$8787,$8787
 dc.w $7F47,$2321,$1D19,$1511,$D09,$503,-5,$F9F5
 dc.w $F3EF,$EDE9,$E7E5,$E1DF,$DDD9,$D7D5,$D3D1,$CDCB
 dc.w $C9C5,$C3C1,$BFBB,$B9B7,$B5B3,$AFAD,$ABA7,$A5A3
 dc.w $A19F,$9D9B,$9797,$9593,$918F,$8D89,$8785,$8381
 dc.w $F,$230F,$ED,$D7ED,0,0,0,0
 dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 dc.w $F5EF,$E5D7,$C9B9,$ADA5,$ABB5,$C3CF,$D7DF,$EBF5
 dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 dc.w $8383,$8383,$8383,$8383,$7D7D,$7D7D,$7D7D,$7D7D
 dc.w $7D7D,$7D7D,$7D7D,$7D7D,$7D7D,$7D7D,$7D7D,$7D7D
 dc.w $7D7D,$7D7D,$7D7D,$7D7D,$7D7D,$7D7D,$7D7D,$7D7D
 dc.w $7D7D,$7D7D,$7D7D,$7D7D,$7D7D,$7D7D,$7D7D,$7D7D
 dc.w $8585,$8585,$8585,$8585,$8585,$8585,$8585,$8585
 dc.w $8585,$8585,$8585,$8585,$8585,$8585,$8585,$8585
 dc.w $8585,$8585,$8585,$8585,$8585,$8585,$8585,$8585
 dc.w $8585,$8585,$8585,$8585,$8585,$8585,$8585,$8585
 dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 
 END

