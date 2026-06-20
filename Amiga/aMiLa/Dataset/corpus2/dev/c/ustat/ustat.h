#ifndef IUW_USTAT_H
#define IUW_USTAT_H

struct ustat {
    long    f_tfree;        /* Total free blocks (Kbytes) */
    long    f_tinode;       /* Unix: Number of free inodes, Amiga: number of free (physical) blocks */
    char    f_fname[256];   /* Unix: Filsys name, Amiga: volume name */
    char    f_fpack[6];     /* unused */
};


extern int ustat(long, struct ustat *);

#endif /* IUW_USTAT_H */

