*------------------------------------------------------------------------------
* PRO-PACK MC68000 Unpack Source Code (Compact Version) - Method 1 
*
* Copyright (c) 1991,92 Rob Northen Computing, U.K. All Rights Reserved.
*
* File: MC68_1C.S
*
* Date: 28.2.92
*------------------------------------------------------------------------------

*------------------------------------------------------------------------------
* MC68000 Unpack Routine (Compact Version) - Method 1
*
* on entry,
*	a0.l = start address of packed file
*	a1.l = start address to unpack file
*	(note: a1 cannot be equal to a0)
*	stack space required: $1DC bytes
*
*	all other registers are preserved
*------------------------------------------------------------------------------
unpack
		dc.l $48E7FFFC,$4FEFFE80,$244F5848,$610000EC,$47E8000A,$28494BF4,$08007E00,$1C2B0001
		dc.l $E15E1C13,$70027202,$610000AC,$204A6100,$00D641EA,$00806100,$00CE41EA,$01006100
		dc.l $00C670FF,$72106100,$008E3800,$5344601C,$41EA0080,$70006148,$448043F4,$08FF41EA
		dc.l $0100613C,$18D918D9,$51C8FFFC,$204A6130,$53406B1A,$18DB51C8,$FFFC102B,$0001E158
		dc.l $1013EFA8,$7201EF69,$5341CC81,$8C8051CC,$FFC0B9CD,$65964FEF,$01804CDF,$3FFF4E75
		dc.l $3018C046,$905866F8,$1228003C,$9E016C02,$6130E2AE,$1028003D,$B03C0002,$6D165300
		dc.l $12001400,$3028003E,$C0469E01,$6C026112,$E2AE05C0,$4E75C046,$9E016C02,$6104E2AE
		dc.l $4E75DE01,$EEAE4846,$584B1C23,$E15E1C23,$48469207,$7E109E01,$4E757203,$E1881018
		dc.l $51C9FFFA,$4E75701F,$720561CA,$53406B7C,$34003600,$4FEFFFF0,$224F700F,$720461B6
		dc.l $12C051CA,$FFF67001,$E2987201,$740048E7,$07003803,$43EF000C,$B219663A,$7A01E36D
		dc.l $534530C5,$2A024845,$3E015347,$E355E256,$51CFFFFA,$7A109A01,$EA6E30C6,$1141003C
		dc.l $1A039A04,$1145003D,$7C015305,$EB6E5346,$3146003E,$D48051CC,$FFC0E288,$5201B23C
		dc.l $001166AE,$4CDF00E0,$4FEF0010
		dc.w $4E75
