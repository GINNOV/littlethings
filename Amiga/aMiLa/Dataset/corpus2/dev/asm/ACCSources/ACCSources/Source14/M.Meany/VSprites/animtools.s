
; This file contains assembler equivalents of the C files found in the ROM
;Kernel Reference Manual. I have only a limited knowledge of C, so a few
;bits may be my own improvisations! M.Meany June 1991

; If you use these routines and find a bug, please report it to me. I would
;like to update this file, keeping it as error free as possible.

;		M.Meany,
;		1 Cromwell Road,
;		Southampton,
;		Hant's.
;		SO1 2JH

; Files included:	GELTOOLS_H		<part>
;			animtools.c		<part>

; Defined Structures :	NewVSprite, NewBob

; Defined Subroutines:	GelsInfo=SetUpGelSys( RastPort, SprRsvd )
;			  d0			 a0	   d0

;			CleanUpGelSys( RastPort )
;					  a0

;			VSprite=MakeVSprite( NewVSprite )
;			  d0			a0

;			FreeVSprite( VSprite )
;					a0

;			Bob=MakeBob( NewVSprite )
;			d0 		a0

;			FreeBob( Bob, RasterDepth )
;				 a0	  d0


; From C routines printed in R.K.M Libraries and Devices, Addison & Wesley.
; Assembly interpretation by M.Meany, June 1991.

******************* GELTOOLS_H

; Some equates missing from the assembler include files. I looked these up
;in the C header files in the Includes & Autodocs RKM book. MM.

BORDERHIT	equ	0
TOPHIT		equ	1
BOTTOMHIT	equ	2
LEFTHIT		equ	4
RIGHTHIT	equ	8


; Structure defenitions for an easier ( ??? ) interface with the GELS system.

;NewVSprite structure

		rsreset
nvs_Image	rs.l		1		addr of image data (in CHIP)
nvs_ColourSet	rs.l		1		addr of colour array
nvs_WordWidth	rs.w		1		width of image (words)
nvs_LineHeight	rs.w		1		height of image (scan lines)
nvs_ImageDepth	rs.w		1		depth of image
nvs_X		rs.w		1		Initial X position
nvs_Y		rs.w		1		Initial Y position
nvs_Flags	rs.w		1		VSpriteFlags
nvs_SizeOf	rs.w		0		structure size

;NewBob structure

		rsreset
nb_Image	rs.l		1		addr of image data (CHIP)
nb_WordWidth	rs.w		1		width of bob in words
nb_LineHeight	rs.w		1		height of bob in lines
nb_ImageDepth	rs.w		1		depth of image
nb_PlanePick	rs.b		1		planes to put image in
nb_PlaneOnOff	rs.b		1		what to to with unused planes
nb_BFlags	rs.w		1		bob flags
nb_DBuf		rs.w		1		1=double buffer 0=not
nb_RasDepth	rs.w		1		depth of dest raster
nb_X		rs.w		1		initial X position
nb_Y		rs.w		1		initial Y position
nb_SizeOf	rs.w		0		structure size

******************* Animtools.c

;-------------- Set up the system !

; Entry		a0 must hold the address of an initialised rastport
;		d0 must contain reserved sprite mask

; Exit		d0 will contain the address of the initialised GelsInfo
;		   structure, or 0 if a memory allocation error occurred.

SetUpGelSys	move.l		d0,d7			save reserved mask
		move.l		a0,a4			save rp pointer

		move.l		#gi_SIZEOF,d0		structure size
		move.l		#MEMF_CLEAR,d1		requirements
		CALLEXEC	AllocMem		and get some memory
		move.l		d0,a5			store addr of mem
		beq		.error1			quit if error

		moveq.l		#16,d0			size of matrix
		move.l		#MEMF_CLEAR,d1		requirements
		CALLSYS		AllocMem		and get some memory
		move.l		d0,gi_nextLine(a5)	save it's address
		beq		.error2			quit if error

		moveq.l		#32,d0			size of matrix
		move.l		#MEMF_CLEAR,d1		requirements
		CALLSYS		AllocMem		and get some memory
		move.l		d0,gi_lastColor(a5)	save it's address
		beq		.error3			quit if error

		moveq.l		#16*4,d0		size of collTable
		move.l		#MEMF_CLEAR,d1		requirements
		CALLSYS		AllocMem		and get mem
		move.l		d0,gi_collHandler(a5)	save it's address
		beq		.error4			quit if error

		move.l		#vs_SIZEOF,d0		size
		move.l		#MEMF_CLEAR,d1		req
		CALLSYS		AllocMem		get mem
		move.l		d0,__Head		save it
		beq		.error5			quit if error

		move.l		#vs_SIZEOF,d0		size
		move.l		#MEMF_CLEAR,d1		req
		CALLSYS		AllocMem		get mem
		move.l		d0,__Tail		save it
		beq		.error6			quit if error

		move.b		d7,gi_sprRsrvd(a5)	save sprite mask
		move.w		#0,gi_leftmost(a5)	set left border
		move.l		a4,a1
		move.l		rp_BitMap(a1),a1
		move.w		bm_BytesPerRow(a1),d0	get display width
		asl.w		#3,d0
		subq.w		#1,d0
		move.w		d0,gi_rightmost(a5)	set right border
		move.w		#0,gi_topmost(a5)	set top border
		move.w		bm_Rows(a1),d0
		subq.w		#1,d0
		move.w		d0,gi_bottommost(a5)	set bottom border
		move.l		a5,rp_GelsInfo(a4)	link gi_ to rp_

		move.l		__Head,a0
		move.l		__Tail,a1
		move.l		a5,a2
		CALLGRAF	InitGels
	
		move.l		a5,d0			set d0=GelsInfo
		bra		.error1			all done so return

.error6		move.l		__Head,a1		addr of mem
		move.l		vs_SIZEOF,d0		size
		CALLSYS		FreeMem			and release it

.error5		move.l		gi_collHandler(a5),a1	addr of mem
		moveq.l		#16*4,d0	   	size
		CALLSYS		FreeMem		   	and release it

.error4		move.l		gi_lastColor(a5),a1	addr of mem
		moveq.l		#32,d0		  	size
		CALLSYS		FreeMem		  	and release it

.error3		move.l		gi_nextLine(a5),a1	addr of mem
		moveq.l		#16,d0			size
		CALLSYS		FreeMem			and release it

.error2		move.l		a5,a1			addr of mem
		move.l		#gi_SIZEOF,d0		size
		CALLSYS		FreeMem			and release it

		moveq.l		#0,d0			ERROR !

.error1		rts					and return

__Head		dc.l		0
__Tail		dc.l		0

;-------------- Clean up system after a call to SetUpGelSys

; Entry		a0 must hold address of RastPort structure as sent to
;		   SetUpGelSys subroutine.

CleanUpGelSys	move.l		rp_GelsInfo(a0),d0	get addr of gelsinfo
		beq		.done			quit if not assigned

		move.l		#0,rp_GelsInfo(a0)	break the link
		move.l		d0,a5			save addr of gi_

		move.l		gi_gelTail(a5),a1	addr of mem
		move.l		#vs_SIZEOF,d0		size
		CALLEXEC	FreeMem			and release it

		move.l		gi_gelHead(a5),a1	addr of mem
		move.l		#vs_SIZEOF,d0		size
		CALLSYS		FreeMem			and release it

		move.l		gi_collHandler(a5),a1	addr of mem
		moveq.l		#16*4,d0	   	size
		CALLSYS		FreeMem		   	and release it

		move.l		gi_lastColor(a5),a1	addr of mem
		moveq.l		#32,d0		  	size
		CALLSYS		FreeMem		  	and release it

		move.l		gi_nextLine(a5),a1	addr of mem
		moveq.l		#16,d0			size
		CALLSYS		FreeMem			and release it

		move.l		a5,a1			addr of mem
		move.l		#gi_SIZEOF,d0		size
		CALLSYS		FreeMem			and release it

.done		rts					and return


;--------------	Create a VSprite from info in NewVSprite structure.

; Entry		a0 must hold the address of an initialised NewVSprite
;		   structure.

; Exit		d0 will hold the address of the VSprite structure created
;		   or 0 if a memory allocation error occurred.

MakeVSprite	moveq.l		#0,d0
		move.l		d0,__LineSize		clear internal var
		move.l		d0,__PlaneSize		clear internal var

		move.l		a0,a5			get copy of pointer

		move.w		nvs_WordWidth(a5),d0	width of sprite
		asl.w		#1,d0			x2
		move.l		d0,__LineSize		and store

		mulu.w		nvs_LineHeight(a5),d0  	xheight
		move.l		d0,__PlaneSize		and store

		move.l		#vs_SIZEOF,d0		mem size
		move.l		#MEMF_CLEAR,d1		requirements
		CALLEXEC	AllocMem		get memory
		move.l		d0,a4			store it
		tst.l		d0			check error
		beq		.error1			quit if error

		move.l		__LineSize,d0		get mem size
		move.l		#MEMF_CHIP!MEMF_CLEAR,d1 requirements
		CALLSYS		AllocMem		get memory
		move.l		d0,vs_BorderLine(a4) 	and store it
		beq		.error2

		move.l		__PlaneSize,d0		get mem size
		move.l		#MEMF_CHIP!MEMF_CLEAR,d1 requirements
		CALLSYS		AllocMem		get memory
		move.l		d0,vs_CollMask(a4) 	and store it
		beq		.error3

		move.w		nvs_X(a5),vs_X(a4)
		move.w		nvs_Y(a5),vs_Y(a4)
		move.w		nvs_Flags(a5),vs_VSFlags(a4)
		move.w		nvs_WordWidth(a5),vs_Width(a4)
		move.w		nvs_LineHeight(a5),vs_Height(a4)
		move.w		nvs_ImageDepth(a5),vs_Depth(a4)
		move.w		#1,vs_MeMask(a4)
		move.w		#1,vs_HitMask(a4)
		move.l		nvs_Image(a5),vs_ImageData(a4)
		move.l		nvs_ColourSet(a5),vs_SprColors(a4)
		move.w		#0,vs_PlanePick(a4)

		move.l		a4,a0
		CALLGRAF	InitMasks

		move.l		a4,d0
		bra		.error1

.error3		move.l		vs_BorderLine(a4),a1	mem
		move.l		__LineSize,d0		size
		CALLSYS		FreeMem			release it

.error2		move.l		a4,a1			mem
		move.l		#vs_SIZEOF,d0		size
		CALLSYS		FreeMem			release it

		moveq.l		#0,d0			ERROR !

.error1		rts

__LineSize	dc.l		0
__PlaneSize	dc.l		0

;--------------	Free memory reserved by MakeVSprite.

; Entry		a0 must hold the address of the VSprite structure as
;		   returned by MakeVSprite.

FreeVSprite	moveq.l		#0,d0
		move.l		d0,__LineSize		clear internal var
		move.l		d0,__PlaneSize		clear internal var

		move.l		a0,a5			get copy of pointer

		move.w		vs_Width(a5),d0 	width of sprite
		asl.w		#1,d0			x2
		move.l		d0,__LineSize		and store

		mulu.w		vs_Height(a5),d0  	xheight
		move.l		d0,__PlaneSize	       	and store

		move.l		vs_BorderLine(a5),a1	mem
		move.l		__LineSize,d0		size
		CALLEXEC	FreeMem			and release it

		move.l		vs_CollMask(a5),a1	mem
		move.l		__PlaneSize,d0		size
		CALLSYS		FreeMem			and release it

		move.l		a5,a1			mem
		move.l		#vs_SIZEOF,d0		size
		CALLSYS		FreeMem			and release it

		rts

;--------------	Create a Bob from info in NewBob structure.

; Allocates memory for double buffering if required. Sets up a VSprite for 
;the bob.

; Entry		a0 must hold the address of an initialised NewBob structure.

; Exit		d0 will hold the address of the Bob structure created.
;		   or 0 if a memory allocation error occurred.

; Should be ok to use mulu here as feasably the largest bob anyone would
;want to display would be 40x256x5 (width x height x depth ) which gives
;a grand total of 51200. This value can be contained in a single word.

MakeBob		moveq.l		#0,d0
		move.w		nb_WordWidth(a0),d0	d0=width
		mulu.w		nb_LineHeight(a0),d0	x height
		mulu.w		nb_RasDepth(a0),d0	x height x depth
		asl.l		#1,d0			x2
		move.l		d0,__RasSize		and store it

		move.l		a0,a5			a5->NewBow

		move.l		#bob_SIZEOF,d0		bytesize
		move.l		#MEMF_CLEAR,d1		requirements
		CALLEXEC	AllocMem		get mem
		tst.l		d0			all ok
		beq		.error			quit if error

		move.l		d0,a4			a4->Bob

		move.l		__RasSize,d0		bytesize
		move.l		#MEMF_CHIP!MEMF_CLEAR,d1 requirements
		CALLSYS		AllocMem		get mem
		move.l		d0,bob_SaveBuffer(a4)	store pointer
		beq		.error1

		lea		__NewVSprite,a0		ptr to temp struct

; Build up a NewVSprite structure for this bob

		move.w		nb_WordWidth(a5),nvs_WordWidth(a0)
		move.w		nb_LineHeight(a5),nvs_LineHeight(a0)
		move.w		nb_ImageDepth(a5),nvs_ImageDepth(a0)
		move.l		nb_Image(a5),nvs_Image(a0)
		move.w		nb_X(a5),nvs_X(a0)
		move.w		nb_Y(a5),nvs_Y(a0)
		move.l		#0,nvs_ColourSet(a0)
		move.w		nb_BFlags(a5),nvs_Flags(a0)

		move.l		a4,-(sp)		save Bob ptr
		move.l		a5,-(sp)		save NewBob ptr

		bsr		MakeVSprite		get a VSprite

		move.l		(sp)+,a5		restore NewBob ptr
		move.l		(sp)+,a4		restore Bob ptr
		tst.l		d0			got a VSprite ?
		beq		.error2			quit if not

		move.l		d0,a3			a3->VSprite

; Fill in the VSprite and Bob structures and link them

		move.b		nb_PlanePick(a5),vs_PlanePick(a3)
		move.b		nb_PlaneOnOff(a5),vs_PlaneOnOff(a3)

		move.l		a4,vs_VSBob(a3)
		move.l		a3,bob_BobVSprite(a4)

		move.l		vs_CollMask(a3),bob_ImageShadow(a4)
		moveq.l		#0,d0
		move.w		d0,bob_BobFlags(a4)
		move.l		d0,bob_Before(a4)
		move.l		d0,bob_After(a4)
		move.l		d0,bob_BobComp(a4)

		tst.w		nb_DBuf(a5)
		bne		.double_buffer
		move.l		#0,bob_DBuffer(a4)
		bra		.done

.double_buffer	move.l		#dbp_SIZEOF,d0		bytesize
		move.l		#MEMF_CLEAR,d1		requirements
		CALLEXEC	AllocMem		get mem
		move.l		d0,bob_DBuffer(a4)	save pointer
		beq		.error3

		move.l		d0,a5			save pointer

		move.l		__RasSize,d0		bytesize
		move.l		#MEMF_CHIP!MEMF_CLEAR,d1 requirements
		CALLSYS		AllocMem		get mem
		move.l		d0,dbp_BufBuffer(a5)	save pointer
		beq		.error4

.done		move.l		a4,d0			d0=addr of Bob
		rts					and return

; Error handaling routine. Register a4 still points to the Bob structure.

.error4		move.l		bob_DBuffer(a4),a1	mem
		move.l		#dbp_SIZEOF,d0		size
		CALLSYS		FreeMem			and free it

.error3		move.l		a4,-(sp)		save pointer
		move.l		bob_BobVSprite(a4),a0	a0->VSprite
		bsr		FreeVSprite		and free it
		move.l		(sp)+,a4		restore pointer

.error2		move.l		bob_SaveBuffer(a4),a1	mem
		move.l		__RasSize,d0		size
		CALLEXEC	FreeMem			and free it

.error1		move.l		a4,a1			mem
		move.l		#bob_SIZEOF,d0		size
		CALLSYS		FreeMem			and free it

.error		moveq.l		#0,d0			set error flag
		rts

__RasSize	dc.l		0
__NewVSprite	ds.b		nvs_SizeOf

;--------------	Free a Bob structure set up by calling MakeBob

; Entry		a0 must hold the address of the bob structure allocated by
;		   MakeBob

;		d0 must hold the raster depth of the display. This should
;		   be the same value as passed in the NewBob structure to
;		   MakeBob.

FreeBob		move.l		a0,a4			get copy of ptr

		move.l		bob_BobVSprite(a4),a0	a0->VSprite

		mulu.w		vs_Width(a0),d0		x width
		mulu.w		vs_Height(a0),d0	x height
		asl.l		#1,d0			x2
		move.l		d0,__RasSize		and save value

		tst.l		bob_DBuffer(a4)		double buffered?
		beq.s		.not_DB			jump if not

		move.l		bob_DBuffer(a4),a3	a3->dbp struct

		move.l		dbp_BufBuffer(a3),a1	mem
		move.l		__RasSize,d0		size
		CALLEXEC	FreeMem			and free it

		move.l		a3,a1			mem
		move.l		#dbp_SIZEOF,d0		size
		CALLSYS		FreeMem			and free it

.not_DB		move.l		bob_SaveBuffer(a4),a1	mem
		move.l		__RasSize,d0		size
		CALLEXEC	FreeMem			and free it

		move.l		bob_BobVSprite(a4),a0	a0->VSprite
		move.l		a4,-(sp)

		bsr		FreeVSprite		and free it

		move.l		(sp)+,a1		mem
		move.l		#bob_SIZEOF,d0		size
		CALLEXEC	FreeMem			and free it

		rts

