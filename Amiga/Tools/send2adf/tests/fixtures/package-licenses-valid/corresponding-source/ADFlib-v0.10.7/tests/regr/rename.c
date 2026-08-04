/*
 * rename.c
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include"adflib.h"
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
    struct AdfDevice * const hd = adfDevCreate( "dump", "rename-newdev", 80, 2, 11 );
    if ( ! hd ) {
        log_error( "can't createdevice\n" );
        status = 1;
        goto cleanup_env;
    }

    showDevInfo( hd );

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

    showVolInfo( vol );

    log_info("Create file_1a, file_24, dir_1a, dir_5u (with this order)");
    const unsigned char buf[1];

    struct AdfFile * fic = adfFileOpen( vol, "file_1a", ADF_FILE_MODE_WRITE );
    if ( ! fic ) {
        log_error( "can't create file 'file_1a'\n" );
        status = 1;
        goto cleanup_vol;
    }
    adfFileWrite( fic, 1, buf );
    adfFileClose( fic );

    fic = adfFileOpen( vol, "file_24", ADF_FILE_MODE_WRITE );
    if ( ! fic ) {
        log_error( "can't create file 'file_24'\n" );
        status = 1;
        goto cleanup_vol;
    }
    adfFileWrite( fic, 1, buf );
    adfFileClose( fic );

    fic = adfFileOpen( vol, "dir_1a", ADF_FILE_MODE_WRITE );
    if ( ! fic ) {
        log_error( "can't create file 'dir_1a'\n" );
        status = 1;
        goto cleanup_vol;
    }
    adfFileWrite( fic, 1, buf );
    adfFileClose( fic );

    fic = adfFileOpen( vol, "dir_5u", ADF_FILE_MODE_WRITE );
    if ( ! fic ) {
        log_error( "can't create file 'dir_5a'\n" );
        status = 1;
        goto cleanup_vol;
    }
    adfFileWrite( fic, 1, buf );
    adfFileClose( fic );

    showDirEntries( vol, vol->curDirPtr );
    putchar('\n');

    log_info("Rename dir_5u into file_5u");
    adfRenameEntry( vol, vol->curDirPtr, "dir_5u",
                         vol->curDirPtr, "file_5u" );
    showDirEntries( vol, vol->curDirPtr );
    putchar('\n');

    log_info("Rename file_1a into dir_3");
    adfRenameEntry( vol, vol->curDirPtr, "file_1a",
                         vol->curDirPtr, "dir_3" );
    showDirEntries( vol, vol->curDirPtr );

    log_info("Create dir_5u, Rename dir_3 into longfilename");
/*
    fic = adfOpenFile ( vol, "dir_5u", ADF_FILE_MODE_WRITE );
    if (!fic) {
        adfVolUnMount(vol);
        adfUnMountDev(hd);
        adfCloseDev(hd);
        adfLibCleanUp();
        exit(1);
    }
    adfWriteFile(fic,1,buf);
    adfCloseFile(fic);
*/
    adfCreateDir( vol, vol->curDirPtr, "dir_5u" );
    showDirEntries( vol, vol->curDirPtr );
    adfRenameEntry( vol, vol->curDirPtr, "dir_1a",
                         vol->curDirPtr, "longfilename" );
    showDirEntries( vol, vol->curDirPtr );

cleanup_vol:
    adfVolUnMount( vol );

cleanup_dev:
    adfDevUnMount( hd );
    adfDevClose( hd );

cleanup_env:
    adfLibCleanUp();

    return status;
}
