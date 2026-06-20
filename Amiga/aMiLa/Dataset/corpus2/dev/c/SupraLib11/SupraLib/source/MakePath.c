/****** MakePath *********************************************************
*
*   NAME
*       MakePath -- Creates all new directories in a path (V10)
*
*   SYNOPSIS
*       suc = MakePath(path)
*
*       BOOL = MakePath(char *);
*
*   FUNCTION
*       This function creates a whole specified path of directories.
*       It works similar to CreateDir() except that it can create
*       more subdirs at once. User does not have to care if all
*       sub dirs in a specified path already exist or not.
*
*   INPUTS
*       path - pointer to a path string to create. A path can be
*       relative to a current dir or absolute.
*
*   RESULT
*       suc - TRUE if succeeds (path was created). FALSE if a path
*       could not be created.
*
*   EXAMPLE
*
*       suc = MakePath("RAM:way/to/many/dirs");
*
*       The above function will try to make all non-existing dirs
*       in a path RAM:way/to/many/dirs.
*
*   SEE ALSO
*       CreateDir()
*
*********************************************************************/

#include<proto/dos.h>
#include<dos/dos.h>
#include<string.h>
  
BOOL MakePath(char *path)
{
char *p=path;
BPTR lock;
struct FileInfoBlock fib;
BOOL err=FALSE;

    do {
        p = strchr(p,'/');
        if (p != NULL) p[0] = '\0';
        if (lock = Lock(path, ACCESS_READ)) {
            if (Examine(lock, &fib)) {
                if (fib.fib_DirEntryType < 0) err = TRUE;
            } else err = TRUE;
            UnLock(lock);
            if (err) return(FALSE);
        } else if (lock = CreateDir(path)) {
            UnLock(lock);
        } else return(FALSE);
        if (p != NULL) {
            p[0] = '/';
            p++;
        }
    } while (p != NULL);

    return(TRUE);
}

