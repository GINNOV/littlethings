
/*
 *  SYS/STAT.H
 */

#ifndef SYS_STAT_H
#define SYS_STAT_H

#ifndef LIBRARIES_DOS_H
#include <libraries/dos.h>
#endif

#define S_IFMT	    0xF0000
#define S_IFREG     0x10000
#define S_IFDIR     0x20000
#define S_IFLNK     0x30000
#define S_IFCHR     0x40000
#define S_IFBLK     0x50000

#define S_ISUID     0x08000
#define S_ISGID     0x04000
#define S_ISVTX     0x02000

#define S_IREAD     000400
#define S_IWRITE    000200
#define S_IEXEC     000100


typedef long dev_t;
typedef long ino_t;

struct stat {
    long    st_mode;
    long    st_size;
    long    st_blksize;     /*	not used, compat    */
    long    st_blocks;
    long    st_ctime;
    long    st_mtime;
    long    st_atime;	    /*	not used, compat    */
    long    st_dev;
    short   st_rdev;	    /*	not used, compat    */
    long    st_ino;
    short   st_uid;	    /*	not used, compat    */
    short   st_gid;	    /*	not used, compat    */
    short   st_nlink;	    /*	not used, compat    */
};

extern int stat(const char *, struct stat *);
extern int fstat(int, struct stat *);

/*
 *  dummy unix compat
 */

#define makedev(maj,min)    (((maj) << 8) | (min))
#define major(rdev)     (unsigned char)((rdev) >> 8)
#define minor(rdev)     (unsigned char)(rdev)

#endif

