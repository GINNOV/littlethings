#include "amiga.h"
#include <string.h>

void bcopy(const void *b1, void *b2, size_t length)
{
    /* Unoptimised version */
    memmove(b2, b1, length);
}
