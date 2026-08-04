/*
 *  adfinfo_dircache - directory cache metadata code
 *
 *  Copyright (C) 2023-2026 Tomasz Wolak
 *
 *  This file is part of adfinfo, an utility program showing low-level
 *  filesystem metadata of Amiga Disk Files (ADFs).
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

#include <adf_cache.h>
#include <ctype.h>
#include <stdio.h>
#include <string.h>

#include "adfinfo_dircache.h"

//#include "adfinfo_common.h"

static void show_dircache_block( const struct AdfDirCacheBlock * const  block );

//static void show_dircache_records( const uint8_t * const  records,
//                                   const unsigned         nRecords );

static void show_dircache_block_record( const struct AdfCacheEntry * const  cEntry );


void show_dircache_metadata( struct AdfVolume * const  vol,
                             ADF_SECTNUM               dircache_blocknum )
{
    if ( ! adfVolHasDIRCACHE( vol ) )
        return;

    struct AdfDirCacheBlock dcblock;

    for ( unsigned i = 0;
          dircache_blocknum != 0;
          dircache_blocknum = dcblock.nextDirC, i++ )
    {
        if ( adfReadDirCBlock( vol, dircache_blocknum, &dcblock ) != ADF_RC_OK ) {
            fprintf( stderr, "Error reading dircache block at sector %u.\n",
                     dircache_blocknum );
            return;
        }

        printf( "\nDirCache block %u, block %u (0x%08x):\n",
                i, dircache_blocknum, dircache_blocknum );
        show_dircache_block( &dcblock );
    }    
}

static void show_dircache_block( const struct AdfDirCacheBlock * const  block )
{
    uint8_t block_orig_endian[ 512 ];
    memcpy( block_orig_endian, block, 512 );
    adfSwapEndian( block_orig_endian, ADF_SWBL_CACHE );
    uint32_t checksum_calculated = adfNormalSum( block_orig_endian, 0x14,
                                                 sizeof(struct AdfDirCacheBlock) );
    printf( //"\nDirCache block %u:\n"
            //"  offset field\t\tvalue\n"
            "  0x000  type:\t\t0x%x\t\t%u\n"
            "  0x004  headerKey:\t0x%x\t\t%u\n"
            "  0x008  parent:\t0x%x\t\t%u\n"
            "  0x00c  recordsNb:\t0x%x\t\t%u\n"
            "  0x010  nextDirC:\t0x%x\t\t%u\n"
            "  0x014  checkSum:\t0x%x\n"
            "     ->  calculated:\t0x%x%s\n"
            "  0x018  records[]: (remaining 488 bytes, entries list below)\n",
            block->type,      block->type,
            block->headerKey, block->headerKey,
            block->parent,    block->parent,
            block->recordsNb, block->recordsNb,
            block->nextDirC,  block->nextDirC,
            block->checkSum,
            checksum_calculated,
            block->checkSum == checksum_calculated ? " -> OK" : " -> different(!)" );

    //show_dircache_records( block->records, (unsigned) block->recordsNb );

    int recordOffset = 0;
    struct AdfCacheEntry cEntry;
    for ( int i = 0 ; i < block->recordsNb ; i++ ) {
        if ( adfGetCacheEntry( block, &recordOffset, &cEntry ) != ADF_RC_OK ) {
            fprintf( stderr,"\nDirCache record %d: error getting entry.\n", i );
            continue;
        }

        printf( "\nDirCache record %d:\n", i );
        show_dircache_block_record( &cEntry );
    }    
}

/*
static void show_dircache_records( const uint8_t * const  records,
                                   const unsigned         nRecords )
{
    const uint8_t * record = records;
    for ( unsigned i = 0 ; i < nRecords ; i++ ) {
        struct AdfCacheEntry cEntry = {
            .header  = *( (uint32_t *) ( &record[ 0 ] ) ),
            .size    = *( (uint32_t *) ( &record[ 4 ] ) ),
            .protect = *( (uint32_t *) ( &record[ 8 ] ) ),
            // uid, gid ?
            .days    = *( (uint16_t *) ( &record[ 16 ] ) ),
            .mins    = *( (uint16_t *) ( &record[ 18 ] ) ),
            .ticks   = *( (uint16_t *) ( &record[ 20 ] ) ),
            .type    = *( (int8_t *)   ( &record[ 22 ] ) ),
            .nLen    = *( (uint8_t *)  ( &record[ 23 ] ) ),
        };

        cEntry.cLen = *( (uint8_t *)  ( &record[ 24 + cEntry.nLen ] ) );

        strncpy( cEntry.name, (char *) &record[ 24 ], ADF_MAX_NAME_LEN );
        cEntry.name[ ADF_MAX_NAME_LEN ] = '\0';

        strncpy( cEntry.comm, (char *) &record[ 24 + cEntry.nLen + 1 ], ADF_MAX_COMMENT_LEN );
        cEntry.comm[ ADF_MAX_COMMENT_LEN ] = '\0';
        
        printf( "\nDirCache record %u:\n", i );
        show_dircache_block_record( &cEntry );
    }
}
*/

static void show_dircache_block_record( const struct AdfCacheEntry * const  cEntry )
{
    printf( "  header:\t0x%08x\t%u\n"
            "  size:\t\t0x%08x\t%u\n"
            "  protect:\t0x%08x\t%u\n"
            "  days:\t\t0x%04x\t\t%u\n"
            "  mins:\t\t0x%04x\t\t%u\n"
            "  tics:\t\t0x%04x\t\t%u\n"
            "  type:\t\t0x%02x\t\t%d\n"
            "  nlen:\t\t0x%02x\t\t%u\n"
            "  clen:\t\t0x%02x\t\t%u\n"
            "  name:\t\t'%s'\n"
            "  comm:\t\t'%s'\n",
            cEntry->header,  cEntry->header,
            cEntry->size,    cEntry->size,
            cEntry->protect, cEntry->protect,
            cEntry->days,    cEntry->days,
            cEntry->mins,    cEntry->mins,
            cEntry->ticks,   cEntry->ticks,
            (uint8_t) cEntry->type, (int8_t) cEntry->type,
            (uint8_t) cEntry->nLen, (int8_t) cEntry->nLen,
            (uint8_t) cEntry->cLen, (int8_t) cEntry->cLen,
            cEntry->name, 
            cEntry->comm );
}
