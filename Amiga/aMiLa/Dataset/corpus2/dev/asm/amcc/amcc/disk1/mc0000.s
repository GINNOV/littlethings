programs:

disk1:
letter01		; Brev01
	mc0101.s	
	;mc0101.s	; letter_01 p. 16
	;mc0101.s	; MW_Serie 03, 04, 05, 06

letter02		; Brev02
	mc0201.s
	;mc0201.s	; letter_02 p. 13
	;mc0201.s	; MW_Serie 08, 10
	mc0202.s	; only on letter_02 p. 06	

letter03		; Brev03
	mc0301.s
	;mc0301.s	; letter_03 p. 23
	;mc0301.s	; MW_Serie 13
	mc0302.s	; only on letter_03 p. 07
	mc0303.s	; only on letter_03 p. 13
	mc0304.s	; only on MW_Serie 11
	mc0305.s	; only on MW_Serie 11
	mc0306.s	; only on MW_Serie 11
	mc0307.s	; only on MW_Serie 11

letter04		; Brev04
	mc0401.s
	;mc0401.s	; letter_04 p. 02
	;mc0401.s	; MW_Serie 11
	mc0402.s
	;mc0402.s	; letter_04 p. 09
	;mc0402.s	; MW_Serie 13, 14
	mc0403.s
	;mc0403.s	; letter_04 p. 17
	;mc0403.s	; MW_Serie 14

letter05		; Brev05
	mc0501.s
	;mc0501.s	; letter_05 p. 02
	;mc0501.s	; MW_Serie 16
	mc0502.s
	;mc0502.s	; letter_05 p. 07
	1>wavegen	; own table generation	; on p. 11
	mc0503.s	; only on letter_05 p. 14
	mc0504.s	; only on MW_Serie 15

letter06		; Brev06
	mc0601.s
	;mc0601.s	; letter_06 p. 12
	;mc0601.s	; MW_Serie 18
	mc0602.s
	;mc0602.s	; letter_06 p. 16
	mc0603.s	; only on letter_06 p. 02

letter07		; Brev07
	mc0701.s
	;mc0701.s	; letter_07 p. 03
	;mc0701.s	; MW_Serie 21
	mc0702.s
	;mc0702.s	; letter_07 p. 08
	;mc0702.s	; MW_Serie 21

letter08		; Brev08
	mc0801.s
	;mc0801.s	; letter_08 p. 06
	;mc0801.s	; MW_Serie 23
	mc0802.s
	;mc0802.s	; letter_08 p. 08
	;mc0802.s	; MW_Serie 24
	mc0803.s	; only on MW_Serie 24
	mc0804.s	; letter_08 p. 11

letter09		; Brev09
	mc0901.s
	;mc0901.s	; letter_09 p. 08
	;mc0901.s	; MW_Serie 25
	mc0902.s	; letter_09 p.11

letter10		; Brev10
	mc1001.s
	;mc1001.s	; letter_10 p. 05
	;mc1001.s	; MW_Serie 26
	mc1002.s
	;mc1002.s	; letter_10 p. 07
	;mc1002.s	; MW_Serie 27
	mc1003.s
	;mc1003.s	; letter_10 p. 09
	;mc1003.s	; MW_Serie 27
	mc1004.s
	;mc1004.s	; letter_10 p. 10
	;mc1004.s	; MW_Serie 28
	mc1005.s
	;mc1005.s	; letter_10 p. 12
	;mc1005.s	; MW_Serie 28
	mc1006a.s
	;mc1006.s	; letter_10 p. 15
	;mc1006.s	; MW_Serie 30
	mc1006b.s	; MW_Serie 30
	mc1006b_lvo.s	; MW_Serie 30
	mc1007.s
	;mc1007.s	; letter_10 p. 18
	;mc1007.s	; MW_Serie 29
	mc1008.s	; letter_10 p. 20

letter11		; Brev11	
	mc1101.s
	;mc1101.s	; letter_11 p. 05
	;mc1101.s	; MW_Serie 31
	mc1102.s
	;mc1102.s	; letter_11 p. 09
	;mc1101.s	; MW_Serie 32
				; readjoy p. 15

disk2:
letter12		; Brev12
	mc1201.s	; = ham.s
	;Ham.s		; letter_12 p. 03
				; MW_Serie 21
	mc1202.s	; = hires.s
	;Hires.s	; letter_12 p. 04
				; no explanation in MW_Series
	mc1203.s	; = lace.s
	;lace.s		; letter_12 p. 05
				; no explanation in MW_Series
	mc1204.s	; = wave.s
	;wave.s		; letter_12 p. 06
				; MW_Serie 37
	mc1205.s	; = rot.s
	;Rot.s		; letter_12 p. 07
				; MW_Serie 35
	mc1206.s	; = demo1.s
	;Demo1.s	; letter_12 p. 07
				; no explanation in MW_Series
	mc1207.s	; = demo2.s
	;Demo2.s	; letter_12 p. 07
				; no explanation in MW_Series
	mc1208.s	; = demo3.s
	;Demo3.s	; letter_12 p. 07
				; no explanation in MW_Series
	mc1209.s	; = demo4.s
	;Demo4.s	; letter_12 p. 07
				; no explanation in MW_Series
	mc1210.s	; = disk.s
	;disk.s		; letter_12 p. 10
				; no explanation in MW_Series
	mc1211.s	; = stars.s
	;stars.s	; letter_12 p. 13
				; MW_Serie 36
	mc1212.s	; = linedraw.s
	;linedraw.s	; letter_12 p. 14
				; no explanation in MW_Series
	mc1213.s	; = vec1.s
	;vector.s	; letter_12 p. 15
				; no explanation in MW_Series
	mc1214.s	; = vec2.s
				; no explanation in MW_Series
	mc1215.s	; = readmouse.S
	;readmouse.s	; letter_12 p. 16
				; no explanation in MW_Series or look in MW_Serie 31
	mc1216.s	; = getwb.s
	;getwb.s	; letter_12 p. 16
				; no explanation in MW_Series
	mc1217.s	; = initscreen.s
	;initscreen.s; letter_12 p. 16
				; no explanation in MW_Series
	mc1218.s	; = sqr.s
	;sqr.s		; letter_12 p. 16
				; no explanation in MW_Series
	mc1219.s	; = FizzleFade	
				; only on MW_Serie 33