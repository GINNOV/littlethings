;------------------------------------------------
;-- AGAIN GANDALF ON YOUR SCREEN WITH A SOURCE --
;-- OF ACES.					--
;-- THIS SOURCE IS A FILLED VECTOR CODE  !!!	--
;-- VERY GREAT CODING  !!!			--
;------------------------------------------------

	bra.s	mm

	CUSTOM:	EQU	$DFF000
	BPLCON0: EQU	$100
	BPLCON1: EQU	$102
	BPLCON2: EQU	$104
	BPL1MOD: EQU	$108
	BPL2MOD: EQU	$10A
	DDFSTRT: EQU	$092
	DDFSTOP: EQU	$094
	DIWSTRT: EQU	$08E
	DIWSTOP: EQU	$090
	VHPOSR:	 EQU	$006
	VPOSR:	EQU	$004
	COLOR00: EQU	$180
	COLOR01: EQU	$182
	COLOR02: EQU	$184
	COLOR03: EQU	$186
	COLOR17: EQU	$1A2
	COLOR18: EQU	$1A4
	COLOR19: EQU	$1A6
	DMACON:  EQU	$096
	COP1LCH: EQU	$080
	COPJMP1: EQU	$088
	NONAME:  EQU	$106
	DMACONR: EQU	$002
	BLTDMOD: EQU	$066
	BLTCMOD: EQU	$060
	BLTBMOD: EQU	$062
	BLTAMOD: EQU	$064
	BLTAFWM: EQU	$044
	BLTALWM: EQU	$046
	BLTADAT: EQU	$074
	BLTBDAT: EQU	$072
	BLTCON0: EQU	$040
	BLTCON1: EQU	$042
	BLTAPTH: EQU	$050
	BLTAPTL: EQU	$052
	BLTBPTH: EQU	$04C
	BLTCPTH: EQU	$048
	BLTDPTH: EQU	$054
	BLTSIZE: EQU	$058
	AUDOLCH: EQU	$0A0
	AUDOLEN: EQU	$0A4
	AUDOPER: EQU	$0A6
	AUDOVOL: EQU	$0A8
	AUDODAT: EQU	$0AA
	EXECBASE=	$004
	OPENLIBRARY=	-408
	OPENFILE=	-30
	CLOSEFILE=	-36
	CLOSELIBRARY=	-414
	ALLOCMEMORY=	-198
	FREEMEMORY=	-210
	READFILE=	-42
	WRITEFILE=	-48
	FORBIDTASK=	-132
	PERMITTASK=	-138
;*************************************************
;******		MACRO-FONCTIONS	**********
;*************************************************
OPENLIB:	MACRO				;*
	MOVE.L	EXECBASE,A6			;*
	LEA	?1,A1				;*
	MOVEQ	#0,D0				;*
	JSR	OPENLIBRARY(A6)			;*
	MOVE.L	D0,?2				;*
	ENDM					;*
FREECOP:	MACRO				;*
	MOVE.L	GFXBASE,A6			;*
	MOVE.L	$26(A6),CUSTOM+COP1LCH		;*
	ENDM					;*
PERMIT:		MACRO				;*
	MOVE.L	EXECBASE,A6			;*
	JSR	PERMITTASK(A6)			;*
	ENDM					;*
FORBID:		MACRO				;*
	MOVE.L	EXECBASE,A6			;*
	JSR	FORBIDTASK(A6)			;*
	ENDM					;*
;-------------------------------------------------
	BRA	MM				;*
GFXLIB:		DC.B	"graphics.library",0	;*
	even					;*
DOSLIB:		DC.B	"dos.library",0		;*
	even					;*
DOSBASE:	DC.L 0				;*
GFXBASE:	DC.L 0				;*
;*************************************************
	MM:
	MOVE.L	#ZERO,$14
	FORBID
	MOVE.L	4.W,A6			;*
	MOVE.L	#32100,D0			;*
	MOVEQ	#2,D1				;*
	JSR	ALLOCMEMORY(A6)			;*
	MOVE.L	D0,SCREEN1			;*

	MOVE.L	4.W,A6			;*
	MOVE.L	#32100,D0			;*
	MOVEQ	#2,D1				;*
	JSR	ALLOCMEMORY(A6)			;*
	MOVE.L	D0,SCREEN2			;*

	MOVE.L	4.W,A6			;*
	MOVEQ	#100,D0			;*
	MOVEQ	#2,D1				;*
	JSR	ALLOCMEMORY(A6)			;*
	MOVE.L	D0,COPLIST			;*

	MOVE.L	4.W,A6			;*
	LEA	GFXLIB,A1			;*
	MOVEQ	#0,D0				;*
	JSR	OPENLIBRARY(A6)			;*
	MOVE.L	D0,GFXBASE			;*
	LEA	CUSTOM,A0
	MOVE.W	#$4200,BPLCON0(A0)
	MOVE.W	#0,BPLCON1(A0)
	MOVE.W	#$38,DDFSTRT(A0)
	MOVE.W	#$D0,DDFSTOP(A0)
	MOVE.W	#$2C81,DIWSTRT(A0)
	MOVE.W	#$F4C1,DIWSTOP(A0)

	MOVE.L	SCREEN2(PC),D7
	MOVE.L	SCREEN2,BITMP
	MOVE.L	COPLIST,A1
	MOVE.W	#$00E0,(A1)+
	SWAP	D7
	MOVE.W	D7,(A1)+
	MOVE.W	#$00E2,(A1)+
	SWAP	D7
	MOVE.W	D7,(A1)+
	ADDI.L	#8000,D7
	MOVE.W	#$00E4,(A1)+
	SWAP	D7
	MOVE.W	D7,(A1)+
	MOVE.W	#$00E6,(A1)+
	SWAP	D7
	MOVE.W	D7,(A1)+
	ADDI.L	#8000,D7
	MOVE.W	#$00E8,(A1)+
	SWAP	D7
	MOVE.W	D7,(A1)+
	MOVE.W	#$00EA,(A1)+
	SWAP	D7
	MOVE.W	D7,(A1)+
	ADDI.L	#8000,D7
	MOVE.W	#$00EC,(A1)+
	SWAP	D7
	MOVE.W	D7,(A1)+
	MOVE.W	#$00EE,(A1)+
	SWAP	D7
	MOVE.W	D7,(A1)+
	MOVE.L	#$01800000,(A1)+
	MOVE.L	#$01810101,(A1)+
	MOVE.L	#$01820202,(A1)+
	MOVE.L	#$01840303,(A1)+
	MOVE.L	#$01860404,(A1)+
	MOVE.L	#$01880505,(A1)+
	MOVE.L	#$018A0606,(A1)+
	MOVE.L	#$018C0707,(A1)+
	MOVE.L	#$018E0808,(A1)+
	MOVE.L	#$01900909,(A1)+
	MOVE.L	#$01920A0A,(A1)+
	MOVE.L	#$01940B0B,(A1)+
	MOVE.L	#$01960C0C,(A1)+
	MOVE.L	#$01980D0D,(A1)+
	MOVE.L	#$019A0E0E,(A1)+
	MOVE.L	#$019C0F0F,(A1)+
	MOVE.L	#$FFFFFFFE,(A1)+
	MOVE.L	COPLIST,COP1LCH(A0)
	MOVE.W	#0,COPJMP1(A0)
	MOVE.W	#0,$1fc(A0)
	MOVE.L	#0,$108(A0)
	MOVE.W	#$c00,$106(A0)
	MOVE.W	#$8380,DMACON(A0)
	MOVE.W	#$20,DMACON(A0)
;©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©
DEB:
	MOVE.W	GA(PC),D0
	ADDI.W	#50,D0
	BSR.W	DEG
	MOVE	D0,GA
	MOVE.W	BE(PC),D0
	ADDI.W	#30,D0
	BSR.W	DEG
	MOVE.W	D0,BE
	MOVE.W	AL(PC),D0
	ADDQ.W	#6,D0
	BSR.W	DEG
	MOVE.W	D0,AL
	BSR.W	CLEAR
	MOVE.L	OBJECT(PC),A0
	BSR.S	DISPLAY
;©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©
WAIT:	BTST	#6,$BFE001
	BNE.S	DEB

	MOVE.L	4.W,A6			;*
	MOVE.L	SCREEN1(PC),A1			;*
	MOVE.L	#32100,D0			;*
	JSR	FREEMEMORY(A6)			;*

	MOVE.L	4.W,A6			;*
	MOVE.L	SCREEN2(PC),A1			;*
	MOVE.L	#32100,D0			;*
	JSR	FREEMEMORY(A6)			;*

	MOVE.L	4.W,A6			;*
	MOVE.L	COPLIST(PC),A1			;*
	MOVEQ	#100,D0				;*
	JSR	FREEMEMORY(A6)			;*
	FREECOP
	MOVE.L	4.W,A6			;*
	MOVE.L	GFXBASE(PC),A1			;*
	JSR	CLOSELIBRARY(A6)		;*
	PERMIT
	MOVE.W	#$8020,DMACON+CUSTOM
	RTS
ZERO:	FREECOP
	RTE
;©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©
DISPLAY:MOVE.B $DFF00B,POSX+1	;A0: POINTS & FACETTES
	LEA	PTS2D(PC),A4
	LEA	ZPROF(PC),A5
	LEA	PTS3D(PC),A2
;	MOVEQ	#0,D0		;POSX
;	DIVS	#256,D0
;	MOVE	D0,POSX
;	MOVEQ	#0,D0		;POSY
;	DIVS	#256,D0
;	MOVE	D0,POSY
;	MOVEQ	#0,D0		;POSZ
;	DIVS	#256,D0
;	MOVE	D0,POSZ
	MOVE.W	AL(PC),D2		;3 ANGLES EN °
	MOVE.W	BE(PC),D3
	MOVE.W	GA(PC),D4
	ASR.W	#2,D3
	ASR.W	#2,D2
	ASR.W	#2,D4
	ANDI.L	#$FFFE,D2
	ANDI.L	#$FFFE,D3
	ANDI.L	#$FFFE,D4
DRAW2:	MOVE.W	(A0)+,D5
	CMPI.W	#$7FFF,D5
	BNE.S	JMP1
	BRA.S	LINK
JMP1:	MOVE.W	(A0)+,D6
	MOVE.W	(A0)+,D7
	BSR.W	ROTOZ
	BSR.W	ROTOY
	BSR.W	ROTOX
	ADD.W	POSX(PC),D5
	ADD.W	POSY(PC),D6
	ADD.W	POSZ(PC),D7
	ADDI.W	#400,D7
	MOVE	D5,(A2)+	;'X'
	MOVE	D6,(A2)+	;'Y'
	MOVE	D7,(A5)+	;'Z'
	BSR.W	PROJEC
	MOVE	D5,(A4)+	;X.EC
	MOVE	D6,(A4)+	;Y.EC
	BRA.S	DRAW2
;-----------REMPLIT SURFACES(>= 3 PTS!!) ET SURFLIST. A0:VERS SURFACES
;-----------	CALC INTENSITE COULEUR+PROFONDEUR+ G
LINK:	LEA	PTS2D(PC),A1
	LEA	PTS3D(PC),A6
	LEA	ZPROF(PC),A4
	LEA	ZFACE,A5
	LEA	SURFLIST(PC),A2
	LEA	SURFACES(PC),A3
AGAIN:	MOVEQ	#0,D2		;INIT. SOMME DES 'Z'
	MOVE	(A0)+,D0	;NBRE DE PTS (EN COMPTANT '0')
	CMPI	#-1,D0
	BEQ.W	FINSURF
	MOVE.L	A3,(A2)+	;*SURFACE -> SURFLIST
	MOVE.L	#1,(A3)+	;COULEUR
;-------
	MOVE.W	(A0)+,D1	;--------
	ASL.W	#2,D1		;POS DS PTS2D DE PT(X,Y)
	MOVE.L	(A1,D1.W),(A3)+	;X,Y -> (SURFACES)	
	MOVE.L	(A6,D1.W),VAX	;X->VAX ; Y-> VAY
	LSR.W	#1,D1
	MOVE.W	(A4,D1.W),VAZ	;SOMME DES 'Z'-->D2
	ADD.W	VAZ(PC),D2

	MOVE.W	(A0)+,D1	;2è PT
	ASL.W	#2,D1		
	MOVE.L	(A1,D1.W),(A3)+
	MOVE.L	(A6,D1.W),D6	;D6:(X,Y)->Y.W
	MOVE.L	D6,D5
	SWAP	D5		;D5:X		
	LSR	#1,D1
	MOVE.W	(A4,D1.W),D7	
	ADD.W	D7,D2
	
	MOVE.W	(A0)+,D1
	ASL.W	#2,D1		
	MOVE.L	(A1,D1.W),(A3)+		
	MOVE.L	(A6,D1.W),VBX	
	LSR.W	#1,D1
	MOVE.W	(A4,D1.W),VBZ
	ADD.W	VBZ(PC),D2
	BSR.S	LUM		;CALC.P.VECT,P.SCALAIRE,INTENS.LUM
	CMPI.W	#3,D0
	BEQ.S	ENOUGH		;3 PTS DS SURFACE (AU MINIMUM ...)

	MOVE.W	(A0)+,D1	
	ASL.W	#2,D1		
	MOVE.L	(A1,D1.W),(A3)+		
	LSR.W	#1,D1
	ADD.W	(A4,D1.W),D2	;4 PTS DS SURFACE (AU MAXIMUM ...)
;-------
ENOUGH:	DIVS.W	D0,D2		;BARYCENTRE 'Z'
	MOVE.W	D2,(A5)+	;TABLE DES BARYCENTRES
	MOVE.L	#-1,(A3)+	;FIN	SURFACE n
	BRA.W	AGAIN
	RTS
FINSURF:MOVE.L	#-1,(A2)+	;FIN SURFLIST
	MOVE.W	#$7FFF,(A5)+	;FIN BARYC.LISTE
;--------------------------- TRI EN F() DE Z:
	LEA	ZFACE,A0
	LEA	SURFLIST(PC),A2
TRI:	MOVE.L	A2,A3
	MOVE.L	A0,A1
	ADDQ.L	#2,A1
	ADDQ.L	#4,A3
TRI5:	MOVE.L	(A2),D2		;:PTR
	MOVE.W	(A0),D0		;:Z
	CMP.W	#$7FFF,D0
	BEQ.S	OUFF		;FINI.
TRI3:	MOVE.L	(A3)+,D3	;:PTR
	MOVE.W	(A1)+,D1	;:Z
	CMPI.W	#$7FFF,D1
	BNE.S	TRI4
	ADDQ.L	#2,A0
	ADDQ.L	#4,A2
	BRA.S	TRI
TRI4:	CMP.W	D0,D1
	BLT.S	TRI3
	MOVE.W	D1,(A0)		;EXG LES Z
	MOVE.W	D0,-2(A1)
	MOVE.L	D3,(A2)		;EXG POINTEURS
	MOVE.L	D2,-4(A3)
	BRA.S	TRI5
;---------------------------
OUFF:	LEA	SURFLIST(PC),A2
	BSR.W	DRAW
	RTS
;---------------------------
LUM:	SUB.W	D5,VAX		;COORD. DES 2 VECTEURS
	SUB.W	D6,VAY
	SUB.W	D7,VAZ
	SUB.W	D5,VBX
	SUB.W	D6,VBY
	SUB.W	D7,VBZ
	MOVE.W	VAY(PC),D1
	MULS.W	VBZ(PC),D1
	MOVE.W	VAZ(PC),D3
	MULS.W	VBY(PC),D3
	SUB.L	D3,D1
	MOVE.W	VAZ(PC),D3
	MULS.W	VBX(PC),D3
	MOVE.W	VAX(PC),D4
	MULS.W	VBZ(PC),D4
	SUB.L	D4,D3
	MOVE.W	VAX(PC),D4
	MULS.W	VBY(PC),D4
	MOVE.W	VAY(PC),D5
	MULS.W	VBX(PC),D5
	SUB.L	D5,D4
	MULS.W	D1,D1
	MULS.W	D3,D3
	MULS.W	D4,D4
	ADD.L	D3,D1
	ADD.L	D4,D1
	TST.L	D1
	BEQ.S	ARG
	LSR.L	#4,D1
;-----
	MOVEQ	#0,D5
	MOVE.L	D1,D3
DIV:	ADD.L	D3,D1
	ADDQ.L	#1,D5
	CMP.L	D4,D1
	BMI.S	DIV
	
	ANDI.L	#15,D5
	CMPI.W	#15,D5
	BNE.S	QSD
	MOVEQ	#$E,D5
QSD:	MOVE.L	D5,-16(A3)
	RTS
ARG:	MOVE.L	#$E,-16(A3)
	RTS
DE1:DC.L 0
DE4:DC.L 0
;************************************************
;********** PROJECTION,ROTATIONS(X,Y,Z) *********
;************************************************
;------ D5:X D6:Y D7:Z --------------------------
PROJEC:
	MULS.W	DFOC(PC),D5
	DIVS.W	D7,D5
	ADDI.W	#160,D5
	MULS.W	DFOC(PC),D6
	DIVS.W	D7,D6
	SUBI.W	#100,D6
	NEG.W	D6
	RTS
DFOC:	DC.W	256
;----- D2:ANGLE D6:Y D7:Z D0 D1 A3 A6  ----------
ROTOX:
	LEA.L	COS(PC),A6
	LEA.L	SIN(PC),A3
	MOVE.W	D6,D0
	MOVE.W	D7,D1
	MULS.W	(A6,D2.W),D0
	MULS.W	(A3,D2.W),D1
	ADD.L	D1,D0
	MULS.W	(A6,D2.W),D7
	MULS.W	(A3,D2.W),D6
	SUB.L	D6,D7
	EXG	D0,D6
	ASR.L	#8,D6	;DIVS 256
	ASR.L	#8,D7
	RTS
;----- D3:ANGLE D5:X D7:Z D0 D1 A6 A3 -----------------
ROTOY:
	LEA	COS(PC),A6
	LEA	SIN(PC),A3
	MOVE.W	D5,D0
	MOVE.W	D7,D1
	MULS.W	(A6,D3.W),D0
	MULS.W	(A3,D3.W),D1
	SUB.L	D1,D0
	MULS.W	(A6,D3.W),D7
	MULS.W	(A3,D3.W),D5
	ADD.L	D5,D7
	EXG	D0,D5
	ASR.L	#8,D5	;DIVS	#256,D5
	ASR.L	#8,D7	;DIVS	#256,D7
	RTS
;-----D4:ANGLE D5:X D6:Y A6 A3 D0 D1 ------------
ROTOZ:
	LEA.L	COS(PC),A6
	LEA.L	SIN(PC),A3
	MOVE.W	D5,D0
	MOVE.W	D6,D1
	MULS.W	(A6,D4.W),D0
	MULS.W	(A3,D4.W),D1
	ADD.L	D1,D0
	MULS.W	(A6,D4.W),D6
	MULS.W	(A3,D4.W),D5
	SUB.L	D5,D6
	EXG	D0,D5
	ASR.L	#8,D6		;DIVS	#256,D6
	ASR.L	#8,D5		;DIVS	#256,D5
	RTS
;-------D0:Angle à convertir --------------------
DEG:	CMPI.W	#360*8,D0
	BLT.S	DEG2
	SUBI.W	#360*8,D0
	BRA.S	DEG3
DEG2:	TST.W	D0
	BPL.S	DEG3
	ADDI.W	#360*8,D0
DEG3:	RTS	
;************************************************
COS:	DC.W 256,255,255,255,255,255,254
	DC.W 254,253,252,252,251,250,249
	DC.W 248,247,246,244,243,242,240
	DC.W 238,237,235,233,232,230,228
	DC.W 226,223,221,219,217,214,212
	DC.W 209,207,204,201,198,196
	DC.W 193,190,187,186,181,177,174
	DC.W 171,167,164,161,157,154,150
	DC.W 146,143,139,135,131,128,124
	DC.W 120,116,112,108,104,100,95,91
	DC.W 87,83,79,74,70,66,61,57,53
	DC.W 48,44,40,35,31,26,22,17,13,8,4
	DC.W -0,-4,-8,-13,-17,-22,-26,-31,-35,-40
	DC.W -44,-48,-53,-57,-61,-66,-70,-74,-79,-83
	DC.W -87,-91,-95,-100,-104,-108,-112
	DC.W -116,-120,-124,-128,-131,-135,-139,-143
	DC.W -146,-150,-154,-157,-161,-164
	DC.W -167,-171,-174,-177,-181,-184,-187,-190
	DC.W -193,-196,-198,-201,-204,-207
	DC.W -209,-212,-214,-217,-219,-221,-223,-226
	DC.W -228,-230,-232,-233,-235,-237
	DC.W -238,-240,-242,-243,-244,-246,-247,-248
	DC.W -249,-250,-251,-252,-252,-253
	DC.W -254,-254,-255,-255,-255,-255,-255
	DC.W -256,-255,-255,-255,-255,-255,-254
	DC.W -254,-253,-252,-252,-251,-250,-249
	DC.W -248,-247,-246,-244,-243,-242,-240
	DC.W -238,-237,-235,-233,-232,-230,-228
	DC.W -226,-223,-221,-219,-217,-214,-212
	DC.W -209,-207,-204,-201,-198,-196
	DC.W -193,-190,-187,-186,-181,-177,-174
	DC.W -171,-167,-164,-161,-157,-154,-150
	DC.W -146,-143,-139,-135,-131,-128,-124
	DC.W -120,-116,-112,-108,-104,-100,-95,-91
	DC.W -87,-83,-79,-74,-70,-66,-61,-57,-53
	DC.W -48,-44,-40,-35,-31,-26,-22,-17,-13,-8,-4
	DC.W 0,4,8,13,17,22,26,31,35,40
	DC.W 44,48,53,57,61,66,70,74,79,83
	DC.W 87,91,95,100,104,108,112
	DC.W 116,120,124,128,131,135,139,143
	DC.W 146,150,154,157,161,164
	DC.W 167,171,174,177,181,184,187,190
	DC.W 193,196,198,201,204,207
	DC.W 209,212,214,217,219,221,223,226
	DC.W 228,230,232,233,235,237
	DC.W 238,240,242,243,244,246,247,248
	DC.W 249,250,251,252,252,253
	DC.W 254,254,255,255,255,255,255,256

SIN:	DC.W 0,4,8,13,17,22,26,31,35,40
	DC.W 44,48,53,57,61,66,70,74,79,83
	DC.W 87,91,95,100,104,108,112
	DC.W 116,120,124,128,131,135,139,143
	DC.W 146,150,154,157,161,164
	DC.W 167,171,174,177,181,184,187,190
	DC.W 193,196,198,201,204,207
	DC.W 209,212,214,217,219,221,223,226
	DC.W 228,230,232,233,235,237
	DC.W 238,240,242,243,244,246,247,248
	DC.W 249,250,251,252,252,253
	DC.W 254,254,255,255,255,255,255
	DC.W 256,255,255,255,255,255,254
	DC.W 254,253,252,252,251,250,249
	DC.W 248,247,246,244,243,242,240
	DC.W 238,237,235,233,232,230,228
	DC.W 226,223,221,219,217,214,212
	DC.W 209,207,204,201,198,196
	DC.W 193,190,187,186,181,177,174
	DC.W 171,167,164,161,157,154,150
	DC.W 146,143,139,135,131,128,124
	DC.W 120,116,112,108,104,100,95,91
	DC.W 87,83,79,74,70,66,61,57,53
	DC.W 48,44,40,35,31,26,22,17,13,8,4
	DC.W -0,-4,-8,-13,-17,-22,-26,-31,-35,-40
	DC.W -44,-48,-53,-57,-61,-66,-70,-74,-79,-83
	DC.W -87,-91,-95,-100,-104,-108,-112
	DC.W -116,-120,-124,-128,-131,-135,-139,-143
	DC.W -146,-150,-154,-157,-161,-164
	DC.W -167,-171,-174,-177,-181,-184,-187,-190
	DC.W -193,-196,-198,-201,-204,-207
	DC.W -209,-212,-214,-217,-219,-221,-223,-226
	DC.W -228,-230,-232,-233,-235,-237
	DC.W -238,-240,-242,-243,-244,-246,-247,-248
	DC.W -249,-250,-251,-252,-252,-253
	DC.W -254,-254,-255,-255,-255,-255,-255
	DC.W -256,-255,-255,-255,-255,-255,-254
	DC.W -254,-253,-252,-252,-251,-250,-249
	DC.W -248,-247,-246,-244,-243,-242,-240
	DC.W -238,-237,-235,-233,-232,-230,-228
	DC.W -226,-223,-221,-219,-217,-214,-212
	DC.W -209,-207,-204,-201,-198,-196
	DC.W -193,-190,-187,-186,-181,-177,-174
	DC.W -171,-167,-164,-161,-157,-154,-150
	DC.W -146,-143,-139,-135,-131,-128,-124
	DC.W -120,-116,-112,-108,-104,-100,-95,-91
	DC.W -87,-83,-79,-74,-70,-66,-61,-57,-53
	DC.W -48,-44,-40,-35,-31,-26,-22,-17,-13,-8,-4,0
;©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©
CLEAR:
	BCHG	#0,ALTSC
	BEQ.S	K
	MOVE.L	SCREEN1(PC),BITMP
	MOVE.L	SCREEN2(PC),D0
	BRA.S	V
K:	MOVE.L	SCREEN2(PC),BITMP
	MOVE.L	SCREEN1(PC),D0
V	CMPI.B	#200,CUSTOM+VHPOSR
	BNE.S	V
	MOVE.L	COPLIST,A6
	SWAP	D0
	MOVE.W	D0,2(A6)
	SWAP	D0
	MOVE.W	D0,6(A6)
	ADDI.L	#8000,D0
	SWAP	D0
	MOVE.W	D0,10(A6)
	SWAP	D0
	MOVE.W	D0,14(A6)
	ADDI.L	#8000,D0
	SWAP	D0
	MOVE.W	D0,18(A6)
	SWAP	D0
	MOVE.W	D0,22(A6)
	ADDI.L	#8000,D0
	SWAP	D0
	MOVE.W	D0,26(A6)
	SWAP	D0
	MOVE.W	D0,30(A6)
L:	BTST	#$E,CUSTOM+DMACONR
	BNE.S	L
	MOVE.L	BITMP,CUSTOM+BLTDPTH
	MOVE.W	#0,CUSTOM+BLTDMOD
	MOVE.W	#0,CUSTOM+BLTCON1
	MOVE.W	#$100,CUSTOM+BLTCON0
	MOVE.W	#$3FBF,CUSTOM+BLTSIZE
	RTS
ALTSC:	DC.W	0
SCREEN1:	DC.L 0
SCREEN2:	DC.L 0
COPLIST:	DC.L 0
BITMP:		DC.L 0
****************************************************************
******************					**********
******************	AFFICHAGE DE SURFACES	**********
******************					**********
****************************************************************
	BITMAP1=	8000
	BITMAP2=	16000
	BITMAP3=	24000
DRAW:;A2=SURFLIST
		lea	SURFACES2(PC),A1
	move.l  A2,A6
SF1:	move.l  (A2),D0
	bmi.s	SF7
	move.l  D0,A0
	move.l  A1,(A2)+
	addq.l  #2,A0
	move.l  A1,A5
	addq.l  #4,A1
	move.w  (A0)+,(A1)+
	move.w  #$0fff,D0
	move.l  A0,A4
	move.l	#$00,D4
SF2:	move.w  (A0)+,D2
	bmi.s	SF3
	move.w  (A0)+,D3
	addq.b  #1,D4
	cmp.w	D3,D0
	bcs.s	SF2
	move.w  D3,D0
	move.w  D4,D5
	move.l  A0,A3
	bra.s	SF2
SF3:	subq.l  #4,A3
	move.l  A3,A0
SF4:	move.l  (A3)+,(A1)+
	bpl.s	SF4
	subq.l  #4,A1
	subq.w  #2,D5
	bmi.s	SF6
SF5:	move.l  (A4)+,(A1)+
	dbf	D5,SF5
SF6:	move.l  A1,(A5)
	clr.l	(A1)+
	bra.s	SF1
SF7:	move.l  A6,-(A7)
	bsr.w	SF8
	move.l  (A7)+,A2
	bra.w	SF33
***********************************************************
SF8:	lea	SURFACES3(PC),A3
	lea	LINETAB,A4
SF9:	move.l  (A6),D0
	bpl.s	SF10
	rts
SF10:	move.l  D0,A0
	move.l  A3,(A6)+
	move.l  (A0)+,A1
	move.w  (A0)+,(A3)+
	subq.w  #8,A1
	cmpa.l  A0,A1
	beq.w	SF22
	addq.w  #8,A1
	move.l	#$00,D0
	move.w  (A0)+,D0
	move.l  D0,D1
	move.w  (A0)+,A2
	move.w  A2,(A3)+
	move.w  A2,A5
	move.l	#$00,D7
SF11:	move.w  (A0)+,D4
	move.w  D4,V1
	move.w  (A0)+,D3
	move.w  D3,V4
	sub.w	A2,D3
	bmi.w	SF21
	bne.s	SF12
	move.w  D4,D0
	bra.s	SF11
SF12:	sub.w	D0,D4
	move.w  D3,A2
	adda.w  A2,A2
	muls.W	2(A4,A2.W),D4
	add.l	D4,D4
	move.w  D4,A2
	swap	D4
SF13:	move.w  -(A1),D6
	move.w  -(A1),D5
	move.w  D6,V3
	move.w  D5,V2
	sub.w	A5,D6
	bmi.w	SF21
	bne.s	SF14
	move.w  D5,D1
	bra.s	SF13
SF14:	sub.w	D1,D5
	move.w  D6,A5
	adda.w  A5,A5
	muls.W 2(A4,A5.W),D5
	add.l	D5,D5
	move.w  D5,A5
	swap	D5
SF15:
	add.w	A2,D7
	addx.w  D4,D0
	add.w	A5,D2
	addx.w  D5,D1
	move.w  D0,(A3)+
	move.w  D1,(A3)+
	dbf	D3,SF18
	move.w  V1,D0
	clr.w	D7
	move.w  V4,A2
SF16:	move.w  (A0)+,D4
	move.w  D4,V1
	move.w  (A0)+,D3
	move.w  D3,V4
	sub.w	A2,D3
	bmi.s	SF21
	bne.s	SF17
	move.w  D4,D0
	bra.s	SF16
SF17:	sub.w	D0,D4
	move.w  D3,A2
	adda.w  A2,A2
	muls.W	0(A4,A2.W),D4
	add.l	D4,D4
	move.w  D4,A2
	swap	D4
	subq.w  #1,D3
SF18:	dbf	D6,SF15
	move.w  V2,D1
	ext.l	D1
	move.w  V3,A5
SF19:	move.w  -(A1),D6
	move.w  -(A1),D5
	move.w  D6,V3
	move.w  D5,V2
	sub.w	A5,D6
	bmi.s	SF21
	bne.s	SF20
	move.w  D5,D1
	bra.s	SF19
SF20:	sub.w	D1,D5
	move.w  D6,A5
	adda.w  A5,A5
	muls.W	0(A4,A5.W),D5
	add.l	D5,D5
	move.w  D5,A5
	swap	D5
	subq.w  #1,D6
	bra.w	SF15
SF21:	move.w  #$ffff,(A3)+
	bra.w	SF9
;--------------------------------------------------------
SF22:	movem.w (A0)+,D3/D2/D1/D0
	move.w  D1,(A3)+
	cmp.w	D1,D3
	bne.s	SF24
	cmp.w	D0,D2
	bcc.s	SF23
	move.w  D2,(A3)+
	move.w  D0,(A3)+
	move.w  #$ffff,(A3)+
	bra.w	SF9
SF23:	move.w  D0,(A3)+
	move.w  D2,(A3)+
	move.w  #$ffff,(A3)+
	bra.w	SF9
SF24:	cmp.w	D0,D2
	bne.w	SF26
	sub.w	D1,D3
SF25:	move.w  D0,(A3)+
	move.w  D0,(A3)+
	dbf	D3,SF25
	move.w  D3,(A3)+
	bra.w	SF9
SF26:	cmp.w	D0,D2
	bcc.s	SF29
	move.w  D0,D5
	sub.w	D2,D0
	sub.w	D1,D3
	add.w	D3,D3
	mulu.W	0(A4,D3.W),D0
	add.l	D0,D0
	lsr.w	#1,D3
	subQ.w  #1,D3
	move.w  D5,D4
	move.w  D5,(A3)+
	move.w  D4,(A3)+
SF27:	move.w  D5,D4
	subq.w  #1,D4
	swap	D5
	sub.l	D0,D5
	swap	D5
	cmp.w	D5,D4
	bcc.s	SF28
	addq.w  #1,D4
SF28:	move.w  D5,(A3)+
	move.w  D4,(A3)+
	dbf	D3,SF27
	move.w  D3,(A3)+
	bra.w	SF9
SF29:	sub.w	D0,D2
	sub.w	D1,D3
	add.w	D3,D3
	mulu.W	0(A4,D3.W),D2
	add.l	D2,D2
	lsr.w	#1,D3
	subQ.w  #1,D3
	move.w  D0,D4
	move.w  D4,(A3)+
	move.w  D0,(A3)+
SF30:	move.w  D0,D4
	addq.w  #1,D4
	swap	D0
	add.l	D2,D0
	swap	D0
	cmp.w	D4,D0
	bcc.s	SF31
	subq.w  #1,D4
SF31:	move.w  D4,(A3)+
	move.w  D0,(A3)+
	dbf	D3,SF30
	move.w  D3,(A3)+
	bra.w	SF9
*************************************************************
SF32:	move.L	MOUAI,A2
	bra.w	SF35
SF34:	rts
SF33:	MOVe.L	#$00,D6
	move.L	#-1,D7
	move.L	#$28,D0
	move.L	#$20,D1
SF35:	move.l  (A2)+,D3
	bmi.w	SF34
	move.l  D3,A0
	move.L  A2,MOUAI
	move.w  (A0)+,D3
;	 bmi.w	SF38  PAS ENCORE AU POINT...
;----------------------------------------
	add.w	D3,D3
	move.w  COLORPT(PC,D3.W),D3
	lea	COLORPT(PC,D3.W),A2
	move.w  (A0)+,D2
	add.w	D2,D2
	LEA.L	POS(PC),A3
	move.l  BITMP,A1
	MOVE.W  0(A3,D2.W),D3	;D3 EST * PAR 4 !!!
	ASR.W	#2,D3
	ADD.W	D3,A1
	move.w  (A0)+,D2
	bmi.w	SF32
SF41:	move.w  (A0)+,D3
	cmp.w	D2,D3
	bhi.s	SF36
	exg	D2,D3
SF36:	move.l	#$00,D5
	move.l	#$1f,D4
	sub.w	D3,D4
	bset	D4,D5
	subq.l  #1,D5
	move.w  D2,D4
	andi.w  #$001f,D4
	sub.w	D4,D2
	add.w	D4,D4
	add.w	D4,D4
	move.l  BORDERS(PC,D4.W),D4
	sub.w	D2,D3
	lsr.w	#3,D2
	move.l  A1,A3
	adda.w  D2,A3
	adda.w  D0,A1
	sub.w	D1,D3
	jmp	(A2)
***********************************************************
COLORPT:
	DC.W	$0160,$0208,$02b0,$0358,$0400,$04a8,$0550,$05f8
	DC.W	$06a0,$0748,$07f0,$0898,$0940,$09e8,$0a90,$0b38
BORDERS:
	DC.W	$0000,$0000,$8000,$0000,$c000,$0000,$e000,$0000
	DC.W	$f000,$0000,$f800,$0000,$fc00,$0000,$fe00,$0000
	DC.W	$ff00,$0000,$ff80,$0000,$ffc0,$0000,$ffe0,$0000
	DC.W	$fff0,$0000,$fff8,$0000,$fffc,$0000,$fffe,$0000
	DC.W	$ffff,$0000,$fFFf,$8000,$ffff,$c000,$ffff,$e000
	DC.W	$ffff,$f000,$ffff,$f800,$ffff,$fc00,$ffff,$fe00
	DC.W	$ffff,$ff00,$ffff,$ff80,$ffff,$ffc0,$ffff,$ffe0
	DC.W	$ffff,$fff0,$ffff,$fff8,$ffff,$fffc,$ffff,$fffe
	DC.W	$7fff,$ffff,$3fff,$ffff,$1fff,$ffff,$0fff,$ffff
	DC.W	$07ff,$ffff,$03ff,$ffff,$01ff,$ffff,$00ff,$ffff
	DC.W	$007f,$ffff,$003f,$ffff,$001f,$ffff,$000f,$ffff
	DC.W	$0007,$ffff,$0003,$ffff,$0001,$ffff,$0000,$ffff
	DC.W	$0000,$7fff,$0000,$3fff,$0000,$1fff,$0000,$0fff
	DC.W	$0000,$07ff,$0000,$03ff,$0000,$01ff,$0000,$00ff
	DC.W	$0000,$007f,$0000,$003f,$0000,$001f,$0000,$000f
	DC.W	$0000,$0007,$0000,$0003,$0000,$0001,$0000,$0000
	DC.W	$0000,$8000,$c000,$e000,$f000,$f800,$fc00,$fe00
	DC.W	$ff00,$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe
	DC.W	$7fff,$3fff,$1fff,$0fff,$07ff,$03ff,$01ff,$00ff
	DC.W	$007f,$003f,$001f,$000f,$0007,$0003,$0001,$0000
;**********************************************************
	bpl.s	SF40
	or.l	D4,D5
	and.l	D5,(A3)
	and.l	D5,BITMAP1(A3)
	and.l	D5,BITMAP2(A3)
	and.l	D5,BITMAP3(A3)
	not.l	D5
	move.w  (A0)+,D2
	bpl.w	SF41
	bra.w	SF32
SF40:	lea	BITMAP1(A3),A4
	lea	BITMAP1(A4),A5
	lea	BITMAP1(A5),A6
	and.l	D4,(A3)+
	and.l	D4,(A4)+
	and.l	D4,(A5)+
	and.l	D4,(A6)+
	not.l	D4
	sub.w	D1,D3
	bmi.s	SF42
	move.l  D6,(A3)+
	move.l  D6,(A4)+
	move.l  D6,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF42
	move.l  D6,(A3)+
	move.l  D6,(A4)+
	move.l  D6,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF42
	move.l  D6,(A3)+
	move.l  D6,(A4)+
	move.l  D6,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF42
	move.l  D6,(A3)+
	move.l  D6,(A4)+
	move.l  D6,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF42
	move.l  D6,(A3)+
	move.l  D6,(A4)+
	move.l  D6,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF42
	move.l  D6,(A3)+
	move.l  D6,(A4)+
	move.l  D6,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF42
	move.l  D6,(A3)+
	move.l  D6,(A4)+
	move.l  D6,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF42
	move.l  D6,(A3)+
	move.l  D6,(A4)+
	move.l  D6,(A5)+
	move.l  D6,(A6)+
SF42:	and.l	D5,(A3)+
	and.l	D5,(A4)+
	and.l	D5,(A5)+
	and.l	D5,(A6)+
	not.l	D5
	move.w  (A0)+,D2
	bpl.w	SF41
	bra.w	SF32
	bpl.s	SF43
	or.l	D4,D5
	and.l	D5,BITMAP1(A3)
	and.l	D5,BITMAP2(A3)
	and.l	D5,BITMAP3(A3)
	not.l	D5
	or.l	D5,(A3)
	move.w  (A0)+,D2
	bpl.w	SF41
	bra.w	SF32
SF43:	lea	BITMAP1(A3),A4
	lea	BITMAP1(A4),A5
	lea	BITMAP1(A5),A6
	and.l	D4,(A4)+
	and.l	D4,(A5)+
	and.l	D4,(A6)+
	not.l	D4
	or.l	D4,(A3)+
	sub.w	D1,D3
	bmi.s	SF44
	move.l  D7,(A3)+
	move.l  D6,(A4)+
	move.l  D6,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF44
	move.l  D7,(A3)+
	move.l  D6,(A4)+
	move.l  D6,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF44
	move.l  D7,(A3)+
	move.l  D6,(A4)+
	move.l  D6,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF44
	move.l  D7,(A3)+
	move.l  D6,(A4)+
	move.l  D6,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF44
	move.l  D7,(A3)+
	move.l  D6,(A4)+
	move.l  D6,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF44
	move.l  D7,(A3)+
	move.l  D6,(A4)+
	move.l  D6,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF44
	move.l  D7,(A3)+
	move.l  D6,(A4)+
	move.l  D6,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF44
	move.l  D7,(A3)+
	move.l  D6,(A4)+
	move.l  D6,(A5)+
	move.l  D6,(A6)+
SF44:	and.l	D5,(A4)+
	and.l	D5,(A5)+
	and.l	D5,(A6)+
	not.l	D5
	or.l	D5,(A3)+
	move.w  (A0)+,D2
	bpl.w	SF41
	bra.w	SF32
	bpl.s	SF45
	or.l	D4,D5
	and.l	D5,(A3)
	and.l	D5,BITMAP2(A3)
	and.l	D5,BITMAP3(A3)
	not.l	D5
	or.l	D5,BITMAP1(A3)
	move.w  (A0)+,D2
	bpl.w	SF41
	bra.w	SF32
SF45:	lea	BITMAP1(A3),A4
	lea	BITMAP1(A4),A5
	lea	BITMAP1(A5),A6
	and.l	D4,(A3)+
	and.l	D4,(A5)+
	and.l	D4,(A6)+
	not.l	D4
	or.l	D4,(A4)+
	sub.w	D1,D3
	bmi.s	SF46
	move.l  D6,(A3)+
	move.l  D7,(A4)+
	move.l  D6,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF46
	move.l  D6,(A3)+
	move.l  D7,(A4)+
	move.l  D6,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF46
	move.l  D6,(A3)+
	move.l  D7,(A4)+
	move.l  D6,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF46
	move.l  D6,(A3)+
	move.l  D7,(A4)+
	move.l  D6,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF46
	move.l  D6,(A3)+
	move.l  D7,(A4)+
	move.l  D6,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF46
	move.l  D6,(A3)+
	move.l  D7,(A4)+
	move.l  D6,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF46
	move.l  D6,(A3)+
	move.l  D7,(A4)+
	move.l  D6,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF46
	move.l  D6,(A3)+
	move.l  D7,(A4)+
	move.l  D6,(A5)+
	move.l  D6,(A6)+
SF46:	and.l	D5,(A3)+
	and.l	D5,(A5)+
	and.l	D5,(A6)+
	not.l	D5
	or.l	D5,(A4)+
	move.w  (A0)+,D2
	bpl.w	SF41
	bra.w	SF32
	bpl.s	SF47
	or.l	D4,D5
	and.l	D5,BITMAP2(A3)
	and.l	D5,BITMAP3(A3)
	not.l	D5
	or.l	D5,(A3)
	or.l	D5,BITMAP1(A3)
	move.w  (A0)+,D2
	bpl.w	SF41
	bra.w	SF32
SF47:	lea	BITMAP1(A3),A4
	lea	BITMAP1(A4),A5
	lea	BITMAP1(A5),A6
	and.l	D4,(A5)+
	and.l	D4,(A6)+
	not.l	D4
	or.l	D4,(A3)+
	or.l	D4,(A4)+
	sub.w	D1,D3
	bmi.s	SF48
	move.l  D7,(A3)+
	move.l  D7,(A4)+
	move.l  D6,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF48
	move.l  D7,(A3)+
	move.l  D7,(A4)+
	move.l  D6,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF48
	move.l  D7,(A3)+
	move.l  D7,(A4)+
	move.l  D6,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF48
	move.l  D7,(A3)+
	move.l  D7,(A4)+
	move.l  D6,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF48
	move.l  D7,(A3)+
	move.l  D7,(A4)+
	move.l  D6,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF48
	move.l  D7,(A3)+
	move.l  D7,(A4)+
	move.l  D6,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF48
	move.l  D7,(A3)+
	move.l  D7,(A4)+
	move.l  D6,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF48
	move.l  D7,(A3)+
	move.l  D7,(A4)+
	move.l  D6,(A5)+
	move.l  D6,(A6)+
SF48:	and.l	D5,(A5)+
	and.l	D5,(A6)+
	not.l	D5
	or.l	D5,(A3)+
	or.l	D5,(A4)+
	move.w  (A0)+,D2
	bpl.w	SF41
	bra.w	SF32
	bpl.s	SF49
	or.l	D4,D5
	and.l	D5,(A3)
	and.l	D5,BITMAP1(A3)
	and.l	D5,BITMAP3(A3)
	not.l	D5
	or.l	D5,BITMAP2(A3)
	move.w  (A0)+,D2
	bpl.w	SF41
	bra.w	SF32
SF49:	lea	BITMAP1(A3),A4
	lea	BITMAP1(A4),A5
	lea	BITMAP1(A5),A6
	and.l	D4,(A3)+
	and.l	D4,(A4)+
	and.l	D4,(A6)+
	not.l	D4
	or.l	D4,(A5)+
	sub.w	D1,D3
	bmi.s	SF50
	move.l  D6,(A3)+
	move.l  D6,(A4)+
	move.l  D7,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF50
	move.l  D6,(A3)+
	move.l  D6,(A4)+
	move.l  D7,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF50
	move.l  D6,(A3)+
	move.l  D6,(A4)+
	move.l  D7,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF50
	move.l  D6,(A3)+
	move.l  D6,(A4)+
	move.l  D7,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF50
	move.l  D6,(A3)+
	move.l  D6,(A4)+
	move.l  D7,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF50
	move.l  D6,(A3)+
	move.l  D6,(A4)+
	move.l  D7,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF50
	move.l  D6,(A3)+
	move.l  D6,(A4)+
	move.l  D7,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF50
	move.l  D6,(A3)+
	move.l  D6,(A4)+
	move.l  D7,(A5)+
	move.l  D6,(A6)+
SF50:	and.l	D5,(A3)+
	and.l	D5,(A4)+
	and.l	D5,(A6)+
	not.l	D5
	or.l	D5,(A5)+
	move.w  (A0)+,D2
	bpl.w	SF41
	bra.w	SF32
	bpl.s	SF51
	or.l	D4,D5
	and.l	D5,BITMAP1(A3)
	and.l	D5,BITMAP3(A3)
	not.l	D5
	or.l	D5,(A3)
	or.l	D5,BITMAP2(A3)
	move.w  (A0)+,D2
	bpl.w	SF41
	bra.w	SF32
SF51:	lea	BITMAP1(A3),A4
	lea	BITMAP1(A4),A5
	lea	BITMAP1(A5),A6
	and.l	D4,(A4)+
	and.l	D4,(A6)+
	not.l	D4
	or.l	D4,(A3)+
	or.l	D4,(A5)+
	sub.w	D1,D3
	bmi.s	SF52
	move.l  D7,(A3)+
	move.l  D6,(A4)+
	move.l  D7,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF52
	move.l  D7,(A3)+
	move.l  D6,(A4)+
	move.l  D7,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF52
	move.l  D7,(A3)+
	move.l  D6,(A4)+
	move.l  D7,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF52
	move.l  D7,(A3)+
	move.l  D6,(A4)+
	move.l  D7,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF52
	move.l  D7,(A3)+
	move.l  D6,(A4)+
	move.l  D7,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF52
	move.l  D7,(A3)+
	move.l  D6,(A4)+
	move.l  D7,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF52
	move.l  D7,(A3)+
	move.l  D6,(A4)+
	move.l  D7,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF52
	move.l  D7,(A3)+
	move.l  D6,(A4)+
	move.l  D7,(A5)+
	move.l  D6,(A6)+
SF52:	and.l	D5,(A4)+
	and.l	D5,(A6)+
	not.l	D5
	or.l	D5,(A3)+
	or.l	D5,(A5)+
	move.w  (A0)+,D2
	bpl.w	SF41
	bra.w	SF32
	bpl.s	SF53
	or.l	D4,D5
	and.l	D5,(A3)
	and.l	D5,BITMAP3(A3)
	not.l	D5
	or.l	D5,BITMAP1(A3)
	or.l	D5,BITMAP2(A3)
	move.w  (A0)+,D2
	bpl.w	SF41
	bra.w	SF32
SF53:	lea	BITMAP1(A3),A4
	lea	BITMAP1(A4),A5
	lea	BITMAP1(A5),A6
	and.l	D4,(A3)+
	and.l	D4,(A6)+
	not.l	D4
	or.l	D4,(A4)+
	or.l	D4,(A5)+
	sub.w	D1,D3
	bmi.s	SF54
	move.l  D6,(A3)+
	move.l  D7,(A4)+
	move.l  D7,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF54
	move.l  D6,(A3)+
	move.l  D7,(A4)+
	move.l  D7,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF54
	move.l  D6,(A3)+
	move.l  D7,(A4)+
	move.l  D7,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF54
	move.l  D6,(A3)+
	move.l  D7,(A4)+
	move.l  D7,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF54
	move.l  D6,(A3)+
	move.l  D7,(A4)+
	move.l  D7,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF54
	move.l  D6,(A3)+
	move.l  D7,(A4)+
	move.l  D7,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF54
	move.l  D6,(A3)+
	move.l  D7,(A4)+
	move.l  D7,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF54
	move.l  D6,(A3)+
	move.l  D7,(A4)+
	move.l  D7,(A5)+
	move.l  D6,(A6)+
SF54:	and.l	D5,(A3)+
	and.l	D5,(A6)+
	not.l	D5
	or.l	D5,(A4)+
	or.l	D5,(A5)+
	move.w  (A0)+,D2
	bpl.w	SF41
	bra.w	SF32
	bpl.s	SF55
	or.l	D4,D5
	and.l	D5,BITMAP3(A3)
	not.l	D5
	or.l	D5,(A3)
	or.l	D5,BITMAP1(A3)
	or.l	D5,BITMAP2(A3)
	move.w  (A0)+,D2
	bpl.w	SF41
	bra.w	SF32
SF55:	lea	BITMAP1(A3),A4
	lea	BITMAP1(A4),A5
	lea	BITMAP1(A5),A6
	and.l	D4,(A6)+
	not.l	D4
	or.l	D4,(A3)+
	or.l	D4,(A4)+
	or.l	D4,(A5)+
	sub.w	D1,D3
	bmi.s	SF56
	move.l  D7,(A3)+
	move.l  D7,(A4)+
	move.l  D7,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF56
	move.l  D7,(A3)+
	move.l  D7,(A4)+
	move.l  D7,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF56
	move.l  D7,(A3)+
	move.l  D7,(A4)+
	move.l  D7,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF56
	move.l  D7,(A3)+
	move.l  D7,(A4)+
	move.l  D7,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF56
	move.l  D7,(A3)+
	move.l  D7,(A4)+
	move.l  D7,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF56
	move.l  D7,(A3)+
	move.l  D7,(A4)+
	move.l  D7,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF56
	move.l  D7,(A3)+
	move.l  D7,(A4)+
	move.l  D7,(A5)+
	move.l  D6,(A6)+
	sub.w	D1,D3
	bmi.s	SF56
	move.l  D7,(A3)+
	move.l  D7,(A4)+
	move.l  D7,(A5)+
	move.l  D6,(A6)+
SF56:	and.l	D5,(A6)+
	not.l	D5
	or.l	D5,(A3)+
	or.l	D5,(A4)+
	or.l	D5,(A5)+
	move.w  (A0)+,D2
	bpl.w	SF41
	bra.w	SF32
	bpl.s	SF57
	or.l	D4,D5
	and.l	D5,(A3)
	and.l	D5,BITMAP1(A3)
	and.l	D5,BITMAP2(A3)
	not.l	D5
	or.l	D5,BITMAP3(A3)
	move.w  (A0)+,D2
	bpl.w	SF41
	bra.w	SF32
SF57:	lea	BITMAP1(A3),A4
	lea	BITMAP1(A4),A5
	lea	BITMAP1(A5),A6
	and.l	D4,(A3)+
	and.l	D4,(A4)+
	and.l	D4,(A5)+
	not.l	D4
	or.l	D4,(A6)+
	sub.w	D1,D3
	bmi.s	SF58
	move.l  D6,(A3)+
	move.l  D6,(A4)+
	move.l  D6,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF58
	move.l  D6,(A3)+
	move.l  D6,(A4)+
	move.l  D6,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF58
	move.l  D6,(A3)+
	move.l  D6,(A4)+
	move.l  D6,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF58
	move.l  D6,(A3)+
	move.l  D6,(A4)+
	move.l  D6,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF58
	move.l  D6,(A3)+
	move.l  D6,(A4)+
	move.l  D6,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF58
	move.l  D6,(A3)+
	move.l  D6,(A4)+
	move.l  D6,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF58
	move.l  D6,(A3)+
	move.l  D6,(A4)+
	move.l  D6,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF58
	move.l  D6,(A3)+
	move.l  D6,(A4)+
	move.l  D6,(A5)+
	move.l  D7,(A6)+
SF58:	and.l	D5,(A3)+
	and.l	D5,(A4)+
	and.l	D5,(A5)+
	not.l	D5
	or.l	D5,(A6)+
	move.w  (A0)+,D2
	bpl.w	SF41
	bra.w	SF32
	bpl.s	SF59
	or.l	D4,D5
	and.l	D5,BITMAP1(A3)
	and.l	D5,BITMAP2(A3)
	not.l	D5
	or.l	D5,(A3)
	or.l	D5,BITMAP3(A3)
	move.w  (A0)+,D2
	bpl.w	SF41
	bra.w	SF32
SF59:	lea	BITMAP1(A3),A4
	lea	BITMAP1(A4),A5
	lea	BITMAP1(A5),A6
	and.l	D4,(A4)+
	and.l	D4,(A5)+
	not.l	D4
	or.l	D4,(A3)+
	or.l	D4,(A6)+
	sub.w	D1,D3
	bmi.s	SF60
	move.l  D7,(A3)+
	move.l  D6,(A4)+
	move.l  D6,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF60
	move.l  D7,(A3)+
	move.l  D6,(A4)+
	move.l  D6,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF60
	move.l  D7,(A3)+
	move.l  D6,(A4)+
	move.l  D6,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF60
	move.l  D7,(A3)+
	move.l  D6,(A4)+
	move.l  D6,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF60
	move.l  D7,(A3)+
	move.l  D6,(A4)+
	move.l  D6,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF60
	move.l  D7,(A3)+
	move.l  D6,(A4)+
	move.l  D6,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF60
	move.l  D7,(A3)+
	move.l  D6,(A4)+
	move.l  D6,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF60
	move.l  D7,(A3)+
	move.l  D6,(A4)+
	move.l  D6,(A5)+
	move.l  D7,(A6)+
SF60:	and.l	D5,(A4)+
	and.l	D5,(A5)+
	not.l	D5
	or.l	D5,(A3)+
	or.l	D5,(A6)+
	move.w  (A0)+,D2
	bpl.w	SF41
	bra.w	SF32
	bpl.s	SF61
	or.l	D4,D5
	and.l	D5,(A3)
	and.l	D5,BITMAP2(A3)
	not.l	D5
	or.l	D5,BITMAP1(A3)
	or.l	D5,BITMAP3(A3)
	move.w  (A0)+,D2
	bpl.w	SF41
	bra.w	SF32
SF61:	lea	BITMAP1(A3),A4
	lea	BITMAP1(A4),A5
	lea	BITMAP1(A5),A6
	and.l	D4,(A3)+
	and.l	D4,(A5)+
	not.l	D4
	or.l	D4,(A4)+
	or.l	D4,(A6)+
	sub.w	D1,D3
	bmi.s	SF62
	move.l  D6,(A3)+
	move.l  D7,(A4)+
	move.l  D6,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF62
	move.l  D6,(A3)+
	move.l  D7,(A4)+
	move.l  D6,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF62
	move.l  D6,(A3)+
	move.l  D7,(A4)+
	move.l  D6,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF62
	move.l  D6,(A3)+
	move.l  D7,(A4)+
	move.l  D6,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF62
	move.l  D6,(A3)+
	move.l  D7,(A4)+
	move.l  D6,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF62
	move.l  D6,(A3)+
	move.l  D7,(A4)+
	move.l  D6,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF62
	move.l  D6,(A3)+
	move.l  D7,(A4)+
	move.l  D6,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF62
	move.l  D6,(A3)+
	move.l  D7,(A4)+
	move.l  D6,(A5)+
	move.l  D7,(A6)+
SF62:	and.l	D5,(A3)+
	and.l	D5,(A5)+
	not.l	D5
	or.l	D5,(A4)+
	or.l	D5,(A6)+
	move.w  (A0)+,D2
	bpl.w	SF41
	bra.w	SF32
	bpl.s	SF63
	or.l	D4,D5
	and.l	D5,BITMAP2(A3)
	not.l	D5
	or.l	D5,(A3)
	or.l	D5,BITMAP1(A3)
	or.l	D5,BITMAP3(A3)
	move.w  (A0)+,D2
	bpl.w	SF41
	bra.w	SF32
SF63:	lea	BITMAP1(A3),A4
	lea	BITMAP1(A4),A5
	lea	BITMAP1(A5),A6
	and.l	D4,(A5)+
	not.l	D4
	or.l	D4,(A3)+
	or.l	D4,(A4)+
	or.l	D4,(A6)+
	sub.w	D1,D3
	bmi.s	SF64
	move.l  D7,(A3)+
	move.l  D7,(A4)+
	move.l  D6,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF64
	move.l  D7,(A3)+
	move.l  D7,(A4)+
	move.l  D6,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF64
	move.l  D7,(A3)+
	move.l  D7,(A4)+
	move.l  D6,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF64
	move.l  D7,(A3)+
	move.l  D7,(A4)+
	move.l  D6,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF64
	move.l  D7,(A3)+
	move.l  D7,(A4)+
	move.l  D6,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF64
	move.l  D7,(A3)+
	move.l  D7,(A4)+
	move.l  D6,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF64
	move.l  D7,(A3)+
	move.l  D7,(A4)+
	move.l  D6,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF64
	move.l  D7,(A3)+
	move.l  D7,(A4)+
	move.l  D6,(A5)+
	move.l  D7,(A6)+
SF64:	and.l	D5,(A5)+
	not.l	D5
	or.l	D5,(A3)+
	or.l	D5,(A4)+
	or.l	D5,(A6)+
	move.w  (A0)+,D2
	bpl.w	SF41
	bra.w	SF32
	bpl.s	SF65
	or.l	D4,D5
	and.l	D5,(A3)
	and.l	D5,BITMAP1(A3)
	not.l	D5
	or.l	D5,BITMAP2(A3)
	or.l	D5,BITMAP3(A3)
	move.w  (A0)+,D2
	bpl.w	SF41
	bra.w	SF32
SF65:	lea	BITMAP1(A3),A4
	lea	BITMAP1(A4),A5
	lea	BITMAP1(A5),A6
	and.l	D4,(A3)+
	and.l	D4,(A4)+
	not.l	D4
	or.l	D4,(A5)+
	or.l	D4,(A6)+
	sub.w	D1,D3
	bmi.s	SF66
	move.l  D6,(A3)+
	move.l  D6,(A4)+
	move.l  D7,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF66
	move.l  D6,(A3)+
	move.l  D6,(A4)+
	move.l  D7,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF66
	move.l  D6,(A3)+
	move.l  D6,(A4)+
	move.l  D7,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF66
	move.l  D6,(A3)+
	move.l  D6,(A4)+
	move.l  D7,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF66
	move.l  D6,(A3)+
	move.l  D6,(A4)+
	move.l  D7,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF66
	move.l  D6,(A3)+
	move.l  D6,(A4)+
	move.l  D7,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF66
	move.l  D6,(A3)+
	move.l  D6,(A4)+
	move.l  D7,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF66
	move.l  D6,(A3)+
	move.l  D6,(A4)+
	move.l  D7,(A5)+
	move.l  D7,(A6)+
SF66:	and.l	D5,(A3)+
	and.l	D5,(A4)+
	not.l	D5
	or.l	D5,(A5)+
	or.l	D5,(A6)+
	move.w  (A0)+,D2
	bpl.w	SF41
	bra.w	SF32
	bpl.s	SF67
	or.l	D4,D5
	and.l	D5,BITMAP1(A3)
	not.l	D5
	or.l	D5,(A3)
	or.l	D5,BITMAP2(A3)
	or.l	D5,BITMAP3(A3)
	move.w  (A0)+,D2
	bpl.w	SF41
	bra.w	SF32
SF67:	lea	BITMAP1(A3),A4
	lea	BITMAP1(A4),A5
	lea	BITMAP1(A5),A6
	and.l	D4,(A4)+
	not.l	D4
	or.l	D4,(A3)+
	or.l	D4,(A5)+
	or.l	D4,(A6)+
	sub.w	D1,D3
	bmi.s	SF68
	move.l  D7,(A3)+
	move.l  D6,(A4)+
	move.l  D7,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF68
	move.l  D7,(A3)+
	move.l  D6,(A4)+
	move.l  D7,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF68
	move.l  D7,(A3)+
	move.l  D6,(A4)+
	move.l  D7,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF68
	move.l  D7,(A3)+
	move.l  D6,(A4)+
	move.l  D7,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF68
	move.l  D7,(A3)+
	move.l  D6,(A4)+
	move.l  D7,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF68
	move.l  D7,(A3)+
	move.l  D6,(A4)+
	move.l  D7,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF68
	move.l  D7,(A3)+
	move.l  D6,(A4)+
	move.l  D7,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF68
	move.l  D7,(A3)+
	move.l  D6,(A4)+
	move.l  D7,(A5)+
	move.l  D7,(A6)+
SF68:	and.l	D5,(A4)+
	not.l	D5
	or.l	D5,(A3)+
	or.l	D5,(A5)+
	or.l	D5,(A6)+
	move.w  (A0)+,D2
	bpl.w	SF41
	bra.w	SF32
	bpl.s	SF69
	or.l	D4,D5
	and.l	D5,(A3)
	not.l	D5
	or.l	D5,BITMAP1(A3)
	or.l	D5,BITMAP2(A3)
	or.l	D5,BITMAP3(A3)
	move.w  (A0)+,D2
	bpl.w	SF41
	bra.w	SF32
SF69:	lea	BITMAP1(A3),A4
	lea	BITMAP1(A4),A5
	lea	BITMAP1(A5),A6
	and.l	D4,(A3)+
	not.l	D4
	or.l	D4,(A4)+
	or.l	D4,(A5)+
	or.l	D4,(A6)+
	sub.w	D1,D3
	bmi.s	SF70
	move.l  D6,(A3)+
	move.l  D7,(A4)+
	move.l  D7,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF70
	move.l  D6,(A3)+
	move.l  D7,(A4)+
	move.l  D7,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF70
	move.l  D6,(A3)+
	move.l  D7,(A4)+
	move.l  D7,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF70
	move.l  D6,(A3)+
	move.l  D7,(A4)+
	move.l  D7,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF70
	move.l  D6,(A3)+
	move.l  D7,(A4)+
	move.l  D7,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF70
	move.l  D6,(A3)+
	move.l  D7,(A4)+
	move.l  D7,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF70
	move.l  D6,(A3)+
	move.l  D7,(A4)+
	move.l  D7,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF70
	move.l  D6,(A3)+
	move.l  D7,(A4)+
	move.l  D7,(A5)+
	move.l  D7,(A6)+
SF70:	and.l	D5,(A3)+
	not.l	D5
	or.l	D5,(A4)+
	or.l	D5,(A5)+
	or.l	D5,(A6)+
	move.w  (A0)+,D2
	bpl.w	SF41
	bra.w	SF32
	bpl.s	SF71
	or.l	D4,D5
	not.l	D5
	or.l	D5,(A3)
	or.l	D5,BITMAP1(A3)
	or.l	D5,BITMAP2(A3)
	or.l	D5,BITMAP3(A3)
	move.w  (A0)+,D2
	bpl.w	SF41
	bra.w	SF32
SF71:	lea	BITMAP1(A3),A4
	lea	BITMAP1(A4),A5
	lea	BITMAP1(A5),A6
	not.l	D4
	or.l	D4,(A3)+
	or.l	D4,(A4)+
	or.l	D4,(A5)+
	or.l	D4,(A6)+
	sub.w	D1,D3
	bmi.s	SF72
	move.l  D7,(A3)+
	move.l  D7,(A4)+
	move.l  D7,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF72
	move.l  D7,(A3)+
	move.l  D7,(A4)+
	move.l  D7,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF72
	move.l  D7,(A3)+
	move.l  D7,(A4)+
	move.l  D7,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF72
	move.l  D7,(A3)+
	move.l  D7,(A4)+
	move.l  D7,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF72
	move.l  D7,(A3)+
	move.l  D7,(A4)+
	move.l  D7,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF72
	move.l  D7,(A3)+
	move.l  D7,(A4)+
	move.l  D7,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF72
	move.l  D7,(A3)+
	move.l  D7,(A4)+
	move.l  D7,(A5)+
	move.l  D7,(A6)+
	sub.w	D1,D3
	bmi.s	SF72
	move.l  D7,(A3)+
	move.l  D7,(A4)+
	move.l  D7,(A5)+
	move.l  D7,(A6)+
SF72:	not.l	D5
	or.l	D5,(A3)+
	or.l	D5,(A4)+
	or.l	D5,(A5)+
	or.l	D5,(A6)+
	move.w  (A0)+,D2
	bpl.W	SF41
	bra.W	SF32
;---------------------------------------------
V1:	DC.L 0
V2:	DC.L 0
V3:	DC.L 0
V4:	DC.L 0
MOUAI:	DC.L 0
LINETAB:
	DC.W	$0000,$7fff,$4000,$2aaa,$2000,$1999,$1555,$1249
	DC.W	$1000,$0e38,$0ccc,$0ba2,$0aaa,$09d8,$0924,$0888
	DC.W	$0800,$0787,$071c,$06bc,$0666,$0618,$05d1,$0590
	DC.W	$0555,$051e,$04ec,$04bd,$0492,$0469,$0444,$0421
	DC.W	$0400,$03e0,$03c3,$03a8,$038e,$0375,$035e,$0348
	DC.W	$0333,$031f,$030c,$02fa,$02e8,$02d8,$02c8,$02b9
	DC.W	$02aa,$029c,$028f,$0282,$0276,$026a,$025e,$0253
	DC.W	$0249,$023e,$0234,$022b,$0222,$0219,$0210,$0208
	DC.W	$0200,$01f8,$01f0,$01e9,$01e1,$01da,$01d4,$01cd
	DC.W	$01c7,$01c0,$01ba,$01b4,$01af,$01a9,$01a4,$019e
	DC.W	$0199,$0194,$018f,$018a,$0186,$0181,$017d,$0178
	DC.W	$0174,$0170,$016c,$0168,$0164,$0160,$015c,$0158
	DC.W	$0155,$0151,$014e,$014a,$0147,$0144,$0141,$013e
	DC.W	$013b,$0138,$0135,$0132,$012f,$012c,$0129,$0127
	DC.W	$0124,$0121,$011f,$011c,$011a,$0118,$0115,$0113
	DC.W	$0111,$010e,$010c,$010a,$0108,$0106,$0104,$0102
	DC.W	$0100,$00fe,$00fc,$00fa,$00f8,$00f6,$00f4,$00f2
	DC.W	$00f0,$00ef,$00ed,$00eb,$00ea,$00e8,$00e6,$00e5
	DC.W	$00e3,$00e1,$00e0,$00de,$00dd,$00db,$00da,$00d9
	DC.W	$00d7,$00d6,$00d4,$00d3,$00d2,$00d0,$00cf,$00ce
	DC.W	$00cc,$00cb,$00ca,$00c9,$00c7,$00c6,$00c5,$00c4
	DC.W	$00c3,$00c1,$00c0,$00bf,$00be,$00bd,$00bc,$00bb
	DC.W	$00ba,$00b9,$00b8,$00b7,$00b6,$00b5,$00b4,$00b3
	DC.W	$00b2,$00b1,$00b0,$00af,$00ae,$00ad,$00ac,$00ab
	DC.W	$00aa,$00a9,$00a8,$00a8,$00a7,$00a6,$00a5,$00a4
	DC.W	$00a3,$00a3,$00a2,$00a1,$00a0,$009f,$009f,$009e
	DC.W	$009d,$009c,$009c,$009b,$009a,$0099,$0099,$0098
	DC.W	$0097,$0097,$0096,$0095,$0094,$0094,$0093,$0092
	DC.W	$0092,$0091,$0090,$0090,$008f,$008f,$008e,$008d
	DC.W	$008d,$008c,$008c,$008b,$008a,$008a,$0089,$0089
	DC.W	$0088,$0087,$0087,$0086,$0086,$0085,$0085,$0084
	DC.W	$0084,$0083,$0083,$0082,$0082,$0081,$0081,$0080
	DC.W	$0080,$007f,$007f,$007e,$007e,$007d,$007d,$007c
	DC.W	$007c,$007b,$007b,$007a,$007a,$0079,$0079,$0078
	DC.W	$0078,$0078,$0077,$0077,$0076,$0076,$0075,$0075
	DC.W	$0075,$0074,$0074,$0073,$0073,$0072,$0072,$0072
	DC.W	$0071,$0071,$0070,$0070,$0070,$006f,$006f,$006f
	DC.W	$006e,$006e,$006d,$006d,$0000,$0000,$0000,$0000
*********************************************************
POS:
	DC.W	$0000,$00a0,$0140,$01e0,$0280,$0320,$03c0,$0460
	DC.W	$0500,$05a0,$0640,$06e0,$0780,$0820,$08c0,$0960
	DC.W	$0a00,$0aa0,$0b40,$0be0,$0c80,$0d20,$0dc0,$0e60
	DC.W	$0f00,$0fa0,$1040,$10e0,$1180,$1220,$12c0,$1360	
	DC.W	$1400,$14a0,$1540,$15e0,$1680,$1720,$17c0,$1860
	DC.W	$1900,$19a0,$1a40,$1ae0,$1b80,$1c20,$1cc0,$1d60
	DC.W	$1e00,$1ea0,$1f40,$1fe0,$2080,$2120,$21c0,$2260
	DC.W	$2300,$23a0,$2440,$24e0,$2580,$2620,$26c0,$2760
	DC.W	$2800,$28a0,$2940,$29e0,$2a80,$2b20,$2bc0,$2c60
	DC.W	$2d00,$2da0,$2e40,$2ee0,$2f80,$3020,$30c0,$3160
	DC.W	$3200,$32a0,$3340,$33e0,$3480,$3520,$35c0,$3660
	DC.W	$3700,$37a0,$3840,$38e0,$3980,$3a20,$3ac0,$3b60
	DC.W	$3c00,$3ca0,$3d40,$3de0,$3e80,$3f20,$3fc0,$4060
	DC.W	$4100,$41a0,$4240,$42e0,$4380,$4420,$44c0,$4560
	DC.W	$4600,$46a0,$4740,$47e0,$4880,$4920,$49c0,$4a60
	DC.W	$4b00,$4ba0,$4c40,$4ce0,$4d80,$4e20,$4ec0,$4f60
	DC.W	$5000,$50a0,$5140,$51e0,$5280,$5320,$53c0,$5460
	DC.W	$5500,$55a0,$5640,$56e0,$5780,$5820,$58c0,$5960
	DC.W	$5a00,$5aa0,$5b40,$5be0,$5c80,$5d20,$5dc0,$5e60
	DC.W	$5f00,$5fa0,$6040,$60e0,$6180,$6220,$62c0,$6360
	DC.W	$6400,$64a0,$6540,$65e0,$6680,$6720,$67c0,$6860
	DC.W	$6900,$69a0,$6a40,$6ae0,$6b80,$6c20,$6cc0,$6d60
	DC.W	$6e00,$6ea0,$6f40,$6fe0,$7080,$7120,$71c0,$7260
	DC.W	$7300,$73a0,$7440,$74e0,$7580,$7620,$76c0,$7760
	DC.W	$7800,$78a0,$7940,$79e0,$7a80,$7b20,$7bc0,$7c60
**********************************************************
TOTO:	;A
	DC.W -95,-25,0,-85,-25,0,-80,25,0,-70,25,0,-55,-25,0,-65,-25,0
	DC.W -75,7,0,-79,-5,0,-71,-5,0,-81,-10,0,-69,-10,0
	;C
	DC.W -45,-25,0,-45,25,0,-5,25,0,-5,15,0,-35,15,0,-35,-15,0
	DC.W -5,-15,0,-5,-25,0
	;D
	DC.W 5,-25,0,5,25,0,45,25,0,45,15,0,20,15,0,20,5,0,30,5,0
	DC.W 30,-5,0,20,-5,0,20,-15,0,45,-15,0,45,-25,0
	;S
	DC.W 55,-25,0,55,-15,0,85,-15,0,85,0,0,60,0,0,60,25,0,85,25,0
	DC.W 85,15,0,70,15,0,70,10,0,95,10,0,95,-25,0
	;A
	DC.W -95,-25,40,-85,-25,40,-80,25,40
	DC.W -70,25,40,-55,-25,40,-65,-25,40
	DC.W -75,7,40,-79,-5,40,-71,-5,40,-81,-10,40,-69,-10,40
	;C
	DC.W -45,-25,40,-45,25,40,-5,25,40,-5,15,40,-35,15,40,-35,-15,40
	DC.W -5,-15,40,-5,-25,40
	;D
	DC.W 5,-25,40,5,25,40,45,25,40,45,15,40,20,15,40,20,5,40,30,5,40
	DC.W 30,-5,40,20,-5,40,20,-15,40,45,-15,40,45,-25,40
	;S
	DC.W 55,-25,40,55,-15,40,85,-15,40,85,0,40,60,0,40,60,25,40,85,25,40
	DC.W 85,15,40,70,15,40,70,10,40,95,10,40,95,-25,40
	DC.W	$7FFF
	DC.W 4,0,1,3,2, 4,6,3,4,5, 4,7,8,10,9
	DC.W 4,11,16,15,12, 4,12,15,14,13, 4,11,16,17,18
	DC.W 4,19,28,23,20, 4,20,23,22,21, 4,24,25,26,27,4,19,28,29,30
	DC.W 4,36,39,38,37,4,31,32,33,42,4,33,42,41,34,4,34
	DC.W 41,40,35,4,40,35,36,39

	DC.W 4,43,44,46,45, 4,49,46,47,48, 4,50,51,53,52
	DC.W 4,54,43+16,43+15,43+12, 4,43+12,43+15,43+14,43+13
	DC.W 4,43+11,43+16,43+17,43+18
	DC.W 4,19+43,28+43,23+43,20+43, 4,20+43,23+43,22+43,21+43
	DC.W 4,24+43,25+43,26+43,27+43, 4,19+43,28+43,29+43,30+43
	DC.W 4,36+43,39+43,38+43,37+43,4,31+43,32+43,33+43,42+43
	DC.W 4,33+43,42+43,41+43,34+43,4,34+43,41+43,40+43,35+43
	DC.W 4,40+43,35+43,36+43,39+43
	DC.W 4,0,43,45,2,4,2,45,46,3, 4,3,4,47,46, 4,5,10,53,48
	DC.W 4,1,9,52,44,4,9,10,53,52,4,0,1,44,43,4,4,5,48,47
	DC.W 4,11,12,55,54,4,12,13,13+43,12+43,4,13,14,14+43,13+43
	DC.W 4,14,15,15+43,14+43,4,15,16,16+43,15+43
	DC.W 4,16,17,17+43,16+43,4,17,18,18+43,17+43,4,11,18,18+43,11+43
	DC.W 4,20,21,21+43,20+43,4,21,22,22+43,21+43,4,22,23,23+43,22+43
	DC.W 4,23,24,24+43,23+43,4,24,25,25+43,24+43,4,25,26,26+43,25+43
	DC.W 4,26,27,27+43,26+43,4,27,28,28+43,27+43,4,28,29,29+43,29+43
	DC.W 4,29,30,30+43,29+43,4,19,30,30+43,19+43,4,19,20,20+43,19+43
	DC.W 4,31,32,32+43,31+43,4,32,33,33+43,32+43,4,33,34,34+43,33+43
	DC.W 4,34,35,35+43,34+43,4,35,36,36+43,35+43,4,36,37,37+43,36+43
	DC.W 4,37,38,38+43,37+43,4,38,39,39+43,38+43,4,39,40,40+43,39+43
	DC.W 4,40,41,41+43,40+43,4,41,42,42+43,41+43,4,42,31,31+43,42+43
	DC.W	-1
;----------------------------------
BIBI:	DC.W 0,100,0,50,86,0,86,50,0,100,0,0,86,-50,0,50,-86,0	
	DC.W 0,-100,0,-50,-86,0,-86,-50,0,-100,0,0,-86,50,0,-50,86,0
	DC.W 0,100,30,50,86,30,86,50,30,100,0,30,86,-50,30,50,-86,30
	DC.W 0,-100,30,-50,-86,30,-86,-50,30,-100,0,30,-86,50,30,-50,86,30
	DC.W -10,0,-100,10,0,-100,10,0,100,-10,0,100
	DC.W $7FFF
	DC.W 4,0,1,13,12,4,1,2,14,13,4,2,3,15,14,4,3,4,16,15,4,4,5,17,16
	DC.W 4,5,6,18,17,4,6,7,19,18,4,7,8,20,19,4,8,9,21,20
	DC.W 4,9,10,22,21,4,10,11,23,22,4,11,0,12,23,4,24,25,26,27
	DC.W 4,0,1,25,24,4,17,18,27,26
	DC.W -1
;------------
HELICO:
	DC.W	0,0,0,-135,0,5,-135,0,-5,135,0,5,135,0,-5
	DC.W	-15,-5,30,15,-5,30,15,-5,-20,-15,-5,-20
	DC.W	-35,-25,20,-15,-30,70,15,-30,70,35,-25,20
	DC.W	30,-25,-20,10,-15,-60,-10,-15,-60,-30,-25,-20
	DC.W	-35,-45,20,-15,-45,70,15,-45,70,35,-45,20,30,-45,-20
	DC.W	0,-35,-60,-30,-45,-20
	DC.W	-15,-55,50,15,-55,50,15,-55,-20,-15,-55,-20
	DC.W -30,-60,55,-25,-65,50,-35,-65,50,-35,-65,-40,-25,-65,-40
	DC.W 30,-60,55,25,-65,50,35,-65,50,35,-65,-40,25,-65,-40
	DC.W 	0,-15,-160,0,-15,-130,0,15,-150,0,15,-165
	DC.W	-25,-50,20,-30,-65,20,-25,-50,-10,-30,-65,-10
	DC.W	25,-50,20,30,-65,20,25,-50,-10,30,-65,-10,0,-5,0,$7FFF

	DC.W 4,10,11,19,18,4,9,10,18,17,4,11,19,20,12,4,10,11,6,5
	DC.W 4,18,19,25,24,4,24,25,26,27,4,9,17,23,16,4,12,20,21,13
	DC.W 4,13,21,22,14,4,16,23,22,15,4,5,6,7,8,4,1,2,3,4
	DC.W 4,17,23,27,24,4,20,21,26,25, 3,18,24,17,3,19,25,20
	DC.W 4,5,8,16,9,4,6,7,13,12,4,7,8,15,14,3,7,14,13,3,8,16,15
	DC.W 3,26,27,22,3,26,21,22,3,27,23,22,3,22,15,38,3,22,14,38
	DC.W 3,14,15,38,4,38,39,40,41,4,29,32,31,30,3,30,28,29
	DC.W 3,33,34,35,4,34,35,36,37
	DC.W -1
;-------------- FIN DE DEFINITION DES OBJETS ------
;--------------------------------------------------
VAX:	DC.W	0
VAY:	DC.W	0
VAZ:	DC.W	0
VBX:	DC.W	0
VBY:	DC.W	0
VBZ:	DC.W	0

AL:	DC.W	0
BE:	DC.W	0
GA:	DC.W	0
POSX:	DC.L	0
POSY:	DC.L	0
POSZ:	DC.L	0
OBJECT:	DC.L	BIBI
PTS2D:	DCB.W	2000,$7FFF
PTS3D:	DCB.W	2000,$7FFF
ZPROF:	DCB.W	2000,$7FFF
;©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©
SURFLIST:	DCB.L	100,-1
SURFACES:	DCB.L	1000,-1
SURFACES2:	DCB.L	1000,-1
SURFACES3:	DCB.L	1000,-1
ZFACE:	DCB.W	1000,-1

	END

