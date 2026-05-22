;------------------------------------------------------------------------------
;				GhostRider Key-table
;------------------------------------------------------------------------------
; To save some development time I have decided to make the keyboard
; configuration a "do-it-yourself"-project.
; Alter the source below to get whatever country-map you prefer to use.
; Only change dc.b statements (not DC.B). Do not change order. Do not add
; or remove bytes.
; After assembling, write binary to "ENVARC:GhostRider.KeyMap" (area 's-e').
; The map below is the default (USA0 - more or less).
;------------------------------------------------------------------------------

s
;------------------------------------------------------------------------------
;				Unshifted Key-table
;------------------------------------------------------------------------------
		dc.b	'`1234567890-=\'	;Row 1
		DC.B	$0E			;Empty definition
		dc.b	'0'			;Keypad 0

		dc.b	'qwertyuiop[]'		;Row 2
		DC.B	$1C			;Empty definition
		dc.b	'123'			;Keypad 1-3

		dc.b	"asdfghjkl;'"		;Row 3
		dc.b	"'"			;This key is not on all keyboards.
		DC.B	$2C			;Empty definition
		dc.b	'456'			;Keypad 4-6

		dc.b	'<zxcvbnm,./'		;Row 4
		DC.B	$3B			;Empty definition
		dc.b	'.','789'		;Keypad . and 7-9

		dc.b	' '			;Space

		DC.B	$08,$09,$0A,$0A,$1B,$7F	;bs, tab, ret, enter, esc, del

		DC.B	$47,$48,$49		;Empty definitions

		dc.b	'-'			;Keypad -

		DC.B	$4B			;Empty definition

		DC.B	1,2,3,4			;up, down, right, left

		DC.B	$80,$81,$82,$83,$84,$85,$86,$87,$88,$89;F1-F10

		dc.b	'()/*','+'		;Keypad Row 1 and +

		dc.b	138			;HELP


;------------------------------------------------------------------------------
;				Shifted Key-table
;------------------------------------------------------------------------------
		dc.b	'~!@#$%^&*()_+|'	;Row 1
		DC.B	$0E			;Empty definition
		dc.b	'0'			;Keypad 0

		dc.b	'QWERTYUIOP{}'		;Row 2
		DC.B	$1C			;Empty definition
		dc.b	'123'			;Keypad 1-3

		dc.b	'ASDFGHJKL:"'		;Row 3
		dc.b	"*"			;This key is not on all keyboards.
		DC.B	$2C			;Empty definition
		dc.b	'456'			;Keypad 4-6

		dc.b	'>ZXCVBNM<>?'		;Row 4
		DC.B	$3B			;Empty definition
		dc.b	'.','789'		;Keypad . and 7-9

		dc.b	' '			;Space

		DC.B	$08,$09,$0A,$0A,$1B,$7F	;bs, tab, ret, enter, esc, del

		DC.B	$47,$48,$49		;Empty definitions

		dc.b	'-'			;Keypad -

		DC.B	$4B			;Empty definition

		DC.B	1,2,3,4			;up, down, right, left

		DC.B	$80,$81,$82,$83,$84,$85,$86,$87,$88,$89;F1-F10

		dc.b	'()/*','+'		;Keypad Row 1 and +

		dc.b	138			;HELP
e
len=e-s

	ifne	len-96*2			;Check table has correct length
	fail	'Table has wrong length!'
	endc
