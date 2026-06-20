//////////////////////////////////////////////////////////////////////////////
// TapeDeck.cpp
//
// Deryk Robosson
// April 29, 1996
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// INCLUDES
#include "aframe:include/TapeDeck.hpp"

//////////////////////////////////////////////////////////////////////////////
//

AFTapeDeck::AFTapeDeck()
    :ClassLibrary(NULL)
{
	if(!ClassLibrary) {
		if(!(ClassLibrary=(struct ClassLibrary*)OpenLibrary((UBYTE*)"gadgets/tapedeck.gadget",37)))
            if(!(ClassLibrary=(struct ClassLibrary*)OpenLibrary((UBYTE*)":classes/gadgets/tapedeck.gadget",37)))
        		if(!(ClassLibrary=(struct ClassLibrary*)OpenLibrary((UBYTE*)"classes/gadgets/tapedeck.gadget",37)))
        		    printf("Unable to open tapedeck.gadget\n");
    }
}

AFTapeDeck::~AFTapeDeck()
{
    if(ClassLibrary) {
        CloseLibrary((struct Library*)ClassLibrary);
        ClassLibrary=NULL;
    }

    DestroyObject();
}

void AFTapeDeck::DestroyObject()
{
    if(m_pgadget) {
        RemoveGList(m_pwindow->m_pWindow, (LPGadget)m_pgadget, 1);
        ::DisposeObject(m_pgadget);
        m_pgadget=NULL;
    }
}

void AFTapeDeck::Create(AFWindow *window, AFRect *rect, ULONG id)
{
    m_pwindow=window;

	if(m_pgadget = (LPExtGadget)NewObject(NULL, (UBYTE*)"tapedeck.gadget",
                    GA_Top,	rect->TopLeft()->m_y,
                    GA_Left, rect->TopLeft()->m_x,
                    GA_Height, rect->Height(),
                    GA_Width, rect->Width(),
                    GA_RelVerify, TRUE,
                    GA_Immediate, TRUE,
                    GA_ID, id,
                    TDECK_Tape, TRUE,
                    TAG_DONE)) {

        AddGList(m_pwindow->m_pWindow, (LPGadget)m_pgadget, -1, 1, NULL);
        m_pwindow->AppendGadget(this);
    }
}

ULONG AFTapeDeck::GetCurrentButton()
{
    ULONG result;

    if(m_pgadget) {
        if(!(GetAttr(TDECK_Mode, m_pgadget, &result)))
            return FALSE;
        else return result;
    } else return FALSE;
}
