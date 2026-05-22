;APS00000000000000000000000000000000000000000000000000000000000000000000000000000000
BIT_0_2		=	0*2
BIT_3_5		=	1*2
BIT_6_8		=	2*2
BIT_6_7		=	3*2
BIT_8		=	4*2
BIT_8_B		=	5*2
BIT_9_B		=	6*2
BIT_C_F		=	7*2
BIT_MOVEM	=	8*2
BIT_11_9	=	9*2
BIT_15_14	=	10*2
BIT_9_7		=	11*2
BIT_7_0		=	12*2		
BIT_12_10	=	13*2
BIT_3		=	14*2
BIT_6_0		=	15*2


;***  Command yyyy xxxx xxxx xxxx  ****

DISStruct:
	dc.w	BIT_C_F
	dr.w	DIS_1_0000	;0000
	dr.w	DIS_MOVEB	;0001
	dr.w	DIS_MOVEL	;0010
	dr.w	DIS_MOVEW	;0011
	dr.w	DIS_1_0100	;0100
	dr.w	DIS_1_0101	;0101
	dr.w	DIS_1_0110	;0110
	dr.w	DIS_1_0111	;0111
	dr.w	DIS_1_1000	;1000
	dr.w	DIS_1_1001	;1001
	dr.w	DIS_NM_LINEA	;1010
	dr.w	DIS_1_1011	;1011
	dr.w	DIS_1_1100	;1100
	dr.w	DIS_1_1101	;1101
	dr.w	DIS_1_1110	;1110
	dr.w	DIS_NM_LINEF	;1111

;***  Command 0000 xxxy xxxx xxxx  ****

DIS_1_0000:
	dc.w	BIT_8
	dr.w	DIS_NEW2
	dr.w	DIS_NEW4

;***  Command 0000 yyy0 xxxx xxxx  ****

DIS_NEW2:
	dc.w	BIT_9_B
	dr.w	DIS_ORI
	dr.w	DIS_ANDI
	dr.w	DIS_SUBI
	dr.w	DIS_ADDI
	dr.w	DIS_NEW3
	dr.w	DIS_EORI
	dr.w	DIS_CMPI
	dr.w	DIS_NM_UNKWN

;***  Command 0000 0000 yyxx xxxx  ***

DIS_NM_UNKWN:
	dc.w	BIT_6_7
	dr.w	MOVESB.DIS_MSG	;00
	dr.w	MOVESW.DIS_MSG	;01
	dr.w	MOVESL.DIS_MSG	;10
	dr.w	DIS_NM_UNKWN2

MOVESB.DIS_MSG:	dc.b	'MOVES.B    ',0
		dc.w	$2100
MOVESW.DIS_MSG:	dc.b	'MOVES.W    ',0
		dc.w	$2100
MOVESL.DIS_MSG:	dc.b	'MOVES.L    ',0
		dc.w	$2100

DIS_NM_UNKWN2:
	dc.w	BIT_3_5
	dr.w	CASL.DIS_MSG
	dr.w	CASL.DIS_MSG
	dr.w	CASL.DIS_MSG
	dr.w	CASL.DIS_MSG
	dr.w	CASL.DIS_MSG
	dr.w	CASL.DIS_MSG
	dr.w	CASL.DIS_MSG
	dr.w	DIS_lbW000080

DIS_lbW000080:
	dc.w	BIT_0_2
	dr.w	CASL.DIS_MSG
	dr.w	CASL.DIS_MSG
	dr.w	CASL.DIS_MSG
	dr.w	CASL.DIS_MSG
	dr.w	CAS2L.DIS_MSG
	dr.w	CASL.DIS_MSG
	dr.w	CASL.DIS_MSG
	dr.w	CASL.DIS_MSG

CAS2L.DIS_MSG:	dc.b	'CAS2.L     ',0
		dc.w	$1D00
CASL.DIS_MSG:	dc.b	'CAS.L      ',0
		dc.w	$1C00

DIS_ORI:
	dc.w	BIT_3_5
	dr.w	DIS_lbW0000D2
	dr.w	DIS_lbW0000D2
	dr.w	DIS_lbW0000D2
	dr.w	DIS_lbW0000D2
	dr.w	DIS_lbW0000D2
	dr.w	DIS_lbW0000D2
	dr.w	DIS_lbW0000D2
	dr.w	DIS_lbW0000C0	;%111
	
DIS_lbW0000C0:
	dc.w	BIT_0_2
	dr.w	DIS_lbW0000D2	;000
	dr.w	DIS_lbW0000D2	;001
	dr.w	DIS_lbW0000DC	;010
	dr.w	DIS_lbW0000DC	;011
	dr.w	DIS_lbW0000FC	;100
	dr.w	DC.DIS_MSG	;101
	dr.w	DC.DIS_MSG	;110
	dr.w	DC.DIS_MSG	;111
	
DIS_lbW0000D2:
	dc.w	BIT_6_7
	dr.w	ORIB.DIS_MSG
	dr.w	ORIW.DIS_MSG
	dr.w	ORIL.DIS_MSG
	dr.w	DIS_lbW0000DC

DIS_lbW0000DC:
	dc.w	BIT_11_9
	dr.w	CMP2B.DIS_MSG
	dr.w	CMP2W.DIS_MSG		;DC.DIS_MSG
	dr.w	CMP2L.DIS_MSG		;DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	CHK2B.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG

CMP2B.DIS_MSG:	dc.b	'CMP2.B     ',0
		dc.w	$1E00

CHK2B.DIS_MSG:	dc.b	'CHK2.B     ',0
		dc.w	$1E00
		
DIS_lbW0000FC:
	dc.w	6
	dr.w	ORIB.DIS_MSG0
	dr.w	ORIW.DIS_MSG0
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG

ORIB.DIS_MSG:	dc.b	'ORI.B      ',0
		dc.w	$0401
ORIW.DIS_MSG:	dc.b	'ORI.W      ',0
		dc.w	$0502
ORIL.DIS_MSG:	dc.b	'ORI.L      ',0
		dc.w	$0603
ORIB.DIS_MSG0:	dc.b	'ORI.B      ',0
		dc.w	$040D
ORIW.DIS_MSG0:	dc.b	'ORI.W      ',0
		dc.w	$050C

DIS_ANDI:
	dc.w	2
	dr.w	DIS_lbW00017E
	dr.w	DIS_lbW00017E
	dr.w	DIS_lbW00017E
	dr.w	DIS_lbW00017E
	dr.w	DIS_lbW00017E
	dr.w	DIS_lbW00017E
	dr.w	DIS_lbW00017E
	dr.w	DIS_lbW00016C
DIS_lbW00016C:
	dc.w	0
	dr.w	DIS_lbW00017E
	dr.w	DIS_lbW00017E
	dr.w	DIS_lbW000192
	dr.w	DIS_lbW000192
	dr.w	DIS_lbW000188
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
DIS_lbW00017E:
	dc.w	6
	dr.w	ANDIB.DIS_MSG
	dr.w	ANDIW.DIS_MSG
	dr.w	ANDIL.DIS_MSG
	dr.w	DIS_lbW000192
DIS_lbW000188:
	dc.w	6
	dr.w	ANDIB.DIS_MSG0
	dr.w	ANDIW.DIS_MSG0
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
DIS_lbW000192:
	dc.w	BIT_11_9
	dr.w	CMP2W.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	CHK2W.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
CMP2W.DIS_MSG:
	dc.b	'CMP2.W     ',0
	dc.w	$1E00
CHK2W.DIS_MSG:
	dc.b	'CHK2.W     ',0
	dc.w	$1E00
ANDIB.DIS_MSG:
	dc.b	'ANDI.B     ',0
	dc.w	$0401
ANDIW.DIS_MSG:
	dc.b	'ANDI.W     ',0
	dc.w	$0502
ANDIL.DIS_MSG:
	dc.b	'ANDI.L     ',0
	dc.w	$0603
ANDIB.DIS_MSG0:
	dc.b	'ANDI.B     ',0
	dc.w	$040D
ANDIW.DIS_MSG0:
	dc.b	'ANDI.W     ',0
	dc.w	$050C
DIS_SUBI:
	dc.w	2
	dr.w	DIS_lbW00022A
	dr.w	DC.DIS_MSG
	dr.w	DIS_lbW00022A
	dr.w	DIS_lbW00022A
	dr.w	DIS_lbW00022A
	dr.w	DIS_lbW00022A
	dr.w	DIS_lbW00022A
	dr.w	DIS_lbW000218
DIS_lbW000218:
	dc.w	0
	dr.w	DIS_lbW00022A
	dr.w	DIS_lbW00022A
	dr.w	DIS_lbW000234
	dr.w	DIS_lbW000234
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
DIS_lbW00022A:
	dc.w	6
	dr.w	SUBIB.DIS_MSG
	dr.w	SUBIW.DIS_MSG
	dr.w	SUBIL.DIS_MSG
	dr.w	DIS_lbW000234
DIS_lbW000234:
	dc.w	BIT_11_9
	dr.w	CMP2L.DIS_MSG	;000
	dr.w	DC.DIS_MSG	;001
	dr.w	DC.DIS_MSG	;010
	dr.w	DC.DIS_MSG	;011
	dr.w	CHK2L.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
;;
	dc.b	'BGND       '
	dc.b	2
	dcb.b	2,0
CMP2L.DIS_MSG:
	dc.b	'CMP2.L     ',0
	dc.w	$1E00
CHK2L.DIS_MSG:
	dc.b	'CHK2.L     ',0
	dc.w	$1E00
SUBIB.DIS_MSG:
	dc.b	'SUBI.B     ',0
	dc.w	$0401
SUBIW.DIS_MSG:
	dc.b	'SUBI.W     ',0
	dc.w	$0502
SUBIL.DIS_MSG:
	dc.b	'SUBI.L     ',0
	dc.w	$0603
DIS_ADDI:
	dc.w	2
	dr.w	DIS_lbW0002BE
	dr.w	RTM.DIS_MSG
	dr.w	DIS_lbW0002BE
	dr.w	DIS_lbW0002BE
	dr.w	DIS_lbW0002BE
	dr.w	DIS_lbW0002BE
	dr.w	DIS_lbW0002BE
	dr.w	DIS_lbW0002AC
DIS_lbW0002AC:
	dc.w	0
	dr.w	DIS_lbW0002BE
	dr.w	DIS_lbW0002BE
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
DIS_lbW0002BE:
	dc.w	6
	dr.w	ADDIB.DIS_MSG
	dr.w	ADDIW.DIS_MSG
	dr.w	ADDIL.DIS_MSG
	dr.w	DIS_lbW0002C8
DIS_lbW0002C8:
	dc.w	2
	dr.w	RTM.DIS_MSG
	dr.w	RTM.DIS_MSG
	dr.w	CALLM.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	CALLM.DIS_MSG
	dr.w	CALLM.DIS_MSG
	dr.w	CALLM.DIS_MSG
RTM.DIS_MSG:
	dc.b	'RTM        ',0
	dc.b	'$',0
CALLM.DIS_MSG:
	dc.b	'CALLM      ',0
	dc.b	$1B
	dc.b	0
ADDIB.DIS_MSG:
	dc.b	'ADDI.B     ',0
	dc.b	4
	dc.b	1
ADDIW.DIS_MSG:
	dc.b	'ADDI.W     ',0
	dc.b	5
	dc.b	2
ADDIL.DIS_MSG:
	dc.b	'ADDI.L     ',0
	dc.b	6
	dc.b	3
DIS_EORI:
	dc.w	2
	dr.w	DIS_lbW000344
	dr.w	DIS_lbW000344
	dr.w	DIS_lbW000344
	dr.w	DIS_lbW000344
	dr.w	DIS_lbW000344
	dr.w	DIS_lbW000344
	dr.w	DIS_lbW000344
	dr.w	DIS_lbW000332
DIS_lbW000332:
	dc.w	0
	dr.w	DIS_lbW000344
	dr.w	DIS_lbW000344
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DIS_lbW00035C
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
DIS_lbW000344:
	dc.w	6
	dr.w	EORIB.DIS_MSG
	dr.w	EORIW.DIS_MSG
	dr.w	EORIL.DIS_MSG
	dr.w	CASB.DIS_MSG
CASB.DIS_MSG:
	dc.b	'CAS.B      ',0
	dc.w	$1C00
DIS_lbW00035C:
	dc.w	6
	dr.w	EORIB.DIS_MSG0
	dr.w	EORIW.DIS_MSG0
	dr.w	EORIL.DIS_MSG
	dr.w	DC.DIS_MSG
EORIB.DIS_MSG:
	dc.b	'EORI.B     ',0
	dc.b	4
	dc.b	1
EORIW.DIS_MSG:
	dc.b	'EORI.W     ',0
	dc.b	5
	dc.b	2
EORIL.DIS_MSG:
	dc.b	'EORI.L     ',0
	dc.b	6
	dc.b	3
EORIB.DIS_MSG0:
	dc.b	'EORI.B     ',0
	dc.b	4
	dc.b	13
EORIW.DIS_MSG0:
	dc.b	'EORI.W     ',0
	dc.b	5
	dc.b	12

DIS_CMPI:
	dc.w	BIT_3_5
	dr.w	DIS_lbW0003D0	;000
	dr.w	DC.DIS_MSG	;001
	dr.w	DIS_lbW0003D0	;010
	dr.w	DIS_lbW0003D0	;011
	dr.w	DIS_lbW0003D0	;100
	dr.w	DIS_lbW0003D0	;101
	dr.w	DIS_lbW0003D0	;110
	dr.w	DIS_lbW0003BE	;111
DIS_lbW0003BE:
	dc.w	BIT_0_2
	dr.w	DIS_lbW0003D0	;000
	dr.w	DIS_lbW0003D0	;001
	dr.w	DIS_lbW0003D0	;DC.DIS_MSG	;010
	dr.w	DC.DIS_MSG	;011
	dr.w	CAS2W.DIS_MSG	;100
	dr.w	DC.DIS_MSG	;101
	dr.w	DC.DIS_MSG	;110
	dr.w	DC.DIS_MSG	;111
DIS_lbW0003D0:
	dc.w	6
	dr.w	CMPIB.DIS_MSG
	dr.w	CMPIW.DIS_MSG
	dr.w	CMPIL.DIS_MSG
	dr.w	CASW.DIS_MSG
CAS2W.DIS_MSG:
	dc.b	'CAS2.W     ',0
	dc.b	$1D
	dc.b	0
CASW.DIS_MSG:
	dc.b	'CAS.W      ',0
	dc.b	$1C
	dc.b	0
CMPIB.DIS_MSG:
	dc.b	'CMPI.B     ',0
	dc.b	4
	dc.b	1
CMPIW.DIS_MSG:
	dc.b	'CMPI.W     ',0
	dc.b	5
	dc.b	2
CMPIL.DIS_MSG:
	dc.b	'CMPI.L     ',0
	dc.b	6
	dc.b	3
DIS_NEW3:
	dc.w	6
	dr.w	DIS_lbW00042A
	dr.w	DIS_lbW00045C
	dr.w	DIS_lbW00048E
	dr.w	DIS_lbW0004C0
DIS_lbW00042A:
	dc.w	2
	dr.w	BTST.DIS_MSG
	dr.w	BTST.DIS_MSG	;APOLLO support Ax access
	dr.w	BTST.DIS_MSG
	dr.w	BTST.DIS_MSG
	dr.w	BTST.DIS_MSG
	dr.w	BTST.DIS_MSG
	dr.w	BTST.DIS_MSG
	dr.w	DIS_lbW00043C
DIS_lbW00043C:
	dc.w	0
	dr.w	BTST.DIS_MSG
	dr.w	BTST.DIS_MSG
	dr.w	BTST.DIS_MSG
	dr.w	BTST.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
BTST.DIS_MSG:
	dc.b	'BTST       ',0
	dc.w	$0401
DIS_lbW00045C:
	dc.w	2
	dr.w	BCHG.DIS_MSG
	dr.w	BCHG.DIS_MSG
	dr.w	BCHG.DIS_MSG
	dr.w	BCHG.DIS_MSG
	dr.w	BCHG.DIS_MSG
	dr.w	BCHG.DIS_MSG
	dr.w	BCHG.DIS_MSG
	dr.w	DIS_lbW00046E
DIS_lbW00046E:
	dc.w	0
	dr.w	BCHG.DIS_MSG
	dr.w	BCHG.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
BCHG.DIS_MSG:
	dc.b	'BCHG       ',0
	dc.b	4
	dc.b	1
DIS_lbW00048E:
	dc.w	2
	dr.w	BCLR.DIS_MSG
	dr.w	BCLR.DIS_MSG
	dr.w	BCLR.DIS_MSG
	dr.w	BCLR.DIS_MSG
	dr.w	BCLR.DIS_MSG
	dr.w	BCLR.DIS_MSG
	dr.w	BCLR.DIS_MSG
	dr.w	DIS_lbW0004A0
DIS_lbW0004A0:
	dc.w	0
	dr.w	BCLR.DIS_MSG
	dr.w	BCLR.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
BCLR.DIS_MSG:
	dc.b	'BCLR       ',0
	dc.b	4
	dc.b	1
DIS_lbW0004C0:
	dc.w	2
	dr.w	BSET.DIS_MSG
	dr.w	BSET.DIS_MSG
	dr.w	BSET.DIS_MSG
	dr.w	BSET.DIS_MSG
	dr.w	BSET.DIS_MSG
	dr.w	BSET.DIS_MSG
	dr.w	BSET.DIS_MSG
	dr.w	DIS_lbW0004D2
DIS_lbW0004D2:
	dc.w	0
	dr.w	BSET.DIS_MSG
	dr.w	BSET.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
BSET.DIS_MSG:
	dc.b	'BSET       ',0
	dc.b	4
	dc.b	1
DIS_NEW4:
	dc.w	6
	dr.w	DIS_lbW0004FC
	dr.w	DIS_lbW00052E
	dr.w	DIS_lbW000560
	dr.w	DIS_lbW000592
DIS_lbW0004FC:
	dc.w	2
	dr.w	BTST.DIS_MSG0
	dr.w	MOVEPW.DIS_MSG
	dr.w	BTST.DIS_MSG0
	dr.w	BTST.DIS_MSG0
	dr.w	BTST.DIS_MSG0
	dr.w	BTST.DIS_MSG0
	dr.w	BTST.DIS_MSG0
	dr.w	DIS_lbW00050E
DIS_lbW00050E:
	dc.w	0
	dr.w	BTST.DIS_MSG0
	dr.w	BTST.DIS_MSG0
	dr.w	BTST.DIS_MSG0
	dr.w	BTST.DIS_MSG0
	dr.w	BTST.DIS_MSG0
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
BTST.DIS_MSG0:
	dc.b	'BTST       ',0
	dc.b	$87
	dc.b	1
DIS_lbW00052E:
	dc.w	2
	dr.w	BCHG.DIS_MSG0
	dr.w	MOVEPL.DIS_MSG
	dr.w	BCHG.DIS_MSG0
	dr.w	BCHG.DIS_MSG0
	dr.w	BCHG.DIS_MSG0
	dr.w	BCHG.DIS_MSG0
	dr.w	BCHG.DIS_MSG0
	dr.w	DIS_lbW000540
DIS_lbW000540:
	dc.w	0
	dr.w	BCHG.DIS_MSG0
	dr.w	BCHG.DIS_MSG0
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
BCHG.DIS_MSG0:
	dc.b	'BCHG       ',0
	dc.w	$8701
DIS_lbW000560:
	dc.w	2
	dr.w	BCLR.DIS_MSG0
	dr.w	MOVEPW.DIS_MSG0
	dr.w	BCLR.DIS_MSG0
	dr.w	BCLR.DIS_MSG0
	dr.w	BCLR.DIS_MSG0
	dr.w	BCLR.DIS_MSG0
	dr.w	BCLR.DIS_MSG0
	dr.w	DIS_lbW000572
DIS_lbW000572:
	dc.w	0
	dr.w	BCLR.DIS_MSG0
	dr.w	BCLR.DIS_MSG0
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
BCLR.DIS_MSG0:
	dc.b	'BCLR       ',0
	dc.w	$8701
DIS_lbW000592:
	dc.w	2
	dr.w	BSET.DIS_MSG0
	dr.w	MOVEPL.DIS_MSG0
	dr.w	BSET.DIS_MSG0
	dr.w	BSET.DIS_MSG0
	dr.w	BSET.DIS_MSG0
	dr.w	BSET.DIS_MSG0
	dr.w	BSET.DIS_MSG0
	dr.w	DIS_lbW0005A4
DIS_lbW0005A4:
	dc.w	0
	dr.w	BSET.DIS_MSG0
	dr.w	BSET.DIS_MSG0
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
BSET.DIS_MSG0:
	dc.b	'BSET       ',0
	dc.b	$87
	dc.b	1
MOVEPW.DIS_MSG:
	dc.b	'MOVEP.W    ',0
	dc.w	$0987
MOVEPL.DIS_MSG:
	dc.b	'MOVEP.L    ',0
	dc.b	9
	dc.b	$87
MOVEPW.DIS_MSG0:
	dc.b	'MOVEP.W    ',0
	dc.b	$87
	dc.b	9
MOVEPL.DIS_MSG0:
	dc.b	'MOVEP.L   '
	dc.w	$2000
	dc.w	$8709
DIS_MOVEB:
	dc.w	2
	dr.w	DIS_lbW000620
	dr.w	DIS_lbW000620
	dr.w	DIS_lbW000620
	dr.w	DIS_lbW000620
	dr.w	DIS_lbW000620
	dr.w	DIS_lbW000620
	dr.w	DIS_lbW000620
	dr.w	DIS_lbW00060E
DIS_lbW00060E:
	dc.w	0
	dr.w	DIS_lbW000620
	dr.w	DIS_lbW000620
	dr.w	DIS_lbW000620
	dr.w	DIS_lbW000620
	dr.w	DIS_lbW000620
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
DIS_lbW000620:
	dc.w	4
	dr.w	MOVEB.DIS_MSG
	dr.w	MOVEB.DIS_MSG
	dr.w	MOVEB.DIS_MSG
	dr.w	MOVEB.DIS_MSG
	dr.w	MOVEB.DIS_MSG
	dr.w	MOVEB.DIS_MSG
	dr.w	MOVEB.DIS_MSG
	dr.w	DIS_lbW000632
DIS_lbW000632:
	dc.w	12
	dr.w	MOVEB.DIS_MSG
	dr.w	MOVEB.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
MOVEB.DIS_MSG:
	dc.b	'MOVE.B  '
	dc.b	'  '
	dc.b	' ',0
	dc.w	$0181
DIS_MOVEL:
	dc.w	2
	dr.w	DIS_lbW000676
	dr.w	DIS_lbW000676
	dr.w	DIS_lbW000676
	dr.w	DIS_lbW000676
	dr.w	DIS_lbW000676
	dr.w	DIS_lbW000676
	dr.w	DIS_lbW000676
	dr.w	DIS_lbW000664
DIS_lbW000664:
	dc.w	0
	dr.w	DIS_lbW000676
	dr.w	DIS_lbW000676
	dr.w	DIS_lbW000676
	dr.w	DIS_lbW000676
	dr.w	DIS_lbW000676
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
DIS_lbW000676:
	dc.w	4
	dr.w	MOVEL.DIS_MSG
	dr.w	MOVEL.DIS_MSG
	dr.w	MOVEL.DIS_MSG
	dr.w	MOVEL.DIS_MSG
	dr.w	MOVEL.DIS_MSG
	dr.w	MOVEL.DIS_MSG
	dr.w	MOVEL.DIS_MSG
	dr.w	DIS_lbW000688
DIS_lbW000688:
	dc.w	12
	dr.w	MOVEL.DIS_MSG
	dr.w	MOVEL.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
MOVEL.DIS_MSG:
	dc.b	'MOVE.L'
	dc.b	'  '
	dc.b	'   ',0
	dc.w	$0383
DIS_MOVEW:
	dc.w	2
	dr.w	DIS_lbW0006CC
	dr.w	DIS_lbW0006CC
	dr.w	DIS_lbW0006CC
	dr.w	DIS_lbW0006CC
	dr.w	DIS_lbW0006CC
	dr.w	DIS_lbW0006CC
	dr.w	DIS_lbW0006CC
	dr.w	DIS_lbW0006BA
DIS_lbW0006BA:
	dc.w	0
	dr.w	DIS_lbW0006CC
	dr.w	DIS_lbW0006CC
	dr.w	DIS_lbW0006CC
	dr.w	DIS_lbW0006CC
	dr.w	DIS_lbW0006CC
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
DIS_lbW0006CC:
	dc.w	4
	dr.w	MOVEW.DIS_MSG
	dr.w	MOVEW.DIS_MSG
	dr.w	MOVEW.DIS_MSG
	dr.w	MOVEW.DIS_MSG
	dr.w	MOVEW.DIS_MSG
	dr.w	MOVEW.DIS_MSG
	dr.w	MOVEW.DIS_MSG
	dr.w	DIS_lbW0006DE
DIS_lbW0006DE:
	dc.w	12
	dr.w	MOVEW.DIS_MSG
	dr.w	MOVEW.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
MOVEW.DIS_MSG:
	dc.b	'MOVE'
	dc.b	'.W'
	dc.b	'     ',0
	dc.w	$0282
DIS_1_0100:
	dc.w	8
	dr.w	DIS_lbW0007B2
	dr.w	DIS_lbW000704
DIS_lbW000704:
	dc.w	6
	dr.w	DIS_lbW00070E
	dr.w	DC.DIS_MSG
	dr.w	DIS_lbW000740
	dr.w	DIS_lbW000772
DIS_lbW00070E:
	dc.w	2
	dr.w	CHKL.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	CHKL.DIS_MSG
	dr.w	CHKL.DIS_MSG
	dr.w	CHKL.DIS_MSG
	dr.w	CHKL.DIS_MSG
	dr.w	CHKL.DIS_MSG
	dr.w	DIS_lbW000720
DIS_lbW000720:
	dc.w	0
	dr.w	CHKL.DIS_MSG
	dr.w	CHKL.DIS_MSG
	dr.w	CHKL.DIS_MSG
	dr.w	CHKL.DIS_MSG
	dr.w	CHKL.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
CHKL.DIS_MSG:
	dc.b	'CHK.L      ',0
	dc.w	$0387
DIS_lbW000740:
	dc.w	2
	dr.w	CHKW.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	CHKW.DIS_MSG
	dr.w	CHKW.DIS_MSG
	dr.w	CHKW.DIS_MSG
	dr.w	CHKW.DIS_MSG
	dr.w	CHKW.DIS_MSG
	dr.w	DIS_lbW000752
DIS_lbW000752:
	dc.w	0
	dr.w	CHKW.DIS_MSG
	dr.w	CHKW.DIS_MSG
	dr.w	CHKW.DIS_MSG
	dr.w	CHKW.DIS_MSG
	dr.w	CHKW.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
CHKW.DIS_MSG:
	dc.b	'CHK.W      ',0
	dc.w	$0287
DIS_lbW000772:
	dc.w	2
	dr.w	EXTBL.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	LEA.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	LEA.DIS_MSG
	dr.w	LEA.DIS_MSG
	dr.w	DIS_lbW000792
EXTBL.DIS_MSG:
	dc.b	'EXTB.L     ',0
	dc.b	7
	dc.b	0
DIS_lbW000792:
	dc.w	0
	dr.w	LEA.DIS_MSG
	dr.w	LEA.DIS_MSG
	dr.w	LEA.DIS_MSG
	dr.w	LEA.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
LEA.DIS_MSG:
	dc.b	'LEA        ',0
	dc.w	$0288
DIS_lbW0007B2:
	dc.w	12
	dr.w	DIS_lbW0007C4
	dr.w	DIS_lbW000896
	dr.w	DIS_lbW000968
	dr.w	DIS_lbW000A3A
	dr.w	DIS_lbW000B0C
	dr.w	DIS_lbW000C24
	dr.w	DIS_lbW000D04
	dr.w	DIS_lbW000DEA
DIS_lbW0007C4:
	dc.w	6
	dr.w	DIS_lbW0007CE
	dr.w	DIS_lbW0007F2
	dr.w	DIS_lbW000816
	dr.w	DIS_lbW000864
DIS_lbW0007CE:
	dc.w	2
	dr.w	NEGXB.DIS_MSG
	dr.w	NEGXB.DIS_MSG	;APOLLO negx.b ax
	dr.w	NEGXB.DIS_MSG
	dr.w	NEGXB.DIS_MSG
	dr.w	NEGXB.DIS_MSG
	dr.w	NEGXB.DIS_MSG
	dr.w	NEGXB.DIS_MSG
	dr.w	DIS_lbW0007E0
DIS_lbW0007E0:
	dc.w	0
	dr.w	NEGXB.DIS_MSG
	dr.w	NEGXB.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
DIS_lbW0007F2:
	dc.w	2
	dr.w	NEGXW.DIS_MSG
	dr.w	NEGXW.DIS_MSG	;APOLLO negx.w ax
	dr.w	NEGXW.DIS_MSG
	dr.w	NEGXW.DIS_MSG
	dr.w	NEGXW.DIS_MSG
	dr.w	NEGXW.DIS_MSG
	dr.w	NEGXW.DIS_MSG
	dr.w	DIS_lbW000804
DIS_lbW000804:
	dc.w	0
	dr.w	NEGXW.DIS_MSG
	dr.w	NEGXW.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
DIS_lbW000816:
	dc.w	2
	dr.w	NEGXL.DIS_MSG
	dr.w	NEGXL.DIS_MSG	;APOLLO negx.l ax
	dr.w	NEGXL.DIS_MSG
	dr.w	NEGXL.DIS_MSG
	dr.w	NEGXL.DIS_MSG
	dr.w	NEGXL.DIS_MSG
	dr.w	NEGXL.DIS_MSG
	dr.w	DIS_lbW000828
DIS_lbW000828:
	dc.w	0
	dr.w	NEGXL.DIS_MSG
	dr.w	NEGXL.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
NEGXB.DIS_MSG:
	dc.b	'NEGX.B     ',0
	dc.b	1
	dc.b	0
NEGXW.DIS_MSG:
	dc.b	'NEGX.W     ',0
	dc.w	$0200
NEGXL.DIS_MSG:
	dc.b	'NEGX.L     ',0
	dc.w	$0300
DIS_lbW000864:
	dc.w	2
	dr.w	MOVE.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	MOVE.DIS_MSG
	dr.w	MOVE.DIS_MSG
	dr.w	MOVE.DIS_MSG
	dr.w	MOVE.DIS_MSG
	dr.w	MOVE.DIS_MSG
	dr.w	DIS_lbW000876
DIS_lbW000876:
	dc.w	0
	dr.w	MOVE.DIS_MSG
	dr.w	MOVE.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
MOVE.DIS_MSG:
	dc.b	'MOVE       ',0,$C
	dc.b	2
DIS_lbW000896:
	dc.w	6
	dr.w	DIS_lbW0008A0
	dr.w	DIS_lbW0008C4
	dr.w	DIS_lbW0008E8
	dr.w	DIS_lbW000936
DIS_lbW0008A0:
	dc.w	2
	dr.w	CLRB.DIS_MSG
	dr.w	CLRB.DIS_MSG	;APOLLO clr.b ax
	dr.w	CLRB.DIS_MSG
	dr.w	CLRB.DIS_MSG
	dr.w	CLRB.DIS_MSG
	dr.w	CLRB.DIS_MSG
	dr.w	CLRB.DIS_MSG
	dr.w	DIS_lbW0008B2
DIS_lbW0008B2:
	dc.w	0
	dr.w	CLRB.DIS_MSG
	dr.w	CLRB.DIS_MSG
	dr.w	CLRB.DIS_MSG
	dr.w	CLRB.DIS_MSG
	dr.w	CLRB.DIS_MSG
	dr.w	CLRB.DIS_MSG
	dr.w	CLRB.DIS_MSG
	dr.w	CLRB.DIS_MSG
DIS_lbW0008C4:
	dc.w	2
	dr.w	CLRW.DIS_MSG
	dr.w	CLRW.DIS_MSG	;APOLLO clr.w ax
	dr.w	CLRW.DIS_MSG
	dr.w	CLRW.DIS_MSG
	dr.w	CLRW.DIS_MSG
	dr.w	CLRW.DIS_MSG
	dr.w	CLRW.DIS_MSG
	dr.w	DIS_lbW0008D6
DIS_lbW0008D6:
	dc.w	0
	dr.w	CLRW.DIS_MSG
	dr.w	CLRW.DIS_MSG
	dr.w	CLRW.DIS_MSG
	dr.w	CLRW.DIS_MSG
	dr.w	CLRW.DIS_MSG
	dr.w	CLRW.DIS_MSG
	dr.w	CLRW.DIS_MSG
	dr.w	CLRW.DIS_MSG
DIS_lbW0008E8:
	dc.w	2
	dr.w	CLRL.DIS_MSG
	dr.w	CLRL.DIS_MSG	;APOLLO clr.l ax
	dr.w	CLRL.DIS_MSG
	dr.w	CLRL.DIS_MSG
	dr.w	CLRL.DIS_MSG
	dr.w	CLRL.DIS_MSG
	dr.w	CLRL.DIS_MSG
	dr.w	DIS_lbW0008FA
DIS_lbW0008FA:
	dc.w	0
	dr.w	CLRL.DIS_MSG
	dr.w	CLRL.DIS_MSG
	dr.w	CLRL.DIS_MSG
	dr.w	CLRL.DIS_MSG
	dr.w	CLRL.DIS_MSG
	dr.w	CLRL.DIS_MSG
	dr.w	CLRL.DIS_MSG
	dr.w	CLRL.DIS_MSG
CLRB.DIS_MSG:
	dc.b	'CLR.B      ',0
	dc.b	1
	dc.b	0
CLRW.DIS_MSG:
	dc.b	'CLR.W      ',0
	dc.b	2
	dc.b	0
CLRL.DIS_MSG:
	dc.b	'CLR.L      ',0
	dc.b	3
	dc.b	0
DIS_lbW000936:
	dc.w	2
	dr.w	MOVE.DIS_MSG0
	dr.w	DC.DIS_MSG
	dr.w	MOVE.DIS_MSG0
	dr.w	MOVE.DIS_MSG0
	dr.w	MOVE.DIS_MSG0
	dr.w	MOVE.DIS_MSG0
	dr.w	MOVE.DIS_MSG0
	dr.w	DIS_lbW000948
DIS_lbW000948:
	dc.w	0
	dr.w	MOVE.DIS_MSG0
	dr.w	MOVE.DIS_MSG0
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
MOVE.DIS_MSG0:
	dc.b	'MOVE       ',0,$D
	dc.b	2
DIS_lbW000968:
	dc.w	6
	dr.w	DIS_lbW000972
	dr.w	DIS_lbW000996
	dr.w	DIS_lbW0009BA
	dr.w	DIS_lbW000A08
DIS_lbW000972:
	dc.w	2
	dr.w	NEGB.DIS_MSG
	dr.w	NEGB.DIS_MSG	;APOLLO neg.b ax
	dr.w	NEGB.DIS_MSG
	dr.w	NEGB.DIS_MSG
	dr.w	NEGB.DIS_MSG
	dr.w	NEGB.DIS_MSG
	dr.w	NEGB.DIS_MSG
	dr.w	DIS_lbW000984
DIS_lbW000984:
	dc.w	0
	dr.w	NEGB.DIS_MSG
	dr.w	NEGB.DIS_MSG
	dr.w	NEGB.DIS_MSG
	dr.w	NEGB.DIS_MSG
	dr.w	NEGB.DIS_MSG
	dr.w	NEGB.DIS_MSG
	dr.w	NEGB.DIS_MSG
	dr.w	NEGB.DIS_MSG
DIS_lbW000996:
	dc.w	2
	dr.w	NEGW.DIS_MSG
	dr.w	NEGW.DIS_MSG	;APOLLO neg.w ax
	dr.w	NEGW.DIS_MSG
	dr.w	NEGW.DIS_MSG
	dr.w	NEGW.DIS_MSG
	dr.w	NEGW.DIS_MSG
	dr.w	NEGW.DIS_MSG
	dr.w	DIS_lbW0009A8
DIS_lbW0009A8:
	dc.w	0
	dr.w	NEGW.DIS_MSG
	dr.w	NEGW.DIS_MSG
	dr.w	NEGW.DIS_MSG
	dr.w	NEGW.DIS_MSG
	dr.w	NEGW.DIS_MSG
	dr.w	NEGW.DIS_MSG
	dr.w	NEGW.DIS_MSG
	dr.w	NEGW.DIS_MSG
DIS_lbW0009BA:
	dc.w	2
	dr.w	NEGL.DIS_MSG
	dr.w	NEGL.DIS_MSG	;APOLLO neg.l ax
	dr.w	NEGL.DIS_MSG
	dr.w	NEGL.DIS_MSG
	dr.w	NEGL.DIS_MSG
	dr.w	NEGL.DIS_MSG
	dr.w	NEGL.DIS_MSG
	dr.w	DIS_lbW0009CC
DIS_lbW0009CC:
	dc.w	0
	dr.w	NEGL.DIS_MSG
	dr.w	NEGL.DIS_MSG
	dr.w	NEGL.DIS_MSG
	dr.w	NEGL.DIS_MSG
	dr.w	NEGL.DIS_MSG
	dr.w	NEGL.DIS_MSG
	dr.w	NEGL.DIS_MSG
	dr.w	NEGL.DIS_MSG
NEGB.DIS_MSG:
	dc.b	'NEG.B      ',0
	dc.b	1
	dc.b	0
NEGW.DIS_MSG:
	dc.b	'NEG.W      ',0
	dc.b	2
	dc.b	0
NEGL.DIS_MSG:
	dc.b	'NEG.L      ',0
	dc.b	3
	dc.b	0
DIS_lbW000A08:
	dc.w	2
	dr.w	MOVE.DIS_MSG1
	dr.w	DC.DIS_MSG
	dr.w	MOVE.DIS_MSG1
	dr.w	MOVE.DIS_MSG1
	dr.w	MOVE.DIS_MSG1
	dr.w	MOVE.DIS_MSG1
	dr.w	MOVE.DIS_MSG1
	dr.w	DIS_lbW000A1A
DIS_lbW000A1A:
	dc.w	0
	dr.w	MOVE.DIS_MSG1
	dr.w	MOVE.DIS_MSG1
	dr.w	MOVE.DIS_MSG1
	dr.w	MOVE.DIS_MSG1
	dr.w	MOVE.DIS_MSG1
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
MOVE.DIS_MSG1:
	dc.b	'MOVE       ',0
	dc.w	$020D
DIS_lbW000A3A:
	dc.w	6
	dr.w	DIS_lbW000A44
	dr.w	DIS_lbW000A68
	dr.w	DIS_lbW000A8C
	dr.w	DIS_lbW000ADA
DIS_lbW000A44:
	dc.w	2
	dr.w	NOTB.DIS_MSG
	dr.w	NOTB.DIS_MSG	;APOLLO not.b ax
	dr.w	NOTB.DIS_MSG
	dr.w	NOTB.DIS_MSG
	dr.w	NOTB.DIS_MSG
	dr.w	NOTB.DIS_MSG
	dr.w	NOTB.DIS_MSG
	dr.w	DIS_lbW000A56
DIS_lbW000A56:
	dc.w	0
	dr.w	NOTB.DIS_MSG
	dr.w	NOTB.DIS_MSG
	dr.w	NOTB.DIS_MSG
	dr.w	NOTB.DIS_MSG
	dr.w	NOTB.DIS_MSG
	dr.w	NOTB.DIS_MSG
	dr.w	NOTB.DIS_MSG
	dr.w	NOTB.DIS_MSG
DIS_lbW000A68:
	dc.w	2
	dr.w	NOTW.DIS_MSG
	dr.w	NOTW.DIS_MSG	;APOLLO not.w ax
	dr.w	NOTW.DIS_MSG
	dr.w	NOTW.DIS_MSG
	dr.w	NOTW.DIS_MSG
	dr.w	NOTW.DIS_MSG
	dr.w	NOTW.DIS_MSG
	dr.w	DIS_lbW000A7A
DIS_lbW000A7A:
	dc.w	0
	dr.w	NOTW.DIS_MSG
	dr.w	NOTW.DIS_MSG
	dr.w	NOTW.DIS_MSG
	dr.w	NOTW.DIS_MSG
	dr.w	NOTW.DIS_MSG
	dr.w	NOTW.DIS_MSG
	dr.w	NOTW.DIS_MSG
	dr.w	NOTW.DIS_MSG
DIS_lbW000A8C:
	dc.w	2
	dr.w	NOTL.DIS_MSG
	dr.w	NOTL.DIS_MSG	;APOLLO not.l ax
	dr.w	NOTL.DIS_MSG
	dr.w	NOTL.DIS_MSG
	dr.w	NOTL.DIS_MSG
	dr.w	NOTL.DIS_MSG
	dr.w	NOTL.DIS_MSG
	dr.w	DIS_lbW000A9E
DIS_lbW000A9E:
	dc.w	0
	dr.w	NOTL.DIS_MSG
	dr.w	NOTL.DIS_MSG
	dr.w	NOTL.DIS_MSG
	dr.w	NOTL.DIS_MSG
	dr.w	NOTL.DIS_MSG
	dr.w	NOTL.DIS_MSG
	dr.w	NOTL.DIS_MSG
	dr.w	NOTL.DIS_MSG
NOTB.DIS_MSG:
	dc.b	'NOT.B      ',0
	dc.b	1
	dc.b	0
NOTW.DIS_MSG:
	dc.b	'NOT.W      ',0
	dc.b	2
	dc.b	0
NOTL.DIS_MSG:
	dc.b	'NOT.L      ',0
	dc.b	3
	dc.b	0
DIS_lbW000ADA:
	dc.w	2
	dr.w	MOVE.DIS_MSG2
	dr.w	DC.DIS_MSG
	dr.w	MOVE.DIS_MSG2
	dr.w	MOVE.DIS_MSG2
	dr.w	MOVE.DIS_MSG2
	dr.w	MOVE.DIS_MSG2
	dr.w	MOVE.DIS_MSG2
	dr.w	DIS_lbW000AEC
DIS_lbW000AEC:
	dc.w	0
	dr.w	MOVE.DIS_MSG2
	dr.w	MOVE.DIS_MSG2
	dr.w	MOVE.DIS_MSG2
	dr.w	MOVE.DIS_MSG2
	dr.w	MOVE.DIS_MSG2
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
MOVE.DIS_MSG2:
	dc.b	'MOVE       ',0
	dc.b	2
	dc.b	12
DIS_lbW000B0C:
	dc.w	6
	dr.w	DIS_lbW000B16
	dr.w	DIS_lbW000B56
	dr.w	DIS_lbW000BA4
	dr.w	DIS_lbW000BE4
DIS_lbW000B16:
	dc.w	2
	dr.w	NBCD.DIS_MSG
	dr.w	LINKL.DIS_MSG
	dr.w	NBCD.DIS_MSG
	dr.w	NBCD.DIS_MSG
	dr.w	NBCD.DIS_MSG
	dr.w	NBCD.DIS_MSG
	dr.w	NBCD.DIS_MSG
	dr.w	DIS_lbW000B28
DIS_lbW000B28:
	dc.w	0
	dr.w	NBCD.DIS_MSG
	dr.w	NBCD.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
NBCD.DIS_MSG:
	dc.b	'NBCD       ',0
	dc.b	1
	dc.b	0
LINKL.DIS_MSG:
	dc.b	'LINK.L     ',0
	dc.b	8
	dc.b	6
DIS_lbW000B56:
	dc.w	2
	dr.w	SWAP.DIS_MSG
	dr.w	BPKT.DIS_MSG
	dr.w	PEA.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	PEA.DIS_MSG
	dr.w	PEA.DIS_MSG
	dr.w	DIS_lbW000B84
BPKT.DIS_MSG:
	dc.b	'BKPT       ',0
	dc.b	$1A
	dc.b	0
SWAP.DIS_MSG:
	dc.b	'SWAP       ',0
	dc.b	7
	dc.b	0
DIS_lbW000B84:
	dc.w	0
	dr.w	PEA.DIS_MSG
	dr.w	PEA.DIS_MSG
	dr.w	PEA.DIS_MSG
	dr.w	PEA.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
PEA.DIS_MSG:
	dc.b	'PEA        ',0
	dc.b	3
	dc.b	0
DIS_lbW000BA4:
	dc.w	2
	dr.w	EXTW.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	MOVEMW.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	MOVEMW.DIS_MSG
	dr.w	MOVEMW.DIS_MSG
	dr.w	MOVEMW.DIS_MSG
	dr.w	DIS_lbW000BB6
DIS_lbW000BB6:
	dc.w	0
	dr.w	MOVEMW.DIS_MSG
	dr.w	MOVEMW.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
MOVEMW.DIS_MSG:
	dc.b	'MOVEM.W    ',0
	dc.w	$1416
EXTW.DIS_MSG:
	dc.b	'EXT.W      ',0
	dc.w	$0700
DIS_lbW000BE4:
	dc.w	2
	dr.w	EXTL.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	MOVEML.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	MOVEML.DIS_MSG
	dr.w	MOVEML.DIS_MSG
	dr.w	MOVEML.DIS_MSG
	dr.w	DIS_lbW000BF6
DIS_lbW000BF6:
	dc.w	0
	dr.w	MOVEML.DIS_MSG
	dr.w	MOVEML.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
MOVEML.DIS_MSG:
	dc.b	'MOVEM.L    ',0
	dc.b	$14
	dc.b	$16
EXTL.DIS_MSG:
	dc.b	'EXT.L      ',0
	dc.b	7
	dc.b	0
DIS_lbW000C24:
	dc.w	6
	dr.w	DIS_lbW000C2E
	dr.w	DIS_lbW000C52
	dr.w	DIS_lbW000C76
	dr.w	DIS_lbW000CC4
DIS_lbW000C2E:
	dc.w	2
	dr.w	TSTB.DIS_MSG
	dr.w	TSTB.DIS_MSG	;APOLLO tst.b ax
	dr.w	TSTB.DIS_MSG
	dr.w	TSTB.DIS_MSG
	dr.w	TSTB.DIS_MSG
	dr.w	TSTB.DIS_MSG
	dr.w	TSTB.DIS_MSG
	dr.w	DIS_lbW000C40
DIS_lbW000C40:
	dc.w	0
	dr.w	TSTB.DIS_MSG
	dr.w	TSTB.DIS_MSG
	dr.w	TSTB.DIS_MSG
	dr.w	TSTB.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
DIS_lbW000C52:
	dc.w	2
	dr.w	TSTW.DIS_MSG
	dr.w	TSTW.DIS_MSG
	dr.w	TSTW.DIS_MSG
	dr.w	TSTW.DIS_MSG
	dr.w	TSTW.DIS_MSG
	dr.w	TSTW.DIS_MSG
	dr.w	TSTW.DIS_MSG
	dr.w	DIS_lbW000C64
DIS_lbW000C64:
	dc.w	0
	dr.w	TSTW.DIS_MSG
	dr.w	TSTW.DIS_MSG
	dr.w	TSTW.DIS_MSG
	dr.w	TSTW.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
DIS_lbW000C76:
	dc.w	2
	dr.w	TSTL.DIS_MSG
	dr.w	TSTL.DIS_MSG
	dr.w	TSTL.DIS_MSG
	dr.w	TSTL.DIS_MSG
	dr.w	TSTL.DIS_MSG
	dr.w	TSTL.DIS_MSG
	dr.w	TSTL.DIS_MSG
	dr.w	DIS_lbW000C88
DIS_lbW000C88:
	dc.w	0
	dr.w	TSTL.DIS_MSG
	dr.w	TSTL.DIS_MSG
	dr.w	TSTL.DIS_MSG
	dr.w	TSTL.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
TSTB.DIS_MSG:
	dc.b	'TST.B      ',0
	dc.b	1
	dc.b	0
TSTW.DIS_MSG:
	dc.b	'TST.W      ',0
	dc.b	2
	dc.b	0
TSTL.DIS_MSG:
	dc.b	'TST.L      ',0
	dc.b	3
	dc.b	0
DIS_lbW000CC4:
	dc.w	2
	dr.w	TAS.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	TAS.DIS_MSG
	dr.w	TAS.DIS_MSG
	dr.w	TAS.DIS_MSG
	dr.w	TAS.DIS_MSG
	dr.w	TAS.DIS_MSG
	dr.w	DIS_lbW000CD6
DIS_lbW000CD6:
	dc.w	0
	dr.w	TAS.DIS_MSG
	dr.w	TAS.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	ILLEGAL.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
ILLEGAL.DIS_MSG:
	dc.b	'ILLEGAL    ',0,0
	dc.b	0
TAS.DIS_MSG:
	dc.b	'TAS        ',0
	dc.b	1
	dc.b	0
DIS_lbW000D04:
	dc.w	6
	dr.w	DIS_lbW000D0E
	dr.w	DIS_lbW000D3C
	dr.w	DIS_lbW000D86
	dr.w	DIS_lbW000DB8
DIS_lbW000D0E:
	dc.w	$0012
	dr.w	MULUL.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	MULUL.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	MULSL.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	MULSL.DIS_MSG
	dr.w	DC.DIS_MSG
MULUL.DIS_MSG:
	dc.b	'MULU.L     ',0
	dc.b	'"',0
MULSL.DIS_MSG:
	dc.b	'MULS.L     ',0
	dc.b	'"',0
DIS_lbW000D3C:
	dc.w	$0012
	dr.w	DIVULL.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DIVUL.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DIVSLL.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DIVSL.DIS_MSG
	dr.w	DC.DIS_MSG
DIVULL.DIS_MSG:
	dc.b	'DIVUL.L    ',0
	dc.b	$1F
	dc.b	0
DIVUL.DIS_MSG:
	dc.b	'DIVU.L     ',0
	dc.b	$1F
	dc.b	0
DIVSLL.DIS_MSG:
	dc.b	'DIVSL.L    ',0
	dc.b	$1F
	dc.b	0
DIVSL.DIS_MSG:
	dc.b	'DIVS.L     ',0
	dc.b	$1F
	dc.b	0
DIS_lbW000D86:
	dc.w	2
	dr.w	MOVEMW.DIS_MSG0
	dr.w	MOVEMW.DIS_MSG0
	dr.w	MOVEMW.DIS_MSG0
	dr.w	MOVEMW.DIS_MSG0
	dr.w	DC.DIS_MSG
	dr.w	MOVEMW.DIS_MSG0
	dr.w	MOVEMW.DIS_MSG0
	dr.w	DIS_lbW000D98
DIS_lbW000D98:
	dc.w	0
	dr.w	MOVEMW.DIS_MSG0
	dr.w	MOVEMW.DIS_MSG0
	dr.w	MOVEMW.DIS_MSG0
	dr.w	MOVEMW.DIS_MSG0
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
MOVEMW.DIS_MSG0:
	dc.b	'MOVEM.W    ',0
	dc.b	$16
	dc.b	$14
DIS_lbW000DB8:
	dc.w	2
	dr.w	MOVEML.DIS_MSG0
	dr.w	MOVEML.DIS_MSG0
	dr.w	MOVEML.DIS_MSG0
	dr.w	MOVEML.DIS_MSG0
	dr.w	DC.DIS_MSG
	dr.w	MOVEML.DIS_MSG0
	dr.w	MOVEML.DIS_MSG0
	dr.w	DIS_lbW000DCA
DIS_lbW000DCA:
	dc.w	0
	dr.w	MOVEML.DIS_MSG0
	dr.w	MOVEML.DIS_MSG0
	dr.w	MOVEML.DIS_MSG0
	dr.w	MOVEML.DIS_MSG0
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
MOVEML.DIS_MSG0:
	dc.b	'MOVEM.L    ',0
	dc.b	$16
	dc.b	$14
DIS_lbW000DEA:
	dc.w	6
	dr.w	DC.DIS_MSG
	dr.w	DIS_lbW000DF4
	dr.w	DIS_lbW000EDC
	dr.w	DIS_lbW000F0E
DIS_lbW000DF4:
	dc.w	2
	dr.w	TRAP.DIS_MSG
	dr.w	TRAP.DIS_MSG
	dr.w	LINKW.DIS_MSG
	dr.w	UNLK.DIS_MSG
	dr.w	MOVEL.DIS_MSG0
	dr.w	MOVEL.DIS_MSG1
	dr.w	DIS_lbW000E5A
	dr.w	MOVEC.DIS_MSG
MOVEC.DIS_MSG:
	dc.b	'MOVEC      ',0
	dc.b	' ',0
LINKW.DIS_MSG:
	dc.b	'LINK.W     ',0
	dc.b	8
	dc.b	5
MOVEL.DIS_MSG0:
	dc.b	'MOVE.L     ',0
	dc.b	8
	dc.b	14
MOVEL.DIS_MSG1:
	dc.b	'MOVE.L     ',0
	dc.b	14
	dc.b	8
TRAP.DIS_MSG:
	dc.b	'TRAP       ',0
	dc.b	$13
	dc.b	0
UNLK.DIS_MSG:
	dc.b	'UNLK       ',0
	dc.b	8
	dc.b	0
DIS_lbW000E5A:
	dc.w	0
	dr.w	RESET.DIS_MSG
	dr.w	NOP.DIS_MSG
	dr.w	STOP.DIS_MSG
	dr.w	RTE.DIS_MSG
	dr.w	RTD.DIS_MSG
	dr.w	RTS.DIS_MSG
	dr.w	TRAPV.DIS_MSG
	dr.w	RTR.DIS_MSG
TRAPV.DIS_MSG:
	dc.b	'TRAPV      ',0,0
	dc.b	0
RESET.DIS_MSG:
	dc.b	'RESET      ',0,0
	dc.b	0
NOP.DIS_MSG:
	dc.b	'NOP        ',0,0
	dc.b	0
RTE.DIS_MSG:
	dc.b	'RTE        ',0,0
	dc.b	0
RTR.DIS_MSG:
	dc.b	'RTR        '
	dc.b	2
	dcb.b	2,0
RTS.DIS_MSG:
	dc.b	'RTS        '
	dc.b	2
	dcb.b	2,0
STOP.DIS_MSG:
	dc.b	'STOP       ',0
	dc.b	5
	dc.b	0
RTD.DIS_MSG:
	dc.b	'RTD        ',0
	dc.b	4
	dc.b	0
DIS_lbW000EDC:
	dc.w	2
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	JSR.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	JSR.DIS_MSG
	dr.w	JSR.DIS_MSG
	dr.w	DIS_lbW000EEE
DIS_lbW000EEE:
	dc.w	0
	dr.w	JSR.DIS_MSG
	dr.w	JSR.DIS_MSG
	dr.w	JSR.DIS_MSG
	dr.w	JSR.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
JSR.DIS_MSG:
	dc.b	'JSR        ',0
	dc.b	3
	dc.b	0
DIS_lbW000F0E:
	dc.w	2
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	JMP.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	JMP.DIS_MSG
	dr.w	JMP.DIS_MSG
	dr.w	DIS_lbW000F20
DIS_lbW000F20:
	dc.w	0
	dr.w	JMP.DIS_MSG
	dr.w	JMP.DIS_MSG
	dr.w	JMP.DIS_MSG
	dr.w	JMP.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
JMP.DIS_MSG:
	dc.b	'JM'
	dc.b	'P '
	dc.b	'       '
	dc.b	1
	dc.b	3
	dc.b	0
DIS_1_0101:
	dc.w	6
	dr.w	DIS_lbW000F4A
	dr.w	DIS_lbW000F90
	dr.w	DIS_lbW000FD6
	dr.w	DIS_lbW00101C
DIS_lbW000F4A:
	dc.w	2
	dr.w	DIS_lbW000F6E
	dr.w	DC.DIS_MSG
	dr.w	DIS_lbW000F6E
	dr.w	DIS_lbW000F6E
	dr.w	DIS_lbW000F6E
	dr.w	DIS_lbW000F6E
	dr.w	DIS_lbW000F6E
	dr.w	DIS_lbW000F5C
DIS_lbW000F5C:
	dc.w	0
	dr.w	DIS_lbW000F6E
	dr.w	DIS_lbW000F6E
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
DIS_lbW000F6E:
	dc.w	8
	dr.w	ADDQB.DIS_MSG
	dr.w	SUBQB.DIS_MSG
ADDQB.DIS_MSG:
	dc.b	'ADDQ.B     ',0
	dc.b	$91
	dc.b	1
SUBQB.DIS_MSG:
	dc.b	'SUBQ.B     ',0
	dc.b	$91
	dc.b	1
DIS_lbW000F90:
	dc.w	2
	dr.w	DIS_lbW000FB4
	dr.w	DIS_lbW000FB4
	dr.w	DIS_lbW000FB4
	dr.w	DIS_lbW000FB4
	dr.w	DIS_lbW000FB4
	dr.w	DIS_lbW000FB4
	dr.w	DIS_lbW000FB4
	dr.w	DIS_lbW000FA2
DIS_lbW000FA2:
	dc.w	0
	dr.w	DIS_lbW000FB4
	dr.w	DIS_lbW000FB4
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
DIS_lbW000FB4:
	dc.w	8
	dr.w	ADDQW.DIS_MSG
	dr.w	SUBQW.DIS_MSG
ADDQW.DIS_MSG:
	dc.b	'ADDQ.W     ',0
	dc.b	$91
	dc.b	2
SUBQW.DIS_MSG:
	dc.b	'SUBQ.W     ',0
	dc.b	$91
	dc.b	2
DIS_lbW000FD6:
	dc.w	2
	dr.w	DIS_lbW000FFA
	dr.w	DIS_lbW000FFA
	dr.w	DIS_lbW000FFA
	dr.w	DIS_lbW000FFA
	dr.w	DIS_lbW000FFA
	dr.w	DIS_lbW000FFA
	dr.w	DIS_lbW000FFA
	dr.w	DIS_lbW000FE8
DIS_lbW000FE8:
	dc.w	0
	dr.w	DIS_lbW000FFA
	dr.w	DIS_lbW000FFA
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
DIS_lbW000FFA:
	dc.w	8
	dr.w	ADDQL.DIS_MSG
	dr.w	SUBQL.DIS_MSG
ADDQL.DIS_MSG:
	dc.b	'ADDQ.L     ',0
	dc.b	$91
	dc.b	3
SUBQL.DIS_MSG:
	dc.b	'SUBQ.L     ',0
	dc.b	$91
	dc.b	3
DIS_lbW00101C:
	dc.w	2
	dr.w	Scc.DIS_MSG
	dr.w	DBcc.DIS_MSG
	dr.w	Scc.DIS_MSG
	dr.w	Scc.DIS_MSG
	dr.w	Scc.DIS_MSG
	dr.w	Scc.DIS_MSG
	dr.w	Scc.DIS_MSG
	dr.w	DIS_lbW00102E
DIS_lbW00102E:
	dc.w	0
	dr.w	Scc.DIS_MSG
	dr.w	Scc.DIS_MSG
	dr.w	TRAPcc.DIS_MSG
	dr.w	TRAPcc.DIS_MSG
	dr.w	TRAPcc.DIS_MSG0
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
TRAPcc.DIS_MSG:
	dc.b	'TRAPcc     ',0
	dc.w	$2500
TRAPcc.DIS_MSG0:
	dc.b	'TRAPcc     ',0,0
	dc.b	0
Scc.DIS_MSG:
	dc.b	'Scc        ',0
	dc.b	1
	dc.b	0
DBcc.DIS_MSG:
	dc.b	'DB'
	dc.b	'cc       '
	dc.b	2
	dc.b	7
	dc.b	11
DIS_1_0110:
	dc.w	12
	dr.w	DIS_lbW00108A
	dr.w	Bccz.DIS_MSG
	dr.w	Bccz.DIS_MSG
DIS_lbW001080:
	dc.w	$002C
	dr.w	Bccz.DIS_MSG
	dr.w	Bccz.DIS_MSG
	dr.w	Bccz.DIS_MSG
	dr.w	Bccz.DIS_MSG
DIS_lbW00108A:
	dc.w	8
	dr.w	BRAz.DIS_MSG
	dr.w	BSRz.DIS_MSG
BRAz.DIS_MSG:
	dc.b	'BRA.z      '
	dc.b	2
	dc.b	10
	dc.b	0
BSRz.DIS_MSG:
	dc.b	'BSR.z      ',0,$A,0
Bccz.DIS_MSG:
	dc.b	'Bcc.z      '
	dc.b	2
	dc.b	10
	dc.b	0
DIS_1_0111:
	dc.w	8
	dr.w	MOVEQ.DIS_MSG
	dr.w	DC.DIS_MSG
MOVEQ.DIS_MSG:
	dc.b	'MOVEQ      ',0
	dc.b	$12
	dc.b	$87
DIS_1_1000:
	dc.w	6
	dr.w	DIS_lbW0010D8
	dr.w	DIS_lbW00115E
	dr.w	DIS_lbW0011D6
	dr.w	DIS_lbW00124E
DIS_lbW0010D8:
	dc.w	8
	dr.w	DIS_lbW0010DE
	dr.w	DIS_lbW001110
DIS_lbW0010DE:
	dc.w	2
	dr.w	ORB.DIS_MSG
	dr.w	ORB.DIS_MSG
	dr.w	ORB.DIS_MSG
	dr.w	ORB.DIS_MSG
	dr.w	ORB.DIS_MSG
	dr.w	ORB.DIS_MSG
	dr.w	ORB.DIS_MSG
	dr.w	DIS_lbW0010F0
DIS_lbW0010F0:
	dc.w	0
	dr.w	ORB.DIS_MSG
	dr.w	ORB.DIS_MSG
	dr.w	ORB.DIS_MSG
	dr.w	ORB.DIS_MSG
	dr.w	ORB.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
ORB.DIS_MSG:
	dc.b	'OR.B       ',0
	dc.w	$0187
DIS_lbW001110:
	dc.w	2
	dr.w	SBCDB.DIS_MSG0
	dr.w	SBCDB.DIS_MSG
	dr.w	ORB.DIS_MSG0
	dr.w	ORB.DIS_MSG0
	dr.w	ORB.DIS_MSG0
	dr.w	ORB.DIS_MSG0
	dr.w	ORB.DIS_MSG0
	dr.w	DIS_lbW001122
DIS_lbW001122:
	dc.w	0
	dr.w	ORB.DIS_MSG0
	dr.w	ORB.DIS_MSG0
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
ORB.DIS_MSG0:
	dc.b	'OR.B       ',0
	dc.w	$8701
SBCDB.DIS_MSG:
	dc.b	'SBCD.B     ',0
	dc.w	$0F8F
SBCDB.DIS_MSG0:
	dc.b	'SBCD.B     ',0
	dc.w	$0787
DIS_lbW00115E:
	dc.w	8
	dr.w	DIS_lbW001164
	dr.w	DIS_lbW001196
DIS_lbW001164:
	dc.w	2
	dr.w	ORW.DIS_MSG
	dr.w	ORW.DIS_MSG
	dr.w	ORW.DIS_MSG
	dr.w	ORW.DIS_MSG
	dr.w	ORW.DIS_MSG
	dr.w	ORW.DIS_MSG
	dr.w	ORW.DIS_MSG
	dr.w	DIS_lbW001176
DIS_lbW001176:
	dc.w	0
	dr.w	ORW.DIS_MSG
	dr.w	ORW.DIS_MSG
	dr.w	ORW.DIS_MSG
	dr.w	ORW.DIS_MSG
	dr.w	ORW.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
ORW.DIS_MSG:
	dc.b	'OR.W       ',0
	dc.w	$0287
DIS_lbW001196:
	dc.w	2
	dr.w	PACK.DIS_MSG
	dr.w	PACK.DIS_MSG
	dr.w	ORW.DIS_MSG0
	dr.w	ORW.DIS_MSG0
	dr.w	ORW.DIS_MSG0
	dr.w	ORW.DIS_MSG0
	dr.w	ORW.DIS_MSG0
	dr.w	DIS_lbW0011B6
PACK.DIS_MSG:
	dc.b	'PACK       ',0
	dc.w	$2300
DIS_lbW0011B6:
	dc.w	0
	dr.w	ORW.DIS_MSG0
	dr.w	ORW.DIS_MSG0
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
ORW.DIS_MSG0:
	dc.b	'OR.W       ',0
	dc.w	$8702
DIS_lbW0011D6:
	dc.w	8
	dr.w	DIS_lbW0011DC
	dr.w	DIS_lbW00120E
DIS_lbW0011DC:
	dc.w	2
	dr.w	ORL.DIS_MSG
	dr.w	ORL.DIS_MSG
	dr.w	ORL.DIS_MSG
	dr.w	ORL.DIS_MSG
	dr.w	ORL.DIS_MSG
	dr.w	ORL.DIS_MSG
	dr.w	ORL.DIS_MSG
	dr.w	DIS_lbW0011EE
DIS_lbW0011EE:
	dc.w	0
	dr.w	ORL.DIS_MSG
	dr.w	ORL.DIS_MSG
	dr.w	ORL.DIS_MSG
	dr.w	ORL.DIS_MSG
	dr.w	ORL.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
ORL.DIS_MSG:
	dc.b	'OR.L       ',0
	dc.b	3
	dc.b	$87
DIS_lbW00120E:
	dc.w	2
	dr.w	UNPK.DIS_MSG
	dr.w	UNPK.DIS_MSG
	dr.w	ORL.DIS_MSG0
	dr.w	ORL.DIS_MSG0
	dr.w	ORL.DIS_MSG0
	dr.w	ORL.DIS_MSG0
	dr.w	ORL.DIS_MSG0
	dr.w	DIS_lbW00122E
UNPK.DIS_MSG:
	dc.b	'UNPK       ',0
	dc.b	'#',0
DIS_lbW00122E:
	dc.w	0
	dr.w	ORL.DIS_MSG0
	dr.w	ORL.DIS_MSG0
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
ORL.DIS_MSG0:
	dc.b	'OR.L       ',0
	dc.b	$87
	dc.b	3
DIS_lbW00124E:
	dc.w	2
	dr.w	DIS_lbW001272
	dr.w	DC.DIS_MSG
	dr.w	DIS_lbW001272
	dr.w	DIS_lbW001272
	dr.w	DIS_lbW001272
	dr.w	DIS_lbW001272
	dr.w	DIS_lbW001272
	dr.w	DIS_lbW001260
DIS_lbW001260:
	dc.w	0
	dr.w	DIS_lbW001272
	dr.w	DIS_lbW001272
	dr.w	DIS_lbW001272
	dr.w	DIS_lbW001272
	dr.w	DIS_lbW001272
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
DIS_lbW001272:
	dc.w	8
	dr.w	DIVUW.DIS_MSG
	dr.w	DIVSW.DIS_MSG
DIVUW.DIS_MSG:
	dc.b	'DIVU.W    '
	dc.b	' ',0
	dc.b	2
	dc.b	$87
DIVSW.DIS_MSG:
	dc.b	'DIVS.W     ',0
	dc.b	2
	dc.b	$87
DIS_1_1001:
	dc.w	6
	dr.w	DIS_lbW00129E
	dr.w	DIS_lbW001324
	dr.w	DIS_lbW0013AA
	dr.w	DIS_lbW001430
DIS_lbW00129E:
	dc.w	8

	
	dr.w	DIS_lbW0012A4
	dr.w	DIS_lbW0012D6
DIS_lbW0012A4:
	dc.w	2
	dr.w	SUBB.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	SUBB.DIS_MSG
	dr.w	SUBB.DIS_MSG
	dr.w	SUBB.DIS_MSG
	dr.w	SUBB.DIS_MSG
	dr.w	SUBB.DIS_MSG
	dr.w	DIS_lbW0012B6
DIS_lbW0012B6:
	dc.w	0
	dr.w	SUBB.DIS_MSG
	dr.w	SUBB.DIS_MSG
	dr.w	SUBB.DIS_MSG
	dr.w	SUBB.DIS_MSG
	dr.w	SUBB.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
SUBB.DIS_MSG:
	dc.b	'SUB.B      ',0
	dc.b	1
	dc.b	$87
DIS_lbW0012D6:
	dc.w	2
	dr.w	SUBXB.DIS_MSG
	dr.w	SUBXB.DIS_MSG0
	dr.w	SUBB.DIS_MSG0
	dr.w	SUBB.DIS_MSG0
	dr.w	SUBB.DIS_MSG0
	dr.w	SUBB.DIS_MSG0
	dr.w	SUBB.DIS_MSG0
	dr.w	DIS_lbW0012E8
DIS_lbW0012E8:
	dc.w	0
	dr.w	SUBB.DIS_MSG0
	dr.w	SUBB.DIS_MSG0
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
SUBB.DIS_MSG0:
	dc.b	'SUB.B      ',0
	dc.b	$87
	dc.b	1
SUBXB.DIS_MSG0:
	dc.b	'SUBX.B     ',0
	dc.b	15
	dc.b	$8F
SUBXB.DIS_MSG:
	dc.b	'SUBX.B     ',0
	dc.b	7
	dc.b	$87
DIS_lbW001324:
	dc.w	8
	dr.w	DIS_lbW00132A
	dr.w	DIS_lbW00135C
DIS_lbW00132A:
	dc.w	2
	dr.w	SUBW.DIS_MSG
	dr.w	SUBW.DIS_MSG
	dr.w	SUBW.DIS_MSG
	dr.w	SUBW.DIS_MSG
	dr.w	SUBW.DIS_MSG
	dr.w	SUBW.DIS_MSG
	dr.w	SUBW.DIS_MSG
	dr.w	DIS_lbW00133C
DIS_lbW00133C:
	dc.w	0
	dr.w	SUBW.DIS_MSG
	dr.w	SUBW.DIS_MSG
	dr.w	SUBW.DIS_MSG
	dr.w	SUBW.DIS_MSG
	dr.w	SUBW.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
SUBW.DIS_MSG:
	dc.b	'SUB.W      ',0
	dc.b	2
	dc.b	$87
DIS_lbW00135C:
	dc.w	2
	dr.w	SUBXW.DIS_MSG
	dr.w	SUBXW.DIS_MSG0
	dr.w	SUBW.DIS_MSG0
	dr.w	SUBW.DIS_MSG0
	dr.w	SUBW.DIS_MSG0
	dr.w	SUBW.DIS_MSG0
	dr.w	SUBW.DIS_MSG0
	dr.w	DIS_lbW00136E
DIS_lbW00136E:
	dc.w	0
	dr.w	SUBW.DIS_MSG0
	dr.w	SUBW.DIS_MSG0
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
SUBW.DIS_MSG0:
	dc.b	'SUB.W      ',0
	dc.b	$87
	dc.b	2
SUBXW.DIS_MSG0:
	dc.b	'SUBX.W     ',0
	dc.b	15
	dc.b	$8F
SUBXW.DIS_MSG:
	dc.b	'SUBX.W     ',0
	dc.b	7
	dc.b	$87
DIS_lbW0013AA:
	dc.w	8
	dr.w	DIS_lbW0013B0
	dr.w	DIS_lbW0013E2
DIS_lbW0013B0:
	dc.w	2
	dr.w	SUBL.DIS_MSG
	dr.w	SUBL.DIS_MSG
	dr.w	SUBL.DIS_MSG
	dr.w	SUBL.DIS_MSG
	dr.w	SUBL.DIS_MSG
	dr.w	SUBL.DIS_MSG
	dr.w	SUBL.DIS_MSG
	dr.w	DIS_lbW0013C2
DIS_lbW0013C2:
	dc.w	0
	dr.w	SUBL.DIS_MSG
	dr.w	SUBL.DIS_MSG
	dr.w	SUBL.DIS_MSG
	dr.w	SUBL.DIS_MSG
	dr.w	SUBL.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
SUBL.DIS_MSG:
	dc.b	'SUB.L      ',0
	dc.b	3
	dc.b	$87
DIS_lbW0013E2:
	dc.w	2
	dr.w	SUBXL.DIS_MSG
	dr.w	SUBXL.DIS_MSG0
	dr.w	SUBL.DIS_MSG0
	dr.w	SUBL.DIS_MSG0
	dr.w	SUBL.DIS_MSG0
	dr.w	SUBL.DIS_MSG0
	dr.w	SUBL.DIS_MSG0
	dr.w	DIS_lbW0013F4
DIS_lbW0013F4:
	dc.w	0
	dr.w	SUBL.DIS_MSG0
	dr.w	SUBL.DIS_MSG0
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
SUBL.DIS_MSG0:
	dc.b	'SUB.L      ',0
	dc.b	$87
	dc.b	3
SUBXL.DIS_MSG0:
	dc.b	'SUBX.L     ',0
	dc.b	15
	dc.b	$8F
SUBXL.DIS_MSG:
	dc.b	'SUBX.L     ',0
	dc.b	7
	dc.b	$87
DIS_lbW001430:
	dc.w	2
	dr.w	DIS_lbW001454
	dr.w	DIS_lbW001454
	dr.w	DIS_lbW001454
	dr.w	DIS_lbW001454
	dr.w	DIS_lbW001454
	dr.w	DIS_lbW001454
	dr.w	DIS_lbW001454
	dr.w	DIS_lbW001442
DIS_lbW001442:
	dc.w	0
	dr.w	DIS_lbW001454
	dr.w	DIS_lbW001454
	dr.w	DIS_lbW001454
	dr.w	DIS_lbW001454
	dr.w	DIS_lbW001454
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
DIS_lbW001454:
	dc.w	8
	dr.w	SUBAW.DIS_MSG
	dr.w	SUBAL.DIS_MSG
SUBAW.DIS_MSG:
	dc.b	'SUBA.W  '
	dc.b	'   ',0
	dc.b	2
	dc.b	$88
SUBAL.DIS_MSG:
	dc.b	'SUBA.L'
	dc.b	'     ',0
	dc.b	3,$88

DIS_NM_LINEA:
	dc.w	$001C
	dr.w	LINE_A.DIS_MSG
	dr.w	PFLUSHR.DIS_MSG

LINE_A.DIS_MSG:	dc.b	'LINE_A     ',0
		dc.b	$15,0

DIS_1_1011:
	dc.w	6
	dr.w	DIS_lbW00148E
	dr.w	DIS_lbW001506
	dr.w	DIS_lbW00157E
	dr.w	DIS_lbW0015F6
DIS_lbW00148E:
	dc.w	8
	dr.w	DIS_lbW001494
	dr.w	DIS_lbW0014C6
DIS_lbW001494:
	dc.w	2
	dr.w	CMPB.DIS_MSG
	dr.w	CMPB.DIS_MSG
	dr.w	CMPB.DIS_MSG
	dr.w	CMPB.DIS_MSG
	dr.w	CMPB.DIS_MSG
	dr.w	CMPB.DIS_MSG
	dr.w	CMPB.DIS_MSG
	dr.w	DIS_lbW0014A6
DIS_lbW0014A6:
	dc.w	0
	dr.w	CMPB.DIS_MSG
	dr.w	CMPB.DIS_MSG
	dr.w	CMPB.DIS_MSG
	dr.w	CMPB.DIS_MSG
	dr.w	CMPB.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
CMPB.DIS_MSG:
	dc.b	'CMP.B      ',0
	dc.b	1
	dc.b	$87
DIS_lbW0014C6:
	dc.w	2
	dr.w	EORB.DIS_MSG
	dr.w	CMPMB.DIS_MSG
	dr.w	EORB.DIS_MSG
	dr.w	EORB.DIS_MSG
	dr.w	EORB.DIS_MSG
	dr.w	EORB.DIS_MSG
	dr.w	EORB.DIS_MSG
	dr.w	DIS_lbW0014D8
DIS_lbW0014D8:
	dc.w	0
	dr.w	EORB.DIS_MSG
	dr.w	EORB.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
EORB.DIS_MSG:
	dc.b	'EOR.B      ',0
	dc.b	$87
	dc.b	1
CMPMB.DIS_MSG:
	dc.b	'CMPM.B     ',0
	dc.b	$10
	dc.b	$90
DIS_lbW001506:
	dc.w	8
	dr.w	DIS_lbW00150C
	dr.w	DIS_lbW00153E
DIS_lbW00150C:
	dc.w	2
	dr.w	CMPW.DIS_MSG
	dr.w	CMPW.DIS_MSG
	dr.w	CMPW.DIS_MSG
	dr.w	CMPW.DIS_MSG
	dr.w	CMPW.DIS_MSG
	dr.w	CMPW.DIS_MSG
	dr.w	CMPW.DIS_MSG
	dr.w	DIS_lbW00151E
DIS_lbW00151E:
	dc.w	0
	dr.w	CMPW.DIS_MSG
	dr.w	CMPW.DIS_MSG
	dr.w	CMPW.DIS_MSG
	dr.w	CMPW.DIS_MSG
	dr.w	CMPW.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
CMPW.DIS_MSG:
	dc.b	'CMP.W      ',0
	dc.b	2
	dc.b	$87
DIS_lbW00153E:
	dc.w	2
	dr.w	EORW.DIS_MSG
	dr.w	CMPMW.DIS_MSG
	dr.w	EORW.DIS_MSG
	dr.w	EORW.DIS_MSG
	dr.w	EORW.DIS_MSG
	dr.w	EORW.DIS_MSG
	dr.w	EORW.DIS_MSG
	dr.w	DIS_lbW001550
DIS_lbW001550:
	dc.w	0
	dr.w	EORW.DIS_MSG
	dr.w	EORW.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
EORW.DIS_MSG:
	dc.b	'EOR.W      ',0
	dc.b	$87
	dc.b	2
CMPMW.DIS_MSG:
	dc.b	'CMPM.W     ',0
	dc.b	$10
	dc.b	$90
DIS_lbW00157E:
	dc.w	8
	dr.w	DIS_lbW001584
	dr.w	DIS_lbW0015B6
DIS_lbW001584:
	dc.w	2
	dr.w	CMPL.DIS_MSG
	dr.w	CMPL.DIS_MSG
	dr.w	CMPL.DIS_MSG
	dr.w	CMPL.DIS_MSG
	dr.w	CMPL.DIS_MSG
	dr.w	CMPL.DIS_MSG
	dr.w	CMPL.DIS_MSG
	dr.w	DIS_lbW001596
DIS_lbW001596:
	dc.w	0
	dr.w	CMPL.DIS_MSG
	dr.w	CMPL.DIS_MSG
	dr.w	CMPL.DIS_MSG
	dr.w	CMPL.DIS_MSG
	dr.w	CMPL.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
CMPL.DIS_MSG:
	dc.b	'CMP.L      ',0
	dc.b	3
	dc.b	$87
DIS_lbW0015B6:
	dc.w	2
	dr.w	EORL.DIS_MSG
	dr.w	CMPML.DIS_MSG
	dr.w	EORL.DIS_MSG
	dr.w	EORL.DIS_MSG
	dr.w	EORL.DIS_MSG
	dr.w	EORL.DIS_MSG
	dr.w	EORL.DIS_MSG
	dr.w	DIS_lbW0015C8
DIS_lbW0015C8:
	dc.w	0
	dr.w	EORL.DIS_MSG
	dr.w	EORL.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
EORL.DIS_MSG:
	dc.b	'EOR.L      ',0
	dc.b	$87
	dc.b	3
CMPML.DIS_MSG:
	dc.b	'CMPM.L     ',0
	dc.b	$10
	dc.b	$90
DIS_lbW0015F6:
	dc.w	2
	dr.w	DIS_lbW00161A
	dr.w	DIS_lbW00161A
	dr.w	DIS_lbW00161A
	dr.w	DIS_lbW00161A
	dr.w	DIS_lbW00161A
	dr.w	DIS_lbW00161A
	dr.w	DIS_lbW00161A
	dr.w	DIS_lbW001608
DIS_lbW001608:
	dc.w	0
	dr.w	DIS_lbW00161A
	dr.w	DIS_lbW00161A
	dr.w	DIS_lbW00161A
	dr.w	DIS_lbW00161A
	dr.w	DIS_lbW00161A
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
DIS_lbW00161A:
	dc.w	8
	dr.w	CMPAW.DIS_MSG
	dr.w	CMPAL.DIS_MSG
CMPAW.DIS_MSG:
	dc.b	'CMPA'
	dc.b	'.W     ',0
	dc.b	2
	dc.b	$88
CMPAL.DIS_MSG:
	dc.b	'CMPA.L     ',0
	dc.b	3
	dc.b	$88
DIS_1_1100:
	dc.w	6
	dr.w	DIS_lbW001646
	dr.w	DIS_lbW0016CC
	dr.w	DIS_lbW001752
	dr.w	DIS_lbW0017CA
DIS_lbW001646:
	dc.w	8
	dr.w	DIS_lbW00164C
	dr.w	DIS_lbW00167E
DIS_lbW00164C:
	dc.w	2
	dr.w	ANDB.DIS_MSG
	dr.w	ANDB.DIS_MSG
	dr.w	ANDB.DIS_MSG
	dr.w	ANDB.DIS_MSG
	dr.w	ANDB.DIS_MSG
	dr.w	ANDB.DIS_MSG
	dr.w	ANDB.DIS_MSG
	dr.w	DIS_lbW00165E
DIS_lbW00165E:
	dc.w	0
	dr.w	ANDB.DIS_MSG
	dr.w	ANDB.DIS_MSG
	dr.w	ANDB.DIS_MSG
	dr.w	ANDB.DIS_MSG
	dr.w	ANDB.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
ANDB.DIS_MSG:
	dc.b	'AND.B      ',0
	dc.b	1
	dc.b	$87
DIS_lbW00167E:
	dc.w	2
	dr.w	ABCDB.DIS_MSG
	dr.w	ABCDB.DIS_MSG0
	dr.w	ANDB.DIS_MSG0
	dr.w	ANDB.DIS_MSG0
	dr.w	ANDB.DIS_MSG0
	dr.w	ANDB.DIS_MSG0
	dr.w	ANDB.DIS_MSG0
	dr.w	DIS_lbW001690
DIS_lbW001690:
	dc.w	0
	dr.w	ANDB.DIS_MSG0
	dr.w	ANDB.DIS_MSG0
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
ANDB.DIS_MSG0:
	dc.b	'AND.B      ',0
	dc.b	$87
	dc.b	1
ABCDB.DIS_MSG0:
	dc.b	'ABCD.B     ',0
	dc.b	15
	dc.b	$8F
ABCDB.DIS_MSG:
	dc.b	'ABCD.B     ',0
	dc.b	7
	dc.b	$87
DIS_lbW0016CC:
	dc.w	8
	dr.w	DIS_lbW0016D2
	dr.w	DIS_lbW001704
DIS_lbW0016D2:
	dc.w	2
	dr.w	ANDW.DIS_MSG
	dr.w	ANDW.DIS_MSG
	dr.w	ANDW.DIS_MSG
	dr.w	ANDW.DIS_MSG
	dr.w	ANDW.DIS_MSG
	dr.w	ANDW.DIS_MSG
	dr.w	ANDW.DIS_MSG
	dr.w	DIS_lbW0016E4
DIS_lbW0016E4:
	dc.w	0
	dr.w	ANDW.DIS_MSG
	dr.w	ANDW.DIS_MSG
	dr.w	ANDW.DIS_MSG
	dr.w	ANDW.DIS_MSG
	dr.w	ANDW.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
ANDW.DIS_MSG:
	dc.b	'AND.W      ',0
	dc.b	2
	dc.b	$87
DIS_lbW001704:
	dc.w	2
	dr.w	EXG.DIS_MSG
	dr.w	EXG.DIS_MSG0
	dr.w	ANDW.DIS_MSG0
	dr.w	ANDW.DIS_MSG0
	dr.w	ANDW.DIS_MSG0
	dr.w	ANDW.DIS_MSG0
	dr.w	ANDW.DIS_MSG0
	dr.w	DIS_lbW001716
DIS_lbW001716:
	dc.w	0
	dr.w	ANDW.DIS_MSG0
	dr.w	ANDW.DIS_MSG0
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
ANDW.DIS_MSG0:
	dc.b	'AND.W      ',0
	dc.b	$87
	dc.b	2
EXG.DIS_MSG:
	dc.b	'EXG        ',0
	dc.b	$87
	dc.b	7
EXG.DIS_MSG0:
	dc.b	'EXG        ',0
	dc.b	$88
	dc.b	8
DIS_lbW001752:
	dc.w	8
	dr.w	DIS_lbW001758
	dr.w	DIS_lbW00178A
DIS_lbW001758:
	dc.w	2
	dr.w	ANDL.DIS_MSG
	dr.w	ANDL.DIS_MSG
	dr.w	ANDL.DIS_MSG
	dr.w	ANDL.DIS_MSG
	dr.w	ANDL.DIS_MSG
	dr.w	ANDL.DIS_MSG
	dr.w	ANDL.DIS_MSG
	dr.w	DIS_lbW00176A
DIS_lbW00176A:
	dc.w	0
	dr.w	ANDL.DIS_MSG
	dr.w	ANDL.DIS_MSG
	dr.w	ANDL.DIS_MSG
	dr.w	ANDL.DIS_MSG
	dr.w	ANDL.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
ANDL.DIS_MSG:
	dc.b	'AND.L      ',0
	dc.b	3
	dc.b	$87
DIS_lbW00178A:
	dc.w	2
	dr.w	DC.DIS_MSG
	dr.w	EXG.DIS_MSG1
	dr.w	ANDL.DIS_MSG0
	dr.w	ANDL.DIS_MSG0
	dr.w	ANDL.DIS_MSG0
	dr.w	ANDL.DIS_MSG0
	dr.w	ANDL.DIS_MSG0
	dr.w	DIS_lbW00179C
DIS_lbW00179C:
	dc.w	0
	dr.w	ANDL.DIS_MSG0
	dr.w	ANDL.DIS_MSG0
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
ANDL.DIS_MSG0:
	dc.b	'AND.L      ',0
	dc.b	$87
	dc.b	3
EXG.DIS_MSG1:
	dc.b	'EXG        ',0
	dc.b	$87
	dc.b	8
DIS_lbW0017CA:
	dc.w	2
	dr.w	DIS_lbW0017EE
	dr.w	DC.DIS_MSG
	dr.w	DIS_lbW0017EE
	dr.w	DIS_lbW0017EE
	dr.w	DIS_lbW0017EE
	dr.w	DIS_lbW0017EE
	dr.w	DIS_lbW0017EE
	dr.w	DIS_lbW0017DC
DIS_lbW0017DC:
	dc.w	0
	dr.w	DIS_lbW0017EE
	dr.w	DIS_lbW0017EE
	dr.w	DIS_lbW0017EE
	dr.w	DIS_lbW0017EE
	dr.w	DIS_lbW0017EE
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
DIS_lbW0017EE:
	dc.w	8
	dr.w	MULUW.DIS_MSG
	dr.w	MULSW.DIS_MSG
MULUW.DIS_MSG:
	dc.b	'MU'
	dc.b	'LU.W     ',0
	dc.b	2
	dc.b	$87
MULSW.DIS_MSG:
	dc.b	'MULS.W     ',0
	dc.b	2
	dc.b	$87
DIS_1_1101:
	dc.w	6
	dr.w	DIS_lbW00181A
	dr.w	DIS_lbW0018A0
	dr.w	DIS_lbW001926
	dr.w	DIS_lbW0019AC
DIS_lbW00181A:
	dc.w	8
	dr.w	DIS_lbW001820
	dr.w	DIS_lbW001852
DIS_lbW001820:
	dc.w	2
	dr.w	ADDB.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	ADDB.DIS_MSG
	dr.w	ADDB.DIS_MSG
	dr.w	ADDB.DIS_MSG
	dr.w	ADDB.DIS_MSG
	dr.w	ADDB.DIS_MSG
	dr.w	DIS_lbW001832
DIS_lbW001832:
	dc.w	0
	dr.w	ADDB.DIS_MSG
	dr.w	ADDB.DIS_MSG
	dr.w	ADDB.DIS_MSG
	dr.w	ADDB.DIS_MSG
	dr.w	ADDB.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
ADDB.DIS_MSG:
	dc.b	'ADD.B      ',0
	dc.b	1
	dc.b	$87
DIS_lbW001852:
	dc.w	2
	dr.w	ADDXB.DIS_MSG
	dr.w	ADDXB.DIS_MSG0
	dr.w	ADDB.DIS_MSG0
	dr.w	ADDB.DIS_MSG0
	dr.w	ADDB.DIS_MSG0
	dr.w	ADDB.DIS_MSG0
	dr.w	ADDB.DIS_MSG0
	dr.w	DIS_lbW001864
DIS_lbW001864:
	dc.w	0
	dr.w	ADDB.DIS_MSG0
	dr.w	ADDB.DIS_MSG0
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
ADDB.DIS_MSG0:
	dc.b	'ADD.B      ',0
	dc.b	$87
	dc.b	1
ADDXB.DIS_MSG0:
	dc.b	'ADDX.B     ',0
	dc.b	15
	dc.b	$8F
ADDXB.DIS_MSG:
	dc.b	'ADDX.B     ',0
	dc.b	7
	dc.b	$87
DIS_lbW0018A0:
	dc.w	8
	dr.w	DIS_lbW0018A6
	dr.w	DIS_lbW0018D8
DIS_lbW0018A6:
	dc.w	2
	dr.w	ADDW.DIS_MSG
	dr.w	ADDW.DIS_MSG
	dr.w	ADDW.DIS_MSG
	dr.w	ADDW.DIS_MSG
	dr.w	ADDW.DIS_MSG
	dr.w	ADDW.DIS_MSG
	dr.w	ADDW.DIS_MSG
	dr.w	DIS_lbW0018B8
DIS_lbW0018B8:
	dc.w	0
	dr.w	ADDW.DIS_MSG
	dr.w	ADDW.DIS_MSG
	dr.w	ADDW.DIS_MSG
	dr.w	ADDW.DIS_MSG
	dr.w	ADDW.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
ADDW.DIS_MSG:
	dc.b	'ADD.W      ',0
	dc.b	2
	dc.b	$87
DIS_lbW0018D8:
	dc.w	2
	dr.w	ADDXW.DIS_MSG
	dr.w	ADDXW.DIS_MSG0
	dr.w	ADDW.DIS_MSG0
	dr.w	ADDW.DIS_MSG0
	dr.w	ADDW.DIS_MSG0
	dr.w	ADDW.DIS_MSG0
	dr.w	ADDW.DIS_MSG0
	dr.w	DIS_lbW0018EA
DIS_lbW0018EA:
	dc.w	0
	dr.w	ADDW.DIS_MSG0
	dr.w	ADDW.DIS_MSG0
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
ADDW.DIS_MSG0:
	dc.b	'ADD.W      ',0
	dc.b	$87
	dc.b	2
ADDXW.DIS_MSG0:
	dc.b	'ADDX.W     ',0
	dc.b	15
	dc.b	$8F
ADDXW.DIS_MSG:
	dc.b	'ADDX.W     ',0
	dc.b	7
	dc.b	$87
DIS_lbW001926:
	dc.w	8
	dr.w	DIS_lbW00192C
	dr.w	DIS_lbW00195E
DIS_lbW00192C:
	dc.w	2
	dr.w	ADDL.DIS_MSG
	dr.w	ADDL.DIS_MSG
	dr.w	ADDL.DIS_MSG
	dr.w	ADDL.DIS_MSG
	dr.w	ADDL.DIS_MSG
	dr.w	ADDL.DIS_MSG
	dr.w	ADDL.DIS_MSG
	dr.w	DIS_lbW00193E
DIS_lbW00193E:
	dc.w	0
	dr.w	ADDL.DIS_MSG
	dr.w	ADDL.DIS_MSG
	dr.w	ADDL.DIS_MSG
	dr.w	ADDL.DIS_MSG
	dr.w	ADDL.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
ADDL.DIS_MSG:
	dc.b	'ADD.L      ',0
	dc.b	3
	dc.b	$87
DIS_lbW00195E:
	dc.w	2
	dr.w	ADDXL.DIS_MSG
	dr.w	ADDXL.DIS_MSG0
	dr.w	ADDL.DIS_MSG0
	dr.w	ADDL.DIS_MSG0
	dr.w	ADDL.DIS_MSG0
	dr.w	ADDL.DIS_MSG0
	dr.w	ADDL.DIS_MSG0
	dr.w	DIS_lbW001970
DIS_lbW001970:
	dc.w	0
	dr.w	ADDL.DIS_MSG0
	dr.w	ADDL.DIS_MSG0
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
ADDL.DIS_MSG0:
	dc.b	'ADD.L      ',0
	dc.b	$87
	dc.b	3
ADDXL.DIS_MSG0:
	dc.b	'ADDX.L     ',0
	dc.b	15
	dc.b	$8F
ADDXL.DIS_MSG:
	dc.b	'ADDX.L     ',0
	dc.b	7
	dc.b	$87
DIS_lbW0019AC:
	dc.w	2
	dr.w	DIS_lbW0019D0
	dr.w	DIS_lbW0019D0
	dr.w	DIS_lbW0019D0
	dr.w	DIS_lbW0019D0
	dr.w	DIS_lbW0019D0
	dr.w	DIS_lbW0019D0
	dr.w	DIS_lbW0019D0
	dr.w	DIS_lbW0019BE
DIS_lbW0019BE:
	dc.w	0
	dr.w	DIS_lbW0019D0
	dr.w	DIS_lbW0019D0
	dr.w	DIS_lbW0019D0
	dr.w	DIS_lbW0019D0
	dr.w	DIS_lbW0019D0
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
DIS_lbW0019D0:
	dc.w	8
	dr.w	ADDAW.DIS_MSG
	dr.w	ADDAL.DIS_MSG
ADDAW.DIS_MSG:
	dc.b	'ADDA.W     ',0
	dc.b	2
	dc.b	$88
ADDAL.DIS_MSG:
	dc.b	'ADDA.L     ',0
	dc.b	3
	dc.b	$88
DIS_1_1110:
	dc.w	6
	dr.w	DIS_lbW0019FC
	dr.w	DIS_lbW001B1E
	dr.w	DIS_lbW001C40
	dr.w	DIS_lbW001D62
DIS_lbW0019FC:
	dc.w	2
	dr.w	DIS_lbW001A32
	dr.w	DIS_lbW001A26
	dr.w	DIS_lbW001A1A
	dr.w	DIS_lbW001A0E
	dr.w	DIS_lbW001A38
	dr.w	DIS_lbW001A2C
	dr.w	DIS_lbW001A20
	dr.w	DIS_lbW001A14
DIS_lbW001A0E:
	dc.w	8
	dr.w	RORB.DIS_MSG
	dr.w	ROLB.DIS_MSG
DIS_lbW001A14:
	dc.w	8
	dr.w	RORB.DIS_MSG0
	dr.w	ROLB.DIS_MSG0
DIS_lbW001A1A:
	dc.w	8
	dr.w	ROXRB.DIS_MSG
	dr.w	ROXLB.DIS_MSG
DIS_lbW001A20:
	dc.w	8
	dr.w	ROXRB.DIS_MSG0
	dr.w	ROXLB.DIS_MSG0
DIS_lbW001A26:
	dc.w	8
	dr.w	LSR.DIS_MSG
	dr.w	LSLB.DIS_MSG
DIS_lbW001A2C:
	dc.w	8
	dr.w	LSRB.DIS_MSG
	dr.w	LSLB.DIS_MSG0
DIS_lbW001A32:
	dc.w	8
	dr.w	ASRB.DIS_MSG
	dr.w	ASLB.DIS_MSG
DIS_lbW001A38:
	dc.w	8
	dr.w	ASRB.DIS_MSG0
	dr.w	ASLB.DIS_MSG0
ASRB.DIS_MSG0:
	dc.b	'ASR.B      ',0
	dc.b	$87
	dc.b	7
ASLB.DIS_MSG0:
	dc.b	'ASL.B      ',0
	dc.b	$87
	dc.b	7
ASRB.DIS_MSG:
	dc.b	'ASR.B      ',0
	dc.b	$91
	dc.b	7
ASLB.DIS_MSG:
	dc.b	'ASL.B      ',0
	dc.b	$91
	dc.b	7
LSRB.DIS_MSG:
	dc.b	'LSR.B      ',0
	dc.b	$87
	dc.b	7
LSLB.DIS_MSG0:
	dc.b	'LSL.B      ',0
	dc.b	$87
	dc.b	7
LSR.DIS_MSG:
	dc.b	'LSR'
B.DIS_MSG:
	dc.b	'.B      ',0
	dc.b	$91
	dc.b	7
LSLB.DIS_MSG:
	dc.b	'LSL.B      ',0
	dc.b	$91
	dc.b	7
RORB.DIS_MSG0:
	dc.b	'ROR.B      ',0
	dc.b	$87
	dc.b	7
ROLB.DIS_MSG0:
	dc.b	'ROL.B      ',0
	dc.b	$87
	dc.b	7
RORB.DIS_MSG:
	dc.b	'ROR.B      ',0
	dc.b	$91
	dc.b	7
ROLB.DIS_MSG:
	dc.b	'ROL.B      ',0
	dc.b	$91
	dc.b	7
ROXRB.DIS_MSG0:
	dc.b	'ROXR.B     ',0
	dc.b	$87
	dc.b	7
ROXLB.DIS_MSG0:
	dc.b	'ROXL.B     ',0
	dc.b	$87
	dc.b	7
ROXRB.DIS_MSG:
	dc.b	'ROXR.B     ',0
	dc.b	$91
	dc.b	7
ROXLB.DIS_MSG:
	dc.b	'ROXL.B     ',0
	dc.b	$91
	dc.b	7
DIS_lbW001B1E:
	dc.w	2
	dr.w	DIS_lbW001B54
	dr.w	DIS_lbW001B48
	dr.w	DIS_lbW001B3C
	dr.w	DIS_lbW001B30
	dr.w	DIS_lbW001B5A
	dr.w	DIS_lbW001B4E
	dr.w	DIS_lbW001B42
	dr.w	DIS_lbW001B36
DIS_lbW001B30:
	dc.w	8
	dr.w	RORW.DIS_MSG
	dr.w	ROLW.DIS_MSG
DIS_lbW001B36:
	dc.w	8
	dr.w	RORW.DIS_MSG0
	dr.w	ROLW.DIS_MSG0
DIS_lbW001B3C:
	dc.w	8
	dr.w	ROXRW.DIS_MSG
	dr.w	ROXLW.DIS_MSG
DIS_lbW001B42:
	dc.w	8
	dr.w	ROXRW.DIS_MSG0
	dr.w	ROXLW.DIS_MSG0
DIS_lbW001B48:
	dc.w	8
	dr.w	LSRW.DIS_MSG
	dr.w	LSLW.DIS_MSG
DIS_lbW001B4E:
	dc.w	8
	dr.w	LSRW.DIS_MSG0
	dr.w	LSLW.DIS_MSG0
DIS_lbW001B54:
	dc.w	8
	dr.w	ASRW.DIS_MSG
	dr.w	ASLW.DIS_MSG
DIS_lbW001B5A:
	dc.w	8
	dr.w	ASRW.DIS_MSG0
	dr.w	ASLW.DIS_MSG0
ASRW.DIS_MSG0:
	dc.b	'ASR.W      ',0
	dc.b	$87
	dc.b	7
ASLW.DIS_MSG0:
	dc.b	'ASL.W      ',0
	dc.b	$87
	dc.b	7
ASRW.DIS_MSG:
	dc.b	'ASR.W      ',0
	dc.b	$91
	dc.b	7
ASLW.DIS_MSG:
	dc.b	'ASL.W      ',0
	dc.b	$91
	dc.b	7
LSRW.DIS_MSG0:
	dc.b	'LSR.W      ',0
	dc.b	$87
	dc.b	7
LSLW.DIS_MSG0:
	dc.b	'LSL.W      ',0
	dc.b	$87
	dc.b	7
LSRW.DIS_MSG:
	dc.b	'LSR.W      ',0
	dc.b	$91
	dc.b	7
LSLW.DIS_MSG:
	dc.b	'LSL.W      ',0
	dc.b	$91
	dc.b	7
RORW.DIS_MSG0:
	dc.b	'ROR.W      ',0
	dc.b	$87
	dc.b	7
ROLW.DIS_MSG0:
	dc.b	'ROL.W      ',0
	dc.b	$87
	dc.b	7
RORW.DIS_MSG:
	dc.b	'ROR.W      ',0
	dc.b	$91
	dc.b	7
ROLW.DIS_MSG:
	dc.b	'ROL.W      ',0
	dc.b	$91
	dc.b	7
ROXRW.DIS_MSG0:
	dc.b	'ROXR.W     ',0
	dc.b	$87
	dc.b	7
ROXLW.DIS_MSG0:
	dc.b	'ROXL.W     ',0
	dc.b	$87
	dc.b	7
ROXRW.DIS_MSG:
	dc.b	'ROXR.W     ',0
	dc.b	$91
	dc.b	7
ROXLW.DIS_MSG:
	dc.b	'ROXL.W     ',0
	dc.b	$91
	dc.b	7
DIS_lbW001C40:
	dc.w	2
	dr.w	DIS_lbW001C76
	dr.w	DIS_lbW001C6A
	dr.w	DIS_lbW001C5E
	dr.w	DIS_lbW001C52
	dr.w	DIS_lbW001C7C
	dr.w	DIS_lbW001C70
	dr.w	DIS_lbW001C64
	dr.w	DIS_lbW001C58
DIS_lbW001C52:
	dc.w	8
	dr.w	RORL.DIS_MSG
	dr.w	ROLL.DIS_MSG
DIS_lbW001C58:
	dc.w	8
	dr.w	RORL.DIS_MSG0
	dr.w	ROLL.DIS_MSG0
DIS_lbW001C5E:
	dc.w	8
	dr.w	ROXRL.DIS_MSG
	dr.w	ROXLL.DIS_MSG
DIS_lbW001C64:
	dc.w	8
	dr.w	ROXRL.DIS_MSG0
	dr.w	ROXLL.DIS_MSG0
DIS_lbW001C6A:
	dc.w	8
	dr.w	LSRL.DIS_MSG
	dr.w	LSLL.DIS_MSG
DIS_lbW001C70:
	dc.w	8
	dr.w	LSRL.DIS_MSG0
	dr.w	LSLL.DIS_MSG0
DIS_lbW001C76:
	dc.w	8
	dr.w	ASRL.DIS_MSG
	dr.w	ASLL.DIS_MSG
DIS_lbW001C7C:
	dc.w	8
	dr.w	ASRL.DIS_MSG0
	dr.w	ASLL.DIS_MSG0
ASRL.DIS_MSG0:
	dc.b	'ASR.L      ',0
	dc.b	$87
	dc.b	7
ASLL.DIS_MSG0:
	dc.b	'ASL.L      ',0
	dc.b	$87
	dc.b	7
ASRL.DIS_MSG:
	dc.b	'ASR.L      ',0
	dc.b	$91
	dc.b	7
ASLL.DIS_MSG:
	dc.b	'ASL.L      ',0
	dc.b	$91
	dc.b	7
LSRL.DIS_MSG0:
	dc.b	'LSR.L      ',0
	dc.b	$87
	dc.b	7
LSLL.DIS_MSG0:
	dc.b	'LSL.L      ',0
	dc.b	$87
	dc.b	7
LSRL.DIS_MSG:
	dc.b	'LSR.L      ',0
	dc.b	$91
	dc.b	7
LSLL.DIS_MSG:
	dc.b	'LSL.L      ',0
	dc.b	$91
	dc.b	7
RORL.DIS_MSG0:
	dc.b	'ROR.L      ',0
	dc.b	$87
	dc.b	7
ROLL.DIS_MSG0:
	dc.b	'ROL.L      ',0
	dc.b	$87
	dc.b	7
RORL.DIS_MSG:
	dc.b	'ROR.L      ',0
	dc.b	$91
	dc.b	7
ROLL.DIS_MSG:
	dc.b	'ROL.L      ',0
	dc.b	$91
	dc.b	7
ROXRL.DIS_MSG0:
	dc.b	'ROXR.L     ',0
	dc.b	$87
	dc.b	7
ROXLL.DIS_MSG0:
	dc.b	'ROXL.L     ',0
	dc.b	$87
	dc.b	7
ROXRL.DIS_MSG:
	dc.b	'ROXR.L     ',0
	dc.b	$91
	dc.b	7
ROXLL.DIS_MSG:
	dc.b	'ROXL.L     ',0
	dc.b	$91
	dc.b	7
DIS_lbW001D62:
	dc.w	2
	dr.w	DIS_lbW001D86
	dr.w	DC.DIS_MSG
	dr.w	DIS_lbW001D86
	dr.w	DIS_lbW001D86
	dr.w	DIS_lbW001D86
	dr.w	DIS_lbW001D86
	dr.w	DIS_lbW001D86
	dr.w	DIS_lbW001D74
DIS_lbW001D74:
	dc.w	0
	dr.w	DIS_lbW001D86
	dr.w	DIS_lbW001D86
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
	dr.w	DC.DIS_MSG
DIS_lbW001D86:
	dc.w	12
	dr.w	DIS_lbW001E20
	dr.w	DIS_lbW001E26
	dr.w	DIS_lbW001E32
	dr.w	DIS_lbW001E2C
	dr.w	DIS_lbW001DA4
	dr.w	DIS_lbW001D9E
	dr.w	DIS_lbW001DAA
	dr.w	DIS_lbW001D98
DIS_lbW001D98:
	dc.w	8
	dr.w	BFSET.DIS_MSG
	dr.w	BFINS.DIS_MSG
DIS_lbW001D9E:
	dc.w	8
	dr.w	BFCHG.DIS_MSG
	dr.w	BFEXTS.DIS_MSG
DIS_lbW001DA4:
	dc.w	8
	dr.w	BFTST.DIS_MSG
	dr.w	BFEXTU.DIS_MSG
DIS_lbW001DAA:
	dc.w	8
	dr.w	BFCLR.DIS_MSG
	dr.w	BFFFO.DIS_MSG

BFINS.DIS_MSG:	dc.b	'BFINS      ',0
		dc.b	$19,$18
BFFFO.DIS_MSG:	dc.b	'BFFFO      ',0
		dc.b	$18,$19
BFEXTU.DIS_MSG:	dc.b	'BFEXTU     ',0
		dc.b	$18,$19
BFEXTS.DIS_MSG:	dc.b	'BFEXTS     ',0
		dc.b	$18,$19
BFCHG.DIS_MSG:	dc.b	'BFCHG      ',0
		dc.b	$18,0
BFCLR.DIS_MSG:	dc.b	'BFCLR      ',0
		dc.b	$18,0
BFSET.DIS_MSG:	dc.b	'BFSET      ',0
		dc.b	$18,0
BFTST.DIS_MSG:	dc.b	'BFTST      ',0
		dc.b	$18,0

DIS_lbW001E20:
	dc.w	8
	dr.w	ASRW.DIS_MSG1
	dr.w	ASLW.DIS_MSG1
DIS_lbW001E26:
	dc.w	8
	dr.w	LSRW.DIS_MSG1
	dr.w	LSLW.DIS_MSG1
DIS_lbW001E2C:
	dc.w	8
	dr.w	RORW.DIS_MSG1
	dr.w	ROLW.DIS_MSG1
DIS_lbW001E32:
	dc.w	8
	dr.w	ROXRW.DIS_MSG1
	dr.w	ROXLW.DIS_MSG1
	
ROXRW.DIS_MSG1:	dc.b	'ROXR.W     ',0
		dc.b	2,0
ROXLW.DIS_MSG1:	dc.b	'ROXL.W     ',0
		dc.b	2,0
RORW.DIS_MSG1:	dc.b	'ROR.W      ',0
		dc.b	2,0
ROLW.DIS_MSG1:	dc.b	'ROL.W      ',0
		dc.b	2,0
ASRW.DIS_MSG1:	dc.b	'ASR.W      ',0
		dc.b	2,0
ASLW.DIS_MSG1:	dc.b	'ASL.W      ',0
		dc.b	2,0
LSRW.DIS_MSG1:	dc.b	'LSR.W      ',0
		dc.b	2,0
LSLW.DIS_MSG1:	dc.b	'LSL.W      ',0
		dc.b	2,0
		
DIS_NM_LINEF:
	dc.w	BIT_8_B
	dr.w	DIS_lbW0020BC
	dr.w	DIS_lbW002014
	dr.w	DIS_lbW001EDC
	dr.w	DIS_lbW001ECA
	dr.w	DIS_lbW001F9E
	dr.w	DIS_lbW00203A
	dr.w	MOVE16.DIS_MSG
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
DIS_lbW001ECA:
	dc.w	4
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
	dr.w	FSAVE.DIS_MSG
	dr.w	FRESTORE.DIS_MSG
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
DIS_lbW001EDC:
	dc.w	4
	dr.w	DIS_lbW002004
	dr.w	DIS_lbW001F18
	dr.w	FBq.DIS_MSG
	dr.w	FBq.DIS_MSG0
	dr.w	FSAVE.DIS_MSG
	dr.w	FRESTORE.DIS_MSG
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
FSAVE.DIS_MSG:
	dc.b	'FSAVE      ',0
	dc.b	'(',0
FRESTORE.DIS_MSG:
	dc.b	'FRESTORE   ',0
	dc.b	'(',0
MOVE16.DIS_MSG:
	dc.b	'MOVE16     ',0
	dc.b	59,0

DIS_lbW001F18:
	dc.w	2
	dr.w	FSq.DIS_MSG
	dr.w	FDBq.DIS_MSG
	dr.w	FSq.DIS_MSG
	dr.w	FSq.DIS_MSG
	dr.w	FSq.DIS_MSG
	dr.w	FSq.DIS_MSG
	dr.w	FSq.DIS_MSG
	dr.w	DIS_lbW001F54
FBq.DIS_MSG:
	dc.b	'FBq.       '
	dc.b	2
	dc.b	11
	dc.b	0
FBq.DIS_MSG0:
	dc.b	'FBq.       '
	dc.b	2
	dc.b	'*',0
FDBq.DIS_MSG:
	dc.b	'FDBq       '
	dc.b	2
	dc.b	',',0
DIS_lbW001F54:
	dc.w	0
	dr.w	FSq.DIS_MSG
	dr.w	FSq.DIS_MSG
	dr.w	FTRAPq.DIS_MSG
	dr.w	FTRAPq.DIS_MSG0
	dr.w	FTRAPq.DIS_MSG1
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
FSq.DIS_MSG:
	dc.b	'FSq        ',0
	dc.w	$2B00
FTRAPq.DIS_MSG:
	dc.b	'FTRAPq.    ',0
	dc.w	$2F00
FTRAPq.DIS_MSG0:
	dc.b	'FTRAPq.    ',0
	dc.w	$2D00
FTRAPq.DIS_MSG1:
	dc.b	'FTRAPq     ',0
	dc.w	$2E00
DIS_lbW001F9E:
	dc.w	2
	dr.w	LINE.DIS_MSG
	dr.w	CINVL.DIS_MSG
	dr.w	CINVP.DIS_MSG
	dr.w	CINVA.DIS_MSG
	dr.w	LINE.DIS_MSG
	dr.w	CPUSHL.DIS_MSG
	dr.w	CPUSHP.DIS_MSG
	dr.w	CPUSHA.DIS_MSG
CINVL.DIS_MSG:
	dc.b	'CINVL      ',0
	dc.w	$4800
CPUSHL.DIS_MSG:
	dc.b	'CPUSHL     ',0
	dc.w	$4800
CINVP.DIS_MSG:
	dc.b	'CINVP      ',0
	dc.w	$4800
CPUSHP.DIS_MSG:
	dc.b	'CPUSHP     ',0
	dc.w	$4800
CINVA.DIS_MSG:
	dc.b	'CINVA      ',0
	dc.w	$4800
CPUSHA.DIS_MSG:
	dc.b	'CPUSHA     ',0
	dc.w	$4800
DIS_lbW002004:
	dc.w	$0014
	dr.w	DIS_lbW00200E
	dr.w	DIS_lbW00200E
	dr.w	DIS_lbW002360
	dr.w	FMOVEMX.DIS_MSG
DIS_lbW00200E:
	dc.w	$001C
	dr.w	DIS_lbW0022C6
	dr.w	DIS_lbW002348
DIS_lbW002014:
	dc.w	6
	dr.w	PSAVE.DIS_MSG
	dr.w	PRESTORE.DIS_MSG
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
PSAVE.DIS_MSG:
	dc.b	'PSAVE      ',0
	dc.w	$2800
PRESTORE.DIS_MSG:
	dc.b	'PRESTORE   ',0
	dc.w	$2800
DIS_lbW00203A:
	dc.w	6
	dr.w	DIS_lbW002044
	dr.w	DIS_lbW00208E
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
DIS_lbW002044:
	dc.w	2
	dr.w	PFLUSHN.DIS_MSG
	dr.w	PFLUSH.DIS_MSG
	dr.w	PFLUSHAN.DIS_MSG
	dr.w	PFLUSHA.DIS_MSG
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
PFLUSHN.DIS_MSG:
	dc.b	'PFLUSHN    ',0
	dc.w	$3C00
PFLUSH.DIS_MSG:
	dc.b	'PFLUSH     ',0
	dc.w	$3C00
PFLUSHAN.DIS_MSG:
	dc.b	'PFLUSHAN   ',0
	dc.w	$3D00
PFLUSHA.DIS_MSG:
	dc.b	'PFLUSHA    ',0
	dc.w	$3d00

DIS_lbW00208E:
	dc.w	2
	dr.w	PTESTW.DIS_MSG
	dr.w	PTESTW.DIS_MSG
	dr.w	PTESTW.DIS_MSG
	dr.w	PTESTW.DIS_MSG
	dr.w	PTESTR.DIS_MSG
	dr.w	PTESTR.DIS_MSG
	dr.w	PTESTR.DIS_MSG
	dr.w	PTESTR.DIS_MSG
PTESTW.DIS_MSG:
	dc.b	'PTESTW     ',0
	dc.b	'>',0
PTESTR.DIS_MSG:
	dc.b	'PTESTR     ',0
	dc.b	'>',0
DIS_lbW0020BC:
	dc.w	6
	dr.w	DIS_lbW00214C
	dr.w	DIS_lbW0020C6
	dr.w	PBx.DIS_MSG
	dr.w	PBx.DIS_MSG0
DIS_lbW0020C6:
	dc.w	2
	dr.w	PSx.DIS_MSG
	dr.w	PDBx.DIS_MSG
	dr.w	PSx.DIS_MSG
	dr.w	PSx.DIS_MSG
	dr.w	PSx.DIS_MSG
	dr.w	PSx.DIS_MSG
	dr.w	PSx.DIS_MSG
	dr.w	DIS_lbW0020F4
PSx.DIS_MSG:
	dc.b	'PSx        ',0
	dc.b	'+',0
PDBx.DIS_MSG:
	dc.b	'PDBx       ',0
	dc.b	',',0
DIS_lbW0020F4:
	dc.w	0
	dr.w	PSx.DIS_MSG
	dr.w	PSx.DIS_MSG
	dr.w	PTRAPx.DIS_MSG
	dr.w	PTRAPx.DIS_MSG0
	dr.w	PTRAPx.DIS_MSG1
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG

PTRAPx.DIS_MSG:	dc.b	'PTRAPx.    ',0
		dc.w	$2F00
PTRAPx.DIS_MSG0:dc.b	'PTRAPx.    ',0
		dc.w	$2D00
PTRAPx.DIS_MSG1:dc.b	'PTRAPx     ',0
		dc.w	$2E00
PBx.DIS_MSG:	dc.b	'PBx.       ',0
		dc.w	$0B00
PBx.DIS_MSG0:	dc.b	'PBx.       ',0
		dc.w	$2A00

DIS_lbW00214C:
	dc.w	$0014
	dr.w	DIS_lbW002156
	dr.w	DIS_lbW00215C
	dr.w	DIS_lbW002212	;DIS_lbW00220C
	dr.w	LINE.DIS_MSG
DIS_lbW002156:
	dc.w	$001C
	dr.w	DIS_lbW0021B0
	dr.w	DIS_lbW00224E
DIS_lbW00215C:
	dc.w	$001C
	dr.w	DIS_lbW002162
	dr.w	DIS_lbW002174

DIS_lbW002162:
	dc.w	BIT_12_10
	dr.w	DIS_lbW0021B0	;000
	dr.w	DIS_lbW0021DE	;001
	dr.w	DIS_lbW0021DE	;010
	dr.w	DIS_lbW0021DE	;011
	dr.w	PMOVEB.DIS_MSG	;100
	dr.w	PMOVEB.DIS_MSG	;101
	dr.w	PMOVEB.DIS_MSG	;110
	dr.w	DIS_lbW002174	;111

;DIS_PMOVE:
;	dc.w	BIT_3_5
;	dr.w	PMOVEB.DIS_MSG	;000
;	dr.w	PMOVEW.DIS_MSG	;001
;	dr.w	PMOVEB.DIS_MSG	;010
;	dr.w	PMOVEW.DIS_MSG	;011
;	dr.w	PMOVEB.DIS_MSG	;100
;	dr.w	PMOVEW.DIS_MSG	;101
;	dr.w	PMOVEB.DIS_MSG	;110
;	dr.w	PMOVEW.DIS_MSG	;111

DIS_lbW002174:
	dc.w	BIT_9_7
	dr.w	PMOVEW.DIS_MSG		;000
	dr.w	PMOVEW.DIS_MSG		;001
	dr.w	PMOVEFD.DIS_MSG		;010
	dr.w	PMOVEFD.DIS_MSG		;011
	dr.w	PMOVEW.DIS_MSG		;100
	dr.w	PMOVEW.DIS_MSG		;101
	dr.w	PMOVEFD.DIS_MSG		;110
	dr.w	PMOVEFD.DIS_MSG		;111

PMOVEB.DIS_MSG:	dc.b	'PMOVE.B    ',0
		dc.w	$4600
PMOVEW.DIS_MSG:	dc.b	'PMOVE.W    ',0
		dc.w	$4400
PMOVEFD.DIS_MSG:
		dc.b	'PMOVEFD    ',0
		dc.w	$4400
DIS_lbW0021B0:
	dc.w	$0016
	dr.w	PMOVEL.DIS_MSG
	dr.w	PMOVEL.DIS_MSG
	dr.w	PMOVEFDL.DIS_MSG
	dr.w	PMOVEFDL.DIS_MSG
	dr.w	PMOVEL.DIS_MSG
	dr.w	PMOVEL.DIS_MSG
	dr.w	PMOVEFDL.DIS_MSG
	dr.w	PMOVEFDL.DIS_MSG

PMOVEFDL.DIS_MSG:
		dc.b	'PMOVEFD.L  ',0
		dc.w	$4500
PMOVEL.DIS_MSG:	dc.b	'PMOVE.L    ',0
		dc.w	$4500

DIS_lbW0021DE:
	dc.w	$0016
	dr.w	PMOVEQ.DIS_MSG
	dr.w	PMOVEQ.DIS_MSG
	dr.w	PMOVEFDQ.DIS_MSG
	dr.w	PMOVEFDQ.DIS_MSG
	dr.w	PMOVEQ.DIS_MSG
	dr.w	PMOVEQ.DIS_MSG
	dr.w	PMOVEFDQ.DIS_MSG
	dr.w	PMOVEFDQ.DIS_MSG
PMOVEFDQ.DIS_MSG:
	dc.b	'PMOVEFD.Q  ',0
	dc.w	$4700
PMOVEQ.DIS_MSG:
	dc.b	'PMOVE.Q    ',0
	dc.w	$4700

;DIS_lbW00220C:
;	dc.w	$001C
;	dr.w	DIS_lbW002212
;	dr.w	PFLUSHR.DIS_MSG

DIS_lbW002212:
	dc.w	$0016
	dr.w	PTESTW.DIS_MSG0
	dr.w	PTESTW.DIS_MSG0
	dr.w	PTESTW.DIS_MSG0
	dr.w	PTESTW.DIS_MSG0
	dr.w	PTESTR.DIS_MSG0
	dr.w	PTESTR.DIS_MSG0
	dr.w	PTESTR.DIS_MSG0
	dr.w	PTESTR.DIS_MSG0
PTESTR.DIS_MSG0:
	dc.b	'PTESTR     ',0
	dc.w	$4300
PTESTW.DIS_MSG0:
	dc.b	'PTESTW     ',0
	dc.w	$4300
PFLUSHR.DIS_MSG:
	dc.b	'PFLUSHR    ',0
	dc.w	$1600
DIS_lbW00224E:
	dc.w	$001A
	dr.w	DIS_lbW002260
	dr.w	PFLUSHA.DIS_MSG0
	dr.w	PVALID.DIS_MSG
	dr.w	PVALID.DIS_MSG
	dr.w	PFLUSH.DIS_MSG0
	dr.w	PFLUSHS.DIS_MSG
	dr.w	PFLUSH.DIS_MSG0
	dr.w	PFLUSHS.DIS_MSG
DIS_lbW002260:
	dc.w	$0016
	dr.w	PLOADW.DIS_MSG
	dr.w	PLOADW.DIS_MSG
	dr.w	PLOADW.DIS_MSG
	dr.w	PLOADW.DIS_MSG
	dr.w	PLOADR.DIS_MSG
	dr.w	PLOADR.DIS_MSG
	dr.w	PLOADR.DIS_MSG
	dr.w	PLOADR.DIS_MSG
PLOADW.DIS_MSG:
	dc.b	'PLOADW     ',0
	dc.w	$4100
PLOADR.DIS_MSG:
	dc.b	'PLOADR     ',0
	dc.w	$4100
PVALID.DIS_MSG:
	dc.b	'PVALID     ',0
	dc.w	$4000
PFLUSHA.DIS_MSG0:
	dc.b	'PFLUSHA    ',0
	dc.w	$4200
PFLUSH.DIS_MSG0:
	dc.b	'PFLUSH     ',0
	dc.w	$3F00
PFLUSHS.DIS_MSG:
	dc.b	'PFLUSHS    ',0
	dc.w	$3F00
DIS_lbW0022C6:
	dc.w	$001E
	dr.w	DIS_lbW002348
	dr.w	DIS_lbW0024D0
	dr.w	DIS_lbW00255C
	dr.w	DIS_lbW0025E8
	dr.w	DIS_lbW002674
	dr.w	LINE.DIS_MSG
	dr.w	DIS_lbW002700
	dr.w	LINE.DIS_MSG
	dr.w	DIS_lbW00278C
	dr.w	DIS_lbW002818
	dr.w	DIS_lbW0028A4
	dr.w	FMOVECRX.DIS_MSG
	dr.w	DIS_lbW002930
	dr.w	DIS_lbW0029BC
	dr.w	DIS_lbW002A48
	dr.w	DIS_lbW002AD4
	dr.w	DIS_lbW002B60
	dr.w	DIS_lbW002BEC
	dr.w	DIS_lbW002C78
	dr.w	LINE.DIS_MSG
	dr.w	DIS_lbW002D04
	dr.w	DIS_lbW002D90
	dr.w	DIS_lbW002E1C
	dr.w	LINE.DIS_MSG
	dr.w	DIS_lbW002EA8
	dr.w	DIS_lbW002F34
	dr.w	DIS_lbW002FC0
	dr.w	LINE.DIS_MSG
	dr.w	DIS_lbW00304C
	dr.w	DIS_lbW0030D8
	dr.w	DIS_lbW003164
	dr.w	DIS_lbW0031F0
	dr.w	DIS_lbW00327C
	dr.w	DIS_lbW003308
	dr.w	DIS_lbW003394
	dr.w	DIS_lbW003420
	dr.w	DIS_lbW0034AC
	dr.w	DIS_lbW003538
	dr.w	DIS_lbW0035C4
	dr.w	DIS_lbW003650
	dr.w	DIS_lbW0036DC
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
	dr.w	DIS_lbW003768
	dr.w	DIS_lbW003768
	dr.w	DIS_lbW003768
	dr.w	DIS_lbW003768
	dr.w	DIS_lbW003768
	dr.w	DIS_lbW003768
	dr.w	DIS_lbW003768
	dr.w	DIS_lbW003768
	dr.w	DIS_lbW0037F4
	dr.w	FMOVECRX.DIS_MSG
	dr.w	DIS_lbW003880
	dr.w	FMOVECRX.DIS_MSG
	dr.w	FMOVECRX.DIS_MSG
	dr.w	FMOVECRX.DIS_MSG
	dr.w	FMOVECRX.DIS_MSG
	dr.w	FMOVECRX.DIS_MSG
	dr.w	DIS_NM_LINEF		; Extra table, prevents
	dr.w	DIS_NM_LINEF		; Asm-Pro from crashing
	dr.w	DIS_NM_LINEF		; when disassembling these
	dr.w	DIS_NM_LINEF		; opcodes !!!
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
	dr.w	DIS_NM_LINEF
DIS_lbW002348:
	dc.w	$0014
	dr.w	FMOVEX.DIS_MSG
	dr.w	DIS_lbW00239C
	dr.w	DIS_lbW002360
	dr.w	FMOVEMX.DIS_MSG
FMOVEX.DIS_MSG:
	dc.b	'FMOVE.X    ',0
	dc.w	$2600
DIS_lbW002360:
	dc.w	$001A
	dr.w	DIS_lbW00239C
	dr.w	FMOVEL.DIS_MSG
	dr.w	FMOVEL.DIS_MSG
	dr.w	FMOVEML.DIS_MSG
	dr.w	FMOVEL.DIS_MSG
	dr.w	FMOVEML.DIS_MSG
	dr.w	FMOVEML.DIS_MSG
	dr.w	FMOVEML.DIS_MSG
FMOVEL.DIS_MSG:
	dc.b	'FMOVE.L    ',0
	dc.w	$3A00
FMOVEML.DIS_MSG:
	dc.b	'FMOVEM.L   ',0
	dc.w	$3A00
FMOVECRX.DIS_MSG:
	dc.b	'FMOVECR.X  ',0
	dc.w	$3800
DIS_lbW00239C:
	dc.w	$001C
	dr.w	DIS_lbW0023A2
	dr.w	DIS_lbW0023B4
DIS_lbW0023A2:
	dc.w	$001A
	dr.w	FMOVEL.DIS_MSG0
	dr.w	FMOVES.DIS_MSG
	dr.w	FMOVEX.DIS_MSG0
	dr.w	FMOVEP.DIS_MSG
	dr.w	FMOVEW.DIS_MSG
	dr.w	FMOVED.DIS_MSG
	dr.w	FMOVEB.DIS_MSG
	dr.w	FMOVECRX.DIS_MSG
DIS_lbW0023B4:
	dc.w	$001A
	dr.w	FMOVEL.DIS_MSG1
	dr.w	FMOVES.DIS_MSG0
	dr.w	FMOVEX.DIS_MSG1
	dr.w	FMOVEP.DIS_MSG0
	dr.w	FMOVEW.DIS_MSG0
	dr.w	FMOVED.DIS_MSG0
	dr.w	FMOVEB.DIS_MSG0
	dr.w	FMOVEP.DIS_MSG1
FMOVEL.DIS_MSG0:
	dc.b	'FMOVE.L    ',0
	dc.w	$3000
FMOVES.DIS_MSG:
	dc.b	'FMOVE.S    ',0
	dc.w	$3000
FMOVEX.DIS_MSG0:
	dc.b	'FMOVE.X    ',0
	dc.w	$3000

	dc.b	'FMOVE.P    ',0
	dc.w	$3000
FMOVEW.DIS_MSG:
	dc.b	'FMOVE.W    ',0
	dc.w	$3000
FMOVED.DIS_MSG:
	dc.b	'FMOVE.D    ',0
	dc.w	$3000
FMOVEB.DIS_MSG:
	dc.b	'FMOVE.B    ',0
	dc.w	$3000
FMOVEP.DIS_MSG0:
	dc.b	'FMOVE.P    ',0
	dc.w	$3500
FMOVEP.DIS_MSG1:
	dc.b	'FMOVE.P    ',0
	dc.w	$3600
FMOVEP.DIS_MSG:
	dc.b	'FMOVE.P    ',0
	dc.w	$3300
	dc.b	'FMOVE.P    ',0
	dc.w	$3400
FMOVEL.DIS_MSG1:
	dc.b	'FMOVE.L    ',0
	dc.w	$3100
FMOVES.DIS_MSG0:
	dc.b	'FMOVE.S    ',0
	dc.w	$3100
FMOVEX.DIS_MSG1:
	dc.b	'FMOVE.X    ',0
	dc.w	$3100
	dc.b	'FMOVE.P    ',0
	dc.w	$3100
FMOVEW.DIS_MSG0:
	dc.b	'FMOVE.W    ',0
	dc.w	$3100
FMOVED.DIS_MSG0:
	dc.b	'FMOVE.D    ',0
	dc.w	$3100
FMOVEB.DIS_MSG0:
	dc.b	'FMOVE.B    ',0
	dc.w	$3100
FMOVEMX.DIS_MSG:
	dc.b	'FMOVEM.X   ',0
	dc.w	$3900
DIS_lbW0024D0:
	dc.w	$0014
	dr.w	FINTX.DIS_MSG
	dr.w	DIS_lbW0024DA
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
DIS_lbW0024DA:
	dc.w	$001A
	dr.w	FINTL.DIS_MSG
	dr.w	FINTS.DIS_MSG
	dr.w	FINTX.DIS_MSG0
	dr.w	FINTP.DIS_MSG
	dr.w	FINTW.DIS_MSG
	dr.w	FINTD.DIS_MSG
	dr.w	FINTB.DIS_MSG
	dr.w	FMOVECRX.DIS_MSG
FINTX.DIS_MSG:
	dc.b	'FINT.X     ',0
	dc.w	$2600
FINTL.DIS_MSG:
	dc.b	'FINT.L     ',0
	dc.w	$2600
FINTS.DIS_MSG:
	dc.b	'FINT.S     ',0
	dc.w	$2600
FINTX.DIS_MSG0:
	dc.b	'FINT.X     ',0
	dc.w	$2600
FINTP.DIS_MSG:
	dc.b	'FINT.P     ',0
	dc.w	$2600
FINTW.DIS_MSG:
	dc.b	'FINT.W     ',0
	dc.w	$2600
FINTD.DIS_MSG:
	dc.b	'FINT.D     ',0
	dc.w	$2600
FINTB.DIS_MSG:
	dc.b	'FINT.B     ',0
	dc.w	$2600
DIS_lbW00255C:
	dc.w	$0014
	dr.w	FSINHX.DIS_MSG
	dr.w	DIS_lbW002566
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
DIS_lbW002566:
	dc.w	$001A
	dr.w	FSINHL.DIS_MSG
	dr.w	FSINHS.DIS_MSG
	dr.w	FSINHX.DIS_MSG0
	dr.w	FSINHP.DIS_MSG
	dr.w	FSINHW.DIS_MSG
	dr.w	FSINHD.DIS_MSG
	dr.w	FSINHB.DIS_MSG
	dr.w	FMOVECRX.DIS_MSG
FSINHX.DIS_MSG:
	dc.b	'FSINH.X    ',0
	dc.w	$2600
FSINHL.DIS_MSG:
	dc.b	'FSINH.L    ',0
	dc.w	$2600
FSINHS.DIS_MSG:
	dc.b	'FSINH.S    ',0
	dc.w	$2600
FSINHX.DIS_MSG0:
	dc.b	'FSINH.X    ',0
	dc.w	$2600
FSINHP.DIS_MSG:
	dc.b	'FSINH.P    ',0
	dc.w	$2600
FSINHW.DIS_MSG:
	dc.b	'FSINH.W    ',0
	dc.w	$2600
FSINHD.DIS_MSG:
	dc.b	'FSINH.D    ',0
	dc.w	$2600
FSINHB.DIS_MSG:
	dc.b	'FSINH.B    ',0
	dc.w	$2600
DIS_lbW0025E8:
	dc.w	$0014
	dr.w	FINTRZX.DIS_MSG
	dr.w	DIS_lbW0025F2
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
DIS_lbW0025F2:
	dc.w	$001A
	dr.w	FINTRZL.DIS_MSG
	dr.w	FINTRZS.DIS_MSG
	dr.w	FINTRZX.DIS_MSG0
	dr.w	FINTRZP.DIS_MSG
	dr.w	FINTRZW.DIS_MSG
	dr.w	FINTRZD.DIS_MSG
	dr.w	FINTRZB.DIS_MSG
	dr.w	FMOVECRX.DIS_MSG
FINTRZX.DIS_MSG:
	dc.b	'FINTRZ.X   ',0
	dc.w	$2600
FINTRZL.DIS_MSG:
	dc.b	'FINTRZ.L   ',0
	dc.w	$2600
FINTRZS.DIS_MSG:
	dc.b	'FINTRZ.S   ',0
	dc.w	$2600
FINTRZX.DIS_MSG0:
	dc.b	'FINTRZ.X   ',0
	dc.w	$2600
FINTRZP.DIS_MSG:
	dc.b	'FINTRZ.P   ',0
	dc.w	$2600
FINTRZW.DIS_MSG:
	dc.b	'FINTRZ.W   ',0
	dc.w	$2600
FINTRZD.DIS_MSG:
	dc.b	'FINTRZ.D   ',0
	dc.w	$2600
FINTRZB.DIS_MSG:
	dc.b	'FINTRZ.B   ',0
	dc.w	$2600
DIS_lbW002674:
	dc.w	$0014
	dr.w	FSQRTX.DIS_MSG
	dr.w	DIS_lbW00267E
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
DIS_lbW00267E:
	dc.w	$001A
	dr.w	FSQRTL.DIS_MSG
	dr.w	FSQRTS.DIS_MSG
	dr.w	FSQRTX.DIS_MSG0
	dr.w	FSQRTP.DIS_MSG
	dr.w	FSQRTW.DIS_MSG
	dr.w	FSQRTD.DIS_MSG
	dr.w	FSQRTB.DIS_MSG
	dr.w	FMOVECRX.DIS_MSG
FSQRTX.DIS_MSG:
	dc.b	'FSQRT.X    ',0
	dc.w	$2600
FSQRTL.DIS_MSG:
	dc.b	'FSQRT.L    ',0
	dc.w	$2600
FSQRTS.DIS_MSG:
	dc.b	'FSQRT.S    ',0
	dc.w	$2600
FSQRTX.DIS_MSG0:
	dc.b	'FSQRT.X    ',0
	dc.w	$2600
FSQRTP.DIS_MSG:
	dc.b	'FSQRT.P    ',0
	dc.w	$2600
FSQRTW.DIS_MSG:
	dc.b	'FSQRT.W    ',0
	dc.w	$2600
FSQRTD.DIS_MSG:
	dc.b	'FSQRT.D    ',0
	dc.w	$2600
FSQRTB.DIS_MSG:
	dc.b	'FSQRT.B    ',0
	dc.w	$2600
DIS_lbW002700:
	dc.w	$0014
	dr.w	FLOGNP1X.DIS_MSG
	dr.w	DIS_lbW00270A
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
DIS_lbW00270A:
	dc.w	$001A
	dr.w	FLOGNP1L.DIS_MSG
	dr.w	FLOGNP1S.DIS_MSG
	dr.w	FLOGNP1X.DIS_MSG0
	dr.w	FLOGNP1P.DIS_MSG
	dr.w	FLOGNP1W.DIS_MSG
	dr.w	FLOGNP1D.DIS_MSG
	dr.w	FLOGNP1B.DIS_MSG
	dr.w	FMOVECRX.DIS_MSG
FLOGNP1X.DIS_MSG:
	dc.b	'FLOGNP1.X  ',0
	dc.w	$2600
FLOGNP1L.DIS_MSG:
	dc.b	'FLOGNP1.L  ',0
	dc.w	$2600
FLOGNP1S.DIS_MSG:
	dc.b	'FLOGNP1.S  ',0
	dc.w	$2600
FLOGNP1X.DIS_MSG0:
	dc.b	'FLOGNP1.X  ',0
	dc.w	$2600
FLOGNP1P.DIS_MSG:
	dc.b	'FLOGNP1.P  ',0
	dc.w	$2600
FLOGNP1W.DIS_MSG:
	dc.b	'FLOGNP1.W  ',0
	dc.w	$2600
FLOGNP1D.DIS_MSG:
	dc.b	'FLOGNP1.D  ',0
	dc.w	$2600
FLOGNP1B.DIS_MSG:
	dc.b	'FLOGNP1.B  ',0
	dc.w	$2600
DIS_lbW00278C:
	dc.w	$0014
	dr.w	FETOXM1X.DIS_MSG
	dr.w	DIS_lbW002796
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
DIS_lbW002796:
	dc.w	$001A
	dr.w	FETOXM1L.DIS_MSG
	dr.w	FETOXM1S.DIS_MSG
	dr.w	FETOXM1X.DIS_MSG0
	dr.w	FETOXM1P.DIS_MSG
	dr.w	FETOXM1W.DIS_MSG
	dr.w	FETOXM1D.DIS_MSG
	dr.w	FETOXM1B.DIS_MSG
	dr.w	FMOVECRX.DIS_MSG
FETOXM1X.DIS_MSG:
	dc.b	'FETOXM1.X  ',0
	dc.w	$2600
FETOXM1L.DIS_MSG:
	dc.b	'FETOXM1.L  ',0
	dc.w	$2600
FETOXM1S.DIS_MSG:
	dc.b	'FETOXM1.S  ',0
	dc.w	$2600
FETOXM1X.DIS_MSG0:
	dc.b	'FETOXM1.X  ',0
	dc.w	$2600
FETOXM1P.DIS_MSG:
	dc.b	'FETOXM1.P  ',0
	dc.w	$2600
FETOXM1W.DIS_MSG:
	dc.b	'FETOXM1.W  ',0
	dc.w	$2600
FETOXM1D.DIS_MSG:
	dc.b	'FETOXM1.D  ',0
	dc.w	$2600
FETOXM1B.DIS_MSG:
	dc.b	'FETOXM1.B  ',0
	dc.w	$2600
DIS_lbW002818:
	dc.w	$0014
	dr.w	FTANHX.DIS_MSG
	dr.w	DIS_lbW002822
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
DIS_lbW002822:
	dc.w	$001A
	dr.w	FTANHL.DIS_MSG
	dr.w	FTANHS.DIS_MSG
	dr.w	FTANHX.DIS_MSG0
	dr.w	FTANHP.DIS_MSG
	dr.w	FTANHW.DIS_MSG
	dr.w	FTANHD.DIS_MSG
	dr.w	FTANHB.DIS_MSG
	dr.w	FMOVECRX.DIS_MSG
FTANHX.DIS_MSG:
	dc.b	'FTANH.X    ',0
	dc.w	$2600
FTANHL.DIS_MSG:
	dc.b	'FTANH.L    ',0
	dc.w	$2600
FTANHS.DIS_MSG:
	dc.b	'FTANH.S    ',0
	dc.w	$2600
FTANHX.DIS_MSG0:
	dc.b	'FTANH.X    ',0
	dc.w	$2600
FTANHP.DIS_MSG:
	dc.b	'FTANH.P    ',0
	dc.w	$2600
FTANHW.DIS_MSG:
	dc.b	'FTANH.W    ',0
	dc.w	$2600
FTANHD.DIS_MSG:
	dc.b	'FTANH.D    ',0
	dc.w	$2600
FTANHB.DIS_MSG:
	dc.b	'FTANH.B    ',0
	dc.w	$2600
DIS_lbW0028A4:
	dc.w	$0014
	dr.w	FATANX.DIS_MSG
	dr.w	DIS_lbW0028AE
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
DIS_lbW0028AE:
	dc.w	$001A
	dr.w	FATANL.DIS_MSG
	dr.w	FATANS.DIS_MSG
	dr.w	FATANX.DIS_MSG0
	dr.w	FATANP.DIS_MSG
	dr.w	FATANW.DIS_MSG
	dr.w	FATAND.DIS_MSG
	dr.w	FATANB.DIS_MSG
	dr.w	FMOVECRX.DIS_MSG
FATANX.DIS_MSG:
	dc.b	'FATAN.X    ',0
	dc.w	$2600
FATANL.DIS_MSG:
	dc.b	'FATAN.L    ',0
	dc.w	$2600
FATANS.DIS_MSG:
	dc.b	'FATAN.S    ',0
	dc.w	$2600
FATANX.DIS_MSG0:
	dc.b	'FATAN.X    ',0
	dc.w	$2600
FATANP.DIS_MSG:
	dc.b	'FATAN.P    ',0
	dc.w	$2600
FATANW.DIS_MSG:
	dc.b	'FATAN.W    ',0
	dc.w	$2600
FATAND.DIS_MSG:
	dc.b	'FATAN.D    ',0
	dc.w	$2600
FATANB.DIS_MSG:
	dc.b	'FATAN.B    ',0
	dc.w	$2600
DIS_lbW002930:
	dc.w	$0014
	dr.w	FASINX.DIS_MSG
	dr.w	DIS_lbW00293A
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
DIS_lbW00293A:
	dc.w	$001A
	dr.w	FASINL.DIS_MSG
	dr.w	FASINS.DIS_MSG
	dr.w	FASINX.DIS_MSG0
	dr.w	FASINP.DIS_MSG
	dr.w	FASINW.DIS_MSG
	dr.w	FASIND.DIS_MSG
	dr.w	FASINB.DIS_MSG
	dr.w	FMOVECRX.DIS_MSG
FASINX.DIS_MSG:
	dc.b	'FASIN.X    ',0
	dc.w	$2600
FASINL.DIS_MSG:
	dc.b	'FASIN.L    ',0
	dc.w	$2600
FASINS.DIS_MSG:
	dc.b	'FASIN.S    ',0
	dc.w	$2600
FASINX.DIS_MSG0:
	dc.b	'FASIN.X    ',0
	dc.w	$2600
FASINP.DIS_MSG:
	dc.b	'FASIN.P    ',0
	dc.w	$2600
FASINW.DIS_MSG:
	dc.b	'FASIN.W    ',0
	dc.w	$2600
FASIND.DIS_MSG:
	dc.b	'FASIN.D    ',0
	dc.w	$2600
FASINB.DIS_MSG:
	dc.b	'FASIN.B    ',0
	dc.w	$2600
DIS_lbW0029BC:
	dc.w	$0014
	dr.w	FATANHX.DIS_MSG
	dr.w	DIS_lbW0029C6
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
DIS_lbW0029C6:
	dc.w	$001A
	dr.w	FATANHL.DIS_MSG
	dr.w	FATANHS.DIS_MSG
	dr.w	FATANHX.DIS_MSG0
	dr.w	FATANHP.DIS_MSG
	dr.w	FATANHW.DIS_MSG
	dr.w	FATANHD.DIS_MSG
	dr.w	FATANHB.DIS_MSG
	dr.w	FMOVECRX.DIS_MSG
FATANHX.DIS_MSG:
	dc.b	'FATANH.X   ',0
	dc.w	$2600
FATANHL.DIS_MSG:
	dc.b	'FATANH.L   ',0
	dc.w	$2600
FATANHS.DIS_MSG:
	dc.b	'FATANH.S   ',0
	dc.w	$2600
FATANHX.DIS_MSG0:
	dc.b	'FATANH.X   ',0
	dc.w	$2600
FATANHP.DIS_MSG:
	dc.b	'FATANH.P   ',0
	dc.w	$2600
FATANHW.DIS_MSG:
	dc.b	'FATANH.W   ',0
	dc.w	$2600
FATANHD.DIS_MSG:
	dc.b	'FATANH.D   ',0
	dc.w	$2600
FATANHB.DIS_MSG:
	dc.b	'FATANH.B   ',0
	dc.w	$2600
DIS_lbW002A48:
	dc.w	$0014
	dr.w	FSINX.DIS_MSG
	dr.w	DIS_lbW002A52
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
DIS_lbW002A52:
	dc.w	$001A
	dr.w	FSINL.DIS_MSG
	dr.w	FSINS.DIS_MSG
	dr.w	FSINX.DIS_MSG0
	dr.w	FSINP.DIS_MSG
	dr.w	FSINW.DIS_MSG
	dr.w	FSIND.DIS_MSG
	dr.w	FSINB.DIS_MSG
	dr.w	FMOVECRX.DIS_MSG
FSINX.DIS_MSG:
	dc.b	'FSIN.X     ',0
	dc.w	$2600
FSINL.DIS_MSG:
	dc.b	'FSIN.L     ',0
	dc.w	$2600
FSINS.DIS_MSG:
	dc.b	'FSIN.S     ',0
	dc.w	$2600
FSINX.DIS_MSG0:
	dc.b	'FSIN.X     ',0
	dc.w	$2600
FSINP.DIS_MSG:
	dc.b	'FSIN.P     ',0
	dc.w	$2600
FSINW.DIS_MSG:
	dc.b	'FSIN.W     ',0
	dc.w	$2600
FSIND.DIS_MSG:
	dc.b	'FSIN.D     ',0
	dc.w	$2600
FSINB.DIS_MSG:
	dc.b	'FSIN.B     ',0
	dc.w	$2600
DIS_lbW002AD4:
	dc.w	$0014
	dr.w	FTANX.DIS_MSG
	dr.w	DIS_lbW002ADE
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
DIS_lbW002ADE:
	dc.w	$001A
	dr.w	FTANL.DIS_MSG
	dr.w	FTANS.DIS_MSG
	dr.w	FTANX.DIS_MSG0
	dr.w	FTANP.DIS_MSG
	dr.w	FTANW.DIS_MSG
	dr.w	FTAND.DIS_MSG
	dr.w	FTANB.DIS_MSG
	dr.w	FMOVECRX.DIS_MSG
FTANX.DIS_MSG:
	dc.b	'FTAN.X     ',0
	dc.w	$2600
FTANL.DIS_MSG:
	dc.b	'FTAN.L     ',0
	dc.w	$2600
FTANS.DIS_MSG:
	dc.b	'FTAN.S     ',0
	dc.w	$2600
FTANX.DIS_MSG0:
	dc.b	'FTAN.X     ',0
	dc.w	$2600
FTANP.DIS_MSG:
	dc.b	'FTAN.P     ',0
	dc.w	$2600
FTANW.DIS_MSG:
	dc.b	'FTAN.W     ',0
	dc.w	$2600
FTAND.DIS_MSG:
	dc.b	'FTAN.D     ',0
	dc.w	$2600
FTANB.DIS_MSG:
	dc.b	'FTAN.B     ',0
	dc.w	$2600
DIS_lbW002B60:
	dc.w	$0014
	dr.w	FETOXX.DIS_MSG
	dr.w	DIS_lbW002B6A
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
DIS_lbW002B6A:
	dc.w	$001A
	dr.w	FETOXL.DIS_MSG
	dr.w	FETOXS.DIS_MSG
	dr.w	FETOXX.DIS_MSG0
	dr.w	FETOXP.DIS_MSG
	dr.w	FETOXW.DIS_MSG
	dr.w	FETOXD.DIS_MSG
	dr.w	FETOXB.DIS_MSG
	dr.w	FMOVECRX.DIS_MSG
FETOXX.DIS_MSG:
	dc.b	'FETOX.X    ',0
	dc.w	$2600
FETOXL.DIS_MSG:
	dc.b	'FETOX.L    ',0
	dc.w	$2600
FETOXS.DIS_MSG:
	dc.b	'FETOX.S    ',0
	dc.w	$2600
FETOXX.DIS_MSG0:
	dc.b	'FETOX.X    ',0
	dc.w	$2600
FETOXP.DIS_MSG:
	dc.b	'FETOX.P    ',0
	dc.w	$2600
FETOXW.DIS_MSG:
	dc.b	'FETOX.W    ',0
	dc.w	$2600
FETOXD.DIS_MSG:
	dc.b	'FETOX.D    ',0
	dc.w	$2600
FETOXB.DIS_MSG:
	dc.b	'FETOX.B    ',0
	dc.w	$2600
DIS_lbW002BEC:
	dc.w	$0014
	dr.w	FTWOTOXX.DIS_MSG
	dr.w	DIS_lbW002BF6
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
DIS_lbW002BF6:
	dc.w	$001A
	dr.w	FTWOTOXL.DIS_MSG
	dr.w	FTWOTOXS.DIS_MSG
	dr.w	FTWOTOXX.DIS_MSG0
	dr.w	FTWOTOXP.DIS_MSG
	dr.w	FTWOTOXW.DIS_MSG
	dr.w	FTWOTOXD.DIS_MSG
	dr.w	FTWOTOXB.DIS_MSG
	dr.w	FMOVECRX.DIS_MSG
FTWOTOXX.DIS_MSG:
	dc.b	'FTWOTOX.X  ',0
	dc.w	$2600
FTWOTOXL.DIS_MSG:
	dc.b	'FTWOTOX.L  ',0
	dc.w	$2600
FTWOTOXS.DIS_MSG:
	dc.b	'FTWOTOX.S  ',0
	dc.w	$2600
FTWOTOXX.DIS_MSG0:
	dc.b	'FTWOTOX.X  ',0
	dc.w	$2600
FTWOTOXP.DIS_MSG:
	dc.b	'FTWOTOX.P  ',0
	dc.w	$2600
FTWOTOXW.DIS_MSG:
	dc.b	'FTWOTOX.W  ',0
	dc.w	$2600
FTWOTOXD.DIS_MSG:
	dc.b	'FTWOTOX.D  ',0
	dc.w	$2600
FTWOTOXB.DIS_MSG:
	dc.b	'FTWOTOX.B  ',0
	dc.w	$2600
DIS_lbW002C78:
	dc.w	$0014
	dr.w	FTENTOXX.DIS_MSG
	dr.w	DIS_lbW002C82
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
DIS_lbW002C82:
	dc.w	$001A
	dr.w	FTENTOXL.DIS_MSG
	dr.w	FTENTOXS.DIS_MSG
	dr.w	FTENTOXX.DIS_MSG0
	dr.w	FTENTOXP.DIS_MSG
	dr.w	FTENTOXW.DIS_MSG
	dr.w	FTENTOXD.DIS_MSG
	dr.w	FTENTOXB.DIS_MSG
	dr.w	FMOVECRX.DIS_MSG
FTENTOXX.DIS_MSG:
	dc.b	'FTENTOX.X  ',0
	dc.w	$2600
FTENTOXL.DIS_MSG:
	dc.b	'FTENTOX.L  ',0
	dc.w	$2600
FTENTOXS.DIS_MSG:
	dc.b	'FTENTOX.S  ',0
	dc.w	$2600
FTENTOXX.DIS_MSG0:
	dc.b	'FTENTOX.X  ',0
	dc.w	$2600
FTENTOXP.DIS_MSG:
	dc.b	'FTENTOX.P  ',0
	dc.w	$2600
FTENTOXW.DIS_MSG:
	dc.b	'FTENTOX.W  ',0
	dc.w	$2600
FTENTOXD.DIS_MSG:
	dc.b	'FTENTOX.D  ',0
	dc.w	$2600
FTENTOXB.DIS_MSG:
	dc.b	'FTENTOX.B  ',0
	dc.w	$2600
DIS_lbW002D04:
	dc.w	$0014
	dr.w	FLOGNX.DIS_MSG
	dr.w	DIS_lbW002D0E
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
DIS_lbW002D0E:
	dc.w	$001A
	dr.w	FLOGNL.DIS_MSG
	dr.w	FLOGNS.DIS_MSG
	dr.w	FLOGNX.DIS_MSG0
	dr.w	FLOGNP.DIS_MSG
	dr.w	FLOGNW.DIS_MSG
	dr.w	FLOGND.DIS_MSG
	dr.w	FLOGNB.DIS_MSG
	dr.w	FMOVECRX.DIS_MSG
FLOGNX.DIS_MSG:
	dc.b	'FLOGN.X    ',0
	dc.w	$2600
FLOGNL.DIS_MSG:
	dc.b	'FLOGN.L    ',0
	dc.w	$2600
FLOGNS.DIS_MSG:
	dc.b	'FLOGN.S    ',0
	dc.w	$2600
FLOGNX.DIS_MSG0:
	dc.b	'FLOGN.X    ',0
	dc.w	$2600
FLOGNP.DIS_MSG:
	dc.b	'FLOGN.P    ',0
	dc.w	$2600
FLOGNW.DIS_MSG:
	dc.b	'FLOGN.W    ',0
	dc.w	$2600
FLOGND.DIS_MSG:
	dc.b	'FLOGN.D    ',0
	dc.w	$2600
FLOGNB.DIS_MSG:
	dc.b	'FLOGN.B    ',0
	dc.w	$2600
DIS_lbW002D90:
	dc.w	$0014
	dr.w	FLOG10X.DIS_MSG
	dr.w	DIS_lbW002D9A
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
DIS_lbW002D9A:
	dc.w	$001A
	dr.w	FLOG10L.DIS_MSG
	dr.w	FLOG10S.DIS_MSG
	dr.w	FLOG10X.DIS_MSG0
	dr.w	FLOG10P.DIS_MSG
	dr.w	FLOG10W.DIS_MSG
	dr.w	FLOG10D.DIS_MSG
	dr.w	FLOG10B.DIS_MSG
	dr.w	FMOVECRX.DIS_MSG
FLOG10X.DIS_MSG:
	dc.b	'FLOG10.X   ',0
	dc.w	$2600
FLOG10L.DIS_MSG:
	dc.b	'FLOG10.L   ',0
	dc.w	$2600
FLOG10S.DIS_MSG:
	dc.b	'FLOG10.S   ',0
	dc.w	$2600
FLOG10X.DIS_MSG0:
	dc.b	'FLOG10.X   ',0
	dc.w	$2600
FLOG10P.DIS_MSG:
	dc.b	'FLOG10.P   ',0
	dc.w	$2600
FLOG10W.DIS_MSG:
	dc.b	'FLOG10.W   ',0
	dc.w	$2600
FLOG10D.DIS_MSG:
	dc.b	'FLOG10.D   ',0
	dc.w	$2600
FLOG10B.DIS_MSG:
	dc.b	'FLOG10.B   ',0
	dc.w	$2600
DIS_lbW002E1C:
	dc.w	$0014
	dr.w	FLOG2X.DIS_MSG
	dr.w	DIS_lbW002E26
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
DIS_lbW002E26:
	dc.w	$001A
	dr.w	FLOG2L.DIS_MSG
	dr.w	FLOG2S.DIS_MSG
	dr.w	FLOG2X.DIS_MSG0
	dr.w	FLOG2P.DIS_MSG
	dr.w	FLOG2W.DIS_MSG
	dr.w	FLOG2D.DIS_MSG
	dr.w	FLOG2B.DIS_MSG
	dr.w	FMOVECRX.DIS_MSG
FLOG2X.DIS_MSG:
	dc.b	'FLOG2.X    ',0
	dc.w	$2600
FLOG2L.DIS_MSG:
	dc.b	'FLOG2.L    ',0
	dc.w	$2600
FLOG2S.DIS_MSG:
	dc.b	'FLOG2.S    ',0
	dc.w	$2600
FLOG2X.DIS_MSG0:
	dc.b	'FLOG2.X    ',0
	dc.w	$2600
FLOG2P.DIS_MSG:
	dc.b	'FLOG2.P    ',0
	dc.w	$2600
FLOG2W.DIS_MSG:
	dc.b	'FLOG2.W    ',0
	dc.w	$2600
FLOG2D.DIS_MSG:
	dc.b	'FLOG2.D    ',0
	dc.w	$2600
FLOG2B.DIS_MSG:
	dc.b	'FLOG2.B    ',0
	dc.w	$2600
DIS_lbW002EA8:
	dc.w	$0014
	dr.w	FABSX.DIS_MSG
	dr.w	DIS_lbW002EB2
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
DIS_lbW002EB2:
	dc.w	$001A
	dr.w	FABSL.DIS_MSG
	dr.w	FABSS.DIS_MSG
	dr.w	FABSX.DIS_MSG0
	dr.w	FABSP.DIS_MSG
	dr.w	FABSW.DIS_MSG
	dr.w	FABSD.DIS_MSG
	dr.w	FABSB.DIS_MSG
	dr.w	FMOVECRX.DIS_MSG
FABSX.DIS_MSG:
	dc.b	'FABS.X     ',0
	dc.w	$2600
FABSL.DIS_MSG:
	dc.b	'FABS.L     ',0
	dc.w	$2600
FABSS.DIS_MSG:
	dc.b	'FABS.S     ',0
	dc.w	$2600
FABSX.DIS_MSG0:
	dc.b	'FABS.X     ',0
	dc.w	$2600
FABSP.DIS_MSG:
	dc.b	'FABS.P     ',0
	dc.w	$2600
FABSW.DIS_MSG:
	dc.b	'FABS.W     ',0
	dc.w	$2600
FABSD.DIS_MSG:
	dc.b	'FABS.D     ',0
	dc.w	$2600
FABSB.DIS_MSG:
	dc.b	'FABS.B     ',0
	dc.w	$2600
DIS_lbW002F34:
	dc.w	$0014
	dr.w	FCOSHX.DIS_MSG
	dr.w	DIS_lbW002F3E
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
DIS_lbW002F3E:
	dc.w	$001A
	dr.w	FCOSHL.DIS_MSG
	dr.w	FCOSHS.DIS_MSG
	dr.w	FCOSHX.DIS_MSG0
	dr.w	FCOSHP.DIS_MSG
	dr.w	FCOSHW.DIS_MSG
	dr.w	FCOSHD.DIS_MSG
	dr.w	FCOSHB.DIS_MSG
	dr.w	FMOVECRX.DIS_MSG
FCOSHX.DIS_MSG:
	dc.b	'FCOSH.X    ',0
	dc.w	$2600
FCOSHL.DIS_MSG:
	dc.b	'FCOSH.L    ',0
	dc.w	$2600
FCOSHS.DIS_MSG:
	dc.b	'FCOSH.S    ',0
	dc.w	$2600
FCOSHX.DIS_MSG0:
	dc.b	'FCOSH.X    ',0
	dc.w	$2600
FCOSHP.DIS_MSG:
	dc.b	'FCOSH.P    ',0
	dc.w	$2600
FCOSHW.DIS_MSG:
	dc.b	'FCOSH.W    ',0
	dc.w	$2600
FCOSHD.DIS_MSG:
	dc.b	'FCOSH.D    ',0
	dc.w	$2600
FCOSHB.DIS_MSG:
	dc.b	'FCOSH.B    ',0
	dc.w	$2600
DIS_lbW002FC0:
	dc.w	$0014
	dr.w	FNEGX.DIS_MSG
	dr.w	DIS_lbW002FCA
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
DIS_lbW002FCA:
	dc.w	$001A
	dr.w	FNEGL.DIS_MSG
	dr.w	FNEGS.DIS_MSG
	dr.w	FNEGX.DIS_MSG0
	dr.w	FNEGP.DIS_MSG
	dr.w	FNEGW.DIS_MSG
	dr.w	FNEGD.DIS_MSG
	dr.w	FNEGB.DIS_MSG
	dr.w	FMOVECRX.DIS_MSG
FNEGX.DIS_MSG:
	dc.b	'FNEG.X     ',0
	dc.w	$2600
FNEGL.DIS_MSG:
	dc.b	'FNEG.L     ',0
	dc.w	$2600
FNEGS.DIS_MSG:
	dc.b	'FNEG.S     ',0
	dc.w	$2600
FNEGX.DIS_MSG0:
	dc.b	'FNEG.X     ',0
	dc.w	$2600
FNEGP.DIS_MSG:
	dc.b	'FNEG.P     ',0
	dc.w	$2600
FNEGW.DIS_MSG:
	dc.b	'FNEG.W     ',0
	dc.w	$2600
FNEGD.DIS_MSG:
	dc.b	'FNEG.D     ',0
	dc.w	$2600
FNEGB.DIS_MSG:
	dc.b	'FNEG.B     ',0
	dc.w	$2600
DIS_lbW00304C:
	dc.w	$0014
	dr.w	FACOSX.DIS_MSG
	dr.w	DIS_lbW003056
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
DIS_lbW003056:
	dc.w	$001A
	dr.w	FACOSL.DIS_MSG
	dr.w	FACOSS.DIS_MSG
	dr.w	FACOSX.DIS_MSG0
	dr.w	FACOSP.DIS_MSG
	dr.w	FACOSW.DIS_MSG
	dr.w	FACOSD.DIS_MSG
	dr.w	FACOSB.DIS_MSG
	dr.w	FMOVECRX.DIS_MSG
FACOSX.DIS_MSG:
	dc.b	'FACOS.X    ',0
	dc.w	$2600
FACOSL.DIS_MSG:
	dc.b	'FACOS.L    ',0
	dc.w	$2600
FACOSS.DIS_MSG:
	dc.b	'FACOS.S    ',0
	dc.w	$2600
FACOSX.DIS_MSG0:
	dc.b	'FACOS.X    ',0
	dc.w	$2600
FACOSP.DIS_MSG:
	dc.b	'FACOS.P    ',0
	dc.w	$2600
FACOSW.DIS_MSG:
	dc.b	'FACOS.W    ',0
	dc.w	$2600
FACOSD.DIS_MSG:
	dc.b	'FACOS.D    ',0
	dc.w	$2600
FACOSB.DIS_MSG:
	dc.b	'FACOS.B    ',0
	dc.w	$2600
DIS_lbW0030D8:
	dc.w	$0014
	dr.w	FCOSX.DIS_MSG
	dr.w	DIS_lbW0030E2
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
DIS_lbW0030E2:
	dc.w	$001A
	dr.w	FCOSL.DIS_MSG
	dr.w	FCOSS.DIS_MSG
	dr.w	FCOSX.DIS_MSG0
	dr.w	FCOSP.DIS_MSG
	dr.w	FCOSW.DIS_MSG
	dr.w	FCOSD.DIS_MSG
	dr.w	FCOSB.DIS_MSG
	dr.w	FMOVECRX.DIS_MSG
FCOSX.DIS_MSG:
	dc.b	'FCOS.X     ',0
	dc.w	$2600
FCOSL.DIS_MSG:
	dc.b	'FCOS.L     ',0
	dc.w	$2600
FCOSS.DIS_MSG:
	dc.b	'FCOS.S     ',0
	dc.w	$2600
FCOSX.DIS_MSG0:
	dc.b	'FCOS.X     ',0
	dc.w	$2600
FCOSP.DIS_MSG:
	dc.b	'FCOS.P     ',0
	dc.w	$2600
FCOSW.DIS_MSG:
	dc.b	'FCOS.W     ',0
	dc.w	$2600
FCOSD.DIS_MSG:
	dc.b	'FCOS.D     ',0
	dc.w	$2600
FCOSB.DIS_MSG:
	dc.b	'FCOS.B     ',0
	dc.w	$2600
DIS_lbW003164:
	dc.w	$0014
	dr.w	FGETEXPX.DIS_MSG
	dr.w	DIS_lbW00316E
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
DIS_lbW00316E:
	dc.w	$001A
	dr.w	FGETEXPL.DIS_MSG
	dr.w	FGETEXPS.DIS_MSG
	dr.w	FGETEXPX.DIS_MSG0
	dr.w	FGETEXPP.DIS_MSG
	dr.w	FGETEXPW.DIS_MSG
	dr.w	FGETEXPD.DIS_MSG
	dr.w	FGETEXPB.DIS_MSG
	dr.w	FMOVECRX.DIS_MSG
FGETEXPX.DIS_MSG:
	dc.b	'FGETEXP.X  ',0
	dc.w	$2600
FGETEXPL.DIS_MSG:
	dc.b	'FGETEXP.L  ',0
	dc.w	$2600
FGETEXPS.DIS_MSG:
	dc.b	'FGETEXP.S  ',0
	dc.w	$2600
FGETEXPX.DIS_MSG0:
	dc.b	'FGETEXP.X  ',0
	dc.w	$2600
FGETEXPP.DIS_MSG:
	dc.b	'FGETEXP.P  ',0
	dc.w	$2600
FGETEXPW.DIS_MSG:
	dc.b	'FGETEXP.W  ',0
	dc.w	$2600
FGETEXPD.DIS_MSG:
	dc.b	'FGETEXP.D  ',0
	dc.w	$2600
FGETEXPB.DIS_MSG:
	dc.b	'FGETEXP.B  ',0
	dc.w	$2600
DIS_lbW0031F0:
	dc.w	$0014
	dr.w	FGETMANX.DIS_MSG
	dr.w	DIS_lbW0031FA
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
DIS_lbW0031FA:
	dc.w	$001A
	dr.w	FGETMANL.DIS_MSG
	dr.w	FGETMANS.DIS_MSG
	dr.w	FGETMANX.DIS_MSG0
	dr.w	FGETMANP.DIS_MSG
	dr.w	FGETMANW.DIS_MSG
	dr.w	FGETMAND.DIS_MSG
	dr.w	FGETMANB.DIS_MSG
	dr.w	FMOVECRX.DIS_MSG
FGETMANX.DIS_MSG:
	dc.b	'FGETMAN.X  ',0
	dc.w	$2600
FGETMANL.DIS_MSG:
	dc.b	'FGETMAN.L  ',0
	dc.w	$2600
FGETMANS.DIS_MSG:
	dc.b	'FGETMAN.S  ',0
	dc.w	$2600
FGETMANX.DIS_MSG0:
	dc.b	'FGETMAN.X  ',0
	dc.w	$2600
FGETMANP.DIS_MSG:
	dc.b	'FGETMAN.P  ',0
	dc.w	$2600
FGETMANW.DIS_MSG:
	dc.b	'FGETMAN.W  ',0
	dc.w	$2600
FGETMAND.DIS_MSG:
	dc.b	'FGETMAN.D  ',0
	dc.w	$2600
FGETMANB.DIS_MSG:
	dc.b	'FGETMAN.B  ',0
	dc.w	$2600
DIS_lbW00327C:
	dc.w	$0014
	dr.w	FDIVX.DIS_MSG
	dr.w	DIS_lbW003286
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
DIS_lbW003286:
	dc.w	$001A
	dr.w	FDIVL.DIS_MSG
	dr.w	FDIVS.DIS_MSG
	dr.w	FDIVX.DIS_MSG0
	dr.w	FDIVP.DIS_MSG
	dr.w	FDIVW.DIS_MSG
	dr.w	FDIVD.DIS_MSG
	dr.w	FDIVB.DIS_MSG
	dr.w	FMOVECRX.DIS_MSG
FDIVX.DIS_MSG:
	dc.b	'FDIV.X     ',0
	dc.w	$2600
FDIVL.DIS_MSG:
	dc.b	'FDIV.L     ',0
	dc.w	$2600
FDIVS.DIS_MSG:
	dc.b	'FDIV.S     ',0
	dc.w	$2600
FDIVX.DIS_MSG0:
	dc.b	'FDIV.X     ',0
	dc.w	$2600
FDIVP.DIS_MSG:
	dc.b	'FDIV.P     ',0
	dc.w	$2600
FDIVW.DIS_MSG:
	dc.b	'FDIV.W     ',0
	dc.w	$2600
FDIVD.DIS_MSG:
	dc.b	'FDIV.D     ',0
	dc.w	$2600
FDIVB.DIS_MSG:
	dc.b	'FDIV.B     ',0
	dc.w	$2600
DIS_lbW003308:
	dc.w	$0014
	dr.w	FMODX.DIS_MSG
	dr.w	DIS_lbW003312
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
DIS_lbW003312:
	dc.w	$001A
	dr.w	FMODL.DIS_MSG
	dr.w	FMODS.DIS_MSG
	dr.w	FMODX.DIS_MSG0
	dr.w	FMODP.DIS_MSG
	dr.w	FMODW.DIS_MSG
	dr.w	FMODD.DIS_MSG
	dr.w	FMODB.DIS_MSG
	dr.w	FMOVECRX.DIS_MSG
FMODX.DIS_MSG:
	dc.b	'FMOD.X     ',0
	dc.w	$2600
FMODL.DIS_MSG:
	dc.b	'FMOD.L     ',0
	dc.w	$2600
FMODS.DIS_MSG:
	dc.b	'FMOD.S     ',0
	dc.w	$2600
FMODX.DIS_MSG0:
	dc.b	'FMOD.X     ',0
	dc.w	$2600
FMODP.DIS_MSG:
	dc.b	'FMOD.P     ',0
	dc.w	$2600
FMODW.DIS_MSG:
	dc.b	'FMOD.W     ',0
	dc.w	$2600
FMODD.DIS_MSG:
	dc.b	'FMOD.D     ',0
	dc.w	$2600
FMODB.DIS_MSG:
	dc.b	'FMOD.B     ',0
	dc.w	$2600
DIS_lbW003394:
	dc.w	$0014
	dr.w	FADDX.DIS_MSG
	dr.w	DIS_lbW00339E
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
DIS_lbW00339E:
	dc.w	$001A
	dr.w	FADDL.DIS_MSG
	dr.w	FADDS.DIS_MSG
	dr.w	FADDX.DIS_MSG0
	dr.w	FADDP.DIS_MSG
	dr.w	FADDW.DIS_MSG
	dr.w	FADDD.DIS_MSG
	dr.w	FADDB.DIS_MSG
	dr.w	FMOVECRX.DIS_MSG
FADDX.DIS_MSG:
	dc.b	'FADD.X     ',0
	dc.w	$2700
FADDL.DIS_MSG:
	dc.b	'FADD.L     ',0
	dc.w	$2700
FADDS.DIS_MSG:
	dc.b	'FADD.S     ',0
	dc.w	$2700
FADDX.DIS_MSG0:
	dc.b	'FADD.X     ',0
	dc.w	$2700
FADDP.DIS_MSG:
	dc.b	'FADD.P     ',0
	dc.w	$2700
FADDW.DIS_MSG:
	dc.b	'FADD.W     ',0
	dc.w	$2700
FADDD.DIS_MSG:
	dc.b	'FADD.D     ',0
	dc.w	$2700
FADDB.DIS_MSG:
	dc.b	'FADD.B     ',0
	dc.w	$2700
DIS_lbW003420:
	dc.w	$0014
	dr.w	FMULX.DIS_MSG
	dr.w	DIS_lbW00342A
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
DIS_lbW00342A:
	dc.w	$001A
	dr.w	FMULL.DIS_MSG
	dr.w	FMULS.DIS_MSG
	dr.w	FMULX.DIS_MSG0
	dr.w	FMULP.DIS_MSG
	dr.w	FMULW.DIS_MSG
	dr.w	FMULD.DIS_MSG
	dr.w	FMULB.DIS_MSG
	dr.w	FMOVECRX.DIS_MSG
FMULX.DIS_MSG:
	dc.b	'FMUL.X     ',0
	dc.w	$2600
FMULL.DIS_MSG:
	dc.b	'FMUL.L     ',0
	dc.w	$2600
FMULS.DIS_MSG:
	dc.b	'FMUL.S     ',0
	dc.w	$2600
FMULX.DIS_MSG0:
	dc.b	'FMUL.X     ',0
	dc.w	$2600
FMULP.DIS_MSG:
	dc.b	'FMUL.P     ',0
	dc.w	$2600
FMULW.DIS_MSG:
	dc.b	'FMUL.W     ',0
	dc.w	$2600
FMULD.DIS_MSG:
	dc.b	'FMUL.D     ',0
	dc.w	$2600
FMULB.DIS_MSG:
	dc.b	'FMUL.B     ',0
	dc.w	$2600
DIS_lbW0034AC:
	dc.w	$0014
	dr.w	FSGLDIVX.DIS_MSG
	dr.w	DIS_lbW0034B6
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
DIS_lbW0034B6:
	dc.w	$001A
	dr.w	FSGLDIVL.DIS_MSG
	dr.w	FSGLDIVS.DIS_MSG
	dr.w	FSGLDIVX.DIS_MSG0
	dr.w	FSGLDIVP.DIS_MSG
	dr.w	FSGLDIVW.DIS_MSG
	dr.w	FSGLDIVD.DIS_MSG
	dr.w	FSGLDIVB.DIS_MSG
	dr.w	FMOVECRX.DIS_MSG
FSGLDIVX.DIS_MSG:
	dc.b	'FSGLDIV.X  ',0
	dc.w	$2600
FSGLDIVL.DIS_MSG:
	dc.b	'FSGLDIV.L  ',0
	dc.w	$2600
FSGLDIVS.DIS_MSG:
	dc.b	'FSGLDIV.S  ',0
	dc.w	$2600
FSGLDIVX.DIS_MSG0:
	dc.b	'FSGLDIV.X  ',0
	dc.w	$2600
FSGLDIVP.DIS_MSG:
	dc.b	'FSGLDIV.P  ',0
	dc.w	$2600
FSGLDIVW.DIS_MSG:
	dc.b	'FSGLDIV.W  ',0
	dc.w	$2600
FSGLDIVD.DIS_MSG:
	dc.b	'FSGLDIV.D  ',0
	dc.w	$2600
FSGLDIVB.DIS_MSG:
	dc.b	'FSGLDIV.B  ',0
	dc.w	$2600
DIS_lbW003538:
	dc.w	$0014
	dr.w	FREMX.DIS_MSG
	dr.w	DIS_lbW003542
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
DIS_lbW003542:
	dc.w	$001A
	dr.w	FREML.DIS_MSG
	dr.w	FREMS.DIS_MSG
	dr.w	FREMX.DIS_MSG0
	dr.w	FREMP.DIS_MSG
	dr.w	FREMW.DIS_MSG
	dr.w	FREMD.DIS_MSG
	dr.w	FREMB.DIS_MSG
	dr.w	FMOVECRX.DIS_MSG
FREMX.DIS_MSG:
	dc.b	'FREM.X     ',0
	dc.w	$2600
FREML.DIS_MSG:
	dc.b	'FREM.L     ',0
	dc.w	$2600
FREMS.DIS_MSG:
	dc.b	'FREM.S     ',0
	dc.w	$2600
FREMX.DIS_MSG0:
	dc.b	'FREM.X     ',0
	dc.w	$2600
FREMP.DIS_MSG:
	dc.b	'FREM.P     ',0
	dc.w	$2600
FREMW.DIS_MSG:
	dc.b	'FREM.W     ',0
	dc.w	$2600
FREMD.DIS_MSG:
	dc.b	'FREM.D     ',0
	dc.w	$2600
FREMB.DIS_MSG:
	dc.b	'FREM.B     ',0
	dc.w	$2600
DIS_lbW0035C4:
	dc.w	$0014
	dr.w	FSCALEX.DIS_MSG
	dr.w	DIS_lbW0035CE
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
DIS_lbW0035CE:
	dc.w	$001A
	dr.w	FSCALEL.DIS_MSG
	dr.w	FSCALES.DIS_MSG
	dr.w	FSCALEX.DIS_MSG0
	dr.w	FSCALEP.DIS_MSG
	dr.w	FSCALEW.DIS_MSG
	dr.w	FSCALED.DIS_MSG
	dr.w	FSCALEB.DIS_MSG
	dr.w	FMOVECRX.DIS_MSG
FSCALEX.DIS_MSG:
	dc.b	'FSCALE.X   ',0
	dc.w	$2600
FSCALEL.DIS_MSG:
	dc.b	'FSCALE.L   ',0
	dc.w	$2600
FSCALES.DIS_MSG:
	dc.b	'FSCALE.S   ',0
	dc.w	$2600
FSCALEX.DIS_MSG0:
	dc.b	'FSCALE.X   ',0
	dc.w	$2600
FSCALEP.DIS_MSG:
	dc.b	'FSCALE.P   ',0
	dc.w	$2600
FSCALEW.DIS_MSG:
	dc.b	'FSCALE.W   ',0
	dc.w	$2600
FSCALED.DIS_MSG:
	dc.b	'FSCALE.D   ',0
	dc.w	$2600
FSCALEB.DIS_MSG:
	dc.b	'FSCALE.B   ',0
	dc.w	$2600
DIS_lbW003650:
	dc.w	$0014
	dr.w	FSGLMULX.DIS_MSG
	dr.w	DIS_lbW00365A
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
DIS_lbW00365A:
	dc.w	$001A
	dr.w	FSGLMULL.DIS_MSG
	dr.w	FSGLMULS.DIS_MSG
	dr.w	FSGLMULX.DIS_MSG0
	dr.w	FSGLMULP.DIS_MSG
	dr.w	FSGLMULW.DIS_MSG
	dr.w	FSGLMULD.DIS_MSG
	dr.w	FSGLMULB.DIS_MSG
	dr.w	FMOVECRX.DIS_MSG
FSGLMULX.DIS_MSG:
	dc.b	'FSGLMUL.X  ',0
	dc.w	$2600
FSGLMULL.DIS_MSG:
	dc.b	'FSGLMUL.L  ',0
	dc.w	$2600
FSGLMULS.DIS_MSG:
	dc.b	'FSGLMUL.S  ',0
	dc.w	$2600
FSGLMULX.DIS_MSG0:
	dc.b	'FSGLMUL.X  ',0
	dc.w	$2600
FSGLMULP.DIS_MSG:
	dc.b	'FSGLMUL.P  ',0
	dc.w	$2600
FSGLMULW.DIS_MSG:
	dc.b	'FSGLMUL.W  ',0
	dc.w	$2600
FSGLMULD.DIS_MSG:
	dc.b	'FSGLMUL.D  ',0
	dc.w	$2600
FSGLMULB.DIS_MSG:
	dc.b	'FSGLMUL.B  ',0
	dc.w	$2600
DIS_lbW0036DC:
	dc.w	$0014
	dr.w	FSUBX.DIS_MSG
	dr.w	DIS_lbW0036E6
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
DIS_lbW0036E6:
	dc.w	$001A
	dr.w	FSUBL.DIS_MSG
	dr.w	FSUBS.DIS_MSG
	dr.w	FSUBX.DIS_MSG0
	dr.w	FSUBP.DIS_MSG
	dr.w	FSUBW.DIS_MSG
	dr.w	FSUBD.DIS_MSG
	dr.w	FSUBB.DIS_MSG
	dr.w	FMOVECRX.DIS_MSG
FSUBX.DIS_MSG:
	dc.b	'FSUB.X     ',0
	dc.w	$2700
FSUBL.DIS_MSG:
	dc.b	'FSUB.L     ',0
	dc.w	$2700
FSUBS.DIS_MSG:
	dc.b	'FSUB.S     ',0
	dc.w	$2700
FSUBX.DIS_MSG0:
	dc.b	'FSUB.X     ',0
	dc.w	$2700
FSUBP.DIS_MSG:
	dc.b	'FSUB.P     ',0
	dc.w	$2700
FSUBW.DIS_MSG:
	dc.b	'FSUB.W     ',0
	dc.w	$2700
FSUBD.DIS_MSG:
	dc.b	'FSUB.D     ',0
	dc.w	$2700
FSUBB.DIS_MSG:
	dc.b	'FSUB.B     ',0
	dc.w	$2700
DIS_lbW003768:
	dc.w	$0014
	dr.w	FSINCOSX.DIS_MSG
	dr.w	DIS_lbW003772
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
DIS_lbW003772:
	dc.w	$001A
	dr.w	FSINCOSL.DIS_MSG
	dr.w	FSINCOSS.DIS_MSG
	dr.w	FSINCOSX.DIS_MSG0
	dr.w	FSINCOSP.DIS_MSG
	dr.w	FSINCOSW.DIS_MSG
	dr.w	FSINCOSD.DIS_MSG
	dr.w	FSINCOSB.DIS_MSG
	dr.w	FMOVECRX.DIS_MSG
FSINCOSX.DIS_MSG:
	dc.b	'FSINCOS.X  ',0
	dc.w	$2600
FSINCOSL.DIS_MSG:
	dc.b	'FSINCOS.L  ',0
	dc.w	$2600
FSINCOSS.DIS_MSG:
	dc.b	'FSINCOS.S  ',0
	dc.w	$2600
FSINCOSX.DIS_MSG0:
	dc.b	'FSINCOS.X  ',0
	dc.w	$2600
FSINCOSP.DIS_MSG:
	dc.b	'FSINCOS.P  ',0
	dc.w	$2600
FSINCOSW.DIS_MSG:
	dc.b	'FSINCOS.W  ',0
	dc.w	$2600
FSINCOSD.DIS_MSG:
	dc.b	'FSINCOS.D  ',0
	dc.w	$2600
FSINCOSB.DIS_MSG:
	dc.b	'FSINCOS.B  ',0
	dc.w	$2600
DIS_lbW0037F4:
	dc.w	$0014
	dr.w	FCMPX.DIS_MSG
	dr.w	DIS_lbW0037FE
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
DIS_lbW0037FE:
	dc.w	$001A
	dr.w	FCMPL.DIS_MSG
	dr.w	FCMPS.DIS_MSG
	dr.w	FCMPX.DIS_MSG0
	dr.w	FCMPP.DIS_MSG
	dr.w	FCMPW.DIS_MSG
	dr.w	FCMPD.DIS_MSG
	dr.w	FCMPB.DIS_MSG
	dr.w	FMOVECRX.DIS_MSG
FCMPX.DIS_MSG:
	dc.b	'FCMP.X     ',0
	dc.w	$2700
FCMPL.DIS_MSG:
	dc.b	'FCMP.L     ',0
	dc.w	$2700
FCMPS.DIS_MSG:
	dc.b	'FCMP.S     ',0
	dc.w	$2700
FCMPX.DIS_MSG0:
	dc.b	'FCMP.X     ',0
	dc.w	$2700
FCMPP.DIS_MSG:
	dc.b	'FCMP.P     ',0
	dc.w	$2700
FCMPW.DIS_MSG:
	dc.b	'FCMP.W     ',0
	dc.w	$2700
FCMPD.DIS_MSG:
	dc.b	'FCMP.D     ',0
	dc.w	$2700
FCMPB.DIS_MSG:
	dc.b	'FCMP.B     ',0
	dc.w	$2700
DIS_lbW003880:
	dc.w	$0014
	dr.w	FTSTX.DIS_MSG
	dr.w	DIS_lbW00388A
	dr.w	LINE.DIS_MSG
	dr.w	LINE.DIS_MSG
DIS_lbW00388A:
	dc.w	$001A
	dr.w	FTSTL.DIS_MSG
	dr.w	FTSTS.DIS_MSG
	dr.w	FTSTX.DIS_MSG0
	dr.w	FTSTP.DIS_MSG
	dr.w	FTSTW.DIS_MSG
	dr.w	FTSTD.DIS_MSG
	dr.w	FTSTB.DIS_MSG
	dr.w	FMOVECRX.DIS_MSG
FTSTX.DIS_MSG:
	dc.b	'FTST.X     ',0
	dc.w	$2900
FTSTL.DIS_MSG:
	dc.b	'FTST.L     ',0
	dc.w	$2900
FTSTS.DIS_MSG:
	dc.b	'FTST.S     ',0
	dc.w	$2900
FTSTX.DIS_MSG0:
	dc.b	'FTST.X     ',0
	dc.w	$2900
FTSTP.DIS_MSG:
	dc.b	'FTST.P     ',0
	dc.w	$2900
FTSTW.DIS_MSG:
	dc.b	'FTST.W     ',0
	dc.w	$2900
FTSTD.DIS_MSG:
	dc.b	'FTST.D     ',0
	dc.w	$2900
FTSTB.DIS_MSG:
	dc.b	'FTST.B     ',0
	dc.w	$2900
DC.DIS_MSG:
	dc.b	'DC         ',0
	dc.w	$1700
LINE.DIS_MSG:
	dc.b	'LINE_F     ',0
	dc.w	$1500
