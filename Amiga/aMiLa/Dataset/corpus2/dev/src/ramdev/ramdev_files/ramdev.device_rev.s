VERSION = 51
REVISION = 1

.macro DATE
.ascii "16.6.2006"
.endm

.macro VERS
.ascii "ramdev.device 51.1"
.endm

.macro VSTRING
.ascii "ramdev.device 51.1 (16.6.2006)"
.byte 13,10,0
.endm

.macro VERSTAG
.byte 0
.ascii "$VER: ramdev.device 51.1 (16.6.2006)"
.byte 0
.endm
