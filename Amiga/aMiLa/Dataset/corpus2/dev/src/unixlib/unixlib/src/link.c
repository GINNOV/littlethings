#include "amiga.h"

int link(char *from, char *to)
{
  BPTR from_lock = Lock(from, ACCESS_READ);

  chkabort();
  if (from_lock)
    {
      int ok = MakeLink(to, from_lock, 0);

      UnLock(from_lock);
      if (ok) return 0;
    }
  ERROR;
}
