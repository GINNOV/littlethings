//////////////////////////////////////////////////////////////////////////////
// rect.hpp
//
// Jeffry A Worth
// November 10, 1995
//////////////////////////////////////////////////////////////////////////////

#ifndef __RECT_HPP__
#define __RECT_HPP__

//////////////////////////////////////////////////////////////////////////////
// Includes
#include <exec/types.h>

//////////////////////////////////////////////////////////////////////////////
// Point Class

class AFPoint
{
public:
  AFPoint(LONG x = 0, LONG y = 0);
  void SetPoint(LONG x, LONG y);
  void SetPoint(AFPoint* point);
  AFPoint* operator+=(AFPoint* point);
  AFPoint* operator+=(AFPoint point);
  AFPoint* operator-=(AFPoint* point);
  AFPoint* operator-=(AFPoint point);

  LONG m_x;
  LONG m_y;
};

//////////////////////////////////////////////////////////////////////////////
// Rect Class

class AFRect
{
public:
  AFRect(ULONG x1, ULONG y1, ULONG x2, ULONG y2);
  AFRect();

  void SetRect(ULONG x1, ULONG y1, ULONG x2, ULONG y2);
  void SetRect(AFPoint* tl, AFPoint* br);
  AFPoint* TopLeft();
  AFPoint* BottomRight();
  ULONG Width();
  ULONG Height();
  AFRect* operator+=(AFPoint* point);
  AFRect* operator+=(AFPoint point);
  AFRect* operator-=(AFPoint* point);
  AFRect* operator-=(AFPoint point);
  AFRect* operator=(AFRect* rect);

private:
  AFPoint m_TopLeft;
  AFPoint m_BottomRight;
};

//////////////////////////////////////////////////////////////////////////////
#endif // __RECT_HPP__
