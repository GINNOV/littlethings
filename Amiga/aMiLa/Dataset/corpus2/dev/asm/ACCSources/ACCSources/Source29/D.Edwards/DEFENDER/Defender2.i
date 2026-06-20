

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


* Here, we're below the landscape surface, so set Y pos.


BDIN_2		addq.w	#4,d0
		move.w	d0,Anim_YPos(a0)

		clr.l	AO_SpecialCode(a0)	;do nothing more

		rts


* BodyCode1(a0,a6)
* Perform Body operations once kidnapped.

* d0/a1 corrupt


BodyCode1	move.w	Anim_YPos(a0),d0	;get Body Y pos
		subq.w	#1,d0		;-1
		cmp.w	#MIN_SY,d0	;off top of play area?
		bhi.s	BC1_1		;skip if not

		moveq	#_ANF_DISABLED,d0	;else kill it
		move.b	d0,Anim_Flags(a0)
		clr.l	AO_SpecialCode(a0)
		move.l	AO_ScanLoc(a6),a1		;zero out
		move.l	AO_ScanBit1(a6),d0	;scanner bits
		not.l	d0			;for dead Body
		and.l	d0,(a1)
		rts

BC1_1		move.w	d0,Anim_YPos(a0)	;replace y position
		rts


* BodyCode2(a0,a6)

* Perform Body operations if kidnapping Lander dies.
* Basically cause descent, and if Body hits floor
* too hard (i.e., from too high up) then Body dies.
* Also checks to see if ship has rescued body.

* d0-d2/a1 corrupt


BodyCode2	move.w	Anim_XPos(a0),d0	;get Body X Pos
		add.w	CurrXPos(a6),d0
		and.w	MaxScrPos(a6),d0	;position rel. to ship

		move.l	ShipAnim(a6),a1
		move.w	Anim_XPos(a1),d1
		move.w	d1,d2		;ship x
		add.w	#14,d2		;ship x + 14
		cmp.w	d1,d0		;Body x > ship x?
		bls.s	BC2_4		;skip if not
		cmp.w	d2,d0		;Body x < (ship x + 14)?
		bcc.s	BC2_4		;skip if not

		move.w	Anim_YPos(a0),d0

		move.w	Anim_YPos(a1),d1
		move.w	d1,d2		;ship y
		addq.w	#8,d2		;ship y + 8
		addq.w	#4,d2		;ship y + 12
		cmp.w	d1,d0		;body y > ship y?
		bls.s	BC2_4		;skip if not
		cmp.w	d2,d0		;body y < (ship y + 12) ?
		bcc.s	BC2_4		;skip if not
		
		lea	BodyCode3(pc),a1		;change Body
		move.l	a1,AO_SpecialCode(a0)	;SpecialCode

;		or.b	#_AOF_RESCUED,AO_Flags(a0)	;signal rescued
		move.b	#_AOF_RESCUED,AO_Flags(a0)

		rts


BC2_4		move.w	Anim_YPos(a0),d0	;Body Y pos
		add.w	AO_YMove(a0),d0	;move down a bit
		move.w	d0,Anim_YPos(a0)

		move.w	AO_YCnt(a0),d0	;do acceleration
		addq.w	#1,d0
		and.w	#$F,d0		;counter cycled back?
		move.w	d0,AO_YCnt(a0)
		bne.s	BC2_1		;skip if not

		addq.w	#1,AO_YMove(a0)	;else vert speed + 1

BC2_1		move.w	Anim_YPos(a0),d0	;get y position
		move.l	YTable(a6),a1	;Ytable
		move.w	d0,d1
		subq.w	#4,d1		;y-4
		add.w	d1,d1
		move.w	0(a1,d1.w),d1	;get YTable entry

		move.w	Anim_XPos(a0),d2
		lsr.w	#4,d2
		add.w	d2,d2
		move.l	LandOff(a6),a1
		add.w	d2,d2
		move.w	0(a1,d2.w),d2	;get landscape entry
		add.w	LandYHgt(a6),d2	;landscape height
		cmp.w	d2,d1		;below surface?
		bcs.s	BC2_2		;skip if not

;		cmp.w	#MAX_SY-20,d0	;Body hit bottom?
;		bcs.s	BC2_2		;skip if not

		move.w	AO_YMove(a0),d0	;get vertical speed
		cmp.w	#4,d0		;hit ground too fast?
		bls.s	BC2_3		;skip if not

		or.b	#_ANF_DISABLED,Anim_Flags(a0)

		move.l	CurrentPlayer(a6),a1
		subq.w	#1,pd_Bodies(a1)

BC2_3		clr.w	AO_YMove(a0)
		clr.l	AO_SpecialCode(a0)

BC2_2		rts


* BodyCode3(a0,a6)

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

		clr.l	AO_SpecialCode(a0)	;no more SpecialCode
		clr.b	AO_Flags(a0)		;no longer rescued

		move.l	CurrentPlayer(a6),a1
		move.l	pd_Score(a1),d0
		moveq	#100,d1
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
		clr.l	AO_KidnapPtr(a0)

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

* Note : new way of setting lander hunting. Use a countdown clock
* stored in AO_BCount. When it hits zero, a-hunting we will go.


DoLander		move.b	AO_Flags(a0),d0	;check alien status
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

;		move.w	#$600,COLOR00(a5)

DoLander_2a	rts

DoLander_1	move.w	Anim_XPos(a0),d0	;current x coord
		add.w	AO_XMove(a0),d0	;movement value
		and.w	MaxScrPos(a6),d0	;constrain to screen
		move.w	d0,Anim_XPos(a0)	;replace x coord

		add.w	CurrXPos(a6),d0
		and.w	MaxScrPos(a6),d0

		move.w	Anim_YPos(a0),d0	;current y coord
		add.w	AO_YMove(a0),d0	;movement value
		move.w	d0,Anim_YPos(a0)	;replace y coord


* Before doing terrain following, see if kidnapping a Body. If so,
* skip terrain following.


		move.b	AO_Flags(a0),d1
		and.b	#_AOF_SNATCHING,d1	;taking a Body?
		bne	DoLander_4		;skip if so


* here handle terrain following...


		add.w	#20,d0		;current y + 20
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
;		bsr	LMine_1		;do missile if wanted

		move.b	AO_Flags(a0),d0
		move.b	d0,d1
		and.b	#_AOF_HUNTING,d1		;looking for body?
		bne.s	DoLander_3		;skip if so
		and.b	#_AOF_SNATCHING,d0	;got body?
		bne	DoLander_4		;skip if so

		move.w	AO_BCount(a0),d0	;reduce ticker
		subq.w	#1,d0
		and.w	KDThresh(a6),d0	;prevent excess time rollover
		move.w	d0,AO_BCount(a0)
		beq.s	DoLander_5	;set hunting if zero

		rts			;else done

DoLander_5	moveq	#_AOF_HUNTING,d0
		or.b	d0,AO_Flags(a0)	;set hunting flag
		rts

DoLander_3	move.l	AO_KidnapPtr(a0),d0	;got body to hunt for?
		bne.s	DoLander_7		;skip if so

		move.l	BodyPtr(a6),a1	;get body
		move.w	Anim_ID(a1),d0	;check object ID
		cmp.w	#_AL_BODY,d0	;genuine body?
		beq.s	DoLander_6	;skip if so

		and.b	#_NAOF_HUNTING,AO_Flags(a0)

		move.l	BodyList(a6),d0	;round again in case
		move.l	d0,BodyPtr(a6)	;hunting lander killed!

		rts

DoLander_6b	move.l	Anim_Next(a1),BodyPtr(a6)	;else update next

		and.b	#_NAOF_HUNTING,AO_Flags(a0)
		rts

DoLander_6	move.b	Anim_Flags(a1),d0
		and.b	#_ANF_DISABLED,d0	;body already dead?
		bne.s	DoLander_6b	;don't snatch it if so
		move.b	AO_Flags(a1),d0
		move.b	d0,d1
		and.b	#_AOF_SNATCHED,d1	;already snatched?
		bne.s	DoLander_6b	;don't snatch if so
		and.b	#_AOF_RESCUED,d0	;rescued state?
		bne.s	DoLander_6b	;don't snatch if so

DoLander_6a	move.l	a1,AO_KidnapPtr(a0)	;set kidnap ptr
		move.l	Anim_Next(a1),BodyPtr(a6)	;& update next

		move.l	Anim_XPos(a1),d0	;get coords in one go
		sub.w	#10,d0		;y=y-10
		swap	d0
		subq.w	#3,d0		;x=x-3
		and.w	MaxScrPos(a6),d0
		swap	d0		;correct order
		move.l	d0,AO_XCnt(a0)	;& store in one go

		move.b	#_AOF_SNATCHED,AO_Flags(a1)

		rts

DoLander_7	move.w	AO_XCnt(a0),d0	;get body x pos
		move.w	Anim_XPos(a0),d1
		sub.w	d0,d1
		bpl.s	DoLander_7a
		neg.w	d1
DoLander_7a	cmp.w	#2,d1		;lander close to body?
		bls.s	DoLander_8
		rts			;else done

DoLander_8	move.w	d0,Anim_XPos(a0)	;set lander position
		moveq	#0,d0		;stop horiz movement
		move.w	d0,AO_XMove(a0)

		move.w	AO_YCnt(a0),d0	;get body y pos
		cmp.w	Anim_YPos(a0),d0	;lander got body?
		beq.s	DoLander_9	;skip if so

		moveq	#1,d0		;set lander to move down
		move.w	d0,AO_YMove(a0)
		rts

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

DoLander_4	move.w	Anim_YPos(a0),d0	;Lander Y pos
		cmp.w	#MIN_SY,d0	;top of screen?
		bhi.s	DoLander_10	;skip if not

		moveq	#0,d0
		move.w	d0,AO_XMove(a0)	;stop moving upwards
		move.w	d0,AO_YMove(a0)

		move.l	AO_KidnapPtr(a0),a1
		move.b	Anim_Flags(a1),d0		;check if Body
		and.b	#_ANF_DISABLED,d0		;snatch complete
		beq.s	DoLander_10		;done if not

		or.b	#_ANF_DISABLED,d0
		move.b	d0,Anim_Flags(a1)
		move.l	CurrentPlayer(a6),a1
		subq.w	#1,pd_Bodies(a1)

		lea	DoMutant(pc),a1		;else Lander becomes
		move.l	a1,AO_SpecialCode(a0)	;a mutant!
		addq.w	#1,Anim_ID(a0)
		move.l	AlienAnFr+4(a6),d0
		move.l	d0,Anim_Frames(a0)
		move.l	d0,Anim_CFrame(a0)
		clr.l	AO_KidnapPtr(a0)
		move.b	#_ANF_SAMEFRAME,Anim_Flags(a0)
		clr.b	AO_Flags(a0)

;		move.w	#$060,COLOR00(a5)

DoLander_10	rts


* MutantCode(a0,a6)
* a0 = ptr to AO_ struct for mutant
* a6 = ptr to main program vars

* Initialise Mutant position etc.


MutantCode	bsr	SetPos		;set position

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

		rts

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

tmpDoBomber	nop
		rts


* DoBomber(a0,a6)


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
		addq.l	#1,d0
		move.l	d0,DebugL(a6)
		cmp.l	pd_BaiterAlarm(a0),d0	;ready for the off?
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
		cmp.w	#-20,d0		;too fast?
		blt.s	DoB_7		;skip if so
		move.w	d0,AO_XMove(a0)	;else set speed
		bra.s	DoB_7


DoB_5		cmp.w	#80,d0		;really close to ship?
		bcs.s	DoB_9		;skip if so

		move.w	AO_XMove(a0),d0	;Baiter speed
		addq.w	#1,d0		;faster -> direction
		cmp.w	#20,d0		;too fast?
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
		bcs.s	DOM_5
		cmp.w	d6,d1		;off bottom of playfield?
		bhi.s	DOM_5

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
* ship!


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





