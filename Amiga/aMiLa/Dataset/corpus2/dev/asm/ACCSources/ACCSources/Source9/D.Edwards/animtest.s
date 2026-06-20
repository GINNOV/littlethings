

		include	source9:include/hardware.i


* Some equates


BP_WIDE		equ	320
BP_TALL		equ	256
BP_SIZE		equ	BP_WIDE*BP_TALL
BP_BYTEWIDE	equ	BP_WIDE/8
BP_BYTES		equ	BP_SIZE/8
BP_CLEARSIZE	equ	BP_TALL*64+BP_BYTEWIDE/2

LOCK_REPLACE	equ	0	;animation lock:replace backgrounds
LOCK_SAVE	equ	1	;animation lock:save new backgrounds
LOCK_PLOT	equ	2	;animation lock:plot the graphics
LOCK_DISABLE	equ	3	;animation lock:do nothing

my_dma		equ	SETIT+DMAEN+BPLEN+COPEN+BLTEN
my_int		equ	SETIT+INTEN+BLIT+VERTB+COPER+PORTS


* Some structure definitions


		rsreset
anim_next	rs.l	1	;ptr to next anim struct
anim_scrn	rs.l	1	;ptr to screen area
anim_bob		rs.l	1	;ptr to bob struct array
anim_bgnd	rs.l	1	;ptr to background save area

anim_x		rs.w	1	;coordinates
anim_y		rs.w	1

anim_fnum	rs.w	1	;frame number
anim_fmax	rs.w	1	;max frame no

anim_dir		rs.w	1	;anim dir + or - 1

anim_sizeof	rs.w	0


		rsreset
bob_image	rs.l	1	;ptr to graphic data
bob_mask		rs.l	1	;ptr to mask if needed

bob_width	rs.w	1	;size of bob
bob_height	rs.w	1
bob_planes	rs.w	1	;no of bitplanes

bob_xoff		rs.w	1	;x & y offsets for this frame
bob_yoff		rs.w	1

bob_soff		rs.l	1	;bob screen offset

bob_bcon0	rs.w	1	;all of these entries
bob_bcon1	rs.w	1	;pre-initialised for
bob_fwm		rs.w	1	;the interrupt blitter
bob_lwm		rs.w	1	;routine

bob_cptr		rs.l	1
bob_bptr		rs.l	1
bob_aptr		rs.l	1
bob_dptr		rs.l	1

bob_cmod		rs.w	1
bob_bmod		rs.w	1
bob_amod		rs.w	1
bob_dmod		rs.w	1

bob_bsize	rs.w	1

bob_sizeof	rs.w	0


		section	x1,code_c


		include	source9:include/hardstart.i

		lea	stacktop,a7		;MY stack!


* Clear interrupt vectors


		lea	null_vector(pc),a0
		lea	$64,a1
		moveq	#7,d0
blastints	move.l	a0,(a1)+
		subq.l	#1,d0
		bne.s	blastints


* Set up interrupt handlers


		lea	Int3_Handler(pc),a0
		move.l	a0,$6C
		lea	Int2_Handler(pc),a0
		move.l	a0,$68


* Set up Trace Handler


		lea	Trace_Handler(pc),a0
		move.l	a0,$24


* Set up bitplane control


		move.w	#$2981,DIWSTRT(a5)
		move.w	#$29C1,DIWSTOP(a5)

		move.w	#$38,DDFSTRT(a5)
		move.w	#$D0,DDFSTOP(a5)

		move.w	#$4200,BPLCON0(a5)	;16-colour low-res
		move.w	#0,BPLCON1(a5)
		move.w	#0,BPLCON2(a5)
		move.w	#0,BPL1MOD(a5)
		move.w	#0,BPL2MOD(a5)


* Set colours


		lea	colours,a0
		lea	COLOR00(a5),a1
		moveq	#16,d0

setcolours	move.w	(a0)+,(a1)+
		subq.w	#1,d0
		bne.s	setcolours


* Set up 320*256 4-bitplane screen copper list


		lea	copperlist,a0
		move.l	a0,d0

		lea	display,a1
		move.l	a1,d1		;screen start addr

		move.w	#BPL1PTH,(a0)+
		swap	d1
		move.w	d1,(a0)+
		swap	d1
		move.w	#BPL1PTL,(a0)+
		move.w	d1,(a0)+
		add.l	#BP_BYTES,d1

		move.w	#BPL2PTH,(a0)+
		swap	d1
		move.w	d1,(a0)+
		swap	d1
		move.w	#BPL2PTL,(a0)+
		move.w	d1,(a0)+
		add.l	#BP_BYTES,d1

		move.w	#BPL3PTH,(a0)+
		swap	d1
		move.w	d1,(a0)+
		swap	d1
		move.w	#BPL3PTL,(a0)+
		move.w	d1,(a0)+
		add.l	#BP_BYTES,d1

		move.w	#BPL4PTH,(a0)+
		swap	d1
		move.w	d1,(a0)+
		swap	d1
		move.w	#BPL4PTL,(a0)+
		move.w	d1,(a0)+
		add.l	#BP_BYTES,d1

		move.l	#$FFFFFFFE,(a0)	;end of copper list

		move.w	#LOCK_DISABLE,AnimLock	;kill animation

		move.w	#my_dma,DMACON(a5)	;turn on DMA
		move.w	#my_int,INTENA(a5)	;and interrupts

		move.w	#$2100,SR	;and let 68000 see them

		move.b	#$88,CIAAICR	;and enable Int2 kbrd handler
		move.b	#$20,CIAACRA

		move.l	d0,COP1LCH(a5)
		move.w	#0,COPJMP1(a5)	;start it up!


* Clear bitplanes


		lea	display,a0


* This is blitter code for clearing the screen


wb0		btst	#6,DMACONR(a5)
		bne.s	wb0

		move.w	#0,BLTADAT(a5)
		moveq	#-1,d0
		move.l	d0,BLTAFWM(a5)
		move.l	a0,BLTDPTH(a5)
		move.w	#$01F0,BLTCON0(a5)	;USED,D=A
		move.w	#0,BLTCON1(a5)
		move.w	#0,BLTDMOD(a5)
		move.w	#BP_CLEARSIZE,BLTSIZE(a5)

wb1		btst	#6,DMACONR(a5)
		bne.s	wb1

		add.l	#BP_BYTES,a0

		move.w	#0,BLTADAT(a5)
		moveq	#-1,d0
		move.l	d0,BLTAFWM(a5)
		move.l	a0,BLTDPTH(a5)
		move.w	#$01F0,BLTCON0(a5)	;USED,D=A
		move.w	#0,BLTCON1(a5)
		move.w	#0,BLTDMOD(a5)
		move.w	#BP_CLEARSIZE,BLTSIZE(a5)

wb2		btst	#6,DMACONR(a5)
		bne.s	wb2

		add.l	#BP_BYTES,a0

		move.w	#0,BLTADAT(a5)
		moveq	#-1,d0
		move.l	d0,BLTAFWM(a5)
		move.l	a0,BLTDPTH(a5)
		move.w	#$01F0,BLTCON0(a5)	;USED,D=A
		move.w	#0,BLTCON1(a5)
		move.w	#0,BLTDMOD(a5)
		move.w	#BP_CLEARSIZE,BLTSIZE(a5)

wb3		btst	#6,DMACONR(a5)
		bne.s	wb3

		add.l	#BP_BYTES,a0

		move.w	#0,BLTADAT(a5)
		moveq	#-1,d0
		move.l	d0,BLTAFWM(a5)
		move.l	a0,BLTDPTH(a5)
		move.w	#$01F0,BLTCON0(a5)	;USED,D=A
		move.w	#0,BLTCON1(a5)
		move.w	#0,BLTDMOD(a5)
		move.w	#BP_CLEARSIZE,BLTSIZE(a5)

wb4		btst	#6,DMACONR(a5)
		bne.s	wb4


;		lea	ta_1(pc),a0
		lea	ta_1,a0
		lea	display,a1
		move.l	a1,d0
		bsr	InitAnims	;set up animation structs

;		lea	ta_1,a0
;		bsr	InitBgnds	;initialise backgrounds

		bsr	WaitVBL

		lea	ta_1,a0
		move.l	a0,IntPtr
		move.l	a0,IntStart
		move.l	anim_bob(a0),WhichFrame
		move.w	#0,WhichPlane
		move.w	#LOCK_SAVE,AnimLock	;initalise animations
		move.w	#SETIT+BLIT,INTREQ(a5)	;& set them off!

;		lea	ta_1,a0
;		move.l	a0,IntStart
;		move.l	a0,IntPtr
;		move.l	anim_bob(a0),WhichFrame
;		move.w	#0,WhichPlane
;		move.w	#LOCK_SAVE,AnimLock

hang		nop

;		bsr	ClearTrace

;wm1		btst	#6,CIAAPRA	;wait for mouse button
;		bne.s	wm1
;wm2		btst	#6,CIAAPRA
;		beq.s	wm2

		moveq	#0,d0
		move.w	AnimLock,d0
		moveq	#16,d1
		moveq	#10,d2
		bsr	showd0

		move.l	IntPtr,d0
		moveq	#16,d1
		moveq	#20,d2
		bsr	showd0

		move.l	WhichFrame,d0
		moveq	#16,d1
		moveq	#30,d2
		bsr	showd0

		moveq	#0,d0
		move.w	WhichPlane,d0
		moveq	#16,d1
		moveq	#40,d2
		bsr	showd0

;		lea	IntBlitRep(pc),a0
;		move.l	a0,d0
;		moveq	#16,d1
;		moveq	#50,d2
;		bsr	showd0

;		lea	IntBlitSave(pc),a0
;		move.l	a0,d0
;		moveq	#16,d1
;		moveq	#60,d2
;		bsr	showd0

;		lea	IntBlitAnim(pc),a0
;		move.l	a0,d0
;		moveq	#16,d1
;		moveq	#70,d2
;		bsr	showd0

		moveq	#0,d0
		move.b	ShiftKey,d0
		lsl.w	#8,d0
		move.b	OrdKey,d0
		moveq	#16,d1
		moveq	#80,d2
		bsr	showd0

;		bsr	SetTrace

;		move.w	AnimLock,d0
;		cmp.w	#LOCK_REPLACE,d0
;		bne.s	tst1

;		move.w	#$700,COLOR00(a5)
;		bsr	IntBlitRep
;		bra	hang

;tst1		cmp.w	#LOCK_SAVE,d0
;		bne.s	tst2

;		move.w	#$070,COLOR00(a5)
;		bsr	IntBlitSave
;		bra	hang

;tst2		cmp.w	#LOCK_PLOT,d0
;		bne.s	tst3

;		move.w	#$077,COLOR00(a5)
;		bsr	IntBlitAnim
;		bra	hang

;tst3		bsr	WaitVBL
;		move.w	#LOCK_REPLACE,AnimLock
;		move.w	#0,COLOR00(a5)

;		lea	ta_1,a0
;		move.l	a0,IntStart
;		move.l	a0,IntPtr
;		move.l	anim_bob(a0),WhichFrame
;		move.w	#0,WhichPlane

		bra	hang

		rts


* InitAnims(a0,d0)
* a0 = ptr to 1st anim struct in list
* d0 = ptr to screen to use
* initialises anim structs and their
* respective bob frames.

* DOES NOT PRE-SAVE BACKGROUNDS!

* d0-d3/d6-d7/a0-a2 corrupt


InitAnims	move.l	a0,d7		;check if pointer exists
		beq	IA_exit		;if not, exit NOW.

		move.l	d0,anim_scrn(a0)

		move.l	anim_bob(a0),a1	;get bob pointer
		move.w	anim_fmax(a0),d6	;no of animation frames
		move.w	anim_x(a0),d0	;x & y coords
		move.w	anim_y(a0),d1

		bra.s	InitA_a1

* In this loop, pre-compute blitter register values and save them
* in workspace areas provided for the purpose.

InitA_l1		lea	bob_bcon0(a1),a2	;ptr to blitter precomps
		move.w	d0,d2		;x value
		add.w	bob_xoff(a1),d2	;corrected for this frame
		move.w	d2,d3		;copy for later
		and.w	#$F,d2		;x mod 16
		ror.w	#4,d2		;position correctly
;		or.w	#$FCA,d2
		or.w	#$FE2,d2
		move.w	d2,(a2)+		;write BLTCON0
		and.w	#$F000,d2
		move.w	d2,(a2)+		;write BLTCON1

		moveq	#-1,d2
		clr.w	d2		;BLTALWM zero:Laurence Part 1
		move.l	d2,(a2)+		;write masks

		move.w	d1,d2		;get y value
		add.w	bob_yoff(a1),d2	;corrcted for this frame
		mulu	#BP_BYTEWIDE,d2
		ext.l	d3
		asr.l	#4,d3
		add.l	d3,d3		;2*int(x/16)
		add.l	d3,d2
		move.l	d2,bob_soff(a1)	;create word offset into screen

		move.l	anim_scrn(a0),d2
		move.l	d2,(a2)+		;create initial CPTH/L
		move.l	bob_mask(a1),d3
		move.l	bob_image(a1),d4
		move.l	d3,(a2)+		;and BPTH/L
		move.l	d4,(a2)+		;and APTH/L
		move.l	d2,(a2)+		;and DPTH/L

		move.w	bob_width(a1),d2	;width in WORDS!

		move.w	d2,d3
		addq.w	#1,d3		;word cols+1:Laurence Pt 3
		add.w	d3,d3		;width in BYTES
		neg.w	d3
		add.w	#BP_BYTEWIDE,d3
		move.w	d3,(a2)+		;create C modulo
		move.w	#-2,(a2)+	;B modulo -2:Laurence Part 2
		move.w	#-2,(a2)+	;A modulo -2:Laurence Part 2
		move.w	d3,(a2)+		;A modulo

		move.w	bob_height(a1),d3
		lsl.w	#6,d3
		addq.w	#1,d2		;word cols+1:Laurence Pt 3
		add.w	d3,d2
		move.w	d2,(a2)+		;create BLTSIZE

		move.l	a2,a1		;next bob structure in array

InitA_a1		dbra	d6,InitA_l1	;do this many

		move.l	anim_scrn(a0),d0	;get screen ptr
		move.l	anim_next(a0),a0	;get next animation structure
		bra	InitAnims

IA_exit		rts


* InitBgnds(a0)
* a0 = ptr to 1st animation structure in list
* Saves backgrounds.

* d0-d7/a0-a1 corrupt


InitBgnds	move.l	a0,d7		;pointer exists?
		beq.s	InitB_exit	;no-exit NOW

		move.l	anim_bob(a0),a1	;get bob array pointer

		move.l	anim_bgnd(a0),d0	;this is source D

		move.l	anim_scrn(a0),d1
		add.l	bob_soff(a1),d1	;this is source A

		move.w	anim_x(a0),d2
		add.w	bob_xoff(a1),d2
		and.w	#$F,d2
		ror.w	#4,d2
		move.w	d2,d3		;this is BLTCON1
		or.w	#$9F0,d2		;this is BLTCON0
		moveq	#-1,d4		;this is BLTAFWM
		move.w	bob_width(a1),d5
		add.w	d5,d5
		neg.w	d5
		add.w	#BP_BYTEWIDE,d5	;this is BLTAMOD

		move.l	d0,BLTDPTH(a5)
		move.l	d1,BLTAPTH(a5)
		move.w	d2,BLTCON0(a5)
		move.w	d3,BLTCON1(a5)
		move.l	d4,BLTAFWM(a5)
		move.w	d5,BLTAMOD(a5)
		move.w	#0,BLTDMOD(a5)
		move.w	bob_bsize(a1),BLTSIZE(a5)

InitB_w1		btst	#6,DMACONR(a5)	;busy wait for blitter
		bne.s	InitB_w1

		move.l	anim_next(a0),a0	;ptr to next Animation
		bra.s	InitBgnds		

InitB_exit	rts


* Trace_Handler()
* Handle a trace exception
* My own debugging routine!

Trace_Handler	movem.l	d0-d7/a0-a7,TraceRegs
		move.w	SR,TraceStat
;		move.w	#$2700,SR	;prevent ints

		move.l	2(sp),TracePC

		bsr	ShowRegs

;Trace_W1		btst	#6,CIAAPRA	;wait for mouse press
;		bne.s	Trace_W1
;Trace_W2		btst	#6,CIAAPRA
;		beq.s	Trace_W1

Trace_W1		move.b	OrdKey,d0
		cmp.b	#$45,d0		;ESC?
		bne.s	Trace_W1		;no
Trace_W2		move.b	OrdKey,d0	;ESC released?
		cmp.b	#$FF,d0
		bne.s	Trace_W2		;no

		tst.w	Tron		;continuing trace?
		bne.s	Trace_B1		;yes

		move.w	(sp),d0		;get actual SR saved
		bclr	#15,d0		;clr trace bit
		move.w	d0,(sp)		;save back

Trace_B1		movem.l	TraceRegs,d0-d7/a0-a7
		rte


* ShowRegs()
* d0-d2/a6 corrupt

ShowRegs		lea	TraceRegs,a6	;where saved regs are

		moveq	#8,d7		;show 1st 8 (d0-d7)
		moveq	#2,d1
		move.w	#170,d2

Trace_L1		move.l	(a6)+,d0		;get reg
		bsr	showd0		;display it
		add.w	#10,d2		;next display pos
		subq.w	#1,d7
		bne.s	Trace_L1

		moveq	#12,d1
		move.w	#170,d2
		moveq	#8,d7		;show 2nd 8 (a0-a7)

Trace_L2		move.l	(a6)+,d0		;get reg
		bsr	showd0		;show it
		add.w	#10,d2		;next display pos
		subq.w	#1,d7
		bne.s	Trace_L2

		move.l	(a6)+,d0		;get PC
		moveq	#22,d1
		move.w	#170,d2
		bsr	showd0		;show it
		add.w	#10,d2		;next display pos

		move.w	(a6)+,d0		;get SR
		add.w	#10,d2
		bsr	showd0		;display it

		rts


* SetTrace()

SetTrace		move.w	#-1,Tron
		or.w	#$8000,SR
		rts


* ClearTrace()

ClearTrace	clr.w	Tron
		rts


* Int2_Handler()
* Handle Level 2 interrupt (CIA-A)
* Get key value etc


Int2_Handler	movem.l	d0-d5,-(sp)

		move.w	#$2700,SR	;prevent interrupt nesting

		move.w	INTREQR(a5),d0
		bclr	#15,d0		;ensure IRQ acknowledge
		bclr	#3,d0		;of CIA interrupt
		move.w	d0,INTREQ(a5)	;and tell 4703 about it

		move.b	CIAAICR,d1	;check CIA source
		bclr	#7,d1

		addq.l	#1,CIACounter	;one of many counters...

		move.b	CIAASP,d2	;get key press
		or.b	#$40,CIAACRA	;pull KCLK low (SPMODE output)

		not.b	d2
		ror.b	#1,d2		;get correct key code

		move.b	d2,d3		;copy key code
		bclr	#7,d3		;clear keyup bit of copy
		cmp.b	#$60,d3		;is it a shift-type key?
		bcc.s	Int2_3		;yes

		tst.b	d2		;key up?
		bmi.s	Int2_4		;yes
		move.b	d3,OrdKey	;else save ordinary key
		bra.s	Int2_2		;and exit Int2

Int2_4		st	OrdKey		;keyup so 'clear' it
;		clr.b	ShiftKey		;and the shifts??
		bra.s	Int2_2		;and exit Int2

Int2_3		moveq	#0,d4		;shift key state to record
		move.b	ShiftKey,d5	;shifts already gotten
		sub.b	#$60,d3		;get shift bit no
		bset	d3,d4		;& set the shift bit

		tst.b	d2		;is it keyup?
		bmi.s	Int2_5		;yes
		or.b	d4,d5		;else add a new one
		move.b	d5,ShiftKey	;and set it
		bra.s	Int2_2		;and exit Int2

Int2_5		not.b	d4		;subtract a shift state
		and.b	d4,d5
		move.b	d5,ShiftKey	;signal new shift state

Int2_2		nop

		moveq	#4,d2		;wait for 75 microsecs
Int2_6		subq.w	#1,d2
		bne.s	Int2_6

		and.b	#$BF,CIAACRA	;SPMODE=input again

Int2_1		movem.l	(sp)+,d0-d5
		rte


* Int3_Handler()
* Handle Level 3 Interrupt
* a5 MUST point to custom chips!

* Note:blitter animation code handled via interrupts. Relies upon a
* variable AnimLock.W to determine which animation phase is currently
* on line. States are:

* LOCK_REPLACE	: cause Int3 to replace saved backgrounds
* LOCK_SAVE	: cause Int3 to save new backgrounds after movement
* LOCK_PLOT	: cause Int3 to plot graphics
* LOCK_DISABLE	: Int3 does nothing.


Int3_Handler	movem.l	d0-d7/a0-a2,-(sp)	;save these

		move.w	#$2700,SR	;prevent interrupt nesting

		move.w	INTREQR(a5),d0	;check which int occurred
		bclr	#15,d0		;signal IRQ acknowledge
		move.w	d0,INTREQ(a5)	;and tell 4703 about it

		btst	#6,d0		;Blitter?
		beq.s	Int3_1		;no

		addq.l	#1,BlitCounter	;add to blitter counter

		move.w	d0,-(sp)		;save INTREQ value

		move.w	AnimLock,d0	;get lock. Lock=replace?
		cmp.w	#LOCK_REPLACE,d0
		bne.s	Int3_Replaced	;skip if not

		bsr	IntBlitRep	;else do the replace
;		move.w	#$C00,COLOR00(a5)	;& signal it
		bra.s	Int3_Plotted

Int3_Replaced	cmp.w	#LOCK_SAVE,d0	;lock=save?
		bne.s	Int3_Saved	;skip if not

		bsr	IntBlitSave	;else do the save
;		move.w	#$080,COLOR00(a5)
		bra.s	Int3_Plotted

Int3_Saved	cmp.w	#LOCK_PLOT,d0	;lock=plot?
		bne.s	Int3_Plotted	;skip if not

		bsr	IntBlitAnim	;else do the plot
		move.w	#$06C,COLOR00(a5)

Int3_Plotted	move.w	(sp)+,d0

Int3_1		btst	#5,d0		;VBL?
		beq.s	Int3_2		;no

		move.w	#0,COLOR00(a5)

		addq.l	#1,VBLCounter	;add to VBL counter

		move.w	#LOCK_REPLACE,AnimLock

		move.w	#SETIT+BLIT,INTREQ(a5)

Int3_2		btst	#4,d0		;Copper?
		beq.s	Int3_3		;no

		addq.l	#1,CopCounter	;add to Copper counter

Int3_3		movem.l	(sp)+,d0-d7/a0-a2
		rte


* WaitVBL()
* Wait for VBL to pass by
* d0 corrupt

WaitVBL		move.l	VBLCounter,d0
WaitVBL_1	cmp.w	VBLCounter,d0
		beq.s	WaitVBL_1
		rts


* IntBlitAnim()
* blast graphic onto screen during blitter interrupt.

* This routine to be called by blitter interrupt routine
* once all bgnd blocks saved.

* NOTE:Uses Laurence trick. A/B Moduli -2, word cols + 1
* in BLTSIZE, BLTALWM zero.

* d0-d5/a0-a2 corrupt


IntBlitAnim	move.l	IntPtr,d0	;get current Anim
		bne.s	IBA_1		;it's ok
		rts			;else return

IBA_1		move.l	d0,a0
		move.l	WhichFrame,a1	;get frame ptr

		movem.w	bob_bcon0(a1),d0-d3
		movem.w	d0-d3,BLTCON0(a5)

		movem.l	bob_cptr(a1),d0-d3	;get pointers
		move.w	WhichPlane,d4
		mulu	#BP_BYTES,d4
		add.l	d4,d0			;correct screen
		add.l	d4,d3			;ptr for bitplane
		move.w	WhichPlane,d4
		move.w	bob_width(a1),d5		;this is WORDS!
		mulu	bob_height(a1),d5		
		add.l	d5,d5			;point to correct
		mulu	d5,d4			;image bitplane
		add.l	d4,d2
		add.l	bob_soff(a1),d0
		add.l	bob_soff(a1),d3
		movem.l	d0-d3,BLTCPTH(a5)

		movem.w	bob_cmod(a1),d0-d3
		movem.w	d0-d3,BLTCMOD(a5)

		move.w	bob_bsize(a1),BLTSIZE(a5)	;start blitter

		move.w	WhichPlane,d4		;check plane counter
		addq.w	#1,d4			;next plane
		cmp.w	bob_planes(a1),d4		;last one?
		bne.s	IBA_2			;no

* Here last bitplane of this animation, this frame.
* Now set up pointers for next animation.

		move.l	anim_next(a0),d0		;check next animation
		bne.s	IBA_3			;skip if it exists
		move.l	IntStart,d0		;else reset to 1st
		move.w	#LOCK_DISABLE,AnimLock	;and lock=do nothing

IBA_3		move.l	d0,a0			;this is IntPtr
		move.l	anim_bob(a0),a1
		move.w	anim_fnum(a0),d0
		mulu	#bob_sizeof,d0
		add.l	d0,a1			;this is WhichFrame

		move.l	a0,IntPtr
		move.l	a1,WhichFrame
		move.w	#0,WhichPlane

		rts

* Here not last bitplane, so point to next bitplane
* of this animation frame, and end this interrupt response.

IBA_2		move.w	d4,WhichPlane
		rts


* IntBlitRep()
* Replace backgrounds under interrupt control

* NOTE:Uses Laurence trick. A/ Modulo -2, word cols + 1
* in BLTSIZE, BLTALWM zero.

* d0-d5/a0-a2 corrupt


IntBlitRep	move.l	IntPtr,d0	;get animation ptr
		bne.s	IBR_1		;ptr ok so do it
		rts

IBR_1		move.l	d0,a0
		move.l	WhichFrame,a1
		move.l	anim_scrn(a0),a2
		add.l	bob_soff(a1),a2	;this is BLTDPTH/L
		move.w	WhichPlane,d0
		mulu	#BP_BYTES,d0
		add.l	d0,a2
		move.w	bob_width(a1),d0	;this is WORDS!
		move.w	d0,d2
		mulu	bob_height(a1),d0
		add.l	d0,d0		;this is BYTES!
		move.w	WhichPlane,d1
		mulu	d1,d0
		add.l	anim_bgnd(a0),d0	;this is BLTAPTH/L
		addq.w	#1,d2		;word cols +1 :Laurence Pt 3
		add.w	d2,d2
		neg.w	d2
		add.w	#BP_BYTEWIDE,d2	;this is BLTDMOD
		move.w	anim_x(a0),d1
		add.w	bob_xoff(a1),d1
		and.w	#$F,d1
		ror.w	#4,d1
		or.w	#$9F0,d1		;this is BLTCON0
		moveq	#-2,d3		;this is BLTAMOD
		moveq	#-1,d4		;this is BLTAFWM
		clr.w	d4		;Laurence Trick!
		move.w	bob_bsize(a1),d5

* Now replace background

		move.l	a2,BLTDPTH(a5)
		move.l	d0,BLTAPTH(a5)
		move.w	d2,BLTDMOD(a5)
		move.w	d3,BLTAMOD(a5)
		move.w	d1,BLTCON0(a5)
		move.w	#0,BLTCON1(a5)
		move.l	d4,BLTAFWM(a5)
		move.w	d5,BLTSIZE(a5)	;start blitter

* Now check if last bitplane of bgnd replaced

		move.w	WhichPlane,d0
		addq.w	#1,d0
		cmp.w	bob_planes(a1),d0
		bne.s	IBR_2

* Here it is, so update pointers to point to next animation.
* Also, update pointers for THIS animation to point to the
* next frame.

		move.w	anim_fnum(a0),d0		;current frame
		move.w	anim_dir(a0),d1		;move on to next one
		add.w	d1,d0
		bpl.s	IBR_3			;skip if in bounds
		move.w	anim_fmax(a0),d0
		add.w	d1,d0			;else reset counter
		bra.s	IBR_4

IBR_3		cmp.w	anim_fmax(a0),d0
		bcs.s	IBR_4			;skip if in bounds
		moveq	#0,d0			;else reset counter

IBR_4		move.w	d0,anim_fnum(a0)

		move.l	anim_next(a0),d0		;check next animation
		bne.s	IBR_5			;skip if it exists
		move.l	IntStart,d0		;else reset to 1st
		move.w	#LOCK_SAVE,AnimLock	;and lock=save

IBR_5		move.l	d0,a0
		move.l	anim_bob(a0),a1
		move.w	anim_fnum(a0),d0
		mulu	#bob_sizeof,d0
		add.l	d0,a1			;this is WhichFrame

		move.l	a0,IntPtr
		move.l	a1,WhichFrame
		move.w	#0,WhichPlane

		rts

* Here not last bitplane of bgnd replaced, so update
* bitplane counter

IBR_2		move.w	d0,WhichPlane
		rts


* IntBlitSave()
* Save backgrounds under interrupt control

* NOTE:Uses Laurence trick. A/B Moduli -2, word cols + 1
* in BLTSIZE, BLTALWM zero.

* d0-d5/a0-a2 corrupt


IntBlitSave	move.l	IntPtr,d0	;get animation ptr
		bne.s	IBS_1		;ptr ok so do it
		rts

IBS_1		move.l	d0,a0
		move.l	WhichFrame,a1
		move.l	anim_scrn(a0),a2
		add.l	bob_soff(a1),a2	;this is BLTAPTH/L
		move.w	WhichPlane,d0
		mulu	#BP_BYTES,d0
		add.l	d0,a2
		move.w	bob_width(a1),d0	;this is WORDS!
		move.w	d0,d2
		mulu	bob_height(a1),d0
		add.l	d0,d0		;this is BYTES!
		move.w	WhichPlane,d1
		mulu	d1,d0
		add.l	anim_bgnd(a0),d0	;this is BLTDPTH/L
		addq.w	#1,d2		;word cols +1 :Laurence Pt 3
		add.w	d2,d2
		neg.w	d2
		add.w	#BP_BYTEWIDE,d2	;this is BLTAMOD
		move.w	anim_x(a0),d1
		add.w	bob_xoff(a1),d1
		and.w	#$F,d1
		ror.w	#4,d1
		or.w	#$9F0,d1		;this is BLTCON0
		moveq	#-2,d3		;this is BLTDMOD
		moveq	#-1,d4		;this is BLTAFWM
		clr.w	d4		;Laurence Pt 2
		move.w	bob_bsize(a1),d5

* Now save background

		move.l	d0,BLTDPTH(a5)
		move.l	a2,BLTAPTH(a5)
		move.w	d3,BLTDMOD(a5)
		move.w	d2,BLTAMOD(a5)
		move.w	d1,BLTCON0(a5)
		move.w	#0,BLTCON1(a5)
		move.l	d4,BLTAFWM(a5)
		move.w	d5,BLTSIZE(a5)	;start blitter

* Now check if last bitplane of bgnd saved

		move.w	WhichPlane,d0
		addq.w	#1,d0
		cmp.w	bob_planes(a1),d0
		bne.s	IBS_2

* Here it is, so update pointers to point to next animation.

		move.l	anim_next(a0),d0		;check next animation
		bne.s	IBS_3			;skip if it exists
		move.l	IntStart,d0		;else reset to 1st
		move.w	#LOCK_PLOT,AnimLock	;and lock=plot

IBS_3		move.l	d0,a0			;this is IntPtr
		move.l	anim_bob(a0),a1
		move.w	anim_fnum(a0),d0
		mulu	#bob_sizeof,d0
		add.l	d0,a1			;this is WhichFrame

		move.l	a0,IntPtr
		move.l	a1,WhichFrame
		move.w	#0,WhichPlane

		rts

* Here not last bitplane of bgnd saved, so update
* bitplane counter

IBS_2		move.w	d0,WhichPlane
		rts


* showd0(d0,d1,d2)
* d0 = value to show
* d1 = x pos
* d2 = y pos

* all regs preserved

showd0		movem.l	d0-d2/d6/d7/a0/a1,-(sp)
		lea	display,a0
		mulu	#BP_BYTEWIDE,d2
		add.l	d2,a0
		add.w	d1,a0		;where to start plotting chars
			
		moveq	#8,d7		;8 chars per longword
		bra.s	showd0_a

showd0_l		moveq	#0,d6		;clear digit
		rol.l	#4,d0		;get digits in sequence
		move.b	d0,d6
		and.b	#%1111,d6	;ensure range 0-F hex
		lsl.w	#3,d6		;as index into char table
		lea	chars,a1
		add.w	d6,a1		;get char bit pattern ptr
		move.b	(a1)+,(a0)	;put char on screen
		move.b	(a1)+,40(a0)
		move.b	(a1)+,80(a0)
		move.b	(a1)+,120(a0)
		move.b	(a1)+,160(a0)
		move.b	(a1)+,200(a0)
		move.b	(a1)+,240(a0)
		move.b	(a1)+,280(a0)
		addq.l	#1,a0		;next char position along

showd0_a		dbra	d7,showd0_l

		movem.l	(sp)+,d0-d2/d6/d7/a0/a1
		rts


* Lifetime's supply of Webster's Bitter free!!! Phone:

* 0700 636 102 93 280 701 262 429212


		section	x2,data_c


IntStart		dc.l	0
IntPtr		dc.l	0
WhichFrame	dc.l	0
WhichPlane	dc.w	0
AnimLock		dc.w	0

ShiftKey		dc.b	0
OrdKey		dc.b	0

VBLCounter	dc.l	0
CopCounter	dc.l	0
BlitCounter	dc.l	0

CIACounter	dc.l	0

TraceRegs	dc.l	0,0,0,0,0,0,0,0
		dc.l	0,0,0,0,0,0,0,0

TracePC		dc.l	0

TraceStat	dc.w	0

Tron		dc.w	0


colours		dc.w	$000,$FFF,$F00,$0F0
		dc.w	$00F,$FF0,$F0F,$0FF
		dc.w	$444,$777,$700,$070
		dc.w	$007,$770,$707,$077



ta_1		dc.l	ta_2		;no more anims
		dc.l	0		;scrn ptr
		dc.l	ta1_bob1		;ptr to bob
		dc.l	savebuf		;ptr to bgnd save area
		dc.w	48,60		;x & y coords
		dc.w	0,3		;frames
		dc.w	1		;dir

ta_2		dc.l	0		;no more anims
		dc.l	0		;scrn ptr
		dc.l	ta2_bob1		;ptr to bob
		dc.l	savebuf+64	;ptr to background save area
		dc.w	80,100		;x & y coords
		dc.w	0,1		;frames
		dc.w	1		;dir


ta1_bob1		dc.l	ta1_img1		;image
		dc.l	ta1_msk1		;mask
		dc.w	1,8		;width, height
		dc.w	4		;bitplanes
		dc.w	0,0		;anim offsets

		dc.l	0		;precomputed
		dc.w	0,0,0,0		;blitter
		dc.l	0,0,0,0		;values
		dc.w	0,0,0,0
		dc.w	0

ta1_bob2		dc.l	ta1_img2		;image
		dc.l	ta1_msk2		;mask
		dc.w	1,8		;width, height
		dc.w	4		;bitplanes
		dc.w	-2,10		;anim offsets

		dc.l	0		;precomputed
		dc.w	0,0,0,0		;blitter
		dc.l	0,0,0,0		;values
		dc.w	0,0,0,0
		dc.w	0

ta1_bob3		dc.l	ta1_img3		;image
		dc.l	ta1_msk3		;mask
		dc.w	1,8		;width, height
		dc.w	4		;bitplanes
		dc.w	-4,20		;anim offsets

		dc.l	0		;precomputed
		dc.w	0,0,0,0		;blitter
		dc.l	0,0,0,0		;values
		dc.w	0,0,0,0
		dc.w	0


ta2_bob1		dc.l	ta1_img2		;image
		dc.l	ta1_msk2		;mask
		dc.w	1,8		;width, height
		dc.w	1		;bitplanes
		dc.w	0,0		;anim offsets

		dc.l	0		;precomputed
		dc.w	0,0,0,0		;blitter
		dc.l	0,0,0,0		;values
		dc.w	0,0,0,0
		dc.w	0


ta1_img1		dc.w	%0000000000000000
		dc.w	%0001100000011000
		dc.w	%0000011001100000
		dc.w	%0000000110000000
		dc.w	%0000000110000000
		dc.w	%0000011001100000
		dc.w	%0001100000011000
		dc.w	%0000000000000000

		dc.w	%0000000000000000
		dc.w	%0001100000011000
		dc.w	%0000011001100000
		dc.w	%0000000110000000
		dc.w	%0000000110000000
		dc.w	%0000011001100000
		dc.w	%0001100000011000
		dc.w	%0000000000000000

		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000

		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000


ta1_img2		dc.w	%0000000000000000
		dc.w	%0000000110000000
		dc.w	%0000000110000000
		dc.w	%0000111111110000
		dc.w	%0000111111110000
		dc.w	%0000000110000000
		dc.w	%0000000110000000
		dc.w	%0000000000000000

		dc.w	%0000000000000000
		dc.w	%0000000110000000
		dc.w	%0000000110000000
		dc.w	%0000111111110000
		dc.w	%0000111111110000
		dc.w	%0000000110000000
		dc.w	%0000000110000000
		dc.w	%0000000000000000

		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000

		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000

ta1_img3		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000

		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000

		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000

		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000


ta1_msk1		dc.w	%0000000000000000
		dc.w	%0001100000011000
		dc.w	%0000011001100000
		dc.w	%0000000110000000
		dc.w	%0000000110000000
		dc.w	%0000011001100000
		dc.w	%0001100000011000
		dc.w	%0000000000000000

ta1_msk2		dc.w	%0000000000000000
		dc.w	%0000000110000000
		dc.w	%0000000110000000
		dc.w	%0000111111110000
		dc.w	%0000111111110000
		dc.w	%0000000110000000
		dc.w	%0000000110000000
		dc.w	%0000000000000000

ta1_msk3		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000
		dc.w	%0000000000000000



chars		dc.b	%00000000
		dc.b	%00111100
		dc.b	%01000010
		dc.b	%01000010
		dc.b	%01000010
		dc.b	%01000010
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


		section	x3,bss_c

copperlist	ds.l	32

display		ds.b	BP_BYTES*4

savebuf		ds.b	32768

stackbot		ds.l	1024
stacktop		equ	*



