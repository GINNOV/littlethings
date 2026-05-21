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
    rebuild.c

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 16-Oct-93
    Modified: 02-Dec-95
    _______________________________________________________________________
*/

#include "headers.h"

#define UNKNOWN_DIR	"Unknown"

static LONG DirCount ;
static BYTE tmp[MAXSTR+1], RName[MAXSTR+1] ;

/*************************************************************************/

static struct Object *MakeNewObject( struct Header *pHdr )

/* Make an allocated copy of the given object */

{
  struct DeviceDef *pDef ;
  struct Object *pNew, *pObj ;

  pObj = &(pHdr->h_Obj) ;
  pNew = AllocObject( ABO_OBJECT , pObj->obj_Name ) ;
  if ( ! pNew ) return( NULL ) ;

  memcpy( pNew , pObj , sizeof(struct Object) ) ;
  CleanObj( pNew ) ;
  SetObjFlag( pNew , OBJF_SAVED ) ;

  if ( ObjIsDevice( pNew ) )
  {
    pDef = AllocObject( ABO_DEVICEDEF , pHdr->h_DeviceDef.dd_Name ) ;
    if ( ! pDef )
    {
      FreeObject( pNew ) ;
      return( NULL ) ;
    }
    memcpy( pDef , &(pHdr->h_DeviceDef) , sizeof(struct DeviceDef) ) ;
    AddDeviceDef( pNew , pDef ) ;
  }

  return( pNew ) ;
}

/*************************************************************************/

static struct Object *MakeNewDir( BYTE *pName , LONG Level )

/*
 * Create a new directory object
 * If pName is NULL, UNKNOWN_DIR is used for the name of this dir
 */

{
  struct Object *pObj ;

  if ( ! pName )
  {
    SPrintf( tmp , "%s%ld" , UNKNOWN_DIR , ++DirCount ) ;
    pName = tmp ;
  }

  pObj = AllocObject( ABO_OBJECT , pName ) ;
  if ( ! pObj ) return( NULL ) ;

  pObj->obj_Date = StartDate ;
  pObj->obj_Bits = FIBF_EXECUTE ;
  pObj->obj_UserData = Level ;
  SetObjFlag( pObj , (OBJF_DIRECTORY|OBJF_SAVED) ) ;
  return( pObj ) ;
}

/*************************************************************************/

static struct Object *PushDownTree( BYTE *pName , struct Object *pRoot )

/*
 * Push down directory tree, by creating a new root object and adding
 * the old root (pointed to by pRoot) as the firt child
 * Return a pointer to the new root, or NULL if failed
 */

{
  struct Object *pObj ;

  pObj = MakeNewDir( pName , pRoot->obj_UserData - 1 ) ;
  if ( pObj ) AddChild( pObj , pRoot ) ;
  return( pObj ) ;
}

/*************************************************************************/

static void GetObjPosition( struct Object *pObj )

/* Sets the obj_Disk and obj_Offset fields of the given object */

{
  struct ArcUnit *pUnit ;

  pUnit = FindCurUnit( Archive ) ;
  pObj->obj_Disk   = pUnit->au_CurDisk ;
  pObj->obj_Offset = pUnit->au_CurPos - sizeof(struct OldHeader) ;
}

/*************************************************************************/

static BOOL BadHeaderType( LONG Type )

/* Check if header type is correct for RebuildOld() */

{
  if ( Type == HT_DIR   ) return( FALSE ) ;
  if ( Type == HT_FILE  ) return( FALSE ) ;
  if ( Type == HT_HLINK ) return( FALSE ) ;
  if ( Type == HT_SLINK ) return( FALSE ) ;
  if ( Type == HT_NDOS  ) return( FALSE ) ;
  return( TRUE ) ;
}

/*************************************************************************/

static struct Object *RebuildOld( void )

/*
 * Rebuild the catalog of an archive in the old format
 * Returns a pointer to the root object, or NULL if failed
 */

{
  BYTE *p ;
  struct Object *pObj, *pParent, *pRoot, *pNew ;

  /* Get first header */

  while ( BadHeaderType( pGHdr->h_Type ) )
    if ( ! ReadNextHeader( Archive , pGHdr ) ) return( NULL ) ;
  if ( pGHdr->h_Type == HT_END ) return( NULL ) ;

  /* Old versions could only backup a single partition */

  if ( pGHdr->h_Type == HT_NDOS )
  {
    pRoot = AllocObject( ABO_OBJECT , "" ) ;
    if ( ! pRoot ) return( NULL ) ;
    SetObjFlag( pRoot , OBJF_MULTIVOL ) ;

    if ( pNew = MakeNewObject( pGHdr ) )
    {
      AddChild( pRoot , pNew ) ;
      pNew->obj_Disk = 1 ;
      return( pRoot ) ;
    }

    FreeObject( pRoot ) ;
    return( NULL ) ;
  }

  /* Create root object */

  strcpy( RName , OldHdr.th_fname ) ;
  p = strchr( RName , ':' ) ;
  if ( p ) p[1] = '\0' ;
  pRoot = MakeNewDir( RName , 0 ) ;
  if ( ! pRoot ) return( NULL ) ;

  /*
   * Read loop :
   * pNew    = new object to insert
   * pRoot   = pointer to root object
   * pParent = pointer to parent object
   */

  do
  {
    if ( pGHdr->h_Type == HT_END ) break ;
    if ( BadHeaderType( pGHdr->h_Type ) ) continue ;

    pNew = MakeNewObject( pGHdr ) ;
    if ( ! pNew ) break ;
    GetObjPosition( pNew ) ;

    /*
     * Check root name:
     * If not the same as RName, it's a multi-partition backup so:
     * If OBJF_MULTIVOL is not set on root, push down tree
     * Then add a new child dir (if it doesn't exists)
     */

    strcpy( tmp , OldHdr.th_fname ) ;
    p = strchr( tmp , ':' ) ;
    if ( p ) p[1] = '\0' ;

    if ( stricmp( tmp , RName ) )
    {
      if (! ObjIsMultiVol( pRoot ))
      {
	pRoot = PushDownTree( "" , pRoot ) ;
	if ( ! pRoot )
	{
	  FreeObject( pNew ) ;
	  break ;
	}
	SetObjFlag( pRoot , OBJF_MULTIVOL ) ;
	*RName = '\0' ;
      }

      pObj = FindObjectByName( pRoot , tmp ) ;
      if ( ! pObj )
      {
	pObj = MakeNewDir( tmp , 1 ) ;
	if ( ! pObj )
	{
	  FreeObject( pNew ) ;
	  break ;
	}
	AddChild( pRoot , pObj ) ;
      }
    }

    /*
     * Add new object in tree:
     * - find parent object
     * - extract path into tmp[]
     * - build path if it doesn't exist
     * - add the child to the good parent dir
     */

    pParent = FindObjectByName( pRoot , tmp ) ;
    if ( ! pParent ) pParent = pRoot ;

    p = strchr( OldHdr.th_fname , ':' ) ;
    p = ( p ) ? p + 1 : OldHdr.th_fname ;
    strcpy( tmp , p ) ;
    p = strrchr( tmp , '/' ) ;
    if ( p ) p[1] = '\0' ;

    if ( strchr( tmp , '/' ) )
      for ( p = strtok( tmp , "/" ) ; p ; p = strtok( NULL , "/" ) )
      {
	pObj = FindObjectByName( pParent , p ) ;
	if ( ! pObj )
	{
	  pObj = MakeNewDir( p , pParent->obj_UserData+1 ) ;
	  if ( ! pObj )
	  {
	    FreeObject( pObj ) ;
	    return( NULL ) ;
	  }
	  AddChild( pParent , pObj ) ;
	}
	pParent = pObj ;
      }

    AddChild( pParent , pNew ) ;

    /* update status info */

    FilesDone++ ;
    BytesDone += pNew->obj_Size ;
    GetFullName( tmp , pNew ) ;
    MonitorPrint( MP_POS1 , tmp , MPF_LINEFEED ) ;
    if ( HasInterface() ) MonitorStatus( Archive ) ;

    if (! SkipData( Archive , pGHdr )) break ;
  }
  while ( ReadNextHeader( Archive , pGHdr ) ) ;

  return( pRoot ) ;
}

/*************************************************************************/

static struct Object *Rebuild50X( void )

/*
 * Rebuild the catalog of an archive in the v5.0x format
 * Returns a pointer to the root object, or NULL if failed
 */

{
  BOOL Flg ;
  LONG k, l ;
  struct Object *pRoot, *pObj, *pNew, *pParent, *pFirst, *pNext ;

  /* initializations */

  DirCount = 0 ;
  pNew = pParent = NULL ;
  IdntDate = pGHdr->h_BDate ;

  /*
   * Create root object:
   * allocate a directory object which name is the new object parent dir,
   * and add the new object as its children
   */

  pNew = MakeNewObject( pGHdr ) ;
  if ( ! pNew ) return( NULL ) ;
  GetObjPosition( pNew ) ;

  pRoot = PushDownTree( pGHdr->h_Parent , pNew ) ;
  if ( ! pRoot )
  {
    FreeObject( pNew ) ;
    return( NULL ) ;
  }

  for ( k = 1 ; k < pNew->obj_UserData ; k++ )
  {
    pParent = PushDownTree( NULL , pRoot ) ;
    if ( ! pParent )
    {
      FreeDirTree( pRoot ) ;
      return( NULL ) ;
    }
    pRoot = pParent ;
  }

  /*
   * Read loop
   * pRoot   = root directory
   * pNew    = new object to insert
   * pObj    = last inserted object
   * pParent = parent directory of pObj
   */

  FOREVER
  {
    /* update status info */

    FilesDone++ ;
    BytesDone += pNew->obj_Size ;
    if ( ObjIsDevice( pNew ) ) strcpy( tmp , pNew->obj_Name ) ;
			  else GetFullName( tmp , pNew ) ;
    MonitorPrint( MP_POS1 , tmp , MPF_LINEFEED ) ;
    if ( HasInterface() ) MonitorStatus( Archive ) ;

    /* skip object data and read next header */

    if (! SkipData( Archive , pGHdr )) break ;
    if (! ReadNextHeader( Archive , pGHdr )) break ;
    if ( pGHdr->h_Type == HT_CATAL ) break ;

    pObj = pNew ;
    if ( pObj ) pParent = pObj->obj_Parent ;
    if ( ! pParent ) pParent = pRoot ;

    pNew = MakeNewObject( pGHdr ) ;
    if ( ! pNew ) break ;
    GetObjPosition( pNew ) ;

    if ( pNew->obj_UserData < pObj->obj_UserData )
    {
      /*
       * Lower level than previous object :
       * Go up in directory tree until the good level is reached (if some
       * directories are missing, allocate new dirs and insert them)
       */

      for ( k = pObj->obj_UserData ; k > pNew->obj_UserData ; k-- )
      {
	if ( ! pParent )
	{
	  pRoot = PushDownTree( NULL , pObj ) ;
	  if ( ! pRoot )
	  {
	    FreeObject( pNew ) ;
	    goto _end ;
	  }
	  pParent = pRoot ;
	}
	pObj = pParent ;
	pParent = pObj->obj_Parent ;
      }
      if ( ! pParent ) pParent = pRoot ;

      /* fall down in the "same level" case */
      pObj = pNew ;
    }

    if ( pNew->obj_UserData == pObj->obj_UserData )
    {
      /*
       * Same level as previous object : compare parent directory names
       * If equal, add the new object to the children of the directory
       * Else, create a new dir and add the new object in it
       */

      if (! strcmp( pGHdr->h_Parent , pParent->obj_Name )) AddChild( pParent , pNew ) ;
      else
      {
	/* set flag to TRUE if previous object parent name unknown */
	Flg = (! strncmp( pParent->obj_Name , UNKNOWN_DIR , strlen(UNKNOWN_DIR) )) ? TRUE : FALSE ;

	/* make sure that directory name is unique */
	pFirst = pParent->obj_Parent ;
	if ( pFirst && (pNext = FindObjectByName( pFirst , pGHdr->h_Parent )) )
	{
	  pNext->obj_SelChildren++ ;
	  SPrintf( tmp , "%s%ld" , pGHdr->h_Parent , pNext->obj_SelChildren ) ;
	}
	else strcpy( tmp , pGHdr->h_Parent ) ;

	/* create the parent dir */
	pObj = MakeNewDir( tmp , pNew->obj_UserData - 1 ) ;
	if ( ! pObj )
	{
	  FreeObject( pNew ) ;
	  break ;
	}

	/* if previous parent was unknown, we assume both objects have the same parent */
	if ( Flg )
	{
	  /* transfert all children */
	  for ( pFirst = FirstChild( pParent ) ; pNext = NextChild( pFirst ) ; pFirst = pNext )
	  {
	    RemChild( pFirst ) ;
	    AddChild( pObj , pFirst ) ;
	  }
	  /* remove dummy directory, and replace it by the new parent dir */
	  if ( pFirst = pParent->obj_Parent )
	  {
	    RemChild( pParent ) ;
	    FreeObject( pParent ) ;
	    AddChild( pFirst , pObj ) ;
	  }
	  else pRoot = pObj ;
	  pParent = pObj ;
	}
	else	/* add the new parent dir to the tree */
	{
	  if ( ! pParent->obj_Parent )
	  {
	    if ( pObj->obj_UserData > pParent->obj_UserData )
	    {
	      pRoot = PushDownTree( NULL , pParent ) ;
	      if ( ! pRoot )
	      {
		FreeObject( pNew ) ;
		pRoot = pParent ;
		break ;
	      }
	      AddChild( pRoot , pObj ) ;
	    }
	    else if ( pObj->obj_UserData < pParent->obj_UserData )
	    {
	      pRoot = pObj ;
	      AddChild( pRoot , pParent ) ;
	    }
	    else pObj = pParent ;
	  }
	  else AddChild( pParent->obj_Parent , pObj ) ;
	}

	/* add the new object to the new directory */
	AddChild( pObj , pNew ) ;
      }
    }
    else if ( pNew->obj_UserData > pObj->obj_UserData )
    {
      /*
       * Higher level than previous object:
       * Go down in directory tree until the good level is reached (if some
       * directories are missing, allocate new dirs and insert them)
       * Add the new object to the directory
       */

      l = pNew->obj_UserData - 1 ;
      for ( k = pObj->obj_UserData ; k < pNew->obj_UserData ; k++ )
      {
	pFirst = MakeNewDir( (k == l) ? pGHdr->h_Parent : NULL , k ) ;
	if ( ! pFirst )
	{
	  FreeObject( pNew ) ;
	  goto _end ;
	}
	AddChild( pParent , pFirst ) ;
	pParent = pFirst ;
      }

      AddChild( pParent , pNew ) ;
    }
  }

_end:
  if ( pRoot )
  {
    pFirst = FirstChild( pRoot ) ;
    k = strlen( pFirst->obj_Name ) - 1 ;
    if ( (k >= 0) && (pFirst->obj_Name[k] == ':') && (pRoot->obj_Size > 1) )
    {
      SetObjFlag( pRoot , OBJF_MULTIVOL|OBJF_DEVICE ) ;
      pRoot->obj_Name[0] = '\0' ;
    }
  }

  return( pRoot ) ;
}

/*************************************************************************/

static struct Object *InsertNewObject( struct Object *pRoot , struct Header *pHdr )

/*
 * Main function for rebuilding post-5.10 archive catalogs
 * It automatically build the path for the given object, and then add this
 * object in the right directory
 */

{
  LONG k, l ;
  struct Object *pDir, *pFirst, *pNext, *pNew ;

  /* creates the path */

  for ( k = 0 ; k < pHdr->h_PathLen ; k++ )
  {
    /* searches for a directory with the given number */
    pDir = NULL ;
    l = pHdr->h_PathTable[k] ;
    for ( pFirst = FirstChild( pRoot ) ; pNext = NextChild( pFirst ) ; pFirst = pNext )
      if ( pFirst->obj_UserData == l )
      {
	pDir = pFirst ;
	break ;
      }

    /* not found : create it */
    if ( ! pDir )
    {
      pDir = MakeNewDir( NULL , l ) ;
      if ( ! pDir ) return( NULL ) ;
      AddChild( pRoot , pDir ) ;
    }
    pRoot = pDir ;
  }

  /* modifies the parent dir's name if unknown */

  if ( pRoot->obj_Parent &&
       (! strncmp( pRoot->obj_Name , UNKNOWN_DIR , strlen(UNKNOWN_DIR) )) &&
       (pNew = MakeNewDir( pHdr->h_Parent , pRoot->obj_UserData )) )
  {
    /* transfert all children */
    for ( pFirst = FirstChild( pRoot ) ; pNext = NextChild( pFirst ) ; pFirst = pNext )
    {
      RemChild( pFirst ) ;
      AddChild( pNew , pFirst ) ;
    }
    /* remove the directory, and replace it by the new one */
    pFirst = pRoot->obj_Parent ;
    RemChild( pRoot ) ;
    FreeObject( pRoot ) ;
    AddChild( pFirst , pNew ) ;
    pRoot = pNew ;
  }

  /* creates the object */

  pDir = MakeNewObject( pHdr ) ;
  if ( ! pDir ) return( NULL ) ;
  GetObjPosition( pDir ) ;
  AddChild( pRoot , pDir ) ;

  return( pDir ) ;
}

/*************************************************************************/

static struct Object *Rebuild510( void )

/*
 * Rebuild the catalog of an archive in the v5.10 format
 * Returns a pointer to the root object, or NULL if failed
 */

{
  LONG k ;
  struct Object *pRoot, *pNew ;

  /* initializations */

  DirCount = 0 ;
  IdntDate = pGHdr->h_BDate ;

  pRoot = MakeNewDir( "Ram:" , 0 ) ;
  if ( ! pRoot ) return( NULL ) ;

  /* read loop */

  FOREVER
  {
    /* add the new object in the tree */

    pNew = InsertNewObject( pRoot , pGHdr ) ;
    if ( ! pNew ) break ;

    /* update status info */

    FilesDone++ ;
    BytesDone += pNew->obj_Size ;
    if ( ObjIsDevice( pNew ) ) strcpy( tmp , pNew->obj_Name ) ;
			  else GetFullName( tmp , pNew ) ;
    MonitorPrint( MP_POS1 , tmp , MPF_LINEFEED ) ;
    if ( HasInterface() ) MonitorStatus( Archive ) ;

    /* skip object data and read next header */

    if (! SkipData( Archive , pGHdr )) break ;
    if (! ReadNextHeader( Archive , pGHdr )) break ;
    if ( pGHdr->h_Type == HT_CATAL ) break ;
  }

  if ( pRoot )
  {
    pNew = FirstChild( pRoot ) ;
    k = strlen( pNew->obj_Name ) - 1 ;
    if ( (k >= 0) && (pNew->obj_Name[k] == ':') && (pRoot->obj_Size > 1) )
    {
      SetObjFlag( pRoot , OBJF_MULTIVOL|OBJF_DEVICE ) ;
      pRoot->obj_Name[0] = '\0' ;
    }
  }

  return( pRoot ) ;
}

/*************************************************************************/

static BOOL RebuildSortDirTree( struct Object *pObj )

/* Sort function for catalog rebuilding */

{
  if ( ObjIsDir( pObj ) ) SortDirTree( pObj ) ;
  return( TRUE ) ;
}

/*************************************************************************/

BOOL DoRebuild( BYTE *pName )

/* $DOC
 * FUNCTION
 *	Rebuild the catalog of an archive. This high-level function
 *	masks the difference between the various archive formats.
 * INPUTS
 *	pName = name of the archive
 * OUTPUTS
 *	Result = success/failure
 * $END
 */

{
  BOOL Ret = FALSE ;
  struct Object *pRoot ;
  struct ArcUnit *pUnit ;

  /* open the archive */

  Archive = OpenArc( pName , OAF_READ ) ;
  if ( ! Archive ) return( FALSE ) ;

  InitOperation() ;
  if ( HasInterface() ) MonitorStatus( Archive ) ;

  /* if archive on floppy, ask the first disk */

  pUnit = FindCurUnit( Archive ) ;
  if ( DevIsTrackDisk( pUnit ) )
    if (! DiskRequest( pUnit , DR_NEXTDISK ))
    {
      CloseArc( Archive ) ;
      return( FALSE ) ;
    }

  /* Read the first header, and call the right function */

  if ( ReadNextHeader( Archive , pGHdr ) )
  {
    IdntDate = pGHdr->h_BDate ;
    if ( OldArchiveFmt() )
      pRoot = RebuildOld() ;
    else if ( HasPathTable( ArchiveFmt ) )
      pRoot = Rebuild510() ;
    else
      pRoot = Rebuild50X() ;
  }
  else pRoot = NULL ;

  if ( ! FilesDone )
  {
    FreeDirTree( pRoot ) ;
    return( FALSE ) ;
  }

  /* Store new catalog */

  if ( pRoot )
  {
    MonitorPrint( MP_POS1 , GetStr( MSG_SORTING_TREE ) , MPF_LINEFEED ) ;
    WalkDirTree( pRoot , RebuildSortDirTree , WDTF_RECURSIVE|WDTF_DIRBEFORE ) ;
    CloseArc( Archive ) ;
    ClearPrgFlag( PF_BREAKED ) ;

    GArcInfo.ai_NumFiles = FilesDone ;
    GArcInfo.ai_NumBytes = BytesDone ;
    GArcInfo.ai_CType	 = CompType ;
    Ret = WriteCatalog( Archive , pRoot , CompType , WCF_TOFILE ) ;
    FreeDirTree( pRoot ) ;
  }

  return( Ret ) ;
}
