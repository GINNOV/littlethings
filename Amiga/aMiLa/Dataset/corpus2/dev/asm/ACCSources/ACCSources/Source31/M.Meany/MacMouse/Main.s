
; Mouse Control			mouse controlled bob

;				Displays a 3 bitplane bob, with background
;				preservation.

		incdir		ACC31:Include/
		include		hardware.i
		include		HW_Macros.i
		include		HW_Start.i
		include		HW_Input.i

; First, 'poke' address of bit plane into Copper list

Main		COPBPLC		CopPlanes,Screen,(320/8)*256,3

; Enable bitplane, Copper and Blitter DMA.

		move.w		#SETIT!DMAEN!COPEN!BPLEN!BLTEN,DMACON(a5)

; Install vert blank interrupt handler and enable it

		move.l		#Level3,$6c
		move.w		#SETIT!INTEN!VERTB,INTENA(a5)

; Now strobe the Copper list.

		move.l		#MyCopper,COP1LCH(a5)	address of list
		move.w		#0,COPJMP1(a5)		strobe Copper

; Wait for user to press the left mouse button

mouse		btst		#6,CIAAPRA
		bne.s		mouse

; And exit.

		rts

;		***************************
;		*     Level 3 Interrupt	  *
;		***************************

Level3		lea		$dff000,a5		a5->hardware regs

		bsr		BlitBob

		bsr		TestMouse

		subq.w		#1,VBLCount
		bne.s		NoImChange
		move.w		#5,VBLCount

		move.l		d6,d0
		move.l		d7,d1
		bsr		GetImNum

		tst.w		d2
		beq.s		NoImChange

		subq.w		#1,d2
		mulu		#BobSize,d2
		
		lea		Bob1,a0
		adda.l		d2,a0
		move.l		a0,Bob

		lea		Bob1Mask,a0
		adda.l		d2,a0
		move.l		a0,BobMask
		
NoImChange	move.w		INTREQR(a5),d0		get bits
		and.w		#VERTB!COPER!BLIT,d0	mask level 3 bits
		move.w		d0,INTREQ(a5)		clear request

		rte					back to user mode

VBLCount	dc.w		5

;		***************************
;		*    Interrogate Mouse    *
;		***************************

; Update bobs x,y position according to mouse movements

; Corrupts d0, d1,d2,d3 and d4

TestMouse	jsr		SeeMouse

; By uncommenting the following two lines you will slow down the speed at
;which the bob moves. The X,Y increment values will have be scaled down by
;some 50%.

		move.l		d0,d6
		move.l		d1,d7

;		asr.w		d0
;		asr.w		d1

		move.w		Bob_x,d2
		add.w		d0,d2
		bpl.s		XNotNeg
		moveq.l		#0,d2

XNotNeg		cmp.w		#288,d2
		ble.s		XOk
		move.w		#288,d2

XOk		move.w		d2,Bob_x

		move.w		Bob_y,d2
		add.w		d1,d2
		bpl.s		YNotNeg
		moveq.l		#0,d2

YNotNeg		cmp.w		#246,d2
		ble.s		YOk
		move.w		#246,d2

YOk		move.w		d2,Bob_y

		rts


; Return image number to use for a bob, given it's dx and dy values.

; Entry		d0 = dx
;		d1 = dy

; Exit		d2 = Image number to use, 1 to 8 clockwise from 12 O'Clock
;		     0 if no change to last image!


GetImNum	move.l		a0,-(sp)
		move.l		d3,-(sp)

		move.w		#1,d2			set bit
		tst.w		d0			test x
		beq.s		XIsSet
		bpl.s		XIsPl
		asl.w		#1,d2
XIsPl		asl.w		#1,d2

XIsSet		move.w		#%1000,d3		set bit
		tst.w		d1			test y
		beq.s		YIsSet
		bpl.s		YIsPl
		asl.w		#1,d3
YIsPl		asl.w		#1,d3

YIsSet		or.w		d3,d2
		lea		ImTab,a0
		move.b		0(a0,d2),d2
		move.l		(sp)+,d3
		move.l		(sp)+,a0
		rts


ImTab		dc.b		0,0,0,0,0,0,0,0,0,0,3,0,7,0,0,0,0,5
		dc.b		4,0,6,0,0,0,0,0,0,0,0,0,0,0,0,1,2,0
		dc.b		8,0
		even

;		***************************
;		*     Blit Graphic	  *
;		***************************

; Entry		d0= x pixel coordinate of bob
;		d1= y pixel coordinate of bob

BlitBob		move.l		Bob_Restore,d0		get restore addr
		beq.s		SaveBob			skip if 0

; Restore background at previous position

BWait		btst		#14,DMACONR(a5)		wait for Blitter
		bne.s		BWait

		moveq.l		#2,d3			num planes - 1

		move.l		#BobSave,BLTAPTH(a5)	A address
		move.w		#0,BLTAMOD(a5)		A Modulo
		move.w		#36,BLTDMOD(a5)		D Modulo
		move.w		#-1,BLTAFWM(a5)		A first mask
		move.w		#-1,BLTALWM(a5)		A last mask
		move.w		#$09f0,BLTCON0(a5)	use A,D: D=A
		move.w		#0,BLTCON1(a5)

BLoop		move.l		d0,BLTDPTH(a5)		D address
		move.w		#16<<6!2,BLTSIZE(a5)	2 words by 16 lines

		add.l		#(320/8)*256,d0		bump for next plane

BWait0		btst		#14,DMACONR(a5)		wait for Blitter
		bne.s		BWait0

		dbra		d3,BLoop

; Calculate start address, scroll for new position. This is saved at the
;label Bob_Restore and used to restore the background during the next pass.

SaveBob		moveq.l		#0,d0			clear registers
		move.l		d0,d1
		move.w		Bob_x,d0		get x position
		move.w		Bob_y,d1		get y position
		mulu		#40,d1			start of line offset
		ror.l		#4,d0			isolate scrl & offset
		asl.w		#1,d0			multiply offset by 2
		add.w		d0,d1			byte offset
		add.l		#Screen,d1		dest start address
		move.l		d1,Bob_Restore		save for next restore
		swap		d0			get scroll bits
		move.w		d0,d2			copy scroll bits
		or.w		#$0fca,d0		add minterm & usage

; Copy background at location bob is about to splat into

BWait1		btst		#14,DMACONR(a5)		wait for Blitter
		bne.s		BWait1

		moveq.l		#2,d3			num planes - 1
		move.l		d1,d4			d4=screen address

		move.l		#BobSave,BLTDPTH(a5)	D address
		move.w		#36,BLTAMOD(a5)		A Modulo
		move.w		#0,BLTDMOD(a5)		D Modulo
		move.w		#-1,BLTAFWM(a5)		A first mask
		move.w		#-1,BLTALWM(a5)		A last mask
		move.w		#$09f0,BLTCON0(a5)	use A,D: D=A
		move.w		#0,BLTCON1(a5)

BLoop1		move.l		d4,BLTAPTH(a5)		A address
		move.w		#16<<6!2,BLTSIZE(a5)	3 words by 10 lines

		add.l		#(320/8)*256,d4		bump for next plane

BWait11		btst		#14,DMACONR(a5)		wait for Blitter
		bne.s		BWait11

		dbra		d3,BLoop1

; Now blit the bob onto screen

		moveq.l		#2,d3
		move.l		d1,d4

		move.l		Bob,BLTBPTH(a5)		B address
		move.w		#-2,BLTAMOD(a5)		A modulo
		move.w		#-2,BLTBMOD(a5)		B modulo
		move.w		#36,BLTCMOD(a5)		C modulo
		move.w		#36,BLTDMOD(a5)		D modulo
		move.w		#-1,BLTAFWM(a5)		A first mask
		move.w		#0,BLTALWM(a5)		A last mask
		move.w		d0,BLTCON0(a5)		Use A,B,C,D: D=AB+aC
		move.w		d2,BLTCON1(a5)		no special modes

BLoop2		move.l		BobMask,BLTAPTH(a5)	A address
		move.l		d4,BLTCPTH(a5)		C address
		move.l		d4,BLTDPTH(a5)		D address
		move.w		#16<<6!2,BLTSIZE(a5)	3 words by 10 lines

		add.l		#(320/8)*256,d4		bump for next plane

BWait2		btst		#14,DMACONR(a5)		wait for Blitter
		bne.s		BWait2

		dbra		d3,BLoop2

		rts


;		***************************
;		*       Fixed Data	  *
;		***************************

Bob		dc.l		Bob1
BobMask		dc.l		Bob1Mask

Bob_x		dc.w		0
Bob_y		dc.w		0
Bob_Restore	dc.l		0

;		***************************
;		*     CHIP Memory Data    *
;		***************************

;section		data custom,chip		****  Use this for A68K  ****

		Section		custom,data_C	**** Use this for Devpac ****

MyCopper	CMOVE		DIWSTRT,$2c81		PAL -- 256 lines
		CMOVE		DIWSTOP,$2cc1
		CMOVE		DDFSTRT,$0038		LoRes
		CMOVE		DDFSTOP,$00d0
		CMOVE		BPL1MOD,$0000		No modulos
		CMOVE		BPL2MOD,$0000
		CMOVE		BPLCON0,$3200		3 bitplanes & colour
		CMOVE		BPLCON1,$0000		No scrolling
		CMOVE		BPLCON2,$0000		Ignore priority

CopPlanes	CMOVE		BPL1PTH,0		Bit plane pointer
		CMOVE		BPL1PTL,0
		CMOVE		BPL2PTH,0		Bit plane pointer
		CMOVE		BPL2PTL,0
		CMOVE		BPL3PTH,0		Bit plane pointer
		CMOVE		BPL3PTL,0

		ds.w		16*2			space for 16 colours
		
		CEND					end of list

; Raw screen data: 320x256x3, CMAP behind.

Screen		incbin		BlitPic2.bm

Bob1		incbin		Mouse1.bm

Bob1Mask	incbin		Mouse1Mask.bm

BobSize		equ		*-Bob1

Bob2		incbin		Mouse2.bm

Bob2Mask	incbin		Mouse2Mask.bm

Bob3		incbin		Mouse3.bm

Bob3Mask	incbin		Mouse3Mask.bm

Bob4		incbin		Mouse4.bm

Bob4Mask	incbin		Mouse4Mask.bm

Bob5		incbin		Mouse5.bm

Bob5Mask	incbin		Mouse5Mask.bm

Bob6		incbin		Mouse6.bm

Bob6Mask	incbin		Mouse6Mask.bm

Bob7		incbin		Mouse7.bm

Bob7Mask	incbin		Mouse7Mask.bm

Bob8		incbin		Mouse8.bm

Bob8Mask	incbin		Mouse8Mask.bm

BobSave		ds.w		3*18*3			

		end

		
