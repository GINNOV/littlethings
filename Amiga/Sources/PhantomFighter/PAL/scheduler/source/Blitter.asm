;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;
; File contains :-
; = = = = = = = = =
;
; XORBlit
;
; BlitBackGroundBob
;
; XORBackBlit
;
; ORBackBlit
;
; SoftBlit
;
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

		far	code
		far	data

		xdef	_SoftBlit
		xref	_bm2
		xref	_view_bm
		xref	_BLTListWrite
		xref	_BLTListRead
		xref	_BLT_ObjectList

		include	"header:iff.i"
                include	"header:custom.i"

DoPlane		Macro
		move.l	#0,d0			* Plane Offset
		move.w	D7,d0
		add.l	(a2)+,d0		* Add to plane start
		move.l	d0,(a3)+		* cpt
		lea.l	4(a3),a3		* Skip bpt
		add.l	d1,d4			* Add imagesize
		move.l	d4,(a3)+		* apt
		move.l	-12(a3),(a3)		* dpt is same as cpt
		lea.l	4(a3),a3		* Move to next set of pts
		Endm

;- - - - - - - - - XOBlit - - - - - - - - - - - - - - - - - - -
;
; FUNCTION
;    XORBlit(Object,x,y)
;       struct GraphObject *Object;
;       WORD x,y;
;
;
; ACTION
;   Blits a 3 plane Graphobject to a specified x y on a bitmap
;   pointed to by view_bm. The image is XORed on
;
;- - Written by Billy Newport - - - - - - - - - - - - - - - - - -

		xdef	_XORBlit
_XORBlit:
BlitterRegs	reg	a2/a3/d3/d4/d5/d6/D7
LOC_object	equ	8
LOC_x		equ	14
LOC_y		equ	18

		move.l	a5,-(sp)
		movea.l	sp,a5		* Get Frame Ptr
		movem.l	BlitterRegs,-(sp)

		move.w	LOC_x(a5),d4
                move.w	LOC_y(a5),d5
		movea.l	LOC_object(a5),a0
;;; X<-32
		cmp.w	#-32,d4	* x<-32 ?
		ble	10$
;;; Y<-32
		cmp.w	#-32,d5	* y<-32 ?
		ble	10$
;;; X+Width>352
		move.w	GOBJ_width(a0),d1
		add.w	d1,d4
		cmp.w	#352,d4
		bge	10$
;;; Y+Height>232
		move.w	GOBJ_height(a0),d1
		add.w	d1,d5
		cmp.w	#232,d5
		blt	20$	* If yes, clip and exit
10$
		movem.l	(sp)+,BlitterRegs
		movea.l	(sp)+,a5
		rts

20$
		add.w	#32,LOC_x(a5)	* x+=32
		add.w	#32,LOC_y(a5)	* y+=32

		move.l	LOC_object(a5),a0	* Get width in bytes
		move.w	GOBJ_width(a0),d6	* in D6
		add.w	#15,d6
		asr.w	#3,d6
		bclr	#0,d6

		move.w	D6,d5			* Get ImageSize in d5
		mulu.w	GOBJ_height(a0),d5

		move.l	_view_bm,a0	* Get Destination modulo
		move.w	(a0),d3		* BytesPerRow
		move.w	D6,d1	* Width in Bytes
		add.w	#2,d1		* +2 cause extra word
		sub.w	d1,d3		* Subtract

		move.w	LOC_y(a5),D7	* Get Byte Offset in plane
		mulu.w	(a0),D7		* y * bytesperrow
		move.w	LOC_x(a5),d1
		asr.w	#3,d1
		add.w	d1,D7		* + x &15

		move.l	#0,d0		* Get Blitter object
		move.w	_BLTListWrite,d0
		and.w	#127,d0		* Wrap
		move.w	#66,d1		* BLT_size
		mulu.w	d1,d0
		lea	_BLT_ObjectList,a0
		add.l	a0,d0
		move.l	d0,a3

		move.w	LOC_x(a5),d0		* xcon0
		and.w	#15,d0			* shift x&15
		move.w	#12,d1			* <<12
		asl.w	d1,d0
		or.w	#USEA|USEC|USED|$5a,d0		*A|C|D|0x5a
		move.w	d0,(a3)+

		clr.w	(a3)+			* Clear con1

		move.w	D3,(a3)+	* cmod
		lea.l	2(a3),a3		* Skip bmod
		move.w	#-2,(a3)+		* amod
		move.w	D3,(a3)+	* dmod

		move.w	#-1,(a3)+		* afwm
		clr.w	(a3)+			* alwm

		move.l	LOC_object(a5),a0	* Get bltsize
		move.w	GOBJ_height(a0),d0
		asl.w	#6,d0
		move.w	D6,d1
		lsr.w	#1,d1
		add.w	d1,d0
		add.w	#1,d0
		move.w	d0,(a3)+

		move.l	LOC_object(a5),a0	* Get Start of image
		move.l	GOBJ_image(a0),d4

		move.l	_view_bm,a2		* Get Address of Planes
		add.l	#8,a2

		moveq.l	#0,d0
		move.w	D7,d0	* Store Plane Offset
		add.l	(a2)+,d0		* in cpt
		move.l	d0,(a3)+
		lea.l	4(a3),a3		* bpt
		move.l	d4,(a3)+		* apt
		move.l	-12(a3),(a3)		* dpt
		lea.l	4(a3),a3

		moveq.l	#0,d1
		move.w	D5,d1	* Get ImageSize
		DoPlane				* Do Other two planes
                DoPlane
30$
		move.w	_BLTListWrite,d0	* Wait before incrementing
		add.w	#2,d0
		move.w	_BLTListRead,d1
		sub.w	d1,d0
		and.w	#127,d0
		beq	30$
40$
		add.w	#1,_BLTListWrite	* Increment and finish
		bra	10$

;- - - - - - - - - XORBackBlit - - - - - - - - - - - - - - - - -
;
; FUNCTION
;    XORBackBlit(Object,x,y)
;       struct GraphObject *Object;
;       WORD x,y;
;
;
; ACTION
;   Blits a 3 plane Graphobject to a specified x y on a bitmap
;   pointed to by bm2. The image is XORed on
;
;- - Written by Billy Newport - - - - - - - - - - - - - - - - - -

		xdef	_XORBackBlit
_XORBackBlit:
		move.l	a5,-(sp)
		movea.l	sp,a5		* Get Frame Ptr
		movem.l	BlitterRegs,-(sp)

		move.w	LOC_x(a5),d4
                move.w	LOC_y(a5),d5
		move.l	LOC_object(a5),a0	* Get width in bytes
		move.w	GOBJ_width(a0),d6	* in D6
		add.w	#15,d6
		asr.w	#3,d6
		bclr	#0,d6

		move.w	D6,d5			* Get ImageSize in d5
		mulu.w	GOBJ_height(a0),d5

		move.l	_bm2,a0	* Get Destination modulo
		move.w	(a0),d3		* BytesPerRow
		move.w	D6,d1	* Width in Bytes
		add.w	#2,d1		* +2 cause extra word
		sub.w	d1,d3		* Subtract

		move.w	LOC_y(a5),D7	* Get Byte Offset in plane
		mulu.w	(a0),D7		* y * bytesperrow
		move.w	LOC_x(a5),d1
		asr.w	#3,d1
		add.w	d1,D7		* + x &15

		move.l	#0,d0		* Get Blitter object
		move.w	_BLTListWrite,d0
		and.w	#127,d0		* Wrap
		move.w	#66,d1		* BLT_size
		mulu.w	d1,d0
		lea	_BLT_ObjectList,a0
		add.l	a0,d0
		move.l	d0,a3

		move.w	LOC_x(a5),d0		* xcon0
		and.w	#15,d0			* shift x&15
		move.w	#12,d1			* <<12
		asl.w	d1,d0
		or.w	#USEA|USEC|USED|$5a,d0		*A|C|D|0x5a
		move.w	d0,(a3)+

		clr.w	(a3)+			* Clear con1

		move.w	D3,(a3)+	* cmod
		lea.l	2(a3),a3		* Skip bmod
		move.w	#-2,(a3)+		* amod
		move.w	D3,(a3)+	* dmod

		move.w	#-1,(a3)+		* afwm
		clr.w	(a3)+			* alwm

		move.l	LOC_object(a5),a0	* Get bltsize
		move.w	GOBJ_height(a0),d0
		asl.w	#6,d0
		move.w	D6,d1
		lsr.w	#1,d1
		add.w	d1,d0
		add.w	#1,d0
		move.w	d0,(a3)+

		move.l	LOC_object(a5),a0	* Get Start of image
		move.l	GOBJ_image(a0),d4

		move.l	_bm2,a2		* Get Address of Planes
		add.l	#8,a2

		moveq.l	#0,d0
		move.w	D7,d0	* Store Plane Offset
		add.l	(a2)+,d0		* in cpt
		move.l	d0,(a3)+
		lea.l	4(a3),a3		* bpt
		move.l	d4,(a3)+		* apt
		move.l	-12(a3),(a3)		* dpt
		lea.l	4(a3),a3

		moveq.l	#0,d1
		move.w	D5,d1	* Get ImageSize
		DoPlane				* Do Other two planes
                DoPlane
30$
		move.w	_BLTListWrite,d0	* Wait before incrementing
		add.w	#2,d0
		move.w	_BLTListRead,d1
		sub.w	d1,d0
		and.w	#127,d0
		beq	30$
40$
		add.w	#1,_BLTListWrite	* Increment and finish
		movem.l	(sp)+,BlitterRegs
		movea.l	(sp)+,a5
		rts

;- - - - - - - - - ORBackBlit - - - - - - - - - - - - - - - - -
;
; FUNCTION
;    ORBackBlit(Object,x,y)
;       struct GraphObject *Object;
;       WORD x,y;
;
;
; ACTION
;   Blits a 3 plane Graphobject to a specified x y on a bitmap
;   pointed to by bm2. The image is ORed on
;
;- - Written by Billy Newport - - - - - - - - - - - - - - - - - -

		xdef	_ORBackBlit
_ORBackBlit:
		move.l	a5,-(sp)
		movea.l	sp,a5		* Get Frame Ptr
		movem.l	BlitterRegs,-(sp)

		move.w	LOC_x(a5),d4
                move.w	LOC_y(a5),d5
		move.l	LOC_object(a5),a0	* Get width in bytes
		move.w	GOBJ_width(a0),d6	* in D6
		add.w	#15,d6
		asr.w	#3,d6
		bclr	#0,d6

		move.w	D6,d5			* Get ImageSize in d5
		mulu.w	GOBJ_height(a0),d5

		move.l	_bm2,a0	* Get Destination modulo
		move.w	(a0),d3		* BytesPerRow
		move.w	D6,d1	* Width in Bytes
		add.w	#2,d1		* +2 cause extra word
		sub.w	d1,d3		* Subtract

		move.w	LOC_y(a5),D7	* Get Byte Offset in plane
		mulu.w	(a0),D7		* y * bytesperrow
		move.w	LOC_x(a5),d1
		asr.w	#3,d1
		add.w	d1,D7		* + x &15

		move.l	#0,d0		* Get Blitter object
		move.w	_BLTListWrite,d0
		and.w	#127,d0		* Wrap
		move.w	#66,d1		* BLT_size
		mulu.w	d1,d0
		lea	_BLT_ObjectList,a0
		add.l	a0,d0
		move.l	d0,a3

		move.w	LOC_x(a5),d0		* xcon0
		and.w	#15,d0			* shift x&15
		move.w	#12,d1			* <<12
		asl.w	d1,d0
		or.w	#USEA|USEC|USED|$fa,d0		*A|C|D|0xfa
		move.w	d0,(a3)+

		clr.w	(a3)+			* Clear con1

		move.w	D3,(a3)+	* cmod
		lea.l	2(a3),a3		* Skip bmod
		move.w	#-2,(a3)+		* amod
		move.w	D3,(a3)+	* dmod

		move.w	#-1,(a3)+		* afwm
		clr.w	(a3)+			* alwm

		move.l	LOC_object(a5),a0	* Get bltsize
		move.w	GOBJ_height(a0),d0
		asl.w	#6,d0
		move.w	D6,d1
		lsr.w	#1,d1
		add.w	d1,d0
		add.w	#1,d0
		move.w	d0,(a3)+

		move.l	LOC_object(a5),a0	* Get Start of image
		move.l	GOBJ_image(a0),d4

		move.l	_bm2,a2		* Get Address of Planes
		add.l	#8,a2

		moveq.l	#0,d0
		move.w	D7,d0	* Store Plane Offset
		add.l	(a2)+,d0		* in cpt
		move.l	d0,(a3)+
		lea.l	4(a3),a3		* bpt
		move.l	d4,(a3)+		* apt
		move.l	-12(a3),(a3)		* dpt
		lea.l	4(a3),a3

		moveq.l	#0,d1
		move.w	D5,d1	* Get ImageSize
		DoPlane				* Do Other two planes
                DoPlane
30$
		move.w	_BLTListWrite,d0	* Wait before incrementing
		add.w	#2,d0
		move.w	_BLTListRead,d1
		sub.w	d1,d0
		and.w	#127,d0
		beq	30$
40$
		add.w	#1,_BLTListWrite	* Increment and finish
		movem.l	(sp)+,BlitterRegs
		movea.l	(sp)+,a5
		rts

DoPlane2	Macro
		move.l	#0,d0			* Plane Offset
		move.w	D7,d0
		add.l	(a2)+,d0		* Add to plane start
		move.l	d0,(a3)+		* cpt
		add.l	d1,d4			* Advance image ptr
		move.l	d4,(a3)+		* bpt
		move.l	a4,(a3)+		* apt
		move.l	-12(a3),(a3)		* dpt is same as cpt
		lea.l	4(a3),a3		* Move to next set of pts
		Endm

;- - - - - - - - - BlitBackGroundBob - - - - - - - - - - - - - - - - - - -
;
; FUNCTION
;    BlitBackGroundBob(Object,x,y)
;       struct GraphObject *Object;
;       WORD x,y;
;
;
; ACTION
;   Blits a 3 plane Graphobject with mask to a specified x y on a bitmap
;   pointed to by bm2. The image is MASKEDed on
;
;- - Written by Billy Newport - - - - - - - - - - - - - - - - - -

		xdef	_BlitBackGroundBob
_BlitBackGroundBob:
BlitterRegs2	reg	d4/a2/a3/a4/d5/d6/D7

		move.l	a5,-(sp)
		movea.l	sp,a5
		movem.l	BlitterRegs2,-(sp)

		move.l	LOC_object(a5),a0	* Get width in bytes
		move.w	GOBJ_width(a0),d6	* in LOC_temp
		add.w	#15,d6
		asr.w	#3,d6
		bclr	#0,d6

		move.w	d6,d5
		mulu.w	GOBJ_height(a0),d5	* ImageSize in bytes

		move.l	_bm2,a0		* Get Destination modulo
		move.w	(a0),d3		* BytesPerRow
		move.w	D6,d1	* Width in Bytes
		add.w	#2,d1		* +2 cause extra word
		sub.w	d1,d3		* Subtract

		move.w	LOC_y(a5),D7	* Get Byte offset in plane
		mulu.w	(a0),D7		* y * bytesperrow
		move.w	LOC_x(a5),d1
		asr.w	#3,d1
		add.w	d1,D7		* + x &15

		move.l	#0,d0		* Get Blitter object
		move.w	_BLTListWrite,d0
		and.w	#127,d0		* Wrap
		move.w	#66,d1		* BLT_size
		mulu.w	d1,d0
		lea	_BLT_ObjectList,a0
		add.l	a0,d0
		move.l	d0,a3

		move.w	LOC_x(a5),d0		* xcon0
		and.w	#15,d0			* shift x&15
		move.w	#12,d1			* <<12
		asl.w	d1,d0
		move.w	d0,2(a3)		* con1
		or.w	#$fca,d0		*A|B|C|D|0xca
		move.w	d0,(a3)+

		lea.l	2(a3),a3		* con1 done already

		move.w	D3,(a3)+	* cmod
		move.w	#-2,(a3)+		* bmod
		move.w	#-2,(a3)+		* amod
		move.w	D3,(a3)+	* dmod

		move.w	#-1,(a3)+		* afwm
		clr.w	(a3)+			* alwm

		move.l	LOC_object(a5),a0	* Get bltsize
		move.w	GOBJ_height(a0),d0
		asl.w	#6,d0
		move.w	D6,d1
		lsr.w	#1,d1
		add.w	d1,d0
		add.w	#1,d0
		move.w	d0,(a3)+

		move.l	LOC_object(a5),a0	* Get Start of image
		move.l	GOBJ_image(a0),d4

		move.l	_bm2,a2			* Get Address of Planes
		add.l	#8,a2

		moveq.l	#0,d0
		move.w	D5,d0
		move.l	d0,d1			* Save in d1
                add.l	d0,d0			* 2*
                add.l	d1,d0			* 3 *imagesize
		add.l	d4,d0			* Add to image to get mask
                movea.l	d0,a4			* Put in a4

		moveq.l	#0,d0
		move.w	D7,d0	* Store Plane Offset
		add.l	(a2)+,d0		* in cpt
		move.l	d0,(a3)+
		move.l	d4,(a3)+		* bpt
		move.l	a4,(a3)+		* apt
		move.l	-12(a3),(a3)		* dpt
		lea.l	4(a3),a3

		moveq.l	#0,d1
                move.w	D5,d1	* Get fast imagesize
		DoPlane2			* Do Other two planes
                DoPlane2
10$
		move.w	_BLTListWrite,d0	* Wait before incrementing
		add.w	#2,d0
		move.w	_BLTListRead,d1
		sub.w	d1,d0
		and.w	#127,d0
		bne	20$
		bra	10$
20$
		add.w	#1,_BLTListWrite	* Increment and finish
		movem.l	(sp)+,BlitterRegs2
		movea.l	(sp)+,a5
		rts


;; SoftBlit(image,dest,dmod,h,s)

DoSoftLine	Macro				* 61 cycles on average
		moveq.l	#0,d2			* Clear
		move.w	(a0)+,d2		* Get word
		ror.l	d1,d2			* Shift
		swap	d2			* Swap around
		eor.l	d2,(a1)			* Xor on
                adda.l	a2,a1			* add width screen
		endm

DoSoftLineZ	Macro				* 56 cycles on average
		moveq.l	#0,d1			* Clear
		move.w	(a0)+,d1		* Get word
		rol.l	d2,d1			* Shift
		eor.l	d1,(a1)			* Xor on
                adda.l	a2,a1			* add width screen
		endm

SoftBlitRegs:	reg	a2/d2
_SoftBlit:	movea.l	sp,a0
		movem.l	SoftBlitRegs,-(sp)

		movea.l	8(a0),a1		* a1 is plane
		movea.l	12(a0),a2		* a2 is dmod
                move.w	18(a0),d0		* Row counter
		lsr.w	#1,d0			* Divide by four
		subq.l	#1,d0
                move.w	22(a0),d1		* Shift counter
		movea.l	4(a0),a0		* a0 is image
		cmp.w	#8,d1			* Quicker with rol
                bcc	20$
                
10$:
		DoSoftLine
                DoSoftLine
                dbf	d0,10$			* loop
                
		movem.l	(sp)+,SoftBlitRegs	* restore a2
		rts

* Note d2 and d1 reversed here

20$:		moveq.l	#16,d2
		sub.w	d1,d2
30$:		DoSoftLineZ
                DoSoftLineZ
                dbf	d0,30$
		movem.l	(sp)+,SoftBlitRegs
                rts

;- - - - - - - - - SmallBlit - - - - - - - - - - - - - - - - - - -
;
; FUNCTION
;    SmallBlit(Object,x,y)
;       struct GraphObject *Object;
;       WORD x,y;
;
;
; ACTION
;   Blits a 3 plane Graphobject to a specified x y on a bitmap
;   pointed to by view_bm. The image is XORed on
;
;- - Written by Billy Newport - - - - - - - - - - - - - - - - - -

		xdef	_SmallBlit
SmallRegs:	reg	d4-d7/a2/a3
_SmallBlit:

		move.l	a5,-(sp)
		movea.l	sp,a5		* Get Frame Ptr
		movem.l	SmallRegs,-(sp)

		move.w	LOC_x(a5),d4
                move.w	LOC_y(a5),d5
		movea.l	LOC_object(a5),a0
;;; X<-32
		cmp.w	#-32,d4	* x<-32 ?
		ble	10$
;;; Y<-32
		cmp.w	#-32,d5	* y<-32 ?
		ble	10$
;;; X+Width>352
		move.w	GOBJ_width(a0),d1
		add.w	d1,d4
		cmp.w	#352,d4
		bge	10$
;;; Y+Height>232
		move.w	GOBJ_height(a0),d1
		add.w	d1,d5
		cmp.w	#232,d5
		blt	20$	* If yes, clip and exit
10$
		movem.l	(sp)+,SmallRegs
		movea.l	(sp)+,a5
		rts

20$
		add.w	#32,LOC_x(a5)	* x+=32
		add.w	#32,LOC_y(a5)	* y+=32

		moveq.l	#0,d5		* Clear High Word
		move.w	GOBJ_height(a0),d5

		move.l	_view_bm,a0	* Get Destination modulo
		move.w	LOC_y(a5),D7	* Get Byte Offset in plane
		mulu.w	(a0),D7		* y * bytesperrow
		move.w	LOC_x(a5),d1
		asr.w	#3,d1
		andi.l	#$fffe,d1	* Cleare high word and low bit
		add.l	d1,D7		* D7 is DstOffset

                lea.l	8(a0),a2	* Address of pointer to first plane
                
		move.w	LOC_x(a5),d6	* Get x
                andi.l	#15,d6		* Shift

      		move.l	d6,-(sp)
                move.l	d5,-(sp)
		add.w	d5,d5		* Double here

                move.w	-8(a2),-(sp)	* Get BytesPerRow
		clr.w	-(sp)		* Clear High Word
                
		move.l	(a2)+,-(sp)	* Save Plane 0 Address
                add.l	d7,(sp)		* Add DstOffset
		move.l	LOC_object(a5),a0
                move.l	GOBJ_image(a0),-(sp)
;;; SoftBlit(Image,Plane,BytesPerRow,ImageSizeShift)
		jsr	_SoftBlit

               	move.l	(a2)+,4(sp)	* GEt Plane address
                add.l	d7,4(sp)	* Add DstOffset to new plane
                add.l	d5,(sp)		* Add ImageSize
                jsr	_SoftBlit

               	move.l	(a2)+,4(sp)	* GetPlane Address
                add.l	d7,4(sp)	* Add DstOffset to new plane
                add.l	d5,(sp)		* Add ImageSize
                jsr	_SoftBlit
		lea.l	20(sp),sp		* Neccessary
		jmp	10$
                end


