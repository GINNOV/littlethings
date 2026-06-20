

* Data structures include file for Defender.


Anim1_1		dc.l	Anim1_2
		dc.l	Anim1_2

		dc.l	A1FF1,A1FF1

		dc.w	160,128
		dc.w	_AL_CRAFT	;ship ID = 0
		dc.b	0,0
		
		dc.l	0,0,0,0		;blitprecomps
		dc.w	0,0,0,0
		dc.w	0,0,0
		dc.w	0,0,0,0
		dc.w	0

		dc.w	0		;score
		dc.w	0,0		;movement
		dc.w	0,0		;cnts
		dc.l	ShipCode		;SpecialCode
		dc.l	0		;KidnapPtr
		dc.l	0		;tmp KidnapPtr
		dc.w	0		;Bomber
		dc.w	7,4		;coll offsets
		dc.w	0,0
		dc.w	0		;laser collision
		dc.w	0		;generic
		dc.l	0		;scanloc
		dc.w	0,0		;scanbits
		dc.w	-1,0		;scanmasks
		dc.b	0,0		;flags & dummy


Anim1_2		dc.l	Anim1_1
		dc.l	Anim1_1

		dc.l	A2FF1,A2FF1

		dc.w	153,131
		dc.w	_AL_FLAME	;flame ID = 1
		dc.b	0,0
		
		dc.l	0,0,0,0		;blitprecomps
		dc.w	0,0,0,0
		dc.w	0,0,0
		dc.w	0,0,0,0
		dc.w	0

		dc.w	0		;score etc
		dc.w	0,0
		dc.w	0,0
		dc.l	0		;SpecialCode
		dc.l	0
		dc.l	0
		dc.w	0
		dc.w	0,0
		dc.w	0,0
		dc.w	0		;laser collision
		dc.w	0
		dc.l	0
		dc.w	0,0
		dc.w	-1,0
		dc.b	0,0		;flags


Anim2_1		dc.l	Anim2_2
		dc.l	Anim2_2

		dc.l	A1FF1,A1FF1

		dc.w	160,128
		dc.w	_AL_CRAFT	;ship ID = 0
		dc.b	0,0
		
		dc.l	0,0,0,0		;blitprecomps
		dc.w	0,0,0,0
		dc.w	0,0,0
		dc.w	0,0,0,0
		dc.w	0

		dc.w	0		;score
		dc.w	0,0		;movement
		dc.w	0,0		;cnts
		dc.l	ShipCode		;SpecialCode
		dc.l	0		;KidnapPtr
		dc.l	0		;tmp KidnapPtr
		dc.w	0		;Bomber
		dc.w	7,4		;coll offsets
		dc.w	0,0
		dc.w	0		;laser collision
		dc.w	0		;generic
		dc.l	0		;scanloc
		dc.w	0,0		;scanbits
		dc.w	-1,0		;scanmasks
		dc.b	0,0		;flags & dummy


Anim2_2		dc.l	Anim2_1
		dc.l	Anim2_1

		dc.l	A2FF1,A2FF1

		dc.w	153,131
		dc.w	_AL_FLAME	;flame ID = 1
		dc.b	0,0
		
		dc.l	0,0,0,0		;blitprecomps
		dc.w	0,0,0,0
		dc.w	0,0,0
		dc.w	0,0,0,0
		dc.w	0

		dc.w	0		;score etc
		dc.w	0,0
		dc.w	0,0
		dc.l	0		;SpecialCode
		dc.l	0
		dc.l	0
		dc.w	0
		dc.w	0,0
		dc.w	0,0
		dc.w	0		;laser collision
		dc.w	0
		dc.l	0
		dc.w	0,0
		dc.w	-1,0
		dc.b	0,0		;flags


Anim1_3		ds.b	AO_Sizeof*120


Anim2_3		ds.b	AO_Sizeof*120


* Ship animation frames:forward set


A1FF1		dc.l	A1FF2,A1FF3

		dc.l	ASF1_G
		dc.l	ASF_M

		dc.w	8,1
		dc.w	0,0

A1FF2		dc.l	A1FF3,A1FF1

		dc.l	ASF2_G
		dc.l	ASF_M

		dc.w	8,1
		dc.w	0,0

A1FF3		dc.l	A1FF1,A1FF2

		dc.l	ASF3_G
		dc.l	ASF_M

		dc.w	8,1
		dc.w	0,0


* Ship animation frames:reverse set


A1RF1		dc.l	A1RF2,A1RF3

		dc.l	ASR1_G
		dc.l	ASR_M

		dc.w	8,1
		dc.w	0,0

A1RF2		dc.l	A1RF3,A1RF1

		dc.l	ASR2_G
		dc.l	ASR_M

		dc.w	8,1
		dc.w	0,0

A1RF3		dc.l	A1RF1,A1RF2

		dc.l	ASR3_G
		dc.l	ASR_M

		dc.w	8,1
		dc.w	0,0


* Flame animation frames:forward set


A2FF1		dc.l	A2FF2,A2FF2

		dc.l	AFF1_G
		dc.l	AFF1_M

		dc.w	3,1
		dc.w	2,1

A2FF2		dc.l	A2FF1,A2FF1

		dc.l	AFF2_G
		dc.l	AFF2_M

		dc.w	5,1
		dc.w	-2,-1


* Flame animation frames:reverse set


A2RF1		dc.l	A2RF2,A2RF2

		dc.l	AFR1_G
		dc.l	AFR1_M

		dc.w	3,1
		dc.w	0,1

A2RF2		dc.l	A2RF1,A2RF1

		dc.l	AFR2_G
		dc.l	AFR2_M

		dc.w	5,1
		dc.w	0,-1


* Various creature animframes. 1st frame = object's normal appearance,
* subsequent frames are explosion frames (except pod which doesn't
* have explosion).


A3F1		dc.l	A3F2,A3F2

		dc.l	A1F1_G		;lander
		dc.l	A1F1_M

		dc.w	11,1
		dc.w	0,0

A3F2		dc.l	A3F3,A3F3

		dc.l	XPL1_1G
		dc.l	XPL1_1M

		dc.w	11,1
		dc.w	0,0

A3F3		dc.l	A3F4,A3F4

		dc.l	XPL1_2G
		dc.l	XPL1_2M

		dc.w	9,1
		dc.w	0,1

A3F4		dc.l	A3F5,A3F5

		dc.l	XPL1_3G
		dc.l	XPL1_3M

		dc.w	7,1
		dc.w	0,1

A3F5		dc.l	A3F6,A3F6

		dc.l	XPL1_4G
		dc.l	XPL1_4M

		dc.w	5,1
		dc.w	0,1

A3F6		dc.l	A3F6,A3F6

		dc.l	XPL1_5G
		dc.l	XPL1_5M

		dc.w	3,1
		dc.w	0,1


A4F1		dc.l	A4F2,A4F2

		dc.l	A2F1_G		;mutant
		dc.l	A2F1_M

		dc.w	12,1
		dc.w	0,0

A4F2		dc.l	A4F3,A4F3

		dc.l	XPL2_1G
		dc.l	XPL2_1M

		dc.w	11,1
		dc.w	0,0

A4F3		dc.l	A4F4,A4F4

		dc.l	XPL2_2G
		dc.l	XPL2_2M

		dc.w	9,1
		dc.w	0,1

A4F4		dc.l	A4F5,A4F5

		dc.l	XPL2_3G
		dc.l	XPL2_3M

		dc.w	7,1
		dc.w	1,1

A4F5		dc.l	A4F6,A4F6

		dc.l	XPL2_4G
		dc.l	XPL2_4M

		dc.w	5,1
		dc.w	1,1

A4F6		dc.l	A4F6,A4F6

		dc.l	XPL2_5G
		dc.l	XPL2_5M

		dc.w	3,1
		dc.w	1,1


A5F1		dc.l	A5F2,A5F2

		dc.l	A3F1_G		;bomber
		dc.l	A3F1_M

		dc.w	7,1
		dc.w	0,0

A5F2		dc.l	A5F3,A5F3

		dc.l	XPL3_1G
		dc.l	A3F1_M

		dc.w	7,1
		dc.w	0,0

A5F3		dc.l	A5F4,A5F4

		dc.l	XPL3_2G
		dc.l	A3F1_M

		dc.w	7,1
		dc.w	0,0

A5F4		dc.l	A5F5,A5F5

		dc.l	XPL3_3G
		dc.l	A3F1_M

		dc.w	7,1
		dc.w	0,0

A5F5		dc.l	A5F6,A5F6

		dc.l	XPL3_4G
		dc.l	XPL3_4M

		dc.w	7,1
		dc.w	0,0

A5F6		dc.l	A5F6,A5F6

		dc.l	XPL3_5G
		dc.l	XPL3_5M

		dc.w	7,1
		dc.w	0,0


A6F1		dc.l	A6F2,A6F2

		dc.l	A4F1_G		;baiter
		dc.l	A4F1_M

		dc.w	3,1
		dc.w	0,0

A6F2		dc.l	A6F3,A6F3

		dc.l	XPL4_1G
		dc.l	XPL4_1M

		dc.w	5,1
		dc.w	0,-1

A6F3		dc.l	A6F4,A6F4

		dc.l	XPL4_2G
		dc.l	XPL4_2M

		dc.w	7,1
		dc.w	0,-1

A6F4		dc.l	A6F5,A6F5

		dc.l	XPL4_3G
		dc.l	XPL4_3M

		dc.w	1,1
		dc.w	0,3

A6F5		dc.l	A6F5,A6F5

		dc.l	XPL4_4G
		dc.l	XPL4_4M

		dc.w	1,1
		dc.w	0,0


A7F1		dc.l	A7F2,A7F2

		dc.l	A5F1_G		;swarmer
		dc.l	A5F1_M

		dc.w	5,1
		dc.w	0,0

A7F2		dc.l	A7F3,A7F3

		dc.l	XPL5_1G
		dc.l	A5F1_M

		dc.w	5,1
		dc.w	0,0

A7F3		dc.l	A7F4,A7F4

		dc.l	XPL5_2G
		dc.l	A5F1_M

		dc.w	5,1
		dc.w	0,0

A7F4		dc.l	A7F5,A7F5

		dc.l	XPL5_3G
		dc.l	A5F1_M

		dc.w	5,1
		dc.w	0,0

A7F5		dc.l	A7F5,A7F5

		dc.l	XPL5_4G
		dc.l	A5F1_M

		dc.w	5,1
		dc.w	0,0


A8F1		dc.l	A8F1,A8F1

		dc.l	A6F1_G		;pod
		dc.l	A6F1_M

		dc.w	11,1
		dc.w	0,0


A9F1		dc.l	A9F1,A9F1

		dc.l	A7F1_G		;body
		dc.l	A7F1_M

		dc.w	9,1
		dc.w	0,0


* Animation frames for the PowerUps.


PUF1		dc.l	PUF1,PUF1

		dc.l	POWG1
		dc.l	POWM

		dc.w	7,1
		dc.w	0,0


PUF2		dc.l	PUF2,PUF2

		dc.l	POWG2
		dc.l	POWM

		dc.w	7,1
		dc.w	0,0


PUF3		dc.l	PUF3,PUF3

		dc.l	POWG3
		dc.l	POWM

		dc.w	7,1
		dc.w	0,0


PUF4		dc.l	PUF4,PUF4

		dc.l	POWG4
		dc.l	POWM

		dc.w	7,1
		dc.w	0,0


* AnimFrames for the Missile.


MISF		dc.l	MISF,MISF

		dc.l	AAMF_G
		dc.l	AAMF_M

		dc.w	7,1
		dc.w	0,0


MISR		dc.l	MISR,MISR

		dc.l	AAMR_G
		dc.l	AAMR_M

		dc.w	7,1
		dc.w	0,0



* This is the conversion table for ASCII chars to charset chars
* starting at ASCII 32


CTab1		dc.b	36,36,36,36	;32
		dc.b	36,36,36,36	;36
		dc.b	36,36,36,36	;40
		dc.b	36,36,36,36	;44
		dc.b	0,1,2,3		;48
		dc.b	4,5,6,7		;52
		dc.b	8,9,36,36	;56
		dc.b	36,36,36,36	;60
		dc.b	36,10,11,12	;64
		dc.b	13,14,15,16	;68
		dc.b	17,18,19,20	;72
		dc.b	21,22,23,24	;76
		dc.b	25,26,27,28	;80
		dc.b	29,30,31,32	;84
		dc.b	33,34,35,36	;88
		dc.b	36,36,36,36	;92
		dc.b	36,10,11,12	;96
		dc.b	13,14,15,16	;100
		dc.b	17,18,19,20	;104
		dc.b	21,22,23,24	;108
		dc.b	25,26,27,28	;112
		dc.b	29,30,31,32	;116
		dc.b	33,34,35,36	;120
		dc.b	36,36,36,36	;124


* This conversion table is valid for UK Amigas only. It maps raw
* key codes onto ASCII codes. Raw key code is index into this table
* and value indexed is ASCII code. Intel 80x86 owners needn't get
* smug about using XLAT - I can use any address reg and index reg
* I like! Special key mappings are:

* Function keys:rawkey code + $80
* Cursor keys:rawkey code + $90
* HELP:$A0
* Nonexistent keys:$FF
* Return/ENTER:$0D
* Backspace:$08
* ESC:$1B


CTab2		dc.b	"'","1","2","3","4","5","6","7"
		dc.b	"8","9","0","-","=","\",$FF,"0"	;00-0F
		dc.b	"q","w","e","r","t","y","u","i"
		dc.b	"o","p","[","]",$FF,"1","2","3"	;10-1F
		dc.b	"a","s","d","f","g","h","j","k"
		dc.b	"l",";","#",$0D,$FF,"4","5","6"	;20-2F
		dc.b	$FF,"z","x","c","v","b","n","m"
		dc.b	"<",">","/",$FF,".","7","8","9"	;30-3F
		dc.b	" ",$08,$FF,$0D,$0D,$1B,$7F,$FF
		dc.b	$FF,$FF,"-",$FF,$90,$91,$92,$93	;40-4F
		dc.b	$80,$81,$82,$83,$84,$85,$86,$87
		dc.b	$88,$89,"(",")","/","*","+",$A0	;50-5F

		dc.b	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
		dc.b	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF	;60-6F

		dc.b	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
		dc.b	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF	;70-7F


* Colour cycles


FlashTab		dc.w	$0C4C,$0C5C,$0C6C,$0C7C
		dc.w	$0C8C,$0C9C,$0CAC,$0CBC

		dc.w	$0CCC,$0CCB,$0CCA,$0CC9
		dc.w	$0CC8,$0CC7,$0CC6,$0CC5

		dc.w	$0CC4,$0CB4,$0CA4,$0C94
		dc.w	$0C84,$0C74,$0C64,$0C54

		dc.w	$0C44,$0B45,$0A46,$0947
		dc.w	$0848,$0749,$064A,$054B

		dc.w	$044C,$045C,$046C,$047C
		dc.w	$048C,$049C,$04AC,$04BC

		dc.w	$04CC,$04CB,$04CA,$04C9
		dc.w	$04C8,$04C7,$04C6,$04C5

		dc.w	$04C4,$05C4,$06C4,$07C4
		dc.w	$08C4,$09C4,$0AC4,$0BC4

		dc.w	$0CC4,$0CB5,$0CA6,$0C97
		dc.w	$0C88,$0C79,$0C6A,$0C5B


* Initial keyboard/joystick states for players. Order is:
* variable offset, value, mask.


_KeyPrefs	dc.l	JoyPos			;ship up
		dc.b	1,$7F

		dc.l	JoyPos			;ship down
		dc.b	2,$7F

		dc.l	ShiftKey			;thrust
		dc.b	_SK_LSHIFT,_SK_LSHIFT

		dc.l	JoyButton		;fire
		dc.b	$FF,$FF

		dc.l	ShiftKey			;reverse
		dc.b	_SK_LALT,_SK_LALT

		dc.l	ShiftKey			;smart bomb
		dc.b	_SK_CTRL,_SK_CTRL


* Password Colours


__PWColours	dc.w	$0060,$0066,$0600,$0660


* Set of initialisers for PlayerData. Pointer to them set in
* the PlayerData structure by InitVars.


__P1Init		dc.w	10,26,42,58,0

__P2Init		dc.w	238,254,270,286,0


* SpecialValues array for InitSet(). Contains:

* Points, XMove, YMove, XOff, YOff, XDisp, YDisp,
* YLDisp, ScanMsk1, ScanMsk2, SpecialCodePtr

* in that order. IF CHANGES MADE, MODIFY IMMEDIATE IN InitSet()!


SVArray		dc.w	100,2,0,5,5,12,9,5,0,-1
		dc.l	LanderCode
		dc.w	150,2,0,5,6,12,10,6,-1,0
		dc.l	MutantCode
		dc.w	250,2,0,3,3,10,7,3,-1,0
		dc.l	BomberCode
		dc.w	200,2,0,6,1,13,5,1,0,-1
		dc.l	BaiterCode
		dc.w	150,2,0,3,2,10,6,2,-1,-1
		dc.l	SwarmerCode
		dc.w	1000,2,0,5,5,12,9,5,-1,-1
		dc.l	PodCode


* Baiter initial 'alarm clock' settings for 1st 16 levels (further
* levels use level 16's value) as referenced by InitPlayer(). Time
* limits shrink until level 10, and then increase to allow more time
* to kill the increased hordes. Also, the timings cycle back every
* 16 levels AND have a random displacement added on to them just for
* good measure...


_BIASet		dc.w	$1200,$1100,$1000,$0E00
		dc.w	$0C00,$0A00,$0900,$0880
		dc.w	$0800,$0780,$0780,$0800
		dc.w	$0880,$0900,$0900,$0900


* Initialiser array for split swarmers. Values are, in order:
* XMove, YMove, Generic, AnimFlags, AOFlags


SSIArray		dc.w	-4,3,4
		dc.b	_ANF_SAMEFRAME,_AOF_ERUPT
		dc.w	3,1,3
		dc.b	_ANF_SAMEFRAME,_AOF_ERUPT
		dc.w	-2,-4,4
		dc.b	_ANF_SAMEFRAME,_AOF_ERUPT
		dc.w	1,4,2
		dc.b	_ANF_SAMEFRAME,_AOF_ERUPT
		dc.w	3,-1,4
		dc.b	_ANF_SAMEFRAME,_AOF_ERUPT
		dc.w	-4,-2,3
		dc.b	_ANF_SAMEFRAME,_AOF_ERUPT
		dc.w	-1,-2,4
		dc.b	_ANF_SAMEFRAME,_AOF_ERUPT
		dc.w	3,4,2
		dc.b	_ANF_SAMEFRAME,_AOF_ERUPT

		dc.w	-1,3,2
		dc.b	_ANF_SAMEFRAME,_AOF_ERUPT
		dc.w	2,-2,3
		dc.b	_ANF_SAMEFRAME,_AOF_ERUPT
		dc.w	-1,-4,3
		dc.b	_ANF_SAMEFRAME,_AOF_ERUPT
		dc.w	3,1,2
		dc.b	_ANF_SAMEFRAME,_AOF_ERUPT
		dc.w	-2,2,4
		dc.b	_ANF_SAMEFRAME,_AOF_ERUPT
		dc.w	4,-2,4
		dc.b	_ANF_SAMEFRAME,_AOF_ERUPT
		dc.w	-2,4,2
		dc.b	_ANF_SAMEFRAME,_AOF_ERUPT
		dc.w	-2,-1,3
		dc.b	_ANF_SAMEFRAME,_AOF_ERUPT


* Y-table for y-coordinate to address offset computations.
* Initialised algorithmically.


_YTab		ds.w	256


* Collision list. Pointers to all objects that have collided with
* another are slotted into this array. 


__CList		ds.l	200		;safety margin


* Bomber Lists. 1st list = initial x positions & x speeds for
* Bombers


BList1		dc.w	500,4
		dc.w	508,4
		dc.w	492,4
		dc.w	1000,-4
		dc.w	1008,-4
		dc.w	992,-4
		dc.w	1500,4
		dc.w	1506,4


* 2nd list = y values for a plotted curve along which the
* Bombers will fly. This curve is redefined each time a
* new attack wave is launched. Curve formed from the
* equation:

* y = A sin(x) + B sin(2x) + C sin(3x)


BList2		ds.w	_CURVECOUNT


* Landscape list #1. Generated by the NewLSList() function each time.


__LandL1		ds.b	512


* Landscape List 2.


__LandL2		ds.w	512


* Repeats for Player 2.


__LandL3		ds.b	512

__LandL4		ds.w	512


* Attack Wave array. Numbers are. in the following order:

* landers, mutants, bombers, baiters, swarmers, pods

* NOTE : swarmers are initially disabled. They only become
* active once the pod has been hit.

* Highest attack wave = 15.


AWArray		dc.w	10,0,0,0,0,0
		dc.w	10,0,0,0,0,0
		dc.w	12,0,3,0,10,1
		dc.w	14,0,5,0,30,3
		dc.w	16,0,5,0,30,3
		dc.w	18,0,5,0,30,3
		dc.w	20,0,5,0,30,3
		dc.w	20,0,5,0,30,3

		dc.w	22,0,7,0,50,5
		dc.w	24,0,7,0,50,5
		dc.w	26,0,7,0,50,5
		dc.w	26,0,7,0,50,5
		dc.w	28,0,7,0,50,5
		dc.w	28,0,7,0,50,5
		dc.w	30,0,7,0,50,5
		dc.w	30,0,7,0,50,5


* Tab settings for score display, 1st = Player 1, 2nd = Player 2


__TS1		dc.w	82,74,66,58,50
		dc.w	42,34,26,18,10

__TS2		dc.w	302,294,286,278,270
		dc.w	262,254,246,238,230


XBuf		ds.b	32


* Normalised sine table. Table of values of 32768*sin(X) for use
* by my custom sine routine.


__Sine1		dc.w	$0000,$0192,$0324,$04B6	;0 deg section
		dc.w	$0648,$07D9,$096B,$0AFB
		dc.w	$0C8C,$0E1C,$0FAB,$113A
		dc.w	$12C8,$1455,$15E2,$176E
		dc.w	$18F9,$1A83,$1C0C,$1D93
		dc.w	$1F1A,$209F,$2224,$23A7
		dc.w	$2528,$26A8,$2827,$29A4
		dc.w	$2B1F,$2C99,$2E11,$2F87
		dc.w	$30FC,$326E,$33DF,$354E
		dc.w	$36BA,$3825,$398D,$3AF3
		dc.w	$3C57,$3DB8,$3F17,$4074
		dc.w	$41CE,$4326,$447B,$45CD
		dc.w	$471D,$486A,$49B4,$4AFB
		dc.w	$4C40,$4D81,$4EC0,$4FFB
		dc.w	$5134,$5269,$539B,$54CA
		dc.w	$55F6,$571E,$5843,$5964

		dc.w	$5A82,$5B9D,$5CB4,$5DC8	;45 deg section
		dc.w	$5ED7,$5FE4,$60EC,$61F1
		dc.w	$62F2,$63EF,$64E9,$65DE
		dc.w	$66D0,$67BD,$68A7,$698C
		dc.w	$6A6E,$6B4B,$6C24,$6CF9
		dc.w	$6DCA,$6E97,$6F5F,$7023
		dc.w	$70E3,$719E,$7255,$7308
		dc.w	$73B6,$7460,$7505,$75A6
		dc.w	$7642,$76D9,$776C,$77FB
		dc.w	$7885,$790A,$798A,$7A06
		dc.w	$7A7D,$7AEF,$7B5D,$7BC6
		dc.w	$7C2A,$7C89,$7CE4,$7D3A
		dc.w	$7D8A,$7DD6,$7E1E,$7E60
		dc.w	$7E9D,$7ED6,$7F0A,$7F38
		dc.w	$7F62,$7F87,$7FA7,$7FC2
		dc.w	$7FD9,$7FEA,$7FF6,$7FFE

		dc.w	$8000,$7FFE,$7FF6,$7FEA	;90 deg section
		dc.w	$7FD9,$7FC2,$7FA7,$7F87
		dc.w	$7F62,$7F38,$7F0A,$7ED6
		dc.w	$7E9D,$7E60,$7E1E,$7DD6
		dc.w	$7D8A,$7D3A,$7CE4,$7C89
		dc.w	$7C2A,$7BC6,$7B5D,$7AEF
		dc.w	$7A7D,$7A06,$798A,$790A
		dc.w	$7885,$77FB,$776C,$76D9
		dc.w	$7642,$75A6,$7505,$7460
		dc.w	$73B6,$7308,$7255,$719E
		dc.w	$70E3,$7023,$6F5F,$6E97
		dc.w	$6DCA,$6CF9,$6C24,$6B4B
		dc.w	$6A6E,$698C,$68A7,$67BD
		dc.w	$66D0,$65DE,$64E9,$63EF
		dc.w	$62F2,$61F1,$60EC,$5FE4
		dc.w	$5ED7,$5DC8,$5CB4,$5B9D

		dc.w	$5A82,$5964,$5843,$571E	;135 deg section
		dc.w	$55F6,$54CA,$539B,$5269
		dc.w	$5134,$4FFB,$4EC0,$4D81
		dc.w	$4C40,$4AFB,$49B4,$486A
		dc.w	$471D,$45CD,$447B,$4326
		dc.w	$41CE,$4074,$3F17,$3DB8
		dc.w	$3C57,$3AF3,$398D,$3825
		dc.w	$36BA,$354E,$33DF,$326E
		dc.w	$30FC,$2F87,$2E11,$2C99
		dc.w	$2B1F,$29A4,$2827,$26A8
		dc.w	$2528,$23A7,$2224,$209F
		dc.w	$1F1A,$1D93,$1C0C,$1A83
		dc.w	$18F9,$176E,$15E2,$1455
		dc.w	$12C8,$113A,$0FAB,$0E1C
		dc.w	$0C8C,$0AFB,$096B,$07D9
		dc.w	$0648,$04B6,$0324,$0192

		dc.w	$0000,$FE6E,$FCDC,$FB4A	;180 deg section
		dc.w	$F9B8,$F827,$F695,$F505
		dc.w	$F374,$F1E4,$F055,$EEC6
		dc.w	$ED38,$EBAB,$EA1E,$E892
		dc.w	$E707,$E57D,$E3F5,$E26D
		dc.w	$E0E6,$DF61,$DDDC,$DC59
		dc.w	$DAD8,$D958,$D7D9,$D65C
		dc.w	$D4E1,$D367,$D1EF,$D079
		dc.w	$CF04,$CD92,$CC21,$CAB2
		dc.w	$C946,$C7DB,$C673,$C50D
		dc.w	$C3A9,$C248,$C0E9,$BF8C
		dc.w	$BE32,$BCDA,$BB85,$BA33
		dc.w	$B8E3,$B796,$B64C,$B505
		dc.w	$B3C0,$B27F,$B140,$B005
		dc.w	$AECC,$AD97,$AC65,$AB36
		dc.w	$AA0A,$A8E2,$A7BD,$A69C

		dc.w	$A57E,$A463,$A34C,$A238	;225 deg section
		dc.w	$A129,$A01C,$9F14,$9E0F
		dc.w	$9D0E,$9C11,$9B17,$9A22
		dc.w	$9931,$9843,$9759,$9674
		dc.w	$9592,$94B5,$93DC,$9307
		dc.w	$9236,$9169,$90A1,$8FDD
		dc.w	$8F1D,$8E62,$8DAB,$8CF8
		dc.w	$8C4A,$8BA0,$8AFB,$8A5A
		dc.w	$89BE,$8927,$8894,$8805
		dc.w	$877B,$86F6,$8676,$85FA
		dc.w	$8583,$8511,$84A3,$843A
		dc.w	$83D6,$8377,$831C,$82C7
		dc.w	$8276,$822A,$81E2,$81A0
		dc.w	$8163,$812A,$80F6,$80C8
		dc.w	$809E,$8079,$8059,$803E
		dc.w	$8027,$8016,$800A,$8002

		dc.w	$8000,$8002,$800A,$8016	;270 deg section
		dc.w	$8027,$803E,$8059,$8079
		dc.w	$809E,$80C8,$80F6,$812A
		dc.w	$8163,$81A0,$81E2,$822A
		dc.w	$8276,$82C6,$831C,$8377
		dc.w	$83D6,$843A,$84A3,$8511
		dc.w	$8583,$85FA,$8676,$86F6
		dc.w	$877B,$8805,$8894,$8927
		dc.w	$89BE,$8A5A,$8AFB,$8BA0
		dc.w	$8C4A,$8CF8,$8DAB,$8E62
		dc.w	$8F1D,$8FDD,$90A1,$9169
		dc.w	$9236,$9307,$93DC,$94B5
		dc.w	$9592,$9674,$9759,$9843
		dc.w	$9930,$9A22,$9B17,$9C11
		dc.w	$9D0E,$9E0F,$9F14,$A01C
		dc.w	$A128,$A238,$A34C,$A463

		dc.w	$A57E,$A69C,$A7BD,$A8E2	;315 deg section
		dc.w	$AA0A,$AB36,$AC65,$AD97
		dc.w	$AECC,$B005,$B140,$B27F
		dc.w	$B3C0,$B505,$B64C,$B796
		dc.w	$B8E3,$BA33,$BB85,$BCDA
		dc.w	$BE32,$BF8C,$C0E9,$C248
		dc.w	$C3A9,$C50D,$C673,$C7DB
		dc.w	$C946,$CAB2,$CC21,$CD92
		dc.w	$CF04,$D079,$D1EF,$D367
		dc.w	$D4E1,$D65C,$D7D9,$D958
		dc.w	$DAD8,$DC59,$DDDC,$DF61
		dc.w	$E0E6,$E26D,$E3F4,$E57D
		dc.w	$E707,$E892,$EA1E,$EBAA
		dc.w	$ED38,$EEC6,$F055,$F1E4
		dc.w	$F374,$F505,$F695,$F827
		dc.w	$F9B8,$FB4A,$FCDC,$FE6E


* End of fractional sine table. Integer sines follow.


__Sine2		dc.w	0,1,0,-1		;sine of 0, 90, 180, 270 deg.


* Today's Greatest High Scores


TDG_Array	dc.l	2500
		dc.b	"DWE",0
		dc.l	2250
		dc.b	"M M",0
		dc.l	2000
		dc.b	"MJC",0
		dc.l	1750
		dc.b	"S M",0
		dc.l	1500
		dc.b	"ABC",0
		dc.l	1000
		dc.b	"XYZ",0
		dc.l	750
		dc.b	"PIG",0
		dc.l	600
		dc.b	"NUT",0
		dc.l	500
		dc.b	"ACE",0
		dc.l	400
		dc.b	"BIN",0


* All Time Greatest High Scores


ATG_Array	dc.l	2500
		dc.b	"DWE",0
		dc.l	2250
		dc.b	"M M",0
		dc.l	2000
		dc.b	"MJC",0
		dc.l	1750
		dc.b	"S M",0
		dc.l	1500
		dc.b	"ABC",0
		dc.l	1000
		dc.b	"XYZ",0
		dc.l	750
		dc.b	"PIG",0
		dc.l	600
		dc.b	"NUT",0
		dc.l	500
		dc.b	"ACE",0
		dc.l	400
		dc.b	"BIN",0


* DeathList workspace


__DthLst		ds.w	_DTHLSTSZ*3+1


* List of sprite pointers for Scanner (more work for InitVars() !!)


__SLst		ds.l	6		;6 sprites used


* Table 1 for scanner plotting. Each entry is a byte, low nibble=offset
* into sprite ptr list, high nibble = bit number. Uses (x/16) as index
* into table. This is the revised scanner table that makes the scanner
* tidy!


__SPTH		dc.b	$E2,$D2,$B2,$A2,$82,$72,$52,$42
		dc.b	$22,$12,$E3,$D3,$B3,$A3,$83,$73
		dc.b	$53,$43,$23,$13,$13,$03,$03,$03
		dc.b	$03,$03,$03,$03,$F4,$F4,$F4,$F4
		dc.b	$F4,$F4,$F4,$F4,$E4,$E4,$E4,$E4
		dc.b	$E4,$E4,$E4,$D4,$D4,$D4,$D4,$D4
		dc.b	$D4,$D4,$D4,$C4,$C4,$C4,$C4,$C4
		dc.b	$C4,$C4,$B4,$B4,$B4,$B4,$B4,$B4

		dc.b	$B4,$B4,$A4,$A4,$A4,$A4,$A4,$A4
		dc.b	$A4,$94,$94,$94,$94,$94,$94,$94
		dc.b	$94,$84,$84,$84,$84,$84,$84,$84
		dc.b	$74,$74,$74,$74,$74,$74,$74,$74
		dc.b	$64,$64,$64,$64,$64,$64,$64,$54
		dc.b	$54,$54,$54,$54,$54,$54,$54,$44
		dc.b	$44,$44,$44,$44,$44,$44,$34,$34
		dc.b	$34,$34,$34,$34,$34,$34,$24,$24

		dc.b	$24,$24,$24,$24,$24,$14,$14,$14
		dc.b	$14,$14,$14,$14,$14,$04,$04,$04
		dc.b	$04,$04,$04,$04,$F5,$F5,$F5,$F5
		dc.b	$F5,$F5,$F5,$F5,$E5,$E5,$E5,$E5
		dc.b	$E5,$E5,$E5,$D5,$D5,$D5,$D5,$D5
		dc.b	$D5,$D5,$D5,$C5,$C5,$C5,$C5,$C5
		dc.b	$C5,$C5,$B5,$B5,$B5,$B5,$B5,$B5
		dc.b	$B5,$B5,$A5,$A5,$A5,$A5,$A5,$A5

		dc.b	$A5,$95,$95,$95,$95,$95,$95,$95
		dc.b	$95,$85,$85,$85,$85,$85,$85,$85
		dc.b	$75,$75,$75,$75,$75,$75,$75,$75
		dc.b	$65,$65,$65,$65,$65,$65,$65,$55
		dc.b	$55,$55,$55,$55,$55,$55,$55,$45
		dc.b	$45,$45,$45,$45,$45,$45,$35,$35
		dc.b	$35,$35,$35,$35,$35,$35,$25,$25
		dc.b	$25,$25,$25,$25,$25,$15,$15,$15

		dc.b	$15,$15,$15,$15,$15,$05,$05,$05
		dc.b	$05,$05,$05,$05,$05,$F0,$F0,$F0
		dc.b	$F0,$F0,$F0,$F0,$E0,$E0,$E0,$E0
		dc.b	$E0,$E0,$E0,$E0,$D0,$D0,$D0,$D0
		dc.b	$D0,$D0,$D0,$C0,$C0,$C0,$C0,$C0
		dc.b	$C0,$C0,$C0,$B0,$B0,$B0,$B0,$B0
		dc.b	$B0,$B0,$A0,$A0,$A0,$A0,$A0,$A0
		dc.b	$A0,$A0,$90,$90,$90,$90,$90,$90

		dc.b	$90,$80,$80,$80,$80,$80,$80,$80
		dc.b	$80,$70,$70,$70,$70,$70,$70,$70
		dc.b	$60,$60,$60,$60,$60,$60,$60,$60
		dc.b	$50,$50,$50,$50,$50,$50,$50,$40
		dc.b	$40,$40,$40,$40,$40,$40,$40,$30
		dc.b	$30,$30,$30,$30,$30,$30,$20,$20
		dc.b	$20,$20,$20,$20,$20,$20,$10,$10
		dc.b	$10,$10,$10,$10,$10,$00,$00,$00

		dc.b	$00,$00,$00,$00,$00,$F1,$F1,$F1
		dc.b	$F1,$F1,$F1,$F1,$E1,$E1,$E1,$E1
		dc.b	$E1,$E1,$E1,$E1,$D1,$D1,$D1,$D1
		dc.b	$D1,$D1,$D1,$C1,$C1,$C1,$C1,$C1
		dc.b	$C1,$C1,$C1,$B1,$B1,$B1,$B1,$B1
		dc.b	$B1,$B1,$A1,$A1,$A1,$A1,$A1,$A1
		dc.b	$A1,$A1,$91,$91,$91,$91,$91,$91
		dc.b	$91,$81,$81,$81,$81,$81,$81,$81

		dc.b	$81,$71,$71,$71,$71,$71,$71,$71
		dc.b	$61,$61,$61,$61,$61,$61,$61,$61
		dc.b	$51,$51,$51,$51,$51,$51,$51,$41
		dc.b	$41,$41,$41,$41,$41,$41,$41,$31
		dc.b	$31,$31,$31,$31,$31,$31,$21,$21
		dc.b	$21,$21,$21,$21,$21,$21,$11,$11
		dc.b	$11,$11,$11,$11,$11,$01,$01,$01
		dc.b	$01,$01,$01,$01,$01,$F2,$F2,$F2


* This scanner table indexed by y coord (y-MIN_SY). So far, 130
* entries. More needed if RNG_SY changes! Code multiplies
* entry by 4 to add to sprite data ptr offset.


__SPTV		dc.b	0,0,0,0,0,1,1,1
		dc.b	1,1,2,2,2,2,2,3
		dc.b	3,3,3,3,4,4,4,4
		dc.b	4,5,5,5,5,5,6,6

		dc.b	6,6,6,7,7,7,7,7
		dc.b	8,8,8,8,8,9,9,9
		dc.b	9,9,10,10,10,10,10,11
		dc.b	11,11,11,11,12,12,12,12

		dc.b	12,13,13,13,13,13,14,14
		dc.b	14,14,14,15,15,15,15,15
		dc.b	16,16,16,16,16,17,17,17
		dc.b	17,17,18,18,18,18,18,19

		dc.b	19,20,20,20,20,20,21,21
		dc.b	21,21,21,22,22,22,22,22
		dc.b	23,23,23,23,23,24,24,24
		dc.b	24,24,25,25,25,25,25,26

		dc.b	26,26,26,26,27,27,27,27
		dc.b	27,28,28,28,28,28,28,28
		dc.b	27,28,28,28,28,28,28,28
		dc.b	27,28,28,28,28,28,28,28


* LtoA conversion buffer


__LACB		ds.b	64


* Keyboard buffer


__KBBUF		ds.b	64


* Mine/Missile Arrays


_MArr1		ds.b	md_Sizeof*_MA_SIZE

_MArr2		ds.b	_MA_SIZE


* Some texts


Txt1_1		dc.b	"lander",0
Txt1_2		dc.b	"100 pts",0

Txt2_1		dc.b	"Mutant",0
Txt2_2		dc.b	"150 pts",0

Txt3_1		dc.b	"bomber",0
Txt3_2		dc.b	"250 pts",0

Txt4_1		dc.b	"baiter",0
Txt4_2		dc.b	"200 pts",0

Txt5_1		dc.b	"swarmer",0
Txt5_2		dc.b	"150 pts",0

Txt6_1		dc.b	"pod",0
Txt6_2		dc.b	"1000 pts",0

HDG_1		dc.b	"todays",0
HDG_2		dc.b	"all time",0
HDG_3		dc.b	"greatest",0
HDG_4		dc.b	"hall of fame",0

_PINST1		dc.b	"press f1      one  player",0

_PINST2		dc.b	"press f2      two  player",0

_PINST3		dc.b	"press f3      change keys",0

_PINST3A		dc.b	"press f4      game options",0

_PINST4		dc.b	"player 1",0

_PINST5		dc.b	"player 2",0

_PINST6		dc.b	"keyboard and joystick",0

_PINST7		dc.b	"settings",0

_PINST8		dc.b	"game over",0

_PINST9		dc.b	"you are admitted to the",0

_PINST10		dc.b	"defender hall of fame",0

_PINST11		dc.b	"enter your initials",0

_PINST12		dc.b	"attack wave        ",0


* Cheat passwords for my own use.
* 1st allows infinite lives
* 2nd allows infinite smart bombs
* 3rd allows skip to any level
* 4th allows ???


__MYCPW		dc.b	"eithne ni bhraonian",0
		dc.b	"vita sackville-west",0
		dc.b	"nastassja kinski",0
		dc.b	"marghanita laski",0

		dc.b	$FF


CharSet		dc.b	%00000000
		dc.b	%00111100
		dc.b	%01000110
		dc.b	%01001010
		dc.b	%01010010
		dc.b	%01100010
		dc.b	%00111100
		dc.b	%00000000

		dc.b	%00000000
		dc.b	%00001000
		dc.b	%00011000
		dc.b	%00001000
		dc.b	%00001000
		dc.b	%00001000
		dc.b	%00111100
		dc.b	%00000000

		dc.b	%00000000
		dc.b	%00111100
		dc.b	%01000010
		dc.b	%00000100
		dc.b	%00001000
		dc.b	%00010000
		dc.b	%01111110
		dc.b	%00000000

		dc.b	%00000000
		dc.b	%00111100
		dc.b	%01000010
		dc.b	%00001100
		dc.b	%00001100
		dc.b	%01000010
		dc.b	%00111100
		dc.b	%00000000

		dc.b	%00000000
		dc.b	%00001000
		dc.b	%00011000
		dc.b	%00101000
		dc.b	%01111100
		dc.b	%00001000
		dc.b	%00001000
		dc.b	%00000000

		dc.b	%00000000
		dc.b	%01111110
		dc.b	%01000000
		dc.b	%01111100
		dc.b	%00000010
		dc.b	%01000010
		dc.b	%00111100
		dc.b	%00000000

		dc.b	%00000000
		dc.b	%00111100
		dc.b	%01000000
		dc.b	%01111100
		dc.b	%01000010
		dc.b	%01000010
		dc.b	%00111100
		dc.b	%00000000

		dc.b	%00000000
		dc.b	%01111110
		dc.b	%00000010
		dc.b	%00000100
		dc.b	%00001000
		dc.b	%00001000
		dc.b	%00001000
		dc.b	%00000000

		dc.b	%00000000
		dc.b	%00111100
		dc.b	%01000010
		dc.b	%00111100
		dc.b	%00111100
		dc.b	%01000010
		dc.b	%00111100
		dc.b	%00000000

		dc.b	%00000000
		dc.b	%00111100
		dc.b	%01000010
		dc.b	%01000010
		dc.b	%00111110
		dc.b	%00000010
		dc.b	%00111100
		dc.b	%00000000

		dc.b	%00000000
		dc.b	%00111100
		dc.b	%01000010
		dc.b	%01000010
		dc.b	%01111110
		dc.b	%01000010
		dc.b	%01000010
		dc.b	%00000000

		dc.b	%00000000
		dc.b	%01111000
		dc.b	%01000100
		dc.b	%01111100
		dc.b	%01000100
		dc.b	%01000010
		dc.b	%01111110
		dc.b	%00000000

		dc.b	%00000000
		dc.b	%00111100
		dc.b	%01000010
		dc.b	%01000000
		dc.b	%01000000
		dc.b	%01000010
		dc.b	%00111100
		dc.b	%00000000

		dc.b	%00000000
		dc.b	%01111100
		dc.b	%01000010
		dc.b	%01000010
		dc.b	%01000010
		dc.b	%01000010
		dc.b	%01111100
		dc.b	%00000000

		dc.b	%00000000
		dc.b	%01111110
		dc.b	%01000000
		dc.b	%01110000
		dc.b	%01110000
		dc.b	%01000000
		dc.b	%01111110
		dc.b	%00000000

		dc.b	%00000000
		dc.b	%01111110
		dc.b	%01000000
		dc.b	%01110000
		dc.b	%01110000
		dc.b	%01000000
		dc.b	%01000000
		dc.b	%00000000
