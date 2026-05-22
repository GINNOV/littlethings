#ifndef _INCLUDE_PRAGMA_DOS_LIB_H
#define _INCLUDE_PRAGMA_DOS_LIB_H

#ifndef CLIB_DOS_PROTOS_H
#include <clib/dos_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/dos.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(DOSBase,0x01E,Open(d1,d2))
#pragma amicall(DOSBase,0x024,Close(d1))
#pragma amicall(DOSBase,0x02A,Read(d1,d2,d3))
#pragma amicall(DOSBase,0x030,Write(d1,d2,d3))
#pragma amicall(DOSBase,0x036,Input())
#pragma amicall(DOSBase,0x03C,Output())
#pragma amicall(DOSBase,0x042,Seek(d1,d2,d3))
#pragma amicall(DOSBase,0x048,DeleteFile(d1))
#pragma amicall(DOSBase,0x04E,Rename(d1,d2))
#pragma amicall(DOSBase,0x054,Lock(d1,d2))
#pragma amicall(DOSBase,0x05A,UnLock(d1))
#pragma amicall(DOSBase,0x060,DupLock(d1))
#pragma amicall(DOSBase,0x066,Examine(d1,d2))
#pragma amicall(DOSBase,0x06C,ExNext(d1,d2))
#pragma amicall(DOSBase,0x072,Info(d1,d2))
#pragma amicall(DOSBase,0x078,CreateDir(d1))
#pragma amicall(DOSBase,0x07E,CurrentDir(d1))
#pragma amicall(DOSBase,0x084,IoErr())
#pragma amicall(DOSBase,0x08A,CreateProc(d1,d2,d3,d4))
#pragma amicall(DOSBase,0x090,Exit(d1))
#pragma amicall(DOSBase,0x096,LoadSeg(d1))
#pragma amicall(DOSBase,0x09C,UnLoadSeg(d1))
#pragma amicall(DOSBase,0x0AE,DeviceProc(d1))
#pragma amicall(DOSBase,0x0B4,SetComment(d1,d2))
#pragma amicall(DOSBase,0x0BA,SetProtection(d1,d2))
#pragma amicall(DOSBase,0x0C0,DateStamp(d1))
#pragma amicall(DOSBase,0x0C6,Delay(d1))
#pragma amicall(DOSBase,0x0CC,WaitForChar(d1,d2))
#pragma amicall(DOSBase,0x0D2,ParentDir(d1))
#pragma amicall(DOSBase,0x0D8,IsInteractive(d1))
#pragma amicall(DOSBase,0x0DE,Execute(d1,d2,d3))
#pragma amicall(DOSBase,0x0E4,AllocDosObject(d1,d2))
#pragma amicall(DOSBase,0x0E4,AllocDosObjectTagList(d1,d2))
#pragma amicall(DOSBase,0x0EA,FreeDosObject(d1,d2))
#pragma amicall(DOSBase,0x0F0,DoPkt(d1,d2,d3,d4,d5,d6,d7))
#pragma amicall(DOSBase,0x0F0,DoPkt0(d1,d2))
#pragma amicall(DOSBase,0x0F0,DoPkt1(d1,d2,d3))
#pragma amicall(DOSBase,0x0F0,DoPkt2(d1,d2,d3,d4))
#pragma amicall(DOSBase,0x0F0,DoPkt3(d1,d2,d3,d4,d5))
#pragma amicall(DOSBase,0x0F0,DoPkt4(d1,d2,d3,d4,d5,d6))
#pragma amicall(DOSBase,0x0F6,SendPkt(d1,d2,d3))
#pragma amicall(DOSBase,0x0FC,WaitPkt())
#pragma amicall(DOSBase,0x102,ReplyPkt(d1,d2,d3))
#pragma amicall(DOSBase,0x108,AbortPkt(d1,d2))
#pragma amicall(DOSBase,0x10E,LockRecord(d1,d2,d3,d4,d5))
#pragma amicall(DOSBase,0x114,LockRecords(d1,d2))
#pragma amicall(DOSBase,0x11A,UnLockRecord(d1,d2,d3))
#pragma amicall(DOSBase,0x120,UnLockRecords(d1))
#pragma amicall(DOSBase,0x126,SelectInput(d1))
#pragma amicall(DOSBase,0x12C,SelectOutput(d1))
#pragma amicall(DOSBase,0x132,FGetC(d1))
#pragma amicall(DOSBase,0x138,FPutC(d1,d2))
#pragma amicall(DOSBase,0x13E,UnGetC(d1,d2))
#pragma amicall(DOSBase,0x144,FRead(d1,d2,d3,d4))
#pragma amicall(DOSBase,0x14A,FWrite(d1,d2,d3,d4))
#pragma amicall(DOSBase,0x150,FGets(d1,d2,d3))
#pragma amicall(DOSBase,0x156,FPuts(d1,d2))
#pragma amicall(DOSBase,0x15C,VFWritef(d1,d2,d3))
#pragma amicall(DOSBase,0x162,VFPrintf(d1,d2,d3))
#pragma amicall(DOSBase,0x168,Flush(d1))
#pragma amicall(DOSBase,0x16E,SetVBuf(d1,d2,d3,d4))
#pragma amicall(DOSBase,0x174,DupLockFromFH(d1))
#pragma amicall(DOSBase,0x17A,OpenFromLock(d1))
#pragma amicall(DOSBase,0x180,ParentOfFH(d1))
#pragma amicall(DOSBase,0x186,ExamineFH(d1,d2))
#pragma amicall(DOSBase,0x18C,SetFileDate(d1,d2))
#pragma amicall(DOSBase,0x192,NameFromLock(d1,d2,d3))
#pragma amicall(DOSBase,0x198,NameFromFH(d1,d2,d3))
#pragma amicall(DOSBase,0x19E,SplitName(d1,d2,d3,d4,d5))
#pragma amicall(DOSBase,0x1A4,SameLock(d1,d2))
#pragma amicall(DOSBase,0x1AA,SetMode(d1,d2))
#pragma amicall(DOSBase,0x1B0,ExAll(d1,d2,d3,d4,d5))
#pragma amicall(DOSBase,0x1B6,ReadLink(d1,d2,d3,d4,d5))
#pragma amicall(DOSBase,0x1BC,MakeLink(d1,d2,d3))
#pragma amicall(DOSBase,0x1C2,ChangeMode(d1,d2,d3))
#pragma amicall(DOSBase,0x1C8,SetFileSize(d1,d2,d3))
#pragma amicall(DOSBase,0x1CE,SetIoErr(d1))
#pragma amicall(DOSBase,0x1D4,Fault(d1,d2,d3,d4))
#pragma amicall(DOSBase,0x1DA,PrintFault(d1,d2))
#pragma amicall(DOSBase,0x1E0,ErrorReport(d1,d2,d3,d4))
#pragma amicall(DOSBase,0x1EC,Cli())
#pragma amicall(DOSBase,0x1F2,CreateNewProc(d1))
#pragma amicall(DOSBase,0x1F2,CreateNewProcTagList(d1))
#pragma amicall(DOSBase,0x1F8,RunCommand(d1,d2,d3,d4))
#pragma amicall(DOSBase,0x1FE,GetConsoleTask())
#pragma amicall(DOSBase,0x204,SetConsoleTask(d1))
#pragma amicall(DOSBase,0x20A,GetFileSysTask())
#pragma amicall(DOSBase,0x210,SetFileSysTask(d1))
#pragma amicall(DOSBase,0x216,GetArgStr())
#pragma amicall(DOSBase,0x21C,SetArgStr(d1))
#pragma amicall(DOSBase,0x222,FindCliProc(d1))
#pragma amicall(DOSBase,0x228,MaxCli())
#pragma amicall(DOSBase,0x22E,SetCurrentDirName(d1))
#pragma amicall(DOSBase,0x234,GetCurrentDirName(d1,d2))
#pragma amicall(DOSBase,0x23A,SetProgramName(d1))
#pragma amicall(DOSBase,0x240,GetProgramName(d1,d2))
#pragma amicall(DOSBase,0x246,SetPrompt(d1))
#pragma amicall(DOSBase,0x24C,GetPrompt(d1,d2))
#pragma amicall(DOSBase,0x252,SetProgramDir(d1))
#pragma amicall(DOSBase,0x258,GetProgramDir())
#pragma amicall(DOSBase,0x25E,SystemTagList(d1,d2))
#pragma amicall(DOSBase,0x25E,System(d1,d2))
#pragma amicall(DOSBase,0x264,AssignLock(d1,d2))
#pragma amicall(DOSBase,0x26A,AssignLate(d1,d2))
#pragma amicall(DOSBase,0x270,AssignPath(d1,d2))
#pragma amicall(DOSBase,0x276,AssignAdd(d1,d2))
#pragma amicall(DOSBase,0x27C,RemAssignList(d1,d2))
#pragma amicall(DOSBase,0x282,GetDeviceProc(d1,d2))
#pragma amicall(DOSBase,0x288,FreeDeviceProc(d1))
#pragma amicall(DOSBase,0x28E,LockDosList(d1))
#pragma amicall(DOSBase,0x294,UnLockDosList(d1))
#pragma amicall(DOSBase,0x29A,AttemptLockDosList(d1))
#pragma amicall(DOSBase,0x2A0,RemDosEntry(d1))
#pragma amicall(DOSBase,0x2A6,AddDosEntry(d1))
#pragma amicall(DOSBase,0x2AC,FindDosEntry(d1,d2,d3))
#pragma amicall(DOSBase,0x2B2,NextDosEntry(d1,d2))
#pragma amicall(DOSBase,0x2B8,MakeDosEntry(d1,d2))
#pragma amicall(DOSBase,0x2BE,FreeDosEntry(d1))
#pragma amicall(DOSBase,0x2C4,IsFileSystem(d1))
#pragma amicall(DOSBase,0x2CA,Format(d1,d2,d3))
#pragma amicall(DOSBase,0x2D0,Relabel(d1,d2))
#pragma amicall(DOSBase,0x2D6,Inhibit(d1,d2))
#pragma amicall(DOSBase,0x2DC,AddBuffers(d1,d2))
#pragma amicall(DOSBase,0x2E2,CompareDates(d1,d2))
#pragma amicall(DOSBase,0x2E8,DateToStr(d1))
#pragma amicall(DOSBase,0x2EE,StrToDate(d1))
#pragma amicall(DOSBase,0x2F4,InternalLoadSeg(d0,a0,a1,a2))
#pragma amicall(DOSBase,0x2FA,InternalUnLoadSeg(d1,a1))
#pragma amicall(DOSBase,0x300,NewLoadSeg(d1,d2))
#pragma amicall(DOSBase,0x300,NewLoadSegTagList(d1,d2))
#pragma amicall(DOSBase,0x306,AddSegment(d1,d2,d3))
#pragma amicall(DOSBase,0x30C,FindSegment(d1,d2,d3))
#pragma amicall(DOSBase,0x312,RemSegment(d1))
#pragma amicall(DOSBase,0x318,CheckSignal(d1))
#pragma amicall(DOSBase,0x31E,ReadArgs(d1,d2,d3))
#pragma amicall(DOSBase,0x324,FindArg(d1,d2))
#pragma amicall(DOSBase,0x32A,ReadItem(d1,d2,d3))
#pragma amicall(DOSBase,0x330,StrToLong(d1,d2))
#pragma amicall(DOSBase,0x336,MatchFirst(d1,d2))
#pragma amicall(DOSBase,0x33C,MatchNext(d1))
#pragma amicall(DOSBase,0x342,MatchEnd(d1))
#pragma amicall(DOSBase,0x348,ParsePattern(d1,d2,d3))
#pragma amicall(DOSBase,0x34E,MatchPattern(d1,d2))
#pragma amicall(DOSBase,0x35A,FreeArgs(d1))
#pragma amicall(DOSBase,0x366,FilePart(d1))
#pragma amicall(DOSBase,0x36C,PathPart(d1))
#pragma amicall(DOSBase,0x372,AddPart(d1,d2,d3))
#pragma amicall(DOSBase,0x378,StartNotify(d1))
#pragma amicall(DOSBase,0x37E,EndNotify(d1))
#pragma amicall(DOSBase,0x384,SetVar(d1,d2,d3,d4))
#pragma amicall(DOSBase,0x38A,GetVar(d1,d2,d3,d4))
#pragma amicall(DOSBase,0x390,DeleteVar(d1,d2))
#pragma amicall(DOSBase,0x396,FindVar(d1,d2))
#pragma amicall(DOSBase,0x3A2,CliInitNewcli(a0))
#pragma amicall(DOSBase,0x3A8,CliInitRun(a0))
#pragma amicall(DOSBase,0x3AE,WriteChars(d1,d2))
#pragma amicall(DOSBase,0x3B4,PutStr(d1))
#pragma amicall(DOSBase,0x3BA,VPrintf(d1,d2))
#pragma amicall(DOSBase,0x3C6,ParsePatternNoCase(d1,d2,d3))
#pragma amicall(DOSBase,0x3CC,MatchPatternNoCase(d1,d2))
#pragma amicall(DOSBase,0x3D8,SameDevice(d1,d2))
#pragma amicall(DOSBase,0x3DE,ExAllEnd(d1,d2,d3,d4,d5))
#pragma amicall(DOSBase,0x3E4,SetOwner(d1,d2))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall DOSBase Open                 01E 2102
#pragma  libcall DOSBase Close                024 101
#pragma  libcall DOSBase Read                 02A 32103
#pragma  libcall DOSBase Write                030 32103
#pragma  libcall DOSBase Input                036 00
#pragma  libcall DOSBase Output               03C 00
#pragma  libcall DOSBase Seek                 042 32103
#pragma  libcall DOSBase DeleteFile           048 101
#pragma  libcall DOSBase Rename               04E 2102
#pragma  libcall DOSBase Lock                 054 2102
#pragma  libcall DOSBase UnLock               05A 101
#pragma  libcall DOSBase DupLock              060 101
#pragma  libcall DOSBase Examine              066 2102
#pragma  libcall DOSBase ExNext               06C 2102
#pragma  libcall DOSBase Info                 072 2102
#pragma  libcall DOSBase CreateDir            078 101
#pragma  libcall DOSBase CurrentDir           07E 101
#pragma  libcall DOSBase IoErr                084 00
#pragma  libcall DOSBase CreateProc           08A 432104
#pragma  libcall DOSBase Exit                 090 101
#pragma  libcall DOSBase LoadSeg              096 101
#pragma  libcall DOSBase UnLoadSeg            09C 101
#pragma  libcall DOSBase DeviceProc           0AE 101
#pragma  libcall DOSBase SetComment           0B4 2102
#pragma  libcall DOSBase SetProtection        0BA 2102
#pragma  libcall DOSBase DateStamp            0C0 101
#pragma  libcall DOSBase Delay                0C6 101
#pragma  libcall DOSBase WaitForChar          0CC 2102
#pragma  libcall DOSBase ParentDir            0D2 101
#pragma  libcall DOSBase IsInteractive        0D8 101
#pragma  libcall DOSBase Execute              0DE 32103
#pragma  libcall DOSBase AllocDosObject       0E4 2102
#pragma  libcall DOSBase AllocDosObjectTagList 0E4 2102
#pragma  libcall DOSBase FreeDosObject        0EA 2102
#pragma  libcall DOSBase DoPkt                0F0 765432107
#pragma  libcall DOSBase DoPkt0               0F0 2102
#pragma  libcall DOSBase DoPkt1               0F0 32103
#pragma  libcall DOSBase DoPkt2               0F0 432104
#pragma  libcall DOSBase DoPkt3               0F0 5432105
#pragma  libcall DOSBase DoPkt4               0F0 65432106
#pragma  libcall DOSBase SendPkt              0F6 32103
#pragma  libcall DOSBase WaitPkt              0FC 00
#pragma  libcall DOSBase ReplyPkt             102 32103
#pragma  libcall DOSBase AbortPkt             108 2102
#pragma  libcall DOSBase LockRecord           10E 5432105
#pragma  libcall DOSBase LockRecords          114 2102
#pragma  libcall DOSBase UnLockRecord         11A 32103
#pragma  libcall DOSBase UnLockRecords        120 101
#pragma  libcall DOSBase SelectInput          126 101
#pragma  libcall DOSBase SelectOutput         12C 101
#pragma  libcall DOSBase FGetC                132 101
#pragma  libcall DOSBase FPutC                138 2102
#pragma  libcall DOSBase UnGetC               13E 2102
#pragma  libcall DOSBase FRead                144 432104
#pragma  libcall DOSBase FWrite               14A 432104
#pragma  libcall DOSBase FGets                150 32103
#pragma  libcall DOSBase FPuts                156 2102
#pragma  libcall DOSBase VFWritef             15C 32103
#pragma  libcall DOSBase VFPrintf             162 32103
#pragma  libcall DOSBase Flush                168 101
#pragma  libcall DOSBase SetVBuf              16E 432104
#pragma  libcall DOSBase DupLockFromFH        174 101
#pragma  libcall DOSBase OpenFromLock         17A 101
#pragma  libcall DOSBase ParentOfFH           180 101
#pragma  libcall DOSBase ExamineFH            186 2102
#pragma  libcall DOSBase SetFileDate          18C 2102
#pragma  libcall DOSBase NameFromLock         192 32103
#pragma  libcall DOSBase NameFromFH           198 32103
#pragma  libcall DOSBase SplitName            19E 5432105
#pragma  libcall DOSBase SameLock             1A4 2102
#pragma  libcall DOSBase SetMode              1AA 2102
#pragma  libcall DOSBase ExAll                1B0 5432105
#pragma  libcall DOSBase ReadLink             1B6 5432105
#pragma  libcall DOSBase MakeLink             1BC 32103
#pragma  libcall DOSBase ChangeMode           1C2 32103
#pragma  libcall DOSBase SetFileSize          1C8 32103
#pragma  libcall DOSBase SetIoErr             1CE 101
#pragma  libcall DOSBase Fault                1D4 432104
#pragma  libcall DOSBase PrintFault           1DA 2102
#pragma  libcall DOSBase ErrorReport          1E0 432104
#pragma  libcall DOSBase Cli                  1EC 00
#pragma  libcall DOSBase CreateNewProc        1F2 101
#pragma  libcall DOSBase CreateNewProcTagList 1F2 101
#pragma  libcall DOSBase RunCommand           1F8 432104
#pragma  libcall DOSBase GetConsoleTask       1FE 00
#pragma  libcall DOSBase SetConsoleTask       204 101
#pragma  libcall DOSBase GetFileSysTask       20A 00
#pragma  libcall DOSBase SetFileSysTask       210 101
#pragma  libcall DOSBase GetArgStr            216 00
#pragma  libcall DOSBase SetArgStr            21C 101
#pragma  libcall DOSBase FindCliProc          222 101
#pragma  libcall DOSBase MaxCli               228 00
#pragma  libcall DOSBase SetCurrentDirName    22E 101
#pragma  libcall DOSBase GetCurrentDirName    234 2102
#pragma  libcall DOSBase SetProgramName       23A 101
#pragma  libcall DOSBase GetProgramName       240 2102
#pragma  libcall DOSBase SetPrompt            246 101
#pragma  libcall DOSBase GetPrompt            24C 2102
#pragma  libcall DOSBase SetProgramDir        252 101
#pragma  libcall DOSBase GetProgramDir        258 00
#pragma  libcall DOSBase SystemTagList        25E 2102
#pragma  libcall DOSBase System               25E 2102
#pragma  libcall DOSBase AssignLock           264 2102
#pragma  libcall DOSBase AssignLate           26A 2102
#pragma  libcall DOSBase AssignPath           270 2102
#pragma  libcall DOSBase AssignAdd            276 2102
#pragma  libcall DOSBase RemAssignList        27C 2102
#pragma  libcall DOSBase GetDeviceProc        282 2102
#pragma  libcall DOSBase FreeDeviceProc       288 101
#pragma  libcall DOSBase LockDosList          28E 101
#pragma  libcall DOSBase UnLockDosList        294 101
#pragma  libcall DOSBase AttemptLockDosList   29A 101
#pragma  libcall DOSBase RemDosEntry          2A0 101
#pragma  libcall DOSBase AddDosEntry          2A6 101
#pragma  libcall DOSBase FindDosEntry         2AC 32103
#pragma  libcall DOSBase NextDosEntry         2B2 2102
#pragma  libcall DOSBase MakeDosEntry         2B8 2102
#pragma  libcall DOSBase FreeDosEntry         2BE 101
#pragma  libcall DOSBase IsFileSystem         2C4 101
#pragma  libcall DOSBase Format               2CA 32103
#pragma  libcall DOSBase Relabel              2D0 2102
#pragma  libcall DOSBase Inhibit              2D6 2102
#pragma  libcall DOSBase AddBuffers           2DC 2102
#pragma  libcall DOSBase CompareDates         2E2 2102
#pragma  libcall DOSBase DateToStr            2E8 101
#pragma  libcall DOSBase StrToDate            2EE 101
#pragma  libcall DOSBase InternalLoadSeg      2F4 A98004
#pragma  libcall DOSBase InternalUnLoadSeg    2FA 9102
#pragma  libcall DOSBase NewLoadSeg           300 2102
#pragma  libcall DOSBase NewLoadSegTagList    300 2102
#pragma  libcall DOSBase AddSegment           306 32103
#pragma  libcall DOSBase FindSegment          30C 32103
#pragma  libcall DOSBase RemSegment           312 101
#pragma  libcall DOSBase CheckSignal          318 101
#pragma  libcall DOSBase ReadArgs             31E 32103
#pragma  libcall DOSBase FindArg              324 2102
#pragma  libcall DOSBase ReadItem             32A 32103
#pragma  libcall DOSBase StrToLong            330 2102
#pragma  libcall DOSBase MatchFirst           336 2102
#pragma  libcall DOSBase MatchNext            33C 101
#pragma  libcall DOSBase MatchEnd             342 101
#pragma  libcall DOSBase ParsePattern         348 32103
#pragma  libcall DOSBase MatchPattern         34E 2102
#pragma  libcall DOSBase FreeArgs             35A 101
#pragma  libcall DOSBase FilePart             366 101
#pragma  libcall DOSBase PathPart             36C 101
#pragma  libcall DOSBase AddPart              372 32103
#pragma  libcall DOSBase StartNotify          378 101
#pragma  libcall DOSBase EndNotify            37E 101
#pragma  libcall DOSBase SetVar               384 432104
#pragma  libcall DOSBase GetVar               38A 432104
#pragma  libcall DOSBase DeleteVar            390 2102
#pragma  libcall DOSBase FindVar              396 2102
#pragma  libcall DOSBase CliInitNewcli        3A2 801
#pragma  libcall DOSBase CliInitRun           3A8 801
#pragma  libcall DOSBase WriteChars           3AE 2102
#pragma  libcall DOSBase PutStr               3B4 101
#pragma  libcall DOSBase VPrintf              3BA 2102
#pragma  libcall DOSBase ParsePatternNoCase   3C6 32103
#pragma  libcall DOSBase MatchPatternNoCase   3CC 2102
#pragma  libcall DOSBase SameDevice           3D8 2102
#pragma  libcall DOSBase ExAllEnd             3DE 5432105
#pragma  libcall DOSBase SetOwner             3E4 2102
#endif
#ifdef __STORM__
#pragma tagcall(DOSBase,0x0E4,AllocDosObjectTags(d1,d2))
#pragma tagcall(DOSBase,0x15C,FWritef(d1,d2,d3))
#pragma tagcall(DOSBase,0x162,FPrintf(d1,d2,d3))
#pragma tagcall(DOSBase,0x1F2,CreateNewProcTags(d1))
#pragma tagcall(DOSBase,0x25E,SystemTags(d1,d2))
#pragma tagcall(DOSBase,0x300,NewLoadSegTags(d1,d2))
#pragma tagcall(DOSBase,0x3BA,Printf(d1,d2))
#endif
#ifdef __SASC_60
#pragma  tagcall DOSBase AllocDosObjectTags   0E4 2102
#pragma  tagcall DOSBase FWritef              15C 32103
#pragma  tagcall DOSBase FPrintf              162 32103
#pragma  tagcall DOSBase CreateNewProcTags    1F2 101
#pragma  tagcall DOSBase SystemTags           25E 2102
#pragma  tagcall DOSBase NewLoadSegTags       300 2102
#pragma  tagcall DOSBase Printf               3BA 2102
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_DOS_LIB_H  */
