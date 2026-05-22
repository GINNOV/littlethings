/****** FileType ****************************************************
*
*   NAME
*       FileType -- Examines if a file is a directory or a file (V10)
*
*   SYNOPSIS
*       type = FileType(filename)
*
*       LONG = FileType(char *);
*
*   FUNCTION
*       Will use dos.library's Examine() function to determine
*       whether a specified file(path) exists, and if it is a file
*       or a directory.
*
*   INPUTS
*       filename - pointer to a filename string
*
*   RESULT
*       returns 0 if specified file/path does not exist. If < 0, then
*       it is a plain file. If > 0 a directory.
*       This function actually returns fib_DirEntryType (from
*       struct FileInfoBlock).
*
*   EXAMPLE
*
*       type = FileType("SYS:System");
*
*       type will be > 0, which means that "SYS:System" is a dir.
*
*******************************************************************/


#include<proto/dos.h>
#include<dos/dos.h>

LONG FileType(char *file)
{
    struct FileInfoBlock fib;
    BPTR lock;
    LONG type=0;

    lock = Lock(file, ACCESS_READ);
    if (lock)
	{
        if (Examine(lock, &fib))
		{
            type = fib.fib_DirEntryType;
        }
        UnLock(lock);
    }

    return(type);
}



