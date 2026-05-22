
*******	Returns pointer to ImageData and number of words of data

; Entry		a0->Image Structure

; Exit		a0->ImageData
;		d1=number of words in image

; Corrupt	d1,d0,a0

ImDataSize	moveq.l		#0,d1
		move.w		ig_Width(a0),d1
		moveq.l		#0,d0
		ror.l		#4,d1
		move.w		d1,d0
		swap		d1
		tst.w		d1
		beq.s		.Multiple
		addq.w		#1,d0

.Multiple	moveq.l		#0,d1
		move.w		ig_Height(a0),d1
		mulu		d1,d0
		
		move.w		ig_Depth(a0),d1
		mulu		d1,d0
		
		move.l		ig_ImageData(a0),a0
		rts
		
	

