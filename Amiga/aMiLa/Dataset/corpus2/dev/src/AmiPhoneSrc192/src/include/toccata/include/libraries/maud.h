
/*
**  This C include file was generated automatically
**  from an assembly include file
**  using I2H written by Henning Friedl.
*/


#ifndef MAUD_H
#define MAUD_H	1
/* --------------------------------------------------------------------------- */
/*               IFND        EXEC_TYPES_I */
/*                 INCLUDE   "exec/types.i" */
/*               ENDC */
/* --------------------------------------------------------------------------- */
/* ---- ID's used in FORM MAUD */

#define ID_MAUD	0x4D415544	/* 'MAUD' */	/* the FORM-ID */
#define ID_MHDR	0x4D484452	/* 'MHDR' */	/* file header chunk */
#define ID_MDAT	0x4D444154	/* 'MDAT' */	/* sample data chunk */
#define ID_MINF	0x4D494E46	/* 'MINF' */	/* optional channel info chunk (future) */

/* ---- the file header 'MHDR' */

struct MaudHeader {
	ULONG	mhdr_Samples;	/* number of samples stored in MDAT */
	UWORD	mhdr_SampleSizeC;	/* number of bits per sample as stored in MDAT */
	UWORD	mhdr_SampleSizeU;	/* number of bits per sample after decompression */
	ULONG	mhdr_RateSource;	/* clock source frequency (see maud.doc) */
	UWORD	mhdr_RateDevide;	/* clock devide           (see maud.doc) */
	UWORD	mhdr_ChannelInfo;	/* channel information (see below) */
	UWORD	mhdr_Channels;	/* number of channels (mono: 1, stereo: 2, ...) */
	UWORD	mhdr_Compression;	/* compression type (see below) */
	ULONG	mhdr_Reserved1;	/* MUST be set to 0 when saving */
	ULONG	mhdr_Reserved2;	/* MUST be set to 0 when saving */
	ULONG	mhdr_Reserved3;	/* MUST be set to 0 when saving */
};

/* ---- possible values for mhdr_ChannelInfo */

#define MCI_MONO	0	/* mono */
#define MCI_STEREO	1	/* stereo */
#define MCI_MULTIMONO	2	/* mono multichannel (channels can be 2, 3, 4, ...) */
#define MCI_MULTISTEREO	3	/* stereo multichannel (channels must be 4, 6, 8, ...) */
#define MCI_MULTICHANNEL	4	/* multichannel (requires additional MINF-chunks) (future) */

/* ---- possible values for mhdr_Compression */

#define MCOMP_NONE	0	/* no compression */
#define MCOMP_FIBDELTA	1	/* 'Fibonacci Delta Compression' as used in 8SVX */
#define MCOMP_ALAW	2	/* 16->8 bit, European PCM standard A-Law */
#define MCOMP_ULAW	3	/* 16->8 bit, American PCM standard µ-Law */
#define MCOMP_ADPCM2	4	/* 16->2 bit, ADPCM compression */
#define MCOMP_ADPCM3	5	/* 16->3 bit, ADPCM compression */
#define MCOMP_ADPCM4	6	/* 16->4 bit, ADPCM compression */
#define MCOMP_ADPCM5	7	/* 16->5 bit, ADPCM compression */
#define MCOMP_LONGDAT	8	/* 16->12 bit, used for DAT-longplay */

/* --------------------------------------------------------------------------- */
#endif	/*  MAUD_I */
