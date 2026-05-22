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
    utils.c

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 04-Aug-93
    Modified: 28-Jan-97
    _______________________________________________________________________
*/

#include "headers.h"
#include <libraries/multiuser.h>
#include <proto/multiuser.h>

#define POOL_FLAG	(1<<31)

/*************************************************************************/

struct NameNode
{
  struct Node nn_Node;			// System Node structure
  BYTE	      nn_Data[MINSTR+1];	// Node-specific data
};

extern BYTE XpkErrMsg[] ;

static struct DateTime DTime ;
static BYTE tmp[MAXSTR+1], aux[MAXSTR+1] ;

static LONG ErrCodeToID[] =
{
  MSG_ABERR_CANNOT_OPEN, MSG_ABERR_DECOMP_ERROR, MSG_ABERR_READ_ERROR,
  MSG_ABERR_WRONG_PASSWORD, MSG_ABERR_VERIFY_ERROR, MSG_ABERR_BAD_PATTERN,
  MSG_ABERR_BAD_DATE, MSG_ABERR_BAD_BITS, MSG_ABERR_SYNTAX_ERROR,
  MSG_ABERR_BACKUP_TO_ITSELF, MSG_ABERR_NOT_A_TAPE, MSG_ABERR_COPYCAT_FAILED,
  MSG_ABERR_NOT_AN_ARCHIVE, MSG_ABERR_BAD_FORMAT
} ;

static LONG UnitCodeToID[] =
{
  MSG_TDERR_NOSECHDR,MSG_TDERR_BADSECPRE,MSG_TDERR_BADSECID,MSG_TDERR_BADHDRSUM,
  MSG_TDERR_BADSECSUM,MSG_TDERR_TOOFEWSECS,MSG_TDERR_BADSECHDR,-1 * ERROR_DISK_WRITE_PROTECTED,
  -1 * ERROR_NO_DISK,MSG_TDERR_SEEKERROR, -1 * ERROR_NO_FREE_STORE
} ;

/*************************************************************************/

void WakeUpUser( void )

/* $DOC
 * FUNCTION
 *	Wake-up the user, either by flashing the screen or by making a sound.
 * $END
 */

{
  if ( IS_FLASH ) DisplayBeep( NULL ) ;
  if ( IS_BEEP ) PlayBeep() ;
}

/*************************************************************************/

void ABackupAlert( BYTE *pName , BYTE *pMsg )

/* $DOC
 * FUNCTION
 *	Lowest level of error reporting: display a requester with the
 *	message, and write the message in the report file
 * INPUTS
 *	pName = pointer to the file/dir/device name (may be NULL)
 *	pMsg = error message
 * $END
 */

{
  APTR args[2] ;

  if ( HasBeenBreaked() ) return ;

  if ( ! FULLBATCHMODE ) WakeUpUser() ;
  if ( ! pName ) pName = _PROGNAME_ ;
  ReportError( pName , pMsg ) ;

  if ( HasInterface() )
  {
    args[0] = pName ;
    args[1] = pMsg ;
    Notify( MSG_REQUEST , "%s\n%s" , MSG_REQ_OK , NULL , &args[0] ) ;
  }
  else
  {
    SPrintf( tmp , "%s: %s\n" , pName , pMsg ) ;
    FPuts( Output() , tmp ) ;
    Flush( Output() ) ;
  }
}

/*************************************************************************/

void HandleError( BYTE *pName , LONG Code )

/* $DOC
 * FUNCTION
 *	Highest level of error reporting
 * INPUTS
 *	pName = file/dir/device name (may be NULL)
 *	Code = error code, may be:
 *		HERR_IOERR		use IoErr() value
 *		less than HERR_XPKERR	XPK error code
 *		ABERR_something 	ABackup error code
 *		Any other value is supposed to be a dos.library error code.
 * $END
 */

{
  BYTE *p ;

  // build error message
  if ( Code < HERR_XPKERR )
    strcpy( aux , XpkErrMsg ) ;
  else if ( Code >= ABERR_CANNOT_OPEN )
    strcpy( aux , GetStr( ErrCodeToID[Code - ABERR_CANNOT_OPEN] ) ) ;
  else
  {
    if ( Code == HERR_IOERR ) Code = IoErr() ;
    if ( Code )
    {
      Fault( Code , "" , aux , MAXSTR ) ;
      if ( p = strchr( aux , ':'  ) ) strcpy( aux , p+2 ) ;
      if ( p = strchr( aux , '\n' ) ) *p = '\0' ;
    }
    else strcpy( aux , GetStr( ErrCodeToID[ABERR_READ_ERROR - ABERR_CANNOT_OPEN] ) ) ;
  }

  // display message
  ABackupAlert( pName , aux ) ;
}

/*************************************************************************/

void UnitError( struct ArcUnit *pUnit )

/* $DOC
 * FUNCTION
 *	Reports an error that occured on a device
 * INPUTS
 *	pUnit = pointer to the unit
 * $END
 */

{
  LONG MsgID ;

  if ( pUnit )
  {
    if ( (pUnit->au_LastErr >= TDERR_NoSecHdr) &&
	 (pUnit->au_LastErr <= TDERR_NoMem) )
      MsgID = UnitCodeToID[pUnit->au_LastErr - TDERR_NoSecHdr] ;
    else
      MsgID = MSG_ERROR_DEVICE ;

    if ( MsgID >= 0 )
    {
      SPrintf( aux , GetStr( MsgID ) , pUnit->au_LastErr ) ;
      ABackupAlert( pUnit->au_Name , aux ) ;
    }
    else HandleError( pUnit->au_Name , -1 * MsgID ) ;
  }

}

/*************************************************************************/

VOID MyFreeMem( VOID *pMem )

/* $DOC
 * FUNCTION
 *	Frees a block of memory (lowest-level)
 * INPUTS
 *	pMem = pointer to the block to free
 * SEE ALSO
 *	MyAllocMem()
 * $END
 */

{
  LONG *pArea, Size ;

  if ( ! pMem ) return ;

  // retrieve size and original pointer
  pArea = pMem ;
  pArea-- ;
  Size = *pArea ;

  // free memory
  if ( Size & POOL_FLAG )
  {
    Size &= ~POOL_FLAG ;
    FreePooled( MemPool , pArea , Size ) ;
  }
  else FreeMem( pArea , Size ) ;
}

/*************************************************************************/

VOID *MyAllocMem( ULONG Size , LONG MFlags )

/* $DOC
 * FUNCTION
 *	Allocates a block of memory (lowest-level)
 * INPUTS
 *	Size = number of bytes
 *	MFlags = flags for AllocMem()
 *		(MEMF_CLEAR and MEMF_PUBLIC are forced so they may be omitted)
 * OUTPUTS
 *	Result = pointer to the block, or NULL is failed
 * NOTES
 *	Automatically tries to use pooled allocation.
 *	Use the MyFreeMem() function to free the allocated memory.
 * $END
 */

{
  LONG *pMem ;

  // add space for size, forces memory flags
  Size	 += sizeof(LONG);
  MFlags |= POOL_MEMFLAGS ;

  // allocation loop
  FOREVER
  {
    if ( MemPool && (MFlags == POOL_MEMFLAGS) )
    {
      pMem = AllocPooled( MemPool , Size ) ;
      if ( pMem ) *pMem = POOL_FLAG ; /* set bit 31 if allocated with AllocPooled() */
    }
    else pMem = AllocMem( Size , MFlags ) ;
    if ( pMem ) break ;

    if ( Size < KBYTES(2) ) break ;

    SPrintf( tmp , GetStr( MSG_REQ_NEED_MEMORY ) , Size >> 10 ) ;
    if ( FULLBATCHMODE || (! YesNoRequest( tmp , NULL , MSG_REQ_RETRY_CANCEL , FALSE )) ) break ;
  }

  // save block size
  if ( pMem ) *pMem++ |= Size ;
  return( (VOID *)pMem ) ;
}

/*************************************************************************/

struct DeviceDef *GetDeviceDef( struct Object *pObj )

/* $DOC
 * FUNCTION
 *	Returns a pointer to the DeviceDef structutre corresponding to
 *	a device object.
 * INPUTS
 *	pObj = pointer to the object
 * OUTPUTS
 *	Result = the corresponding DeviceDef structure, or NULL if the
 *	object is not a device, or not DeviceDef structure is found.
 * $END
 */

{
  struct DeviceDef *pDef ;

  if ( ObjIsDevice( pObj ) )
  {
    pDef = (struct DeviceDef *)FirstChild( pObj ) ;
    if ( pDef->dd_Node.ln_Succ ) return( pDef ) ;
  }
  return( NULL ) ;
}

/*************************************************************************/

void __stackext GetFullName( BYTE *pName , struct Object *pObj )

/* $DOC
 * FUNCTION
 *	Builds the full path name of an object
 * INPUTS
 *	pName = pointer to a buffer where to put the full path name
 *	pObj = pointer to the object
 * $END
 */

{
  /* special action for devices */
  if ( ObjIsDevice( pObj ) )
  {
    strcpy( pName , pObj->obj_Name ) ;
    return ;
  }

  /* walk up till root directory */
  if ( pObj->obj_Parent ) GetFullName( pName , pObj->obj_Parent ) ;
		     else *pName = '\0' ;

  /* add object name */
  AddPart( pName , pObj->obj_Name , MAXSTR ) ;
}

/*************************************************************************/

void BuildDestName( BYTE *pName , struct Object *pObj )

/* $DOC
 * FUNCTION
 *	Builds the full path name where to restore an object
 * INPUTS
 *	pName = pointer to a buffer where to put the full path name
 *	pObj = pointer to the object
 * $END
 */

{
  LONG k ;
  BYTE *p ;
  struct Object *pRoot, *pParent ;

  if ( ObjIsDevice( pObj ) )
    strcpy( pName , pObj->obj_Name ) ;
  else
  {
    for ( pRoot = pObj ; pParent = pRoot->obj_Parent ; pRoot = pParent )
      if ( ! pParent->obj_Name[0] ) break ;

    if ( IS_RFL_DIRTREE )
    {
      GetFullName( tmp , pObj ) ;
      if ( DestDir[0] )
      {
	strcpy( pName , DestDir ) ;
	k = pRoot->obj_Parent ? 0 : strlen( pRoot->obj_Name ) ;
	while ( p = strchr( tmp , ':' ) ) *p = '/' ;
	if ( tmp[k] == '/' ) k++ ;
	AddPart( pName , &tmp[k] , MAXSTR ) ;
      }
      else strcpy( pName , tmp ) ;
    }
    else
    {
      strcpy( pName , DestDir[0] ? DestDir : pRoot->obj_Name ) ;
      AddPart( pName , pObj->obj_Name , MAXSTR ) ;
    }
  }
}

/*************************************************************************/

BOOL MyExamine( BYTE *pName )

/* $DOC
 * FUNCTION
 *	High-level function to examine an file or directory.
 * INPUTS
 *	pName = full pathname of file/dir
 * OUTPUTS
 *	Result = success/failure
 *	If successfull, the file/dir description may be found in the
 *	global GFib structure.
 * $END
 */

{
  BOOL Res ;
  BPTR Key ;

  Key = Lock( pName , ACCESS_READ ) ;
  if ( ! Key ) return( FALSE ) ;
  Res = Examine( Key , &GFib ) ;
  UnLock( Key ) ;
  return( Res ) ;
}

/*************************************************************************/

BOOL MyInfo( BYTE *pDName , BYTE *pVName )

/* $DOC
 * FUNCTION
 *	High-level function to examine a volume
 * INPUTS
 *	pDName = name of any file/dir on the volume
 *	pVName = place where to copy volume logical name
 *		 (may be NULL, must point to at least MINSTR+2 chars)
 * OUTPUTS
 *	Result = success/failure
 *	If successfull, the volume description may be found in the global
 *	GInfo structure.
 * $END
 */

{
  BYTE *p ;
  BOOL Res ;
  BPTR Cle ;
  APTR OldPtr ;
  static BYTE PName[MAXSTR+1] ;

  OldPtr = SetWinPtr( (APTR)-1 ) ;
  Cle = Lock( pDName , ACCESS_READ ) ;
  SetWinPtr( OldPtr ) ;

  if ( ! Cle ) return( FALSE ) ;

  Res = Info( Cle , &GInfo ) ;
  if ( pVName )
    if ( NameFromLock( Cle , PName , MAXSTR+1 ) )
    {
      if ( p = strchr( PName , ':' ) ) p[1] = '\0' ;
      strncpy( pVName , PName , MINSTR+1 ) ;
      pVName[MINSTR+1] = '\0' ;
    }
    else Res = FALSE ;

  UnLock( Cle ) ;
  return( Res ) ;
}

/*************************************************************************/

void SwapNodes( struct List *pList , struct Node *pFirst, struct Node *pSecond )

/* $DOC
 * FUNCTION
 *	Swaps two nodes in an exec list
 * INPUTS
 *	pList = pointer to the list header
 *	pFirst = pointer to the first node
 *	pSecond = pointer to the second node
 * $END
 */

{
  struct Node *pFPred, *pSPred ;

  /* get the preds of the two nodes */
  pFPred = pFirst->ln_Pred ;
  if ( ! pFPred->ln_Succ ) pFPred = NULL ;
  pSPred = pSecond->ln_Pred ;
  if ( ! pSPred->ln_Succ ) pSPred = NULL ;

  /* remove the second node, and insert it after the pred of the first */
  Remove( pSecond ) ;
  Insert( pList , pSecond , pFPred ) ;

  /* remove the first node, and insert it after the old pred of the second */
  if ( pSPred != pFirst )
  {
    Remove( pFirst ) ;
    Insert( pList , pFirst , pSPred ) ;
  }
}

/*************************************************************************/

void *LoadFileInMem( BYTE *pName , LONG Size , LONG Offset )

/* $DOC
 * FUNCTION
 *	Loads a file in memory
 * INPUTS
 *	pName = full path name
 *	Size = number of bytes to read
 *	Offset = starting position
 * OUTPUTS
 *	Result = pointer to a block of memory allocated with MyAllocMem() where
 *		the file is, or NULL if failed
 * NOTES
 *	The actual allocation is sizeof(struct Object) longer than Size
 * $END
 */

{
  BPTR Desc ;
  void *pMem ;

  /* open file */
  Desc = Open( pName , MODE_OLDFILE ) ;
  if ( ! Desc )
  {
    HandleError( pName , HERR_IOERR ) ;
    return( NULL ) ;
  }
  Seek( Desc , Offset , OFFSET_BEGINNING ) ;

  /* allocate memory */
  pMem = MyAllocMem( Size+sizeof(struct Object) , NULL ) ;
  if ( ! pMem )
  {
    Close( Desc  ) ;
    return( NULL ) ;
  }

  /* read file */
  Size -= Read( Desc , pMem , Size ) ;
  Close( Desc ) ;

  if ( ! Size ) return( pMem ) ;

  HandleError( pName , HERR_IOERR ) ;
  MyFreeMem( pMem ) ;
  return( NULL ) ;
}

/****************************************************************************/

LONG PackDate( struct DateStamp *pDate )

/* $DOC
 * FUNCTION
 *	Packs a DateStamp structure into a LONG.
 * INPUTS
 *	pDate = pointer to a DateStamp structure (may be NULL, in
 *		which case current date is used)
 * OUTPUTS
 *	Result = number of seconds since 01-Jan-1978, 00h00
 * SEE ALSO
 *	UnPackDate()
 * $END
 */

{
  LONG Sec ;
  struct DateStamp DStamp ;

  if ( ! pDate )
  {
    pDate = &DStamp ;
    DateStamp( pDate ) ;
  }

  Sec  = pDate->ds_Tick   / TICKS_PER_SECOND ;
  Sec += pDate->ds_Minute * SECS_PER_MIN ;
  Sec += pDate->ds_Days   * SECS_PER_DAY ;
  return( Sec ) ;
}

/****************************************************************************/

struct DateStamp *UnPackDate( LONG Date )

/* $DOC
 * FUNCTION
 *	Unpacks a LONG into a DateStamp structure.
 * INPUTS
 *	Date = number of seconds since 01-Jan-1978, 00h00
 * OUTPUTS
 *	Result = pointer to a DateStamp structure
 * SEE ALSO
 *	PackDate()
 * $END
 */

{
  static struct DateStamp DStamp ;

  DStamp.ds_Days   = Date / SECS_PER_DAY ; Date %= SECS_PER_DAY ;
  DStamp.ds_Minute = Date / SECS_PER_MIN ; Date %= SECS_PER_MIN ;
  DStamp.ds_Tick   = Date * TICKS_PER_SECOND ;
  return( &DStamp ) ;
}

/****************************************************************************/

BYTE *PackedDateToStr( LONG Date )

/* $DOC
 * FUNCTION
 *	Builds a "DDD DD-MMM-YY HH:MM:SS " string from a packed date.
 *	(note there is a space at the end of the string !)
 * INPUTS
 *	Date = packed date
 * OUTPUTS
 *	Result = pointer to the string
 * $END
 */

{
  static BYTE day[LEN_DATSTRING], date[LEN_DATSTRING], time[LEN_DATSTRING];

  // retrieve date stamp from packed date
  memset( &DTime , '\0' , sizeof(struct DateTime) ) ;
  memcpy( &(DTime.dat_Stamp) , UnPackDate( Date ) , sizeof(struct DateStamp) ) ;

  // build date string
  DTime.dat_Format  = FORMAT_DOS ;
  DTime.dat_StrDay  = day ;
  DTime.dat_StrDate = date ;
  DTime.dat_StrTime = time ;
  DateToStr( &DTime ) ;

  SPrintf( tmp , "%.3s %.10s %s" , day , date , time ) ;
  return( tmp ) ;
}

/****************************************************************************/

LONG PackedDateFromStr( BYTE *pStr , LONG Time )

/* $DOC
 * FUNCTION
 *	Convert a string into a packed date
 * INPUTS
 *	pStr = string to convert, in the "DD-MM-YY HH:MM:SS" or "DD-MMM-YY HH:MM:SS"
 *		format. Either date or time may be omitted (not both !).
 *	Time = default time in seconds (if ommited in string)
 *
 * OUTPUTS
 *	Result = packed date, or -1 if any error occurs
 * $END
 */

{
  LONG RDate ;
  BYTE *p, *q ;
  struct DateStamp DStamp ;

  // separate date and time
  while ( isspace( *pStr ) ) pStr++ ;
  if ( p = strchr( pStr , ' ' ) ) *p++ = '\0' ;

  // make sure pStr points to date, and p points to time
  if ( strchr( pStr , ':' ) )
  {
    q = pStr ;
    pStr = p ;
    p = q ;
  }

  // convert string to date stamp
  memset( &DTime , '\0' , sizeof(struct DateTime) ) ;
  DTime.dat_Format  = FORMAT_DOS ;
  DTime.dat_StrDate = pStr ;
  DTime.dat_StrTime = p ;
  if ( ! StrToDate( &DTime ) ) return( -1 ) ;

  // set default date if needed
  if ( ! pStr )
  {
    DateStamp( &DStamp ) ;
    DTime.dat_Stamp.ds_Days = DStamp.ds_Days ;
  }

  // pack date
  RDate = PackDate( &(DTime.dat_Stamp) ) ;

  // add default time if needed
  if ( ! p ) RDate += Time ;
  return( RDate ) ;
}

/****************************************************************************/

LONG Ratio( LONG CSize , LONG Size )

/* $DOC
 * FUNCTION
 *	Computes a percentage
 * INPUTS
 *	CSize = x% value
 *	Size = 100% value
 * OUTPUTS
 *	Result = the x value that makes CSize = x% * Size
 * $END
 */

{
  while ( CSize > 21474836 )        // avoid overflow !
  {
    Size  /= 2 ;
    CSize /= 2 ;
  }

  if ( Size ) Size = ( CSize * 100 ) / Size ;

  if ( Size <   0 ) return(   0 ) ;
  if ( Size > 100 ) return( 100 ) ;
  return( Size ) ;
}

/****************************************************************************/

BOOL SolveLink( BYTE *pName , BYTE *pBuf )

/* $DOC
 * FUNCTION
 *	Finds a link destination
 * INPUTS
 *	pName = full pathname of the link
 *	pBuf = buffer where to put the name of the destination object
 *		THE BUFFER MUST BE AT LEAST MAXDATA BYTES LONG !!
 * OUTPUTS
 *	Result = success/failure
 * $END
 */

{
  BYTE *p ;
  BOOL Res ;
  size_t Len ;
  BPTR Dir, Link ;

  // go in the directory where is the link (else Lock() doesn't work)
  strcpy( tmp , pName ) ;
  if ( p = PathPart( tmp ) ) *p = '\0' ;
  Dir = Lock( tmp , ACCESS_READ ) ;
  if ( ! Dir ) return( FALSE ) ;
  Dir = CurrentDir( Dir ) ;

  // does a Lock() on the link, and go back in previous directory
  p = FilePart( pName ) ;
  Link = Lock( p , ACCESS_READ ) ;
  Dir = CurrentDir( Dir ) ;
  UnLock( Dir ) ;
  if ( ! Link ) return( FALSE ) ;

  // finds out the link destination
  Res = NameFromLock( Link , pBuf , MAXDATA ) ;
  UnLock( Link ) ;

  // clears end of buffer
  Len = strlen( pBuf ) ;
  if ( Len < MAXDATA ) memset( &pBuf[Len] , '\0' , MAXDATA - Len ) ;

  return( Res ) ;
}

/****************************************************************************/

BOOL SameObj( struct Object *pFirst , struct Object *pSecond )

/* $DOC
 * FUNCTION
 *	Compares two Object structures
 * INPUTS
 *	pFirst = pointer to the first object
 *	pSecond = pointer to the second object
 * OUTPUTS
 *	Result = TRUE if the two structures decribe the same object
 * $END
 */

{
  if ( (pFirst->obj_Flags & OBJF_TYPE) != (pSecond->obj_Flags & OBJF_TYPE) ) return( FALSE ) ;
  if ( pFirst->obj_Size != pSecond->obj_Size ) return( FALSE ) ;
  if ( pFirst->obj_Date != pSecond->obj_Date ) return( FALSE ) ;
  if ( strcmp( pFirst->obj_Name , pSecond->obj_Name ) ) return( FALSE ) ;
  return( TRUE ) ;
}

/****************************************************************************/

BOOL __stackext CheckPath( struct Object *pObj , BYTE *pName )

/* $DOC
 * FUNCTION
 *	Checks that the path of an object exists, and create it if needed
 * INPUTS
 *	pObj = pointer to the object
 *	pName = full pathname of the object
 * OUTPUTS
 *	Result = success/failure
 * $END
 */

{
  BYTE *p ;
  BOOL Ret ;
  BPTR Cle ;

  // check if object is valid
  if ( ! pObj ) return( TRUE ) ;
  if ( ObjPathOk( pObj ) ) return( TRUE ) ;
  if ( ObjIsDevice( pObj ) ) return( TRUE ) ;

  // go up in directory tree
  if ( p = strrchr( pName , '/' ) )
  {
    *p = '\0' ;
    Ret = CheckPath( pObj->obj_Parent , pName ) ;
    *p = '/' ;
    if ( ! Ret ) return( FALSE ) ;
  }

  if ( ! ObjIsNotEmptyDir( pObj ) ) return( TRUE ) ;

  // create the directory
  if ( Cle = CreateDir( pName ) )
  {
    UnLock( Cle ) ;
    SetObjFlag( pObj , OBJF_PATHOK ) ;
    return( TRUE ) ;
  }

  // check error
  if ( IoErr() == ERROR_OBJECT_EXISTS ) return( TRUE ) ;
  if ( IoErr() == ERROR_OBJECT_IN_USE ) return( TRUE ) ;
  HandleError( pName , HERR_IOERR ) ;
  return( FALSE ) ;
}

/*************************************************************************/

void CleanObj( struct Object *pObj )

/* $DOC
 * FUNCTION
 *	Cleanup an Object structure
 *	This function is to use after loading the catalog file for exemple
 * INPUTS
 *	pObj = pointer to the Object structure
 * $END
 */

{
  if ( ObjIsClean( pObj ) ) return ;

  NoChildren( pObj ) ;
  pObj->obj_Parent = NULL ;
  pObj->obj_SelChildren = 0 ;
  ClearObjFlag( pObj , OBJF_IOMASK ) ;
  memset( &(pObj->obj_Node) , '\0' , sizeof(struct MinNode) ) ;

  SetObjFlag( pObj , OBJF_CLEAN ) ;
}

/*************************************************************************/

void TmpName( BYTE *pName )

/* $DOC
 * FUNCTION
 *	Creates a unique name for a temporary file.
 * INPUTS
 *	pName = pointer to where the name is to write
 *		The buffer must be at least MAXSTR+1 bytes long
 * $END
 */

{
  LONG Ext ;
  struct DateStamp DStamp ;

  DateStamp( &DStamp ) ;
  Ext = DStamp.ds_Days + DStamp.ds_Minute + DStamp.ds_Tick ;
  Ext = ( Ext + (LONG)FindTask( NULL ) ) & 0x0ffff ;

  do
  {
    strcpy( pName , PRF_TEMPDIR ) ;
    SPrintf( tmp , "ABCK_%lX" , Ext ) ;
    AddPart( pName , tmp , MAXSTR ) ;
    Ext++ ;
  }
  while ( MyExamine( pName ) ) ;
}

/*************************************************************************/

void InitOperation( void )

/* $DOC
 * FUNCTION
 *	Initialization before any operations: backup, restore, etc..
 * $END
 */

{
  struct DateStamp Stamp ;

  /* setup some variables */
  DiskNum = 1 ;
  IdntDate = -1 ;
  ArchiveFmt = -1 ;

  DateStamp( &Stamp ) ;
  StartDate = PackDate( &Stamp ) ;
  memset( GPathTable , '\0' , PATHTABLE+1 ) ;

  FilesDone   = 0 ;
  BytesDone   = 0 ;
  FilesFailed = 0 ;
  FilesLeft   = FilesSelected ;
  BytesLeft   = BytesSelected ;

  /* set compression type */
  if ( IS_XPKLIB ) CompType = ( XpkBase ) ? HCT_XPKLIB : HCT_NONE ;
  else if ( IS_EXTERNAL ) CompType = HCT_EXTERNAL ;
  else CompType = HCT_INTERNAL ;

  /* set archive info */
  if ( PrgAction == PA_BACKUP )
  {
    GArcInfo.ai_NumFiles = FilesSelected ;
    GArcInfo.ai_NumBytes = BytesSelected ;
    GArcInfo.ai_CType	 = IS_BFL_COMPRESS ? CompType : HCT_NONE ;
    if ( IS_XPKLIB ) strcpy( GArcInfo.ai_XpkMethod , PRF_XPKMETHOD ) ;
  }

  /* set program flags */
  ClearPrgFlag( PF_BREAKED|PF_UNCRYPT|PF_CATALISTREE|PF_PAUSED|PF_CATALFOUND ) ;
}

/*************************************************************************/

BYTE *ElapsedTime( void )

/* $DOC
 * FUNCTION
 *	Compute elapsed time since "StartDate".
 * OUTPUTS
 *	Result = pointer to a string in the HH:MM:SS format
 * $END
 */

{
  LONG h, m, s ;
  struct DateStamp Stamp ;
  static BYTE tString[10] ;

  DateStamp( &Stamp ) ;
  s = PackDate( &Stamp ) - StartDate ;
  h = s / SECS_PER_HOUR ; s %= SECS_PER_HOUR ;
  m = s / SECS_PER_MIN	; s %= SECS_PER_MIN  ;
  SPrintf( tString , "%02ld:%02ld:%02ld" , h , m , s ) ;
  return( tString ) ;
}

/*************************************************************************/

BOOL StopMe( void )

/* $DOC
 * FUNCTION
 *	Test if the user asked to stop the current action
 * OUTPUTS
 *	Result = TRUE if we must stop
 * $END
 */

{
  if ( HasBeenBreaked() ) return( TRUE ) ;

  if ( HasInterface() )
    FOREVER
    {
      if ( HandleIDCMP( FALSE ) != KEEP_WINDOW ) return( TRUE ) ;
      if ( ! HasBeenPaused() ) break ;
      WaitPort( Win->UserPort ) ;
    }
  else if ( SetSignal( 0 , 0 ) & SIGBREAKF_CTRL_C )
  {
    SetPrgFlag( PF_BREAKED ) ;
    ReportBreaked() ;
    return( TRUE ) ;
  }

  if ( HasInterface() ) StripIntuiMessages() ;
  return( FALSE ) ;
}

/*************************************************************************/

BOOL IsOnMUFSVolume( BYTE *pName )

/* $DOC
 * FUNCTION
 *	Test if a file/dir is on a MultiUserFileSystem volume
 * INPUTS
 *	pName = object name
 * OUTPUTS
 *	Result = TRUE if on a MUFS volume, FALSE if not or failed
 * $END
 */

{
  struct Object *pObj ;
  struct DeviceDef *pDef ;
  static BYTE aux[MINSTR+2] ;

  if ( MyInfo( pName , aux )         &&
       (pObj = FindDevByName( aux )) &&
       (pDef = GetDeviceDef( pObj )) &&
       (pDef->dd_Env.de_DosType == MUFS_ID) ) return( TRUE ) ;

  return( FALSE ) ;
}

/*************************************************************************/

BOOL CopyFile( BYTE *pDst , BYTE *pSrc , LONG Flags )

/* $DOC
 * FUNCTION
 *	Copy a file to another
 * INPUTS
 *	pDst = destination file's name
 *	pSrc = source file's name
 *	Flags = any combination of:
 *		CFF_ADDHEADER	write pGHdr at the beginning of dest file
 * OUTPUTS
 *	Result = success/failure
 * $END
 */

{
  LONG Size ;
  BOOL Ret = FALSE ;
  BPTR SDesc, DDesc ;

  if ( SDesc = Open( pSrc , MODE_OLDFILE ) )
  {
    if ( DDesc = Open( pDst , MODE_NEWFILE ) )
    {
      if ( Flags & CFF_ADDHEADER )
      {
	PrepareData( 0 , (BYTE *)pGHdr , sizeof(struct Header) ) ;
	if ( Write( DDesc , IOBuf , TD_SECTOR ) != TD_SECTOR )
	{
	  HandleError( pDst , HERR_IOERR ) ;
	  goto _end ;
	}
      }

      while ( Size = Read( SDesc , IOBuf , IOBUFSIZE ) )
      {
	if ( Size < 0 )
	{
	  HandleError( pSrc , HERR_IOERR ) ;
	  break ;
	}

	if ( Write( DDesc , IOBuf , Size ) != Size )
	{
	  HandleError( pDst , HERR_IOERR ) ;
	  break ;
	}
      }
      if ( ! Size ) Ret = TRUE ;

_end:
      Close( DDesc ) ;
    }
    else HandleError( pDst , ABERR_CANNOT_OPEN ) ;
    Close( SDesc ) ;
  }
  else HandleError( pSrc , ABERR_CANNOT_OPEN ) ;

  return( Ret ) ;
}

/*************************************************************************/

BOOL MatchNoCompExt( BYTE *pName )

/* $DOC
 * FUNCTION
 *	Test if a file's name matches one of the extension to don't compress
 * INPUTS
 *	pName = file's name
 * OUTPUTS
 *	Result = TRUE if the name matches one extension, FALSE if not
 * $END
 */

{
  BYTE *p, *q ;

  if ( p = strrchr( pName , '.' ) )
  {
    p++ ;
    for ( q = FirstComponant( PRF_FILTER ) ; q ; q = NextComponant() )
      if (! stricmp( p , q )) return( TRUE ) ;
  }

  return( FALSE ) ;
}

/*************************************************************************/

VOID StringToList(struct List *list,STRPTR string)

/* Converts a string of names into a list */

{
	UBYTE	i,j,name[256];

	NewList(list);

	for (i = 0; string[i]; i += j + (string[i+j] ? 1 : 0)) {
		for (j = 0; string[i+j] && string[i+j] != ','; j++) ;
		strncpy(name,&string[i],j);
		name[j] = '\0';
		AddName(list,name);
	}
}

/*************************************************************************/

UWORD ListToString(struct List *list,STRPTR string)

/* Converts a list of names into a string */

{
	UWORD		pos = 0;
	struct Node	*nn;

	string[0] = '\0';
	for (nn = (struct Node *)list->lh_Head;
	     nn->ln_Succ;
	     nn = nn->ln_Succ,pos++) {
		if (pos) strcat(string,",");
		strcat(string,nn->ln_Name);
	}
	return(pos);
}

/*************************************************************************/

BOOL AddName (struct List *list,STRPTR name)
{
	struct NameNode *namenode;

	if (namenode = MyAllocMem(sizeof(struct NameNode),NULL)) {
		strcpy(namenode->nn_Data,name);
		namenode->nn_Node.ln_Name = namenode->nn_Data;
		namenode->nn_Node.ln_Type = NT_USER;
		namenode->nn_Node.ln_Pri  = 0;
		AddTail(list,(struct Node *)namenode);
		return(TRUE);
	}

	Warning(MSG_WARN_MEMORY);
	return(FALSE);
}

/*************************************************************************/

VOID FreeNameList (struct List *list)
{
	struct NameNode *nn,*wn;

	wn = (struct NameNode *)(list->lh_Head);

	while (nn = (struct NameNode *)(wn->nn_Node.ln_Succ)) {
		MyFreeMem(wn);
		wn = nn;
	}

	NewList(list);
}

/*************************************************************************/

struct Node *FindDevNode(struct List *plist, UWORD num)

{
	struct Node *nn;
	UWORD i;

	for (i = 0,nn = (struct Node *)plist->lh_Head;nn->ln_Succ; i++,nn = nn->ln_Succ)
		if (i == num) return(nn);

	return(NULL);
}

/*************************************************************************/

static BYTE *pComp = NULL, FullString[MAXSTR+1] ;

BYTE *NextComponant( void )

/* $DOC
 * FUNCTION
 *	Extract the next name from a list. The heading and trailing spaces
 *	are deleted.
 * OUTPUTS
 *	Result = pointer to the next name, or NULL if end of list reached
 * SEE ALSO
 *	FirstComponant()
 * $END
 */

{
  BYTE *pStart ;

  if ( ! pComp ) return( NULL ) ;

  /* find start of substring */
  for ( pStart = pComp ; isspace( *pStart ) ; pStart++ ) ;

  /* go to the end of the substring */
  for ( pComp = pStart ; ! isspace( *pComp ) ; pComp++ )
  {
    if ( *pComp == ',' ) break ;
    if ( ! *pComp ) break ;
  }

  /* mark end of substring */
  if ( *pComp ) *pComp++ = '\0' ;
	    else pComp = NULL ;

  return( pStart ) ;
}

/*************************************************************************/

BYTE *FirstComponant( BYTE *pString )

/* $DOC
 * FUNCTION
 *	Extract the first name from a list. The heading and trailing spaces
 *	are deleted.
 * INPUTS
 *	pString = pointer to a list of name separated by commas
 * OUTPUTS
 *	Result = pointer to the first name, or NULL if no comma found
 * NOTES
 *	The input string is not modified.
 * SEE ALSO
 *	FreeComponant()
 * $END
 */

{
  if (! strchr( pString , ',' )) return( NULL ) ;

  strcpy( FullString , pString ) ;
  pComp = FullString ;
  return( NextComponant() ) ;
}

/*************************************************************************/

BOOL CheckAccess( struct Header *pHdr )

/* $DOC
 * FUNCTION
 *	Check if the current user can access the given object
 * INPUTS
 *	pHdr = header describing the object
 * OUTPUTS
 *	Result = TRUE if access granted, FALSE if access denied
 * NOTES
 *	Access control is performed using MUFS
 * $END
 */

{
  VOID *user ;
  ULONG prot, flags ;
  BOOL access = FALSE ;

  if ( muBase && (user = muGetTaskExtOwner( NULL )) )
  {
    flags = pHdr->h_Obj.obj_Bits ;
    prot  = muGetRelationshipA( user , (pHdr->h_OwnerUID << 16) | pHdr->h_OwnerGID , NULL ) ;

    if ( prot & muRelF_ROOT_UID )                               // "root" has all accesses
      flags |= FIBF_READ ;
    else if ( prot & (muRelF_UID_MATCH|muRelF_NO_OWNER) )       // check "user" level access
      flags = ~flags ;
    else if ( prot & muRelF_GID_MATCH )                         // check "group" level access
      flags >>= FIBB_GRP_DELETE ;
    else							// check "other" level access
      flags >>= FIBB_OTR_DELETE ;

    if ( flags & FIBF_READ ) access = TRUE ;
    muFreeExtOwner( user ) ;
  }

  return( access ) ;
}

/*************************************************************************/

LONG AutoSplitLimit( void )

/* $DOC
 * FUNCTION
 *	Estimates the free space on the volume used for temporary storage
 *	Files bigger than this estimated space will be automatically splitted
 *	during backup.
 * OUTPUT
 *	Result = estimated free space
 * $END
 */

{
  BPTR l1, l2 ;
  LONG free = 0 ;

  if ( l1 = Lock( PRF_TEMPDIR , ACCESS_READ ) )
  {
    if ( Info( l1 , &GInfo ) ) free = ( GInfo.id_NumBlocks - GInfo.id_NumBlocksUsed ) * GInfo.id_BytesPerBlock ;
    if ( (! free) && (l2 = Lock( "RAM:"  , ACCESS_READ )) )
    {
      if ( SameDevice( l1 , l2 ) ) free = AvailMem( NULL ) ;
      UnLock( l2 ) ;
    }
    UnLock( l1 ) ;
  }

  free = ( free * 3 ) / 4 ;
  return( free ) ;
}

