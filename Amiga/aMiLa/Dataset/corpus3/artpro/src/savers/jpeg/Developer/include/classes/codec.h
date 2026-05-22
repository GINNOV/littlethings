#ifndef CLASSES_CODEC_H
#define CLASSES_CODEC_H
/*
**  $VER: codec.h 0.1 (26.3.94)
**
**  Interface definitions for Tower coder/decoder objects.
**
**  Copyright © 1994 Christoph Feck, TowerSystems.
**  All Rights Reserved.
**
**  NOTE:  This file is provided "AS-IS" and subject to change without
**  prior notice; no warranties are made.  All use is at your own risk.
**  No liability or responsibility is assumed.
*/

#ifndef LIBRARIES_TOWER_H
#include <libraries/tower.h>
#endif

/*****************************************************************************/

#define CODECCLASS		"codec.class"

/*****************************************************************************/

#define CDA_Dummy		(TA_Dummy + 0x3200)

/* Common attributes */
#define CDA_Stream		(CDA_Dummy + 1)		/* [i.g] (APTR) stream.class object or DOS file handle. */
#define CDA_StreamType		(CDA_Dummy + 2)		/* [i.g] (LONG) Type of stream. */
#define CDA_Coding		(CDA_Dummy + 3)		/* [i.g] (BOOL) TRUE for coding, FALSE for decoding. */
#define CDA_TotalSize		(CDA_Dummy + 4)		/* [..g] (LONG) */
#define CDA_ChunkSize		(CDA_Dummy + 5)		/* [..g] (LONG) Size of I/O buffer */
#define CDA_Quality		(CDA_Dummy + 6)		/* [.s.] (LONG) */
#define CDA_Monitor		(CDA_Dummy + 7)		/* [isg] (Object *) Object that is called while processing. */
#define CDA_Password		(CDA_Dummy + 8)		/* [.s.] (STRPTR) */
#define CDA_Lossless		(CDA_Dummy + 9)		/* [.sg] (BOOL) */
#define CDA_ActualSize		(CDA_Dummy + 10)	/* [..g] (LONG) */
#define CDA_ErrorCode		(CDA_Dummy + 11)	/* [..g] (LONG) */
#define CDA_ErrorString		(CDA_Dummy + 12)	/* [..g] (STRPTR) */
#define CDA_BitsPerSample	(CDA_Dummy + 13)	/* [.sg] (LONG) Defaults to 8 bits. */

/*****************************************************************************/

/* Stream types. */
#define CDST_OBJECT		0
#define CDST_reserved		1	/* Do not use */
#define CDST_FILE		2

/*****************************************************************************/

#define CDM_Dummy		(TM_Dummy + 0x3200)

#define CDM_START		(CDM_Dummy + 1)
#define CDM_PROCESS		(CDM_Dummy + 2)
#define CDM_FINISH		(CDM_Dummy + 3)
#define CDM_ABORT		(CDM_Dummy + 4)
#define CDM_READHEADER		(CDM_Dummy + 6)
#define CDM_WRITEHEADER		(CDM_Dummy + 7)

/* Additional monitor methods */
#define CDM_STATUS		(CDM_Dummy + 13)
#define CDM_ERROR		(CDM_Dummy + 14)
#define CDM_COMMENT		(CDM_Dummy + 15)

/* Internal methods used by codec subclasses */
#define CDM_READ		(CDM_Dummy + 24)
#define CDM_WRITE		(CDM_Dummy + 25)
#define CDM_SEEK		(CDM_Dummy + 26)
#define CDM_SYNC		(CDM_Dummy + 27)
#define CDM_CODE		(CDM_Dummy + 30)
#define CDM_DECODE		(CDM_Dummy + 31)

/*****************************************************************************/

/* Return codes from CDM_READHEADER */
#define HEADER_ERROR		0
#define HEADER_READY		1
#define HEADER_EMPTY		2
#define HEADER_SUSPENDED	3
#define HEADER_PROTECTED	4

/*****************************************************************************/

struct cdProcess
{
    ULONG		 MethodID;
    UBYTE		*cdp_Buffer;		/* Pointer to samples */
    LONG		 cdp_BufferSize;	/* Number of samples */
};

struct cdAccess
{
    ULONG		 MethodID;
    APTR		*cda_BufferPtr;
    LONG		 cda_MaxSize;
};

struct cdSeek
{
    ULONG		 MethodID;
    LONG		 cds_Position;
    ULONG		 cds_Offset;
};

/*****************************************************************************/

#endif /* CLASSES_CODEC_H */
