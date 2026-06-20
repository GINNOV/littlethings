	IFND _OBJ_VECREP
_OBJ_VECREP SET 1
	ELSE
_OBJ_VECREP SET _OBJ_VECREP+1
	ENDC

;0 - back
;1 - Triangle front
;2 - Triangle side
;3 - Triangle bottom
;4 - Main front
;5 - main left side
;6 - main right side
;7 - main bottom

VEC_PaletteVecRep1:	dc.w	$0,$f08,$e07,$d06,$fff,$eee,$ddd,$333
			dc.w	$0,$c05,$b04,$a05,$ccc,$bbb,$aaa,$111

VEC_PaletteVecRep2:	dc.w	$05B,$f08,$e07,$d06,$fff,$eee,$ddd,$333
			dc.w	$028,$c05,$b04,$a05,$ccc,$bbb,$aaa,$111


; This object is sized -80 to 80

OBJ_VECREP_NUMPTS = 20
Obj_VecRep_Info:
	dc.w	0			; initialised (happens on first load)
	dc.w	0,0,0			; pos, x,y,z
	dc.w	0,0,0			; current rotation, x,y,z
	dc.w	1,2,0			; Rotation step, x,y,z
	dc.w	1			; Complex 1/0
	dc.w	2			; Num frames min
	dc.l	Obj_VecRep_PtsBuffer	; Pts ptr (in use/buffer)
	dc.l	Obj_VecRep_Pts		; Initial points ptr
	dc.l	Obj_VecRep_Facelist	; Facelist ptr
	dc.w	0,0,0			; Morph active flag, counter, speed

; Points are loaded to here from Ob1_Pts. So can do transforms without
; trashing original points.
Obj_VecRep_PtsBuffer:
	ds.w	1
	ds.w	3*OBJ_VECREP_NUMPTS

Obj_VecRep_Pts:
	dc.w	OBJ_VECREP_NUMPTS-1

	;tri - bot left front
	dc.w -48,-28,-12	;0
	dc.w -4,-80,-12		;1
	dc.w -48,-80,-12	;2

	;tri - bot left back
	dc.w -48,-28,12		;3
	dc.w -4,-80,12		;4
	dc.w -48,-80,12		;5

	;tri - bot right front
	dc.w 48,-28,-12		;6
	dc.w 48,-80,-12		;7
	dc.w 4,-80,-12		;8

	;tri - bot right back
	dc.w 48,-28,12		;9
	dc.w 48,-80,12		;10
	dc.w 4,-80,12		;11

	;main - front
	;main - back
	dc.w 0,80,-12		;12
	dc.w 44,-12,-12		;13
	dc.w 0,-64,-12		;14
	dc.w -44,-12,-12	;15
	
	dc.w 0,80,12		;16
	dc.w 44,-12,12		;17
	dc.w 0,-64,12		;18
	dc.w -44,-12,12		;19

Obj_VecRep_Pts_SquareOnSquare:
	dc.w	OBJ_VECREP_NUMPTS-1

	;tri - bot left front
	dc.w 44,0,-12		;0
	dc.w -44,-80,-12	;1
	dc.w -44,0,-12		;2

	;tri - bot left back
	dc.w 44,-0,12		;3
	dc.w -44,-80,12		;4
	dc.w -44,0,12		;5

	;tri - bot right front
	dc.w 44,0,-12		;6
	dc.w 44,-80,-12		;7
	dc.w -44,-80,-12	;8

	;tri - bot right back
	dc.w 44,0,12		;9
	dc.w 44,-80,12		;10
	dc.w -44,-80,12		;11

	;main - front
	;main - back
	dc.w -44,80,-12		;12
	dc.w 44,80,-12		;13
	dc.w 44,0,-12		;14
	dc.w -44,0,-12		;15

	dc.w -44,80,12		;16
	dc.w 44,80,12		;17
	dc.w 44,0,12		;18
	dc.w -44,0,12		;19

Obj_VecRep_Pts_Interim:
	dc.w	OBJ_VECREP_NUMPTS-1

	;tri - bot left front
	dc.w -48,-28,-12	;0
	dc.w -4,-80,-12		;1
	dc.w -48,-80,-12	;2

	;tri - bot left back
	dc.w -48,-28,12		;3
	dc.w -4,-80,12		;4
	dc.w -48,-80,12		;5

	;tri - bot right front
	dc.w 48,-28,-12		;6
	dc.w 48,-80,-12		;7
	dc.w 4,-80,-12		;8

	;tri - bot right back
	dc.w 48,-28,12		;9
	dc.w 48,-80,12		;10
	dc.w 4,-80,12		;11

	;main - front
	;main - back
	dc.w -44,80,-12		;12
	dc.w 44,80,-12		;13
	dc.w 44,0,-12		;14
	dc.w -44,0,-12		;15

	dc.w -44,80,12		;16
	dc.w 44,80,12		;17
	dc.w 44,0,12		;18
	dc.w -44,0,12		;19



Obj_VecRep_Facelist:
	dc.w	18-1 ;6-1

	;Bot left triangle
	dc.l	Obj_VecRep_f1
	dc.l	Obj_VecRep_f2
	dc.l	Obj_VecRep_f3
	dc.l	Obj_VecRep_f4
	dc.l	Obj_VecRep_f5

	;Bot right triangle
	dc.l	Obj_VecRep_f6
	dc.l	Obj_VecRep_f7
	dc.l	Obj_VecRep_f8
	dc.l	Obj_VecRep_f9
	dc.l	Obj_VecRep_f10

	;Main top front/back
	dc.l	Obj_VecRep_f11
	dc.l	Obj_VecRep_f12
	dc.l	Obj_VecRep_f13
	dc.l	Obj_VecRep_f14
	dc.l	Obj_VecRep_f15
	dc.l	Obj_VecRep_f16
	dc.l	Obj_VecRep_f17
	dc.l	Obj_VecRep_f18



;Bot left triangle
Obj_VecRep_f1:		;front
	VEC_FACE	3-1,1,1,-1,-1
	VEC_CON		0,1
	VEC_CON		1,2
	VEC_CON		2,0

Obj_VecRep_f2:		;back
	VEC_FACE	3-1,1,1,-1,-1
	VEC_CON		3,5
	VEC_CON		5,4
	VEC_CON		4,3

Obj_VecRep_f3:		;side
	VEC_FACE	4-1,2,2,-1,-1
	VEC_CON		3,0
	VEC_CON		0,2
	VEC_CON		2,5
	VEC_CON		5,3

Obj_VecRep_f4:		;top
	VEC_FACE	4-1,3,3,-1,-1
	VEC_CON		0,3
	VEC_CON		3,4
	VEC_CON		4,1
	VEC_CON		1,0

Obj_VecRep_f5:		;bottom
	VEC_FACE	4-1,3,3,-1,-1
	VEC_CON		1,4
	VEC_CON		4,5
	VEC_CON		5,2
	VEC_CON		2,1


;Bot right triangle
Obj_VecRep_f6:		;front
	VEC_FACE	3-1,1,1,-1,-1
	VEC_CON		6,7
	VEC_CON		7,8
	VEC_CON		8,6

Obj_VecRep_f7:		;back
	VEC_FACE	3-1,1,1,-1,-1
	VEC_CON		9,11
	VEC_CON		11,10
	VEC_CON		10,9

Obj_VecRep_f8:		;side
	VEC_FACE	4-1,2,2,-1,-1
	VEC_CON		6,9
	VEC_CON		9,10
	VEC_CON		10,7
	VEC_CON		7,6

Obj_VecRep_f9:		;top
	VEC_FACE	4-1,2,2,-1,-1
	VEC_CON		9,6
	VEC_CON		6,8
	VEC_CON		8,11
	VEC_CON		11,9

Obj_VecRep_f10:		;bottom
	VEC_FACE	4-1,3,3,-1,-1
	VEC_CON		7,10
	VEC_CON		10,11
	VEC_CON		11,8
	VEC_CON		8,7

;main
Obj_VecRep_f11:		;front top
	VEC_FACE	3-1,4,4,-1,-1
	VEC_CON		12,13
	VEC_CON		13,15
	VEC_CON		15,12

Obj_VecRep_f12:		;front bottom
	VEC_FACE	3-1,4,4,-1,-1
	VEC_CON		15,13
	VEC_CON		13,14
	VEC_CON		14,15

Obj_VecRep_f13:		;back top
	VEC_FACE	3-1,4,4,-1,-1
	VEC_CON		16,19
	VEC_CON		19,17
	VEC_CON		17,16

Obj_VecRep_f14:		;back bottom
	VEC_FACE	3-1,4,4,-1,-1
	VEC_CON		17,19
	VEC_CON		19,18
	VEC_CON		18,17

Obj_VecRep_f15:		;top left
	VEC_FACE	4-1,5,5,-1,-1
	VEC_CON		16,12
	VEC_CON		12,15
	VEC_CON		15,19
	VEC_CON		19,16

Obj_VecRep_f16:		;top right
	VEC_FACE	4-1,6,6,-1,-1
	VEC_CON		12,16
	VEC_CON		16,17
	VEC_CON		17,13
	VEC_CON		13,12

Obj_VecRep_f17:		;bot left
	VEC_FACE	4-1,6,6,-1,-1
	VEC_CON		19,15
	VEC_CON		15,14
	VEC_CON		14,18
	VEC_CON		18,19

Obj_VecRep_f18:		;bot right
	VEC_FACE	4-1,5,5,-1,-1
	VEC_CON		13,17
	VEC_CON		17,18
	VEC_CON		18,14
	VEC_CON		14,13


