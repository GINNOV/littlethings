/*
**     $VER: AslManagement.c V0.01 (17-06-95)
**
**     Author:  Gerben Venekamp
**     Updates: 19-06-95  Version 0.01     Intial module
**
**  AslManagement.c contains all the functions to manage Asl requesters.
**
*/

#include <exec/types.h>
#include <proto/asl.h>

#include "IFFConverter.h"


// Defining variables
struct FileRequester *Asl_FRLoad = NULL;
struct FileRequester *Asl_FRSave = NULL;

// Defining prototypes
void AllocAsl_Requests(void);
void FreeAsl_Requests(void);


/*
**  AllocAsl_Requests()
**
**     Allocates all necessary Asl_Requests. One for Loading and one for
**     Saving.
**
**  pre:  None.
**  post: None.
*/
void AllocAsl_Requests()
{
   if(!( Asl_FRLoad = AllocAslRequestTags(ASL_FileRequest,
                                          ASLFR_Window, PanelWindow,
                                          ASLFR_SleepWindow, TRUE,
                                          ASLFR_TitleText, "Load Picture...",
                                          ASLFR_PositiveText, "Load",
                                          ASLFR_InitialLeftEdge, 150, 
                                          ASLFR_InitialTopEdge, 20,
                                          ASLFR_InitialWidth, PubScreenWidth-300,
                                          ASLFR_InitialHeight, PubScreenHeight-40,
                                          ASLFR_RejectIcons, TRUE,
                                          ASLFR_InitialDrawer, GraphicsDrawer,
                                          TAG_DONE) ))
      ErrorHandler( IFFerror_AllocErr, "Asl Load requester struct" );

   if(!( Asl_FRSave = AllocAslRequestTags(ASL_FileRequest,
                                          ASLFR_Window, PanelWindow,
                                          ASLFR_SleepWindow, TRUE,
                                          ASLFR_TitleText, "Save Picture...",
                                          ASLFR_PositiveText, "Save",
                                          ASLFR_InitialLeftEdge, 150,
                                          ASLFR_InitialTopEdge, 20,
                                          ASLFR_InitialWidth, PubScreenWidth-300,
                                          ASLFR_InitialHeight, PubScreenHeight-40,
                                          ASLFR_RejectIcons, TRUE,
                                          ASLFR_DoSaveMode, TRUE,
                                          TAG_DONE) ))
      ErrorHandler( IFFerror_AllocErr, "Asl Save requester struct" );

}


/*
**  FreeAsl_Requests()
**
**     Frees all allocated Asl_Requests.
**
**  pre:  None.
**  post: None.
*/
void FreeAsl_Requests()
{
   if(Asl_FRLoad) FreeAslRequest(Asl_FRLoad);
   if(Asl_FRSave) FreeAslRequest(Asl_FRSave);
}
