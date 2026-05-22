//////////////////////////////////////////////////////////////////////////////
// window.cpp
//
// Jeffry A Worth
// November 10, 1995
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// INCLUDES
#include <string.h>
#include "aframe:include/window.hpp"
#include "aframe:include/gadget.hpp"
#include "aframe:include/rastport.hpp"

//////////////////////////////////////////////////////////////////////////////
//

AFWindow::AFWindow()
	:m_pWindow(NULL),
	m_pscreen(NULL),
	m_papp(NULL),
	m_statusObject(NULL)
{
}

AFWindow::~AFWindow()
{
	// Call Destroy object is not already called
	if(m_pWindow)
		DestroyObject();
}

BOOL AFWindow::Create(AFAmigaApp* app, AFRect* rect)
{
  return Create(app,rect,"");
}

BOOL AFWindow::Create(AFScreen* screen, AFRect* rect)
{
  return Create(screen,rect,"");
}

BOOL AFWindow::Create(AFWindow* window, AFRect* rect)
{
  return Create(window,rect,"");
}

BOOL AFWindow::Create(AFWindow* window, AFRect* rect, char* szTitle)
{
  if(!m_pscreen)
    return Create(window->m_papp,rect,szTitle);
  else
    return Create(window->m_pscreen,rect,szTitle);
}

BOOL AFWindow::Create(AFAmigaApp* app, AFRect* rect, char *szTitle)
{
  struct WindowRange wr;

  // Remember the Application for later
  m_papp = app;

  // Create a string for the Window Title
  m_sztitle = new char[strlen(szTitle)+1];
  if(m_sztitle) strcpy(m_sztitle,szTitle);

  // Fill in the window range structure;
  SetWindowRange(&wr);

  // Open the Window the intuition way
  if(m_pWindow = OpenWindowTags((struct NewWindow*)NULL,
	WA_Left,	rect->TopLeft()->m_x,
	WA_Top,		rect->TopLeft()->m_y,
	WA_Width,	rect->Width(),
	WA_Height,	rect->Height(),
	WA_Title,	m_sztitle,
	WA_MinWidth,	wr.minWidth,
	WA_MinHeight,	wr.minHeight,
	WA_MaxWidth,	wr.maxWidth,
	WA_MaxHeight,	wr.maxHeight,
	WA_IDCMP,	WindowIDCMP(),
	WA_Flags,	WindowFlags(),
	TAG_END)) {

    // Fill the textattr structure
    ::AskFont(m_pWindow->RPort,&m_textattr);

	m_papp->addWindow(this);

    // Call OnCreate Method
    OnCreate();

    // Create was successful
    return TRUE;
  }
  return FALSE;
}

BOOL AFWindow::Create(AFScreen* screen, AFRect* rect, char *szTitle)
{
  struct WindowRange wr;

  // Remember the Application for later
  m_papp = screen->m_papp;
  m_pscreen = screen;

  // Create a string for the Window Title
  m_sztitle = new char[strlen(szTitle)+1];
  if(m_sztitle) strcpy(m_sztitle,szTitle);

  // Fill in the window range structure;
  SetWindowRange(&wr);

  // Open the Window the intuition way
  if(m_pWindow = OpenWindowTags((struct NewWindow*)NULL,
	WA_Left,	rect->TopLeft()->m_x,
	WA_Top,		rect->TopLeft()->m_y,
	WA_Width,	rect->Width(),
	WA_Height,	rect->Height(),
	WA_Title,	m_sztitle,
	WA_MinWidth,	wr.minWidth,
	WA_MinHeight,	wr.minHeight,
	WA_MaxWidth,	wr.maxWidth,
	WA_MaxHeight,	wr.maxHeight,
	WA_IDCMP,	WindowIDCMP(),
	WA_Flags,	WindowFlags(),
	WA_PubScreen,	screen->m_pScreen,
	TAG_END)) {

    // Fill the textattr structure
    ::AskFont(m_pWindow->RPort,&m_textattr);

	m_papp->addWindow(this);

    // Call OnCreate Method
    OnCreate();

    // Create was successful
    return TRUE;
  }
  return FALSE;
}

///////////////////////////////////////////////////////////
// GetMsg
//		Gets an IntuiMessage from the window handle and
//	returns it.  This is generally only called by AFAmigaApp
//
LPIntuiMessage
AFWindow::GetMsg()
{
	if(m_pWindow)
		return (LPIntuiMessage)::GetMsg(m_pWindow->UserPort);
	return NULL;
}

LPAppMessage
AFWindow::GetAppMsg(LPMsgPort mport)
{
    if(m_pWindow)
        return (LPAppMessage)::GetMsg(mport);
    return NULL;
}

void
AFWindow::ReplyMsg(LPIntuiMessage imess)
{
	if(m_pWindow)
		::ReplyMsg((LPMessage)imess);
}

void AFWindow::DestroyWindow()
{
  LPGadget gad;
  AFPtrDlistIterator iter(m_gadgets);

  if(m_pWindow) {

    // Destroy any cgadget objects that are attached
	// CONVERT THIS TO A PTRDLIST with ITERATOR
    //gad = m_pWindow->FirstGadget;
    //while(gad) {
    //  if(gad->UserData)
    //  ((AFGadget*)gad->UserData)->DestroyObject();
    //  gad=gad->NextGadget;
    //}

	// Destroy any afgadgets still attached to the afwindow
	iter.reset();
	while(++iter)
		iter.key()->DestroyObject();

	m_papp->removeWindow(this);

    CloseWindow(m_pWindow),m_pWindow=NULL;
  }
  if(m_sztitle) delete m_sztitle;
}

void
AFWindow::DestroyObject()
{
}

void AFWindow::SetWindowRange(LPWindowRange wrange)
{
  wrange->minWidth=50;
  wrange->minHeight=50;
  wrange->maxWidth=~0;
  wrange->maxHeight=~0;
}

BOOL AFWindow::ValidPoint(AFPoint* point)
{
  // Check X value
  if( (point->m_x <= m_pWindow->BorderLeft) || (point->m_x >= (m_pWindow->Width-m_pWindow->BorderRight) ) )
    return FALSE;

  // Check Y value
  if( (point->m_y <= m_pWindow->BorderTop) || (point->m_y >= (m_pWindow->Height-m_pWindow->BorderBottom) ) )
    return FALSE;
  
  return TRUE;
}

void AFWindow::AdjustPoint(AFPoint* point)
{
  // Adjust X value
  if(point->m_x <= m_pWindow->BorderLeft)
    point->m_x = m_pWindow->BorderLeft;
  else if(point->m_x >= (m_pWindow->Width-m_pWindow->BorderRight) )
    point->m_x = m_pWindow->Width - m_pWindow->BorderRight - 1;

  // Adjust Y value
  if(point->m_y <= m_pWindow->BorderTop)
    point->m_y = m_pWindow->BorderTop;
  else if(point->m_y >= (m_pWindow->Height-m_pWindow->BorderBottom) )
    point->m_y = m_pWindow->Height-m_pWindow->BorderBottom-1;
}

void AFWindow::GetDisplayRect(AFRect* rect)
{
  rect->SetRect(m_pWindow->BorderLeft,m_pWindow->BorderTop,
	m_pWindow->Width-m_pWindow->BorderRight-1,m_pWindow->Height-m_pWindow->BorderBottom-1);
}

// Intuition Events

void AFWindow::OnNewSize(LPIntuiMessage imess)
{
	AFPtrDlistIterator iter(m_gadgets);

	iter.reset();
	while(++iter)
		((AFGadget*)iter.key())->OnPaint();
}

void AFWindow::OnGadgetUp(LPIntuiMessage imess)
{
  AFGadget *ptr;
  char string[10];

  ptr = (AFGadget*)GadgetFromID(((LPGadget)imess->IAddress)->GadgetID);
  sprintf(string,"%d",((LPGadget)imess->IAddress)->GadgetID);
  printf("%s\n",string);
  ptr->OnGadgetUp(imess);
}

void AFWindow::OnGadgetDown(LPIntuiMessage imess)
{
  AFGadget *ptr;

  //ptr = (AFGadget*)GadgetFromID(((LPGadget)imess->IAddress)->GadgetID);
  //ptr->OnGadgetDown(imess);
}

void AFWindow::OnCloseWindow(LPIntuiMessage imess)
{
  DestroyWindow();
}

void AFWindow::OnGadgetHelp(LPIntuiMessage imess)
{
	if(m_statusObject) {
		if(imess->IAddress == m_pWindow)
			m_statusObject->SetText(m_statusText.data());
		else if(imess->IAddress) {
			AFGadget* gadget;
			LONG sysgad=((LPGadget)imess->IAddress)->GadgetType & 0xF0;
			//printf("%x\n",sysgad);
			//switch(sysgad) {
			//case GTYP_SIZING:
			//	m_statusObject->SetText(m_sizeStatusText.data()); break;
			//case GTYP_WDRAGGING:
			//	m_statusObject->SetText(m_dragStatusText.data()); break;
			//case GTYP_WUPFRONT:
			//	m_statusObject->SetText(m_depthStatusText.data()); break;
			//case GTYP_WDOWNBACK:
			//	m_statusObject->SetText(m_zoomStatusText.data()); break;
			//case GTYP_CLOSE:
			//	m_statusObject->SetText(m_closeStatusText.data()); break;
			//default:
			if (sysgad) 
				m_statusObject->SetText("");
			else
				if(((LPGadget)imess->IAddress)->UserData) {
					gadget = (AFGadget*)((LPGadget)imess->IAddress)->UserData;
					m_statusObject->SetText(gadget->m_statusText.data());
				} else
					m_statusObject->SetText("");
			//	break;
			//}
		} else
			m_statusObject->SetText("");
	}
}

// Intuition Functions

void AFWindow::SetWindowTitles(UBYTE* lpszWindowTitle, UBYTE* lpszScreenTitle)
{
  ::SetWindowTitles(m_pWindow,lpszWindowTitle,lpszScreenTitle);
}

void AFWindow::SizeWindow(WORD deltax, WORD deltay)
{
  ::SizeWindow(m_pWindow, deltax, deltay);
}

void AFWindow::WindowToBack()
{
  ::WindowToBack(m_pWindow);
}

void AFWindow::WindowToFront()
{
  ::WindowToFront(m_pWindow);
}

void AFWindow::ZipWindow()
{
  ::ZipWindow(m_pWindow);
}

void AFWindow::RefreshGadgets()
{
	AFPtrDlistIterator iter(m_gadgets);

	::RefreshGadgets(m_pWindow->FirstGadget,m_pWindow, (struct Requester*)NULL);

	iter.reset();
	while(++iter)
		((AFGadget*)iter.key())->OnPaint();
}

void
AFWindow::Clear(UBYTE pen)
{
  AFRastPort rp(this);
  AFRect rect;

  rp.SetAPen(pen);
  GetDisplayRect(&rect);
  rp.RectFill(&rect);
}

void
AFWindow::ExecuteMsg(LPIntuiMessage imess)
{
	switch(imess->Class) {
	case IDCMP_SIZEVERIFY:
		OnSizeVerify(imess); break;
	case IDCMP_NEWSIZE:
		OnNewSize(imess); break;
	case IDCMP_REFRESHWINDOW:
		OnRefreshWindow(imess); break;
	case IDCMP_MOUSEBUTTONS:
		OnMouseButtons(imess); break;
	case IDCMP_MOUSEMOVE:
		OnMouseMove(imess); break;
	case IDCMP_GADGETDOWN:
		OnGadgetDown(imess); break;
	case IDCMP_GADGETUP:
		OnGadgetUp(imess); break;
	case IDCMP_REQSET:
		OnReqSet(imess); break;
	case IDCMP_MENUPICK:
		OnMenuPick(imess); break;
	case IDCMP_CLOSEWINDOW:
		OnCloseWindow(imess); break;
	case IDCMP_RAWKEY:
		OnRawKey(imess); break;
	case IDCMP_REQVERIFY:
		OnReqVerify(imess); break;
	case IDCMP_REQCLEAR:
		OnReqClear(imess); break;
	case IDCMP_MENUVERIFY:
		OnMenuVerify(imess); break;
	case IDCMP_NEWPREFS:
		OnNewPrefs(imess); break;
	case IDCMP_DISKINSERTED:
		OnDiskInserted(imess); break;
	case IDCMP_DISKREMOVED:
		OnDiskRemoved(imess); break;
	case IDCMP_WBENCHMESSAGE:
		OnWBenchMessage(imess); break;
	case IDCMP_ACTIVEWINDOW:
		OnActiveWindow(imess); break;
	case IDCMP_INACTIVEWINDOW:
		OnInActiveWindow(imess); break;
	case IDCMP_DELTAMOVE:
		OnDeltaMove(imess); break;
	case IDCMP_VANILLAKEY:
		OnVanillaKey(imess); break;
	case IDCMP_INTUITICKS:
		OnIntuiTicks(imess); break;
	case IDCMP_IDCMPUPDATE:
		OnIDCMPUpdate(imess); break;
	case IDCMP_MENUHELP:
		OnMenuHelp(imess); break;
	case IDCMP_CHANGEWINDOW:
		OnChangeWindow(imess); break;
	case IDCMP_GADGETHELP:
		OnGadgetHelp(imess); break;
	default:
		OnFutureIDCMP(imess); break;
	}
}

void
AFWindow::ExecuteAppMsg(LPAppMessage amess)
{
    switch(amess->am_Type) {
    case AMTYPE_APPWINDOW:
        OnAppWindow(amess); break;
    case AMTYPE_APPICON:
        OnAppIcon(amess); break;
    case AMTYPE_APPMENUITEM:
        OnAppMenu(amess); break;
    default:
        OnFutureIDCMP(amess); break;
    }
}

BOOL
AFWindow::isValid()
{
	return(m_pWindow!=NULL);
}

void
AFWindow::SetStatusPanel(AFObject* obj)
{
	m_statusObject = obj;
}

void
AFWindow::HelpControl(ULONG flags)
{
	::HelpControl(m_pWindow,flags);
}

BOOL
AFWindow::AppendGadget(AFObject* gadget)
{
	return m_gadgets.append(gadget);
}

void
AFWindow::RemoveGadget(AFObject* gadget, BOOL deleteobject)
{
	// Not supported yet.
}

AFObject*
AFWindow::GadgetFromID(ULONG id)
{
	AFPtrDlistIterator iter(m_gadgets);
	AFGadget *gad;

	iter.reset();
	while(++iter) {
		if( ((AFGadget*)iter.key())->GadgetID()==id)
			return iter.key();
	}
}
