#ifndef CODECS_PICTURE_H
#define CODECS_PICTURE_H
/*
**  $VER: picture.h 0.1 (24.6.94)
**
**  Interface definitions for Tower picture codec objects.
**
**  Copyright © 1994 Christoph Feck, TowerSystems.
**  All Rights Reserved.
**
**  NOTE:  This file is provided "AS-IS" and subject to change without
**  prior notice; no warranties are made.  All use is at your own risk.
**  No liability or responsibility is assumed.
*/

#ifndef CLASSES_CODEC_H
#include <classes/codec.h>
#endif

/*****************************************************************************/

#define PICTURECODEC		"picture.codec"

/*****************************************************************************/

typedef UBYTE		*SAMPROW;
typedef SAMPROW		*SAMPARRAY;
typedef SAMPARRAY	*SAMPIMAGE;

/*****************************************************************************/

#define PCDA_Dummy		(CDA_Dummy + 0x80)

/* Picture attributes */
#define PCDA_Width		(PCDA_Dummy + 1)	/* [.sg] (LONG) Number of pixels per row. */
#define PCDA_Height		(PCDA_Dummy + 2)	/* [.sg] (LONG) Number of rows in picture. */
#define PCDA_Components		(PCDA_Dummy + 3)	/* [.sg] (LONG) Number of components in color space. */
#define PCDA_ColorSpace		(PCDA_Dummy + 4)	/* [.sg] (LONG) Color space of the picture. */
#define PCDA_Gamma		(PCDA_Dummy + 5)	/* [.sg] (DOUBLE) Pass a pointer for setting. */
#define PCDA_DensityUnit	(PCDA_Dummy + 6)	/* [.sg] (LONG) */
#define PCDA_XDensity		(PCDA_Dummy + 7)	/* [.sg] (LONG) */
#define PCDA_YDensity		(PCDA_Dummy + 8)	/* [.sg] (LONG) */
#define PCDA_NumColors		(PCDA_Dummy + 9)	/* [.sg] (LONG) */
#define PCDA_ColorMap		(PCDA_Dummy + 10)	/* [.sg] (SAMPARRAY) */
#define PCDA_Scanline		(PCDA_Dummy + 11)	/* [..g] (LONG) */
#define PCDA_ScaleNum		(PCDA_Dummy + 12)	/* [.s.] (LONG) */
#define PCDA_ScaleDenom		(PCDA_Dummy + 13)	/* [.s.] (LONG) */

/* Picture decoder attributes */
#define PCDA_QuantizeColors	(PCDA_Dummy + 14)	/* [.s.] (LONG) */
#define PCDA_TwoPassQuantize	(PCDA_Dummy + 15)	/* [.s.] (BOOL) */
#define PCDA_DitherMode		(PCDA_Dummy + 16)	/* [.s.] (LONG) */

/* Picture encoder attributes */
#define PCDA_SmoothingFactor	(PCDA_Dummy + 20)	/* [.s.] (LONG) */

/*****************************************************************************/

/* Color spaces */
#define PCDCS_UNKNOWN		0
#define PCDCS_GRAYSCALE		1
#define PCDCS_RGB		2
#define PCDCS_YCC		3
#define PCDCS_CMYK		4
#define PCDCS_YCCK		5

/* Density units */
#define PCDDU_UNKNOWN		0
#define PCDDU_DPI		1
#define PCDDU_DPCM		2

/* Dither modes */
#define PCDDM_NONE		0
#define PCDDM_ORDERED		1
#define PCDDM_FS		2

/*****************************************************************************/

#define PCDM_Dummy		(CDM_Dummy + 0x80)

/* These are all private */
#define PCDM_SCALE		(PCDM_Dummy + 1)
#define PCDM_HAMPALETTE		(PCDM_Dummy + 14)
#define PCDM_HAMCONVERT		(PCDM_Dummy + 15)

/*****************************************************************************/

struct pcdHamPalette
{
    ULONG MethodID;
    struct ColorRegister *cmap;
    LONG numcolors;
};

struct pcdHamConvert
{
    ULONG MethodID;
    UBYTE *buffer;
    LONG width;
    ULONG halving;
    LONG numcolors;
};

/*****************************************************************************/

#endif /* CODECS_PICTURE_H */
