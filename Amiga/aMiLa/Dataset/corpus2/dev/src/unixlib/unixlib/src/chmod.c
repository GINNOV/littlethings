#include "amiga.h"

int chmod(char *name, int mode)
{
  chkabort();
  if (SetProtection(name, _make_protection(mode))) return 0;
  ERROR;
}
