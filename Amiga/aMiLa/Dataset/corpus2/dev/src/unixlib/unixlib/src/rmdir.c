#include "amiga.h"
#include <utility/tagitem.h>

int rmdir(char *name)
{
  struct FileInfoBlock *fib = 0;
  BPTR lock = 0;

  if ((fib = AllocDosObjectTags(DOS_FIB, TAG_END)) &&
      (lock = Lock(name, ACCESS_READ)) &&
      Examine(lock, fib))
    {
      int isdir = fib->fib_DirEntryType > 0;

      UnLock(lock);
      FreeDosObject(DOS_FIB, fib);

      if (isdir)
	{
	  if (DeleteFile(name)) return 0;
	  ERROR;
	}
      errno = ENOTDIR;
      return -1;
    }
  errno = convert_oserr(IoErr());

  if (lock) UnLock(lock);
  if (fib) FreeDosObject(DOS_FIB, fib);
  return -1;
}
