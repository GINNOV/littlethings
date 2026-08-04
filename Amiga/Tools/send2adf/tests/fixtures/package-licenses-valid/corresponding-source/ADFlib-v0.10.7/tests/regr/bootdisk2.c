/*
 * bootdisk.c
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include"adflib.h"
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
    if ( argc < 2 )
        return 1;

    log_init( stderr, TEST_VERBOSITY );

    struct AdfVolume *vol;
    FILE* boot;
    unsigned char bootcode[1024];
 
    boot=fopen(argv[1],"rb");
    if (!boot) {
        log_error( "can't open bootcode file\n");
        exit(1);
    }
    fread(bootcode, sizeof(unsigned char), 1024, boot);
    fclose(boot);

    adfLibInit();

    struct AdfDevice * const hd = adfDevOpen( argv[2], ADF_ACCESS_MODE_READWRITE );
    if ( ! hd ) {
        log_error( "Cannot open file/device '%s' - aborting...\n", argv[2] );
        adfLibCleanUp();
        exit(1);
    }

    ADF_RETCODE rc = adfDevMount ( hd );
    if ( rc != ADF_RC_OK ) {
        log_error( "can't mount device\n" );
        adfDevClose( hd );
        adfLibCleanUp(); exit(1);
    }
	
    vol = adfVolMount ( hd, 0, ADF_ACCESS_MODE_READWRITE );
    if (!vol) {
        log_error( "can't mount volume\n" );
        adfDevUnMount( hd );
        adfDevClose( hd );
        adfLibCleanUp(); exit(1);
    }

    adfVolInstallBootBlock ( vol, bootcode );

    showVolInfo( vol );

    adfVolUnMount ( vol );

    adfDevUnMount ( hd );
    adfDevClose ( hd );

    adfLibCleanUp();

    return 0;
}
