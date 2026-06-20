
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


#include "SysSupport/EndianIn.h"
#include "SysSupport/Exception.h"


namespace SysSupport {


//!  Constructor
EndianIn::EndianIn( const char *file_name ){
	open( file_name );
}


//!  Destructor
EndianIn::~EndianIn(){
    close();
}


//!  Same stream can be reused by closing and opening after constructor, too
void EndianIn::open( const char *file_name ){
	ifs = new ifstream( file_name, ios::in|ios::binary );
    /*
	cout << "Opened file " << file_name;
	cout << " for reading. Handle " << (long)ifs;
	cout << " Good status " << ifs->good();
	cout << " Is Open " << ifs->is_open();
	cout << " tellg " << ifs->tellg();
    cout << endl;
	if( ifs->tellg()!=0 ){
		cout << "Hmm, seems like we are not at the beginning of the stream. Rewinding." << endl;
		ifs->seekg(0,ios::beg);
        cout << "Final tellg " << ifs->tellg() << endl;
	}
	*/
}


//!  Close stream
void EndianIn::close(){
	//cout << "Closing file at pos " << ifs->tellg() << endl;
	if( ifs!= NULL ){
		ifs->close(), ifs = NULL;
	}
}


//!  Get file length
unsigned long EndianIn::len(){
    streampos original = ifs->tellg();
	ifs->seekg( 0, ios::end );
    unsigned long l = ifs->tellg();
	ifs->seekg( original, ios::beg );
    return l;
}


void EndianIn::read_all( char *buf ){
	ifs->read( buf, len() );
}


//!  Read in single byte from stream
unsigned char EndianIn::read_byte(){
	int            C;
	unsigned char  c = 0;

	C = ifs->get();
	if( C == EOF ){
        throw( Exception("EOF read error") );
	}else{
		c = (unsigned char)C;
	}
	return c;
}


//!  Read in two bytes and build short
unsigned short int EndianIn::read_short(){
	unsigned char c1, c2;

	c1 = read_byte();
	c2 = read_byte();

	if( q_MSBfirst() ){
		return (c1 << 8) | c2;
	}else{
		return (c2 << 8) | c1;
	}
}


//!  Read in four bytes and build long
unsigned long int EndianIn::read_long(){
	unsigned char c1, c2, c3, c4;

	c1 = read_byte();
	c2 = read_byte();
	c3 = read_byte();
	c4 = read_byte();	

	if ( q_MSBfirst() ){
		return (c1 << 24) | (c2 << 16) | (c3 << 8) | c4;
	}else{
		return (c4 << 24) | (c3 << 16) | (c2 << 8) | c1;
	}
}


//!  Read in four bytes and build float
float EndianIn::read_float(){
	float          ret_val;
	long          *shadow = (long*)(&ret_val);
	unsigned char  c1, c2, c3, c4;

	c1 = read_byte();
	c2 = read_byte();
	c3 = read_byte();
	c4 = read_byte();	

	if ( q_MSBfirst() ){
		*shadow = (c1 << 24) | (c2 << 16) | (c3 << 8) | c4;
	}else{
		*shadow = (c4 << 24) | (c3 << 16) | (c2 << 8) | c1;
	}

	return ret_val;
}


};  //  namespace SysSupport

