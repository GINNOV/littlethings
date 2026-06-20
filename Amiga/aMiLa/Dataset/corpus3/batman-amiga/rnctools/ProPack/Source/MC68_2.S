*------------------------------------------------------------------------------
* PRO-PACK MC68000 Unpack Source Code - Method 2
*
* Copyright (c) 1991,92 Rob Northen Computing, U.K. All Rights Reserved.
*
* File: MC68_2.S
*
* Date: 5.3.92
*------------------------------------------------------------------------------

*------------------------------------------------------------------------------
* MC68000 Unpack Routine - Method 2
*
* on entry,
*	a0.l = start address of packed file
*	a1.l = start address to unpack file
* 	stack space required: $50 bytes
*
* on exit,
*	d0.l = length of the unpacked file in bytes OR error code
*	    0 =  not a packed file
*
*	all other registers are preserved
*------------------------------------------------------------------------------
unpack
		dc.l $48E7FFFE,$610001BC,$7200B0BC,$524E4302,$660001A8,$610001AC,$2E8047E8,$000A2A49
		dc.l $4DF50800,$6100019C,$49F30800,$4267BBCC,$644C7000,$102BFFFE,$41F60800,$B1CC633E
		dc.l $544F200C,$08000000,$6704524C,$52482008,$08000000,$67025248,$7000BDC8,$67081220
		dc.l $3F015200,$60F43F00,$D1C049EC,$FFE04CD4,$00FF48E0,$FF00B9CB,$62F097CC,$D7C87E80
		dc.l $DE071E1B,$DF07DE07,$600000BA,$1E1BDF07,$60301E1B,$DF076044,$1E1BDF07,$60441E1B
		dc.l $DF076046,$1E1BDF07,$604C1E1B,$DF07604C,$1E1BDF07,$604C1E1B,$DF076052,$7A03DE07
		dc.l $67CADD46,$51CDFFF8,$54461ADB,$1ADB1ADB,$1ADB51CE,$FFF6606C,$DE0767B6,$DB45DE07
		dc.l $67B6640E,$5345DE07,$67B4DB45,$BA3C0009,$67CADE07,$67AE641A,$DE0767AE,$DD46DE07
		dc.l $67AE656E,$4A466608,$5246DE07,$67A8DD46,$E15E1C1B,$204D90C6,$5348E24D,$64021AD8
		dc.l $53454A46,$660C1C10,$1AC61AC6,$51CDFFFA,$60121AD8,$1AD851CD,$FFFA6008,$1E1BDF07
		dc.l $650E1ADB,$DE076506,$1ADBDE07,$64F467EC,$7A027C00,$DE07672C,$6400FF7E,$DE07672A
		dc.l $64B05245,$DE076728,$64881A1B,$67345045,$6080DE07,$6720DD46,$00460004,$DE07671C
		dc.l $658E6086,$1E1BDF07,$60CE1E1B,$DF0760D0,$1E1BDF07,$60D21E1B,$DF0760DA,$1E1BDF07
		dc.l $60DEDE07,$66041E1B,$DF076598,$301F6708,$321F1AC1,$530066F8,$60022E81,$4CDF7FFF
		dc.l $4E757203,$E1881018,$51C9FFFA
		dc.w $4E75
