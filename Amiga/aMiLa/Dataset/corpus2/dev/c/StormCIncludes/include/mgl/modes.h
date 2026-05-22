/*
 * $Id: modes.h,v 1.2 2000/10/20 11:32:49 nobody Exp $
 *
 * $Date: 2000/10/20 11:32:49 $
 * $Revision: 1.2 $
 *
 * (C) 1999 by Hyperion
 * All rights reserved
 *
 * This file is part of the MiniGL library project
 * See the file Licence.txt for more details
 *
 */

#ifndef __MGL_MODES_H
#define __MGL_MODES_H

#include <Warp3D/Warp3D.h>

#define MGL_MAX_MODE 80

typedef struct
{
	GLint id;               // blackbox id used for mglCreateContextID()
	GLint width,height;     // screenmode size
	GLint bit_depth;        // depth of mode
	char  mode_name[MGL_MAX_MODE]; // name for this mode
} MGLScreenMode;

typedef struct
{
	ULONG width,height,depth;
	ULONG pixel_format;
	void *base_address;
	ULONG pitch;
} MGLLockInfo;

typedef GLboolean (*MGLScreenModeCallback)(MGLScreenMode *);

#endif
