
; This program shows how to reuse a sprite channel. A total of ten sprites
;are displayed ( 1 blank and 9 letters ).

; The program is multi-tasking friendly, the sprite channel is requested and
;initialised by the graphics library, no custom copperlists here. To see the
;beauty of this method of programming run the final version a few times, do
;not click the mouse in between. You will end up with LOADS OF SPRITES.

; To make the sprite go away, press both mouse buttons.

; In case you do not know, AMIGANUTS UNITED are one of the oldest PD Libraries
;in the UK. They can be contacted on Southampton ( 0703 ) 785680.



		opt		o+,ow-
	
		incdir		:include/
		include		'graphics/gfx.i'
		include		'graphics/gfxbase.i'
		include		'graphics/graphics_lib.i'
		include		'graphics/view.i'
		include		'graphics/sprite.i'
		include		'exec/exec.i'
		include		'exec/exec_lib.i'
		include		'exec/execbase.i'
;		include		'misc/easystart.i'

ciaapra		equ		$bfe001



start		bsr		move_sprite	init sprite data

; Open graphics library

		moveq.l		#0,d0
		lea		GfxName,a1
		CALLEXEC	OpenLibrary
		move.l		d0,_GfxBase
		beq		quit_fast

; Find the viewport for the current view

		move.l		d0,a0
		move.l		gb_ActiView(a0),a0
		move.l		v_ViewPort(a0),a0
		move.l		a0,viewport
		
; Get a sprite to use
		
		lea		sprite,a0
		move.l		#-1,d0
		CALLGRAF	GetSprite
		move.l		d0,sprite_num
		addq.l		#1,d0
		beq		quit
		subq.l		#1,d0
		
; Set colour registers ( the hard way !!! )

		move.l		sprite_num,d7
		andi.l		#6,d7
		asl.l		#1,d7
		addi.l		#17,d7
		
		move.l		viewport,a0
		move.l		d7,d0
		move.l		#$f,d1
		move.l		#$8,d2
		move.l		#$0,d3
		CALLGRAF	SetRGB4
		addq.l		#1,d7
		move.l		viewport,a0
		move.l		d7,d0
		move.l		#$f,d1
		move.l		#$f,d2
		move.l		#$0,d3
		CALLGRAF	SetRGB4
		addq.l		#1,d7
		move.l		viewport,a0
		move.l		d7,d0
		move.l		#$f,d1
		move.l		#$a,d2
		move.l		#$c,d3
		CALLGRAF	SetRGB4
		
; Set the sprites x,y and height details
		
		move.l		#0,a0
		lea		sprite,a1
		move.w		#$140,ss_x(a1)
		move.w		#150,ss_y(a1)
		move.w		#8,ss_height(a1)

; Display the sprite

		lea		sprite_data,a2
		CALLGRAF	ChangeSprite
	
		move.l		#$80a08800,sprite_data

; Move it
	
mouse		CALLGRAF	WaitTOF
		bsr		move_sprite

; Wait for mouse

		btst		#6,ciaapra
		bne		mouse
		btst		#$0a,$dff016
		bne		mouse
		
; Wait for blanking gap
		
		CALLGRAF	WaitTOF

; Give sprite back to system

		move.l		sprite_num,d0
		CALLGRAF	FreeSprite

; Close graphics library

quit		move.l		_GfxBase,a1
		CALLEXEC	CloseLibrary
quit_fast	rts

*****************************************************************************	
	
move_sprite	lea		sprite_data,a2
		lea		sprite_pos,a0	get pointer to x-offset
		moveq.l		#9,d1		d1= counter ( 10 images )
		moveq.l		#1,d0		init displacement
move_loop	move.l		(a0),a1		a1= addr of x-offset
		tst.b		(a1)		end of table ?
		bne.s		legal_pos	if not don't worry
		lea		table,a1	else go back to start
legal_pos	move.b		(a1)+,0(a2,d0)	update x position of sprite
		add.l		#36,d0		d0=offset to next sprites x-pos
		move.l		a1,(a0)+	save ptr to this sprites x-pos
		dbra		d1,move_loop	repeat for all 9 images
		rts


*****************************************************************************	
; Variables

GfxName		dc.b		'graphics.library',0
		even
_GfxBase	dc.l		0
viewport	dc.l		0
sprite_num	dc.l		0

sprite		ds.b		ss_SIZEOF
		even
		
		

sprite_pos	dc.l		pos1		holds pts to each images 
		dc.l		pos2		place in the x-sp table
		dc.l		pos3
		dc.l		pos4
		dc.l		pos5
		dc.l		pos6
		dc.l		pos7
		dc.l		pos8
		dc.l		pos9
		dc.l		posa


table		dc.b	57+6,57+6,57+6,57+6,57+6,57+6,57+6,57+6,57+6
		dc.b	58+6,58+6,58+6,58+6,58+6,59+6,59+6,59+6,60+6,60+6
		dc.b	61+6,61+6,62+6,62+6,63+6,64+6,65+6,66+6,67+6,68+6
		dc.b	69+6,70+6,71+6,73+6,75+6,77+6,79+6,82+6,85+6
posa		dc.b	88+6
pos9		dc.b	92+6
pos8		dc.b	96+6
pos7		dc.b	100+6
pos6		dc.b	105+6
pos5		dc.b	111+6
pos4		dc.b	117+6
pos3		dc.b	124+6
pos2		dc.b	131+6
pos1		dc.b	138+6,145+6,151+6,157+6,162+6,166+6,170+6,174+6
		dc.b	177+6,180+6,183+6,185+6,187+6,189+6,191+6,192+6
		dc.b	193+6,194+6,195+6,196+6,197+6,198+6,199+6,200+6
		dc.b	200+6,201+6,201+6,202+6,202+6,203+6,203+6,203+6
		dc.b	204+6,204+6,204+6,204+6,204+6,205+6,205+6,205+6
		dc.b	205+6,205+6,205+6,205+6,205+6,205+6
		dc.b	204+6,204+6,204+6,204+6,204+6
		dc.b	203+6,203+6,203+6,202+6,202+6,201+6,201+6,200+6
		dc.b	200+6,199+6,198+6,197+6,196+6,195+6,194+6,193+6
		dc.b	192+6,191+6,189+6,187+6,185+6,183+6,180+6,177+6
		dc.b	174+6,170+6,166+6,162+6,157+6,151+6,145+6,138+6
		dc.b	131+6,124+6,117+6,111+6,105+6,100+6,96+6,92+6
		dc.b	88+6,85+6,82+6,79+6,77+6,75+6,73+6,71+6,70+6,69+6,68+6
		dc.b	67+6,66+6,65+6,64+6,63+6,62+6,62+6,61+6,61+6,60+6,60+6
		dc.b	59+6,59+6,59+6,58+6,58+6,58+6,58+6,58+6,0

		even
		
		section		marks,data_c

sprite_data	dc.w	$80a0,$8800
		dc.l	0,0,0,0,0,0,0,0	
sp1		dc.w	$96a0,$9e00
		dc.l	0,56,68,68,68,124,68,68		a
sp2		dc.w	$a095,$a800
		dc.l	0,68,108,84,68,68,68,68		m
sp3		dc.w	$aa9e,$b200
		dc.l	0,108,16,16,16,16,16,108	i
sp4		dc.w	$b49d,$bc00
		dc.l	0,60,64,64,64,92,68,56		g
sp5		dc.w	$be9a,$c600
		dc.l	0,56,68,68,68,124,68,68		a
sp6		dc.w	$c898,$d000
		dc.l	0,68,100,84,84,84,76,68		n
sp7		dc.w	$d294,$da00
		dc.l	0,68,68,68,68,68,68,58		u
sp8		dc.w	$dc90,$e400
		dc.l	0,124,16,16,16,16,16,16		t
sp9		dc.w	$e68c,$ee00
		dc.l	0,60,64,64,56,4,4,120		s
		dc.w	0,0

