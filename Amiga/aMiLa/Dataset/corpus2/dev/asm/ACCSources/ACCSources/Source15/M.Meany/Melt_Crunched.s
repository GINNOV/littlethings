
; Screen melt -- idea from RSI. Copper list typed in full for clarity!

; This version uses a raw data file crunched using the cruncher that I've
;also put on this disc. The decrunch subroutine is straightforward enough.

; Colour map must be infront of bpl data ( ie. cmap before ).

; M.Meany, July 1991.


		opt		c-

		include		sys:include/exec/exec_lib.i
		include		source:include/hardware.i

;--------------	Decrunch the gfx

		lea		crunched_gfx,a0		addr of crunched data
		lea		Picture,a1		destination memory
		bsr		DeCrunch		decrunch it


		lea		$dff000,a5	Offset for hardware registers

;--------------	Set up Copper List, 1st bit plane pointers then colour reg.

; This code assumes the colour map is before the raw bpl data.

		lea		Picture,a0	a0-> colour data
		lea		Colours,a1	a1-> into Copper List
		move.w		#$180,d0	d0=colour reg offset
		moveq		#31,d1		d1=num of colours - 1

Colloop		move.w		d0,(a1)+	reg offset into list
		move.w		(a0)+,(a1)+	colour value into list
		addq.w		#2,d0		offset of next reg
		dbra		d1,Colloop	repeat for all registers

		bsr		PutPlanes	put plane addrs into Copper

;--------------	Get addr of current Copper List and save it

		lea		Gfxname,a1	library name
		moveq		#0,d0		any version
		CALLEXEC	OpenLibrary	and open it
		tst.l		d0		all ok ?
		beq		quit_fast	if not quit
		move.l		d0,a1		base ptr int a1
		move.l		38(a1),Old	Save old copper address
		CALLEXEC	CloseLibrary	Close graphics library

;--------------	Activate our Copper List

		CALLEXEC	Forbid		disable multitasking
		move.w		#$0020,dmacon(a5) Disable sprites
		move.l		#Newcop,cop1lch(a5)  Insert new copper data

;--------------	Init the loop

		move.l		#200,d5		loop counter
		moveq.l		#0,d4		clear register
		moveq.l		#1,d0		set flag
		lea		playcon,a4	a4 points into copper list
		lea		6(a4),a4	a4->modulo value

;--------------	Wait for Vert blank
 
Wait		cmpi.b		#$f0,$dff006	VBL
		bne.s		Wait

		neg.l		d0
		bmi.s		Wait

;--------------	Build the screen

		move.w		d4,(a4)		reset lines modulo
		lea		4(a4),a4	bump to next modulo
		move.w		d4,(a4)		reset even line modulo
		lea		8(a4),a4	bump to next modulo
		subq.l		#1,d5		dec counter
		bne.s		Wait		loop if not finished

Wait1		btst		#6,CIAAPRA	LMB pressed ?
		bne.s		Wait1		loop back if not

		lea		constop+2,a0	a0->last modulo value
		move.l		#199,d1		line counter
		move.w		#-40,d0		new modulo
		moveq.l		#1,d2		flip flop

;-------------- Destroy the screen

Wait2		cmpi.b		#$f0,$dff006	VBL
		bne.s		Wait2

		neg.w		d2
		bmi.s		Wait2

		move.w		d0,(a0)
		move.w		d0,4(a0)
		lea		-12(a0),a0	next line
		dbra		d1,Wait2


;--------------	Restore original Copper List

		move.l		Old,cop1lch(a5)	Restore copper
		move.w		#$83e0,dmacon(a5) Restore DMA channel

;--------------	And finish

quit_fast
		CALLEXEC	Permit		Restore multi-tasking
		rts				Exit


;--------------	Routine to plonk bitplane pointers into copper list

; This subroutine sets up planes for a 320x200x5 display, but only
;requires minor mods to work for any size display!

;Entry		a0=start address of bitplane

;Corrupted	d0,d1,d2,a0

PutPlanes	moveq.l		#4,d0		num of planes -1
		move.l		#(320/8)*256,d1	size of each bitplane
		move.l		a0,d2		d2=addr of 1st bitplane
		lea		CopPlanes,a0	a0-> into Copper List
.PlaneLoop	swap		d2		get high part of addr
		move.w		d2,(a0)		put in Copper List
		lea		4(a0),a0	point to next pos in list
		swap		d2		get low part of addr
		move.w		d2,(a0)		put in Copper List
		lea		4(a0),a0	point to next pos in list
		add.l		d1,d2		point to next plane
		dbra		d0,.PlaneLoop	repeat for all planes
		rts


; ByteRun decrunch algorithm. For ArtWerk by M.Meany, July 1991.

; The 1st long word of a crunched data block is the length of the block
;when decrunched. It is up to you to allocate memory for the decrunched
;data. This is not a problem if you have crunched a series of graphics
;that all fit into the same size display as only one block need be obtained.

; Entry		a0->Crunched Data
;		a1->Memory to decrunch into

DeCrunch	lea		4(a0),a0	a0->data

.outer		tst.w		(a0)		end of crunched data ?
		beq		.done		if so quit

		move.b		(a0)+,d0	get value

		move.w		d0,$dff180	change color0 

		moveq.l		#0,d1		clear register
		move.b		(a0)+,d1	and count
		subq.l		#1,d1		adjust for dbra

.inner		move.b		d0,(a1)+	copy next byte
		dbra		d1,.inner	count times

		bra		.outer		go back for more

.done		rts				all decrunched


;--------------	DATA SECTION


Gfxname 
 dc.b "graphics.library",0   Pointer for library
 even


crunched_gfx	 Incbin "source:bitmaps/bum_crunched"     Calls the raw data from disk 

		section mm,data_c

;--------------	The Copper list itself. I have added comments before each
;		section.

; First set up the display.

Newcop                   
		dc.w diwstrt,$2c81	Top left of screen
		dc.w diwstop,$f4c1	Bottom right of screen - NTSC ($2cc1 for PAL)
		dc.w ddfstrt,$38	Data fetch start
		dc.w ddfstop,$d0	Data fetch stop
		dc.w bplcon0,$4200	Select lo-res 16 colour 
		dc.w bplcon1,0		No horizontal offset

; Reserve space to set up colour registers

Colours		ds.w 64			Space for 32 colour registers 
 
; Now set all plane pointers

		dc.w	bpl1pth		Plane pointers for 4 planes          
CopPlanes	dc.w	0,bpl1ptl          
		dc.w	0,bpl2pth
		dc.w	0,bpl2ptl
		dc.w	0,bpl3pth
		dc.w	0,bpl3ptl
		dc.w	0,bpl4pth
		dc.w	0,bpl4ptl
		dc.w	0,bpl5pth
		dc.w	0,bpl5ptl
		dc.w	0

; Now the 'wobbly' bit.

playcon		dc.w	$2c09,$fffe			wait 0,44 line 1
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$2d09,$fffe			wait 0,45 line 2
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$2e09,$fffe			wait 0,46 line 3
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$2f09,$fffe			wait 0,46 line 4
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$3009,$fffe			wait 0,44 line 5
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$3109,$fffe			wait 0,45 line 6
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$3209,$fffe			wait 0,46 line 7
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$3309,$fffe			wait 0,46 line 8
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$3409,$fffe			wait 0,44 line 9
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$3509,$fffe			wait 0,45 line 10
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$3609,$fffe			wait 0,46 line 11
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$3709,$fffe			wait 0,46 line 12
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$3809,$fffe			wait 0,44 line 13
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$3909,$fffe			wait 0,45 line 14
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$3a09,$fffe			wait 0,46 line 15
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$3b09,$fffe			wait 0,46 line 16
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$3c09,$fffe			wait 0,44 line 17
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$3d09,$fffe			wait 0,45 line 18
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$3e09,$fffe			wait 0,46 line 19
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$3f09,$fffe			wait 0,46 line 20
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$4009,$fffe			wait 0,44 line 21
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$4109,$fffe			wait 0,45 line 22
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$4209,$fffe			wait 0,46 line 23
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$4309,$fffe			wait 0,46 line 24
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$4409,$fffe			wait 0,44 line 25
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$4509,$fffe			wait 0,45 line 26
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$4609,$fffe			wait 0,46 line 27
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$4709,$fffe			wait 0,46 line 28
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$4809,$fffe			wait 0,44 line 29
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$4909,$fffe			wait 0,45 line 30
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$4a09,$fffe			wait 0,46 line 31
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$4b09,$fffe			wait 0,46 line 32
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$4c09,$fffe			wait 0,44 line 33
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$4d09,$fffe			wait 0,45 line 34
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$4e09,$fffe			wait 0,46 line 35
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$4f09,$fffe			wait 0,46 line 36
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$5009,$fffe			wait 0,44 line 37
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$5109,$fffe			wait 0,45 line 38
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$5209,$fffe			wait 0,46 line 39
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$5309,$fffe			wait 0,46 line 40
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$5409,$fffe			wait 0,44 line 41
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$5509,$fffe			wait 0,45 line 42
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$5609,$fffe			wait 0,46 line 43
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$5709,$fffe			wait 0,46 line 44
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$5809,$fffe			wait 0,44 line 45
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$5909,$fffe			wait 0,45 line 46
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$5a09,$fffe			wait 0,46 line 47
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$5b09,$fffe			wait 0,46 line 48
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$5c09,$fffe			wait 0,44 line 49
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$5d09,$fffe			wait 0,45 line 50
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$5e09,$fffe			wait 0,46 line 51
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$5f09,$fffe			wait 0,46 line 52
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$6009,$fffe			wait 0,44 line 53
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$6109,$fffe			wait 0,45 line 54
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$6209,$fffe			wait 0,46 line 55
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$6309,$fffe			wait 0,46 line 56
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$6409,$fffe			wait 0,44 line 57
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$6509,$fffe			wait 0,45 line 58
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$6609,$fffe			wait 0,46 line 59
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$6709,$fffe			wait 0,46 line 60
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$6809,$fffe			wait 0,44 line 61
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$6909,$fffe			wait 0,45 line 62
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$6a09,$fffe			wait 0,46 line 63
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$6b09,$fffe			wait 0,46 line 64
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$6c09,$fffe			wait 0,44 line 65
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$6d09,$fffe			wait 0,45 line 66
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$6e09,$fffe			wait 0,46 line 67
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$6f09,$fffe			wait 0,46 line 68
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$7009,$fffe			wait 0,44 line 69
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$7109,$fffe			wait 0,45 line 70
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$7209,$fffe			wait 0,46 line 71
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$7309,$fffe			wait 0,46 line 72
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$7409,$fffe			wait 0,44 line 73
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$7509,$fffe			wait 0,45 line 74
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$7609,$fffe			wait 0,46 line 75
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$7709,$fffe			wait 0,46 line 76
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$7809,$fffe			wait 0,44 line 77
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$7909,$fffe			wait 0,45 line 78
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$7a09,$fffe			wait 0,46 line 79
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$7b09,$fffe			wait 0,46 line 80
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$7c09,$fffe			wait 0,44 line 81
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$7d09,$fffe			wait 0,45 line 82
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$7e09,$fffe			wait 0,46 line 83
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$7f09,$fffe			wait 0,46 line 84
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$8009,$fffe			wait 0,44 line 85
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$8109,$fffe			wait 0,45 line 86
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$8209,$fffe			wait 0,46 line 87
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$8309,$fffe			wait 0,46 line 88
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$8409,$fffe			wait 0,44 line 89
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$8509,$fffe			wait 0,45 line 90
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$8609,$fffe			wait 0,46 line 91
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$8709,$fffe			wait 0,46 line 92
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$8809,$fffe			wait 0,44 line 93
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$8909,$fffe			wait 0,45 line 94
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$8a09,$fffe			wait 0,46 line 95
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$8b09,$fffe			wait 0,46 line 96
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$8c09,$fffe			wait 0,44 line 97
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$8d09,$fffe			wait 0,45 line 98
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$8e09,$fffe			wait 0,46 line 99
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$8f09,$fffe			wait 0,46 line 100
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$9009,$fffe			wait 0,44 line 101
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$9109,$fffe			wait 0,45 line 102
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$9209,$fffe			wait 0,46 line 103
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$9309,$fffe			wait 0,46 line 104
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$9409,$fffe			wait 0,44 line 105
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$9509,$fffe			wait 0,45 line 106
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$9609,$fffe			wait 0,46 line 107
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$9709,$fffe			wait 0,46 line 108
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$9809,$fffe			wait 0,44 line 109
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$9909,$fffe			wait 0,45 line 110
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$9a09,$fffe			wait 0,46 line 111
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$9b09,$fffe			wait 0,46 line 112
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$9c09,$fffe			wait 0,44 line 113
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$9d09,$fffe			wait 0,45 line 114
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$9e09,$fffe			wait 0,46 line 115
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$9f09,$fffe			wait 0,46 line 116
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$a009,$fffe			wait 0,44 line 117
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$a109,$fffe			wait 0,45 line 118
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$a209,$fffe			wait 0,46 line 119
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$a309,$fffe			wait 0,46 line 120
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$a409,$fffe			wait 0,44 line 121
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$a509,$fffe			wait 0,45 line 122
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$a609,$fffe			wait 0,46 line 123
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$a709,$fffe			wait 0,46 line 124
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$a809,$fffe			wait 0,44 line 125
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$a909,$fffe			wait 0,45 line 126
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$aa09,$fffe			wait 0,46 line 127
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$ab09,$fffe			wait 0,46 line 128
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$ac09,$fffe			wait 0,44 line 129
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$ad09,$fffe			wait 0,45 line 130
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$ae09,$fffe			wait 0,46 line 131
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$af09,$fffe			wait 0,46 line 132
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$b009,$fffe			wait 0,44 line 133
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$b109,$fffe			wait 0,45 line 134
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$b209,$fffe			wait 0,46 line 135
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$b309,$fffe			wait 0,46 line 136
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$b409,$fffe			wait 0,44 line 137
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$b509,$fffe			wait 0,45 line 138
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$b609,$fffe			wait 0,46 line 139
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$b709,$fffe			wait 0,46 line 140
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$b809,$fffe			wait 0,44 line 141
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$b909,$fffe			wait 0,45 line 142
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$ba09,$fffe			wait 0,46 line 143
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$bb09,$fffe			wait 0,46 line 144
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$bc09,$fffe			wait 0,44 line 145
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$bd09,$fffe			wait 0,45 line 146
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$be09,$fffe			wait 0,46 line 147
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$bf09,$fffe			wait 0,46 line 148
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$c009,$fffe			wait 0,44 line 149
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$c109,$fffe			wait 0,45 line 150
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$c209,$fffe			wait 0,46 line 151
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$c309,$fffe			wait 0,46 line 152
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$c409,$fffe			wait 0,44 line 153
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$c509,$fffe			wait 0,45 line 154
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$c609,$fffe			wait 0,46 line 155
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$c709,$fffe			wait 0,46 line 156
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$c809,$fffe			wait 0,44 line 157
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$c909,$fffe			wait 0,45 line 158
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$ca09,$fffe			wait 0,46 line 159
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$cb09,$fffe			wait 0,46 line 160
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$cc09,$fffe			wait 0,44 line 161
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$cd09,$fffe			wait 0,45 line 162
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$ce09,$fffe			wait 0,46 line 163
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$cf09,$fffe			wait 0,46 line 164
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$d009,$fffe			wait 0,44 line 165
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$d109,$fffe			wait 0,45 line 166
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$d209,$fffe			wait 0,46 line 167
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$d309,$fffe			wait 0,46 line 168
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$d409,$fffe			wait 0,44 line 169
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$d509,$fffe			wait 0,45 line 170
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$d609,$fffe			wait 0,46 line 171
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$d709,$fffe			wait 0,46 line 172
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$d809,$fffe			wait 0,44 line 173
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$d909,$fffe			wait 0,45 line 174
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$da09,$fffe			wait 0,46 line 175
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$db09,$fffe			wait 0,46 line 176
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$dc09,$fffe			wait 0,44 line 177
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$dd09,$fffe			wait 0,45 line 178
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$de09,$fffe			wait 0,46 line 179
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$df09,$fffe			wait 0,46 line 180
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$e009,$fffe			wait 0,44 line 181
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$e109,$fffe			wait 0,45 line 182
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$e209,$fffe			wait 0,46 line 183
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$e309,$fffe			wait 0,46 line 184
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$e409,$fffe			wait 0,44 line 185
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$e509,$fffe			wait 0,45 line 186
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$e609,$fffe			wait 0,46 line 187
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$e709,$fffe			wait 0,46 line 188
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$e809,$fffe			wait 0,44 line 189
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$e909,$fffe			wait 0,45 line 190
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$ea09,$fffe			wait 0,46 line 191
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$eb09,$fffe			wait 0,46 line 192
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$ec09,$fffe			wait 0,44 line 193
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$ed09,$fffe			wait 0,45 line 194
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$ee09,$fffe			wait 0,46 line 195
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$ef09,$fffe			wait 0,46 line 196
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$f009,$fffe			wait 0,44 line 197
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$f109,$fffe			wait 0,45 line 198
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$f209,$fffe			wait 0,46 line 199
		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0
		dc.w	$f309,$fffe			wait 0,46 line 200
constop		dc.w	bpl1mod,-40,bpl2mod,-40		modulos=0

; End of list!
		dc.w $ffff,$fffe	End of copper list
 
Old 
 dc.l 0 		     Storage point

Picture 	ds.b		(320/8)*256*5


