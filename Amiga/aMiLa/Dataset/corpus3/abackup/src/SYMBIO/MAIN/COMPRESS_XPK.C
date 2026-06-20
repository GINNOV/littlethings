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
    compress_xpk.c

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 10-Sep-93
    Modified: 17-Aug-99
    _______________________________________________________________________
*/

#define LATTICE
#include <xpk/xpk.h>
#include <proto/xpkmaster.h>

/****************************************************************************/

BYTE XpkErrMsg[XPKERRMSGSIZE+1] ;

static struct XpkPackerInfo XpkInfo ;
static struct XpkPackerList XpkList ;

static struct TagItem XGML1Tags[] =
{
  XPK_PackersQuery,(ULONG)&XpkList,
  TAG_DONE,NULL
} ;

static struct TagItem XGML2Tags[] =
{
  XPK_PackMethod,NULL,
  XPK_PackerQuery,(ULONG)&XpkInfo,
  TAG_DONE,NULL
} ;

void XpkGetMethodList( void )

/* $DOC
 * FUNCTION
 *	Builds the list of the available XPK compression methods
 * $END
 */

{
  LONG k, l ;

  if ( ! XpkBase ) return ;

  /* get the list from the library */
  if ( XpkQuery( XGML1Tags ) )
  {
    XpkList.xpl_NumPackers = 0 ;
    return ;
  }

  /* eliminates methods that are not suitable for us */
  for ( k = l = 0 ; k < XpkList.xpl_NumPackers ; k++ )
  {
    XGML2Tags[0].ti_Data = (ULONG)XpkList.xpl_Packer[k] ;
    if ( XpkQuery( XGML2Tags ) ) continue ;

    if ( XpkInfo.xpi_Flags & XPKIF_LOSSY      ) continue ;
    if ( XpkInfo.xpi_Flags & XPKIF_NEEDPASSWD ) continue ;
    if (! (XpkInfo.xpi_Flags & XPKIF_PK_CHUNK)) continue ;
    if (! (XpkInfo.xpi_Flags & XPKIF_UP_CHUNK)) continue ;

    strcpy( XpkList.xpl_Packer[l] , XpkList.xpl_Packer[k] ) ;
    l++ ;
  }

  XpkList.xpl_NumPackers = l ;
}

/****************************************************************************/

static long __saveds __asm XpkChkAbort( register __a1 struct XpkProgress *msg )
{
  return( StopMe() ) ;
}

static struct Hook XCHook = { {0} , XpkChkAbort } ;

/***********************************************************************************/

static struct TagItem XCFTags[] =
{
  XPK_InFH,NULL,
  XPK_InLen,NULL,
  XPK_OutName,NULL,
  XPK_GetOutLen,NULL,
  XPK_PackMethod,NULL,
  XPK_PackMode,NULL,
  XPK_ChunkHook,(ULONG)&XCHook,
  XPK_GetError,(ULONG)XpkErrMsg,
  TAG_DONE,NULL
} ;

static LONG XpkCompFile( BYTE *pSrc , BYTE *pDst , LONG Start )

/* XPK file compression, returns length of result (-1 if error) */

{
  LONG k ;
  BPTR InDesc ;

  if ( ! XpkBase ) return( -1 ) ;

  InDesc = Open( pSrc , MODE_OLDFILE ) ;
  if ( ! InDesc ) return( -1 ) ;
  Seek( InDesc , Start , OFFSET_BEGINNING ) ;

  XCFTags[0].ti_Data = (ULONG)InDesc ;
  XCFTags[1].ti_Data = (ULONG)InSize ;
  XCFTags[2].ti_Data = (ULONG)pDst ;
  XCFTags[3].ti_Data = (ULONG)&OutSize ;
  XCFTags[4].ti_Data = (ULONG)PRF_XPKMETHOD ;
  XCFTags[5].ti_Data = (ULONG)PRF_XPKMODE ;

  k = XpkPack( XCFTags ) ;
  Close( InDesc ) ;
  return( k ? - 1 : OutSize ) ;
}

/****************************************************************************/

static struct TagItem XCCTags[] =
{
  XPK_InBuf,NULL,
  XPK_InLen,NULL,
  XPK_OutBuf,NULL,
  XPK_OutBufLen,NULL,
  XPK_GetOutLen,NULL,
  XPK_PackMethod,NULL,
  XPK_PackMode,NULL,
  XPK_ChunkHook,(ULONG)&XCHook,
  XPK_GetError,(ULONG)XpkErrMsg,
  TAG_DONE,NULL
} ;

static LONG XpkCompCyl( BYTE *pSrc , BYTE *pDst , LONG DstSize )

/* XPK cylinder compression, returns length of result (-1 if error) */

{
  if ( ! XpkBase ) return( -1 ) ;

  XCCTags[0].ti_Data = (ULONG)pSrc ;
  XCCTags[1].ti_Data = (ULONG)InSize ;
  XCCTags[2].ti_Data = (ULONG)pDst ;
  XCCTags[3].ti_Data = (ULONG)DstSize ;
  XCCTags[4].ti_Data = (ULONG)&OutSize ;
  XCCTags[5].ti_Data = (ULONG)PRF_XPKMETHOD ;
  XCCTags[6].ti_Data = (ULONG)PRF_XPKMODE ;

  if ( XpkPack( XCCTags ) ) return( -1 ) ;
  return( OutSize ) ;
}

/***********************************************************************************/

static long __saveds __asm XpkReadArc( register __a1 struct XpkIOMsg *msg )

/* Read hook for XPK decompression */

{
  if ( msg->xiom_Private1 ) /* free previously allocated memory */
  {
    MyFreeMem( (void *)msg->xiom_Private1 ) ;
    msg->xiom_Private1 = NULL ;
  }

  if ( msg->xiom_Type == XIO_FREE ) return( FALSE ) ; /* termination message ? */

  if ( (msg->xiom_Type == XIO_READ) ) /* read asked ? */
  {
    if ( ! msg->xiom_Ptr ) /* no buffer provided, allocate one */
    {
      msg->xiom_Ptr = MyAllocMem( msg->xiom_Size , NULL ) ;
      if ( ! msg->xiom_Ptr ) return( TRUE ) ;
      msg->xiom_Private1 = (ULONG)msg->xiom_Ptr ;
    }

    if ( DecompGetBuf( msg->xiom_Ptr , msg->xiom_Size ) != msg->xiom_Size ) return( TRUE ) ;
    return( FALSE ) ;
  }

  return( FALSE ) ;
}

/***********************************************************************************/

static struct Hook XDFHook = { {0} , XpkReadArc } ;

static struct TagItem XDFTags[] =
{
  XPK_InHook,(ULONG)&XDFHook,
  XPK_OutFH,NULL,
  XPK_InLen,NULL,
  XPK_ChunkHook,(ULONG)&XCHook,
  XPK_GetError,(ULONG)XpkErrMsg,
  TAG_DONE,NULL
} ;

static BOOL XpkDecompFile( struct Header *pHdr , BYTE *pName , BPTR OutDesc )

/* XPK file decompression */

{
  LONG k ;

  if ( ! XpkBase )
  {
    HandleError( XPKNAME , ERROR_OBJECT_NOT_FOUND ) ;
    return( FALSE ) ;
  }

  XDFTags[1].ti_Data = OutDesc ;
  XDFTags[2].ti_Data = pHdr->h_CSize ;

  k = XpkUnpack( XDFTags ) ;

  if ( k < 0 )
  {
    HandleError( pName , k + HERR_XPKERR ) ;
    return( FALSE ) ;
  }

  return( TRUE ) ;
}

/***********************************************************************************/

static struct TagItem XDCTags[] =
{
  XPK_InBuf,NULL,
  XPK_InLen,NULL,
  XPK_OutBuf,NULL,
  XPK_OutBufLen,NULL,
  XPK_ChunkHook,(ULONG)&XCHook,
  XPK_GetError,(ULONG)XpkErrMsg,
} ;

static BOOL XpkDecompCyl( BYTE *pSrc , struct ArcUnit *pUnit )

/* XPK cylinder decompression */

{
  LONG k ;

  if ( ! XpkBase )
  {
    HandleError( XPKNAME , ERROR_OBJECT_NOT_FOUND ) ;
    return( FALSE ) ;
  }

  XDCTags[0].ti_Data = (ULONG)pSrc ;
  XDCTags[1].ti_Data = (ULONG)InSize ;
  XDCTags[2].ti_Data = (ULONG)pUnit->au_Buffer ;
  XDCTags[3].ti_Data = (ULONG)pUnit->au_BufSize ;

  k = XpkUnpack( XDCTags ) ;

  if ( k < 0 )
  {
    HandleError( pUnit->au_Name , k + HERR_XPKERR ) ;
    return( FALSE ) ;
  }

  return( TRUE ) ;
}

