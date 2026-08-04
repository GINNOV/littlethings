/*
 * hd_test.c
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

    if ( argc < 2 ) {
        log_error( "Usage: hd_test2 ZipDiskFileName\n" );
        return 1;
    }

    int status = 0;

    adfLibInit();

    const char * const tmpDevName = argv[ 1 ];

    /* a zip disk */
    struct AdfDevice * hd = adfDevCreate( "dump", tmpDevName, 2891, 1, 68 );
    if ( ! hd ) {
        log_error( "can't create a zip disk device, name %s\n", tmpDevName );
        status = 1;
        goto cleanup_lib;
    }

    showDevInfo( hd );

    const struct AdfPartition ** const partList =
        (const struct AdfPartition **) malloc( sizeof(struct AdfPartition *) );
    if ( partList == NULL ) {
        status = 1;
        goto cleanup_dev;
    }
    const struct AdfPartition part1 = {
        .startCyl = 2,
        .lenCyl   = 2889,
        .volName  = strdup("zip"),
        .volType  = ADF_DOSFS_FFS |
                    ADF_DOSFS_DIRCACHE
    };

    partList[0] = &part1;
    ADF_RETCODE rc = adfCreateHd( hd, 1, (const struct AdfPartition * const * const) partList );
    free( partList );
    free( part1.volName );
    if ( rc != ADF_RC_OK ) {
        log_error( "adfCreateHd returned error %d\n", rc );
        status = 1;
        goto cleanup_dev;
    }

    struct AdfVolume * vol = adfVolMount( hd, 0, ADF_ACCESS_MODE_READWRITE );
    if ( ! vol ) {
        log_error( "can't mount volume\n" );
        status = 1;
        goto cleanup_dev;
    }

    showVolInfo( vol );
    adfVolUnMount( vol );
    adfDevUnMount( hd );
    adfDevClose( hd );

    /* mount the created device */
    hd = adfDevOpen( tmpDevName, ADF_ACCESS_MODE_READWRITE );
    if ( ! hd ) {
        log_error( "Cannot open file/device '%s' - aborting...\n",
                 tmpDevName );
        status = 1;
        goto cleanup_lib;
    }

    rc = adfDevMount( hd );
    if ( rc != ADF_RC_OK ) {
        log_error( "can't mount device\n" );
        status = 1;
        goto cleanup_dev;
    }

    showDevInfo( hd );

    vol = adfVolMount( hd, 0, ADF_ACCESS_MODE_READWRITE );
    if ( ! vol ) {
        log_error( "can't mount volume\n" );
        status = 1;
        goto cleanup_dev;
    }

    showVolInfo( vol );

    adfVolUnMount(vol);

cleanup_dev:
    adfDevUnMount( hd );
    adfDevClose( hd );

cleanup_lib:
    adfLibCleanUp();

    return status;
}
