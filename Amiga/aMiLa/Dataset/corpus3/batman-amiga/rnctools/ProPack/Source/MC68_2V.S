*------------------------------------------------------------------------------
* PRO-PACK MC68000 Unpack Source Code - Method 2, Verify
*
* Copyright (c) 1991,92 Rob Northen Computing, U.K. All Rights Reserved.
*
* File: MC68_2V.S
*
* Date: 5.3.92
*------------------------------------------------------------------------------

*------------------------------------------------------------------------------
* MC68000 Unpack Routine - Method 2, Verify
*
* on entry,
*	a0.l = start address of packed file
*	a1.l = start address to unpack file
*	stack space required: $244 bytes
*
* on exit,
*	d0.l = length of the unpacked file in bytes OR error code
*	    0 = not a packed file
*	   -1 = packed data CRC error
*	   -2 = unpacked data CRC error
*
*	all other registers are preserved
*------------------------------------------------------------------------------
unpack
		dc.l $48E7FFFE,$610001E6,$7200B0BC,$524E4302,$660001D2,$610001D6,$2E8047E8,$000A2A49
		dc.l $4DF50800,$610001C6,$49F30800,$224B6100,$01C841EB,$FFFA6100,$01B472FF,$B0426600
		dc.l $01A44840,$3F004267,$BBCC644C,$7000102B,$FFFE41F6,$0800B1CC,$633E544F,$200C0800
		dc.l $00006704,$524C5248,$20080800,$00006702,$52487000,$BDC86708,$12203F01,$520060F4
		dc.l $3F00D1C0,$49ECFFE0,$4CD400FF,$48E0FF00,$B9CB62F0,$97CCD7C8,$7E80DE07,$1E1BDF07
		dc.l $DE076000,$00BA1E1B,$DF076030,$1E1BDF07,$60441E1B,$DF076044,$1E1BDF07,$60461E1B
		dc.l $DF07604C,$1E1BDF07,$604C1E1B,$DF07604C,$1E1BDF07,$60527A03,$DE0767CA,$DD4651CD
		dc.l $FFF85446,$1ADB1ADB,$1ADB1ADB,$51CEFFF6,$606CDE07,$67B6DB45,$DE0767B6,$640E5345
		dc.l $DE0767B4,$DB45BA3C,$000967CA,$DE0767AE,$641ADE07,$67AEDD46,$DE0767AE,$656E4A46
		dc.l $66085246,$DE0767A8,$DD46E15E,$1C1B204D,$90C65348,$E24D6402,$1AD85345,$4A46660C
		dc.l $1C101AC6,$1AC651CD,$FFFA6012,$1AD81AD8,$51CDFFFA,$60081E1B,$DF07650E,$1ADBDE07
		dc.l $65061ADB,$DE0764F4,$67EC7A02,$7C00DE07,$672C6400,$FF7EDE07,$672A64B0,$5245DE07
		dc.l $67286488,$1A1B6734,$50456080,$DE076720,$DD460046,$0004DE07,$671C658E,$60861E1B
		dc.l $DF0760CE,$1E1BDF07,$60D01E1B,$DF0760D2,$1E1BDF07,$60DA1E1B,$DF0760DE,$DE076604
		dc.l $1E1BDF07,$6598301F,$670A204D,$321F10C1,$530066F8,$202F0002,$9BC0224D,$611A72FE
		dc.l $B45F6702,$2E814CDF,$7FFF4E75,$7203E188,$101851C9,$FFFA4E75,$4FEFFE00,$204F7600
		dc.l $22037407,$E2496404,$0A41A001,$51CAFFF6,$30C15203,$66EA7400,$1219B302,$32020242
		dc.l $00FFD442,$34372000,$E049B302,$538066E8,$4FEF0200
		dc.w $4E75
