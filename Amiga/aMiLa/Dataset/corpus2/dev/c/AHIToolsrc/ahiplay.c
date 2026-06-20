/*      AHI Output Tool

        G. Jones
*/

#include <libraries/dos.h>
#include <proto/exec.h>
#include <proto/graphics.h>             /* Includes for the tool */
#include <proto/intuition.h>
#include <string.h>
#include <intuition/intuition.h>

#include <devices/ahi.h>
#include <exec/exec.h>
#include <proto/ahi.h>                 /* Includes for the AHI code */
#include <proto/dos.h>
#include <proto/exec.h>

#include <exec/libraries.h>
#include <exec/types.h>
#include <clib/debug_protos.h>
#include <exec/memory.h>                  /* Includes for the port code */
#include <dos/dos.h>
#include <clib/exec_protos.h>
#include <clib/alib_protos.h>
#include <clib/intuition_protos.h>
#include <stdio.h>
#include <ctype.h>

                                        //*********************** Aiff includes
#include <dos/dos.h>
#include <libraries/iffparse.h>
#include <proto/iffparse.h>

#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <dos.h>


// ********************* Other includes and User includes

#include "bars.h"       // B&Pipes programming header file
#include "notes.h"      // Lookup table for sound pitches
#include "aiff.h"       // AIFF loading header
#include "ahigui.c"     // GUI file for the tool
#include "amigaimage.c" // Bitmap image
#include "revimage.c"   // Bitmap image
#include "speakerimage.c"  // Bitmap image

#include "slidercode.c" // Functions for displaying slider values

#define ID_AHIT 0x41484954  // The unique ID for this tool

#define FILES_DELETE    1
#define FILES_OPEN      2
#define FILES_SAVE      4
#define FILES_TEST      8    // File open modes
#define FILES_TYPE      16
#define FILES_PATH      32
#define  ID_AIFF     MAKE_ID('A','I','F','F')
#define  ID_AIFC     MAKE_ID('A','I','F','C')    // ID's used to determine the
#define  ID_COMM     MAKE_ID('C','O','M','M')    // type of file being read
#define  ID_SSND     MAKE_ID('S','S','N','D')
#define  ID_NONE     MAKE_ID('N','O','N','E')
#define  ID_8SVX     MAKE_ID('8','S','V','X')
#define  ID_BODY     MAKE_ID('B','O','D','Y')
#define  ID_VHDR     MAKE_ID('V','H','D','R')
#define  ID_CHAN     MAKE_ID('C','H','A','N')

#define EQ ==
#define MINBUFFLEN 10000

#define CHANNELS   16       // Number of channels to allocate
#define MAXSAMPLES 16       // Maximum allowed samples

#define FILELENGTH 100

///

// Variables **************************************************

APTR samples[MAXSAMPLES] = { 0 };

struct Library      *AHIBase;
struct Library      *IFFParseBase;
struct MsgPort      *AHImp     = NULL;
struct AHIRequest   *AHIio     = NULL;
BYTE                 AHIDevice = -1;
struct AHIAudioCtrl *actrl     = NULL;
struct AHIEffMasterVolume *mveffect=NULL;

struct {
        struct AHIEffDSPMask mask;
        UBYTE                echomask[CHANNELS];
       } maskeffect = {0};

struct AHIDSPEcho      *dspecho=NULL;

struct Image ahiimg;

struct Event *controllers;
extern UWORD chip ahi[];
extern struct Functions *functions;
extern long notefreq[];

BOOL   revon;
BOOL   loopsnd[17];
BOOL   ahiopen;
BOOL   alldone;
BOOL   soundplaying;
BOOL   sampleloaded;
BOOL   audio=FALSE;
BOOL   play=FALSE;
BOOL   stereo[MAXSAMPLES];
UWORD  samps[32];
UWORD  samps2;
char   *filen[100];
char   *filenames[32];
long   fcounter[CHANNELS];
long   file;
long   mastervol;
UWORD  prevchann;
UWORD  chann;
UWORD  stoppedchann;
UWORD  counter;
UBYTE  echomask[CHANNELS];

long echmix;
long feedback;
long xmix;
ULONG edelay;


unsigned char playednotes[16];

UWORD  channels[16];
ULONG   *samplelen;
ULONG   samplelength[32];
ULONG  samplestart;
UWORD  currentchannel=0;
char   *strbuff[32];
char   *samplenames[32];
short  tempnum;
long   fadeoutspeed[MAXSAMPLES];
long   fadeinspeed[MAXSAMPLES];
BOOL   channplay[17];
char   modename[34];
long   slen;

APTR *samplearray=samples;

// ************************************************************


// Prototypes *************************************************

BOOL  OpenAHI(void);
void  CloseAHI(void);
BOOL AllocAudio(struct AHITool *tool);
void  FreeAudio(void);
UWORD LoadSample(char * , UWORD channel, struct AHITool *);
void  UnloadSample(UWORD );
static struct Tool *loadtool(long file,long size);

struct FileData *readhdr(struct IFFHandle *iff, struct AHITool *tool);
void closeiff(struct IFFHandle *iff);
BOOL openiff(struct IFFHandle *iff, char *name,int mode);
long ex2long(extended *ex);

void playsound(UWORD , long , ULONG ,ULONG , UWORD ,
               ULONG , LONG, struct AHITool * );

void stopsound(UWORD , ULONG, ULONG);
void load(struct AHITool *tool);

LONG calcpitchbend(LONG pitchb, LONG nfreq,
                   struct AHITool *tool);

void setmastervol(struct AHITool *tool);
void setstrings(struct AHITool *tool);
void canceleffects(struct AHITool *tool);
void ReloadSample(struct AHITool *tool);
void cleartool(struct AHITool *tool);
struct Tool *createtool(struct AHITool *copy);
static void deletetool(struct AHITool *tool);
void removetool(struct AHITool *tool);
void reAllocAudio(struct AHITool *tool);
void allocaudioload(struct AHITool *tool);
char *strippath(char *name);
void AHImodeinfo(struct AHITool *tool);
void drawline(struct Window *window,int x, int y, int endx, int endy);
void clearsample(struct AHITool *tool, int x);
void findloop(UWORD *, BOOL start, struct AHITool *tool);
void stopplay(struct AHITool *tool);
void setecho(struct AHITool *tool);
void setdspmask(struct AHITool *tool);


// ***********************************************************

typedef struct AHITool {
                      struct Tool tool;
                      long mastervol;
                      char *filen[100];
                      BOOL echo[MAXSAMPLES];
                      BOOL noteplaying[17];
                      BOOL scratchmode;
                      BOOL loopm;
                      BOOL sample[CHANNELS+1];

                      int  scratchlength;
                      int  scratchrange;
                      int  scratchstart;
                      long volume[17];
                      long pan[17];
                      long finetune;

                      long mix;
                      long feedback;
                      long xmix;

                      long pbend;
                      long pbend2;
                      long pbend3;
                      long pbendr;

                      unsigned char channel;
                      ULONG offset;
                      char *samplename[32];
                      char *labels[32];

                      ULONG audiomode;
                      ULONG mixfreq;
                      ULONG delay;
                      UWORD multich;
                      ULONG samplelength[32];
                      LONG temp;
                      ULONG playvol[17];
                      ULONG channvol;
                      ULONG playvol2[17];
                      UWORD loop;
                      UWORD channels[17];
                      BOOL  channplay[17];
                      ULONG samplestart;
                      ULONG loopstart[17];
                      ULONG loopend[17];
                      UWORD *loopst;
                      UWORD *looped;
                      LONG  length;
                      unsigned char playednotes[20];
                      unsigned char playedvel  [20];
                      unsigned char oldnotes[20];
                      BOOL fade;
                      long fadeoutspd;
                      long fadeinspd;
                      char buffer[32];
                                    } AHITool;

struct EasyStruct badaiff =
    {
    sizeof(struct EasyStruct),
    0,
    "Error loading sample",
    "Error loading sample %s\nBad or unsupported AIFF file",
    "Ok",
    };

struct EasyStruct readerror =
    {
    sizeof(struct EasyStruct),
    0,
    "Read Error",
    "Error reading file %s",
    "Ok",
    };

struct EasyStruct flush =
    {
    sizeof(struct EasyStruct),
    0,
    "Flush sounds?",
    "Clear Current or All sounds?",
    "Current|All|CANCEL",
    };

struct EasyStruct ahifail =
    {
    sizeof(struct EasyStruct),
    0,
    "AHI Sample Player",
    "AHI is already open by another Application.\nPlease close the other Application and Retry.",
    "Retry",
    };

struct EasyStruct ahiopenfail =
    {
    sizeof(struct EasyStruct),
    0,
    "AHI Sample Player",
    "AHI.device ver 3 could not be opened\n Please check your AHI installation\n",
    "Retry",
    };

struct EasyStruct ifferror =
    {
    sizeof(struct EasyStruct),
    0,
    "IFF Parse Error",
    "IFF Parse Error",
    "Ok",
    };

struct EasyStruct filelost =
    {
    sizeof(struct EasyStruct),
    0,
    "Unable to find file",
    "Unable to load sample, the path or filename\nmay of changed, please select new sound.",
    "Ok",
    };


extern printf();


struct {
  BOOL      FadeOut;
  BOOL      FadeIn;
  BOOL      Loop;
  Fixed     Volume;
  Fixed     Currvol;
  Fixed     Initialvol;
  ULONG      loopstart;
  UWORD     multich;
  ULONG      loopend;
  sposition Position;
} channelstate[CHANNELS*2];

///

/* -------------------------------------  --------------------------------------

   Player function, interrupt based function for fading the volume of the sound
   in/out. Also used to set the loop points.

*/

__asm __interrupt __saveds static void PlayerFunc(
    register __a0 struct Hook *hook,           // Hook to be used
    register __a2 struct AHIAudioCtrl *actrl,  // Audio structure to be used
    register __a1 APTR  ignored) {

  int i;           // for the counter, used for scanning the channels


 for (i=0;i<CHANNELS;i++){      // Scan all channels

                                       // If fadein (attack) is switched on
 if (channelstate[i].FadeIn) {
                          fcounter[i]+=fadeinspeed[channelstate[i].multich];
                     //     fcounter[i]+=fcounter/2;

if (fcounter[i]<1584){
                  channelstate[i].Currvol=(channelstate[i].Initialvol
                  /1584) * fcounter[i];    // Divide the volume by 1584
                                           // and then multiply it by
                                           // the current fcounter value
                 }
            else {        // If the fade is complete or off
                          // set the playvolume to the value calculated
                          // in the NOTEON case.

                  channelstate[i].Currvol=channelstate[i].Initialvol; // Set vol to initial
                  channelstate[i].FadeIn = FALSE;  // Fade is complete
                  fcounter[i]=0;                   // Reset the fcounter
                 }
                   AHI_SetVol(i, channelstate[i].Currvol, channelstate[i].Position,
                   actrl, AHISF_IMM);         // Alter the volume
channelstate[i].Volume=channelstate[i].Currvol;   // Set the volume to be used by
    }                                             // Fadeout


 if (channelstate[i].FadeOut) {      // If the note has been released and decay is on
                                     // fade out the volume.

      channelstate[i].Volume = (channelstate[i].Volume   // Volume=Volume * speed/200
      * fadeoutspeed[channelstate[i].multich]+1) / 200;  // Speed is set by the slider
                                                         // 0-200
      if(channelstate[i].Volume == 0) {   // If the volume has reached Zero
        channelstate[i].FadeOut = FALSE;  // Fade out is done
         AHI_SetSound(i, AHI_NOSOUND,0,0, actrl, AHISF_IMM);      // Stop sample
         channels[i]=NULL;

      }

      AHI_SetVol(i, channelstate[i].Volume, channelstate[i].Position,
          actrl, AHISF_IMM);   // Set the volume
      }

 if ((channelstate[i].Loop==TRUE)){    // If the LOOP button is on
     AHI_SetSound(i,channels[i],       // Set the loop using the sound
     channelstate[i].loopstart,        // stored in channels[] and the
     channelstate[i].loopend,actrl,0L); // Loop start and end stored when
     }                                  // The start and end slider were dragged

 else AHI_SetSound(i,AHI_NOSOUND,NULL,NULL,actrl,NULL);  // Otherwise just stop
                                                         // the sound when it's finished

     }

  return;
}

struct Hook PlayerHook = {       // The hook that calls the Playerfunc
  0,0,
  (ULONG (* )()) PlayerFunc,
  NULL,
  NULL,
};

/* -------------------------------------  --------------------------------------

 Process event code, this is the core engine of the program, this receives the
 note and controller events sent by the sequencer and acts on each event type
 accordingly

*/


struct Event *processeventcode(struct NoteEvent *event)  // Function is given the event
{                                                        // in it's arguments

UWORD counter2,loop;// These are used in the effect and noteon/off loops to
                    // perform changes to each channel

struct AHITool *tool = (struct AHITool *) event->tool; // Tool structure is made

    controllers=event;         // Copy the event for use by Control Change messages

    event->tool = tool->tool.next;  // Pass the event to the next tool in the linked
                                    // list

    if (!tool->tool.touched) {            // Once the tool is in the pipeline
        tool->tool.touched = TOUCH_INIT;  // if it hasn't been initilised
    }                                     // then do so

//*******************************************************************************

if (audio) {               // If the audio channels have been allocated

switch (event->status) {   // Case statement, select action by event status


case  MIDI_NOTEON:         // A note has been pressed
{
///

ULONG temp2;
ULONG temp3;
chann=0;

while (channplay[chann]) {
            chann++;
            if (chann==CHANNELS) break;
}


tool->oldnotes[chann]=event->value;    // Store event on this channel into the notes array
tool->playednotes[chann]=event->value; // As above, but into a different array.
tool->playedvel[chann]=event->velocity;// Store the velocity on this channels into array
channplay[chann]=TRUE;                 // A note has been started, set the flag for this channel


channels[chann]=tool->multich;        // The instrument for this channel is stored

channelstate[chann].FadeOut=FALSE;    // No fadeout yet, we wait until a note is played

// Below, we calculate the play volume for this multipart by taking the note velocity
// multiplying it by the volume set for this part, dividing the result by the range of
// the part volume, we then convert the integer value to a 'fixed' number.

tool->playvol[tool->multich]=
           (((event->velocity*tool->volume[tool->multich])/127)*65536/127);

// The channel volume is also calculated, this is used by the Control change 7 controller

tool->channvol=(((event->velocity*65536)/127)
      *tool->volume[tool->multich])/127;


channelstate[chann].Initialvol=tool->playvol[tool->multich];  // Set the initial volume for fade FX
channelstate[chann].Currvol=tool->playvol[tool->multich];     // Set the current volume for fade FX
channelstate[chann].Volume=tool->playvol[tool->multich];      // Set the volume for the fade FX
channelstate[chann].Position=(tool->pan[tool->multich]*65536/128); // Set pan pos for the fade FX
channelstate[chann].loopstart=(tool->loopstart[tool->multich]*10); // Set the loop start position
                                                                   // for the loop effect

temp3=samplelength[tool->multich]-(tool->loopend[tool->multich]*10); // Calculate the loop lengths
temp2=(samplelength[tool->multich]-temp3)-tool->samplestart;
temp3=temp2-(tool->loopstart[tool->multich]*10);

channelstate[chann].loopend = temp3;           // The loop will end at this point
channelstate[chann].multich=tool->multich;     // The multi channel will be used to find which channel
                                               // to loop
    if (tool->loopm) channelstate[chann].Loop=TRUE;      // If the loop button is enabled, turn on loop
    else             channelstate[chann].Loop=FALSE;    // otherwise, no looping


if (tool->fadeinspd>0)  // If we've set the fadein speed to above 0, we set initial play volume
{                       // to zero, so the fade is clean and starts at zero

        fcounter[chann]=0;
        channelstate[chann].FadeIn=TRUE;

        playsound(tool->multich,(notefreq[event->value]*(100+tool->finetune-30))/100,0x0,
                  tool->pan[tool->multich]*65536/128,chann,tool->samplestart,
                  temp2,tool);

    }

// Otherwise we set the start volume to the previous calculated value

        else playsound(tool->multich,(notefreq[event->value]*(100+tool->finetune-30))/100,
             tool->playvol[tool->multich],tool->pan[tool->multich]*65536/128,chann,tool->samplestart,
             temp2,tool);
///
}
        break;


case MIDI_NOTEOFF:    // Note has been released, turn off sound and fade out (if enabled)
///
counter2=0;     // Start at channel 0

// Below, the note number 0-127 is compared with the value stored in the 'playednotes' array
// when the match is made, the counter will be set to the sound channel that the note is
// using. A safety check is included, although it shouldn't be needed.

while(event->value!=tool->playednotes[counter2]){
                                                  counter2++;
    if (counter2>CHANNELS) {
                            counter2=chann;
                            break;
                           }
}

// Below, we set all the flags to their off state, if we've used a fade in, it's cancelled
// If we've selected a fadeout, then it is performed when we set the FadeOut flag to true

        tool->playednotes[counter2]=NULL;
        channplay[counter2]=FALSE;

        channelstate[counter2].FadeIn=FALSE;
        channelstate[counter2].FadeOut=TRUE;

        break;

//*******************************************************************************

///
case MIDI_CCHANGE:     // Control change messages, these are controllers used to
                       // perform effects, such as volume change and panning
 switch(controllers->byte1) {            // We select the controller using a case type
                                            // statement
   case 7:  // Volume for this channel/part
///
   for (loop=0;loop<CHANNELS;loop++) {       // We perform the changes on all channels
       if (channels[loop]==tool->multich) {  // If the current part is used by this
                                             // channel, perform the changes

// Below, we calculate the new channel volume
      tool->channvol=(((tool->playedvel[loop]*65536)/128)*controllers->byte2)/128;

// Below, we set the changes using a call to the AHI_SetVol function, AHISF_IMM is set, so
// the changes are immediate

 AHI_SetVol(loop,tool->channvol,tool->pan[tool->multich]*65536/128,actrl,AHISF_IMM);
 channelstate[loop].Volume=tool->channvol; // Set the volume variable used by the fade
                                           // effects to the new volume, otherwise
                                           // the fade will leap to the old value
                                          }
                                    }
 tool->volume[tool->multich]=controllers->byte2; // store the value of the slider for
                                                 // use in calculating the next
                                                 // note play volume
          break;

//*******************************************************************************
///
 case 15:
///           // Just set the finetine value to the value of the controller
           // As the finetune has a smaller range, we scale it to that

           tool->finetune=(controllers->byte2*60/127);  // Finetune
 break;


//*******************************************************************************
///
 case 19:                  //Offset
///
// Many calulations needed here, the loop and offset aren't compatible yet

// Below, we calculate the position were the offset/scratch should begin by
// taking the length of the current sample, multiplying it by the value of the
// controller added to the scratch offset, this is then divided by 128 added to
// the scratch offset. The result is then divided by the scratchrange+1, +1 is used
// to avoid the lethal divide by zero error.

      tool->samplestart=((tool->samplelength[tool->multich]*
          (controllers->byte2+tool->scratchstart))/(128+tool->scratchstart))
          /((tool->scratchrange+1));

// So that the samplestart part works we have to add the previous value to the samplelength minus
// the sample start, which we then multiply by the scratch start divided by 128

      tool->samplestart=tool->samplestart+((tool->samplelength[tool->multich]-tool->samplestart)
          *tool->scratchstart/128);

// If we've switched on scratch mode (realtime offset)

 if (tool->scratchmode==TRUE) {

// Below we, 1. Set the frequency and channel
//           2. Set the sound and play start position and length

     AHI_SetFreq(chann,notefreq[tool->oldnotes[chann]],actrl,AHISF_IMM);
     AHI_SetSound(chann,tool->multich,tool->samplestart,
     ((tool->samplelength[tool->multich]-tool->samplestart)
     /(tool->scratchlength+1)),actrl,AHISF_IMM);

     }
break;
///
//*******************************************************************************

 case 20:                    //scratch on/off
///
// This allows the scratchmode to be switched on/off automaticaly by a song using
// the control change controller number 20

 if (controllers->byte2>63) tool->scratchmode=TRUE; // Values 64-127 switch on
 else tool->scratchmode=FALSE;                      // Anything else switches off
 break;
 ///

//*******************************************************************************

case 10:                                  // Pan
///
// Panning works similar to the Volume controller

for (loop=0;loop<CHANNELS; loop++){        // do for all channels
     if (channels[loop]==tool->multich){   // if the current sound channel is used by this part

     tool->channvol=(((tool->playedvel[loop]*65536)/128)   // Calc the channel vol first
     *tool->volume[tool->multich]/127);

// We set the volume and panning below

AHI_SetVol(loop,tool->channvol,controllers->byte2*65536/127,actrl,AHISF_IMM);
    }
tool->pan[tool->multich]=controllers->byte2;   // Store the pan position for use by a new note
channelstate[chann].Position=controllers->byte2*65536/127; // Store pan for use by fades
   }
///
  break;
}
break;

case MIDI_PCHANGE:
       // Program changes are used to select different sounds
       // In the case of this program, they are used for just that

// Only values 0-15 are valid, so we reject anything else
                     if (controllers->byte1<16) tool->multich=controllers->byte1;
                     break;

case  MIDI_PBEND:
///
/* The Midi controller for Pitchbend is a very large number so it is stored in two bytes
   Upper and lower bits, we need just one for this program though, so a bitwise shift is used
   on the upper bit and then the lower is added on, eg.

Upper    110011

Lower   0011001                                 <---- 7

Upper is shifted to the left, 7 places ie. 1100110000000

Lower can now be added to upper                  0011001

                    Result                 1100110011001    */

tool->pbend=(controllers->byte2<<7)+controllers->byte1; // Merge upper and lower bits in one

for(loop=0;loop<CHANNELS;loop++) {

if ((channels[loop]==tool->multich)&&(!channelstate[loop].FadeOut)){

tool->pbend2=calcpitchbend(tool->pbend,notefreq[tool->playednotes[loop]]+((tool->finetune-30)*50),tool);
//tool->pbend2=tool->pbend2/12*tool->pbendr;

AHI_SetFreq(loop,tool->pbend2,actrl,AHISF_IMM);               // Playback rate

    }
   }
  break;
  ///

  } // if (audio)
}
//return event;
(*functions->freeevent)(event);

return(0);


}
extern struct NewWindow ahiNewWindowStructure1;

// ******************************************************************************************
// ******************************************************************************************
// ******************************************************************************************

void removetool(struct AHITool *tool)
{


if (mveffect){
           mveffect->ahie_Effect = AHIET_CANCEL | AHIET_MASTERVOLUME;
           AHI_SetEffect(mveffect,actrl);                          // Clear and cancel
           FreeVec(mveffect);                                      // Master volume
              }

if (dspecho){
           dspecho->ahie_Effect = AHIET_CANCEL | AHIET_DSPECHO;
           AHI_SetEffect(dspecho,actrl);                          // Clear and cancel
           FreeVec(dspecho);                                      // DSP Echo
              }

//if (maskeffect){
          // maskeffect.mask.ahie_Effect = AHIET_CANCEL | AHIET_DSPMASK;
          // AHI_SetEffect(&maskeffect,actrl);                          // Clear and cancel
          // FreeVec(&maskeffect);                                      // DSP Mask
           //   }

if (play) {
           AHI_ControlAudio(actrl,
           AHIC_Play, FALSE,
           TAG_DONE);             // If sound is being routed to the audio hardware
           play=FALSE;            // then halt it.
          }



if (audio) FreeAudio();   // If audio channels are allocated, free them

  if (IFFParseBase)   CloseLibrary(IFFParseBase);   // Close IFFParse library

  if (AHIBase)        CloseAHI();                   // Close AHI device
}


//******************************************************************************************

void edittoolcode(struct AHITool *tool) // Edit tool - opens the gui and allows the setting
{                                       // of parameters and loading of sounds
     struct Window *window;             // Allocate window structure
 struct IntuiMessage *message=NULL;     // Allocate message structure
struct StringInfo *stringinfo;          // Allocate string gadget info structure

static struct Menu TitleMenu = {
    NULL,0,0,0,0,MENUENABLED,                       // The Menu bar structure
   "AHI Sample Player Tool, © 1997 G. O. Jones.",0
};
    char text[40];                 // String used for printing to screen
    struct Gadget *gadget;         // Gadget structure
    struct NewWindow *newwindow;   // NewWindow structure
    UWORD counter;                 // Channel counter
    long class, code,answer;
    char refresh = 2;           // Refresh variable, value sets which gadgets to refresh
    int x;



    ahiNewWindowStructure1.Screen = functions->screen;  // Use B&Pipes screen
    if (tool->tool.touched & TOUCH_EDIT) {              // If tool has been opened before
        ahiNewWindowStructure1.LeftEdge = tool->tool.left; // Restore Window positions
        ahiNewWindowStructure1.TopEdge = tool->tool.top;
        ahiNewWindowStructure1.Width = tool->tool.width;
        ahiNewWindowStructure1.Height = tool->tool.height;
    }
    if (!tool->tool.touched) {    // If the tool has only just been created
if (!mveffect) mastervol=100;     // If the mastervol structure exists set vol to 100
        tool->tool.touched  = TOUCH_INIT; // Tool has now been opened, set touched to true
        tool->finetune      = 30;     // Centered, no fine tune.
        tool->scratchmode   = FALSE;  // Scratch is OFF
        tool->loopm         = FALSE;  // Loop is OFF
        tool->fade          = FALSE;  // Fade is OFF
        tool->fadeoutspd    = 0;     // Fadespeeds 0
        tool->fadeinspd     = 0;
        tool->scratchlength = 0;
        tool->scratchrange  = 0;
        tool->scratchstart  = 0;
        tool->channel       = 0;
        tool->pbend         = 0;                    // No pitchbend.
        tool->pbendr        = 0;
        tool->multich       = 0;                    // Channel 0 by default.
        tool->loopst        = 0;
        tool->looped        = 0;

//        tool->audiomode     = AHI_DEFAULT_ID;
//        tool->mixfreq       = AHI_DEFAULT_FREQ;

        setstrings(tool);  // Allocate string buffers and initialise

for (counter=0;counter<CHANNELS;counter++) {     // Set for each multichannel
            tool->volume[counter] = 127;   // Volume to max
            tool->pan[counter]    = 64;    // Pan to centre
            tool->channels[counter]=NULL;  // All channels off
            tool->loopstart[counter]=0;    // Loop points to 0
            tool->loopend[counter]=0;
            channels[counter]=NULL;
            tool->sample[counter]=FALSE;   // No samples loaded
            //echomask[counter]=AHIEDM_DRY;   // disabled
           }
 }

 newwindow = (struct NewWindow *)                // Duplicate window
     (*functions->DupeNewWindow)(&ahiNewWindowStructure1);


  if (!newwindow) return;                       // Exit if window couldn't be created
    newwindow->Screen      = functions->screen; // set screen to B&Pipes screen
    newwindow->Title       = 0;                 // No title
    newwindow->IDCMPFlags  = 0;                 // No message port flags
    newwindow->Flags      |= BORDERLESS;
    newwindow->Flags      &= ~0xF;
    newwindow->BlockPen    = 0;
    newwindow->DetailPen   = 0;
    window = (struct Window *)
        (*functions->FlashyOpenWindow)(newwindow); // Open the window

    if (!window) return;        // exit if window couldn't be created
    tool->tool.window = window; // set the tool to use this window
    SetMenuStrip(window,&TitleMenu);  // Turn on the Menu
    (*functions->EmbossWindowOn)(window,WINDOWCLOSE|WINDOWDEPTH|WINDOWDRAG, // Emboss the window
    "AHI Output v1.01 Beta",(short)-1,(short)-1,0,0); // Set window title

    // the following Emboss calls, turn on the embossed effect of the gadgets

    (*functions->EmbossOn)(window,4,1);
    (*functions->EmbossOn)(window,5,1);
    (*functions->EmbossOn)(window,30,1); // FREE sample
    (*functions->EmbossOn)(window,31,1); // load next
    (*functions->EmbossOn)(window,39,1); // load next

    (*functions->EmbossOn)(window,6,1);  // Scratch toggle button
    (*functions->EmbossOn)(window,25,1); // Loop toggle button
    (*functions->EmbossOn)(window,26,1); // Fade toggle button
    (*functions->EmbossOn)(window,34,1); // About toggle button
    (*functions->EmbossOn)(window,35,1); // About toggle button

// Slider gadgets need a slightly different function
// the parameters are, Main ID, shift left button ID. shufftright button ID, routine for displaying value
// max value and emboss mode

    (*functions->FatEmbossedPropOn)(window,3,14,15,tightroutine,301,1);
    (*functions->FatEmbossedPropOn)(window,1,8,9,tightroutine,128,1);
    (*functions->FatEmbossedPropOn)(window,2,10,11,panroutine,128,1);
    (*functions->FatEmbossedPropOn)(window,7,12,13,finetuneroutine,61,1);
    (*functions->FatEmbossedPropOn)(window,21,16,17,chanroutine,16,1);
    (*functions->FatEmbossedPropOn)(window,22,18,19,lengthroutine,21,1);
    (*functions->FatEmbossedPropOn)(window,23,200,201,lengthroutine,21,1);
    (*functions->FatEmbossedPropOn)(window,24,202,203,multiroutine,128,1);
    (*functions->FatEmbossedPropOn)(window,27,204,205,multiroutine,200,1);
    (*functions->FatEmbossedPropOn)(window,28,206,207,pitchbendroutine,12,1);
    (*functions->FatEmbossedPropOn)(window,29,208,209,attackroutine,200,1);
    (*functions->FatEmbossedPropOn)(window,32,210,211,looproutine,1,1);
    (*functions->FatEmbossedPropOn)(window,33,212,213,looproutine,1,1);
    (*functions->FatEmbossedPropOn)(window,36,214,215,tightroutine,101,1);
    (*functions->FatEmbossedPropOn)(window,37,216,217,tightroutine,101,1);
    (*functions->FatEmbossedPropOn)(window,38,218,219,tightroutine,101,1);
    (*functions->FatEmbossedPropOn)(window,40,220,221,tightroutine,401,1);


    drawline(window,4,80,527,80);    // Draw dividing line
    DrawImage(window->RPort,&amigaimage,421,227); // Draw the amiga logo
    DrawImage(window->RPort,&speakerimage,475,39); // Draw the speaker image
    tool->mastervol=mastervol;    // Set tool mastervolume to the global value
    setmastervol(tool);           // Set mastervolume
  //  setdspmask(tool);     //disabled

   for (;;) {               // infinite loop
        if (refresh) {     // if refresh > 0

// Below. the slider positions are reset/refreshed to their correct values

(*functions->ModifyEmbossedProp)(window,32,0,0,samplelength[tool->multich]/10,0,0,0);
(*functions->ModifyEmbossedProp)(window,33,0,0,samplelength[tool->multich]/10,0,0,0);

(*functions->ModifyEmbossedProp)(window,1,tool->volume[tool->multich],0,0,0,0,0);
(*functions->ModifyEmbossedProp)(window,3,mastervol,0,0,0,0,0);
(*functions->ModifyEmbossedProp)(window,2,tool->pan[tool->multich],0,0,0,0,0);
(*functions->ModifyEmbossedProp)(window,7,tool->finetune,0,0,0,0,0);
(*functions->ModifyEmbossedProp)(window,21,tool->multich,0,0,0,0,0);
(*functions->ModifyEmbossedProp)(window,22,tool->scratchlength,0,0,0,0,0);
(*functions->ModifyEmbossedProp)(window,23,tool->scratchrange,0,0,0,0,0);
(*functions->ModifyEmbossedProp)(window,24,tool->scratchstart,0,0,0,0,0);
(*functions->ModifyEmbossedProp)(window,27,tool->fadeoutspd,0,0,0,0,0);
(*functions->ModifyEmbossedProp)(window,28,tool->pbendr,0,0,0,0,0);
(*functions->ModifyEmbossedProp)(window,29,tool->fadeinspd,0,0,0,0,0);
(*functions->ModifyEmbossedProp)(window,32,tool->loopstart[tool->multich],0,0,0,0,0);
(*functions->ModifyEmbossedProp)(window,33,tool->loopend[tool->multich],0,0,0,0,0);
(*functions->ModifyEmbossedProp)(window,36,echmix,0,0,0,0,0);
(*functions->ModifyEmbossedProp)(window,37,feedback,0,0,0,0,0);
(*functions->ModifyEmbossedProp)(window,38,xmix,0,0,0,0,0);
(*functions->ModifyEmbossedProp)(window,40,edelay,0,0,0,0,0);


              (*functions->DrawEmbossedProp)(window,1);
              (*functions->DrawEmbossedProp)(window,3);
              (*functions->DrawEmbossedProp)(window,21);
              (*functions->DrawEmbossedProp)(window,22);
              (*functions->DrawEmbossedProp)(window,23);
              (*functions->DrawEmbossedProp)(window,24);
              (*functions->DrawEmbossedProp)(window,27);
              (*functions->DrawEmbossedProp)(window,28);
              (*functions->DrawEmbossedProp)(window,29);
              (*functions->DrawEmbossedProp)(window,32);
              (*functions->DrawEmbossedProp)(window,33);

              (*functions->DrawEmbossedProp)(window,36);
              (*functions->DrawEmbossedProp)(window,37);
              (*functions->DrawEmbossedProp)(window,38);
              (*functions->DrawEmbossedProp)(window,40);

              (*functions->DrawEmbossedProp)(window,2);
              (*functions->DrawEmbossedProp)(window,7);

              (*functions->SelectEmbossed)(window,6,tool->scratchmode);
              (*functions->SelectEmbossed)(window,25,tool->loopm);
              (*functions->SelectEmbossed)(window,39,tool->echo[tool->multich]);

              samplelen=&samplelength[tool->multich];

// Below, if the loopstart is greater than the loopend the loop wil play
// backwards, so the Reverse image is drawn

 if (tool->loopstart[tool->multich]>tool->loopend[tool->multich]){
   DrawImage(window->RPort,&revimage,15,310);
   revon=TRUE;
        }

// the Reverse gadget is cleared if the loopstart is less than the loopend

             if (tool->loopstart[tool->multich]<=tool->loopend[tool->multich]&&revon){
                          EraseImage(window->RPort,&revimage,15,310);
                          revon=FALSE;
                          }


 if (refresh==2) {

  stringinfo=(void *)functions->GetStringInfo(window,20); // get the contents of the gadget
  stringinfo->Buffer=strbuff[tool->multich];
  functions->RefreshGadget(window,20);         // Sample Name
  AHImodeinfo(tool);

///
    Move(window->RPort,45,68);
    SetAPen(window->RPort,1);
    SetBPen(window->RPort,0);
    SetDrMd(window->RPort,JAM2);
    sprintf(text,"%s","Mode:");
    Text(window->RPort,text,5);
                                    // Print the Audiomode name
    Move(window->RPort,90,68);
    SetAPen(window->RPort,1);
    SetBPen(window->RPort,3);
    SetDrMd(window->RPort,JAM2);
    Text(window->RPort,modename,sizeof(modename));

// *************************************************

    Move(window->RPort,29,47);
    SetAPen(window->RPort,1);
    SetBPen(window->RPort,0);
    SetDrMd(window->RPort,JAM2);         // LENGTH OF SAMPLE
    sprintf(text,"%s","Length:");
    Text(window->RPort,text,7);

    Move(window->RPort,90,47);
    SetAPen(window->RPort,1);
    SetBPen(window->RPort,3);
    SetDrMd(window->RPort,JAM2);
    sprintf(text,"%ld           ",*samplelen*2);
    Text(window->RPort,text,8);

    Move(window->RPort,160,47);
    SetAPen(window->RPort,1);
    SetBPen(window->RPort,0);
    SetDrMd(window->RPort,JAM2);    // in bytes
    sprintf(text,"%s","Bytes");
    Text(window->RPort,text,5);

    Move(window->RPort,210,47);
    SetAPen(window->RPort,1);
    SetBPen(window->RPort,3);
    SetDrMd(window->RPort,JAM2);

if (samplelength[tool->multich]!=0)
{

    sprintf(text,"%ld           ",*samplelen/48);

}
else
    sprintf(text,"%ld            ",0);

    Text(window->RPort,text,10);

    Move(window->RPort,270,47);
    SetAPen(window->RPort,1);
    SetBPen(window->RPort,0);                  // and milliseconds
    SetDrMd(window->RPort,JAM2);
    sprintf(text,"%s","milliseconds");
    Text(window->RPort,text,12);

if (stereo[tool->multich])
{
    Move(window->RPort,495,47);
    SetAPen(window->RPort,6);
    SetBPen(window->RPort,0);          // if sample is stereo print ST
    SetDrMd(window->RPort,JAM2);
    sprintf(text,"%s","ST");
    Text(window->RPort,text,2);
}

else if (!stereo[tool->multich]&&samps[tool->multich]!=AHI_NOSOUND)
{
    Move(window->RPort,495,47);
    SetAPen(window->RPort,4);
    SetBPen(window->RPort,0);        // Else print MO
    SetDrMd(window->RPort,JAM2);
    sprintf(text,"%s","MO");
    Text(window->RPort,text,2);
}

if (!tool->sample[tool->multich])
{
    Move(window->RPort,495,47);
    SetAPen(window->RPort,1);
    SetBPen(window->RPort,3);      // if no sample is loaded print --
    SetDrMd(window->RPort,JAM2);
    sprintf(text,"%s","--");
    Text(window->RPort,text,2);
}
///

// ************************************************
      }
        if (refresh==3){
        (*functions->SelectEmbossed)(window,6,tool->scratchmode);
        (*functions->SelectEmbossed)(window,25,tool->loopm);
        (*functions->SelectEmbossed)(window,39,tool->echo[tool->multich]);

                }
     }
        refresh = 0; // refresh is done, reset 'refresh'


 // Get the message from the Window
       message = (struct IntuiMessage *) (*functions->GetIntuiMessage)(window);

// Get the class of the message
        class = message->Class;

// and it's identifier
        code = message->Code;

// and the gadget
        gadget = (struct Gadget *) message->IAddress;

// check the system gadgets
        class = (*functions->SystemGadgets)(window,class,gadget,code);

// if the user has click the window close gadget
        if (class == CLOSEWINDOW) break;   // leave loop
        else if (class == GADGETDOWN) {
            class = gadget->GadgetID;    // otherwise switch on the gadget ID
            switch (class) {

        case 1 :
           tool->volume[tool->multich] = (*functions->DragEmbossedProp)(window,1);
             refresh=1;
             break;

        case 2 :
            tool->pan[tool->multich] = (*functions->DragEmbossedProp)(window,2);
            refresh=1;
            break;

        case 3 :
            mastervol = (*functions->DragEmbossedProp)(window,3);
            setmastervol(tool);
            break;

        case 4 :
            break;

        case 7 :
            tool->finetune = (*functions->DragEmbossedProp)(window,7);
            break;

        case 8 :
            tool->volume[tool->multich] = (*functions->ShiftEmbossedProp)(window,1,-1,0);
            break;

        case 9 :
            tool->volume[tool->multich] = (*functions->ShiftEmbossedProp)(window,1,1,0);
            break;

        case 10 :
            tool->pan[tool->multich] = (*functions->ShiftEmbossedProp)(window,2,-1,0);
            break;

        case 11 :
            tool->pan[tool->multich] = (*functions->ShiftEmbossedProp)(window,2,1,0);
            break;

        case 12 :
            tool->finetune = (*functions->ShiftEmbossedProp)(window,7,-1,0);
            break;

        case 13 :
            tool->finetune = (*functions->ShiftEmbossedProp)(window,7,1,0);
            break;

        case 14 :
            mastervol = (*functions->ShiftEmbossedProp)(window,3,-1,0);
            setmastervol(tool);
            break;

        case 15 :
            mastervol = (*functions->ShiftEmbossedProp)(window,3,1,0);
           setmastervol(tool);
            break;

        case 16 :
            tool->multich = (*functions->ShiftEmbossedProp)(window,21,-1,0);
            currentchannel=tool->multich;
            samplelen=&samplelength[tool->multich];
            refresh=2;
            break;

        case 17 :
            tool->multich = (*functions->ShiftEmbossedProp)(window,21,1,0);
            currentchannel=tool->multich;
            samplelen=&samplelength[tool->multich];
            refresh=2;
            break;

        case 18 :
            tool->scratchlength = (*functions->ShiftEmbossedProp)(window,22,-1,0);
            break;

        case 19 :
            tool->scratchlength = (*functions->ShiftEmbossedProp)(window,22,1,0);
                break;

        case 21 :
            tool->multich = (*functions->DragEmbossedProp)(window,21);
            currentchannel=tool->multich;
            samplelen=&samplelength[tool->multich];
            refresh=2;
            break;

        case 22 :
            tool->scratchlength = (*functions->DragEmbossedProp)(window,22);
                break;

        case 23 :
            tool->scratchrange = (*functions->DragEmbossedProp)(window,23);
            break;

        case 24 :
            tool->scratchstart = (*functions->DragEmbossedProp)(window,24);
            break;

        case 27 :
            tool->fadeoutspd = (*functions->DragEmbossedProp)(window,27);
            fadeoutspeed[tool->multich]=tool->fadeoutspd;
            break;

        case 28 :
            tool->pbendr = (*functions->DragEmbossedProp)(window,28);
            break;

        case 29 :
            tool->fadeinspd = (*functions->DragEmbossedProp)(window,29);
            fadeinspeed[tool->multich]=tool->fadeinspd;
            break;

        case 32 :
            tool->loopstart[tool->multich] = (*functions->DragEmbossedProp)(window,32);
            if (tool->loopstart[tool->multich]>tool->loopend[tool->multich]&&!revon){
            DrawImage(window->RPort,&revimage,15,310);
            revon=TRUE;
            }
            if (tool->loopstart[tool->multich]<tool->loopend[tool->multich]&&revon){
            EraseImage(window->RPort,&revimage,15,310);
            revon=FALSE;
            }
            tool->loopst=(UWORD *)(tool->loopstart[tool->multich]*10);
            break;

        case 33 :
            tool->loopend[tool->multich] = (*functions->DragEmbossedProp)(window,33);
            if (tool->loopstart[tool->multich]>tool->loopend[tool->multich]&&!revon){
            DrawImage(window->RPort,&revimage,15,310);
            revon=TRUE;
            }
            if (tool->loopstart[tool->multich]<tool->loopend[tool->multich]&&revon){
            EraseImage(window->RPort,&revimage,15,310);
            revon=FALSE;
            }
            tool->looped=(UWORD *)(tool->loopend[tool->multich]*10);
            break;

        case 36:
            echmix = (*functions->DragEmbossedProp)(window,36);
            setecho(tool);
            break;
        case 37:
            feedback = (*functions->DragEmbossedProp)(window,37);
            setecho(tool);
            break;
        case 38:
            xmix = (*functions->DragEmbossedProp)(window,38);
            setecho(tool);
            break;
        case 40:
            edelay = (*functions->DragEmbossedProp)(window,40);
            setecho(tool);
            break;


            // ********************** Arrow Buttons ************************************

                case 200 :
                    tool->scratchrange = (*functions->ShiftEmbossedProp)(window,23,-1,0);
                    break;

                case 201 :
                    tool->scratchrange = (*functions->ShiftEmbossedProp)(window,23,1,0);
                    break;

                case 202 :
                    tool->scratchstart = (*functions->ShiftEmbossedProp)(window,24,-1,0);
                    break;

                case 203 :
                    tool->scratchstart = (*functions->ShiftEmbossedProp)(window,24,1,0);
                    break;

                case 204 :
                    tool->fadeoutspd = (*functions->ShiftEmbossedProp)(window,27,-1,0);
                    fadeoutspeed[tool->multich]=tool->fadeoutspd;
                    break;

                case 205 :
                    tool->fadeoutspd = (*functions->ShiftEmbossedProp)(window,27,1,0);
                    fadeoutspeed[tool->multich]=tool->fadeoutspd;
                    break;

                case 206 :
                    tool->pbendr = (*functions->ShiftEmbossedProp)(window,28,-1,0);
                    break;

                case 207 :
                    tool->pbendr = (*functions->ShiftEmbossedProp)(window,28,1,0);
                    break;

                case 208 :
                    tool->fadeinspd = (*functions->ShiftEmbossedProp)(window,29,-1,0);
                    fadeinspeed[tool->multich]=tool->fadeinspd;
                    break;

                case 209 :
                    tool->fadeinspd = (*functions->ShiftEmbossedProp)(window,29,1,0);
                    fadeinspeed[tool->multich]=tool->fadeinspd;
                    break;

                case 210 :
                    tool->loopstart[tool->multich] = (*functions->ShiftEmbossedProp)(window,32,-1,0);
                    if (tool->loopstart[tool->multich]>tool->loopend[tool->multich]&&!revon){
                    DrawImage(window->RPort,&revimage,15,310);
                    revon=TRUE;
                    }
                    if (tool->loopstart[tool->multich]<tool->loopend[tool->multich]&&revon){
                    EraseImage(window->RPort,&revimage,15,310);
                    revon=FALSE;
                    }
                    tool->loopst=(UWORD *)(tool->loopstart[tool->multich]*10);
                    break;

                case 211 :
                    tool->loopstart[tool->multich] = (*functions->ShiftEmbossedProp)(window,32,1,0);
                    if (tool->loopstart[tool->multich]>tool->loopend[tool->multich]&&!revon){
                    DrawImage(window->RPort,&revimage,15,310);
                    revon=TRUE;
                    }
                    if (tool->loopstart[tool->multich]<tool->loopend[tool->multich]&&revon){
                    EraseImage(window->RPort,&revimage,15,310);
                    revon=FALSE;
                    }
                    tool->loopst=(UWORD *)(tool->loopstart[tool->multich]*10);
                    break;

                case 212 :
                    tool->loopend[tool->multich] = (*functions->ShiftEmbossedProp)(window,33,-1,0);
                    if (tool->loopstart[tool->multich]>tool->loopend[tool->multich]&&!revon){
                    DrawImage(window->RPort,&revimage,15,310);
                    revon=TRUE;
                    }
                    if (tool->loopstart[tool->multich]<tool->loopend[tool->multich]&&revon){
                    EraseImage(window->RPort,&revimage,15,310);
                    revon=FALSE;
                    }
                    tool->looped=(UWORD *)(tool->loopend[tool->multich]*10);
                    break;

                case 213 :
                    tool->loopend[tool->multich] = (*functions->ShiftEmbossedProp)(window,33,1,0);
                    if (tool->loopstart[tool->multich]>tool->loopend[tool->multich]&&!revon){
                    DrawImage(window->RPort,&revimage,15,310);
                    revon=TRUE;
                    }
                    if (tool->loopstart[tool->multich]<tool->loopend[tool->multich]&&revon){
                    EraseImage(window->RPort,&revimage,15,310);
                    revon=FALSE;
                    }
                    tool->looped=(UWORD *)(tool->loopend[tool->multich]*10);
                    break;
                case 214 :
                    echmix = (*functions->ShiftEmbossedProp)(window,36,-1,0);
                    setecho(tool);
                    break;
                case 215 :
                    echmix = (*functions->ShiftEmbossedProp)(window,36,1,0);
                    setecho(tool);
                    break;
                case 216 :
                    feedback = (*functions->ShiftEmbossedProp)(window,37,-1,0);
                    setecho(tool);
                    break;
                case 217 :
                    feedback = (*functions->ShiftEmbossedProp)(window,37,1,0);
                    setecho(tool);
                    break;
                case 218 :
                    xmix = (*functions->ShiftEmbossedProp)(window,38,-1,0);
                    setecho(tool);
                    break;
                case 219 :
                    xmix = (*functions->ShiftEmbossedProp)(window,38,1,0);
                    setecho(tool);
                    break;
                case 220 :
                    edelay = (*functions->ShiftEmbossedProp)(window,40,-1,0);
                    setecho(tool);
                    break;
                case 221 :
                    edelay = (*functions->ShiftEmbossedProp)(window,40,1,0);
                    setecho(tool);
                    break;

                default: break;
      }
}
        else if (class == GADGETUP) {

            class = gadget->GadgetID;

 switch (class) {

case 4:
         functions->doscall(load,tool);        // Load button
         if (tool->samplename[tool->multich]!="None") refresh=2;

    break;

//***********************************************************************

 case 5:
canceleffects(tool);
functions->doscall(reAllocAudio,tool);
setmastervol(tool);
setecho(tool);

if (audio) refresh=2;

              break;
 case 6:
              tool->scratchmode=!tool->scratchmode;
              refresh=3;
              break;
 case 20:                                              // String gadget
              //strbuff[tool->multich]=tool->samplename[tool->multich];

              break;
 case 25:                                              // Loop button
              tool->loopm=!tool->loopm;
              loopsnd[tool->multich]=!loopsnd[tool->multich];
              refresh=3;
              break;
 case 26:                                              // Pan reset button
              tool->pan[tool->multich]=64;
              refresh=1;
              break;

 case 30:

answer=EasyRequest(functions->window, &flush, NULL,NULL,NULL);

switch(answer) {

         case 1:
                clearsample(tool,tool->multich);
                refresh=2;
                break;
         case 2:


                for (x=0;x<16;x++)
                    {
                     clearsample(tool,x);
                    }

                refresh=2;
                break;
        case 3:
                break;

              }
 break;

 case 31:

  functions->doscall(load,tool);        // Load Next button

if (tool->samplename[tool->multich]!="None") refresh=2;
if (tool->multich!=15) tool->multich++;

  break;

 case 34:

// findloop(samples[tool->multich],TRUE,tool);
//refresh = 1;
  break;


 case 35:

//findloop(samples[tool->multich],FALSE,tool);
//refresh = 1;

 break;

case 39:
//tool->echo[tool->multich]=!tool->echo[tool->multich];
//setdspmask(tool);
//refresh=3;
break;


     } // End of switch
   }
 }

ReplyMsg((struct Message *)message);

    ClearMenuStrip(window);
    tool->tool.window = 0;
    tool->tool.left = window->LeftEdge;
    tool->tool.top = window->TopEdge;
    tool->tool.width = window->Width;
    tool->tool.height = window->Height;
    tool->tool.touched = TOUCH_EDIT | TOUCH_INIT;
    (*functions->FatEmbossedPropOff)(window,3,14,15);
    (*functions->EmbossOff)(window,4);

    (*functions->EmbossOff)(window,5);
    (*functions->EmbossOff)(window,6);  // Scratch toggle button
    (*functions->EmbossOff)(window,25); // Loop toggle button
    (*functions->EmbossOff)(window,26); // Fadee toggle button
    (*functions->EmbossOff)(window,30);
    (*functions->EmbossOff)(window,34);
    (*functions->EmbossOff)(window,35);
    (*functions->EmbossOff)(window,39);

    (*functions->FatEmbossedPropOff)(window,1,8,9);
    (*functions->FatEmbossedPropOff)(window,24,202,203);// Scratch start
    (*functions->FatEmbossedPropOff)(window,27,204,205);// Decay rate
    (*functions->FatEmbossedPropOff)(window,28,206,207);// Pitch bend range;
    (*functions->FatEmbossedPropOff)(window,29,208,209);// Pitch bend range;
    (*functions->FatEmbossedPropOff)(window,23,200,201);// Scratch range
    (*functions->FatEmbossedPropOff)(window,22,18,19); // Scratch length
    (*functions->FatEmbossedPropOff)(window,21,16,17); // Multichannel
    (*functions->FatEmbossedPropOff)(window,3,14,15);  // AHI Master Volume
    (*functions->FatEmbossedPropOff)(window,2,10,11);
    (*functions->FatEmbossedPropOff)(window,7,12,13);

    (*functions->FatEmbossedPropOff)(window,32,210,211);
    (*functions->FatEmbossedPropOff)(window,33,212,213);


    (*functions->FatEmbossedPropOff)(window,36,214,215);  // AHI Master Volume
    (*functions->FatEmbossedPropOff)(window,37,216,217);
    (*functions->FatEmbossedPropOff)(window,38,218,219);

    (*functions->FlashyCloseWindow)(window);
    (*functions->DeleteNewWindow)(newwindow);
}


/******************************************************************************
**** OpenAHI ******************************************************************
******************************************************************************/

/* Open the device for low-level usage */

BOOL OpenAHI(void) {

    if(AHImp = CreateMsgPort()) {
    if(AHIio = (struct AHIRequest *)CreateIORequest(
    AHImp,sizeof(struct AHIRequest))) {
    AHIio->ahir_Version = 4;

      if(!(AHIDevice = OpenDevice(AHINAME, AHI_NO_UNIT,
          (struct IORequest *) AHIio,NULL))) {
        AHIBase = (struct Library *) AHIio->ahir_Std.io_Device;
        return TRUE;
      }
    }
  }
  FreeAudio();
  return FALSE;
}


/******************************************************************************
**** CloseAHI *****************************************************************
******************************************************************************/

/* Close the device */

void CloseAHI(void) {

  if(! AHIDevice)
                  CloseDevice((struct IORequest *)AHIio);
  AHIDevice=-1;
  DeleteIORequest((struct IORequest *)AHIio);
  AHIio=NULL;
  DeleteMsgPort(AHImp);
  AHImp=NULL;
}


/******************************************************************************
**** AllocAudio ***************************************************************
******************************************************************************/

/* Ask user for an audio mode and allocate it */

BOOL AllocAudio(AHITool *tool) {
  struct AHIAudioModeRequester *req;
  BOOL   rc = FALSE;

struct TagItem tags[]={
       AHIDB_Realtime,TRUE,
       AHIDB_Bits,16,
       TAG_DONE};

  req = AHI_AllocAudioRequest(
        AHIR_Screen, functions->screen,
        AHIR_InitialHeight, 320,
        AHIR_InitialWidth,  300,
        AHIR_InitialLeftEdge, 250,
        AHIR_InitialTopEdge,  100,
        AHIR_TitleText,     "Select a mode and rate",
        AHIR_DoMixFreq,     TRUE,
        AHIR_DoDefaultMode, TRUE,
        AHIR_FilterTags, tags,
      TAG_DONE);

if(req) {
     if(AHI_AudioRequest(req, TAG_DONE)) {

         FreeAudio();

         actrl = AHI_AllocAudio(
                    AHIA_AudioID,   req->ahiam_AudioID,
                    AHIA_MixFreq,   req->ahiam_MixFreq,
                    AHIA_PlayerFunc,&PlayerHook,
                    AHIA_Channels,  CHANNELS,
                    AHIA_Sounds,    MAXSAMPLES,
                    TAG_DONE);

               tool->audiomode=req->ahiam_AudioID;
                 tool->mixfreq=req->ahiam_MixFreq;
      if(actrl) {
                 rc = TRUE;
                }
          }
           AHI_FreeAudioRequest(req);
    }
  return rc;
}


/******************************************************************************
**** FreeAudio ****************************************************************
******************************************************************************/

/* Release the audio hardware */

void FreeAudio() {
                  AHI_FreeAudio(actrl);
                  actrl = NULL;
                 }


//*****************************************************************************
UWORD LoadSample(char *filename, UWORD channel, struct AHITool *tool) {

struct AHISampleInfo sample;
UWORD  rc = AHI_NOSOUND;
BPTR file;
struct IFFHandle *iff;
struct FileData *fdata;
 int length;
 int length2;
 iff=AllocIFF();         /* Allocate IFF structure */


file = Open(filename, MODE_OLDFILE);


  if(file) {
            Seek(file, 0, OFFSET_END);
            length = Seek(file, 0, OFFSET_BEGINNING);
            Close(file);

if (iff) {
     if (openiff(iff,filename,IFFF_READ)) {
           if (fdata=readhdr(iff,tool)) {
                                    length2=length-(sizeof(fdata));
                                    samples[channel] = AllocVec(length2, MEMF_PUBLIC);
                                    ReadChunkBytes(iff,samples[channel],length2);
                                    }
                        else {
                              closeiff(iff);
                              FreeIFF(iff);
                              return AHI_NOSOUND;
                             }
                        closeiff(iff);
                }
                FreeIFF(iff);
        }

   length2=length-(sizeof(fdata));

if (stereo[tool->multich]) sample.ahisi_Type = AHIST_S16S;
else        sample.ahisi_Type = AHIST_M16S;

   sample.ahisi_Address = samples[channel];
   sample.ahisi_Length = length2 / AHI_SampleFrameSize(sample.ahisi_Type);

   samplelength[channel]=sample.ahisi_Length;             //   Store length of sample for use

   samplelen=&samplelength[channel];
   tool->samplelength[tool->multich]=sample.ahisi_Length;      //   by the offset routine
   if(! AHI_LoadSound(channel, AHIST_SAMPLE, &sample, actrl)) {
        rc = channel;
      }
  }
  return rc;
}


// RELOAD **********************************************************

void ReloadSample(struct AHITool *tool) {
struct AHISampleInfo sample;

 UWORD i;


for (i=0;i<16;i++) {

if (tool->sample[i]) {
                    if (stereo[tool->multich])  sample.ahisi_Type = AHIST_S16S;
                    else sample.ahisi_Type = AHIST_M16S;

                      sample.ahisi_Address = samples[i];     // *samplearray;
                      sample.ahisi_Length = samplelength[i];
   if(! AHI_LoadSound(i, AHIST_SAMPLE, &sample, actrl)) {
        samps[i] = i;
      }
    }
  }
}



/******************************************************************************
**** UnloadSample *************************************************************
******************************************************************************/

void UnloadSample(UWORD id) {

  AHI_UnloadSound(id, actrl);        // Free a sample from memory
  FreeVec(samples[id]);
  samples[id] = NULL;
}



/******************************************************************************
***** Play Sound **************************************************************
******************************************************************************/

void playsound(UWORD sound, long freq, ULONG vol, ULONG pan,UWORD channel,
               ULONG playoffset, LONG samplelength, struct AHITool *tool) {

  AHI_SetFreq(channel,freq,actrl,AHISF_IMM);                       // Set Frequency
  AHI_SetSound(channel,sound,playoffset,samplelength,actrl,AHISF_IMM); // Set sound etc..
  AHI_SetVol(channel,vol,pan,actrl,AHISF_IMM);                     // Vol and Pan
if (!tool->loopm){
                 AHI_SetSound(channel, AHI_NOSOUND, 0, 0, actrl, 0L);
                }
 }

/*****************************************************************************
*** Stop sound ***************************************************************
*****************************************************************************/

void stopsound(UWORD channel, ULONG pan, ULONG volume){

// Code removed, stop sound is now done using the interupt/fade

}

/*******************************************************************
**** Load function called by DOS call ******************************
*******************************************************************/

void load(struct AHITool *tool)
{

 (*functions->FileName)(tool->filen,"Load AIFF Sample:","",
 functions->screen,FILES_OPEN|FILES_DELETE|FILES_TYPE,0,0);

if (tool->filen[0]!="") {
                    (*functions->openwait)();

     if (samps[tool->multich]) {
                    UnloadSample(samps[tool->multich]);
                    samps[tool->multich]=NULL;
                    tool->sample[tool->multich]=FALSE;
                }
samps[tool->multich] = LoadSample(tool->filen, tool->multich,tool);        // Sample load
                    (*functions->closewait)();

if (samps[tool->multich]!=AHI_NOSOUND) {
                tool->samplename[tool->multich]=strdup(tool->filen);
                samplenames[tool->multich]=strdup(tool->filen);
                tool->sample[tool->multich]=TRUE;
                tool->labels[tool->multich]=strdup(tool->filen);
                strbuff[tool->multich]=strippath(tool->filen);
                strcpy(tool->labels[tool->multich],strbuff[tool->multich]);
                tool->loopstart[tool->multich]=0;
                tool->loopend[tool->multich]=samplelength[tool->multich]/10;
                tool->loopm=FALSE;
               }
        }
 }



/*******************************************************************
*** Calculate pitchbend ********************************************
*******************************************************************/

LONG calcpitchbend(LONG pitchb, LONG nfreq, struct AHITool *tool)

{
   LONG pitch;
   LONG pitch2;

  pitchb=(pitchb-8192);      // Make pitchbend value -8192 to 8192

    if (pitchb> 0 && pitchb <= 8191){
                                    pitch2=(nfreq*pitchb)/8191;
                                    pitch2=pitch2/(tool->pbendr+1);
                                    pitch=(nfreq+pitch2);
                                    return pitch;
                                   }

      else if(pitchb < 0) {
                            pitch2=(nfreq*pitchb)/16382;
                            pitch2=pitch2/(tool->pbendr+1);
                            pitch=(nfreq+pitch2);
                            return pitch;
                          }

    else if(pitchb== 0 ){
                         return nfreq;
                         }
}

/*******************************************************************
********************************************************************
*******************************************************************/

void setmastervol(AHITool *tool)
{

if (!mveffect)
        mveffect = AllocVec(sizeof(struct AHIEffMasterVolume), MEMF_PUBLIC);


if (mveffect) {
           mveffect->ahie_Effect = AHIET_MASTERVOLUME;
           mveffect->ahiemv_Volume = (mastervol*65536/200)*CHANNELS;
           AHI_SetEffect(mveffect,actrl);
              }
}

void setecho(AHITool *tool)
{

if (!dspecho)
        dspecho = AllocVec(sizeof(struct AHIDSPEcho), MEMF_PUBLIC);

if (dspecho) {
           dspecho->ahie_Effect = AHIET_DSPECHO;
           dspecho->ahiede_Delay = 48000*30/(edelay+1);
           dspecho->ahiede_Mix = ((echmix+1)*65536)/100;
           dspecho->ahiede_Feedback = ((feedback+1)*65536)/100;
           dspecho->ahiede_Cross = ((xmix+1)*65536)/100;
           AHI_SetEffect(dspecho,actrl);
              }
}

void setdspmask(AHITool *tool)
{
int counter;


              maskeffect.mask.ahie_Effect = AHIET_DSPMASK;
              maskeffect.mask.ahiedm_Channels = CHANNELS;
for (counter=0;counter<16;counter++)
{
   if (tool->echo[tool->multich])
            maskeffect.mask.ahiedm_Mask[counter]  = AHIEDM_WET;

   else

              maskeffect.mask.ahiedm_Mask[counter]  = AHIEDM_DRY;
}
              AHI_SetEffect(&maskeffect,actrl);
}

// ***************************************************************
// ***************************************************************
// ***************************************************************


/*
 *      Convert an 80 bit IEEE Standard 754 floating point number
 *      into an integer value.
 */

long ex2long(extended *ex)
{
        unsigned long   mantissa = ex -> mantissa[0];
                 long   exponent = ex -> exponent,sign;

        if(exponent & 0x8000) sign = -1; else sign = 1;
        exponent = (exponent & 0x7FFF) - 0x3FFF;

        if(exponent < 0) mantissa = 0;
        else
        {
                exponent -= 31;
                if(exponent > 0) mantissa = 0x7FFFFFFF;
                else mantissa >>= -exponent;
        }
        return(sign * (long)mantissa);
}

/******************************************
 * open/close IFF handle with DOS file
 */

BOOL openiff(struct IFFHandle *iff, char *name,int mode)
{
        if (iff->iff_Stream=Open(name,mode ? MODE_NEWFILE : MODE_OLDFILE)) {
                InitIFFasDOS(iff);
                if (!OpenIFF(iff,mode)) return(TRUE);
                Close(iff->iff_Stream);
                iff->iff_Stream=NULL;
        }
        return(FALSE);
}

void closeiff(struct IFFHandle *iff)
{
        if (iff) if (iff->iff_Stream) {
                CloseIFF(iff);
                Close(iff->iff_Stream);
                iff->iff_Stream=NULL;
        }
}

/********************************************
 * Get file information
 * after this call, IFFHandle is positioned
 * in start of sample data. Just use
 * ReadChunkBytes() to get data..
 */
struct FileData *readhdr(struct IFFHandle *iff, struct AHITool *tool)
{
        static struct FileData fdata;
        struct COMMch *ch;
        struct StoredProperty *prop;
        int buf[2];
        int fail=0;

        fdata.name=NULL;
        fdata.mode=0;
        fdata.codecfreq=0;

// Below, the iffparse library reads the file to find the id chunks 'AIFF' and 'SSND'
// if these aren't found then Fail is assigned a value which will then display
// the appropriate error requestor

if((!PropChunk(iff,ID_AIFF,ID_COMM))&&(!StopChunk(iff,ID_AIFF,ID_SSND))) {
                if (!ParseIFF(iff,IFFPARSE_SCAN)) {
                        if (!(prop=FindProp(iff,ID_AIFF,ID_COMM))) prop=NULL;
                        if (prop) {
                                ch=(struct COMMch *)prop->sp_Data;
                                if ((prop->sp_Size)>0x15) if ((ch->compr)!=ID_NONE) fail=3;
                                if (fail || (ch->channels>2) || (ch->bits!=16))
                                        fail=3;
                                else {
                                        fdata.stereo=ch->channels-1;
                                        fdata.filefreq=ex2long(&ch->rate);
                                        if (ReadChunkBytes(iff,buf,8)!=8) fail=1;
                                        if (buf[0] || buf[1]) fail=3;
                                if (ch->channels==2) stereo[tool->multich]=TRUE; // Sample is stereo
                                else                 stereo[tool->multich]=FALSE;// Sample is mono
                                }
                        } else fail=3; // Not an AIFF file or file is bad
                } else fail=3;
          } else fail=3;


        switch (fail) {
                case 0:
                        return(&fdata);

                case 1:    // Read Error

                        EasyRequest(functions->window, &readerror, NULL,tool->filen,NULL);
                        break;

                case 2:   // IFF Parse Error

                    // Because of modifications, this case isn't called by anything

                        EasyRequest(functions->window, &ifferror, NULL,NULL,NULL);
                        break;

                case 3:  // Bad AIFF file

                        EasyRequest(functions->window, &badaiff, NULL,tool->filen,NULL);
                        break;
     }
      return(NULL);
}

/* -------------------------------------  --------------------------------------

   Strip the path of a filename, eg. 'dh1:samples/bass.aiff' becomes 'bass.aiff'

*/

char *strippath(char *name)
{

int i,j,pos;            // Integers for use in loops and for storing the postion

                        // where the copy shall commence.
char temp[100],*temp2;  // Char arrays used for the source filename with path
                        // and for the destination without the path
i=j=pos=0;              // Init variables


while(i<99){                    // Perform loop while i is less than 99
      if (name[i]=='/') {       // If name[i] is '/', store the position in the
                         pos=i; // array where this occured
                        }
  i++;
}                               // Move to next array element

i=0;                            // Initialise i

if (pos==0) {                   // If a '/' was not found

   while(i<99){                 // While i is less than 99
          if (name[i]==':') {       // If name[i] is ':'
                             pos=i; // Store the position where this occured
                            }
                 i++;               // Move to next array element
              }

            }

if (pos!=0){                       // If a '/' was found

for(i=0;i<pos+1;i++){              // Fill elements in the array with
                   name[i]=0x20;   // spaces up to the position (pos)
                  }

for (i=0;i<100;i++){                 // Copy all the elements in
                                     // the source array to the destination
if (name[i]!=0x20){ temp[j]=name[i]; // array, skipping any spaces.
                    j++;
                  }
}
           }
else {                              // If the filename has no ':' or '/'
       return name;                 // then just send it back
     }

temp2=strdup(temp);                // Duplicate the array into a pointer
return temp2;                      // using strdup
}                                  // return the stripped filename


/* -------------------------------------  --------------------------------------

   Set strings, allocate the memory for the string display and labels.

*/

void setstrings(AHITool *tool)
{
  short index;
  char *s;

  for(index=0 ; index<16 ; ++index)
  {

      if(!tool->samplename[index])
         {tool->samplename[index]=(void *)functions->myalloc(FILELENGTH,MEMF_CLEAR);}

      if(s=tool->samplename[index])
      {
        if(!s[0])
                {
                 functions->myfree(s,FILELENGTH);
                 tool->samplename[index]=NULL;
                }
      }

      if(!tool->labels[index])
         {tool->labels[index]=(void *)functions->myalloc(FILELENGTH,MEMF_CLEAR);}

      if(s=tool->labels[index])
      {
        if(!s[0])
                {
                 functions->myfree(s,FILELENGTH);
                 tool->labels[index]=NULL;
                }
      }
  }
  for(index=0;index<16;index++){ tool->samplename[index]="None";
                            if (!strbuff[index])  strbuff[index]="None";
                                 tool->labels[index]="None";
                               }
}

/*
   Size tool, return the total size of the tool structure for use by savetool
*/
static long sizetool(AHITool *tool)
{
  long size=sizeof(AHITool);
  short id;

  for(id=0 ; id<16 ; ++id)
  {
    if(tool->samplename[id])
        size+=FILELENGTH;
    if(tool->labels[id])
        size+=FILELENGTH;
  }
  return size;
}

/*
   Save tool, saves all the tool structures with the current song to
   be reloaded by Load tool.
*/
static long savetool(long file,AHITool *tool)
{
  long id=ID_AHIT;

tool->mastervol=mastervol;

  functions->fastwrite(file,(char *)&id,4);
  id=sizetool(tool);
  functions->fastwrite(file,(char *)&id,4);
  if(functions->fastwrite(file,(char *)tool,sizeof(AHITool))==-1)
      return 1;
  for(id=0 ; id<16 ; ++id)
  {

if (samplenames[id])
tool->samplename[id]=samplenames[id];

    if(tool->samplename[id])
    {
      if(functions->fastwrite(file,tool->samplename[id],FILELENGTH)==-1)
          return 1;
    }
    if(tool->labels[id])
    {
      if(functions->fastwrite(file,tool->labels[id],FILELENGTH)==-1)
          return 1;
    }
  }
  return 0;
}

/* -------------------------------------  --------------------------------------

   Load tool, loads the data chunk stored in the saved song from disk

*/

static struct Tool *loadtool(long file,long size)
{

  AHITool *tool=(AHITool *)functions->myalloc(sizeof(AHITool),MEMF_CLEAR);
  short i;
  UWORD j;

  if(tool)
  {
    functions->fastread(file,(char *)tool,sizeof(AHITool));
    size-=sizeof(AHITool);
    for(i=0 ; i<16 ; ++i)
    {

char *temp[32];

                    if(tool->samplename[i])
                          {
                           tool->samplename[i]=(void *)functions->myalloc(FILELENGTH,0);
                           if(tool->samplename[i])
                           {
                            functions->fastread(file,tool->samplename[i],FILELENGTH);
                            size-=FILELENGTH;
                            samplenames[i]=strdup(tool->samplename[i]);
                            temp[i]=strdup(tool->samplename[i]);
                            strbuff[i]=strippath(temp[i]);
                         }
                     }
                    if(tool->labels[i])
                          {
                           tool->labels[i]=(void *)functions->myalloc(FILELENGTH,0);
                           if(tool->labels[i])
                           {
                            functions->fastread(file,tool->labels[i],FILELENGTH);
                            size-=FILELENGTH;
                           }
                       fadeoutspeed[i]=tool->fadeoutspd;
                    }
               }

for(j=0;j<16;j++)
       {

if (tool->sample[j]&&tool->samplename[j]) {
                   if (samps[j]) UnloadSample(samps[j]);
                                 samps[j]=NULL;

if (tool->sample[j])
                  {
                   samps[j]=LoadSample(tool->samplename[j], j, tool);

if (samps[j]==AHI_NOSOUND){
                            EasyRequest(functions->window, &filelost, NULL,NULL,NULL);
                            (*functions->FileName)(filen,"Select replacement","",
                            functions->screen,FILES_OPEN|FILES_DELETE|FILES_TYPE,0,0);
                            samps[j]=LoadSample(filen, j, tool);

                            tool->samplename[j]=strdup(filen);
                            samplenames[j]=strdup(filen);
                            tool->labels[j]=strdup(filen);
                            strbuff[j]=strippath(filen);
                            //strcpy(tool->labels[j],strbuff[j]);
                          }
                    }
              }
        }
  }

mastervol=tool->mastervol;

functions->fastseek(file,size,0);
alldone=TRUE;

 return (struct Tool *)tool;
}

/* -------------------------------------  --------------------------------------

  Cancel effects, cancels all effects and frees memory allocated by their
  structures.

*/

void canceleffects(struct AHITool *tool)
{

if (mveffect){
          mveffect->ahie_Effect = AHIET_CANCEL | AHIET_MASTERVOLUME;
          AHI_SetEffect(mveffect,actrl);                          // Clear and cancel
          FreeVec(mveffect);                                      // Master volume
          mveffect=NULL;
   }

if (dspecho){
           dspecho->ahie_Effect = AHIET_CANCEL | AHIET_DSPECHO;
           AHI_SetEffect(dspecho,actrl);                          // Clear and cancel
           FreeVec(dspecho);                                      // Master volume
           dspecho=NULL;
              }

//if (maskeffect){
//           maskeffect.mask.ahie_Effect = AHIET_CANCEL | AHIET_DSPMASK;
//           AHI_SetEffect(&maskeffect,actrl);                          // Clear and cancel
         //  FreeVec(dspmask);                                      // Master volume
         //  dspmask=NULL;
  //            }
}


/* -------------------------------------  --------------------------------------

  Create tool, duplicates the tool structure and allocates memory for the two strings

*/
struct Tool *createtool(AHITool *copy)
{
  AHITool *tool=(AHITool *)functions->myalloc(sizeof(AHITool),MEMF_CLEAR);
  short i;

  if(tool)
  {
    if(copy)
    {
      *tool=*copy;
      tool->tool.next=NULL;
      for(i=0 ; i<16 ; ++i)
      {
if(copy->samplename[i])
                   {
                    tool->samplename[i]=(void *)functions->myalloc(FILELENGTH,MEMF_CLEAR);
                    if(tool->samplename[i])
                    memcpy(tool->samplename[i],copy->samplename[i],FILELENGTH);
                   }
if(copy->labels[i])
                   {
                    tool->labels[i]=(void *)functions->myalloc(FILELENGTH,MEMF_CLEAR);
                    if(tool->labels[i])
                    memcpy(tool->labels[i],copy->labels[i],FILELENGTH);
                   }
      }
    }
  }
  return (struct Tool *)tool;
}

/*
   deletetool

   delete a tool and free all dynamically allocated memory
*/
static void deletetool(AHITool *tool)
{
short i;
for (i=0;i<16;i++)
{
if (tool->sample[i])
 {
  UnloadSample(samps[i]);
  tool->sample[i]=FALSE;
  samps[i]=NULL;
  }
 }
 functions->doscall(stopplay,tool);
 canceleffects(tool);
  cleartool(tool);
  functions->myfree((char *)tool,sizeof(AHITool));


}

/*
  cleartool

  reset all strings to be blank and free their memory.
*/
void cleartool(AHITool *tool)
{
  short i;
 alldone=FALSE;

  for(i=0 ; i<16 ; ++i)
  {
    if(tool->samplename[i])
    {
      functions->myfree(tool->samplename[i],FILELENGTH);
      tool->samplename[i]=NULL;
    }
    if(tool->labels[i])
    {
      functions->myfree(tool->labels[i],FILELENGTH);
      tool->labels[i]=NULL;
    }
  }


}

/* -------------------------------------  --------------------------------------

 Re-alloc audio, frees the audio channels so the Audio mode can be changed.

*/

void reAllocAudio(AHITool *tool)
{

if (audio&&play) {
                  AHI_ControlAudio(actrl,
                  AHIC_Play, FALSE,
                  TAG_DONE);
                  play=FALSE;
                 }
if (audio&&mveffect)
{
          mveffect->ahie_Effect = AHIET_CANCEL | AHIET_MASTERVOLUME;
          AHI_SetEffect(mveffect,actrl);                          // Clear and cancel
          FreeVec(mveffect);                                      // Master volume
          mveffect=NULL;
}
                 audio=AllocAudio(tool);  // AHI Mode select button
                 ReloadSample(tool);

                     AHI_ControlAudio(actrl,
                     AHIC_Play, TRUE,
                     TAG_DONE);
                     play=TRUE;
}

/* -------------------------------------  --------------------------------------

 Stop play, stops playback on all channels

*/

void stopplay(AHITool *tool)
{
if (audio&&play) {
                  AHI_ControlAudio(actrl,
                  AHIC_Play, FALSE,
                  TAG_DONE);
                  play=FALSE;
                 }
                     AHI_ControlAudio(actrl,
                     AHIC_Play, TRUE,
                     TAG_DONE);
                     play=TRUE;
}


/* -------------------------------------  --------------------------------------

 AHI Mode Info, returns the name of the current audio mode.

*/


void AHImodeinfo(struct AHITool *tool)
{
int i;

for (i=0;i<35;i++) modename[i]=32;

 AHI_GetAudioAttrs(AHI_INVALID_ID,actrl,AHIDB_Name,modename,
                                        AHIDB_BufferLen,34,TAG_DONE);
for (i=0;i<35;i++){

   if (modename[i]==0x00) modename[i]=0x20;
 }
}

void drawline(struct Window *window,int x, int y, int endx, int endy)
{
    SetAPen(window->RPort,1);
    SetBPen(window->RPort,3);
    SetDrMd(window->RPort,JAM2);
    Move(window->RPort,x,y);
    Draw(window->RPort,endx,endy);
    SetAPen(window->RPort,2);
    Move(window->RPort,x,y+1);
    Draw(window->RPort,endx,endy+1);
    SetAPen(window->RPort,3);
    Move(window->RPort,x,y+2);
    Draw(window->RPort,endx,endy+2);
}


void clearsample(struct AHITool *tool, int x)
{
 if (tool->sample[x]){ UnloadSample(samps[x]);

   tool->sample[x]=FALSE;
   strbuff[x]="None";
   tool->labels[x]="None";
   tool->samplename[x]="None";
   samplelength[x]=0;
 }
}


void findloop(UWORD *sample, BOOL start, struct AHITool *tool){

//if (start) sample=(UWORD *)(tool->loopstart[tool->multich]*10);
//else       sample=(UWORD *)(tool->loopend[tool->multich]*10);

if (start)
//sample=&tool->loopst;

//else sample=&tool->looped;

sample++;
tool->length++;


  while((*sample !=32768 ) && (tool->length<samplelength[tool->multich])) {
    sample++;
    tool->length++;
  }


if (start) tool->loopst=sample;
else       tool->looped=sample;

if (start) tool->loopstart[tool->multich]=(ULONG)sample/10;
else       tool->loopend[tool->multich]=(ULONG)sample/10;

}


static struct ToolMaster master;

struct ToolMaster *inittoolmaster(void)

{
 int i;

 ahiopen=FALSE;

IFFParseBase = OpenLibrary ("iffparse.library", 0L);
for(i = 0; i < CHANNELS; i++) channelstate[i].FadeOut = FALSE;

ahiopen=OpenAHI();

actrl=NULL;

while (!actrl) {

 actrl = AHI_AllocAudio(
         AHIA_AudioID,    AHI_DEFAULT_ID,
         AHIA_MixFreq,    AHI_DEFAULT_FREQ,
         AHIA_Channels,   CHANNELS,
         AHIA_PlayerFunc, &PlayerHook,
         AHIA_Sounds,     MAXSAMPLES,
         TAG_DONE);

if (actrl) audio=TRUE;
else {
      EasyRequest(functions->window, &ahifail, NULL,NULL,NULL);
     }

}


if (audio){
           AHI_ControlAudio(actrl,
           AHIC_Play, TRUE,
           TAG_DONE);
           play=TRUE;
          }

    memset((char *)&master,0,sizeof(struct ToolMaster));
    master.toolid = ID_AHIT;
    master.image = &ahiimage;
    strcpy(master.name,"AHI Output");
    master.loadtool    = loadtool;
    master.savetool    = savetool;
    master.savesize    = sizetool;
    master.edittool    = edittoolcode;
    master.createtool  = createtool;
    master.deletetool  = deletetool;
    master.removetool  = removetool;
    master.processevent = processeventcode;
    master.tooltype = TOOL_OUTPUT|TOOL_ONTIME;
    master.toolsize = sizeof(struct AHITool);
    return(&master);
}


