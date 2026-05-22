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
    objects.c

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 04-Aug-93
    Modified: 17-Aug-99
    _______________________________________________________________________
*/

#include "headers.h"
#include <xpk/xpk.h>

/*************************************************************************/

BOOL FreeObject( void *pAObj )

/* $DOC
 * FUNCTION
 *	Frees an object allocated by AllocObject()
 * INPUTS
 *	pAObj = pointer to the object to free
 * OUTPUTS
 *	Returns always TRUE, so may be called by WalkDirTree()
 * $END
 */

{
  LONG *pRealObj ;
  struct Object *pObj ;
  struct DeviceDef *pDef ;

  if ( ! pAObj ) return( TRUE ) ;

  /* retrieve object type */
  pRealObj = (LONG *)pAObj ;
  pRealObj -= 1 ;

  /* special case depending on object type */
  if ( *pRealObj == ABO_OBJECT )
  {
    pObj = (struct Object *)pAObj ;
    if ( ObjIsDevice( pObj ) )
      if ( pDef = GetDeviceDef( pObj ) ) FreeObject( pDef ) ;
  }

  /* free object */
  MyFreeMem( pRealObj ) ;
  return( TRUE ) ;
}

/*************************************************************************/

static void *DoAllocObject( LONG Type , size_t Size , LONG MFlags )

/*
 * Low-level allocator for AllocObject()
 * Type   = object type
 * Size   = size of memory required
 * MFlags = flags for MyAllocMem()
 */

{
  LONG *pObj ;

  /* add one long to size (to store object type) */
  Size += sizeof( LONG ) ;

  /* allocate object */
  pObj = MyAllocMem( Size , MFlags ) ;
  if ( ! pObj ) return( NULL ) ;

  /* store object type and returns */
  *pObj++ = Type ;
  return( pObj ) ;
}

/*************************************************************************/

void *AllocObject( LONG Type , void *pData )

/* $DOC
 * FUNCTION
 *	Allocates an object
 * INPUTS
 *	Type = object type (see Objects.h)
 *	pData = pointer to extra data needed for allocation
 * OUTPUTS
 *	Result = pointer to the new object, or NULL if failed
 * SEE ALSO
 *	FreeObject()
 * $END
 */

{
  size_t Len ;
  ULONG  MFlags ;
  struct Object *pObj ;
  struct Header *pHdr ;
  struct ArcUnit *pUnit ;
  struct DeviceDef *pDef ;

  switch ( Type )
  {
    case ABO_OBJECT :		 // Something to store a dir/file/link/device

      Len = strlen( pData ) ;
      if ( pObj = DoAllocObject( Type , sizeof(struct Object)+Len , NULL ) )
      {
	NoChildren( pObj ) ;
	strcpy( pObj->obj_Name , pData ) ;
      }
      return( pObj ) ;

    case ABO_PREFERENCE :	// A struct to store preferences/config settings

      return( DoAllocObject( Type , sizeof(ABPREFS) , NULL ) ) ;

    case ABO_DEVICEDEF :	// Extra info for devices

      if ( pDef = DoAllocObject( Type , sizeof(struct DeviceDef)+127 , NULL ) )
      {
	pDef->dd_Node.ln_Name = pDef->dd_Name ;
	strcpy( pDef->dd_Name , pData ) ;
      }
      return( pDef ) ;

    case ABO_ARCUNIT :		// An archive unit

      if ( pUnit = DoAllocObject( Type , sizeof(struct ArcUnit) , NULL ) )
      {
	pUnit->au_Node.ln_Name = pUnit->au_Name ;
	strcpy( pUnit->au_Name , pData ) ;
	pUnit->au_FDesc   = -1 ;
	pUnit->au_CurDisk = -1 ;
	pUnit->au_CurCyl  = -1 ;
      }
      return( pUnit ) ;

    case ABO_HEADER :		// An object header
    case ABO_BADCYLMAP :	// A bad cylinder map

      if ( pHdr = DoAllocObject( Type , TD_SECTOR , NULL ) )
      {
	pHdr->h_Idnt1	 = H_IDNT ;
	pHdr->h_Idnt2	 = H_IDNT ;
	pHdr->h_Version  = HVER_CURRENT ;
	pHdr->h_CatalOfs = -1 ;
	if ( Type == ABO_BADCYLMAP ) pHdr->h_Type = HT_BADCYL ;
      }
      return( pHdr ) ;

    case ABO_DEVBUFFER :	// A buffer for a device

      MFlags = NULL ;
      pUnit  = (struct ArcUnit *)pData ;
      pDef   = pUnit->au_DeviceDef ;
      if ( (! pDef) || (pDef->dd_Env.de_BufMemType & BMT_CHIP) ) MFlags |= MEMF_CHIP ;
      pUnit->au_BufSize = pUnit->au_CylSize + (pUnit->au_CylSize / 32) + (2 * XPK_MARGIN) ;
      return( DoAllocObject( Type , (size_t)pUnit->au_BufSize , MFlags ) ) ;
  }

  return( NULL ) ;
}

