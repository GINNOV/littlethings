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

#ifndef COMMON_H
#define COMMON_H

#include <adflib.h>

bool change_dir( struct AdfVolume * const  vol,
                 const char * const        dir_path );


unsigned filesize2datablocks( const unsigned fsize,
                              const unsigned blocksize );

unsigned datablocks2extblocks( const unsigned data_blocks );

unsigned filesize2blocks( const unsigned fsize,
                          const unsigned blocksize );

#endif
