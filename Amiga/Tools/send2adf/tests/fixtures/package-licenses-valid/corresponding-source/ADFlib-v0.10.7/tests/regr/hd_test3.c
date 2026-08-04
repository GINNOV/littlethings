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
        log_error( "Usage: hd_test3 diskDumpFileName\n" );
        return 1;
    }

    int status = 0;

    adfLibInit();

    const char * const tmpDevName = argv[ 1 ];

    /* an harddisk, "b"=7.5Mb, "h"=74.5mb */

    struct AdfDevice * hd = adfDevCreate( "dump", tmpDevName, 980, 10, 17 );
    if ( ! hd ) {
        log_error( "can't create device %s\n", tmpDevName );
        status = 1;
        goto cleanup_lib;
    }

    showDevInfo( hd );

    const struct AdfPartition ** const partList =
        (const struct AdfPartition ** const) malloc( sizeof(struct AdfPartition *) * 2 );
    if ( partList == NULL ) {
        log_error( "malloc error\n" );
        status = 1;
        goto cleanup_lib;
    }

    const struct AdfPartition part1 = {
        .startCyl = 2,
	.lenCyl   = 100,
	.volName  = strdup("b"),
        .volType  = ADF_DOSFS_FFS | ADF_DOSFS_DIRCACHE
    };
	
    const struct AdfPartition part2 = {
        .startCyl = 101,
	.lenCyl   = 878,
	.volName  = strdup("h"),
        .volType  = ADF_DOSFS_FFS
    };

    partList[0] = &part1;
    partList[1] = &part2;

    ADF_RETCODE rc = adfCreateHd( hd, 2, (const struct AdfPartition * const * const) partList );
    free( partList );
    free( part1.volName );
    free( part2.volName );
    if ( rc != ADF_RC_OK ) {
        log_error( "adfCreateHd returned error %d\n", rc );
        status = 1;
        goto cleanup_dev;
    }

    struct AdfVolume * const vol = adfVolMount( hd, 0, ADF_ACCESS_MODE_READWRITE );
    if ( ! vol ) {
        log_error( "can't mount volume 0\n" );
        status = 1;
        goto cleanup_dev;
    }
    struct AdfVolume * const vol2 = adfVolMount( hd, 1, ADF_ACCESS_MODE_READWRITE );
    if ( ! vol2 ) {
        log_error( "can't mount volume 1\n" );
        adfVolUnMount( vol );
        status = 1;
        goto cleanup_dev;
    }

    showVolInfo( vol );
    showVolInfo( vol2 );

    adfVolUnMount( vol );
    adfVolUnMount( vol2 );
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

cleanup_dev:
    adfDevUnMount( hd );
    adfDevClose( hd );

cleanup_lib:
    adfLibCleanUp();

    return status;
}
