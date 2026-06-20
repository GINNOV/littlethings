VERSION = 2
REVISION = 12

.macro DATE
.ascii "19.4.2020"
.endm

.macro VERS
.ascii "amijansson_source/jansson.library 2.12"
.endm

.macro VSTRING
.ascii "amijansson_source/jansson.library 2.12 (19.4.2020)"
.byte 13,10,0
.endm

.macro VERSTAG
.byte 0
.ascii "$VER: amijansson_source/jansson.library 2.12 (19.4.2020)"
.byte 0
.endm
