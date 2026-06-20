
/*
 * [!BGN - MACHINE GENERATED - DO NOT EDIT THIS HEADER]
 *
 * Program   : FloppyFlux (Floppy disk backup program)
 * Version   : 1.2
 * File      : Work:Source/!WIP/FloppyFlux/FF_winsettings.c
 * Author    : Andrew Bell
 * Copyright : Copyright © 1999 Andrew Bell
 * Created   : Wednesday 05-May-99 22:42:29
 * Modified  : Sunday 27-Jun-99 19:57:22
 * Comment   : Module for handling the settings window
 *
 * (Generated with StampSource 1.1 by Andrew Bell)
 *
 * [!END - MACHINE GENERATED - DO NOT EDIT THIS HEADER]
 *
 */

#define FLOPPYFLUX_WINSETTINGS_C

/* Created: Wed/28/Apr/1999 */

#include <FF_include.h>

/*************************************************
 *
 * Function protos
 *
 */

Prototype void DisplaySettingsWindow( void );
Prototype BOOL OpenSettingsWindow( void );
Prototype void CloseSettingsWindow( void );
Prototype void IDCMPSettingsWindow( void );
Prototype BOOL BuildXPKMethodList( void );
Prototype void FreeXPKMethodList( void );
Prototype struct PackerListNode *GetXPKMethodEntry( ULONG Number );
Prototype void AttachXPKMethodList( void );
Prototype void RemoveXPKMethodList( void );
Prototype void PrintSettingsStatus( UBYTE *String, APTR Fmt );
Prototype ULONG GetXPKMethodListNumber( UBYTE *MethodName );

/*************************************************
 *
 * Data protos
 *
 */

/* Stuff for the settings window */

struct List XPKMethodList;
ULONG AmtOfPackers = NULL;
ULONG AmtOfPackersSkipped = NULL;


/****************************************************************************
 *
 * Settings window routines.
 *
 */

/*************************************************
 *
 * Display and handle the settings window.
 *
 */

void DisplaySettingsWindow( void )
{
  if (OpenSettingsWindow())
  {
    IDCMPSettingsWindow();
  }
  CloseSettingsWindow();
}

/*************************************************
 *
 * Open the settings window. 
 *
 */

struct LayoutHandle *SettingsHandle = NULL;
struct Window *SettingsWindow = NULL;

BOOL OpenSettingsWindow( void )
{
  BOOL Result = FALSE;

  SettingsHandle = LT_CreateHandleTags( NULL,
                              LAHN_AutoActivate, FALSE,
                              TAG_DONE);

  /* Note: We must still init the XPK method list, even if
           XPK is not available. */

  NewList( (struct List *) &XPKMethodList );

  if (SettingsHandle)
  {
    if (XpkBase)
    {
      if (!BuildXPKMethodList())
      {
        FFError("Unable to build XPK method list!", NULL);
      }
    }

    /* Note: The 'Handle' variable is required for my macros */

    struct LayoutHandle *Handle = SettingsHandle;

    VGroup, /* LA_LabelText, "Settings for program", */ EndTags
      VGroup, LA_LabelText, "Settings", EndTags
        VGroup, EndTags
          VGroup, EndTags
            ObjCheckBox, LA_LabelText, "Compress all incoming disk images?",
                         LA_ID, GIDSET_COMPDISKIMGS,
                         LA_LabelPlace, PLACE_Right,
                         GTCB_Checked, FFC.FFC_UseXPK,
                         EndTags
            ObjSeparator, EndTags
          EndGroup
          HGroup, EndTags
            HGroup, EndTags
              ObjListView, LA_Chars,       35,
                           LALV_MinChars,  35,
                           LA_ID,          GIDSET_METHODLIST,
                           LA_LabelText,   "XPK method",
                           LA_LabelPlace,  PLACE_Above,
                           LALV_Lines,     10,
                           LALV_Link,      NIL_LINK,
                           LALV_TextAttr,  ~NULL,
                           LALV_ResizeY,   TRUE,
                           LALV_ResizeX,   TRUE,
                           LALV_MinLines,  10,
                           GTLV_Labels,    &XPKMethodList,
                           GTLV_Selected,  GetXPKMethodListNumber( (UBYTE *) &FFC.FFC_XPKMethod ),
                           LALV_CursorKey, TRUE,
                           LALV_LockSize,  TRUE,
                           EndTags
            EndGroup
            VGroup, LAGR_Spread, TRUE, EndTags
              ObjSlider, LA_ID,              GIDSET_XPKCOMPMODE,
                         LA_LabelText,       "XPK compression mode",
                         LA_LabelPlace,      PLACE_Above,
                         LASL_FullCheck,     FALSE,
                         GTSL_LevelPlace,    PLACETEXT_RIGHT,
                         GTSL_Justification, GTJ_RIGHT,
                         GTSL_Min, 1,        GTSL_Max, 100,
                         PGA_Freedom,        LORIENT_HORIZ,
                         GTSL_Level,         (ULONG) FFC.FFC_XPKMode,
                         EndTags
            EndGroup
          EndGroup
          HGroup, EndTags
            ObjText, LA_ID, GIDSET_XPKINFOBOX, GTTX_Border, TRUE, LA_Chars, 70, EndTags
          EndGroup
        EndGroup
      EndGroup
      HGroup, LAGR_Spread, TRUE, EndTags
        ObjButton, LA_LabelText, "Save", LA_ID, GIDSET_SAVE, EndTags
        ObjButton, LA_LabelText, "Use", LA_ID, GIDSET_USE, EndTags
        ObjButton, LA_LabelText, "Cancel", LA_ID, GIDSET_CANCEL, EndTags
      EndGroup
    EndGroup

    SettingsWindow = LT_Build( Handle,
                                LAWN_Title,       "Settings window",
                                LAWN_IDCMP,       IDCMP_CLOSEWINDOW,
                                LAWN_Parent,      MainWindow,
                                LAWN_BlockParent, TRUE,
                                WA_Flags,         ( WFLG_ACTIVATE | WFLG_CLOSEGADGET |
                                                   WFLG_DRAGBAR | WFLG_DEPTHGADGET |
                                                   WFLG_RMBTRAP),
                                TAG_DONE );

    if (SettingsWindow)
    {
      PrintSettingsStatus("Configure me!", NULL);
      Result = TRUE;
    }

  } /* CreateHandleTags() */

  return Result;
}

/*************************************************
 *
 * Close the settings window. 
 *
 */

void CloseSettingsWindow( void )
{
  if (SettingsHandle) LT_DeleteHandle(SettingsHandle);

  SettingsHandle = NULL;
  SettingsWindow = NULL;

  if (XpkBase)
  {
    FreeXPKMethodList();
  }
}

/*************************************************
 *
 * Handle the settings window's IDCMP events.
 *
 */

void IDCMPSettingsWindow( void )
{
  /* IDCMP event handler for the settings window */

  struct IntuiMessage *Message;
  ULONG                MsgQualifier, MsgClass;
  UWORD                MsgCode;
  struct Gadget       *MsgGadget;
  BOOL                 Done = FALSE;

  struct FFConfig CancelFFC;

  /* Take a copy of the config structure before the user starts
     to configure it. Then, if the user cancels the settings it
     will be copied back. */

  CopyMem(&FFC, &CancelFFC, sizeof(struct FFConfig));

  do
  {
    WaitPort( SettingsWindow->UserPort );

    while( Message = GT_GetIMsg( SettingsWindow->UserPort ) )
    {
      MsgClass     = Message->Class;
      MsgCode      = Message->Code;
      MsgQualifier = Message->Qualifier;
      MsgGadget    = Message->IAddress;

      GT_ReplyIMsg( Message );

      LT_HandleInput( SettingsHandle, MsgQualifier, &MsgClass, &MsgCode, &MsgGadget );

      switch( MsgClass )
      {
        case IDCMP_CLOSEWINDOW:
          Done = TRUE;
          break;

        case IDCMP_GADGETUP:
          switch( MsgGadget->GadgetID )
          {
            case GIDSET_COMPDISKIMGS:
              BOOL State = (BOOL) LT_GetAttributes( SettingsHandle, GIDSET_COMPDISKIMGS, TAG_DONE );
              if (State) /* State == TRUE */
              {
                FFC.FFC_UseXPK = TRUE;

                if (!XpkBase) /* Try to open XPK if not available */
                {
                  InitXPK();

                  PrintSettingsStatus("Please wait getting XPK packer list.", NULL );

                  if (BuildXPKMethodList())
                  {
                    AttachXPKMethodList();
                    PrintSettingsStatus("Finished getting XPK packer list.", NULL );
                  }
                  else PrintSettingsStatus("Unable to get XPK packer list!", NULL );
                }
              }
              else  /* State == FALSE */
              {
                FFC.FFC_UseXPK = FALSE;
              }
              break;

            case GIDSET_METHODLIST:
              ULONG Selected = (ULONG) LT_GetAttributes( SettingsHandle, GIDSET_METHODLIST, TAG_DONE );
              if (Selected != ~NULL)
              {
                struct PackerListNode *PLN = GetXPKMethodEntry( Selected );
                if (PLN)
                {
                  /* update config with user's choice */
                  strncpy((UBYTE *) &FFC.FFC_XPKMethod, (UBYTE *) &PLN->PLN_Method, 6);
                  PrintSettingsStatus( (UBYTE *) &PLN->PLN_Description, NULL );
                }
                else DisplayBeep(NULL);
              }
              else DisplayBeep(NULL);
              break;

            case GIDSET_XPKCOMPMODE:
              FFC.FFC_XPKMode = (UWORD) LT_GetAttributes( SettingsHandle, GIDSET_XPKCOMPMODE, TAG_DONE );
              break;

            case GIDSET_SAVE: /* Save config and exit */
              SaveConfig();
              Done = TRUE;
              break;

            case GIDSET_USE:  /* Exit window and don't save config */
              Done = TRUE;
              break;

            case GIDSET_CANCEL: /* Get back the old config and exit window */
              CopyMem(&CancelFFC, &FFC, sizeof(struct FFConfig));
              Done = TRUE;
              break;

            default:
              break;
          }
          break;
      }
    }
  }
  while( !Done );
}

/*************************************************
 *
 * Filter out useable compression methods from the
 * XPK method pool and build a linked list for the
 * listview gadget.
 *
 */

BOOL BuildXPKMethodList( void )
{
  if (!XpkBase) return FALSE;

  LT_LockWindow( SettingsWindow );

  BOOL Result = FALSE;

  struct XpkPackerInfo *XPKpi = NULL;

  if (XPKpi = (struct XpkPackerInfo *) XpkAllocObject(XPKOBJ_PACKERINFO, NULL))
  {
    ULONG Cnt = NULL;
    struct PackerListNode *ThisNode = NULL;
    AmtOfPackers = XPKpl->xpl_NumPackers;
    AmtOfPackersSkipped = NULL;

    NewList( (struct List *) &XPKMethodList );

    while(Cnt < AmtOfPackers)
    {
      LONG xpkerr = XpkQueryTags( XPK_PackerQuery, XPKpi,
                                  XPK_PackMethod,  &XPKpl->xpl_Packer[Cnt][0],
                                  TAG_DONE);

      if (xpkerr == XPKERR_OK)
      {
        if (!(XPKpi->xpi_Flags & XPKIF_NEEDPASSWD ||
              XPKpi->xpi_Flags & XPKIF_LOSSY))
        {
          /* Note: If an allocation fails we simply skip that method. */

          if ( ThisNode = MyAllocVec( PLN_Size ))
          {
            ThisNode->PLN_Node.ln_Name = (UBYTE *) &ThisNode->PLN_ViewString;
            ThisNode->PLN_NodeNumber = Cnt - AmtOfPackersSkipped;

            strncpy( (UBYTE *) &ThisNode->PLN_Method, (UBYTE *) &XPKpl->xpl_Packer[Cnt][0], 6);
            strncpy( (UBYTE *) &ThisNode->PLN_Name, (UBYTE *) &XPKpi->xpi_Name, 24);
            strncpy( (UBYTE *) &ThisNode->PLN_LongName, (UBYTE *) &XPKpi->xpi_LongName, 32);
            strncpy( (UBYTE *) &ThisNode->PLN_Description, (UBYTE *) &XPKpi->xpi_Description, 80);

            UBYTE *stream[] = {  (UBYTE *) &ThisNode->PLN_Method,  (UBYTE *) &ThisNode->PLN_LongName };
            RawDoFmt("%-4.4s - %.32s", &stream, &putchproc, (UBYTE *) &ThisNode->PLN_ViewString);

            AddTail( &XPKMethodList, (struct Node *) ThisNode );
          }
          else ++AmtOfPackersSkipped;
        }
        else ++AmtOfPackersSkipped;
      }
      ++Cnt;
    }
    XpkFreeObject(XPKOBJ_PACKERINFO, XPKpi);

    Result = TRUE;
  }
  else FreeXPKMethodList();

  LT_UnlockWindow( SettingsWindow );

  return Result;
}

/*************************************************
 *
 * Free the XPK method list.
 *
 */

void FreeXPKMethodList( void )
{
  struct PackerListNode *PLN = NULL, *TmpPLN = NULL;

  for ( PLN = (struct PackerListNode *) XPKMethodList.lh_Head; PLN->PLN_Node.ln_Succ; )
  {
    TmpPLN = (struct PackerListNode *) PLN->PLN_Node.ln_Succ;
    MyFreeVec( PLN );
    PLN = TmpPLN;
  }
  NewList( (struct List *) &XPKMethodList );
}

/*************************************************
 *
 * Get an XPK method entry using an ordinal index
 * number.
 *
 */

struct PackerListNode *GetXPKMethodEntry( ULONG Number )
{
  if (Number == ~NULL) return NULL;

  struct PackerListNode *PLN = NULL;

  for ( PLN = (struct PackerListNode *) XPKMethodList.lh_Head;
        PLN->PLN_Node.ln_Succ;
        PLN = (struct PackerListNode *) PLN->PLN_Node.ln_Succ )
  {
    if (!Number--) return PLN;
  }
  return NULL;
}

/*************************************************
 *
 * Attach the XPK method list to the settings
 * window.
 *
 */

void AttachXPKMethodList( void )
{
  if (!SettingsHandle) return;

  ULONG SM = GetXPKMethodListNumber( (UBYTE *) &FFC.FFC_XPKMethod );

  LT_SetAttributes(SettingsHandle, GIDSET_METHODLIST,
    GTLV_Labels,      &XPKMethodList,
    GTLV_Selected,    SM,
    GTLV_MakeVisible, (SM == ~NULL) ? NULL : SM,
    TAG_DONE);
}

/*************************************************
 *
 * Remove the XPK method list from the settings
 * window. 
 *
 */

void RemoveXPKMethodList( void )
{
  if (!SettingsHandle) return;

  LT_SetAttributes(SettingsHandle, GIDSET_METHODLIST,
    GTLV_Labels, NULL,
    TAG_DONE);
}

/*************************************************
 *
 * Print a string in the settings window's status
 * gadget. 
 *
 */

UBYTE PrintSettingsStatusBuf[256]; /* Use this buffer to hold string until next call */

void PrintSettingsStatus( UBYTE *String, APTR Fmt )
{
  if (!SettingsHandle) return;

  RawDoFmt(String, Fmt, &putchproc, (UBYTE *) &PrintSettingsStatusBuf);

  PrintSettingsStatusBuf[75] = NULL; /* Limit string size */

  LT_SetAttributes(SettingsHandle, GIDSET_XPKINFOBOX,
    GTTX_Text, &PrintSettingsStatusBuf,
    TAG_DONE);
}

/*************************************************
 *
 * Pass the name of an XPK method and return the
 * ordinal index number for that method's position
 * in the linked list.
 *
 */

ULONG GetXPKMethodListNumber( UBYTE *MethodName )
{
  /* Pass NUKE, FAST, etc into MethodName, and ordinal number
     of position will be returned, else ~NULL if not found. */

  struct PackerListNode *PLN;

  ULONG Cnt = NULL;

  for ( PLN = (struct PackerListNode *) XPKMethodList.lh_Head;
        PLN->PLN_Node.ln_Succ;
        PLN = (struct PackerListNode *) PLN->PLN_Node.ln_Succ )
  {
    if (!Stricmp( (UBYTE *) &PLN->PLN_Method, MethodName ))
    {
      return Cnt;
    }
    else Cnt++;
  }

  return ~NULL;
}

