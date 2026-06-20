/****h* TimeSerial.c [3.0] **********************************************
*
* NAME
*    TimedSerial.c
*
* DESCRIPTION
*    This file contains the code to issue serial commands
*    that will time-out if there is no response from the
*    PC at the other end of the serial link.
*
* HISTORY
*    28-Oct-2004 - Added AmigaOS4 & gcc support.
*
*    28-Dec-2002 - Added ResetBuffer() to ReadString().
* 
*    25-Dec-2002 - Added a boolean flag to each function that
*                  uses the timer in order to control whether
*                  the timer uses microseconds or seconds.
*                  Also modified the TranslateErrorNumber
*                  function to return a string with incorrect
*                  error number values.
*
*    28-Sep-2000 - Added the serName parameter to the OpenSerial()
*                  function. 
*    30-Dec-1998 - Added GetErrNum() & GetSerialStatus();
*    06-Nov-1996 - Created.
*
* WARNINGS
*    These functions have NOT been tested thoroughly, but they
*    are guaranteed to time out, so your system won't freeze if
*    you use them!
*
* NOTES
*    The following functions are available to the User:
*
*    VISIBLE int   GetErrNum( void );
*    VISIBLE int   GetSerialStatus( void );
*    VISIBLE void  TimerDelay( int delayseconds, BOOL useMicrosFlag );
*    VISIBLE int   TestTimer( void );
*    VISIBLE char *TranslateErrorNumber( int errnum );
*
*    VISIBLE int   OpenSerial( char *serName,
*                              int   unit, 
*                              int   HowLong, 
*                              int   buffersize,
*                              int   flags
*                            ); 
*
*    VISIBLE void  CloseSerial( void );
*
*    VISIBLE char  *ReadString( int timeout, BOOL microFlag, int strsize );
*    VISIBLE UBYTE  ReadChar(   int timeout, BOOL microFlag              );
*
*    VISIBLE int WriteString( int timeout, BOOL microFlag, char *string, int strsize );
*    VISIBLE int WriteChar(   int timeout, BOOL microFlag, int   ch                  );
*
*    VISIBLE int ResetSerial( int timeout, BOOL microFlag );
*    VISIBLE int ClearSerial( int timeout, BOOL microFlag );
*    VISIBLE int FlushSerial( int timeout, BOOL microFlag );
*    VISIBLE int StopSerial(  int timeout, BOOL microFlag );
*    VISIBLE int StartSerial( int timeout, BOOL microFlag );
*    VISIBLE int QuerySerial( int timeout, BOOL microFlag );
*
*    VISIBLE int BreakSerial( int timeout, BOOL microFlag, int duration );
*    VISIBLE int SetSerialParams( int timeout, BOOL microFlag, int which, int params );
*
* $VER: TimedSerial.c 3.0 (28-Oct-2004) by J.T. Steichen
************************************************************************
*
*/

#include <stdio.h>
#include <string.h>

#include <exec/types.h>
#include <exec/memory.h>
#include <exec/io.h>

#include <devices/timer.h>
#include <devices/serial.h>

#include <dos/dos.h>

#ifndef  PRIVATE         // storage types to increase readability.
# define PRIVATE static  
# define IMPORT  extern
# define PUBLIC
# define VISIBLE
#endif

#ifndef __amigaos4__

# include <clib/exec_protos.h>
# include <clib/dos_protos.h>

#else

# define __USE_INLINE__

# include <proto/dos.h>
# include <proto/exec.h>

IMPORT struct ExecIFace *IExec;

PRIVATE struct Library    *TimerBase;
PRIVATE struct TimerIFace *ITimer;

#endif // __amigaos4__

#define    ALLOCATE       1
# include "TimedSerial.h"
#undef     ALLOCATE

// Misc' ERROR return values:

#define TIMER_TIMEDOUT    -2
#define BREAKSIGNAL_GIVEN -3

// -------------------------------------------------------------------

#ifndef __amigaos4__

IMPORT struct MsgPort *CreatePort( char *, ULONG );

IMPORT void DeletePort( struct MsgPort * );

#endif

// -------------------------------------------------------------------

PRIVATE int                 ErrorNumber = 0;

PRIVATE struct timerequest *SerTimer    = NULL;
PRIVATE struct MsgPort     *TimerPort   = NULL;

// -------------------------------------------------------------------

/****h* GetErrNum() [1.1] **********************************************
*
* NAME
*    GetErrNum()
*
* SYNOPSIS
*    int errnum = GetErrNum( void );
*
* DESCRIPTION
*    Return the value that the internal ErrorNumber variable is set at.
************************************************************************
*
*/

PUBLIC int GetErrNum( void ) { return( ErrorNumber ); }

/****i* SetupTimer() [1.1] *********************************************
*
* NAME
*    SetupTimer()
*
* DESCRIPTION
*    Initialize the timer's Port & Open the device.
************************************************************************
*
*/

PRIVATE int SetupTimer( int HowLong )
{
#  ifndef __amigaos4__
   if (!(TimerPort = (struct MsgPort *) CreatePort( "serial.timer", 0 ))) == NULL)
      return( -1 );

   if ((SerTimer = (struct timerequest *) 
                   AllocVec( sizeof( struct timerequest ), 
                             MEMF_CLEAR | MEMF_ANY )) == NULL)
      {
      DeletePort( TimerPort );

      return( -2 );
      }

   SerTimer->tr_node.io_Message.mn_Node.ln_Type = NT_MESSAGE;
   SerTimer->tr_node.io_Message.mn_Node.ln_Pri  = 0;
   SerTimer->tr_node.io_Message.mn_ReplyPort    = TimerPort;

#  else

   if (!(TimerPort = AllocSysObjectTags( ASOT_PORT, ASOPORT_Name, "serial.timer", TAG_DONE ))) // == NULL)
      return( -1 );
      
   if (!(SerTimer = AllocSysObjectTags( ASOT_IOREQUEST, ASOIOR_Size,      sizeof( struct timerequest ),
                                                        ASOIOR_ReplyPort, TimerPort, 
							TAG_DONE ))) // == NULL)
      {
      FreeSysObject( ASOT_PORT, TimerPort );
      
      return( -2 );
      }
#  endif


   if (OpenDevice( TIMERNAME, UNIT_VBLANK, (struct IORequest *) SerTimer, 0 ) != 0)
      {
#     ifndef __amigaos4__
      FreeVec(    SerTimer  );
      DeletePort( TimerPort );
#     else
      FreeSysObject( ASOT_IOREQUEST, SerTimer  );
      FreeSysObject( ASOT_PORT,      TimerPort );
#     endif

      return( -3 );
      }

#  ifdef __amigaos4__
   TimerBase = (struct Library *) SerTimer->tr_node.io_Device;
   
   if (!(ITimer = (struct TimerIFace *) GetInterface( TimerBase, "main", 1, NULL ))) // == NULL)
      {
      CloseDevice( (struct IORequest *) SerTimer );
      
      TimerBase = (struct Library *) NULL;
            
      FreeSysObject( ASOT_IOREQUEST, SerTimer  );
      FreeSysObject( ASOT_PORT,      TimerPort );

      SerTimer  = (struct timerequest *) NULL;
      TimerPort = (struct MsgPort     *) NULL;

      return( -4 );
      }
#endif
   
   TimeValue = HowLong;

   return 0;
}

/****i* CloseTimer() [1.1] *******************************************
*
* NAME
*    CloseTimer()
*
* DESCRIPTION
*    Close the Timer & Serial devices & Free memory allocated.  
**********************************************************************
*
*/

PRIVATE void CloseTimer( void )
{
#  ifndef __amigaos4__
   CloseDevice( (struct IORequest *) SerTimer );

   DeletePort( SerTimer->tr_node.io_Message.mn_ReplyPort );

   SerTimer->tr_node.io_Message.mn_Node.ln_Type = 0xFF;
   SerTimer->tr_node.io_Device                  = (struct Device *) NULL;
   SerTimer->tr_node.io_Unit                    = (struct Unit   *) NULL;

   FreeVec( SerTimer );
#  else
   if (!CheckIO( (struct IORequest *) SerTimer ))
      AbortIO(   (struct IORequest *) SerTimer );

   WaitIO( (struct IORequest *) SerTimer );
      
   DropInterface( (struct Interface *) ITimer    );
   CloseDevice(   (struct IORequest *) SerTimer  );
   FreeSysObject(  ASOT_IOREQUEST,     SerTimer  );
   FreeSysObject(  ASOT_PORT,          TimerPort ); 
   
   ITimer    = (struct TimerIFace *) NULL;
   TimerBase = (struct Library    *) NULL;
#  endif

   SerTimer  = NULL;
   TimerPort = NULL;
   TimeValue = 0;

   return;
}

/****i* StartTimer() [2.0] ******************************************
*
* NAME
*    StartTimer()
*
* DESCRIPTION
*    Tell the timeout timer to begin timing the serial device.
*********************************************************************
*
*/

PRIVATE void StartTimer( int interval, BOOL useMicrosFlag )
{
   TimedOut  = FALSE;
   TimeValue = interval;

   if (useMicrosFlag == TRUE)
      SerTimer->tr_time.tv_micro = interval;
   else
      SerTimer->tr_time.tv_secs = interval;

   SerTimer->tr_node.io_Command = TR_ADDREQUEST;

   SendIO( (struct IORequest *) SerTimer );

   return;
}

/****i* KillTimer() [1.1] *******************************************
*
* NAME
*    KillTimer()
*
* DESCRIPTION
*    Stop the Serial timeout timer 
*
* NOTES
*    CloseTimer() still has to be called in order to shut down
*    completely!
*********************************************************************
*
*/

PRIVATE void KillTimer( void )
{
   AbortIO( (struct IORequest *) SerTimer );

   (void) GetMsg( SerTimer->tr_node.io_Message.mn_ReplyPort );

   return;
}

/****h* TimerDelay() [2.0] ******************************************
*
* NAME
*    TimerDelay()
*
* DESCRIPTION
*    Start the Serial timeout timer & wait for it to time-out.
*********************************************************************
*
*/

VISIBLE void TimerDelay( int delayseconds, BOOL useMicrosFlag )
{
   StartTimer( delayseconds, useMicrosFlag );

   Wait( 1L << SerTimer->tr_node.io_Message.mn_ReplyPort->mp_SigBit );

   (void) GetMsg( SerTimer->tr_node.io_Message.mn_ReplyPort );

   return;
}

/****h* TestTimer() [1.1] *******************************************
*
* NAME
*    TestTimer()
*
* DESCRIPTION
*    Return any timer error values (zero means NO ERROR).
*********************************************************************
*
*/

VISIBLE int TestTimer( void )
{
   return( CheckIO( (struct IORequest *) SerTimer ) 
           && ( !SerTimer->tr_node.io_Error) );
}

/****h* TranslateErrorNumber() [2.0] ********************************
*
* NAME
*    TranslateErrorNumber()
*
* DESCRIPTION
*    Return a string corresponding to the given error number.
*********************************************************************
*
*/

PRIVATE char *SerErrors[] = {

   "No serial error.",    
   "Device is Busy.",
   "Baud rate NOT supported by hardware.",
   "Unknown error number.",
   "Failed to allocate new read buffer.",
   "Bad parameter.",
   "Hardware data overrun!",
   "Unknown error number.",
   "Unknown error number.",
   "Parity ERROR.",
   "Unknown error number.",
   "Timeout (if using 7-wire handshaking).",
   "Read buffer overflowed.",
   "No Data Set ready.",
   "Unknown error number.",
   "Break detected.",
   "Selected unit already in use.",
   NULL
};

PRIVATE char tErr[32] = "";

VISIBLE char *TranslateErrorNumber( int errnum )
{
   if (errnum < 17 && errnum >= 0 )
      return( SerErrors[ errnum ] );
   else
      {
      sprintf( tErr, "Bad Error Number: 0x%08LX", errnum );
      
      return( tErr );
      }
}

/****h* OpenSerial() [1.1] ******************************************
*
* NAME
*    OpenSerial()
*
* SYNOPSIS
*    int success = OpenSerial( char *serName,    // Name of Serial device
*                              int   unit,       // Serial Unit #
*                              int   HowLong,    // Timeout delay
*                              int   buffersize, // Serial buffer size
*                              int   flags       // SerialIO Flags
*                            );
*
* DESCRIPTION
*    Initialize & Open the Serial & timer devices.
*********************************************************************
*
*/

VISIBLE int OpenSerial( char *sername, 
                        int   unit, 
                        int   HowLong, 
                        int   buffersize, 
                        int   flags
                      ) 
{
   ULONG    readbit, writebit, timebit;
   
   if (!(ReadRequest = (struct IOExtSer *) AllocVec( sizeof( struct IOExtSer ), 
                                                     MEMF_CLEAR | MEMF_PUBLIC ))) // == NULL)   
      return( -1 );
      
   if (!(ReadBuffer = (char *) AllocVec( buffersize, MEMF_CLEAR ))) // == NULL)
      {
      FreeVec( ReadRequest );

      return( -2 );
      }

   ReadSize                 = buffersize;
   ReadRequest->io_SerFlags = flags; // SERF_SHARED | SERF_XDISABLED;

   if (!(ReadRequest->IOSer.io_Message.mn_ReplyPort = CreatePort( "serial.read", 0 ))) // == NULL)
      {
      FreeVec( ReadBuffer  );
      FreeVec( ReadRequest );

      return( -3 );
      }

   if (!sername) // == NULL)
      {
      if (OpenDevice( SERIALNAME, unit, (struct IORequest *) ReadRequest, 0 ) != 0)
         {
         DeletePort( ReadRequest->IOSer.io_Message.mn_ReplyPort );
         
         FreeVec( ReadBuffer  );
         FreeVec( ReadRequest );
      
         return( -4 );
         }
      }
   else
      {
      if (OpenDevice( sername, unit, (struct IORequest *) ReadRequest, 0 ) != 0)
         {
         DeletePort( ReadRequest->IOSer.io_Message.mn_ReplyPort );
         
         FreeVec( ReadBuffer  );
         FreeVec( ReadRequest );
      
         return( -4 );
         }
      }

   ReadRequest->IOSer.io_Command = CMD_READ;
   ReadRequest->IOSer.io_Length  = buffersize;
   ReadRequest->IOSer.io_Data    = (APTR) ReadBuffer;
   
   if (!(WriteRequest = (struct IOExtSer *) AllocVec( sizeof( struct IOExtSer ), 
                                                      MEMF_CLEAR | MEMF_PUBLIC ))) // == NULL)   
      {
      CloseDevice( (struct IORequest *) ReadRequest ); 
      DeletePort( ReadRequest->IOSer.io_Message.mn_ReplyPort );

      FreeVec( ReadBuffer  );
      FreeVec( ReadRequest );

      return( -5 );
      }
      
   if (!(WriteBuffer = (char *) AllocVec( buffersize, MEMF_CLEAR ))) // == NULL)
      {
      FreeVec( WriteRequest );
      
      CloseDevice( (struct IORequest *) ReadRequest ); 
      DeletePort( ReadRequest->IOSer.io_Message.mn_ReplyPort );
      
      FreeVec( ReadBuffer  );
      FreeVec( ReadRequest );
      
      return( -6 );
      }

   WriteSize                 = buffersize;
   WriteRequest->io_SerFlags = flags; // SERF_SHARED | SERF_XDISABLED;

   if (!(WriteRequest->IOSer.io_Message.mn_ReplyPort = CreatePort( "serial.write", 0 ))) // == NULL)
      {
      FreeVec( WriteBuffer  );
      FreeVec( WriteRequest );

      CloseDevice( (struct IORequest *) ReadRequest ); 
      DeletePort( ReadRequest->IOSer.io_Message.mn_ReplyPort );

      FreeVec( ReadBuffer  );
      FreeVec( ReadRequest );

      return( -7 );
      }

   if (!sername) // == NULL)
      {
      if (OpenDevice( SERIALNAME, unit, (struct IORequest *) WriteRequest, 0 ) != 0)
         {
         DeletePort( WriteRequest->IOSer.io_Message.mn_ReplyPort );

         FreeVec( WriteBuffer  );
         FreeVec( WriteRequest );

         CloseDevice( (struct IORequest *) ReadRequest ); 
         DeletePort( ReadRequest->IOSer.io_Message.mn_ReplyPort );

         FreeVec( ReadBuffer  );
         FreeVec( ReadRequest );

         return( -8 );
         }
      }
   else
      {
      if (OpenDevice( sername, unit, (struct IORequest *) WriteRequest, 0 ) != 0)
         {
         DeletePort( WriteRequest->IOSer.io_Message.mn_ReplyPort );

         FreeVec( WriteBuffer  );
         FreeVec( WriteRequest );

         CloseDevice( (struct IORequest *) ReadRequest ); 
         DeletePort( ReadRequest->IOSer.io_Message.mn_ReplyPort );

         FreeVec( ReadBuffer  );
         FreeVec( ReadRequest );

         return( -8 );
         }
      }

   WriteRequest->IOSer.io_Command = CMD_WRITE;
   WriteRequest->IOSer.io_Length  = ReadSize;
   WriteRequest->IOSer.io_Data    = (APTR) WriteBuffer;

   ReadRequest->io_SerFlags      = SERF_SHARED | SERF_XDISABLED;
   ReadRequest->io_Baud          = 9600;
   ReadRequest->io_ReadLen       = 8;
   ReadRequest->io_WriteLen      = 8;
   ReadRequest->io_RBufLen       = ReadSize;
   ReadRequest->io_CtlChar       = 1L;
   ReadRequest->IOSer.io_Command = SDCMD_SETPARAMS;

   DoIO( (struct IORequest *) ReadRequest );

   ReadRequest->IOSer.io_Command = CMD_READ;
   ErrorNumber                   = ReadRequest->IOSer.io_Error;

   readbit  = 1L << ReadRequest->IOSer.io_Message.mn_ReplyPort->mp_SigBit;
   writebit = 1L << WriteRequest->IOSer.io_Message.mn_ReplyPort->mp_SigBit;

   if (SetupTimer( HowLong ) < 0)
      {
      CloseDevice( (struct IORequest *) WriteRequest ); 
      DeletePort( WriteRequest->IOSer.io_Message.mn_ReplyPort );

      FreeVec( WriteBuffer  );
      FreeVec( WriteRequest );

      CloseDevice( (struct IORequest *) ReadRequest ); 
      DeletePort( ReadRequest->IOSer.io_Message.mn_ReplyPort );

      FreeVec( ReadBuffer  );
      FreeVec( ReadRequest );

      return( -9 );
      }

   timebit = 1L << SerTimer->tr_node.io_Message.mn_ReplyPort->mp_SigBit;

   WaitSerMask = SIGBREAKF_CTRL_C | readbit | writebit | timebit;

   return( 0 ); 
}

/****h* CloseSerial() [1.1] *****************************************
*
* NAME
*    CloseSerial()
*
* SYNOPSIS
*    void CLoseSerial( void );
*
* DESCRIPTION
*    Close the Serial & timeout timer devices, then Free the memory
*    allocated to them.
*********************************************************************
*
*/

VISIBLE void CloseSerial( void )
{
   KillTimer();
   CloseTimer();

   CloseDevice( (struct IORequest *) WriteRequest ); 
   DeletePort( WriteRequest->IOSer.io_Message.mn_ReplyPort );

   FreeVec( WriteBuffer  );
   FreeVec( WriteRequest );

   CloseDevice( (struct IORequest *) ReadRequest ); 
   DeletePort( ReadRequest->IOSer.io_Message.mn_ReplyPort );

   FreeVec( ReadBuffer  );
   FreeVec( ReadRequest );

   return;
}

PRIVATE void ResetBuffer( char *buffer, int count )
{
   int i;
   
   for (i = 0; i < count; i++)
      *(buffer + i) = '\0'; // Clean out the buffer's contents.
      
   return;
}

/****h* ReadString() [3.0] ***************************************
*
* NAME
*    ReadString()
*
* SYNOPSIS
*    char *string = ReadString( int timeout, BOOL microFlag, int strsize );
*
* DESCRIPTION
*    Read a string strsize characters long from the Serial port.
*    NULL will be returned if the timer times out or if there's
*    an error.
******************************************************************
*
*/

VISIBLE char *ReadString( int timeout, BOOL microFlag, int strsize )
{
   ULONG temp = 0L;

   KillTimer();   

   if (strsize > ReadSize)
      {
      FreeVec( ReadBuffer ); // Need a new buffer, free the old one first.

      ReadBuffer = (char *) AllocVec( strsize, MEMF_CLEAR );

      if (!ReadBuffer) // == NULL)
         {
         fprintf( stderr, "Ran out of memory!\n" );

         return( NULL );
         }

      ReadSize = strsize;
      }
   else
      ResetBuffer( ReadBuffer, ReadSize ); // Clean out old contents
       
   TimeValue = timeout;
   StartTimer( timeout, microFlag );

   ReadRequest->IOSer.io_Command = CMD_READ;
   ReadRequest->IOSer.io_Length  = strsize;
   ReadRequest->IOSer.io_Data    = (APTR) ReadBuffer;
 
   SendIO( (struct IORequest *) ReadRequest ); // Ask serial port for input.

   while (1) // Wait for input or the timer timing out
      {
      temp = Wait( WaitSerMask );

      if ((SIGBREAKF_CTRL_C & temp) == SIGBREAKF_CTRL_C)
         {
         TimedOut = FALSE;

         break;
         }

      if (CheckIO( (struct IORequest *) ReadRequest ))
         {
         TimedOut = FALSE; // We beat the timer.
	 
         WaitIO( (struct IORequest *) ReadRequest );

         return( ReadBuffer );
         }
      else if (CheckIO( (struct IORequest *) SerTimer ) && ( !SerTimer->tr_node.io_Error))
         {
         TimedOut = TRUE; // Serial link timed out!

         return( NULL );
         }
      }

   AbortIO( (struct IORequest *) ReadRequest );
   WaitIO( (struct IORequest *) ReadRequest );

   ErrorNumber = ReadRequest->IOSer.io_Error;

   return( ReadBuffer );
}

/****h* ReadChar() [2.0] *****************************************
*
* NAME
*    ReadChar()
*
* SYNOPSIS
*    UBYTE ch = ReadChar( int timeout, BOOL microFlag );
*
* DESCRIPTION
*    Read a single character from the Serial port.
******************************************************************
*
*/

VISIBLE UBYTE ReadChar( int timeout, BOOL microFlag )
{
   UBYTE *rt = NULL, rval = 0;
   
   rt   = ReadString( timeout, microFlag, 1 );
   rval = *rt;

   return( rval );
}

/****h* WriteString() [2.0] **************************************
*
* NAME
*    WriteString()
*
* SYNOPSIS
*    int success = WriteString( int   timeout, 
*                               BOOL  microFlag, // use microseconds = TRUE
*                               char *string,
*                               int   strsize
*                             );
*
* DESCRIPTION
*    Write a string to the Serial Port (zero means success). 
******************************************************************
*
*/

VISIBLE int WriteString( int timeout, BOOL microFlag, char *string, int strsize )
{
   ULONG temp = 0L;
   
   KillTimer();   

   if (strsize > WriteSize)
      {
      FreeVec( WriteBuffer ); // Need a new buffer, so free the old one first.

      WriteBuffer = (char *) AllocVec( strsize, MEMF_CLEAR );

      if (!WriteBuffer) // == NULL)
         {
         fprintf( stderr, "Ran out of memory!\n" );

         return( -1 );
         }

      WriteSize = strsize;
      }

   strncpy( WriteBuffer, string, strsize ); 

   TimeValue = timeout;
   StartTimer( timeout, microFlag );

   WriteRequest->IOSer.io_Command = CMD_WRITE;
   WriteRequest->IOSer.io_Length  = strsize;
   WriteRequest->IOSer.io_Data    = (APTR) WriteBuffer;

   SendIO( (struct IORequest *) WriteRequest ); // Write the buffer to the serial port.

   ErrorNumber = WriteRequest->IOSer.io_Error;

   while (1) // wait for the IO to complete or the timer to time out:
      {
      temp = Wait( WaitSerMask );

      if ((SIGBREAKF_CTRL_C & temp) == SIGBREAKF_CTRL_C)
         {
         TimedOut = FALSE;

         break;
         }

      if (CheckIO( (struct IORequest *) WriteRequest ))
         {
         TimedOut = FALSE; // We beat the timer.
	 
         WaitIO( (struct IORequest *) WriteRequest );
      
         ErrorNumber = WriteRequest->IOSer.io_Error;

         return( RETURN_OK );
         }
      else if (CheckIO( (struct IORequest *) SerTimer ) && ( !SerTimer->tr_node.io_Error))
         {
         TimedOut = TRUE; // Serial link timed out.

         return( TIMER_TIMEDOUT );
         }
      }

   AbortIO( (struct IORequest *) WriteRequest );
   WaitIO( (struct IORequest *) WriteRequest );

   ErrorNumber = WriteRequest->IOSer.io_Error;

   return( BREAKSIGNAL_GIVEN );
}

/****h* WriteChar() [2.0] ******************************************
*
* NAME
*    WriteChar()
*
* SYNOPSIS
*    int success = WriteChar( int timeout, BOOL microFlag, int ch );
*
* DESCRIPTION
*    Write a single character to the Serial Port 
*    (zero means success).
********************************************************************
*
*/

VISIBLE int WriteChar( int timeout, BOOL microFlag, int ch )
{
   int rval = 0;
   
   *WriteBuffer       = (char) ch;
   *(WriteBuffer + 1) = '\0';
   
   rval = WriteString( timeout, microFlag, WriteBuffer, 1 );

   return( rval );
}

/****h* ResetSerial() [2.0] ******************************************
*
* NAME
*    ResetSerial()
*
* SYNOPSIS
*    int success = ResetSerial( int timeout, BOOL microFlag );
*
* DESCRIPTION
*    Reset the Serial Port & change the timeout value.
*    (success >= 0 means NO ERROR).
********************************************************************
*
*/

VISIBLE int ResetSerial( int timeout, BOOL microFlag )
{
   ULONG temp = 0L;
   
   KillTimer();   

   ReadRequest->IOSer.io_Command = CMD_RESET;

   TimeValue = timeout;

   StartTimer( timeout, microFlag );

   SendIO( (struct IORequest *) ReadRequest );

   while (1)
      {
      temp = Wait( WaitSerMask );

      if ((SIGBREAKF_CTRL_C & temp) == SIGBREAKF_CTRL_C)
         {
         TimedOut = FALSE;

         break;
         }

      if (CheckIO( (struct IORequest *) ReadRequest ))
         {
         TimedOut = FALSE;

         WaitIO( (struct IORequest *) ReadRequest );

         ErrorNumber = ReadRequest->IOSer.io_Error;
      
         return( (int) ReadRequest->IOSer.io_Actual );
         }
      else if (CheckIO( (struct IORequest *) SerTimer ) 
               && ( !SerTimer->tr_node.io_Error))
         {
         TimedOut = TRUE;

         return( TIMER_TIMEDOUT );
         } 
      }

   AbortIO( (struct IORequest *) ReadRequest );
   WaitIO( (struct IORequest *) ReadRequest );

   ErrorNumber = ReadRequest->IOSer.io_Error;

   return( (int) ReadRequest->IOSer.io_Actual );
}

/****h* ClearSerial() [2.0] ***************************************
*
* NAME
*    ClearSerial()
*
* SYNOPSIS
*    int success = ClearSerial( int timeout, BOOL microFlag );
*
* DESCRIPTION
*    Issue a CMD_CLEAR to the Serial device (success < 0 means
*    the timer timed out). 
*******************************************************************
*
*/

VISIBLE int ClearSerial( int timeout, BOOL microFlag )
{
   ULONG temp = 0L;
   
   KillTimer();   

   ReadRequest->IOSer.io_Command = CMD_CLEAR;

   TimeValue = timeout;

   StartTimer( timeout, microFlag );

   SendIO( (struct IORequest *) ReadRequest );

   while (1)
      {
      temp = Wait( WaitSerMask );

      if ((SIGBREAKF_CTRL_C & temp) == SIGBREAKF_CTRL_C)
         {
         TimedOut = FALSE;
         
         break;
         }

      if (CheckIO( (struct IORequest *) ReadRequest ))
         {
         TimedOut = FALSE;

         WaitIO( (struct IORequest *) ReadRequest );
       
         ErrorNumber = ReadRequest->IOSer.io_Error;

         return( (int) ReadRequest->IOSer.io_Actual );
         }
      else if (CheckIO( (struct IORequest *) SerTimer ) && ( !SerTimer->tr_node.io_Error))
         {
         TimedOut = TRUE;
         
         return( TIMER_TIMEDOUT );
         } 
      }

   AbortIO( (struct IORequest *) ReadRequest );
   WaitIO( (struct IORequest *) ReadRequest );

   ErrorNumber = ReadRequest->IOSer.io_Error;

   return( (int) ReadRequest->IOSer.io_Actual );
}

/****h* FlushSerial() [2.0] ***************************************
*
* NAME
*    FlushSerial()
*
* SYNOPSIS
*    int success = FlushSerial( int timeout, BOOL microFlag );
*
* DESCRIPTION
*    Issue a CMD_FLUSH to the Serial device (success < 0 means
*    the timer timed out). 
*******************************************************************
*
*/

VISIBLE int FlushSerial( int timeout, BOOL microFlag )
{
   ULONG temp = 0L;
   
   KillTimer();   

   ReadRequest->IOSer.io_Command = CMD_FLUSH;

   TimeValue = timeout;

   StartTimer( timeout, microFlag );

   SendIO( (struct IORequest *) ReadRequest );

   while (1)
      {
      temp = Wait( WaitSerMask );

      if ((SIGBREAKF_CTRL_C & temp) == SIGBREAKF_CTRL_C)
         {
         TimedOut = FALSE;

         break;
         }

      if (CheckIO( (struct IORequest *) ReadRequest ))
         {
         TimedOut = FALSE;

         WaitIO( (struct IORequest *) ReadRequest );

         ErrorNumber = ReadRequest->IOSer.io_Error;

         return( (int) ReadRequest->IOSer.io_Actual );
         }
      else if (CheckIO( (struct IORequest *) SerTimer ) && ( !SerTimer->tr_node.io_Error))
         {
         TimedOut = TRUE;

         return( TIMER_TIMEDOUT );
         } 
      }

   AbortIO( (struct IORequest *) ReadRequest );
   WaitIO(  (struct IORequest *) ReadRequest );

   ErrorNumber = ReadRequest->IOSer.io_Error;

   return( (int) ReadRequest->IOSer.io_Actual );
}

/****h* StopSerial() [2.0] ****************************************
*
* NAME
*    StopSerial()
*
* SYNOPSIS
*    int success = StopSerial( int timeout, BOOL microFlag );
*
* DESCRIPTION
*    Issue a CMD_STOP to the Serial device (success < 0 means
*    the timer timed out). 
*
* SEE ALSO
*    StartSerial()
*******************************************************************
*
*/

VISIBLE int StopSerial( int timeout, BOOL microFlag )
{
   ULONG temp = 0L;
   
   KillTimer();   

   ReadRequest->IOSer.io_Command = CMD_STOP;

   TimeValue = timeout;

   StartTimer( timeout, microFlag );

   SendIO( (struct IORequest *) ReadRequest );

   while (1)
      {
      temp = Wait( WaitSerMask );

      if ((SIGBREAKF_CTRL_C & temp) == SIGBREAKF_CTRL_C)
         {
         TimedOut = FALSE;

         break;
         }

      if (CheckIO( (struct IORequest *) ReadRequest ))
         {
         TimedOut = FALSE;

         WaitIO( (struct IORequest *) ReadRequest );

         ErrorNumber = ReadRequest->IOSer.io_Error;

         return( (int) ReadRequest->IOSer.io_Actual );
         }
      else if (CheckIO( (struct IORequest *) SerTimer ) && ( !SerTimer->tr_node.io_Error))
         {
         TimedOut = TRUE;

         return( TIMER_TIMEDOUT );
         } 
      }

   AbortIO( (struct IORequest *) ReadRequest );
   WaitIO(  (struct IORequest *) ReadRequest );

   ErrorNumber = ReadRequest->IOSer.io_Error;

   return( (int) ReadRequest->IOSer.io_Actual );
}

/****h* StartSerial() [2.0] ***************************************
*
* NAME
*    StartSerial()
*
* SYNOPSIS
*    int success = StartSerial( int timeout, BOOL microFlag );
*
* DESCRIPTION
*    Issue a CMD_START to the Serial device (success < 0 means
*    the timer timed out). 
*
* SEE ALSO
*    StopSerial()
*******************************************************************
*
*/

VISIBLE int StartSerial( int timeout, BOOL microFlag )
{
   ULONG temp = 0L;
   
   KillTimer();   

   ReadRequest->IOSer.io_Command = CMD_START;

   TimeValue = timeout;

   StartTimer( timeout, microFlag );

   SendIO( (struct IORequest *) ReadRequest );

   while (1)
      {
      temp = Wait( WaitSerMask );

      if ((SIGBREAKF_CTRL_C & temp) == SIGBREAKF_CTRL_C)
         {
         TimedOut = FALSE;

         break;
         }

      if (CheckIO( (struct IORequest *) ReadRequest ))
         {
         TimedOut = FALSE;

         WaitIO( (struct IORequest *) ReadRequest );

         ErrorNumber = ReadRequest->IOSer.io_Error;

         return( (int) ReadRequest->IOSer.io_Actual );
         }
      else if (CheckIO( (struct IORequest *) SerTimer ) && ( !SerTimer->tr_node.io_Error))
         {
         TimedOut = TRUE;

         return( TIMER_TIMEDOUT );
         } 
      }

   AbortIO( (struct IORequest *) ReadRequest );
   WaitIO( (struct IORequest *) ReadRequest );

   ErrorNumber = ReadRequest->IOSer.io_Error;

   return( (int) ReadRequest->IOSer.io_Actual );
}

/****h* BreakSerial() [2.0] ***************************************
*
* NAME
*    BreakSerial()
*
* SYNOPSIS
*    int success = BreakSerial( int timeout, BOOL microFlag, int duration );
*
* DESCRIPTION
*    Issue a SDCMD_BREAK to the Serial device with the break
*    duration given (success < 0 means the timer timed out). 
*******************************************************************
*
*/

VISIBLE int BreakSerial( int timeout, BOOL microFlag, int duration )
{
   ULONG temp = 0L;
   
   KillTimer();   

   ReadRequest->IOSer.io_Command = SDCMD_BREAK;
   ReadRequest->io_BrkTime       = duration;
   TimeValue                     = timeout;

   StartTimer( timeout, microFlag );

   SendIO( (struct IORequest *) ReadRequest );

   while (1)
      {
      temp = Wait( WaitSerMask );

      if ((SIGBREAKF_CTRL_C & temp) == SIGBREAKF_CTRL_C)
         {
         TimedOut = FALSE;

         break;
         }

      if (CheckIO( (struct IORequest *) ReadRequest ))
         {
         TimedOut = FALSE;

         WaitIO( (struct IORequest *) ReadRequest );

         ErrorNumber = ReadRequest->IOSer.io_Error;

         return( (int) ReadRequest->IOSer.io_Actual );
         }
      else if (CheckIO( (struct IORequest *) SerTimer ) && ( !SerTimer->tr_node.io_Error))
         {
         TimedOut = TRUE;

         return( TIMER_TIMEDOUT );
         } 
      }

   AbortIO( (struct IORequest *) ReadRequest );
   WaitIO( (struct IORequest *) ReadRequest );

   ErrorNumber = ReadRequest->IOSer.io_Error;

   return( (int) ReadRequest->IOSer.io_Actual );
}

/****h* QuerySerial() [2.0] ***************************************
*
* NAME
*    QuerySerial()
*
* SYNOPSIS
*    int success = QuerySerial( int timeout, BOOL microFlag );
*
* DESCRIPTION
*    Issue a SDCMD_QUERY to the Serial device (success < 0 means
*    the timer timed out). 
*******************************************************************
*
*/

VISIBLE int QuerySerial( int timeout, BOOL microFlag )
{
   ULONG temp = 0L;
   
   KillTimer();   

   ReadRequest->IOSer.io_Command = SDCMD_QUERY;

   TimeValue = timeout;

   StartTimer( timeout, microFlag );

   SendIO( (struct IORequest *) ReadRequest );

   while (1)
      {
      temp = Wait( WaitSerMask );

      if ((SIGBREAKF_CTRL_C & temp) == SIGBREAKF_CTRL_C)
         {
         TimedOut = FALSE;

         break;
         }

      if (CheckIO( (struct IORequest *) ReadRequest ))
         {
         TimedOut = FALSE;

         WaitIO( (struct IORequest *) ReadRequest );

         SerialStatus = ReadRequest->io_Status;

         ErrorNumber = ReadRequest->IOSer.io_Error;

         return( (int) ReadRequest->IOSer.io_Actual );
         }
      else if (CheckIO( (struct IORequest *) SerTimer ) && ( !SerTimer->tr_node.io_Error))
         {
         TimedOut = TRUE;

         return( TIMER_TIMEDOUT );
         } 
      }

   AbortIO( (struct IORequest *) ReadRequest );
   WaitIO(  (struct IORequest *) ReadRequest );

   SerialStatus = ReadRequest->io_Status;
   ErrorNumber  = ReadRequest->IOSer.io_Error;

   return( (int) ReadRequest->IOSer.io_Actual );
}

/****h* GetSerialStatus() [1.1] ***********************************
*
* NAME
*    GetSerialStatus()
*
* SYNOPSIS
*    int success = GetSerialStatus( void );
*
* DESCRIPTION
*    Return the internal SerialStatus variable setting.
*******************************************************************
*
*/

VISIBLE int GetSerialStatus( void )
{
   return( SerialStatus );
}

/****h* SetSerialParams() [2.0] ***********************************
*
* NAME
*    SetSerialParams()
*
* SYNOPSIS
*    int success = SetSerialParams( int timeout,
*                                   BOOL microFlag, // use microseconds = TRUE
*                                   int whichparm,
*                                   int param
*                                 );
*
* DESCRIPTION
*    Issue a SDCMD_SETPARAMS to the Serial device for the given
*    parameter type & value (success < 0 means the timer timed 
*    out or an unknown value for whichparm).
*******************************************************************
*
*/

VISIBLE int SetSerialParams( int timeout, BOOL microFlag, int which, int params )
{
   ULONG temp = 0L;

   switch (which)
      {
      case SETBAUD:
         ReadRequest->io_Baud = params;
         break;

      case SETSTOP:
         ReadRequest->io_StopBits = params;
         break;

      case SETFLAGS:
         ReadRequest->io_SerFlags = params;
         break;

      case SETEXTFLAGS:
         ReadRequest->io_ExtFlags = params;
         break;

      case SETREADLEN:
         ReadRequest->io_ReadLen = params;
         break;

      case SETWRITELEN:
         ReadRequest->io_WriteLen = params;
         break;

      case SETBREAKTIME:
         ReadRequest->io_BrkTime = params;
         break;

      case SETCTLCHAR:
         ReadRequest->io_CtlChar = params;
         break;

      case SETRBUFLEN:
         ReadRequest->io_RBufLen = params;
         break;

      default:
         return( -1 );
      }
         
   KillTimer();   

   ReadRequest->IOSer.io_Command = SDCMD_SETPARAMS;

   TimeValue = timeout;

   StartTimer( timeout, microFlag );

   SendIO( (struct IORequest *) ReadRequest );

   while (1)
      {
      temp = Wait( WaitSerMask );

      if ((SIGBREAKF_CTRL_C & temp) == SIGBREAKF_CTRL_C)
         {
         TimedOut = FALSE;

         break;
         }

      if (CheckIO( (struct IORequest *) ReadRequest ))
         {
         TimedOut = FALSE;

         WaitIO( (struct IORequest *) ReadRequest );

         ErrorNumber = ReadRequest->IOSer.io_Error;

         return( (int) ReadRequest->IOSer.io_Actual );
         }
      else if (CheckIO( (struct IORequest *) SerTimer ) && ( !SerTimer->tr_node.io_Error))
         {
         TimedOut = TRUE;

         return( TIMER_TIMEDOUT );
         } 
      }

   AbortIO( (struct IORequest *) ReadRequest );
   WaitIO(  (struct IORequest *) ReadRequest );

   ErrorNumber = ReadRequest->IOSer.io_Error;

   return( (int) ReadRequest->IOSer.io_Actual );
}

/* ----------------- End of TimedSerial.c file! ------------------ */
