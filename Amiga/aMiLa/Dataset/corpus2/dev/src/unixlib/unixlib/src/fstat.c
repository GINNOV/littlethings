#include "amiga.h"
#include <dos/dosextens.h>
#include <utility/tagitem.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <amiga/ioctl.h>

int fstat(int fd, struct stat *sbuf)
{
  BPTR fh;
  struct FileInfoBlock *fib;
  int ret;

  chkabort();
  if (ioctl(fd, _AMIGA_GET_FH, &fh) == -1) return -1;
  if ((fib = AllocDosObjectTags(DOS_FIB, TAG_END)) && ExamineFH(fh, fib))
    {
      _fibstat(fib, 0, sbuf);
      ret = 0;
    }
  else
    {
      int err = IoErr();

      if (err == ERROR_ACTION_NOT_KNOWN)
	/* Fake a stat result */
	{
	  ret = 0;
	  sbuf->st_dev = (long)(((struct FileHandle *)BADDR(fh))->fh_Type);
	  sbuf->st_ino = 0;
	  sbuf->st_mode = 0777;
	  sbuf->st_nlink = 1;
	  sbuf->st_uid = AMIGA_UID; sbuf->st_gid = AMIGA_GID;
	  sbuf->st_blksize = 512;
	  sbuf->st_blocks = 0;
	  sbuf->st_size = 0;
	  /* 1-Jan-1978 */
	  sbuf->st_ctime = sbuf->st_atime = sbuf->st_mtime = 252460800;
	}
      else
	{
	  ret = -1;
	  errno = convert_oserr(err);
	}
    }
  if (fib) FreeDosObject(DOS_FIB, fib);
  ioctl(fd, _AMIGA_FREE_FH, &fh);
  return ret;
}
