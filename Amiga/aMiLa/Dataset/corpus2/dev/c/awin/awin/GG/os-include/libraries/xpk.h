/*
**	$Filename: xpk.h $
**	$Release: 0.9 $
**
**
**
**	(C) Copyright 1991 U. Dominik Mueller, Bryan Ford, Christian Schneider
**	    All Rights Reserved
*/

#ifndef LIBRARIES_XPK_H
#define LIBRARIES_XPK_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef EXEC_NODES_H
#include <exec/nodes.h>
#endif

#if INCLUDE_VERSION >= 36

#ifndef UTILITY_TAGITEM_H
#include <utility/tagitem.h>
#endif

#ifndef UTILITY_HOOKS_H
#include <utility/hooks.h>
#endif

#else

typedef ULONG	Tag; /* Extracted (without permission) from utility/tagitem.h */
struct TagItem	{
    Tag		ti_Tag;
    ULONG	ti_Data;
};

#define TAG_DONE   (0L)     /* terminates array of TagItems. ti_Data unused */
#define TAG_IGNORE (1L)     /* ignore this item, not end of array           */
#define TAG_USER   (1L<<31) /* differentiates user tags from system tags    */

struct Hook	{               /* Likewise, but from utility/hooks.h */
    struct MinNode	h_MinNode;
    ULONG		(*h_Entry)();	/* assembler entry point	*/
    ULONG		(*h_SubEntry)();/* often HLL entry point	*/
    VOID		*h_Data;	/* owner specific		*/
};

#endif

typedef struct TagItem  TAGS;
typedef struct Hook *   HOOK;

#define XPKNAME "xpkmaster.library"

/*****************************************************************************
 *
 *
 *      The packing/unpacking tags
 *
 */

#define XPK_TagBase	(TAG_USER + 'X'*256 + 'P')
#define XTAG(a) (XPK_TagBase+a)

/* Caller must supply ONE of these to tell Xpk#?ackFile where to get data from */
#define XPK_InName	  XTAG(0x01)	/* Process an entire named file */
#define XPK_InFH	  XTAG(0x02)	/* File handle - start from current position */
					/* If packing partial file, must also supply InLen */
#define XPK_InBuf	  XTAG(0x03)	/* Single unblocked memory buffer */
					/* Must also supply InLen */
#define XPK_InHook	  XTAG(0x04)	/* Call custom Hook to read data */
					/* If packing, must also supply InLen */
					/* If unpacking, InLen required only for PPDecrunch */

/* Caller must supply ONE of these to tell Xpk#?ackFile where to send data to */
#define XPK_OutName	  XTAG(0x10)	/* Write (or overwrite) this data file */
#define XPK_OutFH	  XTAG(0x11)	/* File handle - write from current position on */
#define XPK_OutBuf	  XTAG(0x12)	/* Unblocked buffer - must also supply OutBufLen */
#define XPK_GetOutBuf	  XTAG(0x13)	/* Master allocates OutBuf - ti_Data points to buf ptr */
#define XPK_OutHook	  XTAG(0x14)	/* Callback Hook to get output buffers */

/* Other tags for Pack/Unpack */
#define XPK_InLen	  XTAG(0x20)	/* Length of data in input buffer  */
#define XPK_OutBufLen	  XTAG(0x21)	/* Length of output buffer         */
#define XPK_GetOutLen	  XTAG(0x22)	/* ti_Data points to long to receive OutLen    */
#define XPK_GetOutBufLen  XTAG(0x23)	/* ti_Data points to long to receive OutBufLen */
#define XPK_Password	  XTAG(0x24)	/* Password for de/encoding        */
#define XPK_GetError	  XTAG(0x25)	/* ti_Data points to buffer for error message  */
#define XPK_OutMemType	  XTAG(0x26)	/* Memory type for output buffer   */
#define XPK_PassThru	  XTAG(0x27)	/* Bool: Pass through unrecognized formats on unpack */
#define XPK_StepDown	  XTAG(0x28)	/* Bool: Step down pack method if necessary    */
#define XPK_ChunkHook	  XTAG(0x29)	/* Call this Hook between chunks   */
#define XPK_PackMethod	  XTAG(0x2a)	/* Do a FindMethod before packing  */
#define XPK_ChunkSize	  XTAG(0x2b)	/* Chunk size to try to pack with  */
#define XPK_PackMode	  XTAG(0x2c)	/* Packing mode for sublib to use  */
#define XPK_NoClobber	  XTAG(0x2d)	/* Don't overwrite existing files  */
#define XPK_Ignore	  XTAG(0x2e)	/* Skip this tag                   */
#define XPK_TaskPri	  XTAG(0x2f)	/* Change priority for (un)packing */
#define XPK_FileName	  XTAG(0x30)	/* File name for progress report   */
#define XPK_ShortError	  XTAG(0x31)	/* Output short error messages     */
#define XPK_PackersQuery  XTAG(0x32)	/* Query available packers         */
#define XPK_PackerQuery	  XTAG(0x33)	/* Query properties of a packer    */
#define XPK_ModeQuery	  XTAG(0x34)	/* Query properties of packmode    */
#define XPK_LossyOK		  XTAG(0x35)	/* Lossy packing permitted? def.=no*/


#define XPK_FindMethod XPK_PackMethod	/* Compatibility */

#define XPK_MARGIN	256	/* Safety margin for output buffer	*/




/*****************************************************************************
 *
 *
 *     The hook function interface
 *
 */

/* Message passed to InHook and OutHook as the ParamPacket */
typedef struct XpkIOMsg {
	ULONG Type		; /* Read/Write/Alloc/Free/Abort	*/
	APTR  Ptr		; /* The mem area to read from/write to */
	LONG  Size		; /* The size of the read/write		*/
	LONG  IOError		; /* The IoErr() that occurred		*/
	LONG  Reserved		; /* Reserved for future use		*/
	LONG  Private1		; /* Hook specific, will be set to 0 by */
	LONG  Private2		; /* master library before first use	*/
	LONG  Private3		;
	LONG  Private4		;
} XIOMSG;

/* The values for XpkIoMsg->Type */
#define XIO_READ    1
#define XIO_WRITE   2
#define XIO_FREE    3
#define XIO_ABORT   4
#define XIO_GETBUF  5
#define XIO_SEEK    6
#define XIO_TOTSIZE 7





/*****************************************************************************
 *
 *
 *      The progress report interface
 *
 */

/* Passed to ChunkHook as the ParamPacket */
typedef struct XpkProgress {
	LONG	Type		; /* Type of report: start/cont/end/abort	*/
	STRPTR	PackerName	; /* Brief name of packer being used 		*/
	STRPTR	PackerLongName	; /* Descriptive name of packer being used 	*/
	STRPTR	Activity	; /* Packing/unpacking message			*/
	STRPTR	FileName	; /* Name of file being processed, if available */
	LONG	CCur		; /* Amount of packed data already processed	*/
	LONG	UCur		; /* Amount of unpacked data already processed 	*/
	LONG	ULen		; /* Amount of unpacked data in file		*/
	LONG	CF		; /* Compression factor so far			*/
	LONG	Done		; /* Percentage done already			*/
	LONG	Speed		; /* Bytes per second, from beginning of stream */
	LONG	Reserved[8]	; /* For future use				*/
} XPROG;
#define XPKPROG_START	1
#define XPKPROG_MID	2
#define XPKPROG_END	3





/*****************************************************************************
 *
 *
 *       The file info block
 *
 */
struct XpkFib {
	LONG	Type		; /* Unpacked, packed, archive?   */
	LONG	ULen		; /* Uncompressed length          */
	LONG	CLen		; /* Compressed length            */
	LONG	NLen		; /* Next chunk len               */
	LONG	UCur		; /* Uncompressed bytes so far    */
	LONG	CCur		; /* Compressed bytes so far      */
	LONG	ID		; /* 4 letter ID of packer        */
	UBYTE	Packer[6]	; /* 4 letter name of packer      */
	WORD	SubVersion	; /* Required sublib version      */
	WORD	MasVersion	; /* Required masterlib version   */
	LONG	Flags		; /* Password?                    */
	UBYTE	Head[16]	; /* First 16 bytes of orig. file */
	LONG	Ratio		; /* Compression ratio            */
	LONG	Reserved[8]	; /* For future use               */
};
typedef struct XpkFib XFIB;

#define XPKTYPE_UNPACKED 0        /* Not packed                   */
#define XPKTYPE_PACKED   1        /* Packed file                  */
#define XPKTYPE_ARCHIVE  2        /* Archive                      */

#define XPKFLAGS_PASSWORD 1       /* Password needed              */
#define XPKFLAGS_NOSEEK   2       /* Chunks are dependent         */
#define XPKFLAGS_NONSTD   4       /* Nonstandard file format      */





/*****************************************************************************
 *
 *
 *       The error messages
 *
 */

#define XPKERR_OK	  0
#define XPKERR_NOFUNC	   -1	/* This function not implemented	*/
#define XPKERR_NOFILES	   -2	/* No files allowed for this function	*/
#define XPKERR_IOERRIN	   -3	/* Input error happened, look at Result2*/
#define XPKERR_IOERROUT	   -4	/* Output error happened,look at Result2*/
#define XPKERR_CHECKSUM	   -5	/* Check sum test failed		*/
#define XPKERR_VERSION	   -6	/* Packed file's version newer than lib */
#define XPKERR_NOMEM	   -7	/* Out of memory			*/
#define XPKERR_LIBINUSE	   -8	/* For not-reentrant libraries		*/
#define XPKERR_WRONGFORM   -9	/* Was not packed with this library	*/
#define XPKERR_SMALLBUF	   -10	/* Output buffer too small		*/
#define XPKERR_LARGEBUF	   -11	/* Input buffer too large		*/
#define XPKERR_WRONGMODE   -12	/* This packing mode not supported	*/
#define XPKERR_NEEDPASSWD  -13	/* Password needed for decoding		*/
#define XPKERR_CORRUPTPKD  -14	/* Packed file is corrupt		*/
#define XPKERR_MISSINGLIB  -15	/* Required library is missing		*/
#define XPKERR_BADPARAMS   -16	/* Caller's TagList was screwed up	*/
#define XPKERR_EXPANSION   -17	/* Would have caused data expansion	*/
#define XPKERR_NOMETHOD    -18	/* Can't find requested method		*/
#define XPKERR_ABORTED     -19	/* Operation aborted by user		*/
#define XPKERR_TRUNCATED   -20	/* Input file is truncated		*/
#define XPKERR_WRONGCPU    -21	/* Better CPU required for this library	*/
#define XPKERR_PACKED      -22	/* Data are already XPacked		*/
#define XPKERR_NOTPACKED   -23	/* Data not packed			*/
#define XPKERR_FILEEXISTS  -24	/* File already exists			*/
#define XPKERR_OLDMASTLIB  -25	/* Master library too old		*/
#define XPKERR_OLDSUBLIB   -26	/* Sub library too old			*/
#define XPKERR_NOCRYPT     -27	/* Cannot encrypt			*/
#define XPKERR_NOINFO      -28	/* Can't get info on that packer	*/
#define XPKERR_LOSSY       -29	/* This compression method is lossy	*/
#define XPKERR_NOHARDWARE  -30	/* Compression hardware required	*/
#define XPKERR_BADHARDWARE -31	/* Compression hardware failed		*/
#define XPKERR_WRONGPW     -32	/* Password was wrong			*/

#define XPKERRMSGSIZE	80	/* Maximum size of an error message	*/





/*****************************************************************************
 *
 *
 *     The XpkQuery() call
 *
 */

typedef struct XpkPackerInfo {
	BYTE    Name[24]        ; /* Brief name of the packer          */
	BYTE    LongName[32]    ; /* Full name of the packer           */
	BYTE    Description[80] ; /* One line description of packer    */
	LONG    Flags           ; /* Defined below                     */
	LONG    MaxChunk        ; /* Max input chunk size for packing  */
	LONG    DefChunk        ; /* Default packing chunk size        */
	UWORD   DefMode         ; /* Default mode on 0..100 scale      */
} XPINFO;

/* Defines for Flags */
#define XPKIF_PK_CHUNK    0x00000001 /* Library supplies chunk packing       */
#define XPKIF_PK_STREAM   0x00000002 /* Library supplies stream packing      */
#define XPKIF_PK_ARCHIVE  0x00000004 /* Library supplies archive packing     */
#define XPKIF_UP_CHUNK    0x00000008 /* Library supplies chunk unpacking     */
#define XPKIF_UP_STREAM   0x00000010 /* Library supplies stream unpacking    */
#define XPKIF_UP_ARCHIVE  0x00000020 /* Library supplies archive unpacking   */
#define XPKIF_HOOKIO      0x00000080 /* Uses full Hook I/O                   */
#define XPKIF_CHECKING    0x00000400 /* Does its own data checking           */
#define XPKIF_PREREADHDR  0x00000800 /* Unpacker pre-reads the next chunkhdr */
#define XPKIF_ENCRYPTION  0x00002000 /* Sub library supports encryption      */
#define XPKIF_NEEDPASSWD  0x00004000 /* Sub library requires encryption      */
#define XPKIF_MODES       0x00008000 /* Sub library has different modes      */
#define XPKIF_LOSSY       0x00010000 /* Sub library does lossy compression   */


typedef struct XpkMode {
	struct XpkMode *Next   ; /* Chain to next descriptor for ModeDesc list*/
	ULONG   Upto           ; /* Maximum efficiency handled by this mode   */
	ULONG   Flags          ; /* Defined below                             */
	ULONG   PackMemory     ; /* Extra memory required during packing      */
	ULONG   UnpackMemory   ; /* Extra memory during unpacking             */
	ULONG   PackSpeed      ; /* Approx packing speed in K per second      */
	ULONG   UnpackSpeed    ; /* Approx unpacking speed in K per second    */
	UWORD   Ratio          ; /* CF in 0.1% for AmigaVision executable     */
	UWORD   ChunkSize      ; /* Desired chunk size in K (!!) for this mode*/
	BYTE    Description[10]; /* 7 character mode description              */
} XMINFO;

/* Defines for XpkMode.Flags */
#define XPKMF_A3000SPEED 0x00000001	/* Timings on A3000/25               */
#define XPKMF_PK_NOCPU   0x00000002	/* Packing not heavily CPU dependent */
#define XPKMF_UP_NOCPU   0x00000004	/* Unpacking... (i.e. hardware modes)*/

#define MAXPACKERS 100

typedef struct XpkPackerList {
	ULONG	NumPackers;
	BYTE	Packer[MAXPACKERS][6];
} XPLIST;



/*****************************************************************************
 *
 *
 *     The XpkOpen() type calls
 *
 */

#define XPKLEN_ONECHUNK 0x7fffffff
#define XpkFH XpkFib
typedef struct XpkFib XFH;


/*****************************************************************************
 *
 *
 *      The library vectors
 *
 */

#define REG  register
#define _a0  register __a0
#define _a1  register __a1
#define _a2  register __a2
#define _a4  register __a4
#define _d0  register __d0
#define _d1  register __d1

#ifndef NO_XPK_PROTOS

LONG XpkExamine      ( XFIB *fib, TAGS *tags);
LONG XpkPack         ( TAGS *tags );
LONG XpkUnpack       ( TAGS *tags );
LONG XpkOpen         ( XFH **xfh, TAGS  *tags );
LONG XpkRead         ( XFH  *xfh, UBYTE *buf, LONG len  );
LONG XpkWrite        ( XFH  *xfh, UBYTE *buf, LONG ulen );
LONG XpkSeek         ( XFH  *xfh, LONG  dist, LONG mode );
LONG XpkClose        ( XFH  *xfh  );
LONG XpkQuery        ( TAGS *tags );
LONG XpkExamineTags  ( XFIB *fib, ULONG, ... );
LONG XpkPackTags     ( ULONG, ... );
LONG XpkUnpackTags   ( ULONG, ... );
LONG XpkQueryTags    ( ULONG, ... );
LONG XpkOpenTags     ( XFH **xfh, ULONG, ... );

#ifndef NO_XPK_PRAGMAS
#ifdef LATTICE
# pragma libcall XpkBase XpkExamine 24  9802
# pragma libcall XpkBase XpkPack    2A   801
# pragma libcall XpkBase XpkUnpack  30   801
# pragma libcall XpkBase XpkOpen    36  9802
# pragma libcall XpkBase XpkRead    3C 09803
# pragma libcall XpkBase XpkWrite   42 09803
# pragma libcall XpkBase XpkSeek    48 10803
# pragma libcall XpkBase XpkClose   4E   801
# pragma libcall XpkBase XpkQuery   54   801
#endif

#ifdef AZTEC_C
# pragma amicall(XpkBase, 0x24, XpkExamine(a0,a1))
# pragma amicall(XpkBase, 0x2a, XpkPack(a0))
# pragma amicall(XpkBase, 0x30, XpkUnpack(a0))
# pragma amicall(XpkBase, 0x36, XpkOpen(a0,a1))
# pragma amicall(XpkBase, 0x3c, XpkRead(a0,a1,d0))
# pragma amicall(XpkBase, 0x42, XpkWrite(a0,a1,d0))
# pragma amicall(XpkBase, 0x48, XpkSeek(a0,d0,d1))
# pragma amicall(XpkBase, 0x4e, XpkClose(a0))
# pragma amicall(XpkBase, 0x54, XpkQuery(a0))
#endif

#endif
#endif

#endif /* LIBRARIES_XPK_H */
