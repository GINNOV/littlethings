	Section	codice,CODE

	incdir	"dh1:programs/asmone/modem/bbs/"
	include	"DaWorkBench.s"	
	include	"startup2.s"

DMASET		equ	%1000001110000000
WAITDISK	equ	10

START:
	movem.l	d0-d7/a0-a6,-(SP)	; setto la musica
	lea	P61_data,a0	; Indirizzo del modulo in a0
	lea	$dff000,a6	; Ricordiamoci il $dff000 in a6!
	sub.l	a1,a1		; I samples non sono a parte, mettiamo zero
	sub.l	a2,a2		; no samples -> modulo non compattato
	lea	samples,a2	; modulo compattato! Buffer destinazione per
				; i samples (in chip ram) da indicare!
	bsr.w	P61_Init
	movem.l	(SP)+,d0-d7/a0-a6

	move.l	BaseVbr(PC),A1
	move.l	#MyInt6c,$6C(A1)
	move.w	#DMASET,$dff096		; DMACON - abilita bitplane e copper
	move.w	#$e020,$dff09a		; INTENA - Abilito Master and lev6

	lea	BPLPOINTERS,A1
	move.l	#PICTURE,d0
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
 	swap	d0

	move.l	#VUOTO,d0
	lea	BPLPOINTERStesto,A1	
 	move.w	d0,6(a1)
 	swap	d0
 	move.w	d0,2(a1)
 	swap	d0

	bsr.w	maketabz
	bsr.w	makeoffy
	bsr.w	makecube

	bsr.w	PRINTATESTO

	move.l	#COPPERLIST,$dff080
	move.w	d0,$dff088

	clr.l	VBcounter

LOOP:
	bsr.w	WBLAN

	lea	PTRPIC(pc),a0		; double buffering
	movem.l	(a0),d0-d1
	exg.l	d0,d1
	movem.l	d0-d1,(a0)
	lea	BPLPOINTERS,a0
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)

	bsr.w	LINECOP		; Effetto "supercar"

	bsr.w	CUBO3D
	bsr.w	MUOVIPIC
	bsr.w	MUOVIPIC
	bsr.w	RIMBALZO

	btst	#6,$bfe001	; se premi il mouse ESCI!!!
	beq.w	ESCI

	cmpi.l	#3500,VBcounter
	blo.s	LOOP

	clr.l	VBcounter

ESCI:
	lea	$dff000,a6	; stoppo la musica
	bsr.w	P61_End
	rts			; esci

ptrpic:
	dc.l	Picture,Picture+ScreenX*ScreenY/8


******************************************************************************
;			ROUTINE CHE ASPETTA IL VBL
******************************************************************************

WBLAN:
	move.l	$dff004,d0
	and.l	#$0001ff00,d0
	cmp.l	#$00002000,d0
	bne.s	WBLAN
WBLAN1:
	move.l	$dff004,d0
	and.l	#$0001ff00,d0
	cmp.l	#$00002000,d0
	beq.s	WBLAN1
	rts

******************************************************************************
			; Interrupt level 3, VERTB...
******************************************************************************

	cnop	0,4
MyInt6c:
	btst	#5,$DFF01F
	beq.s	NoIntVertb
	movem.l	D0-D7/A0-A6,-(SP)
	st	FrameFlagCounter
	addq.l	#1,VBcounter
	movem.l	(SP)+,D0-D7/A0-A6
NoIntVertb:
	btst	#4,$DFF01F
	beq.w	NoIntCoper
NoIntCoper:
	move.w	#$70,$DFF09C
	rte

*****************************************************************************

FrameFlagCounter:
	dc.w	0

AspettaFrameFlag:
	sf	FrameFlagCounter
StoFlaNon:
	tst.b	FrameFlagCounter
	beq.b	StoFlaNon
	rts

AspettVBL:
	cmp.b	#$40,$dff006
	bne.s	AspettVBL
AspettVBL2:
	cmp.b	#$40,$dff006
	beq.s	AspettVBL2
	rts

*******************************************************************************

VBcounter:
	dc.l	0

*****************************************************************************
*	ROUTINE CHE SPOSTA L'IMMAGINE IN OGNI DIREZIONE
*****************************************************************************

; Uses: d0-d3/a0-a1

MUOVIPIC:
	move.l	indtabx(pc),a0	; a0=ptr position x
	cmpa.l	#endtabx,a0
	bne.s	nextvalx
	lea	tabposx(pc),a0
nextvalx:
	move.l	indtaby(pc),a1	; a1=ptr position y
	cmpa.l	#endtaby,a1
	bne.s	nextvaly
	lea	tabposy(pc),a1
nextvaly:
	moveq	#0,d0
	move.w	(a0)+,d0	; [d0.w=position x in mem]
	moveq	#0,d1
	move.w	(a1)+,d1	; [d1.w=position y in mem]
	move.l	d1,d3
	lsl.w	#5,d1
	lsl.w	#3,d3
	add.w	d3,d1		; d1.w=offset y for bplptr
	move.l	d0,d2
	lsr.w	#3,d2
	andi.w	#$fffe,d2	; d2.w=offset x for bplptr
	move.l	a0,indtabx
	andi.w	#$000f,d0	; d0.b=value for bplcon1
	move.l	a1,indtaby

	move.b	d0,BplCon1+3	; ok bplcon1 in cop
	move.l	#Picture,d0
	sub.l	d1,d0
	sub.l	d2,d0		; d0=address to point pic
	bsr.w	PuntaPic

	rts

indtabx:
	dc.l	tabposx
indtaby:
	dc.l	tabposy

tabposx:
	DC.W	$009F,$009F,$009F,$009F,$009F,$009F,$009F,$009E,$009E,$009E
	DC.W	$009D,$009D,$009C,$009C,$009B,$009A,$009A,$0099,$0098,$0097
	DC.W	$0096,$0096,$0095,$0094,$0093,$0092,$0091,$0090,$008E,$008D
	DC.W	$008C,$008B,$008A,$0088,$0087,$0086,$0084,$0083,$0081,$0080
	DC.W	$007E,$007D,$007B,$007A,$0078,$0077,$0075,$0073,$0072,$0070
	DC.W	$006F,$006D,$006B,$0069,$0068,$0066,$0064,$0063,$0061,$005F
	DC.W	$005D,$005C,$005A,$0059,$0057,$0056,$0054,$0052,$0050,$004F
	DC.W	$004D,$004B,$0049,$0048,$0046,$0044,$0043,$0041,$003F,$003E
	DC.W	$003C,$003B,$0039,$0038,$0036,$0035,$0033,$0032,$0030,$002F
	DC.W	$002E,$002C,$002B,$002A,$0028,$0027,$0026,$0025,$0024,$0023
	DC.W	$0022,$0021,$0020,$001F,$001E,$001D,$001C,$001B,$001B,$001A
	DC.W	$0019,$0019,$0018,$0018,$0017,$0017,$0016,$0016,$0016,$0015
	DC.W	$0015,$0015,$0015,$0015,$0015,$0015,$0015,$0015,$0015,$0015
	DC.W	$0015,$0015,$0016,$0016,$0016,$0017,$0017,$0018,$0018,$0019
	DC.W	$0019,$001A,$001B,$001C,$001C,$001D,$001E,$001F,$0020,$0021
	DC.W	$0022,$0023,$0024,$0025,$0026,$0028,$0029,$002A,$002B,$002D
	DC.W	$002E,$002F,$0031,$0032,$0034,$0035,$0037,$0038,$003A,$003B
	DC.W	$003D,$003E,$0040,$0042,$0043,$0045,$0047,$0048,$004A,$004C
	DC.W	$004D,$004F,$0051,$0053,$0054,$0056,$0058,$005A,$005A,$005C
	DC.W	$005E,$0060,$0061,$0063,$0065,$0067,$0068,$006A,$006C,$006D
	DC.W	$006F,$0071,$0072,$0074,$0076,$0077,$0079,$007A,$007C,$007D
	DC.W	$007F,$0080,$0082,$0083,$0085,$0086,$0087,$0089,$008A,$008B
	DC.W	$008C,$008E,$008F,$0090,$0091,$0092,$0093,$0094,$0095,$0096
	DC.W	$0097,$0098,$0098,$0099,$009A,$009A,$009B,$009C,$009C,$009D
	DC.W	$009D,$009E,$009E,$009E,$009F,$009F,$009F,$009F,$009F,$009F
endtabx:

tabposy:
	DC.W	$0064,$0066,$0068,$006A,$006B,$006D,$006F,$0071,$0072,$0074
	DC.W	$0076,$0077,$0079,$007B,$007C,$007E,$0080,$0081,$0083,$0084
	DC.W	$0086,$0088,$0089,$008A,$008C,$008D,$008F,$0090,$0091,$0093
	DC.W	$0094,$0095,$0097,$0098,$0099,$009A,$009B,$009C,$009D,$009E
	DC.W	$009F,$00A0,$00A1,$00A2,$00A2,$00A3,$00A4,$00A5,$00A5,$00A6
	DC.W	$00A6,$00A7,$00A7,$00A8,$00A8,$00A8,$00A9,$00A9,$00A9,$00A9
	DC.W	$00A9,$00A9,$00AA,$00A9,$00A9,$00A9,$00A9,$00A9,$00A9,$00A8
	DC.W	$00A8,$00A8,$00A7,$00A7,$00A6,$00A6,$00A5,$00A5,$00A4,$00A3
	DC.W	$00A2,$00A2,$00A1,$00A0,$009F,$009E,$009D,$009C,$009B,$009A
	DC.W	$0099,$0098,$0097,$0095,$0094,$0093,$0091,$0090,$008F,$008D
	DC.W	$008C,$008A,$0089,$0088,$0086,$0084,$0083,$0081,$0080,$007E
	DC.W	$007C,$007B,$0079,$0077,$0076,$0074,$0072,$0071,$006F,$006D
	DC.W	$006B,$006A,$0068,$0066,$0064,$0064,$0062,$0060,$005E,$005D
	DC.W	$005B,$0059,$0057,$0056,$0054,$0052,$0051,$004F,$004D,$004C
	DC.W	$004A,$0048,$0047,$0045,$0044,$0042,$0040,$003F,$003E,$003C
	DC.W	$003B,$0039,$0038,$0037,$0035,$0034,$0033,$0031,$0030,$002F
	DC.W	$002E,$002D,$002C,$002B,$002A,$0029,$0028,$0027,$0026,$0026
	DC.W	$0025,$0024,$0023,$0023,$0022,$0022,$0021,$0021,$0020,$0020
	DC.W	$0020,$001F,$001F,$001F,$001F,$001F,$001F,$001E,$001F,$001F
	DC.W	$001F,$001F,$001F,$001F,$0020,$0020,$0020,$0021,$0021,$0022
	DC.W	$0022,$0023,$0023,$0024,$0025,$0026,$0026,$0027,$0028,$0029
	DC.W	$002A,$002B,$002C,$002D,$002E,$002F,$0030,$0031,$0033,$0034
	DC.W	$0035,$0037,$0038,$0039,$003B,$003C,$003E,$003F,$0040,$0042
	DC.W	$0044,$0045,$0047,$0048,$004A,$004C,$004D,$004F,$0051,$0052
	DC.W	$0054,$0056,$0057,$0059,$005B,$005D,$005E,$0060,$0062,$0064
endtaby:

******************************************************************************
*	ROUTINE CHE PUNTA L'IMMAGINE IN COPPERLIST
*
* Input: d0=picture address
******************************************************************************

PUNTAPIC:
	lea	BPLPOINTERS,a1
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	rts

*****************************************************************************
*			ROUTINE DI 3D
*****************************************************************************

ScreenX = 320
ScreenY = 256

CUBO3D:

; -=-=-=-=-=-=-=-=-=- Pulisci buffer -=-=-=-=-=-=-=-=-=-=-

	move.l	sp,oldsp
	move.l	ptrpic(pc),sp
	lea	ScreenX*ScreenY/8(sp),sp
	movem.l	clrreg,a0-a6/d0-d6
	move.w	#ScreenX*ScreenY/8/(14*4)-1,d7
.clrscr:
	movem.l	d0-d6/a0-a6,-(sp)
	dbra	d7,.clrscr
	movem.l	d0-d6/a0-a4,-(sp)
	move.l	oldsp,sp
	
; -=-=-=-=-=-=-=-=-=- Rotazione -=-=-=-=-=-=-=-=-=-

	lea	angles,a0		; ptr angles
	lea	SinTab(pc),a1		; ptr sintab
	lea	SinTab+1024/4*2(pc),a2	; ptr costab
	lea	xyzcosta,a4		; ptr costants
	move.w	#1023,d7		; and angle mask

	movem.w	(a0),d0-d2
	addq.w	#daz,d0
	and.w	d7,d0			; d0=ax
	move.w	d0,(a0)+
	addq.w	#day,d1
	and.w	d7,d1			; d1=ay
	move.w	d1,(a0)+
	addq.w	#dax,d2
	and.w	d7,d2			; d2=az
	move.w	d2,(a0)

	move.w	(a2,d2.w*2),d5		; cos(az)=c3
	move.w	(a1,d2.w*2),d4		; sin(az)=s3	
	move.w	(a2,d1.w*2),d3		; cos(ay)=c2
	move.w	(a1,d1.w*2),d2		; sin(ay)=s2
	move.w	(a2,d0.w*2),d1		; cos(ax)=c1
	move.w	(a1,d0.w*2),d0		; sin(ax)=s1

	move.w	d5,d6
	muls	d3,d6
	move.l	d6,a0		;
	move.w	d4,d7
	muls	d2,d7
	move.l	d7,a1		;
	add.l	d7,d7
	add.l	d7,d7
	swap	d7
	muls	d0,d7
	add.l	d6,d7
	add.l	d7,d7
	add.l	d7,d7
	swap	d7
	move.w	d7,(a4)+	; A
	move.w	d4,d6
	muls	d3,d6
	move.l	d6,a2		;
	move.w	d2,d7
	muls	d5,d7
	move.l	d7,a3		;
	add.l	d7,d7
	add.l	d7,d7
	swap	d7
	muls	d0,d7
	sub.l	d6,d7
	add.l	d7,d7
	add.l	d7,d7
	swap	d7
	move.w	d7,(a4)+	; B
	move.w	d2,d7
	muls	d1,d7
	add.l	d7,d7
	add.l	d7,d7
	swap	d7
	move.w	d7,(a4)+	; C
	move.w	d4,d7
	muls	d1,d7
	add.l	d7,d7
	add.l	d7,d7
	swap	d7
	move.w	d7,(a4)+	; D
	move.w	d5,d7
	muls	d1,d7
	add.l	d7,d7
	add.l	d7,d7
	swap	d7
	move.w	d7,(a4)+	; E
	move.w	d0,d7
	neg.w	d7
	move.w	d7,(a4)+	; F
	move.l	a2,d7
	add.l	d7,d7
	add.l	d7,d7
	swap	d7
	muls	d0,d7
	sub.l	a3,d7
	add.l	d7,d7
	add.l	d7,d7
	swap	d7
	move.w	d7,(a4)+	; G
	move.l	a0,d7
	add.l	d7,d7
	add.l	d7,d7
	swap	d7
	muls	d0,d7
	add.l	a1,d7
	add.l	d7,d7
	add.l	d7,d7
	swap	d7
	move.w	d7,(a4)+	; H
	muls	d1,d3
	add.l	d3,d3
	add.l	d3,d3
	swap	d3
	move.w	d3,(a4)		; I

	lea	BuffPointsXYZ,a0
	lea	PointsXYZ,a1
	lea	xyzcosta,a4		; ptr costants
	move.w	#PointsObj-1,d7
.looprot1:
	movem.w	(a0)+,d0-d2		; d0=x  d1=y  d2=z

	movem.w	(a4)+,d3-d5
	muls.w	d0,d3			; d3=A*x
	muls.w	d1,d4			; d4=B*y
	muls.w	d2,d5			; d5=C*z
	add.l	d4,d3
	add.l	d5,d3			; d3=xr
	add.l	d3,d3
	add.l	d3,d3
	swap	d3
	move.w	d3,(a1)+

	movem.w	(a4)+,d3-d5
	muls.w	d0,d3			; d3=D*x
	muls.w	d1,d4			; d4=E*y
	muls.w	d2,d5			; d5=F*z
	add.l	d4,d3
	add.l	d5,d3			; d3=yr
	add.l	d3,d3
	add.l	d3,d3
	swap	d3
	move.w	d3,(a1)+
	
	movem.w	(a4)+,d3-d5
	muls.w	d0,d3			; d3=G*x
	muls.w	d1,d4			; d4=H*y
	muls.w	d2,d5			; d5=I*z
	add.l	d4,d3
	add.l	d5,d3			; d3=zr
	add.l	d3,d3
	add.l	d3,d3
	swap	d3
	move.w	d3,(a1)+

	lea	xyzcosta,a4		; ptr costants
	dbra	d7,.looprot1

; -=-=-=-=-=-=-=-=-=- Prospettiva -=-=-=-=-=-=-=-=-=-=-=-

	lea	PointsXYZ,a0		; a0=ptr points 3d
	lea	PointsXY,a1		; a1=ptr points 2d
	lea	tabz+511*4,a2		; ptr tabz for z=0
	move.w	#ScreenX/2-100,d3		; d3=cx
	move.w 	#ScreenY/2-95,d4		; d4=cy
	move.w	#PointsObj-1,d7
.loopprosp:
	movem.w	(a0)+,d0-d2		; d0=x  d1=y  d2=z
	move.l	(a2,d2.w*4),d2		; d5=prosp z in 16.16
	muls.l	d2,d0			; d0=xp
	swap	d0
	add.w	d3,d0
	move.w	d0,(a1)+
	muls.l	d2,d1			; d1=yp
	swap	d1
	add.w	d4,d1
	move.w	d1,(a1)+
	dbra	d7,.loopprosp

; -=-=-=-=-=-=-=-=-=- Clipping -=-=-=-=-=-=-=-=-=-

	lea	PointsXY,a0
	lea	offsety,a1
	move.l	ptrpic(pc),a2
	moveq	#0,d1
	moveq	#7,d3			; and mask
	move.w	#PointsObj-1,d7
.loopplot:
	move.w	(a0)+,d0		; d0=xp
	move.w	(a0)+,d1		; d1=yp
	move.w	(a1,d1.w*2),d2		; right offsety to plot point
	move.w	d0,d1
	and.b	d3,d1			; ptr bit of byte x to plot
	not.b	d1			; invert bit sequence
	lsr.w	#3,d0
	add.w	d0,d2			; ptr byte of pixel to plot
	bset.b	d1,(a2,d2.w)		; plot point
.noplot:
	dbra	d7,.loopplot
	rts

SinTab:
	DC.W	$0032,$0096,$00FA,$015F,$01C3,$0227
	DC.W	$028B,$02F0,$0354,$03B8,$041C,$0480
	DC.W	$04E4,$0548,$05AC,$0610,$0674,$06D8
	DC.W	$073B,$079F,$0802,$0866,$08C9,$092D
	DC.W	$0990,$09F3,$0A56,$0AB9,$0B1C,$0B7F
	DC.W	$0BE1,$0C44,$0CA6,$0D08,$0D6A,$0DCC
	DC.W	$0E2E,$0E90,$0EF2,$0F53,$0FB4,$1016
	DC.W	$1077,$10D7,$1138,$1199,$11F9,$1259
	DC.W	$12B9,$1319,$1379,$13D8,$1437,$1497
	DC.W	$14F5,$1554,$15B3,$1611,$166F,$16CD
	DC.W	$172A,$1788,$17E5,$1842,$189F,$18FB
	DC.W	$1957,$19B3,$1A0F,$1A6A,$1AC6,$1B21
	DC.W	$1B7B,$1BD6,$1C30,$1C8A,$1CE4,$1D3D
	DC.W	$1D96,$1DEF,$1E47,$1EA0,$1EF7,$1F4F
	DC.W	$1FA6,$1FFD,$2054,$20AB,$2101,$2156
	DC.W	$21AC,$2201,$2256,$22AA,$22FF,$2352
	DC.W	$23A6,$23F9,$244C,$249E,$24F0,$2542
	DC.W	$2593,$25E4,$2635,$2685,$26D5,$2725
	DC.W	$2774,$27C3,$2811,$285F,$28AD,$28FA
	DC.W	$2947,$2993,$29DF,$2A2B,$2A76,$2AC1
	DC.W	$2B0C,$2B56,$2B9F,$2BE8,$2C31,$2C7A
	DC.W	$2CC1,$2D09,$2D50,$2D97,$2DDD,$2E23
	DC.W	$2E68,$2EAD,$2EF1,$2F35,$2F79,$2FBC
	DC.W	$2FFE,$3040,$3082,$30C3,$3104,$3144
	DC.W	$3184,$31C3,$3202,$3240,$327E,$32BC
	DC.W	$32F9,$3335,$3371,$33AC,$33E7,$3422
	DC.W	$345C,$3495,$34CE,$3506,$353E,$3576
	DC.W	$35AD,$35E3,$3619,$364E,$3683,$36B7
	DC.W	$36EB,$371E,$3751,$3783,$37B5,$37E6
	DC.W	$3816,$3847,$3876,$38A5,$38D3,$3901
	DC.W	$392F,$395B,$3988,$39B3,$39DE,$3A09
	DC.W	$3A33,$3A5C,$3A85,$3AAE,$3AD5,$3AFC
	DC.W	$3B23,$3B49,$3B6F,$3B94,$3BB8,$3BDC
	DC.W	$3BFF,$3C22,$3C44,$3C65,$3C86,$3CA6
	DC.W	$3CC6,$3CE5,$3D04,$3D22,$3D3F,$3D5C
	DC.W	$3D78,$3D94,$3DAF,$3DC9,$3DE3,$3DFC
	DC.W	$3E15,$3E2D,$3E44,$3E5B,$3E72,$3E87
	DC.W	$3E9C,$3EB1,$3EC5,$3ED8,$3EEB,$3EFD
	DC.W	$3F0E,$3F1F,$3F2F,$3F3F,$3F4E,$3F5C
	DC.W	$3F6A,$3F77,$3F84,$3F90,$3F9B,$3FA6
	DC.W	$3FB0,$3FBA,$3FC3,$3FCB,$3FD3,$3FDA
	DC.W	$3FE0,$3FE6,$3FEC,$3FF0,$3FF4,$3FF8
	DC.W	$3FFA,$3FFD,$3FFE,$3FFF,$3FFF,$3FFF
	DC.W	$3FFE,$3FFD,$3FFB,$3FF8,$3FF5,$3FF1
	DC.W	$3FEC,$3FE7,$3FE1,$3FDB,$3FD4,$3FCC
	DC.W	$3FC4,$3FBB,$3FB2,$3FA8,$3F9D,$3F92
	DC.W	$3F86,$3F79,$3F6C,$3F5E,$3F50,$3F41
	DC.W	$3F31,$3F21,$3F11,$3EFF,$3EED,$3EDB
	DC.W	$3EC7,$3EB4,$3E9F,$3E8A,$3E75,$3E5F
	DC.W	$3E48,$3E30,$3E18,$3E00,$3DE7,$3D3D
	DC.W	$3DB3,$3D98,$3D7C,$3D60,$3D43,$3D26
	DC.W	$3D08,$3CEA,$3CCA,$3CAB,$3C8B,$3C6A
	DC.W	$3C48,$3C26,$3C04,$3BE1,$3BBD,$3B99
	DC.W	$3B74,$3B4F,$3B29,$3B02,$3ADB,$3AB3
	DC.W	$3A8B,$3A62,$3A39,$3A0F,$39E4,$39B9
	DC.W	$398E,$3962,$3935,$3908,$38DA,$38AC
	DC.W	$387D,$384D,$381D,$37ED,$37BC,$378A
	DC.W	$3758,$3725,$36F2,$36BF,$368A,$3656
	DC.W	$3620,$35EB,$35B4,$357D,$3546,$350E
	DC.W	$34D6,$349D,$3464,$342A,$33F0,$33B5
	DC.W	$3379,$333D,$3301,$32C4,$3287,$3249
	DC.W	$320B,$31CC,$318D,$314D,$310D,$30CC
	DC.W	$308B,$304A,$3008,$2FC5,$2F82,$2F3F
	DC.W	$2EFB,$2EB6,$2E72,$2E2C,$2DE7,$2DA1
	DC.W	$2D5A,$2D13,$2CCC,$2C84,$2C3B,$2BF3
	DC.W	$2BAA,$2B60,$2B16,$2ACC,$2A81,$2A36
	DC.W	$29EA,$299E,$2952,$2905,$28B8,$286A
	DC.W	$281C,$27CE,$277F,$2730,$26E0,$2691
	DC.W	$2640,$25F0,$259F,$254D,$24FC,$24AA
	DC.W	$2457,$2405,$23B2,$235E,$230A,$22B6
	DC.W	$2262,$220D,$21B8,$2163,$210D,$20B7
	DC.W	$2060,$200A,$1FB3,$1F5B,$1F04,$1EAC
	DC.W	$1E54,$1DFB,$1DA3,$1D49,$1CF0,$1C97
	DC.W	$1C3D,$1BE2,$1B88,$1B2D,$1AD2,$1A77
	DC.W	$1A1C,$19C0,$1964,$1908,$18AC,$184F
	DC.W	$17F2,$1795,$1737,$16DA,$167C,$161E
	DC.W	$15C0,$1561,$1503,$14A4,$1445,$13E6
	DC.W	$1386,$1327,$12C7,$1267,$1207,$11A6
	DC.W	$1146,$10E5,$1084,$1023,$0FC2,$0F61
	DC.W	$0EFF,$0E9E,$0E3C,$0DDA,$0D78,$0D16
	DC.W	$0CB4,$0C51,$0BEF,$0B8C,$0B2A,$0AC7
	DC.W	$0A64,$0A01,$099E,$093B,$08D7,$0874
	DC.W	$0810,$07AD,$0749,$06E5,$0682,$061E
	DC.W	$05BA,$0556,$04F2,$048E,$042A,$03C6
	DC.W	$0362,$02FE,$0299,$0235,$01D1,$016D
	DC.W	$0108,$00A4,$0040,$FFDC,$FF78,$FF14
	DC.W	$FEAF,$FE4B,$FDE7,$FD83,$FD1E,$FCBA
	DC.W	$FC56,$FBF2,$FB8E,$FB2A,$FAC6,$FA62
	DC.W	$F9FE,$F99A,$F936,$F8D3,$F86F,$F80B
	DC.W	$F7A8,$F745,$F6E1,$F67E,$F61B,$F5B8
	DC.W	$F555,$F4F2,$F48F,$F42D,$F3CA,$F368
	DC.W	$F305,$F2A3,$F241,$F1DF,$F17E,$F11C
	DC.W	$F0BA,$F059,$EFF8,$EF97,$EF36,$EED5
	DC.W	$EE75,$EE14,$EDB4,$ED54,$ECF4,$EC95
	DC.W	$EC35,$EBD6,$EB77,$EB18,$EAB9,$EA5B
	DC.W	$E9FC,$E99E,$E940,$E8E3,$E885,$E828
	DC.W	$E7CB,$E76E,$E712,$E6B6,$E65A,$E5FE
	DC.W	$E5A2,$E547,$E4EC,$E491,$E437,$E3DD
	DC.W	$E383,$E329,$E2CF,$E276,$E21E,$E1C5
	DC.W	$E16D,$E115,$E0BD,$E066,$E00F,$DFB8
	DC.W	$DF61,$DF0B,$DEB5,$DE60,$DE0B,$DDB6
	DC.W	$DD61,$DD0D,$DCB9,$DC66,$DC13,$DBC0
	DC.W	$DB6D,$DB1B,$DAC9,$DA78,$DA27,$D9D6
	DC.W	$D986,$D936,$D8E6,$D897,$D848,$D7FA
	DC.W	$D7AC,$D75E,$D711,$D6C4,$D677,$D62B
	DC.W	$D5DF,$D594,$D549,$D4FF,$D4B5,$D46B
	DC.W	$D422,$D3D9,$D390,$D349,$D301,$D2BA
	DC.W	$D273,$D22D,$D1E7,$D1A2,$D15D,$D118
	DC.W	$D0D4,$D091,$D04E,$D00B,$CFC9,$CF87
	DC.W	$CF46,$CF05,$CEC5,$CE85,$CE46,$CE07
	DC.W	$CDC8,$CD8A,$CD4D,$CD10,$CCD3,$CC97
	DC.W	$CC5C,$CC21,$CBE6,$CBAC,$CB73,$CB3A
	DC.W	$CB01,$CAC9,$CA92,$CA5B,$CA25,$C9EF
	DC.W	$C9B9,$C984,$C950,$C91C,$C8E9,$C8B6
	DC.W	$C884,$C852,$C821,$C7F0,$C7C0,$C791
	DC.W	$C762,$C733,$C705,$C6D8,$C6AB,$C67F
	DC.W	$C653,$C628,$C5FD,$C5D3,$C5A9,$C580
	DC.W	$C558,$C530,$C509,$C4E2,$C4BC,$C497
	DC.W	$C472,$C44D,$C429,$C406,$C3E3,$C3C1
	DC.W	$C3A0,$C37F,$C35E,$C33E,$C31F,$C301
	DC.W	$C2E2,$C2C5,$C2A8,$C28C,$C270,$C255
	DC.W	$C23A,$C221,$C207,$C1EE,$C1D6,$C1BF
	DC.W	$C1A8,$C191,$C17C,$C167,$C152,$C13E
	DC.W	$C12B,$C118,$C106,$C0F4,$C0E3,$C0D3
	DC.W	$C0C3,$C0B4,$C0A6,$C098,$C08A,$C07E
	DC.W	$C072,$C066,$C05B,$C051,$C047,$C03E
	DC.W	$C036,$C02E,$C027,$C021,$C01B,$C015
	DC.W	$C010,$C00C,$C009,$C006,$C004,$C002
	DC.W	$C001,$C001,$C001,$C001,$C003,$C005
	DC.W	$C008,$C00B,$C00F,$C013,$C018,$C01E
	DC.W	$C024,$C02B,$C033,$C03B,$C044,$C04D
	DC.W	$C057,$C062,$C06D,$C079,$C085,$C092
	DC.W	$C0A0,$C0AE,$C0BD,$C0CC,$C0DC,$C0ED
	DC.W	$C0FE,$C110,$C123,$C136,$C149,$C15E
	DC.W	$C173,$C188,$C19E,$C1B5,$C1CC,$C1E4
	DC.W	$C1FD,$C216,$C22F,$C24A,$C265,$C280
	DC.W	$C29C,$C2B9,$C2D6,$C2F4,$C312,$C331
	DC.W	$C351,$C371,$C392,$C3B3,$C3D5,$C3F7
	DC.W	$C41A,$C43E,$C462,$C487,$C4AC,$C4D2
	DC.W	$C4F8,$C520,$C547,$C56F,$C598,$C5C1
	DC.W	$C5EB,$C616,$C640,$C66C,$C698,$C6C5
	DC.W	$C6F2,$C720,$C74E,$C77D,$C7AC,$C7DC
	DC.W	$C80C,$C83D,$C86F,$C8A1,$C8D3,$C906
	DC.W	$C93A,$C96E,$C9A3,$C9D8,$CA0E,$CA44
	DC.W	$CA7B,$CAB2,$CAEA,$CB22,$CB5B,$CB94
	DC.W	$CBCE,$CC08,$CC43,$CC7E,$CCBA,$CCF6
	DC.W	$CD33,$CD70,$CDAE,$CDEC,$CE2B,$CE6A
	DC.W	$CEAA,$CEEA,$CF2A,$CF6B,$CFAD,$CFEF
	DC.W	$D031,$D074,$D0B8,$D0FB,$D140,$D184
	DC.W	$D1CA,$D20F,$D255,$D29C,$D2E3,$D32A
	DC.W	$D372,$D3BA,$D403,$D44C,$D495,$D4DF
	DC.W	$D529,$D574,$D5BF,$D60B,$D657,$D6A3
	DC.W	$D6F0,$D73D,$D78B,$D7D8,$D827,$D875
	DC.W	$D8C4,$D914,$D964,$D9B4,$DA04,$DA55
	DC.W	$DAA7,$DAF8,$DB4A,$DB9D,$DBEF,$DC42
	DC.W	$DC96,$DCE9,$DD3D,$DD92,$DDE7,$DE3C
	DC.W	$DE91,$DEE7,$DF3D,$DF93,$DFEA,$E041
	DC.W	$E098,$E0EF,$E147,$E19F,$E1F8,$E250
	DC.W	$E2A9,$E303,$E35C,$E3B6,$E410,$E46B
	DC.W	$E4C5,$E520,$E57B,$E5D7,$E632,$E68E
	DC.W	$E6EA,$E747,$E7A4,$E800,$E85D,$E8BB
	DC.W	$E918,$E976,$E9D4,$EA32,$EA91,$EAEF
	DC.W	$EB4E,$EBAD,$EC0C,$EC6C,$ECCB,$ED2B
	DC.W	$ED8B,$EDEB,$EE4C,$EEAC,$EF0D,$EF6D
	DC.W	$EFCE,$F030,$F091,$F0F2,$F154,$F1B5
	DC.W	$F217,$F279,$F2DB,$F33E,$F3A0,$F402
	DC.W	$F465,$F4C8,$F52B,$F58D,$F5F0,$F654
	DC.W	$F6B7,$F71A,$F77D,$F7E1,$F844,$F8A8
	DC.W	$F90C,$F96F,$F9D3,$FA37,$FA9B,$FAFF
	DC.W	$FB63,$FBC7,$FC2B,$FC8F,$FCF3,$FD58
	DC.W	$FDBC,$FE20,$FE84,$FEE9,$FF4D,$FFB1
	DC.W	$0015,$0079,$00DD,$0142,$01A6,$020A
	DC.W	$026E,$02D3,$0337,$039B,$03FF,$0463
	DC.W	$04C7,$050B,$058F,$05F3,$0657,$06BB
	DC.W	$071E,$0782,$07E6,$0849,$08AC,$0910
	DC.W	$0973,$09D6,$0A39,$0A9C,$0AFF,$0B62
	DC.W	$0BC5,$0C27,$0C89,$0CEC,$0D4E,$0DB0
	DC.W	$0E12,$0E74,$0ED5,$0F37,$0F98,$0FF9
	DC.W	$105A,$10BB,$111C,$117D,$11DD,$123D
	DC.W	$129D,$12FD,$135D,$13BC,$141C,$147B
	DC.W	$14DA,$1539,$1597,$15F5,$1653,$16B1
	DC.W	$170F,$176D,$17CA,$1827,$1884,$18E0
	DC.W	$193C,$1998,$19F4,$1A50,$1AAB,$1B06
	DC.W	$1B61,$1BBB,$1C16,$1C70,$1CC9,$1D23
	DC.W	$1D7C,$1DD5,$1E2E,$1E86,$1EDE,$1F36
	DC.W	$1F8D,$1FE4,$203B,$2091,$20E8,$213D
	DC.W	$2193,$21E8,$223D,$2292,$22E6,$233A
	DC.W	$238D,$23E1,$2434,$2486,$24D8,$252A
	DC.W	$257C,$25CD,$261D,$266E,$26BE,$270E
	DC.W	$275D,$27AC,$27FA,$2848,$2896,$28E3
	DC.W	$2930,$297D,$29C9,$2A15,$2A60,$2AAB
	DC.W	$2AF6,$2B40,$2B8A,$2BD3,$2C1C,$2C64
	DC.W	$2CAC,$2CF4,$2D3B,$2D82,$2DC8,$2E0E
	DC.W	$2E54,$2E99,$2EDD,$2F21,$2F65,$2FA8
	DC.W	$2FEB,$302D,$306F,$30B0,$30F1,$3131
	DC.W	$3171,$31B1,$31F0,$322E,$326C,$32AA
	DC.W	$3257,$3323,$335F,$339B,$33D6,$3411
	DC.W	$344B,$3484,$34BD,$34F6,$352E,$3565
	DC.W	$359C,$35D3,$3609,$363F,$3673,$36A8
	DC.W	$36DC,$370F,$3742,$3774,$37A6,$37D7
	DC.W	$3808,$3838,$3868,$3897,$38C6,$38F4
	DC.W	$3921,$394E,$397B,$39A6,$39D2,$39FC
	DC.W	$3A27,$3A50,$3A79,$3AA2,$3ACA,$3AF1
	DC.W	$3B18,$3B3E,$3B64,$3B89,$3BAD,$3BD1
	DC.W	$3BF5,$3C17,$3C3A,$3C5B,$3C7C,$3C9D
	DC.W	$3CBD,$3CDC,$3CFB,$3D19,$3D36,$3D53
	DC.W	$3D70,$3D8C,$3DA7,$3DC1,$3DDB,$3DF5
	DC.W	$3E0E,$3E26,$3E3E,$3E55,$3E6B,$3E81
	DC.W	$3E96,$3EAB,$3EBF,$3ED2,$3EE5,$3EF7
	DC.W	$3F09,$3F1A,$3F2B,$3F3A,$3F4A,$3F58
	DC.W	$3F66,$3F74,$3F80,$3F8C,$3F98,$3FA3
	DC.W	$3FAD,$3FB7,$3FC0,$3FC9,$3FD1,$3FD8
	DC.W	$3FDF,$3FE5,$3FEA,$3FEF,$3FF3,$3FF7
	DC.W	$3FFA,$3FFC

*****************************************************************************
*		ROUTINE CREA OFFSET PER POSIZIONI Y DELLA PIC
*****************************************************************************

	cnop	0,4
makeoffy:
	lea	offsety,a0
	moveq	#0,d0
	move.w	#ScreenY-1,d1
.loopoffy:
	move.w	d0,(a0)+
	add.w	#ScreenX/8,d0
	dbra	d1,.loopoffy
	rts

*****************************************************************************
*		ROUTINE CREA TABELLA PROSPETTIVA Z PRECALCOLATA
*****************************************************************************

	cnop	0,4
maketabz:
	lea	tabz,a0
	move.l	#2^16*512,d0		; d0=Zo in 16.16
	move.l	#-511+512,d1		; d1=z+Zo
	move.l	#32768+511-1,d7		; how many z
.looptabz:
	move.l	d0,d3			; d3.l=dividend
	divu.l	d1,d3			; d3.l=2^16*512/(z+Zo)
	move.l	d3,(a0)+
	addq.l	#1,d1			; next z
	cmp.l	d1,d7
	bne.s	.looptabz
	rts

*****************************************************************************
*			ROUTINE CREA CUBO DI PUNTI
*****************************************************************************

PLine	= 5			; num points on 1 line
PStep	= 10			; pixel distance
PDim	= PStep*(PLine-1)/2
PointsObj = 2*(PLine^2)+2*PLine*(PLine-2)+2*((PLine-2)^2)

	cnop	0,4
makecube:
	lea	BuffPointsXYZ,a0

	move.w	#-PDim,d0
	move.w	#-PDim,d1
	move.w	#-PDim,d2	; -z=costant
	move.w	#PLine-1,d7
.mkc1	move.w	#PLine-1,d6
.mkc2	movem.w	d0-d2,(a0)
	addq.w	#3*2,a0
	add.w	#PStep,d0
	dbra	d6,.mkc2
	move.w	#-PDim,d0
	add.w	#PStep,d1
	dbra	d7,.mkc1

	move.w	#-PDim,d0
	move.w	#-PDim,d1
	move.w	#PDim,d2	; z=costant
	move.w	#PLine-1,d7
.mkc3	move.w	#PLine-1,d6
.mkc4	movem.w	d0-d2,(a0)
	addq.w	#3*2,a0
	add.w	#PStep,d0
	dbra	d6,.mkc4
	move.w	#-PDim,d0
	add.w	#PStep,d1
	dbra	d7,.mkc3

	move.w	#-PDim,d0	; -x=costant
	move.w	#-PDim,d1
	move.w	#-PDim+PStep,d2
	move.w	#PLine-1,d7
.mkc5	move.w	#PLine-3,d6
.mkc6	movem.w	d0-d2,(a0)
	addq.w	#3*2,a0
	add.w	#PStep,d2
	dbra	d6,.mkc6
	move.w	#-PDim+PStep,d2
	add.w	#PStep,d1
	dbra	d7,.mkc5

	move.w	#PDim,d0	; x=costant
	move.w	#-PDim,d1
	move.w	#-PDim+PStep,d2
	move.w	#PLine-1,d7
.mkc7	move.w	#PLine-3,d6
.mkc8	movem.w	d0-d2,(a0)
	addq.w	#3*2,a0
	add.w	#PStep,d2
	dbra	d6,.mkc8
	move.w	#-PDim+PStep,d2
	add.w	#PStep,d1
	dbra	d7,.mkc7

	move.w	#-PDim+PStep,d0
	move.w	#-PDim,d1	; -y=costant
	move.w	#-PDim+PStep,d2
	move.w	#PLine-3,d7
.mkc9	move.w	#PLine-3,d6
.mkc10	movem.w	d0-d2,(a0)
	addq.w	#3*2,a0
	add.w	#PStep,d2
	dbra	d6,.mkc10
	move.w	#-PDim+PStep,d2
	add.w	#PStep,d0
	dbra	d7,.mkc9

	move.w	#-PDim+PStep,d0
	move.w	#PDim,d1	; y=costant
	move.w	#-PDim+PStep,d2
	move.w	#PLine-3,d7
.mkc11	move.w	#PLine-3,d6
.mkc12	movem.w	d0-d2,(a0)
	addq.w	#3*2,a0
	add.w	#PStep,d2
	dbra	d6,.mkc12
	move.w	#-PDim+PStep,d2
	add.w	#PStep,d0
	dbra	d7,.mkc11

	rts

*****************************************************************************
*		ROUTINE CHE FA LE COPPERLIST ORIZZONTALI
*****************************************************************************

LINECOP:
	lea	TabellaColori(PC),a0
	lea	FineTabColori(PC),a3
	lea	EffInCop,a1		; Indirizzo barra orizzontale 1
	lea	EffInCop2,a2		; Indirizzo barra orizzontale 2
	moveq	#54-1,d3		; Numero di colori orizzontali
	addq.l	#2,ColBarraAltOffset	; Barra bassa - scorr. colori
					; verso sinistra
	subq.l	#2,ColBarraBassOffset	; Barra alta - scorrimento colori
					; verso destra
	move.l	ColBarraAltOffset(PC),d0	; Start Offset (1)
	add.l	d0,a0		; trova il colore giusto nella tabella colori
				; secondo l'offset attuale
	cmp.w	#-1,(a0)	; siamo alla fine della tabella? (indicata
				; con un dc.w -1)
	bne.s	CSalta		; se no, vai avanti
	clr.l	ColBarraAltOffset	; altrimenti riparti
	lea	TabellaColori(PC),a0	; dal primo colore
CSalta:
	move.l	ColBarraBassOffset(PC),d1	; Start Offset (2)
	sub.l	d1,a3				; trova il colore giusto
	cmp.w	#-1,-(a3)		; siamo alla fine della tabella
	bne.s	MettiColori		; se non ancora vai avanti
	move.l	#FineTabColori-TabellaColori,ColBarraBassOffset ; altrimenti
					; fai ripartire dalla fine della
					; tabella (dato che questa barra
					; scorre all'indietro!)
	lea	FineTabColori-2(PC),a3
MettiColori:
	addq.w	#2,a1		; salta il dc.w $180
	addq.w	#2,a2		; salta il dc.w $180
	move.w	(a0)+,(a1)+	; Immetti il colore in coplist (barra1)
	move.w	(a3),(a2)+	; Immetti il col. nella barra 2

	cmp.w	#-1,(a0)	; siamo alla fine della tabella colori? (bar1)
	bne.s	NonFine		; se non ancora vai avanti
	lea 	TabellaColori(PC),a0	; altrimenti riparti da capo (bar1)
NonFine:
	cmp.w	#-1,-(a3)	; siamo all'inizio della tab colori? (bar2)
	bne.s	NonFine2	; se non ancora vai avanti
	lea 	FineTabColori-2(PC),a3	; altrimenti riparti dalla fine (bar2)
NonFine2:
	dbra	d3,MettiColori
	rts

ColBarraAltOffset:
	dc.l	0

ColBarraBassOffset:
	dc.l	0

	dc.w 	-1	; fine tabella
TabellaColori:
	DC.W	$F0F,$F0E,$F0D,$F0C,$F0B,$F0A,$F09,$F08,$F07,$F06
	DC.W	$F05,$F04,$F03,$F02,$F01,$F00,$F10,$F20,$F30,$F40
	DC.W	$F50,$F60,$F70,$F80,$F90,$FA0,$FB0,$FC0,$FD0,$FE0
	DC.W	$FF0,$EF0,$DF0,$CF0,$BF0,$AF0,$9F0,$8F0,$7F0,$6F0
	DC.W	$5F0,$4F0,$3F0,$2F0,$1F0,$0F0,$0F1,$0F2,$0F3,$0F4
	DC.W	$0F5,$0F6,$0F7,$0F8,$0F9,$0FA,$0FB,$0FC,$0FD,$0FE
	DC.W	$0FF,$0EF,$0DF,$0CF,$0BF,$0AF,$09F,$08F,$07F,$06F
	DC.W	$05F,$04F,$03F,$02F,$01F,$00F,$10F,$20F,$30F,$40F
	DC.W	$50F,$60F,$70F,$80F,$90F,$A0F,$B0F,$C0F,$D0F,$E0F
FineTabColori:
	dc.w	-1	; fine tabella

*******************************************************************************
;			ROUTINE DI PRINTING TESTO
*******************************************************************************

PRINTATESTO:
	LEA	SCROLLTESTO(PC),A0
	LEA	VUOTO,A3
	MOVEQ	#66-1,D3
.PRINTRIGA:
	MOVEQ	#40-1,D0
.PRINTCHAR2:
	MOVEQ	#0,D2
	MOVE.B	(A0)+,D2
	SUB.B	#$20,D2
	MULU.W	#8,D2
	MOVE.L	D2,A2
	ADD.L	#FONT,A2
	MOVE.B	(A2)+,(A3)
	MOVE.B	(A2)+,40(A3)
	MOVE.B	(A2)+,40*2(A3)
	MOVE.B	(A2)+,40*3(A3)
	MOVE.B	(A2)+,40*4(A3)
	MOVE.B	(A2)+,40*5(A3)
	MOVE.B	(A2)+,40*6(A3)
	MOVE.B	(A2)+,40*7(A3)

	ADDQ.w	#1,A3
	DBRA	D0,.PRINTCHAR2
	ADD.W	#40*7,A3
	DBRA	D3,.PRINTRIGA
	RTS

SCROLLTESTO:
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                  CALL                  "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"     P L A S T I K     D R E A M S      "
	dc.b	"                                        "
	dc.b	"                  B B S                 "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"             +39 41 5732014             "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"           SYSOP IS MRK/X-ZONE          "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"    24 HOURS PER DAY - AMIGA STUFF      "
	dc.b	"   DEMO SCENE ORIENTED - ALL XZN PRODS  "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"   - PLASTIK DREAMS IS X-ZONE'S WHQ -   "
	dc.b	"                                        "
	dc.b	"                                        "

	; pagina 2

	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"  GREETS TO:                            "
	dc.b	"                                        "
	dc.b	" ABYSS - AGRESSIONE - ALONE             "
	dc.b	" AMIGA CIRCLE - BALANCE - CAPSULE       "
	dc.b	" CHAOS AGE - CYDONIA - DEGENERATION     "
	dc.b	" DIGITAL CHAOS - ELVEN - ESSENCE        "
	dc.b	" ETERNALLY - KNB - FENIX CORPORATION    "
	dc.b	" GODS - HAUJOBB - LLFB - METRO          "
	dc.b	" MORBID VISIONS - NETWORK - NIVEL 7     "
	dc.b	" ODRUSBA - QKP - RAM JAM - SOFT ONE     "
	dc.b	" 3LE - TBL - TPD                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	" CODE: MODEM  FONTS: LANCH  MUSIC: AUD  "
	dc.b	"                                        "
	dc.b	"                                        "

	even

*******************************************************************************
;			ROUTINE DI RIMBALZO TESTO
*******************************************************************************

RIMBALZO:
	lea	BPLPOINTERStesto,a1
	move.w	2(a1),d0
	swap	d0
	move.w	6(a1),d0
	addq.l	#8,RIMBALZOPUNTA
	move.l	RIMBALZOPUNTA(PC),a0
	cmp.l	#FINERIMBALZO-4,a0
	bne.s	NOSTART
	move.l	#RIMBALZOTABELLA-4,RIMBALZOPUNTA

NOSTART:
	move.l	(a0),d1
	sub.l	d1,d0
	lea	BPLPOINTERStesto,a1

	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	rts

RIMBALZOPUNTA:
	dc.l	RIMBALZOTABELLA-4

RIMBALZOTABELLA:
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0

	dc.l	-40,-40,-40,-40,-40,-40,-40,-40,-40
	dc.l	-40,-40,-2*40,-2*40
	dc.l	-2*40,-2*40,-2*40,-2*40,-2*40
	dc.l	-3*40,-3*40,-3*40,-3*40,-3*40			; acceleriamo
	dc.l	-3*40,-3*40,-3*40,-3*40,-3*40
	dc.l	-4*40,-4*40,-4*40,-4*40,-4*40
	dc.l	-4*40,-4*40,-4*40,-4*40,-4*40
	dc.l	-4*40,-4*40,-4*40,-4*40,-4*40

	dc.l	-5*40
	dc.l	-5*40,-5*40,-5*40,-5*40,-5*40
	dc.l	-5*40,-5*40,-5*40,-5*40,-5*40
	dc.l	-5*40,-5*40,-5*40,-5*40,-5*40
	dc.l	-5*40,-5*40,-5*40,-5*40,-5*40
	dc.l	-5*40,-5*40,-5*40,-5*40,-5*40
	dc.l	-5*40,-5*40,-5*40,-5*40,-5*40
	dc.l	-5*40,-5*40,-5*40,-5*40,-5*40
	dc.l	-5*40,-5*40,-5*40,-5*40,-5*40
	dc.l	-5*40,-5*40,-5*40,-5*40,-5*40
	dc.l	-5*40,-5*40,-5*40,-5*40,-5*40
	dc.l	-5*40,-5*40,-5*40,-5*40,-5*40

	dc.l	-4*40,-4*40,-4*40,-4*40,-4*40
	dc.l	-4*40,-4*40,-4*40,-4*40,-4*40
	dc.l	-4*40,-4*40,-4*40,-4*40,-4*40
	dc.l	-3*40,-3*40,-3*40,-3*40,-3*40
	dc.l	-3*40,-3*40,-3*40,-3*40,-3*40
	dc.l	-2*40,-2*40,-2*40,-2*40,-2*40			; deceleriamo
	dc.l	-2*40,-2*40,-40,-40
	dc.l	-40,-40,-40,-40,-40,-40,-40,-40,-40,0,0,0,0,0	; in cima

	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0

	dc.l	0,0,40,40,40,40,40,40,40,40,40 			; in cima
	dc.l	40,40,2*40,2*40
	dc.l	2*40,2*40,2*40,2*40,2*40			; acceleriamo
	dc.l	3*40,3*40,3*40,3*40,3*40
	dc.l	3*40,3*40,3*40,3*40,3*40
	dc.l	4*40,4*40,4*40,4*40,4*40
	dc.l	4*40,4*40,4*40,4*40,4*40
	dc.l	4*40,4*40,4*40,4*40,4*40

	dc.l	5*40
	dc.l	5*40,5*40,5*40,5*40,5*40
	dc.l	5*40,5*40,5*40,5*40,5*40
	dc.l	5*40,5*40,5*40,5*40,5*40
	dc.l	5*40,5*40,5*40,5*40,5*40
	dc.l	5*40,5*40,5*40,5*40,5*40
	dc.l	5*40,5*40,5*40,5*40,5*40
	dc.l	5*40,5*40,5*40,5*40,5*40
	dc.l	5*40,5*40,5*40,5*40,5*40
	dc.l	5*40,5*40,5*40,5*40,5*40
	dc.l	5*40,5*40,5*40,5*40,5*40
	dc.l	5*40,5*40,5*40,5*40,5*40

	dc.l	4*40,4*40,4*40,4*40,4*40
	dc.l	4*40,4*40,4*40,4*40,4*40
	dc.l	4*40,4*40,4*40,4*40,4*40
	dc.l	3*40,3*40,3*40,3*40,3*40
	dc.l	3*40,3*40,3*40,3*40,3*40
	dc.l	2*40,2*40,2*40,2*40,2*40			; deceleriamo
	dc.l	2*40,2*40,40,40
	dc.l	40,40,40,40,40,40,40,40,40,0,0,0,0,0,0,0	; in fondo

FINERIMBALZO:
	dc.l	0

*******************************************************************************
;				ROUTINE MUSICALE
*******************************************************************************

fade  = 0
jump = 0
system = 1
CIA = 1
exec = 1
opt020 = 0
use = $2009110

	include	"play.s"	; La routine vera e propria!

	Section	modulozzo,DATA
P61_DATA:
	incbin	"P61.mod"	; Compresso

	Section	smp,BSS_C
SAMPLES:
	ds.b	3488		; lunghezza riportata dal p61con

;=============================================================================

	cnop	0,8
	SECTION	GRAPHIC,DATA_C

COPPERLIST:
	dc.w	$8E,$2c81		; DiwStrt - window start 
	dc.w	$90,$2cc1		; DiwStop - window stop
	dc.w	$92,$38			; DdfStrt - data fetch start
	dc.w	$94,$d0			; DdfStop - data fetch stop
	dc.w	$104,0			; BplCon2 - priority register
;	dc.w	$106,$c00		; BplCon3
;	dc.w	$10c,$11		; BplCon4
;	dc.w	$1fc,0			; burst 64 bit
BplCon1:
	dc.w	$102,0			; BplCon1 - scroll register
	dc.w	$108,0			; Bpl1Mod - modulo pl. dispari
	dc.w	$10a,0			; Bpl2Mod - modulo pl. pari

BPLPOINTERS:
	dc.w	$e0,0,$e2,0		; 1 bitplane
BPLPOINTERStesto:
	dc.w	$e4,0,$e6,0		; 2 bitplane (testo)


	dc.w	$180,0,$182,$ddd,$184,$bbf,$186,$bbf

	dc.w	$100,$200		; 0 bitplanes
	dc.w	$2d01,$FFFE		; Wait linea $29
EffInCop2:
	dcb.l	54,$1800000		; 54 Color0 di seguito, che ogni 8
					; pixel in avanti riempiono la linea

	dc.w	$2a01,$FFFE		; Wait linea $2a
	dc.w	$100,%0010001000000001	; BPLCON0 - 1 bitplane LOWRES
	dc.w	$180,0			; Color0 nero


	dc.w	$FFDF,$FFFE		; Wait speciale per andare in zona PAL

	dc.w	$2A01,$FFFE		; Attendi la linea $2a+$ff
	dc.w	$100,$200		; 0 bitplanes
EffInCop:
	dcb.l	54,$1800000		; 54 Color0 di seguito, che ogni8
					; pixel in avanti riempiono la linea

	dc.w	$2B07,$FFFE		; Wait linea $ff+$2b
	dc.w	$180,0			; Color0 nero

	dc.w	$ffff,$fffe
	
*****************************************************************************
*				PICTURE
*****************************************************************************

	cnop	0,8
	SECTION	planarpic,BSS_C
	ds.b	40*256
Picture:
	ds.b	ScreenX*ScreenY/8*2

	Section	FontiDelClitunno,DATA
FONT:
	incbin	"prova.fnt"

*****************************************************************************
*				USER MEMORY
*****************************************************************************

	cnop	0,8
	SECTION	fastram,BSS

tabz:
	ds.l	32768+511
offsety:
	ds.w	ScreenY

BuffPointsXYZ:
	ds.w	PointsObj*3
PointsXYZ:
	ds.w	PointsObj*3
PointsXY:
	ds.w	PointsObj*2

dax	= 2
day	= 3
daz	= 4
angles		ds.w	3
xyzcosta	ds.w	9

clrreg		ds.l	15
oldsp		ds.l	1

	Section	AreaVuota,BSS_C
VUOTO:
	ds.b	40*512
	ds.b	1000

	END

