

* Include file for Defender.

* This file contains the routines for supporting the title screen,
* keyboard/joystick configuration for players, and (when I write it)
* the 'Get Ready' screens.


* DoTitleScreen(a6)
* a6 = ptr to main program variables

* Blit various data to title screen, then display it.
* Repeat for all title screens until a key is pressed.

* Note : uses VBL counter to determine display time. Timings
* computed for a 50Hz PAL Amiga. Change the InitVars() variable
* assignments to the display period variables to alter the
* timings for NTSC machines.

* d2-d7/a0-a2 corrupt


DoTitleScreen	cmp.b	#$FF,OrdKey(a6)	;key held down?
		bne.s	DoTitleScreen	;wait till released

		st	ScrSwitch(a6)		;kill screen switching


* First, prepare page 1 on inactive screen...


		move.l	RasterWaiting(a6),a0
		bsr	BlitScrClear

		move.l	RasterWaiting(a6),a1
		lea	Logo1,a0
		moveq	#24*3,d0		;24 lines deep
		moveq	#15,d1		;15 words wide
		moveq	#47,d2		;x position
		moveq	#10,d3		;y position
		bsr	BlitLogo		;pop on logo

		move.l	RasterWaiting(a6),a1
		lea	Logo2,a0
		moveq	#29*3,d0		;29 lines deep
		moveq	#12,d1		;12 words wide
		moveq	#65,d2		;x position
		moveq	#40,d3		;y position
		bsr	BlitLogo		;pop on logo

		move.l	RasterWaiting(a6),a1
		lea	Logo3,a0
		move.w	#45*3,d0		;45 lines deep
		moveq	#7,d1		;7 words wide
		moveq	#107,d2		;x position
		moveq	#90,d3		;y position
		bsr	BlitLogo		;pop on logo

		move.l	RasterWaiting(a6),a1
		lea	Logo4,a0
		move.w	#43*3,d0		;43 lines deep
		moveq	#15,d1		;15 words wide
		moveq	#40,d2		;x position
		move.w	#140,d3		;y position
		bsr	BlitLogo		;pop on logo


* ...now switch the screen in. Prepare page 2 on inactive screen...


		sf	ScrSwitch(a6)	;reallow screen switch
		bsr	WaitVBL		;Wait for VBL
		st	ScrSwitch(a6)	;now lock out screen switch


* Note that this is where we come to once we've displayed all of the
* pages. Ignore the first page from now on or I'll be accused of
* ego tripping!


DTS_Rst		move.l	RasterWaiting(a6),a0
		bsr	BlitScrClear

		lea	ScannerImg,a0
		move.l	RasterWaiting(a6),a1
		move.w	#61*3,d0
		moveq	#20,d1
		moveq	#0,d2
		moveq	#0,d3
		bsr	BlitLogo

		lea	A1F1_G,a0
		move.l	RasterWaiting(a6),a1
		moveq	#11*3,d0
		moveq	#1,d1
		moveq	#58,d2
		moveq	#70,d3
		bsr	BlitLogo

		lea	Txt1_1,a0
		moveq	#42,d0
		moveq	#90,d1
		moveq	#3,d2
		bsr	BlitPString

		lea	Txt1_2,a0
		moveq	#38,d0
		moveq	#100,d1
		moveq	#1,d2
		bsr	BlitPString

		lea	A2F1_G,a0
		move.l	RasterWaiting(a6),a1
		moveq	#12*3,d0
		moveq	#1,d1
		move.w	#150,d2
		moveq	#70,d3
		bsr	BlitLogo

		lea	Txt2_1,a0
		move.w	#132,d0
		moveq	#90,d1
		moveq	#3,d2
		bsr	BlitPString

		lea	Txt2_2,a0
		move.w	#128,d0
		moveq	#100,d1
		moveq	#1,d2
		bsr	BlitPString

		lea	A3F1_G,a0
		move.l	RasterWaiting(a6),a1
		moveq	#7*3,d0
		moveq	#1,d1
		move.w	#240,d2
		moveq	#70,d3
		bsr	BlitLogo

		lea	Txt3_1,a0
		move.w	#222,d0
		moveq	#90,d1
		moveq	#3,d2
		bsr	BlitPString

		lea	Txt3_2,a0
		move.w	#218,d0
		moveq	#100,d1
		moveq	#1,d2
		bsr	BlitPString

		lea	A4F1_G,a0
		move.l	RasterWaiting(a6),a1
		moveq	#3*3,d0
		moveq	#1,d1
		moveq	#60,d2
		move.w	#140,d3
		bsr	BlitLogo

		lea	Txt4_1,a0
		moveq	#42,d0
		move.w	#160,d1
		moveq	#3,d2
		bsr	BlitPString

		lea	Txt4_2,a0
		moveq	#38,d0
		move.w	#170,d1
		moveq	#1,d2
		bsr	BlitPString

		lea	A5F1_G,a0
		move.l	RasterWaiting(a6),a1
		moveq	#5*3,d0
		moveq	#1,d1
		move.w	#152,d2
		move.w	#140,d3
		bsr	BlitLogo

		lea	Txt5_1,a0
		move.w	#128,d0
		move.w	#160,d1
		moveq	#3,d2
		bsr	BlitPString

		lea	Txt5_2,a0
		move.w	#128,d0
		move.w	#170,d1
		moveq	#1,d2
		bsr	BlitPString

		lea	A6F1_G,a0
		move.l	RasterWaiting(a6),a1
		moveq	#11*3,d0
		moveq	#1,d1
		move.w	#240,d2
		move.w	#140,d3
		bsr	BlitLogo

		lea	Txt6_1,a0
		move.w	#234,d0
		move.w	#160,d1
		moveq	#3,d2
		bsr	BlitPString

		lea	Txt6_2,a0
		move.w	#214,d0
		move.w	#170,d1
		moveq	#1,d2
		bsr	BlitPString


* ...now wait for 5 secs or a key press. If it's F1 or F2 then
* leave the title screens & set up 1 or 2 player game, if it's
* F3 then alter key assignments...


		move.l	VBLCounter(a6),d0	;get VBL Counter
		move.w	DispUnit(a6),d1
		mulu	#DDLY_STD,d1
		add.l	d1,d0
		move.l	d0,DispSCount(a6)	;save current VBL + 5 secs

DTS_1		bsr	GetAKey		;get a key
		cmp.b	#$80,d0		;F1?
		beq	DTS_Done		;skip if so
		cmp.b	#$81,d0		;F2?
		beq	DTS_Done		;skip if so
		cmp.b	#$82,d0		;F3?
		bne.s	DTS_1b		;skip if not
		bsr	SetUserKeys	;configure keys if F3 hit
		bra.s	DTS_1c		;and finished...

DTS_1b		cmp.b	#$0D,d0		;Return/Enter?
		bne.s	DTS_1a		;continue if not
		bsr	CheckPW		;are we cheating? sshh...

;		cmp.b	#$FF,OrdKey(a6)	;any key hit?
;		bne	DTS_Done		;exit if hit

DTS_1a		move.l	VBLCounter(a6),d0	;get VBL
		cmp.l	DispSCount(a6),d0	;time elapsed?
		bls.s	DTS_1		;back if not


* Now switch in page 2, prepare page 3 on inactive screen...


		sf	ScrSwitch(a6)
		bsr	WaitVBL
		st	ScrSwitch(a6)

DTS_1c		move.l	RasterWaiting(a6),a0
		bsr	BlitScrClear

		move.l	RasterWaiting(a6),a1
		lea	Logo4,a0
		move.w	#43*3,d0		;43 lines deep
		moveq	#15,d1		;15 words wide
		moveq	#40,d2		;x position
		moveq	#10,d3		;y position
		bsr	BlitLogo		;pop on logo

		lea	HDG_4,a0
		moveq	#112,d0
		moveq	#60,d1
		moveq	#2,d2
		bsr	BlitPString

		lea	HDG_1,a0
		moveq	#58,d0
		moveq	#80,d1
		moveq	#2,d2
		bsr	BlitPString

		lea	HDG_2,a0
		move.w	#208,d0
		moveq	#80,d1
		moveq	#2,d2
		bsr	BlitPString

		lea	HDG_3,a0
		moveq	#50,d0
		moveq	#90,d1
		moveq	#2,d2
		bsr	BlitPString

		lea	HDG_3,a0
		move.w	#208,d0
		moveq	#90,d1
		moveq	#2,d2
		bsr	BlitPString

		lea	TDG_Array,a2
		moveq	#110,d0		;1st Y pos
		moveq	#10,d1		;no to do

DTS_L1		move.l	(a2)+,d2		;get 1st number
		movem.l	d0/d1/a2,-(sp)	;save important values
		move.l	d2,d0
		lea	XBuf,a0
;		lea	Base10(pc),a1
		bsr	LtoA10		;long int to ASCII convert
		bsr	StrLen		;no of chars in d7
		movem.l	(sp),d0/d1/a2	;recover & preserve values
		neg.w	d7
		add.w	#9,d7		;9 chars max
		add.w	d7,d7
		add.w	d7,d7
		add.w	d7,d7
		add.w	#10,d7		;leftmost print pos
		move.w	d0,d1
		move.w	d7,d0
		moveq	#7,d2
		bsr	BlitPString
		movem.l	(sp)+,d0/d1/a2	;recover values (editable)
		move.l	a2,a0		;point to string
		addq.l	#4,a2		;point to next entry
		movem.l	d0/d1/a2,-(sp)	;save new values

		move.w	d0,d1		;y coord
		moveq	#90,d0		;x coord
		moveq	#7,d2
		bsr	BlitPString	;print string

		movem.l	(sp)+,d0/d1/a2	;recover values (editable)
		add.w	#12,d0		;next y pos

		subq.l	#1,d1		;done them all?
		bne.s	DTS_L1		;back if not

		lea	ATG_Array,a2
		moveq	#110,d0		;1st Y pos
		moveq	#10,d1		;no to do

DTS_L2		move.l	(a2)+,d2		;get 1st number
		movem.l	d0/d1/a2,-(sp)	;save important values
		move.l	d2,d0
		lea	XBuf,a0
;		lea	Base10(pc),a1
		bsr	LtoA10		;long int to ASCII convert
		bsr	StrLen		;no of chars in d7
		movem.l	(sp),d0/d1/a2	;recover & preserve values
		neg.w	d7
		add.w	#9,d7		;9 chars max
		add.w	d7,d7
		add.w	d7,d7
		add.w	d7,d7
		add.w	#168,d7		;leftmost print pos
		move.w	d0,d1
		move.w	d7,d0
		moveq	#7,d2
		bsr	BlitPString
		movem.l	(sp)+,d0/d1/a2	;recover values (editable)
		move.l	a2,a0		;point to string
		addq.l	#4,a2		;point to next entry
		movem.l	d0/d1/a2,-(sp)	;save new values

		move.w	d0,d1		;y coord
		move.w	#246,d0		;x coord
		moveq	#7,d2
		bsr	BlitPString	;print string

		movem.l	(sp)+,d0/d1/a2	;recover values (editable)
		add.w	#12,d0		;next y pos

		subq.l	#1,d1		;done them all?
		bne.s	DTS_L2		;back if not


* ...now wait for 5 secs or a key press...


		move.l	VBLCounter(a6),d0	;get VBL Counter
		move.w	DispUnit(a6),d1
		mulu	#DDLY_STD,d1
		add.l	d1,d0
		move.l	d0,DispSCount(a6)	;save current VBL + 5 secs

DTS_2		bsr	GetAKey		;get a key
		cmp.b	#$80,d0		;F1?
		beq	DTS_Done		;skip if so
		cmp.b	#$81,d0		;F2?
		beq	DTS_Done		;skip if so
		cmp.b	#$82,d0		;F3?
		bne.s	DTS_2b		;skip if not
		bsr	SetUserKeys	;configure keys if F3 hit
		bra.s	DTS_2c		;and finished...

DTS_2b		cmp.b	#$0D,d0		;Return/Enter?
		bne.s	DTS_2a		;continue if not
		bsr	CheckPW

;		cmp.b	#$FF,OrdKey(a6)	;any key hit?
;		bne.s	DTS_Done		;exit if hit

DTS_2a		move.l	VBLCounter(a6),d0	;get VBL
		cmp.l	DispSCount(a6),d0	;time elapsed?
		bls.s	DTS_2		;back if not


* ...now switch in page 3...


		sf	ScrSwitch(a6)	;allow screen switching
		bsr	WaitVBL		;wait for VBL
		st	ScrSwitch(a6)	;forbid it again


* ...now do Page 4 on the inactive screen...


DTS_2c		move.l	RasterWaiting(a6),a0
		bsr	BlitScrClear

		move.l	RasterWaiting(a6),a1
		lea	Logo4,a0
		move.w	#43*3,d0		;43 lines deep
	
		moveq	#15,d1		;15 words wide
		moveq	#40,d2		;x position
		moveq	#10,d3		;y position
		bsr	BlitLogo		;pop on logo


* Inform user what keys to press...


		lea	_PINST1,a0
		moveq	#60,d0
		moveq	#80,d1
		moveq	#2,d2
		bsr	BlitPString

		lea	_PINST2,a0
		moveq	#60,d0
		moveq	#100,d1
		moveq	#3,d2
		bsr	BlitPString

		lea	_PINST3,a0
		moveq	#60,d0
		moveq	#120,d1
		moveq	#4,d2
		bsr	BlitPString


* ...now wait for 5 secs or a key press...


		move.l	VBLCounter(a6),d0	;get VBL Counter
		move.w	DispUnit(a6),d1
		mulu	#DDLY_STD,d1
		add.l	d1,d0
		move.l	d0,DispSCount(a6)	;save current VBL + 5 secs

DTS_3		bsr	GetAKey		;get a key
		cmp.b	#$80,d0		;F1?
		beq	DTS_Done		;skip if so
		cmp.b	#$81,d0		;F2?
		beq	DTS_Done		;skip if so
		cmp.b	#$82,d0		;F3?
		bne.s	DTS_3b		;skip if not
		bsr	SetUserKeys	;configure keys if F3 hit
		bra.s	DTS_3c		;and finished...

DTS_3b		cmp.b	#$0D,d0		;Return/Enter?
		bne.s	DTS_3a		;continue if not
		bsr	CheckPW

;		cmp.b	#$FF,OrdKey(a6)	;any key hit?
;		bne.s	DTS_Done		;exit if hit

DTS_3a		move.l	VBLCounter(a6),d0	;get VBL
		cmp.l	DispSCount(a6),d0	;time elapsed?
		bls.s	DTS_3		;back if not


* Switch in page 4...


		sf	ScrSwitch(a6)
		bsr	WaitVBL
		st	ScrSwitch(a6)

;		bsr	AlterKeys	;debug only
;		bsr	SetUserKeys	;debug only


* Now do Page 5...


DTS_3c		move.l	RasterWaiting(a6),a0
		bsr	BlitScrClear

		move.l	RasterWaiting(a6),a1
		lea	Logo4,a0
		move.w	#43*3,d0		;43 lines deep
	
		moveq	#15,d1		;15 words wide
		moveq	#40,d2		;x position
		moveq	#10,d3		;y position
		bsr	BlitLogo		;pop on logo

		lea	_PINST4,a0
		move.w	#128,d0
		moveq	#60,d1
		moveq	#1,d2
		bsr	BlitPString

		lea	_PINST6,a0
		moveq	#76,d0
		moveq	#70,d1
		moveq	#2,d2
		bsr	BlitPString

		lea	_PINST7,a0
		move.w	#128,d0
		moveq	#80,d1
		moveq	#2,d2
		bsr	BlitPString

		move.l	Player1Data(a6),a0
		bsr	GetPlayerKeys
		lea	UpKeyPtr(a6),a0
		move.l	a0,Generic1(a6)
		lea	UpKeyVal(a6),a0
		move.l	a0,Generic2(a6)
		lea	AKStr3(pc),a0
		move.l	a0,Generic3(a6)

		moveq	#_NUMASNKEYS,d0	;loop counter

DTS_L3		move.w	d0,-(sp)		;save loop counter

		move.l	Generic3(a6),a0	;ptr to string to print
		move.w	(a0)+,d0		;get x pos
		move.w	(a0)+,d1		;get y pos
		move.b	(a0)+,d2		;get colour
		add.w	#10,d1		;y=y+10
		movem.w	d0-d1,-(sp)	;save coords
		move.l	a0,-(sp)		;save ptr
		bsr	BlitPString	;print string
		move.l	(sp)+,a0		;recover ptr
DTS_L4		tst.b	(a0)+		;skip past EOS of
		bne.s	DTS_L4		;current string
		move.l	a0,d0		;check for word alignment
		and.b	#1,d0		;address even?
		beq.s	DTS_B1		;skip if so
		addq.l	#1,a0		;else word align it!
DTS_B1		move.l	a0,Generic3(a6)	;& save for next
		move.l	Generic1(a6),a0	;get ptr to ptr vars
		move.l	(a0)+,d0		;get address of variable
		move.l	a0,Generic1(a6)	;save updated ptr to ptrs
		move.l	Generic2(a6),a0	;get ptr to values
		moveq	#0,d1
		move.b	(a0)+,d1		;get value of variable
		move.l	a0,Generic2(a6)	;save updated ptr
		bsr	GetKeyIDStr	;get ptr to ID string
		movem.w	(sp)+,d0-d1	;get coords
		moveq	#1,d2		;set colour
		add.w	#160,d0		;x=x+160
		bsr	BlitPString	;print ID string

		move.w	(sp)+,d0		;recover loop counter
		subq.w	#1,d0		;done them all?
		bne.s	DTS_L3		;back for more if not


* ...now wait for 5 secs or a key press...


		move.l	VBLCounter(a6),d0	;get VBL Counter
		move.w	DispUnit(a6),d1
		mulu	#DDLY_STD,d1
		add.l	d1,d0
		move.l	d0,DispSCount(a6)	;save current VBL + 5 secs

DTS_4		bsr	GetAKey		;get a key
		cmp.b	#$80,d0		;F1?
		beq	DTS_Done		;skip if so
		cmp.b	#$81,d0		;F2?
		beq	DTS_Done		;skip if so
		cmp.b	#$82,d0		;F3?
		bne.s	DTS_4b		;skip if not
		bsr	SetUserKeys	;configure keys if F3 hit
		bra.s	DTS_4c		;and finished...

DTS_4b		cmp.b	#$0D,d0		;Return/Enter?
		bne.s	DTS_4a		;continue if not
		bsr	CheckPW

;		cmp.b	#$FF,OrdKey(a6)	;any key hit?
;		bne.s	DTS_Done		;exit if hit

DTS_4a		move.l	VBLCounter(a6),d0	;get VBL
		cmp.l	DispSCount(a6),d0	;time elapsed?
		bls.s	DTS_4		;back if not


* Now switch in page 5...


		sf	ScrSwitch(a6)
		bsr	WaitVBL
		st	ScrSwitch(a6)


* ...now create Page 6...


DTS_4c		move.l	RasterWaiting(a6),a0
		bsr	BlitScrClear

		move.l	RasterWaiting(a6),a1
		lea	Logo4,a0
		move.w	#43*3,d0		;43 lines deep
	
		moveq	#15,d1		;15 words wide
		moveq	#40,d2		;x position
		moveq	#10,d3		;y position
		bsr	BlitLogo		;pop on logo

		lea	_PINST5,a0
		move.w	#128,d0
		moveq	#60,d1
		moveq	#1,d2
		bsr	BlitPString

		lea	_PINST6,a0
		moveq	#76,d0
		moveq	#70,d1
		moveq	#2,d2
		bsr	BlitPString

		lea	_PINST7,a0
		move.w	#128,d0
		moveq	#80,d1
		moveq	#2,d2
		bsr	BlitPString

		move.l	Player2Data(a6),a0
		bsr	GetPlayerKeys
		lea	UpKeyPtr(a6),a0
		move.l	a0,Generic1(a6)
		lea	UpKeyVal(a6),a0
		move.l	a0,Generic2(a6)
		lea	AKStr3(pc),a0
		move.l	a0,Generic3(a6)

		moveq	#_NUMASNKEYS,d0	;loop counter

DTS_L5		move.w	d0,-(sp)		;save loop counter

		move.l	Generic3(a6),a0	;ptr to string to print
		move.w	(a0)+,d0		;get x pos
		move.w	(a0)+,d1		;get y pos
		move.b	(a0)+,d2		;get colour
		add.w	#10,d1		;y=y+10
		movem.w	d0-d1,-(sp)	;save coords
		move.l	a0,-(sp)		;save ptr
		bsr	BlitPString	;print string
		move.l	(sp)+,a0		;recover ptr
DTS_L6		tst.b	(a0)+		;skip past EOS of
		bne.s	DTS_L6		;current string
		move.l	a0,d0		;check for word alignment
		and.b	#1,d0		;address even?
		beq.s	DTS_B2		;skip if so
		addq.l	#1,a0		;else word align it!
DTS_B2		move.l	a0,Generic3(a6)	;& save for next
		move.l	Generic1(a6),a0	;get ptr to ptr vars
		move.l	(a0)+,d0		;get address of variable
		move.l	a0,Generic1(a6)	;save updated ptr to ptrs
		move.l	Generic2(a6),a0	;get ptr to values
		moveq	#0,d1
		move.b	(a0)+,d1		;get value of variable
		move.l	a0,Generic2(a6)	;save updated ptr
		bsr	GetKeyIDStr	;get ptr to ID string
		movem.w	(sp)+,d0-d1	;get coords
		moveq	#1,d2		;set colour
		add.w	#160,d0		;x=x+160
		bsr	BlitPString	;print ID string

		move.w	(sp)+,d0		;recover loop counter
		subq.w	#1,d0		;done them all?
		bne.s	DTS_L5		;back for more if not


* ...now wait for 5 secs or a key press...


		move.l	VBLCounter(a6),d0	;get VBL Counter
		move.w	DispUnit(a6),d1
		mulu	#DDLY_STD,d1
		add.l	d1,d0
		move.l	d0,DispSCount(a6)	;save current VBL + 5 secs

DTS_5		bsr	GetAKey		;get a key
		cmp.b	#$80,d0		;F1?
		beq.s	DTS_Done		;skip if so
		cmp.b	#$81,d0		;F2?
		beq.s	DTS_Done		;skip if so
		cmp.b	#$82,d0		;F3?
		bne.s	DTS_5b		;skip if not
		bsr	SetUserKeys	;configure keys if F3 hit
		bra.s	DTS_5c		;and finished...

DTS_5b		cmp.b	#$0D,d0		;Return/Enter?
		bne.s	DTS_5a		;continue if not
		bsr	CheckPW

;		cmp.b	#$FF,OrdKey(a6)	;any key hit?
;		bne.s	DTS_Done		;exit if hit

DTS_5a		move.l	VBLCounter(a6),d0	;get VBL
		cmp.l	DispSCount(a6),d0	;time elapsed?
		bls.s	DTS_5		;back if not


* Now switch in last page...


		sf	ScrSwitch(a6)
		bsr	WaitVBL
		st	ScrSwitch(a6)


* ...now repeat the whole cycle!!!


DTS_5c		bra	DTS_Rst

DTS_Done		sub.w	#$80,d0			;get player count
		move.w	d0,PlayerIndex(a6)	;and save it

		rts


* GetReadyScreen(a6)
* a6 = ptr to main program variables
* display the 'get ready' screen, then wait 5 secs
* or until user hits key/moves joystick etc.

* d0-d7/a0-a2 corrupt


GetReadyScreen	nop

		bsr	WaitVBL

		st	ScrSwitch(a6)

		move.l	RasterWaiting(a6),a0
		bsr	BlitScrClear

		move.l	RasterWaiting(a6),a1
		lea	Logo4,a0
		move.w	#43*3,d0		;43 lines deep
	
		moveq	#15,d1		;15 words wide
		moveq	#40,d2		;x position
		moveq	#10,d3		;y position
		bsr	BlitLogo		;pop on logo

		move.l	CurrentPlayer(a6),a0
		move.l	pd_Name(a0),a0
		move.w	#128,d0
		moveq	#100,d1
		moveq	#2,d2
		bsr	BlitPString

		lea	XBuf,a0
		move.l	CurrentPlayer(a6),a1
		move.l	pd_WaveNumber(a1),d0
		bsr	LtoA10

		lea	_PINST12,a0	;"attack wave" text
		move.l	a0,a1		;copy ptr
		lea	XBuf,a2		;ptr to ASCIIZ from above
		add.w	#12,a1		;point past text

GRdy_3		move.b	(a2)+,(a1)+	;copy string
		bne.s	GRdy_3		;including EOS

;		lea	_PINST12,a0
		moveq	#104,d0
		move.w	#140,d1
		moveq	#7,d2
		bsr	BlitPString

		sf	ScrSwitch(a6)
		bsr	WaitVBL
		st	ScrSwitch(a6)

		move.l	VBLCounter(a6),d0	;get VBL Counter
		move.w	DispUnit(a6),d1
		mulu	#DDLY_STD,d1
		add.l	d1,d0
		move.l	d0,DispSCount(a6)	;save current VBL + 5 secs

GRdy_1		bsr	GetAnyGameIO	;any key/joystick activity?
		tst.l	d0
		bne.s	GRdy_2		;exit if so

		move.l	VBLCounter(a6),d0	;done 5 secs waiting?
		cmp.l	DispSCount(a6),d0
		bls.s	GRdy_1		;back for more if not

GRdy_2		rts


* SetUserKeys(a6)
* a6 = ptr to main program variables
* Set key preferences for Player 1 & Player 2.

* d0-d5/d7/a0-a1 corrupt


SetUserKeys	st	ScrSwitch(a6)		;kill screen switching

		move.l	RasterWaiting(a6),a0	;clear inactive screen
		bsr	BlitScrClear

		move.l	RasterWaiting(a6),a1
		lea	Logo4,a0
		move.w	#43*3,d0		;43 lines deep
	
		moveq	#15,d1		;15 words wide
		moveq	#40,d2		;x position
		moveq	#10,d3		;y position
		bsr	BlitLogo		;pop on logo

		lea	SUKStr1(pc),a0
		move.w	(a0)+,d0
		move.w	(a0)+,d1
		move.b	(a0)+,d2
		bsr	BlitPString

		lea	SUKStr3(pc),a0
		move.w	(a0)+,d0
		move.w	(a0)+,d1
		move.b	(a0)+,d2
		bsr	BlitPString

		lea	SUKStr4(pc),a0
		move.w	(a0)+,d0
		move.w	(a0)+,d1
		move.b	(a0)+,d2
		bsr	BlitPString

		lea	SUKStr5(pc),a0
		move.w	(a0)+,d0
		move.w	(a0)+,d1
		move.b	(a0)+,d2
		bsr	BlitPString

		lea	SUKStr6(pc),a0
		move.w	(a0)+,d0
		move.w	(a0)+,d1
		move.b	(a0)+,d2
		bsr	BlitPString

		sf	ScrSwitch(a6)
		bsr	WaitVBL
		st	ScrSwitch(a6)

SUK_L1		move.b	OrdKey(a6),d0	;get key
		cmp.b	#$45,d0		;ESC?
		beq.s	SUK_L2		;skip if so
		cmp.b	#$44,d0		;Enter?
		beq.s	SUK_B1		;change keys if so
		cmp.b	#$43,d0		;keypad Enter?
		bne.s	SUK_L1		;back if not

SUK_B1		cmp.b	#$FF,OrdKey(a6)	;wait until key
		bne.s	SUK_B1		;released

		bsr	AlterKeys	;then set keys

		move.l	Player1Data(a6),a0	;and set them
		bsr	SetPlayerKeys		;for Player 1

SUK_L2		cmp.b	#$FF,OrdKey(a6)	;wait until key
		bne.s	SUK_L2		;released

		st	ScrSwitch(a6)		;kill screen switching

		move.l	RasterWaiting(a6),a0	;clear inactive screen
		bsr	BlitScrClear

		move.l	RasterWaiting(a6),a1
		lea	Logo4,a0
		move.w	#43*3,d0		;43 lines deep
	
		moveq	#15,d1		;15 words wide
		moveq	#40,d2		;x position
		moveq	#10,d3		;y position
		bsr	BlitLogo		;pop on logo

		lea	SUKStr2(pc),a0
		move.w	(a0)+,d0
		move.w	(a0)+,d1
		move.b	(a0)+,d2
		bsr	BlitPString

		lea	SUKStr3(pc),a0
		move.w	(a0)+,d0
		move.w	(a0)+,d1
		move.b	(a0)+,d2
		bsr	BlitPString

		lea	SUKStr4(pc),a0
		move.w	(a0)+,d0
		move.w	(a0)+,d1
		move.b	(a0)+,d2
		bsr	BlitPString

		lea	SUKStr5(pc),a0
		move.w	(a0)+,d0
		move.w	(a0)+,d1
		move.b	(a0)+,d2
		bsr	BlitPString

		lea	SUKStr6(pc),a0
		move.w	(a0)+,d0
		move.w	(a0)+,d1
		move.b	(a0)+,d2
		bsr	BlitPString

		sf	ScrSwitch(a6)
		bsr	WaitVBL
		st	ScrSwitch(a6)

SUK_L3		move.b	OrdKey(a6),d0	;get key
		cmp.b	#$45,d0		;ESC?
		beq.s	SUK_L4		;skip if so
		cmp.b	#$44,d0		;Enter?
		beq.s	SUK_B2		;change keys if so
		cmp.b	#$43,d0		;keypad Enter?
		bne.s	SUK_L3		;back if not

SUK_B2		cmp.b	#$FF,OrdKey(a6)	;wait until key
		bne.s	SUK_B2		;released

		bsr	AlterKeys	;then set them

		move.l	Player2Data(a6),a0	;and set them
		bsr	SetPlayerKeys		;for Player 2

SUK_L4		cmp.b	#$FF,OrdKey(a6)	;wait until key
		bne.s	SUK_L4		;released

		rts


* AlterKeys(a6)
* a6 = ptr to main variables

* Alter keyboard/joystick/mouse assignments according to user
* preference.

* d0-d5/d7/a0-a1 corrupt


AlterKeys	st	ScrSwitch(a6)		;kill screen switching

		move.l	RasterWaiting(a6),a0	;clear inactive screen
		bsr	BlitScrClear

		move.l	RasterWaiting(a6),a1
		lea	Logo4,a0
		move.w	#43*3,d0		;43 lines deep
	
		moveq	#15,d1		;15 words wide
		moveq	#40,d2		;x position
		moveq	#10,d3		;y position
		bsr	BlitLogo		;pop on logo

		lea	AKStr1(pc),a0
		move.w	(a0)+,d0
		move.w	(a0)+,d1
		move.b	(a0)+,d2
		bsr	BlitPString

		lea	AKStr2(pc),a0
		move.w	(a0)+,d0
		move.w	(a0)+,d1
		move.b	(a0)+,d2
		bsr	BlitPString


* Now switch in screen...


		sf	ScrSwitch(a6)	;allow screen switching
		bsr	WaitVBL		;wait for VBL
		st	ScrSwitch(a6)	;forbid it again


* Now repeat on second screen...


		move.l	RasterWaiting(a6),a0	;clear inactive screen
		bsr	BlitScrClear

		move.l	RasterWaiting(a6),a1
		lea	Logo4,a0
		move.w	#43*3,d0		;43 lines deep
	
		moveq	#15,d1		;15 words wide
		moveq	#40,d2		;x position
		moveq	#10,d3		;y position
		bsr	BlitLogo		;pop on logo

		lea	AKStr1(pc),a0
		move.w	(a0)+,d0
		move.w	(a0)+,d1
		move.b	(a0)+,d2
		bsr	BlitPString

		lea	AKStr2(pc),a0
		move.w	(a0)+,d0
		move.w	(a0)+,d1
		move.b	(a0)+,d2
		bsr	BlitPString


* And wait for various key pressings/joystick moves etc.


		moveq	#_NUMASNKEYS,d7	;number of variables to do

		lea	UpKeyPtr(a6),a0	;ptr to controller vars
		move.l	a0,Generic1(a6)	;save
		lea	UpKeyVal(a6),a0	;ptr to controller values
		move.l	a0,Generic2(a6)	;save
		lea	AKStr3(pc),a0	;ptr to strings to print
		move.l	a0,Generic3(a6)	;save
		lea	UpKeyMsk(a6),a0	;ptr to controller masks
		move.l	a0,Generic4(a6)

AKey_L1		move.w	d7,-(sp)		;save counter

		move.l	Generic3(a6),a0	;print function on
		move.w	(a0)+,d0		;INACTIVE screen
		move.w	(a0)+,d1
		move.b	(a0)+,d2
		move.w	d1,AKVert(a6)	;save coords for later
		move.w	d0,AKHoriz(a6)
		bsr	BlitPString

		sf	ScrSwitch(a6)	;switch screens
		bsr	WaitVBL
		st	ScrSwitch(a6)

		move.l	Generic3(a6),a0	;repeat for new
		move.w	(a0)+,d0		;INACTIVE screen
		move.w	(a0)+,d1
		move.b	(a0)+,d2
		move.l	a0,Generic3(a6)	;save string ptr
		bsr	BlitPString
		move.l	Generic3(a6),a0	;get ptr

AKey_L2		tst.b	(a0)+		;skip to EOS
		bne.s	AKey_L2		;and then past it

		move.l	a0,d0		;get ptr to next data
		and.b	#1,d0		;word aligned?
		beq.s	AKey_B1		;skip if so
		addq.l	#1,a0		;else align it
AKey_B1		move.l	a0,Generic3(a6)	;save for next round

AKey_L3		bsr	GetAnyGameIO	;check for response
		beq.s	AKey_L3		;back until we get one

		movem.l	d0-d2,-(sp)	;save return values

AKey_L4		bsr	GetAnyGameIO	;check for continued response
		bne.s	AKey_L4		;back until it's ended

		movem.l	(sp)+,d0-d2	;recover return values

		move.l	Generic1(a6),a0	;get variable table ptr
		move.l	d0,(a0)+		;save variable ptr
		move.l	a0,Generic1(a6)	;save updated table ptr
		move.l	Generic2(a6),a0	;value table ptr
		move.b	d1,(a0)+		;save value
		move.l	a0,Generic2(a6)	;save updated table ptr
		move.l	Generic4(a6),a0	;get mask table ptr
		move.b	d2,(a0)+		;save mask
		move.l	a0,Generic4(a6)	;save updated table ptr

		bsr	GetKeyIDStr
		move.l	a0,d0		;check ptr
		beq.s	AKey_B2		;skip if invalid

		move.l	a0,-(sp)		;save string ptr
		move.w	AKHoriz(a6),d0
		add.w	#140,d0
		move.w	AKVert(a6),d1	;print string on the
		moveq	#1,d2		;INACTIVE screen
		bsr	BlitPString

		sf	ScrSwitch(a6)	;now enable screen switch
		bsr	WaitVBL
		st	ScrSwitch(a6)	;disable again

		move.l	(sp)+,a0
		move.w	AKHoriz(a6),d0
		add.w	#140,d0		;repeat print on the
		move.w	AKVert(a6),d1	;other INACTIVE screen
		moveq	#1,d2
		bsr	BlitPString

AKey_B2		move.w	(sp)+,d7		;recover counter
		subq.w	#1,d7		;done all of them?
		bne	AKey_L1		;back if not

		lea	AKStr10(pc),a0
		move.w	(a0)+,d0
		move.w	(a0)+,d1
		move.b	(a0)+,d2
		bsr	BlitPString

		lea	AKStr11(pc),a0
		move.w	(a0)+,d0
		move.w	(a0)+,d1
		move.b	(a0)+,d2
		bsr	BlitPString

		sf	ScrSwitch(a6)
		bsr	WaitVBL
		st	ScrSwitch(a6)

AKey_L5		move.b	OrdKey(a6),d0	;get key press
		cmp.b	#$45,d0		;ESC?
		beq	AlterKeys	;do again if so
		cmp.b	#$44,d0		;ENTER?
		beq.s	AKey_Done	;exit if so
		cmp.b	#$43,d0		;Keypad ENTER?
		bne.s	AKey_L5		;get another key if not

;		bsr	WaitMBDown	;debug only!
;		bsr	WaitMBUp

AKey_Done	cmp.b	#$FF,OrdKey(a6)	;wait until key is
		bne.s	AKey_Done	;released

		rts


* GetAnyGameIO(a6) -> d0/d1/d2
* a6 = ptr to main program variables
* obtain ANY valid response, be it a key press,
* a joystick movement or the fire button.

* Returns:

* Pointer to relevant response variable in d0 (NULL if no response)
* value contained in that variable in d1
* mask to use in d2

* d2/a0 corrupt


GetAnyGameIO	moveq	#0,d0
		moveq	#$7F,d2		;mask to use
		lea	OrdKey(a6),a0	;ptr to variable!
		move.b	(a0),d0		;get its value
		cmp.b	#$FF,d0		;ANY key press?
		bne.s	GAGIO_Done	;skip if so

		lea	JoyPos(a6),a0	;this time it's joystick
		move.b	(a0),d0		;ANY joystick movement?
		bne.s	GAGIO_Done	;skip if so

		lea	JoyButton(a6),a0	;this time its fire button
		moveq	#-1,d2		;new mask
		move.b	(a0),d0		;pressed?
		bne.s	GAGIO_Done

		lea	ShiftKey(a6),a0	;Now it's shifted keys
		move.b	(a0),d0		;get shift keys
		beq.s	GAGIO_Exit	;there are none-leave

		moveq	#1,d1		;1st bit to check

GAGIO_1		move.b	d0,d2
		and.b	d1,d2		;this bit set?
		beq.s	GAGIO_2		;skip if not
		move.b	d1,d0		;else use this value
		bra.s	GAGIO_Done	;and leave it

GAGIO_2		add.b	d1,d1		;next bit
		cmp.b	#_SK_CAPS,d1	;CAPS LOCK?
		beq.s	GAGIO_2		;skip CAPS LOCK if so!
		tst.b	d1		;done all 8 bits?
		bne.s	GAGIO_1		;back until 8 bits done

		move.b	d1,d0		;for safety in case
		sub.l	a0,a0		;CAPS LOCK hit
		moveq	#$7F,d2		;including mask

GAGIO_Done	move.b	d0,d1		;return values
		move.l	a0,d0		;go here
		rts

GAGIO_Exit	moveq	#0,d0		;NULL pointer
		move.b	d0,d1		;and this doesn't matter!
		rts


* GetKeyIDStr(a6,d0,d1) -> a0
* a6 = ptr to main program variables
* d0 = variable ptr from GetAnyGameIO()
* d1 = variable value from GetAnyGameIO()

* Returns pointer to required string to print to identify
* IO response in a0 (NULL if invalid IO response ID)

* d1/a0 corrupt


GetKeyIDStr	lea	OrdKey(a6),a0	;ptr to OrdKey variable
		cmp.l	a0,d0		;pointers same?
		bne	GKIS_1		;skip if not

		move.l	MyKeyMap(a6),a0	;get keymap ptr
		and.w	#$7F,d1		;ensure key conformity


* This code handles special keys (e.g., non-printable ASCII chars or
* ones not in the special charset). THIS IS UK KEYBOARD SPECIFIC
* CODE - FOR USA OR OTHER KEYBOARDS IT MUST BE CHANGED!


		cmp.b	#$41,d1		;backspace?
		bne.s	GKIS_s1		;skip if not
		lea	AKXK1(pc),a0	;else this string
		rts

GKIS_s1		cmp.b	#$46,d1		;DEL?
		bne.s	GKIS_s2		;skip if not
		lea	AKXK2(pc),a0	;else this string
		rts			;and so on ...

GKIS_s2		cmp.b	#$5F,d1		;HELP?
		bne.s	GKIS_s3
		lea	AKXK3(pc),a0
		rts

GKIS_s3		cmp.b	#$44,d1		;RETURN?
		bne.s	GKIS_s4
		lea	AKXK4(pc),a0
		rts

GKIS_s4		cmp.b	#$43,d1		;Keypad ENTER?
		bne.s	GKIS_s5
		lea	AKXK5(pc),a0
		rts

GKIS_s5		cmp.b	#$42,d1		;TAB?
		bne.s	GKIS_s6
		lea	AKXK6(pc),a0
		rts

GKIS_s6		cmp.b	#$00,d1		;Quote (') ?
		bne.s	GKIS_s7
		lea	AKXK7(pc),a0
		rts

GKIS_s7		cmp.b	#$38,d1		;comma?
		bne.s	GKIS_s8
		lea	AKXK8(pc),a0
		rts

GKIS_s8		cmp.b	#$39,d1		;full stop?
		bne.s	GKIS_s9
		lea	AKXK9(pc),a0
		rts

GKIS_s9		cmp.b	#$29,d1		;semicolon?
		bne.s	GKIS_s10
		lea	AKXK10(pc),a0
		rts

GKIS_s10		cmp.b	#$2A,d1		;hash?
		bne.s	GKIS_s11
		lea	AKXK11(pc),a0
		rts

GKIS_s11		cmp.b	#$1A,d1		;"[" key?
		bne.s	GKIS_s12
		lea	AKXK12(pc),a0
		rts

GKIS_s12		cmp.b	#$1B,d1		;"]" key?
		bne.s	GKIS_s13
		lea	AKXK13(pc),a0
		rts

GKIS_s13		cmp.b	#$0B,d1		;"-" key?
		bne.s	GKIS_s14
		lea	AKXK14(pc),a0
		rts

GKIS_s14		cmp.b	#$0C,d1		;"=" key?
		bne.s	GKIS_s15
		lea	AKXK15(pc),a0
		rts

GKIS_s15		cmp.b	#$0D,d1		;"\" key?
		bne.s	GKIS_s16
		lea	AKXK16(pc),a0
		rts

GKIS_s16		cmp.b	#$40,d1		;SPACE?
		bne.s	GKIS_s17
		lea	AKXK17(pc),a0
		rts

GKIS_s17		cmp.b	#$4C,d1		;cursor up?
		bne.s	GKIS_s18
		lea	AKXK18(pc),a0
		rts

GKIS_s18		cmp.b	#$4D,d1		;cursor down?
		bne.s	GKIS_s19
		lea	AKXK19(pc),a0
		rts

GKIS_s19		cmp.b	#$4F,d1		;cursor left?
		bne.s	GKIS_s20
		lea	AKXK20(pc),a0
		rts

GKIS_s20		cmp.b	#$4E,d1		;cursor right?
		bne.s	GKIS_s21
		lea	AKXK21(pc),a0
		rts


* Now return to handling normal keys.


GKIS_s21		move.b	0(a0,d1.w),d1	;get ASCII entry
		lea	AKOrd(pc),a0	;ptr to string
		move.b	d1,9(a0)		;insert char
		clr.b	10(a0)		;and EOS
		rts			;and return ptr

GKIS_1		lea	JoyPos(a6),a0	;ptr to JoyPos variable
		cmp.l	a0,d0		;pointers same?
		bne.s	GKIS_2		;skip if not

		cmp.b	#1,d1		;Joystick UP?
		bne.s	GKIS_1a		;skip if not
		lea	AKJoy1(pc),a0	;else point to this
		rts
GKIS_1a		cmp.b	#2,d1		;Joystick DOWN?
		bne.s	GKIS_4		;exit if not
		lea	AKJoy2(pc),a0	;else point to this
		rts

GKIS_2		lea	JoyButton(a6),a0	;ptr to JoyButton variable
		cmp.l	a0,d0		;ptrs equal?
		bne.s	GKIS_3		;skip if not

		tst.b	d1		;button pressed?
		beq.s	GKIS_4		;skip if not
		lea	AKJoy3(pc),a0	;else point to this
		rts

GKIS_3		lea	ShiftKey(a6),a0	;ptr to ShiftKey variable
		cmp.l	a0,d0		;ptrs equal?
		bne.s	GKIS_4		;skip if not

		cmp.b	#_SK_LSHIFT,d1	;this key?
		bne.s	GKIS_3a		;skip if not
		lea	AKSH1(pc),a0	;else point to this
		rts
GKIS_3a		cmp.b	#_SK_RSHIFT,d1	;this key?
		bne.s	GKIS_3b		;skip if not
		lea	AKSH2(pc),a0	;else point to this
		rts
GKIS_3b		cmp.b	#_SK_CTRL,d1	;this key?
		bne.s	GKIS_3c		;skip if not
		lea	AKSH3(pc),a0	;else point to this
		rts
GKIS_3c		cmp.b	#_SK_LALT,d1	;this key?
		bne.s	GKIS_3d		;skip if not
		lea	AKSH4(pc),a0	;else point to this
		rts
GKIS_3d		cmp.b	#_SK_RALT,d1	;this key?
		bne.s	GKIS_3e		;skip if not
		lea	AKSH5(pc),a0	;else point to this
		rts
GKIS_3e		cmp.b	#_SK_LAMIGA,d1	;this key?
		bne.s	GKIS_3f		;skip if not
		lea	AKSH6(pc),a0	;else point to this
		rts
GKIS_3f		cmp.b	#_SK_RAMIGA,d1	;this key?
		bne.s	GKIS_4		;skip if not
		lea	AKSH7(pc),a0	;else point to this
		rts

GKIS_4		sub.l	a0,a0		;NULL pointer-invalid!
		rts


* Strings for use with AlterKeys() above etc.:


SUKStr1		dc.w	128,70
		dc.b	2
		dc.b	"Player 1",0
		even

SUKStr2		dc.w	128,70
		dc.b	2
		dc.b	"Player 2",0
		even

SUKStr3		dc.w	56,80
		dc.b	2
		dc.b	"Press ENTER to change your",0
		even

SUKStr4		dc.w	80,90
		dc.b	2
		dc.b	"Keyboard Preferences",0
		even

SUKStr5		dc.w	68,100
		dc.b	2
		dc.b	"Press ESC to leave them",0
		even

SUKStr6		dc.w	140,110
		dc.b	2
		dc.b	"alone",0


AKStr1		dc.w	48,60
		dc.b	7
		dc.b	"Select Keyboard And Joystick",0
		even

AKStr2		dc.w	112,70
		dc.b	7
		dc.b	"Preferences",0
		even

AKStr3		dc.w	30,90
		dc.b	3
		dc.b	"Move Ship Up",0
		even

AKStr4		dc.w	30,100
		dc.b	3
		dc.b	"Move Ship Down",0
		even

AKStr5		dc.w	30,110
		dc.b	3
		dc.b	"Thrust",0
		even

AKStr6		dc.w	30,120
		dc.b	3
		dc.b	"Fire Lasers",0
		even

AKStr7		dc.w	30,130
		dc.b	3
		dc.b	"Reverse Ship",0
		even

AKStr8		dc.w	30,140
		dc.b	3
		dc.b	"Smart Bomb",0
		even

AKStr9		dc.w	30,150
		dc.b	3
		dc.b	"Hyperspace",0
		even

AKStr10		dc.w	76,180
		dc.b	4
		dc.b	"Press ENTER to Finish",0
		even

AKStr11		dc.w	76,190
		dc.b	4
		dc.b	"Press ESC to do again",0


AKOrd		dc.b	"Keyboard  ",0

AKJoy1		dc.b	"Joystick UP",0

AKJoy2		dc.b	"Joystick DOWN",0

AKJoy3		dc.b	"Joystick FIRE",0

AKSH1		dc.b	"Left SHIFT",0
AKSH2		dc.b	"Right SHIFT",0
AKSH3		dc.b	"CTRL",0
AKSH4		dc.b	"Left ALT",0
AKSH5		dc.b	"Right ALT",0
AKSH6		dc.b	"Left AMIGA",0
AKSH7		dc.b	"Right AMIGA",0

AKXK1		dc.b	"BACKSPACE",0
AKXK2		dc.b	"DEL",0
AKXK3		dc.b	"HELP",0
AKXK4		dc.b	"RETURN",0
AKXK5		dc.b	"ENTER",0
AKXK6		dc.b	"TAB",0
AKXK7		dc.b	"QUOTE",0
AKXK8		dc.b	"COMMA",0
AKXK9		dc.b	"FULL STOP",0
AKXK10		dc.b	"SEMICOLON",0
AKXK11		dc.b	"HASH",0
AKXK12		dc.b	"LEFT BRACE",0
AKXK13		dc.b	"RIGHT BRACE",0
AKXK14		dc.b	"MINUS",0
AKXK15		dc.b	"EQUALS",0
AKXK16		dc.b	"BACKSLASH",0
AKXK17		dc.b	"SPACE",0
AKXK18		dc.b	"CURSOR UP",0
AKXK19		dc.b	"CURSOR DOWN",0
AKXK20		dc.b	"CURSOR LEFT",0
AKXK21		dc.b	"CURSOR RIGHT",0

		even


* GetPlayerKeys(a6,a0)
* a6 = ptr to main program variables
* a0 = ptr to required PlayerData structure

* Get the player's own key settings.

* no registers corrupt!


GetPlayerKeys	move.l	pd_UpKeyPtr(a0),UpKeyPtr(a6)
		move.l	pd_DownKeyPtr(a0),DownKeyPtr(a6)
		move.l	pd_ThrKeyPtr(a0),ThrKeyPtr(a6)
		move.l	pd_FireKeyPtr(a0),FireKeyPtr(a6)
		move.l	pd_RevKeyPtr(a0),RevKeyPtr(a6)
		move.l	pd_SBKeyPtr(a0),SBKeyPtr(a6)

		move.b	pd_UpKeyVal(a0),UpKeyVal(a6)
		move.b	pd_DownKeyVal(a0),DownKeyVal(a6)
		move.b	pd_ThrKeyVal(a0),ThrKeyVal(a6)
		move.b	pd_FireKeyVal(a0),FireKeyVal(a6)
		move.b	pd_RevKeyVal(a0),RevKeyVal(a6)
		move.b	pd_SBKeyVal(a0),SBKeyVal(a6)

		move.b	pd_UpKeyMsk(a0),UpKeyMsk(a6)
		move.b	pd_DownKeyMsk(a0),DownKeyMsk(a6)
		move.b	pd_ThrKeyMsk(a0),ThrKeyMsk(a6)
		move.b	pd_FireKeyMsk(a0),FireKeyMsk(a6)
		move.b	pd_RevKeyMsk(a0),RevKeyMsk(a6)
		move.b	pd_SBKeyMsk(a0),SBKeyMsk(a6)

		rts


* SetPlayerKeys(a6,a0)
* a6 = ptr to main program variables
* a0 = ptr to required PlayerData structure

* Set the player's own key settings.

* no registers corrupt!


SetPlayerKeys	move.l	UpKeyPtr(a6),pd_UpKeyPtr(a0)
		move.l	DownKeyPtr(a6),pd_DownKeyPtr(a0)
		move.l	ThrKeyPtr(a6),pd_ThrKeyPtr(a0)
		move.l	FireKeyPtr(a6),pd_FireKeyPtr(a0)
		move.l	RevKeyPtr(a6),pd_RevKeyPtr(a0)
		move.l	SBKeyPtr(a6),pd_SBKeyPtr(a0)

		move.b	UpKeyVal(a6),pd_UpKeyVal(a0)
		move.b	DownKeyVal(a6),pd_DownKeyVal(a0)
		move.b	ThrKeyVal(a6),pd_ThrKeyVal(a0)
		move.b	FireKeyVal(a6),pd_FireKeyVal(a0)
		move.b	RevKeyVal(a6),pd_RevKeyVal(a0)
		move.b	SBKeyVal(a6),pd_SBKeyVal(a0)

		move.b	UpKeyMsk(a6),pd_UpKeyMsk(a0)
		move.b	DownKeyMsk(a6),pd_DownKeyMsk(a0)
		move.b	ThrKeyMsk(a6),pd_ThrKeyMsk(a0)
		move.b	FireKeyMsk(a6),pd_FireKeyMsk(a0)
		move.b	RevKeyMsk(a6),pd_RevKeyMsk(a0)
		move.b	SBKeyMsk(a6),pd_SBKeyMsk(a0)

		rts


* InitPlayerKeys(a6)
* a6 = ptr to main program variables
* set the initial player key states for both players.

* d0/a0-a1 corrupt


InitPlayerKeys	lea	_KeyPrefs,a0	;ptr to table

		move.l	Player1Data(a6),a1	;this player

		move.l	(a0)+,d0			;get var offset
		add.l	a6,d0			;make true ptr
		move.l	d0,pd_UpKeyPtr(a1)	;save
		move.b	(a0)+,pd_UpKeyVal(a1)	;get value
		move.b	(a0)+,pd_UpKeyMsk(a1)	;and mask

		move.l	(a0)+,d0			;get var offset
		add.l	a6,d0			;make true ptr
		move.l	d0,pd_DownKeyPtr(a1)	;save
		move.b	(a0)+,pd_DownKeyVal(a1)	;get value
		move.b	(a0)+,pd_DownKeyMsk(a1)	;and mask

		move.l	(a0)+,d0			;get var offset
		add.l	a6,d0			;make true ptr
		move.l	d0,pd_ThrKeyPtr(a1)	;save
		move.b	(a0)+,pd_ThrKeyVal(a1)	;get value
		move.b	(a0)+,pd_ThrKeyMsk(a1)	;and mask

		move.l	(a0)+,d0			;get var offset
		add.l	a6,d0			;make true ptr
		move.l	d0,pd_FireKeyPtr(a1)	;save
		move.b	(a0)+,pd_FireKeyVal(a1)	;get value
		move.b	(a0)+,pd_FireKeyMsk(a1)	;and mask

		move.l	(a0)+,d0			;get var offset
		add.l	a6,d0			;make true ptr
		move.l	d0,pd_RevKeyPtr(a1)	;save
		move.b	(a0)+,pd_RevKeyVal(a1)	;get value
		move.b	(a0)+,pd_RevKeyMsk(a1)	;and mask

		move.l	(a0)+,d0			;get var offset
		add.l	a6,d0			;make true ptr
		move.l	d0,pd_SBKeyPtr(a1)	;save
		move.b	(a0)+,pd_SBKeyVal(a1)	;get value
		move.b	(a0)+,pd_SBKeyMsk(a1)	;and mask

		lea	_KeyPrefs,a0	;ptr to table

		move.l	Player2Data(a6),a1	;this player

		move.l	(a0)+,d0			;get var offset
		add.l	a6,d0			;make true ptr
		move.l	d0,pd_UpKeyPtr(a1)	;save
		move.b	(a0)+,pd_UpKeyVal(a1)	;get value
		move.b	(a0)+,pd_UpKeyMsk(a1)	;and mask

		move.l	(a0)+,d0			;get var offset
		add.l	a6,d0			;make true ptr
		move.l	d0,pd_DownKeyPtr(a1)	;save
		move.b	(a0)+,pd_DownKeyVal(a1)	;get value
		move.b	(a0)+,pd_DownKeyMsk(a1)	;and mask

		move.l	(a0)+,d0			;get var offset
		add.l	a6,d0			;make true ptr
		move.l	d0,pd_ThrKeyPtr(a1)	;save
		move.b	(a0)+,pd_ThrKeyVal(a1)	;get value
		move.b	(a0)+,pd_ThrKeyMsk(a1)	;and mask

		move.l	(a0)+,d0			;get var offset
		add.l	a6,d0			;make true ptr
		move.l	d0,pd_FireKeyPtr(a1)	;save
		move.b	(a0)+,pd_FireKeyVal(a1)	;get value
		move.b	(a0)+,pd_FireKeyMsk(a1)	;and mask

		move.l	(a0)+,d0			;get var offset
		add.l	a6,d0			;make true ptr
		move.l	d0,pd_RevKeyPtr(a1)	;save
		move.b	(a0)+,pd_RevKeyVal(a1)	;get value
		move.b	(a0)+,pd_RevKeyMsk(a1)	;and mask

		move.l	(a0)+,d0			;get var offset
		add.l	a6,d0			;make true ptr
		move.l	d0,pd_SBKeyPtr(a1)	;save
		move.b	(a0)+,pd_SBKeyVal(a1)	;get value
		move.b	(a0)+,pd_SBKeyMsk(a1)	;and mask
		
		rts



