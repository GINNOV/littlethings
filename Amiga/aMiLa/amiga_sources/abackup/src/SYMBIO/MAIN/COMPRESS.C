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
    compress.c

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 10-Sep-93
    Modified: 18-Nov-95
    _______________________________________________________________________
*/

#include "headers.h"

static BPTR InFile, OutFile ;
static BYTE *OutBuf, *InBuf ;
static LONG InSize, OutSize ;

BYTE ToDelete[MAXSTR+1] = "" ;

#ifndef _GENPROTO
#include "Compress_int.c"
#include "Compress_ext.c"
#include "Compress_xpk.c"
#endif

#define MAXREAD 	(IOBUFSIZE/2)

/*************************************************************************/

static BOOL CompareFiles( BYTE *pSrc , BYTE *pDst , LONG Start , LONG Size )

/*
 * Compare two files of the given size
 * Start = starting offset in pDst
 * Size  = number of bytes to compare
 */

{
  BOOL Ret ;
  BPTR f1, f2 ;
  LONG ToRead ;

  Ret = FALSE ;
  MonitorPrint( MP_POS2 , GetStr( MSG_MONITOR_COMPARING ) , NULL ) ;

  if ( f1 = Open( pSrc , MODE_OLDFILE ) )
  {
    if ( f2 = Open( pDst , MODE_OLDFILE ) )
    {
      Seek( f2 , Start , OFFSET_BEGINNING ) ;
      while ( Size > 0 )
      {
	if ( StopMe() ) break ;

	ToRead = MIN( Size , MAXREAD ) ;
	if ( Read( f1 , IOBuf , ToRead ) != ToRead ) break ;
	if ( Read( f2 , &IOBuf[MAXREAD] , ToRead ) != ToRead ) break ;
	if ( memcmp( IOBuf , &IOBuf[MAXREAD] , (size_t)ToRead ) ) break ;

	Size -= ToRead ;
      }
      if ( ! Size ) Ret = TRUE ;
      Close( f2 ) ;
    }
    Close( f1 ) ;
  }

  return( Ret ) ;
}

/*************************************************************************/

static LONG IntCompFile( BYTE *pSName , BYTE *pDName , LONG Start )

/* Internal file compression, returns length of result (-1 if error) */

{
  BOOL Res ;

  /* opens source file */
  InFile = Open( pSName , MODE_OLDFILE ) ;
  if ( ! InFile ) return( -1 ) ;
  Seek( InFile , Start , OFFSET_BEGINNING ) ;

  /* open destination file */
  OutFile = Open( pDName , MODE_NEWFILE ) ;
  if ( ! OutFile )
  {
    Close( InFile ) ;
    return( -1 ) ;
  }

  /* compress data */
  InBuf  = GIOBuf ;
  OutBuf = NULL ;
  Res = compress() ;
  Close( OutFile ) ;
  Close( InFile ) ;

  if ( ! Res ) return( -1 ) ;
  return( OutSize ) ;
}

/*************************************************************************/

static LONG ExtCompFile( BYTE *pSName , BYTE *pDName )

/* External file compression, returns lenght of result (-1 if error) */

{
  strcat( pDName , ARG_ECSUFFIX ) ;
  if (! RunExtPrg( PRF_COMP , pSName , pDName )) return( -1 ) ;
  if ( ! MyExamine( pDName ) ) return( -1 ) ;
  if ( StopMe() ) return( -1 ) ;
  OutSize = GFib.fib_Size ;
  return( OutSize ) ;
}

/*************************************************************************/

BYTE *CompressFile( BYTE *pName , struct Header *pHdr , LONG block , UBYTE CompType )

/* $DOC
 * FUNCTION
 *	Compresses a file. Informations for decompression are put in the file
 *	header.
 * INPUTS
 *	pName = pointer to the full pathname of the file to compress
 *	pHdr = pointer to the file header
 *	block = block number to compress
 *	CompType = compression algorithm to use
 * OUTPUTS
 *	Result = pointer to the full pathname of the compressed file
 *	If the compression failed, returns the original name of the file,
 *	except for splited files, in which case NULL is returned
 * NOTES
 *	The file is not compressed if smaller than MAXDATA bytes, if already
 *	compressed, or if excluded by the compression filters.
 * $END
 */

{
  LONG RSize, start ;

  ToDelete[0] = '\0' ;

  /* compression filter */

  if ( CompType == HCT_NONE ) return( pName ) ;                 // exclude if no compression
  if ( MatchNoCompExt( pName ) ) return( pName ) ;              // exclude by extension
  RSize = GetFileType( pName , TRUE ) ;                         // exclude if already compressed
  if ( RSize < FTYPE_EMPTY ) return( pName ) ;

  if ( pHdr->h_Type != HT_SPLIT )
    if ( pHdr->h_Obj.obj_Size <= MAXDATA ) return( pName ) ;    // exclude if size < MAXDATA

  /* prepare compression */

  TmpName( ToDelete ) ;

  start = block * pHdr->h_BSize ;
  InSize = pHdr->h_Obj.obj_Size - start ;
  if ( InSize < pHdr->h_BSize )
  {
    pHdr->h_BSize = InSize ;
    if ( InSize <= MAXDATA ) CompType = HCT_NONE ;
  }
  else InSize = pHdr->h_BSize ;

  /* call the right compression function */

  RSize = -1 ;

  switch ( CompType )
  {
    case HCT_INTERNAL :

      RSize = IntCompFile( pName , ToDelete , start ) ;
      break ;

    case HCT_EXTERNAL :

      RSize = ExtCompFile( pName , ToDelete ) ;
      break ;

    case HCT_XPKLIB :

      RSize = XpkCompFile( pName , ToDelete , start ) ;
      break ;
  }

  /* check if compression is ok */

  if ( (RSize < 0) || (RSize >= InSize) )
  {
    /*
     * Special action when a block of a splited file is not compressed :
     * we copy the given block to the temporary file. If it failed, we
     * return NULL to abort processing of the splited file
     */

    if ( pHdr->h_Type == HT_SPLIT )
    {
      CompType = HCT_NONE ;
      if ( InFile = Open( pName , MODE_OLDFILE ) )
      {
	Seek( InFile , start , OFFSET_BEGINNING ) ;
	if ( OutFile = Open( ToDelete , MODE_NEWFILE ) )
	{
	  for ( start = 0 ; start < pHdr->h_BSize ; start += InSize )
	  {
	    InSize = pHdr->h_BSize - start ;
	    if ( InSize > MaxIoSize() ) InSize = MaxIoSize() ;
	    if ( Read( InFile , GIOBuf , InSize ) != InSize )
	    {
	      HandleError( pName , HERR_IOERR ) ;
	      break ;
	    }
	    if ( Write( OutFile , GIOBuf , InSize ) != InSize )
	    {
	      HandleError( ToDelete , HERR_IOERR ) ;
	      break ;
	    }
	  }
	  if ( start >= pHdr->h_BSize ) RSize = start ;
	  Close( OutFile ) ;
	}
	Close( InFile ) ;
      }
      if ( RSize == -1 ) return( NULL ) ;
    }
    else return( pName ) ;
  }

  /* update file header */

  UpdateHeader( pHdr , CompType , RSize ) ;
  return( ToDelete ) ;
}

/*************************************************************************/

static LONG IntCompCyl( BYTE *pSrc , BYTE *pDst )

/* Internal cylinder compression, returns lenght of result (-1 if error) */

{
  InFile  = NULL ;
  OutFile = NULL ;
  InBuf   = pSrc ;
  OutBuf  = pDst ;
  if (! compress()) return( -1 ) ;
  return( OutSize ) ;
}

/*************************************************************************/

LONG CompressCyl( struct ArcUnit *pUnit , BYTE *pDst , UBYTE CompType )

/* $DOC
 * FUNCTION
 *	Compresses a device cylinder
 * INPUTS
 *	pUnit = pointer to the unit, which buffer contains the cylinder to
 *	compress
 *	pDst = pointer to the memory area where to put the compressed data
 *	CompType = compression algorithm to use
 * OUTPUTS
 *	Result = length of the compressed data, or -1 if any error occurs
 * NOTES
 *	The external compression is not supported in this case.
 * $END
 */

{
  LONG RSize ;
  BYTE *pRDst, *pRSrc ;

  InSize = pUnit->au_CylSize ;
  pRDst  = &pDst[sizeof(LONG)] ;
  pRSrc  = &pUnit->au_Buffer[sizeof(LONG)] ;

  /*
   * Call the right compression function
   * NOTE: external compression is not supported in this case
   */

  switch ( CompType )
  {
    case HCT_INTERNAL : RSize = IntCompCyl( pRSrc , pRDst ) ;
			break ;
    case HCT_XPKLIB   : RSize = XpkCompCyl( pRSrc , pRDst , pUnit->au_BufSize ) ;
			break ;
    default	      : RSize = -1 ;
			break ;
  }

  /* write final lenght and exit */
  if ( (RSize < 0) || (RSize >= InSize) ) RSize = -1 ;
  else memcpy( pDst , &RSize , sizeof(LONG) ) ;

  return( RSize ) ;
}

/*************************************************************************/

static BOOL ExtDecompFile( struct Header *pHdr , BYTE *pDName )

/* External file decompression */

{
  BOOL Ret ;

  Ret = FALSE ;
  TmpName( ToDelete ) ;
  strcat( ToDelete , ARG_ECSUFFIX ) ;
  if ( ReadFile( pHdr , ToDelete ) )
    Ret = RunExtPrg( PRF_DECOMP , ToDelete , pDName ) ;
  if ( StopMe() ) return( -1 ) ;
  DeleteFile( ToDelete ) ;
  return( Ret ) ;
}

/*************************************************************************/

LONG DecompressFile( struct Header *pHdr , BYTE *pName , BYTE *pCmp )

/* $DOC
 * FUNCTION
 *	Extract and decompresses a file from an archive.
 * INPUTS
 *	pHdr  = pointer to the file header
 *	pName = pointer to the full pathname of destination file
 *	pCmp  = name of the original file (if not NULL, the extracted
 *		data is compared with the data in this file)
 * OUTPUTS
 *	Result = DFR_OK if successful
 *		 DFR_READERR if couldn't extract data
 *		 DFR_CMPERR if comparison failed
 * $END
 */

{
  BOOL Res ;
  LONG Ret, k, l, osize ;

  Ret = DFR_READERR ;

  /* check access rights */

  if ( ObjIsMultiUser( &(pHdr->h_Obj) ) )
    for ( k = 0 ; ! CheckAccess( pHdr ) ; k++ )
    {
      if ( ! k ) ReportAccessDenied( pHdr->h_Obj.obj_Name ) ;
      if ( FULLBATCHMODE || (! YesNoRequest( GetStr( MSG_REQ_ACCESS_DENIED ) , pHdr->h_Obj.obj_Name , MSG_REQ_RETRY_CANCEL , FALSE )) ) return( DFR_READERR ) ;
    }

  /* extract and decompress the object */

  switch ( pHdr->h_CType )
  {
    case HCT_NONE :

      // special case for verifying a file larger than available memory
      osize = AutoSplitLimit() ;

      if ( (PrgAction == PA_VERIFY) && (pHdr->h_CSize > osize) )
      {
	osize = MaxIoSize() ;
	for ( k = 0 ; k < pHdr->h_CSize ; k += l )
	{
	  l = pHdr->h_CSize - k ;
	  if ( l > osize ) l = osize ;
	  OutFile = Open( pName , MODE_NEWFILE ) ;
	  if ( ! OutFile ) break ;
	  Res = ReadDataToFile( Archive , OutFile , l ) ;
	  Close( OutFile ) ;
	  if ( ! Res ) break ;

	  if ( pCmp && (! CompareFiles( pName , pCmp , k , l )) )
	  {
	    Ret = DFR_CMPERR ;
	    break ;
	  }
	  DeleteFile( pName ) ;
	}
	if ( k >= pHdr->h_CSize ) Ret = DFR_OK ;
      }
      else if ( ReadFile( pHdr , pName ) ) // normal case
      {
	Ret = DFR_OK ;
	if ( pCmp && (! CompareFiles( pName , pCmp , 0 , pHdr->h_Obj.obj_Size )) ) Ret = DFR_CMPERR ;
      }
      break ;

    case HCT_EXTERNAL :

      if ( ExtDecompFile( pHdr , pName ) )
      {
	Ret = DFR_OK ;
	if ( pCmp && (! CompareFiles( pName , pCmp , 0 , pHdr->h_Obj.obj_Size )) ) Ret = DFR_CMPERR ;
      }
      break ;

    case HCT_XPKLIB :
    case HCT_INTERNAL :

      if ( OutFile = Open( pName , MODE_NEWFILE ) )
      {
	osize = 0 ;

	do
	{
	  inptr  = 0 ;
	  inreal = 0 ;
	  insize = MaxIoSize() ;
	  inleft = pHdr->h_CSize ;
	  InBuf  = GIOBuf ;
	  InFile = NULL ;
	  InSize = pHdr->h_BSize ;
	  OutBuf = NULL ;

	  // extract next block
	  // note: any block of the file may be not compressed
	  if ( pHdr->h_CType == HCT_INTERNAL )
	    Res = decompress() ;
	  else if ( pHdr->h_CType == HCT_XPKLIB )
	    Res = XpkDecompFile( pHdr , pName , OutFile ) ;
	  else
	    Res = ReadDataToFile( Archive , OutFile , InSize ) ;
	  if ( ! Res ) break ;

	  // compare data
	  if ( pCmp )
	  {
	    Close( OutFile ) ;
	    Res = CompareFiles( pName , pCmp , osize , pHdr->h_BSize ) ;
	    OutFile = Open( pName , MODE_NEWFILE ) ;
	    if ( ! OutFile ) break ;
	    if ( ! Res )
	    {
	      Ret = DFR_CMPERR ;
	      break ;
	    }
	    MonitorPrint( MP_POS2 , GetStr( MSG_MONITOR_READING ) , NULL ) ;
	  }

	  // update size read
	  osize += pHdr->h_BSize ;
	  if ( osize >= pHdr->h_Obj.obj_Size ) break ;

	  // find next block
	  Res = ReadNextHeader( Archive , pHdr ) ;
	  if ( ! Res ) break ;
	}
	while ( pHdr->h_Type == HT_SPLIT ) ;

	if ( OutFile ) Close( OutFile ) ;
	if ( Res ) Ret = DFR_OK ;
      }
      else Ret = DFR_READERR ;
      break ;
  }

  /* check result size */

  if ( Ret == DFR_OK && (! pCmp) )
  {
    if ( ! MyExamine( pName ) ) Ret = DFR_READERR ;
    else if ( GFib.fib_Size != pHdr->h_Obj.obj_Size ) Ret = DFR_READERR ;
  }

  /* report error */

  if ( (Ret == DFR_READERR) && (! HasBeenBreaked()) )
  {
    osize = ( pHdr->h_CType == HCT_NONE ) ?  ABERR_READ_ERROR : ABERR_DECOMP_ERROR ;
    HandleError( pHdr->h_Obj.obj_Name , osize ) ;
  }
  return( Ret ) ;
}

/*************************************************************************/

static BOOL IntDecompCyl( BYTE *pSrc , struct ArcUnit *pUnit )

/* Internal cylinder decompression */

{
  // inits to write to buffer
  InFile  = NULL ;
  InBuf   = pSrc ;
  InSize  = pUnit->au_CylSize ;
  OutFile = NULL ;
  OutBuf  = pUnit->au_Buffer ;

  return( decompress() ) ;
}

/*************************************************************************/

BOOL DecompressCyl( struct ArcUnit *pUnit , BYTE *pSrc , LONG CompType )

/* $DOC
 * FUNCTION
 *	Decompresses cylinder data
 * INPUTS
 *	pUnit = pointer to an unit, in which buffer to put the result
 *	pSrc = pointer to the compressed data
 *	CompType = compression algorithme
 * OUTPUTS
 *	Result = success/failure
 * NOTES
 *	The sizeof(LONG) first bytes of the input buffer must contain
 *	the size of the compressed data
 * $END
 */

{
  BOOL Ret ;
  BYTE *pRSrc ;

  // inits to read buffer
  inptr  = 0 ;
  inleft = 0 ;
  insize = pUnit->au_CylSize ;
  memcpy( &inreal , pSrc , sizeof(LONG) ) ;

  /*
   * Call the right compression function
   * NOTE: external compression is not supported in this case
   */

  pRSrc = &pSrc[sizeof(LONG)] ;

  switch ( CompType )
  {
    case HCT_INTERNAL : Ret = IntDecompCyl( pRSrc , pUnit ) ;
			break ;
    case HCT_XPKLIB   : InSize = inreal ;
			Ret = XpkDecompCyl( pRSrc , pUnit ) ;
			break ;
    default	      : Ret = FALSE ;
			break ;
  }

  if ( (! Ret) && (! HasBeenBreaked()) ) HandleError( pUnit->au_Name , ABERR_DECOMP_ERROR ) ;
  return( Ret ) ;
}

