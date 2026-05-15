VERSION = 1
REVISION = 1

.macro DATE
.ascii "7.10.2018"
.endm

.macro VERS
.ascii "uuid.library 1.1"
.endm

.macro VSTRING
.ascii "uuid.library 1.1 (7.10.2018)"
.byte 13,10,0
.endm

.macro VERSTAG
.byte 0
.ascii "$VER: uuid.library 1.1 (7.10.2018)"
.byte 0
.endm
