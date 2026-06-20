#ifndef _INCLUDE_PRAGMA_INTUITION_LIB_H
#define _INCLUDE_PRAGMA_INTUITION_LIB_H

#ifndef CLIB_INTUITION_PROTOS_H
#include <clib/intuition_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/intuition.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(IntuitionBase,0x01E,OpenIntuition())
#pragma amicall(IntuitionBase,0x024,Intuition(a0))
#pragma amicall(IntuitionBase,0x02A,AddGadget(a0,a1,d0))
#pragma amicall(IntuitionBase,0x030,ClearDMRequest(a0))
#pragma amicall(IntuitionBase,0x036,ClearMenuStrip(a0))
#pragma amicall(IntuitionBase,0x03C,ClearPointer(a0))
#pragma amicall(IntuitionBase,0x042,CloseScreen(a0))
#pragma amicall(IntuitionBase,0x048,CloseWindow(a0))
#pragma amicall(IntuitionBase,0x04E,CloseWorkBench())
#pragma amicall(IntuitionBase,0x054,CurrentTime(a0,a1))
#pragma amicall(IntuitionBase,0x05A,DisplayAlert(d0,a0,d1))
#pragma amicall(IntuitionBase,0x060,DisplayBeep(a0))
#pragma amicall(IntuitionBase,0x066,DoubleClick(d0,d1,d2,d3))
#pragma amicall(IntuitionBase,0x06C,DrawBorder(a0,a1,d0,d1))
#pragma amicall(IntuitionBase,0x072,DrawImage(a0,a1,d0,d1))
#pragma amicall(IntuitionBase,0x078,EndRequest(a0,a1))
#pragma amicall(IntuitionBase,0x07E,GetDefPrefs(a0,d0))
#pragma amicall(IntuitionBase,0x084,GetPrefs(a0,d0))
#pragma amicall(IntuitionBase,0x08A,InitRequester(a0))
#pragma amicall(IntuitionBase,0x090,ItemAddress(a0,d0))
#pragma amicall(IntuitionBase,0x096,ModifyIDCMP(a0,d0))
#pragma amicall(IntuitionBase,0x09C,ModifyProp(a0,a1,a2,d0,d1,d2,d3,d4))
#pragma amicall(IntuitionBase,0x0A2,MoveScreen(a0,d0,d1))
#pragma amicall(IntuitionBase,0x0A8,MoveWindow(a0,d0,d1))
#pragma amicall(IntuitionBase,0x0AE,OffGadget(a0,a1,a2))
#pragma amicall(IntuitionBase,0x0B4,OffMenu(a0,d0))
#pragma amicall(IntuitionBase,0x0BA,OnGadget(a0,a1,a2))
#pragma amicall(IntuitionBase,0x0C0,OnMenu(a0,d0))
#pragma amicall(IntuitionBase,0x0C6,OpenScreen(a0))
#pragma amicall(IntuitionBase,0x0CC,OpenWindow(a0))
#pragma amicall(IntuitionBase,0x0D2,OpenWorkBench())
#pragma amicall(IntuitionBase,0x0D8,PrintIText(a0,a1,d0,d1))
#pragma amicall(IntuitionBase,0x0DE,RefreshGadgets(a0,a1,a2))
#pragma amicall(IntuitionBase,0x0E4,RemoveGadget(a0,a1))
#pragma amicall(IntuitionBase,0x0EA,ReportMouse(d0,a0))
#pragma amicall(IntuitionBase,0x0F0,Request(a0,a1))
#pragma amicall(IntuitionBase,0x0F6,ScreenToBack(a0))
#pragma amicall(IntuitionBase,0x0FC,ScreenToFront(a0))
#pragma amicall(IntuitionBase,0x102,SetDMRequest(a0,a1))
#pragma amicall(IntuitionBase,0x108,SetMenuStrip(a0,a1))
#pragma amicall(IntuitionBase,0x10E,SetPointer(a0,a1,d0,d1,d2,d3))
#pragma amicall(IntuitionBase,0x114,SetWindowTitles(a0,a1,a2))
#pragma amicall(IntuitionBase,0x11A,ShowTitle(a0,d0))
#pragma amicall(IntuitionBase,0x120,SizeWindow(a0,d0,d1))
#pragma amicall(IntuitionBase,0x126,ViewAddress())
#pragma amicall(IntuitionBase,0x12C,ViewPortAddress(a0))
#pragma amicall(IntuitionBase,0x132,WindowToBack(a0))
#pragma amicall(IntuitionBase,0x138,WindowToFront(a0))
#pragma amicall(IntuitionBase,0x13E,WindowLimits(a0,d0,d1,d2,d3))
#pragma amicall(IntuitionBase,0x144,SetPrefs(a0,d0,d1))
#pragma amicall(IntuitionBase,0x14A,IntuiTextLength(a0))
#pragma amicall(IntuitionBase,0x150,WBenchToBack())
#pragma amicall(IntuitionBase,0x156,WBenchToFront())
#pragma amicall(IntuitionBase,0x15C,AutoRequest(a0,a1,a2,a3,d0,d1,d2,d3))
#pragma amicall(IntuitionBase,0x162,BeginRefresh(a0))
#pragma amicall(IntuitionBase,0x168,BuildSysRequest(a0,a1,a2,a3,d0,d1,d2))
#pragma amicall(IntuitionBase,0x16E,EndRefresh(a0,d0))
#pragma amicall(IntuitionBase,0x174,FreeSysRequest(a0))
#pragma amicall(IntuitionBase,0x17A,MakeScreen(a0))
#pragma amicall(IntuitionBase,0x180,RemakeDisplay())
#pragma amicall(IntuitionBase,0x186,RethinkDisplay())
#pragma amicall(IntuitionBase,0x18C,AllocRemember(a0,d0,d1))
#pragma amicall(IntuitionBase,0x198,FreeRemember(a0,d0))
#pragma amicall(IntuitionBase,0x19E,LockIBase(d0))
#pragma amicall(IntuitionBase,0x1A4,UnlockIBase(a0))
#pragma amicall(IntuitionBase,0x1AA,GetScreenData(a0,d0,d1,a1))
#pragma amicall(IntuitionBase,0x1B0,RefreshGList(a0,a1,a2,d0))
#pragma amicall(IntuitionBase,0x1B6,AddGList(a0,a1,d0,d1,a2))
#pragma amicall(IntuitionBase,0x1BC,RemoveGList(a0,a1,d0))
#pragma amicall(IntuitionBase,0x1C2,ActivateWindow(a0))
#pragma amicall(IntuitionBase,0x1C8,RefreshWindowFrame(a0))
#pragma amicall(IntuitionBase,0x1CE,ActivateGadget(a0,a1,a2))
#pragma amicall(IntuitionBase,0x1D4,NewModifyProp(a0,a1,a2,d0,d1,d2,d3,d4,d5))
#pragma amicall(IntuitionBase,0x1DA,QueryOverscan(a0,a1,d0))
#pragma amicall(IntuitionBase,0x1E0,MoveWindowInFrontOf(a0,a1))
#pragma amicall(IntuitionBase,0x1E6,ChangeWindowBox(a0,d0,d1,d2,d3))
#pragma amicall(IntuitionBase,0x1EC,SetEditHook(a0))
#pragma amicall(IntuitionBase,0x1F2,SetMouseQueue(a0,d0))
#pragma amicall(IntuitionBase,0x1F8,ZipWindow(a0))
#pragma amicall(IntuitionBase,0x1FE,LockPubScreen(a0))
#pragma amicall(IntuitionBase,0x204,UnlockPubScreen(a0,a1))
#pragma amicall(IntuitionBase,0x20A,LockPubScreenList())
#pragma amicall(IntuitionBase,0x210,UnlockPubScreenList())
#pragma amicall(IntuitionBase,0x216,NextPubScreen(a0,a1))
#pragma amicall(IntuitionBase,0x21C,SetDefaultPubScreen(a0))
#pragma amicall(IntuitionBase,0x222,SetPubScreenModes(d0))
#pragma amicall(IntuitionBase,0x228,PubScreenStatus(a0,d0))
#pragma amicall(IntuitionBase,0x22E,ObtainGIRPort(a0))
#pragma amicall(IntuitionBase,0x234,ReleaseGIRPort(a0))
#pragma amicall(IntuitionBase,0x23A,GadgetMouse(a0,a1,a2))
#pragma amicall(IntuitionBase,0x246,GetDefaultPubScreen(a0))
#pragma amicall(IntuitionBase,0x24C,EasyRequestArgs(a0,a1,a2,a3))
#pragma amicall(IntuitionBase,0x252,BuildEasyRequestArgs(a0,a1,d0,a3))
#pragma amicall(IntuitionBase,0x258,SysReqHandler(a0,a1,d0))
#pragma amicall(IntuitionBase,0x25E,OpenWindowTagList(a0,a1))
#pragma amicall(IntuitionBase,0x264,OpenScreenTagList(a0,a1))
#pragma amicall(IntuitionBase,0x26A,DrawImageState(a0,a1,d0,d1,d2,a2))
#pragma amicall(IntuitionBase,0x270,PointInImage(d0,a0))
#pragma amicall(IntuitionBase,0x276,EraseImage(a0,a1,d0,d1))
#pragma amicall(IntuitionBase,0x27C,NewObjectA(a0,a1,a2))
#pragma amicall(IntuitionBase,0x282,DisposeObject(a0))
#pragma amicall(IntuitionBase,0x288,SetAttrsA(a0,a1))
#pragma amicall(IntuitionBase,0x28E,GetAttr(d0,a0,a1))
#pragma amicall(IntuitionBase,0x294,SetGadgetAttrsA(a0,a1,a2,a3))
#pragma amicall(IntuitionBase,0x29A,NextObject(a0))
#pragma amicall(IntuitionBase,0x2A6,MakeClass(a0,a1,a2,d0,d1))
#pragma amicall(IntuitionBase,0x2AC,AddClass(a0))
#pragma amicall(IntuitionBase,0x2B2,GetScreenDrawInfo(a0))
#pragma amicall(IntuitionBase,0x2B8,FreeScreenDrawInfo(a0,a1))
#pragma amicall(IntuitionBase,0x2BE,ResetMenuStrip(a0,a1))
#pragma amicall(IntuitionBase,0x2C4,RemoveClass(a0))
#pragma amicall(IntuitionBase,0x2CA,FreeClass(a0))
#pragma amicall(IntuitionBase,0x300,AllocScreenBuffer(a0,a1,d0))
#pragma amicall(IntuitionBase,0x306,FreeScreenBuffer(a0,a1))
#pragma amicall(IntuitionBase,0x30C,ChangeScreenBuffer(a0,a1))
#pragma amicall(IntuitionBase,0x312,ScreenDepth(a0,d0,a1))
#pragma amicall(IntuitionBase,0x318,ScreenPosition(a0,d0,d1,d2,d3,d4))
#pragma amicall(IntuitionBase,0x31E,ScrollWindowRaster(a1,d0,d1,d2,d3,d4,d5))
#pragma amicall(IntuitionBase,0x324,LendMenus(a0,a1))
#pragma amicall(IntuitionBase,0x32A,DoGadgetMethodA(a0,a1,a2,a3))
#pragma amicall(IntuitionBase,0x330,SetWindowPointerA(a0,a1))
#pragma amicall(IntuitionBase,0x336,TimedDisplayAlert(d0,a0,d1,a1))
#pragma amicall(IntuitionBase,0x33C,HelpControl(a0,d0))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall IntuitionBase OpenIntuition        01E 00
#pragma  libcall IntuitionBase Intuition            024 801
#pragma  libcall IntuitionBase AddGadget            02A 09803
#pragma  libcall IntuitionBase ClearDMRequest       030 801
#pragma  libcall IntuitionBase ClearMenuStrip       036 801
#pragma  libcall IntuitionBase ClearPointer         03C 801
#pragma  libcall IntuitionBase CloseScreen          042 801
#pragma  libcall IntuitionBase CloseWindow          048 801
#pragma  libcall IntuitionBase CloseWorkBench       04E 00
#pragma  libcall IntuitionBase CurrentTime          054 9802
#pragma  libcall IntuitionBase DisplayAlert         05A 18003
#pragma  libcall IntuitionBase DisplayBeep          060 801
#pragma  libcall IntuitionBase DoubleClick          066 321004
#pragma  libcall IntuitionBase DrawBorder           06C 109804
#pragma  libcall IntuitionBase DrawImage            072 109804
#pragma  libcall IntuitionBase EndRequest           078 9802
#pragma  libcall IntuitionBase GetDefPrefs          07E 0802
#pragma  libcall IntuitionBase GetPrefs             084 0802
#pragma  libcall IntuitionBase InitRequester        08A 801
#pragma  libcall IntuitionBase ItemAddress          090 0802
#pragma  libcall IntuitionBase ModifyIDCMP          096 0802
#pragma  libcall IntuitionBase ModifyProp           09C 43210A9808
#pragma  libcall IntuitionBase MoveScreen           0A2 10803
#pragma  libcall IntuitionBase MoveWindow           0A8 10803
#pragma  libcall IntuitionBase OffGadget            0AE A9803
#pragma  libcall IntuitionBase OffMenu              0B4 0802
#pragma  libcall IntuitionBase OnGadget             0BA A9803
#pragma  libcall IntuitionBase OnMenu               0C0 0802
#pragma  libcall IntuitionBase OpenScreen           0C6 801
#pragma  libcall IntuitionBase OpenWindow           0CC 801
#pragma  libcall IntuitionBase OpenWorkBench        0D2 00
#pragma  libcall IntuitionBase PrintIText           0D8 109804
#pragma  libcall IntuitionBase RefreshGadgets       0DE A9803
#pragma  libcall IntuitionBase RemoveGadget         0E4 9802
#pragma  libcall IntuitionBase ReportMouse          0EA 8002
#pragma  libcall IntuitionBase Request              0F0 9802
#pragma  libcall IntuitionBase ScreenToBack         0F6 801
#pragma  libcall IntuitionBase ScreenToFront        0FC 801
#pragma  libcall IntuitionBase SetDMRequest         102 9802
#pragma  libcall IntuitionBase SetMenuStrip         108 9802
#pragma  libcall IntuitionBase SetPointer           10E 32109806
#pragma  libcall IntuitionBase SetWindowTitles      114 A9803
#pragma  libcall IntuitionBase ShowTitle            11A 0802
#pragma  libcall IntuitionBase SizeWindow           120 10803
#pragma  libcall IntuitionBase ViewAddress          126 00
#pragma  libcall IntuitionBase ViewPortAddress      12C 801
#pragma  libcall IntuitionBase WindowToBack         132 801
#pragma  libcall IntuitionBase WindowToFront        138 801
#pragma  libcall IntuitionBase WindowLimits         13E 3210805
#pragma  libcall IntuitionBase SetPrefs             144 10803
#pragma  libcall IntuitionBase IntuiTextLength      14A 801
#pragma  libcall IntuitionBase WBenchToBack         150 00
#pragma  libcall IntuitionBase WBenchToFront        156 00
#pragma  libcall IntuitionBase AutoRequest          15C 3210BA9808
#pragma  libcall IntuitionBase BeginRefresh         162 801
#pragma  libcall IntuitionBase BuildSysRequest      168 210BA9807
#pragma  libcall IntuitionBase EndRefresh           16E 0802
#pragma  libcall IntuitionBase FreeSysRequest       174 801
#pragma  libcall IntuitionBase MakeScreen           17A 801
#pragma  libcall IntuitionBase RemakeDisplay        180 00
#pragma  libcall IntuitionBase RethinkDisplay       186 00
#pragma  libcall IntuitionBase AllocRemember        18C 10803
#pragma  libcall IntuitionBase FreeRemember         198 0802
#pragma  libcall IntuitionBase LockIBase            19E 001
#pragma  libcall IntuitionBase UnlockIBase          1A4 801
#pragma  libcall IntuitionBase GetScreenData        1AA 910804
#pragma  libcall IntuitionBase RefreshGList         1B0 0A9804
#pragma  libcall IntuitionBase AddGList             1B6 A109805
#pragma  libcall IntuitionBase RemoveGList          1BC 09803
#pragma  libcall IntuitionBase ActivateWindow       1C2 801
#pragma  libcall IntuitionBase RefreshWindowFrame   1C8 801
#pragma  libcall IntuitionBase ActivateGadget       1CE A9803
#pragma  libcall IntuitionBase NewModifyProp        1D4 543210A9809
#pragma  libcall IntuitionBase QueryOverscan        1DA 09803
#pragma  libcall IntuitionBase MoveWindowInFrontOf  1E0 9802
#pragma  libcall IntuitionBase ChangeWindowBox      1E6 3210805
#pragma  libcall IntuitionBase SetEditHook          1EC 801
#pragma  libcall IntuitionBase SetMouseQueue        1F2 0802
#pragma  libcall IntuitionBase ZipWindow            1F8 801
#pragma  libcall IntuitionBase LockPubScreen        1FE 801
#pragma  libcall IntuitionBase UnlockPubScreen      204 9802
#pragma  libcall IntuitionBase LockPubScreenList    20A 00
#pragma  libcall IntuitionBase UnlockPubScreenList  210 00
#pragma  libcall IntuitionBase NextPubScreen        216 9802
#pragma  libcall IntuitionBase SetDefaultPubScreen  21C 801
#pragma  libcall IntuitionBase SetPubScreenModes    222 001
#pragma  libcall IntuitionBase PubScreenStatus      228 0802
#pragma  libcall IntuitionBase ObtainGIRPort        22E 801
#pragma  libcall IntuitionBase ReleaseGIRPort       234 801
#pragma  libcall IntuitionBase GadgetMouse          23A A9803
#pragma  libcall IntuitionBase GetDefaultPubScreen  246 801
#pragma  libcall IntuitionBase EasyRequestArgs      24C BA9804
#pragma  libcall IntuitionBase BuildEasyRequestArgs 252 B09804
#pragma  libcall IntuitionBase SysReqHandler        258 09803
#pragma  libcall IntuitionBase OpenWindowTagList    25E 9802
#pragma  libcall IntuitionBase OpenScreenTagList    264 9802
#pragma  libcall IntuitionBase DrawImageState       26A A2109806
#pragma  libcall IntuitionBase PointInImage         270 8002
#pragma  libcall IntuitionBase EraseImage           276 109804
#pragma  libcall IntuitionBase NewObjectA           27C A9803
#pragma  libcall IntuitionBase DisposeObject        282 801
#pragma  libcall IntuitionBase SetAttrsA            288 9802
#pragma  libcall IntuitionBase GetAttr              28E 98003
#pragma  libcall IntuitionBase SetGadgetAttrsA      294 BA9804
#pragma  libcall IntuitionBase NextObject           29A 801
#pragma  libcall IntuitionBase MakeClass            2A6 10A9805
#pragma  libcall IntuitionBase AddClass             2AC 801
#pragma  libcall IntuitionBase GetScreenDrawInfo    2B2 801
#pragma  libcall IntuitionBase FreeScreenDrawInfo   2B8 9802
#pragma  libcall IntuitionBase ResetMenuStrip       2BE 9802
#pragma  libcall IntuitionBase RemoveClass          2C4 801
#pragma  libcall IntuitionBase FreeClass            2CA 801
#pragma  libcall IntuitionBase AllocScreenBuffer    300 09803
#pragma  libcall IntuitionBase FreeScreenBuffer     306 9802
#pragma  libcall IntuitionBase ChangeScreenBuffer   30C 9802
#pragma  libcall IntuitionBase ScreenDepth          312 90803
#pragma  libcall IntuitionBase ScreenPosition       318 43210806
#pragma  libcall IntuitionBase ScrollWindowRaster   31E 543210907
#pragma  libcall IntuitionBase LendMenus            324 9802
#pragma  libcall IntuitionBase DoGadgetMethodA      32A BA9804
#pragma  libcall IntuitionBase SetWindowPointerA    330 9802
#pragma  libcall IntuitionBase TimedDisplayAlert    336 918004
#pragma  libcall IntuitionBase HelpControl          33C 0802
#endif
#ifdef __STORM__
#pragma tagcall(IntuitionBase,0x24C,EasyRequest(a0,a1,a2,a3))
#pragma tagcall(IntuitionBase,0x252,BuildEasyRequest(a0,a1,d0,a3))
#pragma tagcall(IntuitionBase,0x25E,OpenWindowTags(a0,a1))
#pragma tagcall(IntuitionBase,0x264,OpenScreenTags(a0,a1))
#pragma tagcall(IntuitionBase,0x27C,NewObject(a0,a1,a2))
#pragma tagcall(IntuitionBase,0x288,SetAttrs(a0,a1))
#pragma tagcall(IntuitionBase,0x294,SetGadgetAttrs(a0,a1,a2,a3))
#pragma tagcall(IntuitionBase,0x32A,DoGadgetMethod(a0,a1,a2,a3))
#pragma tagcall(IntuitionBase,0x330,SetWindowPointer(a0,a1))
#endif
#ifdef __SASC_60
#pragma  tagcall IntuitionBase EasyRequest          24C BA9804
#pragma  tagcall IntuitionBase BuildEasyRequest     252 B09804
#pragma  tagcall IntuitionBase OpenWindowTags       25E 9802
#pragma  tagcall IntuitionBase OpenScreenTags       264 9802
#pragma  tagcall IntuitionBase NewObject            27C A9803
#pragma  tagcall IntuitionBase SetAttrs             288 9802
#pragma  tagcall IntuitionBase SetGadgetAttrs       294 BA9804
#pragma  tagcall IntuitionBase DoGadgetMethod       32A BA9804
#pragma  tagcall IntuitionBase SetWindowPointer     330 9802
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_INTUITION_LIB_H  */
