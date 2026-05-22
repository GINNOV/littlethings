
/*
 * [!BGN - MACHINE GENERATED - DO NOT EDIT THIS HEADER]
 *
 * Program   : FloppyFlux (Floppy disk backup program)
 * Version   : 1.2
 * File      : Work:Source/!WIP/FloppyFlux/FF_wininfo.c
 * Author    : Andrew Bell
 * Copyright : Copyright © 1999 Andrew Bell
 * Created   : Wednesday 05-May-99 22:42:29
 * Modified  : Sunday 27-Jun-99 19:57:22
 * Comment   : Module for handling the info window
 *
 * (Generated with StampSource 1.1 by Andrew Bell)
 *
 * [!END - MACHINE GENERATED - DO NOT EDIT THIS HEADER]
 *
 */

#define FLOPPYFLUX_WININFO_C

/* Created: Wed/28/Apr/1999 */

#include <FF_include.h>

/*************************************************
 *
 * Function protos
 *
 */

Prototype void DisplayInfo( void );
Prototype BOOL OpenInfoWindow( UBYTE *Text, APTR TextFmt );
Prototype void CloseInfoWindow( void );
Prototype void IDCMPInfoWindow( void );

/*************************************************
 *
 * Data protos
 *
 */

/*************************************************
 *
 * Display and handle the information window.
 *
 */

void DisplayInfo( void )
{
  PrintStatus("Getting information...", NULL );

  ULONG ImageCnt = NULL;
  ULONG PackedImageCnt = NULL;
  ULONG ImageByteCnt = NULL;

  BPTR IDLock; /* Image Dir lock */

  if (IDLock = Lock(IMAGEDIRNAME, SHARED_LOCK))
  {
    struct FileInfoBlock *FIB;

    if (FIB = (struct FileInfoBlock *) AllocDosObject(DOS_FIB, NULL))
    {
      if (Examine(IDLock, FIB))
      {
        if (FIB->fib_DirEntryType > 0)
        {
          LT_LockWindow( MainWindow );

          while (ExNext(IDLock, FIB))
          {
            ImageByteCnt += FIB->fib_Size;
            ImageCnt++;

            UBYTE TmpPath[256]; strcpy( (UBYTE *) &TmpPath, IMAGEDIRNAME);

            if (AddPart( (UBYTE *) &TmpPath, (UBYTE *) &FIB->fib_FileName, 256L))
            {
              ULONG res = IsFileXPKPacked( (UBYTE *) &TmpPath );

              if ( (res != NULL) && (res != ~NULL) )
              {
                /* Is packed */ PackedImageCnt++;
              }
            }
            else FFDOSError(NULL, NULL);
          }

          if (IoErr() != ERROR_NO_MORE_ENTRIES)
          {
            FFDOSError(NULL, NULL);
          }

          LT_UnlockWindow( MainWindow );
        }
        else
        {
          /* Invalid object type - We got a dir! :) */
        }
      }
      else FFDOSError(NULL, NULL);

      FreeDosObject(DOS_FIB, FIB);
    }
    else FFDOSError(NULL, NULL);

    UnLock(IDLock);
  }
  else FFDOSError(NULL, NULL);

  PrintStatus("Finished getting information.", NULL );

  UBYTE xpkvbuf[32] = { "(Not available)\0" };

  if (XpkBase)
  {
    ULONG xpkvstream[] = { (ULONG) XpkBase->lib_Version, (ULONG) XpkBase->lib_Revision };
    RawDoFmt("%lu.%lu", &xpkvstream, &putchproc, &xpkvbuf);
  }

  ULONG stream[] = { ImageCnt, ImageByteCnt, PackedImageCnt, (ULONG) &xpkvbuf };

  /* use K, MB, GB, etc. here */

  UBYTE *InfoString = "\n"
                      " Amount of disk images: %lu \n"
                      " Total amount of bytes used by disk images: %lu \n"
                      "\n"
                      " Amount of compressed disk images: %lu \n"
                      "\n"
                      " Current version of XPK installed: %.32s \n"
                      "\n";

  if (OpenInfoWindow(InfoString, &stream))
  {
    IDCMPInfoWindow();
  }
  CloseInfoWindow();
}

/*************************************************
 *
 * Open the information window.
 *
 */

struct LayoutHandle *InfoHandle = NULL;
struct Window *InfoWindow = NULL;
UBYTE *InfoWinTextBuf = NULL;

BOOL OpenInfoWindow( UBYTE *Text, APTR TextFmt )
{
  BOOL Result = FALSE;

  if (Text)
  {
    InfoWinTextBuf = (UBYTE *) MyAllocVec( RawDoFmtSize(Text, TextFmt ) + SAFETY );

    if (InfoWinTextBuf)
    {
      RawDoFmt(Text, TextFmt, &putchproc, InfoWinTextBuf);
    }
    else return FALSE;
  }
  else return FALSE;

  InfoHandle = LT_CreateHandleTags( NULL,
                              LAHN_AutoActivate, FALSE,
                              TAG_DONE);

  if (InfoHandle)
  {
    /* Note: The 'Handle' variable is required for my macros */

    struct LayoutHandle *Handle = InfoHandle;

    VGroup, LA_LabelText, "FloppyFlux infomation", EndTags
      ObjBox,    LA_ID,          GIDINF_TEXTBOX,
                 LABX_Line,      InfoWinTextBuf,
                 LABX_Chars,     40,
                 LALV_TextAttr,  ~NULL,
                 LABX_AlignText, ALIGNTEXT_Centered,
                 EndTags
      ObjButton, LA_LabelText, "Continue", LA_ID, GIDINF_CONTINUE, EndTags
    EndGroup

    InfoWindow = LT_Build( Handle,
                                LAWN_Title,       "Information window",
                                LAWN_IDCMP,       IDCMP_CLOSEWINDOW,
                                LAWN_Parent,      MainWindow,
                                LAWN_BlockParent, TRUE,
                                WA_Flags,         ( WFLG_ACTIVATE | WFLG_CLOSEGADGET |
                                                    WFLG_DRAGBAR | WFLG_DEPTHGADGET |
                                                    WFLG_RMBTRAP ),
                                TAG_DONE );

    if (InfoWindow)
    {
      Result = TRUE;
    }

  } /* CreateHandleTags() */

  return Result;
}

/*************************************************
 *
 * Close the information window.
 *
 */

void CloseInfoWindow( void )
{
  if (InfoHandle) LT_DeleteHandle(InfoHandle);

  InfoHandle = NULL;
  InfoWindow = NULL;

  if (InfoWinTextBuf)
  {
    MyFreeVec(InfoWinTextBuf);

    InfoWinTextBuf = NULL;
  }
}

/*************************************************
 *
 * Handle the information window's IDCMP events.
 *
 */

void IDCMPInfoWindow( void )
{
  /* IDCMP event handler for the info window */

  struct IntuiMessage *Message;
  ULONG                MsgQualifier, MsgClass;
  UWORD                MsgCode;
  struct Gadget       *MsgGadget;
  BOOL                 Done = FALSE;

  do
  {
    WaitPort( InfoWindow->UserPort );

    while( Message = GT_GetIMsg( InfoWindow->UserPort ) )
    {
      MsgClass     = Message->Class;
      MsgCode      = Message->Code;
      MsgQualifier = Message->Qualifier;
      MsgGadget    = Message->IAddress;
      GT_ReplyIMsg( Message );

      LT_HandleInput( InfoHandle, MsgQualifier, &MsgClass, &MsgCode, &MsgGadget );

      switch( MsgClass )
      {
        case IDCMP_CLOSEWINDOW:
          Done = TRUE;
          break;

        case IDCMP_GADGETUP:
          switch( MsgGadget->GadgetID )
          {
            case GIDINF_CONTINUE:
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
 *
 *
 */

