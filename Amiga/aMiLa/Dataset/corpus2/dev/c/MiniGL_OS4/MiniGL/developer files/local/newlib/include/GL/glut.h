/*
 * $Id: glut.h 168 2005-08-26 13:44:23Z hfrieden $
 *
 * $Date: 2005-08-26 08:44:23 -0359ÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐ $
 * $Revision: 168 $
 *
 * (C) 1999 by Hyperion
 * All rights reserved
 *
 * This file is part of the MiniGL library project
 * See the file Licence.txt for more details
 *
 */

#ifndef _GLUT_H
#define _GLUT_H

#include <GL/gl.h>
#include <GL/glext.h>
#include <mgl/gl.h>
#include <mgl/minigl.h>
#include <interfaces/glut.h>
#include <mgl/glut.h>

#define GLUT_RGBA		(1L << 0)
#define GLUT_RGB		GLUT_RGBA
#define GLUT_SINGLE		0
#define GLUT_DOUBLE		(1L << 1)
#define GLUT_DEPTH		(1L << 2)
#define GLUT_STENCIL	(1L << 3)

#define GLUTEVENT_RESHAPE		(1L << 0)
#define GLUTEVENT_REPOSITION 	(1L << 1)
#define GLUTEVENT_FULLSCREEN	(1L << 2)
#define GLUTEVENT_POPWINDOW		(1L << 3)
#define GLUTEVENT_PUSHWINDOW	(1L << 4)
#define GLUTEVENT_SHOWWINDOW	(1L << 5)
#define GLUTEVENT_HIDEWINDOW	(1L << 6)
#define GLUTEVENT_ICONIFY		(1L << 7)
#define GLUTEVENT_REDISPLAY		(1L << 8)

#define GLUT_NOT_VISIBLE		0
#define	GLUT_VISIBLE			1

#define GLUT_LEFT				0
#define GLUT_ENTERED			1

#define GLUT_KEY_F1				256
#define GLUT_KEY_F2				257
#define GLUT_KEY_F3				258
#define GLUT_KEY_F4				259
#define GLUT_KEY_F5				260
#define GLUT_KEY_F6				261
#define GLUT_KEY_F7				262
#define GLUT_KEY_F8				263
#define GLUT_KEY_F9				264
#define GLUT_KEY_F10			265
#define GLUT_KEY_F11			266
#define GLUT_KEY_F12			267
#define GLUT_KEY_LEFT			268
#define	GLUT_KEY_UP				269
#define GLUT_KEY_RIGHT			270
#define GLUT_KEY_DOWN			271
#define GLUT_KEY_PAGE_UP		272
#define GLUT_KEY_PAGE_DOWN		273
#define GLUT_KEY_HOME			274
#define GLUT_KEY_END			275
#define GLUT_KEY_INSERT			276

#define GLUT_LEFT_BUTTON		0
#define GLUT_MIDDLE_BUTTON		1
#define GLUT_RIGHT_BUTTON		2

#define GLUT_DOWN				0
#define GLUT_UP					1


/* glutGet parameters. */
#define GLUT_WINDOW_X                   ((GLenum) 100)
#define GLUT_WINDOW_Y                   ((GLenum) 101)
#define GLUT_WINDOW_WIDTH               ((GLenum) 102)
#define GLUT_WINDOW_HEIGHT              ((GLenum) 103)
#define GLUT_WINDOW_BUFFER_SIZE         ((GLenum) 104)
#define GLUT_WINDOW_STENCIL_SIZE        ((GLenum) 105)
#define GLUT_WINDOW_DEPTH_SIZE          ((GLenum) 106)
#define GLUT_WINDOW_RED_SIZE            ((GLenum) 107)
#define GLUT_WINDOW_GREEN_SIZE          ((GLenum) 108)
#define GLUT_WINDOW_BLUE_SIZE           ((GLenum) 109)
#define GLUT_WINDOW_ALPHA_SIZE          ((GLenum) 110)
#define GLUT_WINDOW_ACCUM_RED_SIZE      ((GLenum) 111)
#define GLUT_WINDOW_ACCUM_GREEN_SIZE    ((GLenum) 112)
#define GLUT_WINDOW_ACCUM_BLUE_SIZE     ((GLenum) 113)
#define GLUT_WINDOW_ACCUM_ALPHA_SIZE    ((GLenum) 114)
#define GLUT_WINDOW_DOUBLEBUFFER        ((GLenum) 115)
#define GLUT_WINDOW_RGBA                ((GLenum) 116)
#define GLUT_WINDOW_PARENT              ((GLenum) 117)
#define GLUT_WINDOW_NUM_CHILDREN        ((GLenum) 118)
#define GLUT_WINDOW_COLORMAP_SIZE       ((GLenum) 119)
#define GLUT_WINDOW_NUM_SAMPLES         ((GLenum) 120)
#define GLUT_WINDOW_STEREO              ((GLenum) 121)
#define GLUT_WINDOW_CURSOR              ((GLenum) 122)
#define GLUT_SCREEN_WIDTH               ((GLenum) 200)
#define GLUT_SCREEN_HEIGHT              ((GLenum) 201)
#define GLUT_SCREEN_WIDTH_MM            ((GLenum) 202)
#define GLUT_SCREEN_HEIGHT_MM           ((GLenum) 203)
#define GLUT_MENU_NUM_ITEMS             ((GLenum) 300)
#define GLUT_DISPLAY_MODE_POSSIBLE      ((GLenum) 400)
#define GLUT_INIT_WINDOW_X              ((GLenum) 500)
#define GLUT_INIT_WINDOW_Y              ((GLenum) 501)
#define GLUT_INIT_WINDOW_WIDTH          ((GLenum) 502)
#define GLUT_INIT_WINDOW_HEIGHT         ((GLenum) 503)
#define GLUT_INIT_DISPLAY_MODE          ((GLenum) 504)
#define GLUT_ELAPSED_TIME               ((GLenum) 700)
#define GLUT_WINDOW_FORMAT_ID           ((GLenum) 123)



#endif
