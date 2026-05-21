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
    restore.c

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 17-Sep-93
    Modified: 18-Jan-97
    _______________________________________________________________________
*/

#include "headers.h"
#include <proto/multiuser.h>

static BYTE tmp[MAXSTR+1] ;
static BOOL UseMUFS, rFirstCall ;

/*************************************************************************/

static BOOL RestoreCaract( struct Header *pHdr , BYTE *pName )

/*
 * Restore date, protection, comment and owner of the object which full
 * name is "pName", from the informations in "pHdr"
 */

{
  BPTR Cle ;
  struct DevProc *pDevProc ;
  struct DateStamp *pStamp ;

  // restore date
  if ( IS_RFL_DATE )
  {
    pStamp = UnPackDate( pHdr->h_Obj.obj_Date ) ;
    if ( ! SetFileDate( pName , pStamp ) ) return( FALSE ) ;
  }

  // restore comment
  if ( ! SetComment( pName , pHdr->h_Comment ) ) return( FALSE ) ;

  // restore owner if both source and target are on a MUFS volume
  if ( UseMUFS &&
       ObjIsMultiUser( &(pHdr->h_Obj) ) &&
       (pDevProc = GetDeviceProc( pName, NULL )) )
  {
    if ( Cle = Lock( pName , ACCESS_READ) )
    {
      DoPkt( pDevProc->dvp_Port , ACTION_SET_OWNER , NULL , Cle , MKBADDR( "\0" ) , (pHdr->h_OwnerUID << 16) | pHdr->h_OwnerGID , NULL ) ;
      UnLock( Cle ) ;
    }
    FreeDeviceProc( pDevProc ) ;
    if ( IoErr() ) return( FALSE ) ;
  }

  // restore bits
  if ( UseMUFS && muBase )
  {
    if ( ! muSetProtection( pName , pHdr->h_Obj.obj_Bits ) ) return( FALSE ) ;
  }
  else if ( ! SetProtection( pName , pHdr->h_Obj.obj_Bits ) ) return( FALSE ) ;

  return( TRUE ) ;
}

/*************************************************************************/

static LONG ReplaceObj( struct Object *pObj , BYTE *pName )

/*
 * Decide if we can replace the given object
 * The informations about the existing object are in GFib
 *
 * Returns the same values that YesNoRequest()/StringRequest() :
 *	FALSE if aborted
 *	TRUE if ok to overwrite
 *	2 if not ok to overwrite
 */

{
  LONG k, Date ;
  static BYTE aux[MINSTR+1] ;

  // always replace
  if ( IS_RFL_REPLACE ) return( TRUE ) ;

  // replace if version on disk is older than version in archive
  Date = PackDate( &(GFib.fib_Date) ) ;
  if ( IS_RFL_OLDREPLACE )
  {
    if ( Date < pObj->obj_Date ) return( TRUE ) ;
    return( 2 ) ;
  }

  if ( FULLBATCHMODE ) return( 2 ) ;

  // ask if replace
  if ( IS_RFL_ASKREPLACE )
  {
    strcpy( aux , PackedDateToStr( Date ) ) ;
    SPrintf( tmp , GetStr( MSG_REQ_REPLACE ) , pName , GFib.fib_Size , aux ,
		   pObj->obj_Size , PackedDateToStr( pObj->obj_Date ) ) ;
    return( YesNoRequest( tmp , NULL , MSG_REQ_REPLACE_SKIP , FALSE ) ) ;
  }

  // restore under another name
  if ( IS_RFL_RENAME )
  {
    strcpy( tmp , pName ) ;
    k = StringRequest( tmp , 30L, pName , GetStr( MSG_REQ_EXISTS_RENAME ) , MSG_REQ_OK_CANCEL ) ;
    if ( k < 0 ) k = FALSE ;
    if ( k != TRUE ) return( k ) ;
    if ( stricmp( FullName , tmp ) ) ReportRenamed( FullName , tmp ) ;
    strcpy( FullName , tmp ) ;
    return( TRUE ) ;
  }

  return( 2 ) ;
}

/*************************************************************************/

BOOL RestoreFile( struct Header *pHdr , BYTE *pName , BOOL Flg )

/* $DOC
 * FUNCTION
 *	Extract a file from an archive (high-level). The file is decompressed
 *	if needed, and it's attributes (date/protection/comment) are restored.
 * INPUTS
 *	pHdr = pointer to the file header
 *	pName = full pathname of destination file
 *	Flg = TRUE to restore file's caracteristics (date,bits,comment)
 * OUTPUTS
 *	Result = success/failure
 * NOTES
 *	The destination file is overwritten if it already exists.
 * SEE ALSO
 *	ReadFile(), DecompressFile()
 * $END
 */

{
  BytesDone += pHdr->h_Obj.obj_Size ;
  BytesLeft -= pHdr->h_Obj.obj_Size ;

  if ( DecompressFile( pHdr , pName , NULL ) != DFR_OK ) return( FALSE ) ;
  if ( (! Flg) || RestoreCaract( pHdr , pName ) ) return( TRUE ) ;

  HandleError( pName , HERR_IOERR ) ;
  return( FALSE ) ;
}

/*************************************************************************/

static BOOL RestoreDir( struct Header *pHdr , BYTE *pName )

/*
 * Restore the empty dir which description is in "pHdr", under the
 * name specified in "pName"
 */

{
  BPTR Cle ;

  if ( ! IS_RFL_EMPTYDIRS ) return( TRUE ) ;

  if ( Cle = CreateDir( pName ) ) UnLock( Cle ) ;
  else if ( IoErr() != ERROR_OBJECT_EXISTS ) goto _failed ;

  ReportRDir( &(pHdr->h_Obj) , pName ) ;
  if ( RestoreCaract( pHdr , pName ) ) return( TRUE ) ;

_failed:
  HandleError( pName , HERR_IOERR ) ;
  return( FALSE ) ;
}

/*************************************************************************/

static BOOL RestoreLink( struct Header *pHdr , struct Object *pObj )

/*
 * Restore the link which description is in "pHdr"
 * In fact, we just read the link destination and store it as the
 * first child of the corresponding object
 * See also Restore2()
 */

{
  struct Object *pChild ;

  if (! ReadData( Archive , tmp , MAXSTR )) return( FALSE ) ;

  pChild = AllocObject( ABO_OBJECT , tmp ) ;
  if ( ! pChild ) return( FALSE ) ;
  AddChild( pObj , pChild ) ;

  SetObjFlag( pChild , OBJF_DESTLINK ) ;
  return( TRUE ) ;
}

/*************************************************************************/

BOOL RestoreDev( struct Header *pHdr , BYTE *pName , LONG Mode )

/* $DOC
 * FUNCTION
 *	Restore or verify a device
 * INPUTS
 *	pHdr = header of the device
 *	pName = device name
 *	Mode = RDF_RESTORE to restore
 *	       RDF_VERIFY to verify
 * OUTPUTS
 *	Result = success/failure
 * $END
 */

{
  BOOL Ret ;
  BYTE *pBuffer, *p ;
  struct Object *pDev ;
  struct ArcUnit *pUnit ;
  LONG Cyl, Size, FBLen ;
  struct DeviceDef *pSDef, *pDDef ;

  if ( (Mode == RDM_VERIFY) && (! IS_VFL_COMPARE) )
  {
    pDev = &(pHdr->h_Obj) ;
    AddDeviceDef( pDev , &(pHdr->h_DeviceDef) ) ;
    pUnit = OpenDev( pDev , OAF_DUMMY , NULL ) ;
    if ( ! pUnit ) return( FALSE ) ;
  }
  else
  {
    // get a pointer to the device

    pDev  = FindDevByName( pName ) ;
    pSDef = ( pDev ) ? GetDeviceDef( pDev ) : NULL ;
    if ( ! pSDef )
    {
      HandleError( pName , ERROR_OBJECT_NOT_FOUND ) ;
      return( FALSE ) ;
    }

    // compare devices definitions

    pDDef = &(pHdr->h_DeviceDef) ;
    if (! SameDeviceDef( pSDef , pDDef ))
    {
      HandleError( pName , ERROR_OBJECT_WRONG_TYPE ) ;
      return( FALSE ) ;
    }

    // open the device

    if ( (Mode == RDM_RESTORE) && (! OverwriteRequest( MSG_REQ_MISC_DISK , NULL , pName , NULL )) )
    {
      ReportNotReplaced( pName ) ;
      return( FALSE ) ;
    }

    pUnit = OpenDev( pDev , ( Mode == RDM_RESTORE ) ? OAF_WRITE : OAF_READ , NULL ) ;
    if ( ! pUnit )
    {
      HandleError( pName , ABERR_CANNOT_OPEN ) ;
      return( FALSE ) ;
    }

    SetUnitFlag( pUnit , AUF_NOTARCHIVE ) ;
    if ( ! PrepareDev( pUnit , NULL ) )
    {
      CloseDev( pUnit ) ;
      return( FALSE ) ;
    }
  }

  // allocate a buffer for reading and try to allocate a verify buffer

  pBuffer = AllocObject( ABO_DEVBUFFER , pUnit ) ;
  if ( ! pBuffer )
  {
    CloseDev( pUnit ) ;
    return( FALSE ) ;
  }
  if ( Mode == RDM_RESTORE ) pUnit->au_VBuffer = AllocObject( ABO_DEVBUFFER , pUnit ) ;

  // loop on cylinders
  FBLen = OldArchiveFmt() ? TD_SECTOR : MAXDATA ;
  for ( Cyl = 0 ; Cyl < pUnit->au_NumCyls ; Cyl++ )
  {

    if ( (Mode == RDM_RESTORE) && (! SeekDev( pUnit , Cyl+1 )) ) break ;

    // update display
    if ( Cyl )
    {
      if ( Mode == RDM_RESTORE ) SPrintf( tmp , GetStr( MSG_MONITOR_RESTORED ) , pUnit->au_CylSize ) ;
			    else strcpy( tmp , GetStr( MSG_MONITOR_VERIFIED ) ) ;
      MonitorPrint( MP_POS2 , tmp , MPF_LINEFEED ) ;
    }
    SPrintf( tmp , GetStr( MSG_MONITOR_CYLINDER ) , pDev->obj_Name , Cyl ) ;
    MonitorPrint( MP_POS1 , tmp , NULL ) ;
    MonitorPrint( MP_POS2 , GetStr( MSG_MONITOR_READING ) , NULL ) ;

    // read cylinder data from archive
    if (! ReadData( Archive , pBuffer , FBLen )) break ;
    memcpy( &Size , pBuffer , sizeof(LONG) ) ;
    if ( (Size < 1) || (Size > pUnit->au_CylSize) )
    {
      SPrintf( tmp , GetStr( MSG_ERROR_READING_CYLINDER ) , Size , pUnit->au_Name , Cyl , pUnit->au_CylSize ) ;
      ABackupAlert( NULL , tmp ) ;
      break ;
    }

    Size -= FBLen - sizeof(LONG) ;
    if ( (Size > 0) && (! ReadData( Archive , &pBuffer[FBLen] , Size )) ) break ;

    // decompress cylinder
    memcpy( &Size , pBuffer , sizeof(LONG) ) ;
    if ( Size == pUnit->au_CylSize )
      memcpy( pUnit->au_Buffer , &pBuffer[sizeof(LONG)] , (size_t)pUnit->au_CylSize ) ;
    else
      if (! DecompressCyl( pUnit , pBuffer , pHdr->h_CType )) break ;

    // restore or verify
    if ( Mode == RDM_RESTORE )
    {
      MonitorPrint( MP_POS2 , GetStr( MSG_MONITOR_WRITING ) , NULL ) ;
      SetUnitFlag( pUnit , AUF_BUFFLUSH ) ;
    }

    if ( (Mode == RDM_VERIFY) && IS_VFL_COMPARE )
    {
      p = pBuffer ;
      pBuffer = pUnit->au_Buffer ;
      pUnit->au_Buffer = p ;
      if (! ReadCylDev( pUnit , Cyl , NULL )) break ;
      MonitorPrint( MP_POS2 , GetStr( MSG_MONITOR_COMPARING ) , NULL ) ;
      if ( memcmp( pUnit->au_Buffer , pBuffer , (size_t)pUnit->au_CylSize ) &&
	   (! FULLBATCHMODE) &&
	   (! YesNoRequest( GetStr( MSG_REQ_FILES_NOTEQUAL ) , tmp , MSG_REQ_CONTINUE_ABORT , FALSE )) ) break ;
    }

    // update report and display
    ReportRCyl( tmp , pUnit->au_CylSize ) ;
    BytesDone += pUnit->au_CylSize ;
    BytesLeft -= pUnit->au_CylSize ;
    if ( HasInterface() ) MonitorStatus( Archive ) ;
  }

  // update status variables
  Size = pUnit->au_NumCyls - Cyl ;
  if ( Size > 0 )
  {
    Size *= pUnit->au_CylSize ;
    BytesDone += Size ;
    BytesLeft -= Size ;
  }

  // close unit and exit
  FreeObject( pBuffer ) ;
  Ret = (BOOL)( Cyl == pUnit->au_NumCyls ) ;
  if ( Ret )
  {
    if ( Mode == RDM_RESTORE ) SPrintf( tmp , GetStr( MSG_MONITOR_RESTORED ) , pUnit->au_CylSize ) ;
			  else strcpy( tmp , GetStr( MSG_MONITOR_VERIFIED ) ) ;
    MonitorPrint( MP_POS2 , tmp , MPF_LINEFEED ) ;
    MonitorPrint( MP_POS1 , pDev->obj_Name , NULL ) ;
  }
  if (! CloseDev( pUnit )) Ret = FALSE ;
  return( Ret ) ;
}

/*************************************************************************/

static BOOL RestoreObj( struct Object *pObj )

/* Restore the given object */

{
  LONG k ;
  BOOL Ret ;

  // build object name

  BuildDestName( FullName , pObj ) ;
  MonitorPrint( MP_POS1 , FullName , NULL ) ;

  // check object path

  if ( ! ObjIsDevice( pObj ) )
  {
    if (! CheckPath( pObj , FullName )) goto _failed ;

    if ( MyExamine( FullName ) )
    {
      k = ReplaceObj( pObj , FullName ) ;
      if ( k != 1 )
      {
	MonitorPrint( MP_POS2 , GetStr( MSG_MONITOR_SKIPPED ) , MPF_LINEFEED ) ;
	if ( k != FALSE ) ReportNotReplaced( FullName ) ;
	return( (BOOL)k ) ;
      }
      SetProtection( FullName , GFib.fib_Protection & ~(FIBF_DELETE|FIBF_WRITE) ) ;
    }
  }

  // read object header

  if (! ReadObjectHeader( pObj , FullName )) goto _failed ;

  // restore object

  MonitorPrint( MP_POS2 , GetStr( MSG_MONITOR_READING ) , NULL ) ;
  if ( ObjIsFile( pObj ) )
  {
    if ( Ret = RestoreFile( pGHdr , FullName , TRUE ) ) ReportRFile( &(pGHdr->h_Obj) , FullName ) ;
  }
  else if ( ObjIsDir( pObj ) )    Ret = RestoreDir( pGHdr  , FullName ) ;
  else if ( ObjIsLink( pObj ) )   Ret = RestoreLink( pGHdr , pObj ) ;
  else if ( ObjIsDevice( pObj ) ) Ret = RestoreDev( pGHdr , pObj->obj_Name , RDM_RESTORE ) ;
  else				  Ret = FALSE ;

  // update status
  FilesDone++ ;
  FilesLeft-- ;
  if ( HasInterface() ) MonitorStatus( Archive ) ;

  if ( HasBeenBreaked() ) return( FALSE ) ;

  // return success
  if ( Ret )
  {
    SPrintf( tmp , GetStr( MSG_MONITOR_RESTORED ) , pObj->obj_Size ) ;
    MonitorPrint( MP_POS2 , tmp , MPF_LINEFEED ) ;
    return( TRUE ) ;
  }

  // failed: decide if we must delete the target
  Ret = FALSE ;
  ReportError( FullName , GetStr( MSG_REPORT_COULD_NOT_RESTORE ) ) ;

  if ( ObjIsFile( pObj ) )
  {
    if ( IS_RFL_ASKDELBAD )
      Ret = FULLBATCHMODE ? FALSE : YesNoRequest( GetStr ( MSG_REQ_DELETE_BAD_FILE ) , FullName , MSG_REQ_YES_NO , FALSE ) ;
    if ( IS_RFL_DELBAD ) Ret = TRUE ;
  }

  if ( Ret )
  {
    ReportBFRemoved( FullName ) ;
    DeleteFile( FullName ) ;
  }

_failed:
  if ( HasBeenBreaked() ) return( FALSE ) ;
  MonitorPrint( MP_POS2 , GetStr( MSG_MONITOR_ERROR ) , MPF_LINEFEED ) ;
  if ( FULLBATCHMODE ) return( TRUE ) ;
  return( YesNoRequest( GetStr( MSG_REQ_RESTORE_FAILED ) , FullName , MSG_REQ_CONTINUE_ABORT , FALSE ) ) ;
}

/*************************************************************************/

static BOOL Restore2( struct Object *pObj )

/*
 * Second pass for restoration :
 * - restore directory dates
 * - restore links
 * NOTE: always returns TRUE
 */

{
  BYTE *p ;
  BOOL Res ;
  BPTR Cle ;
  size_t Len ;
  struct DateStamp *pStamp ;
  struct Object *pDest, *pRoot ;

  if ( rFirstCall )
  {
    MonitorPrint( MP_POS1 , GetStr( MSG_RESTORING_LINKS ) , MPF_LINEFEED ) ;
    rFirstCall = FALSE ;
  }

  BuildDestName( FullName , pObj ) ;

  // restore directory dates and comments
  if ( ObjIsDir( pObj ) && pObj->obj_SelChildren )
  {
    if ( IS_RFL_DATE )
    {
      pStamp = UnPackDate( pObj->obj_Date ) ;
      SetFileDate( FullName , pStamp ) ;
    }
    if ( ObjHasComment( pObj ) )
    {
      p = (BYTE *)pObj ;
      Len = sizeof(struct Object) + strlen(pObj->obj_Name) ;
      if ( Len & 1 ) Len += 1 ;
      SetComment( FullName , &p[Len] ) ;
    }
    return( TRUE ) ;
  }

  // check object is a selected link, and we have destination
  if ( ! ObjIsSelected( pObj ) ) return( TRUE ) ;
  if ( ! ObjIsLink( pObj ) ) return( TRUE ) ;
  pDest = FirstChild( pObj ) ;
  if ( ! NextChild( pDest ) ) return( TRUE ) ;

  // build full name of "destination"
  for ( pRoot = pObj ; pRoot->obj_Parent ; pRoot = pRoot->obj_Parent ) ;
  Len = strlen( pRoot->obj_Name )  ;
  if (! strnicmp( pRoot->obj_Name , pDest->obj_Name , Len ))
  {
    p = &(pDest->obj_Name[Len]) ;
    if ( (*p == ':') || (*p == '/') )
    {
      p++ ;
      Len++ ;
    }
    else p = NULL ;
  }
  else p = NULL ;

  if ( p )
  {
    if ( PRF_RESTO[0] ) strcpy( tmp , PRF_RESTO ) ;
			    else tmp[Len] = '\0' ;
    if (! IS_RFL_DIRTREE ) p = (BYTE *)FilePart( pDest->obj_Name ) ;
    AddPart( tmp , p , MAXSTR ) ;
  }
  else strcpy( tmp , pDest->obj_Name ) ;

  // make sure that destination exists
  if ( ! MyExamine( tmp ) )
  {
    HandleError( tmp , HERR_IOERR ) ;
    return( TRUE ) ;
  }

  // restore the link
  if ( ObjIsHLink( pObj ) )
  {
    Cle = Lock( tmp , ACCESS_READ ) ;
    if ( ! Cle ) return( TRUE ) ;
    Res = MakeLink( FullName , Cle , FALSE ) ;
    UnLock( Cle ) ;
  }
  else Res = MakeLink( FullName , (LONG)tmp , TRUE ) ;

  if ( Res ) ReportRLink( pObj , FullName ) ;
	else HandleError( FullName , HERR_IOERR ) ;
  return( TRUE ) ;
}

/*************************************************************************/

static BOOL CleanUp( struct Object *pObj )

/*
 * Clear the OBJF_PATHOK flag
 * Free the dummy child object allocated to remember links destinations
 */

{
  struct Object *pChild ;

  if ( ObjIsLink( pObj ) )
  {
    pChild = FirstChild( pObj ) ;
    if ( NextChild( pChild ) ) FreeObject( pChild ) ;
    NoChildren( pObj ) ;
  }

  ClearObjFlag( pObj , OBJF_PATHOK ) ;
  return( TRUE ) ;
}

/*************************************************************************/

BOOL DoRestore( struct Object *pRoot , UBYTE *pDest )

/* $DOC
 * FUNCTION
 *	Front-end for all restore operations.
 * INPUTS
 *	pRoot = root of a directory tree, or partition list. Objects to
 *		restore must have to OBJF_SELECTED flag set
 *	pDest = directory to restore to
 * OUTPUTS
 *	Result = success/failure
 * NOTES
 *	The archive must be opened, and the result of OpenArc() stored in
 *	the global variable "Archive"
 * $END
 */

{
  BOOL Ret ;

  strcpy( DestDir , pDest ) ;
  UseMUFS = IsOnMUFSVolume( PRF_RESTO ) ;
  OpenReport( MSG_REPORT_RESTORE , PRF_RESFLAGS / RFL_REPORT ) ;

  if ( Ret = WalkDirTree( pRoot , RestoreObj , (WDTF_RECURSIVE|WDTF_DIRAFTER|WDTF_SELECTED) ) )
  {
    rFirstCall = TRUE ;
    Ret = WalkDirTree( pRoot , Restore2 , (WDTF_RECURSIVE|WDTF_DIRAFTER) ) ;
  }

  WalkDirTree( pRoot , CleanUp , (WDTF_RECURSIVE|WDTF_DIRAFTER) ) ;
  CloseReport() ;

  return( Ret ) ;
}

