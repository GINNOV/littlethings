*------------------------------------------------------------------------------
* PRO-PACK MC68000 Unpack Source Code - Method 2, Key
*
* Copyright (c) 1991,92 Rob Northen Computing, U.K. All Rights Reserved.
*
* File: MC68_2K.S
*
* Date: 5.3.92
*------------------------------------------------------------------------------

*------------------------------------------------------------------------------
* MC68000 Unpack Routine - Method 2, Key
*
* on entry,
*	d0.w = key
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
		dc.l $48E7FFFE,$28006100,$01E67200,$B0BC524E,$43026600,$01D26100,$01D62E80,$47E8000A
		dc.l $2A494DF5,$08006100,$01C649F3,$08004267,$BBCC6450,$7000102B,$FFFE41F6,$0800B1CC
		dc.l $6342544F,$200C0800,$00006704,$524C5248,$20080800,$00006702,$52487000,$BDC86708
		dc.l $12203F01,$520060F4,$3F00D1C0,$3F0449EC,$FFE04CD4,$00FF48E0,$FF00B9CB,$62F097CC
		dc.l $D7C8381F,$7E80DE07,$1E1BDF07,$DE076000,$00D21E1B,$DF076030,$1E1BDF07,$60561E1B
		dc.l $DF076056,$1E1BDF07,$60581E1B,$DF07605E,$1E1BDF07,$605E1E1B,$DF07605E,$1E1BDF07
		dc.l $60647A03,$DE0767CA,$DD4651CD,$FFF85446,$101BB900,$1AC0101B,$B9001AC0,$101BB900
		dc.l $1AC0101B,$B9001AC0,$51CEFFE6,$E25C6072,$DE0767A4,$DB45DE07,$67A4640E,$5345DE07
		dc.l $67A2DB45,$BA3C0009,$67B8DE07,$679C641A,$DE07679C,$DD46DE07,$679C657E,$4A466608
		dc.l $5246DE07,$6796DD46,$E15E1C1B,$204D90C6,$5348E24D,$64021AD8,$53454A46,$660C1C10
		dc.l $1AC61AC6,$51CDFFFA,$60181AD8,$1AD851CD,$FFFA600E,$1E1BDF07,$651A101B,$B9001AC0
		dc.l $E25CDE07,$650C101B,$B9001AC0,$E25CDE07,$64E867E0,$7A027C00,$DE076734,$6400FF72
		dc.l $DE076732,$64A45245,$DE076730,$6400FF7C,$1A1B673A,$50456000,$FF72DE07,$6724DD46
		dc.l $00460004,$DE076720,$6500FF7E,$6000FF74,$1E1BDF07,$60C61E1B,$DF0760C8,$1E1BDF07
		dc.l $60CA1E1B,$DF0760D6,$1E1BDF07,$60DADE07,$66041E1B,$DF07658A,$301F6708,$321F1AC1
		dc.l $530066F8,$60022E81,$4CDF7FFF,$4E757203,$E1881018,$51C9FFFA
		dc.w $4E75
