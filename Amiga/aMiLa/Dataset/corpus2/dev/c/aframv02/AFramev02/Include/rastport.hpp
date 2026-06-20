//////////////////////////////////////////////////////////////////////////////
// rastport.hpp
//
// Jeffry A Worth
// November 10, 1995
//////////////////////////////////////////////////////////////////////////////

#ifndef __RASTPORT_HPP__
#define __RASTPORT_HPP__

//////////////////////////////////////////////////////////////////////////////
// Includes
#include "aframe:include/window.hpp"
#include "aframe:include/string.hpp"
#include "graphics/rastport.h"

//////////////////////////////////////////////////////////////////////////////
// Raster Port Class

class AFRastPort 
{
public:
  AFRastPort(AFWindow* pwindow = NULL);   // Default constructor
  AFRastPort(AFScreen* pscreen = NULL);
  virtual void FromWindow(AFWindow* pwindow); // Create from a AFWindow Object
  virtual void FromScreen(AFScreen* pscreen);   // Create from a AFScreen Object
  virtual void FromHandle(LPWindow pwindow); // Create from a Window structure ((AFWindow*)->m_pWindow)

// Graphics functions
  virtual void Clear();
  virtual void TextOut(ULONG x, ULONG y, char* lpszData, ULONG length);
  virtual void Move(ULONG x, ULONG y);
  virtual void Move(AFPoint* point);
  virtual void Draw(ULONG x, ULONG y);
  virtual void Draw(AFPoint* point);
  virtual void Text(char *lpszData, ULONG length);
  virtual void SetAPen(UBYTE pen);
  virtual void SetBPen(UBYTE pen);
  virtual void SetDrMd(ULONG drawMode);
  virtual void SetRGB4(struct ViewPort *vp, long index, ULONG red, ULONG green, ULONG blue);
  virtual ULONG GetAPen();
  virtual ULONG GetBPen();
  virtual ULONG GetDrMd();
  virtual void RectFill(AFRect* prect);
  virtual void Rect(AFRect* prect);
  virtual long TextLength(char *text,long length);
  virtual void DrawEllipse(AFRect *prect);
  virtual void DrawEllipse(AFPoint* point, long radius);
  virtual void DrawEllipse(AFPoint* point, long xradius, long yradius);
  virtual void Flood(AFPoint* point, int mode);
  virtual void Flood(AFPoint* point);
  virtual void TextExtent(char *string, int count, PTEXTEXTENT textextent);
  virtual void AskFont(PTEXTATTR textattr);
  virtual void DrawImage(AFPoint point,LPImage image);

private:
  LPRastPort m_prastport;
  LPWindow m_pwindow;

public:
  virtual void TextOut(AFPoint* point,AFString* string);
};

//////////////////////////////////////////////////////////////////////////////
#endif // __RASTPORT_HPP__
