//////////////////////////////////////////////////////////////////////////////
// rastport.cpp
//
// Jeffry A Worth
// November 10, 1995
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// INCLUDES
#include "aframe:include/rastport.hpp"

//////////////////////////////////////////////////////////////////////////////
//

AFRastPort::AFRastPort(AFWindow* pwindow)
{
  if(pwindow) {
    m_prastport = pwindow->m_pWindow->RPort;
    m_pwindow = pwindow->m_pWindow;
  } else
    m_pwindow = NULL;
}

AFRastPort::AFRastPort(AFScreen* pscreen)
{
  if(pscreen)
    m_prastport = &(pscreen->m_pScreen->RastPort);
}

void AFRastPort::FromWindow(AFWindow* pwindow)
{
  if(pwindow) {  
    m_prastport = pwindow->m_pWindow->RPort;
    m_pwindow = pwindow->m_pWindow;
  }
}

void AFRastPort::FromScreen(AFScreen* pscreen)
{
  if(pscreen)
    m_prastport = &(pscreen->m_pScreen->RastPort);
}

void AFRastPort::FromHandle(LPWindow pwindow)
{
  if(pwindow) {
    m_prastport = pwindow->RPort;
    m_pwindow = pwindow;
  }
}

// Graphics functions

void AFRastPort::Clear()
{
  ::ClearScreen(m_prastport);
}

void AFRastPort::TextOut(AFPoint* point, AFString* string)
{
	TextOut(point->m_x,point->m_y,string->data(),string->length());
}

void AFRastPort::TextOut(ULONG x, ULONG y, char *lpszData, ULONG length)
{
  if(m_prastport) {
    ::Move(m_prastport,x,y);
    ::Text(m_prastport,lpszData,length);
  }
}

void AFRastPort::Move(ULONG x, ULONG y)
{
  if(m_prastport) {
    ::Move(m_prastport,x,y);
  }
}

void AFRastPort::Move(AFPoint* point)
{
  if(m_prastport) {
    ::Move(m_prastport,point->m_x,point->m_y);
  }
}

void AFRastPort::Draw(ULONG x, ULONG y)
{
  if(m_prastport) {
    ::Draw(m_prastport,x,y);
  }
}

void AFRastPort::Draw(AFPoint* point)
{
  if(m_prastport) {
    ::Draw(m_prastport,point->m_x,point->m_y);
  }
}

void AFRastPort::Text(char *lpszData, ULONG length)
{
  if(m_prastport) {
    ::Text(m_prastport,lpszData,length);
  }
}

void AFRastPort::SetAPen(UBYTE pen)
{
  if(m_prastport) {
    ::SetAPen(m_prastport,pen);
  }
}

void AFRastPort::SetBPen(UBYTE pen)
{
  if(m_prastport) {
    ::SetBPen(m_prastport,pen);
  }
}

void AFRastPort::SetDrMd(ULONG drawmode)
{
  if(m_prastport) {
    ::SetDrMd(m_prastport,drawmode);
  }
}

ULONG AFRastPort::GetAPen()
{
  return ::GetAPen(m_prastport);
}

ULONG AFRastPort::GetBPen()
{
  return ::GetBPen(m_prastport);
}

ULONG AFRastPort::GetDrMd()
{
  return ::GetDrMd(m_prastport);
}

void AFRastPort::RectFill(AFRect* prect)
{
  int x1,x2,y1,y2,tmp;

  // Get all the coordinates
  x1=prect->TopLeft()->m_x;
  x2=prect->BottomRight()->m_x;
  y1=prect->TopLeft()->m_y;
  y2=prect->BottomRight()->m_y;

  // Make sure coordinated go down and to the right
  // This is required by the RectFill function
  if(x1>x2) {
    tmp=x1;x1=x2;x2=tmp;
  }
  if(y1>y2) {
    tmp=y1;y1=y2;y2=tmp;
  }

  ::RectFill(m_prastport,x1,y1,x2,y2);
}

void AFRastPort::Rect(AFRect* prect)
{
  Move(prect->TopLeft());
  Draw(prect->BottomRight()->m_x,prect->TopLeft()->m_y);
  Draw(prect->BottomRight()->m_x,prect->BottomRight()->m_y);
  Draw(prect->TopLeft()->m_x,prect->BottomRight()->m_y);
  Draw(prect->TopLeft());
}

long AFRastPort::TextLength(char *text,long length)
{
  return ::TextLength(m_prastport,text,length);
}

void AFRastPort::DrawEllipse(AFRect* rect)
{
  AFPoint point((rect->TopLeft()->m_x+rect->BottomRight()->m_x)/2,(rect->TopLeft()->m_y+rect->BottomRight()->m_y)/2);
  
  DrawEllipse(&point,rect->Width()/2,rect->Height()/2);
}

void AFRastPort::DrawEllipse(AFPoint* point, long radius)
{
  DrawEllipse(point,radius,radius);
}

void AFRastPort::DrawEllipse(AFPoint* point, long xradius, long yradius)
{
  if( (xradius > 0) && (yradius > 0) )
    ::DrawEllipse(m_prastport,point->m_x,point->m_y,xradius,yradius);
}

void AFRastPort::Flood(AFPoint* point, int mode)
{
  // This function at present will not wirk,  it also need to make sure there
  // is a TmpRas structure formed to perform the floodfill before it can actually
  // do the flood fill.

  ::Flood(m_prastport,point->m_x,point->m_y,mode);
}

void AFRastPort::Flood(AFPoint* point)
{
  Flood(point,0);
}

void AFRastPort::TextExtent(char *string, int count, PTEXTEXTENT textextent)
{
  ::TextExtent(m_prastport,string,count,textextent);
}

void AFRastPort::AskFont(PTEXTATTR textattr)
{
  ::AskFont(m_prastport,textattr);
}

// Feb 28, 1996
void AFRastPort::SetRGB4(struct ViewPort *vp, long index,
                        ULONG red, ULONG blue, ULONG green)
{
  ::SetRGB4(vp,index,red,blue,green);
}

void
AFRastPort::DrawImage(AFPoint point, LPImage image)
{
	::DrawImage(m_prastport,image,point.m_x,point.m_y);
}
