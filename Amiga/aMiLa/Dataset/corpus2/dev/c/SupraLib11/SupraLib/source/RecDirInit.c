/****** RecDirInit ******************************************
*
*   NAME
*       RecDirInit -- Initializes recursive files scanning process (V10)
*       (dos V36)
*
*   SYNOPSIS
*       error = RecDirInit(RecDirInfo)
*
*       UBYTE = RecDirInit(struct RecDirInfo *)
*
*   FUNCTION
*       This function is required to start scanning files through entire
*       or partial directory tree. It locks a directory path provided in
*       RecDirInfo structure, then files can be examined by calling
*       RecDirNext() function. Please see RecDirNext() for more
*       explanation on how this is useful.
*       You should initialize RecDirInfo by yourself, and you MUST set
*       rdi_Path, rdi_Num, and rdi_Pattern.
*
*   INPUTS
*       RecDirInfo - pointer to RecDirInfo structure, which should be
*       allocated and initialized before RecDirInit() is called.
*       You must set its rdi_Path field to starting directory path
*       you want to scan.
*       
*       Set rdi_Num for maximum number of directories you wish to scan
*       into. If you set rdi_Num to 1 it will only scan one level (that
*       rdi_Path points to). If you set rdi_Num to -1 it will scan
*       unlimited number of subdirectories deep.
*
*       If rdi_Pattern field is non-NULL and points to a string then
*       calling RecDirNext will only return files that match the
*       pattern string. NOTE that rdi_Pattern should point to a string
*       which has been parsed with ParsePattern().
*
*   RESULT
*       error - 0 if no error, otherwise returns one of the following
*       errors (also see libraries/supra.h):
*           RDI_ERR_FILE - Path provided in rdi_Path points to a file
*                          not directory.
*           RDI_ERR_NONEXIST - Path provided in rdi_Path does not exist.
*           RDI_ERR_MEM - not enough memory to execute RecDirInit().
*
*   EXAMPLE
*       Please see an example in RecDirNext() function.
*
*   NOTES
*       IMPORTANT: You MUST open dos.library before calling RecDirInit()!
*       rdi_Path is a path relative to a current path your program uses.
*       That means you can set rdi_Path to "" to scan from current
*       directory, or "/" to scan parent directory.
*
*   BUGS
*       None found yet.
*
*   SEE ALSO
*       RecDirFree(), RecDirNext(), libraries/supra.h
*
**************************************************************************/

#include <proto/exec.h>
#include <proto/dos.h>
#include <exec/memory.h>
#include <string.h>
#include <libraries/supra.h>

UBYTE RecDirInit(struct RecDirInfo *rdi)
{
    BPTR lock;
    struct FileInfoBlock *fib;
    struct LockNode *ln;
    char *lnPath;
    int len;

    if ((lock = Lock(rdi->rdi_Path, ACCESS_READ)) == NULL) return(RDI_ERR_NONEXIST);

    if (fib = AllocMem(sizeof(struct FileInfoBlock), 0L)) {
        if (Examine(lock, fib)) {
            if (fib->fib_DirEntryType > 0) { /* Directory */
                    if (ln = AllocMem(sizeof(struct LockNode), 0L)) {

                        /* Everything all right till now */
                        /* Now first prepare to copy a path */

                        if (lnPath = AllocMem(strlen(rdi->rdi_Path)+2, 0L)) {
                            strcpy(lnPath, rdi->rdi_Path);

                            /* Alter path's ending: check for slash etc. */
                            len = strlen(lnPath);
                            if (len > 0) {
                                if (lnPath[len-1] != '/' && lnPath[len-1] != ':') {
                                    strcat(lnPath,"/");
                                }
                            }

                            ln->ln_Succ = NULL;
                            ln->ln_Pred = NULL;
                            ln->ln_FIB  = fib;
                            ln->ln_Lock = lock;
                            ln->ln_Path = lnPath;
                            ln->ln_Len  = strlen(rdi->rdi_Path)+2;

                            rdi->rdi_Node = ln;
                            rdi->rdi_Deep = 1;
                            return(0);
                        }
                    }
            } else if (fib->fib_DirEntryType < 0) {   /* Path is file */
                FreeMem(fib, sizeof(struct FileInfoBlock));
                UnLock(lock);
                return(RDI_ERR_FILE); /* Indicate that path is a file not dir */
            }
        }
    }

    if (ln) FreeMem(ln,sizeof(struct LockNode));
    if (fib) FreeMem(fib, sizeof(struct FileInfoBlock));
    if (lock) UnLock(lock);

    return(RDI_ERR_MEM);   /* No success */
}


