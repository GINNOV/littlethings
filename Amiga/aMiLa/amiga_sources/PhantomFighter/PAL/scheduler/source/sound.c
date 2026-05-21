 /*******************************************************
 *  Routines for use with SGCS		       *
 *******************************************************
 * Written by -=BN=- and BK			       *
 *						       *
 ******************************************************/
 
#include <stdio.h>
#include <exec/types.h>
#include <exec/memory.h>
#include <math.h>
#include <hardware/custom.h>
#include <hardware/intbits.h>
#include "scheduler.h"
#include "iff.h"
#include "sound.h"
#include "GameParam.h"

#define HIGHBASSSIZE 2000
#define SYNTHSNARESIZE 2000
#define BASS1SIZE 2000
#define BASSGUITARSIZE 2400
#define CYMBALSIZE 2000
#define SYNTHSIZE 894
#define LASERSIZE 7635
#define EXPLOSIONSIZE 7126
#define TOKENSIZE 5259

extern SCH_PEQE CreateEvent();

int quiz;

UBYTE ChannelLock[4];
WORD  ChannelPtr;
SCH_PEQE ChannelEQEs[4];

extern void *AllocMem();
extern void CleanUpEvent();


TrackDesc Track[4];
MUS_Instr Instrument[10];
SScoreHeader ScoreHeader;

UWORD Initial;

extern UWORD Octave1[128];
extern UWORD Octave2[128];
extern UWORD Octave3[128];

#define OCTAVES 10
#define NOTES 120
#define qwerty

UWORD Frequency[NOTES];
UWORD NoteLength[8];

char *HighBassSample=NULL;
char *SynthSnareSample=NULL;
char *Bass1Sample=NULL;
char *BassGuitarSample=NULL;
char *CymbalSample=NULL;
char *SynthSample=NULL;
char *TokenSample=NULL;
char *LaserSample=NULL;
char *ExplosionSample=NULL;

/****************************************************************
 * Event routine to stop a sound effect, param is UWORD holding	*
 * dmacon contents required to stop sound effect		*
 ***************************************************************/

void SND_StopChannel(ChanNo,EQE)
ULONG ChanNo;
SCH_PEQE EQE;
{
  /* Stop DMA if User0 is not set */
  if(EQE->flags^EQE_User0)

  custom.dmacon=(UWORD)(1<<ChanNo);	/* Kill DMA */

  ChannelLock[ChanNo]=0;
  PurgeEvent(EQE);
  FreeEQE(EQE);
}

/****************************************************************
 * Initialise Sound Effects, call after InitialiseSheduling()	*
 ***************************************************************/
 
void InitialiseSound()
{
  int i;
  for(i=0;i<4;++i)
     ChannelLock[i]=0;
  ChannelPtr=0;
}

WORD GetChannel()
{
   register WORD t;
   /* If Channel is in use Set User0 so that the EQE is use */
   /* will not disable the channel                          */
   if(ChannelLock[t=ChannelPtr])
      ChannelEQEs[t]->flags|=EQE_User0;
   ChannelLock[t]=1;
   ChannelPtr=(ChannelPtr+1)&(NUMCHANNELS-1);			/* None available */
   return t;
}

/****************************************************************
 * Routine to Start a sound effect using SGCS			*
 ****************************************************************
 * Written by -=BN=- May 88 *************************************
 ****************************************************************
 * Length	how long is sample in ticks			*
 * Sample	Address of actual sample			*
 * SampleSize	Size of sample in bytes				*
 * Period	Time in Usecs between samples			*
 * Volume	0-63 Volume of effect				*
 ***************************************************************/

void StartSoundEffect(Length,Sample,SampleSize,Period,Volume)
UWORD Length,*Sample,SampleSize,Period,Volume;
{
  register int ChanNo;
  register UWORD t;
  register SCH_PEQE EQE;

  ChanNo=GetChannel();
  
  ChannelEQEs[ChanNo]=
       CreateEvent(SND_StopChannel,ChanNo,Length-2,"Stop Sound");  
       
  custom.dmacon=(t=1<<ChanNo);
  for (quiz = 0;quiz<50;quiz++)quiz++; 

  custom.aud[ChanNo].ac_ptr=(UWORD *)Sample;
  custom.aud[ChanNo].ac_len=SampleSize>>1;
  custom.aud[ChanNo].ac_vol=Volume;
  custom.aud[ChanNo].ac_per=Period;
  custom.dmacon=0x8000+t;	/* Switch on sound dma */
}

/*****************************************
 * Laser Sound Effect
 *
 */
 
void StartLaserSound()
{
  StartSoundEffect(25,LaserSample,LASERSIZE,400,63);
}

/*****************************************
 * Explosion Sound Effect
 *
 */
 
void StartExplosionSound()
{
  StartSoundEffect(25,ExplosionSample,EXPLOSIONSIZE,400,63);
}

void StartTokenSound()
{
  StartSoundEffect(29,TokenSample,TOKENSIZE,324,63);
}


/****************************************************************
 * Routine to load a sample from disk when saved in SOP3 format *
 ****************************************************************
 * Written by -=BN=- May 88 *************************************
 ****************************************************************
 * name		String holding file name			*
 * Buffer	Address of pointer to point to Sample		*
 * Size		Size of sample file (ls -al to get it)		*
 ***************************************************************/
 
void LoadSample(name,Buffer,Size)
char *name,**Buffer;
int Size;
{
   FILE *fp;
   *Buffer=AllocMem(Size,MEMF_CHIP|MEMF_CLEAR);

   if(!(*Buffer))
     dprintf("LoadSample-F:No memory for sound effects");

   if(!(fp=fopen(name,"r")))
      dprintf("LoadSample-F:Bad hit opening effect file");
 
   fread(*Buffer,1,Size,fp);

   fclose(fp);
}

 
void LoadSounds()
{
   LoadSample("Highbass.sfx",&HighBassSample,HIGHBASSSIZE);
   LoadSample("token.sfx",&TokenSample,TOKENSIZE);
   LoadSample("laser.sfx",&LaserSample,LASERSIZE);
   LoadSample("explosion.sfx",&ExplosionSample,EXPLOSIONSIZE);
   LoadSample("bass1.sfx",&Bass1Sample,BASS1SIZE);
   LoadSample("Cymbal.sfx",&CymbalSample,CYMBALSIZE);
   LoadSample("SynthSnare.sfx",&SynthSnareSample,SYNTHSNARESIZE);
   LoadSample("bassGuitar.sfx",&BassGuitarSample,BASSGUITARSIZE);
   LoadSample("tube.sfx",&SynthSample,SYNTHSIZE);
}
#ifdef qwerty
void UnloadSounds()
{
  if(HighBassSample) FreeMem(HighBassSample,HIGHBASSSIZE);
  if(Bass1Sample) FreeMem(Bass1Sample,BASS1SIZE);
  if(CymbalSample) FreeMem(CymbalSample,CYMBALSIZE);
  if(SynthSnareSample) FreeMem(SynthSnareSample,SYNTHSNARESIZE);
  if(BassGuitarSample) FreeMem(BassGuitarSample,BASSGUITARSIZE);
  if(SynthSample) FreeMem(SynthSample,SYNTHSIZE);
  if(TokenSample) FreeMem(TokenSample,TOKENSIZE);
  if(LaserSample) FreeMem(LaserSample,LASERSIZE);
  if(ExplosionSample) FreeMem(ExplosionSample,EXPLOSIONSIZE);
}
#endif

/* Chunk points to an INS1 chunk */

void LoadInstrument(fp,chunk)
FILE *fp;
struct ChunkHeader *chunk;
{
   RefInstrument MyInstr;
   char *name,*t;
   char Buff[32];
   char *FileName[50];
   int i;
   FILE *fp2;
   fread(&MyInstr,chunk->ckSize,1,fp);

   name=&MyInstr.name[0];
   t=Buff;
   for(i=4;i<chunk->ckSize;++i)
      *t++=*name++;
   *t='\0';
   if(chunk->ckSize&1)
      fseek(fp,1,1);	/* Skip zero pad byte */
   FileName[0]='\0';
   strcpy(FileName,"Music:"); /* is Music:*.ss */
   strcat(Buff,".ss");
   strcat(FileName,Buff);
   
#ifdef NEVER
   if(!(fp2=fopen(FileName,"r")))
      DoAnAlert("LoadInstrument-F: Can't open instrument file");
#endif      
}


/******************************************************************
 * This loads in a track from the music file                      *
 ********************************************************_-=BN=-_**
 *							  -=^^=- */

void LoadTrack(fp,TrkNo,chunk)
FILE *fp;
int TrkNo;
struct ChunkHeader *chunk;
{
   SEvent *Trk;

   if(!(Trk=AllocMem(chunk->ckSize,MEMF_CLEAR)))
      dprintf("LoadTrack-F: No memory for track");
   
   fread(Trk,chunk->ckSize,1,fp);
   
   Track[TrkNo].Track=Trk;
   Track[TrkNo].Length=chunk->ckSize;


}

void UnLoadTracks()
{
   int i;
   for(i=0;i<4;++i)
      if(Track[i].Length)
         FreeMem(Track[i].Track,Track[i].Length);
}

void InitialiseMusic()
{
   int i,j;
   int x;
   /* Initialise Frequency table */

   NoteLength[0]=96;	/* #ticks for a full Note 	*/
   for(j=1;j<8;j++)
      NoteLength[j]=NoteLength[j-1]>>1; /* Half the last one */

}

/*************************************************
 * This routine loads in music from SONIX        *
 ***************************************_-=BN=-_*/
 
void LoadMusic()
{
   FILE *fp;
   struct ChunkHeader chunk;
   SEvent Event;
   SNote  *Note;
   int CurTrak;
   

   if(!(fp=fopen("beat.smus","r"))) {
      dprintf("LoadMusic-F: Could'nt open music file\n");
      exit();
   }
   
   fread(&chunk,sizeof(chunk),1,fp);

   if(chunk.ckID!=ID_FORM)
      dprintf("LoadMusic-F: Can't find FORM in file\n");
   
   fseek(fp,4,1);	/* Skip SMUS thingy */

   do {
      fread(&chunk,sizeof(chunk),1,fp);

      if(chunk.ckID!=ID_SHDR)
         fseek(fp,chunk.ckSize,1);	/* Skip chunk */
   } while (chunk.ckID!=ID_SHDR);
   
   fread(&ScoreHeader,sizeof(ScoreHeader),1,fp);

   for(CurTrak=0;CurTrak<4;++CurTrak)
      Track[CurTrak].Length=0;

   CurTrak=0;

   do {
      fread(&chunk,sizeof(chunk),1,fp);

      if(chunk.ckID==ID_NAME) {	/* Name can be padded out with a zero */
         if(chunk.ckSize&1)
            ++chunk.ckSize;
         fseek(fp,chunk.ckSize,1);
      } else if(chunk.ckID==ID_INS1)
         LoadInstrument(fp,&chunk);
      else if(chunk.ckID==ID_TRAK)
         LoadTrack(fp,CurTrak++,&chunk);
      else         
         fseek(fp,chunk.ckSize,1);	/* Skip unwanted chunk */
   } while(CurTrak!=ScoreHeader.ctTrack);
   
   fclose(fp);
   
   InitialiseMusic();
}

void UnLoadMusic()
{
   UnLoadTracks();
}

BYTE SineWave[8]={0,90,127,90,0,-90,-127,-90};
BYTE TriangleWave[8]={0,63,127,63,0,-63,-127,-63};

void NextNoteIn(flag,EQE)
UBYTE flag;
SCH_PEQE EQE;
{
   register int period;
   period=NoteLength[flag&NOT_division];
   if(flag&NOT_dot)
      period=(period*3)>>1;
   ENQUEUEEVENT(EQE,period);
}

char qwerty1[50];


void MusicMachine(Track,EQE)
TrackDesc *Track;
SCH_PEQE EQE;
{ /* Music Machine */
   register SNote *Note;
   register SEvent *CurIn;
   register UWORD  Freq;
   register ULONG  t;
   while(1) {
      custom.dmacon=(UWORD)1<<Track->Channel;
      for (quiz = 0;quiz<50;quiz++)quiz++;

      
      do{
         if(Track->SndPC<<1==Track->Length){	/* Make tune repeat */
            Track->SndPC=0;
         }
         CurIn=&Track->Track[Track->SndPC++];    
         if (CurIn->sID==SID_Instrument)
             switch (CurIn->data){
                case 1 : Track->SamplePtr=(UWORD *)CymbalSample;
			 Track->SampleLength=(UWORD)CYMBALSIZE>>1;
                         break;
                case 3 : Track->SamplePtr=(UWORD *)BassGuitarSample;
			 Track->OctavePtr = (UWORD *)&Octave2;
                         Track->SampleLength=(UWORD)BASSGUITARSIZE>>1;
			 break;
                case 2 : Track->SamplePtr=(UWORD *)SynthSnareSample;
			 Track->SampleLength=(UWORD)SYNTHSNARESIZE>>1;
                         break;
                case 0 : Track->SamplePtr=(UWORD *)Bass1Sample;
			 Track->OctavePtr = (UWORD *)&Octave1;
                         Track->SampleLength=(UWORD)BASS1SIZE>>1;
                         break;
                case 4 : Track->SamplePtr=(UWORD *)HighBassSample;
			 Track->SampleLength=(UWORD)HIGHBASSSIZE>>1;
                         break;
                default : Track->SamplePtr=(UWORD *)BassGuitarSample;
			 Track->SampleLength=(UWORD)BASSGUITARSIZE>>1;
                         break;
             }
      }while (CurIn->sID>128); /* Loop Until we get a note or rest */

      Note=(SNote *)CurIn;
      
      if(Note->tone==SID_Rest) {		/* Rest Note */
         custom.dmacon=(UWORD)1<<Track->Channel;
         NextNoteIn(Note->flags,EQE);		/* Wait until rest done */
         break;
      }
 
      if(Note->tone>SID_FirstNote||Note->tone<SID_LastNote) { 
      						/* Then its a note 	*/
         custom.aud[Track->Channel].ac_ptr=Track->SamplePtr;
         custom.aud[Track->Channel].ac_len=Track->SampleLength;
         custom.aud[Track->Channel].ac_vol=Track->Volume;
         custom.aud[Track->Channel].ac_per=Track->OctavePtr[Note->tone];
         custom.dmacon=(UWORD)0x8000+(1<<Track->Channel); /* Enable Chan */
         NextNoteIn(Note->flags,EQE);
         break;
      }
   }
}

void StartMusic()
{
   int i;
   int Channel;
   
   custom.dmacon=(UWORD)15;

Track[0].Channel=1;
Track[0].OctavePtr = (UWORD *)&Octave1;
Track[0].Volume=50;

Track[1].Channel=2;
Track[1].OctavePtr = (UWORD *)&Octave2;
Track[1].Volume=50;

Track[2].Channel=3;
Track[2].OctavePtr = (UWORD *)&Octave2;
Track[2].Volume=50;


   for(i=0;i<3;i++)
      if(Track[i].Length) {
         Track[i].SndPC=0;
         CreateEvent(MusicMachine,&Track[i],1,"MusicMachine");
      }
}

UWORD Octave1[]={
   7550,
   7127,
   6727,
   6349,
   5993,
   5656,
   5339,
   5039,
   4756,
   4489,
   4237,
   4000,
   3775,
   3563,
   3363,
   3174,
   2996,
   2828,
   2669,
   2519,
   2378,
   2244,
   2118,
   2000,
   1887,
   1781,
   1681,
   1587,
   1498,
   1414,
   1334,
   1259,
   1189,
   1122,
   1059,
   1000,
   943,
   890,
   840,
   793,
   749,
   707,
   667,
   629,
   594,
   561,
   529,
   500,
   471,
   445,
   420,
   396,
   374,
   353,
   333,
   314,
   297,
   280,
   264,
   250,
   235,
   222,
   210,
   198,
   187,
   176,
   166,
   157,
   148,
   140,
   132,
   125,
   117,
   111,
   105,
   99,
   93,
   88,
   83,
   78,
   74,
   70,
   66,
   62,
   58,
   55,
   52,
   49,
   46,
   44,
   41,
   39,
   37,
   35,
   33,
   31,
   29,
   27,
   26,
   24,
   23,
   22,
   20,
   19,
   18,
   17,
   16,
   15,
   14,
   13,
   13,
   12,
   11,
   11,
   10,
   9,
   9,
   8,
   8,
   7,
   7,
   6,
   6,
   6,
   5,
   5,
   5,
};
UWORD Octave2[]={
   2595,
   2449,
   2312,
   2182,
   2060,
   1944,
   1835,
   1732,
   1635,
   1543,
   1456,
   1375,
   1297,
   1224,
   1156,
   1091,
   1030,
   972,
   917,
   866,
   817,
   771,
   728,
   687,
   648,
   612,
   578,
   545,
   515,
   486,
   458,
   433,
   408,
   385,
   364,
   343,
   324,
   306,
   289,
   272,
   257,
   243,
   229,
   216,
   204,
   192,
   182,
   171,
   162,
   153,
   144,
   136,
   128,
   121,
   114,
   108,
   102,
   96,
   91,
   85,
   81,
   76,
   72,
   68,
   64,
   60,
   57,
   54,
   51,
   48,
   45,
   42,
   40,
   38,
   36,
   34,
   32,
   30,
   28,
   27,
   25,
   24,
   22,
   21,
   20,
   19,
   18,
   17,
   16,
   15,
   14,
   13,
   12,
   12,
   11,
   10,
   10,
   9,
   9,
   8,
   8,
   7,
   7,
   6,
   6,
   6,
   5,
   5,
   5,
   4,
   4,
   4,
   4,
   3,
   3,
   3,
   3,
   3,
   2,
   2,
   2,
   2,
   2,
   2,
   2,
   1,
   1,
};
UWORD Octave3[]={
   4200,
   3964,
   3741,
   3531,
   3333,
   3146,
   2970,
   2803,
   2645,
   2497,
   2357,
   2225,
   2100,
   1982,
   1870,
   1765,
   1666,
   1573,
   1485,
   1401,
   1322,
   1248,
   1178,
   1112,
   1050,
   991,
   935,
   882,
   833,
   786,
   742,
   700,
   661,
   624,
   589,
   556,
   525,
   495,
   467,
   441,
   416,
   393,
   371,
   350,
   330,
   312,
   294,
   278,
   262,
   247,
   233,
   220,
   208,
   196,
   185,
   175,
   165,
   156,
   147,
   139,
   131,
   123,
   116,
   110,
   104,
   98,
   92,
   87,
   82,
   78,
   73,
   69,
   65,
   61,
   58,
   55,
   52,
   49,
   46,
   43,
   41,
   39,
   36,
   34,
   32,
   30,
   29,
   27,
   26,
   24,
   23,
   21,
   20,
   19,
   18,
   17,
   16,
   15,
   14,
   13,
   13,
   12,
   11,
   10,
   10,
   9,
   9,
   8,
   8,
   7,
   7,
   6,
   6,
   6,
   5,
   5,
   5,
   4,
   4,
   4,
   4,
   3,
   3,
   3,
   3,
   3,
   2,
};
