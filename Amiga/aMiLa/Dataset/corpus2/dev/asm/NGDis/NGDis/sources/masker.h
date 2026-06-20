#ifndef _mask_h_included
#define _mask_h_included

#include <cassert>
#include "dissasm.h"

//
//
//

class MaskTLCS900 {
private:
public:
	MaskTLCS900() {}
	~MaskTLCS900() {}

	inline int getR( Mem& m, int i=0 ) const {
		return static_cast<int>( m[i] & 0x07 );
	}
	inline int getR( unsigned char m ) const {
		return static_cast<int>( m & 0x07 );
	}
	inline int getr( Mem& m, int i=0 ) const {
		if (m[i] & 0x0f == 0x07) {
			// opcode case xxxx0111 -> next byte tells the actual r
			return -1;
		} else {
			return static_cast<int>( m[i] & 0x07 );
		}
	}
	inline int getr( unsigned char m ) const {
		if (m & 0x0f == 0x07) {
			// opcode case xxxx0111 -> next byte tells the actual r
			return -1;
		} else {
			return static_cast<int>( m & 0x07 );
		}
	}
	inline int getzz( Mem& m, int i=0 ) const {
		return static_cast<int>( (m[i] & 0x30) >> 4 );
	}
	inline int getzz( unsigned char m ) const {
		return static_cast<int>( (m & 0x30) >> 4 );
	}
	inline int getzzz( Mem& m, int i=0 ) const {
		return static_cast<int>( (m[i] & 0x70) >> 4 );
	}
	inline int getzzz( unsigned char m ) const {
		return static_cast<int>( (m & 0x70) >> 4 );
	}
	inline int getcc( Mem& m, int i=0 ) const {
		return static_cast<int>( m[i] & 0x0f );
	}
	inline int getcc( unsigned char m ) const {
		return static_cast<int>( m & 0x0f );
	}
	inline int getmem( Mem& m, int i=0 ) const {
		int mm = static_cast<int>( m[i] & 0x4f );
		return ((mm & 0x40) >> 2) | (mm & 0x0f);
	}
	inline int getmem( unsigned char m ) const {
		int mm = static_cast<int>( m & 0x4f );
		return ((mm & 0x40) >> 2) | (mm & 0x0f);
	}
	inline int getz1( Mem& m, int i=0 ) const {
		return static_cast<int>( m[i] & 0x02);
	}
	inline int getz1( unsigned char m ) const {
		return static_cast<int>( m & 0x02);
	}
	inline int getz4( Mem& m, int i=0 ) const {
		int z4 = static_cast<int>( m[i] & 0x30);
		assert(z4 > 0x20);
		return z4 >> 4;
	}
	inline int getz4( unsigned char m ) const {
		int z4 = static_cast<int>( m & 0x30);
		assert(z4 > 0x20);
		return z4 >> 4;
	}
	inline int getIm3( Mem& m, int i=0 ) const {
		return static_cast<int>( m[i] & 0x07);
	}
	inline int getIm3( unsigned char m ) const {
		return static_cast<int>( m & 0x07);
	}
	inline int getIm4( Mem& m, int i=0 ) const {
		return static_cast<int>( m[i] & 0x0f);
	}
	inline int getIm4( unsigned char m ) const {
		return static_cast<int>( m & 0x0f);
	}
	inline char getIm8( Mem& m, int i=0 ) const {
		return static_cast<int>( m[i] );
	}
	inline unsigned char getIm8u( Mem& m, int i=0 ) const {
		return static_cast<int>( m[i] ) & 0xff;
	}
	inline short getIm16( Mem& m, int i=0 ) const {
		// little endian..
		return static_cast<int>( (m[i+1] << 8) | m[i] );
	}
	inline unsigned short getIm16u( Mem& m, int i=0 ) const {
		// little endian..
		return static_cast<int>( (m[i+1] << 8) | m[i]) & 0xffff;
	}
	inline long getIm24( Mem& m, int i=0 ) const {
		// little endian..
		return static_cast<long>( (m[i+2] << 16) | (m[i+1] << 8) | m[i] );
	}
	inline long getIm32( Mem& m, int i=0 ) const {
		// little endian..
		return static_cast<long>( (m[i+3] << 24) | (m[i+2] << 16) | (m[i+1] << 8) | m[i] );
	}
};




#endif
