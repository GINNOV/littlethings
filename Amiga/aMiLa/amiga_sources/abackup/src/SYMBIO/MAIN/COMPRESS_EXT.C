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
    compress_ext.c

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 11-Sep-93
    Modified: 23-Sep-95
    _______________________________________________________________________
*/

#define LOGNAME 	"T:ABackup.log"

static BYTE *ExtArgs[6] ;
static BYTE ExtCmd[MAXSTR+1], ExtArg1[MAXSTR+1], ExtArg2[MAXSTR+1] ;

/****************************************************************************/

static void BuildStrings( BYTE *pName , BYTE *pStr , LONG idx )

/* Build strings array to replace "%x" specifications */

{
  BYTE *p ;

  ExtArgs[idx++] = pName ;			// 1st element: full pathname
  strcpy( pStr , pName ) ;
  if ( p = FilePart( pStr ) ) *p = '\0' ;
  ExtArgs[idx++] = pStr ;			// 2nd element: pathname only
  ExtArgs[idx] = FilePart( ExtArgs[idx-2] ) ;   // 3rd element: basename only
}

/****************************************************************************/

static BOOL RunExtPrg( BYTE *pPrg , BYTE *pSrc , BYTE *pDst )

/*
 * Run an external program, using "pPrg" as command specification, "pSrc"
 * and "pDst" as source and destination files
 */

{
  BOOL f ;
  BPTR Desc ;
  LONG k, l ;

  // fills the ExtArgs[] array with file names
  BuildStrings( pSrc , ExtArg1 , 0 ) ;
  BuildStrings( pDst , ExtArg2 , 3 ) ;

  // build the command string to execute
  f = FALSE ;
  ExtCmd[0] = '\0' ;
  for ( k = 0 ; *pPrg ; pPrg++ )
  {
    if ( isspace( *pPrg ) && f )
    {
      ExtCmd[k++] = '"' ;
      f = FALSE ;
    }

    if ( *pPrg != '%' )                         // normal character: copy it and continue
    {
      ExtCmd[k++] = *pPrg ;
      continue ;
    }

    pPrg++ ;					// else parse '%x' specification
    if ( *pPrg == 's' ) *pPrg = '0' ;
    else if ( *pPrg == 'd' ) *pPrg = '3' ;

    l = *pPrg - '0' ;
    if ( (l < 0) || (l > 5) ) continue ;        // ignore bad '%x' specifications

    // quote the arguement string to allow spaces in file names
    ExtCmd[k++] = '"' ;
    strcpy( &ExtCmd[k] , ExtArgs[l] ) ;
    k += strlen( ExtArgs[l] ) ;
    f = TRUE ;
  }

  if ( f ) ExtCmd[k++] = '"' ;
  ExtCmd[k++] = '\n' ;
  ExtCmd[k]   = '\0' ;

  // opens the log file
  Desc = Open( LOGNAME , MODE_NEWFILE ) ;
  if ( ! Desc ) return( FALSE ) ;
  Write( Desc , ExtCmd , strlen(ExtCmd) ) ;

  // execute the command
  k = Execute( ExtCmd , NULL , Desc ) ;
  Close( Desc ) ;

  if ( k != DOSTRUE ) HandleError( ExtCmd , HERR_IOERR ) ;
  return( (BOOL)(k == DOSTRUE) ) ;
}

