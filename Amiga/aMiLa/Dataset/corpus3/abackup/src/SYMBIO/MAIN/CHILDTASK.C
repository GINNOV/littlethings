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
    childtask.c

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 01-Oct-93
    Modified: 28-Jan-98
    _______________________________________________________________________
*/

#include "headers.h"
#include "childtask.h"

/*************************************************************************/

#ifdef _DEBUG

#define MYSTACKSIZE     KBYTES( 8 )
#define CHILDPORTNAME   "ABackup_child"
#define PARENTPORTNAME  "ABackup_parent"
#define CHILDTASKNAME   "ABackupChildTask"

#define BPRINT( c )     { if ( pMonitor ) *pMonitor++ = c ; }
#define LPRINT( l )     { if ( pMonitor ) { memcpy( pMonitor , &l , 4 ) ; pMonitor += 4 ; } }

static BYTE *pMonitor = NULL ;

#else

#define MYSTACKSIZE     KBYTES( 4 )
#define CHILDPORTNAME   NULL
#define PARENTPORTNAME  NULL
#define CHILDTASKNAME   "ABCK_%08ld"

#endif

/* $DOC Macros_SubTask
 *      ICmdIsSync( c ) 	TRUE if command is synchronous
 *      ICmdIsASync( c )	TRUE if command is asynchronous
 *      ICmdIsPrior( c )	TRUE if command is prioritary
 *      ICmdIsToFree( p )       TRUE if message is to free after use
 *      RemICmd( p )    	remove a queued write command
 *      AddICmd( p )    	enqueue a write command
 * $END
 */

#define ICmdIsSync( c ) 	((c) & ICMDC_SYNC)
#define ICmdIsASync( c )	((c) & ICMDC_ASYNC)
#define ICmdIsPrior( c )	((c) & ICMDC_PRIOR)
#define ICmdIsToFree( p )       ((p)->ic_Flags & ICMDF_FREEMSG)
#define RemICmd( p )    	{ Remove( (struct Node *)p ) ; QueuedCmd-- ; }
#define AddICmd( p )    	{ AddTail( &AWList , (struct Node *)p ) ; QueuedCmd++ ; }

/*************************************************************************/

struct SignalSemaphore SemGFX ; // access arbitration on gfx operations
struct SignalSemaphore SemSCU ; // access arbitration for SetCurrentUnit

/*
 * The QueuedCmd variable contains the number of commands queued in AWList
 * It is updated by the child task. The Parent task only makes "unbreakable"
 * read access on it, i.e. "tst.l XXX(A4)", so there is not need to protect
 * access with Forbid()/Permit()
 */

static LONG CurLeft, QueuedCmd ;
static BYTE *pCurPos, ChildName[MINSTR+1] ;

static struct List AWList ;     		// list of queued write commands
static struct SignalSemaphore SemPort ; 	// access arbitration on MsgPorts
static struct MsgPort *ChildPort  = NULL ,      // for sending commands to the child
		      *ParentPort = NULL ;      // for replying to the parent

/*************************************************************************/

#define ICMDSTACKSIZE   16

static LONG ICmdSP = 0 ;
static struct InternalCmd *ICmdStack[ICMDSTACKSIZE] ;

static void PushICmd( struct InternalCmd *pCmd )
{
  if ( pCmd )
  {
    ICmdStack[ICmdSP] = pCmd ;
    if ( ICmdSP < ICMDSTACKSIZE ) ICmdSP++ ;
  }
}

static struct InternalCmd *PopICmd( void )
{
  if ( ! ICmdSP ) return( NULL ) ;
  return( ICmdStack[--ICmdSP] ) ;
}

/*************************************************************************/

static void SafePutMsg( struct MsgPort *pPort , struct InternalCmd *pCmd , LONG Cmd )

/* Prepare and send a message */

{
  pCmd->ic_Command = Cmd ;
  pCmd->ic_Message.mn_Node.ln_Type = NT_MESSAGE ;
  pCmd->ic_Message.mn_ReplyPort    = ( pPort == ParentPort ) ? ChildPort : ParentPort ;
  pCmd->ic_Message.mn_Length       = sizeof(struct InternalCmd) ;

  ObtainSemaphore( &SemPort ) ;
  PutMsg( pPort , (struct Message *)pCmd ) ;
  ReleaseSemaphore( &SemPort ) ;
}

/*************************************************************************/

static void SafeReplyMsg( struct InternalCmd *pCmd )

/* Replies safely to a message */

{
  ObtainSemaphore( &SemPort ) ;
  ReplyMsg( (struct Message *)pCmd ) ;
  ReleaseSemaphore( &SemPort ) ;
}

/*************************************************************************/

static struct InternalCmd *SafeGetMsg( struct MsgPort *pPort )

/* Gets a message safely */

{
  struct InternalCmd *pCmd ;

  ObtainSemaphore( &SemPort ) ;
  pCmd = (struct InternalCmd *)GetMsg( pPort ) ;
  ReleaseSemaphore( &SemPort ) ;

  return( pCmd ) ;
}

/*************************************************************************/

BOOL ResetChildBuffer( void )

/*
 * Makes all write buffer available
 * Returns FALSE if there are still queued writes in buffer
 */

{
  if ( QueuedCmd ) return( FALSE ) ;

  pCurPos = WriteBuf ;
  CurLeft = WBufSize ;
  return( TRUE ) ;
}

/*************************************************************************/

static void ResetList( void )

/* Free all queued write messages */

{
  struct InternalCmd *pFirst, *pNext ;

  for ( pFirst = FirstCmd( &AWList ) ; pNext = NextCmd( pFirst ) ; pFirst = pNext )
    if ( ICmdIsToFree( pFirst ) ) FreeVec( pFirst ) ;

  NewList( &AWList ) ;
  QueuedCmd = 0 ;
  ICmdSP = 0 ;
}

/*************************************************************************/

static struct InternalCmd *BuildWriteMsg( BYTE *pBuffer , BYTE *pData , LONG Len )

/*
 * Prepare a ICMD_AWRITE message, using the given buffer
 * The buffer must be large enough to fit Len+sizeof(struct InternalCmd) bytes
 *
 * NOTE: the ic_Flags field of the InternalCmd is set to zero
 */

{
  struct InternalCmd *pCmd ;

  pCmd = (struct InternalCmd *)pBuffer ;
  pBuffer += sizeof(struct InternalCmd) ;

  memcpy( pBuffer , pData , (size_t)Len ) ;
  pCmd->ic_Data  = pBuffer ;
  pCmd->ic_Arg   = Len ;
  pCmd->ic_Flags = 0 ;

  return( pCmd ) ;
}

/*************************************************************************/

static void StopWriting( struct ArcUnit *pUnit , struct InternalCmd *pCmd , LONG Cmd )

/*
 * Locks the given unit, and send the "Cmd" command to the parent task
 * NOTE: the ic_Flags field of the InternalCmd is set to zero
 */

{
  pCmd->ic_Flags = 0 ;
  pCmd->ic_Unit  = pUnit ;

  SetUnitFlag( pUnit , AUF_LOCKED ) ;
  ClearUnitFlag( pUnit , AUF_PENDING ) ;

  SafePutMsg( ParentPort , pCmd , Cmd ) ;
}

/*************************************************************************/

static BOOL ChildFlushDev( struct ArcUnit *pUnit , struct InternalCmd *pCmd )

/*
 * Flush the given unit for the child task. This function handles bad cylinders
 * The pCmd message is used to send message to the parent task, if needed
 * Returns TRUE if write successfull, FALSE if sended ICMD_ERROR or ICMD_ASKDISK
 * to parent task
 */

{
  LONG Cyl ;
  BYTE *pBuffer ;
  struct InternalCmd *pWCmd ;

  FOREVER
  {
    // write data to unit
    DoFlushDev( pUnit ) ;
    ClearUnitFlag( pUnit , AUF_BUFFLUSH ) ;
    if ( ! pUnit->au_LastErr ) return( TRUE ) ;

    if ( pUnit->au_LastErr >= TDERR_WriteProt )
    {
      StopWriting( pUnit , pCmd , ICMD_ERROR ) ;
      return( FALSE ) ;
    }

    // failed: report error
    Cyl = CurrentCyl( pUnit ) ;
    if ( Cyl < MAXBADCYL )
    {
      AddBadCyl( pUnit ) ;
      if ( pWCmd = AllocVec( sizeof(struct InternalCmd) , MEMF_PUBLIC ) )
      {
	pWCmd->ic_Unit = pUnit ;
	pWCmd->ic_Arg  = Cyl ;
	SetICmdFlag( pWCmd , ICMDF_FREEMSG ) ;
	SafePutMsg( ParentPort , pWCmd , ICMD_BADCYL ) ;
      }
    }
    else Cyl = 0 ;

    if ( Cyl < 1 )
    {
      StopWriting( pUnit , pCmd , ICMD_ERROR ) ;
      return( FALSE ) ;
    }

    /*
     * End of disk reached: asks for a new one
     * We insert a ICMD_AWRITE command before all pending commands, which will
     * allow to write the data that should have been on the unit
     */

    if ( Cyl >= pUnit->au_NumCyls )
    {
      // allocate some memory for the ICMD_AWRITE command
      pBuffer = AllocVec( pUnit->au_CylSize+sizeof(struct InternalCmd) , MEMF_PUBLIC ) ;
      if ( ! pBuffer )
      {
	pUnit->au_LastErr = TDERR_NoMem ;
	StopWriting( pUnit , pCmd , ICMD_ERROR ) ;
	return( FALSE ) ;
      }

      // build and add the ICMD_AWRITE command
      pWCmd = BuildWriteMsg( pBuffer , pUnit->au_Buffer , pUnit->au_CylSize ) ;
      pWCmd->ic_Unit = pUnit ;
      pWCmd->ic_Command = ICMD_AWRITE ;
      SetICmdFlag( pWCmd , ICMDF_FREEMSG ) ;
      AddHead( &AWList , (struct Node *)pWCmd ) ;
      QueuedCmd++ ;

      // send an ICMD_ASKDISK command to the parent task
      pUnit->au_LastErr = 0 ;
      StopWriting( pUnit , pCmd , ICMD_ASKDISK ) ;
      return( FALSE ) ;
    }

    // retry on next cylinder
    if ( Cyl == pUnit->au_FirstCyl+1 ) pUnit->au_FirstCyl++ ;
    pUnit->au_CurPos += pUnit->au_CylSize ;
  }
}

/*************************************************************************/

static void __interrupt __saveds ChildTask( void )

/*
 * The child task itself
 * When started, it allocates a message port to receive commands
 * If failed, a ICMD_DIE command is send to the parent port before
 * the task terminates.
 * Else, a ICMD_SYNC command is send and the task waits for commands
 */

{
  LONG Len, Left, ToCopy, Cyl ;
  struct ArcUnit *pUnit, *CurUnit ;
  struct InternalCmd CCmd, *pCmd, *pOCmd ;

  // initializations, CAUTION: DO NOT CALL ResetList() !!
  ICmdSP    = 0 ;
  QueuedCmd = 0 ;
  pOCmd     = NULL ;
  CurUnit   = NULL ;
  NewList( &AWList ) ;
  memset( &CCmd , '\0' , sizeof(struct InternalCmd) ) ;

  // allocate the message port and send startup message
  ChildPort = CreatePort( CHILDPORTNAME , 0 ) ;
  if ( ! ChildPort )
  {
    SafePutMsg( ParentPort , &CCmd , ICMD_DIE ) ;
    RemTask( NULL ) ;
  }

  SafePutMsg( ParentPort , &CCmd , ICMD_SYNC ) ;

  // loop for waiting and processing parent messages
  FOREVER
  {
    /*
     * No command yet : get next message from port
     * We try first to pop a command from the stack
     * If there are no queued write command, or if unit locked, we do a WaitPort()
     */

_loop:

    if ( (! pOCmd) && CurUnit && (! DevIsLocked( CurUnit )) ) pOCmd = PopICmd() ;

    if ( ! pOCmd )
    {
      pCmd = FirstCmd( &AWList ) ;
      if ( (! NextCmd( pCmd )) || DevIsLocked( pCmd->ic_Unit ) )
      {
	if ( CurUnit && DevIsTrackDisk( CurUnit ) )
	{
	  CurUnit->au_IOReq->iotd_Req.io_Command = TD_MOTOR ;
	  CurUnit->au_IOReq->iotd_Req.io_Length  = 0 ;
	  DoIO( (struct IORequest *)CurUnit->au_IOReq ) ;
	}
	WaitPort( ChildPort ) ;
      }
      pOCmd = SafeGetMsg( ChildPort ) ;
    }

    /* check command number */
    if ( pOCmd && (pOCmd->ic_Command & ~(ICMDC_MASK|ICMDN_MASK)) ) pOCmd = NULL ;

    /*
     * Execute prioritary commands
     */

    if ( pOCmd && ICmdIsPrior( pOCmd->ic_Command ) )
    {
      pUnit = pOCmd->ic_Unit ;

      switch ( pOCmd->ic_Command )
      {
	case ICMD_DOIO :			// execute a device command

	  if ( (! CurUnit) && (pUnit->au_IOReq->iotd_Req.io_Command == CMD_READ) ) CurUnit = pUnit ;
	  DoIO( (struct IORequest *)pUnit->au_IOReq ) ;
	  pUnit->au_Result = pUnit->au_IOReq->iotd_Req.io_Actual ;
	  SafeReplyMsg( pOCmd ) ;
	  break ;

	case ICMD_SWRITE :      		// synchronous write (does not handle bad cyls)

	  SetUnitFlag( pUnit , AUF_PENDING ) ;
	  DoFlushDev( pUnit ) ;
	  ClearUnitFlag( pUnit , AUF_PENDING ) ;
	  SafeReplyMsg( pOCmd ) ;
	  break ;

	case ICMD_AWRITE :      		// asynchronous write

	  CurUnit = pUnit ;
	  AddICmd( pOCmd ) ;
	  break ;

	case ICMD_RESTART :     		// restart asynchronous write

	  ClearUnitFlag( CurUnit , AUF_LOCKED ) ;
	  ClearUnitFlag( pUnit , AUF_LOCKED ) ;
	  CurUnit = pUnit ;
	  break ;

	case ICMD_CANCEL :      		// abort asynchronous write

	  ClearUnitFlag( CurUnit , AUF_LOCKED ) ;
	  ClearUnitFlag( CurUnit , AUF_BUFFLUSH ) ;
	  CurUnit = NULL ;
	  ResetList() ;
	  break ;
      }

      pOCmd = NULL ;
      continue ;
    }

    /*
     * Process the first queued write
     */

    pCmd = FirstCmd( &AWList ) ;
    if ( NextCmd( pCmd ) )
    {
      if ( DevIsLocked( CurUnit ) )
      {
	PushICmd( pOCmd ) ;
	pOCmd = NULL ;
	continue ;
      }

      SetUnitFlag( CurUnit , AUF_PENDING ) ;

      for ( Len = pCmd->ic_Arg ; (Len > 0) && (! HasBeenBreaked()) ; Len -= ToCopy )
      {
	// test if we try to write past end of disk
	Cyl = CurrentCyl( CurUnit ) ;
	if ( Cyl >= CurUnit->au_NumCyls )
	{
	  StopWriting( CurUnit , &CCmd , ICMD_ASKDISK ) ;
	  PushICmd( pOCmd ) ;
	  pOCmd = NULL ;
	  goto _loop ;
	}

	// copy data to buffer
	Cyl  = CurUnit->au_CurPos % CurUnit->au_CylSize ;
	Left = CurUnit->au_CylSize - Cyl ;
	ToCopy = MIN( Len , Left ) ;
	if ( ToCopy )
	{
	  memcpy( &CurUnit->au_Buffer[Cyl] , pCmd->ic_Data , (size_t)ToCopy ) ;
	  SetUnitFlag( CurUnit , AUF_BUFFLUSH ) ;
	  CurUnit->au_CurPos += ToCopy ;
	  pCmd->ic_Data += ToCopy ;
	  pCmd->ic_Arg -= ToCopy ;
	}

	// should we flush buffer ?
	if ( ToCopy == Left )
	  if (! ChildFlushDev( CurUnit , &CCmd ))
	  {
	    PushICmd( pOCmd ) ;
	    pOCmd = NULL ;
	    goto _loop ;
	  }
      }

      ClearUnitFlag( CurUnit , AUF_PENDING ) ;

      // remove message from queue
      RemICmd( pCmd ) ;
      if ( ICmdIsToFree( pCmd ) ) FreeVec( pCmd ) ;
      continue ;
    }

    /*
     * This is the place to process all other messages
     */

    if ( ! pOCmd ) continue ;
    if ( pUnit = pOCmd->ic_Unit ) SetUnitFlag( pUnit , AUF_PENDING ) ;

    switch ( pOCmd->ic_Command )
    {
      case ICMD_DIE  :  		// termination

	while ( pCmd = SafeGetMsg( ChildPort ) )
	  if ( ICmdIsToFree( pCmd ) ) FreeVec( pCmd ) ;
	DeletePort( ChildPort ) ;
	ChildPort = NULL ;
	ResetList() ;
	RemTask( NULL ) ;
	break ;

      case ICMD_OPEN :  		// opens a device

	DoOpenDev( pUnit , (struct DeviceDef *)pOCmd->ic_Data ) ;
	break ;

      case ICMD_CLOSE : 		// closes a device

	if ( CurUnit == pUnit ) CurUnit = NULL ;
	if ( DevIsOpened( pUnit ) && DevIsTrackDisk( pUnit ) )
	{
	  pUnit->au_IOReq->iotd_Req.io_Length = 0 ;
	  MyDoIO( pUnit , TD_MOTOR ) ;
	}
	DoCloseDev( pUnit ) ;
	break ;

      case ICMD_SYNC :  		// wait end of queued writes and flush last cylinder

	ClearUnitFlag( pUnit , AUF_PENDING ) ;
	pUnit = FindCurUnit( pUnit->au_Parent ) ;
	if ( DevIsToUpdate( pUnit ) )
	{
	  SetUnitFlag( pUnit , AUF_PENDING ) ;
	  if (! ChildFlushDev( pUnit , &CCmd ))
	  {
	    PushICmd( pOCmd ) ;
	    pOCmd = NULL ;
	    goto _loop ;
	  }
	}
	ResetList() ;
	break ;

      case ICMD_WAIT :  		// wait end of queued writes

	pOCmd->ic_Unit = CurUnit ;
	ResetList() ;
	break ;
    }

    if ( pUnit ) ClearUnitFlag( pUnit , AUF_PENDING ) ;
    if ( ICmdIsSync( pOCmd->ic_Command ) ) SafeReplyMsg( pOCmd ) ;
    pOCmd = NULL ;
  }

  // NOTE: we should *NEVER* come here...
  RemTask( NULL ) ;
}

/*************************************************************************/

struct ArcUnit *WaitChildMsg( struct InternalCmd *pOCmd )

/*
 * Wait a reply from the child task
 * If pOCmd != NULL, wait for a reply to this message
 * If pOCmd == -1, never waits for messages
 * Deals with ICMD_ERROR, ICMD_ASKDISK and ICMD_BADCYL messages
 */

{
  struct ArcUnit *pUnit ;
  ULONG rsig, csig, wsig ;
  struct InternalCmd *pNCmd ;

  csig  = 1 << ParentPort->mp_SigBit ;
  wsig  = Win ? 1 << Win->UserPort->mp_SigBit : 0 ;

  FOREVER
  {
    // vide les messages en attente
    while ( pNCmd = SafeGetMsg( ParentPort ) )
    {
      pUnit = pNCmd->ic_Unit ;

      // reporte les pistes défectueuses
      if ( pNCmd->ic_Command == ICMD_BADCYL )
      {
	ReportBadCyl( pUnit , pNCmd->ic_Arg ) ;
	if ( ICmdIsToFree( pNCmd ) ) FreeVec( pNCmd ) ;
	continue ;
      }

      // effectue les demandes de disquette
      if ( pNCmd->ic_Command == ICMD_ASKDISK )
      {
	if ( pUnit = NextFloppy( pUnit->au_Parent ) )
	{
	  pNCmd->ic_Unit = pUnit ;
	  pNCmd->ic_Command = ICMD_RESTART ;
	  if ( HasInterface() ) MonitorStatus( pUnit->au_Parent ) ;
	}
	else
	{
	  SetPrgFlag( PF_BREAKED ) ;
	  pNCmd->ic_Command = ICMD_CANCEL ;
	}

	SafeReplyMsg( pNCmd ) ;
	if ( pNCmd->ic_Command == ICMD_CANCEL ) return( NULL ) ;
	continue ;
      }

      // reporte les erreurs d'E/S
      if ( pNCmd->ic_Command == ICMD_ERROR )
      {
	UnitError( pUnit ) ;
	pNCmd->ic_Command = ICMD_CANCEL ;
	SafeReplyMsg( pNCmd ) ;
	return( NULL ) ;
      }

      if ( (! pOCmd) || (pOCmd == pNCmd) ) return( pUnit ) ;
    }

    if ( pOCmd == (struct InternalCmd *)-1 ) return( (struct ArcUnit *)-1 ) ;

    // attend un message
    do
    {
      rsig = Wait( csig | wsig ) ;
      if ( rsig & wsig ) StopMe() ;
    }
    while (! (rsig & csig)) ;
  }
}

/*************************************************************************/

LONG DoASyncIO( struct ArcUnit *pUnit , LONG Cmd , BYTE *pData , LONG Arg )

/* $DOC
 * FUNCTION
 *      Sends a command to the child task
 * INPUTS
 *      pUnit = pointer to the unit to which the command is to apply
 *      	(may be NULL for some commands)
 *      Cmd = command to send (see Objects.h)
 *      pData = pointer argument (may be NULL for some commands)
 *      Arg = numeric argument
 * OUTPUTS
 *      Result = return value if command is ICMD_OPEN or ICMD_SWRITE
 *      	 always TRUE otherwise
 * $END
 */

{
  LONG Size ;
  struct ArcUnit *pNUnit ;
  struct InternalCmd CCmd, *pCmd ;

  CCmd.ic_Flags = 0 ;
  CCmd.ic_Unit  = NULL ;

  // asynchronous write: store in buffer and exit
  if ( Cmd == ICMD_AWRITE )
  {
    // compute size needed in buffer
    Size = sizeof(struct InternalCmd) + Arg ;
    if ( Size & 1 ) Size++ ;

    // not enought space in buffer: wait end of asynchronous writes
    if ( Size > CurLeft )
    {
      do
      {
	SafePutMsg( ChildPort , &CCmd , ICMD_WAIT ) ;
	pNUnit = WaitChildMsg( &CCmd ) ;
      }
      while (! ResetChildBuffer()) ;
      if ( pNUnit ) pUnit = pNUnit ;
    }

    // prepare message
    pCmd = BuildWriteMsg( pCurPos , pData , Arg ) ;
    pCurPos += Size ;
    CurLeft -= Size ;

    // send write message
    pCmd->ic_Unit = pUnit ;
    SafePutMsg( ChildPort , pCmd , ICMD_AWRITE ) ;
    if (! WaitChildMsg( (struct InternalCmd *)-1 )) return( FALSE ) ;
    return( TRUE ) ;
  }

  // send command to child task
  CCmd.ic_Arg   = Arg ;
  CCmd.ic_Data  = pData ;
  CCmd.ic_Unit  = pUnit ;
  SafePutMsg( ChildPort , &CCmd , Cmd ) ;

  // wait for reply and exit
  if ( ICmdIsSync( Cmd ) )
  {
    pUnit = WaitChildMsg( &CCmd ) ;
    if ( (! pUnit) || pUnit->au_LastErr ) return( FALSE ) ;
  }
  return( TRUE ) ;
}

/*************************************************************************/

BOOL SetupChildTask( void )

/* $DOC
 * FUNCTION
 *      Starts the child task, and initialize all required data
 * OUTPUTS
 *      Result = success/failure
 * $END
 */

{
  struct InternalCmd *pCmd ;

  /*
   * Initialize our semaphores, which will arbitrate access to MsgPorts,
   * gfx operations, and SetCurrentUnit()
   * The memset() is *MANDATORY*, see InitSemaphore() autodoc
   */

  memset( &SemPort , '\0' , sizeof(struct SignalSemaphore) ) ;
  InitSemaphore( &SemPort ) ;

  memset( &SemSCU  , '\0' , sizeof(struct SignalSemaphore) ) ;
  InitSemaphore( &SemSCU  ) ;

  memset( &SemGFX , '\0' , sizeof(struct SignalSemaphore) ) ;
  InitSemaphore( &SemGFX  ) ;

  // allocates message port for IPC
  ParentPort = CreatePort( PARENTPORTNAME , 0 ) ;
  if ( ! ParentPort ) return( FALSE ) ;

  // creates the child task
  SPrintf( ChildName , CHILDTASKNAME , FindTask( NULL ) ) ;
  if (! CreateTask( ChildName , 5 , ChildTask , MYSTACKSIZE ))
  {
_failed:
    DeletePort( ParentPort ) ;
    ParentPort = NULL ;
    return( FALSE ) ;
  }

  // waits for startup message
  WaitPort( ParentPort ) ;
  pCmd = SafeGetMsg( ParentPort ) ;
  if ( pCmd->ic_Command == ICMD_DIE ) goto _failed ;

  SetPrgFlag( PF_CHILDTASK ) ;
  return( TRUE ) ;
}

/*************************************************************************/

void CleanupChildTask( void )

/* $DOC
 * FUNCTION
 *      Terminates the child task
 * $END
 */

{
  struct InternalCmd *pCmd ;

  if ( ! HasChildTask() ) return ;

  DoASyncIO( NULL , ICMD_DIE , NULL , 0 ) ;

  while ( pCmd = SafeGetMsg( ParentPort ) ) ;
  DeletePort( ParentPort ) ;
  ParentPort = NULL ;

  ClearPrgFlag( PF_CHILDTASK ) ;
}

