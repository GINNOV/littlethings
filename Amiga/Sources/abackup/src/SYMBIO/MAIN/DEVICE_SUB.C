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
    device_sub.c

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 01-Sep-93
    Modified: 06-Feb-98
    _______________________________________________________________________
*/

/****************************************************************************/

void InhibitDev( struct ArcUnit *pUnit , BOOL Flag )

/* $DOC
 * FUNCTION
 *	Makes a device busy or available
 * INPUTS
 *	pUnit = pointer to the unit
 *	Flag = TRUE to make it busy, FALSE to make it available
 * $END
 */

{
  if ( pUnit->au_Type != AUT_DEVICE ) return ;
  if ( Flag && DevIsInhibited( pUnit ) ) return ;

  Inhibit( pUnit->au_Name , (long)Flag ) ;

  if ( Flag ) SetUnitFlag( pUnit , AUF_INHIBITED ) ;
	 else ClearUnitFlag( pUnit , AUF_INHIBITED ) ;
}

/****************************************************************************/

void MyDoIO( struct ArcUnit *pUnit , LONG Cmd )

/* $DOC
 * FUNCTION
 *	Lowest-level function for sending a command to a device/tape
 * INPUTS
 *	pUnit = pointer to the unit to which to send the command
 *	Cmd = command (e.g. CMD_WRITE)
 * $END
 */

{
  struct IOStdReq *pReq ;

  if ( pUnit->au_Type == AUT_FILE ) return ;

  pReq = &(pUnit->au_IOReq->iotd_Req) ;

  pReq->io_Flags    = 0 ;
  pUnit->au_LastErr = 0 ;
  pReq->io_Command  = Cmd ;

  if ( UseChildTask( pUnit ) )
  {
    if (! DoASyncIO( pUnit , ICMD_DOIO , NULL , 0 )) pReq->io_Error = TDERR_NotSpecified ;
  }
  else
  {
    DoIO( (struct IORequest *)pUnit->au_IOReq ) ;
    pUnit->au_Result = pReq->io_Actual ;
  }

  pUnit->au_LastErr = pReq->io_Error ;
}

/***************************************************************************/

void DoCloseDev( struct ArcUnit *pUnit )

/* $DOC
 * FUNCTION
 *	Closes a device (lowest-level)
 * INPUTS
 *	pUnit = pointer to the unit
 * NOTES
 *	This function is also used for AUT_TAPE units
 * $END
 */

{
  if ( DevIsOpened( pUnit ) )   CloseDevice( (struct IORequest *)pUnit->au_IOReq ) ;
  if ( pUnit->au_IOReq   )      DeleteIORequest( (struct IORequest *)pUnit->au_IOReq ) ;
  if ( pUnit->au_MsgPort )      DeleteMsgPort( pUnit->au_MsgPort ) ;
}

/***************************************************************************/

BOOL DoOpenDev( struct ArcUnit *pUnit , struct DeviceDef *pDef )

/* $DOC
 * FUNCTION
 *	Opens a device (lowest-level)
 * INPUTS
 *	pUnit = pointer to the corresponding unit
 *	pDef = pointer to the corresponding device definition
 * OUTPUTS
 *	Result = success/failure
 * NOTES
 *	This function is also used for AUT_TAPE units.
 * $END
 */

{
  pUnit->au_LastErr = TDERR_NoMem ;

  if ( pUnit->au_MsgPort = CreateMsgPort() )
    if ( pUnit->au_IOReq = (struct IOExtTD *)CreateIORequest( pUnit->au_MsgPort , sizeof(struct IOExtTD) ) )
    {
      pUnit->au_LastErr = OpenDevice( pDef->dd_Name , pDef->dd_Unit , (struct IORequest *)pUnit->au_IOReq , pDef->dd_Flags ) ;
      if ( ! pUnit->au_LastErr )
      {
	SetUnitFlag( pUnit , AUF_OPENED ) ;
	return( TRUE ) ;
      }
    }

  return( FALSE ) ;
}

/***************************************************************************/

static struct ArcUnit *FlushOnNextUnit( struct ArcUnit *pUnit )

/* $DOC
 * FUNCTION
 *	Flush unit buffer on the next unit, after a hard error has occured.
 *	Works only when backing up to floppies.
 * INPUTS
 *	pUnit = pointer to the unit on which we had an error
 * OUTPUTS
 *	Result = pointer to new unit to use, or NULL if failed
 * $END
 */

{
  BYTE *pBuffer ;
  LONG Pos, CSize ;

  if (! DevIsArchive( pUnit )) return( NULL ) ;

  /* copy the buffer because will be freed by NextFloppy() */
  CSize = pUnit->au_CylSize ;
  pBuffer = AllocObject( ABO_DEVBUFFER , pUnit ) ;
  if ( ! pBuffer ) return( NULL ) ;
  memcpy( pBuffer , pUnit->au_Buffer , (size_t)CSize ) ;

  /* ask next disk */
  if (! NextFloppy( pUnit->au_Parent ))
  {
    FreeObject( pBuffer ) ;
    return( NULL ) ;
  }

  /* write data on new disk */
  Pos = WriteDev( pUnit , pBuffer , CSize ) ;
  FreeObject( pBuffer ) ;
  if ( Pos ) return( pUnit ) ;
  return( NULL ) ;
}

/***************************************************************************/

void DoFlushDev( struct ArcUnit *pUnit )

/* $DOC
 * FUNCTION
 *	Flush data to device (lowest-level) : write and verify data
 *	but doesn't skip bad cylinders.
 * INPUTS
 *	pUnit = pointer to the unit to flush
 *	pBuffer = pointer to data to write
 * OUTPUTS
 *	pUnit->au_LastError = error code, or 0 if ok
 * NOTES
 *	Uses a TD_FORMAT command if possible, rather than a CMD_WRITE command.
 *	Automatically verifies data if the pUnit->au_VBuffer field is not NULL
 *	Updates the archive catalog for each header found in the buffer
 *	The unit buffer is not cleared, and the current position is not changed.
 * $END
 */

{
  LONG Offset, Pos ;
  struct Header *pHdr ;
  struct IOStdReq *pReq ;
  static BYTE tmp[TD_SECTOR] ;

  /* check that we can write on this unit */

  if ( pUnit->au_Type != AUT_DEVICE ) return ;
  if ( DevIsReadOnly( pUnit ))
  {
    pUnit->au_LastErr = TDERR_WriteProt ;
    return ;
  }

  pUnit->au_LastErr = 0 ;
  if ( HasBeenBreaked() ) return ;

  /* clear the end of the buffer (if unused) */

  Offset = pUnit->au_CurPos % pUnit->au_CylSize ;
  Pos = pUnit->au_CylSize - Offset ;
  if ( Offset && (Pos > 0) ) memset( &pUnit->au_Buffer[Offset] , '\0' , (size_t)Pos ) ;

  /* compute offset of the first byte in buffer */

  if ( ! Offset ) Offset = pUnit->au_CylSize ;
  Offset = pUnit->au_CurPos - Offset ;
  pUnit->au_CurCyl = Offset / pUnit->au_CylSize ;

  if ( HasDiskGauge() && Offset ) MonitorDiskGauge( pUnit , 0 ) ;

  /* prepare the I/O request block */

  pReq = &(pUnit->au_IOReq->iotd_Req) ;
  pReq->io_Length = pUnit->au_CylSize ;
  pReq->io_Data   = pUnit->au_Buffer ;
  pReq->io_Offset = Offset ;

  /* write data */

  MyDoIO( pUnit , DevIsFormatable( pUnit ) ? TD_FORMAT : CMD_WRITE ) ;

  if ( (! pUnit->au_LastErr) && DevIsTrackDisk( pUnit ) )
  {
    MyDoIO( pUnit , CMD_UPDATE ) ;
    MyDoIO( pUnit , CMD_CLEAR ) ;
  }

  if ( pUnit->au_LastErr ) return ;

  /* verify data written */

  if ( pUnit->au_VBuffer )
  {
    pReq->io_Length = pUnit->au_CylSize ;
    pReq->io_Data   = pUnit->au_VBuffer ;
    pReq->io_Offset = Offset ;
    MyDoIO( pUnit , CMD_READ ) ;
    if ( pUnit->au_LastErr || memcmp( pUnit->au_Buffer , pUnit->au_VBuffer , (size_t)pUnit->au_CylSize ) )
    {
      pUnit->au_LastErr = TDERR_NotSpecified ;
      return ;
    }
  }

  /* update the catalog for each header in the cylinder buffer */

  Offset -= BeginOfDev( pUnit ) ;
  for ( Pos = 0 ; Pos < pUnit->au_CylSize ; Pos += TD_SECTOR )
  {
    pHdr = (struct Header *)(&pUnit->au_Buffer[Pos]) ;
    if ( (pHdr->h_Idnt1 & H_IDNT_MSK) == H_IDNT )
    {
      memcpy( tmp , &pUnit->au_Buffer[Pos] , TD_SECTOR ) ;
      pHdr = (struct Header *)tmp ;
      if ( IsNewHeader( pHdr )        &&
	   (pHdr->h_Type != HT_SPLIT) &&
	   (pHdr->h_Type != HT_BADCYL) )
	AddToCatalog( (struct Object *)pHdr->h_Obj.obj_Node.mln_Succ , pUnit->au_CurDisk , Offset+Pos ) ;
    }
  }
}

/***************************************************************************/

static struct ArcUnit *DoReadDev( struct ArcUnit *pUnit , BYTE *pData , LONG Len )

/*
 * Reads "Len" bytes from device, into the given buffer
 * Lowest-level function, which skip bad cylinders and ask new
 * disk if last cylinder reached
 * Returns a pointer to the new unit to use, or NULL if failed
 */

{
  LONG Cyl, Size ;

  while ( Len > 0 )
  {
    /* test if data is already in the buffer */

    Cyl = CurrentCyl( pUnit ) ;
    if ( Cyl != pUnit->au_CurCyl )
    {
      /* get and check current position */

_restart:
      while ( IsBadCyl( pUnit , Cyl ) )
      {
	pUnit->au_CurPos += pUnit->au_CylSize ;
	Cyl++ ;
      }

      /* ask for a new disk if needed */

      if ( Cyl >= pUnit->au_NumCyls )
      {
	pUnit = NextFloppy( pUnit->au_Parent ) ;
	if ( ! pUnit ) return( NULL ) ;
	Cyl = CurrentCyl( pUnit ) ;
	goto _restart ;
      }

      if ( HasInterface() && (NewID == WIN_MONITOR) ) MonitorDiskGauge( pUnit , 0 ) ;

      /* read data from the device */

      if (! ReadCylDev( pUnit , Cyl , NULL )) return( NULL ) ;
    }

    /* copy data to the user buffer */

    Cyl  = pUnit->au_CurPos % pUnit->au_CylSize ;
    Size = pUnit->au_CylSize - Cyl ;
    if ( Size > Len ) Size = Len ;
    memcpy( pData , &pUnit->au_Buffer[Cyl] , (size_t)Size ) ;
    pUnit->au_CurPos += Size ;
    pData += Size ;
    Len -= Size ;
  }

  return( pUnit ) ;
}

/***************************************************************************/

static BOOL DoSeekDev( struct ArcUnit *pUnit , LONG Cyl )

/* $DOC
 * FUNCTION
 *	Seeks to the given cylinder.
 * INPUTS
 *	pUnit = pointer to an unit
 *	Cyl = cylinder number (NOT CHECKED ! NOT OFFSET BY LOW_CYL !)
 * OUTPUTS
 *	Result = success/failure
 * $END
 */

{
  if ( pUnit->au_Type != AUT_DEVICE ) return( TRUE ) ;
  if ( (! DevIsReady( pUnit )) && (! PrepareDev( pUnit , NULL )) ) return( FALSE ) ;

  if (! FlushDev( pUnit , -1 )) return( FALSE ) ;
  pUnit->au_CurPos = Cyl * pUnit->au_CylSize ;
  return( TRUE ) ;
}
