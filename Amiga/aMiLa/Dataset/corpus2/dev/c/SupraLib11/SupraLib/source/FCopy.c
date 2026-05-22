/****** FCopy **************************************************************
*
*   NAME
*       FCopy -- copies source file to destination file (V10)
*       (dos V36)
*
*       Please use FCopyTags() instead.
*
*   SYNOPSIS
*       error = FCopy(source, dest, buffer)
*
*       UBYTE = FCopy(char *, char *, LONG);
*
*   FUNCTION
*       This function works very similar to C:Copy program. It copies
*       a source file to a destination file.
*       Please see more powerful FCopyTags() function (asynchronous).
*
*   INPUTS
*       source - pointer to a source file name (with a relative or
*                absolute path)
*       dest - pointer to a destination file name
*       buffer - maximum size of a buffer (in bytes) to be
*                allocated for copying. If this buffer is 0, FCopy()
*                will try to allocate buffer a size of a source file,
*                or the largest memory block available. (this is the
*                fastest way).
*
*   RESULT
*       error - zero if no error. Function may return one of the
*       following error definitions:
*
*           FC_ERR_EXIST - Source file does not exist
*           FC_ERR_EXAM  - Error during examination of a source file
*           FC_ERR_MEM   - Not enough memory availabe
*           FC_ERR_OPEN  - Source file could not be oppened
*           FC_ERR_READ  - Error while reading a source file
*           FC_ERR_DIR   - Source file path is a directory
*           FC_ERR_DEST  - Destination file could not be created
*           FC_ERR_WRITE - Error while writing to a destination file
*
*   EXAMPLE
*
*       \* This example will copy a file c:dir to ram: with a new name
*        * list.
*        *\
*
*       UBYTE err;
*
*       if ((err = FCopy("C:Dir", "ram:list", 0)) == 0) {
*
*           no errors...
*
*       } else {
*           printf("Error: %d\n", err); \* Error occured during FCopy() *\
*
*       }
*
*   NOTES
*       If an error occurs then a destination file will not be deleted
*       if it has already been partly copied.
*
************************************************************************/

#include <exec/memory.h>
#include <proto/dos.h>
#include <proto/exec.h>
#include <libraries/supra.h>


UBYTE FCopy(char *source, char *dest, LONG buf)
{
struct FileInfoBlock fib;

LONG fsize, max;  /* part = One part of buffer */
APTR mem=NULL;
LONG len;
BPTR lock,fsource=NULL,fdest=NULL;
UBYTE err=0;

    if ((lock = Lock(source, ACCESS_READ)) == NULL) return(FC_ERR_EXIST);
    if (Examine(lock, &fib) == NULL) {
        UnLock(lock);
        return(FC_ERR_EXAM);
    }

    if (fib.fib_DirEntryType < 0) {
        fsize = fib.fib_Size;

        if (fdest = Open(dest, MODE_NEWFILE)) {

            if (buf == 0) max = AvailMem(MEMF_LARGEST);
            else max = buf;

            if (max > fsize) max = fsize;

            /* Allocate a buffer */
            while ((mem = AllocMem(max, 0L)) == NULL && max > 1024) max-=1024;

            if (mem) {

              if (fsource = OpenFromLock(lock)) {
                  /* Do the copying process */

                  do {
                      len = Read(fsource, mem, max);
                      if (len == -1) {
                          err = FC_ERR_READ;
                          break;
                      } else if (len == 0) break;

                       if ((LONG) Write(fdest, mem, len) != len) {
                          err = FC_ERR_WRITE;
                          break;
                      }
                  } while (TRUE);
              } else err = FC_ERR_OPEN; /* if OpenFromLock */
            } else err = FC_ERR_MEM; /* Not enough memory */
        } else err = FC_ERR_DEST;   /* if Destination File Open */
    } else err = FC_ERR_DIR;    /* If source is dir */

    if (fsource) Close(fsource);
    if (fdest) Close(fdest);
    if (lock) UnLock(lock);
    if (mem) FreeMem(mem, max);

    return(err);
}


