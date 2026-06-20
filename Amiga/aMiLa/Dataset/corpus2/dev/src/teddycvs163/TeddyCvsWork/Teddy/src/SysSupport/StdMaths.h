
/*
    TEDDY - General graphics application library
    Copyright (C) 1999, 2000, 2001  Timo Suoranta
    tksuoran@cc.helsinki.fi

	This library is free software; you can redistribute it and/or
	modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	This library is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public
	License along with this library; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

/*!
	\file
	\ingroup g_sys_support
	\author  Timo Suoranta
	\brief   Wrapper for system math includes
	\date    2001
*/


#ifndef TEDDY_SYS_SUPPORT_STD_MATHS_H
#define TEDDY_SYS_SUPPORT_STD_MATHS_H


#if defined(_MSC_VER)
# pragma warning(disable:4786)
#endif


#include <cmath>
#include <cfloat>
#include <climits>
#include <cstring>
#include <cstdlib>


#undef  M_PI
#undef  M_2_PI
#define M_PI          ( 3.14159265358979323846264338327950288419716939937510)
#define M_2_PI        ( 2*M_PI)
#define M_HALF_PI     (M_PI/2)
#define DEGS_PER_RAD  (57.29577951308232286465)
#define RADS_PER_DEG  ( 0.01745329251994329547)
#define degs(x)       (x*DEGS_PER_RAD)
#define rads(x)       (x*RADS_PER_DEG)


#if !defined(_MSC_VER)
# define acosf(x) (float)(acos(x))
# define cosf(x)  (float)(cos(x))
# define sinf(x)  (float)(sin(x))
# define sqrtf(x) (float)(sin(x))
#endif


#endif  //  TEDDY_SYS_SUPPORT_STD_MATHS_H


