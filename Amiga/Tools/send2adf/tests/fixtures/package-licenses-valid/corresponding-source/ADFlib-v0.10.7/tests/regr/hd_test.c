/*
 * hd_test.c
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
    if ( argc < 2 ) {
        fprintf ( stderr,
                  "required parameter (image/device) absent - aborting...\n");
        return 1;
    }

    struct AdfVolume *vol, *vol2;

    /* initialisation */
    adfLibInit();

    /*** a real harddisk ***/
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
        fprintf(stderr, "can't mount volume 0\n");
        adfLibCleanUp(); exit(1);
    }
    showVolInfo( vol );

    vol2 = adfVolMount ( hd, 1, ADF_ACCESS_MODE_READWRITE );
    if (!vol2) {
        adfDevUnMount ( hd );
        adfDevClose ( hd );
        fprintf(stderr, "can't mount volume 1\n");
        adfLibCleanUp(); exit(1);
    }
    showVolInfo( vol2 );

    /* unmounts */
    adfVolUnMount(vol);
    adfVolUnMount(vol2);
    adfDevUnMount ( hd );
    adfDevClose ( hd );

    /*** a dump of a zip disk ***/
    hd = adfDevOpen ( argv[2], ADF_ACCESS_MODE_READWRITE );
    if ( ! hd ) {
        fprintf ( stderr, "Cannot open file/device '%s' - aborting...\n",
                  argv[2] );
        adfLibCleanUp();
        exit(1);
    }

    rc = adfDevMount ( hd );
    if ( rc != ADF_RC_OK ) {
        fprintf(stderr, "can't mount device\n");
        adfDevClose ( hd );
        adfLibCleanUp(); exit(1);
    }

    showDevInfo( hd );

    vol = adfVolMount ( hd, 0, ADF_ACCESS_MODE_READWRITE );
    if (!vol) {
        adfDevUnMount ( hd );
        adfDevClose ( hd );
        fprintf(stderr, "can't mount volume\n");
        adfLibCleanUp(); exit(1);
    }
    showVolInfo( vol );

    adfVolUnMount(vol);
    adfDevUnMount ( hd );
    adfDevClose ( hd );

    /* clean up */
    adfLibCleanUp();

    return 0;
}
