#include <string.h>

char *rindex(const char *str, int c)
{
    return strrchr(str, c);
}
