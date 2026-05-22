

* This is my standard Dos library file. It has
* been ripped off from the Genam file & altered
* to suit me.

* library offsets from dos_base(a6)

Open		equ	-30
Close		equ	-36
Read		equ	-42
Write		equ	-48
Input		equ	-54
Output		equ	-60
Seek		equ	-66
DeleteFile	equ	-72
Rename		equ	-78
Lock		equ	-84
UnLock		equ	-90
DupLock		equ	-96
Examine		equ	-102
ExNext		equ	-108
Info		equ	-114
CreateDir	equ	-120
CurrentDir	equ	-126
IoErr		equ	-132
CreateProc	equ	-138
Exit		equ	-144
LoadSeg		equ	-150
UnLoadSeg	equ	-156
GetPacket	equ	-162
QueuePacket	equ	-168
DeviceProc	equ	-174
SetComment	equ	-180
SetProtection	equ	-186
DateStamp	equ	-192
Delay		equ	-198
WaitForChar	equ	-204
ParentDir	equ	-210
IsInteractive	equ	-216
Execute		equ	-222

;dos library access modes

MODE_OLD		equ	1005
MODE_NEW		equ	1006


SHARED_LOCK	EQU   -2
ACCESS_READ	EQU   -2
EXCLUSIVE_LOCK	EQU   -1
ACCESS_WRITE	EQU   -1

SEEK_START	EQU	-1
SEEK_CURRENT	EQU	0
SEEK_END		EQU	1


* Macro for calling a DOS.LIBRARY function

CALLDOS		macro	name	;call a DOS library function

		move.l	a6,-(sp)
		move.l	dos_base(a6),a6
		jsr	\1(a6)
		move.l	(sp)+,a6

		endm



