#include "amiga.h"
#include <unistd.h>

extern char *_system_name;

char *strncpy(char *, const char *, size_t);

long gethostname(unsigned char *buf, long len)
{
    strncpy(buf, _system_name, len);

    return 0;
}
