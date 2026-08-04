/*
 * readonly.c
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
    log_init( stderr, TEST_VERBOSITY );

    int status = 0;

    if ( argc < 2 ) {
        log_error( "missing parameter (image/device) - aborting...\n");
        return 1;
    }
 
    adfLibInit();

    /* open and mount existing device */
    struct AdfDevice * hd = adfDevOpen( argv[1], ADF_ACCESS_MODE_READWRITE );
    if ( ! hd ) {
        log_error( "Cannot open file/device '%s' - aborting...\n", argv[1] );
        status = 1;
        goto cleanup_env;
    }

    ADF_RETCODE rc = adfDevMount( hd );
    if ( rc != ADF_RC_OK ) {
        log_error( "can't mount device\n" );
        status = 1;
        goto cleanup_dev;
    }

    struct AdfVolume * const vol = adfVolMount( hd, 0, ADF_ACCESS_MODE_READWRITE );
    if ( ! vol ) {
        log_error( "can't mount volume\n" );
        status = 1;
        goto cleanup_dev;
    }

    showVolInfo( vol );
    showDirEntries( vol, vol->curDirPtr );
    log_info("\n");

    adfCreateDir( vol, vol->curDirPtr, "newdir" );

    /* cd dir_2 */
    //ADF_SECTNUM nSect = adfChangeDir(vol, "same_hash");
    adfChangeDir( vol, "same_hash" );
    showDirEntries( vol, vol->curDirPtr );
    log_info("\n");

    /* not empty */
    adfRemoveEntry( vol, vol->curDirPtr, "mon.paradox" );

    /* first in same hash linked list */
    adfRemoveEntry( vol, vol->curDirPtr, "file_3a" );
    /* second */
    adfRemoveEntry( vol, vol->curDirPtr, "dir_3" );
    /* last */
    adfRemoveEntry( vol, vol->curDirPtr, "dir_1a" );

    showDirEntries( vol, vol->curDirPtr );
    log_info("\n");

    adfParentDir( vol );
    adfRemoveEntry( vol, vol->curDirPtr, "mod.And.DistantCall" );
    showDirEntries( vol, vol->curDirPtr );
    log_info("\n");

    showVolInfo( vol );

    adfVolUnMount( vol );

cleanup_dev:
    adfDevUnMount( hd );
    adfDevClose( hd );

cleanup_env:
    adfLibCleanUp();

    return status;
}
