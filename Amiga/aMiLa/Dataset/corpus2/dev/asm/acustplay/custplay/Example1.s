;
;	EXAMPLE 1
;	In order to remove the hunks in the custom files you
;	can resource them and use the source directly in
;	your assembler.
;

	include	"include/misc/custplay.i"
	section "customPlay",code

j	jsr	CP_GETDATA		;Read some data from module
	jsr	CP_INIT			;Initializing routine

wait1	cmp.b	#$a0,$dff006		;Simple raster wait routine
	bne.s	wait1
wait2	cmp.b	#$00,$dff006
	beq.s	wait2
	move	#$f00,$dff180		;Flash screencolour

	jsr	CP_PLAY			;Play routine

	move	#$fff,$dff180
	btst	#6,$bfe001		;Test for mouse
	bne.s	wait1

	jsr	CP_END			;Stop routine
	rts

**********************************************************************
;CUST.Letterplayer 1 - Resourced.
**********************************************************************

	SECTION CUSTLetterPlayer1000000,CODE_C
CP_DATA	dc.l	$70FF4E75
	dc.l	$44454C49
	dc.l	$5249554D
	dc.l	lbC00007C
	dc.l	$24564552
	dc.l	$3A204C65
	dc.l	$74746572
	dc.l	$20506C61
	dc.l	$79657220
	dc.l	$4D757369
	dc.l	$6320312E
	dc.l	$30204375
	dc.l	$73746F6D
	dc.l	$20506C61
	dc.l	$79657220
	dc.l	$302E390A
	dc.l	$6F726967
	dc.l	$696E616C
	dc.l	$6C792032
	dc.l	$372D4665
	dc.l	$622D3139
	dc.l	$38372C20
	dc.l	$61646170
	dc.l	$74656420
	dc.l	$6279206D
	dc.l	$61726C65
	dc.l	$792F494E
	dc.l	$46454354
	dc.l	$2028342D
	dc.l	$4D61722D
	dc.l	$39332900
lbC00007C	dc.l	$80004455
	dc.l	1
	dc.l	$8000445E
	dc.l	lbC000272
	dc.l	$80004463
	dc.l	m.MSG
	dc.l	$80004464
	dc.l	m.MSG0
	dc.l	$80004465
	dc.l	lbC0000F0
	dc.l	$80004466
	dc.l	lbC0000C0
	dc.l	0
m.MSG	dc.l	$206D004C
	dc.l	$4E904E75
m.MSG0	dc.l	$206D0050
	dc.l	$4E904E75
lbC0000C0	dc.l	$48E78020
	dc.l	$45F900DF
	dc.l	$F000700F
	dc.l	$35400096
	dc.l	$70002540
	dc.l	$00A62540
	dc.l	$00B62540
	dc.l	$00C62540
	dc.l	$00D608B9
	dc.l	$000100BF
	dc.l	$E0014CDF
	dc.l	$04014E75
lbC0000F0	dc.l	$08F90001
	dc.l	$00BFE001
	dc.l	$61000006
	dc.l	$6000005A
	dc.l	$48E7FFFE
	dc.l	$33FC000F
	dc.l	$00DFF096
	dc.l	$70007202
	dc.l	$43FA0042
	dc.l	$41F900DF
	dc.l	$F0006100
	dc.l	$002641F9
	dc.l	$00DFF010
	dc.l	$6100001C
	dc.l	$41F900DF
	dc.l	$F0206100
	dc.l	$001241F9
	dc.l	$00DFF030
	dc.l	$61000008
	dc.l	$4CDF7FFF
	dc.l	$4E753140
	dc.l	$00A63140
	dc.l	$00A83141
	dc.l	$00A42149
	dc.l	$00A04E75
	dc.l	0
	dc.l	$48E7FFFE
	dc.w	$23FC
	dc.l	lbL00081E
	dc.l	lbL0005C4
	dc.w	$23FC
	dc.l	lbL000846
	dc.l	lbL0005FE
	dc.w	$23FC
	dc.l	lbL000856
	dc.l	lbL000638
	dc.w	$23FC
	dc.l	lbL000866
	dc.l	lbL000672
	dc.w	$42B9
	dc.l	lbL0005AE
	dc.w	$42B9
	dc.l	lbL0005E8
	dc.w	$42B9
	dc.l	lbL000622
	dc.w	$42B9
	dc.l	lbL00065C
	dc.w	$42B9
	dc.l	lbL0005B4
	dc.w	$42B9
	dc.l	lbL0005EE
	dc.w	$42B9
	dc.l	lbL000628
	dc.w	$42B9
	dc.l	lbL000662
	dc.w	$23F9
	dc.l	lbL00081E
	dc.l	lbL0005C8
	dc.w	$23F9
	dc.l	lbL000846
	dc.l	lbL000602
	dc.w	$23F9
	dc.l	lbL000856
	dc.l	lbL00063C
	dc.w	$23F9
	dc.l	lbL000866
	dc.l	lbL000676
	dc.w	$23F9
	dc.l	lbB000822
	dc.l	lbL0005D4
	dc.w	$23F9
	dc.l	lbB00084A
	dc.l	lbL00060E
	dc.w	$23F9
	dc.l	lbL00085A
	dc.l	lbL000648
	dc.w	$23F9
	dc.l	lbB00086A
	dc.l	lbL000682
	dc.w	$42B9
	dc.l	lbL0005B6
	dc.w	$42B9
	dc.l	lbL0005F0
	dc.w	$42B9
	dc.l	lbL00062A
	dc.w	$42B9
	dc.l	lbL000664
	dc.w	$23FC
	dc.l	lbB00068E
	dc.w	$00DF
	dc.w	$F0A0
	dc.w	$23FC
	dc.l	lbB00068E
	dc.w	$00DF
	dc.w	$F0B0
	dc.w	$23FC
	dc.l	lbB00068E
	dc.w	$00DF
	dc.w	$F0C0
	dc.w	$23FC
	dc.l	lbB00068E
	dc.l	$00DFF0D0
	dc.l	$33FC0010
	dc.l	$00DFF0A4
	dc.l	$33FC0010
	dc.l	$00DFF0B4
	dc.l	$33FC0010
	dc.l	$00DFF0C4
	dc.l	$33FC0010
	dc.l	$00DFF0D4
	dc.l	$33FC800F
	dc.l	$00DFF096
	dc.l	$4CDF7FFF
	dc.l	$4E7548E7
lbC000272	EQU	*-2
	dc.l	$FFFE41F9
	dc.l	lbL0005A6
	dc.w	$6100
	dc.w	$0026
	dc.w	$41F9
	dc.l	lbL0005E0
	dc.w	$6100
	dc.w	$001C
	dc.w	$41F9
	dc.l	lbL00061A
	dc.w	$6100
	dc.w	$0012
	dc.w	$41F9
	dc.l	lbL000654
	dc.l	$61000008
	dc.l	$4CDF7FFF
	dc.l	$4E755368
	dc.l	$000E6A00
	dc.l	$00D44268
	dc.l	$00344268
	dc.l	$00362268
	dc.l	$00222628
	dc.l	$002E4284
	dc.l	$3811B87C
	dc.l	$00806600
	dc.l	$001E2169
	dc.l	$00020000
	dc.l	$06A80000
	dc.l	$00060022
	dc.l	$2A290002
	dc.l	$2668001A
	dc.l	$26856000
	dc.l	$FFD2B87C
	dc.l	$00816600
	dc.l	$001E2668
	dc.l	$00002769
	dc.l	$00020056
	dc.l	$27690006
	dc.l	$005A06A8
	dc.l	10
	dc.l	$00226000
	dc.l	$FFAEB87C
	dc.l	$00826600
	dc.l	$000C317C
	dc.l	$00010036
	dc.l	$60000042
	dc.l	$D6443143
	dc.l	$0032B6A8
	dc.l	$002E6600
	dc.l	$003406A8
	dc.l	8
	dc.l	$001E2468
	dc.l	$001E216A
	dc.l	$0004002E
	dc.l	$21520022
	dc.l	$6600FF74
	dc.l	$21680026
	dc.l	$001E2468
	dc.l	$001E216A
	dc.l	$0004002E
	dc.l	$21520022
	dc.l	$6000FF5C
	dc.l	$4A680036
	dc.l	$6600000A
	dc.l	$42A80004
	dc.l	$42680038
	dc.l	$30290002
	dc.l	$53403140
	dc.l	$000ED3FC
	dc.l	4
	dc.l	$21490022
	dc.l	$2468001A
	dc.l	$26680000
	dc.l	$30280018
	dc.l	$5340C0FC
	dc.l	$000249F9
	dc.l	lbB00051A
	dc.l	$32340000
	dc.l	$302B005E
	dc.l	$67000032
	dc.l	$B268002A
	dc.l	$65000016
	dc.l	$D168002A
	dc.l	$B268002A
	dc.l	$62000006
	dc.l	$3141002A
	dc.l	$6000001E
	dc.l	$9168002A
	dc.l	$B268002A
	dc.l	$65000006
	dc.l	$3141002A
	dc.l	$6000000A
	dc.l	$D2680034
	dc.l	$3141002A
	dc.l	$26680000
	dc.l	$D7FC0000
	dc.l	$00562228
	dc.l	$00124282
	dc.l	$14331800
	dc.l	$6A000012
	dc.l	$44024283
	dc.l	$36280032
	dc.l	$96423403
	dc.l	$60000006
	dc.l	$D4680032
	dc.l	$31420018
	dc.l	$52A80012
	dc.l	$0CA80000
	dc.l	$00080012
	dc.l	$66000006
	dc.l	$42A80012
	dc.l	$26680000
	dc.l	$4A68000C
	dc.l	$6700001A
	dc.l	$4268000C
	dc.l	$4282142B
	dc.l	$00553228
	dc.l	$002AD242
	dc.l	$3141002A
	dc.l	$60000018
	dc.l	$317CFFFF
	dc.l	$000C4282
	dc.l	$142B0055
	dc.l	$3228002A
	dc.l	$92423141
	dc.l	$002A4282
	dc.l	$342B0060
	dc.l	$95680034
	dc.l	$42803028
	dc.l	$002A322B
	dc.l	$00626700
	dc.l	$00126B00
	dc.l	$000A9068
	dc.l	$00386000
	dc.l	$0006D068
	dc.l	$00383540
	dc.l	$00064282
	dc.l	$24680000
	dc.l	$42804281
	dc.l	$102A0030
	dc.l	$122A0031
	dc.l	$B2A80004
	dc.l	$6700006A
	dc.l	$B0BC0000
	dc.l	$00006700
	dc.l	$0014B0A8
	dc.l	$00046600
	dc.l	$000C0C68
	dc.l	$00000036
	dc.l	$6700004E
	dc.l	$24280004
	dc.l	$C4FC0002
	dc.l	$47EA0020
	dc.l	$42834284
	dc.l	$16332000
	dc.l	$18332001
	dc.l	$B8680038
	dc.l	$6200001A
	dc.l	$97680038
	dc.l	$B8680038
	dc.l	$6F00000A
	dc.l	$31440038
	dc.l	$52A80004
	dc.l	$60000016
	dc.l	$D7680038
	dc.l	$B8680038
	dc.l	$6200000A
	dc.l	$31440038
	dc.l	$52A80004
	dc.l	$42813228
	dc.l	$003882FC
	dc.l	$00042268
	dc.l	$001A3341
	dc.l	$00084E75
lbB00051A	dc.l	$1AC01940
	dc.l	$17D01680
	dc.l	$15301400
	dc.l	$12E011D0
	dc.l	$10D00FE0
	dc.l	$0F000E20
	dc.l	$0D600CA0
	dc.l	$0BE80B40
	dc.l	$0A980A00
	dc.l	$097008E8
	dc.l	$086807F0
	dc.l	$07800710
	dc.l	$06B00650
	dc.l	$05F405A0
	dc.l	$054C0500
	dc.l	$04B80474
	dc.l	$043403F8
	dc.l	$03C00388
	dc.l	$03580328
	dc.l	$02FA02D0
	dc.l	$02A60280
	dc.l	$025C023A
	dc.l	$021A01FC
	dc.l	$01E001C4
	dc.l	$01AC0194
	dc.l	$017D0168
	dc.l	$01530140
	dc.l	$012E011D
	dc.l	$010D00FE
	dc.l	$00F000E2
	dc.l	$00D600CA
	dc.l	$00BE00B4
	dc.l	$00AA00A0
	dc.l	$0097008F
	dc.l	$0087007F
lbL0005A6	dc.l	lbB00068E
	dc.l	0
lbL0005AE	dc.l	0
	dc.l	0
lbL0005B4	EQU	*-2
lbL0005B6	dc.l	0
	dc.l	0
	dc.l	$000000DF
	dc.l	$F0A00000
lbL0005C4	EQU	*-2
	dc.l	0
lbL0005C8	EQU	*-2
	dc.w	0
	dc.l	lbL00081E
	dc.w	0
	dc.w	0
lbL0005D4	dc.l	0
	dc.l	0
	dc.l	0
lbL0005E0	dc.l	lbB00068E
	dc.l	0
lbL0005E8	dc.l	0
	dc.l	0
lbL0005EE	EQU	*-2
lbL0005F0	dc.l	0
	dc.l	0
	dc.l	$000000DF
	dc.l	$F0B00000
lbL0005FE	EQU	*-2
	dc.l	0
lbL000602	EQU	*-2
	dc.w	0
	dc.l	lbL000846
	dc.w	0
	dc.w	0
lbL00060E	dc.l	0
	dc.l	0
	dc.l	0
lbL00061A	dc.l	lbB00068E
	dc.l	0
lbL000622	dc.l	0
	dc.l	0
lbL000628	EQU	*-2
lbL00062A	dc.l	0
	dc.l	0
	dc.l	$000000DF
	dc.l	$F0C00000
lbL000638	EQU	*-2
	dc.l	0
lbL00063C	EQU	*-2
	dc.w	0
	dc.l	lbL000856
	dc.w	0
	dc.w	0
lbL000648	dc.l	0
	dc.l	0
	dc.l	0
lbL000654	dc.l	lbB00068E
	dc.l	0
lbL00065C	dc.l	0
	dc.l	0
lbL000662	EQU	*-2
lbL000664	dc.l	0
	dc.l	0
	dc.l	$000000DF
	dc.l	$F0D00000
lbL000672	EQU	*-2
	dc.l	0
lbL000676	EQU	*-2
	dc.w	0
	dc.l	lbL000866
	dc.w	0
	dc.w	0
lbL000682	dc.l	0
	dc.l	0
	dc.l	0
lbB00068E	dc.l	$80889098
	dc.l	$A0A8B0B8
	dc.l	$C0C8D0D8
	dc.l	$E0E8F0F8
	dc.l	$00081018
	dc.l	$20283038
	dc.l	$40485058
	dc.l	$60687078
	dc.l	$FFFF0E00
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	$00020002
	dc.l	$04060806
	dc.l	$040200FE
	dc.l	$FCFAF8FA
	dc.l	$FCFE0002
	dc.l	$04060806
	dc.l	$040200FE
	dc.l	$FCFAF8FA
	dc.l	$FCFE0000
	dc.l	$01000000
	dc.l	0
	dc.l	0
	dc.l	0
lbB0006F2	dc.l	$00F0E0D0
	dc.l	$C0B0A090
	dc.l	$8090A0B0
	dc.l	$C0D0E0F0
	dc.l	$00102030
	dc.l	$40506070
	dc.l	$7F706050
	dc.l	$40302010
	dc.l	$96960000
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	$00010002
	dc.l	$04060806
	dc.l	$040200FE
	dc.l	$FCFAF8FA
	dc.l	$FCFE0002
	dc.l	$04060806
	dc.l	$040200FE
	dc.l	$FCFAF8FA
	dc.l	$FCFE0000
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbB000756	dc.l	$80808080
	dc.l	$80808080
	dc.l	$80808080
	dc.l	$80808080
	dc.l	$7F7F7F7F
	dc.l	$7F7F7F7F
	dc.l	$7F7F7F7F
	dc.l	$7F7F7F7F
	dc.l	$FFFF1E00
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	$00020002
	dc.l	$04060806
	dc.l	$040200FE
	dc.l	$FCFAF8FA
	dc.l	$FCFE0002
	dc.l	$04060806
	dc.l	$040200FE
	dc.l	$FCFAF8FA
	dc.l	$FCFE0000
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	$FFE20000
lbB0007BA	dc.l	$80808080
	dc.l	$80808080
	dc.l	$80808080
	dc.l	$80808080
	dc.l	$7F7F7F7F
	dc.l	$7F7F7F7F
	dc.l	$7F7F7F7F
	dc.l	$7F7F7F7F
	dc.l	$28AF0A64
	dc.l	$06000000
	dc.l	0
	dc.l	0
	dc.l	$02030002
	dc.l	$04060806
	dc.l	$040200FE
	dc.l	$FCFAF8FA
	dc.l	$FCFE0002
	dc.l	$04060806
	dc.l	$040200FE
	dc.l	$FCFAF8FA
	dc.l	$FCFE0000
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL00081E	dc.l	lbW0008A6
lbB000822	dc.l	1
	dc.l	lbW0008A6
	dc.l	$FFFFFFFD
	dc.l	lbW0008A6
	dc.l	$FFFFFFF8
	dc.l	lbW0008D2
	dc.l	$FFFFFFFF
	dc.l	0
	dc.l	0
lbL000846	dc.l	lbW0008FE
lbB00084A	dc.l	1
	dc.l	0
	dc.l	0
lbL000856	dc.l	lbW000940
lbL00085A	dc.l	0
	dc.l	0
	dc.l	0
lbL000866	dc.l	lbL000A78
lbB00086A	dc.l	1
	dc.l	lbW000984
	dc.l	1
	dc.l	lbW000984
	dc.l	1
	dc.l	lbW000A30
	dc.l	1
	dc.l	lbW000A30
	dc.l	1
	dc.l	lbW0009E4
	dc.l	1
	dc.l	lbW0009E4
	dc.l	1
	dc.l	0
	dc.l	0
lbW0008A6	dc.w	$0080
	dc.l	lbB00068E
	dc.l	$00810000
	dc.l	0
	dc.l	$00000019
	dc.l	$000C0019
	dc.l	$00180019
	dc.l	$00060025
	dc.l	$00060019
	dc.l	$000C0019
	dc.l	$00240000
	dc.w	0
lbW0008D2	dc.w	$0080
	dc.l	lbB00068E
	dc.l	$00810000
	dc.l	0
	dc.l	$00000019
	dc.l	$000C0019
	dc.l	$00180019
	dc.l	$00060017
	dc.l	$00060019
	dc.l	$000C0019
	dc.l	$00240000
	dc.w	0
lbW0008FE	dc.w	$0080
	dc.l	lbB0006F2
	dc.l	$00810003
	dc.l	$07000003
	dc.l	$0700003D
	dc.l	$00600081
	dc.l	$00030800
	dc.l	$00030800
	dc.l	$003D0060
	dc.l	$0081FE03
	dc.l	$07FEFE03
	dc.l	$07FE003D
	dc.l	$00600081
	dc.l	$FE0205FE
	dc.l	$FE0205FE
	dc.l	$003D0060
	dc.l	0
lbW000940	dc.w	$0080
	dc.l	lbB000756
	dc.l	$00810000
	dc.l	0
	dc.l	$00000082
	dc.l	$0018002D
	dc.l	$000C0082
	dc.l	$0024002D
	dc.l	$000C002D
	dc.l	$0006002D
	dc.l	$00060082
	dc.l	$0018002D
	dc.l	$000C0082
	dc.l	$0024002D
	dc.l	$0008002C
	dc.l	$0008002B
	dc.l	$00080000
	dc.w	0
lbW000984	dc.w	$0080
	dc.l	lbB0007BA
	dc.l	$00810000
	dc.l	0
	dc.l	$00000031
	dc.l	$00300034
	dc.l	$000C0033
	dc.l	$000C0031
	dc.l	$000C002F
	dc.l	$000C002D
	dc.l	$00300034
	dc.l	$000C0033
	dc.l	$000C0031
	dc.l	$000C002F
	dc.l	$000C0034
	dc.l	$00300034
	dc.l	$000C0033
	dc.l	$000C0031
	dc.l	$000C002F
	dc.l	$000C0036
	dc.l	$00180033
	dc.l	$00180031
	dc.l	$0018002F
	dc.l	$00180000
	dc.w	0
lbW0009E4	dc.w	$0080
	dc.l	lbB0007BA
	dc.l	$00810000
	dc.l	0
	dc.l	$00000031
	dc.l	$00300038
	dc.l	$000C0038
	dc.l	$000C0038
	dc.l	$000C0036
	dc.l	$00180038
	dc.l	$006C0034
	dc.l	$000C0034
	dc.l	$00180034
	dc.l	$00180034
	dc.l	$000C0036
	dc.l	$00180033
	dc.l	$00180031
	dc.l	$0018002F
	dc.l	$00180000
	dc.w	0
lbW000A30	dc.w	$0080
	dc.l	lbB0007BA
	dc.l	$00810000
	dc.l	0
	dc.l	$00000031
	dc.l	$00480038
	dc.l	$00180036
	dc.l	$000C0034
	dc.l	$000C0031
	dc.l	$00600034
	dc.l	$000C0034
	dc.l	$00180034
	dc.l	$00180034
	dc.l	$000C0036
	dc.l	$00180033
	dc.l	$00180031
	dc.l	$0018002F
	dc.l	$00180000
	dc.w	0
lbL000A78	dc.l	$00820180
	dc.l	0
	END
