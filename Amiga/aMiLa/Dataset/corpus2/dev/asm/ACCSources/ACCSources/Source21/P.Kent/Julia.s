
    OPT C-,O+,D+

*****************************************************************************
*TABS = 4                                                                   *
*                     FULL-SCREEN JULIA SETS IN REALTIME                    *
*                     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~                    *
*                          Code: Paul Kent 31/1/92                          *
*                                                                           *
*Code plots a full screen image from the standard julia set equations       *
*of Z->Z^2+C for constant c and varied z. (c,z = complex no.s).             *
*                                                                           *
*Various values for 'c' are built in - experiment with others!              *
*This code evaluates using fixed point arithmetic! It is not designed       *
*to be desperately accurate or anything! I advise aginst zooming in on      *
*any of the fractals! You're better off with a proper floating point routine*
* *or* a fixed point routine running to a higher accuracy!                  *
*                                                                           *
*****************************************************************************

    SECTION YUMYUM,CODE_C
	INCLUDE	Source:include/HARDWARE.I			; Hw equates
	INCLUDE	Source:p.kent/MYMACROS.I			; Blitwait,catchVB etc
	INCLUDE	Source:p.kent/HWSTART.S			; HW start-up code, calls _BOOT
	INCLUDE	Source:p.kent/LOADPOINTERS.S		; Insert bitplanes in copper
	INCLUDE	Source:p.kent/FADE.S				; FADER CALL
RASTERCHECK =   0 					; 1 FOR TIMING BACKGROUND, 0 BLACK.
MUSIC	=	1						; 1 FOR MUSIC!
****************************
*     SCREEN SIZES         *
****************************
;SCREEN IS 352 ($2C WIDB), 268 HGT
NPL = 5
PLWIDW = 22
PLWIDB = PLWIDW*2

PLHGT  = 268
PLLEN = PLWIDB*PLHGT


_BOOT
	LEA	CUSTOM,A6
	CATCHVB	A6	        			; Wait for VBL
	MOVE.W	#SETIT!DMAEN!BPLEN!BLTEN!COPEN,dmacon(A6)

	BSR	SetCopper					; Put in ptrs.
	IFNE	MUSIC
	JSR	Mt_init
	ENDC
;Other inits...
	MOVE.L	#MY_Copper,cop1lch(A6)	; Just set dma/ints and wait!
	MOVE.W	D0,COPJMP1(A6)
	MOVE.L	#MY_VBI,$6C.W
	MOVE.L	#(SETIT!INTEN!VERTB)*65536+$7FFF,intena(A6)
									; My ints + zap intreq!
LP
	MOVE.L	COLLIST,A0
	BSR	FADEME

	ADD.L	#32*2,COLLIST
	CMP.L	#COLLIST2_END,COLLIST
	BNE.S	colok
	MOVE.L	#COLLIST2,COLLIST
colok				
	BSR	ChaosBOX
	ADDQ.L	#4,BoxNo
	CMP.L	#BoxMax,BoxNo
	BNE.s	Chk
	MOVE.L	#0,BoxNo
Chk		MOUSE	LP

;Fade out copper list...
	LEA	FADECOLS,A0
	BSR	FADEME
	IFNE	MUSIC
	JSR	mt_end
	ENDC
	RTS	
 
 
MY_VBI
	MOVEM.L	D0-D7/A0-A6,-(SP)
	LEA	CUSTOM,A6
    IFNE    RASTERCHECK
    MOVE.W  #$300,$180(A6)
    ENDC

;Int code here...
	IFNE	MUSIC
	JSR	mt_MUSIC
	ENDC
;
    IFNE    RASTERCHECK
    MOVE.W  #0,$180(A6)
    ENDC

	MOVE.W	#INTEN!VERTB,intreq(A6)
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTE	

SetCopper
	Lea	Screen,a0
	Lea	Plptr1(pc),a1
	moveq	#npl,d1
	move.w	#plwidb,d2
	BSR	LoadPointers
	rts

FADEME					;A0 is ptr to cols!
FADEME_LP	
	SF	Faded			;Set faded sig in rt (0)
	LEA	COLPTR1(PC),A1
	MOVE.L	A0,A2		;A2=target cols work ptr
	MOVE.W	#32-1,D7	;Count
	CATCHVB	A6
FADEME_ILP
	MOVE.W	(A1),D0		;Fading value
	MOVE.W	(A2),D1		;Target colour
	CMP.W	D0,D1
	BEQ.S	FADEME_OK
	BSR	Fader			;Fade rt		
	ST	Faded			;Set faded sig in rt (-1)
FADEME_OK	
	MOVE.W	D0,(A1)
	ADDQ.L	#2,A2		;Next col
	ADDQ.L	#4,A1		;Next copper col
	DBRA	D7,FADEME_ILP
	TST.B	FADED
	BNE.S	FADEME_LP
	RTS
Faded	dc.b	-1
	even		
COLLIST	DC.L	COLLIST2
ColList2

;red>white
	dc.w	$e00,$e10,$d20,$c30,$b40,$a50,$a60,$a70
	dc.w	$a80,$a90,$aa0,$bb0,$cc0,$dd0,$ee0,$ff0
	dc.w	$ee0,$dd1,$cc2,$bb3,$aa4,$aa5,$aa6,$aa7
	dc.w	$aa8,$aa9,$aaa,$bbb,$ccc,$ddd,$eee,$fff

;black>red>white
	dc.w	$000,$100,$200,$300,$400,$500,$600,$700
	dc.w	$800,$900,$a00,$b00,$c00,$d00,$e00,$f00
	dc.w	$f01,$f11,$f22,$f33,$f44,$f55,$f66,$f77
	dc.w	$f88,$f99,$faa,$fbb,$fcc,$fdd,$fee,$fff
	
;blue>cyan>white
	dc.w	$00e,$1e,$2d,$3c,$4b,$5a,$6a,$7a
	dc.w	$8a,$9a,$aa,$bb,$cc,$dd,$ee,$ff
	dc.w	$ee,$1dd,$2cc,$3bb,$4aa,$5aa,$6aa,$7aa
	dc.w	$8aa,$9aa,$aaa,$bbb,$ccc,$ddd,$eee,$fff

;blue/magentaripples>
	dc.w	$000,$001,$101,$002,$202,$113,$313,$224
	dc.w	$424,$335,$535,$446,$646,$557,$757,$668
	dc.w	$868,$779,$979,$88a,$a8a,$99b,$b9b,$aac
	dc.w	$cac,$bbd,$dbd,$cce,$ece,$ddf,$fdf,$fef

;green>cyan>white
	dc.w	$e0,$e1,$d2,$c3,$b4,$a5,$a6,$a7
	dc.w	$a8,$a9,$aa,$bb,$cc,$dd,$ee,$ff
	dc.w	$0ee,$1dd,$2cc,$3bb,$4aa,$5aa,$6aa,$7aa
	dc.w	$8aa,$9aa,$aaa,$bbb,$ccc,$ddd,$eee,$fff
Collist2_end
	
MY_Copper
	dc.w	diwstrt,$2A71,diwstop,$36D1
	dc.w	ddfstrt,$30,ddfstop,$D8
	dc.w	bplcon0,$5200
	dc.w	bplcon1,0,bplcon2,0
	dc.w	bpl1mod,PLWIDB*(NPL-1),bpl2mod,PLWIDB*(NPL-1)

    IFEQ    RASTERCHECK
	dc.w	COLOR00
    ENDC
	IFNE	RASTERCHECK
	dc.w	COLOR01
	ENDC
ColPtr1
	dc.w	0,COLOR01,0,COLOR02,0,COLOR03,0,COLOR04,0
	DC.W	COLOR05,0,COLOR06,0,COLOR07,0,COLOR08,0
	DC.W	COLOR09,0,COLOR10,0,COLOR11,0,COLOR12,0
	DC.W	COLOR13,0,COLOR14,0,COLOR15,0,COLOR16,0
	DC.W	COLOR17,0,COLOR18,0,COLOR19,0,COLOR20,0
	DC.W	COLOR21,0,COLOR22,0,COLOR23,0,COLOR24,0
	DC.W	COLOR25,0,COLOR26,0,COLOR27,0,COLOR28,0
	DC.W	COLOR29,0,COLOR30,0,COLOR31,0

	dc.w	bpl1pth
Plptr1	dc.w	0,bpl1ptl,0
	dc.w	bpl2pth,0,bpl2ptl,0
	dc.w	bpl3pth,0,bpl3ptl,0
	dc.w	bpl4pth,0,bpl4ptl,0
	dc.w	bpl5pth,0,bpl5ptl,0
	dc.w	$FFFF,$FFFE

ConstReal	dc.w	0
ConstComp	dc.w	0

ImgPixelWid	dc.w	PLWIDB*8-1
ImgPixelHgt	dc.w	PLHGT-1

HorizStart	dc.l	-56100
HorizEnd	dc.l	56100
VertInit	dc.l	-56100
VertEnd		dc.l	56100

VertAdd	dc.w	0
VertAct	dc.w	0
BoxNo	dc.l	0

; Madel points for Julian FN
julianFX
	dc.w	-$fe,-$38
	dc.w	$63,-$40
	dc.w	$50,3
	dc.w	2,$B2
	dc.w	$10,$AB
	dc.w	$67,$32
	dc.w	-$37,$AA
	dc.w	-$fc,$4C
	dc.w	2,$FF
	dc.w	$4F,8
	dc.w	-$ca,$4B
	dc.w	-$ff,$58
BoxMax	=	*-JulianFX

; PLOT A BOX OF CHAOS!
; See Gleick (etc) for Julian iteration shell/full description of
; this sort of iteration.

; z->z^2+c for contant c
; Z=a+bj
;(a+bj)(a+bj)+c+dj=(a*a-b*b+c)+(2ab+d)j
ChaosBOX

	MOVE.L	HorizStart(PC),A3
	MOVE.L	HorizEnd(PC),D0
	SUB.L	A3,D0					;D0=dx
	DIVS	ImgPixelWid(PC),D0		;d0=horizontal increment
	MOVE.W	D0,A5					;a5=horiz increment (real)
	
	MOVE.L	VertEnd(PC),D0
	SUB.L	VertInit(PC),D0
	DIVS	ImgPixelHgt(PC),D0
	MOVE.W	D0,VertAdd				;VertAdd=Imaginary increment
; Desp base!
	LEA	SCREEN,A0
	LEA	julianFX(PC),A4
	ADD.L	BoxNo,A4
	MOVE.W	(A4),ConstReal			;CReal,CImaginary values
	MOVE.W	2(A4),ConstComp

	MOVE.W	#7,D4					; Init pixel pos start!

	MOVE.W	ImgPixelHgt(PC),D7		; Vertical loop count

VertLp

	MOVE.W	VertAdd(PC),D5
	MULS	D7,D5
	ADD.L	VertInit(PC),D5			
	ASR.L	#8,D5					; Round back down
	MOVE.W	D5,VertAct				; VertAct=VertAdd*VertPPos+VertInit
									; =complex position. CONST in horiz loop
	MOVE.W	ImgPixelWid(PC),D6		; Horizontal loop count
HorizLp

	MOVE.W	A5,D5					; Calc real position
	MULS	D6,D5
	ADD.L	A3,D5
	ASR.L	#8,D5					; HorizAct=HorizAdd*HorizPPos+HorizInit
									; Divided by 256

	MOVE.W	D5,D0
	MOVE.W	D5,A1
	ASR.W	#1,D0					; HorizAct/2
	ADD.W	D0,A1					; 3/2*HorizAct
	MULS	D0,D0					;
	ASR.W	#5,D0					; HorizAct^2
	MOVE.W	D0,A2
	MOVE.W	VertAct(PC),D0
	MOVE.W	D0,D3
	ASR.W	#1,D0
	ADD.W	D0,D3
	MULS	D0,D0
	
	ASR.W	#5,D0
	MOVE.W	D0,A4				;b^2 

	MOVEQ.L	#64,D2	; Max iter = 64  (2^(NPL+1)) (one extra power for extra
					; 'depth' to image/accuracy
; Main iteration loop....
IterAgain
	MOVE.W	A2,D0
	ADD.W	ConstReal(PC),D0	;a^2+c
	SUB.W	A4,D0				;a^2-b^2+c
	
	MOVE.W	A1,D1
	MULS	D3,D1				;ab
	ASR.L	#7,D1				;2ab due to fixed point
	ADD.W	ConstComp(PC),D1	;2ab+d
	
	MOVE.W	D1,D3				;save new a+bj as a1,d3
	MOVE.W	D0,A1				
	
	MULS	D0,D0			
	ASR.L	#8,D0
	MOVE.W	D0,A2				;Save A2=A^2 for next calc
	MULS	D1,D1
	ASR.L	#8,D1
	MOVE.W	D1,A4				;a4=B^2 saved for next calc
	ADD.L	D1,D0				;A^2+B^2
	
	CMP.L	#$FDE8,D0			; Blown up ?
	BGE.S	BlownUP
	SUBQ.W	#1,D2				; Reached max iter ?
	BGT.S	IterAgain
BlownUP
	BTST	#6,$BFE001	
	BEQ	LeaveRt					; Check for mouse exit/abort!
	
; Plot D2 iters, d4 bit no. ,at (a0)
	NOT.B	D2					; Invert count to get set planes...
	
	BCLR	D4,(A0)				; WIPE PREVIOUS PIXELS!
	BCLR	D4,PLWIDB(A0)
	BCLR	D4,(PLWIDB*2)(A0)
	BCLR	D4,(PLWIDB*3)(A0)
	BCLR	D4,(PLWIDB*4)(A0)
	
	BTST	#1,D2					; Set pixels in display according to iter
									; count.. (skipping bit 0!)
	BEQ.S	NoPl1
	BSET	D4,(A0)
NoPl1
	BTST	#2,D2
	BEQ.S	NoPl2
	BSET	D4,PLWIDB(A0)
NoPl2
	BTST	#3,D2
	BEQ.S	NoPl3
	BSET	D4,(PLWIDB*2)(A0)
NoPl3
	BTST	#4,D2
	BEQ.S	NoPl4
	BSET	D4,(PLWIDB*3)(A0)
NoPl4
	BTST	#5,D2
	BEQ.S	NoPl5
	BSET	D4,(PLWIDB*4)(A0)
NoPl5

	SUBQ.W	#1,D4					; More bits to go!
	BGE.S	MoreBits
	ADDQ.L	#1,A0

	MOVE.W	#7,D4
MoreBits	DBRA	D6,HorizLp
	LEA	PLWIDB*(NPL-1)(A0),A0		; Next line. NB. Have already stepped
									; through 1 planes worth	
	DBRA	D7,VertLp				; Loop vert
LeaveRT
	RTS	
 

    SECTION	VIEWME,BSS_C
FADECOLS	DS.W	32				;32 cols of black
SCREEN      DS.B	NPL*PLLEN		;View planes

	IFNE	MUSIC
	SECTION	PLAY,CODE_C
	INCLUDE	Source:p.kent/PT11B-PLAY.S
MT_DATA	INCBIN Source:modules/MOD.music
	EVEN
	ENDC
		