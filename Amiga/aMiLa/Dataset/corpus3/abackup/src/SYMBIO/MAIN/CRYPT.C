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
    crypt.c

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 12-Oct-93
    Modified: 06-Apr-95
    _______________________________________________________________________
*/

#include "headers.h"

LONG CryptLen = 0 ;		// password length
LONG CryptSum = -1 ;		// password checksum
BYTE CryptKey[MINSTR+1] ;	// encryption/uncryption password

/****************************************************************************/

LONG GetPassword( void )

/* $DOC
 * FUNCTION
 *	Asks the password required for encryption/uncryption
 * OUTPUTS
 *	Result = success/failure
 * $END
 */

{
  LONG k ;

  // asks for the password

  *CryptKey = '\0' ;
  if ( FULLBATCHMODE ||
       (StringRequest( CryptKey, MINSTR, GetStr( MSG_REQ_PASSWORD ), "", MSG_REQ_OK_CANCEL ) != TRUE) ||
       (! *CryptKey) )
    return( FALSE ) ;

  // compute password checksum

  CryptSum = 0 ;
  for ( k = 0 ; CryptKey[k] ; k++ ) CryptSum += k * (ULONG)CryptKey[k] ;
  CryptLen = k ;
  return( TRUE ) ;
}

/****************************************************************************/

static BOOL GetUncryptKey( LONG Sum )

/* Asks and check password for data uncryption */

{
  while ( ! CryptLen )
  {
    if ( ! GetPassword() ) return( FALSE ) ;
    if ( CryptSum == Sum ) break ;
    HandleError( CryptKey , ABERR_WRONG_PASSWORD ) ;
    CryptLen = 0 ;
  }

  return( TRUE ) ;
}

/****************************************************************************/

void UncryptData( UBYTE *pSrc , LONG Len )

/* $DOC
 * FUNCTION
 *	Uncrypt a data block
 * INPUTS
 *	pSrc = pointer to the data block
 *	Len = number of bytes to uncrypt
 * NOTES
 *	Although this function is named UncryptData(), it is also used by
 *	EncryptData() for data encryption (the algorithm is reversible).
 * $END
 */

{
  LONG l ;
  UBYTE s, p, *pPswd ;

  while ( Len > 0 )
  {
    l = MIN( Len , CryptLen ) ;
    for ( pPswd = CryptKey ; l > 0 ; l-- , Len-- )
    {
      p = *pPswd++ ;
      if ( (s = *pSrc) && ( s != p) ) s ^= p ;
      *pSrc++ = s ;
    }
  }
}

/****************************************************************************/

void EncryptData( UBYTE *pData , LONG Len )

/* $DOC
 * FUNCTION
 *	Encrypts a data block
 * INPUTS
 *	pData = pointer to the data block
 *	Len = number of bytes to encrypt
 * $END
 */

{
  struct Header *pHdr ;

  /*
   * If data block is a header :
   * - set the HT_CRYPT flag
   * - store the encryption checksum
   * - skip the 4 first long words
   */

  pHdr = (struct Header *)pData ;
  if ( IsNewHeader( pHdr ) )
  {
    pHdr->h_Type |= HT_CRYPT ;
    pHdr->h_CryptSum = CryptSum ;
    pData += offsetof(struct Header,h_BDate) ;
    Len -= offsetof(struct Header,h_BDate) ;
  }

  // encrypt data
  UncryptData( pData , Len ) ;
}

/****************************************************************************/

BOOL UncryptNewHeader( struct Header *pHdr )

/* $DOC
 * FUNCTION
 *	Uncrypt a header in the new archive format
 * INPUTS
 *	pHdr = pointer to the header
 * OUTPUTS
 *	Result = success/failure
 * $END
 */

{
  if ( ! GetUncryptKey( pHdr->h_CryptSum ) ) return( FALSE ) ;
  UncryptData( (UBYTE *)&(pHdr->h_BDate) , TD_SECTOR - offsetof(struct Header,h_BDate) ) ;
  return( TRUE ) ;
}

