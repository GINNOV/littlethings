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
    tape.c

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 03-Nov-93
    Modified: 09-May-02
    _______________________________________________________________________
*/

#include <stdio.h>
#include "headers.h"
#include "childtask.h"

/*************************************************************************/

#define MDSENSE_DATA	12
#define SENSE_DATA	32
#define INQUIRY_DATA	36

#define TCTL_WAIT	0x01

/* SCSI commands used */
#define CMD_TEST_UNIT_READY	0x00
#define CMD_REWIND		0x01
#define CMD_REQUEST_SENSE	0x03
#define CMD_SCSI_READ		0x08
#define CMD_SCSI_WRITE		0x0A
#define CMD_INQUIRY		0x12
#define CMD_MODE_SENSE		0x1A
#define CMD_LOAD_UNLOAD 	0x1B

/* dummy SCSI commands for TapeIO() */
#define CMD_RETENSION		0x80
#define CMD_EJECT		0x81

/* Results of TapeSense() */
#define SENSE_NOSENSE		0x00
#define SENSE_RECOVERED 	0x01
#define SENSE_NOTREADY		0x02
#define SENSE_MEDIUMERROR	0x03
#define SENSE_HARDWERROR	0x04
#define SENSE_ILLEGALREQ	0x05
#define SENSE_UNITATTN		0x06
#define SENSE_DATAPROTECTED	0x07
#define SENSE_CMDABORTED	0x0B
#define SENSE_VOLUMEOVF 	0x0D
#define SENSE_FILEMARK		0x10
#define SENSE_ENDOFTAPE 	0x11
#define SENSE_ILLEGALLEN	0x12
#define SENSE_SCSIERR		0x13

static int TapeErrMsg[] =
{
  SENSE_RECOVERED    , MSG_TAPE_SENSE_01,
  SENSE_NOTREADY     , MSG_TAPE_SENSE_02,
  SENSE_MEDIUMERROR  , MSG_TAPE_SENSE_03,
  SENSE_HARDWERROR   , MSG_TAPE_SENSE_04,
  SENSE_ILLEGALREQ   , MSG_TAPE_SENSE_05,
  SENSE_UNITATTN     , MSG_TAPE_SENSE_06,
  SENSE_DATAPROTECTED, MSG_TAPE_SENSE_07,
  SENSE_CMDABORTED   , MSG_TAPE_SENSE_0B,
  SENSE_VOLUMEOVF    , MSG_TAPE_SENSE_0D,
  0		     , MSG_ERROR_SCSI_SENSE
} ;

/* result of CMD_INQUIRY */
#define PDT_DIRECTACCESS	0x00
#define PDT_SEQUENTIAL		0x01

static BYTE tmp[MAXSTR+1], aux[MAXSTR+1] ;

/*************************************************************************/

/* standard SCSI command buffer */

struct ScsiCmdBuf
{
  UBYTE opcode ;		// operation code
  UBYTE lun ;			// logical unit number (bits 7,6,5)
				// logical block address (bits 4-0)
  UWORD lba ;			// logical block address (16 bits)
  UBYTE length ;		// transfert length (or flag for LOAD_UNLOAD)
  UBYTE control ;		// control byte (usually zero)
} ;

#define LOAD_UNLOAD		0x00	// eject
#define LOAD_LOAD		0x01	// load
#define LOAD_RETENSION		0x02	// retension

/* result of CMD_REQUEST_SENSE */

struct ScsiExtSenseData
{
  UBYTE error ; 		// error class and code
  UBYTE segment ;		// segment number
  UBYTE key ;			// sense key and special bits
} ;

#define SESD_ERRORMASK		0x7F	// for error
#define SESD_EXTENDEDDATA	0x70

#define SESD_FILEMARK		0x80	// for key
#define SESD_ENDOFMEDIUM	0x40
#define SESD_ILLEGALLEN 	0x20
#define SESD_KEYMASK		0x0F

/* result of CMD_MODE_SENSE */

struct smsd_bdesc
{
  UBYTE density ;		// medium density
  UBYTE nobh,nobm,nobl ;	// number of blocks (24 bits)
  UBYTE reserved ;
  UBYTE blh,blm,bll ;		// block length (24 bits)
} ;

struct ScsiModeSenseData
{
  UBYTE length ;		// length of returned data
  UBYTE mtype ; 		// medium type
  UBYTE wprotect ;		// bit 7 set if write protected
  UBYTE bdlen ; 		// size of bdesc array
  struct smsd_bdesc bdesc[0] ;	// block descr. start here
} ;

#define SMSD_WRITEPROTECTED	0x80

/*************************************************************************/

static LONG TapeIO( struct ArcUnit *pUnit , LONG Cmd , LONG Mode )

/* $DOC
 * FUNCTION
 *	Low-level access to tape
 * INPUTS
 *	pUnit  = pointer to a structure returned by OpenTape()
 *	Cmd    = SCSI command
 *	Mode   = must be set to TCTL_WAIT (synchronous operations)
 * OUTPUTS
 *	Result = 0 if ok, or error code
 * $END
 */

{
  UWORD Block, BCount ;
  struct SCSICmd  *pCmd ;
  struct IOStdReq *pReq ;
  struct ScsiCmdBuf cbuf ;

  // set the device request

  pCmd = &(pUnit->au_SCSICmd) ;
  pCmd->scsi_Command   = (UBYTE *)&cbuf ;
  pCmd->scsi_CmdLength = sizeof(struct ScsiCmdBuf) ;
  pCmd->scsi_Status    = 0 ;
  pCmd->scsi_Actual    = 0 ;
  pCmd->scsi_Flags     = SCSIF_READ ;

  pReq = &(pUnit->au_IOReq->iotd_Req) ;
  pReq->io_Data    = (APTR)pCmd ;
  pReq->io_Length  = sizeof(struct SCSICmd) ;
  pReq->io_Error   = 0 ;

  // build the SCSI command

  memset( &cbuf , '\0' , sizeof(cbuf) ) ;
  cbuf.opcode = (UBYTE)Cmd ;
  cbuf.lun    = pUnit->au_Lun ;

  switch ( Cmd )
  {
    case CMD_REQUEST_SENSE :

      memset( pUnit->au_Inquiry , '\0' , SENSE_DATA ) ;
      cbuf.length = SENSE_DATA ; /* extended sense */
      pCmd->scsi_Length = SENSE_DATA ;
      pCmd->scsi_Data	= (UWORD *)pUnit->au_Inquiry ;
      break ;

    case CMD_INQUIRY :

      cbuf.length = INQUIRY_DATA ;
      pCmd->scsi_Length = INQUIRY_DATA ;
      pCmd->scsi_Data	= (UWORD *)pUnit->au_Inquiry ;
      break ;

    case CMD_MODE_SENSE :

      memset( pUnit->au_Inquiry , '\0' , MDSENSE_DATA ) ;
      cbuf.length = MDSENSE_DATA ;
      pCmd->scsi_Length = MDSENSE_DATA ;
      pCmd->scsi_Data	= (UWORD *)pUnit->au_Inquiry ;
      break ;

    case CMD_SCSI_WRITE :

      Block   = ( pUnit->au_CurPos - pCmd->scsi_Length ) / pUnit->au_BlockSize ;
      BCount  = pCmd->scsi_Length / pUnit->au_BlockSize ;

      cbuf.lun	 |= (UBYTE)((Block >> 16) & 0x1f) ;
      cbuf.lba	  = (UWORD)(Block & 0xffff) ;
      cbuf.length = (UBYTE)(BCount & 0xff) ;

      pCmd->scsi_Length = RoundToSector( pCmd->scsi_Length ) ;
      pCmd->scsi_Data	= (UWORD *)pUnit->au_Buffer ;
      pCmd->scsi_Flags	= SCSIF_WRITE;
      break ;

    case CMD_SCSI_READ :

      Block   = pUnit->au_CurPos / pUnit->au_BlockSize ;
      BCount  = pCmd->scsi_Length / pUnit->au_BlockSize ;

      cbuf.lun	 |= (UBYTE)((Block >> 16) & 0x1f) ;
      cbuf.lba	  = (UWORD)(Block & 0xffff) ;
      cbuf.length = (UBYTE)(BCount & 0xff) ;

      pCmd->scsi_Length = RoundToSector( pCmd->scsi_Length ) ;
      pCmd->scsi_Data = (UWORD *)pUnit->au_Buffer ;
      break ;

    case CMD_RETENSION :

      cbuf.opcode = (UBYTE)CMD_LOAD_UNLOAD ;
      cbuf.length = LOAD_RETENSION|LOAD_LOAD ;
      break ;

    case CMD_EJECT :

      cbuf.opcode = (UBYTE)CMD_LOAD_UNLOAD ;
      cbuf.length = LOAD_UNLOAD ;
      break ;

    case CMD_REWIND :
    case CMD_TEST_UNIT_READY :

      break ;
  }

{
static char msg[256];
sprintf( msg , "SCSI cmd %02x (%02x %04x %02x %02x)\n" ,
  cbuf.opcode , cbuf.lun , cbuf.lba , cbuf.length , cbuf.control ) ;
Write( Output() , msg , strlen(msg) ) ;
}

  if ( Mode == TCTL_WAIT ) MyDoIO( pUnit , HD_SCSICMD ) ;
  return( pUnit->au_LastErr ) ;
}

/*************************************************************************/

static LONG TapeSense( struct ArcUnit *pUnit , LONG ErrCode , char *pMsg )

/* $DOC
 * FUNCTION
 *	Examine an I/O error code and tells what to do
 * INPUTS
 *	pUnit	= pointer to a structure returned by OpenTape()
 *	ErrCode = error code returned by TapeIO()
 *	pMsg	= where to write the corresponding mesage
 * OUTPUTS
 *	Result = what to do
 * $END
 */

{
  int k ;
  LONG SenseKey = 0 ;
  struct ScsiExtSenseData *psd ;

  if ( (! ErrCode) || (ErrCode == HFERR_BadStatus) )
  {
    TapeIO( pUnit , CMD_REQUEST_SENSE, TCTL_WAIT ) ;
    psd = (struct ScsiExtSenseData *)pUnit->au_Inquiry ;

{
static char msg[256];
sprintf( msg , "sense data: error %02x, key = %02x, asc = %02x, ascq = %02x\n" ,
  psd->error , psd->key , pUnit->au_Inquiry[12] , pUnit->au_Inquiry[13] ) ;
Write( Output() , msg , strlen(msg) ) ;
}

    if ( (psd->error & SESD_ERRORMASK) == SESD_EXTENDEDDATA )
    {
	   if ( psd->key & SESD_FILEMARK    ) SenseKey = SENSE_ILLEGALLEN ;
      else if ( psd->key & SESD_ENDOFMEDIUM ) SenseKey = SENSE_FILEMARK ;
      else if ( psd->key & SESD_ILLEGALLEN  ) SenseKey = SENSE_ENDOFTAPE ;

      if ( ! SenseKey ) SenseKey = psd->key & SESD_KEYMASK ;
    }
    else SenseKey = psd->error & SESD_KEYMASK ; // non extended sense data

    if ( SenseKey == SENSE_ENDOFTAPE )
    {
      strcpy( pMsg , GetStr( MSG_TAPE_END_REACHED ) ) ;
      SetPrgFlag( PF_BREAKED ) ;
    }
    else
    {
      for ( k = 0 ; TapeErrMsg[k] != 0 ; k += 2 )
	if ( TapeErrMsg[k] == SenseKey ) break ;

      SPrintf( pMsg , GetStr( TapeErrMsg[k+1] ) , SenseKey ) ;
    }

    return( SenseKey ) ;
  }

  if ( (ErrCode >= 40) && (ErrCode <= 45) )
    SPrintf( pMsg , GetStr( MSG_ERROR_SCSI_ERROR ) , ErrCode - 40 ) ;
  else
    SPrintf( pMsg , GetStr( MSG_ERROR_SCSI_DRIVER ) , ErrCode ) ;

  return( SENSE_SCSIERR ) ;
}

/*************************************************************************/

BOOL ReadTape( struct ArcUnit *pUnit , BYTE *pData , LONG Len )

/* $DOC
 * FUNCTION
 *	Reads data from a tape
 * INPUTS
 *	pUnit = pointer to the tape unit
 *	pData = pointer to the buffer where to put data
 *	Len = number of data bytes to read
 * OUTPUTS
 *	Result = success/failure
 * $END
 */

{
  LONG ToCopy, ToRead, k ;

  if ( pUnit->au_Type != AUT_TAPE ) return( TRUE ) ;

  while ( Len > 0 )
  {
    ToCopy = MIN( Len , pUnit->au_CylSize ) ;

    ToRead = RoundToSector( ToCopy ) ;
    pUnit->au_SCSICmd.scsi_Length = ToRead ;
    if ( k = TapeIO( pUnit , CMD_SCSI_READ , TCTL_WAIT ) )
    {
      TapeSense( pUnit , k , tmp ) ;
      SPrintf( aux , GetStr( MSG_TAPE_READ_FAILED ) , ToRead , tmp ) ;
      ABackupAlert( NULL , aux ) ;
      return( FALSE ) ;
    }
    pUnit->au_CurPos += ToRead ;

    memcpy( pData , pUnit->au_Buffer , ToCopy ) ;
    pData += ToCopy ;
    Len -= ToCopy ;
  }

  return( TRUE ) ;
}

/*************************************************************************/

BOOL FlushTape( struct ArcUnit *pUnit )

/* $DOC
 * FUNCTION
 *	Flushes the data buffer of a tape unit.
 * INPUTS
 *	pUnit = pointer to unit to flush
 * OUTPUTS
 *	Result = success/failure
 * $END
 */

{
  LONG Pos, Len ;

  if ( pUnit->au_Type != AUT_TAPE ) return( TRUE ) ;
  if ( ! DevIsToUpdate( pUnit ) )   return( TRUE ) ;

  /* clear end of buffer if unused */
  Pos = pUnit->au_CurPos % pUnit->au_CylSize ;
  Len = pUnit->au_CylSize - Pos ;
  if ( Pos && (Len > 0) ) memset( &pUnit->au_Buffer[Pos] , '\0' , (size_t)Len ) ;

  /* write data */
  if ( ! Pos ) Pos = pUnit->au_CylSize ;
  Len = RoundToSector( Pos ) ;
  pUnit->au_SCSICmd.scsi_Length = Len ;
  Pos = TapeIO( pUnit , CMD_SCSI_WRITE , TCTL_WAIT ) ;
  ClearUnitFlag( pUnit , AUF_BUFFLUSH ) ;

  if ( Pos )
  {
    TapeSense( pUnit , Pos , tmp ) ;
    SPrintf( aux , GetStr( MSG_TAPE_WRITE_FAILED ) , Len , tmp ) ;
    ABackupAlert( NULL , aux ) ;
    return( FALSE ) ;
  }

  pUnit->au_CurPos = RoundToSector( pUnit->au_CurPos ) ;
  return( TRUE ) ;
}

/*************************************************************************/

BOOL WriteTape( struct ArcUnit *pUnit , BYTE *pData , LONG Len )

/* $DOC
 * FUNCTION
 *	Writes data to a tape
 * INPUTS
 *	pUnit = pointer to the tape unit
 *	pData = pointer to the buffer which contains data to write
 *	Len = number of data bytes to write
 * OUTPUTS
 *	Result = success/failure
 * $END
 */

{
  LONG ToCopy, Pos, Left ;

  if ( pUnit->au_Type != AUT_TAPE ) return( TRUE ) ;

  while ( Len > 0 )
  {
    Pos  = pUnit->au_CurPos % pUnit->au_CylSize ;
    Left = pUnit->au_CylSize - Pos ;

    if ( ToCopy = MIN( Len , Left ) )
    {
      memcpy( &pUnit->au_Buffer[Pos] , pData , ToCopy ) ;
      SetUnitFlag( pUnit , AUF_BUFFLUSH ) ;
      pUnit->au_CurPos += ToCopy ;
    }

    if ( (ToCopy == Left) && (! FlushTape( pUnit )) ) return( FALSE ) ;

    pData += ToCopy ;
    Len -= ToCopy ;
  }

  return( TRUE ) ;
}

/*************************************************************************/

void RewindTape( struct ArcUnit *pUnit )

/* $DOC
 * FUNCTION
 *	Rewind to the beginning of the tape
 * INPUTS
 *	pUnit = pointer to the tape unit
 * $END
 */

{
  LONG k ;
  struct DosEnvec *pEnv ;

  k = TapeIO( pUnit , CMD_REWIND , TCTL_WAIT ) ;
  if ( k ) TapeSense( pUnit , k , tmp ) ;

  /* compute "true" cylinder size (not the same as pUnit->au_CylSize !) */
  pEnv = (struct DosEnvec *)&(pUnit->au_DeviceDef->dd_Env) ;
  k  = pEnv->de_Surfaces * pEnv->de_BlocksPerTrack * pEnv->de_SizeBlock * 4 ;

  /* compute begining of tape address */
  pUnit->au_CurPos = (pEnv->de_LowCyl * k) + (pUnit->au_BlockSize * pEnv->de_Reserved) ;

{
char msg[256];
sprintf(msg,"REWIND: %d (lowcyl %d, reserved %d)\n" , pUnit->au_CurPos , pEnv->de_LowCyl , pEnv->de_Reserved ) ;
Write( Output() , msg , strlen(msg) ) ;
}
}

/*************************************************************************/

BOOL CloseTape( struct ArcUnit *pUnit )

/* $DOC
 *	Closes a tape unit and free the corresponding structure
 * INPUTS
 *	pUnit = pointer to the tape unit
 * OUTPUTS
 *	Result = success/failure
 * NOTES
 *	The unit structure is freed by this function so don't use pUnit after,
 *	even if FALSE is returned.
 * $END
 */

{
  BOOL Ret = TRUE ;

  if ( pUnit->au_Type != AUT_TAPE ) return( TRUE ) ;

  if ( DevIsOpened( pUnit ) )
  {
    if ( DevIsToUpdate( pUnit ) ) Ret = FlushTape( pUnit ) ;
    if ( IS_TFL_REWIND )
    {
      if ( NewID == WIN_MONITOR )
	MonitorPrint( MP_POS1 , GetStr( MSG_TAPE_REWINDING ) , MPF_LINEFEED ) ;
      RewindTape( pUnit ) ;
    }
    if ( IS_TFL_EJECT  ) TapeIO( pUnit , CMD_EJECT , TCTL_WAIT ) ;
  }

  DoCloseDev( pUnit ) ;
  if ( pUnit->au_Buffer )       FreeObject( pUnit->au_Buffer ) ;
  if ( pUnit->au_DeviceDef )    FreeObject( pUnit->au_DeviceDef ) ;

  FreeObject( pUnit ) ;
  return( Ret ) ;
}

/*************************************************************************/

static LONG TestTapeStatus( struct ArcUnit *pUnit , LONG k )

/* $DOC
 * FUNCTION
 *	Test return status after a CMD_TEST_UNIT_READY or CMD_MDSENSE command
 * INPUTS
 *	pUnit = pointer to the tape unit
 *	k = status
 * OUTPUT
 *	Result = 0 if tape ok, 1 if must retry, -1 if unit closed
 * $END
 */

{
  k = TapeSense( pUnit , k , tmp ) ;

  if ( k == SENSE_NOSENSE    ) return( 0 ) ;
  if ( k == SENSE_UNITATTN   ) return( 0 ) ;
  if ( k == SENSE_ILLEGALREQ ) return( 0 ) ;

  if ( (FULLBATCHMODE) ||
       (! YesNoRequest( GetStr( MSG_REQ_TAPE_NOT_READY ) , NULL , MSG_REQ_RETRY_CANCEL , NULL )) )
  {
    CloseTape( pUnit ) ;
    return( -1 ) ;
  }

  return( 1 ) ;
}

/*************************************************************************/

struct ArcUnit *OpenTape( LONG Mode )

/* $DOC
 * FUNCTION
 *	Opens a tape
 * INPUTS
 *	Mode  = OAF_READ or OAF_WRITE
 * OUTPUTS
 *	Result = pointer to an ArcUnit structure
 *		 NULL if failed
 *		   -1 if aborted by user
 * NOTES
 *	All needed memory (buffers etc...) is allocated in CHIP memory
 * $END
 */

{
  LONG k ;
  UBYTE Lun ;
  struct ArcUnit *pUnit ;
  struct DeviceDef *pDef ;
  struct ScsiModeSenseData *pmsd ;

  /* allocate the ArcUnit structure */

  pUnit = AllocObject( ABO_ARCUNIT , GetStr( MSG_TAPE_NAME ) ) ;
  if ( ! pUnit ) return( NULL ) ;

  /* allocate a dummy DeviceDef structure */

  pDef = AllocObject( ABO_DEVICEDEF , PRF_DEVICEDRIVER ) ;
  if ( ! pDef )
  {
    CloseTape( pUnit ) ;
    return( NULL ) ;
  }
  pDef->dd_Unit = PRF_SCSIPORT ;
  pDef->dd_Env.de_BufMemType = IS_TFL_FASTBUFFER ? 0 : BMT_CHIP ;

  /* initialize the ArcUnit structure */

  pUnit->au_Type      = AUT_TAPE ;
  pUnit->au_BlockSize = PRF_BLOCKSIZE ;
  pUnit->au_DeviceDef = pDef ;

  Lun = (UBYTE)pDef->dd_Unit ;
  pUnit->au_Lun = ((Lun / 10 - (Lun / 100) * 10) & 7) << 5 ;

  /* open i/o ressources for access */

  if ( ! DoOpenDev( pUnit , pDef ) )
  {
    CloseTape( pUnit ) ;
    return( NULL ) ;
  }

  /* check device type */

  if ( k = TapeIO( pUnit , CMD_INQUIRY , TCTL_WAIT ) )
  {
    TapeSense( pUnit , k , tmp ) ;
    SPrintf( aux , GetStr( MSG_TAPE_INQUIRY_FAILED ) , tmp ) ;
    ABackupAlert( NULL , aux ) ;
    CloseTape( pUnit ) ;
    return( NULL ) ;
  }

  if ( pUnit->au_Inquiry[0] == PDT_SEQUENTIAL )
  {
    pDef->dd_Env.de_Reserved = 0 ;
  }
  else if ( pUnit->au_Inquiry[0] == PDT_DIRECTACCESS )
  {
    SetUnitFlag( pUnit , AUF_DACTAPE ) ;
  }
  else
  {
    SPrintf( tmp , GetStr( MSG_UNIT_NAME ) , pDef->dd_Unit , pDef->dd_Name ) ;
    HandleError( tmp , ABERR_NOT_A_TAPE ) ;
    CloseTape( pUnit ) ;
    return( NULL ) ;
  }

  /* examine tape */

  FOREVER
  {
    /* check if device is ready */
    do
      if ( k = TapeIO( pUnit , CMD_TEST_UNIT_READY , TCTL_WAIT ) )
      {
_retry:
	k = TestTapeStatus( pUnit , k ) ;
	if ( k == -1 ) return( NULL ) ;
      }
    while ( k ) ;

    /* get device info */
    if ( k = TapeIO( pUnit , CMD_MODE_SENSE , TCTL_WAIT ) ) goto _retry ;
    pmsd = (struct ScsiModeSenseData *)pUnit->au_Inquiry ;

    if ( Mode == OAF_READ ) break ;
    if (! (pmsd->wprotect & SMSD_WRITEPROTECTED)) break ;

    if ( (FULLBATCHMODE) ||
	 (! YesNoRequest( GetStr( MSG_TAPE_PROTECTED ) , NULL , MSG_REQ_RETRY_CANCEL , NULL )) )
    {
      CloseTape( pUnit ) ;
      return( (struct ArcUnit *)-1 ) ;
    }
  }

  /* check block size */

  if ( pmsd->bdlen >= sizeof(struct smsd_bdesc) )
  {
    k =  pmsd->bdesc[0].bll +
	(pmsd->bdesc[0].blm << 8) +
	(pmsd->bdesc[0].blh << 16) ;

    if ( (pUnit->au_BlockSize != k) && (k >= 512) )
    {
      pUnit->au_BlockSize = k ;
      if (! FULLBATCHMODE) YesNoRequest( GetStr( MSG_TAPE_BSIZE_CHANGED ) , (STRPTR)k , MSG_REQ_OK , NULL ) ;
    }
  }

  /* allocate buffer */

  pUnit->au_CylSize = ( KBYTES(PRF_BUFSIZE) / pUnit->au_BlockSize ) * pUnit->au_BlockSize ;
  pUnit->au_Buffer  = AllocObject( ABO_DEVBUFFER , pUnit ) ;
  if ( ! pUnit->au_Buffer )
  {
    CloseTape( pUnit ) ;
    return( NULL ) ;
  }

  /* check for overwriting tape */

  if ( (Mode == OAF_WRITE) &&
       (! FULLBATCHMODE)   &&
       (! YesNoRequest( GetStr( MSG_REQ_OVERWRITE_TAPE ) , NULL , MSG_REQ_CONTINUE_ABORT , NULL )) )
  {
    CloseTape( pUnit ) ;
    return( (struct ArcUnit *)-1 ) ;
  }

  /* rewind tape before access */

  if ( HasInterface() )
  {
    if ( NewID == WIN_LOADTREE )
      SetGad( GD_LoadTree , GTTX_Text, (ULONG)GetStr( MSG_TAPE_REWINDING ) ) ;
    else
      MonitorPrint( MP_POS1 , GetStr( MSG_TAPE_REWINDING ) , MPF_LINEFEED ) ;
  }
  if ( IS_TFL_RETENTION ) TapeIO( pUnit , CMD_RETENSION , TCTL_WAIT ) ;
  RewindTape( pUnit ) ;

  return( pUnit ) ;
}

