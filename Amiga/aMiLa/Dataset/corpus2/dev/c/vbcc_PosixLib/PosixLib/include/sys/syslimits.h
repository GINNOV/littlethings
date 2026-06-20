/*
 * POSIX Compatibility Library for AmigaOS
 *
 * Written by Frank Wille <frank@phoenix.owl.de> in 2003
 *
 * $Id: syslimits.h,v 1.3 2021/07/28 14:40:31 phx Exp $
 */

#ifndef _SYS_SYSLIMITS_H_
#define _SYS_SYSLIMITS_H_

#define GID_MAX            2147483647U  /* max value for a gid_t (2^31-2) */
#define MAX_INPUT                 511   /* max bytes in terminal input */
#define NAME_MAX                   30   /* max bytes in a file name */
#define UID_MAX            2147483647U  /* max value for a uid_t (2^31-2) */
#define LOGIN_NAME_MAX            256   /* max length of a login name */
#define OPEN_MAX                   64   /* max open files per process */
#define PATH_MAX                 1024   /* max bytes in pathname */
#define SYMLINK_MAX              1024   /* max bytes in symlink */

#endif  /* _SYS_SYSLIMITS_H_ */
