
/*
 * [!BGN - MACHINE GENERATED - DO NOT EDIT THIS HEADER]
 *
 * Program   : FloppyFlux (Floppy disk backup program)
 * Version   : 1.2
 * File      : Work:Source/!WIP/FloppyFlux/FF_imagecache.c
 * Author    : Andrew Bell
 * Copyright : Copyright © 1999 Andrew Bell
 * Created   : Tuesday 01-Jun-99 23:05:51
 * Modified  : Sunday 27-Jun-99 19:57:22
 * Comment   : Image directory cache routines
 *
 * (Generated with StampSource 1.1 by Andrew Bell)
 *
 * [!END - MACHINE GENERATED - DO NOT EDIT THIS HEADER]
 *
 */

#define FLOPPYFLUX_IMAGECACHE_C

/* Created: Tue/1/Jun/1999 */

#include <FF_include.h>

/* One night, I had a few hours to spare, so I decided to write this
   rather elaborate disk image dir caching system, enjoy... :-)

   These routines help increase dir scanning, esp. on large
   fragmented HDs (like mine!) or a HD with a low buffer count. */

/*************************************************
 *
 * Notes:
 *
 * All cache files should end with #?.cache.
 *
 * Uses buffered dos.library IO routines. These
 * routines are quite slow under version 39 of
 * the dos.library.
 * 
 */

/*************************************************
 *
 * Protos
 *
 */

Prototype BOOL CheckCacheFile( UBYTE *CacheFileName );
BOOL ExtractCacheDirName(UBYTE *CacheFileName, UBYTE *Buf, ULONG BufLen);
Prototype BOOL CreateILFromCF( UBYTE *CacheFileName );
struct CacheTag *CFF_GetTag(struct CacheHeader *CH, UWORD TagID);
Prototype BOOL CreateCFFromIL( UBYTE *CacheFileName );

UBYTE *CFIO_Name;
ULONG CFIO_Amount;
BPTR CFIO_Open( UBYTE *Name );
BOOL CFIO_Close( BPTR FH );
BOOL CFIO_WriteHeader( BPTR FH, ULONG Amount, UWORD Flags, ULONG TotalLen);
ULONG CFIO_WriteTAG( BPTR FH, UWORD TagID );
BOOL CFIO_EndTAG( BPTR FH, ULONG TagPos );
BOOL CFIO_WriteULONG( BPTR FH, ULONG aULONG );
BOOL CFIO_WriteUWORD( BPTR FH, UWORD aUWORD );
BOOL CFIO_WriteBOOL( BPTR FH, BOOL aBOOL );
BOOL CFIO_WriteString( BPTR FH, UBYTE *String );
BOOL CFIO_Align( BPTR FH );

BOOL CFIO_WriteNAMES( BPTR FH );
BOOL CFIO_WriteCOMMENTS( BPTR FH );
BOOL CFIO_WriteLENGTHS( BPTR FH );
BOOL CFIO_WritePACKIDS( BPTR FH );

/*************************************************
 *
 * Determine if there is a valid cache file. If
 * not, we scan the dir as normal.
 *
 * If FALSE is retuned, then dir should be scanned.
 *
 */

BOOL CheckCacheFile( UBYTE *CacheFileName )
{
  BOOL result = FALSE;
  BPTR CacheFileLock, CacheDirLock;
  UBYTE CacheDirName[256];
  struct FileInfoBlock *CacheFileFIB, *CacheDirFIB; 

  if (ExtractCacheDirName(CacheFileName, CacheDirName, 256L))
  {
    if (CacheFileLock = Lock(CacheFileName, SHARED_LOCK))
    {
      if (CacheDirLock = Lock(CacheDirName, SHARED_LOCK))
      {
        if (CacheFileFIB = AllocDosObject(DOS_FIB, NULL))
        {
          if (CacheDirFIB = AllocDosObject(DOS_FIB, NULL))
          {
            if (Examine(CacheFileLock, CacheFileFIB) && Examine(CacheDirLock, CacheDirFIB))
            {
              LONG cdr = CompareDates(&CacheFileFIB->fib_Date, &CacheDirFIB->fib_Date);

              if (cdr < 0) /* Is date1 is later than date2? */
              {
                result = TRUE; /* Don't update cache file */
              }
              else
              {
                result = FALSE; /* Do update cache file */
              }
            }
            else FFDOSError(NULL, NULL);

            FreeDosObject(DOS_FIB, CacheDirFIB);
          }
          else FFDOSError(NULL, NULL);

          FreeDosObject(DOS_FIB, CacheFileFIB);
        }
        else FFDOSError(NULL, NULL);

        UnLock(CacheDirLock);
      }
      else if (IoErr() != ERROR_OBJECT_NOT_FOUND)
      {
        FFDOSError(NULL, NULL);
      }
      UnLock(CacheFileLock);
    }
    else if (IoErr() != ERROR_OBJECT_NOT_FOUND)
    {
      FFDOSError(NULL, NULL);
    }
  }
  return result;
}

/*************************************************
 *
 * This routine basically removes the ".cache"
 * suffix on a filename.
 *
 */

BOOL ExtractCacheDirName(UBYTE *CacheFileName, UBYTE *Buf, ULONG BufLen)
{
  if (BufLen < 256) return FALSE;

  ULONG Len = strlen(CacheFileName);
  if (Len <= 6) return FALSE; /* #?.cache would not fit */

  if (!Stricmp(CacheFileName + (Len - 6), ".cache"))
  {
    memcpy(Buf, CacheFileName, Len - 6);
    Buf[Len - 6] = 0;
    return TRUE;
  }
  else return FALSE; 
}


/*************************************************
 *
 * Build the entire image list from the cache file
 * instead of scanning the whole directory.
 *
 */

BOOL CreateILFromCF( UBYTE *CacheFileName ) /* UNTESTED */
{
  PrintStatus("Reading cache file...", NULL);

  FreeImageList(); InitImageList();

  BOOL result = FALSE;
  BPTR CFLock = Lock(CacheFileName, SHARED_LOCK);
  if (CFLock)
  {
    struct FileInfoBlock *FIB = AllocDosObject(DOS_FIB, NULL);
    if (FIB)
    {
      if (Examine(CFLock, FIB))
      {
        if (FIB->fib_Size)
        {
          struct CacheHeader *CH = (struct CacheHeader *) LoadFileToVec(CacheFileName, NULL);
          if (CH)
          {
            if (!memcmp(CH, CACHEHDR_ID, sizeof(CACHEHDR_ID) - 1 ))
            {
              struct CacheTag *TagNAMES = NULL, *TagCOMMENTS = NULL, *TagLENGTHS = NULL, *TagPACKIDS = NULL;

              TagNAMES = CFF_GetTag(CH, TAGID_NAMES);
              TagCOMMENTS = CFF_GetTag(CH, TAGID_COMMENTS);
              TagLENGTHS = CFF_GetTag(CH, TAGID_LENGTHS);
              TagPACKIDS = CFF_GetTag(CH, TAGID_PACKIDS);

              if (TagNAMES && TagCOMMENTS && TagLENGTHS && TagPACKIDS)
              {
                register UBYTE *NAMESData = (UBYTE *) ++TagNAMES;
                register UBYTE *COMMENTSData = (UBYTE *) ++TagCOMMENTS;
                register ULONG *LENGTHSData = (ULONG *) ++TagLENGTHS;
                register ULONG *PACKIDSData = (ULONG *) ++TagPACKIDS;

                register ULONG cnt = 0; LENGTHSData++; PACKIDSData++;

                while(cnt < CH->CHDR_Amount)
                {
                  AddImageEntry( NAMESData + 1, COMMENTSData + 1, *LENGTHSData, *PACKIDSData, TRUE);

                  NAMESData += *NAMESData++;
                  COMMENTSData += *COMMENTSData++;
                  LENGTHSData++;
                  PACKIDSData++;

                  cnt++;
                }
                result = TRUE;

                PrintStatus("Cache contains %lu entries.", &cnt );
              }
            }
            MyFreeVec(CH);
          }
        }
      }
      FreeDosObject(DOS_FIB, FIB);
    }
    else FFDOSError(NULL, NULL);

    UnLock(CFLock);
  }
  else FFDOSError(NULL, NULL);

  return result;
}

/*************************************************
 *
 * Locate a tag structure inside a cache file. The
 * whole cache file must be in memory. Set CH to
 * point to it.
 *
 */

struct CacheTag *CFF_GetTag(struct CacheHeader *CH, UWORD TagID)
{
  struct CacheTag *CT = (struct CacheTag *) (CH + 1);

  while ((CT->CTAG_TagID != TAGID_ENDTAG) &&
          (((ULONG)CT) < ((ULONG)CH) + CH->CHDR_Length))
  {
    if (CT->CTAG_TagID == TagID)
    {
      return CT;
    }
    ((ULONG)CT) += CT->CTAG_Length; CT++; 
  }
  return NULL;
}

/*************************************************
 *
 * This routine creates a new cache file using the
 * image list. It is normally called when FF quits.
 *
 */

BOOL CreateCFFromIL( UBYTE *CacheFileName )
{
  BOOL result = FALSE;

  PrintStatus("Updating cache file...", NULL);

  BPTR FH;

  if (FH = CFIO_Open( CacheFileName ))
  {
    CFIO_Amount = CountImageList();

    if (CFIO_WriteHeader(FH, 0, 0, 0))
    {
      /*
       *
       * Note: Keep string chunks at the end of the cache file.
       *
       */

      if (CFIO_WriteLENGTHS( FH ))
      {
        if (CFIO_WritePACKIDS( FH ))
        {
          if (CFIO_WriteNAMES( FH ))
          {
            if (CFIO_WriteCOMMENTS( FH ))
            {
              result = TRUE;
            }
          }
        }
      }
    }
    CFIO_Close(FH);
  }
  return result;
}

/*************************************************
 *
 * Open a new cache file.
 *
 */

BPTR CFIO_Open( UBYTE *Name )
{
  CFIO_Name = Name;

  BPTR FH = Open(Name, MODE_NEWFILE);

  if (FH)
  {
    /* Note: SetVBuf() is not enabled on dos.library v39
       meaning buffered IO can be slower! */

    if(SetVBuf(FH, NULL, BUF_FULL, CACHEFHBUFSIZE))
    {
      /* Note: non-zero = error */

      FFDOSError(NULL, NULL);

      Close(FH); FH = 0;
    }
  }
  else FFDOSError(NULL, NULL);

  return FH;
}

/*************************************************
 *
 * Close the cache filehandle.
 *
 */

BOOL CFIO_Close( BPTR FH )
{
  BOOL result = FALSE;
  if (CFIO_WriteTAG(FH, TAGID_ENDTAG) != -1)
  {
    if (Seek(FH, 0, OFFSET_END) != -1)
    {
      ULONG TotalLen = Seek(FH, 0, OFFSET_CURRENT);
      if (TotalLen != -1)
      {
        if (Seek(FH, 0, OFFSET_BEGINNING) != -1)
        {
          result = CFIO_WriteHeader( FH, CFIO_Amount, 0, TotalLen);
        }
      }
    }
    else FFDOSError(NULL, NULL);
  }
  Close(FH);

  if (!result)
  {
    if (!DeleteFile(CFIO_Name))
    {
      FFDOSError(NULL, NULL);
    }
  }

  return result;
}

/*************************************************
 *
 * Write the cache file header.
 *
 */

BOOL CFIO_WriteHeader( BPTR FH, ULONG Amount, UWORD Flags, ULONG TotalLen)
{
  struct CacheHeader CH; setmem(&CH, sizeof(struct CacheHeader), 0);
  memcpy(CH.CHDR_ID, CACHEHDR_ID, 8);
  CH.CHDR_FmtVer = CACHEHDR_VER;
  CH.CHDR_Flags = Flags;
  CH.CHDR_Amount = Amount;
  CH.CHDR_Length = TotalLen;

  if (FWrite(FH, &CH, sizeof(struct CacheHeader), 1) != 1)
  {
    FFDOSError(NULL, NULL);
    return FALSE;
  }
  else
  {
    return TRUE;
  }
}

/*************************************************
 *
 * Start writing a data block.
 *
 */

ULONG CFIO_WriteTAG( BPTR FH, UWORD TagID )
{
  ULONG TagPos = Seek(FH, 0, OFFSET_CURRENT);

  if (TagPos != -1)
  {
    struct CacheTag CT; setmem(&CT, sizeof(struct CacheTag), 0);

    CT.CTAG_TagID = TagID;
    CT.CTAG_Flags = 0;
    CT.CTAG_Length = 0;
    CT.CTAG_CheckSum = 0;

    if (FWrite(FH, &CT, sizeof(struct CacheTag), 1) != 1)
    {
      FFDOSError(NULL, NULL);
      TagPos = -1;
    }
  }
  else FFDOSError(NULL, NULL);

  return TagPos;
}

/*************************************************
 *
 * Finish writing a data block.
 *
 */

BOOL CFIO_EndTAG( BPTR FH, ULONG TagPos )
{
  BOOL result = FALSE;

  if (CFIO_Align(FH))
  {
    ULONG CurPos = Seek(FH, TagPos, OFFSET_BEGINNING);
    if (CurPos != -1)
    {
      struct CacheTag CT; setmem(&CT, sizeof(struct CacheTag), 0);

      if (Read(FH, &CT, sizeof(struct CacheTag)) == sizeof(struct CacheTag))
      {
        if (Seek(FH, TagPos, OFFSET_BEGINNING) != -1)
        {
          CT.CTAG_Length = CurPos - TagPos - sizeof(struct CacheTag);
          if (FWrite(FH, &CT, sizeof(struct CacheTag), 1) == 1)
          {
            if (Seek(FH, 0, OFFSET_END) != -1)
            {
              result = TRUE;
            }
            else FFDOSError(NULL, NULL);
          }
          else FFDOSError(NULL, NULL);
        }
        else FFDOSError(NULL, NULL);
      }
      else FFDOSError(NULL, NULL);
    }
    else FFDOSError(NULL, NULL);
  }
  return result;
}

/*************************************************
 *
 * Write 32 bits (ULONG or LONG) to the cache file.
 *
 */

BOOL CFIO_WriteULONG( BPTR FH, ULONG aULONG )
{
  if (FWrite(FH, &aULONG, 4, 1) == 1)
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
 * Write 16 bits (UWORD or WORD) to the cache file.
 *
 */

BOOL CFIO_WriteUWORD( BPTR FH, UWORD aUWORD )
{
  if (FWrite(FH, &aUWORD, 2, 1) == 1)
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
 * Write a 2 byte BOOL datatype to the cache file.
 *
 */

BOOL CFIO_WriteBOOL( BPTR FH, BOOL aBOOL )
{
  return CFIO_WriteUWORD( FH, (UWORD) aBOOL );
}

/*************************************************
 *
 * Write a string to the cache file.
 *
 */

BOOL CFIO_WriteString( BPTR FH, UBYTE *String )
{
  BOOL result = FALSE;
  UBYTE SLen = (UBYTE) strlen(String) + 1; /* Note: Includes NULL */

  if (FWrite(FH, &SLen, 1, 1) == 1)
  {
    if (FWrite(FH, String, SLen, 1) == 1)
    {
      result = TRUE;
    }
    else FFDOSError(NULL, NULL);
  }
  else FFDOSError(NULL, NULL);

  return result;
}

/*************************************************
 *
 * Align the cache filehandle to the next 32 bits.
 *
 */

BOOL CFIO_Align( BPTR FH )
{
  BOOL result = FALSE;
  ULONG CurPos = Seek(FH, 0, OFFSET_CURRENT);

  if (CurPos != -1)
  {
    ULONG Pad = 0, PadLen = 4 - (CurPos % 4);
    if (PadLen)
    {
      if (FWrite(FH, &Pad, PadLen, 1) == 1)
      {
        result = TRUE;
      }
      else FFDOSError(NULL, NULL);
    }
    else result = TRUE;
  }
  return result;
}

/*************************************************
 *
 * Save the disk image names to the cache file.
 *
 */

BOOL CFIO_WriteNAMES( BPTR FH )
{
  BOOL result = FALSE;
  struct ImageEntry *IE;

  /* Cache the comments */

  ULONG NAMESPos = CFIO_WriteTAG( FH, TAGID_NAMES );

  if (NAMESPos != -1)
  {
    for ( IE = (struct ImageEntry *) IEList.lh_Head;
          IE->IE_Node.ln_Succ;
          IE = (struct ImageEntry *) IE->IE_Node.ln_Succ )
    {
      if (!CFIO_WriteString( FH, (UBYTE *) &IE->IE_Name))
      {
        return result;
      }
    }
    result = CFIO_EndTAG(FH, NAMESPos);
  }
  return result;
}

/*************************************************
 *
 * Save the comment strings to the cache file.
 *
 */

BOOL CFIO_WriteCOMMENTS( BPTR FH )
{
  BOOL result = FALSE;
  struct ImageEntry *IE;

  /* Cache the comments */

  ULONG COMMENTSPos = CFIO_WriteTAG( FH, TAGID_COMMENTS );

  if (COMMENTSPos != -1)
  {
    for ( IE = (struct ImageEntry *) IEList.lh_Head;
          IE->IE_Node.ln_Succ;
          IE = (struct ImageEntry *) IE->IE_Node.ln_Succ )
    {
      if (!CFIO_WriteString( FH, (UBYTE *) &IE->IE_Comment))
      {
        return result;
      }
    }
    result = CFIO_EndTAG(FH, COMMENTSPos);
  }
  return result;
}

/*************************************************
 *
 * Save the array of disk image lengths to the
 * cache file.
 *
 */

BOOL CFIO_WriteLENGTHS( BPTR FH )
{
  BOOL result = FALSE;
  struct ImageEntry *IE;

  /* Cache the lengths */

  ULONG LENGTHSPos = CFIO_WriteTAG( FH, TAGID_LENGTHS );

  if (LENGTHSPos != -1)
  {
    if (CFIO_WriteULONG( FH, CFIO_Amount ))
    {
      for ( IE = (struct ImageEntry *) IEList.lh_Head;
            IE->IE_Node.ln_Succ;
            IE = (struct ImageEntry *) IE->IE_Node.ln_Succ )
      {
        if (!CFIO_WriteULONG( FH, IE->IE_Size ))
        {
          return result;
        }
      }
      result = CFIO_EndTAG(FH, LENGTHSPos);
    }
  }
  return result;
}

/*************************************************
 *
 * Save the array of XPK methods to the cache
 * file.
 *
 */

BOOL CFIO_WritePACKIDS( BPTR FH )
{
  BOOL result = FALSE;
  struct ImageEntry *IE;

  /* Cache the lengths */

  ULONG PACKIDSPos = CFIO_WriteTAG( FH, TAGID_PACKIDS );

  if (PACKIDSPos != -1)
  {
    if (CFIO_WriteULONG( FH, CFIO_Amount ))
    {
      for ( IE = (struct ImageEntry *) IEList.lh_Head;
            IE->IE_Node.ln_Succ;
            IE = (struct ImageEntry *) IE->IE_Node.ln_Succ )
      {
        if (!CFIO_WriteULONG( FH, IE->IE_PackID ))
        {
          return result;
        }
      }
      result = CFIO_EndTAG(FH, PACKIDSPos);
    }
  }
  return result;
}

/*************************************************
 *
 * 
 *
 */
