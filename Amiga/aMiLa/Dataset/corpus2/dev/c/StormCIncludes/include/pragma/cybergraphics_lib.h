#ifndef _INCLUDE_PRAGMA_CYBERGRAPHICS_LIB_H
#define _INCLUDE_PRAGMA_CYBERGRAPHICS_LIB_H

#ifndef CLIB_CYBERGRAPHICS_PROTOS_H
#include <clib/cybergraphics_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/cybergraphics.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(CyberGfxBase,0x036,IsCyberModeID(d0))
#pragma amicall(CyberGfxBase,0x03C,BestCModeIDTagList(a0))
#pragma amicall(CyberGfxBase,0x042,CModeRequestTagList(a0,a1))
#pragma amicall(CyberGfxBase,0x048,AllocCModeListTagList(a1))
#pragma amicall(CyberGfxBase,0x04E,FreeCModeList(a0))
#pragma amicall(CyberGfxBase,0x05A,ScalePixelArray(a0,d0,d1,d2,a1,d3,d4,d5,d6,d7))
#pragma amicall(CyberGfxBase,0x060,GetCyberMapAttr(a0,d0))
#pragma amicall(CyberGfxBase,0x066,GetCyberIDAttr(d0,d1))
#pragma amicall(CyberGfxBase,0x06C,ReadRGBPixel(a1,d0,d1))
#pragma amicall(CyberGfxBase,0x072,WriteRGBPixel(a1,d0,d1,d2))
#pragma amicall(CyberGfxBase,0x078,ReadPixelArray(a0,d0,d1,d2,a1,d3,d4,d5,d6,d7))
#pragma amicall(CyberGfxBase,0x07E,WritePixelArray(a0,d0,d1,d2,a1,d3,d4,d5,d6,d7))
#pragma amicall(CyberGfxBase,0x084,MovePixelArray(d0,d1,a1,d2,d3,d4,d5))
#pragma amicall(CyberGfxBase,0x090,InvertPixelArray(a1,d0,d1,d2,d3))
#pragma amicall(CyberGfxBase,0x096,FillPixelArray(a1,d0,d1,d2,d3,d4))
#pragma amicall(CyberGfxBase,0x09C,DoCDrawMethodTagList(a0,a1,a2))
#pragma amicall(CyberGfxBase,0x0A2,CVideoCtrlTagList(a0,a1))
#pragma amicall(CyberGfxBase,0x0A8,LockBitMapTagList(a0,a1))
#pragma amicall(CyberGfxBase,0x0AE,UnLockBitMap(a0))
#pragma amicall(CyberGfxBase,0x0B4,UnLockBitMapTagList(a0,a1))
#pragma amicall(CyberGfxBase,0x0BA,ExtractColor(a0,a1,d0,d1,d2,d3,d4))
#pragma amicall(CyberGfxBase,0x0C6,WriteLUTPixelArray(a0,d0,d1,d2,a1,a2,d3,d4,d5,d6,d7))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall CyberGfxBase IsCyberModeID        036 001
#pragma  libcall CyberGfxBase BestCModeIDTagList   03C 801
#pragma  libcall CyberGfxBase CModeRequestTagList  042 9802
#pragma  libcall CyberGfxBase AllocCModeListTagList 048 901
#pragma  libcall CyberGfxBase FreeCModeList        04E 801
#pragma  libcall CyberGfxBase ScalePixelArray      05A 76543921080A
#pragma  libcall CyberGfxBase GetCyberMapAttr      060 0802
#pragma  libcall CyberGfxBase GetCyberIDAttr       066 1002
#pragma  libcall CyberGfxBase ReadRGBPixel         06C 10903
#pragma  libcall CyberGfxBase WriteRGBPixel        072 210904
#pragma  libcall CyberGfxBase ReadPixelArray       078 76543921080A
#pragma  libcall CyberGfxBase WritePixelArray      07E 76543921080A
#pragma  libcall CyberGfxBase MovePixelArray       084 543291007
#pragma  libcall CyberGfxBase InvertPixelArray     090 3210905
#pragma  libcall CyberGfxBase FillPixelArray       096 43210906
#pragma  libcall CyberGfxBase DoCDrawMethodTagList 09C A9803
#pragma  libcall CyberGfxBase CVideoCtrlTagList    0A2 9802
#pragma  libcall CyberGfxBase LockBitMapTagList    0A8 9802
#pragma  libcall CyberGfxBase UnLockBitMap         0AE 801
#pragma  libcall CyberGfxBase UnLockBitMapTagList  0B4 9802
#pragma  libcall CyberGfxBase ExtractColor         0BA 432109807
#pragma  libcall CyberGfxBase WriteLUTPixelArray   0C6 76543A921080B
#endif
#ifdef __STORM__
#pragma tagcall(CyberGfxBase,0x03C,BestCModeIDTags(a0))
#pragma tagcall(CyberGfxBase,0x042,CModeRequestTags(a0,a1))
#pragma tagcall(CyberGfxBase,0x048,AllocCModeListTags(a1))
#pragma tagcall(CyberGfxBase,0x09C,DoCDrawMethodTags(a0,a1,a2))
#pragma tagcall(CyberGfxBase,0x0A2,CVideoCtrlTags(a0,a1))
#pragma tagcall(CyberGfxBase,0x0A8,LockBitMapTags(a0,a1))
#pragma tagcall(CyberGfxBase,0x0B4,UnLockBitMapTags(a0,a1))
#endif
#ifdef __SASC_60
#pragma  tagcall CyberGfxBase BestCModeIDTags      03C 801
#pragma  tagcall CyberGfxBase CModeRequestTags     042 9802
#pragma  tagcall CyberGfxBase AllocCModeListTags   048 901
#pragma  tagcall CyberGfxBase DoCDrawMethodTags    09C A9803
#pragma  tagcall CyberGfxBase CVideoCtrlTags       0A2 9802
#pragma  tagcall CyberGfxBase LockBitMapTags       0A8 9802
#pragma  tagcall CyberGfxBase UnLockBitMapTags     0B4 9802
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_CYBERGRAPHICS_LIB_H  */
