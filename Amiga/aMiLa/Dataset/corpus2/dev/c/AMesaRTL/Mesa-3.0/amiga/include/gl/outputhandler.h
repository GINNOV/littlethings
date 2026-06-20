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
 * outputhandler.h
 *
 * Version 1.0  01 Aug 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * Version 2.0  13 Sep 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * - SetIndexRGBTable added
 * - Getting and setting of attributes added
 * - Change in InitQuantizer interface
 * - Renamed to outputhandler.h
 * - Added parameter tags
 *
 */


#ifndef OUTPUTHANDLER_H
#define OUTPUTHANDLER_H


#ifdef __cplusplus
extern "C" {
#endif


#ifndef MAKE_OUTPUTHANDLERLIB
#include "pragmas/outputhandler_pragmas.h"
#endif

#include "mesadriver.h"

#include <utility/tagitem.h>

#define OH_Base			(AMRTL_CustomBase + 512)	/* Tags live with driver tags */

#define OH_Output		(OH_Base + 0)		/* Output handle */				/* ISG */
#define OH_ColourBase	(OH_Base + 1)		/* Should be done through parameters */
#define OH_ColorBase	(OH_ColourBase)		/* " */
#define OH_NumColours	(OH_Base + 2)		/* " */
#define OH_NumColors	(OH_NumColours)		/* " */
#define OH_OutputType	(OH_Base + 3)		/* Type of output */			/* ISG */
#define OH_Width		(OH_Base + 4)		/* Output width */				/*   G */
#define OH_Height		(OH_Base + 5)		/* Output height */				/*   G */
#define OH_ParameterQuery	(OH_Base + 6)	/* Prefs parameter string */	/*   G */
#define OH_Parameters	(OH_Base + 7)		/* Prefs parameters */			/* IS  */
#define OH_DriverBase	(OH_Base + 8)		/* Driver library base */		/* I   */
#define OH_OutputQuery	(OH_Base + 9)		/* Supported output types */	/*   G */
#define OH_RGBAOrder	(OH_Base + 10)		/* Desired RGBA byte order */	/*   G */

#define OH_CustomBase	(OH_Base + 512)

extern __asm __saveds int InitOutputHandlerA(register __a0 AmigaMesaRTLContext context, register __a1 struct TagItem *tags);
extern int InitOutputHandler(AmigaMesaRTLContext context, Tag tag, ...);
extern __asm __saveds void DeleteOutputHandler(void);
extern __asm __saveds int ResizeOutputHandler(void);
extern __asm __saveds int ProcessOutput(void);
extern __asm __saveds void SetIndexRGBTable(register __d0 int index, register __a0 ULONG *rgbtable, register __d1 int numcolours);
extern __asm __saveds ULONG SetOutputHandlerAttrsA(register __a0 struct TagItem *tags);
extern ULONG SetOutputHandlerAttrs( Tag tag, ... );
extern __asm __saveds ULONG GetOutputHandlerAttr(register __d0 ULONG attr, register __a0 ULONG *data);

#ifdef __cplusplus
}
#endif


#endif

