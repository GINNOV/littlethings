#include <crbinc/inc.h>


/*protos:*/

struct BitIOInfo * BitIO_Init(ubyte *Array);
void BitIO_CleanUp(struct BitIOInfo * BII);
long BitIO_FlushWrite(struct BitIOInfo * BII); /*returns length of data*/
void BitIO_ResetArray(struct BitIOInfo * BII,ubyte *Array);             

const int ReadBitMask = 0x80;

struct BitIOInfo
  {
  ubyte *BitArray;
  ubyte *BitArrayPtr;
  int BitBuffer;
  int BitsToGo;
  };

void BitIO_ResetArray(struct BitIOInfo * BII,ubyte *Array)
{
BII->BitBuffer = 0;
BII->BitsToGo = 8;

BII->BitArrayPtr = BII->BitArray = Array;
}

/*
 *  Allocate and init a BII
 *  for reads, BitIO_InitRead must also be called
 *
 */
struct BitIOInfo * BitIO_Init(ubyte *Array)
{
struct BitIOInfo * BII;

if ( (BII = malloc(sizeof(struct BitIOInfo))) == NULL )
  return(NULL);

BitIO_ResetArray(BII,Array);

return(BII);
}

/*
 *  Free a BII after it has been written or read from
 *  call BitIO_FlushWrite before writing to a file
 *
 */
void BitIO_CleanUp(struct BitIOInfo * BII)
{
free(BII);
}

/*
 *  FlushWrite sticks remaining bits into BitArray
 *  must be called before writing BitArray
 *  returns length of array to write
 *
 */
long BitIO_FlushWrite(struct BitIOInfo * BII)
{

if ( BII->BitsToGo < 8 )
  {
  BII->BitBuffer <<= BII->BitsToGo;
  *BII->BitArrayPtr++ = BII->BitBuffer;

  BII->BitsToGo = 8;
  BII->BitBuffer = 0;
  /* keep going, if you like */
  }

return( BII->BitArrayPtr - BII->BitArray );
}
