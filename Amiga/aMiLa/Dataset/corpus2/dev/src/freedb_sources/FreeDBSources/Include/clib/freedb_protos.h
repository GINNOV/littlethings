#ifndef CLIB_FREEDB_PROTOS_H
#define CLIB_FREEDB_PROTOS_H

/*
**  $VER: freedb_protos.h 3.1 (12.12.2001)
**  Includes Release 3.1
**
**  C prototypes. For use with 32 bit integers only.
**
**  Written by Alfonso Ranieri
**  Released under the GNU Public Licence version 2
*/

#ifndef LIBRARIES_FREEDB_H
#include <libraries/freedb.h>
#endif

/* toc */
LONG FreeDBReadTOCA ( struct TagItem *attrs );
LONG FreeDBReadTOC ( Tag tag1 , ... );

/* objects */
APTR FreeDBAllocObjectA ( ULONG type , struct TagItem *attrs );
APTR FreeDBAllocObject ( ULONG type , Tag tag1 , ... );
void FreeDBClearObject ( APTR m );
void FreeDBFreeObject ( APTR m );

/* local cache */
LONG FreeDBGetLocalDiscA ( struct TagItem *attrs );
LONG FreeDBGetLocalDisc ( Tag tag1 , ... );
LONG FreeDBSaveLocalDiscA ( struct TagItem *attrs );
LONG FreeDBSaveLocalDisc ( Tag tag1 , ... );

/* remote */
APTR FreeDBHandleCreateA ( struct TagItem *attrs );
APTR FreeDBHandleCreate ( Tag tag1 , ... );
LONG FreeDBHandleCommandA ( APTR handle , ULONG cmd , struct TagItem *attrs );
LONG FreeDBHandleCommand ( APTR handle , ULONG cmd , Tag tag1 , ... );
ULONG FreeDBHandleSignal ( APTR handle );
LONG FreeDBHandleWait ( APTR handle );
void FreeDBHandleAbort ( APTR handle );
ULONG FreeDBHandleCheck ( APTR handle );
void FreeDBHandleFree ( APTR handle );
LONG FreeDBGetDiscA ( struct TagItem *attrs );
LONG FreeDBGetDisc ( Tag tag1 , ... );

/* config */
void FreeDBFreeConfig ( struct FREEDBS_Config *opts );
struct FREEDBS_Config *FreeDBReadConfig ( STRPTR name );
LONG FreeDBSaveConfig ( struct FREEDBS_Config *opts , STRPTR name );
LONG FreeDBConfigChanged ( void );

/* matches */
LONG FreeDBMatchA(struct match *match,struct FileInfoBlock **fib,struct TagItem *attrs);
APTR FreeDBMatchStartA(struct TagItem *attrs);
APTR FreeDBMatchStart(Tag tag1,...);
struct FREEDBS_DiscInfo * FreeDBMatchNext(APTR);
void FreeDBMatchEnd(APTR);

/* DiscInfo */
LONG FreeDBSetDiscInfoA ( struct FREEDBS_DiscInfo *di , struct TagItem *attrs );
LONG FreeDBSetDiscInfo ( struct FREEDBS_DiscInfo *di , Tag tag1 , ... );
LONG FreeDBSetDiscInfoTrackA ( struct FREEDBS_DiscInfo *di , ULONG t , struct TagItem *attrs );
LONG FreeDBSetDiscInfoTrack ( struct FREEDBS_DiscInfo *di , ULONG t , Tag tag1 , ... );

/* app */
APTR FreeDBCreateAppA ( struct TagItem *attrs );
APTR FreeDBCreateApp ( Tag tag1 ,  ... );

/* various */
STRPTR FreeDBGetString ( ULONG id );
void FreeDBFreeMessage ( APTR );
LONG FreeDBPlayMSFA ( struct TagItem *attrs );
LONG FreeDBPlayMSF ( Tag tag1 , ... );

#endif /* CLIB_FREEDB_PROTOS_H */
