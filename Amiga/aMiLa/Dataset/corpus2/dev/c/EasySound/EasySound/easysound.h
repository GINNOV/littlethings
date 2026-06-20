#ifndef EASYSOUND_H
#define EASYSOUND_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif /* EXEX_TYPES_H */

/* 
 * Sound channels:
 */
#define L0         0 // Left  0
#define R0         1 // Right 0
#define R1         2 // Left  1
#define L1         3 // Right 1

#define NONSTOP       0 // Repeat the sound over and over and ...
#define ONCE          1 // Play the sample only once
#define MAXVOL       64 // Maximal Volume
#define MINVOL        0 // Minimal Volume
#define DONT_WAIT     0 // Do _not_ wait 'til the sound has finished
#define WAIT          1 // Wait 'til the sound has finished

struct SoundInfo {
    BYTE *SoundBuffer;  // Buffer to hold the waveform
    UWORD RecordRate;   // Record rate
    ULONG FileLength;   // Length of wave
    UBYTE channel_bit;  // Channel to use
};

#endif /* EASYSOUND_H */

