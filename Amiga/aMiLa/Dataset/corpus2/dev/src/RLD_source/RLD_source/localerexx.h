/*
  $Id: localerexx.h,v 1.2 1997/10/21 22:35:08 wegge Stab wegge $

  $Log: localerexx.h,v $
  Revision 1.2  1997/10/21 22:35:08  wegge
  Snapshot inden upload af 2.13 i source og binær form

  Revision 1.1  1997/10/21 03:49:58  wegge
  Initial revision

 */

#if !defined(LOCALEREXX_H)
#define LOCALEREXX_H

#define MISC_STR_ALLOC 1024L

struct StringHookData
  {
    UBYTE *Buffer;		/* Pointer to beginning of the buffer area */
    ULONG BufLen;		/* Total allocated buffer size */
    ULONG BufPos;		/* Next Read/Write position */
  };

#endif /* LOCALEREXX_H */
