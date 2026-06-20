/*
 * $Id: modes.h 26 2004-12-19 16:23:59Z tfrieden $
 *
 * $Date: 2004-12-19 11:23:59 -0359ÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐ $
 * $Revision: 26 $
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

#include <warp3D/warp3D.h>

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
