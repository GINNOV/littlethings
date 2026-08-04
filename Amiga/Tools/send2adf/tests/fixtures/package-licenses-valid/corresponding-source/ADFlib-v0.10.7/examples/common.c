/*
 *  common - common utility functions
 *
 *  Copyright (C) 2026 Tomasz Wolak
 *
 *  This file is part of utility programs for ADFLib 
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

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

bool change_dir( struct AdfVolume * const  vol,
                 const char * const        dir_path )
{
    if ( *dir_path == '\0' )
    //   ||  strcmp( dir_path, "." ) == 0 ) // "." is a legal name in AmigaDOS(!)
    {
        return true;
    }

    char * const dirpath_tmp = strdup( dir_path );

    char * dir = dirpath_tmp;
    char * dir_end;
    while ( *dir && ( dir_end = strchr( dir, '/' ) ) ) {
        *dir_end = '\0';     // replace '/' (setting end of the dirname to change to)

        if ( adfChangeDir( vol, dir ) != ADF_RC_OK ) {
            free( dirpath_tmp );
            return false;
        }

        dir = dir_end + 1;   // next subdir
    }

    if ( adfChangeDir( vol, dir ) != ADF_RC_OK ) {
        free( dirpath_tmp );
        return false;
    }

    free( dirpath_tmp );
    return true;
}


unsigned filesize2datablocks( const unsigned fsize,
                              const unsigned blocksize )
{
    return ( fsize / blocksize +
             ( ( fsize % blocksize > 0 ) ? 1 : 0 ) );
}


unsigned datablocks2extblocks( const unsigned data_blocks )
{
    //return max ( ( data_blocks - 1 ) / ADF_MAX_DATABLK, 0 );
    if ( data_blocks < 1 )
        return 0;
    return ( data_blocks - 1 ) / ( ADF_MAX_DATABLK );
}


unsigned filesize2blocks( const unsigned fsize,
                          const unsigned blocksize )
{
    //assert ( fsize >= 0 );
    //assert ( blocksize >= 0 );
    unsigned data_blocks = filesize2datablocks( fsize, blocksize );
    unsigned ext_blocks  = datablocks2extblocks( data_blocks );
    return data_blocks + ext_blocks + 1;   // +1 is the file header block
}
