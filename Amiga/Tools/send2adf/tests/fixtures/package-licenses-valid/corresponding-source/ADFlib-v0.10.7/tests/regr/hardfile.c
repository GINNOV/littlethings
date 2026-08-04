/*
 * bootdisk.c
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include"adflib.h"
#include "common.h"


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
    struct AdfVolume *vol;

    adfLibInit();

    struct AdfDevice * hd = adfDevOpen ( argv[1], ADF_ACCESS_MODE_READWRITE );
    if ( ! hd ) {
        fprintf ( stderr, "Cannot open file/device '%s' - aborting...\n",
                  argv[1] );
        adfLibCleanUp();
        exit(1);
    }

    ADF_RETCODE rc = adfDevMount ( hd );
    if ( rc != ADF_RC_OK ) {
        fprintf(stderr, "can't mount device\n");
        adfDevClose ( hd );
        adfLibCleanUp(); exit(1);
    }

    showDevInfo( hd );

    /* mount the 2 partitions */
    vol = adfVolMount ( hd, 0, ADF_ACCESS_MODE_READWRITE );
    if (!vol) {
        adfDevUnMount ( hd );
        adfDevClose ( hd );
        fprintf(stderr, "can't mount volume\n");
        adfLibCleanUp(); exit(1);
    }
    showVolInfo( vol );
    showDirEntries( vol, vol->curDirPtr );

    /* unmounts */
    adfVolUnMount(vol);
    adfDevUnMount ( hd );
    adfDevClose ( hd );

    adfLibCleanUp();

    return 0;
}
