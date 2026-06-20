

* SpecialCodes for objects go in this include file. So does the
* mine handling system.

* NOTE : ALL SpecialCode routines (which have a pointer to them
* placed in the AO_SpecialCode entry of the AlienObject structure)
* MUST be re-entrant with respect to each alien (i.e., register A0
* MUST be left untouched). They can corrupt other registers freely
* and also write to the variable table (pointed to by A6). They
* can also cause inter-object interactions via pointers to the AO_
* structure for the other object if need be (e.g., Lander picking
* up Body).

* DO NOT CORRUPT REGISTER A0 OR ALL HELL WILL BREAK LOOSE!


* ShipCode(a6,a0)
* Perform special operations for ship.

* d0-d1/a1 corrupt


ShipCode		move.b	Anim_Flags(a0),d0	;get death status
		and.b	#_ANF_DISABLED,d0	;dead?
		beq.s	ShipCode4	;skip if not

		rts			;else done

ShipCode4	move.b	AO_Flags(a0),d0	;get ship status flags
		move.b	d0,d1		;copy them

		and.b	#_AOF_DYING,d0	;ship dying?
		bne.s	ShipCode1	;skip if so

		move.b	d1,d0		;copy flags back
		and.b	#_AOF_HIT,d0	;ship hit by something?
		bne.s	ShipCode3	;skip if so

		rts			;else done

ShipCode3	moveq	#10,d0		;no. of explosion frames
		move.w	d0,DeathTime(a6)	;set them off

		clr.w	CurrXSpeed(a6)	;stop the ship
		st	Brakes(a6)	;and prevent thrust

		and.b	#_NAOF_HIT,d1	;finished hitting
		or.b	#_AOF_DYING,d1	;now it's dying
		move.b	d1,AO_Flags(a0)	;change ship stat

		rts

ShipCode1	tst.w	DeathTime(a6)	;finished explosion?
		beq.s	ShipCode2	;skip if so

		clr.w	CurrXSpeed(a6)	;stop the ship

		rts			;else done

ShipCode2	or.b	#_ANF_DISABLED,Anim_Flags(a0)	;kill ship
		move.l	Anim_Next(a0),a1
		or.b	#_ANF_DISABLED,Anim_Flags(a1)	;and flame

		move.l	CurrentPlayer(a6),a1
		moveq	#_PDF_DEAD,d1
		move.b	d1,pd_Flags(a1)
		rts


* BodyInit(a0,a6)
* a0 = ptr to AO_ struct for Body
* a6 = ptr to main program variables

* Initialise Body position relative to landscape. If can't put
* Body in a sensible position at this landscape point, move it.

* d0-d2/a1-a2 corrupt


BodyInit		move.l	YTable(a6),a1	;table ptrs
		move.l	LandOff(a6),a2

		move.w	Anim_YPos(a0),d0	;get Body Y pos
		subq.w	#4,d0

BDIN_1		move.w	d0,d1		;copy Y pos
		add.w	d1,d1		;word index
		move.w	0(a1,d1.w),d1	;get YTable entry = YH
		move.w	Anim_XPos(a0),d2	;x pos
		lsr.w	#4,d2
		add.w	d2,d2		;word index
		move.w	0(a2,d2.w),d2	;get Landscape entry
		add.w	LandYHgt(a6),d2	;make true Y offset = YL
		cmp.w	d2,d1		;below landscape surface?
		bcc.s	BDIN_2		;skip if so
		addq.w	#8,d0		;else try another Y
		cmp.w	#196,d0		;too far down?
		bcs.s	BDIN_1		;back if not


* Here, we're at a deep trough. So relocate our Body and try again.


		move.w	#180-4,d0	;initial Y pos
		bsr	Random		;change X position
		move.w	Seed(a6),d1
		and.w	MaxScrPos(a6),d1	;constrain to screen limits
		move.w	d1,Anim_XPos(a0)	;set it
		move.w	d0,Anim_YPos(a0)
		bra.s	BDIN_1


* Here, we're below the landscape surface, so set Y pos, and
* change the SpecialCode to point to the laser hit detection
* code.


BDIN_2		addq.w	#4,d0
		move.w	d0,Anim_YPos(a0)

		lea	BodyCode(pc),a1
		move.l	a1,AO_SpecialCode(a0)	;check for laser hits

		rts


* BodyCode1(a0,a6)
* a0 = ptr to AO_ struct for Body
* a6 = ptr to main program variables

* Perform Body operations once kidnapped. Fall through to
* normal BodyCode if not dead.

* d0/a1 corrupt


BodyCode1	move.l	AO_KidnapPtr(a0),a1	;check Lander
		move.b	Anim_Flags(a1),d0		;& see if dead
		and.b	#_ANF_DISABLED,d0		;is it dead?
		beq.s	BC1_2			;skip if not


* Here, the Lander has been shot away. Begin the falling sequence.


		lea	BodyCode2(pc),a1
		move.l	a1,AO_SpecialCode(a0)
		rts


BC1_2		move.w	Anim_YPos(a0),d0	;get Body Y pos
		subq.w	#1,d0		;-1
		cmp.w	#MIN_SY,d0	;off top of play area?
		bhi.s	BC1_1		;skip if not

		moveq	#_ANF_DISABLED,d0	;else kill it
		move.b	d0,Anim_Flags(a0)
		clr.l	AO_SpecialCode(a0)
		move.l	AO_ScanLoc(a0),a1		;zero out
		move.l	AO_ScanBit1(a0),d0	;scanner bits
		not.l	d0			;for dead Body
		and.l	d0,(a1)
		rts			;and done

BC1_1		move.w	d0,Anim_YPos(a0)	;replace y position, then do...


* BodyCode(a0,a6)
* a0 = ptr to AO_ struct for Body
* a6 = ptr to main program variables

* Perform 'Body hit by laser' function. If not hit, just
* exit cleanly. If hit, then check if this is the last
* Body and if so, signal the End Of The World...

* d0/a1 corrupt


BodyCode		move.b	AO_Flags(a0),d0	;check Body status
		and.b	#_AOF_HIT,d0	;hit by laser?
		beq.s	BC0_1		;exit if not

		move.b	#_ANF_DISABLED,d0	;else this Body is
		move.b	d0,Anim_Flags(a0)	;dead...

		move.l	AO_ScanLoc(a0),a1		;zero out
		move.l	AO_ScanBit1(a0),d0	;scanner bits
		not.l	d0			;for dead Body
		and.l	d0,(a1)


* NOTE : all of the pd_Bodies subtractions have been reworked like
* this to prevent the -1 Body count bug (which results in mayhem on
* screen plus 65,536,000 added to the score!!!).


		move.l	CurrentPlayer(a6),a1	;subtract 1 from
		move.w	pd_Bodies(a1),d0
		beq.s	BC0_2
		subq.w	#1,d0
		move.w	d0,pd_Bodies(a1)		;Body count
		bne.s	BC0_1			;skip if some left

BC0_2		bsr	EndOfWorld		;else oh, oh...

BC0_1		rts


* BodyCode2(a0,a6)
* a0 = ptr to AO_ struct for Body
* a6 = ptr to main program variables

* Perform Body operations if kidnapping Lander dies.
* Basically cause descent, and if Body hits floor
* too hard (i.e., from too high up) then Body dies.
* Also checks to see if ship has rescued body.

* d0-d2/a1 corrupt


BodyCode2	move.w	Anim_XPos(a0),d0	;get Body X Pos
		add.w	CurrXPos(a6),d0
		and.w	MaxScrPos(a6),d0	;position rel. to ship


* Here, check if Body and Ship are close together (i.e., ship is
* picking up Body)


		move.l	ShipAnim(a6),a1
		move.w	Anim_XPos(a1),d1
		move.w	d1,d2		;ship x
		add.w	#14,d2		;ship x + 18
		subq.w	#4,d1		;make life easier!
		cmp.w	d1,d0		;Body x > ship x?
		bls.s	BC2_4		;skip if not
		cmp.w	d2,d0		;Body x < (ship x + 14)?
		bcc.s	BC2_4		;skip if not

		move.w	Anim_YPos(a0),d0

		move.w	Anim_YPos(a1),d1
		move.w	d1,d2		;ship y
;		addq.w	#8,d2		;ship y + 8
;		addq.w	#4,d2		;ship y + 12
		add.w	#16,d2		;ship y + 16 (was 12)
		cmp.w	d1,d0		;body y > ship y?
		bls.s	BC2_4		;skip if not
		cmp.w	d2,d0		;body y < (ship y + 16) ?
		bcc.s	BC2_4		;skip if not


* If we reach here, then the ship and the Body are close together
* and we've rescued the Body.

		
		lea	BodyCode3(pc),a1		;change Body
		move.l	a1,AO_SpecialCode(a0)	;SpecialCode

;		or.b	#_AOF_RESCUED,AO_Flags(a0)	;signal rescued
		move.b	#_AOF_RESCUED,AO_Flags(a0)

		rts


* Come here if still not rescued. Begin the descent to the landscape
* and if we hit the landscape too hard, then the Body dies.


BC2_4		move.w	Anim_YPos(a0),d0	;Body Y pos
		add.w	AO_YMove(a0),d0	;move down a bit
		move.w	d0,Anim_YPos(a0)

		move.w	AO_YCnt(a0),d0	;do acceleration
		addq.w	#1,d0
;		and.w	#$F,d0
		and.w	#$7,d0		;counter cycled back?
		move.w	d0,AO_YCnt(a0)
		bne.s	BC2_1		;skip if not

		addq.w	#1,AO_YMove(a0)	;else vert speed + 1


* Here, see if the Body has hit the ground. If not, continue moving
* downwards. Use Landscape data table to determine if we're there.


BC2_1		move.w	Anim_YPos(a0),d0	;get y position
		move.l	YTable(a6),a1	;YTable
		move.w	d0,d1
		subq.w	#4,d1		;y-4 for below ground
		add.w	d1,d1
		move.w	0(a1,d1.w),d1	;get YTable entry

		move.w	Anim_XPos(a0),d2	;x position
		lsr.w	#4,d2		;x/16=array index
		add.w	d2,d2		;WORD index
		move.l	LandOff(a6),a1	;ptr to array
		move.w	0(a1,d2.w),d2	;get landscape entry
		add.w	LandYHgt(a6),d2	;landscape height
		cmp.w	d2,d1		;below surface?
		bcs.s	BC2_2		;exit if not

;		cmp.w	#MAX_SY-20,d0	;Body hit bottom?
;		bcs.s	BC2_2		;skip if not

		move.w	AO_YMove(a0),d0	;get vertical speed
		cmp.w	#4,d0		;hit ground too fast?
		bls.s	BC2_3		;skip if not


* Here, the Body has hit the ground from too high up. Kill it off.


		or.b	#_ANF_DISABLED,Anim_Flags(a0)

		move.l	AO_ScanLoc(a0),a1		;zero out
		move.l	AO_ScanBit1(a0),d0	;scanner bits
		not.l	d0			;for dead Body
		and.l	d0,(a1)

		move.l	CurrentPlayer(a6),a1	;now reduce the
		move.w	pd_Bodies(a1),d0		;Body count
		beq.s	BC2_2A
		subq.w	#1,d0
		move.w	d0,pd_Bodies(a1)
		bne.s	BC2_2			;skip if any left


* Here, we trigger landscape disappearance, mutant conversion of
* remaining Landers, when all Bodies have been killed off.


BC2_2A		bsr	EndOfWorld


* Whether dead or not, come here if we're at ground level...
* Restore the original BodyCode whether dead or not-because
* if the Body is dead, it won't get called, and if it isn't,
* then it'll be needed...


BC2_3		clr.w	AO_YMove(a0)		;no vertical speed
		lea	BodyCode(pc),a1
		move.l	a1,AO_SpecialCode(a0)


* ...else exit for another round of the same.


BC2_2		rts


* BodyCode3(a0,a6)
* a0 = ptr to AO_ struct for Body
* a6 = ptr to main program variables

* Handle rescued Bodies.


BodyCode3	move.l	ShipAnim(a6),a1

		move.w	MaxScrPos(a6),d0
		sub.w	CurrXPos(a6),d0
		add.w	Anim_XPos(a1),d0	;true body X pos

		addq.w	#4,d0		;plus a displacement
		move.l	Seed(a6),d1
		and.w	#3,d1
		subq.w	#1,d1		;plus a random wobble
		add.w	d1,d0		;factor
		and.w	MaxScrPos(a6),d0
		move.w	d0,Anim_XPos(a0)	;= body x pos

		move.w	Anim_YPos(a1),d0	;ship y pos
		addq.w	#7,d0
		move.w	d0,Anim_YPos(a0)	;this is body y pos

		move.l	YTable(a6),a1	;YTable ptr
		move.w	d0,d1		;copy Y position
		subq.w	#4,d1
		add.w	d1,d1
		move.w	0(a1,d1.w),d1	;get YTable entry
		move.l	LandOff(a6),a1
		move.w	Anim_XPos(a0),d2	;get x position
		lsr.w	#4,d2
		add.w	d2,d2
		move.w	0(a1,d2.w),d2	;get landscape entry
		add.w	LandYHgt(a6),d2	;landscape height
		cmp.w	d2,d1		;below surface?
		bcs.s	BC3_1		;skip if not

;		move.w	#MAX_SY,d1
;		sub.w	#10,d1		;y limit - 10
;		cmp.w	d1,d0		;body y > above?
;		bls.s	BC3_1		;skip if not


* Here, if rescued, restore original SpecialCode and give player a
* bonus for rescuing the Body.


		lea	BodyCode(pc),a1
		move.l	a1,AO_SpecialCode(a0)
		clr.b	AO_Flags(a0)		;no longer rescued

		move.l	CurrentPlayer(a6),a1
		move.l	pd_Score(a1),d0
		moveq	#0,d1
		move.w	#500,d1		;rescue Body:500 points!
		add.l	d1,d0
		move.l	d0,pd_Score(a1)
		
BC3_1		rts


* LanderCode(a0,a6)
* a0 = ptr to AlienObject structure (Anim header!)
* a6 = ptr to main program variables
* Perform Lander operation. For now, just initialise and then
* move the lander.

* d0/a1 corrupt


LanderCode	move.w	#160,Anim_YPos(a0)	;set Y Position
		bsr	Random
		move.l	Seed(a6),d0		;get random no.
		and.w	MaxScrPos(a6),d0
		move.w	d0,Anim_XPos(a0)		;set X Position

		move.b	#_ANF_SAMEFRAME,d0
		move.b	d0,Anim_Flags(a0)
		clr.b	AO_Flags(a0)
		clr.l	AO_KidnapPtr(a0)		;no Body yet
		move.l	BodyList(a6),d0
		move.l	d0,AO_WhatBody(a0)	;ptr to Bodies

		lea	DoLander(pc),a1
		move.l	a1,AO_SpecialCode(a0)

		tst.b	Seed(a6)		;top byte <0?
		bpl.s	LanderSet	;skip if not

		neg.w	AO_XMove(a0)	;else change direction

LanderSet	clr.w	AO_YMove(a0)	;no y movement yet

		bsr	Random		;another random number
		move.l	Seed(a6),d0
		and.w	KDThresh(a6),d0
		move.w	d0,AO_BCount(a0)	;ticker for hunting

		rts


* DoLander(a0,a6)
* a0 = ptr to AlienObject structure (Anim header!)
* a6 = ptr to main program variables

* Handle Lander operations.

* Note : new way of setting lander hunting. Use a countdown clock
* stored in AO_BCount. When it hits zero, a-hunting we will go.
* Also, Lander now tries to find the Body closest to it for hunting.


DoLander		tst.b	NoLand(a6)	;Planet gone?
		bne	DoLander_12	;skip if so

		move.b	AO_Flags(a0),d0	;check Lander status
		move.b	d0,d1
		and.b	#_AOF_HIT,d0	;hit by laser?
		beq.s	DoLander_2	;skip if not
		eor.b	#_AOF_HIT,d1
		move.b	d1,AO_Flags(a0)
		and.b	#_NANF_SAMEFRAME,Anim_Flags(a0)
		
DoLander_2	move.b	Anim_Flags(a0),d0		;check Anim flags
		and.b	#_ANF_SAMEFRAME,d0	;not animating?
		bne.s	DoLander_1		;skip if not

		move.l	Anim_CFrame(a0),a1
		move.l	AnFr_Next(a1),d0		;done explosion
		cmp.l	d0,a1			;animating?
		bne.s	DoLander_1		;skip if not

		move.b	#_AOF_DYING,d0	;else this object is
		move.b	d0,AO_Flags(a0)	;dying...

		move.l	CurrentPlayer(a6),a1
		subq.w	#1,pd_Landers(a1)

		move.l	AO_KidnapPtr(a0),d0	;dropping a Body?
		beq.s	DoLander_2a		;skip if not

		lea	BodyCode2(pc),a1		;else change
		exg	d0,a1			;SpecialCode
		move.l	d0,AO_SpecialCode(a1)	;for Body
		moveq	#1,d0
		move.w	d0,AO_YMove(a1)
		clr.w	AO_YCnt(a1)


* Here, we do a test for whether we're playing Defender Plus. If so,
* we can leave a power-up behind to pick up.


DoLander_2a	tst.b	GamePlus(a6)		;which game?
		beq.s	DoLander_2x		;skip if Classic


* Here, we're playing Defender Plus. Allow this AO_ structure to be re-used
* for the Power-Up. Here determine whether or not we'll have a power-up, &
* if not, set the re-use pointer to zero.


		moveq	#0,d0		;reuse pointer

		bsr	Random		;make a random number
		move.w	Seed(a6),d1	;get it
		and.w	#$0F,d1		;lowest 4 bits zero?
		bne.s	DoLander_2y	;skip if not


* Here, we're having a power-up, so set the re-use pointer to
* point to this dead Lander's AO_ struct.


		move.l	a0,d0

DoLander_2y	move.l	d0,PuPtr(a6)
		move.l	CurrentPlayer(a6),a1
		move.l	d0,pd_PuPtr(a1)

DoLander_2x	rts


* Come here if Lander functioning normally.


DoLander_1	move.w	Anim_XPos(a0),d0	;current x coord
		add.w	AO_XMove(a0),d0	;movement value
		and.w	MaxScrPos(a6),d0	;constrain to screen
		move.w	d0,Anim_XPos(a0)	;replace x coord

;		add.w	CurrXPos(a6),d0
;		and.w	MaxScrPos(a6),d0

		move.w	Anim_YPos(a0),d0	;current y coord
		add.w	AO_YMove(a0),d0	;movement value
		move.w	d0,Anim_YPos(a0)	;replace y coord


* Before doing terrain following, see if kidnapping a Body. If so,
* skip terrain following.


		move.b	AO_Flags(a0),d1
		move.b	d1,d2
		and.b	#_AOF_SNATCHING,d1	;taking a Body?
		bne	DoLander_4		;skip if so


* Here handle terrain following. First check if we're descending after
* having a Body shot from the underside. If so, descend in 1 pixel steps
* until we're at the correct height. Then begin moving sideways again
* as normal.


		and.b	#_AOF_LOSTIT,d2	;just lost a Body?
		beq.s	DoLander_1h	;skip if not

		move.w	AO_YMove(a0),d1	;get movement
		cmp.w	#-1,d1		;moving up?
		beq	DoLander_14	;skip if so
		cmp.w	#1,d1		;moving down?
		beq	DoLander_15	;skip if so


* Here it isn't ascending/descending because of Body loss, so
* continue as normal.


DoLander_1h	add.w	#20,d0		;current y + 20
		add.w	d0,d0		;index into YTable
		move.l	YTable(a6),a1
		move.w	0(a1,d0.w),d0	;get YTable entry =YH

		move.w	Anim_XPos(a0),d1
		addq.l	#8,d1
		and.w	MaxScrPos(a6),d1
		lsr.w	#4,d1		;index into LandScape
		add.w	d1,d1
		move.l	LandOff(a6),a1
		move.w	0(a1,d1.w),d1	;get Landscape offset =YL
		add.w	LandYHgt(a6),d1

		moveq	#0,d2		;this is YMove
		cmp.w	d0,d1		;heights equal (YH=YL)?
		beq.s	DoLander_1a	;skip if so
		bcs.s	DoLander_1b	;skip if YL<YH

		moveq	#4,d2		;if YL>YH then lander
		bra.s	DoLander_1a	;should move down

DoLander_1b	moveq	#-4,d2		;lander should move up

DoLander_1a	move.w	d2,AO_YMove(a0)	;set terrain following movement

		bsr	LMine		;do missile if wanted

		move.b	AO_Flags(a0),d0
		move.b	d0,d1
		and.b	#_AOF_HUNTING,d1		;looking for body?
		bne.s	DoLander_3		;skip if so
		and.b	#_AOF_SNATCHING,d0	;got body?
		bne	DoLander_4		;skip if so


* Here, check the countdown clock to hunting. Reset clock to KDThresh
* value just in case this kidnap attempt unsuccessful for some reason
* once countdown to zero achieved. Thus we can try again later.


		move.w	AO_BCount(a0),d0	;reduce ticker
		subq.w	#1,d0
		and.w	KDThresh(a6),d0	;prevent excess time rollover
		move.w	d0,AO_BCount(a0)
		beq.s	DoLander_5	;set hunting if zero

		rts			;else done

DoLander_5	moveq	#_AOF_HUNTING,d0
		or.b	d0,AO_Flags(a0)	;set hunting flag
		rts


* Come here if hunting. Select a Body to kidnap.


DoLander_3	move.l	AO_KidnapPtr(a0),d0	;got body to hunt for?
		bne	DoLander_7		;skip if so

		move.l	AO_WhatBody(a0),a1	;get Body
		move.w	Anim_ID(a1),d0		;check object ID
		cmp.w	#_AL_BODY,d0		;genuine body?
		beq.s	DoLander_6		;skip if so

		move.l	BodyList(a6),d0		;round again in case
		move.l	d0,AO_WhatBody(a0)	;hunting Lander killed!

		rts


* We come here if an attempt to select a Body for kidnapping has
* been thwarted (already kidnapped/rescued/dead etc).


DoLander_6b	move.l	Anim_Next(a1),a1		;get next Body
		move.l	a1,AO_WhatBody(a0)	;for next test
		rts


* Here, check if Body is available to be hunted/snatched.


DoLander_6	move.b	Anim_Flags(a1),d0
		and.b	#_ANF_DISABLED,d0	;body already dead?
		bne.s	DoLander_6b	;don't snatch it if so
		move.b	AO_Flags(a1),d0
		move.b	d0,d1
		and.b	#_AOF_SNATCHED,d1	;already snatched?
		bne.s	DoLander_6b	;don't snatch if so
		move.b	d0,d1
		and.b	#_AOF_HUNTED,d1	;already hunted by another?
		bne.s	DoLander_6b	;don't hunt if so
		and.b	#_AOF_RESCUED,d0	;rescued state?
		bne.s	DoLander_6b	;don't snatch if so


* Now see if this Body is close enough to this Lander. If so,
* we go and get it.


		move.w	Anim_XPos(a0),d0	;get Lander position
		move.w	Anim_XPos(a1),d1	;get Body position
		sub.w	d0,d1		;check how close it is
		move.w	MaxScrPos(a6),d0
		and.w	d0,d1		;normalise separation
		lsr.w	#1,d0
		cmp.w	d0,d1		;check which side it's on
		bhi.s	DoLander_11	;skip if Body to Left


* Here, Body is to right. Check if close enough.


		cmp.w	#$200,d1		;are we close to it?
		bhi.s	DoLander_6b	;leave if not
		bra.s	DoLander_6a	;else go kidnap it


* Here, Body is to left. Check if close enough.


DoLander_11	cmp.w	#$2000-$200,d1	;are we close to it?
		bcs.s	DoLander_6b	;leave if not


* Come here if Body is available to be kidnapped AND is close enough
* to this Lander. From here, we set Lander to go find this Body &
* kidnap it.


DoLander_6a	move.b	#_AOF_HUNTED,AO_Flags(a1)	;set this Body hunted!

		move.l	a1,AO_KidnapPtr(a0)	;set kidnap ptr
		move.l	a0,AO_KidnapPtr(a1)	;this is the kidnapper
;		move.l	Anim_Next(a1),BodyPtr(a6)	;& update next

		move.l	Anim_XPos(a1),d0	;get coords in one go
		sub.w	#10,d0		;y=y-10
		swap	d0
		subq.w	#3,d0		;x=x-3
		and.w	MaxScrPos(a6),d0
		swap	d0		;correct order
		move.l	d0,AO_XCnt(a0)	;& store in one go

		move.b	#_AOF_SNATCHED,AO_Flags(a1)

		rts


* Come here if this Lander has selected a Body for kidnap. Check if we're
* on top of it, and if so, complete the kidnap operation.


DoLander_7	move.w	AO_XCnt(a0),d0	;get body x pos
		move.w	Anim_XPos(a0),d1
		sub.w	d0,d1		;this lot gets the value
		bpl.s	DoLander_7a	;abs(landerx-bodyx)
		neg.w	d1
DoLander_7a	cmp.w	#2,d1		;lander close to body?
		bls.s	DoLander_8	;skip if so
		rts			;else done


* Come here if we're on top of the Body. Kidnap it!


DoLander_8	move.w	d0,Anim_XPos(a0)	;set lander position
		moveq	#0,d0		;stop horiz movement
		move.w	d0,AO_XMove(a0)

		move.w	AO_YCnt(a0),d0	;get body y pos
		cmp.w	Anim_YPos(a0),d0	;lander got body?
		beq.s	DoLander_9	;skip if so

		moveq	#1,d0		;set lander to move down
		move.w	d0,AO_YMove(a0)
		rts


* Come here if Lander touches body. Begin taking to top of screen.


DoLander_9	move.b	AO_Flags(a0),d0
		and.b	#_NAOF_HUNTING,d0		;lander is now
		or.b	#_AOF_SNATCHING,d0	;snatching
		move.b	d0,AO_Flags(a0)

		moveq	#-1,d0		;set lander to climb
		move.w	d0,AO_YMove(a0)	;to top of screen

		lea	BodyCode1(pc),a1		;and the Body too!
		move.l	a1,d0
		move.l	AO_KidnapPtr(a0),a1
		move.l	d0,AO_SpecialCode(a1)
		rts


* Come here if snatching Body. Check if we've hit top of screen.


DoLander_4	move.w	Anim_YPos(a0),d0	;Lander Y pos
		cmp.w	#MIN_SY,d0	;top of screen?
		bhi.s	DoLander_10	;skip if not


* Here, we wait for Body to be completely absorbed into the Lander
* as set by BodyCode.


;		move.l	a0,DebugL(a6)
;		move.l	AO_KidnapPtr(a0),DebugL+4(a6)

		moveq	#0,d0
		move.w	d0,AO_XMove(a0)	;stop moving upwards
		move.w	d0,AO_YMove(a0)

		move.l	AO_KidnapPtr(a0),a1
		move.b	Anim_Flags(a1),d0		;check if Body
		and.b	#_ANF_DISABLED,d0		;snatch complete
		beq.s	DoLander_10		;done if not


* Here, Body has been completely kidnapped. Turn Lander into a Mutant.


		or.b	#_ANF_DISABLED,d0
		move.b	d0,Anim_Flags(a1)
		move.l	CurrentPlayer(a6),a1
		move.w	pd_Bodies(a1),d0		;adjust Body count
		beq.s	DoLander_22
		subq.w	#1,d0
		move.w	d0,pd_Bodies(a1)

		bne.s	DoLander_12		;skip if any left


* Here, trigger Landscape disappearance & mutant conversion
* if all Bodies have been destroyed.


DoLander_22	bsr	EndOfWorld


* Here, convert THIS Lander into a Mutant. Also come here if landscape has
* gone (i.e., no more planet) if this Lander didn't cause the end of the
* world...


DoLander_12	lea	DoMutant(pc),a1		;else Lander becomes
		move.l	a1,AO_SpecialCode(a0)	;a mutant!
		addq.w	#1,Anim_ID(a0)
		move.l	AlienAnFr+4(a6),d0
		move.l	d0,Anim_Frames(a0)
		move.l	d0,Anim_CFrame(a0)
		clr.l	AO_KidnapPtr(a0)
		move.b	#_ANF_SAMEFRAME,Anim_Flags(a0)
		clr.b	AO_Flags(a0)
		move.w	#150,d0
		move.w	d0,AO_Points(a0)	;150 pts for killing Mutant!
		moveq	#-1,d0
		clr.w	d0
		move.l	d0,AO_ScanMsk1(a0)	;scanner dot changes!
		rts


* Come here if Lander not at top of screen. Now check if the Body
* has been shot from under the Lander.


DoLander_10	move.l	AO_KidnapPtr(a0),a1	;ptr to Body
		move.b	Anim_Flags(a1),d0		;get Body flags
		and.b	#_ANF_DISABLED,d0		;Body dead?
		beq.s	DoLander_13		;skip if not


* Here, old Body has been shot away, so resume hunting.


		clr.l	AO_KidnapPtr(a0)
		moveq	#_AOF_HUNTING+_AOF_LOSTIT,d0
		move.b	d0,AO_Flags(a0)


* Come here if either Body dead & hunting resumed, or Body live &
* being kidnapped.


DoLander_13	rts


* Come here if moving up after Body snatch, & Body shot away.


DoLander_14	move.w	Anim_YPos(a0),d1	;check height
		add.w	#20,d1
		move.l	YTable(a6),a1	;get YTable offset
		add.w	d1,d1		;WORD index into YTable!
		move.w	0(a1,d1.w),d1
		cmp.w	LandYHgt(a6),d1	;at normal Landscape height?
		beq.s	DoLander_16	;skip if equal
		bhi.s	DoLander_17	;and skip if below landscape

		moveq	#1,d0
		move.w	d0,AO_YMove(a0)	;else make it move down

DoLander_17	rts


* Come here if moving down after Body snatch, & Body shot away.


DoLander_15	move.w	Anim_YPos(a0),d1	;check height
		add.w	#20,d1
		move.l	YTable(a6),a1	;get YTable offset
		add.w	d1,d1		;WORD index into YTable!
		move.w	0(a1,d1.w),d1
		cmp.w	LandYHgt(a6),d1	;at normal Landscape height?
		beq.s	DoLander_16	;skip if equal
		bcs.s	DoLander_17	;and skip if above landscape

		moveq	#-1,d0
		move.w	d0,AO_YMove(a0)	;else make it move up
		rts


* Come here if normal Lander service is to be resumed.


DoLander_16	clr.w	AO_YMove(a0)	;stop vertical movement
		move.b	AO_Flags(a0),d0	;signal no longer lost Body
		and.b	#_NAOF_LOSTIT,d0
		move.b	d0,AO_Flags(a0)
		move.w	Seed(a6),d0	;get random number
		bmi.s	DoLander_18	;skip if negative
		moveq	#2,d0
		move.w	d0,AO_XMove(a0)	;restore horizontal movement
		rts

DoLander_18	moveq	#-2,d0
		move.w	d0,AO_XMove(a0)	;restore horizontal movement
		rts


* MutantCode(a0,a6)
* a0 = ptr to AO_ struct for mutant
* a6 = ptr to main program vars

* Initialise Mutant position etc.


MutantCode	bsr	Random			;make new random no.
		move.w	Seed(a6),d0		;get random number
		and.w	#1,d0			;0 or 1
		add.w	d0,d0			;word index
		lea	MutantStart(a6),a1	;ptr to Mutant x pos'n
		move.w	0(a1,d0.w),d0		;get which one
		move.l	Seed(a6),d1		;random number again
		move.l	d1,d2			;copy it
		and.w	#$7F,d1			;range=0 to 127
		add.b	d1,d1			; x 2
		ext.w	d1			;make negative if so
		asr.w	#1,d1			;/2 again
		add.w	d1,d0			;add to start x pos
		and.w	MaxScrPos(a6),d0		;normalise to screen
		move.w	d0,Anim_XPos(a0)		;this is X position
		rol.w	#4,d2			;get random number
		and.w	#$3F,d2			;range=0 to 63
		add.w	#MIN_SY,d2		;add on minimum y pos
		move.w	d2,Anim_YPos(a0)		;this is Y position

;		bsr	SetPos		;set position

		lea	DoMutant(pc),a1		;mutant controller
		move.l	a1,AO_SpecialCode(a0)	;point to it

		rts


* DoMutant(a0,a6)


DoMutant		move.b	AO_Flags(a0),d0	;check alien status
		move.b	d0,d1
		and.b	#_AOF_HIT,d0	;hit by laser?
		beq.s	DoMutant_3	;skip if not
		eor.b	#_AOF_HIT,d1
		move.b	d1,AO_Flags(a0)
		and.b	#_NANF_SAMEFRAME,Anim_Flags(a0)
		
DoMutant_3	move.b	Anim_Flags(a0),d0		;check Anim flags
		and.b	#_ANF_SAMEFRAME,d0	;not animating?
		bne.s	DoMutant_4		;skip if not

		move.l	Anim_CFrame(a0),a1
		move.l	AnFr_Next(a1),d0		;done explosion
		cmp.l	d0,a1			;animating?
		bne.s	DoMutant_4		;skip if not

		move.b	#_AOF_DYING,d0	;else this object is
		move.b	d0,AO_Flags(a0)	;dying...

		move.l	CurrentPlayer(a6),a1
		subq.w	#1,pd_Mutants(a1)


* Here, check to see if we're playing Defender Plus. If so, allow
* power-ups to be dropped.


		tst.b	GamePlus(a6)		;which game?
		beq.s	DoMutant_2x		;skip if Classic


* Here, we're playing Defender Plus. Allow this AO_ structure to be re-used
* for the Power-Up. Here determine whether or not we'll have a power-up, &
* if not, set the re-use pointer to zero.


		moveq	#0,d0		;reuse pointer

		bsr	Random		;make a random number
		move.w	Seed(a6),d1	;get it
		and.w	#$0F,d1		;lowest 4 bits zero?
		bne.s	DoMutant_2y	;skip if not


* Here, we're having a power-up, so set the re-use pointer to
* point to this dead Mutant's AO_ struct.


		move.l	a0,d0

DoMutant_2y	move.l	d0,PuPtr(a6)
		move.l	CurrentPlayer(a6),a1
		move.l	d0,pd_PuPtr(a1)

DoMutant_2x	rts


DoMutant_4	bsr	Random
		move.l	Seed(a6),d0	;get random number
		and.w	#$0F,d0
		subq.w	#8,d0		;this is X add-on (-8 to +7)
		swap	d0
		and.w	#$0F,d0
		subq.w	#8,d0		;this is Y add-on (-8 to +7)

		move.w	Anim_YPos(a0),d1	;get Y position
		add.w	d0,d1		;new Y position
		cmp.w	#MIN_SY,d1	;off top of screen?
		bcc.s	DoMutant_1	;skip if not
		move.w	#MAX_SY,d1	;else put on bottom
DoMutant_1	cmp.w	#MAX_SY,d1	;off bottom of screen?
		bls.s	DoMutant_2	;skip if not
		move.w	#MIN_SY,d1	;else put on top
DoMutant_2	move.w	d1,Anim_YPos(a0)	;save new Y position
		swap	d0		;get X add-on
		move.w	Anim_XPos(a0),d1	;get X position
		add.w	d0,d1		;update it
		and.w	MaxScrPos(a6),d1	;constrain to screen limits
		move.w	d1,Anim_XPos(a0)	;& store back

		bsr	LMine		;& throw a missile

		rts


* BomberCode(a0,a6)
* a0 = ptr to AO_ struct for Bomber
* a6 = ptr to main program vars

* Initialise Bomber position, then set
* AO_SpecialCode to point to Bomber movement code.


BomberCode	move.l	BInitList(a6),a1		;initialiser list
		move.w	BomberCount(a6),d0	;counter
		move.w	d0,d1
		addq.w	#1,d1			;next one
		and.w	#7,d1
		move.w	d1,BomberCount(a6)	;save it for next time
		add.w	d0,d0			;adjust for
		add.w	d0,d0			;longword entries
		add.w	d0,a1			;point to entry
		move.w	(a1)+,Anim_XPos(a0)	;get start x pos
		move.w	(a1)+,AO_XMove(a0)	;get start x speed

		move.b	#_ANF_SAMEFRAME,d0
		move.b	d0,Anim_Flags(a0)
		clr.b	AO_Flags(a0)

		bsr	Random
		move.l	Seed(a6),d0		;initial counter
		and.w	#$1FF,d0			;constrain to limits
		move.w	d0,AO_BCount(a0)		;and save
		add.w	d0,d0			;adjust for word size
		move.l	BomberList(a6),a1		;point to curve
		move.w	0(a1,d0.w),d0		;get curve Y pos
		move.w	d0,Anim_YPos(a0)		;and save it
		clr.w	AO_YMove(a0)

		lea	DoBomber(pc),a1
		move.l	a1,AO_SpecialCode(a0)

		rts


* DoBomber(a0,a6)
* a6 = ptr to main program variables
* a0 = ptr to Bomber's AO_ structure

* Perform Bomber functions.


DoBomber		move.b	AO_Flags(a0),d0	;check alien status
		move.b	d0,d1
		and.b	#_AOF_HIT,d0	;hit by laser?
		beq.s	DoBomber_2	;skip if not
		eor.b	#_AOF_HIT,d1
		move.b	d1,AO_Flags(a0)
		and.b	#_NANF_SAMEFRAME,Anim_Flags(a0)

DoBomber_2	move.b	Anim_Flags(a0),d0		;check Anim flags
		and.b	#_ANF_SAMEFRAME,d0	;not animating?
		bne.s	DoBomber_1		;skip if not

		move.l	Anim_CFrame(a0),a1
		move.l	AnFr_Next(a1),d0		;done explosion
		cmp.l	d0,a1			;animating?
		bne.s	DoBomber_1		;skip if not

		move.b	#_AOF_DYING,d0	;else this object is
		move.b	d0,AO_Flags(a0)	;dying...

		move.l	CurrentPlayer(a6),a1
		subq.w	#1,pd_Bombers(a1)

		rts

DoBomber_1	move.w	Anim_XPos(a0),d0	;current x coord
		add.w	AO_XMove(a0),d0	;movement value
		and.w	MaxScrPos(a6),d0	;constrain to screen
		move.w	d0,Anim_XPos(a0)	;replace x coord

		move.w	AO_BCount(a0),d0	;get current Bomber count
		addq.w	#1,d0		;next one
		and.w	#$1FF,d0		;within curve limits
		move.w	d0,AO_BCount(a0)	;save new count
		move.l	BomberList(a6),a1	;get list
		add.w	d0,d0
		move.w	0(a1,d0.w),d0	;get new Y coord
		move.w	d0,Anim_YPos(a0)	;and store it

		bsr	BMine		;lay a mine

		rts


* BaiterOn(a6)
* a6 = ptr to main program variables

* Activate the Baiter when time's up. Use a 'count-up' clock &
* compare with preset alarm value. When alarm value matched or
* exceeded, activate a Baiter!

* d0/a1 corrupt


BaiterOn		move.l	CurrentPlayer(a6),a0	;this player
		move.l	pd_BaiterClock(a0),d0	;check count-up
		move.l	pd_BaiterAlarm(a0),d1
		addq.l	#1,d0
		cmp.l	d1,d0			;ready for the off?
		bcs.s	BON_1			;skip if not


* Here, we've run out of time. Activate the dreaded Baiter.


		move.l	pd_BaiterPtr(a0),a1	;ptr to Baiter
		move.b	Anim_Flags(a1),d0		;get flags
		and.b	#_ANF_DISABLED,d0		;already dead?
		bne.s	BON_2			;bring to life if so

		move.l	Anim_Next(a1),a1		;2nd Baiter
		move.b	Anim_Flags(a1),d0		;get flags
		and.b	#_ANF_DISABLED,d0		;already dead?
		bne.s	BON_2			;bring to life if so

		move.l	Anim_Next(a1),a1		;3rd Baiter
		move.b	Anim_Flags(a1),d0		;get flags
		and.b	#_ANF_DISABLED,d0		;already dead?
		bne.s	BON_2			;bring to life if so

		move.l	Anim_Next(a1),a1		;4th Baiter
		move.b	Anim_Flags(a1),d0		;get flags
		and.b	#_ANF_DISABLED,d0		;already dead?
		beq.s	BON_3			;exit if not


* Come here if one of the Baiter AO_ structures has _ANF_DISABLED set
* (in other words it's awaiting activation).


BON_2		move.w	Anim_ID(a1),d0		;now see if it's
		cmp.w	#_AL_BAITER,d0		;reserved for a
		bne.s	BON_3			;Baiter


* We come here ONLY if the structure is free, AND it's ID code
* is that of a Baiter (preset by InitSet() beforehand).


		move.b	#_ANF_SAMEFRAME,Anim_Flags(a1)	;Activate it!
		st	BAlert(a6)


* Here reset the alarm so that the next Baiter appears after 30 seconds
* so that if the player kills the old one off, he'll find reinforcements
* to hand!


		moveq	#0,d0
		move.w	#$300,d0
		move.l	d0,pd_BaiterAlarm(a0)


* Come straight here if time isn't up. Reset the clock for the next
* Baiter if we've got one (or there isn't one online to activate).


BON_3		moveq	#0,d0			;reset clock

BON_1		move.l	d0,pd_BaiterClock(a0)
		rts


* BaiterCode(a0,a6)
* a0 = ptr to AO_Struct for calling Baiter
* a6 = ptr to main program variables

* Initialise the Baiter and set it running. This code is pre-loaded into
* the AO_SpecialCode entry of the AO_ sturct, and gets called once the
* BaiterOn() code above enables this struct for BlitPreComp().


BaiterCode	move.l	SVStartup(a6),a1	;ptr to SpecialValues
		add.w	#72,a1		;point to Baiter entry

		move.w	(a1)+,AO_Points(a0)	;initialise the
		move.w	(a1)+,AO_XMove(a0)	;relevant Baiter
		move.w	(a1)+,AO_YMove(a0)	;structure entries
		move.w	(a1)+,AO_XOff(a0)
		move.w	(a1)+,AO_YOff(a0)
		move.w	(a1)+,AO_XDisp(a0)
		move.w	(a1)+,AO_YDisp(a0)
		move.w	(a1)+,AO_YLDisp(a0)
		move.w	(a1)+,AO_ScanMsk1(a0)
		move.w	(a1)+,AO_ScanMsk2(a0)

		move.l	AlienAnFr+12(a6),d0	;set image ptrs
		move.l	d0,Anim_Frames(a0)	;for Baiter
		move.l	d0,Anim_CFrame(a0)


* This next lot is for safety's sake.


		move.w	#_AL_BAITER,Anim_ID(a0)	;set Baiter ID

		move.b	#_ANF_SAMEFRAME,Anim_Flags(a0)
		clr.b	AO_Flags(a0)


* Now set initial Baiter position & movement values.


		move.w	CurrXPos(a6),d0
		move.w	MaxScrPos(a6),d1
		move.w	d1,d2
		lsr.w	#1,d2
		add.w	d2,d0
		and.w	d1,d0
		move.w	d0,Anim_XPos(a0)
		move.w	#128,Anim_YPos(a0)

		move.w	Seed(a6),d0	;get random number
		move.w	d0,d1
		smi	d0
		ext.w	d0		;this creates -1 or 0

		tst.w	d1
		spl	d1
		ext.w	d1
		neg.w	d1		;this creates +1 or 0

		add.w	d1,d0
		move.w	d0,AO_YMove(a0)
		clr.w	AO_XMove(a0)


* Now set up the AO_SpecialCode to point to the Baiter's own
* operational code.


		lea	DoBaiter(pc),a1
		move.l	a1,AO_SpecialCode(a0)

		rts


* DoBaiter(a0,a6)
* a0 = ptr to AO_ structure for calling Baiter
* a6 = ptr to main program variables

* Make Baiter fly.


DoBaiter		move.b	AO_Flags(a0),d0	;check alien status
		move.b	d0,d1
		and.b	#_AOF_HIT,d0	;hit by laser?
		beq.s	DoB_1		;skip if not

		eor.b	#_AOF_HIT,AO_Flags(a0)
		and.b	#_NANF_SAMEFRAME,Anim_Flags(a0)

DoB_1		move.b	Anim_Flags(a0),d2		;check Anim flags
		and.b	#_ANF_SAMEFRAME,d2	;not animating?
		bne.s	DoB_2			;skip if not

		move.l	Anim_CFrame(a0),a1
		move.l	AnFr_Next(a1),d2		;done explosion
		cmp.l	d2,a1			;animating?
		bne.s	DoB_2			;skip if not

		move.b	#_AOF_DYING,d2	;else this object is
		move.b	d2,AO_Flags(a0)	;dying...

		clr.b	BAlert(a6)	;end the Baiter alert...


* Do this to allow the Baiter to be 'recycled' as it were
* so that when it's shot, we can obtain another one...


		lea	BaiterCode(pc),a1
		move.l	a1,AO_SpecialCode(a0)

		rts


* Here make Baiter move.


DoB_2		move.w	Anim_XPos(a0),d0	;current x coord
		add.w	AO_XMove(a0),d0	;movement value
		and.w	MaxScrPos(a6),d0	;constrain to screen
		move.w	d0,Anim_XPos(a0)	;replace x coord

		move.w	Anim_YPos(a0),d0	;change y position
		add.w	AO_YMove(a0),d0
		cmp.w	#MIN_SY,d0	;too small?
		bcc.s	DoB_3		;skip if not
		move.w	#MAX_SY,d0	;else vertical wrap around

DoB_3		cmp.w	#MAX_SY,d0	;too large?
		bls.s	DoB_4		;skip if not
		move.w	#MIN_SY,d0	;else vertical wrap around

DoB_4		move.w	d0,Anim_YPos(a0)	;else set it


* Now make Baiter pursue the Defender ship. Accelerate until
* the Baiter is sufficiently close, then maintain speed while
* hurling missiles...


		move.l	ShipAnim(a6),a1
		move.w	Anim_XPos(a1),d1	;ship PLOT position

		move.w	MaxScrPos(a6),d2
		move.w	d2,d3
		lsr.w	#1,d3		;needed later

		move.w	Anim_XPos(a0),d0	;baiter TRUE position
		add.w	CurrXPos(a6),d0
		and.w	d2,d0		;baiter PLOT position

		sub.w	d1,d0		;baiter xp - ship xp
		and.w	d2,d0		;normalised
		cmp.w	d3,d0		;where is Baiter?
		bhi.s	DoB_5		;skip if right of ship

		cmp.w	#$2000-80,d0	;really close to ship?
		bhi.s	DoB_8		;skip if so

		move.w	AO_XMove(a0),d0	;Baiter speed
		subq.w	#1,d0		;faster <- direction
		cmp.w	#-BAITERSPD,d0	;too fast?
		blt.s	DoB_7		;skip if so
		move.w	d0,AO_XMove(a0)	;else set speed
		bra.s	DoB_7


DoB_5		cmp.w	#80,d0		;really close to ship?
		bcs.s	DoB_9		;skip if so

		move.w	AO_XMove(a0),d0	;Baiter speed
		addq.w	#1,d0		;faster -> direction
		cmp.w	#BAITERSPD,d0	;too fast?
		bgt.s	DoB_7		;skip if so
		move.w	d0,AO_XMove(a0)	;else set speed
		bra.s	DoB_7


* Here, if the Baiter is sufficiently close to the Defender, match
* its speed to the Defender's speed & start throwing missiles at it
* just to make life VERY hard...!


DoB_8		move.w	CurrXSpeed(a6),d0	;match speed to Defender
		move.w	d0,AO_XMove(a0)
		bra.s	DoB_7

DoB_9		move.w	CurrXSpeed(a6),d0	;match speed to Defender
		neg.w	d0
		move.w	d0,AO_XMove(a0)


* Now launch a few missiles...


DoB_7		bsr	XMine

		rts


* Swarmer code. Just set them up as SAMEFRAME and DISABLED anims
* and then leave. Also set up the list pointers if they don't
* exist. Pod code sets up swarmers when pods burst.


SwarmerCode	tst.l	SwarmerList(a6)	;list pointer set up?
		bne.s	SwrC_3		;skip if so

		move.l	a0,SwarmerList(a6)	;set up list
		move.l	a0,SwarmerPtr(a6)		;pointers

		move.l	CurrentPlayer(a6),a1
		move.l	a0,pd_SwarmerList(a1)
		move.l	a0,pd_SwarmerPtr(a1)

SwrC_3		move.b	#_ANF_SAMEFRAME+_ANF_DISABLED,d0

		move.b	d0,Anim_Flags(a0)

		rts


* In the code below, keep a careful eye on D1.


DoSwarmer	move.b	AO_Flags(a0),d0	;check alien status
		move.b	d0,d1
		and.b	#_AOF_HIT,d0	;hit by laser?
		beq.s	DoSwarmer_2	;skip if not

		eor.b	#_AOF_HIT,AO_Flags(a0)
		and.b	#_NANF_SAMEFRAME,Anim_Flags(a0)
		bra.s	DoSwarmer_3

DoSwarmer_2	move.b	Anim_Flags(a0),d2		;check Anim flags
		and.b	#_ANF_SAMEFRAME,d2	;not animating?
		bne.s	DoSwarmer_1		;skip if not

		move.l	Anim_CFrame(a0),a1
		move.l	AnFr_Next(a1),d2		;done explosion
		cmp.l	d2,a1			;animating?
		bne.s	DoSwarmer_1		;skip if not

		move.b	#_AOF_DYING,d2	;else this object is
		move.b	d2,AO_Flags(a0)	;dying...

		move.l	CurrentPlayer(a6),a1
		subq.w	#1,pd_Swarmers(a1)

		rts

DoSwarmer_1	and.b	#_AOF_ERUPT,d1	;swarmer erupting?
		beq.s	DoSwarmer_3	;skip if not

		subq.w	#1,AO_Generic(a0)	;done erupting?
		bne.s	DoSwarmer_3

		bsr	Random
		move.l	Seed(a6),d0	;get random no.
		tst.l	d0
		spl	d1	;this is -1 if result >=0
		smi	d2	;this is -1 if result <0
		neg.b	d1	;this is +1 if result >=0
		add.b	d1,d2
		ext.w	d2
		add.w	d2,d2
		move.w	d2,AO_XMove(a0)

		tst.w	d0
		spl	d1	;this is -1 if result >=0
		smi	d2	;this is -1 if result <0
		neg.b	d1	;this is +1 if result >=0
		add.b	d1,d2
		ext.w	d2
		add.w	d2,d2
		move.w	d2,AO_YMove(a0)

		rts


DoSwarmer_3	move.w	Anim_XPos(a0),d0	;current x coord
		add.w	AO_XMove(a0),d0	;movement value
		and.w	MaxScrPos(a6),d0	;constrain to screen
		move.w	d0,Anim_XPos(a0)	;replace x coord

		move.w	Anim_YPos(a0),d0	;change y position
		add.w	AO_YMove(a0),d0
		cmp.w	#MIN_SY,d0	;too small?
		bcc.s	DoSwr_1		;skip if not
		move.w	#MAX_SY,d0	;else vertical wrap around

DoSwr_1		cmp.w	#MAX_SY,d0	;too large?
		bls.s	DoSwr_2		;skip if not
		move.w	#MIN_SY,d0	;else vertical wrap around

DoSwr_2		move.w	d0,Anim_YPos(a0)	;else set it

		bsr	SMine		;and make player's life hard...

		rts


* This code initialises the Pods.


PodCode		bsr	Random
		move.l	Seed(a6),d0	;get random number
		and.w	#$FF,d0
		sub.w	#$7F,d0
		add.w	PodBasePos(a6),d0	;set x position
		and.w	MaxScrPos(a6),d0
		move.w	d0,Anim_XPos(a0)
		swap	d0
		and.w	#$7F,d0
		add.w	#MIN_SY+2,d0	;create random Y position
		move.w	d0,Anim_YPos(a0)	;save it

		moveq	#1,d0
		move.w	d0,AO_YMove(a0)
		moveq	#2,d0
		move.w	d0,AO_XMove(a0)	;pod movement speed=(+4,+1)

		moveq	#10,d0
		move.w	d0,AO_Generic(a0)	;no of swarmers when split

		bsr	Random		;leave this in!
		move.l	Seed(a6),d0
		tst.l	d0		
		bpl.s	PodC_1
		neg.w	AO_XMove(a0)	;negate x & y speeds according
PodC_1		tst.w	d0		;to random seed value
		bpl.s	PodC_2
		neg.w	AO_YMove(a0)
PodC_2		lea	DoPod(pc),a1
		move.l	a1,AO_SpecialCode(a0)	;now change PodCode

		rts


* This executed for Pod movement & splitting into Swarmers when
* pod is hit by laser bolt...


DoPod		move.b	AO_Flags(a0),d0	;check alien status
		move.b	d0,d1
		and.b	#_AOF_HIT,d0	;hit by laser?
		beq	DoPod_1		;skip if not (.s)


* Here, start spitting out swarmers! Why does this cause VBL
* flicker I wonder...it isn't this so look at the swarmer code!


		move.l	SwarmerPtr(a6),a1	;ptr to Swarmer list...
		move.l	SSIStartup(a6),a2	;ptr to Startup list...

		move.w	Anim_ID(a1),d0	;get ID
		cmp.w	#_AL_SWARMER,d0	;genuine swarmer?
		bne.s	DoPod_3		;skip if not

		bsr	Random
		move.l	Seed(a6),d0
		and.w	#$F,d0		;random 0 to 15
		add.w	d0,d0
		add.w	d0,d0
		add.w	d0,d0		;*8 for entry size
		add.w	d0,a2

		move.w	(a2)+,AO_XMove(a1)
		move.w	(a2)+,AO_YMove(a1)
		move.w	(a2)+,AO_Generic(a1)
		move.b	(a2)+,Anim_Flags(a1)
		move.b	(a2)+,AO_Flags(a1)
;		or.b	#_ANF_DISABLED,Anim_Flags(a1)

		move.w	Anim_XPos(a0),Anim_XPos(a1)
		move.w	Anim_YPos(a0),Anim_YPos(a1)

		lea	DoSwarmer(pc),a2
;		lea	DoSwarmer_3(pc),a2
		move.l	a2,AO_SpecialCode(a1)

DoPod_3		move.l	Anim_Next(a1),d0	;get next ptr
		beq.s	DoPod_4		;none left!
		move.l	d0,SwarmerPtr(a6)	;else save this back

		move.l	CurrentPlayer(a6),a1
		move.l	d0,pd_SwarmerPtr(a1)

DoPod_4		subq.w	#1,AO_Generic(a0)	;done them all?
		beq.s	DoPod_7		;skip if so
		rts			;else leave now

DoPod_7		move.b	#_AOF_DYING,d0	;now this pod is
		move.b	d0,AO_Flags(a0)	;dying...

		move.l	CurrentPlayer(a6),a1
		subq.w	#1,pd_Pods(a1)

		rts


* This is the quick Pod code that causes no problems...


DoPod_1		move.w	Anim_XPos(a0),d0	;change X position
		add.w	AO_XMove(a0),d0
		and.w	MaxScrPos(a6),d0	;constrain to screen limits
		move.w	d0,Anim_XPos(a0)

		move.w	Anim_YPos(a0),d0	;change y position
		add.w	AO_YMove(a0),d0
		cmp.w	#MIN_SY,d0	;too small?
		bcc.s	DoPod_5		;skip if not
		move.w	#MAX_SY,d0	;else vertical wrap around

DoPod_5		cmp.w	#MAX_SY,d0	;too large?
		bls.s	DoPod_6		;skip if not
		move.w	#MIN_SY,d0	;else vertical wrap around

DoPod_6		move.w	d0,Anim_YPos(a0)	;else set it

		move.l	AO_ScanMsk1(a0),d1	;change scanner
		not.l	d1
		not.w	d1			;dot colour for
		move.l	d1,AO_ScanMsk1(a0)	;Pod

		rts


* SetPos(a0)
* a0 = ptr to AO_ structure

* Initialise starting position of object.

* d0 corrupt

SetPos		bsr	Random
		move.l	Seed(a6),d0	;get random value
		and.w	MaxScrPos(a6),d0	;create random X position
		swap	d0
		and.w	#$7F,d0
		add.w	#MIN_SY+2,d0	;create random Y position
		move.w	d0,Anim_YPos(a0)	;save it
		swap	d0
		move.w	d0,Anim_XPos(a0)	;and the X position too
		rts			;byeee!


* Mine/Missile Handling System.


* InitMines(a6)
* a6 = ptr to main program variables

* Initialise the Mine/Missile arrays.

* d0-d1/a0-a1 corrupt


InitMines	move.l	MineArray(a6),a0	;ptr to Mine Structure Array
		move.l	MineFree(a6),a1	;ptr to Mine Free Array

		moveq	#0,d0		;initial mine index
		moveq	#_MA_SIZE,d1	;no. of entries

IMin_1		move.b	#_MDF_FREE,md_Type(a0)	;set type
		move.b	d0,md_Index(a0)		;set index no.
		clr.b	(a1)+			;set free entry
		add.w	#md_Sizeof,a0		;next element
		subq.w	#1,d1			;done them all?
		bne.s	IMin_1			;skip if not
		rts


* DoMines(a6)
* a6 = ptr to main program variables

* Handle the mines/missiles.

* d0-d6/a0-a2 corrupt


DoMines		move.l	MineArray(a6),a0	;ptr to Mine/Missile array

		moveq	#_MA_SIZE,d4	;no. of entries

		move.w	#9240,d5		;top of screen limit
		move.w	#29040,d6	;bottom of screen limit

DOM_1		moveq	#0,d0
		moveq	#0,d1

		move.b	md_Type(a0),d0	;get entry type
		bne.s	DOM_2		;skip if not free

		add.w	#md_Sizeof,a0	;next array entry
		subq.w	#1,d4		;done them all?
		bne.s	DOM_1		;back for more if not

		rts

DOM_2		subq.w	#1,d0		;get graphic index
		add.w	d0,d0		;longword index!
		add.w	d0,d0
		lea	MineImages(a6),a1
		add.w	d0,a1
		move.l	(a1),d0		;save ptr to image

		move.l	YTable(a6),a1
		move.w	md_YPos(a0),d1
		add.w	d1,d1
		move.w	0(a1,d1.w),d1	;get YTable offset
		swap	d1		;save it

;		move.w	MaxScrPos(a6),d1	;get true X plot position
;		addq.w	#1,d1
;		sub.w	md_XPos(a0),d1

		move.w	md_XPos(a0),d1	;get X position
		add.w	CurrXPos(a6),d1	;on screen?
		and.w	MaxScrPos(a6),d1

		cmp.w	#320,d1
		bcc	DOM_5		;skip if not on screen
		move.w	d1,d2		;copy it
		and.w	#$F,d1		;shift value
		lsr.w	#4,d2
		add.w	d2,d2		;word offset
		swap	d1
		add.w	d2,d1		;total offset
		swap	d1		;swap in shift count


* Here : D0 = image ptr, D1 = offset|shift. Create shifted mine image
* for plotting.


		move.l	d0,a1
		move.l	MineBuffer(a6),a2
		move.l	a2,d2		;save buffer ptr

		move.l	(a1)+,d3		;shift N times
		lsr.l	d1,d3		;for correct
		move.l	d3,(a2)+		;pixel alignment
		move.l	(a1)+,d3
		lsr.l	d1,d3
		move.l	d3,(a2)+
		move.l	(a1)+,d3
		lsr.l	d1,d3
		move.l	d3,(a2)+

		move.l	d2,a1		;ptr to shifted mine image

		move.l	RasterWaiting(a6),a2
		addq.l	#2,a2

		clr.w	d1
		swap	d1
		cmp.w	d5,d1		;off top of playfield?
		bcs	DOM_5
		cmp.w	d6,d1		;off bottom of playfield?
		bhi	DOM_5

		add.l	d1,a2		;screen ptr

		move.l	(a1)+,d1
		or.l	d1,(a2)		;plot 1st line
		add.w	#BP_NEXTLINE,a2
		move.l	(a1)+,d1
		or.l	d1,(a2)		;plot 2nd line
		add.w	#BP_NEXTLINE,a2
		move.l	(a1)+,d1
		or.l	d1,(a2)		;plot 3rd line


* Here, see if we've hit the ship. Note corrections for centre of
* ship! Also, check if we have a shield enabled, and if so, the
* mines don't have any effect.


		move.b	PwrUpOn(a6),d0	;check if shield is on
		and.b	#_PU_SHLD,d0
		bne.s	DOM_6		;skip check if on!

		move.w	md_XPos(a0),d0
		add.w	CurrXPos(a6),d0
		and.w	MaxScrPos(a6),d0
		move.w	md_YPos(a0),d1
		move.l	ShipAnim(a6),a1
		move.w	Anim_XPos(a1),d2
		addq.w	#7,d2
		move.w	Anim_YPos(a1),d3
		addq.w	#4,d3

		sub.w	d2,d0	;xmine-xship
		bpl.s	DOM_7
		neg.w	d0	;abs(...)

DOM_7		sub.w	d3,d1	;ymine-yship
		bpl.s	DOM_8
		neg.w	d1	;abs(...)

DOM_8		and.w	#$FFF8,d0	;hit ship?
		bne.s	DOM_6		;no we haven't
		and.w	#$FFFC,d1	;hit ship?
		bne.s	DOM_6		;no we haven't

		move.b	#_AOF_HIT,AO_Flags(a1)	;signal hit


* Here, after we've plotted, check if we're to do any more &
* set this entry as free if not.


DOM_6		move.w	md_XPos(a0),d0	;here change X & Y
		add.w	md_XMove(a0),d0	;position of mine/missile
		and.w	MaxScrPos(a6),d0
		move.w	d0,md_XPos(a0)

		move.w	md_YPos(a0),d0
		add.w	md_YMove(a0),d0
		and.w	MaxScrPos(a6),d0
		move.w	d0,md_YPos(a0)

DOM_4		subq.w	#1,md_Count(a0)	;check index
		bne.s	DOM_3		;still operational

DOM_5		moveq	#0,d0
		move.b	md_Index(a0),d0	;get MineFree index
		move.l	MineFree(a6),a1
		clr.b	0(a1,d0.w)	;set it as free
		clr.b	md_Type(a0)	;set _MDF_FREE also
		
DOM_3		add.w	#md_Sizeof,a0	;next entry
		subq.w	#1,d4		;done them all?
		bne	DOM_1		;back for more if not

		rts


* StopMines(a6)
* a6 = ptr to main program variables

* This routine stops all mine/missile activity currently pending
* in the MineArray.

* d0-d1/a0-a1 corrupt


StopMines	move.l	MineArray(a6),a0

		moveq	#_MA_SIZE,d0

SMN_1		clr.b	md_Type(a0)	;set type to _MDF_FREE
		moveq	#0,d1
		move.b	md_Index(a0),d1	;get index into FreeArray
		move.l	MineFree(a6),a1	;ptr to array
		clr.b	0(a1,d1.w)	;set as free
		add.w	#md_Sizeof,a0	;next MineArray entry
		subq.w	#1,d0		;done them all?
		bne.s	SMN_1		;back for more if not

		rts			;and done.


* Alien mine/missile launching code.

* All of the routines above follow a similar stratagem. First see
* if the alien is visible. If not, leave NOW. If visible, see if the
* next MineArray entry is free. If not, exit.

* Once a free MineArray entry is gotten, do a 'coin-toss' type
* calculation (get random number, check if equal to threshold)
* to see if this time the alien will launch a missile. If this
* is not the case, exit. If so, create the MineArray entry for
* the appropriate object.

* Landers spit missiles in all directions, as do Mutants &
* Baiters. The 'persistence' of these is random (some disappear
* quickly, others last long enough to hit you-you don't know
* which!). Swarmers spit them out in the same direction as they
* are moving across the screen, but in the OPPOSITE vertical
* direction to make your escape harder!

* Bombers lay mines of random persistence in their path. If you
* fly into them, doom time! Some last a VERY long time...



* LMine(a0,a6)
* a0 = ptr to Lander AO_ structure for caller
* a6 = ptr to main program vars

* Generate a missile if at all possible, and insert into the
* mine/missile list. Called by Lander SpecialCode to shoot a
* missile at the Defender ship.

* a0 MUST be left untouched!

* d0-d2/a1 corrupt


LMine		move.b	Anim_Flags(a0),d0	;check if on screen
		and.b	#_ANF_NOSHOW,d0
		beq.s	LMine_1		;skip if visible
		rts			;else exit

LMine_1		move.l	MineFree(a6),a1	;check if this mine/missile
		move.w	MineIndex(a6),d0	;slot is free
		move.w	d0,d2
		tst.b	0(a1,d0.w)
		beq.s	LMine_2		;skip if free

		addq.w	#1,d0		;next missile slot
		cmp.w	#_MA_SIZE,d0	;array bounds check
		bcs.s	LMine_3		;skip if within bounds
		moveq	#0,d0		;else loop back to start

LMine_3		move.w	d0,MineIndex(a6)	;and set new mine index
		rts			;exit


* Here, we have a free Mine Array slot for our Lander's use. Let the
* Lander insert an entry here, and set up for the next mine entry.


LMine_2		addq.w	#1,d2		;next missile slot
		cmp.w	#_MA_SIZE,d2	;array bounds check
		bcs.s	LMine_5		;skip if within bounds
		moveq	#0,d2		;else loop back to start

LMine_5		move.w	d2,MineIndex(a6)	;and set new mine index

		move.w	d0,d1		;md_ struct is 12 bytes:
		add.w	d0,d0		;this is a quick x 12
		add.w	d1,d0		;to index the correct
		add.w	d0,d0		;element
		add.w	d0,d0

		move.l	MineArray(a6),a1
		add.w	d0,a1		;point to element


* This lot uses the Lander's position & movement data to generate a
* Missile. It also uses the Lander's movement plus a random pertur-
* bation factor. Uses random number to determine if we are actually
* loosing off a missile:should only happen on average once every
* 16 calls...


		bsr	Random		;new random number

		move.w	Seed(a6),d0	;are we doing it?
		and.w	#$F000,d0
		beq.s	LMine_4		;skip if so
		rts

LMine_4		move.w	Anim_XPos(a0),d0
		addq.w	#5,d0
		move.w	d0,md_XPos(a1)
		move.w	Anim_YPos(a0),d0
		addq.w	#5,d0
		move.w	d0,md_YPos(a1)
		move.b	#_MDF_MISSILE,md_Type(a1)
		move.w	AO_XMove(a0),d0
		move.w	Seed(a6),d1
		and.w	#$0F,d1
		sub.w	#$07,d1
		add.w	d1,d0
		move.w	d0,md_XMove(a1)
		move.w	AO_YMove(a0),d0
		move.l	Seed(a6),d1
		and.w	#$0F,d1
		sub.w	#$07,d1
		add.w	d1,d0
		move.w	d0,md_YMove(a1)
		moveq	#10,d0
		move.w	d0,md_Count(a1)

		moveq	#0,d0
		move.b	md_Index(a1),d0
		move.l	MineFree(a6),a1
		st	0(a1,d0.w)

		rts


* BMine(a0,a6)
* a0 = ptr to AO_ struct for calling Bomber
* a6 = ptr to main program variables

* Lay a mine.

* d0-d2/a1 corrupt


BMine		move.b	Anim_Flags(a0),d0	;check if on screen
		and.b	#_ANF_NOSHOW,d0
		beq.s	BMine_1		;skip if visible
		rts			;else exit

BMine_1		move.l	MineFree(a6),a1	;check if this mine/missile
		move.w	MineIndex(a6),d0	;slot is free
		move.w	d0,d2
		tst.b	0(a1,d0.w)
		beq.s	BMine_2		;skip if free

		addq.w	#1,d0		;next missile slot
		cmp.w	#_MA_SIZE,d0	;array bounds check
		bcs.s	BMine_3		;skip if within bounds
		moveq	#0,d0		;else loop back to start

BMine_3		move.w	d0,MineIndex(a6)	;and set new mine index
		rts			;exit


BMine_2		addq.w	#1,d2		;next missile slot
		cmp.w	#_MA_SIZE,d2	;array bounds check
		bcs.s	BMine_4		;skip if within bounds
		moveq	#0,d2		;else loop back to start

BMine_4		move.w	d2,MineIndex(a6)	;and set new mine index


* Here, we have a free slot in the mine/missile array. Create a mine
* & lay it in the path described by the Bomber.


		move.w	d0,d1		;quick x 12 to index
		add.w	d0,d0		;into the MineArray
		add.w	d1,d0
		add.w	d0,d0
		add.w	d0,d0

		move.l	MineArray(a6),a1
		add.w	d0,a1		;point to free element


* Now lay the mine. Note position correction for centre of Bomber. First
* determine if we are actually laying, and if so, go do it.


		bsr	Random		;new random number

		move.w	Seed(a6),d0	;are we doing it?
		and.w	#$F000,d0
		beq.s	BMine_5		;skip if so
		rts

BMine_5		move.w	Anim_XPos(a0),d0
		addq.w	#2,d0
		move.w	Anim_YPos(a0),d1
		addq.w	#2,d1

		move.w	d0,md_XPos(a1)	;this position
		move.w	d1,md_YPos(a1)
		moveq	#0,d0
		move.l	d0,md_XMove(a1)	;no movement

		move.b	#_MDF_MINE,md_Type(a1)

		move.w	Seed(a6),d0
		and.w	#$0F,d0
		addq.w	#8,d0
		move.w	d0,md_Count(a1)	;random duration

		moveq	#0,d0
		move.b	md_Index(a1),d0
		move.l	MineFree(a6),a1
		st	0(a1,d0.w)

		rts


* SMine(a0,a6)
* a0 = ptr to AO_ Struct for calling Swarmer
* a6 = ptr to main program variables

* Let Swarmer pop a missile into play. Usual rules (see above)
* apply.

* d0-d2/a1 corrupt


SMine		move.b	Anim_Flags(a0),d0	;get flags
		and.b	#_ANF_NOSHOW,d0	;on screen?
		beq.s	SMine_1		;continue if so
		rts			;else exit

SMine_1		move.l	MineFree(a6),a1	;ptr to free list
		move.w	MineIndex(a6),d0	;check if this is free
		move.w	d0,d2
		tst.b	0(a1,d0.w)	;is it free?
		beq.s	SMine_2		;continue if so

		addq.w	#1,d0		;next MineIndex
		cmp.w	#_MA_SIZE,d0	;out of array bounds?
		bcs.s	SMine_3		;skip if not
		moveq	#0,d0		;else start from beginning

SMine_3		move.w	d0,MineIndex(a6)	;set for next call

		rts

SMine_2		addq.w	#1,d2		;next MineIndex
		cmp.w	#_MA_SIZE,d2	;for next call-see above
		bcs.s	SMine_4
		moveq	#0,d2

SMine_4		move.w	d2,MineIndex(a6)


* Here we've got a free Mine Array slot. Set up the missile.


		move.w	d0,d1		;quick x 12 again!
		add.w	d0,d0
		add.w	d1,d0
		add.w	d0,d0
		add.w	d0,d0

		move.l	MineArray(a6),a1
		add.w	d0,a1		;point to free entry


* Here, determine if we're actually launching a missile and if so,
* do it.


		bsr	Random
		move.w	Seed(a6),d0
		and.w	#$E000,d0
		beq.s	SMine_5
		rts


* Note position correction below for centre of Swarmer...


SMine_5		move.w	Anim_XPos(a0),d0
		move.w	Anim_YPos(a0),d1
		addq.w	#2,d0		;swarmer Centre
		addq.w	#2,d1
		move.w	AO_XMove(a0),d2
		add.w	d2,d2

		move.w	d0,md_XPos(a1)
		move.w	d1,md_YPos(a1)
		move.w	d2,md_XMove(a1)
		move.w	AO_YMove(a0),d2
		neg.w	d2
		move.w	d2,md_YMove(a1)
		move.b	#_MDF_MISSILE,md_Type(a1)
		moveq	#12,d0
		move.w	d0,md_Count(a1)

		moveq	#0,d0
		move.b	md_Index(a1),d0
		move.l	MineFree(a6),a1
		st	0(a1,d0.w)
		rts


* XMine(a0,a6)
* a0 = ptr to Baiter AO_ structure for caller
* a6 = ptr to main program vars

* Generate a missile if at all possible, and insert into the
* mine/missile list. Called by Baiter SpecialCode to shoot a
* missile at the Defender ship.

* a0 MUST be left untouched!

* d0-d2/a1 corrupt


XMine		move.b	Anim_Flags(a0),d0	;check if on screen
		and.b	#_ANF_NOSHOW,d0
		beq.s	XMine_1		;skip if visible
		rts			;else exit

XMine_1		move.l	MineFree(a6),a1	;check if this mine/missile
		move.w	MineIndex(a6),d0	;slot is free
		move.w	d0,d2
		tst.b	0(a1,d0.w)
		beq.s	XMine_2		;skip if free

		addq.w	#1,d0		;next missile slot
		cmp.w	#_MA_SIZE,d0	;array bounds check
		bcs.s	XMine_3		;skip if within bounds
		moveq	#0,d0		;else loop back to start

XMine_3		move.w	d0,MineIndex(a6)	;and set new mine index
		rts			;exit


* Here, we have a free Mine Array slot for our Lander's use. Let the
* Lander insert an entry here, and set up for the next mine entry.


XMine_2		addq.w	#1,d2		;next missile slot
		cmp.w	#_MA_SIZE,d2	;array bounds check
		bcs.s	XMine_5		;skip if within bounds
		moveq	#0,d2		;else loop back to start

XMine_5		move.w	d2,MineIndex(a6)	;and set new mine index

		move.w	d0,d1		;md_ struct is 12 bytes:
		add.w	d0,d0		;this is a quick x 12
		add.w	d1,d0		;to index the correct
		add.w	d0,d0		;element
		add.w	d0,d0

		move.l	MineArray(a6),a1
		add.w	d0,a1		;point to element


* This lot uses the Baiter's position & movement data to generate a
* Missile. It also uses the Baiter's movement plus a random pertur-
* bation factor. Uses random number to determine if we are actually
* loosing off a missile:should only happen on average once every
* 8 calls...


		bsr	Random		;new random number

		move.w	Seed(a6),d0	;are we doing it?
		and.w	#$E000,d0
		beq.s	XMine_4		;skip if so
		rts

XMine_4		move.w	Anim_XPos(a0),d0
		addq.w	#5,d0
		move.w	d0,md_XPos(a1)
		move.w	Anim_YPos(a0),d0
		addq.w	#5,d0
		move.w	d0,md_YPos(a1)
		move.b	#_MDF_MISSILE,md_Type(a1)
		move.w	AO_XMove(a0),d0
		move.w	Seed(a6),d1
		and.w	#$0F,d1
		sub.w	#$07,d1
		add.w	d1,d0
		move.w	d0,md_XMove(a1)
		move.w	AO_YMove(a0),d0
		move.l	Seed(a6),d1
		and.w	#$0F,d1
		sub.w	#$07,d1
		add.w	d1,d0
		move.w	d0,md_YMove(a1)
		moveq	#10,d0
		move.w	d0,md_Count(a1)

		moveq	#0,d0
		move.b	md_Index(a1),d0
		move.l	MineFree(a6),a1
		st	0(a1,d0.w)

		rts


* New Laser handling code. This code uses a different FireList structure,
* and also uses the 68000 to perform the plotting since it might solve a
* few collision problems that I'm having.

* The new Laser List is a ring (i.e., list tail joined back to head).
* Only uses one pointer entry though.

* Needs new fire button handling & collision detection given below!


* Needs:

		rsreset
ll_Next		rs.l	1	;ptr to next in list or NULL if last
ll_YPos		rs.w	1	;y coord
ll_LXPtr		rs.l	1	;LHS x ptr
ll_RXPtr		rs.l	1	;LHS y ptr
ll_LXPos		rs.w	1	;LHS x coord
ll_RXPos		rs.w	1	;RHS x coord
ll_LXVal		rs.w	1	;LHS plot word
ll_RXVal		rs.w	1	;RHS plot word
ll_Type		rs.b	1	;whether L to R or R to L
ll_Pad		rs.b	1

ll_Sizeof	rs.w	0

_LL_SIZE		equ	10


* InitLaserList(a6)
* a6 = ptr to main program variables

* Initialise the Laser list.

* d0-d1/a0-a1 corrupt


InitLaserList	move.l	LList(a6),a0	;ptr to 1st entry
		move.l	a0,LListEntry(a6)	;set 1st entry ptr
		move.l	a0,d0		;copy of ptr

		moveq	#_LL_SIZE,d1	;no. to do

ILL_1		move.l	a0,a1		;copy ptr
		add.w	#ll_Sizeof,a1	;ptr to next
		move.l	a1,ll_Next(a0)	;insert ptr
		subq.w	#1,d1		;done them all?
		beq.s	ILL_2		;skip if so
		move.l	a1,a0		;else point to next
		bra.s	ILL_1

ILL_2		move.l	d0,ll_Next(a0)	;here close the ring

		rts


* ClearLaserList(a6)
* a6 = ptr to main program variables

* Clear the Laser List coordinates to prevent re-appearance
* of laser shots when attack wave changes etc.

* d0-d1/a0 corrupt


ClearLaserList	move.l	LList(a6),a0	;ptr to Laser List
		move.l	a0,d0		;copy start ptr
		moveq	#0,d1		;clear value

CLLS_1		move.l	d1,ll_LXPos(a0)	;prevent firing
		move.l	ll_Next(a0),a0	;point to next entry
		cmp.l	d0,a0		;back to start of list?
		bne.s	CLLS_1		;back for more if not
		rts			;else done


* MakeLaserList(a6)
* a6 = ptr to main program variables

* Make LaserList. Create plotting entries, then ripple the
* coordinates.

* d0-d4/a0-a2 corrupt


MakeLaserList	move.l	YTable(a6),a1		;keep constant
		move.l	RasterWaiting(a6),a2	;and this
		addq.l	#2,a2			;overwide screen!

		lea	RHSLines(a6),a0
		move.l	a0,d0			;keep constant
		lea	LHSLines(a6),a0
		move.l	a0,d1			;keep constant

		move.l	LList(a6),a0	;ptr to Laser list

MLL_1		move.w	ll_YPos(a0),d2		;get y coord
		add.w	d2,d2			;word index
		move.w	0(a1,d2.w),d2		;get offset
		move.w	ll_LXPos(a0),d3
		moveq	#0,d4
		move.w	d3,d4			;copy it
		asr.w	#4,d4			;horiz. offset
		add.w	d4,d4			;WORD offset
		add.w	d2,d4			;total offset
		add.l	a2,d4
		move.l	d4,ll_LXPtr(a0)
		move.w	d3,d4
		and.w	#$0F,d4			;pixel offset
		add.w	d4,d4			;WORD index
		exg	d1,a2			;get LHS words
		move.w	0(a2,d4.w),d4		;get plot word
		move.w	d4,ll_LXVal(a0)		;and save it
		exg	d1,a2			;recover ptr

		move.w	ll_RXPos(a0),d3
		moveq	#0,d4
		move.w	d3,d4			;copy it
		asr.w	#4,d4			;horiz. offset
		add.w	d4,d4			;WORD offset
		add.w	d2,d4			;total offset
		add.l	a2,d4
		move.l	d4,ll_RXPtr(a0)
		move.w	d3,d4
		and.w	#$0F,d4			;pixel offset
		add.w	d4,d4			;WORD index
		exg	d0,a2			;get RHS words
		move.w	0(a2,d4.w),d4		;get plot word
		move.w	d4,ll_RXVal(a0)		;and save it
		exg	d0,a2			;recover ptr
	
		move.l	ll_Next(a0),d2		;get next ptr
		cmp.l	LList(a6),d2		;back to start?
		beq.s	MLL_2			;skip if end of list
		move.l	d2,a0			;else point ot next
		bra.s	MLL_1			;and back for more


* Come here when we've preprocessed the list for plotting.


MLL_2		rts


* PlotLaserList(a6)
* a6 = ptr to main program variables

* Plot Laser List and post-process the coordinates.

* d0-d3/a0-a2 corrupt


PlotLaserList	move.l	LList(a6),a0	;ptr to Laser List
		moveq	#-1,d3		;constant plot word

		moveq	#0,d0		;replace coords

PLL_1		move.l	ll_LXPos(a0),d1	;plot this one?
		beq.s	PLL_7		;skip if not

		move.l	ll_LXPtr(a0),a1	;get LHS and RHS plot ptrs
		move.l	ll_RXPtr(a0),a2

		cmp.l	a1,a2		;ptrs equal?
		bcs.s	PLL_8		;skip if LHS > RHS
		bne.s	PLL_2		;skip if LHS < RHS

		move.w	ll_LXVal(a0),d2	;create short laser fire
		and.w	ll_RXVal(a0),d2	;plot word
		or.w	d2,(a1)		;and plot it
		bra.s	PLL_3		;and skip now done

PLL_2		move.w	ll_LXVal(a0),d2	;get LHS plot word
		or.w	d2,(a1)+		;and plot it

PLL_5		cmp.l	a1,a2		;LHS ptr >= RHS ptr?
		bls.s	PLL_4		;skip if so

		or.w	d3,(a1)+		;else plot this word
		bra.s	PLL_5		;and back for more

PLL_4		move.w	ll_RXVal(a0),d2	;get RHS plot word
		or.w	d2,(a1)		;and plot it

PLL_3		tst.b	ll_Type(a0)	;is it L to R?
		beq.s	PLL_10		;skip if so


* Here, handle coordinate changes for right-to-left laser fire.


		move.l	ll_LXPos(a0),d1	;get LHS/RHS x coords
		swap	d1		;get LHS x coord
		cmp.w	#_LLHS,d1	;LHS >= LHS limit?
		blt.s	PLL_6		;skip if not
		sub.w	#16,d1		;else change it
		move.w	d1,ll_LXPos(a0)	;and replace
		bra.s	PLL_7		;and skip

PLL_6		move.w	d1,d2		;get LHS coords
		swap	d1		;get RHS coords
		cmp.w	d2,d1		;RHS<=LHS?
		ble.s	PLL_8		;skip if so
		sub.w	#24,d1		;else change it
		move.w	d1,ll_RXPos(a0)	;and replace
		bra.s	PLL_7		;and skip

PLL_8		move.l	d0,ll_LXPos(a0)	;here zero out entries

PLL_7		move.l	ll_Next(a0),d1	;end of list?
		cmp.l	LList(a6),d1
		beq.s	PLL_9		;skip if so
		move.l	d1,a0		;else point to next
		bra.s	PLL_1		;and go process it

PLL_9		rts


* Here, handle coordinate changes for left-to-right laser fire.


PLL_10		move.l	ll_LXPos(a0),d1	;get LHS/RHS coords
		cmp.w	#_LRHS,d1	;RHS < RHS limit?
		bge.s	PLL_11		;skip if not
		add.w	#16,d1		;else change it
		move.w	d1,ll_RXPos(a0)	;and replace
		bra.s	PLL_7		;and skip

PLL_11		move.w	d1,d2		;get RHS coords
		swap	d1		;get LHS coords
		cmp.w	d2,d1		;LHS>=RHS?
		bge.s	PLL_8		;skip if so
		add.w	#24,d1		;else change it
		move.w	d1,ll_LXPos(a0)	;and replace
		bra.s	PLL_7		;and skip


* Here goes test Laser lists.


XLL		ds.b	ll_Sizeof*_LL_SIZE
		even


* NewFire(a6)
* a6 = ptr to main vars

* if fire button pressed, then initialise the fire sequence.

* d0-d4/a1 corrupt


NewFire		tst.b	FireLock(a6)	;fire button locked?
		bne	NFire_Done	;exit NOW if so

		move.l	FireKeyPtr(a6),a0		;get which key/stick
		move.b	(a0),d0			;get var value
		and.b	FireKeyMsk(a6),d0		;ensure var masked!
		cmp.b	FireKeyVal(a6),d0		;correct one?
		bne	NFire_Done		;skip if not

NFire_3		move.l	LListEntry(a6),a0		;get LaserList ptr
		tst.l	ll_LXPos(a0)		;list entry free?
		bne.s	NFire_Done		;exit if not!

		tst.w	MoveDir(a6)		;L to R?
		spl	d2			;set if R to L

		move.l	ShipAnim(a6),a1
		move.l	Anim_XPos(a1),d0	;ship's x & y position
		addq.w	#6,d0		;y=y+6
		move.w	d0,ll_YPos(a0)	;set entry
		swap	d0		;now get x
		tst.b	d2		;L to R?
		bmi.s	NFire_1		;skip if R to L


* Here, ship's direction is L to R. Generate appropriate LaserList values
* for a left to right ship.


		add.w	#16,d0		;left x=ship x+16
		move.w	d0,d1
		add.w	#16,d1		;right x=left x+16
		bra.s	NFire_2


* Here, ship's direction is R to L, so generate the values appropriate
* to this direction.


NFire_1		move.w	d0,d1		;right x=ship x
		sub.w	#16,d0		;left x=right x-16


* Here, set LaserList entry.


NFire_2		move.w	d0,ll_LXPos(a0)	;LHS x coordinate
		move.w	d1,ll_RXPos(a0)	;RHS x coorfdinate
		move.b	d2,ll_Type(a0)	;LtoR/RtoL indicator

		st	FireLock(a6)	;lock fire button till release

		move.l	ll_Next(a0),a0
		move.l	a0,LListEntry(a6)

		bsr	MissileOn	;do this if Baiter active

NFire_Done	rts			;and done


* NewCollision(a6)
* a6 = ptr to main program variables

* Handle object collisions. Collisions of 2 types:
* 1) Alien hit by laser : alien dies
* 2) Alien hits ship : ship dies

* d0-d6/a0-a3 corrupt


NewCollision	move.l	ShipAnim(a6),a2		;get ship ptr
		move.w	Anim_XPos(a2),d0		;get ship position
		move.w	Anim_YPos(a2),d1
		add.w	AO_XOff(a2),d0		;add centre offsets
		add.w	AO_YOff(a2),d1

		move.l	CollisionList(a6),a0	;get list ptr

NewC_1		move.l	(a0)+,d2			;object pointer exists?
		beq	NewC_2			;end of table-leave NOW

		move.l	d2,a1			;get object ptr

		move.w	Anim_ID(a1),d2		;here check if special
		cmp.w	#_AL_MISSILE,d2		;missile?
		beq.s	NewC_1			;skip check if so
		cmp.w	#_AL_POWERUP,d2		;power-up?
		beq.s	NewC_1			;it does its own-skip

		move.w	Anim_XPos(a1),d2		;get object position
		move.w	Anim_YPos(a1),d3
		add.w	CurrXPos(a6),d2		;true scrn pos
		and.w	MaxScrPos(a6),d2		;constrain to screen!

		move.w	d3,d4			;copy true Y
		swap	d3
		move.w	d4,d3
		move.l	Anim_Frames(a1),a3
		add.w	AnFr_Rows(a3),d3		;Y + object size
		swap	d3


* Here check if collision with laser.


		move.l	LList(a6),a3	;laser list
		move.l	a3,d6
NewC_7		tst.l	ll_LXPos(a3)	;laser shot active?
		beq.s	NewC_6		;get next one if not
		move.w	ll_YPos(a3),d4	;y pos of laser
		move.w	d4,d5
		sub.w	d3,d4		;laser y - alien y = y'
		bmi.s	NewC_6		;laser above alien-try again
		swap	d3
		sub.w	d3,d5		;laser y - alien yy = y''
		bpl.s	NewC_8		;laser below alien-try again
		cmp.w	ll_LXPos(a3),d2	;x<laser LHS?
		bcs.s	NewC_8		;skip if so
		cmp.w	ll_RXPos(a3),d2	;x>laser RHS?
		bhi.s	NewC_8		;skip if so

		or.b	#_AOF_HIT,AO_Flags(a1)	;signal hit
		clr.l	ll_LXPos(a3)		;prevent shot reuse
		bra.s	NewC_1			;and leave

NewC_8		swap	d3		;recover coord order

NewC_6		move.l	ll_Next(a3),a3	;next entry
		cmp.l	d6,a3		;done all entries?
		bne.s	NewC_7		;back for more if not


* Here check if collided with ship (unless shield on, in which
* case no collision check is performed).


		move.b	PwrUpOn(a6),d4	;shield on?
		and.b	#_PU_SHLD,d4
		bne.s	NewC_1		;skip test if so

		cmp.w	#_AL_BODY,Anim_ID(a1)	;Body object?
		beq	NewC_1			;omit check if so

		add.w	AO_XOff(a1),d2	;ship collision
		and.w	MaxScrPos(a6),d2
		add.w	AO_YOff(a1),d3	;offsets
		sub.w	d1,d3
		bpl.s	NewC_3
		neg.w	d3		;abs(shipy-alieny)
NewC_3		sub.w	d0,d2
		bpl.s	NewC_4
		neg.w	d2		;abs(shipx-alienx)
NewC_4		cmp.w	AO_XDisp(a1),d2	;abs(x2-x1) < min x separation?
		bcc	NewC_1		;skip if not
		cmp.w	AO_YDisp(a1),d3	;abs(y2-y1) < min y separation?
		bcc	NewC_1		;skip if not

		or.b	#_AOF_HIT,AO_Flags(a2)	;signal ship hit
		or.b	#_AOF_HIT,AO_Flags(a1)	;signal alien hit

NewC_2		rts


* The following code implements the 'end of landscape' once all Bodies
* are dead, and causes all Landers to convert to Mutants.


* EndOfWorld(a6)
* a6 = ptr to main program variables

* Cause the end of the world...for now!

* d0 corrupt


EndOfWorld	move.w	#40+1,d0
		move.w	d0,LSCountDown(a6)	;countdown to Death
		rts


* BlastWorld(a6)
* a6 = ptr to main program variables

* Create the 'World Explosion' effect. Flash the background colour
* randomly to create the effect of the 'end of the world'.

* d0/a0 corrupt


BlastWorld	tst.b	NoLand(a6)	;already dead?
		beq.s	BW_2		;skip if not
		rts


* Here, the 'world' is not yet at an end.


BW_2		move.w	LSCountDown(a6),d0	;not counting down?
		beq.s	BW_3			;skip if we're not
		subq.w	#1,d0			;else do the end of
		move.w	d0,LSCountDown(a6)	;the world countdown
		bne.s	BW_1			;skip if not yet ended


* Here, the 'world' IS at an end. Signal the fact.


		st	NoLand(a6)		;set no landscape
		move.l	CurrentPlayer(a6),a0	;and for this
		st	pd_NoLand(a0)		;player for now
		move.w	#0,COLOR00(a5)		;and reset bgnd colour

BW_3		rts


* Here, flash the background colour depending upon the current
* random number.


BW_1		lea	EXPLSF(pc),a0	;ptr to byte array
		move.b	0(a0,d0.w),d0	;get element
		sne	d0		;set to -1 if nonzero
		ext.w	d0		;make word sized
		and.w	#$FFF,d0		;create colour value
		move.w	d0,COLOR00(a5)	;set colour
		rts


* Explosion screen flash array. Basically, byte=0 for black, 1 for white.
* Array = 40 elements long. DON'T set LSCountDown(a6) to more than 40+1
* or else strange things may happen...


EXPLSF		dc.b	0,0,0,0,0,0,0,1
		dc.b	0,0,0,0,0,0,1
		dc.b	0,0,0,0,0,1
		dc.b	0,0,0,0,1
		dc.b	0,0,0,1,0,1,0,1,0,1
		dc.b	0,0,0,1
		even


* Starfield code.


		rsreset
st_Next		rs.l	1	;ptr to next (round robin again)
st_XPos		rs.w	1	;actual x coordinate
st_YPos		rs.w	1	;is actually screen offset!
st_Colour	rs.b	1	;which planes to use
st_Pad		rs.b	1	;padding byte for alignment
st_Sizeof	rs.w	0

_ST_SIZE		equ	40


* InitStarField(a6)
* a6 = ptr to main program variables

* Initialise the Starfield for use.

* d0-d1/a0-a1 corrupt


InitStarField	move.l	StarField(a6),a0	;ptr to Starfield
		move.l	a0,d0		;copy ptr
		moveq	#_ST_SIZE,d1	;no. of entries

ISF_1		move.l	a0,a1		;copy ptr to this entry
		add.w	#st_Sizeof,a1	;make ptr to next
		move.l	a1,st_Next(a0)	;create link
		subq.w	#1,d1		;done them all?
		beq.s	ISF_2		;skip if so
		move.l	a1,a0		;else new this = old next 
		bra.s	ISF_1

ISF_2		move.l	d0,st_Next(a0)	;link to 1st in list

		rts


* NewStarField(a6)
* a6 = ptr to main program variables

* Make a new Starfield using the initialised StarField list.

* d0-d2/a0-a1 corrupt


NewStarField	move.l	StarField(a6),a0	;ptr to StarField
		move.l	a0,d0		;copy ptr
		move.l	YTable(a6),a1	;ptr to Y-Table

NSF_1		bsr	Random		;make random number
		move.l	Seed(a6),d1	;get value
		moveq	#0,d2
		move.w	d1,d2		;copy this
		divu	#320,d2		;want it MOD 320
		swap	d2		;get remainder
		move.w	d2,st_XPos(a0)
		swap	d1		;now get Y pos
		and.w	#$7F,d1		;this lot forces it to
		add.w	#MIN_SY,d1	;lie in the playu area
		add.w	d1,d1		;word index
		move.w	0(a1,d1.w),d1	;get y-table entry
		move.w	d1,st_YPos(a0)
		bsr	Random		;another random number please
		move.b	Seed(a6),d1	;get it
		and.b	#$07,d1		;this is colour
		bne.s	NSF_3		;skip if not background
		moveq	#1,d1		;else make it colour 1
NSF_3		rol.b	#5,d1		;see why later!
		move.b	d1,st_Colour(a0)

		move.l	st_Next(a0),d1	;get next ptr
		cmp.l	d0,d1		;end of list?
		beq.s	NSF_2		;skip if so
		move.l	d1,a0		;else point to next entry
		bra.s	NSF_1		;and create it

NSF_2		rts


* ShowStarField(a6)
* a6 = ptr to main program variables

* Display the starfield, and then update the position of
* each star in the starfield. Since we're using the ship
* speed divided by 4, it's possible for slow moving ships
* to cause no starfield scrolling...

* d0-d4/a0-a2 corrupt


ShowStarField	move.l	StarField(a6),a0	;ptr to StarField list
		move.l	a0,d0		;copy ptr

		move.l	RasterWaiting(a6),a1	;screen ptr
		addq.l	#2,a1			;overwide screen!

		move.w	CurrXSpeed(a6),d4		;get ship speed
;		lsr.w	#2,d4			;divide by 4
		lsr.w	#1,d4			;divide by 2
		tst.w	MoveDir(a6)		;moving from L to R?
		bmi.s	SSF_1			;skip if so
		neg.w	d4			;else change speed

SSF_1		move.b	st_Colour(a0),d1		;get colour ready
		moveq	#0,d2
		move.w	st_YPos(a0),d2
		move.l	a1,a2			;screen ptr
		add.l	d2,a2			;+vertical offset
		move.w	st_XPos(a0),d2		;get x position
		move.w	d2,d3			;copy it
		asr.w	#4,d3			;get word offset
		add.w	d3,d3			;get byte offset
		add.w	d3,a2			;add to scrn addr
		moveq	#0,d3			;initial plot value
		and.w	#$0F,d2			;get pixel bits
		not.b	d2
		and.b	#$0F,d2
		bset	d2,d3		;create set pixel

SSF_2		add.b	d1,d1		;use this bitplane?
		bcc.s	SSF_3		;skip if not
		or.w	d3,(a2)		;else plot pixel
SSF_3		add.w	#BP_HMOD,a2	;next bitplane
		add.b	d1,d1		;use this bitplane?
		bcc.s	SSF_4		;skip if not
		or.w	d3,(a2)		;else plot pixel
SSF_4		add.w	#BP_HMOD,a2	;next bitplane
		add.b	d1,d1		;use this bitplane?
		bcc.s	SSF_5		;skip if not
		or.w	d3,(a2)		;else plot pixel

SSF_5		move.w	st_XPos(a0),d2	;get x position
		sub.w	d4,d2		;add on ship speed/4
		bpl.s	SSF_6		;skip if >=0
		add.w	#320,d2		;else put back on display
SSF_6		cmp.w	#320,d2		;off RHS edge?
		bcs.s	SSF_7		;skip if not
		sub.w	#320,d2		;else put on LHS edge

SSF_7		move.w	d2,st_XPos(a0)	;save new X position

		move.l	st_Next(a0),a0	;point to next entry
		cmp.l	d0,a0		;back to start of list?
		bne.s	SSF_1		;back for more if not

		rts			;else done.


* Starfield array


XST		ds.b	st_Sizeof*_ST_SIZE
		even


* DoPowerUp(a6)
* a6 = ptr to main program variables

* Create the PowerUp left by a dead Lander on Defender Plus.
* Also to be left by dead Mutants on land-less levels!

* d0-d3/a0-a1 corrupt


DoPowerUp	tst.b	GamePlus(a6)	;playing Defender Plus?
		bne.s	DPU_1		;skip if so
		rts			;else leave

DPU_1		move.l	PuPtr(a6),d0	;got a PowerUp?
		bne.s	DPU_2		;skip if so
		rts			;else leave

DPU_2		move.l	d0,a0		;get pointer
		move.b	Anim_Flags(a0),d0	;check if free for use
		and.b	#_ANF_DISABLED,d0	;dead object?
		bne.s	DPU_2A		;skip if so
		rts			;else we'll wait for death...


* Here, we've got a free slot for our PowerUp. Decide which one, then
* set things up accordingly.


DPU_2A		bsr	Random		;make random number
		move.w	Seed(a6),d1	;get it
		and.w	#$03,d1		;this power-up type

		moveq	#0,d2
		bset	d1,d2
		and.b	PwrUpEn(a6),d2	;this one enabled?
		bne.s	DPU_3		;skip if so
		rts			;else abort

DPU_3		nop

;		or.b	d2,PwrUpOn(a6)	;signal available
		move.w	d1,d2
		add.w	d2,d2		;longword index into
		add.w	d2,d2		;AnFr ptr array
		move.w	d2,d3		;copy index

		lea	PuAnFr(a6),a1	;ptr to AnimFrames
		move.l	0(a1,d2.w),d2	;get AnFr pointer

		move.l	d2,Anim_Frames(a0)
		move.l	d2,Anim_CFrame(a0)

		lea	PuRoutines(a6),a1		;ptr to SpecialCodes
		move.l	0(a1,d3.w),d3
		move.l	d3,AO_SpecialCode(a0)	;get this one

		move.w	#_AL_POWERUP,Anim_ID(a0)

		clr.b	AO_Flags(a0)
		clr.l	AO_ScanMsk1(a0)	;no scanner dots

		move.w	#200,d0		;5 secs worth of feature
		move.w	d0,AO_BCount(a0)	;when power-up picked up

		move.b	#_ANF_SAMEFRAME,Anim_Flags(a0)

		clr.l	PuPtr(a6)	;prevent re-re-use!

		move.l	CurrentPlayer(a6),a1
		clr.l	pd_PuPtr(a1)

		move.w	#$FF0,COLOR00(a5)	;flash screen!
		st	PuDropped(a6)	;signal PowerUp dropped...

		rts


* The following are SpecialCodes for the Powerups.

* NOTE : The DoPowerUp() routine changes the background colour
* of the screen to yellow as an indicator that a PowerUp has
* been dropped. The SpecialCodes for the PowerUps should reset
* the background colour to black once this has happened!


* DoTurbo(a0,a6)
* a6 = ptr to main program variables
* a0 = ptr to AO_ struct for Powerup

* Check if user picks up Turbo Thrust powerup.
* If so, enable it for 5 secs.

* d0-d1/a1 corrupt


DoTurbo		tst.b	PuDropped(a6)		;just dropped?
		beq.s	DTB_0			;skip if not

		clr.b	PuDropped(a6)
		move.w	#0,COLOR00(a5)		;else reset bgnd colour

DTB_0		move.w	Anim_XPos(a0),d0		;true playfield pos
		add.w	CurrXPos(a6),d0
		and.w	MaxScrPos(a6),d0		;display pos

		move.l	ShipAnim(a6),a1		;ship AO_ struct
		sub.w	Anim_XPos(a1),d0		;pos rel. to ship
		bpl.s	DTB_1			;skip if >0

		neg.w	d0
		cmp.w	#7,d0		;touched it?
		bls.s	DTB_2		;skip if so


* Here, decrease the life count for the Powerup. If it hits zero,
* then kill off the Powerup.


DTB_4		subq.w	#1,AO_BCount(a0)	;finished with powerup?
		bne.s	DTB_3		;skip if not

		move.b	#_ANF_DISABLED,d0
		move.b	d0,Anim_Flags(a0)	;else kill it off

DTB_3		rts

DTB_1		cmp.w	#14,d0		;touched it?
		bhi.s	DTB_4		;skip if not

DTB_2		move.w	Anim_YPos(a0),d0	;get y position
		sub.w	Anim_YPos(a1),d0	;relative to ship
		bpl.s	DTB_5

		neg.w	d0
DTB_5		cmp.w	#7,d0		;touched it?
		bhi.s	DTB_4		;skip if not


* Here, we've touched the Powerup. Now enable Turbo Thrust!


DTB_6		move.l	CurrentPlayer(a6),a1
		move.w	#200,d0
		move.w	d0,TurboCount(a6)
		move.w	d0,pd_Turbo(a1)
		moveq	#_PU_TURBO,d0
		move.b	PwrUpOn(a6),d1
		or.b	d0,d1
		move.b	d1,PwrUpOn(a6)
		move.b	d1,pd_PwrUp(a1)
		move.b	#_ANF_DISABLED,d0
		move.b	d0,Anim_Flags(a0)

		st	PUVis1(a6)	;allow indicator to show
		st	pd_PUVis1(a1)

		rts


* DoShield(a0,a6)
* a6 = ptr to main program variables
* a0 = ptr to AO_ struct for Powerup

* Check if user picks up Shield powerup.
* If so, enable it for 5 secs.

* d0-d1/a1 corrupt


DoShield		tst.b	PuDropped(a6)		;just dropped?
		beq.s	DSH_0			;skip if not

		clr.b	PuDropped(a6)
		move.w	#0,COLOR00(a5)		;else reset bgnd colour

DSH_0		move.w	Anim_XPos(a0),d0		;true playfield pos
		add.w	CurrXPos(a6),d0
		and.w	MaxScrPos(a6),d0		;display pos

		move.l	ShipAnim(a6),a1		;ship AO_ struct
		sub.w	Anim_XPos(a1),d0		;pos rel. to ship
		bpl.s	DSH_1			;skip if >0

		neg.w	d0
		cmp.w	#7,d0		;touched it?
		bls.s	DSH_2		;skip if so


* Here, decrease the life count for the Powerup. If it hits zero,
* then kill off the Powerup.


DSH_4		subq.w	#1,AO_BCount(a0)	;finished with powerup?
		bne.s	DSH_3		;skip if not

		move.b	#_ANF_DISABLED,d0
		move.b	d0,Anim_Flags(a0)	;else kill it off

DSH_3		rts

DSH_1		cmp.w	#14,d0		;touched it?
		bhi.s	DSH_4		;skip if not

DSH_2		move.w	Anim_YPos(a0),d0	;get y position
		sub.w	Anim_YPos(a1),d0	;relative to ship
		bpl.s	DSH_5

		neg.w	d0
DSH_5		cmp.w	#7,d0		;touched it?
		bhi.s	DSH_4		;skip if not


* Here, we've touched the Powerup. Now enable shield!


DSH_6		move.l	CurrentPlayer(a6),a1
		move.w	#200,d0
		move.w	d0,ShieldCount(a6)
		move.w	d0,pd_Shield(a1)
		moveq	#_PU_SHLD,d0
		move.b	PwrUpOn(a6),d1
		or.b	d0,d1
		move.b	d1,PwrUpOn(a6)
		move.b	d1,pd_PwrUp(a1)
		move.b	#_ANF_DISABLED,d0
		move.b	d0,Anim_Flags(a0)

		st	PUVis2(a6)	;allow indicator to show
		st	pd_PUVis2(a1)

		rts


* DoMissile(a0,a6)
* a6 = ptr to main program variables
* a0 = ptr to AO_ struct for Powerup

* See if user picks up Missile powerup, and if so set things
* up for missile appearance when Baiter appears.

* d0-d1/a1 corrupt


DoMissile	tst.b	PuDropped(a6)		;just dropped?
		beq.s	DMI_0			;skip if not

		clr.b	PuDropped(a6)
		move.w	#0,COLOR00(a5)		;else reset bgnd colour

DMI_0		move.w	Anim_XPos(a0),d0		;true playfield pos
		add.w	CurrXPos(a6),d0
		and.w	MaxScrPos(a6),d0		;display pos

		move.l	ShipAnim(a6),a1		;ship AO_ struct
		sub.w	Anim_XPos(a1),d0		;pos rel. to ship
		bpl.s	DMI_1			;skip if >0

		neg.w	d0
		cmp.w	#7,d0		;touched it?
		bls.s	DMI_2		;skip if so


* Here, decrease the life count for the Powerup. If it hits zero,
* then kill off the Powerup.


DMI_4		subq.w	#1,AO_BCount(a0)	;finished with powerup?
		bne.s	DMI_3		;skip if not

		move.b	#_ANF_DISABLED,d0
		move.b	d0,Anim_Flags(a0)	;else kill it off

DMI_3		rts

DMI_1		cmp.w	#14,d0		;touched it?
		bhi.s	DMI_4		;skip if not

DMI_2		move.w	Anim_YPos(a0),d0	;get y position
		sub.w	Anim_YPos(a1),d0	;relative to ship
		bpl.s	DMI_5

		neg.w	d0
DMI_5		cmp.w	#7,d0		;touched it?
		bhi.s	DMI_4		;skip if not


* Here, we've touched the Powerup. Now enable the missile
* for when the Baiter is active!


DMI_6		move.l	CurrentPlayer(a6),a1
		moveq	#_PU_MISSILE,d0
		move.b	PwrUpOn(a6),d1
		or.b	d0,d1
		move.b	d1,PwrUpOn(a6)
		move.b	d1,pd_PwrUp(a1)
		move.b	#_ANF_DISABLED,d0
		move.b	d0,Anim_Flags(a0)

		move.l	a0,MsPtr(a6)	;set missile pointer
		move.l	a0,pd_MsPtr(a1)

		st	PUVis3(a6)	;allow indicator to show
		st	pd_PUVis3(a1)

		addq.w	#1,SMCount(a6)	;increase missile count
		addq.w	#1,pd_SMCount(a1)	;for this player

		rts


* DoMystery(a0,a6)
* a6 = ptr to main program variables
* a0 = ptr to AO_ struct for Powerup

* See if user picks up Mystery powerup, and if so pick one of the
* other features to activate.

* d0-d1/a1 corrupt


DoMystery	tst.b	PuDropped(a6)		;just dropped?
		beq.s	DMY_0			;skip if not

		clr.b	PuDropped(a6)
		move.w	#0,COLOR00(a5)		;else reset bgnd colour

DMY_0		move.w	Anim_XPos(a0),d0		;true playfield pos
		add.w	CurrXPos(a6),d0
		and.w	MaxScrPos(a6),d0		;display pos

		move.l	ShipAnim(a6),a1		;ship AO_ struct
		sub.w	Anim_XPos(a1),d0		;pos rel. to ship
		bpl.s	DMY_1			;skip if >0

		neg.w	d0
		cmp.w	#7,d0		;touched it?
		bls.s	DMY_2		;skip if so


* Here, decrease the life count for the Powerup. If it hits zero,
* then kill off the Powerup.


DMY_4		subq.w	#1,AO_BCount(a0)	;finished with powerup?
		bne.s	DMY_3		;skip if not

		move.b	#_ANF_DISABLED,d0
		move.b	d0,Anim_Flags(a0)	;else kill it off

DMY_3		rts

DMY_1		cmp.w	#14,d0		;touched it?
		bhi.s	DMY_4		;skip if not

DMY_2		move.w	Anim_YPos(a0),d0	;get y position
		sub.w	Anim_YPos(a1),d0	;relative to ship
		bpl.s	DMY_5

		neg.w	d0
DMY_5		cmp.w	#7,d0		;touched it?
		bhi.s	DMY_4		;skip if not


* Here, we've touched the Powerup. Now pick one of the other three
* PowerUps to activate.


DMY_6		bsr	Random		;make random no.
		move.w	Seed(a6),d0	;get it
		and.w	#3,d0		;range = 0 to 3
		beq.s	DMY_6		;back if zero
		subq.w	#1,d0		;now range = 0 to 2
		add.w	d0,d0		;longword index
		add.w	d0,d0

		lea	DMY_7(pc),a1	;ptr to jumptable
		move.l	0(a1,d0.w),a1	;get jumptable entry

		move.b	#_ANF_DISABLED,d0
		move.b	d0,Anim_Flags(a0)

		jmp	(a1)		;and execute


DMY_7		dc.l	DTB_6
		dc.l	DSH_6
		dc.l	DMI_6


* SetMaxThrust(a6)
* a6 = ptr to main program variables

* If playing Defender Plus, set maximum thrust to turbo level
* if turbo thrust enabled.

* d0-d1/a0 corrupt


SetMaxThrust	tst.b	GamePlus(a6)	;playing Defender Plus?
		bne.s	SMT_1		;skip if so
		rts

SMT_1		move.l	CurrentPlayer(a6),a0

		move.b	PwrUpOn(a6),d0	;get power-up flags
		move.b	d0,d1		;copy it
		and.b	#_PU_TURBO,d0	;turbo thrust on?
		bne.s	SMT_2		;skip if so

SMT_3		moveq	#$0F,d0		;set normal max speed
		move.w	d0,MaxScrSpeed(a6)
		move.b	#_PU_TURBO,d0
		not.b	d0
		and.b	d0,d1
		move.b	d1,PwrUpOn(a6)	;clear turbo flag
		move.b	d1,pd_PwrUp(a0)
		sf	PUVis1(a6)	;kill indicator
		sf	pd_PUVis1(a0)
		rts

SMT_2		move.w	TurboCount(a6),d0	;countdown finished?
		beq.s	SMT_3		;normal thrust if so
		subq.w	#1,d0		;count down
		move.w	d0,TurboCount(a6)	;store back
		move.w	d0,pd_Turbo(a0)
		beq.s	SMT_3		;normal thrust if zero

		moveq	#$1F,d0		;else turbo max speed
		move.w	d0,MaxScrSpeed(a6)
		rts


* SetShield(a6)
* a6 = ptr to main program variables

* If playing Defender Plus, handle shield.

* d0/d1 corrupt


SetShield	tst.b	GamePlus(a6)	;playing Defender Plus?
		bne.s	SSH_1		;skip if so
		rts

SSH_1		move.l	CurrentPlayer(a6),a0

		move.b	PwrUpOn(a6),d0	;get power-up flags
		move.b	d0,d1		;copy it
		and.b	#_PU_SHLD,d0	;shield on?
		bne.s	SSH_2		;skip if so

SSH_3		move.b	#_PU_SHLD,d0
		not.b	d0
		and.b	d0,d1
		move.b	d1,PwrUpOn(a6)	;clear shield flag
		move.b	d1,pd_PwrUp(a0)
		sf	PUVis2(a6)	;kill indicator
		sf	pd_PUVis2(a0)
		rts

SSH_2		move.w	ShieldCount(a6),d0	;countdown finished?
		beq.s	SSH_3			;kill shield if so
		subq.w	#1,d0			;count down
		move.w	d0,ShieldCount(a6)	;store back
		move.w	d0,pd_Shield(a0)
		beq.s	SSH_3			;no shield if zero

		rts


* MissileOn(a6)
* a6 = ptr to main program variables

* Launch a missile if Baiter active.

* BECAUSE THIS IS CALLED FROM THE FIRE ROUTINE, ASSUME ALL
* REGISTERS CORRUPT BEFORE ENTRY, AND HENCE UPON EXIT!


MissileOn	tst.b	BAlert(a6)	;Baiter alert?
		bne.s	MON_1		;skip if so
		rts			;else exit now

MON_1		move.b	PwrUpOn(a6),d0
		and.b	#_PU_MISSILE,d0	;missile powerup selected?
		bne.s	MON_1A		;skip if so
		clr.b	BAlert(a6)
		rts			;else exit now

MON_1A		move.l	MsPtr(a6),d0	;Missile pointer exists?
		bne.s	MON_1B		;continue if so
		rts			;else leave NOW...

MON_1B		move.l	d0,a0		;point to it
		move.b	Anim_Flags(a0),d0	;check if free for use
		and.b	#_ANF_DISABLED,d0	;free for use?
		bne.s	MON_1C		;skip if so
		rts			;else leave now

MON_1C		move.w	SMCount(a6),d0	;any left?
		bne.s	MON_1D		;skip if so

		move.l	CurrentPlayer(a6),a1
		moveq	#_PU_MISSILE,d0
		not.b	d0
		and.b	d0,PwrUpOn(a6)	;signal no more missiles left
		and.b	d0,pd_PwrUp(a1)
		sf	PUVis3(a6)	;kill indicator
		sf	pd_PUVis3(a1)

		rts


MON_1D		subq.w	#1,d0		;1 less missile
		move.w	d0,SMCount(a6)
		move.l	CurrentPlayer(a6),a1
		move.w	d0,pd_SMCount(a1)

		move.l	MsPtr(a6),a0	;ptr to Missile AO_ struct
		move.l	ShipAnim(a6),a1	;ptr to Ship AO_ struct

		move.w	Anim_XPos(a1),d0	;get ship display x pos
		sub.w	CurrXPos(a6),d0
		and.w	MaxScrPos(a6),d0	;get ship playfield pos
		move.w	Anim_YPos(a1),d1	;get ship y position
		add.w	#16,d1		;make missile y position

		cmp.w	#196,d1		;missile too low down?
		bcs.s	MON_2		;skip if not
		sub.w	#32,d1		;else put above ship

MON_2		move.w	d0,Anim_XPos(a0)	;set missile position
		move.w	d1,Anim_YPos(a0)

		clr.w	AO_YMove(a0)	;no vertical movement
		move.w	CurrXSpeed(a6),d0	;match speed to ship
		lea	MsAnFrs(a6),a2	;ptr to AnFrs for missile
		tst.w	MoveDir(a6)
		bmi.s	MON_3
		neg.w	d0		;and match direction too
		addq.l	#4,a2		;change AnFr ptrs if reversed
MON_3		move.w	d0,AO_XMove(a0)
		move.l	(a2),d0
		move.l	d0,Anim_Frames(a0)
		move.l	d0,Anim_CFrame(a0)

		moveq	#_AL_MISSILE,d0
		move.w	d0,Anim_ID(a0)

		moveq	#-1,d0
		clr.w	d0
		move.l	d0,AO_ScanMsk1(a0)

		clr.b	AO_Flags(a0)
		clr.b	Anim_Flags(a0)

		lea	FlyMissile(pc),a1
		move.l	a1,AO_SpecialCode(a0)

		clr.b	BAlert(a6)	;prevent re-use
		rts


* FlyMissile(a0,a6)
* a6 = ptr to main program variables
* a0 = ptr to AO_ struct for missile

* Fly the missile.

* d0-d1/a1-a2 corrupt


FlyMissile	move.b	AO_Flags(a0),d0	;missile flags
		move.b	d0,d1
		and.b	#_AOF_LOCKED,d1	;locked onto Baiter?
		bne.s	FMS_1		;skip if locked

		and.b	#_AOF_TRACKED,d0	;tracking Baiter?
		bne.s	FMS_2		;skip if tracking


* Here, we've just launched the missile. So get the pointer to the
* Baiter. Leave now if we can't get it.


		move.l	CurrentPlayer(a6),a1
		tst.w	SMCount(a6)		;last missile?
		bne.s	FMS_13			;skip if not

		moveq	#_PU_MISSILE,d0
		not.b	d0
		and.b	d0,PwrUpOn(a6)		;signal no more
		and.b	d0,pd_PwrUp(a1)		;missiles!

FMS_13		move.l	pd_BaiterPtr(a1),d0
		bne.s	FMS_3
FMS_4		rts


* Here, we've got the pointer to the Baiter, so signal that we're
* tracking it...


FMS_3		move.l	d0,AO_KidnapPtr(a0)	;ptr to Baiter
		moveq	#_AOF_TRACKED,d0		;signal we're
		move.b	d0,AO_Flags(a0)		;tracking it...
		rts


* Here, start tracking Baiter, and if the Y positions match,
* we've locked on to it.


FMS_2		move.w	Anim_XPos(a0),d0		;move missile in
		add.w	AO_XMove(a0),d0		;given direction
		and.w	MaxScrPos(a6),d0
		move.w	d0,Anim_XPos(a0)

		move.l	AO_KidnapPtr(a0),a1
		move.w	Anim_YPos(a1),d0		;get Baiter y pos
		cmp.w	Anim_YPos(a0),d0		;positions match?
		bne.s	FMS_4			;skip if not
		moveq	#_AOF_LOCKED,d0		;else signal locked
		move.b	d0,AO_Flags(a0)
		rts


* Come here if the missile has locked onto the Baiter.


FMS_1		move.l	AO_KidnapPtr(a0),a1	;match missile Y pos
		move.w	Anim_YPos(a1),d0		;to tracked Baiter
		move.w	d0,Anim_YPos(a0)

		move.w	Anim_XPos(a0),d0		;move missile in
		move.w	AO_XMove(a0),d1		;given direction
		add.w	d1,d0
		and.w	MaxScrPos(a6),d0		;normalise pos'n!
		move.w	d0,Anim_XPos(a0)

		lea	MsAnFrs(a6),a2	;AnimFrame pointers
		tst.w	d1		;check which direction
		bpl.s	FMS_8		;we're going in
		addq.l	#4,a2		;here we're going R to L

FMS_8		move.l	(a2),d2			;get frame ptr
		move.l	d2,Anim_Frames(a0)
		move.l	d2,Anim_CFrame(a0)


* Coordinates below are PLAYFIELD coordinates, NOT display coordinates!
* Check where the Baiter is in relation to the missile.


		move.w	Anim_XPos(a1),d0
		sub.w	Anim_XPos(a0),d0		;Baiter x - missile x
		move.w	MaxScrPos(a6),d1
		and.w	d1,d0			;normalise!
		lsr.w	#1,d1
		cmp.w	d1,d0		;Baiter to left?
		bcc.s	FMS_5		;skip if so


* Here, Baiter is to right of missile, so begin moving
* missile to right.


		cmp.w	#40,d0		;close to Baiter?
		bhi.s	FMS_9		;skip if not

		moveq	#_AOF_HIT,d0
		moveq	#_ANF_DISABLED,d1
		move.b	d0,AO_Flags(a1)	;signal Baiter hit
		move.b	d1,Anim_Flags(a0)	;and kill missile

		move.l	AO_ScanLoc(a0),d0		;scanner dots?
		beq.s	FMS_10			;skip if not
		move.l	d0,a1			;else unplot them
		move.l	AO_ScanBit1(a0),d0
		not.l	d0
		and.l	d0,(a1)

FMS_10		rts

FMS_9		move.w	AO_XMove(a0),d0	;get x movement
		addq.w	#1,d0		;increase speed to right
		cmp.w	#BAITERSPD+8,d0	;speed too great?
		bgt.s	FMS_6		;skip if so
		move.w	d0,AO_XMove(a0)	;else set speed

FMS_6		rts


* Here, Baiter is to left of missile, so begin moving
* missile to left.


FMS_5		cmp.w	#$2000-40,d0	;close to Baiter?
		bcs.s	FMS_12		;skip if not

		moveq	#_AOF_HIT,d0
		moveq	#_ANF_DISABLED,d1

		move.b	d0,AO_Flags(a1)	;signal Baiter hit
		move.b	d1,Anim_Flags(a0)	;and kill missile

		move.l	AO_ScanLoc(a0),d0		;scanner dots?
		beq.s	FMS_11			;skip if not
		move.l	d0,a1			;else unplot them
		move.l	AO_ScanBit1(a0),d0
		not.l	d0
		and.l	d0,(a1)

FMS_11		rts

FMS_12		move.w	AO_XMove(a0),d0	;get x movement
		subq.w	#1,d0			;increase speed to left
		cmp.w	#-(BAITERSPD+8),d0	;speed too great?
		blt.s	FMS_7			;skip if so
		move.w	d0,AO_XMove(a0)	;else set speed

FMS_7		rts



	
