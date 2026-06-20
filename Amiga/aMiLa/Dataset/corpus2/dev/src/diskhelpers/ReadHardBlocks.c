/****h* ReadHardBlocks.c [2.0] ************************************************
*
* NAME
*    ReadHardBlocks.c
*
* DESCRIPTION
*    Read a HardDisk from GVP's SCSI device driver in order to get information
*    on the RDB, PART & LSEG blocks, located in the first 16 blocks
*    of every HardDisk on the SCSI bus.
*
* HISTORY
*    31-Oct-1995 - Created.
*    16-Nov-2004 - Ported to AmigaOS4 & gcc.
************************************************************************
*
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>            // For atoi()

#include <exec/types.h>
#include <exec/memory.h>

#include <AmigaDOSErrs.h>

#include <devices/trackdisk.h>
#include <devices/hardblocks.h>

#include <libraries/dos.h>

#ifndef __amigaos4__

# include <proto/exec.h>
# include <proto/dos.h>

PRIVATE STRPTR v = "\0$VER: ReadHardBlocks 2.0 " __AMIGADATE__ " by J.T. Steichen\0";
#else

# define __USE_INLINE__

# include <proto/exec.h>
# include <proto/dos.h>

IMPORT struct Library *SysBase;
IMPORT struct Library *DOSBase;

IMPORT struct ExecIFace *IExec;
IMPORT struct DOSIFace  *IDOS;

PRIVATE STRPTR v = "\0$VER: ReadHardBlocks 2.0 " __DATE__ " by J.T. Steichen\0";

#endif

#define BOARD 0 // controller board
#define LUN   0 // logical unit

#define TBUF_SIZE        128

PRIVATE int                 TID              = 1;
PRIVATE char             strbuf[ TBUF_SIZE ] = "";

PRIVATE UBYTE           *data = NULL;
PRIVATE struct MsgPort  *mp   = NULL;
PRIVATE struct IOStdReq *io   = NULL;

#define UNIT  (BOARD * 100 + LUN * 10 + TID)

#ifdef __amigaos4__

// AmigaOS3.5+ respects RDB_LOCATION_LIMIT & we do NOT need this:

PRIVATE int firstPartitionBlkNum = 0;

#endif

PRIVATE void ResetStringBuf( void )
{
   int i;
   
   for (i = 0; i < TBUF_SIZE; i++)
      strbuf[i] = '\0';

   return;
}

PRIVATE char *GetBString( UBYTE *data, int len )
{
   ResetStringBuf();

   strncpy( strbuf, &data[1], len );
   strbuf[ len + 1 ] = '\0';

   return( strbuf );
}

PRIVATE char *GetString( UBYTE *data, int len )
{
   int   dlen = 0;
   
   ResetStringBuf();

   if ((dlen = strlen( data )) < len)
      len = dlen;

   strncpy( strbuf, data, len );
   strbuf[ len + 1 ] = '\0';

   return( strbuf );
}

PRIVATE void  PrintRDB( UBYTE *data )
{
   struct RigidDiskBlock *r = (struct RigidDiskBlock *) &data[0];
   int                    i = 0;
      
   printf( "struct RigidDiskBlock {\n\n" );

   printf( "\tULONG  rdb_ID                = 5244534B (\"RDSK\");\n" );
   printf( "\tULONG  rdb_SummedLongs       = %08LX;\n", r->rdb_SummedLongs );
   printf( "\tULONG  rdb_ChkSum            = %08LX;\n", r->rdb_ChkSum );
   printf( "\tULONG  rdb_HostID            = %08LX;\n", r->rdb_HostID );
   printf( "\tULONG  rdb_BlockBytes        = %08LX;\n", r->rdb_BlockBytes );
   printf( "\tULONG  rdb_Flags             = %08LX;\n", r->rdb_Flags );

#  ifndef __amigaos4__
   printf( "\tULONG  rdb_BadBlockList      = %08LX;\n", r->rdb_BadBlockList );
#  else
   printf( "\tULONG  rdb_Obsolete1         = %08LX;\n", r->rdb_Obsolete1 );
#  endif

   printf( "\tULONG  rdb_PartitionList     = %08LX;\n", r->rdb_PartitionList );
   printf( "\tULONG  rdb_FileSysHeaderList = %08LX;\n", r->rdb_FileSysHeaderList);
   printf( "\tULONG  rdb_DriveInit         = %08LX;\n", r->rdb_DriveInit );

#  ifndef __amigaos4__
   printf( "\tULONG  rdb_Reserved1[6]  = %08LX;\n", r->rdb_Reserved1[0] );
   printf( "\t                           %08LX;\n", r->rdb_Reserved1[1] );
   printf( "\t                           %08LX;\n", r->rdb_Reserved1[2] );
   printf( "\t                           %08LX;\n", r->rdb_Reserved1[3] );
   printf( "\t                           %08LX;\n", r->rdb_Reserved1[4] );
   printf( "\t                           %08LX;\n\n", r->rdb_Reserved1[5] );
#  else
   
   firstPartitionBlkNum = r->rdb_PartitionList; // __amigaos4__ has a lot of 'BOOT' blocks (more than RDB_LOCATION_LIMIT)

   printf( "\tULONG  rdb_BootStrapCode     = %08LX;\n", r->rdb_BootStrapCode );

   printf( "\tULONG  rdb_Reserved1[5]  = %08LX;\n", r->rdb_Reserved1[0] );
   printf( "\t                           %08LX;\n", r->rdb_Reserved1[1] );
   printf( "\t                           %08LX;\n", r->rdb_Reserved1[2] );
   printf( "\t                           %08LX;\n", r->rdb_Reserved1[3] );
   printf( "\t                           %08LX;\n", r->rdb_Reserved1[4] );
#  endif

   printf( "\tULONG  rdb_Cylinders     = %08LX;\n", r->rdb_Cylinders );
   printf( "\tULONG  rdb_Sectors       = %08LX;\n", r->rdb_Sectors );
   printf( "\tULONG  rdb_Heads         = %08LX;\n", r->rdb_Heads );
   printf( "\tULONG  rdb_Interleave    = %08LX;\n", r->rdb_Interleave );
   printf( "\tULONG  rdb_Park          = %08LX;\n", r->rdb_Park );
   printf( "\tULONG  rdb_Reserved2[3]  = %08LX;\n", r->rdb_Reserved2[0] );
   printf( "\t                           %08LX;\n", r->rdb_Reserved2[1] );
   printf( "\t                           %08LX;\n", r->rdb_Reserved2[2] );
   printf( "\tULONG  rdb_WritePreComp  = %08LX;\n", r->rdb_WritePreComp );
   printf( "\tULONG  rdb_ReducedWrite  = %08LX;\n", r->rdb_ReducedWrite );
   printf( "\tULONG  rdb_StepRate      = %08LX;\n", r->rdb_StepRate );
   printf( "\tULONG  rdb_Reserved3[5]  = %08LX;\n", r->rdb_Reserved3[0] );
   printf( "\t                           %08LX;\n", r->rdb_Reserved3[1] );
   printf( "\t                           %08LX;\n", r->rdb_Reserved3[2] );
   printf( "\t                           %08LX;\n", r->rdb_Reserved3[3] );
   printf( "\t                           %08LX;\n", r->rdb_Reserved3[4] );
   printf( "\tULONG  rdb_RDBBlocksLo     = %08LX;\n", r->rdb_RDBBlocksLo );
   printf( "\tULONG  rdb_RDBBlocksHi     = %08LX;\n", r->rdb_RDBBlocksHi );
   printf( "\tULONG  rdb_LoCylinder      = %08LX;\n", r->rdb_LoCylinder );
   printf( "\tULONG  rdb_HiCylinder      = %08LX;\n", r->rdb_HiCylinder );
   printf( "\tULONG  rdb_CylBlocks       = %08LX;\n", r->rdb_CylBlocks );
   printf( "\tULONG  rdb_AutoParkSeconds = %08LX;\n", r->rdb_AutoParkSeconds );
   printf( "\tULONG  rdb_HighRDSKBlock   = %08LX;\n", r->rdb_HighRDSKBlock );
   printf( "\tULONG  rdb_Reserved4       = %08LX;\n", r->rdb_Reserved4 );
   printf( "\tchar   rdb_DiskVendor[8]   = %s;\n", GetString( (UBYTE *) r->rdb_DiskVendor, 8 ));
   printf( "\tchar   rdb_DiskProduct[16] = %s;\n", GetString( (UBYTE *) r->rdb_DiskProduct, 16));
   printf( "\tchar   rdb_DiskRevision[4] = %s;\n", GetString( (UBYTE *) r->rdb_DiskRevision, 4 ));
   printf( "\tchar   rdb_ControllerVendor[8]   = %s;\n", GetString( (UBYTE *) r->rdb_ControllerVendor, 8));
   printf( "\tchar   rdb_ControllerProduct[16] = %s;\n", GetString( (UBYTE *) r->rdb_ControllerProduct, 16));
   printf( "\tchar   rdb_ControllerRevision[4] = %s;\n", GetString( (UBYTE *) r->rdb_ControllerRevision, 4 ) );

   printf( "\tchar   rdb_DriveInitName[40]     = '%-40.40s'\n", GetString( (UBYTE *) r->rdb_DriveInitName, 40 ));

#  ifdef __amigaos4__
   printf( "\tchar   rdb_BootStrapName[108]    = '%-s'\n", GetString( (UBYTE *) r->rdb_BootStrapName, 108 ));
#  endif

   printf( "\tULONG  rdb_Reserved5[37] = {\n\n\t\t" );

   for (i = 0; i < 37; i++)
      {
      printf( "%08LX", r->rdb_Reserved5[i] );

      if ((i + 1) % 4 == 0 && i != 0)
         printf( ",\n\t\t" );
      else
         printf( ",  " );
      }

   printf( "\t};\n" );      
   printf( "\n};\n" );

   return;
}

PRIVATE void PrintBADB( UBYTE *data )
{
   int i = 0;
   struct BadBlockBlock *bb = (struct BadBlockBlock *) &data[0];
   
   printf( "struct BadBlockBlock {\n\n" );
   printf( "\tULONG  bbb_ID            = 42414442 (\"BADB\");\n" );
   printf( "\tULONG  bbb_SummedLongs   = %08LX;\n", bb->bbb_SummedLongs );
   printf( "\tULONG  bbb_ChkSum        = %08LX;\n", bb->bbb_ChkSum );
   printf( "\tULONG  bbb_HostID        = %08LX;\n", bb->bbb_HostID );
   printf( "\tULONG  bbb_Next          = %08LX;\n", bb->bbb_Next );
   printf( "\tULONG  bbb_Reserved      = %08LX;\n", bb->bbb_Reserved );
   
   printf( "\tstruct BadBlockEntry bbb_BlockPairs[61] = { \n\n" );

   for (i = 0; i < 61; i ++)
      {
      printf( "\t\tULONG bbe_BadBlock  = %08LX;\n", bb->bbb_BlockPairs[i].bbe_BadBlock );
      printf( "\t\tULONG bbe_GoodBlock = %08LX;\n", bb->bbb_BlockPairs[i].bbe_GoodBlock );
      }

   printf( "\n\t};\n" );
   printf( "\n};\n" );

   return;
}
   
PRIVATE void PrintPART( UBYTE *data )
{
   struct PartitionBlock *p = (struct PartitionBlock *) &data[0];
   int                    i = 0;
      
   printf( "struct PartitionBlock {\n\n" );
   printf( "\tULONG  pb_ID            = 50415254 (\"PART\");\n" );
   printf( "\tULONG  pb_SummedLongs   = %08LX;\n", p->pb_SummedLongs );
   printf( "\tULONG  pb_ChkSum        = %08LX;\n", p->pb_ChkSum );
   printf( "\tULONG  pb_HostID        = %08LX;\n", p->pb_HostID );
   printf( "\tULONG  pb_Next          = %08LX;\n", p->pb_Next );
   printf( "\tULONG  pb_Flags         = %08LX;\n", p->pb_Flags );
   printf( "\tULONG  pb_Reserved1[2]  = %08LX;\n", p->pb_Reserved1[0] );
   printf( "\t                          %08LX;\n", p->pb_Reserved1[1] );
   printf( "\tULONG  pb_DevFlags      = %08LX;\n", p->pb_DevFlags );

   printf( "\tUBYTE  pb_DriveName[32] = \"%s\";\n", GetBString( (UBYTE *) p->pb_DriveName, 32 ));

   printf( "\tULONG  pb_Reserved2[15]  = {\n\n\t\t" );

   for (i = 0; i < 15; i++)   
      {
      printf( "%08LX", p->pb_Reserved2[i] );

      if ((i + 1) % 4 == 0 && i != 0)
         printf( ",\n\t\t" );
      else
         printf( ",  " );
      }

   printf( "\n\t};\n" );      

#  ifdef __amigaos4__      
   printf( "\tULONG  pb_Environment[20] = {\n\n\t\t" );

   for (i = 0; i < 20; i++)   
#  else
   printf( "\tULONG  pb_Environment[17] = {\n\n\t\t" );

   for (i = 0; i < 17; i++)   
#  endif
      {
      printf( "%08LX", p->pb_Environment[i] );

      if ((i + 1) % 4 == 0 && i != 0)
         printf( ",\n\t\t" );
      else
         printf( ",  " );
      }

   printf( "\n\t};\n" );

#  ifdef __amigaos4__
   printf( "\tULONG  pb_EReserved[12]   = {\n\n\t\t" );

   for (i = 0; i < 12; i++)   
#  else
   printf( "\tULONG  pb_EReserved[15]   = {\n\n\t\t" );

   for (i = 0; i < 15; i++)   
#  endif
      {
      printf( "%08LX", p->pb_EReserved[i] );

      if ((i + 1) % 4 == 0 && i != 0)
         printf( ",\n\t\t" );
      else
         printf( ",  " );
      }

   printf( "\n\t};\n" );
      
   printf( "\n};\n" );

   return;
}

PRIVATE void PrintFSHD( UBYTE *data )
{
   struct FileSysHeaderBlock *f = (struct FileSysHeaderBlock *) &data[0];
   int                        i = 0;
   
   printf( "struct FileSysHeaderBlock {\n\n" );
   printf( "\tULONG  fhb_ID            = 46534844 (\"FSHD\");\n" );
   printf( "\tULONG  fhb_SummedLongs   = %08LX;\n", f->fhb_SummedLongs );
   printf( "\tULONG  fhb_ChkSum        = %08LX;\n", f->fhb_ChkSum );
   printf( "\tULONG  fhb_HostID        = %08LX;\n", f->fhb_HostID );
   printf( "\tULONG  fhb_Next          = %08LX;\n", f->fhb_Next );
   printf( "\tULONG  fhb_Flags         = %08LX;\n", f->fhb_Flags );
   printf( "\tULONG  fhb_Reserved1[2]  = %08LX;\n", f->fhb_Reserved1[0] );
   printf( "\t                           %08LX;\n", f->fhb_Reserved1[1] );
   printf( "\tULONG  fhb_DosType       = %08LX;\n", f->fhb_DosType );
   printf( "\tULONG  fhb_Version       = %08LX;\n", f->fhb_Version );
   printf( "\tULONG  fhb_PatchFlags    = %08LX;\n", f->fhb_PatchFlags );
   printf( "\tULONG  fhb_Type          = %08LX;\n", f->fhb_Type );
   printf( "\tULONG  fhb_Task          = %08LX;\n", f->fhb_Task );
   printf( "\tULONG  fhb_Lock          = %08LX;\n", f->fhb_Lock );
   printf( "\tULONG  fhb_Handler       = %08LX;\n", f->fhb_Handler );
   printf( "\tULONG  fhb_StackSize     = %08LX;\n", f->fhb_StackSize );
   printf( "\tULONG  fhb_Priority      = %08LX;\n", f->fhb_Priority );
   printf( "\tULONG  fhb_Startup       = %08LX;\n", f->fhb_Startup );
   printf( "\tULONG  fhb_SegListBlocks = %08LX;\n", f->fhb_SegListBlocks );
   printf( "\tULONG  fhb_GlobalVec     = %08LX;\n", f->fhb_GlobalVec );

   printf( "\tULONG  fhb_Reserved2[23] = {\n\n\t\t" );

   for (i = 0; i < 23; i++)   
      {
      printf( "%08LX", f->fhb_Reserved2[i] );
      if ((i + 1) % 4 == 0 && i != 0)
         printf( ",\n\t\t" );
      else
         printf( ",  " );
      }

#  ifdef __amigaos4__
   printf( "\tchar   fhb_FileSysName[84] = \"%s\";\n", &f->fhb_FileSysName[0] );
#  endif

   printf( "\n\t};\n" );

#  ifndef __amigaos4__      
   printf( "\tULONG  fhb_Reserved3[21]  = {\n\n\t\t" );

   for (i = 0; i < 21; i++)   
      {
      printf( "%08LX", f->fhb_Reserved3[i] );

      if ((i + 1) % 4 == 0 && i != 0)
         printf( ",\n\t\t" );
      else
         printf( ",  " );
      }
#  endif

   printf( "\n\t};\n" );
   printf( "\n};\n" );

   return;
}

PRIVATE void PrintLSEG( UBYTE *data )
{
   struct LoadSegBlock *s = (struct LoadSegBlock *) &data[0];
   int                  i = 0;
   
   printf( "struct LoadSegBlock {\n\n" );
   printf( "\tULONG  lsb_ID            = 4C534547 (\"LSEG\");\n" );
   printf( "\tULONG  lsb_SummedLongs   = %08LX;\n", s->lsb_SummedLongs );
   printf( "\tULONG  lsb_ChkSum        = %08LX;\n", s->lsb_ChkSum );
   printf( "\tULONG  lsb_HostID        = %08LX;\n", s->lsb_HostID );
   printf( "\tULONG  lsb_Next          = %08LX;\n", s->lsb_Next );

   printf( "\tULONG  lsb_LoadData[123] = {\n\n\t\t" );

   for (i = 0; i < 123; i++)
      {
      printf( "%08LX", s->lsb_LoadData[i] );

      if ((i + 1) % 4 == 0 && i != 0)
         printf( ",\n\t\t" );
      else
         printf( ",  " );
      }

   printf( "\n\t};\n" );
   printf( "\n};\n" );

   return;
}

#ifdef __amigaos4__
PRIVATE void PrintBootstrapCodeBlock( UBYTE *data )
{
   struct BootstrapCodeBlock *s = (struct BootstrapCodeBlock *) &data[0];
   int                        i = 0;
   
   printf( "struct BootstrapCodeBlock {\n\n" );
   printf( "\tULONG  bcb_ID            = 424F4F54 (\"BOOT\");\n" );
   printf( "\tULONG  bcb_SummedLongs   = %08LX;\n", s->bcb_SummedLongs );
   printf( "\tULONG  bcb_ChkSum        = %08LX;\n", s->bcb_ChkSum );
   printf( "\tULONG  bcb_HostID        = %08LX;\n", s->bcb_HostID );
   printf( "\tULONG  bcb_Next          = %08LX;\n", s->bcb_Next );

   printf( "\tULONG  bcb_LoadData[123] = {\n\n\t\t" );

   for (i = 0; i < 123; i++)
      {
      printf( "%08LX", s->bcb_LoadData[i] );

      if ((i + 1) % 4 == 0 && i != 0)
         printf( ",\n\t\t" );
      else
         printf( ",  " );
      }

   printf( "\n\t};\n" );
   printf( "\n};\n" );

   return;
}
#endif

PRIVATE ULONG GetLong( UBYTE *data )
{
   ULONG result = 0;
   
   result = data[3] + (data[2] << 8) + (data[1] << 16) + (data[0] << 24);

   return( result );
}

PRIVATE void PrintBlock( UBYTE *data )
{
   char   *s, buffer[1024];
   UBYTE  *p, d;
   UWORD  i, j;
   ULONG  BlockType = IDNAME_RIGIDDISK;
   
   BlockType = GetLong( &data[0] );
   
   switch (BlockType)
      {
      case IDNAME_RIGIDDISK:
         PrintRDB( data );
         break;
         
      case IDNAME_BADBLOCK:
         PrintBADB( data );
         break;
   
      case IDNAME_PARTITION:
         PrintPART( data );
         break;
         
      case IDNAME_FILESYSHEADER:
         PrintFSHD( data );
         break;
         
      case IDNAME_LOADSEG:
         PrintLSEG( data );
         break;

#     ifdef __amigaos4__
      case IDNAME_BOOTSTRAPCODE:
         PrintBootstrapCodeBlock( data );
	 break;
#     endif
	 
      default:
         buffer[70] = '\0';

         for (p = data, i = 0; i < TD_SECTOR; i += 16)
            {
            sprintf( buffer, "%03X:", i );

            (void) memset( buffer + 4, ' ', 66 ); // It's all a blank!!

            for (s = buffer + 4, j = 0; j < 16; s += 3, ++j)
               {
               sprintf( s, " %02X", d = *p++ );
               buffer[53 + j] = d >= 32 && d <= 126 || d >= 160 ? d : '.';
               }

            *s = ' ';
            printf( "%s\n", buffer);
            }
      }

   return;
}

PRIVATE void ShutdownProgram( BOOL deviceOpened )
{
   if (deviceOpened)
      CloseDevice( (struct IORequest *) io );

   if (io)
      DeleteStdIO( (struct IORequest *) io );

   if (mp)
      DeletePort( mp );

   if (data)
      FreeVec( data );

   return;
}

PRIVATE int SetupProgram( STRPTR deviceName, ULONG unitNumber )
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

      ShutdownProgram( FALSE );

      goto exitSetupProgram;
      }

   if (!(io = (struct IOStdReq *) CreateStdIO( mp )))
      {
      rval = IoErr();

      ShutdownProgram( FALSE );

      goto exitSetupProgram;
      }

   if (OpenDevice( deviceName, unitNumber, (struct IORequest *) io, 0 ))
      {
      rval = ERROR_DEVICE_NOT_MOUNTED; // IoErr();

      ShutdownProgram( FALSE );
      }

exitSetupProgram:

   return( rval );
}

PRIVATE BOOL sendReadCommand( int blkNumber )
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

PRIVATE void blockProcessor( int startingBlock )
{
   int blk;

   for (blk = startingBlock; blk < RDB_LOCATION_LIMIT; blk++)
      {
      if (sendReadCommand( blk ) == TRUE)
         {
         printf( "\n" );
         PrintBlock( data );
         }
      }

   return;
}

#ifdef __amigaos4__

PRIVATE void processPartitions( int blk )
{
   struct PartitionBlock *pb = NULL;

   if (blk <= 0)
      return; // Short circuit this function.
      
   while (blk > 0)
      {
      // Now we process all of the Partitions until we get pb->pb_Next = 0xFFFFFFFF
      if (sendReadCommand( blk ) == TRUE)
         {
         printf( "\n" );
         PrintBlock( data );
	 }

      pb = (struct PartitionBlock *) data;

      blk = pb->pb_Next;
      }

   return;
}

PRIVATE void NewBlockProcessor( void )
{
   int numBlocks, blk, lastPartition = 0;

   if (sendReadCommand( 0 ) == TRUE)
      {
      printf( "\n" );
      PrintBlock( data ); // We got the 'RDSK' block processed.
      }

   if (firstPartitionBlkNum > RDB_LOCATION_LIMIT)
      {
      
      blk = 1;

      blockProcessor( blk );

      blk = RDB_LOCATION_LIMIT;
      
      while (blk < firstPartitionBlkNum)
         {
	 // On my HardDisk, there are 60 blocks before the first Partition block!
         if (sendReadCommand( blk ) == TRUE)
            {
            printf( "\n" );
            PrintBlock( data );
            }
	 else
	    break;
	    
	 blk++;
	 }

      blk = firstPartitionBlkNum;

      processPartitions( blk );
      }
   else
      {
      blockProcessor( 1 );
      }
   
   return;
}
#endif
     
PUBLIC int main( int argc, char *argv[] )
{
   int rval = RETURN_OK;
   
   if (argc == 0)
      return( RETURN_ERROR ); // No Workbench support (yet!)
   
   if (argc != 3)
      {
      fprintf( stderr, "USAGE:  %s DEVICENAME/A,UNITNUMBER/N\n", argv[0] );

      return( ERROR_REQUIRED_ARG_MISSING );
      }   

   TID = atoi( argv[2] );

   // Should probably get the User to pass in LUN & Board number as well.
   
   if (SetupProgram( argv[1], UNIT ) != RETURN_OK)
      {
      fprintf( stderr, "Could NOT setup %s program!\n", argv[0] );

      return( RETURN_FAIL );
      }
   else
      {
#     ifndef __amigaos4__
      blockProcessor( 0 );
#     else
      NewBlockProcessor();
#     endif
      }

   // ALWAYS make sure the motor is turned off!

   io->io_Command = TD_MOTOR;
   io->io_Length  = 0;

   (void) DoIO( (struct IORequest *) io );

   ShutdownProgram( TRUE ); // device was opened or else we would not get here!

   return( rval );
}

/* ----------------- END of ReadHardBlocks.c file! ------------------- */
