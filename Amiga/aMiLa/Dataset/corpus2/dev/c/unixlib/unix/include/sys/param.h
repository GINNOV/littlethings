#ifndef _PARAM_H
#define _PARAM_H

/*
 * Let's assume we are BSD compatible
 */
#define BSD	199402	/* Feb, 1994 system version (year & month) */

#undef  FILENAME_MAX
#define MAXPATHLEN 254
#define FILENAME_MAX MAXPATHLEN /* Should be in stdio.h */
#ifndef DEV_BSIZE
#define DEV_BSIZE 1024
#endif
#define NOFILE 20 /* maximum number of open files (from stdio.h) */

#ifndef NULL
#define NULL (0)
#endif

#endif
