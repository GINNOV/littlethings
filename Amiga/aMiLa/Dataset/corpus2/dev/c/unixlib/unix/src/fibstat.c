#include "amiga.h"
#include "timeconvert.h"
#include <fcntl.h>
#include <time.h>
#include <sys/stat.h>

void 
_fibstat(struct FileInfoBlock *fib, int isroot, struct stat *sbuf, long dev)
{
    long protection = fib->fib_Protection;

    sbuf->st_dev = dev;
    sbuf->st_rdev = 0;
    sbuf->st_uid = AMIGA_UID;
    sbuf->st_gid = AMIGA_GID;
    sbuf->st_blksize = 512;
    sbuf->st_nlink = 1;
    sbuf->st_blocks = fib->fib_NumBlocks;
    /* Give directories an arbitrary size */
    if (fib->fib_Size == 0 && fib->fib_DirEntryType > 0)
	sbuf->st_size = 2048;
    else
	sbuf->st_size = fib->fib_Size;
    sbuf->st_ino = fib->fib_DiskKey;
    sbuf->st_ctime = sbuf->st_atime = sbuf->st_mtime = _amiga2gmt(&fib->fib_Date);

    switch (fib->fib_DirEntryType) {
	    /*case ST_SOFTLINK: sbuf->st_mode = S_IFLNK; break; */
	case ST_PIPEFILE:
	    sbuf->st_mode = S_IFIFO;
	    break;
	    /* If Examine wasn't braindead this would be the right test */
	case ST_ROOT:
	    sbuf->st_mode = S_IFDIR;
	    protection = 0;
	    break;
	default:
	    sbuf->st_mode = fib->fib_DirEntryType > 0 ? S_IFDIR : S_IFREG;
	    break;
    }
    /* Examine is braindead. You can't tell if you've examined a root directory
       (for which the protection flags are invalid) or not. */
    if (isroot)
	protection = 0;

    sbuf->st_mode |= _make_mode(protection);
}
