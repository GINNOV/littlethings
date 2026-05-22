;
; ### DigiShow v 1.21 ###
;
; - Created 880305 by JM under title 'ShowIFF' -
;
;
; Kaaks!
;
; Bugs: None known.
;
;
; Edited:
;
; - 880306 by JM -> v1.00	- works.
; - 880306 by JM -> v1.01	- HAM works, too.
; - 880910 by JM -> v1.20	- code compressed, ermsgs removed.
; - 880912 by JM -> v1.21	- buffer size & delay moved to end of program
;
;

ChBODY		equ	'BODY'
ChCMAP		equ	'CMAP'
ChBMHD		equ	'BMHD'
ChFORM		equ	'FORM'
ChILBM		equ	'ILBM'
ChCAMG		equ	'CAMG'

		xref	_LVOOpenLibrary
		xref	_LVOCloseLibrary
		xref	_LVOOpen
		xref	_LVOClose
		xref	_LVOOutput
		xref	_LVORead
		xref	_LVOWrite
		xref	_LVODelay
		xref	_LVOAllocMem
		xref	_LVOFreeMem

		xref	_LVOOpenScreen
		xref	_LVOCloseScreen
		xref	_LVOLoadRGB4
		xref	_LVOWaitTOF


		include "JMPLibs.i"
		include "intuition.i"
		include	"com.i"

		BITDEF	MEM,PUBLIC,0
		BITDEF	MEM,CHIP,1
		BITDEF	MEM,FAST,2
		BITDEF	MEM,CLEAR,16
		BITDEF	MEM,LARGEST,17



colmap		movem.l	d2-d7/a2-a6,-(sp)	save regs
		move.l	a0,a4			start addr of cmd line
		clr.b	-1(a0,d0.l)		null-terminate it

		openlib Dos,cleanup		open Dos library
		openlib	Gfx,cleanup		open Graphics
		openlib	Intuition,cleanup	open Intuition

		move.l	BUFFER(pc),d0		this many bytes needed
		move.l	#MEMF_PUBLIC,d1		from RAM
		lib	Exec,AllocMem		ask for them
		move.l	d0,buffer		save start addr
		tst.l	d0			got memory?
		beq	cleanup			no, exit

		move.l	a4,d1			file to show
		move.l	#1005,d2		mode: read only
		lib	Dos,Open		open it
		move.l	d0,fileptr		save ptr
		beq	cleanup			no, exit

		bsr	Get4Bytes
		cmp.l	#ChFORM,d0
		bne	cleanup
FORMok		bsr	Get4Bytes
		cmp.l	BUFFER(pc),d0
		bhs	cleanup
LENok		bsr	Get4Bytes
		cmp.l	#ChILBM,d0
		bne	cleanup
ChunkLoop	bsr	Get4Bytes
		bcs	cleanup
		cmp.l	#ChCMAP,d0
		bne	Chunk1
		bsr	Get4Bytes	;length of colmap
		bsr	GetNBytes	;read color map
		lea	colmap(pc),a1
		moveq.l	#31,d2
CMAPloop	move.b	(a0)+,d0	get R value
		and.l	#$f0,d0
		move.l	d0,d1
		lsl.l	#4,d1
		move.b	(a0)+,d0	get G value
		and.b	#$f0,d0
		or.b	d0,d1
		move.b	(a0)+,d0	get B value
		lsr.l	#4,d0
		or.b	d0,d1
		move.w	d1,(a1)+	save color values into table
		dbf	d2,CMAPloop
		bra	ChunkLoop

Chunk1		cmp.l	#ChBMHD,d0
		bne	Chunk2
		bsr	GetBMHD
		bcs	cleanup
		bra	ChunkLoop

Chunk2		cmp.l	#ChCAMG,d0
		bne	Chunk3
		bsr	Get4Bytes	must be one LONG
		bsr	GetNBytes
		move.l	(a0),CAmg	save CAMG data
		bra	ChunkLoop

Chunk3		cmp.l	#ChBODY,d0
		beq	Chunk4

		; unknown chunk

		bsr	Get4Bytes
		bsr	GetNBytes
		bra	ChunkLoop

Chunk4		; read body

		bsr	Get4Bytes
		move.l	d0,d3
		move.l	buffer(pc),d2
		move.l	fileptr(pc),d1
		lib	Dos,Read
		lea	picscreen(pc),a0
		move.b	nPlanes(pc),ns_Depth+1(a0)
		moveq.l	#0,d0
		cmp.w	#320,RasX
		ble	Chunk42
		or.w	#V_HIRES,d0
Chunk42		cmp.w	#256,RasY
		ble	Chunk43
		or.w	#V_LACE,d0
Chunk43		or.w	CAmg+2(pc),d0
		move.w	d0,ns_ViewModes(a0)
		lib	Intuition,OpenScreen	open screen
		move.l	d0,screen		save ptr
		beq	cleanup
		move.l	d0,a4			find out the address
		lea	sc_ViewPort(a4),a0	of ViewPort in
		lea	colmap(pc),a1		addr of colormap
		moveq.l	#32,d0			32 colors to set
		lib	Gfx,LoadRGB4		DO!

		lea	sc_BitMap+bm_Planes(a4),a6 screen->BitMap.Planes
		bsr	UnCompress

		move.l	DELAY(pc),d7
delayloop	lib	Gfx,WaitTOF
		leftmouse
		dbeq	d7,delayloop

		move.l	screen(pc),d0
		beq	cleanup
		move.l	d0,a0
		lib	Intuition,CloseScreen

cleanup		move.l	fileptr(pc),d1		if file open close it
		beq	clean10
		lib	Dos,Close

clean10		move.l	buffer(pc),d0		if mem reserved release it
		beq	clean11
		move.l	d0,a1
		move.l	BUFFER(pc),d0
		lib	Exec,FreeMem
clean11		closlib	Intuition		close libraries
		closlib	Gfx
		closlib	Dos

		movem.l	(sp)+,d2-d7/a2-a6
		rts


Get4Bytes	movem.l	d1-d3/a0/a1,-(sp)
		move.l	fileptr(pc),d1
		move.l	#smallbuf,d2
		move.l	#4,d3
		lib	Dos,Read
		move.l	smallbuf(pc),d0
		movem.l	(sp)+,d1-d3/a0/a1
		rts


GetNBytes	movem.l	d1-d3/a1,-(sp)
		move.l	fileptr(pc),d1
		move.l	buffer(pc),d2
		move.l	d0,d3
		lib	Dos,Read
		move.l	d2,a0
		movem.l	(sp)+,d1-d3/a1
		rts


GetBMHD		movem.l	d0/a0,-(sp)
		bsr	Get4Bytes
		bsr	GetNBytes
		move.w	(a0),RasX
		move.w	2(a0),RasY
		move.b	8(a0),nPlanes
		cmp.b	#1,10(a0)		; Compressing method
		bne	GetBMHDer
		cmp.w	#640,RasX
		bhi	GetBMHDer
		cmp.w	#512,RasY
		bhi	GetBMHDer
		cmp.b	#4,nPlanes
		bls	GetBMHD4
		cmp.w	#320,RasX
		bhi	GetBMHDer
		cmp.b	#6,nPlanes
		bls	GetBMHD4
GetBMHDer	setc
		bra	GetBMHD5
GetBMHD4	clrc
GetBMHD5	movem.l	(sp)+,d0/a0
		rts


UnCompress	move.l	buffer(pc),a0	source
		move.l	#0,d7		counts raster line 0...RasY
		move.l	#0,d6		holds bytes per row
		move.w	RasX(pc),d6
		move.w	RasY(pc),a2	for loop end value
		addq.w	#7,d6
		lsr.w	#3,d6
		move.b	nPlanes(pc),d2	for loop end value

NxRow		moveq.l	#0,d4		planenum
		move.l	a6,a5		ptr to plane ptr
		move.w	d7,d5
		mulu.w	d6,d5
NxPlane		addq.w	#1,d4		incr plane
		move.l	d5,a1		BytesPerRow * k16
		add.l	(a5)+,a1	... + hires[planenum]
		moveq.l	#0,d3		bytecount
NxByte		moveq.l	#0,d0
		move.b	(a0)+,d0	get one byte
		bmi	Negative
		add.l	d0,d3		add new bytes
		addq.l	#1,d3
Identical	move.b	(a0)+,(a1)+
		dbf	d0,Identical
		bra	NxBlk
Negative	move.b	(a0)+,d1	duplicate one byte
		neg.b	d0
		add.l	d0,d3		add new bytes
		addq.l	#1,d3
Duplicate	move.b	d1,(a1)+
		dbf	d0,Duplicate
NxBlk		cmp.w	d6,d3
		blt	NxByte
		cmp.b	d2,d4
		blt	NxPlane
		addq.w	#1,d7
		cmp.w	a2,d7
		blt	NxRow
		rts


		libnames

picscreen				;uninitialized screen structure
		dc.w	0,0		;left, top edge
RasX		dc.w	320		;width
RasY		dc.w	20		;height
		dc.w	0		;depth
		dc.b	0,1		;bg,fg
		dc.w	0		;viewmodes
		dc.w	$000f		;type custom
		dc.l	0		;textattr
		dc.l	0		;title
		dc.l	0		;gadgets
screen		dc.l	0		;custom bitmap

fileptr		dc.l	0
buffer		dc.l	0
smallbuf	ds.l	2
nPlanes		dc.w	0
CAmg		dc.l	0
BUFFER		dc.l	100000
DELAY		dc.l	500


		end

