#error Old File
/*
	TEDDY - General graphics application library
	Copyright (C) 1999, 2000  Timo Suoranta

	This library is free software; you can redistribute it and/or
	modify it under the terms of the GNU Library General Public
	License as published by the Free Software Foundation; either
	version 2 of the License, or (at your option) any later version.

	This library is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	Library General Public License for more details.

	You should have received a copy of the GNU Library General Public
	License along with this library; if not, write to the Free
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

	Timo Suoranta
	tksuoran@cc.helsinki.fi
*/


/*!
		\file
		\ingroup  Graphics
		\author   Timo Suoranta
		\brief	  OpenGL header
		\date	  2000
*/


#ifndef TEDDY_GRAPHICS_OPENGL_H
#define TEDDY_GRAPHICS_OPENGL_H


#if defined(_WIN32)


/* Try to avoid including <windows.h>
   to avoid name space pollution, but
   Win32's <GL/gl.h> needs APIENTRY
   and WINGDIAPI defined properly. */
# if 0
#  define  WIN32_LEAN_AND_MEAN
#  include <windows.h>
# else
   /* XXX This is from Win32's <windef.h> */
#  ifndef APIENTRY
#	define GLUT_APIENTRY_DEFINED
#	if (_MSC_VER >= 800) || defined(_STDCALL_SUPPORTED)
#	 define APIENTRY	__stdcall
#	else
#	 define APIENTRY
#	endif
#  endif
   /* XXX This is from Win32's <winnt.h> */
#  ifndef CALLBACK
#	if (defined(_M_MRX000) || defined(_M_IX86) || defined(_M_ALPHA) || defined(_M_PPC)) && !defined(MIDL_PASS)
#	 define CALLBACK __stdcall
#	else
#	 define CALLBACK
#	endif
#  endif
   /* XXX This is from Win32's <wingdi.h> and <winnt.h> */
#  ifndef WINGDIAPI
#	define GLUT_WINGDIAPI_DEFINED
#	define WINGDIAPI __declspec(dllimport)
#  endif
   /* XXX This is from Win32's <ctype.h> */
#  ifndef _WCHAR_T_DEFINED
typedef unsigned short wchar_t;
#	define _WCHAR_T_DEFINED
#  endif
# endif

#pragma comment (lib, "winmm.lib")	   /* link with Windows MultiMedia lib */
#pragma comment (lib, "opengl32.lib")  /* link with Microsoft OpenGL lib */
#pragma comment (lib, "glu32.lib")	   /* link with OpenGL Utility lib */
#pragma comment (lib, "sdl.lib")
#pragma comment (lib, "sdlmain.lib")

#pragma warning (disable:4244)	/* Disable bogus conversion warnings. */
#pragma warning (disable:4786)	/* Long names are problem to VC debugger. */

#endif

#include <GL/gl.h>
#include <GL/glu.h>
#include "SDL.h"


#ifdef GLUT_APIENTRY_DEFINED
# undef GLUT_APIENTRY_DEFINED
# undef APIENTRY
#endif

#ifdef GLUT_WINGDI
API_DEFINED
# undef GLUT_WINGDIAPI_DEFINED
# undef WINGDIAPI
#endif


#endif	//	TEDDY_GRAPHICS_OPENGL_H

