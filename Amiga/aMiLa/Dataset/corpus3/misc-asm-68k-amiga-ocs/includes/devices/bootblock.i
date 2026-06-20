	IFND	DEVICES_BOOTBLOCK_I
DEVICES_BOOTBLOCK_I	SET	1
	rsreset
BB	rs.b	0
BB_ID	rs.b	4
BB_CHKSUM	rs.l	1
BB_DOSBLOCK	rs.l	1
BB_ENTRY	rs.w	0
BB_SIZE	rs.w	0
BOOTSECTS	equ	2
BBID_DOS	macro
	dc.b	'DOS',0
	endm
BBID_KICK	macro
	dc.b	'KICK'
	endm
BBNAME_DOS	EQU	(('D'<<24)!('O'<<16)!('S'<<8))
BBNAME_KICK	EQU	(('K'<<24)!('I'<<16)!('C'<<8)!('K'))
	ENDC

