#ifndef _FREECDDBCONFIG_PROTOS_H
#define _FREECDDBCONFIG_PROTOS_H

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
Object *hbar ( void );
Object *urlTextObject ( STRPTR url , STRPTR text );
Object *textObject ( STRPTR contents , STRPTR preParse , ULONG weight , ULONG font );
void __stdargs sprintf ( char *to , char *fmt , ...);

/* loc.c */
void ASM initStrings(REG(a0) struct libBase *base);

/* init.c */
ULONG SAVEDS ASM query ( REG (d0 )LONG which );
void ASM freeBase ( REG (a0 )struct libBase *base );
BOOL ASM initBase ( REG (a0 )struct libBase *base );

/* class.c */
BOOL ASM initClass ( REG (a0 )struct libBase *base );

#endif /* _FREECDDBCONFIG_PROTOS_H */
