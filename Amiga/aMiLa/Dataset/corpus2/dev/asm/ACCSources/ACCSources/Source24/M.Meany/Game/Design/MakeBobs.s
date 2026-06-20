
; Small program that will 'make' a binary file for the game. Must write a
;screen designer/editor!

; Change name of files to 'incbin' and so join together.
; Change name of destination file.
; assemble and run.

		incdir		sys:include/
		include		exec/exec_lib.i
		include		libraries/dos_lib.i
		include		libraries/dosextens.i



Start		lea		dosname,a1
		moveq.l		#0,d0
		CALLEXEC	OpenLibrary
		move.l		d0,_DOSBase
		beq		Error
		
		move.l		#filename,d1
		move.l		#MODE_NEWFILE,d2
		CALLDOS		Open
		move.l		d0,d7
		beq		Error1
		
		move.l		d7,d1
		move.l		#Binary,d2
		move.l		#FileLen,d3
		CALLDOS		Write
		
		move.l		d7,d1
		CALLDOS		Close

Error1		move.l		_DOSBase,a1
		CALLEXEC	CloseLibrary

Error		rts


dosname		dc.b		'dos.library',0
		even
_DOSBase	dc.l		0

; This lot was used to build ships binary file!

filename dc.b	'source:m.meany/game/game/Bobs.bm',0
		even

ID_Player	equ		1<<0		players bob
ID_Bullet	equ		1<<1		bob is a players bullet
ID_Deadly	equ		1<<2		enemy bullet
ID_Points	equ		1<<3		picked up for points
ID_NRG		equ		1<<4		picked up for energy
ID_Power	equ		1<<5		picked up for fire power
ID_Screen	equ		1<<6		part of screen: go under it!


		incdir	source:m.meany/game/design/

Binary		dc.l		11			11 bobs to declare

; The players bob		
		
		dc.l		ID_Player		bob type
		dc.l		1			word width
		dc.l		18			line height
		dc.l		16			X
		dc.l		16			Y
		incbin		'bitmaps/N.bm'
		incbin		'bitmaps/N_Mask.bm'
		incbin		'bitmaps/NE.bm'
		incbin		'bitmaps/NE_Mask.bm'
		incbin		'bitmaps/E.bm'
		incbin		'bitmaps/E_Mask.bm'
		incbin		'bitmaps/SE.bm'
		incbin		'bitmaps/SE_Mask.bm'
		incbin		'bitmaps/S.bm'
		incbin		'bitmaps/S_Mask.bm'
		incbin		'bitmaps/SW.bm'
		incbin		'bitmaps/SW_Mask.bm'
		incbin		'bitmaps/W.bm'
		incbin		'bitmaps/W_Mask.bm'
		incbin		'bitmaps/NW.bm'
		incbin		'bitmaps/NW_Mask.bm'

; bullet 0

		dc.l		ID_Bullet		bob type
		dc.l		1			word width
		dc.l		6			line height
		incbin		'bitmaps/bullet.bm'
		incbin		'bitmaps/bullet_Mask.bm'

; bullet 1

		dc.l		ID_Bullet		bob type
		dc.l		1			word width
		dc.l		6			line height
		incbin		'bitmaps/bullet.bm'
		incbin		'bitmaps/bullet_Mask.bm'

; bullet 2

		dc.l		ID_Bullet		bob type
		dc.l		1			word width
		dc.l		6			line height
		incbin		'bitmaps/bullet.bm'
		incbin		'bitmaps/bullet_Mask.bm'

; bullet 3

		dc.l		ID_Bullet		bob type
		dc.l		1			word width
		dc.l		6			line height
		incbin		'bitmaps/bullet.bm'
		incbin		'bitmaps/bullet_Mask.bm'

; bullet 4

		dc.l		ID_Bullet		bob type
		dc.l		1			word width
		dc.l		6			line height
		incbin		'bitmaps/bullet.bm'
		incbin		'bitmaps/bullet_Mask.bm'

; bullet 5

		dc.l		ID_Bullet		bob type
		dc.l		1			word width
		dc.l		6			line height
		incbin		'bitmaps/bullet.bm'
		incbin		'bitmaps/bullet_Mask.bm'

; bullet 6

		dc.l		ID_Bullet		bob type
		dc.l		1			word width
		dc.l		6			line height
		incbin		'bitmaps/bullet.bm'
		incbin		'bitmaps/bullet_Mask.bm'

; bullet 7

		dc.l		ID_Bullet		bob type
		dc.l		1			word width
		dc.l		6			line height
		incbin		'bitmaps/bullet.bm'
		incbin		'bitmaps/bullet_Mask.bm'

; bullet 8

		dc.l		ID_Bullet		bob type
		dc.l		1			word width
		dc.l		6			line height
		incbin		'bitmaps/bullet.bm'
		incbin		'bitmaps/bullet_Mask.bm'

; bullet 9

		dc.l		ID_Bullet		bob type
		dc.l		1			word width
		dc.l		6			line height
		incbin		'bitmaps/bullet.bm'
		incbin		'bitmaps/bullet_Mask.bm'

FileLen		equ		*-Binary
