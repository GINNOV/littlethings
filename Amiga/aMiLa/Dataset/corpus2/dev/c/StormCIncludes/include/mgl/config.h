/*
 * $Id: config.h,v 1.2 2000/10/20 11:32:33 nobody Exp $
 *
 * $Date: 2000/10/20 11:32:33 $
 * $Revision: 1.2 $
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

#ifndef __VBCC__
#define INLINE __inline
#else
#define INLINE
#endif

// Stack sizes of the different matrix stacks
#define MODELVIEW_STACK_SIZE    40
#define PROJECTION_STACK_SIZE  5

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
#define MGL_MAXVERTS 1024

#endif
