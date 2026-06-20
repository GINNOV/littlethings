
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
	\brief   Error, warning, init and debug message routines
	\date    2001
*/


#ifndef TEDDY_SYS_SUPPORT_MESSAGES_H
#define TEDDY_SYS_SUPPORT_MESSAGES_H


#define mkstr_(x) # x
#define mkstr(x) mkstr_( x )
#define MSG_HEAD mkstr( __FILE__ ) ": " mkstr( __LINE__ ) " "

extern void fatal_msg     ( char *format, ... );
extern void init_msg      ( char *format, ... );
extern void warn_msg      ( char *format, ... );
extern void error_msg     ( char *format, ... );
extern void debug_msg     ( char *format, ... );
extern void mat_debug_msg ( char *format, ... );
extern void lwo_debug_msg ( char *format, ... );
extern void ffe_debug_msg ( char *format, ... );
extern void net_debug_msg ( char *format, ... );
extern void tmap_debug_msg( char *format, ... );
extern void vert_debug_msg( char *format, ... );
extern void wm_debug_msg  ( char *format, ... );


#endif  //  TEDDY_SYS_SUPPORT_MESSAGES_H

