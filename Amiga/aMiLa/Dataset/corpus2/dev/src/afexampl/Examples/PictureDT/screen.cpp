//////////////////////////////////////////////////////////////////////////////
// screen.cpp
//
// Jeffry A Worth
// December 19, 1995
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// INCLUDES
#include <string.h>
#include "aframe:include/screen.hpp"

//////////////////////////////////////////////////////////////////////////////
//

AFScreen::AFScreen()
{
  m_pScreen = NULL;
  return;
}

AFScreen::~AFScreen()
{
  DestroyObject();
}

BOOL AFScreen::Create(AFAmigaApp* app, AFRect* rect)
{
  return Create(app,rect,"",4,NULL);
}

BOOL AFScreen::Create(AFAmigaApp* app, AFRect* rect, char *szTitle,
                      int depth, long displayid)
{

  // Remember the Application for later
  m_papp = app;

  // Create a string for the Window Title
  m_sztitle = new char[strlen(szTitle)+1];
  if(m_sztitle) strcpy(m_sztitle,szTitle);

  if(displayid==NULL)
    displayid=HIRESLACE_KEY;

  // Open the Window the intuition way
  if(m_pScreen = OpenScreenTags(NULL,
	SA_Left,	rect->TopLeft()->m_x,
	SA_Top,		rect->TopLeft()->m_y,
	SA_Width,	rect->Width(),
	SA_Height,	rect->Height(),
	SA_Depth,	depth,
	SA_Title,	m_sztitle,
	SA_DisplayID,	displayid,
	TAG_END)) {

    // Fill the textattr structure
    //::AskFont(m_pWindow->RPort,&m_textattr);

    // Add window's sigbit to Application
    //app->m_SigBits |= 1<<(m_pWindow->UserPort->mp_SigBit);

    // Add window to the system window node list
    //app->m_pwindows = new AFNode((void*)this,app->m_pwindows);

    // Call OnCreate Method
    OnCreate();

    // Create was successful
    return TRUE;
  }
  return FALSE;
}

void AFScreen::DestroyObject()
{
  if(m_pScreen) {
    CloseScreen(m_pScreen),m_pScreen=NULL;
    PostNCDestroy();
  }
  if(m_sztitle) delete m_sztitle;
}

ULONG AFScreen::GetDisplayID()  // returns screen DisplayID
{
  return ::GetVPModeID(&(m_pScreen->ViewPort));
}
