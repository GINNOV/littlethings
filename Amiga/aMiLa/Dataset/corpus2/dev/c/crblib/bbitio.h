/*
 *
 * Totally changed 6-12-95
 *
 * we now properly write bits left->right
 * 
 * all previous programs must be modified to be accomodate this
 *
 * new 6-13 : after FlushWrite, you must read the return value of FlushWrite
 *
 */

#ifndef BIT_IO_H
#define BIT_IO_H

#include <crbinc/inc.h>

struct BitIOInfo
  {
  ubyte *BitArray;
  ubyte *BitArrayPtr;
  int BitBuffer;
  int BitsToGo;
  };

/*externs in BitIO.c :*/

extern struct BitIOInfo * BitIO_Init(ubyte *Array);
extern void BitIO_CleanUp(struct BitIOInfo * BII);
extern long BitIO_FlushWrite(struct BitIOInfo * BII); /*returns length of data*/
extern void BitIO_ResetArray(struct BitIOInfo * BII,ubyte *Array);

/*macros:*/

/*

BII = (struct BitIOInfo * BII)

void BitIO_WriteBit(BII,ubyte Bit);
void BitIO_WriteZeroBit(BII);
void BitIO_InitRead(BII);
void BitIO_ReadBit(BII,bool Bit); / /fills out Bit

*/


/*
 *  Write a Bit to the BII - Bit may be True or False (need not be 0 or 1)
 *  params: struct BitIOInfo * BII,ubyte Bit
 *
 */
#define BitIO_WriteBit(BII,Bit)                   \
{                                                 \
BII->BitBuffer += BII->BitBuffer + Bit;           \
BII->BitsToGo--;                                  \
if ( ! BII->BitsToGo )                            \
  {                                               \
  *(BII->BitArrayPtr)++ = BII->BitBuffer;         \
  BII->BitsToGo = 8;                              \
  BII->BitBuffer = 0;                             \
  }                                               \
}                                                 \
/* End BitIO_WriteBit */

#define BitIO_WriteZeroBit(BII)                   \
{                                                 \
BII->BitBuffer += BII->BitBuffer;                 \
BII->BitsToGo--;                                  \
if ( ! BII->BitsToGo )                            \
  {                                               \
  *(BII->BitArrayPtr)++ = BII->BitBuffer;         \
  BII->BitsToGo = 8;                              \
  BII->BitBuffer = 0;                             \
  }                                               \
}                                                 \
/* End BitIO_WriteZeroBit */

/*
 *  Reads bits into BitBuffer from BitArray
 *  must be done before any _Read commands
 *
 */
#define BitIO_InitRead(BII)                                                \
BII->BitBuffer = *BII->BitArrayPtr++;                                      \
/* End BitIO_InitRead */

extern const int ReadBitMask;

/*
 *  Read a bit from BII into (bool Bit)
 *
 */
#define BitIO_ReadBit(BII,Bit)                    \
{                                                 \
if ( BII->BitBuffer & ReadBitMask )               \
  Bit = 1;                                        \
else                                              \
  Bit = 0;                                        \
BII->BitBuffer += BII->BitBuffer;                 \
BII->BitsToGo --;                                 \
if ( BII->BitsToGo == 0 )                         \
  {                                               \
  BII->BitBuffer = *(BII->BitArrayPtr)++;         \
  BII->BitsToGo = 8;                              \
  }                                               \
}                                                 \
/* End BitIO_ReadBit */

#endif /* BIT_IO_H*/
