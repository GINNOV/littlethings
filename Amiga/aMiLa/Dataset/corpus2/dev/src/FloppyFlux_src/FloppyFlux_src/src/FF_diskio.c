
/*
 * [!BGN - MACHINE GENERATED - DO NOT EDIT THIS HEADER]
 *
 * Program   : FloppyFlux (Floppy disk backup program)
 * Version   : 1.2
 * File      : Work:Source/!WIP/FloppyFlux/FF_diskio.c
 * Author    : Andrew Bell
 * Copyright : Copyright © 1999 Andrew Bell
 * Created   : Wednesday 05-May-99 22:42:29
 * Modified  : Sunday 27-Jun-99 19:57:22
 * Comment   : Floppy disk control routines
 *
 * (Generated with StampSource 1.1 by Andrew Bell)
 *
 * [!END - MACHINE GENERATED - DO NOT EDIT THIS HEADER]
 *
 */

#define FLOPPYFLUX_DISKIO_C

/* Created: Wed/28/Apr/1999 */

#include <FF_include.h>

/*************************************************
 *
 * Function protos
 *
 */

Prototype BOOL InitTD( ULONG UnitNumber );
Prototype void EndTD( void );
Prototype void MotorOn( void );
Prototype void MotorOff( void );
Prototype BOOL DiskToFile( ULONG UnitNumber, UBYTE *FileName );
Prototype BOOL FileToDisk( ULONG UnitNumber, UBYTE *FileName );
Prototype BOOL DiskToPackedFile( ULONG UnitNumber, UBYTE *FileName );
Prototype BOOL PackedFileToDisk( ULONG UnitNumber, UBYTE *FileName );
Prototype BOOL PromptForDisk( struct IOExtTD *MyIOReq , ULONG UnitID, ULONG PromptMode );

Prototype BOOL GetDiskDetails(UBYTE *DeviceName, UBYTE *Buf, ULONG BufLen, struct InfoData *DestID );

/*************************************************
 *
 * Data protos
 *
 */

/*************************************************
 *
 * Setup the trackdisk related variables for all
 * of the trackdisk related functions.
 *
 */

struct MsgPort *TDMP = NULL;    /* Trackdisk message port */
struct IOExtTD *MyIOReq = NULL;
UBYTE InhibitBuf[32];

BOOL InitTD( ULONG UnitNumber )
{
  PrintStatus("Accessing trackdisk.device unit %lu...",  &UnitNumber );

  sprintf( (UBYTE *) &InhibitBuf, "DF%lu:", UnitNumber);

  if (!Inhibit( (UBYTE *) &InhibitBuf, DOSTRUE))
  {
    FFDOSError("Failed to inhibit %.32s", &InhibitBuf);
    return FALSE;
  }

  if (TDMP = CreateMsgPort())
  {
    if (MyIOReq = (struct IOExtTD *) CreateExtIO(TDMP, sizeof(struct IOExtTD)))
    {
      if (!OpenDevice("trackdisk.device", UnitNumber, (struct IORequest *) MyIOReq, NULL))
      {
        return TRUE;
      }
    }
  }
  return FALSE;
}

/*************************************************
 *
 * Close the trackdisk device.
 *
 */

void EndTD( void )
{
  if (MyIOReq) CloseDevice( (struct IORequest *) MyIOReq );
  if (MyIOReq) DeleteExtIO( (struct IORequest *) MyIOReq );
  if (TDMP) DeleteMsgPort(TDMP);

  Inhibit( (UBYTE *) &InhibitBuf, DOSFALSE);

  MyIOReq = NULL; TDMP = NULL;
}

/*************************************************
 *
 * Turn on the disk motor.
 *
 */

void MotorOn( void )
{
  if (!MyIOReq) return;

  /* Turn the floppy drive motor on. I don't bother checking
     the return values of DoIO() when turning the motor on
     & off, I'am too lazy... */

  MyIOReq->iotd_Req.io_Command = TD_MOTOR;
  MyIOReq->iotd_Req.io_Length = 1;
  DoIO( (struct IORequest *) MyIOReq);
}

/*************************************************
 *
 * Turn off the disk motor.
 *
 */

void MotorOff( void )
{
  if (!MyIOReq) return;

  MyIOReq->iotd_Req.io_Command = TD_MOTOR;
  MyIOReq->iotd_Req.io_Length = 0;
  DoIO( (struct IORequest *) MyIOReq);
}

/*************************************************
 *
 * Disk -> file
 *
 */

BOOL DiskToFile( ULONG UnitNumber, UBYTE *FileName )
{
  BOOL Result = TRUE;

  ULONG ImageSize = STDIMAGESIZE;
  ULONG IOSize    = ImageSize / 16; /* 16 steps, must divide equally into ImageSize */
  BOOL Aborted    = FALSE;

  if (IOSize % TD_SECTOR)
  {
    FFError("Internal error: IOSize is invalid.", NULL); return FALSE;
  }

  struct ProgressHandle *PH = OpenProgressWindow( ImageSize, "Reading disk image" );

  if (InitTD( UnitNumber ))
  {
    if (PromptForDisk( MyIOReq , UnitNumber, PROMPTMODE_READ ))
    {
      PrintStatus( "Reading disk image from unit %lu...", &UnitNumber );

      MotorOn();
      MyIOReq->iotd_Req.io_Offset = NULL;
      UBYTE *MyVec;

      if (MyVec = (UBYTE *) MyAllocVec( IOSize ))
      {
        BPTR OutFile;

        if (OutFile = Open(FileName, MODE_NEWFILE))
        {
          BOOL IgnoreAllErrors = FALSE;

          ULONG cnt = IOSize >> 2;
          ULONG *ptr = (ULONG *) MyVec;
          while (cnt--) *ptr++ = 'BAD!';

          do
          {
            /* Setup the IORequest structure and start transfering data
               to the image memory buffer. */

            MyIOReq->iotd_Req.io_Command = CMD_READ;
            MyIOReq->iotd_Req.io_Length = IOSize;
            MyIOReq->iotd_Req.io_Data = MyVec;

            if (DoIO( (struct IORequest *) MyIOReq))
            {
              LONG TDError = MyIOReq->iotd_Req.io_Error;
              if (!IgnoreAllErrors)
              {
                switch(FFPopup("Disk error...", "Error while reading disk image.\n" "trackdisk.device error %ld\n\n" "Do you want to continue anyway and ignore all future errors?", &TDError, "Yes|No"))
                {
                  /* No */ case 0: Aborted = TRUE; break;
                  /* Yes */ case 1: IgnoreAllErrors = TRUE; break;
                }
              }
            }

            MyIOReq->iotd_Req.io_Offset += IOSize;

            if (Aborted) break;
            else
            {
              if ( Write(OutFile, MyVec, IOSize) != IOSize)
              {
                FFDOSError(NULL, NULL);

                switch (FFPopup("File error", "Error while writing disk image.\n"
                                              "\nDo you want to continue anyway and ignore all future errors?", NULL, "Yes|No"))
                {
                  /* No */ case 0: Aborted = TRUE; break;
                  /* Yes */ case 1: IgnoreAllErrors = TRUE; break;
                }
              }
              else if (UpdateProgress( PH, MyIOReq->iotd_Req.io_Offset ))
              {
                Aborted = TRUE; break;
              }
            }
          }
          while( MyIOReq->iotd_Req.io_Offset < STDIMAGESIZE && Aborted == FALSE);

          Close(OutFile);
        }
        else FFDOSError(NULL, NULL);

        MyFreeVec(MyVec);
      }
      MotorOff();
    }
    else Result = FALSE;
  }
  else
  {
    PrintStatus("Can't access trackdisk.device unit %lu", &UnitNumber);
    Result = FALSE;
  }

  EndTD();

  if (Aborted)
  {
    PrintStatus("Operation was aborted.", NULL);
    DeleteFile(FileName);
    Result = FALSE;
  }
  else if (Result == TRUE)
  {
    PrintStatus("Finished. Image size = %lu bytes", &ImageSize );
  }
  else if (Result == FALSE)
  {
    PrintStatus("Operation was not successful.", &ImageSize );
  }

  CloseProgressWindow( PH );
  return Result;
}

/*************************************************
 *
 * File -> disk
 *
 */

BOOL FileToDisk( ULONG UnitNumber, UBYTE *FileName )
{
  BOOL Result = TRUE;
  ULONG ImageSize = -1;
  PrintStatus("Getting disk image size...", NULL );
  BPTR TestLock = Lock(FileName, SHARED_LOCK);

  if (TestLock)
  {
    struct FileInfoBlock *FIB = AllocDosObject(DOS_FIB, NULL);

    if (FIB)
    {
      if (Examine(TestLock, FIB))
      {
        ImageSize = FIB->fib_Size;
      }
      else FFDOSError(NULL, NULL);

      FreeDosObject(DOS_FIB, FIB);
    }
    else FFDOSError(NULL, NULL);

    UnLock(TestLock);
  }

  if (ImageSize == -1)
  {
    FFError("Failed to get disk image's size.", NULL); return FALSE;
  }

  if (ImageSize < STDIMAGESIZE)
  {
    FFError("Disk image is too small!", NULL); return FALSE;
  }

  if (ImageSize > STDIMAGESIZE) ImageSize = STDIMAGESIZE;

  ULONG IOSize    = ImageSize / 16; /* 16 steps, must divide equally into ImageSize */
  BOOL Aborted    = FALSE;

  if (IOSize % TD_SECTOR)
  {
    FFError("Internal error: IOSize is invalid.", NULL);
    return FALSE;
  }

  struct ProgressHandle *PH = OpenProgressWindow( ImageSize, "Writing disk image" );

  PrintStatus("Accessing trackdisk.device unit %lu...",  &UnitNumber );

  if (InitTD( UnitNumber ))
  {
    if (PromptForDisk( MyIOReq , UnitNumber, PROMPTMODE_WRITE ))
    {
      PrintStatus( "Writing disk image to unit %lu...", &UnitNumber );

      MotorOn();

      MyIOReq->iotd_Req.io_Offset = NULL;
      UBYTE *MyVec;

      if (MyVec = (UBYTE *) MyAllocVec( IOSize ))
      {
        BPTR InFile;

        if (InFile = Open(FileName, MODE_OLDFILE))
        {
          BOOL IgnoreAllErrors = FALSE;
          do
          {
            if ( Read(InFile, MyVec, IOSize) != IOSize)
            {
              FFDOSError(NULL, NULL);

              switch (FFPopup("File error", "Error while reading disk image.\n" "\nDo you want to continue anyway and ignore all future errors?", NULL, "Yes|No"))
              {
                /* No */ case 0: Aborted = TRUE; break;
                /* Yes */ case 1: IgnoreAllErrors = TRUE; break;
              }
            }

            if (Aborted == FALSE)
            {
              /* Setup the IORequest structure and start transfering data
                 to from the image to the disk */

              MyIOReq->iotd_Req.io_Command = CMD_WRITE;
              MyIOReq->iotd_Req.io_Length = IOSize;
              MyIOReq->iotd_Req.io_Data = MyVec;

              if (DoIO( (struct IORequest *) MyIOReq))
              {
                LONG TDError = MyIOReq->iotd_Req.io_Error;

                if (!IgnoreAllErrors)
                {
                  switch(FFPopup("Disk error...", "Error while writing disk image.\n" "trackdisk.device error %ld\n\n" "Do you want to continue anyway and ignore all future errors?", &TDError, "Yes|No"))
                  {
                    /* No */ case 0: Aborted = TRUE; break;
                    /* Yes */ case 1: IgnoreAllErrors = TRUE; break;
                  }
                }
              }
            }
            else break;

            MyIOReq->iotd_Req.io_Offset += IOSize;

            if (Aborted)
            {
              break;
            }
            else if (UpdateProgress( PH, MyIOReq->iotd_Req.io_Offset ))
            {
              Aborted = TRUE; break;
            }
          }
          while( MyIOReq->iotd_Req.io_Offset < STDIMAGESIZE && Aborted == FALSE);

          Close(InFile);
        }
        else FFDOSError(NULL, NULL);

        MyFreeVec(MyVec);
      }
      MotorOff();
    }
    else Result = FALSE;
  }
  else
  {
    PrintStatus("Can't access trackdisk.device unit %lu", &UnitNumber);
    Result = FALSE;
  }

  EndTD();

  if (Aborted)
  {
    PrintStatus("Operation was aborted.", NULL);
    Result = FALSE;
  }
  else if (Result == TRUE)
  {
    PrintStatus("Finished.", &ImageSize );
  }
  else if (Result == FALSE)
  {
    PrintStatus("Operation was not successful.", &ImageSize );
  }

  CloseProgressWindow( PH );

  return Result;
}

/*************************************************
 *
 * Disk -> compressed file
 *
 */

/* This routine is getting a bit big */

BOOL DiskToPackedFile( ULONG UnitNumber, UBYTE *FileName )
{
  if (!XpkBase) return FALSE;

  BOOL Result = TRUE;
  ULONG ImageSize = STDIMAGESIZE;
  ULONG IOSize    = ImageSize / 16; /* 16 steps, must divide equally into ImageSize */
  ULONG IOMemType = MEMF_ANY;
  BOOL Aborted    = FALSE;
  APTR SaveAddr   = NULL; ULONG SaveLen = NULL;

  PrintStatus("Accessing trackdisk.device unit %lu...",  &UnitNumber );

  if (InitTD( UnitNumber ))
  {
    if (PromptForDisk( MyIOReq , UnitNumber, PROMPTMODE_READ ))
    {
      PrintStatus( "Reading disk image from unit %lu...", &UnitNumber );

      MotorOn();

      MyIOReq->iotd_Req.io_Offset = NULL;
      UBYTE *ImageVec;

      if (ImageVec = (UBYTE *) MyAllocVec( ImageSize ))
      {
        UBYTE *LoadPoint = ImageVec;
        BOOL IgnoreAllErrors = FALSE;
        struct ProgressHandle *PH = OpenProgressWindow( ImageSize, "Reading disk image (then packing)" );

        ULONG cnt = ImageSize >> 2;
        ULONG *ptr = (ULONG *) ImageVec;
        while (cnt--) *ptr++ = 'BAD!';

        do
        {
          /* Setup the IORequest structure and start transfering data
             to the image memory buffer. */

          MyIOReq->iotd_Req.io_Command = CMD_READ;
          MyIOReq->iotd_Req.io_Length = IOSize;
          MyIOReq->iotd_Req.io_Data = LoadPoint;

          if ( DoIO( (struct IORequest *) MyIOReq) )
          {
            LONG TDError = MyIOReq->iotd_Req.io_Error;

            if (!IgnoreAllErrors)
            {
              switch(FFPopup("Disk error...", "Error while reading disk image.\n" "trackdisk.device error %ld\n\n" "Do you want to continue anyway and ignore all future errors?", &TDError, "Yes|No"))
              {
                /* No */ case 0: Aborted = TRUE; break;
                /* Yes */ case 1: IgnoreAllErrors = TRUE; break;
              }
            }
          }

          LoadPoint += IOSize;
          MyIOReq->iotd_Req.io_Offset += IOSize;

          if (Aborted)
          {
            break;
          }
          else if (UpdateProgress( PH, MyIOReq->iotd_Req.io_Offset ))
          {
            Aborted = TRUE; break;
          }
        }
        while( MyIOReq->iotd_Req.io_Offset < STDIMAGESIZE && Aborted == FALSE);

        MotorOff();

        CloseProgressWindow( PH ); PH = NULL;

        if (!Aborted) /* If disk reading process what aborted then don't pack! */
        {
          PrintStatus( "Compressing disk image, please wait...", &UnitNumber );

          /* Create progress window title and open window */

          UBYTE ProTitleBuf[64];
          ULONG stream[] = { (ULONG) &FFC.FFC_XPKMethod, (ULONG) FFC.FFC_XPKMode };
          RawDoFmt("Compressing disk image with %.4s.%lu", &stream, &putchproc, &ProTitleBuf);
          struct ProgressHandle *PackPH = OpenProgressWindow( 100L, (UBYTE *) &ProTitleBuf );

          /* Init some variables */

          APTR PackedImageVec = NULL; ULONG PackedImageSize = NULL;

          /* Compress the image */

          if (PackMemory(ImageVec, ImageSize, (ULONG *) &PackedImageVec, (ULONG *) &PackedImageSize, PackPH))
          {
            SaveAddr = PackedImageVec; SaveLen = PackedImageSize;
          }
          else /* We failed to pack the data / or was aborted */
          {
            switch(FFRequest("Compression was aborted.\n"
                              "Do you want to save the disk image uncompressed?", NULL, "Yes|Don't save at all"))
            {
              /* No */ case 0:  SaveAddr = NULL; SaveLen = NULL; Result = FALSE; Aborted = TRUE; break;
              /* Yes */ default: case 1: SaveAddr = ImageVec; SaveLen = ImageSize; break;
            }
          }

          /* Save either a compressed image or a non-compressed image */

          if (Result && SaveAddr)
          {
            BPTR OutFile;
            if (OutFile = Open(FileName, MODE_NEWFILE))
            {
              if (Write(OutFile, SaveAddr, SaveLen) != SaveLen)
              {
                FFDOSError("Could not save disk image!", NULL);
                Result = FALSE;
              }
              Close(OutFile);
            }
            else FFDOSError(NULL, NULL);
          }

          /* If there was an error, delete any left over file */

          if (!Result) DeleteFile(FileName);

          CloseProgressWindow( PackPH ); PackPH = NULL;

          /* Free packed image */

          if (PackedImageVec) MyFreeVec(PackedImageVec);
        }

        /* Free unpacked image */

        MyFreeVec(ImageVec);
      }
    }
    else Result = FALSE;
  }
  else
  {
    PrintStatus("Can't access trackdisk.device unit %lu", &UnitNumber);
    Result = FALSE;
  }

  EndTD();

  if (Aborted)
  {
    PrintStatus("Operation was aborted.", NULL);
    if (!DeleteFile(FileName))
    {
      FFDOSError("Failed to delete object!", NULL);
    }
    Result = FALSE;
  }
  else if (Result == TRUE)
  {
    PrintStatus("Finished. Image size = %lu bytes", &SaveLen );
  }
  else if (Result == FALSE)
  {
    PrintStatus("Operation was not successful.", &ImageSize );
  }

  return Result;
}

/*************************************************
 *
 * Compressed file -> disk
 *
 */

BOOL PackedFileToDisk( ULONG UnitNumber, UBYTE *FileName )
{
  if (!XpkBase) return FALSE;

  BOOL Result = TRUE;
  APTR UnpackBuf = NULL; ULONG UnpackBufLen = NULL, UnpackLen = NULL;

  /* Although an image can be any size, we only used the first
     ((512 * 11) * 160) bytes - STDIMAGESIZE */

  ULONG ImageSize = STDIMAGESIZE;

  struct ProgresHandle *PH = OpenProgressWindow( 100L, "Decompressing disk image" );

  XPKProgressHook.h_Data = (APTR) PH;

  LONG xpkerr = XpkUnpackTags(
                  XPK_InName,       FileName,
                  XPK_GetOutBuf,    &UnpackBuf,       /* Buffer location             */
                  XPK_GetOutBufLen, &UnpackBufLen,    /* Buffer length for FreeMem() */
                  XPK_GetOutLen,    &UnpackLen,       /* Actual file save length     */
                  XPK_ChunkHook,    &XPKProgressHook,
                  TAG_DONE );

  CloseProgressWindow( PH );

  BOOL Aborted = FALSE;

  if ( (UnpackLen < STDIMAGESIZE) &&
       (xpkerr == XPKERR_OK) )
  {
    FFError("Disk image size is too small!", NULL); 
  }
  else if (xpkerr == XPKERR_OK)
  {
    ULONG IOMemType = MEMF_ANY;
    ULONG IOSize    = STDIMAGESIZE / 16; /* 16 steps, must divide equally into ImageSize */

    struct ProgressHandle *PH = OpenProgressWindow( ImageSize, "Writing disk image" );
    PrintStatus("Accessing trackdisk.device unit %lu...",  &UnitNumber );

    if (InitTD( UnitNumber ))
    {
      if (PromptForDisk( MyIOReq , UnitNumber, PROMPTMODE_WRITE ))
      {
        PrintStatus( "Writing disk image to unit %lu...", &UnitNumber );

        MotorOn();
        MyIOReq->iotd_Req.io_Offset = NULL;
        UBYTE *SavePoint = UnpackBuf;
        BOOL IgnoreAllErrors = FALSE;

        do
        {
          /* Setup the IORequest structure and start transfering data
               to from the image to the disk */

          MyIOReq->iotd_Req.io_Command = CMD_WRITE;
          MyIOReq->iotd_Req.io_Length = IOSize;
          MyIOReq->iotd_Req.io_Data = SavePoint;

          if (DoIO( (struct IORequest *) MyIOReq))
          {
            LONG TDError = MyIOReq->iotd_Req.io_Error;
            if (!IgnoreAllErrors)
            {
              switch(FFPopup("Disk error...", "Error while writing disk image.\n" "trackdisk.device error %ld\n\n" "Do you want to continue anyway and ignore all future errors?", &TDError, "Yes|No"))
              {
                /* No */ case 0: Aborted = TRUE; break;
                /* Yes */ case 1:  IgnoreAllErrors = TRUE; break;
              }
            }
          }

          SavePoint += IOSize;
          MyIOReq->iotd_Req.io_Offset += IOSize;

          if (Aborted)
          {
            break;
          }
          else if (UpdateProgress( PH, MyIOReq->iotd_Req.io_Offset ))
          {
            Aborted = TRUE; break;
          }
        }
        while( MyIOReq->iotd_Req.io_Offset < STDIMAGESIZE && Aborted == FALSE);

        MotorOff();
        PrintStatus( "Finished.", NULL );
      }
      else Result = FALSE;
    }
    else
    {
      PrintStatus("Can't access trackdisk.device unit %lu", &UnitNumber);
      Result = FALSE;
    }

    EndTD();

    CloseProgressWindow( PH );
  }
  else if (xpkerr == XPKERR_ABORTED || Aborted)
  {
    PrintStatus("Operation was aborted.", NULL);
    Result = FALSE;
  }
  else
  {
    PrintStatus("XPK decompression failed", NULL);
    Result = FALSE;
  }

  if (UnpackBuf) FreeMem(UnpackBuf, UnpackBufLen);

  XPKProgressHook.h_Data = NULL;

  return Result;
}

/*************************************************
 *
 * Make sure that a disk is in the disk drive.
 * Also make sure that it's write enabled, if
 * required.
 *
 */

BOOL PromptForDisk( struct IOExtTD *MyIOReq , ULONG UnitID, ULONG PromptMode )
{
  /*
   * Check for a disk, prompt user if there's none.
   */
  BOOL DiskInDrive = FALSE;
  BOOL WriteProtected = FALSE;
  BOOL Abort = FALSE;

  MyIOReq->iotd_Req.io_Command = TD_CHANGESTATE;

  UBYTE *ModeStr = "";
  if (PromptMode == PROMPTMODE_WRITE) ModeStr = " write enabled";

  /* Loop until the user insert a disk into the drive */

  for (;;)
  {
    if (!DoIO( (struct IORequest *) MyIOReq))
    {
      if (!MyIOReq->iotd_Req.io_Actual)
      {
        if (PromptMode == PROMPTMODE_READ)
        {
          return TRUE;
        }
        else
        {
          break; /* break out of for (;;) loop */
        }
      }
      else
      {
        ULONG stream[] =
        {
          (ULONG) ModeStr,
          (ULONG) UnitID
        };

        switch(FFRequest("Please insert a%s disk into DF%lu:", &stream, "I will|Abort"))
        {
          default:
          case 0: return FALSE;
          case 1: continue; /* Continue until we get a disk */
        }
      }
    }
    return FALSE;
  }

  for (;;)
  {
    MyIOReq->iotd_Req.io_Command = TD_PROTSTATUS;

    if (!DoIO( (struct IORequest *) MyIOReq))
    {
      if (!MyIOReq->iotd_Req.io_Actual)
      {
        /* Write enabled */

        return TRUE;
      }
      else
      {
        /* Write protected */

        switch(FFRequest("Disk in unit %lu is write protected!", &UnitID, "Retry|Abort"))
        {
          default:
          case 0: return FALSE;
          case 1: continue; /* continue until we get a write enabled disk */
        }
      }
    }
    return FALSE;
  }
  return FALSE; /* Just in case :) */
}

/*************************************************
 *
 * This routine allows us to quickly get obtain
 * a disk's label and it's DiskInfo block. If the
 * DiskInfo block is not required then pass a NULL
 * to the DI parameter.
 *
 */

BOOL GetDiskDetails(UBYTE *DeviceName, UBYTE *Buf, ULONG BufLen, struct InfoData *DestID )
{
  BOOL success = FALSE;

  /* We remove the window pointer (it gets restored
     later) so we don't get a NDOS (etc.) requester :) */

  APTR OldWindowPtr = ThisProcess->pr_WindowPtr;
  ThisProcess->pr_WindowPtr = (APTR) -1;

  BPTR DiskLock = Lock(DeviceName, SHARED_LOCK);

  if (DiskLock)
  {
    struct FileInfoBlock *FIB = AllocDosObject(DOS_FIB, NULL);

    if (FIB)
    {
      if (Examine(DiskLock, FIB))
      {
        strncpy(Buf, (UBYTE *) &FIB->fib_FileName, BufLen);

        if (DestID) /* Get a copy of the InfoData? */
        {
          struct InfoData *ID = MyAllocVec( sizeof(struct InfoData) );

          if (ID) /* Note: InfoData must be LONG aligned */
          {
            if (Info(DiskLock, ID))
            {
              /* Note: We copy the ID to a vector than to the user's buffer,
                       this lets us bypass the DOS alignment restrictions. */

              CopyMem(ID, DestID, sizeof(struct InfoData));

              success = TRUE;
            }
            else FFDOSError(NULL, NULL);

            MyFreeVec(ID);
          }
          FFError("Out of memory!", NULL);
        }
        else success = TRUE;
      }
      else FFDOSError(NULL, NULL);

      FreeDosObject(DOS_FIB, FIB);
    }
    else FFDOSError(NULL, NULL);

    UnLock(DiskLock);
  }
  else FFDOSError(NULL, NULL);

  ThisProcess->pr_WindowPtr = OldWindowPtr;

  return success;
}

