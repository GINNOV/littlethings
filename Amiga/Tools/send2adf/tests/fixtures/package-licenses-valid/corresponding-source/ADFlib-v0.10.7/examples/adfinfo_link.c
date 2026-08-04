/*
 *  adfinfo_link - link metadata code
 *
 *  Copyright (C) 2026 Tomasz Wolak
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

#include "adfinfo_link.h"
#include <stdio.h>


void show_link_metadata( struct AdfVolume * const  vol,
                         const ADF_SECTNUM         link_sector )
{
    struct AdfLinkBlock //AdfEntryBlock
        block;

    if ( adfReadEntryBlock( vol, link_sector,
                            (struct AdfEntryBlock * ) &block ) != ADF_RC_OK )
    {
        fprintf( stderr, "Error reading link block (%d)\n",
                 link_sector );
        return;
    }

    uint8_t block_orig_endian[ 512 ];
    memcpy( block_orig_endian, &block, 512 );
    adfSwapEndian( block_orig_endian, ADF_SWBL_LINK );
    uint32_t checksum_calculated = adfNormalSum( block_orig_endian, 0x14,
                                                 sizeof( struct AdfLinkBlock ) );
    printf( "\nLink block:\n"
            //"  Offset  field\t\tvalue\n"
            "  0x000  type\t\t0x%x\t\t%u\n"
            "  0x004  headerKey\t0x%x\t\t%u\n"
            "  0x008  r1[ 3 ]\n"
            "  0x014  checkSum\t0x%x\n"
            "     ->  calculated:\t0x%x%s\n"
            "  0x018  realName[ 64 ]\t%s\n"
            "  0x058  r2[ 83 ]\n"
            "  0x1a4  days\t\t0x%x\t\t%u\n"
            "  0x1a8  mins\t\t0x%x\t\t%u\n"
            "  0x1ac  ticks\t\t0x%x\t\t%u\n"
            "  0x1b0  nameLen\t0x%x\t\t%u\n"
            "  0x1b1  name:\t\t%s\n"
            "  0x1d0  r3\t\t0x%x\n"
            "  0x1d4  realEntry\t0x%x\t\t%u\n"
            "  0x1d8  nextLink\t0x%x\t\t%u\n"
            "  0x1dc  r4[ 5 ]\n" //": \t\t(see below)\n"
            "  0x1f0  nextSameHash\t0x%x\t\t%u\n"
            "  0x1f4  parent\t\t0x%x\t\t%u\n"
            "  0x1f8  r5\t\t0x%x\t\t%u\n"
            "  0x1fc  secType\t0x%x\t%d\n",
            block.type, block.type,
            block.headerKey, block.headerKey,
            //block.r1[ 3 ],
            block.checkSum, checksum_calculated,
            block.checkSum == checksum_calculated ? " -> OK" : " -> different(!)",
            block.realName,
            //block.r2[ 83 ],
            block.days, block.days,
            block.mins, block.mins,
            block.ticks, block.ticks,
            block.nameLen, block.nameLen,
            block.name,
            block.r3,
            block.realEntry, block.realEntry,
            block.nextLink, block.nextLink,
            //block.r4[ 5 ],
            block.nextSameHash, block.nextSameHash,
            block.parent, block.parent,
            block.r5, block.r5,
            block.secType, block.secType );
}
