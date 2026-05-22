	IFND _VEC_CONTROLLERSCRIPT
_VEC_CONTROLLERSCRIPT SET 1
	ELSE
_VEC_CONTROLLERSCRIPT SET _VEC_CONTROLLERSCRIPT+1
	ENDC

*****************************************************************************

	RSRESET
VEC_CTRL_SCRIPT_PTR:		rs.l 1		;0 - Script Ptr
VEC_CTRL_PAUSE_COUNTER:		rs.w 1		;4 - Pause counter, 0=running
VEC_CTRL_FRAMES_MIN		rs.w 1		;Minimum frames to run (to avoid skipping between 1 and 2+ frames)
VEC_CTRL_PALETTE_ACTIVE:	rs.w 1		;6 - Palette change active
VEC_CTRL_PALETTE_PTR:		rs.l 1		;8 - src Palette ptr (16 words of colors)
VEC_CTRL_PALETTE_COUNTER:	rs.w 1		;12 - Palette counter, speed
VEC_CTRL_PALETTE_SPEED:		rs.w 1		;How often to update, higher is slower, 0 = instant
VEC_CTRL_PALETTE_STEP		rs.w 1		;Current step to interpolate between current color and final 0-15
VEC_CTRL_ROT_CHANGE_ACTIVE:	rs.w 1		;16 - Rotation change active,final x,y,z,speed
VEC_CTRL_ROT_CHANGE_X:		rs.w 1
VEC_CTRL_ROT_CHANGE_Y:		rs.w 1
VEC_CTRL_ROT_CHANGE_Z:		rs.w 1
VEC_CTRL_ROT_CHANGE_SPEED:	rs.w 1
VEC_CTRL_FLASH_COUNT:		rs.w 1		;26 - flash count
VEC_CTRL_MOVE_ACTIVE:		rs.w 1		;28 - move active, final x,y,z,speed
VEC_CTRL_MOVE_X:		rs.w 1
VEC_CTRL_MOVE_Y:		rs.w 1
VEC_CTRL_MOVE_Z:		rs.w 1
VEC_CTRL_MOVE_SPEED:		rs.w 1
VEC_CTRL_SIZE:			rs.w 0

VEC_CTRL_FLASH_STARTCOUNT = 5

	EVEN
VEC_Controller_Info:
	dcb.b	VEC_CTRL_SIZE,0
	EVEN

VEC_FX_END_FLAG			= 	$ff
VEC_FX_FLASH_FLAG		=	$f0
VEC_FX_LOAD_FLAG		=	$f1
VEC_FX_PAUSE_FLAG		=	$f2
VEC_FX_MORPH_FLAG		=	$f3
VEC_FX_PALETTE_FLAG		=	$f4
VEC_FX_CLONE_ROTATION_FLAG	=	$f5
VEC_FX_CHANGE_ROT_DELTA_FLAG	=	$f6
VEC_FX_CHANGE_ROT_FLAG		=	$f7
VEC_FX_HORIZSINE_FLAG		=	$f8
VEC_FX_MOVE_FLAG		=	$f9

VEC_FX_MOVE	MACRO
		dc.w	VEC_FX_MOVE_FLAG
		dc.w	\1,\2,\3	;new coords
		dc.w	\4		;speed
		ENDM

VEC_FX_MORPH	MACRO
		dc.w	VEC_FX_MORPH_FLAG
		dc.w	\1		;speed
		dc.l	\2		;new pts
		ENDM

VEC_FX_PALETTE	MACRO
		dc.w	VEC_FX_PALETTE_FLAG
		dc.w	\1		;speed
		dc.l	\2		;new palette
		ENDM

VEC_FX_LOAD	MACRO
		dc.w	VEC_FX_LOAD_FLAG
		dc.l	\1		;new object info
		ENDM

VEC_FX_CLONE_ROTATION	MACRO
		dc.w	VEC_FX_CLONE_ROTATION_FLAG
		dc.l	\1		;new object info
		ENDM

VEC_FX_PAUSE	MACRO
		dc.w	VEC_FX_PAUSE_FLAG
		dc.w	\1		;frames to pause
		ENDM

VEC_FX_FLASH	MACRO
		dc.w	VEC_FX_FLASH_FLAG
		ENDM

VEC_FX_END	MACRO
		dc.w	VEC_FX_END_FLAG
		ENDM

VEC_FX_CHANGE_ROT	MACRO
		dc.w	VEC_FX_CHANGE_ROT_FLAG
		dc.w	\1,\2,\3,\4
		ENDM

VEC_FX_CHANGE_ROT_DELTA	MACRO
		dc.w	VEC_FX_CHANGE_ROT_DELTA_FLAG
		dc.w	\1,\2,\3
		ENDM

VEC_FX_HORIZSINE	MACRO
		dc.w	VEC_FX_HORIZSINE_FLAG
		dc.w	\1,\2	;speed1,step1
		ENDM

*****************************************************************************

; For glenz we need colors:
; COLOR01 = off white    
; COLOR02 = dark trans
; COLOR05 = pure white    
; COLOR06 = light trans

; For these palettes we use colors 8-15 to indicate what the reflection 
; colours should be.

; Default palette loaded at startup
VEC_PAL_Default:	dc.w	$0,$0,$0,$0,$0,$0,$0,$0
			dc.w	$0,$0,$0,$0,$0,$0,$0,$0


PaletteTest:		dc.w	$0,$f88,$8f8,$88f,$ff8,$8ff,$f8f,$fff
			dc.w	$0,$f88,$8f8,$88f,$ff8,$8ff,$f8f,$fff

PalleteSolidPurple	dc.w	$000,$63d,$306,$0,$0,$63d,$306,$0
			dc.w	$001,$30a,$003,$0,$0,$30a,$003,$0

PalleteSolidWhitePurple	dc.w	$000,$fff,$306,$0,$0,$fff,$306,$0
			dc.w	$001,$ddd,$104,$0,$0,$ddd,$104,$0

VEC_PAL_AllBlack:	dc.w	$0,$0,$0,$0,$0,$0,$0,$0
			dc.w	$0,$0,$0,$0,$0,$0,$0,$0	

VEC_PAL_AllWhite:	dc.w	$fff,$fff,$fff,$fff,$fff,$fff,$fff,$fff
			dc.w	$fff,$fff,$fff,$fff,$fff,$fff,$fff,$fff

VEC_PAL_AllWhite2:	dc.w	$001,$fff,$fff,$fff,$fff,$fff,$fff,$fff
			dc.w	$002,$ddd,$ddd,$ddd,$ddd,$ddd,$ddd,$ddd


VEC_PAL_Cube12_1:	dc.w	$001,$d96,$a63,$7d8,$394,$58d,$149,$000
			dc.w	$002,$a63,$730,$4a5,$061,$25a,$016,$000

VEC_PAL_Cube12_2:	dc.w	$001,$d96,$d96,$7d8,$7d8,$58d,$58d,$000
			dc.w	$002,$730,$730,$4a5,$4a5,$25a,$25a,$000

VEC_PAL_Cube24_1:	dc.w	$001,$d96,$d96,$7d8,$7d8,$58d,$58d,$000
			dc.w	$002,$730,$730,$4a5,$4a5,$25a,$25a,$000

VEC_PAL_Cube24_2:	dc.w	$001,$d96,$a63,$7d8,$394,$58d,$149,$000
			dc.w	$002,$a63,$730,$4a5,$061,$25a,$016,$000

VEC_PAL_Cube24_3	dc.w	$001,$fff,$149,$fff,$149,$fff,$149,$0
			dc.w	$002,$ddd,$016,$ddd,$016,$ddd,$016,$0

VEC_PAL_GlenzRed:	dc.w	$001,$eef,$800,$0,$0,$fff,$f00,$0
			dc.w	$002,$aab,$400,$0,$0,$bbb,$b00,$0

VEC_PAL_GlenzYellow:	dc.w	$001,$eef,$880,$0,$0,$fff,$ff0,$0
			dc.w	$002,$aab,$440,$0,$0,$bbb,$bb0,$0

VEC_PAL_GlenzPink:	dc.w	$001,$eef,$808,$0,$0,$fff,$f0f,$0
			dc.w	$002,$aab,$404,$0,$0,$bbb,$b0b,$0

VEC_PAL_GlenzGreen:	dc.w	$001,$eef,$080,$0,$0,$fff,$0f0,$0
			dc.w	$002,$aab,$040,$0,$0,$bbb,$0b0,$0

VEC_PAL_GlenzPurple:	dc.w	$001,$eef,$306,$0,$0,$fff,$63d,$0
			dc.w	$002,$ccd,$104,$0,$0,$ddd,$41b,$0

VEC_PAL_GlenzOrange:	dc.w	$001,$eef,$840,$0,$0,$fff,$f80,$0
			dc.w	$002,$aab,$400,$0,$0,$bbb,$b40,$0

VEC_PAL_GlenzBlue:	dc.w	$001,$eef,$149,$0,$0,$fff,$58d,$0
			dc.w	$002,$ccd,$016,$0,$0,$ddd,$25a,$0

VEC_PAL_GlenzCyan:	dc.w	$001,$eef,$088,$0,$0,$fff,$0ff,$0
			dc.w	$002,$ccd,$044,$0,$0,$ddd,$0bb,$0


*****************************************************************************

VEC_ControllerScript:

	;Main routine
	IFNE 1
	VEC_FX_PALETTE		0,VEC_PAL_AllBlack
	VEC_FX_HORIZSINE	0,0

	VEC_FX_PAUSE		80
	VEC_FX_LOAD		Obj_Cube12_Info
	VEC_FX_MORPH		0,Obj_Cube12_Pts_CubeSmall
	VEC_FX_MOVE		0,0,-15,0
	VEC_FX_CHANGE_ROT_DELTA	1,3,5
	VEC_FX_CHANGE_ROT	0,0,0,0
	VEC_FX_PAUSE		1
	VEC_FX_FLASH

	VEC_FX_PAUSE 		80
	VEC_FX_MORPH		0,Obj_Cube12_Pts_Spread
	VEC_FX_PAUSE		1
	VEC_FX_FLASH

	VEC_FX_PAUSE 		80
	VEC_FX_LOAD		Obj_C_Cube24_Info
	VEC_FX_CLONE_ROTATION	Obj_Cube12_Info
	VEC_FX_MORPH		0,Obj_C_Cube24_Pts_Spike
	VEC_FX_MOVE		0,0,-15,0
	VEC_FX_PAUSE		1
	VEC_FX_FLASH

	VEC_FX_PAUSE 		80
	VEC_FX_LOAD		Obj_Glenz24_Info
	VEC_FX_CLONE_ROTATION	Obj_Cube12_Info
	VEC_FX_MORPH		0,Obj_Glenz24_Pts_ClassicSphere
	VEC_FX_MOVE		0,0,-15,0
	VEC_FX_PAUSE		1
	VEC_FX_FLASH

	VEC_FX_PAUSE 		80
	VEC_FX_LOAD		Obj_Cube12_Info
	VEC_FX_CLONE_ROTATION	Obj_Glenz24_Info
	VEC_FX_MORPH		0,Obj_Cube12_Pts_Stack
	VEC_FX_MOVE		0,0,-15,0
	VEC_FX_PAUSE		1
	VEC_FX_FLASH


	VEC_FX_PAUSE		80
	VEC_FX_MORPH		0,Obj_Cube12_Pts_CubeSmall
	VEC_FX_PAUSE		1
	VEC_FX_FLASH

	VEC_FX_PAUSE 		5
	VEC_FX_MORPH		0,Obj_Cube12_Pts_Spread
	VEC_FX_PAUSE		1
	VEC_FX_FLASH

	VEC_FX_PAUSE 		5
	VEC_FX_LOAD		Obj_C_Cube24_Info
	VEC_FX_CLONE_ROTATION	Obj_Cube12_Info
	VEC_FX_MORPH		0,Obj_C_Cube24_Pts_Spike
	VEC_FX_MOVE		0,0,-15,0
	VEC_FX_PAUSE		1
	VEC_FX_FLASH

	VEC_FX_PAUSE 		5
	VEC_FX_LOAD		Obj_Glenz24_Info
	VEC_FX_CLONE_ROTATION	Obj_Cube12_Info
	VEC_FX_MORPH		0,Obj_Glenz24_Pts_ClassicSphere
	VEC_FX_MOVE		0,0,-15,0
	VEC_FX_PAUSE		1
	VEC_FX_FLASH

	VEC_FX_PAUSE 		5
	VEC_FX_LOAD		Obj_Cube12_Info
	VEC_FX_CLONE_ROTATION	Obj_Glenz24_Info
	VEC_FX_MORPH		0,Obj_Cube12_Pts_Stack
	VEC_FX_MOVE		0,0,-15,0
	VEC_FX_PAUSE		1
	VEC_FX_FLASH

	VEC_FX_PAUSE 		5
	VEC_FX_PALETTE		0,VEC_PAL_AllWhite
	VEC_FX_HORIZSINE	3,2

	VEC_FX_PAUSE 		50
	VEC_FX_LOAD		Obj_Cube12_Info
	VEC_FX_CHANGE_ROT	0,0,0,0
	VEC_FX_MORPH		0,Obj_Cube12_Pts_Stack
	VEC_FX_MOVE		0,0,-15,0
	VEC_FX_PAUSE 		1

	VEC_FX_PALETTE		1,VEC_PAL_AllWhite2
	VEC_FX_PAUSE 		100

	;12 face cube, complex, 2 frames
	VEC_FX_PALETTE		2,VEC_PAL_Cube12_1

	VEC_FX_PAUSE		100
	VEC_FX_MORPH		2,Obj_Cube12_Pts_StackSmall
	VEC_FX_PAUSE		125
	VEC_FX_MORPH		1,Obj_Cube12_Pts_Spread
	VEC_FX_PAUSE		400
	VEC_FX_MORPH		1,Obj_Cube12_Pts_CubeSmall
	VEC_FX_PAUSE		200

	VEC_FX_PALETTE		2,VEC_PAL_Cube12_2
	VEC_FX_PAUSE		50

	;24 face cube, complex, 2 frames
	VEC_FX_LOAD		Obj_C_Cube24_Info
	VEC_FX_CLONE_ROTATION	Obj_Cube12_Info
	VEC_FX_MORPH		0,Obj_C_Cube24_Pts_CubeSmall
	VEC_FX_PALETTE		0,VEC_PAL_Cube24_1
	VEC_FX_MOVE		0,0,-15,0

	VEC_FX_PAUSE		1
	VEC_FX_MORPH		1,Obj_C_Cube24_Pts_Spike
	VEC_FX_PAUSE		50
	VEC_FX_PALETTE		4,VEC_PAL_Cube24_2

	VEC_FX_PAUSE		300
	VEC_FX_PALETTE		2,VEC_PAL_Cube24_2
	VEC_FX_MORPH		1,Obj_C_Cube24_Pts_CubeSmall

	VEC_FX_PAUSE		250

	;24 face cube, simple, 1 frame
	VEC_FX_LOAD		Obj_Cube24_Info
	VEC_FX_CLONE_ROTATION	Obj_C_Cube24_Info
	VEC_FX_MORPH		0,Obj_Cube24_Pts_CubeSmall
	VEC_FX_MOVE		0,0,-15,0

	VEC_FX_PAUSE		1
	VEC_FX_PALETTE		4,VEC_PAL_Cube24_3
	VEC_FX_PAUSE		110

	;Final form, glenz vector 
	VEC_FX_LOAD		Obj_Glenz24_Info
	VEC_FX_CLONE_ROTATION	Obj_Cube24_Info
	VEC_FX_MORPH		0,Obj_Glenz24_Pts_CubeSmall
	VEC_FX_MOVE		0,0,-15,0

	VEC_FX_PAUSE		1
	VEC_FX_MORPH		4,Obj_Glenz24_Pts_ClassicSphere
	VEC_FX_PAUSE		200
	VEC_FX_PALETTE		4,VEC_PAL_GlenzBlue
	VEC_FX_PAUSE		200
	VEC_FX_PALETTE		4,VEC_PAL_GlenzRed
	VEC_FX_PAUSE		200
	
	ENDC

	VEC_FX_MORPH		1,Obj_Glenz24_Pts_Pyramid2
	VEC_FX_PALETTE		4,VEC_PAL_GlenzPurple
	VEC_FX_PAUSE		100
	VEC_FX_PALETTE		4,VEC_PAL_GlenzOrange
	VEC_FX_PAUSE		100

	VEC_FX_MORPH		1,Obj_Glenz24_Pts_Disc
	VEC_FX_PALETTE		4,VEC_PAL_GlenzGreen
	VEC_FX_PAUSE		100
	VEC_FX_PALETTE		4,VEC_PAL_GlenzPink
	VEC_FX_PAUSE		100

	VEC_FX_MORPH		1,Obj_Glenz24_Pts_Pyramid
	VEC_FX_PALETTE		4,VEC_PAL_GlenzYellow
	VEC_FX_PAUSE		100
	VEC_FX_PALETTE		4,VEC_PAL_GlenzCyan
	VEC_FX_PAUSE		100

	VEC_FX_MORPH		1,Obj_Glenz24_Pts_Box
	VEC_FX_PALETTE		4,VEC_PAL_GlenzPurple
	VEC_FX_PAUSE		100
	VEC_FX_PALETTE		4,VEC_PAL_GlenzRed
	VEC_FX_PAUSE		100

	VEC_FX_MORPH		1,Obj_Glenz24_Pts_ClassicSphere
	VEC_FX_PALETTE		4,VEC_PAL_GlenzOrange
	VEC_FX_PAUSE		100
	VEC_FX_PALETTE		4,VEC_PAL_GlenzBlue
	VEC_FX_PAUSE		100

;	VEC_FX_PAUSE 		500
	VEC_FX_PALETTE		1,VEC_PAL_AllWhite
	VEC_FX_PAUSE 		32
	VEC_FX_PALETTE		1,VEC_PAL_AllBlack

	VEC_FX_PAUSE 		50
	
	VEC_FX_END


VEC_ControllerScript_VR:
	;Vector Republic Start
	VEC_FX_PALETTE		0,VEC_PAL_AllBlack
	VEC_FX_LOAD		Obj_VecRep_Info
	VEC_FX_MORPH		0,Obj_VecRep_Pts_SquareOnSquare
	VEC_FX_CHANGE_ROT	0,0,0,0
	VEC_FX_CHANGE_ROT_DELTA	0,4,0
	VEC_FX_MOVE		0,0,2000,0
	VEC_FX_HORIZSINE	2,1
	VEC_FX_PAUSE		50

	VEC_FX_PALETTE		4,VEC_PaletteVecRep1
	VEC_FX_MOVE		0,0,-55,10	
	VEC_FX_PAUSE		400

	VEC_FX_MORPH		1,Obj_VecRep_Pts_Interim
	VEC_FX_PAUSE		150
	VEC_FX_MORPH		1,Obj_VecRep_Pts
	VEC_FX_CHANGE_ROT_DELTA	0,4,0
	VEC_FX_PAUSE		200
	VEC_FX_PALETTE		1,VEC_PaletteVecRep2
	VEC_FX_PAUSE		400
	VEC_FX_PALETTE		1,VEC_PAL_AllWhite
	VEC_FX_PAUSE 		64
	VEC_FX_PALETTE		1,VEC_PAL_AllBlack

	VEC_FX_PAUSE		100
	VEC_FX_END
