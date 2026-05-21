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
    save.c

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 29-Aug-93
    Modified: 17-Aug-99
    _______________________________________________________________________
*/

#include "headers.h"
#define LATTICE
#include <xpk/xpk.h>
#include <proto/xpkmaster.h>

#define EST_WRITESPEED		KBYTES(15)      // write speed in Ko/s
#define EST_FLOPPYSIZE		KBYTES(880)     // capacify of a DD floppy
#define EST_INFOPERFILE 	600		// extra size per file in bytes

/*************************************************************************/

static BOOL sFirstCall ;
static BYTE tmp[MAXSTR+1], *RFmt = "Ok (%2ld %%)" ;

static struct XpkMode XpkInfo ;

static struct TagItem XQT[] =
{
  XPK_ModeQuery,(ULONG)&XpkInfo,
  XPK_PackMethod,NULL,
  XPK_PackMode,NULL,
  TAG_END, NULL
} ;

/* Percentage table for Estimate() */
static WORD EstTable[16] =
{
/* off, slow, off, fast compression */
    81,   75,  81,   72, /* small buffer, verify off */
   144,   92, 144,  115, /* small buffer, verify on  */
    81,   72,  81,   65, /* large buffer, verify off */
   143,   79, 143,  112  /* large buffer, verify on  */
} ;

/*************************************************************************/

BOOL SaveFile( BYTE *pName , struct Object *pObj , UBYTE CompType )

/* $DOC
 * FUNCTION
 *	Add a file to an archive (high-level)
 * INPUTS
 *	pName = full pathname of file
 *	pObj = pointer to the (file) object
 *	CompType = compression algorithm to use
 * OUTPUTS
 *	Result = success/failure
 * NOTES
 *	If the OBJF_SAVED flag is set in the pObj struct, nothing is
 *	written to the archive (this feature is used by the WriteCatalog()
 *	function to prevent catalog to be written into the archive in
 *	"rebuild catalogue" mode)
 * SEE ALSO
 *	WriteFile(), CompressFile()
 * $END
 */

{
  BYTE *p ;
  LONG k, nb, csize ;

  do
  {
    /* verify object size */

    if ( ! MyExamine( pName ) )
    {
      HandleError( pName , HERR_IOERR ) ;
      return( FALSE ) ;
    }

    FilesSelected += GFib.fib_Size - pObj->obj_Size ;
    pObj->obj_Date = PackDate( &(GFib.fib_Date) ) ;
    pObj->obj_Bits = GFib.fib_Protection ;
    pObj->obj_Size = GFib.fib_Size ;

    /* verify protection bits */

    if ( ObjIsReadProtected( pObj ) )
    {
      if ( FULLBATCHMODE ) break ;
      if (! YesNoRequest( GetStr( MSG_WARN_READ_PROTECTED ) , pName , MSG_REQ_RETRY_CANCEL , FALSE ))
	return( FALSE ) ;
    }
  }
  while ( ObjIsReadProtected( pObj ) ) ;

  /* initialize object header */

  BuildHeader( pGHdr , pObj ) ;

  if ( ObjIsMultiUser( pObj ) )
  {
    pGHdr->h_OwnerUID = GFib.fib_OwnerUID ;
    pGHdr->h_OwnerGID = GFib.fib_OwnerGID ;
  }

  /* test if object must be splited */

  k = AutoSplitLimit() ;
  if ( k < KBYTES(8) )
    CompType = HCT_NONE ;
  else if ( (pObj->obj_Size > k) &&
       (! ObjIsCatalog( pObj )) &&
       ((CompType == HCT_INTERNAL) || (CompType == HCT_XPKLIB)) )
  {
    SetObjFlag( pObj , OBJF_SPLITED ) ;
    SetObjFlag( &(pGHdr->h_Obj) , OBJF_SPLITED ) ;
    pGHdr->h_BSize = k ;
  }
  else pGHdr->h_BSize = pObj->obj_Size ;

  if ( pGHdr->h_BSize )
  {
    nb = pObj->obj_Size / pGHdr->h_BSize ;
    if ( pObj->obj_Size % pGHdr->h_BSize ) nb++ ;
  }
  else nb = 1 ;

  /* store catalog information */

  if ( ObjIsCatalog( pObj ) )
  {
    memcpy( &(pGHdr->h_DeviceDef) , &GArcInfo , sizeof(struct ArcInfo) ) ;
    strncpy( pGHdr->h_PathTable , RootName , PATHTABLE ) ;
    pGHdr->h_PathTable[PATHTABLE-1] = '\0' ;
    if ( IS_BFL_ADDCOMMENT && (PrgAction != PA_REBUILD) )
    {
      strcpy( pGHdr->h_Comment , PRF_DEFCOMMENT ) ;
      if ( ! FULLBATCHMODE )
      {
	WakeUpUser();
	if ( StringRequest( pGHdr->h_Comment, MAXNOTE, GetStr( MSG_REQ_COMMENT ) , "" , MSG_REQ_OK_CANCEL ) != TRUE )
	  strcpy( pGHdr->h_Comment , GetStr( MSG_NO_COMMENT ) ) ;
      }
    }
    else strcpy( pGHdr->h_Comment, GetStr( MSG_NO_COMMENT ) ) ;
  }
  else strcpy( pGHdr->h_Comment , GFib.fib_Comment ) ;

  /* add object to archive */

  csize = 0 ;

  for ( k = 0 ; k < nb ; k++ )
  {
    /* compress file */

    if ( CompType != HCT_NONE ) MonitorPrint( MP_POS2 , GetStr( MSG_MONITOR_CRUNCHING ) , NULL ) ;
    p = CompressFile( pName , pGHdr , k , CompType ) ;
    if ( ! p ) return( FALSE ) ;
    csize += pGHdr->h_CSize ;

    if ( HasBeenBreaked() ) return( FALSE ) ;

    if ( ! ObjIsSaved( pObj ) )
    {
      /* check if catalog will fit on disk */

      if ( ObjIsCatalog( pObj ) &&
	   (! FitArc( Archive , pGHdr->h_CSize )) &&
	   (! NextFloppy( Archive )) ) return( FALSE ) ;

      /* write object header */

_restart:
      if ( pGHdr->h_Type != HT_SPLIT ) TryToAddToCatalog( Archive , pObj ) ;
      if (! WriteHeader( Archive , pGHdr )) return( FALSE ) ;

      /* write the file */

      if (! WriteFile( Archive , p )) return( FALSE ) ;

      /* make sure that catalog is on one disk only */

      if ( ObjIsCatalog( pObj ) )
      {
	struct ArcUnit *pUnit ;

	if (! FlushArc( Archive , FAF_DEVONLY )) return( FALSE ) ;
	pUnit = FindCurUnit( Archive ) ;
	if ( pUnit->au_CurDisk != pObj->obj_Disk )
	{
	  if (! SeekArc( Archive , TD_SECTOR , OFFSET_BEGINNING )) return( FALSE ) ;
	  goto _restart ;
	}
      }

      if ( *ToDelete ) DeleteFile( ToDelete ) ;
      pGHdr->h_Type = HT_SPLIT ;
    }
  }

  /* update report and display */

  k = Ratio( csize , pObj->obj_Size ) ;
  if ( k ) k = 100 - k ;
  if ( ! ObjIsCatalog( pObj ) )
  {
    ReportBFile( pObj , FullName , k ) ;
    BytesWritten += csize ;
  }
  else ReportBCatal( pObj , k ) ;

  if ( k ) SPrintf( FullName , RFmt , k ) ;
  else strcpy( FullName , GetStr( MSG_MONITOR_BACKEDUP ) ) ;

  MonitorPrint( MP_POS2 , FullName , MPF_LINEFEED ) ;
  return( TRUE ) ;
}

/*************************************************************************/

static BOOL SaveDir( BYTE *pName , struct Object *pObj )

/* Save the dir which full name is "pName" and description is "pObj" */

{
  /* examine object to get comment */
  if ( ! MyExamine( pName ) )
  {
    HandleError( pName , HERR_IOERR ) ;
    return( FALSE ) ;
  }

  /* initialize and write object header */
  BuildHeader( pGHdr , pObj ) ;
  strcpy( pGHdr->h_Comment , GFib.fib_Comment ) ;
  TryToAddToCatalog( Archive , pObj ) ;

  if (! WriteHeader( Archive , pGHdr )) return( FALSE ) ;

  /* update report and display */
  MonitorPrint( MP_POS2 , GetStr( MSG_MONITOR_BACKEDUP ) , MPF_LINEFEED ) ;
  ReportBDir( pObj , pName ) ;
  return( TRUE ) ;
}

/*************************************************************************/

static BOOL SaveLink( BYTE *pName , struct Object *pObj )

/* Save the link which full name is "pName" and description is "pObj" */

{
  // write object header
  BuildHeader( pGHdr , pObj ) ;
  TryToAddToCatalog( Archive , pObj ) ;
  if (! WriteHeader( Archive , pGHdr )) return( FALSE ) ;

  // finds where the link points to
  if (! SolveLink( pName , GIOBuf )) return( FALSE ) ;

  // write "data" (i.e. the link destination)
  if (! WriteData( Archive , GIOBuf , MAXDATA )) return( FALSE ) ;

  MonitorPrint( MP_POS2 , "Ok" , MPF_LINEFEED ) ;
  ReportBLink( pObj , pName ) ;
  return( TRUE ) ;
}

/*************************************************************************/

static BOOL SaveDevice( struct Object *pObj , UBYTE CompType )

/* Save the device which description is pointed to by "pObj" */

{
  BOOL Ret ;
  BYTE *pBuffer ;
  LONG Cyl, Size ;
  struct ArcUnit *pUnit ;

  /* open the device */

  pUnit = OpenDev( pObj , OAF_READ , NULL ) ;
  if ( ! pUnit )
  {
    HandleError( pObj->obj_Name , ABERR_CANNOT_OPEN ) ;
    return( FALSE ) ;
  }

  SetUnitFlag( pUnit , AUF_NOTARCHIVE ) ;
  if ( ! PrepareDev( pUnit , NULL ) )
  {
    CloseDev( pUnit ) ;
    return( FALSE ) ;
  }

  /* allocate a buffer for compression */

  if ( CompType != HCT_NONE )
  {
    pBuffer = AllocObject( ABO_DEVBUFFER , pUnit ) ;
    if ( ! pBuffer ) CompType = HCT_NONE ;
  }
  else pBuffer = NULL ;

  /* initialize and write object header */

  BuildHeader( pGHdr , pObj ) ;
  UpdateHeader( pGHdr , CompType , -1 ) ;
  pGHdr->h_Obj.obj_UserData++ ;

  TryToAddToCatalog( Archive , pObj ) ;
  if (! WriteHeader( Archive , pGHdr ))
  {
    CloseDev( pUnit ) ;
    return( FALSE ) ;
  }

  MonitorPrint( MP_POS2 , "" , MPF_LINEFEED ) ;

  /* write loop on cylinders */

  for ( Cyl = 0 ; Cyl < pUnit->au_NumCyls ; Cyl++ )
  {
    SPrintf( FullName , GetStr( MSG_MONITOR_CYLINDER ) , pObj->obj_Name , Cyl ) ;
    MonitorPrint( MP_POS1 , FullName , NULL ) ;
    MonitorPrint( MP_POS2 , GetStr( MSG_MONITOR_CRUNCHING ) , NULL ) ;

    // compress cylinder
    if (! ReadCylDev( pUnit , Cyl , RCDF_PUTCYLSIZE )) break ;
    Size = ( CompType == HCT_NONE ) ? -1 : CompressCyl( pUnit , pBuffer , CompType ) ;

    // write cylinder
    MonitorPrint( MP_POS2 , GetStr( MSG_MONITOR_WRITING ) , NULL ) ;
    if ( Size < 0 )
    {
      Size = pUnit->au_CylSize ;
      Ret  = WriteData( Archive , pUnit->au_Buffer , Size + sizeof(LONG) ) ;
    }
    else Ret = WriteData( Archive , pBuffer , Size + sizeof(LONG) ) ;

    if ( ! Ret ) break ;

    // update report and display
    BytesDone += pUnit->au_CylSize ;
    BytesLeft -= pUnit->au_CylSize ;
    BytesWritten += Size ;
    if ( HasInterface() ) MonitorStatus( Archive ) ;

    Size = Ratio( Size , pUnit->au_CylSize ) ;
    if ( Size ) Size = 100 - Size ;

    ReportBCyl( FullName , pUnit->au_CylSize , Size ) ;

    if ( Size ) SPrintf( FullName , RFmt , Size ) ;
    else strcpy( FullName , GetStr( MSG_MONITOR_BACKEDUP ) ) ;

    MonitorPrint( MP_POS2 , FullName , MPF_LINEFEED ) ;
  }

  /* update stat variables */

  Size = pUnit->au_NumCyls - Cyl ;
  if ( Size > 0 )
  {
    Size *= pUnit->au_CylSize ;
    BytesDone += Size ;
    BytesLeft -= Size ;
  }

  /* close unit and exit */

  if ( pBuffer ) FreeObject( pBuffer ) ;
  if ( Cyl < pUnit->au_NumCyls )
  {
    Ret = FALSE ;
    strcpy( FullName , pObj->obj_Name ) ;
  }
  else Ret = TRUE ;
  if (! CloseDev( pUnit )) Ret = FALSE ;
  return( Ret ) ;
}

/*************************************************************************/

static BOOL SaveObj( struct Object *pObj )

/* Backup the given object */

{
  BOOL Ret ;
  UBYTE CType ;

  CType = (UBYTE)( IS_BFL_COMPRESS ? CompType : HCT_NONE) ;

  /* find full object name */

  GetFullName( FullName , pObj ) ;
  MonitorPrint( MP_POS1 , FullName , NULL ) ;

  /* save object */

  if ( ObjIsFile( pObj ) )
  {
    Ret = SaveFile( FullName , pObj , CType ) ;
    if ( *ToDelete ) DeleteFile( ToDelete ) ;
    *ToDelete = '\0' ;

    if (! ObjIsCatalog( pObj ))
    {
      BytesDone += pObj->obj_Size ;
      BytesLeft -= pObj->obj_Size ;
    }
  }
  else if ( ObjIsLink( pObj ) )
  {
    if ( IS_BFL_LINKS ) Ret = SaveLink( FullName , pObj ) ;
  }
  else if ( ObjIsDir( pObj ) )    Ret = SaveDir( FullName , pObj ) ;
  else if ( ObjIsDevice( pObj ) ) Ret = SaveDevice( pObj , CType ) ;
  else				  Ret = FALSE ;

  /* handle break or error */

  if ( HasBeenBreaked() ) return( FALSE ) ;

  if ( ! Ret )
  {
    FilesFailed++ ;
    ReportError( FullName , GetStr( MSG_REPORT_COULD_NOT_BACKUP ) ) ;
    MonitorPrint( MP_POS2 , GetStr( MSG_MONITOR_ERROR ) , MPF_LINEFEED ) ;

    if ( FULLBATCHMODE ||
	 (! YesNoRequest( GetStr( MSG_REQ_BACKUP_FAILED ) , FullName , MSG_REQ_CONTINUE_ABORT , FALSE )) )
    {
      SetPrgFlag( PF_BREAKED ) ; // this will stop the child task
      return( FALSE ) ;
    }
  }

  /* set "saved" flag on object and parent */

  if ( Ret )
    do
    {
      SetObjFlag( pObj , OBJF_SAVED ) ;
      pObj = pObj->obj_Parent ;
    }
    while ( pObj && (! ObjIsSaved( pObj )) ) ;

  /* update status */

  FilesDone++ ;
  FilesLeft-- ;
  if ( HasInterface() ) MonitorStatus( Archive ) ;

  return( TRUE ) ;
}

/*************************************************************************/

static BOOL ClearSFlag( struct Object *pObj )

/* Clear the OBJF_SAVED flag */

{
  ClearObjFlag( pObj , OBJF_SAVED ) ;
  return( TRUE ) ;
}

/*************************************************************************/

static BOOL SetABit( struct Object *pObj )

/* Set archive bit on the given object */

{
  if ( ObjIsSaved( pObj) && (! (pObj->obj_Bits & FIBF_ARCHIVE)) )
  {
    if ( sFirstCall )
    {
      MonitorPrint( MP_POS1 , GetStr( MSG_SETTING_ARCHIVE_BITS ) , MPF_LINEFEED ) ;
      sFirstCall = FALSE ;
    }
    GetFullName( FullName , pObj ) ;
    SetProtection( FullName , pObj->obj_Bits | FIBF_ARCHIVE ) ;
  }
  return( TRUE ) ;
}

/*************************************************************************/

BOOL DoBackup( struct Object *pRoot , UBYTE *pName )

/* $DOC
 * FUNCTION
 *	Front-end of all backup operations
 * INPUTS
 *	pRoot = root of a directory tree, or partition list. Objects to
 *		backup must have OBJF_SELECTED flag set
 *	pName = archive name
 * OUTPUTS
 *	Result = success/failure
 * $END
 */

{
  BYTE *p ;
  BOOL Ret ;
  BPTR Desc ;
  LONG Size, k ;
  struct ArcUnit *pUnit ;
  static BYTE VName[MINSTR+2] ;
  struct Object *pFirst, *pNext ;

  /* initializations */

  DiskNum  = 1 ;
  IdntDate = StartDate ;
  ClearPrgFlag( PF_BADCYL ) ;

  strcpy( tmp , pName ) ;
  p   = PathPart( tmp ) ;
  *p  = '\0' ;
  Ret = MyInfo( tmp , VName ) ;

  /* open the archive */

  Archive = OpenArc( pName , OAF_WRITE ) ;
  if ( ! Archive ) return( FALSE ) ;

  if ( Ret &&
       (pUnit = FindCurUnit( Archive )) &&
       (pUnit->au_Type == AUT_FILE) &&
       FindDevByName( VName ) )
  {
    Estimate( pRoot , &Size ) ;
    k = ( GInfo.id_NumBlocks - GInfo.id_NumBlocksUsed ) * GInfo.id_BytesPerBlock ;
    if ( Size > k )
    {
      k = (100 * ( Size - k )) / k ;
      SPrintf( tmp , GetStr( MSG_WARN_ARCHIVE_TOO_BIG ) , k , VName ) ;
      if (! YesNoRequest( tmp , NULL , MSG_REQ_CONTINUE_ABORT , NULL ))
      {
	CloseArc( Archive ) ;
	return( FALSE ) ;
      }
    }
  }

  /* opens the report */

  if ( ObjIsMultiVol( pRoot ) )
  {
    RootName[0] = '\0' ;
    for ( pFirst = FirstChild( pRoot ) ; pNext = NextChild( pFirst ) ; pFirst = pNext )
      if ( ObjIsSelected( pFirst ) || pFirst->obj_SelChildren )
      {
	strcat( RootName , pFirst->obj_Name ) ;

	if ( ObjIsDevice( pFirst ) && MyInfo( pFirst->obj_Name , VName ) )
	{
	  if ( p = strchr( VName , ':' ) ) *p = '\0' ;
	  strcat( RootName , VName ) ;
	}

	strcat( RootName , " " ) ;
      }
  }
  else strcpy( RootName , pRoot->obj_Name ) ;

  OpenReport( MSG_REPORT_BACKUP , PRF_BUPFLAGS / BFL_REPORT ) ;

  /* prepare data encryption */

  if ( IS_BFL_ENCRYPT )
    if ( ! GetPassword() )
    {
      YesNoRequest( GetStr( MSG_WARN_ENCRYPTION_DISABLED ) , NULL , MSG_REQ_OK , NULL ) ;
      PRF_BUPFLAGS &= ~BFL_ENCRYPT ;
    }

  /* save the directory tree, and write archive catalog */

  if ( Ret = WalkDirTree( pRoot , SaveObj , (WDTF_RECURSIVE|WDTF_DIRBEFORE|WDTF_SELECTED) ) )
  {
    if ( FilesFailed < FilesDone )
      Ret = WriteCatalog( Archive , pRoot , CompType , WCF_TOARC ) ;
    else
      Ret = FALSE ;
  }

  /* end */

  CloseArc( Archive ) ;
  if ( Ret ) MonitorPrint( MP_POS1 , GetStr( MSG_ARCHIVE_CLOSED ) , MPF_LINEFEED ) ;
  Delay( 2 * TICKS_PER_SECOND ) ;

  if ( Ret && IS_BFL_SETABIT && (! ObjIsDevice( pRoot )) )
  {
    sFirstCall = TRUE ;
    WalkDirTree( pRoot , SetABit , (WDTF_RECURSIVE|WDTF_DIRBEFORE) ) ;
  }

  WalkDirTree( pRoot , ClearSFlag , (WDTF_RECURSIVE|WDTF_DIRBEFORE) ) ;
  CloseReport() ;

  /* add a line in log file */

  strcpy( FullName , PRF_LOGFILE ) ;
  if ( Ret && FullName[0] )
  {
    if ( Desc = Open( FullName , MODE_OLDFILE ) )
      Seek( Desc , 0 , OFFSET_END ) ;
    else
      Desc = Open( FullName , MODE_NEWFILE ) ;

    if ( Desc )
    {
      SPrintf( tmp , GetStr( MSG_BACKUP_LOG ) , PackedDateToStr( IdntDate ) , RootName , FilesDone , BytesDone / ONEKILOBYTE , pName ) ;
      FPuts( Desc , tmp ) ;
      if ( strcmp( pGHdr->h_Comment , GetStr( MSG_NO_COMMENT ) ) )
      {
	SPrintf( tmp , " [%s]" , pGHdr->h_Comment ) ;
	FPuts( Desc , tmp ) ;
      }
      FPutC( Desc , '\n' ) ;
      Close( Desc ) ;
    }
    else HandleError( FullName , ABERR_CANNOT_OPEN ) ;
  }

  if ( Ret )
  {
    if ( HasBadCyl() ) YesNoRequest( GetStr( MSG_WARN_BAD_CYLINDER ) , NULL , MSG_REQ_OK , FALSE ) ;
    if ( IS_BFL_PRINTLABELS ) PrintLabels( DiskNum ) ;
  }

  return( Ret ) ;
}

/*************************************************************************/

static LONG ToCompress ;

static BOOL GetToCompress( struct Object *pObj )
{
  if ( ObjIsDir( pObj ) || ObjIsLink( pObj ) ) return( TRUE ) ;

  if ( ObjIsFile( pObj ) &&
       (pObj->obj_Size > MAXDATA) &&
       MatchNoCompExt( pObj->obj_Name ) ) return( TRUE ) ;

  ToCompress += pObj->obj_Size ;
  return( TRUE ) ;
}

BYTE *Estimate( struct Object *pRoot , LONG *pSize )

/* $DOC
 * FUNCTION
 *	Estimate backup size and time
 * INPUTS
 *	pRoot = root of all selected object
 *	pSize = pointer to a LONG which will receive archive size
 *		(may be NULL)
 * OUTPUTS
 *	Result = string to display
 * NOTES
 *	Uses the global FilesSelected and BytesSelected variables, as
 *	well as Preferences settings.
 * $END
 */

{
  BYTE *p, *q ;
  LONG CTime, CSpeed, CGain, ToWrite, WTime, NumDisks ;

  if ( ! FilesSelected ) return( (BYTE *)GetStr( MSG_WARN_NOTHING_SELECTED ) ) ;

  /* compute compression time and space */

  if ( IS_BFL_COMPRESS )
  {
    // default compression speed and ratio
    CSpeed = 50 ;
    CGain  = 32 ;

    if ( IS_XPKLIB && XpkBase )
    {
      XQT[1].ti_Data = (ULONG)PRF_XPKMETHOD ;
      XQT[2].ti_Data = (ULONG)PRF_XPKMODE ;
      if ( ! XpkQuery( XQT ) )
      {
	CSpeed = XpkInfo.xm_PackSpeed ;
	CGain  = XpkInfo.xm_Ratio ;
      }
    }

    ToCompress = 0 ;
    WalkDirTree( pRoot , GetToCompress , WDTF_SELECTED|WDTF_DIRBEFORE|WDTF_RECURSIVE ) ;
    CTime = ToCompress / KBYTES( CSpeed ) ;
    CGain = CGain * ( ToCompress / 1000 ) ;
    BytesAdded = ( 2 * BytesAdded ) / 3 ;
  }
  else
  {
    CSpeed = 0 ;
    CGain  = 0 ;
    CTime  = 0 ;
  }

  /* compute output data size in bytes */

  ToWrite  = BytesSelected + BytesAdded + ( FilesSelected * EST_INFOPERFILE ) - CGain ;
  NumDisks = ToWrite / EST_FLOPPYSIZE ;
  if ( ToWrite % EST_FLOPPYSIZE ) NumDisks++ ;

  /* compute total time */

  WTime = EST_WRITESPEED ;
  if ( IS_BFL_VERIFY && (! (IS_BFL_CHILDTASK && HasChildTask())) ) WTime = ( WTime * 3 ) / 5 ;
  WTime = ( ToWrite / WTime ) + CTime + ( NumDisks * 5 ) ;

  /* reduce time if childtask running */

  if ( IS_BFL_CHILDTASK && HasChildTask() )
  {
    CGain = 0 ;
    if ( IS_BFL_COMPRESS )    CGain |= 0x01 ;
    if ( CSpeed >= 75 )       CGain |= 0x02 ;
    if ( IS_BFL_VERIFY )      CGain |= 0x04 ;
    if ( PRF_BUFSIZE >= 128 ) CGain |= 0x08 ;
    WTime = ( EstTable[CGain] * WTime ) / 100 ;
  }

  /* build result string */

  p = PackedDateToStr( WTime ) ;
  if ( q = strrchr( p , ' ' ) ) q++ ;
			   else q = p ;

  SPrintf( tmp , GetStr( MSG_REQ_ESTIMATION ) , NumDisks , ToWrite / ONEKILOBYTE , q ) ;
  if ( pSize ) *pSize = ToWrite ;
  return( tmp ) ;
}
