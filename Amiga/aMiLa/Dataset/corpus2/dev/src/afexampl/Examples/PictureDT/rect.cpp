//////////////////////////////////////////////////////////////////////////////
// rect.cpp
//
// Jeffry A Worth
// November 10, 1995
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// INCLUDES
#include "aframe:include/rect.hpp"

//////////////////////////////////////////////////////////////////////////////
//

AFPoint::AFPoint(LONG x, LONG y)
{
	m_x = x;
	m_y = y;
}

void AFPoint::SetPoint(LONG x, LONG y)
{
	m_x = x;
	m_y = y;
}

void AFPoint::SetPoint(AFPoint* point)
{
	m_x = point->m_x;
	m_y = point->m_y;
}

AFPoint* AFPoint::operator+=(AFPoint* point)
{
	m_x+=point->m_x;
	m_y+=point->m_y;
	return this;
}

AFPoint* AFPoint::operator+=(AFPoint point)
{
	m_x+=point.m_x;
	m_y+=point.m_y;
	return this;
}

AFPoint* AFPoint::operator-=(AFPoint* point)
{
	m_x-=point->m_x;
	m_y-=point->m_y;
	return this;
}

AFPoint* AFPoint::operator-=(AFPoint point)
{
	m_x-=point.m_x;	
	m_y-=point.m_y;
	return this;
}

AFRect::AFRect(ULONG x1, ULONG y1, ULONG x2, ULONG y2)
{
  m_TopLeft.SetPoint(x1,y1);
  m_BottomRight.SetPoint(x2,y2);
}

AFRect::AFRect()
{
  m_TopLeft.SetPoint(0,0);
  m_BottomRight.SetPoint(0,0);
}

void AFRect::SetRect(ULONG x1, ULONG y1, ULONG x2, ULONG y2)
{
  m_TopLeft.SetPoint(x1,y1);
  m_BottomRight.SetPoint(x2,y2);
}

void AFRect::SetRect(AFPoint* tl, AFPoint* br)
{
  m_TopLeft.SetPoint(tl);
  m_BottomRight.SetPoint(br);
}

AFPoint* AFRect::TopLeft()
{
  return &m_TopLeft;
}

AFPoint* AFRect::BottomRight()
{
  return &m_BottomRight;
}

ULONG AFRect::Width()
{
  if(m_BottomRight.m_x > m_TopLeft.m_x)
    return m_BottomRight.m_x - m_TopLeft.m_x;
  return m_TopLeft.m_x - m_BottomRight.m_x;
}

ULONG AFRect::Height()
{
  if(m_BottomRight.m_y > m_TopLeft.m_y)
    return m_BottomRight.m_y - m_TopLeft.m_y;
  return m_TopLeft.m_y - m_BottomRight.m_y;
}

AFRect* AFRect::operator+=(AFPoint* point)
{
	m_TopLeft+=point;
	m_BottomRight+=point;
    return this;
}

AFRect* AFRect::operator+=(AFPoint point)
{
	m_TopLeft+=point;
	m_BottomRight+=point;
    return this;
}

AFRect* AFRect::operator-=(AFPoint* point)
{
	m_TopLeft-=point;
	m_BottomRight-=point;
    return this;
}

AFRect* AFRect::operator-=(AFPoint point)
{
	m_TopLeft-=point;
	m_BottomRight-=point;
    return this;
}

AFRect* AFRect::operator=(AFRect* rect)
{
    SetRect(rect->TopLeft(),rect->BottomRight());
    return this;
}
