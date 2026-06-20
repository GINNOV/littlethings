
*		Animated 16 colour sprite (7 frames)

*		Coded for ACC by Mike Cross - July 1991

*		PD source  -  Use and abuse at will.
 

		opt	C-,O-,D+,M+
		
		incdir	sys:include/			
		include	exec/exec_lib.i		
		include	exec/execbase.i
		include	exec/memory.i
		include	hardware/custom.i
		include	hardware/intbits.i
		include	hardware/dmabits.i
		include	graphics/graphics_lib.i
		include	graphics/gfxbase.i
		include	source:include/mymacros.i		

ScreenWidth	equ	42
ScreenHeight	equ	256
PlaneSize	equ	ScreenWidth*ScreenHeight

NumberOfPlanes	equ	1

Ciaapra		equ	$bfe001
Custom		equ	$dff000
VERSION_NUMBER	equ	33			* 33 for V1.2 Amiga's



		Section	Main,Code
		
		movem.l  a0-a6/d0-d7,-(sp)

		lea	Variables,a6		* A6 - Always variables

		lea     GraphicsName(pc),a1
		moveq.l	#VERSION_NUMBER,d0
		CALLSYS	OpenLibrary   
		beq	Exit
		move.l	d0,a1
		move.l	gb_copinit(a1),SystemCopper(a6)	
		CALLSYS	CloseLibrary
		
		move.l	#PlaneSize*NumberOfPlanes,d0
		move.l	#MEMF_CHIP!MEMF_CLEAR,d1
		CALLSYS	AllocMem
		move.l	d0,ScreenMemory(a6)
		beq	Exit

		move.l	ScreenMemory(a6),d0
		lea	PlaneAddresses(a6),a0	* Grab address of plane
		move.l	d0,(a0)			
		
		bsr	InitVariables

		CALLSYS	Forbid     

		move.l	$68.w,SystemLev2Int(a6)
		move.l	$6c.w,SystemLev3Int(a6)
		move.w	dmaconr(a5),SystemDma(a6)
		move.w	intenar(a5),SystemInts(a6)
		move.w	#$7fff,d0
		move.w  d0,dmacon(a5)
		move.w	d0,intena(a5)
		move.l  #TheCopperList,cop1lc(a5)   
		move.w  d0,copjmp1(a5)     
		move.w  #DMAF_SETCLR!DMAF_MASTER!DMAF_RASTER!DMAF_SPRITE!DMAF_COPPER,dmacon(a5)	

InterruptLoop	move.w	intreqr(a5),d6
		move.w	#INTF_VERTB,d7
		and.w	d7,d6
		beq.s	InterruptLoop
		move.w	d7,intreq(a5)


		bsr	MoveStar		
		bsr	Pulse

		btst	#6,Ciaapra
		bne.s	InterruptLoop

		move.w	SystemInts(a6),d0
		ori.w	#INTF_SETCLR!INTF_INTEN,d0
		move.w	d0,intena(a5)
		move.w 	SystemDma(a6),d0
		ori.w	#DMAF_SETCLR,d0
		move.w 	d0,dmacon(a5)
		move.l	SystemLev2Int(a6),$68.w
		move.l	SystemLev3Int(a6),$6c.w
		CALLSYS	Permit
		move.l 	SystemCopper(a6),cop1lc(a5)
		move.l	ScreenMemory(a6),a1
		move.l	#PlaneSize*NumberOfPlanes,d0
		CALLSYS	FreeMem
Exit		movem.l (sp)+,d0-d7/a0-a6
		rts



MoveStar	lea	Sprite1a,a0		* Update ALL sprites
		lea	Sprite1b,a1
		moveq.l	#7-1,d0
MLoop		add.b	#2,1(a0)
		add.b	#2,1(a1)
		add.w	#136,a0
		add.w	#136,a1
		dbf	d0,MLoop
		rts
		

Pulse		move.l	a4,-(sp)
		lea	SpriteVars,a4
		cmp.b	#1,Delay(a4)			
		bne	NoPulse
		clr.b	Delay(a4)
Pulse2		move.l	SpriteAnim(a4),a0	* Get current frame
		lea	Sprite1a,a1		* Start of sprite data
		move.w	(a0)+,d0		
		cmpi.w	#$ff,d0			* End of anim?
		bne	Okay
		move.l	#AnimFlow,SpriteAnim(a4)
		bra	Pulse2
Okay		mulu	#136,d0			* 136 bytes for each sprite		
		add.l	d0,a1
		move.l	a1,SpriteA(a4)		* Address of sprite a
		add.l	#68,a1
		move.l	a1,SpriteB(a4)		* Same for b
		move.l	a0,SpriteAnim(a4)
		bsr	LoadSprite		* Load sprites
NoPulse		add.b	#1,Delay(a4)		
		move.l	(sp)+,a4
		rts
		
* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×
* ×	Put screen in copper,clear sprite pointers & load colour map	×
* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×

UpdateCopper	lea	PlaneAddresses(a6),a0	
		lea	Planes,a1		
		move.w	(a0),(a1)		
		move.w	2(a0),4(a1)		
		rts

ClearSprites	lea	Sprites,a0
		moveq.l	#16-1,d0
ClrSpriteLoop	move.w	#0,(a0)
		addq.l	#4,a0
		dbf	d0,ClrSpriteLoop
		rts

LoadSprite	move.l	a4,-(sp)
		lea	SpriteVars,a4
		move.l	SpriteA(a4),d0
		move.l	SpriteB(a4),d1
		lea	Sprites,a0
		move.w	d0,4(a0)
		move.w	d1,12(a0)
		swap	d0
		swap	d1
		move.w	d0,(a0)
		move.w	d1,8(a0)
		move.l	(sp)+,a4
		rts

* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×
* ×	Initialise all game variables and pointers			×
* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×

InitVariables	lea	Custom,a5		* A5 - Always hardware
		lea	SpriteVars,a4
		bsr	ClearSprites
		move.l	#Sprite1a,SpriteA(a4)
		move.l	#Sprite1b,SpriteB(a4)
		move.l	#AnimFlow,SpriteAnim(a4)
		bsr	LoadSprite
		bsr	UpdateCopper
		clr.b	Delay(a4)
		rts

* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×
		
		even

GraphicsName	GRAFNAME

		even
		
* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×
* ×	Main variable list (accessed through A6)			×
* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×

		Section	Variables,Bss
		
		rsreset

PlaneAddresses	rs.l	NumberOfPlanes	* Start address of each bitplane
ScreenMemory	rs.l	1		* Allocated memory	
SystemCopper	rs.l	1
SystemDma	rs.w	1
SystemInts	rs.w	1
SystemLev2Int	rs.l	1
SystemLev3Int	rs.l	1
Vars_SIZEOF	rs.b	0

Variables	ds.b	Vars_SIZEOF


SpriteA		rs.l	1		* Point to sprite 1 data
SpriteB		rs.l	1		* Point to sprite 2 data
SpriteAnim	rs.l	1		* Point to Anim structure
SpriteControl	rs.l	1		* Control words
Delay		rs.b	1
Spr_SIZEOF	rs.b	0

SpriteVars	ds.b	Spr_SIZEOF

* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×
* × 	Copper list							×
* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×

		Section	Copper,Data_C

TheCopperList	dc.w	diwstrt,$2c79,diwstop,$2cc1
		dc.w	ddfstrt,$0030,ddfstop,$00d0
		dc.w	bplcon1,$0000,bplcon2,$0000
		dc.w	bpl1mod,-2,bpl2mod,-2

		dc.w 	bplcon0,$1200

		dc.w	color+$00,$0000,color+$02,$0fff
		
		dc.w	color+$20,$0000,color+$22,$0bcf,color+$24,$089c
		dc.w	color+$26,$0459,color+$28,$0236,color+$2a,$0720
		dc.w	color+$2c,$0510,color+$2e,$0410,color+$30,$0558
		dc.w	color+$32,$0447,color+$34,$0336,color+$36,$0ddf
		dc.w	color+$38,$0225,color+$3a,$0aaa,color+$3c,$0888
		dc.w	color+$3e,$0fca
		
		dc.w	sprpt+$00
Sprites		dc.w	$0000,sprpt+$02,$0000,sprpt+$04,$0000,sprpt+$06
		dc.w	$0000,sprpt+$08,$0000,sprpt+$0a,$0000,sprpt+$0c
		dc.w	$0000,sprpt+$0e,$0000,sprpt+$10,$0000,sprpt+$12
		dc.w	$0000,sprpt+$14,$0000,sprpt+$16,$0000,sprpt+$18
		dc.w	$0000,sprpt+$1a,$0000,sprpt+$1c,$0000,sprpt+$1e
		dc.w	$0000

		dc.w	bplpt+$00
Planes 		dc.w 	$0000,bplpt+$02,$0000

     		dc.w	$ffff,$fffe	


* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×

AnimFlow	dc.w	0,1,2,3,4,5,6,6,5,4,3,2,1,0,$ff

Sprite1a	dc.w	$6030,$7000
		dc.w	$0000,$0000,$0fc0,$0fc0,$1060,$1fe0,$2e30,$31f0
		dc.w	$5f10,$60f0,$5f12,$60f2,$4e12,$71f2,$6034,$7ff6
		dc.w	$30e2,$3fe6,$9f96,$9f9a,$406c,$4074,$7fb4,$7fcc
		dc.w	$27c8,$3838,$1830,$1ff0,$07c0,$07c0,$0000,$0000

Sprite1b	dc.w	$6030,$7080
		dc.w	$07c0,$0000,$1030,$0000,$2018,$0000,$400c,$0000
		dc.w	$000c,$0000,$800e,$0000,$800e,$0000,$800e,$0000
		dc.w	$c01e,$0000,$e07e,$0000,$7ffc,$0000,$7ffc,$0000
		dc.w	$3ff8,$0000,$1ff0,$0000,$07c0,$0000,$0000,$0000


Sprite2a	dc.w	$6030,$7000
		dc.w	$0000,$0000,$0000,$0000,$07c0,$07c0,$0860,$0fe0
		dc.w	$1730,$18f0,$2f10,$30f0,$2f10,$30f0,$2710,$38f0
		dc.w	$18e0,$1fe4,$4f94,$4f98,$206c,$2074,$3fb4,$3fcc
		dc.w	$13c8,$1c38,$0c30,$0ff0,$0000,$0000,$0000,$0000

Sprite2b	dc.w	$6030,$7080
		dc.w	$0000,$0000,$03c0,$0000,$0830,$0000,$1018,$0000
		dc.w	$200c,$0000,$000c,$0000,$400c,$0000,$400c,$0000
		dc.w	$601c,$0000,$707c,$0000,$3ffc,$0000,$3ffc,$0000
		dc.w	$1ff8,$0000,$0ff0,$0000,$0000,$0000,$0000,$0000

Sprite3a	dc.w	$6030,$7000
		dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$07c0,$07c0
		dc.w	$0060,$07e0,$0f20,$08e0,$1700,$18e0,$1700,$18e0
		dc.w	$1828,$1fe8,$08e0,$0fe8,$1078,$1068,$1fa8,$1fd8
		dc.w	$0bd0,$0c30,$0420,$07e0,$0000,$0000,$0000,$0000

Sprite3b	dc.w	$6030,$7080
		dc.w	$0000,$0000,$0000,$0000,$03c0,$0000,$0020,$0000
		dc.w	$0810,$0000,$1018,$0000,$2018,$0000,$2018,$0000
		dc.w	$2018,$0000,$3018,$0000,$1ff8,$0000,$1ff8,$0000
		dc.w	$0ff0,$0000,$07e0,$0000,$0000,$0000,$0000,$0000


Sprite4a	dc.w	$6030,$7000
		dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
		dc.w	$0380,$0380,$0440,$07c0,$0f20,$08e0,$0f20,$08e0
		dc.w	$0b20,$0ce0,$04c0,$07d0,$17b0,$17a0,$0850,$0870
		dc.w	$0380,$0460,$0460,$07e0,$0000,$0000,$0000,$0000

Sprite4b	dc.w	$6030,$7080
		dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0380,$0000
		dc.w	$0460,$0000,$0020,$0000,$0010,$0000,$1010,$0000
		dc.w	$1010,$0000,$1830,$0000,$1870,$0000,$0ff0,$0000
		dc.w	$07e0,$0000,$07e0,$0000,$0000,$0000,$0000,$0000


Sprite5a	dc.w	$6030,$7000
		dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
		dc.w	$0000,$0000,$0380,$0380,$0740,$04c0,$0300,$04c0
		dc.w	$0300,$04c0,$04c0,$07c0,$0060,$0040,$07c0,$07a0
		dc.w	$0240,$03c0,$0000,$0000,$0000,$0000,$0000,$0000

Sprite5b	dc.w	$6030,$7080
		dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
		dc.w	$0180,$0000,$0040,$0000,$0020,$0000,$0820,$0000
		dc.w	$0820,$0000,$0820,$0000,$07e0,$0000,$07e0,$0000
		dc.w	$03c0,$0000,$0000,$0000,$0000,$0000,$0000,$0000


Sprite6a	dc.w	$6030,$7000
		dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
		dc.w	$0000,$0000,$0000,$0000,$0040,$01c0,$0180,$0240
		dc.w	$0100,$02c0,$0240,$03c0,$0060,$0040,$03a0,$0260
		dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
		
Sprite6b	dc.w	$6030,$7080		
		dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
		dc.w	$0000,$0000,$0180,$0000,$0220,$0000,$0020,$0000
		dc.w	$0420,$0000,$0420,$0000,$03e0,$0000,$03e0,$0000
		dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000


Sprite7a	dc.w	$6030,$7000
		dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
		dc.w	$0000,$0000,$0000,$0000,$0280,$0380,$0300,$0080
		dc.w	$0100,$0280,$0280,$0380,$00c0,$0080,$01c0,$0240
		dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

Sprite7b	dc.w	$6030,$7080
		dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
		dc.w	$0000,$0000,$0180,$0000,$0040,$0000,$0040,$0000
		dc.w	$0440,$0000,$0440,$0000,$03c0,$0000,$03c0,$0000
		dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

* ×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×x×

		End






