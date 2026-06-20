#ifndef _STAT_H
#define _STAT_H

#if defined __LP64__
#define _STAT_STRUCT_SIZE 144	/* in 64-bit glibc */
#else
#define _STAT_STRUCT_SIZE 88 	/* in 32-bit glibc */
#endif

struct stat {
    char a[_STAT_STRUCT_SIZE];
};

int stat(const char *path, struct stat *buf);

#endif
