
#include "amiga.h"
#include <string.h>

void bzero(void *b, size_t length)
{
    memset(b, 0, length);
}
