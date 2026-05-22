//
//
//

#include <stdio.h>
#include <string.h>
#include <assert.h>
#include "tlcs900d.h"

//
//
//

uint8_t get8u( uint8_t *b ) {
  return *b;
}

uint16_t get16u( uint8_t *b ) {
  return ((b[1] << 8) | *b);
}

uint32_t get24u( uint8_t *b ) {
  return ((b[2] << 16) | (b[1] << 8) | *b);
}

uint32_t get32u( uint8_t *b ) {
  return ((b[3] << 24) | (b[2] << 16) | (b[1] << 8) | *b);
}

//
//
//

int8_t get8( uint8_t *b ) {
  return *b;
}

int16_t get16( uint8_t *b ) {
  return ((b[1] << 8) | *b);
}

int32_t get32( uint8_t *b ) {
  return ((b[3] << 24) | (b[2] << 16) | (b[1] << 8) | *b);
}

//
//
//

int getR( unsigned char *m ) {
  return *m & 0x07;
}

int getr( unsigned char *m ) {
  if ((*m & 0x0f) == 0x07) {
		// opcode case xxxx0111 -> next byte tells the actual r
    return -1;
  } else {
    return *m & 0x07;
  }
}

int getzz( unsigned char *m ) {
	return (*m & 0x30) >> 4;
}

int getzzz( unsigned char *m ) {
	return (*m & 0x70) >> 4;
}

int getcc( unsigned char *m ) {
	return *m & 0x0f;
}

int getmem( unsigned char *m ) {
	int mm = *m & 0x4f;
	return ((mm & 0x40) >> 2) | (mm & 0x0f);
}

int getz1( unsigned char *m ) {
	return *m & 0x02;
}

int getz4( unsigned char *m ) {
	int z4 = *m & 0x30;
	return z4 >> 4;
}

int get3( unsigned char *m ) {
	return *m & 0x07;
}

int get4( unsigned char *m ) {
	return *m & 0x0f;
}

//
//
//

int retmem( unsigned char *b, char *s, int mem ) {
  int i;

  switch (mem) {
  case ARI_XWA: case ARI_XBC: case ARI_XDE: case ARI_XHL:
  case ARI_XIX: case ARI_XIY: case ARI_XIZ: case ARI_XSP:
    strcpy(s,addr_names[mem]);
    return 1;
  case ARID_XWA: case ARID_XBC: case ARID_XDE: case ARID_XHL:
  case ARID_XIX: case ARID_XIY: case ARID_XIZ: case ARID_XSP:
    sprintf(s,"%s%04Xh)",addr_names[mem],get8(b+1) );
    return 1+1;
  case ABS_B:
    sprintf(s,"(%02Xh)",b[1]);
    return 1+1;
  case ABS_W:
    sprintf(s,"(%04Xh)",get16u(b+1));
    return 1+2;
  case ABS_L:
    sprintf(s,"(%06Xh)",get24u(b+1));
    return 1+3;
	case ARI:
    switch (b[1] & 0x03) {
    case 0x00:  // (r32)
      sprintf(s,"(%s)",r32_names[b[1] & 0xfc]);
      return 1+1;
    case 0x01:  // (r32 + d16)
      sprintf(s,"(%s+%04Xh)",r32_names[b[1] & 0xfc ], get16(b+2) );
      return 1+3;
    case 0x03:
      if (b[1] & 0x4) { // (r32+r16)
        sprintf(s,"(%s+%s)",r32_names[b[2]],r16_names[b[3]]);
      } else {          // (r32+r8)
        sprintf(s,"(%s+%s)",r32_names[b[2]],r8_names[b[3]]);
      }
      return 1+3;
    }
  case ARI_PD:
    //i = b[1] & 0x03;
    //i = i ? i << 1 : 1;
    //sprintf(s,"(-%s:%d)",r32_names[b[1] & 0xfc],i);
    sprintf(s,"(-%s)",r32_names[b[1] & 0xfc]);
    return 1+1;
  case ARI_PI:
    //i = b[1] & 0x03;
    //i = i ? i << 1 : 1;
    //sprintf(s,"(%s+:%d)",r32_names[b[1] & 0xfc],i);
    sprintf(s,"(%s+)",r32_names[b[1] & 0xfc]);
    return 1+1;
  default:
    strcpy(s,"(\?\?\?)");  // Invalid..
    break;
  }
  return 0;
}

//
//
//

char **getregs( int r, int zz ) {
  if (r < 0) {
    switch (zz) {
    case 0x00:
      return r8_names;
    case 0x01:
      return r16_names;
    case 0x02:
      return r32_names;
    default:
      break;
    }
  } else {
    switch (zz) {
    case 0x00:
      return R8_names;
    case 0x01:
      return R16_names;
    case 0x02:
      return R32_names;
    default:
      break;
    }
  }
  return NULL;
}



