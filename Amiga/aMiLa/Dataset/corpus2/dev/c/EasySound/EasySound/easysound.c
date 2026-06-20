/*********************************************************************
* Play Sound V1.1 - written with the aid of the 2.0 RKRMs in 1993 for
* my PingPong game. You may use it in your programs for free. Please
* read the docs for more information.
*********************************************************************/

/// "Includes, Defines, Typedefs, ..."
#include <clib/alib_protos.h>
#include <clib/exec_protos.h>
#include <clib/graphics_protos.h>
#include <clib/dos_protos.h>
#include <exec/types.h>
#include <exec/memory.h>
#include <libraries/dos.h>
#include <devices/audio.h>
#include <graphics/gfxbase.h>
#include <stdio.h>
#include <string.h>
#include "easysound.h"

#define Prototype   extern

#define CLOCK_PAL   3579545
#define CLOCK_NTSC  3546895

struct IOAudio *IO[] = {
    NULL,       // All channels are switched off by default
    NULL, 
    NULL, 
    NULL
};

struct Voice8Header {
    ULONG  oneShotHiSamples;  // high octave 1-shot samples
    ULONG  repeatHiSamples;   // high octave repeat samples
    ULONG  samplesPerHiCycle; // high octave samples per cycle
    UWORD  samplesPerSec;     // sampling rate
    UBYTE  ctOctave;          // number of octaves
    UBYTE  sCompression;      // Compression mode
    LONG   vol;               // Playback volume
} SampleHeader;

struct HEADER {
    UBYTE   Form[4];
    long    length;
    UBYTE   Type[4];
} Header;

struct SoundInfo {
    BYTE *SoundBuffer;  // Buffer to hold the waveform
    UWORD RecordRate;   // Record rate
    ULONG FileLength;   // Length of wave
    UBYTE channel_bit;  // Channel to use
};

UBYTE version_tag[] = "\0$VER: EasySound V1.1 (7.8.94) ";
///
/// "Prototypes"
Prototype BOOL PlayIff (struct SoundInfo *info, UWORD vol, UBYTE chan, BYTE prio, WORD drate, UWORD repeat, ULONG start, ULONG time, BOOL wait);

Prototype void StopIff (UBYTE chan);

Prototype LONG GetClockSpeed(void);

Prototype void RemoveIff(struct SoundInfo *info);

Prototype struct SoundInfo *LoadIff(STRPTR name);

Prototype void FindChunk(BPTR file, char *searchchunk);
///
/// "PlayIff"
/****** EasySound/PlayIff **********************************************
*
*   NAME
*       PlayIff -- Play an IFF sample
*
*   SYNOPSIS
*       success = PlayIff(info, vol, chan, prio, drate, times, start,
*                         time, wait)
*       BOOL PlayIff
*           (struct SoundInfo *, UWORD, UBYTE, BYTE, WORD, UWORD, ULONG,
*            ULONG, BOOL)
*
*   FUNCTION
*       Plays an IFF sample. The sample has to be converted to an include
*       file with the aid of the external program 'iff2src'. The resulting 
*       sound data has to be placed in chip memory using e.g. the __chip 
*       keyword.
*
*   INPUTS
*       info        - A (struct SoundInfo *) pointer to the structure.
*       vol         - The volume of the sound (between 0 and 64).
*       chan        - The channel on which the sample will be played, can
*                     be either left or right ;-) . You may use the magic
*                     cookies L0, L1, R0, R1.
*       prio        - State a priority for the sample. (may be something
*                     between -127 and 128.
*       drate       - The sample rate is already stored in the SoundInfo
*                     structure. If you don't want to change the rate,
*                     leave this value 0.
*       times       - How many times do you want this sound to be played.
*                     If you set this value to 0 the sound will be played
*                     nonstop. (You may stop it with StopIff)
*       start       - Where do you want to start the sample, leave this
*                     value to 0 if you want to start at the beginning.
*       time        - How long do you want to play this sound, leave this
*                     value to 0 if you want to play the whole sample.
*       wait        - If you set this value to TRUE your program will wait
*                     until the Sample is played. If it's set to FALSE your
*                     program will continue to run while the sample is
*                     played.
*
*   RESULT
*       success     - Returns TRUE if the sound was played with success,
*                     otherwise the function will return FALSE.
*
*   EXAMPLE
*       PlayIff(&splat_data,64,L0,-35,0,1,0,0,0);
*
*   SEE ALSO
*       StopIff, RemoveIff, LoadIff
*************************************************************************/
BOOL PlayIff (struct SoundInfo *info, UWORD vol, UBYTE chan, BYTE prio,
              WORD drate, UWORD times, ULONG start, ULONG time, BOOL wait) {

    LONG clock;
    BYTE error;
    struct MsgPort *port;
    UWORD period;

    /*
     * Stop the sound on this channel first (if one is still in use)
     */
    StopIff(chan);

    /*
     * Get the ClockSpeed depend on wheter you use a PAL or NTSC Amiga
     */
    clock = GetClockSpeed();

    /*
     * Prepare the complete device stuff.
     */

    period = clock/info->RecordRate+drate;
    
    /*
     * Create a message port
     */
    port = (struct MsgPort *)CreatePort(NULL, 0);
    if(!port) {
        return(FALSE);
    }

    /*
     * Create an IO request:
     */
    IO[chan]=(struct IOAudio *)CreateExtIO(port,sizeof(struct IOAudio));
    if(!IO[chan]) {
      DeletePort(port);
      return(FALSE);
    }
    
    /*
     * Init Audio struct
     */
    IO[chan]->ioa_Request.io_Message.mn_Node.ln_Pri = prio;
    info->channel_bit = 1<<chan;
    IO[chan]->ioa_Data = &(info->channel_bit);
    IO[chan]->ioa_Length = sizeof(UBYTE);

    /*
     * And now open the Audio Device
     */
    error =  OpenDevice(AUDIONAME, 0, (struct IORequest *)IO[chan], 0);
    if(error) {
        DeleteExtIO((struct IORequest *)IO[chan]);
        DeletePort(port);
        IO[chan] = NULL;
        return(FALSE);
    }

    IO[chan]->ioa_Request.io_Flags = ADIOF_PERVOL;
    IO[chan]->ioa_Request.io_Command = CMD_WRITE;
    IO[chan]->ioa_Period = period;
    IO[chan]->ioa_Volume = vol;
    IO[chan]->ioa_Cycles = times;

    if(time)
        IO[chan]->ioa_Length = time;
    else
        IO[chan]->ioa_Length = info->FileLength;

    IO[chan]->ioa_Data = info->SoundBuffer + start;

    /*
     * Here's the output stuff
     */
    BeginIO((struct IORequest *)IO[chan]);
    if(wait)
        WaitIO((struct IORequest *)IO[chan]);
    return(TRUE);
}
///
/// "StopIff"
/****** EasySound/StopIff **********************************************
*
*   NAME
*       StopIff -- Stop an IFF sample
*
*   SYNOPSIS
*       StopIff(chan)
*
*       void StopIff (UBYTE)
*
*   FUNCTION
*       Will stop the sound on the specified audio channel. It'll close the
*       the devices and ports and free the allocated memory. If you call 
*       this function without any sound being played it'll simply return.
*
*   INPUTS
*       chan        - The channel that should be stopped. You may use the
*                     magic cookies L0,L1,R0,R1 for this task.
*
*   SEE ALSO
*       PlayIff, RemoveIff, LoadIff
************************************************************************/
void StopIff (UBYTE chan) {

    /*
     * Test if this channel is REALLY(!) in use, otherwise this function
     * will simply return without doing anything.
     */
    if(IO[chan]) {
        AbortIO((struct IORequest *)IO[chan]);

        if(IO[chan]->ioa_Request.io_Device)
            CloseDevice((struct IORequest *)IO[chan]);

        if(IO[chan]->ioa_Request.io_Message.mn_ReplyPort)
            DeletePort(IO[chan]->ioa_Request.io_Message.mn_ReplyPort);

        DeleteExtIO((struct IORequest *)IO[chan]);
        IO[chan] = NULL;
    }
}
///
/// "GetClockSpeed"
/****** EasySound/GetClockSpeed *****************************************
*
*   NAME
*       GetClockSpeed -- Determine the clock speed for PAL / NTSC
*
*   SYNOPSIS
*       clock = GetClockSpeed()
*
*       LONG GetClockSpeed( void )
*
*   FUNCTION
*       This function returns the clockspeed for e.g samples depending
*       on the system you use (NTSC or PAL).
*
*   SEE ALSO
*       RKRM, Guru Book page 62/63
*************************************************************************/
LONG GetClockSpeed() {

    struct GfxBase *GfxBase;
    LONG clockspeed = CLOCK_PAL;

    GfxBase = (struct GfxBase *)OpenLibrary("graphics.library",0);

    if (GfxBase) {
        if (GfxBase->DisplayFlags & NTSC)
            clockspeed = CLOCK_NTSC;

        if (GfxBase->DisplayFlags & PAL)
            clockspeed = CLOCK_PAL;

        CloseLibrary((struct Library *)GfxBase);
    }

    return clockspeed;
}
///
/// "RemoveIff"
/****** EasySound/RemoveIff **********************************************
*
*   NAME
*       RemoveIff -- Remove a previous loaded Sound.
*
*   SYNOPSIS
*       RemoveIff(info)
*
*       void RemoveIff (struct SoundInfo *)
*
*   FUNCTION
*       Will flush a loaded sample and free the memory.
*
*   INPUTS
*       info        - Pointer to the SoundInfo structure
*
*   SEE ALSO
*       PlayIff, StopIff, LoadIff
************************************************************************/
void RemoveIff(struct SoundInfo *info) {
    if (info) {
        FreeMem(info->SoundBuffer, info->FileLength);
        FreeMem(info, sizeof(struct SoundInfo));
    }
}
///
/// "LoadIff"
/****** EasySound/LoadIff **********************************************
*
*   NAME
*       LoadIff -- Load an external sample in the chip memory
*
*   SYNOPSIS
*       info = LoadIff(filename)
*
*       struct SoundInfo *LoadIff(STRPTR)
*
*   FUNCTION
*       Loads an external 8svx sample in chip memory and returns a pointer
*       to the SoundInfo structure or NULL if the whole thing failed.
*
*   INPUTS
*       filename    - Name of the file, eventually with path.
*
*   SEE ALSO
*       PlayIff, StopIff, LoadIff
************************************************************************/
struct SoundInfo *LoadIff(STRPTR name) {

    BPTR    file;
    struct  SoundInfo       *info;

    /*
     * Allocate the memory for the SoundInfo structure and clear it
     */
    info = (struct SoundInfo *)AllocMem(sizeof(struct SoundInfo), MEMF_CLEAR);
    if (!info) {
        return (NULL);
    }

    /*
     * Open the file (read mode) and exit if the file can't be opened
     * (remember: This is compiled with DICE, this compiler will handle
     * the opening and closing of the Dos Library for me when finding the
     * first DosLib call, in this case it's Open() )
     */
    file = Open(name,MODE_OLDFILE);
    if (!file) {
        FreeMem(info, sizeof(struct SoundInfo));
        return (NULL);
    }

    /*
     * Read the first 12 bytes, it's the IFF Header and we can take a look
     * at the last 4 bytes to see if it's an 8SVX file. The first 4 bytes
     * contains the FORM chunk, the 2nd 4 bytes will give you the length of
     * this file and the last 4 bytes contain the identifier (8SVX, ILBM,
     * CTLG, ...)
     */
    Read(file, &Header, sizeof(Header));

    if (strcmp(Header.Type,"8SVX") != 0) {
        FreeMem(info, sizeof(struct SoundInfo));
        Close(file);
        return (NULL);
    }
    
    /*
     * Search for the VHDR chunk, it marks the position of the sample header
     * We need it to calculate the record rate and the sample length.
     */
    FindChunk(file, "VHDR");
    Read(file, &SampleHeader, sizeof(SampleHeader));

    info->FileLength = SampleHeader.oneShotHiSamples + SampleHeader.repeatHiSamples;
    info->RecordRate = SampleHeader.samplesPerSec;

    /*
     * Exit if the FileLength or the RecordRate is 0, something must be
     * wrong in the file.
     */
    if (info->FileLength == 0 || info->RecordRate == 0) {
        FreeMem(info, sizeof(struct SoundInfo));
        Close(file);
        return (NULL);
    }

    /*
     * The old FutureSound format stored the RecordRate in KHz instead of 
     * Hz. FutureSound Recordrates are smaller than 100, therefor we'll have
     * to change them to Hz. (1KHz === 1000Hz).
     */
    if (info->RecordRate < 100)
        info->RecordRate *= 1000;

    /*
     * Now that we have received the length of the sample we're ready to
     * allocate the Buffer for the sample. Remember: It must be placed in
     * Chipmem.
     */
    info->SoundBuffer = (BYTE *)AllocMem(info->FileLength,MEMF_CHIP | MEMF_CLEAR);
    if (!info->SoundBuffer) {
        FreeMem(info, sizeof(struct SoundInfo));
        Close(file);
        return (NULL);
    }

    /*
     * Ok, allocation the buffer was successfully. Let's fill it with the
     * sample data.
     */
    FindChunk(file, "BODY");
    Read(file, info->SoundBuffer, info->FileLength);

    Close(file);

    return info;
}
///
/// "FindChunk"
/****i* EasySound/FindChunk **********************************************
*
*   NAME
*       FindChunk -- Search for a special chunk in an IFF file.
*
*   SYNOPSIS
*       FindChunk(file, search)
*
*       void FindChunk(BPTR, char *)
*
*   FUNCTION
*       Search for a special chunk in an IFF file and set the File
*       pointer on this chunk.
*
*   INPUTS
*       file        - Pointer on a file opened with Open()
*       search      - An Iff chunk to search for (e.g ILBM, 8SVX, BODY)
*
*
*   SEE ALSO
*       dos.library/Open
************************************************************************/
void FindChunk(BPTR file, char *searchchunk) {

    UBYTE chunk[4];

    /*
     * Rewind the file to the beginning.
     */
    Seek(file, 0, OFFSET_BEGINNING);

    while (strcmp(chunk, searchchunk) != 0) {
        Read(file, &chunk, sizeof(chunk));
    }
    Read(file, &chunk, sizeof(chunk));
}
///

