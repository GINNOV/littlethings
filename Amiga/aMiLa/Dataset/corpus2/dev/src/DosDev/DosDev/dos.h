
/*
 *  DOS.H
 */

#ifdef NOTDEF
#include "exec/types.h"
#include "exec/memory.h"
#include "libraries/dos.h"
#include "libraries/dosextens.h"
#include "libraries/filehandler.h"
#endif NOTDEF

/*
 *  ACTIONS which do not exist in dosextens.h but which indeed exist on
 *  the Amiga.
 */

#define ACTION_OPENRW	    1004
#define ACTION_OPENOLD	    1005
#define ACTION_OPENNEW	    1006
#define ACTION_CLOSE	    1007
#define ACTION_SEEK	    1008
#define ACTION_RAWMODE	    994
#define ACTION_MORECACHE    18
#define ACTION_FLUSH	    27

#define CTOB(x) (void *)(((long)(x))>>2)    /*	BCPL conversion */
#define BTOC(x) (void *)(((long)(x))<<2)

#define bmov(ss,dd,nn) CopyMem(ss,dd,nn)    /*	my habit	*/

#define DOS_FALSE   0
#define DOS_TRUE    -1

#define RAMFILE     struct _RAMFILE	    /*	less restrictive typedefs   */
#define FENTRY	    struct _FENTRY
#define LOCKLINK    struct _LL
#define MYFH	    struct _MYFH

typedef unsigned char	ubyte;		    /*	unsigned quantities	    */
typedef unsigned short	uword;
typedef unsigned long	ulong;

typedef struct Interrupt	INTERRUPT;
typedef struct Task		TASK;
typedef struct FileLock 	LOCK;	    /*	See LOCKLINK	*/
typedef struct FileInfoBlock	FIB;
typedef struct DosPacket	PACKET;
typedef struct Process		PROC;
typedef struct DeviceNode	DEVNODE;
typedef struct DeviceList	DEVLIST;
typedef struct DosInfo		DOSINFO;
typedef struct RootNode 	ROOTNODE;
typedef struct FileHandle	FH;
typedef struct MsgPort		PORT;
typedef struct Message		MSG;
typedef struct MinList		LIST;
typedef struct MinNode		NODE;
typedef struct DateStamp	STAMP;
typedef struct InfoData 	INFODATA;
typedef struct DosLibrary	DOSLIB;

#define FILE_DIR    1
#define FILE_FILE   -1


RAMFILE {
    NODE    node;
    RAMFILE *parent;
    char    *name;
    char    *comment;
    short   flags;
    short   type;	/*  -1 = file,	1 = dir, 0 = dummy entry    */
    short   locks;	/*  <0:exclusive 0:none >0:shared	    */
    ulong   protection;
    ulong   bytes;
    LIST    list;	/*  list of FENTRY's or RAMFILE's   */
    STAMP   date;
};

FENTRY {
    NODE    node;
    ubyte   *buf;
    ulong   bytes;
};

/*
 *  We use this structure to link locks together in a list for internal
 *  usage.  I could have use the link field in the lock structure as a
 *  real linked list, but didn't want to have to sequentially search the
 *  list to remove a node.
 *
 *  NOTE:   You CANNOT simply extend the FileLock (LOCK) structure.  Some
 *  programs assume it is sizeof(LOCK) big and break.  I found this out the
 *  hard way.
 */

LOCKLINK {
    NODE    node;
    LOCK    *lock;
};

MYFH {
    NODE    node;
    RAMFILE *file;	/*  file header     */
    FENTRY  *fentry;
    long    base;	/*  base of FENTRY	*/
    long    offset;	/*  offset into FENTRY	*/
};

/*
 *  (void *)  in Aztec C means 'pointer to anything'.  I use it
 *  extensively.
 */

extern void *AbsExecBase;

extern void *AllocMem(), *RemHead(), *CreatePort(), *GetMsg();
extern void *FindTask(), *Open(), *OpenLibrary();

extern void   *dosalloc(), *NextNode(), *GetHead();
extern void   freedata(), freeramfile(), ramunlock(), btos(), returnpacket();
extern LOCK *ramlock();
extern RAMFILE *searchpath(), *createramfile(), *getlockfile();

extern char *getpathelement();
extern char *typetostr();

