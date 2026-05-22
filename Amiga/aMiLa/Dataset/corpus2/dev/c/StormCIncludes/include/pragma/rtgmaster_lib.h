#ifndef _INCLUDE_PRAGMA_RTGMASTER_LIB_H
#define _INCLUDE_PRAGMA_RTGMASTER_LIB_H

#ifndef CLIB_RTGMASTER_PROTOS_H
#include <clib/rtgmaster_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/rtgmaster.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(RTGMasterBase,0x01E,OpenRtgScreen(a0,a1))
#pragma amicall(RTGMasterBase,0x024,CloseRtgScreen(a0))
#pragma amicall(RTGMasterBase,0x02A,SwitchScreens(a0,d0))
#pragma amicall(RTGMasterBase,0x030,LoadRGBRtg(a0,a1))
#pragma amicall(RTGMasterBase,0x036,LockRtgScreen(a0))
#pragma amicall(RTGMasterBase,0x03C,UnlockRtgScreen(a0))
#pragma amicall(RTGMasterBase,0x042,GetBufAdr(a0,d0))
#pragma amicall(RTGMasterBase,0x048,GetRtgScreenData(a0,a1))
#pragma amicall(RTGMasterBase,0x04E,RtgAllocSRList(a0))
#pragma amicall(RTGMasterBase,0x054,FreeRtgSRList(a0))
#pragma amicall(RTGMasterBase,0x05A,RtgScreenAtFront(a0))
#pragma amicall(RTGMasterBase,0x060,RtgScreenModeReq(a0))
#pragma amicall(RTGMasterBase,0x066,FreeRtgScreenModeReq(a0))
#pragma amicall(RTGMasterBase,0x06C,WriteRtgPixel(a0,a1,d0,d1,d2))
#pragma amicall(RTGMasterBase,0x072,WriteRtgPixelRGB(a0,a1,d0,d1,d2))
#pragma amicall(RTGMasterBase,0x078,FillRtgRect(a0,a1,d0,d1,d2,d3,d4))
#pragma amicall(RTGMasterBase,0x07E,FillRtgRectRGB(a0,a1,d0,d1,d2,d3,d4))
#pragma amicall(RTGMasterBase,0x084,WriteRtgPixelArray(a0,a1,a2,d0,d1,d2,d3))
#pragma amicall(RTGMasterBase,0x08A,WriteRtgPixelRGBArray(a0,a1,a2,d0,d1,d2,d3))
#pragma amicall(RTGMasterBase,0x090,CopyRtgPixelArray(a0,a1,a2,d0,d1,d2,d3,d4,d5))
#pragma amicall(RTGMasterBase,0x096,CopyRtgBlit(a0,a1,a2,a3,d0,d1,d2,d3,d4,d5,d6,d7))
#pragma amicall(RTGMasterBase,0x09C,DrawRtgLine(a0,a1,d0,d1,d2,d3,d4))
#pragma amicall(RTGMasterBase,0x0A2,DrawRtgLineRGB(a0,a1,d0,d1,d2,d3,d4))
#pragma amicall(RTGMasterBase,0x0A8,WaitRtgSwitch(a0))
#pragma amicall(RTGMasterBase,0x0AE,WaitRtgBlit(a0))
#pragma amicall(RTGMasterBase,0x0B4,RtgWaitTOF(a0))
#pragma amicall(RTGMasterBase,0x0BA,RtgBlit(a0,a1,a2,d0,d1,d2,d3,d4,d5,d6))
#pragma amicall(RTGMasterBase,0x0C0,RtgBltClear(a0,a1,d0,d1,d2,d3))
#pragma amicall(RTGMasterBase,0x0C6,CallRtgC2P(a0,a1,a2,d0,d1,d2,d3,d4,d5))
#pragma amicall(RTGMasterBase,0x0CC,RtgBestSR(a0))
#pragma amicall(RTGMasterBase,0x0D2,RtgCheckVSync(a0))
#pragma amicall(RTGMasterBase,0x0D8,InitRtgBobSystem(a0,d0))
#pragma amicall(RTGMasterBase,0x0DE,CheckPPCCommand(a0,d0))
#pragma amicall(RTGMasterBase,0x0E4,CloseRtgBobSystem(a0))
#pragma amicall(RTGMasterBase,0x10E,RtgText(a0,a1,a2,d0,d1,d2))
#pragma amicall(RTGMasterBase,0x114,RtgSetFont(a0,a1))
#pragma amicall(RTGMasterBase,0x11A,RtgClearPointer(a0))
#pragma amicall(RTGMasterBase,0x120,RtgSetPointer(a0,a1,d0,d1,d2,d3))
#pragma amicall(RTGMasterBase,0x126,RtgSetTextMode(a0,d0,d1,d2))
#pragma amicall(RTGMasterBase,0x12C,RtgOpenFont(a0,a1))
#pragma amicall(RTGMasterBase,0x132,RtgCloseFont(a0,a1))
#pragma amicall(RTGMasterBase,0x138,RtgSetTextModeRGB(a0,d0,d1,d2))
#pragma amicall(RTGMasterBase,0x13E,RtgInitRDCMP(a0))
#pragma amicall(RTGMasterBase,0x144,RtgWaitRDCMP(a0))
#pragma amicall(RTGMasterBase,0x14A,RtgGetMsg(a0))
#pragma amicall(RTGMasterBase,0x150,RtgReplyMsg(a0,a1))
#pragma amicall(RTGMasterBase,0x28E,RtgScreenToFront(a0))
#pragma amicall(RTGMasterBase,0x29A,RtgConvert(a0,a1,d0,d1,d2,d3))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall RTGMasterBase OpenRtgScreen        01E 9802
#pragma  libcall RTGMasterBase CloseRtgScreen       024 801
#pragma  libcall RTGMasterBase SwitchScreens        02A 0802
#pragma  libcall RTGMasterBase LoadRGBRtg           030 9802
#pragma  libcall RTGMasterBase LockRtgScreen        036 801
#pragma  libcall RTGMasterBase UnlockRtgScreen      03C 801
#pragma  libcall RTGMasterBase GetBufAdr            042 0802
#pragma  libcall RTGMasterBase GetRtgScreenData     048 9802
#pragma  libcall RTGMasterBase RtgAllocSRList       04E 801
#pragma  libcall RTGMasterBase FreeRtgSRList        054 801
#pragma  libcall RTGMasterBase RtgScreenAtFront     05A 801
#pragma  libcall RTGMasterBase RtgScreenModeReq     060 801
#pragma  libcall RTGMasterBase FreeRtgScreenModeReq 066 801
#pragma  libcall RTGMasterBase WriteRtgPixel        06C 2109805
#pragma  libcall RTGMasterBase WriteRtgPixelRGB     072 2109805
#pragma  libcall RTGMasterBase FillRtgRect          078 432109807
#pragma  libcall RTGMasterBase FillRtgRectRGB       07E 432109807
#pragma  libcall RTGMasterBase WriteRtgPixelArray   084 3210A9807
#pragma  libcall RTGMasterBase WriteRtgPixelRGBArray 08A 3210A9807
#pragma  libcall RTGMasterBase CopyRtgPixelArray    090 543210A9809
#pragma  libcall RTGMasterBase CopyRtgBlit          096 76543210BA980C
#pragma  libcall RTGMasterBase DrawRtgLine          09C 432109807
#pragma  libcall RTGMasterBase DrawRtgLineRGB       0A2 432109807
#pragma  libcall RTGMasterBase WaitRtgSwitch        0A8 801
#pragma  libcall RTGMasterBase WaitRtgBlit          0AE 801
#pragma  libcall RTGMasterBase RtgWaitTOF           0B4 801
#pragma  libcall RTGMasterBase RtgBlit              0BA 6543210A980A
#pragma  libcall RTGMasterBase RtgBltClear          0C0 32109806
#pragma  libcall RTGMasterBase CallRtgC2P           0C6 543210A9809
#pragma  libcall RTGMasterBase RtgBestSR            0CC 801
#pragma  libcall RTGMasterBase RtgCheckVSync        0D2 801
#pragma  libcall RTGMasterBase InitRtgBobSystem     0D8 0802
#pragma  libcall RTGMasterBase CheckPPCCommand      0DE 0802
#pragma  libcall RTGMasterBase CloseRtgBobSystem    0E4 801
#pragma  libcall RTGMasterBase RtgText              10E 210A9806
#pragma  libcall RTGMasterBase RtgSetFont           114 9802
#pragma  libcall RTGMasterBase RtgClearPointer      11A 801
#pragma  libcall RTGMasterBase RtgSetPointer        120 32109806
#pragma  libcall RTGMasterBase RtgSetTextMode       126 210804
#pragma  libcall RTGMasterBase RtgOpenFont          12C 9802
#pragma  libcall RTGMasterBase RtgCloseFont         132 9802
#pragma  libcall RTGMasterBase RtgSetTextModeRGB    138 210804
#pragma  libcall RTGMasterBase RtgInitRDCMP         13E 801
#pragma  libcall RTGMasterBase RtgWaitRDCMP         144 801
#pragma  libcall RTGMasterBase RtgGetMsg            14A 801
#pragma  libcall RTGMasterBase RtgReplyMsg          150 9802
#pragma  libcall RTGMasterBase RtgScreenToFront     28E 801
#pragma  libcall RTGMasterBase RtgConvert           29A 32109806
#endif
#ifdef __STORM__
#pragma tagcall(RTGMasterBase,0x01E,OpenRtgScreenTags(a0,a1))
#pragma tagcall(RTGMasterBase,0x048,GetRtgScreenDataTags(a0,a1))
#pragma tagcall(RTGMasterBase,0x04E,RtgAllocSRListTags(a0))
#pragma tagcall(RTGMasterBase,0x060,RtgScreenModeReqTags(a0))
#pragma tagcall(RTGMasterBase,0x0CC,RtgBestSRTags(a0))
#endif
#ifdef __SASC_60
#pragma  tagcall RTGMasterBase OpenRtgScreenTags    01E 9802
#pragma  tagcall RTGMasterBase GetRtgScreenDataTags 048 9802
#pragma  tagcall RTGMasterBase RtgAllocSRListTags   04E 801
#pragma  tagcall RTGMasterBase RtgScreenModeReqTags 060 801
#pragma  tagcall RTGMasterBase RtgBestSRTags        0CC 801
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_RTGMASTER_LIB_H  */
