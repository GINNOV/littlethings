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
    verify.c

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 18-Oct-93
    Modified: 01-Jul-96
    _______________________________________________________________________
*/

#include "headers.h"

static BYTE tmp[MAXSTR+1] ;

/*************************************************************************/

static BOOL VerifyFile( struct Header *pHdr , BYTE *pName )

/*
 * Extract a file from an archive (high-level) and verify it.
 * pHdr  = pointer to the file header
 * pName = full pathname of destination file
 *
 * The general idea of this function is that we always try at least to extract
 * the file from the archive, which is the lowest level of verification. (That's
 * why we report "changed" and "not found" errors AFTER a successfull extraction).
 * Then, if we can, we compare the extracted data with the data in the archive.
 * The comparison itself is performed by DecompressFile().
 */

#define VFF_OK		0
#define VFF_CHANGED	1
#define VFF_NOTFOUND	2

{
  BYTE *pCmp ;
  LONG Ret, MsgID, Flg ;

  Flg	     = VFF_OK ;
  BytesDone += pHdr->h_Obj.obj_Size ;
  BytesLeft -= pHdr->h_Obj.obj_Size ;

  /* prepare the (eventual) comparison */

  pCmp = NULL ;
  if ( IS_VFL_COMPARE )
  {
    if ( MyExamine( pName ) )
    {
      if ( (pHdr->h_Obj.obj_Size != GFib.fib_Size) ||
	   ((! IS_VFL_IGNOREDATE) && (pHdr->h_Obj.obj_Date != PackDate( &(GFib.fib_Date) ))) )
	Flg = VFF_CHANGED ;
      else
	pCmp = pName ;
    }
    else Flg = VFF_NOTFOUND ;
  }

  /* extract the file, with eventual comparison */

  strcpy( tmp , PRF_TEMPDIR ) ;
  AddPart( tmp , FilePart( pName ) , MAXSTR ) ;
  Ret = DecompressFile( pHdr , tmp , pCmp ) ;
  DeleteFile( tmp ) ;
  if ( HasBeenBreaked() ) return( FALSE ) ;

  /* examine return value */

  switch ( Ret )
  {
    case DFR_OK :

      if ( Flg == VFF_CHANGED )
      {
	ReportVChanged( pName ) ;
	Ret = FULLBATCHMODE ? TRUE : YesNoRequest( GetStr( MSG_REQ_FILE_MODIFIED ) , pName , MSG_REQ_CONTINUE_ABORT , FALSE ) ;
      }
      else if ( Flg == VFF_NOTFOUND )
      {
	ReportNotFound( pName ) ;
	SPrintf( tmp , "%s\n%s" , pName , GetStr( MSG_ABERR_CANNOT_OPEN ) ) ;
	Ret = FULLBATCHMODE ? TRUE : YesNoRequest( tmp , NULL , MSG_REQ_CONTINUE_ABORT , FALSE ) ;
      }
      else
      {
	ReportVFile( &(pHdr->h_Obj) , pName ) ;
	Ret = TRUE ;
      }
      MsgID = MSG_MONITOR_VERIFIED ;
      break ;

    case DFR_READERR :

      ReportError( pName , GetStr( MSG_REPORT_COULD_NOT_VERIFY ) ) ;
      if ( FULLBATCHMODE ) return( TRUE ) ;
      Ret   = YesNoRequest( GetStr( MSG_REQ_RESTORE_FAILED ) , pName , MSG_REQ_CONTINUE_ABORT , FALSE ) ;
      MsgID = MSG_MONITOR_ERROR ;
      break ;

    case DFR_CMPERR :

      ReportVDifferent( pName ) ;
      if ( FULLBATCHMODE ) return( TRUE ) ;
      Ret   = YesNoRequest( GetStr( MSG_REQ_FILES_NOTEQUAL ) , pName , MSG_REQ_CONTINUE_ABORT , FALSE ) ;
      MsgID = MSG_MONITOR_ERROR ;
      break ;
  }

  /* exit */

  MonitorPrint( MP_POS2 , GetStr( MsgID ) , MPF_LINEFEED ) ;
  return( (BOOL)Ret ) ;
}

/*************************************************************************/

static BOOL VerifyObj( struct Object *pObj )

/* Verify the given object */

{
  BOOL Ret ;

  if ( ObjIsDevice( pObj ) || ObjIsFile( pObj ) )
  {
    // build object name

    GetFullName( FullName , pObj ) ;

    // read object header

    if (! ReadObjectHeader( pObj , FullName ))
    {
      if ( HasBeenBreaked() ) return( FALSE ) ;
      ReportError( FullName , GetStr( MSG_REPORT_COULD_NOT_VERIFY ) ) ;
      if ( FULLBATCHMODE ) return( TRUE ) ;
      MonitorPrint( MP_POS2 , GetStr( MSG_MONITOR_ERROR ) , MPF_LINEFEED ) ;
      return( YesNoRequest( GetStr( MSG_REQ_RESTORE_FAILED ) , FullName , MSG_REQ_CONTINUE_ABORT , FALSE ) ) ;
    }

    // verify object

    MonitorPrint( MP_POS2 , GetStr( MSG_MONITOR_READING ) , NULL ) ;
    if ( ObjIsDevice( pObj ) )
    {
      Ret = RestoreDev( pGHdr , pObj->obj_Name , RDM_VERIFY ) ;
      if ( Ret ) MonitorPrint( MP_POS2 , GetStr( MSG_MONITOR_VERIFIED ) , MPF_LINEFEED ) ;
    }
    else if ( ObjIsFile( pObj ) ) Ret = VerifyFile( pGHdr , FullName ) ;
  }
  else Ret = TRUE ;

  // update status

  FilesDone++ ;
  FilesLeft-- ;
  if ( HasInterface() ) MonitorStatus( Archive ) ;

  // exit

  return( Ret ) ;
}

/*************************************************************************/

BOOL DoVerify( struct Object *pRoot )

/* $DOC
 * FUNCTION
 *	Front-end for all verify operations.
 * INPUTS
 *	pRoot = root of a directory tree, or partition list. Objects to
 *		verify must have to OBJF_SELECTED flag set
 * OUTPUT
 *	Result = success/failure
 * NOTES
 *	The archive must be opened, and the result of OpenArc() stored in
 *	the global variable "Archive"
 * $END
 */

{
  BOOL Ret ;

  OpenReport( MSG_REPORT_VERIFY , PRF_VERFLAGS / VFL_REPORT ) ;
  Ret = WalkDirTree( pRoot , VerifyObj , (WDTF_RECURSIVE|WDTF_DIRAFTER|WDTF_SELECTED) ) ;
  CloseReport() ;
  return( Ret ) ;
}

