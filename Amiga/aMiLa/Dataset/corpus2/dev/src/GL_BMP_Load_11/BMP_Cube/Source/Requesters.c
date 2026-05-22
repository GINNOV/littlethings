/* Routines for requester handling */

#ifndef REQUESTERS_H
#include "Requesters.h"
#endif

static void AskQuit( void )
{
   if (IntuitionBase = OpenLibrary("intuition.library",37))
     {
        answer = EasyRequest(NULL, &QuitWindow, NULL, "(Variable)");
        CloseLibrary(IntuitionBase);
      switch (answer)
        {
        case 1:
            exit(0);
            break;
        }
     }
}

static void ShowAbout( void )
{
    if (IntuitionBase = OpenLibrary("intuition.library",37))
      {
         answer = EasyRequest(NULL, &AboutWindow, NULL, "(Variable)");
         CloseLibrary(IntuitionBase);
      }
}

static void ShowError( void )
{
    if (IntuitionBase = OpenLibrary("intuition.library",37))
      {
         answer = EasyRequest(NULL, &ReqWindow, NULL, "(Variable)");
         CloseLibrary(IntuitionBase);
      }
}
