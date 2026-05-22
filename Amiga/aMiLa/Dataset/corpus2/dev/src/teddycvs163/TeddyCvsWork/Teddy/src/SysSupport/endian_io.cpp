
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


#include "SysSupport/endian_io.h"
#include "SysSupport/Exception.h"


EndianIO::EndianIO() : byte_order(LSBfirst){
}

void EndianIO::set_bigendian(){
	byte_order = MSBfirst;
}

void EndianIO::set_littlendian(){
	byte_order = LSBfirst;
}

bool EndianIO::q_MSBfirst() const {
	return byte_order == MSBfirst;
}


EndianIn::EndianIn( const char *file_name ){
	ifs = new ifstream( file_name, ios::in|ios::binary );
    /*
	cout << "Opened file " << file_name;
	cout << " for reading. Handle " << (long)ifs << endl;
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

EndianIn::~EndianIn(){
    close();
}

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

void EndianIn::close(){
	//cout << "Closing file at pos " << ifs->tellg() << endl;
    ifs->close();
}

EndianOut::EndianOut( const char *file_name ){
	ofs = new ofstream(file_name,ios::out|ios::trunc|ios::binary );
}

EndianOut::~EndianOut(){
    close();
}

void EndianOut::open( const char *name ){
	ofs = new ofstream( name, ios::out|ios::trunc|ios::binary );
}

void EndianOut::close(){
    ofs->close();
}

EndianIn::EndianIn(){
    ifs = NULL;
}

int EndianIn::len(){
    streampos original = ifs->tellg();
	ifs->seekg( 0, ios::end );
    int l = (int)ifs->tellg();
	ifs->seekg( original, ios::beg );
    return l;
}

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


unsigned short int EndianIn::read_short(){
	char c1, c2;

	if( !ifs->get(c1) || !ifs->get(c2) )
        throw( Exception("EOF read short") );

	if( q_MSBfirst() )
		return (c1 << 8) | c2;
	else
		return (c2 << 8) | c1;
}

unsigned long int EndianIn::read_long(){
	char c1, c2, c3, c4;

	if( !ifs->get(c1) || !ifs->get(c2) ||
		!ifs->get(c3) || !ifs->get(c4) )
        throw( Exception("EOF read long") );

	if ( q_MSBfirst() )
		return (c1 << 24) | (c2 << 16) | (c3 << 8) | c4;
	else
		return (c4 << 24) | (c3 << 16) | (c2 << 8) | c1;
}

float EndianIn::read_float(){
	float  ret_val;
	long  *shadow = (long*)(&ret_val);
	char   c1, c2, c3, c4;

	if( !ifs->get(c1) || !ifs->get(c2) ||
		!ifs->get(c3) || !ifs->get(c4) )
        throw( Exception("EOF read float") );

	if ( q_MSBfirst() )
		*shadow = (c1 << 24) | (c2 << 16) | (c3 << 8) | c4;
	else
		*shadow = (c4 << 24) | (c3 << 16) | (c2 << 8) | c1;

	return ret_val;
}

EndianOut::EndianOut(){
    ofs = NULL;
}

void EndianOut::write_byte( const int item ){
	if( !ofs->put((unsigned char)item) ){
		throw( Exception("EOF write error") );
	}
}

void EndianOut::write_short( const unsigned short item ){
	if( q_MSBfirst() ){
		write_byte((item>>8) & 0xff ),
		write_byte(item & 0xff );
	}else{
		write_byte(item & 0xff ),
		write_byte((item>>8) & 0xff );
	}
}

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

void EndianOut::write_float( const float item ){
	unsigned int t = *(unsigned int *)(&item);
	int i;

	if( q_MSBfirst() )
		for(i=24; i>=0; i-=8)
			write_byte((t >> i) & 0xff );
	else
		for(i=0; i<4; i++)
			write_byte(t & 0xff ), t >>= 8;
}

