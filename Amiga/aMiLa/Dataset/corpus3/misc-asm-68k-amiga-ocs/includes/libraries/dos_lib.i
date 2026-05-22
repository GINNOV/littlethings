Open	EQU	-30 
Close	EQU	-36 
Read	EQU	-42 
Write	EQU	-48 
Input	EQU	-54 
Output	EQU	-60 
Seek	EQU	-66 
DeleteFile	EQU	-72 
Rename	EQU	-78 
Lock	EQU	-84 
UnLock	EQU	-90 
DupLock	EQU	-96 
Examine	EQU	-102 
ExNext	EQU	-108 
Info	EQU	-114 
CreateDir	EQU	-120 
CurrentDir	EQU	-126 
IoErr	EQU	-132 
CreateProc	EQU	-138 
Exit	EQU	-144 
LoadSeg	EQU	-150 
UnLoadSeg	EQU	-156 
GetPacket	EQU	-162 
QueuePacket	EQU	-168 
DeviceProc	EQU	-174 
SetComment	EQU	-180 
SetProtection	EQU	-186 
DateStamp	EQU	-192 
Delay	EQU	-198 
WaitForChar	EQU	-204 
ParentDir	EQU	-210 
IsInteractive	EQU	-216 
Execute	EQU	-222 
CALLDOS	MACRO
	move.l	_DOSBase,a6
	jsr	\1(a6)
	ENDM
DOSNAME	MACRO
	dc.b	'dos.library',0
	ENDM

