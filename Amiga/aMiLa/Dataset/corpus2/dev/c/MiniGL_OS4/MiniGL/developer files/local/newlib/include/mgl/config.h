/*
 * $Id: config.h 174 2005-09-21 13:37:48Z tfrieden $
 *
 * $Date: 2005-09-21 08:37:48 -0359ÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐ $
 * $Revision: 174 $
 *
 * (C) 1999 by Hyperion
 * All rights reserved
 *
 * This file is part of the MiniGL library project
 * See the file Licence.txt for more details
 *
 */

#ifndef __GLCONFIG_H
#define __GLCONFIG_H

// Stack sizes of the different matrix stacks
#define MODELVIEW_STACK_SIZE    40
#define PROJECTION_STACK_SIZE  5
#define TEXTURE_STACK_SIZE		5

// Stack size for attribute stack
#define ATTRIB_STACK_SIZE 30

// define this to make mglLockMode available
#define AUTOMATIC_LOCKING_ENABLE 1

// Define this is you don't want the ability to log GL calls
#define NLOGGING 1

// Define if you don't want debugging
#define GLNDEBUG 1

// Define if you don't want the compatibility macros
#ifndef __VBCC__
#define NO_GL_MACROS 1
#endif

// Define if you want to use inline functions for compatibility.
// Only valid if NO_GL_MACROS is also defined
#ifndef __VBCC__
#define USE_GL_INLINES 1
#endif

// Define if you don't want to check if the bitmaps allocated for
// screen buffering are cybergraphics bitmaps
#define NCGXDEBUG 1

// define if you don't want to draw anything
// #define NODRAW

// Maximum number of vertices a primitive can have
// Raise this value if needed, but this *should* really be enough.
#define MGL_MAXVERTS 2048

// Maximum number of texture units
#define MAX_TEXTURE_UNITS	4

// Define if you want OpenGL lighting to be compiled
#define MGL_USE_LIGHTING

// Maximum number of Lights
#define MAX_LIGHTS			8

// Maximum number of supported user clipplanes
#define MAX_CLIPPLANES		6

// Use exact squareroot function
#define MGL_USE_EXACT_SQRT  1

// Implement compiled vertex arrays (buggy and incomplete)
//#define MGL_COMPILED_VERTEX_ARRAYS 1

// Speedup hack for Quake 3
#define QUAKE3_HACK 1

// Compile for yet unreleased Warp3D extensions
#define MGL_NEW_WARP3D  1

#endif
