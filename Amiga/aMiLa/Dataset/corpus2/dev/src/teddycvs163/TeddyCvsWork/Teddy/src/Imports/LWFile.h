
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
	\class   LWFile
	\ingroup g_imports
	\author  Timo Suoranta
	\brief   Parses lightwave types from file
	\date    2000, 2001

	Parses lightwave types from file stream.
	Chunks have length guardian so attempting
	to read past chunk is detected.
*/


#ifndef TEDDY_IMPORTS_LW_FILE_H
#define TEDDY_IMPORTS_LW_FILE_H


#include "Imports/lwdef.h"
#include "SysSupport/Types.h"
#include "SysSupport/Messages.h"
namespace SysSupport { class EndianIn; };
using namespace SysSupport;
	

namespace Imports {


#define DOMAIN_STACK_SIZE             20
#define LWFILE_OPTION_SMOOTH_M         1
#define LWFILE_OPTION_SKIP_MATERIAL_M  2


class LWFile {
public:
	LWFile( const char *fname, Uint32 options );
	~LWFile();

	void    open      ( const char *fname );
	void    close     ();
	void    setOptions( Uint32 options );
	Uint32  getOptions();
	void    setLen    ( Uint32 len );  //  Length told in the file
	Uint32  getLen    () const;
	void    setType   ( ID4 file_type );
	ID4     getType   () const;

	void    pushDomain( Uint32 len );              //!<  Push new domain length
	U4      popDomain ( bool skip_rest = false );  //!<  Pop domain, and skip rest of it if requested
	U4      domainLeft();
	U4      bytesRead ();

	ID4     read_ID4  ();
	I1      read_I1   ();
	I2      read_I2   ();
	I4      read_I4   ();
	U1      read_U1   ();
	U2      read_U2   ();
	U4      read_U4   ();
	F4      read_F4   ();
	S0      read_S0   ();
	VX      read_VX   ();
	COL4    read_COL4 ();
	COL12   read_COL12();
	VEC12   read_VEC12();
	FP4     read_FP4  ();
	ANG4    read_ANG4 ();
	FNAM0   read_FNAM0();

protected:
	ID4       file_type;
	EndianIn *is;
	Uint32    domain_end;
	Uint32    bytes_read;
	Uint32    options;
	Uint32    file_len;

	Uint32    d_ends[DOMAIN_STACK_SIZE];  //!<  Domain guardian stack
	Uint32   *dsp;                        //!<  Domain stack pointer
};


extern char *did( ID4 id );


};  //  namespace Imports


#endif  //  TEDDY_IMPORTS_LW_FILE_H


