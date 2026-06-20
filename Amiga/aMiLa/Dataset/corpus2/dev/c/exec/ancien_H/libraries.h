/* libraries.h - exec library function prototypes */

/*
**	Copyright (C) 1986, by MTS Associates, Jacksonville FL
**	All rights reserved.  Duplication of this data by other than
**	licensed users is a violation of copyright law.
**
**	Function prototypes for the exec.library of Amiga EXEC
**
**	Updated: 11/17/86, TFH
*/

#ifndef EXEC_LIBRARIES_H
#define EXEC_LIBRARIES_H

#ifndef EXEC_NODES_H
#include <exec/nodes.h>
#endif !EXEC_NODES_H


#define LIB_VECTSIZE    6
#define LIB_RESERVED    4
#define LIB_BASE    	(-LIB_VECTSIZE)
#define LIB_USERDEF     (LIB_BASE-(LIB_RESERVED*LIB_VECTSIZE))
#define LIB_NONSTD	(LIB_USERDEF)

#define LIB_OPEN	(-6)
#define LIB_CLOSE	(-12)
#define LIB_EXPUNGE	(-18)
#define LIB_EXTFUNC	(-24)


class Library : public Node {
    UBYTE   lib_Flags;
    UBYTE   lib_pad;
    UWORD   lib_NegSize;	    /* number of bytes before library */
    UWORD   lib_PosSize;	    /* number of bytes after library */
    UWORD   lib_Version;
    UWORD   lib_Revision;
    APTR    lib_IdString;		// should be TEXT *
    ULONG   lib_Sum;		    /* the checksum itself */
    UWORD   lib_OpenCnt;	    /* number of current opens */

    friend void AddLibrary(const Library *l);
    friend void CloseLibrary(const Library *l);
    friend Library * MakeLibrary(const APTR function_addresses,
	const APTR initStruct,	/* Init* */
	const APTR libInit,	/* Address of Init routine */
	const int datasize,
	const int codesize);
    friend Library * OldOpenLibrary(const TEXT * libname,
		const int version = 0);
    friend Library * OpenLibrary(const TEXT * libname, const int version);
    friend int RemLibrary(Library *l);
    friend APTR SetFunction(Library *l, const int functionnum, APTR routine);
    friend void SumLibrary(Library *l);
};

#define LIBF_SUMMING	(1<<0)	    /* we are currently checksumming */
#define LIBF_CHANGED	(1<<1)	    /* we have just changed the lib */
#define LIBF_SUMUSED	(1<<2)	    /* set if we should bother to sum */
#define LIBF_DELEXP	(1<<3)	    /* delayed expunge */

/* Temporary Compatibility */
#define lh_Node		lib_Node
#define lh_Flags	lib_Flags
#define lh_pad		lib_pad
#define lh_NegSize	lib_NegSize
#define lh_PosSize	lib_PosSize
#define lh_Version	lib_Version
#define lh_Revision	lib_Revision
#define lh_IdString	lib_IdString
#define lh_Sum		lib_Sum
#define lh_OpenCnt	lib_OpenCnt

#endif
