
/*
 * [!BGN - MACHINE GENERATED - DO NOT EDIT THIS HEADER]
 *
 * Program   : FloppyFlux (Floppy disk backup program)
 * Version   : 1.2
 * File      : Work:Source/!WIP/FloppyFlux/FF_winprogress.c
 * Author    : Andrew Bell
 * Copyright : Copyright © 1999 Andrew Bell
 * Created   : Wednesday 05-May-99 22:42:29
 * Modified  : Sunday 27-Jun-99 19:57:22
 * Comment   : Module for handling the progress window
 *
 * (Generated with StampSource 1.1 by Andrew Bell)
 *
 * [!END - MACHINE GENERATED - DO NOT EDIT THIS HEADER]
 *
 */

#define FLOPPYFLUX_WINPROGRESS_C

/* Created: Wed/28/Apr/1999 */

#include <FF_include.h>

/*************************************************
 *
 * Function protos
 *
 */

Prototype struct ProgressHandle *OpenProgressWindow( ULONG TotalUnits, UBYTE *TitleText );
Prototype BOOL UpdateProgress( struct ProgressHandle *PH, ULONG UnitsDoneSoFar );
Prototype void CloseProgressWindow( struct ProgressHandle *PH );
Prototype void ChangeProgressTotal( struct ProgressHandle *PH, ULONG NewTotal );

/*************************************************
 *
 * Data protos
 *
 */

/*************************************************
 *
 * Open the progress window.
 *
 */

struct ProgressHandle *OpenProgressWindow( ULONG TotalUnits, UBYTE *TitleText )
{
  struct ProgressHandle *PH;

  if (PH = MyAllocVec( sizeof(struct ProgressHandle) ))
  {
    PH->PH_TotalUnits = TotalUnits;

    /* Note: We don't really care if the progress window or handle were not
       create correctly. The progress support functions will detect if this
       has happened. */

    PH->PH_Handle = LT_CreateHandleTags( NULL,
                                LAHN_AutoActivate, FALSE,
                                TAG_DONE);

    if (PH->PH_Handle)
    {
      if (!TitleText) TitleText = "Progress of current operation";

      /* Note: The 'Handle' variable is required for my macros */

      struct LayoutHandle *Handle = PH->PH_Handle;

      HGroup, LA_LabelText, TitleText, EndTags
        ObjGauge,  LA_ID, GIDPRO_GUAGE, LA_Chars, 40, EndTags
        ObjButton, LA_LabelText, "Abort", LA_ID, GIDPRO_ABORT, EndTags
      EndGroup

      PH->PH_Window = LT_Build( Handle,
                                  LAWN_Title,       "Progress window...",
                                  LAWN_IDCMP,       IDCMP_CLOSEWINDOW,
                                  LAWN_Parent,      MainWindow,
                                  LAWN_BlockParent, TRUE,
                                  WA_Flags,         ( WFLG_ACTIVATE | WFLG_CLOSEGADGET |
                                                      WFLG_DRAGBAR | WFLG_DEPTHGADGET |
                                                      WFLG_RMBTRAP),
                                  TAG_DONE );

    } /* CreateHandleTags() */
  }
  return PH;
}

/*************************************************
 *
 * Update the progress window.
 *
 */

/* This function returns TRUE of user wants to abort */

BOOL UpdateProgress( struct ProgressHandle *PH, ULONG UnitsDoneSoFar )
{
  BOOL Abort = FALSE;

  if ( PH )
  {
    /* Both the handle and the window must be valid to update the
       progress window */

    if ( PH->PH_Handle && PH->PH_Window )
    {
      LT_SetAttributes( PH->PH_Handle, GIDPRO_GUAGE,
        LAGA_Percent, (UnitsDoneSoFar * 100) / PH->PH_TotalUnits,
        TAG_DONE);

      struct IntuiMessage *Message;

      while ( Message = GT_GetIMsg( PH->PH_Window->UserPort ) )
      {
        ULONG MsgClass           = Message->Class;
        UWORD MsgCode            = Message->Code;
        ULONG MsgQualifier       = Message->Qualifier;
        struct Gadget *MsgGadget = Message->IAddress;
        GT_ReplyIMsg( Message );
        LT_HandleInput( PH->PH_Handle, MsgQualifier, &MsgClass, &MsgCode, &MsgGadget );

        switch( MsgClass )
        {
          case IDCMP_CLOSEWINDOW:
            Abort = TRUE;
            break;

          case IDCMP_GADGETUP:
            switch( MsgGadget->GadgetID )
            {
              case GIDPRO_ABORT:
                Abort = TRUE;
                break;
            }
            break;
        }
      }
    }
  }
  return Abort;
}

/*************************************************
 *
 * Close the progress window.
 *
 */

void CloseProgressWindow( struct ProgressHandle *PH )
{
  if (PH)
  {
    LT_DeleteHandle(PH->PH_Handle);
    MyFreeVec(PH);
  }
}

/*************************************************
 *
 * Change the progress window's total.
 *
 */

void ChangeProgressTotal( struct ProgressHandle *PH, ULONG NewTotal )
{
  if (PH)
  {
    PH->PH_TotalUnits = NewTotal;

      LT_SetAttributes( PH->PH_Handle, GIDPRO_GUAGE,
        LAGA_Percent, 0,
        TAG_DONE);
  }
}


