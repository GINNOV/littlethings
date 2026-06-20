
/*
 * [!BGN - MACHINE GENERATED - DO NOT EDIT THIS HEADER]
 *
 * Program   : FloppyFlux (Floppy disk backup program)
 * Version   : 1.2
 * File      : Work:Source/!WIP/FloppyFlux/FF_imagelist.c
 * Author    : Andrew Bell
 * Copyright : Copyright © 1999 Andrew Bell
 * Created   : Wednesday 05-May-99 22:42:29
 * Modified  : Sunday 27-Jun-99 19:57:22
 * Comment   : Disk image list control routines
 *
 * (Generated with StampSource 1.1 by Andrew Bell)
 *
 * [!END - MACHINE GENERATED - DO NOT EDIT THIS HEADER]
 *
 */

#define FLOPPYFLUX_IMAGELIST_C

/* Created: Wed/28/Apr/1999 */

#include <FF_include.h>

/*************************************************
 *
 * Function protos
 *
 */

Prototype void InitImageList( void );
Prototype struct ImageEntry *AllocImageEntry( void );
Prototype void FreeImageEntry( struct ImageEntry *IE );
Prototype struct ImageEntry *AddImageEntry(UBYTE *ImageName, UBYTE *ImageComment, ULONG ImageSize, ULONG PackID, BOOL NoLVUpdate);
Prototype void InsertImageEntrySorted( struct ImageEntry *IE );
Prototype void RemImageEntry(struct ImageEntry *IE, BOOL NoLVUpdate);
Prototype void SortImageEntry(struct ImageEntry *IE);
Prototype struct ImageEntry *GetImageEntry( ULONG Number );
Prototype void SetImageEntryName(struct ImageEntry *IE, UBYTE *Name);
Prototype void SetImageEntryComment(struct ImageEntry *IE, UBYTE *Comment);
Prototype ULONG UpdateImageEntrySize( struct ImageEntry *IE );
Prototype void SetImageEntryPackStat( struct ImageEntry *IE );
Prototype void LayoutImageEntryViewString(struct ImageEntry *IE);
Prototype void DeleteImageEntry(struct ImageEntry *IE);
Prototype void AttachImageList( void );
Prototype void AttachImageListFollow( struct ImageEntry *IE );
Prototype void DetachImageList ( void );
Prototype void RemoveImageList ( void );
Prototype BOOL EditImageEntryAttr( struct ImageEntry *IE, BOOL NewEntry );
Prototype BOOL CheckImageEntryName( UBYTE *NameStr, struct ImageEntry *IE );
Prototype void BuildImageList( BOOL Force );
Prototype ULONG FreeImageList( void );
Prototype ULONG CountImageList( void );
Prototype void DeleteImageList( void );
Prototype struct ImageEntry *FindImageEntryByName( UBYTE *Name, struct ImageEntry *ExcludeIE );
Prototype ULONG FindImageEntryIndex( struct ImageEntry *IEToFnd );

/*************************************************
 *
 * Data protos
 *
 */

Prototype struct List IEList;

/*************************************************
 *
 * Prepare the image list for first use.
 *
 */

struct List IEList; /* Disk image list header */

void InitImageList( void )
{
  NewList( (struct List *) &IEList );
  AttachImageList();
}

/*************************************************
 *
 * Allocate the memory for an ImageEntry structure.
 * All routines should use this to allocate the
 * actual memory required by image entries. Some
 * primary things in the structure are also setup.
 *
 */

struct ImageEntry *AllocImageEntry( void )
{
  struct ImageEntry *IE = NULL;

  IE = (struct ImageEntry *) MyAllocVec( sizeof(struct ImageEntry) );

  if ( IE )
  {
    IE->IE_Node.ln_Name = (UBYTE *) &IE->IE_ViewString;
    IE->IE_Size = -1;
    IE->IE_AZero = 0;
  }

  return IE;
}

/*************************************************
 *
 * Free the structure return by AllocImageEntry()
 *
 */

void FreeImageEntry( struct ImageEntry *IE )
{
  if ( IE ) MyFreeVec( IE );
}

/*************************************************
 *
 * Add an entry to the main disk image list.
 *
 */

struct ImageEntry *AddImageEntry(UBYTE *ImageName, UBYTE *ImageComment,
                            ULONG ImageSize, ULONG PackID, BOOL NoLVUpdate)
{
  /* Add another param for ADDIE_START, ADDIE_SORTED, ADDIE_END */

  if (!NoLVUpdate) DetachImageList();

  struct ImageEntry *IE = AllocImageEntry();

  if (IE)
  {
    IE->IE_Size = ImageSize;

    SetImageEntryName(IE, ImageName);
    SetImageEntryComment(IE, ImageComment);

    IE->IE_PackID = PackID;

    LayoutImageEntryViewString(IE);
    InsertImageEntrySorted(IE);
  }

  if (!NoLVUpdate) AttachImageList();

  return IE;
}

/*************************************************
 *
 * Insert an entry into the main disk image list
 * in alphabetical order.
 *
 */

void InsertImageEntrySorted( struct ImageEntry *InsIE )
{
  if (!InsIE) return;

  struct ImageEntry *TmpIE;

  for ( TmpIE = (struct ImageEntry *) IEList.lh_Head;
        TmpIE->IE_Node.ln_Succ;
        TmpIE = (struct ImageEntry *) TmpIE->IE_Node.ln_Succ )
  {
    LONG r = Stricmp( (UBYTE *) &TmpIE->IE_Name, (UBYTE *) &InsIE->IE_Name );

    if ( r >= 0 ) /* &TmpIE->IE_Name >= &InsIE->IE_Name */
    {
      Insert( (struct List *) &IEList,
              (struct Node *) InsIE,
              (struct Node *) TmpIE->IE_Node.ln_Pred );
      return;
    }
  }

  AddTail( (struct List * ) &IEList, (struct Node *) InsIE );
}

/*************************************************
 *
 * Remove an entry from the disk image list. Note:
 * this only removes and frees the node from the
 * linked list. It does not delete the actual disk
 * image file.
 *
 * Don't get this confused with FreeImageEntry(),
 * which only frees and does not unlink!
 *
 */

void RemImageEntry(struct ImageEntry *IE, BOOL NoLVUpdate)
{
  if (!NoLVUpdate) DetachImageList();

  if (IE)
  {
    Remove( (struct Node *) IE );
    FreeImageEntry( IE );
  }

  if (!NoLVUpdate) AttachImageList();
}

/*************************************************
 *
 * Remove an existing ImageEntry from the ImageList
 * and insert it again, in alphabetical order. This
 * is required when renaming entries. WARNING: The
 * ImageList must be detached from the listview!
 *
 */

void SortImageEntry( struct ImageEntry *IE )
{
  if (!IE) return;

  Remove( (struct Node *) IE ); InsertImageEntrySorted( IE );
}

/*************************************************
 *
 * Obtain an entry from the disk image list via
 * an ordinal index number.
 *
 */

struct ImageEntry *GetImageEntry( ULONG Number )
{
  if (Number == -1) return NULL;

  struct ImageEntry *IE;

  for ( IE = (struct ImageEntry *) IEList.lh_Head;
        IE->IE_Node.ln_Succ;
        IE = (struct ImageEntry *) IE->IE_Node.ln_Succ )
  {
    if (!Number--) return IE;
  }

  return NULL;
}

/*************************************************
 *
 * Change the name field of a disk image list entry.
 *
 */

void SetImageEntryName(struct ImageEntry *IE, UBYTE *Name)
{
  if (!IE) return;

  strcpy( (UBYTE *) &IE->IE_Name, Name);
  strcpy( (UBYTE *) &IE->IE_FullPath, IMAGEDIRNAME);
  AddPart( (UBYTE *) &IE->IE_FullPath, (UBYTE *) &IE->IE_Name, 256L);

  LayoutImageEntryViewString(IE);
}

/*************************************************
 *
 * Change the comment field of a disk image list
 * entry.
 *
 */

void SetImageEntryComment(struct ImageEntry *IE, UBYTE *Comment)
{
  if (!IE) return;

  strcpy( (UBYTE *) &IE->IE_Comment, Comment);
  LayoutImageEntryViewString(IE);
}

/*************************************************
 *
 * Update an image entry to reflect the size of
 * the disk image. This function must be used
 * when size is not available when creating
 * the image entry.
 *
 */

ULONG UpdateImageEntrySize( struct ImageEntry *IE )
{
  /* Note: IE->IE_FullPath must be valid! */

  ULONG Size = -1; /* Default to unknown on error */

  if (!IE) return Size;

  if (IE)
  {
    Size = IE->IE_Size = GetFileSize( (UBYTE *) IE->IE_FullPath );

    LayoutImageEntryViewString( IE );
  }

  return Size;
}

/*************************************************
 *
 * Update an image entry to reflect if the image
 * is packed.
 *
 */

void SetImageEntryPackStat( struct ImageEntry *IE )
{
  if (!IE) return;

  /* Note: IE->IE_FullPath must be valid! */

  IE->IE_PackID = IsFileXPKPacked( (UBYTE *) &IE->IE_FullPath );

  LayoutImageEntryViewString(IE);
}

/*************************************************
 *
 * Build the string that will be seen by the user
 * in the listview gadget for an image entry.
 *
 */

/* Very big function name, pain in the arse to type in :) */

void LayoutImageEntryViewString(struct ImageEntry *IE)
{
  if (!IE) return;

  UBYTE SizeStr[32] = { "(size unknown)\0" };
  UBYTE *PackStr = "", *PackIDStr = "";

  if (!IE) return;

  if (IE->IE_Size != -1)
  {
    RawDoFmt("%8lu", &IE->IE_Size, &putchproc, &SizeStr);
  }

  if (IE->IE_PackID == -1)
  {
    PackStr = "?";
    PackIDStr = "";
  }
  else if (IE->IE_PackID)
  {
    PackStr = "packed";
    PackIDStr = (UBYTE *) &IE->IE_PackID;
  }
  else
  {
    PackStr = "";
    PackIDStr =  "";
  }

  ULONG stream[] =
  {
    (ULONG) &IE->IE_Name,
    (ULONG) &SizeStr,
    (ULONG) PackStr,
    (ULONG) PackIDStr
  };

  RawDoFmt("%-30.30s %.32s %s %-4.4s", &stream, &putchproc, &IE->IE_ViewString);
}

/*************************************************
 *
 * Delete an image entry along with it's disk image
 * file.
 *
 */

void DeleteImageEntry(struct ImageEntry *IE)
{
  if (!IE) return;

  ULONG stream = (ULONG) &IE->IE_Name;

  switch (FFRequest(
    "Do you really want to delete the whole disk image for '%s'?\n"
    "You will not be able to get it back!", &stream, "Delete It|Whoops!"))
  {
    default:  /* Whoops! */
    case 0:
      PrintStatus("Image has not been deleted.", NULL);
      break;

    case 1: /* Delete It */
      if (RemDelProtection( (UBYTE *) &IE->IE_FullPath, FALSE))
      {
        if (DeleteFile( (UBYTE *) &IE->IE_FullPath ))
        {
          RemImageEntry(IE, FALSE);

          CreateCFFromIL( CACHEFILENAME );

          PrintStatus("Image has been deleted.", NULL);
        }
        else FFDOSError("Error during deletion!", NULL);
      }
      else PrintStatus("Disk image not deleted", NULL);

      break;  
  }
}

/*************************************************
 *
 * Attach the disk image list to the main listview
 * gadget.
 *
 */

void AttachImageList( void )
{
  if (!MainWindowHandle) return;

  LT_SetAttributes(MainWindowHandle, GID_LIST,
    GTLV_Labels, &IEList,
    TAG_DONE);
}

/*************************************************
 *
 * Attach disk image list to main listview, force
 * an IE entry to be visible in the process.
 *
 */

void AttachImageListFollow( struct ImageEntry *IE )
{
  ULONG IEToFollow = FindImageEntryIndex( IE );

  if (IEToFollow == -1)
  {
    IEToFollow = 0;
  }
  else
  {
    ++IEToFollow;
  }

  LT_SetAttributes(MainWindowHandle, GID_LIST,
    GTLV_Labels,      &IEList,
    GTLV_MakeVisible, IEToFollow,
    TAG_DONE);
}

/*************************************************
 *
 * Detach the disk image list from the main
 * listview so we can work with it then re-attach
 * it via AttachImageList().
 *
 */

void DetachImageList( void )
{
  if (!MainWindowHandle) return;

  LT_SetAttributes(MainWindowHandle, GID_LIST,
    GTLV_Labels, -1,
    TAG_DONE);
}

/*************************************************
 *
 * Remove the disk image list from the listview,
 * never to be attached again.
 *
 */

void RemoveImageList( void )
{
  if (!MainWindowHandle) return;

  LT_SetAttributes(MainWindowHandle, GID_LIST,
    GTLV_Labels, NULL,
    TAG_DONE);
}

/*************************************************
 *
 * Open the edit image attr window.
 *
 */

BOOL EditImageEntryAttr( struct ImageEntry *IE, BOOL NewEntry )
{
  if (!IE) return FALSE;

  /* If NewEntry is TRUE, then no HD IO is done. */

  BOOL Result = FALSE;

  struct LayoutHandle *Handle = NULL;

  Handle = LT_CreateHandleTags( NULL,
                                LAHN_AutoActivate, FALSE,
                                TAG_DONE);
  if (Handle)
  {
    /* This is the GUI tree the image attr */

    VGroup, LA_LabelText, "Image Attributes", EndTags
      VGroup, EndTags

        ObjString, LA_Chars,      40,
                   LA_LabelText,  "Name",
                   LA_ID,         GIDIAT_NAME,
                   GTST_String,   &IE->IE_Name,
                   LAST_Activate, TRUE,
                   GTST_MaxChars, 30,
                   EndTags

        ObjString, LA_Chars,      40,
                   LA_LabelText,  "Comment",
                   LA_ID,         GIDIAT_COMMENT,
                   GTST_String,   &IE->IE_Comment,
                   GTST_MaxChars, 79, 
                   EndTags
      EndGroup
      VGroup, EndTags
        ObjSeparator, EndTags
      EndGroup
      HGroup, LAGR_SameSize, TRUE, LAGR_Spread, TRUE, EndTags
        ObjButton, LA_LabelText, "Accept", LA_ID, GIDIAT_ACCEPT, EndTags
        ObjButton, LA_LabelText, "Cancel", LA_ID, GIDIAT_CANCEL, EndTags
      EndGroup
    EndGroup

    struct Window *IIWindow;

    IIWindow = LT_Build( Handle,
                            LAWN_Title,       "Disk Image Attributes",
                            LAWN_IDCMP,       IDCMP_CLOSEWINDOW,
                            LAWN_Parent,      MainWindow,
                            LAWN_BlockParent, TRUE,
                            WA_Flags,         (WFLG_ACTIVATE |
                                               WFLG_CLOSEGADGET |
                                               WFLG_DRAGBAR |
                                               WFLG_DEPTHGADGET |
                                               WFLG_RMBTRAP ),
                            TAG_DONE );

    if (IIWindow)
    {

      struct IntuiMessage *Message;
      ULONG                MsgQualifier, MsgClass;
      UWORD                MsgCode;
      struct Gadget       *MsgGadget;
      BOOL                 Done = FALSE;

      do
      {
        WaitPort( IIWindow->UserPort );

        while ( Message = GT_GetIMsg( IIWindow->UserPort ) )
        {
          MsgClass     = Message->Class;
          MsgCode      = Message->Code;
          MsgQualifier = Message->Qualifier;
          MsgGadget    = Message->IAddress;

          GT_ReplyIMsg( Message );

          LT_HandleInput( Handle, MsgQualifier, &MsgClass, &MsgCode, &MsgGadget );

          switch( MsgClass )
          {
            case IDCMP_CLOSEWINDOW:
              Done = TRUE;
              break;

            case IDCMP_GADGETUP:
              switch( MsgGadget->GadgetID )
              {
                case GIDIAT_NAME:
                  UBYTE *NameStr = (UBYTE *) LT_GetAttributes(Handle, GIDIAT_NAME,
                                              TAG_DONE);

                  if (CheckImageEntryName( NameStr, IE ))
                  {
                    LT_Activate(Handle, GIDIAT_COMMENT);
                  }
                  else
                  {
                    LT_Activate(Handle, GIDIAT_NAME);
                  }
                  break;

                case GIDIAT_COMMENT:
                  break;

                case GIDIAT_ACCEPT:
                  UBYTE *NameStr = (UBYTE *) LT_GetAttributes(Handle, GIDIAT_NAME,
                                              TAG_DONE);

                  if (CheckImageEntryName( NameStr, IE ))
                  {
                    UBYTE *NameStr = (UBYTE *) LT_GetAttributes(Handle, GIDIAT_NAME,
                                                TAG_DONE);

                    UBYTE oldname[256];
                    if (!NewEntry) strcpy( (UBYTE *) &oldname,
                                            (UBYTE *) &IE->IE_FullPath);

                    SetImageEntryName(IE, NameStr);
                    if (!NewEntry) Rename( (UBYTE *) &oldname,
                                            (UBYTE *) &IE->IE_FullPath );

                    UBYTE *ComStr = (UBYTE *) LT_GetAttributes(Handle,
                                                GIDIAT_COMMENT, TAG_DONE);
                    if (ComStr)
                    {
                      SetImageEntryComment(IE, ComStr);

                      if (!NewEntry)
                      {
                        SetComment((UBYTE *) &IE->IE_FullPath, ComStr);
                      }
                    }

                    LT_Activate(Handle, GIDIAT_COMMENT);

                    CreateCFFromIL( CACHEFILENAME );

                    Done = TRUE;    /* We can leave loop now */
                    Result = TRUE;  /* We got a valid name */
                  }
                  else
                  {
                    LT_Activate(Handle, GIDIAT_NAME);
                  }
                  break;

                case GIDIAT_CANCEL:
                  Done = TRUE;
                  Result = FALSE;
                  break;
              }
              break;
          }
        }
      }
      while( !Done );
    }
    else
    {
      FFError("Unable to layout Image Info window", NULL);
    }

    if (Handle) LT_DeleteHandle(Handle);
  }
  return Result;
}

/*************************************************
 *
 * Ensure that the name passed to the image attr
 * window is valid.
 *
 */

BOOL CheckImageEntryName( UBYTE *NameStr, struct ImageEntry *IE )
{
  if (!IE) return;

  if (NameStr)
  {
    if (*NameStr)
    {
      if (IsFileNameValid(NameStr))
      {
        if (FindImageEntryByName( NameStr, IE ))
        {
          FFInformation("This disk image name is already being used!\n"
                        "Please choose another one.", NULL);
        }
        else return TRUE;
      }
      else
      {
        FFInformation("This name contains invalid characters.\n"
          "Please use characters that are valid for an AmigaDOS filename.", NULL);
      }
    }
    else
    {
      FFInformation("You must enter a name!", NULL);
    }
  }
  else
  {
    FFInformation("Failed to access name!", NULL);
  }
  return FALSE;
}

/*************************************************
 *
 * Scan the disk image directory for files and
 * build the disk image list.
 *
 * If the Force parameter is set to TRUE then the
 * routine will ignore the cache file and rescan
 * the whole directory.
 *
 */

void BuildImageList( BOOL Force )
{
  FreeImageList();

  /* Use the cache file? */

  if (CheckCacheFile( CACHEFILENAME ) && !Force)
  {
    /* If CheckCacheFile() returns TRUE then the cache file is valid */

    if (CreateILFromCF( CACHEFILENAME ))
    {
      goto ENDSCAN; /* Spit! */
    }
  }

  /* Build the list from scratch */

  LT_LockWindow( MainWindow );
  PrintStatus("Scanning the image directory...", NULL );

  BPTR IDLock; /* Image Dir lock */
  register ULONG ImageCnt = 0;

  if (IDLock = Lock(IMAGEDIRNAME, SHARED_LOCK))
  {
    struct FileInfoBlock *FIB;

    if (FIB = (struct FileInfoBlock *) AllocDosObject(DOS_FIB, NULL))
    {
      if (Examine(IDLock, FIB))
      {
        if (FIB->fib_DirEntryType > 0)
        {
          while (ExNext(IDLock, FIB))
          {
            struct ImageEntry *IE;

            IE = AddImageEntry( (UBYTE *) &FIB->fib_FileName,
                    (UBYTE *) &FIB->fib_Comment, FIB->fib_Size, -1, TRUE);

            if (IE)
            {
              SetImageEntryPackStat( IE );
              LayoutImageEntryViewString( IE );
            }
            ImageCnt++;
          }
        }
        else
        {
          /* Invalid object type - We got a dir! */
        }
      }
      FreeDosObject(DOS_FIB, FIB);
    }
    UnLock(IDLock);
  }
  LT_UnlockWindow( MainWindow );

  PrintStatus("Found %lu floppy disk images.", &ImageCnt );

  ENDSCAN:

  AttachImageList();

  /* When we build the image list for the first time, auto-select
     the first entry in the list. */

  LT_SetAttributes(MainWindowHandle, GID_LIST,
    GTLV_Selected, 0,
    TAG_DONE);
}

/*************************************************
 *
 * Free the disk image list. Note: This function
 * returns the last selected item in the listview.
 *
 */

ULONG FreeImageList( void )
{
  LONG LastSelected = -1;

  if (GTLayoutBase && MainWindowHandle)
  {
    LT_GetAttributes(MainWindowHandle, GID_LIST,
      GTLV_Selected, &LastSelected,
      TAG_DONE);
  }

  RemoveImageList();
  struct ImageEntry *IE, *TmpIE;

  for ( IE = (struct ImageEntry *) IEList.lh_Head; IE->IE_Node.ln_Succ ;)
  {
    TmpIE = (struct ImageEntry *) IE->IE_Node.ln_Succ;
    RemImageEntry(IE, TRUE);
    IE = TmpIE;
  }

  NewList( (struct List *) &IEList );
  return LastSelected;
}

/*************************************************
 *
 * Count how many disk images are stored in the
 * disk image list.
 *
 */

ULONG CountImageList( void )
{
  ULONG Cnt = NULL;
  struct ImageEntry *IE;

  for ( IE = (struct ImageEntry *) IEList.lh_Head;
        IE->IE_Node.ln_Succ;
        IE = (struct ImageEntry *) IE->IE_Node.ln_Succ )
  {
    Cnt++;
  }

  return Cnt;
}

/*************************************************
 *
 * Delete every entry in the disk image list and
 * the associated files in the disk image directory.
 *
 */

void DeleteImageList( void )
{
  ULONG Cnt = NULL, Total = CountImageList();
  ULONG DelCnt = NULL, FailCnt = NULL;

  if (!Total) return;

  switch (FFPopup("Delete all request",
    "Really delete all disk images?\n"
    "You cannot get them back.", NULL, "Delete them|Whoops!"))
  {
    default:
    case 0:
      PrintStatus("No disk images were deleted.", NULL);
      return;

    case 1:
      DetachImageList();
      struct ImageEntry *IE;
      for ( IE = (struct ImageEntry *) IEList.lh_Head;
            IE->IE_Node.ln_Succ;
            IE = (struct ImageEntry *) IE->IE_Node.ln_Succ, Cnt++ )
      {
        /* Use RemDelProtection() here */

        ULONG stream[] =
        {
          (ULONG) Cnt,
          (ULONG) Total,
          (ULONG) &IE->IE_Name
        };

        PrintStatus("Deleting image %lu of %lu : %.128s", &stream);

        if (DeleteFile( (UBYTE *) IE->IE_FullPath ))
        {
          DelCnt++;
        }
        else
        {
          FailCnt++;
        }
      }
      FreeImageList();
      BuildImageList( TRUE ); /* Rescan in case not all were deleted */

      CreateCFFromIL( CACHEFILENAME );

      ULONG stream[] =
      {
        DelCnt,
        FailCnt
      };

      PrintStatus("Deleted %lu images, %lu failed.", &stream );
      break;
  }
}

/*************************************************
 *
 * Try to find an image entry via its name.
 *
 * Note: This function treats lower and upper
 *       case as the same when searching.
 *
 */

struct ImageEntry *FindImageEntryByName( UBYTE *Name,
                                          struct ImageEntry *ExcludeIE )
{
  struct ImageEntry *IE, *IEFound = NULL;

  /* This function must scan the WHOLE list */

  for ( IE = (struct ImageEntry *) IEList.lh_Head;
        IE->IE_Node.ln_Succ;
        IE = (struct ImageEntry *) IE->IE_Node.ln_Succ )
  {
    if (!Stricmp( (UBYTE *) &IE->IE_Name, Name ))
    {
      IEFound = IE;

      if (IEFound == ExcludeIE)
      {
        IEFound = NULL;
      }
    }
  }
  return IEFound;
}

/*************************************************
 *
 * Get the ordinal index nmber of an IE. Returns
 * -1 on error.
 *
 */

ULONG FindImageEntryIndex( struct ImageEntry *IEToFnd )
{
  if (!IEToFnd) return -1;

  struct ImageEntry *IE; ULONG cnt = 0;

  for ( IE = (struct ImageEntry *) IEList.lh_Head;
        IE->IE_Node.ln_Succ;
        IE = (struct ImageEntry *) IE->IE_Node.ln_Succ )
  {
    if (IE == IEToFnd)
    {
      return cnt;
    }
    cnt++;
  }

  return -1;
}

/*************************************************
 *
 * 
 *
 */

