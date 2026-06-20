#include <string.h>

char *rindex(char *str, int c)
{
  return strrchr(str, c);
}
