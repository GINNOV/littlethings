#include "amiga.h"
#include <grp.h>

static char *wheel_members[] = { "user", 0 };

static struct group wheel = {
  "wheel",
  "",
  AMIGA_GID,
  wheel_members
};

struct group *getgrgid(gid_t gid) { return &wheel; }
struct group *getgrnam(char *name) { return &wheel; }
