//////////////////////////////////////////////////////////////////////////////
// msgprompt.cpp
//
// Jeffry A Worth
// November 10, 1995
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// INCLUDES
#include <string.h>
#include "aframe:include/msgprompt.hpp"
#include "aframe:include/button.hpp"
#include "aframe:include/rastport.hpp"

//////////////////////////////////////////////////////////////////////////////
//

AFMsgPrompt::AFMsgPrompt()
{
  m_pgadgets = NULL;
}

ULONG AFMsgPrompt::Prompt(AFWindow* pParent, char* szMessage, char* szTitle, ULONG uFlags)
{
  AFRastPort rp(pParent);
  AFRect rect;
  AFNode *node;
  AFButton *button;
  long length;

  length = rp.TextLength(szMessage, strlen(szMessage));
  rect.SetRect(10,10,10+length+25,110);
  Create(pParent->m_papp,&rect,szTitle);

  rp.FromWindow(this);
  rp.SetAPen(1);
  rp.TextOut(10,10,szMessage,strlen(szMessage));

  button = new AFButton;
  rect.SetRect(10,50,70,65);
  button->Create("OK",this,&rect,100);
  RefreshGadgets();
  
  WaitPort(m_pWindow->UserPort);

  DestroyWindow();
  delete button;

  return 100;
}

ULONG AFMsgPrompt::WindowFlags()
{
  return WFLG_DRAGBAR | WFLG_DEPTHGADGET | WFLG_CLOSEGADGET | WFLG_ACTIVATE | WFLG_GIMMEZEROZERO;
}
