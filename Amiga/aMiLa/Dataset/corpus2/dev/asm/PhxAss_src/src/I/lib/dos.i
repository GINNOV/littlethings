**
** dos.library
**
** Release 3.0
**
** PhxAss V3.xx
**

Open = -30
Close = -36
Read = -42
Write = -48
Input = -54
Output = -60
Seek = -66
DeleteFile = -72
Rename = -78
Lock = -84
UnLock = -90
DupLock = -96
Examine = -102
ExNext = -108
Info = -114
CreateDir = -120
CurrentDir = -126
IoErr = -132
CreateProc = -138
Exit = -144
LoadSeg = -150
UnLoadSeg = -156
GetPacket = -162
QueuePacket = -168
DeviceProc = -174
SetComment = -180
SetProtection = -186
 IFND DateStamp
DateStamp = -192
 ELSE
 echo "DateStamp defined twice! Ignoring."
 ENDC
Delay = -198
WaitForChar = -204
ParentDir = -210
IsInteractive = -216
Execute = -222

** functions in V36 or higher:
AllocDosObject = -228
FreeDosObject = -234
DoPkt = -240
SendPkt = -246
WaitPkt = -252
ReplyPkt = -258
AbortPkt = -264
LockRecord = -270
LockRecords = -276
UnLockRecord = -282
UnLockRecords = -288
SelectInput = -294
SelectOutput = -300
FGetC = -306
FPutC = -312
UnGetC = -318
FRead = -324
FWrite = -330
FGets = -336
FPuts = -342
VFWritef = -348
VFPrintf = -354
Flush = -360
SetVBuf = -366
DupLockFromFH = -372
OpenFromLock = -378
ParentOfFH = -384
ExamineFH = -390
SetFileDate = -396
NameFromLock = -402
NameFromFH = -408
SplitName = -414
SameLock = -420
SetMode = -426
ExAll = -432
ReadLink = -438
MakeLink = -444
ChangeMode = -450
SetFileSize = -456
SetIoErr = -462
Fault = -468
PrintFault = -474
ErrorReport = -480
Requester = -486
Cli = -492
CreateNewProc = -498
RunCommand = -504
GetConsoleTask = -510
SetConsoleTask = -516
GetFileSysTask = -522
SetFileSysTask = -528
GetArgStr = -534
SetArgStr = -540
FindCliProc = -546
MaxCli = -552
SetCurrentDirName = -558
GetCurrentDirName = -564
SetProgramName = -570
GetProgramName = -576
SetPrompt = -582
GetPrompt = -588
SetProgramDir = -594
GetProgramDir = -600
System = -606
AssignLock = -612
AssignLate = -618
AssignPath = -624
AssignAdd = -630
RemAssignList = -636
GetDeviceProc = -642
FreeDeviceProc = -648
LockDosList = -654
UnLockDosList = -660
AttemptLockDosList = -666
RemDosEntry = -672
AddDosEntry = -678
FindDosEntry = -684
NextDosEntry = -690
MakeDosEntry = -696
FreeDosEntry = -702
IsFileSystem = -708
Format = -714
Relabel = -720
Inhibit = -726
AddBuffers = -732
CompareDates = -738
DateToStr = -744
StrToDate = -750
InternalLoadSeg = -756
InternalUnLoadSeg = -762
NewLoadSeg = -768
AddSegment = -774
FindSegment = -780
RemSegment = -786
CheckSignal = -792
ReadArgs = -798
FindArgs = -804
ReadItem = -810
StrToLong = -816
MatchFirst = -822
MatchNext = -828
MatchEnd = -834
ParsePattern = -840
MatchPattern = -846
; 1 slot reserved
FreeArgs = -858
; 1 slot reserved
FilePart = -870
PathPart = -876
AddPart = -882
StartNotify = -888
EndNotify = -894
SetVar = -900
GetVar = -906
DeleteVar = -912
FindVar = -918
; 3 slots reserved
WriteChars = -942
PutStr = -948
VPrintf = -954
** functions in V39 or higher
ExAllEnd = -990
SetOwner = -996

