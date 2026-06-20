/*
**	SaveMIDI.c
**
**	Copyright (C) 1994 Bernardo Innocenti
**
**	Original MOD2MIDI PC code (C) 1993 Andrew Scott
**	Amiga Mod2Midi port (C) 1994 Raul Sobon
**
**	Save internal data to a MIDI type 1 file.
*/

#include <exec/types.h>

#include <clib/dos_protos.h>

#include <pragmas/dos_pragmas.h>

#include "XModule.h"
#include "Gui.h"


#define ID_MThd		0x4D546864	/* "MThd", Midi Track HeaDer	*/
#define ID_MTrk		0x4D54726B	/* "MTrk", Midi TRacK			*/



#define DRUMCHANNEL 9

/* Returns a volume in the range 0..127 */
#define RESTRICTVOL(v) (((v) < 0) ? 0 : (((v) > 127) ? 127 : (v)))

/* Convert XModule note -> MIDI note */
#define NOTEVALUE(n) ((n)+36)

#define EVOL(ie,x) (((x) + (ie)->VolShift[0]) * (ie)->VolShift[1] / (ie)->VolShift[2])

#define ANOTE(x) (((x) < 0) ? (-x) : NOTEVALUE(x))

#define ENOTE(ie,x,y) (((ie)->MidiCh > 127) ? ((ie)->MidiCh - 128) : (ANOTE(x) + (ie)->Transpose[y]))



struct MThd
{
	UWORD unknown1;		/* Set to 1		*/
	UWORD Tracks;
	UWORD unknown2;		/* Set to 192	*/
};

struct TRKInfo
{
	UBYTE unknown1[63];
	UBYTE NameLen;
	/* SongName follows */
};

struct InstrExtra
{
	UBYTE MidiCh;
	UBYTE MidiPr;
	UBYTE VolShift[3];
	UBYTE Transpose[3];
};


/* Local functions prototypes */

static UWORD ChooseChannels		(struct Instrument *instr, struct InstrExtra *ie, UBYTE DrumChann);
static ULONG WriteTrack0Info	(BPTR fp, struct SongInfo *si);
static UWORD WriteMIDIHeader	(BPTR fp, UWORD numofchannels);
static LONG WriteVLQ			(BPTR fp, ULONG i);
static ULONG StopNote			(BPTR fp, struct InstrExtra *ie, UWORD channel, UWORD note, UWORD vol, ULONG timer);
static ULONG NoteLength (UBYTE note, ULONG lenght, UWORD beats);



UWORD SaveMIDI (struct SongInfo *si, BPTR fp)
{
	UWORD numofchannels, err,
		i, j, k;
	struct Instrument *instr = &si->Inst[0], *inst1;
	ULONG l;
	BOOL tempodone = FALSE;

	struct InstrExtra iext[MAXINSTRUMENTS], *ie1;

	DisplayAction (MSG_CHOOSING_CHANNELS);

	/* Setup InstrExtra structures */
	for (i = 0; i < MAXINSTRUMENTS; i++)
	{
		iext[i].VolShift[0] = 0;
		iext[i].VolShift[1] = 1;
		iext[i].VolShift[2] = 1;
		iext[i].Transpose[0] = 0;
		iext[i].Transpose[1] = 0;
		iext[i].Transpose[2] = 0;
	}


	/* Get required number of channels */
	if ((numofchannels = ChooseChannels (instr, iext, DRUMCHANNEL)) > 16)
	{
		ShowMessage (MSG_TOO_MANY_CHANNELS);
		return RETURN_FAIL;
	}

	/* Write Header */
	if (err = WriteMIDIHeader (fp, numofchannels))
		return err;

	DisplayAction (MSG_WRITING_MIDI_TRACKS);

	for (i = 0, inst1 = instr, ie1 = iext ; i < MAXINSTRUMENTS; inst1++, ie1++, i++)
	{
		ULONG count, mktrlenpos, timer, delay[MAXTRACKS];
		UBYTE c;

		if (!i || inst1->Length)
		{
			if (DisplayProgress (i, MAXINSTRUMENTS))
				return ERROR_BREAK;

			/* Write MIDI Track */
			l = ID_MTrk;
			if (!FWrite (fp, &l, 4, 1)) return ERR_READWRITE;

			/* Write chunk length	(set to 0 now...) */

			mktrlenpos = Seek (fp, 0, OFFSET_CURRENT);	/* Write it later */
			l = 0;
			if (!FWrite (fp, &l, 4, 1)) return ERR_READWRITE;

			if (!i)
			{
				if (!(count = WriteTrack0Info (fp, si)))
					return ERR_READWRITE;
			}
			else
			{
				static UBYTE unknown[4] = {0, 255, 3, 0};
				static struct
				{
					UBYTE unknown_zero;
					UBYTE channel;
					UBYTE preset;
				} instrinfo;

				/* Write some unknown header */
				unknown[3] = strlen (inst1->Name);
				if (!FWrite (fp, unknown, 4, 1)) return ERR_READWRITE;

				/* Write instrument name */
				if (!FWrite (fp, inst1->Name, unknown[3], 1)) return ERR_READWRITE;

				instrinfo.unknown_zero = 0;
				instrinfo.channel = c = 0xC0 + ie1->MidiCh;
				instrinfo.unknown_zero = (ie1->MidiPr > 127) ? 126 : ie1->MidiPr;
				if (!FWrite (fp, &instrinfo, sizeof (instrinfo), 1))
					return ERR_READWRITE;

				count = sizeof (unknown) + sizeof (instrinfo) + unknown[3];
			}
		}

		timer = 0;
		if (!i || inst1->Length)
		{
			UWORD bpm, ticks, l, h;
			UBYTE sampnum, effnum, effval, lastsam[MAXTRACKS] = {0}, vol[MAXTRACKS];
			BYTE patbreak;
			ULONG x, pause;
			UWORD note, lastslide, slideto;
			UWORD n[MAXTRACKS][48][2];		/* Note data for a song position		*/
			UWORD lastn[MAXTRACKS];			/* Last note on a particular channel	*/

			memset (lastn, 0, MAXTRACKS * sizeof (UWORD));
			memset (vol, 0, MAXTRACKS);
			memset (delay, 0, MAXTRACKS * sizeof (ULONG));

			bpm = si->GlobalTempo;
			ticks = si->GlobalSpeed;
			lastslide = slideto = 0;
			patbreak = 0;

			for (h = 48; h--; )
				for (k = MAXTRACKS; k--; )
					n[k][h][0] = 0;

			for (l = 0; l < si->Length; l++)
			{
				struct Pattern *patt = &si->PattData[si->Sequence[l]];

				/* ??? */
				if (patbreak > 0)
					patbreak = 1 - patbreak;

				for (j = 0; j < patt->Lines; j++)
				{
					pause = 0;
					if (!patbreak)
					{
						for (k = 0; k < patt->Tracks; k++)
						{
							n[k][0][1] = inst1->Volume;

							sampnum = patt->Notes[k]->Inst;
							note	= patt->Notes[k]->Note;
							effnum	= patt->Notes[k]->EffNum;
							effval	= patt->Notes[k]->EffVal;

							if (!i) note = 0;

							if ((note || sampnum) && delay[k])
							{
								count += StopNote (fp, ie1, c, lastn[k], vol[k], timer);
								timer = 0;
								delay[k] = 0;
							}

							if (!note && sampnum == i) /* check "defaults" */
								note = lastn[k];
							else
							{
								if (!sampnum)
								{
									if (lastsam[k] == i)
										sampnum = i;
									else
										note = 0;
								}
								else
								{
									if (sampnum != i)
										note = 0;
									lastsam[k] = sampnum;
								}
								n[k][0][0] = note;
							}

							/* Do Effects */
							switch (effnum)
							{
								case 0x0:				/* Arpeggio */
								{
									UWORD nv;

									if (!i || !effval || ie1->MidiCh > 127)
										break;
									if (!note)
									{
										if (!delay[k])
											break;
										else
										{
											nv = NOTEVALUE(lastn[k]);
											n[k][47][0] = lastn[k];
											n[k][47][1] = vol[k];
											if (effval & 0xF0)
												n[k][16][0] = -(nv + ((effval & 0xF0) >> 4));
											n[k][16][1] = vol[k];
											if (effval & 0x0F)
												n[k][32][0] = -(nv + (effval & 0x0F));
											n[k][32][1] = vol[k];
										}
									}
									else
									{
										nv = NOTEVALUE(note);
										n[k][47][0] = note;
										n[k][47][1] = inst1->Volume;
										if (effval & 0xF0)
											n[k][16][0] = -(nv + ((effval & 0xF0) >> 4));
										n[k][16][1] = inst1->Volume;
										if (effval & 0x0F)
											n[k][32][0] = -(nv + (effval & 0x0F));
										n[k][32][1] = inst1->Volume;
									}
									break;
								}

								case 0x1:				/* Slide Up */
								case 0x2:				/* Slide Down */
									if (!(effval & 0xFF) || ie1->MidiCh > 127)
										break;
									if (effnum == 0x2)
										lastslide = effval;
									else
										lastslide = -effval;
									if (!note)
										if (!delay[k])
											break;
										else
										{
											n[k][0][0] = lastn[k] + lastslide;
											n[k][0][1] = vol[k];
										}
									else
										n[k][0][0] += lastslide;
									if (n[k][0][0] < 13)
										n[k][0][0] = 13;	/* C-1 */
									else if (n[k][0][0] > 48)
										n[k][0][0] = 48;	/* B#3 */
									break;

								case 0x3:				/* Slide To */
									if (!note && !slideto || note == lastn[k] || ie1->MidiCh > 127)
										break;
									if (effval & 0xFF)
										lastslide = effval;
									else
										lastslide = abs (lastslide);
									if (note)
										slideto = note;
									if (slideto > lastn[k])
									{
										n[k][0][0] = lastn[k] + lastslide * (ticks-1);
										if (n[k][0][0] < 13)
											n[k][0][0] = 13;	/* C-1 */
										if (n[k][0][0] > slideto)
											n[k][0][0] = slideto;
									}
									else
									{
										n[k][0][0] = lastn[k] - lastslide*(ticks-1);
										if (n[k][0][0] > 48)
											n[k][0][0] = 48;	/* B#3 */
										if (n[k][0][0] < slideto)
											n[k][0][0] = slideto;
									}
									n[k][0][1] = vol[k];
									break;

								case 0x4:			/* Vibrato */
								case 0x7:			/* Tremolo */
									/* ignore these effects.. not convertable */
									break;

								case 0x5:			/* Slide To + Volume Slide */
									if ((note || slideto) && note!=lastn[k] && ie1->MidiCh < 128)
									{
										if (note)
											slideto = note;
										if (slideto > lastn[k])
										{
											n[k][0][0] = lastn[k] + lastslide*(ticks-1);
											if (n[k][0][0] < 13)
												n[k][0][0] = 13;	/* C-1 */
											if (n[k][0][0] > slideto)
												n[k][0][0] = slideto;
										}
										else
										{
											n[k][0][0] = lastn[k] - lastslide*(ticks-1);
											if (n[k][0][0] > 48)
												n[k][0][0] = 48;	/* B#3 */
											if (n[k][0][0] < slideto)
												n[k][0][0] = slideto;
										}
									}
									else
										n[k][0][0] = 0;
									note = 0;

									/* We do not break here: the next case block (0xA)
									 * will slide volume for us
									 */

								case 0x6:			/* Vibrato & Volume Slide */
									/* Ignore Vibrato; do Volume Slide only */

								case 0xA:			/* Volume Slide */
								{
									UWORD v;

									if (!note)
										v = vol[k];
									else
										v = inst1->Volume;
									v += (ticks-1)*(effval & 0xF0); /* Can't really slide */
									v -= (ticks-1)*(effval & 0x0F);
									if (v > 127)
										v = 127;
									else if (v < 0)
										v = 0;
									n[k][0][1] = v;
									break;
								}

								case 0x9:		/* Set offset: pretend it's retrigger */
									if ((!n[k][0][0] || !sampnum) && delay[k])
									{
										n[k][0][0] = lastn[k];
										n[k][0][1] = vol[k];
									}
									break;

								case 0xB:			/* Position Jump */
									patbreak = 1;	/* Ignore, but break anyway */
									break;

								case 0xD:			/* Pattern Break */
									patbreak = 1 + 10 * (effval & 0xF0) + (effval & 0x0F);
									break;

								case 0xC:			/* Set Volume */
									{
										UWORD vol = effval;

										if (vol == 0x40) vol=0x3F;
										vol = vol & 0x3F;
										n[k][0][1] = vol << 1;
									}
									break;

								case 0xF:			/* Set Speed/Tempo */
								{
									UWORD temp;

									temp = effval;

									if (!temp)
										temp = 1;
									if (temp < 32)
									{
										ticks = temp;
									//	if (TempoType)	/* Tempos act strangely so .. */
										{
											bpm = 750 / temp;
											x = 80000 * temp;
										}
									}
									else
									{
										bpm = temp;
										x = 60000000 / temp;
									}

									if (i)		/* Only write tempo on track 0 */
										break;

									count += 6 + WriteVLQ (fp, timer);
									timer = 0;
									FPutC (fp, 255);	/* Meta-Event	*/
									FPutC (fp, 81);		/* Set Tempo	*/
									FPutC (fp, 3);
									FPutC (fp, x >> 16);
									FPutC (fp, (x >> 8) & 0xFF);
									FPutC (fp, x & 0xFF);
									tempodone = TRUE;

									break;
								}

								case 0xE:		/* Extended Effects */
									switch (effval & 0xF0)
									{
										case 0x10:		/* Fine Slide Up */
											if (!(effval & 0x0F) || ie1->MidiCh > 127)
												break;
											if (!note)
											{
												if (!delay[k])
													break;
												else
												{
													n[k][h][0] = lastn[k] + (effval & 0x0F);
													n[k][h][1] = vol[k];
												}
											}
											else
												n[k][h][0] += effval & 0x0F;
											break;

										case 0x020:		/* Fine Slide Down */
											if (!(effval & 0x0F) || ie1->MidiCh > 127)
												break;
											if (!note)
												if (!delay[k])
													break;
												else {
													n[k][h][0] = lastn[k] - (effval & 0x0F);
													n[k][h][1] = vol[k];
												}
											else
												n[k][h][0] -= effval & 0x0F;
											break;
										case 0x00: /* set filter on/off */
										case 0x30: /* glissando on/off */
										case 0x40: /* set vibrato wave */
										case 0x50: /* set finetune */
										case 0x60: /* pattern loop */
										case 0x70: /* set tremolo wave */
										case 0x80: /* un-used */
										case 0xF0: /* invert loop */
											/* Can't do these in MIDI.. ignore */
											break;

										case 0x0A0:		/* Fine volume slide up		*/
										case 0x0B0:		/* Fine volume slide down	*/
										{
											UWORD v;

											v = inst1->Volume;
											if (effval & 0xA0)
												v += effval & 0x0F;
											else
												v -= effval & 0x0F;
											if (v < 0)
												v = 0;
											else if (v>127)
												v = 127;
											n[k][0][1] = v;
											break;
										}

										case 0x90:		/* Retrigger sample */
										{
											UWORD a, b, c;

											if (!note && !delay[k] || !(effval & 0x0F))
												break;
											a = effval & 0x0F;
											if (!(ticks / a))
												break;
											if (!note)
											{
												n[k][0][0] = lastn[k];
												n[k][0][1] = vol[k];
											}
											c = 0;
											b = 1;
											a *= 48;
											while (c < 48)
											{
												n[k][c][0] = note;
												n[k][c][1] = n[k][0][1];
												c = b * a / ticks;
												b++;
											}

											break;
										}

										case 0xC0:		/* Cut sample */
										{
											UWORD a;

											if (!note && !delay[k])
												break;
											a = 48 * (effval & 0x0F) / ticks;
											if (a > 47)
												break;
											if (note)
												n[k][a][0] = note;
											else
												n[k][a][0] = lastn[k];
											n[k][a][1] = 0;
											break;
										}

										case 0xD0:		/* Delay Sample */
										{
											UWORD a;

											if (!note || !(effval & 0x0F))
												break;
											a = 48 * (effval & 0x0F) / ticks;
											n[k][0][0] = 0;
											if (a > 47)
												break;
											n[k][a][0] = note;
											n[k][a][1] = n[k][a][0];
											break;
										}

										case 0xE0:		/* Pattern Pause */
											pause = 48 * (effval & 0x0F);
											break;

									}	/* End Switch (E effects) */

									break;
									/* else dunno what it does.. disbelieve it ;) */

							}	/* End switch (effnum) */

						}	/* End for (Tracks) */
					}	/* End if (!pattnreak) */

					for (h = 0; h<48; h++)
					{
						for (k = 0; k < patt->Tracks; k++)
						{
							if (n[k][h][0])
							{
								if (delay[k])  /* Turn off old note on same channel */
								{
									count += StopNote (fp, ie1, c, lastn[k], vol[k], timer);
									timer = 0;
									delay[k] = 0;
								}
								lastn[k] = n[k][h][0];
								n[k][h][0] = 0;
								vol[k] = n[k][h][1];
								count += 3 + WriteVLQ(fp, timer);
								timer = 0;
								FPutC (fp, 0x90 + c);	/* Note On */
								FPutC (fp, ENOTE(ie1, lastn[k], 0));
								FPutC (fp, RESTRICTVOL(EVOL(ie1,vol[k])));
								if (ie1->Transpose[1])
								{
									count += 4;
									FPutC (fp, 0);
									FPutC (fp, 0x90 + c);
									FPutC (fp, ENOTE(ie1, lastn[k], 1));
									FPutC (fp, RESTRICTVOL(EVOL(ie1, vol[k])));
									if (ie1->Transpose[2])
									{
										count += 4;
										FPutC (fp, 0);
										FPutC (fp, 0x90 + c);
										FPutC (fp, ENOTE(ie1, lastn[k], 2));
										FPutC (fp, RESTRICTVOL(EVOL(ie1, vol[k])));
									}
								}
								delay[k] = NoteLength (ANOTE(lastn[k]), inst1->Length, bpm);
							}
							else if (delay[k]==1)
							{
								delay[k] = 0;
								count += StopNote (fp, ie1, c, lastn[k], vol[k], timer);
								timer = 0;
							}
							else if (delay[k]>0)
								delay[k]--;
						}
						timer++;
					}
					timer += pause;
					if (patbreak<0)
						patbreak++;
					else if (patbreak>0)
					{
						patbreak = 1 - patbreak;
						j = 0;
					}
				}	/* End for (Lines) */
			}	/* End for (si->Length) */

			for (k = 0; k < si->MaxTracks; k++)
				if (delay[k])
				{
					count += StopNote (fp, ie1, c, lastn[k], vol[k], timer);
					timer = 0;
				}
		}

		if(!i && !tempodone)
		{
			count += 7;
			FPutC (fp, 0);		/* Give the default 128 bpm if none done yet */
			FPutC (fp, 255);
			FPutC (fp, 81);
			FPutC (fp, 3);
			FPutC (fp, 7);
			FPutC (fp, 39);
			FPutC (fp, 14);
		}

		if(inst1->Length || !i)		// RAUL addition
		{
			count += 3 + WriteVLQ (fp, timer);
			FPutC (fp, 255);
			FPutC (fp, 47);
			FPutC (fp, 0);

			/* Write total chunk length */

			if (Seek (fp, mktrlenpos, OFFSET_BEGINNING) == -1)
				return ERR_READWRITE;

			if (!(FWrite (fp, &count, 4, 1)))
				return ERR_READWRITE;

			if (Seek (fp, 0, OFFSET_END) == -1)
				return ERR_READWRITE;
		}

	}	/* End for (instruments) */

	return RETURN_OK;
}



static UWORD ChooseChannels (struct Instrument *instr, struct InstrExtra *ie, UBYTE DrumChann)

/*	Returns: The number of different channels needed to play instruments.
 *	If that number is not greater than 16, upto 16 channels will
 *	be allocated to the samples.
 */
{
	UBYTE c, Presets[128], m, n, numchan;
	UBYTE DrumUsed = 0;
	struct Instrument *instr1, *instr2;
	struct InstrExtra *ie1, *ie2;

	/* Preset all presets !!! */
	for (n = 0; n < MAXINSTRUMENTS; n++)
		ie[n].MidiPr = n;

	memset (Presets, 0, 128);

	for (n = MAXINSTRUMENTS, instr1 = &instr[1], ie1 = &ie[1]; n--; instr1++, ie1++)
	{
		ie->MidiCh = 255;
		if (instr1->Length)
		{
			if (ie1->MidiPr > 127)
			{
				DrumUsed = 1;
				ie1->MidiCh = DrumChann;
			}
			else
				Presets[ie1->MidiPr] = 1;
		}
		else
			ie1->MidiPr = 0;
	}

	for (numchan = DrumUsed, n = 128; n--; numchan += Presets[n]);

	if (numchan > 16)
		return numchan;

	/* Go through and set channels appropriately */
	m = MAXINSTRUMENTS;
	instr1 = &instr[1];
	ie1 = &ie[1];
	c = 0;
	while (--m)
	{
		if (ie1->MidiCh < 0)
		{
			ie1->MidiCh = c;
			n = m;
			ie2 = ie1 + 1;
			instr2 = instr1 + 1;

			/* Search for other instruments with the same preset and set
			 * all them to the same MIDI channel.
			 */
			while (n--)
			{
				if (ie2->MidiCh < 0)
					if (ie2->MidiPr == ie1->MidiPr || !instr2->Length)
						ie2->MidiCh = c;
				instr2++;
				ie2++;
			}
			if (++c == DrumChann && DrumUsed)
				c++;
		}
		ie1++;
		instr1++;
	}
	return numchan;
}



static UWORD WriteMIDIHeader (BPTR fp, UWORD numofchannels)
{
	ULONG l;

	/* Write MIDI header	*/
	l = ID_MThd;
	if (!FWrite (fp, &l, 4, 1)) return ERR_READWRITE;

	/* Write chunk length	*/
	l = sizeof (struct MThd);
	if (!FWrite (fp, &l, 4, 1)) return ERR_READWRITE;

	/* Write header chunk	*/
	{
		struct MThd mthd;

		mthd.unknown1 = 1;
		mthd.Tracks = numofchannels;
		mthd.unknown2 = 192;

		if (!FWrite (fp, &mthd, sizeof (mthd), 1)) return ERR_READWRITE;
	}

	return RETURN_OK;
}



static ULONG WriteTrack0Info (BPTR fp, struct SongInfo *si)

/* Write info for track 0.
 * Return actual number of bytes written, or 0 for failure.
 */
{
	static UBYTE TRK0I[63] =
	{
		0, 255, 2, 42, 70, 105, 108, 101, 32, 67, 111, 112, 121, 114, 105, 103,
		104, 116, 32, 40, 99, 41, 32, 49 ,57, 57, 51, 32, 65, 100, 114, 101, 110,
		97, 108, 105, 110, 32, 83, 111, 102, 116, 119, 97, 114, 101,
		0, 255, 88, 4, 3, 2, 24, 8,
		0, 255, 89, 2, 0, 0,
		0, 255, 3
	}; /* standard header + copyright message */

	struct TRKInfo trkinfo;

	memcpy (trkinfo.unknown1, TRK0I, 63);
	trkinfo.NameLen = strlen (si->SongName);

	if (!FWrite (fp, &trkinfo, sizeof (trkinfo), 1))
		return 0;

	if (!FWrite (fp, si->SongName, trkinfo.NameLen, 1))
		return 0;

	return (sizeof (trkinfo) + trkinfo.NameLen);
}



static LONG WriteVLQ (BPTR fp, ULONG i)

/*	Writes a stream of bytes, each with the msb (bit 7) set to 1 to mean
 *	continuation and 0 to end the byte sequnce.  Note that the data is
 *	put in reverse order.
 *
 *	Returns: # of bytes written after a variable-length-quantity equivalent
 * 	of i has been written to the file f, or 0 for failure.
 */
{
	LONG x = 0;
	ULONG buffer;

	buffer = i & 0x7F;
	while ((i >>= 7) > 0)
		buffer = ((buffer << 8) | 0x80) + (i & 0x7F);
	while (1)
	{
		FPutC (fp, buffer & 0xFF);

		x++;

		if (buffer & 0x80)
			buffer >>= 8;
		else
			return x;
	}
}



static ULONG StopNote (BPTR fp, struct InstrExtra *ie, UWORD channel, UWORD note, UWORD vol, ULONG timer)

/* stop old note */
{
	UWORD count = 3 + WriteVLQ (fp, timer);

	FPutC (fp, 0x80 + channel);	/* note off */
	FPutC (fp, ENOTE(ie, note, 0));
	FPutC (fp, RESTRICTVOL(EVOL(ie, vol)));
	if (ie->Transpose[1])
	{
		count += 4;
		FPutC (fp, 0);
		FPutC (fp, 0x80 + channel);
		FPutC (fp, ENOTE(ie, note, 1));
		FPutC (fp, RESTRICTVOL(EVOL(ie, vol)));
		if (ie->Transpose[2])
		{
			count += 4;
			FPutC (fp, 0);
			FPutC (fp, 0x80 + channel);
			FPutC (fp, ENOTE(ie, note, 2));
			FPutC (fp, RESTRICTVOL(EVOL(ie, vol)));
		}
	}

	return count;
}



static ULONG NoteLength (UBYTE note, ULONG lenght, UWORD beats)

{
    unsigned long  idx;

/*	static float t[84] = {
		3.200e-3, 3.020e-3, 2.851e-3, 2.691e-3, 2.540e-3, 2.397e-3,
		2.263e-3, 2.136e-3, 2.016e-3, 1.903e-3, 1.796e-3, 1.695e-3,
		1.600e-3, 1.510e-3, 1.425e-3, 1.345e-3, 1.270e-3, 1.197e-3,
		1.131e-3, 1.068e-3, 1.008e-3, 9.514e-4, 8.980e-4, 8.476e-4,
		8.000e-4, 7.551e-4, 7.127e-4, 6.727e-4, 6.350e-4, 5.993e-4,
		5.657e-4, 5.339e-4, 5.040e-4, 4.757e-4, 4.490e-4, 4.238e-4,
		4.000e-4, 3.775e-4, 3.564e-4, 3.364e-4, 3.175e-4, 2.997e-4,
		2.828e-4, 2.670e-4, 2.520e-4, 2.378e-4, 2.245e-4, 2.119e-4,
		2.000e-4, 1.888e-4, 1.782e-4, 1.682e-4, 1.587e-4, 1.498e-4,
		1.414e-4, 1.335e-4, 1.260e-4, 1.189e-4, 1.122e-4, 1.059e-4,
		1.000e-4, 9.439e-5, 8.909e-5, 8.409e-5, 7.937e-5, 7.492e-5,
		7.071e-5, 6.674e-5, 6.300e-5, 5.946e-5, 5.612e-5, 5.297e-5,
		5.000e-5, 4.719e-5, 4.454e-5, 4.204e-5, 3.969e-5, 3.746e-5,
		3.536e-5, 3.337e-5, 3.150e-5, 2.973e-5, 2.806e-5, 2.649e-5
		}; */ /* multipliers for each pitch: 12th roots of 2 apart */

	idx = note - 36;
	if (idx < 0) idx = 0;
	if (idx > 84) idx = 84;

	return (TrackerNotes[idx] * beats * lenght); /* better not slide out of this range :( */
}
