#include "amiga.h"
#include <string.h>

int bcmp(char *b1, char *b2, int length)
{
  return length == 0 ? 0 : memcmp(b2, b1, length);
}
