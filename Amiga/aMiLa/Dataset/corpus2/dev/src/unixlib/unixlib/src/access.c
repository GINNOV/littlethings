#include "amiga.h"
#include <utility/tagitem.h>
#include <sys/types.h>
#include <sys/stat.h>

int access(char *name, int mode)
{
  struct FileInfoBlock *fib;
  BPTR lock = 0;
  int ret = -1;

  chkabort();
  if ((fib = AllocDosObjectTags(DOS_FIB, TAG_END)) &&
      (lock = Lock(name, ACCESS_READ)) &&
      Examine(lock, fib))
    {
      struct stat sbuf;
      int fmode;
      BPTR parent = ParentDir(lock);
      int isroot = !parent;

      if (parent) UnLock(parent);
      _fibstat(fib, isroot, &sbuf);
      fmode = (sbuf.st_mode & (S_IREAD | S_IEXEC)) >> 6 |
	(sbuf.st_mode & (S_IWRITE >> 3)) >> 3;

      if ((fmode & mode) == mode) ret = 0;
      else errno = EACCES;
    }
  else errno = convert_oserr(IoErr());

  if (lock) UnLock(lock);
  if (fib) FreeDosObject(DOS_FIB, fib);
  return ret;
}
