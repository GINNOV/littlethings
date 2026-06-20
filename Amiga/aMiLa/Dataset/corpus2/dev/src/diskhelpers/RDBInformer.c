/****h* RDB-Informer.c [2.0] *******************************************
*
* NAME
*    RDB-Informer.c
*
* DESCRIPTION
*    Prints out information stored in the Rigid Disk Block of a device
*
*    Written in September 1994 by
*
*       David Balazic
*       v
*       Centiba 39
*       69220 Lendava
*       Slovenija
*
* This program is FreeWare.
* You may spread it as you like, but leave my name noticed.
*
* SYNOPSIS
*    RDB-Informer [[DEVICE] <device>] [[UNIT] <unit-nr>]
*
*    The default for DEVICE is 'scsi.device' and for UNIT '0'
*
*    Examples :
*    > RDB-Informer scsi.device unit 4
*    > RDB-Informer gvpscsi.device unit 6
*    > RDB-Informer unit 2                ; uses scsi.device unit 2
*    > RDB-Informer evolution.device      ; uses evolution.device unit 0
*
* HISTORY
*     16-Nov-2004 - Ported to AMigaOS4 & gcc by J.T. Steichen
*
* NOTES
*     $VER: RDB-Informer.c 2.0 (16-Nov-2004) by J.T. Steichen
************************************************************************
*
*/


#include <stdio.h>
#include <string.h>

#include <exec/types.h>

#include <AmigaDOSErrs.h>

#define    ALLOCATE
# include <Author.h>         // My personal information (JTS)
#undef     ALLOCATE

#include <devices/trackdisk.h>
#include <devices/hardblocks.h>

#include <dos/filehandler.h> // For struct DosEnvec *

#ifndef __amigaos4__

# include <clib/exec_protos.h>
# include <clib/dos_protos.h>

PRIVATE struct DosLibrary *DOSBase;

#else

# define __USE_INLINE__

# include <proto/exec.h>
# include <proto/dos.h>

IMPORT struct Library *SysBase;
IMPORT struct Library *DOSBase;

IMPORT struct ExecIFace *IExec;
IMPORT struct DOSIFace  *IDOS;

#endif

#define DEFAULT_BLOCKSIZE 512

PRIVATE struct MsgPort            *deviceMPort    = NULL;
PRIVATE struct IOExtTD            *deviceIO       = NULL;
PRIVATE BOOL                       deviceOpened   = FALSE;
PRIVATE UBYTE                      DeviceName[80] = "scsi.device";
PRIVATE ULONG                      DeviceUnit     = 0L;
PRIVATE ULONG                      BlockSize      = DEFAULT_BLOCKSIZE; // Until found to be otherwise! 

PRIVATE struct RigidDiskBlock      RDB;
PRIVATE struct BadBlockBlock       BBB;
PRIVATE struct PartitionBlock      PB;
PRIVATE struct FileSysHeaderBlock  FHB;
PRIVATE struct LoadSegBlock        LSB;

PRIVATE int                        RDBblok;
PRIVATE char                       cbf[ DEFAULT_BLOCKSIZE ];
PRIVATE ULONG                      countbytes, countblocks;

#ifndef __amigaos4__
PRIVATE STRPTR ver = "\0$VER: RDB-Informer 2.0 " __AMIGADATE__ " \x0A\x0D\0";
#else
PRIVATE STRPTR ver = "\0$VER: RDB-Informer 2.0 " __DATE__ " by J.T. Steichen\0";
#endif

#define ID1(p) (((p) & 0xFF000000) >> 24)
#define ID2(p) (((p) & 0xFF0000) >> 16)
#define ID3(p) (((p) & 0xFF00) >> 8)
#define ID4(p)  ((p) & 0xFF)

// --------- FUNCTIONS: ----------------------------------------------------------------

#ifndef __amigaos4__
PRIVATE int OpenLibs( void )
{
   if (!(DOSBase = (struct DosLibrary *) OpenLibrary( DOSNAME, 36L )))
      return FALSE;
  
   return TRUE;
}

void CloseLibs( void )
{
   if (DOSBase)
      CloseLibrary( (struct Library *) DOSBase );

   return;
}

#else // __amigaos4__ is DEFINED!!

PRIVATE void CloseLibs( void ) { return; }
PRIVATE int  OpenLibs(  void ) { return TRUE; }

#endif

PRIVATE void CloseDev( void )
{
   if (deviceOpened)
      CloseDevice( (struct IORequest *) deviceIO );

   if (deviceIO)
      DeleteIORequest( (struct IORequest *) deviceIO );

   if (deviceMPort)
      DeleteMsgPort( deviceMPort );

   return;
}

PRIVATE BOOL OpenDev( STRPTR deviceName, ULONG unit )
{
   BOOL rval = FALSE;

   deviceOpened = rval;
      
   if (!(deviceMPort = CreateMsgPort()))
      return( rval );
      
   if (!(deviceIO = (struct IOExtTD*) CreateIORequest( deviceMPort, sizeof( struct IOExtTD ))))
      {
      CloseDev();

      return( rval );
      }

   if (!OpenDevice( deviceName, unit, (struct IORequest *) deviceIO, 0 ))
      {
      rval = deviceOpened = TRUE; // Now we're in business!
      }
   else
      {
      CloseDev();
      }

   return( rval );
}

PRIVATE char *copyString( char *from, char *to, int nr )
{
   int cn = 0;

   while (((*(to + cn) = *(from + cn)) != 0) && ((cn + 1) < nr))
      cn++;
  
   *(to + cn + 1) = 0;
 
   return( to );
}

PRIVATE void partend( ULONG parts, int err )
{
   if (err)
      printf( "*** There are some errors in Partition Blocks !!!\n" );
  
   printf( "There are total %ld valid partitions on this drive.\n\n", parts );
   
   return;
}

PRIVATE void fsend( ULONG fs, int err )
{
   if (err)
      printf( "*** There are some errors in File System Header Blocks !!!\n" );
  
   printf( "There are total %d valid file systems stored on this drive.\n\n", fs );
   
   return;
}

PRIVATE char *BSTR2CSTR( UBYTE *bstr, char *buf )
{
   return copyString( (char *) (((ULONG) bstr) + 1), buf, bstr[0] );
}

PRIVATE int SumOK( ULONG *p )
{
   int   i;
   LONG  chk = 0;
   ULONG nr  = ((struct RigidDiskBlock *) p)->rdb_SummedLongs;

   if (nr > 555) // (sizeof( struct RigidDiskBlock ) / 4)
      return FALSE;

   for (i = 0; i < nr; i++)
      chk += (*p++);
  
   if (chk)
      return FALSE;

   return TRUE;
}

PRIVATE void badend( ULONG bad, int err )
{
   if (err)
      Printf( "*** There are some errors in Bad Block Blocks !!!\n" );
  
   Printf( "There are total %d valid Bad Block Replacements.\n\n", bad );

   return;
}

PRIVATE int readblok( ULONG *buf, ULONG blkn, ULONG ident )
{
   deviceIO->iotd_Req.io_Command = CMD_READ;
   deviceIO->iotd_Req.io_Flags   = 0;
   deviceIO->iotd_Req.io_Data    = buf;
   deviceIO->iotd_Req.io_Length  = BlockSize;
   deviceIO->iotd_Req.io_Offset  = blkn << TD_SECSHIFT;

   DoIO( (struct IORequest *) deviceIO );
 
   if (deviceIO->iotd_Req.io_Error == 0)
      {
      if (((struct RigidDiskBlock *) buf)->rdb_ID == ident)
         {
         if (SumOK( buf ))
            return 0;
     
         return 2;
         }
      else
         return 1;
      }
   else
      return 3;
}

PRIVATE ULONG countBB( void )
{
   int   c   = 0;
   ULONG cnt = 0;

   for (c = 0; c < 61; c++) //  && ((((&(BBB.bbb_BlockPairs[c])) - (&BBB)) >> 2) < BBB.bbb_SummedLongs); c++)
      {
      if (BBB.bbb_BlockPairs[c].bbe_BadBlock != 0xFFFFFFFF)
         cnt++;
      }

   return cnt;
}

PRIVATE int ReadRDB( void )
{
   struct RigidDiskBlock buf; // UBYTE buf[ DEFAULT_BLOCKSIZE ];
   BOOL                  RDBfound = FALSE;
   int                   blok     = 0, part = 0;

   do {
      deviceIO->iotd_Req.io_Command = CMD_READ;
      deviceIO->iotd_Req.io_Flags   = 0;
      deviceIO->iotd_Req.io_Data    = (UBYTE *) &buf;
      deviceIO->iotd_Req.io_Length  = BlockSize;
      deviceIO->iotd_Req.io_Offset  = blok << TD_SECSHIFT;

      DoIO( (struct IORequest *) deviceIO );

      RDBblok = blok;
      
      if (buf.rdb_ID == IDNAME_RIGIDDISK)
         RDBfound = TRUE;
      
      blok++;
      
      if (blok > RDB_LOCATION_LIMIT)
         break;
      
      }  while (RDBfound == FALSE);

   if (RDBfound == TRUE)
      {
      CopyMem( &buf, &RDB, DEFAULT_BLOCKSIZE );

      return TRUE;
      }
   else
      return FALSE;
}

#define RDB_FLAGS_MASK (RDBFF_LAST | RDBFF_LASTLUN | RDBFF_LASTTID | RDBFF_NORESELECT | RDBFF_DISKID | RDBFF_CTRLRID | RDBFF_SYNCH)

PRIVATE void PrintRDBFlags( ULONG flags )
{
   printf( " RDB Flags    = 0x%08LX =\n", flags );

   if (flags & RDBFF_LAST)
      printf( "                RDBF_LAST       - Last drive on this controller\n" );

   if (flags & RDBFF_LASTLUN)
      printf( "                RDBF_LASTLUN    - Last LUN on this SCSI-address\n" );
  
   if (flags & RDBFF_LASTTID)
      printf( "                RDBF_LASTTID    - Last SCSI-address on this SCSI bus\n" );
  
   if (flags & RDBFF_NORESELECT)
      printf( "                RDBF_NORESELECT - Does not support scsi reselection\n" );
   else
      printf( "                                - Drive supports scsi reselection\n" );

   if (flags & RDBFF_DISKID)
      printf( "                RDBF_DISKID     - RDB contains valid disk identification\n" );
  
   if (flags & RDBFF_CTRLRID)
      printf( "                RDBF_CTRLRID    - RDB contains valid controller identification\n" );
  
   if (flags & RDBFF_SYNCH)
      printf( "                RDBF_SYNCH      - Drive supports scsi synchronous mode\n" );
  
   if (flags & (~RDB_FLAGS_MASK))
      printf( "                *** some unknown flags !!!!\n" );

   return;
}

PRIVATE void ParseBADB( ULONG BADBblok )
{
   int   res, blokerr = 0;
   ULONG bnr, allbad = 0;

   do {
      printf( "Bad Block Block at block %d", BADBblok );

      res = readblok( (ULONG *) &BBB, BADBblok, IDNAME_BADBLOCK );
     
      if (res == 1)
         {
         printf( "\n   *** Wrong block ID !!\n" );
         badend( allbad, 1 );
         return;
         }
      
      if (res == 2)
         {
         printf( "\n   *** CheckSum error !!\n" );
         badend( allbad, 1 );
         return;
         }

      if (res == 3)
         {
         printf( "\n   *** Read error !!\n" );
         badend( allbad, 1 );
         return;
         }

      if (res == 0)
         {
         printf( "  ---  CheckSum is OK.\n\n" );
         bnr     = countBB();
         allbad += bnr;
         printf( " This Bad Block Block contains %d Bad Block replacements\n", bnr );
         BADBblok = BBB.bbb_Next;
         }
      else
         {
         badend( allbad, 1 );
         return;
         }

      } while (BADBblok != 0xFFFFFFFF);

   badend( allbad, 0 );
   
   return;
}

PRIVATE UBYTE nonChar[5] = "";

PRIVATE UBYTE *nonPrintChar( UBYTE ch )
{
   UBYTE hex[] = "0123456789ABCDEF";
   
   nonChar[0] ='\\';
   
   if (ch & 0xF0)
      nonChar[1] = '1';
   else
      nonChar[1] = '0';
      
   if (ch & 0x0F)
      nonChar[2] = hex[ (ch & 0x0F) ];
   else
      nonChar[2] = '0';
   
   nonChar[3] = '\0';
   
   return( &nonChar[0] );
}

PRIVATE void PrintPARTEnvironment( ULONG *inp )
{
   struct DosEnvec *DE  = (struct DosEnvec *) inp;
   ULONG            siz = DE->de_TableSize;
   ULONG            i   = 0;

   printf( "                                 DosEnvec block has %d entries\n", siz );

   printf( " SizeBlock      = 0x%08LX = %10d block size in longwords\n", DE->de_SizeBlock, DE->de_SizeBlock );

   if (++i >= siz)
      return;

   printf( " SecOrg         = 0x%08LX = %10d not used\n", DE->de_SecOrg, DE->de_SecOrg );
 
   if (++i >= siz)
      return;

   printf( " Surfaces       = 0x%08LX = %10d number of heads\n", DE->de_Surfaces, DE->de_Surfaces );
 
   if (++i >= siz)
      return;
  
   printf( " SectorPerBlock = 0x%08LX = %10d not used; must be 1\n", DE->de_SectorPerBlock, DE->de_SectorPerBlock );
 
   if (++i >= siz)
      return;

   printf( " BlocksPerTrack = 0x%08LX = %10d number of blocks per track\n", DE->de_BlocksPerTrack, DE->de_BlocksPerTrack);
 
   if (++i >= siz)
      return;

   printf( " Reserved       = 0x%08LX = %10d DOS reserved blocks at start of partition\n", DE->de_Reserved, DE->de_Reserved );
 
   if (++i >= siz)
      return;

   printf( " PreAlloc       = 0x%08LX = %10d DOS reserved blocks at end of partition\n", DE->de_PreAlloc, DE->de_PreAlloc );

   if (++i >= siz)
      return;
  
   printf( " Interleave     = 0x%08LX = %10d (usually 0)\n", DE->de_Interleave, DE->de_Interleave );
 
   if (++i >= siz)
      return;
  
   printf( " LowCyl         = 0x%08LX = %10d starting cylinder\n", DE->de_LowCyl, DE->de_LowCyl );
 
   if (++i >= siz)
      return;
 
   printf( " HighCyl        = 0x%08LX = %10d ending cylinder\n", DE->de_HighCyl, DE->de_HighCyl );
  
   if (++i >= siz)
      return;
 
   printf( " NumBuffers     = 0x%08LX = %10d initial number of buffers\n", DE->de_NumBuffers, DE->de_NumBuffers );
  
   if (++i >= siz)
      return;

   printf( " BufMemType     = 0x%08LX = %10d type of memory for buffers\n", DE->de_BufMemType, DE->de_BufMemType );

   if (++i >= siz)
      return;

   printf( " MaxTransfer    = 0x%08LX = %10d max number of bytes to transfer at a time\n", DE->de_MaxTransfer, DE->de_MaxTransfer );

   if (++i >= siz)
      return;
  
   printf( " Mask           = 0x%08LX = %10d address mask to block out certain memory\n", DE->de_Mask, DE->de_Mask );
 
   if (++i >= siz)
      return;
   
   printf( " BootPri        = 0x%08LX = %10d boot priority for autoboot\n", DE->de_BootPri, DE->de_BootPri );

   if (++i >= siz)
      return;

   if (ID4( DE->de_DosType ) < ' ')
      printf( " DosType        = 0x%08LX =   '%c%c%c%s' HEX string showing filesystem type\n",
                DE->de_DosType, ID1( DE->de_DosType ), ID2( DE->de_DosType ), 
	                        ID3( DE->de_DosType ), 
		                nonPrintChar( ID4( DE->de_DosType ) ) 
            );
   else
      printf( " DosType        = 0x%08LX =   '%c%c%c%c' HEX string showing filesystem type\n",
                DE->de_DosType, ID1( DE->de_DosType ), ID2( DE->de_DosType ), 
                                ID3( DE->de_DosType ), 
	   	                ID4( DE->de_DosType )
            );

   if (++i >= siz)
      return;
   
   printf( " Baud           = 0x%08LX = %10d baud rate for serial handler\n", DE->de_Baud, DE->de_Baud );
 
   if (++i >= siz)
      return;
   
   printf( " Control        = 0x%08LX = %10d control word for handler/filesystem\n", DE->de_Control, DE->de_Control );
 
   if (++i >= siz)
      return;
   
   printf( " BootBlocks     = 0x%08LX = %10d number of blocks containing boot code\n", DE->de_BootBlocks, DE->de_BootBlocks );
  
   if (++i >= siz)
      return;
   
   printf( " *** %d unknown entries !!\n", siz - i );
   
   return;
}

PRIVATE void PrintPARTFlags( ULONG flags )
{
   printf( " Flags          = 0x%08LX =\n", flags );

   printf( "                  PBF_BOOTABLE    - Partition is%sbootable\n", (flags & PBFF_BOOTABLE) ? " " : " NOT " );

   printf( "                  PBF_NOMOUNT     - Partition is%sautomaticaly mounted \n", (flags & PBFF_NOMOUNT) ? " NOT " : " " );

   if (flags & ~(PBFF_BOOTABLE | PBFF_NOMOUNT))
      printf( "                   *** some unknown flags present!!!!\n" );

   return;
}

PRIVATE void ParsePART( ULONG PARTblok )
{
   int   res     = -1;
   ULONG allpart = 0;

   do {
      printf( "Partition Block at block %d", PARTblok );

      res = readblok( (ULONG *) &PB, PARTblok, IDNAME_PARTITION );

      if (res == 1)
         {
         printf( "\n   *** Wrong block ID !!\n" );
         partend( allpart, 1 );
         return;
         }
      
      if (res == 2)
         {
         printf( "\n   *** CheckSum error !!\n" );
         partend( allpart, 1 );
         return;
         }

      if (res == 3)
         {
         printf( "\n   *** Read error !!\n" );
         partend( allpart, 1 );
         return;
         }

      if (res == 0)
         {
         allpart++;
         printf( "  ---  CheckSum is OK.\n" );
         printf( " Partition %s:\n", BSTR2CSTR( PB.pb_DriveName, cbf ) );
         
	 PrintPARTFlags( PB.pb_Flags );

         printf( " DevFlags       = 0x%08LX = %10d Preferred flags for OpenDevice\n",
                                    PB.pb_DevFlags, PB.pb_DevFlags
	       );
     
         PrintPARTEnvironment( PB.pb_Environment );

         printf( "\n" );
    
         PARTblok = PB.pb_Next;
         }
      else
         {
         partend( allpart, 1 );
         }
  
      } while (PARTblok != 0xFFFFFFFF);

   partend( allpart, 0 );
   
   return;
}

PRIVATE int countlen( ULONG LSEGblok )
{
   int res;

   do {
      res = readblok ((ULONG *) & LSB, LSEGblok, IDNAME_LOADSEG);
      
      if (res == 1)
         {
         printf( "   *** Wrong block ID at block %d.\n", LSEGblok );
         printf( "   *** Expected LoadSegBlock (ID = 'LSEG'). Got ID = '%c%c%c%c'.\n",
                     ID1( RDB.rdb_ID ), ID2( RDB.rdb_ID ),
                     ID3( RDB.rdb_ID ), ID4( RDB.rdb_ID )
	       );

         return FALSE;
         }

      if (res == 2)
         {
         printf( "   *** CheckSum error in block %d (LoadSegBlock).\n", LSEGblok );
         return FALSE;
         }

      if (res == 3)
         {
         printf( "   *** Read error at block %d (LoadSegBlock) !!\n" );
         return FALSE;
         }

      if (res == 0)
         {
         countblocks++;
         countbytes += (LSB.lsb_SummedLongs << 2)
                       - (ULONG) & (((struct LoadSegBlock *) 0L)->lsb_LoadData[0]);

         LSEGblok = LSB.lsb_Next;
         }
      else
         return FALSE;
      
      }  while (LSEGblok != 0xFFFFFFFF);

   return TRUE;
}

PRIVATE void ParseDINI( ULONG DINIblok )
{
   int res;

   printf( "Dive Init Code starting at block %d\n", DINIblok );

   countbytes = countblocks = 0;
 
   if (countlen( DINIblok ))
      {
      printf( " Size      = 0x%08LX = %10d bytes\n", countbytes, countbytes );
      printf( " Size      = 0x%08LX = %10d blocks\n", countblocks, countblocks );
     }

   return;
}

PRIVATE void ParseFSHD( ULONG FSHDblok )
{
   int   res   = -1, i;
   ULONG allfs = 0;

   do {
      printf( "File System Header Block at block %d", FSHDblok );

      res = readblok( (ULONG *) & FHB, FSHDblok, IDNAME_FILESYSHEADER );
     
      if (res == 1)
         {
         printf( "\n   *** Wrong block ID !!\n" );
         fsend( allfs, 1 );
         return;
         }

      if (res == 2)
         {
         printf( "\n   *** CheckSum error !!\n" );
         fsend( allfs, 1 );
         return;
         }
      
      if (res == 3)
         {
         printf( "\n   *** Read error !!\n" );
         fsend( allfs, 1 );
         return;
         }
 
      if (res == 0)
         {
         allfs++;
         printf( "  ---  CheckSum is OK.\n\n" );

         countbytes = countblocks = 0;
     
         if (countlen( FHB.fhb_SegListBlocks ))
            {
            printf( " Size      = 0x%08LX = %10d bytes\n", countbytes, countbytes );
            printf( " Size      = 0x%08LX = %10d blocks\n", countblocks, countblocks );
            printf( " Flags     = 0x%08LX = ?????\n", FHB.fhb_Flags );
            printf( " DosType   = 0x%08LX = '%c%c%c%c'\n",
                      FHB.fhb_DosType, ID1( FHB.fhb_DosType), ID2( FHB.fhb_DosType ),
                                       ID3( FHB.fhb_DosType), ID4( FHB.fhb_DosType )
		  );

            printf( " Version   = 0x%08LX = %5d.%-5d release version of this code\n", 
 	              FHB.fhb_Version, (FHB.fhb_Version & 0xFFFF0000) >> 16,
                      FHB.fhb_Version & 0xFFFF
		  );

            printf( " PatchFlags= 0x%08LX = ?????\n", FHB.fhb_PatchFlags );
            printf( " Type      = 0x%08LX = %10d device node type : zero\n", FHB.fhb_Type, FHB.fhb_Type );
            printf( " Task      = 0x%08LX = %10d DOS task field : zero\n", FHB.fhb_Task, FHB.fhb_Task );
            printf( " Lock      = 0x%08LX = %10d not used for devices : zero\n", FHB.fhb_Lock, FHB.fhb_Lock );
            printf( " Handler   = 0x%08LX = %10d filename to loadseg : zero placeholder\n", FHB.fhb_Handler, FHB.fhb_Handler );
            printf( " StackSize = 0x%08LX = %10d stacksize to use when starting task\n", FHB.fhb_StackSize, FHB.fhb_StackSize );
            printf( " Priority  = 0x%08LX = %10d task priority when starting task\n", FHB.fhb_Priority, FHB.fhb_Priority );
            printf( " Startup   = 0x%08LX = %10d startup message : zero placeholder\n", FHB.fhb_Startup, FHB.fhb_Startup );
            printf( " SegListBlocks=0x%08LX=%10d linked list of LoadSegBlocks\n", FHB.fhb_SegListBlocks, FHB.fhb_SegListBlocks);
            printf( " GlobalVec = 0x%08LX = %10d BCPL global vector when starting task\n",
                         FHB.fhb_GlobalVec, FHB.fhb_GlobalVec
	          );

            for (i = 0; i < 23; i++)
               printf( " Res2[%d]   = 0x%08LX              reserved\n", i, FHB.fhb_Reserved2[i] );

            printf( " FileSysName = %84.84s\n", &FHB.fhb_FileSysName[0] );

            printf( "\n");
            }
   
         FSHDblok = FHB.fhb_Next;
         }
      else
         {
         fsend( allfs, 1 );
         return;
         }
    
      } while (FSHDblok != 0xFFFFFFFF);

   fsend( allfs, 0 );
   
   return;
}

PRIVATE void PrintRDBInfo( STRPTR deviceName, ULONG unit )
{
   int i;
   
   printf( "\t\tHardDisk information for '%s' unit %d\n\n", deviceName, unit );

   printf( "\tRigid Disk Block found at block %d", RDBblok );

   if (SumOK( (ULONG *) &RDB ))
      {
      printf( "  ---  CheckSum is OK.\n\n" );

      printf( " ID           = 0x%08LX = '%c%c%c%c'     block identifier\n",
                RDB.rdb_ID, ID1( RDB.rdb_ID ), ID2( RDB.rdb_ID ), 
		            ID3( RDB.rdb_ID ), ID4( RDB.rdb_ID )
	    );

      printf( " SummedLongs  = 0x%08LX = %10d size of RDB structure\n", RDB.rdb_SummedLongs, RDB.rdb_SummedLongs );
      printf( " ChkSum       = 0x%08LX              block checksum\n", RDB.rdb_ChkSum );
     
      printf( " HostID       = 0x%08LX = %10d SCSI Target ID of host (controller)\n", RDB.rdb_HostID, RDB.rdb_HostID );
     
      printf( " BlockBytes   = 0x%08LX = %10d size of disk blocks\n",  RDB.rdb_BlockBytes, RDB.rdb_BlockBytes );
     
      PrintRDBFlags( RDB.rdb_Flags );

      printf( "\n\t--- Block list heads (0xFFFFFFFF or -1 is none): ---\n\n" );

#     ifndef __amigaos4__     
      printf( " BadBlockList      = 0x%08LX = %10d optional bad block list\n", RDB.rdb_BadBlockList, RDB.rdb_BadBlockList );
#     else
      printf( " BadBlockList      = 0x%08LX = %10d (OBSOLETE!)\n", RDB.rdb_Obsolete1, RDB.rdb_Obsolete1 );
#     endif
     
      printf( " PartitionList     = 0x%08LX = %10d optional first partition block\n", RDB.rdb_PartitionList, RDB.rdb_PartitionList);

      printf( " FileSysHeaderList = 0x%08LX = %10d optional file system header block\n", RDB.rdb_FileSysHeaderList, RDB.rdb_FileSysHeaderList);
      
      printf( " DriveInit         = 0x%08LX = %10d optional drive-specific init code\n", RDB.rdb_DriveInit, RDB.rdb_DriveInit);

#     ifdef __amigaos4__
      printf( " BootStrapCode     = 0x%08LX = %10d Secondary bootstrap code. Uses sector type BOOT\n", 
                                    RDB.rdb_BootStrapCode, RDB.rdb_BootStrapCode );

      for (i = 0; i < 5; i++)
         printf( "   Reserved1[%d]    = 0x%08LX\n", i, RDB.rdb_Reserved1[i] );
#     else
      for (i = 0; i < 6; i++)
         printf( "   Reserved1[%d]    = 0x%08LX\n", i, RDB.rdb_Reserved1[i] );
#     endif

      printf( "\n\t--- Physical drive characteristics: ---\n\n" );
      printf( " Cylinders    = 0x%08LX = %10d number of drive cylinders\n", RDB.rdb_Cylinders, RDB.rdb_Cylinders );
      printf( " Sectors      = 0x%08LX = %10d sectors per track\n", RDB.rdb_Sectors, RDB.rdb_Sectors );
      printf( " Heads        = 0x%08LX = %10d number of drive heads\n", RDB.rdb_Heads, RDB.rdb_Heads );
      printf( " Interleave   = 0x%08LX = %10d interleave\n", RDB.rdb_Interleave, RDB.rdb_Interleave );
      printf( " Park         = 0x%08LX = %10d landing zone cylinder\n", RDB.rdb_Park, RDB.rdb_Park );

//      for (i = 0; i < 3; i++)
//         printf( "   Reserved2[%d] = 0x%08LX\n", i, RDB.rdb_Reserved2[i] );

      printf( " WritePreComp = 0x%08LX = %10d starting cylinder: write precompensation\n", RDB.rdb_WritePreComp, RDB.rdb_WritePreComp);
      printf( " ReducedWrite = 0x%08LX = %10d starting cylinder: reduced write current\n", RDB.rdb_ReducedWrite, RDB.rdb_ReducedWrite);
      printf( " StepRate     = 0x%08LX = %10d drive step rate\n", RDB.rdb_StepRate, RDB.rdb_StepRate );

//      for (i = 0; i < 5; i++)
//         printf( "   Reserved3[%d] = 0x%08LX\n", i, RDB.rdb_Reserved3[i] );

      printf( "\n\t--- Logical drive characteristics ---\n\n" );
      printf( " RDBBlocksLo     = 0x%08LX = %10d low block of range reserved for these hardblocks\n",
                RDB.rdb_RDBBlocksLo, RDB.rdb_RDBBlocksLo
	    );

      printf( " RDBBlocksHi     = 0x%08LX = %10d high block of range reserved for these hardblocks\n",
                RDB.rdb_RDBBlocksHi, RDB.rdb_RDBBlocksHi
	    );

      printf( " LoCylinder      = 0x%08LX = %10d low cylinder of partitionable disk area\n",
                RDB.rdb_LoCylinder, RDB.rdb_LoCylinder
	    );

      printf( " HiCylinder      = 0x%08LX = %10d high cylinder of partitionable disk area\n",
                RDB.rdb_HiCylinder, RDB.rdb_HiCylinder
	    );

      printf( " CylBlocks       = 0x%08LX = %10d number of blocks per cylinder\n",
                RDB.rdb_CylBlocks, RDB.rdb_CylBlocks
	    );

      printf( " AutoParkSeconds = 0x%08LX = %10d zero means no autopark\n", RDB.rdb_AutoParkSeconds, RDB.rdb_AutoParkSeconds );
      printf( " HighRDSKBlock   = 0x%08LX = %10d highest block used by RDB\n", RDB.rdb_HighRDSKBlock, RDB.rdb_HighRDSKBlock );

      printf( " Reserved4       = 0x%08LX\n", RDB.rdb_Reserved4 );

      printf( "\n\t--- Drive/Disk identification : ---\n" );

      if (RDB.rdb_Flags & RDBFF_DISKID)
         {
         printf( "\n DiskVendor         = '%-8.8s'\n", copyString( RDB.rdb_DiskVendor, cbf, 8 ) );

         printf( " DiskProduct        = '%-16.16s'\n",  copyString( RDB.rdb_DiskProduct, cbf, 16 ) );
         printf( " DiskRevision       = '%-4.4s'\n",  copyString( RDB.rdb_DiskRevision, cbf, 4 ) );
         }
      else
         printf( "\t*** not present. ***\n" );

      printf( "\n\t--- Controller identification : ---" );

      if (RDB.rdb_Flags & RDBFF_CTRLRID)
         {
         printf( "\n ControllerVendor   = '%-8.8s'\n", copyString( RDB.rdb_ControllerVendor, cbf, 8 ));
         printf( " ControllerProduct  = '%-16.16s'\n", copyString( RDB.rdb_ControllerProduct, cbf, 16 ));
         printf( " ControllerRevision = '%-4.4s'\n", copyString( RDB.rdb_ControllerRevision, cbf, 4 ));
         }
      else
         printf( "\n\t*** not present. ***\n" );

      printf( "\n DriveInitName  = '%-40.40s'\n", copyString( RDB.rdb_DriveInitName, cbf, 40 ));

#     ifdef __amigaos4__
      printf( " BootStrapName  = '%-s'\n", copyString( RDB.rdb_BootStrapName, cbf, 108 ));

//      for (i = 0; i < 37; i++)
//         printf( "   Reserved5[%2d] = 0x%08LX\n", i, RDB.rdb_Reserved5[i] );
#     endif

      printf( "\n");

      if (RDB.rdb_BlockBytes != BlockSize)
         {
         printf( "\t*** Block sizes other than %d bytes not supported!! ***", DEFAULT_BLOCKSIZE );

         return;
         }

#     ifndef __amigaos4__
      if (RDB.rdb_BadBlockList != 0xFFFFFFFF)
         ParseBADB( RDB.rdb_BadBlockList );
#     endif

      if (RDB.rdb_PartitionList != 0xFFFFFFFF)
         ParsePART( RDB.rdb_PartitionList );

      if (RDB.rdb_FileSysHeaderList != 0xFFFFFFFF)
         ParseFSHD( RDB.rdb_FileSysHeaderList );

      if (RDB.rdb_DriveInit != 0xFFFFFFFF)
         ParseDINI( RDB.rdb_DriveInit );
      }
   else
      printf( "\n   *** CheckSum error !!\n" );

   return;
}

PUBLIC int main( int argc, char *argv[] )
{
   int rval = RETURN_OK;

   if (OpenLibs() == FALSE)
      {
      printf( "Can't open 'dos.library' version 36 !!!\n" );

      rval = ERROR_INVALID_RESIDENT_LIBRARY;

      goto ExitProgram;
      }

   if (argc > 0 && argc < 3)
      {
      fprintf( stderr, "USAGE:  %s DEVICENAME/a,UNITNUMBER/n\n", argv[0] );

      rval = ERROR_REQUIRED_ARG_MISSING;

      goto ExitProgram;
      }
   else if (argc > 0 && argc == 3)
      {
      strncpy( &DeviceName[0], argv[1], 80 );

      DeviceUnit = atoi( argv[2] );
      }

   if (OpenDev( &DeviceName[0], DeviceUnit ) == FALSE)
      {
      printf( "Can't open '%s' unit %d!\n", &DeviceName[0], DeviceUnit );
      
      rval = ERROR_DEVICE_NOT_MOUNTED;
      
      goto ExitProgram;
      }

   if (ReadRDB())
      {
      PrintRDBInfo( &DeviceName[0], DeviceUnit );
      }
   else
      printf( "Rigid Disk Block of '%s' unit %d not found.\n", &DeviceName[0], DeviceUnit );

ExitProgram:

   CloseDev();

   CloseLibs();

   fprintf( stderr, "\n\tWritten in Sep-1994 by David Balazic\n"
                    "\tCentiba 39\n"
                    "\t69220 Lendava\n"
                    "\tSlovenija\n\n"
		    "\t%s was Ported to AmigaOS4 (& gcc)\n\tby %s on (18-Nov-2004)\n"
		    "\tYou can reach me at:\n\t%s\n"
		    "\t%s\n\t%s\n\t%s\n\t%s\n",
		    argv[0], authorName, authorEMail, 
		    authorAddress, authorCity, authorState, authorZipCode
	  );

   
   return( rval );
}

/* --------------------- END of RDB-Informer.c file! -------------------------------- */ 
