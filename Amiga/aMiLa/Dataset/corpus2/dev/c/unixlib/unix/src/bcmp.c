#include "amiga.h"
#include <string.h>

int bcmp(const void *b1, const void *b2, size_t length)
{
    return length == 0 ? 0 : memcmp(b2, b1, length);
}
