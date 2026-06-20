#include "amiga.h"
#include "files.h"
#include <fcntl.h>

int __creat(const char *file, int prot)
{
    __chkabort();
    return __open(file, O_WRONLY | O_CREAT | O_TRUNC, prot);
}
