; Graphics bitmaps
; $VER: Include v1.00 / PH v2.58
; (C) Mika Lundell
;
; This source code is part of the PopHelp package.
; Freeware, use it as you like.

_MpLLogo_	macro	; 96*10
		dc.l	$7F81DC00,$30000000,$00000000,$C0C37600
		dc.l	$3000183E,$0F866000,$CEC3267C,$30003863
		dc.l	$18C66000,$D8C30663,$301C183E,$0F83F000
		dc.l	$D8C30663,$30001803,$00C06000,$CEC3066E
		dc.l	$30001803,$00C06000,$C0C30660,$38007E3E
		dc.l	$0F806000,$7F830060,$1FE00000,$00000000
		dc.l	$00000060,$00000000,$00000000,$00000000
		dc.l	$00000000,$00000000,$0061FF00,$3C000000
		dc.l	$00000000,$3F33FF80,$3C000601,$80619800
		dc.l	$2133FFFF,$BC00061C,$C7319800,$2733F7FF
		dc.l	$FC032641,$90640C00,$2633C7FB,$FC1F063C
		dc.l	$CF339C00,$3133C7FF,$FC000600,$C0301800
		dc.l	$2F33C7FF,$BE000181,$C0701800,$8073C7F8
		dc.l	$3FF87FBF,$8FE07800,$7FE3C078,$1FF80000
		dc.l	$00000000,$00000078,$00000000,$00000000
		endm

_ArrowPtr_	macro	; 16*11
		dc.w	0,0
		dc.w	$c000,$4000,$7000,$b000,$3c00,$4c00,$3f00,$4300
		dc.w	$1fc0,$20c0,$1fc0,$2000,$0f00,$1100,$0d80,$1280
		dc.w	$04c0,$0940,$0460,$08a0,$0020,$0040
		dc.w	0,0
		endm
_BusyPtr_	macro	; 16*16
		dc.w	0,0
		dc.w	$0400,$07c0,$0000,$07c0,$0100,$0380,$0000,$07e0
		dc.w	$07c0,$1ff8,$1ff0,$3fec,$3ff8,$7fde,$3ff8,$7fbe
		dc.w	$7ffc,$ff7f,$7efc,$ffff,$7ffc,$ffff,$3ff8,$7ffe
		dc.w	$3ff8,$7ffe,$1ff0,$3ffc,$07c0,$1ff8,$0000,$07e0
		dc.w	0,0
		endm

_DwnArrowData_	macro
		dc.w	$fffe,$c000,$c3c0,$c3c0,$dff8,$cff0,$c7e0,$c3c0
		dc.w	$c180,$c000,$8000,$0001,$0003,$0003,$0003,$0003
		dc.w	$0003,$0003,$0003,$0003,$0003,$7fff
		endm
_UpArrowData_	macro
		dc.w	$fffe,$c000,$c180,$c3c0,$c7e0,$cff0,$dff8,$c3c0
		dc.w	$c3c0,$c000,$8000,$0001,$0003,$0003,$0003,$0003
		dc.w	$0003,$0003,$0003,$0003,$0003,$7fff
		endm
_PDwnArrowData_	macro
		dc.w	$fffe,$c000,$c7e0,$c3c0,$c180,$c000,$c7e0,$c3c0
		dc.w	$c180,$c000,$8000,$0001,$0003,$0003,$0003,$0003
		dc.w	$0003,$0003,$0003,$0003,$0003,$7fff
		endm
_PUpArrowData_	macro
		dc.w	$fffe,$c000,$c180,$c3c0,$c7e0,$c000,$c180,$c3c0
		dc.w	$c7e0,$c000,$8000,$0001,$0003,$0003,$0003,$0003
		dc.w	$0003,$0003,$0003,$0003,$0003,$7fff
		endm
_BotArrowData_	macro
		dc.w	$fffe,$c000,$c000,$c7e0,$c3c0,$c180,$c000,$cff0
		dc.w	$c000,$c000,$8000,$0001,$0003,$0003,$0003,$0003
		dc.w	$0003,$0003,$0003,$0003,$0003,$7fff
		endm
_TopArrowData_	macro
		dc.w	$fffe,$c000,$c000,$cff0,$c000,$c180,$c3c0,$c7e0
		dc.w	$c000,$c000,$8000,$0001,$0003,$0003,$0003,$0003
		dc.w	$0003,$0003,$0003,$0003,$0003,$7fff
		endm
