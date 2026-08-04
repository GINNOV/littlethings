/*
 *  adfinfo_file - file metadata code
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

#ifndef ADFINFO_FILE_H
#define ADFINFO_FILE_H

#include <adflib.h>

void show_file_metadata( struct AdfVolume * const  vol,
                         const ADF_SECTNUM         fheader_sector );

void show_file_header_block( const struct AdfFileHeaderBlock * const  block );

void show_file_ext_blocks(
    struct AdfVolume * const                 vol,
    const struct AdfFileHeaderBlock * const  fheader_block );

void show_ext_block( const struct AdfFileExtBlock * const  extblock );
void show_file_data_blocks_array(
    const int32_t  datablocks[ ADF_MAX_DATABLK ] );

#endif
