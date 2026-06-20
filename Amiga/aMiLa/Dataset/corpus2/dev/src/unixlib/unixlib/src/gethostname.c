#include "amiga.h"
#include <unistd.h>

extern char *_system_name;

int gethostname(char *buf, int len)
{
  strncpy(buf, _system_name, len);

  return 0;
}
