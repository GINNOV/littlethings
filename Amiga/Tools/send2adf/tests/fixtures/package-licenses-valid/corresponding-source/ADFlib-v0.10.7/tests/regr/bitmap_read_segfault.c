/*
 * test for segfault on reading allocation bitmap
 * when bitmap pages table on the filesystem is not correct
 * ie. non-zero records beyond expected (fixed) size
 *
 * more details:
 * https://github.com/adflib/ADFlib/issues/63
 */


#include <stdio.h>
#include <stdlib.h>

#include "adflib.h"
#include "log.h"

#define TEST_VERBOSITY 0


int main( const int          argc,
          const char * const argv[] )
{
    log_init( stderr, TEST_VERBOSITY );

    if ( argc < 2 )
        return 1;

    adfLibInit();

//	adfEnvSetFct(0,0,MyVer,0);
    bool error_status = false;
    struct AdfDevice * const dev = adfDevOpen( argv[1], ADF_ACCESS_MODE_READONLY );
    if ( ! dev ) {
        log_error( "Cannot open file/device '%s' - aborting...\n", argv[1] );
        adfLibCleanUp();
        exit(1);
    }
    ADF_RETCODE rc = adfDevMount( dev );
    if ( rc != ADF_RC_OK ) {
        log_error( "can't mount device %s\n", argv[1] );
        error_status = true;
        goto close_dev;
    }

    /*** crash happens here, on mounting the volume, in adfReadBitmap() ***/
    struct AdfVolume * const vol = adfVolMount( dev, 0, ADF_ACCESS_MODE_READONLY );
    if ( vol == NULL ) {
        log_error( "can't mount volume %d\n", 0 );
        error_status = true;
        goto umount_dev;
    }

    //showVolInfo( vol );
    //putchar('\n');

    adfVolUnMount( vol );

umount_dev:
    adfDevUnMount( dev );

close_dev:
    adfDevClose( dev );

//clean_up:
    adfLibCleanUp();

    return error_status;
}
