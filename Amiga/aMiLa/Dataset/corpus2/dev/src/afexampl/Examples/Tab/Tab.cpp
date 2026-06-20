//////////////////////////////////////////////////////////////////////////////
// Tab.cpp
//
// Deryk Robosson
// May 5, 1996
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// INCLUDES
#include "aframe:include/Tab.hpp"

//////////////////////////////////////////////////////////////////////////////
//

AFTab::AFTab()
    :ClassLibrary(NULL)
{
	if(!ClassLibrary) {
		if(!(ClassLibrary=(struct ClassLibrary*)OpenLibrary((UBYTE*)"gadgets/tabs.gadget",37)))
            if(!(ClassLibrary=(struct ClassLibrary*)OpenLibrary((UBYTE*)":classes/gadgets/tabs.gadget",37)))
        		if(!(ClassLibrary=(struct ClassLibrary*)OpenLibrary((UBYTE*)"classes/gadgets/tabs.gadget",37)))
        		    printf("Unable to open tabs.gadget\n");
    }
}

AFTab::~AFTab()
{
    if(ClassLibrary) {
        CloseLibrary((struct Library*)ClassLibrary);
        ClassLibrary=NULL;
    }
}

void AFTab::DestroyObject()
{
    if(m_pgadget) {
        RemoveGList(m_pwindow->m_pWindow, (LPGadget)m_pgadget, 1);
        ::DisposeObject(m_pgadget);
        m_pgadget=NULL;
    }
}

void AFTab::Create(AFWindow *window, AFRect *rect, TabLabel tlabels[] , ULONG id)
{
    m_pwindow=window;

    if(m_pgadget=(LPExtGadget)NewObject(NULL, (UBYTE*)"tabs.gadget",
                    GA_Top, rect->TopLeft()->m_y,
                    GA_Left, rect->TopLeft()->m_x,
                    GA_Height, rect->Height(),
                    GA_Width, rect->Width(),
                    GA_RelVerify, TRUE,
                    GA_Immediate, TRUE,
                    GA_ID, id,
                    TABS_Labels, tlabels,
                    TABS_Current, 0,
                    TAG_DONE)) {
        AddGList(m_pwindow->m_pWindow, (LPGadget)m_pgadget, -1, 1, NULL);
        m_pwindow->AppendGadget(this);
    }
}

void AFTab::OnGadgetUp(LPIntuiMessage imess)
{
    ULONG result;

    result=GetCurrentTab();

    switch(result) {
    default:
        break;
    }
}

ULONG AFTab::GetCurrentTab()
{
    ULONG result;

    if(m_pgadget) {
        if(!(GetAttr(TABS_Current, m_pgadget, &result)))
            return FALSE;
        else return result;
    } else return FALSE;
}
