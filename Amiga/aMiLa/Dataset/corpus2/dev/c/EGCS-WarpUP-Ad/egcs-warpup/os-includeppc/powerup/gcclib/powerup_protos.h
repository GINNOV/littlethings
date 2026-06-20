#ifndef POWERUP_GCCLIB_PROTOS_H
#define POWERUP_GCCLIB_PROTOS_H

#include <dos/dos.h>
#include <powerup/ppclib/interface.h>
#include <powerup/ppclib/object.h>
#include <utility/tagitem.h>

#ifndef  INTUITION_CLASSES_H
#include <intuition/classes.h>
#endif
#ifndef  INTUITION_CLASSUSR_H
#include <intuition/classusr.h>
#endif

#include <stdarg.h>

APTR	PPCAllocMem( unsigned long byteSize, unsigned long requirements );
void	PPCFreeMem( APTR memoryBlock, unsigned long byteSize );
APTR	PPCAllocVec( unsigned long byteSize, unsigned long requirements );
void	PPCFreeVec( APTR memoryBlock);
BPTR	PPCOutput(void);
BPTR	PPCInput(void);
BPTR	PPCOpen( STRPTR name, long accessMode );
LONG	PPCClose( BPTR file );
LONG	PPCRead( BPTR file, APTR buffer, long length );
LONG	PPCWrite( BPTR file, APTR buffer, long length );
LONG	PPCSeek( BPTR file, long position, long offset );
APTR	PPCCreatePool( unsigned long requirements, unsigned long puddleSize,
	unsigned long threshSize );
BOOL	PPCDeletePool( APTR poolHeader );
APTR	PPCAllocPooled( APTR poolHeader, unsigned long memSize );
void	PPCFreePooled( APTR poolHeader, APTR memory, unsigned long memSize );
APTR	PPCAllocVecPooled( APTR poolHeader, unsigned long memSize );
void	PPCFreeVecPooled( APTR poolHeader, APTR memory);
ULONG	PPCCallOS(struct Caos*);
ULONG	PPCCallM68k(struct Caos*);
ULONG	PPCSignal(void*,ULONG);
ULONG	PPCWait(ULONG);
void	*PPCFindTask(char*);
ULONG	PPCAllocSignal(ULONG);
void	PPCFreeSignal(ULONG);
void	PPCCacheFlush(APTR,ULONG);
void	PPCCacheFlushAll(void);
void	PPCCacheInvalid(APTR,ULONG);
ULONG	PPCSetSignal(ULONG,ULONG);
void	*PPCCreatePort(struct TagItem*);
BOOL	PPCDeletePort(void*);
void	*PPCObtainPort(struct TagItem*);
BOOL	PPCReleasePort(void*);
void	*PPCCreateMessage(void*,
                         ULONG);
void	PPCDeleteMessage(void*);
void	*PPCGetMessage(void*);
ULONG	PPCGetMessageAttr(void*,
                          ULONG);
BOOL	PPCReplyMessage(void*);
BOOL	PPCSendMessage(void*,
                       void*,
                       void*,
                       ULONG,
                       ULONG);
void	*PPCWaitPort(void*);

void*	PPCCreatePortList(void**,ULONG);
void	PPCDeletePortList(void*);
BOOL	PPCAddPortList(void*,
                       void*);
void	PPCRemPortList(void*,
                       void*);
void*	PPCWaitPortList(void*);
ULONG	PPCGetPortListAttr(void*,
                           ULONG);
void	PPCSetPortListAttr(void*,
                           ULONG,
                           ULONG);

#if !defined(__SASC)
int	strcmp(const char	*,
               const char	*);
char	*strcpy(char		*,
                const char	*);
int	strlen(const char	*);
#endif


/*
 * List functions for not shared and shared lists
 *
 */

void		PPCInsert(struct List	*,
                          struct Node	*,
                          struct Node	*);
void		PPCAddHead(struct List *,
                           struct Node *);
void		PPCAddTail(struct List *,
                           struct Node *);
void		PPCRemove(struct Node *);
struct Node*	PPCRemHead(struct List *);
struct Node*	PPCRemTail(struct List *);
void		PPCEnqueue(struct List*,
                           struct Node*);
struct Node*	PPCFindName(struct List*,
                            char*);
void		PPCNewList(struct List *);


void		PPCInsertSync(struct List	*,
                              struct Node	*,
                              struct Node	*);
void		PPCAddHeadSync(struct List *,
                               struct Node *);
void		PPCAddTailSync(struct List *,
                               struct Node *);
void		PPCRemoveSync(struct Node *);
struct Node*	PPCRemHeadSync(struct List *);
struct Node*	PPCRemTailSync(struct List *);
void		PPCEnqueueSync(struct List*,
                               struct Node*);
struct Node*	PPCFindNameSync(struct List*,
                                char*);

struct TagItem*	PPCNextTagItem(struct TagItem**);
struct TagItem*	PPCFindTagItem(Tag,
                               struct TagItem*);
ULONG	PPCGetTagData(Tag,
                      ULONG,
                      struct TagItem *);

ULONG	PPCVersion(void);
ULONG	PPCRevision(void);

void	PPCReleaseSemaphore(void*);
void	PPCObtainSemaphore(void*);
LONG	PPCAttemptSemaphore(void*);
BOOL	PPCAttemptSemaphoreShared(void*);
void	PPCObtainSemaphoreShared(void*);
void*	PPCCreateSemaphore(struct TagItem*);
void	PPCDeleteSemaphore(void*);
void*	PPCObtainSemaphoreByName(char*);
void*	PPCAttemptSemaphoreByName(char*,
                                  ULONG*);

APTR	PPCRawDoFmt(UBYTE*,
                    APTR,
                    void (*)(),
                    APTR);

ULONG	PPCGetTaskAttr(ULONG);
void	PPCSetTaskAttr(ULONG,
                       ULONG);

void	PPCFinishTask(void);

ULONG	PPCGetAttr(ULONG);

UBYTE	PPCReadByte(UBYTE*);
UWORD	PPCReadWord(UWORD*);
ULONG	PPCReadLong(ULONG*);

void	PPCWriteByte(UBYTE*,UBYTE);
void	PPCWriteWord(UWORD*,UWORD);
void	PPCWriteLong(ULONG*,ULONG);

ULONG	PPCCoerceMethodA(struct IClass*,
                         Object*,
                         Msg);

ULONG	PPCDoMethodA(Object*,
                     Msg);

ULONG	PPCDoSuperMethodA(struct IClass*,
                          Object*,
                          void*);

void	PPCkprintf(const char*,
                   ...);

int	PPCprintf(const char*,
                  ...);

int	PPCsprintf(char*,
                   const char*,
                   ...);

void	PPCvkprintf(const char*,
                    va_list);

int	PPCvprintf(const char*,
                   va_list);

int	PPCvsprintf(char*,
                    const char*,
                    va_list);

int	PPCfprintf(BPTR,
                   const char		*FmtString,
                   ...);

int	PPCvfprintf(BPTR,
                    const char*,
                    va_list);

void	*PPCCreateTask(void*,
                       void*,
                       struct TagItem*);

void	*PPCOpenLibrary(void*,
                        struct TagItem*);

void	PPCCloseLibrary(void*);
void	*PPCGetLibSymbol(void*,
                         char*);


void	*PPCLoadObjectTagList(struct TagItem*);
void	*PPCLoadObject(char*);
void	PPCUnLoadObject(void*);
ULONG	PPCGetObjectAttrs(void*,
                          struct PPCObjectInfo*,
                          struct TagItem*);

void*	PPCCreateTimerObject(struct TagItem*);
void	PPCDeleteTimerObject(void*);

#if !defined(__SASC)
void	PPCSetTimerObject(void*,
                          ULONG,
                          unsigned long long*);

void	PPCGetTimerObject(void*,
                          ULONG,
                          unsigned long long*);
#else
void	PPCSetTimerObject(void*,
                          ULONG,
                          ULONG*);

void	PPCGetTimerObject(void*,
                          ULONG,
                          ULONG*);
#endif


#if !defined(__SASC)

/* GCC 64bit math support
 * which is needed by the compiler
 */

int			__cmpdi2(long long, long long);
long long		__adddi3(long long, long long);
long long		__anddi3(long long, long long);
long long		__ashldi3(long long, unsigned int);
long long		__ashrdi3(long long, unsigned int);
long long		__lshldi3(long long, unsigned int);
long long		__lshrdi3(long long, unsigned int);
int			__cmpdi2(long long, long long );
long long		__divdi3(long long, long long);
long long		__fixdfdi(double);
long long		__fixsfdi(float);
unsigned long long	__fixunsdfdi(double);
unsigned long long	__fixunssfdi(float);
double			__floatdidf(long long);
float			__floatdisf(long long);
double			__floatunsdidf(unsigned long long);
long long		__iordi3(long long, long long);
long long		__moddi3(long long, long long);
long long		__muldi3(long long, long long);
long long		__negdi2(long long);
//long long		__one_cmpldi2(long long);
unsigned long long	__qdivrem(unsigned long long, unsigned long long, unsigned long long *);
long long		__subdi3(long long, long long);
int			__ucmpdi2(unsigned long long, unsigned long long);
unsigned long long	__udivdi3(unsigned long long, unsigned long long );
unsigned long long	__umoddi3(unsigned long long, unsigned long long );
long long		__xordi3(long long, long long);

long long	PPCAdd64(long long,long long);
long long	PPCSub64(long long,long long);
long long	PPCNeg64(long long);
BOOL		PPCCmp64(long long,long long);
long long	PPCMulu64(long long,long long);
long long	PPCDivu64(long long,long long);
long long	PPCMuls64(long long,long long);
long long	PPCDivs64(long long,long long);
long long	PPCModu64(long long,long long);
long long	PPCMods64(long long,long long);
long long	PPCLsr64(unsigned long long,unsigned int);
long long	PPCAsl64(long long,unsigned int);
long long	PPCAsr64(long long,unsigned int);
long long	PPCLsr64(unsigned long long,unsigned int);
long long	PPCOr64(unsigned long long,unsigned long long);
long long	PPCXor64(unsigned long long,unsigned long long);
long long	PPCAnd64(unsigned long long,unsigned long long);
long long	PPCDivRem64(long long,long long,long long*);

#else

/* SAS 64bit support
 * for every long long you get a ptr to a long long
 */
void		PPCAdd64p(int*,int*);
void		PPCSub64p(int*,int*);
void		PPCNeg64p(int*);
BOOL		PPCCmp64p(int*,int*);
void		PPCMulu64p(int*,int*);
void		PPCDivu64p(int*,int*);
void		PPCMuls64p(int*,int*);
void		PPCDivs64p(int*,int*);
void		PPCModu64p(int*,int*);
void		PPCMods64p(int*,int*);
void		PPCLsr64p(unsigned int*,unsigned int);
void		PPCAsl64p(int*,unsigned int);
void		PPCAsr64p(int*,unsigned int);
void		PPCLsl64p(unsigned int*,unsigned int);
void		PPCOr64p(unsigned int*,unsigned int*);
void		PPCXor64p(unsigned int*,unsigned int*);
void		PPCAnd64p(unsigned int*,unsigned int*);

void		PPCDivRem64p(int*,int*,int*);

#endif

#endif
