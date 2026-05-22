/****h* SetSCSIEnv.c [2.0] ******************************************************
*
* NAME
*    SetSCSIEnv.c
*
* DESCRIPTION
*    Read all logical units on the SCSI bus & make Environment strings from
*    all partition names found in the Rigid Disk Blocks information.
*
* HISTORY
*    17-Nov-2004 - Ported to AmigaOS4 & gcc.
*    21-Mar-1996 - Created.
*********************************************************************************
*
*/

#include <stdio.h>
#include <string.h>

#include <exec/types.h>
#include <exec/memory.h>

#include <AmigaDOSErrs.h>

#include <devices/trackdisk.h>
#include <devices/hardblocks.h>

#include <libraries/dos.h>

#ifndef __amigaos4__

# include <proto/exec.h>
# include <proto/dos.h>

PRIVATE STRPTR v = "\0$VER: SetSCSIEnv 2.0 " __AMIGADATE__ " by J.T. Steichen\0";
#else

# include <dos/var.h>       // For SetVar() flags.

# define __USE_INLINE__

# include <proto/exec.h>
# include <proto/dos.h>

IMPORT struct Library *SysBase;
IMPORT struct Library *DOSBase;

IMPORT struct ExecIFace *IExec;
IMPORT struct DOSIFace  *IDOS;

PRIVATE STRPTR v = "\0$VER: SetSCSIEnv 2.0 " __DATE__ " by J.T. Steichen\0";

#endif

#ifdef DEBUG
# define DBG(p) p
#else
# define DBG(p)
#endif

#define BOARD 0 // controller board
#define LUN   0 // logical unit

PRIVATE int     TID   = 1;
#define UNIT  (BOARD * 100 + LUN * 10 + TID)

#define TBUF_SIZE 128

PRIVATE int              numEnvsWritten = 0;
PRIVATE char             strbuf[ TBUF_SIZE ] = "";
PRIVATE UBYTE           *data = NULL;
PRIVATE struct MsgPort  *mp   = NULL;
PRIVATE struct IOStdReq *io   = NULL;

// -----------------------------------------------------------------------

PRIVATE void  ResetStringBuf( void )
{
   int i;
   
   for (i = 0; i < TBUF_SIZE; i++)
      strbuf[i] = '\0';

   return;
}

PRIVATE char  *GetBString( UBYTE *data, int len )
{
   ResetStringBuf();

   strncpy( strbuf, &data[1], len );

   strbuf[ len + 1 ] = '\0';

   DBG( fprintf( stderr, "GetBString() returns %s\n", strbuf ) );

   return( strbuf );
}

#define UNKWN "DHxx:UNKNOWN"

#define NUM_COLUMNS 10
#define NUM_ROWS    6

/* If you have more than this hooked up to your Amiga, you should send me some
** bucks for supporting your business!
*/

PRIVATE char devnames[60][33] = {

   UNKWN, UNKWN, UNKWN, UNKWN, UNKWN, UNKWN, UNKWN, UNKWN, UNKWN, UNKWN,   
   UNKWN, UNKWN, UNKWN, UNKWN, UNKWN, UNKWN, UNKWN, UNKWN, UNKWN, UNKWN,   
   UNKWN, UNKWN, UNKWN, UNKWN, UNKWN, UNKWN, UNKWN, UNKWN, UNKWN, UNKWN,   
   UNKWN, UNKWN, UNKWN, UNKWN, UNKWN, UNKWN, UNKWN, UNKWN, UNKWN, UNKWN,   
   UNKWN, UNKWN, UNKWN, UNKWN, UNKWN, UNKWN, UNKWN, UNKWN, UNKWN, UNKWN,   
   UNKWN, UNKWN, UNKWN, UNKWN, UNKWN, UNKWN, UNKWN, UNKWN, UNKWN, UNKWN   
};

PRIVATE void  ProcessPART( UBYTE *data, int unitnum )
{
   struct PartitionBlock *p = (struct PartitionBlock *) &data[0];
   int                    row;
   char                  *name = NULL;

   name = GetBString( (UBYTE *) p->pb_DriveName, 32 );

   for (row = 0; row < NUM_COLUMNS; row++) // each row is NUM_COLUMNS in size
      {
      if (strcmp( devnames[(unitnum - 1) * NUM_COLUMNS + row], UNKWN ) == 0)
         {
	 DBG( fprintf( stderr, "ProcessPART():  Empty slot %d will be filled with %s\n", (unitnum - 1) * NUM_COLUMNS + row, name ) );

         strncpy( devnames[(unitnum - 1) * NUM_COLUMNS + row], name, 31 );

         break;
         }
      }

   return;
}

PRIVATE ULONG GetLong( UBYTE *data )
{
   ULONG result = 0;
   
   result = data[3] + (data[2] << 8) + (data[1] << 16) + (data[0] << 24);

   return( result );
}

PRIVATE void  ProcessBlock( UBYTE *data, int unitnum )
{
   ULONG  BlockType = IDNAME_RIGIDDISK;
   
   BlockType = GetLong( &data[0] );
   
   switch (BlockType)
      {
      case IDNAME_PARTITION:
//         DBG( fprintf( stderr, "Calling ProcessPART( , %d )\n", unitnum ) );
         ProcessPART( data, unitnum );

      default:
         break;
      }

   return;
}

PRIVATE BOOL readBlock( UBYTE *data, int blkNumber )
{
   io->io_Command = CMD_READ;
   io->io_Length  = TD_SECTOR;
   io->io_Data    = (APTR) data;
   io->io_Offset  = TD_SECTOR * blkNumber; // sector offset

   (void) DoIO( (struct IORequest *) io );
   
   if (io->io_Error == 0)
      return( TRUE );
   else
      return( FALSE );
}

PRIVATE void ProcessUnit( UBYTE *data, struct IOStdReq *io, int unitnum )
{
   int blk = 0;

#  ifndef __amigaos4__   
   for (blk = 0; blk < RDB_LOCATION_LIMIT; blk++)
      {
      if (readBlock( data, blk ) == TRUE)
         ProcessBlock( data, unitnum );
      }

#  else // __amigaos4__ is DEFINED!

   blk = 0;
   
   if (readBlock( data, blk ) == TRUE)
      {
      struct RigidDiskBlock *rdb = (struct RigidDiskBlock *) data;
      struct PartitionBlock *pb  = NULL;

//      DBG( fprintf( stderr, "rdb = 0x%08LX\n", rdb ));

      blk = rdb->rdb_PartitionList;

//      DBG( fprintf( stderr, "first Partition = %d\n", blk ));

      if (blk == 0)
         {
         DBG( fprintf( stderr, "\tNO Partitions found!\n" ));

	 return; // Disk has no partitions defined yet!
	 }
	 
      if (readBlock( data, blk ) == TRUE)
         {
//         DBG( fprintf( stderr, "Partition Block[%d] = 0x%08LX\n", blk, data ));

         pb = (struct PartitionBlock *) data;

//         DBG( fprintf( stderr, "\tpb = 0x%08LX\n", pb ));
	 
         while (blk > 0) // pb) // != NULL)
            {
            data[0] = '\0'; // Reset the data buffer (Should NOT be necessary)
	                
	    if (readBlock( data, blk ) == FALSE)
	       {
               DBG( fprintf( stderr, "\tFound last Partition!\n" ));

               goto exitProcessUnit;
	       }

//            DBG( fprintf( stderr, "\t\tCalling ProcessBlock( , unitnum = %d )...\n", unitnum ));

   	    ProcessBlock( data, unitnum );

//            DBG( fprintf( stderr, "\tReturned from ProcessBlock( , unitnum = %d )...\n", unitnum ));

	    if (pb->pb_Next <= 0)
	       {
               DBG( fprintf( stderr, "\tFound last Partition blk is %d!\n", blk + 1 ));

  	       if (readBlock( data, blk + 1 ) == FALSE)
	          {
                  DBG( fprintf( stderr, "\tFound last Partition!\n" ));

                  goto exitProcessUnit;
	          }
               else
	          ProcessBlock( data, unitnum );
		  
               goto exitProcessUnit;
	       }
            else
	       blk = pb->pb_Next;
	       
//            DBG( fprintf( stderr, "\tblk is now = %d\n", blk ));
	    }
         }
      }
#  endif

   // ALWAYS make sure the motor is turned off!

//   io->io_Command = TD_MOTOR;
//   io->io_Length  = 0;

//   (void) DoIO( (struct IORequest *) io );

exitProcessUnit:

   CloseDevice( (struct IORequest *) io );

   return;
}

#define SCSIDEV_1    "SCSIENV_"
#define SCSIDEV_2    "SCSIENV_"
#define SCSIDEV_3    "SCSIENV_"
#define SCSIDEV_4    "SCSIENV_"
#define SCSIDEV_5    "SCSIENV_"
#define SCSIDEV_6    "SCSIENV_"

PRIVATE char envnames[60][70] = {
   
   SCSIDEV_1, SCSIDEV_1, SCSIDEV_1, SCSIDEV_1, SCSIDEV_1, SCSIDEV_1, SCSIDEV_1, SCSIDEV_1, SCSIDEV_1, SCSIDEV_1, 
   SCSIDEV_2, SCSIDEV_2, SCSIDEV_2, SCSIDEV_2, SCSIDEV_2, SCSIDEV_2, SCSIDEV_2, SCSIDEV_2, SCSIDEV_2, SCSIDEV_2, 
   SCSIDEV_3, SCSIDEV_3, SCSIDEV_3, SCSIDEV_3, SCSIDEV_3, SCSIDEV_3, SCSIDEV_3, SCSIDEV_3, SCSIDEV_3, SCSIDEV_3,
   SCSIDEV_4, SCSIDEV_4, SCSIDEV_4, SCSIDEV_4, SCSIDEV_4, SCSIDEV_4, SCSIDEV_4, SCSIDEV_4, SCSIDEV_4, SCSIDEV_4,
   SCSIDEV_5, SCSIDEV_5, SCSIDEV_5, SCSIDEV_5, SCSIDEV_5, SCSIDEV_5, SCSIDEV_5, SCSIDEV_5, SCSIDEV_5, SCSIDEV_5, 
   SCSIDEV_6, SCSIDEV_6, SCSIDEV_6, SCSIDEV_6, SCSIDEV_6, SCSIDEV_6, SCSIDEV_6, SCSIDEV_6, SCSIDEV_6, SCSIDEV_6,
};

PRIVATE void  MakeEnvStrings( void )
{
   UBYTE buffer[70];
   int   row = 0, column = 0;

   // Have to traverse the entire array in case there is more than one SCSI device in the PC:   

   for (row = 0; row < NUM_COLUMNS; row++)          // each    row is NUM_COLUMNS in size
      {
      for (column = 0; column < NUM_ROWS; column++) // each column is    NUM_ROWS in size
         {
	 int address = column * NUM_COLUMNS + row;

         if (strcmp( devnames[address], UNKWN )) // != 0)
            {
            if (strlen( devnames[address] ) > 1) // valid devnames[] string??
	       {
               sprintf( buffer, "%s", envnames[address] );
            
               DBG( fprintf( stderr, "Copying '%s' to envnames[%d]\n", buffer, address ) );

               sprintf( envnames[address], "%s%d", buffer, address );
	       }
            }
	 }
      }

   return;
}

PRIVATE void  PutEnvStrings( void )
{
   int column, row;

   for (row = 0; row < NUM_COLUMNS; row++)          // each    row is NUM_COLUMNS in size
      {
      for (column = 0; column < NUM_ROWS; column++) // each column is    NUM_ROWS in size
         {
	 int address = column * NUM_COLUMNS + row;
	 
         if (strlen( envnames[address] ) > (strlen( SCSIDEV_1 ))) // ) + 1 ))
            {
#           ifdef __SASC
            putenv( envnames[address] ); // Don't know if this still works
#           else
            (void) SetVar( envnames[address], devnames[address], strlen( devnames[address] ),
                           GVF_SAVE_VAR | GVF_GLOBAL_ONLY 
			 );
#           endif	 

            numEnvsWritten++;
	    }
	 }
      }

   return;
}

PRIVATE void ShutdownProgram( void )
{
   if (io)
      DeleteStdIO( (struct IORequest *) io );

   if (mp)
      DeletePort( mp );

   if (data)
      FreeVec( data );

   return;
}

PRIVATE int SetupProgram( void )
{
   int rval = RETURN_OK;

   if (!(data = AllocVec( TD_SECTOR, MEMF_CLEAR | MEMF_SHARED ))) // MEMF_CHIP )))
      {
      rval = ERROR_NO_FREE_STORE;

      goto exitSetupProgram;
      }

   if (!(mp = CreatePort( NULL, 0 )))
      {
      rval = IoErr();

      ShutdownProgram();

      goto exitSetupProgram;
      }

   if (!(io = (struct IOStdReq *) CreateStdIO( mp )))
      {
      rval = IoErr();

      ShutdownProgram();

      goto exitSetupProgram;
      }

exitSetupProgram:

   return( rval );
}
     
PUBLIC int main( int argc, char **argv )
{
   char devicename[80];
   int  rval = RETURN_OK;

#  ifdef DEBUG
   UBYTE buff[33] = "Testing SetVar()!";
   
   (void) SetVar( "DEBUG_SETVAR", &buff[0], strlen( &buff[0] ), GVF_SAVE_VAR | GVF_GLOBAL_ONLY );
#  endif
   
   if (argc == 0)
      return( RETURN_ERROR ); // No Workbench support (yet!)
   
   if (argc != 2)
      {
      fprintf( stderr, "USAGE:  %s DEVICENAME/A\n", argv[0] );

      return( ERROR_REQUIRED_ARG_MISSING );
      }   

   strncpy( devicename, argv[1], 80 );
      
   if (SetupProgram() != RETURN_OK)
      {
      fprintf( stderr, "Could NOT setup %s program!\n", argv[0] );

      return( RETURN_FAIL );
      }
   else
      {
      for (TID = 1; TID < 7; TID++)
         {
         if (OpenDevice( devicename, UNIT, (struct IORequest *) io, 0 ) == 0)
            {
            ProcessUnit( data, io, TID ); // ProcessUnit() closes the Device!
            }
         }
      }

//   DBG( fprintf( stderr, "Calling MakeEnvStrings()...\n" ) );
   MakeEnvStrings();
//   DBG( fprintf( stderr, "Calling PutEnvStrings()...\n" ) );
   PutEnvStrings();

   ShutdownProgram();

   fprintf( stderr, "%s wrote %d environmental variables (done!)!\n", argv[0], numEnvsWritten );   

   return( rval );
}

/* ----------------- END of SetSCSIEnv.c file! ------------------- */
