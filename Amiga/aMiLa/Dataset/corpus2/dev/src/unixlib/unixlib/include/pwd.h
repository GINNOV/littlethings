#ifndef _PWD_H
#define _PWD_H

struct    passwd {
  char *pw_name;
  char *pw_passwd;
  uid_t pw_uid;
  gid_t pw_gid;
  int  pw_quota;
  char *pw_comment;
  char *pw_gecos;
  char *pw_dir;
  char *pw_shell;
};

struct passwd *getpwuid(uid_t uid);
struct passwd *getpwnam(char *name);

#endif
