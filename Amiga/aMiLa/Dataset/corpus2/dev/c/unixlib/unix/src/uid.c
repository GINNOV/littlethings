#include "amiga.h"

uid_t getuid(void)
{
    return AMIGA_UID;
}

uid_t geteuid(void)
{
    return AMIGA_UID;
}

int setuid(uid_t uid)
{
    if (uid != AMIGA_UID)
        return -1;
    return 0;
}

int seteuid(uid_t euid)
{
    if (euid != AMIGA_UID)
        return -1;
    return 0;
}
