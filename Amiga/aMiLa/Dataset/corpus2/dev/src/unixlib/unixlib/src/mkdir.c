#include "amiga.h"
#include <stdarg.h>

int mkdir(char *name, mode_t mode)
{
  BPTR lock;
  long amode;

  chkabort();

  if (lock = CreateDir(name))
    {
      UnLock(lock);
      /* We remove script because mode 777 contains it by def, but it is
         meaningless for directories */
      amode = _make_protection(mode) & ~(FIBF_SCRIPT);
      if (SetProtection(name, _make_protection(mode))) return 0;
    }
  ERROR;
}
