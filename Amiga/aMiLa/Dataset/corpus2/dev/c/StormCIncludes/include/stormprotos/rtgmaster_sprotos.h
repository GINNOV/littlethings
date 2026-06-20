#ifndef STORMPROTOS_RTGMASTER_SPROTOS_H
#define STORMPROTOS_RTGMASTER_SPROTOS_H

#ifdef __PPC__

extern "AmigaLib" RTGMasterBase
{
	struct RtgScreen *PPCOpenRtgScreen_(struct Library*,struct ScreenReq *,struct TagItem *) = -0x156;
	void PPCCloseRtgScreen_(struct Library*,struct RtgScreen*) = -0x15c;
	void PPCSwitchScreens_(struct Library*,struct RtgScreen*,ULONG) = -0x162;
	void PPCLoadRGBRtg_(struct Library*,struct RtgScreen*,void*) = -0x168;
	void *PPCLockRtgScreen_(struct Library*,struct RtgScreen*) = -0x16e;
	void PPCUnlockRtgScreen_(struct Library*,struct RtgScreen*) = -0x174;
	void *PPCGetBufAdr_(struct Library*,struct RtgScreen*,ULONG) = -0x17a;
	void PPCGetRtgScreenData_(struct Library*,struct RtgScreen *,struct TagItem*) = -0x180;
	ULONG PPCRtgScreenAtFront_(struct Library*,struct RtgScreen*) = -0x192;
	struct ScreenReq *PPCRtgScreenModeReq_(struct Library*,struct TagItem*) = -0x198;
	void PPCFreeRtgScreenModeReq_(struct Library*,struct ScreenReq*) = -0x19e;
	void PPCWriteRtgPixel_(struct Library*,struct RtgScreen*,APTR,ULONG,ULONG,UWORD) = -0x1a4;
	void PPCWriteRtgPixelRGB_(struct Library*,struct RtgScreen*,APTR,ULONG,ULONG,ULONG) = -0x1aa;
	void PPCFillRtgRect_(struct Library*,struct RtgScreen*,APTR,ULONG,ULONG,ULONG,ULONG,ULONG) = -0x1b0;
	void PPCFillRtgRectRGB_(struct Library*,struct RtgScreen*,APTR,ULONG,ULONG,ULONG,ULONG,ULONG) = -0x1b6;
	void PPCWriteRtgPixelArray_(struct Library*,struct RtgScreen*,APTR,APTR,ULONG,ULONG,ULONG,ULONG) = -0x1bc;
	void PPCWriteRtgPixelRGBArray_(struct Library*,struct RtgScreen*,APTR,APTR,ULONG,ULONG,ULONG,ULONG) = -0x1c2;
	void PPCCopyRtgPixelArray_(struct Library*,struct RtgScreen*,APTR,APTR,ULONG,ULONG,ULONG,ULONG,ULONG,ULONG) = -0x1c8;
	void PPCDrawRtgLine_(struct Library*,struct RtgScreen*,APTR,ULONG,ULONG,ULONG,ULONG,ULONG) = -0x1d4;
	void PPCDrawRtgLineRGB_(struct Library*,struct RtgScreen*,APTR,ULONG,ULONG,ULONG,ULONG,ULONG) = -0x1da;
	void PPCWaitRtgSwitch_(struct Library*,struct RtgScreen*) = -0x1e0;
	void PPCWaitRtgBlit_(struct Library*,struct RtgScreen*) = -0x1e6;
	void PPCRtgWaitTOF_(struct Library*,struct RtgScreen*) = -0x1ec;
	void PPCRtgBlit_(struct Library*,struct RtgScreen*,int,int,ULONG,ULONG,ULONG,ULONG,ULONG,ULONG,UBYTE) = -0x1f2;
	void PPCRtgBltClear_(struct Library*,struct RtgScreen*,int,ULONG,ULONG,ULONG,ULONG) = -0x1f8;
	int PPCCallRtgC2P_(struct Library*,struct RtgScreen *MyScreen, APTR BufAdr,APTR Array, ULONG signal, ULONG xpos, ULONG ypos, ULONG width, ULONG height, ULONG mode) = -0x1fe;
	void PPCRtgText_(struct Library*,struct RtgScreen*,void *,char*,WORD,SHORT,SHORT) = -0x246;
	void PPCRtgSetFont_(struct Library*,struct RtgScreen*,void*) = -0x24c;
	void PPCRtgClearPointer_(struct Library*,struct RtgScreen*) = -0x252;
	void PPCRtgSetPointer_(struct Library*,struct RtgScreen*,UWORD*,WORD,WORD,WORD,WORD) = -0x258;
	void PPCRtgSetTextMode_(struct Library*,struct RtgScreen*,UBYTE,UBYTE,UBYTE) = -0x25e;
	void *PPCRtgOpenFont_(struct Library*,struct RtgScreen*,struct TextAttr*) = -0x264;
	void PPCRtgCloseFont_(struct Library*,struct RtgScreen*,void*) = -0x26a;
	void PPCRtgSetTextModeRGB_(struct Library*,struct RtgScreen*,UBYTE,UBYTE,UBYTE) = -0x270;
	void *PPCRtgInitRDCMP_(struct Library*,struct RtgScreen*) = -0x276;
	void PPCRtgWaitRDCMP_(struct Library*,struct RtgScreen*) = -0x27c;
	void *PPCRtgGetMsg_(struct Library*,struct RtgScreen*) = -0x282;
	void PPCRtgReplyMsg_(struct Library*,struct RtgScreen*,void*) = -0x288;
	int PPCRtgCheckVSync_(struct Library*,struct RtgScreen*) = -0x20a;
	struct ScreenReqList *PPCRtgAllocSRList_(struct Library *,struct TagItem *) = -0x186;
	void PPCFreeRtgSRList_(struct Library *,struct ScreenReqList *) = -0x18c;
	struct ScreenReq *PPCRtgBestSR_(struct Library *,struct TagItem *) = -0x204;
	void PPCCopyRtgBlit_(struct Library*,struct RtgScreen *,APTR,APTR,ULONG,ULONG,ULONG,ULONG,ULONG,ULONG,ULONG,ULONG,ULONG) = -0x1ce;
	struct RtgBobHandle *PPCInitRtgBobSystem_(struct Library*,struct RtgScreen*,ULONG) = -528;
	void PPCCloseRtgBobSystem_(struct Library*,struct RtgBobHandle*) = -540;
	int PPCCheckPPCCommand_(struct Library*,struct RtgScreen*,ULONG) = -0x216;
	void PPCRtgScreenToFront_(struct Library *,struct RtgScreen *MyScreen) = -0x294;
	void PPCRtgConvert_(struct Library *,UBYTE *source,UBYTE *dest,int bpr, int height, int format, int cspace) = -0x2A0;
}

__inline void PPCRtgScreenToFront(struct RtgScreen *MyScreen)
{
 extern struct Library *RTGMasterBase;
 PPCRtgScreenToFront_(RTGMasterBase,MyScreen);
}
__inline void PPCRtgConvert(UBYTE *source,UBYTE *dest,int bpr, int height, int format, int cspace)
{
 extern struct Library *RTGMasterBase;
 PPCRtgConvert_(RTGMasterBase,source,dest,bpr,height,format,cspace);
}

__inline struct RtgScreen *PPCOpenRtgScreen(struct ScreenReq *sreq, struct TagItem *taglist)
{
 extern struct Library *RTGMasterBase;
 return PPCOpenRtgScreen_(RTGMasterBase,sreq,taglist);
}

__inline void PPCCloseRtgScreen(struct RtgScreen *MyScreen)
{
 extern struct Library *RTGMasterBase;
 PPCCloseRtgScreen_(RTGMasterBase,MyScreen);
}

__inline void PPCSwitchScreens(struct RtgScreen *MyScreen,ULONG Buffer)
{
 extern struct Library *RTGMasterBase;
 PPCSwitchScreens_(RTGMasterBase,MyScreen,Buffer);
}

__inline void PPCLoadRGBRtg(struct RtgScreen *MyScreen, void *Tables)
{
 extern struct Library *RTGMasterBase;
 PPCLoadRGBRtg_(RTGMasterBase,MyScreen,Tables);
}

__inline void *PPCLockRtgScreen(struct RtgScreen *MyScreen)
{
 extern struct Library *RTGMasterBase;
 return PPCLockRtgScreen_(RTGMasterBase,MyScreen);
}

__inline void PPCUnlockRtgScreen(struct RtgScreen *MyScreen)
{
 extern struct Library *RTGMasterBase;
 PPCUnlockRtgScreen_(RTGMasterBase,MyScreen);
}

__inline void *PPCGetBufAdr(struct RtgScreen *MyScreen,ULONG Buffer)
{
 extern struct Library *RTGMasterBase;
 return PPCGetBufAdr_(RTGMasterBase,MyScreen,Buffer);
}

__inline void PPCGetRtgScreenData(struct RtgScreen *MyScreen,struct  TagItem *taglist)
{
 extern struct Library *RTGMasterBase;
 PPCGetRtgScreenData_(RTGMasterBase,MyScreen,taglist);
}

__inline ULONG PPCRtgScreenAtFront(struct RtgScreen *MyScreen)
{
 extern struct Library *RTGMasterBase;
 return PPCRtgScreenAtFront_(RTGMasterBase,MyScreen);
}

__inline struct ScreenReq *PPCRtgScreenModeReq(struct TagItem *taglist)
{
 extern struct Library *RTGMasterBase;
 return PPCRtgScreenModeReq_(RTGMasterBase,taglist);
}

__inline void PPCFreeRtgScreenModeReq(struct ScreenReq *myreq)
{
 extern struct Library *RTGMasterBase;
 PPCFreeRtgScreenModeReq_(RTGMasterBase,myreq);
}

__inline void PPCWriteRtgPixel(struct RtgScreen *MyScreen,APTR BufferAdr, ULONG XPos, ULONG YPos, UWORD Color)
{
 extern struct Library *RTGMasterBase;
 PPCWriteRtgPixel_(RTGMasterBase,MyScreen,BufferAdr,XPos,YPos,Color);
}

__inline void PPCWriteRtgPixelRGB(struct RtgScreen *MyScreen,APTR BufferAdr, ULONG XPos, ULONG YPos, ULONG Pixel)
{
 extern struct Library *RTGMasterBase;
 PPCWriteRtgPixelRGB_(RTGMasterBase,MyScreen,BufferAdr,XPos,YPos,Pixel);
}

__inline void PPCFillRtgRect(struct RtgScreen *MyScreen,APTR BufferAdr, ULONG Color, ULONG Left, ULONG Top, ULONG Width, ULONG Height)
{
 extern struct Library *RTGMasterBase;
 PPCFillRtgRect_(RTGMasterBase,MyScreen,BufferAdr,Color,Left,Top,Width,Height);
}

__inline void PPCFillRtgRectRGB(struct RtgScreen *MyScreen,APTR BufferAdr, ULONG Color, ULONG Left, ULONG Top, ULONG Width, ULONG Height)
{
 extern struct Library *RTGMasterBase;
 PPCFillRtgRectRGB_(RTGMasterBase,MyScreen,BufferAdr,Color,Left,Top,Width,Height);
}

__inline void PPCWriteRtgPixelArray(struct RtgScreen *MyScreen,APTR BufferAdr, APTR Array, ULONG Left, ULONG Top, ULONG Width, ULONG Height)
{
 extern struct Library *RTGMasterBase;
 PPCWriteRtgPixelArray_(RTGMasterBase,MyScreen,BufferAdr,Array,Left,Top,Width,Height);
}

__inline void PPCWriteRtgPixelRGBArray(struct RtgScreen *MyScreen,APTR BufferAdr, APTR Array, ULONG Left, ULONG Top, ULONG Width, ULONG Height)
{
 extern struct Library *RTGMasterBase;
 PPCWriteRtgPixelRGBArray_(RTGMasterBase,MyScreen,BufferAdr,Array,Left,Top,Width,Height);
}

__inline void PPCCopyRtgPixelArray(struct RtgScreen *MyScreen,APTR BufferAdr, APTR Array, ULONG Left, ULONG Top, ULONG Width, ULONG Height, ULONG SrcX, ULONG SrcY)
{
 extern struct Library *RTGMasterBase;
 PPCCopyRtgPixelArray_(RTGMasterBase,MyScreen,BufferAdr,Array,Left,Top,Width,Height,SrcX,SrcY);
}

__inline void PPCDrawRtgLine(struct RtgScreen *MyScreen,APTR BufferAdr, ULONG Color, ULONG X1, ULONG Y1, ULONG X2, ULONG Y2)
{
 extern struct Library *RTGMasterBase;
 PPCDrawRtgLine_(RTGMasterBase,MyScreen,BufferAdr,Color,X1,Y1,X2,Y2);
}

__inline void PPCDrawRtgLineRGB(struct RtgScreen *MyScreen,APTR BufferAdr, ULONG Color, ULONG X1, ULONG Y1, ULONG X2, ULONG Y2)
{
 extern struct Library *RTGMasterBase;
 PPCDrawRtgLineRGB_(RTGMasterBase,MyScreen,BufferAdr,Color,X1,Y1,X2,Y2);
}

__inline void PPCWaitRtgSwitch(struct RtgScreen *MyScreen)
{
 extern struct Library *RTGMasterBase;
 PPCWaitRtgSwitch_(RTGMasterBase,MyScreen);
}

__inline void PPCWaitRtgBlit(struct RtgScreen *MyScreen)
{
 extern struct Library *RTGMasterBase;
 PPCWaitRtgBlit_(RTGMasterBase,MyScreen);
}

__inline void PPCRtgWaitTOF(struct RtgScreen *MyScreen)
{
 extern struct Library *RTGMasterBase;
 PPCRtgWaitTOF_(RTGMasterBase,MyScreen);
}

__inline void PPCRtgBlit(struct RtgScreen *MyScreen, int SrcBuf, int DstBuf, ULONG SrcX, ULONG SrcY, ULONG DstX, ULONG DstY, ULONG Width, ULONG Height,UBYTE minterm)
{
 extern struct Library *RTGMasterBase;
 PPCRtgBlit_(RTGMasterBase,MyScreen,SrcBuf,DstBuf,SrcX,SrcY,DstX,DstY,Width,Height,minterm);
}

__inline void PPCRtgBltClear(struct RtgScreen *MyScreen, int BufNum, ULONG xpos, ULONG ypos, ULONG width, ULONG height)
{
 extern struct Library *RTGMasterBase;
 PPCRtgBltClear_(RTGMasterBase,MyScreen,BufNum,xpos,ypos,width,height);
}

__inline int PPCCallRtgC2P(struct RtgScreen *MyScreen, APTR BufAdr,APTR Array, ULONG signal, ULONG xpos, ULONG ypos, ULONG width, ULONG height, ULONG mode)
{
 extern struct Library *RTGMasterBase;
 return PPCCallRtgC2P_(RTGMasterBase,MyScreen,BufAdr,Array,signal,xpos,ypos,width,height,mode);
}

__inline void PPCRtgText(struct RtgScreen *MyScreen,void *map, char *mytext,WORD length,SHORT xpos,SHORT ypos)
{
 extern struct Library *RTGMasterBase;
 PPCRtgText_(RTGMasterBase,MyScreen,map,mytext,length,xpos,ypos);
}

__inline void PPCRtgSetFont(struct RtgScreen *MyScreen,void *myfont)
{
 extern struct Library *RTGMasterBase;
 PPCRtgSetFont_(RTGMasterBase,MyScreen,myfont);
}

__inline void PPCRtgClearPointer(struct RtgScreen *MyScreen)
{
 extern struct Library *RTGMasterBase;
 PPCRtgClearPointer_(RTGMasterBase,MyScreen);
}

__inline void PPCRtgSetPointer(struct RtgScreen *MyScreen,UWORD *pointer,WORD Height,WORD Width,WORD XOffset,WORD YOffset)
{
 extern struct Library *RTGMasterBase;
 PPCRtgSetPointer_(RTGMasterBase,MyScreen,pointer,Height,Width,XOffset,YOffset);
}

__inline void PPCRtgSetTextMode(struct RtgScreen *MyScreen,UBYTE fgcolor,UBYTE bgcolor,UBYTE drmode)
{
 extern struct Library *RTGMasterBase;
 PPCRtgSetTextMode_(RTGMasterBase,MyScreen,fgcolor,bgcolor,drmode);
}

__inline void *PPCRtgOpenFont(struct RtgScreen *MyScreen,struct TextAttr *ta)
{
 extern struct Library *RTGMasterBase;
 return PPCRtgOpenFont_(RTGMasterBase,MyScreen,ta);
}

__inline void PPCRtgCloseFont(struct RtgScreen *MyScreen,void *myfont)
{
 extern struct Library *RTGMasterBase;
 PPCRtgCloseFont_(RTGMasterBase,MyScreen,myfont);
}

__inline void PPCRtgSetTextModeRGB(struct RtgScreen *MyScreen,ULONG fgcolor,ULONG bgcolor,UBYTE drmode)
{
 extern struct Library *RTGMasterBase;
 PPCRtgSetTextModeRGB_(RTGMasterBase,MyScreen,fgcolor,bgcolor,drmode);
}

__inline void *PPCRtgInitRDCMP(struct RtgScreen *MyScreen)
{
 extern struct Library *RTGMasterBase;
 return PPCRtgInitRDCMP_(RTGMasterBase,MyScreen);
}

__inline void PPCRtgWaitRDCMP(struct RtgScreen *MyScreen)
{
 extern struct Library *RTGMasterBase;
 PPCRtgWaitRDCMP_(RTGMasterBase,MyScreen);
}

__inline void *PPCRtgGetMsg(struct RtgScreen *MyScreen)
{
 extern struct Library *RTGMasterBase;
 return PPCRtgGetMsg_(RTGMasterBase,MyScreen);
}

__inline void PPCRtgReplyMsg(struct RtgScreen *MyScreen,void *msg)
{
 extern struct Library *RTGMasterBase;
 PPCRtgReplyMsg_(RTGMasterBase,MyScreen,msg);
}

__inline int PPCRtgCheckVSync(struct RtgScreen *MyScreen)
{
 extern struct Library *RTGMasterBase;
 return PPCRtgCheckVSync_(RTGMasterBase,MyScreen);
}

__inline struct ScreenReqList *PPCRtgAllocSRList(struct TagItem *tags)
{
 extern struct Library *RTGMasterBase;
 return PPCRtgAllocSRList_(RTGMasterBase,tags);
}

__inline void PPCFreeRtgSRList(struct ScreenReqList *req)
{
 extern struct Library *RTGMasterBase;
 PPCFreeRtgSRList_(RTGMasterBase,req);
}

__inline struct ScreenReq *PPCRtgBestSR(struct TagItem *tags)
{
 extern struct Library *RTGMasterBase;
 return PPCRtgBestSR_(RTGMasterBase,tags);
}

__inline void PPCCopyRtgBlit(struct RtgScreen *RtgScreen, APTR BufferAdr, APTR Array, ULONG Masked, ULONG Left, ULONG Top, ULONG Width, ULONG Height, ULONG WidthSrc, ULONG HeightSrc, ULONG SrcX, ULONG SrcY)
{
 extern struct Library *RTGMasterBase;
 PPCCopyRtgBlit_(RTGMasterBase,RtgScreen,BufferAdr,Array,Masked,Left,Top,Width,Height,WidthSrc,HeightSrc,SrcX,SrcY);
}

__inline struct RtgBobHandle *PPCInitRtgBobSystem(struct RtgScreen *RtgScreen, ULONG MaxNum)
{
 extern struct Library *RTGMasterBase;
 return(PPCInitRtgBobSystem_(RTGMasterBase,RtgScreen,MaxNum));
}

__inline void PPCCloseRtgBobSystem(struct RtgBobHandle *bob)
{
 extern struct Library *RTGMasterBase;
 PPCCloseRtgBobSystem_(RTGMasterBase,bob);
}

__inline int PPCCheckPPCCommand(struct RtgScreen *MyScreen, ULONG command)
{
 extern struct Library *RTGMasterBase;
 return PPCCheckPPCCommand_(RTGMasterBase,MyScreen,command);
}

#endif

#endif
