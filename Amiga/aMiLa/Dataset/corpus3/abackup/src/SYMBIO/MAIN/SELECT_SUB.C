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
    select_sub.c

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 02-Nov-93
    Modified: 02-Jul-94
    _______________________________________________________________________
*/

/*************************************************************************/

static BOOL InclObj( struct Object *pObj )

/* Include the given object */

{
  if ( ObjIsNotEmptyDir( pObj ) )
    return( WalkDirTree( pObj , InclObj , IsRecursive() ? WDTF_RECURSIVE|WDTF_DIRBEFORE : NULL ) ) ;

  if ( ObjIsSelected( pObj ) ) return( TRUE ) ;

  SetObjFlag( pObj , OBJF_SELECTED ) ;
  BytesAdded += TD_SECTOR - ( pObj->obj_Size & SIZEMASK ) ;
  BytesSelected += pObj->obj_Size ;
  FilesSelected++ ;

  while ( pObj = pObj->obj_Parent ) pObj->obj_SelChildren++ ;
  return( TRUE ) ;
}

/*************************************************************************/

static BOOL InclMatch( struct Object *pObj )

/* Include object if name matching pattern */

{
  if ( MatchPatternNoCase( Pattern , pObj->obj_Name ) ) InclObj( pObj ) ;
  return( TRUE ) ;
}

/*************************************************************************/

static BOOL InclNoMatch( struct Object *pObj )

/* Include object if name not matching */

{
  if ( ! MatchPatternNoCase( Pattern , pObj->obj_Name ) ) InclObj( pObj ) ;
  return( TRUE ) ;
}

/*************************************************************************/

static BOOL InclAfter( struct Object *pObj )

/* Include object if modified after PDate */

{
  if ( pObj->obj_Date >= PDate ) InclObj( pObj ) ;
  return( TRUE ) ;
}

/*************************************************************************/

static BOOL InclBefore( struct Object *pObj )

/* Include object if modified before PDate */

{
  if ( pObj->obj_Date <= PDate ) InclObj( pObj ) ;
  return( TRUE ) ;
}

/*************************************************************************/

static BOOL InclBits( struct Object *pObj )

/* Include object if bits as wanted */

{
  if ( (pObj->obj_Bits & BitMask) == BitValue ) InclObj( pObj ) ;
  return( TRUE ) ;
}

/*************************************************************************/

static BOOL ExclObj( struct Object *pObj )

/* Exclude the given object */

{
  if ( ObjIsNotEmptyDir( pObj ) )
    return( WalkDirTree( pObj , ExclObj , IsRecursive() ? WDTF_RECURSIVE|WDTF_DIRBEFORE : NULL ) ) ;

  if ( ! ObjIsSelected( pObj ) ) return( TRUE ) ;

  ClearObjFlag( pObj , OBJF_SELECTED ) ;
  BytesAdded -= TD_SECTOR - ( pObj->obj_Size & SIZEMASK ) ;
  BytesSelected -= pObj->obj_Size ;
  FilesSelected-- ;

  while ( pObj = pObj->obj_Parent ) pObj->obj_SelChildren-- ;
  return( TRUE ) ;
}

/*************************************************************************/

static BOOL ExclMatch( struct Object *pObj )

/* Exclude object if name matching */

{
  if ( MatchPatternNoCase( Pattern , pObj->obj_Name ) ) ExclObj( pObj ) ;
  return( TRUE ) ;
}

/*************************************************************************/

static BOOL ExclNoMatch( struct Object *pObj )

/* Exclude object if name not matching */

{
  if ( ! MatchPatternNoCase( Pattern , pObj->obj_Name ) ) ExclObj( pObj ) ;
  return( TRUE ) ;
}

/*************************************************************************/

static BOOL ExclAfter( struct Object *pObj )

/* Exclude object if modified after PDate */

{
  if ( pObj->obj_Date >= PDate ) ExclObj( pObj ) ;
  return( TRUE ) ;
}

/*************************************************************************/

static BOOL ExclBefore( struct Object *pObj )

/* Exclude object if modified before PDate */

{
  if ( pObj->obj_Date <= PDate ) ExclObj( pObj ) ;
  return( TRUE ) ;
}

/*************************************************************************/

static BOOL ExclBits( struct Object *pObj )

/* Exclude object if bits as wanted */

{
  if ( (pObj->obj_Bits & BitMask) == BitValue ) ExclObj( pObj ) ;
  return( TRUE ) ;
}

/*************************************************************************/

static BOOL ReverseSel( struct Object *pObj )

/* Invert selection */

{
  return( (BOOL)(ObjIsSelected( pObj ) ? ExclObj( pObj ) : InclObj( pObj )) ) ;
}

