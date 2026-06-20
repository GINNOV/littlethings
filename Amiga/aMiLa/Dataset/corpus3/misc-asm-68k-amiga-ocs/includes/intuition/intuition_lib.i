OpenIntuition	EQU	-30 
Intuition	EQU	-36 
AddGadget	EQU	-42 
ClearDMRequest	EQU	-48 
ClearMenuStrip	EQU	-54 
ClearPointer	EQU	-60 
CloseScreen	EQU	-66 
CloseWindow	EQU	-72 
CloseWorkBench	EQU	-78 
CurrentTime	EQU	-84 
DisplayAlert	EQU	-90 
DisplayBeep	EQU	-96 
DoubleClick	EQU	-102 
DrawBorder	EQU	-108 
DrawImage	EQU	-114 
EndRequest	EQU	-120 
GetDefPrefs	EQU	-126 
GetPrefs	EQU	-132 
InitRequester	EQU	-138 
ItemAddress	EQU	-144 
ModifyIDCMP	EQU	-150 
ModifyProp	EQU	-156 
MoveScreen	EQU	-162 
MoveWindow	EQU	-168 
OffGadget	EQU	-174 
OffMenu	EQU	-180 
OnGadget	EQU	-186 
OnMenu	EQU	-192 
OpenScreen	EQU	-198 
OpenWindow	EQU	-204 
OpenWorkBench	EQU	-210 
PrintIText	EQU	-216 
RefreshGadgets	EQU	-222 
RemoveGadget	EQU	-228 
ReportMouse	EQU	-234 
Request	EQU	-240 
ScreenToBack	EQU	-246 
ScreenToFront	EQU	-252 
SetDMRequest	EQU	-258 
SetMenuStrip	EQU	-264 
SetPointer	EQU	-270 
SetWindowTitles	EQU	-276 
ShowTitle	EQU	-282 
SizeWindow	EQU	-288 
ViewAddress	EQU	-294 
ViewPortAddress	EQU	-300 
WindowToBack	EQU	-306 
WindowToFront	EQU	-312 
WindowLimits	EQU	-318 
SetPrefs	EQU	-324 
IntuiTextLength	EQU	-330 
WBenchToBack	EQU	-336 
WBenchToFront	EQU	-342 
AutoRequest	EQU	-348 
BeginRefresh	EQU	-354 
BuildSysRequest	EQU	-360 
EndRefresh	EQU	-366 
FreeSysRequest	EQU	-372 
MakeScreen	EQU	-378 
RemakeDisplay	EQU	-384 
RethinkDisplay	EQU	-390 
AllocRemember	EQU	-396 
AlohaWorkbench	EQU	-402 
FreeRemember	EQU	-408 
LockIBase	EQU	-414 
UnlockIBase	EQU	-420 
GetScreenData	EQU	-426 
RefreshGList	EQU	-432 
AddGList	EQU	-438 
RemoveGList	EQU	-444 
ActivateWindow	EQU	-450 
RefreshWindowFrame	EQU	-456 
ActivateGadget	EQU	-462 
NewModifyProp	EQU	-468 
CALLINT	MACRO
	move.l	_IntuitionBase,a6
	jsr	\1(a6)
	ENDM
INTNAME	MACRO
	dc.b	'intuition.library',0
	ENDM

