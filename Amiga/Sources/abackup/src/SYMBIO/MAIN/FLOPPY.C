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
    floppy.c

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 01-Sep-93
    Modified: 06-Feb-98
    _______________________________________________________________________
*/

#include "headers.h"

static struct DriveGeometry DrvGeom ;

/***************************************************************************/

BOOL FloppyPresent( struct ArcUnit *pUnit )

/* $DOC
 * FUNCTION
 *      Tests if a disk is present in a disk drive
 * INPUTS
 *      pUnit = pointer to the disk unit
 * OUTPUTS
 *      Result = TRUE if disk present
 * $END
 */

{
  if ( DevIsTrackDisk( pUnit ) )
  {
    MyDoIO( pUnit , TD_CHANGESTATE ) ;
    if ( pUnit->au_Result ) return( FALSE ) ;
  }

  return( TRUE ) ;
}

/***************************************************************************/

BOOL FloppyWasChanged( struct ArcUnit *pUnit )

/* $DOC
 * FUNCTION
 *      Tests if disk has been changed in a disk drive, and update
 *      unit change count
 * INPUTS
 *      pUnit = pointer to the disk unit
 * OUTPUTS
 *      Result = TRUE if disk changed
 * $END
 */

{
  LONG Count ;
  BOOL Res = FALSE ;

  if ( DevIsTrackDisk( pUnit ) )
  {
    Count = pUnit->au_IOReq->iotd_Count ;
    MyDoIO( pUnit , TD_CHANGENUM ) ;
    pUnit->au_IOReq->iotd_Count = pUnit->au_Result ;
    if ( pUnit->au_IOReq->iotd_Count != Count ) Res = TRUE ;
  }

  return( Res ) ;
}

/***************************************************************************/

BOOL PrepareFloppy( struct ArcUnit *pUnit )

/* $DOC
 * FUNCTION
 *      Prepares a new floppy disk for beeing accessed: reads disk
 *      geometry, allocates buffers, etc...
 * INPUTS
 *      pUnit = pointer to the unit
 * OUTPUTS
 *      Result = success/failure
 * SEE ALSO
 *      PrepareDev()
 * $END
 */

{
  struct IOStdReq *pReq ;

  pReq = &(pUnit->au_IOReq->iotd_Req) ;

  /* check if there's a disk */

  while ( ! FloppyPresent( pUnit ) )
    if ( FULLBATCHMODE || (! DiskRequest( pUnit , DiskNum )) ) return( FALSE ) ;

  /* get change count */

  MyDoIO( pUnit , TD_CHANGENUM ) ;
  pUnit->au_IOReq->iotd_Count = pUnit->au_Result ;

  /* get cylinder size */

  pReq->io_Data        = (APTR)&DrvGeom ;
  pReq->io_Length      = sizeof(struct DriveGeometry) ;
  MyDoIO( pUnit , TD_GETGEOMETRY ) ;

  pUnit->au_NumCyls    = DrvGeom.dg_Cylinders ;
  pUnit->au_NumSectors = DrvGeom.dg_CylSectors ;
  pUnit->au_CylSize    = pUnit->au_NumSectors * DrvGeom.dg_SectorSize ;
  pUnit->au_DeviceDef->dd_Env.de_BufMemType = DrvGeom.dg_BufMemType ;

  return( TRUE ) ;
}

/***************************************************************************/

BOOL AskGoodDisk( struct List *pArc , LONG DiskNum )

/* $DOC
 * FUNCTION
 *      Asks the user to insert a certain floppy disk.
 * INPUTS
 *      pArc = pointer to an archive, returned by OpenArc()
 *      DiskNum = number of the disk to ask
 * OUTPUTS
 *      Result = success/failure
 * NOTES
 *      See DiskRequest()
 * $END
 */

{
  struct ArcUnit *pUnit ;

  pUnit = FindCurUnit( pArc ) ;
/*  if (! DevIsTrackDisk( pUnit )) return( TRUE ) ; */

  /* check if not already in current unit */
  if ( (! FloppyWasChanged( pUnit )) &&
       (pUnit->au_CurDisk == DiskNum) ) return( TRUE ) ;

  /* close current unit */
  if (! CleanupDev( pUnit )) return( FALSE ) ;

  /* select next unit */
  pUnit = SetCurUnit( pArc , SCU_NEXT ) ;

  /* open this unit */
  if ( FloppyPresent( pUnit ) && FloppyWasChanged( pUnit ) )
  {
    if (! PrepareDev( pUnit , NULL )) return( FALSE ) ;
    if ( pUnit->au_CurDisk == DiskNum ) return( TRUE ) ;
  }

  if ( FULLBATCHMODE ) return( FALSE ) ;
  return( DiskRequest( pUnit , (PrgAction == PA_REBUILD) ? DR_NEXTDISK : DiskNum ) ) ;
}

/***************************************************************************/

struct ArcUnit *NextFloppy( struct List *pArc )

/* $DOC
 * FUNCTION
 *      Asks for next disk, either for reading or writing
 * INPUTS
 *      pArc = pointer to an archive, returned by OpenArc()
 * OUTPUTS
 *      Result = pointer to new unit, or NULL if failed
 * NOTES
 *      See AskGoodDisk()
 * $END
 */

{
  struct ArcUnit *pUnit ;

  if ( HasBeenBreaked() ) return( NULL ) ;

  pUnit = FindCurUnit( pArc ) ;
/*  if (! DevIsTrackDisk( pUnit )) return( NULL ) ; */

  DiskNum = pUnit->au_CurDisk+1 ;
  if (! AskGoodDisk( pArc , DiskNum )) return( NULL ) ;

  return( FindCurUnit( pArc ) ) ;
}

