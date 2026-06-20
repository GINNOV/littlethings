/****h* TimedSerial.h *******************************************
*
* NAME
*    TimedSerial.h
*
* DESCRIPTION
*    Header file for the functions in TimedSerial.c
*
* HISTORY
*    25-Dec-2002 - Added a boolean flag to each function that
*                  uses the timer in order to control whether
*                  the timer uses microseconds or seconds.
*
*****************************************************************
*
*/

#ifndef  TIMEDSERIAL_H
# define TIMEDSERIAL_H  1

# ifndef    EXEC_TYPES_H
#  include <exec/types.h>
# endif
 
#ifndef  PRIVATE         // storage types to increase readability.
# define PRIVATE static  
# define IMPORT  extern
# define PUBLIC
# define VISIBLE
#endif

# define  SETBAUD        1
# define  SETSTOP        2
# define  SETFLAGS       3
# define  SETEXTFLAGS    4
# define  SETREADLEN     5
# define  SETWRITELEN    6
# define  SETBREAKTIME   8
# define  SETCTLCHAR     9
# define  SETRBUFLEN     10

// --------------------------------------------------------------------

# ifdef ALLOCATE

VISIBLE int              TimedOut     = FALSE;
VISIBLE int              TimeValue    = 1;     
VISIBLE ULONG            WaitSerMask  = 0L;

VISIBLE struct IOExtSer *ReadRequest  = NULL;
VISIBLE struct IOExtSer *WriteRequest = NULL;
VISIBLE char            *ReadBuffer   = NULL;
VISIBLE char            *WriteBuffer  = NULL;
VISIBLE int              ReadSize     = 0;
VISIBLE int              WriteSize    = 0;
VISIBLE UWORD            SerialStatus = 0;

# else

IMPORT int              TimedOut;
IMPORT int              TimeValue;
IMPORT ULONG            WaitSerMask;

IMPORT struct IOExtSer *ReadRequest;
IMPORT struct IOExtSer *WriteRequest;
IMPORT char            *ReadBuffer;
IMPORT char            *WriteBuffer;
IMPORT int              ReadSize;
IMPORT int              WriteSize;
IMPORT UWORD            SerialStatus;

# endif

// ---------- Function Prototypes: -------------------------------------

/* 
** BOOL useMicrosFlag & microFlag tell each function whether the 
** timeout/delay value is to be seconds (FALSE) or microseconds (TRUE):
*/

VISIBLE void  TimerDelay( int delayseconds, BOOL useMicrosFlag );

VISIBLE int   TestTimer( void );

VISIBLE char *TranslateErrorNumber( int errnum );

VISIBLE int   OpenSerial( char *serName,
                          int   unit, 
                          int   HowLong, 
                          int   buffersize,
                          int   flags
                        );

VISIBLE void  CloseSerial( void );

VISIBLE char  *ReadString( int timeout, BOOL microFlag, int strsize );
VISIBLE UBYTE  ReadChar(   int timeout, BOOL microFlag );

VISIBLE int WriteString( int timeout, BOOL microFlag, char *string, int strsize );
VISIBLE int WriteChar(   int timeout, BOOL microFlag, int   ch                  );

VISIBLE int ResetSerial( int timeout, BOOL microFlag );
VISIBLE int ClearSerial( int timeout, BOOL microFlag );
VISIBLE int FlushSerial( int timeout, BOOL microFlag );
VISIBLE int StopSerial(  int timeout, BOOL microFlag );
VISIBLE int StartSerial( int timeout, BOOL microFlag );
VISIBLE int QuerySerial( int timeout, BOOL microFlag );
VISIBLE int BreakSerial( int timeout, BOOL microFlag, int duration );

VISIBLE int SetSerialParams( int timeout, BOOL microFlag, int which, int params );

VISIBLE int GetSerialStatus( void );

#endif

/* ------------------- END of TimedSerial.h file --------------------- */
