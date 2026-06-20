/* Copyright (c) 1986, Greg McGary */
/* @(#)bitops.h	1.1 86/10/09 */

#define	BITTST(ba, bn)	((ba)[(bn) >> 3] &  (1 << ((bn) & 0x07)))
#define	BITSET(ba, bn)	((ba)[(bn) >> 3] |= (1 << ((bn) & 0x07)))
#define	BITCLR(ba, bn)	((ba)[(bn) >> 3] &=~(1 << ((bn) & 0x07)))
#define	BITAND(ba, bn)	((ba)[(bn) >> 3] &= (1 << ((bn) & 0x07)))
#define	BITXOR(ba, bn)	((ba)[(bn) >> 3] ^= (1 << ((bn) & 0x07)))

extern char *bitsand();
extern char *bitsclr();
extern char *bitsset();
extern char *bitsxor();
extern int bitsany();
extern int bitstst();
