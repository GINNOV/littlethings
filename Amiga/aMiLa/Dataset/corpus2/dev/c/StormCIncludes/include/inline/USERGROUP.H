#ifndef _INLINE_USERGROUP_H
#define _INLINE_USERGROUP_H

#ifndef USERGROUP_BASE_NAME
#define USERGROUP_BASE_NAME UserGroupBase
#endif

#define ug_SetupContextTagList(pname, taglist) \
	((int (*)(CONST_STRPTR __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) USERGROUP_BASE_NAME) - 30))(pname, taglist, (struct Library *) USERGROUP_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define ug_SetupContextTags(pname, tags...) \
	({ULONG _tags[] = {tags}; ug_SetupContextTagList((pname), () _tags);})
#endif

#define ug_GetErr() \
	((int (*)(struct Library * __asm("a6"))) \
  (((char *) USERGROUP_BASE_NAME) - 36))((struct Library *) USERGROUP_BASE_NAME)

#define ug_StrError(code) \
	((const char * (*)(LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) USERGROUP_BASE_NAME) - 42))(code, (struct Library *) USERGROUP_BASE_NAME)

#define getuid() \
	((uid_t (*)(struct Library * __asm("a6"))) \
  (((char *) USERGROUP_BASE_NAME) - 48))((struct Library *) USERGROUP_BASE_NAME)

#define geteuid() \
	((uid_t (*)(struct Library * __asm("a6"))) \
  (((char *) USERGROUP_BASE_NAME) - 54))((struct Library *) USERGROUP_BASE_NAME)

#define setreuid(real, eff) \
	((int (*)(uid_t __asm("d0"), uid_t __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) USERGROUP_BASE_NAME) - 60))(real, eff, (struct Library *) USERGROUP_BASE_NAME)

#define setuid(id) \
	((int (*)(uid_t __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) USERGROUP_BASE_NAME) - 66))(id, (struct Library *) USERGROUP_BASE_NAME)

#define getgid() \
	((gid_t (*)(struct Library * __asm("a6"))) \
  (((char *) USERGROUP_BASE_NAME) - 72))((struct Library *) USERGROUP_BASE_NAME)

#define getegid() \
	((gid_t (*)(struct Library * __asm("a6"))) \
  (((char *) USERGROUP_BASE_NAME) - 78))((struct Library *) USERGROUP_BASE_NAME)

#define setregid(real, eff) \
	((int (*)(gid_t __asm("d0"), gid_t __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) USERGROUP_BASE_NAME) - 84))(real, eff, (struct Library *) USERGROUP_BASE_NAME)

#define setgid(id) \
	((int (*)(gid_t __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) USERGROUP_BASE_NAME) - 90))(id, (struct Library *) USERGROUP_BASE_NAME)

#define getgroups(ngroups, groups) \
	((int (*)(int __asm("d0"), gid_t * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) USERGROUP_BASE_NAME) - 96))(ngroups, groups, (struct Library *) USERGROUP_BASE_NAME)

#define setgroups(ngroups, groups) \
	((int (*)(int __asm("d0"), const gid_t * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) USERGROUP_BASE_NAME) - 102))(ngroups, groups, (struct Library *) USERGROUP_BASE_NAME)

#define initgroups(name, basegroup) \
	((int (*)(const char * __asm("a1"), gid_t __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) USERGROUP_BASE_NAME) - 108))(name, basegroup, (struct Library *) USERGROUP_BASE_NAME)

#define getpwnam(name) \
	((struct passwd * (*)(const char * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) USERGROUP_BASE_NAME) - 114))(name, (struct Library *) USERGROUP_BASE_NAME)

#define getpwuid(uid) \
	((struct passwd * (*)(uid_t __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) USERGROUP_BASE_NAME) - 120))(uid, (struct Library *) USERGROUP_BASE_NAME)

#define setpwent() \
	((void (*)(struct Library * __asm("a6"))) \
  (((char *) USERGROUP_BASE_NAME) - 126))((struct Library *) USERGROUP_BASE_NAME)

#define getpwent() \
	((struct passwd * (*)(struct Library * __asm("a6"))) \
  (((char *) USERGROUP_BASE_NAME) - 132))((struct Library *) USERGROUP_BASE_NAME)

#define endpwent() \
	((void (*)(struct Library * __asm("a6"))) \
  (((char *) USERGROUP_BASE_NAME) - 138))((struct Library *) USERGROUP_BASE_NAME)

#define getgrnam(name) \
	((struct group * (*)(const char * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) USERGROUP_BASE_NAME) - 144))(name, (struct Library *) USERGROUP_BASE_NAME)

#define getgrgid(gid) \
	((struct group * (*)(gid_t __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) USERGROUP_BASE_NAME) - 150))(gid, (struct Library *) USERGROUP_BASE_NAME)

#define setgrent() \
	((void (*)(struct Library * __asm("a6"))) \
  (((char *) USERGROUP_BASE_NAME) - 156))((struct Library *) USERGROUP_BASE_NAME)

#define getgrent() \
	((struct group * (*)(struct Library * __asm("a6"))) \
  (((char *) USERGROUP_BASE_NAME) - 162))((struct Library *) USERGROUP_BASE_NAME)

#define endgrent() \
	((void (*)(struct Library * __asm("a6"))) \
  (((char *) USERGROUP_BASE_NAME) - 168))((struct Library *) USERGROUP_BASE_NAME)

#define crypt(key, salt) \
	((char * (*)(const char * __asm("a0"), const char * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) USERGROUP_BASE_NAME) - 174))(key, salt, (struct Library *) USERGROUP_BASE_NAME)

#define ug_GetSalt(user, buffer, size) \
	((char * (*)(const struct passwd * __asm("a0"), char * __asm("a1"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) USERGROUP_BASE_NAME) - 180))(user, buffer, size, (struct Library *) USERGROUP_BASE_NAME)

#define getpass(prompt) \
	((char * (*)(const char * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) USERGROUP_BASE_NAME) - 186))(prompt, (struct Library *) USERGROUP_BASE_NAME)

#define umask(mask) \
	((mode_t (*)(mode_t __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) USERGROUP_BASE_NAME) - 192))(mask, (struct Library *) USERGROUP_BASE_NAME)

#define getumask() \
	((mode_t (*)(struct Library * __asm("a6"))) \
  (((char *) USERGROUP_BASE_NAME) - 198))((struct Library *) USERGROUP_BASE_NAME)

#define setsid() \
	((pid_t (*)(struct Library * __asm("a6"))) \
  (((char *) USERGROUP_BASE_NAME) - 204))((struct Library *) USERGROUP_BASE_NAME)

#define getpgrp() \
	((pid_t (*)(struct Library * __asm("a6"))) \
  (((char *) USERGROUP_BASE_NAME) - 210))((struct Library *) USERGROUP_BASE_NAME)

#define getlogin() \
	((char * (*)(struct Library * __asm("a6"))) \
  (((char *) USERGROUP_BASE_NAME) - 216))((struct Library *) USERGROUP_BASE_NAME)

#define setlogin(buffer) \
	((int (*)(const char * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) USERGROUP_BASE_NAME) - 222))(buffer, (struct Library *) USERGROUP_BASE_NAME)

#define setutent() \
	((void (*)(struct Library * __asm("a6"))) \
  (((char *) USERGROUP_BASE_NAME) - 228))((struct Library *) USERGROUP_BASE_NAME)

#define getutent() \
	((struct utmp * (*)(struct Library * __asm("a6"))) \
  (((char *) USERGROUP_BASE_NAME) - 234))((struct Library *) USERGROUP_BASE_NAME)

#define endutent() \
	((void (*)(struct Library * __asm("a6"))) \
  (((char *) USERGROUP_BASE_NAME) - 240))((struct Library *) USERGROUP_BASE_NAME)

#define getlastlog(uid) \
	((struct lastlog * (*)(uid_t __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) USERGROUP_BASE_NAME) - 246))(uid, (struct Library *) USERGROUP_BASE_NAME)

#define setlastlog(uid, name, host) \
	((int (*)(uid_t __asm("d0"), char * __asm("a0"), char * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) USERGROUP_BASE_NAME) - 252))(uid, name, host, (struct Library *) USERGROUP_BASE_NAME)

#define getcredentials(task) \
	((struct UserGroupCredentials * (*)(struct Task * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) USERGROUP_BASE_NAME) - 258))(task, (struct Library *) USERGROUP_BASE_NAME)

#endif /*  _INLINE_USERGROUP_H  */
