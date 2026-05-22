#ifndef MY_ALIB_PROTOS_H
#define MY_ALIB_PROTOS_H
extern __stdargs APTR LibAllocPooled(APTR poolHeader, unsigned long memSize);
extern __stdargs APTR LibCreatePool(unsigned long memFlags, unsigned long puddleSize,
			      unsigned long threshSize);
extern __stdargs void LibDeletePool(APTR poolHeader);
extern __stdargs void LibFreePooled(APTR poolHeader, APTR memory, unsigned long memSize);
#endif
