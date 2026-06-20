#include <libraries/dos.h>      /* For FileInfo struct */
#include <exec/memory.h>        /* For MEMF defines ... */
#include "types.h"
#include "stat.h"
#define ERROR	-1

/*
 *  Manx stat() currently isn't very unix compatible, so we roll our
 *  own...
 */

typedef struct stat STAT;

stat (path, buf)
char *path;
register STAT *buf;
{
    long lck;
    struct FileInfoBlock *fp;
    register long prot;
    register long ftime;
    extern long Lock ();
    extern void *AllocMem ();

    if ((lck = Lock (path, ACCESS_READ)) == 0) {
        return (-1);
    }
    fp = (struct FileInfoBlock *)
        AllocMem ((long) sizeof (struct FileInfoBlock),
        (long) (MEMF_CLEAR | MEMF_CHIP));
    Examine (lck, fp);
    if (fp -> fib_DirEntryType > 0) {
        buf -> st_mode = S_IFDIR;
    } else {
        buf -> st_mode = S_IFREG;
    }
    prot = ~(fp -> fib_Protection >> 1);
    prot &= 0x7;
    buf -> st_mode |= (prot << 6 | prot << 3 | prot);
    buf -> st_nlink = 1;
    buf -> st_size = fp -> fib_Size;
    ftime = fp -> fib_Date.ds_Days * (60L * 60L * 24L);
    ftime += fp -> fib_Date.ds_Minute * 60;
    ftime += fp -> fib_Date.ds_Tick / TICKS_PER_SECOND;
    buf -> st_atime = ftime;
    buf -> st_mtime = ftime;
    buf -> st_ctime = ftime;
    buf -> st_ino = 0;
    buf -> st_dev = 0;
    buf -> st_rdev = 0;
    buf -> st_uid = 0;
    buf -> st_gid = 0;
    FreeMem (fp, (long) sizeof (struct FileInfoBlock));
    UnLock (lck);
    return (0);
}

long fsize(name)
char *name;
{
	STAT	data;

	if(!access(name, 0x00)){
		stat( name, &data );
		return(data.st_size);
	}

	return(ERROR);
}

