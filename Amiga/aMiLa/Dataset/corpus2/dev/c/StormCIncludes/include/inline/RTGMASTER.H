#ifndef _INLINE_RTGMASTER_H
#define _INLINE_RTGMASTER_H

#ifndef RTGMASTER_BASE_NAME
#define RTGMASTER_BASE_NAME RTGMasterBase
#endif

#define OpenRtgScreen(ScreenReq, Tags) \
	((struct RtgScreen * (*)(struct ScreenReq * __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) RTGMASTER_BASE_NAME) - 30))(ScreenReq, Tags, (struct Library *) RTGMASTER_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define OpenRtgScreenTags(ScreenReq, tags...) \
	({ULONG _tags[] = {tags}; OpenRtgScreen((ScreenReq), (unsigned long) _tags);})
#endif

#define CloseRtgScreen(MyScreen) \
	((void (*)(struct RtgScreen * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) RTGMASTER_BASE_NAME) - 36))(MyScreen, (struct Library *) RTGMASTER_BASE_NAME)

#define SwitchScreens(MyScreen, Buffer) \
	((void (*)(struct RtgScreen * __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) RTGMASTER_BASE_NAME) - 42))(MyScreen, Buffer, (struct Library *) RTGMASTER_BASE_NAME)

#define LoadRGBRtg(RtgScreen, Table) \
	((void (*)(struct RtgScreen * __asm("a0"), void * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) RTGMASTER_BASE_NAME) - 48))(RtgScreen, Table, (struct Library *) RTGMASTER_BASE_NAME)

#define LockRtgScreen(RtgScreen) \
	((void   * (*)(struct RtgScreen * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) RTGMASTER_BASE_NAME) - 54))(RtgScreen, (struct Library *) RTGMASTER_BASE_NAME)

#define UnlockRtgScreen(RtgScreen) \
	((void (*)(struct RtgScreen * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) RTGMASTER_BASE_NAME) - 60))(RtgScreen, (struct Library *) RTGMASTER_BASE_NAME)

#define GetBufAdr(RtgScreen, Buffer) \
	((void   * (*)(struct RtgScreen * __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) RTGMASTER_BASE_NAME) - 66))(RtgScreen, Buffer, (struct Library *) RTGMASTER_BASE_NAME)

#define GetRtgScreenData(MyScreen, taglist) \
	((void (*)(struct RtgScreen * __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) RTGMASTER_BASE_NAME) - 72))(MyScreen, taglist, (struct Library *) RTGMASTER_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define GetRtgScreenDataTags(MyScreen, tags...) \
	({ULONG _tags[] = {tags}; GetRtgScreenData((MyScreen), (unsigned long) _tags);})
#endif

#define RtgAllocSRList(tags) \
	((struct ScreenReqList * (*)(struct TagItem * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) RTGMASTER_BASE_NAME) - 78))(tags, (struct Library *) RTGMASTER_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define RtgAllocSRListTags(tags...) \
	({ULONG _tags[] = {tags}; RtgAllocSRList((unsigned long) _tags);})
#endif

#define FreeRtgSRList(req) \
	((void (*)(struct ScreenReqList * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) RTGMASTER_BASE_NAME) - 84))(req, (struct Library *) RTGMASTER_BASE_NAME)

#define RtgScreenAtFront(RtgScreen) \
	((ULONG (*)(struct RtgScreen * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) RTGMASTER_BASE_NAME) - 90))(RtgScreen, (struct Library *) RTGMASTER_BASE_NAME)

#define RtgScreenModeReq(Tags) \
	((struct ScreenReq * (*)(struct TagItem * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) RTGMASTER_BASE_NAME) - 96))(Tags, (struct Library *) RTGMASTER_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define RtgScreenModeReqTags(tags...) \
	({ULONG _tags[] = {tags}; RtgScreenModeReq((unsigned long) _tags);})
#endif

#define FreeRtgScreenModeReq(MyReq) \
	((void (*)(struct ScreenReq * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) RTGMASTER_BASE_NAME) - 102))(MyReq, (struct Library *) RTGMASTER_BASE_NAME)

#define WriteRtgPixel(MyScreen, BufferAdr, XPos, YPos, Color) \
	((void (*)(struct RtgScreen * __asm("a0"), APTR __asm("a1"), ULONG __asm("d0"), ULONG __asm("d1"), UWORD __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) RTGMASTER_BASE_NAME) - 108))(MyScreen, BufferAdr, XPos, YPos, Color, (struct Library *) RTGMASTER_BASE_NAME)

#define WriteRtgPixelRGB(MyScreen, BufferAdr, XPos, YPos, Pixel) \
	((void (*)(struct RtgScreen * __asm("a0"), APTR __asm("a1"), ULONG __asm("d0"), ULONG __asm("d1"), ULONG __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) RTGMASTER_BASE_NAME) - 114))(MyScreen, BufferAdr, XPos, YPos, Pixel, (struct Library *) RTGMASTER_BASE_NAME)

#define FillRtgRect(MyScreen, BufferAdr, Color, Left, Top, Width, Height) \
	((void (*)(struct RtgScreen * __asm("a0"), APTR __asm("a1"), ULONG __asm("d0"), ULONG __asm("d1"), ULONG __asm("d2"), ULONG __asm("d3"), ULONG __asm("d4"), struct Library * __asm("a6"))) \
  (((char *) RTGMASTER_BASE_NAME) - 120))(MyScreen, BufferAdr, Color, Left, Top, Width, Height, (struct Library *) RTGMASTER_BASE_NAME)

#define FillRtgRectRGB(MyScreen, BufferAdr, Color, Left, Top, Width, Height) \
	((void (*)(struct RtgScreen * __asm("a0"), APTR __asm("a1"), ULONG __asm("d0"), ULONG __asm("d1"), ULONG __asm("d2"), ULONG __asm("d3"), ULONG __asm("d4"), struct Library * __asm("a6"))) \
  (((char *) RTGMASTER_BASE_NAME) - 126))(MyScreen, BufferAdr, Color, Left, Top, Width, Height, (struct Library *) RTGMASTER_BASE_NAME)

#define WriteRtgPixelArray(MyScreen, BufferAdr, Array, Left, Top, Width, Height) \
	((void (*)(struct RtgScreen * __asm("a0"), APTR __asm("a1"), APTR __asm("a2"), ULONG __asm("d0"), ULONG __asm("d1"), ULONG __asm("d2"), ULONG __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) RTGMASTER_BASE_NAME) - 132))(MyScreen, BufferAdr, Array, Left, Top, Width, Height, (struct Library *) RTGMASTER_BASE_NAME)

#define WriteRtgPixelRGBArray(MyScreen, BufferAdr, Array, Left, Top, Width, Height) \
	((void (*)(struct RtgScreen * __asm("a0"), APTR __asm("a1"), APTR __asm("a2"), ULONG __asm("d0"), ULONG __asm("d1"), ULONG __asm("d2"), ULONG __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) RTGMASTER_BASE_NAME) - 138))(MyScreen, BufferAdr, Array, Left, Top, Width, Height, (struct Library *) RTGMASTER_BASE_NAME)

#define CopyRtgPixelArray(MyScreen, BufferAdr, Array, Left, Top, Width, Height, SrcX, SrcY) \
	((void (*)(struct RtgScreen * __asm("a0"), APTR __asm("a1"), APTR __asm("a2"), ULONG __asm("d0"), ULONG __asm("d1"), ULONG __asm("d2"), ULONG __asm("d3"), ULONG __asm("d4"), ULONG __asm("d5"), struct Library * __asm("a6"))) \
  (((char *) RTGMASTER_BASE_NAME) - 144))(MyScreen, BufferAdr, Array, Left, Top, Width, Height, SrcX, SrcY, (struct Library *) RTGMASTER_BASE_NAME)

#define CopyRtgBlit(RtgScreen, BufferAdr, Array, Masked, Left, Top, Width, Height, WidthSrc, HeightSrc, SrcX, SrcY) \
	((void (*)(struct RtgScreen * __asm("a0"), APTR __asm("a1"), APTR __asm("a2"), ULONG __asm("a3"), ULONG __asm("d0"), ULONG __asm("d1"), ULONG __asm("d2"), ULONG __asm("d3"), ULONG __asm("d4"), ULONG __asm("d5"), ULONG __asm("d6"), ULONG __asm("d7"), struct Library * __asm("a6"))) \
  (((char *) RTGMASTER_BASE_NAME) - 150))(RtgScreen, BufferAdr, Array, Masked, Left, Top, Width, Height, WidthSrc, HeightSrc, SrcX, SrcY, (struct Library *) RTGMASTER_BASE_NAME)

#define DrawRtgLine(MyScreen, BufferAdr, Color, X1, Y1, X2, Y2) \
	((void (*)(struct RtgScreen * __asm("a0"), APTR __asm("a1"), ULONG __asm("d0"), ULONG __asm("d1"), ULONG __asm("d2"), ULONG __asm("d3"), ULONG __asm("d4"), struct Library * __asm("a6"))) \
  (((char *) RTGMASTER_BASE_NAME) - 156))(MyScreen, BufferAdr, Color, X1, Y1, X2, Y2, (struct Library *) RTGMASTER_BASE_NAME)

#define DrawRtgLineRGB(MyScreen, BufferAdr, Color, X1, Y1, X2, Y2) \
	((void (*)(struct RtgScreen * __asm("a0"), APTR __asm("a1"), ULONG __asm("d0"), ULONG __asm("d1"), ULONG __asm("d2"), ULONG __asm("d3"), ULONG __asm("d4"), struct Library * __asm("a6"))) \
  (((char *) RTGMASTER_BASE_NAME) - 162))(MyScreen, BufferAdr, Color, X1, Y1, X2, Y2, (struct Library *) RTGMASTER_BASE_NAME)

#define WaitRtgSwitch(MyScreen) \
	((void (*)(struct RtgScreen * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) RTGMASTER_BASE_NAME) - 168))(MyScreen, (struct Library *) RTGMASTER_BASE_NAME)

#define WaitRtgBlit(MyScreen) \
	((void (*)(struct RtgScreen * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) RTGMASTER_BASE_NAME) - 174))(MyScreen, (struct Library *) RTGMASTER_BASE_NAME)

#define RtgWaitTOF(MyScreen) \
	((void (*)(struct RtgScreen * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) RTGMASTER_BASE_NAME) - 180))(MyScreen, (struct Library *) RTGMASTER_BASE_NAME)

#define RtgBlit(MyScreen, SrcBuf, DstBuf, SrcX, SrcY, DstX, DstY, Width, Height, minterm) \
	((void (*)(struct RtgScreen * __asm("a0"), int __asm("a1"), int __asm("a2"), ULONG __asm("d0"), ULONG __asm("d1"), ULONG __asm("d2"), ULONG __asm("d3"), ULONG __asm("d4"), ULONG __asm("d5"), UBYTE __asm("d6"), struct Library * __asm("a6"))) \
  (((char *) RTGMASTER_BASE_NAME) - 186))(MyScreen, SrcBuf, DstBuf, SrcX, SrcY, DstX, DstY, Width, Height, minterm, (struct Library *) RTGMASTER_BASE_NAME)

#define RtgBltClear(MyScreen, BufNum, xpos, ypos, width, height) \
	((void (*)(struct RtgScreen * __asm("a0"), int __asm("a1"), ULONG __asm("d0"), ULONG __asm("d1"), ULONG __asm("d2"), ULONG __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) RTGMASTER_BASE_NAME) - 192))(MyScreen, BufNum, xpos, ypos, width, height, (struct Library *) RTGMASTER_BASE_NAME)

#define CallRtgC2P(MyScreen, BufAdr, Array, signal, xpos, ypos, width, height, mode) \
	((int (*)(struct RtgScreen * __asm("a0"), APTR __asm("a1"), APTR __asm("a2"), ULONG __asm("d0"), ULONG __asm("d1"), ULONG __asm("d2"), ULONG __asm("d3"), ULONG __asm("d4"), ULONG __asm("d5"), struct Library * __asm("a6"))) \
  (((char *) RTGMASTER_BASE_NAME) - 198))(MyScreen, BufAdr, Array, signal, xpos, ypos, width, height, mode, (struct Library *) RTGMASTER_BASE_NAME)

#define RtgBestSR(tags) \
	((struct ScreenReq * (*)(struct TagItem * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) RTGMASTER_BASE_NAME) - 204))(tags, (struct Library *) RTGMASTER_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define RtgBestSRTags(tags...) \
	({ULONG _tags[] = {tags}; RtgBestSR((unsigned long) _tags);})
#endif

#define RtgCheckVSync(RtgScreen) \
	((int (*)(struct RtgScreen * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) RTGMASTER_BASE_NAME) - 210))(RtgScreen, (struct Library *) RTGMASTER_BASE_NAME)

#define InitRtgBobSystem(RtgScreen, maxnum) \
	((struct RtgBobHandle * (*)(struct RtgScreen * __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) RTGMASTER_BASE_NAME) - 216))(RtgScreen, maxnum, (struct Library *) RTGMASTER_BASE_NAME)

#define CheckPPCCommand(RtgScreen, Command) \
	((int (*)(struct RtgScreen * __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) RTGMASTER_BASE_NAME) - 222))(RtgScreen, Command, (struct Library *) RTGMASTER_BASE_NAME)

#define CloseRtgBobSystem(RtgBobHandle) \
	((void (*)(struct RtgBobHandle * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) RTGMASTER_BASE_NAME) - 228))(RtgBobHandle, (struct Library *) RTGMASTER_BASE_NAME)

#define RtgText(MyScreen, map, mytext, length, xpos, ypos) \
	((void (*)(struct RtgScreen * __asm("a0"), void * __asm("a1"), char * __asm("a2"), WORD __asm("d0"), SHORT __asm("d1"), SHORT __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) RTGMASTER_BASE_NAME) - 270))(MyScreen, map, mytext, length, xpos, ypos, (struct Library *) RTGMASTER_BASE_NAME)

#define RtgSetFont(MyScreen, myfont) \
	((void (*)(struct RtgScreen * __asm("a0"), void * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) RTGMASTER_BASE_NAME) - 276))(MyScreen, myfont, (struct Library *) RTGMASTER_BASE_NAME)

#define RtgClearPointer(MyScreen) \
	((void (*)(struct RtgScreen * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) RTGMASTER_BASE_NAME) - 282))(MyScreen, (struct Library *) RTGMASTER_BASE_NAME)

#define RtgSetPointer(MyScreen, pointer, xpos, ypos, width, height) \
	((void (*)(struct RtgScreen * __asm("a0"), UWORD * __asm("a1"), WORD __asm("d0"), WORD __asm("d1"), WORD __asm("d2"), WORD __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) RTGMASTER_BASE_NAME) - 288))(MyScreen, pointer, xpos, ypos, width, height, (struct Library *) RTGMASTER_BASE_NAME)

#define RtgSetTextMode(MyScreen, fgcolor, bgcolor, drmode) \
	((void (*)(struct RtgScreen * __asm("a0"), UBYTE __asm("d0"), UBYTE __asm("d1"), UBYTE __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) RTGMASTER_BASE_NAME) - 294))(MyScreen, fgcolor, bgcolor, drmode, (struct Library *) RTGMASTER_BASE_NAME)

#define RtgOpenFont(MyScreen, myattr) \
	((void * (*)(struct RtgScreen * __asm("a0"), struct TextAttr * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) RTGMASTER_BASE_NAME) - 300))(MyScreen, myattr, (struct Library *) RTGMASTER_BASE_NAME)

#define RtgCloseFont(MyScreen, myfont) \
	((void (*)(struct RtgScreen * __asm("a0"), void * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) RTGMASTER_BASE_NAME) - 306))(MyScreen, myfont, (struct Library *) RTGMASTER_BASE_NAME)

#define RtgSetTextModeRGB(MyScreen, fgcolor, bgcolor, drmode) \
	((void (*)(struct RtgScreen * __asm("a0"), ULONG __asm("d0"), ULONG __asm("d1"), UBYTE __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) RTGMASTER_BASE_NAME) - 312))(MyScreen, fgcolor, bgcolor, drmode, (struct Library *) RTGMASTER_BASE_NAME)

#define RtgInitRDCMP(MyScreen) \
	((void * (*)(struct RtgScreen * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) RTGMASTER_BASE_NAME) - 318))(MyScreen, (struct Library *) RTGMASTER_BASE_NAME)

#define RtgWaitRDCMP(MyScreen) \
	((void (*)(struct RtgScreen * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) RTGMASTER_BASE_NAME) - 324))(MyScreen, (struct Library *) RTGMASTER_BASE_NAME)

#define RtgGetMsg(MyScreen) \
	((void * (*)(struct RtgScreen * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) RTGMASTER_BASE_NAME) - 330))(MyScreen, (struct Library *) RTGMASTER_BASE_NAME)

#define RtgReplyMsg(MyScreen, msg) \
	((void (*)(struct RtgScreen * __asm("a0"), void * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) RTGMASTER_BASE_NAME) - 336))(MyScreen, msg, (struct Library *) RTGMASTER_BASE_NAME)

#define RtgScreenToFront(RtgScreen) \
	((void (*)(struct RtgScreen * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) RTGMASTER_BASE_NAME) - 654))(RtgScreen, (struct Library *) RTGMASTER_BASE_NAME)

#define RtgConvert(source, dest, bpr, height, format, cspace) \
	((void (*)(UBYTE * __asm("a0"), UBYTE * __asm("a1"), int __asm("d0"), int __asm("d1"), int __asm("d2"), int __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) RTGMASTER_BASE_NAME) - 666))(source, dest, bpr, height, format, cspace, (struct Library *) RTGMASTER_BASE_NAME)

#endif /*  _INLINE_RTGMASTER_H  */
