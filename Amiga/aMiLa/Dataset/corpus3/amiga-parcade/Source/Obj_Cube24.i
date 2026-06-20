	IFND _OBJ_CUBE24
_OBJ_CUBE24 SET 1
	ELSE
_OBJ_CUBE24 SET _OBJ_CUBE24+1
	ENDC

OBJ_CUBE24_NUMPTS = 14
Obj_Cube24_Info:
	dc.w	0			; initialised (happens on first load)
	dc.w	0,0,0			; pos, x,y,z
	dc.w	0,0,0			; current rotation, x,y,z
	dc.w	0,0,0			; Rotation step, x,y,z
	dc.w	0			; Complex 1/0
	dc.w	1			; Num frames max
	dc.l	Obj_Cube24_PtsBuffer	; 22 - Pts ptr (in use/buffer)
	dc.l	Obj_Cube24_Pts_Cube	; 26 - Initial points ptr
	dc.l	Obj_Cube24_Facelist	; 30 - Facelist ptr
	dc.w	0,0,0			; Morph active flag, counter, speed

; Points are loaded to here from Obj_Cube24_Pts. So can do transforms without
; trashing original points.
Obj_Cube24_PtsBuffer:
	ds.w	1
	ds.w	3*OBJ_CUBE24_NUMPTS

Obj_Cube24_Pts_Cube:	;CUBE
	; points defined looking at object from the front
	; postitive x = up, y = right, z = forward
	dc.w	OBJ_CUBE24_NUMPTS-1
	dc.w	-50,50,-50	;0 front top left
	dc.w	50,50,-50	;1 front top right
	dc.w	50,-50,-50	;2 front bottom right
	dc.w	-50,-50,-50	;3 front bottom left

	dc.w	-50,50,50	;4 back top left
	dc.w	50,50,50	;5 back top right
	dc.w	50,-50,50	;6 back bottom right
	dc.w	-50,-50,50	;7 back bottom left

	dc.w	0,0,-50		;8 front middle
	dc.w	0,0,50		;9 back middle
	dc.w	0,50,0		;10 top middle
	dc.w	0,-50,0		;11 bottom middle
	dc.w	50,0,0		;12 right middle
	dc.w	-50,0,0		;13 left middle

Obj_Cube24_Pts_CubeSmall:	;CUBE
	; points defined looking at object from the front
	; postitive x = up, y = right, z = forward
	dc.w	OBJ_CUBE24_NUMPTS-1
	dc.w	-40,40,-40	;0 front top left
	dc.w	40,40,-40	;1 front top right
	dc.w	40,-40,-40	;2 front bottom right
	dc.w	-40,-40,-40	;3 front bottom left

	dc.w	-40,40,40	;4 back top left
	dc.w	40,40,40	;5 back top right
	dc.w	40,-40,40	;6 back bottom right
	dc.w	-40,-40,40	;7 back bottom left

	dc.w	0,0,-40		;8 front middle
	dc.w	0,0,40		;9 back middle
	dc.w	0,40,0		;10 top middle
	dc.w	0,-40,0		;11 bottom middle
	dc.w	40,0,0		;12 right middle
	dc.w	-40,0,0		;13 left middle

Obj_Cube24_Facelist:
	dc.w	24-1 ;6-1
	dc.l	Obj_Cube24_f1
	dc.l	Obj_Cube24_f2
	dc.l	Obj_Cube24_f3
	dc.l	Obj_Cube24_f4
	dc.l	Obj_Cube24_f5
	dc.l	Obj_Cube24_f6
	dc.l	Obj_Cube24_f7
	dc.l	Obj_Cube24_f8
	dc.l	Obj_Cube24_f9
	dc.l	Obj_Cube24_f10
	dc.l	Obj_Cube24_f11
	dc.l	Obj_Cube24_f12
	dc.l	Obj_Cube24_f13
	dc.l	Obj_Cube24_f14
	dc.l	Obj_Cube24_f15
	dc.l	Obj_Cube24_f16
	dc.l	Obj_Cube24_f17
	dc.l	Obj_Cube24_f18
	dc.l	Obj_Cube24_f19
	dc.l	Obj_Cube24_f20
	dc.l	Obj_Cube24_f21
	dc.l	Obj_Cube24_f22
	dc.l	Obj_Cube24_f23
	dc.l	Obj_Cube24_f24

; Connections should be defined in as if you were facing that side in clockwise order
Obj_Cube24_f1:	;front, top tri, white
	VEC_FACE	3-1,1,1,-1,-1
	VEC_CON		8,0
	VEC_CON		0,1
	VEC_CON		1,8

Obj_Cube24_f2: ;front, right tri, trans
	VEC_FACE	3-1,2,2,-1,-1
	VEC_CON		8,1
	VEC_CON		1,2
	VEC_CON		2,8

Obj_Cube24_f3:	;front, bot tri, white
	VEC_FACE	3-1,1,1,-1,-1
	VEC_CON		8,2
	VEC_CON		2,3
	VEC_CON		3,8

Obj_Cube24_f4: ;front, left tri, trans
	VEC_FACE	3-1,2,2,-1,-1
	VEC_CON		8,3
	VEC_CON		3,0
	VEC_CON		0,8

Obj_Cube24_f5:	;back, top tri, white
	VEC_FACE	3-1,1,1,-1,-1
	VEC_CON		9,5
	VEC_CON		5,4
	VEC_CON		4,9

Obj_Cube24_f6: ;back, right tri, trans
	VEC_FACE	3-1,2,2,-1,-1
	VEC_CON		9,4
	VEC_CON		4,7
	VEC_CON		7,9

Obj_Cube24_f7:	;back, bot tri, white
	VEC_FACE	3-1,1,1,-1,-1
	VEC_CON		9,7
	VEC_CON		7,6
	VEC_CON		6,9

Obj_Cube24_f8: ;back, left tri, trans
	VEC_FACE	3-1,2,2,-1,-1
	VEC_CON		9,6
	VEC_CON		6,5
	VEC_CON		5,9

Obj_Cube24_f9:	;top, top tri, trans
	VEC_FACE	3-1,4,4,-1,-1
	VEC_CON		10,4
	VEC_CON		4,5
	VEC_CON		5,10

Obj_Cube24_f10: ;top, right tri, white
	VEC_FACE	3-1,3,3,-1,-1
	VEC_CON		10,5
	VEC_CON		5,1
	VEC_CON		1,10

Obj_Cube24_f11:	;top, bot tri, trans
	VEC_FACE	3-1,4,4,-1,-1
	VEC_CON		10,1
	VEC_CON		1,0
	VEC_CON		0,10

Obj_Cube24_f12: ;top, left tri, white
	VEC_FACE	3-1,3,3,-1,-1
	VEC_CON		10,0
	VEC_CON		0,4
	VEC_CON		4,10

Obj_Cube24_f13:	;bot, top tri, trans
	VEC_FACE	3-1,4,4,-1,-1
	VEC_CON		11,3
	VEC_CON		3,2
	VEC_CON		2,11

Obj_Cube24_f14: ;bot, right tri, white
	VEC_FACE	3-1,3,3,-1,-1
	VEC_CON		11,2
	VEC_CON		2,6
	VEC_CON		6,11

Obj_Cube24_f15:	;bot, bot tri, trans
	VEC_FACE	3-1,4,4,-1,-1
	VEC_CON		11,6
	VEC_CON		6,7
	VEC_CON		7,11

Obj_Cube24_f16: ;bot, left tri, white
	VEC_FACE	3-1,3,3,-1,-1
	VEC_CON		11,7
	VEC_CON		7,3
	VEC_CON		3,11

Obj_Cube24_f17: ;right, top tri, trans
	VEC_FACE	3-1,6,6,-1,-1
	VEC_CON		12,1
	VEC_CON		1,5
	VEC_CON		5,12

Obj_Cube24_f18: ;right, right tri, white
	VEC_FACE	3-1,5,5,-1,-1
	VEC_CON		12,5
	VEC_CON		5,6
	VEC_CON		6,12

Obj_Cube24_f19: ;right, bot tri, trans
	VEC_FACE	3-1,6,6,-1,-1
	VEC_CON		12,6
	VEC_CON		6,2
	VEC_CON		2,12

Obj_Cube24_f20: ;right, left tri, white
	VEC_FACE	3-1,5,5,-1,-1
	VEC_CON		12,2
	VEC_CON		2,1
	VEC_CON		1,12

Obj_Cube24_f21: ;left, top tri, trans
	VEC_FACE	3-1,6,6,-1,-1
	VEC_CON		13,4
	VEC_CON		4,0
	VEC_CON		0,13

Obj_Cube24_f22: ;left, right tri, white
	VEC_FACE	3-1,5,5,-1,-1
	VEC_CON		13,0
	VEC_CON		0,3
	VEC_CON		3,13

Obj_Cube24_f23: ;left, bot tri, trans
	VEC_FACE	3-1,6,6,-1,-1
	VEC_CON		13,3
	VEC_CON		3,7
	VEC_CON		7,13

Obj_Cube24_f24: ;left, left tri, white
	VEC_FACE	3-1,5,5,-1,-1
	VEC_CON		13,7
	VEC_CON		7,4
	VEC_CON		4,13


