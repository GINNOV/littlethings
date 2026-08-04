/*
 * del_test.c
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include"adflib.h"
#include "adf_dir.h"
#include "common.h"
#include "log.h"

#define TEST_VERBOSITY 1


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

    if ( argc < 2 ) {
        log_error( "missing required parameter (image/device) - aborting...\n" );
        return 1;
    }

    struct AdfVolume *vol;
 
    adfLibInit();

    /* open and mount existing device */
    struct AdfDevice * hd = adfDevOpen ( argv[1], ADF_ACCESS_MODE_READWRITE );
    if ( ! hd ) {
        log_error( "Cannot open file/device '%s' - aborting...\n", argv[1] );
        adfLibCleanUp();
        exit(1);
    }

    ADF_RETCODE rc = adfDevMount ( hd );
    if ( rc != ADF_RC_OK ) {
        log_error( "can't mount device\n" );
        adfDevClose ( hd );
        adfLibCleanUp(); exit(1);
    }

    vol = adfVolMount ( hd, 0, ADF_ACCESS_MODE_READWRITE );
    if (!vol) {
        log_error( "can't mount volume\n" );
        adfDevUnMount ( hd );
        adfDevClose ( hd );
        adfLibCleanUp(); exit(1);
    }

    showVolInfo( vol );
    showDirEntries( vol, vol->curDirPtr );
    putchar('\n');

    /* cd dir_2 */
    //ADF_SECTNUM nSect =
    adfChangeDir(vol, "same_hash");
    showDirEntries( vol, vol->curDirPtr );
    putchar('\n');

    /* not empty */
    adfRemoveEntry(vol, vol->curDirPtr, "dir_2");

    /* first in same hash linked list */
    adfRemoveEntry(vol, vol->curDirPtr, "file_3a");
    /* second */
    adfRemoveEntry(vol, vol->curDirPtr, "dir_3");
    /* last */
    adfRemoveEntry(vol, vol->curDirPtr, "dir_1a");

    showDirEntries( vol, vol->curDirPtr );
    putchar('\n');

    adfParentDir(vol);
    adfRemoveEntry(vol, vol->curDirPtr, "mod.And.DistantCall");
    showDirEntries( vol, vol->curDirPtr );
    putchar('\n');

    showVolInfo( vol );

    adfVolUnMount(vol);
    adfDevUnMount ( hd );
    adfDevClose ( hd );

    adfLibCleanUp();

    return 0;
}
