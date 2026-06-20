/*
  $Id: rxslibinlines.h,v 1.2 1997/10/21 22:35:08 wegge Stab wegge $

  $Log: rxslibinlines.h,v $
  Revision 1.2  1997/10/21 22:35:08  wegge
  Snapshot inden upload af 2.13 i source og binær form

  Revision 1.1  1997/10/21 03:49:58  wegge
  Initial revision

 */

#if !defined(RXSLIBINLINES_H)
#define RXSLIBINLINES_H

#ifndef _CDEFS_H_
#include <sys/cdefs.h>
#endif

#ifndef __INLINE_STUB_H
#include <inline/stubs.h>
#endif

#ifndef REXXSYSLIB_BASE_NAME
#define REXXSYSLIB_BASE_NAME RexxSysBase
#endif

/*
 * 
 * Strlen()-find the length of a null-terminated string
 * Usage:length=Strlen(string)
 * D0            A0
 * (CCR)
 * 
 * Returns the number of characters in a null-terminated string. Register A0 is
 * preserved,and the CCR is set for the returned length.
 * 
 */

extern __inline ULONG Strlen(UBYTE * Buffer);

extern __inline
ULONG Strlen(UBYTE * Buffer)
{
  register ULONG Length __asm("d0");

  register UBYTE *a0 __asm("a0") = Buffer;

  register struct RxsLib *a6 __asm("a6") = REXXSYSLIB_BASE_NAME;

  __asm __volatile("jsr a6@(-0x120:W)"
		   :"=r"(Length)
		   :"r"(a6), "r"(a0)
		   :"d0", "d1", "a0", "a1", "cc", "memory");

  return Length;
}

/*
 * 
 * CVa2i()-convert from ASCII to integer
 * Usage: (digits,value) = CVa2i(buffer)
 * D1     D0             A0
 * 
 * Converts the buffer of ASCII characters to a signed long integer value. The
 * scan proceeds until a non-digit character is found or until an overflow is
 * detected. The function returns both the number of digits scanned and the
 * converted value.
 * 
 */

struct CVa2i_ret
{
  ULONG Digits;
  ULONG Value;
};

extern __inline void CVa2i(struct CVa2i_ret *RV, UBYTE * Buffer);

extern __inline void
CVa2i(struct CVa2i_ret *RV, UBYTE * Buffer)
{
  register ULONG d0 __asm("d0");
  register ULONG d1 __asm("d1");

  register UBYTE *a0 __asm("a0") = Buffer;

  register struct RxsLib *a6 __asm("a6") = REXXSYSLIB_BASE_NAME;

  __asm __volatile("jsr a6@(-0x12c:W)"
		   :"=r"(d1), "=r"(d0)
		   :"r"(a6), "r"(a0)
		   :"d0", "d1", "a0", "a1", "cc", "memory");

  RV->Value = d0;
  RV->Digits = d1;
}


/*
 * 
 * StrcmpU()-compare the values of strings
 * Usage:test=StrcmpN(string1,string2,length)
 * D0             A0      A1     D0
 * (CCR)
 * 
 * The string1 and string2 arguments are compared for the specified
 * number of characters. The comparison proceeds
 * character-by-character until a difference is found or the maximum
 * number of characters have been examined. The returned value is -1
 * if the first string was less,1 if the first string was greater,and
 * 0 if the strings match exactly. The CCR register is set for the
 * returned value.
 * 
 * ** Case insensitive **
 * 
 */

extern __inline ULONG StrcmpU(UBYTE * String1, UBYTE * String2, ULONG
			      MaxLen);

extern __inline ULONG
StrcmpU(UBYTE * String1, UBYTE * String2, ULONG MaxLen)
{
  register ULONG Compare __asm("d0");

  register UBYTE *a0 __asm("a0") = String1;
  register UBYTE *a1 __asm("a1") = String2;
  register ULONG d0 __asm("d0") = MaxLen;

  register struct RxsLib *a6 __asm("a6") = REXXSYSLIB_BASE_NAME;

  __asm __volatile("jsr a6@(-0x102:W)"
		   :"=r"(Compare)
		   :"r"(a6), "r"(a0), "r"(a1), "r"(d0)
		   :"d0", "d1", "a0", "a1", "cc", "memory");

  return Compare;
}


/*
 * 
 * StrcmpN()-compare the values of strings
 * Usage:test=StrcmpN(string1,string2,length)
 * D0             A0      A1     D0
 * (CCR)
 * 
 * The string1 and string2 arguments are compared for the specified
 * number of characters. The comparison proceeds
 * character-by-character until a difference is found or the maximum
 * number of characters have been examined. The returned value is -1
 * if the first string was less,1 if the first string was greater,and
 * 0 if the strings match exactly. The CCR register is set for the
 * returned value.
 * 
 * ** Case sensitive **
 * 
 */

extern __inline ULONG StrcmpN(UBYTE * String1, UBYTE * String2, ULONG
			      MaxLen);

extern __inline ULONG
StrcmpN(UBYTE * String1, UBYTE * String2, ULONG MaxLen)
{
  register ULONG Compare __asm("d0");

  register UBYTE *a0 __asm("a0") = String1;
  register UBYTE *a1 __asm("a1") = String2;
  register ULONG d0 __asm("d0") = MaxLen;

  register struct RxsLib *a6 __asm("a6") = REXXSYSLIB_BASE_NAME;

  __asm __volatile("jsr a6@(-0xfc:W)"
		   :"=r"(Compare)
		   :"r"(a6), "r"(a0), "r"(a1), "r"(d0)
		   :"d0", "d1", "a0", "a1", "cc", "memory");

  return Compare;
}


/*
 * CVi2arg()-convert from integer to argstring
 * Usage: argstring=CVi2arg(value,digits)
 *           D0               D0    D1
 *        A0
 *       (CCR)
 * 
 * Converts the signed long integer value argument to ASCII
 * characters,and installs them in an argstring(a RexxArg structure).
 * The returned value is an argstring pointer or 0 if the allocation
 * failed. The allocated structure can be released using
 * DeleteArgstring().
 * 
 */

extern __inline UBYTE *CVi2arg(LONG Value, ULONG Digits);

extern __inline
UBYTE *CVi2arg(LONG Value, ULONG Digits)
{
  register UBYTE *ArgString __asm("d0");

  register LONG d0 __asm("d0") = Value;
  register LONG d1 __asm("d1") = Digits;

  register struct RxsLib *a6 __asm("a6") = REXXSYSLIB_BASE_NAME;

  __asm __volatile("jsr a6@(-0x138:W)"
		   :"=r"(ArgString)
		   :"r"(a6), "r"(d0), "r"(d1)
		   :"d0", "d1", "a0", "a1", "cc", "memory");

  return ArgString;
}


/*
 * IsSymbol()-check whether a string is a valid symbol.
 * Usage:(code,length)=IsSymbol(string)
 *         D0    D1               A0
 * 
 * Scans the supplied string pointer for ARexx symbol characters. The
 * code return is the symbol type if a symbol was found,or 0 if the
 * string did not start with a symbol character. The length return is the
 * total length of the symbol.
 */

struct IsSym_ret
{
  ULONG Code;
  ULONG Length;
};

extern __inline VOID IsSymbol(struct IsSym_ret *RV, UBYTE * Buffer);

extern __inline
VOID IsSymbol(struct IsSym_ret *RV, UBYTE * Buffer)
{
  register ULONG d0 __asm("d0");
  register ULONG d1 __asm("d1");

  register UBYTE *a0 __asm("a0") = Buffer;

  register struct RxsLib *a6 __asm("a6") = REXXSYSLIB_BASE_NAME;

  __asm __volatile("jsr a6@(-0x66:W)"
		   :"=r"(d1), "=r"(d0)
		   :"r"(a6), "r"(a0)
		   :"d0", "d1", "a0", "a1", "cc", "memory");

  RV->Code = d0;
  RV->Length = d1;
}


/*
 *
 * StrcpyN()-copy a string
 * Usage:hash=StrcpyN(destination,source,length)
 *        D0              A0        A1     D0
 * 
 * Copies the source string to the destination area. The length of the
 * string (which may include embedded nulls)is considered as a 2-byte
 * unsigned integer.  The hash return is the internal hash byte for the
 * copied string.  See Also:StrcpyA(),StrcpyU
 * 
 */

extern __inline ULONG StrcpyN(UBYTE * Dest, const UBYTE * Src, USHORT
			      Length);

extern __inline
ULONG StrcpyN(UBYTE * Dest, const UBYTE * Src, USHORT Length)
{
  register ULONG Hash __asm("d0");

  register UBYTE *a0 __asm("a0") = Dest;
  register const UBYTE *a1 __asm("a1") = Src;
  register USHORT d0 __asm("d0") = Length;

  register struct RxsLib *a6 __asm("a6") = REXXSYSLIB_BASE_NAME;

  __asm __volatile("jsr a6@(-0x10e:W)"
		   :"=r"(Hash)
		   :"r"(a6), "r"(a0), "r"(a1), "r"(d0)
		   :"d0", "d1", "a0", "a1", "cc", "memory");

  return Length;
}


/*
 * AddRsrcNode()-allocate and link a resource node
 * Usage:node=AddRsrcNode(list,name,length)
 *     D0      A0   A1    D0
 *     A0
 *        (CCR)
 * 
 * Allocates and links a resource node(a RexxRsrc structure)to the
 * specified list.  The name argument is a pointer to a
 * null-terminated string,a copy of which is installed in the node
 * structure. The length argument is the total length for the
 * node;this length is saved within the node so that it may be
 * released later.
 *
 */

extern __inline  struct RexxRsrc *AddRsrcNode(struct List *Lst, UBYTE
					      *Name, ULONG Len);

extern __inline
struct RexxRsrc *AddRsrcNode(struct List *Lst, UBYTE *Name, ULONG Len)
{
  register ULONG d0 __asm("d0") = Len;

  register struct List *a0 __asm("a0") = Lst;
  register UBYTE *a1 __asm("a1") = Name;

  register struct RexxRsrc *ResNode __asm("a0");
  
  register struct RxsLib *a6 __asm("a6") = REXXSYSLIB_BASE_NAME;

  __asm __volatile("jsr a6@(-0xae:W)"
		   :"=r"(ResNode)
		   :"r"(a6), "r"(a0), "r"(d0), "r"(a1)
		   :"d0", "d1", "a0", "a1", "cc", "memory");

  return ResNode;
}


/*
 *
 * FindRsrcNode()-locate a resource node with the given name.
 * Usage:node=FindRsrcNode(list,name,type)
 *       D0                 A0   A1   D0
 *       A0
 *      (CCR)
 * 
 * Searchs the specified list for the first node of the selected type
 * with the given name. The list argument must be a pointer to a
 * properly-initialized EXEC list header. The name argument is a
 * pointer to a null-terminated string. If the type argument is 0,all
 * nodes are selected;otherwise,the supplied type must match the
 * LN_TYPE field of the node. The returned value is a pointer to the
 * node or 0 if no matching node was found.
 *
 */

extern __inline  struct RexxRsrc *FindRsrcNode(struct List *Lst, UBYTE
					       *Name, ULONG Type);

extern __inline
struct RexxRsrc *FindRsrcNode(struct List *Lst, UBYTE *Name, ULONG Type)
{
  register ULONG d0 __asm("d0") = Type;

  register struct List *a0 __asm("a0") = Lst;
  register UBYTE *a1 __asm("a1") = Name;

  register struct RexxRsrc *ResNode __asm("a0");
  
  register struct RxsLib *a6 __asm("a6") = REXXSYSLIB_BASE_NAME;

  __asm __volatile("jsr a6@(-0xb4:W)"
		   :"=r"(ResNode)
		   :"r"(a6), "r"(a0), "r"(d0), "r"(a1)
		   :"d0", "d1", "a0", "a1", "cc", "memory");

  return ResNode;
}


/*
 * 
 * RemRsrcNode()-unlink and deallocate a resource node
 * Usage:RemRsrcNode(node)
 *                    A0
 * 
 * Unlinks and releases the specified resource node,including the name
 * string if one is present. If an "auto-delete" function has been
 * specified in the node,it is called to perform any required resource
 * deallocation before the node is released.  See Also:RemRsrcList()
 * 
 */

extern __inline VOID RemRsrcNode(struct RexxRsrc *Node);

extern __inline
VOID RemRsrcNode(struct RexxRsrc *Node)
{
  register struct RexxRsrc *a0 __asm("a0") = Node;

  register struct RxsLib *a6 __asm("a6") = REXXSYSLIB_BASE_NAME;

  __asm __volatile("jsr a6@(-0xc0:W)"
		   :
		   :"r"(a6), "r"(a0)
		   :"d0", "d1", "a0", "a1", "cc", "memory");
}

#endif /* RXSLIBINLINES_H */
