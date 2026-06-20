//////////////////////////////////////////////////////////////////////////////
// pointer.cpp
//
// Deryk Robosson
// February 29, 1996
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// INCLUDES
#include "aframe:include/pointer.hpp"

//////////////////////////////////////////////////////////////////////////////
//

AFPointer::AFPointer()
{
}

AFPointer::~AFPointer()
{
  DestroyObject();
}

void AFPointer::DestroyObject()
{
}

//void AFPointer::Create()
//{
//}

void AFPointer::SetPointer(AFWindow* window, UWORD pointer[], long height, long width,
                           long xoffset, long yoffset)
{
  m_pPointer=pointer;
  m_pPtrHeight=height;
  m_pPtrWidth=width;
  m_pXOffset=xoffset;
  m_pYOffset=yoffset;
  ::SetPointer(window->m_pWindow,pointer,height,width,xoffset,yoffset);
}

void AFPointer::SetWindowPointer(AFWindow* window, struct TagItem* taglist)
{
  ::SetWindowPointerA(window->m_pWindow,taglist);
}

void AFPointer::ClearPointer(AFWindow* window)
{
  ::ClearPointer(window->m_pWindow);
}
