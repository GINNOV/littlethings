* Amiga 500 + 1 meg + External Drive
* Devpac 2

	SECTION		Chipmemory,data_c	
							;BY BLAINE EVANS
							;1 ERITH WAY
							;PONTYBODKIN
							;NR MOLD
							;CLWYD
							;CH7 4TR
							;TEL O352-771673
		Opt	C-,D+

***************************************************************************
*		The Equates for Screen And Bobs 			  *
***************************************************************************

Height			Equ	256
Width			Equ	40
Depth			Equ	3

ScreenSize		Equ	Height*Width

MemoryRequired_1	Equ	ScreenSize*Depth
MemoryRequired_2	Equ	ScreenSize*Depth

BobHeight		Equ	10
BobWidth		Equ	2
BobDepth		Equ	3

BobSize			Equ	BobHeight*(BobWidth*2)

HitsForBonus		Equ	15
****************************************************************************

		Incdir	source:Include/
		Include	Hardware.i

	Move.l	4.w,a6			;FIND EXEC BASE
	Lea	Gfxlib(pc),a1		;LOAD GRAPHICS LIBRARY IN A1
	Moveq.l	#$00,d0			;VERSION 0
	Jsr	-552(a6)		;OPEN LIBRARY
	Move.l	d0,_Gfxbase		;STORE D0 (GFX ADDRESS )
	Beq	NoLib_Exit		;ELSE EXIT

	Move.l	4.w,a6
	Move.l	#MemoryRequired_1,d0	; Amount of memory
	Move.l	#$10002,d1		; Clear+Chip memory
	Jsr	-198(a6)		; Allocate memory
	Move.l	d0,DisplayScreen	; Save area of memory
	Beq	NoMem_Exit_2		; Error-End

	Move.l	4.w,a6
	Move.l	#MemoryRequired_2,d0	; Amount of memory
	Move.l	#$10002,d1		; Clear+Chip memory
	Jsr	-198(a6)		; Allocate memory
	Move.l	d0,WorkScreen		; Save area of memory
	Beq	NoMem_Exit_1		; Error-End

	Move.l	4.w,a6
	Jsr	-132(a6)		; Forbid

	Move.l	DisplayScreen,d0	; Start of Screen Memory
	Bsr	Plane_Addresses		
	Bsr	BuildAlienFlags
	Bsr	BuildCoordinates
	Bsr	Clear_Display
	Bsr	Init
	Move.l	#22565,Seed		* Random Number Seed

	Move.l	_Gfxbase,a0		; LOAD ADDRESS OF GRAPHICS LIB IN A0
	Move.l	50(a0),Oldcop		; STORE CURRENT COPPER,ETC TO RETRIEVE LATER
S
	Move.l	#Newcop,50(a0)		; POINT TO OUR COPPERLIST
VGapIntro
	Cmp.b	#0,Vhposr(a6)		; VERTICAL BLANKING GAP 
	Bne.s	VGapIntro
	Bsr	BlitIntro
	Btst	#$7,$bfe001		* Fire Button Pressed
	Bne.s	VGapIntro
	Move.w	#$0ff0,22(a4)		* Reset To Yellow

Wait					; WAIT LOOP
	Cmp.b	#0,Vhposr(a6)		; VERTICAL BLANKING GAP 
	Bne.s	Wait			;
;	Move.w	#$fff,$180(a6)		; REMove TO MEASURE RASTER TIME

	Bsr	DoubleBuffer
	Bsr	BlitClear
	Bsr	AlienAnimation
	Bsr	AlienMovement
	Bsr	Joy_Test
	Bsr	ShipMovement
	Move.l	Vposr(a6),Seed		* Random Number Seed
	Bsr	FireButton
	Bsr	MissileMovement
	Bsr	RandomizeFire
	Bsr	FireAlienFire
	Bsr	PosCalc
	Bsr	Bonus
	Bsr	BonusMovement
	Bsr	AlienBonusCollision
	Bsr	PlayerText
	Bsr	UpDateScore
	Bsr	EndLevel
	Bsr	LastAlien

;	Move.w	#$000,$180(a6)		;REMove TO MEASURE RASTER TIME
	Btst	#$6,$bfe001		;QUIT LEFT MOUSE PRESSED
	Bne.s	Wait
Ended					;ELSE LOOP TO WAIT
	Move.w	#%0000000000001111,Dmacon(a6)	* Kill Samples
	Move.l	_Gfxbase,a0		;LOAD GRAPHICS LIB ADDRESS IN A0
	Move.l	Oldcop,50(a0)		;RESTORE OLD COPPER TO RETURN TO EDITTER
	Move.l	4.w,a6
	Jsr	-138(a6)		; Permit
NoMem_Exit_2	
	Move.l	4.w,a6
	Move.l	DisplayScreen,a1	; Address to release from
	Move.l	#MemoryRequired_1,d0	; Size to release
	Jsr	-210(a6)		; Free memory
NoMem_Exit_1
	Move.l	4.w,a6
	Move.l	WorkScreen,a1		; Address to release from
	Move.l	#MemoryRequired_2,d0	; Size to release
	Jsr	-210(a6)		; Free memory
NoLib_Exit
	Move.l	4.w,a6			;FIND EXEC BASE
	Move.l	_Gfxbase,a1		;LOAD GRAPHICS BASE IN A1
	Jsr	-414(a6)		;CLOSE LIBRARY
Exit
	Rts				;RETURN TO EDITER

Plane_Addresses	
	Lea	Planes,a0		; BitPlane Control Words
	Moveq.l	#(Depth)-1,d1		; Number of Planes-1
PlaneLoop
	Move.w	d0,6(a0)		; Low Word of Bit-Plane 
	Swap	d0				
	Move.w	d0,2(a0)		; High Word of Bit-Plane
	Swap	d0
	Add.l	#Width,d0		; Interleaved Bit-Planes
	Addq.l	#8,a0			; Increment to Next Control Word
	DBra	d1,PlaneLoop
	Rts
BuildAlienFlags
	Move.l	#AlienHit,a0		* Base Address
	Move.w	#(NumberBobs)-1,d0	* Number Of Long Words To Clear
ReBuildFlags	
	Move.w	#0,(a0)+		* Clear It
	DBra	d0,ReBuildFlags
	Rts
BuildCoordinates
	Move.l	#Xs1,a0
	Move.l	#XCoord,a1
	Move.w	#(NumberBobs)-1,d0	* Number Of Long Words 
ReBuild2	
	Move.w	(a1)+,(a0)+		
	DBra	d0,ReBuild2
	Move.l	#Ys1,a0
	Move.l	#YCoord,a1
	Move.w	#(NumberBobs)-1,d0	* Number Of Long Words 
ReBuild2.1	
	Move.w	(a1)+,d7
	Add.w	YInc,d7
	Move.w	d7,(a0)+		
	DBra	d0,ReBuild2.1
	Rts

Init
	Lea	$dff000,a6
	Move.w	#%1000011111000000,Dmacon(a6)	; Give Blitter Priority
	Move.w	#2,LastXVelocity
	Move.w	#2,XVelocity
	Move.w	#0,FireFlag
	Move.l	#$3,Lives			* No of Lives to Loose
	Move.w	#0,ShipX	
	Move.b	#0,AlienHits
	Move.w	#0,BonusFlag	
	Move.w	#0,BonusHit
	Move.b	#11,AlienSpeed
	Move.b	#0,TotalAlienHits
	Move.w	#0,YInc
	Move.b	#0,TotalAlienHits	* Clear Flag
	Move.l	#ShipExp1,DisplayShipExp
	Move.l	#ShipExp2,WorkShipExp
	Move.l	#Player1Score,a0
	Move.l	#0,(a0)+			* Reset Score to 0
	Move.l	#0,(a0)+

	move.l	DisplayScreen,d0
	add.l	#60*Width*Depth,d0
	move.l	d0,Text_Base		; store address to start text
	move.l	#Text,a0
	move.l	a0,Text_Address		; store current character
	Rts

Clear_Display
	Move.l	DisplayScreen,a0		; Start of Screen1 memory
	Move.l	#(MemoryRequired_1/4)-1,d0	; Number of long words 
Clear
	Move.l	#$0,(a0)+			; Transfer Data
	DBra	d0,Clear			; Loop till 0
	Move.l	WorkScreen,a0			; Start of Screen2 memory
	Move.l	#(MemoryRequired_2/4)-1,d0	; Number of long words 
Clear_2
	Move.l	#$0,(a0)+			; Transfer Data
	DBra	d0,Clear_2			; Loop till 0
	Rts


PlayerOneScorer
	Move.l	#Player1Score,a0		* Score Address
	Moveq.l	#0,d0				* Clear Work Register
	Move.b	4(a0),d0			* 10's
	Divu	#10,d0				* Low Word=100's,High=10's
	Add.b	d0,3(a0)			* Add to 100's
	Swap	d0				* Low Word=10's
	Move.b	d0,4(a0)			* Store 10's
	Cmp.b	#10,4(a0)			* Above 10 Then
	Beq.s	Hundreds			* Add 1 to Hundreds
	Cmp.b	#10,3(a0)			* Above 10
	Beq.s	Thousands
	Cmp.b	#10,2(a0)			* Above 10
	Beq.s	TenThousands
	Cmp.b	#10,1(a0)			* Above 10
	Beq.s	HundThousands
	Cmp.b	#10,0(a0)			* Above 10
	Beq.s	ResetScore
	Rts
Hundreds
	Move.b	#0,4(a0)			* Clear Tens
	Add.b	#1,3(a0)			* Add 1 to Hundreds
	Rts
Thousands
	Move.b	#0,3(a0)			* Clear Hundreds
	Add.b	#1,2(a0)			* Add 1 to Thousands
	Rts
TenThousands
	Move.b	#0,2(a0)			* Clear Ten Thousands
	Add.b	#1,1(a0)			* Add 1 to Hundred Thousands
	Rts
HundThousands
	Move.b	#0,1(a0)			* Clear Hundred Thousands
	Add.b	#1,0(a0)			* Add 1 to Thousand Thousands
	Rts
ResetScore
	Move.b	#0,0(a0)			* Reset Score to 000000
	Rts	

UpDateScore
	Bsr	PlayerOneScorer
	Move.l	WorkScreen,a1			* Address Of Screen Memory
	Add.l	#(7*Width*Depth)+12,a1
        Moveq	#6-1,d1     			* No of Chars Per Line-1
	Moveq.l	#0,d0
	Bsr	BlitScore
	Move.l	#Lives,a0			* Number of Lives Remaining
	Lea	3(a0),a0			* Unused Bytes
	Move.l	WorkScreen,a1			* Address Of Screen Memory
	Add.l	#(7*Width*Depth)+30,a1
	Moveq.l	#0,d0
        Moveq	#1-1,d1     			* No of Chars Per Line-1
	Bsr	BlitScore
	Rts

BlitScore
	Move.w	#1-1,d3				* Number of Planes -1
NoPlanes
LP1      
	Move.b	(a0)+,d0
        Mulu.w	#8,d0		   		* Find Font Gfx
        Lea	Number_Font(pc),a2		* Font Gfx in a2
        Add.l	d0,a2	         		* Add Offset
        Moveq	#7,d2	         	 	* No of Lines High Font is
        Move.l	a1,a3				* Save Address
LP2      
	Move.b	(a2)+,(a3)	    		* Font Gfx into Memory
        Add.l	#Width*Depth,a3	        	* Add 1 Line Across
        DBra	d2,LP2	        		* Loop till 0
        Addq.l	#1,a1	         		* Increase Address by 1 Byte
        DBra	d1,LP1	        	
	Add.l	#Width,a1			* Next Interleaved Plane
	DBra	d3,NoPlanes
	Rts

PlayerText
	Move.l	#PlayerScoreText1,a0
	Move.l	WorkScreen,a1			* Address Of Screen Memory
	Add.l	#(7*Width*Depth)+2,a1
        Moveq	#9-1,d1     			* No of Chars Per Line-1
	Bsr	TextWriter
	Move.l	#PlayerLivesText1,a0
	Move.l	WorkScreen,a1			* Address Of Screen Memory
	Add.l	#(7*Width*Depth)+22,a1
        Moveq	#6-1,d1     			* No of Chars Per Line-1
	Bsr	TextWriter
	Rts

TextWriter
	Move.w	#1-1,d3				* Number of Planes -1
NoPlanes1
	Move.w	d1,d4				* No.Chars-1
LP11      
	Moveq.l	#0,d0
	Move.b	(a0)+,d0
	Sub.b	#32,d0
        Mulu.w	#8,d0		   		* Find Font Gfx
        Lea	Font(pc),a2			* Font Gfx in a2
        Add.l	d0,a2	         		* Add Offset
        Moveq	#7,d2	         	 	* No of Lines High Font is
        Move.l	a1,a3				* Save Address
LP21      
	Move.b	(a2)+,(a3)	    		* Font Gfx into Memory
        Add.l	#Width*Depth,a3	        	* Add 1 Line Across
        DBra	d2,LP21	        		* Loop till 0
        Addq.l	#1,a1	         		* Increase Address by 1 Byte
        DBra	d4,LP11	        	
	Add.l	#Width,a1			* Next Interleaved Plane
	DBra	d3,NoPlanes1
	Rts

Joy_Test
	Move.w	$DFF00c,d2		* ADDRESS OF STICK 2
	Move.w	d2,d1			* COPY TO D1
	Lsr.w	#1,d1			* LOGICAL SHIFT RIGHT
	Eor.w	d2,d1			* EXCLUSIVE OR D2 WITH D1
	Btst	#1,d2			* TEST BIT 1 OF D2 (RIGHT)
	Beq	Try_Left		* IF NOT EquAL THEN TRY LEFT
	Move.w	#2,ShipX		* Add 1 to X
	Rts
Try_Left
	Btst	#9,d2			;TEST BIT 9 (LEFT)
	Beq	No_Move		
	Move.w	#-2,ShipX		* Subtract 1 from X
	Rts
No_Move
	Move.w	#0,ShipX
	Rts				* Stationary No Move
ShipBoundary
	Cmp.w	#292,d0			* Farthest Right Position
	Bhs.s	No_Right		* If There Then No Move
	Cmp.w	#06,d0			* Farthest Left Position
	Bls.s	No_Left			* If There Then No Move
	Rts
No_Right
	Subq.w	#2,d0
	Rts
No_Left
	Addq.w	#2,d0
	Rts

ShipMovement
	Move.l	ShipsX(pc),a3		* X Co-ordinates
	Move.l	ShipsY(pc),a4		* Y Co-ordinates
	Moveq.l	#0,d0			* Clear Work Register
	Moveq.l	#0,d1			* Clear Work Register
	Move.w	(a3),d0			* Find Co-odinates Location  
	Move.w	(a4),d1			* in List
	Bsr	ShipBoundary
	Movem.l	d0-d7/a0-a6,-(sp)	* Save Registers
	Add.w	ShipX,d0
	Move.w	d0,(a3)			* Last X
	Move.w	d1,(a4)			* Last Y
	Move.l	#ShipMask,a0		* A
	Move.l	#Ship,a1		* B
	Bsr	Bob_draw
	Bsr	OrBlit
	Movem.l	(sp)+,d0-d7/a0-a6	* Restore Registers
	Rts

FireButton	
	Cmp.w	#0,FireFlag			* Is Missile in Motion
	Bne	Return				* No,Then Skip FireButton
	Btst	#$7,$bfe001			* Joystick Button
	Beq.s	Fired
	Rts
Fired
	Move.w	#1,FireFlag
	Move.l	#FireSample,Aud2lch(a6)		* Tell system where sample data is
	Move.w	#1932,Aud2len(a6)		* Length of sample in words
	Move.w	#64,Aud2vol(a6)			* Full volume
	Move.w	#$12c,Aud2per(a6)		* Frequency
	Move.w	#%1000001000000100,Dmacon(a6)	* Channel 1 Only
	Move.l	MissileX(pc),a1
	Move.l	MissileY(pc),a2
	Move.l	ShipsX(pc),a3
	Move.l	ShipsY(pc),a4
	Move.w	0(a3),0(a1)			* Ship X=Missile X
	Move.w	0(a4),0(a2)			* Ship Y=Missile Y
	Rts

MissileMovement
	Cmp.w	#1,FireFlag		* Is Missile in Motion
	Bne.s	Return			* No,Then Skip Movement
	Move.l	MissileX(pc),a3
	Move.l	MissileY(pc),a4
	Moveq.l	#0,d0			* Clear Work Register
	Moveq.l	#0,d1			* Clear Work Register
	Subq.w	#8,0(a4)		* Missile Upwards
	Move.w	(a3),d0			* Find Co-odinates Location  
	Move.w	(a4),d1			* in List
	Bsr	MissileBoundary
	Move.l	#MissileMask,a0		* A
	Move.l	#Missile,a1		* B
	Bsr	Bob_draw
	Bsr	OrBlit
Return
	Rts

MissileBoundary
	Cmp.w	#10,0(a4)			* Top Of Screen
	Bls.s	ResetMissile			* Yes,Reset Flag to
	Cmp.w	#165,0(a4)			* Missile Sample Length
	Bls.s	ResetVoice2			* Yes,Kill Sample
	Rts					* Allow Missile to be
ResetMissile					* Fired Again
	Move.w	#%0000000000000100,Dmacon(a6)	* Kill Channel 2 
	Move.w	#0,FireFlag
	Rts
ResetVoice2
	Move.w	#%0000000000000100,Dmacon(a6)	* Kill Channel 2 
	Rts

Bonus
	Cmp.w	#0,BonusFlag
	Bne.s	Return
	Cmp.b	#HitsForBonus,AlienHits		* Number of Hits
	Beq.s	BonusPath
	Rts
BonusPath
	Move.w	#1,BonusFlag	
	Move.l	BonusX(pc),a0
	Move.l	BonusY(pc),a1
	Move.w	#0,0(a0)			* X Start
	Move.w	#17,0(a1)			* Y Start
	Rts					* Return
BonusMovement
	Cmp.w	#1,BonusFlag			* Is Bonus in Motion
	Bne.s	Return				* No,Then Skip Movement
	Cmp.w	#1,BonusHit
	Beq	BonusExplosion
	Move.l	BonusX(pc),a0
	Move.l	BonusY(pc),a1
	Moveq.l	#0,d0			* Clear Work Register
	Moveq.l	#0,d1			* Clear Work Register
	Cmp.w	#304,0(a0)		* Max Position Right
	Bhs.s	ResetBonus		* Greater Than Reset
	Addq.w	#2,0(a0)		* Alien Bonus Across
	Move.w	(a0),d0			* X
	Move.w	(a1),d1			* Y
	Move.l	#BonusMask,a0		* A Blit Data
	Move.l	#BonusAlien,a1		* B Blit Data
	Bsr	Bob_draw
	Bsr	OrBlit
	Rts

ResetBonus
	Move.w	#0,0(a0)			* Erase Bonus Alien X
	Move.w	#0,0(a1)			* Erase Bonus Alien Y
	Move.w	#0,BonusFlag			* Clear Flag
	Move.b	#0,AlienHits			* Clear Flag
	Rts

AlienBonusCollision	
	Move.l	BonusX(pc),a1
	Move.l	BonusY(pc),a2
	Move.l	MissileX(pc),a3
	Move.l	MissileY(pc),a4
	Move.w	0(a1),d0			* BonusAlien X
	Move.w	0(a2),d1			* BonusAlien Y
	Move.w	0(a3),d2			* Missile X
	Move.w	0(a4),d3			* Missile Y

	Add.w	#2,d1
	Cmp.w	d3,d1				* d1=AlienY,d3=MissileY
	Blo.s	MissedAlienBonus		* If Lower Than Its Missed

	Subq.w	#6,d1				* Pixel Perfect Detection
	Cmp.w	d3,d1				* d1=AlienY,d3=MissileY
	Bhi.s	MissedAlienBonus		* If Higher Than Its Missed

	Subq.w	#8,d0
	Cmp.w	d2,d0				* d0=AlienX,d2=MissileX
	Bhi.s	MissedAlienBonus		* If Lower Its Missed	

	Add.w	#16,d0				* Pixel Perfect Detection
	Cmp.w	d2,d0				* d0=AlienX,d2=MissileX
	Blo.s 	MissedAlienBonus		* If Higher Its Missed

	Move.w	#0,0(a3)			* Erase Missile X
	Move.w	#0,0(a4)			* Erase Missile Y
	Move.w	#0,FireFlag			* Renable Fire
	Lea	Player1Score,a0
	Add.b	#1,3(a0)			* Add 1 to Hundreds
	Move.w	#1,BonusHit
MissedAlienBonus
	Rts

BonusExplosion
	Cmp.w	#1,BonusHit
	Bne	Return
	Move.l	#ExpSample,Sample		* Sample to Play
	Move.w	#13748,SampleLength		* Length of Sample
	Bsr	PlayShipExpSample		* Play Sample
	Lea	AlienBonusColours,a0		* Alien Colour
	Move.w	#$0ff0,6(a0)			* Change To Yellow
	Move.l	BonusX(pc),a0
	Move.l	BonusY(pc),a1
	Add.b	#1,BonusExpAnim
	Cmp.b	#6,BonusExpAnim
	Bhs	BonusExplosion2
	Move.w	(a0),d0			* X
	Move.w	(a1),d1			* Y
	Move.l	#ExplosionMask1,a0
	Move.l	#Explosion1,a1		* New Graphics Data
	Bsr	Bob_draw
	Bsr	OrBlit
	Rts
BonusExplosion2
	Cmp.b	#13,BonusExpAnim
	Bhs	BonusExpReset
	Move.w	(a0),d0			* X
	Move.w	(a1),d1			* Y
	Move.l	#ExplosionMask2,a0
	Move.l	#Explosion2,a1		* New Graphics Data
	Bsr	Bob_draw
	Bsr	OrBlit
	Rts
BonusExpReset	
	Lea	AlienBonusColours,a0		* Alien Colour
	Move.w	#$0fff,6(a0)			* Back To White
	Move.w	#0,BonusHit			* Clear Flag
	Move.b	#0,BonusExpAnim			* Clear Flag
	Move.w	#0,BonusFlag			* Clear Flag
	Move.b	#0,AlienHits			* Clear Flag
	Move.l	BonusX(pc),a0
	Move.l	BonusY(pc),a1
	Move.w	#0,0(a0)			* Erase Bonus Alien X
	Move.w	#0,0(a1)			* Erase Bonus Alien Y
	Move.w	#$1,Dmacon(a6)			* Kill Sample
	Rts


AlienAnimation
	Add.b	#1,AnimDelayRow3
	Add.b	#1,AnimDelayRow2
	Add.b	#1,AnimDelayRow1
	Moveq.l	#0,d5				* Clear d5
	Move.b	AlienSpeed,d5			* Speed in Relation to Animation
	Asl.w	#1,d5				* Multiply By 2
	Cmp.b	AnimDelayRow3,d5		* Which Animation ?
	Blt	AnimationResetRow3
	Rts
AnimationResetRow3
	Move.b	#0,AnimDelayRow3
	Move.b	#0,AnimDelayRow2
	Move.b	#0,AnimDelayRow1
	Rts

AlienData					* Bob Data
	Move.b	AlienSpeed,d5			* For Comparisions/Animation Speed 
	Cmp.w	#((NumberBobs-22)*2)-1,d7	* Rows 4-5
	Bls.s	NextRow
	Move.b	#1,Points			* Value of Alien/10
	Cmp.b	AnimDelayRow3,d5
	Blt	Animation2.1
	Move.l	#BobGraphics_1,AlienAnim
	Move.l	#Mask_1,AlienMaskAnim
	Rts
Animation2.1
	Move.l	#BobGraphics_2,AlienAnim
	Move.l	#Mask_2,AlienMaskAnim
	Rts

NextRow
	Move.b	#3,Points			* Value of Alien/10
	Cmp.w	#((NumberBobs-44)*2)-1,d7	* Row 3-2
	Bls.s	NextRow2
	Cmp.b	AnimDelayRow2,d5
	Blt	Animation2.2
	Move.l	#BobGraphics_3,AlienAnim
	Move.l	#Mask_3,AlienMaskAnim
	Rts
Animation2.2
 	Move.l	#BobGraphics_4,AlienAnim
	Move.l	#Mask_4,AlienMaskAnim
	Rts
NextRow2
	Move.b	#5,Points			* Value of Alien/10
	Cmp.b	AnimDelayRow1,d5
	Blt	Animation2.3
	Move.l	#BobGraphics_5,AlienAnim	* Row 1
	Move.l	#Mask_5,AlienMaskAnim
	Rts
Animation2.3
	Move.l	#BobGraphics_6,AlienAnim	* Row 1
	Move.l	#Mask_6,AlienMaskAnim
	Rts

DoubleBuffer
	Move.l	WorkScreen(pc),a0		* a0 = Work Screen
	Move.l	DisplayScreen(pc),WorkScreen	* Switch Screens
	Move.l	a0,DisplayScreen		* Display Work Screen
	Move.l	a0,d0				* Load Bit-Planes
	Bsr	Plane_Addresses
	Rts

Collision
	Move.l	#AlienHit,a0		* Has Alien Already Been Hit
	Move.w	(a0,d7),d6
	And.w	#$0fff,d6		* Mask Out Collision Bits
	Cmp.w	#$0000,d6
	Bne	CollReturn		
	Move.w	0(a2),d2
	Move.w	d1,d4
	Subq.w	#4,d4
	Cmp.w	d2,d4			* d4=AlienY,d2=MissileY
	Blo	CollReturn		* If Lower Than Its Missed

	Subq.w	#4,d4			* Pixel Perfect Detection
	Cmp.w	d2,d4			* d4=AlienY,d2=MissileY
	Bhi	CollReturn		* If Higher Than Its Missed

	Move.w	0(a1),d3
	Move.w	d0,d4			* Save Alien 
	Subq.w	#6,d4
	Cmp.w	d3,d4			* d4=AlienX,d3=MissileX
	Bhi.s	CollReturn		* If Lower Its Missed	

	Add.w	#11,d4			* Pixel Perfect Detection
	Cmp.w	d3,d4			* d4=AlienX,d3=MissileX
	Blo.s 	CollReturn		* If Higher Its Missed

	Move.l	#AlienHit,a0
	Move.w	(a0,d7),d6
	Or.w	#$0001,d6
	Move.w	d6,(a0,d7)

	Move.w	#0,0(a1)		* Clear Missile X
	Move.w	#0,0(a2)		* Clear Missile Y
	Move.w	#0,FireFlag		* Ready to Fire Again
	Lea	Player1Score,a0
	Move.b	Points,d5			* Value of Alien
	Add.b	d5,4(a0)			* Add Value of Alien to 100's
	Add.b	#1,AlienHits
	Add.b	#1,TotalAlienHits
	Add.b	#1,SpeedHits			* For Alien Speed Increase
	Move.l	#AlienSample,Aud1lch(a6)	* Tell system where sample data is
	Move.w	#4536,Aud1len(a6)		* Length of sample in words
	Move.w	#64,Aud1vol(a6)			* Full volume
	Move.w	#$12c,Aud1per(a6)		* Frequency
	Move.w	#%1000001000000010,Dmacon(a6)	* Channel 1 Only
	Rts
CollReturn
	Rts

PosCalc
	Move.w	#(NumberBobs-1)*2,d7	* Number of Bobs-1 * Word Width
	Move.l	Xa(pc),a3		* X Co-ordinates
	Move.l	Ya(pc),a4		* Y Co-ordinates
Pos_bobs
	Moveq.l	#0,d0			* Clear Work Register
	Moveq.l	#0,d1			* Clear Work Register
	Move.l	MissileX(pc),a1
	Move.l	MissileY(pc),a2
	Move.w	(a3,d7),d0		* Find Co-odinates Location  
	Move.w	(a4,d7),d1		* in List
	Cmp.w	#198,d1			* Same Y As Base Ship
	Bhs	GameOver
	Movem.l	d0-d7/a0-a6,-(sp)	* Save Registers
	Bsr	AlienData
	Bsr	Collision
	Add.w	XVelocity,d0		* X
	Add.w	YVelocity,d1		* Y
	Bsr	BeenHit
	Move.w	d0,(a3,d7)		* Last X
	Move.w	d1,(a4,d7)		* Last Y
	Move.l	AlienMask,a0				* A
	Move.l	Alien,a1				* B
	Bsr	Bob_draw
	Bsr	OrBlit
	Movem.l	(sp)+,d0-d7/a0-a6	* Restore Registers
	Subq.w	#2,d7			* Next Bob( -1 Word )
	Bpl.s	Pos_bobs
	Rts

BeenHit
	Move.l	#AlienHit,a0
	Move.w	(a0,d7),d6
	Move.w	d6,d5			* Save Info
	And.w	#$0fff,d6		* Mask Out Collision Bits
	Cmp.w	#$0000,d6
	Beq	NotHit			* Skip Animation Routine
	Add.w	#$0001,d5
	Add.w	#$0001,d6
	Move.w	d5,(a0,d7)
	Cmp.w	#$0006,d6
	Bhs	ExpOne
	Move.l	#Explosion1,Alien		* Various Animations
	Move.l	#ExplosionMask1,AlienMask	* For Explosion
	Rts
ExpOne
	Cmp.w	#$000a,d6
	Bhs	ExpEnd
	Move.l	#Explosion2,Alien
	Move.l	#ExplosionMask2,AlienMask
	Move.w	#$2,Dmacon(a6)			* Kill Sample(Voice 1)
	Rts	
ExpEnd
	And.w	#$f00a,(a0,d7)			* Animate No More
	Move.l	#Destroyed,Alien
	Move.l	#Destroyed,AlienMask
	Move.w	#0,d0				* Clear X
	Move.w	#0,d1				* Clear Y
	Rts
NotHit
	Move.l	AlienAnim,Alien
	Move.l	AlienMaskAnim,AlienMask
	Rts
************************* Alien Fire Routine ***********************
FireAlienFire
	Move.w	#(NumberBobs-1)*2,d5		* Number of Bobs
FFire	
	Bsr	Alien_Fire
	Sub.w	#2,d5				* Next Bob
	Cmp.w	#((NumberBobs-1)-10)*2,d5	
	Bge.s	FFire
	Rts

Alien_Fire
	Move.l	Xlien(pc),a3		* X Co-ordinates
	Move.l	Ylien(pc),a4		* Y Co-ordinates
	Move.l	#AlienHit,a0
	Move.w	d5,d7			* Bottom Bob Number
InMotion
	Move.w	(a0,d7),d6
	And.w	#$f000,d6		* Mask out Unwanted Bits
	Cmp.w	#$3000,d6		* Already in Motion
	Beq.s	AlreadyMoving

	Move.w	(a0,d7),d6
	And.w	#$f000,d6		* Mask out Unwanted Bits
	Cmp.w	#$1000,d6		* Already in Motion
	Beq.s	AFire
Fire_Bobs
	Move.w	(a0,d7),d6
	And.w	#$000f,d6
	Cmp.w	#$000a,d6		* Already Destroyed
	Bne	Return			* So Alien Can't Fire
NextColumn
	Sub.w	#11*2,d7		* Next Bob( -1 Word )
	Bpl.s	InMotion		* Try Next Bob
	Rts
AFire
	Moveq.l	#0,d0			* Clear Work Register
	Moveq.l	#0,d1			* Clear Work Register
	Move.l	Xa(pc),a1		* X Co-ordinates
	Move.l	Ya(pc),a2		* Y Co-ordinates
	Move.w	(a1,d7),d0		* Find Co-odinates Location  
	Move.w	(a2,d7),d1		* in List
	Add.w	#(BobHeight)-2,d1	* Start at Bottom of Alien
	Move.w	d0,(a3,d7)		* Last X
	Move.w	d1,(a4,d7)		* Last Y

	Or.w	#$2000,(a0,d7)		* Found X,Y Start Position/Set Flag

	Move.l	#FireMask,a0		* A
	Move.l	#AlienFire,a1		* B
	Bsr	Bob_draw
	Bsr	OrBlit
	Rts
AlreadyMoving
	Moveq.l	#0,d0			* Clear Work Register
	Moveq.l	#0,d1			* Clear Work Register
	Move.w	(a3,d7),d0		* Find Co-odinates Location  
	Move.w	(a4,d7),d1		* in List
	Bsr	FireCollison
	Add.w	#7,d1			* Y Movement Down Screen
	Move.w	d0,(a3,d7)		* Last X
	Move.w	d1,(a4,d7)		* Last Y
	Move.l	#FireMask,a0		* A
	Move.l	#AlienFire,a1		* B
	Bsr	Bob_draw
	Bsr	OrBlit
	Rts

RandomizeFire
	Moveq.l	#56,d0			* d0=Max Value+1
	Bsr	Rnd			* Get Random Value
	Move.l	d0,d7			* Save Value
	Asl.w	#1,d7			* *2
	Move.l	#AlienHit,a0		* Flag Address
	Move.w	(a0,d7),d6
	And.w	#$000f,d6
	Cmp.w	#$000a,d6		* Already Destroyed
	Beq	Return			* So Alien Can't Fire
	Or.w	#$1000,(a0,d7)		* Found X,Y Start Position/Set Flag
	Rts

Rnd	
	Move.l	d0,d1			* Make a copy
	Subq.l	#1,d1			* Adjust
RandomLoop	
	Bsr	RandomValue		* Get random value
	And.l	#$ffff,d0	 	* Mask off high bits
	Mulu	d1,d0			* *Num
	Divu	#$ffff,d0		* /Range of random val
	And.l	#$ffff,d0		* Mask off remainder
	Cmp.l	LastRND,d0		* Same value?
	Beq.s	RandomLoop		* If so get another
	Move.l	d0,LastRND		* Save this value
	Addq.l	#1,d0			* Correct
	Rts				* And Return it
	
RandomValue	
	Move.l	d1,-(sp)
	Move.l	a0,-(sp)
	Move.l	Seed,d0			* Get Seed
	Rol.l	d0,d0			* Scramble Bits
	Move.l	d0,d1
	And.l	#$7fffe,d1		* Create Ptr into CHIP
	Move.l	d1,a0
	Add.l	(a0),d0			* Add Onto Scrambled Bits
	Add.l	d0,Seed			* Save Value

	Move.l	(sp)+,a0
	Move.l	(sp)+,d1
	Rts


FireCollison
	Bsr	ShipCollision
	Cmp.w	#204,d1
	Bhs.s	HitBottomScreen
	Rts
HitBottomScreen
	Move.l	#AlienHit,a0
	And.w	#$0fff,(a0,d7)		* Reset Flag to 0
	Move.l	#Destroyed,a0		* A
	Move.l	#Destroyed,a1		* B
	Rts

ShipCollision
	Move.l	ShipsX(pc),a1
	Move.l	ShipsY(pc),a2
	Move.w	0(a2),d2
	Add.w	#16,d2
	Cmp.w	d1,d2			* d1=AlienMissileY,d2=ShipY
	Blo	MissedShip		* If Lower Than Its Missed

	Sub.w	#14,d2			* Pixel Perfect Detection
	Cmp.w	d1,d2			* d1=AlienMissileY,d2=ShipY
	Bhi	MissedShip		* If Higher Than Its Missed

	Move.w	0(a1),d3
	Subq.w	#6,d3
	Cmp.w	d0,d3			* d0=AlienMissileX,d3=ShipX
	Bhi	MissedShip		* If Lower Its Missed	

	Add.w	#14,d3			* Pixel Perfect Detection
	Cmp.w	d0,d3			* d4=AlienMissileX,d3=ShipX
	Blo.s 	MissedShip		* If Higher Its Missed
	Move.w	#%0000000000000110,Dmacon(a6)	* Kill Channel 1,2 
	
	Move.l	#ExpSample,Sample		* Sample to Play
	Move.w	#13748,SampleLength		* Length of Sample
	Bsr	PlayShipExpSample		* Play Sample
	;Move.w	#$1,Dmacon(a6)			* Kill Sample
	Bsr	AnimateShipExp
	Bsr	HitBottomScreen			* Erase Alien Fire
	Move.l	BonusX(pc),a0
	Move.l	BonusY(pc),a1
	Move.w	#0,0(a0)
	Move.w	#0,0(a1)
	Move.w	#0,FireFlag
	Move.w	#0,BonusFlag			* Clear Flag
	Move.b	#0,AlienHits			* Clear Flag

	Sub.l	#1,Lives			* Loose 1 Life
	Cmp.l	#0,Lives			* Does Lives=0
	Beq.s	GameOver			* Game Over
	Move.w	#%0000000000000111,Dmacon(a6)	* Kill Channels 0,1,2 
	Rts
MissedShip
	Rts					* Missed
GameOver					* Game Over Routine
	Move.w	#%0000000000000111,Dmacon(a6)	* Kill Channel 0,1,2
	Movem.l	d0-d7/a0-a6,-(sp)		* Save Registers
	Move.l	#GameOverText,a0
	Move.l	DisplayScreen,a1		* Address Of Screen Memory
	Add.l	#(110*Width*Depth)+13,a1
        Moveq	#9-1,d1     			* No of Chars Per Line-1
	Bsr	TextWriter
	Movem.l	(sp)+,d0-d7/a0-a6		* Restore Registers
	Bsr	BuildAlienFlags
	Move.w	#0,YInc
	Bsr	BuildCoordinates
	Move.b	#0,TotalAlienHits		* Clear Flag
	Move.w	#0,Speed			* Reset Speeds
	Move.w	#2,XVelocity			
	Move.w	#2,LastXVelocity
	Move.b	#11,AlienSpeed			* Reset Speed To Slow
	Move.b	#0,SpeedHits			* Clear Flag
	Move.l	#$3,Lives			* Reset Lives to 3
	Move.l	#Player1Score,a0
	Move.l	#0,(a0)+			* Reset Score to 0
	Move.l	#0,(a0)+
GameHold	
	Btst	#$7,$bfe001			* JoyStick Fire To Play Again
	Bne.s	GameHold
	Btst	#$7,$bfe001			* Released To Restart
	Beq.s	GameHold
	Rts

PlayShipExpSample
	Move.l	Sample,Aud0lch(a6)		* Tell system where sample data is
	Move.w	SampleLength,Aud0len(a6)	* Length of sample in words
	Move.w	#64,Aud0vol(a6)			* Full volume
	Move.w	#$12c,Aud0per(a6)		* Frequency
	Move.w	#%1000001000000001,Dmacon(a6)	* Channel 0 Only
	Rts
AnimateShipExp
	Move.l	ShipsX(pc),a1
	Move.l	ShipsY(pc),a2
	Move.w	0(a1),d0			* X
	Move.w	0(a2),d1			* Y
	Move.w	#5,d6
ExpLoop
	Move.l	#$ffffffff,d2
Del	DBra	d2,Del
	Movem.l	d0-d1/a1-a2,-(sp)		* Save Registers	
	Move.l	WorkShipExp(pc),a0		* Switch Animations
	Move.l	DisplayShipExp(pc),WorkShipExp	* Each Loop
	Move.l	a0,DisplayShipExp
	Move.l	DisplayScreen,d4		* Base address
	Bsr	AD_Blit
	Movem.l	(sp)+,d0-d1/a1-a2		* Restore Registers
	DBra	d6,ExpLoop
	Move.w	#06,0(a1)			* New Ship Position
	Move.w	#202,0(a2)
	Rts

***********************************************************************
ChangeSpeed
	Cmp.b	#10,SpeedHits
	Beq.s	IncreaseSpeed			* Increase Speed of Aliens
	Rts
IncreaseSpeed
	Move.b	#0,SpeedHits			* Clear Flag
	Sub.b	#2,AlienSpeed
	Cmp.b	#5,AlienSpeed
	Beq.s	SpeedUp1
	Cmp.b	#3,AlienSpeed
	Beq.s	SpeedUp2
	Cmp.b	#1,AlienSpeed
	Beq.s	SpeedUp3
	Bsr	IncPlusSpeed
	Rts
SpeedUp1
	Add.w	#01,Speed			* Increase Speed
	Bsr	IncPlusSpeed
	Rts
SpeedUp2
	Add.w	#01,Speed			* Increase Speed
	Bsr	IncPlusSpeed
	Rts
SpeedUp3
	Move.b	#3,AlienSpeed
	Add.w	#02,Speed			* Increase Speed
	Bsr	IncPlusSpeed
	Rts

IncPlusSpeed
	Move.w	Speed,d0
	Move.w	LastXVelocity,d1
	Bpl.s	IncMinusSpeed			* + or -
	Neg.w	d0				* Left/Needs Speed -ve
	Add.w	d0,LastXVelocity
	Rts
IncMinusSpeed
	Add.w	d0,LastXVelocity		* Right/Needs Speed +ve
	Rts

AlienMovement
	Bsr	ChangeSpeed
	Move.w	#0,XVelocity			* Clear Velocity
	Move.w	#0,YVelocity			* Clear Velocity
	Move.b	AlienSpeed,d0
	Add.b	#1,Movement			* Only Move Alien Every
	Cmp.b	Movement,d0			* So Many Frames
	Bgt	Return
	Move.w	LastXVelocity,XVelocity		* Restore Velocity
	Move.b	#0,Movement			* Clear Flag
	Move.l	#AlienHit,a0			* Hit/Exp Flags
	Move.l	Xa(pc),a1			* X Co-ordinates
	Move.l	Ya(pc),a2			* Y Co-ordinates
	Move.w	XVelocity,d2
TestPosition	
	Bpl.s	GoingRight			* + or -(+=Right/-=Left)
	Move.w	#((NumberBobs-1)-10)*2,d7	* Bottom/Left Alien
TestDirLeft
	Move.w	(a0,d7),d3		
	And.w	#$000f,d3
	Cmp.w	#$000a,d3			* Already Destroyed
	Bne.s	TestGoingLeft			* So Try Next Alien
	Sub.w	#11*2,d7			* Next Bob Up
	Bpl.s	TestDirLeft			* Try Next Bob
	Add.w	#((NumberBobs-1)-10)*2,d7
	Add.w	#11*2,d7			* Next Bob Up
	Add.w	#2,d7				* And Left One
	Bpl.s	TestDirLeft
	ILLEGAL
	Move.w	#0,XVelocity			* No Aliens Remaining
	Move.w	#0,LastXVelocity
	Rts
TestGoingLeft
	Move.w	(a1,d7),d0			* X
	Cmp.w	#20,d0
	Bls	ChangeDirection
	Rts
GoingRight
	Move.w	#((NumberBobs-1))*2,d7		* Bottom/Right Alien
TestDirRight
	Move.w	(a0,d7),d3		
	And.w	#$000f,d3
	Cmp.w	#$000a,d3			* Already Destroyed
	Bne.s	TestGoingRight			* So Try Next Alien
	Sub.w	#11*2,d7			* Next Bob Up
	Bpl.s	TestDirRight			* Try Next Bob
	Add.w	#((NumberBobs-1)-10)*2,d7
	Add.w	#11*2,d7			* Next Bob Up
	Sub.w	#2,d7				* And Right One
	Bpl.s	TestDirRight
	ILLEGAL
	Move.w	#0,XVelocity			* No Aliens Remaining
	Move.w	#0,LastXVelocity
	Rts
TestGoingRight
	Move.w	(a1,d7),d0			* X
	Cmp.w	#280,d0
	Bhs	ChangeDirection
	Rts
ChangeDirection
	Neg.w	d2
	Move.w	d2,XVelocity		* Other Way
	Move.w	d2,LastXVelocity
	Move.w	#8,YVelocity		* Y Velocity Down
	Rts

EndLevel
	Cmp.b	#55,TotalAlienHits
	Beq	NewScreen
	Rts
NewScreen
	Move.w	#%0000000000001111,Dmacon(a6)	* Kill Channel 0,1,2,3
	Bsr	BuildAlienFlags
	Add.w	#8,YInc
	Bsr	BuildCoordinates
	Move.b	#0,TotalAlienHits	* Clear Flag
	Move.w	#0,Speed		* Reset Speeds
	Move.w	#2,XVelocity			
	Move.w	#2,LastXVelocity
	Move.b	#11,AlienSpeed		* Reset Speed To Slow
	Move.b	#0,SpeedHits		* Clear Flag
	Move.w	#$1,Dmacon(a6)		* Kill Sample
	Rts

LastAlien
	Cmp.b	#53-1,TotalAlienHits	* Last Aliens
	Blt.s	LastReturn
	Move.w	#((NumberBobs-1))*2,d7	* Number Alien
	Move.l	#AlienHit,a0		* Flag Address
LastA	
	Move.w	(a0,d7),d6
	And.w	#$000f,d6
	Cmp.w	#$000a,d6		* Already Destroyed
	Bne	SetAlienFlag		* So Alien Can't Fire
	Subq.w	#2,d7			* Next Bob( -1 Word )
	Bpl.s	LastA
SetAlienFlag
	Or.w	#$1000,(a0,d7)		* Found Last Alien-Set Flag
LastReturn
	Rts

Bob_draw
	Divu	#16,d0			* This gives no of words in lower
					* Word and remainder is shift value
					* In higher word
	Move.w	d0,d2
	Asl.w	#1,d2
	Mulu.w	#Width*Depth,d1		* Find screen address
	Add.w	d2,d1			* Add X to Y
	Move.l	WorkScreen,d4		* Base address
	Add.l	d1,d4			* Add to base address
	Move.l	d4,BobAddress		* New Address of Bob
	Asl.l	#8,d0			* Put Shift in Correct Place
	Asl.l	#4,d0			* Shift Left 12 Times
	And.l	#$f0000000,d0		* Clear Unwanted Bits
	Move.l	d0,Bltcon		* Save Result
	Rts

OrBlit
	Lea	$dff000,a6				* Custom base
	Move.l	Bltcon,d0
	Move.l	d0,d1					* for Bltcon1
	Or.l	#$0fca0000,d0
	Move.l	BobAddress,a2				* C
Or_Bob					* LOAD BLITTER WITH VALUES
	Bsr	Wfblit
	Move.l	a0,Bltapth(a6)				* Mask
	Move.l	a1,Bltbpth(a6)   			* Source	
	Move.l	a2,Bltcpth(a6)				* Background
	Move.l	a2,Bltdpth(a6)				* Designation
	Move.w	#-2,Bltamod(a6)				* Mask Modula
	Move.w	#-2,Bltbmod(a6)				* Source Modula
	Move.w	#Width-(BobWidth*2),Bltcmod(a6)		* Designation Modula
	Move.w	#Width-(BobWidth*2),Bltdmod(a6)  	* Designation Modula
	Move.l	d0,Bltcon0(a6)				* Bplcon0
	Move.l	d1,Bltcon1(a6)				* Bplcon1
	Move.w	#$ffff,Bltafwm(a6)			* First word mask
	Move.w	#$0000,Bltalwm(a6)  			* Last word mask
	Move.w	#((BobHeight*BobDepth)*64)+(BobWidth),Bltsize(a6)  * Blitsize
	Rts
BlitClear
	Lea	$dff000,a6			* Custom base
	Bsr	Wfblit
	Move.l	WorkScreen,a0
	Move.l	a0,Bltapth(a6)			* Source and are
	Move.l	a0,Bltdpth(a6)			* Designation same
	Move.w	#0,Bltamod(a6)			* Source Modula
	Move.w	#0,Bltdmod(a6) 			* Designation Modula
	Move.l	#$1000000,Bltcon0(a6)		* A Channel Only
	Move.l	#00,Bltcon1(a6)			* Bplcon1
	Move.w	#$ffff,Bltafwm(a6)		* First word mask
	Move.w	#$ffff,Bltalwm(a6)		* Last word mask
	Move.w	#((Height*Depth)*64)+(Width/2),Bltsize(a6)  * Blitsize
	Rts

Wfblit
	Btst	#14,Dmaconr(a6)			* Dmaconr
	Bne.s	Wfblit				* Test Blitter State
	Rts	

AD_Blit					* LOAD BLITTER WITH VALUES
	Divu	#16,d0			* This gives no of words in lower
					* Word and remainder is shift value
					* In higher word
	Move.w	d0,d2
	Asl.w	#1,d2
	Mulu.w	#Width*Depth,d1		* Find screen address
	Add.w	d2,d1			* Add X to Y
	Add.l	d1,d4			* Add to base address
	Move.l	d4,BobAddress		* New Address of Bob
	Asl.l	#8,d0			* Put Shift in Correct Place
	Asl.l	#4,d0			* Shift Left 12 Times
	And.l	#$f0000000,d0		* Clear Unwanted Bits
	Move.l	d0,d1					* for Bltcon1
	Or.l	#$09f00000,d0				* A-D Blit
	Move.l	BobAddress,a2				* D
ADBlit
	Bsr	Wfblit
	Move.l	a0,Bltapth(a6)				* Mask
	Move.l	a2,Bltdpth(a6)				* Designation
	Move.w	#-2,Bltamod(a6)				* Source Modula
	Move.w	#Width-(BobWidth*2),Bltdmod(a6) 	* Designation Modula
	Move.l	d0,Bltcon0(a6)				* Bplcon0
	Move.l	d1,Bltcon1(a6)				* Bplcon1
	Move.w	#$ffff,Bltafwm(a6)			* First word mask
	Move.w	#$0000,Bltalwm(a6)  			* Last word mask
	Move.w	#((BobHeight*BobDepth)*64)+(BobWidth),Bltsize(a6)  * Blitsize
	Rts

BlitIntro
	Move.l	#$fff,d0			* Delay Loop
IDel	DBra	d0,IDel
	Move.l	Text_Base,a1			* Address in a1
        Moveq	#1-1,d1     			* No of chars per line-1
Intro1      
	Moveq	#0,d0				* Clear d0
	Move.l	Text_Address,a0			* Text chars in a0
       	Move.b	(a0),d0				* Next char
	Cmp.b	#$ee,d0				* $ee=add 8 lines*40 words
	Bne.s	Cont				* To address
	Add.l	#(8*Width*Depth)-Width,a1	* a1= address
	Add.w	#1,a0
	Move.b	(a0),d0				* Move next char
	Cmp.b	#$ff,d0				* $ff= end marker
	Beq	EndIntro	
Cont	
        Sub.b	#32,d0		     		* Take off offset
        Mulu.w	#8,d0		   		* To find font gfx
        Lea	Font(pc),a2			* Font gfx in a2
        Add.l	d0,a2	         		* Add offset
        Moveq	#8-1,d2	         		* No of lines high font is
        Move.l	a1,a3				* a3 now =adress
Intro2
	Move.b	(a2)+,d4			* a2=font
	Or.b	d4,(a3)				* Or font with background
        Add.l	#Width*Depth,a3	        	* Add 1 line across
       	DBra	d2,Intro2	        	* Loop till 0
        DBra	d1,Intro1	        		
	Add.w	#1,a0
	Move.l	a0,Text_Address			* Store value
        Addq.l	#1,a1	         		* Increase address by 1 byte
	Move.l	a1,Text_Base			* Add 1 byte to address
	Rts
EndIntro
	Lea	AlienBonusColours,a4		* Colour Address In CopperList
	Add.b	#1,Flash
	Cmp.b	#15,Flash
	Bgt.s	ChangeFlash
	Move.w	#$0fff,22(a4)			* Change To White
	Rts
ChangeFlash
	Cmp.b	#30,Flash
	Bgt.s	FlashReset
	Move.w	#$0000,22(a4)			* Change To Black
	Rts
FlashReset
	Move.b	#0,Flash
	Rts

Gfxlib	Dc.b	"graphics.library",0	
	Even
_Gfxbase	Dc.l	0			;LONG WORD TO STORE GFX ADDRESS
Oldcop		Dc.l	0			;OLD COPPERLIST ADDRESS
DisplayScreen	Dc.l	0
WorkScreen	Dc.l	0
ScreenPointer	Dc.l	0
BobAddress	Dc.l	0
Bltcon		Dc.l	0
Sample		Dc.l	0
Alien		Dc.l	0
AlienMask	Dc.l	0
AlienAnim	Dc.l	0
AlienMaskAnim	Dc.l	0
ShipAnim	Dc.l	0
Seed		Dc.l	0			* For Random Generator
LastRND		Dc.l	0			* To stop repeats
Player1Score	Dc.l	0
		Dc.l	0
Player2Score	Dc.l	0
		Dc.l	0
YInc		Dc.l	0
DisplayShipExp	Dc.l	0
WorkShipExp	Dc.l	0
Lives		Dc.l	0
Text_Address	Dc.l	0
Text_Base	Dc.l	0
SampleLength	Dc.w	0
XVelocity	Dc.w	0
YVelocity	Dc.w	0
Speed		Dc.w	0
FireFlag	Dc.w	0
BonusFlag	Dc.w	0
BonusHit	Dc.w	0
LastXVelocity	Dc.w	0
ShipX		Dc.w	0
Points		Dc.b	0
Movement	Dc.b	0
AnimDelayRow1	Dc.b	0
AnimDelayRow2	Dc.b	0
AnimDelayRow3	Dc.b	0
ShipKillAnim	Dc.b	0
AlienHits	Dc.b	0
AlienSpeed	Dc.b	0
SpeedHits	Dc.b	0
BonusExpAnim	Dc.b	0
TotalAlienHits	Dc.b	0
Flash		Dc.b	0
	Even

XCoord
	Dc.w	30,46,62,78,94,110,126,142,158,174,190
	Dc.w	30,46,62,78,94,110,126,142,158,174,190
	Dc.w	30,46,62,78,94,110,126,142,158,174,190
	Dc.w	30,46,62,78,94,110,126,142,158,174,190
	Dc.w	30,46,62,78,94,110,126,142,158,174,190
YCoord
	Dc.w 	30,30,30,30,30,30,30,30,30,30,30
	Dc.w 	46,46,46,46,46,46,46,46,46,46,46
	Dc.w 	62,62,62,62,62,62,62,62,62,62,62
	Dc.w 	78,78,78,78,78,78,78,78,78,78,78
	Dc.w 	94,94,94,94,94,94,94,94,94,94,94

NumberBobs	Equ	(*-YCoord)/2
	Even
ShipsX		Dc.l	Sx
ShipsY		Dc.l	Sy

Sx		Dc.w	06
Sy		Dc.w	202

MissileX	Dc.l	Mx
MissileY	Dc.l	My

Mx		Dc.w	0
My		Dc.w	0

BonusX		Dc.l	Bx
BonusY		Dc.l	By

Bx		Dc.w	0
By		Dc.w	0

Xa		Dc.l Xs1
Ya		Dc.l Ys1

Xs1		Dcb.w	NumberBobs,0
Ys1		Dcb.w	NumberBobs,0

Xlien		Dc.l Xl
Ylien		Dc.l Yl

Xl		Dcb.w	NumberBobs,0
Yl		Dcb.w	NumberBobs,0

AlienHit	Dcb.w	NumberBobs,0

Newcop
	Dc.w	BplCon0,%0011001000000000
	Dc.w	BplCon1,$0000			; SCROLL VALUE
	Dc.w	BplCon2,%0000000001110111	; PRIORITIES
	Dc.w	Bpl1Mod,Width*(Depth-1)		; Modula1
	Dc.w	Bpl2Mod,Width*(Depth-1)		; Modula2
	Dc.w	DdfStrt,$0038
	Dc.w	DdfStop,$00d0		
	Dc.w	DiwStrt,$2c81
	Dc.w	DiwStop,$2cc1		
						
Planes
	Dc.w	Bpl1pth
	Dc.w	$0000,Bpl1ptl
	Dc.w	$0000,Bpl2pth
	Dc.w	$0000,Bpl2ptl
	Dc.w	$0000,Bpl3pth
	Dc.w	$0000,Bpl3ptl
	Dc.w	$0000,Bpl4pth
	Dc.w	$0000,Bpl4ptl
	Dc.w	$0000,Bpl5pth
	Dc.w	$0000,Bpl5ptl
	Dc.w	$0000,Bpl6pth
	Dc.w	$0000,Bpl6ptl
	Dc.w	$0000

Sprites						;SPRITES
	Dc.w	Spr0pth
	Dc.w	$0000,Spr0ptl
	Dc.w	$0000,Spr1pth
	Dc.w	$0000,Spr1ptl
	Dc.w	$0000,Spr2pth
	Dc.w	$0000,Spr2ptl
	Dc.w	$0000,Spr3pth
	Dc.w	$0000,Spr3ptl
	Dc.w	$0000,Spr4pth
	Dc.w	$0000,Spr4ptl
	Dc.w	$0000,Spr5pth
	Dc.w	$0000,Spr5ptl
	Dc.w	$0000,Spr6pth
	Dc.w	$0000,Spr6ptl
	Dc.w	$0000,Spr7pth
	Dc.w	$0000,Spr7ptl
	Dc.w	$0000

Colors	Dc.w	Color00,$0000,Color01,$00f0
	Dc.w	Color02,$0d10,Color03,$0f70
	Dc.w	Color04,$00ff,Color05,$00f0
	Dc.w	Color06,$0f0f,Color07,$0f82

	Dc.w	Color08,$0000,Color09,$0283
	Dc.w	Color10,$08f4,Color11,$0095
	Dc.w	Color12,$0243,Color13,$00ff
	Dc.w	Color14,$0ff0,Color15,$0f0f

	Dc.w	Color16,$0000,Color17,$0fff
	Dc.w	Color18,$0d00,Color19,$0F70
	Dc.w	Color20,$0000,Color21,$0f0f
	Dc.w	Color22,$0F00,Color23,$0d00
	Dc.w	Color24,$004f,Color25,$008f
	Dc.w	Color26,$00ff,Color27,$00f0
	Dc.w	Color28,$0283,Color29,$0ff0
	Dc.w	Color30,$0456,Color31,$0f00
AlienBonusColours
	Dc.w	$3b01,$fffe			* Change Colours0 + 1
	Dc.w	Color01,$0fff
	Dc.w	$4501,$fffe			* Change Colours0 + 1
	Dc.w	Color01,$0ff0
	Dc.w	$c001,$fffe			* Change Colours0 + 1
	Dc.w	Color01,$0ff0
	
	Dc.w	$ff01,$fffe,Color00,$0fff
	Dc.w	$ffdf,$fffe			* Pal Enable
	Dc.w	$0001,$fffe,Color00,$0fff,Color01,$0fff,Color02,$0fff,Color03,$0fff
	Dc.w	$0101,$fffe,Color00,$0eee,Color01,$0eee,Color02,$0eee,Color03,$0eee
	Dc.w	$0201,$fffe,Color00,$0ddd,Color01,$0ddd,Color02,$0ddd,Color03,$0ddd
	Dc.w	$0301,$fffe,Color00,$0ccc,Color01,$0ccc,Color02,$0ccc,Color03,$0ccc
	Dc.w	$0401,$fffe,Color00,$0bbb,Color01,$0bbb,Color02,$0bbb,Color03,$0bbb
	Dc.w	$0501,$fffe,Color00,$0aaa,Color01,$0aaa,Color02,$0aaa,Color03,$0aaa
	Dc.w	$0601,$fffe,Color00,$0999,Color01,$0999,Color02,$0999,Color03,$0999
	Dc.w	$0701,$fffe,Color00,$0888,Color01,$0888,Color02,$0888,Color03,$0888
	Dc.w	$0801,$fffe,Color00,$0777,Color01,$0777,Color02,$0777,Color03,$0777
	Dc.w	$0901,$fffe,Color00,$0666,Color01,$0666,Color02,$0666,Color03,$0666
	Dc.w	$0a01,$fffe,Color00,$0555,Color01,$0555,Color02,$0555,Color03,$0555
	Dc.w	$0b01,$fffe,Color00,$0444,Color01,$0444,Color02,$0444,Color03,$0444
	Dc.w	$0c01,$fffe,Color00,$0333,Color01,$0333,Color02,$0333,Color03,$0333
	Dc.w	$0d01,$fffe,Color00,$0222,Color01,$0222,Color02,$0222,Color03,$0222
	Dc.w	$0e01,$fffe,Color00,$0111,Color01,$0111,Color02,$0111,Color03,$0111
	Dc.w	$0f01,$fffe,Color00,$0000,Color01,$0000,Color02,$0000,Color03,$0000


	Dc.w	$ffff,$fffe			;END OF COPPERLIST


Mask_1		IncBin	Source:Blaine/BitMaps/Invader.IntMask
Mask_2		IncBin	Source:Blaine/BitMaps/Invader.IntMask-2
Mask_3		IncBin	Source:Blaine/BitMaps/Invader.IntMask-3
Mask_4		IncBin	Source:Blaine/BitMaps/Invader.IntMask-4
Mask_5		IncBin	Source:Blaine/BitMaps/Invader.IntMask-5
Mask_6		IncBin	Source:Blaine/BitMaps/Invader.IntMask-6
BobGraphics_1	IncBin	Source:Blaine/BitMaps/Invader.IntRaw
BobGraphics_2	IncBin	Source:Blaine/BitMaps/Invader.IntRaw-2
BobGraphics_3	IncBin	Source:Blaine/BitMaps/Invader.IntRaw-3
BobGraphics_4	IncBin	Source:Blaine/BitMaps/Invader.IntRaw-4
BobGraphics_5	IncBin	Source:Blaine/BitMaps/Invader.IntRaw-5
BobGraphics_6	IncBin	Source:Blaine/BitMaps/Invader.IntRaw-6
Destroyed	Dcb.b	BobSize*BobDepth,$00
ShipMask	IncBin	Source:Blaine/BitMaps/Ship.IntMask
Ship		IncBin	Source:Blaine/BitMaps/Ship.IntRaw
MissileMask	IncBin	Source:Blaine/BitMaps/Missile.IntMask
Missile		IncBin	Source:Blaine/BitMaps/Missile.IntRaw
ExplosionMask1	IncBin	Source:Blaine/BitMaps/Explosion.IntMask
Explosion1	IncBin	Source:Blaine/BitMaps/Explosion.IntRaw
ExplosionMask2	IncBin	Source:Blaine/BitMaps/Explosion.IntMask-2
Explosion2	IncBin	Source:Blaine/BitMaps/Explosion.IntRaw-2
FireMask	IncBin	Source:Blaine/BitMaps/AlienFire.IntMask-3
AlienFire	IncBin	Source:Blaine/BitMaps/AlienFire.IntRaw-3
ShipExp1	IncBin	Source:Blaine/BitMaps/ShipExp.IntRaw
ShipExp2	IncBin	Source:Blaine/BitMaps/ShipExp.IntRaw-2
BonusMask	IncBin	Source:Blaine/BitMaps/Bonus.IntMask
BonusAlien	IncBin	Source:Blaine/BitMaps/Bonus.IntRaw


	Even
PlayerScoreText1	Dc.b	'Player 1:'
PlayerLivesText1	Dc.b	'Lives:'
	Even
GameOverText		Dc.b	'GAME OVER'
	Even
Font		Include	Source:Blaine/BitMaps/FontGfx        
	Even
Number_Font
         Dc.b      $7C,$C6,$CE,$DE,$F6,$E6,$7C,$00	;0
         Dc.b      $38,$78,$18,$18,$18,$18,$7E,$00	;1
         Dc.b      $7C,$C6,$06,$7C,$C0,$C0,$FE,$00	;2
         Dc.b      $FC,$06,$06,$7C,$06,$06,$FC,$00	;3
         Dc.b      $1C,$3C,$6C,$CC,$FE,$0C,$0C,$00	;4
         Dc.b      $FE,$C0,$C0,$FC,$06,$06,$FC,$00	;5
         Dc.b      $7E,$C0,$C0,$FC,$C6,$C6,$7C,$00	;6
         Dc.b      $FE,$06,$06,$0C,$0C,$18,$18,$00	;7
         Dc.b      $7C,$C6,$C6,$7C,$C6,$C6,$7C,$00	;8
         Dc.b      $7C,$C6,$C6,$7E,$06,$06,$06,$00	;9
	Even
ExpSample	IncBin	Source:Blaine/BitMaps/Explosion.Sample
AlienSample	IncBin	Source:Blaine/BitMaps/AlienExp.Sample
FireSample	IncBin	Source:Blaine/BitMaps/ShipFire.Sample-2

	
Text	     	;12345678901234567899012345678901234567890
	Dc.b	"............ Invaders Mk II ............",$ee
	Dc.b	"   +++++++++++++++++++++++++++++++++++  ",$ee
	Dc.b	"                                        ",$ee
	Dc.b	"Yes Its Me Again With A New Version Of  ",$ee
	Dc.b	"The Classic Space Invaders Game.        ",$ee
	Dc.b	"As You Can See I've Taken The Gfx From  ",$ee
	Dc.b	"The Original............................",$ee
	Dc.b	"My Thanks To Dave Edwards For The Random",$ee
	Dc.b	"Number Generator Routine.               ",$ee
	Dc.b	"Enjoy................ Blaine Evans @1992",$ee
	Dc.b	"                                        ",$ee
	Dc.b	"       PRESS FIRE BUTTON TO PLAY        ",$ee
	Dc.b	$ff
	even

