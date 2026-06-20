#ifndef  CLIB_HDWRENCH_PROTOS_H
#define  CLIB_HDWRENCH_PROTOS_H

/*
**	$VER: hdwrench_protos.h 1.2 (6.10.1999)
**
**	C prototypes. For use with 32 bit integers only.
**
**	Copyright © 1999 Joanne B. Dow, Wizardess Designs, for license to Amiga, Inc.
**	    All Rights Reserved
*/

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

#ifndef  LIBRARIES_HDWRENCH_H
#include <libraries/hdwrench.h>
#endif
/* Open and close a device for use with other library functions */
BOOL HDWOpenDevice( STRPTR devName, ULONG unit );
VOID HDWCloseDevice( VOID );
/* Disk access functions */
UWORD RawRead( BootBlock *bbk, ULONG size );
UWORD RawWrite( BootBlock *bb );
UWORD WriteBlock( BootBlock *bb );
/* Disk RDB access functions */
UWORD ReadRDBs( VOID );
UWORD WriteRDBs( VOID );
/* Simple query functions. */
BOOL QueryReady( LONG *errorcode );
BOOL QueryInquiry( BYTE *inqbuf, LONG *errorcode );
BOOL QueryModeSense( LONG page, LONG msbsize, BYTE *msbuf, LONG *errorcode );
VOID QueryFindValid( ValidIDstruct *validIDs, STRPTR devicename, LONG board, ULONG types, LONG wide_scsi, LONG (*callBack)(HDWCallbackMsg*) );
BOOL QueryCapacity( ULONG *totalblocks, ULONG *blocksize );
/* File and memory IO for RDB information in the two formats recognized */
ULONG ReadMountfile( ULONG unit, STRPTR filename, STRPTR controller );
ULONG ReadRDBStructs( STRPTR filename, ULONG unit );
ULONG WriteMountfile( STRPTR filename, STRPTR ldir, ULONG unit );
ULONG WriteRDBStructs( STRPTR filename );
ULONG InMemMountfile( ULONG unit, STRPTR mfdata, STRPTR controller );
ULONG InMemRDBStructs( STRPTR rdbp, ULONG sizerdb, ULONG unit );
ULONG OutMemMountfile( STRPTR mfp, ULONG *sizew, ULONG sizeb, ULONG unit );
ULONG OutMemRDBStructs( STRPTR rdbp, ULONG *sizew, ULONG sizeb );
/* Complex query functions. */
BOOL FindDiskName( STRPTR diskname );
BOOL FindControllerID( STRPTR devname, ULONG *selfid );
ULONG FindLastSector( VOID );
ULONG FindDefaults( ULONG optimize, struct DefaultsArray *result );
/* The following two functions benefit from an active callback hook. */
/* Please see the HDW_CallBackMsgs.h file for suggested messages. */
ULONG LowlevelFormat( LONG (*callBack)(HDWCallbackMsg*) );
ULONG VerifyDrive( LONG (*callBack)(HDWCallbackMsg*) );

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif   /* CLIB_HDWRENCH_PROTOS_H */
