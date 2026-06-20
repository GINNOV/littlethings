
/*
 *  SYS/DIR.H
 *
 */

#ifndef SYS_DIR_H
#define SYS_DIR_H

#define MAXPATHLEN  1024
#define MAXNAMLEN   256

typedef struct {
    long    am_Private;
} DIR;

struct direct {
    char    *d_name;
    short   d_namlen;
};

DIR *opendir(const char *);
struct direct *readdir(DIR *);
int rewinddir(DIR *);
int closedir(DIR *);

#endif
