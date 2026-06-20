/*/////////////////////////////////////////////////////////////////////////////
// amigaapp.hpp
//
// Amiga Frameworks Class
//
// Initial Creation"
// 		Jeffry A Worth
// 		November 10, 1995
//
// Modification List: (Most recent first)
// ---------------------------------------------------------------------------
// 	January 28, 1996 - Jeffry A Worth
// 		Converted Window and Port lists to use the PtrDlistIterator class
//
//////////////////////////////////////////////////////////////////////////////*/

#ifndef __AMIGAAPP_HPP__
#define __AMIGAAPP_HPP__

//////////////////////////////////////////////////////////////////////////////
// INCLUDES
#include <proto/intuition.h>
#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/dos.h>
#include <proto/reqtools.h>

#include <intuition/intuition.h>
#include <libraries/reqtools.h>
#include <exec/types.h>
#include <stdio.h>

#include "aframe:include/iterator.hpp"

//////////////////////////////////////////////////////////////////////////////
// APPLICATION LIBRARIES GLOBALS
extern struct IntuitionBase *IntuitionBase;
extern struct ReqToolsBase *ReqToolsBase;
extern struct Library *BattClockBase;
extern struct Library *DataTypesBase;

//////////////////////////////////////////////////////////////////////////////
// Amiga Foundation Class Application

class AFAmigaApp
{
public:
        AFAmigaApp();                           // Default Constructor
        ~AFAmigaApp();                          // Default Destructor

        // Methods
        virtual BOOL OpenLibraries();           // Open System Libraries
        virtual void CloseLibraries();  	    // Close System Libraries
        virtual int InitApp();                  // Init Applications routines
        virtual int RunApp();                   // Waits for events and reacts to them
		// Add/Remove
        void addWindow(AFObject* pwindow);		// Adds a window to the window list
        void removeWindow(AFObject* pwindow);	// Removes a window from window list

        struct MsgPort *appmsgport;

private:

        // GLOBAL SigBits for all Window and Ports
        LONG m_SigBits;

        // Window Object List
        AFPtrDlist m_windows;
            //AFNode *m_pwindows;           // Node List of windows

        // Port Object List
        AFPtrDlist m_ports;
            //AFNode *m_pports;             // Node List of ports
};

//////////////////////////////////////////////////////////////////////////////
#endif // __AMIGAAPP_HPP__
