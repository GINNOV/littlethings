
; Test my IFF-ILBM save routine on a LoRes piccy.

		incdir		sys:include/
		include		exec/exec_lib.i
		include		libraries/dos_lib.i
		include		libraries/dosextens.i

Start		lea		dosname,a1		lib name
		moveq.l		#0,d0			any version
		CALLEXEC	OpenLibrary		open DOS
		move.l		d0,_DOSBase		save pointer
		beq		Error			exit on error

; Copy bitplane addresses into structure

		lea		Gfx,a0			a0->raw data
		move.l		#(320/8)*200,d0		bitplane size
		lea		Bpl,a1			a1->struct

		move.l		a0,(a1)+		save bpl address
		add.l		d0,a0			bump to next plane
		move.l		a0,(a1)+		save bpl address
		add.l		d0,a0			bump to next plane
		move.l		a0,(a1)+		save bpl address
		add.l		d0,a0			bump to next plane
		move.l		a0,(a1)+		save bpl address
		add.l		d0,a0			bump to next plane

; And CMAP ( behind bitplanes )

		move.l		a0,Cmap			addr of CMAP

; Save piccy as an IFF-ILBM file ( I hope :-)

		lea		IffSaveStruct,a0	structure
		bsr		IffSave			save file

; Close DOS library

		move.l		_DOSBase,a1		libbase
		CALLEXEC	CloseLibrary		and close it!
		
Error		moveq.l		#0,d0
		rts

		include		IffSave.i


		even
		
dosname		DOSNAME

_DOSBase	dc.l		0


IffSaveStruct	dc.l		filename	pointer to file name
Bpl		dc.l		0		pointer to 1st bitplane
		dc.l		0		           2nd
		dc.l		0		           3rd
		dc.l		0		           4th
		dc.l		0		           5th
		dc.l		0		           6th
Cmap		dc.l		0		pointer to colour map
		dc.w		320		width
		dc.w		200		height
		dc.w		4		depth
		dc.w		0		special modes (HAM,EHB etc )
		dc.w		0		no modulo!

filename	dc.b		'ram:test.iff',0
		even

Gfx		incbin		piccy.raw
