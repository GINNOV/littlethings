//////////////////////////////////////////////////////////////////////////////
// pointer.hpp
//
// Deryk Robosson
// February 29, 1996
//////////////////////////////////////////////////////////////////////////////

#ifndef __POINTER_HPP__
#define __POINTER_HPP__

//////////////////////////////////////////////////////////////////////////////
// INCLUDES
#include "aframe:include/object.hpp"
#include "aframe:include/window.hpp"
#include "aframe:include/screen.hpp"

//////////////////////////////////////////////////////////////////////////////
// Definitions

//////////////////////////////////////////////////////////////////////////////
// Pointer Class

class AFPointer : public AFObject
{
public:
  AFPointer();
  ~AFPointer();

  virtual void DestroyObject();
  virtual char *ObjectType() { return "Pointer"; };

  virtual void SetPointer(AFWindow *window, UWORD ptrdata[], long height, long width, long xoffset, long yoffset);
  virtual void SetWindowPointer(AFWindow* window, struct TagItem *taglist);
  virtual void ClearPointer(AFWindow* window);


  UWORD *m_pPointer;
  long m_pPtrHeight;
  long m_pPtrWidth;
  long m_pXOffset;
  long m_pYOffset;
};

//////////////////////////////////////////////////////////////////////////////
#endif // __POINTER_HPP__
