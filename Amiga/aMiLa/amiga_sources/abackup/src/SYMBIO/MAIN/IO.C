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
    io.c

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 28-Aug-93
    Modified: 13-Jan-98
    _______________________________________________________________________
*/

#include "headers.h"
#include "childtask.h"

static BYTE tmp[MAXSTR+1] ;
static struct List UnitList ;   		// list of opened units

/*************************************************************************/

struct ArcUnit *FindCurUnit( struct List *pArc )

/* $DOC
 * FUNCTION
 *      Finds the first unit with the AUF_CURRENT flag set
 * INPUTS
 *      pArc = pointer to an archive, returned by OpenArc()
 * OUTPUTS
 *      Result = pointer to the current unit, NULL if none found
 * $END
 */

{
  struct ArcUnit *pFirst, *pNext ;

  for ( pFirst = FirstUnit( pArc ) ; pNext = NextUnit( pFirst ) ; pFirst = pNext )
    if ( pFirst->au_Flags & AUF_CURRENT ) return( pFirst ) ;

  return( NULL ) ;
}

/*************************************************************************/

struct ArcUnit *SetCurUnit( struct List *pArc , LONG Mode )

/* $DOC
 * FUNCTION
 *      Change the current unit.
 * INPUTS
 *      pArc = pointer to an archive, returned by OpenArc()
 *      Mode = SCU_FIRST to go back to first unit, SCU_NEXT to use next unit
 * OUTPUTS
 *      Result = pointer to current unit
 * NOTES
 *      If Mode is SCU_NEXT and there is no current unit, the first unit is
 *      selected.
 * $END
 */

{
  struct ArcUnit *pUnit, *pToClear ;

  if ( HasChildTask() ) ObtainSemaphore( &SemSCU ) ;

  /* find current unit */
  pUnit = FindCurUnit( pArc ) ;

  /* clear AUF_CURRENT flag on all units */
  while ( pToClear = FindCurUnit( pArc ) ) ClearUnitFlag( pToClear , AUF_CURRENT ) ;

  /* select new unit */
  if ( (Mode == SCU_NEXT) && (pUnit) )
  {
    pUnit = NextUnit( pUnit ) ;
    if ( ! NextUnit( pUnit ) ) pUnit = FirstUnit( pArc ) ;
  }
  else pUnit = FirstUnit( pArc ) ;

  /* set flag on this unit */
  SetUnitFlag( pUnit , AUF_CURRENT ) ;
  if ( HasChildTask() ) ReleaseSemaphore( &SemSCU );

  return( pUnit ) ;
}

/*************************************************************************/

BOOL FlushArc( struct List *pArc , LONG Flags )

/* $DOC
 * FUNCTION
 *      Flush all buffered data to the given archive
 * INPUTS
 *      pArc = pointer to an archive, returned by OpenArc()
 *      Flags = any combination of:
 *      	FAF_DEVONLY     flush AUT_DEVICE only
 * OUTPUT
 *      Result = success/failure
 * NOTES
 *      Same as FlushDev()
 * $END
 */

{
  struct ArcUnit *pUnit ;

  if ( HasBeenBreaked() ) return( FALSE ) ;

  pUnit = FindCurUnit( pArc ) ;

  if ( pUnit->au_Type != AUT_DEVICE )
  {
    if ( (pUnit->au_Type == AUT_TAPE) &&
	 (! (Flags & FAF_DEVONLY)) ) return( FlushTape( pUnit ) );
    return( TRUE ) ;
  }

  return( (BOOL)FlushDev( pUnit , ICMD_SYNC ) ) ;
}

/*************************************************************************/

BOOL FitArc( struct List *pArc , LONG Len )

/* $DOC
 * FUNCTION
 *      Tests if a file (with it's header) will fit on the current unit.
 * INPUTS
 *      pArc = pointer to an archive, returned by OpenArc()
 *      Len = file size in bytes
 * OUTPUT
 *      Result = FALSE if the file won't fit without disk changing
 * NOTES
 *      If destination is not a disk, always returns TRUE.
 * $END
 */

{
  LONG Left ;
  struct ArcUnit *pUnit ;

  /* flush data */
  if (! FlushArc( pArc , FAF_DEVONLY )) return( FALSE ) ;

  /* find current unit */
  pUnit = FindCurUnit( pArc ) ;
  if ( ! pUnit ) return( FALSE ) ;

  /* if file, tape or partition, returns TRUE */
  if ( pUnit->au_Type != AUT_DEVICE ) return( TRUE ) ;
/*  if (! DevIsTrackDisk( pUnit )) return( TRUE ) ; */

  /* check size left */
  Left  = BeginOfDev( pUnit ) + ( pUnit->au_NumCyls * pUnit->au_CylSize ) ;
  Left -= RoundToSector( pUnit->au_CurPos ) + TD_SECTOR + RoundToSector( Len ) ;
  if ( Left < 0 ) return( FALSE ) ;

  return( TRUE ) ;
}

/*************************************************************************/

BOOL ReadArc( struct List *pArc , BYTE *pData, LONG Len )

/* $DOC
 * FUNCTION
 *      Reads data from an archive (low-level).
 * INPUTS
 *      pArc = pointer to an archive, returned by OpenArc()
 *      pData = pointer to the buffer where to put data
 *      Len = number of data bytes to read
 * OUTPUTS
 *      Result = success/failure
 * $END
 */

{
  struct ArcUnit *pUnit ;

  if ( StopMe() ) return( FALSE ) ;

  pUnit = FindCurUnit( pArc ) ;
  if ( ! pUnit ) return( FALSE ) ;

  switch ( pUnit->au_Type )
  {
    case AUT_DEVICE :

      if ( ReadDev( pUnit , pData , Len ) ) return( TRUE ) ;
      if ( ! HasBeenBreaked() ) UnitError( FindCurUnit( pArc ) ) ;
      return( FALSE ) ;

    case AUT_FILE :

      if ( Read( pUnit->au_FDesc , pData , Len ) != Len )
      {
	if ( OldArchiveFmt() && (! pGRoot)) return( TRUE ) ;

	HandleError( pUnit->au_Name , HERR_IOERR ) ;
	return( FALSE ) ;
      }
      pUnit->au_CurPos += Len ;
      return( TRUE ) ;

    case AUT_TAPE :

      if ( ReadTape( pUnit , pData , Len ) ) return( TRUE ) ;
      return( FALSE ) ;
  }

  return( FALSE ) ;
}

/*************************************************************************/

BOOL WriteArc( struct List *pArc , BYTE *pData, LONG Len )

/* $DOC
 * FUNCTION
 *      Writes data to an archive (low-level).
 * INPUTS
 *      pArc = pointer to an archive, returned by OpenArc()
 *      pData = pointer to the buffer which contains data to write
 *      Len = number of data bytes to write
 * OUTPUTS
 *      Result = success/failure
 * $END
 */

{
  struct ArcUnit *pUnit ;

  if ( StopMe() ) return( FALSE ) ;

  pUnit = FindCurUnit( pArc ) ;
  if ( ! pUnit ) return( FALSE ) ;

  switch ( pUnit->au_Type )
  {
    case AUT_DEVICE :

      return( WriteDev( pUnit , pData , Len ) ) ;

    case AUT_FILE :

      if ( Write( pUnit->au_FDesc , pData , Len ) != Len )
      {
	HandleError( pUnit->au_Name , HERR_IOERR ) ;
	return( FALSE ) ;
      }

      if ( HasDiskGauge() && pUnit->au_FLock && Info( pUnit->au_FLock , &GInfo ) )
	MonitorDiskGauge( NULL , Ratio( GInfo.id_NumBlocksUsed , GInfo.id_NumBlocks ) ) ;

      pUnit->au_CurPos += Len ;
      return( TRUE ) ;

    case AUT_TAPE :

      if ( WriteTape( pUnit , pData , Len ) ) return( TRUE ) ;
      return( FALSE ) ;
  }

  return( FALSE ) ;
}

/*************************************************************************/

BOOL SeekArc( struct List *pArc , LONG Pos , LONG Mode )

/* $DOC
 * FUNCTION
 *      Change the current position within an archive.
 * INPUTS
 *      pArc = pointer to an archive, returned by OpenArc()
 *      Pos = new position (must not be negative)
 *      Mode = OFFSET_BEGINNING for a seek relative to the beginning of the file
 *             OFFSET_CURRENT for a seek relative to the current position
 * OUTPUTS
 *      Result = success/failure
 * NOTES
 *      When using floppy disks, the seek is always within the current disk,
 *      i.e. SeekArc( pArc , 0 , OFFSET_BEGINNING ) goes to the beginning of
 *      the current disk and not to the beginning of the first disk
 *      When seeking on a device, if the position doesn't correspond to the
 *      beginning of a cylinder, this cylinder will be loaded into unit buffer
 * $END
 */

{
  LONG Cyl ;
  struct ArcUnit *pUnit ;

  if (! FlushArc( pArc , NULL )) return( FALSE ) ;

  /* find current unit */
  pUnit = FindCurUnit( pArc ) ;
  if ( ! pUnit ) return( FALSE ) ;

  /* seek into unit */
  switch ( pUnit->au_Type )
  {
    case AUT_DEVICE :

      if ( (! DevIsReady( pUnit )) && (! PrepareDev( pUnit , NULL )) ) return( FALSE ) ;
      Pos = RoundToSector( Pos ) ;
      break ;

    case AUT_FILE :

      if ( Seek( pUnit->au_FDesc , Pos , Mode ) == -1 )
      {
	HandleError( pUnit->au_Name , HERR_IOERR ) ;
	return( FALSE ) ;
      }
      break ;

    case AUT_TAPE :

      if ( Mode == OFFSET_BEGINNING )
      {
	if ( Pos < pUnit->au_CurPos ) RewindTape( pUnit ) ; /* set current pos to 0 */
	if ( Pos > pUnit->au_CurPos )
	{
	  Pos -= pUnit->au_CurPos ;
	  Mode = OFFSET_CURRENT ;
	}
      }
      if ( Mode == OFFSET_CURRENT )
	while ( Pos > 0 )
	{
	  Cyl = MIN( Pos , pUnit->au_CylSize ) ;
	  if (! ReadTape( pUnit , pUnit->au_Buffer , Cyl )) return( FALSE ) ;
	  Pos -= Cyl ;
	}
      break ;
  }

  /* update position */
  if ( pUnit->au_Type != AUT_TAPE )
  {
    if ( Mode == OFFSET_BEGINNING )
      pUnit->au_CurPos = ( pUnit->au_Type == AUT_DEVICE ) ? BeginOfDev( pUnit ) : 0 ;
    pUnit->au_CurPos += Pos ;
  }

  if ( pUnit->au_Type == AUT_DEVICE )
  {
    Cyl = CurrentCyl( pUnit ) ;
    Pos = pUnit->au_CurPos % pUnit->au_CylSize ;
    if ( Cyl != pUnit->au_CurCyl )
    {
      if (! ReadCylDev( pUnit , Cyl , NULL )) return( FALSE ) ;
      pUnit->au_CurPos += Pos ;
    }
  }

  return( TRUE ) ;
}

/*************************************************************************/

BOOL CloseUnit( struct ArcUnit *pUnit )

/* $DOC
 * FUNCTION
 *      Closes an archive unit and free the corresponding structure
 * INPUTS
 *      pUnit = pointer to an unit
 * OUTPUTS
 *      Result = success/failure
 *      This function may fail if a write error occurs when flushing unit buffer.
 * NOTES
 *      The unit structure is freed by this function so don't use pUnit after,
 *      even if FALSE is returned.
 * $END
 */

{
  switch ( pUnit->au_Type )
  {
    case AUT_FILE :

      if ( pUnit->au_FLock  ) UnLock( pUnit->au_FLock ) ;
      if ( pUnit->au_FDesc  ) Close( pUnit->au_FDesc ) ;
      if ( pUnit->au_Parent ) Remove( (struct Node *)pUnit ) ;

      if ( PrgAction == PA_BACKUP )
      {
	SetProtection( pUnit->au_Name , FIBF_WRITE|FIBF_EXECUTE|FIBF_DELETE ) ;

	/* setup the file comment string */
	SPrintf( tmp , GetStr( MSG_ARCHIVE_FILE_COMMENT ) , _PROGNAME_ , _PROGVER_) ;
	SetComment( pUnit->au_Name , tmp ) ;

	/* add an icon to the file */
	AddIcon( pUnit->au_Name ) ;
      }

      FreeObject( pUnit ) ;
      return( TRUE ) ;

    case AUT_DEVICE :

      return( CloseDev( pUnit ) ) ;

    case AUT_TAPE :

      return( CloseTape( pUnit ) ) ;
  }

  return( FALSE ) ;
}

/*************************************************************************/

BOOL CloseArc( struct List *pArc )

/* $DOC
 * FUNCTION
 *      Closes an archive
 * INPUTS
 *      pArc = pointer to an archive, returned by OpenArc()
 *             (may be NULL)
 * OUTPUTS
 *      Result = success/failure
 *      This function may fail if a write error occurs when flushing an unit
 *      buffer.
 * NOTES
 *      The unit list is freed by this function so don't use pArc after,
 *      even if FALSE is returned.
 *      If pArc equals Archive, the global Archive pointer is set to NULL
 * $END
 */

{
  BOOL Ret = TRUE ;
  struct ArcUnit *pFirst , *pNext ;

  if ( ! pArc ) return( TRUE ) ;
  if (! FlushArc( pArc , NULL )) Ret = FALSE ;

  for ( pFirst = FirstUnit( pArc ) ; pNext = NextUnit( pFirst ) ; pFirst = pNext )
    if (! CloseUnit( pFirst )) Ret = FALSE ;

  if ( WriteBuf )
  {
    MyFreeMem( WriteBuf ) ;
    WriteBuf = NULL ;
  }

  if ( pArc == Archive ) Archive = NULL ;
  return( Ret ) ;
}

/*************************************************************************/

static struct ArcUnit *OpenFile( BYTE *pName , LONG Flags )

/* Low-level function for opening a file unit */

{
  BYTE *p ;
  BPTR Cle ;
  struct ArcUnit *pUnit ;

  /* allocate the unit structure */
  pUnit = AllocObject( ABO_ARCUNIT , pName ) ;
  if ( ! pUnit ) return( NULL ) ;
  pUnit->au_Type = AUT_FILE ;

  /* get lock on parent dir */
  strcpy( tmp , pName ) ;
  if ( (p = strchr( tmp , '/' )) || (p = strchr( tmp , ':')) )
  {
    p[1] = '\0' ;
    pUnit->au_FLock = Lock( tmp , ACCESS_READ ) ;
  }
  else
  {
    Cle = CurrentDir( NULL ) ;
    pUnit->au_FLock = DupLock( Cle ) ;
    CurrentDir( Cle ) ;
  }

  /* open the unit */
  pUnit->au_FDesc = Open( pName , ( Flags == OAF_READ ) ? MODE_OLDFILE : MODE_NEWFILE ) ;
  if ( ! pUnit->au_FDesc )
  {
    HandleError( pName , HERR_IOERR ) ;
    FreeObject( pUnit ) ;
    return( NULL ) ;
  }

  SetUnitFlag( pUnit , AUF_ACCESS ) ;
  return( pUnit ) ;
}

/*************************************************************************/

static void AllocateChildTaskBuffer( LONG Flags )

/* $DOC
 * FUNCTION
 *      Allocate the child task buffer before opening the first unit
 * INPUTS
 *      Flags = opening mode
 * $END
 */

{
  if ( (! UnitList.lh_Head->ln_Succ) && (Flags == OAF_WRITE) && IS_BFL_CHILDTASK )
  {
    WBufSize = KBYTES(PRF_BUFSIZE);
    WriteBuf = MyAllocMem( WBufSize , NULL ) ;
    if ( ! WriteBuf )
    {
      WBufSize = AvailMem( MEMF_PUBLIC|MEMF_LARGEST ) - MEMORYTOLEAVE ;
      if ( WBufSize < MINWBUFSIZE ) WBufSize = MINWBUFSIZE ;
      WriteBuf = MyAllocMem( WBufSize , NULL ) ;
    }

    if ( ! WriteBuf ) Warning( MSG_WARN_ALLOC_WRITE_BUFFER ) ;
    ResetChildBuffer() ;
  }
}

/*************************************************************************/

static struct ArcUnit *AddArcUnit( BYTE *pName , LONG Type , LONG Flags )

/*
 * Opens one unit and add it to the unit list
 * pName = unit name
 * Type  = AUT_FILE, AUT_TAPE, or AUT_DEVICE
 * Flags = OAF_READ or OAF_WRITE
 */

{
  BOOL Res ;
  struct Object *pObj ;
  struct ArcUnit *pUnit ;

  pUnit = NULL ;

  switch ( Type )
  {
    case AUT_TAPE :

      pUnit = OpenTape( Flags ) ;
      if ( pUnit == (struct ArcUnit *)-1 ) return( NULL ) ;
      break ;

    case AUT_FILE :

      if ( (Flags == OAF_WRITE) && (! FULLBATCHMODE) && MyExamine( pName ) )
      {
	SPrintf( tmp , GetStr( MSG_REQ_FILE_EXISTS ) , pName , GetStr( MSG_REQ_OVERWRITE ) ) ;
	if (! YesNoRequest( tmp , NULL , MSG_REQ_OK_CANCEL , FALSE )) return( NULL ) ;
      }

      SetProtection( pName , GFib.fib_Protection & ~(FIBF_WRITE|FIBF_DELETE) ) ;
      pUnit = OpenFile( pName , Flags ) ;
      break ;

    case AUT_DEVICE :

      /* check if trying to backup a device to itself */
      pObj = FindDevByName( pName ) ;
      if ( ! pObj ) break ;

      if ( ObjIsSelected( pObj ) )
      {
	HandleError( pName , ABERR_BACKUP_TO_ITSELF ) ;
	return( NULL ) ;
      }

      UpdateDevList( pObj->obj_Name ) ;
      AllocateChildTaskBuffer( Flags ) ;

      pUnit = OpenDev( pObj , Flags , (IS_BFL_CHILDTASK && WriteBuf) ? OAF_USECHILDTASK : NULL ) ;
      if ( pUnit && (! UnitList.lh_Head->ln_Succ) )
      {
	Res = TRUE ;
	if ( Flags == OAF_WRITE && (! FULLBATCHMODE) )
	{
	  if ( (! DevIsTrackDisk( pUnit )) || FloppyPresent( pUnit ) )
	  {
	    if ( (! DevIsReady( pUnit )) && (! PrepareDev( pUnit , PDF_DONTINHIBIT )) ) Res = FALSE ;

	    if ( Res )
	    {
	      SetUnitFlag( pUnit , AUF_NOTARCHIVE ) ;
	      Res = OverwriteRequest( ExamineDisk( pUnit ) ? MSG_REQ_OLD_BACKUP_DISK : MSG_REQ_MISC_DISK , pUnit , NULL , NULL ) ;
	      if ( Res ) ClearUnitFlag( pUnit , AUF_NOTARCHIVE ) ;
	    }

	    if ( Res && (! DevIsReadOnly( pUnit )) ) InhibitDev( pUnit , TRUE ) ;
	  }
	}

	if ( ! Res )
	{
	  CloseDev( pUnit ) ;
	  return( NULL ) ;
	}
      }
  }

  if ( pUnit )
  {
    AddTail( &UnitList , (struct Node *)pUnit ) ;
    pUnit->au_Parent = &UnitList ;
  }
  else HandleError( pName , ABERR_CANNOT_OPEN ) ;

  return( pUnit ) ;
}

/*************************************************************************/

void StopArc( struct List *pArc , BOOL Uninhibit )

/* $DOC
 * FUNCTION
 *      Stops all the devices used to write the given archive
 * INPUTS
 *      pArc = pointer to an archive, returned by OpenArc()
 *      Uninhibit = TRUE if device is to un-inhibit
 * $END
 */

{
  struct ArcUnit *pFirst , *pNext ;

  for ( pFirst = FirstUnit( pArc ) ; pNext = NextUnit( pFirst ) ; pFirst = pNext )
    if ( pFirst->au_Type == AUT_DEVICE ) StopDev( pFirst , Uninhibit ) ;
}

/*************************************************************************/

struct List *OpenArc( BYTE *pName , LONG Flags )

/* $DOC
 * FUNCTION
 *      Opens an archive.
 * INPUTS
 *      pName = file name, "TAPE:", device name or list of devices name
 *      	separated by commas.
 *      Flags = OAF_READ or OAF_WRITE
 * OUTPUTS
 *      Result = a pointer the archive list header, or NULL if failed
 * NOTES
 *      The first unit of the archive is made active, and the archive
 *      format is set to -1 (unknown).
 * SEE ALSO
 *      CloseArc()
 * $END
 */

{
  BYTE *p ;
  LONG Type ;
  struct ArcUnit *pUnit ;

  /* clear unit list */
  NewList( &UnitList ) ;

  if ( p = FirstComponant( pName ) )    	/* opens a list of units */
  {
    do
    {
      pUnit = AddArcUnit( p , AUT_DEVICE , Flags ) ;
      if ( pUnit && (! DevIsTrackDisk( pUnit )) )
      {
	HandleError( p , ERROR_INVALID_COMPONENT_NAME ) ;
	pUnit = NULL ;
      }

      if ( ! pUnit )
      {
	CloseArc( &UnitList ) ;
	return( NULL ) ;
      }
    }
    while ( p = NextComponant() ) ;
  }
  else  				/* opens a single unit */
  {
    if ( stricmp( pName , "TAPE:" ) )
    {
      p = strchr( pName , ':' ) ;
      Type = ( p && (! p[1])) ? AUT_DEVICE : AUT_FILE ;
    }
    else Type = AUT_TAPE ;
    if (! AddArcUnit( pName , Type , Flags )) return( NULL ) ;
  }

  /* set current unit and exit */
  ArchiveFmt = ( Flags == OAF_READ ) ? -1 : HVER_CURRENT ;
  SetCurUnit( &UnitList , SCU_FIRST ) ;
  return( &UnitList ) ;
}

