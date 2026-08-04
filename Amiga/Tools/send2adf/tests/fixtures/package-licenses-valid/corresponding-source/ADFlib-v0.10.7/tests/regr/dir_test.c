/*
 * dir_test.c
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include"adflib.h"
#include "adf_dir.h"
#include "common.h"
#include "log.h"

#define TEST_VERBOSITY 3

int test_chdir_hlink( struct AdfVolume *  vol,
                      char *              hlink,
                      int                 num_entries );

int test_softlink_realname( struct AdfVolume *  vol,
                            char *              slink,
                            char *              expected_dest_name );


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
        log_error( "missing required parameter (image/device) - aborting...\n");
        return 1;
    }
 
    adfLibInit();

//	adfEnvSetFct(0,0,MyVer,0);

    /* open and mount existing device */
/* testffs.adf */
    struct AdfDevice * const hd = adfDevOpen( argv[1], ADF_ACCESS_MODE_READWRITE );
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
    putchar('\n');

    /* cd dir_2 */
    //ADF_SECTNUM nSect = adfChangeDir(vol, "dir_2");
    adfChangeDir(vol, "dir_2");
    showDirEntries( vol, vol->curDirPtr );
    putchar('\n');

    /* cd .. */
    adfParentDir(vol);
    showDirEntries( vol, vol->curDirPtr );

    /* cd hlink_dir1 (hardlink to dir_1) */
    status += test_chdir_hlink( vol, "hlink_dir1", 1 );

    /* cd hlink_dir2 (hardlink to dir_2) */
    status += test_chdir_hlink( vol, "hlink_dir2", 2 );

    /* test getting real name from a softlink */
    status += test_softlink_realname( vol, "slink_dir1", "dir_1" );

    adfVolUnMount(vol);

cleanup_dev:
    adfDevUnMount( hd );
    adfDevClose( hd );

cleanup_env:
    adfLibCleanUp();

    return status;
}


int test_chdir_hlink( struct AdfVolume *  vol,
                      char *              hlink,
                      int                 num_entries )
{
    int status = 0;

    adfToRootDir( vol );

    log_info("*** Test entering hard link %s\n", hlink );
    ADF_RETCODE rc = adfChangeDir( vol, hlink );
    if ( rc != ADF_RC_OK ) {
        log_error( "adfChangeDir error entering hard link %s.\n", hlink );
        status++;
    }

    struct AdfList * list, * cell;
    list = cell = adfGetDirEnt( vol, vol->curDirPtr );
    int count = 0;
    while ( cell ) {
        //adfEntryPrint ( list->content );
        cell = cell->next;
        count++;
    }
    adfFreeDirList( list );

    if ( count != num_entries ) {
        log_error( "Incorrect number of entries (%d) after chdir to hard link %s.\n",
                   count, hlink );
        status++;
    }

    adfToRootDir( vol );

    return status;
}


int test_softlink_realname( struct AdfVolume *  vol,
                            char *              slink,
                            char *              expected_dest_name )
{
    adfToRootDir( vol );

    log_info("*** Test getting destination name for soft link %s\n", slink );

    struct AdfLinkBlock entry;
    ADF_SECTNUM sectNum = adfGetEntryBlock( vol, vol->curDirPtr, slink,
                                            (struct AdfEntryBlock *) &entry );
    if ( sectNum == -1 ) {
        return 1;
    }

    if ( entry.secType != ADF_ST_LSOFT ) {
        return 1;
    }

    if ( strncmp( expected_dest_name, entry.realName, 6 ) != 0 ) {
        log_error( "Name of the softlink %s incorrect: read '%s' != expected '%s'\n",
                   slink, entry.realName, expected_dest_name );
        return 1;
    }
    log_info(" -> OK!\n");
    return 0;
}
