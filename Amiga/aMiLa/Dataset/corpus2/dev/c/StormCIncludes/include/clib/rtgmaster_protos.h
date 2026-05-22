#ifndef RTGMASTER_PROTOS_H
#define RTGMASTER_PROTOS_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef RTGMASTER_RTGMASTER_H
#include <rtgmaster/rtgmaster.h>
#endif

#ifndef RTGMASTER_RTGSUBLIBS_H
#include <rtgmaster/rtgsublibs.h>
#endif

#if defined(__STORM__) && defined(__PPC__)
#include <stormprotos/rtgmaster_sprotos.h>
#else

#ifdef __cplusplus
extern "C" {
#endif

struct RtgScreen * OpenRtgScreen(struct ScreenReq *sreq, struct TagItem *taglist);
struct RtgScreen * OpenRtgScreenTags(struct ScreenReq *sreq, unsigned long tag1Type, ...);
void   CloseRtgScreen(struct RtgScreen *MyScreen);
void   SwitchScreens(struct RtgScreen *MyScreen, ULONG Buffer);
void   LoadRGBRtg(struct RtgScreen *MyScreen, void *Table);
void   *LockRtgScreen(struct RtgScreen *MyScreen);
void   UnlockRtgScreen(struct RtgScreen *MyScreen);
void   *GetBufAdr(struct RtgScreen *MyScreen, ULONG Buffer);
void   GetRtgScreenData(struct RtgScreen *MyScreen, struct TagItem *taglist);
void   GetRtgScreenDataTags(struct RtgScreen *MyScreen, unsigned long tag1Type, ... );
ULONG  RtgScreenAtFront(struct RtgScreen *MyScreen);
struct ScreenReq * RtgScreenModeReq(struct TagItem *taglist);
struct ScreenReq * RtgScreenModeReqTags(unsigned long tag1Type, ... );
void   FreeRtgScreenModeReq(struct ScreenReq *MyReq);
void   WriteRtgPixel(struct RtgScreen *MyScreen, APTR BufferAdr, ULONG XPos, ULONG YPos, UWORD Color);
void   WriteRtgPixelRGB(struct RtgScreen *MyScreen, APTR BufferAdr, ULONG XPos, ULONG YPos, ULONG Pixel);
void   FillRtgRect(struct RtgScreen *MyScreen, APTR BufferAdr, ULONG Color, ULONG Left, ULONG Top, ULONG Width, ULONG Height);
void   FillRtgRectRGB(struct RtgScreen *MyScreen, APTR BufferAdr, ULONG Color, ULONG Left, ULONG Top, ULONG Width, ULONG Height);
void   WriteRtgPixelArray(struct RtgScreen *MyScreen, APTR BufferAdr, APTR Array, ULONG Left, ULONG Top, ULONG Width, ULONG Height);
void   WriteRtgPixelRGBArray(struct RtgScreen *MyScreen, APTR BufferAdr, APTR Array, ULONG Left, ULONG Top, ULONG Width, ULONG Height);
void   CopyRtgPixelArray(struct RtgScreen *MyScreen, APTR BufferAdr, APTR Array, ULONG Left, ULONG Top, ULONG Width, ULONG Height,ULONG SrcX,ULONG SrcY);
void   DrawRtgLine(struct RtgScreen *MyScreen, APTR BufferAdr, ULONG Color, ULONG X1, ULONG Y1, ULONG X2, ULONG Y2);
void   DrawRtgLineRGB(struct RtgScreen *MyScreen, APTR BufferAdr, ULONG Color, ULONG X1, ULONG Y1, ULONG X2, ULONG Y2);
void   WaitRtgSwitch(struct RtgScreen *MyScreen);
void   WaitRtgBlit(struct RtgScreen *MyScreen);
void   RtgWaitTOF(struct RtgScreen *MyScreen);
void   RtgBlit(struct RtgScreen *MyScreen, int SrcBuf, int DstBuf, ULONG SrcX, ULONG SrcY, ULONG DstX, ULONG DstY, ULONG Width, ULONG Height,UBYTE minterm);
void   RtgBltClear(struct RtgScreen *MyScreen, int BufNum,ULONG xpos, ULONG ypos, ULONG width, ULONG height);
int    CallRtgC2P(struct RtgScreen *MyScreen, APTR BufAdr,APTR Array, ULONG signal, ULONG xpos, ULONG ypos, ULONG width, ULONG height, ULONG mode);
void RtgText(struct RtgScreen *MyScreen,void *map, char *mytext,WORD length,SHORT xpos,SHORT ypos);
void RtgSetFont(struct RtgScreen *MyScreen,void *myfont);
void RtgClearPointer(struct RtgScreen *MyScreen);
void RtgSetPointer(struct RtgScreen *MyScreen,UWORD *pointer,WORD Height,WORD Width,WORD XOffset,WORD YOffset);
void RtgSetTextMode(struct RtgScreen *MyScreen,UBYTE fgcolor,UBYTE bgcolor,UBYTE drmode);
void *RtgOpenFont(struct RtgScreen *MyScreen,struct TextAttr *ta);
void RtgCloseFont(struct RtgScreen *MyScreen,void *myfont);
void RtgSetTextModeRGB(struct RtgScreen *MyScreen,ULONG fgcolor,ULONG bgcolor,UBYTE drmode);
void *RtgInitRDCMP(struct RtgScreen *MyScreen);
void RtgWaitRDCMP(struct RtgScreen *MyScreen);
void *RtgGetMsg(struct RtgScreen *MyScreen);
void RtgReplyMsg(struct RtgScreen *MyScreen,void *msg);
int RtgCheckVSync(struct RtgScreen *MyScreen);
struct ScreenReqList *RtgAllocSRList(struct TagItem *tags);
struct ScreenReqList *RtgAllocSRListTags(unsigned long tag1Type, ... );
void FreeRtgSRList(struct ScreenReqList *req);
struct ScreenReq *RtgBestSR(struct TagItem *tags);
struct ScreenReq *RtgBestSRTags(unsigned long tag1Type, ... );
void CopyRtgBlit(struct RtgScreen *RtgScreen, APTR BufferAdr, APTR Array, ULONG Masked, ULONG Left, ULONG Top, ULONG Width, ULONG Height, ULONG WidthSrc, ULONG HeightSrc, ULONG SrcX, ULONG SrcY);
void RtgInitBob(struct RtgScreen *RtgScreen, APTR RtgBob, APTR BackAdr, APTR BufferAdr, ULONG xpos, ULONG ypos, ULONG display);
int CheckPPCCommand(struct RtgScreen *MyScreen,ULONG command);
struct RtgBobHandle *InitRtgBobSystem(struct RtgScreen *MyScreen,ULONG MaxNum);
void CloseRtgBobSystem(struct RtgBobHandle *bob);
void RtgScreenToFront(struct RtgScreen *MyScreen);
void RtgConvert(UBYTE *source,UBYTE *dest,int bpr, int height, int format, int cspace);


#ifdef __cplusplus
};
#endif

#endif

#endif
