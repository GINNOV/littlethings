*------------------------------------------------------------------------------
* AmigaDOS Read File Function for AmigaDos disks
*
* Copyright (c) 1988-92 Rob Northen Computing, U.K. All Rights Reserved.
*
* File: DOSioR.s
*
* Date: 07.09.92
*------------------------------------------------------------------------------

*------------------------------------------------------------------------------
* AmigaDOS Read File Function
* on entry,
*	d0.l = function
*		0=load file
*	a0.l = full pathname of file, terminated with 0
*	a1.l = file buffer (even word boundary)
*	a2.l = workspace buffer ($3300 bytes of CHIPmem required)
* on exit,
*	d0.l = result
*		  0 = no error
*		204 = directory not found
*		205 = file not found
*		225 = not a DOS disk
*		405 = bad block checksum
*		see diskio.s for error codes
*	d1.l = length of file in bytes
*	all others registers are preserved
*
* IMPORTANT :
*
* File loading time can be greatly reduced by writing the file onto the
* disk using the source file DOSIO.S. This has the advantage over using
* AmigaDos to copy the file onto the disk by writing out the file's data
* block lists, as well as the actual data blocks, on contiguous sectors.
*------------------------------------------------------------------------------
dosioR
		dc.l $48E7FFFE,$2C002E01,$28482A49,$2C4A6100,$01684A86,$6606611A,$2F410004,$2E807200
		dc.l $7400363C,$80006100,$026C4CDF,$7FFF4A80,$4E756100,$00A06670,$2E280144,$2F0745E8
		dc.l $01386166,$665E2401,$2801264D,$2C07E08E,$E28E6602,$264E6152,$664A5282,$2A016708
		dc.l $B4816604,$538666EE,$22049484,$204B6100,$02226630,$610001CA,$662A2028,$000C9E80
		dc.l $41E80018,$E4986002,$2AD851C8,$FFFC4240,$E5986002,$1AD851C8,$FFFC5382,$66D62205
		dc.l $200766A2,$221F4A80,$4E752F02,$204E2028,$00086610,$222801F8,$67146100,$0180660E
		dc.l $45E80138,$22227001,$91A80008,$7000241F,$4A804E75,$2F0C204E,$6100013A,$66000094
		dc.l $43FA0182,$32812E8C,$610000D6,$67000084,$E54843FA,$017432C1,$32C02230,$0000674A
		dc.l $6100013A,$666C203C,$000000E1,$7402B490,$66607402,$BC3C0003,$67064A14,$660274FD
		dc.l $B4A801FC,$661E43E8,$01B045FA,$01447400,$14195302,$10196174,$B01A56CA,$FFF86604
		dc.l $4A12671E,$303C01F0,$60A8203C,$000000CC,$BC3C0003,$671C4A14,$6618203C,$000000CD
		dc.l $60104A14,$6600FF7A,$43FA0102,$32A801F2,$7000285F,$4A804E75,$204C612E,$B03C0044
		dc.l $66266126,$B03C0046,$661E1018,$04000030,$6D16B03C,$00336E10,$0C18003A,$660A41FA
		dc.l $00CE1140,$0001584C,$4E751018,$B03C0061,$6D0AB03C,$007A6E04,$020000DF,$4A004E75
		dc.l $48E740C0,$700072FF,$204C43FA,$00A44211,$52814A14,$67080C1C,$002F66F4,$534C4A81
		dc.l $672AC2FC,$000D1018,$61C212C0,$D2400281,$000007FF,$B9C866EA,$0C14002F,$6602524C
		dc.l $421982FC,$00484241,$48415C41,$20014CDF,$03024E75,$323C0370,$6122661E,$203C0000
		dc.l $00E17402,$B4906612,$7401B4A8,$01FC660A,$43FA0034,$32A8013E,$70004E75,$6152660A
		dc.l $610A6706,$203C0000,$01954E75,$48E74080,$7000323C,$007FD098,$51C9FFFC,$44804CDF
		dc.l $01024E75,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
		dc.l $00000000,$00000000,$00000000,$00000000,$74017600,$224E303A
		dc.w $FFD6

		include	diskioR.s
