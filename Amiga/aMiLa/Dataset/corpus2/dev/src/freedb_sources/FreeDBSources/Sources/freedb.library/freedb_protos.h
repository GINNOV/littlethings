#ifndef _FREEDB_PROTOS_H
#define _FREEDB_PROTOS_H

/* toc.c */
ULONG SAVEDS ASM findDevice ( REG (a0 )STRPTR name , REG (a1 )char *buf , REG (d0 )int bufSize , REG (a2 )UWORD *unit );
LONG SAVEDS ASM FreeDBReadTOCA ( REG (a0 )struct TagItem *attrs );

/* alloc.c */
APTR SAVEDS ASM FreeDBAllocObjectA ( REG (d0 )ULONG type , REG (a0 )struct TagItem *attrs );
void SAVEDS ASM FreeDBClearObject ( REG (a0 )APTR m );
void SAVEDS ASM FreeDBFreeObject ( REG (a0 )APTR m );

/* localdisc.c */
LONG SAVEDS ASM parseLine ( REG (a0 )struct FREEDBS_DiscInfo *di , REG (a1 )STRPTR line , REG (d0 )int l );
LONG ASM checkDiscInfo ( REG (a0 )struct FREEDBS_DiscInfo *di , REG (a1 )struct FREEDBS_TOC *toc );
LONG readLocalDisc ( STRPTR name , struct FREEDBS_DiscInfo *di , struct FREEDBS_TOC *toc , char *buf , ULONG bufSize );
LONG callMultiHook ( struct Hook *multiHook , struct FREEDBS_DiscInfo *di );
LONG SAVEDS ASM FreeDBGetLocalDiscA ( REG (a0 )struct TagItem *attrs );
LONG SAVEDS ASM FreeDBMakeHeader ( REG (a0 )struct TagItem *attrs );
LONG SAVEDS ASM FreeDBSaveLocalDiscA ( REG (a0 )struct TagItem *attrs );

/* cddbhandle.c */
struct FREEDBS_Handle *SAVEDS ASM FreeDBHandleCreateA ( REG (a0 )struct TagItem *attrs );
LONG SAVEDS ASM FreeDBHandleCommandA ( REG (a0 )struct FREEDBS_Handle *handle , REG (d0 )ULONG cmd , REG (a1 )struct TagItem *attrs );
ULONG SAVEDS ASM FreeDBHandleSignal ( REG (a0 )struct FREEDBS_Handle *handle );
LONG SAVEDS ASM FreeDBHandleWait ( REG (a0 )struct FREEDBS_Handle *handle );
void SAVEDS ASM FreeDBHandleAbort ( REG (a0 )struct FREEDBS_Handle *handle );
ULONG SAVEDS ASM FreeDBHandleCheck ( REG (a0 )struct FREEDBS_Handle *handle );
void SAVEDS ASM FreeDBHandleFree ( REG (a0 )struct FREEDBS_Handle *handle );
LONG SAVEDS ASM FreeDBHandleResult ( REG (a0 )struct FREEDBS_Handle *handle );
LONG SAVEDS ASM FreeDBGetDiscA ( REG (a0 )struct TagItem *attrs );

/* cddbproc.c */
APTR ASM allocMessage ( REG (d0 )ULONG size );
void SAVEDS ASM FreeDBFreeMessage ( REG (a0 )struct FREEDBS_GenericMessage *msg );
void SAVEDS FreeDBProc ( void );

/* lineread.c */
int ASM lineRead ( REG (a0 )struct lineRead *lr );
void ASM initLineRead ( REG (a0 )struct lineRead *lr , REG (a1 )struct Library *socketBase , REG (d0 )int fd , REG (d1 )int type , REG (d2 )int bufferSize );

/* sprintf.c */
int __stdargs snprintf ( char *buf , int size , char *fmt , ...);
void __stdargs sprintf ( char *to , char *fmt , ...);

/* loc.c */
STRPTR SAVEDS ASM FreeDBGetString ( REG (d0 )ULONG id );

/* options.c */
LONG ASM readConfig ( REG (a0 )struct FREEDBS_Config *opts , REG (a1 )STRPTR name );
void ASM printConfig ( REG (a0 )struct FREEDBS_Config *opts );
struct FREEDBS_Site *ASM insertSite ( REG (a0 )struct MinList *list , REG (a1 )struct FREEDBS_InsertSite *is );
void ASM freeSites ( REG (a0 )struct MinList *list );
struct FREEDBS_Config *SAVEDS ASM FreeDBObtainConfig ( REG (d0 )LONG shared );
void SAVEDS ASM FreeDBReleaseConfig ( void );
void SAVEDS ASM FreeDBFreeConfig ( REG (a0 )struct FREEDBS_Config *opts );
struct FREEDBS_Config *SAVEDS ASM FreeDBReadConfig ( REG (a0 )STRPTR name );
LONG SAVEDS ASM FREEDBSaveConfig ( REG (a0 )struct FREEDBS_Config *opts , REG (a1 )STRPTR name );
LONG SAVEDS ASM FreeDBConfigChanged ( void );

/* ap.c */
APTR ASM allocArbitratePooled ( REG (d0 )ULONG s );
void ASM freeArbitratePooled ( REG (a0 )APTR mem , REG (d0 )ULONG s );
APTR ASM allocArbitrateVecPooled ( REG (d0 )ULONG size );
void ASM freeArbitrateVecPooled ( REG (a0 )APTR mem );

/* playmsf.c */
LONG SAVEDS ASM FreeDBPlayMSFA ( REG (a0 )struct TagItem *attrs );

/* match.c */
struct match *SAVEDS ASM FreeDBMatchStartA ( REG (a0 )struct TagItem *attrs );
struct FREEDBS_DiscInfo *SAVEDS ASM FreeDBMatchNext ( REG (a0 )struct match *match );
void SAVEDS ASM FreeDBMatchEnd ( REG (a0 )struct match *match );

/* di.c */
LONG ASM SAVEDS FreeDBSetDiscInfoA ( REG (a0 )struct FREEDBS_DiscInfo *di , REG (a1 )struct TagItem *attrs );
LONG ASM SAVEDS FreeDBSetDiscInfoTrackA ( REG (a0 )struct FREEDBS_DiscInfo *di , REG (d0 )ULONG t , REG (a1 )struct TagItem *attrs );

/* freedb.c */
APTR SAVEDS ASM FreeDBCreateAppA ( REG (a0 )struct TagItem *attrs );

/* striptext.c */
void ASM stripText ( REG (a0 )STRPTR text );

#endif /* _FREEDB_PROTOS_H */
