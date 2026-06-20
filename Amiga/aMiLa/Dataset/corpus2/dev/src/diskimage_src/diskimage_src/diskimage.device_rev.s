VERSION = 0
REVISION = 2

.macro DATE
.ascii "12.11.2007"
.endm

.macro VERS
.ascii "diskimage.device 0.2"
.endm

.macro VSTRING
.ascii "diskimage.device 0.2 (12.11.2007)"
.byte 13,10,0
.endm

.macro VERSTAG
.byte 0
.ascii "$VER: diskimage.device 0.2 (12.11.2007)"
.byte 0
.endm
