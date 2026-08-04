/*
 *  adfls - show contents of directories on ADF volumes
 *
 *  Copyright (C) 2026 Tomasz Wolak
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License along
 *  with this program; if not, see <https://www.gnu.org/licenses/>.
 *
 */

#include "common.h"
#include "pathutils.h"

#include <adflib.h>
#include <adf_dev_driver_nativ.h>
#include <errno.h>
#include <inttypes.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

#ifndef HAVE_GETOPT
#include "getopt.h"      // use custom getopt
#else
#include <unistd.h>
#endif

#ifndef WIN32
#include <libgen.h>
#endif

typedef struct CmdlineOptions {
    char            *adfDevName;
    unsigned         volidx;
    struct AdfVector paths;
    bool             longFormat,
                     sizeInBlocks,
                     verbose,
                     help,
                     version;
} CmdlineOptions;

CmdlineOptions options;

bool parse_args( const int * const     argc,
                 char * const * const  argv,
                 CmdlineOptions *      options );

bool show_paths( struct AdfVolume * const       vol,
                 const struct AdfVector * const paths );

bool show_path( struct AdfVolume * const  vol,
                const char * const        path );

bool show_current_dir( struct AdfVolume * const  vol );

void show_entry( struct AdfVolume * const      vol,
                 const struct AdfEntry * const entry );

void adfAccess2String( const int32_t  acc,
                       char           accStr[ 8 + 1 ] );

void usage(void)
{
    printf( "\nUsage:  adfls [options] adf_device [path]...\n\n"
            "List contents of directories of an ADF/HDF volume.\n\n"
            "Options:\n"
            "  -b         show size in blocks (total number of blocks used)\n"
            "  -p volume  volume/partition index, counting from 0, default: 0\n"
            "  -l         use long listing format\n"
            "  -v         be more verbose\n\n"
            "  -h         show help\n"
            "  -V         show version\n\n" );
}


int main( const int     argc,
          char * const argv[] )
{
    if ( ! parse_args( &argc, argv, &options ) ) {
        fprintf( stderr, "Usage info:  adfls -h\n" );
        exit( EXIT_FAILURE );
    }

    if ( options.help ) {
        usage();
        exit( EXIT_SUCCESS );
    }

    if ( options.version ) {
        printf( "%s, powered by ADFlib: build   v%s (%s)\n"
                "                           runtime v%s (%s)\n",
                ADFLIB_VERSION,
                ADFLIB_VERSION, ADFLIB_DATE,
                adfGetVersionNumber(), adfGetVersionDate() );
        exit( EXIT_SUCCESS );
    }

    int status = 0;

    adfLibInit();
    adfAddDeviceDriver( &adfDeviceDriverNative );
    adfEnvSetProperty( ADF_PR_USEDIRC, true );
 
    struct AdfDevice * const dev = adfDevOpen( options.adfDevName,
                                               ADF_ACCESS_MODE_READONLY );
    if ( dev == NULL ) {
        fprintf( stderr, "Error opening device '%s' - aborting...\n",
                 options.adfDevName );
        status = 1;
        goto clean_up_env;
    }

    ADF_RETCODE rc = adfDevMount( dev );
    if ( rc != ADF_RC_OK ) {
        fprintf( stderr, "Error mounting device '%s' - aborting...\n",
                 options.adfDevName );
        status = 2;
        goto clean_up_dev_close;
    }

    //const char * const devinfo = adfDevGetInfo( dev );
    //printf( "%s\n", devinfo );
    //free( devinfo );

    struct AdfVolume * const vol = adfVolMount( dev, (int) options.volidx,
                                                ADF_ACCESS_MODE_READONLY );
    if ( vol == NULL ) {
        fprintf( stderr, "Error mounting volume %d of '%s' - aborting...\n",
                 options.volidx, options.adfDevName );
        status = 3;
        goto clean_up_dev_unmount;
    }

    if ( ! show_paths( vol, &options.paths ) )
        status = ENOENT;
    
//clean_up_volume:
    adfVolUnMount( vol );

clean_up_dev_unmount:
    adfDevUnMount( dev );

clean_up_dev_close:
    adfDevClose( dev );

clean_up_env:
    adfLibCleanUp();

    //printf("options paths items ptr (destroy) = 0x%"PRIxPTR"\n",
    //       options.paths.items );
    options.paths.destroy( &options.paths );

    return status;
}


/* return value: true - valid, false - invalid */
bool parse_args( const int * const     argc,
                 char * const * const  argv,
                 CmdlineOptions *      options )
{
    // set default options
    memset( options, 0, sizeof( CmdlineOptions ) );
    options->volidx  = 0;
    options->longFormat =
        options->verbose =
        options->help    =
        options->version = false;
    options->paths   = adfVectorCreate( 0, sizeof(char *) );

    const char * valid_options = "blp:hvV";
    int opt;
    while ( ( opt = getopt( *argc, (char * const *) argv, valid_options ) ) != -1 ) {
//        printf ( "optind %d, opt %c, optarg %s\n", optind, ( char ) opt, optarg );
        switch ( opt ) {
        case 'b':
            options->sizeInBlocks = true;
            break;

        case 'l':
            options->longFormat = true;
            break;

        case 'p': {
            // partition (volume) number (index)
            char * endptr = NULL;
            options->volidx = ( unsigned int ) strtoul( optarg, &endptr, 10 );
            if ( endptr == optarg ||
                 options->volidx > 255 )  // is there a limit for max. number of partitions???
            {
                fprintf( stderr, "Invalid volume/partition %u.\n", options->volidx );
                return false;
            }
            continue;
        }

        case 'v':
            options->verbose = true;
            continue;

        case 'h':
            options->help = true;
            return true;

        case 'V':
            options->version = true;
            return true;

        default:
            return false;
        }
    }

    /* the name of the adf device - required */
    if ( optind > *argc - 1 ) {
        fprintf( stderr, "Missing the name of an adf file/device.\n" );
        return false;
    }
    options->adfDevName = argv[ optind++ ];

    if ( optind >= *argc )
        return true;

    /* (optional) list of files (given as sectors of their file header blocks)
       to undelete */
    options->paths = adfVectorCreate( (unsigned)( *argc - optind ),
                                      sizeof(char *) );
    if ( options->paths.items == NULL ) {
        fprintf( stderr, "Memory allocation error.");
        return false;
    }

    //printf("options paths items ptr (create) = 0x%"PRIxPTR"\n",
    //       options->paths.items );

    for ( unsigned i = 0 ; i < options->paths.nItems ; i++ ) {
        //printf ("Adding %s\n", argv[ optind ] );
        ( &( (char **) options->paths.items )[0] )[ i ] = argv[ optind++ ];
    }

    //printf("options paths items ptr (create 2) = 0x%"PRIxPTR"\n",
    //       options->paths.items );

    return true;
}

// returns true on success
bool show_paths( struct AdfVolume * const       vol,
                 const struct AdfVector * const paths )
{
    if ( paths->nItems < 1 ) {
        //printf (" CASE 1\n");
        return show_path( vol, "" );
    }

    bool status = true;

    for ( unsigned i = 0; i < paths->nItems; i++ ) {
        //printf (" CASE 2\n");
        adfToRootDir( vol );
        const char * const path = ( &( (char **) paths->items )[0] )[ i ];
        if ( paths->nItems > 1 )
            printf("\n%s:\n", path );
        if ( ! show_path( vol, path ) )
            status = false;
    }

    return status;
}


bool show_path( struct AdfVolume * const  vol,
                const char * const        path )
{
    //printf("%s: path '%s'\n", __func__, path );
    const char * path_relative = path;

    // skip all leading '/' from the path
    while ( *path_relative == '/' )
        path_relative++;

    if ( *path_relative == '\0' ) {
        return show_current_dir( vol );
    }

    // not in the root directory so must chdir to the proper one
    //printf("\nChanging dir to %s.\", );
    char * const dirpath_buf   = strdup( path_relative );
    char * const dir_path      = dirname( dirpath_buf );
    char * const entryname_buf = strdup( path );
    char * const entry_name    = basename( entryname_buf );

    bool status = true;
    if ( strcmp( dir_path, "." ) != 0 &&
         ! change_dir( vol, dir_path ) )
    {
        fprintf( stderr, "Invalid dir: '%s'\n", dir_path );
        status = false;
        goto cleanup;
    }

    if ( strlen( entry_name ) > 0 &&
         strcmp( entry_name, "." ) != 0 )
    {
        // get entry
        struct AdfEntry * const entry = malloc( sizeof( struct AdfEntry ) );
        if ( entry == NULL ) {
            status = false;
            goto cleanup;
        }
        ADF_RETCODE rc = adfGetEntry( vol, vol->curDirPtr,
                                      entry_name, entry );
        if ( rc != ADF_RC_OK ) {
            //fprintf( stderr, "Error getting entry for path '%s'.\n", path );
            fprintf( stderr, "%s: No such file or directory.\n", path );
            status = false;

            //adfFreeEntry( entry ); - this fails(!)
            free( entry );

            goto cleanup;
        }

        if ( entry->type == ADF_ST_DIR ) {
            if ( ! change_dir( vol, entry_name ) ) {
                fprintf( stderr, "Cannot enter dir: '%s'\n", path );
                adfFreeEntry( entry );
                status = false;
                goto cleanup;
            }
            
            show_current_dir( vol );
        }
        else
            show_entry( vol, entry );

        adfFreeEntry( entry );
    } else {
        show_current_dir( vol );
    }

cleanup:
    free( entryname_buf );
    free( dirpath_buf );

    return status;
}


bool show_current_dir( struct AdfVolume * const  vol )
{
    struct AdfList * const list = adfGetDirEnt( vol, vol->curDirPtr );

    for ( struct AdfList * node = list; node; node = node->next ) {
        show_entry( vol, node->content );
    }

    adfFreeDirList( list );

    return true;
}

void show_entry( struct AdfVolume * const      vol,
                 const struct AdfEntry * const entry )
{
    if ( options.longFormat ) {
        const char * const type = ( entry->type == ADF_ST_DIR   ? "D " :
                                    entry->type == ADF_ST_FILE  ? "F " :
                                    entry->type == ADF_ST_LFILE ? "LF" :
                                    entry->type == ADF_ST_LDIR  ? "LD" :
                                    entry->type == ADF_ST_LSOFT ? "LS" : "? " );

        // get entry block (for detailed info)
        struct AdfEntryBlock entry_block;
        ADF_SECTNUM sector = adfGetEntryBlock( vol, vol->curDirPtr, entry->name,
                                               &entry_block );
        if ( sector < 0 ) {
            // this should not happen as the entry block was already read earlier
            // but checking anyway...
            fprintf( stderr, "Error getting entry for '%s', sector %d.\n",
                     entry->name, sector );
            printf( "%s\n", entry->name );
            return;
        }

        // get size
        unsigned size = ADF_LOGICAL_BLOCK_SIZE;
        if ( entry->type == ADF_ST_FILE ) {
            size = ( (struct AdfFileHeaderBlock *) &entry_block )->byteSize;
        }

        if ( options.sizeInBlocks )
            size = ( entry->type == ADF_ST_FILE ?
                     filesize2blocks( size, ADF_LOGICAL_BLOCK_SIZE ) : 1 );

        char accessStr[ 8 + 1 ] = "        ";
        if ( entry->type == ADF_ST_FILE ||
             entry->type == ADF_ST_DIR )
        {
            adfAccess2String( entry->access, accessStr );
        }

        if ( entry->type == ADF_ST_LSOFT ) {
            printf( "%s %11u  %4d/%02d/%02d %2d:%02d:%02d  %s %s -> %s\n",
                    accessStr, size,
                    entry->year, entry->month, entry->days,
                    entry->hour, entry->mins, entry->secs,
                    type, entry->name,
                    ( (struct AdfLinkBlock *) &entry_block )->realName );
        } else {
            printf( "%s %11u  %4d/%02d/%02d %2d:%02d:%02d  %s %s\n",
                    accessStr, size,
                    entry->year, entry->month, entry->days,
                    entry->hour, entry->mins, entry->secs,
                    type, entry->name );
        }
    } else {
        printf( "%s\n", entry->name );
    }
}


void adfAccess2String( const int32_t  acc,
                       char           accStr[ 8 + 1 ] )
{
    strcpy( accStr, "----rwed" );
    if ( adfAccHasD( acc ) )  accStr[ 7 ] = '-';
    if ( adfAccHasE( acc ) )  accStr[ 6 ] = '-';
    if ( adfAccHasW( acc ) )  accStr[ 5 ] = '-';
    if ( adfAccHasR( acc ) )  accStr[ 4 ] = '-';
    if ( adfAccHasA( acc ) )  accStr[ 3 ] = 'a';
    if ( adfAccHasP( acc ) )  accStr[ 2 ] = 'p';
    if ( adfAccHasS( acc ) )  accStr[ 1 ] = 's';
    if ( adfAccHasH( acc ) )  accStr[ 0 ] = 'h';
}
