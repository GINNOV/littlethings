//////////////////////////////////////////////////////////////////////////////
// screen.hpp
//
// Jeffry A Worth
// December 19, 1995
//////////////////////////////////////////////////////////////////////////////

#ifndef __AFSCREEN_HPP__
#define __AFSCREEN_HPP__

//////////////////////////////////////////////////////////////////////////////
// Includes
#include "aframe:include/aframe.hpp"
#include "aframe:include/amigaapp.hpp"
#include "aframe:include/rect.hpp"

//////////////////////////////////////////////////////////////////////////////
// Structures

//////////////////////////////////////////////////////////////////////////////
// Window Class

class AFScreen : public AFObject
{
public:
  AFScreen();
  ~AFScreen();

// Methods
  virtual BOOL Create(AFAmigaApp* app, AFRect* rect);
  virtual BOOL Create(AFAmigaApp* app, AFRect* rect, char *szTitle, int depth, LONG displayid);
  virtual void DestroyObject();
  virtual void PostNCDestroy() { return; };

// Setup Functions
  virtual ULONG GetDisplayID();

  virtual void OnCreate() { return; };

// Properties
  AFAmigaApp *m_papp;
  LPScreen m_pScreen;
  char *m_sztitle;
};

//////////////////////////////////////////////////////////////////////////////
#endif //__AFSCREEN_HPP__
