/*
 * rename.c
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "adflib.h"
#include "common.h"
#include "log.h"

#define TEST_VERBOSITY 3


void MyVer(char *msg)
{
    fprintf(stderr,"Verbose [%s]\n",msg);
}


/*
 *
 *
 */
int main(int argc, char *argv[])
{
    (void) argc, (void) argv;

    log_init( stderr, TEST_VERBOSITY );

    int status = 0;
 
    adfLibInit();

    /* create and mount one device */
    struct AdfDevice * const hd = adfDevCreate( "dump", "rename2-newdev", 80, 2, 11 );
    if ( ! hd ) {
        log_error( "can't create device\n" );
        status = 1;
        goto cleanup_env;
    }

    if ( adfCreateFlop( hd, "empty", ADF_DOSFS_FFS |
                                     ADF_DOSFS_DIRCACHE ) != ADF_RC_OK )
    {
        log_error( "can't create floppy\n" );
        status = 1;
        goto cleanup_dev;
    }

    struct AdfVolume * const vol = adfVolMount( hd, 0, ADF_ACCESS_MODE_READWRITE );
    if ( ! vol ) {
        log_error( "can't mount volume\n" );
        status = 1;
        goto cleanup_dev;
    }

    showDevInfo( hd );

    showVolInfo( vol );
    showDirEntries( vol, vol->curDirPtr );
    log_info("\n");

    adfCreateDir( vol, vol->curDirPtr, "dir_5u" );

    adfCreateDir( vol, 883, "dir_51");

    adfCreateDir( vol, vol->curDirPtr, "toto" );
    log_info( "[dir = %d]\n", vol->curDirPtr );
    showDirEntries( vol, vol->curDirPtr );

    log_info( "[dir = %ld]\n", 883L );
    showDirEntries( vol, 883 );

    adfRenameEntry( vol, 883,            "dir_51",
                         vol->curDirPtr, "dir_55" );
    log_info("\n");

    log_info( "[dir = %d]\n", vol->curDirPtr );
    showDirEntries( vol, vol->curDirPtr );

    log_info( "[dir = %ld]\n", 883L );
    showDirEntries( vol, 883 );

    adfRenameEntry( vol, vol->curDirPtr, "toto",
                         883,            "moved_dir" );

    log_info("\n");

    log_info( "[dir = %d]\n", vol->curDirPtr );
    showDirEntries( vol, vol->curDirPtr );

    log_info( "[dir = %ld]\n", 883L );
    showDirEntries( vol, 883 );

    adfVolUnMount( vol );

cleanup_dev:
    adfDevUnMount( hd );
    adfDevClose( hd );

cleanup_env:
    adfLibCleanUp();

    return status;
}
