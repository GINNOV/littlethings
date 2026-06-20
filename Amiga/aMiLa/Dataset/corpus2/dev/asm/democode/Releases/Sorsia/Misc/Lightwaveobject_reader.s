;routine to load lw-object file, no extras, so it's easy to expand suit your needs
;reads only triangles!

;a0 lightwave files start address
;a3 coordinate buffer(x.w,y.w,z.w...)
;a4 polygon buffer(ptr1.w,ptr2.w,ptr3.w)
;nurkat = number of vertices-1
;tasot = number of polygons-1

		cmp.l		#'LWOB',8(a0)
		bne.w		paskakappale
		move.l		a0,a5
lwloop:		addq.w		#1,a0
		cmp.l		#'PNTS',(a0)
		bne.s		lwloop
		addq.l		#4,a0
		move.l		(a0)+,d0
		divs		#12,d0
		subq.w		#1,d0
		move.w		d0,nurkat
lwpoints:	rept		3
		fmove.s		(a0)+,fp0
		fmove.w		fp0,(a3)+
		endr
		dbf		d0,lwpoints
		subq.w		#1,a0
lwloop2:
		moveq.l		#0,d5
		addq.w		#1,a0
		subq.l		#1,koko
		beq.b		loppu2
		cmp.l		#'POLS',(a0)
		bne.s		lwloop2
		addq.w		#4,a0

		move.l		a4,a6
		move.l		(a0)+,d7 ;tavujen m‰‰r‰ t‰ss‰ hunkissa
lwpoly:		move.w		(a0)+,d6
		subq.l		#2,d7
		beq.b		loppu2
lwpoly2:	move.w		(a0)+,(a4)+
		subq.l		#2,d7
		beq.b		loppu2
		dbf		d6,lwpoly2
		addq.w		#1,d5
		tst.l		d7
		bne.s		lwpoly

loppu2:		move.w		d5,tasot
