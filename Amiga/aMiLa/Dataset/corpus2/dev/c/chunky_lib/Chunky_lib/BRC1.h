/*
 * BRC1 library
 * Byte Run Compression (type 1) system
 * Originally based on various BRC sources and extra functions added by
 * Andrew "Oondy" King.
 *
 * (c) 1998 Rosande Limited, all rights reserved
 */

#ifndef BRC1_HEAD
#define BRC1_HEAD

#define HEAD_BRC1 0x42524331

// Application header
struct BRC1Header
{
  unsigned long br_Identification; // == HEAD_BRC1
  unsigned long br_UnpackedSize;
  unsigned long br_PackedSize;
  void *br_Buffer;
  // Packed data follows in file
};

#define DUMP	0
#define RUN	1

#define MINRUN 3	
#define MAXRUN 128
#define MAXDAT 128

#define PutByte(c)    {*Destination++ = (c); ++PutSize;}
#define UPutByte(c)   (*dest++ = (c))
#define OutDump(nn)   dest = BRCPutDump(dest, nn)
#define OutRun(nn,cc) dest = BRCPutRun(dest, nn, cc)

//------------------------------------------------------- Prototypes
void BRC_FreeBuffer(struct BRC1Header *Buffer);
struct BRC1Header *BRC_Compress(void *Buffer, unsigned long BufferSize);
void *BRC_Uncompress(struct BRC1Header *Buffer);

#endif

