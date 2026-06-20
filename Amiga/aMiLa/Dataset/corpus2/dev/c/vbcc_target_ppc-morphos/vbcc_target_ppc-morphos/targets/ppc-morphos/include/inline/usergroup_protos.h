#ifndef _VBCCINLINE_USERGROUP_H
#define _VBCCINLINE_USERGROUP_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

int __ug_SetupContextTagList(void *, const UBYTE* pname, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define ug_SetupContextTagList(pname, taglist) __ug_SetupContextTagList(UserGroupBase, (pname), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
int __linearvarargs __ug_SetupContextTags(void *, const UBYTE* pname, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define ug_SetupContextTags(...) __ug_SetupContextTags(UserGroupBase, __VA_ARGS__)
#endif

int __ug_GetErr(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define ug_GetErr() __ug_GetErr(UserGroupBase)

const char * __ug_StrError(void *, LONG code) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define ug_StrError(code) __ug_StrError(UserGroupBase, (code))

uid_t __getuid(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define getuid() __getuid(UserGroupBase)

uid_t __geteuid(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define geteuid() __geteuid(UserGroupBase)

int __setreuid(void *, uid_t real, uid_t eff) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define setreuid(real, eff) __setreuid(UserGroupBase, (real), (eff))

int __setuid(void *, uid_t id) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define setuid(id) __setuid(UserGroupBase, (id))

gid_t __getgid(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define getgid() __getgid(UserGroupBase)

gid_t __getegid(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define getegid() __getegid(UserGroupBase)

int __setregid(void *, gid_t real, gid_t eff) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tli\t3,-84\n"
	"\tbctrl";
#define setregid(real, eff) __setregid(UserGroupBase, (real), (eff))

int __setgid(void *, gid_t id) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-90\n"
	"\tbctrl";
#define setgid(id) __setgid(UserGroupBase, (id))

int __getgroups(void *, int ngroups, gid_t * groups) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-96\n"
	"\tbctrl";
#define getgroups(ngroups, groups) __getgroups(UserGroupBase, (ngroups), (groups))

int __setgroups(void *, int ngroups, const gid_t * groups) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-102\n"
	"\tbctrl";
#define setgroups(ngroups, groups) __setgroups(UserGroupBase, (ngroups), (groups))

int __initgroups(void *, const char * name, gid_t basegroup) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-108\n"
	"\tbctrl";
#define initgroups(name, basegroup) __initgroups(UserGroupBase, (name), (basegroup))

struct passwd * __getpwnam(void *, const char * name) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-114\n"
	"\tbctrl";
#define getpwnam(name) __getpwnam(UserGroupBase, (name))

struct passwd * __getpwuid(void *, uid_t uid) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-120\n"
	"\tbctrl";
#define getpwuid(uid) __getpwuid(UserGroupBase, (uid))

void __setpwent(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-126\n"
	"\tbctrl";
#define setpwent() __setpwent(UserGroupBase)

struct passwd * __getpwent(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-132\n"
	"\tbctrl";
#define getpwent() __getpwent(UserGroupBase)

void __endpwent(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-138\n"
	"\tbctrl";
#define endpwent() __endpwent(UserGroupBase)

struct group * __getgrnam(void *, const char * name) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-144\n"
	"\tbctrl";
#define getgrnam(name) __getgrnam(UserGroupBase, (name))

struct group * __getgrgid(void *, gid_t gid) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-150\n"
	"\tbctrl";
#define getgrgid(gid) __getgrgid(UserGroupBase, (gid))

void __setgrent(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-156\n"
	"\tbctrl";
#define setgrent() __setgrent(UserGroupBase)

struct group * __getgrent(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-162\n"
	"\tbctrl";
#define getgrent() __getgrent(UserGroupBase)

void __endgrent(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-168\n"
	"\tbctrl";
#define endgrent() __endgrent(UserGroupBase)

char * __crypt(void *, const char * key, const char * salt) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-174\n"
	"\tbctrl";
#define crypt(key, salt) __crypt(UserGroupBase, (key), (salt))

char * __ug_GetSalt(void *, const struct passwd * user, char * buffer, ULONG size) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-180\n"
	"\tbctrl";
#define ug_GetSalt(user, buffer, size) __ug_GetSalt(UserGroupBase, (user), (buffer), (size))

char * __getpass(void *, const char * prompt) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-186\n"
	"\tbctrl";
#define getpass(prompt) __getpass(UserGroupBase, (prompt))

mode_t __umask(void *, mode_t mask) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-192\n"
	"\tbctrl";
#define umask(mask) __umask(UserGroupBase, (mask))

mode_t __getumask(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-198\n"
	"\tbctrl";
#define getumask() __getumask(UserGroupBase)

pid_t __setsid(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-204\n"
	"\tbctrl";
#define setsid() __setsid(UserGroupBase)

pid_t __getpgrp(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-210\n"
	"\tbctrl";
#define getpgrp() __getpgrp(UserGroupBase)

char * __getlogin(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-216\n"
	"\tbctrl";
#define getlogin() __getlogin(UserGroupBase)

int __setlogin(void *, const char * buffer) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-222\n"
	"\tbctrl";
#define setlogin(buffer) __setlogin(UserGroupBase, (buffer))

void __setutent(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-228\n"
	"\tbctrl";
#define setutent() __setutent(UserGroupBase)

struct utmp * __getutent(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-234\n"
	"\tbctrl";
#define getutent() __getutent(UserGroupBase)

void __endutent(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-240\n"
	"\tbctrl";
#define endutent() __endutent(UserGroupBase)

struct lastlog * __getlastlog(void *, uid_t uid) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-246\n"
	"\tbctrl";
#define getlastlog(uid) __getlastlog(UserGroupBase, (uid))

int __setlastlog(void *, uid_t uid, char * name, char * host) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,36(2)\n"
	"\tli\t3,-252\n"
	"\tbctrl";
#define setlastlog(uid, name, host) __setlastlog(UserGroupBase, (uid), (name), (host))

struct UserGroupCredentials * __getcredentials(void *, struct Task * task) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-258\n"
	"\tbctrl";
#define getcredentials(task) __getcredentials(UserGroupBase, (task))

#endif /*  _VBCCINLINE_USERGROUP_H  */
