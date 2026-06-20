
/*
 * [!BGN - MACHINE GENERATED - DO NOT EDIT THIS HEADER]
 *
 * Program   : FloppyFlux (Floppy disk backup program)
 * Version   : 1.2
 * File      : Work:Source/!WIP/FloppyFlux/FF_winmain.c
 * Author    : Andrew Bell
 * Copyright : Copyright © 1999 Andrew Bell
 * Created   : Wednesday 05-May-99 22:42:29
 * Modified  : Sunday 27-Jun-99 19:57:22
 * Comment   : Module for handling the main window
 *
 * (Generated with StampSource 1.1 by Andrew Bell)
 *
 * [!END - MACHINE GENERATED - DO NOT EDIT THIS HEADER]
 *
 */

#define FLOPPYFLUX_WINMAIN_C

/* Created: Wed/28/Apr/1999 */

#include <FF_include.h>

/*************************************************
 *
 * Function protos
 *
 */

Prototype void IDCMPMainWindow( void );
Prototype BOOL OpenMainWindow( void );
Prototype void CloseMainWindow( void );
Prototype void ActM_AboutFF( void );
Prototype void ActM_ImportDiskImage( void );
Prototype void ActM_ExportDiskImage( void );
Prototype void ActM_PackSelected( void );
Prototype void ActM_UnpackSelected( void );
Prototype void ActM_PackAll( void );
Prototype void ActM_UnpackAll( void );

/*************************************************
 *
 * Data protos
 *
 */

Prototype struct Window *MainWindow;
Prototype struct LayoutHandle *MainWindowHandle;

/*************************************************
 *
 * Create the main window.
 *
 */

/* Move these to FF_include.h */
#define nmTitle(txt)            { NM_TITLE, txt, NULL, NULL, NULL, NULL },
#define nmItem(txt, flags, mid) { NM_ITEM, txt, flags, NULL, NULL, (APTR) mid },
#define nmBar                   { NM_ITEM, NM_BARLABEL, NULL, NULL, NULL, NULL },
#define nmEnd                   { NM_END, NULL, NULL, NULL, NULL, NULL }

struct NewMenu MainMenus[] =
{
  nmTitle( "Project"                                    )
  nmItem ( "Information...",      NULL, MID_INFO        )
  nmItem ( "Settings...",         NULL, MID_SETTINGS    )
  nmBar
  nmItem ( "About FloppyFlux...", NULL, MID_ABOUT       )
  nmBar
  nmItem ( "Hide GUI",            NULL, MID_HIDE        )
  nmBar
  nmItem ( "Quit",                NULL, MID_QUIT        )

  nmTitle( "Disk Images"                                )
  nmItem ( "Import from file(s)...", NULL, MID_IMPORT      )
  nmItem ( "Export to file...",   NULL, MID_EXPORT      )
  nmBar

  nmItem ( "Pack selected",    NULL, MID_PACKSELECTED   )
  nmItem ( "Unpack selected",  NULL, MID_UNPACKSELECTED )
  nmItem ( "Pack all",         NULL, MID_PACKALL        )
  nmItem ( "Unpack all",       NULL, MID_UNPACKALL      )
  nmEnd
};

struct Window *MainWindow = NULL;
struct LayoutHandle *MainWindowHandle = NULL;
struct AppWindow *AppWnd = NULL;

BOOL OpenMainWindow( void )
{
  BOOL Result = FALSE;

  struct LayoutHandle *Handle = NULL;

  MainWindowHandle = Handle = LT_CreateHandleTags( NULL,
                                LAHN_AutoActivate, FALSE,
                                LAHN_LocaleHook,   &GTLayoutLocalHook,
                                TAG_DONE);

  if (Handle)
  {
    /*
     * This is the GUI tree the main window, uses GTLayout.library
     */

    ULONG DrivesTable[] = /* This are used in the drive cycle gadget */
    {
      SID_DF0, SID_DF1, SID_DF2, SID_DF3, -1
    };

    VGroup, LA_LabelText, "Main window", EndTags
      HGroup, LAGR_SameSize, TRUE, LAGR_Spread, TRUE, EndTags
        ObjCycle,  LA_LabelText, "Drive", LACY_LabelTable, &DrivesTable, LA_ID, GID_DEVICE, EndTags
        ObjButton, LA_LabelText, "Read Disk Image", LA_ID, GID_READ, EndTags
        ObjButton, LA_LabelText, "Write Disk Image", LA_ID, GID_WRITE, EndTags
      EndGroup
      VGroup, LAGR_Frame, FALSE, EndTags
        VGroup, EndTags
          ObjListView,  LA_Chars,       47,
                        LA_ID,          GID_LIST,
                        LA_LabelText,   "Image name / length in bytes / pack status",
                        LALV_Lines,     15,
                        LALV_Link,      NIL_LINK,
                        LALV_TextAttr,  -1,
                        LALV_ResizeY,   TRUE,
                        LALV_ResizeX,   TRUE,
                        LALV_MinChars,  47,
                        LALV_MinLines,  5,
                        LALV_CursorKey, TRUE,
                        LALV_LockSize,  TRUE,
                        EndTags
        EndGroup
        HGroup, LAGR_Frame, FALSE, LAGR_Spread, TRUE, EndTags
          ObjButton, LA_LabelText, "Edit", LA_ID, GID_EDIT, EndTags
          ObjButton, LA_LabelText, "Delete", LA_ID, GID_DELETE, EndTags
          ObjButton, LA_LabelText, "Delete All", LA_ID, GID_DELETEALL, EndTags
          ObjButton, LA_LabelText, "Info", LA_ID, GID_INFO, EndTags
          ObjButton, LA_LabelText, "Rescan", LA_ID, GID_RESCAN, EndTags
        EndGroup
        HGroup, EndTags
          ObjText, LA_ID, GID_STATUS, GTTX_Border, TRUE, LA_Chars, 50, EndTags
        EndGroup
      EndGroup
      HGroup, LAGR_SameSize, TRUE, LAGR_Spread, TRUE, EndTags
        ObjButton, LA_LabelText, "Hide", LA_ID, GID_HIDE, EndTags
        ObjButton, LA_LabelText, "About", LA_ID, GID_ABOUT, EndTags
        ObjButton, LA_LabelText, "Settings", LA_ID, GID_SETTINGS, EndTags
        ObjButton, LA_LabelText, "Quit", LA_ID, GID_QUIT, EndTags
      EndGroup
    EndGroup

    MainWindow = LT_Build( Handle,
                            LAWN_Title,        VERS " (" DATE ") Copyright © " YEAR " Andrew Bell",
                            LAWN_IDCMP,        (IDCMP_CLOSEWINDOW | IDCMP_MENUPICK),
                            LAWN_Zoom,         TRUE,
                            LAWN_MenuTemplate, &MainMenus,
                            //LAWN_ExtraHeight,  50,
                            WA_Flags,          (WFLG_ACTIVATE |
                                                WFLG_CLOSEGADGET |
                                                WFLG_DRAGBAR |
                                                WFLG_DEPTHGADGET ),
                            TAG_DONE );

    if (MainWindow)
    {
      if (!(AppWnd = AddAppWindowA(0, 0, MainWindow, WBMP, NULL)))
      {
        FFError("Unable to create AppWindow!\n"
                "\nYou will not be able to drag icons into the main window.", NULL);
      }

      Result = TRUE;
    }
    else
    {
      FFError("Unable to layout window", NULL);
      CloseMainWindow();
    }
  }
  else
  {
    FFError("Unable to create window handle", NULL);
  }
  return Result;
}

/*************************************************
 *
 * Close the main window.
 *
 */

void CloseMainWindow( void )
{
  if (AppWnd)
  {
    FlushMsgPort( WBMP );
    RemoveAppWindow(AppWnd);
    AppWnd = NULL;
  }

  if (MainWindowHandle)
  {
    LT_DeleteHandle(MainWindowHandle);
    MainWindowHandle = NULL;
  }

  MainWindow = NULL;
}

/*************************************************
 *
 * Parse all events (esp. IDCMP for main window).
 *
 */

void IDCMPMainWindow( void )
{
  struct IntuiMessage *Message;
  ULONG                MsgQualifier, MsgClass;
  UWORD                MsgCode;
  struct Gadget       *MsgGadget;
  BOOL                 Done = FALSE;

  do
  {
    ULONG Sig_Notify;

    if (NotifyActive)
    {
      Sig_Notify = (1L << NotifySigNum);
    }
    else
    {
      Sig_Notify = 0;
    }

    ULONG Sig_WB = ( 1L << WBMP->mp_SigBit );
    ULONG Sig_IDCMP;

    if (Iconified)
    {
      Sig_IDCMP = 0;
    }
    else
    {
      Sig_IDCMP = ( 1L << MainWindow->UserPort->mp_SigBit );
    }

    ULONG SigEvents = Wait( Sig_IDCMP | Sig_WB | Sig_Notify | SIGBREAKF_CTRL_C );

    if ( (SigEvents & Sig_IDCMP) && !Iconified )
    {
      while ( !Iconified && (Message = GT_GetIMsg( MainWindow->UserPort )) )
      {
        MsgClass     = Message->Class;
        MsgCode      = Message->Code;
        MsgQualifier = Message->Qualifier;
        MsgGadget    = Message->IAddress;
        GT_ReplyIMsg( Message );
        LT_HandleInput( MainWindowHandle, MsgQualifier, &MsgClass, &MsgCode, &MsgGadget );

        switch( MsgClass )
        {
          case IDCMP_CLOSEWINDOW: Done = TRUE; break;
          case IDCMP_VANILLAKEY: break;
          case IDCMP_MENUPICK:
            UWORD menuNumber = MsgCode;
            while ( menuNumber != MENUNULL )
            {
              struct MenuItem *item = ItemAddress( MainWindowHandle->Menu, menuNumber );

              switch( (ULONG) GTMENUITEM_USERDATA( item ) )
              {
                case MID_INFO:           DisplayInfo();           break;
                case MID_SETTINGS:       DisplaySettingsWindow(); break;
                case MID_HIDE:           HideGUI();               break;
                case MID_ABOUT:          ActM_AboutFF();          break;
                case MID_IMPORT:         ActM_ImportDiskImage();  break;
                case MID_EXPORT:         ActM_ExportDiskImage();  break;
                case MID_PACKSELECTED:   ActM_PackSelected();     break;
                case MID_UNPACKSELECTED: ActM_UnpackSelected();   break;
                case MID_PACKALL:        ActM_PackAll();          break;
                case MID_UNPACKALL:      ActM_UnpackAll();        break;
                case MID_QUIT:           Done = TRUE;             break;
                default: break;
              }
              menuNumber = item->NextSelect;
            }
            break;

          case IDCMP_GADGETUP:
            ULONG Selected = (ULONG) LT_GetAttributes( MainWindowHandle, GID_LIST,
                                      TAG_DONE );

            switch( MsgGadget->GadgetID )
            {
              case GID_EDIT:
                if (Selected != -1)
                {
                  struct ImageEntry *IE = GetImageEntry( Selected );
                  if ( IE )
                  {
                    DetachImageList();

                    EditImageEntryAttr( IE, FALSE );
                    SortImageEntry( IE );
                    AttachImageList();
                    PrintComment();
                  }
                }
                else DisplayBeep( NULL );
                break;

              case GID_DEVICE:
                ActiveUnit = (ULONG) LT_GetAttributes( MainWindowHandle, GID_DEVICE,
                                      TAG_DONE );

                PrintStatus("Current drive is now DF%lu:", &ActiveUnit);
                break;

              case GID_READ:
                struct ImageEntry *IE = AllocImageEntry();
                if ( IE )
                {
                  UBYTE DFx[8]; DFx[0] = 0;
                  sprintf( (UBYTE *) &DFx, "DF%lu:", ActiveUnit);

                  if (!GetDiskDetails((UBYTE *) &DFx, (UBYTE *) &IE->IE_Name, 128L, NULL ))
                  {
                    IE->IE_Name[0] = 0;
                  }

                  if (EditImageEntryAttr( IE, TRUE ))
                  {
                    InsertImageEntrySorted( IE );
                    AttachImageList(); /* Let user see changes to the entry */

                    /* Save the disk to a packed file only if the
                       user wants to and XPK is valid */

                    if (FFC.FFC_UseXPK && XpkBase)
                    {
                      if (!DiskToPackedFile( ActiveUnit, (UBYTE *) &IE->IE_FullPath ))
                      {
                        RemImageEntry( IE, FALSE );
                      }
                    }
                    else /* if FFC.FFC_UseXPK == FALSE */
                    {
                      if (!DiskToFile( ActiveUnit, (UBYTE *) &IE->IE_FullPath ))
                      {
                        RemImageEntry( IE, FALSE );
                      }
                    }
                  }
                  else PrintStatus("Image attr window canceled.", NULL);
                  UpdateImageEntrySize( IE );
                  SetImageEntryPackStat( IE );

                  AttachImageList();
                }
                break;

              case GID_WRITE:
                if (Selected != -1)
                {
                  switch(FFRequest( "Are you sure you want to write this disk image to unit %lu?\n"
                                    "All data on the destination disk will be erased, forever.", &ActiveUnit, "Write it|Whoops!"))
                  {
                    case 0: /* Whoops! */
                      break;

                    case 1: /* Write it */
                      struct ImageEntry *IE = GetImageEntry( Selected );
                      if (IE)
                      {
                        ULONG res = IsFileXPKPacked((UBYTE *) &IE->IE_FullPath);
                        if (res == -1)
                        {
                          PrintStatus("Failed to examine disk image!", NULL);
                        }
                        else if (res == NULL)
                        {
                          /* File is not packed */
                          FileToDisk( ActiveUnit, (UBYTE *) &IE->IE_FullPath );
                        }
                        else
                        {
                          /* File is XPK packed */

                          if (XpkBase)
                          {
                            PackedFileToDisk( ActiveUnit, (UBYTE *) &IE->IE_FullPath );
                          }
                          else
                          {
                            FFError("This disk image is packed with XPK!\n"
                                    "I cannot unpack it until you install XPK onto your system!", NULL);

                            PrintStatus("You need XPK!", NULL);
                          }
                        }
                      }
                      break;
                  }
                }
                else DisplayBeep(NULL);
                break;

              case GID_LIST:
                PrintComment();
                break;

              case GID_DELETE:
                if (Selected != -1)
                {
                  struct ImageEntry *IE = GetImageEntry( Selected );
                  if ( IE )
                  {
                    DetachImageList();
                    DeleteImageEntry(IE);
                    AttachImageList();
                  }
                }
                else DisplayBeep( NULL );
                break;

              case GID_DELETEALL: DeleteImageList();       break;
              case GID_INFO:      DisplayInfo();           break;
              case GID_RESCAN:    BuildImageList( TRUE );  break;
              case GID_HIDE:      HideGUI();               break;
              case GID_ABOUT:     ActM_AboutFF();          break;
              case GID_SETTINGS:  DisplaySettingsWindow(); break;
              case GID_QUIT:      Done = TRUE;             break;
            }
            break;
        }
      }
    }
    else if ( SigEvents & Sig_WB )
    {
      /* Workbench is communicating with the FloppyFlux process */

      ProcessWBMsgs(); /* Jumps to FF_wb.c */
    }
    else if ( SigEvents & Sig_Notify )
    {
      PrintStatus("Disk image directory has changed, updating...", NULL);

      BuildImageList( TRUE );
    }
    else if ( SigEvents & SIGBREAKF_CTRL_C )
    {
      Done = TRUE;  /* Catching a "Ctrl + C" comes in handy sometimes :) */
    }
  }
  while( !Done );

  /* Before we quit FloppyFlux we must build a new cache file to
     reflect the changes made to the image list. */

  CreateCFFromIL( CACHEFILENAME );
}

/*************************************************
 *
 * Show the "about" requester.
 *
 */

void ActM_AboutFF( void )
{
  FFInformation( VERS " (" DATE "), GIFTWARE\n"
                 "\n"
                 "Copyright © " YEAR  " Andrew Bell.\n"
                 "\n"
                 "email: " EMAILADDR "\n"
                 "WWW: " WWWURL "\n"
                 "\n"
                 "gtlayout.library is Copyright © 1998 Olaf `Olsen' Barthel.\n"
                 "\n"
                 "xpkmaster.library is Copyright © 1999 by Dirk Stöcker,\n"
                 "Christian von Roques, Urban Dominik Müller & Bryan Ford.\n"
                 , NULL );
}

/*************************************************
 *
 * Import a disk image from a file.
 *
 */

void ActM_ImportDiskImage( void )
{
  BOOL res = AslRequestTags(ImpExpFileReq,
    ASLFR_Window,        MainWindow,
    ASLFR_DoMultiSelect, TRUE,
    ASLFR_TitleText,     "Select some disk images to import...",
    TAG_DONE);

  if (res)
  {
    DetachImageList();

    ULONG Cnt = NULL, FileCnt = ImpExpFileReq->fr_NumArgs;
    struct WBArg *WA = ImpExpFileReq->fr_ArgList;

    UBYTE DISrcPath[256]; UBYTE DIDstPath[256];
    ULONG OKCnt = NULL;

    BOOL CompressMode = FFC.FFC_UseXPK;

    struct ProgressHandle *PH = OpenProgressWindow( FileCnt, "Importing disk images..." );

    for ( Cnt = NULL; Cnt < FileCnt; Cnt++ )
    {
      if (CompressMode)
      {
        PrintStatus("Importing and packing %s...", &WA->wa_Name);
      }
      else
      {
        PrintStatus("Importing %s...", &WA->wa_Name);
      }

      if (AslAddPart( ImpExpFileReq, WA, (UBYTE *) &DISrcPath, 256L ))
      {
        UBYTE *DestName = WA->wa_Name;

        struct ImageEntry *IE = FindImageEntryByName( DestName, NULL );

        if ( IE )
        {
          switch(FFRequest( "The name %s is already present in the list!\n"
                            "What should I do?", &WA->wa_Name, "Rename|Skip|Overwrite|Abort"))
          {
            case 0: /* Abort */
              Cnt = FileCnt;
              continue;

            case 1: /* Rename */
              if (!(DestName = GetString( DestName )))
              {
                WA++;
                continue; /* If user canceled string, then skip */
              }
              break;

            default:
            case 2: /* Skip */
              WA++;
              continue;

            case 3: /* Overwrite */
              /* Remove the old image, this function will popup a warning
                 requester, so we don't have to do it here. */

              DeleteImageEntry( IE );
              break;
          }
        }

        strcpy( (UBYTE *) &DIDstPath, IMAGEDIRNAME);

        if (AddPart( (UBYTE *) &DIDstPath, DestName, 256L))
        {
          struct FileInfoBlock *SrcFIB = AllocDosObject(DOS_FIB, NULL);

          if (SrcFIB)
          {
            BOOL Result;

            if (CompressMode)
            {
              Result = CopyFileAndPack( (UBYTE *) &DISrcPath, (UBYTE *) &DIDstPath, SrcFIB );
            }
            else
            {
              Result = CopyFile( (UBYTE *) &DISrcPath, (UBYTE *) &DIDstPath, SrcFIB );
            }

            if (!Result)
            {
              FFError("Failed to copy %s!", &WA->wa_Name);
            }
            else
            {
              SetImageEntryPackStat( AddImageEntry(DestName,
                (UBYTE *) &SrcFIB->fib_Comment, SrcFIB->fib_Size, -1, FALSE) );

              OKCnt++;
            }

            FreeDosObject(DOS_FIB, SrcFIB);
          }
        } /* AddPart() */
      }

      if (UpdateProgress( PH, Cnt ))
      {
        break; /* Abort */
      }

      WA++;
    }

    AttachImageList(); /* Show the imports */
    PrintStatus("Imported %lu disk images.", &OKCnt);
    CloseProgressWindow( PH );
  }
}

/*************************************************
 *
 * Export an internal image to a file.
 *
 */

void ActM_ExportDiskImage( void )
{
  /* Let user decompress output file */

  ULONG Selected = (ULONG) LT_GetAttributes( MainWindowHandle, GID_LIST,
                            TAG_DONE );

  if (Selected != -1)
  {
    struct ImageEntry *IE = GetImageEntry( Selected );

    if (IE)
    {
      BOOL res = AslRequestTags(ImpExpFileReq,
        ASLFR_Window,      MainWindow,
        ASLFR_TitleText,   "Export disk image to a file...",
        ASLFR_DoSaveMode,  TRUE,
        ASLFR_InitialFile, &IE->IE_Name,
        TAG_DONE);

      if (res)
      {
        UBYTE DIDstPath[256];

        strncpy((UBYTE *) &DIDstPath, ImpExpFileReq->fr_Drawer, 256L);

        if (AddPart( (UBYTE *) &DIDstPath, ImpExpFileReq->fr_File, 256L ))
        {
          PrintStatus("Please wait, exporting disk image...", NULL);

          if (IsFileXPKPacked((UBYTE *) &IE->IE_FullPath))
          {
            switch(FFRequest("This disk image is compressed,\n"
                             "do you want to decompress it before exporting?", NULL, "Yes|No"))
            {
              default:
              case 0: /* No */
                CopyFile( (UBYTE *) &IE->IE_FullPath, (UBYTE *) &DIDstPath, NULL);
                break;

              case 1: /* Yes */
                InitXPK(); /* Ensure that XPK is available */
                if (!XpkBase)
                {
                  FFError("This disk image is compressed with XPK,\n"
                          "which is not available on your system!", NULL);
                }
                else CopyFileAndUnpack( (UBYTE *) &IE->IE_FullPath, (UBYTE *) &DIDstPath, NULL);
                break;
            }
          }
          else CopyFile( (UBYTE *) &IE->IE_FullPath, (UBYTE *) &DIDstPath, NULL);

          PrintStatus("Finished.", NULL);
        }
      }
    }
    else DisplayBeep(NULL);
  }
  else DisplayBeep(NULL);
}

/*************************************************
 *
 * Compress the currently selected image.
 *
 */

void ActM_PackSelected( void )
{
  ULONG Selected = (ULONG) LT_GetAttributes( MainWindowHandle, GID_LIST,
                            TAG_DONE );

  if (Selected != -1)
  {
    struct ImageEntry *IE = GetImageEntry( Selected );

    if (IE)
    {
      PackFile( (UBYTE *) &IE->IE_FullPath, TRUE );
      DetachImageList();
      UpdateImageEntrySize(IE);
      SetImageEntryPackStat(IE);
      AttachImageList();
    }
    else DisplayBeep(NULL);
  }
  else DisplayBeep(NULL);
}

/*************************************************
 *
 * Decompress the currently selected image.
 *
 */

void ActM_UnpackSelected( void )
{
  ULONG Selected = (ULONG) LT_GetAttributes( MainWindowHandle, GID_LIST,
                            TAG_DONE );

  if (Selected != -1)
  {
    struct ImageEntry *IE = GetImageEntry( Selected );

    if (IE)
    {
      UnpackFile( (UBYTE *) &IE->IE_FullPath, TRUE );
      DetachImageList();
      UpdateImageEntrySize(IE);
      SetImageEntryPackStat(IE);
      AttachImageList();
    }
    else DisplayBeep(NULL);
  }
  else DisplayBeep(NULL);
}

/*************************************************
 *
 * Compress all disk images.
 *
 */

void ActM_PackAll( void )
{
  struct ImageEntry *IE;
  ULONG Cnt = 0, FileCnt = CountImageList();

  if (!FileCnt)
  {
    DisplayBeep(NULL);
    return;
  }

  BOOL ForceMode = FALSE; UBYTE *IgnoreID = NULL;

  switch(FFRequest("Should I skip any disk images that have already been packed?", NULL, "Yes|No|Abort"))
  {
    default:
    case 0: /* Abort */
      return;

    case 1: /* Yes */
      ForceMode = FALSE;
      break;

    case 2: /* No */
      ForceMode = TRUE;
      ULONG stream = (ULONG) &FFC.FFC_XPKMethod;
      switch(FFRequest("Skip images already packed with the '%.4s' XPK method?", &stream, "Yes|No|Abort"))
      {
        default:
        case 0: /* Abort */
          return;

        case 1: /* Yes */
          IgnoreID = (UBYTE *) &FFC.FFC_XPKMethod;
          break;

        case 2: /* No */
          IgnoreID = NULL;
          break;
      }
      break;
  }

  struct ProgressHandle *PH = OpenProgressWindow( FileCnt, "Compressing images..." );

  for ( IE = (struct ImageEntry *) IEList.lh_Head;
        IE->IE_Node.ln_Succ;
        IE = (struct ImageEntry *) IE->IE_Node.ln_Succ )
  {
    Cnt++;

    ULONG stream[] =
    {
      (ULONG) &IE->IE_Name,
      (IE->IE_Size == -1) ? 0 : IE->IE_Size
    };
    PrintStatus("%s (%lu bytes)...", &stream);

    ULONG res = IsFileXPKPacked((UBYTE *) &IE->IE_FullPath);

    if (res != -1)
    {
      if (ForceMode)
      {
        if (IgnoreID && !memcmp(IgnoreID, &res, 4))
        {
          /* Skip current file */
        }
        else
        {
          PackFile( (UBYTE *) &IE->IE_FullPath, FALSE );
        }
      }
      else if (!res) /* File is not packed, so pack it */
      {
        PackFile( (UBYTE *) &IE->IE_FullPath, FALSE );
      }

      DetachImageList();
      UpdateImageEntrySize(IE);
      SetImageEntryPackStat(IE);
      AttachImageListFollow(IE);
    }

    if (UpdateProgress( PH, Cnt ))
    {
      break; /* Abort */
    }
  }

  CloseProgressWindow( PH );

  PrintStatus("Finished.", NULL);
}

/*************************************************
 *
 * Decompress all disk images.
 *
 */

void ActM_UnpackAll( void )
{
  struct ImageEntry *IE;
  ULONG Cnt = 0, FileCnt = CountImageList();

  if (!FileCnt)
  {
    DisplayBeep(NULL);
    return;
  }

  struct ProgressHandle *PH = OpenProgressWindow( FileCnt, "Decompressing images..." );

  for ( IE = (struct ImageEntry *) IEList.lh_Head;
        IE->IE_Node.ln_Succ;
        IE = (struct ImageEntry *) IE->IE_Node.ln_Succ )
  {
    Cnt++;

    ULONG stream[] =
    {
      (ULONG) &IE->IE_Name,
      (IE->IE_Size == -1) ? 0 : IE->IE_Size
    };

    PrintStatus("%s (%lu bytes)...", &stream);

    UnpackFile( (UBYTE *) &IE->IE_FullPath, FALSE );

    DetachImageList();
    UpdateImageEntrySize(IE);
    SetImageEntryPackStat(IE);
    AttachImageListFollow(IE);

    if (UpdateProgress( PH, Cnt ))
    {
      break; /* Abort */
    }
  }

  CloseProgressWindow( PH );
  PrintStatus("Finished.", NULL);
}

/*************************************************
 *
 * 
 *
 */

