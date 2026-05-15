#ifndef CODECS_JPEG_H
#define CODECS_JPEG_H
/*
**  $VER: jpeg.h 0.3 (28.6.94)
**
**  Interface definitions for Tower JPEG codec objects.
**
**  Copyright © 1994 Christoph Feck, TowerSystems.
**  All Rights Reserved.
**
**  NOTE:  This file is provided "AS-IS" and subject to change without
**  prior notice; no warranties are made.  All use is at your own risk.
**  No liability or responsibility is assumed.
*/

#ifndef CODECS_PICTURE_H
#include <codecs/picture.h>
#endif

/*****************************************************************************/

#define JPEGCODEC		"jpeg.codec"

/*****************************************************************************/

#define JCDA_Dummy		(PCDA_Dummy + 0x40)

/* JPEG attributes */
#define JCDA_DCTMethod		(JCDA_Dummy + 1)	/* [.s.] (LONG) */
#define JCDA_Interleave		(JCDA_Dummy + 4)	/* [.sg] (BOOL) */
#define JCDA_RestartInterval	(JCDA_Dummy + 5)	/* [.sg] (LONG) */
#define JCDA_JFIFMarker		(JCDA_Dummy + 6)	/* [.sg] (BOOL) */
#define JCDA_AdobeMarker	(JCDA_Dummy + 7)	/* [.sg] (BOOL) */
#define JCDA_RawData		(JCDA_Dummy + 14)	/* [.sg] (BOOL) */
#define JCDA_ArithCode		(JCDA_Dummy + 16)	/* [.sg] (BOOL) */
#define JCDA_CCIR601Sampling	(JCDA_Dummy + 17)	/* [.sg] (BOOL) */

/* JPEG compressor attributes */
#define JCDA_OptimizeCoding	(JCDA_Dummy + 3)	/* [.s.] (BOOL) */
#define JCDA_JPEGColorSpace	(JCDA_Dummy + 10)	/* [.s.] (LONG) */
#define JCDA_ForceBaseline	(JCDA_Dummy + 11)	/* [.s.] (BOOL) */
#define JCDA_LinearQuality	(JCDA_Dummy + 12)	/* [.s.] (LONG) */
#define JCDA_SuppressTables	(JCDA_Dummy + 18)	/* [.s.] (BOOL) */

/* JPEG decompressor attributes */
#define JCDA_BlockSmoothing	(JCDA_Dummy + 8)	/* [.s.] (BOOL) */
#define JCDA_FancyUpsampling	(JCDA_Dummy + 9)	/* [.s.] (BOOL) */
#define JCDA_AdobeTransform	(JCDA_Dummy + 13)	/* [..g] (LONG) */
#define JCDA_Marker		(JCDA_Dummy + 15)	/* [..g] (struct JPEGMarker *) */

/* JPEG component attributes */
#define JCDA_ComponentIndex	(JCDA_Dummy + 32)	/* [.sg] (LONG) */
#define JCDA_HSampFactor	(JCDA_Dummy + 33)	/* [.sg] (LONG) */
#define JCDA_VSampFactor	(JCDA_Dummy + 34)	/* [.sg] (LONG) */
#define JCDA_QuantTableNo	(JCDA_Dummy + 35)	/* [.sg] (LONG) */
#define JCDA_DCTableNo		(JCDA_Dummy + 36)	/* [.sg] (LONG) */
#define JCDA_ACTableNo		(JCDA_Dummy + 37)	/* [.sg] (LONG) */
#define JCDA_ComponentID	(JCDA_Dummy + 38)	/* [.sg] (LONG) */

/*****************************************************************************/

/* DCT methods */
#define JCDDM_NORMAL		0	/* Default method */
#define JCDDM_FASTEST		1	/* Use fastest possible method */
#define JCDDM_BEST		2	/* Use method with best quality */

struct JPEGMarker
{
    ULONG		 jm_Type;
    UBYTE		*jm_Data;
    LONG		 jm_Length;	/* -1 means NULL terminated string */
};

/* Marker types */
#define JCDMT_COM		0xFE	/* Comment */
#define JCDMT_APP0		0xE0	/* APPn is "JCDMT_APP0 + n" */

/*****************************************************************************/

#define JCDM_Dummy		(PCDM_Dummy + 0x40)

#define JCDM_ADDQTBL		(JCDM_Dummy + 1)
#define JCDM_WRITEMARKER	(JCDM_Dummy + 2)

/*****************************************************************************/

struct jcdAddQTbl
{
    ULONG		 MethodID;
    LONG		 jcdq_Which;
    ULONG		*jcdq_Table;
    LONG		 jcdq_Scale;
};

struct jcdWriteMarker
{
    ULONG		 MethodID;
    struct JPEGMarker	 jcdw_Marker;
};

/*****************************************************************************/

#endif /* CODECS_JPEG_H */
