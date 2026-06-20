
	Section Mycode,CODE_C

START
	JMP RUN(PC)

;
;  Hardware Regs.......
;
custom	EQU   $dff000

bltddat	EQU   $000
dmaconr	EQU   $002
vposr	EQU   $004
vhposr	EQU   $006
dskdatr	EQU   $008
joy0dat	EQU   $00A
joy1dat	EQU   $00C
clxdat	EQU   $00E

adkconr	EQU   $010
pot0dat	EQU   $012
pot1dat	EQU   $014
potgor	EQU   $016
serdatr	EQU   $018
dskbytr	EQU   $01A
intenar	EQU   $01C
intreqr	EQU   $01E

dskpt	EQU   $020
dsklen	EQU   $024
dskdat	EQU   $026
refptr	EQU   $028
vposw	EQU   $02A
vhposw	EQU   $02C
copcon	EQU   $02E
serdat	EQU   $030
serper	EQU   $032
potgo	EQU   $034
joytest	EQU   $036
strequ	EQU   $038
strvbl	EQU   $03A
strhor	EQU   $03C
strlong	EQU   $03E

bltcon0	EQU   $040
bltcon1	EQU   $042
bltafwm	EQU   $044
bltalwm	EQU   $046
bltcpth	EQU   $048
bltcptl EQU   $04A
bltbpth	EQU   $04C
bltbptl EQU   $04E
bltapth	EQU   $050
bltaptl EQU   $052
bltdpth	EQU   $054
bltdptl EQU   $056
bltsize	EQU   $058

bltcmod	EQU   $060
bltbmod	EQU   $062
bltamod	EQU   $064
bltdmod	EQU   $066

bltcdat	EQU   $070
bltbdat	EQU   $072
bltadat	EQU   $074

dsksync	EQU   $07E

cop1lc	EQU   $080
cop2lc	EQU   $084
copjmp1	EQU   $088
copjmp2	EQU   $08A
copins	EQU   $08C
diwstrt	EQU   $08E
diwstop	EQU   $090
ddfstrt	EQU   $092
ddfstop	EQU   $094
dmacon	EQU   $096
clxcon	EQU   $098
intena	EQU   $09A
intreq	EQU   $09C
adkcon	EQU   $09E
aud0lch	equ	$0a0
aud0lcl	equ	$0a2
aud0len	equ	$0a4
aud0per	equ	$0a6
aud0vol	equ	$0a8
aud0dat	equ	$0aa
aud1lch	equ	$0b0
aud1lcl	equ	$0b2
aud1len	equ	$0b4
aud1per	equ	$0b6
aud1vol	equ	$0b8
aud1dat	equ	$0ba
aud2lch	equ	$0c0
aud2lcl	equ	$0c2
aud2len	equ	$0c4
aud2per	equ	$0c6
aud2vol	equ	$0c8
aud2dat	equ	$0ca
aud3lch	equ	$0d0
aud3lcl	equ	$0d2
aud3len	equ	$0d4
aud3per	equ	$0d6
aud3vol	equ	$0d8
aud3dat	equ	$0da

bpl1pth	EQU   $0E0
bpl1ptl	EQU   $0E2
bpl2pth	EQU   $0E4
bpl2ptl	EQU   $0E6
bpl3pth	EQU   $0E8
bpl3ptl	EQU   $0EA
bpl4pth	EQU   $0EC
bpl4ptl	EQU   $0EE
bpl5pth	EQU   $0F0
bpl5ptl	EQU   $0F2
bpl6pth	EQU   $0F4
bpl6ptl	EQU   $0F6

bplcon0	EQU   $100
bplcon1	EQU   $102
bplcon2	EQU   $104
bpl1mod	EQU   $108
bpl2mod	EQU   $10A

bpldat	EQU   $110

spr0pth	EQU   $120
spr0ptl EQU   $122
spr1pth EQU   $124
spr1ptl EQU   $126
spr2pth	EQU   $128
spr2ptl EQU   $12A
spr3pth EQU   $12C
spr3ptl EQU   $12E
spr4pth	EQU   $130
spr4ptl EQU   $132
spr5pth EQU   $134
spr5ptl EQU   $136
spr6pth	EQU   $138
spr6ptl EQU   $13A
spr7pth EQU   $13C
spr7ptl EQU   $13E

spr0pos	EQU   $140
spr1pos	EQU   $148
spr2pos EQU   $150
spr3pos EQU   $158
spr4pos EQU   $160
spr5pos EQU   $168
spr6pos EQU   $170
spr7pos EQU   $178

spr0ctl	EQU   $142
spr1ctl	EQU   $14A
spr2ctl EQU   $152
spr3ctl EQU   $15A
spr4ctl EQU   $162
spr5ctl EQU   $16A
spr6ctl EQU   $172
spr7ctl EQU   $17A

spr0data EQU  $144
spr1data EQU  $14c
spr2data EQU  $154
spr3data EQU  $15c
spr4data EQU  $164
spr5data EQU  $16c
spr6data EQU  $174
spr7data EQU  $17c


spr0datb EQU  $146
spr1datb EQU  $14e
spr2datb EQU  $156
spr3datb EQU  $15e
spr4datb EQU  $166
spr5datb EQU  $16e
spr6datb EQU  $176
spr7datb EQU  $17e

col0	EQU   $180
col1 	EQU   $182
col2	EQU   $184
col3    EQU   $186
col4	EQU   $188
col5	equ   $18a
col6	equ   $18c
col7	equ   $18e
col8	EQU   $190
col9	equ   $192
col10	equ   $194
col11	equ   $196
col12	equ   $198
col13	equ   $19a
col14	equ   $19c
col15	equ   $19e
col16   EQU   $1A0	
col17	equ	$1a2
col18	equ	$1a4
col19	equ	$1a6
col20	equ	$1a8
col21	equ	$1aa
col22	equ 	$1ac
col23	equ	$1ae
col24	equ	$1b0
col25	equ	$1b2
col26	equ	$1b4
col27	equ	$1b6
col28	equ	$1b8
col29	equ	$1ba
col30	equ	$1bc
col31	equ	$1be

;
;Cias....
;
ciaa 	equ 	$bfe001
ciab	equ	$bfd000

pra	EQU	$0000
prb	EQU	$0100
ddra	EQU	$0200
ddrb	EQU	$0300
talo	EQU	$0400
tahi	EQU	$0500
tblo	EQU	$0600
tbhi	EQU	$0700
todlow	EQU	$0800
todmid	EQU	$0900
todhi	EQU	$0A00
ttsp	EQU	$0C00
icr	EQU	$0D00
cra	EQU	$0E00
crb	EQU	$0F00

;
;Copper Intruction Macros...
;
; Cmove Val,Reg
; Cwait X,Y
; Cmwt  X,Y,XM,YM  (7th bit of YM is clear then waits for Blitter
;		    i.e. There's no mask for y bit 7		 )
; Cskip X,Y  	   (Skip next com if beam past X,Y)
; Cmskp X,Y,XM,YM  (Same as Cmwt but for Skip...)
;

Cmove	MACRO
	dc.w \2,\1
	ENDM
		
Cwait	MACRO
	dc.w \2<<8!\1!1,$fffe
	ENDM

Cmwt	MACRO
	dc.w \2<<8!\1!1,(\4<<8!\3)&$fffe	
	ENDM

Cskip 	MACRO
	dc.w \2<<8!\1!1,$ffff
	ENDM

Cmskp	MACRO
	DC.W \2<<8!\1!1,\4<<8!\3!1
	ENDM

;
;Blitter macros...
;

Blitwait MACRO
bw_\@	btst #14,dmaconr(a5)
	bne.s bw_\@
	ENDM

Nomask	MACRO
	move #$ffff,bltafwm(a5)
	move #$ffff,bltalwm(a5)
	ENDM
;
;Misc Macros...
;

CatchVB MACRO
vb1_\@:
	btst #0,vposr+1(a5)
	beq.s vb1_\@
vb2_\@:
	btst #0,vposr+1(a5)
	bne.s vb2_\@
	ENDM


*
* Sine Table of the form {16384*sin(x/512*2PI):x=0,1,...,511} Tablesize=1K
* Note-Angles are in 512ths of 2PI Radians!
* ( ^ Only Sailors use degrees.... )
* So 90Deg is at Word 128 , 180Deg is at Word 256 etc...
*
sinetab:
 dc.w $0,$C9,$192,$25B,$324,$3ED,$4B5,$57E,$646,$70E,$7D6,$89D,$964,$A2B,$AF1,$BB7,$C7C,$D41,$E06,$ECA,$F8D,$1050,$1112,$11D3,$1294,$1354,$1413,$14D2,$1590,$164C,$1709,$17C4
 dc.w $187E,$1937,$19EF,$1AA7,$1B5D,$1C12,$1CC6,$1D79,$1E2B,$1EDC,$1F8C,$203A,$20E7,$2193,$223D,$22E7,$238E,$2435,$24DA,$257E,$2620,$26C1,$2760,$27FE,$289A,$2935,$29CE,$2A65,$2AFB,$2B8F,$2C21,$2CB2
 dc.w $2D41,$2DCF,$2E5A,$2EE4,$2F6C,$2FF2,$3076,$30F9,$3179,$31F8,$3274,$32EF,$3368,$33DF,$3453,$34C6,$3537,$35A5,$3612,$367D,$36E5,$374B,$37B0,$3812,$3871,$38CF,$392B,$3984,$39DB,$3A30,$3A82,$3AD3
 dc.w $3B21,$3B6D,$3BB6,$3BFD,$3C42,$3C85,$3CC5,$3D03,$3D3F,$3D78,$3DAF,$3DE3,$3E15,$3E45,$3E72,$3E9D,$3EC5,$3EEB,$3F0F,$3F30,$3F4F,$3F6B,$3F85,$3F9C,$3FB1,$3FC4,$3FD4,$3FE1,$3FEC,$3FF5,$3FFB,$3FFF
 dc.w $4000,$3FFF,$3FFB,$3FF5,$3FEC,$3FE1,$3FD4,$3FC4,$3FB1,$3F9C,$3F85,$3F6B,$3F4F,$3F30,$3F0F,$3EEB,$3EC5,$3E9D,$3E72,$3E45,$3E15,$3DE3,$3DAF,$3D78,$3D3F,$3D03,$3CC5,$3C85,$3C42,$3BFD,$3BB6,$3B6D
 dc.w $3B21,$3AD3,$3A82,$3A30,$39DB,$3984,$392B,$38CF,$3871,$3812,$37B0,$374B,$36E5,$367D,$3612,$35A5,$3537,$34C6,$3453,$33DF,$3368,$32EF,$3274,$31F8,$3179,$30F8,$3076,$2FF2,$2F6C,$2EE4,$2E5A,$2DCF
 dc.w $2D41,$2CB2,$2C21,$2B8F,$2AFB,$2A65,$29CE,$2935,$289A,$27FE,$2760,$26C1,$2620,$257E,$24DA,$2435,$238E,$22E7,$223D,$2193,$20E7,$203A,$1F8C,$1EDC,$1E2B,$1D79,$1CC6,$1C12,$1B5D,$1AA7,$19EF,$1937
 dc.w $187E,$17C4,$1709,$164C,$1590,$14D2,$1413,$1354,$1294,$11D3,$1112,$1050,$F8D,$ECA,$E06,$D41,$C7C,$BB7,$AF1,$A2B,$964,$89D,$7D6,$70E,$646,$57E,$4B5,$3ED,$324,$25B,$192,$C9
 dc.w $0,$FF37,$FE6E,$FDA5,$FCDC,$FC13,$FB4B,$FA82,$F9BA,$F8F2,$F82A,$F763,$F69C,$F5D5,$F50F,$F449,$F384,$F2BF,$F1FA,$F136,$F073,$EFB0,$EEEE,$EE2D,$ED6C,$ECAC,$EBED,$EB2E,$EA70,$E9B4,$E8F7,$E83C
 dc.w $E782,$E6C9,$E611,$E559,$E4A3,$E3EE,$E33A,$E287,$E1D5,$E124,$E074,$DFC6,$DF19,$DE6D,$DDC3,$DD19,$DC72,$DBCB,$DB26,$DA82,$D9E0,$D93F,$D8A0,$D802,$D766,$D6CB,$D632,$D59B,$D505,$D471,$D3DF,$D34E
 dc.w $D2BF,$D231,$D1A6,$D11C,$D094,$D00E,$CF8A,$CF07,$CE87,$CE08,$CD8C,$CD11,$CC98,$CC21,$CBAD,$CB3A,$CAC9,$CA5B,$C9EE,$C983,$C91B,$C8B5,$C850,$C7EE,$C78F,$C731,$C6D5,$C67C,$C625,$C5D0,$C57E,$C52D
 dc.w $C4DF,$C493,$C44A,$C403,$C3BE,$C37B,$C33B,$C2FD,$C2C1,$C288,$C251,$C21D,$C1EB,$C1BB,$C18E,$C163,$C13B,$C115,$C0F1,$C0D0,$C0B1,$C095,$C07B,$C064,$C04F,$C03C,$C02C,$C01F,$C014,$C00B,$C005,$C001
 dc.w $C000,$C001,$C005,$C00B,$C014,$C01F,$C02C,$C03C,$C04F,$C064,$C07B,$C095,$C0B1,$C0D0,$C0F1,$C115,$C13B,$C163,$C18E,$C1BB,$C1EB,$C21D,$C251,$C288,$C2C1,$C2FD,$C33B,$C37B,$C3BE,$C403,$C44A,$C493
 dc.w $C4DF,$C52D,$C57E,$C5D0,$C625,$C67C,$C6D5,$C731,$C78F,$C7EE,$C850,$C8B5,$C91B,$C983,$C9EE,$CA5B,$CAC9,$CB3A,$CBAD,$CC21,$CC98,$CD11,$CD8C,$CE08,$CE87,$CF08,$CF8A,$D00E,$D094,$D11C,$D1A6,$D231
 dc.w $D2BF,$D34E,$D3DF,$D471,$D505,$D59B,$D632,$D6CB,$D766,$D802,$D8A0,$D93F,$D9E0,$DA82,$DB26,$DBCB,$DC72,$DD19,$DDC3,$DE6D,$DF19,$DFC6,$E074,$E124,$E1D5,$E287,$E33A,$E3EE,$E4A3,$E559,$E611,$E6C9
 dc.w $E782,$E83C,$E8F7,$E9B4,$EA70,$EB2E,$EBED,$ECAC,$ED6C,$EE2D,$EEEE,$EFB0,$F073,$F136,$F1FA,$F2BF,$F384,$F449,$F50F,$F5D5,$F69C,$F763,$F82A,$F8F2,$F9BA,$FA82,$FB4B,$FC13,$FCDC,$FDA5,$FE6E,$FF37

*Trig Macros and routines...
*All these assume A4 points at Sinetab!!!
*
*Sin Dx	 Takes "angle" in Dx returns 2^14*sin("angle") in Dx

Sin	MACRO
	and.w #$1ff,\1
	lsl.w #1,\1
	move.w (a4,\1.w),\1
	ENDM

* Cos Dx 

Cos	MACRO
	add.w #$80,\1
	sin \1
	ENDM

* Tan Dx

Tan	MACRO
	move \1,-(sp)			;stack \1
	cos \1
	move \1,-(sp)			;stack cos \1
	bne.s notzero_\@	

;division by zero....	
	lea 4(sp),sp			;restore stack
	move #$7fff,\1			;As close to signed infinity as poss!
	bra.s leavez_\@	
	
notzero_\@:

	move 2(sp),\1			;get \1	
	sin \1
	ext.l \1			;extended to a long word
	lsl.l #8,\1
	lsl.l #6,\1			;*16384

	divs (sp),\1			;do the divide
	lea 4(sp),sp			;reset the stack	
		
leavez_\@:
	ENDM
	
;
;trigdiv d? -- divides out the 16384 from the data reg d?
;

trigdiv	MACRO
	lsr.l #8,\1
	lsr.l #6,\1
	ENDM

* Ok thats that , the above are macros ... may need to use these
* in subroutines if mem is tight....
* Tan is a mess ....!! Create a Tantable if not good enough
	
	
Openlib	equ -552
Closelib equ -414			;...Equates for OS calls...
Oslist equ 38
Forbid  equ -132
Permit  equ -138

gfxname	dc.b	"graphics.library",0,0
storelist dc.l  0


RUN:
;-- Close Down the System Set up Bitplanes etc..
;-- This is the Standard Goldfire Setup Routine (C) Goldfire 1990-1991


; neghiamo le coordinate Y:

	lea	pts2+2,a0
	moveq	#8-1,d7		; num. punti
LoopNeg:
	neg.w	(a0)
	addq.w	#2*3,a0
	dbra	d7,LoopNeg

	lea custom,a5
	move.l 4.w,a6
	bset #1,ciaa+pra		;Led Off
	jsr forbid(a6)
	blitwait			;Multitask down so let any Blits end
	lea gfxname,a1
	moveq #0,d0
	jsr openlib(a6)			;open gfxlib
	move.l d0,a1			;Put gfx base addr in a1
	move.l oslist(a1),storelist	;store OS copper addr
	jsr closelib(a6)		;close gfxlib		
	catchVB
	move #$0020,dmacon(a5)		;sprite DMA off
	move #$8640,dmacon(a5)
	move.l	#screen1,d0
	move.w	d0,pl0l
	swap	d0
	move.w	d0,pl0h
	move #$8100,dmacon(a5)
	move #$4020,intena(a5)		;Master & VB off
	move.l $6c.w,oldlev3+2
	move.l #level3,$6c.w
	move #$c010,intena(a5)		;Master & Copper On
	catchVB
	move.l #Copperlist,cop1lc(a5)
	move #$0080,dmacon(a5)
	move #0,copjmp1(a5)
	move #$8080,dmacon(a5)

;-- Main Mouse Waiting Loop

mouse:	btst #6,ciaa+pra
	bne.s mouse	

;-- Tidy up afterwards and quit

	bclr #1,ciaa+pra		;Led On
	move #$7e0,dmacon(a5)		;Dma (incl nasty blit) off
	move.l storelist(pc),cop1lc(a5)
	move #0,copjmp1(a5)
	move #$83e0,dmacon(a5)
	move #$4010,intena(a5)
	move.l oldlev3+2,$6c.w
	move #$c020,intena(a5)
	jsr permit(a6)
	moveq #0,d0
	rts				;Go Home.....

;Level 3 interrupt handler.......
level3:
	movem.l a0-a6/d0-d7,-(sp)
	lea custom,a5
 	btst #4,(intreqr+1)(a5)		;Check for copper IR
 	beq.s notcopper

	bsr	Vector_Routine

	move.w #$10,intreq(a5)		;Clear IR 	
notcopper:
	movem.l (sp)+,a0-a6/d0-d7
oldlev3:
        jmp $0.l 	

Blanksprite dc.w 0,0

;-- Copper List... PAL and 1 bitplanes
Copperlist:
	dc.w diwstrt,$2a81		
	dc.w diwstop,$2ac1
	dc.w ddfstrt,$38
	dc.w ddfstop,$d0		;Normal screen

	dc	$106,0,$1fc,0

	dc.w bpl1mod,0
	dc.w bpl2mod,0
	dc.w bplcon1,0,$1fc,0,$106,0
cols	dc.w col0,0,col1,$FF,col2,$8,col3,$FF
	dc.w bpl1ptl
pl0l	dc.w 0,bpl1pth
pl0h	dc.w 0,bpl2ptl	
pl1l	dc.w 0,bpl2pth
pl1h	dc.w 0
	dc.w bplcon0,$1200		;One planes
	dc.w bplcon2,0			;sprites behind
	dc.w $ffdf,$fffe		;wait for end of NTSC
	dc.w $2b09,$fffe		;first line after screen
	dc.w intreq,$8010		;trigger copper IR
	dc.w $ffff,$fffe		;endless wait

*****************************************************************************
; Okay lets start with nice user-friendly assembler constants for readabilty
*****************************************************************************

OriginDist	=	640
ScreenDist	=	640
SNext_Ob	=	0		;These are offsets in data structure
SXpos		=	4		;these should always be used
SYpos		=	6		;incase of change of structure
SZpos		=	8
SXangle		=	10
SYangle		=	12
SZangle		=	14
SNum_Pts	=	16
SCorner_Pt	=	20	
SFace_Pt	=	24	

*****************************************************************************
;-- Main Loop...
*****************************************************************************

VECTOR_ROUTINE:
	bsr	DoubleBuffer
	bsr	Blitclear
	bsr	Animate
	bsr	Vector_Calculate
	bsr	DrawObjects
	rts
	
*****************************************************************************
; 3D Vector Calculatation Routine by Prophet of Goldfire (C) T.Szirtes 1991
; Features realtime Rotation, Translation, Transformation, HiddenLine Vectors
*****************************************************************************

Vector_Calculate:

;-- Load up our pointers and get relevant data

	move.l	ObjectPointer,a0	;Pointer to Object Data in a0
	move.l	SCorner_Pt(a0),a2	;Pointer to Points in a2
	lea	Screen_Points,a1	;Pointer to Screen POints,a1
	lea	sinetab,a4		;SineTable in a4
	move.l  SNum_Pts(a0),d6
VecLoop

;-- Tidy Up

	moveq.l	#0,d0
	moveq.l	#0,d1
	moveq.l	#0,d2

;-- Rotation about Z Axis :- X2 = X1 COS a - Y1 SIN a, Y2 = Y1 COS a - X1 SIN a

	move SZangle(a0),d5	
	move d5,d4
	sin d4			
	cos d5			
	move (a2),d0		;X pos
	move 2(a2),d1		;Y Pos
	muls d5,d0		;X * cos a
	muls d4,d1		;Y * sin a
	sub.l d1,d0		;subtract to get...
	trigdiv d0		;FINAL X
	
	move (a2),d1		;X pos
	move 2(a2),d2		;Y pos
	muls d4,d1		;X * sin a
	muls d5,d2		;Y * cos a
	add.l d2,d1		;add...
	trigdiv d1		;FINAL Y

;-- Rotation about X Axis :- Y2 = Y1 COS a - Z1 SIN a, Z2 = Z1 COS a + Y1 SIN a

	move SXangle(a0),d5	
	move d5,d4
	sin d4			
	cos d5			

	move 4(a2),d2		;Find Z
	move d1,d7		;X in d0, Y in d7, Z in d2

	muls d5,d1		;Y * cos a
	muls d4,d2		;Z * sin a
	sub.l d2,d1		;subtract to get...
	trigdiv d1		;FINAL Y
	
	move 4(a2),d2		;Find Z
	muls d4,d7		;Y * sin a
	muls d5,d2		;Z * cos a
	add.l d7,d2		;add...
	trigdiv d2		;FINAL Z

;-- Rotation about Y Axis :- Z2 = Z1 COS a - X1 SIN a, X2 = X1 COS a + Z1 SIN a

	move SYangle(a0),d5	
	move d5,d4
	sin d4			
	cos d5			

	move d2,d7
	move d0,d3		;X in d3, Y in d1, Z in d7

	muls d5,d2		;Z * cos a
	muls d4,d3		;X * sin a
	sub.l d2,d3		;subtract to get...
	trigdiv d3		;FINAL Z
	move d3,d2

	muls d4,d7		;Z * sin a
	muls d5,d0		;X * cos a
	add.l d7,d0		;add...
	trigdiv d0		;FINAL Z

;-- Okay lets calculate perspective

	add SZpos(a0),d2	;Add its Zposition

	add #origindist,d2	;Calculate Perspective
	muls #screendist,d0
	muls #screendist,d1
	divs d2,d0
	divs d2,d1

;-- Then lets move it to the right position (Translate)

	add.w	SXpos(a0),d0	;Add Xpos
	add.w	SYpos(a0),d1	;Add Ypos

;- and put it into the list

	move.w	d0,(a1)+
	move.w	d1,(a1)+

;- loop

	add.l	#6,a2		;Next load of points
	dbra	d6,VecLoop

Finished_Points
	rts

*****************************************************************************
; Draw Objects -- This Incorporates the Hidden Line Routine 
*****************************************************************************

DrawObjects:
	move.l	objectpointer,a0
	move.l	SFace_pt(a0),a1		;Pointer to Face Structure
	lea	Screen_Points,a2	;Pointer to Points

HiddenLineLoop
	move	(a1)+,d7		;d7 = number of points
	bmi	NomoreFaces		;if -1 then no more faces

	move.w	(a1),d0			;d0 = Offset to Point 1
	move.w	(a2,d0),d1		;d1 = X1
	move.w	2(a2,d0),d2		;d2 = Y1
	move.w	2(a1),d0		;d0 = Offset to Point 2
	move.w	(a2,d0),d3		;d3 = X2
	move.w	2(a2,d0),d4		;d4 = Y2
	sub.w	d1,d3			;d3 = X21 = X2-X1
	sub.w	d2,d4			;d4 = Y21 = Y2-Y1

	move.w	4(a1),d0		;d0 = Offset to Point 3
	move.w	(a2,d0),d5		;d5 = X3
	move.w	2(a2,d0),d6		;d6 = Y3
	sub.w	d1,d5			;d5 = X31 = X3-X1
	sub.w	d2,d6			;d6 = Y31 = Y3-Y1
					;Phew just enough registers!
					;try doing that on an 8bit!
	muls	d3,d6			;X21*Y31
	muls	d5,d4			;X31*Y21
	sub.l	d4,d6			;subtracted
	bmi	Face_seen		;If its positive we can see it
	addq.w	#2,d7
	add.l	d7,d7
	lea	(a1,d7.w),a1		;Find next face
	bra.s	HiddenLineLoop		;otherwise Loop
	rts
Face_Seen
;-- We now have to load up the registers ready for line drawing
;-- a1 face structure, a2 - points
Face_Seen_Loop
	moveq.l	#0,d0
	moveq.l	#0,d1
	moveq.l	#0,d2
	moveq.l	#0,d3
	move.w	(a1)+,d4		;pointer to Point 1
	move.w	(a1),d5			;pointer to Point 2

	move.w	(a2,d4),d0		;
	move.w	2(a2,d4),d1

	move.w	(a2,d5),d2
	move.w	2(a2,d5),d3
	bsr	linedraw
	dbra	d7,Face_Seen_Loop
	add.w	#2,a1
	jmp	HiddenLineLoop
Nomorefaces
;	move.w	#$FFF,$DFF180
	rts

*****************************************************************************
;-- Animate Routine... Basically add velocities to variables
*****************************************************************************

Animate:
	move.l	ObjectPointer,a0
	move.w ANGLEVX,d0
	add.w d0,SXangle(a0)
	move.w ANGLEVY,d0
	add.w d0,SYangle(a0)
	move.w ANGLEVZ,d0
	add.w d0,SZangle(a0)
	move.w ZVel,d0
	add.w d0,SZpos(a0)
	rts


;-- Data for 3D routine... 

ANGLEVX	dc.w	1
ANGLEVZ	dc.w	4
ANGLEVY dc.w 	2
ZVel	dc.w	0
ObjectPointer dc.l	Object1
screen_Points	dcb.w	90*2
NulObject	dc.l	Object1,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0

*****************************************************************************
;-- 3D Data Structure
;-- Format	dc.l Pointer to nextobject (0 if no more)	0
;		dc.w XPos,YPos,Zpos,Xangle,YAngle,ZAngle	4,6,8,10,12,14
;		dc.l Pointer to Corners				16
;		dc.l Pointer to Faces				20
*****************************************************************************
;Boring Cube
OBJECT1 dc.l 0				;Next Object
	dc.w 160,128,0,0,0,0		;Xpos,Ypos,Zpos,Xa,ya,za
	dc.l 7				;number of pts-1
	dc.l PTS2,FAC2			;Pointer to points/faces

; punti (I valori Y devono essere negati)
pts2:
	dc.w	-50,+50,-50	; P0 (X,Y,Z)
	dc.w	+50,+50,-50	; P1 (X,Y,Z)
	dc.w	+50,-50,-50	; P2 (X,Y,Z)
	dc.w	-50,-50,-50	; P3 (X,Y,Z)
	dc.w	-50,+50,+50	; P4 (X,Y,Z)
	dc.w	+50,+50,+50	; P5 (X,Y,Z)
	dc.w	+50,-50,+50	; P6 (X,Y,Z)
	dc.w	-50,-50,+50	; P7 (X,Y,Z)

fac2: 	dc.w 3,0*4,1*4,2*4,3*4,0*4	;Numberofpoints then points
	dc.w 3,1*4,5*4,6*4,2*4,1*4	;dont forget to repeat first
	dc.w 3,4*4,7*4,6*4,5*4,4*4	;Points are entered clockwise
	dc.w 3,0*4,3*4,7*4,4*4,0*4	;and bloody confusing it is
	dc.w 3,2*4,6*4,7*4,3*4,2*4
	dc.w 3,0*4,4*4,5*4,1*4,0*4
	dc.w -1
;Cool Ship
OBJECT2 dc.l 0				;Next Object
	dc.w 160,128,0,0,0,0		;Xpos,Ypos,Zpos,Xa,ya,za
	dc.l 4 				;number of pts-1
	dc.l PTS1,FAC1			;Pointer to points/faces
pts1:	
	dc.w 0,0,-50
	dc.w 70,0,50
	dc.w 0,30,50
	dc.w -70,0,50
	dc.w 0,-30,50
	
fac1: 	dc.w 2,0*4,1*4,2*4,0*4
	dc.w 2,0*4,2*4,3*4,0*4
	dc.w 2,0*4,4*4,1*4,0*4
	dc.w 2,0*4,3*4,4*4,0*4
	dc.w 3,1*4,4*4,3*4,2*4,1*4
	dc.w -1

*****************************************************************************
;-- Toggle Screen Routine
*****************************************************************************

DoubleBuffer:
	move.l	Scrpt1,a0
	move.l	Scrpt2,a1
	move.l	a0,Scrpt2
	move.l	a1,Scrpt1
	move.l	a1,d0
	move.w	d0,pl0l
	swap	d0
	move.w	d0,pl0h
	rts
Scrpt1	dc.l	Screen1
Scrpt2	dc.l	Screen2

*****************************************************************************
;-- Blit Simple Lines with boundary checking
;-- Input d0,d1,d2,d3 for X1,Y1,X2,Y2    Uses d4+d5 for working
*****************************************************************************
	
linedraw:
	cmp.l	#320,d0
	bgt	BoundFound
	cmp.l	#0,d0
	blt	BoundFound

	cmp.l	#320,d2
	bgt	BoundFound
	cmp.l	#0,d2
	blt	BoundFound

	cmp.l	#256,d1
	bgt	BoundFound
	cmp.l	#0,d1
	blt	BoundFound

	cmp.l	#256,d3
	bgt	BoundFound
	cmp.l	#0,d3
	blt	BoundFound

	move.l	#40,d4
	move.l	scrpt2,a0
	sub	d0,d2
	bmi	xneg
	sub	d1,d3
	bmi	yneg
	cmp	d3,d2
	bmi	ygtx
	moveq.l	#(4*4)!1,d5
	bra	lineagain
ygtx:	exg	d2,d3
	moveq.l	#(0*4)!1,d5
	bra	lineagain
yneg	neg	d3
	cmp.w	d3,d2
	bmi	ynygtx
	moveq.l	#(6*4)!1,d5
	bra	lineagain
ynygtx	exg	d2,d3
	moveq.l	#(1*4)!1,d5
	bra	lineagain
xneg	neg	d2
	sub	d1,d3
	bmi	xyneg
	cmp	d3,d2
	bmi	xnygtx
	moveq.l	#(5*4)!1,d5
	bra	lineagain
xnygtx	exg	d2,d3
	moveq.l	#(2*4)!1,d5
	bra	lineagain
xyneg	neg	d3
	cmp	d3,d2
	bmi	xynygtx
	moveq.l	#(7*4)!1,d5
	bra	lineagain
xynygtx	exg	d2,d3
	moveq.l	#(3*4)!1,d5
lineagain:
	mulu	d4,d1
	ror.l	#4,d0	
	add	d0,d0
	add.l	d1,a0
	add	d0,a0
	swap	d0
	or.w	#$BFA,d0
	lsl.w	#2,d3
	add	d2,d2
	move	d2,d1
	lsl	#5,d1
	add	#$42,d1
	blitwait
	move	d3,Bltbmod(A5)
	sub	d2,d3
	ext.l	d3
	move.l	d3,Bltapth(a5)
	bpl	lineover
	or	#$40,d5
lineover:
	move.w	d0,Bltcon0(a5)
	move.w	d5,Bltcon1(a5)
	move.w	d4,Bltcmod(a5)
	move	d4,Bltdmod(a5)
	sub	d2,d3
	move	d3,BltAmod(A5)
	move	#$8000,BltAdat(A5)
	moveq.l	#-1,d5
	move.l	d5,BltAfwm(a5)
	move.l	a0,BltCpth(a5)
	move.l	a0,BltDpth(a5)
	move	d1,Bltsize(a5)
	rts
BoundFound	
	move.w	#$F,$DFF180	
	rts

*****************************************************************************
; Blitter Clear Routine... one bitplane
*****************************************************************************

Blitclear:
	move.w	#$0100,bltcon0(a5)
	move.w	#0,bltcon1(a5)
	move.w	#0,bltdmod(a5)
	move.l	scrpt2,bltdpth(a5)
	move.w	#(256<<6)!20,bltsize(a5)
	blitwait
	rts

*****************************************************************************
; Screens...
*****************************************************************************

screen1: ds.b	40*260*1

screen2: ds.b	40*260*1

