#include "amiga.h"
#include <string.h>

void bcopy(char *b1, char *b2, int length)
{
  /* Unoptimised version */
  memmove(b2, b1, length);
}
