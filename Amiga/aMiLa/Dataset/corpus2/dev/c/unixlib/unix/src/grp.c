#include "amiga.h"
#include <grp.h>

static int accessed;

static char *wheel_members[] =
{"user", 0};

static struct group wheel =
{
    "wheel",
    "",
    AMIGA_GID,
    wheel_members
};

struct group *getgrgid(gid_t gid)
{
    return &wheel;
}
struct group *getgrnam(char *name)
{
    return &wheel;
}
struct group *getgrent(void)
{
    if (accessed)
        return NULL;
    accessed = 1;
    return &wheel;
}
int setgroupent(int stayopen)
{
    accessed = 0;
    return 1;
}
void setgrent(void)
{
    accessed = 0;
}
void endgrent(void)
{
    accessed = 0;
}
