שתשתÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ**
**	disk-boot
**
**

Start		EQU	$20000
LoadPTR		EQU	$90000
AllocSize	EQU	600000
BegSect		EQU	2
Length		EQU	226

	INCDIR	INCLUDES:
	INCLUDE	HARDWARE/DMABITS.i

Debut	Dc.B	'DOS',0
	Dc.L	0
	Dc.L	880

	Lea	$dff000,a0
	Move	#DMAF_RASTER+DMAF_COPPER,$96(a0)
	Clr	$180(a0)

;----
;----

	Move.L	4.w,a6
	Lea	Start,a1
	Move.L	#AllocSize,d0
	Jsr	-204(a6)
	Move.L	d0,-(sp)
	Beq.W	Error

	Lea	Start,a1
	Move.L	#AllocSize,d0
ClrLoop	Clr.L	(a1)+
	Clr.L	(a1)+
	Subq.L	#8,d0
	Blt.B	ClrLoop

;----
;----

	Move.L	4.w,a6
	Sub.L	a1,a1
	Jsr	-294(a6)

	Move.L	4.w,a6
	Lea	MsgPort(pc),a1	
	Move.L	d0,16(a1)
	Jsr	-354(a6)

	Move.L	4.w,a6			
	Lea	DiskDevice(pc),a0
	Lea	IORequest(pc),a1
	Lea	MsgPort(pc),a2
	Move.L	a2,14(a1)	
	Moveq	#0,d0
	Moveq	#0,d1
	Jsr	-444(a6)
	Tst.L	d0
	Bne.B	Error

	Move.L	4.w,a6
	Lea	IORequest(pc),a1
	Move	#2,28(a1)			; read mode
	Move.L	#BegSect*512,44(a1)		; start
	Move.L	#Length*512,36(a1)		; nbr sect
	Move.L	#LoadPTR,40(a1)			; dest
	Jsr	-456(a6)
	Tst.L	d0	
	Bne.B	Error

	Jmp	LoadPTR

Loop	Bra.B	Loop

Error	Move	#$f00,$dff180
	Bra.B	Error

IORequest	Ds.B	44
MsgPort		Ds.B	40
MyTask		Ds.L	1
DiskDevice	Dc.B	"trackdisk.device",0
Text		Dc.B	'!!!   This is LTP4 Party-Megademo bootblock   !!!'

Fin

		Blk.B	1024
