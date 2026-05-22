/*
 * AmigaMesaRTL graphics library
 * Version:  2.0
 * Copyright (C) 1998  Jarno van der Linden
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the Free
 * Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */


/*
 * outputhandler_pragmas.h
 *
 * Version 1.0  01 Aug 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * Version 2.0  05 Sep 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * - SetIndexRGBTable added
 * - Setting and getting of attributes added
 * - Change in Init interface
 * - Renamed to outputhandler_pragmas.h
 *
 */

/* The output handler interface*/
#pragma libcall outputhandlerBase InitOutputHandlerA 1e 9802
#pragma tagcall outputhandlerBase InitOutputHandler 1e 9802
#pragma libcall outputhandlerBase DeleteOutputHandler 24 0
#pragma libcall outputhandlerBase ResizeOutputHandler 2a 0
#pragma libcall outputhandlerBase ProcessOutput 30 0
#pragma libcall outputhandlerBase SetIndexRGBTable 36 18003
#pragma libcall outputhandlerBase SetOutputHandlerAttrsA 3c 801
#pragma tagcall outputhandlerBase SetOutputHandlerAttrs 3c 801
#pragma libcall outputhandlerBase GetOutputHandlerAttr 42 8002
