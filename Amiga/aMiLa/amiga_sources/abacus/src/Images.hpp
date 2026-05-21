/*
* This file is part of Abacus.
* Copyright (C) 1997 Kai Nickel
* 
* Abacus is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* Abacus is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with Abacus.  If not, see <http://www.gnu.org/licenses/>.
*
*/
#ifndef INCLUDE_IMAGES_HPP
#define INCLUDE_IMAGES_HPP

#define IMG_SAVE_WIDTH        17
#define IMG_SAVE_HEIGHT       16
#define IMG_SAVE_DEPTH         3
#define IMG_SAVE_COMPRESSION   0
#define IMG_SAVE_MASKING       2

extern const ULONG IMG_Save_colors[24];
extern const UBYTE IMG_Save_body[192];



#define IMG_LOGO_WIDTH        58
#define IMG_LOGO_HEIGHT       42
#define IMG_LOGO_DEPTH         3
#define IMG_LOGO_COMPRESSION   1
#define IMG_LOGO_MASKING       2

extern const UBYTE IMG_Logo_body[801];



#define IMG_ABACUS_WIDTH        77
#define IMG_ABACUS_HEIGHT       18
#define IMG_ABACUS_DEPTH         3
#define IMG_ABACUS_COMPRESSION   1
#define IMG_ABACUS_MASKING       2

extern const ULONG IMG_Abacus_colors[24];
extern const UBYTE IMG_Abacus_body[362];


#endif
