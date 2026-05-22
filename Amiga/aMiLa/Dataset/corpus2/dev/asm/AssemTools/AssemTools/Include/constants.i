
; CONSTANTS.I  v1.3	22.06.89
; 
; created 21.05.89 Supervisor Software/TM
; 
; Amiga Macro Assembler Constant Equation File

		ifnd	memf_public
memf_public	equ	1
memf_chip	equ	2
memf_fast	equ	4
memf_clear	equ	1<<16
memf_largest	equ	1<<17
memf_def	equ	memf_public
		endc

		ifnd	drmd_jam1
drmd_jam1	equ	0
drmd_jam2	equ	1
drmd_complement	equ	2
drmd_inversvid	equ	4
		endc

		ifnd	style_bold
style_bold	equ	2
style_italic	equ	4
style_underline	equ	1
		endc

		ifnd	open_read
open_read	equ	0
open_write	equ	1
open_append	equ	2
open_quiet	equ	8
		endc

		ifnd	mode_oldfile
mode_oldfile	equ	1005
mode_newfile	equ	1006
access_read	equ	-2
access_write	equ	-1
		endc

		ifnd	fib_type
fib_type	equ	4
fib_name	equ	8
fib_bytes	equ	124
fib_blocks	equ	128
fib_sizeof	equ	260
fib_SIZEOF	equ	260
		endc

		ifnd	MEMF_PUBLIC
MEMF_PUBLIC	equ	1
MEMF_CHIP	equ	2
MEMF_FAST	equ	4
MEMF_CLEAR	equ	1<<16
MEMF_LARGEST	equ	1<<17
MEMF_DEF	equ	MEMF_PUBLIC
		endc

		ifnd	RP_JAM1
RP_JAM1		equ	0
RP_JAM2		equ	1
RP_COMPLEMENT	equ	2
RP_INVERSVID	equ	4
		endc

		ifnd	LF
LF		set	10
		endc

		ifnd	CSI
CSI		set	$9b
		endc

		ifnd	TAB
TAB		set	9
		endc

		ifnd	SPC
SPC		set	32
		endc

		ifnd	CR
CR		set	13
		endc

		ifnd	FF
FF		set	12
		endc


