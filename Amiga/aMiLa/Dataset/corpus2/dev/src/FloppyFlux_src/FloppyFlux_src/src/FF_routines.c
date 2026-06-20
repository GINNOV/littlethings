
/*
 * [!BGN - MACHINE GENERATED - DO NOT EDIT THIS HEADER]
 *
 * Program   : FloppyFlux (Floppy disk backup program)
 * Version   : 1.2
 * File      : Work:Source/!WIP/FloppyFlux/FF_routines.c
 * Author    : Andrew Bell
 * Copyright : Copyright © 1999 Andrew Bell
 * Created   : Wednesday 05-May-99 22:42:29
 * Modified  : Sunday 27-Jun-99 19:57:22
 * Comment   : Assorted routines
 *
 * (Generated with StampSource 1.1 by Andrew Bell)
 *
 * [!END - MACHINE GENERATED - DO NOT EDIT THIS HEADER]
 *
 */

#define FLOPPYFLUX_ROUTINES_C

/* Created: Wed/28/Apr/1999 */

#include <FF_include.h>

/*************************************************
 *
 * Function protos
 *
 */

Prototype ULONG IsFileXPKPacked( UBYTE *FileName );
Prototype APTR MyAllocVec( ULONG Size );
Prototype void MyFreeVec( APTR Vec );
Prototype ULONG GetFileSize( UBYTE *FileName );
Prototype ULONG RawDoFmtSize( UBYTE *FmtString, APTR Fmt );
Prototype BOOL RemDelProtection( UBYTE *FileName, BOOL Force );
Prototype BOOL IsFileNameValid( UBYTE *FileName );
Prototype void PrintComment( void );
Prototype void PrintStatus( UBYTE *String, APTR Fmt );
Prototype void FFXPKError( LONG xpkerrcode, UBYTE *Body, void *BodyFmt );
Prototype void FFDOSError( UBYTE *Body, void *BodyFmt );
Prototype void FFError( UBYTE *Body, void *BodyFmt );
Prototype ULONG FFInformation(UBYTE *Body, void *BodyFmt);
Prototype ULONG FFRequest(UBYTE *Body, void *BodyFmt, UBYTE *Gads);
Prototype ULONG FFPopup(UBYTE *Title, UBYTE *Body, void *BodyFmt, UBYTE *Gads);
Prototype BOOL PackMemory(APTR Mem, ULONG MemSize, ULONG *PackedMem, ULONG *PackedSize, struct ProgressHandle *PH );
Prototype BOOL UnpackMemory(APTR Mem, ULONG MemSize, ULONG *UnpackedMem, ULONG *UnpackedSize, struct ProgressHandle *PH );
Prototype BOOL AslAddPart( struct FileRequester *FR, struct WBArg *WA, UBYTE *Buf, ULONG BufLen );
Prototype BOOL PackFile( UBYTE *FileName, BOOL ShowProgress );
Prototype BOOL UnpackFile( UBYTE *FileName, BOOL ShowProgress );
Prototype BOOL CopyFileAndUnpack( UBYTE *SrcName, UBYTE *DestName, struct FileInfoBlock *GFIB );
Prototype BOOL CopyFileAndPack( UBYTE *SrcName, UBYTE *DestName, struct FileInfoBlock *GFIB );
Prototype BOOL CopyFile( UBYTE *SrcName, UBYTE *DestName, struct FileInfoBlock *GFIB  );
Prototype BOOL MoveFile( UBYTE *SrcName, UBYTE *DestName, struct FileInfoBlock *GFIB  );
Prototype BOOL GetFIB( UBYTE *FileName, struct FileInfoBlock *FIB );
Prototype APTR LoadFileToVec( UBYTE *Filename, ULONG *Length );
Prototype BOOL SaveFile( UBYTE *FileName, APTR Mem, ULONG MemLen );
Prototype UBYTE *FindTempFile( UBYTE *PathString );
Prototype void FreeTempFile( UBYTE *TempNameBuf );
Prototype void FlushMsgPort( struct MsgPort *MP );
Prototype ULONG GetTasksStackSize( void );

/*************************************************
 *
 * Data protos
 *
 */

/*************************************************
 *
 * Determine if a file is packed with XPK.
 *
 */

ULONG IsFileXPKPacked( UBYTE *FileName )
{
  ULONG Result = -1;

  /* At one time this function used XpkExamineTags() to see if
     file was XPK packed, but that method resulted in a catch-22
     situation. So I just decided to implement this method :) */

  ULONG Header[3] = { -1, -1, -1 };

  BPTR TestHandle;

  if (TestHandle = Open( FileName, MODE_OLDFILE ))
  {
    if (Read(TestHandle, &Header, 12) == 12)
    {
      if (Header[0] == 'XPKF')
      {
        Result = Header[2];  /* File is XPK packed */
      }
      else 
      {
        Result = NULL; /* No, file is not XPK packed */
      }
    }
    else FFDOSError(NULL, NULL);

    Close( TestHandle );
  }
  else if (IoErr() != ERROR_OBJECT_NOT_FOUND)
  {
    FFDOSError(NULL, NULL);
  }

  return Result; /* NULL=No, -1=Fail else MethodID is in ULONG */
}

/*************************************************
 *
 * Allocate a vector using the internal memory
 * pool.
 *
 */

APTR MyAllocVec( ULONG Size )
{
  Size += 4; ULONG *Vec = AllocPooled( MemPool, Size );

  if ( Vec ) *Vec++ = Size;

  return (APTR) Vec;
}

/*************************************************
 *
 * Free a vector that was allocated by the
 * MyAllocVec() function.
 *
 */

void MyFreeVec( APTR Vec )
{
  if ( Vec ) FreePooled(MemPool, ((UBYTE *) Vec) - 4, ((ULONG *) Vec)[-1] );
}

/*************************************************
 *
 * Get the length of a file, returns -1 on an
 * error.
 *
 */

ULONG GetFileSize( UBYTE *FileName )
{
  ULONG Size = -1;

  BPTR TestLock = Lock( FileName, SHARED_LOCK );

  if (TestLock)
  {
    struct FileInfoBlock *FIB = AllocDosObject(DOS_FIB, NULL);

    if (FIB)
    {
      if (Examine(TestLock, FIB))
      {
        Size = FIB->fib_Size;
      }
      else FFDOSError(NULL, NULL);

      FreeDosObject(DOS_FIB, FIB);
    }
    else FFDOSError(NULL, NULL);

    UnLock(TestLock);
  }
  else FFDOSError(NULL, NULL);

  return Size;  /* On error -1 is returned */
}

/*************************************************
 *
 * Calculate the amount of bytes required by
 * exec.library/RawDoFmt() for it's output buffer.
 *
 */

ULONG RDFSize = NULL;

__geta4 __asm void CalRDFSize( __d0 UBYTE Ch, __a3 UBYTE *ChDest )
{
  ChDest++; RDFSize++; /* A dummy write back hook that just counts */
}

ULONG RawDoFmtSize( UBYTE *FmtString, APTR Fmt )
{
  RDFSize = NULL;
  UBYTE FmtBuf[256]; /* Just in case :) */
  RawDoFmt(FmtString, Fmt, (void *) &CalRDFSize, &FmtBuf);
  RDFSize++;         /* Room for NULL termination */
  return RDFSize;
}

/*************************************************
 *
 * Remove the delete protection from a file, ask
 * user first, if required.
 *
 */

BOOL RemDelProtection( UBYTE *FileName, BOOL Force )
{
  /* If Force is set to TRUE, then no warning requester is displayed */

  BOOL Result = FALSE;
  BPTR TestLock;
  UBYTE *ErrStr = "Unable to see if file is delete protected";

  if (TestLock = Lock(FileName, SHARED_LOCK))
  {
    struct FileInfoBlock *FIB;

    if (FIB = (struct FileInfoBlock *) AllocDosObject(DOS_FIB, NULL))
    {
      if (Examine(TestLock, FIB))
      {
        if (FIB->fib_Protection & FIBF_DELETE)
        {
          ULONG stream = (ULONG) FilePart(FileName);

          if (Force) goto REMOVEIT;

          switch (FFRequest("File '%s' is protected from deletion.\n"
                    "Remove the protection?", &stream, "Remove it|Whoops!"))
          {
            default:  /* Whoops */
            case 0:
              Result = FALSE; /* User backed out of deletion, don't delete! */
              break;

            REMOVEIT:
            case 1: /* Remove it */
              if (SetProtection(FileName, FIB->fib_Protection & ~FIBF_DELETE))
              {
                Result = TRUE;
              }
              else FFDOSError( "Failed to change file's protection bits!", NULL );
              break;
          }
        }
        else Result = TRUE; /* File is not protected, go ahead an delete it */
      }
      else FFDOSError( "Failed to examine file to see if it was delete protected!", NULL );

      FreeDosObject(DOS_FIB, FIB);
    }
    else FFDOSError( ErrStr, NULL );

    UnLock(TestLock);
  }
  else if (IoErr() == ERROR_OBJECT_NOT_FOUND)
  {
    Result = TRUE;
  }
  else FFDOSError( ErrStr, NULL );

  return Result; /* FALSE = Don't delete/error, TRUE = prot rem'd */
}

/*************************************************
 *
 * Determine if an AmigaDOS filename is valid. I'm
 * sure there's a better way of doing this!
 *
 */

BOOL IsFileNameValid( UBYTE *FileName )
{
  BOOL Result = TRUE;

  while( *FileName )
  {
    switch( *FileName )
    {
      case ':': /* Typical chars that would make a file name invalid */
      case '/':
      case '#': /* #, ?, and | would mess up DOS wildcards */
      case '?':
      case '|':
        Result = FALSE; /* FALSE means filename IS invalid */
        break;
      default:
        break;
    }
    FileName++;
  }
  return Result;
}

/*************************************************
 *
 * Print the comment of an ImageEntry to the status
 * gadget.
 *
 */

void PrintComment( void )
{
  ULONG Selected = (ULONG) LT_GetAttributes( MainWindowHandle, GID_LIST,
                            TAG_DONE );

  if (Selected != -1)
  {
    struct ImageEntry *IE = GetImageEntry( Selected );

    if ( IE )
    {
      UBYTE *CmtStr = NULL;

      if (*IE->IE_Comment)
      {
        CmtStr = (UBYTE *) &IE->IE_Comment;
      }
      else
      {
        CmtStr = "(empty)";
      }
      PrintStatus("Comment: %.82s", &CmtStr);
    }
  }
}

/*************************************************
 *
 * Print a string in the main window's status gadget.
 *
 */

UBYTE PrintStatusBuf[256]; /* Use this buffer to hold string until next call */

void PrintStatus( UBYTE *String, APTR Fmt )
{
  if (!MainWindowHandle) return;

  RawDoFmt(String, Fmt, &putchproc, (UBYTE *) &PrintStatusBuf);

  LT_SetAttributes(MainWindowHandle, GID_STATUS,
    GTTX_Text, &PrintStatusBuf,
    TAG_DONE);
}

/*************************************************
 *
 * Show an error requester for an XPK related error.
 *
 */

void FFXPKError( LONG xpkerrcode, UBYTE *Body, void *BodyFmt )
{
  UBYTE BodyFmtBuf[256];
  RawDoFmt(Body, BodyFmt, &putchproc, (UBYTE *) &BodyFmtBuf);

  UBYTE XPKErrStr[82];
  XpkFault( xpkerrcode, "", (UBYTE *) &XPKErrStr, 80L );

  ULONG stream[] =
  {
    (ULONG) &BodyFmtBuf,
    (ULONG) xpkerrcode,
    (ULONG) &XPKErrStr
  };

  FFPopup("FloppyFlux XPK Error",
          "%s\n"
          "\n"
          "XPK error code %ld %s", &stream, "Abort");
}


/*************************************************
 *
 * Display DOS releated error, DOS error code and
 * string is append to end of text.
 *
 */

void FFDOSError( UBYTE *Body, void *BodyFmt )
{
  UBYTE BodyFmtBuf[256];

  if (!Body) Body = "Encountered a problem with dos.library!";

  RawDoFmt(Body, BodyFmt, &putchproc, (UBYTE *) &BodyFmtBuf);

  ULONG DOSErrCode = IoErr();
  UBYTE DOSErrStr[82];
  Fault( DOSErrCode, "", (UBYTE *) &DOSErrStr, 80L );

  ULONG stream[] =
  {
    (ULONG) &BodyFmtBuf,
    (ULONG) DOSErrCode,
    (ULONG) &DOSErrStr
  };

  FFPopup("FloppyFlux DOS Error", "%s\n\nDOS error code %lu %s", &stream, "Abort");
}

/*************************************************
 *
 * Display a simple error requester.
 *
 */

void FFError( UBYTE *Body, void *BodyFmt )
{
  FFPopup("FloppyFlux Error", Body, BodyFmt, "Abort");
}

/*************************************************
 *
 * Display a simple information requester.
 *
 */

ULONG FFInformation(UBYTE *Body, void *BodyFmt)
{
  return FFPopup("FloppyFlux Information...", Body, BodyFmt, "Continue");
}

/*************************************************
 *
 * Display a simple requester.
 *
 */

ULONG FFRequest(UBYTE *Body, void *BodyFmt, UBYTE *Gads)
{
  return FFPopup("FloppyFlux Request...", Body, BodyFmt, Gads);
}

/*************************************************
 *
 * Display a requester, with custom title.
 *
 */

ULONG FFPopup(UBYTE *Title, UBYTE *Body, void *BodyFmt, UBYTE *Gads)
{
  if (SysBase->LibNode.lib_Version < 36) return NULL;

  struct EasyStruct LMEZ =
  {
    sizeof(struct EasyStruct),
    0,
    Title,
    Body,
    Gads
  };

  /* Note: If window is NULL, then req will default to WB */
  return EasyRequestArgs(MainWindow, &LMEZ, NULL, BodyFmt);
}

/*************************************************
 *
 * Simple way to pack a region of memory using XPK.
 *
 */

BOOL PackMemory(APTR Mem, ULONG MemSize, ULONG *PackedMem, ULONG *PackedSize, struct ProgressHandle *PH )
{
  XPKProgressHook.h_Data = (APTR) PH;

  *PackedMem = NULL;
  *PackedSize = NULL;

  ULONG VecSize = MemSize+MemSize/32+2*XPK_MARGIN;
  APTR Vec = MyAllocVec( VecSize );

  if (!Vec) return FALSE;

  ULONG PSize = NULL;

  LONG xpkerr = XpkPackTags(XPK_PackMethod, (UBYTE *) &FFC.FFC_XPKMethod,
                            XPK_PackMode,   FFC.FFC_XPKMode,
                            XPK_InBuf,      (ULONG) Mem,
                            XPK_InLen,      MemSize,
                            XPK_OutBuf,     Vec,
                            XPK_OutBufLen,  VecSize,
                            XPK_GetOutLen,  &PSize,
                            XPK_ChunkHook,  &XPKProgressHook,
                            XPK_ChunkSize,  XpkChunkSize,
                            TAG_DONE);

  XPKProgressHook.h_Data = NULL;

  if (xpkerr == XPKERR_OK)
  {
    *PackedMem = (ULONG) Vec;
    *PackedSize = PSize;
    return TRUE;
  }
  else if (xpkerr == XPKERR_ABORTED)
  {
    PrintStatus("Operation aborted.", NULL);
    MyFreeVec(Vec);
    return FALSE;
  }
  else
  {
    FFXPKError(xpkerr, "Unable to pack data", NULL);

    MyFreeVec(Vec);
    return FALSE;
  }
}

/*************************************************
 *
 * Simple way to unpack a region of memory using XPK.
 *
 */

BOOL UnpackMemory(APTR Mem, ULONG MemSize, ULONG *UnpackedMem, ULONG *UnpackedSize, struct ProgressHandle *PH )
{
  BOOL result = FALSE;
  APTR UnpackBuf = NULL;
  ULONG UnpackBufLen, UnpackLen;

  XPKProgressHook.h_Data = (APTR) PH;

  LONG xpkerr = XpkUnpackTags(
                  XPK_InBuf,       Mem,
                  XPK_InLen,       MemSize,

                  XPK_GetOutBuf,    &UnpackBuf,       /* Buffer location             */
                  XPK_GetOutBufLen, &UnpackBufLen,    /* Buffer length for FreeMem() */
                  XPK_GetOutLen,    &UnpackLen,       /* Actual file save length     */
                  XPK_ChunkHook,    &XPKProgressHook,
                  TAG_DONE );

  if ((xpkerr == XPKERR_OK) && UnpackLen)
  {
    *UnpackedSize = UnpackLen;
    *UnpackedMem = (ULONG) MyAllocVec(UnpackLen);

    if (*UnpackedMem)
    {
      /* This uses loads of memory :) Just to get it into a vector! */
      CopyMem(UnpackBuf, (APTR) *UnpackedMem, UnpackLen);

      result = TRUE;
    }
  }
  else if (xpkerr != XPKERR_OK)
  {
    FFXPKError( xpkerr, "Failed to unpack data", NULL );
  }
  else FFError("Error while unpacking", NULL);

  if (UnpackBuf)
  {
    FreeMem(UnpackBuf, UnpackBufLen);
  }

  return result;
}

/*************************************************
 *
 * Quickly build a path using ASL filereq / WBArg.
 *
 */

BOOL AslAddPart( struct FileRequester *FR, struct WBArg *WA, UBYTE *Buf, ULONG BufLen )
{
  if (!FR || !WA || !Buf || !BufLen) return FALSE;

  strncpy(Buf, FR->fr_Drawer, BufLen);

  if (AddPart(Buf, WA->wa_Name, BufLen))
  {
    return TRUE;
  }
  else
  {
    FFDOSError(NULL, NULL);
    return FALSE;
  }
}

/*************************************************
 *
 * Pack a file using the current FF config settings.
 * If it's already packed, then user will be asked
 * if it should be repacked.
 *
 * This routine overwrites the orginal file.
 *
 */

BOOL PackFile( UBYTE *FileName, BOOL ShowProgress )
{
  BOOL result = FALSE;
  ULONG FileLen = 0; APTR FileVec = 0;

  RemDelProtection( FileName, TRUE );

  FileVec = LoadFileToVec( FileName, &FileLen );

  if (!FileVec) return FALSE;

  if (IsFileXPKPacked( FileName ))
  {
    struct ProgressHandle *PH = NULL;
    if (ShowProgress) PH = OpenProgressWindow(100L, "Unpacking...");

    APTR TmpFileVec = NULL;
    ULONG TmpFileLen = 0;

    if (UnpackMemory(FileVec, FileLen, (ULONG *) &TmpFileVec, (ULONG *) &TmpFileLen, PH ))
    {
      MyFreeVec(FileVec);

      FileVec = TmpFileVec; FileLen = TmpFileLen;
    }
    else
    {
      MyFreeVec(FileVec); FileVec = NULL;
    }
    if (ShowProgress) CloseProgressWindow( PH );
  }

  /* At this point, FileVec should point to an unpacked file in memory, and
     FileLen should contain the length of that file. If FileVec == NULL,
     then something went wrong. */

  APTR PackedFileVec = 0;
  ULONG PackedFileLen = 0;

  if (FileVec)
  {
    struct ProgressHandle *PH = NULL;
    if (ShowProgress) PH = OpenProgressWindow(100L, "Packing...");

    if (PackMemory(FileVec, FileLen, (ULONG *) &PackedFileVec, (ULONG *) &PackedFileLen, PH ))
    {
      UBYTE TmpPath[256]; strcpy( (UBYTE *) &TmpPath, FileName);
      *PathPart((UBYTE *) &TmpPath) = 0;

      /* We save save to a temp file so that we don't lose data */

      UBYTE *TmpFile = FindTempFile( (UBYTE *) &TmpPath );

      if (TmpFile)
      {
        if (SaveFile(TmpFile, PackedFileVec, PackedFileLen))
        {
          if (DeleteFile(FileName))
          {
            result = Rename(TmpFile, FileName);
          }
          else FFDOSError(NULL, NULL);

        }
        FreeTempFile( TmpFile );
      }
    }
    if (ShowProgress) CloseProgressWindow( PH );
  }

  if (!result) DisplayBeep(NULL);
  if (PackedFileVec) MyFreeVec(PackedFileVec);
  if (FileVec) MyFreeVec(FileVec);

  return result;
}

/*************************************************
 *
 * Unpack an XPK packed file.
 *
 * This routine overwrites the orginal file.
 *
 */

BOOL UnpackFile( UBYTE *FileName, BOOL ShowProgress )
{
  BOOL result = FALSE;

  RemDelProtection( FileName, TRUE );

  if (IsFileXPKPacked( FileName ))
  {
    ULONG FileLen = 0; APTR FileVec = LoadFileToVec(FileName, &FileLen);

    if (FileVec)
    {
      ULONG UnpackFileLen = 0; APTR UnpackFileVec = 0;

      struct ProgressHandle *PH = NULL;
      if (ShowProgress) PH = OpenProgressWindow(100L, "Unpacking...");

      if (UnpackMemory(FileVec, FileLen, (ULONG *) &UnpackFileVec, (ULONG *) &UnpackFileLen, PH))
      {
        if (SaveFile( FileName, UnpackFileVec, UnpackFileLen ))
        {
          result = TRUE;
        }
        MyFreeVec(UnpackFileVec);
      }
      if (ShowProgress) CloseProgressWindow( PH );

      MyFreeVec(FileVec);
    }
  }
  return result;
}

/*************************************************
 *
 * Copy file and unpack it with XPK.
 *
 */

BOOL CopyFileAndUnpack( UBYTE *SrcName, UBYTE *DestName, struct FileInfoBlock *GFIB )
{
  if (XpkBase && IsFileXPKPacked( SrcName ))
  {
    /* Yes, it's packed */

    LONG xpkerr = XpkUnpackTags( XPK_InName, SrcName,
                                 XPK_OutName, DestName,
                                 XPK_ChunkSize, XpkChunkSize,
                                 TAG_DONE);

    if (xpkerr == XPKERR_OK)
    {
      if (GFIB) GetFIB( DestName, GFIB );

      return TRUE;
    }
    else
    {
      FFXPKError(xpkerr, "Unable to unpack file", NULL);

      return FALSE;
    }
  }
  else
  {
    /* No, it's not packed */

    return CopyFile(SrcName, DestName, GFIB);
  }
}

/*************************************************
 *
 * Copy file and pack it with XPK.
 *
 */

BOOL CopyFileAndPack( UBYTE *SrcName, UBYTE *DestName, struct FileInfoBlock *GFIB )
{
  if (!XpkBase) return FALSE;

  if (IsFileXPKPacked(SrcName))
  {
    return CopyFile(SrcName, DestName, GFIB);
  }
  else
  {
    LONG xpkerr = XpkPackTags( XPK_InName,     SrcName,
                               XPK_OutName,    DestName,
                               XPK_ChunkSize,  XpkChunkSize,
                               XPK_PackMethod, (UBYTE *) &FFC.FFC_XPKMethod,
                               XPK_PackMode,   FFC.FFC_XPKMode,
                               TAG_DONE);

    if (xpkerr == XPKERR_OK)
    {
      BOOL Result = FALSE;

      struct FileInfoBlock *FIB = AllocDosObject(DOS_FIB, NULL);

      if (FIB)
      {
        if (GetFIB(DestName, FIB))
        {
          if (GFIB)
          {
            CopyMem(FIB, GFIB, sizeof(struct FileInfoBlock));
          }

          if (!SetComment(DestName, (UBYTE *) &FIB->fib_Comment))
          {
            FFDOSError(NULL, NULL);
          }

          Result = TRUE;
        }
        FreeDosObject(DOS_FIB, FIB);
      }
      else FFDOSError(NULL, NULL);

      return Result;
    }
    else
    {
      /* Try to copy the file unpacked */

      FFXPKError( xpkerr, "Failed to pack file", NULL );

      return CopyFile(SrcName, DestName, GFIB);
    }
  }
}

/*************************************************
 *
 * Copy a file from A to B in 128KB chunks.
 *
 */

/* Example: CopyFile("c:filename","dh3:stuff/filename")
   TODO: Copy protection bits. */

BOOL CopyFile( UBYTE *SrcName, UBYTE *DestName, struct FileInfoBlock *GFIB )
{
  /* Note: If the GFIB pointer is non-NULL, then SrcFile's FileInfoBlock
           will be copied to this pointer. Make sure there is at least
           sizeof(struct FileInfoBlock) bytes free at this pointer, or
           use AllocDosObject(DOS_FIB, ...) to get the memory.

           Don't examine the FIB if this function fails. */

  #define CF_CHKSIZE (1024*128)

  BOOL Result = TRUE;
  BPTR TestLock = Lock(SrcName, SHARED_LOCK);

  if (TestLock)
  {
    struct FileInfoBlock *FIB = AllocDosObject(DOS_FIB, NULL);

    if (FIB)
    {
      if (Examine(TestLock, FIB))
      {
        if (GFIB)
        {
          CopyMem(FIB, GFIB, sizeof(struct FileInfoBlock));
        }

        ULONG FileLength = FIB->fib_Size;

        if (FileLength)
        {
          ULONG AmtChunks = FileLength / CF_CHKSIZE;
          ULONG Remainder = FileLength % CF_CHKSIZE;

          APTR CpyBuf = MyAllocVec(CF_CHKSIZE);

          if (CpyBuf)
          {
            RemDelProtection( DestName, TRUE );

            BPTR InFile = NULL, OutFile = NULL;

            InFile = Open(SrcName, MODE_OLDFILE);
            OutFile = Open(DestName, MODE_NEWFILE);

            if (InFile && OutFile)
            {
              while (AmtChunks--)
              {
                if (Read(InFile, CpyBuf, CF_CHKSIZE) != CF_CHKSIZE)
                {
                  FFDOSError(NULL, NULL);
                  Result = FALSE; break;
                }
                

                if (Write(OutFile, CpyBuf, CF_CHKSIZE) != CF_CHKSIZE)
                {
                  FFDOSError(NULL, NULL);
                  Result = FALSE; break;
                }
                
              }

              if (Remainder && Result)
              {
                if (Read(InFile, CpyBuf, Remainder) != Remainder)
                {
                  FFDOSError(NULL, NULL);
                  Result = FALSE;
                }

                if (Write(OutFile, CpyBuf, Remainder) != Remainder)
                {
                  FFDOSError(NULL, NULL);
                  Result = FALSE;
                }
              }
            }
            else FFDOSError(NULL, NULL);

            if (InFile) Close(InFile);
            if (OutFile) Close(OutFile);

            if (!SetComment(DestName, (UBYTE *) &FIB->fib_Comment))
            {
              FFDOSError(NULL, NULL);
            }

            MyFreeVec(CpyBuf);
          }
        }
      }
      else FFDOSError(NULL, NULL);

      FreeDosObject(DOS_FIB, FIB);
    }
    else FFDOSError(NULL, NULL);

    UnLock(TestLock);
  }
  else FFDOSError(NULL, NULL);

  if (!Result)
  {
    DeleteFile(DestName);
  }

  return Result;
}

/*************************************************
 *
 * Move a file from A to B, original is deleted.
 *
 */

BOOL MoveFile( UBYTE *SrcName, UBYTE *DestName, struct FileInfoBlock *GFIB )
{
  /* Note: Refer to FF_routines.c/CopyFile() for more information on the
           GFIB parameter */

  BOOL Result = FALSE;

  if (!Rename(SrcName, DestName))
  {
    if (IoErr() == ERROR_RENAME_ACROSS_DEVICES)
    {
      if (CopyFile(SrcName, DestName, GFIB))
      {
        Result = DeleteFile(SrcName);
      }
    }
    else
    {
      FFDOSError(NULL, NULL);
    }
  }
  return Result;
}

/*************************************************
 *
 * Quickly get a FIB. Note: Does not hold the lock.
 *
 */

BOOL GetFIB( UBYTE *FileName, struct FileInfoBlock *FIB )
{
  if (!FileName || !FIB) return FALSE;

  /* Make sure there is at least sizeof(struct FileInfoBlock) bytes free
     for the FIB pointer. */

  BOOL Result = FALSE;
  BPTR TestLock = Lock(FileName, SHARED_LOCK);

  if (TestLock)
  {
    if (Examine(TestLock, FIB))
    {
      Result = TRUE;
    }
    else FFDOSError(NULL, NULL);

    UnLock(TestLock);
  }
  else FFDOSError(NULL, NULL);

  return Result;
}

/*************************************************
 *
 * Load an entire file to RAM. File must be freed
 * with a call to MyFreeVec()!
 *
 */

APTR LoadFileToVec( UBYTE *FileName, ULONG *Length)
{
  APTR FileVec = NULL;
  struct FileInfoBlock *FIB = AllocDosObject(DOS_FIB, NULL);

  if (FIB)
  {
    if (GetFIB(FileName, FIB))
    {
      if (FIB->fib_Size)
      {
        if (Length) *Length = FIB->fib_Size;
        if (FileVec = MyAllocVec(FIB->fib_Size))
        {
          BPTR InFile = Open(FileName, MODE_OLDFILE);
          if (InFile)
          {
            if (Read(InFile, FileVec, FIB->fib_Size) != FIB->fib_Size)
            {
              MyFreeVec(FileVec); FileVec = NULL;
            }
            Close(InFile);
          }
          else FFDOSError(NULL, NULL);
        }
      }
    }
    FreeDosObject(DOS_FIB, NULL);
  }
  else FFDOSError(NULL, NULL);

  return FileVec;
}

/*************************************************
 *
 * Save data as a file.
 *
 */

BOOL SaveFile( UBYTE *FileName, APTR Mem, ULONG MemLen )
{
  BOOL result = FALSE;
  RemDelProtection( FileName, TRUE );

  BPTR OutFile = Open(FileName, MODE_NEWFILE);
  if (OutFile)
  {
    if (Write(OutFile, Mem, MemLen) == MemLen)
    {
      result = TRUE;
    }
    else FFDOSError(NULL, NULL);

    Close(OutFile);
  }
  else FFDOSError(NULL, NULL);

  if (!result) DeleteFile(FileName);

  return result;
}

/*************************************************
 *
 * Temporary file routines.
 *
 * Pass a string like dh1:data/ and you will get
 * something like FFluxTmp.BE32E031. NULL means we
 * could not find a temp name.
 *
 * Use RemoveTempFile() to release resources.
 *
 * Note:
 *
 * This routine only returns a file name that does
 * not exist in the directory you pass. It does not
 * create the file for you.
 *
 */

UBYTE *FindTempFile( UBYTE *PathString )
{
  /* Bail out after 20 attempts */

  UWORD Attempts = 20;

  /* Leave room for string + suffix + NULL */

  ULONG TempNameLength = strlen( PathString ) + 32;
  UBYTE *TempNameBuf;

  if ( !( TempNameBuf = MyAllocVec( TempNameLength ) ) ) return NULL;

  /*************************************************
   *
   * Half of this is not necassary :)
   *
   */

  do
  {
    ULONG RandomNumber = (( GetUniqueID() * Attempts ) << 24) | 0xDEADBEEF | 0x87654321 ;
    RandomNumber += (ULONG) RangeRand( 65535 );
    RandomNumber << 8;
    RandomNumber += (ULONG) RangeRand( 65535 );
    RandomNumber << 8;
    RandomNumber += (ULONG) RangeRand( 65535 );
    RandomNumber += RangeRand( 65535 ) * RangeRand( 128 );

    strcpy( TempNameBuf, PathString );

    UBYTE NamePart[32];

    RawDoFmt( "FFluxTmp.%08lx", &RandomNumber, &putchproc, NamePart );

    if ( AddPart( TempNameBuf, NamePart, TempNameLength ) )
    {
      register BPTR TestLock;

      if ( TestLock = Lock( TempNameBuf, SHARED_LOCK ) )
      {
        UnLock( TestLock );
      }
      else if (IoErr() == ERROR_OBJECT_NOT_FOUND)
      {
        return TempNameBuf;
      }
      else
      {
        FFDOSError(NULL, NULL);
        FreeTempFile( TempNameBuf );
        return NULL;
      }
    }
    else FFDOSError(NULL, NULL);
  }
  while( --Attempts );

  if ( TempNameBuf ) MyFreeVec( TempNameBuf );

  return NULL;
}

/*************************************************
 *
 * Free the vector returned by FindTempFile().
 * Note: This does NOT delete the temp file.
 *
 */

void FreeTempFile( UBYTE *TempNameBuf )
{
  if ( TempNameBuf )
  {
    MyFreeVec( TempNameBuf );
  }
}

/*************************************************
 *
 * Quick way to flush all messages at a port
 *
 */

void FlushMsgPort( struct MsgPort *MP )
{
  struct Message *Msg;
  while(Msg = GetMsg( MP )) ReplyMsg( Msg );
}

/*************************************************
 *
 * Get FF's current stack size.
 *
 */

ULONG GetTasksStackSize( void )
{
  struct Task *Tsk = FindTask( NULL );
  return (ULONG) Tsk->tc_SPUpper - (ULONG) Tsk->tc_SPLower;
}

/*************************************************
 *
 * 
 *
 */

