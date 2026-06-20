*****************************************************
*						    *
* Move The Mouse Routine.                           *
*						    *
* This routine also changes the workbench colours,  *
* (Permentantly Red when you click off....)         *
* So I think I should claim the competition prize!  *
*						    *
* Click Left & Right Mouse To Get Rid Of Interrupt  *
*						    *
* Coded By R.Capper (The Snowman)....		    *
*						    *
*****************************************************
	Section	Mouse,Code_C

	Move.l	$4,a6
	Jsr	-132(A6)		_LVOForbid
	CLR.L   D0
	LEA     GFXlib(PC),A1
	JSR	-552(A6)		Open graphics library
	MOVE.L  D0,GFXbase    
	MOVE.L 	GFXbase,A0
	Move.l	$26(a0),a2		Find colour 182 from base
	Move.l	#0,d0
Copy	Move.w	(a2)+,d0
	Cmp.w	#$0182,d0
	Bne.s	Copy
	Move.l	a2,Save182
	Move.l  $6c,OldRast3+2		Set Up An Interrupt
	Move.l  #Interupt,$6c
	Rts				Exit

***************************************************** A Lame Interrupt
Interupt	
	Movem.l D0-D7/A0-A6,-(A7)
	Move.l  #Interupt,$6c
	Move.l	Save182,a2
	Add.w	#$0222,(a2)		Change colour saved above!
	Move.l	OldPos,a0		Table Handling routine..
	Move.l	#0,d0
	Move.w	(a0)+,d0
	Cmp.w	#$ffff,d0		End of table?
	Bne.s	NoLoop			Nahh...
	Lea.l	Table,a0
	Move.w	(a0)+,d0
NoLoop	Move.w	d0,$dff036		Mouse Control Positions
	Move.l	a0,OldPos
 	Btst	#6,$bfe001		Left Mouse...
	Bne.s   NoWait
	Btst	#$0A,$dff016		And Right Mouse...
	Bne.s	NoWait
	Move.l  OldRast3+2,$6c
	Move.l	$4,a6
	Jsr    	-138(a6)		LVO Permit
	Move.w	#$0f32,(a2)		Restore 182
NoWait	Movem.l (A7)+,D0-D7/A0-A6
OldRast3
	Jmp     	$00000000
***************************************************** Vars / Table
OldPos	Dc.l	Table
Table	Dc.w	$0000,$0001,$0002,$0003,$0004,$0005,$0006
	Dc.w	$0007,$0008,$0009,$000a,$000b,$000c,$000d
	Dc.w	$000e,$000f
	Dc.w	$0010,$0011,$0012,$0013,$0014,$0015,$0016
	Dc.w	$0017,$0018,$0019,$001a,$001b,$001c,$001d
	Dc.w	$001e,$001f
	Dc.w	$0020,$0021,$0022,$0023,$0024,$0025,$0026
	Dc.w	$0027,$0028,$0029,$002a,$002b,$002c,$002d
	Dc.w	$002e,$002f
	Dc.w	$002f,$012f,$022f,$032f,$042f,$052f,$062f
	Dc.w	$072f,$082f,$092f,$0a2f,$0b2f,$0c2f,$0d2f
	Dc.w	$0e2f,$0f2f
	Dc.w	$102f,$112f,$122f,$132f,$142f,$152f,$162f
	Dc.w	$172f,$182f,$192f,$1a2f,$1b2f,$1c2f,$1d2f
	Dc.w	$1e2f,$1f2f
	Dc.w	$202f,$212f,$222f,$232f,$242f,$252f,$262f
	Dc.w	$272f,$282f,$292f,$2a2f,$2b2f,$2c2f,$2d2f
	Dc.w	$2e2f,$2f2f
	Dc.w	$2f2f,$2f2e,$2f2d,$2f2c,$2f2b,$2f2a,$2f29
	Dc.w	$2f28,$2f27,$2f26,$2f25,$2f24,$2f23,$2f22
	Dc.w	$2f21,$2f20
	Dc.w	$2f1f,$2f1e,$2f1d,$2f1c,$2f1b,$2f1a,$2f19
	Dc.w	$2f18,$2f17,$2f16,$2f15,$2f14,$2f13,$2f12
	Dc.w	$2f11,$2f10
	Dc.w	$2f0f,$2f0e,$2f0d,$2f0c,$2f0b,$2f0a,$2f09
	Dc.w	$2f08,$2f07,$2f06,$2f05,$2f04,$2f03,$2f02
	Dc.w	$2f01,$2f00
 	Dc.w	$2f00,$2e00,$2d00,$2c00,$2b00,$2a00,$2900
	Dc.w	$2800,$2700,$2600,$2500,$2400,$2300,$2200
	Dc.w	$2100,$2000
	Dc.w	$1f00,$1e00,$1d00,$1c00,$1b00,$1a00,$1900
	Dc.w	$1800,$1700,$1600,$1500,$1400,$1300,$1200
	Dc.w	$1100,$1000
	Dc.w	$0f00,$0e00,$0d00,$0c00,$0b00,$0a00,$0900
	Dc.w	$0800,$0700,$0600,$0500,$0400,$0300,$0200
	Dc.w	$0100,$0000
	Dc.w	$ffff
	Even
GFXlib	DC.B 	"graphics.library"
GFXbase	DC.L 	0
Save182	Dc.l	0
*****************************************************
	END










