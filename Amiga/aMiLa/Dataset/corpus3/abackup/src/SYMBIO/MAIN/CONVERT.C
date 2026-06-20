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
    convert.c

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 23-Sep-93
    Modified: 26-Feb-95
    _______________________________________________________________________
*/

#include "headers.h"

/*************************************************************************/

struct Object *ConvertObject( struct OldObject *pOld , struct Object *pNew )

/* $DOC
 * FUNCTION
 *	Converts an old Object structure into a new one
 * INPUTS
 *	pOld = pointer to the old structure to convert
 *	pNew = pointer to the new structure to initialize
 *	       (if NULL a new structure is allocated)
 * OUTPUTS
 *	Result = pointer to the new structure, or NULL if failed
 * $END
 */

{
  static BYTE tmp[MINSTR+1] ;

  strcpy( tmp , pOld->o_name ) ;
  if ( pOld->o_flags & OBJF_DEVICE ) strcat( tmp , ":" ) ;

  if ( ! pNew )
  {
    pNew = AllocObject( ABO_OBJECT , tmp ) ;
    if ( ! pNew ) return( NULL ) ;
  }
  else strcpy( pNew->obj_Name , tmp ) ;

  pNew->obj_Flags    = pOld->o_flags ;
  pNew->obj_Size     = pOld->o_size ;
  pNew->obj_Bits     = (UWORD)pOld->o_bits ;
  pNew->obj_Date     = PackDate( &(pOld->o_date) ) ;
  pNew->obj_UserData = (UWORD)pOld->o_suiv ;

  CleanObj( pNew ) ;
  return( pNew ) ;
}

/*************************************************************************/

struct Object *OldCatalToObj( struct OldCatalog *pCat )

/* $DOC
 * FUNCTION
 *	Convert an OldCatalog structure to an Object structure.
 * INPUTS
 *	pCat = pointer to the OldCatalog structure
 * OUTPUTS
 *	pObj = pointer to the Object structure
 * $END
 */

{
  BYTE *p ;
  struct Object *pObj ;
  static BYTE tmp[MINSTR+1] ;

  if ( pCat->c_obj.o_flags & OBJF_DEVICE )
  {
    strcpy( tmp , pCat->c_obj.o_name ) ;
    strcat( tmp , ":" ) ;
    p = tmp ;
  }
  else p = pCat->c_name ;

  pObj = AllocObject( ABO_OBJECT , p ) ;
  if ( ! pObj ) return( NULL ) ;

  ConvertObject( &(pCat->c_obj) , pObj ) ;
  strcpy( pObj->obj_Name , p ) ;
  pObj->obj_Disk   = pCat->c_disk ;
  pObj->obj_Offset = RoundToSector( pCat->c_offset ) ;

  return( pObj ) ;
}

/*************************************************************************/

struct DeviceDef *ConvertDeviceDef( struct OldDeviceDef *pOld , struct DeviceDef *pNew )

/* $DOC
 * FUNCTION
 *	Converts an old DeviceDef structure into a new one
 * INPUTS
 *	pOld = pointer to the old structure to convert
 *	pNew = pointer the new structure to initialize
 *	       (if NULL, a new structure is allocated)
 * OUTPUTS
 *	Result = success/failure
 * $END
 */

{
  if ( pNew )
  {
    memset( pNew , '\0' , sizeof(struct DeviceDef) ) ;
    strcpy( pNew->dd_Name , pOld->d_name ) ;
  }
  else
  {
    pNew = AllocObject( ABO_DEVICEDEF , pOld->d_name ) ;
    if ( ! pNew ) return( NULL ) ;
  }

  memcpy( &(pNew->dd_Env) , &(pOld->d_env) , sizeof(struct DosEnvec) ) ;
  pNew->dd_Unit  = pOld->d_unit ;
  pNew->dd_Flags = pOld->d_openf ;

  return( pNew ) ;
}

/*************************************************************************/

BOOL ConvertHeader( struct OldHeader *pOld , struct Header *pNew )

/* $DOC
 * FUNCTION
 *	Converts an old Header structure into a new one
 * INPUTS
 *	pOld = pointer to the old structure to convert
 *	pNew = pointer the new structure to initialize
 * OUTPUTS
 *	Result = success/failure
 * $END
 */

{
  BYTE *p ;
  struct Object *pObj ;

  memset( pNew , '\0' , sizeof(struct Header) ) ;

  pNew->h_Idnt1    = H_IDNT ;
  pNew->h_Type	   = pOld->th_type ;
  pNew->h_Idnt2    = H_IDNT ;
  if ( pNew->h_Type & HT_CRYPT ) pNew->h_CryptSum = pOld->th_crypt ;
  pNew->h_BDate    = IdntDate ;
  pNew->h_CatalOfs = pOld->th_catalog ;
  if ( pNew->h_CatalOfs != -1 ) pNew->h_CatalOfs <<= TD_SECSHIFT ;

  pObj = &(pNew->h_Obj) ;
  ConvertObject( &(pOld->th_obj) , pObj ) ;

  if ( ! ObjIsDevice( pObj ) )
  {
    p = FilePart( pOld->th_fname ) ;
    if ( p[-1] == '/' ) p-- ;
    *p = '\0' ;
    strcpy( pNew->h_Parent , FilePart( pOld->th_fname ) ) ;
    strcpy( pNew->h_Comment , pOld->th_comment ) ;
  }
  else ConvertDeviceDef( (struct OldDeviceDef *)pOld->th_fname , &(pNew->h_DeviceDef) ) ;

  pNew->h_CType   = pOld->th_ctype ;
  pNew->h_CSize   = pOld->th_ssize ;
  pNew->h_BSize   = pNew->h_Obj.obj_Size ;
  pNew->h_Version = pOld->th_version ;

  return( TRUE ) ;
}

