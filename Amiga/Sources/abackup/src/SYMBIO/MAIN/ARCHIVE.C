/*
* This file is part of ABackup.
* Copyright (C) 1999 Denis Gounelle
* 
* ABackup is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* ABackup is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with ABackup.  If not, see <http://www.gnu.org/licenses/>.
*
*/
/*  _______________________________________________________________________

    ABackup 5.0
    archive.c

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 29-Aug-93
    Modified: 15-Mar-98
    _______________________________________________________________________
*/

#include "headers.h"

struct ArcInfo GArcInfo;
LONG DiskNum, IdntDate, ArchiveFmt ;

static BYTE tName[MAXSTR+1], tmp[MAXSTR+1] ;

/*************************************************************************/

void TryToAddToCatalog( struct List *pArc , struct Object *pObj )

/* $DOC
 * FUNCTION
 *	Store the current position as the offset for the given object.
 *	Does nothing if the archive is a device
 * INPUTS
 *	pArc = pointer to an archive, returned by OpenArc()
 *	pObj = pointer to the object
 * $END
 */

{
  struct ArcUnit *pUnit ;

  pUnit = FindCurUnit( pArc ) ;
  if ( pUnit && (pUnit->au_Type != AUT_DEVICE) ) AddToCatalog( pObj , -1 , pUnit->au_CurPos ) ;
}

/*************************************************************************/

BOOL ReadData( struct List *pArc , BYTE *pData , LONG Len )

/* $DOC
 * FUNCTION
 *	Reads data from an archive. This high-level function masks the
 *	difference between the various archive formats.
 * INPUTS
 *	pArc = pointer to an archive, returned by OpenArc()
 *	pData = pointer to the buffer where to put data
 *	Len = number of data bytes to read
 * OUTPUTS
 *	Result = success/failure
 * $END
 */

{
  if ( Len < 1 ) return( TRUE ) ;
  if ( OldArchiveFmt() ) return( ReadOldData( pArc , pData , Len ) ) ;
  return( ReadNewData( pArc , pData , Len ) ) ;
}

/*************************************************************************/

BOOL IsHeader( BYTE *pData )

/* $DOC
 * FUNCTION
 *	Tests if the data block is an archive header (in any archive
 *	format).
 * INPUTS
 *	pData = pointer to the data block to test
 * OUTPUTS
 *	Result = TRUE if data block is an archive format
 * NOTES
 *	The input data block is automatically converted in the new
 *	archive header format
 * $END
 */

{

  if ( OldArchiveFmt() )
  {
    if (! IsOldHeader( (struct OldHeader *)pData , pData )) return( FALSE ) ;
    return( TRUE ) ;
  }

  return( IsNewHeader( (struct Header *)pData ) ) ;
}

/*************************************************************************/

static BOOL ReadNextBlock( struct List *pArc , struct Header *pHdr )

/*
 * Read the next block of a file archive, and finds the archive version
 * The header is copied at the location pointed to by pHdr
 */

{
  struct ArcUnit *pUnit ;

  if (! ReadArc( pArc , GIOBuf , TD_SECTOR )) return( FALSE ) ;

  if ( VerifyChkSum( GIOBuf ) && IsNewHeader( (struct Header *)GIOBuf ) )
  {
    memcpy( pHdr , GIOBuf , sizeof(struct Header) ) ;
    ArchiveFmt = pHdr->h_Version ;
    return( TRUE ) ;
  }

  if ( IsOldHeader( (struct OldHeader *)GIOBuf , (BYTE *)pHdr ) )
  {
    ArchiveFmt = pHdr->h_Version ;
    return( TRUE ) ;
  }

  pUnit = FindCurUnit( pArc ) ;
  HandleError( pUnit->au_Name , ABERR_NOT_AN_ARCHIVE ) ;
  return( FALSE ) ;
}

/*************************************************************************/

BOOL ReadNextHeader( struct List *pArc , struct Header *pHdr )

/* $DOC
 * FUNCTION
 *	Reads an archive until a header is found. This high-level function
 *	masks the difference between the various archive formats.
 * INPUTS
 *	pArc = pointer to an archive, returned by OpenArc()
 *	pHdr = pointer to a data area where to copy the header found
 * OUTPUTS
 *	Result = TRUE if a header has been found
 * $END
 */

{
  if ( ArchiveFmt == -1 ) return( ReadNextBlock( pArc , pHdr ) ) ;

  while ( ReadData( pArc , GIOBuf , MAXDATA ) )
    if ( IsHeader( GIOBuf ) )
    {
      memcpy( (BYTE *)pHdr , GIOBuf , sizeof(struct Header) ) ;
      return( TRUE ) ;
    }

  return( FALSE ) ;
}

/*************************************************************************/

static BOOL DoSkipData( struct List *pArc , LONG ToSkip )

/* Low-level function to skip "ToSkip" bytes of data */

{
  LONG ToRead, RLen ;
  struct ArcUnit *pUnit ;

  pUnit = FindCurUnit( pArc ) ;
  if ( ! pUnit ) return( FALSE ) ;

  /* file/tape archive: just Seek() */

  if ( pUnit->au_Type != AUT_DEVICE )
  {
    if ( ! OldArchiveFmt() ) ToSkip += ToSkip / MAXDATA ; /* add checksum bytes */
    ToSkip = RoundToSector( ToSkip ) ;                    /* round up to sector boundary */
    return( SeekArc( pArc , ToSkip , OFFSET_CURRENT ) ) ;
  }

  /* device archive: read data (in order to take bad cyls in account) */

  RLen = OldArchiveFmt() ? IOBUFSIZE : IOMAXDATA ;
  while ( ToSkip > 0 )
  {
    ToRead = MIN( ToSkip , RLen ) ;
    if (! ReadData( pArc , GIOBuf , ToRead )) return( FALSE ) ;
    ToSkip -= ToRead ;
  }

  return( TRUE ) ;
}

/*************************************************************************/

BOOL SkipData( struct List *pArc , struct Header *pHdr )

/* $DOC
 * FUNCTION
 *	Skip an object in the archive
 * INPUTS
 *	pHdr = header of the object to skip
 * OUTPUTS
 *	Result = success/failure
 * $END
 */

{
  struct DosEnvec *pEnv ;
  LONG FBLen, Size, NCyl ;

  if ( (pHdr->h_Type == HT_HLINK) ||
       (pHdr->h_Type == HT_SLINK) ) return( DoSkipData( pArc , MAXDATA ) ) ;

  if ( pHdr->h_Type == HT_FILE )
    if ( ObjIsSplited( &(pHdr->h_Obj) ) )
    {
      Size = 0 ;
      FOREVER
      {
	Size += pHdr->h_BSize ;
	if (! DoSkipData( pArc , pHdr->h_CSize )) return( FALSE ) ;
	if ( Size >= pHdr->h_Obj.obj_Size )  break ;
	if (! ReadNextHeader( pArc , pHdr )) return( FALSE ) ;
	if ( pHdr->h_Type != HT_SPLIT ) return( FALSE ) ;
      }
      return( TRUE ) ;
    }
    else return( DoSkipData( pArc , pHdr->h_CSize ) ) ;

  if ( pHdr->h_Type != HT_NDOS ) return( TRUE ) ;

  pEnv	= &(pHdr->h_DeviceDef.dd_Env) ;
  FBLen = OldArchiveFmt() ? TD_SECTOR : MAXDATA ;

  for ( NCyl = pEnv->de_HighCyl - pEnv->de_LowCyl + 1 ; NCyl > 0 ; NCyl-- )
  {
    if (! ReadData( pArc , GIOBuf , FBLen )) return( FALSE ) ;
    if ( IsHeader( GIOBuf ) ) break ;

    memcpy( &Size , GIOBuf , sizeof(LONG) ) ;
    Size -= FBLen - sizeof(LONG) ;
    if ( (Size > 0) && (! DoSkipData( pArc , Size )) ) return( FALSE ) ;
  }

  return( TRUE ) ;
}

/*************************************************************************/

void BuildHeader( struct Header *pHdr , struct Object *pObj )

/* $DOC
 * FUNCTION
 *	Prepares a header for the given object.
 * INPUTS
 *	pHdr = pointer to the header to initialize
 *	pObj = pointer to the object for which you want a header
 * NOTES
 *	Some other fields will be setup by compression functions. By
 *	default, the header is set as if the object was not compressed.
 * SEE ALSO
 *	UpdateHeader()
 * $END
 */

{
  struct DeviceDef *pDef ;

  /* clear end of header structure */
  memset( &(pHdr->h_CryptSum) , '\0' , offsetof(struct Header,h_Version) - offsetof(struct Header,h_CryptSum) ) ;

  /* initialize header type */
  if ( ObjIsDir( pObj ) )          pHdr->h_Type = HT_DIR ;
  else if ( ObjIsDevice(  pObj ) ) pHdr->h_Type = HT_NDOS ;
  else if ( ObjIsHLink(   pObj ) ) pHdr->h_Type = HT_HLINK ;
  else if ( ObjIsSLink(   pObj ) ) pHdr->h_Type = HT_SLINK ;
  else if ( ObjIsCatalog( pObj ) ) pHdr->h_Type = HT_CATAL ;
  else				   pHdr->h_Type = HT_FILE ;

  /* copy object structure */
  memcpy( &(pHdr->h_Obj) , pObj , sizeof(struct Object)+strlen(pObj->obj_Name) ) ;
  if ( IS_BFL_SETABIT ) pHdr->h_Obj.obj_Bits |= FIBF_ARCHIVE ;
  pHdr->h_Obj.obj_UserData = RecursLevel ;

  /* copy device definition (if any) */
  if ( ObjIsDevice( pObj ) && (pDef = GetDeviceDef( pObj )) )
    memcpy( &(pHdr->h_DeviceDef) , pDef , sizeof(struct DeviceDef)+strlen(pDef->dd_Name) ) ;

  /* initialize the objet path */
  if (! ObjIsCatalog( pObj ))
  {
    pHdr->h_PathLen = GPathIndex ;
    memcpy( pHdr->h_PathTable , GPathTable , GPathIndex ) ;
  }

  /* initialize the other fields */
  pHdr->h_CatalOfs  = -1 ;
  pHdr->h_CType     = HCT_NONE ;
  pHdr->h_BDate     = IdntDate ;
  pHdr->h_Version   = HVER_CURRENT ;
  pHdr->h_CSize     = pObj->obj_Size ;
  if ( pObj->obj_Parent ) strncpy( pHdr->h_Parent , pObj->obj_Parent->obj_Name , MINSTR ) ;

  /* this is used by FlushDev() to retrieve Object struct */
  pHdr->h_Obj.obj_Node.mln_Succ = (struct MinNode *)pObj ;
}

/*************************************************************************/

BOOL ReadDataToFile( struct List *pArc , BPTR Desc , LONG Left )

/* $DOC
 * FUNCTION
 *	Reads data from an archive, and adds it into a file
 * INPUTS
 *	pArc = the archive to read from
 *	Desc = the file to write to
 *	Left = the number of bytes to copy
 * OUTPUT
 *	Result = success/failure
 * $END
 */

{
  LONG Size, Nbr ;

  Seek( Desc , 0 , OFFSET_END ) ;

  for ( Size = 0 ; Size < Left ; Size += Nbr )
  {
    Nbr = Left - Size ;
    if ( Nbr > MaxIoSize() ) Nbr = MaxIoSize() ;
    if (! ReadData( Archive , GIOBuf , Nbr )) return( FALSE ) ;
    if ( Write( Desc , GIOBuf , Nbr ) != Nbr ) return( FALSE ) ;
  }

  return( TRUE ) ;
}

/*************************************************************************/

BOOL ReadFile( struct Header *pHdr , BYTE *pName )

/* $DOC
 * FUNCTION
 *	Extracts a file from an archive.
 * INPUTS
 *	pHdr = pointer to the header describing the file
 *	pName = name of the file to create
 * OUPUTS
 *	Result = success/failure
 *	If an error occurs, the (eventually partial) file is not
 *	deleted.
 * NOTES
 *	The file is *NOT* decompressed
 * SEE ALSO
 *	DecompressFile(), RestoreFile(), ReadDataToFile()
 * $END
 */

{
  BPTR Desc ;
  BOOL Ret = FALSE ;

  if ( Desc = Open( pName , MODE_NEWFILE ) )
  {
    /*
     * We use pHdr->h_CSize as file size, instead of pHdr->h_Obj.obj_Size :
     * - if file not compressed, this is the same !
     * - if external compressed, this allow to restore the temporary file
     *	 on which we will run the decompressor (later)
     */

    Ret = ReadDataToFile( Archive , Desc , pHdr->h_CSize ) ;
    Close( Desc ) ;
  }
  else HandleError( pName , HERR_IOERR ) ;

  return( Ret ) ;
}

/*************************************************************************/

BOOL WriteFile( struct List *pArc , BYTE *pName )

/* $DOC
 * FUNCTION
 *	Adds a file into an archive.
 * INPUTS
 *	pArc = pointer to an archive, returned by OpenArc()
 *	pName = pointer to the full pathname of the file to write
 * OUTPUTS
 *	Result = success/failure
 * NOTES
 *	The file is not compressed, and no file header is written.
 * SEE ALSO
 *	SaveFile(), CompressFile()
 * $END
 */

{
  LONG Nbr ;
  BPTR Desc ;

  /* open the file */
  Desc = Open( pName , MODE_OLDFILE ) ;
  if ( ! Desc )
  {
    HandleError( pName , HERR_IOERR ) ;
    return( FALSE ) ;
  }

  /* transfert loop */
  FOREVER
  {
    Nbr = Read( Desc , GIOBuf , IOMAXDATA ) ;
    if ( Nbr < 0 ) HandleError( pName , HERR_IOERR ) ;
    if ( Nbr < 1 ) break ;

    if (! WriteData( pArc , GIOBuf , (LONG)Nbr ))
    {
      Nbr = -1 ;
      break ;
    }
  }

  /* exit */
  Close( Desc ) ;
  return( (BOOL)(Nbr >= 0) ) ;
}

/*************************************************************************/

BOOL ReadObjectHeader( struct Object *pObj , BYTE *pName )

/* $DOC
 * FUNCTION
 *	Reads an object header from the archive
 * INPUTS
 *	pObj = pointer to the object
 *	pName = pointer to full object name (may be NULL)
 * OUTPUTS
 *	Result = success/failure
 * NOTES
 *	The header is copied into the global pGHdr variable
 * $END
 */

{
  BOOL Ret ;
  struct ArcUnit *pUnit ;

  if ( NewID == WIN_MONITOR )
  {
    pUnit = FindCurUnit( Archive ) ;
    if ( pUnit && (pUnit->au_Type == AUT_TAPE) && (pObj->obj_Offset < pUnit->au_CurPos) )
      MonitorPrint( MP_POS1 , GetStr( MSG_TAPE_REWINDING ) , MPF_LINEFEED ) ;
  }

  // seek to the right position

  Ret = FALSE ;
  if ( AskGoodDisk( Archive , (LONG)pObj->obj_Disk ) &&
       SeekArc( Archive , pObj->obj_Offset , OFFSET_BEGINNING ) ) Ret = TRUE ;
  if ( pName ) MonitorPrint( MP_POS1 , pName , NULL ) ;
  if ( ! Ret ) return( FALSE ) ;

  // read object header

  do
  {
    if (! ReadNextHeader( Archive , pGHdr )) return( FALSE ) ;
    if ( pGHdr->h_Type == HT_OLDCATAL ) return( FALSE ) ;
    if ( pGHdr->h_Type == HT_CATAL ) return( FALSE ) ;
  }
  while (! SameObj( pObj , &(pGHdr->h_Obj) )) ;

  return( TRUE ) ;
}

/*************************************************************************/

static BOOL StoreCatalogOffset( struct List *pArc , struct Object *pObj )

/*
 * Stores the offset of the archive catalog, in the appropriate
 * location whithin the archive itself.
 * pArc = pointer to an archive, returned by OpenArc()
 * pObj = pointer to the object describing the archive catalog
 */

{
  struct Header *pHdr ;
  struct ArcUnit *pUnit ;

  if (! FlushArc( pArc , FAF_DEVONLY )) return( FALSE ) ;
  pUnit = FindCurUnit( pArc ) ;

  /* For tapes, we do nothing */
  if ( pUnit->au_Type == AUT_TAPE ) return( TRUE ) ;

  /* For devices we just modify the bad cylinder map, which will be writen later */
  if ( pUnit->au_Type == AUT_DEVICE )
  {
    pUnit->au_BadCyls->bcm_CatalOfs = pObj->obj_Offset ;
    return( TRUE ) ;
  }

  /* For files we modify the first header */
  pHdr = (struct Header *)GIOBuf ;
  if (! SeekArc( pArc , 0 , OFFSET_BEGINNING )) return( FALSE ) ;
  if (! ReadNextHeader( pArc , pHdr )) return( FALSE ) ;
  pHdr->h_CatalOfs = pObj->obj_Offset ;
  if (! SeekArc( pArc , 0 , OFFSET_BEGINNING )) return( FALSE ) ;
  return( WriteHeader( pArc , pHdr ) ) ;
}

/*************************************************************************/

static BPTR WC_Desc ;

static BOOL WriteCat( struct Object *pObj )

/* Adds the given object to the archive catalog */

{
  LONG Len ;
  struct DeviceDef *pDef ;

  if ( ! ObjIsSaved( pObj ) ) return( TRUE ) ;                  // object saved ?

  if ( pObj->obj_Parent ) pObj->obj_UserData = RecursLevel ;    // get level (if not root)
  Len = sizeof(struct Object) + strlen(pObj->obj_Name) ;        // compute object size
  if ( Len & 1 ) Len++ ;                                        // round up to even value
  if ( Write( WC_Desc , pObj , Len ) != Len ) return( FALSE ) ; // write in file

  if ( ObjIsDir( pObj ) && ObjHasComment( pObj ) )              // save directory comment
  {
    GetFullName( FullName , pObj ) ;
    if ( ! MyExamine( FullName ) ) GFib.fib_Comment[0] = '\0' ;
    if ( Write( WC_Desc , GFib.fib_Comment , MAXNOTE ) != MAXNOTE ) return( FALSE ) ;
  }

  if ( ! ObjIsDevice( pObj ) ) return( TRUE ) ;                 // object is a device ?
  if ( ObjIsMultiVol( pObj ) ) return( TRUE ) ;                 // but not root object

  if ( pDef = GetDeviceDef( pObj ) )
  {
    Len = sizeof(struct DeviceDef) + strlen(pDef->dd_Name) ;    // compute definition size
    if ( Len & 1 ) Len++ ;                                      // round up to even value
    return( (BOOL)(Write( WC_Desc , pDef , Len ) == Len) ) ;    // write in file
  }

  return( TRUE ) ;
}

BOOL WriteCatalog( struct List *pArc , struct Object *pRoot , UBYTE CompType , LONG Flags )

/* $DOC
 * FUNCTION
 *	Creates the archive catalog, and adds it at the end of the archive.
 *	There is one entry for each saved object, plus one for the root object,
 *	plus some other objects to store directory tree and (eventually) the
 *	definition of devices.
 *	When using floppy disks, the catalog is always on the last disk.
 *	The SaveFile() function ensure this first by calling FitArc() before
 *	writing the catalog, second by checking the disk number after the
 *	catalog has been written, so it will see if the disk has been changed
 *	during the writing (bad cylinder etc...). In this case, it will rewind
 *	to the beginning of the disk, and rewrite the catalog file starting
 *	from this position.
 * INPUTS
 *	pArc = pointer to an archive, returned by OpenArc()
 *	pRoot = pointer to the root object
 *	CompType = compression algorithm to use for the catalog
 *	Flags = any combination of:
 *		WCF_TOFILE	write catalog to a file
 *		WCF_TOARC	write catalog to the archive
 * OUTPUTS
 *	Result = success/failure
 * NOTES
 *	If CompType is HCT_NONE, the internal compression is used.
 *	The WCF_TOFILE flag is forced if catalog duplication is asked in
 *	Preferences
 * $END
 */

{
  BOOL Ret = FALSE ;
  struct Object *pObj ;

  if ( pArc && (! FlushArc( pArc , FAF_DEVONLY )) ) return( FALSE ) ;
  if ( HasBeenBreaked() ) return( FALSE ) ;

  MonitorPrint( MP_POS1 , GetStr( MSG_MONITOR_CATALOG ) , NULL ) ;

  if ( IS_BFL_DUPCATALOG ) Flags |= WCF_TOFILE ;

  /* first, we write the catalog data in a file */

  TmpName( tName ) ;
  WC_Desc = Open( tName , MODE_NEWFILE ) ;
  if ( ! WC_Desc )
  {
    HandleError( tName , HERR_IOERR ) ;
    return( FALSE ) ;
  }

  /* write root object as first object */

  SetObjFlag( pRoot , OBJF_SAVED ) ;
  pRoot->obj_UserData = 0 ;
  if (! WriteCat( pRoot ))
  {
    HandleError( tName , HERR_IOERR ) ;
    Close( WC_Desc ) ;
    goto _end ;
  }

  /* write all saved objects */

  if (! WalkDirTree( pRoot , WriteCat , (WDTF_DIRBEFORE|WDTF_RECURSIVE) ) )
  {
    HandleError( tName , HERR_IOERR ) ;
    Close( WC_Desc ) ;
    goto _end ;
  }
  Close( WC_Desc ) ;

  /* then write catalog header and catalog data */

  if ( ! MyExamine( tName ) )
  {
    HandleError( tName , HERR_IOERR ) ;
    goto _end ;
  }

  pObj = ObjFromFib( tName , &GFib ) ;
  if ( ! pObj ) goto _end ;
  if (! (Flags & WCF_TOARC)) SetObjFlag( pObj , OBJF_SAVED ) ;

  SetObjFlag( pObj , OBJF_CATALOG ) ;
  if (! IS_BFL_CATCOMP ) CompType = HCT_NONE ;
  else if ( CompType == HCT_NONE ) CompType = HCT_INTERNAL ;
  if ( Ret = SaveFile( tName , pObj , CompType ) )
    if ( Flags & WCF_TOARC ) StoreCatalogOffset( pArc , pObj ) ;

  /* duplicate catalog if needed */

  if ( Flags & WCF_TOFILE )
  {
    strcpy( tmp , ARG_CATALOG ) ;

    for (;;)
    {
      if ( (! BATCHMODE) && (! FileRequest( MSG_REQ_TITLE_SAVE_CATALOG , tmp , NULL)) ) tmp[0] = '\0' ;
      pGHdr->h_Type = HT_CATAL ;
      if ( tmp[0] && (! CopyFile( tmp , tName , CFF_ADDHEADER )) )
      {
	HandleError( tmp , ABERR_COPYCAT_FAILED ) ;
	DeleteFile( tmp ) ;
      }
      else break ;
    }
  }

  /* clean exit */

  if ( *ToDelete ) DeleteFile( ToDelete ) ;
  *ToDelete = '\0' ;
  FreeObject( pObj ) ;

_end:
  DeleteFile( tName ) ;
  return( Ret ) ;
}

/*************************************************************************/

BOOL FindCatalog( BYTE *pName , BOOL FromFile )

/* $DOC
 * FUNCTION
 *	Finds the archive catalog
 * INPUTS
 *	pName = name of the archive
 *	FromFile = TRUE if catalog is to load from a file
 * OUTPUTS
 *	Result = success/failure
 * NOTES
 *	The archive is *NOT* closed by this function, so it will still be
 *	opened when restore will start. Take care that the archive may not
 *	be opened when the function returns, e.g. if OpenArc() fails.
 * $END
 */

{
  LONG k ;
  BPTR Desc ;
  struct Header *pHdr ;
  struct ArcUnit *pUnit ;

  /* open the archive */

  InitOperation() ;
  Archive = OpenArc( pName , OAF_READ ) ;
  if ( ! Archive ) return( FALSE ) ;

  if ( HasInterface() )
    SetGad( GD_LoadTree , GTTX_Text,  (ULONG)GetStr( MSG_CATALOG ) ) ;

  /* ask file name and read first sector to get archive info */

  if ( BATCHMODE && ARG_CATALOG[0] )
  {
    FromFile = TRUE ;
    strcpy( tmp , ARG_CATALOG ) ;
  }
  else if ( FromFile )
  {
    tName[0] = '\0' ;
    if (! FileRequest( MSG_REQ_TITLE_LOAD_CATALOG , tName , NULL )) return( FALSE ) ;
  }

  if ( FromFile )
  {
    if (! (Desc = Open( tName , MODE_OLDFILE )))
    {
      HandleError( tName , ABERR_CANNOT_OPEN ) ;
      return( FALSE ) ;
    }
    k = Read( Desc , pGHdr , TD_SECTOR ) ;
    Close( Desc ) ;
    if ( (k != TD_SECTOR)                  ||
	 (! VerifyChkSum( (BYTE *)pGHdr )) ||
	 (! IsNewHeader( pGHdr ))          ||
	 (pGHdr->h_Type != HT_CATAL) )
    {
      HandleError( tName , ABERR_READ_ERROR ) ;
      return( FALSE ) ;
    }
    ArchiveFmt = pGHdr->h_Version ;
  }
  else
  {
    /*
     * Finds catalog offset
     * device : examine the "auto-loaded" bad cylinder map
     * file   : read the first data block
     * tape   : do nothing
     */

    pUnit = FindCurUnit( Archive ) ;
    if ( pUnit->au_Type == AUT_DEVICE )
    {
      if ( DevIsTrackDisk( pUnit ) && (! FULLBATCHMODE) )
      {
	if (! DiskRequest( pUnit , DR_LASTDISK )) return( FALSE ) ;
      }
      else if (! PrepareDev( pUnit , NULL )) return( FALSE ) ;
      pHdr = (struct Header *)pUnit->au_BadCyls ;
    }
    else
    {
      if (! ReadNextHeader( Archive , pGHdr )) return( FALSE ) ;
      pHdr = pGHdr ;
    }

    if ( (pUnit->au_Type != AUT_TAPE) &&
	 (! SeekArc( Archive , pHdr->h_CatalOfs , OFFSET_BEGINNING )) ) return( FALSE ) ;

    /*
     * find catalog header
     * for tapes, we just read data until we find a header with the right type
     * in order to speed up things, we seek over files using h_CSize
     */

    k = ( OldArchiveFmt() ) ? HT_OLDCATAL : HT_CATAL ;
    do
    {
      if ( (pUnit = FindCurUnit( Archive )) &&
	   (pUnit->au_Type == AUT_TAPE)     &&
	   (! SkipData( Archive , pHdr )) ) return( FALSE ) ;
      if (! ReadNextHeader( Archive , pGHdr )) return( FALSE ) ;
      if ( StopMe() ) return( FALSE ) ;
    }
    while ( pGHdr->h_Type != k ) ;
  }

  /* get archive info and display it */

  IdntDate = pGHdr->h_BDate ;
  if ( ! OldArchiveFmt() )
  {
    memcpy( &GArcInfo , &(pGHdr->h_DeviceDef) , sizeof(struct ArcInfo) ) ;
    strcpy( RootName , pGHdr->h_PathTable ) ;
  }
  else memset( &GArcInfo , '\0' , sizeof(struct ArcInfo) ) ;

  SetPrgFlag( PF_CATALFOUND ) ;
  return( TRUE ) ;
}

/*************************************************************************/

static BOOL ClearUserData( struct Object *pObj )
{
  pObj->obj_UserData = 0 ;
  return( TRUE ) ;
}

struct Object *LoadCatalog( BOOL FromFile )

/* $DOC
 * FUNCTION
 *	Loads the catalog of an archive in memory. This high-level function
 *	masks the differences between the various archive formats.
 * INPUTS
 *	FromFile = TRUE if catalog is to load from a file (name in tName[])
 *		   FALSE if catalog is to load from archive
 * OUTPUTS
 *	pRoot = pointer to the root object, or NULL if failed
 * NOTES
 *	The root object will have the OBJF_CATALOG flag set.
 * $END
 */

{
  LONG k, d ;
  BYTE *pFile ;
  struct Object *pRoot ;
  struct OldCatalog *pOCat ;

  if ( HasInterface() )
    SetGad( GD_LoadTree , GTTX_Text, (ULONG)GetStr(MSG_LOADING_TREE) ) ;

  if ( BATCHMODE && ARG_CATALOG[0] ) FromFile = TRUE ;

  if ( FromFile )
  {
    k = MyExamine( tName ) ? GFib.fib_Size - TD_SECTOR : 0 ;
    d = TD_SECTOR ;
  }
  else			/* restore catalog file in T: */
  {
    strcpy( tName , PRF_TEMPDIR ) ;
    AddPart( tName , pGHdr->h_Obj.obj_Name , MAXSTR ) ;
    if (! RestoreFile( pGHdr , tName , FALSE ))
    {
      DeleteFile( tName ) ;
      return( NULL ) ;
    }
    k = pGHdr->h_Obj.obj_Size ;
    d = 0 ;
  }

  /* loads catalog in memory */

  pFile = LoadFileInMem( tName , k , d ) ;
  if ( ! FromFile ) DeleteFile( tName ) ;
  if ( ! pFile ) return( NULL ) ;

  if ( HasInterface() )
    SetGad( GD_LoadTree , GTTX_Text, (ULONG)GetStr(MSG_ANALYSING_CATALOG) ) ;

  /* make catalog usuable */

  if ( OldArchiveFmt() )
  {
    pOCat = (struct OldCatalog *)pFile ;
    pRoot = BuildOldCatal( NULL , &pOCat , &k ) ;
    SetPrgFlag( PF_CATALISTREE ) ;
    MyFreeMem( pFile ) ;
  }
  else
  {
    pRoot = (struct Object *)pFile ;
    BuildNewCatal( pRoot , NULL , &k ) ;
    ArchiveFmt = -1 ;
  }

  /* reset all obj_UserData fields to zero */

  if ( pRoot )
  {
    WalkDirTree( pRoot , ClearUserData , WDTF_RECURSIVE|WDTF_DIRAFTER ) ;
    SetObjFlag( pRoot , OBJF_CATALOG ) ;
  }

  return( pRoot ) ;
}

