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
    newfmt.c

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 29-Aug-93
    Modified: 01-Jul-96
    _______________________________________________________________________
*/

#include "headers.h"

/*************************************************************************/

BOOL VerifyChkSum( UBYTE *pSrc )

/* $DOC
 * FUNCTION
 *	Verifies the checksum of a data block
 * INPUTS
 *	pSrc = pointer to the data block
 * OUTPUTS
 *	Result = success/failure
 * NOTES
 *	Was a macro, moved as the function becaused it didn't seemed to work
 * $END
 */

{
  if ( pSrc[MAXDATA] == GetChkSum( pSrc ) ) return( TRUE ) ;
  return( FALSE ) ;
}

/*************************************************************************/

void BuildChkSum( UBYTE *pSrc )

/* $DOC
 * FUNCTION
 *	Build the checksum of a data block
 * INPUTS
 *	pSrc = pointer to the data block
 * NOTES
 *	Was a macro, moved as the function for safety (see VerifyChkSum).
 * $END
 */

{
  pSrc[MAXDATA] = GetChkSum( pSrc ) ;
}

/*************************************************************************/

BOOL IsNewHeader( struct Header *pHdr )

/* $DOC
 * FUNCTION
 *	Test if a data block is a header in the new archive format.
 * INPUTS
 *	pHdr = pointer to the data block
 * OUTPUTS
 *	Result = TRUE is the data block is a header
 * NOTES
 *	The pHdr->h_BDate must be equal to the global variable IdntDate
 *	This test is performed only if IdntDate is not set to -1
 *	The header is automatically uncrypted if needed
 * $END
 */

{
  LONG Type ;
  struct Header *pRHdr ;
  static struct Header TmpHdr ;

  // check values in h_Idnt fields
  if ( (pHdr->h_Idnt1 & H_IDNT_MSK) != H_IDNT ) return( FALSE ) ;
  if ( pHdr->h_Idnt2 != H_IDNT ) return( FALSE ) ;

  // check header type
  Type = pHdr->h_Type & ~HT_CRYPT ;
  if ( (Type < HT_MINHT) || (Type > HT_MAXHT) ) return( FALSE ) ;
  if ( Type == HT_END      ) return( FALSE ) ;
  if ( Type == HT_FILEX    ) return( FALSE ) ;
  if ( Type == HT_OBSCATAL ) return( FALSE ) ;
  if ( Type == HT_NDOSX    ) return( FALSE ) ;
  if ( Type == HT_OLDCATAL ) return( FALSE ) ;

  /*
   * Uncrypt data if needed
   * We first copy the data to a working area, in order to avoid having to
   * encrypt data if we finally find it is not a new header
   * So pRHdr is either set to this working area, or to the original header
   */

  if ( pHdr->h_Type & HT_CRYPT )
  {
    memcpy( &TmpHdr , pHdr , sizeof(struct Header) ) ;
    if (! UncryptNewHeader( &TmpHdr )) return( FALSE ) ;
    SetPrgFlag( PF_UNCRYPT ) ;
    pRHdr = &TmpHdr ;
  }
  else pRHdr = pHdr ;

  // check date and version number
  if ( (IdntDate != -1) && (pRHdr->h_BDate != IdntDate) ) return( FALSE ) ;
  if ( BeforeV5( pRHdr->h_Version ) ) return( FALSE ) ;

  /*
   * At this point, we know that we really have a new header, so we can copy
   * uncrypted data over the original header
   */

  if ( pHdr->h_Type & HT_CRYPT )
  {
    memcpy( pHdr , &TmpHdr , sizeof(struct Header) ) ;
    pHdr->h_Type &= ~HT_CRYPT ;
  }

  /* Up to v5.11, a long parent name could overwrite the h_CType field */
  pHdr->h_CType &= HCT_MASK ;

  return( TRUE ) ;
}

/*************************************************************************/

void PrepareData( LONG Offset , BYTE *pData , LONG Len )

/* $DOC
 * FUNCTION
 *	Prepare a data block to be written to an archive
 * INPUTS
 *	Offset = position in IOBuf
 *	pData = pointer to data to write
 *	Len = number of bytes to write
 * NOTES
 *	This function only copies up to MAXDATA bytes of data
 * $END
 */

{
  if ( Len < MAXDATA )
    memset( &IOBuf[Offset] , '\0' , MAXDATA ) ; // clear of data block
  else
    Len = MAXDATA ; // no more than one data block at a time

  memcpy( &IOBuf[Offset] , pData , (size_t)Len ) ; // copy data
  if ( IS_BFL_ENCRYPT ) EncryptData( &IOBuf[Offset] , MAXDATA ) ; // encrypt data
  BuildChkSum( &IOBuf[Offset] ) ; // compute checksum
}

/*************************************************************************/

BOOL WriteData( struct List *pArc , BYTE *pData , LONG Len )

/* $DOC
 * FUNCTION
 *	Writes data to a new format archive.
 * INPUTS
 *	pArc = pointer to an archive, returned by OpenArc()
 *	pData = pointer to the buffer which contains data to write
 *	Len = number of data bytes to write
 * OUTPUTS
 *	Result = success/failure
 * $END
 */

{
  LONG d ;

  /* write loop */
  for ( d = 0 ; Len > 0 ; Len -= MAXDATA )
  {
    PrepareData( d , pData , Len ) ;            // copy data to buffer
    pData += MAXDATA ;
    d += TD_SECTOR ;

    if ( d >= IOBUFSIZE )                       // buffer full ?
    {
      if (! WriteArc( pArc , IOBuf , d )) return( FALSE ) ;
      d = 0 ;
    }
  }

  /* flush buffer and exit */
  if ( d && (! WriteArc( pArc , IOBuf , d )) ) return( FALSE ) ;
  return( TRUE ) ;
}

/*************************************************************************/

BOOL ReadNewData( struct List *pArc , BYTE *pData , LONG Len )

/* $DOC
 * FUNCTION
 *	Reads data from a new format archive.
 * INPUTS
 *	pArc = pointer to an archive, returned by OpenArc()
 *	pData = pointer to the buffer where to put data
 *	Len = number of data bytes to read
 * OUTPUTS
 *	Result = success/failure
 * $END
 */

{
  LONG l, s, d ;
  struct ArcUnit *pUnit ;

  d = 0 ;
  while ( Len > 0 )
  {
    l = MIN( Len , IOBUFSIZE ) ;
    l = RoundToSector( l ) ;
    if (! ReadArc( pArc , IOBuf , l )) return( FALSE ) ;

    for ( s = 0 ; l > 0 ; l -= TD_SECTOR )              // scan all data blocks
    {
      if (! VerifyChkSum( &IOBuf[s] ))                  // verify checksum
      {
	pUnit = FindCurUnit( pArc ) ;
	ReportError( pUnit->au_Name , GetStr( MSG_WARN_CHKSUM_ERROR ) ) ;
	if ( ! FULLBATCHMODE )
	  YesNoRequest( GetStr( MSG_REQ_CHKSUM_ERROR ) , pUnit->au_Name , MSG_REQ_OK , NULL ) ;
	return( FALSE ) ;
      }

      if ( MustUncrypt() )                              // uncrypt data
	if ( ! IsNewHeader( (struct Header *)&IOBuf[s] ) ) UncryptData( &IOBuf[s] , MAXDATA ) ;

      memcpy( &pData[d] , &IOBuf[s] , MAXDATA ) ;       // copy data to user buffer
      Len -= MAXDATA ;
      s += TD_SECTOR ;
      d += MAXDATA ;
    }
  }

  return( TRUE ) ;
}

/*************************************************************************/

static struct Object *NextCatalObj( struct Object *pObj , struct DeviceDef *pDef , LONG *pSize )

/*
 * Returns a pointer to next object in catalog
 * pObj = pointer to object to skip
 * pDef = pointer to device definition to skip
 * One of pObj and pDef must be NULL
 */

{
  LONG OLen ;
  BYTE *pMem ;

  /* compute object len (round up to even value) */
  if ( pObj )
  {
    OLen = sizeof(struct Object) + strlen(pObj->obj_Name) ;
    if ( ObjIsDir( pObj ) && ObjHasComment( pObj ) ) OLen += MAXNOTE ;
  }
  else OLen = sizeof(struct DeviceDef) + strlen(pDef->dd_Name) ;
  if ( OLen & 1 ) OLen++ ;

  /* check if not reached end of catalog and compute next object address */
  *pSize -= OLen ;
  if ( *pSize > 0 )
  {
    pMem = pObj ? (BYTE *)pObj : (BYTE *)pDef ;
    pObj = (struct Object *)(&pMem[OLen]) ;
  }
  else pObj = NULL ;

  return( pObj ) ;
}

/*************************************************************************/

struct Object __stackext *BuildNewCatal( struct Object *pRoot , struct Object *pNew , LONG *pSize )

/* $DOC
 * FUNCTION
 *	Make new format archive catalog usuable, by linking objects together
 * INPUTS
 *	pRoot = pointer to the copy of the catalog in memory (first call)
 *		pointer to the directory to explore (other calls)
 *	pNew  = NULL (first call)
 *		pointer to first child (other calls)
 *	pSize = pointer to the catalog size
 * OUTPUTS
 *	Result = pointer to the root object, or NULL if failed
 * $END
 */

{
  struct Object *pObj, *pPrev ;

  CleanObj( pRoot ) ;

  /* initialize pointers */
  pPrev = pRoot ;
  pObj	= ( pNew ) ? pNew : NextCatalObj( pRoot , NULL , pSize ) ;

  /* loop on all objects */
  while ( pObj )
  {
    CleanObj( pObj ) ;

    if ( pObj->obj_UserData == pRoot->obj_UserData+1 )                  // child of root ?
    {
      AddChild( pRoot , pObj ) ;                                        // add in list
      pPrev = pObj ;
      pObj  = NextCatalObj( pObj , NULL , pSize ) ;

      if ( ObjIsDevice( pPrev ) )                                       // a device ?
      {
	AddDeviceDef( pPrev , pObj ) ;
	pObj = NextCatalObj( NULL , (struct DeviceDef *)pObj , pSize ) ;
      }

      continue ;
    }

    if ( pObj->obj_UserData <= pRoot->obj_UserData ) break ;            // go up
    pObj = BuildNewCatal( pPrev , pObj , pSize ) ;                      // go down
  }

  return( pObj ) ;
}

/*************************************************************************/

BOOL WriteHeader( struct List *pArc , struct Header *pHdr )

/* $DOC
 * FUNCTION
 *	Writes an object header to an archive.
 * INPUTS
 *	pArc = pointer to an archive, returned by OpenArc()
 *	pHdr = pointer to the header to write
 * OUTPUTS
 *	Result = success/failure
 * $END
 */

{
  if ( pHdr->h_CatalOfs == -1 ) MonitorPrint( MP_POS2 , GetStr( MSG_MONITOR_WRITING ) , NULL ) ;
  return( WriteData( pArc , (BYTE *)pHdr , sizeof(struct Header) ) ) ;
}

