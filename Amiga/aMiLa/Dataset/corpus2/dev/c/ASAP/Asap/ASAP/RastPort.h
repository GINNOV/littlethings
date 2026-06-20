/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * ARastPort wrapper class                                                   *
 *                                                                           *
 *****************************************************************************/

extern "C"
{
 #include <Proto/Graphics.h>
 #include <Proto/GadTools.h>
 #include <Proto/Intuition.h>
 #include <Proto/Layers.h>
}

class ARastPort : public RastPort
{
 public:
 inline LONG AreaDraw(long x, long y);
 inline LONG AreaEllipse(long xCenter, long yCenter, long a, long b);
 inline LONG AreaEnd();
 inline LONG AreaMove(long x, long y);
 inline void AskFont(TextAttr * textAttr);
 inline ULONG AskSoftStyle();
 inline void BltPattern(PLANEPTR mask, long xMin, long yMin, long xMax, long yMax, unsigned long maskBPR);
 inline void ClearEOL();
 inline void ClearScreen();
 inline void ClipBlit(long xSrc, long ySrc, RastPort * destRP, long xDest, long yDest, long xSize, long ySize, unsigned long minterm);
 inline void DoCollision();
 inline void Draw(long x, long y);
 inline void DrawBevelBox(long left, long top, long width, long height, Tag tag1, ... );
 inline void DrawBevelBoxA(long left, long top, long width, long height, TagItem * taglist);
 inline void DrawBorder(Border * border, long leftOffset, long topOffset);
 inline void DrawEllipse(long xCenter, long yCenter, long a, long b);
 inline void DrawGList(ViewPort * vp);
 inline void DrawImage(Image * image, long leftOffset, long topOffset);
 inline void DrawImageState(Image * image, long leftOffset, long topOffset, unsigned long state, DrawInfo * drawInfo);
 inline void EraseImage(Image * image, long leftOffset, long topOffset);
 inline void EraseRect(long xMin, long yMin, long xMax, long yMax);
 inline BOOL Flood(unsigned long mode, long x, long y);
 inline ULONG GetAPen();
 inline ULONG GetBPen();
 inline ULONG GetDrMd();
 inline ULONG GetOutlinePen();
 inline void GetRPAttrs(unsigned long tag1Type, ... );
 inline void GetRPAttrsA(TagItem * tags);
 inline void InitRastPort();
 inline void Move(long x, long y);
 inline static ARastPort * ObtainGIRPort(GadgetInfo *gInfo );
 inline void * operator new(size_t, GadgetInfo *gInfo);
 inline void PolyDraw(long count, WORD * polyTable);
 inline void PrintIText(IntuiText * iText, long left, long top);
 inline ULONG ReadPixel(long x, long y);
 inline LONG ReadPixelArray8(unsigned long xstart, unsigned long ystart, unsigned long xstop, unsigned long ystop, UBYTE * array, RastPort * temprp);
 inline LONG ReadPixelLine8(unsigned long xstart, unsigned long ystart, unsigned long width, UBYTE * array, RastPort * tempRP);
 inline void RectFill(long xMin, long yMin, long xMax, long yMax);
 inline void ReleaseGIRPort();
 inline void operator delete(void *rp);
 inline void ScrollRaster(long dx, long dy, long xMin, long yMin, long xMax, long yMax);
 inline void ScrollRasterBF(long dx, long dy, long xMin, long yMin, long xMax, long yMax);
 inline void SetABPenDrMd(unsigned long apen, unsigned long bpen, unsigned long drawmode);
 inline void SetAPen(unsigned long pen);
 inline void SetBPen(unsigned long pen);
 inline void SetDrMd(unsigned long drawMode);
 inline LONG SetFont(TextFont * textFont);
 inline void SetMaxPen(unsigned long maxpen);
 inline ULONG SetOutlinePen(unsigned long pen);
 inline void SetRPAttrs(unsigned long tag1Type, ... );
 inline void SetRPAttrsA(TagItem * tags);
 inline void SetRast(unsigned long pen);
 inline ULONG SetSoftStyle(unsigned long style, unsigned long enable);
 inline ULONG SetWriteMask(unsigned long msk);
 inline void SortGList();
 inline void SwapBitsRastPortClipRect(ClipRect * cr);
 inline LONG Text(STRPTR string, unsigned long count);
 inline WORD TextExtent(STRPTR string, long count, struct TextExtent * textExtent);
 inline ULONG TextFit(STRPTR string, unsigned long strLen, struct TextExtent * textExtent, struct TextExtent * constrainingExtent, long strDirection, unsigned long constrainingBitWidth, unsigned long constrainingBitHeight);
 inline WORD TextLength(STRPTR string, unsigned long count);
 inline void WriteChunkyPixels(unsigned long xstart, unsigned long ystart, unsigned long xstop, unsigned long ystop, UBYTE * array, long bytesperrow);
 inline LONG WritePixel(long x, long y);
 inline LONG WritePixelArray8(unsigned long xstart, unsigned long ystart, unsigned long xstop, unsigned long ystop, UBYTE * array, RastPort * temprp);
 inline LONG WritePixelLine8(unsigned long xstart, unsigned long ystart, unsigned long width, UBYTE * array, RastPort * tempRP);
};
//----------------------------------------------------------------------------
LONG ARastPort::AreaDraw (long x, long y)
{
 return ::AreaDraw(this, x, y);
}
//----------------------------------------------------------------------------
LONG ARastPort::AreaEllipse (long xCenter, long yCenter, long a, long b)
{
 return ::AreaEllipse(this, xCenter, yCenter, a, b);
}
//----------------------------------------------------------------------------
LONG ARastPort::AreaEnd ()
{
 return ::AreaEnd(this);
}
//----------------------------------------------------------------------------
LONG ARastPort::AreaMove (long x, long y)
{
 return ::AreaMove(this, x, y);
}
//----------------------------------------------------------------------------
void ARastPort::AskFont (TextAttr * textAttr)
{
 ::AskFont(this, textAttr);
}
//----------------------------------------------------------------------------
ULONG ARastPort::AskSoftStyle ()
{
 return ::AskSoftStyle(this);
}
//----------------------------------------------------------------------------
void ARastPort::BltPattern (PLANEPTR mask, long xMin, long yMin, long xMax, long yMax, unsigned long maskBPR)
{
 ::BltPattern(this, mask, xMin, yMin, xMax, yMax, maskBPR);
}
//----------------------------------------------------------------------------
void ARastPort::ClearEOL ()
{
 ::ClearEOL(this);
}
//----------------------------------------------------------------------------
void ARastPort::ClearScreen ()
{
 ::ClearScreen(this);
}
//----------------------------------------------------------------------------
void ARastPort::ClipBlit (long xSrc, long ySrc, RastPort * destRP, long xDest, long yDest, long xSize, long ySize, unsigned long minterm)
{
 ::ClipBlit(this, xSrc, ySrc, destRP, xDest, yDest, xSize, ySize, minterm);
}
//----------------------------------------------------------------------------
void ARastPort::DoCollision ()
{
 ::DoCollision(this);
}
//----------------------------------------------------------------------------
void ARastPort::Draw (long x, long y)
{
 ::Draw(this, x, y);
}
//----------------------------------------------------------------------------
void ARastPort::DrawBevelBox (long left, long top, long width, long height, Tag tag1, ... )
{
 DrawBevelBoxA(left, top, width, height, (TagItem *) &tag1);
}
//----------------------------------------------------------------------------
void ARastPort::DrawBevelBoxA (long left, long top, long width, long height, TagItem * taglist)
{
 ::DrawBevelBoxA(this, left, top, width, height, taglist);
}
//----------------------------------------------------------------------------
void ARastPort::DrawBorder (Border * border, long leftOffset, long topOffset)
{
 ::DrawBorder(this, border, leftOffset, topOffset);
}
//----------------------------------------------------------------------------
void ARastPort::DrawEllipse (long xCenter, long yCenter, long a, long b)
{
 ::DrawEllipse(this, xCenter, yCenter, a, b);
}
//----------------------------------------------------------------------------
void ARastPort::DrawGList (ViewPort * vp)
{
 ::DrawGList(this, vp);
}
//----------------------------------------------------------------------------
void ARastPort::DrawImage (Image * image, long leftOffset, long topOffset)
{
 ::DrawImage(this, image, leftOffset, topOffset);
}
//----------------------------------------------------------------------------
void ARastPort::DrawImageState (Image * image, long leftOffset, long topOffset, unsigned long state, DrawInfo * drawInfo)
{
 ::DrawImageState(this, image, leftOffset, topOffset, state, drawInfo);
}
//----------------------------------------------------------------------------
void ARastPort::EraseImage (Image * image, long leftOffset, long topOffset)
{
 ::EraseImage(this, image, leftOffset, topOffset);
}
//----------------------------------------------------------------------------
void ARastPort::EraseRect (long xMin, long yMin, long xMax, long yMax)
{
 ::EraseRect(this, xMin, yMin, xMax, yMax);
}
//----------------------------------------------------------------------------
BOOL ARastPort::Flood (unsigned long mode, long x, long y)
{
 return ::Flood(this, mode, x, y);
}
//----------------------------------------------------------------------------
ULONG ARastPort::GetAPen ()
{
 return ::GetAPen(this);
}
//----------------------------------------------------------------------------
ULONG ARastPort::GetBPen ()
{
 return ::GetBPen(this);
}
//----------------------------------------------------------------------------
ULONG ARastPort::GetDrMd ()
{
 return ::GetDrMd(this);
}
//----------------------------------------------------------------------------
ULONG ARastPort::GetOutlinePen ()
{
 return ::GetOutlinePen(this);
}
//----------------------------------------------------------------------------
void ARastPort::GetRPAttrs (unsigned long tag1Type, ... )
{
 GetRPAttrsA((TagItem *) &tag1Type);
}
//----------------------------------------------------------------------------
void ARastPort::GetRPAttrsA (TagItem * tags)
{
 ::GetRPAttrsA(this, tags);
}
//----------------------------------------------------------------------------
void ARastPort::InitRastPort ()
{
 ::InitRastPort(this);
}
//----------------------------------------------------------------------------
void ARastPort::Move (long x, long y)
{
 ::Move(this, x, y);
}
//----------------------------------------------------------------------------
ARastPort * ObtainGIRPort (GadgetInfo *gInfo)
{
 return (ARastPort *) ::ObtainGIRPort(gInfo);
}
//----------------------------------------------------------------------------
void * ARastPort::operator new (size_t, GadgetInfo *gInfo)
{
 return ARastPort::ObtainGIRPort(gInfo);
}
//----------------------------------------------------------------------------
void ARastPort::PolyDraw (long count, WORD * polyTable)
{
 ::PolyDraw(this, count, polyTable);
}
//----------------------------------------------------------------------------
void ARastPort::PrintIText (IntuiText * iText, long left, long top)
{
 ::PrintIText(this, iText, left, top);
}
//----------------------------------------------------------------------------
ULONG ARastPort::ReadPixel (long x, long y)
{
 return ::ReadPixel(this, x, y);
}
//----------------------------------------------------------------------------
LONG ARastPort::ReadPixelArray8 (unsigned long xstart, unsigned long ystart, unsigned long xstop, unsigned long ystop, UBYTE * array, RastPort * temprp)
{
 return ::ReadPixelArray8(this, xstart, ystart, xstop, ystop, array, temprp);
}
//----------------------------------------------------------------------------
LONG ARastPort::ReadPixelLine8 (unsigned long xstart, unsigned long ystart, unsigned long width, UBYTE * array, RastPort * tempRP)
{
 return ::ReadPixelLine8(this, xstart, ystart, width, array, tempRP);
}
//----------------------------------------------------------------------------
void ARastPort::RectFill (long xMin, long yMin, long xMax, long yMax)
{
 ::RectFill(this, xMin, yMin, xMax, yMax);
}
//----------------------------------------------------------------------------
void ARastPort::ReleaseGIRPort ()
{
 ::ReleaseGIRPort(this);
}
//----------------------------------------------------------------------------
void ARastPort::operator delete (void *rp)
{
 ((ARastPort *) rp)->ReleaseGIRPort();
}
//----------------------------------------------------------------------------
void ARastPort::ScrollRaster (long dx, long dy, long xMin, long yMin, long xMax, long yMax)
{
 ::ScrollRaster(this, dx, dy, xMin, yMin, xMax, yMax);
}
//----------------------------------------------------------------------------
void ARastPort::ScrollRasterBF (long dx, long dy, long xMin, long yMin, long xMax, long yMax)
{
 ::ScrollRasterBF(this, dx, dy, xMin, yMin, xMax, yMax);
}
//----------------------------------------------------------------------------
void ARastPort::SetABPenDrMd (unsigned long apen, unsigned long bpen, unsigned long drawmode)
{
 ::SetABPenDrMd(this, apen, bpen, drawmode);
}
//----------------------------------------------------------------------------
void ARastPort::SetAPen (unsigned long pen)
{
 ::SetAPen(this, pen);
}
//----------------------------------------------------------------------------
void ARastPort::SetBPen (unsigned long pen)
{
 ::SetBPen(this, pen);
}
//----------------------------------------------------------------------------
void ARastPort::SetDrMd (unsigned long drawMode)
{
 ::SetDrMd(this, drawMode);
}
//----------------------------------------------------------------------------
LONG ARastPort::SetFont (TextFont * textFont)
{
 return ::SetFont(this, textFont);
}
//----------------------------------------------------------------------------
void ARastPort::SetMaxPen (unsigned long maxpen)
{
 ::SetMaxPen(this, maxpen);
}
//----------------------------------------------------------------------------
ULONG ARastPort::SetOutlinePen (unsigned long pen)
{
 return ::SetOutlinePen(this, pen);
}
//----------------------------------------------------------------------------
void ARastPort::SetRPAttrs (unsigned long tag1Type, ... )
{
 SetRPAttrsA((TagItem *) &tag1Type);
}
//----------------------------------------------------------------------------
void ARastPort::SetRPAttrsA (TagItem * tags)
{
 ::SetRPAttrsA(this, tags);
}
//----------------------------------------------------------------------------
void ARastPort::SetRast (unsigned long pen)
{
 ::SetRast(this, pen);
}
//----------------------------------------------------------------------------
ULONG ARastPort::SetSoftStyle (unsigned long style, unsigned long enable)
{
 return ::SetSoftStyle(this, style, enable);
}
//----------------------------------------------------------------------------
ULONG ARastPort::SetWriteMask (unsigned long msk)
{
 return ::SetWriteMask(this, msk);
}
//----------------------------------------------------------------------------
void ARastPort::SortGList ()
{
 ::SortGList(this);
}
//----------------------------------------------------------------------------
void ARastPort::SwapBitsRastPortClipRect (ClipRect * cr)
{
 ::SwapBitsRastPortClipRect(this, cr);
}
//----------------------------------------------------------------------------
LONG ARastPort::Text (STRPTR string, unsigned long count)
{
 return ::Text(this, string, count);
}
//----------------------------------------------------------------------------
WORD ARastPort::TextExtent (STRPTR string, long count, struct TextExtent * textExtent)
{
 return ::TextExtent(this, string, count, textExtent);
}
//----------------------------------------------------------------------------
ULONG ARastPort::TextFit (STRPTR string, unsigned long strLen, struct TextExtent * textExtent, struct TextExtent * constrainingExtent, long strDirection, unsigned long constrainingBitWidth, unsigned long constrainingBitHeight)
{
 return ::TextFit(this, string, strLen, textExtent, constrainingExtent, strDirection, constrainingBitWidth, constrainingBitHeight);
}
//----------------------------------------------------------------------------
WORD ARastPort::TextLength (STRPTR string, unsigned long count)
{
 return ::TextLength(this, string, count);
}
//----------------------------------------------------------------------------
void ARastPort::WriteChunkyPixels (unsigned long xstart, unsigned long ystart, unsigned long xstop, unsigned long ystop, UBYTE * array, long bytesperrow)
{
 ::WriteChunkyPixels(this, xstart, ystart, xstop, ystop, array, bytesperrow);
}
//----------------------------------------------------------------------------
LONG ARastPort::WritePixel (long x, long y)
{
 return ::WritePixel(this, x, y);
}
//----------------------------------------------------------------------------
LONG ARastPort::WritePixelArray8 (unsigned long xstart, unsigned long ystart, unsigned long xstop, unsigned long ystop, UBYTE * array, RastPort * temprp)
{
 return ::WritePixelArray8(this, xstart, ystart, xstop, ystop, array, temprp);
}
//----------------------------------------------------------------------------
LONG ARastPort::WritePixelLine8 (unsigned long xstart, unsigned long ystart, unsigned long width, UBYTE * array, RastPort * tempRP)
{
 return ::WritePixelLine8(this, xstart, ystart, width, array, tempRP);
}
