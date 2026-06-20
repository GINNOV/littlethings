
/*
 * [!BGN - MACHINE GENERATED - DO NOT EDIT THIS HEADER]
 *
 * Program   : FloppyFlux (Floppy disk backup program)
 * Version   : 1.2
 * File      : Work:Source/!WIP/FloppyFlux/FF_wb.c
 * Author    : Andrew Bell
 * Copyright : Copyright © 1999 Andrew Bell
 * Created   : Monday 21-Jun-99 16:08:00
 * Modified  : Sunday 27-Jun-99 19:57:22
 * Comment   : Workbench related routines
 *
 * (Generated with StampSource 1.1 by Andrew Bell)
 *
 * [!END - MACHINE GENERATED - DO NOT EDIT THIS HEADER]
 *
 */


#define FLOPPYFLUX_WB_C

/* Created: Mon/21/Jun/1999 */

#include <FF_include.h>

/*************************************************
 *
 * Function protos
 *
 */

Prototype BOOL InitWB( void );
Prototype void EndWB( void );
Prototype void ProcessWBMsgs( void );
Prototype BOOL ImportImageViaWB( UBYTE *SrcPath, UBYTE *DestName );

/*************************************************
 *
 * Data protos
 *
 */

Prototype struct MsgPort *WBMP;
Prototype BOOL FromWB;

/*************************************************
 *
 * Data
 *
 */

struct MsgPort *WBMP = NULL;
BOOL FromWB = FALSE;

/*************************************************
 *
 * Setup WB related resources.
 *
 */

BOOL InitWB( void )
{
  if (ThisProcess->pr_CLI)
  {
    FromWB = FALSE;
  }
  else
  {
    FromWB = TRUE;
  }

  if (!(WBMP = CreateMsgPort()))
  {
    return FALSE;
  }
  return TRUE;
}

/*************************************************
 *
 * Free WB related resources
 *
 */

void EndWB( void )
{
  AI_Hide(); /* Hide AppIcon, if it exists. */

  if (WBMP)
  {
    FlushMsgPort( WBMP );
    DeleteMsgPort( WBMP );
    WBMP = NULL;
  }
}

/*************************************************
 *
 * This routine is called when FF has determined
 * that there are messages pending at the WB message
 * port (WBMP) setup by the InitWB() routine.
 *
 */

void ProcessWBMsgs( void )
{
  struct AppMessage *CurAppMsg;

  while( CurAppMsg = (struct AppMessage *) GetMsg( WBMP ) )
  {
    switch(CurAppMsg->am_Type)
    {
      case AMTYPE_APPICON:
        if (!CurAppMsg->am_NumArgs && !CurAppMsg->am_ArgList)
        {
          /* User has just double clicked FF's AppIcon */
          if (!ShowGUI()) DisplayBeep( NULL );
        }
        break;

      case AMTYPE_APPWINDOW:    /* Not supported yet */
        ULONG Cnt = 0, FileCnt = CurAppMsg->am_NumArgs, ActualFileCnt = 0;
        if ( FileCnt )
        {
          struct ProgressHandle *PH = OpenProgressWindow(FileCnt, "Importing from WB...", );
          struct WBArg *WA = CurAppMsg->am_ArgList;
          DetachImageList();
          BOOL AbortLoop = FALSE;

          for ( Cnt = NULL; (Cnt < FileCnt) && !AbortLoop; Cnt++ )
          {
            if (UpdateProgress( PH, Cnt ))
            {
              AbortLoop = TRUE;
              continue;
            }

            /* The (WA->wa_Name != 8) seems to remove a strange WB
               bug, sometimes (on my system) the value 8 is passed
               in the WA->wa_Name field. If it's a feature, it hasn't
               been clearly documented, so I consider it to be a bug! */ 

            if (WA->wa_Lock && (WA->wa_Name != (BYTE *) 8))
            {
              UBYTE PathBuf[256]; PathBuf[0] = 0;
              struct FileInfoBlock *FIB = AllocDosObject(DOS_FIB, NULL);

              if (FIB)
              {
                if (WA->wa_Name && WA->wa_Name[0]) /* We've got a file */
                {
                  if (NameFromLock(WA->wa_Lock, (UBYTE *) &PathBuf, 256L))
                  {
                    if (AddPart((UBYTE *) &PathBuf, WA->wa_Name, 256L))
                    {
                      if (!ImportImageViaWB( (UBYTE *) &PathBuf, WA->wa_Name ))
                      {
                        AbortLoop = TRUE; continue;
                      }
                      else ActualFileCnt++;
                    }
                    else FFDOSError( "Failed to construct object's DOS path", NULL );
                  }
                  else FFDOSError( "Failed to obtain object's name", NULL );
                }
                else /* We've got a dir */
                {
                  /* ToDo: Create a recursive routine
                           that will scan all sub directories. */

                  if (NameFromLock(WA->wa_Lock, (UBYTE *) &PathBuf, 256L))
                  {
                    if (Examine(WA->wa_Lock, FIB))
                    {
                      while (ExNext(WA->wa_Lock, FIB))
                      {
                        if (FIB->fib_DirEntryType < 0)
                        {
                          /* We've got a file */

                          if (AddPart((UBYTE *) &PathBuf, FIB->fib_FileName, 256L))
                          {
                            if (!ImportImageViaWB( (UBYTE *) &PathBuf, (UBYTE *) &FIB->fib_FileName ))
                            {
                              AbortLoop = TRUE; break;
                            }
                            else
                            {
                              *PathPart((UBYTE *) &PathBuf) = 0;
                              ActualFileCnt++;
                            }
                          }
                          else FFDOSError( "Failed to construct object's DOS path", NULL );
                        }
                        else
                        {
                          /* We've got a dir */
                        }
                      }
                      if ((IoErr() != ERROR_NO_MORE_ENTRIES) && !AbortLoop)
                      {
                        FFDOSError( "Failed to scan directory", NULL );
                      }
                    }
                    else FFDOSError( "Failed to examine directory!", NULL );
                  }
                  else FFDOSError( "Failed to obtain object's name", NULL );
                }
                FreeDosObject(DOS_FIB, FIB);
              }
              else FFDOSError( "Failed to allocated a FileInfoBlock!", NULL );
            }
            else
            {
              UBYTE *ObjName = WA->wa_Name;
              if (!ObjName) ObjName = "entry";

              FFError("Cannot import %s, not a valid object!", &ObjName);
            }
            WA++; /* Goto next WBArg entry */
          }

          if (AbortLoop)
          {
            PrintStatus("Operation aborted.", NULL);
          }
          else
          {
            PrintStatus("Operation successful.", NULL);
          }

          AttachImageList();
          CreateCFFromIL( CACHEFILENAME );
          CloseProgressWindow(PH);
          PrintStatus("Imported %lu disk images from WB.", &ActualFileCnt);
        }
        break;

      case AMTYPE_APPMENUITEM:  /* Not supported yet */
      default:
        break; /* We got an unknown message type! */
    }
    ReplyMsg( (struct Message *) CurAppMsg );
  }
}


/*************************************************
 *
 * This routine is called when we import a disk
 * image from WB.
 *
 */

/* If this returns FALSE then abort */

BOOL ImportImageViaWB( UBYTE *SrcPath, UBYTE *DestName )
{
  struct ImageEntry *IE = FindImageEntryByName( DestName, NULL );

  if ( IE )
  {
    switch(FFRequest( "The image %s is already present in the list!\n"
                      "What should I do?", &DestName, "Rename|Skip|Overwrite|Abort"))
    {
      case 0: /* Abort */
        PrintStatus("Operation aborted.", NULL);
        return FALSE;

      case 1: /* Rename */
        if (!(DestName = GetString( DestName )))
        {
          return TRUE; /* If user canceled string, then skip */
        }
        break;

      default:
      case 2: /* Skip */
        return TRUE;

      case 3: /* Overwrite */
        /* Remove the old image, this function will popup a warning
           requester, so we don't have to do it here. */
        DeleteImageEntry( IE );
        break;
    }
  }

  struct FileInfoBlock *TmpFIB = AllocDosObject(DOS_FIB, NULL);
  if (TmpFIB)
  {
    BOOL CopyResult = FALSE;

    UBYTE DIDstPath[256]; DIDstPath[0] = 0;
    strcpy( (UBYTE *) &DIDstPath, IMAGEDIRNAME);

    if (AddPart((UBYTE *) &DIDstPath, DestName, 256L))
    {
      if ( FFC.FFC_UseXPK )
      {
        PrintStatus("Importing and packing %s...", &DestName);

        CopyResult = CopyFileAndPack( SrcPath, (UBYTE *) &DIDstPath, TmpFIB );
      }
      else
      {
        PrintStatus("Importing %s...", &DestName);

        CopyResult = CopyFile( SrcPath, (UBYTE *) &DIDstPath, TmpFIB );
      }
      if ( CopyResult )
      {
        SetImageEntryPackStat( AddImageEntry( DestName,
          (UBYTE *) &TmpFIB->fib_Comment, TmpFIB->fib_Size, -1, FALSE) );
      }
    }
    else FFDOSError( "Failed to construct object's DOS path", NULL );

    if ( !CopyResult )
    {
      FFError("Failed to import:\n\n%s!", &SrcPath);
    }
    FreeDosObject(DOS_FIB, TmpFIB);
  }
  else FFDOSError( "Failed to allocated a FileInfoBlock!", NULL );

  return TRUE;
}

/*************************************************
 *
 * 
 *
 */

