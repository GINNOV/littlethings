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
    report.c

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 13-Sep-93
    Modified: 17-Jan-99
    _______________________________________________________________________
*/

#include "headers.h"

#define WRL_LONGONLY	0x0001		// write line only if long report
#define WRL_USEBOLD	0x0002		// write line in boldface

#define WRF_REPORT	0x0001		// produce report
#define WRF_REPTOFILE	0x0002		// report to file, not to printer
#define WRF_REPSHORT	0x0004		// short report only

/*************************************************************************/

BYTE ReportName[MAXSTR+1] = "" ;

static BOOL ShortReport ;
static BPTR FDesc = NULL ;
static BYTE tLine[MAXSTR+1] ;

static BYTE *FmtInfo = "%-48s %9lu (%2lu %%) %s\n" ,
	    *FmtErr  = "%s: %s\n" ;

/*************************************************************************/

static BOOL PrintEntry( struct Object *pObj )

/* $DOC
 * FUNCTION
 *	Print the given entry
 * INPUTS
 *	pObj = pointer to the entry
 * OUTPUTS
 *	Result = succes/failure
 * NOTES
 *	The global variable FDesc must be set before calling this function
 * $END
 */

{
  BYTE *p ;

  p = BuildEntryText( pObj ) ;
  if ( FPuts( FDesc , p ) || FPuts( FDesc , "\n" ) ) return( FALSE ) ;
  return( TRUE ) ;
}

/*************************************************************************/

void PrintCurrentList( struct Object *pDir )

/* $DOC
 * FUNCTION
 *	Print all the entries of the given directory
 * INPUTS
 *	pDir = pointer to directory/root object
 * $END
 */

{
  BOOL PrintList = TRUE ;

  FDesc = Open( "PRT:" , MODE_NEWFILE ) ;
  if ( ! FDesc ) return ;

  if ( ! ObjIsDevice( pDir ) )
  {
    SPrintf( tLine , "%s %s\n\n" , GetStr( MSG_DIRECTORY ) , pDir->obj_Name ) ;
    if ( FPuts( FDesc , tLine ) ) PrintList = FALSE ;
  }
  if ( PrintList ) WalkDirTree( pDir , PrintEntry , WDTF_DIRBEFORE ) ;

  Close( FDesc ) ;
  FDesc = NULL ;
}

/*************************************************************************/

void PrintLabels( LONG NumDisks )

/* $DOC
 * FUNCTION
 *	Print disks labels
 * INPUTS
 *	NumDisks = number of disks written
 * NOTES
 *	Uses some globals variables like FilesDone, StartDir, etc..
 * $END
 */

{
  BPTR Desc ;
  LONG k, LLine ;

  if ( (! FULLBATCHMODE) &&
       (! YesNoRequest( GetStr( MSG_REQ_PREPARE_LABEL ) , NULL , MSG_REQ_CONTINUE_ABORT , FALSE )) ) return ;

  Desc = Open( "PRT:" , MODE_NEWFILE ) ;
  if ( ! Desc ) return ;

  for ( k = 1 ; k <= NumDisks ; k++ )
  {
    LLine = 0 ;

    SPrintf( tLine , "\033[4m%s %s   %s %ld/%ld\033[24m\n" , _PROGNAME_ , _PROGVER_  , GetStr( MSG_DISK ) , k , NumDisks ) ;
    if ( FPuts( Desc , tLine ) ) break ;
    LLine++ ;

    SPrintf( tLine , "%s\n" , RootName ) ;
    if ( FPuts( Desc , tLine ) ) break ;
    LLine++ ;

    SPrintf( tLine , GetStr( MSG_LABEL_FILES_BYTES ) , FilesDone , BytesDone ) ;
    if ( FPuts( Desc , tLine ) ) break ;
    LLine++ ;

    SPrintf( tLine , "%s\n" , PackedDateToStr( IdntDate ) ) ;
    if ( FPuts( Desc , tLine ) ) break ;
    LLine++ ;

    tLine[0] = '\0' ;
    if ( strcmp( pGHdr->h_Comment, GetStr( MSG_NO_COMMENT ) ) )
    {
      strcpy( tLine , pGHdr->h_Comment ) ;
      strcat( tLine , "\n" ) ;
    }
    if ( FPuts( Desc , tLine ) ) break ;

    while ( ++LLine < PRF_LABELSLENGTH )
      if ( FPuts( Desc , "\n" ) ) goto _end ;
  }

_end:

  Close( Desc ) ;
}

/*************************************************************************/

void OpenReport( LONG MsgID , LONG Flags )

/* $DOC
 * FUNCTION
 *	Opens the report file.
 * INPUTS
 *	MsgID  = message identifier of the operation name (used for writing
 *		 report header)
 *	Flags  = user preferences for report in bits 0, 1 and 2
 * $END
 */

{
  struct ArcUnit *pUnit ;

  /* initialisation */

  FDesc = NULL ;
  ShortReport = ( Flags & WRF_REPSHORT ) ? TRUE : FALSE ;

  if (! (Flags & WRF_REPORT)) return ;

  /* set report file name */

  ReportName[0] = '\0' ;
  if ( BATCHMODE && ARG_REPORT[0] )
    strcpy( ReportName , ARG_REPORT ) ;
  else if ( Flags & WRF_REPTOFILE )
  {
    if ( FULLBATCHMODE ) return ;
    if ( ARG_REPORT[0] )
      strcpy( ReportName , ARG_REPORT ) ;
    else if ( (pUnit = FindCurUnit( Archive )) && (pUnit->au_Type == AUT_FILE) )
      SPrintf( ReportName , "%s.report" , pUnit->au_Name ) ;
    if (! FileRequest( MSG_REQ_TITLE_REPORT_FILE , ReportName , NULL )) return ;
    strcpy( ARG_REPORT , ReportName ) ;
  }
  else strcpy( ReportName , "PRT:" ) ;

  /* open the report file */

  if ( HasInterface() )
  {
    SetGad( GD_Report, GTTX_Text, (ULONG)ReportName ) ;
    MonitorPrint( MP_POS1 , GetStr( MSG_REPORT_OPENING ) , MPF_LINEFEED ) ;
  }

  FDesc = Open( ReportName , MODE_NEWFILE ) ;
  if ( ! FDesc )
  {
    HandleError( ReportName , ABERR_CANNOT_OPEN ) ;
    ReportName[0] = '\0' ;
    return ;
  }

  /* write report header */

  SPrintf( tLine , GetStr( MSG_REPORT_HEADER1 ) , _PROGNAME_ , _PROGVER_, GetStr( MsgID ) , PackedDateToStr( StartDate ) ) ;
  if ( FPuts( FDesc , tLine ) )
  {
_err:
    HandleError( ReportName , ABERR_CANNOT_OPEN ) ;
    ReportName[0] = '\0' ;
    Close( FDesc ) ;
    FDesc = NULL ;
    return ;
  }

  if ( FPuts( FDesc , GetStr( MSG_REPORT_HEADER2 ) ) ) goto _err ;

  SPrintf( tLine , " %s\n" , RootName ) ;
  if ( FPuts( FDesc , tLine ) ) goto _err ;

  SPrintf( tLine , GetStr( MSG_REPORT_HEADER3 ) , ( MsgID == MSG_REPORT_BACKUP ) ? PRF_BUPTO : PRF_RESFROM ) ;
  if ( FPuts( FDesc , tLine ) ) goto _err ;
}

/*************************************************************************/

void CloseReport( void )

/* $DOC
 * FUNCTION
 *	Close the report file
 * $END
 */

{
  if ( FDesc )
  {
    SPrintf( tLine , GetStr( MSG_REPORT_FOOTER1 ) , FilesDone , BytesDone ) ;
    if (! FPuts( FDesc , tLine ))
    {
      SPrintf( tLine , GetStr( MSG_REPORT_FOOTER2 ) , ElapsedTime() ) ;
      if (! FPuts( FDesc , tLine )) FPutC( FDesc , '\f' ) ;
    }
    Close( FDesc ) ;
  }

  FDesc = NULL ;
}

/*************************************************************************/

static void WriteReportLine( LONG Flags )

/*
 * Called to add line in the report file
 * This function decide if we must write the line or not
 */

{
  if ( ShortReport && (Flags & WRL_LONGONLY) ) return ;
  if ( FDesc )
  {
    if ( (Flags & WRL_USEBOLD) && FPuts( FDesc , "\033[1m" ) ) goto _err ;
    if ( FPuts( FDesc , tLine ) ) goto _err ;
    if ( (Flags & WRL_USEBOLD) && FPuts( FDesc , "\033[22m" ) ) goto _err ;
  }

  return ;

_err:

  Close( FDesc ) ;
  FDesc = NULL ;
}

/*************************************************************************/

void ReportBreaked( void )

/* $DOC
 * FUNCTION
 *	Write a message telling the operation has been breaked
 * $END
 */

{
  strcpy( tLine , GetStr( MSG_REPORT_BREAKED ) ) ;
  WriteReportLine( WRL_USEBOLD ) ;
}

/*************************************************************************/

void ReportError( BYTE *pName , BYTE *pMsg )

/* $DOC
 * FUNCTION
 *	Write an error message to the report file
 * INPUTS
 *	pName = pointer to file/device name
 *	pMsg = error message
 * $END
 */

{
  SPrintf( tLine , FmtErr , pName , pMsg ) ;
  WriteReportLine( WRL_USEBOLD ) ;
}

/*************************************************************************/

void ReportBadCyl( struct ArcUnit *pUnit , LONG Cyl )

/* $DOC
 * FUNCTION
 *	Write a line about a bad cylinder in the report file
 * INPUTS
 *	pUnit = pointer to the unit
 *	Cyl = cylinder number
 * $END
 */

{
  SPrintf( tLine , GetStr( MSG_REPORT_BAD_CYLINDER ) , pUnit->au_Name , Cyl , pUnit->au_CurDisk ) ;
  WriteReportLine( WRL_USEBOLD ) ;
}

/*************************************************************************/

void ReportBFile( struct Object *pObj , BYTE *pName , LONG Ratio )

/* $DOC
 * FUNCTION
 *	Write a line about a file in the report file (backup)
 * INPUTS
 *	pObj = pointer to the (file) object
 *	pName = file name
 *	Ratio = compression ratio
 * $END
 */

{
  pName = FormatFileName( pName , 48 ) ;
  SPrintf( tLine , FmtInfo , pName , pObj->obj_Size , Ratio , PackedDateToStr( pObj->obj_Date ) ) ;
  WriteReportLine( WRL_LONGONLY ) ;
}

/*************************************************************************/

void ReportBCatal( struct Object *pObj , LONG Ratio )

/* $DOC
 * FUNCTION
 *	Write a line about the archive catalog in the report file (backup)
 * INPUTS
 *	pObj = pointer to the object
 *	Ratio = compression ratio
 * $END
 */

{
  SPrintf( tLine , FmtInfo , GetStr( MSG_MONITOR_CATALOG ) , pObj->obj_Size , Ratio , "" ) ;
  WriteReportLine( WRL_LONGONLY ) ;
}

/*************************************************************************/

void ReportBDir( struct Object *pObj , BYTE *pName )

/* $DOC
 * FUNCTION
 *	Write a line about a directory in the report file (backup)
 * INPUTS
 *	pObj = pointer to the (dir) object
 *	pName = dir name
 * NOTES
 *	This function is also used when restoring
 * $END
 */

{
  pName = FormatFileName( pName , 48 ) ;
  SPrintf( tLine , "%-48s     <dir>        %s\n" , pName , PackedDateToStr( pObj->obj_Date ) ) ;
  WriteReportLine( WRL_LONGONLY ) ;
}

/*************************************************************************/

void ReportBLink( struct Object *pObj , BYTE *pName )

/* $DOC
 * FUNCTION
 *	Write a line about a link in the report file (backup)
 * INPUTS
 *	pObj = pointer to the (link) object
 *	pName = link name
 * NOTES
 *	This function is also used when restoring
 * $END
 */

{
  pName = FormatFileName( pName , 48 ) ;
  SPrintf( tLine , "%-48s    <link>        %s\n" , pName , PackedDateToStr( pObj->obj_Date ) ) ;
  WriteReportLine( WRL_LONGONLY ) ;
}

/*************************************************************************/

void ReportBCyl( BYTE *pName , LONG CylSize , LONG Ratio )

/* $DOC
 * FUNCTION
 *	Write a line about a cylinder in the report file (backup)
 * INPUTS
 *	pName = device name, with cylinder number
 *	CylSize = cylinder size
 *	Ratio = compression ratio
 * $END
 */

{
  SPrintf( tLine , FmtInfo , pName , CylSize , Ratio , "" ) ;
  WriteReportLine( WRL_LONGONLY ) ;
}

/*************************************************************************/

void ReportBFRemoved( BYTE *pName )

/* $DOC
 * FUNCTION
 *	Write a line about the deletion of a bad restored file
 * INPUTS
 *	pName = file name
 * $END
 */

{
  SPrintf( tLine , FmtErr , pName , GetStr( MSG_REPORT_BAD_FILE ) ) ;
  WriteReportLine( WRL_USEBOLD ) ;
}

/*************************************************************************/

void ReportNotReplaced( BYTE *pName )

/* $DOC
 * FUNCTION
 *	Write a line about an object not replaced when restoring
 * INPUTS
 *	pName = object name
 * $END
 */

{
  SPrintf( tLine , FmtErr , pName , GetStr( MSG_REPORT_NOT_REPLACED ) ) ;
  WriteReportLine( WRL_USEBOLD ) ;
}

/*************************************************************************/

void ReportRenamed( BYTE *pOldName , BYTE *pNewName )

/* $DOC
 * FUNCTION
 *	Write a line about an object renamed when restoring
 * INPUTS
 *	pOldName = "normal" object name
 *	pNewName = name entered by user
 * $END
 */

{
  SPrintf( tLine , GetStr( MSG_REPORT_RENAMED ) , pOldName , pNewName ) ;
  WriteReportLine( NULL ) ;
}

/*************************************************************************/

void ReportNotFound( BYTE *pName )

/* $DOC
 * FUNCTION
 *	Write a line about an object not found
 * INPUTS
 *	pName = object name
 * $END
 */

{
  SPrintf( tLine , FmtErr , pName , GetStr( MSG_REPORT_NOT_FOUND ) ) ;
  WriteReportLine( WRL_USEBOLD ) ;
}

/*************************************************************************/

void ReportRFile( struct Object *pObj , BYTE *pName )

/* $DOC
 * FUNCTION
 *	Write a line about a file in the report file (restore)
 * INPUTS
 *	pObj = pointer to the (file) object
 *	pName = file name
 * $END
 */

{
  pName = FormatFileName( pName , 48 ) ;
  SPrintf( tLine , "%-48s %9lu        %s\n" , pName , pObj->obj_Size , PackedDateToStr( pObj->obj_Date ) ) ;
  WriteReportLine( WRL_LONGONLY ) ;
}

/*************************************************************************/

void ReportRCyl( BYTE *pName , LONG CylSize )

/* $DOC
 * FUNCTION
 *	Write a line about a cylinder in the report file (restore)
 * INPUTS
 *	pName = device name, with cylinder number
 *	CylSize = cylinder size
 * $END
 */

{
  SPrintf( tLine , "%-48s %9lu\n" , pName , CylSize ) ;
  WriteReportLine( WRL_LONGONLY ) ;
}

/*************************************************************************/

void ReportVDifferent( BYTE *pName )

/* $DOC
 * FUNCTION
 *	Write a line about data not the same (verify file)
 * INPUTS
 *	pName = file name
 * $END
 */

{
  SPrintf( tLine , FmtErr , pName , GetStr( MSG_REPORT_COMPARE_FAILED ) ) ;
  WriteReportLine( WRL_USEBOLD ) ;
}

/*************************************************************************/

void ReportVChanged( BYTE *pName )

/* $DOC
 * FUNCTION
 *	Write a line about a file modified (verify file)
 * INPUTS
 *	pName = file name
 * $END
 */

{
  SPrintf( tLine , FmtErr , pName , GetStr( MSG_REPORT_FILE_MODIFIED ) ) ;
  WriteReportLine( WRL_USEBOLD ) ;
}

/*************************************************************************/

void ReportVFile( struct Object *pObj , BYTE *pName )

/* $DOC
 * FUNCTION
 *	Write a line about a file in the report file (verify)
 * INPUTS
 *	pObj = pointer to the (file) object
 *	pName = file name
 * $END
 */

{
  pName = FormatFileName( pName , 48 ) ;
  SPrintf( tLine , "%-48s %9lu        %s\n" , pName , pObj->obj_Size , PackedDateToStr( pObj->obj_Date ) ) ;
  WriteReportLine( WRL_LONGONLY ) ;
}

/*************************************************************************/

void ReportAccessDenied( BYTE *pName )

/* $DOC
 * FUNCTION
 *	Write a line about a file with denied access
 * INPUTS
 *	pName = file name
 * $END
 */

{
  SPrintf( tLine , FmtErr , pName , GetStr( MSG_REPORT_ACCESS_DENIED ) ) ;
  WriteReportLine( WRL_USEBOLD ) ;
}

