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
    rdb.c

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 14-Jan-98
    Modified: 16-Jan-98
    _______________________________________________________________________
*/

#include "headers.h"

#include <devices/trackdisk.h>
#include <devices/hardblocks.h>
#include <dos/filehandler.h>

static UBYTE TmpBuf[TD_SECTOR] ;

/***************************************************************************/

static BOOL RDBSumOK( struct RigidDiskBlock *prdb )
{
  int   i ;
  LONG  chk = 0 ;
  BOOL  ret = FALSE ;
  ULONG *p  = (ULONG *)prdb ;

  if ( prdb->rdb_SummedLongs < 1024 )
  {
    for ( i = 0 ; i < prdb->rdb_SummedLongs ; i++ ) chk += *p++ ;
    if ( ! chk ) ret = TRUE ;
  }

  return( ret ) ;
}

/***************************************************************************/

static void *GetRDBBlock( struct ArcUnit *pUnit , LONG blk , LONG id )
{
  struct RigidDiskBlock *prdb = NULL ;

  if ( ReadBlockDev( pUnit , blk , TmpBuf ) )
  {
    prdb = (struct RigidDiskBlock *)TmpBuf ;
    if ( (prdb->rdb_ID != id) || (! RDBSumOK( prdb )) ) prdb = NULL ;
  }

  return( (void *)prdb ) ;
}

/***************************************************************************/

BOOL UpdateDevFromRDB( struct ArcUnit *pUnit )
{
  LONG   blk ;
  struct DosEnvec *penv ;
  struct DeviceDef *pdef ;
  struct PartitionBlock *ppb ;
  static UBYTE name[MINSTR+1] ;
  BOOL   found = FALSE, err = FALSE ;
  struct RigidDiskBlock *prdb = NULL ;

  // search for the RIGID DISK BLOCK

  for ( blk = 0 ; (blk < RDB_LOCATION_LIMIT) && (! prdb) ; blk++ )
    prdb = GetRDBBlock( pUnit , blk , IDNAME_RIGIDDISK ) ;

   // search the unit partition in the partition list

  if ( prdb )
  {
    blk = prdb->rdb_PartitionList ;
    while ( (! found) && (! err) && (blk != -1) )
    {
      if ( ppb = GetRDBBlock( pUnit , blk , IDNAME_PARTITION ) )
      {
	B2CStr( ppb->pb_DriveName , name ) ;
	strcat( name , ":" ) ;
	if (! stricmp( name , pUnit->au_Name ))
	{
	  // update the device definition from the partition definition

	  pdef = pUnit->au_DeviceDef ;
	  penv = (struct DosEnvec *)ppb->pb_Environment ;

	  pdef->dd_Flags = ppb->pb_Flags ;
	  memcpy( &(pdef->dd_Env) , penv , sizeof(struct DosEnvec) ) ;
	  if ( penv->de_TableSize < DE_BUFMEMTYPE ) pdef->dd_Env.de_BufMemType = BMT_CHIP ;
	  pUnit->au_NumCyls = penv->de_HighCyl - penv->de_LowCyl + 1 ;
	  found = TRUE ;
	}
	else blk = ppb->pb_Next ;
      }
      else err = TRUE ;
    }
  }

  return( (BOOL)(found && (! err)) ) ;
}
