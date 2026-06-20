#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef DOS_DOS_H
#include <dos/dos.h>
#endif

#ifndef UTILITY_TAGITEM_H
#include <utility/tagitem.h>
#endif

#ifndef GRAPHICS_VIEW_H
#include <graphics/view.h>
#endif

#ifndef LIBRARIES_SUPRA_H
#define LIBRARIES_SUPRA_H


/**** MAKE NEW IMAGE ****/
struct Image *MakeNewImg(struct Image *, ULONG *);
void FreeNewImg(struct Image *);

/*** FileType ***/

LONG FileType(char *);


/*** MakePath ***/

BOOL MakePath(char *);


/****** FCOPY ******/
UBYTE FCopy(char *, char *, LONG);

/* Possible errors */
#define FC_ERR_EXIST 10     /* Source does not exist */
#define FC_ERR_EXAM  20     /* Error while examining a source file */
#define FC_ERR_MEM   30     /* Not enough memory available */
#define FC_ERR_OPEN  40     /* Could not open a source file */
#define FC_ERR_READ  50     /* Could not read a source file */
#define FC_ERR_DIR   60     /* Destination file path is a directory */
#define FC_ERR_DEST  70     /* Could not open/create a destination file */
#define FC_ERR_WRITE 80     /* Error while writing to destination file */



/*** RECURSIVE DIRECTORY SCANNING ***/

/* Procedures */
UBYTE RecDirInit(struct RecDirInfo *);
UBYTE RecDirNext(struct RecDirInfo *, struct RecDirFIB *);
UBYTE RecDirNextTagList(struct RecDirInfo *, struct RecDirFIB *, struct TagItem *);
UBYTE RecDirNextTags(struct RecDirInfo *, struct RecDirFIB *, ULONG, ...);
void RecDirFree(struct RecDirInfo *);
 

/* The following struct is initialized during RecDirInit routine,
 *and it contains neccesary information for using RecDirNext routine
 */
struct RecDirInfo {
    char *rdi_Path;    /* Path to scan from */
    char *rdi_Pattern; /* Matching pattern */
    int rdi_Num;       /* max number of subdirs to scan into. */
    /* The following fields are for system use only */
    struct LockNode *rdi_Node; /* last LockNode (FileInfoBlock) node */
    UWORD rdi_Deep;   /* number of locked items */
};


/* This struct holds information about scanned files. Fields are
 * fulfilled according to tag flags provided by RecDirNext call
 */
struct RecDirFIB {
    char *Name;
    char *Path;
    char *Full;
    ULONG *Size;
    ULONG *Flags;
    char *Comment;
    struct DateStamp *Date;
    ULONG *Blocks;
    UWORD *UID;
    UWORD *GID;
    struct FileInfoBlock *FIB;
};


/* This struct contains information about each subdirectory being
 * scanned. It is compatible with Node struct operation commands
 */
struct LockNode {
    struct LockNode *ln_Succ;  /* Parent structure, or NULL if no */
    struct LockNode *ln_Pred;  /* Child structure, or NULL if no */
    struct FileInfoBlock *ln_FIB;
    BPTR ln_Lock;
    char *ln_Path;             /* name of a directory */
    int ln_Len; /* Path's length */
};

/* Tags that tell which information should be provided when
 * calling RecDirNext routine.
 */

#define RD_Dummy      (TAG_USER)
#define RD_NAME       (RD_Dummy + 1)  /* File name only */
#define RD_PATH       (RD_Dummy + 2)  /* Path only (without file name) */
#define RD_FULL       (RD_Dummy + 3)  /* Path+File Name together */
#define RD_SIZE       (RD_Dummy + 4)  /* File size */
#define RD_FLAGS      (RD_Dummy + 5)  /* File protection flags */
#define RD_COMMENT    (RD_Dummy + 6)  /* File comment */
#define RD_DATE       (RD_Dummy + 7)  /* Creation date */
#define RD_BLOCKS     (RD_Dummy + 8)  /* Number of block a file uses */
#define RD_UID        (RD_Dummy + 9)  /* Owner's UID */
#define RD_GID        (RD_Dummy + 10)  /* Owner's GUD */
#define RD_FIB        (RD_Dummy + 11) /* FileInfoBlock */


/* SubDirNext errors */
#define DN_ERR_END       10       /* Scanning completed with no problems */
#define DN_ERR_EXAMINE   20       /* Examine failure */
#define DN_ERR_MEM       30       /* Not enough memory available */

/* RecDirInit errors */
#define RDI_ERR_FILE     10       /* Path of a FILE was provided */
#define RDI_ERR_NONEXIST 20       /* Path does not exist */
#define RDI_ERR_MEM      30       /* Memory error */


/**** ObtPens ****/
ULONG ObtPens(struct ColorMap *, ULONG *, ULONG *, struct TagItem *);

/**** RelPens ****/
void RelPens(struct ColorMap *, ULONG *, ULONG *);

/**** AddToolType ****/
char *AddToolType(struct DiskObject *, char *); 
#endif
