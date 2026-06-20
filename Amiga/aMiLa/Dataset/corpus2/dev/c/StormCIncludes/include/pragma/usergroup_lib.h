#ifndef _INCLUDE_PRAGMA_USERGROUP_LIB_H
#define _INCLUDE_PRAGMA_USERGROUP_LIB_H

#ifndef CLIB_USERGROUP_PROTOS_H
#include <clib/usergroup_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/usergroup.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(UserGroupBase,0x01E,ug_SetupContextTagList(a0,a1))
#pragma amicall(UserGroupBase,0x024,ug_GetErr())
#pragma amicall(UserGroupBase,0x02A,ug_StrError(d1))
#pragma amicall(UserGroupBase,0x030,getuid())
#pragma amicall(UserGroupBase,0x036,geteuid())
#pragma amicall(UserGroupBase,0x03C,setreuid(d0,d1))
#pragma amicall(UserGroupBase,0x042,setuid(d0))
#pragma amicall(UserGroupBase,0x048,getgid())
#pragma amicall(UserGroupBase,0x04E,getegid())
#pragma amicall(UserGroupBase,0x054,setregid(d0,d1))
#pragma amicall(UserGroupBase,0x05A,setgid(d0))
#pragma amicall(UserGroupBase,0x060,getgroups(d0,a1))
#pragma amicall(UserGroupBase,0x066,setgroups(d0,a1))
#pragma amicall(UserGroupBase,0x06C,initgroups(a1,d0))
#pragma amicall(UserGroupBase,0x072,getpwnam(a1))
#pragma amicall(UserGroupBase,0x078,getpwuid(d0))
#pragma amicall(UserGroupBase,0x07E,setpwent())
#pragma amicall(UserGroupBase,0x084,getpwent())
#pragma amicall(UserGroupBase,0x08A,endpwent())
#pragma amicall(UserGroupBase,0x090,getgrnam(a1))
#pragma amicall(UserGroupBase,0x096,getgrgid(d0))
#pragma amicall(UserGroupBase,0x09C,setgrent())
#pragma amicall(UserGroupBase,0x0A2,getgrent())
#pragma amicall(UserGroupBase,0x0A8,endgrent())
#pragma amicall(UserGroupBase,0x0AE,crypt(a0,a1))
#pragma amicall(UserGroupBase,0x0B4,ug_GetSalt(a0,a1,d0))
#pragma amicall(UserGroupBase,0x0BA,getpass(a1))
#pragma amicall(UserGroupBase,0x0C0,umask(d0))
#pragma amicall(UserGroupBase,0x0C6,getumask())
#pragma amicall(UserGroupBase,0x0CC,setsid())
#pragma amicall(UserGroupBase,0x0D2,getpgrp())
#pragma amicall(UserGroupBase,0x0D8,getlogin())
#pragma amicall(UserGroupBase,0x0DE,setlogin(a1))
#pragma amicall(UserGroupBase,0x0E4,setutent())
#pragma amicall(UserGroupBase,0x0EA,getutent())
#pragma amicall(UserGroupBase,0x0F0,endutent())
#pragma amicall(UserGroupBase,0x0F6,getlastlog(d0))
#pragma amicall(UserGroupBase,0x0FC,setlastlog(d0,a0,a1))
#pragma amicall(UserGroupBase,0x102,getcredentials(a0))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall UserGroupBase ug_SetupContextTagList 01E 9802
#pragma  libcall UserGroupBase ug_GetErr            024 00
#pragma  libcall UserGroupBase ug_StrError          02A 101
#pragma  libcall UserGroupBase getuid               030 00
#pragma  libcall UserGroupBase geteuid              036 00
#pragma  libcall UserGroupBase setreuid             03C 1002
#pragma  libcall UserGroupBase setuid               042 001
#pragma  libcall UserGroupBase getgid               048 00
#pragma  libcall UserGroupBase getegid              04E 00
#pragma  libcall UserGroupBase setregid             054 1002
#pragma  libcall UserGroupBase setgid               05A 001
#pragma  libcall UserGroupBase getgroups            060 9002
#pragma  libcall UserGroupBase setgroups            066 9002
#pragma  libcall UserGroupBase initgroups           06C 0902
#pragma  libcall UserGroupBase getpwnam             072 901
#pragma  libcall UserGroupBase getpwuid             078 001
#pragma  libcall UserGroupBase setpwent             07E 00
#pragma  libcall UserGroupBase getpwent             084 00
#pragma  libcall UserGroupBase endpwent             08A 00
#pragma  libcall UserGroupBase getgrnam             090 901
#pragma  libcall UserGroupBase getgrgid             096 001
#pragma  libcall UserGroupBase setgrent             09C 00
#pragma  libcall UserGroupBase getgrent             0A2 00
#pragma  libcall UserGroupBase endgrent             0A8 00
#pragma  libcall UserGroupBase crypt                0AE 9802
#pragma  libcall UserGroupBase ug_GetSalt           0B4 09803
#pragma  libcall UserGroupBase getpass              0BA 901
#pragma  libcall UserGroupBase umask                0C0 001
#pragma  libcall UserGroupBase getumask             0C6 00
#pragma  libcall UserGroupBase setsid               0CC 00
#pragma  libcall UserGroupBase getpgrp              0D2 00
#pragma  libcall UserGroupBase getlogin             0D8 00
#pragma  libcall UserGroupBase setlogin             0DE 901
#pragma  libcall UserGroupBase setutent             0E4 00
#pragma  libcall UserGroupBase getutent             0EA 00
#pragma  libcall UserGroupBase endutent             0F0 00
#pragma  libcall UserGroupBase getlastlog           0F6 001
#pragma  libcall UserGroupBase setlastlog           0FC 98003
#pragma  libcall UserGroupBase getcredentials       102 801
#endif
#ifdef __STORM__
#pragma tagcall(UserGroupBase,0x01E,ug_SetupContextTags(a0,a1))
#endif
#ifdef __SASC_60
#pragma  tagcall UserGroupBase ug_SetupContextTags  01E 9802
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_USERGROUP_LIB_H  */
