
/*
 * [!BGN - MACHINE GENERATED - DO NOT EDIT THIS HEADER]
 *
 * Program   : FloppyFlux (Floppy disk backup program)
 * Version   : 1.2
 * File      : Work:Source/!WIP/FloppyFlux/FF_wingetstr.c
 * Author    : Andrew Bell
 * Copyright : Copyright © 1999 Andrew Bell
 * Created   : Monday 03-May-99 00:00:00
 * Modified  : Sunday 27-Jun-99 19:57:22
 * Comment   : Simple procedure for obtaining strings.
 *
 * (Generated with StampSource 1.1 by Andrew Bell)
 *
 * [!END - MACHINE GENERATED - DO NOT EDIT THIS HEADER]
 *
 */

/* Created: Mon/3/May/1999 */

/* NOTE: This module is currently not pure (ie: it's not thread-safe), so
         you cannot have multiple instances of this code running. */

#include <FF_include.h>

/*************************************************
 *
 * Function protos.
 *
 */

Prototype UBYTE *GetString( UBYTE *StartStr );
Prototype BOOL OpenGetStrWindow( UBYTE *StartStr );
Prototype void CloseGetStrWindow( void );
Prototype UBYTE *IDCMPGetStrWindow( void );

Prototype struct LayoutHandle *GetStrWindowHandle;
Prototype struct Window *GetStrWindow;

/*************************************************
 *
 * Variables and data. 
 *
 */

struct LayoutHandle *GetStrWindowHandle = NULL;
struct Window *GetStrWindow = NULL;

/*************************************************
 *
 * Call the GetStr window.
 *
 */

UBYTE StringBuf[1024];

UBYTE *GetString( UBYTE *StartStr )
{
  UBYTE *String = NULL;

  if (OpenGetStrWindow( StartStr ))
  {
    String = IDCMPGetStrWindow();
  }
  CloseGetStrWindow();

  return String;
}

/*************************************************
 *
 * Open the GetStr window.
 *
 */

BOOL OpenGetStrWindow( UBYTE *StartStr )
{
  BOOL Result = FALSE;

  struct LayoutHandle *Handle = NULL;

  GetStrWindowHandle = Handle = LT_CreateHandleTags( NULL,
                                LAHN_AutoActivate, FALSE,
                                TAG_DONE);

  if (Handle)
  {
    /*
     * This is the GUI tree the GetStr window, uses GTLayout.library
     */

    HGroup, LA_LabelText, "Please provide a string...", EndTags
      ObjString, LA_Chars, 40, LA_ID, GIDGS_STRING, LAST_Activate, TRUE, GTST_String, StartStr, EndTags
      ObjButton, LA_LabelText, "OK", LA_Chars, 6, LA_ID, GIDGS_OK, EndTags
      ObjButton, LA_LabelText, "Cancel", LA_Chars, 6, LA_ID, GIDGS_CANCEL, EndTags
    EndGroup

    GetStrWindow = LT_Build( Handle,
                            LAWN_Title,  "Enter a string...",
                            LAWN_IDCMP,  IDCMP_CLOSEWINDOW,
                            LAWN_Zoom,   TRUE,
                            LAWN_Parent, MainWindow,
                            WA_Flags,    (WFLG_ACTIVATE | WFLG_CLOSEGADGET |
                                          WFLG_DRAGBAR | WFLG_DEPTHGADGET |
                                          WFLG_RMBTRAP),
                            TAG_DONE );

    if (GetStrWindow)
    {
      Result = TRUE;
    }
    else
    {
      FFError("Unable to layout window", NULL);
      CloseGetStrWindow();
    }
  } /* CreateHandleTags() */
  else
  {
    FFError("Unable to create window handle", NULL);
  }
  return Result;
}

/*************************************************
 *
 * Close the GetStr window. 
 *
 */

void CloseGetStrWindow( void )
{
  if (GetStrWindowHandle) LT_DeleteHandle(GetStrWindowHandle);
  GetStrWindowHandle = NULL;
  GetStrWindow = NULL;
}

/*************************************************
 *
 * Handle the GetStr window's IDCMP events.
 *
 */

UBYTE *IDCMPGetStrWindow( void )
{
  UBYTE *FinalString = NULL;

  struct IntuiMessage *Message;
  ULONG                MsgQualifier, MsgClass;
  UWORD                MsgCode;
  struct Gadget       *MsgGadget;
  BOOL                 Done = FALSE;

  LT_Activate(GetStrWindowHandle, GIDGS_STRING);

  do
  {
    ULONG Sig_IDCMP = ( 1 << GetStrWindow->UserPort->mp_SigBit );
    ULONG SigEvents = Wait( Sig_IDCMP | SIGBREAKF_CTRL_C );

    if ( SigEvents & Sig_IDCMP )
    {
      while ( Message = GT_GetIMsg( GetStrWindow->UserPort ) )
      {
        MsgClass     = Message->Class;
        MsgCode      = Message->Code;
        MsgQualifier = Message->Qualifier;
        MsgGadget    = Message->IAddress;
        GT_ReplyIMsg( Message );
        LT_HandleInput( GetStrWindowHandle, MsgQualifier, &MsgClass, &MsgCode, &MsgGadget );

        switch( MsgClass )
        {
          case IDCMP_CLOSEWINDOW:
            Done = TRUE;
            FinalString = NULL;
            break;

          case IDCMP_GADGETUP:
            switch( MsgGadget->GadgetID )
            {
              case GIDGS_OK:
                FinalString = (UBYTE *) LT_GetAttributes(GetStrWindowHandle, GIDGS_STRING, TAG_DONE);

                if (FinalString)
                {
                  strncpy((UBYTE *) &StringBuf, FinalString, 1024L);
                  FinalString = (UBYTE *) &StringBuf;
                  Done = TRUE;
                }
                break;

              case GIDGS_CANCEL:
                Done = TRUE;
                FinalString = NULL;
                break;

              case GIDGS_STRING:
                break;

            }
            break;
        }
      }
    }
    else if ( SigEvents & SIGBREAKF_CTRL_C )
    {
      Done = TRUE;  /* Catching a "Ctrl + C" comes in handy sometimes :) */
    }
  }
  while( !Done );

  return FinalString;
}

/*************************************************
 *
 * 
 *
 */

