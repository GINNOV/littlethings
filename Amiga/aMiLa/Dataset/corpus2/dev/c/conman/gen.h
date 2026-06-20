#ifndef SIMPLE_GEN_H
#define SIMPLE_GEN_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

//types:
typedef unsigned long  ulong;
typedef short word;
typedef unsigned short uword;
typedef unsigned char  ubyte;
typedef long bool;

//macros:

#define errputs(str) fprintf(stderr,"%s\n",str)

#define sizeofpointer sizeof(void *)

#define SmartFree(a,b) if(a) FreeMem(a,b); a = NULL

#define Malloc(a,b,c) (a = AllocMem(((((b)-1)/4 + 1)*4),c)) == NULL
//Malloc(variable,size,flags)
#define MemCpy(a,b,c) CopyMemQuick(b,a,((((c)-1)/4 + 1)*4))
//MemCpy(to,from,size)
// both macros automatically pad

#define DoublePaddedSize(a) ((((a)-1)/8 + 1)*8)
//doublepaddedsize(originalsize)
#define PaddedSize(a) ((((a)-1)/4 + 1)*4)
//paddedsize(originalsize)
#define WordPaddedSize(a) ((((a)-1)/2 + 1)*2)
//wordpaddedsize(originalsize)

#define IsOdd(a) ( ((a)/2)*2 != (a) )
#define SignOf(a) (((a) < 0) ? -1 : 1)

#define Rewind(a) Seek(a,0,OFFSET_BEGINNING)
#define Tell(a) (ulong)Seek(a,0,OFFSET_CURRENT)

#define STRINGLEN 256

#ifndef max
#define max(a,b) ((a)>(b)?(a):(b))
#endif

#ifndef min
#define min(a,b) ((a)<(b)?(a):(b))
#endif


/*
 *  MemClearMacro
 *
 * fast MemClear , works on non-long-aligned blocks
 *	if MemPtr is not long-aligned, this method is very slow
 *		faster would be to clear bytes until you have long-alignment
 *		and subsequently clear longs
 *	this would also be RISC-compatible
 *
 */
#define MemClearMacro(MemPtr,MemLen)                                       \
  {                                                                        \
 	register ulong *CurMemPtr,*MemDone;                                      \
 	long MyMemLen;                                                           \
	MyMemLen = MemLen;                                                       \
 	CurMemPtr = (ulong *)MemPtr;                                             \
 	MemDone = CurMemPtr + (MyMemLen>>2);                                     \
 	do *CurMemPtr++ = 0; while(CurMemPtr < MemDone);                         \
 	switch(MyMemLen&0x3)                                                     \
		{                                                                      \
		case 0:                                                                \
			break;                                                               \
		case 1:                                                                \
			*((ubyte *)CurMemPtr) = 0;                                           \
			break;                                                               \
		case 2:                                                                \
			*((ubyte *)CurMemPtr) = 0;                                           \
			*((ubyte *)CurMemPtr+1) = 0;                                         \
			break;                                                               \
		case 3:                                                                \
			*((ubyte *)CurMemPtr) = 0;                                           \
			*((ubyte *)CurMemPtr+1) = 0;                                         \
			*((ubyte *)CurMemPtr+2) = 0;                                         \
			break;                                                               \
		}                                                                      \
  }                                                                        \
/* end MemClearMacro */


/*
 *  MemClearMacroFast
 *
 * fastest MemClear, doesnt work on non-long-aligned data
 *
 *	memlen passed in must be the number of 4-byte hunks,
 *		NOT the length in bytes
 *
 *	memlen MUST BE GREATER THAN 0 !!!!
 *	
 */
#define MemClearMacroFast(MemPtr,MemLen_NumLongs)                          \
  {                                                                        \
 	register ulong *CurMemPtr,counter;                                       \
 	CurMemPtr = (ulong *)MemPtr;                                             \
	counter = (ulong) MemLen_NumLongs;                                       \
 	do *CurMemPtr++ = 0; while( (--counter) != 0 );                          \
  }                                                                        \
/* end MemClearMacroFast */

#endif //SIMPLE_GEN_H
