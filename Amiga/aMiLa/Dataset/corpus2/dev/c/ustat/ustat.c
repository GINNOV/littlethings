/* ustat - get file system statictics (DICE)
 *
 * Copyright (C) 1995 by Ingo Wilken (Ingo.Wilken@informatik.uni-oldenburg.de)
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose and without fee is hereby granted, provided
 * that the above copyright notice appear in all copies and that both that
 * copyright notice and this permission notice appear in supporting
 * documentation.  This software is provided "as is" without express or
 * implied warranty.
 *
 *  $VER: ustat.c 1.0 (5.5.95)
 */
#include <exec/types.h>
#include <exec/ports.h>
#include <dos/dos.h>
#include <dos/dosextens.h>

#include <errno.h>
#include <string.h>
#include <ustat.h>


extern LONG SendPacket(struct MsgPort *handler, LONG action, LONG *arglist, LONG nargs);


int
ustat(dev, ub)
    long dev;
    struct ustat *ub;
{
    if( dev ) {
        __aligned struct InfoData info;
        BPTR ifp = MKBADDR(&info);

        if( SendPacket((struct MsgPort *)dev, ACTION_DISK_INFO, (LONG *)&ifp, 1) != DOSFALSE ) {
            struct DeviceList *dlist;
            LONG nblocks;

            nblocks = info.id_NumBlocks - info.id_NumBlocksUsed;
            ub->f_tinode = nblocks;
            ub->f_tfree  = nblocks * info.id_BytesPerBlock / 1024;
            ub->f_fname[0] = '\0';
            ub->f_fpack[0] = '\0';

            if( dlist = BADDR(info.id_VolumeNode) ) {
                UBYTE *name;
                int len;

                /* BCPL string -> C string */
                if( name = BADDR(dlist->dl_Name) ) {
                    len  = *name++;
                    strncpy(ub->f_fname, (char *)name, len);
                    ub->f_fname[len] = '\0';
                }
            }
            return 0;
        }
        errno = ENXIO;
    }
    else
        errno = EINVAL;
    return -1;
}


#ifdef TEST
#include <sys/stat.h>
#include <stdio.h>
#include <fcntl.h>

main(argc, argv)
    int argc;
    char *argv[];
{
    struct stat stat_buf;
    struct ustat ustat_buf;

    if( argc != 2 )
        return 1;

    if( stat(argv[1], &stat_buf) == 0 ) {
        printf("stat st_dev = %08x\n", stat_buf.st_dev);
        if( ustat(stat_buf.st_dev, &ustat_buf) == 0 )
            printf("File/directory %s is on volume %s with %ld KB free\n",
                    argv[1], ustat_buf.f_fname, ustat_buf.f_tfree);
        else
            printf("Can\'t ustat device at %08x\n", stat_buf.st_dev);
    }
    else
        printf("Can\'t stat %s\n", argv[1]);

    return 0;
}
#endif

