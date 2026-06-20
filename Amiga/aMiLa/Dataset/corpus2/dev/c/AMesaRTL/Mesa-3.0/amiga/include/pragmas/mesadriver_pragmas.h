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
 * mesadriver_pragmas.h
 *
 * Version 2.0  13 Sep 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * - Split-off into separate library
 * - (Get|Set)IndexRGB[Table] added
 * - (Get|Set)ContextAttrs added
 * - (Get|Set)QuantizerAttrs added
 * - Renamed quantizers to output handlers
 * - (Get|Set)Attrs added
 *
 */


/* "mesadriver.library" */
#pragma libcall mesadriverBase AmigaMesaRTLCreateContextA 1e 801
#pragma tagcall mesadriverBase AmigaMesaRTLCreateContext 1e 801
#pragma libcall mesadriverBase AmigaMesaRTLDestroyContext 24 801
#pragma libcall mesadriverBase AmigaMesaRTLMakeCurrent 2a 801
#pragma libcall mesadriverBase AmigaMesaRTLGetCurrentContext 30 00
#pragma libcall mesadriverBase AmigaMesaRTLSetIndexRGBTable 36 321004
#pragma libcall mesadriverBase AmigaMesaRTLSetIndexRGB 3c 321004
#pragma libcall mesadriverBase AmigaMesaRTLGetIndexRGB 42 a98004
#pragma libcall mesadriverBase AmigaMesaRTLSetContextAttrsA 48 9802
#pragma tagcall mesadriverBase AmigaMesaRTLSetContextAttrs 48 9802
#pragma libcall mesadriverBase AmigaMesaRTLGetContextAttr 4e 98003
#pragma libcall mesadriverBase AmigaMesaRTLSetOutputHandlerAttrsA 54 9802
#pragma tagcall mesadriverBase AmigaMesaRTLSetOutputHandlerAttrs 54 9802
#pragma libcall mesadriverBase AmigaMesaRTLGetOutputHandlerAttr 5a 98003
#pragma libcall mesadriverBase AmigaMesaRTLSetAttrsA 60 801
#pragma tagcall mesadriverBase AmigaMesaRTLSetAttrs 60 801
#pragma libcall mesadriverBase AmigaMesaRTLGetAttr 66 8002
