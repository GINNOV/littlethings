#include "amiga.h"

gid_t getgid(void)
{
    return AMIGA_GID;
}

gid_t getegid(void)
{
    return AMIGA_GID;
}

int setgid(gid_t gid)
{
    if (gid != AMIGA_GID)
        return -1;
    return 0;
}

int setegid(gid_t egid)
{
    if (egid != AMIGA_GID)
        return -1;
    return 0;
}
