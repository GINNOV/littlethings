/*
 * hd_test_a590.c
 *
 * test opening and mounting a disk image with geometry of a A590 (WD93028)
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "adflib.h"
#include "common.h"
#include "log.h"

#define TEST_VERBOSITY 3


int main(int argc, char *argv[])
{
    log_init( stderr, TEST_VERBOSITY );

    if ( argc < 2 ) {
        log_error( "required parameter (image/device) absent - aborting...\n" );
        return 1;
    }

    int status = 0;

    adfLibInit();

    // open device
    const char * const devName = argv[ 1 ];
    struct AdfDevice * const hd = adfDevOpen( devName, ADF_ACCESS_MODE_READWRITE );
    if ( hd == NULL ) {
        log_error( "Cannot open file/device '%s' - aborting...\n", devName );
        status = 1;
        goto cleanup_lib;
    }

    // mount device
    if ( adfDevMount( hd ) != ADF_RC_OK ) {
        log_error( "can't mount device\n" );
        status = 1;
        goto cleanup_dev;
    }
    showDevInfo( hd );

    // mount volumes (6 partitions)
    struct AdfVolume * vol[ 6 ];
    for ( int i = 0 ; i < 6 ; i++ ) {
        vol[ i ] = adfVolMount( hd, i, ADF_ACCESS_MODE_READWRITE );
        if ( vol[ i ] == NULL ) {
            log_error( "can't mount volume %u\n", i );
            status = 1;
            continue; //goto cleanup_dev;
        }
        showVolInfo( vol[ i ] );
    }

    // cleanup

    for ( unsigned i = 0 ; i < 6 ; i++ )
        adfVolUnMount( vol[ i ] );

cleanup_dev:
    adfDevUnMount( hd );
    adfDevClose( hd );

cleanup_lib:
    adfLibCleanUp();

    return status;
}
