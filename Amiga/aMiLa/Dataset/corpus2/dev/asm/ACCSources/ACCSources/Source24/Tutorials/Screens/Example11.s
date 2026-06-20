
; Example 11: Using a Custom BitMap

		include		int_start.i

; Initialise the BitMap structure

Main		lea		MyBitMap,a0		a0->BitMap struct
		move.l		#4,d0			Depth
		move.l		#640,d1			Width
		move.l		#256,d2			height
		CALLGRAF	InitBitMap		initialise structure

; Link bitplane memory into BitMap structure

		lea		MyBitMap,a0		a0->BitMap
		lea		bm_Planes(a0),a0	a0->bm_Planes field
		
		lea		bitplanes,a1		a1->start of mem block

    ; Write first bitplane start address into structure
    
    		move.l		a1,(a0)+		write bitplane addr
    
    ; Compute addr of 2nd bitplane start address and write into structure
    
    		adda.l		#(640/8)*256,a1		a1->2nd bitplane
    		move.l		a1,(a0)+		write bitplane addr

    ; Compute addr of 3rd bitplane start address and write into structure
    
    		adda.l		#(640/8)*256,a1		a1->3rd bitplane
    		move.l		a1,(a0)+		write bitplane addr

    ; Compute addr of 4th bitplane start address and write into structure
    
    		adda.l		#(640/8)*256,a1		a1->4th bitplane
    		move.l		a1,(a0)+		write bitplane addr

; Link BitMap structure to NewScreen structure

		lea		MyScreen,a0		a0->NewScreen
		move.l		#MyBitMap,ns_CustomBitMap(a0) link BitMap

; Set screens type

		move.w		#CUSTOMBITMAP!CUSTOMSCREEN,ns_Type(a0)

; Open the Custom Screen

		lea		MyScreen,a0		NewScreen struct
		CALLINT		OpenScreen		open it
		move.l		d0,screen.ptr		save pointer
		beq.s		.error			quit if error

; Wait for mouse press

		bsr		RightMouse		wait on RMB
		
; Close the screen

		move.l		screen.ptr,a0		a0->screen struct
		CALLINT		CloseScreen		close it

.error		rts					and exit

; Static Intuition structures and variables

MyBitMap	ds.b		bm_SIZEOF	space for BitMap structure

MyScreen
	dc.w	0,0		;screen XY origin relative to View
	dc.w	640,256		;screen width and height
	dc.w	4		;screen depth (number of bitplanes)
	dc.b	3,8		;detail and block pens
	dc.w	V_HIRES		;display modes for this screen
	dc.w	0		;screen type
	dc.l	0		;pointer to default screen font
	dc.l	.Title		;pointer to screen title
	dc.l	0		;first in list of custom screen gadgets
	dc.l	0		;pointer to custom BitMap structure

.Title	dc.b	'CustomBitMap Screen, believe it or not!',0
	even

screen.ptr	dc.l		0

; BSS section for bitplane memory block

		section		scrn_mem,BSS_C

; reserve space for 4 bitplanes of dimension 640x256

bitplanes	ds.b		(640/8)*256*4
