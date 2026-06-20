


		XREF	_LVOOpenLibrary		;so that linker sees the
		XREF	_LVOCloseLibrary	; symbols
		XREF	_LVODelay


		move.l	4,a6		;get base address of exec library
		lea	dosname,a1	;name of library to be opened
		moveq.l	#0,d0		;version (every version is OK)
		jsr	_LVOOpenLibrary(a6) ;try to open dos.library
		move.l	d0,dospointer	;save dos library base address
		beq	exit		;exit if zero (means an error)

		move.l	d0,a6		;get dosbase
		move.l	#100,d1		;delay value 100/50 = 2 seconds
		jsr	_LVODelay(a6)	;call delay routine in dos.library

		move.l	4,a6		;get execbase again
		move.l	dospointer,a1	;library to be closed
		jsr	_LVOCloseLibrary(a6) ;close it

exit		rts


dospointer	dc.l	0		;space for dos lib pointer
dosname		dc.b	'dos.library',0	;library name (NULL terminated)
		even			;align to word boundary

		end

