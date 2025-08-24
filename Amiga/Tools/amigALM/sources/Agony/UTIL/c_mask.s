
; routine de creation de mask pour le "Twilight Foreground Editor" en GFA
; -----------------------------------------------------------------------

Start
	move.l	bpl0(sp),a0
	move.l	bpl1(sp),a1
                  move.l	bpl2(sp),a2
                  move.l	bpl3(sp),a3
                  move.l	bpl4(sp),a4
	moveq	#20,d2
                  sub	dx(sp),d2
                  add	d2,d2
	move	dy(sp),d0
	subq    #1,d0	;d0 delta y (line)
loop_y
	move	dx(sp),d1
	subq	#1,d1	;d1 delta x (word)
loop_x
	move	(a0),d3
	or	(a1),d3
	or	(a2),d3
	or	(a3),d3
	or	(a4),d3
	move	d3,(a0)+
	move	d3,(a1)+
	move	d3,(a2)+
	move	d3,(a3)+
	move	d3,(a4)+
	dbra	d1,loop_x
	add	d2,a0
	add	d2,a1
	add	d2,a2
	add	d2,a3
	add	d2,a4
	dbra	d0,loop_y
	rts
Stop

	rsreset
return	rs.l	1
bpl0	rs.l	1
bpl1	rs.l	1
bpl2	rs.l	1
bpl3	rs.l	1
bpl4	rs.l	1
dx	rs.w	1
dy	rs.w	1
