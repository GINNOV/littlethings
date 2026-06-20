#include "amiga.h"
#include <pwd.h>

struct passwd _amiga_user = {
  NULL, "",
  AMIGA_UID, AMIGA_GID,
  0, "", NULL,
  NULL, NULL
  };

struct passwd *getpwuid(uid_t uid) { return &_amiga_user; }
struct passwd *getpwnam(char *name) { return &_amiga_user; }
char *getlogin(void) { return _amiga_user.pw_name; }
