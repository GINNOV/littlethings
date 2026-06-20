//////////////////////////////////////////////////////////////////////////////
// gadget.cpp
//
// Jeffry A Worth
// Nov 9, 1995
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// INCLUDES 
#include "aframe:include/rastport.hpp"
#include "aframe:include/gadget.hpp"

//////////////////////////////////////////////////////////////////////////////
//

AFGadget::AFGadget()
	:m_newregion(NULL),
	m_oldregion(NULL),
	m_pgadget(NULL),
	m_flags(NULL)
{
}

AFGadget::~AFGadget()
{
	// Call DestroyObject if not already called
	if(m_pgadget)
		DestroyObject();
}

void AFGadget::DestroyObject()
{
  if(m_pgadget && (!(m_flags & AFGADGET_OWNERSTRUCT)) ) {
    RemoveGadget();
    delete m_pgadget;
    m_pgadget = NULL;
    m_flags = NULL;
  }
}

void AFGadget::Create(AFWindow* pwindow, AFRect *rect, ULONG id)
{
	m_pwindow = pwindow;
	m_pgadget = new struct ExtGadget;
	m_pgadget->NextGadget = NULL;
	m_pgadget->LeftEdge = m_pgadget->BoundsLeftEdge = rect->TopLeft()->m_x;
	m_pgadget->TopEdge = m_pgadget->BoundsTopEdge = rect->TopLeft()->m_y;
	m_pgadget->Width = m_pgadget->BoundsWidth = rect->Width();
	m_pgadget->Height = m_pgadget->BoundsHeight = rect->Height();
	m_pgadget->GadgetID = id;
	FillGadgetStruct(m_pgadget);
	m_pgadget->Flags|=GFLG_EXTENDED;
	m_pgadget->UserData = this;

	// Gadget Tracking - Not implemented yet!
	//m_pwindow->m_pgadgets = new AFNode(m_pgadget,m_pwindow->m_pgadgets);

	AddGadget();
}

void AFGadget::Create(AFWindow* pwindow, LPExtGadget psgadget)
{
	// Set up OWNERSTRUCT Gadget
	m_pgadget = psgadget;
	m_pwindow = pwindow;
	m_flags |= AFGADGET_OWNERSTRUCT;
	psgadget->UserData = this;

	// Gadget Tracking - Not implemented yet!
	// m_pwindow->m_pgadgets = new CNode(m_pgadget,m_pwindow->m_pgadgets);

	AddGadget();
}

void AFGadget::FillGadgetStruct(LPExtGadget psgadget)
{
  psgadget->Flags = GFLG_GADGHCOMP|GFLG_EXTENDED;
  psgadget->Activation = GACT_RELVERIFY | GACT_IMMEDIATE | GACT_FOLLOWMOUSE;
  psgadget->GadgetType = GTYP_BOOLGADGET;
  psgadget->GadgetRender = NULL;
  psgadget->SelectRender = NULL;
  psgadget->GadgetText = NULL;
  psgadget->MutualExclude = NULL;
  psgadget->SpecialInfo = NULL;
  psgadget->MoreFlags = GMORE_GADGETHELP|GMORE_BOUNDS;
  return;
}

void AFGadget::AddGadget()
{
  ::AddGadget(m_pwindow->m_pWindow,(LPGadget)m_pgadget,-1);
}

void AFGadget::RemoveGadget()
{
  ::RemoveGadget(m_pwindow->m_pWindow,(LPGadget)m_pgadget);
}

BOOL AFGadget::BeginPaint()
{
	Rectangle rect;
	AFRect drect;

	if(m_newregion)
		return FALSE;

	GetDisplayRect(&drect);
	rect.MinX = drect.TopLeft()->m_x;
	rect.MinY = drect.TopLeft()->m_y;
	rect.MaxX = drect.BottomRight()->m_x;
	rect.MaxY = drect.BottomRight()->m_y;

	if(m_newregion=NewRegion()) {
		if(!OrRectRegion(m_newregion,&rect)) {
			DisposeRegion(m_newregion);
			m_newregion=NULL;
			return FALSE;
		}
		m_oldregion=InstallClipRegion(m_pwindow->m_pWindow->WLayer,m_newregion);
		return TRUE;
	}
	return FALSE;
}

void AFGadget::EndPaint()
{
	if(m_newregion) {
		InstallClipRegion(m_pwindow->m_pWindow->WLayer,m_oldregion);
		DisposeRegion(m_newregion);
		m_newregion=NULL;
	}
}

void AFGadget::GetDisplayRect(AFRect* rect)
{
	rect->SetRect(m_pgadget->LeftEdge,m_pgadget->TopEdge,
			m_pgadget->LeftEdge+m_pgadget->Width-1,m_pgadget->TopEdge+m_pgadget->Height-1);
}

void
AFGadget::EraseGadget()
{
	AFRastPort rp(m_pwindow);
	AFRect rect;

	GetDisplayRect(&rect);
	rp.SetAPen(0);
	rp.RectFill(&rect);
}

void
AFGadget::DrawGadget()
{
	::RefreshGadgets((LPGadget)m_pgadget,m_pwindow->m_pWindow,NULL);
}

ULONG AFGadget::GadgetID()
{
    return m_pgadget->GadgetID;
}
