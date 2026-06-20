
		include "header:custom.i"
                include	"header:iff.i"
		public	_ScrollVTop
		public	_ScrollHBot	
                public	_ScrollHTop
                
		XREF	_CurVMod,_sys_time

		XREF		_Copper,_XBOffset,_XOffset
		XREF		_BPlanes,_BotDirection

BLTNASTY	macro
		move.w	#SETBIT+BLTPRI,_custom+dmacon
		endm
BLTNICE		macro
		move.w	#CLRBIT+BLTPRI,_custom+dmacon
                endm

;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Use my autovector for Level 3
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

		xdef	_SetUpLoadVectors
		xdef	_SetAutoVector,_ClearAutoVector

_SetAutoVector:	lea.l	_AutoVectorISR,a0
		move.w	#7,d0
                lea.l	$60,a1
10$		move.l	a0,(a1)+		;Level n AutoVector
		dbf	d0,10$
		BLTNASTY
                rts
                
_ClearAutoVector:
		BLTNICE
                rts

;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; AutoVector Interrupt handler
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


		xdef	_AutoVectorISR

AutoVectorRegs:	reg	d0-d7/a0-a6

_AutoVectorISR:	movem.l	AutoVectorRegs,-(sp)

		move.w	_custom+intenar,d0
                and.w	_custom+intreqr,d0	;IntEn&IntReq
                move.w	d0,_custom+intreq	;Clear request
                btst	#4,d0		;Test Copper
                bne.s	10$
		btst	#5,d0		;VertB
                bne.s	20$		;Do VertB
                movem.l	(sp)+,AutoVectorRegs
                rte
10$:		lea.l	_sys_time,a1
		jsr	_CopperServer
                movem.l	(sp)+,AutoVectorRegs
                rte
20$:		jsr	_ColorCycler
	        movem.l	(sp)+,AutoVectorRegs
                rte

		xdef	_AutoVectorISR

		xref	_LVB_Server

LVB_Regs:	reg	d0-d7/a0-a6
_LVBServerQ:	movem.l	LVB_Regs,-(sp)

		move.w	_custom+intenar,d0
                and.w	_custom+intreqr,d0	;IntEn&IntReq
                move.w	d0,_custom+intreq	;Clear request
		btst	#5,d0		;VertB
                bne.s	20$		;Do VertB
                movem.l	(sp)+,LVB_Regs
                rte
20$:		jsr	_LVB_Server
	        movem.l	(sp)+,LVB_Regs
                rte

FirstAdd:	equ		242
NextAdd:	equ		16
ScrollReg	equ		FirstAdd-20

BFirstAdd	equ		410
BNextAdd	equ		16
BScrollReg	equ		BFirstAdd-20

SCRLHBPlne	Macro
		move.w		(a0),d0
                swap		d0
                move.w		4(a0),d0
                add.l		d2,d0
                move.w		d0,4(a0)
                swap		d0
                move.w		d0,(a0)
		adda.w		#BNextAdd,a0
		Endm

; - - - - - - - - - - - - - ScrollHBot  - - - - - - - - - - - - -
;
; FUNCTION ScrollHBot()
;
; ACTION
;    This scrolls the bottom viewport by bit aligning with XBoffset
;    first. If BotDirection=-2 then 2 is subtracted from the bit
;    plane pointers in the copper list if XBoffset&15=15
;
;    If BotDirection=2 then it is added to the bitplane pointers
;    in the copper list if XBoffset=0
;
;
; WARNING
;    Code assumes a one pixel scroll.
;
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

_ScrollHBot:	movea.l		d1,a1
		move.l		d2,-(sp)	;Save d2
		move.l		_BotDirection,d2
		movea.l		_Copper,a0
                move.l		_XBOffset,d0
                andi.w		#15,d0
                move.w		d0,d1
                lsl.w		#4,d0
		eori.w		#$f0,d0
                move.w		d0,BScrollReg(a0)
		tst.l		d2
                bmi.s		5$
		cmp.w		#1,d1
                bne.l		20$
		beq.s		6$
5$:		cmp.w		#15,d1
                bne.l		20$
6$:		adda.l		#BFirstAdd,a0

		SCRLHBPlne
		SCRLHBPlne
		SCRLHBPlne		;Saves 38 cycles

20$:		move.l		a1,d1
		move.l		(sp)+,d2
		rts

; Called as ScrollHTop(Copper,Xoffset) where Copper is a pointer to the 
;current Copper list and Xoffset is the offset of the view in the planezz.

SCRLHTPlne	Macro
		move.w		(a0),d0
                swap		d0
                move.w		4(a0),d0
                addq.l		#2,d0
                move.w		d0,4(a0)
                
                swap		d0
                move.w		d0,(a0)
                adda.w		#NextAdd,a0
		Endm
                
_ScrollHTop:	movea.l		d1,a1
		movea.l		_Copper,a0
                move.l		_XOffset,d0
                andi.w		#15,d0
                move.w		d0,d1
                lsl.w		#4,d0
		eori.w		#$f0,d0
                move.w		d0,ScrollReg(a0)
                tst.w		d1
                bne.l		20$
		adda.l		#FirstAdd,a0
		SCRLHTPlne
		SCRLHTPlne
		SCRLHTPlne
20$:		move.l		a1,d1
                rts

; Called as ScrollVTop(Copper) where Copper is a pointer to the current
; Copper list.

SCRLVTPlne	Macro
	        move.w		(a0),d0
                swap		d0
                move.w		4(a0),d0
                sub.l		_CurVMod,d0
                move.w		d0,4(a0)
                swap		d0
                move.w		d0,(a0)
                adda.w		#NextAdd,a0
		Endm

_ScrollVTop:
		movea.l		_Copper,a0
		adda.l		#FirstAdd,a0
		SCRLVTPlne
		SCRLVTPlne
		SCRLVTPlne
                rts

;; Sprite Address in a, x in d0 y in d1
;;  Temp.SData[0]=((Y&0xff)<<8)+(X>>1);
;;  Temp.SData[1]=(((Y+H)&0xff)<<8)+((Y&0x100)>>6)+
;;           	    (((Y+H)&0x100)>>7)+(X&1);

PositionSprite:	
		move.w	d1,d2
		andi.w	#$ff,d2
                lsl.w	#8,d2		;Get Y&ff<<8
		move.w	d2,-(sp)
                move.w	d0,d2		;Get X
                lsr.w	#1,d2		;Get x>>1
                add.w	(sp)+,d2	;Get First control word
                move.w	d2,(a0)		;Store it

		move.w	d1,d2
		add.w	#49,d2		;Get y+49
		andi.w	#$ff,d2		;&ff
                lsl.w	#8,d2		;get (y+49)<<8
		move.w	d2,-(sp)

                move.w	d1,d2
                andi.w	#$100,d2
                lsr.w	#6,d2		;y&$100>>6
                add.w	(sp),d2
                move.w	d2,(sp)		;(y+49)&ff<<8+y&100>>6

                move.w	d1,d2		;Get y
		add.w	#49,d2		;y+49
                andi.w	#$100,d2
                lsr.w	#7,d2		;y&$100>>6
                add.w	(sp),d2
                move.w	d2,(sp)	;(y+49)&ff<<8+y&100>>6+(y+49)&100>>7

		move.w	d0,d2
		andi.w	#1,d2		;x&1
                add.w	(sp)+,d2	;Get second control word
                move.w	d2,2(a0)		;Store it
                rts

SetUpDouble:
		move.w	#118+14+226,d0
                add.w	d1,d0
                move.w	#30+2+86,d1
                jsr	PositionSprite
		bset	#7,3(a0)	;Set Attach bit
		rts

		xref	_LVBServer

_LVBServer:	move.w	#0,d1
		rts
;                lea.l	_LoadSprite01,a1
;                lea.l	_LoadSprite00,a0
;                jsr	SetUpDouble
;		move.w	#16,d1
;;		lea.l	_LoadSprite02,a0
;;                lea.l	_LoadSprite03,a1
;;                jsr	SetUpDouble
;;		move.w	#32,d1
;;		lea.l	_LoadSprite04,a0
;;                lea.l	_LoadSprite05,a1
;;                jsr	SetUpDouble
;		rts

		XREF	_VBFunc,_BlitFlag,_Debug_Routine,_WatchDog,_MyDebug
		XDEF	_CopperServer,_VFunctions
		xdef	_TimeForChecking
		public	_BLT_ObjectList
		dseg
_TimeForChecking:	dc.w	0
		cseg                

                xref	_MainCopper

_CopperServer:
		move.w	#1,_TimeForChecking
		subi.l	#1,_WatchDog
		bne.s	1$
;                jsr	_MyDebug
1$:		addq.l	#1,(a1)		;Increment Sys_Time
;
; If VBFunc is none zero then we must scroll PF2 either horizontally or
; vertically. Done here for flicker free scrolling
;


; Invoke Debug when Mouse Pressed
;

;		move.b	$bfe001,d0
;                andi.b	#64,d0
;                bne.s	10$
;                jsr	_MyDebug

10$:
                pea.l	50$
		move.l	_VBFunc,d0	;Got the number already multiplied
		lea.l	_VFunctions,a1	;Scratch a1 coz we can
                adda.l	d0,a1
40$:		move.l	(a1)+,-(a7)
		bne	40$
                addq.l	#4,a7
                andi.l	#$60,d0		;Keep ScrollHBOT ReLoadBot
                bne.s	41$
		move.l	_sys_time,d0
                andi.l	#2,d0
                bne.s	41$		;Do every four ticks

41$:		clr.l	_VBFunc
	        rts
50$:		tst.l	_BlitFlag
                bne.l	60$

		jmp	_BLTServer
                
60$:
		rts

		XDEF	_Wait_Blit
_Wait_Blit:	move.w	_custom+dmaconr,d0		;Wait for last blit to finish
                andi.w	#BBUSY,d0
                bne.l	_Wait_Blit
                rts

; On entry A1 has the head of the blitter queue in it

		public	_BLTServer
		public	_BLTListRead
                public	_BLTListWrite
		XREF	_BlitFlag

BLTPlane	macro	\1
*		move.l	d1,(a2)		;con0 and con1 (14)
		movea.l	a4,a5		;get cptr      ( 4)
\1		reg	d4-d7
		movem.l	(a1)+,\1	;Get cbad      (28)
                movem.l	\1,(a5)		;Store cbad    (28)
	        move.w	d0,(a3)		;BLTSIZE       ( 9)
                nop			;buffer	       ( 4)
                			;             -----
		endm			;Total         (85)


		include	"header:blits.i"

_BLTServer:	
		movea.l	#_custom,a0		* a0 is custom base address

;		move.w	#$fff,$dff180		* Border White

;		lea.l	bltcon0(a0),a2		* Get BLTCON0
		lea.l	bltsize(a0),a3		* bltsiz
                lea.l	bltcpth(a0),a4		* cptr
		move.w	#CLRBIT+BLIT,intena(a0)		* No blitter interrupt please
		move.l	#1,_BlitFlag
DoBlit:
                move.w	_BLTListRead,d0
                cmp.w	_BLTListWrite,d0
                beq.l	999$
                andi.w	#MAXBLITS-1,d0			* Only 0-127 is valid
		addi.w	#1,_BLTListRead		* Signal this done
		mulu.w	#66,d0
		lea.l	_BLT_ObjectList,a1	* Base address
                adda.w	d0,a1			* Address of the MAN

*		move.l	(a1)+,d1		* con0 and con1
		move.l	(a1)+,bltcon0(a0)	* con0 and con1

		lea.l	bltcmod(a0),a5
		move.l	(a1)+,(a5)+		* c and b mod
                move.l	(a1)+,(a5)		* a and d mod
	
	        move.l	(a1)+,bltafwm(a0)		* afwm & alwn
	
		move.w	(a1)+,d0		* Get BltSiz
                
		BLTPlane	123$		* Plane 0
		BLTPlane	124$		* Plane 1
                BLTPlane	125$		* Plane 2

		jmp	DoBlit			* Check next entry

999$:
		
;		move.w	#$443,$dff180
		clr.l	_BlitFlag
		rts
        
		xdef	_ColorCycler
		xref	_Copper
		dseg
Count:		dc.w	0
Count2:		dc.w	0
		cseg

_ColorCycler:	movea.l	_Copper,a0
		move.w	#SETBIT+VERTB,_custom+intreq	;Set Coper first
		move.w	#CLRBIT+VERTB,_custom+intreq	;Now Clear Copper
		move.w	Count,d0
                addi.w	#1,d0
                cmpi.w	#6,d0
                beq.s	10$
		move.w	d0,Count
                move.l	#1,d0
		jmp	20$
10$:		clr.w	Count
		lea.l	186(a0),a0		*Get Color5
                move.w	(a0),d0
                move.w	4(a0),d1
                move.w	8(a0),a1
                move.w	a1,(a0)
                move.w	d0,4(a0)
                move.w	d1,8(a0)
                move.l	#1,d0


20$:		move.w	Count2,d0
                addi.w	#1,d0
                cmpi.w	#10,d0
                beq.s	30$
		move.w	d0,Count2
                move.l	#1,d0
                rts
30$:		clr.w	Count2
		lea.l	326(a0),a0		*Get Color5
                move.w	(a0),d0
                move.w	4(a0),d1
                move.w	d0,4(a0)
                move.w	d1,(a0)
                move.l	#1,d0
                rts


_SetUpLoadVectors:	lea.l	_LVBServerQ,a0
		move.w	#7,d0
                lea.l	$60,a1
10$		move.l	a0,(a1)+		;Level n AutoVector
		dbf	d0,10$
                rts
                
