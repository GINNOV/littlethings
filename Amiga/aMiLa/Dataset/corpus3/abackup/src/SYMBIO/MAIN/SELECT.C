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
    select.c

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 02-Nov-93
    Modified: 16-Jan-98
    _______________________________________________________________________
*/

#include "headers.h"

/*************************************************************************/

BOOL RecursionFlag = TRUE ;
LONG BytesSelected, FilesSelected, BytesAdded ;

static BPTR SelDesc = NULL ;
static LONG PDate = -1, BitMask, BitValue ;
static BYTE tmp[MAXSTR+2], SelName[MAXSTR+1], Pattern[MAXSTR+1], ProtBits[] = "hsparwed" ;

static BYTE *STXT_INCLUDE       = "INCLUDE",
	    *STXT_EXCLUDE       = "EXCLUDE",
	    *STXT_REVERSE       = "INVERT",
	    *STXT_CHDIR 	= "CD" ,
	    *STXT_RECURSE       = "RECURS",
	    *STXT_YES   	= "YES",
	    *STXT_NO    	= "NO",
	    *STXT_FUNCNAME[]    = { "NAME" , "DATE" , "BITS" } ,
	    *STXT_FUNCOPTS[]    = {    "==" ,      "!=" ,   "<=" ,    ">=" , "=1" , "=0" } ,
	    *STXT_NEWFUNCOPTS[] = { "MATCH" , "NOMATCH" , "UPTO" , "SINCE" } ;

/*************************************************************************/

static BOOL BitsToMask( BYTE *pStr )

/*
 * Convert a bit specification to mask and value
 *
 * pStr may point either to a list of bits characters (e.g. "hrwd",
 * old format specification) or to a couple of hex numbers (e.g.
 * "0xF0 0x80", new format specification)
 */

{
  BYTE *p ;
  LONG k, b ;

  // get new format specification

  if ( *pStr == '0' )
  {
    BitMask = strtol( pStr , &p , 0 ) & 0x00FF ;
    if ( ! BitMask ) return( FALSE ) ;
    for ( pStr = p ; isspace( *pStr ) ; pStr++ ) ;
    BitValue = strtol( pStr , &p , 0 ) ;
    return( (BOOL)(p != pStr) ) ;
  }

  // get old format specification

  BitMask  = 0 ;
  BitValue = 0x0f ;

  while ( *pStr )
  {
    p = strchr( ProtBits , *pStr ) ;
    if ( ! p ) return( FALSE ) ;
    k = 7 - (LONG) (p - ProtBits) ;
    b = 1 << k ;
    BitMask |= b ;
    if ( k < 4 ) BitValue &= ~b ;
	    else BitValue |=  b ;
    pStr++ ;
  }

  return( TRUE ) ;
}

/*************************************************************************/

static void RecordSel( LONG Action , BYTE *pArg )

/* Record the given selection action into a file */

{
  LONG k, *pBits ;

  switch ( Action )
  {
    case SEL_INCLOBJECT :
    case SEL_EXCLOBJECT : SPrintf( tmp , "%s \"%s\"\n" , (GetType( Action ) == SEL_INCLUDE) ? STXT_INCLUDE : STXT_EXCLUDE , pArg ) ;
			  break ;
    case SEL_REVERSE    : SPrintf( tmp , "%s\n" , STXT_REVERSE ) ;
			  break ;
    case SEL_PARENT     : SPrintf( tmp , "%s /\n" , STXT_CHDIR ) ;
			  break ;
    case SEL_ROOT       : SPrintf( tmp , "%s :\n" , STXT_CHDIR ) ;
			  break ;
    case SEL_ENTERDIR   : SPrintf( tmp , "%s \"%s\"\n" , STXT_CHDIR , pArg ) ;
			  break ;
    case SEL_RECURSE    : SPrintf( tmp , "%s %s\n" , STXT_RECURSE , ( RecursionFlag ) ? STXT_YES : STXT_NO ) ;
			  break ;
    case SEL_INCLBIT    :
    case SEL_EXCLBIT    : pBits = (LONG *)pArg ;
			  SPrintf( tmp , "%s %s \"0x%02lx 0x%02lx\"\n" , GetType( Action ) == SEL_INCLUDE ? STXT_INCLUDE : STXT_EXCLUDE ,
				STXT_FUNCNAME[2] , pBits[0] , pBits[1] ) ;
			  break ;
    default     	: k = GetFunc( Action ) ;
			  SPrintf( tmp , "%s %s \"%s\" %s\n" , (GetType( Action ) == SEL_INCLUDE) ? STXT_INCLUDE : STXT_EXCLUDE ,
				STXT_FUNCNAME[ k >> 1 ] , pArg , STXT_NEWFUNCOPTS[ k ] ) ;
			  break ;
  }

  FPuts( SelDesc , tmp ) ;
}

/*************************************************************************/

#include "Select_sub.c"

static BOOL (*pIncl[SEL_NUMFUNC])( struct Object *pObj ) =
{
  InclMatch, InclNoMatch, InclAfter, InclBefore, InclBits, InclObj
} ;

static BOOL (*pExcl[SEL_NUMFUNC])( struct Object *pObj ) =
{
  ExclMatch, ExclNoMatch, ExclAfter, ExclBefore, ExclBits, ExclObj
} ;

/*************************************************************************/

void DoSelect( struct Object *pObj , LONG Action , BYTE *pArg )

/* $DOC
 * FUNCTION
 *      Execute a selection action on an object
 * INPUTS
 *      pObj = pointer to an object
 *      Action = selection action (SEL_xxxxx)
 *      pArg = action argument :
 *      	object name for  SEL_INCLOBJECT,SEL_EXCLOBJECT,SEL_ENTERDIR
 *      	name/pattern for SEL_INCLMATCH,SEL_INCLNOMATCH,
 *      			 SEL_EXCLMATCH,SEL_EXCLNOMATCH
 *      	date/time for    SEL_INCLAFTER,SEL_INCLBEFORE,
 *      			 SEL_EXCLAFTER,SEL_EXCLBEFORE
 *      	mask/value for   SEL_INCLBIT,SEL_EXCLBIT
 * NOTES
 *      If selection recording is enabled, the action is recorded in the
 *      current selection file.
 *      SEL_PARENT, SEL_ROOT and SEL_ENTERDIR are "do nothing" actions
 *      which are only recorded.
 * $END
 */

{
  LONG Flags, *pBits ;

  /* prepare action arguments */

  switch ( Action )
  {
    case SEL_INCLOBJECT :
    case SEL_EXCLOBJECT :
    case SEL_ENTERDIR   :

	pArg = pObj->obj_Name ;
	break ;

    case SEL_INCLMATCH   :
    case SEL_INCLNOMATCH :
    case SEL_EXCLMATCH   :
    case SEL_EXCLNOMATCH :

	if ( ! *pArg ) return ;
	strupr( pArg ) ;
	if ( ParsePattern( pArg , Pattern , sizeof(Pattern) ) == -1 )
	{
	  HandleError( pArg , ABERR_BAD_PATTERN ) ;
	  return ;
	}
	break ;

    case SEL_INCLAFTER  :
    case SEL_INCLBEFORE :
    case SEL_EXCLAFTER  :
    case SEL_EXCLBEFORE :

	if ( ! *pArg ) return ;
	PDate = PackedDateFromStr( pArg , (GetFunc( Action ) == SEL_AFTER) ? SECS_PER_DAY - 1 : 0 ) ;
	if ( PDate == -1 )
	{
	  HandleError( pArg , ABERR_BAD_DATE ) ;
	  return ;
	}
	break ;

    case SEL_INCLBIT :
    case SEL_EXCLBIT :

	pBits    = (LONG *)pArg ;
	BitMask  = pBits[0] ;
	BitValue = pBits[1] ;
	BitValue &= BitMask ;
	break ;
  }

  /* prepare flags for WalkDirTree() */

  Flags = WDTF_DIRBEFORE ;
  if ( IsRecursive() ) Flags |= WDTF_RECURSIVE ;
  if ( GetFunc( Action ) != SEL_OBJECT ) Flags |= WDTF_EMPTYDIRS ;

  /* execute action */

  switch ( GetType( Action ) )
  {
    case SEL_INCLUDE : if ( Action == SEL_INCLOBJECT ) InclObj( pObj ) ;
		       else WalkDirTree( pObj , pIncl[ GetFunc(Action) ] , Flags ) ;
		       break ;
    case SEL_EXCLUDE : if ( Action == SEL_EXCLOBJECT ) ExclObj( pObj ) ;
		       else WalkDirTree( pObj , pExcl[ GetFunc(Action) ] , Flags ) ;
		       break ;
    case SEL_OTHER   : if ( Action == SEL_REVERSE ) WalkDirTree( pObj , ReverseSel , Flags ) ;
		       else if ( Action == SEL_RECURSE ) RecursionFlag = ! RecursionFlag ;
		       break ;
  }

  if ( NewID == WIN_SELECTION )
  {
    SetNM2TX( GD_Files , FilesSelected , TFiles ) ;
    SetNM3TX( GD_Size  , BytesSelected , TBytes ) ;
    SetGad( GD_Bytes , GTTX_Text, (ULONG)GetStr( GetByteID( BytesSelected ) ) ) ;
  }

  /* record action */

  if ( IsRecording() ) RecordSel( Action , pArg ) ;
}

/*************************************************************************/

void AbortSelect( void )

/* $DOC
 * FUNCTION
 *      Abort selection recording
 * SEE ALSO
 *      SaveSelect(), RecordSelect()
 * $END
 */

{
  if ( SelDesc )
  {
    Close( SelDesc ) ;
    DeleteFile( SelName ) ;
  }
  SelDesc = NULL ;
}

/*************************************************************************/

BOOL RecordSelect( BYTE *pName )

/* $DOC
 * FUNCTION
 *      Start selection recording.
 * INPUTS
 *      pName = selection file's name
 * OUTPUTS
 *      Result = success/failure
 * NOTES
 *      The current state of the recursion flag is written into the file.
 * SEE ALSO
 *      SaveSelect(), AbortSelect()
 * $END
 */

{
  strcpy( SelName , pName ) ;
  SelDesc = Open( SelName , MODE_NEWFILE ) ;
  if ( ! SelDesc ) return( FALSE ) ;

  RecordSel( SEL_RECURSE , NULL ) ;
  return( TRUE ) ;
}

/*************************************************************************/

void SaveSelect( void )

/* $DOC
 * FUNCTION
 *      End of selection recording
 * SEE ALSO
 *      RecordSelect(), AbortSelect()
 * $END
 */

{
  if ( SelDesc ) Close( SelDesc ) ;
  SelDesc = NULL ;
}

/*************************************************************************/

static BYTE *SelGetString( BYTE *pStr )

/*
 * Extract a quoted string starting at pStr and copy it into tmp[]
 * (quotes are not copied)
 * Returns a pointer to the character following the closing quote
 * (spaces are skiped)
 */

{
  BYTE *pName ;

  pStr++ ;
  for ( pName = pStr ; *pStr && (*pStr != '\"') ; pStr++ ) ;
  if ( *pStr ) *pStr++ = '\0' ;
  strcpy( tmp , pName ) ;

  while ( isspace( *pStr ) ) pStr++ ;
  return( pStr ) ;
}

/*************************************************************************/

static struct Object *SelGetObject( struct Object *pRoot , BYTE *pStr )

/* Extract an object name from pStr and search it into pRoot children */

{
  SelGetString( pStr ) ;
  if (! strcmp( pRoot->obj_Name , tmp )) return( pRoot ) ;
  return( FindObjectByName( pRoot , tmp ) ) ;
}

/*************************************************************************/

struct Object *PlaySelect( struct Object *pRoot , BYTE *pName )

/* $DOC
 * FUNCTION
 *      Load and execute a selection file
 * INPUTS
 *      pRoot = current directory
 *      pName = selection file's name
 * OUTPUTS
 *      Result = current directory if success, NULL if failed
 * NOTES
 *      The new version of selection recording doesn't output "INCLUDE ALL" or
 *      "EXCLUDE ALL" actions. For compatibility with previous versions, these
 *      actions are still accepted, and implemented with a SEL_INCLOBJECT or
 *      SEL_EXCLUDEOBJECT action on the current directory
 *      Via the BitsToMask() function, both the new and the old format for
 *      "INCLUDE BITS" and "EXCLUDE BITS" commands is supported
 * $END
 */

{
  BPTR Desc ;
  BYTE *p, *q ;
  struct Object *pObj ;
  LONG Action, Line, k, *l ;

  Desc = Open( pName , MODE_OLDFILE ) ;
  if ( ! Desc ) return( NULL ) ;

  for ( Line = 1 ; FGets( Desc , tmp , MAXSTR ) ; Line++ )
  {
    if ( p = strchr( tmp , '\n' ) ) *p = '\0' ;

    // ignore comments or empty lines
    for ( p = tmp ; isspace( *p ) ; p++ ) ;
    if ( (! *p) || (*p == ';') ) continue ;

    // get command name
    for ( q = p ; *p && (! isspace( *p )) ; p++ ) ;
    if ( *p ) *p++ = '\0' ;
    while ( isspace( *p ) ) p++ ;

    // execute "CD"
    if ( ! stricmp( q , STXT_CHDIR ) )
    {
      if ( *p == ':' ) while ( pRoot->obj_Parent ) pRoot = pRoot->obj_Parent ;
      else if ( *p == '/' )
      {
	if ( pRoot->obj_Parent ) pRoot = pRoot->obj_Parent ;
      }
      else if ( *p == '\"' )
      {
	pRoot = SelGetObject( pRoot , p ) ;
	if ( ! pRoot )
	{
	  HandleError( tmp , ABERR_CANNOT_OPEN ) ;
	  break ;
	}
      }
      else goto _failed ;
      continue ;
    }

    // execute "RECURS"
    if ( ! stricmp( q , STXT_RECURSE ) )
    {
      if ( ! stricmp( p , STXT_YES ) ) RecursionFlag = TRUE ;
      else if ( ! stricmp( p , STXT_NO ) ) RecursionFlag = FALSE ;
      else goto _failed ;
      continue ;
    }

    // check other commands
    pObj = pRoot ;
    if ( ! stricmp( q , STXT_REVERSE ) ) Action = SEL_REVERSE ;
    else if ( ! stricmp( q , STXT_INCLUDE ) ) Action = SEL_INCLUDE ;
    else if ( ! stricmp( q , STXT_EXCLUDE ) ) Action = SEL_EXCLUDE ;
    else goto _failed ;

    // get INCLUDE/EXCLUDE arguments
    if ( Action != SEL_REVERSE )
    {
      if ( *p == '\"' )
      {
	pObj = SelGetObject( pRoot , p ) ;
	if ( ! pObj )
	{
	  HandleError( tmp , ABERR_CANNOT_OPEN ) ;
	  pRoot = NULL ;
	  break ;
	}
	Action |= SEL_OBJECT ;
      }
      else if ( ! strnicmp( p , STXT_FUNCNAME[0] , 4 ) ) Action |= SEL_MATCH ;
      else if ( ! strnicmp( p , STXT_FUNCNAME[1] , 4 ) ) Action |= SEL_BEFORE ;
      else if ( ! strnicmp( p , STXT_FUNCNAME[2] , 4 ) ) Action |= SEL_BIT ;
      else if ( ! stricmp( p , "ALL" ) ) Action |= SEL_OBJECT ;
      else goto _failed ;

      k = GetFunc( Action ) ;
      if ( k != SEL_OBJECT )
      {
	// get command argument

	if ( p = strchr( p , ' ' ) )
	{
	  while ( isspace( *p ) ) p++ ;
	  p = ( *p == '\"' ) ? SelGetString( p ) : NULL ;
	}
	if ( ! p ) goto _failed ;

	if ( k == SEL_BIT )
	{
	  // parse bit specification
	  if ( ! BitsToMask( tmp ) ) goto _failed ;

	  // no option if new bit specification
	  if ( *tmp == '0' ) p = STXT_FUNCOPTS[k] ;
	  else // get option (old format) to know what we want to test
	  {
	    if ( ! strcmp( p , STXT_FUNCOPTS[k+1] ) ) BitValue = ~BitValue ;
	    else if ( strcmp( p , STXT_FUNCOPTS[k] ) ) goto _failed ;
	  }

	  // store values in tmp[]
	  l = (LONG *)tmp ;
	  l[0] = BitMask ;
	  l[1] = BitValue ;
	}
	else    	// check command option
	{
	  if ( ! strcmp( p , STXT_FUNCOPTS[k+1] ) ) Action++ ;
	  else if ( ! strcmp( p , STXT_NEWFUNCOPTS[k+1] ) ) Action++ ;
	  else if ( ! strcmp( p , STXT_NEWFUNCOPTS[k] ) ) ;
	  else if ( strcmp( p , STXT_FUNCOPTS[k] ) ) goto _failed ;
	}
      }
    }

    // execute action
    DoSelect( pObj , Action , tmp ) ;
  }

  Close( Desc ) ;
  return( pRoot ) ;

_failed:

  SPrintf( tmp , GetStr( MSG_ERROR_SYNTAX ) , pName , Line ) ;
  HandleError( tmp , ABERR_SYNTAX_ERROR ) ;
  Close( Desc ) ;
  return( NULL ) ;
}

