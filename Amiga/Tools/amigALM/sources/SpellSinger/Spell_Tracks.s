
*****************************************************************************

*                 ID TRACKS

*****************************************************************************



* CONSTANTES
* ----------


TB_Num	EQU     8	; Maximum number of tracks buffers
Window_Size	EQU	512



* TRY
* ---


	move	#130,d0
	bsr	Tracks_Init


   	rts



* ROUTINE
* -------


Tracks_Init	; D0 = INITIAL POS X (left)	INITIALISE ID TRACKS

	bsr	Tracks_Locate

	rts



Tracks_Update	; D0 = NEW POS X	UPDATE TRACKS BUFFERS




	rts



Tracks_Locate	; D0 = NEW POS X            LOCATE TRACKS WINDOW AT A NEW POS X
	;		& (RE)BUILD ALL SIZE OF BUFFERS
	bsr	Tracks_Init_Stack

	move	d0,d2	; d2=wanted window left X edge
	add	#Window_Size,d0	; d0=wanted window right X edge

	lea	T_List_Frwd,a0
.loop
	move	(a0)+,d1	; get d1=track x1 in start list
	bmi	.exit
	cmp	d1,d0               ; if track x1 > Window right X edge
	bgt	.exit	; then exit
	cmp	(a0)+,d2
	blt     .good               ; if track x2 <= Window left X Edge
	lea	2(a0),a0            ; then reloop (not good)
	bra	.loop
.good
                  move.l	(a0)+,a1	; a1 ptr on Track to start
	move.l	TB_Stack_Ptr,a2	; a2 sp on alloc stack
	move.l	(a2),a2	; a2 ptr on free track buffer struct
	addq.l	#4,TB_Stack_Ptr
                  move.l	TB_Last_Struct,a3	; add new TB Struct in chained list
	bne	.no_first
	move.l	a2,TB_First_Struct
	move.l	a2,(a3)
	clr.l	TBS_Prev(a2)
	clr.l	TBS_Next(a2)
                  bra 	.cont
.no_first
	move.l	(a3),a4             ; a4=last struct buff
	move.l	a2,TBS_Next(a4)	; next struct in last struct
	move.l	a2,(a3)	; new struct in last struct ptr
	move.l	a4,TBS_Prev(a2)
	clr.l	TBS_Next(a2)
.cont
	move	(a1)+,d3	: get d3=track Y start in track struct
	lea	2(a1),a1	; pass end ctrl



                  bra	.loop
.exit
	lea	-2(a0),a0
	move.l	a0,T_List_Frwd_Ptr
                  rts



Tracks_Init_Stack	;		INITIALISE ALLOC STACK

	lea	TB_Alloc_Stack,a0
	move.l	a0,TB_Stack_Ptr	; init TB stack ptr at end of the stack

                  move.l	#Tracks_Buff,d7	; fill TB stack with TB Structs ptr
	moveq	#TB_Num-1,d1
.loop
	move.l	d7,(a0)+
	add.l	#TB_Sizeof,d7
	dbra	d1,.loop

	clr.l	TB_First_Struct	; reset chained list
	clr.l	TB_Last_Struct

	rts



* TRACKS DESCRIPTION
* ------------------


T0_Start
	DC.W	50	; Y start
	DC.B	1,0	; dx,dy if dx=1 => Track End Ctrl
	DC.B	10,10	; dx0,dy0
	DC.B	100,20              ;   .
	DC.B	200,-10             ;   .
	DC.B	100,5               ;   .
	DC.B	200,10              ;   .
	DC.B    20,-10	; dx4,dy4
	DC.B	1,0	; Track End
T0_Stop	DC.W	75	; Y stop

T1_Start
	DC.W	100
	DC.B	1,0
	DC.B    80,20
	DC.B	40,-10
	DC.B	1,0
T1_Stop	DC.W	110

T2_Start
	DC.W	150
	DC.B	1,0
                  DC.B	40,5
	DC.B	1,0
T2_Stop	DC.W	155

T3_Start
	DC.W	120
	DC.B    1,0
	DC.B	50,10
	DC.B	50,-20
	DC.B	1,0
T3_Stop	DC.W	110

T4_Start
	DC.W	110
	DC.B	1,0
	DC.B	250,20
	DC.B	250,15
	DC.B	250,-5
	DC.B	1,0
T4_Stop	DC.W	140

T_List_Frwd
	DC.W	10	; T0 x1
	DC.W	639	; T0 x2
	DC.L	T0_Start	; T0 Start track ptr

	DC.W	600     	; T1 ...
	DC.W	719
	DC.L	T1_Start

	DC.W	650	; T2 ...
	DC.W	689
	DC.L	T2_Start

	DC.W	700
	DC.W	799
	DC.L	T3_Start

	DC.W	750
	DC.W	1499
	DC.L	T4_Start

	DC.W	-1	; END

T_List_Back
	DC.W	639	; T0 x2
	DC.L	T0_Stop	; T0 Stop track ptr
	DC.W	689
	DC.L	T2_Stop
	DC.W	719
	DC.L	T1_Stop
	DC.W    799
	DC.L	T3_Stop
	DC.W	1499
	DC.L	T4_Stop
	DC.W	-1



* DATA
* ----


	RSRESET		; TRACK BUFF STRUCT
TBS_Prev	RS.L	1	; ptr on prev track struct
TBS_Next	RS.L	1	; ptr on next track struct (0=end)
TB_Track_Ptr	RS.L	1	; ptr on source trzck info (lines)
TB_X_Start	RS.W	1	; X coordinate of track part in buffer
TB_R_Off	RS.W	1	; read offs on buff for ID use
TB_R_Len	RS.W	1	; len of valide data for ID use
TB_W_Off	RS.W	1                   ; write offs on buff to construct data
TB_Build_Mode	RS.W	1	; mode: 0->begining 1->progretion 2->endind
TB_Data_Y	RS.W	Window_Size	; data for all y coordinate
TB_Data_Attr	RS.B	Window_Size	; data for all attribute
TB_Sizeof	RS.B	0	; size of this struct

Tracks_Buff
	DS.B	TB_Sizeof*TB_Num	; memory for all TB Struct

TB_Alloc_Stack			; end of dynamic allocation stack
	DS.L    TB_Num	; for TB Struct
TB_Stack_Ptr
	DS.L	1	; stack ptr for alloc stack
TB_First_Struct
	DS.L	1	; ptr on first struct of chained list
TB_Last_Struct
	DS.L	1	; ptr on last struct of chained list

T_Window_X_Left
	DS.W	1                   ; left coordinate of ID-used window for tracks
T_List_Frwd_Ptr
	DS.L	1	; ptr on tracks list forward











