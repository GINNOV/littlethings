;
;                     ********************************
;                      **       3D STARS V1.0      **
;                       ****************************
;
;                          Author: Antonio Martini
;                Hardware support: Simone Rancitelli   
;	      Exit Implemented by: Fabio Ciucci
;                       Assembler: ASM_One V1.0
;
;
;

SPEED = 10             ; velocita' movimento stelle

OldOpenLibrary	= -408
CloseLibrary	= -414

DMASET=	%1000000111000000
;	 -----a-bcdefghij

dmaconr	    EQU	  $002
adkconr	    EQU	  $010
intenar	    EQU	  $01C
intreqr	    EQU	  $01E
copcon	    EQU	  $02E

bltcon0	    EQU	  $040
bltcon1	    EQU	  $042
bltafwm	    EQU	  $044
bltalwm	    EQU	  $046
bltcpt	    EQU	  $048
bltbpt	    EQU	  $04C
bltapt	    EQU	  $050
bltdpt	    EQU	  $054
bltsize	    EQU	  $058

bltcmod	    EQU	  $060
bltbmod	    EQU	  $062
bltamod	    EQU	  $064
bltdmod	    EQU	  $066

bltcdat	    EQU	  $070
bltbdat	    EQU	  $072
bltadat	    EQU	  $074

	SECTION	MAIN,CODE_C

s:
MAINCODE:
	movem.l	d0-d7/a0-a6,-(SP)	; Save registers to stack
	LEA	$DFF000,A5		; CUSTOM REG FOR OFFSETS
	LEA	S(PC),A4		; A4=OFFSET FOR VARIABLES
	move.l	4.w,a6
	LEA	LIBNAME(PC),A1
	JSR	-$198(A6)
	TST.L	D0
	BEQ.W	EXIT
	MOVE.L	D0,A6
	MOVE.L	A6,GFXBASE-S(A4)
	MOVE.L	$22(A6),WBVIEW-S(A4)	; save actual view
	SUBA.L	A1,A1
	JSR	-$DE(A6)	; null loadview for reset
				; AGA OR AAA strange VIDEO modes ...
	JSR	-$10E(A6)	; waitof (if was interlace)
	JSR	-$10E(A6)	; waitof
	move.l	4.w,a6		; get execbase
	JSR	-$84(a6)	; FORBID - DISABLE MULTITASKING
	JSR	-$78(A6)	; DISABLE - DISABLE ALSO INTERRUPTS

	LEA	HEAVYINIT(PC),A5
	JSR	-$1e(a6)		; Execute the code as Exception!

	MOVEA.L	4.w,A6
	JSR	-$7E(A6)		; ENABLE
	JSR	-$8A(A6)		; PERMIT

	MOVE.L	WBVIEW(PC),A1		; OLD WBVIEW IN A1
	MOVE.L	GFXBASE(PC),A6		; GFXBASE IN A6
	JSR	-$DE(A6)		; loadview *fix OLD view
	JSR	-$10E(A6)
	JSR	-$10E(A6)
	MOVE.L	$26(a6),$dff080		; point Sys cop1
	MOVE.L	$32(a6),$dff084		; point Sys cop2
	MOVE.W	D0,$dff088		; START COP 1
	MOVE.L	A6,A1
	move.l	4.w,a6
	jsr	-$19E(a6)		; graphics lib closed
EXIT:
	movem.l	(SP)+,d0-d7/a0-a6	; Restore old registers
	MOVEQ	#0,d0
	RTS

;	FROM HERE NO LAME SYSTEM CALLS =)

HEAVYINIT:
	LEA	S(PC),A4
	LEA	$DFF000,A5
	MOVE.W	2(A5),OLDDMA-S(A4)	; SAVE OLD DMA STATUS
	MOVE.W	$1C(A5),OLDINTENA-S(A4)	; SAVE OLD INTENA STATUS
	MOVE.W	$10(A5),OLDADKCON-S(A4)	; SAVE OLD ADKCON STATUS
	MOVE.W	$1E(A5),OLDINTREQ-S(A4)	; SAVE OLD INTREQ STATUS
	BSET	#15,OLDDMA-S(A4)	; Set the 15th bit of all reg status
	BSET	#15,OLDINTENA-S(A4)	; saved, because when that will be
	BSET	#15,OLDADKCON-S(A4)	; restored the 15th bit must be set
	BSET	#15,OLDINTREQ-S(A4)	; (Is the Set/Clr bit!)
	LEA	$DFF000,A5
	MOVE.L	#$7FFF7FFF,$9A(a5)	; DISABLE INTERRUPTS AND INTREQS
	MOVE.W	#$7FFF,$96(a5)		; DISABLE DMA

	MOVEA.L	4.w,A1
	btst.b	#0,$129(a1)	; Tests for a 68010 or higher Processor
	beq.S	VBRDONE		; is a 68000!!
	dc.l	$4e7a9801	; Movec Vbr,A1 (68010+ instruction)
	move.l  a1,VBRBASE-S(A4)	; Save VbrBase
VBRDONE:


	MOVE.L	VBRBASE(PC),A1
	move.l	$64(a1),OLDINT1-S(A4) ; Sys lev 1 int saved (softint,dskblk)
	move.l	$68(a1),OLDINT2-S(A4) ; Sys lev 2 int saved (I/O,ciaa,int2)
	move.l	$6c(a1),OLDINT3-S(A4) ; Sys lev 3 int saved (coper,vblanc,blit)
	move.l	$70(a1),OLDINT4-S(A4) ; Sys lev 4 int saved (audio)
	move.l	$74(a1),OLDINT5-S(A4) ; Sys lev 5 int saved (rbf,dsksync)
	move.l	$78(a1),OLDINT6-S(A4) ; Sys lev 6 int saved (exter,ciab,inten)


	movem.l	d0-d7/a0-a6,-(Sp)	; Save registers to stack
	bsr.w	START
	movem.l	(sp)+,d0-d7/a0-a6	; restore registers from stack

	move.w	#$8240,$96(a5)		; enable blitter
	btst.b	#6,2(a5)
WaitBlit:				; Wait the end of blitter work
	btst.b	#6,2(a5)
	bne.s	WaitBlit

	MOVE.W	#$7FFF,$96(A5)		; DISABLE ALL DMA
	MOVE.L	#$7FFF7FFF,$9A(A5)	; DISABLE ALL INTERRUPTS & INTREQS

NOCRESTORE:
	MOVE.L	VBRBASE(PC),A1
	MOVE.L	OLDINT1(PC),$64(A1)	; RESTORE Sys LEVEL 1 INTERRUPT
	MOVE.L	OLDINT2(PC),$68(A1)	; RESTORE Sys LEVEL 2 INTERRUPT
	MOVE.L	OLDINT3(PC),$6C(A1)	; RESTORE Sys LEVEL 3 INTERRUPT
	MOVE.L	OLDINT4(PC),$70(A1)	; RESTORE Sys LEVEL 4 INTERRUPT
	MOVE.L	OLDINT5(PC),$74(A1)	; RESTORE Sys LEVEL 5 INTERRUPT
	MOVE.L	OLDINT6(PC),$78(A1)	; RESTORE Sys LEVEL 6 INTERRUPT
	MOVE.W	OLDDMA(PC),$96(A5)	; RESTORE OLD DMA STATUS
	MOVE.W	#$7fff,$9E(a5)
	MOVE.W	OLDADKCON(PC),$9E(A5)	; RESTORE OLD ADKCON STATUS
	MOVE.W	OLDINTREQ(PC),$9C(A5)	; RESTORE OLD INTREQ
	MOVE.W	OLDINTENA(PC),$9A(A5)	; RESTORE OLD INTENA STATUS
	RTE

VBRBASE:		; Pointer to the Vector Base
	dc.l 	0
WBVIEW:			; Sys WorkBench View Address
	DC.L	0
OLDINT1:
	DC.L	0
OLDINT2:
	DC.L	0
OLDINT3:
	DC.L	0
OLDINT4:
	DC.L	0
OLDINT5:
	DC.L	0
OLDINT6:
	DC.L	0
LIBNAME:
	dc.b	'graphics.library',0,0
GFXBASE:		; Pointer to the Graphics Library Base
	dc.l	0
OLDDMA:			; Old DMACON status
	dc.w	0
OLDINTENA:		; Old INTENA status
	dc.w	0
OLDADKCON:		; Old ADKCON status
	DC.W	0
OLDINTREQ:		; Old INTREQ status
	DC.W	0

;			     MAIN PROGRAM


START:
	MOVEM.L	D0-D7/A0-A6,-(A7)	; Put registers on stack


	LEA	$DFF000,A6

	MOVE.W	#$7FFF,$9A(A6)		; Clear interrupt enable

	JSR	Wait_Vert_Blank

	MOVE.W	#$7FFF,$96(A6)		; Clear DMA channels
	MOVE.L	#COPLIST,$80(A6)	; Copper1 start address
	MOVE.W	#DMASET!$8200,$96(A6)	; DMA kontrol data
	MOVE.L	#INTER,$6C.W		; Set interrupt pointer

	MOVE.W	#$7FFF,$9C(A6)		; Clear request
	MOVE.W	#$C020,$9A(A6)		; Interrupt enable

; *******  MAIN ROUTINE ********

init	lea.l	planes-2,a0
	move.w	#-1,(a0)

noblank	tst.w	(a0)
	bmi.s	noblank
	addq.w	#2,a0

	move.l	(a0),d0
	lea.l	$dff000,a6
	
	btst	#6,2(a6)		; attende blitter
wbt00	btst	#6,2(a6)
	bne.s	wbt00

; azzera schermo
	move.l	d0,bltdpt(a6)	
	move.w	#0,bltdmod(a6)
	move.l	#$01000000,bltcon0(a6)
	move.w	#(256<<6)!40,bltsize(a6)

; --------------------------
; PROIEZIONE+CLIPPING STELLE
; --------------------------
; zu = -256
; S  = 2^24

	lea.l	mtk,a6		; ^ tabella proiezione (1/(ze-256))*2^24
	move.w	#160,a2		; Hx	
	move.w	#128,d6		; Hy


	lea.l	star(pc),a0	; ^ dati stelle
	lea.l	dest,a3		; ^ buffer destinazione
	lea.l	colstar,a1

	move.w	#numstars-1,d7	; numero stelle (punti)

	move.w	#$1ff,d4
	move.w	dist,d3
	add.w	#SPEED,d3		; velocita' stelle
	and.w	d4,d3
	move.w	d3,dist

	move.w	#319,a5		; Xmax
	move.w	#255,a4		; Ymax

	move.l	a7,stack
	lea.l	tabella(pc),a7	; ^ tabella Y*40

centr	movem.w	(a0)+,d0-d2	; xe,ye,ze
	sub.w	d3,d2		; velocita'
	and.w	d4,d2		; d4=range movimento

	add.w	d2,d2		; -ze*2
	neg.w	d2		; ze viene effettuata poiche' per errore
				; ho memorizzato la coordinata z 
				; invertita

	move.w	0(a6,d2.w),d5	; Zn

	muls	d5,d0		; xe*Zn
	swap	d0		; d0=d0>>16
	add.w	a2,d0		; xs=Hx+d0

	bmi.s	nvis00		; clipping  orizzontale
	cmp.w	a5,d0
	bgt.s	nvis00

	muls	d5,d1		; ye*Zn
	swap	d1		; d1=d1>>16
	add.w	d6,d1		; ys=Hy+d1

	bmi.s	nvis00		; clipping verticale
	cmp.w	a4,d1
	bge.s	nvis00

	move.w	d2,(a1)+	; colore
	move.w	d0,(a3)+	; x
	lsr.w	#3,d0		; calcola posizione punto in memoria
	add.w	d1,d1
	add.w	0(a7,d1.w),d0
	move.w	d0,(a3)+	; y
nvis00	dbra	d7,centr

	move.l	stack(pc),a7

	move.l	a1,d7
	lea.l	colstar,a1
	sub.l	a1,d7
	lsr.w	#1,d7
	subq.w	#1,d7
	bmi.s	trac00		

; -------------------
; TRACCIAMENTO STELLE
; -------------------

	lea.l	dest,a3			; ^ buffer punti
	move.l	planes,a2		; ^ 1o bitplane
	lea.l	10240*1(a2),a6		; ^ 2o bitplane

; profondita' per selezione luminosita' punto
	move.w	#(-512+170)*2,d3
	move.w	#(-512+170+170)*2,d4

; attesa blitter
	btst	#6,$dff002
wbt10	btst	#6,$dff002
	bne.s	wbt10

trace	move.w	(a1)+,d6	; colore
	move.w	(a3)+,d0	; xs
	move.w	(a3)+,d1	; posizione verticale in bytesy
	not.w	d0

	cmp.w	d3,d6
	ble.s	col1
	cmp.w	d4,d6
	ble.s	col2

; traccia punto in uno dei tre colori a seconda della profondita'
	move.l	a2,a5
	add.w	d1,a5

	bset	d0,(a5)	
	bset	d0,10240(a5)	
	dbra	d7,trace
	bra.s	trac00

col1	bset	d0,0(a2,d1.w)
	dbra	d7,trace
	bra.s	trac00

col2	bset	d0,0(a6,d1.w)
	dbra	d7,trace

; check tasto sinistro mouse
trac00	btst	#6,$bfe001
	bne.w	init

	MOVEM.L	(SP)+,D0-D7/A0-A6
	rts


stack	dc.l	0
dist	dc.w	0	
dist2	dc.w	0	

; TABELLA PROIEZIONE 
	incbin	"CT_TAB"
mtk

; TABELLA Y*40

tabella
	dc.w $0,$28,$50,$78,$A0,$C8,$F0,$118,$140,$168,$190,$1B8
	dc.w $1E0,$208,$230,$258,$280,$2A8,$2D0,$2F8,$320,$348,$370,$398
	dc.w $3C0,$3E8,$410,$438,$460,$488,$4B0,$4D8,$500,$528,$550,$578
	dc.w $5A0,$5C8,$5F0,$618,$640,$668,$690,$6B8,$6E0,$708,$730,$758
	dc.w $780,$7A8,$7D0,$7F8,$820,$848,$870,$898,$8C0,$8E8,$910,$938
	dc.w $960,$988,$9B0,$9D8,$A00,$A28,$A50,$A78,$AA0,$AC8,$AF0,$B18
	dc.w $B40,$B68,$B90,$BB8,$BE0,$C08,$C30,$C58,$C80,$CA8,$CD0,$CF8
	dc.w $D20,$D48,$D70,$D98,$DC0,$DE8,$E10,$E38,$E60,$E88,$EB0,$ED8
	dc.w $F00,$F28,$F50,$F78,$FA0,$FC8,$FF0,$1018,$1040,$1068,$1090,$10B8
	dc.w $10E0,$1108,$1130,$1158,$1180,$11A8,$11D0,$11F8,$1220,$1248,$1270,$1298
	dc.w $12C0,$12E8,$1310,$1338,$1360,$1388,$13B0,$13D8,$1400,$1428,$1450,$1478
	dc.w $14A0,$14C8,$14F0,$1518,$1540,$1568,$1590,$15B8,$15E0,$1608,$1630,$1658
	dc.w $1680,$16A8,$16D0,$16F8,$1720,$1748,$1770,$1798,$17C0,$17E8,$1810,$1838
	dc.w $1860,$1888,$18B0,$18D8,$1900,$1928,$1950,$1978,$19A0,$19C8,$19F0,$1A18
	dc.w $1A40,$1A68,$1A90,$1AB8,$1AE0,$1B08,$1B30,$1B58,$1B80,$1BA8,$1BD0,$1BF8
	dc.w $1C20,$1C48,$1C70,$1C98,$1CC0,$1CE8,$1D10,$1D38,$1D60,$1D88,$1DB0,$1DD8
	dc.w $1E00,$1E28,$1E50,$1E78,$1EA0,$1EC8,$1EF0,$1F18,$1F40,$1F68,$1F90,$1FB8
	dc.w $1FE0,$2008,$2030,$2058,$2080,$20A8,$20D0,$20F8,$2120,$2148,$2170,$2198
	dc.w $21C0,$21E8,$2210,$2238,$2260,$2288,$22B0,$22D8,$2300,$2328,$2350,$2378
	dc.w $23A0,$23C8,$23F0,$2418,$2440,$2468,$2490,$24B8,$24E0,$2508,$2530,$2558
	dc.w $2580,$25A8,$25D0,$25F8,$2620,$2648,$2670,$2698,$26C0,$26E8,$2710,$2738
	dc.w $2760,$2788,$27B0,$27D8,$2800,$2828,$2850,$2878,$28A0,$28C8,$28F0,$2918
	dc.w $2940,$2968,$2990,$29B8,$29E0,$2A08,$2A30,$2A58,$2A80,$2AA8,$2AD0,$2AF8
	dc.w $2B20,$2B48,$2B70,$2B98,$2BC0,$2BE8,$2C10,$2C38,$2C60,$2C88,$2CB0,$2CD8
	dc.w $2D00,$2D28,$2D50,$2D78,$2DA0,$2DC8,$2DF0,$2E18,$2E40,$2E68,$2E90,$2EB8
	dc.w $2EE0,$2F08,$2F30,$2F58,$2F80,$2FA8,$2FD0,$2FF8,$3020,$3048,$3070,$3098
	dc.w $30C0,$30E8,$3110,$3138,$3160,$3188,$31B0,$31D8,$3200,$3228,$3250,$3278
	dc.w $32A0,$32C8,$32F0,$3318,$3340,$3368,$3390,$33B8,$33E0,$3408,$3430,$3458
	dc.w $3480,$34A8,$34D0,$34F8,$3520,$3548,$3570,$3598,$35C0,$35E8,$3610,$3638
	dc.w $3660,$3688,$36B0,$36D8,$3700,$3728,$3750,$3778,$37A0,$37C8,$37F0,$3818
	dc.w $3840,$3868,$3890,$38B8,$38E0,$3908,$3930,$3958,$3980,$39A8,$39D0,$39F8
	dc.w $3A20,$3A48,$3A70,$3A98,$3AC0,$3AE8,$3B10,$3B38,$3B60,$3B88,$3BB0,$3BD8
	dc.w $3C00,$3C28,$3C50,$3C78,$3CA0,$3CC8,$3CF0,$3D18,$3D40,$3D68,$3D90,$3DB8
	dc.w $3DE0,$3E08,$3E30,$3E58,$3E80,$3EA8,$3ED0,$3EF8,$3F20,$3F48,$3F70,$3F98
	dc.w $3FC0,$3FE8,$4010,$4038,$4060,$4088,$40B0,$40D8,$4100,$4128,$4150,$4178
	dc.w $41A0,$41C8,$41F0,$4218,$4240,$4268,$4290,$42B8,$42E0,$4308,$4330,$4358
	dc.w $4380,$43A8,$43D0,$43F8,$4420,$4448,$4470,$4498,$44C0,$44E8,$4510,$4538
	dc.w $4560,$4588,$45B0,$45D8,$4600,$4628,$4650,$4678,$46A0,$46C8,$46F0,$4718
	dc.w $4740,$4768,$4790,$47B8,$47E0,$4808,$4830,$4858,$4880,$48A8,$48D0,$48F8
	dc.w $4920,$4948,$4970,$4998,$49C0,$49E8,$4A10,$4A38,$4A60,$4A88,$4AB0,$4AD8
	dc.w $4B00,$4B28,$4B50,$4B78,$4BA0,$4BC8,$4BF0,$4C18,$4C40,$4C68,$4C90,$4CB8
	dc.w $4CE0,$4D08,$4D30,$4D58,$4D80,$4DA8,$4DD0,$4DF8,$4E20,$4E48,$4E70,$4E98
	dc.w $4EC0,$4EE8,$4F10,$4F38,$4F60,$4F88,$4FB0,$4FD8,$5000,$5028,$5050,$5078
	dc.w $50A0,$50C8,$50F0,$5118,$5140,$5168,$5190,$51B8,$51E0,$5208,$5230,$5258
	dc.w $5280,$52A8,$52D0,$52F8,$5320,$5348,$5370,$5398,$53C0,$53E8,$5410,$5438
	dc.w $5460,$5488,$54B0,$54D8,$5500,$5528,$5550,$5578,$55A0,$55C8,$55F0,$5618
	dc.w $5640,$5668,$5690,$56B8,$56E0,$5708,$5730,$5758,$5780,$57A8,$57D0,$57F8
	dc.w $5820,$5848,$5870,$5898,$58C0,$58E8,$5910,$5938,$5960,$5988,$59B0,$59D8
	dc.w $5A00,$5A28,$5A50,$5A78,$5AA0,$5AC8,$5AF0,$5B18,$5B40,$5B68,$5B90,$5BB8
	dc.w $5BE0,$5C08,$5C30,$5C58,$5C80,$5CA8,$5CD0,$5CF8,$5D20,$5D48,$5D70,$5D98
	dc.w $5DC0,$5DE8,$5E10,$5E38,$5E60,$5E88,$5EB0,$5ED8,$5F00,$5F28,$5F50,$5F78
	dc.w $5FA0,$5FC8,$5FF0,$6018,$6040,$6068,$6090,$60B8,$60E0,$6108,$6130,$6158
	dc.w $6180,$61A8,$61D0,$61F8,$6220,$6248,$6270,$6298,$62C0,$62E8,$6310,$6338
	dc.w $6360,$6388,$63B0,$63D8,$6400,$6428,$6450,$6478,$64A0,$64C8,$64F0,$6518
	dc.w $6540,$6568,$6590,$65B8,$65E0,$6608,$6630,$6658,$6680,$66A8,$66D0,$66F8
	dc.w $6720,$6748,$6770,$6798,$67C0,$67E8,$6810,$6838,$6860,$6888,$68B0,$68D8
	dc.w $6900,$6928,$6950,$6978,$69A0,$69C8,$69F0,$6A18,$6A40,$6A68,$6A90,$6AB8
	dc.w $6AE0,$6B08,$6B30,$6B58,$6B80,$6BA8,$6BD0,$6BF8,$6C20,$6C48,$6C70,$6C98
	dc.w $6CC0,$6CE8,$6D10,$6D38,$6D60,$6D88,$6DB0,$6DD8,$6E00,$6E28,$6E50,$6E78
	dc.w $6EA0,$6EC8,$6EF0,$6F18,$6F40,$6F68,$6F90,$6FB8,$6FE0,$7008,$7030,$7058
	dc.w $7080,$70A8,$70D0,$70F8,$7120,$7148,$7170,$7198,$71C0,$71E8,$7210,$7238
	dc.w $7260,$7288,$72B0,$72D8,$7300,$7328,$7350,$7378,$73A0,$73C8,$73F0,$7418
	dc.w $7440,$7468,$7490,$74B8,$74E0,$7508,$7530,$7558,$7580,$75A8,$75D0,$75F8
	dc.w $7620,$7648,$7670,$7698,$76C0,$76E8,$7710,$7738,$7760,$7788,$77B0,$77D8
	dc.w $7800,$7828,$7850,$7878,$78A0,$78C8,$78F0,$7918,$7940,$7968,$7990,$79B8
	dc.w $79E0,$7A08,$7A30,$7A58,$7A80,$7AA8,$7AD0,$7AF8,$7B20,$7B48,$7B70,$7B98
	dc.w $7BC0,$7BE8,$7C10,$7C38,$7C60,$7C88,$7CB0,$7CD8,$7D00,$7D28,$7D50,$7D78
	dc.w $7DA0,$7DC8,$7DF0,$7E18,$7E40,$7E68,$7E90,$7EB8,$7EE0,$7F08,$7F30,$7F58
	dc.w $7F80,$7FA8,$7FD0,$7FF8,$8020,$8048,$8070,$8098,$80C0,$80E8,$8110,$8138
	dc.w $8160,$8188,$81B0,$81D8,$8200,$8228,$8250,$8278,$82A0,$82C8,$82F0,$8318
	dc.w $8340,$8368,$8390,$83B8,$83E0,$8408,$8430,$8458,$8480,$84A8,$84D0,$84F8
	dc.w $8520,$8548,$8570,$8598,$85C0,$85E8,$8610,$8638,$8660,$8688,$86B0,$86D8
	dc.w $8700,$8728,$8750,$8778,$87A0,$87C8,$87F0,$8818,$8840,$8868,$8890,$88B8
	dc.w $88E0,$8908,$8930,$8958,$8980,$89A8,$89D0,$89F8,$8A20,$8A48,$8A70,$8A98
	dc.w $8AC0,$8AE8,$8B10,$8B38,$8B60,$8B88,$8BB0,$8BD8,$8C00,$8C28,$8C50,$8C78
	dc.w $8CA0,$8CC8,$8CF0,$8D18,$8D40,$8D68,$8D90,$8DB8,$8DE0,$8E08,$8E30,$8E58
	dc.w $8E80,$8EA8,$8ED0,$8EF8,$8F20,$8F48,$8F70,$8F98,$8FC0,$8FE8,$9010,$9038
	dc.w $9060,$9088,$90B0,$90D8,$9100,$9128,$9150,$9178,$91A0,$91C8,$91F0,$9218
	dc.w $9240,$9268,$9290,$92B8,$92E0,$9308,$9330,$9358,$9380,$93A8,$93D0,$93F8
	dc.w $9420,$9448,$9470,$9498,$94C0,$94E8,$9510,$9538,$9560,$9588,$95B0,$95D8
	dc.w $9600,$9628,$9650,$9678,$96A0,$96C8,$96F0,$9718,$9740,$9768,$9790,$97B8
	dc.w $97E0,$9808,$9830,$9858,$9880,$98A8,$98D0,$98F8,$9920,$9948,$9970,$9998
	dc.w $99C0,$99E8,$9A10,$9A38,$9A60,$9A88,$9AB0,$9AD8,$9B00,$9B28,$9B50,$9B78
	dc.w $9BA0,$9BC8,$9BF0,$9C18,$9C40,$9C68,$9C90,$9CB8,$9CE0,$9D08,$9D30,$9D58
	dc.w $9D80,$9DA8,$9DD0,$9DF8,$9E20,$9E48,$9E70,$9E98,$9EC0,$9EE8,$9F10,$9F38
	dc.w $9F60,$9F88,$9FB0,$9FD8,$A000


;      ---------------------
;	      STELLE
;      ---------------------
; tabella stelle nel formato x,y,z

star	dc.w -38*4, 53*4, 3252
	dc.w -55*4,-84*4, 4286
	dc.w -218*4, 126*4, 4219
	dc.w  143*4,-169*4, 175
	dc.w  14*4,-92*4, 3325
	dc.w -169*4,-146*4, 4708
	dc.w -99*4,-62*4, 1230
	dc.w  93*4, 73*4, 1537
	dc.w -189*4, 162*4, 1250

	dc.w -203*4, 156*4, 978
	dc.w  183*4, 72*4, 559
	dc.w -178*4, 68*4, 2418
	dc.w  122*4, 54*4, 2269
	dc.w -61*4,-103*4, 3582
	dc.w -140*4, 22*4, 575
	dc.w  101*4,-116*4, 2852
	dc.w  110*4,-169*4, 2136
	dc.w -123*4,-117*4, 798
	dc.w  207*4, 99*4, 1650
	dc.w  222*4,-62*4, 649
	dc.w -135*4, 155*4, 5939
	dc.w -29*4,-91*4, 4050
	dc.w  17*4,-136*4, 4128
	dc.w -143*4, 126*4, 2708
	dc.w -217*4,-139*4, 1153
	dc.w -134*4,-6*4, 2957
	dc.w  55*4,-57*4, 2350
	dc.w -188*4,-38*4, 973
	dc.w -115*4,-56*4, 4321
	dc.w -136*4,-77*4, 542
	dc.w -138*4,-129*4, 2296
	dc.w -226*4,-95*4, 3883
	dc.w  51*4,-170*4, 3817
	dc.w -6*4,-131*4, 2224
	dc.w  82*4, 107*4, 3692
	dc.w -106*4,-121*4, 2253
	dc.w  178*4, 101*4, 3300
	dc.w -54*4, 161*4, 3450
	dc.w  221*4, 42*4, 55
	dc.w  40*4, 91*4, 3663
	dc.w -139*4,-148*4, 1020
	dc.w  161*4,-158*4, 3665
	dc.w  49*4,-68*4, 4912
	dc.w  7*4, 160*4, 5984
	dc.w -133*4, 20*4, 2180
	dc.w -155*4,-42*4, 2318
	dc.w -221*4,-60*4, 5031
	dc.w  14*4, 25*4, 1978
	dc.w -154*4, 64*4, 83
	dc.w  115*4,-140*4, 624
	dc.w -69*4, 72*4, 1673
	dc.w  159*4,-51*4, 542
	dc.w -81*4,-55*4, 593
	dc.w -113*4, 139*4, 5922
	dc.w -62*4, 80*4, 4517
	dc.w  167*4,-140*4, 2783
	dc.w  24*4,-31*4, 1667
	dc.w  83*4,-136*4, 3918
	dc.w -147*4, 14*4, 3030
	dc.w -105*4, 154*4, 4812
	dc.w -1*4, 88*4, 2492
	dc.w -145*4,-155*4, 639
	dc.w -117*4, 29*4, 3762
	dc.w  174*4, 98*4, 229
	dc.w  198*4,-168*4, 885
	dc.w -101*4,-83*4, 3380
	dc.w  214*4, 57*4, 3582
	dc.w -58*4,-119*4, 2651
	dc.w  144*4,-29*4, 4659
	dc.w -165*4,-65*4, 5702
	dc.w -11*4,-73*4, 5306
	dc.w -227*4, 40*4, 3827
	dc.w -191*4, 116*4, 5802
	dc.w  60*4,-145*4, 1048
	dc.w  112*4, 115*4, 2907
	dc.w -208*4,-35*4, 4268
	dc.w -222*4,-164*4, 1140
	dc.w -165*4,-59*4, 4808
	dc.w -31*4,-16*4, 5283
	dc.w -100*4, 58*4, 5259
	dc.w -214*4,-95*4, 1569
	dc.w -65*4, 147*4, 5541
	dc.w -196*4, 57*4, 1211
	dc.w  217*4,-101*4, 1057
	dc.w  44*4,-30*4, 4249
	dc.w -26*4, 100*4, 3486
	dc.w  200*4, 57*4, 5969
	dc.w  177*4,-69*4, 1933
	dc.w -189*4, 52*4, 3272
	dc.w  119*4, 137*4, 1362
	dc.w  65*4,-156*4, 1694
	dc.w -48*4,-107*4, 142
	dc.w -11*4,-109*4, 5449
	dc.w -105*4,-123*4, 1610
	dc.w  194*4,-115*4, 4633
	dc.w -208*4, 132*4, 4443
	dc.w  62*4, 60*4, 3217
	dc.w -206*4, 58*4, 4120
	dc.w -140*4, 65*4, 3338
	dc.w  155*4, 60*4, 4470
	dc.w -163*4,-34*4, 3459
	dc.w -190*4, 46*4, 2391
	dc.w  46*4, 153*4, 190
	dc.w  93*4,-152*4, 4860
	dc.w  42*4,-48*4, 712
	dc.w -181*4,-105*4, 480
	dc.w -81*4,-25*4, 2969
	dc.w  7*4, 55*4, 2491
	dc.w -29*4, 95*4, 417
	dc.w  95*4, 118*4, 4490
	dc.w  131*4,-111*4, 4633
	dc.w  41*4,-169*4, 842
	dc.w  13*4, 109*4, 4997
	dc.w  55*4, 4*4, 374
	dc.w  62*4,-59*4, 4069
	dc.w -81*4,-145*4, 1159
	dc.w -25*4, 147*4, 5844
	dc.w  186*4, 24*4, 2955
	dc.w -133*4,-74*4, 3268
	dc.w -175*4, 20*4, 5091
	dc.w  125*4, 111*4, 3847
	dc.w  229*4,-81*4, 5018
	dc.w  7*4, 154*4, 5312
	dc.w -142*4, 29*4, 1590
	dc.w  122*4, 113*4, 952
	dc.w -41*4, 163*4, 3714
	dc.w  173*4,-41*4, 4623
	dc.w -172*4,-101*4, 5250
	dc.w  84*4, 12*4, 4779
	dc.w  90*4,-52*4, 3465
	dc.w  130*4, 160*4, 3631
	dc.w  4*4,-39*4, 2494
	dc.w -196*4, 69*4, 5657
	dc.w  187*4, 151*4, 2311
	dc.w -35*4, 31*4, 5400
	dc.w  167*4,-76*4, 2383
	dc.w  28*4,-69*4, 4983
	dc.w  36*4, 106*4, 3581
	dc.w  73*4, 115*4, 4499
	dc.w -203*4,-28*4, 4532
	dc.w -170*4, 90*4, 431
	dc.w -151*4,-113*4, 700
	dc.w  4*4,-12*4, 886
	dc.w -197*4,-33*4, 2658
	dc.w -96*4,-132*4, 949
	dc.w -132*4,-156*4, 2132
	dc.w -152*4,-123*4, 755
	dc.w  111*4, 137*4, 4941
	dc.w -112*4,-47*4, 4711
	dc.w  28*4,-63*4, 4370
	dc.w  182*4,-132*4, 5127
	dc.w -73*4, 95*4, 2731
	dc.w -174*4,-8*4, 5922
	dc.w -128*4,-41*4, 3244
	dc.w  216*4,-73*4, 985
	dc.w  113*4, 94*4, 5734
	dc.w  115*4,-140*4, 4963
	dc.w -78*4, 9*4, 5070
	dc.w  90*4, 113*4, 1905
	dc.w  25*4,-109*4, 5682
	dc.w -119*4, 18*4, 1528
	dc.w  116*4, 169*4, 5035
	dc.w -125*4, 87*4, 1517
	dc.w  74*4, 111*4, 478
	dc.w -147*4, 34*4, 5063
	dc.w -182*4, 47*4, 2075
	dc.w  67*4,-141*4, 5291
	dc.w  99*4,-144*4, 477
	dc.w -112*4, 146*4, 1040
	dc.w  196*4, 65*4, 3550
	dc.w -53*4,-15*4, 5818
	dc.w  165*4, 55*4, 4962
	dc.w  189*4, 97*4, 4967
	dc.w -8*4, 77*4, 1686
	dc.w  4*4, 141*4, 3676
	dc.w  163*4, 148*4, 5182
	dc.w -63*4, 12*4, 585
	dc.w  10*4, 157*4, 2068
	dc.w -76*4,-118*4, 2046
	dc.w -40*4, 73*4, 4545
	dc.w -50*4, 72*4, 1975
	dc.w  152*4,-27*4, 3381
	dc.w  114*4,-108*4, 5619
	dc.w  143*4, 25*4, 2220
	dc.w -33*4,-68*4, 3713
	dc.w  212*4,-55*4, 1694
	dc.w -228*4, 66*4, 1566
	dc.w  227*4,-97*4, 3011
	dc.w -158*4, 84*4, 5004
	dc.w -193*4,-123*4, 902
	dc.w  140*4,-146*4, 1218
	dc.w -17*4,-57*4, 1105
	dc.w -118*4, 113*4, 198
	dc.w  202*4, 51*4, 1081
	dc.w -157*4, 16*4, 1816
	dc.w -31*4, 68*4, 601
	dc.w  157*4,-7*4, 5628
	dc.w  2*4, 120*4, 5788
	dc.w  28*4, 64*4, 3038
	dc.w -165*4, 18*4, 2471
	dc.w -15*4,-96*4, 2598
	dc.w  80*4, 22*4, 5503
	dc.w -160*4, 99*4, 753
	dc.w  42*4,-30*4, 1172
	dc.w  230*4,-88*4, 2569
	dc.w  159*4,-115*4, 4632
	dc.w -96*4,-42*4, 2996
	dc.w  87*4,-35*4, 4740
	dc.w -162*4, 32*4, 1036
	dc.w -176*4, 83*4, 3843
	dc.w -211*4,-20*4, 1852
	dc.w -109*4, 35*4, 1673
	dc.w -68*4, 23*4, 2578
	dc.w -115*4, 107*4, 1104
	dc.w  18*4,-138*4, 1503
	dc.w  8*4, 113*4, 2208
	dc.w -159*4,-99*4, 1032
	dc.w  16*4, 73*4, 4333
	dc.w  180*4, 20*4, 404
	dc.w  83*4, 83*4, 5100
	dc.w  70*4, 119*4, 3813
	dc.w -75*4,-38*4, 5955
	dc.w  175*4,-7*4, 2586
	dc.w  180*4, 9*4, 4612
	dc.w -99*4, 166*4, 3729
	dc.w -211*4,-167*4, 5588
	dc.w -195*4, 142*4, 3002
	dc.w  48*4, 135*4, 1936
	dc.w -77*4, 99*4, 5770
	dc.w -93*4, 106*4, 1846
	dc.w  32*4,-160*4, 5773
	dc.w -197*4,-143*4, 2040
	dc.w -193*4,-8*4, 177
	dc.w  90*4, 8*4, 4563
	dc.w  138*4,-57*4, 1889
	dc.w -58*4,-25*4, 5172
	dc.w -215*4,-15*4, 5998
	dc.w  3*4,-30*4, 230
	dc.w  99*4, 60*4, 2704
	dc.w  84*4,-50*4, 1438
	dc.w  96*4,-88*4, 793
	dc.w -12*4,-24*4, 5493
	dc.w  213*4,-151*4, 3492
	dc.w -139*4,-170*4, 2990
	dc.w -28*4,-36*4, 940
	dc.w -131*4, 87*4, 597
	dc.w -133*4, 102*4, 5548
	dc.w -225*4, 15*4, 5307
	dc.w  192*4,-70*4, 298
	dc.w  3*4, 166*4, 1182
	dc.w  110*4,-11*4, 484
	dc.w  158*4, 161*4, 1714
	dc.w  62*4, 48*4, 2090
	dc.w  181*4,-41*4, 1107
	dc.w  150*4, 43*4, 3436
	dc.w -224*4,-50*4, 3394
	dc.w -49*4,-135*4, 1419
	dc.w -34*4,-26*4, 4234
	dc.w  114*4, 83*4, 3684
	dc.w  224*4, 155*4, 4727
	dc.w -111*4, 111*4, 1617
	dc.w -117*4, 98*4, 4985
	dc.w -224*4,-33*4, 4197
	dc.w  219*4,-95*4, 826
	dc.w  181*4,-24*4, 5773
	dc.w -47*4, 16*4, 5080
	dc.w  22*4,-56*4, 4251
	dc.w  3*4,-33*4, 4364
	dc.w  187*4, 2*4, 3324
	dc.w  149*4,-48*4, 165
	dc.w -194*4,-72*4, 172
	dc.w -227*4, 12*4, 1837
	dc.w  91*4, 123*4, 1411
	dc.w -106*4,-7*4, 176
	dc.w -186*4,-26*4, 3508
	dc.w  74*4, 33*4, 2513
	dc.w -183*4,-15*4, 4002
	dc.w  24*4,-107*4, 4949
	dc.w -62*4, 37*4, 4350
	dc.w -58*4,-37*4, 2050
	dc.w  162*4,-12*4, 5007
	dc.w  19*4,-156*4, 4611
	dc.w  92*4, 138*4, 2305
	dc.w  54*4,-131*4, 5042
	dc.w -173*4,-69*4, 2762
	dc.w  152*4, 146*4, 487
	dc.w -187*4, 16*4, 3377
	dc.w -128*4, 12*4, 4782
	dc.w  120*4,-139*4, 458
	dc.w  164*4,-89*4, 5916
	dc.w  35*4, 105*4, 2307
	dc.w  188*4,-110*4, 2858
	dc.w -113*4,-112*4, 2509
	dc.w  76*4, 93*4, 5896
	dc.w -183*4, 76*4, 1887
	dc.w  84*4,-148*4, 2017
	dc.w -230*4,-54*4, 3947
	dc.w -116*4,-157*4, 5202
	dc.w  46*4, 32*4, 2383
	dc.w -8*4,-35*4, 1584
	dc.w -88*4, 50*4, 3524
	dc.w -52*4, 14*4, 3308
	dc.w  116*4, 90*4, 5763
	dc.w  104*4,-131*4, 4496
	dc.w  28*4, 7*4, 3903
	dc.w  77*4,-148*4, 4629
	dc.w -13*4,-23*4, 5073
	dc.w -143*4,-147*4, 3508
	dc.w -75*4,-151*4, 4914
	dc.w -48*4,-94*4, 4323
	dc.w -165*4, 77*4, 1590
	dc.w  16*4,-150*4, 243
	dc.w -193*4,-72*4, 4757
	dc.w  143*4, 80*4, 3025
	dc.w -13*4, 96*4, 4451
	dc.w  227*4,-96*4, 1909
	dc.w -216*4, 124*4, 1657
	dc.w -162*4,-152*4, 4981
	dc.w  22*4, 95*4, 5618
	dc.w -196*4,-25*4, 4124
	dc.w  171*4, 79*4, 2887
	dc.w  227*4, 113*4, 4367
	dc.w -150*4,-126*4, 1109
	dc.w  28*4,-12*4, 2153
	dc.w -228*4,-136*4, 4642
	dc.w -144*4,-5*4, 3258
	dc.w -226*4, 54*4, 1445
	dc.w -187*4,-100*4, 515
	dc.w -24*4,-131*4, 2301
	dc.w -196*4,-128*4, 89
	dc.w  119*4,-84*4, 3228
	dc.w  25*4,-101*4, 2892
	dc.w -103*4,-4*4, 2228
	dc.w  203*4,-107*4, 1466
	dc.w  206*4,-54*4, 5784
	dc.w  126*4, 126*4, 2861
	dc.w -17*4, 139*4, 444
	dc.w -196*4,-155*4, 4556
	dc.w -51*4, 57*4, 681
	dc.w -156*4,-159*4, 3133
	dc.w -116*4, 145*4, 2742
	dc.w  193*4, 60*4, 2740
	dc.w  198*4, 88*4, 3446
	dc.w  221*4,-133*4, 594
	dc.w -188*4,-162*4, 3041
	dc.w -65*4,-16*4, 3508
	dc.w  105*4,-130*4, 3575
	dc.w -19*4,-21*4, 5646
	dc.w  188*4,-86*4, 3279
	dc.w  220*4,-28*4, 4411
	dc.w -170*4,-132*4, 3692
	dc.w -115*4, 124*4, 1083
	dc.w -78*4, 34*4, 4501
	dc.w -112*4, 140*4, 4491
	dc.w  79*4,-19*4, 2945
	dc.w -222*4, 152*4, 2806
	dc.w  40*4,-125*4, 3669
	dc.w  38*4,-91*4, 322
	dc.w -114*4,-134*4, 612
	dc.w -80*4, 1*4, 2074
	dc.w  212*4,-26*4, 4368
	dc.w  155*4,-19*4, 818
	dc.w  26*4,-144*4, 4998
	dc.w  193*4,-103*4, 1945

numstars	equ	(*-star)/6

dest	ds.l	5000		; buffer stelle
colstar	ds.w	500		; buffer colore stelle

; --------------------------
; INTERRUPT ROUTINE. LEVEL 3 
; --------------------------

	dc.w	0
planes
	dc.l	screen
	dc.l	screen+10240*2

INTER:
	MOVEM.L	D0-D7/A0-A6,-(A7)	; Put registers on stack
	LEA.L	$DFF000,A6
	lea.l	planes-2,a0
	clr.w	(a0)+
	movem.l	(a0),d0-d1
	exg.l	d0,d1
	movem.l	d0-d1,(a0)


; ---------------------------------------
; imposta puntatori bitplanes

	lea.l	plan+2,a0

	move.w	d1,4(a0)		; bitplane 0
	swap	d1
	move.w	d1,(a0)

	addq.w	#8,a0
	swap	d1
	add.l	#10240,d1

	move.w	d1,4(a0)		; bitplane 1
	swap	d1
	move.w	d1,(a0)
; ---------------------------------------

	MOVE.W	#$4020,$9C(A6)		; Clear interrupt request
	MOVEM.L	(A7)+,D0-D7/A0-A6	; Get registers from stack
	RTE

; ----------------
; ROUTINE D'USCITA
; ----------------

;*** WAIT VERTICAL BLANK ***

Wait_Vert_Blank:
	BTST	#0,$5(A6)
	BEQ.S	Wait_Vert_Blank
.loop	BTST	#0,$5(A6)
	BNE.S	.loop
	RTS

;*** DATA AREA ***

GfxName		DC.B	'graphics.library',0
		even
DosBase		DC.L	0

; --------------------------
;      COPPER1 PROGRAM      
; --------------------------

COPLIST:
	DC.W	$0100,$2200	; Bit-Plane control reg.
	DC.W	$0102,$0000	; Hor-Scroll
	DC.W	$0104,$0010	; Sprite/Gfx priority
	DC.W	$0108,$0000	; Modolu (odd)
	DC.W	$010A,$0000	; Modolu (even)
	DC.W	$008E,$2C81	; Screen Size
	DC.W	$0090,$2CC1	; Screen Size
	DC.W	$0092,$0038	; H-start
	DC.W	$0094,$00D0	; H-stop

	DC.W	$0180,$0000	; Color #0 = 000
	DC.W	$0182,$0445	; Color #1 = 445
	DC.W	$0184,$0778	; Color #2 = 778
	DC.W	$0186,$0dde	; Color #2 = dde

	DC.W	$1C01,$FFFE

PLAN	dc.w	$00E0,$0000,$00E2,$0000	; pointer to bitplane 0
	dc.w	$00E4,$0000,$00E6,$0000	; pointer to bitplane 1

	DC.L	$FFFFFFFE

; --------------------------
;      SCREEN DATA AREA     
; --------------------------

	SECTION	Screen,BSS_C

	ds.l	200
SCREEN	DS.B	10240*6

