
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


#include "SysSupport/EndianOut.h"
#include "SysSupport/Exception.h"


namespace SysSupport {


//!  Constructor
EndianOut::EndianOut( const char *file_name ){
	open( file_name );
}


//!  Destructor
EndianOut::~EndianOut(){
    close();
}


//!  Stream can be reused after constructor by closeing and opening
void EndianOut::open( const char *name ){
	ofs = new ofstream( name,ios::out|ios::trunc|ios::binary );
}


//!  Close stream
void EndianOut::close(){
    ofs->close(), ofs = NULL;
}


//!  Write byte to stream
void EndianOut::write_byte( const int item ){
	if( !ofs->put((unsigned char)item) ){
		throw( Exception("EOF write error") );
	}
}


//!  Write short
void EndianOut::write_short( const unsigned short item ){
	if( q_MSBfirst() ){
		write_byte((item>>8) & 0xff ),
		write_byte(item & 0xff );
	}else{
		write_byte(item & 0xff ),
		write_byte((item>>8) & 0xff );
	}
}


//!  Write long
void EndianOut::write_long( const unsigned long item ){
	unsigned int t = item;
	int i;

	if( q_MSBfirst() ){
		for(i=24; i>=0; i-=8){
			write_byte((t >> i) & 0xff );
		}
	}else{
		for(i=0; i<4; i++){
			write_byte(t & 0xff ), t >>= 8;
		}
	}
}


//!  Write float
void EndianOut::write_float( const float item ){
	unsigned int t = *(unsigned int *)(&item);
	int i;

	if( q_MSBfirst() ){
		for(i=24; i>=0; i-=8){
			write_byte((t >> i) & 0xff );
		}
	}else{
		for(i=0; i<4; i++){
			write_byte(t & 0xff ), t >>= 8;
		}
	}
}


};  //  namespace SysSupport

