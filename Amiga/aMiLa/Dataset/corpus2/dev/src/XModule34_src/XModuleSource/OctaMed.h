/*
**	OctaMed.h
**
**	Copyright (C) 1994,95 Bernardo Innocenti
**
**	Use 4 chars wide TABs to read this source
**
**	Structure definition for MED/OctaMED file formats.
**  Based on Teijo Kinnunen's format description rev 2 (30.5.93)
*/


struct MMD0sample
{
	UWORD rep, replen;	/* offs: 0(s), 2(s) */
	UBYTE midich;		/* offs: 4(s) */
	UBYTE midipreset;	/* offs: 5(s) */
	UBYTE svol;			/* offs: 6(s) */
	BYTE strans;		/* offs: 7(s) */
};


struct MMD0
{
	ULONG	id;
	ULONG	modlen;
	struct MMD0song *song;
	ULONG	reserved0;
	struct MMD0Block **blockarr;
	ULONG	reserved1;
	struct InstrHdr **smplarr;
	ULONG	reserved2;
	struct MMD0exp *expdata;
	ULONG	reserved3;
	UWORD	pstate;			/* some data for the player routine */
	UWORD	pblock;
	UWORD	pline;
	UWORD	pseqnum;
	WORD	actplayline;
	UBYTE	counter;
	UBYTE	extra_songs;	/* number of songs - 1 */
}; /* length = 52 bytes */



struct MMD0song
{
	struct MMD0sample sample[63];
	UWORD	numblocks;
	UWORD	songlen;		/* NOTE: number of sections in MMD2 */
	union {
		UBYTE	playseq[256];	/* MMD0/MMD1 only	*/
		struct {				/* MMD2	only		*/
			struct PlaySeq	**playseqtable;
			UWORD	*sectiontable;	/* UWORD section numbers */
			UBYTE	*trackvols; /* UBYTE track volumes */
			UWORD   numtracks;  /* max. number of tracks in the song (also
								 * the number of entries in 'trackvols' table)
								 */
			UWORD	numpseqs;	/* number of PlaySeqs in 'playseqtable'	*/
			UBYTE	pad0[240];	/* reserved for future expansion		*/
		};
	};
	UWORD	deftempo;
	BYTE	playtransp;
	UBYTE	flags;
	UBYTE	flags2;
	UBYTE	tempo2;
	UBYTE	trkvol[16];		/* Unused in MMD2 */
	UBYTE	mastervol;
	UBYTE	numsamples;
}; /* length = 788 bytes */


struct PlaySeq {
	char    name[32];		/* 31 chars + \0 */
	ULONG   reserved[2];	/* for possible extensions */
	UWORD   length;			/* # of entries */
	UWORD   seq[0];			/* block numbers.. */
};


/* Flags for MMD0song->Flags */

#define	FLAG_FILTERON	0x1		/* hardware low-pass filter */
#define	FLAG_JUMPINGON	0x2		/* jumping.. */
#define	FLAG_JUMP8TH	0x4		/* jump 8th.. */
#define	FLAG_INSTRSATT	0x8		/* instruments are attached (sng+samples)
								   used only in saved MED-songs */
#define	FLAG_VOLHEX		0x10	/* volumes are represented as hex */
#define FLAG_STSLIDE	0x20	/* no effects on 1st timing pulse (STS) */
#define FLAG_8CHANNEL	0x40	/* OctaMED 8 channel song, examine this bit
								   to find out which routine to use */

/* Flags for MMD0song->Flags2 */

#define FLAG2_BMASK		0x1F	/* (bits 0-4) BPM beat length (in lines)
									0 = 1 line, $1F = 32 lines.0
									(The rightmost slider in OctaMED Pro
					 				BPM mode.) */
#define FLAG2_BPM		0x20	/* BPM mode on */



struct MMD0block
{
	UBYTE	numtracks,
			lines;
};



struct MMD1block
{
	UWORD	numtracks;
	UWORD	lines;
	struct BlockInfo *info;
};



struct BlockInfo
{
	ULONG	*hlmask;
	UBYTE	*blockname;
	ULONG	blocknamelen;
	ULONG	reserved[6];
};



struct InstrHdr {
	ULONG	length;
	WORD	type;
	/* Followed by actual data */
};


/* Values for InstrHdr.type */

#define	HYBRID		-2
#define	SYNTHETIC	-1
#define	SAMPLE		0	/* ordinary 1 octave sample */
#define	IFF5OCT		1	/* 5 octaves	*/
#define	IFF3OCT		2	/* 3 octaves	*/

/* The following ones are recognized by OctaMED Pro only */
#define	IFF2OCT		3	/* 2 octaves	*/
#define	IFF4OCT		4	/* 4 octaves	*/
#define	IFF6OCT		5	/* 6 octaves	*/
#define	IFF7OCT		6	/* 7 octaves	*/



struct SynthInstr {
	ULONG	length;		/* length of this struct	*/
	WORD	type;		/* -1 or -2					*/
	UBYTE	defaultdecay;
	UBYTE	reserved[3];
	UWORD	rep;
	UWORD	replen;
	UWORD	voltbllen;
	UWORD	wftbllen;
	UBYTE	volspeed;
	UBYTE	wfspeed;
	UWORD	wforms;
	UBYTE	voltbl[128];
	UBYTE	wftbl[128];
	struct SynthWF *wf[64];
};



struct InstrExt {
	UBYTE	hold;				/* hold/decay values of the instrument	*/
	UBYTE	decay;
	UBYTE	suppress_midi_off;	/* 0 (FALSE) or not (TRUE)				*/
	BYTE	finetune;			/* instrument finetune (-8-+7)			*/
	/* length = 4 bytes */

	/* Below fields saved by >= V5 */
	UBYTE default_pitch;
	UBYTE instr_flags;
	UWORD long_midi_preset;
	/* length = 8 bytes */

	/* Below fields saved by >= V5.02 */
	UBYTE output_device;
	UBYTE reserved;
	/* length = 10 bytes */
};



struct MMDInstrInfo {
	UBYTE	name[40];			/* null-terminated instrument name.	*/
};	/* length = 40 bytes */



struct MMD0exp {
	struct MMD0 *nextmod;		/* Pointer to the next module (or zero).	*/
	struct InstrExt *exp_smp;
	UWORD	 s_ext_entries;		/* The size of InstrExt structure array
								 * (i.e. the number of InstrExt structures).
								 */
	UWORD	 s_ext_entrsz; 		/* Size of each InstrExt structure.			*/
	UBYTE	*annotxt;			/* Pointer to the null-terminated annotation text.		*/
	ULONG	 annolen;			/* Length of 'annotxt', including the terminating \0.	*/
	struct MMDInstrInfo *iinfo;
	UWORD	 i_ext_entries;		/* Size of the MMDInstrInfo struct array
								 * (i.e. the number of MMDInstrInfo structures).
								 */
	UWORD	 i_ext_entrsz;		/* Size of each MMDInstrInfo struct			*/
	ULONG	 jumpmask;			/* OBSOLETE									*/
	UWORD	*rgbtable;			/* Pointer to eight UWORDs (screen colors)
			  					 * to be passed to LoadRGB4() routine.
								 */
	UBYTE	 channelsplit[4];	/* this longword is divided to four boolean bytes,
								 * controlling channel splitting in OctaMED 5 - 8 chnl
			  					 * modes. (A non-zero byte means that the channel is
			  					 * NOT splitted.) Currently only the following
			  					 * combinations should be used:
								 *
								 * 0x00000000 (8 channels (or normal 4 channel mode))
								 * 0x000000FF (7 channels)
								 * 0x0000FFFF (6 channels)
								 * 0x00FFFFFF (5 channels)
								 */
	struct NotationInfo *n_info;/* pointer to NotationInfo structure (used only in
								 * OctaMED V2.0 and later). It contains some info for
								 * the notation editor.
								 */
	UBYTE	*songname;			/* song name of the current song (0-terminated).
								 * Each song of a multi-module can have a different
								 * name.
								 */

	ULONG	 songnamelen;		/* song name length (including the \0).		*/
	struct MMDDumpData *dumps;
	ULONG	 reserved2[7];		/* future expansion fields, that MUST be zero now.	*/
};



struct NotationInfo
{
	UBYTE	n_of_sharps;	/* number of sharps or flats (0 - 6).	*/
	UBYTE	flags;			/* See below.							*/
	WORD	trksel[5];		/* The number of the selected track,
							 * for each display preset
							 * (-1 = no track selected)
							 */
	UBYTE	trkshow[16];	/* tracks shown (five bits used in
							 * each byte, bit #0 = preset 1, etc.)
							 */
	UBYTE	trkghost[16];	/* tracks ghosted (as in 'trkshow')		*/
	BYTE	notetr[63];		/* note transpose value for each
							 * instrument (-24 - +24). If bit 6 is
							 * negated, the instrument is hidden.
							 */
	UBYTE	pad;
};

/* flags for NotationInfo->flags */
#define NFLG_FLAT 1
#define NFLG_3_4  2


/* MIDI dump data (created using OctaMED Pro MIDI
 * message editor).
 */

struct MMDDumpData {
	UWORD	numdumps;
	UWORD	reserved[3];
	/* Immediately after this struct, there are 'numdumps'
	 * pointers to MMDDump structures.
	 */
};

struct MMDDump {
	ULONG	length;		/* length of the MIDI message dump.			*/
	UBYTE	*data;		/* pointer to the actual MIDI dump data.	*/
	UWORD	ext_len;	/* MMDDump struct extension length.			*/

	/*	(if ext_len >= 20, the following fields exist)	*/
	UBYTE	name[20];	/* name of the dump.						*/
};



#define MMD0ROW	3			/* Size of an MMD0 pattern row */
#define MMD1ROW	4			/* Size of an MMD1/MMD2 pattern row */

#define ID_MMD0	0x4D4D4430
#define ID_MMD1 0x4D4D4431
#define ID_MMD2 0x4D4D4432
