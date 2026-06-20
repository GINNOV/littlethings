//////////////////////////////////////////////////////////////////////////////
// Led.cpp
//
// Deryk Robosson
// April 25, 1996
//
// 5.23.96 DBR
// SetDigits(int pair, int number)
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// INCLUDES
#include "aframe:include/Led.hpp"

//////////////////////////////////////////////////////////////////////////////
//

// Open led.image if it's not already open =)
AFLed::AFLed()
{
    int i;

    m_Global.Added=FALSE;
    m_Global.Image=NULL;
    m_Global.Colon=TRUE;
    m_Global.Negative=FALSE;
    m_Global.Signed=TRUE;
    m_Global.FGPen=1;
    m_Global.BGPen=0;
    m_Global.NumPairs=1;
    m_Global.Window=NULL;
    m_Global.Image=NULL;
    LedLibrary=NULL;

    for(i=0;i<m_Global.NumPairs;i++)
        m_Global.DigitPairs[i]=0;

    if(LedLibrary == NULL)
        if(!(LedLibrary=(struct ClassLibrary*)OpenLibrary((UBYTE*)"images/led.image",(ULONG)37)))
            if(!(LedLibrary=(struct ClassLibrary*)OpenLibrary((UBYTE*)":classes/images/led.image",(ULONG)37)))
                if(!(LedLibrary=(struct ClassLibrary*)OpenLibrary((UBYTE*)"classes/images/led.image",(ULONG)37)))
                    printf("Failed to open led.image\n");
}

AFLed::~AFLed()
{   // Call DestroyObject if it hasn't already
    if(m_Global.Image != NULL)
        DestroyObject();
}

// Remove object from window if it has been added
// and dispose of it
void AFLed::DestroyObject()
{
    RemoveObject();

    if(LedLibrary) {
        CloseLibrary((struct Library*)LedLibrary);
        LedLibrary=NULL;
    }
}

// Add object to a window, with size and position of rect
BOOL AFLed::Create(AFWindow *window, AFRect *rect)
{
    if(m_Global.Added)
        RemoveObject();

    if(m_Global.Image=(struct Image*)NewObject((struct IClass*)NULL, (UBYTE*)"led.image",
                        IA_FGPEN, m_Global.FGPen,
                        IA_BGPen, m_Global.BGPen,
                        IA_Width, rect->Width(),
                        IA_Height, rect->Height(),
                        LED_Pairs, m_Global.NumPairs,
                        LED_Values, m_Global.DigitPairs,
                        LED_Colon, m_Global.Colon,
                        LED_Negative, m_Global.Negative,
                        LED_Signed, m_Global.Signed,
                        ICA_TARGET, ICTARGET_IDCMP,
                        TAG_DONE)) {
        AddGadget(window->m_pWindow, (struct Gadget*)m_Global.Image, -1);

        DrawImage(window->m_pWindow->RPort, m_Global.Image, rect->TopLeft()->m_x, rect->TopLeft()->m_y);

        m_Global.Window=window;
        m_Global.Added=TRUE;
        m_Global.rect.SetRect(rect->TopLeft(),rect->BottomRight());
        return TRUE;
    } else return FALSE;
}

// Remove object from the window to which it was added
void AFLed::RemoveObject()
{
    if(m_Global.Image !=NULL) {
        DisposeObject((Object*)m_Global.Image);
        m_Global.Image=NULL;
    }
}

void AFLed::RefreshImage()
{
    DrawImage(m_Global.Window->m_pWindow->RPort, m_Global.Image, m_Global.rect.TopLeft()->m_x, m_Global.rect.TopLeft()->m_y);
}

void AFLed::SetDigits(int pair, int number)
{
    m_Global.DigitPairs[pair]=number;
    Create(m_Global.Window, &m_Global.rect);
}
