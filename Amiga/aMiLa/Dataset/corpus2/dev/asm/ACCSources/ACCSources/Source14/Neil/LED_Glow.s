
* LED Glow! This amazing little routine will make your Amiga's LED Glow!
* Far more exciting than the usual flashing!  --  Code modified from part
* of an old Seka demo by Neil Johnston

	section LED_Glow,code

**********

Start	lea	DataTab,a0		Get address of data table
Loop3	move.w	(a0)+,d0		Get delay word
	bsr	Pause			Pause It

	cmp.l	#DataTab+126,a0		End of table?
	bne.s	Loop3			Just loop around
	bra.s	Start			Reset table

Pause	move.w	#24000,d1
	sub.w	d0,d1
	asr.w	#5,d0
	asr.w	#5,d1
	bchg	#1,$bfe001		Swap LED Brightness

Loop1	bsr.s	Pause2
	dbra	d0,Loop1
	bchg	#1,$bfe001
Loop2	bsr.s	Pause2
	dbra	d1,Loop2
	rts

Pause2	sub.l	#1,Time
	beq.s	Exit
	rts

Exit	addq.l	#8,sp			Remove bsr addr's from stack
	bset	#1,$bfe001
	rts

**********

DataTab	dc.w   24000,23940
	dc.w   23760,23464
	dc.w   23052,22530
	dc.w   21904,21178
	dc.w   20360,19459
	dc.w   18483,17443
	dc.w   16384,15209
	dc.w   14039,12848
	dc.w   11649,10453
	dc.w   9273,8120
	dc.w   7006,5941
	dc.w   4937,4004
	dc.w   3151,2386
	dc.w   1717,1151
	dc.w   693,348
	dc.w   120,10
	dc.w   20,150
	dc.w   398,762
	dc.w   1238,1822
	dc.w   2508,3288
	dc.w   4156,5102
	dc.w   6116,7190
	dc.w   8311,9470
	dc.w   10654,11851
	dc.w   13049,14238
	dc.w   15403,16535
	dc.w   17622,18652
	dc.w   19616,20504
	dc.w   21306,22016
	dc.w   22626,23129
	dc.w   23522,23799
	dc.w   23958,23998

Time	dc.l	$50bff


