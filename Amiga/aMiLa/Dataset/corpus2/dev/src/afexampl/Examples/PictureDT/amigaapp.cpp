//////////////////////////////////////////////////////////////////////////////
// amigaapp.cpp
//
// Jeffry A Worth
// Nov 1, 1995
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// INCLUDES
#include "aframe:include/amigaapp.hpp"
#include "aframe:include/window.hpp"


//////////////////////////////////////////////////////////////////////////////
// GLOBAL VARIABLES
struct IntuitionBase *IntuitionBase;
struct GfxBase *GfxBase;
struct ReqToolsBase *ReqToolsBase;
struct Library *LayersBase=NULL;

//////////////////////////////////////////////////////////////////////////////
//

AFAmigaApp::AFAmigaApp()
{
  m_SigBits=NULL;
  appmsgport=NULL;
  ReqToolsBase=NULL;
  DataTypesBase=NULL;

  if(!InitApp())
    Exit(0);
}

AFAmigaApp::~AFAmigaApp()
{
  CloseLibraries();
}

BOOL AFAmigaApp::OpenLibraries()
{
  if(!(IntuitionBase=(struct IntuitionBase*)OpenLibrary((unsigned char*)"intuition.library",(ULONG)39l)))
    return FALSE;
  if(!(GfxBase=(struct GfxBase*)OpenLibrary((unsigned char*)"graphics.library",(ULONG)39l)))
    return FALSE;
  if(!(LayersBase=OpenLibrary((UBYTE*)"layers.library",39l)))
	return FALSE;
  if(!(appmsgport=CreateMsgPort()))
    return FALSE;
  return TRUE;
}

void AFAmigaApp::CloseLibraries()
{
  if(GfxBase) CloseLibrary((struct Library*)GfxBase),GfxBase=NULL;
  if(IntuitionBase) CloseLibrary((struct Library*)IntuitionBase),IntuitionBase=NULL;
  if(ReqToolsBase) CloseLibrary((struct Library*)ReqToolsBase),ReqToolsBase=NULL;
  if(DataTypesBase) CloseLibrary((struct Library*)DataTypesBase),DataTypesBase=NULL;
  if(LayersBase) CloseLibrary(LayersBase),LayersBase=NULL;
  if(appmsgport) DeleteMsgPort(appmsgport),appmsgport=NULL;
}

int AFAmigaApp::InitApp()
{
  return(OpenLibraries());
}

int
AFAmigaApp::RunApp()
{
	AFPtrDlistIterator m_windowiter(m_windows);
	AFPtrDlistIterator m_portiter(m_ports);
	AFWindow* pwindow;
	LPIntuiMessage imess;
    LPAppMessage amess;
	BOOL loop;

	while ( (!m_windows.isEmpty()) || (!m_ports.isEmpty()) ) {
    
	    // Wait for an event!
	    Wait(m_SigBits | 1 << appmsgport->mp_SigBit);

	    // Loop to look for message that was found
	    loop=TRUE;
	    while(loop) {
			loop=FALSE;
			m_windowiter.reset();
	
			//prevnode = NULL;
			while(++m_windowiter) {
				pwindow=(AFWindow*)m_windowiter.key();
		
				if(pwindow->isValid()) {

					if(imess=pwindow->GetMsg()) {
						loop=TRUE;
						pwindow->ExecuteMsg(imess);

						// Reply Message ONLY if Window has not been Destoryed.
						if(pwindow->isValid())
							ReplyMsg((LPMessage)imess);
					}
					if(amess=pwindow->GetAppMsg(appmsgport)) {
					    loop=TRUE;
					    pwindow->ExecuteAppMsg(amess);

                        // Reply Message ONLY if Window has not been Destroyed.
                        if(pwindow->isValid())
                            ReplyMsg((LPMessage)amess);
                    }
				}
				if(!pwindow->isValid()) {
					m_windowiter.removeKey();
				}
			}
		}
	}
	return(TRUE);
}

void
AFAmigaApp::addWindow(AFObject* pwindow)
{
	// Add windows's sigbit
	m_SigBits |= 1<<(((AFWindow*)pwindow)->m_pWindow->UserPort->mp_SigBit);
	
	// Add window to window list
	m_windows.append(pwindow);
}

void
AFAmigaApp::removeWindow(AFObject* pwindow)
{
	// Remove window's SigBits
	m_SigBits &= ~(1<<(((AFWindow*)pwindow)->m_pWindow->UserPort->mp_SigBit));

	// Remove the window from the window list
	// m_windows.removeNode(pwindow->m_node);
}
