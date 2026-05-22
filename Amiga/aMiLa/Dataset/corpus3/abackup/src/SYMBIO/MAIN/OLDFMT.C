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
    oldmft.c

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 23-Sep-93
    Modified: 26-Nov-95
    _______________________________________________________________________
*/

#include "headers.h"

/*************************************************************************/

BOOL IsOldHeader( struct OldHeader *pHdr , BYTE *pData )

/* $DOC
 * FUNCTION
 *	Test if a data block is a header in the old archive format, and
 *	if true, convert it into the new format
 * INPUTS
 *	pHdr = pointer to the data block
 *	pData = pointer to the area where to put the converted header
 *		(may be NULL, if you don't want conversion)
 * OUTPUTS
 *	Result = TRUE is the data block is a header
 * NOTES
 *	Structure conversion is made in such way that pData may be equal
 *	to pHdr. Before conversion, the old header is copied in the global
 *	variable OldHdr.
 * $END
 */

{
  // check "ABCK" values in h_Idnt fields
  if ( pHdr->th_idnt1 != OLD_IDNT ) return( FALSE ) ;
  if ( pHdr->th_idnt2 != OLD_IDNT ) return( FALSE ) ;

  // check header type
  if ( pHdr->th_type & HT_CRYPT ) return( FALSE ) ;
  if ( (pHdr->th_type < HT_MINHT) || (pHdr->th_type > HT_OLDCATAL) ) return( FALSE ) ;

  // check version number
  if ( AfterV4( pHdr->th_version ) ) return( FALSE ) ;

  // eventually convert to new format
  if ( pData )
  {
    memcpy( &OldHdr , pHdr , sizeof(struct OldHeader) ) ;
    ConvertHeader( &OldHdr , (struct Header *)pData ) ;
  }
  return( TRUE ) ;
}

/*************************************************************************/

BOOL ReadOldData( struct List *pArc , BYTE *pData , LONG Len )

/* $DOC
 * FUNCTION
 *	Reads data from an old format archive.
 * INPUTS
 *	pArc = pointer to an archive, returned by OpenArc()
 *	pData = pointer to the buffer where to put data
 *	Len = number of data bytes to read
 * OUTPUTS
 *	Result = success/failure
 * $END
 */

{
  LONG ToRead, ToCopy ;

  while ( Len > 0 )
  {
    ToCopy = MIN( Len , IOBUFSIZE ) ;
    ToRead = RoundToSector( ToCopy ) ;
    if (! ReadArc( pArc , IOBuf , ToRead )) return( FALSE ) ;
    memcpy( pData , IOBuf , (size_t)ToCopy ) ;
    pData += ToCopy ;
    Len -= ToCopy ;
  }

  return( TRUE ) ;
}

/*************************************************************************/

static struct OldCatalog *NextCatalObj( struct OldCatalog *pCat , LONG *pSize )

/*
 * Returns a pointer to next object in catalog
 * pObj = pointer to object to skip
 */

{
  LONG OLen ;
  BYTE *pMem ;

  /* compute object len (round up to even value) */
  OLen = sizeof(struct OldCatalog) + strlen( pCat->c_name ) ;
  if ( OLen & 1 ) OLen++ ;

  /* check if not reached end of catalog and compute next object address */
  *pSize -= OLen ;
  if ( *pSize > 0 )
  {
    pMem = (BYTE *)pCat ;
    pCat = (struct OldCatalog *)(&pMem[OLen]) ;
  }
  else pCat = NULL ;

  return( pCat ) ;
}

/*************************************************************************/

struct Object __stackext *BuildOldCatal( struct Object *pRoot , struct OldCatalog **pNCat , LONG *pSize )

/* $DOC
 * FUNCTION
 *	Make old format archive catalog usuable, by linking objects together
 * INPUTS
 *	pRoot = pointer to the parent directory for this level (may be NULL)
 *	pNCat = address of a pointer to the first OldCatalog struct to process.
 *	pSize = pointer to the catalog size
 * OUTPUTS
 *	Result = pointer to the root object, or NULL if failed
 *	The address of the last OldCatalog struct processed is put at the location
 *	pointed to by pNCat
 * $END
 */

{
  struct DeviceDef *pDef ;
  struct OldCatalog *pCat ;
  struct Object *pObj, *pPrev ;

  pCat = *pNCat ;

  /* initialize pointers */
  pPrev = pRoot ;
  if ( ! pRoot )
  {
    pRoot = OldCatalToObj( pCat ) ;
    if ( ! pRoot ) return( NULL ) ;
  }

  /*
   * In previous versions, backup of a partition produced a special catalog
   * with a single entry (describing the partition). Since v5.00, there must
   * be a root object with the OBJF_MULTIVOL flag and the partition object as
   * the first child
   */

  if ( ObjIsDevice( pRoot ) )
  {
    pObj = pRoot ;
    if ( pRoot = AllocObject( ABO_OBJECT , "" ) )
    {
      AddChild( pRoot , pObj ) ;
      if ( pDef = ConvertDeviceDef( (struct OldDeviceDef *)&(pCat->c_name[0]) , NULL ) )
      {
	AddDeviceDef( pObj , pDef ) ;
	SetObjFlag( pRoot , OBJF_MULTIVOL ) ;
      }
    }
    else pRoot = pObj ;

    if (! ObjIsMultiVol( pRoot ) )
    {
      FreeDirTree( pRoot ) ;
      return( NULL ) ;
    }
  }
  else for ( pCat = NextCatalObj( pCat , pSize ) ; pCat ; )             // loop on all objects
  {
    pObj = OldCatalToObj( pCat ) ;
    if ( ! pObj )
    {
      FreeDirTree( pRoot ) ;
      return( NULL ) ;
    }
    strcpy( pObj->obj_Name , pCat->c_obj.o_name ) ;

    if ( pObj->obj_UserData <= pRoot->obj_UserData ) break ;            // go down

    AddChild( pRoot , pObj ) ;                                          // add in list
    if ( ObjIsDir( pObj ) )
    {
      if (! BuildOldCatal( pObj , &pCat , pSize ))
      {
	FreeDirTree( pRoot ) ;
	return( NULL ) ;
      }
    }
    else pCat  = NextCatalObj( pCat , pSize ) ;
  }

  *pNCat = pCat ;

  pRoot->obj_Flags |= OBJF_DIRECTORY ;
  return( pRoot ) ;
}

