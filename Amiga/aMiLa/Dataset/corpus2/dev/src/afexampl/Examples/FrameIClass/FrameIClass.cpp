//////////////////////////////////////////////////////////////////////////////
// FrameIClass.cpp
//
// Deryk Robosson
// June 2, 1996
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// INCLUDES
#include "aframe:include/FrameIClass.hpp"

//////////////////////////////////////////////////////////////////////////////
//

AFFrameIClass::AFFrameIClass()
{
    m_Frame=NULL;
}

AFFrameIClass::~AFFrameIClass()
{   // Call DestroyObject if it hasn't already
    if(m_Frame != NULL)
        DestroyObject();
}

// Remove object from window if it has been added
// and dispose of it
void AFFrameIClass::DestroyObject()
{
    RemoveObject();
}

// Add object to a window, with size and position of rect
BOOL AFFrameIClass::Create(AFWindow *window, AFRect *rect, int recessed, int frametype)
{
    if(m_Added)
        RemoveObject();

    if(m_Frame=(struct Image*)NewObject((struct IClass*)NULL, (UBYTE*)"frameiclass",
                        IA_FrameType, frametype,
                        IA_Recessed, recessed,
                        IA_Width, rect->Width(),
                        IA_Height, rect->Height(),
                        TAG_DONE)) {
        DrawImage(window->m_pWindow->RPort, m_Frame, rect->TopLeft()->m_x, rect->TopLeft()->m_y);

        m_pwindow=window;
        m_Added=TRUE;
        m_Rect.SetRect(rect->TopLeft(),rect->BottomRight());
        return TRUE;
    } else return FALSE;
}

void AFFrameIClass::RefreshImage()
{
    BeginRefresh(m_pwindow->m_pWindow);
    DrawImage(m_pwindow->m_pWindow->RPort, m_Frame, m_Rect.TopLeft()->m_x, m_Rect.TopLeft()->m_y);
    EndRefresh(m_pwindow->m_pWindow,TRUE);
}

// Remove object from the window to which it was added
void AFFrameIClass::RemoveObject()
{
    if(m_Frame !=NULL) {
        DisposeObject((Object*)m_Frame);
        m_Frame=NULL;
    }
}
