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
    badcyl.c

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 06-Sep-93
    Modified: 30-Jun-96
    _______________________________________________________________________
*/

#include "headers.h"
#include "childtask.h"

#define BCM_BYTE( c )   ((c) >> 3)                      // byte in bmap
#define BCM_MASK( c )   (1 << (7 - ((c) & 0x07)))       // mask for byte in bmap

/****************************************************************************/

void ClearBadCyl( struct ArcUnit *pUnit )

/* $DOC
 * FUNCTION
 *	Clears the bad cylinders map of the given unit
 * INPUTS
 *	pUnit = pointer to the unit
 * $END
 */

{
  pUnit->au_BadCyls->bcm_CatalOfs   = -1 ;
  pUnit->au_BadCyls->bcm_NumBadCyls =  0 ;
  memset( pUnit->au_BadCyls->bcm_BMap , '\0' , BMAPSIZE ) ;
}

/****************************************************************************/

BOOL ExamineDisk( struct ArcUnit *pUnit )

/* $DOC
 * FUNCTION
 *	Examine the disk in the given unit, and test if it is an ABackup
 *	disk, in the new archive format.
 * INPUTS
 *	pUnit = pointer to the unit
 *		The AUF_NOTARCHIVE flag should be set for the unit
 * OUTPUTS
 *	Result = success/failure
 * NOTES
 *	This function only reads the first cylinder of the disk
 *	The current position on the disk (au_CurPos) is not changed
 *	The unit buffer is destroyed by this call.
 * $END
 */

{
  BOOL Ret ;
  LONG BDate, OldPos ;
  struct Header *pHdr ;

  OldPos = pUnit->au_CurPos ;

  /*
   * Reads and test first sector
   * NOTE: we temporary change the backup date in the header, because IsNewHeader()
   *	   only works if this field is equal to IdntDate
   */

  Ret = FALSE ;
  if ( ReadCylDev( pUnit , 0 , RCDF_QUIET ) && VerifyChkSum( pUnit->au_Buffer ) )
  {
    pHdr = (struct Header *)pUnit->au_Buffer ;
    BDate = pHdr->h_BDate ;
    pHdr->h_BDate = IdntDate ;

    if ( pHdr->h_Type & HT_CRYPT )
    {
      BDate = 0 ;
      Ret = TRUE ;
    }
    else if ( IsNewHeader( pHdr ) && (pHdr->h_Type == HT_BADCYL) ) Ret = TRUE ;

    if ( Ret )
    {
      pHdr->h_BDate = BDate ;
      memcpy( pUnit->au_BadCyls , pHdr , sizeof(struct BadCylMap) ) ;
      if ( ! DevIsReadOnly( pUnit ) ) ClearBadCyl( pUnit ) ;
    }
  }

  memset( pUnit->au_Buffer , '\0' , TD_SECTOR ) ;
  pUnit->au_CurPos = OldPos ;
  StopDev( pUnit , FALSE ) ;
  return( Ret ) ;
}

/****************************************************************************/

BOOL LoadBadCyl( struct ArcUnit *pUnit )

/* $DOC
 * FUNCTION
 *	Loads the bad cylinders map from the given unit.
 * INPUTS
 *	pUnit = pointer to the unit
 * OUTPUTS
 *	Result = success/failure
 * NOTES
 *	If the archive format is unknown when calling this function, it is set
 *	to the format of the data on the unit. Otherwise, the data on the unit
 *	must be of the same archive format.
 *	May fail either because the entire device is unreadable, or map is not
 *	found, or data checksum is not valid.
 * SEE ALSO
 *	StoreBadCyl()
 * $END
 */

{
  LONG k ;
  struct Header *pHdr ;
  struct OldHeader *pOld ;

  /* clear map */
  ClearBadCyl( pUnit ) ;

  /* finds first readable cylinder */
  for ( k = 0 ; k <  pUnit->au_NumCyls ; k++ )
  {
    if ( StopMe() ) return( FALSE ) ;
    if ( ReadCylDev( pUnit , k , RCDF_QUIET ) ) break ;
  }

  pUnit->au_FirstCyl = k ;
  if ( k == pUnit->au_NumCyls ) return( FALSE ) ;
  pUnit->au_CurPos += TD_SECTOR ;

  /* verify first sector */
  if ( (ArchiveFmt == -1) || AfterV4( ArchiveFmt ) )
  {
    pHdr = (struct Header *)pUnit->au_Buffer ;
    if ( VerifyChkSum( (BYTE *)pHdr ) && IsNewHeader( pHdr ) && (pHdr->h_Type == HT_BADCYL) )
    {
      memcpy( pUnit->au_BadCyls , pHdr , sizeof(struct BadCylMap) ) ;
      pUnit->au_CurDisk = pUnit->au_BadCyls->bcm_DiskNum ;
      ArchiveFmt = pHdr->h_Version ;
      return( TRUE ) ;
    }

    if ( AfterV4( ArchiveFmt ) )
    {
      HandleError( pUnit->au_Name , ABERR_BAD_FORMAT ) ;
      return( FALSE ) ;
    }
  }

  /* if no HT_BADCYL found, we must at least have an old header */
  if ( (ArchiveFmt == -1) || BeforeV5( ArchiveFmt ) )
  {
    pOld = (struct OldHeader *)pUnit->au_Buffer ;
    if ( IsOldHeader( pOld , (BYTE *)pUnit->au_BadCyls ) )
    {
      pUnit->au_BadCyls->bcm_Version = pOld->th_version ;
      pUnit->au_BadCyls->bcm_NumBadCyls = 0 ;
      pUnit->au_CurDisk = pOld->th_dsknum ;
      ArchiveFmt = pOld->th_version ;
      return( TRUE ) ;
    }

    if ( BeforeV5( ArchiveFmt ) )
    {
      HandleError( pUnit->au_Name , ABERR_BAD_FORMAT ) ;
      return( FALSE ) ;
    }
  }

  HandleError( pUnit->au_Name , ABERR_NOT_AN_ARCHIVE ) ;
  return( FALSE ) ;
}

/****************************************************************************/

BOOL StoreBadCyl( struct ArcUnit *pUnit )

/* $DOC
 * FUNCTION
 *	Stores the bad cylinders map of the given unit.
 * INPUTS
 *	pUnit = pointer to the unit
 * OUTPUTS
 *	Result = success/failure
 * SEE ALSO
 *	LoadBadCyl()
 * $END
 */

{
  BOOL Ret ;
  static BYTE Idnt[5] ;

  /* reset structure */
  pUnit->au_BadCyls->bcm_Type	  = HT_BADCYL ;
  pUnit->au_BadCyls->bcm_CryptSum = 0 ;
  pUnit->au_BadCyls->bcm_BDate	  = IdntDate ;
  pUnit->au_BadCyls->bcm_Version  = HVER_CURRENT ;

  /* update disk number */
  pUnit->au_BadCyls->bcm_DiskNum = pUnit->au_CurDisk ;
  SPrintf( Idnt , H_IDNT_FMT , pUnit->au_CurDisk ) ;
  memcpy( &(pUnit->au_BadCyls->bcm_Idnt1) , Idnt , sizeof(LONG) ) ;

  /* reads first cylinder directly into unit buffer */
  if (! ReadCylDev( pUnit , pUnit->au_FirstCyl , NULL )) return( FALSE ) ;

  /* write special header at the beginning of the buffer */
  memset( GIOBuf , '\0' , TD_SECTOR ) ;                                 // clear data block
  memcpy( GIOBuf , pUnit->au_BadCyls , sizeof(struct BadCylMap) ) ;     // copy bad cyl map
  if ( IS_BFL_ENCRYPT ) EncryptData( GIOBuf , TD_SECTOR ) ;
  BuildChkSum( GIOBuf ) ;                                               // compute checksum
  memcpy( pUnit->au_Buffer , GIOBuf , TD_SECTOR ) ;                     // copy data in buffer

  /* flush device and exit */
  SeekDev( pUnit , pUnit->au_FirstCyl + 1 ) ;
  SetUnitFlag( pUnit , AUF_DONTSKIP|AUF_BUFFLUSH ) ;
  Ret = (BOOL)FlushDev( pUnit , ICMD_SWRITE ) ;
  ClearUnitFlag( pUnit , AUF_DONTSKIP ) ;
  if ( ! Ret ) UnitError( pUnit ) ;
  return( Ret ) ;
}

/****************************************************************************/

void AddBadCyl( struct ArcUnit *pUnit )

/* $DOC
 * FUNCTION
 *	Adds current cylinder in bad cylinders map
 * INPUTS
 *	pUnit = pointer to the unit
 * $END
 */

{
  LONG Cyl, Pos ;

  /* get and check cylinder number */

  Cyl = CurrentCyl( pUnit ) - 1 ;
  ClearUnitFlag( pUnit , AUF_BUFFLUSH ) ;

  if ( (Cyl < 0) || (Cyl >= MAXBADCYL) ) return ;

  /* add in bitmap */

  Pos = BCM_BYTE( Cyl ) ;
  pUnit->au_BadCyls->bcm_BMap[Pos] |= BCM_MASK( Cyl ) ;
  pUnit->au_BadCyls->bcm_NumBadCyls++ ;
  SetPrgFlag( PF_BADCYL ) ;
}

/****************************************************************************/

BOOL IsBadCyl( struct ArcUnit *pUnit , LONG Cyl )

/* $DOC
 * FUNCTION
 *	Tests if a cylinder is in bad cylinders map
 * INPUTS
 *	pUnit = pointer to the unit
 *	Cyl = cylinder number
 * OUTPUTS
 *	Result = TRUE if bad cylinder, FALSE if ok
 * $END
 */

{
  LONG Pos ;

  if ( ! pUnit->au_BadCyls->bcm_NumBadCyls ) return( FALSE ) ;

  /* check cylinder number */
  if ( Cyl >= MAXBADCYL ) return( FALSE ) ;
  if ( (Cyl < 0) || (Cyl >= pUnit->au_NumCyls) ) return( FALSE ) ;

  /* look in bitmap */
  Pos = BCM_BYTE( Cyl ) ;
  if ( pUnit->au_BadCyls->bcm_BMap[Pos] & BCM_MASK( Cyl ) ) return( TRUE ) ;
  return( FALSE ) ;
}

