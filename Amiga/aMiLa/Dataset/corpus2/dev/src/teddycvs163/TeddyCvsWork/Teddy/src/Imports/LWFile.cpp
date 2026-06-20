
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


#include "Imports/LWFile.h"
#include "SysSupport/EndianIn.h"
#include <cstdio>
using namespace SysSupport;


namespace Imports {


extern char *did( ID4 id4 ){
	static char id[5*10];
	static int  counter = 0;

	char *start = id + counter * 5;
	counter++;
	if( counter >9 ){
		counter = 0;
	}

	sprintf(
		start,
		"%c%c%c%c",
		(char)((id4 & 0xff000000)>>24),
		(char)((id4 & 0x00ff0000)>>16),
		(char)((id4 & 0x0000ff00)>> 8),
		(char)((id4 & 0x000000ff)    )
	);
	return start;
}


void LWFile::setType( ID4 file_type ){
	this->file_type = file_type;
}

ID4 LWFile::getType() const {
	return file_type;
}


void LWFile::setLen( Uint32 len ){
	file_len = len;
}


Uint32 LWFile::getLen() const {
	return file_len;
}


//!  Constructor
LWFile::LWFile( const char *name, Uint32 options = 0 ){
	this->dsp     = NULL;
	this->options = options;
	open( name );
}


//!  Destructor
LWFile::~LWFile(){
	close();
}


//!	 Open lightwave file stream
void LWFile::open( const char *name ){
	is = new EndianIn( name );
	is->set_bigendian();
	bytes_read = 0;

	// Initialize domain gurdians
	for( int i=0; i<DOMAIN_STACK_SIZE; i++ ){
		d_ends[i] = 0;
	}
	dsp = d_ends;
}


//!  Close stream
void LWFile::close(){
	is->close(), is = NULL;
}


//!  Set file options
void LWFile::setOptions( Uint32 options ){
	this->options = options;
}


//!  Get file options
Uint32 LWFile::getOptions(){
	return this->options;
}


//static int depth = 0;

//!  Push domain guardian
void LWFile::pushDomain( Uint32 len ){
//	cout << "PUSH " << ++depth << endl;
	//  FIX Add stack check
	*(++dsp) = bytes_read + len;
}


//!  Pop domain guardian - returns bytes left in parent domain
U4 LWFile::popDomain( bool skip_rest ){
//	cout << "POP " << --depth << endl;
	if( skip_rest ){
		while( *dsp > bytes_read ){
			(void)read_U1();
		}
	}
	//  FIX Add stack check
	dsp--;
	return (*dsp) - (bytes_read);
}


//!  Check bytes left in domain
U4 LWFile::domainLeft(){
	return *dsp - bytes_read;
}


//!  Return number of bytes read
U4 LWFile::bytesRead(){
	return bytes_read;
}


//!  Read ID4
ID4 LWFile::read_ID4(){
	if( (*dsp) >= (bytes_read+4) ){											
		ID4 data = is->read_long();
		bytes_read += 4;
		return data;
	}else{
		return 0;
	}
}


//!  Read I1
I1 LWFile::read_I1(){
	if( (*dsp) >= (bytes_read+1) ){
		I1 data = is->read_byte();
		bytes_read++;
		return data;
	}else{
		return 0;
	}
}


//!  Read I2
I2 LWFile::read_I2(){
	if( (*dsp) >= (bytes_read+2) ){
		I2 data = is->read_short();
		bytes_read += 2;
		return data;
	}else{
		return 0;
	}
}


I4 LWFile::read_I4(){
	if( (*dsp) >= (bytes_read+4) ){
		I4 data = is->read_long();
		bytes_read += 4;
		return data;
	}else{
		return 0;
	}
}


//1  Read U1
U1 LWFile::read_U1(){
	if( (*dsp) >= (bytes_read+1) ){
		U1 data = is->read_byte();
		bytes_read++;
		return data;
	}else{
		return 0;
	}
}


//!  Read U2
U2 LWFile::read_U2(){
	if( (*dsp) >= (bytes_read+2) ){
		U2 data = is->read_short();
		bytes_read += 2;
		return data;
	}else{
		return 0;
	}
}


//!  Read U4
U4 LWFile::read_U4(){
	if( (*dsp) >= (bytes_read+4) ){
		U4 data = is->read_long();
		bytes_read += 4;
		return data;
	}else{
		return 0;
	}
}


//!  Read F4
F4 LWFile::read_F4(){
	if( (*dsp) >= (bytes_read+4) ){
		F4 data = is->read_float();
		bytes_read += 4;
		return data;
	}else{
		return 0;
	}
}


//!  Read S0
S0 LWFile::read_S0(){
	Uint8 *buffer = new Uint8[256];
	Uint8  c      = 0xff;
	int    i      = 0;

	while( (*dsp) >= (bytes_read+1) && c !=0 && i<255 ){
		buffer[i++] = c = read_U1();
	}

	if( i>254 ){
		buffer[i] = 0;
	}

	if( bytes_read & 1 ){
		(void)read_U1();
	}

	return (char*)(buffer);
}


//!  Read VX
VX LWFile::read_VX(){
	U2 data = read_U2();

	if( (data & 0xff00) == 0xff00 ){
		U2 data2 = read_U2();
		return ((data & 0x00ff) << 16) | data2;
	}else{
		return data;
	}
}


//!  Read COL4
COL4 LWFile::read_COL4(){
	float red   = (float)(read_I1()/255.0f);
	float green = (float)(read_I1()/255.0f);
	float blue  = (float)(read_I1()/255.0f);
	return Color( red, green, blue );
}


//!  Read COL12
COL12 LWFile::read_COL12(){
	float red   = read_F4();
	float green = read_F4();
	float blue  = read_F4();
	return Color( red, green, blue );
}


//!  Read VEC12
VEC12 LWFile::read_VEC12(){
	float x = read_F4();
	float y = read_F4();
	float z = read_F4();
	return Vector( x, y, -z );
}


//!  Read FP4
FP4 LWFile::read_FP4(){
	return read_F4();
}


//!  Read ANG4
ANG4 LWFile::read_ANG4(){
	return read_F4();
}


FNAM0 LWFile::read_FNAM0(){
	return read_S0();
}


};  //  namespace Imports

