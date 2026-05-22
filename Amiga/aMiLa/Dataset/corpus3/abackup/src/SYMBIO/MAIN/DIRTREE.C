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
    dirtree.c

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 04-Aug-93
    Modified: 18-Jan-98
    _______________________________________________________________________
*/

#include "headers.h"

#define PARENT_DIR	"/"
#define BMT_CHIP	2	// device buffer must be in CHIP memory
#define DLFLAGS 	(LDF_DEVICES|LDF_READ)

WORD RecursLevel = 1 ;		// recursion level of WalkDirTree()

static BYTE tmp[MAXSTR+1] ;

/*************************************************************************/

struct Object *FindDevByName( BYTE *pName )

/* $DOC
 * FUNCTION
 *	Finds a device by it's name, in the list of all devices.
 * INPUTS
 *	pName = device name, either physical (DF0:) or logical (Empty:)
 * OUTPUTS
 *	Result = pointer to the corresponding Object structure, or NULL
 *		if failed
 * $END
 */

{
  APTR OldPtr ;
  struct Object *p, *q ;
  static BYTE aux[MINSTR+2] ;

  OldPtr = SetWinPtr( (APTR)-1 ) ;

  for ( p = FirstChild( DevList ) ; q = NextChild( p ) ; p = q )
  {
    if (! stricmp( p->obj_Name , pName )) goto _ok ;
    if ( MyInfo( p->obj_Name , aux ) && (! stricmp( pName , aux )) ) goto _ok ;
  }

  p = NULL ;

_ok:

  SetWinPtr( OldPtr ) ;
  return( p ) ;
}

/*************************************************************************/

struct Object *FindObjectByNum( struct Object *pRoot , LONG Num )

/* $DOC
 * FUNCTION
 *	Returns a pointer to the "num"-th object of a directory tree
 * INPUTS
 *	pRoot = pointer to a directory or root object
 *	Num = number of the desired object
 * OUTPUTS
 *	Result = pointer to an object structure, or NULL if failed
 * $END
 */

{
  struct Object *pFirst, *pNext ;

  for ( pFirst = FirstChild( pRoot ) ; pNext = NextChild( pFirst ) ; pFirst = pNext )
  {
    if ( ! Num ) return( pFirst ) ;
    Num-- ;
  }
  return( NULL ) ;
}

/*************************************************************************/

struct Object *FindObjectByName( struct Object *pRoot , BYTE *pName )

/* $DOC
 * FUNCTION
 *	Finds an object of a given name
 * INPUTS
 *	pRoot = pointer to a directory or root object
 *	pName = pointer to the name of the desired object
 * OUTPUTS
 *	Result = pointer to an object structure, or NULL if failed
 * $END
 */

{
  struct Object *pFirst, *pNext ;

  for ( pFirst = FirstChild( pRoot ) ; pNext = NextChild( pFirst ) ; pFirst = pNext )
    if (! stricmp( pFirst->obj_Name , pName )) return( pFirst ) ;

  return( NULL ) ;
}

/*************************************************************************/

void NoChildren( struct Object *pObj )

/* $DOC
 * FUNCTION
 *	Clears the children list of an object
 * INPUTS
 *	pObj = pointer to an object structure
 * $END
 */

{
  pObj->obj_SelChildren = 0 ;
  if ( ObjIsDir( pObj ) ) pObj->obj_Size = 0 ;
  NewList( (struct List *)&(pObj->obj_Children) ) ;
}

/*************************************************************************/

void RemChild( struct Object *pChild )

/* $DOC
 * FUNCTION
 *	Remove an object from the list of the children of another object
 * INPUTS
 *	pChild = object to remove
 * $END
 */

{
  Remove( (struct Node *)pChild ) ;
  if ( pChild = pChild->obj_Parent ) pChild->obj_Size-- ;
}

/*************************************************************************/

void AddChild( struct Object *pRoot , struct Object *pChild )

/* $DOC
 * FUNCTION
 *	Adds an object to the list of the children of another object
 * INPUTS
 *	pRoot = parent object
 *	pChild = object to add
 * $END
 */

{
  if ( pRoot->obj_Flags & OBJF_MULTIUSER ) SetObjFlag( pChild , OBJF_MULTIUSER ) ;
  AddTail( (struct List *)&(pRoot->obj_Children) , (struct Node *)pChild ) ;
  pChild->obj_Parent = pRoot ;
  pRoot->obj_Size++ ;
}

/*************************************************************************/

static BOOL WDT_CallFunc( BOOL (*pFunc)( struct Object * ) , struct Object *pObj , LONG Flg )
{
  if ( Flg & WDTF_SELECTED )
    if (! ObjIsSelected( pObj )) return( TRUE ) ;

  if ( (Flg & WDTF_EMPTYDIRS) && ObjIsNotEmptyDir( pObj ) ) return( TRUE ) ;

  return( (*pFunc)( pObj ) ) ;
}

BOOL __stackext WalkDirTree( struct Object *pObj , BOOL (*pFunc)( struct Object * ) , LONG Flg )

/* $DOC
 * FUNCTION
 *	Recursively walks down trough a directory tree, calling a function for each
 *	object encountered.
 * INPUTS
 *	pObj = pointer to a directory or root object
 *	pFunc = pointer to the function to call. The function will receive a pointer
 *		to the current object as unique argument. If the function returns
 *		FALSE, the directory scanning is immediatly aborted.
 *	Flg = combination of:
 *		WDTF_RECURSIVE		walk down in sub-directories
 *		WDTF_DIRAFTER		process directories after walking down
 *		WDTF_DIRBEFORE		process directories before walking down
 *		WDTF_SELECTED		call the function for selected objects only
 *		WDTF_EMPTYDIRS		process empty dirs only
 * OUTPUTS
 *	Result = return value of the user function returned
 * NOTES
 *	If neither WDTF_DIRAFTER nor WDTF_DIRBEFORE are provided, the user function
 *	is never called for directories (except empty dirs if WDTF_EMPTYDIRS is set)
 * $END
 */

{
  BOOL Ret ;
  struct Object *pNext ;

  if ( ! pObj ) return( FALSE ) ;
  if ( RecursLevel == 1 ) GPathIndex = 0 ;

  /* loop over every child of directory which root is pObj */
  for ( pObj = FirstChild( pObj ) ; pNext = NextChild( pObj ) ; pObj = pNext )
  {
    if ( ObjIsDir( pObj ) )
    {
      Ret = TRUE ;

      /* process dir if asked */
      if ( (Flg & WDTF_DIRBEFORE) && Ret ) Ret = WDT_CallFunc( pFunc , pObj , Flg ) ;

      /* if directory non empty and recurs : go down */
      if ( (Flg & WDTF_RECURSIVE) && Ret && ObjIsNotEmptyDir( pObj ) )
      {
	GPathIndex++ ;
	if ( GPathIndex < PATHTABLE ) GPathTable[GPathIndex] = 0 ;

	RecursLevel++ ;
	Ret = WalkDirTree( pObj , pFunc , Flg ) ;
	RecursLevel-- ;

	GPathIndex-- ;
	if ( GPathIndex < PATHTABLE ) GPathTable[GPathIndex]++ ;
      }

      /* process dir if asked */
      if ( (Flg & WDTF_DIRAFTER) && Ret ) Ret = WDT_CallFunc( pFunc , pObj , Flg ) ;
    }
    else Ret = WDT_CallFunc( pFunc , pObj , Flg ) ;

    /* stop if last call of pFunc returned FALSE */
    if ( ! Ret ) return( FALSE ) ;
  }

  return( TRUE ) ;
}

/*************************************************************************/

void SortDirTree( struct Object *pRoot )

/* $DOC
 * FUNCTION
 *	Sorts the contents of a directory tree
 * INPUTS
 *	pRoot = root of the tree to sort
 * $END
 */

{
  VOID *pTree ;
  struct Object *p, *q ;

  if ( pRoot->obj_Size < 2 ) return ;

  if ( pTree = CreateAVLTree( pRoot->obj_Size ) )
  {
    for ( p = FirstChild( pRoot ) ; q = NextChild( p ) ; p = q ) AddAVLNode( pTree , p ) ;
    AVLToList( pTree , pRoot ) ;
  }
}

/*************************************************************************/

struct Object *ObjFromFib( BYTE *pName , struct FileInfoBlock *pFib )

/* $DOC
 * FUNCTION
 *	Allocates and initializes an Object structure
 * INPUTS
 *	pName = name of the object
 *	pFib = pointer to the FileInfoBlock describing the object
 * OUTPUTS
 *	Result = pointer to an Object structure, or NULL if failed
 * $END
 */

{
  struct Object *pObj ;

  /* allocate a new structure */
  pObj = AllocObject( ABO_OBJECT , pName ) ;
  if ( ! pObj ) return( NULL ) ;

  /* determine object type */
  switch ( pFib->fib_DirEntryType )
  {
    case ST_LINKDIR  :
    case ST_LINKFILE : SetObjFlag( pObj , OBJF_HLINK ) ; break ;
    case ST_SOFTLINK : SetObjFlag( pObj , OBJF_SLINK ) ; break ;
    default	     : if ( pFib->fib_DirEntryType > 0 ) SetObjFlag( pObj , OBJF_DIRECTORY ) ;
						    else pObj->obj_Size   = pFib->fib_Size ;
		       break ;
  }

  /* copy other info to structure */
  pObj->obj_Bits = pFib->fib_Protection ;
  pObj->obj_Date = PackDate( &(pFib->fib_Date) ) ;
  if ( pFib->fib_Comment[0] ) SetObjFlag( pObj , OBJF_HASCOMMENT ) ;
  return( pObj ) ;
}

/*************************************************************************/

static BOOL __stackext LoadSubDirTree( struct Object *pRoot )

/*
 * Adds the contents of the directory tree which root is "pRoot"
 * Returns TRUE if ok, FALSE if a problem occurs
 */

{
  BPTR Dir ;
  struct Object *pObj, *pNext ;

  /* open the directory */

  Dir = Lock( pRoot->obj_Name , ACCESS_READ ) ;
  if ( ! Dir )
  {
    HandleError( pRoot->obj_Name , HERR_IOERR ) ;
    return( FALSE ) ;
  }

  if (! Examine( Dir , &GFib ))
  {
    HandleError( pRoot->obj_Name , HERR_IOERR ) ;
    UnLock( Dir ) ;
    return( FALSE ) ;
  }

  if ( HasInterface() )
    if ( NewID == WIN_LOADTREE )
    {
      SetGad( GD_LoadTreeStatus , GTTX_Text, (ULONG)GetStr(MSG_LOADING_TREE) ) ;
      SetGad( GD_LoadTree , GTTX_Text , (ULONG)pRoot->obj_Name ) ;
    }
    else SetGad( GD_Directory , GTTX_Text , (ULONG)pRoot->obj_Name ) ;

  /* scan all objects in this directory */

  while ( ExNext( Dir , &GFib ) )
  {
    if ( StopMe() )
    {
      UnLock( Dir ) ;
      chdir( PARENT_DIR ) ;
      return( FALSE ) ;
    }

    if ( (! IS_BFL_IGNSKIPME) && (! strnicmp( GFib.fib_Comment , "SKIPME" , 6 )) ) continue ;

    pObj = ObjFromFib( GFib.fib_FileName , &GFib ) ;
    if ( ! pObj ) /* couldn't allocate object */
    {
      UnLock( Dir ) ;
      return( FALSE ) ;
    }
    AddChild( pRoot , pObj ) ;
  }

  UnLock( Dir ) ;

  /* sort directory tree */

  if ( HasInterface() )
    SetGad( NewID == WIN_LOADTREE ? GD_LoadTreeStatus : GD_Directory , GTTX_Text, (ULONG)GetStr(MSG_SORTING_TREE) ) ;

  SortDirTree( pRoot ) ;

  if ( HasBeenBreaked() )
  {
    chdir( PARENT_DIR ) ;
    return( FALSE ) ;
  }

  /* examine all subdirectories */

  chdir( pRoot->obj_Name ) ;

  for ( pObj = FirstChild( pRoot ) ; pNext = NextChild( pObj ) ; pObj = pNext )
  {
    /* subdirs are always at the top, so if we meet a file we can stop */
    if (! ObjIsDir( pObj )) break ;
    /* go down in that sub directory */
    if (! LoadSubDirTree( pObj ))
    {
      chdir( PARENT_DIR ) ;
      return( FALSE ) ;
    }
  }

  /* end for this directory */

  chdir( PARENT_DIR ) ;
  return( TRUE ) ;
}

/*************************************************************************/

static struct Object *DoLoadDirTree( BYTE *pName )

/*
 * Loads the contents of the directory tree with root is "pName"
 * Returns a pointer to the "root" object, or NULL is an error occurs
 * The root object will have the OBJF_DIRECTORY flag set
 */

{
  struct Object *pRoot ;

  /* allocate root object */
  pRoot = AllocObject( ABO_OBJECT , pName ) ;
  if ( ! pRoot ) return( NULL ) ;

  if ( IsOnMUFSVolume( pName ) ) SetObjFlag( pRoot , OBJF_MULTIUSER ) ;

  /* loads contents of root directory */
  SetObjFlag( pRoot , OBJF_DIRECTORY ) ;
  if ( LoadSubDirTree( pRoot ) ) return( pRoot ) ;

  /* failed: free partial tree */
  FreeDirTree( pRoot ) ;
  return( NULL ) ;
}

/*************************************************************************/

struct Object *LoadDirTree( BYTE *pName )

/* $DOC
 * FUNCTION
 *	Loads the contents of a directory tree
 * INPUTS
 *	pName = name of a directory. May be a list of directory names,
 *		separated by commas (in this case, the root object will
 *		have the OBJF_MULTIVOL flag set)
 * OUTPUTS
 *	Result = pointer to the root object, or NULL if failed
 * NOTES
 *	Use the FreeDirTree() macro to free the directory tree
 * $END
 */

{
  BYTE *p ;
  struct Object *pRoot, *pObj ;

  getcwd( tmp , MAXSTR ) ;

  if ( p = FirstComponant( pName ) )                    // a list of directories
  {
    /* allocate "super-root" object */
    pRoot = AllocObject( ABO_OBJECT , "" ) ;
    if ( ! pRoot ) return( NULL ) ;
    SetObjFlag( pRoot , (OBJF_MULTIVOL|OBJF_DIRECTORY) ) ;

    /* loads contents of each directory */
    do
    {
      pObj = DoLoadDirTree( p ) ;
      if ( ! pObj )
      {
	FreeDirTree( pRoot ) ;
	pRoot = NULL ;
	break ;
      }
      AddChild( pRoot , pObj ) ;
    }
    while ( p = NextComponant() ) ;
    if ( pRoot ) SortDirTree( pRoot ) ;
  }
  else pRoot = DoLoadDirTree( pName ) ;                 // a single directory

  /* return pointer to root */
  chdir( tmp ) ;
  return( pRoot ) ;
}

/*************************************************************************/

struct Object *AddDirTree( struct Object *pORoot , BYTE *pName )

/* $DOC
 * FUNCTION
 *	Loads the contents of a directory tree, and adds it to the
 *	current root
 * INPUTS
 *	pORoot = current root object
 *	pName  = name of a directory. May be a list of directory names,
 *		 separated by commas (in this case, the root object will
 *		 have the OBJF_MULTIVOL flag set)
 * OUTPUTS
 *	Result = pointer to the new root object (same as old root if failed)
 * NOTES
 *	Use the FreeDirTree() macro to free the directory tree
 * $END
 */

{
  BYTE *p ;
  struct Object *pRoot, *pObj ;

  BlockWinInput();

  // allocates a "super-root" object if required

  if (! ObjIsMultiVol( pORoot ))
  {
    pRoot = AllocObject( ABO_OBJECT , "" ) ;
    if ( ! pRoot ) return( pORoot ) ;
    SetObjFlag( pRoot , (OBJF_MULTIVOL|OBJF_DIRECTORY) ) ;
    AddChild( pRoot , pORoot ) ;
  }
  else pRoot = pORoot ;

  getcwd( tmp , MAXSTR ) ;

  if ( p = FirstComponant( pName ) )                    // a list of directories
  {
    do
    {
      pObj = DoLoadDirTree( p ) ;
      if ( ! pObj ) break ;
      AddChild( pRoot , pObj ) ;
    }
    while ( p = NextComponant() ) ;
  }
  else if ( pObj = DoLoadDirTree( pName ) )             // a single directory
    AddChild( pRoot , pObj ) ;

  // unallocate "super-root" if not usefull

  if ( pRoot->obj_Size < 2 )
  {
    pORoot = FirstChild( pRoot ) ;
    FreeObject( pRoot ) ;
    pRoot = pORoot ;
    pRoot->obj_Parent = NULL ;
  }
  else SortDirTree( pRoot ) ;

  // return pointer to root

  chdir( tmp ) ;
  ReleaseWinInput();
  return( pRoot ) ;
}

/*************************************************************************/

struct Object *LoadDevList( void )

/* $DOC
 * FUNCTION
 *	Builds a list of all the partitions
 * OUTPUTS
 *	Result = pointer to the root object, or NULL if failed.
 * NOTES
 *	The root object will have the OBJF_MULTIVOL, OBJF_DEVICE and OBJF_DIRECTORY
 *	flags set. All children will have the OBJF_DEVICE flag set, and a DeviceDef
 *	structure as first child.
 *	Use the FreeDevList() macro to free the partition list.
 * $END
 */

{
  LONG len, k ;
  struct DosEnvec *pEnv ;
  struct DevInfo *pDInfo ;
  struct DeviceDef *pDef ;
  struct Object *pRoot, *pObj ;
  struct FileSysStartupMsg *pMsg ;

  /* allocate root object */

  pRoot = AllocObject( ABO_OBJECT , "" ) ;
  if ( ! pRoot ) return( NULL ) ;
  SetObjFlag( pRoot , OBJF_MULTIVOL|OBJF_DIRECTORY|OBJF_DEVICE ) ;

  /* parse dos volume list and add an entry for each volume */

  pDInfo = (struct DevInfo *)LockDosList( DLFLAGS ) ;
  while ( pDInfo = (struct DevInfo *)NextDosEntry( (struct DosList *)pDInfo , DLFLAGS ) )
  {
    // get and verify pointers to essential info

    if (! (pDInfo->dvi_Startup & 0x0ffffff0)) continue ;
    pMsg = B2CPTR( pDInfo->dvi_Startup ) ;
    pEnv = B2CPTR( pMsg->fssm_Environ ) ;
    if ( ! pEnv ) continue ;
    if ( pEnv->de_TableSize < DE_UPPERCYL ) continue ;

    // check the size of the device

    len = (pEnv->de_HighCyl - pEnv->de_LowCyl + 1) * pEnv->de_Surfaces * pEnv->de_BlocksPerTrack ;
    k	= pEnv->de_SizeBlock << 2 ;
    if ( len > ((1<<31) / k) ) continue ;
    len *= k ;

    // allocate a new Object structure

    B2CStr( B2CPTR( pDInfo->dvi_Name ) , tmp ) ;
    strcat( tmp , ":" ) ;
    pObj = AllocObject( ABO_OBJECT , tmp ) ;
    if ( ! pObj )
    {
_failed:
      UnLockDosList( DLFLAGS ) ;
      FreeDirTree( pRoot ) ;
      return( NULL ) ;
    }
    AddChild( pRoot , pObj ) ;

    // initialize the Object structure

    SetObjFlag( pObj , OBJF_DEVICE ) ;
    pObj->obj_Size = len ;

    // allocate the DeviceDef structure

    B2CStr( B2CPTR( pMsg->fssm_Device ) , tmp ) ;
    pDef = AllocObject( ABO_DEVICEDEF , tmp ) ;
    if ( ! pDef ) goto _failed ;
    AddDeviceDef( pObj , pDef ) ;

    // initialize the DeviceDef structure

    pDef->dd_Unit  = pMsg->fssm_Unit  ;
    pDef->dd_Flags = pMsg->fssm_Flags ;
    memcpy( &(pDef->dd_Env) , pEnv , sizeof(struct DosEnvec) ) ;
    if ( pEnv->de_TableSize < DE_BUFMEMTYPE ) pDef->dd_Env.de_BufMemType = BMT_CHIP ;
  }

  /* end */

  UnLockDosList( DLFLAGS ) ;
  SortDirTree( pRoot ) ;
  return( pRoot ) ;
}

/*************************************************************************/

void UpdateDevList( BYTE *pName )

/* $DOC
 * FUNCTION
 *	Rescan AmigaDOS device list, in order to update the dd_Env
 *	field of entries in the DevList list
 * INPUTS
 *	pName = name of the entry to update, or NULL for all entries
 * $END
 */

{
  BYTE *p ;
  LONG len ;
  struct DosEnvec *pEnv ;
  struct DeviceDef *pDef ;
  struct DosList *pDInfo ;
  struct DevInfo *pDEntry ;
  struct Object *pFirst, *pNext ;
  struct FileSysStartupMsg *pMsg ;

  pDInfo = LockDosList( DLFLAGS ) ;

  for ( pFirst = FirstChild( DevList ) ; pNext = NextChild( pFirst ) ; pFirst = pNext )
  {
    strcpy( tmp , pFirst->obj_Name ) ;
    if ( pName && (! strcmp( tmp , pName )) ) continue ;
    if ( p = strchr( tmp , ':' ) ) *p = '\0' ;

    // for each entry in DevList, find the corresponding node in AmigaDos device list
    if ( pDEntry = (struct DevInfo *)FindDosEntry( pDInfo , tmp , DLFLAGS ) )
    {
      // get and verify pointers to essential info
      if (! (pDEntry->dvi_Task)) continue ;
      pMsg = B2CPTR( pDEntry->dvi_Startup ) ;
      pEnv = pMsg ? B2CPTR( pMsg->fssm_Environ ) : NULL ;
      if ( ! pEnv ) continue ;
      if ( pEnv->de_TableSize < DE_UPPERCYL ) continue ;

      // update object size
      len = pEnv->de_HighCyl - pEnv->de_LowCyl + 1 ;
      len = len * pEnv->de_Surfaces * pEnv->de_BlocksPerTrack ;
      pFirst->obj_Size = (len * pEnv->de_SizeBlock) << 2 ;

      // update device definition
      if ( pDef = GetDeviceDef( pFirst ) )
      {
	B2CStr( B2CPTR( pMsg->fssm_Device ) , tmp ) ;
	strcpy( pDef->dd_Name , tmp ) ;
	memcpy( &(pDef->dd_Env) , pEnv , sizeof(struct DosEnvec) ) ;
	if ( pEnv->de_TableSize < DE_BUFMEMTYPE ) pDef->dd_Env.de_BufMemType = BMT_CHIP ;
      }
    }
  }

  UnLockDosList( DLFLAGS ) ;
}

