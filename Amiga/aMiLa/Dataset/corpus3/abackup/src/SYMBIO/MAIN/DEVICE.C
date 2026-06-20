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
    device.c

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
#include "childtask.h"

#define UseChildTask( p )       ( DevIsASync(p) && (! ((p)->au_Flags & AUF_PENDING)) )

#include "device_sub.c"

/***************************************************************************/

static BOOL AllocIOBuf( struct ArcUnit *pUnit )

/* $DOC
 * FUNCTION
 *	Allocate I/O buffers for the given unit. The verify buffer is
 *	allocated only in write mode and if verification is enabled.
 * INPUTS
 *	pUnit = pointer to the unit
 * OUTPUTS
 *	Result = success/failure
 * SEE ALSO
 *	FreeIOBuf()
 * $END
 */

{
  pUnit->au_Buffer = AllocObject( ABO_DEVBUFFER , pUnit ) ;
  if ( ! pUnit->au_Buffer ) return( FALSE ) ;

  if ( (! DevIsReadOnly( pUnit )) && IS_BFL_VERIFY )
  {
    pUnit->au_VBuffer = AllocObject( ABO_DEVBUFFER , pUnit ) ;
    if ( ! pUnit->au_VBuffer ) return( FALSE ) ;
  }
  else pUnit->au_VBuffer = NULL ;

  return( TRUE ) ;
}

/***************************************************************************/

static void FreeIOBuf( struct ArcUnit *pUnit )

/* $DOC
 * FUNCTION
 *	Free the I/O buffers allocated by AllocIOBuf()
 * INPUTS
 *	pUnit = pointer to the unit
 * $END
 */

{
  if ( pUnit->au_Buffer  )
  {
    FreeObject( pUnit->au_Buffer ) ;
    pUnit->au_Buffer = NULL ;
  }

  if ( pUnit->au_VBuffer  )
  {
    FreeObject( pUnit->au_VBuffer ) ;
    pUnit->au_VBuffer = NULL ;
  }
}

/***************************************************************************/

BOOL PrepareDev( struct ArcUnit *pUnit , LONG Flags )

/* $DOC
 * FUNCTION
 *	Prepares a device for beeing accessed (allocate buffers, load bad
 *	cylinders map, etc...)
 * INPUTS
 *	pUnit = pointer to the unit to prepare
 *	Flags = any combination of:
 *		PDF_DONTINHIBIT 	do not inhibit device
 * OUTPUTS
 *	Result = success/failure
 * SEE ALSO
 *	CleanupDev(), PrepareFloppy()
 * $END
 */

{
  BOOL loop ;

  if ( pUnit->au_Type != AUT_DEVICE ) return( TRUE ) ;

  do
  {
    loop = FALSE ;

    /* special case for floppy disks */

    if ( DevIsTrackDisk( pUnit ) && (! PrepareFloppy( pUnit )) ) return( FALSE ) ;

    /* check if write protected */

    MyDoIO( pUnit , TD_PROTSTATUS ) ;
    if ( pUnit->au_Result )
    {
      SetUnitFlag( pUnit , AUF_PROTECTED ) ;
      if (! DevIsReadOnly( pUnit ))
      {
	if ( FULLBATCHMODE ) return( FALSE ) ;
	if (! YesNoRequest( GetStr( MSG_WARN_WRITE_PROTECTED ) , pUnit->au_Name , MSG_REQ_RETRY_CANCEL , TRUE ))
	  return( FALSE ) ;
	loop = TRUE ;
      }
    }
    else ClearUnitFlag( pUnit , AUF_PROTECTED ) ;
  }
  while ( loop ) ;

  SetUnitFlag( pUnit , AUF_ACCESS ) ;
  if ( ! AllocIOBuf( pUnit ) ) return( FALSE ) ;

  /* update essential info when using a disk partition */

  if ( ! DevIsTrackDisk( pUnit ) )
  {
    while ( ! UpdateDevFromRDB( pUnit ) )
      if ( FULLBATCHMODE || (! DiskRequest( pUnit , DiskNum )) ) return( FALSE ) ;

    /* re-allocate I/O buffer since cylinder size may have changed */

    FreeIOBuf( pUnit ) ;
    if ( ! AllocIOBuf( pUnit ) ) return( FALSE ) ;
  }

  /* seek to start of device */

  pUnit->au_FirstCyl =	0 ;
  pUnit->au_CurCyl   = -1 ;
  pUnit->au_CurPos   = BeginOfDev( pUnit ) ;
  if ( DevIsArchive( pUnit ) ) pUnit->au_CurPos += TD_SECTOR ;

  if ( (! DevIsReadOnly( pUnit )) && (! (Flags & PDF_DONTINHIBIT)) ) InhibitDev( pUnit , TRUE ) ;

  /* load or clear bad cylinder map */

  if ( pUnit->au_Flags & AUF_LOADBADCYL )
  {
    if ( DevIsArchive( pUnit ) ) return( LoadBadCyl( pUnit ) ) ;
    return( TRUE ) ;
  }

  if ( ArchiveFmt == -1 ) ArchiveFmt = HVER_CURRENT ;
  pUnit->au_CurDisk = DiskNum ;
  ClearBadCyl( pUnit ) ;
  return( TRUE ) ;
}

/***************************************************************************/

struct ArcUnit *FlushDev( struct ArcUnit *pUnit , LONG Cmd )

/* $DOC
 * FUNCTION
 *	Flushes the data buffer of a device unit.
 *	CAUTION ! DON'T FORGET THAT pUnit->au_CurPos IS THE OFFSET OF THE
 *	FIRST BYTE AFTER DATA TO WRITE, AND NOT THE OFFSET WHERE TO WRITE !!
 * INPUTS
 *	pUnit = pointer to unit to flush
 *	Cmd = child task command
 *		ICMD_SWRITE	immediate write (to use when unit locked)
 *		ICMD_SYNC	wait end of queued writes
 *		-1		does nothing if child task is here, else
 *				write buffer to device
 * OUTPUTS
 *	Result = pointer to new unit to use, or NULL if failed
 * NOTES
 *	See DoFlushDev()
 * $END
 */

{
  LONG Offset ;

  if ( DevIsASync( pUnit ) )
  {
    if ( Cmd == -1 ) return( pUnit ) ;
    if ( DoASyncIO( pUnit , Cmd , NULL , 0 ) ) return( pUnit ) ;

    pUnit = FindCurUnit( pUnit->au_Parent ) ;
    if ( pUnit->au_LastErr ) UnitError( pUnit ) ;
    return( NULL ) ;
  }

  if ( ! DevIsToUpdate( pUnit ) ) return( pUnit ) ;

  FOREVER
  {
    /* write data */
    DoFlushDev( pUnit ) ;
    ClearUnitFlag( pUnit , AUF_BUFFLUSH ) ;
    if ( ! pUnit->au_LastErr ) return( pUnit ) ;

    if ( pUnit->au_LastErr >= TDERR_WriteProt )
    {
      UnitError( pUnit ) ;
      return( NULL ) ;
    }

    Offset = CurrentCyl( pUnit ) ;
    ReportBadCyl( pUnit , Offset ) ;

    /* failed: try next cylinder */
    if ( (pUnit->au_Flags & AUF_DONTSKIP) || (Offset >= MAXBADCYL) )
    {
      UnitError( pUnit ) ;
      return( NULL ) ;
    }

    AddBadCyl( pUnit ) ;

    if ( Offset < 1 ) return( NULL ) ;
    if ( Offset >= pUnit->au_NumCyls ) return( FlushOnNextUnit( pUnit ) ) ;

    if ( Offset == pUnit->au_FirstCyl+1 ) pUnit->au_FirstCyl++ ;
    pUnit->au_CurPos += pUnit->au_CylSize ;
  }
}

/***************************************************************************/

void StopDev( struct ArcUnit *pUnit , BOOL Uninhibit )

/* $DOC
 * FUNCTION
 *	Stop motor and un-inhibit the given unit
 * INPUTS
 *	pUnit = pointer to an unit
 *	Uninhibit = TRUE if device is to un-inhibit
 * $END
 */

{
  if ( ! DevIsASync( pUnit ) )
  {
    if ( DevIsOpened( pUnit ) && DevIsTrackDisk( pUnit ) )
    {
      pUnit->au_IOReq->iotd_Req.io_Length = 0 ;
      MyDoIO( pUnit , TD_MOTOR ) ;
    }

    if ( Uninhibit && DevIsInhibited( pUnit ) ) InhibitDev( pUnit , FALSE ) ;
  }
}

/***************************************************************************/

BOOL CleanupDev( struct ArcUnit *pUnit )

/* $DOC
 * FUNCTION
 *	Prepares a device for beeing removed/closed (free buffers, store
 *	bad cylinders map, etc...)
 * INPUTS
 *	pUnit = pointer to an unit
 * OUTPUTS
 *	Result = success/failure
 * $END
 */

{
  BOOL Ret = TRUE ;
  struct ArcUnit *pNUnit ;

  if ( pUnit->au_Type != AUT_DEVICE ) return( TRUE ) ;

  /* flush buffer */

  if ( DevIsReady( pUnit ) )
    if ( ! HasBeenBreaked() )
    {
      pNUnit = FlushDev( pUnit , -1 ) ;
      if ( pNUnit ) pUnit = pNUnit ;
	       else Ret = FALSE ;
      if ( (! DevIsReadOnly( pUnit )) && DevIsArchive( pUnit ) ) Ret = StoreBadCyl( pUnit ) ;
    }
    else if ( DevIsASync( pUnit ) ) DoASyncIO( pUnit , ICMD_SYNC , NULL , 0 ) ;

  /* Stop motor and un-inhibit */

  StopDev( pUnit , TRUE ) ;
  if ( DevIsInhibited( pUnit ) ) InhibitDev( pUnit , FALSE ) ;

  FreeIOBuf( pUnit ) ;

  ClearUnitFlag( pUnit , AUF_ACCESS ) ;
  pUnit->au_CurCyl = -1 ;
  return( Ret ) ;
}

/***************************************************************************/

BOOL SeekDev( struct ArcUnit *pUnit , LONG Cyl )

/* $DOC
 * FUNCTION
 *	Seeks to the given cylinder.
 * INPUTS
 *	pUnit = pointer to an unit
 *	Cyl = cylinder number (NOT CHECKED !)
 * OUTPUTS
 *	Result = success/failure
 * $END
 */

{
  BOOL ret ;

  ret = DoSeekDev( pUnit , Cyl ) ;
  if ( ret ) pUnit->au_CurPos += BeginOfDev( pUnit ) ;
  return( ret ) ;
}

/***************************************************************************/

BOOL ReadCylDev( struct ArcUnit *pUnit , LONG Cyl , LONG Flags )

/* $DOC
 * FUNCTION
 *	Reads a full cylinder.
 * INPUTS
 *	pUnit = pointer to the unit to read from
 *	Cyl = number of the desired cylinder (NOT CHECKED !)
 *	Flags = combination of:
 *		RCDF_PUTCYLSIZE : writes cylinder size in the sizeof(LONG) first
 *				  bytes of the buffer
 *		RCDF_QUIET	: silently fails (no error message)
 *		RCDF_REALCYL	: don't offset the cyl by LowCyl
 * OUTPUTS
 *	Result = TRUE if succes, data is in unit buffer
 * $END
 */

{
  BOOL ret ;
  struct IOStdReq *pReq ;

  if ( pUnit->au_Type != AUT_DEVICE ) return( TRUE ) ;
  if ( (! DevIsReady( pUnit )) && (! PrepareDev( pUnit , NULL )) ) return( FALSE ) ;

  if ( Cyl != pUnit->au_CurCyl )
  {
    /* seek to cylinder position */

    ret = ( Flags & RCDF_REALCYL ) ? DoSeekDev( pUnit , Cyl ) : SeekDev( pUnit , Cyl ) ;
    if ( ! ret ) return( FALSE ) ;

    /* read data */

    pReq = &(pUnit->au_IOReq->iotd_Req) ;
    pReq->io_Length = pUnit->au_CylSize ;
    pReq->io_Data   = ( Flags & RCDF_PUTCYLSIZE ) ? &pUnit->au_Buffer[sizeof(LONG)] : pUnit->au_Buffer ;
    pReq->io_Offset = pUnit->au_CurPos ;
    MyDoIO( pUnit , CMD_READ ) ;

    if ( pUnit->au_LastErr )
    {
      if (! (Flags & RCDF_QUIET)) UnitError( pUnit ) ;
      return( FALSE ) ;
    }
    if ( Flags & RCDF_PUTCYLSIZE ) memcpy( pUnit->au_Buffer , &pUnit->au_CylSize , sizeof(LONG) ) ;
    pUnit->au_CurCyl = Cyl ;
  }

  return( TRUE ) ;
}

/***************************************************************************/

BOOL ReadBlockDev( struct ArcUnit *pUnit , LONG blk , UBYTE *pbuf )

/* $DOC
 * FUNCTION
 *	Reads a single block on a device.
 * INPUTS
 *	pUnit = pointer to the unit to read from
 *	blk   = number of the desired block (NOT CHECKED !)
 *		this is assumed to be a "real" block number, this mean that
 *		it is not offset by the first block number of the unit
 *	pbuf  = pointer to the location where to read the data in
 * OUTPUTS
 *	Result = TRUE if succes, data is in the given buffer
 * $END
 */

{
  LONG cyl ;
  BOOL ret = FALSE ;

  cyl = blk / pUnit->au_NumSectors ;
  if ( ReadCylDev( pUnit , cyl , RCDF_QUIET|RCDF_REALCYL ) )
  {
    cyl = ( blk % pUnit->au_NumSectors ) * TD_SECTOR ;
    memcpy( pbuf , &pUnit->au_Buffer[cyl] , TD_SECTOR ) ;
    ret = TRUE ;
  }

  return( ret ) ;
}

/***************************************************************************/

BOOL ReadDev( struct ArcUnit *pUnit , BYTE *pData , LONG Len )

/* $DOC
 * FUNCTION
 *	Reads data from a device
 * INPUTS
 *	pUnit = pointer to the unit to read from
 *	pData = pointer to the buffer where to put the data
 *	Len = number of bytes to read
 * OUTPUTS
 *	Result = success/failure
 * $END
 */

{
  LONG Size, Left ;

  if ( pUnit->au_Type != AUT_DEVICE ) return( TRUE ) ;
  if ( (! DevIsReady( pUnit )) && (! PrepareDev( pUnit , NULL )) ) return( FALSE ) ;

  /* reads till end of current cylinder */
  Left = LeftOnCyl( pUnit ) ;
  if ( Left > 0 )
  {
    Size = MIN( Len , Left ) ;
    pUnit = DoReadDev( pUnit , pData , Size ) ;
    if ( ! pUnit ) return( FALSE ) ;
    pData += Size ;
    Len -= Size ;
  }

  /* loop on cylinders */
  for ( Size = pUnit->au_CylSize ; Len > Size ; )
  {
    pUnit = DoReadDev( pUnit , pData , Size ) ;
    if ( ! pUnit ) return( FALSE ) ;
    pData += Size ;
    Len -= Size ;
  }

  /* read beginning of last cylinder */
  if ( Len > 0 )
  {
    Size = RoundToSector( Len ) ;
    pUnit = DoReadDev( pUnit , pData , Size ) ;
    if ( ! pUnit ) return( FALSE ) ;
  }

  return( TRUE ) ;
}

/***************************************************************************/

BOOL WriteDev( struct ArcUnit *pUnit , BYTE *pData , LONG Len )

/* $DOC
 * FUNCTION
 *	Writes data to a device
 * INPUTS
 *	pUnit = pointer to the unit to write to
 *	pData = pointer to the buffer containing data to write
 *	Len = number of bytes to write
 * OUTPUTS
 *	Result = success/failure
 * $END
 */

{
  LONG Cyl, Left ;
  size_t ToCopy ;

  if ( pUnit->au_Type != AUT_DEVICE ) return( TRUE ) ;
  if ( (! DevIsReady( pUnit )) && (! PrepareDev( pUnit , NULL )) ) return( FALSE ) ;

  if ( DevIsASync( pUnit ) ) return( (BOOL)DoASyncIO( pUnit , ICMD_AWRITE , pData , Len ) ) ;

  /* write loop */
  while ( Len > 0 )
  {
    /* test if we try to write past end of disk */
    Cyl = CurrentCyl( pUnit ) ;
    if ( Cyl >= pUnit->au_NumCyls )
    {
      pUnit = NextFloppy( pUnit->au_Parent ) ;
      if ( ! pUnit ) return( FALSE ) ;
    }

    /* copy data to buffer */
    Cyl  = pUnit->au_CurPos % pUnit->au_CylSize ;
    Left = pUnit->au_CylSize - Cyl ;
    ToCopy = MIN( Len , Left ) ;
    if ( ToCopy )
    {
      memcpy( &pUnit->au_Buffer[Cyl] , pData , ToCopy ) ;
      pUnit->au_CurPos += ToCopy ;
    }

    SetUnitFlag( pUnit , AUF_BUFFLUSH ) ;

    /* should we flush buffer ? */
    if ( ToCopy == Left )
    {
      pUnit = FlushDev( pUnit , -1 ) ;
      if ( ! pUnit ) return( FALSE ) ;
    }

    /* advance in input buffer */
    pData += ToCopy ;
    Len -= ToCopy ;
  }

  return( TRUE ) ;
}

/***************************************************************************/

BOOL CloseDev( struct ArcUnit *pUnit )

/* $DOC
 * FUNCTION
 *	Close down access to a device
 * INPUTS
 *	pUnit = pointer to the unit to close
 * OUTPUTS
 *	Result = success/failure
 *	This function may fail if a write error occurs when flushing unit buffer.
 * NOTES
 *	The unit structure is freed by this function so don't use pUnit after,
 *	even if it returned FALSE.
 * $END
 */

{
  BOOL Ret ;

  if ( pUnit->au_Type != AUT_DEVICE ) return( TRUE ) ;

  Ret = CleanupDev( pUnit ) ;
  if ( DevIsASync( pUnit ) ) DoASyncIO( pUnit , ICMD_CLOSE , NULL , 0 ) ;
			else DoCloseDev( pUnit ) ;

  if ( pUnit->au_BadCyls ) FreeObject( pUnit->au_BadCyls ) ;
  if ( pUnit->au_Parent ) Remove( (struct Node *)pUnit ) ;
  FreeObject( pUnit ) ;
  return( Ret ) ;
}

/***************************************************************************/

struct ArcUnit *OpenDev( struct Object *pObj , LONG Mode , LONG Flags )

/* $DOC
 * FUNCTION
 *	Opens ressources to allow access to a device
 * INPUTS
 *	pObj = pointer to the object describing the device to open
 *	Mode = OAF_READ, OAF_WRITE, OAF_DUMMY
 *	Flags = any combination of:
 *		OAF_USECHILDTASK	use child task if opened for writing
 * OUTPUTS
 *	Result = pointer to an unit structure, or NULL if failed
 * SEE ALSO
 *	CloseDev()
 * $END
 */

{
  BYTE *p ;
  BOOL Ret ;
  struct DosEnvec *pEnv ;
  struct ArcUnit *pUnit ;
  struct DeviceDef *pDef ;

  /* allocate the ArcUnit structure */

  pDef = GetDeviceDef( pObj ) ;
  if ( ! pDef ) return( NULL ) ;
  pUnit = AllocObject( ABO_ARCUNIT , pObj->obj_Name ) ;
  if ( ! pUnit ) return( NULL ) ;

  /* initialize the ArcUnit structure */

  pEnv = (struct DosEnvec *)&(pDef->dd_Env) ;
  pUnit->au_Type       = AUT_DEVICE ;
  pUnit->au_NumCyls    = pEnv->de_HighCyl - pEnv->de_LowCyl + 1 ;
  pUnit->au_NumSectors = pEnv->de_BlocksPerTrack ;
  pUnit->au_CylSize    = pEnv->de_Surfaces * pEnv->de_BlocksPerTrack * pEnv->de_SizeBlock * 4 ;
  pUnit->au_DeviceDef  = pDef ;

{
char msg[256];
SPrintf(msg,"%s has %ld cylinders of %ld bytes => total size %ld\n", pObj->obj_Name ,
  pUnit->au_NumCyls , pUnit->au_CylSize , pUnit->au_NumCyls*pUnit->au_CylSize ) ;
Write( Output() , msg , strlen(msg) ) ;
}

  if ( (Mode == OAF_WRITE) && (pUnit->au_NumCyls >= MAXBADCYL) )
    YesNoRequest( GetStr( MSG_WARN_BADCYL_OVERFLOW ) , (STRPTR)MAXBADCYL , MSG_REQ_OK , FALSE ) ;

  /* dummy devices just need a buffer */

  if ( Mode == OAF_DUMMY )
  {
    pUnit->au_Buffer = AllocObject( ABO_DEVBUFFER , pUnit ) ;
    if ( ! pUnit->au_Buffer )
    {
      CloseDev( pUnit ) ;
      pUnit = NULL ;
    }
    return( pUnit ) ;
  }

  /* open i/o ressources for access */

  if ( HasChildTask() && (Mode == OAF_WRITE) && (Flags & OAF_USECHILDTASK) )
  {
    SetUnitFlag( pUnit , AUF_ASYNC ) ;
    Ret = DoASyncIO( pUnit , ICMD_OPEN , (BYTE *)pDef , 0 ) ;
  }
  else Ret = DoOpenDev( pUnit , pDef ) ;

  if ( ! Ret )
  {
    CloseDev( pUnit ) ;
    return( NULL ) ;
  }

  /* end of initialisation */

  if (! (pUnit->au_BadCyls = AllocObject( ABO_BADCYLMAP , NULL )))
  {
    CloseDev( pUnit ) ;
    return( NULL ) ;
  }

  /* set "floppy" flag if device driver is "trackdisk" or "diskspare" */

  p = FilePart( pDef->dd_Name ) ;
  if ( (! strcmp( p , TD_NAME )) || (! strcmp( p , "diskspare.device" )) )
  {
    SetUnitFlag( pUnit , AUF_TRACKDISK ) ;
    FloppyWasChanged( pUnit ) ;
  }

  if ( Mode == OAF_READ ) SetUnitFlag( pUnit , AUF_READONLY|AUF_LOADBADCYL ) ;
  return( pUnit ) ;
}
