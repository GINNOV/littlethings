/*
 * file_seek_test2.c
 */

#include <stdio.h>
#include <stdlib.h>
#include "adflib.h"
#include "common.h"
#include "log.h"

#define TEST_VERBOSITY 2

#define NUM_TESTS  1000
#define MAX_ERRORS 10


typedef struct test_file_s {
    char * image_filename;
    char * filename_adf;
    char * filename_local;

    unsigned int len;

    int max_errors;
} test_file_t;


//const unsigned int ofs_highest_pos_not_using_extension = 35135;  // 0x893f

test_file_t test_file_ofs = {
    .filename_adf = "moon.gif",
    .filename_local = "../Files/testofs_adf/MOON.GIF",
    .len = 173847,
    .max_errors = 10
};


//const unsigned int ffs_highest_pos_not_using_extension = //39935;  // 0x9bff   ( 512 * 72) ?
//    36863;  // 0x9bff

test_file_t test_file_ffs = {
    .filename_adf = "mod.And.DistantCall",
    .filename_local = "../Files/testffs_adf/mod.And.DistantCall",
    .len = 145360,
    .max_errors = 10
};


int run_multiple_seek_tests( test_file_t *  test_data );

int test_single_seek( struct AdfFile * const  file_adf,
                      FILE * const            file_local,
                      unsigned int            offset );


int main( int argc, char * argv[] )
{ 
    (void) argc;

    log_init( stderr, TEST_VERBOSITY );

    adfLibInit();

//	adfEnvSetFct(0,0,MyVer,0);
    int status = 0;

    test_file_ofs.image_filename = argv[1];
    status += run_multiple_seek_tests( &test_file_ofs );

    test_file_ffs.image_filename = argv[2];
    status += run_multiple_seek_tests( &test_file_ffs );

    adfLibCleanUp();

    return status;
}


int run_multiple_seek_tests ( test_file_t * test_data )
{
    log_info( "\n*** Testing multiple file seeking"
              "\n\timage file:\t%s\n\tfilename:\t%s\n\tlocal file:\t%s\n",
              test_data->image_filename,
              test_data->filename_adf,
              test_data->filename_local );

    struct AdfDevice * const dev = adfDevOpen( test_data->image_filename,
                                               ADF_ACCESS_MODE_READONLY );
    if ( ! dev ) {
        log_error( "Cannot open file/device '%s' - aborting...\n",
                   test_data->image_filename );
        return 1;
    }

    int status = 0;

    const ADF_RETCODE rc = adfDevMount( dev );
    if ( rc != ADF_RC_OK ) {
        log_error( "Cannot mount image %s - aborting the test...\n",
                   test_data->image_filename );
        status = 1;
        goto cleanup_dev;
    }

    struct AdfVolume * const vol = adfVolMount( dev, 0, ADF_ACCESS_MODE_READONLY );
    if ( ! vol ) {
        log_error( "Cannot mount volume 0 from image %s - aborting the test...\n",
                   test_data->image_filename );
        status = 1;
        goto cleanup_dev;
    }
#if TEST_VERBOSITY > 3
    showVolInfo( vol );
#endif

    struct AdfFile * const file_adf = adfFileOpen( vol, test_data->filename_adf,
                                                   ADF_FILE_MODE_READ );
    if ( ! file_adf ) {
        log_error( "Cannot open adf file %s - aborting...\n",
                   test_data->filename_adf );
        status = 1;
        goto cleanup_vol;
    }

    FILE * const file_local = fopen( test_data->filename_local, "rb" );
    if ( ! file_local ) {
        log_error( "Cannot open local file %s - aborting...\n",
                   test_data->filename_local );
        goto cleanup_adffile;
    }

    int errors = 0;
    for ( int i = 0 ; i < NUM_TESTS && status < MAX_ERRORS ; ++i ) {
        errors += test_single_seek( file_adf, file_local,
                                    (unsigned) rand() % test_data->len );
        if ( errors > test_data->max_errors )
            break;
    }
    status += errors;

    fclose( file_local );

cleanup_adffile:
    adfFileClose( file_adf );

cleanup_vol:
    adfVolUnMount( vol );

cleanup_dev:
    adfDevUnMount( dev );
    adfDevClose( dev );

    return status;
}


int test_single_seek( struct AdfFile * const  file_adf,
                      FILE * const            file_local,
                      unsigned int            offset )
{
    log_info( "  Reading data after seek to position 0x%x (%d)...", offset, offset );
    //fflush(stdout);

    const ADF_RETCODE rc = adfFileSeek( file_adf, offset );
    if ( rc != ADF_RC_OK ) {
        log_error( " -> seeking to 0x%x (%d) failed!!!\n", offset, offset );
        //fflush(stderr);
        return 1;
    }

    unsigned char c;
    const unsigned n = adfFileRead( file_adf, 1, &c );
    if ( n != 1 ) {
        log_error( " -> Reading data failed!!!\n" );
        //fflush(stderr);
        return 1;
    }

    if ( fseek( file_local, offset, SEEK_SET ) != 0 ) {
        log_error( " -> fseek error on local file at %u (0x%08x).",
                   offset, offset );
        //perror (" -> ");
        //fflush(stderr);
        return 1;
    }

    unsigned char expected_value;
    const size_t  items_read = fread( &expected_value, 1, 1, file_local );
    if ( items_read != 1 ) {
        log_error( " -> Error reading local file at %u (0x%08x), items read %lu.\n",
                   offset, offset, items_read );
        //fflush(stderr);
        return 1;
    }
    
    if ( c != expected_value ) {
        log_error( " -> Incorrect data read:  expected 0x%x != read 0x%x\n",
                   (int) expected_value, (int) c );
        //fflush(stderr);
        return 1;
    }

    log_info( " -> OK.\n" );
    return 0;
}
