	IFND _OBJ_CUBE12
_OBJ_CUBE12 SET 1
	ELSE
_OBJ_CUBE12 SET _OBJ_CUBE12+1
	ENDC


OBJ_CUBE12_NUMPTS = 24
Obj_Cube12_Info:
	dc.w	0			; initialised (happens on first load)
	dc.w	0,0,0			; pos, x,y,z
	dc.w	0,0,0			; current rotation, x,y,z
	dc.w	1,2,3			; Rotation step, x,y,z
	dc.w	1			; Complex 1/0
	dc.w	2			; Num frames min
	dc.l	Obj_Cube12_PtsBuffer	; Pts ptr (in use/buffer)
	dc.l	Obj_Cube12_Pts_CubeSmall	; Initial points ptr
	dc.l	Obj_Cube12_Facelist	; Facelist ptr
	dc.w	0,0,0			; Morph active flag, counter, speed

; Points are loaded to here from Ob1_Pts. So can do transforms without
; trashing original points.
Obj_Cube12_PtsBuffer:
	ds.w	1
	ds.w	3*OBJ_CUBE12_NUMPTS

Obj_Cube12_Pts_CubeSmall:
	dc.w	OBJ_CUBE12_NUMPTS-1
	dc.w -40,40,40		;0
	dc.w 40,40,40		;1
	dc.w 40,-40,40		;2
	dc.w -40,-40,40		;3

	dc.w -40,40,-40		;4
	dc.w 40,40,-40		;5
	dc.w 40,-40,-40		;6
	dc.w -40,-40,-40	;7

	dc.w 40,40,40		;8
	dc.w 40,40,-40		;9
	dc.w 40,-40,-40		;10
	dc.w 40,-40,40		;11

	dc.w -40,40,40		;12
	dc.w -40,40,-40		;13
	dc.w -40,-40,-40	;14
	dc.w -40,-40,40		;15

	dc.w -40,40,40		;16
	dc.w -40,40,-40		;17
	dc.w 40,40,-40		;18
	dc.w 40,40,40		;19

	dc.w -40,-40,40		;20
	dc.w -40,-40,-40	;21
	dc.w 40,-40,-40		;22
	dc.w 40,-40,40		;23

Obj_Cube12_Pts_Spread:
	dc.w	OBJ_CUBE12_NUMPTS-1

	;back
	dc.w -30,30,80		;0
	dc.w 30,30,80		;1
	dc.w 30,-30,80		;2
	dc.w -30,-30,80		;3

	;front
	dc.w -30,30,-80		;4
	dc.w 30,30,-80		;5
	dc.w 30,-30,-80		;6
	dc.w -30,-30,-80	;7

	;right
	dc.w 80,30,30		;8
	dc.w 80,30,-30		;9
	dc.w 80,-30,-30		;10
	dc.w 80,-30,30		;11

	;left
	dc.w -80,30,30		;12
	dc.w -80,30,-30		;13
	dc.w -80,-30,-30	;14
	dc.w -80,-30,30		;15

	;top
	dc.w -30,80,30		;16
	dc.w -30,80,-30		;17
	dc.w 30,80,-30		;18
	dc.w 30,80,30		;19

	;bottom
	dc.w -30,-80,30		;20
	dc.w -30,-80,-30	;21
	dc.w 30,-80,-30		;22
	dc.w 30,-80,30		;23

Obj_Cube12_Pts_Stack:	
	dc.w	OBJ_CUBE12_NUMPTS-1

	dc.w -30,50,30		;0
	dc.w -30,50,-30		;1
	dc.w 30,50,-30		;2
	dc.w 30,50,30		;3

	dc.w -30,-50,30		;4
	dc.w -30,-50,-30	;5
	dc.w 30,-50,-30		;6
	dc.w 30,-50,30		;7

	dc.w -30,20,30		;8
	dc.w -30,20,-30		;9
	dc.w 30,20,-30		;10
	dc.w 30,20,30		;11

	dc.w -30,-20,30		;12
	dc.w -30,-20,-30	;13
	dc.w 30,-20,-30		;14
	dc.w 30,-20,30		;15

	dc.w -30,80,30		;16
	dc.w -30,80,-30		;17
	dc.w 30,80,-30		;18
	dc.w 30,80,30		;19

	dc.w -30,-80,30		;20
	dc.w -30,-80,-30	;21
	dc.w 30,-80,-30		;22
	dc.w 30,-80,30		;23

Obj_Cube12_Pts_StackSmall:	
	dc.w	OBJ_CUBE12_NUMPTS-1

	dc.w -10,70,10		;0
	dc.w -10,70,-10		;1
	dc.w 10,70,-10		;2
	dc.w 10,70,10		;3

	dc.w -10,-70,10		;4
	dc.w -10,-70,-10	;5
	dc.w 10,-70,-10		;6
	dc.w 10,-70,10		;7

	dc.w -10,20,10		;8
	dc.w -10,20,-10		;9
	dc.w 10,20,-10		;10
	dc.w 10,20,10		;11

	dc.w -10,-20,10		;12
	dc.w -10,-20,-10	;13
	dc.w 10,-20,-10		;14
	dc.w 10,-20,10		;15

	dc.w -10,90,10		;16
	dc.w -10,90,-10		;17
	dc.w 10,90,-10		;18
	dc.w 10,90,10		;19

	dc.w -10,-90,10		;20
	dc.w -10,-90,-10	;21
	dc.w 10,-90,-10		;22
	dc.w 10,-90,10		;23

Obj_Cube12_Facelist:
	dc.w	6-1 ;6-1
	dc.l	Obj_Cube12_f1
	dc.l	Obj_Cube12_f2
	dc.l	Obj_Cube12_f3
	dc.l	Obj_Cube12_f4
	dc.l	Obj_Cube12_f5
	dc.l	Obj_Cube12_f6

Obj_Cube12_f1		;front
	VEC_FACE	4-1,1,1,1,1
	VEC_CON		4,5
	VEC_CON		5,6
	VEC_CON		6,7
	VEC_CON		7,4

Obj_Cube12_f2:		;back
	VEC_FACE	4-1,2,2,2,2
	VEC_CON		3,2
	VEC_CON		2,1
	VEC_CON		1,0
	VEC_CON		0,3

Obj_Cube12_f3		;top
	VEC_FACE	4-1,3,3,3,3
	VEC_CON		19,18
	VEC_CON		18,17
	VEC_CON		17,16
	VEC_CON		16,19	

Obj_Cube12_f4		;bottom
	VEC_FACE	4-1,4,4,4,4
	VEC_CON		20,21
	VEC_CON		21,22
	VEC_CON		22,23
	VEC_CON		23,20		

Obj_Cube12_f5		;left
	VEC_FACE	4-1,5,5,5,5
	VEC_CON		12,13
	VEC_CON		13,14
	VEC_CON		14,15
	VEC_CON		15,12

Obj_Cube12_f6		;right
	VEC_FACE	4-1,6,6,6,6
	VEC_CON		11,10
	VEC_CON		10,9
	VEC_CON		9,8
	VEC_CON		8,11


