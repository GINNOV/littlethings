#ifndef _CLASS_PROTOS_H
#define _CLASS_PROTOS_H

/* various */
#define getreg __builtin_getreg
LONG getreg ( int );
ULONG DoSuperMethodA( struct IClass *, APTR , APTR );
ULONG DoSuperMethod( struct IClass *, APTR , ULONG , ...);
ULONG DoMethodA( APTR , APTR);
ULONG DoMethod( APTR , unsigned long MethodID, ... );
ULONG CoerceMethodA(APTR , APTR , APTR);
ULONG CoerceMethod(APTR , APTR , long MethodID, ... );
ULONG SetSuperAttrs(APTR, APTR , ULONG , ... );
void kprintf(char *,...);
#define debug kprintf

/* utils.c */
ULONG DoSuperNew ( struct IClass *cl , Object *obj , ULONG tag1 , ...);
ULONG getKeyChar ( STRPTR string );
Object *textObject ( ULONG help , STRPTR pp , BOOL clean );
Object *stringObject ( ULONG label , ULONG help , ULONG weight , ULONG max );
Object *hspace ( ULONG weight );
Object *hbar ( void );
Object *checkmarkObject ( ULONG key , ULONG help );
Object *cycleObject ( ULONG key , ULONG help , STRPTR *labels );
Object *buttonObject ( ULONG label , ULONG help );
void ASM stripDiscInfo ( REG (a0 )struct FREEDBS_DiscInfo *di );
void STDARGS sprintf ( char *to , char *fmt , ...);
int STDARGS snprintf ( char *buf , int size , char *fmt , ...);

/* loc.c */
STRPTR ASM getString ( REG (d0 )ULONG id );
void ASM initStrings ( REG(a0 )struct libBase *base );

/* init.c */
ULONG SAVEDS ASM query ( REG (d0 )LONG which );
void ASM freeBase ( REG (a0 )struct libBase *base );
BOOL ASM initBase ( REG (a0 )struct libBase *base );

/* titleslist.c */
BOOL ASM initTitlesListClass ( REG (a0 )struct libBase *base );

/* multimatcheslist.c */
BOOL ASM initMultiMatchesListClass ( REG (a0 )struct libBase *base );

/* bar.c */
BOOL ASM initBarClass ( REG (a0 )struct libBase *base );

/* edit.c */
BOOL ASM initEditClass ( REG (a0 )struct libBase *base );

/* discinfo.c */
BOOL ASM initDiscInfoClass ( REG (a0 )struct libBase *base );

/* mcc.c */
BOOL ASM initMCCClass ( REG (a0 )struct libBase *base );

/* mcp.c */
void ASM initMCPClass ( void );

#endif /* _CLASS_PROTOS_H */
