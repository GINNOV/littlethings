
/*
	TEDDY - General graphics application library
	Copyright (C) 1999, 2000, 2001	Timo Suoranta
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
	\class	 FileScan
	\ingroup g_sys_support
	\author  Timo Suoranta
	\brief	 Scan for pattern matching files (in single directory)
	\warning Minimal implementation
	\bug	 Implementations for WIN32 and POSIX work differently!
	\date	 2000, 2001
*/



#ifndef TEDDY_SYS_SUPPORT_FILE_SCAN_H
#define TEDDY_SYS_SUPPORT_FILE_SCAN_H


#include "SysSupport/StdList.h"


extern char *fix_file_name( char *file_name );


class FileScan {
public:
	FileScan( const char *pattern );

	inline list<char*> &get_files(){
		return files;
	};
	inline const list<char *> &get_files() const {
		return files;
	};

private:
	list<char *> files;
};


#endif	//	TEDDY_SYS_SUPPORT_FILE_SCAN_H

