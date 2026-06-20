

*****	IFF - ILBM file save subroutine, M.Meany 1992.

; This very crude routine does not take advantage of the finer points of the
;IFF-ILBM format, but it will allow you to save a picture to disk!

; No error checking is done on the data you supply -- get it right;-)

; Entry		a0->a completed structure as defined below
;		dos.library open and base pointer in _DOSBase

; Exit		d0=0 if file saved OK, structure will be cleared!!!
;		d0 is non-zero if a file error occurred!!!

; If the ilbms_modes field of the structure is zero, routine will make a
;wild guess at suitable modes to use. Best way to get the modes you really
;want is to define them yourself.

; 452 bytes ( +44 bytes for required structure )

IffSave		movem.l		d1-d7/a0-a6,-(sp)	save 'em

		bsr		GuessIffModes		get display modes

		move.l		a0,a5			param into safe reg

		moveq.l		#1,d7			set for error

		moveq.l		#0,d5
		move.w		ilbms_Modulo(a5),d5	get bpl modulo
		ext.l		d5			sign extend
		move.l		d5,-(sp)		onto stack

; Determine byte width of piccy from pixel width

		moveq.l		#0,d5			clear
		move.w		ilbms_Width(a5),d5	get pixel width
		move.w		d5,_ILBMS_Width		save in both
		move.w		d5,_ILBMS_PWidth	header location
		divu		#8,d5			get byte width
		swap		d5			check remainder to
		tst.w		d5			see if we must bump
		beq.s		.NoAdd			nope, so skip!
		add.l		#$10000,d5		bump

; If byte width is odd we must pad out line with an extra byte. Lines must be
;saved in word data multiples!

.NoAdd		move.l		d5,d0
		swap		d0
		btst		#0,d0			odd
		beq.s		.NoPad
		addq.w		#1,d0			bump to even

; Calculate the space occupied by bpl data

.NoPad		move.l		d0,-(sp)		length onto stack
		swap		d5
		mulu		ilbms_Depth(a5),d0	WxD
		mulu		ilbms_Height(a5),d0	WxHxD
		move.l		d0,_ILBMS_BSize		set chunk length
		add.l		#_ILBMS_SSIZE,d0	add header length
		subq.l		#8,d0			less 2 longs
		move.l		d0,_ILBMS_FSize		and save

; Copy other data

		move.w		ilbms_Modes(a5),_ILBMS_Modes+2
		move.w		ilbms_Height(a5),_ILBMS_Height
		move.w		ilbms_Height(a5),_ILBMS_PHeight
		move.w		ilbms_Depth(a5),d4
		move.b		d4,_ILBMS_Depth

; Copy colours - must be save as Red, Green and Blue components, one byte
;each! Since the Amiga supports less that 256 colour intensities, value
;must be shifted left ( never realised this at first:-( )

		moveq.l		#31,d0			always 32 colours
		move.l		ilbms_Colours(a5),a0	a0->CMAP
		lea		_ILBMS_Colours,a1	dest
.Cloop		move.w		(a0)+,d2		Get next RGB
		move.w		d2,d1
		and.w		#$0f00,d1		isolate RED
		asr.w		#4,d1			into high nibble
		move.b		d1,(a1)+		save RED
		
		move.w		d2,d1			Get RGB
		and.w		#$00f0,d1		isolate GREEN
		move.b		d1,(a1)+		save GREEN
		
		move.w		d2,d1			get RGB
		and.w		#$000f,d1		isolate BLUE
		asl.b		#4,d1			into high nibble
		move.b		d1,(a1)+		save BLUE
		
		dbra		d0,.Cloop		for all 32 entries

; Open the file

;		move.l		ilbms_Fname(a5),d1	filename
		move.l		(a5),d1			filename
		move.l		#MODE_NEWFILE,d2	access mode required
		CALLDOS		Open			and open it
		move.l		d0,d6			save handle
		beq		.error			exit on failure

; Write the data header

		move.l		d0,d1			handle
		move.l		#_ILBMS_Header,d2	buffer
		move.l		#_ILBMS_SSIZE,d3	size
		jsr		_LVOWrite(a6)		and write it

; now write the bitplane data in interleave format

		moveq.l		#0,d4			clear
		move.w		ilbms_Height(a5),d4	get height
		subq.w		#1,d4			dbra adjust
		lea		ilbms_bpl1(a5),a4	a4->bpl pointers
		move.l		#0,ilbms_Colours(a5)	clear
		
.OuterLoop	move.l		a4,a3
.InnerLoop	move.l		(a3),d0			get next pointer
		beq		.Next			skip if no more
		
		move.l		d0,d2			Address of data
		add.l		d5,d0			bump to next line
		add.l		4(sp),d1		add modulo
		move.l		d0,(a3)+		and save
		
		move.l		d6,d1			handle
		move.l		(sp),d3			size
		jsr		_LVOWrite(a6)		save
		bra.s		.InnerLoop		and loop

.Next		dbra		d4,.OuterLoop		for all lines

		move.l		d6,d1			handle
		jsr		_LVOClose(a6)		close it
		
		moveq.l		#0,d7

.error		move.l		d7,d0			set return code
		addq.l		#8,sp			flush stack
		movem.l		(sp)+,d1-d7/a0-a6	restore
		rts

; file header for IFF - ILBM file.

; first the FORM chunk

_ILBMS_Header	dc.b		'FORM'
_ILBMS_FSize	dc.l		0			file length-calculate
		dc.b		'ILBM'

; the BMHD chunk

		dc.b		'BMHD'
		dc.l		20
_ILBMS_Width	dc.w		0			pixel width
_ILBMS_Height	dc.w		0			pixel height
		dc.w		0
		dc.w		0
_ILBMS_Depth	dc.b		0			depth
		dc.b		0
		dc.b		0
		dc.b		0
		dc.w		0
		dc.b		10			EA say so (320x200)
		dc.b		11
_ILBMS_PWidth	dc.w		0
_ILBMS_PHeight	dc.w		0

; the CMAP chunk

		dc.b		'CMAP'
		dc.l		32*3			size - 32 colours
_ILBMS_Colours	ds.b		32*3

; the CAMG chunk

		dc.b		'CAMG'
		dc.l		4
_ILBMS_Modes	dc.l		0

; the start of the BODY chunk, data will be added after!

; the BODY chunk

		dc.b		'BODY'
_ILBMS_BSize	dc.l		0			size of this chunk

_ILBMS_SSIZE	equ		*-_ILBMS_Header		size of header

; Structure used by IffSave. This must be prepared prior to calling. Fields
;marked with an * must be set, others may be initialised to zero.

		rsreset
ilbms_Fname	rs.l		1			* address of filename
ilbms_bpl1	rs.l		1			* bitplane 1 address
ilbms_bpl2	rs.l		1			bitplane 2 address
ilbms_bpl3	rs.l		1			bitplane 3 address
ilbms_bpl4	rs.l		1			bitplane 4 address
ilbms_bpl5	rs.l		1			bitplane 5 address
ilbms_bpl6	rs.l		1			bitplane 6 address
ilbms_Colours	rs.l		1			* address of CMAP
ilbms_Width	rs.w		1			* pixel width
ilbms_Height	rs.w		1			* line height
ilbms_Depth	rs.w		1			* depth
ilbms_Modes	rs.w		1			view modes or NULL
ilbms_Modulo	rs.w		1			bpl modulo value


*****	Makes a guess at what screen modes to use for file being saved.

; This routine has been supplied seperately as it's prone to get the wrong
;idea. Set the ilbms_Modes field yourself if you can, use this as a last
;resort.

; Entry		a0->Structure prior to passing to IffSave

; Exit		ilbms_Modes will be set with something???

GuessIffModes	tst.l		ilbms_Modes(a0)		mode set already?
		bne.s		.done			yes, exit now

; Check for six bitplanes, set for HAM mode if present.

		tst.l		ilbms_bpl6(a0)		plane 6 set?
		beq.s		.NotHam			no, skip HAM

		move.w		#$0800,ilbms_Modes(a0)	else set HAM mode
		bra.s		.done			and exit

; If width > 320, set HiRes

.NotHam		cmpi.w		#320,ilbms_Width(a0)	check width
		ble.s		.TryLace		not HiRes, skip
		move.w		#$8000,ilbms_Modes(a0)	else set HiRes

; if height > 256, set LACE

.TryLace	cmpi.w		#256,ilbms_Height(a0)	check height
		ble.s		.done			not interlace, skip
		or.w		#$0004,ilbms_Modes(a0)	else set interlace

.done		rts



