#include "amiga.h"
#include "files.h"
#include <fcntl.h>

int creat(char *file, int prot)
{
  chkabort();
  return open(file, O_WRONLY | O_CREAT | O_TRUNC, prot);
}
