/*
 *  adfinfo_common - common utility functions
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

#ifndef ADFINFO_COMMON_H
#define ADFINFO_COMMON_H

#include <adflib.h>
#include <ctype.h>

void show_hashtable( const uint32_t hashtable[ ADF_HT_SIZE ] );

// replace non-printable with a dot ('.')
static inline char printable( char c )
{
    return ( isalnum( c ) ? c : '.' );
}

#endif
